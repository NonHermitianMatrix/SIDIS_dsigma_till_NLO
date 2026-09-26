(* Map new spin numerators with the unchanged accepted real-integral mapper. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s08_map_real_spin.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "RealMapFailure"], CloseKernels[]; Quit[1]]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate["time bound " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory bound " <> ToString[label, InputForm], False]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
configPath = FileNameJoin[{root, "common", "s08_inputs.json"}];
config = Import[configPath, "RawJSON"];
originalMapperPath = FileNameJoin[{root, config["original_mapper"]}];
gate["pinned original mapper", IntegerString[FileHash[originalMapperPath, "SHA256"], 16, 64] === config["original_mapper_sha256"]];
originalText = Import[originalMapperPath, "Text"];
originalBlock = StringTake[originalText, {First[First[StringPosition[originalText, "merge[pieces_List]"]]],
  First[First[StringPosition[originalText, "mapTask[task_]"]]] - 1}];
gate["unchanged mapping functions", StringContainsQ[Import[sourcePath, "Text"], originalBlock]];
spinPath = FileNameJoin[{root, channel, "s05_result", "s05_result.wl"}];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
spin = Get[spinPath]; library = Get[libraryPath];
gate["accepted real spin input", spin["Schema"] === "polarized-sidis-real-response-v1" &&
  spin["Channel"] === channel && And @@ Values[spin["Checks"]]];
gate["accepted scalar reuse library", library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
geometryOriginal = readLibrary["s02"]; reductionOriginal = readLibrary["s04"];
gate["accepted geometry and reduction", geometryOriginal["Accepted"] && reductionOriginal["Accepted"]];
scalarConventionRules = {Q2 -> Q^2, w -> s23};
geometry = geometryOriginal /. scalarConventionRules;
reduction = reductionOriginal /. scalarConventionRules;
denominators = geometry["OnCutUncutPropagators"]; directions = geometry["UncutDirections"];
families = geometry["Families"]; familyNames = Keys[families];
commonBasis = geometry["BasisMomenta"];
commonCoordinates[value_] := Coefficient[Expand[value], #] & /@ commonBasis;
commonDot[left_, right_] := Factor[commonCoordinates[left].geometry["CommonGram"].commonCoordinates[right] /. geometry["CutRules"]];
momentumRules = {k2 -> First[geometry["LoopMomenta"]], k3 -> geometry["RecoilMomentum"] - First[geometry["LoopMomenta"]]};
gate["same cut momenta", And @@ (Expand[#] === 0 & /@ ((spin["CutMomenta"] /. momentumRules) - geometry["CutMomenta"]))];
gate["same positive-energy support", (spin["CutEnergySupport"] /. momentumRules) === geometry["CutEnergyConditions"]];
rows = spin["RealScalarProducts"]; oldValues = rows[[All, 3]];
targetValues = (commonDot[#[[1]] /. momentumRules, #[[2]] /. momentumRules] &) /@ rows;
globalSymbols[value_] := DeleteDuplicates[Cases[value, symbol_Symbol /; Context[symbol] === "Global`", Infinity]];
coordinateUnknowns = Complement[globalSymbols[oldValues], globalSymbols[geometry["CommonGram"]]];
coordinateSolutions = Solve[Thread[oldValues == targetValues], coordinateUnknowns];
gate["unique loop-coordinate conversion", Length[coordinateSolutions] === 1 && FreeQ[coordinateSolutions, _ConditionalExpression]];
coordinateRules = First[coordinateSolutions];
gate["all scalar products reconstruct", And @@ (zero /@ ((oldValues /. coordinateRules) - targetValues))];
gate["coordinate change preserves measured transverse constraint", FreeQ[spin["TransverseConstraint"], Alternatives @@ coordinateUnknowns]];

merge[pieces_List] := If[pieces === {}, <||>,
  Select[Merge[pieces, Factor[Together[Total[#]]] &], # =!= 0 &]];

(* All partial-fraction coefficients are solved from the actual affine
   propagators. No angular integral or phase-space formula is used. *)
decompose[powers_List] := decompose[powers] = Module[
  {support, relations, relation, constant, pieces, lowered},
  support = Flatten[Position[powers, _?(# > 0 &)]];
  If[support === {}, Return[<|powerKey @@ powers -> 1|>]];
  If[Length[support] <= 2 && MatrixRank[directions[[support]]] === Length[support],
    Return[<|powerKey @@ powers -> 1|>]];
  relations = NullSpace[Transpose[directions[[support]]]];
  relation = SelectFirst[relations, !zero[#.denominators[[support]]] &, $Failed];
  gate["nonzero affine relation for dependent propagators", relation =!= $Failed];
  constant = Factor[relation.denominators[[support]]];
  gate["relation constant is independent of loop coordinates", FreeQ[constant, a | b]];
  pieces = MapThread[Function[{position, coefficient},
    If[coefficient === 0, <||>,
      lowered = ReplacePart[powers, position -> powers[[position]] - 1];
      Map[Factor[coefficient #/constant] &, decompose[lowered]]]], {support, relation}];
  merge[pieces]];

extractAtoms[expression_] := Module[{rational, factors, powers, found, ratio, prefactor},
  rational = Together[expression];
  factors = Rest[FactorList[Denominator[rational]]];
  powers = ConstantArray[0, Length[denominators]];
  Do[If[!FreeQ[factor[[1]], a | b],
    found = SelectFirst[Range[Length[denominators]],
      Function[index, ratio = Cancel[factor[[1]]/denominators[[index]]];
        ratio =!= 0 && FreeQ[ratio, a | b]], Missing["UnknownPropagator"]];
    If[MissingQ[found], Print["UNKNOWN_PROPAGATOR ", InputForm[factor[[1]]]]];
    gate["every loop-dependent factor is a generated propagator", !MissingQ[found]];
    powers[[found]] += factor[[2]]], {factor, factors}];
  prefactor = Cancel[rational Times @@ MapThread[Power, {denominators, powers}]];
  gate["atom extraction leaves a polynomial numerator",
    FreeQ[Denominator[Together[prefactor]], a | b]];
  {powers, prefactor}];

familyRows[expression_, family_] := Module[
  {spec, transformed, numerator, denominator, denominatorPowers, denominatorCoefficient,
   polynomial, rows, reconstruction},
  spec = families[family];
  transformed = Together[expression /. spec["UncutCoordinateRules"]];
  numerator = Expand[Numerator[transformed]];
  denominator = Factor[Denominator[transformed]];
  gate["family numerator is polynomial", PolynomialQ[numerator, {v3, v4}]];
  denominatorPowers = Exponent[denominator, #] & /@ {v3, v4};
  denominatorCoefficient = Cancel[denominator/(Times @@ MapThread[Power,
    {{v3, v4}, denominatorPowers}])];
  gate["family denominator is a Laurent monomial", FreeQ[denominatorCoefficient, v3 | v4]];
  polynomial = CoefficientRules[numerator, {v3, v4}];
  rows = Association[Map[Function[entry,
    CutIntegral[family, Join[ConstantArray[1, Length[geometry["CutMomenta"]]],
      denominatorPowers - First[entry]]] -> Factor[Last[entry]/denominatorCoefficient]], polynomial]];
  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power, {{v3, v4}, -Drop[integral[[2]], 2]}]], rows]];
  gate["family Laurent coefficients reconstruct", zero[reconstruction - transformed]];
  rows];

mapExpression[expression_] := Module[{powers, prefactor, decomposition, pieces, rows, reconstruction},
  If[expression === 0, Return[<||>]];
  {powers, prefactor} = extractAtoms[expression];
  decomposition = decompose[powers];
  pieces = KeyValueMap[Function[{key, coefficient},
    Module[{indices = List @@ key, support, family, value},
      support = Flatten[Position[indices, _?(# > 0 &)]];
      family = SelectFirst[familyNames,
        Complement[support, families[#]["UncutIndices"]] === {} &, Missing["NoFamily"]];
      gate["every independent denominator set has a family", !MissingQ[family]];
      value = Cancel[prefactor coefficient/(Times @@ MapThread[Power, {denominators, indices}])];
      familyRows[value, family]]], decomposition];
  rows = merge[pieces];
  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power,
      {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], rows]];
  gate["complete cut-family map reconstructs the input tensor", zero[reconstruction - expression]];
  gate["both physical cuts remain to unit power in every target",
    And @@ (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[rows])];
  rows];


coefficientPath = FileNameJoin[{root, config["coefficient_source"]}];
gate["pinned GitHub coefficient assembly", IntegerString[FileHash[coefficientPath, "SHA256"], 16, 64] === config["coefficient_source_sha256"]];
coefficientText = Import[coefficientPath, "Text"];
coefficientBlock = StringTake[coefficientText, {
  First[First[StringPosition[coefficientText, "\n  values=Association@Table["]]],
  First[First[StringPosition[coefficientText, "\n  gate[\"coefficients contain"]]] - 1}];
gate["unchanged GitHub coefficient loop", StringContainsQ[Import[sourcePath, "Text"], coefficientBlock]];
referenceCoefficients[coefficients_, masterList_, key_] := Module[{ruleMap, missingKeys, values, terms},
  ruleMap = Association[reduction["Rules"]];
  missingKeys = Complement[Keys[coefficients], Keys[ruleMap]];
  ruleMap = Join[ruleMap, AssociationThread[missingKeys, missingKeys]];

  values=Association@Table[
    terms=KeyValueMap[#2 Coefficient[ruleMap[#1],master] &,coefficients];
    master -> bounded[Factor[Together[Total[terms]]],channel<>" "<>key<>" "<>ToString[master,InputForm]],
    {master,masterList}];
  gate["reduced coefficients are scalar rational expressions", FreeQ[values, _CutIntegral | _Real | $Failed | $Aborted | _Integrate | _SeriesData]];
  values];

sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = {configPath, originalMapperPath, coefficientPath, spinPath, libraryPath,
  FileNameJoin[{root, library["Library"]["s02"]["File"]}], FileNameJoin[{root, library["Library"]["s04"]["File"]}]};
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s08", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
tasks = {}; bookkeeping = <||>;
Do[
  sector = spin["Sectors"][label];
  AssociateTo[bookkeeping, label -> KeyTake[sector, {"TagWeight", "TagWeightAppliedToTensor", "OutgoingFields",
    "IncomingSpinLabels", "OutgoingSpinLabels", "ChargeDegrees", "AmplitudeCouplingPowers"}]];
  MapIndexed[Function[{value, index}, If[value =!= 0,
    AppendTo[tasks, <|"Sector" -> label, "Kind" -> "ExtendedResponse", "Index" -> index, "Value" -> value|>]]], sector["ExtendedResponse"], {3}];
  AppendTo[tasks, <|"Sector" -> label, "Kind" -> "PhotonMetricD", "Index" -> {}, "Value" -> sector["PhotonMetricD"]|>],
  {label, Keys[spin["Sectors"]]}];
ruleKeys = First /@ reduction["Rules"];
gate["unique saved reduction targets", DuplicateFreeQ[ruleKeys]];
mappingInputHashes = inputHashes;
previousMapperPath = FileNameJoin[{root, "common", "s08_result", "reference", "s08_map_real_spin_before_known_denominator.wls"}];
gate["pinned previous production mapper", IntegerString[FileHash[previousMapperPath, "SHA256"], 16, 64] ===
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f"];
previousMappingHash = Hash[{FileHash[previousMapperPath, "SHA256"], mappingInputHashes, $Version, $FeynCalcVersion}, "SHA256"];
sumValidationPath = FileNameJoin[{root, "Hqqprime", "s08_cancel_denominator_result", "s08_result.wl"}];
gate["pinned complete rational-sum validation", IntegerString[FileHash[sumValidationPath, "SHA256"], 16, 64] ===
  "215afefb5862347917f3db9fecb401e34c59fcd4a858c12731ae55bdecaef0da"];
sumValidation = Get[sumValidationPath];
gate["accepted complete rational-sum validation", sumValidation["Schema"] === "polarized-sidis-known-denominator-validation-v1" &&
  And @@ Values[sumValidation["Checks"]] && AllTrue[sumValidation["Evidence"], TrueQ[#["Evidence"]["ExactTermwiseReconstructionPassed"]] &]];
DownValues[factoredDenominatorSum] = sumValidation["Definitions"];
DownValues[cancelKnownDenominatorFactors] = sumValidation["CancellationDefinitions"];
gate["executed rational-sum definitions", DownValues[factoredDenominatorSum] === sumValidation["Definitions"] &&
  DownValues[cancelKnownDenominatorFactors] === sumValidation["CancellationDefinitions"]];
sumFixtureConfigPath = FileNameJoin[{root, "common", "s08_rational_sum_inputs.json"}];
sumFixtureConfig = Import[sumFixtureConfigPath, "RawJSON"];
sumFixturePath = FileNameJoin[{root, sumFixtureConfig["raw_map"]}];
gate["accepted coefficient control raw-map identity", FileHash[sumFixturePath, "SHA256"] === sumValidation["RawMapHash"]];
sumFixture = Get[sumFixturePath];
gate["accepted coefficient control reconstruction", And @@ Values[sumFixture["MappingChecks"]]];
controlRuleMap = Association[reduction["Rules"]];
controlMissing = Complement[Keys[sumFixture["Coefficients"]], Keys[controlRuleMap]];
controlRuleMap = Join[controlRuleMap, AssociationThread[controlMissing, controlMissing]];
controlMaster = sumValidation["ControlMaster"];
controlTerms = KeyValueMap[#2 Coefficient[controlRuleMap[#1], controlMaster] &, sumFixture["Coefficients"]];
controlValue = sumValidation["ReducedCoefficients"][controlMaster];
gate["validation used these original reduction rules", sumValidation["InputHashes"][library["Library"]["s04"]["File"]] ===
  mappingInputHashes[library["Library"]["s04"]["File"]]];
extendedReductionUsed = False;
extensionRelative = Environment["POLARIZED_SIDIS_REAL_REDUCTION"];
If[StringQ[extensionRelative] && StringLength[extensionRelative] > 0,
  extensionPath = FileNameJoin[{root, extensionRelative}]; extendedReduction = Get[extensionPath];
  gate["accepted real reduction extension", extendedReduction["Schema"] === "polarized-sidis-real-reduction-extension-v1" &&
    TrueQ[extendedReduction["Accepted"]] && And @@ Values[extendedReduction["Checks"]]];
  gate["real reduction extension original input identities", extendedReduction["GeometryHash"] ===
    mappingInputHashes[library["Library"]["s02"]["File"]] && extendedReduction["BaselineReductionHash"] ===
    mappingInputHashes[library["Library"]["s04"]["File"]]];
  gate["real reduction extension source identity", extendedReduction["SourceHash"] ===
    FileHash[FileNameJoin[{root, "common", "s08_extend_real_reduction.wls"}], "SHA256"]];
  gate["real reduction extension retains original masters and cuts", Sort[extendedReduction["Masters"]] ===
    Sort[reductionOriginal["Masters"]] && extendedReduction["CutEnergyConditions"] === geometryOriginal["CutEnergyConditions"]];
  reduction = extendedReduction /. scalarConventionRules; ruleKeys = First /@ reduction["Rules"];
  gate["unique extended reduction targets", DuplicateFreeQ[ruleKeys]];
  AppendTo[inputPaths, extensionPath]; extendedReductionUsed = True];

rawTargetPath = FileNameJoin[{root, channel, "s08_targets_result", "s08_result.wl"}];
rawTargetComponents = {};
If[FileExistsQ[rawTargetPath],
  rawTarget = Get[rawTargetPath];
  gate["accepted complete raw-target map", rawTarget["Schema"] === "polarized-sidis-real-target-map-v1" &&
    rawTarget["Channel"] === channel && TrueQ[rawTarget["MappingAccepted"]] && And @@ Values[rawTarget["Checks"]]];
  gate["raw-target map identical physical inputs", rawTarget["InputHashes"] === mappingInputHashes &&
    rawTarget["MapperSourceHash"] === FileHash[previousMapperPath, "SHA256"] && rawTarget["MappingInputHash"] === previousMappingHash];
  rawTargetComponents = rawTarget["Components"];
  gate["raw-target component ordering", (KeyTake[#, {"Sector", "Kind", "Index"}] & /@ rawTargetComponents) ===
    (KeyDrop[#, "Value"] & /@ tasks) && And @@ Lookup[rawTargetComponents, "ReconstructionPassed"]];
  AppendTo[inputPaths, rawTargetPath]];
inputPaths = Join[inputPaths, {previousMapperPath, sumValidationPath, sumFixtureConfigPath, sumFixturePath}];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s08", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
putCompressed[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[bounded[Compress[value], {path, "native compression"}], InputForm] <> "]\n";
  gate["compressed scalar map below file bound", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["compressed scalar map exact round trip", bounded[Get[path <> ".tmp"] === value, {path, "native reload"}]];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
coefficientControl[] := Catch[Block[{checks = <||>}, Module[{answer},
  answer = factoredDenominatorSum[controlTerms, "fresh production worker control"];
  gate["fresh worker reproduces accepted original coefficient", bounded[zero[answer["Value"] - controlValue], "worker coefficient comparison"]];
  <|"Checks" -> checks, "Kernel" -> $KernelID|>]], "RealMapFailure"];
mapComponent[index_] := Catch[Block[{checks = <||>}, Module[
  {task, pairPath, saved, rawPath, raw, coefficients, missing, ruleMap, missingKeys,
   remaining, rule, masters, terms, packetPath, packet, reducedCoefficients, evidence, reuseValidation},
  task = tasks[[index]];
  pairPath = FileNameJoin[{cache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
  If[Lookup[saved, "InputHash", None] === inputHash && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && And @@ Values[saved["Checks"]], Return[saved]];
  Print["REAL_MAP ", channel, " ", index, "/", Length[tasks], " ", KeyDrop[task, "Value"], " kernel ", $KernelID];
  rawPath = FileNameJoin[{cache, "raw_" <> IntegerString[index, 10, 4] <> ".wl"}];
  raw = If[rawTargetComponents =!= {}, rawTargetComponents[[index]], If[FileExistsQ[rawPath], Get[rawPath], <||>]];
  If[rawTargetComponents =!= {} || (Lookup[raw, "InputHash", None] === inputHash && TrueQ[Lookup[raw, "ReconstructionPassed", False]]),
    gate["raw component retains executed reconstruction", AssociationQ[raw["Checks"]] && And @@ Values[raw["Checks"]] &&
      (Length[raw["Checks"]] > 0 || ((task["Value"] /. coordinateRules) === 0 && raw["Coefficients"] === <||>))];
    coefficients = raw["Coefficients"],
    coefficients = bounded[mapExpression[task["Value"] /. coordinateRules], {index, "real mapping"}];
    gate["raw map has exact reconstruction evidence", TrueQ[Lookup[checks, "complete cut-family map reconstructs the input tensor", False]] ||
      ((task["Value"] /. coordinateRules) === 0 && coefficients === <||>)];
    raw = <|"InputHash" -> inputHash, "Coefficients" -> coefficients, "Checks" -> checks, "ReconstructionPassed" -> True|>;
    putCompressed[raw, rawPath]];
  missing = Complement[Keys[coefficients], ruleKeys, reduction["Masters"]];
  ruleMap = Association[reduction["Rules"]];
  missingKeys = Complement[Keys[coefficients], Keys[ruleMap]];
  ruleMap = Join[ruleMap, AssociationThread[missingKeys, missingKeys]];
  remaining = Union[Cases[Values[KeyTake[ruleMap, Keys[coefficients]]], _CutIntegral, Infinity]];
  gate["known rules end in saved masters", Complement[remaining, Join[missing, reduction["Masters"]]] === {}];
  Do[
    rule = ruleMap[target]; masters = Union[Cases[rule, _CutIntegral, {0, Infinity}]];
    gate["exact individual reduction-rule reconstruction", bounded[
      zero[rule - Total[(Coefficient[rule, #] #) & /@ masters]], {index, target, "rule reconstruction"}]],
    {target, Keys[coefficients]}];
  reducedCoefficients = <||>; evidence = {};
  reuseValidation = !extendedReductionUsed && channel === sumValidation["Channel"] && mappingInputHashes === sumValidation["InputHashes"] &&
    KeyDrop[task, "Value"] === sumValidation["Task"] && coefficients === sumFixture["Coefficients"];
  If[reuseValidation,
    gate["accepted complete component master inventory unchanged", Keys[sumValidation["ReducedCoefficients"]] === remaining];
    reducedCoefficients = sumValidation["ReducedCoefficients"]; evidence = sumValidation["Evidence"];,
    Do[
      packetPath = FileNameJoin[{cache, "component_" <> IntegerString[index, 10, 4] <> "_master_" <>
        IntegerString[Hash[master, "SHA256"], 16] <> ".wl"}];
      packet = If[FileExistsQ[packetPath], Get[packetPath], <||>];
      If[Lookup[packet, "InputHash", None] =!= inputHash || !TrueQ[Lookup[packet, "ReconstructionPassed", False]],
        terms = KeyValueMap[#2 Coefficient[ruleMap[#1], master] &, coefficients];
        Print["REAL_MASTER_COEFFICIENT ", channel, " ", index, " ", InputForm[master]];
        packet = factoredDenominatorSum[terms, {index, master}];
        If[Lookup[packet["Evidence"], "TermCount", None] === 0,
          gate["empty master sum reconstructs", DeleteCases[terms, 0] === {} && packet["Value"] === 0];
          packet = Join[packet, <|"Evidence" -> Join[packet["Evidence"], <|"ExactTermwiseReconstructionPassed" -> True|>]|>]];
        packet = Join[packet, <|"InputHash" -> inputHash, "Master" -> master, "Checks" -> checks, "ReconstructionPassed" -> True|>];
        putCompressed[packet, packetPath]];
      gate["master coefficient retains exact reconstruction", TrueQ[packet["Evidence"]["ExactTermwiseReconstructionPassed"]] &&
        And @@ Values[packet["Checks"]]];
      AssociateTo[reducedCoefficients, master -> packet["Value"]];
      AppendTo[evidence, KeyDrop[packet, {"Value", "InputHash", "Checks"}]], {master, remaining}]];
  gate["complete linear reduced coefficient reconstruction", Keys[reducedCoefficients] === remaining &&
    AllTrue[evidence, TrueQ[#["Evidence"]["ExactTermwiseReconstructionPassed"]] &]];
  gate["reduced coefficients are scalar rational expressions", FreeQ[reducedCoefficients,
    _CutIntegral | _Real | $Failed | $Aborted | _Integrate | _SeriesData]];
  saved = Join[KeyDrop[task, "Value"], <|"Coefficients" -> coefficients, "ReducedCoefficients" -> reducedCoefficients,
    "MissingTargets" -> missing, "InputHash" -> inputHash, "ReconstructionPassed" -> True,
    "Checks" -> checks, "CoefficientEvidence" -> evidence, "AcceptedValidationReused" -> reuseValidation|>];
  putCompressed[saved, pairPath]; ClearSystemCache[]; Print["REAL_MAP_ACCEPTED ", channel, " ", index]; saved]], "RealMapFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  gate["scalar-map workers share compute node", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  gate["scalar-map worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@
    ParallelEvaluate[{$Version, $FeynCalcVersion}])];
  DistributeDefinitions[gate, bounded, put, putCompressed, zero, factoredDenominatorSum, cancelKnownDenominatorFactors,
    coefficientControl, controlTerms, controlValue, mapComponent, tasks, cache, inputHash, mappingInputHashes,
    rawTargetComponents, sumValidation, sumFixture, channel, coordinateRules, ruleKeys, reduction, extendedReductionUsed,
    merge, decompose, extractAtoms, familyRows, mapExpression, denominators, directions, families, familyNames, geometry]];
$DistributedContexts = None;
workerControl = First[If[workers > 0, ParallelMap[Function[unused, coefficientControl[]], {1}], {coefficientControl[]}]];
gate["production worker coefficient control accepted", AssociationQ[workerControl] && And @@ Values[workerControl["Checks"]]];
components = If[workers > 0, ParallelMap[mapComponent, Range[Length[tasks]], Method -> "FinestGrained"],
  mapComponent /@ Range[Length[tasks]]];
CloseKernels[];
gate["all scalar-map workers accepted", AllTrue[components, AssociationQ] && And @@ Flatten[Values[#["Checks"]] & /@ components]];
targets = Union[Flatten[Keys[#["Coefficients"]] & /@ components]];
missingTargets = Union[Flatten[Lookup[components, "MissingTargets"]]];
gate["all nonzero components mapped", Length[components] === Length[tasks] && And @@ Lookup[components, "ReconstructionPassed"]];
result = <|"Schema" -> "polarized-sidis-real-scalar-map-v1", "Channel" -> channel,
  "Components" -> components, "Targets" -> targets, "MissingTargets" -> missingTargets,
  "SavedMasterInventory" -> reduction["Masters"], "ReductionCoverageComplete" -> (missingTargets === {}),
  "ScalarConventionRules" -> scalarConventionRules, "CoordinateRules" -> coordinateRules,
  "Bookkeeping" -> bookkeeping, "PhotonLabels" -> spin["PhotonLabels"], "SpinLabels" -> spin["SpinLabels"],
  "IndexOrder" -> spin["IndexOrder"], "CutMomenta" -> geometry["CutMomenta"], "CutEnergySupport" -> geometry["CutEnergyConditions"],
  "TransverseSubstitution" -> spin["TransverseSubstitution"], "TransverseConstraint" -> spin["TransverseConstraint"],
  "Gamma5Scheme" -> spin["Gamma5Scheme"], "CouplingsRemoved" -> spin["CouplingsRemoved"],
  "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "RationalSumValidationHash" -> FileHash[sumValidationPath, "SHA256"], "WorkerCount" -> workers,
  "Checks" -> checks, "MappingAccepted" -> True, "MasterExpansionDepthChecked" -> False,
  "PhaseSpaceIntegrated" -> False, "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s08_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
putCompressed[result, FileNameJoin[{resultDir, "s08_result.wl"}]];
Export[FileNameJoin[{resultDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "component_count" -> Length[components], "target_count" -> Length[targets], "missing_target_count" -> Length[missingTargets],
  "reduction_coverage_complete" -> (missingTargets === {}), "finite_nlo_fhats_computed" -> False,
  "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s08_map_real_spin"]; Quit[0];

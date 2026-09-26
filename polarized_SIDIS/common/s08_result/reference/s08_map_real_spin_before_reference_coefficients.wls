(* Map new spin numerators with the unchanged accepted real-integral mapper. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s08_map_real_spin.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  Print["FAIL: time bound ", label]; Quit[2]], 2*1024^3,
  Print["FAIL: memory bound ", label]; Quit[3]];
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


sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = {configPath, originalMapperPath, spinPath, libraryPath,
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
components = {}; targets = {};
Do[
  task = tasks[[index]]; pairPath = FileNameJoin[{cache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["REAL_MAP ", channel, " ", index, "/", Length[tasks], " ", task["Sector"], " ", task["Kind"], " ", task["Index"]];
    value = task["Value"] /. coordinateRules;
    coefficients = bounded[mapExpression[value], {index, "real mapping"}];
    ownTargets = Keys[coefficients]; missing = Complement[ownTargets, ruleKeys, reduction["Masters"]];
    reducedExpression = Total[KeyValueMap[Times, coefficients]] /. reduction["Rules"];
    remaining = Union[Cases[reducedExpression, _CutIntegral, Infinity]];
    gate["known rules end in saved masters", Complement[remaining, Join[missing, reduction["Masters"]]] === {}];
    reducedCoefficients = AssociationMap[Factor[Coefficient[Expand[reducedExpression], #]] &, remaining];
    gate["linear reduced coefficient reconstruction", zero[reducedExpression - Total[KeyValueMap[Times, reducedCoefficients]]]];
    saved = Join[KeyDrop[task, "Value"], <|"Coefficients" -> coefficients,
      "ReducedCoefficients" -> reducedCoefficients, "MissingTargets" -> missing,
      "InputHash" -> inputHash, "ReconstructionPassed" -> True|>];
    put[saved, pairPath]; Clear[coefficients, reducedExpression, reducedCoefficients, value]; ClearSystemCache[]];
  AppendTo[components, saved]; targets = Union[targets, Keys[saved["Coefficients"]]], {index, Length[tasks]}];
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
  "Checks" -> checks, "MappingAccepted" -> True, "MasterExpansionDepthChecked" -> False,
  "PhaseSpaceIntegrated" -> False, "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s08_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s08_result.wl"}]];
Export[FileNameJoin[{resultDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "component_count" -> Length[components], "target_count" -> Length[targets], "missing_target_count" -> Length[missingTargets],
  "reduction_coverage_complete" -> (missingTargets === {}), "finite_nlo_fhats_computed" -> False,
  "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s08_map_real_spin"]; Quit[0];

(* Reuse the original complete virtual topologies and their Kira reductions. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s09_map_virtual_spin.wls"}];
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
merge[pieces_List] := If[pieces === {}, <||>,
  Select[Merge[pieces, Factor[Together[Total[#]]] &], # =!= 0 &]];

spinPath = FileNameJoin[{root, channel, "s07_result", "s07_result.wl"}];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
configPath = FileNameJoin[{root, "common", "s07_inputs.json"}];
config = Import[configPath, "RawJSON"];
referencePath = FileNameJoin[{root, config["channels"][channel]["destination"]}];
gate["pinned original virtual map", IntegerString[FileHash[referencePath, "SHA256"], 16, 64] === config["channels"][channel]["sha256"]];
spin = Get[spinPath]; reference = Get[referencePath]; library = Get[libraryPath];
gate["accepted virtual spin tensor", spin["Schema"] === "polarized-sidis-virtual-response-v1" &&
  spin["Channel"] === channel && And @@ Values[spin["Checks"]]];
gate["accepted original map and scalar library", reference["Accepted"] &&
  library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
reduction = readLibrary["s09"] /. Q2 -> Q^2;
parents = readLibrary["s12"]; evaluations = readLibrary["s13"];
gate["accepted virtual reductions and master values", reduction["Accepted"] && parents["Accepted"] && evaluations["AcceptedEuclideanParents"]];
changes = reduction["Canonicalization"]; families = reduction["Families"];
ruleKeys = First /@ reduction["Rules"];
gate["unique saved rule targets", DuplicateFreeQ[ruleKeys]];
FCClearScalarProducts[];
Scan[Function[row, With[{left = row[[1]], right = row[[2]], value = row[[3]]}, SPD[left, right] = value]],
  Join[spin["BornScalarProducts"], spin["LoopScalarProducts"]]];
loopVariables = spin["LoopScalarProducts"][[All, 3]];
canonicalize[GLI[id_String, indices_List]] := GLI[changes[id]["Family"], indices[[changes[id]["Permutation"]]]];

mapExpression[expression_, topology_] := Module[{id, lines, forms, variables, matrix, constant, coordinateRules,
    transformed, numerator, denominator, denominatorPowers, denominatorCoefficient, polynomial,
    coefficients, reconstructed, change, momenta, old, new, canonicalCoefficients},
  If[expression === 0, Return[<||>]];
  gate["nonzero spin integrand has an inherited topology", MatchQ[topology, _FCTopology]];
  id = topology[[1]]; lines = topology[[2]];
  gate["inherited canonical routing exists", KeyExistsQ[changes, id]];
  forms = ExpandScalarProduct[1/FeynAmpDenominatorExplicit[#]] & /@ lines;
  variables = Array[propagatorCoordinate, Length[forms]];
  matrix = Table[Coefficient[forms[[i]], variable], {i, Length[forms]}, {variable, loopVariables}];
  constant = forms /. Thread[loopVariables -> 0];
  gate["complete affine loop coordinates", Length[forms] === Length[loopVariables] && Det[matrix] =!= 0 &&
    And @@ (zero /@ (forms - matrix.loopVariables - constant))];
  coordinateRules = Thread[loopVariables -> LinearSolve[matrix, variables - constant]];
  gate["loop coordinate reconstruction", And @@ (zero /@ ((forms /. coordinateRules) - variables))];
  transformed = Together[expression /. coordinateRules];
  numerator = Expand[Numerator[transformed]]; denominator = Factor[Denominator[transformed]];
  gate["polynomial virtual numerator", PolynomialQ[numerator, variables]];
  denominatorPowers = Exponent[denominator, #] & /@ variables;
  denominatorCoefficient = Cancel[denominator/(Times @@ MapThread[Power, {variables, denominatorPowers}])];
  gate["inherited topology covers every spin denominator", FreeQ[denominatorCoefficient, Alternatives @@ variables]];
  polynomial = CoefficientRules[numerator, variables];
  coefficients = Association[(GLI[id, denominatorPowers - First[#]] -> Factor[Last[#]/denominatorCoefficient]) & /@ polynomial];
  reconstructed = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power, {forms, -integral[[2]]}]], coefficients]];
  gate["complete virtual integrand reconstruction", zero[reconstructed - expression]];
  gate["native massless standard topology", MatchQ[lines,
    {FeynAmpDenominator[StandardPropagatorDenominator[Momentum[_, D], 0, 0, {1, 1}]]..}]];
  momenta = #[[1, 1, 1]] & /@ lines; change = changes[id];
  Do[
    old = momenta[[change["Permutation"][[i]]]] /. ell -> change["Orientation"] ell - change["Anchor"];
    new = families[change["Family"]]["PropagatorMomenta"][[i]];
    gate["inherited canonical propagator reconstruction", zero[ExpandScalarProduct[SPD[old, old] - SPD[new, new]]]],
    {i, Length[momenta]}];
  canonicalCoefficients = merge[KeyValueMap[(<|canonicalize[#1] -> #2|>) &, coefficients]];
  canonicalCoefficients];

reduceCoefficients[coefficients_] := Module[{missing, expression, remaining, values},
  missing = Complement[Keys[coefficients], ruleKeys, reduction["Masters"]];
  expression = Total[KeyValueMap[Times, coefficients]] /. reduction["Rules"];
  remaining = Union[Cases[expression, _GLI, Infinity]];
  gate["known rules terminate in saved masters", Complement[remaining, Join[missing, reduction["Masters"]]] === {}];
  values = AssociationMap[Factor[Coefficient[Expand[expression], #]] &, remaining];
  gate["linear virtual reduction reconstruction", zero[expression - Total[KeyValueMap[Times, values]]]];
  <|"Coefficients" -> coefficients, "ReducedCoefficients" -> values, "MissingTargets" -> missing|>];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = Join[{spinPath, libraryPath, configPath, referencePath},
  (FileNameJoin[{root, library["Library"][#]["File"]}] &) /@ {"s09", "s12", "s13"}];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s09", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
diagrams = {};
Do[
  index = diagram["Diagram"]; pairPath = FileNameJoin[{cache, "diagram_" <> IntegerString[index, 10, 2] <> ".wl"}];
  saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["VIRTUAL_MAP ", channel, " diagram ", index];
    originalMaps = Select[reference["DiagramMaps"], #["Diagram"] === index &];
    topology = SelectFirst[Lookup[originalMaps, "Topology"], MatchQ[#, _FCTopology] &, Missing["ZeroUnpolarizedDiagram"]];
    tasks = {};
    MapIndexed[Function[{value, position}, If[value =!= 0,
      AppendTo[tasks, <|"Kind" -> "ExtendedResponse", "Index" -> position, "Value" -> value|>]]], diagram["ExtendedResponse"], {3}];
    AppendTo[tasks, <|"Kind" -> "PhotonMetricD", "Index" -> {}, "Value" -> diagram["PhotonMetricD"]|>];
    MapIndexed[Function[{value, position}, AppendTo[tasks,
      <|"Kind" -> "PhotonWardLeft", "Index" -> position, "Value" -> value|>]], diagram["PhotonWardLeft"]];
    components = Table[Print["VIRTUAL_COMPONENT ", index, " ", task["Kind"], " ", task["Index"]];
      mapped = bounded[mapExpression[task["Value"], topology], {index, task["Index"], "virtual mapping"}];
      Join[KeyDrop[task, "Value"], bounded[reduceCoefficients[mapped], {index, "virtual reduction"}]], {task, tasks}];
    Do[
      original = SelectFirst[originalMaps, #["Mode"] === mode &];
      ownCDR = reduceCoefficients[bounded[mapExpression[diagram["CDRContractions"][mode], topology], {index, mode, "CDR mapping"}]];
      gate["reference projection reduction is covered", ownCDR["MissingTargets"] === {}];
      originalExpression = (Total[KeyValueMap[Times, original["Coefficients"]]] /.
        integral_GLI :> canonicalize[integral]) /. reduction["Rules"] /. Q2 -> Q^2;
      gate["diagram " <> ToString[index] <> " reduced reference " <> mode,
        zero[Total[KeyValueMap[Times, ownCDR["ReducedCoefficients"]]] - originalExpression]], {mode, {"Pg", "Ppp"}}];
    saved = <|"Diagram" -> index, "Components" -> components, "InputHash" -> inputHash,
      "ReconstructionPassed" -> True, "ReducedReferenceChecksPassed" -> True|>;
    put[saved, pairPath]; Clear[components, mapped]; ClearSystemCache[]];
  AppendTo[diagrams, saved], {diagram, spin["Diagrams"]}];
gate["all virtual diagrams mapped", Length[diagrams] === Length[spin["Diagrams"]] &&
  And @@ Lookup[diagrams, "ReconstructionPassed"] && And @@ Lookup[diagrams, "ReducedReferenceChecksPassed"]];
allComponents = Flatten[Lookup[diagrams, "Components"], 1];
componentKeys = DeleteDuplicates[({#["Kind"], #["Index"]} &) /@ allComponents];
components = Association@Table[key -> merge[Lookup[Select[allComponents, {#["Kind"], #["Index"]} === key &], "ReducedCoefficients"]],
  {key, componentKeys}];
targets = Union[Flatten[Keys /@ Lookup[allComponents, "Coefficients"]]];
missingTargets = Union[Flatten[Lookup[allComponents, "MissingTargets"]]];
valuation[expression_] := If[expression === 0, Infinity, With[{rational = Together[expression /. D -> 4 - 2 eps]},
  Exponent[Numerator[rational], eps, Min] - Exponent[Denominator[rational], eps, Min]]];
requiredOrders = Merge[(Map[If[# === Infinity, 0, Max[0, -#]] &, Map[valuation, #]] &) /@ Values[components], Max];
masterCoverage = missingTargets === {};
depthCoverage = masterCoverage && And @@ KeyValueMap[Function[{master, order},
  With[{series = evaluations["Parents"][parents["VirtualMasterParents"][master]["ParentID"]]["Series"]},
    MatchQ[series, _SeriesData] && series[[5]] > order]], requiredOrders];
result = Join[KeyTake[spin, {"Channel", "PhotonLabels", "SpinLabels", "IncomingSpinLabels", "OutgoingSpinLabels", "IndexOrder",
    "TransverseSubstitution", "TransverseConstraint", "BornScalarProducts", "IncomingNormalization", "ModelChargeSquared",
    "CouplingsRemoved", "MasslessQuarkSpecialization", "Gamma5Scheme", "Measure", "LoopPrescription", "InterferenceConvention"}],
  <|"Schema" -> "polarized-sidis-virtual-scalar-map-v1", "Diagrams" -> diagrams, "Components" -> components,
    "Targets" -> targets, "MissingTargets" -> missingTargets, "RequiredOrders" -> requiredOrders,
    "ReductionCoverageComplete" -> masterCoverage, "MasterExpansionDepthSufficient" -> depthCoverage,
    "ScalarConventionRules" -> {Q2 -> Q^2}, "SavedMasterInventory" -> reduction["Masters"],
    "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "Checks" -> checks, "MappingAccepted" -> True, "LoopIntegrated" -> False,
    "IntegratedWardChecksPassed" -> False, "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>];
resultDir = FileNameJoin[{root, channel, "s09_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s09_result.wl"}]];
Export[FileNameJoin[{resultDir, "s09_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "diagram_count" -> Length[diagrams], "component_count" -> Length[components], "target_count" -> Length[targets],
  "missing_target_count" -> Length[missingTargets], "master_expansion_depth_sufficient" -> depthCoverage,
  "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s09_map_virtual_spin"]; Quit[0];

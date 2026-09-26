(* Retain the reference order: map each accepted diagram pair, then sum. *)
$HistoryLength = 0;
pairStudyPath = FileNameJoin[{Directory[], "common", "s08_check_gluon_pair_mapping.wls"}];
pairConfigPath = FileNameJoin[{Directory[], "common", "s08_gluon_pair_mapping_inputs.json"}];
pairConfig = Import[pairConfigPath, "RawJSON"];
pairBasePath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
If[IntegerString[FileHash[pairBasePath, "SHA256"], 16, 64] =!=
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9",
  Print["FAIL: pinned reference target mapper"]; Quit[1]];
pairBaseText = Import[pairBasePath, "Text"];
pairBoundary = StringPosition[pairBaseText, "\nmapTargetTask[index_]"];
If[Length[pairBoundary] =!= 1, Print["FAIL: unique target initialization"]; Quit[1]];
pairPrefix = StringTake[pairBaseText, First[First[pairBoundary]] - 1];
If[!SyntaxQ[pairPrefix], Print["FAIL: target initialization syntax"]; Quit[1]];
ToExpression[pairPrefix, InputForm];
gate["complete pair comparison syntax", SyntaxQ[Import[pairStudyPath, "Text"]]];
gate["pair comparison channel", channel === pairConfig["channel"] && channel === "Hgq"];
KeyValueMap[Function[{relative, identity}, gate["pinned pair input " <> relative,
  IntegerString[FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] === identity]], pairConfig["files"]];
pairBasisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
pairBasis = Get[pairBasisPath];
pairExtractionPath = FileNameJoin[{root, "Hqqprime", "s05_spin_extraction_result", "s05_result.wl"}];
pairExtraction = Get[pairExtractionPath];
gate["accepted complete spin extraction", pairExtraction["Schema"] === "polarized-sidis-spin-extraction-validation-v1" &&
  And @@ Values[pairExtraction["Checks"]] && pairExtraction["BasisInputHash"] === FileHash[pairBasisPath, "SHA256"]];
gate["same accepted spin basis", spin["InputHashes"]["common/s02_result/s02_result.wl"] === FileHash[pairBasisPath, "SHA256"] &&
  pairBasis["PhotonLabels"] === spin["PhotonLabels"] && pairBasis["SpinLabels"] === spin["SpinLabels"]];
DownValues[compactSpinResponse] = pairExtraction["ExtractionDefinitions"];
gate["unchanged accepted spin extraction definition", DownValues[compactSpinResponse] === pairExtraction["ExtractionDefinitions"]];
pairLabel = First[Keys[spin["Sectors"]]];
gate["single inherited real sector", Keys[spin["Sectors"]] === {pairLabel}];
pairSector = spin["Sectors"][pairLabel];
pairNames = pairConfig["pair_files"];
pairIndices = (FromDigits /@ StringCases[FileBaseName[#], DigitCharacter ..]) & /@ pairNames;
gate["complete inherited diagram-pair inventory", pairIndices === pairSector["DiagramPairs"] && DuplicateFreeQ[pairNames]];
pairInputs = Get[FileNameJoin[{root, #}]] & /@ pairNames;
gate["every pair belongs to accepted real tensor", AllTrue[pairInputs,
  #["InputHash"] === spin["InputHash"] && AssociationQ[#["Checks"]] && And @@ Values[#["Checks"]] &]];
pairVariablesIn = Take[{1, xIn, yIn, hIn, eIn}, Length[pairSector["IncomingSpinLabels"]]];
pairVariablesOut = Take[{1, xOut, yOut, hOut, eOut}, Length[pairSector["OutgoingSpinLabels"]]];
gate["inherited gluon and quark spin axes", pairSector["IncomingSpinLabels"] === Append[pairBasis["SpinLabels"], "E"] &&
  pairSector["OutgoingSpinLabels"] === pairBasis["SpinLabels"]];
pairOwnControlPath = FileNameJoin[{root, pairConfig["own_control"]}];
pairOwnControl = Get[pairOwnControlPath];
gate["accepted same-channel target control", pairOwnControl["InputHash"] === targetInputHash &&
  TrueQ[pairOwnControl["ReconstructionPassed"]] && And @@ Values[pairOwnControl["Checks"]]];
pairControlIndex = First[FirstPosition[KeyDrop[#, "Value"] & /@ tasks,
  KeyTake[pairOwnControl, {"Sector", "Kind", "Index"}]]];
pairEIndex = SelectFirst[Range[Length[tasks]], tasks[[#]]["Kind"] === "ExtendedResponse" &&
  Last[tasks[[#]]["Index"]] === Length[pairVariablesIn] &, Missing["NoGluonComplement"]];
gate["gluon complement present in actual tensor", IntegerQ[pairEIndex]];
pairSelected = DeleteDuplicates[Join[{pairControlIndex, pairEIndex}, pairConfig["component_indices"]]];
gate["selected actual components", AllTrue[pairSelected, IntegerQ[#] && Between[#, {1, Length[tasks]}] &]];
pairStudyHash = Hash[{FileHash[pairStudyPath, "SHA256"], FileHash[pairConfigPath, "SHA256"], inputHashes,
  targetInputHash, $Version, $FeynCalcVersion}, "SHA256"];
pairCache = FileNameJoin[{root, "cache", "s08_pair_mapping", channel, IntegerString[pairStudyHash, 16]}];
If[!DirectoryQ[pairCache], CreateDirectory[pairCache, CreateIntermediateDirectories -> True]];
pairSave[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[bounded[Compress[value], "pair-map compression"], InputForm] <> "]\n";
  gate["pair-map file bound", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["pair-map exact native reload", bounded[Get[path <> ".tmp"] === value, "pair-map reload"]];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
pairExpression[record_, task_] := Module[{photon, response},
  Switch[task["Kind"],
    "ExtendedResponse",
      photon = Tr[#.record["PhotonMatrix"]] & /@ pairBasis["PhotonDual"];
      response = compactSpinResponse[photon, pairVariablesIn, pairVariablesOut];
      Extract[response, task["Index"]],
    "PhotonMetricD", record["ScalarModes"]["PgD"],
    _, gate["inherited task kind", False]]];
pairMap[packet_] := Catch[Block[{checks = <||>}, Module[{path, saved, coefficients, seconds},
  path = FileNameJoin[{pairCache, "component_" <> ToString[packet["Component"]] <> "_pair_" <> ToString[packet["PairIndex"]] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "Binding", None] === packet["Binding"] && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]], Return[saved]];
  Print["REFERENCE_PAIR_MAP ", packet["Component"], " pair ", packet["PairIndex"], " bytes ", ByteCount[packet["Value"]]];
  {seconds, coefficients} = AbsoluteTiming[bounded[mapExpression[packet["Value"]],
    {"reference pair mapping", packet["Component"], packet["PairIndex"]}]];
  If[packet["Value"] === 0, gate["exact zero pair retains empty map", coefficients === <||>]];
  saved = <|"Binding" -> packet["Binding"], "Component" -> packet["Component"], "PairIndex" -> packet["PairIndex"],
    "Coefficients" -> coefficients, "Seconds" -> seconds, "InputBytes" -> ByteCount[packet["Value"]],
    "OutputBytes" -> ByteCount[coefficients], "Checks" -> checks, "ReconstructionPassed" -> True|>;
  pairSave[saved, path]; ClearSystemCache[]; saved]], "TargetMapFailure"];
pairReconstruct[coefficients_] := Total[KeyValueMap[Function[{integral, coefficient}, coefficient Times @@ MapThread[Power,
  {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], coefficients]];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  gate["pair workers share allocated node", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  gate["pair worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@
    ParallelEvaluate[{$Version, $FeynCalcVersion}])];
  DistributeDefinitions[gate, bounded, targetTimeLimit, targetMemoryLimit, pairSave, pairMap, pairCache,
    zero, merge, decompose, extractAtoms, familyRows, mapExpression, denominators, directions, families, familyNames, geometry]];
$DistributedContexts = None;
pairComponents = {};
Do[
  task = tasks[[index]];
  gate["selected task belongs to inherited sector", task["Sector"] === pairLabel];
  {extractionSeconds, values} = AbsoluteTiming[bounded[pairExpression[#, task] & /@ pairInputs, {index, "pair spin extraction"}]];
  gate["complete accepted component reconstructed from pairs " <> ToString[index],
    bounded[zero[Total[values] - task["Value"]], {index, "original pair sum"}]];
  packets = MapIndexed[Function[{value, position}, <|"Component" -> index, "PairIndex" -> First[position],
    "Value" -> (value /. coordinateRules), "Binding" -> Hash[{pairStudyHash, index, First[position], value}, "SHA256"]|>], values];
  records = If[workers > 0, ParallelMap[pairMap, packets, Method -> "FinestGrained"], pairMap /@ packets];
  gate["all selected pair maps accepted " <> ToString[index], AllTrue[records, AssociationQ] &&
    And @@ Lookup[records, "ReconstructionPassed"] && And @@ Flatten[Values[#["Checks"]] & /@ records]];
  {mergeSeconds, coefficients} = AbsoluteTiming[bounded[merge[Lookup[records, "Coefficients"]], {index, "original map merge"}]];
  reconstruction = pairReconstruct[coefficients];
  gate["complete merged map reconstructs accepted input " <> ToString[index],
    bounded[zero[reconstruction - (task["Value"] /. coordinateRules)], {index, "complete mapped reconstruction"}]];
  gate["merged map preserves both physical cuts " <> ToString[index], And @@
    (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[coefficients])];
  If[index === pairControlIndex, gate["entire own accepted control map reproduced",
    bounded[zero[reconstruction - pairReconstruct[pairOwnControl["Coefficients"]]], "own accepted pair-map control"]]];
  component = Join[KeyDrop[task, "Value"], <|"ComponentIndex" -> index, "Coefficients" -> coefficients,
    "MissingTargets" -> Complement[Keys[coefficients], ruleKeys, reduction["Masters"]], "InputHash" -> targetInputHash,
    "StudyInputHash" -> pairStudyHash, "ReconstructionPassed" -> True, "Checks" -> checks,
    "ExtractionSeconds" -> extractionSeconds, "MergeSeconds" -> mergeSeconds,
    "PairEvidence" -> (KeyDrop[#, {"Coefficients", "Checks"}] & /@ records)|>];
  pairSave[component, FileNameJoin[{pairCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}]];
  AppendTo[pairComponents, component]; Print["REFERENCE_PAIR_COMPONENT_ACCEPTED ", index];
  Clear[values, packets, records, coefficients, reconstruction]; ClearSystemCache[], {index, pairSelected}];
CloseKernels[];
pairResult = <|"Schema" -> "polarized-sidis-pair-mapping-comparison-v1", "Channel" -> channel,
  "Components" -> pairComponents, "ControlIndex" -> pairControlIndex, "SelectedIndices" -> pairSelected,
  "SourceHash" -> FileHash[pairStudyPath, "SHA256"], "ConfigurationHash" -> FileHash[pairConfigPath, "SHA256"],
  "OriginalMapperHash" -> FileHash[originalMapperPath, "SHA256"], "InputHashes" -> inputHashes,
  "TargetInputHash" -> targetInputHash, "MappingInputHash" -> inputHash, "InputHash" -> pairStudyHash,
  "PairFiles" -> pairNames, "PairInputHashes" -> pairConfig["files"], "OriginalMappingDefinitions" -> DownValues[mapExpression],
  "OriginalMergeDefinitions" -> DownValues[merge], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "WorkerCount" -> workers, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
pairResultDir = FileNameJoin[{root, channel, "s08_pair_mapping_result"}];
If[!DirectoryQ[pairResultDir], CreateDirectory[pairResultDir, CreateIntermediateDirectories -> True]];
pairSave[pairResult, FileNameJoin[{pairResultDir, "s08_result.wl"}]];
Export[FileNameJoin[{pairResultDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "component_indices" -> pairSelected, "workers" -> workers, "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_gluon_pair_mapping"]; Quit[0];

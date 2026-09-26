(* Execute the accepted denominator grouping with the unchanged reference mapper. *)
$HistoryLength = 0;
groupProductionPath = FileNameJoin[{Directory[], "common", "s08_map_certified_group_targets.wls"}];
groupBasePath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
groupRequire[name_, test_] := If[!TrueQ[test], Print["FAIL: ", name]; Quit[1]];
groupRequire["reviewed base target mapper", IntegerString[FileHash[groupBasePath, "SHA256"], 16, 64] ===
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9"];
groupBaseText = Import[groupBasePath, "Text"];
groupBoundary = StringPosition[groupBaseText, "\nmapTargetTask[index_]"];
groupRequire["unique base initialization boundary", Length[groupBoundary] === 1];
groupPrefix = StringTake[groupBaseText, First[First[groupBoundary]] - 1];
groupRequire["complete base initialization syntax", SyntaxQ[groupPrefix]];
ToExpression[groupPrefix, InputForm];
gate["complete grouped production source syntax", SyntaxQ[Import[groupProductionPath, "Text"]]];
gate["grouped production owns inspected channel", channel === "Hqqbar"];
groupProofPath = FileNameJoin[{root, "Hqqbar", "s08_grouped_result", "s08_result.wl"}];
groupCheckPath = FileNameJoin[{root, "common", "s08_grouped_mapping_check.wls"}];
gate["pinned complete grouped mapping comparison", IntegerString[FileHash[groupProofPath, "SHA256"], 16, 64] ===
  "fc69dbab36b65068fde2e89a25ae05a4ac4f166a84bdf03dfde712a93aa66ed0"];
groupProof = Get[groupProofPath];
gate["accepted grouped mapping comparison", groupProof["Schema"] === "polarized-sidis-grouped-mapping-comparison-v1" &&
  groupProof["Channel"] === channel && And @@ Values[groupProof["Checks"]] &&
  And @@ Values[groupProof["ControlComparison"]["Checks"]] &&
  And @@ Lookup[groupProof["Components"], "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ groupProof["Components"]]];
gate["grouped comparison exact source and inputs", groupProof["SourceHash"] === FileHash[groupCheckPath, "SHA256"] &&
  groupProof["MapperSourceHash"] === FileHash[groupBasePath, "SHA256"] &&
  groupProof["InputHashes"] === inputHashes && groupProof["MappingInputHash"] === targetInputHash &&
  groupProof["ControlComparison"]["ReferenceHash"] === FileHash[targetFixturePath, "SHA256"]];
gate["unchanged executed original mapping definitions", DownValues[mapExpression] === groupProof["OriginalMappingDefinitions"]];
DownValues[groupDenominators] = groupProof["GroupingDefinitions"];
DownValues[groupedMapExpression] = groupProof["MappingDefinitions"];
gate["exact executed grouping definitions", DownValues[groupDenominators] === groupProof["GroupingDefinitions"] &&
  DownValues[groupedMapExpression] === groupProof["MappingDefinitions"]];
groupCertificatePath = FileNameJoin[{root, channel, "s08_group_certificate_result", "s08_result.wl"}];
groupCertificateSource = FileNameJoin[{root, "common", "s08_check_group_reconstruction.wls"}];
gate["pinned accepted grouping reconstruction certificate", IntegerString[FileHash[groupCertificatePath, "SHA256"], 16, 64] ===
  "b0f6a49846b8b7f770f30ea48bc8d9aa6b4733234eed70d2ac08ed489264be5a"];
groupCertificate = Get[groupCertificatePath];
gate["accepted own grouping certificate and controls", groupCertificate["Schema"] === "polarized-sidis-group-reconstruction-comparison-v1" &&
  groupCertificate["Channel"] === channel && And @@ Values[groupCertificate["Checks"]] &&
  groupCertificate["InputHashes"] === inputHashes && groupCertificate["MappingInputHash"] === targetInputHash &&
  groupCertificate["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  groupCertificate["SourceHash"] === FileHash[groupCertificateSource, "SHA256"] &&
  groupCertificate["GroupingProofHash"] === FileHash[groupProofPath, "SHA256"] &&
  Sort[groupCertificate["ControlComparisons"]] === Sort[Lookup[groupProof["Components"], "ComponentIndex"]] &&
  groupCertificate["OriginalGroupingDefinitions"] === DownValues[groupDenominators]];
DownValues[certifyGrouping] = groupCertificate["CertificateDefinitions"];
DownValues[groupDenominators] = groupCertificate["GroupingDefinitions"];
gate["exact executed certificate installed", DownValues[certifyGrouping] === groupCertificate["CertificateDefinitions"] &&
  DownValues[groupDenominators] === groupCertificate["GroupingDefinitions"] &&
  DownValues[groupedMapExpression] === groupProof["MappingDefinitions"]];
groupCertificateHash = FileHash[groupCertificatePath, "SHA256"];
groupPreviousSource = FileNameJoin[{root, "common", "s08_map_grouped_real_targets.wls"}];
gate["unchanged original production checkpoint contract", IntegerString[FileHash[groupPreviousSource, "SHA256"], 16, 64] ===
  "dbb73551b462cb066e4c06ed11fb10348e520241c0fb8676243ab4d484c712a7"];
groupPreviousTargetHash = targetInputHash;
groupInputHash = Hash[{FileHash[groupCheckPath, "SHA256"], inputHashes, groupPreviousTargetHash,
  $Version, $FeynCalcVersion}, "SHA256"];
gate["exact comparison checkpoint identity", groupInputHash === groupProof["InputHash"]];
groupCache = FileNameJoin[{root, "cache", "s08_grouped_check", channel, IntegerString[groupInputHash, 16]}];
If[!DirectoryQ[groupCache], CreateDirectory[groupCache, CreateIntermediateDirectories -> True]];
groupReferenceCalculationHash = targetCalculationHash;
targetSourceHash = FileHash[groupProductionPath, "SHA256"];
targetCalculationHash = FileHash[groupPreviousSource, "SHA256"];
targetInputHash = Hash[{targetCalculationHash, FileHash[groupProofPath, "SHA256"], groupPreviousTargetHash}, "SHA256"];
targetCache = FileNameJoin[{root, "cache", "s08_grouped_targets", channel, IntegerString[targetInputHash, 16]}];
If[!DirectoryQ[targetCache], CreateDirectory[targetCache, CreateIntermediateDirectories -> True]];
groupProofComponents = Association[(#["ComponentIndex"] -> #) & /@ groupProof["Components"]];
groupProofHash = FileHash[groupProofPath, "SHA256"];
gate["raw-map consumer physical-input identity", inputHash ===
  Hash[{FileHash[targetMapperPath, "SHA256"], inputHashes, $Version, $FeynCalcVersion}, "SHA256"]];

mapTargetTask[index_] := Catch[Block[{checks = <||>}, Module[
  {task, path, saved, prior, coefficients, seconds, missing},
  task = tasks[[index]];
  path = FileNameJoin[{targetCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "InputHash", None] === targetInputHash && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
      AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]], Return[saved]];
  If[KeyExistsQ[groupProofComponents, index],
    prior = groupProofComponents[index];
    gate["accepted grouped component exact task identity", KeyTake[prior, {"Sector", "Kind", "Index"}] === KeyDrop[task, "Value"] &&
      prior["InputHash"] === groupPreviousTargetHash && TrueQ[prior["ReconstructionPassed"]] && And @@ Values[prior["Checks"]]];
    saved = Join[prior, <|"InputHash" -> targetInputHash, "GroupingProofHash" -> groupProofHash,
      "ReusedComparisonComponent" -> True, "Checks" -> Join[prior["Checks"], checks]|>];
    put[saved, path]; Print["GROUPED_TARGET_REUSED ", index]; Return[saved]];
  Print["GROUPED_TARGET_MAP ", index, "/", Length[tasks], " ", KeyDrop[task, "Value"], " kernel ", $KernelID];
  {seconds, coefficients} = AbsoluteTiming[groupedMapExpression[task["Value"] /. coordinateRules,
    "component_" <> ToString[index]]];
  missing = Complement[Keys[coefficients], ruleKeys, reduction["Masters"]];
  saved = Join[KeyDrop[task, "Value"], <|"Coefficients" -> coefficients, "MissingTargets" -> missing,
    "InputHash" -> targetInputHash, "GroupingProofHash" -> groupProofHash, "ReconstructionPassed" -> True,
    "Checks" -> checks, "Seconds" -> seconds, "InputBytes" -> ByteCount[task["Value"]], "OutputBytes" -> ByteCount[coefficients]|>];
  put[saved, path]; ClearSystemCache[]; Print["GROUPED_TARGET_ACCEPTED ", index]; saved]], "TargetMapFailure"];

groupWorkerControl[unused_] := Catch[Block[{checks = <||>}, Module[{value, candidate, reference},
  value = groupedMapExpression[targetControlTask["Value"] /. coordinateRules, "accepted_control"];
  candidate = Total[KeyValueMap[Function[{integral, coefficient}, coefficient Times @@ MapThread[Power,
    {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], value]];
  reference = Total[KeyValueMap[Function[{integral, coefficient}, coefficient Times @@ MapThread[Power,
    {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], targetFixture["Coefficients"]]];
  gate["fresh grouped worker reproduces accepted control expression", bounded[zero[candidate - reference], "grouped worker control"]];
  <|"Checks" -> checks, "ReconstructionPassed" -> True|>]], "TargetMapFailure"];

slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  gate["grouped workers share compute node", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  gate["grouped worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@
    ParallelEvaluate[{$Version, $FeynCalcVersion}])];
  DistributeDefinitions[gate, bounded, targetTimeLimit, targetMemoryLimit, put, zero, merge, decompose, extractAtoms, familyRows,
    mapExpression, certifyGrouping, groupDenominators, groupedMapExpression, groupInputHash, groupCache, groupProofComponents,
    groupPreviousTargetHash, groupProofHash, mapTargetTask, tasks, targetCache, targetInputHash, coordinateRules,
    ruleKeys, reduction, groupWorkerControl, targetControlTask, targetFixture, denominators, directions, families, familyNames, geometry]];
$DistributedContexts = None;
Print["Independent grouped target worker count = ", workers];
groupControl = First[If[workers > 0, ParallelMap[groupWorkerControl, {1}], groupWorkerControl /@ {1}]];
gate["fresh grouped target worker accepted", AssociationQ[groupControl] && And @@ Values[groupControl["Checks"]]];
targetComponents = If[workers > 0, ParallelMap[mapTargetTask, Range[Length[tasks]], Method -> "FinestGrained"],
  mapTargetTask /@ Range[Length[tasks]]];
CloseKernels[];
gate["all real target maps accepted", Length[targetComponents] === Length[tasks] && AllTrue[targetComponents, AssociationQ] &&
  And @@ Lookup[targetComponents, "ReconstructionPassed"] && And @@ Flatten[Values[#["Checks"]] & /@ targetComponents]];
targetInventory = Union[Flatten[Keys[#["Coefficients"]] & /@ targetComponents]];
targetMissing = Union[Flatten[Lookup[targetComponents, "MissingTargets"]]];
targetResult = <|"Schema" -> "polarized-sidis-real-target-map-v1", "Channel" -> channel,
  "Components" -> targetComponents, "Targets" -> targetInventory, "MissingTargets" -> targetMissing,
  "ReductionCoverageComplete" -> (targetMissing === {}), "Bookkeeping" -> bookkeeping,
  "MapperSourceHash" -> FileHash[targetMapperPath, "SHA256"], "SourceHash" -> targetSourceHash,
  "CalculationSourceHash" -> targetCalculationHash, "ReferenceCalculationSourceHash" -> groupReferenceCalculationHash,
  "GroupingProofHash" -> groupProofHash, "GroupingCertificateHash" -> groupCertificateHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "InputHashes" -> inputHashes, "InputHash" -> targetInputHash, "MappingInputHash" -> inputHash,
  "ReferenceTargetMapHash" -> FileHash[targetFixturePath, "SHA256"], "Checks" -> checks,
  "WorkerCount" -> workers, "MappingAccepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
targetDir = FileNameJoin[{root, channel, "s08_targets_result"}];
If[!DirectoryQ[targetDir], CreateDirectory[targetDir, CreateIntermediateDirectories -> True]];
targetResultPath = FileNameJoin[{targetDir, "s08_result.wl"}];
targetSerialized = "Uncompress[" <> ToString[bounded[Compress[targetResult], "target-map compression"], InputForm] <> "]\n";
gate["target-map output below file bound", StringLength[targetSerialized] < 128*1024^2];
Export[targetResultPath <> ".tmp", targetSerialized, "Text"];
gate["target-map output exact native round trip", bounded[Get[targetResultPath <> ".tmp"] === targetResult, "target-map reload"]];
RenameFile[targetResultPath <> ".tmp", targetResultPath, OverwriteTarget -> True];
Export[FileNameJoin[{targetDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "component_count" -> Length[targetComponents], "target_count" -> Length[targetInventory],
  "missing_target_count" -> Length[targetMissing], "workers" -> workers,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_map_certified_group_targets"]; Quit[0];

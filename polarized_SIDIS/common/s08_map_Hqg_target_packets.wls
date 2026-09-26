(* Complete the unchanged reference cut mapping before master-coefficient assembly. *)
$HistoryLength = 0;
packetSourcePath = FileNameJoin[{Directory[], "common", "s08_map_Hqg_target_packets.wls"}];
targetSourcePath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
targetMapperPath = FileNameJoin[{Directory[], "common", "s08_result", "reference", "s08_map_real_spin_before_known_denominator.wls"}];
If[IntegerString[FileHash[targetMapperPath, "SHA256"], 16, 64] =!=
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f", Quit[1]];
targetMapperText = Import[targetMapperPath, "Text"];
targetStop = First[First[StringPosition[targetMapperText, "\ncomponents = {}; targets = {};"]]];
targetPrefix = StringTake[targetMapperText, targetStop - 1];
targetSourceAssignment = "sourcePath = FileNameJoin[{root, \"common\", \"s08_map_real_spin.wls\"}];";
If[StringCount[targetPrefix, targetSourceAssignment] =!= 1, Quit[1]];
targetPrefix = StringReplace[targetPrefix, targetSourceAssignment -> "sourcePath = targetMapperPath;"];
If[!SyntaxQ[targetPrefix], Print["FAIL: complete target-mapping prefix syntax"]; Quit[1]];
ToExpression[targetPrefix, InputForm];
gate["Hqg assigned-component entry", channel === "Hqg"];
gate["complete assigned-component source syntax", SyntaxQ[Import[packetSourcePath, "Text"]]];
gate["complete target mapping source syntax", SyntaxQ[Import[targetSourcePath, "Text"]]];
targetCalculationPath = FileNameJoin[{root, "common", "s08_result", "reference", "s08_map_real_targets_before_channel_resume.wls"}];
targetCalculationHash = FileHash[targetCalculationPath, "SHA256"];
gate["pinned unchanged target calculation", IntegerString[targetCalculationHash, 16, 64] ===
  "eaebc31004da122daa275f4d817ba45e84c8ed5db8e5c0bf40a008289791a1ce"];
targetSection[text_] := StringTake[text, {
  First[First[StringPosition[text, "\nmapTargetTask[index_]"]]],
  First[First[StringPosition[text, "\nslots ="]]] - 1}];
gate["unchanged complete target calculation and checkpoint contract",
  targetSection[Import[packetSourcePath, "Text"]] === targetSection[Import[targetCalculationPath, "Text"]]];
targetConfigPath = FileNameJoin[{root, "common", "s08_rational_sum_inputs.json"}];
targetConfig = Import[targetConfigPath, "RawJSON"];
targetFixturePath = FileNameJoin[{root, targetConfig["raw_map"]}];
gate["pinned actual reference target map", IntegerString[FileHash[targetFixturePath, "SHA256"], 16, 64] === targetConfig["raw_map_sha256"]];
targetFixture = Get[targetFixturePath];
targetControlSpinRelative = "Hqqprime/s05_result/s05_result.wl";
targetControlSpinPath = FileNameJoin[{root, targetControlSpinRelative}];
gate["pinned accepted control tensor", IntegerString[FileHash[targetControlSpinPath, "SHA256"], 16, 64] ===
  "07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f"];
targetControlSpin = If[channel === "Hqqprime", spin, Get[targetControlSpinPath]];
gate["control shares exact measured scalar products", targetControlSpin["RealScalarProducts"] === spin["RealScalarProducts"] &&
  targetControlSpin["TransverseConstraint"] === spin["TransverseConstraint"] && And @@ Values[targetControlSpin["Checks"]]];
targetControlTask = Append[targetFixture["Task"], "Value" -> Extract[
  targetControlSpin["Sectors"][targetFixture["Task"]["Sector"]][targetFixture["Task"]["Kind"]], targetFixture["Task"]["Index"]]];
Clear[targetControlSpin];
targetControlInputs = Association[Map[If[First[#] === StringDrop[spinPath, StringLength[root] + 1],
  targetControlSpinRelative -> FileHash[targetControlSpinPath, "SHA256"], #] &, Normal[inputHashes]]];
targetFixtureHash = Hash[{FileHash[FileNameJoin[{root, targetConfig["raw_profile_source"]}], "SHA256"],
  targetControlInputs, FileHash[FileNameJoin[{root, "common", "s05_result", "reference",
    "s05_real_spin_response_before_parallel_spin_checks.wls"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
gate["reference target map exact input identity", targetFixture["InputHash"] === targetFixtureHash &&
  And @@ Values[targetFixture["MappingChecks"]] && KeyDrop[targetControlTask, "Value"] === targetFixture["Task"]];
targetSourceHash = FileHash[targetSourcePath, "SHA256"];
targetInputHash = Hash[{targetCalculationHash, inputHash, FileHash[targetFixturePath, "SHA256"],
  FileHash[targetConfigPath, "SHA256"]}, "SHA256"];
targetCache = FileNameJoin[{root, "cache", "s08_targets", channel, IntegerString[targetInputHash, 16]}];
If[!DirectoryQ[targetCache], CreateDirectory[targetCache, CreateIntermediateDirectories -> True]];
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "TargetMapFailure"], CloseKernels[]; Quit[1]]];
targetResourceLimit[name_, default_, maximum_] := Module[{value = Environment[name]},
  If[value === $Failed || value === "", Return[default]];
  gate["integer resource limit " <> name, StringQ[value] && StringMatchQ[value, DigitCharacter ..]];
  value = FromDigits[value];
  gate["bounded resource limit " <> name, IntegerQ[value] && 0 < value <= maximum]; value];
targetTimeLimit = targetResourceLimit["POLARIZED_SIDIS_TARGET_SECONDS", 3600, 10800];
targetMemoryLimit = targetResourceLimit["POLARIZED_SIDIS_TARGET_MEMORY_GIB", 2, 8]*1024^3;
Print["TARGET_RESOURCE_LIMITS seconds ", targetTimeLimit, " bytes ", targetMemoryLimit];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, targetTimeLimit,
  gate["time bound " <> ToString[label, InputForm], False]], targetMemoryLimit,
  gate["memory bound " <> ToString[label, InputForm], False]];
mapTargetTask[index_] := Catch[Block[{checks = <||>}, Module[
  {task, path, saved, coefficients, seconds, missing},
  task = tasks[[index]];
  path = FileNameJoin[{targetCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "InputHash", None] === targetInputHash && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]], Return[saved]];
  Print["REAL_TARGET_MAP ", index, "/", Length[tasks], " ", KeyDrop[task, "Value"], " kernel ", $KernelID];
  {seconds, coefficients} = AbsoluteTiming[bounded[mapExpression[task["Value"] /. coordinateRules],
    {"complete raw cut mapping", index}]];
  missing = Complement[Keys[coefficients], ruleKeys, reduction["Masters"]];
  saved = Join[KeyDrop[task, "Value"], <|"Coefficients" -> coefficients, "MissingTargets" -> missing,
    "InputHash" -> targetInputHash, "ReconstructionPassed" -> True, "Checks" -> checks,
    "Seconds" -> seconds, "InputBytes" -> ByteCount[task["Value"]], "OutputBytes" -> ByteCount[coefficients]|>];
  put[saved, path]; ClearSystemCache[]; saved]], "TargetMapFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
(* Preserve the native mapper; change only the data held by each worker. *)
packetInputFootprint = <|"TaskBytesBefore" -> ByteCount[tasks], "SpinBytesBefore" -> ByteCount[spin],
  "MemoryBefore" -> MemoryInUse[]|>;
packetMetadata = KeyDrop[#, "Value"] & /@ tasks;
packetPositions = Select[Range[Length[tasks]], tasks[[#]]["Value"] =!= 0 &];
gate["own nonzero target-map comparison available", packetPositions =!= {}];
packetControlIndex = First[MinimalBy[packetPositions, ByteCount[tasks[[#]]["Value"]] &]];
packetOriginal = mapTargetTask[packetControlIndex];
gate["own original target-map comparison accepted", AssociationQ[packetOriginal] &&
  TrueQ[packetOriginal["ReconstructionPassed"]] && And @@ Values[packetOriginal["Checks"]]];
packetInputs = MapIndexed[{First[#2], #1, Hash[#1, "SHA256"]} &, tasks];
gate["assigned tasks retain original order and values", Map[#[[2]] &, packetInputs] === tasks &&
  Map[First, packetInputs] === Range[Length[tasks]]];
packetControlCache = FileNameJoin[{root, "cache", "s08_target_packets", channel,
  IntegerString[Hash[{targetInputHash, FileHash[packetSourcePath, "SHA256"]}, "SHA256"], 16]}];
If[!DirectoryQ[packetControlCache], CreateDirectory[packetControlCache, CreateIntermediateDirectories -> True]];
mapTargetPacket[packet_] := Catch[Module[{index = packet[[1]], assigned = packet[[2]]},
  gate["assigned original component exact identity", Hash[assigned, "SHA256"] === packet[[3]] &&
    KeyDrop[assigned, "Value"] === tasks[[index]]];
  Block[{tasks = ReplacePart[tasks, index -> assigned]}, mapTargetTask[index]]], "TargetMapFailure"];
packetControlFunction[packet_] := Block[{targetCache = packetControlCache}, mapTargetPacket[packet]];
tasks = packetMetadata;
Clear[spin, sector, packetMetadata]; ClearSystemCache[];
AssociateTo[packetInputFootprint, {"TaskBytesAfter" -> ByteCount[tasks],
  "LargestAssignedTaskBytes" -> Max[ByteCount[#[[2]]] & /@ packetInputs], "MemoryAfter" -> MemoryInUse[]}];
Print["S08_TARGET_PACKET_INPUTS ", InputForm[packetInputFootprint]];
targetControlTaskFunction[unused_] := Catch[Block[{checks = <||>}, Module[{value, seconds},
  {seconds, value} = AbsoluteTiming[bounded[mapExpression[targetControlTask["Value"] /. coordinateRules], "reference control mapping"]];
  gate["fresh worker reproduces entire reference map", value === targetFixture["Coefficients"]];
  <|"Checks" -> checks, "Seconds" -> seconds, "ReconstructionPassed" -> True|>]], "TargetMapFailure"];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  gate["target workers share compute node", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>;
    PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]; $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  gate["target worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@
    ParallelEvaluate[{$Version, $FeynCalcVersion}])];
  packetDistributionStart = AbsoluteTime[];
  DistributeDefinitions[mapTargetPacket, packetControlFunction, packetControlCache,
    gate, bounded, targetTimeLimit, targetMemoryLimit, put, zero, merge, decompose, extractAtoms, familyRows, mapExpression,
    mapTargetTask, tasks, targetCache, targetInputHash, coordinateRules, ruleKeys, reduction,
    targetControlTaskFunction, targetControlTask, targetFixture,
    denominators, directions, families, familyNames, geometry];
  packetDistributionSeconds = AbsoluteTime[] - packetDistributionStart;
  Print["S08_TARGET_PACKET_DISTRIBUTION_SECONDS ", packetDistributionSeconds]];
$DistributedContexts = None;
Print["Independent target worker count = ", workers];
targetControlFunction = If[channel === "Hqqprime", mapTargetTask, targetControlTaskFunction];
targetControl = First[If[workers > 0, ParallelMap[targetControlFunction, {1}], targetControlFunction /@ {1}]];
gate["fresh target worker accepted", AssociationQ[targetControl] && And @@ Values[targetControl["Checks"]]];
If[channel === "Hqqprime", gate["entire original target map unchanged", targetControl["Coefficients"] === targetFixture["Coefficients"]]];
packetCandidate = First[If[workers > 0,
  ParallelMap[packetControlFunction, {packetInputs[[packetControlIndex]]}],
  {packetControlFunction[packetInputs[[packetControlIndex]]]}]];
gate["own assigned-component target checks accepted", AssociationQ[packetCandidate] &&
  TrueQ[packetCandidate["ReconstructionPassed"]] && And @@ Values[packetCandidate["Checks"]]];
gate["own complete mapped coefficient unchanged", KeyDrop[packetCandidate, {"Seconds", "Checks"}] === KeyDrop[packetOriginal, {"Seconds", "Checks"}]];
packetComparison = <|"ControlIndex" -> packetControlIndex, "AssignedInputHash" -> packetInputs[[packetControlIndex, 3]],
  "OriginalOutputHash" -> Hash[KeyDrop[packetOriginal, {"Seconds", "Checks"}], "SHA256"],
  "CandidateOutputHash" -> Hash[KeyDrop[packetCandidate, {"Seconds", "Checks"}], "SHA256"],
  "OriginalChecks" -> packetOriginal["Checks"], "CandidateChecks" -> packetCandidate["Checks"],
  "OriginalSeconds" -> packetOriginal["Seconds"], "CandidateSeconds" -> packetCandidate["Seconds"],
  "ExactOwnComparisonPassed" -> True, "InputHash" -> targetInputHash,
  "SourceHash" -> FileHash[packetSourcePath, "SHA256"], "NativeVersions" -> {$Version, $FeynCalcVersion}|>;
Print["S08_TARGET_PACKET_COMPARISON ", InputForm[packetComparison]];
targetRest = Range[If[channel === "Hqqprime", 2, 1], Length[tasks]];
targetComponents = If[workers > 0,
  ParallelMap[mapTargetPacket, packetInputs[[targetRest]], Method -> "FinestGrained"], mapTargetPacket /@ packetInputs[[targetRest]]];
If[channel === "Hqqprime", targetComponents = Prepend[targetComponents, targetControl]];
CloseKernels[];
gate["all real target maps accepted", Length[targetComponents] === Length[tasks] &&
  AllTrue[targetComponents, AssociationQ] && And @@ Lookup[targetComponents, "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ targetComponents]];
targetInventory = Union[Flatten[Keys[#["Coefficients"]] & /@ targetComponents]];
targetMissing = Union[Flatten[Lookup[targetComponents, "MissingTargets"]]];
targetResult = <|"Schema" -> "polarized-sidis-real-target-map-v1", "Channel" -> channel,
  "Components" -> targetComponents, "Targets" -> targetInventory, "MissingTargets" -> targetMissing,
  "ReductionCoverageComplete" -> (targetMissing === {}), "Bookkeeping" -> bookkeeping,
  "MapperSourceHash" -> FileHash[targetMapperPath, "SHA256"], "SourceHash" -> targetSourceHash,
  "CalculationSourceHash" -> targetCalculationHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "DispatchSourceHash" -> FileHash[packetSourcePath, "SHA256"], "AssignedComponentComparison" -> packetComparison,
  "AssignedComponentFootprint" -> packetInputFootprint,
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
Print["PASS: s08_map_real_targets"]; Quit[0];

(* Complete the unchanged reference cut mapping before master-coefficient assembly. *)
$HistoryLength = 0;
targetSourcePath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
targetMapperPath = FileNameJoin[{Directory[], "common", "s08_map_real_spin.wls"}];
If[IntegerString[FileHash[targetMapperPath, "SHA256"], 16, 64] =!=
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f", Quit[1]];
targetMapperText = Import[targetMapperPath, "Text"];
targetStop = First[First[StringPosition[targetMapperText, "\ncomponents = {}; targets = {};"]]];
targetPrefix = StringTake[targetMapperText, targetStop - 1];
If[!SyntaxQ[targetPrefix], Print["FAIL: complete target-mapping prefix syntax"]; Quit[1]];
ToExpression[targetPrefix, InputForm];
gate["complete target mapping source syntax", SyntaxQ[Import[targetSourcePath, "Text"]]];
gate["initial target-mapping comparison channel", channel === "Hqqprime"];
targetConfigPath = FileNameJoin[{root, "common", "s08_rational_sum_inputs.json"}];
targetConfig = Import[targetConfigPath, "RawJSON"];
targetFixturePath = FileNameJoin[{root, targetConfig["raw_map"]}];
gate["pinned actual reference target map", IntegerString[FileHash[targetFixturePath, "SHA256"], 16, 64] === targetConfig["raw_map_sha256"]];
targetFixture = Get[targetFixturePath];
targetFixtureHash = Hash[{FileHash[FileNameJoin[{root, targetConfig["raw_profile_source"]}], "SHA256"],
  inputHashes, FileHash[FileNameJoin[{root, "common", "s05_result", "reference",
    "s05_real_spin_response_before_parallel_spin_checks.wls"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
gate["reference target map exact input identity", targetFixture["InputHash"] === targetFixtureHash &&
  And @@ Values[targetFixture["MappingChecks"]] && KeyDrop[First[tasks], "Value"] === targetFixture["Task"]];
targetSourceHash = FileHash[targetSourcePath, "SHA256"];
targetInputHash = Hash[{targetSourceHash, inputHash, FileHash[targetFixturePath, "SHA256"],
  FileHash[targetConfigPath, "SHA256"]}, "SHA256"];
targetCache = FileNameJoin[{root, "cache", "s08_targets", channel, IntegerString[targetInputHash, 16]}];
If[!DirectoryQ[targetCache], CreateDirectory[targetCache, CreateIntermediateDirectories -> True]];
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "TargetMapFailure"], CloseKernels[]; Quit[1]]];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate["time bound " <> ToString[label, InputForm], False]], 2*1024^3,
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
  DistributeDefinitions[gate, bounded, put, zero, merge, decompose, extractAtoms, familyRows, mapExpression,
    mapTargetTask, tasks, targetCache, targetInputHash, coordinateRules, ruleKeys, reduction,
    denominators, directions, families, familyNames, geometry]];
$DistributedContexts = None;
Print["Independent target worker count = ", workers];
targetControl = First[If[workers > 0, ParallelMap[mapTargetTask, {1}], mapTargetTask /@ {1}]];
gate["fresh target worker accepted", AssociationQ[targetControl] && And @@ Values[targetControl["Checks"]]];
gate["entire original target map unchanged", targetControl["Coefficients"] === targetFixture["Coefficients"]];
targetRest = Range[2, Length[tasks]];
targetComponents = Prepend[If[workers > 0,
  ParallelMap[mapTargetTask, targetRest, Method -> "FinestGrained"], mapTargetTask /@ targetRest], targetControl];
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
  "InputHashes" -> inputHashes, "InputHash" -> targetInputHash, "MappingInputHash" -> inputHash,
  "ReferenceTargetMapHash" -> FileHash[targetFixturePath, "SHA256"], "Checks" -> checks,
  "WorkerCount" -> workers, "MappingAccepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
targetDir = FileNameJoin[{root, channel, "s08_targets_result"}];
If[!DirectoryQ[targetDir], CreateDirectory[targetDir, CreateIntermediateDirectories -> True]];
put[targetResult, FileNameJoin[{targetDir, "s08_result.wl"}]];
Export[FileNameJoin[{targetDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "component_count" -> Length[targetComponents], "target_count" -> Length[targetInventory],
  "missing_target_count" -> Length[targetMissing], "workers" -> workers,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_map_real_targets"]; Quit[0];

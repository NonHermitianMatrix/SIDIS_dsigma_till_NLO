(* Finish a complete native export interrupted by the shared storage guard. *)
$HistoryLength = 0;
resumeSource = FileNameJoin[{Directory[], "common", "s05_resume_Hgg_component_export.wls"}];
resumeBase = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_component_sum.wls"}];
If[IntegerString[FileHash[resumeBase, "SHA256"], 16, 64] =!=
  "67f4b5daf66d9ef7a7413eff9d64f61adcec1776a1d2679937355f797dae781f" ||
  !SyntaxQ[Import[resumeSource, "Text"]], Quit[1]];
resumeText = StringTrim[Import[resumeBase, "Text"]];
resumeTerminal = "ToExpression[assemblyRunTail, InputForm];";
If[!StringEndsQ[resumeText, resumeTerminal], Quit[1]];
ToExpression[StringDrop[resumeText, -StringLength[resumeTerminal]], InputForm];
assembleCompletedPairs[] := Module[{key, temporary, previousPath, previous, packet, path,
  expectedPaths, actualPaths, report, started = AbsoluteTime[], packetHash},
  gate["native complete export recovery setup", channel === "Hgg" && workerCount === 0 && !validationOnly];
  key = Environment["POLARIZED_SIDIS_SUM_KEY"];
  temporary = FileNameJoin[{root, Environment["POLARIZED_SIDIS_COMPLETE_EXPORT"]}];
  previousPath = FileNameJoin[{root, Environment["POLARIZED_SIDIS_PREVIOUS_RECEIPT"]}];
  previous = Import[previousPath, "RawJSON"];
  gate["origin stopped only at storage guard", previous["passed"] === False && previous["reason"] === "scratch_limit" &&
    previous["reviewed_sha256"]["common/s05_assemble_Hgg_component_sum.wls"] ===
      IntegerString[FileHash[resumeBase, "SHA256"], 16, 64] &&
    previous["reviewed_sha256"]["common/s05_Hgg_completed_pair_inputs.json"] ===
      IntegerString[FileHash[assemblyManifestPath, "SHA256"], 16, 64]];
  packetHash = FileHash[temporary, "SHA256"];
  Clear[componentPacket, componentProof]; ClearSystemCache[];
  packet = bounded[Get[temporary], "complete native temporary reader"];
  gate["complete original native component checkpoint", AssociationQ[packet] &&
    packet["Schema"] === "polarized-sidis-complete-component-sum-v1" && packet["Channel"] === channel &&
    packet["Key"] === key && packet["InputHash"] === inputHash && packet["InputHashes"] === inputHashes &&
    packet["SourceHash"] === FileHash[resumeBase, "SHA256"] && packet["ManifestHash"] === FileHash[assemblyManifestPath, "SHA256"] &&
    packet["NativeVersions"] === {$Version, $FeynCalcVersion} &&
    packet["ParentFiles"] === assemblyManifest["pairs"] &&
    packet["ParentSumInputHash"] === Hash[{inputHash, label, key, assemblyManifest["pairs"]}, "SHA256"] &&
    packet["OriginalLinearSumDefinitions"] === DownValues[linearComponentSum] &&
    AssociationQ[packet["Checks"]] && Length[packet["Checks"]] > 0 && And @@ Values[packet["Checks"]]];
  expectedPaths = (StringDrop[FileNameJoin[{cache, label <> "_" <> ToString[First[#]] <>
    "_" <> ToString[Last[#]] <> ".wl"}], StringLength[root] + 1] &) /@ pairs;
  actualPaths = Lookup[assemblyManifest["pairs"], "file"];
  gate["complete original generated parent inventory", Sort[actualPaths] === Sort[expectedPaths] &&
    DuplicateFreeQ[actualPaths] && Length[packet["PairMetadata"]] === Length[pairs] &&
    AllTrue[packet["PairMetadata"], AssociationQ] &&
    And @@ Flatten[Values[#["Checks"]] & /@ packet["PairMetadata"]]];
  Do[gate["unchanged complete parent " <> row["file"], IntegerString[
    FileHash[FileNameJoin[{root, row["file"]}], "SHA256"], 16, 64] === row["sha256"]], {row, assemblyManifest["pairs"]}];
  gate["completed original sum reached export", MemberQ[packet["CompleteKeys"], key] &&
    TrueQ[packet["Checks"]["complete original component inputs"]] && KeyExistsQ[packet, "Value"]];
  path = FileNameJoin[{root, channel, "s05_component_sums_result", key, "s05_result.wl"}];
  put[packet, path];
  report = <|"channel" -> channel, "key" -> key, "all_component_keys" -> packet["CompleteKeys"],
    "checks" -> Join[packet["Checks"], checks], "source_sha256" -> IntegerString[FileHash[resumeBase, "SHA256"], 16, 64],
    "recovery_source_sha256" -> IntegerString[FileHash[resumeSource, "SHA256"], 16, 64],
    "manifest_sha256" -> IntegerString[FileHash[assemblyManifestPath, "SHA256"], 16, 64],
    "input_hash" -> IntegerString[inputHash, 16, 64], "native_versions" -> {$Version, $FeynCalcVersion},
    "recovered_complete_native_export" -> True, "original_job_id" -> previous["job_id"],
    "temporary_sha256" -> IntegerString[packetHash, 16, 64], "exact_native_storage_comparison" -> True,
    "sum_seconds" -> packet["SumSeconds"], "elapsed_seconds" -> AbsoluteTime[] - started,
    "peak_kernel_memory_bytes" -> MaxMemoryUsed[], "finite_nlo_fhats_computed" -> False|>;
  Export[FileNameJoin[{DirectoryName[path], "s05_checks.json"}], report, "RawJSON"];
  Print["PASS: s05_resume_Hgg_component_export"]; Quit[0]];
ToExpression[assemblyRunTail, InputForm];

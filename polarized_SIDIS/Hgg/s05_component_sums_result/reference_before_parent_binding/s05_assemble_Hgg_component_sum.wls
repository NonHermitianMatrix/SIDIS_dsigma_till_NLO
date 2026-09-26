(* Assemble one complete saved projection without retaining the other tensors. *)
$HistoryLength = 0;
componentSumPath = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_component_sum.wls"}];
componentSumBase = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_completed_pairs.wls"}];
If[IntegerString[FileHash[componentSumBase, "SHA256"], 16, 64] =!=
  "849cbecf55c4b8f9e0a6765e1c4396ae12b5beb67500fcd043d3bf57d21e71f8", Quit[1]];
componentSumBaseText = StringTrim[Import[componentSumBase, "Text"]];
componentSumTerminal = "ToExpression[assemblyRunTail, InputForm];";
If[!StringEndsQ[componentSumBaseText, componentSumTerminal] ||
  !SyntaxQ[Import[componentSumPath, "Text"]], Quit[1]];
componentSumBootstrap = StringDrop[componentSumBaseText, -StringLength[componentSumTerminal]];
If[!SyntaxQ[componentSumBootstrap], Quit[1]];
ToExpression[componentSumBootstrap, InputForm];
assembleCompletedPairs[] := Module[{key, paths, expectedPaths, values = {}, record, value,
  indices, scalarKeys, keys, metadata = {}, binding, control, controlPath, controlChecks,
  controlReceipt, controlRelative, output, result, seconds, report, started = AbsoluteTime[]},
  gate["serial bounded component assembly", channel === "Hgg" && workerCount === 0 && !validationOnly];
  key = Environment["POLARIZED_SIDIS_SUM_KEY"];
  gate["requested component key", StringQ[key] && StringMatchQ[key, (LetterCharacter | DigitCharacter | "_") ..]];
  paths = Lookup[assemblyManifest["pairs"], "file"];
  expectedPaths = (StringDrop[FileNameJoin[{cache, label <> "_" <> ToString[First[#]] <>
    "_" <> ToString[Last[#]] <> ".wl"}], StringLength[root] + 1] &) /@ pairs;
  gate["same complete generated pair inventory", Sort[paths] === Sort[expectedPaths] && DuplicateFreeQ[paths]];
  Do[gate["pinned completed pair " <> row["file"], IntegerString[FileHash[
    FileNameJoin[{root, row["file"]}], "SHA256"], 16, 64] === row["sha256"]], {row, assemblyManifest["pairs"]}];
  controlRelative = channel <> "/s05_component_sums_result/Photon_1_1/";
  If[key =!= "Photon_1_1",
    controlReceipt = Import[FileNameJoin[{root, controlRelative, "s05_execution.json"}], "RawJSON"];
    controlChecks = Import[FileNameJoin[{root, controlRelative, "s05_checks.json"}], "RawJSON"];
    gate["accepted own complete component control", TrueQ[controlReceipt["passed"]] &&
      controlReceipt["result_sha256"][controlRelative <> "s05_checks.json"] === IntegerString[
        FileHash[FileNameJoin[{root, controlRelative, "s05_checks.json"}], "SHA256"], 16, 64] &&
      TrueQ[controlChecks["exact_own_accepted_sum_comparison"]] &&
      controlChecks["source_sha256"] === IntegerString[FileHash[componentSumPath, "SHA256"], 16, 64] &&
      controlChecks["manifest_sha256"] === IntegerString[FileHash[assemblyManifestPath, "SHA256"], 16, 64] &&
      controlChecks["input_hash"] === IntegerString[inputHash, 16, 64] &&
      controlChecks["native_versions"] === {$Version, $FeynCalcVersion}]];
  Clear[componentPacket, componentProof]; ClearSystemCache[];
  Do[
    Print["COMPONENT_PAIR_READ ", key, " ", pair, " memory ", MemoryInUse[]];
    record = bounded[pairTask[pair], {key, pair, "accepted pair reader"}];
    gate["accepted complete parent and conventions", AssociationQ[record] && record["InputHash"] === inputHash &&
      record["SectorWardComparisonHash"] === wardProofHash && And @@ Values[record["Checks"]] &&
      Dimensions[record["PhotonMatrix"]] === {Length[photonSymbols], Length[photonSymbols]}];
    If[metadata === {},
      scalarKeys = DeleteCases[Keys[record["ScalarModes"]], "PhotonWard"];
      keys = Join[Flatten[Table["Photon_" <> ToString[a] <> "_" <> ToString[b],
        {a, Length[photonSymbols]}, {b, Length[photonSymbols]}]], ("Scalar_" <> # &) /@ scalarKeys];
      gate["requested component belongs to generated inventory", MemberQ[keys, key]]];
    gate["common saved scalar inventory", DeleteCases[Keys[record["ScalarModes"]], "PhotonWard"] === scalarKeys];
    value = If[StringStartsQ[key, "Photon_"],
      indices = FromDigits /@ Rest[StringSplit[key, "_"]]; Extract[record["PhotonMatrix"], indices],
      record["ScalarModes"][StringDrop[key, StringLength["Scalar_"]]]];
    AppendTo[values, value]; AppendTo[metadata, KeyDrop[record, {"PhotonMatrix", "ScalarModes"}]];
    Clear[value, record]; ClearSystemCache[], {pair, pairs}];
  gate["complete original component inputs", Length[values] === Length[pairs] && AllTrue[metadata, AssociationQ]];
  Print["COMPONENT_SUM_BINDING ", key, " input_bytes ", ByteCount[values], " memory ", MemoryInUse[]];
  binding = bounded[Hash[{inputHash, label, key, values}, "SHA256"], {key, "original sum binding"}];
  {seconds, value} = AbsoluteTiming[bounded[linearComponentSum[<|"Key" -> key, "Values" -> values|>], {key, "original linear sum"}]];
  If[key === "Photon_1_1",
    controlPath = FileNameJoin[{root, assemblyManifest["sum_control"]["file"]}];
    gate["pinned original complete sum", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] === assemblyManifest["sum_control"]["sha256"]];
    control = bounded[Get[controlPath], "original complete sum reader"];
    gate["entire own accepted sum exactly reproduced", control["InputHash"] === inputHash &&
      control["Key"] === key && control["SumInputHash"] === binding && And @@ Values[control["Checks"]] &&
      value === control["Value"]]; Clear[control]];
  Clear[values]; ClearSystemCache[];
  output = FileNameJoin[{root, channel, "s05_component_sums_result", key}];
  If[!DirectoryQ[output], CreateDirectory[output, CreateIntermediateDirectories -> True]];
  result = <|"Schema" -> "polarized-sidis-complete-component-sum-v1", "Channel" -> channel,
    "InputHash" -> inputHash, "InputHashes" -> inputHashes, "SumInputHash" -> binding, "Key" -> key,
    "Value" -> value, "PairMetadata" -> metadata, "CompleteKeys" -> keys,
    "SourceHash" -> FileHash[componentSumPath, "SHA256"], "ManifestHash" -> FileHash[assemblyManifestPath, "SHA256"],
    "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks,
    "OriginalLinearSumDefinitions" -> DownValues[linearComponentSum], "SumSeconds" -> seconds,
    "ElapsedSeconds" -> AbsoluteTime[] - started, "PeakKernelMemoryBytes" -> MaxMemoryUsed[],
    "FiniteNLOFHatsComputed" -> False|>;
  put[result, FileNameJoin[{output, "s05_result.wl"}]];
  report = <|"channel" -> channel, "key" -> key, "all_component_keys" -> keys, "checks" -> checks,
    "source_sha256" -> IntegerString[FileHash[componentSumPath, "SHA256"], 16, 64],
    "manifest_sha256" -> IntegerString[FileHash[assemblyManifestPath, "SHA256"], 16, 64],
    "input_hash" -> IntegerString[inputHash, 16, 64], "native_versions" -> {$Version, $FeynCalcVersion},
    "exact_own_accepted_sum_comparison" -> True, "sum_seconds" -> seconds,
    "elapsed_seconds" -> AbsoluteTime[] - started, "peak_kernel_memory_bytes" -> MaxMemoryUsed[],
    "finite_nlo_fhats_computed" -> False|>;
  Export[FileNameJoin[{output, "s05_checks.json"}], report, "RawJSON"];
  Print["PASS: s05_assemble_Hgg_component_sum"]; Quit[0]];
gate["unchanged original assembly caller", StringCount[assemblyRunTail, "assembleCompletedPairs[];"] === 1];
ToExpression[assemblyRunTail, InputForm];

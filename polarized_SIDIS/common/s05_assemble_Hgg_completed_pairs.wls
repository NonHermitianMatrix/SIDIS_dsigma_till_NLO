(* Assemble completed native pairs once; retain the original tensor acceptance gates. *)
$HistoryLength = 0;
assemblyDispatchPath = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_completed_pairs.wls"}];
assemblyBasePath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hgg_components.wls"}];
If[IntegerString[FileHash[assemblyBasePath, "SHA256"], 16, 64] =!=
  "000061ea5ba381c3dd6be3d21ec2a613e6dd56c555fe8ec6d414717595abd9a7", Quit[1]];
assemblyBaseText = StringTrim[Import[assemblyBasePath, "Text"]];
assemblyTerminal = "ToExpression[componentRunTail,InputForm];";
If[!StringEndsQ[assemblyBaseText, assemblyTerminal] || !SyntaxQ[assemblyBaseText] ||
  !SyntaxQ[Import[assemblyDispatchPath, "Text"]], Quit[1]];
assemblyBootstrap = StringDrop[assemblyBaseText, -StringLength[assemblyTerminal]];
If[!SyntaxQ[assemblyBootstrap], Quit[1]];
ToExpression[assemblyBootstrap, InputForm];
assemblyManifestPath = FileNameJoin[{Directory[], "common", "s05_Hgg_completed_pair_inputs.json"}];
assemblyManifest = Import[assemblyManifestPath, "RawJSON"];
gate["completed-pair assembly manifest", assemblyManifest["schema"] ===
  "polarized-sidis-completed-pair-assembly-inputs-v1" && assemblyManifest["channel"] === "Hgg"];

assembleCompletedPairs[] := Module[
  {paths, expectedPaths, record, scalarValues, controlValues = {}, control, controlBinding,
   sumPaths, sumKeys, sumRecords, key, value, binding, saved, checkpointDirectory,
   start = AbsoluteTime[], before, released, timings = {}, evidence, proofDirectory, proofPath},
  gate["serial completed-pair assembly", channel === "Hgg" && workerCount === 0 && !validationOnly];
  paths = Lookup[assemblyManifest["pairs"], "file"];
  expectedPaths = (StringDrop[FileNameJoin[{cache, label <> "_" <> ToString[First[#]] <>
    "_" <> ToString[Last[#]] <> ".wl"}], StringLength[root] + 1] &) /@ pairs;
  gate["complete generated pair inventory pinned", Sort[paths] === Sort[expectedPaths] && DuplicateFreeQ[paths]];
  Do[gate["completed pair file " <> row["file"], IntegerString[
    FileHash[FileNameJoin[{root, row["file"]}], "SHA256"], 16, 64] === row["sha256"]],
    {row, assemblyManifest["pairs"]}];
  gate["own native assembled control pinned", IntegerString[FileHash[
    FileNameJoin[{root, assemblyManifest["sum_control"]["file"]}], "SHA256"], 16, 64] ===
    assemblyManifest["sum_control"]["sha256"]];
  proofDirectory = FileNameJoin[{root, channel, "s05_completed_assembly_result"}];
  proofPath = FileNameJoin[{proofDirectory, "s05_result.wl"}];
  If[FileExistsQ[proofPath],
    evidence = Get[proofPath];
    If[AssociationQ[evidence] && evidence["SourceHash"] === FileHash[assemblyDispatchPath, "SHA256"] &&
      evidence["InputManifestHash"] === FileHash[assemblyManifestPath, "SHA256"],
      gate["accepted own completed assembly checkpoint", evidence["InputHash"] === inputHash &&
        evidence["InputHashes"] === inputHashes && evidence["NativeVersions"] === {$Version, $FeynCalcVersion} &&
        TrueQ[evidence["ExactOwnAcceptedSumComparison"]] && TrueQ[evidence["Accepted"]] &&
        evidence["ControlHash"] === FileHash[FileNameJoin[{root, assemblyManifest["sum_control"]["file"]}], "SHA256"] &&
        AssociationQ[evidence["Checks"]] && And @@ Values[evidence["Checks"]]];
      scalarKeys = evidence["ScalarKeys"]; scalarValues = <||>;
      matrix = ConstantArray[0, {Length[photonSymbols], Length[photonSymbols]}];
      Do[
        gate["own sum checkpoint file " <> row["Key"], FileHash[FileNameJoin[{root, row["File"]}], "SHA256"] === row["FileHash"]];
        saved = bounded[Get[FileNameJoin[{root, row["File"]}]], {"saved assembly reader", row["Key"]}];
        gate["own sum checkpoint binding", saved["InputHash"] === inputHash && saved["Key"] === row["Key"] &&
          saved["CompletedPairSumInputHash"] === row["CompletedPairSumInputHash"] && And @@ Values[saved["Checks"]]];
        If[StringStartsQ[row["Key"], "Photon_"],
          matrix = ReplacePart[matrix, (FromDigits /@ Rest[StringSplit[row["Key"], "_"]]) -> saved["Value"]],
          AssociateTo[scalarValues, StringDrop[row["Key"], StringLength["Scalar_"]] -> saved["Value"]]];
        Clear[saved]; ClearSystemCache[]; Share[], {row, evidence["SumFiles"]}];
      gate["complete saved assembly scalar inventory", Keys[scalarValues] === scalarKeys];
      scalarModes = Join[scalarValues, <|"PhotonWard" -> wardProof["ScalarValue"]|>];
      pairValues = evidence["PairMetadata"]; sumEvidence = evidence["SumFiles"];
      completedPairAssemblyEvidence = evidence;
      Print["REUSED_COMPLETE_PAIR_ASSEMBLY memory ", MemoryInUse[]]; Return[]]];
  (* The contraction installers have consumed these packets; their file identities remain bound. *)
  Clear[componentPacket, componentProof]; ClearSystemCache[]; Share[];
  pairValues = {}; matrix = ConstantArray[0, {Length[photonSymbols], Length[photonSymbols]}];
  scalarValues = <||>;
  Do[
    Print["COMPLETED_PAIR_ASSEMBLY ", pair, " memory ", MemoryInUse[]];
    record = bounded[pairTask[pair], {label, pair, "completed pair reader"}];
    gate["accepted completed pair input and checks", AssociationQ[record] &&
      record["InputHash"] === inputHash && record["SectorWardComparisonHash"] === wardProofHash &&
      AssociationQ[record["Checks"]] && And @@ Values[record["Checks"]] &&
      Dimensions[record["PhotonMatrix"]] === Dimensions[matrix]];
    before = MemoryInUse[]; released = Share[];
    AssociateTo[record, "ScalarModes" -> KeyDrop[record["ScalarModes"], "PhotonWard"]];
    If[pairValues === {}, scalarKeys = Keys[record["ScalarModes"]];
      scalarValues = AssociationThread[scalarKeys, ConstantArray[0, Length[scalarKeys]]]];
    gate["common completed-pair scalar inventory", Keys[record["ScalarModes"]] === scalarKeys];
    AppendTo[controlValues, record["PhotonMatrix"][[1, 1]]];
    matrix = MapThread[Plus, {matrix, record["PhotonMatrix"]}, 2];
    scalarValues = Association@Table[key -> (scalarValues[key] + record["ScalarModes"][key]), {key, scalarKeys}];
    AppendTo[pairValues, KeyDrop[record, {"PhotonMatrix", "ScalarModes"}]];
    Clear[record]; ClearSystemCache[]; Share[];
    AppendTo[timings, <|"Pair" -> pair, "MemoryBeforeSharing" -> before,
      "SharedBytesReleased" -> released, "MemoryAfterAssembly" -> MemoryInUse[],
      "ElapsedSeconds" -> AbsoluteTime[] - start|>];
    Print["COMPLETED_PAIR_ASSEMBLED ", InputForm[Last[timings]]], {pair, pairs}];
  gate[label <> " all diagram pairs complete", Length[pairValues] === Length[pairs] && AllTrue[pairValues, AssociationQ]];
  gate[label <> " all pair checks accepted", And @@ Flatten[Values[#["Checks"]] & /@ pairValues]];
  gate["all pairs share complete-sector proof", AllTrue[pairValues, #["SectorWardComparisonHash"] === wardProofHash &]];
  controlBinding = bounded[Hash[{inputHash, label, "Photon_1_1", controlValues}, "SHA256"], "own original sum binding"];
  control = bounded[Get[FileNameJoin[{root, assemblyManifest["sum_control"]["file"]}]], "own accepted sum reader"];
  Share[];
  gate["own original assembled sum identity", control["InputHash"] === inputHash &&
    control["Key"] === "Photon_1_1" && control["SumInputHash"] === controlBinding &&
    AssociationQ[control["Checks"]] && And @@ Values[control["Checks"]]];
  gate["entire own accepted sum exactly reproduced", matrix[[1, 1]] === control["Value"] &&
    linearComponentSum[<|"Key" -> "Photon_1_1", "Values" -> controlValues|>] === control["Value"]];
  evidence = <|"SourceHash" -> FileHash[assemblyDispatchPath, "SHA256"],
    "InputManifestHash" -> FileHash[assemblyManifestPath, "SHA256"],
    "InputHash" -> inputHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
    "ControlHash" -> FileHash[FileNameJoin[{root, assemblyManifest["sum_control"]["file"]}], "SHA256"],
    "ControlSumInputHash" -> controlBinding, "ExactOwnAcceptedSumComparison" -> True,
    "Measurements" -> timings, "ElapsedSeconds" -> AbsoluteTime[] - start|>;
  Clear[control, controlValues]; ClearSystemCache[]; Share[];
  checkpointDirectory = FileNameJoin[{root, "cache", "s05_shared_assembly", channel,
    IntegerString[Hash[{inputHash, evidence["SourceHash"], evidence["InputManifestHash"]}, "SHA256"], 16]}];
  If[!DirectoryQ[checkpointDirectory], CreateDirectory[checkpointDirectory, CreateIntermediateDirectories -> True]];
  sumKeys = Join[Flatten[Table["Photon_" <> ToString[a] <> "_" <> ToString[b],
    {a, Length[photonSymbols]}, {b, Length[photonSymbols]}]], ("Scalar_" <> # &) /@ scalarKeys];
  sumPaths = AssociationThread[sumKeys, (FileNameJoin[{checkpointDirectory, # <> ".wl"}] &) /@ sumKeys];
  sumRecords = Table[
    Print["SHARED_COMPONENT_SAVE ", key, " memory ", MemoryInUse[]];
    value = If[StringStartsQ[key, "Photon_"],
      Extract[matrix, FromDigits /@ Rest[StringSplit[key, "_"]]], scalarValues[StringDrop[key, StringLength["Scalar_"]]]];
    If[StringContainsQ[key, "Ward"], value = bounded[algebraicReduce[value], {label, key, "Ward sum"}]];
    binding = Hash[{inputHash, label, key, evidence["SourceHash"], evidence["InputManifestHash"]}, "SHA256"];
    saved = <|"InputHash" -> inputHash, "CompletedPairSumInputHash" -> binding, "Key" -> key,
      "Value" -> value, "Checks" -> checks|>;
    put[saved, sumPaths[key]];
    If[StringStartsQ[key, "Scalar_"], AssociateTo[scalarValues, StringDrop[key, StringLength["Scalar_"]] -> value]];
    Clear[value, saved]; ClearSystemCache[]; Share[];
    <|"Key" -> key, "CompletedPairSumInputHash" -> binding,
      "File" -> StringDrop[sumPaths[key], StringLength[root] + 1], "FileHash" -> FileHash[sumPaths[key], "SHA256"]|>,
    {key, sumKeys}];
  scalarModes = Join[scalarValues, <|"PhotonWard" -> wardProof["ScalarValue"]|>];
  sumEvidence = sumRecords; completedPairAssemblyEvidence = Join[evidence,
    <|"Schema" -> "polarized-sidis-completed-pair-assembly-v1", "Accepted" -> True,
      "SumFiles" -> sumRecords, "PairMetadata" -> pairValues, "ScalarKeys" -> scalarKeys, "Checks" -> checks|>];
  If[!DirectoryQ[proofDirectory], CreateDirectory[proofDirectory, CreateIntermediateDirectories -> True]];
  put[completedPairAssemblyEvidence, proofPath];
  gate["complete own assembly evidence reload", Get[proofPath] === completedPairAssemblyEvidence];
  gate[label <> " all component sums complete", Length[sumEvidence] === Length[sumKeys]];
  gate[label <> " component sum checks accepted", And @@ Values[checks]];
  Share[]; Print["COMPLETED_PAIR_ASSEMBLY_MEMORY ", MemoryInUse[]]];

assemblyFirst = "  ownPackedPairComparison=verifyOwnPackedPair[];finishPackedPreflight[];";
assemblyLast = "  Clear[sums, sumValues, sumTasks];";
gate["unique complete-pair assembly boundaries", StringCount[componentRunTail, assemblyFirst] === 1 &&
  StringCount[componentRunTail, assemblyLast] === 1];
assemblyBegin = First[First[StringPosition[componentRunTail, assemblyFirst]]];
assemblyEnd = Last[First[StringPosition[componentRunTail, assemblyLast]]];
assemblyOriginalBlock = StringTake[componentRunTail, {assemblyBegin, assemblyEnd}];
assemblyReplacement = "  assembleCompletedPairs[];";
assemblyMetadata = "AssociateTo[result,{\"PackedPairControl\"->ownPackedPairComparison,\"PackedPairDispatchHash\"->FileHash[packedDispatchPath,\"SHA256\"]}];";
assemblyNewMetadata = "AssociateTo[result, {\"CompletedPairAssembly\" -> completedPairAssemblyEvidence, \"CompletedPairAssemblyDispatchHash\" -> FileHash[assemblyDispatchPath, \"SHA256\"]}];";
gate["unique assembly provenance boundary", StringCount[componentRunTail, assemblyMetadata] === 1];
assemblyChanges = {assemblyOriginalBlock -> assemblyReplacement, assemblyMetadata -> assemblyNewMetadata};
assemblyRunTail = StringReplace[componentRunTail, assemblyChanges];
gate["all other original contractions and tensor gates unchanged", SyntaxQ[assemblyRunTail] &&
  StringReplace[assemblyRunTail, Reverse /@ assemblyChanges] === componentRunTail];
ToExpression[assemblyRunTail, InputForm];

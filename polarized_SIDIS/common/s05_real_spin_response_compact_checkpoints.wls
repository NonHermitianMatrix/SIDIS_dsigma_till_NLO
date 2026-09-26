(* Retain the accepted cached-scalar calculation with lossless checkpoint storage. *)
$HistoryLength = 0;
checkpointDispatchPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_compact_checkpoints.wls"}];
checkpointBasePath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[checkpointBasePath, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: immutable cached-scalar implementation"]; Quit[1]];
checkpointCode = Import[checkpointBasePath, "Text"];
checkpointOld = "put[value_, path_] := (Put[value, path <> \".tmp\"];\n  RenameFile[path <> \".tmp\", path, OverwriteTarget -> True]);";
checkpointNew = "put[value_, path_] := Module[{serialized, temporary},\n  serialized = \"Uncompress[\" <> ToString[bounded[Compress[value], \"checkpoint compression\"], InputForm] <> \"]\\n\";\n  gate[\"compressed checkpoint below file bound\", StringLength[serialized] < 128*1024^2];\n  temporary = path <> \".\" <> ToString[$ProcessID] <> \".tmp\";\n  Export[temporary, serialized, \"Text\"];\n  gate[\"compressed checkpoint exact native reload\", bounded[Get[temporary] === value, \"checkpoint reload\"]];\n  RenameFile[temporary, path, OverwriteTarget -> True]];";
checkpointInitialization = "$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; Get[\"FeynCalc`\"];\ngate[\"complete source syntax\", SyntaxQ[Import[sourcePath, \"Text\"]]];";
checkpointProofCode = "\ncheckpointProofPath = FileNameJoin[{root, \"Hgg\", \"s05_pair_storage_result\", \"s05_result.wl\"}];\ncheckpointProofSHA = Environment[\"POLARIZED_SIDIS_STORAGE_PROOF_SHA256\"];\ngate[\"pinned complete own checkpoint storage proof\", channel === \"Hgg\" && StringQ[checkpointProofSHA] &&\n  IntegerString[FileHash[checkpointProofPath, \"SHA256\"], 16, 64] === checkpointProofSHA];\ncheckpointProof = Get[checkpointProofPath];\ngate[\"accepted native checkpoint representation\", checkpointProof[\"Schema\"] === \"polarized-sidis-native-pair-storage-v1\" &&\n  checkpointProof[\"SourceHash\"] === FileHash[FileNameJoin[{root, \"common\", \"s05_compact_pair_checkpoints.wls\"}], \"SHA256\"] &&\n  checkpointProof[\"NativeVersions\"] === {$Version, $FeynCalcVersion} && Length[checkpointProof[\"Files\"]] > 0 &&\n  And @@ Values[checkpointProof[\"Checks\"]] && And @@ Lookup[checkpointProof[\"Files\"], \"exact_native_reload\"]];\ngate[\"complete checkpoint dispatch syntax\", SyntaxQ[Import[checkpointDispatchPath, \"Text\"]]];\n";
checkpointMetadata = "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
If[StringCount[checkpointCode, checkpointOld] =!= 1 ||
  StringCount[checkpointCode, checkpointInitialization] =!= 1 ||
  StringCount[checkpointCode, checkpointMetadata] =!= 1,
  Print["FAIL: unique unchanged checkpoint interfaces"]; Quit[1]];
checkpointCode = StringReplace[checkpointCode, {
  checkpointOld -> checkpointNew,
  checkpointInitialization -> (checkpointInitialization <> checkpointProofCode),
  checkpointMetadata -> (checkpointMetadata <>
    "\nAssociateTo[result, {\"CheckpointStorageValidationHash\" -> FileHash[checkpointProofPath, \"SHA256\"],\n  \"CheckpointStorageDispatchHash\" -> FileHash[checkpointDispatchPath, \"SHA256\"]}];")}];
If[!SyntaxQ[checkpointCode], Print["FAIL: complete compact-checkpoint calculation syntax"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
checkpointCode = StringReplace[checkpointCode, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
ToExpression[checkpointCode, InputForm];

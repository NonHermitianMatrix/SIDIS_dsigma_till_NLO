(* Install only the executed exact-zero angular shortcut; preserve all nonzero reductions. *)
$HistoryLength = 0;
zeroDispatchSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_zero_angular.wls"}];
zeroDispatchBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[zeroDispatchBase, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: pinned zero-angular production source"]; Quit[1]];
zeroDispatchText = Import[zeroDispatchBase, "Text"];
zeroDispatchBoundary = StringPosition[zeroDispatchText, "\nDo[\n  amplitudes ="];
If[Length[zeroDispatchBoundary] =!= 1 || !SyntaxQ[Import[zeroDispatchSource, "Text"]],
  Print["FAIL: complete zero-angular dispatch syntax"]; Quit[1]];
zeroDispatchPrefix = StringTake[zeroDispatchText, First[First[zeroDispatchBoundary]] - 1];
zeroDispatchTail = StringDrop[zeroDispatchText, First[First[zeroDispatchBoundary]] - 1];
If[!SyntaxQ[zeroDispatchPrefix] || !SyntaxQ[zeroDispatchTail], Print["FAIL: inherited complete calculation syntax"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
If[StringCount[zeroDispatchPrefix, "Get[\"FeynCalc`\"]"] =!= 1, Print["FAIL: unique main package loader"]; Quit[1]];
zeroDispatchPrefix = StringReplace[zeroDispatchPrefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[zeroDispatchPrefix], Print["FAIL: native-context initialization syntax"]; Quit[1]];
ToExpression[zeroDispatchPrefix, InputForm];
zeroProofRelative = FileNameJoin[{channel, "s05_zero_angular_result", "s05_result.wl"}];
zeroProofPath = FileNameJoin[{root, zeroProofRelative}];
zeroProofReceiptPath = FileNameJoin[{root, channel, "s05_zero_angular_result", "s05_execution.json"}];
zeroProofReceipt = Import[zeroProofReceiptPath, "RawJSON"];
gate["matching accepted zero-angular receipt", TrueQ[zeroProofReceipt["passed"]] &&
  zeroProofReceipt["result_sha256"][zeroProofRelative] === IntegerString[FileHash[zeroProofPath, "SHA256"], 16, 64]];
zeroProof = Get[zeroProofPath];
gate["complete own zero-angular comparison accepted", channel === "Hqg" && zeroProof["Channel"] === channel &&
  zeroProof["Schema"] === "polarized-sidis-zero-angular-shortcut-validation-v1" &&
  AssociationQ[zeroProof["Checks"]] && Length[zeroProof["Checks"]] > 0 && And @@ Values[zeroProof["Checks"]] &&
  TrueQ[zeroProof["Checks"]["own projection nontrivial shortcut exercised"]] &&
  TrueQ[zeroProof["Checks"]["angular zero never written to pre-average scalar cache"]] &&
  Length[zeroProof["Comparisons"]] === 2 && AllTrue[zeroProof["Comparisons"], TrueQ[#["CompleteProjectionComparison"]] &]];
gate["same zero-angular inputs and native conventions", zeroProof["InputHash"] === inputHash &&
  zeroProof["InputHashes"] === inputHashes && zeroProof["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  zeroProof["ProductionSourceHash"] === FileHash[zeroDispatchBase, "SHA256"] &&
  zeroProof["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s05_check_zero_angular.wls"}], "SHA256"] &&
  zeroProof["ConfigHash"] === FileHash[FileNameJoin[{root, "common", "s05_zero_angular_inputs.json"}], "SHA256"]];
zeroDispatchReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne],
  DownValues[angularAverage], DownValues[angularAverageOne]};
gate["same original scalar and angular definitions", zeroProof["OriginalReductionDefinitions"] === zeroDispatchReductionDefinitions &&
  DownValues[restoredScalarComponent] === (zeroProof["OriginalCheckpointDefinitions"] /. checkpointedScalarComponent -> restoredScalarComponent)];
DownValues[exactAngularZero] = zeroProof["ZeroAngularDefinitions"];
DownValues[restoredScalarComponent] = zeroProof["GuardedCheckpointDefinitions"] /. zeroCheckpointedScalarComponent -> restoredScalarComponent;
gate["exact executed zero-angular definitions installed", DownValues[exactAngularZero] === zeroProof["ZeroAngularDefinitions"] &&
  DownValues[restoredScalarComponent] === (zeroProof["GuardedCheckpointDefinitions"] /. zeroCheckpointedScalarComponent -> restoredScalarComponent)];
gate["original scalar and angular equations retained after installation", zeroDispatchReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]}];
zeroDispatchChanges = {
  "compactSpinResponse, restoredScalarComponent, profiledNative, coefficientAlgorithmHash" ->
    "compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, coefficientAlgorithmHash",
  "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];" ->
    "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];\nAssociateTo[result, \"ZeroAngularValidationHash\" -> FileHash[zeroProofPath, \"SHA256\"], \"ZeroAngularDispatchHash\" -> FileHash[zeroDispatchSource, \"SHA256\"]];"};
gate["unique zero-angular worker and provenance interfaces", And @@ (StringCount[zeroDispatchTail, First[#]] === 1 & /@ zeroDispatchChanges)];
zeroDispatchRunTail = StringReplace[zeroDispatchTail, zeroDispatchChanges];
gate["complete inherited real calculation retained", StringReplace[zeroDispatchRunTail, Reverse /@ zeroDispatchChanges] === zeroDispatchTail && SyntaxQ[zeroDispatchRunTail]];
ToExpression[zeroDispatchRunTail, InputForm];

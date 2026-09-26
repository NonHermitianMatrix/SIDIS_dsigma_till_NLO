(* Install the own-channel tested zero-angular shortcut in the accepted Hgg pipeline. *)
$HistoryLength = 0;
ownZeroSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hgg_zero_angular.wls"}];
ownZeroBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_sector_ward.wls"}];
If[IntegerString[FileHash[ownZeroBase, "SHA256"], 16, 64] =!=
  "6948a70cdb9e796425db2d4fb61bf848af2824cdb1e0e493470c0d81a250dd14", Quit[1]];
ownZeroBaseText = Import[ownZeroBase, "Text"];
ownZeroEntry = "ToExpression[checkpointCode, InputForm];";
ownZeroEntryPositions = StringPosition[ownZeroBaseText, ownZeroEntry];
If[ownZeroEntryPositions === {} ||
  !StringEndsQ[StringTrim[ownZeroBaseText], ownZeroEntry] || !SyntaxQ[Import[ownZeroSource, "Text"]],
  Print["FAIL: complete Hgg zero-angular source and terminal entry"]; Quit[1]];
ownZeroBootstrap = StringTake[ownZeroBaseText, First[Last[ownZeroEntryPositions]] - 1];
If[!SyntaxQ[ownZeroBootstrap], Quit[1]];
ToExpression[ownZeroBootstrap, InputForm];
ownZeroBoundary = "\nDo[\n  amplitudes =";
If[StringCount[checkpointCode, ownZeroBoundary] =!= 1, Quit[1]];
ownZeroPrefix = First[StringSplit[checkpointCode, ownZeroBoundary]];
ownZeroTail = ownZeroBoundary <> Last[StringSplit[checkpointCode, ownZeroBoundary]];
If[!SyntaxQ[ownZeroPrefix] || !SyntaxQ[ownZeroTail], Quit[1]];
ToExpression[ownZeroPrefix, InputForm];
ownZeroProofRelative = "Hgg/s05_zero_angular_result/s05_result.wl";
ownZeroProofPath = FileNameJoin[{root, ownZeroProofRelative}];
ownZeroReceiptPath = FileNameJoin[{root, "Hgg", "s05_zero_angular_result", "s05_execution.json"}];
gate["pinned own angular-zero proof and receipt",
  IntegerString[FileHash[ownZeroProofPath, "SHA256"], 16, 64] === "793290082b835554b6bf252955675ca123624aff0c1c5f484845704addede607" &&
  IntegerString[FileHash[ownZeroReceiptPath, "SHA256"], 16, 64] === "85e0353a16dc55cc56d21e7cb3cb3176f3a17d3feedcc7ac8401524cf5db3e51"];
ownZeroReceipt = Import[ownZeroReceiptPath, "RawJSON"]; ownZeroProof = Get[ownZeroProofPath];
gate["own complete angular comparison accepted", channel === "Hgg" && ownZeroProof["Channel"] === channel &&
  ownZeroProof["Schema"] === "polarized-sidis-own-angular-zero-comparison-v1" && TrueQ[ownZeroReceipt["passed"]] &&
  ownZeroReceipt["result_sha256"][ownZeroProofRelative] === IntegerString[FileHash[ownZeroProofPath, "SHA256"], 16, 64] &&
  AssociationQ[ownZeroProof["Checks"]] && Length[ownZeroProof["Checks"]] > 0 && And @@ Values[ownZeroProof["Checks"]] &&
  TrueQ[ownZeroProof["Checks"]["own nontrivial angular-zero shortcut exercised"]] &&
  TrueQ[ownZeroProof["Checks"]["own nonzero reduction retained"]] &&
  TrueQ[ownZeroProof["Checks"]["angular zero never saved before angular averaging"]] &&
  Length[ownZeroProof["Comparisons"]] === 2 && AllTrue[ownZeroProof["Comparisons"], TrueQ[#["CompleteProjectionComparison"]] &]];
gate["own angular proof source inputs and native conventions", ownZeroProof["InputHash"] === inputHash &&
  ownZeroProof["InputHashes"] === inputHashes && ownZeroProof["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  ownZeroProof["ProductionSourceHash"] === FileHash[sourcePath, "SHA256"] &&
  ownZeroProof["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s05_check_Hgg_zero_angular.wls"}], "SHA256"]];
ownZeroOriginalReduction = {DownValues[algebraicReduce], DownValues[algebraicReduceOne],
  DownValues[angularAverage], DownValues[angularAverageOne]};
gate["original own scalar and angular equations", ownZeroProof["OriginalReductionDefinitions"] === ownZeroOriginalReduction &&
  DownValues[restoredScalarComponent] === (ownZeroProof["OriginalCheckpointDefinitions"] /. checkpointedScalarComponent -> restoredScalarComponent)];
installOwnZeroAngular[] := (
  gate["unchanged equations at angular shortcut installation", ownZeroOriginalReduction ===
    {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]} &&
    DownValues[restoredScalarComponent] === (ownZeroProof["OriginalCheckpointDefinitions"] /. checkpointedScalarComponent -> restoredScalarComponent)];
  DownValues[exactAngularZero] = ownZeroProof["ZeroAngularDefinitions"];
  DownValues[restoredScalarComponent] = ownZeroProof["GuardedCheckpointDefinitions"] /. zeroCheckpointedScalarComponent -> restoredScalarComponent;
  gate["executed own zero-angular definitions installed", DownValues[exactAngularZero] === ownZeroProof["ZeroAngularDefinitions"] &&
    DownValues[restoredScalarComponent] === (ownZeroProof["GuardedCheckpointDefinitions"] /. zeroCheckpointedScalarComponent -> restoredScalarComponent)]);
ownZeroWorkerBoundary = "  slots = Quiet[Check[ToExpression[Environment[\"NSLOTS\"]], 1]];";
ownZeroMetadata = "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
ownZeroMetadataCode = ownZeroMetadata <>
  "\nAssociateTo[result, {\"OwnZeroAngularProofHash\" -> FileHash[ownZeroProofPath, \"SHA256\"], \"OwnZeroAngularSourceHash\" -> FileHash[ownZeroSource, \"SHA256\"]}];";
ownZeroChanges = {
  ownZeroWorkerBoundary -> ("  installOwnZeroAngular[];\n" <> ownZeroWorkerBoundary),
  "compactSpinResponse, restoredScalarComponent, profiledNative, coefficientAlgorithmHash" ->
    "compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, coefficientAlgorithmHash",
  ownZeroMetadata -> ownZeroMetadataCode};
gate["unique own zero-angular installation interfaces", And @@ (StringCount[ownZeroTail, First[#]] === 1 & /@ ownZeroChanges)];
ownZeroRunTail = StringReplace[ownZeroTail, ownZeroChanges];
gate["unchanged complete Hgg real calculation", StringReplace[ownZeroRunTail, Reverse /@ ownZeroChanges] === ownZeroTail && SyntaxQ[ownZeroRunTail]];
Block[{result = <||>}, ToExpression[ownZeroMetadataCode, InputForm];
  gate["actual complete own zero-angular provenance", result === <|
    "ScalarCheckpointValidationHash" -> FileHash[coefficientProofPath, "SHA256"],
    "OwnZeroAngularProofHash" -> FileHash[ownZeroProofPath, "SHA256"],
    "OwnZeroAngularSourceHash" -> FileHash[ownZeroSource, "SHA256"]|>]];
ToExpression[ownZeroRunTail, InputForm];

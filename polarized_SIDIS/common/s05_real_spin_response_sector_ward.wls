(* Reuse the accepted complete-amplitude Ward proof with unchanged physical projections. *)
$HistoryLength = 0;
sectorDispatchPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_sector_ward.wls"}];
sectorBasePath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_compact_checkpoints.wls"}];
If[IntegerString[FileHash[sectorBasePath, "SHA256"], 16, 64] =!=
  "030c45837ea1fd7b558ab97105e7384bbaad9f35bd53c3e9b868dd4ee19bac29",
  Print["FAIL: immutable compact checkpoint entry point"]; Quit[1]];
sectorBaseText = Import[sectorBasePath, "Text"];
sectorBoundary = "ToExpression[checkpointCode, InputForm];";
If[StringCount[sectorBaseText, sectorBoundary] =!= 1,
  Print["FAIL: unique compact dispatch boundary"]; Quit[1]];
sectorBootstrap = First[StringSplit[sectorBaseText, sectorBoundary]];
If[!SyntaxQ[sectorBootstrap], Print["FAIL: compact bootstrap syntax"]; Quit[1]];
ToExpression[sectorBootstrap, InputForm];
sectorOriginalCode = checkpointCode;
sectorReplace[old_, new_] := (
  If[StringCount[checkpointCode, old] =!= 1,
    Print["FAIL: unique sector dispatch interface ", old]; Quit[1]];
  checkpointCode = StringReplace[checkpointCode, old -> new]);
sectorCacheLine = "cache = FileNameJoin[{root, \"cache\", \"s05\", channel, IntegerString[inputHash, 16]}];";
sectorProofCode = "
wardProofPath = FileNameJoin[{root, \"Hgg\", \"s05_ordered_amplitude_ward_result\", \"s05_result.wl\"}];
wardReceiptPath = FileNameJoin[{DirectoryName[wardProofPath], \"s05_execution.json\"}];
wardProofHash = FileHash[wardProofPath, \"SHA256\"];
gate[\"pinned own complete-amplitude Ward proof\", channel === \"Hgg\" &&
  IntegerString[wardProofHash, 16, 64] === \"48367062fd822766d83c23e95da8845e67c5ae0e49f532ee9b47914b7a6a2239\" &&
  IntegerString[FileHash[wardReceiptPath, \"SHA256\"], 16, 64] ===
    \"7cfa37e10aa962ce993471c89c15ee3b230d679a5f7ebd84b19bbee306a0abea\"];
wardReceipt = Import[wardReceiptPath, \"RawJSON\"]; wardProof = Get[wardProofPath];
gate[\"accepted complete-sector photon Ward proof\", TrueQ[wardReceipt[\"passed\"]] &&
  wardReceipt[\"result_sha256\"][\"Hgg/s05_ordered_amplitude_ward_result/s05_result.wl\"] === IntegerString[wardProofHash, 16, 64] &&
  wardProof[\"Schema\"] === \"polarized-sidis-amplitude-ward-comparison-v1\" && wardProof[\"Channel\"] === channel &&
  And @@ Values[wardProof[\"Checks\"]] && wardProof[\"CandidateValue\"] === 0 && wardProof[\"ScalarValue\"] === 0 &&
  wardProof[\"NativeVersions\"] === {$Version, $FeynCalcVersion} && wardProof[\"InputHash\"] === inputHash &&
  wardProof[\"InputHashes\"] === inputHashes && wardProof[\"ProductionSourceHash\"] === FileHash[sourcePath, \"SHA256\"] &&
  IntegerString[wardProof[\"SourceHash\"], 16, 64] === \"17eeead96293268f88c8ff9fc2d6bc4dfeeafb76eec3edefda7fa1390d8bda53\"];
gate[\"complete sector dispatch syntax\", SyntaxQ[Import[sectorDispatchPath, \"Text\"]]];
previousInputHashes = DeleteDuplicates[Prepend[previousInputHashes, inputHash]];
cache = FileNameJoin[{root, \"cache\", \"s05_sector_ward\", channel, IntegerString[Hash[{inputHash, wardProofHash}, \"SHA256\"], 16]}];";
sectorReplace[sectorCacheLine, sectorProofCode];
sectorReplace["validationOnly = Environment[\"POLARIZED_SIDIS_VALIDATE_ONLY\"] === \"1\";",
  "validationOnly = Environment[\"POLARIZED_SIDIS_VALIDATE_ONLY\"] === \"1\";\ngate[\"production complete-sector Ward mode\", !validationOnly];"];
sectorReplace["If[Lookup[saved, \"InputHash\", None] === inputHash, Return[saved]];",
  "If[Lookup[saved, \"InputHash\", None] === inputHash,\n      gate[\"pair complete-sector Ward identity\", Lookup[saved, \"SectorWardComparisonHash\", None] === wardProofHash]; Return[saved]];"];
sectorOldModes = "scalarModes = <|\"PgD\" -> cachedProjection[prefix <> \"_PgD.wl\", tensor MTD[mu, nu], {label, pair, \"PgD\"}],\n      \"PhotonWard\" -> cachedProjection[prefix <> \"_PhotonWard.wl\", photonProject[tensor, q, q], {label, pair, \"photon Ward\"}]|>;";
sectorNewModes = "scalarModes = <|\"PgD\" -> cachedProjection[prefix <> \"_PgD.wl\", tensor MTD[mu, nu], {label, pair, \"PgD\"}]|>;";
sectorReplace[sectorOldModes, sectorNewModes];
If[StringCount[checkpointCode, "put[saved, pairPath];"] =!= 2,
  Print["FAIL: complete pair writer inventory"]; Quit[1]];
checkpointCode = StringReplace[checkpointCode, "put[saved, pairPath];" ->
  "AssociateTo[saved, \"SectorWardComparisonHash\" -> wardProofHash]; put[saved, pairPath];"];
sectorSectorGate = "
  gate[\"same complete generated amplitude inventory\", labels === {label} &&
    Range[Length[amplitudes]] === wardProof[\"AmplitudeInventory\"] && Hash[amplitudes, \"SHA256\"] === wardProof[\"AmplitudeHash\"]];
  gate[\"unchanged complete-sector contraction definitions\", wardProof[\"OriginalDefinitions\"] ===
    {DownValues[buildPair], DownValues[reduceScalar], DownValues[restoredScalarComponent],
      DownValues[algebraicReduceOne], DownValues[angularAverageOne]}];
";
sectorReplace["  slots = Quiet[Check[ToExpression[Environment[\"NSLOTS\"]], 1]];",
  sectorSectorGate <> "  slots = Quiet[Check[ToExpression[Environment[\"NSLOTS\"]], 1]];"];
sectorReplace["inputHash, previousInputHashes, pairs, basis,", "inputHash, previousInputHashes, wardProofHash, pairs, basis,"];
sectorReplace["  scalarKeys = Keys[First[pairValues][\"ScalarModes\"]];",
  "  gate[\"all pairs share complete-sector proof\", AllTrue[pairValues, Lookup[#, \"SectorWardComparisonHash\", None] === wardProofHash &]];\n  pairValues = (Join[#, <|\"ScalarModes\" -> KeyDrop[#[\"ScalarModes\"], \"PhotonWard\"]|>] &) /@ pairValues;\n  scalarKeys = Keys[First[pairValues][\"ScalarModes\"]];"];
sectorReplace["  scalarModes = Association@Table[key -> sumValues[\"Scalar_\" <> key], {key, scalarKeys}];",
  "  scalarModes = Association@Table[key -> sumValues[\"Scalar_\" <> key], {key, scalarKeys}];\n  AssociateTo[scalarModes, \"PhotonWard\" -> wardProof[\"ScalarValue\"]];"];
sectorReplace["AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];",
  "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];\nAssociateTo[result, {\"SectorWardComparisonHash\" -> wardProofHash,\n  \"SectorWardDispatchHash\" -> FileHash[sectorDispatchPath, \"SHA256\"], \"SectorWardCache\" -> cache}];"];
If[!SyntaxQ[checkpointCode], Print["FAIL: complete sector-Ward calculation syntax"]; Quit[1]];
ToExpression[checkpointCode, InputForm];

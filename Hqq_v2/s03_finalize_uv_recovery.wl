(* Hqq_v2 S03: finalize the hash-bound UV-tail recovery. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
$LoadAddOns = {"FeynArts", "FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[
  hqqV2Fail, hqqV2Require, atomicPut, namedSymbolQ,
  strongCouplingArgumentQ, strongSMPObjects, extractLoggedResidual
];

hqqV2Fail[msg_String] :=
  (Print["S03_FINALIZE_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] :=
  If[! TrueQ[test], hqqV2Fail[msg]];

atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    hqqV2Fail["failed to write " <> path]];
  hqqV2Require[
    FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary result is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  hqqV2Require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"];
];

namedSymbolQ[symbol_, name_String] :=
  MatchQ[Unevaluated[symbol], _Symbol] &&
    SymbolName[Unevaluated[symbol]] === name;
strongCouplingArgumentQ[argument_] :=
  SameQ[argument, "g_s"] ||
    (MatchQ[Unevaluated[argument], _Symbol] &&
      SymbolName[Unevaluated[argument]] === "g_s");
strongSMPObjects[expression_] := DeleteDuplicates@Cases[
  Unevaluated[expression],
  object : head_[argument_] /;
      namedSymbolQ[Unevaluated[head], "SMP"] &&
        strongCouplingArgumentQ[argument] :> Unevaluated[object],
  Infinity];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
checkpointPath = FileNameJoin[{stageDirectory,
  "s03_pre_uv_checkpoint.wl"}];
recoverySourcePath = FileNameJoin[{stageDirectory,
  "s03_renormalize_project_hqq.wl"}];
failedProductionLogPath = FileNameJoin[{stageDirectory,
  "s03_failed_uv_cancellation_local.log"}];
recoveryLogPath = FileNameJoin[{stageDirectory,
  "s03_uv_recovery_local.log"}];
resultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];

expectedCheckpointHash =
  "20e642e5474ff130934f8d1963f1966cb18ceac819a532295c1af3a715af16a5";
expectedRecoverySourceHash =
  "17414e62c06f2f885449a305df7c4094eac0d7eb8e1de9b2b456865dbb3f4111";
expectedFailedProductionLogHash =
  "e080747ea4d1c74bd4d9a37ba33446914dbf9ae2e4c1ea3f16a751ac9fcc437c";
expectedRecoveryLogHash =
  "5bb9f642b737b1c8b46e53346a48d1cae1e54e640ce637b73b9f8f7e6292132c";
expectedS01SourceHash =
  "5125f6f8a2c2ac7cfa44fc3b8bb437e1f5fdf26c52169d9c4991f5b35ab660d1";
expectedS01ResultHash =
  "83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911";
expectedS02SourceHash =
  "2559c4b388b9fcb746dcf37bebbd33731f6adf7584e749ac632e4db68854fe73";
expectedS02ResultHash =
  "316c6e18b49bd7c446506fc866546d0c998f6d61cec3c3813693cbf72b735c83";

hqqV2Require[
  FileHash[checkpointPath, "SHA256", "HexString"] ===
    expectedCheckpointHash,
  "pre-UV checkpoint identity mismatch"];
hqqV2Require[
  FileHash[recoverySourcePath, "SHA256", "HexString"] ===
    expectedRecoverySourceHash,
  "recovery source identity mismatch"];
hqqV2Require[
  FileHash[failedProductionLogPath, "SHA256", "HexString"] ===
    expectedFailedProductionLogHash,
  "failed production log identity mismatch"];
hqqV2Require[
  FileHash[recoveryLogPath, "SHA256", "HexString"] ===
    expectedRecoveryLogHash,
  "recovery log identity mismatch"];
hqqV2Require[! FileExistsQ[resultPath],
  "an S03 result already exists"];

Print["S03_FINALIZE_STAGE=load pre-UV checkpoint and UV log"];
checkpoint = Get[checkpointPath];
recoveryLogText = Import[recoveryLogPath, "Text"];
hqqV2Require[
  AssociationQ[checkpoint] &&
    checkpoint["Stage"] === "HqqV2S03PreUVCheckpoint-v1" &&
    checkpoint["ScopeTag"] === scopeTag &&
    checkpoint["RecoverySource", "SHA256"] ===
      expectedRecoverySourceHash &&
    checkpoint["FailedRunEvidence", "LogSHA256"] ===
      expectedFailedProductionLogHash &&
    checkpoint["Inputs", "S01SourceSHA256"] ===
      expectedS01SourceHash &&
    checkpoint["Inputs", "S01ResultSHA256"] ===
      expectedS01ResultHash &&
    checkpoint["Inputs", "S02SourceSHA256"] ===
      expectedS02SourceHash &&
    checkpoint["Inputs", "S02ResultSHA256"] ===
      expectedS02ResultHash &&
    And @@ Values[checkpoint["PreUVChecks"]],
  "pre-UV checkpoint failed its bound schema or gates"];

projectedPreUV = checkpoint["ProjectedPreUV"];
channelStrongCouplings = DeleteDuplicates@Cases[
  projectedPreUV,
  symbol_Symbol /;
      namedSymbolQ[Unevaluated[symbol], "FAGS"] :>
        Unevaluated[symbol],
  Infinity];
checkpointSMStrongCouplings = strongSMPObjects[projectedPreUV];
hqqV2Require[
  Length[channelStrongCouplings] === 1 &&
    Length[checkpointSMStrongCouplings] === 1,
  "checkpoint does not contain one channel and one SM strong coupling"];
channelStrongCoupling = First[channelStrongCouplings];
checkpointSMStrongCoupling = First[checkpointSMStrongCouplings];

Print["S03_FINALIZE_STAGE=derive coupling map from generated tree vertex"];
treeTopologies = FeynArts`CreateTopologies[0, 2 -> 1];
treeInsertions = FeynArts`InsertFields[treeTopologies,
  {FeynArts`F[3, {1}], FeynArts`V[5]} ->
    {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD",
  FeynArts`GenericModel -> "Lorentz"];
treeRaw = FeynArts`CreateFeynAmp[treeInsertions,
  FeynArts`Truncated -> True,
  FeynArts`GaugeRules -> {},
  FeynArts`PreFactor -> 1];
treeConverted = CheckAbort[Quiet@Check[
  FeynCalc`FCFAConvert[treeRaw,
    FeynCalc`IncomingMomenta -> {rMap, -rMap},
    FeynCalc`OutgoingMomenta -> {0},
    FeynCalc`LoopMomenta -> {},
    FeynCalc`LorentzIndexNames -> {aMap},
    FeynCalc`DropSumOver -> True,
    FeynCalc`UndoChiralSplittings -> True,
    FeynCalc`ChangeDimension -> D,
    FeynCalc`SMP -> True,
    System`List -> True], $Failed], $Failed];
rawModelStrongCouplings = DeleteDuplicates@Cases[
  treeRaw,
  symbol_Symbol /;
      namedSymbolQ[Unevaluated[symbol], "FAGS"] :>
        Unevaluated[symbol],
  Infinity];
convertedSMStrongCouplings = strongSMPObjects[treeConverted];
couplingMapGeneratedGate = TrueQ[
  ListQ[treeConverted] && Length[treeConverted] === 1 &&
  Length[rawModelStrongCouplings] === 1 &&
  Length[convertedSMStrongCouplings] === 1 &&
  SymbolName[First[rawModelStrongCouplings]] ===
    SymbolName[channelStrongCoupling] &&
  SameQ[First[convertedSMStrongCouplings],
    checkpointSMStrongCoupling]];
hqqV2Require[couplingMapGeneratedGate,
  "generated tree vertex did not establish the FAGS-to-SMP map"];

checkpointCouplingRule =
  checkpointSMStrongCoupling -> channelStrongCoupling;
projected = projectedPreUV /. checkpointCouplingRule;
renormalization =
  checkpoint["Renormalization"] /. checkpointCouplingRule;
couplingCanonicalizationGate = TrueQ[
  strongSMPObjects[{projected, renormalization}] === {} &&
  ! FreeQ[{projected, renormalization}, channelStrongCoupling]];
hqqV2Require[couplingCanonicalizationGate,
  "tool-derived checkpoint coupling canonicalization failed"];

extractLoggedResidual[label_String] := Module[
  {prefix, lines, body, held},
  prefix = "S03_UV_POLE_RESIDUAL=" <> label <> " InputForm[";
  lines = Select[StringSplit[recoveryLogText, "\n"],
    StringStartsQ[#, prefix] &];
  hqqV2Require[
    Length[lines] === 1 && StringEndsQ[First[lines], "]"],
    "recovery log does not contain one exact " <> label <>
      " UV residual"];
  body = StringDrop[
    StringDrop[First[lines], StringLength[prefix]], -1];
  body = StringReplace[body,
    "SMP[g_s]" -> "HqqV2LoggedStrongCoupling"];
  held = Quiet@Check[
    ToExpression[body, InputForm, HoldComplete], $Failed];
  hqqV2Require[
    held =!= $Failed && FreeQ[held,
      _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
    "failed to parse exact " <> label <> " UV residual"];
  ReleaseHold[held]
];

projectorLabels = Keys[checkpoint["Projectors"]];
uvPoleResidualsBeforeCanonicalization = AssociationMap[
  extractLoggedResidual, projectorLabels];
hqqV2Require[
  ! FreeQ[uvPoleResidualsBeforeCanonicalization,
    HqqV2LoggedStrongCoupling],
  "logged UV residuals do not contain the strong-coupling marker"];
loggedCouplingRule =
  HqqV2LoggedStrongCoupling -> channelStrongCoupling;
couplingCanonicalizationRules =
  DeleteDuplicates[{checkpointCouplingRule, loggedCouplingRule}];
uvPoleResiduals = AssociationMap[
  Together[uvPoleResidualsBeforeCanonicalization[#] /.
      couplingCanonicalizationRules] &,
  projectorLabels];
uvCancellationGates = AssociationMap[
  TrueQ[Together[uvPoleResiduals[#]] === 0] &,
  projectorLabels];
Scan[Function[projectorLabel,
  Print["S03_FINAL_UV_POLE_RESIDUAL=", projectorLabel, " ",
    InputForm[uvPoleResiduals[projectorLabel]]]], projectorLabels];
hqqV2Require[And @@ Values[uvCancellationGates],
  "hash-bound exact UV residues do not cancel after canonicalization"];

virtualProjected = projected["VirtualBareDirected"];
countertermProjected = projected["CountertermDirected"];
uvRenormalizedPV = AssociationMap[
  virtualProjected[#] + countertermProjected[#] &,
  projectorLabels];
scalarMasters = DeleteDuplicates@Cases[
  Flatten[Values[projected["VirtualBareDirectedRows"]]],
  master : (FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe)[___] :> master,
  Infinity];

recoveryUVLogGate = TrueQ[
  StringContainsQ[recoveryLogText,
    "S03_STAGE=batch distinct-master UV extraction"] &&
  StringContainsQ[recoveryLogText,
    "S03_FAILURE: exact MS-bar UV-pole cancellation failed"] &&
  Keys[uvPoleResidualsBeforeCanonicalization] === projectorLabels];
checks = Join[checkpoint["PreUVChecks"], <|
  "CheckpointIdentity" ->
    (FileHash[checkpointPath, "SHA256", "HexString"] ===
      expectedCheckpointHash),
  "GeneratedTreeCouplingMap" -> couplingMapGeneratedGate,
  "StrongCouplingCanonicalized" -> couplingCanonicalizationGate,
  "RecoveryUVLogBound" -> recoveryUVLogGate,
  "ExactUVResidualsParsed" ->
    FreeQ[uvPoleResidualsBeforeCanonicalization,
      _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
  "BothUVPoleResidualsZero" ->
    And @@ Values[uvCancellationGates],
  "CanonicalizedPublishedDataHaveNoSMPGS" ->
    (strongSMPObjects[{projected, renormalization,
      uvRenormalizedPV, uvPoleResiduals}] === {}),
  "SymbolicExactAfterUV" -> FreeQ[
    {projected, renormalization, uvRenormalizedPV,
      uvPoleResidualsBeforeCanonicalization, uvPoleResiduals},
    $Failed | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity]
|>];
Print["S03_FINAL_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks],
  "one or more final S03 recovery gates failed"];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
renormalization = Append[renormalization,
  "CouplingCanonicalization" -> <|
    "FeynArtsRawModelCoupling" ->
      First[rawModelStrongCouplings],
    "FeynCalcSMCoupling" -> checkpointSMStrongCoupling,
    "LoggedSMCouplingDisplay" -> "SMP[g_s]",
    "ChannelCoupling" -> channelStrongCoupling,
    "AppliedRules" -> couplingCanonicalizationRules,
    "GeneratedTreeGate" -> couplingMapGeneratedGate|>];

result = <|
  "Stage" -> "HqqV2S03-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "RecoveryProvenance" -> <|
    "FailedProductionLogSHA256" ->
      expectedFailedProductionLogHash,
    "RecoverySourceSHA256" -> expectedRecoverySourceHash,
    "RecoveryLogSHA256" -> expectedRecoveryLogHash,
    "PreUVCheckpointSHA256" -> expectedCheckpointHash|>,
  "Inputs" -> checkpoint["Inputs"],
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
  "Projectors" -> checkpoint["Projectors"],
  "Kinematics" -> checkpoint["Kinematics"],
  "Projected" -> Append[projected,
    "VirtualUVRenormalizedPV" -> uvRenormalizedPV],
  "RealGaugeGates" -> checkpoint["RealGaugeGates"],
  "Renormalization" -> renormalization,
  "UVLedger" -> <|
    "ExtractionEvidenceLogSHA256" -> expectedRecoveryLogHash,
    "DistinctMasters" -> scalarMasters,
    "DistinctMasterUVParts" ->
      Missing["NotSerializedByCompletedRecoveryUVRun"],
    "VirtualUVRows" ->
      Missing["NotSerializedByCompletedRecoveryUVRun"],
    "VirtualUV" ->
      Missing["NotSerializedByCompletedRecoveryUVRun"],
    "PoleResidualsBeforeCouplingCanonicalization" ->
      uvPoleResidualsBeforeCanonicalization,
    "PoleResiduals" -> uvPoleResiduals,
    "CancellationGates" -> uvCancellationGates,
    "FullMasterEvaluationDeferredTo" -> "S06"|>,
  "ParallelPolicy" -> checkpoint["ParallelPolicy"],
  "HermitianConvention" -> checkpoint["HermitianConvention"],
  "Checks" -> checks
|>;

Print["S03_FINALIZE_STAGE=atomic result publication"];
atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];

kernelExecutable = First[$CommandLine];
validatorCode = StringJoin[
  "$HistoryLength=0;$LoadAddOns={\"FeynArts\",\"FeynHelpers\"};",
  "$FeynCalcStartupMessages=False;Quiet[Needs[\"FeynCalc`\"]];",
  "r=Get[", ToString[resultPath, InputForm], "];",
  "ok=AssociationQ[r]&&r[\"Stage\"]===\"HqqV2S03-v1\"&&",
  "r[\"ScopeTag\"]===", ToString[scopeTag, InputForm], "&&",
  "r[\"Source\",\"SHA256\"]===",
    ToString[sourceHash, InputForm], "&&",
  "r[\"Inputs\",\"S02ResultSHA256\"]===",
    ToString[expectedS02ResultHash, InputForm], "&&",
  "And@@Values[r[\"Checks\"]]&&",
  "And@@Values[r[\"UVLedger\",\"CancellationGates\"]];",
  "If[TrueQ[ok],Print[\"S03_FRESH_RELOAD_OK\"];Quit[0],",
  "Print[\"S03_FRESH_RELOAD_FAILURE\"];Quit[1]]"
];
validator = RunProcess[
  {kernelExecutable, "-noinit", "-noprompt", "-run", validatorCode},
  {"ExitCode", "StandardOutput", "StandardError"}];
If[StringLength[validator["StandardOutput"]] > 0,
  Print[validator["StandardOutput"]]];
If[StringLength[validator["StandardError"]] > 0,
  Print[validator["StandardError"]]];
hqqV2Require[
  validator["ExitCode"] === 0 &&
    StringContainsQ[validator["StandardOutput"],
      "S03_FRESH_RELOAD_OK"],
  "fresh-kernel S03 result validation failed"];

Print["S03_FINALIZER_SOURCE_SHA256=", sourceHash];
Print["S03_RESULT_SHA256=", resultHash];
Print["S03_DISTINCT_MASTERS=", Length[scalarMasters]];
Print["S03_SUCCESS"];
Quit[0];

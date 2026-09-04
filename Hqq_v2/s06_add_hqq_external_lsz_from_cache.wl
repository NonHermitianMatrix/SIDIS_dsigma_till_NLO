(* Hqq_v2 S06: add the accepted external-LSZ row to cached virtual data. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
$FCAdvice = False;

ClearAll[
  fail, require, atomicPut, exactZeroQ, massShellRule,
  packageXConjugate
];

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

fail[message_String, detail_: Null] := (
  Print["S06_LSZ_FAILURE: ", message];
  If[detail =!= Null,
    Print["S06_LSZ_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Cancel[Together[expression]] === 0];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], fail["failed to write " <> path]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary publication is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published file is missing or empty"];
];
massShellRule[record_List] := With[
  {momentum = record[[1]], value = record[[2]]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum, D],
    FeynCalc`Momentum[momentum, D]]] :> value];
packageXConjugate[expression_] := Module[{answer},
  answer = expression /. {
    X`ContinuedDiLog[{x_, xPrescription_}, {y_, yPrescription_}] :>
      X`ContinuedDiLog[{x, -xPrescription}, {y, -yPrescription}],
    X`DiLog[x_, prescription_] :> X`DiLog[x, -prescription],
    X`Ln[x_, prescription_] :> X`Ln[x, -prescription]};
  answer /. Complex[real_, imaginary_] :>
    Complex[real, -imaginary]
];
stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
correctedS03SourcePath = FileNameJoin[{stageDirectory,
  "s03_correct_hqq_external_lsz.wl"}];
correctedS03ResultPath = FileNameJoin[{stageDirectory,
  "s03_result.wl"}];
preS06SourcePath = FileNameJoin[{stageDirectory,
  "s06_evaluate_hqq_virtual.wl"}];
preS06ResultPath = FileNameJoin[{stageDirectory,
  "s06_result_pre_lsz_superseded_b8e8b105.wl"}];
masterCachePath = FileNameJoin[{stageDirectory,
  "s06_master_cache.wl"}];
branchCachePath = FileNameJoin[{stageDirectory,
  "s06_branch_cache.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s06_result.wl"}];

expectedCorrectedS03SourceHash =
  "8fb858fdd596a0dc21ffdf03031e0f21d2585d5e976b3bb6ee9c4a003bb8c40d";
expectedCorrectedS03ResultHash =
  "b3d483dea534ed26b93e601c28788b6c5797a200bb04e72c913b1c0c6c69ab80";
expectedPreS06SourceHash =
  "4b78bd25d05d52913ad668973fc6c404b1b883e6b94e6ede0562ac98d892e8d3";
expectedPreS06ResultHash =
  "b8e8b105bf62f2148d56d419a2563c8970dcf7c8b1b8e097f6ad55e0f1dddb9e";
expectedPreLSZS03ResultHash =
  "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4";
expectedS04SourceHash =
  "ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793";
expectedS04ResultHash =
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c";
expectedMasterCacheHash =
  "194798bbeae02f03192e57dfc5f14fc61bf40579e20049608de78c76909fe54c";
expectedBranchCacheHash =
  "ff1e712bbfd19b267fdc7829e9ff14efd90d91b1d58d282796ce2dead12e8456";
expectedBranchProducerHash =
  "aa57a7cd30a141dc67e60abea1e5423940563bb7216b6c5e730895cea6a86bad";
expectedBranchContractHash =
  "c6e5df1a98d6176131cf739f4e25cb937417ca255658aaca18c86400909cb43e";
expectedBranchStoredContentHash =
  "4926c277226fdc48cea7424da53fe4c6b850fafafd02959e5dc97b383d910801";

requiredPaths = {correctedS03SourcePath, correctedS03ResultPath,
  preS06SourcePath, preS06ResultPath, masterCachePath,
  branchCachePath};
require[And @@ Map[FileExistsQ, requiredPaths],
  "a required accepted input is missing", requiredPaths];
require[! FileExistsQ[resultPath],
  "corrected S06 target already exists; refusing to overwrite it"];

inputFileChecks = <|
  "CorrectedS03Source" ->
    (FileHash[correctedS03SourcePath, "SHA256", "HexString"] ===
      expectedCorrectedS03SourceHash),
  "CorrectedS03Result" ->
    (FileHash[correctedS03ResultPath, "SHA256", "HexString"] ===
      expectedCorrectedS03ResultHash),
  "PreS06Source" ->
    (FileHash[preS06SourcePath, "SHA256", "HexString"] ===
      expectedPreS06SourceHash),
  "PreS06Result" ->
    (FileHash[preS06ResultPath, "SHA256", "HexString"] ===
      expectedPreS06ResultHash),
  "MasterCache" ->
    (FileHash[masterCachePath, "SHA256", "HexString"] ===
      expectedMasterCacheHash),
  "BranchCache" ->
    (FileHash[branchCachePath, "SHA256", "HexString"] ===
      expectedBranchCacheHash)|>;
require[And @@ Values[inputFileChecks],
  "an accepted input identity changed", inputFileChecks];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
masterCacheHashBefore =
  FileHash[masterCachePath, "SHA256", "HexString"];
branchCacheHashBefore =
  FileHash[branchCachePath, "SHA256", "HexString"];

Print["S06_LSZ_STAGE=load corrected S03 and immutable S06 artifacts"];
s03 = Quiet@Check[Get[correctedS03ResultPath], $Failed];
preS06 = Quiet@Check[Get[preS06ResultPath], $Failed];
branchCache = Quiet@Check[Get[branchCachePath], $Failed];

projectorLabels = {"Pg", "PPP"};
laurentPowers = {-2, -1, 0};
inputSchemaChecks = <|
  "CorrectedS03" -> TrueQ[
    AssociationQ[s03] && s03["Stage"] === "HqqV2S03-v2" &&
      s03["ScopeTag"] === scopeTag &&
      s03["Source", "SHA256"] === expectedCorrectedS03SourceHash &&
      AssociationQ[s03["Checks"]] && And @@ Values[s03["Checks"]]],
  "PreS06" -> TrueQ[
    AssociationQ[preS06] && preS06["Stage"] === "HqqV2S06-v1" &&
      preS06["ScopeTag"] === scopeTag &&
      preS06["Source", "SHA256"] === expectedPreS06SourceHash &&
      preS06["Inputs", "S03ResultSHA256"] ===
        expectedPreLSZS03ResultHash &&
      preS06["Inputs", "S04SourceSHA256"] === expectedS04SourceHash &&
      preS06["Inputs", "S04ResultSHA256"] === expectedS04ResultHash &&
      AssociationQ[preS06["Checks"]] &&
      And @@ Values[preS06["Checks"]]],
  "BranchCache" -> TrueQ[
    AssociationQ[branchCache] &&
      branchCache["Stage"] === "HqqV2S06Branch-v1" &&
      branchCache["ScopeTag"] === scopeTag &&
      branchCache["ProducerSourceSHA256"] ===
        expectedBranchProducerHash &&
      branchCache["Inputs", "S03ResultSHA256"] ===
        expectedPreLSZS03ResultHash &&
      branchCache["Inputs", "S04ResultSHA256"] ===
        expectedS04ResultHash &&
      branchCache["Inputs", "MasterCacheSHA256"] ===
        expectedMasterCacheHash &&
      branchCache["ContractSHA256"] === expectedBranchContractHash &&
      branchCache["Projectors"] === projectorLabels &&
      branchCache["LaurentPowers"] === laurentPowers &&
      AssociationQ[branchCache["Checks"]] &&
      And @@ Values[branchCache["Checks"]] &&
      branchCache["ContentSHA256"] ===
        expectedBranchStoredContentHash],
  "PreS06CacheMetadata" -> TrueQ[
    preS06["MasterEvaluation", "CacheSHA256"] ===
        expectedMasterCacheHash &&
      preS06["PostBranchCache", "SHA256"] ===
        expectedBranchCacheHash]|>;
require[And @@ Values[inputSchemaChecks],
  "an accepted input schema or embedded gate failed", inputSchemaChecks];
require[s03["Renormalization", "Scheme"] === "MSbar" &&
    preS06["Renormalization", "Scheme"] === "MSbar",
  "MS-bar convention changed"];

Print["S06_LSZ_STAGE=validate cached pre-LSZ virtual ledger"];
hardPartNormalization =
  preS06["PhaseSpace", "HardPartNormalization"];
invariantMeasure = preS06["PhaseSpace", "InvariantMeasure"];
fractionalMeasure = preS06["PhaseSpace", "FractionalMeasure"];
twoFractionRules = preS06["PhaseSpace", "TwoBodyFractionRules"];
invariantDeltaCases = Cases[invariantMeasure,
  DiracDelta[argument_] :> argument, Infinity];
require[Length[invariantDeltaCases] === 1 &&
    FreeQ[fractionalMeasure, DiracDelta],
  "stored invariant/fractional two-body representation changed"];
invariantMeasurePrefactor = invariantMeasure /. DiracDelta[_] -> 1;
fractionalMeasurePrefactor = fractionalMeasure;

cachedInvariantDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization invariantMeasurePrefactor # &,
    branchCache["Values", projector]]], projectorLabels];
cachedFractionalDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization fractionalMeasurePrefactor
      (# /. twoFractionRules) &,
    branchCache["Values", projector]]], projectorLabels];
cacheReconstructionChecks = AssociationMap[Function[projector,
  SameQ[cachedInvariantDeltaLaurent[projector],
      preS06["VirtualLaurentLedger", projector, "DeltaLaurent"]] &&
    SameQ[cachedFractionalDeltaLaurent[projector],
      preS06["FractionalDeltaLaurent", projector]]], projectorLabels];
require[And @@ Values[cacheReconstructionChecks],
  "immutable branch cache does not reconstruct former S06 ledgers",
  cacheReconstructionChecks];

Print["S06_LSZ_STAGE=one-row on-shell Laurent and Hermitian completion"];
lszDirectedRows = s03["Projected", "ExternalLSZDirectedRows"];
storedLSZCoefficient = s03["Renormalization", "ExternalLSZ",
  "DirectedAmplitudeCoefficient"];
lszRowInventoryChecks = AssociationMap[Function[projector,
  AssociationQ[lszDirectedRows] &&
    Keys[lszDirectedRows] === projectorLabels &&
    Length[lszDirectedRows[projector]] === 1], projectorLabels];
lszBornProportionalChecks = AssociationMap[Function[projector,
  exactZeroQ[First[lszDirectedRows[projector]] -
    storedLSZCoefficient s03["Projected", "Born", projector]]],
  projectorLabels];
require[And @@ Values[lszRowInventoryChecks] &&
    And @@ Values[lszBornProportionalChecks],
  "corrected S03 LSZ-row contract failed"];

twoBodyMassShellRules = massShellRule /@
  s03["Kinematics", "TwoBody", "MassShells"];
lszOnShellRows = AssociationMap[
  (# /. twoBodyMassShellRules) & /@ lszDirectedRows[#] &,
  projectorLabels];
require[FreeQ[lszOnShellRows,
    FeynCalc`Pair | FeynCalc`FeynAmpDenominator |
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe],
  "LSZ row is not closed after the accepted two-body mass shells"];

toPackageXRules = {
  FeynCalc`PaXLn -> X`Ln,
  FeynCalc`PaXDiLog -> X`DiLog,
  FeynCalc`PaXContinuedDiLog -> X`ContinuedDiLog};
fromPackageXRules = {
  X`Ln -> FeynCalc`PaXLn,
  X`DiLog -> FeynCalc`PaXDiLog,
  X`ContinuedDiLog -> FeynCalc`PaXContinuedDiLog};
commonRegulatorRules = {
  D -> 4 - 2 epsilon,
  FeynCalc`EpsilonUV -> epsilon,
  FeynCalc`EpsilonIR -> epsilon};

lszDirectedSeriesRows = AssociationMap[Function[projector,
  Map[Series[# /. commonRegulatorRules /. toPackageXRules,
      {epsilon, 0, 0}] &,
    lszOnShellRows[projector]]], projectorLabels];
lszDirectedLaurentRows = AssociationMap[
  Map[Normal, lszDirectedSeriesRows[#]] &, projectorLabels];
lszDirectedCoefficientRowsX = AssociationMap[Function[projector,
  Map[Function[rowSeries,
    AssociationMap[Function[power,
      SeriesCoefficient[rowSeries, power]], laurentPowers]],
    lszDirectedSeriesRows[projector]]], projectorLabels];
lszLaurentReconstructionChecks = AssociationMap[Function[projector,
  And @@ MapThread[Function[{rowLaurent, rowCoefficients},
    TrueQ[Expand[rowLaurent -
      Total[KeyValueMap[#2 epsilon^#1 &, rowCoefficients]]] === 0]],
    {lszDirectedLaurentRows[projector],
      lszDirectedCoefficientRowsX[projector]}]], projectorLabels];
lszConjugationInvolutionChecks = AssociationMap[Function[projector,
  And @@ Map[Function[rowCoefficients,
    And @@ Map[Function[coefficient,
      TrueQ[packageXConjugate[packageXConjugate[coefficient]] ===
        coefficient]], Values[rowCoefficients]]],
    lszDirectedCoefficientRowsX[projector]]], projectorLabels];
lszHermitianCoefficientRowsX = AssociationMap[Function[projector,
  Map[Function[rowCoefficients,
    AssociationMap[Function[power,
      Expand[rowCoefficients[power] +
        packageXConjugate[rowCoefficients[power]]]], laurentPowers]],
    lszDirectedCoefficientRowsX[projector]]], projectorLabels];
lszHermitianSymmetryChecks = AssociationMap[Function[projector,
  And @@ Map[Function[rowCoefficients,
    And @@ Map[Function[coefficient,
      TrueQ[Expand[coefficient -
        packageXConjugate[coefficient]] === 0]],
      Values[rowCoefficients]]],
    lszHermitianCoefficientRowsX[projector]]], projectorLabels];
lszBranchFreeChecks = AssociationMap[Function[projector,
  FreeQ[lszHermitianCoefficientRowsX[projector],
    X`ContinuedDiLog | X`DiLog | X`Ln]], projectorLabels];
require[And @@ Values[lszLaurentReconstructionChecks] &&
    And @@ Values[lszConjugationInvolutionChecks] &&
    And @@ Values[lszHermitianSymmetryChecks] &&
    And @@ Values[lszBranchFreeChecks],
  "LSZ Laurent or explicit Hermitian gate failed"];

lszHermitianCoefficientLaurent = AssociationMap[Function[projector,
  AssociationMap[Function[power,
    Total[Lookup[lszHermitianCoefficientRowsX[projector], power]]],
    laurentPowers]], projectorLabels] /. fromPackageXRules;
require[FreeQ[lszHermitianCoefficientLaurent,
    epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D |
      FeynCalc`PaXEpsilonBar | X`ContinuedDiLog | X`DiLog | X`Ln |
      ConditionalExpression | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity],
  "LSZ Hermitian Laurent coefficients are not closed exact expressions"];

Print["S06_LSZ_STAGE=two-body normalization and additive cache tail"];
lszInvariantDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization invariantMeasurePrefactor # &,
    lszHermitianCoefficientLaurent[projector]]], projectorLabels];
lszFractionalDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization fractionalMeasurePrefactor
      (# /. twoFractionRules) &,
    lszHermitianCoefficientLaurent[projector]]], projectorLabels];

correctedInvariantDeltaLaurent = AssociationMap[Function[projector,
  AssociationMap[Function[power,
    preS06["VirtualLaurentLedger", projector, "DeltaLaurent", power] +
      lszInvariantDeltaLaurent[projector, power]], laurentPowers]],
  projectorLabels];
correctedFractionalDeltaLaurent = AssociationMap[Function[projector,
  AssociationMap[Function[power,
    preS06["FractionalDeltaLaurent", projector, power] +
      lszFractionalDeltaLaurent[projector, power]], laurentPowers]],
  projectorLabels];
zeroLaurent = AssociationThread[laurentPowers,
  ConstantArray[0, Length[laurentPowers]]];
correctedVirtualLaurentLedger = AssociationMap[Function[projector,
  <|"DeltaLaurent" -> correctedInvariantDeltaLaurent[projector],
    "BoundedPlusLaurent" -> zeroLaurent,
    "OrdinaryLaurent" -> zeroLaurent|>], projectorLabels];

cacheTailAdditionChecks = AssociationMap[Function[projector,
  And @@ Map[Function[power,
    TrueQ[
      correctedInvariantDeltaLaurent[projector, power] -
        preS06["VirtualLaurentLedger", projector,
          "DeltaLaurent", power] -
        lszInvariantDeltaLaurent[projector, power] === 0] &&
    TrueQ[
      correctedFractionalDeltaLaurent[projector, power] -
        preS06["FractionalDeltaLaurent", projector, power] -
        lszFractionalDeltaLaurent[projector, power] === 0]],
    laurentPowers]], projectorLabels];

masterCacheHashAfter =
  FileHash[masterCachePath, "SHA256", "HexString"];
branchCacheHashAfter =
  FileHash[branchCachePath, "SHA256", "HexString"];
checks = <|
  "AcceptedInputHashes" -> And @@ Values[inputFileChecks],
  "InputSchemas" -> And @@ Values[inputSchemaChecks],
  "MSbar" -> (s03["Renormalization", "Scheme"] === "MSbar"),
  "FormerS06ChecksRetained" -> And @@ Values[preS06["Checks"]],
  "ImmutableBranchCacheReconstructsFormerS06" ->
    And @@ Values[cacheReconstructionChecks],
  "LSZRowInventory" -> And @@ Values[lszRowInventoryChecks],
  "LSZRowsBornProportional" ->
    And @@ Values[lszBornProportionalChecks],
  "LSZLaurentReconstructs" ->
    And @@ Values[lszLaurentReconstructionChecks],
  "LSZConjugationInvolution" ->
    And @@ Values[lszConjugationInvolutionChecks],
  "LSZHermitianSymmetry" -> And @@ Values[lszHermitianSymmetryChecks],
  "LSZNeedsNoBranchResolution" -> And @@ Values[lszBranchFreeChecks],
  "ExactCacheTailAddition" -> And @@ Values[cacheTailAdditionChecks],
  "MasterCacheUntouched" ->
    (masterCacheHashBefore === expectedMasterCacheHash &&
      masterCacheHashAfter === masterCacheHashBefore),
  "BranchCacheUntouched" ->
    (branchCacheHashBefore === expectedBranchCacheHash &&
      branchCacheHashAfter === branchCacheHashBefore),
  "OnlyVirtualDeltaSector" -> And @@ Map[
    SameQ[correctedVirtualLaurentLedger[#,
        "BoundedPlusLaurent"], zeroLaurent] &&
      SameQ[correctedVirtualLaurentLedger[#,
        "OrdinaryLaurent"], zeroLaurent] &, projectorLabels],
  "RegulatorsEliminatedFromLedger" -> FreeQ[
    {correctedVirtualLaurentLedger, correctedFractionalDeltaLaurent},
    epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D],
  "ExactSymbolic" -> FreeQ[
    {correctedVirtualLaurentLedger, correctedFractionalDeltaLaurent,
      lszHermitianCoefficientLaurent},
    $Failed | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity]|>;
Print["S06_LSZ_CHECKS=", InputForm[checks]];
require[And @@ Values[checks],
  "one or more corrected S06 gates failed", checks];

result = Join[preS06, <|
  "Stage" -> "HqqV2S06-v2",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "SourceSHA256" -> sourceHash,
  "Inputs" -> <|
    "S03SourceSHA256" -> expectedCorrectedS03SourceHash,
    "S03ResultSHA256" -> expectedCorrectedS03ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "PreLSZS03ResultSHA256" -> expectedPreLSZS03ResultHash,
    "PreLSZS06SourceSHA256" -> expectedPreS06SourceHash,
    "PreLSZS06ResultSHA256" -> expectedPreS06ResultHash|>,
  "Renormalization" -> Join[preS06["Renormalization"], <|
    "ExternalLSZ" -> s03["Renormalization", "ExternalLSZ"]|>],
  "Correction" -> <|
    "Name" -> "ExternalLSZCacheTail",
    "PreLSZS06ResultSHA256" -> expectedPreS06ResultHash,
    "CorrectedS03ResultSHA256" -> expectedCorrectedS03ResultHash,
    "MasterCacheSHA256" -> expectedMasterCacheHash,
    "BranchCacheSHA256" -> expectedBranchCacheHash,
    "MasterCacheReevaluated" -> False,
    "BranchCacheRowsReevaluated" -> False,
    "LSZDirectedAmplitudeCoefficient" -> storedLSZCoefficient,
    "LSZHermitianCoefficientLaurent" ->
      lszHermitianCoefficientLaurent,
    "LSZInvariantDeltaLaurent" -> lszInvariantDeltaLaurent,
    "LSZFractionalDeltaLaurent" -> lszFractionalDeltaLaurent,
    "Checks" -> <|
      "RowInventory" -> lszRowInventoryChecks,
      "BornProportional" -> lszBornProportionalChecks,
      "LaurentReconstruction" -> lszLaurentReconstructionChecks,
      "ConjugationInvolution" -> lszConjugationInvolutionChecks,
      "HermitianSymmetry" -> lszHermitianSymmetryChecks,
      "BranchFree" -> lszBranchFreeChecks,
      "CacheTailAddition" -> cacheTailAdditionChecks|>|>,
  "VirtualLaurentLedger" -> correctedVirtualLaurentLedger,
  "FractionalDeltaLaurent" -> correctedFractionalDeltaLaurent,
  "ParallelPolicy" ->
    "serial cache-only replay on one resolved master-free LSZ row",
  "Checks" -> checks|>];

Print["S06_LSZ_STAGE=atomic corrected result publication"];
atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];
resultReload = Quiet@Check[Get[resultPath], $Failed];
reloadChecks = <|
  "Association" -> AssociationQ[resultReload],
  "Stage" -> Quiet@Check[
    resultReload["Stage"] === "HqqV2S06-v2", False],
  "Scope" -> Quiet@Check[resultReload["ScopeTag"] === scopeTag, False],
  "Source" -> Quiet@Check[
    resultReload["Source", "SHA256"] === sourceHash, False],
  "Checks" -> Quiet@Check[
    AssociationQ[resultReload["Checks"]] &&
      And @@ Values[resultReload["Checks"]], False],
  "NoTemporary" ->
    ! FileExistsQ[resultPath <> ".tmp." <> ToString[$ProcessID]]|>;
Print["S06_LSZ_RELOAD_CHECKS=", InputForm[reloadChecks]];
require[And @@ Values[reloadChecks],
  "same-kernel corrected-result reload failed", reloadChecks];

Print["S06_LSZ_RESULT_SHA256=", resultHash];
Print["S06_LSZ_CACHE_TAIL_RELOAD_OK"];
Print["S06_LSZ_SUCCESS"];
Quit[0];

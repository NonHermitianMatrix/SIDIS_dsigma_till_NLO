(* Hqq_v2 S06: Package-X virtual contribution through the finite term. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {"FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
$FCAdvice = False;

ClearAll[
  fail, require, atomicPut, massShellRule, packageXConjugate,
  resolveHermitianBranches, exactZeroQ, branchCacheContentHash
];

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

fail[message_String, detail_: Null] := (
  Print["S06_FAILURE: ", message];
  If[detail =!= Null, Print["S06_FAILURE_DETAIL=", InputForm[detail]]];
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

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
s03SourcePath = FileNameJoin[{stageDirectory,
  "s03_finalize_uv_recovery.wl"}];
s03ResultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];
s04SourcePath = FileNameJoin[{stageDirectory,
  "s04_integrate_hqq_phase_space.wl"}];
s04ResultPath = FileNameJoin[{stageDirectory, "s04_result.wl"}];
masterCachePath = FileNameJoin[{stageDirectory,
  "s06_master_cache.wl"}];
branchCachePath = FileNameJoin[{stageDirectory,
  "s06_branch_cache.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s06_result.wl"}];

expectedS03SourceHash =
  "379e463f748adae363c693cd39afd4a8dc5420e3a096e98d60c73d9a9afeca0b";
expectedS03ResultHash =
  "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4";
expectedS04SourceHash =
  "ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793";
expectedS04ResultHash =
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c";

require[And @@ Map[FileExistsQ,
    {s03SourcePath, s03ResultPath, s04SourcePath, s04ResultPath}],
  "an accepted S03/S04 input is missing"];
require[FileHash[s03SourcePath, "SHA256", "HexString"] ===
    expectedS03SourceHash &&
  FileHash[s03ResultPath, "SHA256", "HexString"] ===
    expectedS03ResultHash &&
  FileHash[s04SourcePath, "SHA256", "HexString"] ===
    expectedS04SourceHash &&
  FileHash[s04ResultPath, "SHA256", "HexString"] ===
    expectedS04ResultHash,
  "an accepted S03/S04 input hash changed"];
require[! FileExistsQ[resultPath],
  "S06 result target already exists; refusing to overwrite it"];

Print["S06_STAGE=load accepted S03 and S04"];
s03 = Quiet@Check[Get[s03ResultPath], $Failed];
s04 = Quiet@Check[Get[s04ResultPath], $Failed];
require[AssociationQ[s03] && AssociationQ[s04] &&
    s03["Stage"] === "HqqV2S03-v1" &&
    s04["Stage"] === "HqqV2S04-v1" &&
    s03["ScopeTag"] === scopeTag && s04["ScopeTag"] === scopeTag &&
    s03["Source", "SHA256"] === expectedS03SourceHash &&
    s04["Source", "SHA256"] === expectedS04SourceHash &&
    And @@ Values[s03["Checks"]] && And @@ Values[s04["Checks"]],
  "accepted S03/S04 schema or embedded gate failed"];
require[s03["Renormalization", "Scheme"] === "MSbar" &&
    s03["HermitianConvention"] ===
      "all virtual and counterterm projections remain directed M_loop^mu (M_Born^nu)*; Package-X analytic continuation and explicit Hermitian 2 Re are S06",
  "S03 renormalization or directed-interference convention changed"];

projectorLabels = Keys[s03["Projected", "Born"]];
virtualRows = s03["Projected", "VirtualBareDirectedRows"];
virtualTotals = s03["Projected", "VirtualBareDirected"];
countertermTotals = s03["Projected", "CountertermDirected"];
require[projectorLabels === {"Pg", "PPP"} &&
    Keys[virtualRows] === projectorLabels &&
    Keys[virtualTotals] === projectorLabels &&
    Keys[countertermTotals] === projectorLabels,
  "projector or virtual/counterterm schema changed"];
require[And @@ Map[TrueQ[Total[virtualRows[#]] === virtualTotals[#]] &,
    projectorLabels],
  "accepted S03 virtual rows do not reconstruct their totals"];

pvPattern = FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
  FeynCalc`D0 | FeynCalc`PaVe;
scalarMasters = DeleteDuplicates@Cases[
  Flatten[Values[virtualRows]],
  master : (FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe)[___] :> master,
  Infinity];
require[scalarMasters =!= {} &&
    SameQ[scalarMasters, s03["UVLedger", "DistinctMasters"]],
  "tool-derived master inventory differs from accepted S03"];
masterInventoryHash = IntegerString[
  Hash[HoldComplete[scalarMasters], "SHA256"], 16, 64];
masterEvaluationContract = HoldComplete[
  PaXEvaluateUVIRSplit,
  PaXImplicitPrefactor -> 1,
  PaXAnalytic -> True,
  PaXC0Expand -> True,
  PaXD0Expand -> True,
  PaXDiscExpand -> True,
  PaXKallenExpand -> True,
  PaXKibbleExpand -> True,
  PaXExpandInEpsilon -> True,
  PaXSubstituteEpsilon -> True,
  TimeConstrained -> Infinity];
masterEvaluationContractHash = IntegerString[
  Hash[masterEvaluationContract, "SHA256"], 16, 64];
sourceHash = FileHash[sourcePath, "SHA256", "HexString"];

If[FileExistsQ[masterCachePath],
  Print["S06_STAGE=load accepted S06 master cache"];
  masterCache = Quiet@Check[Get[masterCachePath], $Failed];
  require[AssociationQ[masterCache] &&
      masterCache["Stage"] === "HqqV2S06MasterCache-v1" &&
      masterCache["ScopeTag"] === scopeTag &&
      masterCache["Inputs", "S03ResultSHA256"] ===
        expectedS03ResultHash &&
      masterCache["MasterInventorySHA256"] === masterInventoryHash &&
      masterCache["EvaluationContractSHA256"] ===
        masterEvaluationContractHash &&
      SameQ[masterCache["Masters"], scalarMasters] &&
      Length[masterCache["Values"]] === Length[scalarMasters] &&
      And @@ Values[masterCache["Checks"]],
    "existing S06 master cache failed its exact contract"];
  masterValues = masterCache["Values"];
  Print["S06_MASTER_CACHE_ACCEPTED count=", Length[masterValues]],

  Print["S06_STAGE=evaluate distinct masters once count=",
    Length[scalarMasters]];
  masterTags = Array[hqqV2S06MasterTag, Length[scalarMasters]];
  masterBatchInput = Total[MapThread[Times,
    {masterTags, scalarMasters}]];
  masterBatch = CheckAbort[Quiet@Check[
    FeynCalc`PaXEvaluateUVIRSplit[masterBatchInput,
      FeynCalc`PaXImplicitPrefactor -> 1,
      FeynCalc`PaXAnalytic -> True,
      FeynCalc`PaXC0Expand -> True,
      FeynCalc`PaXD0Expand -> True,
      FeynCalc`PaXDiscExpand -> True,
      FeynCalc`PaXKallenExpand -> True,
      FeynCalc`PaXKibbleExpand -> True,
      FeynCalc`PaXExpandInEpsilon -> True,
      FeynCalc`PaXSubstituteEpsilon -> True,
      TimeConstrained -> Infinity], $Failed], $Failed];
  require[masterBatch =!= $Failed && FreeQ[masterBatch,
      pvPattern | FeynCalc`PaXpvA | FeynCalc`PaXpvB |
      FeynCalc`PaXpvC | FeynCalc`PaXpvD | ConditionalExpression |
      FeynCalc`PaXEpsilonBar |
      _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
    "Package-X did not fully and exactly evaluate the master batch"];
  masterValues = Coefficient[Expand[masterBatch], #] & /@ masterTags;
  masterBatchResidual = Expand[masterBatch - Total[MapThread[Times,
    {masterTags, masterValues}]]];
  require[TrueQ[masterBatchResidual === 0] &&
      FreeQ[masterValues, pvPattern | FeynCalc`PaXpvA |
        FeynCalc`PaXpvB | FeynCalc`PaXpvC | FeynCalc`PaXpvD |
        FeynCalc`PaXEpsilonBar | ConditionalExpression | _Real | Indeterminate |
        ComplexInfinity | DirectedInfinity],
    "evaluated master coefficients failed reconstruction or closure"];
  masterCacheChecks = <|
    "MasterListMatchesS03" ->
      SameQ[scalarMasters, s03["UVLedger", "DistinctMasters"]],
    "BatchReconstructs" -> TrueQ[masterBatchResidual === 0],
    "NoUnevaluatedPV" -> FreeQ[masterValues,
      pvPattern | FeynCalc`PaXpvA | FeynCalc`PaXpvB |
      FeynCalc`PaXpvC | FeynCalc`PaXpvD],
    "ExactSymbolic" -> FreeQ[masterValues,
      $Failed | _Real | Indeterminate | ComplexInfinity |
        DirectedInfinity]
  |>;
  require[And @@ Values[masterCacheChecks],
    "master cache gates failed before publication"];
  masterCache = <|
    "Stage" -> "HqqV2S06MasterCache-v1",
    "ScopeTag" -> scopeTag,
    "ProducerSourceSHA256" -> sourceHash,
    "Inputs" -> <|"S03SourceSHA256" -> expectedS03SourceHash,
      "S03ResultSHA256" -> expectedS03ResultHash|>,
    "Runtime" -> <|"Wolfram" -> $Version,
      "FeynCalc" -> FeynCalc`$FeynCalcVersion,
      "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
    "MasterInventorySHA256" -> masterInventoryHash,
    "EvaluationContract" -> masterEvaluationContract,
    "EvaluationContractSHA256" -> masterEvaluationContractHash,
    "Masters" -> scalarMasters,
    "Values" -> masterValues,
    "Checks" -> masterCacheChecks|>;
  atomicPut[masterCache, masterCachePath];
  masterCacheReload = Quiet@Check[Get[masterCachePath], $Failed];
  require[AssociationQ[masterCacheReload] &&
      SameQ[masterCacheReload["Masters"], scalarMasters] &&
      SameQ[masterCacheReload["Values"], masterValues] &&
      And @@ Values[masterCacheReload["Checks"]],
    "fresh S06 master-cache reload failed"];
  Print["S06_MASTER_CACHE_WRITTEN count=", Length[masterValues]]
];
masterCacheHash = FileHash[masterCachePath, "SHA256", "HexString"];
masterRules = Dispatch[Thread[scalarMasters -> masterValues]];
packageXLoadResult = Quiet@Check[
  FeynCalc`PaXEvaluateUVIRSplit[0,
    FeynCalc`PaXImplicitPrefactor -> 1], $Failed];
require[TrueQ[packageXLoadResult === 0] &&
    And @@ (NameQ /@ {"X`Utilities`SimplifyLn",
      "X`Utilities`SimplifyDiLog",
      "X`Utilities`ContinuedDiLogExpand"}),
  "Package-X analytic-continuation utilities did not load"];

Print["S06_STAGE=inherit accepted S03 exact UV gate"];
uvPoleResiduals = s03["UVLedger", "PoleResiduals"];
uvCancellationGates = s03["UVLedger", "CancellationGates"];
require[Keys[uvPoleResiduals] === projectorLabels &&
    Keys[uvCancellationGates] === projectorLabels &&
    And @@ Values[uvCancellationGates] &&
    And @@ Map[exactZeroQ[uvPoleResiduals[#]] &, projectorLabels],
  "accepted S03 exact MS-bar UV ledger failed", uvPoleResiduals];
Scan[Function[projector,
  Print["S06_UV_POLE_RESIDUAL=", projector, " ",
    InputForm[uvPoleResiduals[projector]]]], projectorLabels];

Print["S06_STAGE=substitute cached masters rowwise"];
massShellRule[record_List] := With[
  {momentum = record[[1]], value = record[[2]]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum, D],
    FeynCalc`Momentum[momentum, D]]] :> value];
twoBodyMassShellRules = massShellRule /@
  s03["Kinematics", "TwoBody", "MassShells"];
virtualEvaluatedRows = AssociationMap[
  virtualRows[#] /. twoBodyMassShellRules /. masterRules &,
  projectorLabels];
virtualEvaluated = AssociationMap[
  Total[virtualEvaluatedRows[#]] &,
  projectorLabels];
directedUVRenormalizedRows = AssociationMap[
  Join[virtualEvaluatedRows[#], {countertermTotals[#]}] &,
  projectorLabels];
directedUVRenormalized = AssociationMap[
  Total[directedUVRenormalizedRows[#]] &,
  projectorLabels];
rowwiseMasterSubstitutionGates = AssociationMap[TrueQ[
      virtualEvaluated[#] ===
        (virtualTotals[#] /. twoBodyMassShellRules /. masterRules)] &,
    projectorLabels];
singleCountertermRowGates = AssociationMap[TrueQ[
      Length[directedUVRenormalizedRows[#]] ===
          Length[virtualEvaluatedRows[#]] + 1 &&
        Last[directedUVRenormalizedRows[#]] === countertermTotals[#]] &,
    projectorLabels];
require[And @@ Values[rowwiseMasterSubstitutionGates] &&
    And @@ Values[singleCountertermRowGates],
  "rowwise cached-master substitution did not reconstruct S03 totals"];
require[FreeQ[virtualEvaluatedRows,
    pvPattern | FeynCalc`PaXpvA | FeynCalc`PaXpvB |
      FeynCalc`PaXpvC | FeynCalc`PaXpvD],
  "a PV master survived virtual assembly"];
require[FreeQ[directedUVRenormalizedRows,
    FeynCalc`Pair | _FeynCalc`FeynAmpDenominator],
  "accepted canonical S03 totals became noncanonical after substitution"];

toPackageXRules = {
  FeynCalc`PaXLn -> X`Ln,
  FeynCalc`PaXDiLog -> X`DiLog,
  FeynCalc`PaXContinuedDiLog -> X`ContinuedDiLog};
fromPackageXRules = {
  X`Ln -> FeynCalc`PaXLn,
  X`DiLog -> FeynCalc`PaXDiLog,
  X`ContinuedDiLog -> FeynCalc`PaXContinuedDiLog};
packageXConjugate[expression_] := Module[{answer},
  answer = expression /. {
    X`ContinuedDiLog[{x_, xPrescription_}, {y_, yPrescription_}] :>
      X`ContinuedDiLog[{x, -xPrescription}, {y, -yPrescription}],
    X`DiLog[x_, prescription_] :> X`DiLog[x, -prescription],
    X`Ln[x_, prescription_] :> X`Ln[x, -prescription]};
  answer /. Complex[real_, imaginary_] :>
    Complex[real, -imaginary]
];
resolveHermitianBranches[expression_] := Module[{answer},
  answer = X`Utilities`SimplifyContinuedDiLog[expression];
  answer = X`Utilities`ContinuedDiLogExpand[answer];
  answer = X`Utilities`SimplifyDiLog[answer];
  X`Utilities`SimplifyLn[answer]
];

commonRegulatorRules = {
  D -> 4 - 2 epsilon,
  FeynCalc`EpsilonUV -> epsilon,
  FeynCalc`EpsilonIR -> epsilon};
laurentPowers = {-2, -1, 0};
branchCacheContract = HoldComplete[
  "HqqV2S06Branch-v1",
  "accepted generated virtual rows plus one complete MSbar counterterm row",
  {D -> 4 - 2 epsilon, FeynCalc`EpsilonUV -> epsilon,
    FeynCalc`EpsilonIR -> epsilon},
  Series[#, {epsilon, 0, 0}] &,
  SeriesCoefficient,
  "Package-X prescription conjugate plus directed expression",
  X`Utilities`SimplifyContinuedDiLog,
  X`Utilities`ContinuedDiLogExpand,
  X`Utilities`SimplifyDiLog,
  X`Utilities`SimplifyLn];
branchCacheContractHash = IntegerString[
  Hash[branchCacheContract, "SHA256"], 16, 64];
branchCacheContentHash[values_, gates_] := IntegerString[
  Hash[HoldComplete[values, gates], "SHA256"], 16, 64];
branchCacheAccepted = False;
branchCachePresent = FileExistsQ[branchCachePath];
If[branchCachePresent,
  Print["S06_STAGE=load accepted S06 post-branch cache"];
  branchCacheCandidate = Quiet@Check[Get[branchCachePath], $Failed];
  branchCacheValidation = <|
    "Association" -> AssociationQ[branchCacheCandidate],
    "Stage" -> Quiet@Check[
      branchCacheCandidate["Stage"] === "HqqV2S06Branch-v1", False],
    "Scope" -> Quiet@Check[
      branchCacheCandidate["ScopeTag"] === scopeTag, False],
    "S03Result" -> Quiet@Check[
      branchCacheCandidate["Inputs", "S03ResultSHA256"] ===
        expectedS03ResultHash, False],
    "S04Result" -> Quiet@Check[
      branchCacheCandidate["Inputs", "S04ResultSHA256"] ===
        expectedS04ResultHash, False],
    "MasterCache" -> Quiet@Check[
      branchCacheCandidate["Inputs", "MasterCacheSHA256"] ===
        masterCacheHash, False],
    "Contract" -> Quiet@Check[
      branchCacheCandidate["ContractSHA256"] ===
        branchCacheContractHash, False],
    "Projectors" -> Quiet@Check[
      SameQ[branchCacheCandidate["Projectors"], projectorLabels], False],
    "LaurentPowers" -> Quiet@Check[
      SameQ[branchCacheCandidate["LaurentPowers"], laurentPowers], False],
    "ValuesSchema" -> Quiet@Check[
      AssociationQ[branchCacheCandidate["Values"]] &&
        Keys[branchCacheCandidate["Values"]] === projectorLabels, False],
    "GatesSchema" -> Quiet@Check[
      AssociationQ[branchCacheCandidate["Gates"]], False],
    "Checks" -> Quiet@Check[
      AssociationQ[branchCacheCandidate["Checks"]] &&
        And @@ Values[branchCacheCandidate["Checks"]], False],
    "ContentHash" -> Quiet@Check[
      branchCacheCandidate["ContentSHA256"] ===
        branchCacheContentHash[branchCacheCandidate["Values"],
          branchCacheCandidate["Gates"]], False],
    "ClosedExact" -> Quiet@Check[
      FreeQ[branchCacheCandidate["Values"],
        epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D |
          FeynCalc`PaXEpsilonBar | pvPattern | FeynCalc`PaXpvA |
          FeynCalc`PaXpvB | FeynCalc`PaXpvC | FeynCalc`PaXpvD |
          X`ContinuedDiLog | X`DiLog | X`Ln |
          ConditionalExpression | _Real | Indeterminate |
          ComplexInfinity | DirectedInfinity], False]|>;
  branchCacheNonContentAccepted = And @@ Values[
    KeyDrop[branchCacheValidation, {"ContentHash"}]];
  If[TrueQ[branchCacheNonContentAccepted] &&
      ! TrueQ[branchCacheValidation["ContentHash"]],
    Print["S06_BRANCH_CACHE_CANONICALIZE_CONTENT_HASH"];
    branchCacheCandidate["ContentSHA256"] =
      branchCacheContentHash[branchCacheCandidate["Values"],
        branchCacheCandidate["Gates"]];
    atomicPut[branchCacheCandidate, branchCachePath];
    branchCacheCandidate = Quiet@Check[Get[branchCachePath], $Failed];
    branchCacheValidation["Association"] =
      AssociationQ[branchCacheCandidate];
    branchCacheValidation["ContentHash"] = Quiet@Check[
      branchCacheCandidate["ContentSHA256"] ===
        branchCacheContentHash[branchCacheCandidate["Values"],
          branchCacheCandidate["Gates"]], False];
  ];
  branchCacheAccepted = And @@ Values[branchCacheValidation];
  If[! TrueQ[branchCacheAccepted],
    Print["S06_BRANCH_CACHE_VALIDATION=",
      InputForm[branchCacheValidation]]];
];
require[! branchCachePresent || branchCacheAccepted,
  "existing post-branch cache failed validation; refusing row recomputation"];
If[branchCacheAccepted,
  branchCache = branchCacheCandidate;
  hermitianCoefficientLaurent = branchCache["Values"];
  laurentReconstructionGates =
    branchCache["Gates", "LaurentReconstruction"];
  conjugationInvolutionGates =
    branchCache["Gates", "ConjugationInvolution"];
  hermitianSymmetryGates =
    branchCache["Gates", "HermitianSymmetry"];
  Print["S06_BRANCH_CACHE_ACCEPTED rows=",
    Total[Length /@ Values[directedUVRenormalizedRows]]],
  Print["S06_STAGE=common regulator and explicit Hermitian sum"];
  directedSeriesRows = AssociationMap[Function[projector,
    MapIndexed[Function[{row, index},
      Print["S06_LAURENT_ROW=", projector, "/", First[index], "/",
        Length[directedUVRenormalizedRows[projector]]];
      Series[
        row /. commonRegulatorRules /. toPackageXRules,
        {epsilon, 0, 0}]],
      directedUVRenormalizedRows[projector]]], projectorLabels];
  directedLaurentRows = AssociationMap[
    Map[Normal, directedSeriesRows[#]] &, projectorLabels];
  directedCoefficientLaurentRowsX = AssociationMap[Function[projector,
    Map[Function[rowSeries,
      AssociationMap[Function[power,
        SeriesCoefficient[rowSeries, power]], laurentPowers]],
      directedSeriesRows[projector]]], projectorLabels];
  laurentReconstructionGates = AssociationMap[Function[projector,
    And @@ MapThread[Function[{rowLaurent, rowCoefficients},
      TrueQ[Expand[rowLaurent -
        Total[KeyValueMap[#2 epsilon^#1 &, rowCoefficients]]] === 0]],
      {directedLaurentRows[projector],
        directedCoefficientLaurentRowsX[projector]}]], projectorLabels];
  require[And @@ Values[laurentReconstructionGates],
    "rowwise Laurent powers do not reconstruct the finite series"];
  conjugationInvolutionGates = AssociationMap[Function[projector,
    And @@ Map[Function[rowCoefficients,
      And @@ Map[Function[coefficient,
        TrueQ[packageXConjugate[packageXConjugate[coefficient]] ===
          coefficient]], Values[rowCoefficients]]],
      directedCoefficientLaurentRowsX[projector]]], projectorLabels];
  hermitianCoefficientLaurentRawRowsX = AssociationMap[
    Function[projector,
      Map[Function[rowCoefficients,
        AssociationMap[Function[power,
          Expand[rowCoefficients[power] +
            packageXConjugate[rowCoefficients[power]]]], laurentPowers]],
        directedCoefficientLaurentRowsX[projector]]], projectorLabels];
  hermitianSymmetryGates = AssociationMap[Function[projector,
    And @@ Map[Function[rowCoefficients,
      And @@ Map[Function[coefficient,
        TrueQ[Expand[coefficient - packageXConjugate[coefficient]] === 0]],
        Values[rowCoefficients]]],
      hermitianCoefficientLaurentRawRowsX[projector]]], projectorLabels];
  require[And @@ Values[conjugationInvolutionGates] &&
      And @@ Values[hermitianSymmetryGates],
    "explicit rowwise Package-X Hermitian construction failed"];
  hermitianCoefficientLaurentRowsX = AssociationMap[Function[projector,
    MapIndexed[Function[{rowCoefficients, index},
      AssociationMap[Function[power,
        Print["S06_BRANCH_RESOLVE=", projector, "/", power, "/row-",
          First[index], "/",
          Length[hermitianCoefficientLaurentRawRowsX[projector]]];
        resolveHermitianBranches[rowCoefficients[power]]],
        laurentPowers]],
      hermitianCoefficientLaurentRawRowsX[projector]]], projectorLabels];
  hermitianCoefficientLaurentX = AssociationMap[Function[projector,
    AssociationMap[Function[power,
      Total[Lookup[hermitianCoefficientLaurentRowsX[projector], power]]],
      laurentPowers]], projectorLabels];
  hermitianCoefficientLaurent = hermitianCoefficientLaurentX /.
    fromPackageXRules;
  require[FreeQ[hermitianCoefficientLaurent,
      epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D |
        FeynCalc`PaXEpsilonBar |
        pvPattern | FeynCalc`PaXpvA | FeynCalc`PaXpvB |
        FeynCalc`PaXpvC | FeynCalc`PaXpvD | X`ContinuedDiLog |
        X`DiLog | X`Ln | ConditionalExpression | _Real |
        Indeterminate | ComplexInfinity | DirectedInfinity],
    "Hermitian Laurent coefficients are not closed exact expressions"];
  branchGateLedger = <|
    "LaurentReconstruction" -> laurentReconstructionGates,
    "ConjugationInvolution" -> conjugationInvolutionGates,
    "HermitianSymmetry" -> hermitianSymmetryGates|>;
  branchCacheChecks = <|
    "AcceptedInputs" -> True,
    "MasterCache" -> True,
    "Contract" -> True,
    "Projectors" -> (Keys[hermitianCoefficientLaurent] ===
      projectorLabels),
    "LaurentPowers" -> And @@ Map[
      Keys[hermitianCoefficientLaurent[#]] === laurentPowers &,
      projectorLabels],
    "AllRowGates" -> And @@ Flatten[
      Values /@ Values[branchGateLedger]],
    "ClosedExact" -> FreeQ[hermitianCoefficientLaurent,
      epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D |
        FeynCalc`PaXEpsilonBar | pvPattern | FeynCalc`PaXpvA |
        FeynCalc`PaXpvB | FeynCalc`PaXpvC | FeynCalc`PaXpvD |
        X`ContinuedDiLog | X`DiLog | X`Ln | ConditionalExpression |
        _Real | Indeterminate | ComplexInfinity | DirectedInfinity]|>;
  require[And @@ Values[branchCacheChecks],
    "post-branch cache gate failed", branchCacheChecks];
  branchCache = <|
    "Stage" -> "HqqV2S06Branch-v1",
    "ScopeTag" -> scopeTag,
    "ProducerSourceSHA256" -> sourceHash,
    "Inputs" -> <|
      "S03ResultSHA256" -> expectedS03ResultHash,
      "S04ResultSHA256" -> expectedS04ResultHash,
      "MasterCacheSHA256" -> masterCacheHash|>,
    "ContractSHA256" -> branchCacheContractHash,
    "Projectors" -> projectorLabels,
    "LaurentPowers" -> laurentPowers,
    "Values" -> hermitianCoefficientLaurent,
    "Gates" -> branchGateLedger,
    "ContentSHA256" -> branchCacheContentHash[
      hermitianCoefficientLaurent, branchGateLedger],
    "Checks" -> branchCacheChecks|>;
  atomicPut[branchCache, branchCachePath];
  branchCacheReload = $Failed;
  Do[
    branchCacheReload = Quiet@Check[Get[branchCachePath], $Failed];
    If[AssociationQ[branchCacheReload] &&
        And @@ Values[branchCacheReload["Checks"]],
      branchCacheCanonicalHash = branchCacheContentHash[
        branchCacheReload["Values"], branchCacheReload["Gates"]];
      If[branchCacheReload["ContentSHA256"] =!=
          branchCacheCanonicalHash,
        branchCacheReload["ContentSHA256"] =
          branchCacheCanonicalHash;
        atomicPut[branchCacheReload, branchCachePath];
        Pause[2],
        Break[]]];
    Pause[2],
    {5}];
  require[AssociationQ[branchCacheReload] &&
      branchCacheReload["ContentSHA256"] ===
        branchCacheContentHash[branchCacheReload["Values"],
          branchCacheReload["Gates"]] &&
      And @@ Values[branchCacheReload["Checks"]],
    "fresh post-branch cache reload failed"];
  Print["S06_BRANCH_CACHE_WRITTEN rows=",
    Total[Length /@ Values[directedUVRenormalizedRows]]]
];
branchCacheHash = FileHash[branchCachePath, "SHA256", "HexString"];

hardPartNormalization =
  s04["Conventions", "HardPartNormalization"];
invariantMeasure = s04["PhaseSpace", "TwoBody", "InvariantMeasure"];
fractionalMeasure = s04["PhaseSpace", "TwoBody", "FractionalMeasure"];
invariantDeltaCases = Cases[invariantMeasure,
  DiracDelta[argument_] :> argument, Infinity];
require[Length[invariantDeltaCases] === 1 &&
    FreeQ[fractionalMeasure, DiracDelta],
  "stored S04 invariant/fractional measure representation changed"];
invariantDeltaConstraint = First[invariantDeltaCases];
fractionalDeltaConstraint =
  s04["PhaseSpace", "TwoBody", "DeltaConstraint"];
invariantMeasurePrefactor = invariantMeasure /.
  DiracDelta[_] -> 1;
fractionalMeasurePrefactor = fractionalMeasure;
fractionDefinitions = s04["VariableMap", "Definitions"];
twoFractionRules = Thread[{sHat, tHat, uHat} ->
  Lookup[fractionDefinitions, {"sHat", "t1", "u1"}]];
fractionRecoilMapGate = exactZeroQ[
  (invariantDeltaConstraint /. twoFractionRules) -
    s04["PhaseSpace", "TwoBody", "FractionalRecoilVirtuality"]];
fractionDeltaScaleGate = exactZeroQ[
  s04["PhaseSpace", "TwoBody", "FractionalRecoilVirtuality"] -
    s04["PhaseSpace", "TwoBody", "DeltaScale"]
      fractionalDeltaConstraint];
fractionMapGate = fractionRecoilMapGate && fractionDeltaScaleGate;
require[TrueQ[fractionMapGate],
  "stored S04 two-body fractional map does not reconstruct"];

invariantDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization invariantMeasurePrefactor # &,
    hermitianCoefficientLaurent[projector]]], projectorLabels];
fractionalDeltaLaurent = AssociationMap[Function[projector,
  Map[hardPartNormalization fractionalMeasurePrefactor
      (# /. twoFractionRules) &,
    hermitianCoefficientLaurent[projector]]], projectorLabels];
zeroLaurent = AssociationThread[laurentPowers,
  ConstantArray[0, Length[laurentPowers]]];
virtualLaurentLedger = AssociationMap[Function[projector,
  <|"DeltaLaurent" -> invariantDeltaLaurent[projector],
    "BoundedPlusLaurent" -> zeroLaurent,
    "OrdinaryLaurent" -> zeroLaurent|>], projectorLabels];

checks = <|
  "AcceptedInputHashes" ->
    (FileHash[s03SourcePath, "SHA256", "HexString"] ===
        expectedS03SourceHash &&
      FileHash[s03ResultPath, "SHA256", "HexString"] ===
        expectedS03ResultHash &&
      FileHash[s04SourcePath, "SHA256", "HexString"] ===
        expectedS04SourceHash &&
      FileHash[s04ResultPath, "SHA256", "HexString"] ===
        expectedS04ResultHash),
  "InputSchemas" ->
    (s03["Stage"] === "HqqV2S03-v1" &&
      s04["Stage"] === "HqqV2S04-v1"),
  "MSbar" -> (s03["Renormalization", "Scheme"] === "MSbar"),
  "MasterInventoryMatchesS03" ->
    SameQ[scalarMasters, s03["UVLedger", "DistinctMasters"]],
  "MasterCacheAccepted" -> And @@ Values[masterCache["Checks"]],
  "BranchCacheAccepted" -> And @@ Values[branchCache["Checks"]],
  "RowwiseMasterSubstitution" ->
    And @@ Values[rowwiseMasterSubstitutionGates],
  "SingleCountertermRow" -> And @@ Values[singleCountertermRowGates],
  "NoUnevaluatedPV" -> FreeQ[
    {masterValues, virtualEvaluated, hermitianCoefficientLaurent},
    pvPattern | FeynCalc`PaXpvA | FeynCalc`PaXpvB |
      FeynCalc`PaXpvC | FeynCalc`PaXpvD],
  "ExactUVCancellation" -> And @@ Values[uvCancellationGates],
  "ConjugationInvolution" ->
    And @@ Values[conjugationInvolutionGates],
  "ExplicitHermitianSymmetry" ->
    And @@ Values[hermitianSymmetryGates],
  "LaurentReconstructs" ->
    And @@ Values[laurentReconstructionGates],
  "TwoBodyFractionMap" -> fractionMapGate,
  "OnlyVirtualDeltaSector" -> And @@ Map[
    SameQ[virtualLaurentLedger[#, "BoundedPlusLaurent"], zeroLaurent] &&
      SameQ[virtualLaurentLedger[#, "OrdinaryLaurent"], zeroLaurent] &,
    projectorLabels],
  "RegulatorsEliminatedFromLedger" -> FreeQ[
    {virtualLaurentLedger, fractionalDeltaLaurent},
    epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | D],
  "ExactSymbolic" -> FreeQ[
    {virtualLaurentLedger, fractionalDeltaLaurent, uvPoleResiduals},
    $Failed | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity]
|>;
Print["S06_CHECKS=", InputForm[checks]];
require[And @@ Values[checks],
  "one or more final S06 gates failed", checks];

result = <|
  "Stage" -> "HqqV2S06-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|
    "S03SourceSHA256" -> expectedS03SourceHash,
    "S03ResultSHA256" -> expectedS03ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash|>,
  "Runtime" -> <|"Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
  "Renormalization" -> <|
    "Scheme" -> s03["Renormalization", "Scheme"],
    "SEpsilon" -> s03["Renormalization", "SEpsilon"],
    "PoleFactor" -> s03["Renormalization", "PoleFactor"],
    "UVPoleResiduals" -> uvPoleResiduals,
    "UVCancellationGates" -> uvCancellationGates|>,
  "MasterEvaluation" -> <|
    "DistinctCount" -> Length[scalarMasters],
    "InventorySHA256" -> masterInventoryHash,
    "ContractSHA256" -> masterEvaluationContractHash,
    "CachePath" -> masterCachePath,
    "CacheSHA256" -> masterCacheHash|>,
  "PostBranchCache" -> <|
    "ContractSHA256" -> branchCacheContractHash,
    "Path" -> branchCachePath,
    "SHA256" -> branchCacheHash|>,
  "AnalyticContinuation" -> <|
    "Evaluator" -> "FeynHelpers PaXEvaluateUVIRSplit / Package-X",
    "ImplicitPrefactor" -> 1,
    "HermitianOperation" ->
      "directed expression plus exact Package-X prescription conjugate",
    "PackageXUtilities" -> {"SimplifyContinuedDiLog",
      "ContinuedDiLogExpand", "SimplifyDiLog", "SimplifyLn"},
    "PaperBoundary" -> "Appendix E, Eqs. (E1), (E7), and (E8)"|>,
  "PhaseSpace" -> <|
    "HardPartNormalization" -> hardPartNormalization,
    "InvariantDeltaConstraint" -> invariantDeltaConstraint,
    "FractionalDeltaConstraint" -> fractionalDeltaConstraint,
    "InvariantMeasure" -> invariantMeasure,
    "FractionalMeasure" -> fractionalMeasure,
    "TwoBodyFractionRules" -> twoFractionRules|>,
  "VirtualLaurentLedger" -> virtualLaurentLedger,
  "FractionalDeltaLaurent" -> fractionalDeltaLaurent,
  "ParallelPolicy" ->
    "serial tagged Package-X batch: one stateful Package-X session evaluates every distinct master once",
  "Checks" -> checks|>;

Print["S06_STAGE=atomic result publication"];
atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];

kernelExecutable = First[$CommandLine];
validatorCode = StringJoin[
  "$HistoryLength=0;r=Get[", ToString[resultPath, InputForm], "];",
  "ok=AssociationQ[r]&&r[\"Stage\"]===\"HqqV2S06-v1\"&&",
  "r[\"ScopeTag\"]===", ToString[scopeTag, InputForm], "&&",
  "r[\"Source\",\"SHA256\"]===", ToString[sourceHash, InputForm],
  "&&And@@Values[r[\"Checks\"]]&&",
  "And@@Values[r[\"Renormalization\",\"UVCancellationGates\"]];",
  "If[TrueQ[ok],Print[\"S06_FRESH_RELOAD_OK\"];Quit[0],",
  "Print[\"S06_FRESH_RELOAD_FAILURE\"];Quit[1]]"];
validator = RunProcess[
  {kernelExecutable, "-noinit", "-noprompt", "-run", validatorCode},
  {"ExitCode", "StandardOutput", "StandardError"}];
If[StringLength[validator["StandardOutput"]] > 0,
  Print[validator["StandardOutput"]]];
If[StringLength[validator["StandardError"]] > 0,
  Print[validator["StandardError"]]];
require[validator["ExitCode"] === 0 &&
    StringContainsQ[validator["StandardOutput"],
      "S06_FRESH_RELOAD_OK"],
  "fresh-kernel S06 result validation failed"];

Print["S06_SOURCE_SHA256=", sourceHash];
Print["S06_MASTER_CACHE_SHA256=", masterCacheHash];
Print["S06_RESULT_SHA256=", resultHash];
Print["S06_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S06_SUCCESS"];
Quit[0];

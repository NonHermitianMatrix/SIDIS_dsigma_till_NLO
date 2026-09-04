(* Hqq_v2 S07: validate and publish the accepted finite checkpoint. *)

ClearAll["Global`*"];
$HistoryLength = 0;
$IterationLimit = Infinity;

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[fail, require, hashMatches, atomicPut, badSymbolicQ];
fail[message_String, detail_: Null] := (
  Print["S07_FINALIZE_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_FINALIZE_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
hashMatches[path_String, expected_String] :=
  FileExistsQ[path] &&
    FileHash[path, "SHA256", "HexString"] === expected;
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    fail["failed to write temporary S07 result"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary S07 result is missing or empty"];
  RenameFile[temporary, path];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published S07 result is missing or empty"];
];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity | Cancel | Together];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
sourceHash = FileHash[sourcePath, "SHA256", "HexString"];

finiteCachePath = FileNameJoin[{stageDirectory,
  "s07_finite_projected_actions_cache.wl"}];
s03Path = FileNameJoin[{stageDirectory, "s03_result.wl"}];
s05Path = FileNameJoin[{stageDirectory, "s05_result.wl"}];
s05ValidationPath = FileNameJoin[{stageDirectory,
  "s05_endpoint_correction_validation_result.wl"}];
s06Path = FileNameJoin[{stageDirectory, "s06_result.wl"}];
s06RouteValidationPath = FileNameJoin[{stageDirectory,
  "s06_packagex_pave_normalization_route_validation_result.wl"}];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected.wl"}];
factorizationValidationPath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected_validation_result.wl"}];
plusDiagnosticPath = FileNameJoin[{stageDirectory,
  "s07_bounded_plus_endpoint_diagnostic_result.wl"}];
ordinaryDiagnosticPath = FileNameJoin[{stageDirectory,
  "s07_ordinary_endpoint_subtraction_diagnostic_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s07_result.wl"}];

expectedFiniteCacheHash =
  "8118047f56686a4032efcc00944508b09cd230b43379f236951a4b732e0b4a96";
expectedFiniteProducerHash =
  "2871fb493112d7d030e7a10cdc4aa3071ee9ded1db785405d8ad2d434f2641f9";
expectedS03Hash =
  "b3d483dea534ed26b93e601c28788b6c5797a200bb04e72c913b1c0c6c69ab80";
expectedS05Hash =
  "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb";
expectedS05ValidationHash =
  "d04413b87ee94452fe0d854c1530483129717096d55b369a8707c48ee5195a01";
expectedS06Hash =
  "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979";
expectedS06RouteValidationHash =
  "155f2f71078fcea2f5b9384ce7cfbfe4333195263168caa96d533b1e8e5ca339";
expectedFactorizationCacheHash =
  "4b5538d1b8bf89c7ff94b45ad79458f9d8c3a6c42f6b6aa637b0529bc7ffcdef";
expectedFactorizationValidationHash =
  "5d7903c932e20e25ff9cc1771ccbd1087d44be49ffd2f06643356d768681adbf";
expectedPlusDiagnosticHash =
  "ebe5fcfb59a9320610d8efa07d24c636575f42fa335762e5a4a118dd128dc8bf";
expectedOrdinaryDiagnosticHash =
  "cc9368de2a72575f1891e0b6b39902851919d2b96ee99341647c1be365895b8b";

acceptedPathsAndHashes = <|
  "FiniteProjectedActionsCache" ->
    {finiteCachePath, expectedFiniteCacheHash},
  "S03Result" -> {s03Path, expectedS03Hash},
  "S05Result" -> {s05Path, expectedS05Hash},
  "S05Validation" ->
    {s05ValidationPath, expectedS05ValidationHash},
  "S06Result" -> {s06Path, expectedS06Hash},
  "S06NormalizationRouteValidation" ->
    {s06RouteValidationPath, expectedS06RouteValidationHash},
  "FactorizationCache" ->
    {factorizationCachePath, expectedFactorizationCacheHash},
  "FactorizationValidation" ->
    {factorizationValidationPath, expectedFactorizationValidationHash},
  "BoundedPlusDiagnostic" ->
    {plusDiagnosticPath, expectedPlusDiagnosticHash},
  "OrdinaryDiagnostic" ->
    {ordinaryDiagnosticPath, expectedOrdinaryDiagnosticHash}|>;
inputIdentityChecks = Map[
  hashMatches[#[[1]], #[[2]]] &,
  acceptedPathsAndHashes];

validationMode =
  Environment["HQQV2_S07_FINALIZE_VALIDATE_ONLY"] === "1";
If[validationMode,
  Print["S07_FINALIZE_STAGE=fresh result validation"];
  candidate = Quiet@Check[Get[resultPath], $Failed];
  validationChecks = <|
    "AcceptedInputHashes" -> And @@ Values[inputIdentityChecks],
    "Association" -> AssociationQ[candidate],
    "StageScope" -> TrueQ[AssociationQ[candidate] &&
      candidate["Stage"] === "HqqV2S07-v8" &&
      candidate["ScopeTag"] === scopeTag],
    "Source" -> TrueQ[AssociationQ[candidate] &&
      candidate["Source", "SHA256"] === sourceHash],
    "Inputs" -> TrueQ[AssociationQ[candidate] &&
      candidate["Inputs", "FiniteProjectedActionsCacheSHA256"] ===
        expectedFiniteCacheHash &&
      candidate["Inputs", "S06ResultSHA256"] === expectedS06Hash &&
      candidate["Inputs", "S06NormalizationRouteValidationSHA256"] ===
        expectedS06RouteValidationHash],
    "StoredChecks" -> TrueQ[AssociationQ[candidate] &&
      AssociationQ[candidate["Checks"]] &&
      And @@ Values[candidate["Checks"]]],
    "PoleResiduals" -> TrueQ[AssociationQ[candidate] &&
      candidate["PoleResidualList"] =!= {} &&
      And @@ (SameQ[#, 0] & /@ candidate["PoleResidualList"])],
    "ProjectedActions" -> TrueQ[AssociationQ[candidate] &&
      Keys[candidate["FiniteProjectedActions"]] === {"Pg", "PPP"} &&
      And @@ (Keys[#] === {"Delta", "BoundedPlus", "Ordinary"} & /@
        Values[candidate["FiniteProjectedActions"]])],
    "NoTemporary" ->
      FileNames["s07_result.wl.tmp.*", stageDirectory] === {}|>;
  Print["S07_FINALIZE_FRESH_CHECKS=", InputForm[validationChecks]];
  If[And @@ Values[validationChecks],
    Print["S07_FINALIZE_FRESH_RELOAD_OK"];
    Print["S07_RESULT_SHA256=",
      FileHash[resultPath, "SHA256", "HexString"]];
    Quit[0],
    Print["S07_FINALIZE_FRESH_RELOAD_FAILURE"];
    Quit[1]
  ]
];

require[And @@ Values[inputIdentityChecks],
  "accepted input identity mismatch", inputIdentityChecks];
require[! FileExistsQ[resultPath],
  "S07 result already exists; refusing overwrite"];

Print["S07_FINALIZE_STAGE=load immutable checkpoint and route verdict"];
finiteCache = Quiet@Check[Get[finiteCachePath], $Failed];
routeValidation = Quiet@Check[Get[s06RouteValidationPath], $Failed];

expectedCheckpointInputs = <|
  "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
  "FactorizationValidationResultSHA256" ->
    expectedFactorizationValidationHash,
  "S05ResultSHA256" -> expectedS05Hash,
  "S05ValidationResultSHA256" -> expectedS05ValidationHash,
  "S06ResultSHA256" -> expectedS06Hash,
  "PlusDiagnosticResultSHA256" -> expectedPlusDiagnosticHash,
  "OrdinaryDiagnosticResultSHA256" -> expectedOrdinaryDiagnosticHash|>;
componentOrder = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime", "Virtual", "Factorization"};
projectors = {"Pg", "PPP"};
sectors = {"Delta", "BoundedPlus", "Ordinary"};
polePowers = {-2, -1};

schemaChecks = <|
  "CheckpointAssociation" -> AssociationQ[finiteCache],
  "CheckpointStageScope" -> TrueQ[AssociationQ[finiteCache] &&
    finiteCache["Stage"] ===
      "HqqV2S07FiniteProjectedActionsCache-v1" &&
    finiteCache["ScopeTag"] === scopeTag],
  "CheckpointProducer" -> TrueQ[AssociationQ[finiteCache] &&
    finiteCache["Producer", "SHA256"] === expectedFiniteProducerHash],
  "CheckpointInputs" -> TrueQ[AssociationQ[finiteCache] &&
    finiteCache["Inputs"] === expectedCheckpointInputs],
  "CheckpointStoredChecks" -> TrueQ[AssociationQ[finiteCache] &&
    AssociationQ[finiteCache["Checks"]] &&
    And @@ Values[finiteCache["Checks"]]],
  "RouteValidationAssociation" -> AssociationQ[routeValidation],
  "RouteValidationStageScope" -> TrueQ[AssociationQ[routeValidation] &&
    routeValidation["Stage"] ===
      "HqqV2S06PackageXPaVeNormalizationRouteValidation-v1" &&
    routeValidation["ScopeTag"] === scopeTag],
  "RouteValidationStoredChecks" -> TrueQ[
    AssociationQ[routeValidation] &&
    AssociationQ[routeValidation["Checks"]] &&
    And @@ Values[routeValidation["Checks"]]],
  "RouteValidationSelectedUnity" -> TrueQ[
    AssociationQ[routeValidation] &&
    routeValidation["SelectedCandidate"] === "S06-v2-unity" &&
    TrueQ[routeValidation["CandidateSelections", "S06-v2-unity"]] &&
    ! TrueQ[routeValidation[
      "CandidateSelections", "S06-v3-converted"]] &&
    routeValidation["Correction", "RestoreCandidateSHA256"] ===
      expectedS06Hash &&
    routeValidation["Correction", "MasterReevaluationRequired"] ===
      False]|>;
require[And @@ Values[schemaChecks],
  "checkpoint or route schema failed", schemaChecks];

finiteComponents = finiteCache["FiniteComponents"];
finiteActions = finiteCache["FiniteProjectedActions"];
poleResidualList = finiteCache["PoleResidualList"];
rebuiltPoleResidualList = Flatten@Table[
  finiteCache["PoleResiduals", projector, sector, power],
  {projector, projectors}, {sector, sectors}, {power, polePowers}];

contentChecks = <|
  "ComponentOrder" -> finiteCache["ComponentOrder"] === componentOrder,
  "ComponentSchema" ->
    Keys[finiteComponents] === projectors &&
    And @@ Flatten@Table[
      Keys[finiteComponents[projector, sector]] === componentOrder,
      {projector, projectors}, {sector, sectors}],
  "ActionSchema" ->
    Keys[finiteActions] === projectors &&
    And @@ (Keys[#] === sectors & /@ Values[finiteActions]),
  "ActionsMatchCombinationMetadata" -> And @@ Flatten@Table[
    SameQ[finiteActions[projector, sector],
      finiteCache["FiniteCombinationMetadata", projector, sector,
        "Expression"]],
    {projector, projectors}, {sector, sectors}],
  "PoleListReconstructed" ->
    SameQ[poleResidualList, rebuiltPoleResidualList],
  "EveryDoubleAndSinglePoleZero" ->
    poleResidualList =!= {} &&
      And @@ (SameQ[#, 0] & /@ poleResidualList),
  "MSbarLogBasisCanonical" ->
    finiteCache["NoncanonicalPiLogAtoms"] === {},
  "FiniteExact" ->
    ! badSymbolicQ[{finiteComponents, finiteActions}] &&
    FreeQ[{finiteComponents, finiteActions},
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs]|>;
require[And @@ Values[contentChecks],
  "finite checkpoint content failed", contentChecks];

checks = <|
  "AcceptedInputHashes" -> And @@ Values[inputIdentityChecks],
  "AcceptedInputSchemas" -> And @@ Values[schemaChecks],
  "CheckpointContentClosure" -> And @@ Values[contentChecks],
  "UnityPaVeRouteSelected" ->
    schemaChecks["RouteValidationSelectedUnity"],
  "EveryDoubleAndSinglePoleZero" ->
    contentChecks["EveryDoubleAndSinglePoleZero"],
  "FiniteProjectorSchema" -> contentChecks["ActionSchema"],
  "MSbarLogBasisCanonical" ->
    contentChecks["MSbarLogBasisCanonical"],
  "FiniteExact" -> contentChecks["FiniteExact"]|>;
Print["S07_FINALIZE_CHECKS=", InputForm[checks]];
require[And @@ Values[checks], "S07 final gates failed", checks];

result = <|
  "Stage" -> "HqqV2S07-v8",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> Join[expectedCheckpointInputs, <|
    "FiniteProjectedActionsCacheSHA256" -> expectedFiniteCacheHash,
    "FiniteProjectedActionsProducerSHA256" ->
      expectedFiniteProducerHash,
    "S03ResultSHA256" -> expectedS03Hash,
    "S06NormalizationRouteValidationSHA256" ->
      expectedS06RouteValidationHash|>],
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "ParallelPolicy" ->
      "serial structural validation and publication of immutable cached actions"|>,
  "Conventions" -> <|
    "RenormalizationScheme" -> "MSbar",
    "VirtualMasterNormalization" -> <|
      "SelectedCandidate" -> routeValidation["SelectedCandidate"],
      "ImplicitPrefactor" ->
        routeValidation["Route", "V2ImplicitPrefactor"]|>,
    "FinalSchemeValidationBoundary" ->
      "S08 derives Eq. (9) weights and validates F1Hat/F2Hat against S03 SEpsilon"|>,
  "CheckpointValidation" -> <|
    "InputIdentityChecks" -> inputIdentityChecks,
    "SchemaChecks" -> schemaChecks,
    "ContentChecks" -> contentChecks|>,
  "PoleLedger" -> <|
    "Residuals" -> finiteCache["PoleResiduals"]|>,
  "PoleResidualList" -> poleResidualList,
  "FiniteProjectedActions" -> finiteActions,
  "DownstreamBoundary" ->
    "S08 derives Eq. (9) weights with Wolfram and applies them only to these finite Pg/PPP actions",
  "Checks" -> checks|>;

Print["S07_FINALIZE_STAGE=atomic S07 result publication"];
atomicPut[result, resultPath];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, result] &&
    AssociationQ[reloaded["Checks"]] &&
    And @@ Values[reloaded["Checks"]],
  "same-kernel S07 result reload failed"];
Print["S07_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_RESULT_READY"];
Quit[0];

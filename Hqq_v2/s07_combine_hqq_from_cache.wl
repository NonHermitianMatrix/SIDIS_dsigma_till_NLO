(* Hqq_v2 S07: cache-only MS-bar pole combination and finite actions. *)

$HistoryLength = 0;
$IterationLimit = Infinity;

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[fail, require, atomicPut, exactZeroQ, badSymbolicQ,
  hashMatches, expressionHash, canonicalLogArgumentsOnce,
  canonicalLogArguments, canonicalLogAtom, positiveNumericLogFactor,
  canonicalRealBoundedPlus, carrierCoefficient,
  mapInterior, mapEndpointKinematics, ordinaryMapRecord,
  realContribution];
fail[message_String, detail_: Null] := (
  Print["S07_FAILURE: ", message];
  If[detail =!= Null, Print["S07_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
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
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity];
hashMatches[path_String, expected_String] :=
  FileExistsQ[path] &&
    FileHash[path, "SHA256", "HexString"] === expected;
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{stageDirectory, "s07_result.wl"}];
finiteCachePath = FileNameJoin[{stageDirectory,
  "s07_finite_projected_actions_cache.wl"}];
diagnosticPath = FileNameJoin[{stageDirectory,
  "s07_combination_diagnostic_result.wl"}];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected.wl"}];
factorizationProducerPath = FileNameJoin[{stageDirectory,
  "s07_factorize_hqq_msbar.wl"}];
factorizationCorrectionSourcePath = FileNameJoin[{stageDirectory,
  "s07_correct_initial_ppp_factorization_cache.wl"}];
factorizationValidationSourcePath = FileNameJoin[{stageDirectory,
  "s07_validate_corrected_factorization_cache.wl"}];
factorizationValidationResultPath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected_validation_result.wl"}];
s05SourcePath = FileNameJoin[{stageDirectory,
  "s05_correct_hqq_same_flavor_endpoint_residue.wl"}];
s05ResultPath = FileNameJoin[{stageDirectory, "s05_result.wl"}];
s05ValidationSourcePath = FileNameJoin[{stageDirectory,
  "s05_validate_hqq_same_flavor_endpoint_correction.wl"}];
s05ValidationResultPath = FileNameJoin[{stageDirectory,
  "s05_endpoint_correction_validation_result.wl"}];
s06SourcePath = FileNameJoin[{stageDirectory,
  "s06_add_hqq_external_lsz_from_cache.wl"}];
s06ResultPath = FileNameJoin[{stageDirectory, "s06_result.wl"}];
plusDiagnosticSourcePath = FileNameJoin[{stageDirectory,
  "s07_diagnose_bounded_plus_endpoint_coefficient.wl"}];
plusDiagnosticResultPath = FileNameJoin[{stageDirectory,
  "s07_bounded_plus_endpoint_diagnostic_result.wl"}];
ordinaryDiagnosticSourcePath = FileNameJoin[{stageDirectory,
  "s07_diagnose_ordinary_endpoint_subtraction_map.wl"}];
ordinaryDiagnosticResultPath = FileNameJoin[{stageDirectory,
  "s07_ordinary_endpoint_subtraction_diagnostic_result.wl"}];
paperPath = FileNameJoin[{DirectoryName[stageDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedFactorizationProducerHash =
  "db2012e21e8abe0fe4c007f3811ed57fd4cd5f2635301fb107a0aa0bf45a7c00";
expectedBaseFactorizationCacheHash =
  "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48";
expectedFactorizationCacheHash =
  "4b5538d1b8bf89c7ff94b45ad79458f9d8c3a6c42f6b6aa637b0529bc7ffcdef";
expectedFactorizationCorrectionSourceHash =
  "5c256aac4dedb323867c4b0a7e10b7aba81d0017215e54c83b81b1ee2c85ab25";
expectedFactorizationValidationSourceHash =
  "3cf38ba66a02bebb97e78ce79a09915c9abe32347cd542334b58958dcc3c839f";
expectedFactorizationValidationResultHash =
  "5d7903c932e20e25ff9cc1771ccbd1087d44be49ffd2f06643356d768681adbf";
expectedS05SourceHash =
  "f59ed00061be52090bddac52b3aa9a08dcdbcf1e7895ce618a49cde831f8be2c";
expectedS05ResultHash =
  "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb";
expectedS05ValidationSourceHash =
  "c3e7089644927d7a90c106e02a386cb01c5a8d6937a40358823d32a056fecacd";
expectedS05ValidationResultHash =
  "d04413b87ee94452fe0d854c1530483129717096d55b369a8707c48ee5195a01";
expectedS06SourceHash =
  "bca55a4735f54453071f47e920348de5fdf1cb541e990a1e6a9126bae9054216";
expectedS06ResultHash =
  "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979";
expectedPlusDiagnosticSourceHash =
  "30a2e8d7a1ce82ce1478c133ffecaf08c3007e745eb8650a9db255af65622009";
expectedPlusDiagnosticResultHash =
  "ebe5fcfb59a9320610d8efa07d24c636575f42fa335762e5a4a118dd128dc8bf";
expectedOrdinaryDiagnosticSourceHash =
  "4be3510bbedac05f613d60602c833bd689d02307ccb874a8aac7d7ff2de67779";
expectedOrdinaryDiagnosticResultHash =
  "cc9368de2a72575f1891e0b6b39902851919d2b96ee99341647c1be365895b8b";
expectedOrdinaryPPPResidualHash =
  "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918";
expectedPPPScaleDiagnosticResultHash =
  "6d74d4c16b74e8a4a2c97e921e85d30d81345bb340bb1a86e7572f5a9e51e70e";
expectedFactorizationCacheS06ResultHash =
  "b8e8b105bf62f2148d56d419a2563c8970dcf7c8b1b8e097f6ad55e0f1dddb9e";
expectedFactorizationCacheS05ResultHash =
  "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f";

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
validationMode = Environment["HQQV2_S07_VALIDATE_ONLY"] === "1";
inputIdentityChecks = <|
  "Paper" -> hashMatches[paperPath, expectedPaperHash],
  "FactorizationProducer" -> hashMatches[factorizationProducerPath,
    expectedFactorizationProducerHash],
  "FactorizationCache" -> hashMatches[factorizationCachePath,
    expectedFactorizationCacheHash],
  "FactorizationCorrectionSource" -> hashMatches[
    factorizationCorrectionSourcePath,
    expectedFactorizationCorrectionSourceHash],
  "FactorizationValidationSource" -> hashMatches[
    factorizationValidationSourcePath,
    expectedFactorizationValidationSourceHash],
  "FactorizationValidationResult" -> hashMatches[
    factorizationValidationResultPath,
    expectedFactorizationValidationResultHash],
  "S05Source" -> hashMatches[s05SourcePath, expectedS05SourceHash],
  "S05Result" -> hashMatches[s05ResultPath, expectedS05ResultHash],
  "S05ValidationSource" -> hashMatches[s05ValidationSourcePath,
    expectedS05ValidationSourceHash],
  "S05ValidationResult" -> hashMatches[s05ValidationResultPath,
    expectedS05ValidationResultHash],
  "S06Source" -> hashMatches[s06SourcePath, expectedS06SourceHash],
  "S06Result" -> hashMatches[s06ResultPath, expectedS06ResultHash],
  "PlusDiagnosticSource" -> hashMatches[plusDiagnosticSourcePath,
    expectedPlusDiagnosticSourceHash],
  "PlusDiagnosticResult" -> hashMatches[plusDiagnosticResultPath,
    expectedPlusDiagnosticResultHash],
  "OrdinaryDiagnosticSource" -> hashMatches[
    ordinaryDiagnosticSourcePath, expectedOrdinaryDiagnosticSourceHash],
  "OrdinaryDiagnosticResult" -> hashMatches[
    ordinaryDiagnosticResultPath,
    expectedOrdinaryDiagnosticResultHash]|>;

If[validationMode,
  Print["S07_STAGE=fresh cache-only result validation"];
  candidate = Quiet@Check[Get[resultPath], $Failed];
  validationChecks = <|
    "Association" -> AssociationQ[candidate],
    "StageScope" -> TrueQ[AssociationQ[candidate] &&
      candidate["Stage"] === "HqqV2S07-v6" &&
      candidate["ScopeTag"] === scopeTag],
    "Source" -> TrueQ[AssociationQ[candidate] &&
      candidate["Source", "SHA256"] === sourceHash],
    "Inputs" -> TrueQ[AssociationQ[candidate] &&
      candidate["Inputs", "FactorizationCacheSHA256"] ===
        expectedFactorizationCacheHash &&
      candidate["Inputs", "S05ResultSHA256"] ===
        expectedS05ResultHash &&
      candidate["Inputs", "S05ValidationResultSHA256"] ===
        expectedS05ValidationResultHash &&
      candidate["Inputs", "S06ResultSHA256"] ===
        expectedS06ResultHash &&
      candidate["Inputs", "PlusDiagnosticResultSHA256"] ===
        expectedPlusDiagnosticResultHash &&
      candidate["Inputs", "FactorizationValidationResultSHA256"] ===
        expectedFactorizationValidationResultHash &&
      candidate["Inputs", "OrdinaryDiagnosticResultSHA256"] ===
        expectedOrdinaryDiagnosticResultHash &&
      And @@ Values[inputIdentityChecks]],
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
    "ExactFinite" -> TrueQ[AssociationQ[candidate] &&
      FreeQ[candidate["FiniteProjectedActions"],
        epsilon | D | _SeriesData | _Real | Integrate |
          Inactive[Integrate] | Limit | ConditionalExpression |
          Indeterminate | ComplexInfinity | DirectedInfinity | Abs]],
    "NoTemporary" ->
      FileNames["s07_result.wl.tmp.*", stageDirectory] === {}|>;
  Print["S07_FRESH_CHECKS=", InputForm[validationChecks]];
  If[And @@ Values[validationChecks],
    Print["S07_FRESH_RELOAD_OK"];
    Quit[0],
    Print["S07_FRESH_RELOAD_FAILURE"];
    Quit[1]
  ]
];

require[And @@ Values[inputIdentityChecks],
  "accepted cache/input identity mismatch", inputIdentityChecks];
plusEndpointDiagnostic = Quiet@Check[
  Get[plusDiagnosticResultPath], $Failed];
plusEndpointDiagnosticChecks = <|
  "Association" -> AssociationQ[plusEndpointDiagnostic],
  "StageScope" -> TrueQ[AssociationQ[plusEndpointDiagnostic] &&
    plusEndpointDiagnostic["Stage"] ===
      "HqqV2S07BoundedPlusEndpointDiagnostic-v1" &&
    plusEndpointDiagnostic["ScopeTag"] === scopeTag],
  "Source" -> TrueQ[AssociationQ[plusEndpointDiagnostic] &&
    plusEndpointDiagnostic["Source", "SHA256"] ===
      expectedPlusDiagnosticSourceHash],
  "Consumer" -> TrueQ[AssociationQ[plusEndpointDiagnostic] &&
    plusEndpointDiagnostic["Inputs", "S07Consumer"] ===
      "eb9bbaea4485d19dd3d85e4cf09bdfd231ae409a6022b0bebccde78139d2a20d"],
  "StoredChecks" -> TrueQ[AssociationQ[plusEndpointDiagnostic] &&
    AssociationQ[plusEndpointDiagnostic["Checks"]] &&
    And @@ Values[plusEndpointDiagnostic["Checks"]]],
  "BothProjectorsZero" -> TrueQ[
    AssociationQ[plusEndpointDiagnostic] &&
    And @@ Map[
      TrueQ[plusEndpointDiagnostic[
        "EndpointMappedResidualMetadata", #, "Zero"]] &,
      {"Pg", "PPP"}]]|>;
require[And @@ Values[plusEndpointDiagnosticChecks],
  "accepted bounded-plus endpoint diagnostic failed its gates",
  plusEndpointDiagnosticChecks];
boundedPlusEndpointGate = TrueQ[
  And @@ Values[plusEndpointDiagnosticChecks]];
factorizationValidation = Quiet@Check[
  Get[factorizationValidationResultPath], $Failed];
factorizationValidationChecks = <|
  "Association" -> AssociationQ[factorizationValidation],
  "StageScope" -> TrueQ[AssociationQ[factorizationValidation] &&
    factorizationValidation["Stage"] ===
      "HqqV2S07FactorizationCacheValidation-v1" &&
    factorizationValidation["ScopeTag"] === scopeTag],
  "Source" -> TrueQ[AssociationQ[factorizationValidation] &&
    factorizationValidation["Source", "SHA256"] ===
      expectedFactorizationValidationSourceHash],
  "Bindings" -> TrueQ[AssociationQ[factorizationValidation] &&
    factorizationValidation["Inputs", "BaseCacheSHA256"] ===
      expectedBaseFactorizationCacheHash &&
    factorizationValidation["Inputs", "CorrectedCacheSHA256"] ===
      expectedFactorizationCacheHash],
  "StoredChecks" -> TrueQ[AssociationQ[factorizationValidation] &&
    AssociationQ[factorizationValidation["Checks"]] &&
    And @@ Values[factorizationValidation["Checks"]]],
  "EveryRouteSum" -> TrueQ[AssociationQ[factorizationValidation] &&
    AssociationQ[factorizationValidation["RouteSumChecks"]] &&
    And @@ Values[factorizationValidation["RouteSumChecks"]]],
  "CorrectedPole" -> TrueQ[AssociationQ[factorizationValidation] &&
    factorizationValidation["CorrectedPoleResidual"] === 0]|>;
require[And @@ Values[factorizationValidationChecks],
  "corrected factorization cache validation failed its gates",
  factorizationValidationChecks];
factorizationValidationGate = TrueQ[
  And @@ Values[factorizationValidationChecks]];

ordinaryEndpointDiagnostic = Quiet@Check[
  Get[ordinaryDiagnosticResultPath], $Failed];
ordinaryEndpointDiagnosticChecks = <|
  "Association" -> AssociationQ[ordinaryEndpointDiagnostic],
  "StageScope" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic["Stage"] ===
      "HqqV2S07OrdinaryEndpointSubtractionDiagnostic-v1" &&
    ordinaryEndpointDiagnostic["ScopeTag"] === scopeTag],
  "Source" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic["Source", "SHA256"] ===
      expectedOrdinaryDiagnosticSourceHash],
  "Bindings" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic["Inputs", "S07Consumer"] ===
      "c2f73601702a7425eb78d46d6f818b59b7e3c9e66038e6c6d8598435f9a49864" &&
    ordinaryEndpointDiagnostic["Inputs", "CorrectedS05"] ===
      expectedS05ResultHash &&
    ordinaryEndpointDiagnostic["Inputs", "CorrectedS06"] ===
      expectedS06ResultHash &&
    ordinaryEndpointDiagnostic["Inputs", "FactorizationCache"] ===
      expectedBaseFactorizationCacheHash &&
    ordinaryEndpointDiagnostic["Inputs", "PlusDiagnostic"] ===
      expectedPlusDiagnosticResultHash],
  "Location" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic["Location"] ===
      <|"Sector" -> "Ordinary", "EpsilonPower" -> -1|>],
  "AcceptedChecks" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic["Checks",
      "EndpointSubtractedPPPZero"] === False &&
    And @@ Values[KeyDrop[ordinaryEndpointDiagnostic["Checks"],
      {"EndpointSubtractedPPPZero"}]]],
  "PgZero" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic[
      "EndpointSubtractedResidualMetadata", "Pg", "Zero"] === True],
  "KnownPPPResidual" -> TrueQ[AssociationQ[ordinaryEndpointDiagnostic] &&
    ordinaryEndpointDiagnostic[
      "EndpointSubtractedResidualMetadata", "PPP", "Zero"] === False &&
    ordinaryEndpointDiagnostic[
      "EndpointSubtractedResidualMetadata", "PPP", "SHA256"] ===
        expectedOrdinaryPPPResidualHash]|>;
require[And @@ Values[ordinaryEndpointDiagnosticChecks],
  "accepted ordinary endpoint-subtraction diagnostic failed its gates",
  ordinaryEndpointDiagnosticChecks];
ordinaryEndpointDiagnosticGate = TrueQ[
  And @@ Values[ordinaryEndpointDiagnosticChecks]];
require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing S07 result"];
require[! FileExistsQ[diagnosticPath],
  "refusing to overwrite an existing S07 combination diagnostic"];

If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
$FCAdvice = False;
require[ValueQ[FeynCalc`$FeynCalcVersion], "FeynCalc did not load"];

Print["S07_STAGE=load accepted cache and unsubtracted ledgers"];
factorizationCache = Quiet@Check[Get[factorizationCachePath], $Failed];
factorizationCacheChecks = <|
  "Association" -> AssociationQ[factorizationCache],
  "StageScope" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["Stage"] ===
      "HqqV2S07FactorizationCache-v2" &&
    factorizationCache["ScopeTag"] === scopeTag],
  "Producer" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["ProducerSource", "SHA256"] ===
      expectedFactorizationProducerHash],
  "AcceptedInputs" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["Inputs", "PaperSHA256"] === expectedPaperHash &&
    factorizationCache["Inputs", "S05ResultSHA256"] ===
      expectedFactorizationCacheS05ResultHash &&
    factorizationCache["Inputs", "S06ResultSHA256"] ===
      expectedFactorizationCacheS06ResultHash],
  "Correction" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["CorrectionSource", "SHA256"] ===
      expectedFactorizationCorrectionSourceHash &&
    factorizationCache["Correction", "BaseCacheSHA256"] ===
      expectedBaseFactorizationCacheHash &&
    factorizationCache["Correction", "AcceptedDiagnosticSHA256"] ===
      expectedPPPScaleDiagnosticResultHash &&
    factorizationCache["Correction", "CorrectedPoleResidual"] === 0],
  "FreshValidation" -> factorizationValidationGate,
  "StoredChecks" -> TrueQ[AssociationQ[factorizationCache] &&
    AssociationQ[factorizationCache["Checks"]] &&
    And @@ Values[factorizationCache["Checks"]]],
  "MSbar" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["Conventions", "Scheme"] === "MSbar"],
  "RootFree" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["Factorization", "PrincipalRoots"] === {}]|>;
require[And @@ Values[factorizationCacheChecks],
  "accepted factorization cache failed its gates",
  factorizationCacheChecks];

s05 = Quiet@Check[Get[s05ResultPath], $Failed];
require[AssociationQ[s05] && s05["Stage"] === "HqqV2S05-v2" &&
    s05["ScopeTag"] === scopeTag && AssociationQ[s05["Checks"]] &&
    And @@ Values[s05["Checks"]] &&
    s05["Source", "SHA256"] === expectedS05SourceHash &&
    s05["Correction", "Schema"] ===
      "HqqV2S05SameFlavorEndpointCorrection-v2" &&
    And @@ Values[s05["Correction", "Checks"]],
  "accepted S05 result failed its gates"];
s05Validation = Quiet@Check[Get[s05ValidationResultPath], $Failed];
require[AssociationQ[s05Validation] &&
    s05Validation["Stage"] ===
      "HqqV2S05EndpointCorrectionValidation-v1" &&
    s05Validation["ScopeTag"] === scopeTag &&
    s05Validation["Source", "SHA256"] ===
      expectedS05ValidationSourceHash &&
    s05Validation["Inputs", "CorrectedS05"] === expectedS05ResultHash &&
    AssociationQ[s05Validation["Checks"]] &&
    And @@ Values[s05Validation["Checks"]] &&
    And @@ Flatten[Values /@
      Values[s05Validation["PoleCancellationChecks"]]],
  "independent corrected-S05 validation failed its gates"];
s05CorrectionGate = TrueQ[
  s05["Source", "SHA256"] === expectedS05SourceHash &&
  And @@ Values[s05["Correction", "Checks"]] &&
  And @@ Values[s05Validation["Checks"]]];
s06 = Quiet@Check[Get[s06ResultPath], $Failed];
require[AssociationQ[s06] && s06["Stage"] === "HqqV2S06-v2" &&
    s06["ScopeTag"] === scopeTag && AssociationQ[s06["Checks"]] &&
    And @@ Values[s06["Checks"]] &&
    s06["Correction", "Name"] === "ExternalLSZCacheTail" &&
    s06["Correction", "MasterCacheReevaluated"] === False &&
    s06["Correction", "BranchCacheRowsReevaluated"] === False,
  "accepted S06 result failed its gates"];
externalLSZCorrectionGate = TrueQ[
  s06["Correction", "Name"] === "ExternalLSZCacheTail" &&
  s06["Correction", "MasterCacheReevaluated"] === False &&
  s06["Correction", "BranchCacheRowsReevaluated"] === False];

factorizationLaurentLedger =
  factorizationCache["Factorization", "LaurentLedger"];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
realLedger = s05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
projectorLabels = Keys[factorizationLaurentLedger];
realFamilies = Keys[realLedger["Pg"]];
require[projectorLabels === {"Pg", "PPP"} &&
    Keys[realLedger] === projectorLabels &&
    Keys[virtualLedger] === projectorLabels &&
    realFamilies === {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
      "Hqq;qPrime_qbarPrime"},
  "accepted ledger schema changed"];

(* Expand only special-function atoms discovered in the accepted ledgers. *)
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {realLedger, virtualLedger, factorizationLaurentLedger},
  _PolyGamma, Infinity];
combinationSpecialValues = Quiet@Check[
  FunctionExpand /@ combinationSpecialAtoms, $Failed];
require[combinationSpecialValues =!= $Failed &&
    Length[combinationSpecialValues] === Length[combinationSpecialAtoms] &&
    FreeQ[combinationSpecialValues, _PolyGamma] &&
    ! badSymbolicQ[combinationSpecialValues],
  "special-function basis expansion failed"];
combinationSpecialResiduals = Quiet@Check[
  MapThread[FullSimplify[#1 - #2] &,
    {combinationSpecialAtoms, combinationSpecialValues}], $Failed];
require[combinationSpecialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "special-function basis identities failed",
  combinationSpecialResiduals];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
combinationBasisChecks = <|
  "AtomsDiscovered" -> combinationSpecialAtoms =!= {},
  "ExactIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "ExpandedBasis" -> FreeQ[combinationSpecialValues, _PolyGamma]|>;
require[And @@ Values[combinationBasisChecks],
  "combination basis gates failed", combinationBasisChecks];
Print["S07_COMBINATION_SPECIAL_RULES=",
  InputForm[combinationSpecialRules]];
Clear[s05, s05Validation, s06];

sectorNames = {"Delta", "BoundedPlus", "Ordinary"};
realSectorName = <|"Delta" -> "DeltaLaurent",
  "BoundedPlus" -> "BoundedPlusLaurent",
  "Ordinary" -> "OrdinaryLaurent"|>;
virtualSectorName = realSectorName;

ClearAll[canonicalCombinationBasis, canonicalReal, canonicalVirtual,
  canonicalFactorization, canonicalLogArgumentsOnce,
  canonicalLogArguments, canonicalLogAtom, positiveNumericLogFactor,
  canonicalRealBoundedPlus];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
positiveNumericLogFactor[argument_] := Module[
  {canonical, factors, numericProduct, positiveFactor},
  canonical = Factor[Cancel[Together[argument]]];
  factors = If[Head[canonical] === Times,
    List @@ canonical, {canonical}];
  numericProduct = Times @@ Select[factors, NumericQ];
  positiveFactor = Quiet@FullSimplify[Abs[numericProduct]];
  If[TrueQ[Positive[positiveFactor]] &&
      FreeQ[positiveFactor, _Real | Abs], positiveFactor, 1]
];
canonicalLogAtom[argument_] := Module[
  {canonical, positiveFactor, remainder, numericLog},
  canonical = Factor[Cancel[Together[argument]]];
  positiveFactor = positiveNumericLogFactor[canonical];
  If[SameQ[positiveFactor, 1], Return[Log[canonical]]];
  remainder = Quiet@Check[
    Cancel[Together[canonical/positiveFactor]], $Failed];
  require[remainder =!= $Failed && ! badSymbolicQ[remainder] &&
      exactZeroQ[canonical - positiveFactor remainder],
    "positive numeric log-factor reconstruction failed",
    <|"Argument" -> canonical, "Factor" -> positiveFactor|>];
  numericLog = Quiet@Check[PowerExpand[Log[positiveFactor]], $Failed];
  require[numericLog =!= $Failed && ! badSymbolicQ[numericLog],
    "positive numeric log-factor expansion failed", positiveFactor];
  numericLog + Log[remainder]
];
canonicalLogArgumentsOnce[expression_] := expression /.
  HoldPattern[Log[argument_]] :> canonicalLogAtom[argument];
canonicalLogArguments[expression_] := Module[{answer},
  answer = FixedPoint[canonicalLogArgumentsOnce, expression, 8];
  require[SameQ[answer, canonicalLogArgumentsOnce[answer]],
    "log-argument canonicalization did not reach a fixed point"];
  answer
];
canonicalReal[expression_, "Delta"] :=
  canonicalLogArguments[
    canonicalCombinationBasis[expression] /. u1Rule /. s23 -> 0];
canonicalRealBoundedPlus[expression_] := Module[
  {atoms, dummies, polynomial, degrees, coefficients, remainder,
   mappedHeads, mappedCoefficients},
  atoms = DeleteDuplicates@Cases[Unevaluated[expression],
    HoldPattern[HqqV2BoundedPlus[_, s23, _]], Infinity];
  If[atoms === {},
    require[exactZeroQ[expression],
      "real bounded-plus field has no distribution head but is nonzero"];
    Return[0]
  ];
  require[And @@ Map[FreeQ[#[[3]], s23] &, atoms],
    "real bounded-plus upper bound depends on its integration variable",
    atoms];
  dummies = Table[s07BoundedPlusDummy[index],
    {index, Length[atoms]}];
  polynomial = expression /. Thread[atoms -> dummies];
  degrees = Exponent[polynomial, #] & /@ dummies;
  require[PolynomialQ[polynomial, dummies] &&
      And @@ Map[SameQ[#, 1] &, degrees],
    "real bounded-plus field is not linear in every distribution head",
    degrees];
  coefficients = Quiet@Check[Map[
    Cancel[Together[Coefficient[polynomial, #, 1]]] &,
    dummies], $Failed];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - Total[MapThread[Times, {coefficients, dummies}]]]],
    $Failed];
  require[coefficients =!= $Failed && remainder =!= $Failed &&
      SameQ[remainder, 0] &&
      FreeQ[coefficients, _s07BoundedPlusDummy] &&
      ! badSymbolicQ[coefficients],
    "real bounded-plus coefficient extraction failed",
    <|"Degrees" -> degrees, "Remainder" -> remainder|>];
  mappedHeads = (# /. u1Rule) & /@ atoms;
  mappedCoefficients = Quiet@Check[Map[
    Cancel[Together[canonicalCombinationBasis[#] /.
      u1Rule /. s23 -> 0]] &, coefficients], $Failed];
  require[mappedCoefficients =!= $Failed &&
      ! badSymbolicQ[mappedCoefficients] &&
      And @@ Map[FreeQ[#, s23 | u1] &, mappedCoefficients],
    "real bounded-plus endpoint coefficient map failed",
    mappedCoefficients];
  Total[MapThread[Times, {mappedCoefficients, mappedHeads}]]
];
canonicalReal[expression_, "BoundedPlus"] :=
  canonicalRealBoundedPlus[expression];
mapInterior[expression_] :=
  canonicalCombinationBasis[expression] /. u1Rule;
mapEndpointKinematics[expression_, label_String] := Module[
  {held, mapped},
  require[FreeQ[expression, s07HeldExplicitLogS23],
    label <> " contains the ordinary-map hold symbol"];
  held = expression /.
    HoldPattern[Log[s23]] -> s07HeldExplicitLogS23;
  mapped = Quiet@Check[Cancel[Together[
    canonicalCombinationBasis[held] /. u1Rule /. s23 -> 0]],
    $Failed];
  require[mapped =!= $Failed && ! badSymbolicQ[mapped] &&
      FreeQ[mapped, s23 | u1],
    label <> " endpoint-kinematic map failed", mapped];
  mapped /. s07HeldExplicitLogS23 -> Log[s23]
];
carrierCoefficient[data_Association, alpha_Integer, power_Integer] :=
  Total@Table[If[sourcePower <= power,
      Lookup[data, sourcePower, 0] *
        (-alpha Log[s23])^(power - sourcePower)/
          Factorial[power - sourcePower], 0],
    {sourcePower, Keys[data]}];
ordinaryMapRecord[ordinary_, endpointByAlpha_Association,
    power_Integer, label_String] := Module[
  {endpointTerms, rawSingularTerms, mappedRawSingular,
   mappedEndpointSingular, correctionTerms, current, candidate,
   fixedInterior, mappedFixedInterior, checks},
  require[And @@ Map[IntegerQ, Keys[endpointByAlpha]] &&
      FreeQ[endpointByAlpha, s23 | epsilon | _SeriesData | _Real],
    label <> " endpoint-alpha ledger is unresolved"];
  endpointTerms = AssociationMap[
    carrierCoefficient[endpointByAlpha[#], #, power] &,
    Keys[endpointByAlpha]];
  rawSingularTerms = (#/s23) & /@ Values[endpointTerms];
  current = mapInterior[ordinary];
  mappedRawSingular = mapInterior /@ rawSingularTerms;
  mappedEndpointSingular = MapThread[
    mapEndpointKinematics[#1,
      label <> "/alpha=" <> ToString[#2]]/s23 &,
    {Values[endpointTerms], Keys[endpointTerms]}];
  correctionTerms = MapThread[Subtract,
    {mappedRawSingular, mappedEndpointSingular}];
  candidate = current + Total[correctionTerms];
  fixedInterior = ordinary + Total[rawSingularTerms];
  mappedFixedInterior = mapInterior[fixedInterior];
  checks = <|
    "StoredSplitReconstructs" -> exactZeroQ[
      ordinary - (fixedInterior - Total[rawSingularTerms])],
    "MappedSplitReconstructs" -> exactZeroQ[
      candidate - (mappedFixedInterior -
        Total[mappedEndpointSingular])],
    "CorrectionExact" -> ! badSymbolicQ[correctionTerms] &&
      FreeQ[correctionTerms, epsilon | D | _SeriesData | _Real],
    "ExplicitEndpointLogsPreserved" ->
      FreeQ[candidate, s07HeldExplicitLogS23]|>;
  require[And @@ Values[checks],
    label <> " ordinary endpoint-subtraction map failed", checks];
  <|"Candidate" -> candidate,
    "Correction" -> Total[correctionTerms], "Checks" -> checks|>
];
canonicalVirtual[expression_] := canonicalLogArguments[
  canonicalCombinationBasis[expression] /.
    {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0];
canonicalFactorization[expression_, "Delta"] :=
  canonicalLogArguments[
    canonicalCombinationBasis[expression] /. s23 -> 0];
canonicalFactorization[expression_, _String] :=
  canonicalCombinationBasis[expression];

ordinaryPowers = {-2, -1, 0};
ordinaryMapRecords = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    AssociationMap[Function[power, ordinaryMapRecord[
      Lookup[realLedger[projector, family, "OrdinaryLaurent"],
        power, 0],
      realLedger[projector, family,
        "EndpointResidueByAlphaThroughEpsilon1"],
      power, projector <> "/" <> family <> "/epsilon^" <>
        ToString[power]]], ordinaryPowers]], realFamilies]],
  projectorLabels];
ordinaryMapGate = And @@ Flatten@Table[
  And @@ Values[ordinaryMapRecords[
    projector, family, power, "Checks"]],
  {projector, projectorLabels}, {family, realFamilies},
  {power, ordinaryPowers}];
ordinaryDiagnosticCorrectionChecks = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    expressionHash[ordinaryMapRecords[
      projector, family, -1, "Correction"]] ===
      ordinaryEndpointDiagnostic[
        "CorrectionSHA256", projector, family]], realFamilies]],
  projectorLabels];
ordinaryDiagnosticCorrectionGate = And @@ Flatten[
  Values /@ Values[ordinaryDiagnosticCorrectionChecks]];
require[ordinaryMapGate && ordinaryDiagnosticCorrectionGate,
  "production ordinary map disagrees with accepted diagnostic",
  ordinaryDiagnosticCorrectionChecks];

realContribution[projector_, family_, "Ordinary", power_] :=
  ordinaryMapRecords[projector, family, power, "Candidate"];
realContribution[projector_, family_, sector_String, power_] :=
  canonicalReal[Lookup[
    realLedger[projector, family, realSectorName[sector]], power, 0],
    sector];

ClearAll[balancedExactSum, denominatorGroupedCombination];
balancedExactSum[values_List, label_String] := Module[{level, next},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed && ! badSymbolicQ[level],
    label <> " canonicalization failed"];
  level = DeleteCases[level, 0];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Map[If[Length[#] === 1, First[#],
      Quiet@Check[Cancel[Together[#[[1]] + #[[2]]]], $Failed]] &,
      Partition[level, UpTo[2]]];
    require[FreeQ[next, $Failed] && ! badSymbolicQ[next],
      label <> " balanced exact addition failed"];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];

denominatorGroupedCombination[expressions_List, label_String,
    proveZeroQ_] := Module[
  {accumulator = <||>, terms, canonical, denominator, numerator,
   denominatorHash, group, levels, level, carry, groupTotals,
   additiveExpression, zeroResidual},
  Do[
    terms = If[Head[expression] === Plus,
      List @@ expression, {expression}];
    Do[
      If[TrueQ[term === 0], Continue[]];
      canonical = Quiet@Check[Cancel[Together[term]], $Failed];
      require[canonical =!= $Failed && ! badSymbolicQ[canonical],
        label <> " term canonicalization failed"];
      If[TrueQ[canonical === 0], Continue[]];
      denominator = Denominator[canonical];
      numerator = Numerator[canonical];
      denominatorHash = IntegerString[
        Hash[denominator, "SHA256"], 16, 64];
      If[KeyExistsQ[accumulator, denominatorHash],
        group = accumulator[denominatorHash];
        require[SameQ[group["Denominator"], denominator],
          label <> " denominator hash collision"],
        group = <|"Denominator" -> denominator, "Levels" -> <||>|>];
      levels = group["Levels"];
      level = 0;
      carry = numerator;
      While[KeyExistsQ[levels, level],
        carry = Quiet@Check[Cancel[Together[
          levels[level] + carry]], $Failed];
        require[carry =!= $Failed && ! badSymbolicQ[carry],
          label <> " numerator accumulation failed"];
        KeyDropFrom[levels, level];
        level++;
        If[TrueQ[carry === 0], Break[]]];
      If[! TrueQ[carry === 0], AssociateTo[levels, level -> carry]];
      AssociateTo[group, "Levels" -> levels];
      AssociateTo[accumulator, denominatorHash -> group],
      {term, terms}],
    {expression, expressions}];
  groupTotals = KeyValueMap[Function[{hash, storedGroup},
    With[{summedNumerator = balancedExactSum[
        Values[KeySort[storedGroup["Levels"]]],
        label <> "/denominator/" <> StringTake[hash, 12]]},
      If[TrueQ[summedNumerator === 0], 0,
        Cancel[summedNumerator/storedGroup["Denominator"]]]]],
    KeySort[accumulator]];
  groupTotals = DeleteCases[groupTotals, 0];
  additiveExpression = If[groupTotals === {}, 0, Total[groupTotals]];
  zeroResidual = If[TrueQ[proveZeroQ],
    balancedExactSum[groupTotals, label <> "/cross-denominator"],
    Missing["NotRequested"]];
  Print["S07_GROUPED_SUM=", label, " DENOMINATORS=",
    Length[accumulator], " NONZERO_GROUPS=", Length[groupTotals],
    If[TrueQ[proveZeroQ],
      " ZERO=" <> ToString[SameQ[zeroResidual, 0]], ""]];
  <|"Expression" -> additiveExpression,
    "ZeroResidual" -> zeroResidual,
    "DenominatorCount" -> Length[accumulator],
    "NonzeroGroupCount" -> Length[groupTotals]|>
];

ClearAll[fieldContributions];
fieldContributions[projector_, sector_, power_] :=
  canonicalLogArguments /@ Join[
  Table[realContribution[projector, family, sector, power],
    {family, realFamilies}],
  {canonicalVirtual[Lookup[
    virtualLedger[projector, virtualSectorName[sector]], power, 0]]},
  {canonicalFactorization[Lookup[
    factorizationLaurentLedger[projector, sector], power, 0], sector]}];

ClearAll[principalRootAtoms, publishPoleDiagnostic];
principalRootAtoms[expression_] := DeleteDuplicates@Cases[
  expression, HoldPattern[Power[Power[_, 2], Rational[1, 2]]],
  Infinity];

publishPoleDiagnostic[projector_String, sector_String, power_Integer,
    contributions_List, combined_Association] := Module[
  {names, components, componentZeroChecks, componentLeafCounts,
   rootInventories, roots, root, flippedComponents, componentOdd,
   totalOdd, oddSum, oddMetadata, diagnostic, diagnosticReload},
  names = Join[realFamilies, {"Virtual", "Factorization"}];
  require[Length[names] === Length[contributions],
    "diagnostic component schema mismatch"];
  components = AssociationThread[names, contributions];
  componentZeroChecks = AssociationMap[
    exactZeroQ[components[#]] &, names];
  componentLeafCounts = AssociationMap[
    LeafCount[components[#]] &, names];
  rootInventories = AssociationMap[
    principalRootAtoms[components[#]] &, names];
  roots = DeleteDuplicates[Flatten[Values[rootInventories]]];
  oddMetadata = <|"Status" -> "NotUniquePrincipalRoot",
    "RootCount" -> Length[roots]|>;
  If[Length[roots] === 1,
    root = First[roots];
    flippedComponents = AssociationMap[Function[name,
      Quiet@Check[components[name] /. root -> -root, $Failed]], names];
    If[FreeQ[flippedComponents, $Failed],
      componentOdd = AssociationMap[Function[name,
        Quiet@Check[Cancel[Together[
          (components[name] - flippedComponents[name])/2]], $Failed]],
        names];
      totalOdd = Quiet@Check[Cancel[Together[
        (combined["ZeroResidual"] -
          (combined["ZeroResidual"] /. root -> -root))/2]], $Failed];
      If[FreeQ[{componentOdd, totalOdd}, $Failed],
        oddSum = balancedExactSum[Values[componentOdd],
          projector <> "/" <> sector <> "/diagnostic-root-odd"];
        oddMetadata = <|"Status" -> "Computed", "Root" -> root,
          "ComponentOdd" -> componentOdd, "TotalOdd" -> totalOdd,
          "ComponentOddSum" -> oddSum,
          "ReconstructsTotalOdd" -> exactZeroQ[oddSum - totalOdd]|>,
        oddMetadata = <|"Status" -> "ExactOddReductionFailed",
          "Root" -> root|>],
      oddMetadata = <|"Status" -> "RootFlipFailed", "Root" -> root|>]
  ];
  diagnostic = <|
    "Stage" -> "HqqV2S07PoleDiagnostic-v1",
    "ScopeTag" -> scopeTag,
    "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
    "Inputs" -> <|
      "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
      "S05ResultSHA256" -> expectedS05ResultHash,
      "S05ValidationResultSHA256" -> expectedS05ValidationResultHash,
      "S06ResultSHA256" -> expectedS06ResultHash|>,
    "Location" -> <|"Projector" -> projector, "Sector" -> sector,
      "EpsilonPower" -> power|>,
    "ComponentOrder" -> names,
    "Components" -> components,
    "ComponentZeroChecks" -> componentZeroChecks,
    "ComponentLeafCounts" -> componentLeafCounts,
    "CombinationMetadata" -> combined,
    "PrincipalRootInventories" -> rootInventories,
    "PrincipalRoots" -> roots,
    "RootOddDecomposition" -> oddMetadata|>;
  atomicPut[diagnostic, diagnosticPath];
  diagnosticReload = Quiet@Check[Get[diagnosticPath], $Failed];
  require[SameQ[diagnosticReload, diagnostic],
    "fresh pole diagnostic reload failed"];
  Print["S07_POLE_DIAGNOSTIC_LOCATION=", InputForm[
    diagnostic["Location"]]];
  Print["S07_POLE_COMPONENT_ZERO_CHECKS=",
    InputForm[componentZeroChecks]];
  Print["S07_POLE_COMPONENT_LEAF_COUNTS=",
    InputForm[componentLeafCounts]];
  Print["S07_POLE_PRINCIPAL_ROOTS=", InputForm[roots]];
  Print["S07_POLE_ROOT_ODD_STATUS=", InputForm[
    Lookup[oddMetadata, "Status"]]];
  Print["S07_POLE_ROOT_ODD_RECONSTRUCTS=", InputForm[
    Lookup[oddMetadata, "ReconstructsTotalOdd", Missing["NotComputed"]]]];
  Print["S07_POLE_DIAGNOSTIC_SHA256=",
    FileHash[diagnosticPath, "SHA256", "HexString"]];
  Print["S07_POLE_DIAGNOSTIC_READY"];
  fail["pole did not cancel; exact same-kernel diagnostic published",
    diagnostic["Location"]]
];

Print["S07_STAGE=exact cache-only pole cancellation"];
poleCombinationMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    Association@Table[power -> Module[{contributions, combined},
      Print["S07_POLE_FIELD=", projector, "/", sector,
        "/", power];
      contributions = fieldContributions[projector, sector, power];
      combined = denominatorGroupedCombination[contributions,
        projector <> "/" <> sector <> "/epsilon" <>
          ToString[power], True];
      If[! SameQ[combined["ZeroResidual"], 0],
        publishPoleDiagnostic[projector, sector, power,
          contributions, combined]];
      combined], {power, {-2, -1}}]], sectorNames]], projectorLabels];

poleResiduals = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    AssociationMap[Function[power,
      poleCombinationMetadata[projector, sector, power,
        "ZeroResidual"]], {-2, -1}]], sectorNames]], projectorLabels];
poleResidualList = Flatten[Table[
  poleResiduals[projector, sector, power],
  {projector, projectorLabels}, {sector, sectorNames},
  {power, {-2, -1}}]];
require[And @@ (SameQ[#, 0] & /@ poleResidualList),
  "one or more exact pole residuals are nonzero"];

Print["S07_STAGE=finite projected actions"];
finiteComponentNames = Join[realFamilies, {"Virtual", "Factorization"}];
finiteFieldComponents = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    AssociationThread[finiteComponentNames,
      fieldContributions[projector, sector, 0]]], sectorNames]],
  projectorLabels];
finiteCombinationMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    Print["S07_FINITE_FIELD=", projector, "/", sector];
    denominatorGroupedCombination[
      Values[finiteFieldComponents[projector, sector]],
      projector <> "/" <> sector <> "/finite", False]],
    sectorNames]], projectorLabels];
finiteProjectedActions = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    finiteCombinationMetadata[projector, sector, "Expression"]],
    sectorNames]], projectorLabels];

schemeTaggedActions = finiteProjectedActions /.
  {EulerGamma -> s07EulerGammaTag,
    HoldPattern[Log[Pi]] -> s07LogPiTag};
schemeConstantGate = FreeQ[schemeTaggedActions,
  s07EulerGammaTag | s07LogPiTag];
noncanonicalPiLogAtoms = DeleteDuplicates@Cases[
  finiteProjectedActions,
  HoldPattern[atom : Log[argument_]] /;
    ! FreeQ[argument, Pi] && ! SameQ[atom, Log[Pi]], Infinity];
finiteCacheChecks = <|
  "EveryDoubleAndSinglePoleZero" ->
    And @@ (SameQ[#, 0] & /@ poleResidualList),
  "ComponentSchema" -> And @@ Flatten@Table[
    Keys[finiteFieldComponents[projector, sector]] ===
      finiteComponentNames,
    {projector, projectorLabels}, {sector, sectorNames}],
  "ActionSchema" ->
    Keys[finiteProjectedActions] === projectorLabels &&
      And @@ (Keys[#] === sectorNames & /@
        Values[finiteProjectedActions]),
  "MSbarLogBasisCanonical" -> noncanonicalPiLogAtoms === {},
  "FiniteExact" -> ! badSymbolicQ[
      {finiteFieldComponents, finiteProjectedActions}] &&
    FreeQ[{finiteFieldComponents, finiteProjectedActions},
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs]|>;
require[And @@ Values[finiteCacheChecks],
  "finite checkpoint gates failed", finiteCacheChecks];
require[! FileExistsQ[finiteCachePath],
  "finite checkpoint already exists; refusing overwrite"];
finiteCache = <|
  "Stage" -> "HqqV2S07FiniteProjectedActionsCache-v1",
  "ScopeTag" -> scopeTag,
  "Producer" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|
    "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
    "FactorizationValidationResultSHA256" ->
      expectedFactorizationValidationResultHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S05ValidationResultSHA256" -> expectedS05ValidationResultHash,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "PlusDiagnosticResultSHA256" -> expectedPlusDiagnosticResultHash,
    "OrdinaryDiagnosticResultSHA256" ->
      expectedOrdinaryDiagnosticResultHash|>,
  "ComponentOrder" -> finiteComponentNames,
  "PoleCombinationMetadata" -> poleCombinationMetadata,
  "PoleResiduals" -> poleResiduals,
  "PoleResidualList" -> poleResidualList,
  "FiniteComponents" -> finiteFieldComponents,
  "FiniteCombinationMetadata" -> finiteCombinationMetadata,
  "FiniteProjectedActions" -> finiteProjectedActions,
  "NoncanonicalPiLogAtoms" -> noncanonicalPiLogAtoms,
  "Checks" -> finiteCacheChecks,
  "DownstreamBoundary" ->
    "scheme-residual correction and final S07 publication only"|>;
Print["S07_STAGE=atomic finite checkpoint publication"];
atomicPut[finiteCache, finiteCachePath];
finiteCacheReload = Quiet@Check[Get[finiteCachePath], $Failed];
require[SameQ[finiteCacheReload, finiteCache] &&
    And @@ Values[finiteCacheReload["Checks"]],
  "fresh finite checkpoint reload failed"];
Print["S07_FINITE_CACHE_SHA256=",
  FileHash[finiteCachePath, "SHA256", "HexString"]];
Print["S07_FINITE_CACHE_READY"];
ordinaryCorrectionHashes = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    AssociationMap[Function[power,
      expressionHash[ordinaryMapRecords[
        projector, family, power, "Correction"]]], ordinaryPowers]],
    realFamilies]], projectorLabels];
noForeignProductionCacheGate = Intersection[Keys[inputIdentityChecks],
  {"AngularMasterCache", "CoefficientCache", "EndpointCache",
    "RootGroupCache", "DirectEndpointCache"}] === {};

checks = <|
  "AcceptedInputHashes" -> And @@ Values[inputIdentityChecks],
  "AcceptedFactorizationCache" ->
    And @@ Values[factorizationCacheChecks],
  "AcceptedFactorizationValidation" -> factorizationValidationGate,
  "ExternalLSZCorrection" -> externalLSZCorrectionGate,
  "CorrectedS05EndpointCorrection" -> s05CorrectionGate,
  "AcceptedBoundedPlusEndpointDiagnostic" -> boundedPlusEndpointGate,
  "AcceptedOrdinaryEndpointDiagnostic" ->
    ordinaryEndpointDiagnosticGate,
  "EveryOrdinaryEndpointMap" -> ordinaryMapGate,
  "OrdinaryDiagnosticCorrectionAgreement" ->
    ordinaryDiagnosticCorrectionGate,
  "AcceptedSchemas" -> Keys[realLedger] === projectorLabels &&
    Keys[virtualLedger] === projectorLabels,
  "FactorizationPrincipalRootsEmpty" ->
    factorizationCache["Factorization", "PrincipalRoots"] === {},
  "CombinationSpecialFunctionBasis" ->
    And @@ Values[combinationBasisChecks],
  "EveryDoubleAndSinglePoleZero" ->
    And @@ (SameQ[#, 0] & /@ poleResidualList),
  "FiniteProjectorSchema" ->
    Keys[finiteProjectedActions] === projectorLabels &&
      And @@ (Keys[#] === sectorNames & /@
        Values[finiteProjectedActions]),
  "MSbarConstantsCancel" -> TrueQ[schemeConstantGate],
  "MSbarLogBasisCanonical" -> noncanonicalPiLogAtoms === {},
  "FiniteExact" -> ! badSymbolicQ[finiteProjectedActions] &&
    FreeQ[finiteProjectedActions,
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs],
  "NoForeignProductionCache" -> noForeignProductionCacheGate|>;
Print["S07_CHECKS=", InputForm[checks]];
require[And @@ Values[checks], "S07 final gates failed", checks];

result = <|
  "Stage" -> "HqqV2S07-v6",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> Join[factorizationCache["Inputs"], <|
    "FactorizationProducerSHA256" ->
      expectedFactorizationProducerHash,
    "BaseFactorizationCacheSHA256" ->
      expectedBaseFactorizationCacheHash,
    "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
    "FactorizationCorrectionSourceSHA256" ->
      expectedFactorizationCorrectionSourceHash,
    "FactorizationValidationSourceSHA256" ->
      expectedFactorizationValidationSourceHash,
    "FactorizationValidationResultSHA256" ->
      expectedFactorizationValidationResultHash,
    "PPPScaleDiagnosticResultSHA256" ->
      expectedPPPScaleDiagnosticResultHash,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S05ValidationSourceSHA256" -> expectedS05ValidationSourceHash,
    "S05ValidationResultSHA256" -> expectedS05ValidationResultHash,
    "S06SourceSHA256" -> expectedS06SourceHash,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "PlusDiagnosticSourceSHA256" ->
      expectedPlusDiagnosticSourceHash,
    "PlusDiagnosticResultSHA256" ->
      expectedPlusDiagnosticResultHash,
    "OrdinaryDiagnosticSourceSHA256" ->
      expectedOrdinaryDiagnosticSourceHash,
    "OrdinaryDiagnosticResultSHA256" ->
      expectedOrdinaryDiagnosticResultHash,
    "FactorizationCacheBoundS05ResultSHA256" ->
      expectedFactorizationCacheS05ResultHash,
    "FactorizationCacheBoundS06ResultSHA256" ->
      expectedFactorizationCacheS06ResultHash|>],
  "Runtime" -> <|"Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "ParallelPolicy" ->
      "serial exact combination of already-cached symbolic fields"|>,
  "Conventions" -> factorizationCache["Conventions"],
  "LowerBorn" -> factorizationCache["LowerBorn"],
  "SplittingKernels" -> factorizationCache["SplittingKernels"],
  "Factorization" -> factorizationCache["Factorization"],
  "CombinationSpecialFunctionBasis" -> <|
    "Rules" -> combinationSpecialRules,
    "Checks" -> combinationBasisChecks|>,
  "MSbarLogCanonicalization" -> <|
    "Method" ->
      "Wolfram PowerExpand only after Positive proves an extracted numeric multiplier; exact argument reconstruction required",
    "ForbiddenResiduals" -> {EulerGamma, Log[Pi]},
    "NoncanonicalPiLogAtoms" -> noncanonicalPiLogAtoms|>,
  "BoundedPlusEndpointMap" -> <|
    "DiagnosticSourceSHA256" -> expectedPlusDiagnosticSourceHash,
    "DiagnosticResultSHA256" -> expectedPlusDiagnosticResultHash,
    "Checks" -> plusEndpointDiagnosticChecks|>,
  "OrdinaryEndpointSubtractionMap" -> <|
    "DiagnosticSourceSHA256" -> expectedOrdinaryDiagnosticSourceHash,
    "DiagnosticResultSHA256" -> expectedOrdinaryDiagnosticResultHash,
    "DiagnosticChecks" -> ordinaryEndpointDiagnosticChecks,
    "CorrectionAgreementChecks" ->
      ordinaryDiagnosticCorrectionChecks,
    "CorrectionHashes" -> ordinaryCorrectionHashes|>,
  "FactorizationCacheValidation" -> <|
    "SourceSHA256" -> expectedFactorizationValidationSourceHash,
    "ResultSHA256" -> expectedFactorizationValidationResultHash,
    "Checks" -> factorizationValidationChecks|>,
  "PoleLedger" -> <|
    "CombinationMetadata" -> poleCombinationMetadata,
    "Residuals" -> poleResiduals|>,
  "PoleResidualList" -> poleResidualList,
  "FiniteCombinationMetadata" -> finiteCombinationMetadata,
  "FiniteProjectedActions" -> finiteProjectedActions,
  "DownstreamBoundary" ->
    "S08 derives Eq. (9) weights and applies them only to these finite Pg/PPP actions",
  "Checks" -> checks|>;

Print["S07_STAGE=atomic result publication"];
atomicPut[result, resultPath];
resultReload = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[resultReload, result] &&
    And @@ Values[resultReload["Checks"]],
  "fresh S07 result reload failed"];
Print["S07_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_CANDIDATE_READY"];
Quit[0];

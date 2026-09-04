(* Hqq_v2 S07: fresh validation of the corrected factorization cache. *)

ClearAll["Global`*"];
$HistoryLength = 0;
$IterationLimit = Infinity;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
$FCAdvice = False;

ClearAll[fail, require, atomicPut, exactZeroQ, badSymbolicQ,
  expressionHash, boundedPlusCoefficient];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_FACTOR_CACHE_VALIDATION_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_FACTOR_CACHE_VALIDATION_FAILURE_DETAIL=",
      InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    fail["corrected-cache validation publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "corrected-cache validation temporary result is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published corrected-cache validation result is missing"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
baseCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
correctedCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected.wl"}];
diagnosticPath = FileNameJoin[{stageDirectory,
  "s07_initial_ppp_projector_rescaling_diagnostic_result.wl"}];
rawResidualCachePath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_raw_residual_cache.wl"}];
resultPath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected_validation_result.wl"}];

expectedBaseCacheHash =
  "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48";
expectedCorrectedCacheHash =
  "4b5538d1b8bf89c7ff94b45ad79458f9d8c3a6c42f6b6aa637b0529bc7ffcdef";
expectedCorrectionProducerHash =
  "5c256aac4dedb323867c4b0a7e10b7aba81d0017215e54c83b81b1ee2c85ab25";
expectedDiagnosticHash =
  "6d74d4c16b74e8a4a2c97e921e85d30d81345bb340bb1a86e7572f5a9e51e70e";
expectedRawResidualCacheHash =
  "afc12bb8e9942d9059c0f1eda9e1e6d73d137e19af5dc0cf26651992edaad569";
expectedResidualHash =
  "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918";

requiredPaths = {baseCachePath, correctedCachePath, diagnosticPath,
  rawResidualCachePath};
require[And @@ FileExistsQ /@ requiredPaths && ! FileExistsQ[resultPath],
  "corrected-cache validation input/target state is invalid"];
fileHashChecks = <|
  "BaseCache" -> FileHash[baseCachePath, "SHA256", "HexString"] ===
    expectedBaseCacheHash,
  "CorrectedCache" ->
    FileHash[correctedCachePath, "SHA256", "HexString"] ===
      expectedCorrectedCacheHash,
  "Diagnostic" -> FileHash[diagnosticPath, "SHA256", "HexString"] ===
    expectedDiagnosticHash,
  "RawResidualCache" ->
    FileHash[rawResidualCachePath, "SHA256", "HexString"] ===
      expectedRawResidualCacheHash|>;
require[And @@ Values[fileHashChecks],
  "corrected-cache validation input hashes changed", fileHashChecks];

baseCache = Quiet@Check[Get[baseCachePath], $Failed];
correctedCache = Quiet@Check[Get[correctedCachePath], $Failed];
diagnostic = Quiet@Check[Get[diagnosticPath], $Failed];
rawResidualCache = Quiet@Check[Get[rawResidualCachePath], $Failed];
inputChecks = <|
  "Associations" -> And @@ AssociationQ /@
    {baseCache, correctedCache, diagnostic, rawResidualCache},
  "Scopes" -> TrueQ[
    baseCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    correctedCache["Stage"] === "HqqV2S07FactorizationCache-v2" &&
    diagnostic["Stage"] ===
      "HqqV2S07InitialPPPProjectorRescalingDiagnostic-v1" &&
    rawResidualCache["Stage"] ===
      "HqqV2S07OrdinaryPPPRawResidualCache-v1" &&
    And @@ (# === scopeTag & /@ {
      baseCache["ScopeTag"], correctedCache["ScopeTag"],
      diagnostic["ScopeTag"], rawResidualCache["ScopeTag"]})],
  "CorrectionProducer" -> TrueQ[
    correctedCache["CorrectionSource", "SHA256"] ===
      expectedCorrectionProducerHash],
  "CorrectionBindings" -> TrueQ[
    correctedCache["Correction", "BaseCacheSHA256"] ===
      expectedBaseCacheHash &&
    correctedCache["Correction", "AcceptedDiagnosticSHA256"] ===
      expectedDiagnosticHash &&
    correctedCache["Correction", "RawResidualCacheSHA256"] ===
      expectedRawResidualCacheHash &&
    correctedCache["Correction", "ResidualSHA256"] ===
      expectedResidualHash],
  "ResidualIdentity" -> TrueQ[
    rawResidualCache["RawResidualMetadata", "SHA256"] ===
      expectedResidualHash &&
    expressionHash[rawResidualCache["RawResidual"]] ===
      expectedResidualHash],
  "StoredChecks" -> TrueQ[
    And @@ Values[baseCache["Checks"]] &&
    And @@ Values[correctedCache["Checks"]] &&
    And @@ Values[diagnostic["Checks"]] &&
    And @@ Values[rawResidualCache["Checks"]]]|>;
require[And @@ Values[inputChecks],
  "corrected-cache accepted inputs failed", inputChecks];

Print["S07_FACTOR_CACHE_VALIDATION_STAGE=independent scale derivation"];
xDefinition = xHat == Q2/(2 pDotQ);
parentXDefinition = xParent == Q2/(2 parentScale pDotQ);
momentumScaleSolutions = Quiet@Check[Solve[
  Last[parentXDefinition] == Last[xDefinition]/eta, parentScale], $Failed];
require[ListQ[momentumScaleSolutions] &&
    Length[momentumScaleSolutions] === 1,
  "validation xHat relation did not determine one momentum scale",
  momentumScaleSolutions];
momentumScaleRule = First[momentumScaleSolutions];
FeynCalc`DataType[parentScale, FeynCalc`FCVariable] = True;
externalDot = FeynCalc`FCI[FeynCalc`Pair[
  FeynCalc`Momentum[p, D], FeynCalc`Momentum[q, D]]];
parentDot = Quiet@Check[FeynCalc`ExpandScalarProduct[
  externalDot /. p -> parentScale p], $Failed];
externalPPP = FeynCalc`FCI[
  FeynCalc`Pair[FeynCalc`Momentum[p, D],
    FeynCalc`LorentzIndex[mu, D]]
  FeynCalc`Pair[FeynCalc`Momentum[p, D],
    FeynCalc`LorentzIndex[nu, D]]];
parentPPP = Quiet@Check[FeynCalc`ExpandScalarProduct[
  externalPPP /. p -> parentScale p], $Failed];
projectorScale = Quiet@Check[Cancel[Together[
  parentPPP/externalPPP]], $Failed];
projectorScaleEta = Quiet@Check[Cancel[Together[
  projectorScale /. momentumScaleRule]], $Failed];
conversionSolutions = Quiet@Check[Solve[
  pppConversion projectorScaleEta == 1, pppConversion], $Failed];
require[ListQ[conversionSolutions] && Length[conversionSolutions] === 1,
  "validation PPP tensor did not determine one conversion",
  conversionSolutions];
routeScaleEta = Quiet@Check[Cancel[Together[
  pppConversion /. First[conversionSolutions]]], $Failed];

baseFactorization = baseCache["Factorization"];
correctedFactorization = correctedCache["Factorization"];
initialConstraint = baseFactorization["InitialConstraint"];
etaRootSolutions = Quiet@Check[
  Solve[initialConstraint == 0, eta], $Failed];
require[ListQ[etaRootSolutions] && Length[etaRootSolutions] === 1,
  "validation initial constraint lacks one root", etaRootSolutions];
etaRootRule = First[etaRootSolutions];
routeScale = Quiet@Check[Cancel[Together[
  routeScaleEta /. etaRootRule]], $Failed];
routeScaleEndpoint = Quiet@Check[Cancel[Together[
  routeScale /. s23 -> 0]], $Failed];

scaleChecks = <|
  "SymbolicMomentumCoefficientDeclared" -> TrueQ[
    FeynCalc`DataType[parentScale, FeynCalc`FCVariable]],
  "XDefinitionReconstructs" -> exactZeroQ[
    (Last[parentXDefinition] - Last[xDefinition]/eta) /.
      momentumScaleRule],
  "ParentDotReconstructs" -> exactZeroQ[
    parentDot - parentScale externalDot],
  "ProjectorScaleReconstructs" -> exactZeroQ[
    parentPPP - projectorScale externalPPP],
  "ExternalConversionReconstructs" -> exactZeroQ[
    externalPPP - routeScaleEta (parentPPP /. momentumScaleRule)],
  "ConstraintRoot" -> exactZeroQ[initialConstraint /. etaRootRule],
  "EndpointUnity" -> exactZeroQ[routeScaleEndpoint - 1],
  "DiagnosticScaleAgreement" -> exactZeroQ[
    routeScale - diagnostic["Derivation", "RouteScale"]],
  "CacheScaleAgreement" -> exactZeroQ[
    routeScale - correctedCache["Correction", "DerivedRouteScale"]],
  "ScaleClosed" -> ! badSymbolicQ[routeScale] &&
    FreeQ[routeScale, eta | parentScale | pppConversion |
      FeynCalc`Pair | FeynCalc`Momentum | FeynCalc`LorentzIndex]|>;
require[And @@ Values[scaleChecks],
  "fresh corrected-cache scale derivation failed", scaleChecks];

boundedPlusCoefficient[expression_, label_String] := Module[
  {atoms, dummy, polynomial, coefficient, remainder},
  If[SameQ[expression, 0], Return[<|
    "Coefficient" -> 0, "Reconstruction" -> True|>]];
  atoms = DeleteDuplicates@Cases[Unevaluated[expression],
    HoldPattern[HqqV2BoundedPlus[_, s23, _]], Infinity];
  require[Length[atoms] === 1 && FreeQ[atoms[[1, 3]], s23],
    label <> " bounded-plus head is invalid", atoms];
  dummy = Unique["s07FactorValidationPlus"];
  polynomial = expression /. atoms[[1]] -> dummy;
  require[PolynomialQ[polynomial, dummy] &&
      Exponent[polynomial, dummy] === 1,
    label <> " is not linear in its bounded-plus head"];
  coefficient = Quiet@Check[Cancel[Together[
    Coefficient[polynomial, dummy, 1]]], $Failed];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - coefficient dummy]], $Failed];
  require[coefficient =!= $Failed && SameQ[remainder, 0] &&
      ! badSymbolicQ[coefficient] &&
      FreeQ[coefficient, dummy | HqqV2BoundedPlus],
    label <> " bounded-plus extraction failed"];
  <|"Coefficient" -> coefficient,
    "Reconstruction" -> exactZeroQ[
      expression - coefficient atoms[[1]]]|>
];

Print["S07_FACTOR_CACHE_VALIDATION_STAGE=reconstruct targets and sums"];
routes = baseFactorization["Routes"];
routeNames = Keys[routes];
initialRoutes = Select[routeNames,
  routes[#, "Direction"] === "Initial" &];
finalRoutes = Select[routeNames,
  routes[#, "Direction"] === "Final" &];
baseByRoute = baseFactorization["ByRouteLaurent"];
correctedByRoute = correctedFactorization["ByRouteLaurent"];
baseLedger = baseFactorization["LaurentLedger"];
correctedLedger = correctedFactorization["LaurentLedger"];
projectors = Keys[baseLedger];
sectors = Keys[baseLedger[First[projectors]]];
laurentPowers = Keys[baseLedger[First[projectors], First[sectors]]];
inventoryCheck = routeNames ===
      {"Initial_qq", "Initial_gq", "Final_qq", "Final_qg"} &&
    initialRoutes === {"Initial_qq", "Initial_gq"} &&
    finalRoutes === {"Final_qq", "Final_qg"} &&
    projectors === {"Pg", "PPP"} &&
    sectors === {"Delta", "BoundedPlus", "Ordinary"} &&
    laurentPowers === {-1, 0};
require[inventoryCheck,
  "fresh validation inventory changed"];
expectedTargetCount = Length[initialRoutes] Length[laurentPowers];
expectedRouteSumCount =
  Length[projectors] Length[sectors] Length[laurentPowers];

plusData = AssociationMap[Function[route,
  AssociationMap[Function[power, boundedPlusCoefficient[
    baseByRoute[route, "PPP", "BoundedPlus", power],
    route <> "/epsilon^" <> ToString[power]]], laurentPowers]],
  initialRoutes];
expectedTargets = AssociationMap[Function[route,
  AssociationMap[Function[power, Quiet@Check[Cancel[Together[
    routeScale baseByRoute[route, "PPP", "Ordinary", power] +
    (routeScale - 1) plusData[route, power, "Coefficient"]/s23]],
    $Failed]], laurentPowers]], initialRoutes];
targetRules = Flatten[Table[
  {Key[route], Key["PPP"], Key["Ordinary"], Key[power]} ->
    s07AuthorizedRouteTarget[route, power],
  {route, initialRoutes}, {power, laurentPowers}]];
ledgerTargetRules = Table[
  {Key["PPP"], Key["Ordinary"], Key[power]} ->
    s07AuthorizedLedgerTarget[power], {power, laurentPowers}];

targetChecks = Flatten[Table[
  exactZeroQ[correctedByRoute[route, "PPP", "Ordinary", power] -
    expectedTargets[route, power]],
  {route, initialRoutes}, {power, laurentPowers}]];
targetChangedChecks = Flatten[Table[
  ! exactZeroQ[correctedByRoute[route, "PPP", "Ordinary", power] -
    baseByRoute[route, "PPP", "Ordinary", power]],
  {route, initialRoutes}, {power, laurentPowers}]];
plusChecks = Flatten[Table[
  TrueQ[plusData[route, power, "Reconstruction"]],
  {route, initialRoutes}, {power, laurentPowers}]];
routeSumChecks = Association@Flatten[Table[
  (projector <> "/" <> sector <> "/" <> ToString[power]) ->
    exactZeroQ[correctedLedger[projector, sector, power] - Total[
      correctedByRoute[#, projector, sector, power] & /@ routeNames]],
  {projector, projectors}, {sector, sectors},
  {power, laurentPowers}]];
correctionSums = AssociationMap[Function[power,
  Quiet@Check[Cancel[Together[Total[
    correctedByRoute[#, "PPP", "Ordinary", power] -
      baseByRoute[#, "PPP", "Ordinary", power] & /@ initialRoutes]]],
    $Failed]], laurentPowers];
rawResidual = rawResidualCache["RawResidual"];
correctedPoleResidual = Quiet@Check[Cancel[Together[
  rawResidual + correctedLedger["PPP", "Ordinary", -1] -
    baseLedger["PPP", "Ordinary", -1]]], $Failed];

stableTopKeys = {"ScopeTag", "ProducerSource", "Inputs", "Conventions",
  "LowerBorn", "SplittingKernels"};
validationChecks = <|
  "Inventory" -> inventoryCheck,
  "PlusReconstruction" -> And @@ plusChecks,
  "FourTargetsReconstructed" ->
    Length[targetChecks] === expectedTargetCount &&
    And @@ targetChecks,
  "FourTargetsChanged" ->
    Length[targetChangedChecks] === expectedTargetCount &&
    And @@ targetChangedChecks,
  "AllRouteSumsReconstruct" ->
    Length[routeSumChecks] === expectedRouteSumCount &&
    And @@ Values[routeSumChecks],
  "NonTargetRoutesByteIdentical" -> SameQ[
    ReplacePart[correctedByRoute, targetRules],
    ReplacePart[baseByRoute, targetRules]],
  "NonTargetLedgersByteIdentical" -> SameQ[
    ReplacePart[correctedLedger, ledgerTargetRules],
    ReplacePart[baseLedger, ledgerTargetRules]],
  "FactorizationMetadataByteIdentical" -> SameQ[
    KeyDrop[correctedFactorization, {"ByRouteLaurent", "LaurentLedger"}],
    KeyDrop[baseFactorization, {"ByRouteLaurent", "LaurentLedger"}]],
  "StableTopLevelByteIdentical" -> And @@
    (SameQ[correctedCache[#], baseCache[#]] & /@ stableTopKeys),
  "BaseRuntimePreserved" -> SameQ[
    KeyTake[correctedCache["Runtime"], Keys[baseCache["Runtime"]]],
    baseCache["Runtime"]],
  "CorrectionLedgerFields" -> TrueQ[
    correctedCache["Correction", "InitialRoutes"] === initialRoutes &&
    correctedCache["Correction", "Projector"] === "PPP" &&
    correctedCache["Correction", "Sector"] === "Ordinary" &&
    correctedCache["Correction", "LaurentPowers"] === laurentPowers],
  "CorrectionSumsAgree" -> And @@
    (exactZeroQ[correctionSums[#] -
      correctedCache["Correction", "CorrectionSums", #]] & /@
      laurentPowers),
  "DiagnosticMinusOneAgreement" -> And @@
    (exactZeroQ[expectedTargets[#, -1] -
      diagnostic["CorrectedInitialPPPOrdinaryMinusOne", #]] & /@
      initialRoutes),
  "PoleResidualLiteralZero" -> SameQ[correctedPoleResidual, 0] &&
    SameQ[correctedCache["Correction", "CorrectedPoleResidual"], 0],
  "BaseCacheImmutable" ->
    FileHash[baseCachePath, "SHA256", "HexString"] ===
      expectedBaseCacheHash,
  "CorrectedCacheImmutableDuringValidation" ->
    FileHash[correctedCachePath, "SHA256", "HexString"] ===
      expectedCorrectedCacheHash,
  "ExactClosed" -> ! badSymbolicQ[
      {expectedTargets, correctionSums, correctedPoleResidual}] &&
    FreeQ[{expectedTargets, correctionSums, correctedPoleResidual},
      epsilon | D | eta | HqqV2BoundedPlus | _SeriesData | _Real]|>;
require[And @@ Values[validationChecks],
  "fresh corrected-cache validation failed", validationChecks];

checks = Join[fileHashChecks, inputChecks, scaleChecks, validationChecks];
require[And @@ Values[checks],
  "fresh corrected-cache aggregate gate failed", checks];

result = <|
  "Stage" -> "HqqV2S07FactorizationCacheValidation-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> <|
    "BaseCacheSHA256" -> expectedBaseCacheHash,
    "CorrectedCacheSHA256" -> expectedCorrectedCacheHash,
    "DiagnosticSHA256" -> expectedDiagnosticHash,
    "RawResidualCacheSHA256" -> expectedRawResidualCacheHash|>,
  "DerivedRouteScale" -> routeScale,
  "TargetHashes" -> AssociationMap[Function[route,
    AssociationMap[Function[power,
      expressionHash[expectedTargets[route, power]]], laurentPowers]],
    initialRoutes],
  "CorrectionSumHashes" -> Map[expressionHash, correctionSums],
  "CorrectedPoleResidual" -> correctedPoleResidual,
  "RouteSumChecks" -> routeSumChecks,
  "Checks" -> checks,
  "DownstreamBoundary" ->
    "S07 may consume only corrected factorization cache 4b5538d1...fcdef"|>;
atomicPut[result, resultPath];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, result] && And @@ Values[reloaded["Checks"]],
  "same-kernel corrected-cache validation reload failed"];
Print["S07_FACTOR_CACHE_VALIDATION_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_FACTOR_CACHE_VALIDATION_ROUTE_SCALE=", InputForm[routeScale]];
Print["S07_FACTOR_CACHE_VALIDATION_ROUTE_SUMS=",
  InputForm[routeSumChecks]];
Print["S07_FACTOR_CACHE_VALIDATION_CHECKS=", InputForm[checks]];
Print["S07_FACTOR_CACHE_VALIDATION_SUCCESS"];
Quit[0];

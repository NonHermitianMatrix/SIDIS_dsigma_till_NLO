(* Hqq_v2 S07: correct only initial-state PPP factorization cache fields. *)

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
  Print["S07_FACTOR_CACHE_CORRECTION_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_FACTOR_CACHE_CORRECTION_FAILURE_DETAIL=",
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
    fail["corrected factorization cache publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "corrected factorization temporary cache is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published corrected factorization cache is missing"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
baseCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
diagnosticPath = FileNameJoin[{stageDirectory,
  "s07_initial_ppp_projector_rescaling_diagnostic_result.wl"}];
rawResidualCachePath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_raw_residual_cache.wl"}];
correctedCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache_corrected.wl"}];

expectedBaseCacheHash =
  "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48";
expectedBaseProducerHash =
  "db2012e21e8abe0fe4c007f3811ed57fd4cd5f2635301fb107a0aa0bf45a7c00";
expectedDiagnosticHash =
  "6d74d4c16b74e8a4a2c97e921e85d30d81345bb340bb1a86e7572f5a9e51e70e";
expectedDiagnosticProducerHash =
  "df3703604186740cabc5e4212b4744d5a4a04f9801e2c6763ce4660b685f76e5";
expectedRawResidualCacheHash =
  "afc12bb8e9942d9059c0f1eda9e1e6d73d137e19af5dc0cf26651992edaad569";
expectedResidualHash =
  "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918";

requiredPaths = {baseCachePath, diagnosticPath, rawResidualCachePath};
require[And @@ FileExistsQ /@ requiredPaths &&
    ! FileExistsQ[correctedCachePath],
  "factorization cache correction input/target state is invalid"];
fileHashChecks = <|
  "BaseCache" -> FileHash[baseCachePath, "SHA256", "HexString"] ===
    expectedBaseCacheHash,
  "Diagnostic" -> FileHash[diagnosticPath, "SHA256", "HexString"] ===
    expectedDiagnosticHash,
  "RawResidualCache" ->
    FileHash[rawResidualCachePath, "SHA256", "HexString"] ===
      expectedRawResidualCacheHash|>;
require[And @@ Values[fileHashChecks],
  "factorization cache correction input hashes changed", fileHashChecks];

baseCache = Quiet@Check[Get[baseCachePath], $Failed];
diagnostic = Quiet@Check[Get[diagnosticPath], $Failed];
rawResidualCache = Quiet@Check[Get[rawResidualCachePath], $Failed];
inputChecks = <|
  "Associations" -> And @@ AssociationQ /@
    {baseCache, diagnostic, rawResidualCache},
  "BaseScope" -> TrueQ[AssociationQ[baseCache] &&
    baseCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    baseCache["ScopeTag"] === scopeTag &&
    baseCache["ProducerSource", "SHA256"] === expectedBaseProducerHash],
  "DiagnosticScope" -> TrueQ[AssociationQ[diagnostic] &&
    diagnostic["Stage"] ===
      "HqqV2S07InitialPPPProjectorRescalingDiagnostic-v1" &&
    diagnostic["ScopeTag"] === scopeTag &&
    diagnostic["Source", "SHA256"] ===
      expectedDiagnosticProducerHash],
  "RawResidualScope" -> TrueQ[AssociationQ[rawResidualCache] &&
    rawResidualCache["Stage"] ===
      "HqqV2S07OrdinaryPPPRawResidualCache-v1" &&
    rawResidualCache["ScopeTag"] === scopeTag &&
    rawResidualCache["RawResidualMetadata", "SHA256"] ===
      expectedResidualHash &&
    expressionHash[rawResidualCache["RawResidual"]] ===
      expectedResidualHash],
  "StoredChecks" -> TrueQ[
    And @@ Values[baseCache["Checks"]] &&
    And @@ Values[diagnostic["Checks"]] &&
    And @@ Values[rawResidualCache["Checks"]]]|>;
require[And @@ Values[inputChecks],
  "accepted cache correction inputs failed", inputChecks];

Print["S07_FACTOR_CACHE_CORRECTION_STAGE=rederive projector scale"];
xDefinition = xHat == Q2/(2 pDotQ);
parentXDefinition = xParent == Q2/(2 parentScale pDotQ);
momentumScaleSolutions = Quiet@Check[Solve[
  Last[parentXDefinition] == Last[xDefinition]/eta, parentScale], $Failed];
require[ListQ[momentumScaleSolutions] &&
    Length[momentumScaleSolutions] === 1,
  "xHat definition did not determine one parent momentum scale",
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
  "PPP tensor scale did not determine one external conversion",
  conversionSolutions];
routeScaleEta = Quiet@Check[Cancel[Together[
  pppConversion /. First[conversionSolutions]]], $Failed];

baseFactorization = baseCache["Factorization"];
routes = baseFactorization["Routes"];
routeNames = Keys[routes];
initialRoutes = Select[routeNames,
  routes[#, "Direction"] === "Initial" &];
finalRoutes = Select[routeNames,
  routes[#, "Direction"] === "Final" &];
initialConstraint = baseFactorization["InitialConstraint"];
etaRootSolutions = Quiet@Check[
  Solve[initialConstraint == 0, eta], $Failed];
require[ListQ[etaRootSolutions] && Length[etaRootSolutions] === 1,
  "initial constraint did not determine one eta root", etaRootSolutions];
etaRootRule = First[etaRootSolutions];
routeScale = Quiet@Check[Cancel[Together[
  routeScaleEta /. etaRootRule]], $Failed];
routeScaleEndpoint = Quiet@Check[Cancel[Together[
  routeScale /. s23 -> 0]], $Failed];

genericOldOrdinary = genericRegularDensity +
  (genericSingularDensity - genericEndpointPlusCoefficient)/genericS;
genericNewOrdinary = genericRouteScale genericRegularDensity +
  (genericRouteScale genericSingularDensity -
    genericEndpointPlusCoefficient)/genericS;
genericCachedRewrite = genericRouteScale genericOldOrdinary +
  (genericRouteScale - 1) genericEndpointPlusCoefficient/genericS;
genericIdentityCheck = exactZeroQ[
  genericNewOrdinary - genericCachedRewrite];

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
  "GenericCachedIdentity" -> genericIdentityCheck,
  "ScaleClosed" -> ! badSymbolicQ[routeScale] &&
    FreeQ[routeScale, eta | parentScale | pppConversion |
      FeynCalc`Pair | FeynCalc`Momentum | FeynCalc`LorentzIndex],
  "ScaleNontrivial" -> ! exactZeroQ[routeScale - 1]|>;
require[And @@ Values[scaleChecks],
  "independent factor-cache scale derivation failed", scaleChecks];

boundedPlusCoefficient[expression_, label_String] := Module[
  {atoms, dummy, polynomial, coefficient, remainder},
  If[SameQ[expression, 0], Return[<|
    "Head" -> 0, "Coefficient" -> 0,
    "Reconstruction" -> True|>]];
  atoms = DeleteDuplicates@Cases[Unevaluated[expression],
    HoldPattern[HqqV2BoundedPlus[_, s23, _]], Infinity];
  require[Length[atoms] === 1,
    label <> " does not contain exactly one bounded-plus head", atoms];
  require[FreeQ[atoms[[1, 3]], s23],
    label <> " bounded-plus upper bound depends on s23", atoms[[1]]];
  dummy = Unique["s07FactorCachePlus"];
  polynomial = expression /. atoms[[1]] -> dummy;
  require[PolynomialQ[polynomial, dummy] &&
      Exponent[polynomial, dummy] === 1,
    label <> " is not linear in its bounded-plus head"];
  coefficient = Quiet@Check[Cancel[Together[
    Coefficient[polynomial, dummy, 1]]], $Failed];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - coefficient dummy]], $Failed];
  require[coefficient =!= $Failed && remainder =!= $Failed &&
      SameQ[remainder, 0] && ! badSymbolicQ[coefficient] &&
      FreeQ[coefficient, dummy | HqqV2BoundedPlus],
    label <> " bounded-plus coefficient extraction failed",
    <|"Coefficient" -> coefficient, "Remainder" -> remainder|>];
  <|"Head" -> atoms[[1]], "Coefficient" -> coefficient,
    "Reconstruction" -> exactZeroQ[
      expression - coefficient atoms[[1]]]|>
];

Print["S07_FACTOR_CACHE_CORRECTION_STAGE=correct four cached fields"];
baseByRoute = baseFactorization["ByRouteLaurent"];
baseLedger = baseFactorization["LaurentLedger"];
laurentPowers = Keys[
  baseByRoute[First[initialRoutes], "PPP", "Ordinary"]];
require[laurentPowers === {-1, 0},
  "factorization Laurent powers changed", laurentPowers];

plusData = AssociationMap[Function[route,
  AssociationMap[Function[power, boundedPlusCoefficient[
    baseByRoute[route, "PPP", "BoundedPlus", power],
    route <> "/epsilon^" <> ToString[power]]], laurentPowers]],
  initialRoutes];
baseInitialOrdinary = AssociationMap[Function[route,
  AssociationMap[Function[power,
    baseByRoute[route, "PPP", "Ordinary", power]], laurentPowers]],
  initialRoutes];
correctedInitialOrdinary = AssociationMap[Function[route,
  AssociationMap[Function[power, Quiet@Check[Cancel[Together[
    routeScale baseInitialOrdinary[route, power] +
    (routeScale - 1) plusData[route, power, "Coefficient"]/s23]],
    $Failed]], laurentPowers]], initialRoutes];
routeCorrections = AssociationMap[Function[route,
  AssociationMap[Function[power, Quiet@Check[Cancel[Together[
    correctedInitialOrdinary[route, power] -
      baseInitialOrdinary[route, power]]], $Failed]], laurentPowers]],
  initialRoutes];
replacementRules = Flatten[Table[
  {Key[route], Key["PPP"], Key["Ordinary"], Key[power]} ->
    correctedInitialOrdinary[route, power],
  {route, initialRoutes}, {power, laurentPowers}]];
correctedByRoute = ReplacePart[baseByRoute, replacementRules];

correctedLedgerEntries = AssociationMap[Function[power,
  Quiet@Check[Cancel[Together[Total[
    correctedByRoute[#, "PPP", "Ordinary", power] & /@ routeNames]]],
    $Failed]], laurentPowers];
ledgerReplacementRules = Table[
  {Key["PPP"], Key["Ordinary"], Key[power]} ->
    correctedLedgerEntries[power], {power, laurentPowers}];
correctedLedger = ReplacePart[baseLedger, ledgerReplacementRules];
correctedFactorization = ReplacePart[baseFactorization, {
  Key["ByRouteLaurent"] -> correctedByRoute,
  Key["LaurentLedger"] -> correctedLedger}];

correctionSums = AssociationMap[Function[power,
  Quiet@Check[Cancel[Together[Total[
    routeCorrections[#, power] & /@ initialRoutes]]], $Failed]],
  laurentPowers];
rawResidual = rawResidualCache["RawResidual"];
correctedPoleResidual = Quiet@Check[Cancel[Together[
  rawResidual + correctedLedger["PPP", "Ordinary", -1] -
    baseLedger["PPP", "Ordinary", -1]]], $Failed];

routeSumChecks = AssociationMap[Function[power,
  exactZeroQ[baseLedger["PPP", "Ordinary", power] - Total[
    baseByRoute[#, "PPP", "Ordinary", power] & /@ routeNames]] &&
  exactZeroQ[correctedLedger["PPP", "Ordinary", power] - Total[
    correctedByRoute[#, "PPP", "Ordinary", power] & /@ routeNames]]],
  laurentPowers];
plusExtractionChecks = Flatten[Table[
  TrueQ[plusData[route, power, "Reconstruction"]],
  {route, initialRoutes}, {power, laurentPowers}]];
targetChangeChecks = Flatten[Table[
  ! exactZeroQ[routeCorrections[route, power]],
  {route, initialRoutes}, {power, laurentPowers}]];

structuralChecks = <|
  "RouteInventory" -> routeNames ===
      {"Initial_qq", "Initial_gq", "Final_qq", "Final_qg"} &&
    initialRoutes === {"Initial_qq", "Initial_gq"} &&
    finalRoutes === {"Final_qq", "Final_qg"},
  "PlusExtraction" -> And @@ plusExtractionChecks,
  "AllFourTargetsChanged" -> Length[targetChangeChecks] === 4 &&
    And @@ targetChangeChecks,
  "RouteSumsReconstruct" -> And @@ Values[routeSumChecks],
  "DiagnosticMinusOneFields" -> And @@
    (exactZeroQ[correctedInitialOrdinary[#, -1] -
      diagnostic["CorrectedInitialPPPOrdinaryMinusOne", #]] & /@
      initialRoutes),
  "DiagnosticMinusOneCorrection" -> exactZeroQ[
    correctionSums[-1] - diagnostic["CorrectionSum"]],
  "CachedResidualCancellation" -> SameQ[correctedPoleResidual, 0],
  "PgRoutesUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "Pg"], baseByRoute[#, "Pg"]] & /@
      routeNames),
  "PPPDeltaRoutesUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "PPP", "Delta"],
      baseByRoute[#, "PPP", "Delta"]] & /@ routeNames),
  "PPPPlusRoutesUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "PPP", "BoundedPlus"],
      baseByRoute[#, "PPP", "BoundedPlus"]] & /@ routeNames),
  "FinalRoutesUnchanged" -> And @@
    (SameQ[correctedByRoute[#], baseByRoute[#]] & /@ finalRoutes),
  "PgLedgerUnchanged" -> SameQ[
    correctedLedger["Pg"], baseLedger["Pg"]],
  "PPPDeltaLedgerUnchanged" -> SameQ[
    correctedLedger["PPP", "Delta"], baseLedger["PPP", "Delta"]],
  "PPPPlusLedgerUnchanged" -> SameQ[
    correctedLedger["PPP", "BoundedPlus"],
    baseLedger["PPP", "BoundedPlus"]],
  "FactorizationMetadataUnchanged" -> SameQ[
    KeyDrop[correctedFactorization, {"ByRouteLaurent", "LaurentLedger"}],
    KeyDrop[baseFactorization, {"ByRouteLaurent", "LaurentLedger"}]],
  "CorrectionsClosed" -> ! badSymbolicQ[
      {correctedInitialOrdinary, routeCorrections, correctionSums,
        correctedLedgerEntries}] &&
    FreeQ[{correctedInitialOrdinary, routeCorrections, correctionSums,
      correctedLedgerEntries}, epsilon | D | eta | HqqV2BoundedPlus],
  "OriginalCacheStillImmutable" ->
    FileHash[baseCachePath, "SHA256", "HexString"] ===
      expectedBaseCacheHash,
  "ExactClosed" -> ! badSymbolicQ[
      {correctedFactorization, correctedPoleResidual}] &&
    FreeQ[correctedFactorization, epsilon | D | _SeriesData | _Real]|>;
require[And @@ Values[structuralChecks],
  "corrected factorization cache fields failed", structuralChecks];

checks = Join[fileHashChecks, inputChecks, scaleChecks, structuralChecks];
require[And @@ Values[checks],
  "corrected factorization cache aggregate gate failed", checks];

correctionLedger = <|
  "BaseCacheSHA256" -> expectedBaseCacheHash,
  "AcceptedDiagnosticSHA256" -> expectedDiagnosticHash,
  "RawResidualCacheSHA256" -> expectedRawResidualCacheHash,
  "ResidualSHA256" -> expectedResidualHash,
  "InitialRoutes" -> initialRoutes,
  "Projector" -> "PPP",
  "Sector" -> "Ordinary",
  "LaurentPowers" -> laurentPowers,
  "DerivedRouteScale" -> routeScale,
  "PlusEndpointCoefficients" -> Map[
    Map[#["Coefficient"] &, #] &, plusData],
  "RouteCorrections" -> routeCorrections,
  "CorrectionSums" -> correctionSums,
  "CorrectedPoleResidual" -> correctedPoleResidual,
  "Metadata" -> <|
    "RouteScaleSHA256" -> expressionHash[routeScale],
    "MinusOneCorrectionSHA256" -> expressionHash[correctionSums[-1]],
    "FiniteCorrectionSHA256" -> expressionHash[correctionSums[0]]|>|>;

correctedRuntime = Join[baseCache["Runtime"], <|
  "CorrectionWolfram" -> $Version,
  "CorrectionFeynCalc" -> FeynCalc`$FeynCalcVersion|>];
correctedCache = Join[baseCache, <|
  "Stage" -> "HqqV2S07FactorizationCache-v2",
  "CorrectionSource" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Runtime" -> correctedRuntime,
  "Correction" -> correctionLedger,
  "Factorization" -> correctedFactorization,
  "Checks" -> checks|>];

Print["S07_FACTOR_CACHE_CORRECTION_STAGE=atomic publication"];
atomicPut[correctedCache, correctedCachePath];
reloaded = Quiet@Check[Get[correctedCachePath], $Failed];
require[SameQ[reloaded, correctedCache] &&
    And @@ Values[reloaded["Checks"]] &&
    FileHash[baseCachePath, "SHA256", "HexString"] ===
      expectedBaseCacheHash,
  "same-kernel corrected factorization cache reload failed"];
Print["S07_FACTOR_CACHE_CORRECTED_SHA256=",
  FileHash[correctedCachePath, "SHA256", "HexString"]];
Print["S07_FACTOR_CACHE_ROUTE_SCALE=", InputForm[routeScale]];
Print["S07_FACTOR_CACHE_CORRECTION_HASHES=", InputForm[
  Map[expressionHash, correctionSums]]];
Print["S07_FACTOR_CACHE_CORRECTION_CHECKS=", InputForm[checks]];
Print["S07_FACTOR_CACHE_CORRECTION_SUCCESS"];
Quit[0];

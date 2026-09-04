(* Hqq_v2 S07: diagnose the initial-state PPP projector rescaling. *)

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
  Print["S07_INITIAL_PPP_SCALE_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_INITIAL_PPP_SCALE_FAILURE_DETAIL=", InputForm[detail]]];
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
    fail["projector-rescaling diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "projector-rescaling diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published projector-rescaling diagnostic is missing"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
rawResidualCachePath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_raw_residual_cache.wl"}];
rationalFactorResultPath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_rational_factor_result.wl"}];
resultPath = FileNameJoin[{stageDirectory,
  "s07_initial_ppp_projector_rescaling_diagnostic_result.wl"}];

expectedFactorizationCacheHash =
  "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48";
expectedFactorizationProducerHash =
  "db2012e21e8abe0fe4c007f3811ed57fd4cd5f2635301fb107a0aa0bf45a7c00";
expectedRawResidualCacheHash =
  "afc12bb8e9942d9059c0f1eda9e1e6d73d137e19af5dc0cf26651992edaad569";
expectedRawResidualProducerHash =
  "f66a719faf20465e6986eb2b8f592c5b7449f9efad41d32be715abbed154ebc6";
expectedRationalFactorResultHash =
  "633223d4714264ba56b5c20bac98c28d219386f97eb05f3c9c5399f7efe5ddf9";
expectedRationalFactorProducerHash =
  "7fab2aa040b7cd41aa9f1f591f51e0a80f9ea7582d642d78d83eb4f14d296ba9";
expectedResidualHash =
  "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918";

requiredPaths = {factorizationCachePath, rawResidualCachePath,
  rationalFactorResultPath};
require[And @@ FileExistsQ /@ requiredPaths && ! FileExistsQ[resultPath],
  "projector-rescaling input/target state is invalid"];
fileHashChecks = <|
  "FactorizationCache" ->
    FileHash[factorizationCachePath, "SHA256", "HexString"] ===
      expectedFactorizationCacheHash,
  "RawResidualCache" ->
    FileHash[rawResidualCachePath, "SHA256", "HexString"] ===
      expectedRawResidualCacheHash,
  "RationalFactorResult" ->
    FileHash[rationalFactorResultPath, "SHA256", "HexString"] ===
      expectedRationalFactorResultHash|>;
require[And @@ Values[fileHashChecks],
  "projector-rescaling input hashes changed", fileHashChecks];

factorizationCache = Quiet@Check[Get[factorizationCachePath], $Failed];
rawResidualCache = Quiet@Check[Get[rawResidualCachePath], $Failed];
rationalFactorResult = Quiet@Check[
  Get[rationalFactorResultPath], $Failed];
inputChecks = <|
  "Associations" -> And @@ AssociationQ /@
    {factorizationCache, rawResidualCache, rationalFactorResult},
  "FactorizationScope" -> TrueQ[AssociationQ[factorizationCache] &&
    factorizationCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    factorizationCache["ScopeTag"] === scopeTag &&
    factorizationCache["ProducerSource", "SHA256"] ===
      expectedFactorizationProducerHash],
  "RawResidualScope" -> TrueQ[AssociationQ[rawResidualCache] &&
    rawResidualCache["Stage"] ===
      "HqqV2S07OrdinaryPPPRawResidualCache-v1" &&
    rawResidualCache["ScopeTag"] === scopeTag &&
    rawResidualCache["Source", "SHA256"] ===
      expectedRawResidualProducerHash],
  "RationalFactorScope" -> TrueQ[AssociationQ[rationalFactorResult] &&
    rationalFactorResult["Stage"] ===
      "HqqV2S07OrdinaryPPPRationalFactor-v1" &&
    rationalFactorResult["ScopeTag"] === scopeTag &&
    rationalFactorResult["Source", "SHA256"] ===
      expectedRationalFactorProducerHash],
  "StoredChecks" -> TrueQ[
    And @@ Values[factorizationCache["Checks"]] &&
    And @@ Values[rawResidualCache["Checks"]] &&
    And @@ Values[rationalFactorResult["Checks"]]],
  "ResidualIdentity" -> TrueQ[
    rawResidualCache["RawResidualMetadata", "SHA256"] ===
      expectedResidualHash &&
    expressionHash[rawResidualCache["RawResidual"]] ===
      expectedResidualHash &&
    exactZeroQ[rationalFactorResult["FactoredResidual"] -
      rawResidualCache["RawResidual"]]]|>;
require[And @@ Values[inputChecks],
  "accepted projector-rescaling inputs failed", inputChecks];

Print["S07_INITIAL_PPP_SCALE_STAGE=derive momentum and projector scales"];
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

factorization = factorizationCache["Factorization"];
routes = factorization["Routes"];
routeNames = Keys[routes];
initialRoutes = Select[routeNames,
  routes[#, "Direction"] === "Initial" &];
finalRoutes = Select[routeNames,
  routes[#, "Direction"] === "Final" &];
initialConstraint = factorization["InitialConstraint"];
etaRootSolutions = Quiet@Check[
  Solve[initialConstraint == 0, eta], $Failed];
require[ListQ[etaRootSolutions] && Length[etaRootSolutions] === 1,
  "initial constraint did not determine one eta root", etaRootSolutions];
etaRootRule = First[etaRootSolutions];
routeScale = Quiet@Check[Cancel[Together[
  routeScaleEta /. etaRootRule]], $Failed];
routeScaleEndpoint = Quiet@Check[Cancel[Together[
  routeScale /. s23 -> 0]], $Failed];

scaleChecks = <|
  "SymbolicMomentumCoefficientDeclared" -> TrueQ[
    FeynCalc`DataType[parentScale, FeynCalc`FCVariable]],
  "FeynCalcObjects" -> FreeQ[
    {parentDot, parentPPP, projectorScale, routeScaleEta, routeScale},
    $Failed | _Real],
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
  "ScaleClosed" -> ! badSymbolicQ[routeScale] &&
    FreeQ[routeScale, eta | parentScale | pppConversion |
      FeynCalc`Pair | FeynCalc`Momentum | FeynCalc`LorentzIndex],
  "ScaleNontrivial" -> ! exactZeroQ[routeScale - 1]|>;
require[And @@ Values[scaleChecks],
  "tool-derived initial PPP route scale failed", scaleChecks];

Print["S07_INITIAL_PPP_SCALE_STAGE=derive cached ordinary identity"];
genericOldOrdinary = genericRegularDensity +
  (genericSingularDensity - genericEndpointPlusCoefficient)/genericS;
genericNewOrdinary = genericRouteScale genericRegularDensity +
  (genericRouteScale genericSingularDensity -
    genericEndpointPlusCoefficient)/genericS;
genericCachedRewrite = genericRouteScale genericOldOrdinary +
  (genericRouteScale - 1) genericEndpointPlusCoefficient/genericS;
genericIdentityCheck = exactZeroQ[
  genericNewOrdinary - genericCachedRewrite];
require[genericIdentityCheck,
  "cached ordinary rescaling identity was not derived exactly"];

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
  dummy = Unique["s07InitialPPPPlus"];
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

byRoute = factorization["ByRouteLaurent"];
plusData = AssociationMap[boundedPlusCoefficient[
  byRoute[#, "PPP", "BoundedPlus", -1], #] &, initialRoutes];
oldInitialOrdinary = AssociationMap[
  byRoute[#, "PPP", "Ordinary", -1] &, initialRoutes];
correctedInitialOrdinary = AssociationMap[Quiet@Check[
  Cancel[Together[
    routeScale oldInitialOrdinary[#] +
    (routeScale - 1) plusData[#, "Coefficient"]/s23]], $Failed] &,
  initialRoutes];
routeCorrections = AssociationMap[Quiet@Check[Cancel[Together[
  correctedInitialOrdinary[#] - oldInitialOrdinary[#]]], $Failed] &,
  initialRoutes];
correctionSum = Quiet@Check[Cancel[Together[
  Total[Values[routeCorrections]]]], $Failed];

correctedByRoute = Fold[
  Function[{current, route}, ReplacePart[current,
    {Key[route], Key["PPP"], Key["Ordinary"], Key[-1]} ->
      correctedInitialOrdinary[route]]], byRoute, initialRoutes];
oldRouteSum = Quiet@Check[Cancel[Together[Total[
  byRoute[#, "PPP", "Ordinary", -1] & /@ routeNames]]], $Failed];
correctedRouteSum = Quiet@Check[Cancel[Together[Total[
  correctedByRoute[#, "PPP", "Ordinary", -1] & /@ routeNames]]],
  $Failed];
oldLedger = factorization["LaurentLedger", "PPP", "Ordinary", -1];
rawResidual = rawResidualCache["RawResidual"];
correctedResidual = Quiet@Check[Cancel[Together[
  rawResidual + correctedRouteSum - oldLedger]], $Failed];

structuralChecks = <|
  "RouteInventory" -> routeNames ===
      {"Initial_qq", "Initial_gq", "Final_qq", "Final_qg"} &&
    initialRoutes === {"Initial_qq", "Initial_gq"} &&
    finalRoutes === {"Final_qq", "Final_qg"},
  "PlusExtraction" -> And @@
    (TrueQ[plusData[#, "Reconstruction"]] & /@ initialRoutes),
  "CorrectionsClosed" -> ! badSymbolicQ[
      {correctedInitialOrdinary, routeCorrections, correctionSum}] &&
    FreeQ[{correctedInitialOrdinary, routeCorrections, correctionSum},
      epsilon | D | eta | HqqV2BoundedPlus],
  "CorrectionsNonzero" -> And @@
    (! exactZeroQ[routeCorrections[#]] & /@ initialRoutes),
  "OldRouteSumReconstructsLedger" -> exactZeroQ[
    oldRouteSum - oldLedger],
  "CorrectedRouteSumIsOldPlusCorrection" -> exactZeroQ[
    correctedRouteSum - oldLedger - correctionSum],
  "PgUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "Pg"], byRoute[#, "Pg"]] & /@
      routeNames),
  "DeltaUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "PPP", "Delta"],
      byRoute[#, "PPP", "Delta"]] & /@ routeNames),
  "BoundedPlusUnchanged" -> And @@
    (SameQ[correctedByRoute[#, "PPP", "BoundedPlus"],
      byRoute[#, "PPP", "BoundedPlus"]] & /@ routeNames),
  "FinalRoutesUnchanged" -> And @@
    (SameQ[correctedByRoute[#], byRoute[#]] & /@ finalRoutes),
  "InitialOtherOrdinaryPowersUnchanged" -> And @@
    (SameQ[KeyDrop[correctedByRoute[#, "PPP", "Ordinary"], {-1}],
      KeyDrop[byRoute[#, "PPP", "Ordinary"], {-1}]] & /@
      initialRoutes),
  "CorrectionCancelsCachedResidual" -> exactZeroQ[
    rawResidual + correctionSum],
  "CorrectedResidual" -> SameQ[correctedResidual, 0],
  "ExactClosed" -> ! badSymbolicQ[
      {oldRouteSum, correctedRouteSum, correctedResidual}] &&
    FreeQ[{oldRouteSum, correctedRouteSum, correctedResidual},
      epsilon | D | eta | _SeriesData | _Real]|>;
require[And @@ Values[structuralChecks],
  "initial PPP cached-route correction failed", structuralChecks];

checks = Join[fileHashChecks, inputChecks, scaleChecks, <|
  "GenericCachedIdentity" -> genericIdentityCheck|>, structuralChecks];
require[And @@ Values[checks],
  "projector-rescaling diagnostic aggregate gate failed", checks];

result = <|
  "Stage" -> "HqqV2S07InitialPPPProjectorRescalingDiagnostic-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> <|
    "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
    "RawResidualCacheSHA256" -> expectedRawResidualCacheHash,
    "RationalFactorResultSHA256" -> expectedRationalFactorResultHash,
    "ResidualSHA256" -> expectedResidualHash|>,
  "Derivation" -> <|
    "XDefinition" -> xDefinition,
    "ParentXDefinition" -> parentXDefinition,
    "MomentumScaleRule" -> momentumScaleRule,
    "ExternalPPP" -> externalPPP,
    "ParentPPP" -> parentPPP,
    "ProjectorScale" -> projectorScale,
    "ExternalConversionInEta" -> routeScaleEta,
    "InitialConstraint" -> initialConstraint,
    "EtaRootRule" -> etaRootRule,
    "RouteScale" -> routeScale,
    "RouteScaleEndpoint" -> routeScaleEndpoint,
    "GenericOldOrdinary" -> genericOldOrdinary,
    "GenericNewOrdinary" -> genericNewOrdinary,
    "GenericCachedRewrite" -> genericCachedRewrite|>,
  "InitialRoutes" -> initialRoutes,
  "PlusEndpointCoefficients" ->
    Map[#["Coefficient"] &, plusData],
  "CorrectedInitialPPPOrdinaryMinusOne" -> correctedInitialOrdinary,
  "RouteCorrections" -> routeCorrections,
  "CorrectionSum" -> correctionSum,
  "CorrectedResidual" -> correctedResidual,
  "Metadata" -> <|
    "RouteScaleSHA256" -> expressionHash[routeScale],
    "CorrectionSumSHA256" -> expressionHash[correctionSum],
    "CorrectedRouteSumSHA256" -> expressionHash[correctedRouteSum],
    "CorrectedResidualSHA256" -> expressionHash[correctedResidual]|>,
  "Checks" -> checks,
  "DownstreamBoundary" ->
    "regenerate only initial PPP ordinary Laurent fields from the accepted factorization cache"|>;

atomicPut[result, resultPath];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, result] && And @@ Values[reloaded["Checks"]],
  "same-kernel projector-rescaling diagnostic reload failed"];
Print["S07_INITIAL_PPP_SCALE_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_INITIAL_PPP_SCALE_ROUTE_SCALE=", InputForm[routeScale]];
Print["S07_INITIAL_PPP_SCALE_CORRECTION_HASH=",
  expressionHash[correctionSum]];
Print["S07_INITIAL_PPP_SCALE_CHECKS=", InputForm[checks]];
Print["S07_INITIAL_PPP_SCALE_SUCCESS"];
Quit[0];

(* Hqq_v2 S07: diagnose the ordinary PPP logarithm basis. *)

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
  expressionHash, balancedExactSum, carrierCoefficient,
  canonicalCombinationBasis, mapInterior, mapEndpointKinematics,
  endpointSubtractedOrdinary, canonicalLogArgumentsOnce,
  canonicalLogArguments, currentVirtualOrdinary,
  currentFactorizationOrdinary];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_ORDINARY_LOG_DIAGNOSTIC_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_ORDINARY_LOG_DIAGNOSTIC_FAILURE_DETAIL=",
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
    fail["ordinary-log diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "ordinary-log diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published ordinary-log diagnostic is missing"];
];
balancedExactSum[values_List, label_String] := Module[{level, next},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed && ! badSymbolicQ[level],
    label <> " canonicalization failed"];
  level = DeleteCases[level, 0];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Quiet@Check[
      Map[If[Length[#] === 1, First[#],
        Cancel[Together[#[[1]] + #[[2]]]]] &,
        Partition[level, UpTo[2]]], $Failed];
    require[next =!= $Failed && ! badSymbolicQ[next],
      label <> " balanced addition failed"];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];
carrierCoefficient[data_Association, alpha_Integer, power_Integer] :=
  Total@Table[If[sourcePower <= power,
      Lookup[data, sourcePower, 0] *
        (-alpha Log[s23])^(power - sourcePower)/
          Factorial[power - sourcePower], 0],
    {sourcePower, Keys[data]}];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_log_basis_diagnostic_result.wl"}];
rawCachePath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_raw_residual_cache.wl"}];
inputPaths = <|
  "S07Consumer" -> FileNameJoin[{stageDirectory,
    "s07_combine_hqq_from_cache.wl"}],
  "PartialOrdinaryDiagnostic" -> FileNameJoin[{stageDirectory,
    "s07_ordinary_endpoint_subtraction_diagnostic_result.wl"}],
  "CorrectedS05" -> FileNameJoin[{stageDirectory, "s05_result.wl"}],
  "CorrectedS06" -> FileNameJoin[{stageDirectory, "s06_result.wl"}],
  "FactorizationCache" -> FileNameJoin[{stageDirectory,
    "s07_factorization_laurent_cache.wl"}]|>;
expectedHashes = <|
  "S07Consumer" ->
    "c2f73601702a7425eb78d46d6f818b59b7e3c9e66038e6c6d8598435f9a49864",
  "PartialOrdinaryDiagnostic" ->
    "cc9368de2a72575f1891e0b6b39902851919d2b96ee99341647c1be365895b8b",
  "CorrectedS05" ->
    "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb",
  "CorrectedS06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48"|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[resultPath] && ! FileExistsQ[rawCachePath],
  "ordinary-log diagnostic input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] ===
    expectedHashes[#] &, Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "ordinary-log diagnostic input identity failed", identityChecks];

Print["S07_ORDINARY_LOG_DIAGNOSTIC_STAGE=load accepted fields"];
partialDiagnostic = Quiet@Check[
  Get[inputPaths["PartialOrdinaryDiagnostic"]], $Failed];
s05 = Quiet@Check[Get[inputPaths["CorrectedS05"]], $Failed];
s06 = Quiet@Check[Get[inputPaths["CorrectedS06"]], $Failed];
factorizationCache = Quiet@Check[
  Get[inputPaths["FactorizationCache"]], $Failed];
partialAcceptedChecks = If[AssociationQ[partialDiagnostic] &&
    AssociationQ[partialDiagnostic["Checks"]],
  KeyDrop[partialDiagnostic["Checks"],
    {"EndpointSubtractedPPPZero"}], <||>];
schemaChecks = <|
  "Associations" -> And @@ Map[AssociationQ,
    {partialDiagnostic, s05, s06, factorizationCache}],
  "Scopes" -> And @@ Map[#1["ScopeTag"] === scopeTag &,
    {partialDiagnostic, s05, s06, factorizationCache}],
  "PartialDiagnostic" -> TrueQ[
    partialDiagnostic["Stage"] ===
      "HqqV2S07OrdinaryEndpointSubtractionDiagnostic-v1" &&
    partialDiagnostic["Source", "SHA256"] ===
      "4be3510bbedac05f613d60602c833bd689d02307ccb874a8aac7d7ff2de67779" &&
    And @@ Values[partialAcceptedChecks] &&
    partialDiagnostic["Checks", "EndpointSubtractedPPPZero"] === False &&
    partialDiagnostic["EndpointSubtractedResidualMetadata", "Pg",
      "Zero"] === True &&
    partialDiagnostic["EndpointSubtractedResidualMetadata", "PPP",
      "Zero"] === False &&
    partialDiagnostic["EndpointSubtractedResidualMetadata", "PPP",
      "SHA256"] ===
      "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918"],
  "CorrectedS05" -> TrueQ[s05["Stage"] === "HqqV2S05-v2" &&
    And @@ Values[s05["Checks"]] &&
    And @@ Values[s05["Correction", "Checks"]]],
  "CorrectedS06" -> TrueQ[s06["Stage"] === "HqqV2S06-v2" &&
    And @@ Values[s06["Checks"]]],
  "Factorization" -> TrueQ[
    factorizationCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    And @@ Values[factorizationCache["Checks"]]],
  "NoProducerCacheInput" -> Intersection[Keys[inputPaths],
    {"AngularMasterCache", "CoefficientCache", "EndpointCache",
      "RootGroupCache", "DirectEndpointCache",
      "PushforwardProducer"}] === {}|>;
require[And @@ Values[schemaChecks],
  "ordinary-log diagnostic schema gate failed", schemaChecks];

projector = "PPP";
realFamilies = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"};
power = -1;
realLedger = s05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
factorizationLedger =
  factorizationCache["Factorization", "LaurentLedger"];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {realLedger, virtualLedger, factorizationLedger}, _PolyGamma, Infinity];
combinationSpecialValues = Quiet@Check[
  FunctionExpand /@ combinationSpecialAtoms, $Failed];
require[combinationSpecialValues =!= $Failed &&
    FreeQ[combinationSpecialValues, _PolyGamma] &&
    ! badSymbolicQ[combinationSpecialValues],
  "ordinary-log special-function expansion failed"];
combinationSpecialResiduals = Quiet@Check[
  MapThread[FullSimplify[#1 - #2] &,
    {combinationSpecialAtoms, combinationSpecialValues}], $Failed];
require[combinationSpecialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "ordinary-log special-function identity failed"];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
mapInterior[expression_] := canonicalCombinationBasis[expression] /.
  u1Rule;
mapEndpointKinematics[expression_, label_String] := Module[
  {held, mapped},
  require[FreeQ[expression, s07HeldExplicitLogS23],
    label <> " contains the hold symbol"];
  held = expression /.
    HoldPattern[Log[s23]] -> s07HeldExplicitLogS23;
  mapped = Quiet@Check[Cancel[Together[
    canonicalCombinationBasis[held] /. u1Rule /. s23 -> 0]],
    $Failed];
  require[mapped =!= $Failed && ! badSymbolicQ[mapped] &&
      FreeQ[mapped, s23 | u1],
    label <> " endpoint-kinematic map failed"];
  mapped /. s07HeldExplicitLogS23 -> Log[s23]
];
endpointSubtractedOrdinary[family_String] := Module[
  {ordinary, endpointByAlpha, endpointTerms, rawSingular,
   mappedRawSingular, mappedEndpointSingular},
  ordinary = Lookup[
    realLedger[projector, family, "OrdinaryLaurent"], power, 0];
  endpointByAlpha = realLedger[projector, family,
    "EndpointResidueByAlphaThroughEpsilon1"];
  endpointTerms = AssociationMap[
    carrierCoefficient[endpointByAlpha[#], #, power] &,
    Keys[endpointByAlpha]];
  rawSingular = (#/s23) & /@ Values[endpointTerms];
  mappedRawSingular = mapInterior /@ rawSingular;
  mappedEndpointSingular = MapThread[
    mapEndpointKinematics[#1,
      projector <> "/" <> family <> "/alpha=" <> ToString[#2]]/
        s23 &,
    {Values[endpointTerms], Keys[endpointTerms]}];
  mapInterior[ordinary] + Total[MapThread[Subtract,
    {mappedRawSingular, mappedEndpointSingular}]]
];
currentVirtualOrdinary[expression_] :=
  canonicalCombinationBasis[expression] /.
    {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0;
currentFactorizationOrdinary[expression_] :=
  canonicalCombinationBasis[expression];

canonicalLogArgumentsOnce[expression_] := expression /.
  HoldPattern[Log[argument_]] :>
    Log[Factor[Cancel[Together[argument]]]];
canonicalLogArguments[expression_] := Module[{answer},
  answer = FixedPoint[canonicalLogArgumentsOnce, expression, 8];
  require[SameQ[answer, canonicalLogArgumentsOnce[answer]],
    "ordinary-log canonicalization did not reach a fixed point"];
  answer
];

Print["S07_ORDINARY_LOG_DIAGNOSTIC_STAGE=reconstruct PPP residual"];
realContributions = endpointSubtractedOrdinary /@ realFamilies;
virtualContribution = currentVirtualOrdinary[Lookup[
  virtualLedger[projector, "OrdinaryLaurent"], power, 0]];
factorizationContribution = currentFactorizationOrdinary[Lookup[
  factorizationLedger[projector, "Ordinary"], power, 0]];
contributions = Join[realContributions,
  {virtualContribution, factorizationContribution}];
rawResidual = balancedExactSum[contributions,
  "PPP/endpoint-subtracted-ordinary-single"];
rawAgreementChecks = <|
  "Nonzero" -> ! exactZeroQ[rawResidual],
  "LeafCount" -> LeafCount[rawResidual] ===
    partialDiagnostic["EndpointSubtractedResidualMetadata", "PPP",
      "LeafCount"],
  "SHA256" -> expressionHash[rawResidual] ===
    partialDiagnostic["EndpointSubtractedResidualMetadata", "PPP",
      "SHA256"]|>;
require[And @@ Values[rawAgreementChecks],
  "reconstructed PPP residual disagrees with partial diagnostic",
  rawAgreementChecks];

rawCacheChecks = <|
  "InputIdentities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "RawResidualAgreement" -> And @@ Values[rawAgreementChecks],
  "ResidualIsRationalLogFree" -> FreeQ[rawResidual, _Log],
  "ExactClosed" -> ! badSymbolicQ[rawResidual] &&
    FreeQ[rawResidual, epsilon | D | _SeriesData | _Real]|>;
rawCache = <|
  "Stage" -> "HqqV2S07OrdinaryPPPRawResidualCache-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> expectedHashes,
  "Location" -> <|"Projector" -> projector,
    "Sector" -> "Ordinary", "EpsilonPower" -> power|>,
  "RawResidual" -> rawResidual,
  "RawResidualMetadata" -> <|
    "Zero" -> exactZeroQ[rawResidual],
    "LeafCount" -> LeafCount[rawResidual],
    "SHA256" -> expressionHash[rawResidual]|>,
  "Checks" -> rawCacheChecks,
  "DownstreamBoundary" ->
    "rational-residual diagnostics load this cache and do not rebuild the ordinary ledger sum"|>;
require[And @@ Values[rawCacheChecks],
  "PPP raw-residual cache gates failed", rawCacheChecks];
atomicPut[rawCache, rawCachePath];
rawCacheReload = Quiet@Check[Get[rawCachePath], $Failed];
require[SameQ[rawCacheReload, rawCache],
  "same-kernel PPP raw-residual cache reload failed"];
Print["S07_ORDINARY_PPP_RAW_CACHE_SHA256=",
  FileHash[rawCachePath, "SHA256", "HexString"]];

Print["S07_ORDINARY_LOG_DIAGNOSTIC_STAGE=canonicalize log arguments"];
logAtoms = DeleteDuplicates@Cases[rawResidual, _Log, Infinity];
If[logAtoms === {},
  Print["S07_ORDINARY_PPP_RAW_CACHE_READY"];
  Quit[0]
];
canonicalLogAtoms = canonicalLogArgumentsOnce /@ logAtoms;
argumentIdentityChecks = MapThread[exactZeroQ[
    First[#1] - First[#2]] &, {logAtoms, canonicalLogAtoms}];
canonicalContributions = canonicalLogArguments /@ contributions;
componentwiseResidual = balancedExactSum[canonicalContributions,
  "PPP/canonical-log-ordinary-single"];
canonicalWhole = canonicalLogArguments[rawResidual];
wholeResidual = Quiet@Check[Cancel[Together[
  canonicalWhole]], $Failed];
require[wholeResidual =!= $Failed && ! badSymbolicQ[wholeResidual],
  "whole PPP log-basis reduction failed"];

checks = <|
  "InputIdentities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "RawResidualAgreement" -> And @@ Values[rawAgreementChecks],
  "EveryLogArgumentAlgebraicallyIdentical" ->
    And @@ argumentIdentityChecks,
  "EveryComponentAtFixedPoint" -> And @@ Map[
    SameQ[#, canonicalLogArgumentsOnce[#]] &,
    canonicalContributions],
  "WholeAtFixedPoint" ->
    SameQ[canonicalWhole, canonicalLogArgumentsOnce[canonicalWhole]],
  "WholeAndComponentwiseAgree" -> exactZeroQ[
    wholeResidual - componentwiseResidual],
  "CanonicalPPPZero" -> SameQ[componentwiseResidual, 0] &&
    SameQ[wholeResidual, 0],
  "NoBranchTransform" -> FreeQ[
    {canonicalLogAtoms, canonicalContributions}, PowerExpand],
  "NoProducerCacheInput" -> schemaChecks["NoProducerCacheInput"],
  "ExactClosed" -> ! badSymbolicQ[
    {canonicalLogAtoms, canonicalContributions,
      componentwiseResidual, wholeResidual}] &&
    FreeQ[canonicalContributions,
      epsilon | D | _SeriesData | _Real | s07HeldExplicitLogS23]|>;

diagnosticResult = <|
  "Stage" -> "HqqV2S07OrdinaryPPPLogBasisDiagnostic-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> expectedHashes,
  "Location" -> <|"Projector" -> projector,
    "Sector" -> "Ordinary", "EpsilonPower" -> power|>,
  "RawResidualMetadata" -> <|
    "Zero" -> exactZeroQ[rawResidual],
    "LeafCount" -> LeafCount[rawResidual],
    "SHA256" -> expressionHash[rawResidual]|>,
  "LogBasisMetadata" -> <|
    "AtomCount" -> Length[logAtoms],
    "OriginalAtomsSHA256" -> expressionHash[logAtoms],
    "CanonicalAtomsSHA256" -> expressionHash[canonicalLogAtoms],
    "ComponentwiseResidualZero" ->
      SameQ[componentwiseResidual, 0],
    "WholeResidualZero" -> SameQ[wholeResidual, 0],
    "ComponentwiseResidualSHA256" ->
      expressionHash[componentwiseResidual],
    "WholeResidualSHA256" -> expressionHash[wholeResidual]|>,
  "Checks" -> checks|>;
require[! FileExistsQ[resultPath],
  "refusing to overwrite an ordinary-log diagnostic"];
atomicPut[diagnosticResult, resultPath];
Print["S07_ORDINARY_LOG_DIAGNOSTIC_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, diagnosticResult],
  "same-kernel ordinary-log diagnostic reload failed"];
Print["S07_ORDINARY_LOG_DIAGNOSTIC_METADATA=",
  InputForm[diagnosticResult["LogBasisMetadata"]]];
Print["S07_ORDINARY_LOG_DIAGNOSTIC_CHECKS=", InputForm[checks]];
If[And @@ Values[checks],
  Print["S07_ORDINARY_LOG_DIAGNOSTIC_SUCCESS"];
  Quit[0],
  fail["PPP log-basis candidate failed", checks]
];

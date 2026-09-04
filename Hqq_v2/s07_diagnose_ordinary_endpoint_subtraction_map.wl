(* Hqq_v2 S07: diagnose the real ordinary endpoint-subtraction map. *)

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
  boundedPlusCoefficient, ordinaryMapRecord, currentVirtualOrdinary,
  currentFactorizationOrdinary];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_ORDINARY_DIAGNOSTIC_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_ORDINARY_DIAGNOSTIC_FAILURE_DETAIL=",
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
    fail["ordinary diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "ordinary diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published ordinary diagnostic is missing"];
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
  "s07_ordinary_endpoint_subtraction_diagnostic_result.wl"}];
inputPaths = <|
  "S07Consumer" -> FileNameJoin[{stageDirectory,
    "s07_combine_hqq_from_cache.wl"}],
  "FailedDiagnostic" -> FileNameJoin[{stageDirectory,
    "s07_combination_diagnostic_result.wl"}],
  "CorrectedS05" -> FileNameJoin[{stageDirectory, "s05_result.wl"}],
  "CorrectedS06" -> FileNameJoin[{stageDirectory, "s06_result.wl"}],
  "FactorizationCache" -> FileNameJoin[{stageDirectory,
    "s07_factorization_laurent_cache.wl"}],
  "PlusDiagnostic" -> FileNameJoin[{stageDirectory,
    "s07_bounded_plus_endpoint_diagnostic_result.wl"}]|>;
expectedHashes = <|
  "S07Consumer" ->
    "c2f73601702a7425eb78d46d6f818b59b7e3c9e66038e6c6d8598435f9a49864",
  "FailedDiagnostic" ->
    "e3238bb7567494162a1a470579cab6a694faa4225e3ef27270011be1f851b027",
  "CorrectedS05" ->
    "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb",
  "CorrectedS06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48",
  "PlusDiagnostic" ->
    "ebe5fcfb59a9320610d8efa07d24c636575f42fa335762e5a4a118dd128dc8bf"|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[resultPath],
  "ordinary diagnostic input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] ===
    expectedHashes[#] &, Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "ordinary diagnostic input identity failed", identityChecks];

Print["S07_ORDINARY_DIAGNOSTIC_STAGE=load exact cached fields"];
failedDiagnostic = Quiet@Check[Get[inputPaths["FailedDiagnostic"]],
  $Failed];
s05 = Quiet@Check[Get[inputPaths["CorrectedS05"]], $Failed];
s06 = Quiet@Check[Get[inputPaths["CorrectedS06"]], $Failed];
factorizationCache = Quiet@Check[
  Get[inputPaths["FactorizationCache"]], $Failed];
plusDiagnostic = Quiet@Check[Get[inputPaths["PlusDiagnostic"]],
  $Failed];
schemaChecks = <|
  "Associations" -> And @@ Map[AssociationQ,
    {failedDiagnostic, s05, s06, factorizationCache, plusDiagnostic}],
  "Scopes" -> And @@ Map[#1["ScopeTag"] === scopeTag &,
    {failedDiagnostic, s05, s06, factorizationCache, plusDiagnostic}],
  "FailedLocation" -> TrueQ[
    failedDiagnostic["Stage"] === "HqqV2S07PoleDiagnostic-v1" &&
    failedDiagnostic["Source", "SHA256"] ===
      expectedHashes["S07Consumer"] &&
    failedDiagnostic["Location"] === <|"Projector" -> "Pg",
      "Sector" -> "Ordinary", "EpsilonPower" -> -1|>],
  "CorrectedS05" -> TrueQ[s05["Stage"] === "HqqV2S05-v2" &&
    And @@ Values[s05["Checks"]] &&
    And @@ Values[s05["Correction", "Checks"]]],
  "CorrectedS06" -> TrueQ[s06["Stage"] === "HqqV2S06-v2" &&
    And @@ Values[s06["Checks"]]],
  "Factorization" -> TrueQ[
    factorizationCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    And @@ Values[factorizationCache["Checks"]]],
  "AcceptedPlusDiagnostic" -> TrueQ[
    plusDiagnostic["Stage"] ===
      "HqqV2S07BoundedPlusEndpointDiagnostic-v1" &&
    And @@ Values[plusDiagnostic["Checks"]]],
  "NoProducerCacheInput" -> Intersection[Keys[inputPaths],
    {"AngularMasterCache", "CoefficientCache", "EndpointCache",
      "RootGroupCache", "DirectEndpointCache",
      "PushforwardProducer"}] === {}|>;
require[And @@ Values[schemaChecks],
  "ordinary diagnostic schema gate failed", schemaChecks];

projectors = {"Pg", "PPP"};
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
  "ordinary diagnostic special-function expansion failed"];
combinationSpecialResiduals = Quiet@Check[
  MapThread[FullSimplify[#1 - #2] &,
    {combinationSpecialAtoms, combinationSpecialValues}], $Failed];
require[combinationSpecialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "ordinary diagnostic special-function identity failed"];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
mapInterior[expression_] := canonicalCombinationBasis[expression] /.
  u1Rule;
mapEndpointKinematics[expression_, label_String] := Module[
  {held, mapped},
  require[FreeQ[expression, s07HeldExplicitLogS23],
    label <> " contains the diagnostic hold symbol"];
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
boundedPlusCoefficient[expression_, label_String] := Module[
  {atoms, head, polynomial, coefficient, remainder},
  atoms = DeleteDuplicates@Cases[Unevaluated[expression],
    HoldPattern[HqqV2BoundedPlus[_, s23, _]], Infinity];
  If[atoms === {},
    require[exactZeroQ[expression],
      label <> " has no bounded-plus head but is nonzero"];
    Return[0]
  ];
  require[Length[atoms] === 1,
    label <> " has multiple bounded-plus heads", atoms];
  head = First[atoms];
  polynomial = expression /. head -> s07OrdinaryPlusDummy;
  require[PolynomialQ[polynomial, s07OrdinaryPlusDummy] &&
      Exponent[polynomial, s07OrdinaryPlusDummy] === 1,
    label <> " is not linear in its bounded-plus head"];
  coefficient = Quiet@Check[Cancel[Together[
    Coefficient[polynomial, s07OrdinaryPlusDummy, 1]]], $Failed];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - coefficient s07OrdinaryPlusDummy]], $Failed];
  require[coefficient =!= $Failed && remainder =!= $Failed &&
      SameQ[remainder, 0] && ! badSymbolicQ[coefficient],
    label <> " bounded-plus coefficient extraction failed"];
  coefficient
];

ordinaryMapRecord[ordinary_, plus_, endpointByAlpha_Association,
    label_String] := Module[
  {endpointTerms, rawSingularTerms, mappedRawSingular,
   mappedEndpointSingular, correctionTerms, current, candidate,
   fixedInterior, mappedFixedInterior, plusCoefficient, checks},
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
    mapEndpointKinematics[#1, label <> "/alpha=" <> ToString[#2]]/
      s23 &,
    {Values[endpointTerms], Keys[endpointTerms]}];
  correctionTerms = MapThread[Subtract,
    {mappedRawSingular, mappedEndpointSingular}];
  candidate = current + Total[correctionTerms];
  fixedInterior = ordinary + Total[rawSingularTerms];
  mappedFixedInterior = mapInterior[fixedInterior];
  plusCoefficient = boundedPlusCoefficient[plus,
    label <> "/stored-plus-single-pole"];
  checks = <|
    "StoredSplitReconstructs" -> exactZeroQ[
      ordinary - (fixedInterior - Total[rawSingularTerms])],
    "EndpointMatchesStoredPlus" -> exactZeroQ[
      plusCoefficient - Total[Values[endpointTerms]]],
    "MappedSplitReconstructs" -> exactZeroQ[
      candidate - (mappedFixedInterior -
        Total[mappedEndpointSingular])],
    "CorrectionExact" -> ! badSymbolicQ[correctionTerms] &&
      FreeQ[correctionTerms, epsilon | _SeriesData | _Real],
    "ExplicitEndpointLogsPreserved" ->
      FreeQ[candidate, s07HeldExplicitLogS23]|>;
  require[And @@ Values[checks],
    label <> " ordinary map record failed", checks];
  <|"Current" -> current, "Candidate" -> candidate,
    "Correction" -> Total[correctionTerms], "Checks" -> checks|>
];
currentVirtualOrdinary[expression_] :=
  canonicalCombinationBasis[expression] /.
    {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0;
currentFactorizationOrdinary[expression_] :=
  canonicalCombinationBasis[expression];

Print["S07_ORDINARY_DIAGNOSTIC_STAGE=reconstruct subtraction maps"];
mapRecords = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    ordinaryMapRecord[
      Lookup[realLedger[projector, family, "OrdinaryLaurent"],
        power, 0],
      Lookup[realLedger[projector, family, "BoundedPlusLaurent"],
        power, 0],
      realLedger[projector, family,
        "EndpointResidueByAlphaThroughEpsilon1"],
      projector <> "/" <> family]], realFamilies]], projectors];
currentRealContributions = AssociationMap[Function[projector,
  AssociationMap[mapRecords[projector, #, "Current"] &,
    realFamilies]], projectors];
candidateRealContributions = AssociationMap[Function[projector,
  AssociationMap[mapRecords[projector, #, "Candidate"] &,
    realFamilies]], projectors];
virtualContributions = AssociationMap[currentVirtualOrdinary[Lookup[
    virtualLedger[#, "OrdinaryLaurent"], power, 0]] &, projectors];
factorizationContributions = AssociationMap[
  currentFactorizationOrdinary[Lookup[
    factorizationLedger[#, "Ordinary"], power, 0]] &, projectors];
currentContributions = AssociationMap[Join[
  currentRealContributions[#], <|"Virtual" -> virtualContributions[#],
    "Factorization" -> factorizationContributions[#]|>] &, projectors];
candidateContributions = AssociationMap[Join[
  candidateRealContributions[#], <|"Virtual" -> virtualContributions[#],
    "Factorization" -> factorizationContributions[#]|>] &, projectors];

Print["S07_ORDINARY_DIAGNOSTIC_STAGE=reduce Pg and PPP residuals"];
currentResiduals = <|"Pg" -> balancedExactSum[
  Values[currentContributions["Pg"]], "Pg/current-ordinary-single"]|>;
candidateResiduals = AssociationMap[balancedExactSum[
  Values[candidateContributions[#]],
  # <> "/endpoint-subtracted-ordinary-single"] &, projectors];
diagnosticAgreementChecks = <|
  "ComponentOrder" -> Keys[failedDiagnostic["Components"]] ===
    Join[realFamilies, {"Virtual", "Factorization"}],
  "PgComponents" -> And @@ Map[exactZeroQ[
      currentContributions["Pg", #] -
        failedDiagnostic["Components", #]] &,
    Keys[failedDiagnostic["Components"]]],
  "PgResidual" -> exactZeroQ[currentResiduals["Pg"] -
    failedDiagnostic["CombinationMetadata", "ZeroResidual"]],
  "CurrentPgNonzero" -> ! exactZeroQ[currentResiduals["Pg"]]|>;
require[And @@ Values[diagnosticAgreementChecks],
  "fresh current ordinary map disagrees with failed diagnostic",
  diagnosticAgreementChecks];

mappingChecks = And @@ Flatten@Table[
  And @@ Values[mapRecords[projector, family, "Checks"]],
  {projector, projectors}, {family, realFamilies}];
checks = <|
  "InputIdentities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "EveryOrdinaryMapReconstructs" -> mappingChecks,
  "FailedDiagnosticAgreement" ->
    And @@ Values[diagnosticAgreementChecks],
  "EndpointSubtractedPgZero" -> SameQ[candidateResiduals["Pg"], 0],
  "EndpointSubtractedPPPZero" -> SameQ[candidateResiduals["PPP"], 0],
  "FactorizationUnchanged" -> SameQ[factorizationContributions,
    AssociationMap[currentFactorizationOrdinary[Lookup[
      factorizationLedger[#, "Ordinary"], power, 0]] &, projectors]],
  "VirtualUnchanged" -> SameQ[virtualContributions,
    AssociationMap[currentVirtualOrdinary[Lookup[
      virtualLedger[#, "OrdinaryLaurent"], power, 0]] &, projectors]],
  "AcceptedPlusDiagnostic" ->
    schemaChecks["AcceptedPlusDiagnostic"],
  "NoProducerCacheInput" -> schemaChecks["NoProducerCacheInput"],
  "ExactClosed" -> ! badSymbolicQ[
    {candidateRealContributions, candidateResiduals}] &&
    FreeQ[candidateRealContributions, epsilon | D | _SeriesData | _Real]|>;

diagnosticResult = <|
  "Stage" -> "HqqV2S07OrdinaryEndpointSubtractionDiagnostic-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> expectedHashes,
  "Location" -> <|"Sector" -> "Ordinary",
    "EpsilonPower" -> power|>,
  "CurrentResidualMetadata" -> AssociationMap[<|
    "Zero" -> exactZeroQ[currentResiduals[#]],
    "LeafCount" -> LeafCount[currentResiduals[#]],
    "SHA256" -> expressionHash[currentResiduals[#]]|> &,
    Keys[currentResiduals]],
  "EndpointSubtractedResidualMetadata" -> AssociationMap[<|
    "Zero" -> exactZeroQ[candidateResiduals[#]],
    "LeafCount" -> LeafCount[candidateResiduals[#]],
    "SHA256" -> expressionHash[candidateResiduals[#]]|> &, projectors],
  "CorrectionSHA256" -> AssociationMap[Function[projector,
    AssociationMap[expressionHash[
      mapRecords[projector, #, "Correction"]] &,
      realFamilies]], projectors],
  "Checks" -> checks|>;
require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing ordinary diagnostic"];
atomicPut[diagnosticResult, resultPath];
Print["S07_ORDINARY_DIAGNOSTIC_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, diagnosticResult],
  "same-kernel ordinary diagnostic reload failed"];
Print["S07_ORDINARY_DIAGNOSTIC_CURRENT=",
  InputForm[diagnosticResult["CurrentResidualMetadata"]]];
Print["S07_ORDINARY_DIAGNOSTIC_ENDPOINT_SUBTRACTED=",
  InputForm[diagnosticResult[
    "EndpointSubtractedResidualMetadata"]]];
Print["S07_ORDINARY_DIAGNOSTIC_CHECKS=", InputForm[checks]];
If[And @@ Values[checks],
  Print["S07_ORDINARY_DIAGNOSTIC_SUCCESS"];
  Quit[0],
  fail["ordinary endpoint-subtraction candidate failed", checks]
];

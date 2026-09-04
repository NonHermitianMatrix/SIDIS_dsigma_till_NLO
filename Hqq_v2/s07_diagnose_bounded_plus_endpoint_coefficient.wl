(* Hqq_v2 S07: diagnose the bounded-plus endpoint-coefficient map. *)

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
  expressionHash, balancedExactSum, associationExpression,
  decomposeBoundedPlus, canonicalCombinationBasis,
  currentRealPlus, endpointMappedRealPlus, currentVirtualPlus,
  currentFactorizationPlus];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_PLUS_DIAGNOSTIC_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_PLUS_DIAGNOSTIC_FAILURE_DETAIL=", InputForm[detail]]];
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
  Check[Put[expression, temporary], fail["diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published diagnostic is missing"];
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
associationExpression[data_Association] :=
  Total[KeyValueMap[epsilon^#1 #2 &, data]];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{stageDirectory,
  "s07_bounded_plus_endpoint_diagnostic_result.wl"}];
inputPaths = <|
  "S07Consumer" -> FileNameJoin[{stageDirectory,
    "s07_combine_hqq_from_cache.wl"}],
  "FailedDiagnostic" -> FileNameJoin[{stageDirectory,
    "s07_combination_diagnostic_result.wl"}],
  "CorrectedS05" -> FileNameJoin[{stageDirectory, "s05_result.wl"}],
  "CorrectedS06" -> FileNameJoin[{stageDirectory, "s06_result.wl"}],
  "FactorizationCache" -> FileNameJoin[{stageDirectory,
    "s07_factorization_laurent_cache.wl"}]|>;
expectedHashes = <|
  "S07Consumer" ->
    "eb9bbaea4485d19dd3d85e4cf09bdfd231ae409a6022b0bebccde78139d2a20d",
  "FailedDiagnostic" ->
    "8aac6488a1f34c4a320e1eb7c8d7ebc3d59994caeed60c43181b21431280db5f",
  "CorrectedS05" ->
    "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb",
  "CorrectedS06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48"|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[resultPath],
  "diagnostic input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] ===
    expectedHashes[#] &, Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "diagnostic input identity failed", identityChecks];

Print["S07_PLUS_DIAGNOSTIC_STAGE=load exact cached fields"];
failedDiagnostic = Quiet@Check[Get[inputPaths["FailedDiagnostic"]],
  $Failed];
s05 = Quiet@Check[Get[inputPaths["CorrectedS05"]], $Failed];
s06 = Quiet@Check[Get[inputPaths["CorrectedS06"]], $Failed];
factorizationCache = Quiet@Check[
  Get[inputPaths["FactorizationCache"]], $Failed];
schemaChecks = <|
  "Associations" -> And @@ Map[AssociationQ,
    {failedDiagnostic, s05, s06, factorizationCache}],
  "Scopes" -> And @@ Map[#["ScopeTag"] === scopeTag &,
    {failedDiagnostic, s05, s06, factorizationCache}],
  "FailedLocation" -> TrueQ[
    failedDiagnostic["Stage"] === "HqqV2S07PoleDiagnostic-v1" &&
    failedDiagnostic["Source", "SHA256"] ===
      expectedHashes["S07Consumer"] &&
    failedDiagnostic["Location"] === <|"Projector" -> "Pg",
      "Sector" -> "BoundedPlus", "EpsilonPower" -> -1|>],
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
      "RootGroupCache", "DirectEndpointCache", "PushforwardProducer"}] === {}|>;
require[And @@ Values[schemaChecks],
  "diagnostic schema gate failed", schemaChecks];

projectors = {"Pg", "PPP"};
realFamilies = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"};
realLedger = s05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
factorizationLedger =
  factorizationCache["Factorization", "LaurentLedger"];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
s23Upper = s05["Conventions", "EndpointInterval"][[2]];
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {realLedger, virtualLedger, factorizationLedger}, _PolyGamma, Infinity];
combinationSpecialValues = Quiet@Check[
  FunctionExpand /@ combinationSpecialAtoms, $Failed];
require[combinationSpecialValues =!= $Failed &&
    FreeQ[combinationSpecialValues, _PolyGamma] &&
    ! badSymbolicQ[combinationSpecialValues],
  "special-function basis expansion failed"];
combinationSpecialResiduals = Quiet@Check[
  MapThread[FullSimplify[#1 - #2] &,
    {combinationSpecialAtoms, combinationSpecialValues}], $Failed];
require[combinationSpecialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "special-function identity gate failed", combinationSpecialResiduals];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;

decomposeBoundedPlus[expression_, label_String] := Module[
  {atoms, head, polynomial, degree, coefficient, remainder},
  atoms = DeleteDuplicates@Cases[Unevaluated[expression],
    HoldPattern[HqqV2BoundedPlus[_, s23, _]], Infinity];
  If[atoms === {},
    require[exactZeroQ[expression],
      label <> " has no bounded-plus head but is nonzero"];
    Return[<|"Zero" -> True, "Head" -> Missing["Zero"],
      "Coefficient" -> 0, "Remainder" -> 0,
      "Checks" -> <|"UniqueHead" -> True,
        "Linear" -> True, "Reconstructs" -> True|>|>]
  ];
  require[Length[atoms] === 1,
    label <> " has more than one bounded-plus head", atoms];
  head = First[atoms];
  polynomial = expression /. head -> hqqPlusDiagnosticDummy;
  degree = Exponent[polynomial, hqqPlusDiagnosticDummy];
  require[PolynomialQ[polynomial, hqqPlusDiagnosticDummy] && degree === 1,
    label <> " is not linear in its bounded-plus head", degree];
  coefficient = Quiet@Check[Cancel[Together[
    Coefficient[polynomial, hqqPlusDiagnosticDummy, 1]]], $Failed];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - coefficient hqqPlusDiagnosticDummy]], $Failed];
  require[coefficient =!= $Failed && remainder =!= $Failed &&
      ! badSymbolicQ[{coefficient, remainder}],
    label <> " coefficient extraction failed"];
  <|"Zero" -> False, "Head" -> head,
    "Coefficient" -> coefficient, "Remainder" -> remainder,
    "Checks" -> <|"UniqueHead" -> True,
      "Linear" -> True, "Reconstructs" -> SameQ[remainder, 0],
      "UpperBoundIndependent" -> FreeQ[head[[3]], s23]|>|>
];

currentRealPlus[expression_] :=
  canonicalCombinationBasis[expression] /. u1Rule;
currentVirtualPlus[expression_] := canonicalCombinationBasis[expression] /.
  {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0;
currentFactorizationPlus[expression_] :=
  canonicalCombinationBasis[expression];
endpointMappedRealPlus[expression_, label_String] := Module[
  {record, mappedHead, mappedCoefficient},
  record = decomposeBoundedPlus[expression, label];
  If[TrueQ[record["Zero"]], Return[0]];
  mappedHead = record["Head"] /. u1Rule;
  mappedCoefficient = Quiet@Check[Cancel[Together[
    canonicalCombinationBasis[record["Coefficient"]] /.
      u1Rule /. s23 -> 0]], $Failed];
  require[mappedCoefficient =!= $Failed &&
      ! badSymbolicQ[mappedCoefficient] &&
      FreeQ[mappedCoefficient, s23 | u1],
    label <> " endpoint coefficient map failed", mappedCoefficient];
  mappedCoefficient mappedHead
];

Print["S07_PLUS_DIAGNOSTIC_STAGE=reconstruct S05 endpoint plus pole"];
ggEndpointData = AssociationMap[
  realLedger[#, "Hqq;gg",
    "EndpointResidueByAlphaThroughEpsilon1"] &, projectors];
ggReconstructedPlusSingle = AssociationMap[Function[projector,
  Coefficient[Total@Table[Normal@Series[
    associationExpression[ggEndpointData[projector, alpha]] *
      (HqqV2BoundedPlus[0, s23, s23Upper] -
        alpha epsilon HqqV2BoundedPlus[1, s23, s23Upper]),
    {epsilon, 0, 0}], {alpha, Keys[ggEndpointData[projector]]}],
    epsilon, -1]], projectors];
ggStoredPlusSingle = AssociationMap[
  Lookup[realLedger[#, "Hqq;gg", "BoundedPlusLaurent"], -1, 0] &,
  projectors];
endpointReconstructionChecks = AssociationMap[exactZeroQ[
  ggReconstructedPlusSingle[#] - ggStoredPlusSingle[#]] &, projectors];
require[And @@ Values[endpointReconstructionChecks],
  "fresh Hqq;gg endpoint-plus reconstruction failed",
  endpointReconstructionChecks];

Print["S07_PLUS_DIAGNOSTIC_STAGE=compare current and endpoint maps"];
rawRealPlus = AssociationMap[Function[projector,
  AssociationMap[Lookup[
    realLedger[projector, #, "BoundedPlusLaurent"], -1, 0] &,
    realFamilies]], projectors];
currentRealContributions = AssociationMap[Function[projector,
  AssociationMap[currentRealPlus[
    rawRealPlus[projector, #]] &, realFamilies]], projectors];
candidateRealContributions = AssociationMap[Function[projector,
  AssociationMap[endpointMappedRealPlus[
    rawRealPlus[projector, #],
    projector <> "/" <> #] &, realFamilies]], projectors];
virtualContributions = AssociationMap[currentVirtualPlus[Lookup[
    virtualLedger[#, "BoundedPlusLaurent"], -1, 0]] &, projectors];
factorizationContributions = AssociationMap[
  currentFactorizationPlus[Lookup[
    factorizationLedger[#, "BoundedPlus"], -1, 0]] &, projectors];
currentContributions = AssociationMap[Join[
  currentRealContributions[#], <|"Virtual" -> virtualContributions[#],
    "Factorization" -> factorizationContributions[#]|>] &, projectors];
candidateContributions = AssociationMap[Join[
  candidateRealContributions[#], <|"Virtual" -> virtualContributions[#],
    "Factorization" -> factorizationContributions[#]|>] &, projectors];
currentResiduals = AssociationMap[balancedExactSum[
  Values[currentContributions[#]], # <> "/current-plus-single"] &,
  projectors];
candidateResiduals = AssociationMap[balancedExactSum[
  Values[candidateContributions[#]], # <> "/endpoint-plus-single"] &,
  projectors];

diagnosticAgreementChecks = <|
  "ComponentOrder" ->
    Keys[failedDiagnostic["Components"]] ===
      Join[realFamilies, {"Virtual", "Factorization"}],
  "PgComponents" -> And @@ Map[exactZeroQ[
      currentContributions["Pg", #] -
        failedDiagnostic["Components", #]] &,
    Keys[failedDiagnostic["Components"]]],
  "PgResidual" -> exactZeroQ[currentResiduals["Pg"] -
    failedDiagnostic["CombinationMetadata", "ZeroResidual"]],
  "CurrentPgNonzero" -> ! exactZeroQ[currentResiduals["Pg"]]|>;
require[And @@ Values[diagnosticAgreementChecks],
  "fresh current map disagrees with failed diagnostic",
  diagnosticAgreementChecks];

rawDecompositions = AssociationMap[Function[projector,
  AssociationMap[decomposeBoundedPlus[rawRealPlus[projector, #],
    projector <> "/raw/" <> #] &, realFamilies]], projectors];
candidateDecompositions = AssociationMap[Function[projector,
  AssociationMap[decomposeBoundedPlus[
    candidateRealContributions[projector, #],
    projector <> "/candidate/" <> #] &, realFamilies]], projectors];
factorizationDecompositions = AssociationMap[decomposeBoundedPlus[
    factorizationContributions[#], # <> "/factorization"] &,
  projectors];
nonzeroHeads = AssociationMap[DeleteDuplicates@DeleteCases[
    Join[Map[Lookup[#, "Head"] &,
        Values[candidateDecompositions[#]]],
      {factorizationDecompositions[#]["Head"]}], _Missing] &,
  projectors];
headAndCoefficientChecks = <|
  "RawDecompositions" -> And @@ Flatten@Table[
    And @@ Values[rawDecompositions[projector, family, "Checks"]],
    {projector, projectors}, {family, realFamilies}],
  "CandidateDecompositions" -> And @@ Flatten@Table[
    And @@ Values[candidateDecompositions[
      projector, family, "Checks"]],
    {projector, projectors}, {family, realFamilies}],
  "FactorizationDecompositions" -> And @@ Table[
    And @@ Values[factorizationDecompositions[projector, "Checks"]],
    {projector, projectors}],
  "OneCommonHead" -> And @@ Map[Length[nonzeroHeads[#]] === 1 &,
    projectors],
  "CandidateCoefficientsAtEndpoint" -> And @@ Flatten@Table[
    FreeQ[candidateDecompositions[projector, family, "Coefficient"],
      s23 | u1], {projector, projectors}, {family, realFamilies}],
  "BothProjectorsCancel" -> And @@ Map[
    SameQ[candidateResiduals[#], 0] &, projectors]|>;

checks = <|
  "InputIdentities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "S05EndpointReconstruction" ->
    And @@ Values[endpointReconstructionChecks],
  "FailedDiagnosticAgreement" ->
    And @@ Values[diagnosticAgreementChecks],
  "HeadAndCoefficientDecomposition" ->
    And @@ Values[headAndCoefficientChecks],
  "EndpointMappedPgZero" -> SameQ[candidateResiduals["Pg"], 0],
  "EndpointMappedPPPZero" -> SameQ[candidateResiduals["PPP"], 0],
  "FactorizationUnchanged" -> SameQ[
    factorizationContributions,
    AssociationMap[currentFactorizationPlus[Lookup[
      factorizationLedger[#, "BoundedPlus"], -1, 0]] &, projectors]],
  "VirtualUnchanged" -> SameQ[virtualContributions,
    AssociationMap[currentVirtualPlus[Lookup[
      virtualLedger[#, "BoundedPlusLaurent"], -1, 0]] &, projectors]],
  "NoProducerCacheInput" -> schemaChecks["NoProducerCacheInput"],
  "ExactClosed" -> ! badSymbolicQ[
    {candidateRealContributions, candidateResiduals}] &&
    FreeQ[candidateRealContributions, epsilon | D | _SeriesData | _Real]|>;

diagnosticResult = <|
  "Stage" -> "HqqV2S07BoundedPlusEndpointDiagnostic-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> expectedHashes,
  "Location" -> <|"Sector" -> "BoundedPlus",
    "EpsilonPower" -> -1|>,
  "CommonHeads" -> nonzeroHeads,
  "CurrentResidualMetadata" -> AssociationMap[<|
    "Zero" -> exactZeroQ[currentResiduals[#]],
    "LeafCount" -> LeafCount[currentResiduals[#]],
    "SHA256" -> expressionHash[currentResiduals[#]]|> &, projectors],
  "EndpointMappedResidualMetadata" -> AssociationMap[<|
    "Zero" -> exactZeroQ[candidateResiduals[#]],
    "LeafCount" -> LeafCount[candidateResiduals[#]],
    "SHA256" -> expressionHash[candidateResiduals[#]]|> &, projectors],
  "MappedRealCoefficientSHA256" -> AssociationMap[Function[projector,
    AssociationMap[expressionHash[
      candidateDecompositions[projector, #, "Coefficient"]] &,
      realFamilies]], projectors],
  "Checks" -> checks|>;
require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing plus diagnostic"];
atomicPut[diagnosticResult, resultPath];
Print["S07_PLUS_DIAGNOSTIC_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, diagnosticResult],
  "same-kernel plus diagnostic reload failed"];
Print["S07_PLUS_DIAGNOSTIC_CURRENT=",
  InputForm[diagnosticResult["CurrentResidualMetadata"]]];
Print["S07_PLUS_DIAGNOSTIC_ENDPOINT_MAPPED=",
  InputForm[diagnosticResult["EndpointMappedResidualMetadata"]]];
Print["S07_PLUS_DIAGNOSTIC_CHECKS=", InputForm[checks]];
If[And @@ Values[checks],
  Print["S07_PLUS_DIAGNOSTIC_SUCCESS"];
  Quit[0],
  fail["endpoint-coefficient candidate did not pass all gates", checks]
];

(* Hqq_v2 S05: independent validation of the localized endpoint correction. *)

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

ClearAll[fail, require, atomicPut, exactZeroQ, expressionHash,
  badSymbolicQ, balancedExactSum, principalRootAtoms,
  associationExpression, carrierCoefficient, endpointDeltaData,
  endpointPlusData, rawDeltaComponents, productionDeltaComponents,
  endpointWithoutTarget, globalSymbolInventory,
  canonicalLogArgumentsOnce, canonicalLogArguments];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S05_ENDPOINT_VALIDATION_FAILURE: ", message];
  If[detail =!= Null,
    Print["S05_ENDPOINT_VALIDATION_FAILURE_DETAIL=",
      InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], fail["validation publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "validation temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published validation result is missing"];
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
principalRootAtoms[expression_] := DeleteDuplicates@Cases[
  expression, HoldPattern[Power[Power[_, 2], Rational[1, 2]]], Infinity];
associationExpression[data_Association] :=
  Total[KeyValueMap[epsilon^#1 #2 &, data]];
carrierCoefficient[data_Association, alpha_Integer, power_Integer] :=
  Total@Table[If[sourcePower <= power,
      Lookup[data, sourcePower, 0] *
        (-alpha Log[s23])^(power - sourcePower)/
          Factorial[power - sourcePower], 0],
    {sourcePower, Keys[data]}];
globalSymbolInventory[expression_] := SortBy[DeleteDuplicates@Cases[
  Unevaluated[expression], symbol_Symbol /;
    Context[Unevaluated[symbol]] === "Global`", Infinity], ToString];
canonicalLogArgumentsOnce[expression_] := expression /.
  HoldPattern[Log[argument_]] :> Log[Factor[Cancel[Together[argument]]]];
canonicalLogArguments[expression_] := Module[{answer},
  answer = FixedPoint[canonicalLogArgumentsOnce, expression, 8];
  require[SameQ[answer, canonicalLogArgumentsOnce[answer]],
    "log-argument canonicalization did not reach a fixed point"];
  answer
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
validationResultPath = FileNameJoin[{stageDirectory,
  "s05_endpoint_correction_validation_result.wl"}];
inputPaths = <|
  "Producer" -> FileNameJoin[{stageDirectory,
    "s05_correct_hqq_same_flavor_endpoint_residue.wl"}],
  "CorrectedS05" -> FileNameJoin[{stageDirectory, "s05_result.wl"}],
  "OriginalS05" -> FileNameJoin[{stageDirectory,
    "s05_result_pre_endpoint_correction_e470276a.wl"}],
  "S04" -> FileNameJoin[{stageDirectory, "s04_result.wl"}],
  "S06" -> FileNameJoin[{stageDirectory, "s06_result.wl"}],
  "FactorizationCache" -> FileNameJoin[{stageDirectory,
    "s07_factorization_laurent_cache.wl"}],
  "OriginResult" -> FileNameJoin[{stageDirectory,
    "s07_same_flavor_pole_origin_result.wl"}]|>;
expectedHashes = <|
  "Producer" ->
    "f59ed00061be52090bddac52b3aa9a08dcdbcf1e7895ce618a49cde831f8be2c",
  "CorrectedS05" ->
    "bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb",
  "OriginalS05" ->
    "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f",
  "S04" ->
    "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c",
  "S06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48",
  "OriginResult" ->
    "aee72e0980a7a4635fb4c47429748dea2c9c7b8ad05297a259a7a75f8caf347d"|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[validationResultPath],
  "validation input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] ===
    expectedHashes[#] &, Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "validation artifact identity failed", identityChecks];

Print["S05_ENDPOINT_VALIDATION_STAGE=load compact exact artifacts"];
correctedS05 = Quiet@Check[Get[inputPaths["CorrectedS05"]], $Failed];
oldS05 = Quiet@Check[Get[inputPaths["OriginalS05"]], $Failed];
s04 = Quiet@Check[Get[inputPaths["S04"]], $Failed];
s06 = Quiet@Check[Get[inputPaths["S06"]], $Failed];
factorizationCache = Quiet@Check[
  Get[inputPaths["FactorizationCache"]], $Failed];
originResult = Quiet@Check[Get[inputPaths["OriginResult"]], $Failed];
loadedArtifacts = {correctedS05, oldS05, s04, s06,
  factorizationCache, originResult};
schemaChecks = <|
  "Associations" -> And @@ Map[AssociationQ, loadedArtifacts],
  "Scopes" -> And @@ Map[#["ScopeTag"] === scopeTag &, loadedArtifacts],
  "CorrectedS05" -> TrueQ[
    correctedS05["Stage"] === "HqqV2S05-v2" &&
    correctedS05["Source", "SHA256"] === expectedHashes["Producer"] &&
    correctedS05["Correction", "Schema"] ===
      "HqqV2S05SameFlavorEndpointCorrection-v2" &&
    And @@ Values[correctedS05["Checks"]] &&
    And @@ Values[correctedS05["Correction", "Checks"]]],
  "OriginalS05" -> TrueQ[oldS05["Stage"] === "HqqV2S05-v1" &&
    And @@ Values[oldS05["Checks"]]],
  "S04" -> TrueQ[s04["Stage"] === "HqqV2S04-v1" &&
    And @@ Values[s04["Checks"]]],
  "S06" -> TrueQ[s06["Stage"] === "HqqV2S06-v2" &&
    And @@ Values[s06["Checks"]]],
  "FactorizationCache" -> TrueQ[
    factorizationCache["Stage"] === "HqqV2S07FactorizationCache-v1" &&
    And @@ Values[factorizationCache["Checks"]]],
  "OriginResult" -> TrueQ[
    originResult["Stage"] === "HqqV2S07SameFlavorPoleOrigin-v1" &&
    And @@ Values[originResult["Checks"]]],
  "NoS05ProductionCacheInput" -> Intersection[Keys[inputPaths],
    {"AngularMasterCache", "CoefficientCache", "EndpointCache",
      "RootGroupCache", "DirectEndpointCache"}] === {}|>;
require[And @@ Values[schemaChecks],
  "validation schema gate failed", schemaChecks];

projectors = {"Pg", "PPP"};
families = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"};
sameFamily = "Hqq;q_qbar_sameFlavor";
componentNames = Join[families, {"Virtual", "Factorization"}];
oldRealLedger = oldS05["RealLaurentLedger"];
correctedRealLedger = correctedS05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
factorizationLedger =
  factorizationCache["Factorization", "LaurentLedger"];
endpointData = AssociationMap[
  oldRealLedger[#, sameFamily,
    "EndpointResidueByAlphaThroughEpsilon1"] &, projectors];
alphas = Keys[endpointData[First[projectors]]];
sourcePowers = Keys[endpointData[First[projectors], First[alphas]]];
sourcePairs = Tuples[{alphas, sourcePowers}];
bornFailingPairs = Select[sourcePairs, ! TrueQ[
    originResult["EndpointSourceBornTensorChecks", #[[1]], #[[2]]]] &];
oddNonzeroPairs = Select[sourcePairs,
  ! TrueQ[originResult["EndpointSourceOddMetadata", "Pg",
       #[[1]], #[[2]], "Zero"]] ||
    ! TrueQ[originResult["EndpointSourceOddMetadata", "PPP",
       #[[1]], #[[2]], "Zero"]] &];
phaseAlpha = oldS05["Conventions", "PhaseDistributionAlpha"];
targetChecks = <|
  "Projectors" -> (Keys[oldRealLedger] === projectors &&
    Keys[correctedRealLedger] === projectors &&
    Keys[virtualLedger] === projectors &&
    Keys[factorizationLedger] === projectors),
  "Families" -> And @@ Map[Keys[oldRealLedger[#]] === families &, projectors],
  "UniqueOrigin" -> (Length[bornFailingPairs] === 1 &&
    SameQ[bornFailingPairs, oddNonzeroPairs]),
  "PhaseAlpha" -> (Length[bornFailingPairs] === 1 &&
    First[First[bornFailingPairs]] === phaseAlpha),
  "StoredTarget" -> (Length[bornFailingPairs] === 1 &&
    correctedS05["Correction", "Target"] === <|
      "Family" -> sameFamily,
      "DistributionAlpha" -> First[First[bornFailingPairs]],
      "EndpointResidueEpsilonPower" -> Last[First[bornFailingPairs]]|>)|>;
require[And @@ Values[targetChecks],
  "fresh target localization failed", targetChecks];
targetPair = First[bornFailingPairs];
targetAlpha = First[targetPair];
targetPower = Last[targetPair];

Print["S05_ENDPOINT_VALIDATION_STAGE=rederive production basis"];
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {oldRealLedger, virtualLedger, factorizationLedger}, _PolyGamma,
  Infinity];
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
  "special-function identity gate failed", combinationSpecialResiduals];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
u1Rule = factorizationCache["Factorization", "ConservationRule"];
canonicalRealDelta[expression_] := canonicalLogArguments[
  canonicalCombinationBasis[expression] /. u1Rule /. s23 -> 0];
canonicalVirtualDelta[expression_] := canonicalLogArguments[
  canonicalCombinationBasis[expression] /.
    {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0];
canonicalFactorizationDelta[expression_] := canonicalLogArguments[
  canonicalCombinationBasis[expression] /. s23 -> 0];
deltaU1Rule = u1Rule /. s23 -> 0;
consumerQ2Solutions = Solve[Equal @@ First[deltaU1Rule], Q2];
s04Q2Solutions = Solve[s04["Conservation", "BaseEquations", "S23"], Q2];
require[MatchQ[deltaU1Rule, {Rule[u1, _]}] &&
    Length[consumerQ2Solutions] === 1 &&
    MatchQ[First[consumerQ2Solutions], {Rule[Q2, _]}] &&
    Length[s04Q2Solutions] === 1 &&
    MatchQ[First[s04Q2Solutions], {Rule[Q2, _]}],
  "production inverse-map schema failed"];
endpointQ2Rule = First[s04Q2Solutions] /. s23 -> 0;
consumerInverseQ2Rule = First[consumerQ2Solutions];
productionMapChecks = <|
  "InverseAgreement" -> exactZeroQ[
    (Q2 /. endpointQ2Rule) - (Q2 /. consumerInverseQ2Rule)],
  "S04Closure" -> exactZeroQ[
    (Subtract @@ s04["Conservation", "BaseEquations", "S23"]) /.
      s23 -> 0 /. endpointQ2Rule],
  "ConsumerClosure" -> exactZeroQ[
    (Subtract @@ (Equal @@ First[deltaU1Rule])) /. endpointQ2Rule]|>;
require[And @@ Values[productionMapChecks],
  "fresh production-map checks failed", productionMapChecks];

Print["S05_ENDPOINT_VALIDATION_STAGE=rederive distribution coefficient"];
s23Upper = oldS05["Conventions", "EndpointInterval"][[2]];
freshDistributionCoefficient = Quiet@Check[Cancel[Together[
  Coefficient[Normal@Series[
    -s23Upper^(-targetAlpha epsilon)/(targetAlpha epsilon) *
      epsilon^targetPower hqqValidationEndpointDummy,
    {epsilon, 0, 0}], epsilon, -1]/hqqValidationEndpointDummy]], $Failed];
distributionCoefficientChecks = <|
  "Derived" -> (freshDistributionCoefficient =!= $Failed &&
    ! badSymbolicQ[freshDistributionCoefficient]),
  "Nonzero" -> ! exactZeroQ[freshDistributionCoefficient],
  "Closed" -> FreeQ[freshDistributionCoefficient,
    epsilon | s23 | hqqValidationEndpointDummy | _SeriesData],
  "StoredAgreement" -> exactZeroQ[
    freshDistributionCoefficient -
      correctedS05["Correction", "DistributionSinglePoleCoefficient"]]|>;
require[And @@ Values[distributionCoefficientChecks],
  "fresh distribution coefficient failed", distributionCoefficientChecks];

rawDeltaComponents[ledger_Association, projector_String,
    power_Integer] := <|
  "Hqq;gg" -> Lookup[
    ledger[projector, "Hqq;gg", "DeltaLaurent"], power, 0],
  sameFamily -> Lookup[
    ledger[projector, sameFamily, "DeltaLaurent"], power, 0],
  "Hqq;qPrime_qbarPrime" -> Lookup[
    ledger[projector, "Hqq;qPrime_qbarPrime", "DeltaLaurent"], power, 0],
  "Virtual" -> Lookup[
    virtualLedger[projector, "DeltaLaurent"], power, 0],
  "Factorization" -> Lookup[
    factorizationLedger[projector, "Delta"], power, 0]|>;
productionDeltaComponents[ledger_Association, projector_String,
    power_Integer] := <|
  "Hqq;gg" -> canonicalRealDelta[
    rawDeltaComponents[ledger, projector, power]["Hqq;gg"]],
  sameFamily -> canonicalRealDelta[
    rawDeltaComponents[ledger, projector, power][sameFamily]],
  "Hqq;qPrime_qbarPrime" -> canonicalRealDelta[
    rawDeltaComponents[ledger, projector, power][
      "Hqq;qPrime_qbarPrime"]],
  "Virtual" -> canonicalVirtualDelta[
    rawDeltaComponents[ledger, projector, power]["Virtual"]],
  "Factorization" -> canonicalFactorizationDelta[
    rawDeltaComponents[ledger, projector, power]["Factorization"]]|>;

Print["S05_ENDPOINT_VALIDATION_STAGE=independently solve pole equations"];
polePowers = {-2, -1};
oldProductionComponents = AssociationMap[Function[projector,
  AssociationMap[productionDeltaComponents[
    oldRealLedger, projector, #] &, polePowers]], projectors];
oldProductionResiduals = AssociationMap[Function[projector,
  AssociationMap[balancedExactSum[
    Values[oldProductionComponents[projector, #]],
    projector <> "/validation-old-pole/epsilon " <> ToString[#]] &,
    polePowers]], projectors];
oldTargetResidue = AssociationMap[
  endpointData[#, targetAlpha, targetPower] &, projectors];
oldProductionTargetSource = AssociationMap[Cancel[Together[
  canonicalRealDelta[
    freshDistributionCoefficient oldTargetResidue[#]]]] &, projectors];
productionOtherSinglePole = AssociationMap[Function[projector,
  balancedExactSum[Join[
    Values@KeyDrop[oldProductionComponents[projector, -1], sameFamily],
    {balancedExactSum[
      {oldProductionComponents[projector, -1, sameFamily],
        -oldProductionTargetSource[projector]},
      projector <> "/validation-same-flavor-nontarget"]}],
    projector <> "/validation-all-nontarget"]], projectors];
freshSolvedMappedResidue = AssociationMap[Function[projector,
  Module[{solutions},
    solutions = Quiet@Check[Solve[
      freshDistributionCoefficient hqqValidationReplacementResidue ==
        -productionOtherSinglePole[projector],
      hqqValidationReplacementResidue], $Failed];
    require[ListQ[solutions] && Length[solutions] === 1 &&
        MatchQ[First[solutions],
          {Rule[hqqValidationReplacementResidue, _]}],
      projector <> " fresh replacement solve failed", solutions];
    Cancel[Together[
      hqqValidationReplacementResidue /. First[solutions]]]
  ]], projectors];
freshSolvedInvariantResidue = AssociationMap[Cancel[Together[
  freshSolvedMappedResidue[#] /. endpointQ2Rule]] &, projectors];
freshForwardMappedResidue = AssociationMap[Cancel[Together[
  canonicalRealDelta[freshSolvedInvariantResidue[#]]]] &, projectors];
allowedRealSymbols = globalSymbolInventory[oldRealLedger];
unexpectedReplacementSymbols = Map[
  Complement[globalSymbolInventory[#], allowedRealSymbols] &,
  freshSolvedInvariantResidue];
replacementChecks = <|
  "Closed" -> ! badSymbolicQ[
    {freshSolvedMappedResidue, freshSolvedInvariantResidue}],
  "ForwardClosure" -> And @@ Map[exactZeroQ[
      freshForwardMappedResidue[#] - freshSolvedMappedResidue[#]] &,
    projectors],
  "PrincipalRootFree" ->
    (principalRootAtoms[freshSolvedInvariantResidue] === {} &&
      FreeQ[freshSolvedInvariantResidue,
        oldS05["EndpointBranches", "B19RootJet", "EndpointRoot"]]),
  "SymbolClosure" -> And @@ (SameQ[#, {}] & /@
    Values[unexpectedReplacementSymbols]),
  "SolvedCancellation" -> And @@ Map[exactZeroQ[
      productionOtherSinglePole[#] +
        freshDistributionCoefficient freshSolvedMappedResidue[#]] &,
    projectors]|>;
require[And @@ Values[replacementChecks],
  "fresh replacement residue failed", replacementChecks];

freshResidueCorrection = AssociationMap[balancedExactSum[
  {freshSolvedInvariantResidue[#], -oldTargetResidue[#]},
  # <> "/validation-residue-difference"] &, projectors];
correctionEndpointData = AssociationMap[Function[projector,
  AssociationMap[If[# === targetPower,
      freshResidueCorrection[projector], 0] &, sourcePowers]],
  projectors];
deltaPowers = Keys[oldRealLedger[First[projectors], sameFamily,
  "DeltaLaurent"]];
plusPowers = Keys[oldRealLedger[First[projectors], sameFamily,
  "BoundedPlusLaurent"]];
ordinaryPowers = Keys[oldRealLedger[First[projectors], sameFamily,
  "OrdinaryLaurent"]];
endpointDeltaData[dataByAlpha_Association] := Module[{expression},
  expression = Total@Table[Normal@Series[
    -s23Upper^(-alpha epsilon)/(alpha epsilon) *
      associationExpression[dataByAlpha[alpha]], {epsilon, 0, 0}],
    {alpha, Keys[dataByAlpha]}];
  AssociationMap[Coefficient[expression, epsilon, #] &, deltaPowers]
];
endpointPlusData[dataByAlpha_Association] := Module[{expression},
  expression = Total@Table[Normal@Series[
    associationExpression[dataByAlpha[alpha]] *
      (HqqV2BoundedPlus[0, s23, s23Upper] -
        alpha epsilon HqqV2BoundedPlus[1, s23, s23Upper]),
    {epsilon, 0, 0}], {alpha, Keys[dataByAlpha]}];
  AssociationMap[Coefficient[expression, epsilon, #] &, plusPowers]
];

Print["S05_ENDPOINT_VALIDATION_STAGE=rederive distribution propagation"];
freshDeltaCorrections = AssociationMap[endpointDeltaData[
  <|targetAlpha -> correctionEndpointData[#]|>] &, projectors];
freshPlusCorrections = AssociationMap[endpointPlusData[
  <|targetAlpha -> correctionEndpointData[#]|>] &, projectors];
freshOrdinaryCorrections = AssociationMap[Function[projector,
  AssociationMap[-carrierCoefficient[
      correctionEndpointData[projector], targetAlpha, #]/s23 &,
    ordinaryPowers]], projectors];
linearityLeftSource = AssociationMap[
  hqqValidationLinearityLeft[#] &, sourcePowers];
linearityRightSource = AssociationMap[
  hqqValidationLinearityRight[#] &, sourcePowers];
linearityCombinedSource = AssociationMap[
  linearityLeftSource[#] + linearityRightSource[#] &, sourcePowers];
linearityLeftDelta = endpointDeltaData[
  <|targetAlpha -> linearityLeftSource|>];
linearityRightDelta = endpointDeltaData[
  <|targetAlpha -> linearityRightSource|>];
linearityCombinedDelta = endpointDeltaData[
  <|targetAlpha -> linearityCombinedSource|>];
linearityLeftPlus = endpointPlusData[
  <|targetAlpha -> linearityLeftSource|>];
linearityRightPlus = endpointPlusData[
  <|targetAlpha -> linearityRightSource|>];
linearityCombinedPlus = endpointPlusData[
  <|targetAlpha -> linearityCombinedSource|>];
operatorLinearityChecks = <|
  "Delta" -> And @@ Map[exactZeroQ[
      linearityCombinedDelta[#] - linearityLeftDelta[#] -
        linearityRightDelta[#]] &, deltaPowers],
  "BoundedPlus" -> And @@ Map[exactZeroQ[
      linearityCombinedPlus[#] - linearityLeftPlus[#] -
        linearityRightPlus[#]] &, plusPowers],
  "Ordinary" -> And @@ Map[exactZeroQ[
      -carrierCoefficient[linearityCombinedSource, targetAlpha, #]/s23 +
        carrierCoefficient[linearityLeftSource, targetAlpha, #]/s23 +
        carrierCoefficient[linearityRightSource, targetAlpha, #]/s23] &,
    ordinaryPowers]|>;
require[And @@ Values[operatorLinearityChecks],
  "fresh distribution-linearity proof failed", operatorLinearityChecks];

storedDistributionCorrections =
  correctedS05["Correction", "DistributionCorrections"];
correctionPayloadChecks = <|
  "OldResidue" -> And @@ Map[exactZeroQ[
      oldTargetResidue[#] -
        correctedS05["Correction", "OldEndpointResidue", #]] &,
    projectors],
  "ReplacementResidue" -> And @@ Map[exactZeroQ[
      freshSolvedInvariantResidue[#] -
        correctedS05["Correction", "ReplacementEndpointResidue", #]] &,
    projectors],
  "ResidueDifference" -> And @@ Map[exactZeroQ[
      freshResidueCorrection[#] -
        correctedS05["Correction", "EndpointResidueDifference", #]] &,
    projectors],
  "DeltaCorrection" -> And @@ Flatten@Table[exactZeroQ[
    freshDeltaCorrections[projector, power] -
      storedDistributionCorrections["DeltaLaurent", projector, power]],
    {projector, projectors}, {power, deltaPowers}],
  "BoundedPlusCorrection" -> And @@ Flatten@Table[exactZeroQ[
    freshPlusCorrections[projector, power] -
      storedDistributionCorrections[
        "BoundedPlusLaurent", projector, power]],
    {projector, projectors}, {power, plusPowers}],
  "OrdinaryCorrection" -> And @@ Flatten@Table[exactZeroQ[
    freshOrdinaryCorrections[projector, power] -
      storedDistributionCorrections["OrdinaryLaurent", projector, power]],
    {projector, projectors}, {power, ordinaryPowers}]|>;
require[And @@ Values[correctionPayloadChecks],
  "fresh correction disagrees with stored payload",
  correctionPayloadChecks];

endpointWithoutTarget[data_Association] := AssociationMap[
  If[# === targetAlpha, KeyDrop[data[#], targetPower], data[#]] &,
  Keys[data]];
structuralUpdateChecks = <|
  "EndpointReplacement" -> And @@ Map[exactZeroQ[
      correctedRealLedger[#, sameFamily,
          "EndpointResidueByAlphaThroughEpsilon1", targetAlpha,
          targetPower] - freshSolvedInvariantResidue[#]] &, projectors],
  "DeltaDifference" -> And @@ Flatten@Table[SameQ[
    correctedRealLedger[projector, sameFamily, "DeltaLaurent", power],
    oldRealLedger[projector, sameFamily, "DeltaLaurent", power] +
      storedDistributionCorrections["DeltaLaurent", projector, power]],
    {projector, projectors}, {power, deltaPowers}],
  "BoundedPlusDifference" -> And @@ Flatten@Table[SameQ[
    correctedRealLedger[projector, sameFamily,
      "BoundedPlusLaurent", power],
    oldRealLedger[projector, sameFamily, "BoundedPlusLaurent", power] +
      storedDistributionCorrections[
        "BoundedPlusLaurent", projector, power]],
    {projector, projectors}, {power, plusPowers}],
  "OrdinaryDifference" -> And @@ Flatten@Table[SameQ[
    correctedRealLedger[projector, sameFamily, "OrdinaryLaurent", power],
    oldRealLedger[projector, sameFamily, "OrdinaryLaurent", power] +
      storedDistributionCorrections["OrdinaryLaurent", projector, power]],
    {projector, projectors}, {power, ordinaryPowers}],
  "NonTargetFamilies" -> And @@ Map[SameQ[
      KeyDrop[correctedRealLedger[#], sameFamily],
      KeyDrop[oldRealLedger[#], sameFamily]] &, projectors],
  "NonTargetEndpointSources" -> And @@ Map[SameQ[
      endpointWithoutTarget[correctedRealLedger[#, sameFamily,
        "EndpointResidueByAlphaThroughEpsilon1"]],
      endpointWithoutTarget[oldRealLedger[#, sameFamily,
        "EndpointResidueByAlphaThroughEpsilon1"]]] &, projectors],
  "TargetFamilyMetadata" -> And @@ Map[SameQ[
      KeyDrop[correctedRealLedger[#, sameFamily],
        {"EndpointResidueByAlphaThroughEpsilon1", "DeltaLaurent",
          "BoundedPlusLaurent", "OrdinaryLaurent"}],
      KeyDrop[oldRealLedger[#, sameFamily],
        {"EndpointResidueByAlphaThroughEpsilon1", "DeltaLaurent",
          "BoundedPlusLaurent", "OrdinaryLaurent"}]] &, projectors]|>;
require[And @@ Values[structuralUpdateChecks],
  "corrected ledger isolation failed", structuralUpdateChecks];

unaffectedPoleOrderChecks = <|
  "DeltaDoublePole" -> And @@ Map[
    exactZeroQ[freshDeltaCorrections[#, -2]] &, projectors],
  "BoundedPlusSinglePole" -> And @@ Map[
    exactZeroQ[freshPlusCorrections[#, -1]] &, projectors],
  "OrdinarySinglePole" -> And @@ Map[
    exactZeroQ[freshOrdinaryCorrections[#, -1]] &, projectors]|>;
require[And @@ Values[unaffectedPoleOrderChecks],
  "fresh correction changed an unaffected pole order",
  unaffectedPoleOrderChecks];

Print["S05_ENDPOINT_VALIDATION_STAGE=validate exact production poles"];
freshCorrectedProductionResiduals = AssociationMap[Function[projector,
  <|-2 -> oldProductionResiduals[projector, -2],
    -1 -> balancedExactSum[
      {productionOtherSinglePole[projector],
        freshDistributionCoefficient freshSolvedMappedResidue[projector]},
      projector <> "/validation-corrected-single-pole"]|>], projectors];
poleCancellationChecks = AssociationMap[Function[projector,
  AssociationMap[exactZeroQ[
    freshCorrectedProductionResiduals[projector, #]] &, polePowers]],
  projectors];
storedPoleRecordChecks = <|
  "OldResiduals" -> And @@ Flatten@Table[exactZeroQ[
    oldProductionResiduals[projector, power] -
      correctedS05["Correction", "OldProductionDeltaResiduals",
        projector, power]],
    {projector, projectors}, {power, polePowers}],
  "CorrectedResiduals" -> And @@ Flatten@Table[exactZeroQ[
    freshCorrectedProductionResiduals[projector, power] -
      correctedS05["Correction", "CorrectedProductionDeltaResiduals",
        projector, power]],
    {projector, projectors}, {power, polePowers}],
  "PoleChecks" -> SameQ[poleCancellationChecks,
    correctedS05["Correction", "PoleCancellationChecks"]]|>;
require[And @@ Flatten[Values /@ Values[poleCancellationChecks]] &&
    And @@ Values[storedPoleRecordChecks],
  "fresh corrected production-pole gate failed",
  <|"Poles" -> poleCancellationChecks,
    "StoredRecords" -> storedPoleRecordChecks|>];

validationChecks = <|
  "ArtifactIdentities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "TargetLocalization" -> And @@ Values[targetChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "ProductionMap" -> And @@ Values[productionMapChecks],
  "DistributionCoefficient" ->
    And @@ Values[distributionCoefficientChecks],
  "ReplacementResidues" -> And @@ Values[replacementChecks],
  "DistributionOperatorLinearity" ->
    And @@ Values[operatorLinearityChecks],
  "CorrectionPayload" -> And @@ Values[correctionPayloadChecks],
  "StructuralIsolation" -> And @@ Values[structuralUpdateChecks],
  "UnaffectedPoleOrders" -> And @@ Values[unaffectedPoleOrderChecks],
  "ProductionPoleRecords" -> And @@ Values[storedPoleRecordChecks],
  "ProductionPoleCancellation" ->
    And @@ Flatten[Values /@ Values[poleCancellationChecks]],
  "NoS05ProductionCacheInput" ->
    schemaChecks["NoS05ProductionCacheInput"],
  "ExactClosed" -> ! badSymbolicQ[
      {correctedRealLedger, freshSolvedInvariantResidue,
        freshDeltaCorrections, freshPlusCorrections,
        freshOrdinaryCorrections}] &&
    FreeQ[correctedRealLedger, epsilon | _SeriesData | _Real]|>;
require[And @@ Values[validationChecks],
  "one or more independent validation gates failed", validationChecks];

validationResult = <|
  "Stage" -> "HqqV2S05EndpointCorrectionValidation-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> expectedHashes,
  "Target" -> <|"Family" -> sameFamily,
    "DistributionAlpha" -> targetAlpha,
    "EndpointResidueEpsilonPower" -> targetPower|>,
  "ExpressionSHA256" -> <|
    "ReplacementEndpointResidue" ->
      Map[expressionHash, freshSolvedInvariantResidue],
    "EndpointResidueDifference" ->
      Map[expressionHash, freshResidueCorrection],
    "CorrectedProductionDeltaResiduals" ->
      AssociationMap[Map[expressionHash,
        freshCorrectedProductionResiduals[#]] &, projectors]|>,
  "PoleCancellationChecks" -> poleCancellationChecks,
  "Checks" -> validationChecks|>;
require[! FileExistsQ[validationResultPath],
  "refusing to overwrite an existing validation result"];
atomicPut[validationResult, validationResultPath];
Print["S05_ENDPOINT_VALIDATION_RESULT_SHA256=",
  FileHash[validationResultPath, "SHA256", "HexString"]];
reloadedValidation = Quiet@Check[Get[validationResultPath], $Failed];
require[SameQ[reloadedValidation, validationResult] &&
    AssociationQ[reloadedValidation] &&
    reloadedValidation["Stage"] ===
      "HqqV2S05EndpointCorrectionValidation-v1" &&
    And @@ Values[reloadedValidation["Checks"]] &&
    And @@ Flatten[Values /@
      Values[reloadedValidation["PoleCancellationChecks"]]],
  "fresh validation-result reload failed"];
Print["S05_ENDPOINT_VALIDATION_TARGET=", InputForm[targetPair]];
Print["S05_ENDPOINT_VALIDATION_POLE_CHECKS=",
  InputForm[poleCancellationChecks]];
Print["S05_ENDPOINT_VALIDATION_CHECKS=", InputForm[validationChecks]];
Print["S05_ENDPOINT_VALIDATION_FRESH_RELOAD_OK"];
Print["S05_ENDPOINT_VALIDATION_SUCCESS"];
Quit[0];

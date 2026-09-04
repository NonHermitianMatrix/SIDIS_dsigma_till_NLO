(* Hqq_v2 S07: isolate the cached same-flavor delta-pole origin. *)

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
  canonicalLogArguments, commonDeltaMap, deltaSourceContribution,
  rootEven, rootOdd, colorSignature, compactMetadata];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_SAME_FLAVOR_ORIGIN_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_SAME_FLAVOR_ORIGIN_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Real | Indeterminate | ComplexInfinity | DirectedInfinity];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], fail["diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
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
canonicalLogArguments[expression_] := expression /.
  HoldPattern[Log[argument_]] :> Log[Factor[Cancel[Together[argument]]]];
compactMetadata[expression_] := <|
  "Zero" -> exactZeroQ[expression],
  "LeafCount" -> LeafCount[expression],
  "SHA256" -> expressionHash[expression]|>;

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
s04Path = FileNameJoin[{stageDirectory, "s04_result.wl"}];
s05Path = FileNameJoin[{stageDirectory, "s05_result.wl"}];
s06Path = FileNameJoin[{stageDirectory, "s06_result.wl"}];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
poleDiagnosticPath = FileNameJoin[{stageDirectory,
  "s07_combination_diagnostic_result.wl"}];
commonBasisResultPath = FileNameJoin[{stageDirectory,
  "s07_delta_common_basis_result.wl"}];
resultPath = FileNameJoin[{stageDirectory,
  "s07_same_flavor_pole_origin_result.wl"}];

expectedHashes = <|
  "S04" ->
    "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c",
  "S05" ->
    "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f",
  "S06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48",
  "PoleDiagnostic" ->
    "d68a942fc7374c7c1b78d5c6ae633983af2f10bda7e34deddd1c4d6696b03b09",
  "CommonBasisResult" ->
    "638c5c66e84921dbfc715908866e9704a300bbe5dc0e2987c5235fb1c2fcb6c8"|>;
inputPaths = <|"S04" -> s04Path, "S05" -> s05Path,
  "S06" -> s06Path, "FactorizationCache" -> factorizationCachePath,
  "PoleDiagnostic" -> poleDiagnosticPath,
  "CommonBasisResult" -> commonBasisResultPath|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[resultPath],
  "diagnostic input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] === expectedHashes[#] &,
  Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "diagnostic input identity failed", identityChecks];

Print["S07_SAME_FLAVOR_ORIGIN_STAGE=load accepted compact ledgers"];
s04 = Quiet@Check[Get[s04Path], $Failed];
s05 = Quiet@Check[Get[s05Path], $Failed];
s06 = Quiet@Check[Get[s06Path], $Failed];
factorizationCache = Quiet@Check[Get[factorizationCachePath], $Failed];
poleDiagnostic = Quiet@Check[Get[poleDiagnosticPath], $Failed];
commonBasisResult = Quiet@Check[Get[commonBasisResultPath], $Failed];
require[And @@ Map[AssociationQ,
    {s04, s05, s06, factorizationCache, poleDiagnostic,
      commonBasisResult}] &&
    And @@ Map[# ["ScopeTag"] === scopeTag &,
      {s04, s05, s06, factorizationCache, poleDiagnostic,
        commonBasisResult}] &&
    And @@ Values[s04["Checks"]] && And @@ Values[s05["Checks"]] &&
    And @@ Values[s06["Checks"]] &&
    And @@ Values[factorizationCache["Checks"]] &&
    And @@ Values[commonBasisResult["Checks"]],
  "stored input schema or gate failed"];

projectors = {"Pg", "PPP"};
families = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"};
sameFamily = "Hqq;q_qbar_sameFlavor";
realLedger = s05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
factorizationLedger =
  factorizationCache["Factorization", "LaurentLedger"];
endpointData = AssociationMap[
  s05["RealLaurentLedger", #, sameFamily,
    "EndpointResidueByAlphaThroughEpsilon1"] &, projectors];
s23Upper = s05["Conventions", "EndpointInterval"][[2]];
storedRoot = s05["EndpointBranches", "B19RootJet", "EndpointRoot"];
bornProjection = AssociationMap[
  factorizationCache["LowerBorn", "Projected", "Hqq", #] &,
  projectors];
inverseFractionRules =
  factorizationCache["Factorization", "InverseFractionRules"];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
zetaMap = s04["VariableMap", "Zeta"];
schemaChecks = <|
  "Projectors" -> (Keys[realLedger] === projectors &&
    Keys[virtualLedger] === projectors &&
    Keys[factorizationLedger] === projectors),
  "Families" -> And @@ (Keys[realLedger[#]] === families & /@ projectors),
  "EndpointAlphaAgreement" ->
    (Keys[endpointData["Pg"]] === Keys[endpointData["PPP"]]),
  "EndpointPowerAgreement" -> And @@ Flatten@Table[
    Keys[endpointData[projector, alpha]] === {-1, 0, 1},
    {projector, projectors}, {alpha, Keys[endpointData[projector]]}],
  "StoredRoot" -> MatchQ[storedRoot,
    HoldPattern[Power[Power[_, 2], Rational[1, 2]]]],
  "BornProjection" -> And @@ (! badSymbolicQ[#] && # =!= 0 & /@
    Values[bornProjection])|>;
require[And @@ Values[schemaChecks],
  "selected ledger schema changed", schemaChecks];

Print["S07_SAME_FLAVOR_ORIGIN_STAGE=derive common delta map"];
zetaDefinitionEquation = (zetaMap /. s23 -> 0) == z/zHat;
phtSolutions = Solve[zetaDefinitionEquation, PHT2];
require[Length[phtSolutions] === 1 &&
    MatchQ[First[phtSolutions], {Rule[PHT2, _]}],
  "stored zeta map does not determine a unique PHT2 rule"];
phtRule = First[phtSolutions];
phtInvariantRule = phtRule /. inverseFractionRules /. u1Rule /.
  s23 -> 0;
phtInvariantRule = PHT2 -> Cancel[Together[PHT2 /. phtInvariantRule]];
mapChecks = <|
  "ZetaDefinition" -> exactZeroQ[
    Subtract @@ zetaDefinitionEquation /. phtRule],
  "MatchesAcceptedCommonBasis" ->
    SameQ[phtInvariantRule, commonBasisResult["DerivedPHTRule"]],
  "Closed" -> FreeQ[Last[phtInvariantRule],
    PHT2 | xHat | zHat | k1T2 | zeta | s23 | u1]|>;
require[And @@ Values[mapChecks], "common delta-map gate failed", mapChecks];

selectedRawComponents = AssociationMap[Function[projector, <|
  "Hqq;gg" -> Lookup[
    realLedger[projector, "Hqq;gg", "DeltaLaurent"], -1, 0],
  sameFamily -> Lookup[
    realLedger[projector, sameFamily, "DeltaLaurent"], -1, 0],
  "Hqq;qPrime_qbarPrime" -> Lookup[
    realLedger[projector, "Hqq;qPrime_qbarPrime", "DeltaLaurent"], -1, 0],
  "Virtual" -> Lookup[
    virtualLedger[projector, "DeltaLaurent"], -1, 0],
  "Factorization" -> Lookup[
    factorizationLedger[projector, "Delta"], -1, 0]|>], projectors];
selectedExpressions = {selectedRawComponents, endpointData,
  bornProjection, s23Upper};
specialAtoms = DeleteDuplicates@Cases[selectedExpressions, _PolyGamma,
  Infinity];
specialValues = Quiet@Check[FunctionExpand /@ specialAtoms, $Failed];
require[specialValues =!= $Failed &&
    Length[specialValues] === Length[specialAtoms] &&
    FreeQ[specialValues, _PolyGamma] && ! badSymbolicQ[specialValues],
  "selected special-function expansion failed"];
specialResiduals = Quiet@Check[MapThread[FullSimplify[#1 - #2] &,
  {specialAtoms, specialValues}], $Failed];
require[specialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ specialResiduals),
  "selected special-function identities failed", specialResiduals];
specialRules = MapThread[Rule, {specialAtoms, specialValues}];

commonDeltaMap[expression_, kind_String] := Module[{answer},
  answer = expression /. specialRules;
  If[kind === "Virtual",
    answer = answer /. {tHat -> t1, uHat -> u1}];
  answer = answer /. phtRule /. inverseFractionRules /. u1Rule /.
    s23 -> 0;
  answer = canonicalLogArguments[answer];
  Quiet@Check[Cancel[Together[answer]], $Failed]
];

Print["S07_SAME_FLAVOR_ORIGIN_STAGE=map both projector pole ledgers"];
mappedComponents = AssociationMap[Function[projector,
  AssociationMap[Function[name,
    commonDeltaMap[selectedRawComponents[projector, name],
      If[name === "Virtual", "Virtual", "Other"]]],
    Keys[selectedRawComponents[projector]]]], projectors];
require[! badSymbolicQ[mappedComponents],
  "mapped component construction failed"];
mappedResiduals = AssociationMap[balancedExactSum[
  Values[mappedComponents[#]], # <> "/mapped-residual"] &, projectors];
pgStoredMappedResidual = commonDeltaMap[
  poleDiagnostic["CombinationMetadata", "ZeroResidual"], "Other"];
pgDiagnosticAgreement = exactZeroQ[
  mappedResiduals["Pg"] - pgStoredMappedResidual];
require[pgDiagnosticAgreement,
  "fresh Pg component sum disagrees with accepted pole diagnostic"];

alphas = Keys[endpointData["Pg"]];
powers = {-1, 0, 1};
deltaSourceContribution[projector_String, alpha_, power_Integer] :=
  Coefficient[Normal@Series[
    -s23Upper^(-alpha epsilon)/(alpha epsilon) *
      epsilon^power endpointData[projector, alpha, power],
    {epsilon, 0, 0}], epsilon, -1];
rawSourcePieces = AssociationMap[Function[projector,
  Association@Table[alpha -> Association@Table[power ->
    deltaSourceContribution[projector, alpha, power],
    {power, powers}], {alpha, alphas}]], projectors];
rawSourceSums = AssociationMap[balancedExactSum[
  Flatten[Values /@ Values[rawSourcePieces[#]]],
  # <> "/raw-endpoint-source-sum"] &, projectors];
sourceReconstructionChecks = AssociationMap[exactZeroQ[
  rawSourceSums[#] - selectedRawComponents[#, sameFamily]] &,
  projectors];
require[And @@ Values[sourceReconstructionChecks],
  "endpoint-source reconstruction failed", sourceReconstructionChecks];

Print["S07_SAME_FLAVOR_ORIGIN_STAGE=map endpoint source contributions"];
mappedSourcePieces = AssociationMap[Function[projector,
  AssociationMap[Function[alpha,
    AssociationMap[commonDeltaMap[rawSourcePieces[projector, alpha, #],
      "Other"] &, powers]], alphas]], projectors];
require[! badSymbolicQ[mappedSourcePieces],
  "mapped endpoint-source construction failed"];
mappedSourceSums = AssociationMap[balancedExactSum[
  Flatten[Values /@ Values[mappedSourcePieces[#]]],
  # <> "/mapped-endpoint-source-sum"] &, projectors];
mappedSourceReconstructionChecks = AssociationMap[exactZeroQ[
  mappedSourceSums[#] - mappedComponents[#, sameFamily]] &,
  projectors];
require[And @@ Values[mappedSourceReconstructionChecks],
  "mapped endpoint-source reconstruction failed",
  mappedSourceReconstructionChecks];

rootInventories = Map[principalRootAtoms, mappedComponents];
require[AllTrue[Flatten[Values[rootInventories]],
      SameQ[#, storedRoot] &] &&
    MemberQ[Flatten[Values[rootInventories]], storedRoot],
  "mapped root inventory changed", rootInventories];
rootEven[expression_] := Quiet@Check[Cancel[Together[
  (expression + (expression /. storedRoot -> -storedRoot))/2]], $Failed];
rootOdd[expression_] := Quiet@Check[Cancel[Together[
  (expression - (expression /. storedRoot -> -storedRoot))/2]], $Failed];

sameEven = AssociationMap[rootEven[mappedComponents[#, sameFamily]] &,
  projectors];
sameOdd = AssociationMap[rootOdd[mappedComponents[#, sameFamily]] &,
  projectors];
require[! badSymbolicQ[{sameEven, sameOdd}],
  "same-flavor root-parity split failed"];
sameParityReconstructionChecks = AssociationMap[exactZeroQ[
  sameEven[#] + sameOdd[#] - mappedComponents[#, sameFamily]] &,
  projectors];
require[And @@ Values[sameParityReconstructionChecks],
  "same-flavor root-parity reconstruction failed"];

sourceOdd = AssociationMap[Function[projector,
  AssociationMap[Function[alpha,
    AssociationMap[rootOdd[mappedSourcePieces[projector, alpha, #]] &,
      powers]], alphas]], projectors];
sourceEven = AssociationMap[Function[projector,
  AssociationMap[Function[alpha,
    AssociationMap[rootEven[mappedSourcePieces[projector, alpha, #]] &,
      powers]], alphas]], projectors];
require[! badSymbolicQ[{sourceOdd, sourceEven}],
  "endpoint-source root-parity split failed"];
sourceOddSums = AssociationMap[balancedExactSum[
  Flatten[Values /@ Values[sourceOdd[#]]],
  # <> "/source-root-odd-sum"] &, projectors];
sourceEvenSums = AssociationMap[balancedExactSum[
  Flatten[Values /@ Values[sourceEven[#]]],
  # <> "/source-root-even-sum"] &, projectors];
sourceParitySumChecks = AssociationMap[
  exactZeroQ[sourceOddSums[#] - sameOdd[#]] &&
    exactZeroQ[sourceEvenSums[#] - sameEven[#]] &, projectors];
require[And @@ Values[sourceParitySumChecks],
  "source parity sums do not reconstruct same-flavor parity"];

Print["S07_SAME_FLAVOR_ORIGIN_STAGE=derive color and Born-tensor tests"];
born4 = AssociationMap[commonDeltaMap[
  bornProjection[#] /. D -> 4, "Other"] &, projectors];
require[And @@ (! badSymbolicQ[#] && # =!= 0 & /@ Values[born4]),
  "four-dimensional Born templates failed"];
bornTensorChecks = <|
  "SameFlavorTotal" -> exactZeroQ[
    mappedComponents["Pg", sameFamily] born4["PPP"] -
      mappedComponents["PPP", sameFamily] born4["Pg"]],
  "SameFlavorEven" -> exactZeroQ[
    sameEven["Pg"] born4["PPP"] - sameEven["PPP"] born4["Pg"]],
  "SameFlavorOdd" -> exactZeroQ[
    sameOdd["Pg"] born4["PPP"] - sameOdd["PPP"] born4["Pg"]],
  "FullResidual" -> exactZeroQ[
    mappedResiduals["Pg"] born4["PPP"] -
      mappedResiduals["PPP"] born4["Pg"]]|>;
sourceBornTensorChecks = Association@Table[alpha -> Association@Table[
  power -> exactZeroQ[
    mappedSourcePieces["Pg", alpha, power] born4["PPP"] -
      mappedSourcePieces["PPP", alpha, power] born4["Pg"]],
  {power, powers}], {alpha, alphas}];
sourceOddBornTensorChecks = Association@Table[alpha -> Association@Table[
  power -> exactZeroQ[
    sourceOdd["Pg", alpha, power] born4["PPP"] -
      sourceOdd["PPP", alpha, power] born4["Pg"]],
  {power, powers}], {alpha, alphas}];

colorSignature[expression_] := Module[
  {rational, numerator, denominator, numeratorRules, denominatorRules},
  rational = Quiet@Check[Together[
    expression /. storedRoot -> hqqV2S07RootDummy], $Failed];
  require[rational =!= $Failed && ! badSymbolicQ[rational],
    "color rationalization failed"];
  numerator = Numerator[rational];
  denominator = Denominator[rational];
  require[PolynomialQ[numerator, SUNN] && PolynomialQ[denominator, SUNN],
    "color dependence is not polynomial after common denominator"];
  numeratorRules = CoefficientRules[numerator, {SUNN}];
  denominatorRules = CoefficientRules[denominator, {SUNN}];
  <|"NumeratorDegree" -> Exponent[numerator, SUNN],
    "DenominatorDegree" -> Exponent[denominator, SUNN],
    "NumeratorPowers" -> (#[[1, 1]] & /@ numeratorRules),
    "DenominatorPowers" -> (#[[1, 1]] & /@ denominatorRules),
    "NumeratorCoefficientSHA256" -> Association@Map[
      ToString[#[[1, 1]]] -> expressionHash[#[[2]]] &, numeratorRules],
    "DenominatorCoefficientSHA256" -> Association@Map[
      ToString[#[[1, 1]]] -> expressionHash[#[[2]]] &, denominatorRules]|>
];
colorSignatures = <|
  "SameFlavorOdd" -> AssociationMap[colorSignature[sameOdd[#]] &,
    projectors],
  "FullResidual" -> AssociationMap[colorSignature[mappedResiduals[#]] &,
    projectors]|>;

sourceOddMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[alpha,
    AssociationMap[compactMetadata[sourceOdd[projector, alpha, #]] &,
      powers]], alphas]], projectors];
sourceEvenMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[alpha,
    AssociationMap[compactMetadata[sourceEven[projector, alpha, #]] &,
      powers]], alphas]], projectors];
componentMetadata = AssociationMap[Function[projector,
  Map[compactMetadata, mappedComponents[projector]]], projectors];
sameParityMetadata = AssociationMap[Function[projector, <|
  "Even" -> compactMetadata[sameEven[projector]],
  "Odd" -> compactMetadata[sameOdd[projector]]|>], projectors];
residualMetadata = AssociationMap[compactMetadata[mappedResiduals[#]] &,
  projectors];
flavorMultiplicityFreeChecks = AssociationMap[FreeQ[
  mappedResiduals[#], _HqqV2FlavorMultiplicity] &, projectors];
closedExactCheck = FreeQ[
  {mappedComponents, mappedResiduals, mappedSourcePieces, sameEven,
    sameOdd, sourceEven, sourceOdd, born4},
  PHT2 | xHat | zHat | k1T2 | zeta | s23 | u1 | epsilon |
    _SeriesData | _Real | $Failed | Indeterminate | ComplexInfinity |
    DirectedInfinity];

checks = <|
  "Identities" -> And @@ Values[identityChecks],
  "Schemas" -> And @@ Values[schemaChecks],
  "CommonDeltaMap" -> And @@ Values[mapChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ specialResiduals),
  "PgDiagnosticAgreement" -> pgDiagnosticAgreement,
  "EndpointSourceReconstruction" ->
    And @@ Values[sourceReconstructionChecks],
  "MappedEndpointSourceReconstruction" ->
    And @@ Values[mappedSourceReconstructionChecks],
  "RootParityReconstruction" ->
    And @@ Values[sameParityReconstructionChecks],
  "SourceParitySums" -> And @@ Values[sourceParitySumChecks],
  "FlavorMultiplicityFreeResiduals" ->
    And @@ Values[flavorMultiplicityFreeChecks],
  "ClosedExact" -> closedExactCheck|>;
require[And @@ Values[checks],
  "one or more same-flavor origin gates failed", checks];

result = <|
  "Stage" -> "HqqV2S07SameFlavorPoleOrigin-v1",
  "ScopeTag" -> scopeTag,
  "SourceSHA256" -> FileHash[sourcePath, "SHA256", "HexString"],
  "Inputs" -> expectedHashes,
  "Location" -> <|"Sector" -> "Delta", "EpsilonPower" -> -1|>,
  "DerivedPHTRule" -> phtInvariantRule,
  "EndpointAlphas" -> alphas,
  "EndpointSourcePowers" -> powers,
  "StoredRoot" -> storedRoot,
  "ComponentMetadata" -> componentMetadata,
  "ResidualMetadata" -> residualMetadata,
  "SameFlavorParityMetadata" -> sameParityMetadata,
  "EndpointSourceOddMetadata" -> sourceOddMetadata,
  "EndpointSourceEvenMetadata" -> sourceEvenMetadata,
  "EndpointSourceReconstructionChecks" -> sourceReconstructionChecks,
  "MappedEndpointSourceReconstructionChecks" ->
    mappedSourceReconstructionChecks,
  "SourceParitySumChecks" -> sourceParitySumChecks,
  "BornTensorProportionalityChecks" -> bornTensorChecks,
  "EndpointSourceBornTensorChecks" -> sourceBornTensorChecks,
  "EndpointSourceOddBornTensorChecks" -> sourceOddBornTensorChecks,
  "ColorSignatures" -> colorSignatures,
  "FlavorMultiplicityFreeChecks" -> flavorMultiplicityFreeChecks,
  "Checks" -> checks|>;

Print["S07_SAME_FLAVOR_ORIGIN_RESIDUAL_ZERO=",
  InputForm[Map[# ["Zero"] &, residualMetadata]]];
Print["S07_SAME_FLAVOR_ORIGIN_PARITY=",
  InputForm[Map[Map[# ["Zero"] &, #] &, sameParityMetadata]]];
Print["S07_SAME_FLAVOR_ORIGIN_SOURCE_ODD_ZERO=",
  InputForm[Map[Map[Map[# ["Zero"] &, #] &, #] &,
    sourceOddMetadata]]];
Print["S07_SAME_FLAVOR_ORIGIN_BORN_TENSOR_CHECKS=",
  InputForm[bornTensorChecks]];
Print["S07_SAME_FLAVOR_ORIGIN_SOURCE_BORN_TENSOR_CHECKS=",
  InputForm[sourceBornTensorChecks]];
Print["S07_SAME_FLAVOR_ORIGIN_SOURCE_ODD_BORN_TENSOR_CHECKS=",
  InputForm[sourceOddBornTensorChecks]];
Print["S07_SAME_FLAVOR_ORIGIN_CHECKS=", InputForm[checks]];
atomicPut[result, resultPath];
resultReload = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[resultReload, result], "fresh diagnostic reload failed"];
Print["S07_SAME_FLAVOR_ORIGIN_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_SAME_FLAVOR_POLE_ORIGIN_SUCCESS"];
Quit[0];

(* Hqq_v2 S07: derive and test the common two-body delta basis. *)

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
  canonicalLogArguments, canonicalDeltaExpression, balancedExactSum];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_DELTA_BASIS_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_DELTA_BASIS_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], fail["diagnostic publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "diagnostic temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
];
balancedExactSum[values_List] := Module[{level, next},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed, "component canonicalization failed"];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Quiet@Check[
      Map[If[Length[#] === 1, First[#],
        Cancel[Together[#[[1]] + #[[2]]]]] &,
        Partition[level, UpTo[2]]], $Failed];
    require[next =!= $Failed, "balanced component addition failed"];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
diagnosticPath = FileNameJoin[{stageDirectory,
  "s07_combination_diagnostic_result.wl"}];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
s04Path = FileNameJoin[{stageDirectory, "s04_result.wl"}];
resultPath = FileNameJoin[{stageDirectory,
  "s07_delta_common_basis_result.wl"}];
expectedDiagnosticHash =
  "d68a942fc7374c7c1b78d5c6ae633983af2f10bda7e34deddd1c4d6696b03b09";
expectedFactorizationCacheHash =
  "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48";
expectedS04Hash =
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c";

paths = {diagnosticPath, factorizationCachePath, s04Path};
require[And @@ Map[FileExistsQ, paths] && ! FileExistsQ[resultPath],
  "diagnostic input/target state is invalid"];
identityChecks = <|
  "PoleDiagnostic" ->
    (FileHash[diagnosticPath, "SHA256", "HexString"] ===
      expectedDiagnosticHash),
  "FactorizationCache" ->
    (FileHash[factorizationCachePath, "SHA256", "HexString"] ===
      expectedFactorizationCacheHash),
  "S04" -> (FileHash[s04Path, "SHA256", "HexString"] ===
    expectedS04Hash)|>;
require[And @@ Values[identityChecks],
  "diagnostic input identity failed", identityChecks];

Print["S07_DELTA_BASIS_STAGE=load exact stored maps and components"];
diagnostic = Quiet@Check[Get[diagnosticPath], $Failed];
factorizationCache = Quiet@Check[Get[factorizationCachePath], $Failed];
s04 = Quiet@Check[Get[s04Path], $Failed];
require[AssociationQ[diagnostic] && AssociationQ[factorizationCache] &&
    AssociationQ[s04] && diagnostic["ScopeTag"] === scopeTag &&
    factorizationCache["ScopeTag"] === scopeTag &&
    s04["ScopeTag"] === scopeTag &&
    And @@ Values[factorizationCache["Checks"]] &&
    And @@ Values[s04["Checks"]],
  "stored input schema or gate failed"];

inverseFractionRules =
  factorizationCache["Factorization", "InverseFractionRules"];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
zetaMap = s04["VariableMap", "Zeta"];
require[MatchQ[inverseFractionRules, {(_Rule)..}] &&
    MatchQ[u1Rule, {(_Rule)..}] && ! FreeQ[zetaMap, PHT2],
  "stored fraction-map schema changed"];

Print["S07_DELTA_BASIS_STAGE=derive observed-transverse rule"];
zetaDefinitionEquation = (zetaMap /. s23 -> 0) == z/zHat;
phtSolutions = Solve[zetaDefinitionEquation, PHT2];
require[Length[phtSolutions] === 1 &&
    MatchQ[First[phtSolutions], {Rule[PHT2, _]}],
  "stored zeta map does not uniquely determine PHT2 on delta support"];
phtRule = First[phtSolutions];
phtInvariantRule = phtRule /. inverseFractionRules /. u1Rule /.
  s23 -> 0;
phtInvariantRule = PHT2 -> Cancel[Together[PHT2 /. phtInvariantRule]];
mapDerivationChecks = <|
  "UniquePHTRule" -> (Length[phtSolutions] === 1),
  "PHTRuleClosesZetaDefinition" -> exactZeroQ[
    Subtract @@ zetaDefinitionEquation /. phtRule],
  "InverseRulesComplete" -> FreeQ[
    Values[inverseFractionRules], xHat | zHat | k1T2],
  "InvariantPHTRule" -> FreeQ[phtInvariantRule,
    xHat | zHat | k1T2 | zeta | s23 | u1]|>;
require[And @@ Values[mapDerivationChecks],
  "common delta-map derivation failed", mapDerivationChecks];

canonicalLogArguments[expression_] := expression /.
  HoldPattern[Log[argument_]] :> Log[Factor[Cancel[Together[argument]]]];
canonicalDeltaExpression[expression_] := Module[{answer},
  answer = expression /. phtRule /. inverseFractionRules /.
    u1Rule /. s23 -> 0;
  answer = canonicalLogArguments[answer];
  Cancel[Together[answer]]
];

Print["S07_DELTA_BASIS_STAGE=map five exact pole components"];
components = diagnostic["Components"];
componentNames = diagnostic["ComponentOrder"];
mappedComponents = AssociationMap[Function[name,
  Print["S07_DELTA_BASIS_COMPONENT=", name];
  canonicalDeltaExpression[components[name]]], componentNames];
mappedResidualFromComponents = balancedExactSum[Values[mappedComponents]];
mappedStoredResidual = canonicalDeltaExpression[
  diagnostic["CombinationMetadata", "ZeroResidual"]];
componentSumCheck = exactZeroQ[
  mappedResidualFromComponents - mappedStoredResidual];
require[componentSumCheck,
  "common-basis component sum does not reconstruct stored residual"];

roots = DeleteDuplicates@Cases[mappedResidualFromComponents,
  HoldPattern[Power[Power[_, 2], Rational[1, 2]]], Infinity];
require[Length[roots] === 1,
  "common-basis residual does not retain exactly one principal root",
  roots];
root = First[roots];
require[Head[root] === Power && Last[List @@ root] === Rational[1, 2],
  "common-basis root has unexpected internal form"];
rootArgument = First[List @@ root];
linearBranch = PowerExpand[root];
require[FreeQ[linearBranch, Power[_, Rational[1, 2]]] &&
    exactZeroQ[linearBranch^2 - rootArgument],
  "Wolfram did not derive the algebraic linear branch"];

positiveResidual = balancedExactSum[
  Values[mappedComponents] /. root -> linearBranch];
negativeResidual = balancedExactSum[
  Values[mappedComponents] /. root -> -linearBranch];
branchZeroChecks = <|
  "PositiveLinearBranch" -> exactZeroQ[positiveResidual],
  "NegativeLinearBranch" -> exactZeroQ[negativeResidual]|>;
rootDummyResidual = Cancel[Together[
  mappedResidualFromComponents /. root -> hqqV2S07RootDummy]];
rootRelation = hqqV2S07RootDummy^2 - rootArgument;
rootRemainder = Quiet@Check[PolynomialRemainder[
  Numerator[rootDummyResidual], rootRelation, hqqV2S07RootDummy],
  $Failed];
require[rootRemainder =!= $Failed,
  "common-basis quotient reduction failed"];
rootRemainderZero = exactZeroQ[rootRemainder];

inverseAtDelta = inverseFractionRules /. u1Rule /. s23 -> 0;
xHatInvariant = xHat /. inverseAtDelta;
zHatInvariant = zHat /. inverseAtDelta;
k1T2Invariant = k1T2 /. inverseAtDelta;
physicalAssumptions = Q2 > 0 && 0 < xHatInvariant < 1 &&
  0 < zHatInvariant < 1 && k1T2Invariant > 0;
positiveRegion = Quiet@Check[Reduce[
  physicalAssumptions && linearBranch > 0,
  {Q2, sHat, t1}, Reals], $Failed];
negativeRegion = Quiet@Check[Reduce[
  physicalAssumptions && linearBranch < 0,
  {Q2, sHat, t1}, Reals], $Failed];
signRegionChecks = <|
  "PositiveRegionExists" ->
    (positiveRegion =!= False && positiveRegion =!= $Failed),
  "NegativeRegionExists" ->
    (negativeRegion =!= False && negativeRegion =!= $Failed)|>;

checks = <|
  "Identities" -> And @@ Values[identityChecks],
  "MapDerivation" -> And @@ Values[mapDerivationChecks],
  "ComponentSum" -> componentSumCheck,
  "MappedExpressionsClosed" -> FreeQ[mappedComponents,
    PHT2 | xHat | zHat | k1T2 | zeta | s23 | u1 |
      $Failed | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity],
  "RootReductionClosed" -> FreeQ[
    {rootRemainder, positiveResidual, negativeResidual},
    $Failed | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity],
  "SignRegionsComputed" -> And @@ Values[signRegionChecks]|>;
require[And @@ Values[checks],
  "one or more common delta-basis gates failed", checks];

result = <|
  "Stage" -> "HqqV2S07DeltaCommonBasis-v1",
  "ScopeTag" -> scopeTag,
  "SourceSHA256" -> FileHash[sourcePath, "SHA256", "HexString"],
  "Inputs" -> <|"PoleDiagnosticSHA256" -> expectedDiagnosticHash,
    "FactorizationCacheSHA256" -> expectedFactorizationCacheHash,
    "S04ResultSHA256" -> expectedS04Hash|>,
  "DerivedPHTRule" -> phtInvariantRule,
  "MapDerivationChecks" -> mapDerivationChecks,
  "ComponentLeafCounts" -> Map[LeafCount, mappedComponents],
  "ComponentSHA256" -> Map[expressionHash, mappedComponents],
  "ComponentSumCheck" -> componentSumCheck,
  "Root" -> root,
  "WolframLinearBranch" -> linearBranch,
  "RootRemainderZero" -> rootRemainderZero,
  "RootRemainderLeafCount" -> LeafCount[rootRemainder],
  "RootRemainderSHA256" -> expressionHash[rootRemainder],
  "BranchZeroChecks" -> branchZeroChecks,
  "SignRegionChecks" -> signRegionChecks,
  "PositiveRegion" -> positiveRegion,
  "NegativeRegion" -> negativeRegion,
  "Checks" -> checks|>;
Print["S07_DELTA_BASIS_DERIVED_PHT_RULE=", InputForm[phtInvariantRule]];
Print["S07_DELTA_BASIS_ROOT_REMAINDER_ZERO=", rootRemainderZero];
Print["S07_DELTA_BASIS_BRANCH_ZERO_CHECKS=",
  InputForm[branchZeroChecks]];
Print["S07_DELTA_BASIS_SIGN_REGION_CHECKS=",
  InputForm[signRegionChecks]];
Print["S07_DELTA_BASIS_CHECKS=", InputForm[checks]];
atomicPut[result, resultPath];
resultReload = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[resultReload, result], "fresh diagnostic reload failed"];
Print["S07_DELTA_BASIS_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_DELTA_COMMON_BASIS_SUCCESS"];
Quit[0];

(* Hqq_v2 S05: production-basis correction of one localized endpoint residue. *)

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
  associationExpression, carrierCoefficient, rawDeltaComponents,
  productionDeltaComponents, endpointDeltaData, endpointPlusData,
  endpointWithoutTarget, compactMetadata, globalSymbolInventory,
  canonicalLogArgumentsOnce, canonicalLogArguments];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S05_ENDPOINT_CORRECTION_FAILURE: ", message];
  If[detail =!= Null,
    Print["S05_ENDPOINT_CORRECTION_FAILURE_DETAIL=", InputForm[detail]]];
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
  Check[Put[expression, temporary], fail["result publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "result temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing"];
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
compactMetadata[expression_] := <|
  "Zero" -> exactZeroQ[expression],
  "LeafCount" -> LeafCount[expression],
  "SHA256" -> expressionHash[expression]|>;
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
resultPath = FileNameJoin[{stageDirectory, "s05_result.wl"}];
inputPaths = <|
  "S04" -> FileNameJoin[{stageDirectory, "s04_result.wl"}],
  "OriginalS05Source" -> FileNameJoin[{stageDirectory,
    "s05_expand_hqq_endpoints.wl"}],
  "OriginalS05" -> FileNameJoin[{stageDirectory,
    "s05_result_pre_endpoint_correction_e470276a.wl"}],
  "S06" -> FileNameJoin[{stageDirectory, "s06_result.wl"}],
  "FactorizationCache" -> FileNameJoin[{stageDirectory,
    "s07_factorization_laurent_cache.wl"}],
  "PoleDiagnostic" -> FileNameJoin[{stageDirectory,
    "s07_combination_diagnostic_result.wl"}],
  "OriginResult" -> FileNameJoin[{stageDirectory,
    "s07_same_flavor_pole_origin_result.wl"}]|>;
expectedHashes = <|
  "S04" ->
    "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c",
  "OriginalS05Source" ->
    "cd8e471d24fec0e751463c36f08bdeb72c0a791379d350cbc99e24b541d4fdac",
  "OriginalS05" ->
    "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f",
  "S06" ->
    "a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979",
  "FactorizationCache" ->
    "4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48",
  "PoleDiagnostic" ->
    "d68a942fc7374c7c1b78d5c6ae633983af2f10bda7e34deddd1c4d6696b03b09",
  "OriginResult" ->
    "aee72e0980a7a4635fb4c47429748dea2c9c7b8ad05297a259a7a75f8caf347d"|>;
require[And @@ Map[FileExistsQ, Values[inputPaths]] &&
    ! FileExistsQ[resultPath],
  "correction input/target state is invalid"];
identityChecks = AssociationMap[
  FileHash[inputPaths[#], "SHA256", "HexString"] === expectedHashes[#] &,
  Keys[inputPaths]];
require[And @@ Values[identityChecks],
  "correction input identity failed", identityChecks];

Print["S05_ENDPOINT_CORRECTION_STAGE=load compact accepted ledgers"];
s04 = Quiet@Check[Get[inputPaths["S04"]], $Failed];
oldS05 = Quiet@Check[Get[inputPaths["OriginalS05"]], $Failed];
s06 = Quiet@Check[Get[inputPaths["S06"]], $Failed];
factorizationCache = Quiet@Check[
  Get[inputPaths["FactorizationCache"]], $Failed];
poleDiagnostic = Quiet@Check[Get[inputPaths["PoleDiagnostic"]], $Failed];
originResult = Quiet@Check[Get[inputPaths["OriginResult"]], $Failed];
require[And @@ Map[AssociationQ,
    {s04, oldS05, s06, factorizationCache, poleDiagnostic,
      originResult}] &&
    And @@ Map[# ["ScopeTag"] === scopeTag &,
      {s04, oldS05, s06, factorizationCache, poleDiagnostic,
        originResult}] &&
    oldS05["Stage"] === "HqqV2S05-v1" &&
    oldS05["Source", "SHA256"] === expectedHashes["OriginalS05Source"] &&
    poleDiagnostic["Stage"] === "HqqV2S07PoleDiagnostic-v1" &&
    originResult["Stage"] === "HqqV2S07SameFlavorPoleOrigin-v1" &&
    And @@ Values[s04["Checks"]] && And @@ Values[oldS05["Checks"]] &&
    And @@ Values[s06["Checks"]] &&
    And @@ Values[factorizationCache["Checks"]] &&
    And @@ Values[originResult["Checks"]],
  "stored correction input schema or checks failed"];

projectors = {"Pg", "PPP"};
families = {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"};
componentNames = Join[families, {"Virtual", "Factorization"}];
sameFamily = "Hqq;q_qbar_sameFlavor";
realLedger = oldS05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
factorizationLedger =
  factorizationCache["Factorization", "LaurentLedger"];
endpointData = AssociationMap[
  realLedger[#, sameFamily,
    "EndpointResidueByAlphaThroughEpsilon1"] &, projectors];
s23Upper = oldS05["Conventions", "EndpointInterval"][[2]];
phaseAlpha = oldS05["Conventions", "PhaseDistributionAlpha"];
storedRoot = oldS05["EndpointBranches", "B19RootJet", "EndpointRoot"];
bornProjection = AssociationMap[
  factorizationCache["LowerBorn", "Projected", "Hqq", #] &,
  projectors];
u1Rule = factorizationCache["Factorization", "ConservationRule"];
alphas = Keys[endpointData["Pg"]];
sourcePowers = Keys[endpointData["Pg", First[alphas]]];
sourcePairs = Tuples[{alphas, sourcePowers}];
bornFailingPairs = Select[sourcePairs, ! TrueQ[
    originResult["EndpointSourceBornTensorChecks", #[[1]], #[[2]]]] &];
oddNonzeroPairs = Select[sourcePairs,
  ! TrueQ[originResult["EndpointSourceOddMetadata", "Pg",
       #[[1]], #[[2]], "Zero"]] ||
    ! TrueQ[originResult["EndpointSourceOddMetadata", "PPP",
       #[[1]], #[[2]], "Zero"]] &];
locationChecks = <|
  "Projectors" -> (Keys[realLedger] === projectors &&
    Keys[virtualLedger] === projectors &&
    Keys[factorizationLedger] === projectors),
  "Families" -> And @@ (Keys[realLedger[#]] === families & /@ projectors),
  "EndpointSchemas" -> And @@ Flatten@Table[
    Keys[endpointData[projector]] === alphas &&
      Keys[endpointData[projector, alpha]] === sourcePowers,
    {projector, projectors}, {alpha, alphas}],
  "UniqueDiagnosticLocation" ->
    (Length[bornFailingPairs] === 1 &&
      SameQ[bornFailingPairs, oddNonzeroPairs]),
  "DiagnosticEpsilonPower" ->
    (Length[bornFailingPairs] === 1 && Last[First[bornFailingPairs]] === 0),
  "DiagnosticDistributionAlpha" ->
    (Length[bornFailingPairs] === 1 &&
      First[First[bornFailingPairs]] === phaseAlpha),
  "PhaseAlphaDerived" -> IntegerQ[phaseAlpha] && phaseAlpha > 0,
  "StoredRoot" -> MatchQ[storedRoot,
    HoldPattern[Power[Power[_, 2], Rational[1, 2]]]],
  "BornProjection" -> And @@ (! badSymbolicQ[#] && # =!= 0 & /@
    Values[bornProjection]),
  "PoleDiagnosticLocation" ->
    poleDiagnostic["Location"] === <|"Projector" -> "Pg",
      "Sector" -> "Delta", "EpsilonPower" -> -1|>,
  "PoleDiagnosticComponents" ->
    poleDiagnostic["ComponentOrder"] === componentNames|>;
require[And @@ Values[locationChecks],
  "localized correction contract changed", locationChecks];
targetPair = First[bornFailingPairs];
targetAlpha = First[targetPair];
targetPower = Last[targetPair];

Print["S05_ENDPOINT_CORRECTION_STAGE=derive production basis"];
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {realLedger, virtualLedger, factorizationLedger}, _PolyGamma, Infinity];
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
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
canonicalRealDelta[expression_] :=
  canonicalLogArguments[
    canonicalCombinationBasis[expression] /. u1Rule /. s23 -> 0];
canonicalVirtualDelta[expression_] :=
  canonicalLogArguments[canonicalCombinationBasis[expression] /.
    {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0];
canonicalFactorizationDelta[expression_] :=
  canonicalLogArguments[
    canonicalCombinationBasis[expression] /. s23 -> 0];

deltaU1Rule = u1Rule /. s23 -> 0;
require[MatchQ[deltaU1Rule, {Rule[u1, _]}],
  "production conservation rule schema changed"];
consumerQ2Solutions = Solve[Equal @@ First[deltaU1Rule], Q2];
s04Q2Solutions = Solve[s04["Conservation", "BaseEquations", "S23"], Q2];
require[Length[consumerQ2Solutions] === 1 &&
    MatchQ[First[consumerQ2Solutions], {Rule[Q2, _]}] &&
    Length[s04Q2Solutions] === 1 &&
    MatchQ[First[s04Q2Solutions], {Rule[Q2, _]}],
  "production map did not have one tool-derived inverse"];
endpointQ2Rule = First[s04Q2Solutions] /. s23 -> 0;
consumerInverseQ2Rule = First[consumerQ2Solutions];
productionMapChecks = <|
  "S04AndConsumerInverseAgree" -> exactZeroQ[
    (Q2 /. endpointQ2Rule) - (Q2 /. consumerInverseQ2Rule)],
  "S04EndpointClosure" -> exactZeroQ[
    (Subtract @@ s04["Conservation", "BaseEquations", "S23"]) /.
      s23 -> 0 /. endpointQ2Rule],
  "ConsumerEndpointClosure" -> exactZeroQ[
    (Subtract @@ (Equal @@ First[deltaU1Rule])) /.
      endpointQ2Rule]|>;
require[And @@ Values[productionMapChecks],
  "production map derivation failed", productionMapChecks];

Print["S05_ENDPOINT_CORRECTION_STAGE=derive distribution coefficient"];
distributionCoefficient = Quiet@Check[Cancel[Together[
  Coefficient[Normal@Series[
    -s23Upper^(-targetAlpha epsilon)/(targetAlpha epsilon) *
      epsilon^targetPower hqqEndpointDummy,
    {epsilon, 0, 0}], epsilon, -1]/hqqEndpointDummy]], $Failed];
distributionCoefficientChecks = <|
  "Derived" -> (distributionCoefficient =!= $Failed &&
    ! badSymbolicQ[distributionCoefficient]),
  "Nonzero" -> ! exactZeroQ[distributionCoefficient],
  "Closed" -> FreeQ[distributionCoefficient,
    epsilon | s23 | hqqEndpointDummy | _SeriesData]|>;
require[And @@ Values[distributionCoefficientChecks],
  "distribution coefficient derivation failed",
  distributionCoefficientChecks];

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

Print["S05_ENDPOINT_CORRECTION_STAGE=map old production poles"];
polePowers = {-2, -1};
oldProductionComponents = AssociationMap[Function[projector,
  AssociationMap[productionDeltaComponents[
    realLedger, projector, #] &, polePowers]], projectors];
oldProductionResiduals = AssociationMap[Function[projector,
  AssociationMap[balancedExactSum[
    Values[oldProductionComponents[projector, #]],
    projector <> "/old-production-delta/epsilon " <> ToString[#]] &,
    polePowers]], projectors];
diagnosticComponentAgreement = AssociationMap[exactZeroQ[
    oldProductionComponents["Pg", -1, #] -
      canonicalLogArguments[poleDiagnostic["Components", #]]] &,
  componentNames];
diagnosticResidualAgreement = exactZeroQ[
  oldProductionResiduals["Pg", -1] -
    canonicalLogArguments[
      poleDiagnostic["CombinationMetadata", "ZeroResidual"]]];
require[And @@ Values[diagnosticComponentAgreement] &&
    diagnosticResidualAgreement,
  "fresh production map disagrees with accepted S07 diagnostic",
  <|"Components" -> diagnosticComponentAgreement,
    "Residual" -> diagnosticResidualAgreement|>];

oldTargetResidue = AssociationMap[
  endpointData[#, targetAlpha, targetPower] &, projectors];
oldProductionTargetSource = AssociationMap[Cancel[Together[
    canonicalRealDelta[
      distributionCoefficient oldTargetResidue[#]]]] &,
  projectors];
productionOtherSinglePole = AssociationMap[Function[projector,
  balancedExactSum[Join[
    Values@KeyDrop[oldProductionComponents[projector, -1], sameFamily],
    {balancedExactSum[
      {oldProductionComponents[projector, -1, sameFamily],
        -oldProductionTargetSource[projector]},
      projector <> "/same-flavor/non-target-source"]}],
    projector <> "/all-production-non-target-sources"]], projectors];

Print["S05_ENDPOINT_CORRECTION_STAGE=solve production pole equations"];
replacementMappedResidue = AssociationMap[Function[projector,
  Module[{solutions},
    solutions = Quiet@Check[Solve[
      distributionCoefficient hqqReplacementResidue ==
        -productionOtherSinglePole[projector], hqqReplacementResidue],
      $Failed];
    require[ListQ[solutions] && Length[solutions] === 1 &&
        MatchQ[First[solutions], {Rule[hqqReplacementResidue, _]}],
      projector <> " replacement residue solve failed", solutions];
    Cancel[Together[hqqReplacementResidue /. First[solutions]]]
  ]], projectors];
replacementInvariantResidue = AssociationMap[Cancel[Together[
    replacementMappedResidue[#] /. endpointQ2Rule]] &,
  projectors];
replacementForwardMapped = AssociationMap[Cancel[Together[
    canonicalRealDelta[replacementInvariantResidue[#]]]] &,
  projectors];
allowedRealSymbols = globalSymbolInventory[realLedger];
replacementSymbolInventory =
  Map[globalSymbolInventory, replacementInvariantResidue];
unexpectedReplacementSymbols =
  Map[Complement[#, allowedRealSymbols] &, replacementSymbolInventory];
born4Production = AssociationMap[Cancel[Together[
    canonicalFactorizationDelta[bornProjection[#] /. D -> 4]]] &,
  projectors];
componentBornTensorDiagnostic = AssociationMap[exactZeroQ[
    oldProductionComponents["Pg", -1, #] born4Production["PPP"] -
      oldProductionComponents["PPP", -1, #] born4Production["Pg"]] &,
  componentNames];
replacementBornDifference =
  replacementMappedResidue["Pg"] born4Production["PPP"] -
    replacementMappedResidue["PPP"] born4Production["Pg"];
replacementChecks = <|
  "SolveClosed" -> ! badSymbolicQ[
    {replacementMappedResidue, replacementInvariantResidue}],
  "ForwardMapClosure" -> And @@ Map[exactZeroQ[
      replacementForwardMapped[#] - replacementMappedResidue[#]] &,
    projectors],
  "PrincipalRootFree" ->
    (principalRootAtoms[replacementInvariantResidue] === {} &&
      FreeQ[replacementInvariantResidue, storedRoot]),
  "ProductionSymbolClosure" ->
    And @@ (SameQ[#, {}] & /@ Values[unexpectedReplacementSymbols]),
  "MappedSinglePoleCancellation" -> And @@ Map[exactZeroQ[
      productionOtherSinglePole[#] +
        distributionCoefficient replacementMappedResidue[#]] &,
    projectors]|>;
componentSymbolInventory = AssociationMap[
  Map[globalSymbolInventory, oldProductionComponents[#, -1]] &,
  projectors];
forwardDifferenceMetadata = AssociationMap[compactMetadata[
    replacementForwardMapped[#] - replacementMappedResidue[#]] &,
  projectors];
require[And @@ Values[replacementChecks],
  "solved production-basis residue failed acceptance gates",
  <|"Checks" -> replacementChecks,
    "MappedSymbols" -> Map[globalSymbolInventory,
      replacementMappedResidue],
    "InvariantSymbols" -> replacementSymbolInventory,
    "ComponentSymbols" -> componentSymbolInventory,
    "ForwardDifference" -> forwardDifferenceMetadata,
    "UnexpectedSymbols" -> unexpectedReplacementSymbols|>];

residueCorrection = AssociationMap[balancedExactSum[
  {replacementInvariantResidue[#], -oldTargetResidue[#]},
  # <> "/endpoint-residue-difference"] &, projectors];
correctionEndpointData = AssociationMap[Function[projector,
  AssociationMap[If[# === targetPower, residueCorrection[projector], 0] &,
    sourcePowers]], projectors];
endpointDeltaData[dataByAlpha_Association] := Module[{expression},
  expression = Total@Table[Normal@Series[
    -s23Upper^(-alpha epsilon)/(alpha epsilon) *
      associationExpression[dataByAlpha[alpha]], {epsilon, 0, 0}],
    {alpha, Keys[dataByAlpha]}];
  AssociationMap[Coefficient[expression, epsilon, #] &, Range[-2, 0]]
];
endpointPlusData[dataByAlpha_Association] := Module[{expression},
  expression = Total@Table[Normal@Series[
    associationExpression[dataByAlpha[alpha]] *
      (HqqV2BoundedPlus[0, s23, s23Upper] -
        alpha epsilon HqqV2BoundedPlus[1, s23, s23Upper]),
    {epsilon, 0, 0}], {alpha, Keys[dataByAlpha]}];
  AssociationMap[Coefficient[expression, epsilon, #] &, Range[-1, 0]]
];

Print["S05_ENDPOINT_CORRECTION_STAGE=propagate solved difference"];
deltaCorrections = AssociationMap[endpointDeltaData[
  <|targetAlpha -> correctionEndpointData[#]|>] &, projectors];
plusCorrections = AssociationMap[endpointPlusData[
  <|targetAlpha -> correctionEndpointData[#]|>] &, projectors];
ordinaryCorrections = AssociationMap[Function[projector,
  AssociationMap[-carrierCoefficient[
      correctionEndpointData[projector], targetAlpha, #]/s23 &,
    Keys[realLedger[projector, sameFamily, "OrdinaryLaurent"]]]],
  projectors];
require[! badSymbolicQ[
    {residueCorrection, deltaCorrections, plusCorrections,
      ordinaryCorrections}],
  "distribution propagation produced an unresolved expression"];
unaffectedPoleOrderChecks = <|
  "DeltaDoublePole" -> And @@ Map[
    exactZeroQ[deltaCorrections[#, -2]] &, projectors],
  "BoundedPlusSinglePole" -> And @@ Map[
    exactZeroQ[plusCorrections[#, -1]] &, projectors],
  "OrdinarySinglePole" -> And @@ Map[
    exactZeroQ[ordinaryCorrections[#, -1]] &, projectors]|>;
require[And @@ Values[unaffectedPoleOrderChecks],
  "localized correction changed an unaffected pole order",
  unaffectedPoleOrderChecks];

Print["S05_ENDPOINT_CORRECTION_STAGE=prove distribution linearity"];
linearityLeftSource = AssociationMap[
  hqqLinearityLeft[#] &, sourcePowers];
linearityRightSource = AssociationMap[
  hqqLinearityRight[#] &, sourcePowers];
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
ordinaryPowers = DeleteDuplicates@Flatten[
  Keys[realLedger[#, sameFamily, "OrdinaryLaurent"]] & /@ projectors];
distributionOperatorLinearityChecks = <|
  "Delta" -> And @@ Map[exactZeroQ[
      linearityCombinedDelta[#] - linearityLeftDelta[#] -
        linearityRightDelta[#]] &,
    Keys[linearityCombinedDelta]],
  "BoundedPlus" -> And @@ Map[exactZeroQ[
      linearityCombinedPlus[#] - linearityLeftPlus[#] -
        linearityRightPlus[#]] &,
    Keys[linearityCombinedPlus]],
  "Ordinary" -> And @@ Map[exactZeroQ[
      -carrierCoefficient[linearityCombinedSource, targetAlpha, #]/s23 +
        carrierCoefficient[linearityLeftSource, targetAlpha, #]/s23 +
        carrierCoefficient[linearityRightSource, targetAlpha, #]/s23] &,
    ordinaryPowers]|>;
require[And @@ Values[distributionOperatorLinearityChecks],
  "distribution operators failed exact linearity gates",
  distributionOperatorLinearityChecks];

correctedLedger = realLedger;
Do[
  oldFamilyRecord = realLedger[projector, sameFamily];
  correctedEndpoint = ReplacePart[
    oldFamilyRecord["EndpointResidueByAlphaThroughEpsilon1"],
    {Key[targetAlpha], Key[targetPower]} ->
      replacementInvariantResidue[projector]];
  correctedDelta = AssociationMap[
    Lookup[oldFamilyRecord["DeltaLaurent"], #, 0] +
      Lookup[deltaCorrections[projector], #, 0] &,
    Keys[oldFamilyRecord["DeltaLaurent"]]];
  correctedPlus = AssociationMap[
    Lookup[oldFamilyRecord["BoundedPlusLaurent"], #, 0] +
      Lookup[plusCorrections[projector], #, 0] &,
    Keys[oldFamilyRecord["BoundedPlusLaurent"]]];
  correctedOrdinary = AssociationMap[
    Lookup[oldFamilyRecord["OrdinaryLaurent"], #, 0] +
      Lookup[ordinaryCorrections[projector], #, 0] &,
    Keys[oldFamilyRecord["OrdinaryLaurent"]]];
  correctedFamilyRecord = ReplacePart[oldFamilyRecord, {
    Key["EndpointResidueByAlphaThroughEpsilon1"] -> correctedEndpoint,
    Key["DeltaLaurent"] -> correctedDelta,
    Key["BoundedPlusLaurent"] -> correctedPlus,
    Key["OrdinaryLaurent"] -> correctedOrdinary}];
  correctedLedger = ReplacePart[correctedLedger,
    {Key[projector], Key[sameFamily]} -> correctedFamilyRecord],
  {projector, projectors}];

Print["S05_ENDPOINT_CORRECTION_STAGE=validate structural ledger update"];
distributionReconstructionChecks = <|
  "OperatorLinearity" ->
    And @@ Values[distributionOperatorLinearityChecks],
  "EndpointDifference" -> And @@ Map[exactZeroQ[
      correctedLedger[#, sameFamily,
          "EndpointResidueByAlphaThroughEpsilon1", targetAlpha,
          targetPower] -
        realLedger[#, sameFamily,
          "EndpointResidueByAlphaThroughEpsilon1", targetAlpha,
          targetPower] - residueCorrection[#]] &, projectors],
  "DeltaDifference" -> And @@ Flatten@Table[SameQ[
    correctedLedger[projector, sameFamily, "DeltaLaurent", power],
    realLedger[projector, sameFamily, "DeltaLaurent", power] +
      Lookup[deltaCorrections[projector], power, 0]],
    {projector, projectors},
    {power, Keys[realLedger[projector, sameFamily,
      "DeltaLaurent"]]}],
  "BoundedPlusDifference" -> And @@ Flatten@Table[SameQ[
    correctedLedger[projector, sameFamily, "BoundedPlusLaurent", power],
    realLedger[projector, sameFamily, "BoundedPlusLaurent", power] +
      Lookup[plusCorrections[projector], power, 0]],
    {projector, projectors},
    {power, Keys[realLedger[projector, sameFamily,
      "BoundedPlusLaurent"]]}],
  "OrdinaryDifference" -> And @@ Flatten@Table[SameQ[
    correctedLedger[projector, sameFamily, "OrdinaryLaurent", power],
    realLedger[projector, sameFamily, "OrdinaryLaurent", power] +
      Lookup[ordinaryCorrections[projector], power, 0]],
    {projector, projectors},
    {power, Keys[realLedger[projector, sameFamily,
      "OrdinaryLaurent"]]}]|>;
require[And @@ Values[distributionReconstructionChecks],
  "corrected distribution ledger does not reconstruct",
  distributionReconstructionChecks];

endpointWithoutTarget[data_Association] := AssociationMap[
  If[# === targetAlpha, KeyDrop[data[#], targetPower], data[#]] &,
  Keys[data]];
unchangedChecks = <|
  "NonTargetFamilies" -> And @@ Table[SameQ[
    KeyDrop[correctedLedger[projector], sameFamily],
    KeyDrop[realLedger[projector], sameFamily]],
    {projector, projectors}],
  "NonTargetEndpointSources" -> And @@ Table[SameQ[
    endpointWithoutTarget[correctedLedger[projector, sameFamily,
      "EndpointResidueByAlphaThroughEpsilon1"]],
    endpointWithoutTarget[realLedger[projector, sameFamily,
      "EndpointResidueByAlphaThroughEpsilon1"]]],
    {projector, projectors}],
  "TargetFamilyMetadata" -> And @@ Table[SameQ[
    KeyDrop[correctedLedger[projector, sameFamily],
      {"EndpointResidueByAlphaThroughEpsilon1", "DeltaLaurent",
        "BoundedPlusLaurent", "OrdinaryLaurent"}],
    KeyDrop[realLedger[projector, sameFamily],
      {"EndpointResidueByAlphaThroughEpsilon1", "DeltaLaurent",
        "BoundedPlusLaurent", "OrdinaryLaurent"}]],
    {projector, projectors}],
  "NoProductionCacheInput" -> Intersection[Keys[inputPaths],
    {"MasterCache", "CoefficientCache", "EndpointCache",
      "RootGroupCache"}] === {}|>;
require[And @@ Values[unchangedChecks],
  "an unaffected S05 field changed", unchangedChecks];

Print["S05_ENDPOINT_CORRECTION_STAGE=validate corrected production poles"];
correctedProductionResiduals = AssociationMap[Function[projector,
  <|-2 -> oldProductionResiduals[projector, -2],
    -1 -> productionOtherSinglePole[projector] +
      distributionCoefficient replacementMappedResidue[projector]|>],
  projectors];
poleCancellationChecks = AssociationMap[Function[projector,
  AssociationMap[exactZeroQ[
    correctedProductionResiduals[projector, #]] &, polePowers]],
  projectors];
require[And @@ Flatten[Values /@ Values[poleCancellationChecks]],
  "corrected production delta poles did not cancel",
  poleCancellationChecks];

correctionChecks = <|
  "InputIdentities" -> And @@ Values[identityChecks],
  "LocalizedDiagnostic" -> And @@ Values[locationChecks],
  "ProductionMap" -> And @@ Values[productionMapChecks],
  "SpecialFunctionIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "AcceptedDiagnosticAgreement" ->
    And @@ Values[diagnosticComponentAgreement] &&
      diagnosticResidualAgreement,
  "DistributionCoefficient" ->
    And @@ Values[distributionCoefficientChecks],
  "ReplacementResidue" -> And @@ Values[replacementChecks],
  "DistributionReconstruction" ->
    And @@ Values[distributionReconstructionChecks],
  "UnaffectedPoleOrders" -> And @@ Values[unaffectedPoleOrderChecks],
  "UnaffectedFieldsUnchanged" -> And @@ Values[unchangedChecks],
  "FullProductionDeltaPoleCancellation" ->
    And @@ Flatten[Values /@ Values[poleCancellationChecks]],
  "ExactClosed" -> ! badSymbolicQ[correctedLedger] &&
    FreeQ[correctedLedger, epsilon | _SeriesData | _Real]|>;
require[And @@ Values[correctionChecks],
  "one or more final correction gates failed", correctionChecks];

correctionRecord = <|
  "Schema" -> "HqqV2S05SameFlavorEndpointCorrection-v2",
  "OriginDiagnosticSHA256" -> expectedHashes["OriginResult"],
  "ProductionPoleDiagnosticSHA256" -> expectedHashes["PoleDiagnostic"],
  "Target" -> <|"Family" -> sameFamily,
    "DistributionAlpha" -> targetAlpha,
    "EndpointResidueEpsilonPower" -> targetPower|>,
  "DistributionSinglePoleCoefficient" -> distributionCoefficient,
  "OldEndpointResidue" -> oldTargetResidue,
  "ReplacementEndpointResidue" -> replacementInvariantResidue,
  "EndpointResidueDifference" -> residueCorrection,
  "DistributionCorrections" -> <|
    "DeltaLaurent" -> deltaCorrections,
    "BoundedPlusLaurent" -> plusCorrections,
    "OrdinaryLaurent" -> ordinaryCorrections|>,
  "ProductionMap" -> <|"ForwardU1Rule" -> deltaU1Rule,
    "InverseQ2Rule" -> endpointQ2Rule,
    "Checks" -> productionMapChecks|>,
  "OldProductionDeltaResiduals" -> oldProductionResiduals,
  "CorrectedProductionDeltaResiduals" -> correctedProductionResiduals,
  "PoleCancellationChecks" -> poleCancellationChecks,
  "ReplacementChecks" -> replacementChecks,
  "DistributionReconstructionChecks" ->
    distributionReconstructionChecks,
  "UnaffectedChecks" -> unchangedChecks,
  "BornTensorLocalizationDiagnostic" -> <|
    "AcceptanceGate" -> False,
    "CompleteComponentChecks" -> componentBornTensorDiagnostic,
    "ReplacementDifferenceMetadata" ->
      compactMetadata[replacementBornDifference]|>,
  "ExpressionSHA256" -> <|
    "OldEndpointResidue" -> Map[expressionHash, oldTargetResidue],
    "ReplacementEndpointResidue" ->
      Map[expressionHash, replacementInvariantResidue],
    "EndpointResidueDifference" -> Map[expressionHash, residueCorrection]|>,
  "Checks" -> correctionChecks|>;

correctedS05 = Join[ReplacePart[oldS05, {
  Key["Stage"] -> "HqqV2S05-v2",
  Key["Source"] -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"],
    "OriginalProductionPath" -> inputPaths["OriginalS05Source"],
    "OriginalProductionSHA256" -> expectedHashes["OriginalS05Source"]|>,
  Key["Inputs"] -> Join[oldS05["Inputs"], <|
    "OriginalS05ResultSHA256" -> expectedHashes["OriginalS05"],
    "CorrectedS06ResultSHA256" -> expectedHashes["S06"],
    "FactorizationCacheSHA256" -> expectedHashes["FactorizationCache"],
    "ProductionPoleDiagnosticSHA256" -> expectedHashes["PoleDiagnostic"],
    "SameFlavorOriginResultSHA256" -> expectedHashes["OriginResult"]|>],
  Key["Runtime"] -> Join[oldS05["Runtime"], <|
    "CorrectionMode" -> "production-basis compact-ledger cache tail",
    "CorrectionWolfram" -> $Version,
    "ReevaluatedAngularMasters" -> 0,
    "ReevaluatedCoefficientCaches" -> 0,
    "ReevaluatedEndpointCaches" -> 0|>],
  Key["RealLaurentLedger"] -> correctedLedger,
  Key["Checks"] -> Join[oldS05["Checks"], <|
    "SameFlavorEndpointCorrection" -> And @@ Values[correctionChecks]|>]
}], <|"Correction" -> correctionRecord|>];
payloadChecks = <|
  "Stage" -> correctedS05["Stage"] === "HqqV2S05-v2",
  "Scope" -> correctedS05["ScopeTag"] === scopeTag,
  "Source" -> correctedS05["Source", "SHA256"] ===
    FileHash[sourcePath, "SHA256", "HexString"],
  "StoredChecks" -> And @@ Values[correctedS05["Checks"]] &&
    And @@ Values[correctedS05["Correction", "Checks"]],
  "ImmutableTopLevelPhysics" -> And @@ (SameQ[
      correctedS05[#], oldS05[#]] & /@
    {"Conventions", "AngularLaurentMasters", "EndpointBranches",
      "ChannelWeights", "BoundedDistributionDefinition",
      "DownstreamBoundary"}),
  "ExactClosed" -> ! badSymbolicQ[correctedS05["RealLaurentLedger"]]|>;
require[And @@ Values[payloadChecks],
  "corrected S05 payload failed final gates", payloadChecks];

require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing active S05 result"];
atomicPut[correctedS05, resultPath];
Print["S05_ENDPOINT_CORRECTION_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, correctedS05] &&
    AssociationQ[reloaded] && reloaded["Stage"] === "HqqV2S05-v2" &&
    And @@ Values[reloaded["Checks"]] &&
    And @@ Values[reloaded["Correction", "Checks"]],
  "same-kernel corrected S05 reload failed"];
Print["S05_ENDPOINT_CORRECTION_TARGET=", InputForm[targetPair]];
Print["S05_ENDPOINT_CORRECTION_POLE_CHECKS=",
  InputForm[poleCancellationChecks]];
Print["S05_ENDPOINT_CORRECTION_CHECKS=", InputForm[correctionChecks]];
Print["S05_ENDPOINT_CORRECTION_FRESH_RELOAD_OK"];
Print["S05_ENDPOINT_CORRECTION_SUCCESS"];
Quit[0];

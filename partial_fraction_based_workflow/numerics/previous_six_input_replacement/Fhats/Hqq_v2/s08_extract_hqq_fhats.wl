(* Hqq_v2 S08: derive Eq. (9) and publish the final symbolic hats. *)

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

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[fail, require, hashMatches, atomicPut, badSymbolicQ,
  exactZeroQ, expressionHash, balancedExactSum,
  denominatorGroupedZero];
fail[message_String, detail_: Null] := (
  Print["S08_FAILURE: ", message];
  If[detail =!= Null,
    Print["S08_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
hashMatches[path_String, expected_String] :=
  FileExistsQ[path] &&
    FileHash[path, "SHA256", "HexString"] === expected;
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    fail["failed to write temporary S08 result"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary S08 result is missing or empty"];
  RenameFile[temporary, path];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published S08 result is missing or empty"];
];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity | Cancel | Together];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];

balancedExactSum[values_List, label_String] := Module[{level, next},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed && ! badSymbolicQ[level],
    label <> " canonicalization failed"];
  level = DeleteCases[level, 0];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Map[If[Length[#] === 1, First[#],
      Quiet@Check[Cancel[Together[#[[1]] + #[[2]]]], $Failed]] &,
      Partition[level, UpTo[2]]];
    require[FreeQ[next, $Failed] && ! badSymbolicQ[next],
      label <> " balanced exact addition failed"];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];

denominatorGroupedZero[expressions_List, label_String] := Module[
  {accumulator = <||>, terms, canonical, denominator, numerator,
   denominatorHash, group, levels, level, carry, groupTotals,
   zeroResidual},
  Do[
    terms = If[Head[expression] === Plus,
      List @@ expression, {expression}];
    Do[
      If[TrueQ[term === 0], Continue[]];
      canonical = Quiet@Check[Cancel[Together[term]], $Failed];
      require[canonical =!= $Failed && ! badSymbolicQ[canonical],
        label <> " term canonicalization failed"];
      If[TrueQ[canonical === 0], Continue[]];
      denominator = Denominator[canonical];
      numerator = Numerator[canonical];
      denominatorHash = IntegerString[
        Hash[denominator, "SHA256"], 16, 64];
      If[KeyExistsQ[accumulator, denominatorHash],
        group = accumulator[denominatorHash];
        require[SameQ[group["Denominator"], denominator],
          label <> " denominator hash collision"],
        group = <|"Denominator" -> denominator, "Levels" -> <||>|>];
      levels = group["Levels"];
      level = 0;
      carry = numerator;
      While[KeyExistsQ[levels, level],
        carry = Quiet@Check[Cancel[Together[
          levels[level] + carry]], $Failed];
        require[carry =!= $Failed && ! badSymbolicQ[carry],
          label <> " numerator accumulation failed"];
        KeyDropFrom[levels, level];
        level++;
        If[TrueQ[carry === 0], Break[]]];
      If[! TrueQ[carry === 0], AssociateTo[levels, level -> carry]];
      AssociateTo[group, "Levels" -> levels];
      AssociateTo[accumulator, denominatorHash -> group],
      {term, terms}],
    {expression, expressions}];
  groupTotals = KeyValueMap[Function[{hash, storedGroup},
    With[{summedNumerator = balancedExactSum[
        Values[KeySort[storedGroup["Levels"]]],
        label <> "/denominator/" <> StringTake[hash, 12]]},
      If[TrueQ[summedNumerator === 0], 0,
        Cancel[summedNumerator/storedGroup["Denominator"]]]]],
    KeySort[accumulator]];
  groupTotals = DeleteCases[groupTotals, 0];
  zeroResidual = balancedExactSum[
    groupTotals, label <> "/cross-denominator"];
  Print["S08_GROUPED_ZERO=", label, " DENOMINATORS=",
    Length[accumulator], " NONZERO_GROUPS=", Length[groupTotals],
    " ZERO=", SameQ[zeroResidual, 0]];
  <|"ZeroResidual" -> zeroResidual,
    "DenominatorCount" -> Length[accumulator],
    "NonzeroGroupCount" -> Length[groupTotals]|>
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
paperPath = FileNameJoin[{DirectoryName[stageDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];
s03Path = FileNameJoin[{stageDirectory, "s03_result.wl"}];
s07Path = FileNameJoin[{stageDirectory, "s07_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s08_result.wl"}];

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS03Hash =
  "b3d483dea534ed26b93e601c28788b6c5797a200bb04e72c913b1c0c6c69ab80";
expectedS07Hash =
  "a858aab618a044d223b1caf5897579db68a692f596fd0b1eafb2d692054b88e4";
inputIdentityChecks = <|
  "Paper" -> hashMatches[paperPath, expectedPaperHash],
  "S03" -> hashMatches[s03Path, expectedS03Hash],
  "S07" -> hashMatches[s07Path, expectedS07Hash]|>;

validationMode = Environment["HQQV2_S08_VALIDATE_ONLY"] === "1";
If[validationMode,
  Print["S08_STAGE=fresh result validation"];
  candidate = Quiet@Check[Get[resultPath], $Failed];
  validationChecks = <|
    "AcceptedInputHashes" -> And @@ Values[inputIdentityChecks],
    "Association" -> AssociationQ[candidate],
    "StageScope" -> TrueQ[AssociationQ[candidate] &&
      candidate["Stage"] === "HqqV2S08-v1" &&
      candidate["ScopeTag"] === scopeTag],
    "Source" -> TrueQ[AssociationQ[candidate] &&
      candidate["Source", "SHA256"] === sourceHash],
    "Inputs" -> TrueQ[AssociationQ[candidate] &&
      candidate["Inputs"] === <|
        "PaperSHA256" -> expectedPaperHash,
        "S03ResultSHA256" -> expectedS03Hash,
        "S07ResultSHA256" -> expectedS07Hash|>],
    "StoredChecks" -> TrueQ[AssociationQ[candidate] &&
      AssociationQ[candidate["Checks"]] &&
      And @@ Values[candidate["Checks"]]],
    "HatSchema" -> TrueQ[AssociationQ[candidate] &&
      AssociationQ[candidate["F1Hat"]] &&
      AssociationQ[candidate["F2Hat"]] &&
      Keys[candidate["F1Hat"]] ===
        {"Delta", "BoundedPlus", "Ordinary"} &&
      Keys[candidate["F2Hat"]] ===
        {"Delta", "BoundedPlus", "Ordinary"}],
    "SchemeProfile" -> TrueQ[AssociationQ[candidate] &&
      And @@ Flatten@Table[
        With[{record = candidate["MSbarSchemeValidation",
            "HatRecords", hat, sector]},
          AssociationQ[record] &&
            IntegerQ[record["DenominatorCount"]] &&
            IntegerQ[record["NonzeroGroupCount"]] &&
            ! badSymbolicQ[record["ZeroResidual"]] &&
            FreeQ[record["ZeroResidual"],
              epsilon | D | FeynCalc`EpsilonUV |
                FeynCalc`EpsilonIR | Abs]],
        {hat, {"F1Hat", "F2Hat"}},
        {sector, {"Delta", "BoundedPlus", "Ordinary"}}]],
    "ExactAndRegulatorFree" -> TrueQ[AssociationQ[candidate] &&
      ! badSymbolicQ[{candidate["F1Hat"], candidate["F2Hat"]}] &&
      FreeQ[{candidate["F1Hat"], candidate["F2Hat"]},
        epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs]],
    "NoTemporary" ->
      FileNames["s08_result.wl.tmp.*", stageDirectory] === {}|>;
  Print["S08_FRESH_CHECKS=", InputForm[validationChecks]];
  If[And @@ Values[validationChecks],
    Print["S08_FRESH_RELOAD_OK"];
    Print["S08_RESULT_SHA256=",
      FileHash[resultPath, "SHA256", "HexString"]];
    Quit[0],
    Print["S08_FRESH_RELOAD_FAILURE"];
    Quit[1]
  ]
];

require[And @@ Values[inputIdentityChecks],
  "accepted S08 input identity mismatch", inputIdentityChecks];
require[! FileExistsQ[resultPath],
  "S08 result already exists; refusing overwrite"];

Print["S08_STAGE=load accepted S03 and S07"];
s03 = Quiet@Check[Get[s03Path], $Failed];
s07 = Quiet@Check[Get[s07Path], $Failed];
projectorLabels = {"Pg", "PPP"};
sectorLabels = {"Delta", "BoundedPlus", "Ordinary"};
hatLabels = {"F1Hat", "F2Hat"};
inputSchemaChecks = <|
  "S03Association" -> AssociationQ[s03],
  "S03StageScope" -> TrueQ[AssociationQ[s03] &&
    s03["Stage"] === "HqqV2S03-v2" &&
    s03["ScopeTag"] === scopeTag],
  "S03StoredChecks" -> TrueQ[AssociationQ[s03] &&
    AssociationQ[s03["Checks"]] && And @@ Values[s03["Checks"]]],
  "S03MSbar" -> TrueQ[AssociationQ[s03] &&
    s03["Renormalization", "Scheme"] === "MSbar"],
  "S03Projectors" -> TrueQ[AssociationQ[s03] &&
    Keys[s03["Projectors"]] === projectorLabels],
  "S07Association" -> AssociationQ[s07],
  "S07StageScope" -> TrueQ[AssociationQ[s07] &&
    s07["Stage"] === "HqqV2S07-v8" &&
    s07["ScopeTag"] === scopeTag],
  "S07StoredChecks" -> TrueQ[AssociationQ[s07] &&
    AssociationQ[s07["Checks"]] && And @@ Values[s07["Checks"]]],
  "S07Actions" -> TrueQ[AssociationQ[s07] &&
    Keys[s07["FiniteProjectedActions"]] === projectorLabels &&
    And @@ (Keys[#] === sectorLabels & /@
      Values[s07["FiniteProjectedActions"]])],
  "S07PolesZero" -> TrueQ[AssociationQ[s07] &&
    s07["PoleResidualList"] =!= {} &&
    And @@ (SameQ[#, 0] & /@ s07["PoleResidualList"])]|>;
require[And @@ Values[inputSchemaChecks],
  "accepted S03/S07 schema failed", inputSchemaChecks];

Print["S08_STAGE=derive D-dimensional projector inversion"];
storedProjectors = s03["Projectors"];
lorentzIndices = DeleteDuplicates@Cases[Values[storedProjectors],
  FeynCalc`LorentzIndex[index_, D] :> index, Infinity];
require[Length[lorentzIndices] === 2,
  "S03 projectors do not expose exactly two photon indices",
  lorentzIndices];
{photonIndex1, photonIndex2} = lorentzIndices;
metricTensor = FeynCalc`Pair[
  FeynCalc`LorentzIndex[photonIndex1, D],
  FeynCalc`LorentzIndex[photonIndex2, D]];
pVector1 = FeynCalc`Pair[
  FeynCalc`LorentzIndex[photonIndex1, D],
  FeynCalc`Momentum[p, D]];
pVector2 = FeynCalc`Pair[
  FeynCalc`LorentzIndex[photonIndex2, D],
  FeynCalc`Momentum[p, D]];
qVector1 = FeynCalc`Pair[
  FeynCalc`LorentzIndex[photonIndex1, D],
  FeynCalc`Momentum[q, D]];
qVector2 = FeynCalc`Pair[
  FeynCalc`LorentzIndex[photonIndex2, D],
  FeynCalc`Momentum[q, D]];
constructedProjectors = <|
  "Pg" -> metricTensor,
  "PPP" -> pVector1 pVector2|>;

FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[p, p] = 0;
FeynCalc`SPD[q, q] = -Q2;
FeynCalc`SPD[p, q] = Q2/(2 xHat);
qSquared = FeynCalc`SPD[q, q];
pDotQ = FeynCalc`SPD[p, q];
tensorBasis1 = -metricTensor + qVector1 qVector2/qSquared;
transverseP1 = pVector1 - qVector1 pDotQ/qSquared;
transverseP2 = pVector2 - qVector2 pDotQ/qSquared;
tensorBasis2 = transverseP1 transverseP2/pDotQ;
partonicTensor = tensorBasis1 f1Symbol + tensorBasis2 f2Symbol;

ClearAll[canonicalProjection];
canonicalProjection[expression_] := Module[{answer},
  answer = Quiet@Check[FeynCalc`Contract[
    FeynCalc`ExpandScalarProduct[expression],
    FeynCalc`FCParallelize -> False], $Failed];
  require[answer =!= $Failed,
    "FeynCalc projector contraction failed"];
  answer = Quiet@Check[Cancel[Together[
    answer /. D -> 4 - 2 epsilon]], $Failed];
  require[answer =!= $Failed && ! badSymbolicQ[answer] &&
      FreeQ[answer, FeynCalc`LorentzIndex],
    "projector contraction did not close", answer];
  answer
];
primitiveContractions = AssociationThread[projectorLabels,
  Table[canonicalProjection[
    storedProjectors[label] partonicTensor],
    {label, projectorLabels}]];
primitiveSymbols = <|"Pg" -> primitivePg,
  "PPP" -> primitivePPP|>;
projectorEquations = Thread[
  Values[primitiveSymbols] == Values[primitiveContractions]];
projectorSolutions = Quiet@Check[
  Solve[projectorEquations, {f1Symbol, f2Symbol}], $Failed];
require[ListQ[projectorSolutions] &&
    Length[projectorSolutions] === 1,
  "Wolfram did not derive one projector inversion",
  projectorSolutions];
projectorSolution = First[projectorSolutions];
structureSolutions = <|
  "F1Hat" -> Cancel[Together[f1Symbol /. projectorSolution]],
  "F2Hat" -> Cancel[Together[f2Symbol /. projectorSolution]]|>;
weightsD = AssociationThread[hatLabels,
  Table[AssociationThread[projectorLabels,
    Table[Cancel[Together[Coefficient[
      structureSolutions[hat], primitiveSymbols[label]]]],
      {label, projectorLabels}]],
    {hat, hatLabels}]];

projectorDerivationChecks = <|
  "StoredPrimitiveProjectors" ->
    SameQ[Map[FeynCalc`FCI, constructedProjectors],
      Map[FeynCalc`FCI, storedProjectors]],
  "PrimitiveContractionsClosed" ->
    ! badSymbolicQ[primitiveContractions] &&
      FreeQ[primitiveContractions, FeynCalc`LorentzIndex],
  "UniqueSolve" -> Length[projectorSolutions] === 1,
  "SolutionsLinearInPrimitiveProjections" -> And @@ Table[
    exactZeroQ[structureSolutions[hat] -
      Total@Table[weightsD[hat, label] primitiveSymbols[label],
        {label, projectorLabels}]],
    {hat, hatLabels}],
  "PrimitiveReconstruction" -> And @@ Table[
    exactZeroQ[(primitiveContractions[label] /. projectorSolution) -
      primitiveSymbols[label]],
    {label, projectorLabels}],
  "WeightsExact" -> ! badSymbolicQ[weightsD] &&
    FreeQ[weightsD, FeynCalc`LorentzIndex | _Real]|>;
require[And @@ Values[projectorDerivationChecks],
  "Eq. (9) projector derivation failed", projectorDerivationChecks];

Print["S08_STAGE=derive xHat invariant map and finite weights"];
twoBodyScalarRecords =
  s03["Kinematics", "TwoBody", "ScalarProductAssignments"];
pDotQRecords = Select[twoBodyScalarRecords,
  MemberQ[{{p, q}, {q, p}},
    {#["Momentum1"], #["Momentum2"]}] &];
require[Length[pDotQRecords] === 1 &&
    First[pDotQRecords]["Dimension"] === D,
  "S03 p.q record is not unique", pDotQRecords];
pDotQInvariant = First[pDotQRecords]["Value"];
xHatSolutions = Quiet@Check[
  Solve[xHat == Q2/(2 pDotQInvariant), xHat], $Failed];
require[ListQ[xHatSolutions] && Length[xHatSolutions] === 1 &&
    Length[First[xHatSolutions]] === 1,
  "Wolfram did not derive one xHat invariant rule", xHatSolutions];
xHatRule = First[First[xHatSolutions]];
xHatMapChecks = <|
  "UniqueSolution" -> Length[xHatSolutions] === 1,
  "DefinitionReconstructs" -> exactZeroQ[
    (xHat - Q2/(2 pDotQInvariant)) /. xHatRule],
  "EliminatesXHat" -> FreeQ[Last[xHatRule], xHat],
  "Exact" -> ! badSymbolicQ[xHatRule]|>;
require[And @@ Values[xHatMapChecks],
  "Eq. (12) xHat map failed", xHatMapChecks];

weightsFiniteXHat = AssociationThread[hatLabels,
  Table[AssociationThread[projectorLabels,
    Table[Cancel[Together[Limit[
      weightsD[hat, label], epsilon -> 0]]],
      {label, projectorLabels}]],
    {hat, hatLabels}]];
weightsFiniteInvariant = Map[
  Map[Cancel[Together[# /. xHatRule]] &],
  weightsFiniteXHat];

polePowers = Keys[s07["PoleLedger", "Residuals",
  First[projectorLabels], First[sectorLabels]]];
genericCoefficients = AssociationThread[projectorLabels,
  Table[AssociationThread[Append[polePowers, 0],
    Table[Unique["genericFiniteProof"],
      {Length[Append[polePowers, 0]]}]],
    {Length[projectorLabels]}]];
genericPrimitiveLaurent = AssociationThread[projectorLabels,
  Table[Total@Table[
    genericCoefficients[label, power] epsilon^power,
    {power, Append[polePowers, 0]}],
    {label, projectorLabels}]];
zeroGenericPoleRules = Flatten@Table[
  genericCoefficients[label, power] -> 0,
  {label, projectorLabels}, {power, polePowers}];
finiteWeightReductionChecks = AssociationThread[hatLabels,
  Table[Module[{fullGenericHat, finiteFromFull, finiteExpected},
    fullGenericHat = Total@Table[
      weightsD[hat, label] genericPrimitiveLaurent[label],
      {label, projectorLabels}];
    finiteFromFull = Quiet@Check[SeriesCoefficient[
      fullGenericHat /. zeroGenericPoleRules,
      {epsilon, 0, 0}], $Failed];
    finiteExpected = Total@Table[
      weightsFiniteXHat[hat, label] genericCoefficients[label, 0],
      {label, projectorLabels}];
    TrueQ[finiteFromFull =!= $Failed &&
      exactZeroQ[finiteFromFull - finiteExpected]]],
    {hat, hatLabels}]];
require[And @@ Values[finiteWeightReductionChecks],
  "finite-weight reduction was not proven",
  finiteWeightReductionChecks];

finiteProjectedActions = s07["FiniteProjectedActions"];
hatActions = AssociationThread[hatLabels,
  Table[AssociationThread[sectorLabels,
    Table[Total@Table[
      weightsFiniteXHat[hat, label]
        finiteProjectedActions[label, sector],
      {label, projectorLabels}],
      {sector, sectorLabels}]],
    {hat, hatLabels}]];

Print["S08_STAGE=derive and test final MS-bar scheme direction"];
sEpsilon = s03["Renormalization", "SEpsilon"];
schemeLinearCoefficient = Quiet@Check[SeriesCoefficient[
  sEpsilon, {FeynCalc`EpsilonUV, 0, 1}], $Failed];
schemeLinearCanonical = Quiet@Check[
  Expand[PowerExpand[schemeLinearCoefficient]], $Failed];
schemeLinearTagged = schemeLinearCanonical /.
  {EulerGamma -> schemeEulerTag,
    HoldPattern[Log[Pi]] -> schemePiLogTag};
schemeGradient = {
  D[schemeLinearTagged, schemeEulerTag],
  D[schemeLinearTagged, schemePiLogTag]};
schemeTangentBasis = Quiet@Check[NullSpace[{schemeGradient}], $Failed];
require[ListQ[schemeTangentBasis] &&
    Length[schemeTangentBasis] === 1 &&
    Length[First[schemeTangentBasis]] === 2,
  "S03 SEpsilon did not define one scheme tangent",
  <|"LinearCoefficient" -> schemeLinearCoefficient,
    "Gradient" -> schemeGradient,
    "NullSpace" -> schemeTangentBasis|>];
schemeTangent = First[schemeTangentBasis];
schemeDerivationChecks = <|
  "LinearCoefficientDerived" ->
    schemeLinearCoefficient =!= $Failed &&
      FreeQ[schemeLinearCoefficient, FeynCalc`EpsilonUV],
  "CanonicalizationClosed" ->
    schemeLinearCanonical =!= $Failed &&
      ! badSymbolicQ[schemeLinearCanonical],
  "GradientNonzero" -> schemeGradient =!= {0, 0},
  "UniqueTangent" -> Length[schemeTangentBasis] === 1,
  "TangentOrthogonal" -> exactZeroQ[
    schemeGradient . schemeTangent]|>;
require[And @@ Values[schemeDerivationChecks],
  "S03 MS-bar scheme-coordinate derivation failed",
  schemeDerivationChecks];

ClearAll[schemeDirection];
schemeDirection[expression_] := Module[{tagged},
  tagged = expression /.
    {EulerGamma -> schemeEulerTag,
      HoldPattern[Log[Pi]] -> schemePiLogTag};
  schemeTangent . {
    D[tagged, schemeEulerTag],
    D[tagged, schemePiLogTag]}
];
projectorSchemeDirections = AssociationThread[projectorLabels,
  Table[AssociationThread[sectorLabels,
    Table[schemeDirection[finiteProjectedActions[label, sector]],
      {sector, sectorLabels}]],
    {label, projectorLabels}]];
schemeHatRecords = AssociationThread[hatLabels,
  Table[AssociationThread[sectorLabels,
    Table[denominatorGroupedZero[
      Table[weightsFiniteXHat[hat, label]
        projectorSchemeDirections[label, sector],
        {label, projectorLabels}],
      hat <> "/" <> sector <> "/MSbar-tangent"],
      {sector, sectorLabels}]],
    {hat, hatLabels}]];
schemeHatProfileGate = And @@ Flatten@Table[
  AssociationQ[schemeHatRecords[hat, sector]] &&
    IntegerQ[schemeHatRecords[hat, sector, "DenominatorCount"]] &&
    IntegerQ[schemeHatRecords[hat, sector, "NonzeroGroupCount"]] &&
    ! badSymbolicQ[
      schemeHatRecords[hat, sector, "ZeroResidual"]] &&
    FreeQ[schemeHatRecords[hat, sector, "ZeroResidual"],
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs],
  {hat, hatLabels}, {sector, sectorLabels}];
schemeHatZeroFindings = AssociationThread[hatLabels,
  Table[AssociationThread[sectorLabels,
    Table[SameQ[
      schemeHatRecords[hat, sector, "ZeroResidual"], 0],
      {sector, sectorLabels}]],
    {hat, hatLabels}]];
require[schemeHatProfileGate,
  "one or more final MS-bar scheme profiles is not exact",
  schemeHatZeroFindings];

finalChecks = <|
  "AcceptedInputHashes" -> And @@ Values[inputIdentityChecks],
  "AcceptedInputSchemas" -> And @@ Values[inputSchemaChecks],
  "Eq9ProjectorDerivation" ->
    And @@ Values[projectorDerivationChecks],
  "Eq12InvariantMap" -> And @@ Values[xHatMapChecks],
  "FiniteWeightReduction" ->
    And @@ Values[finiteWeightReductionChecks],
  "HatActionSchema" ->
    Keys[hatActions] === hatLabels &&
      And @@ (Keys[#] === sectorLabels & /@ Values[hatActions]),
  "MSbarSchemeCoordinateDerived" ->
    And @@ Values[schemeDerivationChecks],
  "MSbarSchemeProfileExact" -> schemeHatProfileGate,
  "FinalExact" -> ! badSymbolicQ[hatActions] &&
    FreeQ[hatActions,
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs]|>;
Print["S08_CHECKS=", InputForm[finalChecks]];
require[And @@ Values[finalChecks],
  "one or more S08 final gates failed", finalChecks];

result = <|
  "Stage" -> "HqqV2S08-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|
    "PaperSHA256" -> expectedPaperHash,
    "S03ResultSHA256" -> expectedS03Hash,
    "S07ResultSHA256" -> expectedS07Hash|>,
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "ParallelPolicy" ->
      "serial FeynCalc inversion and denominator-grouped exact checks on six immutable actions"|>,
  "ProjectorDerivation" -> <|
    "TensorBasis" -> <|"F1Hat" -> tensorBasis1,
      "F2Hat" -> tensorBasis2|>,
    "PrimitiveContractions" -> primitiveContractions,
    "Solutions" -> structureSolutions,
    "WeightsD" -> weightsD,
    "WeightsFiniteXHat" -> weightsFiniteXHat,
    "WeightsFiniteInvariant" -> weightsFiniteInvariant,
    "Checks" -> projectorDerivationChecks|>,
  "Kinematics" -> <|
    "PDotQFromS03" -> pDotQInvariant,
    "XHatRule" -> xHatRule,
    "Checks" -> xHatMapChecks|>,
  "FiniteWeightReduction" -> <|
    "PolePowers" -> polePowers,
    "Checks" -> finiteWeightReductionChecks|>,
  "MSbarSchemeValidation" -> <|
    "SEpsilon" -> sEpsilon,
    "LinearCoefficient" -> schemeLinearCoefficient,
    "CanonicalLinearCoefficient" -> schemeLinearCanonical,
    "Gradient" -> schemeGradient,
    "OrthogonalTangent" -> schemeTangent,
    "HatRecords" -> schemeHatRecords,
    "OrthogonalResidualZeroQ" -> schemeHatZeroFindings,
    "Interpretation" ->
      "exact finite normalization profile retained; no extra cancellation imposed beyond accepted MSbar inputs",
    "Checks" -> schemeDerivationChecks|>,
  "F1Hat" -> hatActions["F1Hat"],
  "F2Hat" -> hatActions["F2Hat"],
  "Checks" -> finalChecks|>;

Print["S08_STAGE=atomic final-hat publication"];
atomicPut[result, resultPath];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, result] &&
    AssociationQ[reloaded["Checks"]] &&
    And @@ Values[reloaded["Checks"]],
  "same-kernel S08 result reload failed"];
Print["S08_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S08_FHAT_HASHES=", InputForm[<|
  "F1Hat" -> expressionHash[result["F1Hat"]],
  "F2Hat" -> expressionHash[result["F2Hat"]]|>]];
Print["S08_RESULT_READY"];
Quit[0];

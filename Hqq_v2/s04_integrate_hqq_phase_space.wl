(* Hqq_v2 S04: exact phase space and Appendix-B angular masters. *)

$HistoryLength = 0;
$LoadAddOns = {};
Needs["FeynCalc`"];

ClearAll[
  fail, require, exactZeroQ, uniqueRule, atomicPut, eliminateTo,
  massShellRule, sp3, mdot, atomGeometry, deriveThreeRelation,
  associationScale, associationMerge, decomposePowers,
  extractAtomKernel, atomType, terminalFamily, deriveFamilySpec,
  rowsFromExpression, rowsValue, mapToFamilies, canonicalReal,
  reduceReal, processRows, collectItems, angularMasterKey,
  angularMasterRecord, phaseMasterRows, reductionMetadata
];

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
sourcePath = ExpandFileName[$InputFileName];
stageDirectory = DirectoryName[sourcePath];
s03SourcePath = FileNameJoin[{stageDirectory,
    "s03_finalize_uv_recovery.wl"}];
s03ResultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s04_result.wl"}];
temporaryResultPath = resultPath <> ".tmp";

expectedS03SourceHash =
  "379e463f748adae363c693cd39afd4a8dc5420e3a096e98d60c73d9a9afeca0b";
expectedS03ResultHash =
  "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4";

fail[message_String, detail_: Null] := (
  Print["S04_FAILURE: ", message];
  If[detail =!= Null, Print["S04_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Cancel[Together[expression]] === 0];
uniqueRule[equation_, variable_, label_String] := Module[{solutions},
  solutions = Quiet@Check[Solve[equation, variable], $Failed];
  require[ListQ[solutions] && Length[solutions] === 1 &&
    Length[First[solutions]] === 1,
    "defining relation is not uniquely solvable: " <> label, solutions];
  First[First[solutions]]
];
atomicPut[expression_, path_String] := Module[{},
  If[FileExistsQ[temporaryResultPath], DeleteFile[temporaryResultPath]];
  Put[expression, temporaryResultPath];
  RenameFile[temporaryResultPath, path, OverwriteTarget -> True]
];

probeMode = TrueQ[Environment["HQQV2_S04_PROBE"] === "1"];

require[FileExistsQ[s03SourcePath] && FileExistsQ[s03ResultPath],
  "accepted S03 inputs are missing"];
require[FileHash[s03SourcePath, "SHA256", "HexString"] ===
  expectedS03SourceHash, "accepted S03 source hash mismatch"];
require[FileHash[s03ResultPath, "SHA256", "HexString"] ===
  expectedS03ResultHash, "accepted S03 result hash mismatch"];

s03 = Quiet@Check[Get[s03ResultPath], $Failed];
require[AssociationQ[s03] && s03["Stage"] === "HqqV2S03-v1" &&
  s03["ScopeTag"] === scopeTag,
  "accepted S03 result failed its stage/scope schema"];
require[s03["Source", "SHA256"] === expectedS03SourceHash,
  "S03 result does not bind its accepted producing source"];

projectorLabels = Keys[s03["Projected", "Born"]];
realProjectedRows = s03["Projected", "RealRows"];
realFamilyLabels = Keys[realProjectedRows[First[projectorLabels]]];
threeKinematics = s03["Kinematics", "ThreeBody"];
threeMassShells = threeKinematics["MassShells"];
threeAssignments = threeKinematics["ScalarProductAssignments"];
conservationEquations = threeKinematics["ConservationEquations"];

require[projectorLabels === {"Pg", "PPP"},
  "unexpected projector ordering", projectorLabels];
require[realFamilyLabels === {
    "Hqq;gg", "Hqq;q_qbar_sameFlavor", "Hqq;qPrime_qbarPrime"},
  "unexpected real-family ordering", realFamilyLabels];
require[And @@ Map[Keys[realProjectedRows[#]] === realFamilyLabels &,
    projectorLabels],
  "real-family schemas differ between projectors"];

(* Exact Appendix-D relations from the accepted conservation system. *)
invariantSymbols = {Q2, sHat, t1, t2, t3, u1, u2, u3,
  s12, s13, s23};
eliminateTo[kept_List] := FullSimplify@Eliminate[
  conservationEquations, Complement[invariantSymbols, kept]];

uPairEquation = eliminateTo[{u2, u3, t1, s23}];
tPairEquation = eliminateTo[{t2, t3, u1, s23, Q2}];
sPairEquation = eliminateTo[{s12, s13, sHat, s23}];
s12BaseEquation = eliminateTo[{s12, t2, u2, Q2, s23}];
s13BaseEquation = eliminateTo[{s13, sHat, t2, u2, Q2}];
s23Equation = eliminateTo[{Q2, sHat, t1, u1, s23}];

u3Rule = uniqueRule[uPairEquation, u3, "u-type 2AR"];
t3Rule = uniqueRule[tPairEquation, t3, "t-type 2AR"];
s13PairRule = uniqueRule[sPairEquation, s13, "s-type 2AR"];
s12BaseRule = uniqueRule[s12BaseEquation, s12,
  "s12 three-ADMV base rule"];
s13BaseRule = uniqueRule[s13BaseEquation, s13,
  "s13 three-ADMV base rule"];
sHatInS23Rule = uniqueRule[s23Equation, sHat,
  "three-body sHat conservation"];
u1InS23Rule = uniqueRule[s23Equation, u1,
  "three-body u1 conservation"];

tTotal = Factor[t2 + (t3 /. t3Rule)];
uTotal = Factor[u2 + (u3 /. u3Rule)];
sTotal = Factor[(s12 + (s13 /. s13PairRule)) /.
  sHatInS23Rule];
s13CanonicalRule = s13 -> Factor[(s13 /. s13BaseRule) /.
  sHatInS23Rule];
baseRules = {t3Rule, u3Rule, s12BaseRule, s13CanonicalRule};
conservationChecks = <|
  "TType2AR" -> exactZeroQ[(t3 /. t3Rule) -
    (u1 - Q2 - s23 - t2)],
  "UType2AR" -> exactZeroQ[(u3 /. u3Rule) -
    (t1 - s23 - u2)],
  "SType2AR" -> exactZeroQ[(s13 /. s13PairRule) -
    (sHat - s23 - s12)],
  "S12Base" -> exactZeroQ[(s12 /. s12BaseRule) -
    (-Q2 - s23 - t2 - u2)],
  "S13Base" -> exactZeroQ[(s13 /. s13BaseRule) -
    (Q2 + sHat + t2 + u2)],
  "S23Conservation" -> exactZeroQ[
    (sHat /. sHatInS23Rule) - (s23 - Q2 - t1 - u1)]|>;
require[And @@ Values[conservationChecks],
  "derived conservation relations failed", conservationChecks];

(* Eqs. (28)--(32) and (40), derived from Eqs. (25)--(27). *)
sHatFraction = Q2 (1/xHat - 1);
t1Fraction = -Q2 + Q2 zHat - k1T2/zHat;
u1Fraction = -Q2 zHat/xHat;
fractionRules = {sHat -> sHatFraction, t1 -> t1Fraction,
  u1 -> u1Fraction};
s23FractionRule = uniqueRule[s23Equation /. fractionRules, s23,
  "s23 fraction map"];
s23Fraction = Factor[s23 /. s23FractionRule];
zetaRule = uniqueRule[s23Equation /. fractionRules /.
  {zHat -> z/zeta, k1T2 -> PHT2/zeta^2}, zeta,
  "zeta to s23 map"];
zetaMap = Factor[zeta /. zetaRule];
zetaJacobian = Factor[D[zetaMap, s23]];
xiLowerRule = uniqueRule[
  (zetaMap /. {s23 -> 0, xHat -> x/xi}) == 1, xi,
  "lower xi boundary"];
xiLower = Factor[xi /. xiLowerRule];
s23UpperRule = uniqueRule[zetaMap == 1, s23,
  "upper s23 boundary"];
s23Upper = Factor[s23 /. s23UpperRule];
dtduJacobianSigned = Factor[Det[{
  {D[t1Fraction, zHat], D[t1Fraction, k1T2]},
  {D[u1Fraction, zHat], D[u1Fraction, k1T2]}}]];
dtduJacobianPhysical = Factor[-dtduJacobianSigned];

variableChecks = <|
  "Eq30" -> exactZeroQ[zetaMap -
    (xHat PHT2 + z^2 Q2 (1 - xHat))/
      (z (Q2 (1 - xHat) - s23 xHat))],
  "Eq29Jacobian" -> exactZeroQ[zetaJacobian -
    (xHat^2 PHT2 + xHat z^2 Q2 (1 - xHat))/
      (z (Q2 (1 - xHat) - s23 xHat)^2)],
  "Eq31" -> exactZeroQ[xiLower -
    (x + x PHT2/(z (1 - z) Q2))],
  "Eq32" -> exactZeroQ[s23Upper -
    (Q2 (1/xHat - 1) (1 - z) - PHT2/z)],
  "Eq40" -> exactZeroQ[s23Fraction -
    (Q2 (zHat (1 - xHat) - zHat^2 (1 - xHat)) -
      xHat k1T2)/(xHat zHat)],
  "Eq28" -> exactZeroQ[dtduJacobianPhysical - Q2/(xHat zHat)]|>;
require[And @@ Values[variableChecks],
  "fraction map, bound, or Jacobian gate failed", variableChecks];

(* Eq. (35), derived from the two-body invariant definitions. *)
twoDefinitionEquations = {
  pp == 0, qq == -Q2, k1k1 == 0,
  sHat == pp + qq + 2 pq,
  tHat == qq + k1k1 - 2 qk1,
  uHat == pp + k1k1 - 2 pk1};
twoScalarRules = First@Solve[twoDefinitionEquations,
  {pp, qq, k1k1, pq, qk1, pk1}];
twoGram = {{pp, pq, pk1}, {pq, qq, qk1},
  {pk1, qk1, k1k1}} /. twoScalarRules;
twoRecoilVirtuality = Factor[{1, 1, -1} . twoGram . {1, 1, -1}];
twoFractionRules = {sHat -> sHatFraction, tHat -> t1Fraction,
  uHat -> u1Fraction};
twoRecoilFractional = Factor[twoRecoilVirtuality /. twoFractionRules];
twoDeltaScale = Q2/xHat;
twoDeltaConstraint = Factor[twoRecoilFractional/twoDeltaScale];
twoBodyChecks = <|
  "InvariantRecoil" -> exactZeroQ[twoRecoilVirtuality -
    (Q2 + sHat + tHat + uHat)],
  "FractionalConstraint" -> exactZeroQ[twoDeltaConstraint -
    ((1 - xHat) (1 - zHat) - xHat k1T2/(zHat Q2))],
  "DeltaScale" -> exactZeroQ[twoRecoilFractional -
    twoDeltaScale twoDeltaConstraint]|>;
require[And @@ Values[twoBodyChecks],
  "two-body phase-space gate failed", twoBodyChecks];

hardPartNormalization = (2 Pi)^(-4);
twoMeasureInvariant = 2 Pi DiracDelta[twoRecoilVirtuality];
twoMeasureFractional = (2 Pi/twoDeltaScale)
  DiracDelta[twoDeltaConstraint];
threeAngularPrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon) Gamma[1 - epsilon]/
    ((2 Pi)^(2 - 2 epsilon) Gamma[1 - 2 epsilon]);
eq38Prefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon) Gamma[1 - epsilon]/
    ((2 Pi)^(6 - 2 epsilon) Gamma[1 - 2 epsilon]);
measureChecks = <|
  "Eq19AbsentUpstream" ->
    FreeQ[{s03["Projected", "Born"], realProjectedRows}, Pi],
  "Eq38" -> exactZeroQ[hardPartNormalization threeAngularPrefactor -
    eq38Prefactor]|>;
require[And @@ Values[measureChecks],
  "hard-part or three-body measure gate failed", measureChecks];

massShellRule[record_List] := With[
  {momentum = record[[1]], value = record[[2]]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum, D],
    FeynCalc`Momentum[momentum, D]]] :> value];
twoMassShellRules = massShellRule /@
  s03["Kinematics", "TwoBody", "MassShells"];
threeMassShellRules = massShellRule /@ threeMassShells;
bornCanonical = Map[
  Cancel[Together[# /. twoMassShellRules /. D -> 4 - 2 epsilon]] &,
  s03["Projected", "Born"]];
require[FreeQ[bornCanonical, FeynCalc`Pair | _Real | Indeterminate |
    ComplexInfinity | DirectedInfinity],
  "canonical Born boundary is unresolved or inexact"];
bornPhaseInvariant = Map[
  hardPartNormalization twoMeasureInvariant # &, bornCanonical];
bornPhaseFractional = Map[
  hardPartNormalization twoMeasureFractional
    (# /. twoFractionRules) &, bornCanonical];

(* Frame 1 and all six angle-dependent atoms. *)
massValues = Association[Rule @@@ threeMassShells];
sp3[a_, a_] := Module[{value = Lookup[massValues, a,
    Missing["NotFound"]]},
  require[! MissingQ[value], "missing three-body mass shell", a];
  value];
sp3[a_, b_] := Module[{record},
  record = SelectFirst[threeAssignments,
    Function[item,
      (item["Momentum1"] === a && item["Momentum2"] === b) ||
      (item["Momentum1"] === b && item["Momentum2"] === a)],
    Missing["NotFound"]];
  require[! MissingQ[record], "missing accepted scalar product", {a, b}];
  record["Value"]];
mdot[left_List, right_List] := Expand[
  left[[1]] right[[1]] - Rest[left] . Rest[right]];

pDotR = sp3[p, p] + sp3[p, q] - sp3[p, k1];
k1DotR = sp3[k1, p] + sp3[k1, q] - sp3[k1, k1];
p0Frame = Factor[(pDotR /. sHatInS23Rule)/Sqrt[s23]];
k10Frame = Factor[k1DotR/Sqrt[s23]];
cosAlphaRule = uniqueRule[
  sp3[p, k1] == p0Frame k10Frame (1 - cosAlpha1),
  cosAlpha1, "frame-1 cos(alpha1)"];
cosAlphaValue = Factor[cosAlpha1 /. cosAlphaRule];
sinAlphaValue = Sqrt[Factor[1 - cosAlphaValue^2]];

rFrame = {Sqrt[s23], 0, 0};
pFrame = p0Frame {1, sinAlphaValue, cosAlphaValue};
k1Frame = k10Frame {1, 0, 1};
qFrame = Expand[rFrame - pFrame + k1Frame];
k2Frame = Sqrt[s23]/2 {1, sinBetaCosBeta2, cosBeta1};
k3Frame = Sqrt[s23]/2 {1, -sinBetaCosBeta2, -cosBeta1};
atomExpressions = Map[Factor, <|
  "t2" -> -Q2 - 2 mdot[qFrame, k2Frame],
  "t3" -> -Q2 - 2 mdot[qFrame, k3Frame],
  "u2" -> -2 mdot[pFrame, k2Frame],
  "u3" -> -2 mdot[pFrame, k3Frame],
  "s12" -> 2 mdot[k1Frame, k2Frame],
  "s13" -> 2 mdot[k1Frame, k3Frame]|>];

atomGeometry[expression_] := Module[
  {constant, coefficients, spatialSquare, caseResidual, class,
   scale, dParameter, direction, normResidual},
  constant = Factor[expression /.
    {sinBetaCosBeta2 -> 0, cosBeta1 -> 0}];
  coefficients = Factor /@ {
    Coefficient[expression, sinBetaCosBeta2],
    Coefficient[expression, cosBeta1]};
  spatialSquare = Factor[coefficients . coefficients];
  caseResidual = Factor[constant^2 - spatialSquare];
  If[exactZeroQ[caseResidual],
    class = "Lightlike";
    scale = constant;
    dParameter = 1,
    class = "Massive";
    scale = Sqrt[spatialSquare];
    dParameter = Factor[constant/scale]
  ];
  direction = Factor /@ (-coefficients/scale);
  normResidual = Factor[direction . direction - 1];
  <|"Class" -> class, "Scale" -> scale,
    "DParameter" -> dParameter, "Direction" -> direction,
    "CaseResidual" -> caseResidual,
    "DirectionNormResidual" -> normResidual|>];
atomGeometries = Map[atomGeometry, atomExpressions];
geometryChecks = <|
  "FramePhotonMass" -> exactZeroQ[mdot[qFrame, qFrame] + Q2],
  "TComplement" -> exactZeroQ[atomExpressions["t2"] +
    atomExpressions["t3"] - tTotal],
  "UComplement" -> exactZeroQ[atomExpressions["u2"] +
    atomExpressions["u3"] - uTotal],
  "SComplement" -> exactZeroQ[atomExpressions["s12"] +
    atomExpressions["s13"] - sTotal],
  "TAtomsMassive" -> And @@ Map[
    # ["Class"] === "Massive" &, atomGeometries /@ {"t2", "t3"}],
  "USAtomsLightlike" -> And @@ Map[
    # ["Class"] === "Lightlike" &,
    atomGeometries /@ {"u2", "u3", "s12", "s13"}],
  "AllDirectionsUnit" -> And @@ Map[
    exactZeroQ[# ["DirectionNormResidual"]] &,
    Values[atomGeometries]]|>;
require[And @@ Values[geometryChecks],
  "six-atom frame geometry failed", geometryChecks];

(* Complete six-atom Appendix-D reducer. *)
atomNames = {"t2", "t3", "u2", "u3", "s12", "s13"};
atomValues = Map[Factor, <|
  "t2" -> t2,
  "t3" -> (t3 /. t3Rule),
  "u2" -> u2,
  "u3" -> (u3 /. u3Rule),
  "s12" -> (s12 /. s12BaseRule),
  "s13" -> (s13 /. s13CanonicalRule)|>];
baseVariablesPattern = t2 | u2;

threeLabelSets = Tuples[{
  {"t2", "t3"}, {"u2", "u3"}, {"s12", "s13"}}];
deriveThreeRelation[labels_List] := Module[
  {values, coefficientMatrix, nullVectors, coefficients, resultant},
  values = Lookup[atomValues, labels];
  coefficientMatrix = {
    Coefficient[#, t2] & /@ values,
    Coefficient[#, u2] & /@ values};
  nullVectors = NullSpace[coefficientMatrix];
  require[Length[nullVectors] === 1,
    "three-direction relation is not unique", labels];
  coefficients = Together /@ First[nullVectors];
  resultant = Factor[coefficients . values];
  require[FreeQ[resultant, baseVariablesPattern] &&
    ! TrueQ[resultant === 0],
    "three-direction resultant is invalid", {labels, resultant}];
  <|"Labels" -> labels, "Coefficients" -> coefficients,
    "Resultant" -> resultant,
    "Residual" -> Factor[coefficients . values - resultant]|>];
threeRelationLedger = AssociationThread[
  (HqqV2ThreeRelationKey @@ # &) /@ threeLabelSets,
  deriveThreeRelation /@ threeLabelSets];
threeRelationChecks = Map[
  exactZeroQ[# ["Residual"]] &, threeRelationLedger];
require[And @@ Values[threeRelationChecks],
  "a derived three-direction identity failed", threeRelationChecks];

associationScale[association_Association, factor_] := Map[factor # &,
  association];
associationMerge[pieces__Association] := Select[
  Merge[{pieces}, Cancel[Together[Total[#]]] &],
  ! TrueQ[# === 0] &];

Clear[decompositionCache];
decomposePowers[input_List] := decompositionCache[input] = Module[{},
  Clear[decompose];
  decompose[powers_List] := decompose[powers] = Module[
    {lowered, firstPiece, secondPiece, directionCounts, chosen,
     labels, relation, pieces},
    require[Min[powers] >= 0,
      "negative affine denominator power", powers];
    If[powers[[1]] > 0 && powers[[2]] > 0,
      lowered = ReplacePart[powers, 1 -> powers[[1]] - 1];
      firstPiece = associationScale[decompose[lowered], 1/tTotal];
      lowered = ReplacePart[powers, 2 -> powers[[2]] - 1];
      secondPiece = associationScale[decompose[lowered], 1/tTotal];
      Return[associationMerge[firstPiece, secondPiece]]];
    If[powers[[3]] > 0 && powers[[4]] > 0,
      lowered = ReplacePart[powers, 3 -> powers[[3]] - 1];
      firstPiece = associationScale[decompose[lowered], 1/uTotal];
      lowered = ReplacePart[powers, 4 -> powers[[4]] - 1];
      secondPiece = associationScale[decompose[lowered], 1/uTotal];
      Return[associationMerge[firstPiece, secondPiece]]];
    If[powers[[5]] > 0 && powers[[6]] > 0,
      lowered = ReplacePart[powers, 5 -> powers[[5]] - 1];
      firstPiece = associationScale[decompose[lowered], 1/sTotal];
      lowered = ReplacePart[powers, 6 -> powers[[6]] - 1];
      secondPiece = associationScale[decompose[lowered], 1/sTotal];
      Return[associationMerge[firstPiece, secondPiece]]];
    directionCounts = {
      Total[powers[[{1, 2}]]], Total[powers[[{3, 4}]]],
      Total[powers[[{5, 6}]]]};
    If[Count[directionCounts, _?(# > 0 &)] <= 2,
      Return[<|HqqV2ReductionKey @@ powers -> 1|>]];
    chosen = {If[powers[[1]] > 0, 1, 2],
      If[powers[[3]] > 0, 3, 4],
      If[powers[[5]] > 0, 5, 6]};
    labels = atomNames[[chosen]];
    relation = threeRelationLedger[HqqV2ThreeRelationKey @@ labels];
    pieces = MapThread[Function[{position, coefficient},
      lowered = ReplacePart[powers,
        position -> powers[[position]] - 1];
      associationScale[decompose[lowered],
        coefficient/relation["Resultant"]]],
      {chosen, relation["Coefficients"]}];
    Apply[associationMerge, pieces]
  ];
  decompose[input]];

extractAtomKernel[expression_] := Module[
  {compact, denominator, factors, powers, unmatched, factor,
   exponent, match, ratio, atomProduct, prefactor},
  compact = Cancel[Together[expression]];
  denominator = Factor[Denominator[compact]];
  factors = Rest[FactorList[denominator]];
  powers = AssociationThread[atomNames, ConstantArray[0, 6]];
  unmatched = {};
  Do[
    factor = factorRow[[1]];
    exponent = factorRow[[2]];
    match = SelectFirst[atomNames, Function[name,
      ratio = Cancel[factor/atomValues[name]];
      FreeQ[ratio, baseVariablesPattern] && ratio =!= 0],
      Missing["NotFound"]];
    If[MissingQ[match], AppendTo[unmatched, {factor, exponent}],
      powers[match] += exponent],
    {factorRow, factors}];
  atomProduct = Times @@ Map[atomValues[#]^powers[#] &, atomNames];
  prefactor = Cancel[compact atomProduct];
  require[FreeQ[Denominator[Together[prefactor]],
      baseVariablesPattern],
    "unrecognized angle-dependent denominator survived atom extraction",
    <|"Denominator" -> denominator, "Unmatched" -> unmatched|>];
  <|"Expression" -> compact, "Powers" -> Lookup[powers, atomNames],
    "Prefactor" -> prefactor, "UnmatchedFactors" -> unmatched|>];

atomType[name_String] := Which[
  MemberQ[{"t2", "t3"}, name], "t",
  MemberQ[{"u2", "u3"}, name], "u",
  MemberQ[{"s12", "s13"}, name], "s",
  True, fail["unknown ADMV atom", name]];
typeOrder = <|"t" -> 1, "u" -> 2, "s" -> 3|>;
familyPairList = Join[
  Flatten[Table[{ta, ua}, {ta, {"t2", "t3"}},
    {ua, {"u2", "u3"}}], 1],
  Flatten[Table[{ta, sa}, {ta, {"t2", "t3"}},
    {sa, {"s12", "s13"}}], 1],
  Flatten[Table[{ua, sa}, {ua, {"u2", "u3"}},
    {sa, {"s12", "s13"}}], 1]];
familyAtomPairs = Association[
  (StringRiffle[#, "_"] -> # &) /@ familyPairList];

terminalFamily[key_HqqV2ReductionKey] := Module[
  {powers, support, ordered, family},
  powers = List @@ key;
  support = Pick[atomNames, powers, _?(# > 0 &)];
  ordered = Switch[Length[support],
    0, {"u2", "s12"},
    1, Switch[atomType[First[support]],
      "t", {First[support], "u2"},
      "u", {First[support], "s12"},
      "s", {"u2", First[support]}],
    2, SortBy[support, typeOrder[atomType[#]] &],
    _, fail["terminal support has more than two types", support]];
  require[Length[DeleteDuplicates[atomType /@ ordered]] === 2,
    "terminal family repeats an ADMV type", ordered];
  family = StringRiffle[ordered, "_"];
  require[KeyExistsQ[familyAtomPairs, family],
    "terminal family is unsupported", family];
  family];

deriveFamilySpec[atoms_List] := Module[{solutions},
  solutions = Solve[{
    atomValues[atoms[[1]]] == hqqX,
    atomValues[atoms[[2]]] == hqqY}, {t2, u2}];
  require[Length[solutions] === 1,
    "family variables do not uniquely determine the angular base", atoms];
  <|"Substitutions" -> First[solutions],
    "Inverse" -> {hqqX -> atomValues[atoms[[1]]],
      hqqY -> atomValues[atoms[[2]]]}|>];
familySpecifications = AssociationMap[
  deriveFamilySpec[familyAtomPairs[#]] &, Keys[familyAtomPairs]];

rowsFromExpression[expression_, family_String] := Module[
  {specification, expanded, terms, rows, rational, powerX,
   powerY, coefficient, grouped},
  If[TrueQ[expression === 0], Return[{}]];
  specification = familySpecifications[family];
  expanded = Expand[Cancel[Together[
    expression /. specification["Substitutions"]]]];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  rows = Map[Function[term,
    rational = Together[term];
    powerX = Exponent[Numerator[rational], hqqX] -
      Exponent[Denominator[rational], hqqX];
    powerY = Exponent[Numerator[rational], hqqY] -
      Exponent[Denominator[rational], hqqY];
    coefficient = Cancel[term/(hqqX^powerX hqqY^powerY)];
    require[FreeQ[coefficient, hqqX | hqqY],
      "non-Laurent family coefficient",
      {family, powerX, powerY, coefficient}];
    {powerX, powerY, coefficient}], terms];
  grouped = Merge[(#[[{1, 2}]] -> #[[3]] &) /@ rows,
    Cancel[Together[Total[#]]] &];
  SortBy[({#[[1, 1]], #[[1, 2]], #[[2]]} &) /@
    Select[Normal[grouped], ! TrueQ[Last[#] === 0] &],
    Take[#, 2] &]];

rowsValue[rows_List, family_String] :=
  Total[(#[[3]] hqqX^#[[1]] hqqY^#[[2]]) & /@ rows] /.
    familySpecifications[family, "Inverse"];

mapToFamilies[expression_] := Module[
  {kernel, decomposition, contributions, originalResidual,
   familyExpressions, familyRows, rowResiduals},
  kernel = extractAtomKernel[expression];
  decomposition = decomposePowers[kernel["Powers"]];
  contributions = KeyValueMap[Function[{key, coefficient},
    Module[{powers = List @@ key, term},
      term = Cancel[kernel["Prefactor"] coefficient/
        Times @@ MapThread[Power,
          {Lookup[atomValues, atomNames], powers}]];
      <|"Family" -> terminalFamily[key], "Expression" -> term|>]],
    decomposition];
  originalResidual = Cancel[Together[
    Total[Lookup[contributions, "Expression"]] - kernel["Expression"]]];
  require[TrueQ[originalResidual === 0],
    "six-atom partial fractions failed reconstruction", originalResidual];
  familyExpressions = AssociationMap[Function[family,
    Cancel[Together[Total[Lookup[
      Select[contributions, # ["Family"] === family &],
      "Expression", {}]]]]], Keys[familyAtomPairs]];
  familyRows = AssociationMap[
    rowsFromExpression[familyExpressions[#], #] &, Keys[familyAtomPairs]];
  rowResiduals = AssociationMap[
    Cancel[Together[rowsValue[familyRows[#], #] -
      familyExpressions[#]]] &, Keys[familyAtomPairs]];
  require[And @@ Map[TrueQ[# === 0] &, Values[rowResiduals]],
    "family Laurent rows failed reconstruction", rowResiduals];
  <|"Rows" -> familyRows, "AtomPowers" -> kernel["Powers"],
    "UnmatchedDenominatorFactors" -> kernel["UnmatchedFactors"],
    "TerminalCount" -> Length[decomposition],
    "Checks" -> <|"PartialFractionReconstructs" -> True,
      "FamilyRowsReconstruct" -> True|>|>];

canonicalReal[expression_] := Module[{answer},
  answer = expression /. threeMassShellRules /. D -> 4 - 2 epsilon;
  require[FreeQ[answer, FeynCalc`Pair],
    "canonical real row retains a Pair head"];
  answer = answer /. baseRules /. sHatInS23Rule;
  require[FreeQ[answer, t3 | u3 | s12 | s13 | sHat],
    "canonical real row retains a non-base ADMV"];
  answer];
reduceReal[expression_] := Module[{canonical, mapped},
  canonical = canonicalReal[expression];
  require[FreeQ[canonical, _Real | Indeterminate | ComplexInfinity |
    DirectedInfinity], "canonical real row is inexact or singular"];
  mapped = mapToFamilies[canonical];
  Append[mapped, "CanonicalChecks" -> <|
    "PairFree" -> True, "SixAtomBase" -> True, "Exact" -> True|>]];
processRows[input_Association] := AssociationMap[Function[projector,
  AssociationMap[Function[family,
    MapIndexed[Function[{expression, index},
      Print["S04_REDUCE_ROW=", projector, "/", family, "/",
        First[index], "/", Length[input[projector, family]]];
      reduceReal[expression]], input[projector, family]]],
    Keys[input[projector]]]], Keys[input]];
collectItems[reduction_Association] := Module[{items = {}},
  Do[items = Join[items, reduction[projector, family]],
    {projector, Keys[reduction]},
    {family, Keys[reduction[projector]]}];
  items];

(* Exact Appendix-B representations. *)
angularMasterKey[family_String, powerX_Integer, powerY_Integer] :=
  HqqV2AngularMasterKey[family, powerX, powerY];
angularMasterRecord[key_HqqV2AngularMasterKey] := Module[
  {family, powerX, powerY, atoms, geometryX, geometryY,
   scaleX, scaleY, directionX, directionY, cosine, dX, dY,
   j, l, n, normalized, representation, definingIntegral,
   exactRepresentation, w},
  {family, powerX, powerY} = List @@ key;
  atoms = familyAtomPairs[family];
  geometryX = atomGeometries[atoms[[1]]];
  geometryY = atomGeometries[atoms[[2]]];
  scaleX = geometryX["Scale"];
  scaleY = geometryY["Scale"];
  directionX = geometryX["Direction"];
  directionY = geometryY["Direction"];
  cosine = Factor[directionX . directionY];
  dX = geometryX["DParameter"];
  dY = geometryY["DParameter"];
  j = -powerX;
  l = -powerY;
  n = 4 - 2 epsilon;
  Which[
    geometryX["Class"] === "Lightlike" &&
      geometryY["Class"] === "Lightlike",
    representation = "Paper Eq. (B18), case (1)";
    normalized = 2 Pi Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2 *
      2^(-j - l) Beta[1 - epsilon - j, 1 - epsilon - l] *
      Hypergeometric2F1[j, l, 1 - epsilon, (1 + cosine)/2],
    geometryX["Class"] === "Massive" &&
      geometryY["Class"] === "Lightlike",
    representation = "Paper Eqs. (B19)-(B20), case (2)";
    w = (1 + cosine) omegaB/(dX - 1 + 2 omegaB);
    normalized = (-1)^(l + 1) 2^(1 - l - j) Pi *
      Gamma[n - 3] Gamma[2 + l - n/2] Gamma[n/2 - l - 1]/
      (Gamma[n/2 - 1]^2 Gamma[n/2 - 2] Gamma[3 - n/2]) *
      Inactive[Integrate][
        omegaB^(n/2 - 2) (1 - omegaB)^(n/2 - l - 2)/
          (omegaB + (dX - 1)/2)^j *
          Hypergeometric2F1[j, l, n/2 - 1, w],
        {omegaB, 0, 1}],
    True,
    fail["angular family is neither case (1) nor case (2)",
      {family, geometryX["Class"], geometryY["Class"]}]
  ];
  exactRepresentation = scaleX^powerX scaleY^powerY normalized;
  definingIntegral = Inactive[Integrate][
    Sin[beta1]^(1 - 2 epsilon) Sin[beta2]^(-2 epsilon)/
      ((scaleX (dX - Cos[beta1]))^j *
       (scaleY (dY - cosine Cos[beta1] -
         Sqrt[1 - cosine^2] Sin[beta1] Cos[beta2]))^l),
    {beta1, 0, Pi}, {beta2, 0, Pi}];
  <|"Family" -> family, "Powers" -> {powerX, powerY},
    "DenominatorPowers" -> {j, l}, "Atoms" -> atoms,
    "Classes" -> {geometryX["Class"], geometryY["Class"]},
    "Scales" -> {scaleX, scaleY}, "DParameters" -> {dX, dY},
    "CosChi" -> cosine, "DefiningIntegral" -> definingIntegral,
    "ExactRepresentation" -> exactRepresentation,
    "Representation" -> representation|>];

phaseMasterRows[item_Association, ledger_Association] := Module[
  {rows = {}, key},
  Do[Do[
    key = angularMasterKey[family, row[[1]], row[[2]]];
    require[KeyExistsQ[ledger, key], "missing angular master", key];
    AppendTo[rows, {key,
      hardPartNormalization threeAngularPrefactor row[[3]]}],
    {row, item["Rows", family]}],
    {family, Keys[item["Rows"]]}];
  rows];
reductionMetadata[item_Association] := <|
  "AtomPowers" -> item["AtomPowers"],
  "UnmatchedDenominatorFactors" -> item["UnmatchedDenominatorFactors"],
  "TerminalCount" -> item["TerminalCount"],
  "Checks" -> Join[item["Checks"], item["CanonicalChecks"]]|>;

inputRows = If[probeMode,
  AssociationMap[Function[projector,
    AssociationMap[{First[realProjectedRows[projector, #]]} &,
      realFamilyLabels]], projectorLabels],
  realProjectedRows];
Print["S04_MODE=", If[probeMode, "representative-probe", "production"]];
realReduction = processRows[inputRows];
items = collectItems[realReduction];
require[And @@ Map[And @@ Values[# ["Checks"]] &&
    And @@ Values[# ["CanonicalChecks"]] &, items],
  "one or more row-reduction gates failed"];

distinctMasterKeys = {};
Do[Do[Do[AppendTo[distinctMasterKeys,
  angularMasterKey[family, row[[1]], row[[2]]]],
  {row, item["Rows", family]}], {family, Keys[item["Rows"]]}],
  {item, items}];
distinctMasterKeys = DeleteDuplicates[distinctMasterKeys];
angularMasterLedger = AssociationMap[angularMasterRecord,
  distinctMasterKeys];
representations = Lookup[Values[angularMasterLedger], "Representation"];
masterChecks = <|
  "Nonempty" -> Length[angularMasterLedger] > 0,
  "B18Present" -> MemberQ[representations,
    "Paper Eq. (B18), case (1)"],
  "B19Present" -> MemberQ[representations,
    "Paper Eqs. (B19)-(B20), case (2)"],
  "Exact" -> FreeQ[
    Lookup[Values[angularMasterLedger], "ExactRepresentation"],
    _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
  "NoEndpointSeries" -> FreeQ[angularMasterLedger,
    SeriesData | Inactive[Series]]|>;
require[And @@ Values[masterChecks],
  "Appendix-B master ledger failed", masterChecks];

realPhaseRows = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    phaseMasterRows[#, angularMasterLedger] & /@
      realReduction[projector, family]],
    Keys[realReduction[projector]]]], Keys[realReduction]];
realReductionMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    reductionMetadata /@ realReduction[projector, family]],
    Keys[realReduction[projector]]]], Keys[realReduction]];
processedRowCount = Length[items];
inputRowCount = Total[Flatten[Table[
  Length[realProjectedRows[projector, family]],
  {projector, projectorLabels}, {family, realFamilyLabels}]]];
assembledRowCount = Total[Flatten[Table[
  Length[realPhaseRows[projector, family]],
  {projector, Keys[realPhaseRows]},
  {family, Keys[realPhaseRows[projector]]}]]];
phaseChecks = <|
  "EveryInputRowAssembled" -> assembledRowCount === processedRowCount,
  "EveryKeyBound" -> And @@ Map[
    KeyExistsQ[angularMasterLedger, #] &,
    DeleteDuplicates@Cases[realPhaseRows,
      _HqqV2AngularMasterKey, Infinity]],
  "Exact" -> FreeQ[realPhaseRows,
    _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
  "EndpointExpansionDeferred" -> FreeQ[realPhaseRows,
    SeriesData | Inactive[Series]]|>;
require[And @@ Values[phaseChecks],
  "phase-space master assembly failed", phaseChecks];

If[probeMode,
  probeChecks = <|
    "RepresentativeRows" -> processedRowCount ===
      Length[projectorLabels] Length[realFamilyLabels],
    "Conservation" -> And @@ Values[conservationChecks],
    "VariableMap" -> And @@ Values[variableChecks],
    "TwoBody" -> And @@ Values[twoBodyChecks],
    "Measure" -> And @@ Values[measureChecks],
    "Geometry" -> And @@ Values[geometryChecks],
    "ThreeDirectionRelations" -> And @@ Values[threeRelationChecks],
    "Reduction" -> And @@ Map[And @@ Values[# ["Checks"]] &&
      And @@ Values[# ["CanonicalChecks"]] &, items],
    "Masters" -> And @@ Values[masterChecks],
    "Assembly" -> And @@ Values[phaseChecks]|>;
  Print["S04_PROBE_CHECKS=", InputForm[probeChecks]];
  require[And @@ Values[probeChecks],
    "representative probe failed", probeChecks];
  Print["S04_REPRESENTATIVE_PROBE_OK"];
  Quit[0]];

require[processedRowCount === inputRowCount,
  "production did not process every accepted real row",
  {processedRowCount, inputRowCount}];
require[! FileExistsQ[resultPath],
  "S04 result target already exists; refusing to overwrite it"];

checks = <|
  "InputHashes" -> FileHash[s03SourcePath, "SHA256", "HexString"] ===
      expectedS03SourceHash &&
    FileHash[s03ResultPath, "SHA256", "HexString"] ===
      expectedS03ResultHash,
  "InputSchema" -> AssociationQ[s03] &&
    s03["Stage"] === "HqqV2S03-v1",
  "ProjectorAndFamilySchema" -> projectorLabels === {"Pg", "PPP"} &&
    realFamilyLabels === {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
      "Hqq;qPrime_qbarPrime"},
  "Conservation" -> And @@ Values[conservationChecks],
  "VariableMapAndBounds" -> And @@ Values[variableChecks],
  "TwoBodyMeasure" -> And @@ Values[twoBodyChecks],
  "ThreeBodyMeasure" -> And @@ Values[measureChecks],
  "SixAtomGeometry" -> And @@ Values[geometryChecks],
  "ThreeDirectionRelations" -> And @@ Values[threeRelationChecks],
  "EveryRealRowProcessed" -> processedRowCount === inputRowCount,
  "EveryReductionReconstructs" -> And @@ Map[
    And @@ Values[# ["Checks"]] &&
      And @@ Values[# ["CanonicalChecks"]] &, items],
  "AngularMasters" -> And @@ Values[masterChecks],
  "PhaseAssembly" -> And @@ Values[phaseChecks],
  "BornBoundaryExact" -> FreeQ[
    {bornPhaseInvariant, bornPhaseFractional},
    FeynCalc`Pair | _Real | Indeterminate | ComplexInfinity |
      DirectedInfinity],
  "ExactSymbolicBoundary" -> FreeQ[
    {realPhaseRows, angularMasterLedger},
    _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
  "NoEndpointExpansion" -> FreeQ[
    {realPhaseRows, angularMasterLedger},
    SeriesData | Inactive[Series]]|>;
Print["S04_CHECKS=", InputForm[checks]];
require[And @@ Values[checks],
  "one or more final S04 gates failed", checks];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
result = <|
  "Stage" -> "HqqV2S04-v1", "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|"S03SourceSHA256" -> expectedS03SourceHash,
    "S03ResultSHA256" -> expectedS03ResultHash|>,
  "Runtime" -> <|"Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion|>,
  "Conventions" -> <|
    "DimensionalRegularization" -> D == 4 - 2 epsilon,
    "HardPartNormalization" -> hardPartNormalization,
    "AngularBase" -> {t2, u2},
    "EndpointExpansionDeferredTo" -> "S05",
    "ParallelPolicy" ->
      "serial row streaming: exact row transfer and duplicated memoization outweigh local subkernel work"|>,
  "VariableMap" -> <|
    "Definitions" -> <|"sHat" -> sHatFraction,
      "t1" -> t1Fraction, "u1" -> u1Fraction|>,
    "S23" -> s23Fraction, "Zeta" -> zetaMap,
    "Dzetads23" -> zetaJacobian, "XiLower" -> xiLower,
    "S23Upper" -> s23Upper,
    "DtDuJacobianSigned" -> dtduJacobianSigned,
    "DtDuJacobianPhysical" -> dtduJacobianPhysical,
    "Checks" -> variableChecks|>,
  "Conservation" -> <|
    "PairEquations" -> <|"T" -> tPairEquation,
      "U" -> uPairEquation, "S" -> sPairEquation|>,
    "BaseEquations" -> <|"S12" -> s12BaseEquation,
      "S13" -> s13BaseEquation, "S23" -> s23Equation|>,
    "BaseRules" -> baseRules, "Checks" -> conservationChecks|>,
  "PhaseSpace" -> <|
    "TwoBody" -> <|"RecoilVirtuality" -> twoRecoilVirtuality,
      "FractionalRecoilVirtuality" -> twoRecoilFractional,
      "DeltaScale" -> twoDeltaScale,
      "DeltaConstraint" -> twoDeltaConstraint,
      "InvariantMeasure" -> twoMeasureInvariant,
      "FractionalMeasure" -> twoMeasureFractional,
      "Checks" -> twoBodyChecks|>,
    "ThreeBody" -> <|"AngularPrefactor" -> threeAngularPrefactor,
      "HardPartTimesAngularPrefactor" ->
        hardPartNormalization threeAngularPrefactor,
      "Checks" -> measureChecks|>|>,
  "BornPhaseSpace" -> <|"Invariant" -> bornPhaseInvariant,
    "Fractional" -> bornPhaseFractional|>,
  "AngularGeometry" -> <|"Frame" -> "paper frame 1",
    "CosAlpha1" -> cosAlphaValue,
    "AtomExpressions" -> atomExpressions,
    "AtomGeometries" -> atomGeometries,
    "FamilyAtomPairs" -> familyAtomPairs,
    "Checks" -> geometryChecks|>,
  "ThreeDirectionRelations" -> <|
    "Ledger" -> threeRelationLedger,
    "Checks" -> threeRelationChecks|>,
  "AngularMasters" -> <|
    "DistinctCount" -> Length[angularMasterLedger],
    "Ledger" -> angularMasterLedger,
    "Checks" -> masterChecks|>,
  "RealReductionMetadata" -> realReductionMetadata,
  "RealPhaseSpaceMasterRows" -> realPhaseRows,
  "AssemblyInstruction" ->
    "For each row, sum coefficient times ExactRepresentation under its HqqV2AngularMasterKey; coefficients include Eqs. (19) and (39).",
  "Checks" -> checks|>;

atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];
Print["S04_SOURCE_SHA256=", sourceHash];
Print["S04_RESULT_SHA256=", resultHash];
Print["S04_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S04_DISTINCT_ANGULAR_MASTERS=", Length[angularMasterLedger]];
Print["S04_PROCESSED_REAL_ROWS=", processedRowCount];
Print["S04_CANDIDATE_WRITTEN"];
Quit[0];

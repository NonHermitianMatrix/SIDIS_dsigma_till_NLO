(* Hqq_v2 S02: exact state-summed Hqq tensors and directed loop interference. *)

$HistoryLength = 0;
$LoadFeynArts = True;
$FeynCalcStartupMessages = False;
Needs["FeynCalc`"];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[
  hqqV2Fail, hqqV2Require, atomicPut, generationSymbolQ,
  containsGenerationQ, generationSumData, resolveRowSums,
  deriveTwoBodyKinematics, deriveThreeBodyKinematics,
  installTwoBodyKinematics, installThreeBodyMassShells, makePairRule,
  canonicalTwoBody, canonicalThreeBody, rationalZeroQ, openIndexObjects,
  tensorStructure, tensorZeroQ, tensorEqualQ, conjugateTreeCurrent,
  stateSumRow, wardSubstitute, electromagneticWardResiduals,
  buildRealFamily
];

hqqV2Fail[msg_String] := (Print["S02_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] := If[! TrueQ[test], hqqV2Fail[msg]];

atomicPut[expression_, path_String] := Module[{tmp},
  tmp = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[tmp], DeleteFile[tmp]];
  Check[Put[expression, tmp], hqqV2Fail["failed to write " <> path]];
  hqqV2Require[FileExistsQ[tmp] && FileByteCount[tmp] > 0,
    "temporary result is missing or empty"];
  RenameFile[tmp, path, OverwriteTarget -> True];
  hqqV2Require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{stageDirectory,
  "s01_generate_hqq_amplitudes.wl"}];
s01ResultPath = FileNameJoin[{stageDirectory, "s01_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s02_result.wl"}];
expectedS01SourceHash =
  "5125f6f8a2c2ac7cfa44fc3b8bb437e1f5fdf26c52169d9c4991f5b35ab660d1";
expectedS01ResultHash =
  "83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911";

hqqV2Require[
  FileHash[s01SourcePath, "SHA256", "HexString"] === expectedS01SourceHash,
  "S01 source identity mismatch"];
hqqV2Require[
  FileHash[s01ResultPath, "SHA256", "HexString"] === expectedS01ResultHash,
  "S01 result identity mismatch"];
s01 = Get[s01ResultPath];
hqqV2Require[
  AssociationQ[s01] && s01["Stage"] === "HqqV2S01-v1" &&
    s01["ScopeTag"] === scopeTag && And @@ Values[s01["Checks"]],
  "S01 result is not accepted"];

mu = s01["OpenPhotonIndex"];
nu = Unique["nu"];
inputRows = s01["OpenCurrentsPerDiagram"];
familyLabels = Keys[inputRows];

(* FeynArts generation sums are physical flavor bookkeeping, whereas its
   color/gluon SumOver wrappers must be removed before FeynCalc performs the
   corresponding SU(N) contractions.  The flavor marker is read from the
   same generated row; no flavor count is inserted here. *)
generationSymbolQ[symbol_] :=
  MatchQ[Unevaluated[symbol], _Symbol] &&
    SymbolName[Unevaluated[symbol]] === "Generation";
containsGenerationQ[expression_] := ! FreeQ[
  Unevaluated[expression],
  symbol_Symbol /; generationSymbolQ[symbol]
];
generationSumData[expression_] := Cases[
  expression,
  sum : FeynArts`SumOver[index_, bound_, rest___] /;
      containsGenerationQ[index] :> {HoldComplete[sum], bound},
  Infinity
];

$S02GenerationRecords = {};
$S02NonGenerationSumCount = 0;
resolveRowSums[expression_, label_String, row_Integer] := Module[
  {generationData, chargeTypes, flavorType, multiplicity, answer,
   sumCountBefore, sumCountAfter},
  generationData = generationSumData[expression];
  chargeTypes = DeleteDuplicates@Cases[expression,
    HqqV2Charge[tag_String] :> tag, Infinity];
  sumCountBefore = Count[expression, _FeynArts`SumOver, Infinity];
  answer = expression;
  If[generationData =!= {},
    hqqV2Require[Length[generationData] === 1,
      label <> " row " <> ToString[row] <>
        " has more than one generation wrapper"];
    hqqV2Require[Length[chargeTypes] === 1 &&
        MemberQ[{"UpType", "DownType"}, First[chargeTypes]],
      label <> " row " <> ToString[row] <>
        " does not determine one flavor type"];
    flavorType = First[chargeTypes];
    multiplicity = HqqV2FlavorMultiplicity[flavorType];
    AppendTo[$S02GenerationRecords, <|
      "Family" -> label, "Row" -> row,
      "ModelBound" -> generationData[[1, 2]],
      "FlavorType" -> flavorType,
      "Replacement" -> multiplicity|>];
    answer = answer /.
      HoldPattern[FeynArts`SumOver[index_, bound_, rest___] /;
        containsGenerationQ[index]] :> multiplicity;
  ];
  sumCountAfter = Count[answer, _FeynArts`SumOver, Infinity];
  $S02NonGenerationSumCount += sumCountAfter;
  answer = answer /. HoldPattern[FeynArts`SumOver[___]] -> 1;
  hqqV2Require[FreeQ[answer, _FeynArts`SumOver] &&
      ! containsGenerationQ[answer],
    "a SumOver or generation index survived in " <> label <>
      " row " <> ToString[row]];
  hqqV2Require[sumCountBefore === Length[generationData] + sumCountAfter,
    "SumOver accounting failed in " <> label <>
      " row " <> ToString[row]];
  answer
];

inputGenerationSumCount = Total@Flatten@KeyValueMap[
  Function[{label, rows}, Length[generationSumData[#]] & /@ rows],
  inputRows
];
inputNonGenerationSumCount = Total@Flatten@KeyValueMap[
  Function[{label, rows},
    (Count[#, _FeynArts`SumOver, Infinity] -
        Length[generationSumData[#]]) & /@ rows],
  inputRows
];
resolvedRows = Association@KeyValueMap[
  Function[{label, rows},
    label -> MapIndexed[
      Function[{expression, position},
        resolveRowSums[expression, label, First[position]]],
      rows]],
  inputRows
];
resolvedSums = AssociationMap[Total[resolvedRows[#]] &, familyLabels];

hqqV2Require[inputGenerationSumCount > 0 &&
    Length[$S02GenerationRecords] === inputGenerationSumCount &&
    $S02NonGenerationSumCount === inputNonGenerationSumCount &&
    AllTrue[$S02GenerationRecords,
      IntegerQ[# ["ModelBound"]] && # ["ModelBound"] > 0 &] &&
    FreeQ[resolvedRows, _FeynArts`SumOver] &&
    And @@ KeyValueMap[SameQ[resolvedSums[#1], Total[#2]] &, resolvedRows],
  "generated-sum resolution failed"];
Print["S02_GENERATION_SUMS=", inputGenerationSumCount,
  " NON_GENERATION_SUMS=", inputNonGenerationSumCount];

(* Every scalar product and dependent invariant is solved by Wolfram from
   the paper's definitions and momentum conservation. *)
deriveTwoBodyKinematics[] := Module[
  {vectors, residual, pairs, variables, pairVariables, equations, solution,
   values, records, uRule, equationResiduals},
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  vectors = {p, q, k1, k2};
  residual = p + q - k1 - k2;
  equations = Join[{
      FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p + q, p + q]] == sHat,
      FeynCalc`ExpandScalarProduct[FeynCalc`SPD[q - k1, q - k1]] == tHat,
      FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p - k1, p - k1]] == uHat
    },
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[residual, #]] == 0 & /@
      vectors];
  pairs = DeleteDuplicates[Cases[equations, _FeynCalc`Pair, Infinity]];
  variables = Array[s02TwoSP, Length[pairs]];
  pairVariables = Thread[pairs -> variables];
  solution = Solve[equations /. pairVariables, Join[variables, {uHat}]];
  hqqV2Require[Length[solution] === 1,
    "two-body invariants lack a unique solution"];
  solution = First[solution];
  values = Together /@ ((variables /. solution) /. solution);
  records = MapThread[
    Function[{pair, value}, Module[{momenta = List @@ pair},
      <|"Momentum1" -> First[List @@ momenta[[1]]],
        "Momentum2" -> First[List @@ momenta[[2]]],
        "Dimension" -> Last[List @@ momenta[[1]]],
        "Value" -> value|>]],
    {pairs, values}];
  equationResiduals = Together[(#[[1]] - #[[2]]) /. pairVariables /.
      solution /. solution] & /@ equations;
  hqqV2Require[And @@ (# === 0 & /@ equationResiduals),
    "two-body solution failed its defining equations"];
  uRule = FirstCase[solution,
    HoldPattern[uHat -> value_] :> (uHat -> value),
    Missing["NotFound"]];
  hqqV2Require[MatchQ[uRule, _Rule],
    "two-body dependent-invariant rule is missing"];
  <|"MassShells" -> {{p, 0}, {q, -Q2}, {k1, 0}, {k2, 0}},
    "ScalarProductAssignments" -> records,
    "MandelstamURule" -> uRule,
    "EquationResiduals" -> equationResiduals|>
];

deriveThreeBodyKinematics[] := Module[
  {vectors, residual, definitions, pairs, variables, pairVariables,
   definitionSolution, values, records, definitionResiduals,
   allInvariants, keptInvariants, eliminatedInvariants,
   conservationEquations, conservationSolution, conservationResiduals},
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[k3, k3] = 0;
  vectors = {p, q, k1, k2, k3};
  residual = p + q - k1 - k2 - k3;
  definitions = {
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p + q, p + q]] == sHat,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[q - k1, q - k1]] == t1,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[q - k2, q - k2]] == t2,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[q - k3, q - k3]] == t3,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p - k1, p - k1]] == u1,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p - k2, p - k2]] == u2,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[p - k3, p - k3]] == u3,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[k1 + k2, k1 + k2]] == s12,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[k1 + k3, k1 + k3]] == s13,
    FeynCalc`ExpandScalarProduct[FeynCalc`SPD[k2 + k3, k2 + k3]] == s23
  };
  pairs = DeleteDuplicates[Cases[definitions, _FeynCalc`Pair, Infinity]];
  variables = Array[s02ThreeSP, Length[pairs]];
  pairVariables = Thread[pairs -> variables];
  definitionSolution = Solve[definitions /. pairVariables, variables];
  hqqV2Require[Length[definitionSolution] === 1,
    "three-body invariant definitions lack a unique scalar-product map"];
  definitionSolution = First[definitionSolution];
  values = Together /@ (variables /. definitionSolution);
  records = MapThread[
    Function[{pair, value}, Module[{momenta = List @@ pair},
      <|"Momentum1" -> First[List @@ momenta[[1]]],
        "Momentum2" -> First[List @@ momenta[[2]]],
        "Dimension" -> Last[List @@ momenta[[1]]],
        "Value" -> value|>]],
    {pairs, values}];
  definitionResiduals = Together[(#[[1]] - #[[2]]) /. pairVariables /.
      definitionSolution] & /@ definitions;
  hqqV2Require[And @@ (# === 0 & /@ definitionResiduals),
    "three-body scalar-product map failed its definitions"];
  conservationEquations =
    (FeynCalc`ExpandScalarProduct[FeynCalc`SPD[residual, #]] /.
        pairVariables /. definitionSolution) == 0 & /@ vectors;
  allInvariants = {sHat, t1, t2, t3, u1, u2, u3, s12, s13, s23};
  keptInvariants = {sHat, t1, t2, u1, u2};
  eliminatedInvariants = Complement[allInvariants, keptInvariants];
  conservationSolution = Quiet[Solve[
    conservationEquations, eliminatedInvariants], {Solve::svars}];
  hqqV2Require[Length[conservationSolution] === 1 &&
      Complement[eliminatedInvariants,
        First /@ First[conservationSolution]] === {},
    "three-body conservation system did not solve the selected complement"];
  conservationSolution = First[conservationSolution];
  conservationResiduals = Together[(#[[1]] - #[[2]]) /.
      conservationSolution] & /@ conservationEquations;
  hqqV2Require[And @@ (# === 0 & /@ conservationResiduals),
    "three-body conservation solution has a nonzero residual"];
  <|"MassShells" -> {{p, 0}, {q, -Q2}, {k1, 0}, {k2, 0}, {k3, 0}},
    "ScalarProductAssignments" -> records,
    "DefinitionResiduals" -> definitionResiduals,
    "KeptInvariants" -> keptInvariants,
    "EliminatedInvariants" -> eliminatedInvariants,
    "ConservationEquations" -> conservationEquations,
    "ConservationRules" -> conservationSolution,
    "ConservationResiduals" -> conservationResiduals|>
];

twoBodyKinematics = deriveTwoBodyKinematics[];
threeBodyKinematics = deriveThreeBodyKinematics[];

installTwoBodyKinematics[] := Module[{},
  FeynCalc`FCClearScalarProducts[];
  Scan[(FeynCalc`SPD[#[[1]], #[[1]]] = #[[2]]) &,
    twoBodyKinematics["MassShells"]];
  Scan[Function[record,
    With[{momentum1 = record["Momentum1"],
        momentum2 = record["Momentum2"], value = record["Value"]},
      FeynCalc`SPD[momentum1, momentum2] = value]],
    twoBodyKinematics["ScalarProductAssignments"]];
  True
];
installThreeBodyMassShells[] := Module[{},
  FeynCalc`FCClearScalarProducts[];
  Scan[(FeynCalc`SPD[#[[1]], #[[1]]] = #[[2]]) &,
    threeBodyKinematics["MassShells"]];
  True
];

makePairRule[record_] := With[
  {momentum1 = record["Momentum1"], momentum2 = record["Momentum2"],
   dimension = record["Dimension"], value = record["Value"]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum1, dimension],
    FeynCalc`Momentum[momentum2, dimension]]] :> value
];
twoBodyPairRules = makePairRule /@
  twoBodyKinematics["ScalarProductAssignments"];
threeBodyPairRules = makePairRule /@
  threeBodyKinematics["ScalarProductAssignments"];

canonicalTwoBody[expression_] := Module[{answer},
  answer = FeynCalc`FeynAmpDenominatorExplicit[
    FeynCalc`Contract[FeynCalc`ExpandScalarProduct[expression]]];
  answer = answer /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  answer = FeynCalc`Contract[answer] /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  answer
];
canonicalThreeBody[expression_] := Module[{answer},
  answer = expression /. HoldPattern[FeynCalc`Momentum[k3, dimension_]] :>
    FeynCalc`Momentum[p + q - k1 - k2, dimension];
  answer = FeynCalc`ExpandScalarProduct[answer];
  answer = FeynCalc`FeynAmpDenominatorExplicit[FeynCalc`Contract[answer]];
  answer = answer /. threeBodyPairRules /.
    threeBodyKinematics["ConservationRules"];
  answer = FeynCalc`Contract[answer] /. threeBodyPairRules /.
    threeBodyKinematics["ConservationRules"];
  answer
];

rationalZeroQ[coefficient_] :=
  TrueQ[Expand[Numerator[Together[coefficient]]] === 0];
openIndexObjects[expression_] := DeleteDuplicates@Cases[
  expression,
  pair : FeynCalc`Pair[a_, b_] /;
      ! FreeQ[pair, FeynCalc`LorentzIndex[mu | nu, D]],
  Infinity, Heads -> True
];
tensorStructure[term_] := Times @@ Cases[
  term,
  pair : FeynCalc`Pair[a_, b_] /;
      ! FreeQ[pair, FeynCalc`LorentzIndex[mu | nu, D]],
  Infinity, Heads -> True
];
tensorZeroQ[expression_, canonicalizer_] := Module[
  {canonical, terms, table},
  canonical = canonicalizer[expression];
  If[TrueQ[canonical === 0], Return[True, Module]];
  terms = If[Head[Expand[canonical]] === Plus,
    List @@ Expand[canonical], {canonical}];
  table = Merge[
    Association[With[{structure = tensorStructure[#]},
      structure -> Cancel[#/structure]]] & /@ terms,
    Total];
  And @@ (rationalZeroQ /@ Values[table])
];
tensorEqualQ[left_, right_, canonicalizer_] :=
  tensorZeroQ[left - right, canonicalizer];

treeRealityRules = {
  HoldPattern[Conjugate[HqqV2Charge[tag_]]] :> HqqV2Charge[tag],
  HoldPattern[Conjugate[HqqV2FlavorMultiplicity[tag_]]] :>
    HqqV2FlavorMultiplicity[tag]
};
conjugateTreeCurrent[amplitude_, label_String] := Module[{answer},
  hqqV2Require[FreeQ[amplitude,
      FeynCalc`B0 | FeynCalc`C0 | FeynCalc`D0 | FeynCalc`PaVe | Log],
    label <> " is not a tree current"];
  answer = CheckAbort[Quiet@Check[
    FeynCalc`ComplexConjugate[
      amplitude /. mu -> nu,
      FeynCalc`FCRenameDummyIndices -> True,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  answer = answer /. treeRealityRules;
  hqqV2Require[answer =!= $Failed && FreeQ[answer, Conjugate] &&
      ! FreeQ[answer, FeynCalc`LorentzIndex[nu, D]],
    label <> " conjugation failed"];
  answer
];

(* The ordering is the one measured for Hqq: close every fermion chain before
   asking FeynCalc to remove external polarization vectors. *)
stateSumRow[expression_, specifications_List, setup_, label_String] := Module[
  {postSpin, postPolarization, postDirac, answer},
  setup[];
  postSpin = CheckAbort[Quiet@Check[
    FeynCalc`FermionSpinSum[expression,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[postSpin =!= $Failed, label <> " spin sum failed"];
  postPolarization = Fold[
    Function[{current, specification}, CheckAbort[Quiet@Check[
      FeynCalc`DoPolarizationSums[current,
        specification[[1]], specification[[2]],
        TimeConstrained -> Infinity,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0], $Failed], $Failed]],
    postSpin, specifications];
  hqqV2Require[postPolarization =!= $Failed,
    label <> " polarization sum failed"];
  postDirac = CheckAbort[Quiet@Check[
    FeynCalc`DiracSimplify[postPolarization,
      FeynCalc`DiracTrace -> True,
      FeynCalc`DiracTraceEvaluate -> True,
      FeynCalc`DiracSubstitute67 -> True,
      FeynCalc`ToDiracGamma67 -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0,
      FeynCalc`Factoring -> False], $Failed], $Failed];
  hqqV2Require[postDirac =!= $Failed && FreeQ[postDirac,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
      _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " Dirac/state reduction is incomplete"];
  answer = CheckAbort[Quiet@Check[
    FeynCalc`SUNSimplify[postDirac initialStateAverage,
      FeynCalc`Explicit -> True,
      FeynCalc`SUNNToCACF -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex | _FeynArts`SumOver |
      _Real | Indeterminate | ComplexInfinity | DirectedInfinity],
    label <> " color sum/average failed"];
  answer
];

installTwoBodyKinematics[];
spinProbe = FeynCalc`DiracSimplify[
  FeynCalc`DiracTrace[
    FeynCalc`GSD[p] . FeynCalc`GSD[s02SpinReference]],
  FeynCalc`DiracTraceEvaluate -> True,
  FeynCalc`FCVerbose -> 0];
spinNormalization = 2 FeynCalc`FCI[
  FeynCalc`SPD[p, s02SpinReference]];
initialSpinStates = Together[spinProbe/spinNormalization];
initialColorStates = FeynCalc`SUNSimplify[
  FeynCalc`SUNFDelta[s02ColorReference, s02ColorReference],
  FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0];
initialStateAverage = Together[
  1/(initialSpinStates initialColorStates)];
hqqV2Require[initialSpinStates =!= 0 && initialColorStates =!= 0 &&
    Together[initialStateAverage initialSpinStates initialColorStates] === 1 &&
    FreeQ[{initialSpinStates, initialColorStates, initialStateAverage}, _Real],
  "initial-state normalization was not derived exactly"];
Print["S02_INITIAL_STATE_AVERAGE=", InputForm[initialStateAverage]];

bornMu = resolvedSums["Born"];
bornNu = conjugateTreeCurrent[bornMu, "Born"];
Print["S02_STAGE=Born tensor"];
bornTensor = stateSumRow[bornMu bornNu, {{k2, 0}},
  installTwoBodyKinematics, "Born"];

buildRealFamily[label_String, specifications_List] := Module[
  {fullNu, rows},
  fullNu = conjugateTreeCurrent[resolvedSums[label], label <> " sum"];
  rows = MapIndexed[
    Function[{amplitude, position},
      Print["S02_REAL_ROW=", label, " ", First[position], "/",
        Length[resolvedRows[label]]];
      stateSumRow[amplitude fullNu, specifications,
        installThreeBodyMassShells,
        label <> " row " <> ToString[First[position]]]],
    resolvedRows[label]];
  <|"Rows" -> rows, "Tensor" -> Total[rows],
    "ConjugateCurrent" -> fullNu|>
];

realPolarizationSpecifications = <|
  "Hqq;gg" -> {{k2, p}, {k3, p}},
  "Hqq;q_qbar_sameFlavor" -> {},
  "Hqq;qPrime_qbarPrime" -> {}
|>;
realLabels = Keys[realPolarizationSpecifications];
Print["S02_STAGE=coherent real tensors"];
realBuilds = AssociationMap[
  Function[label,
    buildRealFamily[label, realPolarizationSpecifications[label]]],
  realLabels];
realRows = AssociationMap[realBuilds[#, "Rows"] &, realLabels];
realTensors = AssociationMap[realBuilds[#, "Tensor"] &, realLabels];

(* Tree-level gauge gates. *)
wardSubstitute[expression_, momentum_] := expression /.
  HoldPattern[FeynCalc`Momentum[
    FeynCalc`Polarization[momentum, phases___], dimension_]] :>
      FeynCalc`Momentum[momentum, dimension];

bornGluonWardMu = wardSubstitute[bornMu, k2];
bornGluonWardNu = conjugateTreeCurrent[
  bornGluonWardMu, "Born gluon Ward current"];
bornGluonWardTensor = stateSumRow[
  bornGluonWardMu bornGluonWardNu, {},
  installTwoBodyKinematics, "Born gluon Ward tensor"];
bornGluonWardZero = tensorZeroQ[bornGluonWardTensor, canonicalTwoBody];
hqqV2Require[bornGluonWardZero,
  "Born external-gluon Ward identity failed"];

electromagneticWardResiduals[
    tensor_, canonicalizer_, vectors_List, label_String] := Module[
  {qMu, residuals},
  qMu = FeynCalc`Pair[FeynCalc`Momentum[q, D],
    FeynCalc`LorentzIndex[mu, D]];
  residuals = AssociationThread[
    ToString[#, InputForm] & /@ vectors,
    (canonicalizer[FeynCalc`Contract[
        qMu FeynCalc`Pair[FeynCalc`Momentum[#, D],
          FeynCalc`LorentzIndex[nu, D]] tensor]]) & /@ vectors];
  Print["S02_EM_WARD=", label, " ",
    InputForm[Map[rationalZeroQ, residuals]]];
  residuals
];

bornEMWardResiduals = electromagneticWardResiduals[
  bornTensor, canonicalTwoBody, {q, p, k1, k2}, "Born"];
bornEMWardZero = And @@ (rationalZeroQ /@ Values[bornEMWardResiduals]);
hqqV2Require[bornEMWardZero,
  "the Born electromagnetic Ward identity failed"];
Print["S02_STAGE=real gauge gates deferred to projected scalars in S03"];

(* TID acts on each small generated loop row.  No Hermitian conjugate is
   formed here: Package-X analytic continuation precedes 2 Re in S03. *)
Print["S02_STAGE=TID bare virtual currents"];
reducedVirtualCurrents = MapIndexed[
  Function[{amplitude, position}, Module[{answer},
    Print["S02_TID_ROW=", First[position], "/",
      Length[resolvedRows["VirtualBare"]]];
    installTwoBodyKinematics[];
    answer = CheckAbort[Quiet@Check[
      FeynCalc`TID[amplitude, ell,
        FeynCalc`ToPaVe -> True,
        FeynCalc`UsePaVeBasis -> True,
        FeynCalc`FeynAmpDenominatorSimplify -> False,
        FeynCalc`ApartFF -> False,
        FeynCalc`FCVerbose -> 0], $Failed], $Failed];
    hqqV2Require[answer =!= $Failed &&
        FreeQ[answer, ell | FeynCalc`TID],
      "virtual TID row " <> ToString[First[position]] <> " failed"];
    answer]],
  resolvedRows["VirtualBare"]];

Print["S02_STAGE=directed bare virtual tensor"];
virtualRows = MapIndexed[
  Function[{amplitude, position},
    Print["S02_VIRTUAL_ROW=", First[position], "/",
      Length[reducedVirtualCurrents]];
    stateSumRow[amplitude bornNu, {{k2, k1}},
      installTwoBodyKinematics,
      "directed virtual row " <> ToString[First[position]]]],
  reducedVirtualCurrents];
virtualTensor = Total[virtualRows];

countertermRowsInput = resolvedRows["VirtualCounterterm"];
hqqV2Require[Length[countertermRowsInput] > 0 &&
    FreeQ[countertermRowsInput, _FeynArts`SumOver | _Real] &&
    ! FreeQ[countertermRowsInput,
      dZGG1 | dZgs1 | _dZfL1 | _dZfR1],
  "generated counterterm rows are incomplete"];
Print["S02_STAGE=generated counterterm rows deferred to S03 MS-bar step"];

tensorRows = <|
  "Real" -> realRows,
  "VirtualBareDirected" -> virtualRows
|>;
tensors = <|
  "Born" -> bornTensor,
  "Real" -> realTensors,
  "VirtualBareDirected" -> virtualTensor
|>;
flatTensors = Join[{bornTensor}, Values[realTensors], {virtualTensor}];

chargeDegree[expression_] := Exponent[
  expression /. HqqV2Charge[_] -> s02ChargeDegreeTag,
  s02ChargeDegreeTag];
checks = <|
  "S01IdentityAccepted" -> True,
  "GeneratedSumsResolvedSymbolically" ->
    (Length[$S02GenerationRecords] === inputGenerationSumCount &&
      inputGenerationSumCount > 0 &&
      $S02NonGenerationSumCount === inputNonGenerationSumCount &&
      FreeQ[resolvedRows, _FeynArts`SumOver]),
  "KinematicsToolDerived" ->
    (And @@ (# === 0 & /@ twoBodyKinematics["EquationResiduals"]) &&
      And @@ (# === 0 & /@
        threeBodyKinematics["DefinitionResiduals"]) &&
      And @@ (# === 0 & /@
        threeBodyKinematics["ConservationResiduals"])),
  "InitialStateAverageToolDerived" ->
    (Together[initialStateAverage initialSpinStates initialColorStates] === 1),
  "BornRowsReconstruct" -> SameQ[resolvedSums["Born"],
    Total[resolvedRows["Born"]]],
  "RealRowsReconstruct" -> And @@
    (SameQ[realTensors[#], Total[realRows[#]]] & /@ realLabels),
  "VirtualRowsReconstruct" -> SameQ[virtualTensor, Total[virtualRows]],
  "CountertermRowsDeferredExactly" ->
    (SameQ[countertermRowsInput,
        resolvedRows["VirtualCounterterm"]] &&
      Length[countertermRowsInput] > 0 &&
      FreeQ[countertermRowsInput, _FeynArts`SumOver | _Real]),
  "BornGluonWardIdentity" -> bornGluonWardZero,
  "BornElectromagneticWardIdentity" -> bornEMWardZero,
  "ResolvedRealGateInputsPublished" ->
    (And @@ (SameQ[resolvedSums[#], Total[resolvedRows[#]]] & /@
        realLabels) &&
      FreeQ[AssociationMap[resolvedRows[#] &, realLabels],
        _FeynArts`SumOver | _Real]),
  "DirectedVirtualOnly" ->
    (Length[virtualRows] === Length[reducedVirtualCurrents] &&
      FreeQ[virtualRows, Re | Im]),
  "AllVirtualCurrentsTIDReduced" ->
    FreeQ[reducedVirtualCurrents, ell | FeynCalc`TID | $Failed],
  "OpenPhotonIndicesRetained" -> And @@
    ((! FreeQ[#, FeynCalc`LorentzIndex[mu, D]] &&
       ! FreeQ[#, FeynCalc`LorentzIndex[nu, D]]) & /@ flatTensors),
  "AllExternalStatesSummed" -> FreeQ[flatTensors,
    _FeynCalc`Spinor | _FeynCalc`Polarization |
    _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
  "AllColorsSummed" -> FreeQ[flatTensors,
    _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex],
  "QuadraticChargeDegree" -> And @@
    (chargeDegree[#] === 2 & /@ flatTensors),
  "SymbolicExact" -> FreeQ[
    {tensors, tensorRows, countertermRowsInput,
      twoBodyKinematics, threeBodyKinematics},
    $Failed | _Real | Indeterminate | ComplexInfinity | DirectedInfinity]
|>;
Print["S02_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks],
  "one or more final S02 gates failed"];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
result = <|
  "Stage" -> "HqqV2S02-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "S01" -> <|"SourceSHA256" -> expectedS01SourceHash,
    "ResultSHA256" -> expectedS01ResultHash|>,
  "Runtime" -> <|"Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion|>,
  "PhotonIndices" -> {mu, nu},
  "GenerationSums" -> <|
    "InputGenerationCount" -> inputGenerationSumCount,
    "InputNonGenerationCount" -> inputNonGenerationSumCount,
    "Records" -> $S02GenerationRecords,
    "Convention" ->
      "generation wrappers become symbolic per-type multiplicities; model bounds are provenance only; color/gluon wrappers are removed before FeynCalc color algebra"|>,
  "InitialStateNormalization" -> <|
    "SpinProbe" -> spinProbe,
    "SpinNormalization" -> spinNormalization,
    "InitialSpinStates" -> initialSpinStates,
    "InitialColorStates" -> initialColorStates,
    "InitialStateAverage" -> initialStateAverage|>,
  "Kinematics" -> <|"TwoBody" -> twoBodyKinematics,
    "ThreeBody" -> threeBodyKinematics|>,
  "PolarizationSums" -> <|
    "Born" -> {{k2, 0}},
    "VirtualBareDirected" -> {{k2, k1}},
    "Hqq;gg" -> {{k2, p}, {k3, p}},
    "QuarkPairFamilies" -> {}|>,
  "ReducedVirtualCurrentsPerDiagram" -> reducedVirtualCurrents,
  "DeferredCountertermInputs" -> <|
    "GeneratedRows" -> countertermRowsInput,
    "RequiredConsumer" ->
      "S03 must derive and gate the MS-bar QCD constants with tools, substitute them into these exact rows, and form the directed counterterm Born interference"|>,
  "TensorRows" -> tensorRows,
  "Tensors" -> tensors,
  "DeferredRealGaugeGateInputs" -> <|
    "ResolvedRows" -> AssociationMap[resolvedRows[#] &, realLabels],
    "ResolvedSums" -> AssociationMap[resolvedSums[#] &, realLabels],
    "PrimaryHqqGGReference" -> p,
    "AlternativeHqqGGReference" -> k1,
    "RequiredConsumer" ->
      "S03 must run electromagnetic and external-gluon Ward gates plus p-versus-k1 reference independence separately after Pg and PPP contraction"|>,
  "WardGates" -> <|
    "BornExternalGluon" -> bornGluonWardZero,
    "BornElectromagneticResiduals" -> bornEMWardResiduals|>,
  "HermitianConvention" ->
    "the stored loop tensor is directed M_virtual^mu (M_Born^nu)*; counterterm construction, Package-X analytic continuation, and explicit 2 Re are deferred to S03",
  "Checks" -> checks
|>;

atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];
tensorLeafCounts = Map[LeafCount, tensors, {1}];

(* A separate kernel must be able to bind all package symbols and accept the
   exact on-disk artifact before this process emits S02_SUCCESS. *)
kernelExecutable = First[$CommandLine];
validatorCode = StringJoin[
  "$HistoryLength=0;$LoadFeynArts=True;$FeynCalcStartupMessages=False;",
  "Needs[\"FeynCalc`\"];",
  "r=Get[", ToString[resultPath, InputForm], "];",
  "ok=AssociationQ[r]&&r[\"Stage\"]===\"HqqV2S02-v1\"&&",
  "r[\"ScopeTag\"]===", ToString[scopeTag, InputForm], "&&",
  "And@@Values[r[\"Checks\"]]&&",
  "FileHash[", ToString[sourcePath, InputForm],
    ",\"SHA256\",\"HexString\"]===r[\"Source\",\"SHA256\"];",
  "If[TrueQ[ok],Print[\"S02_FRESH_RELOAD_OK\"];Quit[0],",
  "Print[\"S02_FRESH_RELOAD_FAIL\"];Quit[1]]"
];
Clear[result, flatTensors, tensors, tensorRows,
  bornGluonWardTensor];
Share[];
validator = RunProcess[
  {kernelExecutable, "-noinit", "-noprompt", "-run", validatorCode}];
Print[validator["StandardOutput"]];
If[StringLength[validator["StandardError"]] > 0,
  Print[validator["StandardError"]]];
hqqV2Require[validator["ExitCode"] === 0 &&
    StringContainsQ[validator["StandardOutput"], "S02_FRESH_RELOAD_OK"],
  "fresh-kernel result validation failed"];

Print["S02_TENSOR_LEAF_COUNTS=", InputForm[tensorLeafCounts]];
Print["S02_SOURCE_SHA256=", sourceHash];
Print["S02_RESULT_SHA256=", resultHash];
Print["S02_SUCCESS"];
Quit[0];

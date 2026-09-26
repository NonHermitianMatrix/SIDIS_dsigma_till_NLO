(* Exact rational transverse-coordinate implementation of the Born spin response. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s03_born_spin_response_exact.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
checks = <||>;
ClearAll[gate, zeroQ, simplify, dot4, coordinates, reduceScalar, buildTensor, spinNumerator, coefficient];
gate[name_, test_] := If[TrueQ[test], If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["supported Born channel", MemberQ[{"Hqq", "Hqg", "Hgq"}, channel]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
FCSetDiracGammaScheme["BMHV"];
SetAttributes[bounded, HoldFirst];
bounded[work_, name_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["FAIL: time bound ", name]; Quit[2]], 2*1024^3,
  Print["FAIL: memory bound ", name]; Quit[3]];
zeroQ[value_] := And @@ (TrueQ[# === 0] & /@ Flatten[{value}]);
inVariables = {1, xIn, yIn, hIn}; outVariables = {1, xOut, yOut, hOut};
$Assumptions = Q > 0 && s > 0 && t < 0 && Q^2 + s + t > 0 && SUNN > 1 &&
  Element[{Q, s, t, SUNN, xIn, yIn, hIn, xOut, yOut, hOut}, Reals];
simplify[value_] := FullSimplify[value, Assumptions -> $Assumptions];

config = Import[FileNameJoin[{root, "common", "s01_inputs.json"}], "RawJSON"];
basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
basis = Get[basisPath];
gate["basis schema", basis["Schema"] === "polarized-sidis-spin-basis-v1"];
gate["basis checks", And @@ Values[basis["Checks"]]];
contract = config["channel_contracts"][channel];
ampPath = FileNameJoin[{root, contract["amplitude_file"]}];
ampRow = SelectFirst[config["files"], #["destination"] === contract["amplitude_file"] &];
gate["amplitude identity", IntegerString[FileHash[ampPath, "SHA256"], 16, 64] === ampRow["sha256"]];
generated = Get[ampPath];
referencePath = FileNameJoin[{root, contract["unpolarized_born_file"]}];
reference = Get[referencePath];
normalization = Get[FileNameJoin[{root, config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}]];
chargeSquared = normalization["ModelChargeSquared"];
gate["reference charge normalization", NumberQ[chargeSquared] && chargeSquared > 0];
amplitude = ChangeDimension[Total[generated["Born"]], 4] /.
  {SMP["e"] -> 1, SMP["g_s"] -> 1};
fermionMomenta = DeleteDuplicates[Cases[amplitude, Spinor[sign_. Momentum[mom_], __] :> mom, Infinity]];
gluonMomenta = DeleteCases[DeleteDuplicates[Cases[amplitude, Polarization[mom_, __] :> mom, Infinity]], q];
gate["one Born gluon", Length[gluonMomenta] === 1];
gluonMomentum = First[gluonMomenta];
incomingQuark = MemberQ[fermionMomenta, p]; outgoingQuark = MemberQ[fermionMomenta, k1];
gate["channel spin assignments", {incomingQuark, outgoingQuark, gluonMomentum} ===
  Switch[channel, "Hqq", {True, True, k2}, "Hqg", {True, False, k1}, "Hgq", {False, True, p}]];
initialColor = SUNSimplify[If[incomingQuark, SUNFDelta[ci, ci], SUNDelta[ca, ca]], SUNNToCACF -> False];
incomingNormalization = basis["IncomingDensityNormalization"] initialColor;

(* Breit frame: +z incoming parton, -z photon, positive tagged-parton x. *)
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot4[a_, b_] := Expand[a.metric.b];
pTrial = {ep, 0, 0, ep}; qTrial = {0, 0, 0, -Q};
kTrial = {ek, Sqrt[kxSquared], 0, kz}; recoilTrial = pTrial + qTrial - kTrial;
equations = {dot4[pTrial + qTrial, pTrial + qTrial] == s,
  dot4[qTrial - kTrial, qTrial - kTrial] == t,
  dot4[kTrial, kTrial] == 0, dot4[recoilTrial, recoilTrial] == 0};
linearSolution[polynomials_, variables_, label_] := Module[{arrays, rules},
  arrays = Normal /@ CoefficientArrays[polynomials, variables];
  gate[label <> " is linear", Length[arrays] === 2];
  gate[label <> " is nonsingular in the physical region", simplify[Det[arrays[[2]]] != 0]];
  rules = Thread[variables -> (Factor /@ LinearSolve[arrays[[2]], -arrays[[1]]])];
  gate[label <> " linear reconstruction", zeroQ[Factor[polynomials /. rules]]];
  rules];
framePolynomials = equations /. Equal -> Subtract;
shellPolynomial = framePolynomials[[3]];
longitudinalRules = linearSolution[{framePolynomials[[1]],
  Expand[framePolynomials[[2]] - shellPolynomial]}, {ep, kz}, "longitudinal frame"];
energyRules = linearSolution[{Expand[(framePolynomials[[4]] - shellPolynomial) /. longitudinalRules]},
  {ek}, "tagged energy"];
transverseRules = linearSolution[{Expand[shellPolynomial /. longitudinalRules /. energyRules]},
  {kxSquared}, "tagged transverse momentum"];
frameSolution = Join[longitudinalRules, energyRules, transverseRules];
gate["Born frame reconstructs invariants", And @@ simplify[equations /. frameSolution]];
gate["central tagged direction retained", And @@ simplify[(equations /. frameSolution) /. t -> -Q^2]];
transverseSquared = Factor[kxSquared /. frameSolution];
transverseRule = transverseK -> Sqrt[transverseSquared];
transverseConstraint = transverseK^2 - transverseSquared;
ClearAll[algebraicReduce];
algebraicReduce[values_List] := algebraicReduce /@ values;
algebraicReduce[value_] := Module[{rational, numerator, denominator, division, remainder},
  gate["unconditional algebraic input", FreeQ[value, _ConditionalExpression | _Piecewise]];
  rational = Together[value]; numerator = Numerator[rational]; denominator = Denominator[rational];
  gate["transverse-independent denominator", FreeQ[denominator, transverseK]];
  gate["polynomial transverse numerator", PolynomialQ[numerator, transverseK]];
  division = PolynomialReduce[numerator, {transverseConstraint}, {transverseK}];
  remainder = Last[division];
  If[Factor[Together[numerator - First[First[division]] transverseConstraint - remainder]] =!= 0,
    Print["RECONSTRUCTION_INPUT ", InputForm[{rational, transverseConstraint, division,
      Factor[Together[numerator - First[First[division]] transverseConstraint - remainder]]}]]];
  gate["exact transverse reconstruction", Factor[Together[numerator - First[First[division]] transverseConstraint - remainder]] === 0];
  Factor[remainder/denominator]];
pVector = Factor[pTrial /. frameSolution]; qVector = qTrial;
kVector = Factor[{ek, transverseK, 0, kz} /. frameSolution];
recoilVector = pVector + qVector - kVector;
outZ = Factor[Rest[kVector]/First[kVector]];
outY = {0, 1, 0}; outX = Factor[Cross[outY, outZ]];
frame = <|p -> pVector, q -> qVector, k1 -> kVector, k2 -> recoilVector,
  eL -> {1, 0, 0, 0}, eX -> {0, 1, 0, 0}, eY -> {0, 0, 1, 0}, eZ -> {0, 0, 0, 1},
  eOutX -> Prepend[outX, 0], eOutY -> Prepend[outY, 0]|>;
coordinates[expr_] := If[KeyExistsQ[frame, expr], frame[expr],
  Factor[Total[(Coefficient[expr, #] frame[#]) & /@ Keys[frame]]]];
gate["outgoing spin axes", zeroQ[algebraicReduce[{dot4[frame[eOutX], frame[k1]],
  dot4[frame[eOutY], frame[k1]], dot4[frame[eOutX], frame[eOutY]],
  dot4[frame[eOutX], frame[eOutX]] + 1, dot4[frame[eOutY], frame[eOutY]] + 1}]]];
FCClearScalarProducts[];
Do[With[{a = aKey, b = bKey, value = algebraicReduce[dot4[frame[aKey], frame[bKey]]]},
  SP[a, b] = value; SPD[a, b] = value], {aKey, Keys[frame]}, {bKey, Keys[frame]}];

(* Calibrate the Levi-Civita orientation against the defining gamma matrices. *)
pauli = basis["PauliMatrices"];
z2 = ConstantArray[0, Dimensions[First[pauli]]];
g0 = ArrayFlatten[{{First[pauli], z2}, {z2, -First[pauli]}}];
gamma = Prepend[Table[ArrayFlatten[{{z2, pauli[[i + 1]]}, {-pauli[[i + 1]], z2}}], {i, 3}], g0];
g5 = I (Dot @@ gamma);
matrixSlashes = Total[MapThread[Times, {metric.#, gamma}]] & /@ (frame /@ {eL, eX, eY, eZ});
matrixTrace = Tr[g5.(Dot @@ matrixSlashes)];
nativeTrace = DiracSimplify[DiracTrace[GA[5].GS[eL].GS[eX].GS[eY].GS[eZ]], DiracTraceEvaluate -> True];
epsilonRule = HoldPattern[Eps[Momentum[a_], Momentum[b_], Momentum[c_], Momentum[d_]]] :>
  epsilonUnit Det[coordinates /@ {a, b, c, d}];
epsilonSolution = Solve[(nativeTrace /. epsilonRule) == matrixTrace, epsilonUnit];
gate["native epsilon orientation determined", Length[epsilonSolution] === 1];
epsilonUnit = epsilonUnit /. First[epsilonSolution];
gate["epsilon orientation is a sign", MemberQ[{-1, 1}, epsilonUnit]];
reduceScalar[expr_] := Module[{value},
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[expr]]]];
  value = algebraicReduce[value /. epsilonRule];
  gate["scalar contraction resolved", FreeQ[value, _Pair | _Eps | _Spinor | _DiracGamma |
    _DiracTrace | _LorentzIndex | _Polarization | _SUNTF | _SUNTrace | _FeynAmpDenominator]];
  value];

spinNumerator[mom_, variables_, axes_] := FCI[Total[MapThread[Times,
  {variables, basis["QuarkSpinNumerators"] /. {spinMomentum -> mom, spinX -> axes[[1]], spinY -> axes[[2]]}}]]];
quarkIn = spinNumerator[p, inVariables, {eX, eY}];
quarkOut = spinNumerator[k1, outVariables, {eOutX, eOutY}];
gluonVariables = If[incomingQuark, outVariables, inVariables];
gluonAxes = If[incomingQuark, {eOutX, eOutY}, {eX, eY}];
gluonStokes = Total[MapThread[Times, {gluonVariables,
  (#[[{2, 3}, {2, 3}]] &) /@ basis["GluonStokesTensorsCanonical"]}]];
(* Outgoing amplitudes contain epsilon-star; the analyzer reverses the dyad indices. *)
If[incomingQuark, gluonStokes = Transpose[gluonStokes]];
gluonDensity = Sum[gluonStokes[[i, j]] FV[gluonAxes[[i]], alpha] FV[gluonAxes[[j]], beta],
  {i, Length[gluonAxes]}, {j, Length[gluonAxes]}];

buildTensor[ward_] := Module[{amp = amplitude, a, b, value},
  If[ward, amp = amp /. Polarization[gluonMomentum, __] -> gluonMomentum];
  a = amp /. Momentum[Polarization[q, __]] -> LorentzIndex[mu];
  b = amp /. Momentum[Polarization[q, __]] -> LorentzIndex[nu];
  If[!ward && gluonMomentum =!= k2,
    a = a /. Momentum[Polarization[gluonMomentum, __]] -> LorentzIndex[alpha];
    b = b /. Momentum[Polarization[gluonMomentum, __]] -> LorentzIndex[beta]];
  value = FermionSpinSum[a ComplexConjugate[b], Head -> keptSpinSum,
    DotSimplify -> False, FCTraceFactor -> False];
  value = value /. keptSpinSum[DiracGamma[Momentum[mom_]]] :>
    Which[mom === p && incomingQuark, quarkIn, mom === k1 && outgoingQuark, quarkOut, True, GS[mom]];
  gate["all fermion completeness factors replaced", FreeQ[value, keptSpinSum | _Spinor]];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[!ward, If[gluonMomentum === k2,
    value = DoPolarizationSums[value, k2, p], value = value gluonDensity]];
  Print["TRACE_BEGIN ", channel, " ward=", ward, " bytes=", ByteCount[value]];
  value = Contract[DiracSimplify[DotSimplify[value], DiracTraceEvaluate -> True]];
  Print["TRACE_END ", channel, " ward=", ward, " bytes=", ByteCount[value]];
  value/(incomingNormalization chargeSquared)];

tensor = bounded[buildTensor[False], "Born tensor"];
photonSymbols = {eL, eX, eY};
photonMatrix = Table[Print["PHOTON_COMPONENT ", a, " ", b];
  bounded[reduceScalar[tensor FV[photonSymbols[[a]], mu] FV[photonSymbols[[b]], nu]], {a, b}],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
gate["photon Hermiticity", zeroQ[algebraicReduce[ComplexExpand[photonMatrix - ConjugateTranspose[photonMatrix]]]]];
photonWard = bounded[reduceScalar[tensor FV[q, mu] FV[q, nu]], "photon Ward"];
gate["photon Ward identity", photonWard === 0];
gluonWardTensor = bounded[buildTensor[True], "gluon Ward tensor"];
gluonWard = bounded[reduceScalar[gluonWardTensor Total[FV[#, mu] FV[#, nu] & /@ photonSymbols]], "gluon Ward"];
gate["gluon Ward identity", gluonWard === 0];
photonCoefficients = algebraicReduce[Tr[#.photonMatrix]] & /@ basis["PhotonDual"];
gate["photon reconstruction", zeroQ[algebraicReduce[photonMatrix -
  Total[MapThread[Times, {photonCoefficients, basis["PhotonBasis"]}]]]]];
coefficient[expr_, vars_, index_] := If[index === 1, expr /. Thread[Rest[vars] -> 0],
  Coefficient[Expand[expr], vars[[index]], 1] /. Thread[DeleteCases[Rest[vars], vars[[index]]] -> 0]];
response = Table[algebraicReduce[coefficient[coefficient[photonCoefficients[[a]], inVariables, i], outVariables, j]],
  {a, Length[photonCoefficients]}, {j, Length[outVariables]}, {i, Length[inVariables]}];
gate["spin response reconstruction", zeroQ[algebraicReduce[photonCoefficients - Table[
  Sum[outVariables[[j]] inVariables[[i]] response[[a, j, i]],
    {j, Length[outVariables]}, {i, Length[inVariables]}], {a, Length[photonCoefficients]}]]]];
unpolarizedMatrix = photonMatrix /. Thread[Join[Rest[inVariables], Rest[outVariables]] -> 0];
pg = algebraicReduce[Tr[basis["PhotonMetric"].unpolarizedMatrix]];
photonFrameMatrix = Transpose[frame /@ Append[photonSymbols, q]];
gate["photon frame is nonsingular", simplify[Det[photonFrameMatrix] != 0]];
pExpansion = LinearSolve[photonFrameMatrix, frame[p]];
gate["incoming momentum projection reconstructs", zeroQ[algebraicReduce[
  photonFrameMatrix.pExpansion - frame[p]]]];
pComponents = Take[pExpansion, Length[photonSymbols]];
pp = algebraicReduce[pComponents.unpolarizedMatrix.pComponents];
gate["reference Born Pg", algebraicReduce[pg - (reference["BornPg"] /. {D -> 4, Q2 -> Q^2})] === 0];
gate["reference Born Ppp", algebraicReduce[pp - (reference["BornPpp"] /. {D -> 4, Q2 -> Q^2})] === 0];
result = <|"Schema" -> "polarized-sidis-born-response-v1", "Channel" -> channel,
  "PhotonLabels" -> basis["PhotonLabels"], "SpinLabels" -> basis["SpinLabels"],
  "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"},
  "Response" -> (response /. transverseRule), "PhotonMatrix" -> (photonMatrix /. transverseRule),
  "Frame" -> (frame /. transverseRule), "AlgebraicResponse" -> response,
  "TransverseSubstitution" -> transverseRule, "TransverseConstraint" -> transverseConstraint,
  "FrameSolution" -> frameSolution, "PhysicalRegion" -> $Assumptions,
  "ReferenceBornPg" -> pg, "ReferenceBornPpp" -> pp,
  "CouplingsRemoved" -> "e_q^2 g_s^2", "PhaseSpaceIncluded" -> False,
  "Dimension" -> 4, "NLOEpsilonTermsIncluded" -> False, "FiniteNLOFHatsComputed" -> False,
  "IncomingNormalization" -> incomingNormalization, "ModelChargeSquared" -> chargeSquared,
  "EpsilonOrientation" -> epsilonUnit, "Checks" -> checks,
  "SourceHash" -> FileHash[sourcePath, "SHA256"],
  "InputHashes" -> <|"Amplitudes" -> FileHash[ampPath, "SHA256"],
    "SpinBasis" -> FileHash[basisPath, "SHA256"], "UnpolarizedReference" -> FileHash[referencePath, "SHA256"]|>,
  "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "WolframVersion" -> $Version,
  "FeynCalcVersion" -> $FeynCalcVersion|>;
resultDir = FileNameJoin[{root, "cache", "s03_exact", channel}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
Put[result, FileNameJoin[{resultDir, "s03_result.wl.tmp"}]];
RenameFile[FileNameJoin[{resultDir, "s03_result.wl.tmp"}], FileNameJoin[{resultDir, "s03_result.wl"}], OverwriteTarget -> True];
Export[FileNameJoin[{resultDir, "s03_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "response_dimensions" -> Dimensions[response], "nonzero_components" -> Count[Flatten[response], Except[0]],
  "phase_space_included" -> False, "finite_nlo_fhats_computed" -> False,
  "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s03_born_spin_response_exact"];
Quit[0];

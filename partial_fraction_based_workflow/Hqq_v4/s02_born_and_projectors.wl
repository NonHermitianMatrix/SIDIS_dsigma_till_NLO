(* Born contractions, model charge, initial averages, invariant maps and Eq. 9 projectors. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, reduce, atomicPut, setKinematics, dot, bornContraction];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 1800,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3, Print["Memory limit: ", label]; Quit[3]];
reduce[value_] := Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[
  Contract[DiracSimplify[value, DiracTraceEvaluate -> True]]]]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
bornInputs = <|"Hqq" -> "Born", "AuxHgq" -> "AuxHgqBorn", "AuxHqg" -> "AuxHqgBorn"|>;
gate["S01 source identity", generated["SourceHash"] === FileHash[FileNameJoin[{root, "s01_generate_amplitudes.wl"}], "SHA256"]];

fundamentalDimension = SUNSimplify[SUNFDelta[ci, ci], SUNNToCACF -> False];
adjointDimension = SUNSimplify[SUNDelta[aa, aa], SUNNToCACF -> False];
generatorTrace = SUNSimplify[SUNTrace[SUNT[aa, aa]], SUNNToCACF -> False];
colors = <|"CF" -> Factor[generatorTrace/fundamentalDimension],
  "TF" -> Factor[generatorTrace/adjointDimension],
  "CA" -> Factor[SUNSimplify[SUNF[aa, bb, cc] SUNF[aa, bb, cc], SUNNToCACF -> False]/adjointDimension]|>;

(* Compare the generated photon vertex with the defining unit-charge vector current. *)
FCClearScalarProducts[];
SPD[k1, k1] = 0; SPD[k2, k2] = 0; SPD[k1, k2] = kappa;
vertex = Total[generated["ChargeVertex"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
vertexSquare = FermionSpinSum[vertex ComplexConjugate[vertex]];
vertexSquare = SUNSimplify[vertexSquare, Explicit -> True, SUNNToCACF -> False];
vertexSquare = reduce[-DoPolarizationSums[vertexSquare, q, 0, VirtualBoson -> True]];
unitCurrentSquare = reduce[MTD[mu, nu] DiracTrace[GSD[k1].GAD[mu].GSD[k2].GAD[nu]] fundamentalDimension];
chargeSquared = Factor[vertexSquare/unitCurrentSquare];
Print["Charge measurement: ", InputForm[<|"VertexSquare" -> vertexSquare,
  "UnitCurrentSquare" -> unitCurrentSquare, "Ratio" -> chargeSquared,
  "FundamentalDimension" -> fundamentalDimension|>]];
gate["model charge is a positive exact constant", TrueQ[chargeSquared > 0] &&
  FreeQ[chargeSquared, kappa | D | SUNN | _Real | _Pair | _Spinor | _DiracTrace | _SMP]];
Print["Measured model charge squared = ", InputForm[chargeSquared]];
otherVertex = Total[generated["OtherChargeVertex"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
gate["two generated normalization vertices coincide including sign",
  Factor[otherVertex - vertex] === 0];

(* Derive the spin count from the idempotent positive-energy Dirac projector. *)
SPD[restMomentum, restMomentum] = mass^2;
spinNumerator = GSD[restMomentum] + mass;
spinNormalization = Factor[
  reduce[DiracTrace[spinNumerator.spinNumerator]]/reduce[DiracTrace[spinNumerator]]];
spinProjector = spinNumerator/spinNormalization;
gate["quark spin projector is idempotent",
  DiracSimplify[spinProjector.spinProjector - spinProjector] === 0];
quarkSpinCount = reduce[DiracTrace[spinProjector]];
gate["quark spin count is a positive exact constant",
  TrueQ[quarkSpinCount > 0] && FreeQ[quarkSpinCount, mass | D | _Real | _DiracTrace | _DiracGamma]];
Print["Derived quark spin count = ", InputForm[quarkSpinCount]];
SPD[p, p] = 0; SPD[n, n] = 0;
gluonSpinCount = Factor[Contract[-MTD[mu, nu] PolarizationSum[mu, nu, p, n, Dimension -> D]]];
gate["physical gluon polarization trace evaluated", FreeQ[gluonSpinCount, _Pair | _PolarizationSum | p | n]];
initialStateCounts = <|quark -> quarkSpinCount fundamentalDimension,
  gluon -> gluonSpinCount adjointDimension|>;
initialAverages = Association@Table[label ->
  Factor[1/initialStateCounts[Last[generated["IncomingSpecies"][bornInputs[label]]]]],
  {label, Keys[bornInputs]}];
gate["all initial-state averages determined", FreeQ[initialAverages, _Missing]];
Print["Derived initial averages = ", InputForm[initialAverages]];

setKinematics[isReal_] := Module[{basis, gram, unknowns, remainder, equations, relations, solution, momenta, rows},
  FCClearScalarProducts[];
  If[isReal,
    basis = {p, q, k1, k2};
    gram = {{0, pq, pk1, pk2}, {pq, -Q2, qk1, qk2}, {pk1, qk1, 0, k1k2}, {pk2, qk2, k1k2, 0}};
    unknowns = {pq, pk1, pk2, qk1, qk2, k1k2}; remainder = p + q - k1 - k2,
    basis = {p, q, k1}; gram = {{0, pq, pk1}, {pq, -Q2, qk1}, {pk1, qk1, 0}};
    unknowns = {pq, pk1, qk1}; remainder = p + q - k1];
  dot[v_, w_] := Expand[(Coefficient[v, #] & /@ basis).gram.(Coefficient[w, #] & /@ basis)];
  equations = {dot[p + q, p + q] == s, dot[q - k1, q - k1] == t, dot[remainder, remainder] == 0};
  If[isReal, equations = Join[equations, {dot[p + q - k1, p + q - k1] == s23,
    dot[k1 + k2, k1 + k2] == a12, dot[p - remainder, p - remainder] == u3}]];
  relations = equations /. Equal -> Subtract;
  solution = First[Solve[equations, unknowns]];
  gate["invariant equations reconstruct exactly", And @@ Thread[(Factor /@ (relations /. solution)) == 0]];
  momenta = If[isReal, {p, q, k1, k2, k3}, {p, q, k1, k2}];
  rows = Flatten[Table[{momenta[[i]], momenta[[j]],
    Factor[dot[momenta[[i]] /. If[isReal, k3 -> remainder, k2 -> remainder],
      momenta[[j]] /. If[isReal, k3 -> remainder, k2 -> remainder]] /. solution]},
    {i, Length[momenta]}, {j, i, Length[momenta]}], 1];
  Scan[Function[row, With[{v = row[[1]], w = row[[2]], val = row[[3]]}, SPD[v, w] = val; SP[v, w] = val]], rows];
  rows];

bornScalarProducts = setKinematics[False];
bornContraction[label_, mode_] := Module[{entry, amplitude, a, b, gl, gluons, reference, value, finalSpecies, observed, weight},
  entry = bornInputs[label];
  amplitude = Total[generated[entry]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
  gluons = Pick[Join[generated["Requests"][entry]["IncomingMomenta"],
    generated["Requests"][entry]["OutgoingMomenta"]],
    Join[generated["IncomingSpecies"][entry], generated["OutgoingSpecies"][entry]], gluon];
  gate[label <> " has one generated gluon leg", Length[gluons] === Length[{gluon}]];
  gl = First[gluons]; reference = If[gl === p, k1, p];
  a = amplitude; b = amplitude;
  Switch[mode,
    "Ppp", a = a /. Polarization[q, ___] -> p; b = b /. Polarization[q, ___] -> p,
    "PhotonWard", a = a /. Polarization[q, ___] -> q; b = b /. Polarization[q, ___] -> q,
    "GluonWard", a = a /. Polarization[gl, ___] -> gl; b = b /. Polarization[gl, ___] -> gl];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverages[label]];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[MemberQ[{"Pg", "GluonWard"}, mode], value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  If[mode =!= "GluonWard", value = DoPolarizationSums[value, gl, reference]];
  finalSpecies = generated["OutgoingSpecies"][entry];
  observed = First[finalSpecies];
  weight = Count[finalSpecies, observed]/Times @@ (Factorial /@ Values[Counts[finalSpecies]]);
  value = reduce[weight value/chargeSquared];
  gate[label <> " " <> mode <> " is scalar and exact", FreeQ[value,
    _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Pair | _Polarization | _Real]];
  If[StringContainsQ[mode, "Ward"], gate[label <> " " <> mode, value === 0]];
  value];
bornResults = Association@Table[label -> Association@Table[
  Print[label, " Born ", mode];
  mode -> bounded[bornContraction[label, mode], {label, mode}],
  {mode, {"Pg", "Ppp", "PhotonWard", "GluonWard"}}], {label, Keys[bornInputs]}];

(* Derive the structure-function extraction from the tensor definition. *)
uBorn = ExpandScalarProduct[SPD[p - k1]];
kinematics = First[Solve[{s == Q2 (1/xh - 1), t == -Q2 (1 - zh) - zh qT2,
  uBorn == -Q2 zh/xh}, {xh, zh, qT2}]];
transverseP = FVD[p, mu] - FVD[q, mu] SPD[p, q]/SPD[q, q];
transversePNu = FVD[p, nu] - FVD[q, nu] SPD[p, q]/SPD[q, q];
tensor = (-MTD[mu, nu] + FVD[q, mu] FVD[q, nu]/SPD[q, q]) f1 + transverseP transversePNu f2/SPD[p, q];
tensorG = Factor[Contract[MTD[mu, nu] tensor]];
tensorPP = Factor[Contract[FVD[p, mu] FVD[p, nu] tensor]];
projectors = First[Solve[{tensorG == hg, tensorPP == hpp}, {f1, f2}]];
paperProjectors = {f1 -> (-hg/2 + 2 xh^2 hpp/Q2)/(1 - eps),
  f2 -> (-xh hg + (3 - 2 eps) 4 xh^3 hpp/Q2)/(1 - eps)};
gate["derived projectors equal paper Eq. 9", And @@ Thread[Factor[
  ({f1, f2} /. projectors /. {D -> 4 - 2 eps, s -> Q2 (1/xh - 1)}) -
  ({f1, f2} /. paperProjectors)] == 0]];
realScalarProducts = setKinematics[True];
result = <|"BornPg" -> bornResults["Hqq"]["Pg"], "BornPpp" -> bornResults["Hqq"]["Ppp"],
  "AuxHgqBorn" -> KeyTake[bornResults["AuxHgq"], {"Pg", "Ppp"}],
  "AuxHqgBorn" -> KeyTake[bornResults["AuxHqg"], {"Pg", "Ppp"}],
  "BornInputs" -> bornInputs, "BornChecks" -> bornResults,
  "ModelChargeSquared" -> chargeSquared, "ColorConstants" -> colors,
  "FundamentalDimension" -> fundamentalDimension, "AdjointDimension" -> adjointDimension,
  "GluonSpinCount" -> gluonSpinCount, "QuarkSpinCount" -> quarkSpinCount,
  "SpinProjectorNormalization" -> spinNormalization, "InitialAverages" -> initialAverages,
  "BornScalarProducts" -> bornScalarProducts, "RealScalarProducts" -> realScalarProducts,
  "BornKinematics" -> kinematics, "BornU" -> uBorn,
  "ProjectorsD" -> projectors, "ProjectorsEpsilon" -> paperProjectors,
  "Dimension" -> D, "CouplingsRemoved" -> "eq^2 gs^2", "AuthorsCoefficientsUsed" -> False,
  "InputHashes" -> <|"s01_result.wl" -> FileHash[FileNameJoin[{root, "s01_result.wl"}], "SHA256"]|>,
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>;
atomicPut[result, FileNameJoin[{root, "s02_result.wl"}]];
Print["Hqq Born Pg = ", InputForm[result["BornPg"]]];
Print["Hqq Born Ppp = ", InputForm[result["BornPpp"]]];
Print["S02_SUCCESS; peak kernel memory = ", MaxMemoryUsed[]];
Quit[];


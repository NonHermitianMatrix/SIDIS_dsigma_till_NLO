(* Independent, pairwise physical-polarization contraction of gamma* q -> g q g. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, setKinematics, dot, scalarPair, bounded, cachedPair];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label, "; earlier checkpoints are retained."]; Quit[3]];
gate["amplitude and Born inputs exist", And @@ (FileExistsQ[FileNameJoin[{root, #}]] & /@
 {"s02_result.wl", "s04_result.wl"})];
raw = Get[FileNameJoin[{root, "s04_result.wl"}]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
bornAmplitudes = raw["Born"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
realAmplitudes = raw["Real"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
cache = FileNameJoin[{root, "s05_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
inputHash = Hash[{FileHash[FileNameJoin[{root, "s04_result.wl"}], "SHA256"],
                  FileHash[$InputFileName, "SHA256"]}, "SHA256"];

(* All scalar products follow from invariant definitions and momentum conservation. *)
setKinematics[isReal_] := Module[{basis, gram, unknowns, remainder, equations, solution, momenta, rows},
 FCClearScalarProducts[];
 If[isReal,
  basis = {p, q, k1, k2};
  gram = {{0, pq, pk1, pk2}, {pq, -Q2, qk1, qk2},
          {pk1, qk1, 0, k1k2}, {pk2, qk2, k1k2, 0}};
  unknowns = {pq, pk1, pk2, qk1, qk2, k1k2};
  remainder = p + q - k1 - k2,
  basis = {p, q, k1};
  gram = {{0, pq, pk1}, {pq, -Q2, qk1}, {pk1, qk1, 0}};
  unknowns = {pq, pk1, qk1};
  remainder = p + q - k1];
 dot[v_, w_] := Expand[(Coefficient[v, #] & /@ basis).gram.(Coefficient[w, #] & /@ basis)];
 equations = {dot[p + q, p + q] == s, dot[q - k1, q - k1] == t, dot[remainder, remainder] == 0};
 If[isReal, equations = Join[equations, {
    dot[p + q - k1, p + q - k1] == s23,
    dot[k1 + k2, k1 + k2] == a12, dot[p - remainder, p - remainder] == u3}]];
 solution = First[Solve[equations, unknowns]];
 momenta = If[isReal, {p, q, k1, k2, k3}, {p, q, k1, k2}];
 rows = Flatten[Table[{momenta[[i]], momenta[[j]],
    Factor[dot[momenta[[i]] /. If[isReal, k3 -> remainder, k2 -> remainder],
               momenta[[j]] /. If[isReal, k3 -> remainder, k2 -> remainder]] /. solution]},
   {i, Length[momenta]}, {j, i, Length[momenta]}], 1];
 Scan[Function[row, With[{v = row[[1]], w = row[[2]], val = row[[3]]}, SPD[v, w] = val; SP[v, w] = val]], rows];
 rows];

scalarPair[left_, right_, mode_, gluons_] := Module[{a = left, b = right, expression},
 Switch[mode,
  "Ppp", a = a /. Polarization[q, ___] -> p; b = b /. Polarization[q, ___] -> p,
  "PhotonWard", a = a /. Polarization[q, ___] -> q; b = b /. Polarization[q, ___] -> q,
  "Gluon1Ward", a = a /. Polarization[k1, ___] -> k1; b = b /. Polarization[k1, ___] -> k1,
  "Gluon3Ward", a = a /. Polarization[k3, ___] -> k3; b = b /. Polarization[k3, ___] -> k3];
 expression = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> 1/(2 SUNN)];
 expression = SUNSimplify[expression, Explicit -> True, SUNNToCACF -> False];
 If[MemberQ[{"Pg", "Gluon1Ward", "Gluon3Ward"}, mode],
   expression = -DoPolarizationSums[expression, q, 0, VirtualBoson -> True]];
 Do[If[!((mode == "Gluon1Ward" && momentum === k1) ||
          (mode == "Gluon3Ward" && momentum === k3)),
   expression = DoPolarizationSums[expression, momentum, p]], {momentum, gluons}];
 expression = DiracSimplify[expression, DiracTraceEvaluate -> True] // Contract;
 expression = expression // FeynAmpDenominatorExplicit // ExpandScalarProduct;
 Factor[expression]];

bornScalarProducts = setKinematics[False];
bornComputed = Table[bounded[scalarPair[Total[bornAmplitudes], Total[bornAmplitudes], mode, {k1}], mode],
                     {mode, {"Pg", "Ppp"}}];
ratios = Factor /@ (bornComputed/{born["BornPg"], born["BornPpp"]});
gate["FeynArts Born agrees with the independently constructed current", SameQ @@ ratios &&
 FreeQ[ratios, s | t | Q2 | D | SUNN | _Pair | _DiracTrace | _Spinor]];
chargeSquared = First[ratios];
gate["model charge normalization is a positive exact constant", TrueQ[chargeSquared > 0] && FreeQ[chargeSquared, _Real]];
Print["Model charge squared = ", InputForm[chargeSquared]];

realScalarProducts = setKinematics[True];
(* Labeled diagrams; sum over the two possible gluon tags and divide by 2!. *)
finalSpecies = {gluon, quark, gluon};
tagWeight = Count[finalSpecies, gluon]/Times @@ (Factorial /@ Values[Counts[finalSpecies]]);
Print["Measured tagged phase-space weight = ", tagWeight];
cachedPair[mode_, i_, j_] := Module[{file, saved, value},
 file = FileNameJoin[{cache, mode <> "_" <> IntegerString[i, 10, 2] <> "_" <> IntegerString[j, 10, 2] <> ".wl"}];
 If[FileExistsQ[file], saved = Get[file]; If[AssociationQ[saved] && saved["InputHash"] === inputHash, Return[saved["Value"]]]];
 Print[mode, " pair ", i, ",", j, "; memory = ", MemoryInUse[], " bytes."];
 value = bounded[scalarPair[realAmplitudes[[i]], realAmplitudes[[j]], mode, {k1, k3}], {mode, i, j}];
 If[i != j, value = Factor[ComplexExpand[value + Conjugate[value]]]];
 value = Factor[tagWeight value/chargeSquared];
 If[AssociationQ[saved], gate["reordered contraction equals saved pair", Factor[value - saved["Value"]] === 0]];
 gate["pair is a scalar rational expression", FreeQ[value,
  _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Pair | _Polarization | _Real]];
 Put[<|"InputHash" -> inputHash, "Value" -> value|>, file];
 value];

results = <||>;
Do[
 pairs = Flatten[Table[cachedPair[mode, i, j], {i, Length[realAmplitudes]}, {j, i, Length[realAmplitudes]}]];
 Print[mode, ": combining checkpointed pairs."];
 value = bounded[Factor[Total[pairs]], mode <> " sum"];
 If[StringContainsQ[mode, "Ward"], gate[mode, value === 0]];
 Put[value, FileNameJoin[{root, "s05_" <> mode <> ".wl"}]];
 AssociateTo[results, mode -> value];
 Print[mode, " complete; leaves = ", LeafCount[value]],
 {mode, {"Pg", "Ppp", "PhotonWard", "Gluon1Ward", "Gluon3Ward"}}];
Put[<|"Contractions" -> results, "BornScalarProducts" -> bornScalarProducts,
 "RealScalarProducts" -> realScalarProducts, "ModelChargeSquared" -> chargeSquared,
 "TagWeight" -> tagWeight, "Inputs" -> "s02 independent current and s04 generated amplitudes",
 "CouplingsRemoved" -> "eq^2 gs^4", "Dimension" -> D|>, FileNameJoin[{root, "s05_result.wl"}]];
Print["Wrote s05_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

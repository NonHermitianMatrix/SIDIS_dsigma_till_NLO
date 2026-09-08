(* Born gamma*(q) + q(p) -> g(k1) + q(k2), and the paper's projectors. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, reduce];
gate[name_, value_] := If[TrueQ[value], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
reduce[expr_] := Factor[Contract[DiracSimplify[expr, DiracTraceEvaluate -> True]]];

(* Solve scalar products from the invariant definitions, not a stored Born. *)
FCClearScalarProducts[];
invariants = First[Solve[{
  2 pq - Q2 == s, -Q2 - 2 qk == t, -2 pk == u,
  -Q2 + 2 pq - 2 pk - 2 qk == 0
}, {pq, qk, pk, u}]];
SPD[p, p] = 0; SPD[q, q] = -Q2; SPD[k1, k1] = 0;
SPD[p, q] = pq /. invariants;
SPD[q, k1] = qk /. invariants;
SPD[p, k1] = pk /. invariants;
Print["Born scalar products established."];

(* Two QCD Compton graphs, with e_q g_s removed. *)
current[ph_, gl_] := GAD[gl].GSD[p + q].GAD[ph]/s +
                     GAD[ph].GSD[p - k1].GAD[gl]/(u /. invariants);
conjugateCurrent[ph_, gl_] := GAD[ph].GSD[p + q].GAD[gl]/s +
                              GAD[gl].GSD[p - k1].GAD[ph]/(u /. invariants);
color = SUNSimplify[SUNTrace[SUNT[ca, ca]], SUNNToCACF -> False]/SUNN // Factor;
spinAverage = 1/2;
trace = DiracTrace[GSD[p + q - k1].current[muIndex, aIndex].GSD[p].conjugateCurrent[nuIndex, bIndex]];
pg = reduce[-MTD[aIndex, bIndex] MTD[muIndex, nuIndex] trace color spinAverage];
pp = reduce[-MTD[aIndex, bIndex] FVD[p, muIndex] FVD[p, nuIndex] trace color spinAverage];
photonWard = reduce[-MTD[aIndex, bIndex] FVD[q, muIndex] FVD[q, nuIndex] trace];
gluonWard = reduce[MTD[muIndex, nuIndex] FVD[k1, aIndex] FVD[k1, bIndex] trace];
gate["photon Ward identity", photonWard === 0];
gate["gluon Ward identity", gluonWard === 0];

(* Recover xhat, zhat, qT^2 from paper Eqs. (25)-(27). *)
kinematics = First[Solve[{
 s == Q2 (1/xh - 1), t == -Q2 (1 - zh) - zh qT2,
 (u /. invariants) == -Q2 zh/xh
}, {xh, zh, qT2}]];

(* Contract Eq. (16), then solve for Fhat_1 and Fhat_2. *)
transverseP = FVD[p, muIndex] - FVD[q, muIndex] SPD[p, q]/SPD[q, q];
transversePNu = FVD[p, nuIndex] - FVD[q, nuIndex] SPD[p, q]/SPD[q, q];
tensor = (-MTD[muIndex, nuIndex] + FVD[q, muIndex] FVD[q, nuIndex]/SPD[q, q]) f1 +
         transverseP transversePNu f2/SPD[p, q];
tensorG = Factor[Contract[MTD[muIndex, nuIndex] tensor]];
tensorPP = Factor[Contract[FVD[p, muIndex] FVD[p, nuIndex] tensor]];
projectors = First[Solve[{tensorG == hg, tensorPP == hpp}, {f1, f2}]];
projectorPaper = {
 f1 -> (-hg/2 + 2 xh^2 hpp/Q2)/(1 - eps),
 f2 -> (-xh hg + (3 - 2 eps) 4 xh^3 hpp/Q2)/(1 - eps)
};
gate["derived projectors equal paper Eq. (9)",
 And @@ Thread[Factor[({f1, f2} /. projectors /. {D -> 4 - 2 eps, s -> Q2 (1/xh - 1)}) -
                        ({f1, f2} /. projectorPaper)] == 0]];
result = <|"ColorAverage" -> color, "BornPg" -> pg, "BornPpp" -> pp,
 "BornKinematics" -> kinematics, "BornInvariants" -> invariants,
 "ProjectorsD" -> projectors, "ProjectorsEpsilon" -> projectorPaper,
 "Inputs" -> "QCD tree vertices, paper invariant definitions and tensor decomposition; no authors coefficient input",
 "Checks" -> <|"PhotonWard" -> photonWard, "GluonWard" -> gluonWard|>|>;
Put[result, FileNameJoin[{root, "s02_result.wl"}]];
Print["BornPg = ", InputForm[pg]];
Print["BornPpp = ", InputForm[pp]];
Print["ProjectorsD = ", InputForm[projectors]];
Print["Wrote s02_result.wl; peak kernel memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

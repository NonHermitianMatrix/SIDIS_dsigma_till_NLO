dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"];
ev = -15/100;
pt = {s -> 5, t -> -3/2, Q2 -> 1, sig -> 7/10, eps -> ev, Nc -> 3, gs -> 1, eq -> 1};
uval = (sig - s - t - Q2) /. pt;
s23e = sig; sq = Sqrt[s23e]; p0 = (s23e - t)/(2 sq); k10 = (s - s23e)/(2 sq);
cpk = 1 + u/(2 p0 k10); sOf[c_] := Sqrt[1 - c^2];
dot4[a_, b_] := a[[1]] b[[1]] - a[[2]] b[[2]] - a[[3]] b[[3]];
K23 = {sq, 0, 0}; k2v = (sq/2) {1, s1 cb2, c1};
k1x = k10 {1, 0, 1}; px = p0 {1, sOf[cpk], cpk}; qx = k1x + K23 - px;
t2A = -Q2 - 2 dot4[qx, k2v]; u2A = -2 dot4[px, k2v];
M = (s02["Mg"] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
ig = M /. {t2 -> t2A, u2 -> u2A} /. pt /. u -> uval;
ig = ig /. {s1 -> Sin[B1], c1 -> Cos[B1], cb2 -> Cos[B2]};
ig = ig Sin[B1]^(1 - 2 ev) Sin[B2]^(-2 ev);
f = Function[{B1, B2}, Evaluate[N[ig]]];
Do[Print["  f(", p[[1]], ",", p[[2]], ") = ", Quiet@Check[f @@ N[p], "ERROR"]],
 {p, {{1., 1.}, {0.5, 2.0}, {0.01, 1.0}, {3.13, 1.0}, {1.0, 0.01}, {1.0, 3.13},
      {0.001, 0.001}, {2.0, 2.5}}}];
Print["--- is it ever complex? ---"];
Print["  Im at (0.5,2.0): ", Im[f[0.5, 2.0]]];
Print["--- 1D slice integral (b2 only, b1=1.0) ---"];
Print["  ", Quiet@NIntegrate[f[1.0, y], {y, 0, Pi}, PrecisionGoal -> 4]];
Print["--- small 2D box away from edges ---"];
Print["  ", Quiet@NIntegrate[f[x, y], {x, 0.5, 2.5}, {y, 0.5, 2.5}, PrecisionGoal -> 4]];
Print["T12DONE"];

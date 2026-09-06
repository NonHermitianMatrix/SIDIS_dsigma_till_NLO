dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"]; s04 = Get[dir <> "s04_result.m"];
ev = -15/100;
pt = {s -> 5, t -> -3/2, Q2 -> 1, sig -> 7/10, eps -> ev, Nc -> 3, gs -> 1, eq -> 1};
uval = (sig - s - t - Q2) /. pt;
s23e = sig; sq = Sqrt[s23e]; p0 = (s23e - t)/(2 sq); k10 = (s - s23e)/(2 sq);
cpk = 1 + u/(2 p0 k10); sOf[c_] := Sqrt[1 - c^2];
dot4[a_, b_] := a[[1]] b[[1]] - a[[2]] b[[2]] - a[[3]] b[[3]];
K23 = {sq, 0, 0}; k2v = (sq/2) {1, s1 cb2, c1};
k1x = k10 {1, 0, 1}; px = p0 {1, sOf[cpk], cpk}; qx = k1x + K23 - px;
t2A = -Q2 - 2 dot4[qx, k2v]; u2A = -2 dot4[px, k2v];
pfRaw = s04["dPi3"]/(2 Pi)^4;
run[proj_] := Module[{},
  lhs = N[((s04[proj]/pfRaw) /. u -> sig - s - t - Q2 /. SUNN -> Nc /. pt
           /. MISSINGEPS[__] -> 0), 16];
  M = (s02[If[proj === "Wg3", "Mg", "Mpp"]] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
  ig = M /. {t2 -> t2A, u2 -> u2A} /. pt /. u -> uval;
  ig = ig /. {s1 -> Sin[B1], c1 -> Cos[B1], cb2 -> Cos[B2]};
  ig = ig Sin[B1]^(1 - 2 ev) Sin[B2]^(-2 ev);
  f = Function[{B1, B2}, Evaluate[N[ig]]];
  Print["=== ", proj, " ==="];
  Print["  f near b1=Pi : ", Quiet@Check[f[3.14159, 1.0], "ERR"],
        "   f at b1=Pi  : ", Quiet@Check[f[N[Pi], 1.0], "ERR"]];
  Print["  s04 bulk = ", lhs];
  Do[Module[{d = 10^-k, num},
     num = Quiet@NIntegrate[f[x, y], {x, d, Pi - d}, {y, d, Pi - d},
        MaxRecursion -> 25, PrecisionGoal -> 5];
     Print["   cutoff 1e-", k, " : integral = ", num,
           "   ratio = ", If[NumericQ[num], N[num/lhs, 8], "unevaluated"]]],
   {k, {4, 6, 8}}]];
run["Wg3"]; run["Wpp3"];
Print["T14DONE"];

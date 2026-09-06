(* t06 retry: endpoint singularities handled, integrand numericised first. *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"]; s04 = Get[dir <> "s04_result.m"];
ev = -15/100;
pt = {s -> 5, t -> -3/2, Q2 -> 1, sig -> 7/10, eps -> ev, Nc -> 3, gs -> 1, eq -> 1};
uval = (sig - s - t - Q2) /. pt;
s23e = sig; sq = Sqrt[s23e];
p0 = (s23e - t)/(2 sq); k10 = (s - s23e)/(2 sq);
cpk = 1 + u/(2 p0 k10);
sOf[c_] := Sqrt[1 - c^2];
dot4[a_, b_] := a[[1]] b[[1]] - a[[2]] b[[2]] - a[[3]] b[[3]];
K23 = {sq, 0, 0}; k2v = (sq/2) {1, s1 cb2, c1};
k1x = k10 {1, 0, 1}; px = p0 {1, sOf[cpk], cpk}; qx = k1x + K23 - px;
t2A = -Q2 - 2 dot4[qx, k2v]; u2A = -2 dot4[px, k2v];
pfRaw = s04["dPi3"]/(2 Pi)^4;
Do[Module[{M, ig, fn, num, lhs},
   lhs = N[((s04[proj]/pfRaw) /. u -> sig - s - t - Q2 /. SUNN -> Nc /. pt), 20];
   M = (s02[If[proj === "Wg3", "Mg", "Mpp"]] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
   ig = M /. {t2 -> t2A, u2 -> u2A} /. pt /. u -> uval;
   ig = ig /. {s1 -> Sin[bb1], c1 -> Cos[bb1], cb2 -> Cos[bb2]};
   ig = ig Sin[bb1]^(1 - 2 ev) Sin[bb2]^(-2 ev);
   fn = Function[{bb1, bb2}, Evaluate[ig]];
   num = Quiet@NIntegrate[fn[x, y], {x, 0, Pi}, {y, 0, Pi},
      Method -> {"GlobalAdaptive", "SingularityHandler" -> "DuffyCoordinates",
                 "SymbolicProcessing" -> 0},
      MaxRecursion -> 40, PrecisionGoal -> 6];
   Print["=== ", proj, " ==="];
   Print["  s04 bulk        = ", lhs];
   Print["  direct integral = ", num];
   Print["  ratio direct/s04 = ", N[num/lhs, 10]]],
 {proj, {"Wg3", "Wpp3"}}];
Print["T08DONE"];

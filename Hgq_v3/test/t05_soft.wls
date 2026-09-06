(* Soft-gluon limit k3 -> 0.  Scale s23, s13, u3 all by lam -> 0 (that IS k3->0).
   Eikonal factorisation:  |M3|^2 -> gs^2 [ CA (S12+S13-S23) + 2 CF S23 ] |M2|^2
   with legs 1=g(p), 2=q(k1), 3=qbar(k2) and S_ij = (pi.pj)/((pi.k3)(pj.k3)).
   Test: decompose the limit as A*CF + B*CA and check A/(2 S23) == B/(S12+S13-S23),
   i.e. both equal the same constant gs^2.                                    *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"]; s01 = Get[dir <> "s01_result.m"];
cf[n_] := (n^2 - 1)/(2 n);
(* s23 = lam a1, s13 = lam a2, u3 = lam a3  (consistent with s04's admv) *)
soft = {sig -> lam a1, u2 -> t - lam (a1 + a3), t2 -> -(s + t + Q2) + lam (a1 + a2 + a3)};
u0 = -s - t - Q2;
S12 = 2 u0/(lam a3 lam a2); S13 = 2 t/(lam a1 lam a3); S23 = 2 s/(lam a1 lam a2);
Do[Module[{M, LO, lim, r, sol, A, B, chk, cA, cB},
   M = (s02[If[g === "g", "Mg", "Mpp"]] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
   M = M /. soft;
   LO = Simplify[(s01["A"][If[g === "g", "Hg", "Hpp"]] /. SUNN -> Nc) /. u -> u0];
   lim = Simplify[Limit[lam^2 M, lam -> 0]];
   r = Simplify[lim/LO];
   sol = Solve[{(r /. Nc -> 2) == aa cf[2] + bb 2, (r /. Nc -> 3) == aa cf[3] + bb 3}, {aa, bb}][[1]];
   A = Simplify[aa /. sol]; B = Simplify[bb /. sol];
   chk = Simplify[(r /. Nc -> 5) - (A cf[5] + B 5)];
   cA = Simplify[A/(2 Simplify[lam^2 S23])];
   cB = Simplify[B/Simplify[lam^2 (S12 + S13 - S23)]];
   Print["=== Gamma = ", g, " ==="];
   Print["  decomposition consistent at Nc=5? ", chk === 0];
   Print["  A/(2 S23)        = ", InputForm[Short[cA, 4]]];
   Print["  B/(S12+S13-S23)  = ", InputForm[Short[cB, 4]]];
   Print["  >>> eikonal structure correct (the two agree)? ", Simplify[cA - cB] === 0]],
 {g, {"g", "pp"}}];
Print["T05DONE"];

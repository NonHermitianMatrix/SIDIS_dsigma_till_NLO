(* r = residue/LO  should equal  gs^2 (A*CF + B*CA),  CF=(Nc^2-1)/(2Nc), CA=Nc.
   Solve for A,B at Nc=2,3 ; verify at Nc=5.  Collinear factorisation (k2||k3
   merge into a qbar, splitting qbar->qbar g) requires B == 0.               *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"];
s01 = Get[dir <> "s01_result.m"];
cf[n_] := (n^2 - 1)/(2 n);
Do[Module[{M, LO, r, r2, r3, r5, sol, A, B, chk},
   M  = (s02[If[g === "g", "Mg", "Mpp"]] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
   LO = Simplify[(s01["A"][If[g === "g", "Hg", "Hpp"]] /. SUNN -> Nc) /. u -> -s - t - Q2];
   r  = Simplify[Limit[sig M, sig -> 0]/LO];
   r2 = Simplify[r /. Nc -> 2]; r3 = Simplify[r /. Nc -> 3]; r5 = Simplify[r /. Nc -> 5];
   sol = Solve[{r2 == gs^2 (aa cf[2] + bb 2), r3 == gs^2 (aa cf[3] + bb 3)}, {aa, bb}][[1]];
   A = Simplify[aa /. sol]; B = Simplify[bb /. sol];
   chk = Simplify[r5 - gs^2 (A cf[5] + B 5)];
   Print["=== Gamma = ", g, " ==="];
   Print["  consistency at Nc=5 (must be 0): ", chk === 0];
   Print["  B (CA coefficient) == 0 ? ", B === 0];
   Print["  A (CF coefficient) = ", InputForm[Short[A, 5]]];
   If[B =!= 0, Print["  B = ", InputForm[Short[B, 5]]];
      Print["  B/A = ", InputForm[Short[Simplify[B/A], 5]]]]],
 {g, {"g", "pp"}}];
Print["T03DONE"];

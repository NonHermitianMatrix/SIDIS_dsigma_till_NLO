(* t03 took sig->0 at INDEPENDENT t2,u2 - off the physical surface.
   At sig=0 the pair k2,k3 is collinear, so their invariants are proportional:
       u2/u3 = (t2+Q2)/(t3+Q2)        [both equal z/(1-z)]
   with u3, t3 taken from s04's admv relations.  Solve that for t2, impose it,
   THEN decompose the residue as gs^2 (A CF + B CA).  Collinear factorisation
   (k2||k3 -> qbar, splitting qbar->qbar g) requires B == 0.                 *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
s02 = Get[dir <> "s02_result.m"]; s01 = Get[dir <> "s01_result.m"];
cf[n_] := (n^2 - 1)/(2 n);
u3a = t - u2 - sig; t3a = u - t2 - sig - Q2;          (* s04 admv *)
coll = Solve[(u2 (t3a + Q2) == u3a (t2 + Q2)) /. sig -> 0 /. u -> -s - t - Q2, t2][[1]];
Print["collinear constraint: t2 -> ", Simplify[t2 /. coll]];
Do[Module[{M, LO, r, sol, A, B, chk},
   M  = (s02[If[g === "g", "Mg", "Mpp"]] /. SUNN -> Nc) /. u -> sig - s - t - Q2;
   LO = Simplify[(s01["A"][If[g === "g", "Hg", "Hpp"]] /. SUNN -> Nc) /. u -> -s - t - Q2];
   r  = Simplify[(Limit[sig M, sig -> 0] /. coll)/LO];
   sol = Solve[{(r /. Nc -> 2) == gs^2 (aa cf[2] + bb 2),
                (r /. Nc -> 3) == gs^2 (aa cf[3] + bb 3)}, {aa, bb}][[1]];
   A = Simplify[aa /. sol]; B = Simplify[bb /. sol];
   chk = Simplify[(r /. Nc -> 5) - gs^2 (A cf[5] + B 5)];
   Print["=== Gamma = ", g, " ==="];
   Print["  decomposition consistent at Nc=5? ", chk === 0];
   Print["  >>> B (CA coefficient) == 0 ? ", B === 0];
   If[B =!= 0, Print["      B = ", InputForm[Short[B, 4]]]];
   Print["  A (CF coefficient) = ", InputForm[Short[A, 4]]]],
 {g, {"g", "pp"}}];
Print["T04DONE"];

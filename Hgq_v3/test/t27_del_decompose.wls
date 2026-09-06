#!/usr/bin/env wolframscript
(* t27: localise del's leak.  del_finite = real + virtual + subtraction.
   virtual (s08ck_virt.m) and subtraction (s08ck_sub.m) are small, so compute
   their eps^0 contributions directly; the real's follows as the difference
   from the stored total.  Report each one's dependence on x = gammaE - LogPi,
   which t26 showed is the ONLY combination that appears.
   Motivation: no power of S_eps can explain the residue - t26 gave
   (n_v^2 - n_r^2)/2 = -9/34, i.e. n_v^2-n_r^2 = -9/17, impossible for integers.
   Package-X puts 581 explicit EulerGamma in the virtual's own coefficients
   (the 1/epsbar convention), so the mismatch is inside the virtual, not a
   factor multiplying it.  This shows which contribution actually carries it. *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
vd  = Get[FileNameJoin[{dir, "s08ck_virt.m"}]];
sb  = Get[FileNameJoin[{dir, "s08ck_sub.m"}]];
r   = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[t27] loaded"];

pts = Table[Module[{sv = 3/2 + i/23, tv = -2 - i/29, qv = 1 + i/11},
    {s -> sv, t -> tv, Q2 -> qv, u -> -(qv + sv + tv), mu2 -> 2 + i/7,
     sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10,
     eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2}], {i, 1, 3}];

splitPi[a_] := Module[{n = Exponent[a, Pi]}, Log[Simplify[a/Pi^n]] + n LGPi];
canon = {PolyGamma[k_, b_] :> FunctionExpand[PolyGamma[k, b]],
         Log[a_] /; ! FreeQ[a, Pi] :> splitPi[a],
         Log[q_Rational | q_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[q]]};
(* x = gE - LGPi is the only combination t26 found, so vary it as one knob *)
prep[e_] := FixedPoint[(# /. canon) &, e, 8] /. EulerGamma -> gE;
atx[e_, xv_] := N[e /. {gE -> xv, LGPi -> 0} /. #, 30] & /@ pts;
dep[e_] := Module[{f0 = atx[e, 0]}, {Max[Abs[atx[e, 1] - f0]], Max[Abs[f0]]}];

Do[Module[{vfin, sfin, tot, rfin},
   vfin = prep[Coefficient[Normal[Series[vd[g], {eps, 0, 0}]], eps, 0]];
   sfin = prep[Coefficient[Normal[Series[sb[g]["del"], {eps, 0, 0}]], eps, 0]];
   tot  = prep[r[If[g === "g", "Hg", "Hpp"]]["del"]];
   rfin = tot - vfin - sfin;
   Print["[t27] ", g, " virtual   dx = ", ScientificForm[dep[vfin][[1]], 4],
         "   |val| = ", ScientificForm[dep[vfin][[2]], 4]];
   Print["[t27] ", g, " subtract  dx = ", ScientificForm[dep[sfin][[1]], 4],
         "   |val| = ", ScientificForm[dep[sfin][[2]], 4]];
   Print["[t27] ", g, " real(diff)dx = ", ScientificForm[dep[rfin][[1]], 4],
         "   |val| = ", ScientificForm[dep[rfin][[2]], 4]];
   Print["[t27] ", g, " TOTAL     dx = ", ScientificForm[dep[tot][[1]], 4],
         "   |val| = ", ScientificForm[dep[tot][[2]], 4]]],
 {g, {"g", "pp"}}];
Print["[t27] done"];

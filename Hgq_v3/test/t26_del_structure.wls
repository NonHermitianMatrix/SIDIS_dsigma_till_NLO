#!/usr/bin/env wolframscript
(* t26: del's residue is QUADRATIC in the scheme logs (d/dgammaE != d/dLogPi),
   so a single finite difference cannot resolve it.  Fit
      residue = c1 gE + c2 LGPi + c11 gE^2 + c22 LGPi^2 + c12 gE LGPi
   by evaluating at (0,0),(1,0),(0,1),(2,0),(0,2),(1,1) and solving exactly.
   Also report the virtual's 1/eps^2 coefficient, since any correction that
   leaves every pole gate at zero must be 1+O(eps^2) and therefore enters the
   finite part ONLY as (its eps^2 coefficient) x virt_{1/eps^2}.
   Points are the t25 physical ones: u = -(Q2+s+t) AND -Q2 < s+t < 0.        *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
vd = Get[FileNameJoin[{dir, "s08ck_virt.m"}]];
r  = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[t26] loaded"];

pts = Table[Module[{sv = 3/2 + i/23, tv = -2 - i/29, qv = 1 + i/11},
    {s -> sv, t -> tv, Q2 -> qv, u -> -(qv + sv + tv), mu2 -> 2 + i/7,
     sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10,
     eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2}], {i, 1, 3}];

splitPi[a_] := Module[{n = Exponent[a, Pi]}, Log[Simplify[a/Pi^n]] + n LGPi];
canon = {PolyGamma[k_, b_] :> FunctionExpand[PolyGamma[k, b]],
         Log[a_] /; ! FreeQ[a, Pi] :> splitPi[a],
         Log[q_Rational | q_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[q]]};
prep[e_] := FixedPoint[(# /. canon) &, e, 8] /. EulerGamma -> gE;
at[e_, a_, b_] := N[e /. {gE -> a, LGPi -> b} /. #, 30] & /@ pts;

Do[Module[{key, e, f00, f10, f01, f20, f02, f11, c1, c2, c11, c22, c12, v2},
   key = If[g === "g", "Hg", "Hpp"];
   e = prep[r[key]["del"]];
   f00 = at[e, 0, 0]; f10 = at[e, 1, 0]; f01 = at[e, 0, 1];
   f20 = at[e, 2, 0]; f02 = at[e, 0, 2]; f11 = at[e, 1, 1];
   c11 = (f20 - 2 f10 + f00)/2;          (* gE^2   *)
   c22 = (f02 - 2 f01 + f00)/2;          (* LGPi^2 *)
   c1  = f10 - f00 - c11;                (* gE     *)
   c2  = f01 - f00 - c22;                (* LGPi   *)
   c12 = f11 - f00 - c1 - c2 - c11 - c22;(* gE LGPi*)
   v2  = prep[Coefficient[Normal[Series[vd[g], {eps, 0, 0}]], eps, -2]];
   v2  = at[v2, 0, 0];
   Print["[t26] ", g, " del  c(gE)      = ", ScientificForm[c1, 4]];
   Print["[t26] ", g, " del  c(LGPi)    = ", ScientificForm[c2, 4]];
   Print["[t26] ", g, " del  c(gE^2)    = ", ScientificForm[c11, 4]];
   Print["[t26] ", g, " del  c(LGPi^2)  = ", ScientificForm[c22, 4]];
   Print["[t26] ", g, " del  c(gE LGPi) = ", ScientificForm[c12, 4]];
   Print["[t26] ", g, " virt 1/eps^2    = ", ScientificForm[v2, 4]];
   Print["[t26] ", g, " c(gE)/virt2 = ", ScientificForm[c1/v2, 6],
                    "   c(gE^2)/virt2 = ", ScientificForm[c11/v2, 6]]],
 {g, {"g", "pp"}}];
Print["[t26] done"];

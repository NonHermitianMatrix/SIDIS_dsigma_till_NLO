#!/usr/bin/env wolframscript
(* t25: measure del on VALID points.  del multiplies delta(s23), so it must be
   evaluated ON the s23=0 surface, i.e. u = -(Q2+s+t) - s08's own pts says so.
   My earlier attempts each violated one constraint:
     t15/t17 : u = -(Q2+s+t) correct, but s+t>0 makes Sqrt[(s+t)^2]=+(s+t) and
               two Log arguments collapse to Log[0] -> Indeterminate;
     t23/t24 : s+t<0 keeps the logs finite, but I set u INDEPENDENTLY, which
               left the s23=0 surface entirely (s23 ~ -2.94) and returned
               COMPLEX values - the tell that the point was unphysical.
   Both hold at once when  -Q2 < s+t < 0  with u = -(Q2+s+t):
     u<0 physical, Sqrt[(s+t)^2] = -(s+t) finite, and D=(2Q2+s+t)/|s+t| > 1 as
     hgq_common's base integrals assume (Assumptions -> dd > 1).             *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
r = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[t25] loaded"];

pts = Table[Module[{sv, tv, qv, uv},
    sv = 3/2 + i/23; tv = -2 - i/29; qv = 1 + i/11;   (* s+t in (-Q2,0) *)
    uv = -(qv + sv + tv);
    Print["[t25] point ", i, ": s+t = ", N[sv + tv], "  u = ", N[uv],
          "  Q2+s+t = ", N[qv + sv + tv], "  D = ", N[(2 qv + sv + tv)/Abs[sv + tv]]];
    {s -> sv, t -> tv, Q2 -> qv, u -> uv, mu2 -> 2 + i/7, sig -> 1/3 + i/23,
     BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10, eq -> 2/3, xh -> 2/5,
     x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2}], {i, 1, 3}];

splitPi[a_] := Module[{n = Exponent[a, Pi]}, Log[Simplify[a/Pi^n]] + n LGPi];
canon = {PolyGamma[k_, b_] :> FunctionExpand[PolyGamma[k, b]],
         Log[a_] /; ! FreeQ[a, Pi] :> splitPi[a],
         Log[q_Rational | q_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[q]]};
prep[e_] := FixedPoint[(# /. canon) &, e, 8] /. EulerGamma -> gE;
ev[e_, ru_] := N[e /. ru /. {gE -> 0, LGPi -> 0} /. #, 30] & /@ pts;

Do[Module[{e, b, dg, dp, left},
   e = prep[r[key][cmp]];
   left = DeleteDuplicates[Cases[e, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]];
   b = ev[e, {}]; dg = ev[e, {gE -> 1}] - b; dp = ev[e, {LGPi -> 1}] - b;
   Print["[t25] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[Max[Abs[dg]], 3],
     "   d/dLogPi = ", ScientificForm[Max[Abs[dp]], 3],
     "   |value| = ", ScientificForm[Max[Abs[b]], 3],
     "   max|Im(value)| = ", ScientificForm[Max[Abs[Im[b]]], 3],
     "   leftovers: ", If[left === {}, "none", Length[left]]]],
 {key, {"Hg", "Hpp"}}, {cmp, {"del", "reg", "p1", "p2"}}];
Print["[t25] done"];

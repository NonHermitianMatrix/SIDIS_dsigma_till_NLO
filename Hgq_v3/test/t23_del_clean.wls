#!/usr/bin/env wolframscript
(* t23: settle del.  t22's canon left 7 Log-arguments containing Pi
   unconverted, so del's d/dEulerGamma there measured my substitution, not the
   physics.  Use a GENERAL rule - for any Log[arg] whose argument carries Pi,
   split off the Pi power exactly: n = Exponent[arg,Pi], Log[arg] ->
   Log[arg/Pi^n] + n LGPi - and PRINT any leftover so it cannot pass silently. *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
r = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[t23] loaded"];

(* s+t<0 branch: at s+t>0 del's Sqrt[(s+t)^2] collapses two Log arguments to
   Log[0] (t18), so del is only evaluable here. *)
pts = Table[{s -> 3/2 + i/13, t -> -7/2 - i/17, Q2 -> 1 + i/11, u -> -2 - i/19,
     mu2 -> 2 + i/7, sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5,
     as -> 1/10, eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5,
     xi -> 1/2}, {i, 1, 3}];

splitPi[a_] := Module[{n = Exponent[a, Pi]}, Log[Simplify[a/Pi^n]] + n LGPi];
canon = {PolyGamma[k_, b_] :> FunctionExpand[PolyGamma[k, b]],
         Log[a_] /; ! FreeQ[a, Pi] :> splitPi[a],
         Log[q_Rational | q_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[q]]};
prep[e_] := FixedPoint[(# /. canon) &, e, 8] /. EulerGamma -> gE;

val[e_, rules_] := N[e /. rules /. {gE -> 0, LGPi -> 0} /. #, 30] & /@ pts;

Do[Module[{e, b, dg, dp, left},
   e = prep[r[key][cmp]];
   left = DeleteDuplicates[Cases[e, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]];
   b = val[e, {}]; dg = val[e, {gE -> 1}] - b; dp = val[e, {LGPi -> 1}] - b;
   Print["[t23] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[Max[Abs[dg]], 3],
     "   d/dLogPi = ", ScientificForm[Max[Abs[dp]], 3],
     "   |value| = ", ScientificForm[Max[Abs[b]], 3],
     "   leftover Pi-logs: ", If[left === {}, "none", InputForm[left]]]],
 {key, {"Hg", "Hpp"}}, {cmp, {"del", "reg", "p1", "p2"}}];
Print["[t23] done"];

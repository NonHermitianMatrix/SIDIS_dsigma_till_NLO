#!/usr/bin/env wolframscript
(* t20: does the PI power balance, or only gamma_E fail?
   Discriminates the two candidate missing factors:
     A  extra e^(-gammaE eps)          -> pure gamma_E, NO pi
     B  extra Gamma(1-eps)/Gamma(1-2eps) = e^(-gammaE eps)(1+O(eps^2))
                                       -> also pure gamma_E, NO pi
     C  wrong power of S_eps=(4Pi)^eps e^(-gammaE eps) -> gamma_E AND Log[Pi]
   t17's Log columns were unreliable: they mapped Log[4 Pi] and Log[Pi] as
   INDEPENDENT atoms, but Log[4 Pi] == 2 Log[2] + Log[Pi].  Canonicalise onto
   the {Log[2], Log[Pi]} basis first, then difference.
   Log[2] is physical (PolyGamma[0,1/2] = -EulerGamma - 2 Log[2]); only Log[Pi]
   is a scheme artefact, from (4Pi)^eps and the phase space's Pi^(-eps).      *)
r = Get["/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/s08_result_snapshot.m"];
Print["[t20] loaded"];

(* s+t<0 branch so del is not Log[0]-degenerate (see t18) *)
pts = Table[{s -> 3/2 + i/13, t -> -7/2 - i/17, Q2 -> 1 + i/11, u -> -2 - i/19,
     mu2 -> 2 + i/7, sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5,
     as -> 1/10, eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5,
     xi -> 1/2}, {i, 1, 3}];

(* canonicalise: every Log of a positive rational times a power of Pi becomes
   an integer combination of LG2, LG3, LGPi ... handled generically by
   expanding Log of an explicit product/power. *)
canon = {
   PolyGamma[a_, b_] :> FunctionExpand[PolyGamma[a, b]],
   Log[Pi] -> LGPi,
   Log[r_Rational | r_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[r]],
   Log[Times[c_?NumericQ, Pi]] :> Log[c] + LGPi,
   Log[Power[Pi, n_]] :> n LGPi};
prep[e_] := FixedPoint[(# /. canon) &, e, 6] /. EulerGamma -> gE /. Log[2] -> LG2;

val[e_, rules_] := N[e /. rules /. {gE -> 0, LGPi -> 0, LG2 -> Log[2]} /. #, 30] & /@ pts;

Do[Module[{e, b, dg, dp, leftover},
   e = prep[r[key][cmp]];
   leftover = DeleteDuplicates[Cases[e, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]];
   b  = val[e, {}];
   dg = val[e, {gE -> 1}] - b;
   dp = val[e, {LGPi -> 1}] - b;
   Print["[t20] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[Max[Abs[dg]], 3],
     "   d/dLogPi = ", ScientificForm[Max[Abs[dp]], 3],
     "   |value| = ", ScientificForm[Max[Abs[b]], 3],
     "   uncanonicalised Pi-logs: ", Length[leftover]]],
 {key, {"Hg", "Hpp"}}, {cmp, {"del", "reg", "p1", "p2"}}];
Print["[t20] done"];

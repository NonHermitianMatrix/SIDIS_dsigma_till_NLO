#!/usr/bin/env wolframscript
(* t15: is the EulerGamma / Log[4Pi] in s08_result.m a real leak or uncancelled
   syntax?  Both enter ONLY through Wcom = 3Log[mu2]+2(Log[4Pi]-EulerGamma)
   multiplying the individual pole coefficients.  If the total's poles cancel,
   their sum must be numerically zero.  Test by evaluating the stored result at
   the s08 gate points with gE,L4P set to 0 and to 1 and differencing - no
   symbolic D, no Simplify, so the cost is one substitution pass.            *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
r = Get["/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/s08_result_snapshot.m"];
Print["[t15] keys: ", Keys[r]];

pts = Table[Module[{sv = 7/2 + i/13, tv = -3/2 - i/17, qv = 1 + i/11},
    {s -> sv, t -> tv, Q2 -> qv, u -> -qv - sv - tv, mu2 -> 2 + i/7,
     sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10,
     eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2}], {i, 1, 3}];

(* strip the two scheme atoms onto free symbols *)
strip[e_] := e /. EulerGamma -> gE /. Log[4 Pi] -> L4P;

val[e_, ge_, l4_] := N[e /. {gE -> ge, L4P -> l4} /. #, 30] & /@ pts;

Do[Module[{e, b, dg, dl},
   e = strip[r[key][cmp]];
   b  = val[e, 0, 0];
   dg = val[e, 1, 0] - b;
   dl = val[e, 0, 1] - b;
   Print["[t15] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[Max[Abs[dg]], 3],
     "   d/dLog4Pi = ", ScientificForm[Max[Abs[dl]], 3],
     "   |value| = ", ScientificForm[Max[Abs[b]], 3]]],
 {key, {"Hg", "Hpp"}}, {cmp, {"del", "reg", "p1", "p2"}}];

Do[Module[{e, b, dg, dl},
   e = strip[r[key][cmp]];
   b  = val[e, 0, 0];
   dg = val[e, 1, 0] - b;
   dl = val[e, 0, 1] - b;
   Print["[t15] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[Max[Abs[dg]], 3],
     "   d/dLog4Pi = ", ScientificForm[Max[Abs[dl]], 3]]],
 {key, {"F1hat", "F2hat"}}, {cmp, {"del", "reg", "p1", "p2"}}];

Print["[t15] done"];

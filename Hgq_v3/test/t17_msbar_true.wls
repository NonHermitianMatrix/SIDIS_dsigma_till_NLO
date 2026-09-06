#!/usr/bin/env wolframscript
(* t17: the honest MSbar measurement.  t15 and s08's own gate both test only
   the explicit EulerGamma atom, but the result carries 93196 PolyGamma[0,1/2],
   and PolyGamma[0,1/2] == -EulerGamma - 2 Log[2].  So both were blind to most
   of the gamma_E.  Here every PolyGamma is FunctionExpand-ed FIRST, then
   EulerGamma is mapped to a free symbol and differenced.
   Also uses a GENERIC u (not u = -Q2-s-t), which in t15 made Log[s+t+u+Q2]
   = Log[0] and returned Indeterminate for del.                             *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
r = Get["/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/s08_result_snapshot.m"];
Print["[t17] loaded, keys: ", Keys[r]];

Print["[t17] check PolyGamma[0,1/2] expansion: ", FunctionExpand[PolyGamma[0, 1/2]]];

(* generic kinematic point: u independent so no Log[0] anywhere *)
pts = Table[Module[{sv = 7/2 + i/13, tv = -3/2 - i/17, qv = 1 + i/11},
    {s -> sv, t -> tv, Q2 -> qv, u -> -2 - i/19, mu2 -> 2 + i/7,
     sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10,
     eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2}], {i, 1, 3}];

(* expand every PolyGamma to its EulerGamma / Log / Zeta form, THEN free the atoms *)
strip[e_] := e /. PolyGamma[a_, b_] :> FunctionExpand[PolyGamma[a, b]] /.
                  EulerGamma -> gE /. Log[4 Pi] -> L4P /. Log[Pi] -> LPi;

val[e_, rules_] := N[e /. rules /. {gE -> 0, L4P -> 0, LPi -> 0} /. #, 30] & /@ pts;

test[e_] := Module[{b, dg, dl, dp},
   b  = val[e, {}];
   dg = val[e, {gE -> 1}] - b;
   dl = val[e, {L4P -> 1}] - b;
   dp = val[e, {LPi -> 1}] - b;
   {Max[Abs[dg]], Max[Abs[dl]], Max[Abs[dp]], Max[Abs[b]]}];

Do[Module[{e, q},
   e = strip[r[key][cmp]];
   q = test[e];
   Print["[t17] ", key, " ", cmp,
     "  d/dEulerGamma = ", ScientificForm[q[[1]], 3],
     "   d/dLog4Pi = ", ScientificForm[q[[2]], 3],
     "   d/dLogPi = ", ScientificForm[q[[3]], 3],
     "   |value| = ", ScientificForm[q[[4]], 3]]],
 {key, {"Hg", "Hpp", "F1hat", "F2hat"}}, {cmp, {"del", "reg", "p1", "p2"}}];
Print["[t17] done"];

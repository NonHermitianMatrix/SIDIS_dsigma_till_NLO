#!/usr/bin/env wolframscript
(* t19: the MSbar residue in reg/p1 is real (t17).  reg and p1 get no virtual,
   so the residue must be  (missing O(eps) normalisation) x (the 1/eps pole).
   Measure the weight: ratio of  d/dEulerGamma[final]  to the SUBTRACTION's
   1/eps coefficient, point by point.  A simple rational ratio identifies the
   factor the real phase space carries and the counterterm does not.         *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];

sub = Get[FileNameJoin[{dir, "s08ck_sub.m"}]];
Print["[t19] sub keys: ", Keys[sub], " / ", Keys[sub["g"]]];

r = Get["/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/s08_result_snapshot.m"];
Print["[t19] result loaded"];

pts = Table[{s -> 7/2 + i/13, t -> -3/2 - i/17, Q2 -> 1 + i/11, u -> -2 - i/19,
     mu2 -> 2 + i/7, sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5,
     as -> 1/10, eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5,
     xi -> 1/2}, {i, 1, 3}];

atoms[e_] := e /. PolyGamma[a_, b_] :> FunctionExpand[PolyGamma[a, b]];
free[e_]  := atoms[e] /. EulerGamma -> gE;

(* d/dEulerGamma of the final answer, per point *)
leak[key_, cmp_] := Module[{e = free[r[key][cmp]]},
   MapThread[#1 - #2 &,
     {N[e /. gE -> 1 /. # , 30] & /@ pts, N[e /. gE -> 0 /. #, 30] & /@ pts}]];

(* the subtraction's own 1/eps coefficient, per point *)
subpole[key_, cmp_] := Module[{e},
   e = Normal[Series[sub[key][cmp], {eps, 0, 0}]];
   e = free[Coefficient[e, eps, -1]];
   N[e /. gE -> 0 /. #, 30] & /@ pts];

Do[Module[{L, P},
   L = leak[If[key === "g", "Hg", "Hpp"], cmp];
   P = subpole[key, cmp];
   Print["[t19] ", key, " ", cmp, "  leak = ", ScientificForm[L, 4]];
   Print["[t19] ", key, " ", cmp, "  subpole = ", ScientificForm[P, 4]];
   Print["[t19] ", key, " ", cmp, "  RATIO leak/subpole = ", ScientificForm[L/P, 8]]],
 {key, {"g", "pp"}}, {cmp, {"reg", "p1"}}];
Print["[t19] done"];

#!/usr/bin/env wolframscript
(* t18: t17 still returns Indeterminate (0*(-Infinity)) for the del component
   even with a generic u, so some OTHER argument vanishes at the test point.
   Find it: substitute the point into every Log argument and every negative
   power base inside Hg["del"] and report the ones that evaluate to zero.
   Then re-measure d/dEulerGamma for del at a point that avoids them.        *)
r = Get["/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/s08_result_snapshot.m"];
e = r["Hg"]["del"];
Print["[t18] del loaded"];

pt = {s -> 7/2 + 1/13, t -> -3/2 - 1/17, Q2 -> 1 + 1/11, u -> -2 - 1/19,
      mu2 -> 2 + 1/7, sig -> 1/3 + 1/23, BB -> 5 + 1/5, Nc -> 3, nf -> 5,
      as -> 1/10, eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5, xi -> 1/2};

logs = DeleteDuplicates[Cases[e, Log[a_] :> a, Infinity]];
Print["[t18] distinct Log arguments: ", Length[logs]];
Do[Module[{v = Simplify[a /. pt]},
   If[TrueQ[v == 0], Print["[t18] VANISHING Log argument: ", a]]], {a, logs}];

pows = DeleteDuplicates[Cases[e, Power[b_, n_?(NumericQ[#] && # < 0 &)] :> b, Infinity]];
Print["[t18] distinct negative-power bases: ", Length[pows]];
Do[Module[{v = Simplify[b /. pt]},
   If[TrueQ[v == 0], Print["[t18] VANISHING denominator: ", b]]], {b, pows}];

Print["[t18] free symbols left after substitution: ",
  DeleteDuplicates[Cases[e /. pt, _Symbol?(! NumericQ[#] &), Infinity]]];
Print["[t18] done"];

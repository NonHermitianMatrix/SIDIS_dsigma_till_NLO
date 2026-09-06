#!/usr/bin/env wolframscript
(* t24: del is the ONLY leaking component and the ONLY one containing the
   virtual.  Real and counterterm now both sit at S_eps^3 (emission / explicit
   pfPS); the virtual gets Sfac^2 from gs^4 and mu2^eps from ScaleMu but NOTHING
   for its loop integration, and Package-X reports in 1/epsbar (S_eps absorbed).
   If it is short exactly one S_eps, then because it carries a 1/eps^2 pole the
   finite residue must be  (Log4Pi - gammaE) x (virtual's 1/eps^2 coefficient),
   so  d/dgammaE(del) / virt_{1/eps^2}  must be a clean -1 (or +1).
   Measure that ratio per point, the way t19 pinned the counterterm.          *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
vd = Get[FileNameJoin[{dir, "s08ck_virt.m"}]];
Print["[t24] virt keys: ", Keys[vd]];
r = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[t24] result loaded"];

pts = Table[{s -> 3/2 + i/13, t -> -7/2 - i/17, Q2 -> 1 + i/11, u -> -2 - i/19,
     mu2 -> 2 + i/7, sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5,
     as -> 1/10, eq -> 2/3, xh -> 2/5, x -> 2/5, z -> 3/5, zt -> 3/5,
     xi -> 1/2}, {i, 1, 3}];

splitPi[a_] := Module[{n = Exponent[a, Pi]}, Log[Simplify[a/Pi^n]] + n LGPi];
canon = {PolyGamma[k_, b_] :> FunctionExpand[PolyGamma[k, b]],
         Log[a_] /; ! FreeQ[a, Pi] :> splitPi[a],
         Log[q_Rational | q_Integer] :> Total[#[[2]] Log[#[[1]]] & /@ FactorInteger[q]]};
prep[e_] := FixedPoint[(# /. canon) &, e, 8] /. EulerGamma -> gE;
ev[e_, ru_] := N[e /. ru /. {gE -> 0, LGPi -> 0} /. #, 30] & /@ pts;

Do[Module[{key, e, b, dg, v2},
   key = If[g === "g", "Hg", "Hpp"];
   e = prep[r[key]["del"]];
   b = ev[e, {}]; dg = ev[e, {gE -> 1}] - b;
   (* virtual's 1/eps^2 coefficient, same atom treatment *)
   v2 = prep[Coefficient[Normal[Series[vd[g], {eps, 0, 0}]], eps, -2]];
   v2 = ev[v2, {}];
   Print["[t24] ", g, "  d/dEulerGamma(del) = ", ScientificForm[dg, 4]];
   Print["[t24] ", g, "  virt 1/eps^2 coeff = ", ScientificForm[v2, 4]];
   Print["[t24] ", g, "  RATIO = ", ScientificForm[dg/v2, 8]]],
 {g, {"g", "pp"}}];
Print["[t24] done"];

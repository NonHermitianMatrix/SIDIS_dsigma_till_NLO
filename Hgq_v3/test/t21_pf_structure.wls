#!/usr/bin/env wolframscript
(* t21: what scheme factor does the REAL actually carry?
   s07a:149 builds pf = Series[(dPi3/(2Pi)^4) sig^eps, {eps,0,1}] and multiplies
   it back into every real term; s08 then imposes mu2^(3eps) Sfac^2 on top.
   Measure pf's exact eps structure and compare its logarithm against Sfac.
   Also expose the O(eps^2) coefficient that s07a's order-1 truncation drops -
   pf multiplies terms with 1/eps^2 poles, so eps^2 reaches the finite part. *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
s04r = Get[FileNameJoin[{dir, "s04_result.m"}]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];

dPi3 = s04r["dPi3"];
Print["[t21] dPi3 = ", InputForm[dPi3]];

pfRaw = dPi3/(2 Pi)^4;
exact = (pfRaw /. u -> sig - s - t - Q2) sig^eps;
Print["[t21] exact pf (unexpanded) = ", InputForm[Simplify[exact]]];

(* the code's truncation *)
pf1 = Normal[Series[exact, {eps, 0, 1}]];
pf2 = Normal[Series[exact, {eps, 0, 2}]];
Print["[t21] pf to O(eps^1) [what s07a uses] = ", InputForm[Simplify[pf1]]];
Print["[t21] pf eps^2 coefficient [DROPPED]  = ",
   InputForm[Simplify[SeriesCoefficient[exact, {eps, 0, 2}]]]];

(* how many powers of Sfac does pf carry?  compare logs order by order *)
Print["[t21] --- log comparison, order by order in eps ---"];
lpf = Series[Log[exact 256 Pi^6], {eps, 0, 3}];
lsf = Series[Log[Sfac], {eps, 0, 3}];
Do[Print["[t21]  eps^", j, " : Log[pf*256Pi^6] = ",
     InputForm[Simplify[SeriesCoefficient[lpf, j]]],
     "    Log[Sfac] = ", InputForm[Simplify[SeriesCoefficient[lsf, j]]]], {j, 0, 3}];

Print["[t21] ratio pf*256Pi^6 / Sfac  (series) = ",
   InputForm[Simplify[Normal[Series[exact 256 Pi^6/Sfac, {eps, 0, 2}]]]]];
Print["[t21] ratio pf*256Pi^6 / Sfac^2 (series) = ",
   InputForm[Simplify[Normal[Series[exact 256 Pi^6/Sfac^2, {eps, 0, 2}]]]]];
Print["[t21] done"];

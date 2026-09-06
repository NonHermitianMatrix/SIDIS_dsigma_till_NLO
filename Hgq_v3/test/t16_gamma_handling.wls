#!/usr/bin/env wolframscript
(* t16: does s08's eps^0 extraction correctly expand the UNEXPANDED
   Gamma[(1-2eps)/2] that s04's dPi3 multiplies into every real term?
   epsCoefFast/epsCoefGen classify terms with Exponent[t,eps,List] and by
   matching Power[_, <eps>].  Gamma[...] is neither, so if Exponent calls it
   eps-free the factor is treated as a constant and its eps-expansion - a
   EulerGamma source - is never performed.
   Test: compare the s08 reduction of real terms that contain Gamma[ against
   an honest Series of the same term times the same common factor.          *)
dir = ParentDirectory[DirectoryName[$InputFileName]];

Print["[t16] Exponent[Gamma[(1-2eps)/2], eps]        = ", Exponent[Gamma[(1 - 2 eps)/2], eps]];
Print["[t16] Exponent[Gamma[(1-2eps)/2], eps, List]  = ", Exponent[Gamma[(1 - 2 eps)/2], eps, List]];
Print["[t16] Exponent[3 eps^-1 Gamma[(1-2eps)/2], eps, List] = ",
   Exponent[3 eps^-1 Gamma[(1 - 2 eps)/2], eps, List]];
Print["[t16] FreeQ[Gamma[(1-2eps)/2], eps] = ", FreeQ[Gamma[(1 - 2 eps)/2], eps]];

(* --- the exact s08 definitions --- *)
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
Ecom = Table[SeriesCoefficient[mu2^eps (mu2^eps Sfac)^2, {eps, 0, j}], {j, 0, 2}];
Wcom = 3 Log[mu2] + 2 (Log[4 Pi] - EulerGamma);
epsCoefGen[t_] := Module[{fs, expf, rest, w, ec, ex, x},
   fs = If[Head[t] === Times, List @@ t, {t}];
   expf = Select[fs, MatchQ[#, Power[_, _?(! FreeQ[#, eps] &)]] &];
   rest = t/(Times @@ expf);
   w = Wcom + Total[(#[[2]] Log[#[[1]]])/eps & /@ expf];
   If[! FreeQ[w, eps] || ! FreeQ[rest, Power[_, _?(! FreeQ[#, eps] &)]],
      Return[With[{ser = Normal[Series[t mu2^eps (mu2^eps Sfac)^2, {eps, 0, 0}]]},
         Coefficient[ser, eps, #] & /@ {-2, -1, 0}]]];
   ex = Exponent[rest, eps, List];
   If[! AllTrue[ex, IntegerQ] || Min[ex] < -2, Print["[t16] gen ABORT path"]; Return[$Failed]];
   ec = {1, w, w^2/2};
   x = Coefficient[rest, eps, #] & /@ {-2, -1, 0};
   {x[[1]], x[[2]] + ec[[2]] x[[1]], x[[3]] + ec[[2]] x[[2]] + ec[[3]] x[[1]]}];
epsCoefFast[t_] := Module[{ex, k},
   ex = Exponent[t, eps, List];
   If[! AllTrue[ex, IntegerQ], Return[epsCoefGen[t]]];
   If[Min[ex] >= 1, Return[{0, 0, 0}]];
   If[Length[ex] =!= 1, Return[epsCoefGen[t]]];
   k = ex[[1]];
   Switch[k, 0, {0, 0, t}, -1, With[{x1 = t eps}, {0, x1, Ecom[[2]] x1}],
    -2, With[{x2 = t eps^2}, {x2, Ecom[[2]] x2, Ecom[[3]] x2}], _, epsCoefGen[t]]];

honest[t_] := Coefficient[Normal[Series[t mu2^eps (mu2^eps Sfac)^2, {eps, 0, 0}]], eps, 0];

getComp[a_, "del"] := a["del"]; getComp[a_, "reg"] := a["reg"];
getComp[a_, "p1"] := a["p"][[1]]; getComp[a_, "p2"] := a["p"][[2]];

pt = {s -> 7/2, t -> -3/2, Q2 -> 1, u -> -3, mu2 -> 2, sig -> 1/3, BB -> 5,
      Nc -> 3, nf -> 5, as -> 1/10, eq -> 2/3, gs -> Sqrt[4 Pi/10], s23e -> 1/3, sq -> 7/2};

aa = Get[FileNameJoin[{dir, "s07part_Wg3_1_20.m"}]];
Print["[t16] partial keys: ", Keys[aa]];
Do[Module[{tl, withG, sel, r, h, d},
   tl = getComp[aa, cmp];
   tl = If[Head[tl] === Plus, List @@ tl, {tl}];
   withG = Select[tl, ! FreeQ[#, Gamma] &];
   Print["[t16] cmp=", cmp, "  terms=", Length[tl], "  terms containing Gamma[=", Length[withG]];
   If[withG =!= {},
     sel = Take[withG, UpTo[3]];
     Do[
       r = epsCoefFast[q][[3]];
       h = honest[q];
       d = N[(r - h) /. pt, 25];
       Print["[t16]    s08 vs honest  diff = ", ScientificForm[Abs[d], 3],
             "   honest = ", ScientificForm[Abs[N[h /. pt, 25]], 3]],
      {q, sel}]]],
 {cmp, {"del", "reg", "p1", "p2"}}];
Print["[t16] done"];

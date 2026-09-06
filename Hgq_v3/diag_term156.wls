#!/usr/bin/env wolframscript
(* Diagnostic: why does a single summand of the real contribution need >7 GB?
   Rebuilds the term list exactly as s07a does, then reports the structure of
   the offending term and tests whether a coefficient-wise product with pf
   reproduces Series exactly (Series is what blows up).                      *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
s04r = Get[FileNameJoin[{dir, "s04_result.m"}]];

pfRaw = s04r["dPi3"]/(2 Pi)^4;
pf = Normal[Series[(pfRaw /. u -> sig - s - t - Q2) sig^eps, {eps, 0, 1}]];
bulk = (s04r["Wg3"]/pfRaw) /. u -> sig - s - t - Q2;
bulk = bulk /. Power[b_, e_] /; ! FreeQ[e, eps] :> Power[b, Simplify[e]];
terms = Module[{fac, sums, rest},
   Which[
    Head[bulk] === Plus, List @@ bulk,
    Head[bulk] === Times,
     fac = List @@ bulk; sums = Select[fac, Head[#] === Plus &];
     rest = Times @@ Select[fac, Head[#] =!= Plus &];
     If[Length[sums] == 1, (rest #) & /@ (List @@ First[sums]), {bulk}],
    True, {bulk}]];
Print["Head[bulk] = ", Head[bulk], "   nterms = ", Length[terms]];

tm = terms[[156]];
Print["term156 LeafCount        = ", LeafCount[tm]];
Print["term156 eps in exponent  = ", ! FreeQ[tm, Power[_, _?(! FreeQ[#, eps] &)]]];
Print["term156 Gamma/PolyGamma  = ", ! FreeQ[tm, Gamma | PolyGamma]];
Print["term156 eps powers       = ", Union[Cases[tm, Power[eps, n_] :> n, Infinity]]];
Print["term156 head             = ", Head[tm], "  nfactors = ",
   If[Head[tm] === Times, Length[List @@ tm], 1]];
Print["term156 factor LeafCounts= ",
   If[Head[tm] === Times, Sort[LeafCount /@ (List @@ tm)] // Reverse // Take[#, UpTo[8]] &, {}]];

(* is it a Laurent polynomial in eps?  If so a coefficient-wise product with
   pf reproduces Series and we can drop Series entirely.                     *)
c0 = Coefficient[pf, eps, 0]; c1 = Coefficient[pf, eps, 1];
t0 = AbsoluteTime[];
ck = Association[Table[k -> Coefficient[tm, eps, k], {k, -4, 2}]];
Print["Coefficient extraction   : ", Round[AbsoluteTime[] - t0, 0.01], " s"];
Print["nonzero eps orders       : ", Select[Keys[ck], ck[#] =!= 0 &]];
t0 = AbsoluteTime[];
g2 = Sum[eps^k (c0 ck[k] + c1 Lookup[ck, k - 1, 0]), {k, -4, 1}];
Print["coefficientwise product  : ", Round[AbsoluteTime[] - t0, 0.01], " s, LeafCount=", LeafCount[g2]];
Print["reconstruction check (tm - Sum_k ck[k] eps^k, numeric) = ",
   N[(tm - Sum[ck[k] eps^k, {k, -4, 2}]) /.
     {s -> 7/2, t -> -3/2, Q2 -> 11/10, sig -> 1/3, Nc -> 3, gs -> 1, eq -> 1, eps -> 1/37}, 20]];

(* Which step actually blows up?  Run the s07a body for this one term with
   per-step timing and RSS. *)
Mcoef[m_] := Mcoef[m] = Simplify[(-1)^m D[-BB^(-eps)/eps, {eps, m}]];
rss[] := Round[ToExpression[StringTrim[Import["!ps -o rss= -p " <> ToString[$ProcessID], "Text"]]]/1024];
Print["--- per-step on term 156 ---  start rss=", rss[], " MB"];
t0 = AbsoluteTime[]; g = Normal[Series[pf tm, {eps, 0, 1}]];
Print["Series  ", Round[AbsoluteTime[] - t0, 0.01], " s  LeafCount=", LeafCount[g], "  rss=", rss[]];
t0 = AbsoluteTime[]; g = Collect[g, Log[sig]];
Print["Collect ", Round[AbsoluteTime[] - t0, 0.01], " s  rss=", rss[]];
t0 = AbsoluteTime[]; sing = Table[Limit[sig Coefficient[g, Log[sig], m], sig -> 0], {m, 0, 2}];
Print["Limit   ", Round[AbsoluteTime[] - t0, 0.01], " s  rss=", rss[]];
t0 = AbsoluteTime[]; rg = g - Sum[sing[[m + 1]] Log[sig]^m/sig, {m, 0, 2}];
r2 = Normal[Series[sig^(-eps) rg, {eps, 0, 1}]];
Print["regSer  ", Round[AbsoluteTime[] - t0, 0.01], " s  LeafCount=", LeafCount[r2], "  rss=", rss[]];

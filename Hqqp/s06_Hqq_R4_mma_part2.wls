#!/usr/bin/env wolframscript
(* Hqq_R4_mma_part2.wls -- R4 endpoint residue, ENGINE v2.  Replaces
   Hqq_R4_mma_part.wls, whose ZERO-SKIP silently DISCARDED contributing terms.

   BUG K (found 2026-07-26, job 14150206 `zskip`).  Engine v1 shortcut a term to
   zero via
       pows = exponents e of every Power[b,e] whose BASE contains W;
       mn = Min[pows];   If[mn > -2, 0, ...]
   `mn` is the lowest EXPONENT, not the lowest POWER OF W: when a base VANISHES
   at W = 0, `b^(-1)` already behaves as `W^(-k)` with k >= 1, so a term with all
   exponents > -2 can still carry W^(-2).  MEASURED on an evenly-spaced 41-term
   sample of MR2PPA: **34 of 41 terms** were zeroed by the skip while the
   DEFINITION gives a nonzero residue (LeafCount 40-58, true lowest power
   p = -2 or -4).  Same on MR2PPQGG (term 3000 and many others).
   The skip entered `Hqq_R4_mma_part.wls` at 16:20 on 2026-07-25 and was NEVER
   validated -- the `PARTMERGE DIFF = 0` exactness test predates it (12:55).
   BLAST RADIUS, by artifact timestamp: only `r4out_MR2PPQGG.m` (07-25 17:03) and
   `r4out_MR2gQGG.m` (07-25 21:45) were produced with it.  All other merged
   residues (MR2{g,PP}A, MR2{g,PP}B, MR2{g,PP}Drel, MR2gE, MR2{g,PP}HGG) date
   from 07-24 20:51 to 07-25 12:55 and predate it.

   THIS ENGINE.  No zero-skip.  Per term, the residue is the DEFINITION,
       resid = free * SeriesCoefficient[dep, {W, 0, -2}],
   with `free` the W-free factors (SeriesCoefficient is multiplicative over
   them -- the W-free split proven exact at 12:55 on 2026-07-25, PARTMERGE
   DIFF = 0), computed under a per-term TimeConstrained.  A term that exceeds it
   is QUARANTINED BY INDEX, never dropped silently; the quarantine file is part
   of the result and the residue is NOT complete until it is empty.

   R4MODE:
     AUTO (default) -- classify each term, run the route that suits it, and fall
                       back to the other one if that route times out.  Cheap
                       terms go DIRECT; the pathological class goes SPLIT.
     DIRECT         -- the definition, nothing else.
     SPLIT          -- factor W^(p + c eps) out of vanishing-base Powers first,
                       then take an ordinary Taylor coefficient.  Validated
                       EXACT against DIRECT (`SPLIT != DIRECT : 0` on 41-term
                       samples of MR2PPA and MR2PPQGG, job 14150323) once
                       `splitPow` was fixed to read the vanishing order from
                       Series rather than from `b /. W -> 0` (which returns
                       Indeterminate on a removable 0/0 and silently no-opped).
   Env: R4PIECE, R4PART, R4NPART, R4RR, R4NK, R4TMAX (cap on the preferred
        route), R4TMAX2 (cap on the fallback), R4MODE, R4OUTTAG, R4REF, C2ROOT. *)

$HistoryLength = 0;
piece = Environment["R4PIECE"]; If[piece === $Failed, piece = "MR2PPA"];
nk = ToExpression[Environment["R4NK"]]; If[!IntegerQ[nk], nk = 8];
tmax = ToExpression[Environment["R4TMAX"]]; If[!IntegerQ[tmax], tmax = 600];
mode = Environment["R4MODE"]; If[mode === $Failed, mode = "AUTO"];
otag = Environment["R4OUTTAG"]; If[otag === $Failed, otag = "b27v3"];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica/"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];
groupCacheFile = Environment["R4GROUPCACHE"];
useGroupCache = StringQ[groupCacheFile] && groupCacheFile =!= "" &&
  FileExistsQ[groupCacheFile];
If[useGroupCache,
  groupCacheData = Get[groupCacheFile];
  If[!AssociationQ[groupCacheData] ||
     !IntegerQ[Lookup[groupCacheData, "OriginalTerms", 0]] ||
     Head[Lookup[groupCacheData, "Keys", 0]] =!= List ||
     Head[Lookup[groupCacheData, "Coefficients", 0]] =!= List ||
     Length[groupCacheData["Keys"]] =!=
       Length[groupCacheData["Coefficients"]],
    Print["FATAL invalid R4 group cache ", groupCacheFile]; Quit[1]];
  angterms = {};
  ntot = groupCacheData["OriginalTerms"],
  Get[root <> "r4in_" <> piece <> ".m"];
  If[Head[angterms] =!= List || Length[angterms] === 0,
     Print["FATAL: angterms empty or not a List (head ", Head[angterms], ")"];
     Quit[1]];
  ntot = Length[angterms]];
part = ToExpression[Environment["R4PART"]]; If[!IntegerQ[part], part = 1];
npart = ToExpression[Environment["R4NPART"]]; If[!IntegerQ[npart], npart = 1];
rr = ToExpression[Environment["R4RR"]];
gateIndices = Environment["R4INDICES"];
If[useGroupCache,
  If[gateIndices =!= $Failed || npart =!= 1,
    Print["FATAL R4 group cache supports only the complete unsliced input"];
    Quit[1]];
  tag = "all"; part = 1; npart = 1,
  If[gateIndices =!= $Failed,
    gateIndices = ToExpression["{" <> gateIndices <> "}"];
    If[!VectorQ[gateIndices, IntegerQ] ||
       AnyTrue[gateIndices, # < 1 || # > ntot &],
      Print["FATAL invalid R4INDICES"]; Quit[1]];
    angterms = angterms[[gateIndices]];
    tag = "gate"; part = 1; npart = 1;
    Print["R4 exact selected global indices ", gateIndices],
   If[rr === 1 && npart > 1,
    angterms = angterms[[part ;; -1 ;; npart]]; tag = "rr",
    If[npart > 1,
       angterms = Take[angterms, {Floor[(part - 1) ntot/npart] + 1,
                                  Floor[part ntot/npart]}]; tag = "part",
       tag = "all"]]]];
Print["R4v2 PIECE ", piece, "  MODE ", mode, "  slice ", tag, part, "/", npart,
      "  terms ", If[useGroupCache, ntot, Length[angterms]], " of ", ntot,
      "  kernels ", nk,
      "  tmax ", tmax, " s"];

(* BUG F: the substitution MUST be sequential -- a single ReplaceAll with both
   rules never converts the s23 introduced by the u1 rule. *)
prepRaw[t_] := t /. u1 -> s23 - s - t1 - Q2 /. s23 -> W^2;
physArg[e_] := e /.
  {Sqrt[W^(-2)] -> 1/W,
   Sqrt[W^2] -> W,
   (W^2)^(3/2) -> W^3,
   Sqrt[(s + t1)^2/W^2] Sqrt[W^2] -> Sqrt[(s + t1)^2],
   Abs[Q2/2 + s/2 + (-Q2-s-t1+W^2)/2] -> (W^2-t1)/2,
   Abs[-t1/2 + W^2/2] -> (W^2-t1)/2};
physW[e_] := e /.
  Power[b_, -1-eps] :> Power[Together[physArg[b]], -1-eps] /.
  PolyLog[2, a_] :> PolyLog[2, Together[physArg[a]]];
prep[t_] := physW[prepRaw[t]];

(* DIRECT: the definition.  `free` is pulled out because SeriesCoefficient is
   multiplicative over W-free factors, and the bulk of every R3 term is a W-free
   rational function of s, t1, Q2, eps. *)
residDirect[t_] := Module[{v, fac, free, dep},
  v = prep[t];
  fac = If[Head[v] === Times, List @@ v, {v}];
  free = Times @@ Select[fac, FreeQ[#, W] &];
  dep = Select[fac, ! FreeQ[#, W] &];
  If[dep === {}, 0, free SeriesCoefficient[Times @@ dep, {W, 0, -2}]]];

(* Candidate additive engine, staged 2026-07-26 and NOT selected unless the
   independent Hqq_additive_series_probe exact gate passes.  It uses only
   linearity of SeriesCoefficient.  The largest W-dependent Plus is selected,
   literal factors common to every addend are removed first, and the direct
   coefficient definition is applied to each primitive addend. *)
commonExact[sum_] := Module[{ts, fs, cf, prim},
  ts = If[Head[sum] === Plus, List @@ sum, {sum}];
  fs = (If[Head[#] === Times, List @@ #, {#}] &) /@ ts;
  cf = If[Length[fs] == 1, {}, Fold[Intersection, First[fs], Rest[fs]]];
  prim = Total[Times @@ DeleteCases[#, Alternatives @@ cf] & /@ fs];
  {Times @@ cf, prim}];

(* Exact Appendix-B27 coefficient engine.

   IMPORTANT: a B27 factor whose dilogarithm argument tends to one is not
   analytic in W.  If
       warg = 1-a W^2+O(W^4),
   then
       Li2[warg] = Pi^2/6
         + a W^2 (Log[a]+2 Log[W]-1)+O(W^4 Log[W]).
   The old V3 engine retained only the constant.  That is sufficient for a
   W^(-2+c eps) term but WRONG for a W^(-4+c eps) term, where the displayed
   W^2 Log[W] contributes to the endpoint residue.  LW is kept inert here and
   is converted to (1/2) Log[s23] only when the endpoint classes are emitted.

   We deliberately support this branch only through W^3 (the W^3 coefficient
   is exactly zero because the argument is rational in W^2).  A term
   requesting W^4 or higher is quarantined rather than guessed. *)
endpointAbs[e_] := e /.
  {Abs[Q2/2 + s/2 + (-Q2-s-t1+W^2)/2] -> (W^2-t1)/2,
   Abs[-t1/2 + W^2/2] -> (W^2-t1)/2};

(* Branch-preserving local expansion for the QGG endpoint radical.

   Do not globally rewrite
     Sqrt[Q2 + (s+t1)^2/(4 W^2)]
   as Sqrt[(s+t1)^2+4 Q2 W^2]/(2 W): although their squares agree for
   W>0, that broad rewrite failed the established exact three-term gate by
   losing symbolic branch bookkeeping.  Instead ask Series to expand only the
   elementary Power itself.  Mathematica then retains Sqrt[(s+t1)^2]
   explicitly, e.g.
     b^(-1/2) = 2 W/Sqrt[(s+t1)^2] + O(W^3),
   with no sign choice for s+t1.  Signature 37 contains hundreds of these
   inverse roots inside a large Plus; expanding the small repeated factor
   before the Plus is assembled removes the timeout without changing the
   surrounding expression. *)
localQGGRootSeries[e_, n_Integer] := If[
  Environment["R4LOCALQGGROOT"] =!= "1", e, e /. {
  HoldPattern[
    Power[Q2 + s^2/(4 W^2) + s t1/(2 W^2) + t1^2/(4 W^2),
          p : (-1/2 | 1/2 | 3/2)]] :>
    Normal[Series[
      Power[Q2 + (s + t1)^2/(4 W^2), p], {W, 0, n}]]
  }];

baseSeries[b_, n_Integer] := Module[{bb, cp, common, primitive},
  bb = localQGGRootSeries[endpointAbs[b], 8 + n];
  cp = commonExact[bb]; {common, primitive} = cp;
  If[Head[primitive] === Plus,
    common Total[Quiet[Series[#, {W, 0, n}]] & /@ (List @@ primitive)],
    common Quiet[Series[primitive, {W, 0, n}]]]];
baseCoefficientsRaw[b_, n_Integer] := Module[
  {sr, poly, k, q, wa, arg, oma, a2},
  wa = Cases[b, PolyLog[2, a_] :> a, Infinity];
  If[Length[wa] === 1 &&
     Simplify[b - (1 + eps^2 PolyLog[2, First[wa]])] === 0 &&
     Together[endpointAbs[First[wa]] /. W -> 0] === 1,
    If[n > 3, Return[$Failed]];
    arg = Together[endpointAbs[First[wa]]];
    oma = Together[1-arg];
    If[Together[SeriesCoefficient[oma, {W, 0, 0}]] =!= 0 ||
       Together[SeriesCoefficient[oma, {W, 0, 1}]] =!= 0,
      Return[$Failed]];
    a2 = Together[SeriesCoefficient[oma, {W, 0, 2}]];
    Return[{0, Take[
      {1 + eps^2 Pi^2/6, 0,
       eps^2 a2 (Log[a2] + 2 LW - 1), 0}, n + 1]}]];
  sr = baseSeries[endpointAbs[b], 8 + n];
  If[Head[sr] === SeriesData && sr[[3]] =!= {},
    k = sr[[4]]/sr[[6]]; poly = Normal[sr],
    poly = Quiet[Expand[Normal[sr]]];
    If[!PolynomialQ[poly W^Max[0, -Exponent[poly, W, Min]], W],
      Return[$Failed]];
    k = Exponent[poly, W, Min]];
  If[!IntegerQ[k], Return[$Failed]];
  q = Expand[poly/W^k];
  {k, Table[Coefficient[q, W, j], {j, 0, n}]}];
$baseCoefficientCache = <||>;
baseCoefficients[b_, n_Integer] := Module[{key, value},
  (* Exact small-base memoization.  The same endpoint denominators and B27
     bases recur across thousands of R3 addends.  Do not cache giant unique
     numerators: retaining them would trade CPU time for unbounded RAM. *)
  If[LeafCount[Unevaluated[b]] > 500,
    Return[baseCoefficientsRaw[b, n]]];
  key = HoldComplete[b, n];
  If[KeyExistsQ[$baseCoefficientCache, key],
    Return[$baseCoefficientCache[key]]];
  value = baseCoefficientsRaw[b, n];
  AssociateTo[$baseCoefficientCache, key -> value];
  value];
regularFactor[b_, e_, n_Integer] := Module[{dat, k, qpoly, fp},
  dat = baseCoefficients[b, n];
  If[dat === $Failed, Return[$Failed]];
  {k, qpoly} = dat;
  qpoly = Sum[qpoly[[j + 1]] W^j, {j, 0, n}];
  fp = Normal[Series[qpoly^e, {W, 0, n}]];
  {k e, fp}];
splitLW[e_] := Module[{v, deg, ans},
  v = Expand[e];
  If[v === 0, Return[{}]];
  deg = Exponent[v, LW];
  If[!IntegerQ[deg] || deg > 1, Return[$Failed]];
  ans = DeleteCases[
    {{0, Together[v /. LW -> 0]},
     {1, Together[Coefficient[v, LW, 1]/2]}}, {_, 0}];
  ans];

(* Return every negative W power, not merely W^-2.  Residue classes are keyed
   by Class[c,l], where W^(-2+c eps) Log[W]^l becomes
   s23^(-1+c eps/2) (Log[s23]/2)^l before the global dPi3 factor.
   Negative even powers below -2 and all negative odd powers are retained in
   separate exact-cancellation sinks.  They are a hard merge gate. *)
residV4Core[v_] := Module[
  {fac, free, dep, rf, tot, p, c, nmax, polys, prod, coeff, logs,
   r = {}, deep = {}, odd = {}, k, j, l, val, key},
  fac = If[Head[v] === Times, List @@ v, {v}];
  free = Times @@ Select[fac, FreeQ[#, W] &];
  dep = Select[fac, !FreeQ[#, W] &];
  If[dep === {}, Return[<|"Residue" -> {}, "Deep" -> {}, "Odd" -> {}|>]];
  rf = Map[
    Function[f, If[MatchQ[f, Power[_, _]],
      regularFactor[First[f], Last[f], 0], regularFactor[f, 1, 0]]], dep];
  If[MemberQ[rf, $Failed], Return[$Failed]];
  tot = Simplify[Total[rf[[All, 1]]]];
  p = Simplify[tot /. eps -> 0];
  c = Simplify[Coefficient[tot, eps]];
  If[!IntegerQ[p] || !IntegerQ[c], Return[$Failed]];
  nmax = -1 - p;
  If[nmax < 0,
    Return[<|"Residue" -> {}, "Deep" -> {}, "Odd" -> {}|>]];
  rf = Map[
    Function[f, If[MatchQ[f, Power[_, _]],
      regularFactor[First[f], Last[f], nmax],
      regularFactor[f, 1, nmax]]], dep];
  If[MemberQ[rf, $Failed], Return[$Failed]];
  polys = rf[[All, 2]];
  prod = Fold[Normal[Series[#1 #2, {W, 0, nmax}]] &, 1, polys];
  Do[
    k = p + j;
    coeff = physArg[free Coefficient[prod, W, j]];
    logs = splitLW[coeff];
    If[logs === $Failed, Return[$Failed]];
    Do[
      {l, val} = lv;
      If[val =!= 0,
        If[k === -2,
          AppendTo[r, {Class[c, l], val}],
          key = Class[c, k, l];
          If[OddQ[k], AppendTo[odd, {key, val}],
                       AppendTo[deep, {key, val}]]]],
      {lv, logs}],
    {j, 0, nmax}];
  <|"Residue" -> r, "Deep" -> deep, "Odd" -> odd|>];
residV4[t_] := residV4Core[prep[t]];

singularKernelFactorQ[f_] := Module[{e},
  If[FreeQ[f, W], Return[False]];
  If[!FreeQ[f, PolyLog], Return[True]];
  If[Head[f] =!= Power, Return[False]];
  e = Last[f];
  !IntegerQ[e] || TrueQ[e < 0]];

endpointParts[t_] := Module[
  {v, fac, kernelFactors, coefficientFactors, kernelKey},
  v = prep[t];
  fac = If[Head[v] === Times, List @@ v, {v}];
  kernelFactors = Select[fac, singularKernelFactorQ];
  coefficientFactors = Select[fac, !singularKernelFactorQ[#] &];
  kernelKey = With[{k = Times @@ kernelFactors}, HoldComplete[k]];
  {kernelKey, Times @@ coefficientFactors}];
largestPlusPos[list_] := Module[{ps},
  ps = Flatten[Position[list, _Plus, {1}]];
  If[ps === {}, Missing["none"],
    First[MaximalBy[ps, LeafCount[list[[#]]] &]]]];
residAdditive[t_] := Module[
  {v, fac, free, dep, pos, add, other, cp, common, primitive},
  v = prep[t];
  fac = If[Head[v] === Times, List @@ v, {v}];
  free = Times @@ Select[fac, FreeQ[#, W] &];
  dep = Select[fac, !FreeQ[#, W] &];
  If[dep === {}, Return[0]];
  pos = largestPlusPos[dep];
  If[MissingQ[pos],
    Return[free SeriesCoefficient[Times @@ dep, {W, 0, -2}]]];
  add = dep[[pos]];
  other = Times @@ Delete[dep, pos];
  cp = commonExact[add]; {common, primitive} = cp;
  If[Head[primitive] === Plus,
    free common Total[
      (SeriesCoefficient[other #, {W, 0, -2}] &) /@ (List @@ primitive)],
    free common SeriesCoefficient[other primitive, {W, 0, -2}]]];

leadOrder[b_] := Module[{sr},
  sr = Quiet[Series[b, {W, 0, 8}]];
  If[Head[sr] =!= SeriesData || sr[[3]] === {}, Return[$Failed]];
  sr[[4]]/sr[[6]]];
(* The vanishing order is read from SERIES, ALWAYS.  The first version gated on
   `b /. W -> 0 === 0`, which is FALSE for a base that is a removable 0/0 at
   W = 0 -- `Quiet[b /. W -> 0]` returns Indeterminate, not 0 -- so on exactly
   those bases the lift silently did nothing and the residue came out wrong.
   MEASURED (job 14150258 `spldiag`, MR2PPQGG terms 3480 and 5678): the untouched
   factors were 1373- and 2366-leaf bases reporting `base at W=0 Indeterminate`,
   and SPLIT then disagreed with the definition.  Both signs of k are lifted: a
   base may also be SINGULAR at W = 0 (lead order -2 occurs). *)
splitPow[f_] := Module[{b, e, k, q},
  If[! MatchQ[f, Power[_, _]], Return[{1, f}]];
  {b, e} = List @@ f;
  If[FreeQ[b, W], Return[{1, f}]];
  If[MatchQ[b, W], Return[{W^e, 1}]];
  k = leadOrder[b];
  If[! IntegerQ[k] || k === 0, Return[{1, f}]];
  q = b/W^k;
  {W^(k e), q^e}];
residSplit[t_] := Module[{v, fac, free, dep, sp, wp, reg, ex, p, c},
  v = prep[t];
  fac = If[Head[v] === Times, List @@ v, {v}];
  free = Times @@ Select[fac, FreeQ[#, W] &];
  dep = Select[fac, ! FreeQ[#, W] &];
  If[dep === {}, Return[0]];
  sp = splitPow /@ dep;
  wp = Times @@ sp[[All, 1]];
  reg = Times @@ sp[[All, 2]];
  ex = Simplify[If[FreeQ[wp, W], 0, Exponent[wp, W]]];
  p = ex /. eps -> 0; c = Coefficient[ex, eps];
  If[! IntegerQ[p] || ! IntegerQ[c], Return[$Failed]];
  free SeriesCoefficient[reg, {W, 0, -2 - p}]];

(* AUTO (default).  MEASURED cost structure: ~95% of terms are trivial under the
   DEFINITION (0.03 s) while a clustered ~5% (15% for the g projection) carry a
   `Power[P, -1-eps]` whose base VANISHES at W = 0 and never finish -- under
   engine v1 they ate the entire 300 s cap each and were then QUARANTINED, which
   is where MR2PPQGG's 8 v2 slices spent most of their ~20 min (363 terms x 300 s
   of pure waiting).  The split route handles exactly that class and is validated
   EXACT against the definition (`SPLIT != DIRECT : 0`, job 14150323).
   So: CLASSIFY first, then fall back.  `pathological` is a cheap structural test
   -- a W-dependent Power with a NON-NUMERIC exponent whose base vanishes (or is
   a removable 0/0) at W = 0.  Misclassification is caught by the fallback, so
   the classifier only has to be fast, not perfect. *)
pathological[t_] := Module[{v, fac, b0},
  v = prep[t];
  fac = If[Head[v] === Times, List @@ v, {v}];
  AnyTrue[fac, MatchQ[#, Power[_, _]] && ! FreeQ[First[#], W] &&
                ! MatchQ[First[#], W] && ! NumericQ[Last[#]] &&
                (b0 = Quiet[First[#] /. W -> 0];
                 b0 === 0 || Head[b0] === Indeterminate) &]];
tmax2 = ToExpression[Environment["R4TMAX2"]]; If[!IntegerQ[tmax2], tmax2 = 900];
residAuto[t_] := Module[{r, first, second, t1x, t2x},
  {first, second} = If[pathological[t], {residSplit, residDirect},
                                        {residDirect, residSplit}];
  {t1x, t2x} = If[pathological[t], {tmax2, tmax}, {tmax, tmax2}];
  r = TimeConstrained[first[t], t1x, $Failed];
  If[r === $Failed || r === Null, r = TimeConstrained[second[t], t2x, $Failed]];
  r];

resid = Switch[mode, "V4", residV4, "V3", residV3,
                     "SPLIT", residSplit,
                     "DIRECT", residDirect, "ADDITIVE", residAdditive,
                     _, residAuto];
residTC[i_, t_] := Module[{r},
  r = If[mode === "AUTO", resid[t], TimeConstrained[resid[t], tmax, $Failed]];
  If[r === $Failed || r === Null, {i, 0}, {0, r}]];

t0 = AbsoluteTime[];
groupFlag = Environment["R4GROUPED"];
grouped = mode === "V4" && groupFlag =!= "0";
workTerms = angterms;
If[grouped,
  tg = AbsoluteTime[];
  If[useGroupCache,
    endpointGroupKeys = groupCacheData["Keys"];
    endpointGroupCoefficients = groupCacheData["Coefficients"];
    Clear[groupCacheData];
    Print["R4 EXACT SIGNATURE CACHE: ", ntot, " terms -> ",
          Length[endpointGroupKeys], " endpoint signatures loaded in ",
          AbsoluteTime[]-tg, " s"],
    endpointPartList = endpointParts /@ angterms;
    endpointGroupLists = GroupBy[endpointPartList, First -> Last];
    endpointGroupKeys = Keys[endpointGroupLists];
    (* GroupBy[..., First -> Last] has ALREADY applied Last to each
       {kernelKey, coefficient} pair.  Applying Last again here selects the
       final argument of each coefficient expression and silently strips its
       normalization/coupling factors.  This was caught by the exact
       grouped-vs-ungrouped gate on global terms 5067, 6241, 6641. *)
    endpointGroupCoefficients = Values[endpointGroupLists];
    Print["R4 EXACT SIGNATURE GROUPING: ", Length[angterms], " terms -> ",
          Length[endpointGroupKeys], " endpoint signatures in ",
          AbsoluteTime[]-tg, " s"]];
  If[Environment["R4GROUPEXPORT"] === "1",
    groupExport = <|
      "OriginalTerms" -> Length[angterms],
      "Keys" -> endpointGroupKeys,
      "Coefficients" -> endpointGroupCoefficients|>;
    groupExportFile = root <> "r4groups_" <> piece <> ".m";
    Put[groupExport, groupExportFile];
    groupCounts = Length /@ endpointGroupCoefficients;
    Print["R4 GROUP EXPORT ", groupExportFile,
          " coefficient counts ", groupCounts,
          " total ", Total[groupCounts],
          " max ", Max[groupCounts]];
    Clear[groupExport]];
  If[Environment["R4GROUPONLY"] === "2",
    Do[Print["R4_GROUP_SAMPLE ", j, " key ",
      InputForm[Short[endpointGroupKeys[[j]], 4]], " members ",
      Length[endpointGroupCoefficients[[j]]]],
      {j, Min[8, Length[endpointGroupKeys]]}]];
  showGroup = ToExpression[Environment["R4SHOWGROUP"]];
  If[IntegerQ[showGroup],
    If[showGroup < 1 || showGroup > Length[endpointGroupKeys],
      Print["FATAL invalid R4SHOWGROUP"]; Quit[1]];
    Print["R4 SHOW GROUP ", showGroup, " members ",
      Length[endpointGroupCoefficients[[showGroup]]],
      " coefficient LeafCounts ",
      LeafCount /@ endpointGroupCoefficients[[showGroup]]];
    Put[<|"Kernel" -> ReleaseHold[endpointGroupKeys[[showGroup]]],
          "Coefficients" -> endpointGroupCoefficients[[showGroup]]|>,
        root <> "r4group_" <> piece <> "_" <> ToString[showGroup] <> ".m"];
    Print["R4_SHOW_GROUP_DONE"]; Quit[0]];
  If[MemberQ[{"1", "2"}, Environment["R4GROUPONLY"]],
    Print["R4_GROUP_ONLY_DONE"]; Quit[0]]];

(* Optional coefficient-level sharding of known hard signatures across
   independent master kernels.  Each shard takes a round-robin subsequence;
   summing all shard outputs therefore reconstructs the original grouped
   coefficient exactly by linearity. *)
shardText = Environment["R4SHARDSIGS"];
shardId = ToExpression[Environment["R4SHARDID"]];
nShards = ToExpression[Environment["R4NSHARDS"]];
If[grouped && shardText =!= $Failed && shardText =!= "",
  shardSigs = ToExpression["{" <> shardText <> "}"];
  If[!VectorQ[shardSigs, IntegerQ] ||
     AnyTrue[shardSigs, # < 1 || # > Length[endpointGroupKeys] &] ||
     !IntegerQ[shardId] || !IntegerQ[nShards] ||
     shardId < 1 || shardId > nShards,
    Print["FATAL invalid R4 signature shard specification"]; Quit[1]];
  Do[
    (* Span[start ;; -1 ;; step] emits Part::take instead of {} when start is
       beyond the list length.  Construct explicit valid positions so workers
       with an empty shard contribute the exact zero Association. *)
    allShardCoeffs = endpointGroupCoefficients[[si]];
    shardPositions = Range[shardId, Length[allShardCoeffs], nShards];
    shardCoeffs = If[shardPositions === {}, {},
      allShardCoeffs[[shardPositions]]];
    If[shardCoeffs === {},
      Print["R4 empty signature shard ", si, " worker ", shardId, "/",
            nShards]];
    endpointGroupCoefficients[[si]] = shardCoeffs;
    Print["R4 signature shard ", si, " worker ", shardId, "/", nShards,
          " members ", Length[shardCoeffs]],
    {si, shardSigs}]];
If[Environment["R4SHARDONLY"] === "1",
  Print["R4_SHARD_ONLY_DONE"]; Quit[0]];

adaptText = Environment["R4ADAPTINDICES"];
adaptIndices = If[adaptText === $Failed || adaptText === "", {},
  ToExpression["{" <> adaptText <> "}"]];

(* Construct each ordinary summed signature only AFTER coefficient sharding.
   Adaptive signatures are processed directly from their small coefficient
   batches, so never build their potentially enormous Total at all. *)
workTerms = MapThread[
  If[#2 === {}, 0,
    If[MemberQ[adaptIndices, #3], ReleaseHold[#1],
      Total[#2] ReleaseHold[#1]]] &,
  {endpointGroupKeys, endpointGroupCoefficients,
   Range[Length[endpointGroupKeys]]}];

sigText = Environment["R4SIGINDICES"];
If[grouped && sigText =!= $Failed && sigText =!= "",
  sigIndices = ToExpression["{" <> sigText <> "}"];
  If[!VectorQ[sigIndices, IntegerQ] ||
     AnyTrue[sigIndices, # < 1 || # > Length[workTerms] &] ||
     DuplicateFreeQ[sigIndices] =!= True,
    Print["FATAL invalid R4SIGINDICES"]; Quit[1]];
  workTerms = workTerms[[sigIndices]];
  idx = sigIndices;
  Print["R4 selected endpoint signatures ", sigIndices],
  idx = Range[Length[workTerms]]];
indexedWork = Transpose[{idx, workTerms}];
workByIndex = AssociationThread[idx -> workTerms];

subTmax = ToExpression[Environment["R4SUBTMAX"]];
If[!IntegerQ[subTmax] || subTmax < 1, subTmax = 90];
adaptBatch = ToExpression[Environment["R4ADAPTBATCH"]];
If[!IntegerQ[adaptBatch] || adaptBatch < 1, adaptBatch = 4];
singletonText = Environment["R4SINGLETONINDICES"];
singletonIndices = If[singletonText === $Failed || singletonText === "", {},
  ToExpression["{" <> singletonText <> "}"]];

combineV4Results[rs_] := Association[
  "Residue" -> Flatten[Lookup[rs, "Residue"], 1],
  "Deep" -> Flatten[Lookup[rs, "Deep"], 1],
  "Odd" -> Flatten[Lookup[rs, "Odd"], 1]];

adaptiveCoefficientResidue[coeffs_, kernel_, depth_:0] := Module[
  {r, cut, left, right},
  r = TimeConstrained[
    residV4Core[prep[Total[coeffs] kernel]], subTmax, $Failed];
  If[r =!= $Failed && r =!= Null, Return[r]];
  If[Length[coeffs] <= 1,
    Print["R4 ADAPTIVE FATAL singleton timeout at depth ", depth];
    Return[$Failed]];
  cut = Ceiling[Length[coeffs]/2];
  Print["R4 ADAPTIVE SPLIT depth ", depth, " members ", Length[coeffs],
        " -> ", cut, "+", Length[coeffs]-cut];
  left = adaptiveCoefficientResidue[Take[coeffs, cut], kernel, depth+1];
  right = adaptiveCoefficientResidue[Drop[coeffs, cut], kernel, depth+1];
  If[left === $Failed || right === $Failed, $Failed,
    combineV4Results[{left, right}]]];

(* Known hard signatures must not pay a full timeout at 161, 81, 41, ...
   coefficients before reaching the small groups that actually finish.
   Partition immediately into small exact batches, checkpoint every successful
   batch, and use recursive bisection only inside one batch.  The subcheckpoint
   filename includes the output tag, so a changed engine cannot load stale
   results. *)
adaptiveSignatureResidue[sig_, coeffs_, kernel_] := Module[
  {chunks, rs = {}, fn, r, b, batchSize},
  batchSize = If[MemberQ[singletonIndices, sig], 1, adaptBatch];
  chunks = Partition[coeffs, UpTo[batchSize]];
  Print["R4 ADAPTIVE FIXED-BATCH signature ", sig, " members ",
        Length[coeffs], " batches ", Length[chunks], " size ", batchSize,
        " subcap ", subTmax, " s"];
  Do[
    fn = root <> "r4subckpt_" <> piece <> "_" <> otag <> tag <>
      ToString[part] <> "_sig" <> IntegerString[sig, 10, 3] <> "_" <>
      IntegerString[b, 10, 4] <> ".m";
    If[FileExistsQ[fn],
      r = Get[fn];
      If[!AssociationQ[r], Print["FATAL invalid subcheckpoint ", fn];
        Return[$Failed]],
      r = adaptiveCoefficientResidue[chunks[[b]], kernel];
      If[r === $Failed || r === Null, Return[$Failed]];
      Put[r, fn]];
    AppendTo[rs, r];
    Print["R4 adaptive signature ", sig, " batch ", b, "/",
          Length[chunks], " complete"];
    (* Timed-out symbolic attempts can leave large internal caches.  Each
       accepted sub-batch is already durable, so release them here. *)
    $baseCoefficientCache = <||>;
    ClearSystemCache[],
    {b, Length[chunks]}];
  combineV4Results[rs]];

residTCDispatch[item_] := Module[{i = item[[1]], t = item[[2]], r},
  If[grouped && MemberQ[adaptIndices, i],
    If[endpointGroupCoefficients[[i]] === {},
      Return[{0, <|"Residue" -> {}, "Deep" -> {}, "Odd" -> {}|>}]];
    Print["R4 ADAPTIVE START signature ", i, " members ",
          Length[endpointGroupCoefficients[[i]]],
          " subcap ", subTmax, " s"];
    r = adaptiveSignatureResidue[i,
      endpointGroupCoefficients[[i]],
      ReleaseHold[endpointGroupKeys[[i]]]];
    If[r === $Failed || r === Null, {i, 0}, {0, r}],
    residTC[i, t]]];

If[nk > 0,
  LaunchKernels[nk];
  DistributeDefinitions[prepRaw, physArg, physW, prep, residDirect,
                        commonExact, endpointAbs, localQGGRootSeries, baseSeries,
                        baseCoefficientsRaw, baseCoefficients,
                        $baseCoefficientCache, regularFactor,
                        splitLW, residV4Core, residV4, residV3,
                        largestPlusPos, residAdditive, leadOrder,
                        splitPow, residSplit,
                        pathological, residAuto, resid, residTC,
                        combineV4Results, adaptiveCoefficientResidue,
                        adaptiveSignatureResidue,
                        residTCDispatch, endpointGroupCoefficients,
                        endpointGroupKeys, adaptIndices, subTmax, adaptBatch,
                        singletonIndices,
                        root, piece, otag, tag, part,
                        tmax, tmax2, mode, grouped],
  Print["R4 SERIAL MODE: no subkernels or expression replication"]];

runWork[ch_] := If[nk <= 0,
  Map[residTCDispatch, ch],
  ParallelMap[residTCDispatch, ch,
              Method -> "FinestGrained"]];

If[grouped,
  chunkSize = ToExpression[Environment["R4CHUNK"]];
  If[!IntegerQ[chunkSize] || chunkSize < 1, chunkSize = 64];
  workChunks = Partition[indexedWork, UpTo[chunkSize]];
  pairs = {};
  Do[
    checkpoint = root <> "r4ckpt_" <> piece <> "_" <> otag <> tag <>
      ToString[part] <> "_" <> IntegerString[ic, 10, 4] <> ".m";
    If[FileExistsQ[checkpoint],
      chunkPairs = Get[checkpoint];
      Print["R4 checkpoint ", ic, "/", Length[workChunks], " loaded"],
      chunkPairs = runWork[workChunks[[ic]]];
      (* Never checkpoint a failed group: a rerun with an improved exact
         branch or larger cap must retry it automatically. *)
      If[DeleteCases[chunkPairs[[All, 1]], 0] === {},
        Put[chunkPairs, checkpoint]]];
    pairs = Join[pairs, chunkPairs];
    Print["R4 progress signatures ", Min[ic chunkSize, Length[indexedWork]],
          "/", Length[indexedWork], "  elapsed ", AbsoluteTime[]-t0, " s"],
    {ic, Length[workChunks]}],
  pairs = runWork[indexedWork]];
If[nk > 0, CloseKernels[]];
slowIdx = DeleteCases[pairs[[All, 1]], 0];
If[mode === "V4",
  makeAssoc[lp_] := If[lp === {}, <||>,
    Merge[(Association[#[[1]] -> #[[2]]] &) /@ lp, Total]];
  good = DeleteCases[pairs[[All, 2]], 0];
  Rclasses = makeAssoc[Flatten[Lookup[good, "Residue"], 1]];
  Rdeep = makeAssoc[Flatten[Lookup[good, "Deep"], 1]];
  Rodd = makeAssoc[Flatten[Lookup[good, "Odd"], 1]];
  R = <|"Residue" -> Rclasses, "Deep" -> Rdeep, "Odd" -> Rodd|>;
  nz = Total[Length /@ Lookup[good, "Residue"]];
  rexpr = Total[Values[Rclasses]],
 If[mode === "V3",
  classPairs = DeleteCases[pairs[[All, 2]], {_, 0}];
  R = If[classPairs === {}, <||>,
    Merge[(Association[#[[1]] -> #[[2]]] &) /@ classPairs, Total]];
  nz = Length[classPairs];
  rexpr = Total[Values[R]],
  nz = Count[pairs[[All, 2]], e_ /; e =!= 0];
  R = Total[pairs[[All, 2]]];
  rexpr = R]];
Print["  residues ", AbsoluteTime[] - t0, " s   nonzero ", nz, " of ",
      Length[angterms]];
Print["  terms done ", Length[angterms] - Length[slowIdx],
      "   QUARANTINED ", Length[slowIdx],
      If[Length[slowIdx] > 0,
         "  indices " <> ToString[Take[slowIdx, UpTo[20]]], ""]];
Print["  RESIDUE COMPLETE ", Length[slowIdx] === 0,
      " (a nonempty quarantine means the residue is PARTIAL -- do not consume)"];
If[Length[slowIdx] > 0,
   Put[slowIdx, root <> "r4slow2_" <> piece <> "_" <> otag <> tag <>
       ToString[part] <> ".m"];
   If[grouped,
     Put[Lookup[workByIndex, slowIdx],
       root <> "r4slowexpr_" <> piece <> "_" <> otag <> tag <>
       ToString[part] <> ".m"]];
   Print["FATAL nonempty quarantine; no residue output written"];
   Quit[1]];
If[mode === "V4",
  Print["endpoint classes ", Sort[Keys[Rclasses]], " class LeafCounts ",
        Map[LeafCount, Rclasses]];
  Print["negative-power sinks: deep classes ", Sort[Keys[Rdeep]],
        " odd classes ", Sort[Keys[Rodd]]],
 If[mode === "V3",
  Print["endpoint classes ", Sort[Keys[R]], " class LeafCounts ",
        Map[LeafCount, R]]]];
Print["residue LeafCount ", LeafCount[R]];
stray = Select[{x, z, PHT, xi}, ! FreeQ[rexpr, #] &];
Print["frame gate stray ", stray, "  (must be {})   ",
      "ComplexInfinity-free ", FreeQ[rexpr, ComplexInfinity | Indeterminate],
      "   s23-free ", FreeQ[rexpr, s23]];
Put[R, root <> "r4out2_" <> piece <> "_" <> otag <> tag <> ToString[part] <> ".m"];

(* EXACTNESS GATE against a pre-BUG-K residue, when one is named.  For a piece
   whose merged residue PREDATES the zero-skip (see the blast radius above), the
   new engine must reproduce it EXACTLY -- that is what licenses reusing those
   artifacts instead of recomputing every channel. *)
ref = Environment["R4REF"];
If[mode =!= "V3" && ref =!= $Failed && FileExistsQ[root <> ref],
   Module[{R0, d},
     R0 = Get[root <> ref];
     d = Simplify[R - R0];
     Print["REFERENCE ", ref, "  LeafCount ", LeafCount[R0]];
     Print["R4v2_REF_DIFF ", If[d === 0, "0 (EXACT)", ToString[LeafCount[d]] <>
           " leaves NONZERO <<<"]]],
   Print["no R4REF given -- no exactness gate this run"]];
Print["R4_MMA_PART2_DONE ", piece, " ", tag, part];

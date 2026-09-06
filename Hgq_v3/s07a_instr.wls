#!/usr/bin/env wolframscript
(* s07a : one batch of the real -> s23 distribution extraction.

   The extraction is LINEAR in the summand, and the accumulated result stays
   small (~270 MB), but the process RSS grows ~150 MB per term through
   allocator fragmentation that ClearSystemCache cannot return to the OS.
   So each batch runs in its OWN kernel, writes its partial accumulator, and
   exits - which returns all memory.  Bounded by construction.

   env:  HGQ_PROJ = Wg3 | Wpp3 ,  HGQ_I0 , HGQ_I1  (1-based, inclusive)      *)

Get["/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/hgq_common.m"];
LF="/tmp/claude-1000/-home-physics-projects-AI-Assisted-SIDIS/450b2cb3-e563-47ca-83c2-0786d3cd94a0/scratchpad/instr.log";
log[x___]:=Module[{ff=OpenAppend[LF]},WriteString[ff,StringJoin[ToString/@{x}],"\n"];Close[ff]];
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3";
s04r = Get[FileNameJoin[{dir, "s04_result.m"}]];
proj = Environment["HGQ_PROJ"];
i0 = ToExpression[Environment["HGQ_I0"]];
i1 = ToExpression[Environment["HGQ_I1"]];

Mcoef[m_] := Mcoef[m] = Simplify[(-1)^m D[-BB^(-eps)/eps, {eps, m}]];

(* Residue at s23=0.  Limit is the step that explodes: on term Wg3 156 it ran
   past 100 s and >7 GB on an expression of only 1738 leaves.  Every term is
   (rational in s23) x (transcendental regular at s23=0), so Laurent-expand the
   two factors separately - both small - and read off the sig^0 coefficient of
   sig*f.  Validated against Limit on real terms: difference exactly 0.      *)
transQ[e_] := ! FreeQ[e, Log | PolyLog | PolyGamma];
(* Expanding the transcendental factor was the whole per-term cost: 44-60 s on
   the big terms, while every other step measured 0 s.  But only the order-1
   expansion is ever used, and every Log/PolyLog here depends on sig solely
   through R = Sqrt[(s+t)^2 + 4 Q2 sig], analytic at sig=0 (R -> |s+t|, away
   from every branch point).  So f(0) + f'(0) sig IS the expansion: one
   derivative and two substitutions replace the full Series machinery, and the
   six PolyLog[2,...] are never expanded as functions at all.
   Falls back to Series if the expression is not analytic at sig=0.
   Gated on terms 145/158/161: residues identical at two random kinematic
   points; 0.52->0.02 s, 60.12->0.7 s, 44.51->1.6 s.                         *)
dser[f_] := Module[{f0, f1},
   f0 = f /. sig -> 0;
   f1 = D[f, sig] /. sig -> 0;
   If[! FreeQ[{f0, f1}, DirectedInfinity | Indeterminate | ComplexInfinity],
     Normal[Series[f, {sig, 0, 1}]], f0 + f1 sig]];
sigResidue[f_] := Module[{tl, tot = 0},
  tl = If[Head[f] === Plus, List @@ f, {f}];
  Do[Module[{fc, tr, ra, sa, st},
     fc = If[Head[tm] === Times, List @@ tm, {tm}];
     tr = Times @@ Select[fc, transQ];
     ra = Times @@ Select[fc, ! transQ[#] &];
     If[FreeQ[ra, sig] && FreeQ[tr, sig], Continue[]];
     sa = Normal[Series[sig ra, {sig, 0, 1}]];
     st = dser[tr];
     tot += Coefficient[Expand[sa st], sig, 0]], {tm, tl}];
  tot];

pfRaw = s04r["dPi3"]/(2 Pi)^4;
pf = Normal[Series[(pfRaw /. u -> sig - s - t - Q2) sig^eps, {eps, 0, 1}]];
bulk = (s04r[proj]/pfRaw) /. u -> sig - s - t - Q2;
bulk = bulk /. Power[b_, e_] /; ! FreeQ[e, eps] :> Power[b, Simplify[e]];
(* The angular-integral variable D = (2Q^2+s+t)/Sqrt[(s+t)^2+4 Q^2 s23] arrives
   with s23=sig split across two radicals, as Sqrt[sig] Sqrt[(...)/sig].  Series
   in sig then has to expand a nested radical about the expansion point, which
   costs minutes on a 4400-leaf term whose only pole is a plain sig^-1.
   Sqrt[N/sig] -> Sqrt[N]/Sqrt[sig] collapses the pair to Sqrt[N]; valid since
   sig>0 and N>0 in the physical region.  Checked numerically on all 187 terms:
   none differ, and no nested Sqrt[.../sig] survives.                        *)
bulk = bulk //. Power[b_, r_Rational] /; ! FreeQ[b, sig] && Denominator[r] === 2 :>
    Power[Numerator[Together[b]], r] Power[Denominator[Together[b]], -r];
terms = Module[{fac, sums, rest},
   Which[
    Head[bulk] === Plus, List @@ bulk,
    Head[bulk] === Times,
     fac = List @@ bulk; sums = Select[fac, Head[#] === Plus &];
     rest = Times @@ Select[fac, Head[#] =!= Plus &];
     If[Length[sums] == 1, (rest #) & /@ (List @@ First[sums]), {bulk}],
    True, {bulk}]];
n = Length[terms];
i1 = Min[i1, n];
Print["[s07a] ", proj, " terms ", i0, "-", i1, " of ", n];
If[i0 > n, Print["[s07a] nothing to do"]; Quit[0]];

acc = <|"del" -> 0, "p" -> {0, 0, 0, 0}, "reg" -> 0|>;
t0 = AbsoluteTime[];
Do[Module[{g, sing, rg, tA, tT = AbsoluteTime[]},
   g = Normal[Series[pf terms[[i]], {eps, 0, 1}]];
   g = Collect[g, Log[sig]];
   sing = Table[sigResidue[Coefficient[g, Log[sig], m]], {m, 0, 2}];
   rg = g - Sum[sing[[m + 1]] Log[sig]^m/sig, {m, 0, 2}];
   acc["del"] += Sum[sing[[m + 1]] Mcoef[m], {m, 0, 2}];
   acc["p"] += Table[Sum[If[k + m == r, sing[[m + 1]] (-eps)^k/k!, 0], {m, 0, 2}, {k, 0, 3}], {r, 0, 3}];
   tA = AbsoluteTime[];
   acc["reg"] += Normal[Series[sig^(-eps) rg, {eps, 0, 1}]];
   log["term ", i, "  termtime=", Round[AbsoluteTime[] - tT, 0.01],
       " s  accStep=", Round[AbsoluteTime[] - tA, 0.01],
       " s  accRegLC=", LeafCount[acc["reg"]], "  elapsed=", Round[AbsoluteTime[] - t0, 0.01]];
   ClearSystemCache[]],
 {i, i0, i1}];
Print["[s07a] batch done in ", Round[AbsoluteTime[] - t0], " s"];
tag = "INSTR_" <> proj <> "_" <> ToString[i0] <> "_" <> ToString[i1];
Put[acc, FileNameJoin[{dir, "s07part_" <> tag <> ".m"}]];
Print["[s07a] wrote s07part_", tag, ".m"];

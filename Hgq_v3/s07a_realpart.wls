#!/usr/bin/env wolframscript
(* s07a : one batch of the real -> s23 distribution extraction.

   The extraction is LINEAR in the summand, and the accumulated result stays
   small (~270 MB), but the process RSS grows ~150 MB per term through
   allocator fragmentation that ClearSystemCache cannot return to the OS.
   So each batch runs in its OWN kernel, writes its partial accumulator, and
   exits - which returns all memory.  Bounded by construction.

   env:  HGQ_PROJ = Wg3 | Wpp3 ,  HGQ_I0 , HGQ_I1  (1-based, inclusive)      *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
(* Per-term progress, flushed to disk each line: a batch piped through grep
   buffers and shows nothing until it exits, which repeatedly made a healthy
   run indistinguishable from a hung one. *)
PLF = FileNameJoin[{dir, "s07a_progress.log"}];
plog[x___] := Module[{ff = OpenAppend[PLF]},
   WriteString[ff, DateString["ISOTime"], " ", StringJoin[ToString /@ {x}], "\n"]; Close[ff]];
s04r = Get[FileNameJoin[{dir, "s04_result.m"}]];
proj = Environment["HGQ_PROJ"];
i0 = ToExpression[Environment["HGQ_I0"]];
i1 = ToExpression[Environment["HGQ_I1"]];

(* ENDPOINT EXPONENT alpha.  The bounded-distribution identity is
       sig^(-1-alpha eps) = -(B^(-alpha eps)/(alpha eps)) delta(sig)
                            + Sum_n ((-alpha eps)^n/n!) [Log^n sig/sig]_+^B
   with alpha PER TERM, not alpha = 1.  alpha > 1 arises because the angular
   master integrals are Hypergeometric2F1[a,b,1-eps,w] whose endpoint is w->1:
   the Euler/Gauss connection splits them into a branch analytic in
   delta = 1-w and a branch carrying delta^(1-eps-a-b).  That exponent is
   eps-dependent and delta vanishes at sig=0, so the second branch supplies
   sig^(-(alpha-1) eps) on top of the phase space's sig^(-eps).
   s03 delivers the angular table ALREADY eps-expanded, so that factor arrives
   here expanded into a Log[sig] tower instead of as a power - which is why the
   affected terms are exactly those carrying Log[sig] (see splitLogSig).
   alpha is therefore recovered from the tower rather than assumed:
       g = G sig^(-(alpha-1) eps) = G (1 - (alpha-1) eps Log[sig] + ...)
   so  alpha = 1 - sing[2]/(eps sing[1]),  gated on being a positive integer
   AND on the Log^2 residue matching sing[1] (alpha-1)^2 eps^2/2.
   NOTE: the truncated Log tower is NOT equivalent to using alpha directly -
   Sum_{k<=2}((-eps)^k/k!) Mcoef[k] reproduces f(2 eps) only as an
   untruncated resummation; truncated it gives -1/eps where alpha=2 needs
   -1/(2 eps).  That error was worth exactly 2 CA in the Hgq del gate.       *)
McoefA[a_] := McoefA[a] = Simplify[-BB^(-a eps)/(a eps)];
(* alpha is the VALUATION of the vanishing quantity, not a residue ratio.
   Hqq_v2 S05: alphaIncrement = -deltaValuation Coefficient[1-eps-a-b, eps]
                              = +deltaValuation ,   alpha = phaseAlpha + that.
   Here phaseAlpha = 1 (the phase space's sig^-eps, Eq.(39)) and delta is the
   argument of the vanishing log that splitLogSig detects.  sigSimpleZeroQ
   accepts ONLY simple zeros, so deltaValuation = 1 wherever it fires, giving
   alpha = 2; the assertion below keeps that honest if a higher zero appears.
   Deriving alpha from sng[[2]]/(eps sng[[1]]) does NOT work: that ratio also
   picks up pf's own eps-dependence and the genuine angular logs, and its
   integrality gate correctly rejected it.                                   *)
alphaOf[args_, idx_] := Module[{vals},
   If[args === {}, Return[1]];
   vals = Exponent[Normal[Series[#, {sig, 0, 2}]], sig, Min] & /@ args;
   If[! AllTrue[vals, # === 1 &],
      Print["[s07a] ABORT: term ", idx, " vanishing-log valuations are ", vals,
            " (only simple zeros are handled)"]; Quit[1]];
   Print["[s07a] term ", idx, " endpoint alpha = 2 (delta valuation 1)"];
   2];

Mcoef[m_] := Mcoef[m] = Simplify[(-1)^m D[-BB^(-eps)/eps, {eps, m}]];

(* rg = g - (singular parts) is ~15x larger than g (95047 leaves vs 6183 on
   Wg3 164), and Series[sig^(-eps) rg, {eps,0,1}] on it ran past 3.5 min while
   every earlier step of that term took 17 s in total.  But sig^(-eps) is just
   Exp[-eps Log[sig]] and rg is a polynomial in eps, so the product truncated
   at order eps^1 is exact in closed form - two Coefficient extractions, no
   series machinery.  Falls back to Series if rg is not polynomial in eps.  *)
epsMul[r_] := Module[{c0, c1},
   If[! PolynomialQ[r, eps], Return[Normal[Series[sig^(-eps) r, {eps, 0, 1}]]]];
   c0 = Coefficient[r, eps, 0];
   c1 = Coefficient[r, eps, 1];
   c0 + (c1 - c0 Log[sig]) eps];

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
     dserFall[f], f0 + f1 sig]];
(* Substitution fails when a summand is a product of a vanishing and a
   diverging factor: sig->0 gives 0*Infinity = Indeterminate even though the
   limit exists.  Series on the whole tr then costs minutes (term Wg3 178 blew
   1800 s twice).  Expanding factor by factor avoids it: each factor has a
   well-defined Laurent expansion and SeriesData multiplication tracks the
   leading orders, so the 0*Infinity cancels in the product.  Order headroom 3
   covers cancellation between a zero and a pole.                            *)
dserFall[f_] := Total[dserFacs /@ If[Head[f] === Plus, List @@ f, {f}]];
dserFacs[x_] := Normal[Series[
    Times @@ (Series[#, {sig, 0, 3}] & /@ If[Head[x] === Times, List @@ x, {x}]),
    {sig, 0, 1}]];
(* Log[sig] IN DISGUISE.  s04 delivers the collinear logarithm already combined,
   as Log[-(sig (Q2+s+t))/(s t)] (and its square), not as a literal Log[sig].
   The path gate below is FreeQ[g, Log[sig]], which is head-blind to that form:
   such a term took the fast path, which assumes no Log[sig] structure exists,
   so Log[sig] leaked through sigResidue into del, p1 and reg.  Split the
   logarithm first, so the general (Mcoef[m], m=0,1,2) path fires as intended.
   The argument need NOT factorise as c sig: term 148 carries
       Log[ sig (Q2+s-sig+t) / ((s-sig)(sig-t)) ],
   where sig also sits inside three of the brackets.  What matters is only that
   the argument has a SIMPLE ZERO at sig=0, i.e. h = x/sig is finite and
   nonzero there; then Log[x] = Log[sig] + Log[h(sig)] with Log[h] analytic at
   sig=0, which is what sigResidue requires of its transcendental factors.
   An earlier version of this rule tested FreeQ[Cancel[x/sig], sig], which is
   true only for the factorised case, so term 148 still took the fast path and
   dser expanded the log for it, leaking Log[sig h(0)] into del.
   The split is exact here, not a PowerExpand gamble: in the physical region
   sig > 0 and h > 0 (s>0, t<0, -u = Q2+s+t-sig > 0, s-sig > 0, sig-t > 0), so
   both factors are positive and no branch cut is crossed.  Logs regular at
   sig=0 (e.g. Log[a + b sig]) are left alone - h then blows up there.       *)
sigSimpleZeroQ[x_] := Module[{h0},
   h0 = Quiet[Cancel[Together[x/sig]] /. sig -> 0];
   FreeQ[h0, DirectedInfinity | Indeterminate | ComplexInfinity] && Simplify[h0] =!= 0];
splitLogSig[e_] := e /. Log[x_] /; ! FreeQ[x, sig] && sigSimpleZeroQ[x] :>
    Log[sig] + Log[Cancel[Together[x/sig]]];

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
(* pf must reach O(eps^2): it multiplies terms carrying 1/eps^2 poles, so its
   eps^2 coefficient contributes to the FINITE part.  Truncating at eps^1
   dropped -(Pi^2-2(Log[16]+Log[Pi]+PolyGamma[0,1/2])^2)/(1024 Pi^6) entirely
   (measured, test/t21).  Series on the product below then picks up
   pf_2 * term_(-2) at eps^0 correctly. *)
pf = Normal[Series[(pfRaw /. u -> sig - s - t - Q2) sig^eps, {eps, 0, 2}]];
(* pf is a CONSTANT.  The phase space carries (Q2+s+t+u)^(-eps), and
   u -> sig-s-t-Q2 makes Q2+s+t+u = sig, so that factor cancels the inserted
   sig^eps exactly, leaving
       pf = (1 + eps (Log[16 Pi] + PolyGamma[0,1/2])) / (256 Pi^6).
   Measured on the s04 output: pf has eps powers {0,1} and no sig, and eps
   never appears in an exponent anywhere in bulk.  So
       Series[pf term, {eps,0,1}]
   is running the whole series machinery to multiply a Laurent polynomial by a
   two-term constant; in closed form that is just
       g = Sum_k Coefficient[term,eps,k] (a0 eps^k + a1 eps^(k+1)),  k <= 1.
   Falls back to Series if term ever carries eps in an exponent.            *)
pfA0 = Coefficient[pf, eps, 0];
pfA1 = Coefficient[pf, eps, 1];
If[Exponent[pf, eps, Max] > 2,
   Print["[s07a] ABORT: pf has eps^", Exponent[pf, eps, Max]]; Quit[1]];
(* bulk = s04r/pfRaw, and pfRaw carries Gamma[(1-2eps)/2] in its DENOMINATOR,
   so every term picks up a Gamma[(1-2eps)/2] factor: eps-dependence that is
   neither a power nor a polynomial.  Series expands it; naive Coefficient
   extraction would not.  So split each term's factors into
     - "bulk-like": free of eps, or polynomial in eps  (fat, never expanded)
     - "scalar":    everything else - Gamma, 1/(1-2eps), eps^-1  (tiny)
   expand pf times the scalars once to the order the term's own eps-depth
   demands, and convolve.  Exact, and Series never sees the fat factor.     *)
gOf[tm_] := Module[{fs, sc, rest, P, jmin},
   fs = If[Head[tm] === Times, List @@ tm, {tm}];
   sc = Select[fs, ! (FreeQ[#, eps] || PolynomialQ[#, eps]) &];
   rest = Times @@ Select[fs, FreeQ[#, eps] || PolynomialQ[#, eps] &];
   If[! PolynomialQ[rest, eps], Return[Normal[Series[pf tm, {eps, 0, 1}]]]];
   (* the scalar part routinely carries eps^-1 (and 1/(eps-1)), so P starts
      BELOW eps^0: its lowest power jmin must be found, not assumed.  Every
      pair (k,j) with k+j <= 1 contributes - including large k paired with a
      negative j - so the k range is set from jmin, not from 0.
      rest passed PolynomialQ, so its eps powers are non-negative integers by
      construction and only k = 0..1-jmin can reach eps^1; Exponent[rest,eps,
      List] is therefore not needed - and it was the entire cost, 147.4 s of
      gOf's 149.5 s on term 162 (vs 0.02 s for all the Coefficient calls).  *)
   P = Normal[Series[pf (Times @@ sc), {eps, 0, 1}]];
   jmin = Exponent[P, eps, Min];
   Sum[Coefficient[rest, eps, k] Coefficient[P, eps, j] eps^(k + j),
     {k, 0, 1 - jmin}, {j, jmin, 1 - k}]];
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
plog["=== batch ", proj, " ", i0, "-", i1, " of ", n, " starting"];
If[i0 > n, Print["[s07a] nothing to do"]; Quit[0]];

acc = <|"del" -> 0, "p" -> {0, 0, 0, 0}, "reg" -> 0|>;
t0 = AbsoluteTime[];
(* bulk contains NO literal Log[sig] (measured: count = 0 over all 187 terms),
   and pf contributes none either, so Collect[g,Log[sig]] is a no-op and the
   m=1,2 coefficients are identically zero - two of the three sigResidue calls
   were computing the residue of 0.  The single-structure path below is taken
   whenever g really is free of Log[sig]; otherwise the original general path
   runs unchanged.                                                          *)
Do[Module[{g, g0, sing, rg, s0, s1, s2, alp, sigzeros, tT = AbsoluteTime[], siglogs},
   g0 = gOf[terms[[i]]];
   g = splitLogSig[g0];
   siglogs = Union[Cases[g0, Log[x_] /; ! FreeQ[x, sig], Infinity]];
   sigzeros = Union[Cases[g0, Log[x_] /; ! FreeQ[x, sig] && sigSimpleZeroQ[x] :> x, Infinity]];
   If[FreeQ[g, Log[sig]],
     s0 = sigResidue[g];
     rg = g - s0/sig;
     acc["del"] += s0 McoefA[1];   (* no Log[sig] tower => alpha = 1 *)
     acc["p"] += Table[s0 (-eps)^r/r!, {r, 0, 3}],
     (* Expand first: after splitLogSig the logs arrive as powers of a SUM,
        (Log[sig]+c)^2, which Collect alone does not break up - without the
        Expand the m=1,2 coefficients would silently come back 0.  The m<=2
        truncation below is asserted, not assumed.                          *)
     g = Collect[Expand[g], Log[sig]];
     If[Exponent[g, Log[sig]] > 2,
        Print["[s07a] ABORT: term ", i, " carries Log[sig]^", Exponent[g, Log[sig]]];
        Quit[1]];
     sing = Table[sigResidue[Coefficient[g, Log[sig], m]], {m, 0, 2}];
     alp = alphaOf[sigzeros, i];
     rg = g - Sum[sing[[m + 1]] Log[sig]^m/sig, {m, 0, 2}];
     (* TWO SECTORS, not one.  Hgq_v4 S10: the angular integral supplies the
        nonuniform (B18 connection) sig^(-1-eps) sector and the phase space
        supplies another sig^(-eps), so THAT sector has alpha = 2; the rest of
        the residue is the uniform soft sector, which only ever sees the phase
        space's sig^(-eps) and therefore keeps alpha = 1.
        Only the nonuniform part carries the sig^(-(alpha-1) eps) factor, so it
        is the only source of the Log[sig] tower.  With g = A + B sig^(-eps):
            sing[1] = res(A) + res(B) ,  sing[2] = -res(B) eps
        =>  s2 = -sing[2]/eps  (alpha sector) ,  s1 = sing[1] - s2  (alpha = 1).
        p1 = s1 + s2 = sing[[1]] is unchanged, so the p1 gate is untouched, and
        s1 carries no 1/eps (sing[2]/(eps sing[1]) -> -1 at leading order) so
        the 1/eps^2 is unchanged too - the two sectors differ only at 1/eps,
        by McoefA[alp] - McoefA[1].  Applying alpha to the WHOLE residue, as the
        first version of this fix did, over-weights the uniform sector.      *)
     (* no Simplify here: s1,s2 are plain linear combinations of the tower and
        Simplify on expressions carrying EulerGamma/PolyGamma sets off
        Series::ztest and dominates the runtime for no gain.               *)
     s2 = -sing[[2]]/eps;
     s1 = sing[[1]] - s2;
     (* The Log^2 consistency check that stood here was dropped: it needed
        Simplify on EulerGamma/PolyGamma-laden expressions and dominated the
        runtime.  The two gates that matter are kept - alphaOf aborts unless
        every vanishing-log argument has a SIMPLE zero, and the assertion below
        aborts if any sig survives into del/p.                             *)
     acc["del"] += s1 McoefA[1] + s2 McoefA[alp];
     acc["p"] += Table[s1 (-eps)^r/r! + s2 (-alp eps)^r/r!, {r, 0, 3}]];
   acc["reg"] += epsMul[rg];
   (* del multiplies delta(s23) and p multiplies [Log^k s23/s23]_+, so both
      coefficients MUST be free of s23.  A sig-dependent one means a Log[sig]
      structure slipped past the path gate.  Abort loudly and name the term
      rather than write a silently wrong partial - the previous version had no
      such check, which is how the disguised Log[sig] reached stage D.      *)
   If[! FreeQ[{acc["del"], acc["p"]}, sig],
      Print["[s07a] ABORT: term ", i, " left sig in del/p",
        "\n  sig-logs in gOf output : ", siglogs,
        "\n  FreeQ[g,Log[sig]] after splitLogSig : ", FreeQ[g, Log[sig]],
        "\n  residual sig structures: ",
        Union[Cases[{acc["del"], acc["p"]}, (Log[x_] /; ! FreeQ[x, sig]) |
              (Power[x_, _] /; ! FreeQ[x, sig]), Infinity]]];
      Quit[1]];
   plog[proj, " term ", i, " done in ", Round[AbsoluteTime[] - tT, 0.01], " s"];
   ClearSystemCache[]],
 {i, i0, i1}];
Print["[s07a] batch done in ", Round[AbsoluteTime[] - t0], " s"];
tag = proj <> "_" <> ToString[i0] <> "_" <> ToString[i1];
Put[acc, FileNameJoin[{dir, "s07part_" <> tag <> ".m"}]];
Print["[s07a] wrote s07part_", tag, ".m"];

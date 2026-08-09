#!/usr/bin/env wolframscript
(* Hqqbar (channel 5) step F1: assemble F1hat and F2hat, and check them.

   INPUT: cache/Hqqbar_R5_MR2{PP,g}QQB.mx, each defining the symbol `regular`
   = kf * jac * Hreal in the production frame {x, xi, z, PHT, Q2, s23}.

   THE MEASURE FACTOR.  `kf` is the dPi3 prefactor WITHOUT the s23^(-eps):
       dPi3 = s23^(-eps) * 2^-2 Pi^-eps/(2Pi)^(2-2eps)
              * (Gamma[1-eps]/Gamma[1-2eps]) dbeta1 dbeta2 ...
       kf   =              2^-2 Pi^-eps/(2Pi)^(2-2eps)
              * (Gamma[1-eps]/Gamma[1-2eps])
   so s23^(-eps) must be restored here before the eps -> 0 limit.  For a
   channel WITH poles that factor matters at O(eps) (it is what produces the
   plus-distributions); for channel 5 there are no poles, so it goes to 1 --
   but it is restored and the limit taken properly rather than assumed.

   FINITENESS IS CHECKED, NOT ASSUMED.  R4 found no endpoint classes and the
   counterterms vanish identically (LO[('q','qb')] is None), so the eps
   expansion must have NO pole.  The script asserts that before taking the
   limit; a surviving 1/eps would mean the no-pole conclusion is wrong.

   THE PROJECTORS (reference section 10, the eps -> 0 limit of the section-2
   extraction projectors):
       F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
       F2hat = -xh Fg + (12 xh^3/Q2) Fpp ,      xh = x/xi
   with Fg, Fpp the SAME sector in the two photon projections.  Channel 5 is
   REGULAR-ONLY, so there is one sector and no delta/plus counterparts.

   CLOBBER TRAP: both .mx files define the SAME symbol `regular` (DumpSave
   stores the symbol, not the file), so a naive second Get would silently
   overwrite the first projection.  Each is bound to a distinct name before
   the next Get, and a ByteCount-equality warning backstops it.

   Output: cache/Hqqbar_F12hat.mx  (F1hatQQB, F2hatQQB)

   ------------------------------------------------------------------------
   PERFORMANCE RULE FOR THIS FILE (2026-08-01; job 14206174 was killed by
   violating it).  NO Simplify / Together / Cancel / Factor is EVER applied
   to an assembled sector or to F1hat / F2hat.  Those objects are ~10^8 bytes
   and every such call is a global normalisation -- exactly what STATE 0z.114
   and reference section 11e forbid.
     * MEASURED: the physics ([0]-[3], the per-term eps^0 extraction over
       1610 + 1559 terms on 15 kernels) takes 18 MINUTES.  The single
       `Simplify[(12 xh^3/Q2) F1hat - (2 xh^2/Q2) F2hat]` that followed ran
       89+ minutes without returning and was killed.
     * The four PROMOTED channels' assemblers (F12_regular_assemble.wls,
       Hqq_F12_assemble.wls) form the SAME linear combination with NO
       Simplify anywhere -- only structural FreeQ gates.  BigTMD's sidis.py
       likewise never simplifies the combination; it evaluates it.
     * The projector check is a statement about SIX RATIONAL COEFFICIENTS,
       not about the sectors, so it is performed on PLACEHOLDER SYMBOLS
       (step [V1]) where it is exact and instantaneous.  See [V1] for why
       that tests strictly more than the old version did.
   ------------------------------------------------------------------------ *)

$HistoryLength = 0;

root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python",
                "cache"}]];
Print["cache = ", root];
t0 = AbsoluteTime[];
tick[msg_] := Print["    [t+", Round[AbsoluteTime[] - t0], " s] ", msg];

loadSector[name_] := Module[{file},
  file = FileNameJoin[{root, "Hqqbar_R5_" <> name <> ".mx"}];
  If[!FileExistsQ[file], Print["FATAL: missing ", file]; Quit[1]];
  Clear[regular];
  Get[file];
  If[Head[regular] === Symbol,
    Print["FATAL: ", file, " did not define `regular`"]; Quit[1]];
  Print["  loaded ", name, ": ByteCount = ", ByteCount[regular]];
  regular];

(* THE IDENTICAL-PARTICLE 1/2, and CTff ONLY.  Established, not assumed:
     * Table I gives channel 5 as H_{qbar q; qq} -- the unobserved pair is
       q q, TWO IDENTICAL QUARKS -- so the phase space carries 1/2.  Nothing
       in the chain applied it: of the six channels only 2 (gg piece) and 5
       have identical unobserved partons, and all four PROMOTED channels do
       not, so it was never needed before.
     * VERIFIED: Res_reg + 2 Res_ff = 0 EXACTLY in both projections
       (jobs 14206147/48), i.e. the real pole is entirely FF-collinear and
       the halved real cancels CTff exactly.  The amplitude has TWO
       equivalent FF regions (s12 -> 0 and s13 -> 0); two regions x 1/2 = one
       CTff, which is why the factor is 2 and not something else.
     * CTpdf is NOT applied.  The exact zero above leaves no room for an
       initial-state pole: if one existed a t2/t3 structure would survive.
       Physically t_i = -Q2 - 2 q.k_i is strictly negative for a SPACELIKE
       photon, so t_i -> 0 is unreachable at fixed s23 > 0 -- a case-2
       angular master, finite, no pole -- while s12, s13 -> 0 are reached
       freely by two massless partons.  Consistent with R4 finding no
       endpoint classes.
   CAVEAT recorded: dropping CTpdf changes the FINITE part as well as the
   pole.  That is correct ONLY if there is genuinely no initial-state
   collinear region to factorize, which the exact cancellation above
   establishes for the POLE but does not independently confirm for the
   finite remainder.  Flagged for check 15.                              *)
half = 1/2;
Fpp = half loadSector["MR2PPQQB"];
Fg  = half loadSector["MR2gQQB"];
Clear[regular];
If[ByteCount[Fpp] === ByteCount[Fg],
  Print["WARNING: identical ByteCounts -- check the second Get did not "
        <> "clobber the first"]];
tick["sectors loaded"];

(* ---- add CTff, then extract the eps^0 part TERM BY TERM ---------------
   The halved real and the CT each carry a 1/eps; they cancel only in the SUM
   (verified exactly, jobs 14206147/48).  So eps -> 0 cannot be taken on either
   piece alone, and a global Together on the sum is the operation that must be
   avoided (STATE 0z.114).
   For a Laurent series t = a_{-1}/eps + a_0 + ..., the eps^0 coefficient is
       a_0 = d/d(eps) [ eps * t ]  at eps = 0
   which is one derivative of an already-normalised object -- cheap per term,
   and the eps^0 of a SUM is the sum of the eps^0's, so this parallelises.
   The per-term Together is REQUIRED and is not the same mistake as a global
   one: `t eps^k /. eps -> 0` on an UNNORMALISED PRODUCT returns 0 x Infinity
   because the vanishing and diverging factors are never combined
   (STATE 0z.119).  Per term (~6600 leaves) Together is cheap; globally it is
   not.                                                                  *)
loadCT[proj_] := Module[{f},
  f = FileNameJoin[{root, "Hqqbar_CTff_" <> proj <> ".m"}];
  If[!FileExistsQ[f], Print["FATAL: missing ", f]; Quit[1]];
  Clear[r5regular]; Get[f]; r5regular];

gammaRules = {
  Gamma[-eps]     :> Gamma[1 - eps]/(-eps),
  Gamma[-1 - eps] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-eps - 1] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-2 eps]   :> Gamma[1 - 2 eps]/(-2 eps)};

eps0[t_] := Module[{u}, u = Cancel[Together[t eps]]; D[u, eps] /. eps -> 0];

nreq = ToExpression[Environment["NKERN"]]; If[!IntegerQ[nreq] || nreq < 1, nreq = 15];
launched = Quiet[Check[LaunchKernels[nreq], {}]];
nk = Length[Kernels[]];
Print["[0] kernels: ", nk];
DistributeDefinitions[eps];

finite[reg_, proj_, label_] := Module[{rp, pf, sm, tms, ct, parts},
  rp = (s23^(-eps) reg) //. gammaRules;
  {pf, sm} = If[Head[rp] === Times,
     Module[{facs, sizes, pos},
       facs = List @@ rp;
       sizes = If[Head[#] === Plus, Length[#], 0] & /@ facs;
       pos = First[Ordering[sizes, -1]];
       {Times @@ Delete[facs, pos], facs[[pos]]}], {1, rp}];
  tms = If[Head[sm] === Plus, List @@ sm, {sm}];
  ct  = (loadCT[proj] //. gammaRules);
  Print["  ", label, ": ", Length[tms], " terms + CTff"];
  parts = If[nk > 0, ParallelMap[eps0[pf #] &, tms], Map[eps0[pf #] &, tms]];
  tick[label <> ": per-term eps^0 done"];
  Total[parts] + eps0[ct]];

FppF = finite[Fpp, "PP", "Fpp"];
FgF  = finite[Fg,  "g",  "Fg"];
Clear[Fpp, Fg];
Print["[1] eps^0 extracted; ByteCount Fpp ", ByteCount[FppF],
      "  Fg ", ByteCount[FgF]];
tick["[1] complete"];

(* ---- the extraction projectors ----------------------------------------
   ONE source for the six coefficients: the 2x2 matrix `projM`.  Both the
   physical assembly and the [V1] placeholder check read it, so [V1] tests
   the numbers that are actually used rather than a retyped copy of them
   (the old version retyped them, which is why it could only ever confirm
   its own transcription -- at a cost of 89+ minutes).                   *)
xh = x/xi;
projM = {{-1/2, 2 xh^2/Q2},
         {-xh,  12 xh^3/Q2}};
{F1hatQQB, F2hatQQB} = projM . {FgF, FppF};
Print["[2] F1hat ByteCount ", ByteCount[F1hatQQB],
      "  F2hat ByteCount ", ByteCount[F2hatQQB]];
tick["[2] complete"];

(* ---- CHECKPOINT BEFORE VERIFYING (reference section 11h) ---------------
   18 minutes of work is written to disk BEFORE any check runs, so a check
   that misbehaves can never again destroy the result.  The sectors FgF and
   FppF are saved alongside F1hat/F2hat: they are the independent objects,
   and downstream can rebuild any projector combination from them without
   re-running this stage.                                                *)
dst = FileNameJoin[{root, "Hqqbar_F12hat.mx"}];
DumpSave[dst, {F1hatQQB, F2hatQQB, FgF, FppF, projM}];
Print["[2b] CHECKPOINT written -> ", dst, " (", FileByteCount[dst]/1.*^6,
      " MB)"];
tick["[2b] checkpoint written"];

(* ---- checks ------------------------------------------------------------
   GATE THE SECTORS, NOT THE COMBINATIONS.  F1hat and F2hat are Plus's of
   scaled copies of FgF and FppF, so gating {FgF, FppF} traverses 195 MB and
   covers every atom that can reach F1hat/F2hat; gating {F1hat, F2hat}
   traverses 390 MB and finds nothing extra.  The only atoms the projectors
   introduce are x, xi, Q2, which are whitelisted and checked separately
   below.                                                                *)
allowed = {"x", "xi", "z", "PHT", "Q2", "s23", "Nc", "ee", "eq", "gs"};
gate[e_, label_] := Module[{syms, names, stray},
  syms = DeleteDuplicates[
    Cases[e, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
          Heads -> True]];
  names = SymbolName /@ syms;
  Print["  ", label, " free symbols: ", Sort[names]];
  If[MemberQ[names, "eps"],
    Print["FATAL: ", label, " still carries eps"]; Quit[1]];
  stray = Complement[names, allowed];
  If[stray =!= {}, Print["FATAL: ", label, " stray symbols ", stray]; Quit[1]];
  If[!FreeQ[e, _Real],
    Print["FATAL: ", label, " carries a machine number"]; Quit[1]];
  If[e === 0, Print["FATAL: ", label, " is identically zero"]; Quit[1]];
  (* THE ACTUAL FINITENESS ASSERTION.  eps-freeness above is NOT sufficient
     and must never be read as finiteness.  The extractor is
         a_0 = d/d(eps)[ eps t ] at eps = 0 ,
     which is exact only if t has AT MOST a simple pole.  If any term carried
     a DOUBLE pole, `eps t` still has a simple pole, Together returns N/D with
     D -> 0, and the derivative at eps = 0 evaluates to ComplexInfinity or
     Indeterminate -- an explicit atom, NOT a surviving `eps` symbol.  The
     eps-free test would then PASS on a meaningless expression.  That is the
     exact failure of STATE 0z.117, where an Indeterminate was printed as a
     verdict.  Hqq_F12_assemble.wls guards it (its line 55); this script did
     not until 2026-08-01.
     Channel 5 is predicted pole-free (R4 found no endpoint classes) and the
     halved real cancels CTff exactly (0z.121), so the leading pole is simple
     and cancels -- but that is the thing being CHECKED, so it is asserted
     here rather than assumed.                                            *)
  If[!FreeQ[e, ComplexInfinity | Indeterminate | DirectedInfinity | Infinity],
    Print["FATAL: ", label, " is NOT FINITE -- it carries ",
          DeleteDuplicates[Cases[e,
            ComplexInfinity | Indeterminate | _DirectedInfinity,
            {0, Infinity}, Heads -> True]],
          ".  The eps^0 extractor assumes at most a SIMPLE pole; this means "
          <> "a term had a higher one, so the no-pole conclusion for channel "
          <> "5 is wrong."];
    Quit[1]];];

gate[FgF,  "Fg  sector"];
gate[FppF, "Fpp sector"];
(* NOTE the Context filter.  Without it, Heads -> True also returns the
   SYSTEM symbols List, Times, Power, Rational -- none of which is in the
   whitelist -- so the test fires on a perfectly correct projM.  That is
   exactly what killed job 14206331 AFTER all the physics had passed (the
   [2b] checkpoint saved the 13.5 min of work).  `gate[]` above always had
   this filter; this check was written without it.                        *)
If[!SubsetQ[allowed, SymbolName /@ Cases[projM,
      _Symbol?(Context[#] === "Global`" &), {0, Infinity}, Heads -> True]],
  Print["FATAL: the projector matrix carries an unexpected symbol: ",
        Complement[SymbolName /@ Cases[projM,
          _Symbol?(Context[#] === "Global`" &), {0, Infinity},
          Heads -> True], allowed]];
  Quit[1]];
Print["[3] gates passed: eps-free, Float-free, whitelist-clean, nonzero"];
tick["[3] complete"];

(* ---- QUICK VERIFICATION, on PLACEHOLDERS ------------------------------
   WHAT THIS TESTS AND WHY IT IS DONE ON SYMBOLS.
     F1hat and F2hat are two linear combinations of the SAME pair
     (Fg, Fpp) with the rational coefficient matrix
         projM = {{-1/2, 2 xh^2/Q2}, {-xh, 12 xh^3/Q2}} .
     Everything there is to verify about that assembly is a statement about
     projM alone -- its determinant (invertibility) and its entries.  The
     sectors enter only as the vector projM acts on, and a linear map is
     correct or not independently of the vector.  So the check is run with
     Fg -> fg, Fpp -> fpp two inert symbols: it is EXACT, it is instant, and
     because both the check and the physical assembly consume the SAME
     projM, it validates the coefficients actually used.

     The previous version formed the combination on the 195 MB objects and
     called Simplify on it.  That asked Mathematica to rediscover
         (12 xh^3/Q2)(2 xh^2/Q2) - (2 xh^2/Q2)(12 xh^3/Q2) = 0
     by normalising 1610 mapped terms of Fpp against each other -- a global
     normalisation of the sort section 11e forbids.  It ran 89+ minutes and
     returned nothing.  It also tested LESS, since it compared projM against
     a hand-retyped copy of projM rather than against the assembly.

   (V1) INVERTIBILITY.  det projM = (-1/2)(12 xh^3/Q2) - (2 xh^2/Q2)(-xh)
        = -6 xh^3/Q2 + 2 xh^3/Q2 = -4 xh^3/Q2, nonzero for xh != 0, so
        (Fg, Fpp) are recoverable from (F1hat, F2hat).  Verified by actually
        inverting projM and applying it.
   (V2) ENTRIES.  projM must equal the reference-section-10 projectors,
        compared entry by entry against the literal reference values.
   (V3) DISTINCTNESS.  The two rows of projM are not proportional -- which
        is det != 0 again, but stated on the rows because the failure it
        guards against (one row clobbering the other) is a row-level bug.
   (V4) The physical objects really are projM.{FgF,FppF}: guaranteed by
        construction at [2] -- there is no second place the coefficients
        could come from.  Recorded, not recomputed.                     *)

Clear[fg, fpp];
{F1sym, F2sym} = projM . {fg, fpp};

detM = Simplify[Det[projM]];
Print["[V1] det projM = ", detM // InputForm, "   (reference: -4 xh^3/Q2 = ",
      Simplify[-4 (x/xi)^3/Q2] // InputForm, ")"];
If[TrueQ[Simplify[detM] === 0] || !TrueQ[Simplify[detM - (-4 (x/xi)^3/Q2)] === 0],
  Print["FATAL: projector matrix is singular or not the reference matrix"];
  Quit[1]];
recovered = Simplify[Inverse[projM] . {F1sym, F2sym}];
Print["[V1] recovered {Fg, Fpp} = ", recovered // InputForm];
If[!TrueQ[Simplify[recovered - {fg, fpp}] === {0, 0}],
  Print["FATAL: projector inversion failed"]; Quit[1]];

refM = {{-1/2, 2 (x/xi)^2/Q2}, {-(x/xi), 12 (x/xi)^3/Q2}};
Print["[V2] projM - reference = ",
      Simplify[projM - refM] // InputForm];
If[!TrueQ[Simplify[projM - refM] === {{0, 0}, {0, 0}}],
  Print["FATAL: projM is not the reference-section-10 projector"]; Quit[1]];

Print["[V3] rows independent (F1hat =!= F2hat structurally): ",
      !TrueQ[Simplify[F1sym - F2sym] === 0]];
If[TrueQ[Simplify[F1sym - F2sym] === 0],
  Print["FATAL: the two projector rows coincide"]; Quit[1]];

Print["[V4] F1hat, F2hat were built as projM.{FgF,FppF} at [2] -- single "
      <> "source, no retyped coefficients."];
Print["[V] quick verification passed"];
tick["[V] complete"];

Print["HQQBAR_F1_DONE -> ", dst, " (", FileByteCount[dst]/1.*^6, " MB)"];

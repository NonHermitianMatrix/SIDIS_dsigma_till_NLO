#!/usr/bin/env wolframscript
(* Step R5 -- the s23-REGULAR part of a channel, the piece R4 does not produce.

   WHY IT IS NEEDED.  R4 gives only the endpoint RESIDUE R (the coefficient of
   s23^-1), which generates the delta(s23) and plus-distribution pieces.  The
   reference implementation's hard functions carry a FOURTH object,
       regular(g, gp, s, t, Q, s23, mu, nf)
   an explicit FUNCTION of s23 (its fchn files show the same
   Sqrt[4 Q^2 s23 + (s+t)^2] radical our engine already handles).  For the
   regular-only channels (4, 5, 6) this is their ENTIRE contribution, and no
   channel's F1/F2 can be assembled without it.

   CORRECTED 2026-07-25 12:40.  The first version took eps -> 0 on the real part
   ALONE and its own gate caught the error (`ComplexInfinity-free False`): the
   claim "the integrand has no 1/eps at fixed s23" is FALSE, because the ANGULAR
   MASTERS already carry eps poles -- that is where the collinear poles come
   from.  Those poles cancel against the COUNTERTERM's regular piece `Creg`, at
   each s23, exactly as the delta and plus poles cancel against `Cdelta`/`Cplus`.
   So the regular sector needs the same real + CT assembly the others get:
       regular(s23) = [ kf (Ht_tot - R/s23) + PREF (CTpdf + CTff).Creg ]_{eps->0}
   and the surviving 1/eps MUST be zero -- a genuine extra pole-cancellation
   check, not bookkeeping.

   THE DECOMPOSITION, written out.  With F(s23) regular at the endpoint,
       s23^{-1-eps} F(s23)
         = s23^{-1-eps} F(0)                      -> delta + plus  (Step R4)
         + s23^{-1-eps} [F(s23) - F(0)]           -> THIS STEP, at eps -> 0.
   The second bracket has no pole, so eps -> 0 may be taken directly: no
   B^-eps, no plus prescription, no 1/eps.  In the variables the residue engine
   uses (W^2 = s23, so the integrand behaves as R/W^2 + regular),
       real regular part = Ht_total - R / s23   (still eps-dependent).

   WHY THIS IS CHEAP, UNLIKE R4.  R4 needs a SeriesCoefficient PER TERM.  Here
   the subtraction uses the ALREADY-SUMMED residue R, so the terms only have to
   be added -- no series at all -- and the eps -> 0 limit is taken once on the
   total.  That is why this stage does not need the partitioning R4 required.

   Input : mathematica/r4in_<piece>.m   (angterms, the R3 output)
           mathematica/r4out_<piece>.m  (R, the merged endpoint residue)
           mathematica/c2in_<C2TAG>.m   (for ctReg; optional -- without it the
                                         script reports the UNSUBTRACTED poles)
   Output: mathematica/r5reg_<piece>.m  (the FINITE regular part, a function of s23)
   Env   : R4PIECE, C2TAG, R4NK, C2ROOT.                                     *)

$HistoryLength = 0;
piece = Environment["R4PIECE"]; If[piece === $Failed, piece = "MR2gHGG"];
nk = ToExpression[Environment["R4NK"]]; If[!IntegerQ[nk], nk = 8];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];

fin = root <> "r4in_" <> piece <> ".m";
fres = root <> "r4out_" <> piece <> ".m";
frt = root <> "r4terms_" <> piece <> ".m";
If[!FileExistsQ[fin], Print["FATAL missing ", fin]; Quit[1]];
If[!FileExistsQ[fres], Print["FATAL missing ", fres, " (merge R4 first)"]; Quit[1]];
If[!FileExistsQ[frt], Print["FATAL missing ", frt, " (bridge R4 first)"]; Quit[1]];
Get[fin];
R = Get[fres];
pieceRterms = Get[frt];
If[Head[angterms] =!= List || Length[angterms] === 0,
   Print["FATAL: angterms empty or not a List (head ", Head[angterms], ")"];
   Quit[1]];
If[Head[pieceRterms] =!= List || Length[pieceRterms] === 0,
   Print["FATAL: pieceRterms empty or not a List (head ", Head[pieceRterms], ")"];
   Quit[1]];
Print["R5 piece ", piece, "  angterms ", Length[angterms],
      "  residue terms ", Length[pieceRterms], "  merged residue LeafCount ",
      LeafCount[R], "  kernels ", nk];

(* same sequential substitution as the residue engine -- BUG F: a combined rule
   list would leave the s23 introduced by the u1 rule unconverted *)
(* eps -> 0 IS APPLIED PER TERM, INSIDE THE PARALLEL SUM.
   Measured first attempt: summing with eps kept gave a 54.8 M-leaf total and
   then a SINGLE-THREADED eps -> 0 pass over the whole thing (cpu ~= wall for
   28 min).  Both halves of the bracket are separately finite at eps = 0 -- the
   integrand at fixed s23 has no 1/eps, and R is the s23-residue, also finite --
   so the limit DISTRIBUTES and can be taken term by term.  That makes it
   parallel AND keeps the running sum far smaller, since the eps-dependent
   factors (s23^-eps, Gammas) collapse to 1 before accumulation. *)
(* eps is KEPT here: the real part carries collinear 1/eps from the angular
   masters, which only cancels once the CT is added.  Each term is Laurent
   expanded to eps^0 with the SPLIT-FACTOR trick proven exact in
   mathematica/Hqq_C2_laurent_bench.wls (Series is multiplicative over eps-free
   factors, so only the eps-dependent factor is expanded). *)
(* Exact physical-region canonicalization.  The R5 integration domain has
   s23>0 and t1<0, hence s23-t1>0.  BigTMD's hard functions use the corresponding
   positive square-root branch directly; leaving these identities as Abs/Sqrt
   products blocked exact pole cancellation and made the old global Series
   path spend hours on removable branch structure. *)
phys[e_] := e /. t -> t1 /.
  {Abs[t1] -> -t1, sign[t1] -> -1,
   Abs[s23 - t1] -> s23 - t1, Abs[-s23 + t1] -> s23 - t1,
   Sqrt[s23^(-1)] Sqrt[s23] -> 1};
sub[u_] := phys[u /. u1 -> s23 - s - t1 - Q2];
(* Common-factor-first additive Laurent candidate.  The ordinary factor-split
   route remains the fallback.  Promotion to the cluster production copy is
   gated by exact coefficient equality in Hqq_additive_series_probe.wls. *)
commonExact[sum_] := Module[{ts, fs, cf, prim},
  ts = If[Head[sum] === Plus, List @@ sum, {sum}];
  fs = (If[Head[#] === Times, List @@ #, {#}] &) /@ ts;
  cf = If[Length[fs] == 1, {}, Fold[Intersection, First[fs], Rest[fs]]];
  prim = Total[Times @@ DeleteCases[#, Alternatives @@ cf] & /@ fs];
  {Times @@ cf, prim}];
largestPlusPos[list_] := Module[{ps},
  ps = Flatten[Position[list, _Plus, {1}]];
  If[ps === {}, Missing["none"],
    First[MaximalBy[ps, LeafCount[list[[#]]] &]]]];
lau[u_] := Module[
  {v, fac, free, dep, pos, add, other, cp, common, primitive,
   cfac, cfree, cdep},
  v = sub[u];
  fac = If[Head[v] === Times, List @@ v, {v}];
  free = Times @@ Select[fac, FreeQ[#, eps] &];
  dep = Select[fac, ! FreeQ[#, eps] &];
  If[dep === {}, Return[free]];
  pos = largestPlusPos[dep];
  If[MissingQ[pos],
    Return[free Normal[Series[Times @@ dep, {eps, 0, 0}]]]];
  add = dep[[pos]];
  other = Times @@ Delete[dep, pos];
  cp = commonExact[add]; {common, primitive} = cp;
  (* *** BUG FIXED 2026-08-08. ***  `common` is the common factor of `add`,
     and `add` is the eps-DEPENDENT part -- so `common` can itself depend on
     eps.  It used to be multiplied OUTSIDE the Series, which meant any
     eps-dependent common factor (in practice Pi^eps, from kf's Pi^-eps and the
     phase-space Pi^-eps) was NEVER Laurent-expanded.
     MEASURED CONSEQUENCE on MR2PPQGG: the reported eps^-1 "pole" came out
     proportional to (-1 + Pi^eps), which VANISHES at eps = 0 -- a spurious
     pole, purely an artifact of the unexpanded factor -- and
     REGULAR_POLES_CANCEL printed False on a piece whose poles do cancel.
     It is also the source of the O(eps) debris of 0z.421.
     FIX: keep only the eps-FREE part of `common` outside, and push the
     eps-dependent part INTO the Series argument. *)
  cfac = If[Head[common] === Times, List @@ common, {common}];
  cfree = Times @@ Select[cfac, FreeQ[#, eps] &];
  cdep = Times @@ Select[cfac, ! FreeQ[#, eps] &];
  If[Head[primitive] === Plus,
    free cfree Total[
      (Normal[Series[cdep other #, {eps, 0, 0}]]) & /@ (List @@ primitive)],
    free cfree Normal[Series[cdep other primitive, {eps, 0, 0}]]]];

LaunchKernels[nk];
DistributeDefinitions[phys, sub, commonExact, largestPlusPos, lau];
t0 = AbsoluteTime[];
(* "FinestGrained": per-term cost is wildly uneven, so fixed chunks strand the
   expensive tail on one kernel while the rest idle. *)
Htot = Total[ParallelMap[lau, angterms, Method -> "FinestGrained"]];
Print["  summed integrand (Laurent to eps^0) ", AbsoluteTime[] - t0,
      " s  LeafCount ", LeafCount[Htot]];

(* The merged residue can have tens of millions of leaves.  Expanding
   Series[kf (Htot-R/s23),...] globally made case B run for >22 h with no
   output.  Use the bridged residue TERM LIST and the C2-proven split-factor
   Laurent term by term.  Chunk/Fold keeps only a running sum on each worker. *)
t0 = AbsoluteTime[];
chunkSum[ch_] := Fold[#1 + lau[#2] &, 0, ch];
DistributeDefinitions[chunkSum];
nchunk = 4 nk;
rchunks = Partition[pieceRterms,
                    UpTo[Ceiling[Length[pieceRterms]/nchunk]]];
Rser = Total[ParallelMap[chunkSum, rchunks]];
Print["  residue Laurent (", Length[pieceRterms], " terms) ",
      AbsoluteTime[] - t0, " s  LeafCount ", LeafCount[Rser]];

(* R5DIAG (default off): is the subtracted residue ACTUALLY the s23^-1
   coefficient of the integrand?  The whole regular sector rests on
       s23^{-1-eps}[F(s23) - F(0)]   being pole-free BY CONSTRUCTION,
   which holds only if the R being subtracted as R/s23 really is
   Limit[s23 Htot, s23 -> 0].  STATE 0z.356 raised this ("establish the exact
   relation between R5's F(0) and the validated residue") and it was never
   settled.  If R is even slightly off, the leftover is a KINEMATIC pole --
   exactly the signature now seen on QGG but not on PAIR. *)
If[Environment["R5DIAG"] === "1",
   Module[{lhs, rhs, d},
     lhs = Simplify[Limit[s23 Coefficient[Htot, eps, 0], s23 -> 0]];
     rhs = Simplify[Coefficient[Rser, eps, 0]];
     d = Simplify[lhs - rhs];
     Print["  R5DIAG  Limit[s23 Htot]_{eps^0} LeafCount ", LeafCount[lhs]];
     Print["  R5DIAG  Rser_{eps^0}            LeafCount ", LeafCount[rhs]];
     Print["  R5DIAG  ** residue matches integrand: ", TrueQ[d === 0], " **"];
     If[d =!= 0,
        Print["  R5DIAG  difference LeafCount ", LeafCount[d]];
        Put[{lhs, rhs, d}, root <> "r5diag_residue_" <> piece <> ".m"]]]];

(* assemble the regular sector: real + counterterm, then eps -> 0 *)
t0 = AbsoluteTime[];
kf = (1/4) Pi^(-eps)/(2 Pi)^(2 - 2 eps) Gamma[1 - eps]/Gamma[1 - 2 eps];
PREF = (gs^2/(16 Pi^2)) (4 Pi)^eps/Gamma[1 - eps]/eps;
ctReg = 0;
tag = Environment["C2TAG"];
If[tag =!= $Failed && FileExistsQ[root <> "c2in_" <> tag <> ".m"],
   Block[{Rterms, virtExpr, ctDelta, ctPlus, hasVirt, hasCT},
     Get[root <> "c2in_" <> tag <> ".m"]];
   Print["  CT regular piece loaded from c2in_", tag, ".m  LeafCount ",
         LeafCount[ctReg]],
   Print["  NO CT (set C2TAG) -- poles below are UNSUBTRACTED"]];
(* Coefficient-wise convolution.  This is algebraically identical to the global
   Series and was proven exact in both projections by job 14151900:
   R5_COEFF_REF_DIFF 0 (EXACT) for MR2gA and MR2PPA. *)
kfs = Normal[Series[kf, {eps, 0, 2}]];
prefs = Normal[Series[PREF, {eps, 0, 0}]];
ctSer = Normal[Series[ctReg, {eps, 0, 1}]];
kc[j_] := Coefficient[kfs, eps, j];
pc[j_] := Coefficient[prefs, eps, j];
cc[j_] := Coefficient[ctSer, eps, j];
(* COUPLING RESTORATION, added 2026-08-08.  MEASURED, not assumed.
   The Hqq real traces were made with ee = eq = gs = 1 (grep of
   r4in_/r4out_MR2*{QGG,PAIR}.m finds ZERO occurrences of ee, eq, gs), exactly
   as the virtual's `virt_preCT` was -- python/Hqq_V2_ren_invariant_sym.py
   records the same defect and fixes it the same way ("restore the 2Re(M0 M1)
   coupling; virt_preCT was traced with ee=eq=gs=1").
   But ctReg carries ee^2 eq^2 gs^2 explicitly and PREF carries the remaining
   gs^2, so the CT side arrives as ee^2 eq^2 gs^4 while the real side arrives
   as 1.  Two different coupling structures CANNOT cancel, and that is exactly
   what the first CT run showed: the surviving eps^-1 was
   (real, no couplings) + (CT, with 4 ee^2 eq^2 gs^4 Pi^2 ...).
   WHICH SIDE TO FIX: restore the real side, do NOT strip the CT.  The promoted
   channels' R5 outputs (verified/Hgg/Hgg_R5_{g,PP}.pkl,
   verified/Hgq/Hgq_R5inv_{g,PP}.pkl) all carry ee, eq, gs, so couplings-present
   is the convention the finished F-hats use.  (C2 went the other way with its
   kappaC = Nc/(2 Pi ee^2 eq^2 gs^2); that is fine for a pole VERDICT, where an
   overall factor is irrelevant, but the finite hard function must match the
   other channels.)
   POWER COUNTING: LO gamma* q -> q g gives |M|^2 ~ ee^2 eq^2 gs^2; the 2->3
   real emission carries one more power of gs^2, hence ee^2 eq^2 gs^4 -- which
   is precisely PREF x ctReg's structure, as it must be.
   SELF-GUARDING: the factor is applied ONLY when the input is measurably
   coupling-free, so a channel whose traces already keep couplings is
   untouched. *)
cplR = If[FreeQ[angterms, ee] && FreeQ[angterms, gs] && FreeQ[angterms, eq],
          ee^2 eq^2 gs^4, 1];
Print["  real-side coupling restoration factor: ", cplR,
      "   (1 means the traces already carried couplings)"];
rc[j_] := cplR (Coefficient[Htot, eps, j] - Coefficient[Rser, eps, j]/s23);
groupSimplify[e_] := Module[{terms, groups, vals},
  If[e === 0, Return[0]];
  terms = If[Head[e] === Plus, List @@ e, {e}];
  groups = Values[GroupBy[terms, {Exponent[#, eq], Exponent[#, eqp]} &]];
  vals = ParallelMap[
    FullSimplify[Refine[#, Q2 > 0 && s > s23 > 0 && t1 < 0],
                 Assumptions -> Q2 > 0 && s > s23 > 0 && t1 < 0] &,
    Total /@ groups, Method -> "FinestGrained"];
  If[AllTrue[vals, # === 0 &], 0,
     FullSimplify[Refine[Total[vals], Q2 > 0 && s > s23 > 0 && t1 < 0],
                  Assumptions -> Q2 > 0 && s > s23 > 0 && t1 < 0]]];
p2 = Simplify[groupSimplify[phys[kc[0] rc[-2]]] /.
              CF -> (Nc^2 - 1)/(2 Nc)];
p1 = Simplify[groupSimplify[
              phys[kc[0] rc[-1] + kc[1] rc[-2] + pc[-1] cc[0]]] /.
              CF -> (Nc^2 - 1)/(2 Nc)];
CloseKernels[];
Print["  regular sector eps^-2 (must be 0): ", InputForm[p2]];
Print["  regular sector eps^-1 (must be 0): ", InputForm[p1]];
Print["  REGULAR_POLES_CANCEL ", TrueQ[p1 === 0 && p2 === 0]];
(* R5PARTIAL, added 2026-08-08.  DEFAULT BEHAVIOUR IS UNCHANGED (the gate below
   still fatals) -- this only opens the case the gate was never scoped for.

   WHY.  This script runs PER PIECE, but the pole cancellation is a PER CHANNEL
   statement (AI.md 11g: each of the six hard parts is separately finite; the
   real/virtual correspondence is not one-to-one WITHIN a channel).  A channel
   built from several pieces -- Hqq case A is QGG + 2 nf PAIR -- cannot cancel
   piece by piece, and feeding the full channel ctReg into each piece
   separately would DOUBLE COUNT the counterterm.  Hgg never exposed this
   because it has a single piece.
   So for a multi-piece channel: run each piece with R5PARTIAL=1 and NO CT,
   record its pole coefficients, and gate ONCE on the weighted channel sum.
   AI.md section 9 requires exactly this -- below channel level a gate must
   RECORD and CONTINUE, never raise. *)
partial = Environment["R5PARTIAL"];
If[(p1 =!= 0 || p2 =!= 0) && partial === "1",
   Put[{p2, p1}, root <> "r5pole_partial_" <> piece <> ".m"];
   Print["  R5PARTIAL: poles RECORDED (not a failure at piece level) -> "
         <> "r5pole_partial_" <> piece <> ".m"];
   Print["  ** PROVISIONAL until the channel-level sum is gated **"]];
If[(p1 =!= 0 || p2 =!= 0) && partial =!= "1",
   Put[{p2, p1}, root <> "r5pole_residual_" <> piece <> ".m"];
   Print["FATAL: regular poles did not cancel; no finite output written"];
   Quit[1]];
reg = phys[kc[0] rc[0] + kc[1] rc[-1] + kc[2] rc[-2]
           + pc[-1] cc[1] + pc[0] cc[0]];
(* eps -> 0 BY SUBSTITUTION FIRST.  The bracket is regular at eps = 0 by
   construction (the pole was subtracted), so a substitution suffices and is
   vastly cheaper than Limit on a ~55 M-leaf expression.  Fall back to Limit
   only if the substitution produces an Indeterminate/ComplexInfinity from a
   REMOVABLE 0/0 -- the same guard the sympy residue engine needed when the
   radical hit its endpoint value inside a ratio. *)
Print["  regular part ", AbsoluteTime[] - t0, " s  LeafCount ", LeafCount[reg]];

(* *** BUG FIXED 2026-08-08. ***  The comment above described this eps -> 0
   step, but THE CODE NEVER PERFORMED IT: `phys` only does the kinematic
   substitutions (t -> t1, Abs resolutions), and everything between the `reg =`
   assignment and the `Put` was a Print.  So r5reg_ files were written with
   O(eps) debris still in them -- rc[j] = Coefficient[Htot, eps, j] leaves eps
   sitting inside unexpanded factors like (1 - 2 eps), which `Coefficient` does
   not reach.  MEASURED on MR2PPPAIR: reg 597 leaves with eps present,
   Limit[reg, eps -> 0] 44 leaves and eps-free, residual -> 0 at eps -> 0.
   The `eps-free` line below was only a Print, never an assertion, so this was
   never caught.  It is now BOTH performed and asserted. *)
reg0 = reg /. eps -> 0;
If[! FreeQ[reg0, ComplexInfinity | Indeterminate],
   Print["  eps -> 0 substitution hit a removable 0/0; using Limit"];
   reg0 = Limit[reg, eps -> 0]];
reg0 = Simplify[reg0];
Print["  eps -> 0 applied: LeafCount ", LeafCount[reg], " -> ", LeafCount[reg0]];
reg = reg0;

stray = Select[{x, z, PHT, xi}, ! FreeQ[reg, #] &];
Print["frame gate stray ", stray, "  (must be {})   ",
      "ComplexInfinity-free ", FreeQ[reg, ComplexInfinity | Indeterminate],
      "   eps-free ", FreeQ[reg, eps]];
(* ASSERT, do not merely report.  A Print-only gate is what let the O(eps)
   debris above reach every downstream F12 assembly. *)
If[! FreeQ[reg, eps] || ! FreeQ[reg, ComplexInfinity | Indeterminate] ||
   stray =!= {},
   Print["FATAL: R5 output failed its own gate (eps-free / finite / frame); "
         <> "no output written"];
   Quit[1]];
Put[reg, root <> "r5reg_" <> piece <> ".m"];
Print["R5_REGULAR_DONE ", piece];

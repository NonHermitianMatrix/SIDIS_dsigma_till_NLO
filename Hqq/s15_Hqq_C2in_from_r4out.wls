#!/usr/bin/env wolframscript
(* BRIDGE R4(Mathematica) -> C2: turn mathematica/r4out_<piece>.m (the summed
   endpoint residue R from Hqq_R4_mma.wls) into the term LIST that
   Hqq_C2_mma.wls consumes as `Rterms` from c2in_<tag>.m.

   Hqq_C2_mma.wls does its eps-Laurent PER TERM (chunked Fold across kernels,
   because collecting N Series results and then Total OOM'd a 15 GB box), so it
   needs the residue split, not summed.  Since Hqq_R4_mma.wls builds
   R = Total[ParallelMap[resid, angterms]], the head of R is Plus and
   `List @@ R` recovers the terms DIRECTLY -- no Expand, which matters because
   the MR2gB residue alone is 22.8 M leaves.

   Also reports per-term LeafCount statistics, so the C2 chunking for this piece
   can be budgeted from data instead of guessed.

   Env: R4PIECE, C2ROOT.  Writes mathematica/r4terms_<piece>.m defining Rterms.
   (The final c2in_<tag>.m still comes from Hqq_C2_export_mma.py, which combines
   the per-piece Rterms with the virtual and the CT pieces per CASEDEF.) *)

$HistoryLength = 0;
piece = Environment["R4PIECE"]; If[piece === $Failed, piece = "MR2PPQGG"];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica/"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];

f = root <> "r4out_" <> piece <> ".m";
If[!FileExistsQ[f], Print["FATAL: ", f, " missing"]; Quit[1]];
R = Get[f];
Print["C2IN piece ", piece, "  residue LeafCount ", LeafCount[R],
      "  Head ", Head[R]];

(* GUARD ADDED 2026-08-08 (0z.411).  Engine v2 writes r4out_ as an
   Association <|Residue -> <|Class[j,l] -> expr|>, Deep -> ..., Odd -> ...|>.
   An Association's Head is NOT Plus, so the line below silently fell through
   to {R} -- Rterms = 1, the WHOLE Association as one "term" -- which
   propagated into R5 and printed the poles as {0,0,0}.  That reads like
   "poles cancel" and nearly promoted a wrong result.  This bridge handles only
   the OLD bare-expression format; use Hqq_C2in_from_r4out_v2.wls for
   Associations.  Refuse loudly rather than mis-handle. *)
If[AssociationQ[R],
   Print["FATAL: r4out_ is an Association (engine v2 format).  This bridge "
         <> "handles only the old bare-expression format -- use "
         <> "mathematica/Hqq_C2in_from_r4out_v2.wls instead."];
   Quit[1]];
Rterms = If[Head[R] === Plus, List @@ R, {R}];
lc = LeafCount /@ Rterms;
Print["  Rterms ", Length[Rterms],
      "   LeafCount min/median/max ", Min[lc], "/", Median[lc], "/", Max[lc],
      "   total ", Total[lc]];
Print["  ComplexInfinity-free ", FreeQ[Rterms, ComplexInfinity | Indeterminate],
      "   frame gate stray ", Select[{x, z, PHT, xi}, !FreeQ[Rterms, #] &],
      " (must be {})"];
Print["  eps-free terms ", Count[Rterms, t_ /; FreeQ[t, eps]],
      " of ", Length[Rterms]];

Put[Rterms, root <> "r4terms_" <> piece <> ".m"];
Print["C2IN_FROM_R4OUT_DONE ", piece];

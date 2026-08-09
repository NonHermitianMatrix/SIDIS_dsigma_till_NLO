#!/usr/bin/env wolframscript
(* Hqq_R4_merge2.wls -- merge the ENGINE v2 slices `r4out2_<piece>_v2rr<k>.m`
   written by Hqq_R4_mma_part2.wls into the single residue `r4out_<piece>.m`
   that every downstream stage (R5, the c2in bridge, C2) already reads.

   Exact: the residue is a plain sum over angular terms, so Total of the slices
   IS the whole -- proven for this partitioning by `PARTMERGE DIFF = 0`
   (mathematica/Hqq_partmerge_compare.wls) and re-confirmed for engine v2 by the
   whole-piece gate (job 14150281: MR2PPA and MR2gA recomputed from scratch,
   `R4v2_REF_DIFF 0 (EXACT)` against the pre-BUG-K residues).

   TWO REFUSALS, both learned the hard way:
   (1) a MISSING slice aborts -- a merge of 7 of 8 slices is a plausible wrong
       answer, the failure mode of STATE section 4;
   (2) a nonempty QUARANTINE aborts unless R4ALLOWPARTIAL=1.  Engine v1's
       quarantine files were merged silently, and that is precisely how the
       incomplete QGG residues reached the BUG-D adjudicator and produced a
       verdict that had to be voided.  The quarantined terms carry physics.
   Env: R4PIECE, R4NPART, R4OUTTAG, R4ALLOWPARTIAL, C2ROOT.                    *)
$HistoryLength = 0;
piece = Environment["R4PIECE"]; If[piece === $Failed, piece = "MR2PPQGG"];
npart = ToExpression[Environment["R4NPART"]]; If[!IntegerQ[npart], npart = 8];
otag = Environment["R4OUTTAG"]; If[otag === $Failed, otag = "v2"];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];

files = Table[root <> "r4out2_" <> piece <> "_" <> otag <> "rr" <> ToString[k] <>
              ".m", {k, npart}];
missing = Select[files, ! FileExistsQ[#] &];
If[missing =!= {},
   Print["MERGE2_ABORT ", piece, " missing ", Length[missing], " of ", npart,
         " slice(s): ", FileNameTake /@ missing];
   Quit[1]];

(* quarantine census FIRST -- the residue is not complete without those terms *)
qf = Select[Table[root <> "r4slow2_" <> piece <> "_" <> otag <> "rr" <>
                  ToString[k] <> ".m", {k, npart}], FileExistsQ];
nq = Total[Length[Get[#]] & /@ qf];
Print["QUARANTINE ", piece, ": ", Length[qf], " file(s), ", nq, " term(s)"];
allow = ToExpression[Environment["R4ALLOWPARTIAL"]];
If[nq > 0 && allow =!= 1,
   Print["MERGE2_ABORT ", piece, " -- ", nq,
         " quarantined term(s) not yet computed; the residue would be PARTIAL.",
         "  Set R4ALLOWPARTIAL=1 only for a DIAGNOSTIC merge, never for a result."];
   Quit[1]];

R = Total[Get /@ files];
Print["MERGE2 ", piece, "  ", npart, " slices  LeafCount ", LeafCount[R],
      "  quarantined ", nq];
stray = Select[{x, z, PHT, xi}, ! FreeQ[R, #] &];
Print["frame gate stray ", stray, "  (must be {})   ",
      "ComplexInfinity-free ", FreeQ[R, ComplexInfinity | Indeterminate],
      "   s23-free ", FreeQ[R, s23]];
If[stray =!= {} || ! FreeQ[R, ComplexInfinity | Indeterminate] ||
   ! FreeQ[R, s23],
   Print["MERGE2_ABORT ", piece, " -- gate failed, not writing"]; Quit[1]];
Put[R, root <> "r4out_" <> piece <> ".m"];
Print["R4_MERGE2_DONE ", piece, If[nq > 0, " (PARTIAL, diagnostic only)", ""]];

#!/usr/bin/env wolframscript
(* Hqq_R5_verify.wls -- verify an ALREADY-WRITTEN regular part r5reg_<piece>.m.

   WHY THIS EXISTS.  The two chn4 (Hgg) R5 runs of job 14146097 WROTE their
   output files (r5reg_MR2gHGG.m 01:19, r5reg_MR2PPHGG.m 07:50) but their logs
   stop at the "CT regular piece loaded" line: `wolframscript` stdout is
   BLOCK-BUFFERED into a file, and the buffer was lost when the kernel exited, so
   the gate lines (frame gate / ComplexInfinity-free / eps-free /
   REGULAR_POLES_CANCEL) were never observed.  Per STATE section 4, a result whose
   gates were not seen is not a result.  This script re-runs the gates on the
   written file alone -- it does NOT recompute the regular part.

   Env: R5PIECES (comma-separated, default MR2gHGG,MR2PPHGG), C2ROOT.          *)

$HistoryLength = 0;
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];
pl = Environment["R5PIECES"];
If[pl === $Failed, pl = "MR2gHGG,MR2PPHGG"];
pieces = StringTrim /@ StringSplit[pl, ","];
allOK = True;

Do[Module[{piece = pieces[[k]], fn, reg, stray, okE, okC, lc},
   fn = root <> "r5reg_" <> piece <> ".m";
   Print["=== ", piece, " ==="];
   If[! FileExistsQ[fn],
      Print["  MISSING ", fn]; allOK = False; Continue[]];
   reg = Get[fn];
   lc = LeafCount[reg];
   (* an EMPTY/undefined read is the silent-no-op failure mode of STATE section 4 *)
   Print["  head ", Head[reg], "   LeafCount ", lc,
         "   NONEMPTY ", TrueQ[lc > 1 && reg =!= Null]];
   stray = Select[{x, z, PHT, xi}, ! FreeQ[reg, #] &];
   okC = FreeQ[reg, ComplexInfinity | Indeterminate | DirectedInfinity];
   okE = FreeQ[reg, eps];
   Print["  frame gate stray ", stray, " (must be {})"];
   Print["  ComplexInfinity-free ", okC, "   eps-free ", okE];
   Print["  s23-present ", ! FreeQ[reg, s23], " (the regular part DEPENDS on s23)"];
   Print["  free symbols ", Sort[DeleteDuplicates[
       Cases[reg, _Symbol?(Context[#] === "Global`" &), {0, Infinity}]]]];
   ok = TrueQ[lc > 1] && stray === {} && okC && okE;
   Print["  R5_VERIFY ", piece, " ", If[ok, "PASS", "FAIL"]];
   If[!ok, allOK = False]],
 {k, Length[pieces]}];
If[!TrueQ[allOK], Print["FATAL R5_VERIFY_FAILED"]; Quit[1]];
Print["R5_VERIFY_DONE"];

#!/usr/bin/env wolframscript
(* Hqqbar (channel 5) step F1 -- COMPLETION from the [2b] checkpoint.

   Job 14206331 computed everything and wrote cache/Hqqbar_F12hat.mx at [2b],
   then died in a CHECK: the projM whitelist test used
       Cases[projM, _Symbol, {0, Infinity}, Heads -> True]
   without the `Context[#] === "Global`"` filter that gate[] uses, so it also
   returned the SYSTEM symbols List, Times, Power, Rational and reported them
   as "unexpected".  A pure check bug; the physics had already passed.

   Rather than repeat the 13.5-minute eps^0 extraction, this script RESUMES
   from the checkpoint -- which is precisely what the checkpoint was added
   for -- and runs only the parts that never executed:
     * integrity of the saved objects (they must be the big ones, not stubs);
     * the corrected projM whitelist check;
     * the placeholder V-block (V1 invertibility, V2 entries, V3 rows).
   The sector gates already PASSED in 14206331 (eps-free, Float-free,
   whitelist-clean, nonzero, and the ComplexInfinity/Indeterminate
   finiteness assertion) and are re-run here because they are cheap relative
   to a rebuild and this script must stand alone as the acceptance record.  *)

$HistoryLength = 0;
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python",
                "cache"}]];
src = FileNameJoin[{root, "Hqqbar_F12hat.mx"}];
If[!FileExistsQ[src], Print["FATAL: missing ", src]; Quit[1]];
Print["loading ", src, " (", FileByteCount[src]/1.*^6, " MB on disk)"];
Get[src];

(* INTEGRITY.  The .mx is only ~0.23 MB while the objects were ~195 MB in
   memory, so confirm the symbols really carry the expressions and were not
   saved as empty stubs (DumpSave on a Module-LOCAL saves the renamed local
   and restores nothing -- STATE 0z lesson).                              *)
Do[If[Head[s] === Symbol,
     Print["FATAL: ", HoldForm[s], " restored as an unassigned symbol"];
     Quit[1]],
   {s, {F1hatQQB, F2hatQQB, FgF, FppF}}];
Print["[I] ByteCounts  FgF ", ByteCount[FgF], "  FppF ", ByteCount[FppF],
      "  F1hat ", ByteCount[F1hatQQB], "  F2hat ", ByteCount[F2hatQQB]];
If[ByteCount[FgF] < 10^6 || ByteCount[FppF] < 10^6,
  Print["FATAL: restored sectors are far too small -- the checkpoint did "
        <> "not capture the expressions"]; Quit[1]];
Print["[I] checkpoint integrity OK"];

xh = x/xi;
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
  (* THE FINITENESS ASSERTION.  eps-freeness is NOT finiteness: the extractor
     a_0 = d/d(eps)[eps t] at 0 is exact only for an at-most-SIMPLE pole, and
     a double pole surfaces as ComplexInfinity/Indeterminate -- an explicit
     atom, not a surviving `eps`.  (STATE 0z.117: an Indeterminate was once
     printed as a verdict.)                                               *)
  If[!FreeQ[e, ComplexInfinity | Indeterminate | DirectedInfinity | Infinity],
    Print["FATAL: ", label, " is NOT FINITE -- carries ",
      DeleteDuplicates[Cases[e,
        ComplexInfinity | Indeterminate | _DirectedInfinity,
        {0, Infinity}, Heads -> True]]];
    Quit[1]];];

gate[FgF,  "Fg  sector"];
gate[FppF, "Fpp sector"];
Print["[3] gates passed: eps-free, FINITE, Float-free, whitelist, nonzero"];

(* corrected projM whitelist check -- Context filter present this time *)
projMstray = Complement[SymbolName /@ Cases[projM,
    _Symbol?(Context[#] === "Global`" &), {0, Infinity}, Heads -> True],
  allowed];
Print["[3b] projM Global` symbols outside the whitelist (must be {}): ",
  projMstray];
If[projMstray =!= {},
  Print["FATAL: projector matrix carries ", projMstray]; Quit[1]];

(* ---- V-block, on PLACEHOLDERS (see Hqqbar_F1_assemble.wls header) ------ *)
Clear[fg, fpp];
{F1sym, F2sym} = projM . {fg, fpp};

detM = Simplify[Det[projM]];
Print["[V1] det projM = ", detM // InputForm, "   reference -4 xh^3/Q2 = ",
      Simplify[-4 (x/xi)^3/Q2] // InputForm];
If[TrueQ[detM === 0] ||
   !TrueQ[Simplify[detM - (-4 (x/xi)^3/Q2)] === 0],
  Print["FATAL: projM singular or not the reference matrix"]; Quit[1]];
recovered = Simplify[Inverse[projM] . {F1sym, F2sym}];
Print["[V1] recovered {Fg, Fpp} = ", recovered // InputForm];
If[!TrueQ[Simplify[recovered - {fg, fpp}] === {0, 0}],
  Print["FATAL: projector inversion failed"]; Quit[1]];

refM = {{-1/2, 2 (x/xi)^2/Q2}, {-(x/xi), 12 (x/xi)^3/Q2}};
Print["[V2] projM - reference = ", Simplify[projM - refM] // InputForm];
If[!TrueQ[Simplify[projM - refM] === {{0, 0}, {0, 0}}],
  Print["FATAL: projM is not the reference-section-10 projector"]; Quit[1]];

Print["[V3] rows independent: ", !TrueQ[Simplify[F1sym - F2sym] === 0]];
If[TrueQ[Simplify[F1sym - F2sym] === 0],
  Print["FATAL: the two projector rows coincide"]; Quit[1]];

Print["[V] verification passed -- Hqqbar F1hat/F2hat ACCEPTED"];
Print["HQQBAR_F1_DONE -> ", src];

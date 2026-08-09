#!/usr/bin/env wolframscript
(* Assemble F1hat and F2hat for the REGULAR sector, in Mathematica.

   WHY HERE AND NOT IN PYTHON.  python/F12_assemble_invariant.py states the
   governing rule: each sector is assembled "in whichever language already
   holds it", because BOTH conversion directions were measured to fail
   (write_m did not finish; sympify hits RecursionError).  The regular sector
   is now a Mathematica .mx -- the sympy R5 map died with MemoryError at
   179.7 GB inside verify_homogeneity (job 14198634) -- so by that same rule
   the regular assembly belongs here.  The three DISTRIBUTION sectors are
   already assembled in mathematica/F12_distribution_assemble.wls.

   WHAT IS COMPUTED.  The eps -> 0 extraction projectors, which are linear and
   therefore act sector by sector:

       F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
       F2hat = -xh Fg + (12 xh^3/Q2) Fpp

   with Fg, Fpp the SAME sector in the two photon projections.

   GATES, enforced not assumed (identical to the Python assembler's):
     FRAME     -- no compact-frame symbol (R5S, R5M, R5K, z, x, xi, PHT,
                  A5mask) may reach the assembly; mixing frames is the
                  failure mode of STATE 0z.72/0z.73 and WRONG.md category D.
     EXACTNESS -- no _Real may appear; one 0.5 produced a spurious
                  32381-leaf "pole" that was pure roundoff (STATE 0z.87).
     eps-FREE  -- these are eps^0 coefficients of a pole-free combination.

   Run: R5CH=<channel> math -script mathematica/F12_regular_assemble.wls
*)

$HistoryLength = 0;

channel = Environment["R5CH"];
If[!StringQ[channel] || channel === "",
  Print["usage: R5CH=<channel> math -script F12_regular_assemble.wls"];
  Quit[1]];
Print["channel = ", channel];

root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python", "cache"}]];

(* BOTH .mx FILES DEFINE THE SAME SYMBOL `mapped` (DumpSave stores the symbol,
   not the file name), so loading the second would SILENTLY CLOBBER the first.
   Load one at a time and bind it to a distinct name before the next Get. *)
loadSector[proj_] := Module[{file},
  file = FileNameJoin[{root, channel <> "_R5inv_" <> proj <> ".mx"}];
  If[!FileExistsQ[file], Print["FATAL: missing ", file]; Quit[1]];
  Clear[mapped];
  Get[file];
  If[Head[mapped] === Symbol,
    Print["FATAL: ", file, " did not define `mapped`"]; Quit[1]];
  Print["  loaded ", proj, ": ByteCount = ", ByteCount[mapped]];
  mapped];

Fg = loadSector["g"];
Fpp = loadSector["PP"];
Clear[mapped];
If[ByteCount[Fg] === ByteCount[Fpp],
  Print["WARNING: the two projections have identical ByteCount -- check that "
        <> "the second Get did not clobber the first"]];

(* ---- gates ---------------------------------------------------------- *)
compact = {"R5S", "R5M", "R5K", "z", "x", "xi", "PHT", "A5mask"};
allowed = {"s", "t1", "Q2", "s23", "Nc", "CF", "nf", "ee", "eq", "gs", "B",
           "xh"};

gate[expr_, label_] := Module[{syms, names, stray},
  syms = DeleteDuplicates[
    Cases[expr, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
          Heads -> True]];
  names = SymbolName /@ syms;
  stray = Intersection[names, compact];
  If[stray =!= {},
    Print["FRAME GATE FAILED: ", label, " carries ", stray]; Quit[1]];
  If[!FreeQ[expr, _Real],
    Print["EXACTNESS GATE FAILED: ", label, " carries a machine number"];
    Quit[1]];
  If[MemberQ[names, "eps"],
    Print["EPS GATE FAILED: ", label, " still carries eps"]; Quit[1]];
  stray = Complement[names, allowed];
  If[stray =!= {},
    Print["WHITELIST GATE FAILED: ", label, " carries ", stray]; Quit[1]];
  Print["  gates passed for ", label, ": ", Sort[names]];];

gate[Fg, "g regular"];
gate[Fpp, "PP regular"];

(* ---- the projectors ------------------------------------------------- *)
F1hatRegular = -Fg/2 + 2 xh^2 Fpp/Q2;
F2hatRegular = -xh Fg + 12 xh^3 Fpp/Q2;
Print["  F1hat ByteCount = ", ByteCount[F1hatRegular],
      ";  F2hat ByteCount = ", ByteCount[F2hatRegular]];

out = FileNameJoin[{root, "F12hat_regular_" <> channel <> ".mx"}];
DumpSave[out, {F1hatRegular, F2hatRegular}];
Print["F12_REGULAR_ASSEMBLE_DONE ", channel, " -> ", out,
      " (", FileByteCount[out]/1.*^6, " MB)"];

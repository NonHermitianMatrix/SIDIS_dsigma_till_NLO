#!/usr/bin/env wolframscript
(* Pre-promotion verification of a finished channel, on the FILES THEMSELVES.

   STATE 0z.94 H.3 requires that eps-freedom and Float-freedom be checked ON
   THE PROMOTED FILES, not on the objects that produced them -- a stale or
   half-written copy is exactly what this catches (STATE has a documented case
   of results/ and cache/ copies differing by three days).

   A finished channel is FOUR sectors in each of F1hat and F2hat:

       delta      coefficient of  delta(s23)
       plus1B     coefficient of  [1/s23]_+        on [0, B]
       plus2B     coefficient of  [Log s23/s23]_+  on [0, B]
       regular    an ordinary function of s23

   The three distribution sectors live in <F>hat_dist_<channel>.m as an
   Association; the regular sector lives in F12hat_regular_<channel>.mx.
   All eight objects are checked here.

   Run: R5CH=<channel> math -script mathematica/Hqg_promote_check.wls
*)

$HistoryLength = 0;

channel = Environment["R5CH"];
If[!StringQ[channel] || channel === "",
  Print["usage: R5CH=<channel> math -script Hqg_promote_check.wls"]; Quit[1]];
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python", "cache"}]];
Print["channel = ", channel, "; cache = ", root];

allowed = {"s", "t1", "Q2", "s23", "Nc", "CF", "nf", "ee", "eq", "gs", "B",
           "xh"};
compact = {"R5S", "R5M", "R5K", "z", "x", "xi", "PHT", "A5mask"};
failures = {};

check[expr_, label_] := Module[{syms, names, stray},
  If[expr === 0 || expr === Null,
    AppendTo[failures, label <> ": EMPTY or ZERO"]; Return[]];
  syms = DeleteDuplicates[
    Cases[expr, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
          Heads -> True]];
  names = SymbolName /@ syms;
  If[!FreeQ[expr, _Real],
    AppendTo[failures, label <> ": carries a machine number"]];
  If[MemberQ[names, "eps"],
    AppendTo[failures, label <> ": still carries eps"]];
  stray = Intersection[names, compact];
  If[stray =!= {},
    AppendTo[failures, label <> ": compact-frame symbols " <> ToString[stray]]];
  stray = Complement[names, allowed];
  If[stray =!= {},
    AppendTo[failures, label <> ": stray symbols " <> ToString[stray]]];
  Print["  ", label, ": LeafCount ", LeafCount[expr], ", symbols ",
        Sort[names]];];

(* ---- the three distribution sectors, from the .m associations -------- *)
Do[
  Module[{file, assoc},
    file = FileNameJoin[{root, fh <> "hat_dist_" <> channel <> ".m"}];
    If[!FileExistsQ[file],
      AppendTo[failures, file <> ": MISSING"];
      Print["  MISSING ", file],
      assoc = Get[file];
      If[Head[assoc] =!= Association,
        AppendTo[failures, file <> ": not an Association"],
        (* READ the keys rather than assuming a naming.  Two conventions are
           in play: BigTMD says delta/plus1B/plus2B, these stage-2 files say
           delta/plus1/plus2.  Assuming the first produced 4 spurious "key
           MISSING" failures on complete data (job 14199409).  Require the
           key SET to be one of the two, and check whatever is there. *)
        Print["  ", fh, "hat keys: ", Keys[assoc]];
        If[Sort[Keys[assoc]] =!= {"delta", "plus1", "plus2"} &&
           Sort[Keys[assoc]] =!= {"delta", "plus1B", "plus2B"},
          AppendTo[failures,
            fh <> "hat: unexpected key set " <> ToString[Keys[assoc]]]];
        Do[check[assoc[sec], fh <> "hat " <> sec], {sec, Keys[assoc]}]]]],
  {fh, {"F1", "F2"}}];

(* ---- the regular sector, from the .mx -------------------------------- *)
mxfile = FileNameJoin[{root, "F12hat_regular_" <> channel <> ".mx"}];
If[!FileExistsQ[mxfile],
  AppendTo[failures, mxfile <> ": MISSING"],
  Get[mxfile];
  check[F1hatRegular, "F1hat regular"];
  check[F2hatRegular, "F2hat regular"]];

(* ---- verdict --------------------------------------------------------- *)
If[failures =!= {},
  Print["PROMOTE_CHECK_FAILED (", Length[failures], "):"];
  Do[Print["   ", f], {f, failures}];
  Quit[1]];
Print["PROMOTE_CHECK_OK ", channel, " -- all 8 objects eps-free, Float-free, "
      <> "frame-clean, whitelist-clean"];

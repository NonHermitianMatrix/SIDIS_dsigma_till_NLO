#!/usr/bin/env wolframscript
(* Pre-promotion verification for Hqqbar (channel 5), ON THE FILE ITSELF.

   STATE 0z.94 H.3: eps-freedom and Float-freedom are checked on the PROMOTED
   FILE, not on the objects that produced it -- that is what catches a stale
   or half-written copy (STATE has a case of results/ and cache/ copies
   differing by three days).

   CHANNEL 5 IS REGULAR-ONLY, so unlike Hgq/Hqg there are just TWO objects,
   not eight: there are no delta/plus1/plus2 sectors to check, because R4
   found no endpoint classes at all (verified term by term: V >= 0 for every
   one of the 1610/1559 terms) and the counterterms vanish identically
   (Hglu_S12_CT.LO[('q','qb')] is None -- gamma* q -> qbar + X does not exist
   at O(alphas)).  A promotion check that looked for the missing sectors would
   fail spuriously, exactly as the first Hqg check did by assuming BigTMD's
   plus1B/plus2B naming (job 14199409).

   WHAT IS NOT CHECKED HERE, and must be said when this channel is quoted:
     * the finite VALUES are unvalidated -- check 15 has never been run for
       ANY channel, and channel 5 has NO external reference at all, since
       BigTMD ships fchn5A/B/C but EXCLUDES chn 5 from its cross section
       (`for chn in [1,2,3,4,6]`, sidis.py line 191);
     * no explicit mu labelling;
     * the (xi, s23) integration and the luminosities are applied downstream.

   Run: R5CACHE=<dir> math -script mathematica/Hqqbar_promote_check.wls
*)

$HistoryLength = 0;

root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python",
                "cache"}]];
file = FileNameJoin[{root, "Hqqbar_F12hat.mx"}];
If[!FileExistsQ[file], Print["FATAL: missing ", file]; Quit[1]];
Print["checking ", file, " (", FileByteCount[file]/1.*^6, " MB)"];
Get[file];

allowed = {"x", "xi", "z", "PHT", "Q2", "s23", "Nc", "ee", "eq", "gs"};
compact = {"R5S", "R5M", "R5K", "s", "t1", "u1", "A5mask"};
failures = {};

check[e_, label_] := Module[{syms, names, stray},
  If[e === 0 || Head[e] === Symbol,
    AppendTo[failures, label <> ": EMPTY or ZERO"]; Return[]];
  syms = DeleteDuplicates[
    Cases[e, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
          Heads -> True]];
  names = SymbolName /@ syms;
  If[MemberQ[names, "eps"],
    AppendTo[failures, label <> ": still carries eps"]];
  If[!FreeQ[e, _Real],
    AppendTo[failures, label <> ": carries a machine number"]];
  stray = Intersection[names, compact];
  If[stray =!= {},
    AppendTo[failures, label <> ": INVARIANT-frame symbols survive "
                       <> ToString[stray] <> " -- frame mixing"]];
  stray = Complement[names, allowed];
  If[stray =!= {},
    AppendTo[failures, label <> ": stray symbols " <> ToString[stray]]];
  Print["  ", label, ": LeafCount ", LeafCount[e], ", ByteCount ",
    ByteCount[e], ", symbols ", Sort[names]];];

check[F1hatQQB, "F1hat"];
check[F2hatQQB, "F2hat"];

(* The two must be genuinely DIFFERENT objects: F1hat and F2hat use different
   projector combinations, so equality would mean one overwrote the other. *)
If[F1hatQQB === F2hatQQB,
  AppendTo[failures, "F1hat and F2hat are IDENTICAL -- one clobbered the other"]];

If[failures =!= {},
  Print["PROMOTE_CHECK_FAILED (", Length[failures], "):"];
  Do[Print["   ", f], {f, failures}];
  Quit[1]];
Print["PROMOTE_CHECK_OK Hqqbar -- both objects eps-free, Float-free, "
      <> "frame-clean, whitelist-clean, distinct"];

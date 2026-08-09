#!/usr/bin/env wolframscript
(* Hqqbar (channel 5): SUBTRACTED regular sector, and the pole check on it.

       regular_subtracted = kf J Hreal + PREF (CTpdf.Creg + CTff.Creg)

   the PLUS sign of Eq. (46).  Rend = 0 for this channel (R4 found no endpoint
   classes, verified term by term), so the CT Creg is the WHOLE subtraction and
   Cdelta = Cplus = 0 on both sides -- consistent with R4, checked at export.

   WHY THERE IS A COUNTERTERM AT ALL (STATE 0z.116).  The master formula needs
   WhatLO_{i'' j} for CTpdf and WhatLO_{i j''} for CTff, NOT the diagonal
   LO_{i,j}.  For incoming q, fragmenting qbar:
       CTpdf = P0_{g/q} (x) LO_{g,qbar}      CTff = P0_{qbar/g} (x) LO_{q,g}
   both of which exist.  I had looked up LO[('q','qb')] -- the diagonal entry,
   legitimately None -- and wrongly concluded the channel needs no subtraction.

   ================== OPTIMISED FROM THE MATH, NOT THE MACHINE ==============
   The previous version scanned k = 3, 2, 1, 0, doing a FULL parallel sweep of
   ~1600 terms at every order (measured: ~7 min per sweep).  Three facts about
   these expressions remove almost all of that work:

   (O1) THE POLE ORDER IS READABLE, NOT SEARCHABLE.  After the Gamma rewrite
        every singularity is an EXPLICIT Power[eps, negative], so each term's
        pole order is a cheap structural read.  Take k0 = max over terms.  No
        search, no wasted sweeps at k = 3 and 2 that were never plausible --
        there is no soft region in this channel, so eps^-2 was never expected.

   (O2) ONLY THE DEEPEST TERMS CONTRIBUTE TO THE LEADING POLE.  A term with
        pole order < k0 satisfies  t eps^k0 -> 0,  so it contributes NOTHING
        to the leading residue and can be dropped before any algebra.  On the
        unsubtracted run 924 of 1610 terms carried the pole, so this discards
        ~40% of the work outright.

   (O3) THE PREFACTOR IS FINITE, SO IT FACTORS OUT AT THE LEADING ORDER.
        pref = s23^(-eps) kf jac is regular at eps = 0, hence
            Res_{k0}(pref * t) = pref|_{eps=0} * Res_{k0}(t) .
        The old code multiplied an 83-leaf prefactor into all ~1600 terms
        before substituting; now it is evaluated ONCE at eps = 0 and applied
        to the summed residue.  (This is valid ONLY for the LEADING order --
        at subleading orders pref's own eps expansion convolves with the
        term's, so the script refuses to use the shortcut there.)

   GUARDS KEPT.  Every residue is tested for ComplexInfinity /
   DirectedInfinity / Indeterminate and the script ABORTS rather than
   reporting -- the previous run printed "NONZERO" for a value that was
   actually Indeterminate (trap E.2).

   Run: R5CACHE=<dir> R5NAME=<MR2PPQQB|MR2gQQB> CTPROJ=<g|PP> NKERN=<n>
        math -script mathematica/Hqqbar_R5_subtract.wls
*)

$HistoryLength = 0;

name = Environment["R5NAME"]; If[!StringQ[name] || name === "", name = "MR2PPQQB"];
ctp  = Environment["CTPROJ"]; If[!StringQ[ctp] || ctp === "", ctp = "PP"];
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python", "cache"}]];
nreq = ToExpression[Environment["NKERN"]]; If[!IntegerQ[nreq] || nreq < 1, nreq = 8];
Print["sector = ", name, "; CT projection = ", ctp];

f1 = FileNameJoin[{root, "Hqqbar_R5_" <> name <> ".mx"}];
f2 = FileNameJoin[{root, "Hqqbar_CT_" <> ctp <> ".m"}];
If[!FileExistsQ[f1] || !FileExistsQ[f2],
  Print["FATAL: missing ", If[FileExistsQ[f1], f2, f1]]; Quit[1]];
Get[f1];
If[Head[regular] === Symbol, Print["FATAL: no `regular`"]; Quit[1]];
Get[f2];
(* THE JACOBIAN BELONGS ON THE COUNTERTERM TOO -- the error that made every
   previous pole check fail.  In the production R5 (python/Hqq_R5_exact.py)
   BOTH pieces carry it:
       line 142 (real) : mapped     = weight * R5_JAC * _invariant_to_compact[term]
       line 276 (CT)   : expression = PREF   * R5_JAC * _invariant_to_compact[cterm]
   and it follows from the master formula: the real term and the subtraction
   are contributions to the SAME Whatmunu, so changing variables to (xi, s23)
   gives BOTH the Jacobian J.  My assembly had
       real = kf jac Hreal        (jac present)
       CT   = PREF Creg           (jac MISSING)
   and since jac is kinematic-dependent, a CT without it has a DIFFERENT
   kinematic structure from the pole it must cancel -- so no pole-order
   bookkeeping, however careful, could ever have made them cancel.
   THE JACOBIAN IS APPLIED IN THE EXPORTER (python/Hqqbar_CT_export_m.py,
   `ct = PREF*jac*total`), so it must NOT be applied again here -- doing both
   would square it.                                                        *)
ct = r5regular;
Print["[1] loaded: regular ByteCount ", ByteCount[regular],
      ", CT LeafCount ", LeafCount[ct]];

gammaRules = {
  Gamma[-eps]     :> Gamma[1 - eps]/(-eps),
  Gamma[-1 - eps] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-eps - 1] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-2 eps]   :> Gamma[1 - 2 eps]/(-2 eps)};
regPart = (s23^(-eps) regular) //. gammaRules;
ctPart  = ct //. gammaRules;
bad = DeleteDuplicates[Cases[{regPart, ctPart},
  Gamma[a_] /; With[{v = Simplify[a /. eps -> 0]}, IntegerQ[v] && v <= 0],
  {0, Infinity}]];
If[bad =!= {}, Print["FATAL: uncovered singular Gamma ", bad]; Quit[1]];
Print["[2] Gamma rewrite complete on BOTH pieces"];

(* split the REGULAR sector's INNER sum; the CT is one extra term *)
{pref, sum} = If[Head[regPart] === Times,
   Module[{facs, sizes, pos},
     facs = List @@ regPart;
     sizes = If[Head[#] === Plus, Length[#], 0] & /@ facs;
     pos = First[Ordering[sizes, -1]];
     If[sizes[[pos]] === 0, {1, regPart},
       {Times @@ Delete[facs, pos], facs[[pos]]}]],
   {1, regPart}];
terms = If[Head[sum] === Plus, List @@ sum, {sum}];
Print["[3] regular: prefactor LeafCount ", LeafCount[pref], ", inner sum ",
  Length[terms], " terms"];
If[Length[terms] < 2,
  Print["FATAL: the regular sector did not split -- head ", Head[regPart]];
  Quit[1]];

(* ---- (O3) the prefactor at eps = 0, once ------------------------------ *)
pref0 = Simplify[pref /. eps -> 0];
If[!FreeQ[pref0, ComplexInfinity | DirectedInfinity | Indeterminate],
  Print["FATAL: the prefactor is NOT regular at eps = 0, so it cannot be "
        <> "factored out of the leading residue"]; Quit[1]];
Print["[4] pref|_{eps=0} LeafCount ", LeafCount[pref0], " (finite: shortcut valid)"];

(* ---- (O1) each term's pole order, read off structurally --------------- *)
(* POLE ORDER -- BY WHAT THE DENOMINATOR DOES, NOT BY WHAT IT LOOKS LIKE.
   The previous criterion matched only Power[eps, negative], i.e. a base
   LITERALLY equal to eps.  But any Power[b, negative] whose base merely
   VANISHES at eps = 0 -- Power[eps + eps^2, -1] and friends -- diverges
   identically and does NOT match that pattern, so Cases could never see it.
   That is why poleOrd reported max order 1 while terms still blew up at
   eps^1, and the diagnostic (job 14205484) showed
       Power::infy: Infinite expression 1/0
       Infinity::indet: 0 * ComplexInfinity
   i.e. a vanishing coefficient meeting an invisible pole.
   Test the base's VALUE at eps = 0 instead.  PossibleZeroQ is the cheap
   structural test; a base that is identically zero there is a genuine
   eps-pole of order |n|.                                                  *)
poleOrd[t_] := Module[{ps},
  ps = Cases[t,
    Power[b_, n_ /; NumberQ[n] && n < 0] /;
      TrueQ[PossibleZeroQ[b /. eps -> 0]] :> -n,
    {0, Infinity}];
  If[ps === {}, 0, Total[ps]]];   (* powers multiply -> orders add *)

ords = poleOrd /@ terms;
kReg = Max[Append[ords, 0]];
kCT  = poleOrd[ctPart];
k0 = Max[kReg, kCT];
Print["[5] pole order: regular sector max ", kReg, ", counterterm ", kCT,
      " -> leading order eps^-", k0];
If[k0 === 0,
  Print["[6] NO POLE AT ALL -- subtracted sector is already finite"];
  Print["HQQBAR_SUBTRACT_DONE ", name]; Quit[0]];

(* ---- (O2) keep only the terms that reach the leading order ------------ *)
deep = Pick[terms, ords, k0];
Print["[6] terms reaching eps^-", k0, ": ", Length[deep], " of ",
  Length[terms], " (", Round[100. Length[deep]/Length[terms]], "% -- the rest "
  <> "cannot contribute to the leading residue)"];

launched = Quiet[Check[LaunchKernels[nreq], {}]];
nk = Length[Kernels[]];
Print["[7] kernels launched: ", nk];

(* NORMALISE THE TERM BEFORE SUBSTITUTING.  `t eps^k /. eps -> 0` evaluates
   each FACTOR independently, so a term that is a product with one factor
   going to 0 and another to ComplexInfinity returns Indeterminate -- the
   cancellation between them is never performed, and multiplying by eps^k
   cannot help because the zero and the infinity sit in DIFFERENT factors.
   Probe 14205505 showed exactly this: 9 harmless eps-free denominators, ONE
   genuine order-1 eps pole, and yet the term still "diverged" at eps^2, which
   is impossible for a simple pole.  The term printed as
       0 * ee^2 eq^2 gs^4 Nc Q2 Sqrt[s23] (...) * ComplexInfinity
   i.e. 0 x infinity, not a deep pole.
   `Together` puts the term over a common denominator first, so numerator and
   denominator cancel and the limit is taken on a single fraction.  Terms are
   small (~6600 leaves), so this is cheap PER TERM -- it is only a global
   Together that must be avoided.                                          *)
resid[t_] := Module[{u},
  u = Together[t eps^k0];
  u = Cancel[u];
  u /. eps -> 0];
DistributeDefinitions[eps, k0];
parts = If[nk > 0, ParallelMap[resid, deep], Map[resid, deep]];
If[AnyTrue[parts, !FreeQ[#, ComplexInfinity | DirectedInfinity |
                            Indeterminate] &],
  Print["FATAL: a per-term residue is infinite/Indeterminate -- the pole "
        <> "order read from the structure is wrong"]; Quit[1]];

(* regular contribution, with the prefactor applied ONCE, plus the CT *)
resReg = pref0 Total[parts];
resCT  = If[kCT === k0, ctPart eps^k0 /. eps -> 0, 0];
total  = resReg + resCT;
If[!FreeQ[total, ComplexInfinity | DirectedInfinity | Indeterminate],
  Print["FATAL: the summed residue is infinite/Indeterminate -- NOT a verdict"];
  Quit[1]];
Print["[8] residue assembled: regular LeafCount ", LeafCount[resReg],
      ", CT LeafCount ", LeafCount[resCT]];

If[total === 0,
  Print["[9] eps^-", k0, " residue is STRUCTURALLY ZERO -- pole cancelled"],
  (* NOT a Module-local: DumpSave on a Module variable writes the RENAMED
     local (red$NNN), so `Get` restores nothing and a later script reads a
     bare symbol.  That silently invalidated the first half-test (it saw
     LeafCount 1 and every verdict from it was garbage).  Use a global. *)
  Module[{},
    savedResidue = Together[total];
    Print["[9] after Together: LeafCount ", LeafCount[savedResidue]];
    If[TrueQ[Simplify[savedResidue] === 0],
      Print["[9] eps^-", k0, " residue is ZERO -- the counterterms cancelled "
            <> "the pole.  F1 can proceed."],
      Print["[9] eps^-", k0, " residue is NONZERO, LeafCount ", LeafCount[savedResidue]];
      Print["    free symbols: ", Sort[SymbolName /@ DeleteDuplicates[
        Cases[savedResidue, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
              Heads -> True]]]];
      DumpSave[FileNameJoin[{root, "Hqqbar_subres_" <> name <> ".mx"}], savedResidue];
      Print["    saved for diagnosis"]]]];

CloseKernels[];
Print["HQQBAR_SUBTRACT_DONE ", name];

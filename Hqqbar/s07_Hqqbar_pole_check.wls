#!/usr/bin/env wolframscript
(* Hqqbar (channel 5): does the 1/eps CANCEL, or is a counterterm missing?

   CONTEXT.  I claimed this channel was pole-free.  It is not (STATE 0z.115):
   both R5 sectors carry an explicit 1/eps plus Gamma[-eps], Gamma[-eps-1],
   Gamma[-2 eps], every one of which is singular at eps = 0.  The R4 result
   (no endpoint classes) was correct but says nothing about the OTHER singular
   regions, which are integrated over in R3 and surface as angular-master
   poles.

   TWO POSSIBILITIES, and this script decides between them WITHOUT assuming
   either:
     (1) the counterterms really do vanish (LO[('q','qb')] is None) and the
         poles cancel WITHIN the real contribution -- angular-master poles can
         cancel between terms;
     (2) the CT lookup ('q','qb') was the wrong assignment for this channel
         and there IS a genuine subtraction I dismissed.
   If the eps^-1 coefficient vanishes identically -> (1), and F1 proceeds.
   If it does not -> (2), and the counterterm must be derived before F1.

   METHOD -- MAKE THE POLES EXPLICIT FIRST, THEN IT IS CHEAP.
   `Series` on these operands ran >11 min on one core without a verdict.  But
   Gamma[z] = Gamma[z+1]/z turns every singular Gamma into a regular Gamma
   times an explicit 1/eps:
       Gamma[-eps]     -> Gamma[1-eps]/(-eps)
       Gamma[-eps-1]   -> Gamma[1-eps]/((-eps)(-eps-1))
       Gamma[-2 eps]   -> Gamma[1-2 eps]/(-2 eps)
   After that every remaining Gamma is finite at eps = 0, the pole order is a
   plain power of eps, and the residue is a SUBSTITUTION rather than an
   expansion:  residue_k = (eps^k expr) /. eps -> 0.

   Run: R5CACHE=<dir> R5NAME=<MR2PPQQB|MR2gQQB>
        math -script mathematica/Hqqbar_pole_check.wls
*)

$HistoryLength = 0;

name = Environment["R5NAME"];
If[!StringQ[name] || name === "", name = "MR2PPQQB"];
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python",
                "cache"}]];
file = FileNameJoin[{root, "Hqqbar_R5_" <> name <> ".mx"}];
If[!FileExistsQ[file], Print["FATAL: missing ", file]; Quit[1]];
Print["name = ", name];
Get[file];
If[Head[regular] === Symbol, Print["FATAL: no `regular`"]; Quit[1]];
Print["[1] loaded, ByteCount = ", ByteCount[regular]];

(* restore the measure factor kf omits *)
expr = s23^(-eps) regular;

(* ---- make every singular Gamma explicit ------------------------------ *)
gammaRules = {
  Gamma[-eps]     :> Gamma[1 - eps]/(-eps),
  Gamma[-1 - eps] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-eps - 1] :> Gamma[1 - eps]/((-eps) (-1 - eps)),
  Gamma[-2 eps]   :> Gamma[1 - 2 eps]/(-2 eps)};
expr = expr //. gammaRules;

bad = DeleteDuplicates[Cases[expr,
  Gamma[a_] /; With[{v = Simplify[a /. eps -> 0]}, IntegerQ[v] && v <= 0],
  {0, Infinity}]];
Print["[2] singular Gammas remaining after the rewrite: ", bad];
If[bad =!= {},
  Print["FATAL: a singular Gamma was not covered by gammaRules -- add it "
        <> "deliberately rather than letting it hide a pole"]; Quit[1]];

(* ---- pole order, structurally --------------------------------------- *)
negs = DeleteDuplicates[
  Cases[expr, Power[eps, n_ /; NumberQ[n] && n < 0], {0, Infinity}]];
Print["[3] explicit negative powers of eps present: ", negs];
kmax = If[negs === {}, 0, -Min[Cases[negs, Power[eps, n_] :> n]]];
Print["[3] leading pole order = eps^-", kmax];
If[kmax === 0,
  Print["[3] no pole after all -- expression is regular"];
  Print["HQQBAR_POLE_CHECK_DONE ", name, " residue = 0 (no pole)"]; Quit[0]];

(* ---- the residue at each pole order, by SUBSTITUTION not expansion --- *)
Do[
  Module[{res},
    res = Together[eps^k expr] /. eps -> 0;
    res = Simplify[res];
    Print["[4] eps^-", k, " residue: ", If[res === 0, "ZERO",
      "NONZERO, LeafCount " <> ToString[LeafCount[res]]]];
    If[res =!= 0 && k === kmax,
      Print["    (this is the leading pole; it must be cancelled by a "
            <> "counterterm or by the rest of the channel)"]];
    ], {k, kmax, 1, -1}];

Print["HQQBAR_POLE_CHECK_DONE ", name];

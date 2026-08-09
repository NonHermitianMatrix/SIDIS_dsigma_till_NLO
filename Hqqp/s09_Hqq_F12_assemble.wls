#!/usr/bin/env wolframscript
(* Step F1 -- assemble the partonic structure functions from a channel's four
   finished pieces, and with them the cross section.

   WHAT GOES IN.  A channel is complete once it has, in EACH photon projection,
       delta(s23) coefficient, plus1B, plus2B   (from C2)
       regular(s23)                             (from R5)
   Channel Hgg is the first to reach that state: its endpoint residue vanishes in
   both projections, so delta = plus1B = plus2B = 0 identically, and its whole
   content is the regular part.

   THE ASSEMBLY (AI.md sec. 10; these ARE the eps -> 0 limit of the eps-exact
   extraction projectors of sec. 2, which is a consistency check in itself):
       F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
       F2hat = -xh Fg + (12 xh^3/Q2) Fpp
   where Fg and Fpp are the SAME assembled quantity in the two projections.
   The measured cross section then follows from
       dsigma/(dx dy dz dPHT2)
           = (Pi^2 alphaEM^2)/(z x y Q2) [ x y^2 F1 + (1-y) F2 ]
   with F1, F2 the convolutions of F1hat, F2hat with the PDFs and FFs -- that
   convolution is NUMERICS (step N1) and is NOT done here.  This stage is
   algebraic only, per the standing "no decimals" directive.

   Env: F12CHAN (label used in the output names), F12G / F12PP (paths to the
        two projections' assembled hard functions), C2ROOT.                   *)

$HistoryLength = 0;
chan = Environment["F12CHAN"]; If[chan === $Failed, chan = "Hgg"];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];
fg = Environment["F12G"]; fpp = Environment["F12PP"];
If[fg === $Failed, fg = root <> "r5reg_MR2g" <> ToUpperCase[chan] <> ".m"];
If[fpp === $Failed, fpp = root <> "r5reg_MR2PP" <> ToUpperCase[chan] <> ".m"];
If[!FileExistsQ[fg], Print["FATAL missing ", fg]; Quit[1]];
If[!FileExistsQ[fpp], Print["FATAL missing ", fpp]; Quit[1]];

Fg = Get[fg];
Fpp = Get[fpp];
Print["F12 channel ", chan, "  Fg LeafCount ", LeafCount[Fg],
      "  Fpp LeafCount ", LeafCount[Fpp]];
If[LeafCount[Fg] < 2 && LeafCount[Fpp] < 2,
   Print["NOTE: both projections are trivial -- nothing to assemble"]];

(* the eps -> 0 extraction projectors *)
F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp;
F2hat = -xh Fg + (12 xh^3/Q2) Fpp;
Print["  F1hat LeafCount ", LeafCount[F1hat],
      "   F2hat LeafCount ", LeafCount[F2hat]];

(* gates: the structure functions must be eps-free and carry no frame variables *)
stray = Select[{x, z, PHT, xi}, ! FreeQ[{F1hat, F2hat}, #] &];
Print["  frame gate stray ", stray, "  (must be {})   eps-free ",
      FreeQ[{F1hat, F2hat}, eps], "   finite ",
      FreeQ[{F1hat, F2hat}, ComplexInfinity | Indeterminate]];

(* GATE MADE AN ASSERTION, 2026-08-08.  verified/MANIFEST.md flagged this
   exact weakness -- "that script's `eps-free` and `finite` gates are `Print`s,
   not assertions: `Put` runs unconditionally" -- and it is how the Hgg F-hats
   were written 85 minutes AFTER a recorded pole failure.  A gate that cannot
   fail is not a gate. *)
If[stray =!= {} || ! FreeQ[{F1hat, F2hat}, eps] ||
   ! FreeQ[{F1hat, F2hat}, ComplexInfinity | Indeterminate],
   Print["FATAL: F1hat/F2hat failed the frame / eps-free / finite gate; "
         <> "nothing written"];
   Quit[1]];

Put[F1hat, root <> "F1hat_" <> chan <> ".m"];
Put[F2hat, root <> "F2hat_" <> chan <> ".m"];
(* The exact expanded hard functions live in the .m files.  Serializing
   multi-million-leaf sums through TeXForm is not algebra and can dominate the
   entire stage.  Emit the exact projector relation compactly for the report;
   retain literal expanded TeX as an explicit debugging opt-in. *)
If[Environment["F12_FULL_TEX"] === "1",
  Export[root <> "F1hat_" <> chan <> ".tex", TeXForm[F1hat], "Text"];
  Export[root <> "F2hat_" <> chan <> ".tex", TeXForm[F2hat], "Text"],
  Export[root <> "F1hat_" <> chan <> ".tex",
    StringJoin["\\widehat F_1^{", chan,
      "}=-\\frac12\\,H_g^{", chan,
      "}+\\frac{2\\widehat x^2}{Q^2}\\,H_{PP}^{", chan, "}\n"], "Text"];
  Export[root <> "F2hat_" <> chan <> ".tex",
    StringJoin["\\widehat F_2^{", chan,
      "}=-\\widehat x\\,H_g^{", chan,
      "}+\\frac{12\\widehat x^3}{Q^2}\\,H_{PP}^{", chan, "}\n"], "Text"]
];
Print["  wrote F1hat_", chan, ".m/.tex and F2hat_", chan, ".m/.tex"];
Print["F12_ASSEMBLE_DONE ", chan];

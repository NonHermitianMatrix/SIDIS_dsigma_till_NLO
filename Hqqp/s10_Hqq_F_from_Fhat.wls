#!/usr/bin/env wolframscript
(* Step F2 -- the hadronic structure functions F1, F2 from the partonic F1hat,
   F2hat, written out as the explicit convolution integrand.

   WHAT THIS STEP DOES AND DOES NOT DO ABOUT SINGULARITIES.
   The eps poles are NOT removed here.  They are removed by MASS FACTORIZATION at
   the PARTONIC level (WS13, Eq. (46) of arXiv:1903.01529),
       What^NLO = W^NLO_unsub - What^LO (x) f^(as) - What^LO (x) D^(as),
   which is steps S1/S2/C2.  Convolving with a FINITE PDF and FF cannot cancel a
   1/eps pole -- if F1hat still had one, F1 would carry it unchanged.  So this
   stage REQUIRES eps-free input and asserts it.
   What the convolution does handle is the DISTRIBUTIONAL singularity in s23:
   the delta(s23), [1/s23]_+ and [Log s23/s23]_+ pieces only have meaning inside
   the s23 integral, against the smooth PDF/FF.  That is precisely why the hard
   functions are kept in the delta/plus/regular decomposition.

   THE FACTORIZATION FORMULA, verbatim (AI.md sec. 3).  NOTE the asymmetry --
   there is no 1/xi in the F2 line; it comes from the different powers of
   momentum in the two tensor structures:
     F1(x,z,Q2,qT) = Int_x^1 (dxi/xi) Int_z^1 (dzeta/zeta^2)
                       F1hat_ij(x/xi, z/zeta, Q2, qT) f_{i/P}(xi) d_{H/j}(zeta)
     F2(x,z,Q2,qT) = Int_x^1  dxi    Int_z^1 (dzeta/zeta^2)
                       F2hat_ij(x/xi, z/zeta, Q2, qT) f_{i/P}(xi) d_{H/j}(zeta)

   THE (xi, s23) FORM ACTUALLY INTEGRATED (AI.md sec. 6): trading the FF variable
   zeta for s23 at fixed (x, z, Q2, PHT),
     Int dxi dzeta ... = Int_A^1 dxi Int_0^B ds23 jac ... ,
     jac  = (xh^2 PHT^2 + xh z^2 Q2 (1-xh)) / (z (Q2 (1-xh) - s23 xh)^2),
     zeta = (xh PHT^2 + z^2 Q2 (1-xh)) / (z (Q2 (1-xh) - s23 xh)),
     A    = x + x PHT^2/(z (1-z) Q2),
     B    = Q2 (1/xh - 1)(1-z) - PHT^2/z,
   so that, with the four finished pieces of a channel,
     F = Int_A^1 dxi (1/xi or 1) f_i(xi) Int_0^B ds23 jac(s23) d_j(zeta(s23))
           x [ delta(s23) Cdelta + [1/s23]_+ Cplus1
               + [Log s23/s23]_+ Cplus2 + regular(s23) ].
   The plus prescription on [0,B] is
     Int_0^B ds23 [F]_+ G = Int_0^B ds23 F(s23) (G(s23) - G(0)).

   THIS STAGE IS ALGEBRAIC ONLY.  f_{i/P} and d_{H/j} are kept as SYMBOLIC
   functions; evaluating them means reading the LHAPDF grids, which is NUMERICS
   (step N1) and is deliberately not done here (standing "no decimals" rule).

   Env: F12CHAN, C2ROOT.  Reads F1hat_<chan>.m / F2hat_<chan>.m and, when
        present, the channel's delta/plus pieces.                             *)

$HistoryLength = 0;
chan = Environment["F12CHAN"]; If[chan === $Failed, chan = "Hgg"];
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];
f1f = root <> "F1hat_" <> chan <> ".m";
f2f = root <> "F2hat_" <> chan <> ".m";
If[!FileExistsQ[f1f] || !FileExistsQ[f2f],
   Print["FATAL: run Hqq_F12_assemble.wls for ", chan, " first"]; Quit[1]];
F1hat = Get[f1f]; F2hat = Get[f2f];

(* the input MUST already be finite -- the convolution cannot cure a pole *)
If[! FreeQ[{F1hat, F2hat}, eps],
   Print["FATAL: F1hat/F2hat still contain eps.  The poles must cancel in C2 "
      <> "BEFORE the convolution; convolving with a finite PDF/FF cannot "
      <> "remove them."]; Quit[1]];
Print["F_from_Fhat channel ", chan, "  F1hat ", LeafCount[F1hat],
      "  F2hat ", LeafCount[F2hat], "   eps-free True"];

(* kinematics, typed verbatim from AI.md sec. 6 *)
xh = x/xi;
jac = (xh^2 PHT^2 + xh z^2 Q2 (1 - xh))/(z (Q2 (1 - xh) - s23 xh)^2);
zeta = (xh PHT^2 + z^2 Q2 (1 - xh))/(z (Q2 (1 - xh) - s23 xh));
Alow = x + x PHT^2/(z (1 - z) Q2);
Bup = Q2 (1/xh - 1) (1 - z) - PHT^2/z;

(* the integrands, with the PDF and FF left SYMBOLIC *)
int1 = (1/xi) fPDF[xi] jac dFF[zeta] F1hat;
int2 =         fPDF[xi] jac dFF[zeta] F2hat;
Print["  F1 integrand LeafCount ", LeafCount[int1],
      "   F2 integrand LeafCount ", LeafCount[int2]];
Print["  xi from ", InputForm[Alow], " to 1;  s23 from 0 to ",
      InputForm[Bup]];

Put[<|"F1integrand" -> int1, "F2integrand" -> int2, "jac" -> jac,
      "zeta" -> zeta, "A" -> Alow, "B" -> Bup|>,
    root <> "Fconv_" <> chan <> ".m"];

(* Do not stringify millions of expanded leaves merely to restate the
   factorization formula.  That serial TeXForm call took longer than the
   calculation and produced an unreadable multi-megabyte equation.  The exact
   expanded integrands remain in Fconv_<chan>.m; the report-facing TeX keeps
   their mathematically identical compact form.  A literal full export remains
   opt-in for debugging only. *)
If[Environment["FCONV_FULL_TEX"] === "1",
  tex = StringJoin["F_1:\\;", ToString[TeXForm[int1]], "\n\nF_2:\\;",
                   ToString[TeXForm[int2]]],
  tex = StringJoin[
    "\\begin{aligned}\n",
    "F_1^{", chan, "}&=\\int_A^1\\frac{d\\xi}{\\xi}\\int_0^B ds_{23}\\,",
    "J(\\xi,s_{23})f_i(\\xi)D_{H/j}(\\zeta)\\,\\widehat F_1^{", chan, "},\\\\\n",
    "F_2^{", chan, "}&=\\int_A^1 d\\xi\\int_0^B ds_{23}\\,",
    "J(\\xi,s_{23})f_i(\\xi)D_{H/j}(\\zeta)\\,\\widehat F_2^{", chan, "}.\n",
    "\\end{aligned}\n"]];
Export[root <> "Fconv_" <> chan <> ".tex", tex, "Text"];
Print["  wrote Fconv_", chan, ".m/.tex"];
Print["F_FROM_FHAT_DONE ", chan];

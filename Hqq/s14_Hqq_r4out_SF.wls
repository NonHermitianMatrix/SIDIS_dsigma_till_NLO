#!/usr/bin/env wolframscript
(* Build r4out_MR2{PP,g}DFA.m for the SF DIRECTLY from its validated endpoint
   residue, bypassing the generic R4 engine.  (STATE.md 0z.408)

   WHY THE ENGINE CANNOT DO THE SF.  The SF angterms carry the GENERAL
   s23-dependent root
       Sqrt[ A(s23)^2 + B(s23)^2 ]
   (positive-definite at finite s23 -- 0z.358 verified this on all 968 roots).
   verified/_shared/Hqq_R4_mma_part2.wls extracts the residue by expanding
   about W -> 0 with s23 = W^2, and THAT is where the root DEGENERATES to
   |Q2 + u1| and the denominators 1/(Q2+u1 -/+ root) blow up -- hence
   "ComplexInfinity-free False" on MR2{PP,g}DFA while QGG and PAIR pass.
   My first fix resolved only the DEGENERATE form (Sqrt[(Q2+u1)^2]) in the
   r4in, so it never fired: at that stage the root is still the general one.
   Handling this correctly needs the FOUR ordered steps of
   mathematica/Hqq_SF_endpoint2.wls (per-class series, Puiseux in sqrt(s23),
   branch resolved before expanding, and resolved VIA A SYMBOL) -- machinery
   the generic engine does not have and should not be taught here.

   ** THE RESIDUE ALREADY EXISTS AND IS VALIDATED. **
   mathematica/Hqq_SF_endpoint_out.m is exactly that object: the s23^-1
   coefficient per eps order, produced by endpoint2.wls with all four defects
   handled, and proven equal to rpair (rpair - sf === 0, 0z.351) -- an
   INDEPENDENT check against a different pipeline.  r4out_<piece>.m is defined
   to hold precisely the merged endpoint residue R, so the right move is to
   write that value, not to re-derive it badly.

   NORMALIZATION.  The other pieces' angterms carry dPi3 inside `sfree`, so
   their residues include it; the endpoint file's entries do NOT (C2 applied
   -dPi3 externally).  So R_SF = dPi3(eps) * Sum_n eps^n E_n.  This factor was
   MEASURED correct against the C2 anchor -- ratio exactly 1 (0z.394) -- not
   assumed.  The flavour multiplicity 2(nf-1) is NOT applied here; it belongs
   at assembly, exactly as the pair's x2 does. *)

$HistoryLength = 0;
dir = DirectoryName[$InputFileName];
sfraw = Import[FileNameJoin[{dir, "Hqq_SF_endpoint_out.m"}]];
If[sfraw === $Failed, Print["FATAL: Hqq_SF_endpoint_out.m missing"]; Quit[1]];

dPi3[e_] := 2^-2 Pi^-e/(2 Pi)^(2 - 2 e) Gamma[1 - e]/Gamma[1 - 2 e];

(* RESOLVE THE DEGENERATE BRANCH HERE, where it is finally the right stage.
   At r4in the root is the GENERAL Sqrt[A(s23)^2+B(s23)^2] and no
   (Q2+u1)^2 rule can fire; AFTER the endpoint extraction it has degenerated to
   Sqrt[(Q2+u1)^2] = |Q2-U|, which the symbol route of 0z.342 resolves exactly:
   root -> symbol rr, Together/Cancel, PolynomialReduce modulo rr^2-(Q2+u1)^2
   (this is what cancels the removable singularity), and ONLY THEN rr -> sgn.
   Substituting the value first leaves 1/0 on the branch where
   (Q2+u1 -/+ root) vanishes.
   WHY IT MATTERS DOWNSTREAM: these are the very roots that produced
   Log[Piecewise[...]] and the phantom log(-u1) of 0z.351, where Coefficient
   silently could not see through the Piecewise.  Removing them now prevents
   that whole class of failure in R5/C2.
   sgn = +1, consistent with taking the "pos" endpoint entries; both branches
   were measured equivalent (0z.360). *)
resolveBranch[e_, sgn_] := Module[{x},
  x = e /. Power[pp_, Rational[1, 2]] :> rr /;
        Simplify[pp - (Q2 + u1)^2] === 0;
  If[FreeQ[x, rr], Return[e]];
  x = Cancel[Together[x]];
  x = PolynomialReduce[Numerator[x], {rr^2 - (Q2 + u1)^2}, {rr}][[2]]/
      Cancel[Denominator[x]];
  Cancel[Together[x /. rr -> sgn (Q2 + u1)]]];

Do[Module[{piece = p[[1]], tag = p[[2]], rec, R, orders},
   rec = SelectFirst[sfraw, #[[1]] === tag &];
   If[MissingQ[rec] || rec === Missing,
      Print["FATAL: no endpoint entry ", tag]; Quit[1]];
   orders = rec[[2]];
   R = dPi3[eps] Total[(eps^#[[1]] resolveBranch[#[[2]], 1]) & /@ orders];
   Print["  ", piece, ": ", Length[orders], " eps orders, R LeafCount ",
         LeafCount[R]];
   Print["     ComplexInfinity-free ",
         FreeQ[R, ComplexInfinity | Indeterminate | DirectedInfinity],
         "   frame gate stray ", Select[{x, z, PHT, xi}, ! FreeQ[R, #] &],
         " (must be {})"];
   Print["     residual Sqrt count ",
         Length[Cases[R, Power[_, Rational[1, 2]], Infinity]]];
   (* ** MATCH THE ENGINE'S OUTPUT FORMAT (STATE.md 0z.411). **
      Hqq_R4_mma_part2.wls writes an ASSOCIATION
          <| Residue -> <| Class[0,0] -> expr |>, Deep -> .., Odd -> .. |>
      (Deep/Odd are the negative-power sinks it reports).  A bare expression
      here is a STRUCTURAL mismatch that silently corrupted everything
      downstream: Hqq_C2in_from_r4out.wls takes List @@ R only when
      Head[R] === Plus, so an Association became "Rterms 1", and that
      propagated into R5_regular as the list-valued {0,0,0} poles.
      The SF has only the (0,0) class and no deep/odd sinks. *)
   Put[<|"Residue" -> <|Class[0, 0] -> R|>, "Deep" -> <||>, "Odd" -> <||>|>,
       FileNameJoin[{dir, "r4out_" <> piece <> ".m"}]];
   Print["     wrote r4out_", piece, ".m"]],
  {p, {{"MR2PPDFA", "PPpos"}, {"MR2gDFA", "gpos"}}}];
Print["HQQ_R4OUT_SF_DONE"];

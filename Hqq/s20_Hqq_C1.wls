#!/usr/bin/env wolframscript
(* Hqq step C1: the eps^-2 SOFT CANCELLATION between the real and the
   renormalized virtual, per photon projection.

   CRITERION (STATE.md 0z.228).  The two sides are assembled with different
   machinery -- the real with dPi3 and the ds23 endpoint, the virtual with
   dPi2 -- but their absolute normalisations need NOT be matched by hand.
   Writing C' for the constant relating the 2->2 tree interference to the
   reference LO hard function,
       jac0 H_LO = C' x average x loX|_{eps->0}      (coupling-free)
   the virtual sits on the SAME 2->2 phase space as LO and carries the SAME
   C', so C' cancels between the two sides and the criterion collapses to
       K_real/(ee^2 eq^2 gs^4)  +  2 (d2X / loX|_{eps->0})  =  0
   with  K_real = cm2/(jac0 H_LO)  from the real assembly and d2X the
   renormalized virtual's eps^-2 coefficient from V2.  The explicit 2 is
   because V1/V2 build tree^dagger x loop, NOT 2 Re.

   ONLY THE gg CHANNEL CARRIES AN eps^-2.  Hqq;qqbar and Hqq;q'qbar' have no
   soft-gluon region -- their singularity is the collinear g -> q qbar
   splitting, a SINGLE pole -- so they contribute nothing here and enter
   only at C2.

   Inputs (all rebuilt after bug A, STATE.md 0z.226-0z.227):
     mathematica/Hqq_gg_assemble_steps.mx     {cm2, cm1, lf}      g
     mathematica/Hqq_gg_assemble_PP_steps.mx  {cm2, cm1, r1, r2}  PP
     mathematica/Hqq_virtual_V2_steps.mx      {d2G, d2PP, loG, loPP, ...} *)

$HistoryLength = 0;
<< FeynCalc`

dir[f_] := FileNameJoin[{Directory[], "mathematica", f}];

Get[dir["Hqq_virtual_V2_steps.mx"]];
vd2G = d2G; vd2PP = d2PP; vloG = loG; vloPP = loPP;
Print["virtual loaded: d2G leaf ", LeafCount[vd2G],
      "  d2PP leaf ", LeafCount[vd2PP]];

(* endpoint kinematics of the delta sector, identical to the assemblies:
   A = Q2+s, S = s, T = Q2+s+t1;  K23 = S/2, P23 = (A-T)/2, pk1 = T/2. *)
kin2 = {
  Pair[Momentum[p, D], Momentum[k1, D]]  -> T/2,
  Pair[Momentum[k1, D], Momentum[p, D]]  -> T/2,
  Pair[Momentum[p, D], Momentum[k2, D]]  -> (A - T)/2,
  Pair[Momentum[k2, D], Momentum[p, D]]  -> (A - T)/2,
  Pair[Momentum[k1, D], Momentum[k2, D]] -> S/2,
  Pair[Momentum[k2, D], Momentum[k1, D]] -> S/2};
named[e_] := Simplify[(e //. kin2) /. SUNN -> Nc /. D -> 4 - 2 eps /.
                      eps -> 0];

loG0  = named[vloG];
loPP0 = named[vloPP];
Print["LO interference at the endpoint:"];
Print["  loG0  = ", InputForm[loG0]];
Print["  loPP0 = ", InputForm[loPP0]];

ratioV[d_, lo_, tag_] := Module[{r},
  r = Simplify[named[d]/lo];
  Print["VIRTUAL ", tag, "  2 x (eps^-2)/LO = ", InputForm[Simplify[2 r]]];
  Print["VIRTUAL ", tag, "  kinematics-free? ", FreeQ[r, A | S | T]];
  Print["VIRTUAL ", tag, "  imaginary part (should be 0): ",
        InputForm[Simplify[ComplexExpand[Im[2 r]]]]];
  2 r];

vG2  = ratioV[vd2G,  loG0,  "g "];
vPP2 = ratioV[vd2PP, loPP0, "PP"];

(* ---- real side ---- *)
jac0 = z A/(S T);
HLOg  = -16 (A^2 + (S - T)^2)/(3 S (A - T));
HLOpp = 8 T/3;

realK[file_, hlo_, tag_] := Module[{c, k},
  Get[dir[file]];
  c = cm2;
  k = Simplify[c/(jac0 hlo)];
  Print["REAL ", tag, "  K_real = cm2/(jac0 H_LO) = ", InputForm[k]];
  Print["REAL ", tag, "  kinematics-free? ", FreeQ[k, A | S | T]];
  Simplify[k/(ee^2 eq^2 gs^4)]];

kG  = realK["Hqq_gg_assemble_steps.mx",    HLOg,  "g "];
kPP = realK["Hqq_gg_assemble_PP_steps.mx", HLOpp, "PP"];

Print["=== C1: eps^-2 SOFT CANCELLATION (each must be 0) ==="];
Print["  g  : K_real + 2 d2/LO = ", InputForm[Simplify[kG  + vG2]]];
Print["  PP : K_real + 2 d2/LO = ", InputForm[Simplify[kPP + vPP2]]];
Print["  (for diagnosis) real g  = ", InputForm[kG],
      "   virtual g  = ", InputForm[vG2]];
Print["  (for diagnosis) real PP = ", InputForm[kPP],
      "   virtual PP = ", InputForm[vPP2]];

DumpSave[dir["Hqq_C1_steps.mx"], {kG, kPP, vG2, vPP2, loG0, loPP0}];
Print["HQQ_C1_DONE"];

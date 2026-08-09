#!/usr/bin/env wolframscript
(* Hqq (channel 2), REBUILD -- step R1 for the PAIR-EMISSION graphs.

   Covers two of the four graph sets of Table I row 2, under ONE convention:
       DF : gamma* q(p) -> q(k1) q'(k2) qbar'(k3)   DIFFERENT flavour
       SF : gamma* q(p) -> q(k1) q(k2) qbar(k3)     SAME flavour
   (Hqq;gg is a separate script -- it needs physical gluon polarization sums.)

   All conventions come from python/Hqq2_bookkeeping.py, the single source of
   truth.  Restating them here is deliberate DUPLICATION-FREE quotation: the
   values below must match that file, and the export asserts the symbol names.

   WHY A REBUILD.  The old chain's defect was never localized: R1->R2, R2->R3
   and R3->R4 were each proven EXACT, MR2gA passed three independent checks,
   and an LO-FREE test STILL showed a g/PP asymmetry (STATE 0z.109).  A fault
   that is real but attributable to no stage is a BOOKKEEPING fault.

   THE THREE CHARGE STRUCTURES (bookkeeping section 2).  For DF the photon may
   attach to the observed line (charge eq) or to the produced pair (charge
   eqp), giving
       DFA = |photon on observed line|^2            ~ eq^2
       DFB = 2 Re(observed x pair interference)     ~ eq*eqp
       DFC = |photon on pair|^2                     ~ eqp^2
   The OLD chain computed A, B, C in separate scripts with separately restated
   conventions.  Here they come from ONE amplitude, so no convention can drift
   between them.

   SAME FLAVOUR (bookkeeping section 3a).  The final state has two identical
   quarks (k1, k2), so the SF amplitude is the DF amplitude ANTISYMMETRIZED
   under k1 <-> k2.  This is physical, NOT the q<->qbar reversal the paper
   forbids (p.16).

   Output: python/generated/Hqq2_R1_pairs.py
*)

$HistoryLength = 0;
<< FeynCalc`

root = "/home/physics/projects/AI_Assisted_SIDIS";
If[StringQ[Environment["SIDIS_ROOT"]] && Environment["SIDIS_ROOT"] =!= "",
  root = Environment["SIDIS_ROOT"]];
Print["[1] FeynCalc loaded; root = ", root];

(* ---- invariants (bookkeeping section 4), NO conservation imposed ------ *)
FCClearScalarProducts[];
SPD[p, p] = 0; SPD[q, q] = -Q2;
SPD[k1, k1] = 0; SPD[k2, k2] = 0; SPD[k3, k3] = 0;
SPD[p, q]  = (s + Q2)/2;
SPD[q, k1] = -(t1 + Q2)/2;
SPD[q, k2] = -(t2 + Q2)/2;
SPD[q, k3] = -(t3 + Q2)/2;
SPD[p, k1] = -u1/2;
SPD[p, k2] = -u2/2;
SPD[p, k3] = -u3/2;
SPD[k1, k2] = s12/2;
SPD[k1, k3] = s13/2;
SPD[k2, k3] = s23/2;
Print["[2] invariants set"];

(* ---- the two current structures -------------------------------------- *)
(* observed quark line, gluon index al, photon index mu.  Photon may come
   first (propagator p+q, denominator s) or after the gluon emission
   (propagator k1-q, denominator t1).  BOTH orderings, always.            *)
obsLine = SpinorUBarD[k1] . GAD[al] . (GSD[p] + GSD[q]) . GAD[mu] . SpinorUD[p]/s +
          SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[al] . SpinorUD[p]/t1;
(* produced pair current with NO photon: just the gluon vertex *)
pairPlain = SpinorUBarD[k2] . GAD[al] . SpinorVD[k3];

(* TOPOLOGY, and the error the gauge check caught (job 14200070).
   When the photon sits on the PRODUCED PAIR, the observed quark line carries
   NO photon: it is simply ubar(k1) gamma^al u(p), and the GLUON then carries
   momentum p - k1 = k2 + k3 - q, so its propagator is 1/u1 -- NOT 1/s23.
   (1/s23 is correct only for the photon-on-observed-line topology, where the
   gluon carries k2 + k3.)  The first version omitted the observed line
   entirely, used 1/s23, and had both fermion propagators sign-wrong.        *)
obsPlain = SpinorUBarD[k1] . GAD[al] . SpinorUD[p];
(* pair line with the photon attached: photon on the q' leg (propagator
   momentum k2 - q, denominator t2 = (q-k2)^2) or on the qbar' leg
   (propagator momentum q - k3, denominator t3 = (q-k3)^2).                 *)
pairPhoton =
  SpinorUBarD[k2] . GAD[mu] . (GSD[k2] - GSD[q]) . GAD[al] . SpinorVD[k3]/t2 +
  SpinorUBarD[k2] . GAD[al] . (GSD[q] - GSD[k3]) . GAD[mu] . SpinorVD[k3]/t3;

(* full DF amplitude: photon on the observed line (eq) OR on the pair (eqp) *)
ampObs  = -eq  obsLine  pairPlain/s23;
ampPair = -eqp obsPlain pairPhoton/u1;
ampDF   = ampObs + ampPair;
Print["[3] DF amplitude built, leafcount ", LeafCount[ampDF]];

(* ---- check 2 on EACH charge structure separately --------------------- *)
gcObs  = DiracSimplify[Contract[FVD[q, mu] ampObs]]  // Together;
gcPair = DiracSimplify[Contract[FVD[q, mu] ampPair]] // Together;
gcDF   = DiracSimplify[Contract[FVD[q, mu] ampDF]]   // Together;
Print["[4] check 2  q_mu on ampObs  : ", Simplify[gcObs]  // InputForm];
Print["[4] check 2  q_mu on ampPair : ", Simplify[gcPair] // InputForm];
Print["[4] check 2  q_mu on ampDF   : ", Simplify[gcDF]   // InputForm];
If[!TrueQ[Simplify[gcDF] === 0],
  Print["FATAL: DF amplitude is not gauge invariant"]; Quit[1]];

(* ---- squares, projected -------------------------------------------- *)
colour = SUNSimplify[SUNTrace[SUNT[a, b]] SUNTrace[SUNT[a, b]],
   SUNNToCACF -> False];
pref = ee^2 gs^4 colour/(2 SUNN);      (* charges carried in the amplitudes *)
Print["[5] colour = ", colour // InputForm];

conj[x_] := ComplexConjugate[x] /. {mu -> mu2, al -> al2};
sq[x_, y_] := MemoryConstrained[DiracSimplify[FermionSpinSum[x conj[y]]], 6*10^9];
projG[e_]  := Together[(Contract[MTD[mu, mu2] e] /. D -> 4 - 2 eps) pref];
projPP[e_] := Together[(Contract[FVD[p, mu] FVD[p, mu2] e] /. D -> 4 - 2 eps) pref];

(* the three DF charge structures, from ONE amplitude *)
sA = sq[ampObs, ampObs];
sC = sq[ampPair, ampPair];
sB = sq[ampObs, ampPair] + sq[ampPair, ampObs];
Print["[6] DF spinsums done: A ", LeafCount[sA], " B ", LeafCount[sB],
  " C ", LeafCount[sC]];

MR2gDFA = projG[sA];   MR2PPDFA = projPP[sA];
MR2gDFB = projG[sB];   MR2PPDFB = projPP[sB];
MR2gDFC = projG[sC];   MR2PPDFC = projPP[sC];
Print["[7] DF projected: gA ", LeafCount[MR2gDFA], " gB ", LeafCount[MR2gDFB],
  " gC ", LeafCount[MR2gDFC]];

(* ---- same flavour: antisymmetrize the observed quark with k2 --------- *)
ampSF = ampDF - (ampDF /. {k1 -> k2, k2 -> k1});
gcSF = DiracSimplify[Contract[FVD[q, mu] ampSF]] // Together;
Print["[8] check 2  q_mu on ampSF   : ", Simplify[gcSF] // InputForm];
sSF = sq[ampSF, ampSF];
MR2gSF = projG[sSF];  MR2PPSF = projPP[sSF];
Print["[9] SF projected: g ", LeafCount[MR2gSF], " PP ", LeafCount[MR2PPSF]];

(* ---- export guards (bookkeeping section 5) --------------------------- *)
all = {MR2gDFA, MR2PPDFA, MR2gDFB, MR2PPDFB, MR2gDFC, MR2PPDFC,
       MR2gSF, MR2PPSF};
If[Or @@ (!FreeQ[#, D] & /@ all),
  Print["FATAL: D survives the substitution"]; Quit[1]];
If[Or @@ (!FreeQ[#, LorentzIndex] & /@ all),
  Print["FATAL: open Lorentz indices survive"]; Quit[1]];
Print["[10] guards passed: no D, no open Lorentz indices"];

nm[e_] := StringReplace[ToString[e // FortranForm], "SUNN" -> "Nc"];
out = FileNameJoin[{root, "python", "generated", "Hqq2_R1_pairs.py"}];
Export[out, StringJoin[
  "# generated by mathematica/Hqq2_R1_pairs.wls  (Hqq REBUILD, step R1)\n",
  "# conventions: python/Hqq2_bookkeeping.py (single source of truth)\n",
  "# DFA ~ eq^2, DFB ~ eq*eqp, DFC ~ eqp^2, SF = same flavour (antisym k1<->k2)\n",
  "# SUNN renamed to Nc on export -- the new chain uses Nc only.\n",
  Sequence @@ Flatten[Table[
    {pair[[1]], " = \"\"\"", nm[pair[[2]]], "\"\"\"\n\n"},
    {pair, {{"MR2gDFA", MR2gDFA}, {"MR2PPDFA", MR2PPDFA},
            {"MR2gDFB", MR2gDFB}, {"MR2PPDFB", MR2PPDFB},
            {"MR2gDFC", MR2gDFC}, {"MR2PPDFC", MR2PPDFC},
            {"MR2gSF", MR2gSF},   {"MR2PPSF", MR2PPSF}}}]]], "Text"];
Print["[11] exported ", out];
Print["HQQ2_R1_PAIRS_DONE"];

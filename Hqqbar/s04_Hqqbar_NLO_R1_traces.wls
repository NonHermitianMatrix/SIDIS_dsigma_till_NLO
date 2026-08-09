#!/usr/bin/env wolframscript
(* Hqqbar (channel 5) -- step R1: 2->3 traces, ANTIQUARK observed.

   Table I row:  N/A (virtual)  |  real  H_{qbar q; q q}  ->  H_{qbar q}
   sidis.py comment (line 167):  5   R: A q -> (qb->h)  q  qb
   i.e.  gamma*(q) + q(p)  ->  qbar(k1, OBSERVED) + q(k2) + q(k3),
   SAME flavour, so the two final-state QUARKS k2, k3 are IDENTICAL and the
   amplitude must be ANTISYMMETRIC under k2 <-> k3 (Fermi statistics).

   This is the only channel of Table I that has never been computed
   (STATE 0z.94 B).  BigTMD ships fchn5A/B/C.py and a chn==5 luminosity branch
   but EXCLUDES channel 5 from its cross section (`for chn in [1,2,3,4,6]`,
   sidis.py line 191), so there is no reference number to lean on -- which is
   exactly why the amplitude is written here directly from the Feynman rules
   and gauge-checked before use (check 2), per the operating rules.

   STRUCTURE.  Each "chain" is the piece-A structure with a different quark
   paired to the observed antiquark:
       chainA : gluon -> (k1 qbar, k2 q) pair, beam line ends on ubar(k3)
       chainB : gluon -> (k1 qbar, k3 q) pair, beam line ends on ubar(k2)
   and  amp = chainA - chainB.
   Each beam line carries BOTH photon orderings exactly as in the verified
   piece-A script (photon first, propagator 1/s; gluon first, propagator
   1/t_i), so no ordering is dropped.

   Conventions are copied from verified/Hqqp/Hqq_NLO_R1_qqpqbarp_traces.wls:
   same invariants, same +MTD[mu,mu2] photon projection, same
   FVD[p,mu]FVD[p,mu2] projection, same D -> 4-2 eps before export.

   Output: python/generated/Hqqbar_R1.py  (MR2gQQB, MR2PPQQB)
*)

$HistoryLength = 0;
<< FeynCalc`

root = "/home/physics/projects/AI_Assisted_SIDIS";
If[StringQ[Environment["SIDIS_ROOT"]] && Environment["SIDIS_ROOT"] =!= "",
  root = Environment["SIDIS_ROOT"]];
Print["[1] FeynCalc loaded; root = ", root];

(* ---------- 2->3 invariants: all scalar products, NO conservation imposed *)
FCClearScalarProducts[];
SPD[p, p] = 0; SPD[q, q] = -Q2;
SPD[k1, k1] = 0; SPD[k2, k2] = 0; SPD[k3, k3] = 0;
SPD[p, q]  = (s + Q2)/2;          (* s   = (p+q)^2   = 2 p.q - Q2  *)
SPD[q, k1] = -(t1 + Q2)/2;        (* ti  = (q-ki)^2  = -Q2 - 2 q.ki *)
SPD[q, k2] = -(t2 + Q2)/2;
SPD[q, k3] = -(t3 + Q2)/2;
SPD[p, k1] = -u1/2;               (* ui  = (p-ki)^2  = -2 p.ki      *)
SPD[p, k2] = -u2/2;
SPD[p, k3] = -u3/2;
SPD[k1, k2] = s12/2;              (* sij = (ki+kj)^2 = 2 ki.kj      *)
SPD[k1, k3] = s13/2;
SPD[k2, k3] = s23/2;
Print["[2] scalar products set"];

(* ---------- the two chains -------------------------------------------- *)
(* beam line ending on ubar[kout], pair (k1 qbar, kq q) off the gluon.
   Photon first: quark propagator (p+q), denominator s.
   Gluon first : quark propagator (kout - q), denominator (t of kout).      *)
beam[kout_, tout_] :=
  SpinorUBarD[kout] . GAD[al] . (GSD[p] + GSD[q]) . GAD[mu] . SpinorUD[p]/s +
  SpinorUBarD[kout] . GAD[mu] . (GSD[kout] - GSD[q]) . GAD[al] . SpinorUD[p]/tout;

(* pair current: gluon -> qbar(k1) q(kq), propagator 1/s_{1,kq} *)
pair[kq_, sinv_] := SpinorUBarD[kq] . GAD[al] . SpinorVD[k1]/sinv;

chainA = beam[k3, t3] pair[k2, s12];
chainB = beam[k2, t2] pair[k3, s13];
amp = -(chainA - chainB);      (* relative MINUS: identical quarks k2, k3 *)
Print["[3] amplitude built, leafcount ", LeafCount[amp]];

(* ---------- check 2: gauge invariance, MUST be 0 ---------------------- *)
gc = DiracSimplify[Contract[FVD[q, mu] amp]] // Together;
Print["[4] check 2 (q_mu M^mu, must be 0): ", gc // InputForm];
If[!TrueQ[Simplify[gc] === 0],
  Print["FATAL: gauge check failed -- amplitude transcription is wrong"];
  Quit[1]];

(* ---------- square, spin sums, projections ---------------------------- *)
ampC = ComplexConjugate[amp] /. {mu -> mu2, al -> al2};
spinsum = MemoryConstrained[DiracSimplify[FermionSpinSum[amp ampC]], 6*10^9];
Print["[5] spin sums + traces done, leafcount ", LeafCount[spinsum]];
If[!FreeQ[spinsum, SpinorUBarD] || !FreeQ[spinsum, SpinorUD],
  Print["FATAL: spinors survive the spin sum"]; Quit[1]];

colour = SUNSimplify[SUNTrace[SUNT[a, b]] SUNTrace[SUNT[a, b]],
   SUNNToCACF -> False];
Print["[6] colour factor = ", colour // InputForm];
pref = eq^2 ee^2 gs^4 colour/(2 SUNN);   (* avg: 1/2 spin, 1/SUNN colour *)

MR2gQQB = MemoryConstrained[Together[
   (Contract[MTD[mu, mu2] spinsum] /. D -> 4 - 2 eps) pref], 6*10^9];
MR2PPQQB = MemoryConstrained[Together[
   (Contract[FVD[p, mu] FVD[p, mu2] spinsum] /. D -> 4 - 2 eps) pref], 6*10^9];
Print["[7] MR2gQQB leafcount ", LeafCount[MR2gQQB],
  ", MR2PPQQB leafcount ", LeafCount[MR2PPQQB]];
If[!FreeQ[MR2gQQB, D] || !FreeQ[MR2PPQQB, D],
  Print["FATAL: D survives -- the D -> 4-2 eps substitution was dropped"];
  Quit[1]];
If[!FreeQ[MR2gQQB, LorentzIndex] || !FreeQ[MR2PPQQB, LorentzIndex],
  Print["FATAL: open Lorentz indices survive the contraction"]; Quit[1]];

(* ---------- export to sympy ------------------------------------------- *)
out = FileNameJoin[{root, "python", "generated", "Hqqbar_R1.py"}];
Export[out, StringJoin[
  "# generated by mathematica/Hqqbar_NLO_R1_traces.wls\n",
  "# Hqqbar (channel 5): gamma* q -> qbar(k1, observed) q(k2) q(k3),\n",
  "# same flavour, amplitude antisymmetrized in the identical quarks k2,k3.\n",
  "MR2gQQB = \"\"\"", ToString[MR2gQQB // FortranForm], "\"\"\"\n\n",
  "MR2PPQQB = \"\"\"", ToString[MR2PPQQB // FortranForm], "\"\"\"\n"], "Text"];
Print["[8] exported ", out];
Print["HQQBAR_R1_DONE"];

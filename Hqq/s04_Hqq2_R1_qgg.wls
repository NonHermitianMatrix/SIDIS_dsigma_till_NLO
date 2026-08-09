#!/usr/bin/env wolframscript
(* Hqq (channel 2), REBUILD -- step R1, the Hqq;gg graphs.

       gamma*(q,mu) + q(p) -> q(k1) + g(k2,al,a) + g(k3,be,b)

   EIGHT diagrams: 6 abelian (photon and the two gluons in every order along
   the quark line, 3! = 6) + 2 with the TRIPLE-GLUON vertex.

   This is NEW rebuild code.  It consumes NO old artifact: the superseded
   chain (python/cache/OLD_Hqq_20260731_SUPERSEDED/) is not read, and the old
   export python/generated/Hqq_R1_qgg.py is NOT reused.  Output is the
   rebuild's own python/generated/Hqq2_R1_qgg.py, alongside
   Hqq2_R1_pairs.py and Hqq2_R1_sameflavor.py.

   ========================================================================
   WHY ATTEMPTS 1-6 FAILED (jobs 14200085/87/91/95/114, 14200380)
   ========================================================================
   Every one of them tried to fix the abelian/triple relative normalization
   `kap` by imposing the PHOTON transversality q_mu M^mu = 0 and solving.
   THAT CHECK IS STRUCTURALLY INCAPABLE OF DETERMINING kap, because the two
   diagram sets are SEPARATELY photon-transverse:

     * ABELIAN.  For each fixed gluon ordering the three photon insertions
       telescope (q-slash = p_out-slash - p_in-slash at each insertion) and
       sum to zero.  Two gluon orderings -> both vanish separately.

     * TRIPLE-GLUON.  The photon sits in two places on the quark line of
       gamma* q -> q g*, and with p-slash u(p) = 0 and ubar(k1) k1-slash = 0,
           q_mu [ ubar.gam^be.(p+q)-slash.gam^mu.u / s
                + ubar.gam^mu.(k1-q)-slash.gam^be.u / t1 ]
         = ubar.gam^be.u (p+q)^2/s - ubar.(k1-q)^2.gam^be.u/t1
         = ubar.gam^be.u - ubar.gam^be.u = 0 ,
       since (p+q)^2 = s and (k1-q)^2 = t1.  The tgv tensor is an overall
       factor, so it cannot spoil this.

   Hence q_mu M^mu(kap) = 0 IDENTICALLY IN kap on a correct amplitude, and
   `Solve[gcRaw == 0, kap]` can only ever return "no constraint" -- or, when
   the abelian chains carry a bug, "NO SOLUTION", which is precisely what
   jobs 14200091 and 14200095 reported.  The check was reading out a chain
   bug while being incapable of its stated job.  The photon check is kept
   below as a NECESSARY condition, never as the determinant of kap.

   THE RELATIVE NORMALIZATION IS FIXED BY THE GLUON WARD IDENTITIES.
   Contract k2^al (resp. k3^be) into the squared amplitude while keeping a
   PHYSICAL polarization sum on the other gluon.  A gauge-invariant qgg
   amplitude gives exactly zero; a wrong relative phase does not.  The
   quark-line colour commutator is proportional to I f^{abc} T^c, so the two
   triple-gluon graphs must be scanned over relative PHASES {+-I, +-I}, not
   real signs.  Exactly one pair may survive, and it must survive in BOTH
   photon projections (a vanishing g-projected contraction alone could in
   principle be a nonzero null tensor -- hence the independent PP guard).

   THREE FURTHER BUGS IN THE SUPERSEDED ATTEMPT, corrected here:
     (i)   pref was  eq^2 ee^2/(2 SUNN)  -- MISSING gs^4 entirely, i.e. the
           QCD coupling was absent from a two-gluon-emission amplitude.
     (ii)  pref was missing the 1/2! IDENTICAL-GLUON phase-space factor.
           (STATE 0z.122 predicted this from channel 5 and recorded that
           "grep finds none anywhere"; that grep covered the rebuild files
           only.  The factor is required here for the same reason it was
           required for channel 5: the unobserved pair g(k2) g(k3) is two
           IDENTICAL bosons.)
     (iii) k3 was eliminated as a VECTOR (k3 -> p+q-k1-k2) on the theory that
           the Ward identity could not otherwise telescope.  That was not the
           bug (see above), and it forces every invariant through a single
           over-constrained route.  Here k3 is kept INDEPENDENT with its own
           scalar products, and the dependent invariants are eliminated only
           inside the Ward CHECKS, via the reference relations.
     Also retired: the claim that `FVD[2 k2 + k3, be]` is malformed because
     FVD "does not distribute over a momentum sum".  FeynCalc accepts a
     momentum sum in FVD; that diagnosis (attempt 4) was a red herring.

   TWO RULES THAT ARE NOT OPTIONAL (reference section 6):

   (1) PHYSICAL GLUON POLARIZATION SUMS.  With a triple-gluon vertex present
       a bare -g^{mu nu} sum is WRONG without ghosts.  Use, per gluon, the
       physical tensor with the OTHER gluon as reference vector:
           polS[m,n,k,r] = -g^{mn} + (k^m r^n + r^m k^n)/(k.r)
       FeynCalc's DoPolarizationSums cannot be used: it needs explicit
       Polarization[k] vectors, while a rules-typed amplitude carries OPEN
       indices (GAD[al]), so it errors `noauto` (MEASURED).

   (2) ACCUMULATE PAIRWISE, NEVER GLOBAL Together.  Tracing the whole
       8x8 = 64 pair product at once and then calling Together builds one
       giant common denominator and blows the result to millions of leaves
       with unclosed indices.  Per pair: FermionSpinSum -> Contract ->
       DiracSimplify -> FCCanonicalizeDummyIndices -> SUNSimplify ->
       Together THIS PAIR ONLY, then sum with Plus and STOP.

   Output: python/generated/Hqq2_R1_qgg.py   (MR2gQGG, MR2PPQGG)
*)

$HistoryLength = 0;
<< FeynCalc`

root = "/home/physics/projects/AI_Assisted_SIDIS";
If[StringQ[Environment["SIDIS_ROOT"]] && Environment["SIDIS_ROOT"] =!= "",
  root = Environment["SIDIS_ROOT"]];
t0 = AbsoluteTime[];
tick[m_] := Print["    [t+", Round[AbsoluteTime[] - t0], " s] ", m];
Print["[1] FeynCalc loaded; root = ", root];

(* ---- kinematics: ALL FIVE momenta independent, per reference section 0 --
   s   = (p+q)^2 = 2 p.q - Q2       ti = (q-ki)^2 = -Q2 - 2 q.ki
   ui  = (p-ki)^2 = -2 p.ki         sij = (ki+kj)^2 = 2 ki.kj             *)
FCClearScalarProducts[];
SPD[p, p] = 0; SPD[q, q] = -Q2;
SPD[k1, k1] = 0; SPD[k2, k2] = 0; SPD[k3, k3] = 0;
SPD[p, q] = (s + Q2)/2;
SPD[q, k1] = -(t1 + Q2)/2; SPD[q, k2] = -(t2 + Q2)/2; SPD[q, k3] = -(t3 + Q2)/2;
SPD[p, k1] = -u1/2; SPD[p, k2] = -u2/2; SPD[p, k3] = -u3/2;
SPD[k1, k2] = s12/2; SPD[k1, k3] = s13/2; SPD[k2, k3] = s23/2;
Print["[2] scalar products set for independent {p,q,k1,k2,k3}"];

(* The eleven invariants are OVER-COMPLETE.  The dependent ones are removed
   in the WARD CHECKS ONLY, using the relations of reference section 6:
       2ARs : t1 = u2 + u3 + s23 ,  u1 = t2 + t3 + s23 + Q2 ,
              s  = s12 + s13 + s23
       3AR  : s13 = s + t2 + u2 + Q2
   together with s + t1 + u1 + Q2 - s23 = 0 (check 4, reference section 9). *)
arSub = {u1 -> s23 - s - t1 - Q2,
         t3  -> (s23 - s - t1 - Q2) - t2 - s23 - Q2,
         u3  -> t1 - u2 - s23,
         s13 -> s + t2 + u2 + Q2,
         s12 -> s - s23 - (s + t2 + u2 + Q2)};
chk4 = Simplify[(s + t1 + u1 + Q2 - s23) /. arSub];
Print["[2a] check 4, s+t1+u1+Q2-s23 under the ARs (must be 0): ",
  chk4 // InputForm];
If[!TrueQ[chk4 === 0],
  Print["FATAL: the AR substitution is not consistent"]; Quit[1]];

(* ---- the eight diagrams ------------------------------------------------
   Quark line read against the fermion flow, ubar(k1) ... u(p).  The
   propagator momentum between two insertions is the momentum flowing along
   the fermion direction: p+q after absorbing the photon, p-k2 after
   emitting g(k2), and so on.  Denominators are the corresponding squares:
       (p+q)^2 = s ,  (p+q-k2)^2 = s13 ,  (p+q-k3)^2 = s12 ,
       (p-k2)^2 = u2 , (p-k3)^2 = u3 ,    (k1-q)^2 = t1 ,  (k2+k3)^2 = s23 .
   Colour: the gluon emitted FIRST along the line sits RIGHTMOST in the
   SUNTF product, matching the gamma ordering.                             *)
d[1][V_] := SpinorUBarD[k1] . GAD[be] . (GSD[p] + GSD[q] - GSD[k2]) . GAD[al] .
   (GSD[p] + GSD[q]) . V . SpinorUD[p]/(s s13) SUNTF[{b, a}, ci, cj];
d[2][V_] := SpinorUBarD[k1] . GAD[al] . (GSD[p] + GSD[q] - GSD[k3]) . GAD[be] .
   (GSD[p] + GSD[q]) . V . SpinorUD[p]/(s s12) SUNTF[{a, b}, ci, cj];
d[3][V_] := SpinorUBarD[k1] . GAD[be] . (GSD[p] - GSD[k2] + GSD[q]) . V .
   (GSD[p] - GSD[k2]) . GAD[al] . SpinorUD[p]/(u2 s13) SUNTF[{b, a}, ci, cj];
d[4][V_] := SpinorUBarD[k1] . GAD[al] . (GSD[p] - GSD[k3] + GSD[q]) . V .
   (GSD[p] - GSD[k3]) . GAD[be] . SpinorUD[p]/(u3 s12) SUNTF[{a, b}, ci, cj];
d[5][V_] := SpinorUBarD[k1] . V . (GSD[k1] - GSD[q]) . GAD[be] .
   (GSD[p] - GSD[k2]) . GAD[al] . SpinorUD[p]/(u2 t1) SUNTF[{b, a}, ci, cj];
d[6][V_] := SpinorUBarD[k1] . V . (GSD[k1] - GSD[q]) . GAD[al] .
   (GSD[p] - GSD[k3]) . GAD[be] . SpinorUD[p]/(u3 t1) SUNTF[{a, b}, ci, cj];

(* TRIPLE-GLUON VERTEX, all-incoming convention.  For (a,mu,p1), (b,nu,p2),
   (c,rho,p3) with p1+p2+p3 = 0,
     V = f^{abc}[ g^{mu nu}(p1-p2)^rho + g^{nu rho}(p2-p3)^mu
                + g^{rho mu}(p3-p1)^nu ].
   The internal gluon enters with K = k2+k3 (index si, colour cc); the two
   external gluons are OUTGOING, hence incoming -k2 and -k3:
       p1 = K (si,cc) , p2 = -k2 (al,a) , p3 = -k3 (be,b)
   so   p1-p2 = 2k2+k3 ,  p2-p3 = k3-k2 ,  p3-p1 = -(k2+2k3).             *)
v3 = SUNF[cc, a, b] (MTD[si, al] FVD[2 k2 + k3, be] +
     MTD[al, be] FVD[k3 - k2, si] - MTD[be, si] FVD[k2 + 2 k3, al]);
d[7][V_] := (SpinorUBarD[k1] . GAD[si] . (GSD[p] + GSD[q]) . V . SpinorUD[p]/
     (s s23)) v3 SUNTF[{cc}, ci, cj];
d[8][V_] := (SpinorUBarD[k1] . V . (GSD[k1] - GSD[q]) . GAD[si] . SpinorUD[p]/
     (t1 s23)) v3 SUNTF[{cc}, ci, cj];
Print["[3] 8 diagrams defined (6 abelian + 2 triple-gluon)"];

signChoices = {{I, I}, {I, -I}, {-I, I}, {-I, -I}};
ampWeight[i_, signs_] := If[i <= 6, 1, signs[[i - 6]]];

polS[m_, n_, k_, r_] := -MTD[m, n] +
   (FVD[k, m] FVD[r, n] + FVD[r, m] FVD[k, n])/SPD[k, r];

(* pairwise accumulation for a given photon contraction Pgam(mu,mu2) *)
build[Pgam_, signs_] := Module[{tot = 0, r, i, j},
  Do[
    r = FermionSpinSum[d[i][GAD[mu]] ComplexConjugate[d[j][GAD[mu2]] /.
        {al -> al2, be -> be2, si -> si2, cc -> cc2}]];
    r = Contract[r Pgam polS[al, al2, k2, k3] polS[be, be2, k3, k2]];
    r = DiracSimplify[r];
    r = FCCanonicalizeDummyIndices[r];
    r = SUNSimplify[r, SUNNToCACF -> False];
    tot = tot + ampWeight[i, signs] Conjugate[ampWeight[j, signs]] Together[r],
    {i, 8}, {j, 8}];
  tot];

(* THE DISCRIMINATOR.  Replace one gluon's polarization tensor by k^m k^n and
   keep a physical sum on the other; a gauge-invariant amplitude vanishes.
   Each expensive trace is evaluated ONCE and accumulated for all four phase
   choices, so the scan costs one pass, not four.                          *)
buildGluonWardScan[Pgam_, wardK_, wardI_, wardI2_, polK_, polI_, polI2_] :=
 Module[{tots = ConstantArray[0, Length[signChoices]], r, i, j, h},
  Do[
    r = FermionSpinSum[d[i][GAD[mu]] ComplexConjugate[d[j][GAD[mu2]] /.
        {al -> al2, be -> be2, si -> si2, cc -> cc2}]];
    r = Contract[r Pgam FVD[wardK, wardI] FVD[wardK, wardI2]
        polS[polI, polI2, polK, wardK]];
    r = DiracSimplify[r];
    r = FCCanonicalizeDummyIndices[r];
    r = SUNSimplify[r, SUNNToCACF -> False];
    r = Together[r];
    Do[tots[[h]] = tots[[h]] + ampWeight[i, signChoices[[h]]]
        Conjugate[ampWeight[j, signChoices[[h]]]] r, {h, Length[signChoices]}],
    {i, 8}, {j, 8}];
  tots];

scanK2 = Simplify[# /. arSub] & /@
  buildGluonWardScan[MTD[mu, mu2], k2, al, al2, k3, be, be2];
Print["[4a] k2 Ward scan {eta7,eta8}: ",
  MapThread[{#1, If[#2 === 0, "ZERO", "NONZERO"], LeafCount[#2]} &,
    {signChoices, scanK2}]];
tick["k2 Ward scan done"];

scanK3 = Simplify[# /. arSub] & /@
  buildGluonWardScan[MTD[mu, mu2], k3, be, be2, k2, al, al2];
Print["[4b] k3 Ward scan {eta7,eta8}: ",
  MapThread[{#1, If[#2 === 0, "ZERO", "NONZERO"], LeafCount[#2]} &,
    {signChoices, scanK3}]];
tick["k3 Ward scan done"];

passingSigns = Pick[signChoices,
  MapThread[(#1 === 0 && #2 === 0) &, {scanK2, scanK3}]];
If[Length[passingSigns] =!= 1,
  Print["FATAL: expected exactly one phase pair passing both gluon Ward "
        <> "identities; got ", passingSigns // InputForm,
        ".  Zero passing = the diagrams or vertex momenta are wrong; more "
        <> "than one = the scan is degenerate and cannot fix the phase."];
  Quit[1]];
chosenSigns = First[passingSigns];
Print["[4c] selected triple-gluon phases {eta7,eta8} = ", chosenSigns];

(* INDEPENDENT PP GUARD.  A vanishing g-projected Ward contraction could in
   principle be a nonzero null tensor, so repeat both contractions with
   p^mu p^mu2 and require the ALREADY-SELECTED phase to vanish there too. *)
scanK2PP = Simplify[# /. arSub] & /@
  buildGluonWardScan[FVD[p, mu] FVD[p, mu2], k2, al, al2, k3, be, be2];
scanK3PP = Simplify[# /. arSub] & /@
  buildGluonWardScan[FVD[p, mu] FVD[p, mu2], k3, be, be2, k2, al, al2];
ipos = First@FirstPosition[signChoices, chosenSigns];
Print["[4d] PP guard at the selected phase: k2 -> ",
  If[scanK2PP[[ipos]] === 0, "ZERO", "NONZERO"], ", k3 -> ",
  If[scanK3PP[[ipos]] === 0, "ZERO", "NONZERO"]];
If[scanK2PP[[ipos]] =!= 0 || scanK3PP[[ipos]] =!= 0,
  Print["FATAL: the phase selected in the g projection fails the "
        <> "independent PP Ward guard"]; Quit[1]];
tick["PP Ward guard done"];

(* CHECK 2, the PHOTON gauge check.  NECESSARY, NOT SUFFICIENT: as explained
   in the header it is satisfied by the abelian and triple-gluon sets
   SEPARATELY and therefore says nothing about their relative phase, which
   [4a]-[4d] have already fixed.  It is run because it still catches a bad
   propagator momentum or gamma ordering inside either set.                *)
gc = Simplify[build[FVD[q, mu] FVD[q, mu2], chosenSigns] /. arSub];
Print["[5] check 2 (q_mu q_mu2, must be 0): ", gc // InputForm];
If[gc =!= 0, Print["FATAL: photon gauge check nonzero"]; Quit[1]];
tick["photon gauge check done"];

M2gAcc  = build[MTD[mu, mu2], chosenSigns];
Print["[6] M2g accumulated, leafcount ", LeafCount[M2gAcc]];
tick["M2g done"];
M2PPAcc = build[FVD[p, mu] FVD[p, mu2], chosenSigns];
Print["[7] M2PP accumulated, leafcount ", LeafCount[M2PPAcc]];
tick["M2PP done"];

If[!FreeQ[{M2gAcc, M2PPAcc}, LorentzIndex],
  Print["FATAL: open Lorentz indices survive -- a contraction was missed"];
  Quit[1]];
If[!FreeQ[{M2gAcc, M2PPAcc}, polS],
  Print["FATAL: polS survives unevaluated"]; Quit[1]];
Print["[8] structural guard passed (indices closed, polS evaluated)"];

(* PREFACTOR.  eq^2 ee^2 gs^4 = the couplings (one photon vertex squared,
   two QCD vertices squared).  1/2 = initial quark SPIN average.
   1/SUNN = initial quark COLOUR average.  The FINAL 1/2 is the
   IDENTICAL-GLUON phase-space factor 1/2!: the unobserved pair g(k2) g(k3)
   is two identical bosons, exactly the situation that required the same
   factor in channel 5 (STATE 0z.121/0z.122, where it was PROVED by
   Res_reg + 2 Res_ff = 0).  Of the six channels only this piece and channel
   5 have identical unobserved partons.                                    *)
pref = eq^2 ee^2 gs^4/(2 SUNN 2);
MR2gQGG  = (pref M2gAcc)  /. D -> 4 - 2 eps;
MR2PPQGG = (pref M2PPAcc) /. D -> 4 - 2 eps;
If[!FreeQ[MR2gQGG, D] || !FreeQ[MR2PPQGG, D],
  Print["FATAL: D survives the substitution D -> 4 - 2 eps"]; Quit[1]];
If[FreeQ[MR2gQGG, eps] || FreeQ[MR2PPQGG, eps],
  Print["FATAL: eps absent -- the D substitution did not take effect"];
  Quit[1]];
Print["[9] MR2gQGG ", LeafCount[MR2gQGG], "  MR2PPQGG ", LeafCount[MR2PPQGG]];

nm[e_] := StringReplace[ToString[e // FortranForm], "SUNN" -> "Nc"];
out = FileNameJoin[{root, "python", "generated", "Hqq2_R1_qgg.py"}];
Export[out, StringJoin[
  "# generated by mathematica/Hqq2_R1_qgg.wls (Hqq REBUILD, step R1)\n",
  "# WS10: gamma* q -> q g g; |M_{2->3}|^2 for the Hqq;gg graphs.\n",
  "# 6 abelian + 2 triple-gluon; physical gluon polarization sums;\n",
  "# accumulated PAIRWISE (never a global Together).\n",
  "# Triple-gluon phases {eta7,eta8} = ", ToString[chosenSigns, InputForm],
  ", fixed by BOTH external-gluon\n",
  "# Ward identities in BOTH photon projections (the photon Ward identity\n",
  "# cannot fix them: the abelian and triple sets are separately transverse).\n",
  "# pref = eq^2 ee^2 gs^4/(2 Nc 2): couplings, spin+colour average, and the\n",
  "# 1/2! IDENTICAL-GLUON phase-space factor.\n",
  "# Invariants s,Q2,t1,t2,t3,u1,u2,u3,s12,s13,s23; NO conservation imposed.\n",
  "MR2gQGG = \"\"\"", nm[MR2gQGG], "\"\"\"\n\n",
  "MR2PPQGG = \"\"\"", nm[MR2PPQGG], "\"\"\"\n"], "Text"];
Print["[10] exported ", out];
tick["export done"];
Print["HQQ2_R1_QGG_DONE"];

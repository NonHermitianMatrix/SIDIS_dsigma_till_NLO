(* Hgq_NLO_R1_traces.wls -- Step R1, channel Hgq (BigTMD chn1):
   gamma*(q,mu) + g(p,rho,e) -> q(k1,ci) + qbar(k2,cj) + g(k3,be,b)
   Gluon-INITIATED.  Obtained by crossing the qgg diagrams (incoming quark
   -> outgoing antiquark k2, one final gluon -> incoming gluon p); the
   fermion line is ubar(k1)...v(k2) with the incoming gluon p and outgoing
   gluon k3 attached, plus the photon.  8 diagrams (6 abelian + 2
   triple-gluon), same self-validating machinery as the qgg trace
   (pairwise accumulation, physical gluon polarization sums, Ward-scan to
   fix the triple-gluon phase, photon gauge check).
   BigTMD fchn1 is the structure reference. *)

$HistoryLength = 0;
<< FeynCalc`;
SetDirectory["/home/physics/projects/AI_Assisted_SIDIS"];

FCClearScalarProducts[];
SPD[p, p] = 0; SPD[q, q] = -Q2;
SPD[k1, k1] = 0; SPD[k2, k2] = 0; SPD[k3, k3] = 0;
SPD[p, q] = (s + Q2)/2;
SPD[q, k1] = -(t1 + Q2)/2; SPD[q, k2] = -(t2 + Q2)/2; SPD[q, k3] = -(t3 + Q2)/2;
SPD[p, k1] = -u1/2; SPD[p, k2] = -u2/2; SPD[p, k3] = -u3/2;
SPD[k1, k2] = s12/2; SPD[k1, k3] = s13/2; SPD[k2, k3] = s23/2;
Print["[1] loaded; scalar products set (Hgq: gamma* g -> q qbar g)"];
Print["WS10 (NLO real; -> R1-R4): gamma* g -> q qbar g; |M_{2->3}|^2."];

(* dependent invariants for the gauge/Ward checks (p+q=k1+k2+k3) *)
arSub = {u1 -> s23 - s - t1 - Q2, t3 -> (s23 - s - t1 - Q2) - t2 - s23 - Q2,
         u3 -> t1 - u2 - s23, s13 -> s + t2 + u2 + Q2,
         s12 -> s - s23 - (s + t2 + u2 + Q2)};

(* fermion line ubar(k1) ... v(k2); V = photon vertex; gluon p:(rho,e),
   gluon k3:(be,b); internal gluon (si,c) for the triple-gluon graphs.
   Propagator momenta and denominators from momentum conservation:
   (k1-q)^2=t1, (k1-p)^2=u1, (k1+k3)^2=s13, (k1-q-p)^2=(k2+k3)^2=s23,
   (k1-q+k3)^2=(p-k2)^2=u2, (k1-p+k3)^2=(q-k2)^2=t2, (p-k3)^2=u3. *)
d[1][V_] := SpinorUBarD[k1] . V . GSD[k1 - q] . GAD[rho] . GSD[-k2 - k3] .
   GAD[be] . SpinorVD[k2]/(t1 s23) SUNTF[{e, b}, ci, cj];
d[2][V_] := SpinorUBarD[k1] . V . GSD[k1 - q] . GAD[be] . GSD[p - k2] .
   GAD[rho] . SpinorVD[k2]/(t1 u2) SUNTF[{b, e}, ci, cj];
d[3][V_] := SpinorUBarD[k1] . GAD[rho] . GSD[k1 - p] . V . GSD[-k2 - k3] .
   GAD[be] . SpinorVD[k2]/(u1 s23) SUNTF[{e, b}, ci, cj];
d[4][V_] := SpinorUBarD[k1] . GAD[rho] . GSD[k1 - p] . GAD[be] . GSD[q - k2] .
   V . SpinorVD[k2]/(u1 t2) SUNTF[{e, b}, ci, cj];
d[5][V_] := SpinorUBarD[k1] . GAD[be] . GSD[k1 + k3] . V . GSD[p - k2] .
   GAD[rho] . SpinorVD[k2]/(s13 u2) SUNTF[{b, e}, ci, cj];
d[6][V_] := SpinorUBarD[k1] . GAD[be] . GSD[k1 + k3] . GAD[rho] . GSD[q - k2] .
   V . SpinorVD[k2]/(s13 t2) SUNTF[{b, e}, ci, cj];
(* triple-gluon vertex: external p(in,rho,e), k3(out,be,b), internal
   (k3-p,si,c) all-incoming form *)
v3 = SUNF[e, b, cc] (MTD[rho, be] FVD[p + k3, si] +
     MTD[be, si] FVD[p - 2 k3, rho] + MTD[si, rho] FVD[k3 - 2 p, be]);
d[7][V_] := (SpinorUBarD[k1] . GAD[si] . GSD[q - k2] . V . SpinorVD[k2]/
     (t2 u3)) v3 SUNTF[{cc}, ci, cj];
d[8][V_] := (SpinorUBarD[k1] . V . GSD[k1 - q] . GAD[si] . SpinorVD[k2]/
     (t1 u3)) v3 SUNTF[{cc}, ci, cj];
Print["[2] 8 diagrams defined"];

signChoices = {{I, I}, {I, -I}, {-I, I}, {-I, -I}};
ampWeight[i_, signs_] := If[i <= 6, 1, signs[[i - 6]]];
polS[mu_, nu_, k_, n_] := -MTD[mu, nu] +
   (FVD[k, mu] FVD[n, nu] + FVD[n, mu] FVD[k, nu])/SPD[k, n];

(* pairwise accumulation; gluons p(rho) and k3(be), physical pol sums *)
build[Pgam_] := Module[{tot = 0, r, i, j},
  Do[
   r = FermionSpinSum[d[i][GAD[mu]] ComplexConjugate[d[j][GAD[mu2]] /.
       {rho -> rho2, be -> be2, si -> si2, cc -> cc2}]];
   r = Contract[r Pgam polS[rho, rho2, p, k3] polS[be, be2, k3, p]];
   r = DiracSimplify[r];
   r = FCCanonicalizeDummyIndices[r];
   r = SUNSimplify[r, SUNNToCACF -> False];
   tot = tot + ampWeight[i, chosenSigns] Conjugate[ampWeight[j, chosenSigns]] Together[r],
   {i, 8}, {j, 8}];
  tot];

buildGluonWardScan[Pgam_, wardK_, wardI_, wardI2_, polK_, polI_, polI2_] :=
 Module[{tots = ConstantArray[0, Length[signChoices]], r, i, j, h},
  Do[
   r = FermionSpinSum[d[i][GAD[mu]] ComplexConjugate[d[j][GAD[mu2]] /.
       {rho -> rho2, be -> be2, si -> si2, cc -> cc2}]];
   r = Contract[r Pgam FVD[wardK, wardI] FVD[wardK, wardI2]
       polS[polI, polI2, polK, wardK]];
   r = DiracSimplify[r]; r = FCCanonicalizeDummyIndices[r];
   r = SUNSimplify[r, SUNNToCACF -> False]; r = Together[r];
   Do[tots[[h]] = tots[[h]] + ampWeight[i, signChoices[[h]]]
       Conjugate[ampWeight[j, signChoices[[h]]]] r, {h, Length[signChoices]}],
   {i, 8}, {j, 8}];
  tots];

(* Ward scan on each external gluon to fix the triple-gluon phase *)
scanKp = Simplify[# /. arSub] & /@
   buildGluonWardScan[MTD[mu, mu2], p, rho, rho2, k3, be, be2];
Print["[3a] gluon-p Ward scan: ",
  MapThread[{#1, If[#2 === 0, "ZERO", "NONZERO"]} &, {signChoices, scanKp}]];
scanK3 = Simplify[# /. arSub] & /@
   buildGluonWardScan[MTD[mu, mu2], k3, be, be2, p, rho, rho2];
Print["[3b] gluon-k3 Ward scan: ",
  MapThread[{#1, If[#2 === 0, "ZERO", "NONZERO"]} &, {signChoices, scanK3}]];
passing = Pick[signChoices,
   MapThread[(#1 === 0 && #2 === 0) &, {scanKp, scanK3}]];
If[Length[passing] =!= 1,
  Print["FATAL: expected one Ward-clean phase; got ", passing // InputForm];
  Quit[1]];
chosenSigns = First[passing];
Print["[3c] triple-gluon phase {eta7,eta8} = ", chosenSigns];

(* photon gauge check q^mu q^mu2 -> 0 *)
gc = Simplify[build[FVD[q, mu] FVD[q, mu2]] /. arSub];
Print["[3] check 2 (photon Ward q q, must be 0): ", gc // InputForm];
If[gc =!= 0, Print["FATAL: photon gauge check nonzero"]; Quit[1]];

M2gAcc = build[MTD[mu, mu2]];
Print["[4] M2g done; leafcount ", LeafCount[M2gAcc]];
M2PPAcc = build[FVD[p, mu] FVD[p, mu2]];
Print["[5] M2PP done; leafcount ", LeafCount[M2PPAcc]];
If[!FreeQ[{M2gAcc, M2PPAcc}, LorentzIndex] || !FreeQ[{M2gAcc, M2PPAcc}, polS],
  Print["FATAL: open index/pol"]; Quit[1]];
Print["[5b] structural guard passed"];

(* gluon-initiated average: 1/(Nc^2-1) colour, 1/(2-2eps) pols; final
   q,qbar,g distinct (no 1/2!) *)
pref = eq^2 ee^2 gs^4/((SUNN^2 - 1) (2 - 2 eps));
M2g  = (pref M2gAcc) /. D -> 4 - 2 eps;
M2PP = (pref M2PPAcc) /. D -> 4 - 2 eps;
DumpSave["mathematica/Hgq_NLO_R1.mx", {M2g, M2PP}];
pyStr[e_] := StringReplace[
   ToString[e /. SUNN -> Nc, InputForm, PageWidth -> Infinity], "^" -> "**"];
str = "# generated by mathematica/Hgq_NLO_R1_traces.wls (chn1 Hgq real)\n" <>
  "# gamma* g -> q qbar g; |M|^2; gluon-initiated average 1/((Nc^2-1)(2-2eps))\n" <>
  "# triple-gluon phase {eta7,eta8}=" <> ToString[chosenSigns, InputForm] <> "\n" <>
  "from sympy import sympify\nM2g = sympify('" <> pyStr[M2g] <> "')\nM2PP = sympify('" <> pyStr[M2PP] <> "')\n";
Export["python/generated/Hgq_R1.py", str, "Text"];
Print["[6] exported -> python/generated/Hgq_R1.py; leafcounts M2g=",
  LeafCount[M2g], " M2PP=", LeafCount[M2PP]];
Print["HGQ_R1_DONE"];

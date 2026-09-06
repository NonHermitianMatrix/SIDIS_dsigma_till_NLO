#!/usr/bin/env wolframscript
(* s02 : real 2->3 squared amplitude for  gamma*(q) + g(p) -> q(k1) qbar(k2) g(k3)
   ( = Hgq;qbar g of Table I ), contracted with g^{mu nu} and p^mu p^nu.
   Kept as a LIST of diagram-pair contributions so that the propagator
   denominators (the angle dependent Mandelstams) stay explicit for the
   partial fractioning of Appendix D.                                       *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
mu = FCGV["mu"]; nu = FCGV["nu"];
polToIndex[expr_, mom_, idx_] := expr /. {
   Momentum[Polarization[mom, _, ___], dim___] :> LorentzIndex[idx, dim]};

(* ---------------- 2->3 kinematics ------------------------------------- *)
FCClearScalarProducts[];
ScalarProduct[p, p, Dimension -> D] = 0;
ScalarProduct[k1, k1, Dimension -> D] = 0;
ScalarProduct[k2, k2, Dimension -> D] = 0;
ScalarProduct[q, q, Dimension -> D] = -Q2;
ScalarProduct[p, q, Dimension -> D] = (s + Q2)/2;
ScalarProduct[p, k1, Dimension -> D] = -u/2;
ScalarProduct[q, k1, Dimension -> D] = (-Q2 - t)/2;
ScalarProduct[p, k2, Dimension -> D] = -u2/2;
ScalarProduct[q, k2, Dimension -> D] = (-Q2 - t2)/2;
ScalarProduct[k1, k2, Dimension -> D] = s12h/2;   (* solved for below *)

(* k3 = p+q-k1-k2 on shell fixes s12 *)
s12sol = Solve[ExpandScalarProduct[SPD[p + q - k1 - k2, p + q - k1 - k2]] == 0, s12h][[1, 1, 2]];
Print["[s02] s12 = 2 k1.k2 = ", s12sol];
ScalarProduct[k1, k2, Dimension -> D] = s12sol/2;

(* k3 is an independent symbol in the FeynArts amplitude: give it the
   scalar products implied by k3 = p+q-k1-k2 (computed, not transcribed) *)
k3vals = Simplify[{ExpandScalarProduct[SPD[p + q - k1 - k2, p + q - k1 - k2]],
   ExpandScalarProduct[SPD[p + q - k1 - k2, p]],
   ExpandScalarProduct[SPD[p + q - k1 - k2, q]],
   ExpandScalarProduct[SPD[p + q - k1 - k2, k1]],
   ExpandScalarProduct[SPD[p + q - k1 - k2, k2]]}];
Print["[s02] k3 scalar products: ", k3vals];
ScalarProduct[k3, k3, Dimension -> D] = k3vals[[1]];
ScalarProduct[k3, p, Dimension -> D] = k3vals[[2]];
ScalarProduct[k3, q, Dimension -> D] = k3vals[[3]];
ScalarProduct[k3, k1, Dimension -> D] = k3vals[[4]];
ScalarProduct[k3, k2, Dimension -> D] = k3vals[[5]];

s23v = ExpandScalarProduct[2 SPD[k2, k3]];
s13v = ExpandScalarProduct[2 SPD[k1, k3]];
u3v  = ExpandScalarProduct[-2 SPD[p, k3]];
t3v  = ExpandScalarProduct[SPD[q - k3, q - k3]];
Print["[s02] s23 = ", Simplify[s23v], " | s13 = ", Simplify[s13v],
      " | u3 = ", Simplify[u3v], " | t3 = ", Simplify[t3v]];
(* Appendix D relations, checked by the tool *)
chk = Simplify[{s23v - (s + t + u + Q2), s13v - (s + t2 + u2 + Q2),
   (u2 + u3v) - (t - s23v), (t2 + t3v) - (u - s23v - Q2),
   (s12sol + s13v) - (s - s23v)}];
Print["[s02] Appendix-D relation checks (must be all 0): ", chk];
If[Union[chk] =!= {0}, Print["ABORT"]; Quit[1]];

(* ---------------- diagrams -------------------------------------------- *)
diags = InsertFields[CreateTopologies[0, 2 -> 3], {V[1], V[5]} ->
    {F[3, {1}], -F[3, {1}], V[5]}, InsertionLevel -> {Classes}, Model -> "SMQCD"];
amps = FCFAConvert[CreateFeynAmp[diags], IncomingMomenta -> {q, p},
   OutgoingMomenta -> {k1, k2, k3}, UndoChiralSplittings -> True,
   ChangeDimension -> D, List -> True, SMP -> True, Contract -> True,
   DropSumOver -> True, Prefactor -> 3/2 SMP["e_Q"]];
amps = amps /. SMP["e"] -> 1 /. SMP["m_u"] -> 0;
Print["[s02] number of diagrams: ", Length[amps]];

avg = 1/(2 (1 - eps)) 1/(SUNN^2 - 1);

(* one Dirac trace per projector: build the photon-index amplitude and its
   conjugate once, sum the 8 diagrams, then square.  (The earlier pairwise
   version did 8x8 traces per projector and was ~100x slower.)             *)
aMu = polToIndex[#, q, mu] & /@ amps;
aNu = (ComplexConjugate[#] /. mu -> nu) & /@ aMu;
AM = Total[aMu]; AN = Total[aNu];

sq[proj_, refP_, refK3_] := Module[{x},
  x = avg proj AM AN;
  x = FeynAmpDenominatorExplicit[x];
  x = SUNSimplify[x, Explicit -> True, SUNNToCACF -> False];
  x = FermionSpinSum[x];
  x = DiracSimplify[x];
  x = DoPolarizationSums[x, p, refP];
  x = DoPolarizationSums[x, k3, refK3];
  x = Contract[x];
  Together[x /. D -> 4 - 2 eps]];

t0 = AbsoluteTime[];
sumMg = sq[MTD[mu, nu], k1, p];
Print["[s02] Mg done, t = ", Round[AbsoluteTime[] - t0], " s, LeafCount=", LeafCount[sumMg]];
sumMpp = sq[FVD[p, mu] FVD[p, nu], k1, p];
Print["[s02] Mpp done, t = ", Round[AbsoluteTime[] - t0], " s, LeafCount=", LeafCount[sumMpp]];

(* gluon reference-vector (gauge) independence check *)
sumMg2 = sq[MTD[mu, nu], k2, k1];
Print["[s02] Mg gauge check (must be 0): ", Simplify[sumMg2 - sumMg]];
Print["[s02] gauge check done, t = ", Round[AbsoluteTime[] - t0], " s"];

Put[<|"Mg" -> Together[sumMg], "Mpp" -> Together[sumMpp],
   "vars" -> {s, t, u, Q2, t2, u2},
   "derived" -> <|"s23" -> Simplify[s23v], "s13" -> Simplify[s13v],
     "u3" -> Simplify[u3v], "t3" -> Simplify[t3v], "s12" -> Simplify[s12sol]|>|>
   /. {SMP["g_s"] -> gs, SMP["e_Q"] -> eq, SUNN -> Nc},
  FileNameJoin[{DirectoryName[$InputFileName], "s02_result.m"}]];
Print["[s02] LeafCount Mg = ", LeafCount[sumMg], "  Mpp = ", LeafCount[sumMpp]];
Print["[s02] done, total t = ", Round[AbsoluteTime[] - t0], " s"];

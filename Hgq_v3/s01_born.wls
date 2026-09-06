#!/usr/bin/env wolframscript
(* s01 : Born (order alpha_s) 2->2 squared amplitudes for
     (A)  gamma*(q) + g(p)  -> q(k1) + qbar(k2)     [ LO of the Hgq channel ]
     (B)  gamma*(q) + q(p)  -> q(k1) + g(k2)        [ needed by the P_qg subtraction ]
   contracted with the two extraction tensors of paper Eq.(7):
     Hg  = g^{mu nu} |M|^2_{mu nu} ,  Hpp = p^mu p^nu |M|^2_{mu nu}
   exact in D = 4-2 eps.  Initial state spin+colour averaged, final state summed. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];

mu = FCGV["mu"]; nu = FCGV["nu"];

polToIndex[expr_, mom_, idx_] := expr /. {
   Momentum[Polarization[mom, _, ___], dim___] :> LorentzIndex[idx, dim]};

(* ---------- kinematics: 2->2 ,  s + t + u = -Q2 ---------------------- *)
setKin22[] := (
  FCClearScalarProducts[];
  ScalarProduct[p, p, Dimension -> D] = 0;
  ScalarProduct[k1, k1, Dimension -> D] = 0;
  ScalarProduct[k2, k2, Dimension -> D] = 0;
  ScalarProduct[q, q, Dimension -> D] = -Q2;
  ScalarProduct[p, q, Dimension -> D] = (s + Q2)/2;
  ScalarProduct[q, k1, Dimension -> D] = (-Q2 - t)/2;
  ScalarProduct[p, k1, Dimension -> D] = -u/2;
  (* derived from k2 = p+q-k1 and the above (tool-derived, see check below) *)
  ScalarProduct[p, k2, Dimension -> D] = (s + Q2 + u)/2;
  ScalarProduct[q, k2, Dimension -> D] = (s + t)/2;
  ScalarProduct[k1, k2, Dimension -> D] = (s + t + u + Q2 + s)/2 - (s + t + u + Q2)/2;
  );

(* momentum-conservation check: k2 = p+q-k1 must be on shell and consistent *)
setKin22[];
chk = Simplify[{
   ExpandScalarProduct[SPD[p + q - k1, p + q - k1]] - SPD[k2, k2],
   ExpandScalarProduct[SPD[p + q - k1, p]] - SPD[k2, p],
   ExpandScalarProduct[SPD[p + q - k1, q]] - SPD[k2, q],
   ExpandScalarProduct[SPD[p + q - k1, k1]] - SPD[k2, k1]} /. u -> -Q2 - s - t];
Print["[s01] 2->2 momentum-conservation check (must be {0,0,0,0}): ", chk];
If[chk =!= {0, 0, 0, 0}, Print["ABORT"]; Quit[1]];

(* ---------- generic squared-amplitude builder ------------------------- *)
(* gluons: axial polarisation sum with the given reference vectors        *)
buildSq[diags_, inMom_, outMom_, gluonRefs_, avg_] := Module[
  {amp, aMu, aNu, sq, res},
  amp = FCFAConvert[CreateFeynAmp[diags], IncomingMomenta -> inMom,
     OutgoingMomenta -> outMom, UndoChiralSplittings -> True,
     ChangeDimension -> D, List -> False, SMP -> True, Contract -> True,
     DropSumOver -> True, Prefactor -> 3/2 SMP["e_Q"]];
  amp = amp /. SMP["e"] -> 1 /. SMP["m_u"] -> 0;
  aMu = polToIndex[amp, q, mu];
  aNu = ComplexConjugate[aMu] /. mu -> nu;
  sq[proj_] := Module[{x},
    x = avg proj aMu aNu;
    x = FeynAmpDenominatorExplicit[x];
    x = SUNSimplify[x, Explicit -> True, SUNNToCACF -> False];
    x = FermionSpinSum[x];
    x = DiracSimplify[x];
    Do[x = DoPolarizationSums[x, First[gr], Last[gr]], {gr, gluonRefs}];
    x = Contract[x];
    Simplify[x]];
  res = <|"Hg" -> sq[hgqProjTensor["g", p]], "Hpp" -> sq[hgqProjTensor["pp", p]]|>;
  res];

(* ---------- (A) gamma* g -> q qbar ------------------------------------ *)
diagA = InsertFields[CreateTopologies[0, 2 -> 2], {V[1], V[5]} -> {F[3, {1}], -F[3, {1}]},
   InsertionLevel -> {Classes}, Model -> "SMQCD"];
Print["[s01] A diagrams: ", Length[diagA[[2]]]];
setKin22[];
(* incoming gluon p: average 1/(2(1-eps)) spins x 1/(Nc^2-1) colours *)
avgA = 1/(2 (1 - eps)) 1/(SUNN^2 - 1);
resA = buildSq[diagA, {q, p}, {k1, k2}, {{p, k1}}, avgA];

(* gluon reference independence check *)
resAalt = buildSq[diagA, {q, p}, {k1, k2}, {{p, k2}}, avgA];
Print["[s01] A gluon-gauge check (must be {0,0}): ",
  Simplify[{resA["Hg"] - resAalt["Hg"], resA["Hpp"] - resAalt["Hpp"]} /. u -> -Q2 - s - t]];

(* cross-check vs FeynCalc example / R.Field Eq.4.3.20 (D->4, Nc->3) *)
known = -2 SMP["e_Q"]^2 SMP["g_s"]^2 (u/t + t/u + 2 Q2 (u + t + Q2)/(t u));
Print["[s01] A check vs published |M|^2 (must be 0): ",
  Simplify[(resA["Hg"] /. {D -> 4, eps -> 0, SUNN -> 3}) - known /. u -> -Q2 - s - t]];

(* ---------- (B) gamma* q -> q g --------------------------------------- *)
diagB = InsertFields[CreateTopologies[0, 2 -> 2], {V[1], F[3, {1}]} -> {F[3, {1}], V[5]},
   InsertionLevel -> {Classes}, Model -> "SMQCD"];
Print["[s01] B diagrams: ", Length[diagB[[2]]]];
setKin22[];
avgB = 1/2 1/SUNN;
resB = buildSq[diagB, {q, p}, {k1, k2}, {{k2, p}}, avgB];
resBalt = buildSq[diagB, {q, p}, {k1, k2}, {{k2, k1}}, avgB];
Print["[s01] B gluon-gauge check (must be {0,0}): ",
  Simplify[{resB["Hg"] - resBalt["Hg"], resB["Hpp"] - resBalt["Hpp"]} /. u -> -Q2 - s - t]];

(* ---------- projectors, derived ---------------------------------------- *)
projRules = hgqProjectorRules[];
Print["[s01] F1,F2 projector solution: ", projRules];

out = <|"A" -> resA, "B" -> resB, "proj" -> projRules|>;
Put[out /. {SMP["g_s"] -> gs, SMP["e_Q"] -> eq, SUNN -> Nc, D -> 4 - 2 eps},
  FileNameJoin[{DirectoryName[$InputFileName], "s01_result.m"}]];
Print["[s01] Hg(A) = ", Simplify[resA["Hg"] /. u -> -Q2 - s - t]];
Print["[s01] done"];

#!/usr/bin/env wolframscript
(* s05 : virtual O(alpha_s^2) contribution to Hgq  =  2 Re( M_1loop M_Born^* )
   for  gamma*(q) + g(p) -> q(k1) + qbar(k2),  contracted with g^{mu nu} and
   p^mu p^nu.   UV and IR poles are kept separate (PaXEvaluateUVIRSplit).
   External massless self energies are scaleless -> 0 and Z_2 = Z_3 = 1;
   the only counterterm is the MSbar coupling renormalisation, whose
   coefficient is DERIVED here by demanding the UV poles cancel and then
   checked against beta0.                                                    *)

HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
If[! ValueQ[PaXEvaluateUVIRSplit] && Head[PaXEvaluateUVIRSplit] === Symbol &&
   Names["FeynCalc`PaXEvaluateUVIRSplit"] === {} && Names["Global`PaXEvaluateUVIRSplit"] === {},
  Null];
Print["[s05] FeynHelpers loaded: ", MemberQ[$Packages, "FeynCalc`"] && Length[DownValues[PaXEvaluate]] > 0];
dir = DirectoryName[$InputFileName];
mu = FCGV["mu"]; nu = FCGV["nu"];
polToIndex[expr_, mom_, idx_] := expr /. {
   Momentum[Polarization[mom, _, ___], dim___] :> LorentzIndex[idx, dim]};

FCClearScalarProducts[];
ScalarProduct[p, p, Dimension -> D] = 0;
ScalarProduct[k1, k1, Dimension -> D] = 0;
ScalarProduct[k2, k2, Dimension -> D] = 0;
ScalarProduct[q, q, Dimension -> D] = -Q2;
ScalarProduct[p, q, Dimension -> D] = (s + Q2)/2;
ScalarProduct[q, k1, Dimension -> D] = (-Q2 - t)/2;
ScalarProduct[p, k1, Dimension -> D] = -u/2;
ScalarProduct[p, k2, Dimension -> D] = (s + Q2 + u)/2;
ScalarProduct[q, k2, Dimension -> D] = (s + t)/2;
ScalarProduct[k1, k2, Dimension -> D] = s/2;

(* ---------------- diagrams -------------------------------------------- *)
topsT = CreateTopologies[0, 2 -> 2];
topsL = CreateTopologies[1, 2 -> 2, ExcludeTopologies -> {Tadpoles, WFCorrections}];
insT = InsertFields[topsT, {V[1], V[5]} -> {F[3, {1}], -F[3, {1}]},
   InsertionLevel -> {Classes}, Model -> "SMQCD"];
insL = InsertFields[topsL, {V[1], V[5]} -> {F[3, {1}], -F[3, {1}]},
   InsertionLevel -> {Classes}, Model -> "SMQCD",
   ExcludeParticles -> {S[_], V[2], V[3], F[1], F[2], F[4]}];
faT = CreateFeynAmp[insT, Truncated -> False, PreFactor -> 3/2 SMP["e_Q"]];
faL = CreateFeynAmp[insL, Truncated -> False, PreFactor -> 3/2 SMP["e_Q"]];
Print["[s05] tree amplitudes: ", Length[faT], "   loop amplitudes: ", Length[faL]];

conv[fa_] := FCFAConvert[fa, IncomingMomenta -> {q, p}, OutgoingMomenta -> {k1, k2},
   LoopMomenta -> {ll}, UndoChiralSplittings -> True, ChangeDimension -> D,
   List -> False, SMP -> True, Contract -> True, DropSumOver -> True] /. SMP["m_u"] -> 0;

(* keep only the pure-QCD orders: tree ~ gs^1, one loop ~ gs^3.  FeynArts also
   generates the QED (photon-exchange) loop corrections, which are O(alpha_em
   alpha_s), not O(alpha_s^2), and must be dropped.                          *)
pickGs[x_, n_] := Coefficient[x, SMP["g_s"], n] SMP["g_s"]^n;
ampT = pickGs[conv[faT], 1] /. SMP["e"] -> 1;
ampL = pickGs[conv[faL], 3] /. SMP["e"] -> 1;
Print["[s05] gs powers kept: tree 1, loop 3"];

(* resolve the propagators that do not carry the loop momentum *)
resolveTree[x_] := FeynAmpDenominatorSplit[x] //.
   FeynAmpDenominator[PropagatorDenominator[mm_, 0]] :>
     1/ExpandScalarProduct[Pair[mm, mm]] /; FreeQ[mm, ll];
ampT = resolveTree[ampT];
ampL = resolveTree[ampL];

avg = 1/(2 (1 - eps)) 1/(SUNN^2 - 1);

interf[proj_] := Module[{aL, aTc, x},
  aL = polToIndex[ampL, q, mu];
  aTc = ComplexConjugate[polToIndex[ampT, q, mu]] /. mu -> nu;
  x = avg proj aL aTc;
  x = SUNSimplify[x, Explicit -> True, SUNNToCACF -> False];
  x = FermionSpinSum[x];
  x = DiracSimplify[x];
  x = DoPolarizationSums[x, p, k1];
  x = Contract[x];
  x = resolveTree[x];
  x = TID[x, ll, ToPaVe -> True];
  x = DiracSimplify[x];
  If[! FreeQ[x, _FeynAmpDenominator], Print["ABORT: unresolved FeynAmpDenominator"]; Quit[1]];
  Collect[x, _PaVe, Simplify]];

t0 = AbsoluteTime[];
Ig = interf[MTD[mu, nu]];
Print["[s05] Pg interference reduced to PaVe, t=", Round[AbsoluteTime[] - t0], " s"];
Ipp = interf[FVD[p, mu] FVD[p, nu]];
Print["[s05] Ppp interference reduced to PaVe, t=", Round[AbsoluteTime[] - t0], " s"];

(* --------- UV / IR split via the Package-X library in FeynHelpers ------ *)
paxOpts = {PaXImplicitPrefactor -> 1/(2 Pi)^D, PaXAnalytic -> True};
evalSplit[x_] := PaXEvaluateUVIRSplit[x, ll, Sequence @@ paxOpts];
Vg = evalSplit[Ig];
Print["[s05] Pg UV/IR split done, t=", Round[AbsoluteTime[] - t0], " s"];
Vpp = evalSplit[Ipp];
Print["[s05] Ppp UV/IR split done, t=", Round[AbsoluteTime[] - t0], " s"];

If[Head[Vg] === PaXEvaluateUVIRSplit || Head[Vpp] === PaXEvaluateUVIRSplit,
  Print["ABORT: PaXEvaluateUVIRSplit did not evaluate"]; Quit[1]];
Put[<|"Ig" -> Ig, "Ipp" -> Ipp, "Vg" -> Vg, "Vpp" -> Vpp,
   "ndiagTree" -> Length[faT], "ndiagLoop" -> Length[faL]|>
  /. {SMP["g_s"] -> gs, SMP["e_Q"] -> eq, SUNN -> Nc} /. D -> 4 - 2 eps,
  FileNameJoin[{dir, "s05_result.m"}]];
Print["[s05] done, t=", Round[AbsoluteTime[] - t0], " s"];

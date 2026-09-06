#!/usr/bin/env wolframscript
(* s07b : the wave-function renormalisation constants Z2 (quark) and Z3 (gluon)
   at one loop, UV and IR poles kept separate.

   WHY THIS STAGE EXISTS.  s05 builds the virtual with
     CreateTopologies[1, 2 -> 2, ExcludeTopologies -> {Tadpoles, WFCorrections}]
   so the external-leg self energies are dropped.  That is correct on shell -
   they are scaleless and vanish - but it also removes every source of C_A and
   n_f from the UV pole.  Measured on s05_result: the UV pole of 2Re(V) is
   exactly -6 C_F (both projectors), with no C_A and no n_f anywhere, while the
   MSbar coupling counterterm carries beta0 = (11 C_A - 4 T_F n_f)/3.  Those
   cannot cancel, so the compensating Z2 and Z3 must be supplied explicitly.

   Both are computed here from the one-loop 2-point functions at GENERIC
   p^2 = pp (not on shell), so the Dirac and Lorentz projections are well
   defined, and PaXEvaluateUVIRSplit separates 1/eps_UV from 1/eps_IR.  The
   quark loop in the gluon self energy is computed for ONE flavour and scaled
   by nf, with the flavour-loop diagrams identified by their fermion content
   rather than by a transcribed count.

   Conventions are inherited verbatim from s05: same PaXImplicitPrefactor,
   same D = 4 - 2 eps, same gs/Nc symbol mapping on output.                  *)

HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
mu = FCGV["mu"]; nu = FCGV["nu"];
LF = FileNameJoin[{dir, "s07b_progress.log"}];
log[x___] := Module[{ff = OpenAppend[LF]},
   WriteString[ff, StringJoin[ToString /@ {x}], "\n"]; Close[ff]];

FCClearScalarProducts[];
ScalarProduct[p, p, Dimension -> D] = pp;   (* generic, NOT on shell *)

(* Prefactor 1, NOT 1/(2Pi)^D.  With 1/(2Pi)^D these 2-point functions came out
   a uniform factor 1/(2Pi)^4 = 1/(16 Pi^4) below s05's normalisation (measured:
   SigmaV_UV/(as/4Pi) = C_F/(16 Pi^4) instead of C_F).  The check is
   self-validating: with the right prefactor both constants must reduce to pure
   rational colour factors with no residual Pi.                              *)
paxOpts = {PaXImplicitPrefactor -> 1, PaXAnalytic -> True};
evalSplit[x_] := PaXEvaluateUVIRSplit[x, ll, Sequence @@ paxOpts];

(* ---------------- 2-point topologies --------------------------------- *)
tops = CreateTopologies[1, 1 -> 1, ExcludeTopologies -> {Tadpoles}];
insQ = InsertFields[tops, F[3, {1}] -> F[3, {1}], InsertionLevel -> {Classes},
   Model -> "SMQCD", ExcludeParticles -> {S[_], V[1], V[2], V[3], F[1], F[2]}];
(* F[4] (down-type) must be excluded too: leaving it in gives TWO fermion loops
   (up and down of generation 1), which combined with the explicit nf scaling
   below double counts the flavours - that showed up as 4 nf instead of 2 nf. *)
insG = InsertFields[tops, V[5] -> V[5], InsertionLevel -> {Classes},
   Model -> "SMQCD", ExcludeParticles -> {S[_], V[1], V[2], V[3], F[1], F[2], F[4]}];
faQ = CreateFeynAmp[insQ, Truncated -> True];
faG = CreateFeynAmp[insG, Truncated -> True];
log["quark SE diagrams: ", Length[faQ], "   gluon SE diagrams: ", Length[faG]];
If[Length[faQ] == 0 || Length[faG] == 0,
  log["ABORT: no self-energy diagrams generated"]; Quit[1]];

conv[fa_] := FCFAConvert[fa, IncomingMomenta -> {p}, OutgoingMomenta -> {p},
   LoopMomenta -> {ll}, UndoChiralSplittings -> True, ChangeDimension -> D,
   List -> True, SMP -> True, Contract -> True, DropSumOver -> True] /.
   SMP["m_u"] -> 0 /. SMP["m_d"] -> 0;

ampQ = conv[faQ];
ampG = conv[faG];
log["converted: quark ", Length[ampQ], " terms, gluon ", Length[ampG], " terms"];

(* ---------------- Z2 : quark self energy ------------------------------ *)
(* Sigma = pslash SigmaV(pp).  Project with Tr[pslash . Sigma]/(4 pp).      *)
(* FCFAConvert names the external indices Lor1/Lor2 and Col1/Col2, not mu/nu:
   the projector must be built from the indices actually present, or it simply
   fails to contract and leaves the tensor/colour structure in place.        *)
freeLor[x_] := Union[Cases[x, LorentzIndex[a_, ___] :> a, Infinity]];
freeFCol[x_] := Union[Cases[x, SUNFIndex[a_] :> a, Infinity]];
freeACol[x_] := Union[Cases[x, SUNIndex[a_] :> a, Infinity]];

sigQ = Module[{x, ci},
   x = Total[ampQ];
   (* Sigma_ij = delta_ij SigmaV, so STRIP the colour delta - but only AFTER
      SUNSimplify: before it the colour structure is SUNT[a].SUNT[a], not a
      bare SUNFDelta, so a strip rule applied first matches nothing (that is
      what the assertion caught twice).                                      *)
   x = SUNSimplify[x, Explicit -> True, SUNNToCACF -> False];
   log["  quark SE colour objects after SUNSimplify: ",
       Union[Head /@ Cases[x, _SUNFDelta | _SUNT | _SUNTF | _SUNDelta, Infinity]]];
   x = x /. {SUNFDelta[__] :> 1, SUNDelta[__] :> 1};
   x = DiracSimplify[DiracTrace[GSD[p] . x]];
   x = TID[x, ll, ToPaVe -> True];
   x = Simplify[x/(4 pp)];
   If[freeFCol[x] =!= {} || freeLor[x] =!= {},
     log["ABORT: quark SE projection left free indices: Lor=", freeLor[x],
         " Col=", freeFCol[x]];
     log["  remaining colour objects: ",
         Union[Cases[x, (_SUNFDelta | _SUNT | _SUNTF | _SUNDelta | _SUNF), Infinity]]];
     Quit[1]];
   x];
sigQ = evalSplit[sigQ];
log["quark SE projected and split"];
If[Head[sigQ] === PaXEvaluateUVIRSplit, log["ABORT: quark SE did not evaluate"]; Quit[1]];
Z2uv = Simplify[Coefficient[sigQ, 1/EpsilonUV]];
Z2ir = Simplify[Coefficient[sigQ, 1/EpsilonIR]];
log["SigmaV UV pole coeff = ", InputForm[Z2uv]];
log["SigmaV IR pole coeff = ", InputForm[Z2ir]];

(* ---------------- Z3 : gluon self energy ------------------------------ *)
(* Pi^{mu nu,ab} = delta^{ab} (pp g^{mu nu} - p^mu p^nu) Pi(pp).
   Contract Lorentz with g_{mu nu}  -> pp (D-1) Pi ,
   contract colour with delta^{ab}  -> (Nc^2-1) Pi .
   The closed-fermion-loop diagrams are identified by carrying a fermion
   propagator, computed for one flavour and scaled by nf.                   *)
fermLoopQ[x_] := ! FreeQ[x, DiracGamma] || ! FreeQ[x, DiracTrace];
gSplit = GroupBy[ampG, fermLoopQ];
log["gluon SE: ", Length[Lookup[gSplit, True, {}]], " fermion-loop diagrams, ",
    Length[Lookup[gSplit, False, {}]], " gluon/ghost-loop diagrams"];
If[Length[Lookup[gSplit, True, {}]] != 1,
  log["ABORT: expected exactly 1 fermion-loop diagram (one flavour) before the ",
      "nf scaling, found ", Length[Lookup[gSplit, True, {}]]]; Quit[1]];

projG[x_] := Module[{y, li, ai},
   y = x;
   (* Pi^{ab} = delta^{ab} Pi : simplify first, then strip the adjoint delta. *)
   y = SUNSimplify[y, Explicit -> True, SUNNToCACF -> False];
   log["  gluon SE colour objects after SUNSimplify: ",
       Union[Head /@ Cases[y, _SUNFDelta | _SUNT | _SUNTF | _SUNDelta | _SUNF, Infinity]]];
   y = y /. {SUNDelta[__] :> 1, SUNFDelta[__] :> 1};
   y = DiracSimplify[y];
   li = freeLor[y];
   If[Length[li] != 2,
     log["ABORT: gluon SE has ", Length[li], " free Lorentz indices, expected 2"]; Quit[1]];
   y = Contract[MTD[li[[1]], li[[2]]] y];
   y = TID[y, ll, ToPaVe -> True];
   y = Simplify[y/(pp (D - 1))];
   If[freeLor[y] =!= {} || freeACol[y] =!= {},
     log["ABORT: gluon SE projection left free indices: Lor=", freeLor[y],
         " Col=", freeACol[y]]; Quit[1]];
   y];

piF = If[Lookup[gSplit, True, {}] === {}, 0, projG[Total[gSplit[True]]]];
piB = If[Lookup[gSplit, False, {}] === {}, 0, projG[Total[gSplit[False]]]];
piF = If[piF === 0, 0, evalSplit[piF]];
piB = If[piB === 0, 0, evalSplit[piB]];
log["gluon SE projected and split"];
If[Head[piF] === PaXEvaluateUVIRSplit || Head[piB] === PaXEvaluateUVIRSplit,
  log["ABORT: gluon SE did not evaluate"]; Quit[1]];

(* one flavour -> nf flavours on the fermion-loop piece only *)
piTotUV = Simplify[nf Coefficient[piF, 1/EpsilonUV] + Coefficient[piB, 1/EpsilonUV]];
piTotIR = Simplify[nf Coefficient[piF, 1/EpsilonIR] + Coefficient[piB, 1/EpsilonIR]];
log["Pi UV pole coeff (nf-scaled) = ", InputForm[piTotUV]];
log["Pi IR pole coeff (nf-scaled) = ", InputForm[piTotIR]];

Put[<|"SigmaV_UV" -> Z2uv, "SigmaV_IR" -> Z2ir,
      "Pi_UV" -> piTotUV, "Pi_IR" -> piTotIR,
      "Pi_F_UV" -> If[piF === 0, 0, Coefficient[piF, 1/EpsilonUV]],
      "Pi_B_UV" -> If[piB === 0, 0, Coefficient[piB, 1/EpsilonUV]],
      "ndiagQ" -> Length[faQ], "ndiagG" -> Length[faG]|>
  /. {SMP["g_s"] -> gs, SUNN -> Nc} /. D -> 4 - 2 eps,
  FileNameJoin[{dir, "s07b_result.m"}]];
(* normalisation gate: in units of as/(4Pi) both must be pure colour factors *)
CFv = (SUNN^2 - 1)/(2 SUNN); CAv = SUNN; TFv = 1/2;
unit = as/(4 Pi);
gsN = gs^2 -> 4 Pi as;
n2 = Simplify[(Z2uv /. gs -> Sqrt[4 Pi as])/unit];
n3 = Simplify[(piTotUV /. gs -> Sqrt[4 Pi as])/unit];
log["NORM CHECK  SigmaV_UV/unit = ", InputForm[n2], "   expect C_F = ",
    InputForm[Simplify[CFv /. SUNN -> Nc]]];
log["NORM CHECK  Pi_UV/unit     = ", InputForm[n3], "   expect 5CA/3-4TF nf/3 = ",
    InputForm[Simplify[(5 CAv/3 - 4 TFv nf/3) /. SUNN -> Nc]]];
log["NORM CHECK  SigmaV free of Pi ? ", FreeQ[n2, Pi], "   Pi_UV free of Pi ? ", FreeQ[n3, Pi]];
log["s07b done"];

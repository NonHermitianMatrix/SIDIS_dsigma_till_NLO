(* Hqq_S12_LO_traces.wls -- S1/S2 prerequisite (WS13): eps-exact LO squared
   amplitudes for the TWO crossed LO channels entering the Hqq counterterms
   of Eq. (46) of arXiv:1903.01529:
     (gq) gamma*(q) + g(p) -> q(k1) + qbar(k2), quark fragments
          [enters CTpdf via P0_{g/q}];
     (qg) gamma*(q) + q(p) -> g(k1) + q(k2), gluon fragments
          [enters CTff via P0_{q/g}].
   Amplitudes typed from the Feynman rules (FeynArts banned), k2 eliminated
   via k2 = p + q - k1. Check 2 (gauge invariance) per channel, then
   M2g/M2PP, export to python/generated/Hqq_S12_LO_M2.py.
   Run: timeout 900 wolframscript -file mathematica/Hqq_S12_LO_traces.wls
        > mathematica/Hqq_S12_LO_traces.log 2>&1                            *)

$HistoryLength = 0;
<< FeynCalc`
Print["[1] FeynCalc loaded"];

SetDirectory["/home/physics/projects/AI_Assisted_SIDIS"];

(* ---------- kinematics: identical dictionary to Hqq_LO_traces.wls ------- *)
FCClearScalarProducts[];
u = -s - t - Q2;                       (* 2->2: s + t + u = -Q2 *)
SPD[p, p]   = 0;  SPD[k1, k1] = 0;  SPD[q, q] = -Q2;
SPD[p, q]   = (s + Q2)/2;              (* s  = (p+q)^2  = 2 p.q - Q2   *)
SPD[q, k1]  = -(t + Q2)/2;             (* t  = (q-k1)^2 = -Q2 - 2 q.k1 *)
SPD[p, k1]  = -u/2;                    (* u  = (p-k1)^2 = -2 p.k1      *)
(* k2 = p + q - k1 kept ATOMIC (FeynCalc spinors need a single momentum);
   its products fixed by momentum conservation:                          *)
SPD[k2, k2] = 0;
SPD[p, k2]  = (s + Q2 + u)/2;          (* p.k2 = p.q - p.k1            *)
SPD[q, k2]  = (s + t)/2;               (* q.k2 = p.q - Q2 - q.k1       *)
SPD[k1, k2] = s/2;                     (* (k1+k2)^2 = (p+q)^2 = s      *)
Print["[3] scalar products set"];

(* ================= channel gq: gamma* g(p) -> q(k1) qbar(k2) ============ *)
(* photon index mu, gluon index nu (incoming gluon, momentum p)
   diagram 1: photon on the k1 side, quark propagator (k1 - q), 1/t
   diagram 2: gluon on the k1 side,  quark propagator (k1 - p), 1/u
   couplings/colour (eq ee gs T^a) factored out; prefactor below          *)
ampGQ1 = SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[nu] .
         SpinorVD[k2]/t;
ampGQ2 = SpinorUBarD[k1] . GAD[nu] . (GSD[k1] - GSD[p]) . GAD[mu] .
         SpinorVD[k2]/u;
ampGQ  = ampGQ1 + ampGQ2;
Print["[4gq] amplitude built, leafcount ", LeafCount[ampGQ]];

(* check 2 in SQUARED form: k2 is atomic, so the Ward identity closes only
   through the scalar-product table -> trace |q.M|^2 (and |p.M|^2), must be 0 *)
gcQ  = Contract[FVD[q, mu] ampGQ];
gcQ2 = Simplify[DiracSimplify[Contract[
   (-MTD[nu, nu2]) FermionSpinSum[gcQ (ComplexConjugate[gcQ] /. nu -> nu2)]]]];
Print["[5gq] check 2 |q_mu M^mu|^2 (must be 0): ", gcQ2 // InputForm];
gcG  = Contract[FVD[p, nu] ampGQ];
gcG2sq = Simplify[DiracSimplify[Contract[
   (-MTD[mu, mu2]) FermionSpinSum[gcG (ComplexConjugate[gcG] /. mu -> mu2)]]]];
Print["[5gq] check 2 |p_nu M^nu|^2 (must be 0): ", gcG2sq // InputForm];
If[gcQ2 =!= 0 || gcG2sq =!= 0, Print["FATAL: gauge check gq failed"]; Quit[1]];

ampGQC = ComplexConjugate[ampGQ] /. {mu -> mu2, nu -> nu2};
ssGQ = MemoryConstrained[
   DiracSimplify[FermionSpinSum[ampGQ ampGQC]], 4*10^9];
Print["[6gq] spin sum + traces done, leafcount ", LeafCount[ssGQ]];
If[!FreeQ[ssGQ, Spinor], Print["FATAL: spinors left"]; Quit[1]];

colour = SUNSimplify[SUNTrace[SUNT[a, a]], SUNNToCACF -> False];
Print["[7] colour factor Tr[T^a T^a] = ", colour // InputForm];
(* averages, gq: 1/(SUNN^2-1) colour, 1/(2-2eps) gluon polarizations *)
prefGQ = eq^2 ee^2 gs^2 colour/((SUNN^2 - 1) (2 - 2 eps));

(* incoming-gluon polarization sum -> -g^{nu nu2} (valid: p_nu check = 0) *)
M2gGQ  = MemoryConstrained[Simplify[
   (Contract[MTD[mu, mu2] (-MTD[nu, nu2]) ssGQ] /. D -> 4 - 2 eps) prefGQ],
   4*10^9];
M2PPGQ = MemoryConstrained[Simplify[
   (Contract[FVD[p, mu] FVD[p, mu2] (-MTD[nu, nu2]) ssGQ] /.
      D -> 4 - 2 eps) prefGQ], 4*10^9];
Print["[8gq] M2g_gq  = ", M2gGQ // InputForm];
Print["[8gq] M2PP_gq = ", M2PPGQ // InputForm];
Print["[8gq] TeX M2g_gq:  ", ToString[TeXForm[M2gGQ]]];
Print["[8gq] TeX M2PP_gq: ", ToString[TeXForm[M2PPGQ]]];
If[!FreeQ[M2gGQ, LorentzIndex] || !FreeQ[M2gGQ, D],
   Print["FATAL: open index or D left in M2gGQ"]; Quit[1]];

(* ================= channel qg: gamma* q(p) -> g(k1) q(k2) =============== *)
(* same two diagrams as the qq channel, but the GLUON (k1, index nu) is the
   observed parton and the quark k2 = p + q - k1 is unobserved
   diagram 1: photon first, quark propagator (p + q), 1/s
   diagram 2: gluon first,  quark propagator (p - k1), 1/u               *)
ampQG1 = SpinorUBarD[k2] . GAD[nu] . (GSD[p] + GSD[q]) . GAD[mu] .
         SpinorUD[p]/s;
ampQG2 = SpinorUBarD[k2] . GAD[mu] . (GSD[p] - GSD[k1]) . GAD[nu] .
         SpinorUD[p]/u;
ampQG  = ampQG1 + ampQG2;
Print["[4qg] amplitude built, leafcount ", LeafCount[ampQG]];

gcQb  = Contract[FVD[q, mu] ampQG];
gcQb2 = Simplify[DiracSimplify[Contract[
   (-MTD[nu, nu2]) FermionSpinSum[gcQb (ComplexConjugate[gcQb] /. nu -> nu2)]]]];
Print["[5qg] check 2 |q_mu M^mu|^2 (must be 0): ", gcQb2 // InputForm];
gcGb  = Contract[FVD[k1, nu] ampQG];
gcGb2 = Simplify[DiracSimplify[Contract[
   (-MTD[mu, mu2]) FermionSpinSum[gcGb (ComplexConjugate[gcGb] /. mu -> mu2)]]]];
Print["[5qg] check 2 |k1_nu M^nu|^2 (must be 0): ", gcGb2 // InputForm];
If[gcQb2 =!= 0 || gcGb2 =!= 0, Print["FATAL: gauge check qg failed"]; Quit[1]];

ampQGC = ComplexConjugate[ampQG] /. {mu -> mu2, nu -> nu2};
ssQG = MemoryConstrained[
   DiracSimplify[FermionSpinSum[ampQG ampQGC]], 4*10^9];
Print["[6qg] spin sum + traces done, leafcount ", LeafCount[ssQG]];
If[!FreeQ[ssQG, Spinor], Print["FATAL: spinors left"]; Quit[1]];

(* averages, qg: 1/2 spin, 1/SUNN colour; final gluon summed (-g, valid) *)
prefQG = eq^2 ee^2 gs^2 colour/(2 SUNN);

M2gQG  = MemoryConstrained[Simplify[
   (Contract[MTD[mu, mu2] (-MTD[nu, nu2]) ssQG] /. D -> 4 - 2 eps) prefQG],
   4*10^9];
M2PPQG = MemoryConstrained[Simplify[
   (Contract[FVD[p, mu] FVD[p, mu2] (-MTD[nu, nu2]) ssQG] /.
      D -> 4 - 2 eps) prefQG], 4*10^9];
Print["[8qg] M2g_qg  = ", M2gQG // InputForm];
Print["[8qg] M2PP_qg = ", M2PPQG // InputForm];
Print["[8qg] TeX M2g_qg:  ", ToString[TeXForm[M2gQG]]];
Print["[8qg] TeX M2PP_qg: ", ToString[TeXForm[M2PPQG]]];
If[!FreeQ[M2gQG, LorentzIndex] || !FreeQ[M2gQG, D],
   Print["FATAL: open index or D left in M2gQG"]; Quit[1]];

(* ---------- save + export ---------- *)
Save["mathematica/Hqq_S12_LO_traces_steps.m", {M2gGQ, M2PPGQ, M2gQG, M2PPQG}];
pyStr[e_] := StringReplace[
   ToString[e /. SUNN -> Nc, InputForm, PageWidth -> Infinity], "^" -> "**"];
str = "# generated by mathematica/Hqq_S12_LO_traces.wls (S1/S2 prerequisite)\n" <>
  "# eps-exact LO squared amplitudes for the crossed channels of Eq. (46):\n" <>
  "#   gq: gamma* g -> q(k1) qbar, quark fragments (CTpdf, P0_gq)\n" <>
  "#   qg: gamma* q -> g(k1) q, gluon fragments (CTff, P0_qg)\n" <>
  "# n = 4 - 2 eps, spin/colour averaged (gluon avg 1/(2-2eps) in gq)\n" <>
  "# M2g: photon pol sum -> +g^{mu nu}; M2PP: -> p^mu p^nu\n" <>
  "from sympy import sympify\n" <>
  "M2g_gq  = sympify('" <> pyStr[M2gGQ]  <> "')\n" <>
  "M2PP_gq = sympify('" <> pyStr[M2PPGQ] <> "')\n" <>
  "M2g_qg  = sympify('" <> pyStr[M2gQG]  <> "')\n" <>
  "M2PP_qg = sympify('" <> pyStr[M2PPQG] <> "')\n";
Export["python/generated/Hqq_S12_LO_M2.py", str, "Text"];
Print["[11] exported -> python/generated/Hqq_S12_LO_M2.py"];
Print["DONE"];

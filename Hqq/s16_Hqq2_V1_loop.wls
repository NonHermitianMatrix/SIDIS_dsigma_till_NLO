(* Hqq2_V1_loop.wls -- Hqq REBUILD, step V1: the VIRTUAL graph Hqq;g.

   This is the fourth and last graph set of Table I row 2:
       virtual : Hqq;g   (one loop on gamma* q -> q g)
       real    : Hqq;gg + Hqq;q qbar + Hqq;q' qbar'   (the three R1 scripts)

   DELIBERATE REUSE, stated openly.  The real-emission pieces were rewritten
   from scratch because the suspected fault was in their CHARGE/FLAVOUR
   bookkeeping (eq vs eqp, the nf-1 weight, the identical-quark exchange) --
   and rewriting them found three genuine transcription errors that the
   gauge checks caught.  The VIRTUAL has no such bookkeeping: it carries one
   charge, no flavour sum, and its only nf is the quark loop.  It was also
   EXONERATED by direct measurement (d(V)/dnf/LO identical in both
   projections, STATE 0z.92), and its nf part was later shown to be exactly
   proportional to the eps-EXACT LO in both projections (STATE 0z.109).
   Rewriting a verified loop calculation from scratch would risk NEW
   transcription errors for no expected gain, so this is the same
   calculation re-run under the new naming (SUNN -> Nc) and exported to the
   Hqq2 namespace.  If the rebuild's real pieces later disagree with it, the
   virtual gets rewritten too.

   Reduction: TID -> PaXEvaluateUVIRSplit (prefactor 1/(2Pi)^D), poles in
   EpsilonUV/EpsilonIR, unified to eps only in sympy (reference section 7).
*)


$HistoryLength = 0;
$LoadAddOns = {"FeynHelpers"};
<< FeynCalc`
If[!ValueQ[$FeynHelpersDirectory],
  Print["FATAL: FeynHelpers failed to load"]; Quit[1]];
Print["[1] FeynCalc + FeynHelpers loaded"];

SetDirectory["/home/physics/projects/AI_Assisted_SIDIS"];

(* ---------- pinned-convention test (AI.md sec. 7): must match closed form *)
b0pin = PaXEvaluate[B0[s, 0, 0], PaXImplicitPrefactor -> 1];
b0ref = 2 + 1/Epsilon - EulerGamma + Log[-ScaleMu^2/(Pi s)];
Print["[2] B0 pin test (0 expected): ", Simplify[b0pin - b0ref] // InputForm];

(* ---------- kinematics ---------- *)
FCClearScalarProducts[];
u = -s - t - Q2;
SPD[p, p] = 0; SPD[k1, k1] = 0; SPD[q, q] = -Q2;
SPD[p, q] = (s + Q2)/2; SPD[q, k1] = -(t + Q2)/2; SPD[p, k1] = -u/2;
k2rule = {k2 -> p + q - k1};
SPD[k2, k2] = 0; SPD[p, k2] = (s + t + Q2)/2 // Expand;
SPD[q, k2] = (s - t)/2 - Q2/2 + Q2/2 // Expand;  (* recompute below *)
FCClearScalarProducts[];
SPD[p, p] = 0; SPD[k1, k1] = 0; SPD[q, q] = -Q2;
SPD[p, q] = (s + Q2)/2; SPD[q, k1] = -(t + Q2)/2; SPD[p, k1] = -u/2;
(* k2 = p+q-k1 derived dots *)
SPD[p, k2]  = SPD[p, q] - SPD[p, k1] // Expand;
SPD[q, k2]  = SPD[q, q] + SPD[p, q] - SPD[q, k1] // Expand;
SPD[k1, k2] = SPD[p, k1] + SPD[q, k1] // Expand;
Print["[3] scalar products set; s+t+u+Q2 = 0 with u = ", u];

(* ---------- tree (conventions of Hqq_LO_traces.wls; colour SUNT[a]) ------ *)
treeD[mu_, nu_] := SUNT[a] (
   SpinorUBarD[k1] . GAD[nu] . (GSD[p] + GSD[q]) . GAD[mu] . SpinorUD[p]/s +
   SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[nu] . SpinorUD[p]/t);

(* ---------- one-loop diagrams (loop momentum l) ---------- *)
(* quark line chains read against fermion flow: ubar(k1) ... u(p).
   Loop gluon adjoint index b; external gluon a, Lorentz nu.  1/s, 1/t
   tree propagators explicit; loop propagators via FAD.                  *)
tgv[{ka_, al_}, {kb_, be_}, {kc_, ga_}] :=   (* all momenta incoming *)
  MTD[al, be] FVD[ka - kb, ga] + MTD[be, ga] FVD[kb - kc, al] +
  MTD[ga, al] FVD[kc - ka, be];

diags = <||>;
(* --- T1 dressings (photon first, 1/s) --- *)
diags["D1"] = {SUNT[a] . SUNT[b] . SUNT[b],
  SpinorUBarD[k1] . GAD[nu] . (GSD[p] + GSD[q]) . GAD[rho] .
    (GSD[p] + GSD[q] - GSD[l]) . GAD[mu] . (GSD[p] - GSD[l]) . GAD[rho] .
    SpinorUD[p]/s,
  FAD[l, {l - p}, {l - p - q}]};
diags["D2"] = {SUNT[b] . SUNT[a] . SUNT[b],
  SpinorUBarD[k1] . GAD[rho] . (GSD[k1] - GSD[l]) . GAD[nu] .
    (GSD[p] + GSD[q] - GSD[l]) . GAD[rho] . (GSD[p] + GSD[q]) . GAD[mu] .
    SpinorUD[p]/s,
  FAD[l, {l - k1}, {l - p - q}]};
(* non-abelian triangle at emission vertex of T1: quark emits gluon c (mom
   l1 = l), gluon b (mom k2 - l) ... 3-gluon vertex with external a(k2):
   f^{abc} colour via SUNTF x SUNF; incoming momenta at vertex:
   a: -k2 (outgoing k2), b: k2 - l, c: l *)
diags["D3"] = {SUNF[a, b, c] SUNT[b] . SUNT[c] I,
  SpinorUBarD[k1] . GAD[be] . (GSD[p] + GSD[q] - GSD[l]) . GAD[ga] .
    (GSD[p] + GSD[q]) . GAD[mu] . SpinorUD[p]/s *
    tgv[{-(p + q - k1), nu}, {p + q - k1 - l, be2}, {l, ga2}] *
    MTD[be, be2] MTD[ga, ga2],
  FAD[l, {l - p - q + k1}, {l - p - q}]};
diags["D4"] = {SUNT[a] . SUNT[b] . SUNT[b],
  SpinorUBarD[k1] . GAD[nu] . (GSD[p] + GSD[q]) . GAD[rho] .
    (GSD[p] + GSD[q] - GSD[l]) . GAD[rho] . (GSD[p] + GSD[q]) . GAD[mu] .
    SpinorUD[p]/s^2,
  FAD[l, {l - p - q}]};
(* --- T2 dressings (gluon first, 1/t) --- *)
diags["D5"] = {SUNT[b] . SUNT[b] . SUNT[a],
  SpinorUBarD[k1] . GAD[rho] . (GSD[k1] - GSD[l]) . GAD[mu] .
    (GSD[k1] - GSD[q] - GSD[l]) . GAD[rho] . (GSD[k1] - GSD[q]) . GAD[nu] .
    SpinorUD[p]/t,
  FAD[l, {l - k1}, {l - k1 + q}]};
diags["D6"] = {SUNT[b] . SUNT[a] . SUNT[b],
  SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[rho] .
    (GSD[k1] - GSD[q] - GSD[l]) . GAD[nu] . (GSD[p] - GSD[l]) . GAD[rho] .
    SpinorUD[p]/t,
  FAD[l, {l - p}, {l - k1 + q}]};
diags["D7"] = {SUNF[a, b, c] SUNT[b] . SUNT[c] I,
  SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[be] .
    (GSD[p] - GSD[l]) . GAD[ga] . SpinorUD[p]/t *
    tgv[{-k2, nu}, {k2 - l, be2}, {l, ga2}] MTD[be, be2] MTD[ga, ga2] /.
    k2rule,
  FAD[l, {l - k2}, {l - p}] /. k2rule /. k2 -> p + q - k1};
(* wait: D7 loop props: gluon l (from p-leg), gluon k2-l (to 3g vertex),
   internal quark p - l.  Corrected FAD below (overwrite): *)
diags["D7"] = {SUNF[a, b, c] SUNT[b] . SUNT[c] I,
  SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[be] .
    (GSD[p] - GSD[l]) . GAD[ga] . SpinorUD[p]/t *
    tgv[{-(p + q - k1), nu}, {p + q - k1 - l, be2}, {l, ga2}] *
    MTD[be, be2] MTD[ga, ga2],
  FAD[l, {l - p - q + k1}, {l - p}]};
diags["D8"] = {SUNT[b] . SUNT[b] . SUNT[a],
  SpinorUBarD[k1] . GAD[mu] . (GSD[k1] - GSD[q]) . GAD[rho] .
    (GSD[k1] - GSD[q] - GSD[l]) . GAD[rho] . (GSD[k1] - GSD[q]) . GAD[nu] .
    SpinorUD[p]/t^2,
  FAD[l, {l - k1 + q}]};
(* --- boxes: loop gluon between external quark legs --- *)
(* D9: along internal quark line photon then gluon:
   p -> (p-l) -> (p+q-l) -> (k1-l)=(p+q-k2-l) -> k1 *)
diags["D9"] = {SUNT[b] . SUNT[a] . SUNT[b],
  SpinorUBarD[k1] . GAD[rho] . (GSD[k1] - GSD[l]) . GAD[nu] .
    (GSD[p] + GSD[q] - GSD[l]) . GAD[mu] . (GSD[p] - GSD[l]) . GAD[rho] .
    SpinorUD[p],
  FAD[l, {l - p}, {l - p - q}, {l - k1}]};
(* D10: gluon then photon along the internal line:
   p -> (p-l) -> (p-k2-l)=(k1-q-l) -> (k1-l) -> k1 *)
diags["D10"] = {SUNT[b] . SUNT[a] . SUNT[b] /. {},
  SpinorUBarD[k1] . GAD[rho] . (GSD[k1] - GSD[l]) . GAD[mu] .
    (GSD[k1] - GSD[q] - GSD[l]) . GAD[nu] . (GSD[p] - GSD[l]) . GAD[rho] .
    SpinorUD[p],
  FAD[l, {l - p}, {l - k1 + q}, {l - k1}]};
(* D10 colour: emissions along line: rho(b) ... mu ... nu(a) ... rho(b):
   order against flow: T^b T^a T^b as well?  chain = T^b (gluon at k1 end)
   T^a (external gluon) T^b (gluon at p end): yes T^b.T^a.T^b *)
(* D11: box with 3-gluon vertex: quark line p -> (p-l) -> (p+q-l) -> k1
   emits gluon (k2 + l - ...)? momenta: quark emits loop gluon l at p end,
   photon, then gluon (p+q-l-k1) = (k2 - l) which fuses with l at the
   3-gluon vertex into external a(k2). *)
diags["D11"] = {SUNF[a, b, c] SUNT[b] . SUNT[c] I,
  SpinorUBarD[k1] . GAD[be] . (GSD[p] + GSD[q] - GSD[l]) . GAD[mu] .
    (GSD[p] - GSD[l]) . GAD[ga] . SpinorUD[p] *
    tgv[{-(p + q - k1), nu}, {p + q - k1 - l, be2}, {l, ga2}] *
    MTD[be, be2] MTD[ga, ga2],
  FAD[l, {l - p}, {l - p - q}, {l - p - q + k1}]};
Print["[4] ", Length[diags], " loop diagrams typed"];

(* ---------- interference with tree, three projections, per diagram ------- *)
projs = <|"qq" -> FVD[q, mu] FVD[q, mu2], "g" -> MTD[mu, mu2],
          "pp" -> FVD[p, mu] FVD[p, mu2],
          "qp" -> FVD[q, mu] FVD[p, mu2]|>;
(* NOTE: "qq" vanishes per diagram because the TREE side is gauge
   invariant -- it does not test the loop.  "qp" contracts q into the
   LOOP index only: each diagram is nonzero, and ONLY the 11-diagram sum
   must vanish -- that is the true loop-transcription gauge check.      *)
treeC = ComplexConjugate[treeD[mu, nu]] /. {mu -> mu2, nu -> nu2,
   SUNT[a] -> SUNT[a]};
results = <||>;
Do[
  {col, chain, prop} = diags[dk];
  Do[
    core = MemoryConstrained[DiracSimplify[FermionSpinSum[
       chain (treeC /. a -> a) ]], 6*10^9];
    core = Contract[projs[pj] (-MTD[nu, nu2]) core];
    core = FCCanonicalizeDummyIndices[core];
    colf = SUNSimplify[col . SUNT[a] // SUNTrace, SUNNToCACF -> False];
    amp = colf core prop;
    red = MemoryConstrained[TID[amp, l, ToPaVe -> True], 6*10^9];
    pax = MemoryConstrained[PaXEvaluateUVIRSplit[red, l,
       PaXImplicitPrefactor -> 1/(2 Pi)^D], 6*10^9];
    results[dk <> "_" <> pj] = pax;
    Print["[5] ", dk, " proj ", pj, " done, leafcount ", LeafCount[pax]];
    DumpSave["mathematica/Hqq_V1_ck.mx", results];
  , {pj, Keys[projs]}];
, {dk, Keys[diags]}];

(* ---------- gauge checks ---------- *)
gc = Simplify[Total[results[# <> "_qq"] & /@ Keys[diags]]];
Print["[6] qq projection sum (trivially 0, tree-side Ward): ",
  gc // InputForm];
gcqp = Simplify[Total[results[# <> "_qp"] & /@ Keys[diags]]];
Print["[6b] CHECK 2, loop side: qp projection sum (must be 0): ",
  gcqp // InputForm];
Print["[6c] qp nonzero per diagram (sanity, must be False): ",
  FreeQ[results["D1_qp"], B0 | C0 | D0] && results["D1_qp"] === 0];

(* ---------- assemble raw virtG, virtPP (x 2Re at the sympy stage) -------- *)
virtGraw  = Total[results[# <> "_g"]  & /@ Keys[diags]];
virtPPraw = Total[results[# <> "_pp"] & /@ Keys[diags]];
Print["[7] virtG leafcount ", LeafCount[virtGraw],
      "  virtPP leafcount ", LeafCount[virtPPraw]];

(* ---------- export (D -> 4 - 2 eps guard) ---------- *)
xp[e_] := Module[{f = e /. D -> 4 - 2 eps /. SUNN -> Nc},
  If[!FreeQ[f, D], Print["FATAL: stray D"]; Quit[1]];
  StringReplace[ToString[f, InputForm, PageWidth -> Infinity],
    "^" -> "**"]];
str = "# generated by mathematica/Hqq2_V1_loop.wls (V1 raw)\n" <>
 "# 2->2 one-loop x tree interference, gamma* q -> q g, BEFORE the 2Re\n" <>
 "# and BEFORE UV renormalization; poles in EpsilonUV/EpsilonIR symbols\n" <>
 "# (unify to eps ONLY in sympy per AI.md sec. 7); scale in ScaleMu.\n" <>
 "from sympy import sympify\n" <>
 "virtGraw  = sympify('" <> xp[virtGraw] <> "')\n" <>
 "virtPPraw = sympify('" <> xp[virtPPraw] <> "')\n";
Export["python/generated/Hqq2_V1_raw.py", str, "Text"];
Print["[8] exported -> python/generated/Hqq2_V1_raw.py"];
Print["DONE"];

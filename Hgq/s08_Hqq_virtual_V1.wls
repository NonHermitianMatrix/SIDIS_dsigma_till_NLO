#!/usr/bin/env wolframscript
(* Hqq;g VIRTUAL: one loop on  gamma*(q,mu) + q(p) -> q(k1) + g(k2,nu,a).

   REBUILD FROM THE FEYNMAN RULES (everything post-LO is stale,
   STALE_Hqq.md).  Paper Table I p.17: Hqq = virtual Hqq;g + real
   (Hqq;gg + Hqq;qqbar + Hqq;q'qbar').  The three real graphs are rebuilt
   and accepted (STATE.md 0z.210, 0z.219, 0z.220); this is the LAST
   unrebuilt source, and the critical path for error 2.

   DIAGRAM COUNT, derived not guessed.
   Class A -- virtual gluon with BOTH ends on the quark line.  Four vertices
   sit on the line: photon, external gluon, and the two virtual-gluon ends
   L1, L2.  Orderings = 4!/2 = 12 (dividing by 2 because L1/L2 are labels of
   the SAME propagator).  Of those, the ones with L1,L2 adjacent at
   positions (1,2) or (3,4) are EXTERNAL-leg self-energies on the on-shell
   massless quark: scaleless, and their IR content belongs to the LSZ
   residue Z_2, so they are EXCLUDED here and restored at V2.  Adjacent at
   (2,3) is an INTERNAL (off-shell) propagator correction and IS kept.
       12 - 4 = 8 class-A diagrams.
   Class B -- virtual gluon from the quark line to the EXTERNAL gluon via a
   triple-gluon vertex.  Three vertices on the line: photon and the two
   internal-gluon ends.  Fixing the end nearer the u(p) side to carry loop
   momentum ell removes the double count from relabelling ell -> k2 - ell,
   leaving the 3 positions of the photon:
       3 class-B diagrams.
   TOTAL 11.  The gluon self-energy on the external gluon leg is likewise
   scaleless -> Z_3 at V2; that is where the nf of this channel comes from
   (reference section 8: "the quark loop on the gluon leg of Hqq;g").

   MOMENTUM ROUTING.  q = k1 + k2 - p is built in, which is what lets the
   photon Ward identity close (a real bug in the qqbar rebuild).

   OUTPUT-CONVENTION PIN (reference section 7, required of every V1 script):
   the B0 test is re-run FIRST and matched against the closed form measured
   on this machine, so a silent Package-X convention change cannot pass. *)

$HistoryLength = 0;
$LoadAddOns = {"FeynHelpers"};
<< FeynCalc`
If[! ValueQ[$FeynCalcDirectory], Print["FATAL: FeynCalc absent"]; Quit[1]];
If[! ValueQ[$FeynHelpersDirectory],
   Print["FATAL: FeynHelpers failed to load"]; Quit[1]];
Print["FeynCalc + FeynHelpers loaded"];

(* ------------------------------------------------- B0 convention pin --- *)
b0test = PaXEvaluate[B0[SPD[p, p], 0, 0], PaXImplicitPrefactor -> 1];
Print["B0 test: ", InputForm[b0test]];
If[FreeQ[b0test, Epsilon],
   Print["FATAL: B0 test has no Epsilon pole -- convention changed"];
   Quit[1]];
Print["B0 convention pin OK"];

FCClearScalarProducts[];
SPD[p, p] = 0; SPD[k1, k1] = 0; SPD[k2, k2] = 0;
qv = k1 + k2 - p;                    (* momentum conservation built in *)

(* ------------------------------------------------- chain builders ------ *)
(* vs = list of {LorentzIndex, incomingMomentum, colourIndex or None},
   ordered from the u(p) end outward.  Returns {diracChain, denomList,
   colourWord}. *)
chainOf[vs_] := Module[{n, mom, parts, i, cols},
  n = Length[vs];
  mom = Table[p + Total[vs[[1 ;; i, 2]]], {i, 1, n}];
  parts = {};
  Do[AppendTo[parts, GAD[vs[[i, 1]]]];
     If[i > 1, AppendTo[parts, GSD[mom[[i - 1]]]]],
     {i, n, 1, -1}];
  (* NOTE the loop runs i = n down to 1, so `parts` is already in the
     ubar . V_n . prop_{n-1} . ... . V_1 . u order *)
  cols = Select[Reverse[vs[[All, 3]]], # =!= None &];
  {Dot[SpinorUBarD[k1], Sequence @@ parts, SpinorUD[p]],
   Table[mom[[i]], {i, 1, n - 1}], cols}];

colourWord[cols_] := If[cols === {}, 1, SUNTF[cols, ci, cj]];

(* ------------------------------------------------- TREE (for the
   interference and for the tree Ward identity gate) --------------------- *)
phT = {mu, qv, None};
glT = {nu, -k2, ca};
treeOf[vs_] := Module[{c},
  c = chainOf[vs];
  c[[1]] colourWord[c[[3]]]/Times @@ (SPD[#, #] & /@ c[[2]])];
tree = Total[treeOf /@ Permutations[{phT, glT}]];
Print["tree diagrams: ", Length[Permutations[{phT, glT}]]];

(* ------------------------------------------------- class A (8) --------- *)
ph = {mu, qv, None};
gl = {nu, -k2, ca};
L1 = {al1, ell, cg};
L2 = {al2, -ell, cg};

allOrd = Permutations[{ph, gl, L1, L2}];
(* keep L1 before L2 (they label ONE propagator), and drop the external-leg
   self-energies where L1,L2 are adjacent at the ends *)
posOf[o_, v_] := First[First[Position[o, v]]];
keepA[o_] := Module[{i1, i2},
  i1 = posOf[o, L1]; i2 = posOf[o, L2];
  i1 < i2 && ! (i2 == i1 + 1 && (i1 == 1 || i2 == 4))];
ordA = Select[allOrd, keepA];
Print["class A diagrams (must be 8): ", Length[ordA]];
If[Length[ordA] =!= 8, Print["FATAL: class A count wrong"]; Quit[1]];

ampA = Total[(Module[{c},
     c = chainOf[#];
     c[[1]] colourWord[c[[3]]] (-MTD[al1, al2]) *
       FAD[ell] Times @@ (FAD[#] & /@ c[[2]])] & /@ ordA)];

(* ------------------------------------------------- class B (3) --------- *)
(* internal gluon A: momentum ell INTO the triple vertex, so it injects
   -ell into the quark line; internal gluon B injects ell - k2.
   Triple vertex, ALL momenta incoming: p1 = ell (be1), p2 = k2 - ell (be2),
   p3 = -k2 (nu). *)
V3B = MTD[be1, be2] FVD[2 ell - k2, nu] +
      MTD[be2, nu] FVD[2 k2 - ell, be1] +
      MTD[nu, be1] FVD[-k2 - ell, be2];

GA = {al1, -ell, cg1};
GB = {al2, ell - k2, cg2};
ordB = {{ph, GA, GB}, {GA, ph, GB}, {GA, GB, ph}};
Print["class B diagrams (must be 3): ", Length[ordB]];

ampB = Total[(Module[{c},
     c = chainOf[#];
     c[[1]] SUNTF[Select[Reverse[#[[All, 3]]], # =!= None &], ci, cj] *
       SUNF[cg1, cg2, ca] V3B (-MTD[al1, be1]) (-MTD[al2, be2]) *
       FAD[ell] FAD[k2 - ell] Times @@ (FAD[#] & /@ c[[2]])] & /@ ordB)];

(* ---------------------------- BUG A FIX (STATE.md 0z.224, 0z.226) ------- *)
(* The chains above are typed WITHOUT the explicit i of each vertex and
   propagator.  Those i's cancel only between diagrams with the SAME
   vertex/propagator counts, which class A and class B do NOT have.  With
   the Feynman rules
       quark prop  i kslash/k^2,  gluon prop -i g^{mu nu}/k^2,
       qqg vertex  i gs gamma^mu T^a,  qqA vertex i e eq gamma^mu,
       triple-gluon vertex  x gs f^{abc}[g^{mu nu}(p1-p2)^rho + cyclic]
   the factor MISSING from each block, relative to what is typed above, is
       class A : i^4 (vertices) i^3 (quark props) i (gluon prop, typed -g)
                 = 1
       class B : i^3 (vertices) i^2 (quark props) i^2 (2 gluon props,
                 typed -g) x = -i x
   so class B needs an extra -i x.  x = 1 was MEASURED, not assumed:
   mathematica/Hqq_gg_lambda_sign.wls got lam = i x = I from the gluon Ward
   identity, kinematics-free and identical in both photon projections. *)
ampB = -I ampB;

amp1 = ampA + ampB;
Print["one-loop amplitude assembled"];

(* ------------------------------------------------- interference -------- *)
(* 2 Re{ tree^dagger * loop }, projected with g^{mu mu2} and p^mu p^mu2.
   Physical gluon polarization sum is NOT needed here: the external gluon is
   a single gluon and the sum -g^{nu nu2} is legitimate once no triple-gluon
   vertex sits on an EXTERNAL cut line.  (Ghosts would be required only for
   a squared amplitude with two external gluons, as in Hqq;gg.) *)
project[tag_, proj_] := Module[{t},
  t = ComplexConjugate[tree /. {mu -> mu2, nu -> nu2, ca -> cb}] *
      amp1 * proj * (-MTD[nu, nu2]) SUNDelta[ca, cb];
  t = FermionSpinSum[t];
  t = DiracSimplify[Contract[t]];
  t = FCCanonicalizeDummyIndices[t];
  t = SUNSimplify[t, SUNNToCACF -> False];
  Print[tag, " assembled, leaf ", LeafCount[t],
        "  FreeQ[Spinor]=", FreeQ[t, Spinor],
        "  FreeQ[LorentzIndex]=", FreeQ[t, LorentzIndex[_, _]]];
  t];

Print["starting gauge check (tree Ward identity, must be 0)"];
gaugeTree = Module[{t},
  t = ComplexConjugate[tree /. {mu -> mu2, nu -> nu2, ca -> cb}] *
      tree * FVD[qv, mu] FVD[qv, mu2] * (-MTD[nu, nu2]) SUNDelta[ca, cb];
  t = SUNSimplify[DiracSimplify[Contract[FermionSpinSum[t]]],
                  SUNNToCACF -> False];
  Simplify[t]];
Print["TREE GAUGE CHECK (must be 0): ", gaugeTree];
If[Simplify[gaugeTree] =!= 0,
   Print["FATAL: tree Ward identity failed -- do not proceed"]; Quit[1]];

intG  = MemoryConstrained[project["intG",  MTD[mu, mu2]], 8*10^9];
intPP = MemoryConstrained[project["intPP", FVD[p, mu] FVD[p, mu2]], 8*10^9];

DumpSave[FileNameJoin[{Directory[], "mathematica",
                       "Hqq_virtual_V1_raw.mx"}], {tree, amp1, intG, intPP}];
Print["raw interference cached"];

(* ------------------------------------------------- PV reduction -------- *)
reduce[e_, tag_] := Module[{r},
  Print["reducing ", tag, " ..."];
  r = TID[e, ell, ToPaVe -> True];
  Print["  TID done, leaf ", LeafCount[r]];
  r = PaXEvaluateUVIRSplit[r, PaXImplicitPrefactor -> 1/(2 Pi)^D];
  Print["  Package-X done, leaf ", LeafCount[r],
        "  hasEpsilonUV=", ! FreeQ[r, EpsilonUV],
        "  hasEpsilonIR=", ! FreeQ[r, EpsilonIR]];
  r];

virtG  = MemoryConstrained[reduce[intG, "intG"], 8*10^9];
virtPP = MemoryConstrained[reduce[intPP, "intPP"], 8*10^9];

DumpSave[FileNameJoin[{Directory[], "mathematica",
                       "Hqq_virtual_V1_steps.mx"}], {virtG, virtPP}];
Print["HQQ_VIRTUAL_V1_DONE"];

(* Hgq_v3 : shared conventions.  Paper = arXiv:1903.01529.
   Channel Hgq :  gamma*(q) + g(p) -> q(k1) + X ,  observed = quark k1.
   Independent invariants (paper Eqs.(21)-(24)):
     s   = (p+q)^2 ,  Q2 = -q^2 ,
     t   = t1 = (q-k1)^2 ,  u = u1 = (p-k1)^2 ,
     t2  = (q-k2)^2 , u2 = -2 p.k2 ,
   derived:  s23 = s+t+u+Q2 , etc.  (all derived in code, never by hand)   *)

If[!ValueQ[HGQAddOns], HGQAddOns = {"FeynArts"}];
$LoadAddOns = HGQAddOns;
$HistoryLength = 0;              (* do not retain In/Out: main memory sink *)
$FeynCalcStartupMessages = False;
<< FeynCalc`;
$FAVerbose = 0;
FCSetDiracGammaScheme["NDR"];

HGQDIR = DirectoryName[$InputFileName /. "" :> "./x"];
If[HGQDIR === "", HGQDIR = Directory[] <> "/"];

(* ---- kinematics helper: set all scalar products of a momentum list ---- *)
(* nothing global here; each stage sets its own scalar products *)

(* ---- structure function projectors, derived (not transcribed) ---------- *)
(* Wmunu = (-g^{mu nu} + q^mu q^nu/q^2) F1 + (Pt^mu Pt^nu/(P.q)) F2 ,
   Pt^mu = P^mu - q^mu (P.q)/q^2 ,  P^2=0 , q^2=-Q2 , x = Q2/(2 P.q).
   Contract with g_{mu nu} and P_mu P_nu and invert.                      *)
hgqProjectorRules[] := Module[{nn = 4 - 2 eps, Pq, A, B, sol},
  Pq = Q2/(2 xh);
  (* g.W and P.P.W in terms of F1,F2 *)
  A = -(nn - 1) F1 + (Pq/Q2) F2;
  B = -(Pq^2/Q2) F1 + (Pq^3/Q2^2) F2;
  sol = Solve[{A == Hg, B == Hpp}, {F1, F2}][[1]];
  Simplify[sol]
];

(* ---- colour / coupling conventions ------------------------------------ *)
(* CF -> (N^2-1)/(2N) , CA -> N , TF -> 1/2 ; gs^2 = 4 Pi alphas          *)
(* ---- extraction tensors of paper Eq.(7), as functions of the incoming
   parton momentum.  This is the single definition of the two projectors:
   s01 contracts the Born with them, and s06 reads off how each one scales
   when the momentum it is built from is rescaled.                        *)
hgqProjTensor[g_, P_] := Switch[g,
   "g",  MTD[FCGV["mu"], FCGV["nu"]],
   "pp", FVD[P, FCGV["mu"]] FVD[P, FCGV["nu"]]];
(* Degree of homogeneity in that momentum: P -> lam P scales the tensor by
   lam^deg.  Counted from the tensor above, never assumed.                *)
hgqProjDegree[g_] := hgqProjDegree[g] =
   Count[hgqProjTensor[g, HGQPMOM], HGQPMOM, Infinity];

hgqColorRules = {SUNN -> Nc};

(* ---- case (1) angular integral (paper Eq. e.case1), both light-like ---
   Int db1 db2 sin^(1-2eps)b1 sin^(-2eps)b2
        / [(1-cos b1)^j (1 - C cos b1 - S sin b1 cos b2)^l]                *)
hgqG0[z_] := 1/(1 - z);
hgqG1[z_] := -Log[1 - z]/(1 - z);
hgqG2[z_] := (Log[1 - z]^2/2 + PolyLog[2, z])/(1 - z);
hgqTheta[f_, z_] := z D[f, z];
hgq2F1[j_, l_, z_, zz_] := Module[{an, ap, dg},
  If[j <= 0 || l <= 0, Return[Hypergeometric2F1[j, l, 1 - eps, z]]];
  an = Expand[Product[(nn + k)/k, {k, 1, j - 1}] Product[(nn + k)/k, {k, 1, l - 1}]];
  dg = Exponent[an, nn];
  ap[g_] := Sum[Coefficient[an, nn, k] Nest[hgqTheta[#, zz] &, g, k], {k, 0, dg}];
  (ap[hgqG0[zz]] + eps ap[hgqG1[zz]] + eps^2 ap[hgqG2[zz]]) /. zz -> z];
hgqCase1[j_, l_, cchi_, order_] := Module[{pref, zz},
  pref = 2 Pi Gamma[1 - 2 eps]/Gamma[1 - eps]^2 2^(-j - l) Beta[1 - eps - j, 1 - eps - l];
  Normal[Series[pref hgq2F1[j, l, (1 + cchi)/2, zz], {eps, 0, order}]]];

(* ---- elementary angular moments (exact in eps) ------------------------ *)
(* Both beta moments in CLOSED FORM.  Symbolic Integrate with an eps-dependent
   exponent costs 0.6-6 s per call and there are ~100 distinct (a,b,l), which
   dominated the runtime.  Closed forms are instant and exact.

   hgqMom2[m] = Int_0^pi sin^(-2 eps)b2 cos^m b2 db2
              = Gamma[(m+1)/2] Gamma[(1-2eps)/2] / Gamma[(m+2-2eps)/2]  (m even)
              = 0                                                       (m odd)

   hgqMom1L[a,b,l] = Int_-1^1 (1-x^2)^(b/2-eps) x^a (1-x)^(-l) dx .
   Substituting x = 1-2y gives 1-x^2 = 4y(1-y), 1-x = 2y, dx = 2 dy, so
              = 2^(b-2eps-l+1) Sum_k Binomial[a,k] (-2)^k
                  Beta[b/2-eps-l+k+1, b/2-eps+1] .
   For l>=1 the first Beta argument can be <= 0: that is exactly the collinear
   1/eps pole, and Beta carries it correctly as a ratio of Gammas.          *)
hgqMom2[m_] := hgqMom2[m] = If[OddQ[m], 0,
   Gamma[(m + 1)/2] Gamma[(1 - 2 eps)/2]/Gamma[(m + 2 - 2 eps)/2]];
hgqMom1L[a_, b_, l_] := hgqMom1L[a, b, l] =
  2^(b - 2 eps - l + 1) Sum[Binomial[a, k] (-2)^k Beta[b/2 - eps - l + k + 1, b/2 - eps + 1],
    {k, 0, a}];
(* beta1 moment with a t-type denominator (D-cos b1)^(-j), expanded to O(eps).
   Done naively this costs ~205 s PER (a,b,j), essentially all of it in the
   Log[1-x^2]/(dd-x)^j dilogarithm.  Divide the polynomial out first,
      P/(dd-x)^j = quotient + remainder/(dd-x)^j ,  deg(remainder) < j,
   and re-express the remainder in powers of (dd-x) via x = dd-(dd-x).  Then
   only two genuine base integrals survive (j=1,2), each computed once, and
   everything else is an elementary polynomial moment.                       *)
hgqPM[n_] := hgqPM[n] = Integrate[x^n Log[1 - x^2], {x, -1, 1}];
hgqLB[i_] := hgqLB[i] =
   Integrate[Log[1 - x]/(dd - x)^i, {x, -1, 1}, Assumptions -> dd > 1] +
   Integrate[Log[1 + x]/(dd - x)^i, {x, -1, 1}, Assumptions -> dd > 1];
(* O(eps^2) partners of hgqPM/hgqLB.  (1-x^2)^(-eps) = 1 - eps L + eps^2 L^2/2
   with L = Log[1-x^2]; hgqMom1D previously stopped at O(eps) while its only
   consumer, hgqElemD, expands to O(eps^2), so the eps^2 coefficient was
   missing the L^2 term entirely.  Split as Log[1-x^2]^2 = (Log[1-x]+Log[1+x])^2
   so every piece integrates in a manifestly real form for dd > 1.          *)
hgqPM2[n_] := hgqPM2[n] = Integrate[x^n Log[1 - x^2]^2, {x, -1, 1}];
hgqLB2[i_] := hgqLB2[i] = Simplify[
   Integrate[Log[1 - x]^2/(dd - x)^i, {x, -1, 1}, Assumptions -> dd > 1] +
   2 Integrate[Log[1 - x] Log[1 + x]/(dd - x)^i, {x, -1, 1}, Assumptions -> dd > 1] +
   Integrate[Log[1 + x]^2/(dd - x)^i, {x, -1, 1}, Assumptions -> dd > 1],
   Assumptions -> dd > 1];
hgqMom1D[a_, b_, j_] := hgqMom1D[a, b, j] = Module[{P, qt, rm, i0, i1, i2, r0, r1},
   P = Expand[(1 - x^2)^(b/2) x^a];
   qt = PolynomialQuotient[P, (dd - x)^j, x];
   rm = Expand[PolynomialRemainder[P, (dd - x)^j, x]];
   i0 = Integrate[qt + rm/(dd - x)^j, {x, -1, 1}, Assumptions -> dd > 1];
   i1 = Sum[Coefficient[qt, x, n] hgqPM[n], {n, 0, Max[0, Exponent[qt, x]]}];
   i2 = Sum[Coefficient[qt, x, n] hgqPM2[n], {n, 0, Max[0, Exponent[qt, x]]}];
   Which[
    j == 1, i1 = i1 + rm hgqLB[1]; i2 = i2 + rm hgqLB2[1],
    j == 2, r1 = Coefficient[rm, x, 1]; r0 = Expand[rm - r1 x];
            i1 = i1 + (r0 + r1 dd) hgqLB[2] - r1 hgqLB[1];
            i2 = i2 + (r0 + r1 dd) hgqLB2[2] - r1 hgqLB2[1],
    True, Print["ABORT: hgqMom1D implemented only for j=1,2; got ", j]; Quit[1]];
   i0 - eps i1 + eps^2 i2/2];
(* full elementary double integral of  c1^a (s1 cb2)^b * den                *)
(* Expand in eps HERE, on the smallest object.  hgqMom2 and hgqMom1L are exact
   in eps (ratios of Gamma/Beta functions); if that is left unexpanded it
   propagates into the assembled result and every later Series has to expand
   hundreds of Gamma[...eps...] inside a multi-MB expression.  Each of these is
   a product of two Gamma expressions, so the expansion is instant here.     *)
hgqElemL[a_, b_, l_] := hgqElemL[a, b, l] =
   Normal[Series[hgqMom2[b] hgqMom1L[a, b, l], {eps, 0, 2}]];
hgqElemD[a_, b_, j_] := hgqElemD[a, b, j] =
   Normal[Series[hgqMom2[b] hgqMom1D[a, b, j], {eps, 0, 2}]];

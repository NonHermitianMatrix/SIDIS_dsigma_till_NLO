#!/usr/bin/env wolframscript
(* s03 : angular integral library for the 2->3 phase space (paper App. B, F).
   Master integral (paper Eq. e.case2 / e.int_gen):
     II[j,l](D,C) = Int_0^pi db1 Int_0^pi db2  sin^(1-2eps)b1 sin^(-2eps)b2
                    / [ (D-cos b1)^j (1 - C cos b1 - S sin b1 cos b2)^l ] , S=Sqrt[1-C^2]
   Case (1)  D=1 (both denominators light-like) : closed form, paper Eq. e.case1.
   Case (2)  D>1 : paper Appendix F table (transcribed from the arXiv LaTeX source).
   Every entry is validated here: numerically where the integral converges,
   and through the exact relations  d/dD I[j,l] = -j I[j+1,l].                *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];

(* ================= case (2): Appendix F table ======================== *)
cF = cc^2 (1 - 3 dd^2) + 4 cc dd + dd^2 - 3;
cG = cc^2 (3 dd^2 - 1) - 4 cc dd - dd^2 + 3;
cL = Log[(dd + 1)/(dd - 1)];
cK = PolyLog[2, 2/(dd + 1)] - PolyLog[2, -2/(dd - 1)];
lg16 = Log[(1/16) (dd - 1) (dd + 1)^3];
li2p = PolyLog[2, (dd - 1)/(dd + 1)];

tab[1, -4] = (Pi/72 (-630 cc^4 dd^3 + 330 cc^4 dd + 1440 cc^3 dd^2 - 384 cc^3 + 540 cc^2 dd^3 - 1764 cc^2 dd
     + 9 (cc^4 (35 dd^4 - 30 dd^2 + 3) + 16 cc^3 dd (3 - 5 dd^2) - 6 cc^2 (5 dd^4 - 18 dd^2 + 5)
        + 16 cc dd (3 dd^2 - 5) + 3 dd^4 - 30 dd^2 + 35) cL
     - 864 cc dd^2 + 1152 cc - 54 dd^3 + 522 dd)
   + Pi eps/72 (-1773 cc^4 dd^3 + 943 cc^4 dd + 3744 cc^3 dd^2 - 1024 cc^3 + 1674 cc^2 dd^3
     + 27/2 (cc^2 - 1) (dd^2 - 1) (cc^2 (19 dd^2 - 3) - 32 cc dd - 3 dd^2 + 19) cL
     - 4398 cc^2 dd + 9 (cc^4 (35 dd^4 - 30 dd^2 + 3) + 16 cc^3 dd (3 - 5 dd^2)
        - 6 cc^2 (5 dd^4 - 18 dd^2 + 5) + 16 cc dd (3 dd^2 - 5) + 3 dd^4 - 30 dd^2 + 35) cK
     - 2592 cc dd^2 + 2688 cc - 189 dd^3 + 1599 dd));

tab[2, -4] = (Pi/(3 (dd^2 - 1)) (36 cc (3 - 5 cc^2) dd^3 + 12 cc (13 cc^2 - 11) dd
     + 3 (35 cc^4 - 30 cc^2 + 3) dd^4 + (-115 cc^4 + 222 cc^2 - 51) dd^2 + 16 (cc^4 - 6 cc^2 + 3))
   + 1/2 Pi (5 cc^4 dd (3 - 7 dd^2) + 12 cc^3 (5 dd^2 - 1) + 6 cc^2 dd (5 dd^2 - 9)
     + 4 cc (5 - 9 dd^2) - 3 dd (dd^2 - 5)) cL
   + Pi eps/18 (72 (21 - 29 cc^2) cc dd + 32 (39 - 8 cc^2) cc^2 + 54 (27 cc^4 - 26 cc^2 + 3) dd^2
     - 9 (5 cc^4 dd (7 dd^2 - 3) + cc^3 (12 - 60 dd^2) + 6 cc^2 dd (9 - 5 dd^2)
        + 4 cc (9 dd^2 - 5) + 3 dd (dd^2 - 5)) cK - 528)
   + Pi eps/(2 (dd^2 - 1)) (cc^4 (-11 dd^4 + 30 dd^2 - 15) dd - 4 cc^3 (dd^4 + 6 dd^2 - 3)
     + 6 cc^2 (3 dd^4 - 2 dd^2 + 3) dd - 4 cc (3 dd^4 - 2 dd^2 + 3) - 3 dd^5 + 6 dd^3 + dd) cL);

tab[1, -3] = (Pi (5 cc^3 dd^2 - 4/3 cc^3 - 1/2 (cc dd - 1) (5 cc^2 dd^2 - 3 cc^2 - 4 cc dd - 3 dd^2 + 5) cL
     - 9 cc^2 dd - 3 cc dd^2 + 8 cc + 3 dd)
   + Pi eps (-1/2 (cc dd - 1) (cc^2 (5 dd^2 - 3) - 4 cc dd - 3 dd^2 + 5) cK
     + 1/9 (117 cc^3 dd^2 - 32 cc^3 - 27/2 (cc dd - 1) (cc^2 dd^2 - cc^2 - dd^2 + 1) cL
        - 189 cc^2 dd - 81 cc dd^2 + 156 cc + 81 dd)));

tab[2, -3] = (3/2 Pi (cc (cc^2 (5 dd^2 - 1) - 6 cc dd - 3 dd^2 + 3) + 2 dd) cL
   + Pi (cc^3 dd (13 - 15 dd^2) + 6 cc^2 (3 dd^2 - 2) + 3 cc dd (3 dd^2 - 5) - 6 dd^2 + 8)/(dd^2 - 1)
   + Pi eps/2 (-58 cc^3 dd + 3 (cc (cc^2 (5 dd^2 - 1) - 6 cc dd - 3 dd^2 + 3) + 2 dd) cK
     + 48 cc^2 + 42 cc dd - 24));

tab[-2, -2] = (4 Pi/15 (cc^2 + 10 cc dd + 10 dd^2 + 3) + 4 Pi/225 eps (46 cc^2 + 400 cc dd + 325 dd^2 + 123));
tab[-1, -2] = (4 Pi/3 (cc + 2 dd) + eps Pi/9 (32 cc + 52 dd));
tab[1, -2] = (Pi (dd - 3 cc^2 dd + 4 cc - 1/2 cF cL)
   + eps Pi (-1/4 cG cL lg16 - 1/2 cL (-cc^2 dd^2 + cc^2 + dd^2 - 1)
     + 1/6 Pi^2 (cc^2 (3 dd^2 - 1) - 4 cc dd - dd^2 + 3) + (cc (8 - 7 cc dd) + 3 dd) - cG li2p));
tab[2, -2] = (Pi (cc^2 (6 dd^2 - 4) - (dd^2 - 1) (cc (3 cc dd - 2) - dd) cL - 4 cc dd - 2 dd^2 + 4)/(dd^2 - 1)
   + Pi eps (4 (2 cc^2 + dd (cc dd - 1)^2 cL/(2 (dd^2 - 1)) - 1) - (cc (3 cc dd - 2) - dd) cK));
tab[-2, -1] = (2 Pi/3 (2 cc dd + 3 dd^2 + 1) + eps Pi (32 cc dd/9 + 4 dd^2 + 16/9));
tab[-1, -1] = (2 Pi (cc/3 + dd) + eps Pi (16 cc/9 + 4 dd));
tab[-2, 0] = (2 Pi (dd^2 + 1/3) + 4 Pi eps (dd^2 + 4/9));
tab[-1, 0] = (2 Pi dd + 4 Pi dd eps);
tab[1, 0] = (Pi cL + eps Pi cK);
tab[2, 0] = (2 Pi/(dd^2 - 1) + eps 2 Pi dd cL/(dd^2 - 1));
tab[1, -1] = (Pi (-(cc dd - 1) cL + 2 cc)
   + Pi eps (4 cc - Pi^2/3 (cc dd - 1) + 1/2 (cc dd - 1) cL lg16 + 2 (cc dd - 1) li2p));
tab[2, -1] = (-Pi (-cc (dd^2 - 1) cL + 2 cc dd - 2)/(dd^2 - 1)
   + eps Pi ((-cL (cc (dd^2 - 1) lg16 + 4 dd (cc dd - 1)))/(2 (dd^2 - 1)) + Pi^2/3 cc - 2 cc li2p));
tab[-2, 1] = (-Pi (cc - dd)^2/eps + Pi (-3 cc^2 + 4 cc dd + 1) + eps Pi (-7 cc^2 + 8 cc dd + 3));
tab[-1, 1] = (Pi (cc - dd)/eps + 2 Pi cc + 4 eps Pi cc);
tab[1, 1] = (Pi/(eps (cc - dd)) + Pi Log[(dd^2 - 1)/(dd - cc)^2]/(cc - dd)
   + 2 Pi eps/(cc - dd) (PolyLog[2, (cc - 1)/(dd - 1)] - PolyLog[2, (dd - cc)/(dd + 1)]
     + Log[cc + 1] Log[(dd + 1)/(dd - cc)] + Log[dd - cc] Log[(dd - cc)/(dd - 1)]
     - 1/4 cL Log[(dd - 1) (dd + 1)^3] + Pi^2/6));
tab[2, 1] = (-Pi/(eps (dd - cc)^2)
   + Pi ((dd^2 - 1) Log[(dd - cc)^2/(dd^2 - 1)] - 2 cc dd + 2)/((dd^2 - 1) (cc - dd)^2)
   + 2 Pi eps (PolyLog[2, (dd - cc)/(dd + 1)] - PolyLog[2, (cc - 1)/(dd - 1)])/(cc - dd)^2
   - Pi eps/(6 (dd^2 - 1) (cc - dd)^2) (
       12 Log[dd + 1] ((dd^2 - 1) Log[cc + 1] + cc + dd^2 - dd - 1)
     - 12 Log[dd - 1] ((dd^2 - 1) Log[dd - cc] + cc - dd^2 - dd + 1)
     + (dd^2 - 1) (2 (6 Log[dd - cc] (Log[(dd - cc)/(cc + 1)] - 2) + Pi^2)
        - 3 cL Log[(dd - 1) (dd + 1)^3])));
tab[-2, 2] = (Pi/eps (3 cc^2 - 2 cc dd - 1) + Pi (3 cc^2 + 2 cc dd - dd^2 - 2) + eps Pi (9 cc^2 - 2 cc dd + dd^2 - 4));
tab[-1, 2] = (-Pi cc/eps + Pi (cc - dd) + eps Pi (dd - cc));
(* the paper does not quote the O(eps) term of I(1,2) and I(2,2); it is
   carried as a symbol and the final answer must not depend on it       *)
tab[1, 2] = (Pi/eps (1 - cc dd)/(cc - dd)^3
   + Pi/(cc - dd)^3 (-cc^2 - 2 cc dd + dd^2 + 2 + (cc dd - 1) Log[(dd - cc)^2/(dd^2 - 1)])
   + eps MISSINGEPS[1, 2]);
tab[2, 2] = (Pi/eps (cc^2 + 2 cc dd - 3)/(cc - dd)^4
   + Pi/((dd^2 - 1) (cc - dd)^4) (cc^2 (7 dd^2 - 5)
     + (dd^2 - 1) (cc^2 + 2 cc dd - 3) Log[(dd^2 - 1)/(dd - cc)^2]
     + 2 (dd^2 - 3) cc dd - dd^2 (dd^2 + 5) + 8)
   + eps MISSINGEPS[2, 2]);

known = {{1,-4},{2,-4},{1,-3},{2,-3},{-2,-2},{-1,-2},{1,-2},{2,-2},{-2,-1},{-1,-1},
         {-2,0},{-1,0},{1,0},{2,0},{1,-1},{2,-1},{-2,1},{-1,1},{1,1},{2,1},
         {-2,2},{-1,2},{1,2},{2,2}};

(* ---- I[0,l] is case (1) with j=0 (the D factor is absent) ------------ *)
case2[0, l_] := hgqCase1[0, l, cc, 2];
case2[j_, l_] := If[MemberQ[known, {j, l}], tab[j, l],
   Message[case2::miss, j, l]; Abort[]];

(* ================= validation ======================================== *)
numII[j_, l_, dv_, cv_, ev_] := Module[{sv = Sqrt[1 - cv^2], x0},
  x0 = ArcCos[cv];
  NIntegrate[
   Sin[b1]^(1 - 2 ev) Sin[b2]^(-2 ev) (dv - Cos[b1])^(-j)
     (1 - cv Cos[b1] - sv Sin[b1] Cos[b2])^(-l),
   {b1, 0, x0, Pi}, {b2, 0, Pi}, PrecisionGoal -> 8, MaxRecursion -> 30,
   Method -> {"GlobalAdaptive", "SymbolicProcessing" -> 0}]];

dv = 17/10; cv = 3/10;
Print["[s03] --- numerical validation of the case-2 table (D=1.7, C=0.3) ---"];
Do[Module[{jj = e[[1]], ll = e[[2]], f, e1, e2, r1, r2, ev1, ev2},
   If[ll >= 2, Print["  I[", jj, ",", ll, "]  : not numerically testable (non-integrable), skipped"];
    Continue[]];
   {ev1, ev2} = If[ll >= 1, {-1/50, -1/100}, {1/50, 1/100}];
   f = tab[jj, ll] /. {cc -> cv, dd -> dv};
   r1 = numII[jj, ll, N[dv, 30], N[cv, 30], N[ev1, 30]];
   r2 = numII[jj, ll, N[dv, 30], N[cv, 30], N[ev2, 30]];
   e1 = N[(f /. eps -> ev1) - r1, 10]; e2 = N[(f /. eps -> ev2) - r2, 10];
   Print["  I[", jj, ",", ll, "]  resid(eps=", N[ev1], ")=", ScientificForm[e1, 3],
     "  resid(eps=", N[ev2], ")=", ScientificForm[e2, 3],
     "  ratio=", If[Abs[e2] > 0, N[e1/e2, 4], "-"], "  (expect ~4)"];
   ], {e, known}];

Print["[s03] --- exact relation  d/dD I[j,l] = -j I[j+1,l]  (D=1.7,C=0.3) ---"];
Do[Module[{jj = e[[1]], ll = e[[2]], lhs, rhs, ordr},
   ordr = If[ll >= 1, 0, 1];
   If[jj == -1, rhs = hgqCase1[0, ll, cc, 2],
    If[MemberQ[known, {jj + 1, ll}], rhs = -jj (tab[jj + 1, ll] /. MISSINGEPS[__] -> 0), Continue[]]];
   lhs = D[tab[jj, ll] /. MISSINGEPS[__] -> 0, dd];
   Print["  j=", jj, " l=", ll, " -> ",
     Chop[N[Normal[Series[lhs - rhs, {eps, 0, ordr}]] /. {cc -> 3/10, dd -> 17/10}, 20], 10^-12]];
   ], {e, known}];

Put[<|"tab" -> Association[Table[e -> tab[e[[1]], e[[2]]], {e, known}]],
     "known" -> known|>,
  FileNameJoin[{DirectoryName[$InputFileName], "s03_result.m"}]];
Print["[s03] done"];

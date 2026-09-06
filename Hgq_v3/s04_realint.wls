#!/usr/bin/env wolframscript
(* s04 : Appendix-D partial fractioning + Appendix-B frames + angular integration
   of the real 2->3 squared amplitudes produced by s02.
   Output: {P_Gamma Whatt^(3)}_unsub  as a function of (s,t,u,Q2), eps-expanded. *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
selfTestOnly = (Environment["HGQ_SELFTEST"] === "1");
s02r = If[FileExistsQ[FileNameJoin[{dir, "s02_result.m"}]],
   Get[FileNameJoin[{dir, "s02_result.m"}]], <||>];
s03r = Get[FileNameJoin[{dir, "s03_result.m"}]];
tab = s03r["tab"];

(* --- only I(1,1) and I(1,2) are taken from the paper's Appendix F table;
       I(2,l) is DERIVED from the exact relation  d/dD I(j,l) = -j I(j+1,l)
       because the tabulated I(2,l) entries fail that relation (see s03).   *)
Itab[1, l_] := tab[{1, l}];
Itab[2, l_] := -D[tab[{1, l}], dd];

s23e = s + t + u + Q2;
admv = <|"t2" -> t2, "t3" -> u - t2 - s23e - Q2, "u2" -> u2, "u3" -> t - u2 - s23e,
   "s12" -> -s23e - t2 - u2 - Q2, "s13" -> s + t2 + u2 + Q2|>;
admvType = <|"t2" -> "t", "t3" -> "t", "u2" -> "u", "u3" -> "u", "s12" -> "s", "s13" -> "s"|>;
names = Keys[admv];

If[KeyExistsQ[s02r, "derived"],
  chk = Simplify[{admv["s13"] - s02r["derived"]["s13"], admv["u3"] - s02r["derived"]["u3"],
     admv["t3"] - s02r["derived"]["t3"], admv["s12"] - s02r["derived"]["s12"]}];
  Print["[s04] ADMV definitions vs s02 (must be {0,0,0,0}): ", chk];
  If[Union[chk] =!= {0}, Print["ABORT"]; Quit[1]]];

(* ================= frames (paper App. B) ============================== *)
sq = Sqrt[s23e];
p0 = (s23e - t)/(2 sq); q0 = (s + t)/(2 sq); k10 = (s - s23e)/(2 sq); qp = Sqrt[q0^2 + Q2];
cpq = (p0 q0 - (s + Q2)/2)/(p0 qp);          (* cos angle(p,q)   *)
ckq = (k10 q0 + (Q2 + t)/2)/(k10 qp);        (* cos angle(k1,q)  *)
cpk = 1 + u/(2 p0 k10);                      (* cos angle(p,k1)  *)
sOf[c_] := Sqrt[1 - c^2];
dot4[a_, b_] := a[[1]] b[[1]] - a[[2]] b[[2]] - a[[3]] b[[3]];
K23 = {sq, 0, 0};
k2v = (sq/2) {1, s1 cb2, c1}; k3v = (sq/2) {1, -s1 cb2, -c1};

fv["F1"] = Module[{k1x = k10 {1, 0, 1}, px = p0 {1, sOf[cpk], cpk}},
   <|"k1" -> k1x, "p" -> px, "q" -> k1x + K23 - px|>];
fv["F2"] = Module[{px = p0 {1, 0, 1}, k1x = k10 {1, sOf[cpk], cpk}},
   <|"p" -> px, "k1" -> k1x, "q" -> k1x + K23 - px|>];
fv["F3"] = Module[{qx = {q0, 0, qp}, k1x = k10 {1, sOf[ckq], ckq}},
   <|"q" -> qx, "k1" -> k1x, "p" -> k1x + K23 - qx|>];

frameOK = Simplify[Table[{dot4[fv[f]["p"], fv[f]["p"]], dot4[fv[f]["k1"], fv[f]["k1"]],
     dot4[fv[f]["q"], fv[f]["q"]] + Q2,
     2 dot4[fv[f]["p"], fv[f]["q"]] - (s + Q2),
     2 dot4[fv[f]["q"], fv[f]["k1"]] + Q2 + t,
     2 dot4[fv[f]["p"], fv[f]["k1"]] + u}, {f, {"F1", "F2", "F3"}}]];
Print["[s04] frame on-shell/invariant checks (all 0): ", frameOK];
If[Union[Flatten[frameOK]] =!= {0}, Print["ABORT frames"]; Quit[1]];

admvAng[f_] := admvAng[f] = <|
   "t2" -> -Q2 - 2 dot4[fv[f]["q"], k2v], "t3" -> -Q2 - 2 dot4[fv[f]["q"], k3v],
   "u2" -> -2 dot4[fv[f]["p"], k2v], "u3" -> -2 dot4[fv[f]["p"], k3v],
   "s12" -> 2 dot4[fv[f]["k1"], k2v], "s13" -> 2 dot4[fv[f]["k1"], k3v]|>;

(* decisive frame check: the six angular ADMVs must satisfy the same linear
   relations as the algebraic ones, identically in c1 and cb2               *)
frameRel = Table[
   Simplify[(Values[admv] /. {t2 -> admvAng[f]["t2"], u2 -> admvAng[f]["u2"]}) - Values[admvAng[f]]
     /. s1 -> Sqrt[1 - c1^2]], {f, {"F1", "F2", "F3"}}];
Print["[s04] frame ADMV-relation checks (all 0): ", frameRel];
If[Union[Flatten[frameRel]] =!= {0}, Print["ABORT frame relations"]; Quit[1]];

(* ================= Appendix-D partial fractioning ===================== *)
(* find a_i and constant c with Sum a_i ADMV_i == c , c != 0 *)
relFind[nm_] := Module[{fs, grad, ns, a, cv},
  fs = admv /@ nm;
  grad = Transpose[{Coefficient[#, t2], Coefficient[#, u2]} & /@ fs];
  ns = NullSpace[grad];
  Do[cv = Expand[a . fs]; If[cv =!= 0 && FreeQ[cv, t2 | u2], Return[{a, cv}, Module]], {a, ns}];
  Print["ABORT: no relation for ", nm]; Quit[1]];

offend[dens_] := Module[{nm = Keys[dens], byType},
  byType = GroupBy[nm, admvType[#] &];
  Do[If[Length[g] >= 2, Return[Take[g, 2], Module]], {g, Values[byType]}];
  If[Length[nm] >= 3, Return[Take[nm, 3], Module]];
  None];

(* drop one power of ADMV `nm` from the denominator association.  Append is the
   canonical key update for an Association; ReplacePart with a bare string key
   is NOT a position spec and would silently do nothing.                      *)
dropPower[dens_, nm_] := If[dens[nm] == 1, KeyDrop[dens, nm], Append[dens, nm -> dens[nm] - 1]];
degOf[dens_] := Total[Values[dens]];

reduceAll[terms_] := Module[{out = {}, work = terms, tt, sub, a, cv, nm, nd},
  While[work =!= {},
   tt = First[work]; work = Rest[work];
   sub = offend[tt[[2]]];
   If[sub === None, AppendTo[out, tt],
    {a, cv} = relFind[sub];
    Do[If[a[[i]] =!= 0,
      nm = sub[[i]];
      nd = dropPower[tt[[2]], nm];
      If[degOf[nd] >= degOf[tt[[2]]],
        Print["ABORT: reduceAll made no progress on ", nm, " in ", tt[[2]]]; Quit[1]];
      AppendTo[work, {Expand[a[[i]] tt[[1]]/cv], nd}]],
     {i, Length[sub]}]]];
  out];

(* split a rational function of (t2,u2) into {numerator polynomial, denominator assoc} *)
prepare[expr_] := Module[{tg, nu, de, fl, dens = <||>, pref = 1, nmatch},
  tg = Together[expr]; nu = Numerator[tg]; de = Denominator[tg];
  fl = FactorList[de];
  Do[Module[{f = fac[[1]], p = fac[[2]]},
    If[FreeQ[f, t2 | u2], pref *= f^p,
     nmatch = Select[names, FreeQ[Simplify[f/admv[#]], t2 | u2] &];
     If[nmatch === {}, Print["ABORT: denominator factor is not an ADMV: ", f]; Quit[1]];
     pref *= Simplify[f/admv[First[nmatch]]]^p;
     dens[First[nmatch]] = Lookup[dens, First[nmatch], 0] + p]], {fac, fl}];
  {Expand[nu/pref], dens}];

(* ================= angular integration of one reduced term ============ *)
(* term: coefficient (polynomial in t2,u2) / (X^a Y^b), X,Y different types *)
pickPair[dens_] := Module[{nm = Keys[dens], X, Y},
  Which[
   Length[nm] == 2,
   If[admvType[nm[[1]]] === "t", {nm[[1]], nm[[2]]},
    If[admvType[nm[[2]]] === "t", {nm[[2]], nm[[1]]},
     If[admvType[nm[[1]]] === "s", {nm[[1]], nm[[2]]}, {nm[[2]], nm[[1]]}]]],
   Length[nm] == 1,
   Switch[admvType[nm[[1]]], "t", {nm[[1]], "u2"}, "u", {nm[[1]], "s12"}, "s", {nm[[1]], "u2"}],
   True, {"s12", "u2"}]];

frameFor[Xn_] := Switch[admvType[Xn], "t", "F3", "s", "F1", "u", "F2"];

(* decompose an angular expression into A0 + A1 c1 + A2 s1 cb2 *)
decomp[e_] := Module[{ex = Expand[e]},
  {ex /. {c1 -> 0, cb2 -> 0}, Coefficient[ex, c1], Coefficient[Coefficient[ex, cb2], s1]}];

(* frame data for a pair (X,Y): computed once per pair, not per (j,l) term. *)
frameData[Xn_, Yn_, which_] := frameData[Xn, Yn, which] = Module[
   {f, Xa, Ya, A, B, flip, out},
   f = frameFor[If[which === "X", Xn, Yn]];
   Xa = admvAng[f][Xn]; Ya = admvAng[f][Yn];
   flip = MemberQ[{"t3", "u3", "s13"}, If[which === "X", Xn, Yn]];
   If[flip, Xa = Xa /. c1 -> -c1; Ya = Ya /. c1 -> -c1];
   A = decomp[Xa]; B = decomp[Ya];
   If[which === "X",
    If[Simplify[A[[3]]] =!= 0, Print["ABORT X not pure beta1 ", Xn, " ", Yn]; Quit[1]],
    If[Simplify[B[[3]]] =!= 0, Print["ABORT Y not pure beta1 ", Xn, " ", Yn]; Quit[1]]];
   (* squares of the s1*cb2 coefficients: rational, unlike the coefficients *)
   out = <|"Xa" -> Xa, "Ya" -> Ya, "A" -> A, "B" -> B,
           "a2sq" -> Together[Simplify[A[[3]]^2]], "b2sq" -> Together[Simplify[B[[3]]^2]]|>;
   If[which === "X",
    out["TT"] = A[[2]]; out["DD"] = Together[-A[[1]]/A[[2]]];
    out["kap"] = B[[1]]; out["CC"] = Together[-B[[2]]/B[[1]]],
    out["TT"] = B[[2]]; out["DD"] = Together[-B[[1]]/B[[2]]];
    out["kap"] = A[[1]]; out["CC"] = Together[-A[[2]]/A[[1]]]];
   out];

(* The angular integral is built with the frame data left SYMBOLIC:
     ddS, ccS  = D and cos(chi);   ttS, kapS = the two prefactors
     a0S,a1S,a2S / b0S,b1S,b2S = the decomposition of Xang / Yang.
   D and C are algebraic (they carry Sqrt[4 Q2 s23 + (s+t)^2]); substituting
   them into L=Log[(D+1)/(D-1)] and K=Li2[...] explodes the expression, so the
   substitution is done ONCE PER (X,Y) PAIR in doAll, not once per (j,l).     *)
angIntSym[j_, l_, Xn_, Yn_] := angIntSym[j, l, Xn, Yn] = Module[{ex, mons, res},
   If[j >= 1,
    If[admvType[Xn] === "t",
     If[l >= 1,
      res = (-ttS)^(-j) kapS^(-l) Itab[j, l] /. {dd -> ddS, cc -> ccS},
      ex = Expand[(1 - ccS c1 - SS s1 cb2)^(-l)];
      mons = CoefficientRules[ex, {c1, s1, cb2}];
      res = (-ttS)^(-j) kapS^(-l) Total[Table[
          (mr[[2]] /. SS -> Sqrt[1 - ccS^2]) (hgqElemD[mr[[1, 1]], mr[[1, 3]], j] /. dd -> ddS),
          {mr, mons}]]],
     res = a0S^(-j) kapS^(-l) hgqCase1[j, l, ccS, 2]],
    If[l >= 1,
     If[admvType[Yn] === "t",
      res = (-ttS)^(-l) kapS^(-j) Itab[l, j] /. {dd -> ddS, cc -> ccS},
      ex = Expand[(a0S + a1S c1 + a2S s1 cb2)^(-j)];
      mons = CoefficientRules[ex, {c1, s1, cb2}];
      res = b0S^(-l) Total[Table[
         mr[[2]] hgqElemL[mr[[1, 1]], mr[[1, 3]], l], {mr, mons}]]],
     ex = Expand[(a0S + a1S c1 + a2S s1 cb2)^(-j) (b0S + b1S c1 + b2S s1 cb2)^(-l)];
     mons = CoefficientRules[ex, {c1, s1, cb2}];
     res = Total[Table[mr[[2]] hgqElemL[mr[[1, 1]], mr[[1, 3]], 0], {mr, mons}]]]];
   res];

(* which of X,Y is the pure-beta1 factor: X when it sits in the denominator
   (j>=1), otherwise Y.  angIntSym above follows exactly this convention, so
   the frame substitution must be grouped by (X,Y,which), not by (X,Y).      *)
whichFor[j_, l_] := If[j >= 1, "X", "Y"];

frameSub[Xn_, Yn_, which_] := frameSub[Xn, Yn, which] = Module[{fd},
   fd = frameData[Xn, Yn, which];
   (* a2S,b2S multiply s1*cb2 and Int cos^n(beta2) vanishes for odd n, so only
      their EVEN powers survive.  The coefficients themselves are nested
      radicals (Sqrt[1-cos^2] with cos already containing Sqrt[...]), but their
      SQUARES are rational: substituting Sqrt[rational] keeps every surviving
      term rational and is what makes this step fast.                        *)
   {ddS -> fd["DD"], ccS -> fd["CC"], ttS -> fd["TT"], kapS -> fd["kap"],
    a0S -> fd["A"][[1]], a1S -> fd["A"][[2]], a2S -> Sqrt[fd["a2sq"]],
    b0S -> fd["B"][[1]], b1S -> fd["B"][[2]], b2S -> Sqrt[fd["b2sq"]]}];

xySol[X_, Y_] := xySol[X, Y] = Solve[{XX == admv[X], YY == admv[Y]}, {t2, u2}][[1]];

(* Return the term's contribution as a list of {key, rational coefficient},
   key = {j, l, Xname, Yname}.  Nothing transcendental is touched here.      *)
termKeys[{num_, dens_}] := Module[{X, Y, pX, pY, np, mons},
  {X, Y} = pickPair[dens];
  pX = Lookup[dens, X, 0]; pY = Lookup[dens, Y, 0];
  If[Length[dens] != Length[Intersection[Keys[dens], {X, Y}]],
   Print["ABORT: leftover denominators ", Keys[dens]]; Quit[1]];
  np = Expand[num /. xySol[X, Y]];
  mons = CoefficientRules[np, {XX, YY}];
  ({{pX - #[[1, 1]], pY - #[[1, 2]], X, Y}, #[[2]]} & /@ mons)];

(* split the numerator into monomials in (t2,u2) so reduceAll never carries a
   large numerator through the Appendix-D branching                         *)
splitMonomials[{num_, dens_}] := Module[{cr},
  cr = CoefficientRules[num, {t2, u2}];
  ({#[[2]] t2^#[[1, 1]] u2^#[[1, 2]], dens} & /@ cr)];

doAll[expr_, lbl_] := Module[{t0 = AbsoluteTime[], terms, red, acc, keys, res, byPair, np},
  terms = splitMonomials[prepare[expr]];
  If[Head[terms] =!= List || Length[terms] < 2,
    Print["ABORT: splitMonomials returned ", Head[terms], " of length ", Length[terms]];
    Quit[1]];
  Print["[s04] ", lbl, ": ", Length[terms], " numerator monomials"];
  red = reduceAll[terms];
  Print["[s04] ", lbl, ": ", Length[red], " reduced terms  (", Round[AbsoluteTime[] - t0], " s)"];
  (* group by angular integral: only ~tens of distinct ones exist, so sum the
     rational coefficients first and touch each transcendental integral once. *)
  acc = <||>;
  Do[Module[{kv}, kv = termKeys[tt];
     Do[acc[k[[1]]] = Lookup[acc, Key[k[[1]]], 0] + k[[2]], {k, kv}]], {tt, red}];
  keys = Keys[acc];
  Print["[s04] ", lbl, ": ", Length[keys], " distinct angular integrals  (",
    Round[AbsoluteTime[] - t0], " s)"];
  acc = AssociationMap[Together[acc[#]] &, keys];
  ClearSystemCache[];
  (* group by (X,Y): sum the cheap symbolic pieces first, then substitute the
     algebraic frame data once per pair (~12 pairs, not 195 integrals).      *)
  byPair = GroupBy[keys, {#[[3]], #[[4]], whichFor[#[[1]], #[[2]]]} &];
  Print["[s04] ", lbl, ": ", Length[byPair], " (X,Y,frame) groups"];
  res = 0; np = 0;
  Do[Module[{pr, part},
     pr = byPair[pk]; np++;
     part = Total[(acc[#] angIntSym[#[[1]], #[[2]], #[[3]], #[[4]]]) & /@ pr];
     part = part /. frameSub[pk[[1]], pk[[2]], pk[[3]]];
     (* No Series here: hgqElemL/hgqElemD are already eps-expanded at source,
        so `part` is a Laurent polynomial in eps.  Expanding the assembled
        group instead cost ~170 s each and reached 11 GB.                    *)
     res = res + part;
     Print["[s04] ", lbl, ": pair ", np, "/", Length[byPair], " ", pk,
       "  (", Length[pr], " integrals)  mem=", Round[MemoryInUse[]/1024^2], " MB"];
     ClearSystemCache[]],
   {pk, Keys[byPair]}];
  Print["[s04] ", lbl, ": angular integration done (", Round[AbsoluteTime[] - t0], " s)"];
  res];

(* the 2->3 phase space factor, derived and checked against paper Eq.(e.2to3ps) *)
nn = 4 - 2 eps;
dPi3 = (2 Pi)^(2 - nn) (1/8) (sq/2)^(nn - 4) (2 Pi^((nn - 3)/2)/Gamma[(nn - 3)/2]);
dPi3paper = s23e^(-eps) 2^(-2) Pi^(-eps)/(2 Pi)^(2 - 2 eps) Gamma[1 - eps]/Gamma[1 - 2 eps];
Print["[s04] dPi3 derivation vs paper Eq.(2to3ps) (must be 1): ",
  FullSimplify[dPi3/dPi3paper, Assumptions -> {s23e > 0, 0 < eps < 1/4}]];

(* self-test lives in s04_selftest_block.wl.bak; it passed (group A residuals
   all scaled as eps^2, ratio ~4.09) and is not re-run in production.      *)

memCap = 7*1024^3;
guard[e_, lbl_] := Module[{r},
   r = MemoryConstrained[e, memCap, $Failed];
   If[r === $Failed, Print["ABORT: memory limit exceeded in ", lbl]; Quit[1]];
   ClearSystemCache[]; r];
realMg = guard[doAll[s02r["Mg"], "Mg"], "Mg"];
Print["[s04] memory after Mg: ", Round[MemoryInUse[]/1024^2], " MB"];
realMpp = guard[doAll[s02r["Mpp"], "Mpp"], "Mpp"];
Print["[s04] memory after Mpp: ", Round[MemoryInUse[]/1024^2], " MB"];
pref = dPi3/(2 Pi)^4;
Put[<|"Wg3" -> pref realMg, "Wpp3" -> pref realMpp, "dPi3" -> dPi3|>,
  FileNameJoin[{dir, "s04_result.m"}]];
Print["[s04] done"];

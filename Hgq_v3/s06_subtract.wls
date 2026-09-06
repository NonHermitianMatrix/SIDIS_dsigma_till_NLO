#!/usr/bin/env wolframscript
(* s06 : MSbar collinear subtraction terms, paper Eq.(e.Wnextorder) [Eq.(46)]
     SUB = (alpha_s/4pi)(S_eps/eps) [  int dxi/xi   H^LO_{i'' q}(xh/xi, zh) P_{i''/g}(xi)
                                     + int dzt/zt^2 H^LO_{g j''}(xh, zh/zt) P_{q/j''}(zt) ]
   For Hgq (i'=g, j'=q) the surviving channels are
       i''=g : H^LO_gq  (x) P_gg        i''=q : H^LO_qq  (x) P_qg
       j''=q : H^LO_gq  (x) P_qq        j''=g : H^LO_gg = 0
   H^LO_{ij}(s,t,u) = (1/(2pi)^3) |M_Gamma|^2_{2->2} delta(s23) , s23 = s+t+u+Q2.
   All shifts of the Mandelstams under xi and zeta are DERIVED here from the
   definitions of xhat, zhat, k1T; nothing is transcribed.                     *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
s01r = Get[FileNameJoin[{dir, "s01_result.m"}]];

(* ---- Mandelstams <-> (xh, zh, kT2) : paper Eqs.(25)-(27) ------------- *)
sOf[xh_, zh_, kT2_] := Q2 (1 - xh)/xh;
uOf[xh_, zh_, kT2_] := -zh Q2/xh;
tOf[xh_, zh_, kT2_] := -Q2 + zh (Q2 - kT2/zh^2);
inv = Solve[{s == sOf[xh, zh, kT2], u == uOf[xh, zh, kT2], t == tOf[xh, zh, kT2]},
    {xh, zh, kT2}][[1]];
Print["[s06] (xh,zh,kT2) in terms of (s,t,u,Q2): ", Simplify[inv]];

(* initial-state shift  xh -> xh/xi  (zh, kT2 fixed) *)
shiftI[e_] := Simplify[e /. {s -> sOf[xh/xi, zh, kT2], t -> tOf[xh/xi, zh, kT2],
     u -> uOf[xh/xi, zh, kT2]} /. inv];
(* final-state shift  zh -> zh/zt , kT -> kT/zt *)
shiftF[e_] := Simplify[e /. {s -> sOf[xh, zh/zt, kT2/zt^2], t -> tOf[xh, zh/zt, kT2/zt^2],
     u -> uOf[xh, zh/zt, kT2/zt^2]} /. inv];

s23e = s + t + u + Q2;
s23I = shiftI[s23e]; s23F = shiftF[s23e];
Print["[s06] s23 after initial shift: ", Simplify[s23I]];
Print["[s06] s23 after final   shift: ", Simplify[s23F]];
xi0 = xi /. Solve[s23I == 0, xi][[1]];
zt0 = zt /. Solve[s23F == 0, zt][[1]];
jacI = Simplify[D[s23I, xi]]; jacF = Simplify[D[s23F, zt] /. zt -> zt0];
Print["[s06] xi0 = ", Simplify[xi0], "   1-xi0 = ", Simplify[1 - xi0], "   |ds23/dxi| = ", jacI];
Print["[s06] zt0 = ", Simplify[zt0], "   1-zt0 = ", Simplify[1 - zt0], "   |ds23/dzt| = ", Simplify[jacF]];

(* ---- one-loop splitting functions (paper Eqs.(51)-(53) + standard Pgg) - *)
CF = (Nc^2 - 1)/(2 Nc); CA = Nc; TF = 1/2;
Pqq = <|"reg" -> 2 CF (-1 - xx), "plus" -> 4 CF, "delta" -> 3 CF|>;
Pqg = <|"reg" -> 2 TF ((1 - xx)^2 + xx^2), "plus" -> 0, "delta" -> 0|>;
(* Pgg is the ONE splitting function the paper never gives (Eqs.(51)-(53) list
   only Pqq, Pqg, Pgq), so it is built here in the paper's own normalisation,
   which those three fix as P^(1) = 2 x textbook:
     Pgg^(1) = 4 CA [ xi/(1-xi)_+ + (1-xi)/xi + xi(1-xi) ] + beta0 delta(1-xi).
   Splitting the plus piece off requires xi/(1-xi)_+ = 1/(1-xi)_+ - 1, so the
   regular part carries a compensating -1.  Dropping that -1 is what left a
   1/eps in the reg sector that no other term could cancel.                  *)
Pgg = <|"reg" -> 4 CA ((1 - xx)/xx + xx (1 - xx) - 1), "plus" -> 4 CA,
        "delta" -> 11 CA/3 - 4 TF nf/3|>;
Print["[s06] splitting functions loaded (reg + plus/(1-x)_+ + delta * delta(1-x))"];
Print["[s06] projector degrees in the incoming momentum: g -> ", hgqProjDegree["g"], ", pp -> ", hgqProjDegree["pp"]];

(* ---- LO hard-part coefficients (delta(s23) stripped off) -------------- *)
loFac = 1/(2 Pi)^3;
LOgq = <|"g" -> loFac s01r["A"]["Hg"], "pp" -> loFac s01r["A"]["Hpp"]|>;  (* gamma* g -> q qbar *)
LOqq = <|"g" -> loFac s01r["B"]["Hg"], "pp" -> loFac s01r["B"]["Hpp"]|>;  (* gamma* q -> q g  *)

(* ---- the three subtraction convolutions, localised by delta(s23') -----
   Each returns <|"delta" -> coefficient of delta(s23),
                  "sing"  -> coefficient of the 1/(1-x)_+ structure,
                  "reg"   -> ordinary function of s23 |>                    *)
(* Projector weight.  H^Gamma = P_Gamma^{mu nu} What_{mu nu} with P built from
   the EXTERNAL parton momentum p, but the LO tables were contracted with the
   tensor built from the momentum of their own hard subprocess.  In the
   initial-state convolution that subprocess carries xi p, so its tabulated
   H^LO is (xi p)^mu (xi p)^nu W_{mu nu} and must be divided by xi^deg to give
   p^mu p^nu W_{mu nu}.  deg is read off the tensor itself (hgqProjDegree):
   0 for g^{mu nu}, 2 for p^mu p^nu - which is why only Gamma = pp was wrong.
   At xi = 1 the weight is 1, so the delta(1-xi) piece and the sig -> 0 limit
   of the plus piece (where xi0 -> 1) are untouched.
   subFinal needs no such weight: the final-state shift moves zh and kT, not
   the incoming momentum the projector is built from.                       *)
subInitial[LO_, P_, g_] := Module[{w = xi^(-hgqProjDegree[g])}, <|
   "delta" -> P["delta"] LO,
   "sing"  -> P["plus"] Simplify[(w shiftI[LO]/xi)/jacI /. xi -> xi0],
   "reg"   -> Simplify[((w shiftI[LO]/xi) (P["reg"] /. xx -> xi)/jacI) /. xi -> xi0]|>];
subFinal[LO_, P_] := <|
   "delta" -> P["delta"] LO,
   "sing"  -> P["plus"] Simplify[(shiftF[LO]/zt^2)/jacF /. zt -> zt0],
   "reg"   -> Simplify[((shiftF[LO]/zt^2) (P["reg"] /. xx -> zt)/jacF) /. zt -> zt0]|>;

res = Association[Table[
   g -> <|"I_gg" -> subInitial[LOgq[g], Pgg, g], "I_qg" -> subInitial[LOqq[g], Pqg, g],
          "F_qq" -> subFinal[LOgq[g], Pqq]|>, {g, {"g", "pp"}}]];

Put[<|"sub" -> res, "xi0" -> xi0, "zt0" -> zt0, "jacI" -> jacI, "jacF" -> Simplify[jacF],
   "inv" -> inv, "LOgq" -> LOgq, "LOqq" -> LOqq,
   "P" -> <|"qq" -> Pqq, "qg" -> Pqg, "gg" -> Pgg|>|>,
  FileNameJoin[{dir, "s06_result.m"}]];
Print["[s06] done"];

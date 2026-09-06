(* Term 148 is the alpha != 1 term (its log argument vanishes at sig->0).
   Measure its contribution to p1's 1/eps and del's 1/eps^2 in colour units.
   If its p1|_{1/eps}/unit = -4CA, then halving its delta-image (alpha=2)
   supplies exactly the +2CA that is missing.                                *)
dir = "/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v3/";
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
s01r = Get[dir <> "s01_result.m"];
i = 1;
pt = {s -> 7/2 + i/13, t -> -3/2 - i/17, Q2 -> 1 + i/11,
      u -> -(1 + i/11) - (7/2 + i/13) - (-3/2 - i/17), mu2 -> 2 + i/7,
      sig -> 1/3 + i/23, BB -> 5 + i/5, as -> 1/10, eq -> 1};
born = (1/(2 Pi)^3) (s01r["A"]["Hg"] /. gs^2 -> 4 Pi as /. eps -> 0 /. pt);
unit = (as/(4 Pi)) born /. pt;
a148 = Get[dir <> "s07part_Wg3_148_148.m"];
red[e_] := Normal[Series[(e /. gs -> Sqrt[4 Pi as] /. pt) ((mu2^eps Sfac)^2 /. pt), {eps, 0, 0}]];
d2 = Coefficient[red[a148["del"]], eps, -2];
p1c = Coefficient[red[a148["p"][[1]]], eps, -1];
CF = (Nc^2 - 1)/(2 Nc);
Print["term 148 alone:"];
Print["  del 1/eps^2 / unit = ", Simplify[d2/unit]];
Print["  p1  1/eps   / unit = ", Simplify[p1c/unit]];
Print["  identity del = -p1 ? ", Simplify[d2 + p1c] === 0];
Print["  reference: 4CA = ", 4 Nc, "  2CA = ", 2 Nc, "  4CF = ", Simplify[4 CF]];
Print["  at Nc=3 : del/unit = ", N[Simplify[d2/unit] /. Nc -> 3, 10],
      "   p1/unit = ", N[Simplify[p1c/unit] /. Nc -> 3, 10]];
Print["  >>> if alpha=2, del contribution halves; change = ",
      Simplify[-d2/2/unit], "  (need +2CA = ", 2 Nc, ")"];
Print["T16DONE"];

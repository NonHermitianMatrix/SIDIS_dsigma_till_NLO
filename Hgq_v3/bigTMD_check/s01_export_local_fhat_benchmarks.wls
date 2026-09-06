#!/usr/bin/env wolframscript
(* bigTMD_check/s01 : export this pipeline's Hgq hard parts at benchmark points
   for a DIRECT comparison against JeffersonLab/BigTMD, in the same form as
   Hqqbar/bigTMD_check (signed difference BigTMD-local, fixed tolerance, no
   fitted normalisation constant).

   CONVENTIONS taken from Hqqbar/bigTMD_check/local_fhat_benchmarks.json:
       Couplings  EL=1 and g_s=1   ==>  as = g_s^2/(4 Pi) = 1/(4 Pi),  eq = 1
       Scale      ScaleMu = Q      ==>  mu2 = Q2
       Colour     CA=3, CF=4/3, TF=1/2  ==>  Nc = 3
       BigTMD modules are called with g=1, gp=1 (charge-stripped, case A).
   Hgq is BigTMD channel 1; unlike Hqqbar's channel 5 it has ALL FOUR
   distribution coefficients, so all four are exported for both projectors and
   both structure functions.

   BENCHMARK CONSTRUCTION is Hqqbar's (s01:118-136), including the physical
   upper boundary of s23:
       xHat = xB/xi ,  pht2 = zH^2 qT2
       B    = Q2 (1/xHat - 1)(1 - zH) - pht2
       s23  = S23Fraction * B
       zHat = [(1-xHat) - xHat s23/Q2] / [(1-xHat) + xHat qT2/Q2]
       s    = (1-xHat) Q2/xHat ,  t = -(1-zHat) Q2 - zHat qT2
       zeta = zH/zHat
   No zeta-to-s23 Jacobian is applied on either side: this pipeline's hard part
   is already a distribution in s23, as BigTMD's fchn modules are.            *)
dir = DirectoryName[$InputFileName];
res = Get[FileNameJoin[{ParentDirectory[dir], "s08_result.m"}]];
Print["[bt-s01] loaded s08_result.m, keys: ", Keys[res]];

seeds = {
   <|"ID" -> "interior_1", "xB" -> 23/100, "xi" -> 61/100, "zH" -> 37/100,
     "Q2" -> 17, "qT2" -> 31/10, "S23Fraction" -> 2/5, "Nf" -> 4|>,
   <|"ID" -> "interior_2", "xB" -> 27/100, "xi" -> 67/100, "zH" -> 41/100,
     "Q2" -> 23, "qT2" -> 27/10, "S23Fraction" -> 7/20, "Nf" -> 4|>,
   <|"ID" -> "interior_3", "xB" -> 31/100, "xi" -> 71/100, "zH" -> 29/100,
     "Q2" -> 29, "qT2" -> 19/10, "S23Fraction" -> 11/20, "Nf" -> 4|>};

derive[sd_] := Module[{xhv, pht2, bv, s23v, den, com, zhv, sv, tv, zev, uv},
   xhv = sd["xB"]/sd["xi"];
   pht2 = sd["zH"]^2 sd["qT2"];
   bv = sd["Q2"] (1/xhv - 1) (1 - sd["zH"]) - pht2;
   s23v = sd["S23Fraction"] bv;
   den = (1 - xhv) - xhv s23v/sd["Q2"];
   com = (1 - xhv) + xhv sd["qT2"]/sd["Q2"];
   zhv = den/com;
   sv = (1 - xhv) sd["Q2"]/xhv;
   tv = -(1 - zhv) sd["Q2"] - zhv sd["qT2"];
   zev = sd["zH"]/zhv;
   uv = s23v - sv - tv - sd["Q2"];
   If[! (0 < xhv < 1 && bv > 0 && 0 < s23v < bv && 0 < zhv < 1 && 0 < zev < 1),
      Print["[bt-s01] ABORT: unphysical benchmark ", sd["ID"]]; Quit[1]];
   <|"ID" -> sd["ID"], "xHat" -> N[xhv, 30], "zH" -> N[sd["zH"], 30],
     "Q2" -> N[sd["Q2"], 30], "qT2" -> N[sd["qT2"], 30], "B" -> N[bv, 30],
     "S23Sample" -> N[s23v, 30], "s" -> N[sv, 30], "t" -> N[tv, 30],
     "u" -> N[uv, 30], "zHat" -> N[zhv, 30], "zeta" -> N[zev, 30],
     "Nf" -> sd["Nf"]|>];

pts = derive /@ seeds;
Do[Print["[bt-s01] ", p["ID"], "  s=", N[p["s"], 8], " t=", N[p["t"], 8],
   " B=", N[p["B"], 8], " s23=", N[p["S23Sample"], 8],
   " zHat=", N[p["zHat"], 8], " zeta=", N[p["zeta"], 8],
   " s+t=", N[p["s"] + p["t"], 8]], {p, pts}];

(* del multiplies delta(s23): evaluate it ON the s23=0 surface, u=-(Q2+s+t). *)
subs[p_, cmp_] := {s -> p["s"], t -> p["t"], Q2 -> p["Q2"],
   u -> If[cmp === "del", -(p["Q2"] + p["s"] + p["t"]), p["u"]],
   sig -> If[cmp === "del", 0, p["S23Sample"]],
   BB -> p["B"], mu2 -> p["Q2"], Nc -> 3, nf -> p["Nf"],
   as -> 1/(4 Pi), eq -> 1, xh -> p["xHat"], x -> p["xHat"], z -> p["zH"],
   zt -> p["zHat"], xi -> p["xHat"]};

sqrtFix = Sqrt[s^2 + 2 s t + t^2] -> (s + t);
val[e_, p_, lbl_] := Module[{v},
   If[! TrueQ[p["s"] + p["t"] > 0],
      Print["[bt-s01] ABORT: ", lbl, " s+t<=0, sqrtFix invalid"]; Quit[1]];
   (* Expand PolyGamma FIRST.  PolyGamma[0,1/2] == -EulerGamma - Log[4], so
      combinations like EulerGamma + Log[4] + PolyGamma[0,1/2] are identically
      zero; left unexpanded, N[] grinds against $MaxExtraPrecision trying to
      evaluate an exact zero and loses precision in the answer. *)
   v = e /. PolyGamma[a_, b_] :> FunctionExpand[PolyGamma[a, b]];
   (* wrap Logs BEFORE sqrtFix so a vanishing argument cannot become Log[0] *)
   v = v /. Log[a_] :> logS[a];
   v = (v /. sqrtFix) /. subs[p, lbl[[2]]];
   v = v /. logS[a_] :> If[PossibleZeroQ[a], LOGZERO, Log[a]];
   v = N[v, 30];
   If[! FreeQ[v, LOGZERO],
      Module[{c = Coefficient[v, LOGZERO]},
         If[! TrueQ[Abs[N[c, 30]] < 10^-20],
            Print["[bt-s01] ABORT: ", lbl, " Log[0] coefficient nonzero: ", N[c, 10]];
            Quit[1]];
         v = N[v /. LOGZERO -> 0, 30]]];
   With[{vv = v},
      If[! NumericQ[vv], Print["[bt-s01] ABORT: ", lbl, " non-numeric"]; Quit[1]];
      If[Abs[Im[vv]] > 10^-12 Max[1, Abs[Re[vv]]],
         Print["[bt-s01] ABORT: ", lbl, " complex ", vv]; Quit[1]];
      Re[vv]]];

out = Association @@ Table[
   p["ID"] -> Association @@ Table[
      key -> Association @@ Table[cmp -> val[res[key][cmp], p, {key, cmp}],
         {cmp, {"del", "reg", "p1", "p2"}}],
      {key, {"Hg", "Hpp", "F1hat", "F2hat"}}], {p, pts}];

Export[FileNameJoin[{dir, "local_fhat_benchmarks.json"}],
   <|"Status" -> "CompleteLocalHgqFHatBenchmarks",
     "Source" -> FileNameJoin[{ParentDirectory[dir], "s08_result.m"}],
     "Conventions" -> <|
        "Couplings" -> "EL=1 and g_s=1 (as = g_s^2/(4 Pi) = 1/(4 Pi), eq = 1)",
        "Color" -> "SU(3): CA=3, CF=4/3, TF=1/2",
        "Scale" -> "ScaleMu = Q",
        "BigTMDChannel" -> 1,
        "BigTMDChargeCases" -> {"A"},
        "BigTMDDistributionContent" -> "regular, plus1B, plus2B, delta",
        "LocalJacobianAlreadyIncluded" -> False,
        "JacobianPolicy" -> "no zeta-to-s23 Jacobian on either side",
        "DifferenceDirectionExpectedByS02" -> "BigTMD minus local"|>,
     "Benchmarks" -> pts, "LocalFHatByBenchmark" -> out|>, "JSON"];
Print["[bt-s01] wrote local_fhat_benchmarks.json"];
Print["[bt-s01] done"];

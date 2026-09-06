#!/usr/bin/env wolframscript
(* madgraph_check/s02b : evaluate Hgq_v3's Mg, Mpp at every point in
   s02a_points.json.  eq is set to 1 (charge stripped); s03 restores e_u and
   BOTH electromagnetic couplings, since s02_result.m carries eq^2 gs^4 and no
   EL at all - unlike Hgq's S06, which contained EL and therefore needed only
   one further factor of e^2 in its S18 comparison.                          *)
dir = DirectoryName[$InputFileName];
r = Get[FileNameJoin[{ParentDirectory[dir], "s02_result.m"}]];
pts = Import[FileNameJoin[{dir, "s02a_points.json"}], "RawJSON"];
Print["[mg-s02b] loaded s02_result.m and ", Length[pts], " points"];
alphaS = 118/1000;
out = Association @@ Table[
   Module[{inv = pts[nm]["invariants"], sub, mg, mpp},
      sub = {s -> inv["s"], t -> inv["t"], u -> inv["u"], Q2 -> inv["Q2"],
             t2 -> inv["t2"], u2 -> inv["u2"], eps -> 0, Nc -> 3,
             gs -> Sqrt[4 Pi alphaS], eq -> 1};
      mg  = N[r["Mg"] /. sub, 30];
      mpp = N[r["Mpp"] /. sub, 30];
      If[! (NumericQ[mg] && NumericQ[mpp]),
         Print["[mg-s02b] ABORT: non-numeric at ", nm]; Quit[1]];
      Print["[mg-s02b] ", nm, "  Mg = ", N[mg, 12], "   Mpp = ", N[mpp, 12]];
      nm -> <|"Mg" -> mg, "Mpp" -> mpp|>],
   {nm, Keys[pts]}];
Export[FileNameJoin[{dir, "s02b_local_projections.json"}],
   <|"Status" -> "CompleteHgqV3LocalProjections", "AlphaS" -> N[alphaS, 20],
     "ChargeStripped" -> True, "ContainsEL" -> False, "Local" -> out|>, "JSON"];
Print["[mg-s02b] wrote s02b_local_projections.json"];

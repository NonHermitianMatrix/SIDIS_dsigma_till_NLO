#!/usr/bin/env wolframscript
(* Exact WS13 localization of the rejected Hqqbar g regular pole.
   Compare the saved residual with the already-exported total PDF+FF CT pole;
   do not repeat the real-emission Laurent sum. *)
$HistoryLength = 0;
root = Environment["C2ROOT"];
If[root === $Failed, root = "/home/physics/projects/AI_Assisted_SIDIS/mathematica"];
If[StringTake[root, -1] =!= "/", root = root <> "/"];
piece = "MR2gE"; tag = "Hqqbar_g";
resfn = root <> "r5pole_residual_" <> piece <> ".m";
ctfn = root <> "c2in_" <> tag <> ".m";
If[!FileExistsQ[resfn] || !FileExistsQ[ctfn],
  Print["FATAL missing ratio input"]; Quit[1]];
{p2, p1} = Get[resfn];
Block[{Rterms, virtExpr, ctDelta, ctPlus, hasVirt, hasCT}, Get[ctfn]];
PREF = (gs^2/(16 Pi^2)) (4 Pi)^eps/Gamma[1-eps]/eps;
ctPole = Coefficient[Normal[Series[PREF ctReg, {eps, 0, -1}]], eps, -1];
ctPDFPole = Coefficient[
  Normal[Series[PREF ctRegPDF, {eps, 0, -1}]], eps, -1];
ctFFPole = Coefficient[
  Normal[Series[PREF ctRegFF, {eps, 0, -1}]], eps, -1];
color[e_] := Factor[Together[e /. CF -> (Nc^2-1)/(2 Nc)]];
p2 = color[p2]; p1 = color[p1]; ctPole = color[ctPole];
ctPDFPole = color[ctPDFPole]; ctFFPole = color[ctFFPole];
Print["HQQBAR_CT p2zero=", TrueQ[p2 === 0],
      " residualLeaves=", LeafCount[p1], " ctLeaves=", LeafCount[ctPole]];
Do[
  d = color[p1-r ctPole];
  Print["residual-(", InputForm[r], ")CT=",
    If[d === 0, "0 EXACT", "nonzero leaves " <> ToString[LeafCount[d]]]],
  {r, {-2, -1, -1/2, 1/2, 1, 2}}];
Print["residual/CT=", InputForm[Cancel[p1/ctPole]]];
d = color[p1-ctPole];
Print["residual-CT exact remainder=", InputForm[d]];
Do[
  name = pair[[1]]; side = pair[[2]];
  Do[
    q = color[d-r side];
    Print["remainder-(", InputForm[r], ")", name, "=",
      If[q === 0, "0 EXACT", "nonzero leaves " <> ToString[LeafCount[q]]]],
    {r, {-2, -1, -1/2, 1/2, 1, 2}}],
  {pair, {{"PDF", ctPDFPole}, {"FF", ctFFPole}}}];
Print["HQQBAR_CT_RATIO_DONE"];

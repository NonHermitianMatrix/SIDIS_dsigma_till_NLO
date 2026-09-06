#!/usr/bin/env wolframscript
(* t30: t29 tested PaXEvaluate, but s05 uses PaXEvaluateUVIRSplit.  Different
   function - it may treat PaXImplicitPrefactor differently.  That would explain
   why the simple bubble shows the correct Log[4 Pi ScaleMu^2/(-p^2)] structure
   while s05_result.m carries 569 STANDALONE Log[2*Pi].
   Run the SAME bubble through BOTH functions with the SAME prefactor and
   compare the atoms they produce.                                          *)
HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "hgq_common.m"}]];
If[Length[DownValues[PaXEvaluate]] == 0,
   Print["[t30] ABORT: PaXEvaluate unavailable"]; Quit[1]];
Print["[t30] loaded"];

amp = FCI[FAD[{ll, 0}, {ll + pp, 0}]];
ScalarProduct[pp, pp] = psq;
opts = {PaXImplicitPrefactor -> 1/(2 Pi)^D, PaXAnalytic -> True};

show[lbl_, res0_] := Module[{res = res0 /. D -> 4 - 2 eps},
   If[! FreeQ[res, PaXEvaluate | PaXEvaluateUVIRSplit],
      Print["[t30] ", lbl, " DID NOT EVALUATE"]; Return[]];
   Print["[t30] ", lbl, " -> ", InputForm[Simplify[res]]];
   Print["[t30] ", lbl, " atoms: Log[2Pi]=", Count[res, Log[2 Pi], Infinity],
      "  Log[4Pi]=", Count[res, Log[4 Pi], Infinity],
      "  Log[Pi]=", Count[res, Log[Pi], Infinity],
      "  EulerGamma=", Count[res, EulerGamma, Infinity],
      "  any Log containing Pi: ",
      Length[DeleteDuplicates[Cases[res, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]]]]];

show["PaXEvaluate        ", PaXEvaluate[amp, ll, Sequence @@ opts]];
show["PaXEvaluateUVIRSplit", PaXEvaluateUVIRSplit[amp, ll, Sequence @@ opts]];
Print["[t30] done"];

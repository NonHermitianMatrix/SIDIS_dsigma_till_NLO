#!/usr/bin/env wolframscript
(* t31: the bubble gives a clean Log[4 Pi ScaleMu^2/(-p^2)] under BOTH
   PaXEvaluate and PaXEvaluateUVIRSplit (t29,t30), yet s05_result.m carries 569
   standalone Log[2*Pi].  The production amplitude differs from the bubble in
   two ways: higher-point functions (C0/D0) and TENSOR numerators.  Test each
   with the exact options s05 uses, and report whether Log[2*Pi] appears.     *)
HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "hgq_common.m"}]];
If[Length[DownValues[PaXEvaluate]] == 0, Print["[t31] ABORT: no PaXEvaluate"]; Quit[1]];
Print["[t31] loaded"];
opts = {PaXImplicitPrefactor -> 1/(2 Pi)^D, PaXAnalytic -> True};

ScalarProduct[p1, p1] = 0; ScalarProduct[p2, p2] = 0;
ScalarProduct[p1, p2] = ss/2;

probe[lbl_, amp_] := Module[{res},
   res = Quiet[PaXEvaluateUVIRSplit[amp, ll, Sequence @@ opts]] /. D -> 4 - 2 eps;
   If[! FreeQ[res, PaXEvaluateUVIRSplit], Print["[t31] ", lbl, ": did not evaluate"]; Return[]];
   Print["[t31] ", lbl, ":  Log[2Pi]=", Count[res, Log[2 Pi], Infinity],
     "  Log[4Pi]=", Count[res, Log[4 Pi], Infinity],
     "  Log[Pi]=", Count[res, Log[Pi], Infinity],
     "  Pi-logs: ",
     Short[DeleteDuplicates[Cases[res, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]], 3]]];

probe["scalar bubble  ", FCI[FAD[{ll, 0}, {ll + p1, 0}]]];
probe["scalar triangle", FCI[FAD[{ll, 0}, {ll + p1, 0}, {ll + p1 + p2, 0}]]];
probe["rank-1 bubble  ", FCI[FVD[ll, mu] FAD[{ll, 0}, {ll + p1, 0}]]];
probe["rank-2 bubble  ", FCI[FVD[ll, mu] FVD[ll, nu] FAD[{ll, 0}, {ll + p1, 0}]]];
Print["[t31] done"];

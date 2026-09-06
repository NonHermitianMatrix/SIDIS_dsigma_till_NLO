#!/usr/bin/env wolframscript
(* t29: DERIVE the correct PaXImplicitPrefactor for THIS channel (not copied
   from Hqq).  Requirement: real = gs^4 Sfac^2 x pf(=S_eps) = S_eps^3 and the
   counterterm = S_eps^3, so the LOOP must contribute exactly one
   S_eps = (4Pi)^eps Exp[-gammaE eps].
   s05:88 uses PaXImplicitPrefactor -> 1/(2Pi)^D = (2Pi)^(-4+2eps), whose
   eps-expansion gives Log[2Pi] - and indeed s05_result.m holds 569 Log[2*Pi]
   and 580 Log[Pi] but ZERO Log[4*Pi], while real/sub use Log[4Pi] via Sfac.
   Evaluate the massless bubble under each candidate prefactor and compare the
   eps-expansion against the exact closed form, whose (4Pi)^eps is unambiguous:
     Int d^Dl/(2Pi)^D 1/(l^2 (l+p)^2)
        = I/(16 Pi^2) (4Pi)^eps Gamma[1+eps]Gamma[1-eps]^2/Gamma[1-2eps]
          (-p^2)^(-eps) / eps                                                *)
HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "hgq_common.m"}]];
Print["[t29] FeynCalc+FeynHelpers loaded: ",
   MemberQ[$Packages, "FeynCalc`"] && Length[DownValues[PaXEvaluate]] > 0];
If[Length[DownValues[PaXEvaluate]] == 0,
   Print["[t29] ABORT: PaXEvaluate unavailable - result would be meaningless"]; Quit[1]];
amp = FCI[FAD[{ll, 0}, {ll + pp, 0}]];
ScalarProduct[pp, pp] = psq;

cands = {"1/(2Pi)^D" -> 1/(2 Pi)^D, "1/(2Pi)^4" -> 1/(2 Pi)^4, "1" -> 1};
Do[Module[{res, ser},
   res = PaXEvaluate[amp, ll, PaXImplicitPrefactor -> (c[[2]]), PaXAnalytic -> True];
   res = res /. D -> 4 - 2 eps;
   ser = Normal[Series[res, {eps, 0, 0}]];
   If[! FreeQ[res, PaXEvaluate],
      Print["[t29] prefactor ", c[[1]], " DID NOT EVALUATE - skipping"]; Return[]];
   Print["[t29] prefactor ", c[[1]], "  -> ", InputForm[Simplify[ser]]];
   Print["[t29]    atoms: Log[4Pi]=", Count[ser, Log[4 Pi], Infinity],
         " Log[2Pi]=", Count[ser, Log[2 Pi], Infinity],
         " Log[Pi]=", Count[ser, Log[Pi], Infinity],
         " EulerGamma=", Count[ser, EulerGamma, Infinity]]],
 {c, cands}];

(* the exact form, for reference *)
exact = I/(16 Pi^2) (4 Pi)^eps Gamma[1 + eps] Gamma[1 - eps]^2/Gamma[1 - 2 eps] *
        (-psq)^(-eps)/eps;
Print["[t29] exact closed form, eps^-1 and eps^0: ",
   InputForm[Simplify[Normal[Series[exact, {eps, 0, 0}]]]]];
Print["[t29] done"];

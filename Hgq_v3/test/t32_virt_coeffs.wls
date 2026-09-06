#!/usr/bin/env wolframscript
(* t32: does the VIRTUAL carry gammaE inside its Laurent COEFFICIENTS?
   The residue is quadratic in x = gammaE - LogPi.  x can only appear twice if
   the scheme factor's O(eps) term (Log4 - x) multiplies a pole coefficient that
   ITSELF contains x.  real and subtraction keep all their gammaE in Sfac, so
   their coefficients are x-free.  Package-X reports in 1/epsbar, which puts
   gammaE in the coefficients.  Check each Laurent coefficient of the stored
   virtual for gammaE / Log[Pi] content.                                     *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
vd = Get[FileNameJoin[{dir, "s08ck_virt.m"}]];
sb = Get[FileNameJoin[{dir, "s08ck_sub.m"}]];
Do[Module[{ser},
   ser = Normal[Series[vd[g], {eps, 0, 0}]];
   Do[Module[{c = Coefficient[ser, eps, k]},
      Print["[t32] virt ", g, "  eps^", k,
        " : EulerGamma=", Count[c, EulerGamma, Infinity],
        "  Log-with-Pi=", Length[DeleteDuplicates[
             Cases[c, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]]],
        "  LeafCount=", LeafCount[c]]], {k, {-2, -1, 0}}]],
 {g, {"g", "pp"}}];
Do[Module[{ser},
   ser = Normal[Series[sb[g]["del"], {eps, 0, 0}]];
   Do[Module[{c = Coefficient[ser, eps, k]},
      Print["[t32] sub  ", g, "  eps^", k,
        " : EulerGamma=", Count[c, EulerGamma, Infinity],
        "  Log-with-Pi=", Length[DeleteDuplicates[
             Cases[c, Log[a_] /; ! FreeQ[a, Pi] :> a, Infinity]]],
        "  LeafCount=", LeafCount[c]]], {k, {-1, 0}}]],
 {g, {"g", "pp"}}];
Print["[t32] done"];

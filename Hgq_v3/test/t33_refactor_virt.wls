#!/usr/bin/env wolframscript
(* t33: is the virtual of the form  S_eps^k x (gammaE-free coefficients)?
   If Package-X's output is just an EXPANDED S_eps (the 1/epsbar convention),
   then dividing by S_eps^k for the right integer k must leave Laurent
   coefficients with ZERO EulerGamma.  If no k does that, the gammaE is NOT a
   factorable scheme factor and the residue is a genuine normalisation error.
   Tested on the RAW s05 output (before gsSub), with EpsilonUV/IR -> eps.
   Cheap: s05_result.m is 196 KB.  Touches nothing.                          *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
s05r = Get[FileNameJoin[{dir, "s05_result.m"}]];
Sfac = (4 Pi)^eps Exp[-EulerGamma eps];
Do[Module[{V},
   V = s05r[If[g === "g", "Vg", "Vpp"]] /. {EpsilonUV -> eps, EpsilonIR -> eps};
   Do[Module[{W, ser, cnt},
      W = V Sfac^(-k);
      ser = Normal[Series[W, {eps, 0, 0}]];
      cnt = Table[Count[Coefficient[ser, eps, m], EulerGamma, Infinity], {m, {-2, -1, 0}}];
      Print["[t33] ", g, "  k=", k, "  EulerGamma per order {eps^-2,eps^-1,eps^0} = ", cnt,
            If[cnt[[1]] == 0 && cnt[[2]] == 0, "   <== poles gammaE-FREE", ""]]],
    {k, {0, 1, 2, 3, -1}}]],
 {g, {"g", "pp"}}];
Print["[t33] done"];

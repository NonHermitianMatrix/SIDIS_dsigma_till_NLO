#!/usr/bin/env wolframscript
(* t28: is the virtual truncated in eps?  It carries a 1/eps^2 pole, so its
   eps^2 content reaches del's FINITE part.  The pole gates prove it is right at
   O(eps) (an O(eps) error would leak into 1/eps and break del's gate), and t26
   proves the residue is QUADRATIC in the scheme logs - exactly what a missing
   eps^2 term produces.  This is the same bug class as s07a's pf truncation.
   Measure the eps-depth of the stored virtual, per projector.               *)
dir = ParentDirectory[DirectoryName[$InputFileName]];
s05r = Get[FileNameJoin[{dir, "s05_result.m"}]];
vd   = Get[FileNameJoin[{dir, "s08ck_virt.m"}]];
Do[Module[{e, ex},
   e = s05r[If[g === "g", "Vg", "Vpp"]];
   ex = Union[Exponent[e, eps, List]];
   Print["[t28] s05 ", g, " eps exponents present: ", ex,
         "   min = ", Min[ex], "  max = ", Max[ex]];
   Print["[t28] s05 ", g, " has EpsilonUV/IR: ",
         {! FreeQ[e, EpsilonUV], ! FreeQ[e, EpsilonIR]}]],
 {g, {"g", "pp"}}];
Do[Module[{ex},
   ex = Union[Exponent[vd[g], eps, List]];
   Print["[t28] s08ck_virt ", g, " eps exponents: ", ex,
         "   min = ", Min[ex], "  max = ", Max[ex]]],
 {g, {"g", "pp"}}];
Print["[t28] done"];

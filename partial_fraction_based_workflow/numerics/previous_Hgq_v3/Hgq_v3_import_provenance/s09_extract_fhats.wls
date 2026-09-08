#!/usr/bin/env wolframscript
(* s09 : extract F1hat and F2hat from s08_result.m into per-component files.
   Verification status differs BY COMPONENT and is recorded in s09_status.txt:
     reg, p1, p2 : poles cancel AND MSbar-clean (d/dEulerGamma = d/dLogPi = 0
                   to 31-32 digits at physical points, tests t23/t25)
     del         : poles cancel, but a scheme residue remains (t25/t26) - NOT
                   yet MSbar-clean.  Do not use del for a final number.       *)
dir = DirectoryName[$InputFileName];
r = Get[FileNameJoin[{dir, "s08_result.m"}]];
Print["[s09] loaded, keys: ", Keys[r]];
out = FileNameJoin[{dir, "s09_fhats"}];
If[! DirectoryQ[out], CreateDirectory[out]];
Do[Module[{e, f},
   e = r[key][cmp];
   f = FileNameJoin[{out, key <> "_" <> cmp <> ".m"}];
   Put[e, f];
   Print["[s09] ", key, " ", cmp, "  LeafCount = ", LeafCount[e],
         "  bytes = ", FileByteCount[f]]],
 {key, {"F1hat", "F2hat"}}, {cmp, {"del", "reg", "p1", "p2"}}];
Print["[s09] written to ", out];
Print["[s09] done"];

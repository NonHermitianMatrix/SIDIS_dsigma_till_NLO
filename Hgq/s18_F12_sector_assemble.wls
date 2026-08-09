#!/usr/bin/env wolframscript
(* Step F1 -- assemble F1hat/F2hat PER SECTOR from a channel's four finished
   pieces, in both photon projections.

   WHY PER SECTOR, and why `Hqq_F12_assemble.wls` could not be reused as-is.
   A completed channel carries FOUR objects in each projection,

       delta      coefficient of  delta(s23)
       plus1B     coefficient of  [1/s23]_+        on [0, B]
       plus2B     coefficient of  [Log s23/s23]_+  on [0, B]
       regular    an ordinary function of s23

   These multiply DIFFERENT distributions, so they cannot be summed into one
   expression -- only the coefficients of the same distribution may be
   combined.  `Hqq_F12_assemble.wls` takes ONE pre-assembled hard function per
   projection, which was adequate for Hgg alone: Hgg's endpoint residue
   vanishes identically, so delta = plus1B = plus2B = 0 there and `regular` is
   its entire content.  Hgq and Hqg have all four nonzero.

   The extraction projectors are LINEAR, so they act sector by sector.  These
   are the eps -> 0 limit of the eps-exact projectors (a consistency check in
   itself):

       F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
       F2hat = -xh Fg + (12 xh^3/Q2) Fpp

   applied with Fg, Fpp the SAME sector in the two projections.  Keeping the
   four sectors separate is also what makes the result map one-to-one onto the
   reference implementation's `delta / plus1B / plus2B / regular` structure.

   The convolution with PDFs and FFs is NUMERICS (step N1) and is NOT done
   here; this stage is algebraic only.

   FRAME REQUIREMENT, enforced not assumed.  All four sectors must be written
   in the SAME variables.  Stage 2 emits the invariant frame (s, t1, Q2, B);
   R5 emits the compact frame (R5S, R5M, z, s23).  Mixing them silently is the
   failure mode of STATE 0z.72/0z.73 and WRONG.md Category D, so this script
   REFUSES to assemble if any sector still carries a compact-frame symbol.

   Env: F12CHAN   channel label (Hgq, Hqg, Hqq, ...)
        F12DELTA  path to the stage-2 result .m for each projection, as
                  F12G_S2 / F12PP_S2
        F12G_REG / F12PP_REG   paths to the invariant-frame regular sectors
        C2ROOT    output directory                                          *)

$HistoryLength = 0;

chan = Environment["F12CHAN"]; If[chan === $Failed, chan = "Hgq"];
root = Environment["C2ROOT"];
If[root === $Failed, root = Directory[]];
If[StringTake[root, -1] =!= "/", root = root <> "/"];

get[var_, fallback_] := Module[{v = Environment[var]},
   If[v === $Failed, fallback, v]];

fs2g = get["F12G_S2", root <> "stage2_" <> chan <> "_g.m"];
fs2pp = get["F12PP_S2", root <> "stage2_" <> chan <> "_PP.m"];
fregg = get["F12G_REG", root <> "r5reg_inv_" <> chan <> "_g.m"];
fregpp = get["F12PP_REG", root <> "r5reg_inv_" <> chan <> "_PP.m"];

Do[If[!FileExistsQ[f], Print["FATAL missing ", f]; Quit[1]],
   {f, {fs2g, fs2pp, fregg, fregpp}}];

s2g = Get[fs2g]; s2pp = Get[fs2pp];
regg = Get[fregg]; regpp = Get[fregpp];
If[Head[s2g] =!= Association || Head[s2pp] =!= Association,
   Print["FATAL: stage-2 file is not an Association"]; Quit[1]];

(* the eps^0 coefficient of each distribution sector *)
sector[a_, name_] := Lookup[a, Key[{name, 0}], Missing[]];

Fg = <|"delta" -> sector[s2g, "delta"], "plus1B" -> sector[s2g, "plus1"],
       "plus2B" -> sector[s2g, "plus2"], "regular" -> regg|>;
Fpp = <|"delta" -> sector[s2pp, "delta"], "plus1B" -> sector[s2pp, "plus1"],
        "plus2B" -> sector[s2pp, "plus2"], "regular" -> regpp|>;

Do[If[MissingQ[Fg[k]] || MissingQ[Fpp[k]],
      Print["FATAL: sector ", k, " missing from a stage-2 result"]; Quit[1]],
   {k, {"delta", "plus1B", "plus2B"}}];

(* FRAME GATE -- compact-frame symbols must not reach the assembly *)
compact = {R5S, R5M, R5K, z, x, xi, PHT};
bad = {};
Do[Do[If[!FreeQ[f[k], v], AppendTo[bad, {k, v}]], {v, compact}],
   {f, {Fg, Fpp}}, {k, Keys[Fg]}];
If[bad =!= {},
   Print["FATAL frame gate: compact-frame symbols reached the assembly: ",
         DeleteDuplicates[bad]];
   Print["  Map the regular sector to (s, t1, Q2, s23) FIRST.  Do not assemble."];
   Quit[1]];
Print["frame gate: PASSED (all four sectors free of ", compact, ")"];

(* eps must be gone: these are eps^0 coefficients of a pole-free combination *)
Do[If[!FreeQ[f[k], eps],
      Print["FATAL: sector ", k, " still carries eps"]; Quit[1]],
   {f, {Fg, Fpp}}, {k, Keys[Fg]}];
Print["eps-free gate: PASSED"];

F1hat = Association[]; F2hat = Association[];
Do[
  Module[{g = Fg[k], pp = Fpp[k]},
   F1hat[k] = -(1/2) g + (2 xh^2/Q2) pp;
   F2hat[k] = -xh g + (12 xh^3/Q2) pp;
   Print["  ", k, ": Fg ", LeafCount[g], "  Fpp ", LeafCount[pp],
         "  -> F1hat ", LeafCount[F1hat[k]], "  F2hat ", LeafCount[F2hat[k]]];
  ], {k, {"delta", "plus1B", "plus2B", "regular"}}];

Put[F1hat, root <> "F1hat_" <> chan <> ".m"];
Put[F2hat, root <> "F2hat_" <> chan <> ".m"];
Print["F12_SECTOR_ASSEMBLE_DONE ", chan,
      " -> F1hat_", chan, ".m , F2hat_", chan, ".m"];

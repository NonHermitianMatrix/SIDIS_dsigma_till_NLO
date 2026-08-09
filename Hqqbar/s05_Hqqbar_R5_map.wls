#!/usr/bin/env wolframscript
(* Hqqbar (channel 5) R5: the s23-regular sector, frame-mapped in Mathematica.

   WHY HERE.  MEASURED on this exact operand (python/Hqqbar_R5_profile.py and
   the full-map timing):
       30 top-level terms : expr.subs 6.25 s | xreplace 0.01 s | dag 0.00 s
       1610 terms (full)  : dag_xreplace >120 s locally, and 8 h 48 m on the
                            cluster at 100% of one core without finishing
   The DAG is only 7650 nodes and small slices map instantly, so the cost is
   not per node -- it is the FINAL TOP-LEVEL Add, where sympy tries to combine
   like terms across 1610 large mapped rational functions.  Mathematica has no
   such problem, and this route is validated: the identical trick mapped the
   75-million-op Hqg regular sector in 3 SECONDS (STATE 0z.96).

   THE MAP IS APPLIED BY THE LEAVES.  Everything in the R5 map is a pure
   substitution on LEAF SYMBOLS (reference sections 4 and 6):
       xh = x/xi
       s  -> Q2 (1/xh - 1)
       u1 -> -zh Q2/xh
       t1 -> -Q2 + zh (Q2 - k1T^2/zh^2)
       zeta = (xh PHT^2 + z^2 Q2 (1-xh)) / (z (Q2 (1-xh) - s23 xh))
       zh = z/zeta ,  k1T = PHT/zeta
   so assigning s, t1, u1 BEFORE the Get applies the map during the read, in
   one linear pass, with no replacement pass at all.

   AND THE CHANNEL NEEDS NOTHING ELSE.  R4 found NO endpoint classes (verified
   term by term) and the counterterms vanish identically because
   Hglu_S12_CT.LO[('q','qb')] is None -- gamma* q -> qbar + X does not exist at
   O(alphas).  So the finished hard function is simply

       regular = kf * jac * Hreal ,   kf = (1/4) Pi^-eps/(2Pi)^(2-2eps)
                                             Gamma[1-eps]/Gamma[1-2eps]

   Input : python/cache/Hqqbar_R3_<name>_ang.m   (Hqqbar_R5_export_m.py)
   Output: python/cache/Hqqbar_R5_<name>.mx      (symbol `regular`)

   Run: R5NAME=<MR2PPQQB|MR2gQQB> math -script mathematica/Hqqbar_R5_map.wls
*)

$HistoryLength = 0;

name = Environment["R5NAME"];
If[!StringQ[name] || name === "",
  Print["usage: R5NAME=<MR2PPQQB|MR2gQQB> math -script Hqqbar_R5_map.wls"];
  Quit[1]];
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python",
                "cache"}]];
Print["name = ", name, "; cache = ", root];

src = FileNameJoin[{root, "Hqqbar_R3_" <> name <> "_ang.m"}];
dst = FileNameJoin[{root, "Hqqbar_R5_" <> name <> ".mx"}];
If[!FileExistsQ[src], Print["FATAL: missing ", src]; Quit[1]];
Print["input: ", src, " (", FileByteCount[src]/1.*^6, " MB)"];

(* ---- the map, as leaf values (reference sections 4 and 6) ------------- *)
xh = x/xi;
zeta = (xh PHT^2 + z^2 Q2 (1 - xh))/(z (Q2 (1 - xh) - s23 xh));
zh = z/zeta;
k1T = PHT/zeta;

s  = Q2 (1/xh - 1);
u1 = -zh Q2/xh;
t1 = -Q2 + zh (Q2 - k1T^2/zh^2);
jac = (xh^2 PHT^2 + xh z^2 Q2 (1 - xh))/(z (Q2 (1 - xh) - s23 xh)^2);
kf = (1/4) Pi^(-eps)/(2 Pi)^(2 - 2 eps) Gamma[1 - eps]/Gamma[1 - 2 eps];

(* CHECK 4 of the reference: the map must satisfy momentum conservation,
   s + t1 + u1 + Q2 - s23 = 0 identically.  Assert it BEFORE using the map. *)
cons = Simplify[s + t1 + u1 + Q2 - s23];
Print["[1] check 4  s + t1 + u1 + Q2 - s23 = ", cons // InputForm];
If[!TrueQ[cons === 0],
  Print["FATAL: the kinematic map violates momentum conservation"]; Quit[1]];

(* ---- read (the substitution happens here) ----------------------------- *)
tRead = AbsoluteTiming[Get[src];][[1]];
Print["[2] Get done in ", tRead, " s; Head[r5regular] = ", Head[r5regular],
      "; ByteCount = ", ByteCount[r5regular]];
If[Head[r5regular] === Symbol || ByteCount[r5regular] < 1000,
  Print["FATAL: r5regular did not load"]; Quit[1]];

regular = kf jac r5regular;
Print["[3] regular assembled; ByteCount = ", ByteCount[regular]];

(* ---- gates ----------------------------------------------------------- *)
allowed = {"x", "xi", "z", "PHT", "Q2", "s23", "eps", "Nc", "ee", "eq", "gs"};
syms = DeleteDuplicates[
  Cases[regular, _Symbol?(Context[#] === "Global`" &), {0, Infinity},
        Heads -> True]];
names = SymbolName /@ syms;
Print["[4] free symbols: ", Sort[names]];
stray = Complement[names, allowed];
If[stray =!= {}, Print["FATAL: stray symbols ", stray]; Quit[1]];
If[!FreeQ[regular, _Real],
  Print["FATAL: a machine number reached the result"]; Quit[1]];
Print["[4] gates passed: whitelist clean, no machine numbers"];

DumpSave[dst, regular];
Print["HQQBAR_R5_MAP_DONE ", name, " -> ", dst,
      " (", FileByteCount[dst]/1.*^6, " MB)"];

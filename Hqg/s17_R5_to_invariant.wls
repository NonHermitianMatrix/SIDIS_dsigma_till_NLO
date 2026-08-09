#!/usr/bin/env wolframscript
(* R5 regular sector -> invariant frame (s, t1, Q2, s23), in Mathematica.

   WHY MATHEMATICA.  The sympy stage (python/R5_to_invariant.py) spends its
   time on TREE-sized operations applied to a DAG-sized object: the Hqg g
   regular sector is 251682 distinct nodes but ~75 million tree operations,
   and both `xreplace` and `sp.count_ops` walk the tree without memoizing
   shared subexpressions.  Mathematica shares subexpressions by reference, so
   the same map is a single linear read.

   WHAT IS IMPLEMENTED.  Exactly the map of python/R5_to_invariant.py:

       A    = [ (t1 + Q2) + (s - s23) ] / [ (s - s23) (Q2 + s) ]
       R5M -> 1/A,   R5S -> s,   z -> 1
       mapped = regular * z (R5S - s23)^2 / R5M      (the inverse Jacobian)

   z -> 1 is the degree-0 homogeneity shortcut (each term is homogeneous under
   z -> lam z, R5M -> lam^2 R5M once the Jacobian is divided out), GUARDED on
   the sympy side by verify_homogeneity before this file is ever produced.

   THE MAP IS APPLIED BY THE LEAVES, NOT BY A REPLACEMENT PASS.  R5M, R5S and
   z are given values BEFORE the Get, so the substitution happens as the file
   is read.  There is deliberately no /. pass: a ReplaceAll over this
   expression would be the tree-sized operation this stage exists to avoid.

   Input : python/cache/<channel>_R5_<projection>.m   (python/R5_export_m.py)
   Output: python/cache/<channel>_R5inv_<projection>.mx

   Run: wolframscript -file mathematica/R5_to_invariant.wls <channel> <proj>
*)

$HistoryLength = 0;

(* Parameters come from the ENVIRONMENT, as in every other launcher here:
   `math -script` does NOT populate $ScriptCommandLine (measured -- it is {},
   and Rest[{}] is an error), unlike `wolframscript -file`.  The command line
   is still accepted as a fallback for interactive wolframscript runs. *)
envOr[var_, pos_] := Module[{e = Environment[var], cl = $ScriptCommandLine},
  Which[
    StringQ[e] && e =!= "", e,
    ListQ[cl] && Length[cl] > pos, cl[[pos + 1]],
    True, $Failed]];
channel = envOr["R5CH", 1];
projection = envOr["R5PR", 2];
If[!StringQ[channel] || !StringQ[projection],
  Print["usage: R5CH=<channel> R5PR=<projection> math -script R5_to_invariant.wls"];
  Quit[1]];
Print["channel = ", channel, ", projection = ", projection];

(* Cache directory: R5CACHE on the cluster (flat layout), else python/cache. *)
root = If[StringQ[Environment["R5CACHE"]] && Environment["R5CACHE"] =!= "",
  Environment["R5CACHE"],
  FileNameJoin[{ParentDirectory[DirectoryName[$InputFileName]], "python", "cache"}]];
src = FileNameJoin[{root, channel <> "_R5_" <> projection <> ".m"}];
dst = FileNameJoin[{root, channel <> "_R5inv_" <> projection <> ".mx"}];

If[!FileExistsQ[src], Print["FATAL: missing input ", src]; Quit[1]];
Print["input: ", src, " (", FileByteCount[src]/1.*^6, " MB)"];

(* ---- the map, as leaf values --------------------------------------- *)
A5 = ((t1 + Q2) + (s - s23))/((s - s23) (Q2 + s));
R5M = 1/A5;
R5S = s;
z = 1;

(* invJac is written in the SAME form as the sympy stage; because R5S, R5M
   and z already carry values it evaluates immediately to (s-s23)^2 A5. *)
invJac = z (R5S - s23)^2/R5M;
Print["invJac = ", InputForm[Simplify[invJac]]];
(* CHECK ON THE VARIABLES, NOT ON THE SYMBOLS.  R5M, R5S, z and A5 all CARRY
   VALUES here, so `FreeQ[invJac, R5M]` does NOT test for the symbol -- R5M
   evaluates to its value first and the test searches for that expression
   instead.  That false positive killed job 14198960 on a CORRECT invJac.
   The meaningful statement is that only invariants remain. *)
If[Complement[SymbolName /@ Variables[invJac], {"s", "t1", "Q2", "s23"}] =!= {},
  Print["FATAL: invJac carries non-invariant variables: ",
        Variables[invJac]]; Quit[1]];

(* ---- read (the substitution happens here) --------------------------- *)
tRead = AbsoluteTiming[Get[src];][[1]];
Print["Get done in ", tRead, " s; Head[r5regular] = ", Head[r5regular],
      "; ByteCount = ", ByteCount[r5regular]];
If[Head[r5regular] === Symbol || ByteCount[r5regular] < 1000,
  Print["FATAL: r5regular did not load"]; Quit[1]];

mapped = r5regular invJac;

(* ---- checks --------------------------------------------------------- *)
(* No separate "did R5M survive" test: R5M, R5S and z carry values, so they
   CANNOT appear in `mapped` -- such a test is vacuous (and, written as
   FreeQ[mapped, Symbol["R5M"]], actively wrong, since Symbol["R5M"]
   evaluates to the value too).  The free-symbol whitelist below is the real
   check, and it catches an unmapped R5 variable as a stray name. *)
allowed = {"s", "t1", "Q2", "s23", "Nc", "CF", "nf", "ee", "eq", "gs", "B"};
syms = DeleteDuplicates[Cases[mapped, _Symbol?(Context[#] === "Global`" &),
                              {0, Infinity}, Heads -> True]];
stray = Complement[SymbolName /@ syms, allowed];
Print["free symbols: ", Sort[SymbolName /@ syms]];
If[stray =!= {}, Print["FATAL: stray symbols ", stray]; Quit[1]];

Print["ByteCount[mapped] = ", ByteCount[mapped]];
DumpSave[dst, mapped];
Print["R5_TO_INVARIANT_M_DONE ", channel, " ", projection,
      " -> ", dst, " (", FileByteCount[dst]/1.*^6, " MB)"];

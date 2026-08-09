#!/usr/bin/env wolframscript
(* Stage 2: eps-Laurent pole cancellation for one channel/projection.

   Standing directive `feedback-mathematica-for-series-algebra`:
     "Use Mathematica where sympy is pathologically slow or failing -- the
      Series-heavy pole algebra (eps-Laurent expansion + Simplify pole
      cancellation).  Concretely: C2 (eps-Laurent + soft/collinear pole
      cancellation, all channels/cases)."

   INPUT  : cache/mma_finite_<channel>_<projection>/*.m, one file per stage-1
            batch, each a list of {sector, power, coefficient}.
   OUTPUT : mathematica/stage2_<channel>_<projection>.m with the reduced
            eps^-2 and eps^-1 coefficients (must be 0) and the finite eps^0
            coefficient, per sector.

   The batches are summed PER SECTOR AND POWER and reduced with Together,
   which is the operation that has repeatedly defeated SymPy here: the same
   Hqqbar delta pole1 ran 23 min under a monolithic sympy cancel without
   finishing, and 278 s under a hand-rolled parallel basis reducer.

   Parallelism: batches are Together'd independently, then totalled.  That
   is exact (Together is applied to a sum of independent contributions and
   the total is re-reduced afterwards) and uses every kernel.
*)

$HistoryLength = 0;
$s2start = AbsoluteTime[];

channel = Environment["S2CHANNEL"];
projection = Environment["S2PROJ"];
nkernels = ToExpression[Environment["S2KERNELS"]];
If[!IntegerQ[nkernels] || nkernels < 1, nkernels = 8];

root = DirectoryName[$InputFileName];
(* The cache location must come from the ENVIRONMENT, not from the script's
   own path.  Deriving it as ParentDirectory[root]/python/cache assumes the
   repo layout and pointed at /u/home/r/rushil/python/cache on the cluster,
   where the job actually runs from its own work directory. *)
cache = Environment["S2CACHE"];
If[!StringQ[cache] || cache === "", cache = FileNameJoin[{Directory[], "cache"}]];
dir = FileNameJoin[{cache, "mma_finite_" <> channel <> "_" <> projection}];
If[!DirectoryQ[dir], Print["FATAL: missing ", dir]; Quit[1]];

files = FileNames["*.m", dir];
Print["STAGE2 ", channel, " ", projection, ": ", Length[files], " batches"];
If[Length[files] == 0, Print["FATAL: no batch files"]; Quit[1]];

(* One kernel per requested core; fall back to serial if licensing refuses. *)
ok = Quiet[Check[LaunchKernels[nkernels]; True, False]];
Print["  kernels launched: ", If[ok, Length[Kernels[]], 0]];

sectors = {"delta", "plus1", "plus2"};
(* POLES FIRST, FINITE PART LAST.  The iteration below runs {pw, powers} as
   the INNER loop, so with powers = {-2,-1,0} the single most expensive
   quantity in the whole run -- delta eps^0, the FINITE part -- sits BETWEEN
   the delta poles and the plus poles, and blocks them.
   MEASURED 2026-07-30 on Hgq PP: delta eps^0 was 82487 leaves against 47 for
   delta eps^-1, and six concurrent jobs all sat on it for over half an hour
   having printed only 1-2 of their 9 verdicts.  eps^0 is the physics
   deliverable but it is NOT a pole, so nothing about pole cancellation needs
   to wait for it.
   Ordering {-2,-1} first surfaces EVERY pole verdict within minutes of job
   start; eps^0 then follows for the finite hard function. *)
powers = {-2, -1, 0};
poleFirst = {-2, -1};

(* Load every batch; each file is a list of {sector, power, coefficient}. *)
load[f_] := Module[{data}, data = Get[f];
   If[Head[data] =!= List, Print["FATAL: bad batch ", f]; Quit[1]];
   data];

batches = If[ok, ParallelMap[load, files, Method -> "FinestGrained"],
              Map[load, files]];
Print["  loaded (", Round[AbsoluteTime[] - $s2start], " s)"];

out = FileNameJoin[{cache, "stage2_" <> channel <> "_" <> projection <> ".m"}];
assumeReg = {s > 0, Q2 > 0, B > 0, t1 < 0, Q2 + s + t1 > 0,
             Nc > 0, nf > 0};
result = Association[];
Do[
  Module[{sec = job[[1]], pw = job[[2]], parts, total, red},
    parts = Flatten[
      Table[Select[b, (#[[1]] === sec && #[[2]] === pw) &][[All, 3]],
            {b, batches}]];
    (* Reduce each contribution first, then the total: Together on a sum of
       independent pieces, which is exact and parallelises. *)
    parts = If[ok, ParallelMap[Together, parts, Method -> "FinestGrained"],
               Map[Together, parts]];
    total = Together[Total[parts]];
    (* COLOUR IDENTITY BEFORE THE ZERO TEST -- FALSE NEGATIVES OTHERWISE.
       CF and Nc are independent SYMBOLS to Mathematica, so Simplify cannot
       see that Nc^2 - 1 - 2 Nc CF vanishes.  MEASURED 2026-07-30 on Hgq PP:
       plus1 eps^-1 reported zero=False leaves=29 with the expression
           -(1/2) ee^2 eq^2 gs^4 (Nc^2 - 1 - 2 CF Nc) s/(Nc Pi)
       which is IDENTICALLY ZERO once CF = (Nc^2-1)/(2 Nc) is imposed -- and
       its numeric value at a kinematic point was exactly 0.  Substituting the
       identity first turns that 29 into 1 (zero=True).  It does NOT rescue a
       genuine residue: the same run's delta eps^-1 goes 471 -> 333 and stays
       nonzero, which is how we know THAT one is real. *)
    (* PHYSICAL SIGN CONDITIONS TOO.  Without them Mathematica cannot reduce
       Sqrt[(s+t1)^2] to |s+t1|, cannot combine Log of negative arguments, and
       leaves logs of pure NUMBERS (Log[64], Log[2^36], Log[2^48]) whose
       coefficients cancel only once collected.  MEASURED on Hgq PP delta
       eps^-1: 450 leaves -> 47, IDENTICAL on both branches of sign(s+t1) as
       it must be.  This is the same class of defect as the CF identity: a
       known condition the simplifier was never told. *)
    (* HEAVY REDUCTION ONLY WHERE A ZERO TEST IS NEEDED, i.e. the POLES.
       eps^0 is the FINITE deliverable and is never tested against zero, so
       FullSimplify on it is pure cost.  MEASURED 2026-07-30: Hgq PP's
       delta eps^0 is 82487 leaves against 47 for delta eps^-1, and after the
       Assumptions were added to this gate SIX concurrent jobs sat on that one
       quantity for ~50 min having printed only 1-2 of 9 verdicts -- the
       44-minute full-run precedent (14192973.4) PREDATES the Assumptions.
       FullSimplify with Assumptions is far more expensive than plain
       Simplify, so it is now restricted to pw < 0. *)
    (* ESCALATING LADDER, cheapest rung first -- MEASURED 2026-07-31 on the
       three delta eps^-1 slots (Hqg PP, Hqq g, Hqq PP):
           together              170735 / 216609 / 224344 leaves   ~1 min
           cancel                moved 24 leaves                   ~1 min
           powerexpand+simplify  -> 26520 / 32381 / 41302          ~2-4 min
           simplify              -> 26520 / 32381 / 41302  NO CHANGE, ~165 s
       so the sign-aware log transform does the real work and plain Simplify
       after it is pure cost.  FullSimplify with Assumptions is a broad search
       and was previously the FIRST thing tried on every pole slot; it is now
       a bounded last resort.  The ladder STOPS at the first rung returning 0,
       so a genuinely vanishing pole -- which is what most slots are -- costs a
       fraction of the old single-shot call.
       CF IS SUBSTITUTED FIRST, before Together: the colour identity
       Nc^2 - 1 - 2 Nc CF cannot help the rational reduction if it is imposed
       afterwards, which is what the previous ordering did. *)
    red = total /. CF -> (Nc^2 - 1)/(2 Nc);
    red = Together[red];
    If[red =!= 0 && pw < 0, red = Cancel[red]];
    If[red =!= 0 && pw < 0,
       red = Simplify[PowerExpand[red, Assumptions -> assumeReg],
                      Assumptions -> assumeReg]];
    If[red =!= 0 && pw < 0,
       red = TimeConstrained[
               FullSimplify[red, Assumptions -> assumeReg], 900, red]];
    result[{sec, pw}] = red;
    (* PARTIAL SAVE after every quantity.  Previously `result` was written to
       disk only after ALL NINE finished, so a job dying at 8/9 discarded every
       verdict it had already computed -- and several stage-2 jobs did die that
       way today.  Writing here costs milliseconds against minutes of compute
       per quantity. *)
    Put[result, out];
    Print["  ", sec, " eps^", pw, "  zero=", TrueQ[red === 0],
          "  leaves=", LeafCount[red], "  [saved]"];
  ],
  (* POLES FIRST across ALL sectors, THEN the eps^0 finite parts.  See the
     note at `poleFirst` above: eps^0 is the largest object in the run and is
     not a pole, so it must not sit between the delta and plus pole verdicts. *)
  {job, Join[Flatten[Table[{sec, pw}, {pw, poleFirst}, {sec, sectors}], 1],
             Table[{sec, 0}, {sec, sectors}]]}];

Put[result, out];
Print["STAGE2_DONE ", channel, " ", projection, " -> ", out];

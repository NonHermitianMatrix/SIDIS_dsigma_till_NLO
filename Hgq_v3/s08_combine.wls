#!/usr/bin/env wolframscript
(* s08 : real + virtual + collinear subtractions -> the Hgq hard parts.

   Output uses the same four-piece decomposition as the paper's own code
   (JeffersonLab/BigTMD, NLO/Pg/fchn1A.py):
     H^Gamma = reg(s,t,Q2,s23,mu2)
             + del * DiracDelta[s23]
             + p1  * [ 1/s23        ]_+^B
             + p2  * [ Log[s23]/s23 ]_+^B

   Bookkeeping, identical in every stage:
     n = 4-2 eps ,  gs^2 = 4 Pi as mu2^eps Sfac ,  Sfac = (4Pi)^eps Exp[-gammaE eps]
     (MSbar; HGQ_MS=1 selects Sfac=1, i.e. plain MS).  Every contribution carries
     exactly Sfac^2, so the scheme factor is common and the MSbar gate is that
     the finite answer contains no EulerGamma and no Log[4 Pi].
     H^Gamma = P_Gamma^{mu nu} What_{mu nu}                    (paper Eq.(33))
     LO      = (1/(2Pi)^3)|M|^2_{2->2} delta(s23)              (paper Eq.(34))
     virtual = (1/(2Pi)^3)[2Re(M_V conj(M_LO)) + CT] delta(s23)
     real    = s04 output (already carries dPi3/(2Pi)^4)       (paper Eq.(38))
     colour  : CF=(Nc^2-1)/(2Nc), CA=Nc, TF=1/2, nf light flavours            *)

HGQAddOns = {"FeynArts", "FeynHelpers"};
Get[FileNameJoin[{DirectoryName[$InputFileName], "hgq_common.m"}]];
dir = DirectoryName[$InputFileName];
s01r = Get[FileNameJoin[{dir, "s01_result.m"}]];
s04r = Get[FileNameJoin[{dir, "s04_result.m"}]];
s05r = Get[FileNameJoin[{dir, "s05_result.m"}]];
s06r = Get[FileNameJoin[{dir, "s06_result.m"}]];

MSbarQ = (Environment["HGQ_MS"] =!= "1");
Sfac = If[MSbarQ, (4 Pi)^eps Exp[-EulerGamma eps], 1];
Print["[s07] scheme: ", If[MSbarQ, "MSbar", "MS"]];

(* ---------- stage checkpointing ---------------------------------------
   s08 reached 11.4 GB in one kernel and had to be killed before it could
   OOM.  Each expensive block now writes a checkpoint and is skipped when the
   checkpoint exists, so the stages can be run one per kernel (memory is
   returned between them) and only deleted results are recomputed:
       HGQ_STAGE=A   sum the s07a real partials      -> s08ck_real.m
       HGQ_STAGE=B   virtual, UV gate, 2 Re          -> s08ck_virt.m
       HGQ_STAGE=C   MSbar collinear subtractions    -> s08ck_sub.m
       HGQ_STAGE=D   combine, gates, F1hat/F2hat     -> s08_result.m
   With HGQ_STAGE unset every stage runs in this kernel (the old behaviour). *)
stage = Environment["HGQ_STAGE"];
runQ[x_] := (stage === $Failed || stage === Null || stage === "" || stage === x);
ckReal = FileNameJoin[{dir, "s08ck_real.m"}];
ckVirt = FileNameJoin[{dir, "s08ck_virt.m"}];
ckSub  = FileNameJoin[{dir, "s08ck_sub.m"}];
need[f_, what_] := If[! FileExistsQ[f],
   Print["ABORT: stage input missing: ", FileNameTake[f], " (run ", what, " first)"]; Quit[1]];
CF = (Nc^2 - 1)/(2 Nc); CA = Nc; TF = 1/2; beta0 = 11 CA/3 - 4 TF nf/3;
gsSub = {gs^4 -> (4 Pi as mu2^eps Sfac)^2, gs^2 -> 4 Pi as mu2^eps Sfac};
(* Package-X carries its own scale symbol ScaleMu; map it onto this pipeline's mu2 *)
muSub = ScaleMu -> Sqrt[mu2];

(* ---------- 1. real: extract the s23 distribution structure ------------ *)
Mcoef[m_] := Mcoef[m] = Simplify[(-1)^m D[-BB^(-eps)/eps, {eps, m}]];

(* No Together / Expand / Simplify here: on the 5 MB s04 output each of those
   costs more than the whole rest of the pipeline.  Collect by Log[sig] is
   enough to separate the m-th singular structure, and the residue at sig=0
   is taken directly.                                                        *)
(* Every step below (multiply by pf, truncate in eps, Collect by Log[sig],
   residue at sig=0) is LINEAR in the expression, so the 7.5 MB sum is never
   formed as one object: it is processed in chunks of top-level terms and the
   four output pieces are accumulated.  Expand/Together/Simplify on the whole
   thing is what exhausted memory (6.9 GB) on the previous attempts.        *)
(* The real-part extraction is done by s07a in batches (own kernel each, so
   allocator growth is released between them).  Here we just sum the partials.
   Each partial's filename carries the term range it covers, so batches of any
   size may be mixed; s07nterms is recomputed from s04_result exactly as s07a
   builds its term list, so the coverage check below is against the real term
   count rather than a hard-coded number.                                   *)
s07nterms[proj_] := s07nterms[proj] = Module[{pfRaw, bulk},
   pfRaw = s04r["dPi3"]/(2 Pi)^4;
   bulk = (s04r[proj]/pfRaw) /. u -> sig - s - t - Q2;
   bulk = bulk /. Power[b_, e_] /; ! FreeQ[e, eps] :> Power[b, Simplify[e]];
   Which[
    Head[bulk] === Plus, Length[List @@ bulk],
    Head[bulk] === Times,
     Module[{sums = Select[List @@ bulk, Head[#] === Plus &]},
       If[Length[sums] == 1, Length[List @@ First[sums]], 1]],
    True, 1]];
Print["[s07] --- loading real-part partials from s07a ---"];
(* The partials must TILE the term list exactly: no gaps, no overlaps.  A
   missing batch would otherwise be summed silently and give a confidently
   wrong answer, so the union of the covered ranges is compared to 1..nterms;
   a duplicated term makes the union too long and also aborts.              *)
partFiles[proj_] := partFiles[proj] = Module[{fs, rngs, cov, nterms},
   fs = FileNames["s07part_" <> proj <> "_*_*.m", dir];
   If[fs === {}, Print["ABORT: no partials for ", proj]; Quit[1]];
   rngs = Sort[ToExpression[StringCases[FileNameTake[#],
        "_" ~~ a : DigitCharacter .. ~~ "_" ~~ b : DigitCharacter .. ~~ ".m" :>
         {a, b}][[1]]] & /@ fs];
   nterms = s07nterms[proj];
   cov = Sort[Join @@ (Range @@@ rngs)];
   If[cov =!= Range[nterms],
     Print["ABORT: partials for ", proj, " do not cover 1..", nterms,
       " exactly (gap or overlap)\n  ranges: ", rngs];
     Quit[1]];
   Print["[s07]   ", proj, ": ", Length[fs], " partials covering 1..", nterms, " OK"];
   fs];
loadParts[proj_] := Module[{acc = <|"del" -> 0, "p" -> {0, 0, 0, 0}, "reg" -> 0|>},
   Do[Module[{a = Get[f]},
      acc["del"] += a["del"]; acc["p"] += a["p"]; acc["reg"] += a["reg"]],
    {f, partFiles[proj]}];
   acc];
If[runQ["A"] && ! FileExistsQ[ckReal],
  realP = <|"g" -> loadParts["Wg3"], "pp" -> loadParts["Wpp3"]|>;
  Put[realP, ckReal];
  Print["[s07] real partials summed -> ", FileNameTake[ckReal]];
  If[stage === "A", Print["[s07] stage A done"]; Quit[0]],
  Print["[s07] stage A: reusing ", FileNameTake[ckReal]]];
(* Load a checkpoint ONLY in the stage that consumes it.  Loading every
   existing checkpoint in every stage is what pushed stage C to 11.5 GB: it
   pulled in the 537 MB summed real part, which the subtractions never use. *)
combineQ := (stage === "D" || stage === $Failed || stage === Null || stage === "");
(* Stage D does NOT load s08ck_real.m.  Summed, the real part is 6.7 GB live
   in only ~800 top-level terms per projector, so it must be streamed from the
   s07a partials one file at a time (see stage D below); partFiles still runs
   the same gap/overlap coverage check that stage A ran.                    *)

(* ---------- 2. virtual: UV gate, renormalise, take 2 Re ---------------- *)
LOgq = <|"g" -> s01r["A"]["Hg"], "pp" -> s01r["A"]["Hpp"]|> /. SUNN -> Nc;
LOu = Simplify[LOgq /. t -> -Q2 - s - u];        (* s05 uses (s,u) *)
Vraw = <|"g" -> s05r["Vg"], "pp" -> s05r["Vpp"]|>;

(* The old "UV gate" compared Coefficient[Vraw, 1/EpsilonUV] against
   2(CA+CF)|M_LO|^2 and never closed.  It was MEANINGLESS: s05 already
   substitutes D -> 4-2 eps, so Vraw carries `eps` (from D) alongside the
   separate symbols EpsilonUV/EpsilonIR, and the Born itself carries (D-2) =
   2(1-eps).  Picking the 1/EpsilonUV coefficient while that eps sits in the
   same expression drops the (1-eps) expansion, which feeds the double pole
   into the single pole - so the gate's "residual" was an artefact of its own
   extraction, not physics.
   The virtual is verified instead against a process whose poles are known
   exactly, gamma* -> q qbar, mapping EpsilonUV/IR and D to ONE eps first:
       1/eps^2 -> -2 C_F   and   1/eps -> -3 C_F - 2 C_F Log[4Pi mu^2/Q2]
                                            + 2 C_F EulerGamma
   both of which came out exact, i.e. the massless quark form factor.  That
   is the check that matters; the physics path below is unaffected because it
   maps EpsilonUV -> eps and EpsilonIR -> eps, the same eps as D's.         *)
Print["[s07] virtual: UV/IR labels are mapped to a single eps below; the old "
   <> "1/EpsilonUV gate was ill-defined and has been removed (see comment)."];

(* Real part of the virtual interference.
   Package-X returns branches as PaXDiLog[x,delta] = Li2(x + i0 sign(delta)),
   and Log with negative arguments; PaXDiscExpand is an OPTION of PaXEvaluate,
   not a function, so it cannot be applied here.  In the physical region
   s>0, u<0, Q2>0, -t = Q2+s+u > 0 the three dilogarithm arguments that occur are
     (Q2+s)/s        > 1   -> past the branch point, Li2 complex
     (Q2+u)/u        < 1   -> real
     (s+u)/(Q2+s+u) = 1+Q2/t < 1 -> real
   so only the first needs continuing, via
     Re Li2(x -+ i0) = Pi^2/3 - Log[x]^2/2 - Li2(1/x)   for x>1,
   and Re Log[a<0] = Log[-a].                                                 *)
physAssume = {s > 0, Q2 > 0, u < 0, Q2 + s + u > 0, mu2 > 0};
reDiLog = {
   PaXDiLog[(Q2 + s)/s, _] :> Pi^2/3 - Log[(Q2 + s)/s]^2/2 - PolyLog[2, s/(Q2 + s)],
   PaXDiLog[x_, _] :> PolyLog[2, x]};
takeRe[x_] := Refine[(x /. reDiLog) /. Log[a_] :> Log[Abs[a]], physAssume];
(* COUNTERTERM.  |M|^2 renormalises as  Z_gs^2 Z_2^2 Z_3 |Gamma|^2, so at one
   loop the counterterm is  (2 dZ_gs + 2 dZ_2 + dZ_3) x Born.  The previous
   version carried ONLY 2 dZ_gs = -beta0, i.e. the coupling renormalisation,
   and omitted both field renormalisations - which contribute at 1/eps (never
   at 1/eps^2, matching the observed failure pattern).
   dZ_2 and dZ_3 are NOT hand-assigned: they come from s07b, which derived the
   one-loop self-energies at generic p^2 and gave
     SigmaV_UV = C_F (as/4Pi)              -> dZ_2 = -SigmaV_UV/eps
     Pi_UV     = (5CA/3 - 4 TF nf/3)(as/4Pi) -> dZ_3 = +Pi_UV/eps
   (Both reproduce the standard MSbar constants, which is the cross-check.)
   Note the virtual's own UV/IR *labels* from Package-X are unreliable here -
   Coefficient[.,1/EpsilonUV] returns -3 C_F, which for gamma*->q qbar is the
   known TOTAL single pole, not the UV part - so UV and IR are mapped to one
   eps below and the counterterm supplies the whole UV subtraction.        *)
s07br = Get[FileNameJoin[{dir, "s07b_result.m"}]];
dZ2 = -(s07br["SigmaV_UV"] /. gsSub)/eps;
dZ3 = (s07br["Pi_UV"] /. gsSub)/eps;
(* every CT piece must carry the same scheme factor: dZ2 and dZ3 pick up
   mu2^eps Sfac through gsSub, so the coupling piece must too, otherwise
   the CT sits at Sfac^1 against the Sfac^2 of everything else. *)
dZgs2 = -(as/(4 Pi)) (beta0/eps) mu2^eps Sfac;   (* = 2 dZ_gs *)
Print["[s07] CT pieces (units as/4Pi/eps): 2dZgs = ", Simplify[dZgs2/((as/(4 Pi))/eps)],
      "   2dZ2 = ", Simplify[2 dZ2/((as/(4 Pi))/eps)],
      "   dZ3 = ", Simplify[dZ3/((as/(4 Pi))/eps)]];
(* COUNTERTERM: coupling renormalisation ONLY.
   The external partons are MASSLESS, so their self-energies are scaleless and
   vanish identically in dimensional regularisation - their UV and IR poles
   cancel - hence Z_2 = Z_3 = 1 and adding 2 dZ_2 + dZ_3 as explicit
   counterterms double-counts.  (This reverts "fix 5" of the earlier session,
   which added them on the strength of the paper's Appendix E remark about
   LSZ Z factors; that remark is about which diagrams to amputate, not about
   a nonzero massless Z.)
   The objective evidence is the nf test, which the real part cannot touch
   (it carries no nf) and which p1 cannot touch either, so it isolates the CT:
     2 dZgs = -beta0/eps           -> nf coefficient +2/3 (units unit*nf)
     dZ3    = (5CA/3 - 4TF nf/3)/eps -> nf coefficient -2/3
     Pgg["delta"] = beta0 (subtraction) -> nf coefficient -2/3
   With dZ3 present the three sum to -2/3, and -2/3 * unit reproduced the
   measured leftover +4.760e-5 exactly; dropping dZ3 makes nf cancel.
   dZ2 carries no nf so the test does not constrain it - it is removed on the
   same scaleless-self-energy grounds, not by fitting.                      *)
virtDel[g_] := Module[{V, ct},
  V = Vraw[g] /. {EpsilonUV -> eps, EpsilonIR -> eps} /. muSub;
  ct = dZgs2 (LOu[g] /. gsSub);
  (1/(2 Pi)^3) (2 takeRe[V /. gsSub] + ct)];

(* ---------- 3. subtractions ------------------------------------------- *)
(* s06 gives, per channel, {delta, sing, reg}; the overall (as/4Pi)(Sfac/eps)
   is applied here.  The [1/(1-x)]_+ pieces localise to a 1/s23 structure whose
   natural plus-boundary is Sig (where the convolution variable hits its lower
   limit); converting to the physical boundary B leaves a delta(s23) term.    *)
sub = s06r["sub"];
xhat = Q2/(Q2 + s);
SigI = -t s/Q2;                       (* s23 at xi = xhat, i.e. -t(1-xhat)/xhat *)
zbar = -t/(Q2 + s);                   (* 1 - zhat, evaluated at s23 = 0         *)
SigF = s zbar;                        (* s23 at zeta = zhat                     *)
WI[g_] := Simplify[(sub[g]["I_gg"]["sing"] /. u -> sig - s - t - Q2) (sig - t)];
WF[g_] := Simplify[(sub[g]["F_qq"]["sing"] /. u -> sig - s - t - Q2) s];

(* per-step timing + RSS: stage C reached 11 GB and the inputs (s06_result.m)
   are only 4 KB, so one specific line is expanding - instrument to find it. *)
srss[] := Round[ToExpression[StringTrim[Import["!ps -o rss= -p " <> ToString[$ProcessID], "Text"]]]/1024];

slog[x___] := Module[{ff = OpenAppend[FileNameJoin[{dir, "s08c_progress.log"}]]},
   WriteString[ff, StringJoin[ToString /@ {x}], "\n"]; Close[ff]];
(* The MSbar counterterm must be normalised in the measure the real's collinear
   pole actually arrives in.  The real carries the 2->3 phase-space factor
   dPi3/(2Pi)^4 * sig^eps, which t21 measured to be exactly S_eps/(256 Pi^6);
   Eq.(35) shows the 2->2 phase space has NO eps-dependence, so the counterterm
   gets none from its LO and sat one power of S_eps short.  t19 measured that
   shortfall as exactly 1x the subtraction's own 1/eps coefficient (~41 digits).
   pfPS is that factor made dimensionless (pfPS = 1 + eps(Log4Pi - gammaE) + ...).
   Multiplying pref by it CANNOT move any pole: the subtraction has only a
   1/eps pole (pref's 1/eps times a pole-free LO), so a 1+O(eps) rescaling
   leaves every 1/eps coefficient untouched - unlike the real, which has 1/eps^2
   and whose rescaling broke del's gate. *)
pfPS = Normal[Series[(s04r["dPi3"] /. u -> sig - s - t - Q2) sig^eps 256 Pi^6/(2 Pi)^4,
    {eps, 0, 2}]];
If[! FreeQ[pfPS, sig] || Simplify[(pfPS /. eps -> 0) - 1] =!= 0,
   Print["[s07] ABORT: pfPS is not a dimensionless constant with unit eps^0 term: ",
     InputForm[pfPS]]; Quit[1]];
Print["[s07] counterterm phase-space factor pfPS = ", InputForm[Simplify[pfPS]]];
subPieces[g_] := Module[{pref = (as/(4 Pi)) (Sfac pfPS/eps), dl, rg, p1, wi0, wf0, t0},
  t0 = AbsoluteTime[]; slog[g, " WI start rss=", srss[]];
  wi = WI[g]; slog[g, " WI done ", Round[AbsoluteTime[] - t0, 0.1], "s LC=", LeafCount[wi], " rss=", srss[]];
  t0 = AbsoluteTime[]; wf = WF[g];
  slog[g, " WF done ", Round[AbsoluteTime[] - t0, 0.1], "s LC=", LeafCount[wf], " rss=", srss[]];
  wi0 = wi /. sig -> 0; wf0 = wf /. sig -> 0;
  (* delta(s23) from the plus prescription.  The convolution variable's plus
     prescription subtracts the integrand at xi = 1 over the FULL range [0,1],
     while H^LO has support only for xi >= xhat; the missing piece [0,xhat] is
     -wi0 delta(sig) Int_0^xhat dxi/(1-xi) = +wi0 Log[1-xhat] delta(sig), and
     likewise +wf0 Log[1-zhat] for the final state (zbar = 1-zhat).
     What survives on [xhat,1] is a plus distribution in sig whose boundary is
     the sig reached when the convolution variable hits its lower limit
     (sig = SigI at xi = xhat, sig = SigF at zeta = zhat - both derived in
     s06).  Converting that to the physical boundary BB uses
         [1/sig]_+^Sigma = [1/sig]_+^BB - Log[Sigma/BB] delta(sig)
     which follows from [1/sig]_+^X = lim_{d->0}(theta(sig-d)/sig + Log[d/X] delta(sig)).
     The MINUS sign is the point: the previous version added
     Int_BB^Sigma (wi/sig) dsig instead, which both flipped this sign and
     re-added the regular part (wi-wi0)/sig that already sits in reg.  It also
     made the subtraction COMPLEX - Int_BB^SigF wf/sig dsig has a pole at
     sig = s inside its range, giving Log of a negative number (measured:
     an imaginary part 660 I Pi/306 Nc in del's 1/eps, for Gamma = g).      *)
  (* delta(s23) image of the plus prescription, done with the CUTOFF rather
     than by naming a plus-boundary.  Regulating the convolution integral at
     xi = 1 - d and mapping to sigma_c = cutoffScale * d:
         S = lim[ theta(sig-sig_c) D(sig) - w0 Log[cutoffScale/sig_c] delta ]
     and  theta/sig = [1/sig]_+^BB - Log[sig_c/BB] delta ,
     so sig_c cancels and the delta coefficient is simply
         w0 Log[BB/cutoffScale] ,   cutoffScale = |dsig/d(1-xi)| at the endpoint.
     Initial state: sig_I(xi) = t(xi-1)/xi  =>  cutoffScale = -t.
     Final   state: sig_F(zt) = s(1-zt)     =>  cutoffScale = s.
     The previous form, wi0(Log[1-xhat] - Log[SigI/BB]), carried a SPURIOUS
     Log[xhat]: with SigI = -t(1-xhat)/xhat it equals wi0 Log[xhat BB/(-t)].
     The final-state term was already right, because sig_F is LINEAR in zt so
     Log[zbar] - Log[SigF/BB] collapses to Log[BB/s] exactly; only the initial
     state, whose sig_I carries an extra 1/xi, was wrong.                    *)
  dl = pref (sub[g]["I_gg"]["delta"] + sub[g]["I_qg"]["delta"] + sub[g]["F_qq"]["delta"])
     + pref (wi0 Log[BB/(-t)] + wf0 Log[BB/s]);
  slog[g, " dl done rss=", srss[]];
  (* p1 multiplies [1/s23]_+ , so it must be the RESIDUE at sig=0, not the
     full sig-dependent WI/WF.  Splitting
         WI(sig)/sig = WI(0)/sig + [WI(sig)-WI(0)]/sig
     the first piece is the genuine pole (sig-free, matching the real side,
     whose p1 is a residue and hence sig-free by construction) and the second
     is REGULAR and belongs in reg.  The old code put all of WI(sig) into p1,
     which simultaneously corrupted p1 and starved reg - and dl already used
     wi/.sig->0, so stage C was internally inconsistent.
     Checked symbolically: with the residue, REAL p1 + SUB p1 = 0 exactly,
     for both projectors.                                                    *)
  rg = pref ((sub[g]["I_gg"]["reg"] + sub[g]["I_qg"]["reg"] + sub[g]["F_qq"]["reg"]) /. u -> sig - s - t - Q2)
     + pref ((wi - wi0)/sig + (wf - wf0)/sig);
  p1 = pref (wi0 + wf0);
  slog[g, " p1 done rss=", srss[]];
  (* s06's kernels carry the LO gs^2 UNSUBSTITUTED.  Without gsSub the
     subtraction reaches s08 with a bare gs^2, no mu2^eps, and only Sfac^1,
     while the real part carries (4 Pi as mu2^eps Sfac)^2 - so the scheme
     factor is NOT common and the MSbar gate cannot pass by construction.
     Measured on the old checkpoint: subP had gs powers {2}, no mu2, no Sfac.
     Applying gsSub here restores the Sfac^2 contract stated in the header. *)
  <|"del" -> dl, "reg" -> rg, "p1" -> p1|> /. gsSub];

(* stage B: the virtual.  takeRe on Package-X's full output is the other
   heavy block, so it is checkpointed like the real sum and the subtractions. *)
If[runQ["B"] && ! FileExistsQ[ckVirt],
  vd = <|"g" -> virtDel["g"], "pp" -> virtDel["pp"]|>;
  Put[vd, ckVirt];
  Print["[s07] virtual done -> ", FileNameTake[ckVirt]];
  If[stage === "B", Print["[s07] stage B done"]; Quit[0]],
  Print["[s07] stage B: reusing ", FileNameTake[ckVirt]]];
If[combineQ, need[ckVirt, "HGQ_STAGE=B"]; vd = Get[ckVirt]];

Print["[s07] --- subtractions ---"];
If[runQ["C"] && ! FileExistsQ[ckSub],
  subP = <|"g" -> subPieces["g"], "pp" -> subPieces["pp"]|>;
  Put[subP, ckSub];
  Print["[s07] subtractions done -> ", FileNameTake[ckSub]];
  If[stage === "C", Print["[s07] stage C done"]; Quit[0]],
  Print["[s07] stage C: reusing ", FileNameTake[ckSub]]];
If[combineQ, need[ckSub, "HGQ_STAGE=C"]; subP = Get[ckSub]];

(* ---------- 4. combine and gate on pole cancellation ------------------- *)
(* realP["reg"] is ALREADY a Laurent polynomial in eps - s07a produced it as
   Normal[Series[sig^(-eps) rg, {eps,0,1}]].  Calling Series again merely to
   truncate at eps^0 runs the full series machinery over a ~500 MB expression,
   which is what made stage D exceed an hour.  Truncation by coefficient
   extraction is exact and cheap; falls back to Series if eps ever appears in
   an exponent.                                                             *)
(* Measured structure of the real part (s07a partial, and the full sum):

     component   top-level terms   eps powers present   eps in an exponent
       del            161            {-2,-1, 0}            yes (BB^-eps)
       reg            628            {-1, 0, 1}            no
       p1          ~140000           {-1, 0, 1}            no
       p2             161            { 0, 1, 2}            no

   Three facts follow, and they are the whole optimisation.

   (a) reg/p1/p2 are ALREADY Laurent polynomials in eps of depth 1 - s07a
       produced them as Normal[Series[sig^(-eps) rg,{eps,0,1}]] - so Series
       must never be run on them.  Only del carries BB^(-eps).  p2 has no
       pole at all, so its eps^0 part is simply p2 /. eps -> 0.
   (b) The common factor is ONE scalar,
         (mu2^eps Sfac)^2 = Exp[2 eps (Log[mu2] + Log[4Pi] - EulerGamma)],
       so with x_k = Coefficient[X, eps, k] and Ej its series coefficients,
         c_-2 = x_-2,  c_-1 = x_-1 + E1 x_-2,  c_0 = x_0 + E1 x_-1 + E2 x_-2.
       gsSub would instead inject mu2^eps at every gs^4 - eps in an exponent
       at every single term - which is what forced the Series fallback.
   (c) The pole coefficients feed ONLY the numeric gate, so they are collapsed
       to numbers term by term and never assembled symbolically.

   Memory: summed, the real part is 6.7 GB live in ~800 fat top-level terms,
   so chunking by term COUNT split nothing.  The partials are therefore
   streamed one file at a time and reduced term by term, and the surviving
   eps^0 pieces go into a bag that is summed once at the end; "acc = acc + x"
   rebuilds a Plus of the whole answer on every term.                       *)
gsSubNoEps = {gs^4 -> (4 Pi as)^2, gs^2 -> 4 Pi as};
(* REAL common factor.  gsSub gives gs^4 -> mu2^(2 eps) Sfac^2, but the 2->3
   phase space carries ONE MORE mu2^eps than the 2->2: the extra unresolved
   particle's d^(D-1)k integration.  The virtual gets its third power from
   Package-X's ScaleMu (muSub: ScaleMu -> Sqrt[mu2]) on top of gs^4, so without
   this the real sits at mu2^(2 eps) against the virtual's mu2^(3 eps).
   Hgq_v4's README states the same: "a common Born muR2^eps factor is stripped
   from all contributions ... and the real term requires its extra muR2^eps".
   A factor mu2^eps = 1 + eps Log[mu2] cannot move a coefficient that has no
   1/eps^2, so reg/p1/p2 are untouched; it shifts del's 1/eps by
   Log[mu2] * (del's 1/eps^2), which is exactly the surviving residual.
   Sfac^2 is unchanged, so the MSbar contract in the header still holds.     *)
(* Sfac^2 = gs^4's, on top of the ONE power that s07a's pf already supplies, so
   the real sits at S_eps^3.  Imposing Sfac^1 here instead was tried and is
   FALSIFIED: del carries a 1/eps^2 pole, so rescaling the real alone by
   Sfac^-1 = 1+O(eps) shifted del's 1/eps by (Log4Pi-gammaE)x(1/eps^2 coeff)
   and broke its gate (measured 1.40e-3, was 0 to 31 digits), while reg/p1
   survived because they have only a 1/eps pole.  The real's S_eps power is
   CONSTRAINED by the pole cancellation and cannot be changed alone; the
   subtraction is the contribution that was missing a factor.  See subPieces. *)
Ecom = Table[SeriesCoefficient[mu2^eps (mu2^eps Sfac)^2, {eps, 0, j}], {j, 0, 2}];

truncEps[X_] := Module[{ex, kmin},
   If[! FreeQ[X, Power[_, _?(! FreeQ[#, eps] &)]],
      Return[Normal[Series[X, {eps, 0, 0}]]]];
   ex = Exponent[X, eps, List];
   If[! AllTrue[ex, IntegerQ], Return[Normal[Series[X, {eps, 0, 0}]]]];
   kmin = Min[ex];
   Sum[Coefficient[X, eps, k] eps^k, {k, kmin, 0}]];
(* Pole gate.  Deciding whether a huge expression is zero is far cheaper
   numerically than with Simplify: evaluate at several random rational
   kinematic points in the physical region.  Zero at all of them, to working
   precision, is a decisive test for a rational/log/dilog expression.        *)
(* physical points: s>0, t<0, Q2>0, and u fixed to its 2->2 value -Q2-s-t
   (the virtual and the delta(s23) terms live at s23=0, where that is what u is) *)
pts = Table[Module[{sv = 7/2 + i/13, tv = -3/2 - i/17, qv = 1 + i/11},
    {s -> sv, t -> tv, Q2 -> qv, u -> -qv - sv - tv, mu2 -> 2 + i/7,
     sig -> 1/3 + i/23, BB -> 5 + i/5, Nc -> 3, nf -> 5, as -> 1/10}], {i, 1, 3}];
(* gs^4 is no longer substituted term by term (see below), so the numeric
   gate resolves it here; gs -> Sqrt[4 Pi as] reproduces gsSubNoEps exactly
   and leaves as to be fixed by the point itself. *)
numPts[e_] := N[e /. gs -> Sqrt[4 Pi as] /. #, 30] & /@ pts;
Print["[s07] --- pole cancellation gate (max |value| over 3 random points) ---"];
res = <||>;
dlog[x___] := Module[{ff = OpenAppend[FileNameJoin[{dir, "s08d_progress.log"}]]},
   WriteString[ff, StringJoin[ToString /@ {x}], "\n"]; Close[ff]];
drss[] := Round[ToExpression[StringTrim[Import["!ps -o rss= -p " <> ToString[$ProcessID], "Text"]]]/1024];

(* Reduction of ONE real-part term to {c_-2, c_-1, c_0}.

   Read off the measured eps tallies: every reg/p1 term is HOMOGENEOUS in eps
   (each Exponent[...,List] is a single integer), and 1897 of p1's 2379 terms
   per partial are O(eps) - they cannot reach eps^0 and are dropped on sight,
   untouched.  For a homogeneous term of degree k,
       Coefficient[t, eps, k] == t eps^(-k)
   which is a structural multiplication of a Times: no traversal, no rebuild.
   So the fast path costs one Exponent scan per term instead of the six full
   traversals (ReplaceAll + FreeQ + Exponent + three Coefficients) it did
   before.  Anything not homogeneous, or with eps in an exponent - only del,
   via BB^(-eps), 161 terms - falls through to the general path.
   gs^4 is a uniform eps-free factor, so gsSubNoEps is applied ONCE to the
   finished sums rather than to every fat term.                             *)
(* Every eps-in-exponent factor in the real part is a scalar power b^e with b
   free of eps and e linear in eps - del carries BB^(-eps), from Mcoef.  Such
   factors and the common (mu2^eps Sfac)^2 are ONE exponential,
       Exp[eps W],   W = 2(Log[mu2]+Log[4Pi]-EulerGamma) + Sum[e Log[b]]/eps,
   whose expansion coefficients are W^j/j!.  Stripping them leaves a Laurent
   polynomial, so eps^0 is the same cheap convolution used for reg/p1 and
   Series never touches the fat term.  Measured: Series on the full product
   cost 612 s for the 18 del terms of ONE partial - 99.4% of stage D's total
   run time - while every other operation together cost 3 s.                *)
Wcom = 3 Log[mu2] + 2 (Log[4 Pi] - EulerGamma);   (* mu2^(3 eps) Sfac^2 *)
epsCoefGen[t_] := Module[{fs, expf, rest, w, ec, ex, x},
   fs = If[Head[t] === Times, List @@ t, {t}];
   expf = Select[fs, MatchQ[#, Power[_, _?(! FreeQ[#, eps] &)]] &];
   rest = t/(Times @@ expf);
   w = Wcom + Total[(#[[2]] Log[#[[1]]])/eps & /@ expf];
   If[! FreeQ[w, eps] || ! FreeQ[rest, Power[_, _?(! FreeQ[#, eps] &)]],
      Return[With[{ser = Normal[Series[t mu2^eps (mu2^eps Sfac)^2, {eps, 0, 0}]]},
         Coefficient[ser, eps, #] & /@ {-2, -1, 0}]]];
   ex = Exponent[rest, eps, List];
   If[! AllTrue[ex, IntegerQ] || Min[ex] < -2,
      Print["[s07] ABORT: real term carries eps^", Min[ex]]; Quit[1]];
   ec = {1, w, w^2/2};
   x = Coefficient[rest, eps, #] & /@ {-2, -1, 0};
   {x[[1]], x[[2]] + ec[[2]] x[[1]],
    x[[3]] + ec[[2]] x[[2]] + ec[[3]] x[[1]]}];

epsCoefFast[t_] := Module[{ex, k},
   ex = Exponent[t, eps, List];
   If[! AllTrue[ex, IntegerQ], Return[epsCoefGen[t]]];
   If[Min[ex] >= 1, Return[{0, 0, 0}]];
   If[Length[ex] =!= 1, Return[epsCoefGen[t]]];
   k = ex[[1]];
   Switch[k,
     0, {0, 0, t},
    -1, With[{x1 = t eps}, {0, x1, Ecom[[2]] x1}],
    -2, With[{x2 = t eps^2}, {x2, Ecom[[2]] x2, Ecom[[3]] x2}],
     _, epsCoefGen[t]]];

(* Iterator names matter here: Do[...,{t,list}] would BLOCK the Mandelstam
   invariant t, whose own value then contains t - infinite recursion.  Every
   iterator below is a name the expressions cannot contain, and the assertion
   checks that for the kinematic symbols this pipeline actually uses.       *)
If[! And @@ (FreeQ[{trm, cmp, fil, aa, tl}, #] & /@ {s, t, u, Q2, sig, mu2, BB, eps, as, Nc, nf}),
   Print["[s07] ABORT: a loop iterator collides with a kinematic symbol"]; Quit[1]];
comps = {"del", "reg", "p1", "p2"};
getComp[a_, "del"] := a["del"];
getComp[a_, "reg"] := a["reg"];
getComp[a_, "p1"] := a["p"][[1]];
getComp[a_, "p2"] := a["p"][[2]];

(* stream one projector's partials; -> <| comp -> {v2, v1, eps^0 expr} |> *)
realStream[proj_] := Module[{fs, v2, v1, bags, nt = 0},
   fs = partFiles[proj];
   v2 = AssociationMap[0 &, comps]; v1 = AssociationMap[0 &, comps];
   bags = AssociationMap[Internal`Bag[] &, comps];
   Do[
     Module[{aa = Get[fil]},
       Do[
         Module[{tl, c, red},
           tl = getComp[aa, cmp];
           (* one check per component per file picks the path for all its
              terms: eps in an exponent anywhere forces the general path *)
           red = If[FreeQ[tl, Power[_, _?(! FreeQ[#, eps] &)]],
                    epsCoefFast, epsCoefGen];
           tl = If[Head[tl] === Plus, List @@ tl, {tl}];
           nt += Length[tl];
           Do[
             c = red[trm];
             v2[cmp] += numPts[c[[1]]];
             v1[cmp] += numPts[c[[2]]];
             If[c[[3]] =!= 0, Internal`StuffBag[bags[cmp], c[[3]]]],
             {trm, tl}]],
         {cmp, comps}]];
     ClearSystemCache[];
     dlog["   ", proj, " ", FileNameTake[fil], " cumterms=", nt, " rss=", drss[]],
     {fil, fs}];
   AssociationMap[{v2[#], v1[#],
      Total[Internal`BagPart[bags[#], All]] /. gsSubNoEps} &, comps]];

Do[Module[{rr, sm, tstart = AbsoluteTime[]},
   dlog[g, " realStream start rss=", drss[]];
   rr = realStream[If[g === "g", "Wg3", "Wpp3"]];
   dlog[g, " realStream done ", Round[AbsoluteTime[] - tstart, 0.1], "s rss=", drss[]];
   sm = <|"del" -> truncEps[vd[g] + subP[g]["del"]],
          "reg" -> truncEps[subP[g]["reg"]],
          "p1" -> truncEps[subP[g]["p1"]], "p2" -> 0|>;
   Do[Module[{c2, c1},
      c2 = rr[cmp][[1]] + numPts[Coefficient[sm[cmp], eps, -2]];
      c1 = rr[cmp][[2]] + numPts[Coefficient[sm[cmp], eps, -1]];
      Print["  Gamma=", g, "  ", cmp, " : |1/eps^2| = ", ScientificForm[Max[Abs[c2]], 3],
        "   |1/eps| = ", ScientificForm[Max[Abs[c1]], 3]]],
    {cmp, comps}];
   res[g] = AssociationMap[(rr[#][[3]] + Coefficient[sm[#], eps, 0]) &, comps];
   dlog[g, " res stored rss=", drss[]]],
 {g, {"g", "pp"}}];

(* MSbar gate: no EulerGamma, no Log[4 Pi] may survive.
   FreeQ[..., EulerGamma] alone is ATOM-BLIND: the answer carries ~93000
   PolyGamma[0,1/2], and PolyGamma[0,1/2] == -EulerGamma - 2 Log[2], so most of
   the gamma_E is invisible to a bare FreeQ and the gate could report False on a
   clean answer or True on a dirty one.  Expose the atoms with FunctionExpand
   first; memoised per distinct {a,b} so the 93000 instances cost one call. *)
pgx[a_, b_] := pgx[a, b] = FunctionExpand[PolyGamma[a, b]];
msbarAtoms[e_] := e /. PolyGamma[a_, b_] :> pgx[a, b];
(* one component at a time: msbarAtoms on all of res at once would copy the
   whole 244 MB answer; per component the peak is an eighth of that. *)
Print["[s07] MSbar gate (must be True): ",
  AllTrue[Join @@ (Values /@ Values[res]),
    With[{v = msbarAtoms[#]},
      FreeQ[v, EulerGamma] && FreeQ[v /. Log[4 Pi] -> LOG4PI, LOG4PI]] &]];

(* ---------- 5. F1hat, F2hat ------------------------------------------- *)
pr = s01r["proj"];
F1h = AssociationMap[(pr[[1, 2]] /. {Hg -> res["g"][#], Hpp -> res["pp"][#], eps -> 0}) &,
   {"del", "reg", "p1", "p2"}];
F2h = AssociationMap[(pr[[2, 2]] /. {Hg -> res["g"][#], Hpp -> res["pp"][#], eps -> 0}) &,
   {"del", "reg", "p1", "p2"}];
Put[<|"Hg" -> res["g"], "Hpp" -> res["pp"], "F1hat" -> F1h, "F2hat" -> F2h,
   "scheme" -> If[MSbarQ, "MSbar", "MS"]|>,
  FileNameJoin[{dir, "s08_result.m"}]];
Print["[s07] done"];

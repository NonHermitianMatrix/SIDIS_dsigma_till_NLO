#!/usr/bin/env wolframscript
(* C2 for Hqq -- CORRECTED LOG CANONICALIZATION (STATE.md 0z.351).

   Supersedes Hqq_C2_final.wls.  Same physics, same inputs, same factors; the
   ONLY change is how logs are canonicalized before coefficients are taken.

   THE DEFECT.  Hqq_C2_final.wls canonicalized with
       x = x /. Log[a_] :> Log[Simplify[a, dom]]
   and Simplify turns a ratio into a Piecewise, leaving atoms like
       Log[Piecewise[{{Q2/U, Q2 < U}}, U/Q2]]
   Coefficient[re, Log[U]] cannot see the U inside that head, so it reported a
   nonzero coeff(log(-u1)) for a combination that actually cancels IDENTICALLY.
   PROOF (mathematica/Hqq_C2_pair_vs_sf.log): rpairX - sf[X] === 0 exactly, per
   flavour, on all four (projection x branch) cases -- while the same
   Coefficient extraction claimed sf[X] carried a log(-u1) and rpairX did not.
   Same failure class as the CoefficientRules/Log[Pi] trap of 0z.344: a Log
   with a composite argument defeats Coefficient silently.

   THE FIX, two parts:
     (1) DISTRIBUTE first -- Log[a b] -> Log[a] + Log[b], Log[a^n] -> n Log[a]
         -- so every log argument is irreducible, and sign-normalize
         Log[-a] -> Log[a] + I Pi.  Never Simplify INSIDE a Log.
     (2) GATE the resulting atoms against an explicit whitelist.  An
         unrecognized log argument ABORTS instead of silently corrupting a
         coefficient.  This is the structural guard that makes (1) trustworthy.

   Everything else is unchanged from Hqq_C2_final.wls and its fix list:
     0z.333 SF belongs in C2; 0z.335 its dPi3(0) = 1/(16 Pi^2) normalization;
     0z.339 the counterterm pieces must not be lumped; 0z.340 the counterterm
     must actually be ADDED; 0z.343 kappaV = -8 I/Pi; 0z.344a the CT's
     delta(1-v) piece carries no 1/|G'|; 0z.345 flavour multiplicities
     (pair x2, SF x 2(nf-1)); 0z.349 the derived counterterm normalization.

   Reports per source AND the total, so this one run replaces both
   Hqq_C2_final.wls and Hqq_C2_survivors.wls. *)

$HistoryLength = 0;
dir = DirectoryName[$InputFileName];
Get[FileNameJoin[{dir, "Hqq_C2_pieces.m"}]];
sfraw = Import[FileNameJoin[{dir, "Hqq_SF_endpoint_out.m"}]];
If[!ValueQ[rggPP] || !ValueQ[v1PP] || sfraw === $Failed,
   Print["FATAL: inputs did not load"]; Quit[1]];

kappaV = -8 I/Pi;
kappaC = Nc/(2 Pi ee^2 eq^2 gs^2);
dpi3 = 1/(16 Pi^2);
dom = s > 0 && Q2 > 0 && U > 0 && Q2 + s - U > 0 && B > 0 && ScaleMu > 0 && FeynCalcxScaleMu > 0;
toU = {u1 -> -U};
loPPfull = 2 (Nc^2 - 1) U;
logfull  = -(Nc^2 - 1) (Q2^2 + 2 Q2 s + 2 s^2 - 2 s U + U^2)/(s (Q2 + s - U));

(* the irreducible, positive log atoms this calculation may contain *)
okArgs = {2, Pi, B, s, Q2, U, Q2 + s - U, ScaleMu, ScaleMu^2,
          FeynCalcxScaleMu, FeynCalcxScaleMu^2};

sf[tag_] := Module[{rec, e0},
  rec = SelectFirst[sfraw, #[[1]] === tag &];
  If[MissingQ[rec] || rec === Missing, Return[$Failed]];
  e0 = SelectFirst[rec[[2]], #[[1]] === 0 &];
  -dpi3 e0[[2]]];

(* (1) distribute logs into irreducible atoms; NEVER Simplify inside a Log.
   Factor FIRST: an argument may arrive EXPANDED (Log[Q2 s + s^2 - s U] is
   really Log[s (Q2+s-U)]), and a Plus does not match the Times rule below.
   Factor is safe where Simplify is not -- it cannot return a Piecewise. *)
dist[e_] := e //. {
   Log[a_Plus] /; Head[Factor[a]] === Times :> Log[Factor[a]],
   Log[a_Times] :> Total[Log /@ (List @@ a)],
   Log[Power[a_, n_]] /; NumericQ[n] :> n Log[a],
   Log[Rational[m_, n_]] :> Log[m] - Log[n]};
signfix[e_] := e //. {
   Log[a_] /; TrueQ[Simplify[a < 0, dom]] :> Log[Simplify[-a, dom]] + I Pi,
   Log[a_] /; MatchQ[a, _Integer?Negative] :> Log[-a] + I Pi};

canon[e_] := Module[{x},
  x = Expand[e /. toU];
  x = signfix[dist[x]];
  x = dist[signfix[x]];
  Expand[x]];
conj[e_] := e /. Complex[a_, b_] :> Complex[a, -b];
reOf[e_] := Module[{t = canon[e]}, Expand[(t + conj[t])/2]];

(* (2) the structural gate: every surviving log atom must be whitelisted *)
gate[tag_, e_] := Module[{atoms, bad},
  atoms = Union[Cases[e, Log[_], Infinity]];
  bad = Select[atoms, ! MemberQ[okArgs, First[#]] &];
  If[bad =!= {},
     Print["FATAL: unrecognized log atom(s) in ", tag, ": ", bad];
     Print["  A composite Log argument silently defeats Coefficient -- this is"];
     Print["  exactly the 0z.351 defect.  Extend okArgs or fix dist[]."];
     Quit[1]];
  atoms];

coeffs[e_] := {Simplify[Coefficient[e, Log[s]], dom],
               Simplify[Coefficient[e, Log[Q2 + s - U]], dom],
               Simplify[Coefficient[e, Log[U]], dom],
               Simplify[Coefficient[e, Log[Q2]], dom],
               Simplify[Coefficient[e, Log[B]], dom],
               Simplify[Coefficient[e, Log[ScaleMu]] + Coefficient[e, Log[FeynCalcxScaleMu]], dom],
               Simplify[e /. Log[_] -> 0, dom]};
lbl = {"log s   ", "log(-t1)", "log(-u1)", "log Q2  ", "log B   ",
       "log mu  ", "LOG-FREE"};

Do[Module[{pj = p[[1]], lo = p[[2]], rgg = p[[3]], rpr = p[[4]],
           ct = p[[5]], v1 = p[[6]]},
   Do[Module[{sfe = sf[pj <> br], srcs, acc, re},
      If[sfe === $Failed, Print[pj, " ", br, ": SF missing"],
        Print["########## ", pj, " ", br, " ##########"];
        (* THE qqbar RESIDUE IS ONE OBJECT (STATE.md 0z.350/0z.351).  The R4
           identity DFA = (nf-1) x SF and the exact check rpairX - sf[X] === 0
           (Hqq_C2_pair_vs_sf.log, all four cases) say the same- and
           different-flavour residues are IDENTICAL per flavour, so the total
           qqbar contribution is 2 nf rpairX.
           WHY rpairX AND NOT sf[X]: sf[X] still carries an UNRESOLVED
           Sqrt[(Q2-U)^2] = |Q2-U| (the 0z.342 branch), which is what produced
           the Log[Piecewise[...]] that defeated Coefficient.  rpairX is a
           clean rational with no logs and no unresolved root.  Substituting a
           PROVEN-EQUAL object removes the branch from C2 entirely.
           The substitution is GATED below, never assumed. *)
        If[Simplify[reOf[rpr] - reOf[sfe], dom] =!= 0,
           Print["FATAL: rpair =!= sf per flavour for ", pj, " ", br,
                 " -- the 0z.351 substitution is NOT licensed here"]; Quit[1]];
        srcs = {{"real gg",           rgg},
                {"real qqbar x2 nf",  2 nf rpr},
                {"CT (S1/S2)",        kappaC ct},
                {"virtual (kappaV)",  kappaV v1}};
        acc = ConstantArray[0, 7];
        Do[Module[{c},
           re = reOf[q[[2]]];
           gate[pj <> " " <> br <> " " <> q[[1]], re];
           c = coeffs[re];
           acc = acc + c;
           Print["  --- ", q[[1]]];
           Do[Print["      ", lbl[[k]], " /LO : ", Simplify[c[[k]]/lo, dom]],
              {k, 7}]], {q, srcs}];
        Print["  === SUM"];
        Do[Print["      ", lbl[[k]], " /LO : ", Simplify[acc[[k]]/lo, dom]],
           {k, 7}];
        Print["  ALL LOGS ZERO : ", Simplify[acc[[1 ;; 6]], dom] === {0,0,0,0,0,0}];
        Print["  C2 TOTAL ZERO : ", Simplify[Total[acc], dom] === 0]]],
     {br, {"pos", "neg"}}]],
  {p, {{"PP", loPPfull, rggPP, rpairPP, ctPP, v1PP},
       {"g",  logfull,  rggg,  rpairg,  ctg,  v1g}}}];
Print["HQQ_C2_FINAL2_DONE"];

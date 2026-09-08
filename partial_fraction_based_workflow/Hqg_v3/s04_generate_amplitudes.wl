(* Generate only gamma* q -> g q and gamma* q -> g q g. *)
$HistoryLength = 0;
Unprotect[System`Discard];
$FeynCalcStartupMessages = False;
$LoadAddOns = {"FeynArts"};
Get["FeynCalc`"];
$FAVerbose = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, generate, convert];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
Print["CreateFeynAmp options: ", InputForm[Options[CreateFeynAmp]]];

massRules = Thread[(SMP /@ {"m_u", "m_d", "m_s", "m_c", "m_b", "m_t"}) -> 0];
generate[loops_, final_] := Module[{top, diagrams, raw},
 top = CreateTopologies[loops, 2 -> Length[final],
   ExcludeTopologies -> {Tadpoles, WFCorrections}];
 diagrams = InsertFields[top, {V[1], F[3, {1}]} -> final,
   InsertionLevel -> {Classes}, Model -> "SMQCD",
   ExcludeParticles -> {S[_], V[1 | 2 | 3 | 4], U[1 | 2 | 3 | 4], F[1 | 2]}];
 raw = CreateFeynAmp[diagrams, Truncated -> False, PreFactor -> 1];
 <|"Diagrams" -> diagrams, "Raw" -> raw|>];
convert[raw_, outgoing_, loops_] := FCFAConvert[raw,
 IncomingMomenta -> {q, p}, OutgoingMomenta -> outgoing,
 LoopMomenta -> If[loops == 0, {}, {ell}],
 UndoChiralSplittings -> True, ChangeDimension -> D,
 List -> True, SMP -> True, Contract -> False, DropSumOver -> True,
 FinalSubstitutions -> massRules] // DotSimplify //
 (DiracSimplify[#, DiracTraceEvaluate -> True] &);

bornData = generate[0, {V[5], F[3, {1}]}];
bornAmp = convert[bornData["Raw"], {k1, k2}, 0];
gate["Born diagrams generated", Length[bornAmp] > 0];
Print["Born graph count = ", Length[bornAmp]];
realData = generate[0, {V[5], F[3, {1}], V[5]}];
realAmp = convert[realData["Raw"], {k1, k2, k3}, 0];
gate["real diagrams generated", Length[realAmp] > 0];
Print["Real graph count = ", Length[realAmp]];
virtualData = generate[1, {V[5], F[3, {1}]}];
virtualAmp = convert[virtualData["Raw"], {k1, k2}, 1];
virtualAmp = DeleteCases[virtualAmp, 0];
gate["virtual diagrams generated", Length[virtualAmp] > 0];
Print["Virtual graph count = ", Length[virtualAmp]];
gate["all propagating quark masses removed", FreeQ[{bornAmp, realAmp, virtualAmp},
 SMP["m_u" | "m_d" | "m_s" | "m_c" | "m_b" | "m_t"]]];
couplingDegrees = Map[Function[amplitudes,
 DeleteDuplicates[Map[{Exponent[#, SMP["e"]], Exponent[#, SMP["g_s"]]} &, amplitudes]]],
 {bornAmp, realAmp, virtualAmp}];
Print["Coupling degrees {e,gs}: ", InputForm[couplingDegrees]];
gate["only the requested QCD orders are present", couplingDegrees === {{{1, 1}}, {{1, 2}}, {{1, 3}}}];
Put[<|"Born" -> bornAmp, "Real" -> realAmp, "Virtual" -> virtualAmp,
 "GraphCounts" -> Length /@ {bornAmp, realAmp, virtualAmp},
 "CouplingDegrees" -> couplingDegrees,
 "FeynArtsPreFactor" -> 1,
 "LoopMeasure" -> HoldForm[mu^(2 eps) Integrate[loopIntegrand, ell]/(2 Pi)^(4 - 2 eps)],
 "ExternalLegs" -> "on-shell massless external self-energies are scaleless; excluded with WFCorrections",
 "Inputs" -> "FeynArts SMQCD model; no published coefficients"|>,
 FileNameJoin[{root, "s04_result.wl"}]];
Put[<|"Born" -> bornData, "Real" -> realData, "Virtual" -> virtualData|>,
 FileNameJoin[{root, "s04_diagrams.wl"}]];
Print["Wrote s04_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

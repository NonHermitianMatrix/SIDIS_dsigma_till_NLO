$HistoryLength = 0;
$FeynCalcStartupMessages = False;
$LoadAddOns = {"FeynArts"};
Get["FeynCalc`"];
SetDirectory[DirectoryName[$InputFileName]];
If[!DirectoryQ["s01_result"], CreateDirectory["s01_result"]];
require[condition_, message_] := If[!TrueQ[condition], Print["FAIL: ", message]; Quit[1]];

(* Edit the loaded model before FeynArts initializes its couplings. *)
chargeEdit[] := Module[{classRules,seen={}},
  classRules=M$ClassesDescription /. Equal->Rule;
  modelCharges=AssociationThread[{"eq","eqp"},
    (Coefficient[Total[QuantumNumbers /. (# /. classRules)],Charge]& /@ {F[3],F[4]})];
  require[And@@(NumberQ /@ Values[modelCharges]) && FreeQ[Values[modelCharges],0],"model electric charges"];
  M$CouplingMatrices=M$CouplingMatrices /. {
    HoldPattern[Equal[v:C[-F[3,_],F[3,_],V[1]],rhs_]] :>
      (AppendTo[seen,"eq"];Equal[v,rhs eq/modelCharges["eq"]]),
    HoldPattern[Equal[v:C[-F[4,_],F[4,_],V[1]],rhs_]] :>
      (AppendTo[seen,"eqp"];Equal[v,rhs eqp/modelCharges["eqp"]])};
  require[Sort[seen]===Sort[Keys[modelCharges]],"one photon vertex per flavour"];
  Print["PASS: independent symbolic charges; model values ",modelCharges]
];
InitializeModel["SMQCD",ModelEdit:>chargeEdit[]];

generate[name_, incoming_, outgoing_, momentaIn_, momentaOut_] := Module[{graphs, raw, amps, allCount, order, spectators, symmetry},
  Print["Generating ", name];
  graphs = InsertFields[CreateTopologies[0, Length[incoming] -> Length[outgoing]],
    incoming -> outgoing, Model -> "SMQCD", InsertionLevel -> {Particles}];
  raw = CreateFeynAmp[graphs, Truncated -> False, PreFactor -> 1];
  amps = FCFAConvert[raw, IncomingMomenta -> momentaIn, OutgoingMomenta -> momentaOut,
    UndoChiralSplittings -> True, ChangeDimension -> D, List -> True, SMP -> True,
    Contract -> False, DropSumOver -> True,
    FinalSubstitutions -> {SMP["m_u"] -> 0, SMP["m_d"] -> 0,
      SMP["e"] -> ee, SMP["g_s"] -> gs}] /. {GaugeXi[_] -> 1, MQU[_] -> 0, MQD[_] -> 0};
  allCount=Length[amps];
  order=Length[outgoing]-1;
  amps=DotSimplify[#,Expanding->True]& /@ amps;
  amps=DeleteCases[(ee gs^order Coefficient[Coefficient[Expand[#],ee,1],gs,order]& /@ amps),0];
  require[And@@(TrueQ[Expand[#]==ee gs^order Coefficient[Coefficient[Expand[#],ee,1],gs,order]]& /@ amps),"coupling order selection"];
  require[And@@(Together[#-eq Coefficient[#/.eqp->0,eq,1]-eqp Coefficient[#/.eq->0,eqp,1]]===0& /@ amps),"linear charge reconstruction"];
  spectators=Rest[outgoing];
  symmetry=1/Times@@(Factorial[Length[#]]& /@ Gather[spectators]);
  require[symmetry==1/Length[Permutations[Range[Length[spectators]],{Length[spectators]}]] || DuplicateFreeQ[spectators],"spectator multiplicity"];
  require[Length[amps] > 0 && FreeQ[amps, _FCFAConvert], name <> " generation"];
  Put[<|"graphs" -> graphs, "raw" -> raw, "amplitudes" -> amps,
    "incoming" -> momentaIn, "outgoing" -> momentaOut,
    "incoming_fields"->incoming,"outgoing_fields"->outgoing,
    "all_diagram_count"->allCount,"symmetry_weight"->symmetry,
    "model_charges"->modelCharges|>, "s01_result/" <> name <> ".wl"];
  Print[name, ": ", Length[amps], " diagrams; ", ByteCount[amps], " bytes"];
  Length[amps]
];

outcome = MemoryConstrained[
  <|"real" -> generate["real", {V[1], F[3, {1}]}, {F[4, {1}], F[3, {1}], -F[4, {1}]},
       {q, p}, {k1, k2, k3}],
    "born_qg" -> generate["born_qg", {V[1], F[3, {1}]}, {V[5], F[3, {1}]},
       {q, p}, {k1, k2}],
    "born_gq" -> generate["born_gq", {V[1], V[5]}, {F[4, {1}], -F[4, {1}]},
       {q, p}, {k1, k2}]|>, 4*1024^3, $Aborted];
require[outcome =!= $Aborted, "memory limit"];
Put[<|"diagram_counts" -> outcome, "wolfram" -> $Version,
  "feyncalc" -> $FeynCalcVersion, "channel" -> "gamma* q -> qprime q qbarprime",
  "charge" -> "distinct massless flavours with independent symbolic charges eq and eqp",
  "photon_coupling" -> "divide the squared amplitude by ee^2 for the current tensor",
  "dimension" -> HoldForm[4 - 2 eps]|>, "s01_result/manifest.wl"];
Print["PASS: amplitudes saved"];
Quit[0];

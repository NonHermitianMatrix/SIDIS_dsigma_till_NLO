(* Fresh Hgq amplitudes and the Born/vertex inputs needed for normalization and factorization. *)
$HistoryLength = 0;
Unprotect[System`Discard];
$FeynCalcStartupMessages = False;
$LoadAddOns = {"FeynArts"};
Get["FeynCalc`"];
$FAVerbose = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, generate, atomicPut, species];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 1800,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3, Print["Memory limit: ", label]; Quit[3]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
cache = FileNameJoin[{root, "s01_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
sourceHash = FileHash[$InputFileName, "SHA256"];
Print["Wolfram: ", $Version, "; FeynCalc: ", $FeynCalcVersion];

quarkField = F[3, {1}];
massRules = Thread[(SMP /@ {"m_u", "m_d", "m_s", "m_c", "m_b", "m_t"}) -> 0];
excluded = {S[_], V[1 | 2 | 3 | 4], U[1 | 2 | 3 | 4], F[1 | 2]};
requests = <|
 "Born" -> <|"Loops" -> 0, "Incoming" -> {V[1], V[5]}, "Outgoing" -> {quarkField, -quarkField},
   "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2}|>,
 "Real" -> <|"Loops" -> 0, "Incoming" -> {V[1], V[5]}, "Outgoing" -> {quarkField, -quarkField, V[5]},
   "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2, k3}|>,
 "Virtual" -> <|"Loops" -> 1, "Incoming" -> {V[1], V[5]}, "Outgoing" -> {quarkField, -quarkField},
   "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2}|>,
 "AuxHqqBorn" -> <|"Loops" -> 0, "Incoming" -> {V[1], quarkField}, "Outgoing" -> {quarkField, V[5]},
   "IncomingMomenta" -> {q, p}, "OutgoingMomenta" -> {k1, k2}|>,
 "ChargeVertex" -> <|"Loops" -> 0, "Incoming" -> {V[1]}, "Outgoing" -> {quarkField, -quarkField},
   "IncomingMomenta" -> {q}, "OutgoingMomenta" -> {k1, k2}|>|>;
species[field_] := Which[field === V[1], photon, field === V[5], gluon,
  field === quarkField, quark, field === -quarkField, antiquark, True, Missing["UnknownField", field]];

(* Valence and connected-graph identities determine the requested coupling orders. *)
strongPower = ng /. First[Solve[{
  3 (v3 + ve) + 4 v4 == 2 ni + ne,
  nl == ni - v3 - v4 - ve + 1,
  ng == v3 + 2 v4, ve == nPhoton}, {ng, ni, v3, ve}]];
gate["graph identity removes internal vertex counts", FreeQ[strongPower, ni | v3 | v4 | ve]];

generate[label_] := Module[{spec = requests[label], path, fingerprint, saved, top, diagrams, raw,
    amplitudes, degrees, expected, allFields},
  path = FileNameJoin[{cache, label <> ".wl"}];
  fingerprint = Hash[{sourceHash, spec, $Version, $FeynCalcVersion}, "SHA256"];
  If[FileExistsQ[path], saved = Get[path];
    If[AssociationQ[saved] && saved["InputHash"] === fingerprint, Print["Reuse ", label]; Return[saved]]];
  Print["Generate ", label, "; memory = ", MemoryInUse[]];
  top = CreateTopologies[spec["Loops"], Length[spec["Incoming"]] -> Length[spec["Outgoing"]],
    ExcludeTopologies -> {Tadpoles, WFCorrections}];
  diagrams = InsertFields[top, spec["Incoming"] -> spec["Outgoing"],
    InsertionLevel -> {Classes}, Model -> "SMQCD", ExcludeParticles -> excluded];
  raw = CreateFeynAmp[diagrams, Truncated -> False, PreFactor -> 1];
  amplitudes = FCFAConvert[raw, IncomingMomenta -> spec["IncomingMomenta"],
    OutgoingMomenta -> spec["OutgoingMomenta"], LoopMomenta -> If[spec["Loops"] == 0, {}, {ell}],
    UndoChiralSplittings -> True, ChangeDimension -> D, List -> True, SMP -> True,
    Contract -> False, DropSumOver -> True, FinalSubstitutions -> massRules] // DotSimplify //
      (DiracSimplify[#, DiracTraceEvaluate -> True] &);
  amplitudes = DeleteCases[amplitudes, 0];
  gate[label <> " has nonzero generated amplitudes", Length[amplitudes] > 0];
  gate[label <> " is massless", FreeQ[amplitudes, SMP["m_u" | "m_d" | "m_s" | "m_c" | "m_b" | "m_t"]]];
  allFields = Join[spec["Incoming"], spec["Outgoing"]];
  expected = {Count[allFields, V[1]], strongPower /.
    {ne -> Length[allFields], nl -> spec["Loops"], nPhoton -> Count[allFields, V[1]]}};
  degrees = DeleteDuplicates[({Exponent[#, SMP["e"]], Exponent[#, SMP["g_s"]]} & /@ amplitudes)];
  gate[label <> " coupling order matches the graph identity", degrees === {expected}];
  gate[label <> " external species identified", FreeQ[species /@ allFields, _Missing]];
  Print[label, ": graph count = ", Length[amplitudes], "; coupling degrees = ", InputForm[degrees]];
  saved = <|"Amplitudes" -> amplitudes, "Diagrams" -> diagrams, "Raw" -> raw,
    "GraphCount" -> Length[amplitudes], "CouplingDegrees" -> degrees,
    "IncomingSpecies" -> (species /@ spec["Incoming"]), "OutgoingSpecies" -> (species /@ spec["Outgoing"]),
    "Request" -> spec, "InputHash" -> fingerprint|>;
  atomicPut[saved, path];
  ClearSystemCache[];
  saved];

packets = Association@Table[label -> bounded[generate[label], label], {label, Keys[requests]}];
amplitudes = Map[#["Amplitudes"] &, packets];
result = Join[amplitudes, <|"GraphCounts" -> Map[#["GraphCount"] &, packets],
  "CouplingDegrees" -> Map[#["CouplingDegrees"] &, packets],
  "IncomingSpecies" -> Map[#["IncomingSpecies"] &, packets],
  "OutgoingSpecies" -> Map[#["OutgoingSpecies"] &, packets], "ObservedSpecies" -> quark,
  "Requests" -> requests, "FeynArtsPreFactor" -> 1,
  "LoopMeasure" -> HoldForm[mu^(2 eps) Integrate[loopIntegrand, ell]/(2 Pi)^(4 - 2 eps)],
  "ExternalLegs" -> "WFCorrections excluded; generated massless external residues are added in S07",
  "SourceHash" -> sourceHash, "WolframVersion" -> $Version, "FeynCalcVersion" -> $FeynCalcVersion,
  "Inputs" -> "FeynArts SMQCD and paper channel definitions; no prior channel result or authors coefficient"|>];
atomicPut[result, FileNameJoin[{root, "s01_result.wl"}]];
atomicPut[Map[KeyTake[#, {"Diagrams", "Raw", "Request", "InputHash"}] &, packets],
  FileNameJoin[{root, "s01_diagrams.wl"}]];
Print["S01_SUCCESS; peak kernel memory = ", MaxMemoryUsed[]];
Quit[];

(* Generated two-point functions, bare propagator residues, and MS coupling renormalization. *)
$HistoryLength = 0;
Unprotect[System`Discard];
$FeynCalcStartupMessages = False;
FeynCalc`$FeynHelpersLoadInterfaces = {"PackageX"};
$LoadAddOns = {"FeynArts", "FeynHelpers"};
Get["FeynCalc`"];
$FAVerbose = 0;
$KeepLogDivergentScalelessIntegrals = True;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, generateSelf, colorCoefficient, propagatorResidue];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
gate["accepted Born and virtual inputs exist", And @@
  (FileExistsQ[FileNameJoin[{root, #}]] & /@ {"s02_result.wl", "s01_result.wl", "s04_result.wl"})];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
virtual = Get[FileNameJoin[{root, "s04_result.wl"}]];
Scan[Function[entry, gate[entry[[1]] <> " source identity", entry[[2]]["SourceHash"] ===
  FileHash[FileNameJoin[{root, entry[[3]]}], "SHA256"]]],
  {{"S01", generated, "s01_generate_amplitudes.wl"}, {"S02", born, "s02_born_and_projectors.wl"},
   {"S04", virtual, "s04_virtual_integrals.wl"}}];
massRules = Thread[(SMP /@ {"m_u", "m_d", "m_s", "m_c", "m_b", "m_t"}) -> 0];
electroweak = {S[_], V[1 | 2 | 3 | 4], U[1 | 2 | 3 | 4], F[1 | 2]};
paxMeasure = 1/(2 Pi)^(4 - 2 Epsilon);
selfLoopOrder = 1;
strongPower = ng /. First[Solve[{3 (v3 + ve) + 4 v4 == 2 ni + ne,
  nl == ni - v3 - v4 - ve + 1, ng == v3 + 2 v4, ve == nPhoton}, {ng, ni, v3, ve}]];
gate["self-energy graph identity removes internal counts", FreeQ[strongPower, ni | v3 | v4 | ve]];
FCClearScalarProducts[];
SPD[v, v] = rho;

generateSelf[field_, exclusions_, label_] := Module[{topologies, diagrams, raw, amplitudes, loopFields},
  Print["Generate two-point diagrams: ", label];
  topologies = CreateTopologies[selfLoopOrder, 1 -> 1, ExcludeTopologies -> {Tadpoles}];
  diagrams = InsertFields[topologies, {field} -> {field}, Model -> "SMQCD",
    InsertionLevel -> {Particles}, ExcludeParticles -> exclusions];
  If[label === "one quark flavor",
    loopFields = DeleteDuplicates[Cases[diagrams, particle : F[3 | 4, ___] :> particle, Infinity]];
    Print["Selected loop fermions: ", InputForm[loopFields]];
    Put[diagrams, FileNameJoin[{root, "s07_one_flavor_diagrams.wl"}]];
    gate["closed flavor is exactly the selected massless quark",
      DeleteDuplicates[Cases[loopFields, F[3, {i_Integer, ___}] :> i, Infinity]] === {1} &&
        FreeQ[loopFields, F[4, ___]]]];
  raw = CreateFeynAmp[diagrams, Truncated -> True, PreFactor -> 1];
  amplitudes = FCFAConvert[raw, IncomingMomenta -> {v}, OutgoingMomenta -> {v},
    LoopMomenta -> {ell}, UndoChiralSplittings -> True, ChangeDimension -> D,
    List -> True, SMP -> True, Contract -> False, DropSumOver -> True,
    FinalSubstitutions -> massRules] // DotSimplify //
      (DiracSimplify[#, DiracTraceEvaluate -> True] &);
  gate["generated two-point QCD coupling order", Length[amplitudes] > 0 &&
    And @@ (Exponent[#, SMP["g_s"]] == (strongPower /. {ne -> Length[{field, field}], nl -> selfLoopOrder, nPhoton -> Count[{field, field}, V[1]]}) && FreeQ[#, SMP["e"]] & /@ amplitudes)];
  Print[label, ": generated ", Length[amplitudes], " diagrams."];
  <|"Diagrams" -> diagrams, "Amplitudes" -> (amplitudes /. SMP["g_s"] -> 1)|>];

colorCoefficient[amplitude_] := Module[{value, identities},
  value = SUNSimplify[Contract[amplitude], Explicit -> True, SUNNToCACF -> False];
  identities = DeleteDuplicates[Cases[value, _SUNDelta | _SUNFDelta, Infinity]];
  gate["two-point color structure is the external identity", Length[identities] == 1 &&
    FreeQ[value, _SUNTF | _SUNTrace | _SUNF]];
  value/First[identities]];

propagatorResidue[data_, field_, label_] := Module[{amplitude, indices, free, projector,
  insertion, denominator, ratio, longitudinal, reduced, onShell, evaluated},
  amplitude = colorCoefficient[Total[data["Amplitudes"]]];
  If[field === quark,
    free = I GSD[v]/rho;
    insertion = DiracTrace[GSD[v].free.amplitude.free];
    denominator = DiracTrace[GSD[v].free];
    ratio = DiracSimplify[insertion, DiracTraceEvaluate -> True]/
      DiracSimplify[denominator, DiracTraceEvaluate -> True],
    indices = DeleteDuplicates[Cases[amplitude, _LorentzIndex, Infinity]];
    gate["two external vector indices remain", Length[indices] == 2];
    amplitude = amplitude /. Thread[indices -> {LorentzIndex[muSE, D], LorentzIndex[nuSE, D]}];
    longitudinal = bounded[TID[Contract[FVD[v, muSE] FVD[v, nuSE] amplitude]/rho^2,
      ell, ToPaVe -> True] // PaVeReduce // Factor, label <> " longitudinal"];
    gate[label <> " gluon self energy is transverse", longitudinal === 0];
    projector = MTD[muSE, nuSE] - FVD[v, muSE] FVD[v, nuSE]/rho;
    free = -I MTD[muSE, nuSE]/rho;
    insertion = projector (-I MTD[muSE, aaSE]/rho) *
      (amplitude /. {muSE -> aaSE, nuSE -> bbSE}) (-I MTD[bbSE, nuSE]/rho);
    ratio = Contract[insertion]/Contract[projector free]];
  ratio = Contract[ratio] // ExpandScalarProduct;
  Print[label, ": reduce propagator insertion."];
  reduced = bounded[TID[ratio, ell, ToPaVe -> True] // PaVeReduce // Factor, label <> " PV"];
  onShell = reduced /. rho -> 0;
  gate["on-shell residue has no undefined kinematic quotient", FreeQ[onShell,
    ell | rho | Indeterminate | ComplexInfinity | DirectedInfinity]];
  evaluated = bounded[PaXEvaluateUVIRSplit[onShell, PaXImplicitPrefactor -> paxMeasure,
    PaXAnalytic -> True] /. ScaleMu -> mu, label <> " on-shell UV/IR"];
  gate["scaleless residue vanishes after identifying regulators",
    Factor[evaluated /. {EpsilonUV -> Epsilon, EpsilonIR -> Epsilon}] === 0];
  gate["residue has both UV and IR parts", !FreeQ[evaluated, EpsilonUV] && !FreeQ[evaluated, EpsilonIR]];
  gate["external residue is real", Factor[ComplexExpand[evaluated - Conjugate[evaluated]]] === 0];
  Print[label, " propagator residue: ", InputForm[evaluated]];
  <|"ReducedInsertion" -> reduced, "OnShell" -> evaluated|>];

quarkData = bounded[generateSelf[F[3, {1}], electroweak, "quark"], "quark generation"];
gluonData = bounded[generateSelf[V[5], Join[electroweak, {F[_]}], "gluon and ghost"], "gluon generation"];
flavorData = bounded[generateSelf[V[5], {S[_], V[_], U[_], F[1 | 2 | 4],
  F[3, {2}], F[3, {3}]}, "one quark flavor"], "flavor generation"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
Print["Parallel budget inputs: ", InputForm[{slots, $ProcessorCount, $MaxLicenseSubprocesses}]];
Needs["SubKernels`LocalKernels`"];
kernelCommand = "/u/local/apps/mathematica/13.1/Executables/WolframKernel -subkernel -mathlink";
CloseKernels[];
Do[LaunchKernels[SubKernels`LocalKernels`LocalMachine[kernelCommand]], {Min[8, slots, 3]}];
workerCount = Length[Kernels[]];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["residue workers share compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0; $FeynCalcStartupMessages = False;
    FeynCalc`$FeynHelpersLoadInterfaces = {"PackageX"}; $LoadAddOns = {"FeynHelpers"};
    Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, colorCoefficient, propagatorResidue, paxMeasure];
  ParallelEvaluate[$KeepLogDivergentScalelessIntegrals = True; FCClearScalarProducts[]; SPD[v, v] = rho],
  runtimeEvidence = {}; Print["No local parallel kernel available; residue calculations remain serial."]];
residueTask[spec_] := Catch[propagatorResidue @@ spec, "StageFailure"];
DistributeDefinitions[residueTask];
$DistributedContexts = None;
residueTasks = {{quarkData, quark, "quark"}, {gluonData, gluon, "gluon and ghost"},
  {flavorData, gluon, "one quark flavor"}};
residueValues = If[workerCount > 0, ParallelMap[residueTask, residueTasks, Method -> "FinestGrained"],
  residueTask /@ residueTasks];
gate["all generated propagator residues evaluated", And @@ (AssociationQ /@ residueValues)];
{quarkResidue, gluonResidue, flavorResidue} = residueValues;
CloseKernels[];
(* The bare Dirac-adjoint field uses the conjugate field-renormalization factor. *)
antiquarkResidue = Coefficient[ComplexExpand[Conjugate[1 + orderCounter quarkResidue["OnShell"]]], orderCounter];
gate["Dirac-adjoint residue equals the real quark residue", Factor[antiquarkResidue - quarkResidue["OnShell"]] === 0];
fieldResidues = <|quark -> quarkResidue["OnShell"], antiquark -> antiquarkResidue,
  gluon -> gluonResidue["OnShell"] + Nf flavorResidue["OnShell"]|>;
Put[<|"Quark" -> quarkResidue, "GluonGauge" -> gluonResidue,
  "GluonOneFlavor" -> flavorResidue, "FieldResidues" -> fieldResidues,
  "GeneratedInputs" -> {quarkData, gluonData, flavorData}|>,
  FileNameJoin[{root, "s07_self_energies.wl"}]];

(* External fields belong to the same generated Hgq process. *)
externalFields = DeleteCases[Join[generated["IncomingSpecies"]["Born"], generated["OutgoingSpecies"]["Born"]], photon];
gate["all generated external fields have residues", And @@ (KeyExistsQ[fieldResidues, #] & /@ externalFields)];
fieldCounts = Counts[externalFields];
externalFactor = Times @@ (Sqrt[1 + orderCounter fieldResidues[#]] & /@ externalFields);
externalInterference = Coefficient[Normal[Series[externalFactor^2, {orderCounter, 0, 1}]], orderCounter];
bornGSPowers = DeleteDuplicates[Last /@ generated["CouplingDegrees"]["Born"]];
gate["generated Born has a unique strong-coupling degree", Length[bornGSPowers] === 1];
bornGSPower = First[bornGSPowers];
couplingWeight = Coefficient[Normal[Series[(1 + orderCounter zg)^(2 bornGSPower),
  {orderCounter, 0, 1}]], orderCounter]/zg;
uvResidue[expression_] := Factor[Coefficient[Expand[expression], EpsilonUV, -1] /. Epsilon -> 0];
uvExternal = uvResidue[externalInterference];
bornD = <|"Pg" -> born["BornPg"], "Ppp" -> born["BornPpp"]|>;
couplingResidues = Association@Table[
  uvOne = uvResidue[virtual["InterferenceBeforeHermitianConjugate"][mode]];
  gate["UV extraction contains no IR regulator", FreeQ[uvOne, EpsilonIR]];
  uvFull = Factor[ComplexExpand[uvOne + Conjugate[uvOne]]];
  bornFour = bornD[mode] /. D -> 4;
  mode -> Factor[zg /. First[Solve[uvFull + bornFour (uvExternal + couplingWeight zg) == 0, zg]]],
  {mode, {"Pg", "Ppp"}}];
gate["both projectors determine the same coupling UV residue", Factor[
  couplingResidues["Pg"] - couplingResidues["Ppp"]] === 0];
couplingResidue = couplingResidues["Pg"];
gate["coupling UV residue is real and kinematics independent", FreeQ[couplingResidue,
  s | t | Q2 | mu | Epsilon | EpsilonUV | EpsilonIR | _Real] &&
  Factor[ComplexExpand[couplingResidue - Conjugate[couplingResidue]]] === 0];
Print["Derived coupling residue per gs^2: ", InputForm[couplingResidue]];

(* The MS subtraction is defined before identifying UV and IR regulators. *)
msPole = 1/EpsilonUV - EulerGamma + Log[4 Pi];
renormalized = Association@Table[
  interference = virtual["InterferenceBeforeHermitianConjugate"][mode];
  hermitian = bounded[ComplexExpand[interference + Conjugate[interference],
    TargetFunctions -> {Re, Im}], mode <> " Hermitian interference"];
  counterterm = couplingWeight couplingResidue msPole (bornD[mode] /. D -> 4 - 2 Epsilon);
  withFields = hermitian + externalInterference (bornD[mode] /. D -> 4 - 2 Epsilon) + counterterm;
  gate[mode <> " complete UV cancellation", uvResidue[withFields] === 0];
  mode -> bounded[Normal[Series[withFields /. {EpsilonUV -> Epsilon, EpsilonIR -> Epsilon},
    {Epsilon, 0, 0}]], mode <> " renormalized Laurent series"], {mode, {"Pg", "Ppp"}}];
Put[<|"RenormalizedVirtual" -> renormalized, "CouplingResidue" -> couplingResidue,
  "ExternalFieldCounts" -> fieldCounts, "ExternalInterference" -> externalInterference,
  "CouplingWeight" -> couplingWeight, "Regulator" -> Epsilon, "ParallelRuntime" -> runtimeEvidence,
  "MSPole" -> msPole, "CouplingsRemoved" -> "eq^2 gs^4",
  "InputHashes" -> Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
    {name, {"s02_result.wl", "s01_result.wl", "s04_result.wl"}}],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s07_result.wl"}]];
Print["S07_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

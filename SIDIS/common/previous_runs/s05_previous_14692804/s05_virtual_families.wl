(* Scalarize the unchanged virtual interferences for a new Kira reduction. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
gate[name_, condition_] := If[!TrueQ[condition], Print["FAIL: ", name];
  If[$KernelID > 0, Throw[$Failed, "S05Failure"], CloseKernels[]; Quit[1]]];
zero[expression_] := Factor[Together[expression]] === 0;
put[value_, file_] := (Put[value, file <> ".tmp"];
  RenameFile[file <> ".tmp", file, OverwriteTarget -> True]);
SetAttributes[bounded, HoldFirst];
bounded[expression_, name_] := MemoryConstrained[TimeConstrained[expression, 1800,
  gate["time limit " <> ToString[name, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[name, InputForm], False]];
setKinematics[rows_] := (FCClearScalarProducts[];
  Scan[Function[row, With[{v = row[[1]], u = row[[2]], value = row[[3]]},
    SPD[v, u] = value; SP[v, u] = value]], rows]);
externalDenominators[expression_] := expression /.
  FeynAmpDenominator[lines__] :> Times @@
    (If[FreeQ[#, ell], FeynAmpDenominatorExplicit[FeynAmpDenominator[#]],
      FeynAmpDenominator[#]] & /@ {lines});
contract[amplitude_, mode_] := Module[{a = amplitude, b = bornAmplitude, value},
  If[mode === "Ppp", a = a /. Polarization[q, ___] -> p;
    b = b /. Polarization[q, ___] -> p];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverage];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  value = DoPolarizationSums[value, gluonMomentum, gluonReference];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  value = FCReplaceMomenta[value, {k2 -> p + q - k1}];
  ExpandScalarProduct[externalDenominators[value]]/chargeSquared];

(* GLI products here represent multiplication of factors in one integrand.
   They are combined before GLIs are interpreted as integrated quantities. *)
combineGLI[expression_] := FixedPoint[Function[value, Expand[value] /.
  {Power[GLI[id_, indices_List], power_Integer] :> GLI[id, power indices],
   GLI[id_, left_List] GLI[id_, right_List] :> GLI[id, left + right]}], expression];
mapIntegrand[expression_, id_] := Module[
  {lines, topology, numeratorRules, mapped, reconstructed, integrals, coefficients,
   denominator, position, length, scalarProducts},
  If[expression === 0, Return[<|"Coefficients" -> <||>, "Topology" -> Missing["ZeroDiagram"],
    "Targets" -> {}, "ReconstructionPassed" -> True|>]];
  lines = DeleteDuplicates[Flatten[Cases[expression,
    FeynAmpDenominator[propagators__] :> (FeynAmpDenominator /@ {propagators}), Infinity]]];
  gate[id <> " loop propagators present", Length[lines] > 0];
  topology = FCTopology[id, lines, {ell}, {p, q, k1}, {}, {}];
  gate[id <> " independent original propagators", !FCLoopBasisOverdeterminedQ[topology]];
  topology = FCLoopBasisFindCompletion[topology,
    Method -> {FAD[ell], FAD[ell + p], FAD[ell + q], FAD[ell + k1]}, Names -> Function[name, name]];
  gate[id <> " valid complete topology", FCLoopValidTopologyQ[topology] &&
    !FCLoopBasisIncompleteQ[topology] && !FCLoopBasisOverdeterminedQ[topology]];
  numeratorRules = FCLoopCreateRulesToGLI[topology];
  length = Length[topology[[2]]];
  mapped = expression /. FeynAmpDenominator[propagators__] :>
    Times @@ Map[Function[propagator,
      denominator = FeynAmpDenominator[propagator];
      position = FirstPosition[topology[[2]], denominator, Missing["UnmappedPropagator"]];
      gate[id <> " denominator position", !MissingQ[position]];
      GLI[id, UnitVector[length, First[position]]]], {propagators}];
  mapped = combineGLI[mapped /. numeratorRules];
  gate[id <> " scalarization removes every loop scalar product", FreeQ[mapped,
    ell | _FeynAmpDenominator | _Pair | _Spinor | _DiracTrace | _DiracGamma | _SUNTF |
    _SUNTrace | _Polarization | $Failed | $Aborted]];
  integrals = Sort[DeleteDuplicates[Cases[mapped, _GLI, Infinity]]];
  coefficients = AssociationMap[Factor[Coefficient[mapped, #]] &, integrals];
  gate[id <> " expression is linear in scalar integrals", zero[mapped -
    Total[KeyValueMap[Times, coefficients]]]];
  reconstructed = FeynAmpDenominatorExplicit[FCLoopFromGLI[mapped, {topology}]];
  gate[id <> " exact original-integrand reconstruction", zero[
    ExpandScalarProduct[reconstructed - FeynAmpDenominatorExplicit[expression]]]];
  scalarProducts = DeleteDuplicates[Cases[1/(FeynAmpDenominatorExplicit[#]) & /@ topology[[2]],
    _Pair, Infinity]];
  <|"Coefficients" -> coefficients, "Topology" -> topology, "Targets" -> integrals,
    "NumeratorRules" -> numeratorRules, "ScalarProducts" -> scalarProducts,
    "ReconstructionPassed" -> True|>];

task[mode_, index_] := Catch[Module[{file, saved, value, result, id},
  id = prefix <> mode <> IntegerString[index, 10, 2];
  file = FileNameJoin[{cache, id <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash &&
      TrueQ[saved["ReconstructionPassed"]], Return[saved]]];
  Print["VIRTUAL ", channel, " ", mode, " diagram ", index, " kernel ", $KernelID];
  value = bounded[contract[virtualAmplitudes[[index]], mode], id <> " contraction"];
  gate[id <> " closed spin/color trace", FreeQ[value,
    _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Polarization]];
  result = bounded[mapIntegrand[value, id], id <> " scalarization"];
  result = Join[result, <|"InputHash" -> inputHash, "Mode" -> mode,
    "Diagram" -> index, "ContractedIntegrand" -> value|>];
  put[result, file]; ClearSystemCache[]; result], "S05Failure"];

sourceHash = FileHash[$InputFileName, "SHA256"];
geometry = Get[FileNameJoin[{root, "s02_result.wl"}]];
gate["accepted common definitions", TrueQ[geometry["Accepted"]]];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
If[slots > 1, LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[4, slots],
  "TimeConstraint" -> 60]]];
workers = Length[Kernels[]];
If[workers > 0, ParallelEvaluate[$HistoryLength = 0; Global`$FeynCalcStartupMessages = False;
  Get["FeynCalc`"]];
  runtime = ParallelEvaluate[{$MachineName, $Version}];
  gate["workers share the compute node", And @@ (First[#] === $MachineName & /@ runtime)], runtime = {}];
Print["VIRTUAL_WORKERS ", workers];
$DistributedContexts = None;
channelResults = <||>; allTopologies = {}; allTargets = {};
Do[
  inputDirectory = FileNameJoin[{root, channel, "s01_inputs"}];
  born = Get[FileNameJoin[{inputDirectory, "s02_result.wl"}]];
  generatedFile = FileNameJoin[{inputDirectory, If[channel === "Hqg", "s04_result.wl", "s01_result.wl"]}];
  generated = Get[generatedFile];
  If[channel === "Hqg",
    real = Get[FileNameJoin[{inputDirectory, "s05_result.wl"}]];
    chargeSquared = real["ModelChargeSquared"];
    bornScalarProducts = real["BornScalarProducts"];
    quarkStateInput = Get[FileNameJoin[{root, "Hqq", "s01_inputs", "s02_result.wl"}]];
    initialAverage = 1/(quarkStateInput["QuarkSpinCount"] quarkStateInput["FundamentalDimension"]),
    chargeSquared = born["ModelChargeSquared"];
    bornScalarProducts = born["BornScalarProducts"];
    initialAverage = born["InitialAverages"][channel]];
  {gluonMomentum, gluonReference} = Switch[channel, "Hqq", {k2, p}, "Hqg", {k1, p}, "Hgq", {p, k1}];
  setKinematics[bornScalarProducts];
  bornAmplitude = Total[generated["Born"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
  virtualAmplitudes = generated["Virtual"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
  Do[gate[channel <> " inherited Born normalization " <> mode,
    bounded[zero[contract[bornAmplitude, mode] - born["Born" <> mode]], channel <> " Born"]],
    {mode, {"Pg", "Ppp"}}];
  Print["BORN_NORMALIZATION_ACCEPTED ", channel, " virtual diagrams ", Length[virtualAmplitudes]];
  inputHash = Hash[{sourceHash, FileHash[generatedFile, "SHA256"],
    FileHash[FileNameJoin[{inputDirectory, "s02_result.wl"}], "SHA256"],
    bornScalarProducts, initialAverage, chargeSquared, $Version, $FeynCalcVersion}, "SHA256"];
  cache = FileNameJoin[{root, channel, "s05_cache", IntegerString[inputHash, 16]}];
  If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
  prefix = "V" <> channel;
  If[workers > 0, DistributeDefinitions[gate, zero, put, bounded, setKinematics,
    externalDenominators, contract, combineGLI, mapIntegrand, task, channel, prefix,
    bornAmplitude, virtualAmplitudes, initialAverage, chargeSquared, gluonMomentum,
    gluonReference, bornScalarProducts, inputHash, cache];
    ParallelEvaluate[setKinematics[bornScalarProducts]]];
  tasks = Flatten[Table[{mode, index}, {mode, {"Pg", "Ppp"}}, {index, Length[virtualAmplitudes]}], 1];
  results = If[workers > 0, ParallelMap[task @@ # &, tasks, Method -> "FinestGrained"], task @@ # & /@ tasks];
  gate[channel <> " all virtual integrands mapped", FreeQ[results, $Failed | $Aborted]];
  topologies = DeleteCases[Lookup[results, "Topology"], _Missing];
  targets = Sort[DeleteDuplicates[Flatten[Lookup[results, "Targets"]]]];
  put[<|"Channel" -> channel, "DiagramMaps" -> results, "Topologies" -> topologies,
    "Targets" -> targets, "BornScalarProducts" -> bornScalarProducts,
    "InitialAverage" -> initialAverage, "ModelChargeSquared" -> chargeSquared,
    "InterferenceConvention" -> "Before adding the Hermitian conjugate",
    "Measure" -> mu^(2 Epsilon)/(2 Pi)^(4 - 2 Epsilon),
    "CouplingsRemoved" -> "eq^2 gs^4", "SourceHash" -> sourceHash,
    "InputHash" -> inputHash, "BornNormalizationAccepted" -> True,
    "Accepted" -> True, "IntegralEvaluationPerformed" -> False|>,
    FileNameJoin[{root, channel, "s05_result.wl"}]];
  AssociateTo[channelResults, channel -> <|"File" -> channel <> "/s05_result.wl",
    "Hash" -> FileHash[FileNameJoin[{root, channel, "s05_result.wl"}], "SHA256"],
    "DiagramCount" -> Length[virtualAmplitudes], "TargetCount" -> Length[targets]|>];
  allTopologies = Join[allTopologies, topologies]; allTargets = Union[allTargets, targets];
  Print["VIRTUAL_CHANNEL_MAPPED ", channel, " targets ", Length[targets]];
  Clear[results, generated, born, virtualAmplitudes]; ClearSystemCache[], {channel, {"Hqq", "Hqg", "Hgq"}}];
CloseKernels[];
put[<|"Channels" -> channelResults, "Topologies" -> allTopologies,
  "Targets" -> allTargets, "SourceHash" -> sourceHash, "ParallelRuntime" -> runtime,
  "Accepted" -> True, "IntegralEvaluationPerformed" -> False|>, FileNameJoin[{root, "s05_result.wl"}]];
Print["S05_SUCCESS: ", Length[allTargets], " virtual scalar-integral targets."];
Quit[0];

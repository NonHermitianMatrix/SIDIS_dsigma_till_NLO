(* Paper Appendix E: diagram-wise interference, PV reduction, explicit loop measure. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
FeynCalc`$FeynHelpersLoadInterfaces = {"PackageX"};
$LoadAddOns = {"FeynHelpers"};
Print["Loading FeynCalc and the Package-X interface."];
Get["FeynCalc`"];
Print["Loop interface loaded."];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, contractVirtual, externalDenominators, evaluateDiagram, atomicPut, diagramTask];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 1800,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
measure = mu^(2 Epsilon)/(2 Pi)^(4 - 2 Epsilon);
(* Package-X includes ScaleMu^(2 Epsilon); identify it with the paper's mu. *)
paxMeasure = measure/mu^(2 Epsilon);
$KeepLogDivergentScalelessIntegrals = True;

FCClearScalarProducts[];
SPD[r, r] = -Q2;
backend = bounded[PaXEvaluateUVIRSplit[FAD[ell, ell + r], ell,
  PaXImplicitPrefactor -> paxMeasure, PaXC0Expand -> True,
  PaXD0Expand -> True, PaXAnalytic -> True] /. ScaleMu -> mu, "loop backend"];
gate["loop backend evaluates the spacelike bubble", FreeQ[backend,
  _FeynAmpDenominator | _PaVe | _PaXEvaluateUVIRSplit | _PaXEvaluate]];
gate["bubble distinguishes UV from IR", !FreeQ[backend, EpsilonUV] &&
  FreeQ[backend, EpsilonIR]];
atomicPut[<|"Bubble" -> backend, "Measure" -> measure,
  "Backend" -> "FeynHelpers bundled OneLoopFromPackageX"|>,
  FileNameJoin[{root, "s04_backend.wl"}]];
Print["Loop backend: ", InputForm[backend]];

gate["generated amplitudes and accepted Born input exist", And @@
  (FileExistsQ[FileNameJoin[{root, #}]] & /@
    {"s01_result.wl", "s02_result.wl"})];
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
gate["S01 source identity", generated["SourceHash"] === FileHash[FileNameJoin[{root, "s01_generate_amplitudes.wl"}], "SHA256"]];
gate["S02 source identity", born["SourceHash"] === FileHash[FileNameJoin[{root, "s02_born_and_projectors.wl"}], "SHA256"]];
chargeSquared = born["ModelChargeSquared"];
initialAverage = born["InitialAverages"]["Hqq"];
bornScalarProducts = born["BornScalarProducts"];
FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], val = row[[3]]},
  SPD[v, w] = val; SP[v, w] = val]], bornScalarProducts];
bornAmplitude = Total[generated["Born"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
virtualAmplitudes = generated["Virtual"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
physical = Q2 > 0 && s > 0 && -Q2 - s < t < 0 && mu > 0 && SUNN > 1;
$Assumptions = physical;
sourceHash = FileHash[$InputFileName, "SHA256"];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"],
  FileHash[FileNameJoin[{root, "s01_result.wl"}], "SHA256"],
  FileHash[FileNameJoin[{root, "s02_result.wl"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "s04_cache", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];

externalDenominators[expression_] := expression /.
  FeynAmpDenominator[propagators__] :> Times @@
    (If[FreeQ[#, ell], FeynAmpDenominatorExplicit[FeynAmpDenominator[#]],
      FeynAmpDenominator[#]] & /@ {propagators});

contractVirtual[amplitude_, mode_] := Module[{a = amplitude, b = bornAmplitude, value},
  If[mode === "Ppp", a = a /. Polarization[q, ___] -> p;
    b = b /. Polarization[q, ___] -> p];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverage];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  value = DoPolarizationSums[value, k2, p];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  value = FCReplaceMomenta[value, {k2 -> p + q - k1}];
  value = externalDenominators[value] // ExpandScalarProduct;
  value/chargeSquared];

evaluateDiagram[mode_, index_] := Module[{file, saved, contracted, reduced, evaluated},
  file = FileNameJoin[{cache, mode <> "_" <> IntegerString[index, 10, 2] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash, Return[saved["Value"]]]];
  Print[mode, " virtual diagram ", index, "; contracting; memory = ", MemoryInUse[]];
  contracted = bounded[contractVirtual[virtualAmplitudes[[index]], mode], {mode, index, "trace"}];
  gate["virtual interference has no open spin, color, or polarization objects",
    FreeQ[contracted, _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Polarization]];
  Print[mode, " virtual diagram ", index, "; PV reduction."];
  reduced = bounded[TID[contracted, ell, ToPaVe -> True, UsePaVeBasis -> True],
    {mode, index, "PV"}];
  gate["PV reduction eliminates loop momentum", FreeQ[reduced, ell]];
  Print[mode, " virtual diagram ", index, "; analytic loop integrals."];
  evaluated = bounded[PaXEvaluateUVIRSplit[reduced,
    PaXImplicitPrefactor -> paxMeasure, PaXC0Expand -> True, PaXD0Expand -> True,
    PaXAnalytic -> True] /. ScaleMu -> mu, {mode, index, "Package-X"}];
  gate["all loop integrals evaluated", FreeQ[evaluated,
    _PaVe | _A0 | _B0 | _C0 | _D0 | _FeynAmpDenominator |
    _PaXEvaluate | _PaXEvaluateUVIRSplit | _TID | _Real | $Failed | $Aborted]];
  atomicPut[<|"InputHash" -> inputHash, "Value" -> evaluated|>, file];
  evaluated];

diagramTask[spec_] := Catch[evaluateDiagram @@ spec, "StageFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
workerCount = Length[Kernels[]];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["workers share the allocated compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0; $FeynCalcStartupMessages = False;
    FeynCalc`$FeynHelpersLoadInterfaces = {"PackageX"}; $LoadAddOns = {"FeynHelpers"};
    Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, atomicPut, contractVirtual, externalDenominators,
    evaluateDiagram, diagramTask, bornAmplitude, virtualAmplitudes, chargeSquared,
    initialAverage, bornScalarProducts, cache, inputHash, paxMeasure, physical];
  ParallelEvaluate[$KeepLogDivergentScalelessIntegrals = True; $Assumptions = physical;
    FCClearScalarProducts[];
    Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
      SPD[v, w] = value; SP[v, w] = value]], bornScalarProducts]],
  runtimeEvidence = {}; Print["Serial execution: allocation or license provides no multiple local kernels."]];
Print["Independent-diagram worker count = ", workerCount];
$DistributedContexts = None;
result = <||>;
Do[
  tasks = Table[{mode, index}, {index, Length[virtualAmplitudes]}];
  values = If[workerCount > 0, ParallelMap[diagramTask, tasks, Method -> "FinestGrained"], diagramTask /@ tasks];
  gate[mode <> " all virtual diagrams completed", FreeQ[values, $Failed | $Aborted]];
  AssociateTo[result, mode -> Total[values]], {mode, {"Pg", "Ppp"}}];
CloseKernels[];
atomicPut[<|"InterferenceBeforeHermitianConjugate" -> result,
  "HermitianRule" -> HoldForm[interference + Conjugate[interference]],
  "DimensionRegulator" -> Epsilon, "UVRegulator" -> EpsilonUV,
  "IRRegulator" -> EpsilonIR, "Measure" -> measure,
  "CouplingsRemoved" -> "eq^2 gs^4", "InputHash" -> inputHash,
  "SourceHash" -> sourceHash, "ParallelRuntime" -> runtimeEvidence, "AuthorsCoefficientsUsed" -> False,
  "ExternalLegs" -> generated["ExternalLegs"],
  "Renormalization" -> "not yet applied", "PhysicalRegion" -> physical|>,
  FileNameJoin[{root, "s04_result.wl"}]];
Print["S04_SUCCESS; peak main-kernel memory = ", MaxMemoryUsed[], " bytes."];
Quit[];


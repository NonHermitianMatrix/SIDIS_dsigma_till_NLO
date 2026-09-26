(* Fresh Hgq real-amplitude contractions with physical gluon sums. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, atomicPut, scalarPair, cachedPair, pairTask];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 1800,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
Scan[Function[entry, gate[entry[[1]] <> " source identity", entry[[2]]["SourceHash"] ===
  FileHash[FileNameJoin[{root, entry[[3]]}], "SHA256"]]],
  {{"S01", generated, "s01_generate_amplitudes.wl"}, {"S02", born, "s02_born_and_projectors.wl"}}];
realAmplitudes = generated["Real"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
chargeSquared = born["ModelChargeSquared"];
initialAverage = born["InitialAverages"]["Hgq"];
realScalarProducts = born["RealScalarProducts"];
FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
  SPD[v, w] = value; SP[v, w] = value]], realScalarProducts];
finalSpecies = generated["OutgoingSpecies"]["Real"];
tagWeight = Count[finalSpecies, generated["ObservedSpecies"]]/Times @@ (Factorial /@ Values[Counts[finalSpecies]]);
gate["observed species occurs in generated final state", Count[finalSpecies, generated["ObservedSpecies"]] > 0];
Print["Generated-species tagging weight = ", InputForm[tagWeight]];
sourceHash = FileHash[$InputFileName, "SHA256"];
inputHash = Hash[{sourceHash, FileHash[FileNameJoin[{root, "s01_result.wl"}], "SHA256"],
  FileHash[FileNameJoin[{root, "s02_result.wl"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "s03_cache", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];

scalarPair[left_, right_, mode_] := Module[{a = left, b = right, value},
  Switch[mode,
    "Ppp", a = a /. Polarization[q, ___] -> p; b = b /. Polarization[q, ___] -> p,
    "PhotonWard", a = a /. Polarization[q, ___] -> q; b = b /. Polarization[q, ___] -> q,
    "GluonPWard", a = a /. Polarization[p, ___] -> p; b = b /. Polarization[p, ___] -> p,
    "Gluon3Ward", a = a /. Polarization[k3, ___] -> k3; b = b /. Polarization[k3, ___] -> k3];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverage];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[MemberQ[{"Pg", "GluonPWard", "Gluon3Ward"}, mode],
    value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  If[mode =!= "GluonPWard", value = DoPolarizationSums[value, p, k1]];
  If[mode =!= "Gluon3Ward", value = DoPolarizationSums[value, k3, p]];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[value]]]];

cachedPair[mode_, i_, j_] := Module[{file, saved, value},
  file = FileNameJoin[{cache, mode <> "_" <> IntegerString[i, 10, 2] <> "_" <> IntegerString[j, 10, 2] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash, Return[saved["Value"]]]];
  Print[mode, " pair ", i, ",", j, "; kernel ", $KernelID, "; memory ", MemoryInUse[]];
  value = bounded[scalarPair[realAmplitudes[[i]], realAmplitudes[[j]], mode], {mode, i, j}];
  If[i != j, value = Factor[ComplexExpand[value + Conjugate[value]]]];
  value = Factor[tagWeight value/chargeSquared];
  gate["pair is scalar and exact", FreeQ[value,
    _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Pair | _Polarization | _Real | $Failed | $Aborted]];
  atomicPut[<|"InputHash" -> inputHash, "Value" -> value|>, file];
  value];
pairTask[spec_] := Catch[cachedPair @@ spec, "StageFailure"];

slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
workers = Min[8, slots, $ProcessorCount, $MaxLicenseSubprocesses];
CloseKernels[];
If[workers > 1, LaunchKernels[workers]];
workerCount = Length[Kernels[]];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["workers share the allocated compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0; $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, atomicPut, scalarPair, cachedPair, pairTask,
    realAmplitudes, chargeSquared, initialAverage, realScalarProducts, tagWeight, cache, inputHash];
  ParallelEvaluate[FCClearScalarProducts[];
    Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
      SPD[v, w] = value; SP[v, w] = value]], realScalarProducts]],
  runtimeEvidence = {}; Print["Serial execution: allocation or license provides no multiple local kernels."]];
Print["Independent-pair worker count = ", workerCount];
$DistributedContexts = None;
results = <||>;
Do[
  tasks = Flatten[Table[{mode, i, j}, {i, Length[realAmplitudes]}, {j, i, Length[realAmplitudes]}], 1];
  pairs = If[workerCount > 0, ParallelMap[pairTask, tasks, Method -> "FinestGrained"], pairTask /@ tasks];
  gate[mode <> " all pair tasks completed", FreeQ[pairs, $Failed | $Aborted]];
  Print[mode, ": combining ", Length[pairs], " checkpointed pairs"];
  value = bounded[Factor[Total[pairs]], mode <> " sum"];
  If[StringContainsQ[mode, "Ward"], gate[mode, value === 0]];
  atomicPut[value, FileNameJoin[{root, "s03_" <> mode <> ".wl"}]];
  AssociateTo[results, mode -> value];
  Print[mode, " complete; leaves = ", LeafCount[value]],
  {mode, {"Pg", "Ppp", "PhotonWard", "GluonPWard", "Gluon3Ward"}}];
CloseKernels[];
atomicPut[<|"Contractions" -> results, "BornScalarProducts" -> born["BornScalarProducts"],
  "RealScalarProducts" -> realScalarProducts, "ModelChargeSquared" -> chargeSquared,
  "TagWeight" -> tagWeight, "InitialAverage" -> initialAverage,
  "CouplingsRemoved" -> "eq^2 gs^4", "Dimension" -> D, "InputHash" -> inputHash,
  "SourceHash" -> sourceHash, "ParallelRuntime" -> runtimeEvidence,
  "AuthorsCoefficientsUsed" -> False|>, FileNameJoin[{root, "s03_result.wl"}]];
Print["S03_SUCCESS; peak main-kernel memory = ", MaxMemoryUsed[]];
Quit[];

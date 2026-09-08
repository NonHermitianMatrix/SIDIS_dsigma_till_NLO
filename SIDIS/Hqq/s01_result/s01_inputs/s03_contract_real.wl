(* Hqq real sectors: separately checkpointed diagram pairs and charge components. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, atomicPut, photonDegree, scalarPair, cachedPair, pairTask];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name];
  If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
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
labels = generated["RealSectors"];
realAmplitudes = Association@Table[label -> (generated[label] /.
  {SMP["e"] -> 1, SMP["g_s"] -> 1}), {label, labels}];
chargeSquared = born["ModelChargeSquared"];
initialAverage = born["InitialAverages"]["Hqq"];
realScalarProducts = born["RealScalarProducts"];
FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
  SPD[v, w] = value; SP[v, w] = value]], realScalarProducts];
gluons = Association@Table[label -> Pick[generated["Requests"][label]["OutgoingMomenta"],
  generated["OutgoingSpecies"][label], gluon], {label, labels}];
tagWeights = Association@Table[label -> With[{species = generated["OutgoingSpecies"][label]},
  Count[species, generated["ObservedSpecies"]]/Times @@ (Factorial /@ Values[Counts[species]])], {label, labels}];
Print["Generated tagging weights = ", InputForm[tagWeights]];

photonDegree[amplitude_] := Module[{chains, endpoints, degrees},
  chains = Cases[amplitude, chain_Dot /; !FreeQ[chain, Polarization[q, ___]], {0, Infinity}];
  gate["photon-bearing open chains are present", Length[chains] > 0];
  endpoints = ({First[#], Last[#]} & /@ chains);
  degrees = DeleteDuplicates[Map[Function[ends, Which[
    !FreeQ[ends, Spinor[Momentum[p, D], ___]] && !FreeQ[ends, Spinor[Momentum[k1, D], ___]],
      Exponent[eq/eq, chargeRatio],
    !FreeQ[ends, Spinor[Momentum[k2, D], ___]] && !FreeQ[ends, Spinor[-Momentum[k3, D], ___]],
      Exponent[chargeRatio, chargeRatio],
    True, Missing["UnclassifiedPhotonChain", ends]]], endpoints]];
  gate["each distinct diagram has one identified charge degree", Length[degrees] === 1 && FreeQ[degrees, _Missing]];
  First[degrees]];
chargeDegrees = Association@Table[label -> If[label === "RealDistinct",
  photonDegree /@ realAmplitudes[label], ConstantArray[Exponent[1, chargeRatio], Length[realAmplitudes[label]]]],
  {label, labels}];
componentName[label_, degree_] := label <> "_Charge" <> ToString[degree];
observedFlavor = generated["Requests"]["Born"]["Incoming"][[2, 2, 1]];
flavorMultiplicity = FullSimplify[Sum[1 - KroneckerDelta[flavor, observedFlavor], {flavor, 1, Nf}],
  Element[Nf, Integers] && Nf >= observedFlavor];
gate["distinct flavor count evaluated exactly", FreeQ[flavorMultiplicity, _Sum | _Real | _ConditionalExpression]];
components = Association[Flatten[Table[With[{degrees = DeleteDuplicates[Flatten[Outer[Plus,
    chargeDegrees[label], chargeDegrees[label]]]]}, Table[componentName[label, degree] ->
  <|"Sector" -> label, "ChargeRatioPower" -> degree,
    "FlavorWeight" -> If[label === "RealDistinct", If[degree === 0, flavorMultiplicity,
      otherChargeMoment[degree]/eq^degree], 1]|>, {degree, degrees}]], {label, labels}], 1]];
momentDegrees = DeleteDuplicates[Select[Lookup[Values[components], "ChargeRatioPower"], # > 0 &]];
chargeMomentDefinitions = Association@Table[degree ->
  Inactive[Sum][(1 - KroneckerDelta[flavor, observedFlavor]) flavorCharge[flavor]^degree,
    {flavor, 1, Nf}], {degree, momentDegrees}];
modes = Association@Table[label -> Join[{"Pg", "Ppp", "PhotonWard"},
  ("GluonWard_" <> ToString[#] & /@ gluons[label])], {label, labels}];
sourceHash = FileHash[$InputFileName, "SHA256"];
inputHash = Hash[{sourceHash, FileHash[FileNameJoin[{root, "s01_result.wl"}], "SHA256"],
  FileHash[FileNameJoin[{root, "s02_result.wl"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "s03_cache", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];

scalarPair[label_, left_, right_, mode_] := Module[{a = left, b = right, value, wardLeg},
  wardLeg = SelectFirst[gluons[label], mode === "GluonWard_" <> ToString[#] &, Missing["None"]];
  Switch[mode,
    "Ppp", a = a /. Polarization[q, ___] -> p; b = b /. Polarization[q, ___] -> p,
    "PhotonWard", a = a /. Polarization[q, ___] -> q; b = b /. Polarization[q, ___] -> q];
  If[!MissingQ[wardLeg], a = a /. Polarization[wardLeg, ___] -> wardLeg;
    b = b /. Polarization[wardLeg, ___] -> wardLeg];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> initialAverage];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg" || !MissingQ[wardLeg], value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  Do[If[leg =!= wardLeg, value = DoPolarizationSums[value, leg, p]], {leg, gluons[label]}];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[value]]]];
cachedPair[label_, mode_, i_, j_] := Module[{file, saved, value, component},
  component = componentName[label, chargeDegrees[label][[i]] + chargeDegrees[label][[j]]];
  file = FileNameJoin[{cache, StringRiffle[{label, mode, ToString[i], ToString[j]}, "_"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash, Return[saved]]];
  Print[label, " ", mode, " pair ", i, ",", j, "; kernel ", $KernelID, "; memory ", MemoryInUse[]];
  value = bounded[scalarPair[label, realAmplitudes[label][[i]], realAmplitudes[label][[j]], mode],
    {label, mode, i, j}];
  If[i != j, value = Factor[ComplexExpand[value + Conjugate[value]]]];
  value = Factor[tagWeights[label] value/chargeSquared];
  gate["pair is scalar and exact", FreeQ[value,
    _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Pair | _Polarization | _Real | $Failed | $Aborted]];
  saved = <|"InputHash" -> inputHash, "Component" -> component, "Mode" -> mode, "Value" -> value|>;
  atomicPut[saved, file]; saved];
pairTask[spec_] := Catch[cachedPair @@ spec, "StageFailure"];

slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
workerCount = Length[Kernels[]];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["workers share allocated compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0; $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, atomicPut, scalarPair, cachedPair, pairTask,
    componentName, realAmplitudes, chargeDegrees, chargeSquared, initialAverage,
    realScalarProducts, tagWeights, gluons, cache, inputHash];
  ParallelEvaluate[FCClearScalarProducts[];
    Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
      SPD[v, w] = value; SP[v, w] = value]], realScalarProducts]],
  runtimeEvidence = {}; Print["Parallel launch unavailable; bounded pair tasks run serially."]];
Print["Independent-pair worker count = ", workerCount];
$DistributedContexts = None;
results = <||>; wards = <||>;
Do[
  tasks = Flatten[Table[{label, mode, i, j}, {i, Length[realAmplitudes[label]]},
    {j, i, Length[realAmplitudes[label]]}], 1];
  pairs = If[workerCount > 0, ParallelMap[pairTask, tasks, Method -> "FinestGrained"], pairTask /@ tasks];
  gate[label <> " " <> mode <> " pairs complete", FreeQ[pairs, $Failed | $Aborted]];
  groups = GroupBy[pairs, #["Component"] &];
  Do[
    Print[component, " ", mode, ": combining ", Length[groups[component]], " pairs"];
    value = bounded[Factor[Total[Lookup[groups[component], "Value"]]], {component, mode, "sum"}];
    key = component <> "__" <> mode;
    If[StringContainsQ[mode, "Ward"], gate[key, value === 0]; AssociateTo[wards, key -> value],
      AssociateTo[results, key -> value]];
    atomicPut[value, FileNameJoin[{root, "s03_" <> key <> ".wl"}]];
    Print[key, " complete; leaves = ", LeafCount[value]], {component, Keys[groups]}],
  {label, labels}, {mode, modes[label]}];
CloseKernels[];
atomicPut[<|"Contractions" -> results, "WardChecks" -> wards, "Components" -> components,
  "TensorKeys" -> Keys[results], "OtherChargeMomentDefinitions" -> chargeMomentDefinitions,
  "ObservedFlavor" -> observedFlavor, "DistinctFlavorMultiplicity" -> flavorMultiplicity,
  "ChargeDegrees" -> chargeDegrees, "BornScalarProducts" -> born["BornScalarProducts"],
  "RealScalarProducts" -> realScalarProducts, "ModelChargeSquared" -> chargeSquared,
  "TagWeights" -> tagWeights, "InitialAverage" -> initialAverage,
  "CouplingsRemoved" -> "eq^2 gs^4; each component has its separately recorded FlavorWeight",
  "Dimension" -> D, "InputHash" -> inputHash, "SourceHash" -> sourceHash,
  "ParallelRuntime" -> runtimeEvidence, "AuthorsCoefficientsUsed" -> False|>,
  FileNameJoin[{root, "s03_result.wl"}]];
Print["S03_SUCCESS; peak main-kernel memory = ", MaxMemoryUsed[]];
Quit[];

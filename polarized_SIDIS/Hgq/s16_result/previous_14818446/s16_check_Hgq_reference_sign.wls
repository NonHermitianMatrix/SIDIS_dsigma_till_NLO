(* Complete the existing independent real-projector comparison with reference pair contractions. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s16_check_Hgq_reference_sign.wls"}];
referenceRoot = FileNameJoin[{root, "Hgq", "s16_result", "reference"}];
out = DirectoryName[referenceRoot];
checks = <||>;
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 1800,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
sha[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];
put[value_, path_] := (Put[value, path <> ".tmp"];
  gate["exact native checkpoint reload", Get[path <> ".tmp"] === value];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
manifestPath = FileNameJoin[{root, "common", "s16_Hgq_reference_sign_inputs.json"}];
manifest = Import[manifestPath, "RawJSON"];
KeyValueMap[gate["pinned " <> #1, sha[FileNameJoin[{root, #1}]] === #2] &, manifest];
generated = Get[FileNameJoin[{referenceRoot, "inputs", "s01_result.wl"}]];
born = Get[FileNameJoin[{referenceRoot, "inputs", "s02_result.wl"}]];
saved = Get[FileNameJoin[{referenceRoot, "inputs", "s03_result.wl"}]];
sample = Import[FileNameJoin[{referenceRoot, "s03_result.json"}], "RawJSON"];
local = Import[FileNameJoin[{referenceRoot, "s04_result.json"}], "RawJSON"];
metadata = Import[FileNameJoin[{referenceRoot, "s01_result.json"}], "RawJSON"];
gate["unchanged original source identities", And @@ Table[packet[[1]]["SourceHash"] ===
  FileHash[FileNameJoin[{referenceRoot, "inputs", packet[[2]]}], "SHA256"],
  {packet, {{generated, "s01_generate_amplitudes.wl"}, {born, "s02_born_and_projectors.wl"},
    {saved, "s03_contract_real.wl"}}}]];
gate["unchanged independent sample and normalization", sample["SourceSHA256"] ===
  sha[FileNameJoin[{referenceRoot, "s03_sample_madgraph.py"}]] && sample["InputManifestSHA256"] ===
  sha[FileNameJoin[{referenceRoot, "s01_result.json"}]] && local["SourceSHA256"] ===
  sha[FileNameJoin[{referenceRoot, "s04_evaluate_local.wl"}]] && local["SampleSHA256"] ===
  sha[FileNameJoin[{referenceRoot, "s03_result.json"}]]];
point = SelectFirst[sample["Rows"], #["Kind"] === "real" &];
prior = SelectFirst[local["Rows"], #["ID"] === point["ID"] &];
momenta = Rationalize[point["HadronMomenta"], 0];
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot[a_, b_] := a.metric.b;
vectors = AssociationThread[{p, q, k1, k2, k3}, Lookup[momenta, {"p", "q", "k1", "k2", "k3"}]];
rules = {Q2 -> -dot[vectors[q], vectors[q]], s -> dot[vectors[p] + vectors[q], vectors[p] + vectors[q]],
  t -> dot[vectors[q] - vectors[k1], vectors[q] - vectors[k1]],
  s23 -> dot[vectors[k2] + vectors[k3], vectors[k2] + vectors[k3]],
  a12 -> dot[vectors[k1] + vectors[k2], vectors[k1] + vectors[k2]],
  u3 -> dot[vectors[p] - vectors[k3], vectors[p] - vectors[k3]]};
residuals = Table[With[{direct = dot[vectors[row[[1]]], vectors[row[[2]]]], stored = row[[3]] /. rules},
  Abs[direct - stored]/Max[1, Sqrt[(vectors[row[[1]]].vectors[row[[1]]])*
    (vectors[row[[2]]].vectors[row[[2]]])], Abs[direct], Abs[stored]]], {row, born["RealScalarProducts"]}];
gate["original invariants reproduce saved four-vector products", Max[residuals] < 10^-12];
Do[gate["sample mass shell " <> ToString[v], Abs[dot[vectors[v], vectors[v]]]/
  Max[1, vectors[v].vectors[v]] < 10^-12], {v, {p, k1, k2, k3}}];
realScalarProducts = born["RealScalarProducts"] /. rules;
initialize[] := (FCClearScalarProducts[];
  Scan[Function[row, With[{a = row[[1]], b = row[[2]], v = row[[3]]}, SPD[a, b] = v; SP[a, b] = v]], realScalarProducts]);
initialize[];
realAmplitudes = generated["Real"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
initialAverage = born["InitialAverages"]["Hgq"];
chargeSquared = born["ModelChargeSquared"];
finalSpecies = generated["OutgoingSpecies"]["Real"];
tagWeight = Count[finalSpecies, generated["ObservedSpecies"]]/Times @@ (Factorial /@ Values[Counts[finalSpecies]]);
gate["original measured species and normalization", tagWeight === saved["TagWeight"] &&
  chargeSquared === saved["ModelChargeSquared"] && initialAverage === saved["InitialAverage"]];
(* This definition is copied verbatim from the bound original S03. *)
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
originalText = Import[FileNameJoin[{referenceRoot, "inputs", "s03_contract_real.wl"}], "Text"];
definitionText = "scalarPair[left_, right_, mode_] :=" <>
  First[StringSplit[Last[StringSplit[originalText, "scalarPair[left_, right_, mode_] :="]], "\ncachedPair["]];
gate["unchanged original pair function", StringContainsQ[Import[sourcePath, "Text"], StringTrim[definitionText]]];
inputHash = Hash[{FileHash[sourcePath, "SHA256"], FileHash[manifestPath, "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s16_Hgq_reference_sign", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
pairTask[pair_] := Catch[Module[{i = First[pair], j = Last[pair], file, record, value, seconds},
  file = FileNameJoin[{cache, "Ppp_" <> IntegerString[i, 10, 2] <> "_" <> IntegerString[j, 10, 2] <> ".wl"}];
  If[FileExistsQ[file], record = Get[file]; gate["saved pair binding", record["InputHash"] === inputHash && record["Pair"] === pair]; Return[record]];
  Print["REFERENCE_PAIR_START ", pair, " kernel ", $KernelID];
  {seconds, value} = AbsoluteTiming[bounded[scalarPair[realAmplitudes[[i]], realAmplitudes[[j]], "Ppp"], pair]];
  If[i != j, value = Factor[ComplexExpand[value + Conjugate[value]]]];
  value = Factor[tagWeight value/chargeSquared];
  gate["pair is scalar and exact", FreeQ[value, _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Pair | _Polarization | _Real | $Failed | $Aborted]];
  record = <|"InputHash" -> inputHash, "Pair" -> pair, "Value" -> value, "Seconds" -> seconds|>;
  put[record, file]; Print["REFERENCE_PAIR_COMPLETE ", pair, " seconds ", seconds]; record], "StageFailure"];
pairs = Flatten[Table[{i, j}, {i, Length[realAmplitudes]}, {j, i, Length[realAmplitudes]}], 1];
control = Get[FileNameJoin[{referenceRoot, "Ppp_01_01.wl"}]];
gate["own accepted pair input identity", control["InputHash"] === Hash[{
  FileHash[FileNameJoin[{referenceRoot, "inputs", "s03_contract_real.wl"}], "SHA256"],
  FileHash[FileNameJoin[{referenceRoot, "inputs", "s01_result.wl"}], "SHA256"],
  FileHash[FileNameJoin[{referenceRoot, "inputs", "s02_result.wl"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"]];
controlFresh = pairTask[First[pairs]];
gate["entire own accepted pair exactly reproduced", AssociationQ[controlFresh] &&
  bounded[Factor[controlFresh["Value"] - (control["Value"] /. rules)] === 0, "own exact accepted pair"]];
slots = FromDigits[Environment["NSLOTS"]];
workers = Min[8, slots, $ProcessorCount, $MaxLicenseSubprocesses];
CloseKernels[]; If[workers > 1, LaunchKernels[workers]];
workerCount = Length[Kernels[]];
If[workerCount > 0,
  gate["workers share native runtime", And @@ (#[[1]] === $MachineName && #[[2]] === $Version & /@
    ParallelEvaluate[{$MachineName, $Version}])];
  ParallelEvaluate[$HistoryLength = 0; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, put, scalarPair, pairTask, realAmplitudes, initialAverage,
    chargeSquared, tagWeight, inputHash, cache, realScalarProducts, initialize];
  ParallelEvaluate[initialize[]]];
$DistributedContexts = None;
records = If[workerCount > 0, ParallelMap[pairTask, pairs, Method -> "FinestGrained"], pairTask /@ pairs];
CloseKernels[];
gate["complete generated pair coverage", AllTrue[records, AssociationQ] && Lookup[records, "Pair"] === pairs];
unit = bounded[Factor[Total[Lookup[records, "Value"]]], "reference pair total"];
dimensions = {D -> Length[metric], SUNN -> metadata["Particles"]["u"]["color"]};
originalDifference = bounded[Factor[unit - (saved["Contractions"]["Ppp"] /. rules)], "complete saved reference difference"];
n = Map[ToExpression, local["Normalization"]["real"]];
prefactor = Abs[n["AmplitudeCoupling"] n["ChargeAmplitude"] (-I/dot[vectors[q], vectors[q]])]^2;
fresh = bounded[N[prefactor unit /. dimensions, 40], "fresh scaled projector"];
gate["fresh finite real scalar", NumberQ[fresh] && FreeQ[fresh, Indeterminate | _DirectedInfinity] &&
  Abs[Im[fresh]] < 10^-25 Max[1, Abs[Re[fresh]]]];
fresh = Re[fresh];
relative[a_, b_] := Abs[a - b]/Max[Abs[a], Abs[b]];
report = <|"Schema" -> "polarized-sidis-reference-sign-comparison-v1", "Channel" -> "Hgq",
  "SourceSHA256" -> sha[sourcePath], "ManifestSHA256" -> sha[manifestPath], "Point" -> point["ID"],
  "PairCount" -> Length[pairs], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "MaximumScalarProductResidual" -> N[Max[residuals], 17],
  "OwnAcceptedPairExactlyReproduced" -> True, "CompleteSavedReferenceExactlyReproduced" -> (originalDifference === 0),
  "FreshScaledPpp" -> N[fresh, 17], "StoredScaledPpp" -> prior["LocalScaledPpp"],
  "MadGraphScaledPpp" -> point["MadGraphScaledPpp"],
  "FreshVsStoredRelativeDifference" -> N[relative[fresh, prior["LocalScaledPpp"]], 17],
  "FreshVsMadGraphRelativeDifference" -> N[relative[fresh, point["MadGraphScaledPpp"]], 17],
  "Checks" -> checks, "ProductionCoefficientsChanged" -> False|>;
put[<|"Report" -> report, "InputHash" -> inputHash, "PairRecords" -> records,
  "ExactTotal" -> unit, "ExactSavedReferenceDifference" -> originalDifference|>, FileNameJoin[{out, "s16_result.wl"}]];
Export[FileNameJoin[{out, "s16_checks.json"}], report, "RawJSON"];
gate["comparison JSON reload", Import[FileNameJoin[{out, "s16_checks.json"}], "RawJSON"]["SourceSHA256"] === sha[sourcePath]];
Print[InputForm[report]];
Print["PASS: s16_check_Hgq_reference_sign"]; Quit[0];

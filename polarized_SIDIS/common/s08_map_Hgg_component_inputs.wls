(* Keep the accepted mapper; read one pinned Hgg photon payload per worker. *)
$HistoryLength = 0;
hggAdapterPath = FileNameJoin[{Directory[], "common", "s08_map_Hgg_component_inputs.wls"}];
hggMode = Environment["POLARIZED_SIDIS_COMPONENT_STAGE"];
If[Environment["POLARIZED_SIDIS_CHANNEL"] =!= "Hgg" || !MemberQ[{"targets", "coefficients"}, hggMode] ||
  !SyntaxQ[Import[hggAdapterPath, "Text"]], Quit[1]];
hggReplace[text_, old_, new_] := Module[{changed},
  If[StringCount[text, old] =!= 1, Print["FAIL: unique Hgg loading interface"]; Quit[1]];
  changed = StringReplace[text, old -> new];
  If[!SyntaxQ[changed] || StringReplace[changed, new -> old] =!= text,
    Print["FAIL: unchanged Hgg scientific source restoration"]; Quit[1]]; changed];
hggReplaceInventory[text_] := Module[{first, last, original},
  If[StringCount[text, "tasks = {}; bookkeeping = <||>;"] =!= 1 ||
    StringCount[text, "\nruleKeys = First /@ reduction[\"Rules\"];"] =!= 1, Quit[1]];
  first = First[First[StringPosition[text, "tasks = {}; bookkeeping = <||>;"]]];
  last = First[First[StringPosition[text, "\nruleKeys = First /@ reduction[\"Rules\"];"]]] - 1;
  original = StringTake[text, {first, last}];
  If[original =!= hggOriginalInventory, Print["FAIL: original task inventory identity"]; Quit[1]];
  hggReplace[text, original, "hggInitializeTasks[];"]];
hggOriginalMapper = FileNameJoin[{Directory[], "common", "s08_result", "reference",
  "s08_map_real_spin_before_known_denominator.wls"}];
If[IntegerString[FileHash[hggOriginalMapper, "SHA256"], 16, 64] =!=
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f", Quit[1]];
hggOriginalText = Import[hggOriginalMapper, "Text"];
hggOriginalInventory = StringTake[hggOriginalText, {
  First[First[StringPosition[hggOriginalText, "tasks = {}; bookkeeping = <||>;"]]],
  First[First[StringPosition[hggOriginalText, "\nruleKeys = First /@ reduction[\"Rules\"];"]]] - 1}];

hggInitializeTasks[] := Module[{},
  gate["Hgg accepted bounded component interface", channel === "Hgg" &&
    KeyExistsQ[spin, "MappingTaskMetadata"] && KeyExistsQ[spin, "MappingTaskSources"] &&
    KeyExistsQ[spin, "ComponentStorage"]];
  hggTaskMetadata = spin["MappingTaskMetadata"]; hggTaskSources = spin["MappingTaskSources"]; hggTaskRoot = root;
  gate["Hgg complete distinct native task inventory", Length[hggTaskMetadata] > 0 &&
    Length[hggTaskMetadata] === Length[hggTaskSources] && DuplicateFreeQ[hggTaskMetadata] &&
    And @@ (Sort[Keys[#]] === Sort[{"Sector", "Kind", "Index"}] & /@ hggTaskMetadata)];
  bookkeeping = Association@Table[label -> KeyTake[spin["Sectors"][label], {
    "TagWeight", "TagWeightAppliedToTensor", "OutgoingFields", "IncomingSpinLabels",
    "OutgoingSpinLabels", "ChargeDegrees", "AmplitudeCouplingPowers"}], {label, Keys[spin["Sectors"]]}];
  tasks = Table[With[{taskIndex = index}, Join[hggTaskMetadata[[index]],
    <|"Value" :> hggTaskValue[taskIndex]|>]], {index, Length[hggTaskMetadata]}];
  gate["Hgg deferred tasks retain exact ordering", (KeyDrop[#, "Value"] & /@ tasks) === hggTaskMetadata];
  Clear[hggCachedKey, hggCachedValue];
  Print["HGG_COMPONENT_TASKS ", Length[tasks], " metadata_bytes ", ByteCount[tasks]]];

hggTaskValue[index_] := Module[{row, key, path, packet, positions, expected, actual},
  row = hggTaskSources[[index]]; key = {row["Payload"], row["Field"]};
  If[!ValueQ[hggCachedKey] || hggCachedKey =!= key,
    Clear[hggCachedValue, hggCachedKey]; ClearSystemCache[];
    path = FileNameJoin[{hggTaskRoot, row["Payload"]["File"]}];
    gate["Hgg pinned native mapping payload", FileExistsQ[path] &&
      FileHash[path, "SHA256"] === row["Payload"]["Hash"]];
    packet = bounded[Get[path], {"Hgg one native component", index}];
    gate["Hgg accepted native mapping payload", AssociationQ[packet] && packet["Channel"] === "Hgg" &&
      And @@ Values[packet["Checks"]] && KeyExistsQ[packet, row["Field"]]];
    hggCachedValue = packet[row["Field"]];
    positions = Select[Range[Length[hggTaskSources]],
      {hggTaskSources[[#]]["Payload"], hggTaskSources[[#]]["Field"]} === key &];
    expected = hggTaskMetadata[[positions]];
    actual = {};
    If[row["Field"] === "Response",
      MapIndexed[Function[{value, componentIndex}, If[value =!= 0,
        AppendTo[actual, <|"Sector" -> First[expected]["Sector"], "Kind" -> "ExtendedResponse",
          "Index" -> Prepend[componentIndex, packet["Component"]]|>]]], hggCachedValue, {2}],
      gate["Hgg original dimensional metric task", row["Field"] === "Value" && row["Index"] === {} &&
        packet["Key"] === "Scalar_PgD"];
      actual = {<|"Sector" -> First[expected]["Sector"], "Kind" -> "PhotonMetricD", "Index" -> {}|>}];
    gate["Hgg loaded component reproduces original task inventory", actual === expected &&
      And @@ MapThread[If[#1["Kind"] === "ExtendedResponse", Rest[#1["Index"]], {}] === #2["Index"] &,
        {expected, hggTaskSources[[positions]]}]];
    Clear[packet]; hggCachedKey = key];
  Extract[hggCachedValue, row["Index"]]];

hggBaselinePath = FileNameJoin[{Directory[], "common", If[hggMode === "targets",
  "s08_map_real_targets.wls", "s08_map_real_spin_compact_inputs.wls"]}];
If[IntegerString[FileHash[hggBaselinePath, "SHA256"], 16, 64] =!= If[hggMode === "targets",
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9",
  "aea8d3ac781c29b85a00d341a994420d3af5ee7f450ff7ddc0f2074e8851475f"], Quit[1]];
hggRunText = Import[hggBaselinePath, "Text"];
If[hggMode === "targets",
  hggRunText = hggReplace[hggRunText, "ToExpression[targetPrefix, InputForm];",
    "targetPrefix = hggReplaceInventory[targetPrefix]; ToExpression[targetPrefix, InputForm];"],
  hggRunText = hggReplaceInventory[hggRunText]];
hggRunText = hggReplace[hggRunText, "  DistributeDefinitions[gate, bounded,",
  "  Clear[hggCachedKey, hggCachedValue];\n" <>
  "  DistributeDefinitions[hggTaskValue, hggTaskMetadata, hggTaskSources, hggTaskRoot, hggCachedKey, hggCachedValue];\n" <>
  "  DistributeDefinitions[gate, bounded,"];
hggOutputStart = If[hggMode === "targets", "\ntargetResult = <|", "\nresult = <|"];
hggRunText = hggReplace[hggRunText, hggOutputStart,
  hggOutputStart <> "\"ComponentInputDispatchHash\" -> FileHash[hggAdapterPath, \"SHA256\"], "];
If[!SyntaxQ[hggRunText], Quit[1]];
Print["PASS: Hgg component loading leaves scientific implementation unchanged"];
If[Environment["POLARIZED_SIDIS_COMPONENT_VALIDATE_ONLY"] === "1",
  root = Directory[]; channel = "Hgg"; checks = <||>;
  gate[name_, value_] := If[TrueQ[value], AssociateTo[checks, name -> True]; Print["PASS: ", name],
    Print["FAIL: ", name]; Abort[]];
  SetAttributes[bounded, HoldFirst];
  bounded[value_, purpose_] := MemoryConstrained[TimeConstrained[value, 1200,
    gate["native input time bound " <> ToString[purpose, InputForm], False]], 4*1024^3,
    gate["native input memory bound " <> ToString[purpose, InputForm], False]];
  gate["native input comparison compute allocation", StringQ[Environment["JOB_ID"]] &&
    !StringStartsQ[$MachineName, "login"] && StringStartsQ[$UserBaseDirectory, root <> "/"]];
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
  $FeynCalcStartupMessages = False; Get["FeynCalc`"];
  hggOwnFile = "Hgg/s05_projected_components_result/Photon_1/s05_result.wl";
  hggOwnReceipt = Import[FileNameJoin[{root, DirectoryName[hggOwnFile], "s05_execution.json"}], "RawJSON"];
  hggOwnHash = FileHash[FileNameJoin[{root, hggOwnFile}], "SHA256"];
  gate["accepted own native input comparison", TrueQ[hggOwnReceipt["passed"]] &&
    hggOwnReceipt["job_id"] === "14819865" &&
    hggOwnReceipt["result_sha256"][hggOwnFile] === IntegerString[hggOwnHash, 16, 64]];
  hggOwnPacket = bounded[Get[FileNameJoin[{root, hggOwnFile}]], "actual native response"];
  gate["own input comparison native versions", hggOwnPacket["NativeVersions"] === {$Version, FeynCalc`$FeynCalcVersion} &&
    hggOwnPacket["Schema"] === "polarized-sidis-complete-photon-spin-component-v1" &&
    And @@ Values[hggOwnPacket["Checks"]]];
  hggOwnMetadata = {}; hggOwnSources = {};
  MapIndexed[Function[{value, index}, If[value =!= 0,
    AppendTo[hggOwnMetadata, <|"Sector" -> "Real", "Kind" -> "ExtendedResponse",
      "Index" -> Prepend[index, hggOwnPacket["Component"]]|>];
    AppendTo[hggOwnSources, <|"Payload" -> <|"File" -> hggOwnFile, "Hash" -> hggOwnHash|>,
      "Field" -> "Response", "Index" -> index|>]]], hggOwnPacket["Response"], {2}];
  spin = <|"MappingTaskMetadata" -> hggOwnMetadata, "MappingTaskSources" -> hggOwnSources,
    "ComponentStorage" -> <||>, "Sectors" -> <|"Real" -> <||>|>|>;
  hggInitializeTasks[];
  gate["all actual nonzero response positions retained", (KeyDrop[#, "Value"] & /@ tasks) === hggOwnMetadata];
  Clear[hggOwnPacket, spin]; ClearSystemCache[];
  hggValidationWorker[unused_] := Module[{original, accepted, began = AbsoluteTime[]},
    original = bounded[Get[FileNameJoin[{hggTaskRoot, First[hggTaskSources]["Payload"]["File"]}]], "worker original input"];
    accepted = And @@ Table[tasks[[i]]["Value"] === Extract[original["Response"], hggTaskSources[[i]]["Index"]],
      {i, Length[tasks]}];
    <|"ExactOriginalValues" -> accepted, "TaskCount" -> Length[tasks], "Checks" -> checks,
      "Seconds" -> AbsoluteTime[] - began, "PeakMemoryBytes" -> MaxMemoryUsed[],
      "NativeVersions" -> {$Version, FeynCalc`$FeynCalcVersion}|>];
  CloseKernels[];
  LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
    "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> 1, "TimeConstraint" -> 60]];
  gate["own component comparison worker available", Length[Kernels[]] === 1];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, hggTaskValue, hggTaskMetadata, hggTaskSources, hggTaskRoot,
    hggCachedKey, hggCachedValue, tasks, hggValidationWorker];
  $DistributedContexts = None;
  hggOwnComparison = First[ParallelMap[hggValidationWorker, {1}]]; CloseKernels[];
  gate["worker loaded every own response value exactly", AssociationQ[hggOwnComparison] &&
    TrueQ[hggOwnComparison["ExactOriginalValues"]] && And @@ Values[hggOwnComparison["Checks"]] &&
    hggOwnComparison["TaskCount"] === Length[tasks] && hggOwnComparison["NativeVersions"] === {$Version, FeynCalc`$FeynCalcVersion}];
  gate["both unchanged mapper input interfaces supported", SyntaxQ[hggReplaceInventory[
    Import[FileNameJoin[{root, "common", "s08_map_real_spin_compact_inputs.wls"}], "Text"]]]];
  hggProofDir = FileNameJoin[{root, channel, "s08_component_input_result"}];
  If[!DirectoryQ[hggProofDir], CreateDirectory[hggProofDir, CreateIntermediateDirectories -> True]];
  hggProofResult = <|"Schema" -> "polarized-sidis-component-input-comparison-v1", "Channel" -> channel,
    "SourceHash" -> FileHash[hggAdapterPath, "SHA256"], "PayloadHash" -> hggOwnHash,
    "OriginalValuesExactlyReproduced" -> True, "WorkerEvidence" -> hggOwnComparison,
    "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
  Put[hggProofResult, FileNameJoin[{hggProofDir, "s08_result.wl"}]];
  gate["native input comparison exact reload", Get[FileNameJoin[{hggProofDir, "s08_result.wl"}]] === hggProofResult];
  Export[FileNameJoin[{hggProofDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
    "worker_seconds" -> hggOwnComparison["Seconds"], "peak_worker_bytes" -> hggOwnComparison["PeakMemoryBytes"]|>, "RawJSON"];
  Print["PASS: s08_Hgg_component_input_comparison"]; Quit[0]];
hggProofPath = FileNameJoin[{Directory[], "Hgg", "s08_component_input_result", "s08_result.wl"}];
hggProofReceipt = Import[FileNameJoin[{DirectoryName[hggProofPath], "s08_execution.json"}], "RawJSON"];
hggProof = Get[hggProofPath];
If[!TrueQ[hggProofReceipt["passed"]] || hggProofReceipt["result_sha256"]["Hgg/s08_component_input_result/s08_result.wl"] =!=
  IntegerString[FileHash[hggProofPath, "SHA256"], 16, 64] ||
  hggProof["SourceHash"] =!= FileHash[hggAdapterPath, "SHA256"] ||
  !TrueQ[hggProof["OriginalValuesExactlyReproduced"]] || !TrueQ[And @@ Values[hggProof["Checks"]]], Quit[1]];
ToExpression[hggRunText, InputForm];

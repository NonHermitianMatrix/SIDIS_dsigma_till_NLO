(* Reuse the reference merge per integral key with exact native linearity checks. *)
$HistoryLength = 0;
mergeStudyPath = FileNameJoin[{Directory[], "common", "s08_check_pair_merge_linearity.wls"}];
mergeConfigPath = FileNameJoin[{Directory[], "common", "s08_pair_merge_inputs.json"}];
mergeBasePath = FileNameJoin[{Directory[], "common", "s08_check_quark_pair_mapping.wls"}];
If[IntegerString[FileHash[mergeBasePath, "SHA256"], 16, 64] =!=
  "890b96aead1f5c9de58b6cc6b8f1bac8d28eabcb5442b79de38da13bf8a9261a", Quit[1]];
mergeBaseText = Import[mergeBasePath, "Text"];
If[StringCount[mergeBaseText, "\nslots ="] =!= 1, Quit[1]];
mergePrefix = First[StringSplit[mergeBaseText, "\nslots ="]];
If[!SyntaxQ[mergePrefix], Quit[1]];
ToExpression[mergePrefix, InputForm];
gate["complete pair merge comparison syntax", SyntaxQ[Import[mergeStudyPath, "Text"]]];
mergeConfig = Import[mergeConfigPath, "RawJSON"];
gate["pair merge input schema", mergeConfig["schema"] === "polarized-sidis-pair-merge-inputs-v1"];
KeyValueMap[Function[{relative, identity}, gate["pinned pair merge input " <> relative,
  IntegerString[FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] === identity]], mergeConfig["files"]];
mergeStudyHash = Hash[{FileHash[mergeStudyPath, "SHA256"], FileHash[mergeConfigPath, "SHA256"],
  pairStudyHash, $Version, $FeynCalcVersion}, "SHA256"];
mergeCache = FileNameJoin[{root, "cache", "s08_pair_merge", channel, IntegerString[mergeStudyHash, 16]}];
If[!DirectoryQ[mergeCache], CreateDirectory[mergeCache, CreateIntermediateDirectories -> True]];
mergeOriginalDefinitions = DownValues[merge];
mergeSave[value_, path_] := Module[{temporary, serialized},
  temporary = path <> "." <> ToString[$ProcessID] <> ".tmp";
  serialized = "Uncompress[" <> ToString[bounded[Compress[value], "merge output compression"], InputForm] <> "]\n";
  gate["pair merge output file bound", StringLength[serialized] < 128*1024^2];
  Export[temporary, serialized, "Text"];
  gate["pair merge exact native reload", bounded[Get[temporary] === value, "merge output reload"]];
  RenameFile[temporary, path, OverwriteTarget -> True]];
mergeKey[packet_] := Catch[Block[{checks = <||>}, Module[{binding, path, saved, values, mapped, value, seconds},
  binding = Hash[{mergeStudyHash, packet}, "SHA256"];
  path = FileNameJoin[{mergeCache, "coefficient_" <> IntegerString[binding, 16] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "Binding", None] === binding && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]], Return[saved]];
  values = packet["Values"];
  {seconds, mapped} = AbsoluteTiming[bounded[merge[(Association[Rule[packet["Key"], #]] &) /@ values],
    {"original merge coefficient", packet["Component"], packet["Position"]}]];
  value = If[KeyExistsQ[mapped, packet["Key"]], mapped[packet["Key"]], 0];
  gate["unchanged coefficient merge key", Keys[mapped] === {packet["Key"]} || mapped === <||>];
  gate["complete coefficient sum reconstructed", bounded[zero[value - Total[values]], "coefficient sum reconstruction"]];
  saved = <|"Binding" -> binding, "Component" -> packet["Component"], "Key" -> packet["Key"],
    "Value" -> value, "Seconds" -> seconds, "InputBytes" -> ByteCount[values], "Checks" -> checks, "ReconstructionPassed" -> True|>;
  mergeSave[saved, path]; Print["PAIR_MERGE_COEFFICIENT ", packet["Component"], " ", packet["Position"], " seconds ", seconds];
  ClearSystemCache[]; saved]], "TargetMapFailure"];
certifyPairMerge[maps_, grouped_, coefficients_] := Module[
  {terms, positions, keys, formalCoefficients, formalBasis, flatFormal, groupedFormal, replacements, basisValues, actualFlat, actualGrouped},
  terms = Flatten[KeyValueMap[List, #] & /@ maps, 1];
  positions = GroupBy[Range[Length[terms]], First[terms[[#]]] &]; keys = Keys[positions];
  gate["merge partition covers each original map term once", Sort[Flatten[Values[positions]]] === Range[Length[terms]] && keys === Keys[grouped]];
  gate["every grouped coefficient list is unchanged", And @@ KeyValueMap[grouped[#1] === Last /@ terms[[#2]] &, positions]];
  formalCoefficients = Table[Unique["mergeCoefficient"], {Length[terms]}];
  formalBasis = AssociationThread[keys, Table[Unique["mergeBasis"], {Length[keys]}]];
  flatFormal = MapIndexed[formalCoefficients[[First[#2]]] formalBasis[First[#1]] &, terms];
  groupedFormal = KeyValueMap[Total[formalCoefficients[[#2]]] formalBasis[#1] &, positions];
  gate["native complete map linearity identity", Expand[Total[flatFormal] - Total[groupedFormal]] === 0];
  basisValues = pairReconstruct[Association[Rule[#, 1]]] & /@ keys;
  replacements = Join[Thread[formalCoefficients -> (Last /@ terms)], Thread[Values[formalBasis] -> basisValues]];
  actualFlat = (Last[#] pairReconstruct[Association[Rule[First[#], 1]]]) & /@ terms;
  actualGrouped = MapThread[Times, {Total /@ Values[grouped], basisValues}];
  gate["formal identity specializes to every original map term", (flatFormal /. replacements) === actualFlat];
  gate["formal identity specializes to every complete integral group", (groupedFormal /. replacements) === actualGrouped];
  gate["complete merged key inventory", AllTrue[Keys[coefficients], MemberQ[keys, #] &]];
  True];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  gate["merge workers share allocated node", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  gate["merge worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@ ParallelEvaluate[{$Version, $FeynCalcVersion}])];
  DistributeDefinitions[gate, bounded, targetTimeLimit, targetMemoryLimit, zero, merge, mergeSave, mergeKey, mergeStudyHash, mergeCache]];
$DistributedContexts = None;
mergeComponents = {}; mergeSelected = DeleteDuplicates[{pairControlIndex, Last[pairSelected]}];
Do[
  task = tasks[[index]];
  gate["merge component belongs to inherited sector", task["Sector"] === pairLabel];
  values = bounded[pairExpression[#, task] & /@ pairInputs, {index, "original pair spin extraction"}];
  gate["complete original spin-pair sum reconstructed " <> ToString[index], bounded[zero[Total[values] - task["Value"]], {index, "original pair sum"}]];
  records = MapIndexed[Function[{value, position}, Module[{path, record, relative},
    path = FileNameJoin[{pairCache, "component_" <> ToString[index] <> "_pair_" <> ToString[First[position]] <> ".wl"}];
    relative = StringDrop[path, StringLength[root] + 1];
    gate["actual pair input pinned", KeyExistsQ[mergeConfig["files"], relative]];
    record = Get[path];
    gate["actual complete pair binding", record["Binding"] === Hash[{pairStudyHash, index, First[position], value}, "SHA256"] &&
      record["Component"] === index && record["PairIndex"] === First[position] && TrueQ[record["ReconstructionPassed"]] &&
      AssociationQ[record["Checks"]] && Length[record["Checks"]] > 0 && And @@ Values[record["Checks"]]];
    record]], values];
  grouped = Merge[Lookup[records, "Coefficients"], Identity];
  packets = MapIndexed[Function[{key, position}, <|"Component" -> index, "Position" -> First[position],
    "Key" -> key, "Values" -> grouped[key]|>], Keys[grouped]];
  Print["PAIR_MERGE_BEGIN ", index, " integral keys ", Length[packets]];
  {seconds, merged} = AbsoluteTiming[If[workers > 0, ParallelMap[mergeKey, packets, Method -> "FinestGrained"], mergeKey /@ packets]];
  gate["every coefficient reconstructed " <> ToString[index], Length[merged] === Length[packets] && AllTrue[merged, AssociationQ] &&
    And @@ Lookup[merged, "ReconstructionPassed"] && And @@ Flatten[Values[#["Checks"]] & /@ merged] &&
    Lookup[merged, "Key"] === Keys[grouped]];
  coefficients = Select[AssociationThread[Lookup[merged, "Key"], Lookup[merged, "Value"]], # =!= 0 &];
  gate["complete pair merge certificate " <> ToString[index], bounded[certifyPairMerge[Lookup[records, "Coefficients"], grouped, coefficients],
    {index, "formal reconstruction"}]];
  gate["merged map retains both physical cuts " <> ToString[index], And @@
    (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[coefficients])];
  If[index === pairControlIndex,
    ownPath = FileNameJoin[{pairCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
    gate["accepted own pair control is pinned", KeyExistsQ[mergeConfig["files"], StringDrop[ownPath, StringLength[root] + 1]]];
    own = Get[ownPath];
    gate["own pair control exact identity", own["InputHash"] === targetInputHash && own["StudyInputHash"] === pairStudyHash &&
      own["ComponentIndex"] === index && TrueQ[own["ReconstructionPassed"]] && And @@ Values[own["Checks"]]];
    gate["entire own accepted pair coefficient map identical", coefficients === own["Coefficients"]]];
  AppendTo[mergeComponents, Join[KeyDrop[task, "Value"], <|"ComponentIndex" -> index, "Coefficients" -> coefficients,
    "InputHash" -> targetInputHash, "StudyInputHash" -> pairStudyHash, "MergeInputHash" -> mergeStudyHash,
    "MissingTargets" -> Complement[Keys[coefficients], ruleKeys, reduction["Masters"]], "Checks" -> checks,
    "ReconstructionPassed" -> True, "MergeSeconds" -> seconds, "CoefficientEvidence" -> (KeyDrop[#, "Value"] & /@ merged)|>]];
  Print["PAIR_MERGE_COMPONENT_ACCEPTED ", index]; Clear[values, records, grouped, packets, merged, coefficients]; ClearSystemCache[],
  {index, mergeSelected}];
CloseKernels[];
gate["all reference merge equations unchanged", DownValues[merge] === mergeOriginalDefinitions];
mergeResult = <|"Schema" -> "polarized-sidis-pair-merge-linearity-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[mergeStudyPath, "SHA256"], "ConfigurationHash" -> FileHash[mergeConfigPath, "SHA256"],
  "PairSourceHash" -> FileHash[mergeBasePath, "SHA256"], "PairInputHash" -> pairStudyHash,
  "InputHashes" -> inputHashes, "TargetInputHash" -> targetInputHash, "MappingInputHash" -> inputHash,
  "InputHash" -> mergeStudyHash, "FileHashes" -> mergeConfig["files"], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "OriginalMappingDefinitions" -> DownValues[mapExpression], "OriginalMergeDefinitions" -> mergeOriginalDefinitions,
  "CertificateDefinitions" -> DownValues[certifyPairMerge], "Components" -> mergeComponents,
  "ControlIndex" -> pairControlIndex, "SelectedIndices" -> mergeSelected, "WorkerCount" -> workers,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
mergeDirectory = FileNameJoin[{root, channel, "s08_pair_merge_result"}];
If[!DirectoryQ[mergeDirectory], CreateDirectory[mergeDirectory, CreateIntermediateDirectories -> True]];
mergeSave[mergeResult, FileNameJoin[{mergeDirectory, "s08_result.wl"}]];
Export[FileNameJoin[{mergeDirectory, "s08_checks.json"}], <|"checks" -> checks, "components" -> mergeSelected,
  "workers" -> workers, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_pair_merge_linearity"]; Quit[0];

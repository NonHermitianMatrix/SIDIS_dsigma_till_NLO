(* Capture the native denominator-grouping bottleneck without changing its algebra. *)
$HistoryLength = 0;
inspectionPath = FileNameJoin[{Directory[], "common", "s08_inspect_grouping_equation.wls"}];
mapperPath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
If[IntegerString[FileHash[mapperPath, "SHA256"], 16, 64] =!=
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9",
  Print["FAIL: unchanged grouping-inspection mapper"]; Quit[1]];
mapperText = Import[mapperPath, "Text"];
boundary = First[First[StringPosition[mapperText, "\nmapTargetTask[index_]"]]];
prefix = StringTake[mapperText, boundary - 1];
If[!SyntaxQ[prefix], Print["FAIL: complete mapping initialization syntax"]; Quit[1]];
ToExpression[prefix];
gate["complete grouping-inspection syntax", SyntaxQ[Import[inspectionPath, "Text"]]];
gate["grouping inspection channel", channel === "Hqqbar"];
proofPath = FileNameJoin[{root, channel, "s08_grouped_result", "s08_result.wl"}];
gate["pinned accepted grouping proof", IntegerString[FileHash[proofPath, "SHA256"], 16, 64] ===
  "fc69dbab36b65068fde2e89a25ae05a4ac4f166a84bdf03dfde712a93aa66ed0"];
proof = Get[proofPath];
gate["grouping proof shares native inputs", proof["InputHashes"] === inputHashes && And @@ Values[proof["Checks"]]];
source = FileNameJoin[{root, "common", "s08_grouped_mapping_check.wls"}];
gate["grouping proof source binding", FileHash[source, "SHA256"] === proof["SourceHash"]];
text = Import[source, "Text"];
begin = First[First[StringPosition[text, "groupDenominators[expression_] :="]]];
end = First[First[StringPosition[text, "\n(* The reconstruction uses"]]];
groupCode = StringTake[text, {begin, end - 1}];
ToExpression[groupCode];
gate["exact original grouping definitions", DownValues[groupDenominators] === proof["GroupingDefinitions"]];
measurements = {}; lastInput = Missing["NoOperation"];
SetAttributes[inspectGroupingOperation, HoldRest];
inspectGroupingOperation[name_, input_, expression_] := Module[{seconds, answer},
  lastInput = input;
  Print["GROUP_NATIVE_BEGIN ", name, " bytes ", ByteCount[lastInput]];
  {seconds, answer} = AbsoluteTiming[TimeConstrained[MemoryConstrained[expression, 4*1024^3,
    Missing["OperationMemoryLimit"]], 180, Missing["OperationTimeLimit"]]];
  AppendTo[measurements, <|"Operation" -> name, "Seconds" -> seconds,
    "Status" -> If[MissingQ[answer], answer, "Completed"], "InputBytes" -> ByteCount[lastInput],
    "OutputBytes" -> ByteCount[answer], "MemoryBytes" -> MemoryInUse[]|>];
  Print["GROUP_NATIVE_END ", InputForm[Last[measurements]]];
  If[MissingQ[answer], Throw[KeyTake[Last[measurements], {"Operation", "Status"}], "GroupInspection"]]; answer];
replacements = {
  "atoms = extractAtoms /@ terms;" ->
    "atoms = MapIndexed[inspectGroupingOperation[\"extract term \" <> ToString[First[#2]], #1, extractAtoms[#1]] &, terms];",
  "groups = GroupBy[atoms, First -> Last, Total];" ->
    "groups = inspectGroupingOperation[\"group native atoms\", atoms, GroupBy[atoms, First -> Last, Total]];",
  "zero[expression - reconstructed]" ->
    "inspectGroupingOperation[\"complete group reconstruction\", expression - reconstructed, zero[expression - reconstructed]]"};
gate["unique grouping instrumentation", And @@ (StringCount[groupCode, First[#]] === 1 & /@ replacements)];
instrumentedCode = StringReplace[groupCode, replacements];
gate["complete grouping algebra and checks unchanged", StringReplace[instrumentedCode, Reverse /@ replacements] === groupCode];
gate["complete instrumented grouping syntax", SyntaxQ[instrumentedCode]];
ToExpression[instrumentedCode];
index = 4; task = tasks[[index]]; equation = task["Value"] /. coordinateRules;
inventory = <|"Component" -> index, "Task" -> KeyDrop[task, "Value"], "InputBytes" -> ByteCount[equation],
  "InputLeaves" -> LeafCount[equation], "Head" -> ToString[Head[equation], InputForm],
  "AdditiveTerms" -> If[Head[equation] === Plus, Length[equation], 1]|>;
Print["ACTUAL_GROUP_EQUATION ", InputForm[inventory]];
outcome = Catch[TimeConstrained[<|"Status" -> "GroupingCompleted", "Groups" -> groupDenominators[equation]|>,
  2400, <|"Status" -> "InspectionTimeLimit"|>], "GroupInspection"];
gate["captured actual grouping input", !MissingQ[lastInput]];
result = <|"Schema" -> "polarized-sidis-grouping-equation-inspection-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[inspectionPath, "SHA256"], "MapperSourceHash" -> FileHash[mapperPath, "SHA256"],
  "ProofHash" -> FileHash[proofPath, "SHA256"], "InputHashes" -> inputHashes, "MappingInputHash" -> targetInputHash,
  "Equation" -> equation, "OperationInput" -> lastInput, "Inventory" -> inventory, "Outcome" -> outcome,
  "Denominators" -> denominators, "OriginalGroupingCode" -> groupCode, "Measurements" -> measurements,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
directory = FileNameJoin[{root, channel, "s08_group_equation_result"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
path = FileNameJoin[{directory, "s08_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[result], "group equation compression"], InputForm] <> "]\n";
gate["bounded group equation file", StringLength[serialized] < 128*1024^2];
Export[path <> ".tmp", serialized, "Text"];
gate["actual group equation exact round trip", bounded[Get[path <> ".tmp"] === result, "group equation reload"]];
RenameFile[path <> ".tmp", path, OverwriteTarget -> True];
Export[FileNameJoin[{directory, "s08_checks.json"}], <|"checks" -> checks,
  "inventory" -> ToString[inventory, InputForm], "outcome" -> ToString[KeyDrop[outcome, "Groups"], InputForm],
  "measurements" -> ToString[measurements, InputForm], "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_inspect_grouping_equation"]; Quit[0];

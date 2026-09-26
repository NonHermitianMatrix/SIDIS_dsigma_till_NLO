(* Inspect the actual timed-out mapping inputs with the unchanged native mapper. *)
$HistoryLength = 0;
inspectionRoot = Directory[];
inspectionPath = FileNameJoin[{inspectionRoot, "common", "s08_inspect_mapping_equations.wls"}];
inspectionMapperPath = FileNameJoin[{inspectionRoot, "common", "s08_map_real_targets.wls"}];
inspectionAssert[name_, test_] := If[!TrueQ[test], Print["FAIL: ", name]; Quit[1]];
inspectionAssert["inspection source syntax", SyntaxQ[Import[inspectionPath, "Text"]]];
inspectionAssert["reviewed target mapper", IntegerString[FileHash[inspectionMapperPath, "SHA256"], 16, 64] ===
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9"];
inspectionMapperText = Import[inspectionMapperPath, "Text"];
inspectionBoundary = StringPosition[inspectionMapperText, "\nmapTargetTask[index_]"];
inspectionAssert["unique mapping initialization boundary", Length[inspectionBoundary] === 1];
inspectionPrefix = StringTake[inspectionMapperText, First[First[inspectionBoundary]] - 1];
inspectionAssert["complete inherited mapping initialization", SyntaxQ[inspectionPrefix]];
ToExpression[inspectionPrefix, InputForm];
gate["inspection owns timed-out channel", channel === "Hqqbar"];
inspectionRows = {};
inspectionEquations = <||>;
Do[
  inspectionTask = tasks[[inspectionIndex]];
  inspectionValue = inspectionTask["Value"] /. coordinateRules;
  inspectionTerms = If[Head[inspectionValue] === Plus, List @@ inspectionValue, {inspectionValue}];
  gate["original additive input reconstructs " <> ToString[inspectionIndex], Total[inspectionTerms] === inspectionValue];
  Print["MAPPING_INPUT_EQUATION ", InputForm[<|"Component" -> inspectionIndex,
    "Task" -> KeyDrop[inspectionTask, "Value"], "Bytes" -> ByteCount[inspectionValue],
    "Leaves" -> LeafCount[inspectionValue], "Head" -> Head[inspectionValue],
    "AdditiveTerms" -> Length[inspectionTerms]|>]];
  {inspectionWholeSeconds, inspectionWholeAtoms} = AbsoluteTiming[
    bounded[extractAtoms[inspectionValue], {inspectionIndex, "actual complete denominator"}]];
  Print["MAPPING_WHOLE_DENOMINATOR ", InputForm[<|"Component" -> inspectionIndex,
    "Powers" -> First[inspectionWholeAtoms], "NumeratorBytes" -> ByteCount[Last[inspectionWholeAtoms]],
    "Seconds" -> inspectionWholeSeconds|>]];
  {inspectionTermSeconds, inspectionAtoms} = AbsoluteTiming[
    bounded[extractAtoms /@ inspectionTerms, {inspectionIndex, "actual term denominators"}]];
  inspectionGroups = GroupBy[inspectionAtoms, First -> Last, Total];
  inspectionGroupedValue = Total[KeyValueMap[
    #2/(Times @@ MapThread[Power, {denominators, #1}]) &, inspectionGroups]];
  {inspectionReconstructionSeconds, inspectionReconstructed} = AbsoluteTiming[
    bounded[zero[inspectionValue - inspectionGroupedValue], {inspectionIndex, "complete grouped reconstruction"}]];
  gate["complete grouped input reconstructs " <> ToString[inspectionIndex], inspectionReconstructed];
  inspectionRow = <|"Component" -> inspectionIndex, "Task" -> KeyDrop[inspectionTask, "Value"],
    "InputBytes" -> ByteCount[inspectionValue], "InputLeaves" -> LeafCount[inspectionValue],
    "AdditiveTerms" -> Length[inspectionTerms], "WholeDenominatorPowers" -> First[inspectionWholeAtoms],
    "WholeNumeratorBytes" -> ByteCount[Last[inspectionWholeAtoms]], "DenominatorGroups" -> Length[inspectionGroups],
    "GroupPowerInventory" -> Keys[inspectionGroups], "GroupNumeratorBytes" -> (ByteCount /@ Values[inspectionGroups]),
    "WholeExtractionSeconds" -> inspectionWholeSeconds, "TermExtractionSeconds" -> inspectionTermSeconds,
    "ReconstructionSeconds" -> inspectionReconstructionSeconds, "ExactReconstruction" -> inspectionReconstructed,
    "MemoryBytes" -> MemoryInUse[], "PeakMemoryBytes" -> MaxMemoryUsed[]|>;
  AppendTo[inspectionRows, inspectionRow];
  AssociateTo[inspectionEquations, inspectionIndex -> <|"OriginalValue" -> inspectionValue,
    "WholeAtoms" -> inspectionWholeAtoms, "Groups" -> inspectionGroups|>];
  Print["MAPPING_EQUATION_MEASUREMENT ", InputForm[inspectionRow]];
  Clear[inspectionTask, inspectionValue, inspectionTerms, inspectionAtoms, inspectionGroups,
    inspectionGroupedValue, inspectionWholeAtoms]; ClearSystemCache[], {inspectionIndex, {1, 2}}];
inspectionResult = <|"Schema" -> "polarized-sidis-mapping-equation-inspection-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[inspectionPath, "SHA256"], "MapperSourceHash" -> FileHash[inspectionMapperPath, "SHA256"],
  "InputHashes" -> inputHashes, "InputHash" -> inputHash, "MappingInputHash" -> targetInputHash,
  "Denominators" -> denominators, "Measurements" -> inspectionRows, "Equations" -> inspectionEquations,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
inspectionDir = FileNameJoin[{root, channel, "s08_equation_result"}];
If[!DirectoryQ[inspectionDir], CreateDirectory[inspectionDir, CreateIntermediateDirectories -> True]];
inspectionResultPath = FileNameJoin[{inspectionDir, "s08_result.wl"}];
inspectionSerialized = "Uncompress[" <> ToString[bounded[Compress[inspectionResult], "inspection compression"], InputForm] <> "]\n";
gate["inspection saved-file bound", StringLength[inspectionSerialized] < 128*1024^2];
Export[inspectionResultPath <> ".tmp", inspectionSerialized, "Text"];
gate["inspection exact saved round trip", bounded[Get[inspectionResultPath <> ".tmp"] === inspectionResult, "inspection reload"]];
RenameFile[inspectionResultPath <> ".tmp", inspectionResultPath, OverwriteTarget -> True];
Export[FileNameJoin[{inspectionDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_inspect_mapping_equations"]; Quit[0];

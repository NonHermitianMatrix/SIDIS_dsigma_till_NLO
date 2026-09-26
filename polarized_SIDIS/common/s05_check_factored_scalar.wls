(* Compare factor normalization on the actual recorded scalar inputs and own projections. *)
$HistoryLength = 0;
studyPath = FileNameJoin[{Directory[], "common", "s05_check_factored_scalar.wls"}];
studyConfigPath = FileNameJoin[{Directory[], "common", "s05_factored_scalar_inputs.json"}];
studyConfig = Import[studyConfigPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= studyConfig["production_source_sha256"],
  Print["FAIL: factor comparison source binding"]; Quit[1]];
productionText = Import[productionPath, "Text"];
prefixPositions = StringPosition[productionText, "\nDo[\n  amplitudes ="];
If[Length[prefixPositions] =!= 1, Print["FAIL: unique original initialization boundary"]; Quit[1]];
productionPrefix = StringTake[productionText, First[First[prefixPositions]] - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix,
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[productionPrefix] || !SyntaxQ[Import[studyPath, "Text"]],
  Print["FAIL: complete factor comparison syntax"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
ToExpression[productionPrefix, InputForm];
gate["own channel and scalar interfaces", channel === "Hqg" && channel === studyConfig["channel"] &&
  useRestoredScalar && useFactoredPair];
label = First[labels]; gate["one real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode, InputForm];
originalReductionDefinitions = DownValues[algebraicReduceOne];
originalScalarDefinitions = DownValues[reduceScalar];
originalCoordinateDefinitions = DownValues[coordinates];
originalAngularDefinitions = {DownValues[angularAverage], DownValues[angularAverageOne]};
DownValues[originalScalarReducer] = originalReductionDefinitions /. algebraicReduceOne -> originalScalarReducer;
gate["unchanged original scalar reducer", (DownValues[originalScalarReducer] /. originalScalarReducer -> algebraicReduceOne) ===
  originalReductionDefinitions];
factorMeasurements = {};
normalizeScalarFactors[value_] := Module[{powers, bases, factoredBases, baseRules, factoredPowers, symbols, masked, answer, seconds},
  {seconds, answer} = AbsoluteTiming[
    powers = DeleteDuplicates[Cases[value, term : Power[base_, exponent_Integer] /; !AtomQ[base] :> term, {0, Infinity}]];
    bases = DeleteDuplicates[First /@ powers];
    factoredBases = Factor /@ bases;
    gate["every factor base exactly reconstructed", And @@ MapThread[Expand[#1 - #2] === 0 &, {bases, factoredBases}]];
    baseRules = Thread[bases -> factoredBases];
    factoredPowers = (With[{base = First[#] /. baseRules, exponent = Last[#]}, base^exponent] &) /@ powers;
    symbols = Table[Unique["factorPlaceholder"], {Length[powers]}];
    masked = value /. Thread[powers -> symbols];
    gate["entire input reconstructed from factor placeholders", (masked /. Thread[symbols -> powers]) === value];
    masked /. Thread[symbols -> factoredPowers]];
  AppendTo[factorMeasurements, <|"InputHash" -> Hash[value, "SHA256"], "InputBytes" -> ByteCount[value],
    "NormalizedBytes" -> ByteCount[answer], "PowerCount" -> Length[powers], "BaseCount" -> Length[bases],
    "ChangedBaseCount" -> Count[MapThread[SameQ, {bases, factoredBases}], False], "NormalizationSeconds" -> seconds,
    "ExactReconstruction" -> True|>];
  Print["SCALAR_FACTOR_NORMALIZATION ", InputForm[Last[factorMeasurements]]]; answer];
factoredScalarReducer[value_] := originalScalarReducer[
  If[ByteCount[value] >= studyConfig["minimum_input_bytes"], normalizeScalarFactors[value], value]];
DownValues[algebraicReduceOne] = DownValues[factoredScalarReducer] /. factoredScalarReducer -> algebraicReduceOne;
gate["scalar angular and coordinate equations unchanged", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[coordinates] === originalCoordinateDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions];
studyDirectory = FileNameJoin[{root, channel, "s05_factored_scalar_result"}];
If[!DirectoryQ[studyDirectory], CreateDirectory[studyDirectory, CreateIntermediateDirectories -> True]];
saveExact[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[Compress[value], InputForm] <> "]\n";
  gate["comparison output file bound", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["comparison exact native reload", Get[path <> ".tmp"] === value];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
recordedRows = Table[
  recordPath = FileNameJoin[{root, entry["retained"]}];
  gate["pinned recorded scalar " <> entry["sha256"], IntegerString[FileHash[recordPath, "SHA256"], 16, 64] === entry["sha256"]];
  record = Get[recordPath];
  gate["actual recorded input and native conventions", record["Schema"] === "polarized-sidis-pending-scalar-input-v1" &&
    record["Channel"] === channel && record["InputHash"] === inputHash &&
    record["NativeVersions"] === {$Version, $FeynCalcVersion} && record["TransverseConstraint"] === transverseConstraint &&
    Hash[{record["InputHash"], record["CoefficientAlgorithmHash"], record["ScalarInput"]}, "SHA256"] === record["ArgumentHash"]];
  Print["RECORDED_FACTOR_INPUT ", IntegerString[record["ArgumentHash"], 16, 64]];
  {scalarSeconds, candidate} = AbsoluteTiming[bounded[algebraicReduce[record["ScalarInput"]], "recorded factor comparison"]];
  evidence = <|"ArgumentHash" -> record["ArgumentHash"], "RecordHash" -> FileHash[recordPath, "SHA256"],
    "Seconds" -> scalarSeconds, "OutputBytes" -> ByteCount[candidate]|>;
  saveExact[<|"InputHash" -> inputHash, "Evidence" -> evidence, "Value" -> candidate, "Checks" -> checks|>,
    FileNameJoin[{studyDirectory, "s05_scalar_" <> IntegerString[record["ArgumentHash"], 16, 64] <> ".wl"}]];
  Print["RECORDED_FACTOR_REDUCTION ", InputForm[evidence]]; Clear[record, candidate]; evidence,
  {entry, studyConfig["recorded_inputs"]}];
comparisonRows = Table[
  tracePath = FileNameJoin[{root, entry["trace_file"]}]; acceptedPath = FileNameJoin[{root, entry["accepted_file"]}];
  gate["pinned trace " <> entry["name"], IntegerString[FileHash[tracePath, "SHA256"], 16, 64] === entry["trace_sha256"]];
  gate["pinned accepted projection " <> entry["name"], IntegerString[FileHash[acceptedPath, "SHA256"], 16, 64] === entry["accepted_sha256"]];
  trace = Get[tracePath]; accepted = Get[acceptedPath];
  gate["same native projection inputs " <> entry["name"], trace["InputHash"] === inputHash &&
    accepted["InputHash"] === inputHash && trace["Pair"] === entry["pair"] &&
    trace["PhotonIndices"] === entry["photon_indices"] && KeyExistsQ[trace, "TracedExpression"] && KeyExistsQ[accepted, "Value"]];
  Print["FACTOR_PROJECTION_BEGIN ", entry["name"]];
  {projectionSeconds, candidate} = AbsoluteTiming[bounded[reduceScalar[trace["TracedExpression"]], {entry["name"], "factor projection"}]];
  gate["entire accepted projection reproduced " <> entry["name"], candidate === accepted["Value"] ||
    bounded[algebraicReduce[candidate - accepted["Value"]] === 0, {entry["name"], "exact accepted projection comparison"}]];
  evidence = <|"Name" -> entry["name"], "Pair" -> trace["Pair"], "PhotonIndices" -> trace["PhotonIndices"],
    "Seconds" -> projectionSeconds, "OutputBytes" -> ByteCount[candidate], "TraceHash" -> FileHash[tracePath, "SHA256"],
    "AcceptedHash" -> FileHash[acceptedPath, "SHA256"], "ExactComparison" -> True|>;
  saveExact[<|"InputHash" -> inputHash, "Evidence" -> evidence, "Value" -> candidate, "Checks" -> checks|>,
    FileNameJoin[{studyDirectory, "s05_" <> entry["name"] <> ".wl"}]];
  Print["FACTOR_PROJECTION_ACCEPTED ", InputForm[evidence]]; Clear[trace, accepted, candidate]; evidence,
  {entry, studyConfig["comparisons"]}];
gate["factor normalization exercised", Length[factorMeasurements] > 0 && Total[Lookup[factorMeasurements, "ChangedBaseCount"]] > 0];
gate["original scalar angular and coordinate definitions retained", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[coordinates] === originalCoordinateDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions &&
  (DownValues[originalScalarReducer] /. originalScalarReducer -> algebraicReduceOne) === originalReductionDefinitions];
result = <|"Schema" -> "polarized-sidis-factored-scalar-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studyPath, "SHA256"], "ConfigHash" -> FileHash[studyConfigPath, "SHA256"],
  "ProductionSourceHash" -> FileHash[productionPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "OriginalReductionDefinitions" -> originalReductionDefinitions,
  "OriginalReducerDefinitions" -> DownValues[originalScalarReducer], "NormalizationDefinitions" -> DownValues[normalizeScalarFactors],
  "FactoredReducerDefinitions" -> DownValues[factoredScalarReducer], "InstalledReductionDefinitions" -> DownValues[algebraicReduceOne],
  "OriginalScalarDefinitions" -> originalScalarDefinitions, "OriginalAngularDefinitions" -> originalAngularDefinitions,
  "OriginalCoordinateDefinitions" -> originalCoordinateDefinitions, "TransverseConstraint" -> transverseConstraint,
  "Measurements" -> factorMeasurements, "RecordedComparisons" -> recordedRows, "Comparisons" -> comparisonRows,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
saveExact[result, FileNameJoin[{studyDirectory, "s05_result.wl"}]];
Export[FileNameJoin[{studyDirectory, "s05_checks.json"}], <|"checks" -> checks, "comparisons" -> comparisonRows,
  "recorded_comparisons" -> recordedRows, "measurements" -> factorMeasurements, "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_factored_scalar"]; Quit[0];

(* Compare the inherited angular operator before rational reduction of restored coefficients. *)
$HistoryLength = 0;
studyPath = FileNameJoin[{Directory[], "common", "s05_check_angular_first.wls"}];
studyConfigPath = FileNameJoin[{Directory[], "common", "s05_angular_first_inputs.json"}];
studyConfig = Import[studyConfigPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= studyConfig["production_source_sha256"],
  Print["FAIL: angular-first comparison source binding"]; Quit[1]];
productionText = Import[productionPath, "Text"];
prefixPositions = StringPosition[productionText, "\nDo[\n  amplitudes ="];
If[Length[prefixPositions] =!= 1, Print["FAIL: unique original initialization boundary"]; Quit[1]];
productionPrefix = StringTake[productionText, First[First[prefixPositions]] - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix,
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[productionPrefix] || !SyntaxQ[Import[studyPath, "Text"]],
  Print["FAIL: complete angular-first comparison syntax"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
ToExpression[productionPrefix, InputForm];
gate["own channel and scalar interfaces", channel === "Hqg" && channel === studyConfig["channel"] &&
  useRestoredScalar && useFactoredPair];
label = First[labels]; gate["one real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode, InputForm];
originalReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne]};
originalRestorationDefinitions = DownValues[restoredScalarComponent];
originalScalarDefinitions = DownValues[reduceScalar];
originalCoordinateDefinitions = DownValues[coordinates];
originalAngularDefinitions = {DownValues[angularAverage], DownValues[angularAverageOne]};
angularMeasurements = {};
angularFirstReduce[value_] := Module[{rows, powers, monomials, coefficients, reconstructed, moments, averaged, seconds, answer},
  If[FreeQ[value, normalDot], Return[algebraicReduce[value]]];
  gate["angular variable independent of transverse constraint", FreeQ[transverseConstraint, normalDot]];
  gate["restored coefficient polynomial in angular variable", PolynomialQ[value, normalDot]];
  gate["all explicit denominators independent of angular variable", And @@
    (FreeQ[#, normalDot] & /@ Cases[value, Power[base_, exponent_Integer /; exponent < 0] :> base, {0, Infinity}])];
  {seconds, averaged} = AbsoluteTiming[
    rows = CoefficientRules[value, {normalDot}];
    powers = First /@ (First /@ rows); coefficients = Last /@ rows;
    monomials = normalDot^# & /@ powers;
    reconstructed = Total[MapThread[Times, {coefficients, monomials}]];
    gate["entire angular polynomial coefficient reconstruction", CoefficientRules[reconstructed, {normalDot}] === rows];
    gate["angular coefficients independent of angular variable", FreeQ[coefficients, normalDot]];
    moments = normalMoment /@ powers;
    gate["every used moment matches original angular operator", And @@
      MapThread[algebraicReduce[#1 - angularAverage[#2]] === 0 &, {moments, monomials}]];
    Total[MapThread[Times, {coefficients, moments}]]];
  gate["early angular average removes angular variable", FreeQ[averaged, normalDot]];
  AppendTo[angularMeasurements, <|"InputHash" -> Hash[value, "SHA256"], "InputBytes" -> ByteCount[value],
    "AveragedBytes" -> ByteCount[averaged], "Powers" -> powers, "MomentCount" -> Length[moments],
    "AveragingSeconds" -> seconds, "AverageIsZero" -> TrueQ[averaged === 0], "ExactReconstruction" -> True|>];
  Print["EARLY_ANGULAR_AVERAGE ", InputForm[Last[angularMeasurements]]];
  answer = algebraicReduce[averaged]; answer];
gate["one restored scalar evaluation boundary", Length[Cases[originalRestorationDefinitions,
  HoldPattern[algebraicReduce[_]], Infinity]] === 1];
DownValues[restoredScalarComponent] = originalRestorationDefinitions /. algebraicReduce -> angularFirstReduce;
gate["only restored coefficient angular ordering changed",
  (DownValues[restoredScalarComponent] /. angularFirstReduce -> algebraicReduce) === originalRestorationDefinitions];
gate["original scalar angular coordinate and reduction equations unchanged", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[coordinates] === originalCoordinateDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions &&
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne]} === originalReductionDefinitions];
studyDirectory = FileNameJoin[{root, channel, "s05_angular_first_result"}];
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
  Print["RECORDED_ANGULAR_INPUT ", IntegerString[record["ArgumentHash"], 16, 64]];
  {scalarSeconds, candidate} = AbsoluteTiming[bounded[angularFirstReduce[record["ScalarInput"]], "recorded angular-first comparison"]];
  evidence = <|"ArgumentHash" -> record["ArgumentHash"], "RecordHash" -> FileHash[recordPath, "SHA256"],
    "Seconds" -> scalarSeconds, "OutputBytes" -> ByteCount[candidate], "AngularAveraged" -> True|>;
  saveExact[<|"InputHash" -> inputHash, "Evidence" -> evidence, "Value" -> candidate, "Checks" -> checks|>,
    FileNameJoin[{studyDirectory, "s05_scalar_" <> IntegerString[record["ArgumentHash"], 16, 64] <> ".wl"}]];
  Print["RECORDED_ANGULAR_REDUCTION ", InputForm[evidence]]; Clear[record, candidate]; evidence,
  {entry, studyConfig["recorded_inputs"]}];
comparisonRows = Table[
  tracePath = FileNameJoin[{root, entry["trace_file"]}]; acceptedPath = FileNameJoin[{root, entry["accepted_file"]}];
  gate["pinned trace " <> entry["name"], IntegerString[FileHash[tracePath, "SHA256"], 16, 64] === entry["trace_sha256"]];
  gate["pinned accepted projection " <> entry["name"], IntegerString[FileHash[acceptedPath, "SHA256"], 16, 64] === entry["accepted_sha256"]];
  trace = Get[tracePath]; accepted = Get[acceptedPath];
  gate["same native projection inputs " <> entry["name"], trace["InputHash"] === inputHash &&
    accepted["InputHash"] === inputHash && trace["Pair"] === entry["pair"] &&
    trace["PhotonIndices"] === entry["photon_indices"] && KeyExistsQ[trace, "TracedExpression"] && KeyExistsQ[accepted, "Value"]];
  Print["ANGULAR_PROJECTION_BEGIN ", entry["name"]];
  {projectionSeconds, candidate} = AbsoluteTiming[bounded[reduceScalar[trace["TracedExpression"]], {entry["name"], "angular-first projection"}]];
  gate["entire accepted projection reproduced " <> entry["name"], candidate === accepted["Value"] ||
    bounded[algebraicReduce[candidate - accepted["Value"]] === 0, {entry["name"], "exact accepted projection comparison"}]];
  evidence = <|"Name" -> entry["name"], "Pair" -> trace["Pair"], "PhotonIndices" -> trace["PhotonIndices"],
    "Seconds" -> projectionSeconds, "OutputBytes" -> ByteCount[candidate], "TraceHash" -> FileHash[tracePath, "SHA256"],
    "AcceptedHash" -> FileHash[acceptedPath, "SHA256"], "ExactComparison" -> True|>;
  saveExact[<|"InputHash" -> inputHash, "Evidence" -> evidence, "Value" -> candidate, "Checks" -> checks|>,
    FileNameJoin[{studyDirectory, "s05_" <> entry["name"] <> ".wl"}]];
  Print["ANGULAR_PROJECTION_ACCEPTED ", InputForm[evidence]]; Clear[trace, accepted, candidate]; evidence,
  {entry, studyConfig["comparisons"]}];
gate["early angular averaging exercised", Length[angularMeasurements] > 0];
gate["original scalar angular and coordinate definitions retained", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[coordinates] === originalCoordinateDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions &&
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne]} === originalReductionDefinitions &&
  (DownValues[restoredScalarComponent] /. angularFirstReduce -> algebraicReduce) === originalRestorationDefinitions];
result = <|"Schema" -> "polarized-sidis-angular-first-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studyPath, "SHA256"], "ConfigHash" -> FileHash[studyConfigPath, "SHA256"],
  "ProductionSourceHash" -> FileHash[productionPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "OriginalReductionDefinitions" -> originalReductionDefinitions,
  "OriginalRestorationDefinitions" -> originalRestorationDefinitions, "AngularFirstDefinitions" -> DownValues[angularFirstReduce],
  "InstalledRestorationDefinitions" -> DownValues[restoredScalarComponent],
  "OriginalScalarDefinitions" -> originalScalarDefinitions, "OriginalAngularDefinitions" -> originalAngularDefinitions,
  "OriginalCoordinateDefinitions" -> originalCoordinateDefinitions, "TransverseConstraint" -> transverseConstraint,
  "Measurements" -> angularMeasurements, "RecordedComparisons" -> recordedRows, "Comparisons" -> comparisonRows,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
saveExact[result, FileNameJoin[{studyDirectory, "s05_result.wl"}]];
Export[FileNameJoin[{studyDirectory, "s05_checks.json"}], <|"checks" -> checks, "comparisons" -> comparisonRows,
  "recorded_comparisons" -> recordedRows, "measurements" -> angularMeasurements, "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_angular_first"]; Quit[0];

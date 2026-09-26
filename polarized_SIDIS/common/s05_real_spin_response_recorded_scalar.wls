(* Preserve the actual input of an interrupted scalar reduction. *)
$HistoryLength = 0;
recordingSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_recorded_scalar.wls"}];
recordingSourceHash = FileHash[recordingSource, "SHA256"];
recordingBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[recordingBase, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: recorded scalar dispatch source binding"]; Quit[1]];
recordingText = Import[recordingBase, "Text"];
recordingBoundary = StringPosition[recordingText, "\nDo[\n  amplitudes ="];
If[Length[recordingBoundary] =!= 1 || !SyntaxQ[Import[recordingSource, "Text"]],
  Print["FAIL: complete recorded scalar source syntax"]; Quit[1]];
recordingPrefix = StringTake[recordingText, First[First[recordingBoundary]] - 1];
recordingTail = StringDrop[recordingText, First[First[recordingBoundary]] - 1];
If[!SyntaxQ[recordingPrefix] || !SyntaxQ[recordingTail], Print["FAIL: complete inherited real entry"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
If[StringCount[recordingPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited real package loader"]; Quit[1]];
recordingPrefix = StringReplace[recordingPrefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[recordingPrefix], Print["FAIL: native-context initialization syntax"]; Quit[1]];
ToExpression[recordingPrefix, InputForm];
gate["recording owns Hqg scalar inputs", channel === "Hqg"];
recordingOriginalDefinitions = DownValues[restoredScalarComponent];
gate["one unchanged scalar evaluation boundary", Length[Cases[recordingOriginalDefinitions,
  HoldPattern[algebraicReduce[_]], Infinity]] === 1];
recordingReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne],
  DownValues[angularAverage], DownValues[angularAverageOne], DownValues[reduceScalar]};
pendingScalarDirectory = FileNameJoin[{root, "cache", "s05_pending_scalar", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[pendingScalarDirectory], CreateDirectory[pendingScalarDirectory, CreateIntermediateDirectories -> True]];
savePendingScalar[value_] := Module[{argumentHash, path, record, serialized, temporary},
  argumentHash = Hash[{inputHash, coefficientAlgorithmHash, value}, "SHA256"];
  path = FileNameJoin[{pendingScalarDirectory, IntegerString[argumentHash, 16, 64] <> "_" <> ToString[$ProcessID] <> ".wl"}];
  record = <|"Schema" -> "polarized-sidis-pending-scalar-input-v1", "Channel" -> channel,
    "InputHash" -> inputHash, "ArgumentHash" -> argumentHash, "CoefficientAlgorithmHash" -> coefficientAlgorithmHash,
    "SourceHash" -> recordingSourceHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
    "JobID" -> Environment["JOB_ID"], "KernelID" -> $KernelID, "ProcessID" -> $ProcessID,
    "ScalarInput" -> value, "TransverseConstraint" -> transverseConstraint|>;
  serialized = "Uncompress[" <> ToString[Compress[record], InputForm] <> "]\n";
  gate["pending scalar input below file bound", StringLength[serialized] < 128*1024^2];
  temporary = path <> ".tmp";
  Export[temporary, serialized, "Text"];
  gate["pending scalar exact input reload", Get[temporary] === record];
  RenameFile[temporary, path, OverwriteTarget -> True];
  Print["PENDING_SCALAR_COEFFICIENT ", IntegerString[argumentHash, 16, 64], " input bytes ", ByteCount[value],
    " kernel ", $KernelID, " file ", path]; path];
recordedScalarReduction[value_] := Module[{path, answer},
  path = savePendingScalar[value];
  answer = algebraicReduce[value];
  DeleteFile[path];
  answer];
recordingControlPath = FileNameJoin[{root, "cache/s05/Hqg/a26ff6bda85fa1c70a7376a396436ddf9604decb38c24c812c356d7ac9ee8f45/Real_1_7_P1_1.wl"}];
gate["pinned native recording interface input", IntegerString[FileHash[recordingControlPath, "SHA256"], 16, 64] ===
  "c4c98d5497aec74e33c428d87e1e5e6d4fe061915b99cf963faba872cc59f5eb"];
recordingControl = Get[recordingControlPath];
gate["native recording interface input identity", recordingControl["InputHash"] === inputHash && KeyExistsQ[recordingControl, "Value"]];
recordingProbePath = savePendingScalar[recordingControl["Value"]];
gate["actual saved projection recording round trip", Get[recordingProbePath]["ScalarInput"] === recordingControl["Value"]];
DeleteFile[recordingProbePath];
gate["completed recording cleanup", !FileExistsQ[recordingProbePath]];
Clear[recordingControl];
DownValues[restoredScalarComponent] = recordingOriginalDefinitions /. algebraicReduce -> recordedScalarReduction;
gate["only scalar input recording added", (DownValues[restoredScalarComponent] /. recordedScalarReduction -> algebraicReduce) === recordingOriginalDefinitions];
gate["all scalar and angular equations unchanged", recordingReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne], DownValues[reduceScalar]}];
recordingChanges = {
  "compactSpinResponse, restoredScalarComponent, profiledNative, coefficientAlgorithmHash" ->
    "compactSpinResponse, restoredScalarComponent, profiledNative, recordedScalarReduction, savePendingScalar, pendingScalarDirectory, recordingSourceHash, coefficientAlgorithmHash",
  "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];" ->
    "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];\nAssociateTo[result, \"PendingScalarDispatchHash\" -> recordingSourceHash];"};
gate["unique recording worker and provenance interfaces", And @@ (StringCount[recordingTail, First[#]] === 1 & /@ recordingChanges)];
recordingRunTail = StringReplace[recordingTail, recordingChanges];
gate["complete real calculation tail retained", StringReplace[recordingRunTail, Reverse /@ recordingChanges] === recordingTail && SyntaxQ[recordingRunTail]];
ToExpression[recordingRunTail, InputForm];

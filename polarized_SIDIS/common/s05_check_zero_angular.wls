(* Validate only the zero-angular shortcut; reuse the unchanged nonzero reduction and accepted outputs. *)
$HistoryLength = 0;
studyPath = FileNameJoin[{Directory[], "common", "s05_check_zero_angular.wls"}];
studyConfigPath = FileNameJoin[{Directory[], "common", "s05_zero_angular_inputs.json"}];
studyConfig = Import[studyConfigPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= studyConfig["production_source_sha256"],
  Print["FAIL: zero-angular comparison source binding"]; Quit[1]];
productionText = Import[productionPath, "Text"];
prefixPositions = StringPosition[productionText, "\nDo[\n  amplitudes ="];
If[Length[prefixPositions] =!= 1, Print["FAIL: unique original initialization boundary"]; Quit[1]];
productionPrefix = StringTake[productionText, First[First[prefixPositions]] - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix,
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[productionPrefix] || !SyntaxQ[Import[studyPath, "Text"]],
  Print["FAIL: complete zero-angular comparison syntax"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
ToExpression[productionPrefix, InputForm];
gate["own channel and scalar interfaces", channel === "Hqg" && channel === studyConfig["channel"] &&
  useRestoredScalar && useFactoredPair];
label = First[labels]; gate["one real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode, InputForm];
originalReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]};
originalRestorationDefinitions = coefficientProof["OriginalRestorationDefinitions"];
DownValues[restoreOnly] = originalRestorationDefinitions /. {restoredScalarComponent -> restoreOnly, algebraicReduce -> Identity};
gate["restoration code unchanged before scalar reduction",
  (DownValues[restoreOnly] /. {restoreOnly -> restoredScalarComponent, Identity -> algebraicReduce}) === originalRestorationDefinitions];
exactAngularZero[value_] := Module[{expanded, terms, powers, coefficients, monomials, distinctPowers, momentValues, moments},
  If[FreeQ[value, normalDot], Return[If[value === 0, value, Missing["UnchangedReduction"]]]];
  gate["normal coordinate independent of on-shell constraint", FreeQ[transverseConstraint, normalDot]];
  gate["polynomial normal coordinate", PolynomialQ[value, normalDot]];
  gate["normal coordinate absent from every denominator", And @@
    (FreeQ[#, normalDot] & /@ Cases[value, Power[base_, exponent_Integer /; exponent < 0] :> base, {0, Infinity}])];
  expanded = Expand[value, normalDot];
  gate["selective expansion exact input reconstruction", Expand[value - expanded, normalDot] === 0];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  powers = Exponent[#, normalDot] & /@ terms;
  gate["integral nonnegative normal powers", AllTrue[powers, IntegerQ[#] && # >= 0 &]];
  coefficients = terms /. normalDot -> 1; monomials = normalDot^# & /@ powers;
  gate["every angular term exactly reconstructed", MapThread[Times, {coefficients, monomials}] === terms];
  distinctPowers = DeleteDuplicates[powers]; momentValues = normalMoment /@ distinctPowers;
  gate["all used moments reproduce original angular operator", And @@
    MapThread[algebraicReduce[#1 - angularAverage[normalDot^#2]] === 0 &, {momentValues, distinctPowers}]];
  If[!AllTrue[momentValues, # === 0 &], Return[Missing["UnchangedReduction"]]];
  moments = powers /. Thread[distinctPowers -> momentValues];
  Total[MapThread[Times, {coefficients, moments}]]];
checkpointSourcePath = FileNameJoin[{root, "common", "s05_check_scalar_checkpoints.wls"}];
checkpointText = Import[checkpointSourcePath, "Text"];
checkpointBlock = sourceSection[checkpointText, "checkpointedScalarComponent[component_]", "\nDownValues[restoredScalarComponent]"];
gate["checkpoint source and definition accepted", coefficientProof["SourceHash"] === FileHash[checkpointSourcePath, "SHA256"] && SyntaxQ[checkpointBlock]];
ToExpression[checkpointBlock, InputForm];
gate["complete original checkpoint definition reproduced", DownValues[checkpointedScalarComponent] === coefficientProof["CheckpointDefinitions"]];
checkpointNeedle = "  {seconds, answer} = AbsoluteTiming[algebraicReduce[restored]];";
checkpointGuard = "  With[{zeroValue = exactAngularZero[restored]}, If[!MissingQ[zeroValue], Print[\"ZERO_ANGULAR_COEFFICIENT \", IntegerString[argumentHash, 16, 64]]; Return[zeroValue]]];\n";
gate["one original coefficient evaluation boundary", StringCount[checkpointBlock, checkpointNeedle] === 1];
guardedBlock = StringReplace[checkpointBlock, checkpointNeedle -> checkpointGuard <> checkpointNeedle];
gate["all nonzero reduction and cache equations unchanged", StringReplace[guardedBlock, checkpointGuard -> ""] === checkpointBlock];
guardedBlock = StringReplace[guardedBlock, "checkpointedScalarComponent" -> "zeroCheckpointedScalarComponent"];
gate["complete zero-checkpoint definition syntax", SyntaxQ[guardedBlock]];
ToExpression[guardedBlock, InputForm];
studyDirectory = FileNameJoin[{root, channel, "s05_zero_angular_result"}];
If[!DirectoryQ[studyDirectory], CreateDirectory[studyDirectory, CreateIntermediateDirectories -> True]];
coefficientDirectory = FileNameJoin[{studyDirectory, "isolated_cache"}];
If[!DirectoryQ[coefficientDirectory], CreateDirectory[coefficientDirectory]];
gate["isolated shortcut probe cache empty", FileNames[All, coefficientDirectory] === {}];
saveExact[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[Compress[value], InputForm] <> "]\n";
  gate["bounded comparison output", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["exact native comparison reload", Get[path <> ".tmp"] === value];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
recordedRows = Table[
  recordPath = FileNameJoin[{root, entry["retained"]}];
  gate["pinned recorded input " <> entry["sha256"], IntegerString[FileHash[recordPath, "SHA256"], 16, 64] === entry["sha256"]];
  record = Get[recordPath];
  gate["recorded scalar input and native conventions", record["Schema"] === "polarized-sidis-pending-scalar-input-v1" &&
    record["Channel"] === channel && record["InputHash"] === inputHash && record["NativeVersions"] === {$Version, $FeynCalcVersion} &&
    record["TransverseConstraint"] === transverseConstraint &&
    Hash[{inputHash, record["CoefficientAlgorithmHash"], record["ScalarInput"]}, "SHA256"] === record["ArgumentHash"]];
  {seconds, zeroValue} = AbsoluteTiming[bounded[exactAngularZero[record["ScalarInput"]], "recorded zero-angular predicate"]];
  If[!MissingQ[zeroValue],
    gate["actual guarded checkpoint returns derived angular zero", zeroCheckpointedScalarComponent[record["ScalarInput"]] === zeroValue];
    gate["angular zero never written to pre-average scalar cache", FileNames[All, coefficientDirectory] === {}]];
  evidence = <|"ArgumentHash" -> record["ArgumentHash"], "RecordHash" -> FileHash[recordPath, "SHA256"],
    "Seconds" -> seconds, "Shortcut" -> !MissingQ[zeroValue], "InputBytes" -> ByteCount[record["ScalarInput"]]|>;
  Print["ZERO_ANGULAR_INPUT ", InputForm[evidence]]; Clear[record]; evidence, {entry, studyConfig["recorded_inputs"]}];
gate["nontrivial actual zero shortcut exercised", AnyTrue[recordedRows, TrueQ[#["Shortcut"]] && #["InputBytes"] > studyConfig["minimum_input_bytes"] &]];
gate["actual nonzero input retains original reduction", AnyTrue[recordedRows, !TrueQ[#["Shortcut"]] &]];
preprocessText = "  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[expression]]]]];";
gate["unchanged complete scalar preprocessing equation", StringCount[productionText, preprocessText] === 1];
monomials = Flatten[Outer[Times, outVariables, inVariables]];
comparisonRows = Table[
  tracePath = FileNameJoin[{root, entry["trace_file"]}]; acceptedPath = FileNameJoin[{root, entry["accepted_file"]}];
  gate["pinned own trace " <> entry["name"], IntegerString[FileHash[tracePath, "SHA256"], 16, 64] === entry["trace_sha256"]];
  gate["pinned own complete projection " <> entry["name"], IntegerString[FileHash[acceptedPath, "SHA256"], 16, 64] === entry["accepted_sha256"]];
  trace = Get[tracePath]; accepted = Get[acceptedPath];
  gate["same complete projection inputs " <> entry["name"], trace["InputHash"] === inputHash && accepted["InputHash"] === inputHash &&
    trace["Pair"] === entry["pair"] && trace["PhotonIndices"] === entry["photon_indices"]];
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[trace["TracedExpression"]]]]]];
  rawCoefficients = Flatten[First[compactSpinResponse[{value}, inVariables, outVariables]]];
  acceptedCoefficients = Flatten[First[compactSpinResponse[{accepted["Value"]}, inVariables, outVariables]]];
  gate["complete own raw spin reconstruction " <> entry["name"], Length[rawCoefficients] === Length[monomials] &&
    zero[value - Total[MapThread[Times, {rawCoefficients, monomials}]]]];
  gate["complete accepted spin reconstruction " <> entry["name"], Length[acceptedCoefficients] === Length[monomials] &&
    zero[accepted["Value"] - Total[MapThread[Times, {acceptedCoefficients, monomials}]]]];
  shortcutIndices = {}; nontrivialShortcutIndices = {}; reusedIndices = {}; candidateCoefficients = acceptedCoefficients;
  comparisonSeconds = First[AbsoluteTiming[Do[
    Print["ZERO_ANGULAR_CONTROL ", entry["name"], " component ", n, " of ", Length[rawCoefficients]];
    restored = bounded[restoreOnly[rawCoefficients[[n]]], "own coefficient restoration"];
    zeroValue = bounded[exactAngularZero[restored], "own zero-angular coefficient predicate"];
    If[MissingQ[zeroValue], AppendTo[reusedIndices, n],
      gate["own accepted angular-zero coefficient " <> entry["name"] <> " " <> ToString[n], zero[acceptedCoefficients[[n]] - zeroValue]];
      candidateCoefficients[[n]] = zeroValue; AppendTo[shortcutIndices, n];
      If[restored =!= 0, AppendTo[nontrivialShortcutIndices, n]]], {n, Length[rawCoefficients]}]]];
  gate["entire own projection unchanged with only proved zero replacements " <> entry["name"],
    zero[Total[MapThread[Times, {candidateCoefficients, monomials}]] - accepted["Value"]]];
  evidence = <|"Name" -> entry["name"], "TraceHash" -> FileHash[tracePath, "SHA256"], "AcceptedHash" -> FileHash[acceptedPath, "SHA256"],
    "Seconds" -> comparisonSeconds, "ShortcutIndices" -> shortcutIndices, "NontrivialShortcutIndices" -> nontrivialShortcutIndices,
    "UnchangedReductionIndicesReused" -> reusedIndices,
    "CompleteProjectionComparison" -> True, "UnchangedNonzeroReductionsRecomputed" -> False|>;
  Print["ZERO_ANGULAR_PROJECTION_ACCEPTED ", InputForm[evidence]];
  Clear[trace, accepted, rawCoefficients, acceptedCoefficients, candidateCoefficients, restored, value]; evidence,
  {entry, studyConfig["comparisons"]}];
gate["original scalar and angular equations retained", originalReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]}];
gate["own projection nontrivial shortcut exercised", AnyTrue[comparisonRows, Length[#["NontrivialShortcutIndices"]] > 0 &]];
gate["no comparison scalar cache mutations", FileNames[All, coefficientDirectory] === {}];
result = <|"Schema" -> "polarized-sidis-zero-angular-shortcut-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studyPath, "SHA256"], "ConfigHash" -> FileHash[studyConfigPath, "SHA256"],
  "ProductionSourceHash" -> FileHash[productionPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "ZeroAngularDefinitions" -> DownValues[exactAngularZero],
  "OriginalCheckpointDefinitions" -> DownValues[checkpointedScalarComponent], "GuardedCheckpointDefinitions" -> DownValues[zeroCheckpointedScalarComponent],
  "OriginalReductionDefinitions" -> originalReductionDefinitions, "RecordedInputs" -> recordedRows, "Comparisons" -> comparisonRows,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
saveExact[result, FileNameJoin[{studyDirectory, "s05_result.wl"}]];
Export[FileNameJoin[{studyDirectory, "s05_checks.json"}], <|"checks" -> checks, "recorded_inputs" -> recordedRows,
  "comparisons" -> comparisonRows, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_zero_angular"]; Quit[0];

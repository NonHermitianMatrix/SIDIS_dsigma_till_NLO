(* Inspect actual timed-out scalar equations without changing production algebra. *)
$HistoryLength = 0;
inspectionPath = FileNameJoin[{Directory[], "common", "s05_inspect_scalar_equation.wls"}];
inspectionConfigPath = FileNameJoin[{Directory[], "common", "s05_scalar_inspection_inputs.json"}];
inspectionConfig = Import[inspectionConfigPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= inspectionConfig["production_source_sha256"],
  Print["FAIL: pinned scalar-inspection source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
If[!SyntaxQ[productionPrefix], Print["FAIL: complete production prefix syntax"]; Quit[1]];
ToExpression[productionPrefix];
gate["complete scalar inspection syntax", SyntaxQ[Import[inspectionPath, "Text"]]];
gate["known scalar inspection contract", inspectionConfig["schema"] === "polarized-sidis-scalar-inspection-inputs-v1" &&
  channel === inspectionConfig["channel"] && channel === "Hqg" && useRestoredScalar && useFactoredPair];
label = First[labels];
gate["one inspected real sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["complete unchanged pair definitions syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
pair = inspectionConfig["pair"]; indices = inspectionConfig["photon_indices"];
gate["actual native projection inventory", MemberQ[pairs, pair] && Length[indices] === 2 &&
  And @@ (Between[#, {1, Length[photonSymbols]}] & /@ indices)];
controlPath = FileNameJoin[{root, inspectionConfig["control"]["file"]}];
gate["pinned own accepted projection", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] === inspectionConfig["control"]["sha256"]];
control = Get[controlPath];
gate["own accepted projection input binding", control["InputHash"] === inputHash && KeyExistsQ[control, "Value"]];
Clear[control];
inspectionDir = FileNameJoin[{root, channel, "s05_scalar_equation_result"}];
If[!DirectoryQ[inspectionDir], CreateDirectory[inspectionDir, CreateIntermediateDirectories -> True]];
measurements = {}; lastScalarEquation = Missing["NoScalarEquation"];
SetAttributes[inspectOperation, HoldRest];
inspectOperation[name_, expression_] := Module[{seconds, answer, status},
  Print["SCALAR_NATIVE_BEGIN ", name];
  {seconds, answer} = AbsoluteTiming[TimeConstrained[MemoryConstrained[expression, realMemoryLimit,
    Missing["OperationMemoryLimit"]], inspectionConfig["operation_seconds"], Missing["OperationTimeLimit"]]];
  status = If[MissingQ[answer], answer, "Completed"];
  AppendTo[measurements, <|"Operation" -> name, "Seconds" -> seconds, "Status" -> status,
    "ResultBytes" -> ByteCount[answer], "KernelMemoryBytes" -> MemoryInUse[]|>];
  Print["SCALAR_NATIVE_END ", InputForm[Last[measurements]]];
  If[MissingQ[answer], Throw[<|"Status" -> status, "Operation" -> name|>, "ScalarInspection"]]; answer];
originalAlgebraCode = sourceSection[productionText, "algebraicReduceOne[value_] :=", "\npVector ="]; 
instrumentation = {
  "Together[value]" -> "inspectOperation[\"Together input\", Together[value]]",
  "PolynomialExtendedGCD[den, transverseConstraint, transverseK]" ->
    "inspectOperation[\"transverse Bezout\", PolynomialExtendedGCD[den, transverseConstraint, transverseK]]",
  "Together[num inverse]" -> "inspectOperation[\"Together inverse product\", Together[num inverse]]",
  "PolynomialReduce[Numerator[work], {transverseConstraint}, {transverseK}]" ->
    "inspectOperation[\"transverse polynomial division\", PolynomialReduce[Numerator[work], {transverseConstraint}, {transverseK}]]",
  "Factor[Last[division]/Denominator[work]]" ->
    "inspectOperation[\"Factor on-shell answer\", Factor[Last[division]/Denominator[work]]]",
  "Last[PolynomialReduce[Numerator[Together[rational - answer]], {transverseConstraint}, {transverseK}]]" ->
    "inspectOperation[\"complete rational reconstruction\", Last[PolynomialReduce[Numerator[Together[rational - answer]], {transverseConstraint}, {transverseK}]]]",
  "zero[gcd - bezout.{den, transverseConstraint}]" ->
    "inspectOperation[\"Bezout equality\", zero[gcd - bezout.{den, transverseConstraint}]]",
  "zero[Numerator[work] - First[First[division]] transverseConstraint - Last[division]]" ->
    "inspectOperation[\"division equality\", zero[Numerator[work] - First[First[division]] transverseConstraint - Last[division]]]",
  "zero[proof]" -> "inspectOperation[\"reconstruction equality\", zero[proof]]"};
gate["unique native-operation instrumentation", And @@ (StringCount[originalAlgebraCode, First[#]] === 1 & /@ instrumentation)];
instrumentedAlgebraCode = StringReplace[originalAlgebraCode, instrumentation];
gate["all production equations and checks unchanged", StringReplace[instrumentedAlgebraCode, Reverse /@ instrumentation] === originalAlgebraCode];
instrumentedAlgebraCode = StringReplace[instrumentedAlgebraCode,
  "algebraicReduceOne[value_] :=" -> "inspectedAlgebraicReduceOne[value_] :="];
gate["complete instrumented scalar definition syntax", SyntaxQ[instrumentedAlgebraCode]];
ToExpression[instrumentedAlgebraCode];
ToExpression[StringReplace[originalAlgebraCode,
  "algebraicReduceOne[value_] :=" -> "unprofiledAlgebraicReduceOne[value_] :="]];
algebraicReduceOne[value_] := If[TrueQ[inspectRestoredCoefficient],
  lastScalarEquation = value; inspectedAlgebraicReduceOne[value], unprofiledAlgebraicReduceOne[value]];
restorationCode = sourceSection[Import[FileNameJoin[{root, "common", "s05_spin_map_check.wls"}], "Text"],
  "restoredScalarComponent[component_] :=", "\nscalarCode ="];
gate["exact accepted restoration body for scoped profiling", StringCount[restorationCode, "algebraicReduce[restored]"] === 1];
scopedRestorationCode = StringReplace[restorationCode,
  "algebraicReduce[restored]" -> "Block[{inspectRestoredCoefficient = True}, algebraicReduce[restored]]"];
gate["restoration unchanged apart from profiling scope", StringReplace[scopedRestorationCode,
  "Block[{inspectRestoredCoefficient = True}, algebraicReduce[restored]]" -> "algebraicReduce[restored]"] === restorationCode];
ToExpression[restorationCode];
gate["scoped profiling starts from accepted restoration definition", DownValues[restoredScalarComponent] === scalarProof["RestoredScalarDefinitions"]];
ToExpression[scopedRestorationCode];
traceBinding = Hash[{inputHash, pair, indices, FileHash[productionPath, "SHA256"]}, "SHA256"];
traceDirectory = FileNameJoin[{root, "cache", "s05_scalar_inspection", channel, IntegerString[traceBinding, 16]}];
If[!DirectoryQ[traceDirectory], CreateDirectory[traceDirectory, CreateIntermediateDirectories -> True]];
tracePath = FileNameJoin[{traceDirectory, "s05_trace.wl"}];
traceRecord = If[FileExistsQ[tracePath], Get[tracePath], <||>];
If[Lookup[traceRecord, "Binding", None] === traceBinding && KeyExistsQ[traceRecord, "TracedExpression"],
  traced = traceRecord["TracedExpression"]; traceSeconds = traceRecord["TraceSeconds"],
  tensor = bounded[buildPair[First[pair], Last[pair], None], {"inspection", pair, "spin closure"}];
  projected = photonProject[tensor, photonSymbols[[First[indices]]], photonSymbols[[Last[indices]]]];
  {traceSeconds, traced} = AbsoluteTiming[bounded[Contract[DiracSimplify[projected, DiracTraceEvaluate -> True]],
    {"inspection", pair, indices, "native trace"}]];
  traceRecord = <|"Binding" -> traceBinding, "InputHash" -> inputHash, "Pair" -> pair,
    "PhotonIndices" -> indices, "TraceSeconds" -> traceSeconds, "TracedExpression" -> traced,
    "ProductionSourceHash" -> FileHash[productionPath, "SHA256"]|>;
  traceSerialized = "Uncompress[" <> ToString[Compress[traceRecord], InputForm] <> "]\n";
  gate["bounded trace checkpoint", StringLength[traceSerialized] < 128*1024^2];
  Export[tracePath <> ".tmp", traceSerialized, "Text"];
  gate["native trace exact checkpoint reload", Get[tracePath <> ".tmp"] === traceRecord];
  RenameFile[tracePath <> ".tmp", tracePath, OverwriteTarget -> True]];
Print["ACTUAL_SCALAR_TRACE ", InputForm[<|"Pair" -> pair, "PhotonIndices" -> indices,
  "Seconds" -> traceSeconds, "Bytes" -> ByteCount[traced]|>]];
inspectionOutcome = Catch[TimeConstrained[
  <|"Status" -> "ProjectionCompleted", "Value" -> reduceScalar[traced]|>,
  inspectionConfig["projection_seconds"], <|"Status" -> "ProjectionTimeLimit"|>], "ScalarInspection"];
gate["saved actual scalar equation", !MissingQ[lastScalarEquation] &&
  FreeQ[lastScalarEquation, _ConditionalExpression | _Piecewise | _Real | $Aborted | $Failed]];
denominatorBases = DeleteDuplicates[Cases[lastScalarEquation, Power[base_, power_Integer /; power < 0] :> base, {0, Infinity}]];
inventory = <|"InputBytes" -> ByteCount[lastScalarEquation], "InputLeaves" -> LeafCount[lastScalarEquation],
  "TopLevelHead" -> ToString[Head[lastScalarEquation], InputForm],
  "TopLevelTerms" -> If[Head[lastScalarEquation] === Plus, Length[lastScalarEquation], 1],
  "DenominatorBases" -> denominatorBases,
  "PolynomialInTransverseCoordinate" -> TimeConstrained[PolynomialQ[lastScalarEquation, transverseK], 30, Missing["NotMeasured"]]|>;
Print["ACTUAL_SCALAR_INVENTORY ", InputForm[KeyDrop[inventory, "DenominatorBases"]]];
Print["ACTUAL_SCALAR_DENOMINATORS ", InputForm[denominatorBases]];
result = <|"Schema" -> "polarized-sidis-scalar-equation-inspection-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[inspectionPath, "SHA256"], "ConfigHash" -> FileHash[inspectionConfigPath, "SHA256"],
  "ProductionSourceHash" -> FileHash[productionPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "Pair" -> pair, "PhotonIndices" -> indices, "TraceSeconds" -> traceSeconds, "TracedExpression" -> traced,
  "ScalarEquation" -> lastScalarEquation, "TransverseConstraint" -> transverseConstraint,
  "Outcome" -> inspectionOutcome, "Inventory" -> inventory, "Measurements" -> measurements,
  "OriginalAlgebraCode" -> originalAlgebraCode, "InstrumentedAlgebraCode" -> instrumentedAlgebraCode,
  "TraceCheckpoint" -> tracePath, "TraceCheckpointHash" -> FileHash[tracePath, "SHA256"],
  "OriginalControlPath" -> inspectionConfig["control"]["file"], "OriginalControlHash" -> FileHash[controlPath, "SHA256"],
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultPath = FileNameJoin[{inspectionDir, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[result], "scalar inspection compression"], InputForm] <> "]\n";
gate["bounded equation artifact", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["actual scalar equation exact round trip", bounded[Get[resultPath <> ".tmp"] === result, "scalar inspection reload"]];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{inspectionDir, "s05_checks.json"}], <|"checks" -> checks,
  "outcome" -> ToString[KeyDrop[inspectionOutcome, "Value"], InputForm],
  "inventory" -> ToString[inventory, InputForm], "measurements" -> ToString[measurements, InputForm],
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_inspect_scalar_equation"]; Quit[0];

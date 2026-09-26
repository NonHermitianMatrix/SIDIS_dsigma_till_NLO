(* Compare compact spin decomposition at the unchanged scalar-reduction boundary. *)
$HistoryLength = 0;
validationSourcePath = FileNameJoin[{Directory[], "common", "s05_spin_map_check.wls"}];
validationConfigPath = FileNameJoin[{Directory[], "common", "s05_spin_map_inputs.json"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
validationConfig = Import[validationConfigPath, "RawJSON"];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= validationConfig["production_source_sha256"],
  Print["FAIL: pinned spin-map production source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
If[!SyntaxQ[productionPrefix], Print["FAIL: complete inherited prefix syntax"]; Quit[1]];
ToExpression[productionPrefix];
gate["complete spin-map comparison syntax", SyntaxQ[Import[validationSourcePath, "Text"]]];
gate["known spin-map comparison contract", validationConfig["schema"] === "polarized-sidis-spin-map-comparison-inputs-v1" &&
  channel === validationConfig["channel"] && channel === "Hgg"];
label = First[labels];
gate["single real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["complete inherited pair definitions syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
controlPath = FileNameJoin[{root, validationConfig["control"]["file"]}];
gate["pinned accepted projection", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  validationConfig["control"]["sha256"]];
controlRecord = Get[controlPath];
gate["accepted projection exact physical input binding", AssociationQ[controlRecord] &&
  controlRecord["InputHash"] === inputHash && KeyExistsQ[controlRecord, "Value"]];

derivativeSpinMap[function_, value_] := Module[{variables, rows, monomials, coefficients, reconstruction},
  variables = Select[spinSymbols, !FreeQ[value, #] &];
  If[variables === {}, Return[function[value]]];
  gate["scalar spin variables have declared axes", Complement[variables, DeleteCases[Join[inVariables, outVariables], 1]] === {}];
  rows = First[compactSpinResponse[{value}, inVariables, outVariables]];
  monomials = Flatten[Outer[Times, outVariables, inVariables]];
  coefficients = Flatten[rows];
  gate["complete scalar spin coefficient inventory", Length[coefficients] === Length[monomials] &&
    FreeQ[coefficients, Alternatives @@ spinSymbols]];
  reconstruction = Total[MapThread[Times, {coefficients, monomials}]];
  gate["exact derivative scalar spin decomposition", zero[value - reconstruction]];
  Print["COMPACT_SCALAR_SPIN input_bytes ", ByteCount[value], " coefficient_bytes ", ByteCount[coefficients]];
  Total[MapThread[Times, {function /@ coefficients, monomials}]]];
originalSpinMapDefinitions = DownValues[spinMap];
DownValues[spinMap] = DownValues[derivativeSpinMap] /. derivativeSpinMap -> spinMap;
gate["installed exact candidate definition", DownValues[spinMap] === (DownValues[derivativeSpinMap] /. derivativeSpinMap -> spinMap)];
originalReduceScalarDefinitions = DownValues[reduceScalar];
SetAttributes[profiledNative, HoldRest];
profiledNative[name_, expression_] := Module[{seconds, answer},
  Print["SCALAR_OPERATION_BEGIN ", name];
  {seconds, answer} = AbsoluteTiming[expression];
  Print["SCALAR_OPERATION_END ", name, " seconds ", seconds, " bytes ", ByteCount[answer]]; answer];
restoredScalarComponent[component_] := Module[{restored},
  restored = profiledNative["restore defining scalar products", (component /. epsilonRule) /. scalarRestore];
  profiledNative["on-shell reduction of restored coefficient", algebraicReduce[restored]]];
scalarCode = sourceSection[productionText, "reduceScalar[expression_]", "(* The imported graph process"];
scalarOld = "spinMap[Function[component, algebraicReduce[\n    Factor[component /. epsilonRule] /. scalarRestore]], value]";
scalarNew = "spinMap[restoredScalarComponent, value]";
gate["unique scalar-restoration ordering change", StringCount[scalarCode, scalarOld] === 1];
scalarCandidateCode = StringReplace[scalarCode, scalarOld -> scalarNew];
gate["complete scalar-restoration candidate syntax", SyntaxQ[scalarCandidateCode]];
ToExpression[scalarCandidateCode, InputForm];
runProjection[row_, purpose_] := Module[{pair, indices, tensor, value, seconds, startMemory},
  pair = row["pair"]; indices = row["photon_indices"];
  gate[purpose <> " valid native diagram pair", MemberQ[pairs, pair] &&
    And @@ (Between[#, {1, Length[photonSymbols]}] & /@ indices)];
  tensor = bounded[buildPair[First[pair], Last[pair], None], {purpose, "spin closure"}];
  startMemory = MemoryInUse[];
  {seconds, value} = AbsoluteTiming[bounded[traceScalar[
    photonProject[tensor, photonSymbols[[First[indices]]], photonSymbols[[Last[indices]]]]], {purpose, pair, indices}]];
  <|"Pair" -> pair, "PhotonIndices" -> indices, "Value" -> value,
    "Seconds" -> seconds, "OutputBytes" -> ByteCount[value], "MemoryBeforeBytes" -> startMemory,
    "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>];
control = runProjection[validationConfig["control"], "accepted control"];
gate["complete accepted scalar projection unchanged", bounded[
  algebraicReduce[control["Value"] - controlRecord["Value"]] === 0, "exact accepted scalar projection comparison"]];
Print["SPIN_MAP_CONTROL_EVIDENCE ", InputForm[KeyDrop[control, "Value"]]];
Clear[controlRecord]; ClearSystemCache[];
candidate = runProjection[validationConfig["resource_failure"], "previous memory-bound projection"];
Print["SPIN_MAP_CANDIDATE_EVIDENCE ", InputForm[KeyDrop[candidate, "Value"]]];
result = <|"Schema" -> "polarized-sidis-spin-map-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[validationSourcePath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ConfigHash" -> FileHash[validationConfigPath, "SHA256"], "ControlHash" -> FileHash[controlPath, "SHA256"],
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "OriginalSpinMapDefinitions" -> originalSpinMapDefinitions,
  "SpinMapDefinitions" -> DownValues[spinMap], "ExtractionDefinitions" -> DownValues[compactSpinResponse],
  "OriginalReduceScalarDefinitions" -> originalReduceScalarDefinitions,
  "ReduceScalarDefinitions" -> DownValues[reduceScalar], "RestoredScalarDefinitions" -> DownValues[restoredScalarComponent],
  "ProfilingDefinitions" -> DownValues[profiledNative], "ProfilingAttributes" -> Attributes[profiledNative],
  "ControlEvidence" -> KeyDrop[control, "Value"], "Candidate" -> candidate, "Checks" -> checks,
  "FiniteNLOFHatsComputed" -> False|>;
resultDir = FileNameJoin[{root, channel, "s05_spin_map_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
resultPath = FileNameJoin[{resultDir, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[result], "comparison result compression"], InputForm] <> "]\n";
gate["comparison output below file bound", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["comparison output exact round trip", bounded[Get[resultPath <> ".tmp"] === result, "comparison result reload"]];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"],
  "control" -> KeyDrop[control, "Value"], "candidate" -> KeyDrop[candidate, "Value"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_spin_map_check"]; Quit[0];

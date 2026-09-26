(* Check factored pair assembly against an actual accepted complete pair. *)
$HistoryLength = 0;
validationSourcePath = FileNameJoin[{Directory[], "common", "s05_pair_assembly_check.wls"}];
validationConfigPath = FileNameJoin[{Directory[], "common", "s05_pair_assembly_inputs.json"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
validationConfig = Import[validationConfigPath, "RawJSON"];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= validationConfig["production_source_sha256"],
  Print["FAIL: pinned pair-assembly production source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
If[!SyntaxQ[productionPrefix], Print["FAIL: complete inherited prefix syntax"]; Quit[1]];
ToExpression[productionPrefix];
gate["complete pair-assembly comparison syntax", SyntaxQ[Import[validationSourcePath, "Text"]]];
gate["known pair-assembly comparison contract",
  validationConfig["schema"] === "polarized-sidis-pair-assembly-comparison-inputs-v1" &&
  channel === validationConfig["channel"] && channel === "Hgg"];
label = First[labels];
gate["single real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["complete inherited pair definitions syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
pair = validationConfig["pair"];
gate["comparison uses an actual generated off-diagonal pair", MemberQ[pairs, pair] && First[pair] =!= Last[pair]];
validationInputHashes = Association@Table[
  gate["pinned pair input " <> relative, IntegerString[FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] ===
    validationConfig["files"][relative]];
  relative -> FileHash[FileNameJoin[{root, relative}], "SHA256"], {relative, Keys[validationConfig["files"]]}];
controlPath = FileNameJoin[{root, validationConfig["control_file"]}];
gate["complete control included in reviewed inputs", KeyExistsQ[validationInputHashes, validationConfig["control_file"]]];
controlRecord = Get[controlPath];
gate["accepted complete pair exact physical input binding", AssociationQ[controlRecord] &&
  controlRecord["InputHash"] === inputHash && And @@ Values[controlRecord["Checks"]] &&
  MatrixQ[controlRecord["PhotonMatrix"]] && AssociationQ[controlRecord["ScalarModes"]]];
projectionPrefix = FileNameDrop[validationConfig["control_file"], -1] <> "/" <>
  FileBaseName[validationConfig["control_file"]];
readProjection[suffix_] := Module[{relative, record},
  relative = projectionPrefix <> suffix <> ".wl";
  gate["projection included in reviewed pair inputs " <> suffix, KeyExistsQ[validationInputHashes, relative]];
  record = Get[FileNameJoin[{root, relative}]];
  gate["projection shares exact physical input " <> suffix,
    AssociationQ[record] && record["InputHash"] === inputHash && KeyExistsQ[record, "Value"]];
  record["Value"]];
rawMatrix = Table[readProjection["_P" <> ToString[a] <> "_" <> ToString[b]],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
rawModes = Association@Table[key -> readProjection["_" <> key], {key, Keys[controlRecord["ScalarModes"]]}];
gate["complete raw photon inventory", Dimensions[rawMatrix] === Dimensions[controlRecord["PhotonMatrix"]]];

factoredRealConjugate[value_] := Module[{variables, heads, answer},
  variables = DeleteDuplicates[Cases[value, _Symbol, {0, Infinity}]];
  heads = DeleteDuplicates[Cases[value, (expression_ /; !AtomQ[expression]) :> Head[expression], {0, Infinity}]];
  gate["pair inputs have exact rational head support", Complement[heads, {Plus, Times, Power}] === {} &&
    FreeQ[value, _Real | Power[_, exponent_ /; !IntegerQ[exponent]]]];
  gate["native inherited real-symbol convention", And @@ (ComplexExpand[Conjugate[#]] === # & /@ variables)];
  Print["PAIR_CONJUGATION_SUPPORT heads ", heads, " input_bytes ", ByteCount[value]];
  answer = value /. coefficient_Complex :> ComplexExpand[Conjugate[coefficient]];
  gate["native real-symbol conjugation is explicit", FreeQ[answer,
    _Conjugate | _Re | _Im | _ConditionalExpression | _Piecewise | $Failed | $Aborted]];
  answer];
factoredPhotonPair[matrix_] := matrix + Transpose[Map[factoredRealConjugate, matrix, {2}]];
factoredScalarPair[value_] := value + factoredRealConjugate[value];
pairEvidence = {};
candidateMatrix = Table[
  Print["PAIR_ASSEMBLY_ENTRY ", {a, b}];
  {entrySeconds, entryValue} = AbsoluteTiming[bounded[
    rawMatrix[[a, b]] + factoredRealConjugate[rawMatrix[[b, a]]], {"factored pair", a, b}]];
  {comparisonSeconds, comparisonValue} = AbsoluteTiming[bounded[
    algebraicReduce[entryValue - controlRecord["PhotonMatrix"][[a, b]]], {"accepted pair comparison", a, b}]];
  gate["complete accepted photon entry " <> ToString[{a, b}, InputForm], comparisonValue === 0];
  AppendTo[pairEvidence, <|"Kind" -> "Photon", "Index" -> {a, b}, "Seconds" -> entrySeconds,
    "ComparisonSeconds" -> comparisonSeconds, "InputBytes" -> ByteCount[{rawMatrix[[a, b]], rawMatrix[[b, a]]}],
    "OutputBytes" -> ByteCount[entryValue]|>];
  entryValue, {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
candidateModes = Association@Table[
  Print["PAIR_ASSEMBLY_SCALAR ", key];
  {entrySeconds, entryValue} = AbsoluteTiming[bounded[factoredScalarPair[rawModes[key]], {"factored scalar pair", key}]];
  {comparisonSeconds, comparisonValue} = AbsoluteTiming[bounded[
    algebraicReduce[entryValue - controlRecord["ScalarModes"][key]], {"accepted scalar pair comparison", key}]];
  gate["complete accepted scalar entry " <> key, comparisonValue === 0];
  AppendTo[pairEvidence, <|"Kind" -> "Scalar", "Key" -> key, "Seconds" -> entrySeconds,
    "ComparisonSeconds" -> comparisonSeconds, "InputBytes" -> ByteCount[rawModes[key]],
    "OutputBytes" -> ByteCount[entryValue]|>];
  key -> entryValue, {key, Keys[rawModes]}];
gate["complete pair assembly function matches measured entries",
  bounded[factoredPhotonPair[rawMatrix] === candidateMatrix, "pair assembly function comparison"]];
gate["complete scalar assembly function matches measured entries",
  bounded[Map[factoredScalarPair, rawModes] === candidateModes, "scalar assembly function comparison"]];
candidateRecord = Join[controlRecord, <|"PhotonMatrix" -> candidateMatrix, "ScalarModes" -> candidateModes,
  "Checks" -> Join[controlRecord["Checks"], checks], "ElapsedSeconds" -> Total[Lookup[pairEvidence, "Seconds"]],
  "ElapsedIncludesProjectionRecomputation" -> False, "ComparedCheckpoint" -> controlPath,
  "ComparedCheckpointHash" -> FileHash[controlPath, "SHA256"],
  "PairAssemblyComparisonSourceHash" -> FileHash[validationSourcePath, "SHA256"]|>];
result = <|"Schema" -> "polarized-sidis-pair-assembly-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[validationSourcePath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ConfigHash" -> FileHash[validationConfigPath, "SHA256"], "InputHash" -> inputHash,
  "InputHashes" -> inputHashes, "ValidationInputHashes" -> validationInputHashes,
  "Pair" -> pair, "ControlFile" -> validationConfig["control_file"], "ControlElapsedSeconds" -> controlRecord["ElapsedSeconds"],
  "ConjugationDefinitions" -> DownValues[factoredRealConjugate],
  "PhotonPairDefinitions" -> DownValues[factoredPhotonPair], "ScalarPairDefinitions" -> DownValues[factoredScalarPair],
  "Evidence" -> pairEvidence, "Candidate" -> candidateRecord, "Checks" -> checks,
  "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "FiniteNLOFHatsComputed" -> False|>;
resultDir = FileNameJoin[{root, channel, "s05_pair_assembly_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
resultPath = FileNameJoin[{resultDir, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[result], "pair comparison compression"], InputForm] <> "]\n";
gate["pair comparison output below file bound", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["pair comparison exact native round trip", bounded[Get[resultPath <> ".tmp"] === result, "pair comparison reload"]];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"],
  "pair" -> pair, "evidence" -> pairEvidence, "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_pair_assembly_check"]; Quit[0];

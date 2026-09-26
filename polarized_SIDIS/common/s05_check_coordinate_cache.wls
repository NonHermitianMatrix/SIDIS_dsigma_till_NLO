(* Reuse the exact defining coordinate routine, as for compact scalar products. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s05_check_coordinate_cache.wls"}];
configPath = FileNameJoin[{Directory[], "common", "s05_scalar_inspection_inputs.json"}];
settings = Import[configPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= settings["production_source_sha256"],
  Print["FAIL: pinned coordinate-cache production source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix,
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[productionPrefix], Print["FAIL: complete inherited initialization syntax"]; Quit[1]];
ToExpression[productionPrefix];
gate["complete coordinate comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
gate["own channel and scalar definitions", channel === settings["channel"] && channel === "Hqg" &&
  useRestoredScalar && useFactoredPair];
label = First[labels];
gate["one native real sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["complete unchanged pair definitions syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
controlPath = FileNameJoin[{root, settings["control"]["file"]}];
gate["pinned own accepted projection", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] === settings["control"]["sha256"]];
controlRecord = Get[controlPath];
gate["own accepted projection input binding", controlRecord["InputHash"] === inputHash && KeyExistsQ[controlRecord, "Value"]];
controlNumbers = FromDigits /@ StringCases[FileBaseName[controlPath], DigitCharacter ..];
gate["complete control coordinate inventory", Length[controlNumbers] === 4];
controlPair = Take[controlNumbers, 2]; controlIndices = Take[controlNumbers, -2];
originalCoordinateDefinitions = DownValues[coordinates];
originalScalarDefinitions = DownValues[reduceScalar];
originalAlgebraDefinitions = DownValues[algebraicReduceOne];
DownValues[uncachedCoordinates] = originalCoordinateDefinitions /. coordinates -> uncachedCoordinates;
gate["unchanged complete coordinate equation", (DownValues[uncachedCoordinates] /. uncachedCoordinates -> coordinates) ===
  originalCoordinateDefinitions];
coordinateCache = <||>; coordinateHits = 0; coordinateMisses = 0; coordinateBytes = 0;
cachedCoordinates[v_] := Module[{key = HoldComplete[v], answer},
  If[KeyExistsQ[coordinateCache, key], coordinateHits++; Return[coordinateCache[key]]];
  coordinateMisses++;
  answer = uncachedCoordinates[v];
  If[Length[coordinateCache] < 256 && coordinateBytes + ByteCount[answer] < 16*1024^2,
    AssociateTo[coordinateCache, key -> answer]; coordinateBytes += ByteCount[answer]];
  answer];
DownValues[coordinates] = DownValues[cachedCoordinates] /. cachedCoordinates -> coordinates;
gate["coordinate caching leaves scalar algebra unchanged", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[algebraicReduceOne] === originalAlgebraDefinitions];
Print["ACTUAL_TRANSVERSE_CONSTRAINT ", InputForm[transverseConstraint]];
Print["ACTUAL_COORDINATE_EQUATIONS ", InputForm[originalCoordinateDefinitions]];
comparisonHash = Hash[{FileHash[comparisonPath, "SHA256"], inputHash, FileHash[controlPath, "SHA256"]}, "SHA256"];
comparisonCache = FileNameJoin[{root, "cache", "s05_coordinate_check", channel, IntegerString[comparisonHash, 16]}];
If[!DirectoryQ[comparisonCache], CreateDirectory[comparisonCache, CreateIntermediateDirectories -> True]];
saveExact[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[bounded[Compress[value], "coordinate comparison compression"], InputForm] <> "]\n";
  gate["bounded coordinate comparison file", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["coordinate comparison exact file reload", bounded[Get[path <> ".tmp"] === value, "coordinate comparison reload"]];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
runProjection[pair_, indices_, purpose_] := Module[
  {binding, prefix, tracePath, projectionPath, record, tensor, projected, traced, traceSeconds,
   value, seconds, initialHits, initialMisses},
  gate[purpose <> " actual generated projection", MemberQ[pairs, pair] && Length[indices] === 2 &&
    And @@ (Between[#, {1, Length[photonSymbols]}] & /@ indices)];
  binding = Hash[{comparisonHash, pair, indices}, "SHA256"];
  prefix = FileNameJoin[{comparisonCache, IntegerString[binding, 16]}];
  projectionPath = prefix <> "_projection.wl"; tracePath = prefix <> "_trace.wl";
  record = If[FileExistsQ[projectionPath], Get[projectionPath], <||>];
  If[Lookup[record, "Binding", None] === binding && KeyExistsQ[record, "Value"] &&
    AssociationQ[Lookup[record, "Checks", None]] && And @@ Values[record["Checks"]], Return[record]];
  record = If[FileExistsQ[tracePath], Get[tracePath], <||>];
  If[Lookup[record, "Binding", None] === binding && KeyExistsQ[record, "TracedExpression"],
    traced = record["TracedExpression"]; traceSeconds = record["TraceSeconds"],
    tensor = bounded[buildPair[First[pair], Last[pair], None], {purpose, pair, "native spin closure"}];
    projected = photonProject[tensor, photonSymbols[[First[indices]]], photonSymbols[[Last[indices]]]];
    {traceSeconds, traced} = AbsoluteTiming[bounded[Contract[DiracSimplify[projected, DiracTraceEvaluate -> True]],
      {purpose, pair, indices, "unchanged native trace"}]];
    saveExact[<|"Binding" -> binding, "InputHash" -> inputHash, "Pair" -> pair, "PhotonIndices" -> indices,
      "TracedExpression" -> traced, "TraceSeconds" -> traceSeconds|>, tracePath]];
  Print["COORDINATE_CHECK_TRACE ", InputForm[<|"Purpose" -> purpose, "Pair" -> pair, "PhotonIndices" -> indices,
    "Seconds" -> traceSeconds, "Bytes" -> ByteCount[traced]|>]];
  initialHits = coordinateHits; initialMisses = coordinateMisses;
  {seconds, value} = AbsoluteTiming[bounded[reduceScalar[traced], {purpose, pair, indices, "unchanged scalar reduction"}]];
  record = <|"Binding" -> binding, "InputHash" -> inputHash, "Pair" -> pair, "PhotonIndices" -> indices, "Value" -> value,
    "TraceSeconds" -> traceSeconds, "ScalarSeconds" -> seconds, "CacheHits" -> coordinateHits - initialHits,
    "CacheMisses" -> coordinateMisses - initialMisses, "CacheBytes" -> coordinateBytes, "Checks" -> checks|>;
  saveExact[record, projectionPath]; Print["COORDINATE_PROJECTION_COMPLETE ", InputForm[KeyDrop[record, {"Value", "Checks"}]]]; record];
control = runProjection[controlPair, controlIndices, "own accepted control"];
gate["entire own accepted projection unchanged", control["Value"] === controlRecord["Value"] ||
  bounded[algebraicReduce[control["Value"] - controlRecord["Value"]] === 0, "own accepted projection comparison"]];
candidate = runProjection[settings["pair"], settings["photon_indices"], "previously timed-out projection"];
gate["actual coordinate cache bounds", Length[coordinateCache] <= 256 && coordinateBytes <= 16*1024^2];
gate["coordinate caching retained every algebra equation", DownValues[reduceScalar] === originalScalarDefinitions &&
  DownValues[algebraicReduceOne] === originalAlgebraDefinitions &&
  (DownValues[uncachedCoordinates] /. uncachedCoordinates -> coordinates) === originalCoordinateDefinitions];
Print["ACTUAL_CACHED_COORDINATES ", InputForm[coordinateCache]];
result = <|"Schema" -> "polarized-sidis-coordinate-cache-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ConfigHash" -> FileHash[configPath, "SHA256"], "ControlHash" -> FileHash[controlPath, "SHA256"],
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "OriginalCoordinateDefinitions" -> originalCoordinateDefinitions, "UncachedCoordinateDefinitions" -> DownValues[uncachedCoordinates],
  "CachedCoordinateDefinitions" -> DownValues[cachedCoordinates], "CoordinateDefinitions" -> DownValues[coordinates],
  "CoordinateValues" -> coordinateCache, "TransverseConstraint" -> transverseConstraint,
  "Control" -> KeyDrop[control, "Value"], "Candidate" -> candidate, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultDir = FileNameJoin[{root, channel, "s05_coordinate_cache_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
saveExact[result, FileNameJoin[{resultDir, "s05_result.wl"}]];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "control" -> KeyDrop[control, {"Value", "Checks"}],
  "candidate" -> KeyDrop[candidate, {"Value", "Checks"}], "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_coordinate_cache"]; Quit[0];

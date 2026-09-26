(* Compare exact polynomial slicing on saved native Hqg projections. *)
$HistoryLength = 0;
studyPath = FileNameJoin[{Directory[], "common", "s05_check_polynomial_scalar.wls"}];
studyConfigPath = FileNameJoin[{Directory[], "common", "s05_polynomial_scalar_inputs.json"}];
studyConfig = Import[studyConfigPath, "RawJSON"];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!= studyConfig["production_source_sha256"],
  Print["FAIL: polynomial comparison source binding"]; Quit[1]];
productionText = Import[productionPath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique inherited package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix,
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[productionPrefix], Print["FAIL: inherited initialization syntax"]; Quit[1]];
ToExpression[productionPrefix];
gate["complete polynomial comparison syntax", SyntaxQ[Import[studyPath, "Text"]]];
gate["own channel and unchanged scalar interfaces", channel === "Hqg" &&
  channel === studyConfig["channel"] && useRestoredScalar && useFactoredPair];
label = First[labels]; gate["one real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged native pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
originalReductionDefinitions = DownValues[algebraicReduceOne];
originalCoordinateDefinitions = DownValues[coordinates];
originalScalarDefinitions = DownValues[reduceScalar];
originalAngularDefinitions = {DownValues[angularAverage], DownValues[angularAverageOne]};
DownValues[unslicedScalar] = originalReductionDefinitions /. algebraicReduceOne -> unslicedScalar;
gate["unchanged original scalar reducer", (DownValues[unslicedScalar] /. unslicedScalar -> algebraicReduceOne) === originalReductionDefinitions];
DownValues[uncachedCoordinates] = originalCoordinateDefinitions /. coordinates -> uncachedCoordinates;
coordinateCache = <||>; coordinateHits = 0; coordinateMisses = 0; coordinateBytes = 0;
cachedCoordinates[v_] := Module[{key = HoldComplete[v], answer},
  If[KeyExistsQ[coordinateCache, key], coordinateHits++; Return[coordinateCache[key]]];
  coordinateMisses++; answer = uncachedCoordinates[v];
  If[Length[coordinateCache] < 256 && coordinateBytes + ByteCount[answer] < 16*1024^2,
    AssociateTo[coordinateCache, key -> answer]; coordinateBytes += ByteCount[answer]];
  answer];
DownValues[coordinates] = DownValues[cachedCoordinates] /. cachedCoordinates -> coordinates;
gate["coordinate equation retained", (DownValues[uncachedCoordinates] /. uncachedCoordinates -> coordinates) === originalCoordinateDefinitions];
slicingMeasurements = {}; largestScalarBytes = 0; largestScalarInput = None;
polynomialScalar[value_] := Module[{denominators, variables, rows, monomials, reconstruction,
    reduced, answer, seconds, inputBytes},
  inputBytes = ByteCount[value];
  If[inputBytes < studyConfig["minimum_input_bytes"], Return[unslicedScalar[value]]];
  gate["exact rational scalar input", FreeQ[value, _ConditionalExpression | _Piecewise | _Real | $Aborted | $Failed]];
  denominators = DeleteDuplicates[Cases[value, Power[base_, power_Integer /; power < 0] :> base, {0, Infinity}]];
  variables = Select[{D, normalDot}, !FreeQ[value, #] && FreeQ[denominators, #] &];
  If[variables === {}, Return[unslicedScalar[value]]];
  gate["slice variables absent from transverse constraint", And @@ (FreeQ[transverseConstraint, #] & /@ variables)];
  gate["polynomial scalar slice domain", PolynomialQ[value, variables]];
  If[inputBytes > largestScalarBytes, largestScalarBytes = inputBytes; largestScalarInput = value];
  Print["POLYNOMIAL_SCALAR_BEGIN ", InputForm[<|"InputBytes" -> inputBytes, "Variables" -> variables|>]];
  {seconds, answer} = AbsoluteTiming[
    rows = CoefficientRules[value, variables];
    monomials = (Times @@ MapThread[Power, {variables, First[#]}]) & /@ rows;
    reconstruction = Total[MapThread[Times, {Last /@ rows, monomials}]];
    gate["exact inverse polynomial coefficient map", CoefficientRules[reconstruction, variables] === rows];
    gate["slice coefficients independent of selected variables", FreeQ[Last /@ rows, Alternatives @@ variables]];
    reduced = Table[Print["POLYNOMIAL_SCALAR_SLICE ", n, " of ", Length[rows]];
      unslicedScalar[Last[rows[[n]]]], {n, Length[rows]}];
    Total[MapThread[Times, {reduced, monomials}]]];
  AppendTo[slicingMeasurements, <|"InputHash" -> Hash[value, "SHA256"], "InputBytes" -> inputBytes,
    "Variables" -> variables, "Powers" -> (First /@ rows), "Slices" -> Length[rows],
    "Seconds" -> seconds, "OutputBytes" -> ByteCount[answer], "ExactCoefficientMap" -> True|>];
  Print["POLYNOMIAL_SCALAR_COMPLETE ", InputForm[Last[slicingMeasurements]]]; answer];
DownValues[algebraicReduceOne] = DownValues[polynomialScalar] /. polynomialScalar -> algebraicReduceOne;
gate["scalar restoration and angular equations unchanged", DownValues[reduceScalar] === originalScalarDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions];
studyDirectory = FileNameJoin[{root, channel, "s05_polynomial_scalar_result"}];
If[!DirectoryQ[studyDirectory], CreateDirectory[studyDirectory, CreateIntermediateDirectories -> True]];
saveExact[value_, path_] := Module[{serialized},
  serialized = "Uncompress[" <> ToString[Compress[value], InputForm] <> "]\n";
  gate["comparison output file bound", StringLength[serialized] < 128*1024^2];
  Export[path <> ".tmp", serialized, "Text"];
  gate["comparison exact native reload", Get[path <> ".tmp"] === value];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]];
comparisonRows = Table[
  tracePath = FileNameJoin[{root, entry["trace_file"]}];
  acceptedPath = FileNameJoin[{root, entry["accepted_file"]}];
  gate["pinned trace " <> entry["name"], IntegerString[FileHash[tracePath, "SHA256"], 16, 64] === entry["trace_sha256"]];
  gate["pinned accepted projection " <> entry["name"], IntegerString[FileHash[acceptedPath, "SHA256"], 16, 64] === entry["accepted_sha256"]];
  trace = Get[tracePath]; accepted = Get[acceptedPath];
  gate["same native projection inputs " <> entry["name"], trace["InputHash"] === inputHash &&
    accepted["InputHash"] === inputHash && trace["Pair"] === entry["pair"] &&
    trace["PhotonIndices"] === entry["photon_indices"] && KeyExistsQ[trace, "TracedExpression"] && KeyExistsQ[accepted, "Value"]];
  Print["SAVED_NATIVE_TRACE ", InputForm[<|"Pair" -> trace["Pair"], "PhotonIndices" -> trace["PhotonIndices"],
    "TraceBytes" -> ByteCount[trace["TracedExpression"]], "TraceSeconds" -> trace["TraceSeconds"]|>]];
  initialMeasurements = Length[slicingMeasurements]; initialHits = coordinateHits; initialMisses = coordinateMisses;
  {projectionSeconds, candidate} = AbsoluteTiming[bounded[reduceScalar[trace["TracedExpression"]], {entry["name"], "polynomial scalar comparison"}]];
  gate["entire accepted projection reproduced " <> entry["name"], candidate === accepted["Value"] ||
    bounded[algebraicReduce[candidate - accepted["Value"]] === 0, {entry["name"], "exact accepted projection comparison"}]];
  evidence = <|"Name" -> entry["name"], "Pair" -> trace["Pair"], "PhotonIndices" -> trace["PhotonIndices"],
    "Seconds" -> projectionSeconds, "OutputBytes" -> ByteCount[candidate], "SlicesUsed" -> Length[slicingMeasurements] - initialMeasurements,
    "CoordinateHits" -> coordinateHits - initialHits, "CoordinateMisses" -> coordinateMisses - initialMisses,
    "TraceHash" -> FileHash[tracePath, "SHA256"], "AcceptedHash" -> FileHash[acceptedPath, "SHA256"], "ExactComparison" -> True|>;
  saveExact[<|"InputHash" -> inputHash, "Evidence" -> evidence, "Value" -> candidate, "Checks" -> checks|>,
    FileNameJoin[{studyDirectory, "s05_" <> entry["name"] <> ".wl"}]];
  Print["POLYNOMIAL_PROJECTION_ACCEPTED ", InputForm[evidence]]; Clear[trace, accepted, candidate]; evidence,
  {entry, studyConfig["comparisons"]}];
gate["polynomial reduction exercised", Length[slicingMeasurements] > 0 && largestScalarInput =!= None];
gate["bounded coordinate reuse", Length[coordinateCache] <= 256 && coordinateBytes < 16*1024^2];
gate["original scalar and angular definitions retained", DownValues[reduceScalar] === originalScalarDefinitions &&
  {DownValues[angularAverage], DownValues[angularAverageOne]} === originalAngularDefinitions &&
  (DownValues[unslicedScalar] /. unslicedScalar -> algebraicReduceOne) === originalReductionDefinitions];
result = <|"Schema" -> "polarized-sidis-polynomial-scalar-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studyPath, "SHA256"], "ConfigHash" -> FileHash[studyConfigPath, "SHA256"],
  "ProductionSourceHash" -> FileHash[productionPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "OriginalReductionDefinitions" -> originalReductionDefinitions,
  "UnslicedDefinitions" -> DownValues[unslicedScalar], "PolynomialDefinitions" -> DownValues[polynomialScalar],
  "InstalledReductionDefinitions" -> DownValues[algebraicReduceOne], "OriginalCoordinateDefinitions" -> originalCoordinateDefinitions,
  "CachedCoordinateDefinitions" -> DownValues[cachedCoordinates], "CoordinateDefinitions" -> DownValues[coordinates],
  "OriginalScalarDefinitions" -> originalScalarDefinitions, "OriginalAngularDefinitions" -> originalAngularDefinitions,
  "TransverseConstraint" -> transverseConstraint, "CoordinateValues" -> coordinateCache,
  "LargestScalarInput" -> largestScalarInput, "Measurements" -> slicingMeasurements, "Comparisons" -> comparisonRows,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
saveExact[result, FileNameJoin[{studyDirectory, "s05_result.wl"}]];
Export[FileNameJoin[{studyDirectory, "s05_checks.json"}], <|"checks" -> checks, "comparisons" -> comparisonRows,
  "slice_operations" -> Length[slicingMeasurements], "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_polynomial_scalar"]; Quit[0];

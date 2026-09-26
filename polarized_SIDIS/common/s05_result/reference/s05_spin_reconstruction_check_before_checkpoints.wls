(* Inspect and check the actual Hgq spin polynomials without a whole-expression common denominator. *)
$HistoryLength = 0;
studyRoot = Directory[];
studySource = FileNameJoin[{studyRoot, "common", "s05_spin_reconstruction_check.wls"}];
studyInputPath = FileNameJoin[{studyRoot, "common", "s05_spin_reconstruction_inputs.json"}];
productionPath = FileNameJoin[{studyRoot, "common", "s05_real_spin_response.wls"}];
studyAssert[name_, test_] := If[!TrueQ[test], Print["FAIL: ", name]; Quit[1]];
studyAssert["study source syntax", SyntaxQ[Import[studySource, "Text"]]];
studyAssert["reviewed production source", IntegerString[FileHash[productionPath, "SHA256"], 16, 64] ===
  "24fe8bc812f0a7306ee73ab9346d0e772d6d0bba77839feee131da55142f5c65"];
productionText = Import[productionPath, "Text"];
prefixBoundary = StringPosition[productionText, "Do[\n  amplitudes ="];
studyAssert["unique production boundary", Length[prefixBoundary] === 1];
productionPrefix = StringTake[productionText, First[First[prefixBoundary]] - 1];
studyAssert["complete production initialization", SyntaxQ[productionPrefix]];
ToExpression[productionPrefix];
gate["study owns actual Hgq tensor", channel === "Hgq" && Length[labels] === 1];
gate["single allocated study kernel", Environment["NSLOTS"] === "1" || Environment["NSLOTS"] === $Failed];
label = First[labels];
fieldSetup = sourceSection[productionText, "\n  amplitudes =", "  Do[\n    leftIndex ="];
gate["complete inherited field setup", SyntaxQ[fieldSetup]];
ToExpression[fieldSetup];
studyInputs = Import[studyInputPath, "RawJSON"]["inputs"];
KeyValueMap[Function[{relative, identity}, gate["pinned equation " <> FileNameTake[relative],
  FileByteCount[FileNameJoin[{root, relative}]] === identity["bytes"] &&
  IntegerString[FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] === identity["sha256"]]], studyInputs];
equationPacket[a_, b_] := Module[{path, relative, packet},
  path = FileNameJoin[{cache, label <> "_assembled_Photon_" <> ToString[a] <> "_" <> ToString[b] <> ".wl"}];
  relative = StringDrop[path, StringLength[root] + 1];
  gate["equation present in pinned inventory", KeyExistsQ[studyInputs, relative]];
  packet = Get[path];
  gate["equation has original input identity", packet["InputHash"] === inputHash];
  gate["equation has original photon index", packet["Key"] === "Photon_" <> ToString[a] <> "_" <> ToString[b]];
  gate["equation checkpoint checks", AssociationQ[packet["Checks"]] && And @@ Values[packet["Checks"]]];
  packet["Value"]];
{loadSeconds, matrix} = AbsoluteTiming[Table[equationPacket[a, b],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}]];
photonCode = "  photonCoefficients = Tr[#.matrix] & /@ basis[\"PhotonDual\"];";
gate["inherited complete photon conversion", StringCount[productionText, photonCode] === 1];
ToExpression[photonCode];
{extractionSeconds, response} = AbsoluteTiming[
  bounded[compactSpinResponse[photonCoefficients, inVariables, outVariables], "study spin extraction"]];
variables = DeleteCases[Join[inVariables, outVariables], 1];
gate["native spin variable inventory", DuplicateFreeQ[variables] && AllTrue[variables, MatchQ[#, _Symbol] &]];
Print["SAVED_EQUATION_INVENTORY ", InputForm[<|"Channel" -> channel, "PhotonComponents" -> Length[photonCoefficients],
  "IncomingVariables" -> inVariables, "OutgoingVariables" -> outVariables, "MatrixBytes" -> ByteCount[matrix],
  "ResponseBytes" -> ByteCount[response], "LoadSeconds" -> loadSeconds, "ExtractionSeconds" -> extractionSeconds|>]];

(* Every operation and monomial is derived by the native polynomial tools from the saved expression. *)
spinPolynomialZero[value_, spinVariables_] := Module[{expanded, rows, monomials, reconstructed},
  gate["spin check polynomial", PolynomialQ[value, spinVariables]];
  expanded = Expand[value, Alternatives @@ spinVariables];
  If[expanded === 0, Return[True]];
  rows = CoefficientRules[expanded, spinVariables];
  monomials = (Times @@ MapThread[Power, {spinVariables, First[#]}]) & /@ rows;
  reconstructed = Total[MapThread[Times, {Last /@ rows, monomials}]];
  gate["spin check full polynomial reconstruction", Collect[expanded - reconstructed, spinVariables,
    Factor[Together[#]] &] === 0];
  And @@ (TrueQ[Factor[Together[#]] === 0] & /@ (Last /@ rows))];

studyRows = {}; acceptedComparisons = {};
Do[
  task = {a, photonCoefficients[[a]], response[[a]]};
  binding = Hash[{inputHash, label, task, inVariables, outVariables}, "SHA256"];
  checkpointPath = FileNameJoin[{cache, label <> "_spin_reconstruction_" <> ToString[a] <> ".wl"}];
  checkpointRelative = StringDrop[checkpointPath, StringLength[root] + 1];
  acceptedCheckpoint = If[KeyExistsQ[studyInputs, checkpointRelative], Get[checkpointPath], <||>];
  If[acceptedCheckpoint =!= <||>,
    gate["own accepted component binding " <> ToString[a], acceptedCheckpoint["InputHash"] === inputHash &&
      acceptedCheckpoint["Binding"] === binding && TrueQ[acceptedCheckpoint["Accepted"]] &&
      AssociationQ[acceptedCheckpoint["Checks"]] && Length[acceptedCheckpoint["Checks"]] > 0 &&
      And @@ Values[acceptedCheckpoint["Checks"]]]];
  gate["saved photon is a spin polynomial " <> ToString[a], PolynomialQ[task[[2]], variables]];
  observedDegrees = Exponent[task[[2]], #] & /@ variables;
  Print["ACTUAL_SPIN_EQUATION ", InputForm[<|"Component" -> a, "InputBytes" -> ByteCount[task[[2]]],
    "InputLeafCount" -> LeafCount[task[[2]]], "SpinDegrees" -> observedDegrees,
    "PriorAccepted" -> (acceptedCheckpoint =!= <||>)|>]];
  residual = task[[2]] - Sum[inVariables[[i]] outVariables[[j]] task[[3, j, i]],
    {i, Length[inVariables]}, {j, Length[outVariables]}];
  memoryBefore = MemoryInUse[];
  {candidateSeconds, candidateValue} = AbsoluteTiming[MemoryConstrained[
    TimeConstrained[spinPolynomialZero[residual, variables], 300, gate["study time limit", False]],
    4*1024^3, gate["study operation memory limit", False]]];
  gate["complete exact reconstruction " <> ToString[a], candidateValue];
  If[acceptedCheckpoint =!= <||>,
    gate["own accepted output comparison " <> ToString[a], candidateValue === acceptedCheckpoint["Accepted"]];
    AppendTo[acceptedComparisons, a]];
  row = <|"Component" -> a, "InputBytes" -> ByteCount[task[[2]]], "ResidualBytes" -> ByteCount[residual],
    "SpinDegrees" -> observedDegrees, "Seconds" -> candidateSeconds, "MemoryBeforeBytes" -> memoryBefore,
    "MemoryAfterBytes" -> MemoryInUse[], "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "ExactReconstruction" -> candidateValue,
    "AcceptedOriginalSeconds" -> Lookup[acceptedCheckpoint, "ElapsedSeconds", Missing["NotCompleted"]]|>;
  AppendTo[studyRows, row]; Print["SPIN_CHECK_MEASUREMENT ", InputForm[row]];
  Clear[task, residual, acceptedCheckpoint]; ClearSystemCache[], {a, Length[photonCoefficients]}];
gate["own accepted comparisons available", Length[acceptedComparisons] > 0];
gate["every photon component checked", Length[studyRows] === Length[photonCoefficients] && And @@ Lookup[studyRows, "ExactReconstruction"]];
studyResult = <|"Schema" -> "polarized-sidis-spin-reconstruction-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studySource, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ConfigurationHash" -> FileHash[studyInputPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "EquationFiles" -> studyInputs, "IncomingVariables" -> inVariables, "OutgoingVariables" -> outVariables,
  "CandidateDefinitions" -> DownValues[spinPolynomialZero], "OriginalPredicateDefinitions" -> DownValues[zero],
  "AcceptedComparisons" -> acceptedComparisons, "Measurements" -> studyRows, "Checks" -> checks,
  "FiniteNLOFHatsComputed" -> False|>;
studyResultDir = FileNameJoin[{root, channel, "s05_spin_reconstruction_result"}];
If[!DirectoryQ[studyResultDir], CreateDirectory[studyResultDir, CreateIntermediateDirectories -> True]];
studyResultPath = FileNameJoin[{studyResultDir, "s05_result.wl"}];
put[studyResult, studyResultPath];
gate["study exact saved round trip", Get[studyResultPath] === studyResult];
Export[FileNameJoin[{studyResultDir, "s05_checks.json"}],
  <|"channel" -> channel, "checks" -> checks, "accepted_comparisons" -> acceptedComparisons,
    "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_spin_reconstruction_check"]; Quit[0];

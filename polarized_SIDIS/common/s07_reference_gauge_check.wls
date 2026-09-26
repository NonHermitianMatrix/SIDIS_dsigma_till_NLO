(* Compare the native reference gluon sum with the resolved-spin sum. *)
$HistoryLength = 0;
probeRoot = Directory[];
probeSource = FileNameJoin[{probeRoot, "common", "s07_reference_gauge_check.wls"}];
acceptedSource = FileNameJoin[{probeRoot, "common", "s07_result", "reference", "s07_virtual_spin_response_before_parallel.wls"}];
If[IntegerString[FileHash[acceptedSource, "SHA256"], 16, 64] =!=
    "daca2aaa7d7253bbf0d9f0a48a88cac14bdd2b41b21f1e678b201cde6656a00b", Quit[1]];
acceptedText = Import[acceptedSource, "Text"];
definitionText = StringTake[acceptedText,
  First[First[StringPosition[acceptedText, "sourceHash = FileHash[sourcePath"]]] - 1];
definitionText = StringReplace[definitionText,
  "sourcePath = FileNameJoin[{root, \"common\", \"s07_virtual_spin_response.wls\"}];" ->
  "sourcePath = acceptedSource;"];
ToExpression[definitionText];
gate["complete gauge-check source syntax", SyntaxQ[Import[probeSource, "Text"]]];
gate["resolved external gluon", MemberQ[{p, k1}, gluonMomentum]];
originalDensity = gluonDensity;
unpolarizedRules = Thread[cdrVariables -> 0];
referenceDifferences = <||>; resolvedDifferences = <||>; bornDifferences = <||>;
covariantTensor = bounded[cdrAverage Block[{gluonDensity = fullSum},
  buildTensor[First[virtualAmplitudes]]] /. unpolarizedRules, "covariant closure"];
resolvedTensor = bounded[cdrAverage (buildTensor[First[virtualAmplitudes]] /. cdrRules), "resolved closure"];
Do[
  original = SelectFirst[reference["DiagramMaps"], #["Diagram"] === 1 && #["Mode"] === mode &];
  referenceValue = bounded[reduceScalar[original["ContractedIntegrand"] /. Q2 -> Q^2], "original " <> mode];
  projection = If[mode === "Pg", MTD[mu, nu], FVD[p, mu] FVD[p, nu]];
  Print["REFERENCE_GAUGE ", mode];
  covariantValue = bounded[traceScalar[covariantTensor projection], "covariant " <> mode];
  resolvedValue = bounded[traceScalar[resolvedTensor projection], "resolved " <> mode];
  AssociateTo[referenceDifferences, mode -> algebraicReduce[covariantValue - referenceValue]];
  AssociateTo[resolvedDifferences, mode -> algebraicReduce[resolvedValue - referenceValue]], {mode, {"Pg", "Ppp"}}];
bornDifferenceTensor = bounded[cdrAverage (
  Block[{gluonDensity = fullSum}, buildTensor[bornAmplitude]] /. unpolarizedRules) -
  cdrAverage (buildTensor[bornAmplitude] /. cdrRules), "Born gauge closure"];
Do[projection = If[mode === "Pg", MTD[mu, nu], FVD[p, mu] FVD[p, nu]];
  AssociateTo[bornDifferences, mode -> bounded[traceScalar[bornDifferenceTensor projection], "Born " <> mode]],
  {mode, {"Pg", "Ppp"}}];
gate["covariant first diagram reproduces reference", And @@ (zero /@ Values[referenceDifferences])];
gate["full Born tensor independent of compared gauge sums", And @@ (zero /@ Values[bornDifferences])];
physicalSpinDensity = originalDensity /. Last[vars] -> 0;
physicalSpinSum = originalDensity /. Thread[Rest[vars] -> 0];
candidateDensity = physicalSpinDensity + Last[vars] Contract[fullSum - physicalSpinSum];
gate["physical spin density unchanged", Contract[FCI[(candidateDensity /. Last[vars] -> 0) - physicalSpinDensity]] === 0];
gate["auxiliary component completes reference sum", Contract[FCI[(candidateDensity /. cdrRules) - fullSum]] === 0];
candidateBorn = bounded[Block[{gluonDensity = candidateDensity}, buildTensor[bornAmplitude]], "completed Born closure"];
candidateBornMatrix = Table[bounded[traceScalar[photonProject[candidateBorn, left, right]], {left, right, "completed Born"}],
  {left, photonSymbols}, {right, photonSymbols}];
candidateResponse = spinResponse[candidateBornMatrix];
bornResidual = algebraicReduce[candidateResponse - (born["ExtendedResponse"] /. Reverse[transverseRule])];
gate["entire extended Born response unchanged", zeroArray[bornResidual]];
resultDir = FileNameJoin[{root, channel, "s07_gauge_completion_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[<|"Schema" -> "polarized-sidis-virtual-gauge-completion-v1", "Channel" -> channel,
  "ReferenceDifferences" -> referenceDifferences, "ResolvedDifferences" -> resolvedDifferences,
  "BornDifferences" -> bornDifferences, "ExtendedBornResidual" -> bornResidual,
  "CandidateDensity" -> (candidateDensity /. scalarRestore), "Checks" -> checks,
  "SourceHash" -> FileHash[probeSource, "SHA256"], "CalculationSourceHash" -> FileHash[acceptedSource, "SHA256"],
  "InputHashes" -> <|"Amplitudes" -> FileHash[ampPath, "SHA256"], "Reference" -> FileHash[referencePath, "SHA256"],
    "Born" -> FileHash[bornPath, "SHA256"], "Basis" -> FileHash[basisPath, "SHA256"], "Angular" -> FileHash[angularPath, "SHA256"]|>,
  "FiniteNLOFHatsComputed" -> False|>, FileNameJoin[{resultDir, "s07_result.wl"}]];
Print["PASS: s07_reference_gauge_check"]; Quit[0];

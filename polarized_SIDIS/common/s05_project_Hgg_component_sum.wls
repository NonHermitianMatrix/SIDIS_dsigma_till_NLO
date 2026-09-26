(* Project one accepted complete photon sum with the original spin equations. *)
$HistoryLength = 0;
projectSource = FileNameJoin[{Directory[], "common", "s05_project_Hgg_component_sum.wls"}];
projectBase = FileNameJoin[{Directory[], "common", "s05_assemble_Hgg_component_sum.wls"}];
If[IntegerString[FileHash[projectBase, "SHA256"], 16, 64] =!=
  "67f4b5daf66d9ef7a7413eff9d64f61adcec1776a1d2679937355f797dae781f", Quit[1]];
projectBaseText = StringTrim[Import[projectBase, "Text"]];
projectTerminal = "ToExpression[assemblyRunTail, InputForm];";
If[!StringEndsQ[projectBaseText, projectTerminal] || !SyntaxQ[Import[projectSource, "Text"]], Quit[1]];
projectBootstrap = StringDrop[projectBaseText, -StringLength[projectTerminal]];
If[!SyntaxQ[projectBootstrap], Quit[1]];
ToExpression[projectBootstrap, InputForm];

assembleCompletedPairs[] := Module[{setting, component, dual, shape, generic, genericCoefficients,
  positions, required, entries = <||>, sumHashes = <||>, record, receipt, relative, path, key,
  controlPath, control, controlPhoton, controlResponse, originalPassed, candidate, proof, proofPath,
  originalSeconds, candidateSeconds, ownConjugate, conjugationSeconds, photon, response,
  reconstruction, responseSeconds, reconstructed, cdrRules, cdrAverage, directory, result, report,
  started = AbsoluteTime[]},
  gate["bounded own projection setup", channel === "Hgg" && labels === {label} && workerCount === 0 && !validationOnly];
  setting = Environment["POLARIZED_SIDIS_PROJECT_COMPONENT"];
  gate["integer requested photon component", StringQ[setting] && StringMatchQ[setting, DigitCharacter ..]];
  component = FromDigits[setting];
  gate["requested photon component belongs to basis", 1 <= component <= Length[basis["PhotonDual"]]];
  dual = basis["PhotonDual"][[component]]; shape = Dimensions[dual];
  gate["complete square photon basis", shape === {Length[photonSymbols], Length[photonSymbols]}];
  generic = Table[Unique["sidisPhotonEntry"], {shape[[1]]}, {shape[[2]]}];
  genericCoefficients = Tr[#.generic] & /@ basis["PhotonDual"];
  gate["original photon inverse for every matrix entry", Expand[generic -
    Total[MapThread[Times, {genericCoefficients, basis["PhotonBasis"]}]]] === ConstantArray[0, shape]];
  positions = Position[Transpose[dual], value_ /; value =!= 0, {2}, Heads -> False];
  gate["nonempty actual photon support", positions =!= {} && AllTrue[positions,
    MatchQ[#, {_Integer, _Integer}] && And @@ MapThread[1 <= #1 <= #2 &, {#, shape}] &]];
  required = Union[positions, Reverse /@ positions];
  gate["actual photon support reproduces original trace", Expand[genericCoefficients[[component]] -
    Total[(Extract[Transpose[dual], #] Extract[generic, #] &) /@ positions]] === 0];

  proofPath = FileNameJoin[{root, "Hqq", "s05_structural_reconstruction_result", "s05_result.wl"}];
  gate["pinned reusable reconstruction algorithm", IntegerString[FileHash[proofPath, "SHA256"], 16, 64] ===
    "b8d397e29a9b9210e2d4db1aabf361eb5ece0c338bbe0c93d0fd846fc8be44de"];
  proof = Get[proofPath];
  gate["accepted reconstruction implementation and extraction", TrueQ[proof["Accepted"]] &&
    And @@ Values[proof["Checks"]] && proof["NativeVersions"] === {$Version, $FeynCalcVersion} &&
    proof["ExtractionDefinitions"] === DownValues[compactSpinResponse]];
  DownValues[structuralSpinReconstruction] = proof["CandidateDefinitions"];
  gate["unchanged executed structural algorithm", DownValues[structuralSpinReconstruction] === proof["CandidateDefinitions"]];
  Clear[componentPacket, componentProof]; ClearSystemCache[];
  controlPath = FileNameJoin[{root, First[assemblyManifest["pairs"]]["file"]}];
  gate["own accepted first diagonal pair identity", First[pairs][[1]] === First[pairs][[2]] &&
    FileBaseName[controlPath] === label <> "_" <> StringRiffle[ToString /@ First[pairs], "_"] &&
    IntegerString[FileHash[controlPath, "SHA256"], 16, 64] === First[assemblyManifest["pairs"]]["sha256"]];
  control = bounded[Get[controlPath], "own projection control reader"];
  gate["own accepted control conventions", control["InputHash"] === inputHash &&
    control["SectorWardComparisonHash"] === wardProofHash && And @@ Values[control["Checks"]]];
  controlPhoton = Tr[dual.control["PhotonMatrix"]];
  controlResponse = First[bounded[compactSpinResponse[{controlPhoton}, inVariables, outVariables], "own original spin extraction"]];
  {originalSeconds, originalPassed} = AbsoluteTiming[bounded[zero[controlPhoton -
    Sum[inVariables[[i]] outVariables[[j]] controlResponse[[j, i]],
      {i, Length[inVariables]}, {j, Length[outVariables]}]], "own original spin reconstruction"]];
  {candidateSeconds, candidate} = AbsoluteTiming[bounded[structuralSpinReconstruction[
    controlPhoton, controlResponse, inVariables, outVariables], "own structural reconstruction comparison"]];
  gate["own complete original reconstruction reproduced", TrueQ[originalPassed] &&
    candidate["Accepted"] === originalPassed && And @@ Values[candidate["Checks"]]];
  {conjugationSeconds, ownConjugate} = AbsoluteTiming[bounded[
    zeroArray[control["PhotonMatrix"] - Transpose[Map[factoredRealConjugate, control["PhotonMatrix"], {2}]]],
    "own factored Hermiticity comparison"]];
  gate["own original Hermiticity reproduced", TrueQ[ownConjugate] && ownConjugate === bounded[
    zeroArray[algebraicReduce[ComplexExpand[control["PhotonMatrix"] - ConjugateTranspose[control["PhotonMatrix"]]]]],
    "own original Hermiticity"]];
  Clear[control, controlPhoton, controlResponse, proof]; ClearSystemCache[];

  Do[
    key = "Photon_" <> StringRiffle[ToString /@ position, "_"];
    relative = channel <> "/s05_component_sums_result/" <> key <> "/s05_result.wl";
    path = FileNameJoin[{root, relative}];
    receipt = Import[FileNameJoin[{DirectoryName[path], "s05_execution.json"}], "RawJSON"];
    gate["accepted complete sum file " <> key, TrueQ[receipt["passed"]] &&
      receipt["result_sha256"][relative] === IntegerString[FileHash[path, "SHA256"], 16, 64]];
    record = bounded[Get[path], {key, "complete sum reader"}];
    gate["complete sum conventions " <> key, record["Schema"] === "polarized-sidis-complete-component-sum-v1" &&
      record["InputHash"] === inputHash && record["InputHashes"] === inputHashes && record["Key"] === key &&
      record["SourceHash"] === FileHash[projectBase, "SHA256"] &&
      record["ManifestHash"] === FileHash[assemblyManifestPath, "SHA256"] &&
      record["NativeVersions"] === {$Version, $FeynCalcVersion} && And @@ Values[record["Checks"]]];
    AssociateTo[entries, key -> record["Value"]]; AssociateTo[sumHashes, relative -> FileHash[path, "SHA256"]];
    Clear[record]; ClearSystemCache[], {position, required}];
  Do[
    key = "Photon_" <> StringRiffle[ToString /@ position, "_"];
    gate["complete sum Hermiticity " <> key, bounded[zeroArray[entries[key] - factoredRealConjugate[
      entries["Photon_" <> StringRiffle[ToString /@ Reverse[position], "_"]]]], {key, "full native Hermiticity"}]],
    {position, positions}];
  photon = Total[(Extract[Transpose[dual], #] entries["Photon_" <> StringRiffle[ToString /@ #, "_"]] &) /@ positions];
  Clear[entries]; ClearSystemCache[];
  {responseSeconds, response} = AbsoluteTiming[First[bounded[
    compactSpinResponse[{photon}, inVariables, outVariables], "complete original spin extraction"]]];
  reconstruction = bounded[structuralSpinReconstruction[photon, response, inVariables, outVariables],
    "complete native spin reconstruction"];
  gate["entire actual spin polynomial reconstructed", TrueQ[reconstruction["Accepted"]] && And @@ Values[reconstruction["Checks"]]];
  cdrRules = Thread[Join[Rest[inVariables], Rest[outVariables]] ->
    (If[MemberQ[{eIn, eOut}, #], 1, 0] & /@ Join[Rest[inVariables], Rest[outVariables]])];
  cdrAverage = If[incomingQuark, 1, basis["IncomingDensityNormalization"]/gluonDimensions[p]];
  reconstructed = cdrAverage (photon /. cdrRules);
  Clear[photon]; ClearSystemCache[];
  directory = FileNameJoin[{root, channel, "s05_projected_components_result", "Photon_" <> ToString[component]}];
  If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
  result = <|"Schema" -> "polarized-sidis-complete-photon-spin-component-v1", "Channel" -> channel,
    "Component" -> component, "PhotonLabel" -> basis["PhotonLabels"][[component]], "Response" -> response,
    "CDRPhotonCoefficient" -> reconstructed, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "SumInputHashes" -> sumHashes, "SourceHash" -> FileHash[projectSource, "SHA256"],
    "BasisHash" -> FileHash[basisPath, "SHA256"], "ControlHash" -> FileHash[controlPath, "SHA256"],
    "ReconstructionAlgorithmHash" -> FileHash[proofPath, "SHA256"], "NativeVersions" -> {$Version, $FeynCalcVersion},
    "IncomingVariables" -> inVariables, "OutgoingVariables" -> outVariables, "Reconstruction" -> reconstruction,
    "OriginalControlSeconds" -> originalSeconds, "CandidateControlSeconds" -> candidateSeconds,
    "ResponseSeconds" -> responseSeconds, "ElapsedSeconds" -> AbsoluteTime[] - started,
    "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
  put[result, FileNameJoin[{directory, "s05_result.wl"}]];
  report = <|"channel" -> channel, "component" -> component, "checks" -> checks,
    "response_bytes" -> ByteCount[response], "original_control_seconds" -> originalSeconds,
    "candidate_control_seconds" -> candidateSeconds, "response_seconds" -> responseSeconds,
    "elapsed_seconds" -> AbsoluteTime[] - started, "peak_kernel_memory_bytes" -> MaxMemoryUsed[],
    "finite_nlo_fhats_computed" -> False|>;
  Export[FileNameJoin[{directory, "s05_checks.json"}], report, "RawJSON"];
  Print["PASS: s05_project_Hgg_component_sum"]; Quit[0]];
ToExpression[assemblyRunTail, InputForm];

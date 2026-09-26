(* Preserve the real calculation; reuse accepted linear photon/spin algorithms. *)
$HistoryLength = 0;
hqgLinearSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hqg_linear_assembly.wls"}];
hqgLinearBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hqg_factored_checks.wls"}];
If[IntegerString[FileHash[hqgLinearBase, "SHA256"], 16, 64] =!=
  "08b1d34c8409ad990833c54704d8d65ca8ab87e4ca8dfb7324665d6fd7bb026d" ||
  !SyntaxQ[Import[hqgLinearSource, "Text"]], Quit[1]];
hqgLinearText = StringTrim[Import[hqgLinearBase, "Text"]];
hqgLinearTerminal = "ToExpression[hqgCheckRun, InputForm];";
If[!StringEndsQ[hqgLinearText, hqgLinearTerminal], Quit[1]];
hqgLinearPrefix = StringDrop[hqgLinearText, -StringLength[hqgLinearTerminal]];
If[!SyntaxQ[hqgLinearPrefix], Quit[1]];
ToExpression[hqgLinearPrefix, InputForm];
hqgStructuralPath = FileNameJoin[{root, "Hqq", "s05_structural_reconstruction_result", "s05_result.wl"}];
gate["pinned accepted structural spin algorithm", IntegerString[FileHash[hqgStructuralPath, "SHA256"], 16, 64] ===
  "b8d397e29a9b9210e2d4db1aabf361eb5ece0c338bbe0c93d0fd846fc8be44de"];
hqgStructuralProof = Get[hqgStructuralPath];
hqgStructuralSource = FileNameJoin[{root, "common", "s05_check_structural_reconstruction.wls"}];
gate["accepted structural definitions and native extraction", TrueQ[hqgStructuralProof["Accepted"]] &&
  And @@ Values[hqgStructuralProof["Checks"]] && hqgStructuralProof["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  hqgStructuralProof["SourceHash"] === FileHash[hqgStructuralSource, "SHA256"] &&
  hqgStructuralProof["ExtractionDefinitions"] === DownValues[compactSpinResponse]];
hqgStructuralDefinition = sourceSection[Import[hqgStructuralSource, "Text"],
  "\nstructuralSpinReconstruction[expression_", "\nmeasurements ="];
gate["complete original structural definition syntax", SyntaxQ[hqgStructuralDefinition]];
ToExpression[hqgStructuralDefinition, InputForm];
gate["same executed structural reconstruction", DownValues[structuralSpinReconstruction] === hqgStructuralProof["CandidateDefinitions"]];
hqgExtractionChanges = {
  "structuralSpinReconstruction[expression_, response_, incoming_, outgoing_]" ->
    "structuralSpinExtraction[expression_, incoming_, outgoing_]",
  ",\n    \"ExactExistingResponse\" -> (restored === response)" -> "",
  "<|\"Accepted\" -> (And @@ Values[evidence]), \"Checks\" -> evidence," ->
    "<|\"Response\" -> restored, \"Accepted\" -> (And @@ Values[evidence]), \"Checks\" -> evidence,"};
gate["unique structural extraction interfaces", And @@ (StringCount[hqgStructuralDefinition, First[#]] === 1 & /@ hqgExtractionChanges)];
hqgExtractionDefinition = StringReplace[hqgStructuralDefinition, hqgExtractionChanges];
hqgExtractionRestored = StringReplace[hqgExtractionDefinition, {
  Last[hqgExtractionChanges[[1]]] -> First[hqgExtractionChanges[[1]]],
  Last[hqgExtractionChanges[[3]]] -> First[hqgExtractionChanges[[3]]],
  "AssociateTo[evidence, {\"ExactAbstractReconstruction\" -> (Expand[opaque - reconstructed] === 0)}];" ->
    "AssociateTo[evidence, {\"ExactAbstractReconstruction\" -> (Expand[opaque - reconstructed] === 0),\n    \"ExactExistingResponse\" -> (restored === response)}];"}];
gate["complete original structural derivation retained", SyntaxQ[hqgExtractionDefinition] &&
  hqgExtractionRestored === hqgStructuralDefinition];
ToExpression[hqgExtractionDefinition, InputForm];
hqgLinearEvidence = <||>;
hqgExtractOne[expression_, incoming_, outgoing_] := Module[{packet},
  packet = structuralSpinExtraction[expression, incoming, outgoing];
  gate["complete structural extraction reconstruction", TrueQ[packet["Accepted"]] && And @@ Values[packet["Checks"]]];
  packet["Response"]];
hqgStructuralCheck[expression_, response_, incoming_, outgoing_] := Module[{packet},
  packet = structuralSpinReconstruction[expression, response, incoming, outgoing];
  TrueQ[packet["Accepted"]] && And @@ Values[packet["Checks"]]];
hqgLinearPhotonCheck[full_, actual_, own_] := Module[{generic, coefficients, ownMatrix, ownPhotons,
  ownOriginal, originalResponse, candidateResponse, oldSpin, newSpin, substitution,
  originalSeconds, candidateSeconds, ownExtractionSeconds, fullMatch},
  generic = Array[Unique["sidisPhotonEntry"] &, Dimensions[full]];
  coefficients = Tr[#.generic] & /@ basis["PhotonDual"];
  gate["complete native linear photon inverse", Expand[generic -
    Total[MapThread[Times, {coefficients, basis["PhotonBasis"]}]]] === ConstantArray[0, Dimensions[full]]];
  ownMatrix = own["PhotonMatrix"]; ownPhotons = Tr[#.ownMatrix] & /@ basis["PhotonDual"];
  {originalSeconds, ownOriginal} = AbsoluteTiming[bounded[zeroArray[Expand[ownMatrix -
    Total[MapThread[Times, {ownPhotons, basis["PhotonBasis"]}]]]], "own original photon reconstruction"]];
  gate["own accepted original photon reconstruction", TrueQ[ownOriginal]];
  substitution = Thread[Flatten[generic] -> Flatten[ownMatrix]];
  gate["own exact original photon coefficients", (coefficients /. substitution) === ownPhotons];
  {ownExtractionSeconds, originalResponse} = AbsoluteTiming[bounded[
    compactSpinResponse[ownPhotons, inVariables, outVariables], "own original complete spin response"]];
  {candidateSeconds, candidateResponse} = AbsoluteTiming[bounded[
    (hqgExtractOne[#, inVariables, outVariables] & /@ ownPhotons), "own structural complete spin response"]];
  gate["own entire original spin response exactly reproduced", candidateResponse === originalResponse];
  Do[
    oldSpin = bounded[spinReconstructionZero[ownPhotons[[a]] -
      Sum[inVariables[[i]] outVariables[[j]] originalResponse[[a, j, i]],
        {i, Length[inVariables]}, {j, Length[outVariables]}]], "own original spin reconstruction"];
    newSpin = bounded[hqgStructuralCheck[ownPhotons[[a]], candidateResponse[[a]], inVariables, outVariables],
      "own structural spin reconstruction"];
    gate["own native reconstruction comparison " <> ToString[a], TrueQ[oldSpin] && newSpin === oldSpin],
    {a, Length[ownPhotons]}];
  substitution = Thread[Flatten[generic] -> Flatten[full]];
  fullMatch = (coefficients /. substitution) === actual;
  gate["entire actual photon transform exactly specialized", fullMatch];
  hqgLinearEvidence = <|"ControlHash" -> Hash[own, "SHA256"], "FullMatrixBytes" -> ByteCount[full],
    "OriginalPhotonSeconds" -> originalSeconds, "OriginalExtractionSeconds" -> ownExtractionSeconds,
    "CandidateExtractionSeconds" -> candidateSeconds, "StructuralProofHash" -> FileHash[hqgStructuralPath, "SHA256"],
    "FullTransformExactlySpecialized" -> fullMatch, "OwnResponseExactlyReproduced" -> (candidateResponse === originalResponse)|>;
  fullMatch];
hqgPhotonOld = "zeroArray[bounded[\n    Expand[matrix - Total[MapThread[Times, {photonCoefficients, basis[\"PhotonBasis\"]}]]], {label, \"linear photon reconstruction\"}]]";
hqgSpinOld = "compactSpinResponse[photonCoefficients, inVariables, outVariables]";
hqgReconstructionOld = "spinReconstructionZero[task[[2]] -\n      Sum[inVariables[[i]] outVariables[[j]] task[[3, j, i]], {i, Length[inVariables]}, {j, Length[outVariables]}]]";
hqgLinearChanges = {
  hqgPhotonOld -> "hqgLinearPhotonCheck[matrix, photonCoefficients, First[pairValues]]",
  hqgSpinOld -> "(hqgExtractOne[#, inVariables, outVariables] & /@ photonCoefficients)",
  hqgReconstructionOld -> "hqgStructuralCheck[task[[2]], task[[3]], inVariables, outVariables]",
  "DistributeDefinitions[spinReconstructionTask, inVariables, outVariables]" ->
    "DistributeDefinitions[spinReconstructionTask, structuralSpinReconstruction, hqgStructuralCheck, inVariables, outVariables]",
  hqgOutput -> (hqgOutput <>
    "\nAssociateTo[result,{\"LinearAssemblyDispatchHash\"->FileHash[hqgLinearSource,\"SHA256\"],\"LinearAssemblyComparison\"->hqgLinearEvidence}];")};
gate["unique remaining linear assembly interfaces", And @@ (StringCount[hqgCheckRun, First[#]] === 1 & /@ hqgLinearChanges)];
hqgLinearRun = StringReplace[hqgCheckRun, hqgLinearChanges];
gate["all other real equations and native writer unchanged", SyntaxQ[hqgLinearRun] &&
  StringReplace[hqgLinearRun, Reverse /@ hqgLinearChanges] === hqgCheckRun];
ToExpression[hqgLinearRun, InputForm];

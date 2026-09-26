(* Reuse the accepted real calculation and factored conjugation check. *)
$HistoryLength = 0;
hqgCheckSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hqg_factored_checks.wls"}];
hqgCheckBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_Hqg_early_power.wls"}];
If[IntegerString[FileHash[hqgCheckBase, "SHA256"], 16, 64] =!=
  "a8f2dc4ca21a878346180632dc80596952c450f9519c0010569e5a0bb617cbbf" ||
  !SyntaxQ[Import[hqgCheckSource, "Text"]], Quit[1]];
hqgCheckText = StringTrim[Import[hqgCheckBase, "Text"]];
hqgCheckTerminal = "ToExpression[earlyRunTail,InputForm];";
If[!StringEndsQ[hqgCheckText, hqgCheckTerminal], Quit[1]];
hqgCheckPrefix = StringDrop[hqgCheckText, -StringLength[hqgCheckTerminal]];
If[!SyntaxQ[hqgCheckPrefix], Quit[1]];
ToExpression[hqgCheckPrefix, InputForm];
gate["own complete factored-check setup", channel === "Hqg" && useFactoredPair && !validationOnly];
gate["unchanged accepted conjugation routine", DownValues[factoredRealConjugate] === pairProof["ConjugationDefinitions"]];
hqgCheckEvidence = <||>;
hqgFactoredHermiticity[full_, own_] := Module[{original, candidate, originalSeconds, candidateSeconds,
  fullSeconds, fullValue, ownMatrix, originalDefinitions},
  gate["own accepted pair for complete matrix comparison", AssociationQ[own] &&
    own["InputHash"] === inputHash && AssociationQ[own["Checks"]] && And @@ Values[own["Checks"]]];
  ownMatrix = own["PhotonMatrix"];
  originalDefinitions = DownValues[factoredRealConjugate];
  {originalSeconds, original} = AbsoluteTiming[bounded[
    zeroArray[algebraicReduce[ComplexExpand[ownMatrix - ConjugateTranspose[ownMatrix]]]],
    "own original complete Hermiticity"]];
  {candidateSeconds, candidate} = AbsoluteTiming[bounded[
    zeroArray[algebraicReduce[ownMatrix - Transpose[Map[factoredRealConjugate, ownMatrix, {2}]]]],
    "own factored complete Hermiticity"]];
  gate["own complete original Hermiticity predicate reproduced", TrueQ[original] && candidate === original];
  gate["same conjugation definition after own comparison", DownValues[factoredRealConjugate] === originalDefinitions];
  Print["Hqg_FACTORED_HERMITICITY input_bytes ", ByteCount[full],
    " original_control_seconds ", originalSeconds, " candidate_control_seconds ", candidateSeconds];
  {fullSeconds, fullValue} = AbsoluteTiming[bounded[
    zeroArray[algebraicReduce[full - Transpose[Map[factoredRealConjugate, full, {2}]]]],
    "complete Hqg factored Hermiticity"]];
  hqgCheckEvidence = <|"ControlHash" -> Hash[own, "SHA256"], "InputHash" -> inputHash,
    "ConjugationDefinitions" -> originalDefinitions, "OriginalSeconds" -> originalSeconds,
    "CandidateSeconds" -> candidateSeconds, "FullSeconds" -> fullSeconds,
    "FullInputBytes" -> ByteCount[full], "OwnOriginalExactlyReproduced" -> (candidate === original),
    "FullAccepted" -> fullValue|>;
  fullValue];
hqgOriginalHermiticity = "zeroArray[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]]]";
hqgCandidateHermiticity = "hqgFactoredHermiticity[matrix, First[pairValues]]";
hqgOutput = "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
hqgChanges = {hqgOriginalHermiticity -> hqgCandidateHermiticity,
  hqgOutput -> (hqgOutput <>
    "\nAssociateTo[result,{\"HermiticityDispatchHash\"->FileHash[hqgCheckSource,\"SHA256\"],\"HermiticityComparison\"->hqgCheckEvidence}];")};
gate["unique complete Hermiticity and output interfaces", And @@ (StringCount[earlyRunTail, First[#]] === 1 & /@ hqgChanges)];
hqgCheckRun = StringReplace[earlyRunTail, hqgChanges];
gate["all remaining real equations unchanged", StringReplace[hqgCheckRun, Reverse /@ hqgChanges] === earlyRunTail && SyntaxQ[hqgCheckRun]];
ToExpression[hqgCheckRun, InputForm];

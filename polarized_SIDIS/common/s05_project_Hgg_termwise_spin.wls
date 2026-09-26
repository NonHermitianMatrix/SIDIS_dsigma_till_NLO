(* Reuse the complete photon projection with bounded conjugation support lists. *)
$HistoryLength = 0;
termwiseSource = FileNameJoin[{Directory[], "common", "s05_project_Hgg_termwise_spin.wls"}];
termwiseBase = FileNameJoin[{Directory[], "common", "s05_project_Hgg_component_sum.wls"}];
If[IntegerString[FileHash[termwiseBase, "SHA256"], 16, 64] =!=
  "8da952ed338e8def5ff361a70cb26d6836433e69e0e0858e474830fb35d609b6" ||
  !SyntaxQ[Import[termwiseSource, "Text"]], Quit[1]];
termwiseText = Import[termwiseBase, "Text"];
termwiseSetup = "  Clear[componentPacket, componentProof]; ClearSystemCache[];";
termwiseControl = "  {conjugationSeconds, ownConjugate} = AbsoluteTiming[bounded[";
termwiseMetadata = "\"ReconstructionAlgorithmHash\" -> FileHash[proofPath, \"SHA256\"],";
termwiseInitialization = "
  originalConjugationDefinitions = DownValues[factoredRealConjugate];
  DownValues[termConjugate] = originalConjugationDefinitions /.
    factoredRealConjugate -> termConjugate /. HoldPattern[Print[arguments___]] :>
      conjugationSupportNotice[arguments];
  gate[\"same conjugation operations apart from support logging\",
    (DownValues[termConjugate] /. termConjugate -> factoredRealConjugate /.
      conjugationSupportNotice -> Print) === originalConjugationDefinitions];
  conjugationSupportNotice[___] := Null;
  streamedRealConjugate[value_] := Module[{parts, answer},
    parts = If[Head[value] === Plus, List @@ value, {value}];
    Print[\"TERMWISE_CONJUGATION input_bytes \", ByteCount[value],
      \" terms \", Length[parts], \" largest_term_bytes \", Max[ByteCount /@ parts]];
    answer = Total[termConjugate /@ parts];
    gate[\"streamed conjugation retains native scalar output\", FreeQ[answer,
      _Conjugate | _Re | _Im | _ConditionalExpression | _Piecewise | $Failed | $Aborted]];
    answer];
  streamedSpinResponse[value_, incoming_, outgoing_] := Module[{parts},
    parts = If[Head[value] === Plus, List @@ value, {value}];
    Print[\"TERMWISE_SPIN_EXTRACTION input_bytes \", ByteCount[value],
      \" terms \", Length[parts], \" largest_term_bytes \", Max[ByteCount /@ parts]];
    Total[First[compactSpinResponse[{#}, incoming, outgoing]] & /@ parts]];
";
termwiseOwnComparison = "
  gate[\"own complete original spin response exactly reproduced\", bounded[
    streamedSpinResponse[controlPhoton, inVariables, outVariables] === controlResponse,
    \"own termwise spin extraction comparison\"]];
  {termwiseControlSeconds, termwiseControlExact} = AbsoluteTiming[bounded[
    Map[streamedRealConjugate, control[\"PhotonMatrix\"], {2}] ===
      Map[factoredRealConjugate, control[\"PhotonMatrix\"], {2}],
    \"own complete termwise conjugation comparison\"]];
  gate[\"own complete conjugated matrix exactly reproduced\", termwiseControlExact];
";
termwiseChanges = {
  termwiseSetup -> (termwiseSetup <> termwiseInitialization),
  termwiseControl -> (termwiseOwnComparison <> termwiseControl),
  "Map[factoredRealConjugate, control[\"PhotonMatrix\"], {2}]]]," ->
    "Map[streamedRealConjugate, control[\"PhotonMatrix\"], {2}]]],",
  "zeroArray[entries[key] - factoredRealConjugate[" ->
    "zeroArray[entries[key] - streamedRealConjugate[",
  "First[bounded[\n    compactSpinResponse[{photon}, inVariables, outVariables], \"complete original spin extraction\"]]" ->
    "bounded[streamedSpinResponse[photon, inVariables, outVariables], \"complete termwise spin extraction\"]",
  termwiseMetadata -> (termwiseMetadata <>
    "\n    \"ConjugationDispatchHash\" -> FileHash[termwiseSource, \"SHA256\"]," <>
    "\n    \"OwnConjugationComparisonSeconds\" -> termwiseControlSeconds,")};
If[!And @@ (StringCount[termwiseText, First[#]] === 1 & /@ termwiseChanges),
  Print["FAIL: unique termwise conjugation interfaces"]; Quit[1]];
termwiseRun = StringReplace[termwiseText, termwiseChanges];
If[!SyntaxQ[termwiseRun] || StringReplace[termwiseRun, Reverse /@ termwiseChanges] =!= termwiseText,
  Print["FAIL: unchanged complete projection around conjugation"]; Quit[1]];
ToExpression[termwiseRun, InputForm];

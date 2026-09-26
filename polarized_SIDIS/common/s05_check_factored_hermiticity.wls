(* Check saved own matrices with the already executed factorized conjugation. *)
$HistoryLength = 0;
hermiticityStudyPath = FileNameJoin[{Directory[], "common", "s05_check_factored_hermiticity.wls"}];
hermiticityBasePath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[hermiticityBasePath, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff", Quit[1]];
hermiticityText = Import[hermiticityBasePath, "Text"];
hermiticityBoundary = StringPosition[hermiticityText, "\nDo[\n  amplitudes ="];
If[Length[hermiticityBoundary] =!= 1 || !SyntaxQ[Import[hermiticityStudyPath, "Text"]], Quit[1]];
hermiticityPrefix = StringTake[hermiticityText, First[First[hermiticityBoundary]] - 1];
If[StringCount[hermiticityPrefix, "Get[\"FeynCalc`\"]"] =!= 1, Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
hermiticityPrefix = StringReplace[hermiticityPrefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[hermiticityPrefix], Quit[1]];
ToExpression[hermiticityPrefix, InputForm];
gate["own Hqq factorized Hermiticity interfaces", channel === "Hqq" && useFactoredPair && useRestoredScalar];
gate["same executed factorized conjugation", DownValues[factoredRealConjugate] === pairProof["ConjugationDefinitions"]];
SetAttributes[hermiticityBounded, HoldFirst];
hermiticityBounded[value_, description_] := MemoryConstrained[TimeConstrained[value, 600,
  gate["Hermiticity time bound " <> description, False]], 4*1024^3,
  gate["Hermiticity memory bound " <> description, False]];
factoredHermiticity[matrix_] := zeroArray[matrix - Transpose[Map[factoredRealConjugate, matrix, {2}]]];
originalHermiticity[matrix_] := zeroArray[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]]];
gate["original complete Hermiticity equation retained", StringContainsQ[hermiticityText,
  "zeroArray[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]]]"]];
hermiticityDimensions = Dimensions[First[basis["PhotonDual"]]];
hermiticityKeys = Table["Photon_" <> ToString[a] <> "_" <> ToString[b],
  {a, First[hermiticityDimensions]}, {b, Last[hermiticityDimensions]}];
hermiticityLabels = Select[labels, Function[sector,
  AllTrue[Flatten[hermiticityKeys], FileExistsQ[FileNameJoin[{cache, sector <> "_assembled_" <> # <> ".wl"}]] &]]];
gate["reported slow sector has all saved photon sums", MemberQ[hermiticityLabels, "RealSame"]];
hermiticityInputHashes = <||>;
hermiticityRows = Table[
  Print["OWN_HERMITICITY_SECTOR ", label];
  fieldSetup = sourceSection[hermiticityText, "\n  amplitudes =", "  quarkIn ="];
  gate["complete original sector field setup syntax", SyntaxQ[fieldSetup]];
  ToExpression[fieldSetup, InputForm];
  pairInventory = Flatten[Table[{i, j}, {i, Length[amplitudes]}, {j, i, Length[amplitudes]}], 1];
  controlPair = First[pairInventory];
  gate["own original Hermiticity control diagonal", SameQ @@ controlPair];
  controlPath = FileNameJoin[{cache, label <> "_" <> StringRiffle[ToString /@ controlPair, "_"] <> ".wl"}];
  control = Get[controlPath];
  gate["own accepted pair binding " <> label, AssociationQ[control] && control["InputHash"] === inputHash &&
    MatrixQ[control["PhotonMatrix"]] && AssociationQ[control["Checks"]] && And @@ Values[control["Checks"]]];
  AssociateTo[hermiticityInputHashes, StringDrop[controlPath, StringLength[root] + 1] -> FileHash[controlPath, "SHA256"]];
  {originalSeconds, originalValue} = AbsoluteTiming[hermiticityBounded[originalHermiticity[control["PhotonMatrix"]], "own original pair"]];
  {controlSeconds, controlValue} = AbsoluteTiming[hermiticityBounded[factoredHermiticity[control["PhotonMatrix"]], "own factorized pair"]];
  gate["own complete original Hermiticity reproduced " <> label, TrueQ[originalValue] && controlValue === originalValue];
  negativeValue = hermiticityBounded[factoredHermiticity[control["PhotonMatrix"] + I IdentityMatrix[Length[control["PhotonMatrix"]]]], "negative control"];
  gate["changed own Hermiticity control rejected " <> label, negativeValue === False];
  matrix = Map[Function[key,
    path = FileNameJoin[{cache, label <> "_assembled_" <> key <> ".wl"}];
    packet = Get[path];
    gate["saved own photon sum " <> label <> " " <> key, AssociationQ[packet] && packet["InputHash"] === inputHash &&
      packet["Key"] === key && AssociationQ[packet["Checks"]] && And @@ Values[packet["Checks"]]];
    AssociateTo[hermiticityInputHashes, StringDrop[path, StringLength[root] + 1] -> FileHash[path, "SHA256"]];
    packet["Value"]], hermiticityKeys, {2}];
  gate["complete own saved photon matrix " <> label, Dimensions[matrix] === hermiticityDimensions &&
    FreeQ[matrix, _Missing | $Failed | $Aborted]];
  {seconds, value} = AbsoluteTiming[hermiticityBounded[factoredHermiticity[matrix], "complete own sector"]];
  gate["complete own sector Hermiticity " <> label, TrueQ[value]];
  evidence = <|"Sector" -> label, "MatrixHash" -> Hash[matrix, "SHA256"], "MatrixBytes" -> ByteCount[matrix],
    "ControlHash" -> FileHash[controlPath, "SHA256"], "OriginalControlSeconds" -> originalSeconds,
    "CandidateControlSeconds" -> controlSeconds, "CandidateSectorSeconds" -> seconds,
    "OriginalControlPassed" -> originalValue, "NegativeControlRejected" -> (negativeValue === False), "Accepted" -> value|>;
  Print["OWN_HERMITICITY_ACCEPTED ", InputForm[evidence]];
  Clear[matrix, packet, control]; ClearSystemCache[]; evidence, {label, hermiticityLabels}];
hermiticityResult = <|"Schema" -> "polarized-sidis-saved-hermiticity-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[hermiticityStudyPath, "SHA256"], "ProductionSourceHash" -> FileHash[hermiticityBasePath, "SHA256"],
  "InputHash" -> inputHash, "PhysicalInputHashes" -> inputHashes, "EquationInputHashes" -> hermiticityInputHashes,
  "ConjugationProofHash" -> FileHash[pairProofPath, "SHA256"], "ConjugationDefinitions" -> DownValues[factoredRealConjugate],
  "CandidateDefinitions" -> DownValues[factoredHermiticity], "OriginalDefinitions" -> DownValues[originalHermiticity],
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Sectors" -> Association[(#["Sector"] -> #) & /@ hermiticityRows],
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
hermiticityDirectory = FileNameJoin[{root, channel, "s05_hermiticity_result"}];
If[!DirectoryQ[hermiticityDirectory], CreateDirectory[hermiticityDirectory, CreateIntermediateDirectories -> True]];
hermiticityResultPath = FileNameJoin[{hermiticityDirectory, "s05_result.wl"}];
hermiticitySerialized = "Uncompress[" <> ToString[Compress[hermiticityResult], InputForm] <> "]\n";
gate["bounded saved Hermiticity proof", StringLength[hermiticitySerialized] < 128*1024^2];
Export[hermiticityResultPath <> ".tmp", hermiticitySerialized, "Text"];
gate["exact saved Hermiticity proof reload", Get[hermiticityResultPath <> ".tmp"] === hermiticityResult];
RenameFile[hermiticityResultPath <> ".tmp", hermiticityResultPath, OverwriteTarget -> True];
Export[FileNameJoin[{hermiticityDirectory, "s05_checks.json"}], <|"checks" -> checks, "sectors" -> hermiticityRows,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_factored_hermiticity"]; Quit[0];

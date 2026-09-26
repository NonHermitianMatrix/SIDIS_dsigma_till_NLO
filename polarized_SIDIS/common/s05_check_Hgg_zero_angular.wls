(* Reuse the executed angular-zero predicate and compare complete own Hgg projections. *)
$HistoryLength = 0;
studyPath = FileNameJoin[{Directory[], "common", "s05_check_Hgg_zero_angular.wls"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: original scalar source binding"]; Quit[1]];
productionText = Import[productionPath, "Text"];
boundary = StringPosition[productionText, "\nDo[\n  amplitudes ="];
If[Length[boundary] =!= 1 || !SyntaxQ[Import[studyPath, "Text"]],
  Print["FAIL: complete comparison syntax"]; Quit[1]];
productionPrefix = StringTake[productionText, First[First[boundary]] - 1];
If[StringCount[productionPrefix, "Get[\"FeynCalc`\"]"] =!= 1,
  Print["FAIL: unique native package loader"]; Quit[1]];
productionPrefix = StringReplace[productionPrefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
If[!SyntaxQ[productionPrefix], Print["FAIL: native initialization syntax"]; Quit[1]];
ToExpression[productionPrefix, InputForm];
gate["own Hgg comparison interfaces", channel === "Hgg" && useRestoredScalar && useFactoredPair];
parentRelative = "Hqg/s05_zero_angular_result/s05_result.wl";
parentPath = FileNameJoin[{root, parentRelative}];
parentReceiptPath = FileNameJoin[{root, "Hqg", "s05_zero_angular_result", "s05_execution.json"}];
gate["pinned executed angular-zero proof and receipt",
  IntegerString[FileHash[parentPath, "SHA256"], 16, 64] === "5652da0e601652452b43370aaf27f376b628d041eb0aa20641683d420b50abd3" &&
  IntegerString[FileHash[parentReceiptPath, "SHA256"], 16, 64] === "7fb216094c1d7593fd3b084ee5775bf21b4a14577593481d365d3bb6e64cbb67"];
parentProof = Get[parentPath]; parentReceipt = Import[parentReceiptPath, "RawJSON"];
gate["accepted parent angular-zero comparison", TrueQ[parentReceipt["passed"]] &&
  parentReceipt["result_sha256"][parentRelative] === IntegerString[FileHash[parentPath, "SHA256"], 16, 64] &&
  parentProof["Schema"] === "polarized-sidis-zero-angular-shortcut-validation-v1" &&
  parentProof["Channel"] === "Hqg" && AssociationQ[parentProof["Checks"]] && Length[parentProof["Checks"]] > 0 &&
  And @@ Values[parentProof["Checks"]] && parentProof["SourceHash"] ===
    FileHash[FileNameJoin[{root, "common", "s05_check_zero_angular.wls"}], "SHA256"] &&
  parentProof["ProductionSourceHash"] === FileHash[productionPath, "SHA256"] &&
  parentProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
Do[gate["parent physical convention " <> relative, parentProof["InputHashes"][relative] === inputHashes[relative]],
  {relative, {"common/s02_result/s02_result.wl", "common/s04_result/s04_result.wl"}}];
originalReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne],
  DownValues[angularAverage], DownValues[angularAverageOne]};
gate["identical scalar and angular equations", parentProof["OriginalReductionDefinitions"] === originalReductionDefinitions &&
  parentProof["OriginalCheckpointDefinitions"] === coefficientProof["CheckpointDefinitions"]];
DownValues[exactAngularZero] = parentProof["ZeroAngularDefinitions"];
DownValues[zeroCheckpointedScalarComponent] = parentProof["GuardedCheckpointDefinitions"];
DownValues[restoreOnly] = coefficientProof["OriginalRestorationDefinitions"] /.
  {restoredScalarComponent -> restoreOnly, algebraicReduce -> Identity};
gate["original restoration before unchanged scalar reduction",
  (DownValues[restoreOnly] /. {restoreOnly -> restoredScalarComponent, Identity -> algebraicReduce}) ===
    coefficientProof["OriginalRestorationDefinitions"]];
label = First[labels]; gate["single real comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged own pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode, InputForm];
controlPair = First[pairs]; gate["own first pair diagonal", SameQ @@ controlPair];
controlPath = FileNameJoin[{cache, label <> "_" <> ToString[First[controlPair]] <> "_" <> ToString[Last[controlPair]] <> ".wl"}];
gate["pinned own complete diagonal pair", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  "16e98e475d6b9922b571ea98bc9b6c6a8d2fe473b2a12a221986e4cc443f1a9b"];
control = Get[controlPath];
gate["complete own accepted control binding", control["InputHash"] === inputHash &&
  AssociationQ[control["Checks"]] && And @@ Values[control["Checks"]]];
studyDirectory = FileNameJoin[{root, channel, "s05_zero_angular_result"}];
If[!DirectoryQ[studyDirectory], CreateDirectory[studyDirectory, CreateIntermediateDirectories -> True]];
coefficientDirectory = FileNameJoin[{studyDirectory, "isolated_cache"}];
If[!DirectoryQ[coefficientDirectory], CreateDirectory[coefficientDirectory]];
gate["isolated angular comparison cache empty", FileNames[All, coefficientDirectory] === {}];
tensor = bounded[buildPair[First[controlPair], Last[controlPair], None], "own control spin closure"];
monomials = Flatten[Outer[Times, outVariables, inVariables]];
representativeInputs = <||>;
comparisonRows = Table[
  Print["OWN_ANGULAR_PROJECTION ", photonIndices];
  projected = photonProject[tensor, photonSymbols[[First[photonIndices]]], photonSymbols[[Last[photonIndices]]]];
  {traceSeconds, traced} = AbsoluteTiming[bounded[Contract[DiracSimplify[projected, DiracTraceEvaluate -> True]], "own complete trace"]];
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[traced]]]]];
  acceptedValue = Extract[control["PhotonMatrix"], photonIndices];
  rawCoefficients = Flatten[First[compactSpinResponse[{value}, inVariables, outVariables]]];
  acceptedCoefficients = Flatten[First[compactSpinResponse[{acceptedValue}, inVariables, outVariables]]];
  gate["own complete raw spin reconstruction " <> ToString[photonIndices], Length[rawCoefficients] === Length[monomials] &&
    bounded[zero[value - Total[MapThread[Times, {rawCoefficients, monomials}]]], "own raw reconstruction"]];
  gate["own complete accepted spin reconstruction " <> ToString[photonIndices], Length[acceptedCoefficients] === Length[monomials] &&
    bounded[zero[acceptedValue - Total[MapThread[Times, {acceptedCoefficients, monomials}]]], "own accepted reconstruction"]];
  candidateCoefficients = acceptedCoefficients; componentRows = {};
  Do[
    restored = bounded[restoreOnly[rawCoefficients[[n]]], "own restored coefficient"];
    {seconds, zeroValue} = AbsoluteTiming[bounded[exactAngularZero[restored], "own angular-zero predicate"]];
    shortcut = !MissingQ[zeroValue];
    If[shortcut,
      gate["own accepted angular-zero coefficient " <> ToString[{photonIndices, n}],
        bounded[zero[acceptedCoefficients[[n]] - zeroValue], "own accepted zero comparison"]];
      gate["actual guarded coefficient matches angular zero", zeroCheckpointedScalarComponent[rawCoefficients[[n]]] === zeroValue];
      candidateCoefficients[[n]] = zeroValue];
    kind = If[shortcut, "Shortcut", "UnchangedReduction"];
    If[restored =!= 0 && !KeyExistsQ[representativeInputs, kind],
      AssociateTo[representativeInputs, kind -> <|"PhotonIndices" -> photonIndices, "Component" -> n,
        "RestoredEquation" -> restored, "Seconds" -> seconds, "InputBytes" -> ByteCount[restored]|>];
      Print["OWN_RESTORED_EQUATION ", kind, " ", InputForm[restored]]];
    evidence = <|"Component" -> n, "Shortcut" -> shortcut, "NontrivialShortcut" -> (shortcut && restored =!= 0),
      "InputHash" -> Hash[restored, "SHA256"], "InputBytes" -> ByteCount[restored], "Seconds" -> seconds|>;
    AppendTo[componentRows, evidence]; Print["OWN_ANGULAR_COEFFICIENT ", InputForm[evidence]],
    {n, Length[rawCoefficients]}];
  gate["entire own photon projection unchanged " <> ToString[photonIndices],
    bounded[zero[Total[MapThread[Times, {candidateCoefficients, monomials}]] - acceptedValue], "own entire projection comparison"]];
  <|"PhotonIndices" -> photonIndices, "TraceSeconds" -> traceSeconds,
    "Components" -> componentRows, "CompleteProjectionComparison" -> True|>,
  {photonIndices, {{1, 1}, {1, 2}}}];
gate["own nontrivial angular-zero shortcut exercised", KeyExistsQ[representativeInputs, "Shortcut"]];
gate["own nonzero reduction retained", KeyExistsQ[representativeInputs, "UnchangedReduction"]];
gate["angular zero never saved before angular averaging", FileNames[All, coefficientDirectory] === {}];
gate["all original scalar and angular equations unchanged", originalReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]}];
result = <|"Schema" -> "polarized-sidis-own-angular-zero-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[studyPath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ParentProofHash" -> FileHash[parentPath, "SHA256"], "ParentReceiptHash" -> FileHash[parentReceiptPath, "SHA256"],
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "ControlHash" -> FileHash[controlPath, "SHA256"], "ControlPair" -> controlPair,
  "ZeroAngularDefinitions" -> DownValues[exactAngularZero],
  "GuardedCheckpointDefinitions" -> DownValues[zeroCheckpointedScalarComponent],
  "OriginalCheckpointDefinitions" -> coefficientProof["CheckpointDefinitions"],
  "OriginalReductionDefinitions" -> originalReductionDefinitions,
  "RepresentativeInputs" -> representativeInputs, "Comparisons" -> comparisonRows,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultPath = FileNameJoin[{studyDirectory, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[Compress[result], InputForm] <> "]\n";
gate["bounded own angular proof output", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["exact own angular proof reload", Get[resultPath <> ".tmp"] === result];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{studyDirectory, "s05_checks.json"}], <|"checks" -> checks,
  "comparisons" -> comparisonRows, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_Hgg_zero_angular"]; Quit[0];

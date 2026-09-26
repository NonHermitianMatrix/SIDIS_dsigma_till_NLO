(* Reuse an executed, input-bound reconstruction through the existing checkpoint reader. *)
$HistoryLength = 0;
provenSource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_proven_reconstruction.wls"}];
provenBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[Environment["POLARIZED_SIDIS_CHANNEL"] =!= "Hqq" ||
  IntegerString[FileHash[provenBase, "SHA256"], 16, 64] =!=
    "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: pinned reconstruction reuse channel and calculation"]; Quit[1]];
provenText = Import[provenBase, "Text"];
provenBoundary = StringPosition[provenText, "\nDo[\n  amplitudes ="];
If[Length[provenBoundary] =!= 1 || !SyntaxQ[Import[provenSource, "Text"]],
  Print["FAIL: complete reconstruction reuse entry"]; Quit[1]];
provenPrefix = StringTake[provenText, First[First[provenBoundary]] - 1];
provenTail = StringDrop[provenText, First[First[provenBoundary]] - 1];
provenPackage = "Get[\"FeynCalc`\"]";
provenPackageReplacement = "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]";
If[StringCount[provenPrefix, provenPackage] =!= 1,
  Print["FAIL: unique native package interface"]; Quit[1]];
provenRunPrefix = StringReplace[provenPrefix, provenPackage -> provenPackageReplacement];
If[StringReplace[provenRunPrefix, provenPackageReplacement -> provenPackage] <> provenTail =!= provenText ||
  !SyntaxQ[provenRunPrefix] || !SyntaxQ[provenTail],
  Print["FAIL: unchanged complete reconstruction calculation"]; Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
ToExpression[provenRunPrefix, InputForm];
provenRelative = "Hqq/s05_structural_reconstruction_result/s05_result.wl";
provenPath = FileNameJoin[{root, provenRelative}];
provenReceiptPath = FileNameJoin[{root, "Hqq", "s05_structural_reconstruction_result", "s05_execution.json"}];
gate["pinned accepted structural reconstruction", IntegerString[FileHash[provenPath, "SHA256"], 16, 64] ===
  "b8d397e29a9b9210e2d4db1aabf361eb5ece0c338bbe0c93d0fd846fc8be44de" &&
  IntegerString[FileHash[provenReceiptPath, "SHA256"], 16, 64] ===
    "ec3a408d4ae8acf143e6d04e963f233c35d8e2c2f701c7c42653641de94e6fab"];
provenReceipt = Import[provenReceiptPath, "RawJSON"];
gate["accepted structural execution receipt", TrueQ[provenReceipt["passed"]]];
KeyValueMap[gate["structural artifact " <> #1, IntegerString[
  FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &, provenReceipt["result_sha256"]];
proven = Get[provenPath];
gate["complete own reconstruction proof", proven["Schema"] === "polarized-sidis-structural-reconstruction-comparison-v1" &&
  proven["Channel"] === channel && proven["Sector"] === "RealSame" && TrueQ[proven["Accepted"]] &&
  AssociationQ[proven["Checks"]] && Length[proven["Checks"]] > 0 && And @@ Values[proven["Checks"]] &&
  proven["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["same actual reconstruction source and inputs", proven["InputHash"] === inputHash &&
  proven["InputHashes"] === inputHashes && proven["ExtractionDefinitions"] === DownValues[compactSpinResponse] &&
  proven["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s05_check_structural_reconstruction.wls"}], "SHA256"] &&
  proven["EquationResultHash"] === FileHash[FileNameJoin[{root, "Hqq", "s05_reconstruction_equation_result", "s05_result.wl"}], "SHA256"] &&
  proven["EquationReceiptHash"] === FileHash[FileNameJoin[{root, "Hqq", "s05_reconstruction_equation_result", "s05_execution.json"}], "SHA256"]];
KeyValueMap[gate["unchanged reconstruction equation " <> #1,
  FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2] &, proven["EquationInputHashes"]];
provenKeys = {"DistinctSpinVariables", "SpinIndependentCoefficients", "ExactExpressionRestoration",
  "PolynomialSpinDependence", "ExactAbstractReconstruction", "ExactExistingResponse"};
gate["complete accepted reconstruction measurements", Lookup[proven["Measurements"], "Component"] === {8, 9} &&
  AllTrue[proven["Measurements"], TrueQ[#["Accepted"]] && Keys[#["Checks"]] === provenKeys && And @@ Values[#["Checks"]] &]];
gate["negative reconstruction control retained", proven["NegativeControl"]["Accepted"] === False &&
  Keys[proven["NegativeControl"]["Checks"]] === provenKeys &&
  proven["NegativeControl"]["Checks"]["ExactExistingResponse"] === False &&
  And @@ Values[KeyDrop[proven["NegativeControl"]["Checks"], "ExactExistingResponse"]]];
provenControl = Get[FileNameJoin[{cache, proven["Sector"] <> "_spin_reconstruction_" <>
  ToString[First[proven["Measurements"]]["Component"]] <> ".wl"}]];
gate["own accepted control preserved", provenControl["InputHash"] === inputHash &&
  provenControl["Binding"] === First[proven["Measurements"]]["Binding"] && TrueQ[provenControl["Accepted"]] &&
  And @@ Values[provenControl["Checks"]]];
provenMeasurement = Last[proven["Measurements"]];
provenCheckpointPath = FileNameJoin[{cache, proven["Sector"] <> "_spin_reconstruction_" <>
  ToString[provenMeasurement["Component"]] <> ".wl"}];
If[FileExistsQ[provenCheckpointPath],
  provenCheckpoint = Get[provenCheckpointPath];
  gate["existing reconstructed checkpoint matches", provenCheckpoint["InputHash"] === inputHash &&
    provenCheckpoint["Binding"] === provenMeasurement["Binding"] && TrueQ[provenCheckpoint["Accepted"]] &&
    AssociationQ[provenCheckpoint["Checks"]] && Length[provenCheckpoint["Checks"]] > 0 && And @@ Values[provenCheckpoint["Checks"]]],
  provenCheckpoint = <|"InputHash" -> inputHash, "Binding" -> provenMeasurement["Binding"],
    "Component" -> provenMeasurement["Component"], "Accepted" -> provenMeasurement["Accepted"],
    "ElapsedSeconds" -> provenMeasurement["Seconds"], "Checks" -> Join[provenMeasurement["Checks"], checks],
    "ReusedComparisonFile" -> provenPath, "ReconstructionProofHash" -> FileHash[provenPath, "SHA256"],
    "ReconstructionProofReceiptHash" -> FileHash[provenReceiptPath, "SHA256"]|>;
  put[provenCheckpoint, provenCheckpointPath]];
gate["exact reused reconstruction checkpoint reload", Get[provenCheckpointPath] === provenCheckpoint];
gate["original native checkpoint reader accepts proof", readProvenSpinCheck[provenCheckpointPath,
  provenMeasurement["Binding"], provenMeasurement["Component"]] === provenCheckpoint];
Print["REUSED_ACCEPTED_STRUCTURAL_RECONSTRUCTION ", proven["Sector"], " ", provenMeasurement["Component"]];
provenMetadataSite = "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
provenMetadataReplacement = provenMetadataSite <>
  "\nAssociateTo[result, {\"StructuralReconstructionProofHash\" -> FileHash[provenPath, \"SHA256\"], \"StructuralReconstructionDispatchHash\" -> FileHash[provenSource, \"SHA256\"]}];";
gate["unique reconstruction provenance interface", StringCount[provenTail, provenMetadataSite] === 1];
provenRunTail = StringReplace[provenTail, provenMetadataSite -> provenMetadataReplacement];
gate["unchanged remaining real calculation", StringReplace[provenRunTail,
  provenMetadataReplacement -> provenMetadataSite] === provenTail && SyntaxQ[provenRunTail]];
Block[{result = <||>}, ToExpression[provenMetadataReplacement, InputForm];
  gate["complete reconstruction provenance", result === <|
    "ScalarCheckpointValidationHash" -> FileHash[coefficientProofPath, "SHA256"],
    "StructuralReconstructionProofHash" -> FileHash[provenPath, "SHA256"],
    "StructuralReconstructionDispatchHash" -> FileHash[provenSource, "SHA256"]|>]];
ToExpression[provenRunTail, InputForm];

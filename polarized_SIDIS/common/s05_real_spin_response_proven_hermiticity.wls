(* Reuse executed Hermiticity checks only for the identical complete own matrix. *)
$HistoryLength = 0;
savedHermiticitySource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_proven_hermiticity.wls"}];
savedHermiticityBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_proven_reconstruction.wls"}];
If[Environment["POLARIZED_SIDIS_CHANNEL"] =!= "Hqq" ||
  IntegerString[FileHash[savedHermiticityBase, "SHA256"], 16, 64] =!=
    "e8dacabc2f79fff22b2bd2eece599d516c795b9075aacffb60138ec84d65c3bb", Quit[1]];
savedHermiticityText = Import[savedHermiticityBase, "Text"];
savedHermiticityEntry = "ToExpression[provenRunTail, InputForm];";
savedHermiticityPositions = StringPosition[savedHermiticityText, savedHermiticityEntry];
If[Length[savedHermiticityPositions] =!= 1 || !SyntaxQ[Import[savedHermiticitySource, "Text"]], Quit[1]];
savedHermiticityPrefix = StringTake[savedHermiticityText, First[First[savedHermiticityPositions]] - 1];
If[!SyntaxQ[savedHermiticityPrefix] ||
  StringTrim[StringDrop[savedHermiticityText, Last[First[savedHermiticityPositions]]]] =!= "", Quit[1]];
ToExpression[savedHermiticityPrefix, InputForm];
savedHermiticityPath = FileNameJoin[{root, channel, "s05_hermiticity_result", "s05_result.wl"}];
savedHermiticityReceiptPath = FileNameJoin[{root, channel, "s05_hermiticity_result", "s05_execution.json"}];
gate["pinned own Hermiticity result and execution",
  IntegerString[FileHash[savedHermiticityPath, "SHA256"], 16, 64] ===
    "b23311b9af3f205e742aa4395356ee0ac5467dd2d13bf8f5d3ba82141bc5fbdb" &&
  IntegerString[FileHash[savedHermiticityReceiptPath, "SHA256"], 16, 64] ===
    "aa26a3c2751e1afcf533968ab14b4f56774ac2db9c700ebf5442556379a58d57"];
savedHermiticityReceipt = Import[savedHermiticityReceiptPath, "RawJSON"];
gate["accepted own Hermiticity execution", TrueQ[savedHermiticityReceipt["passed"]]];
KeyValueMap[gate["own Hermiticity artifact " <> #1,
  IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &,
  savedHermiticityReceipt["result_sha256"]];
savedHermiticityProof = Get[savedHermiticityPath];
gate["complete own Hermiticity evidence", savedHermiticityProof["Schema"] ===
  "polarized-sidis-saved-hermiticity-comparison-v1" && savedHermiticityProof["Channel"] === channel &&
  savedHermiticityProof["InputHash"] === inputHash && savedHermiticityProof["PhysicalInputHashes"] === inputHashes &&
  savedHermiticityProof["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  AssociationQ[savedHermiticityProof["Checks"]] && Length[savedHermiticityProof["Checks"]] > 0 &&
  And @@ Values[savedHermiticityProof["Checks"]] &&
  savedHermiticityProof["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s05_check_factored_hermiticity.wls"}], "SHA256"] &&
  savedHermiticityProof["ProductionSourceHash"] === FileHash[provenBase, "SHA256"] &&
  savedHermiticityProof["ConjugationProofHash"] === FileHash[pairProofPath, "SHA256"] &&
  savedHermiticityProof["ConjugationDefinitions"] === DownValues[factoredRealConjugate]];
KeyValueMap[gate["unchanged own Hermiticity equation " <> #1,
  FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2] &, savedHermiticityProof["EquationInputHashes"]];
gate["accepted sector controls and complete matrices", AssociationQ[savedHermiticityProof["Sectors"]] &&
  Length[savedHermiticityProof["Sectors"]] > 0 &&
  AllTrue[Values[savedHermiticityProof["Sectors"]], TrueQ[#["Accepted"]] &&
    TrueQ[#["OriginalControlPassed"]] && TrueQ[#["NegativeControlRejected"]] &]];
DownValues[originalHermiticity] = savedHermiticityProof["OriginalDefinitions"];
savedHermiticityMatches[value_, sector_] := Module[{evidence},
  evidence = Lookup[savedHermiticityProof["Sectors"], sector, Missing["UnverifiedSector"]];
  AssociationQ[evidence] && TrueQ[evidence["Accepted"]] && Hash[value, "SHA256"] === evidence["MatrixHash"]];
reuseSavedHermiticity[value_, sector_] := If[savedHermiticityMatches[value, sector],
  Print["REUSED_OWN_COMPLETE_HERMITICITY ", sector]; True, originalHermiticity[value]];
savedHermiticityEquation = "zeroArray[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]]]";
savedHermiticityCall = "reuseSavedHermiticity[matrix, label]";
savedHermiticityMetadata = provenMetadataReplacement <>
  "\nAssociateTo[result, {\"HermiticityProofHash\" -> FileHash[savedHermiticityPath, \"SHA256\"], \"HermiticityDispatchHash\" -> FileHash[savedHermiticitySource, \"SHA256\"]}];";
gate["unique own Hermiticity production interfaces", StringCount[provenRunTail, savedHermiticityEquation] === 1 &&
  StringCount[provenRunTail, provenMetadataReplacement] === 1];
savedHermiticityTail = StringReplace[provenRunTail, {
  savedHermiticityEquation -> savedHermiticityCall, provenMetadataReplacement -> savedHermiticityMetadata}];
gate["unchanged remaining production calculation", SyntaxQ[savedHermiticityTail] &&
  StringReplace[savedHermiticityTail, {savedHermiticityCall -> savedHermiticityEquation,
    savedHermiticityMetadata -> provenMetadataReplacement}] === provenRunTail];
Block[{result = <||>}, ToExpression[savedHermiticityMetadata, InputForm];
  gate["complete own Hermiticity provenance", Length[result] === 5 &&
    result["HermiticityProofHash"] === FileHash[savedHermiticityPath, "SHA256"] &&
    result["HermiticityDispatchHash"] === FileHash[savedHermiticitySource, "SHA256"]]];
If[Environment["POLARIZED_SIDIS_HERMITICITY_VALIDATE_ONLY"] === "1",
  savedHermiticityDimensions = Dimensions[First[basis["PhotonDual"]]];
  Do[
    savedHermiticityMatrix = Table[
      Get[FileNameJoin[{cache, sector <> "_assembled_Photon_" <> ToString[a] <> "_" <> ToString[b] <> ".wl"}]]["Value"],
      {a, First[savedHermiticityDimensions]}, {b, Last[savedHermiticityDimensions]}];
    gate["complete saved matrix dispatch " <> sector,
      savedHermiticityMatches[savedHermiticityMatrix, sector] && reuseSavedHermiticity[savedHermiticityMatrix, sector]];
    gate["changed full matrix cannot reuse proof " <> sector,
      !savedHermiticityMatches[savedHermiticityMatrix + I IdentityMatrix[Length[savedHermiticityMatrix]], sector]];
    gate["unverified sector cannot reuse proof " <> sector,
      !savedHermiticityMatches[savedHermiticityMatrix, "UnverifiedSector"]];
    Clear[savedHermiticityMatrix]; ClearSystemCache[], {sector, Keys[savedHermiticityProof["Sectors"]]}];
  savedHermiticityOutput = FileNameJoin[{root, channel, "s05_hermiticity_interface_result"}];
  If[!DirectoryQ[savedHermiticityOutput], CreateDirectory[savedHermiticityOutput, CreateIntermediateDirectories -> True]];
  Export[FileNameJoin[{savedHermiticityOutput, "s05_checks.json"}], <|"checks" -> checks,
    "source_sha256" -> IntegerString[FileHash[savedHermiticitySource, "SHA256"], 16, 64],
    "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
  Print["PASS: s05_hermiticity_interface"]; Quit[0]];
ToExpression[savedHermiticityTail, InputForm];

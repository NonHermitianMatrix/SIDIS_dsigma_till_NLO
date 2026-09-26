(* Reproduce the exact failed endpoint valuation without altering production. *)
$HistoryLength = 0;
capturePath = FileNameJoin[{Directory[], "common", "s12_capture_recoil_valuation.wls"}];
captureBasePath = FileNameJoin[{Directory[], "common", "s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[captureBasePath, "SHA256"], 16, 64] =!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243", Quit[1]];
captureText = Import[captureBasePath, "Text"];
If[!SyntaxQ[Import[capturePath, "Text"]] || StringCount[captureText, "\nslots="] =!= 1, Quit[1]];
capturePrefix = First[StringSplit[captureText, "\nslots="]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
capturePrefix = StringReplace[capturePrefix, "Get[\"FeynCalc`\"]" -> "Null"];
If[!SyntaxQ[capturePrefix], Quit[1]];
ToExpression[capturePrefix, InputForm];
gate["failure capture owns current channel", channel === "Hqqbar"];
captureIndex = FromDigits[Environment["POLARIZED_SIDIS_RECOIL_COMPONENT"]];
gate["actual failed component index", IntegerQ[captureIndex] && 1 <= captureIndex <= Length[mapped["Components"]]];
captureOriginalDefinitions = DownValues[softRows];
captureStart = "\nsoftRows[coefficient_,piece_,sign_]";
captureEnd = "\nassemble[component_,index_]";
gate["unique original endpoint definition", StringCount[captureText, captureStart] === 1 && StringCount[captureText, captureEnd] === 1];
captureDefinition = captureStart <> First[StringSplit[Last[StringSplit[captureText, captureStart]], captureEnd]];
captureGate = "gate[\"spin coefficient has integer recoil valuation\",IntegerQ[valuation]];";
captureReturn = "Return[<|\"Coefficient\"->coefficient,\"Rational\"->rational,\"Valuation\"->valuation,\"IntegerPredicate\"->IntegerQ[valuation],\"Piece\"->piece,\"Branch\"->sign|>];";
gate["unique actual valuation gate", StringCount[captureDefinition, captureGate] === 1];
captureInstrumented = StringReplace[captureDefinition, captureGate -> captureReturn];
gate["original valuation equations unchanged", StringReplace[captureInstrumented, captureReturn -> captureGate] === captureDefinition];
gate["complete capture definition syntax", SyntaxQ[captureInstrumented]];
ToExpression[captureInstrumented, InputForm];
captureComponent = mapped["Components"][[captureIndex]];
captureCoefficients = Select[captureComponent["ReducedCoefficients"], # =!= 0 &] /. transverseRule;
gate["original measured coefficient substitution", FreeQ[captureCoefficients, First[transverseRule]]];
captureEvaluations = {};
captureFailure = Catch[
  Do[
    capturePieces = softPieces[captureMaster, captureSign];
    Do[
      {captureSeconds, captureValue} = AbsoluteTiming[softRows[captureCoefficients[captureMaster], capturePiece, captureSign]];
      gate["native valuation capture returned", AssociationQ[captureValue]];
      captureValue = Join[captureValue, <|"Master" -> captureMaster, "Seconds" -> captureSeconds|>];
      Print["RECOIL_VALUATION_CAPTURE ", captureIndex, " ", InputForm[captureMaster], " branch ", captureSign,
        " integer ", captureValue["IntegerPredicate"], " seconds ", captureSeconds,
        " returned_bytes ", ByteCount[captureValue["Valuation"]]];
      If[!TrueQ[captureValue["IntegerPredicate"]], Throw[captureValue, "CapturedValuation"]];
      AppendTo[captureEvaluations, KeyDrop[captureValue, {"Coefficient", "Rational", "Piece"}]],
      {capturePiece, capturePieces}],
    {captureSign, {1, -1}}, {captureMaster, Keys[captureCoefficients]}]; Missing["FailureNotReproduced"],
  "CapturedValuation"];
gate["actual noninteger valuation reproduced", AssociationQ[captureFailure] && !TrueQ[captureFailure["IntegerPredicate"]]];
captureDirectory = FileNameJoin[{root, channel, "s12_recoil_valuation_result"}];
If[!DirectoryQ[captureDirectory], CreateDirectory[captureDirectory, CreateIntermediateDirectories -> True]];
captureResult = <|"Schema" -> "polarized-sidis-recoil-valuation-capture-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[capturePath, "SHA256"], "ProductionSourceHash" -> sourceHash,
  "InputHashes" -> inputHashes, "InputHash" -> inputHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "ComponentIndex" -> captureIndex, "Task" -> KeyTake[captureComponent, {"Sector", "Kind", "Index"}],
  "OriginalDefinitions" -> captureOriginalDefinitions, "PriorEvaluations" -> captureEvaluations,
  "Failure" -> captureFailure, "Checks" -> checks, "ProductionCorrectionAccepted" -> False|>;
captureFile = FileNameJoin[{captureDirectory, "s12_result.wl"}];
captureSerialized = "Uncompress[" <> ToString[bounded[Compress[captureResult], "capture compression"], InputForm] <> "]\n";
gate["capture native file below bound", StringLength[captureSerialized] < 128*1024^2];
Export[captureFile <> ".tmp", captureSerialized, "Text"];
gate["capture exact native reload", bounded[Get[captureFile <> ".tmp"] === captureResult, "capture reload"]];
RenameFile[captureFile <> ".tmp", captureFile, OverwriteTarget -> True];
captureEquations = StringRiffle[KeyValueMap[ToString[#1] <> " = " <> ToString[#2, InputForm] &, captureFailure], "\n\n"] <> "\n";
gate["readable actual equations below bound", StringLength[captureEquations] < 128*1024^2];
Export[FileNameJoin[{captureDirectory, "s12_equations.txt"}], captureEquations, "Text"];
Export[FileNameJoin[{captureDirectory, "s12_checks.json"}], <|"checks" -> checks,
  "component" -> captureIndex, "job_id" -> Environment["JOB_ID"], "production_correction_accepted" -> False|>, "RawJSON"];
Print["PASS: s12_capture_recoil_valuation"]; Quit[0];

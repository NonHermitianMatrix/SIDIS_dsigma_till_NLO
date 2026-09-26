(* Complete original S12 using the independently accepted recoil components. *)
$HistoryLength = 0;
recoilCompletionPath = FileNameJoin[{Directory[], "common", "s12_complete_recoil_factorization.wls"}];
recoilBaseAdapterPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_rational.wls"}];
If[IntegerString[FileHash[recoilBaseAdapterPath, "SHA256"], 16, 64] =!=
  "25de9eb8201f602b83e3e6757adc8adf88c58e3583e01f5dfb1a9188ff836f6f", Quit[1]];
recoilBaseText = Import[recoilBaseAdapterPath, "Text"];
recoilBaseBoundary = "\nToExpression[rationalProgram, InputForm];";
If[StringCount[recoilBaseText, recoilBaseBoundary] =!= 1 || !SyntaxQ[Import[recoilCompletionPath, "Text"]], Quit[1]];
recoilBasePrefix = First[StringSplit[recoilBaseText, recoilBaseBoundary]];
If[StringCount[recoilBasePrefix, "Get[\"FeynCalc`\"]"] =!= 1, Quit[1]];
recoilBasePrefix = StringReplace[recoilBasePrefix, "Get[\"FeynCalc`\"]" -> "Null"];
If[!SyntaxQ[recoilBasePrefix], Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
ToExpression[recoilBasePrefix, InputForm];
recoilCompletionProofPath = FileNameJoin[{root, channel, "s12_recoil_factorization_result", "s12_result.wl"}];
recoilCompletionExpected = Environment["POLARIZED_SIDIS_RECOIL_PROOF_SHA256"];
gate["pinned accepted recoil comparison", StringQ[recoilCompletionExpected] &&
  IntegerString[FileHash[recoilCompletionProofPath, "SHA256"], 16, 64] === recoilCompletionExpected];
recoilCompletionReceipt = Import[FileNameJoin[{DirectoryName[recoilCompletionProofPath], "s12_execution.json"}], "RawJSON"];
gate["successful recoil comparison receipt", TrueQ[recoilCompletionReceipt["passed"]] &&
  recoilCompletionReceipt["result_sha256"][channel <> "/s12_recoil_factorization_result/s12_result.wl"] === recoilCompletionExpected];
recoilCompletionProof = Get[recoilCompletionProofPath];
recoilCompletionConfigPath = FileNameJoin[{root, "common", "s12_recoil_factorization_inputs.json"}];
recoilCompletionConfig = Import[recoilCompletionConfigPath, "RawJSON"];
KeyValueMap[gate["recoil completion input " <> #1,
  IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &, recoilCompletionConfig["files"]];
gate["accepted own complete recoil proof", channel === "Hqqbar" &&
  recoilCompletionProof["Schema"] === "polarized-sidis-recoil-factorization-comparison-v1" &&
  recoilCompletionProof["Channel"] === channel && And @@ Values[recoilCompletionProof["Checks"]] &&
  recoilCompletionProof["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s12_check_recoil_factorization.wls"}], "SHA256"] &&
  recoilCompletionProof["AdapterSourceHash"] === FileHash[recoilBaseAdapterPath, "SHA256"] &&
  recoilCompletionProof["ProductionSourceHash"] === sourceHash &&
  recoilCompletionProof["InputHash"] === inputHash && recoilCompletionProof["InputHashes"] === inputHashes &&
  recoilCompletionProof["ConfigurationHash"] === FileHash[recoilCompletionConfigPath, "SHA256"] &&
  recoilCompletionProof["CaptureHash"] === FileHash[FileNameJoin[{root, recoilCompletionConfig["capture"]}], "SHA256"] &&
  recoilCompletionProof["RationalProofHash"] === FileHash[rationalProofPath, "SHA256"] &&
  recoilCompletionProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["original recoil consumer definitions", recoilCompletionProof["OriginalDefinitions"] ===
  {DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint], DownValues[epsilonSeries],
   DownValues[laurentProduct], DownValues[assemble]}];
gate["complete own controls and target inventory", Sort[Keys[recoilCompletionProof["Components"]]] ===
  Sort[Join[FromDigits /@ Keys[recoilCompletionConfig["controls"]], recoilCompletionConfig["targets"]]]];
Do[
  recoilCompleted = recoilCompletionProof["Components"][recoilTarget];
  gate["accepted exact recoil target " <> ToString[recoilTarget],
    recoilCompletionProof["ComponentHashes"][recoilTarget] === Hash[mapped["Components"][[recoilTarget]], "SHA256"] &&
    AssociationQ[recoilCompleted] && TrueQ[recoilCompleted["Accepted"]] &&
    And @@ Values[recoilCompleted["Checks"]] && recoilCompleted["InputHash"] === inputHash &&
    KeyTake[recoilCompleted, {"Sector", "Kind", "Index"}] ===
      KeyTake[mapped["Components"][[recoilTarget]], {"Sector", "Kind", "Index"}]];
  recoilTargetFile = FileNameJoin[{cache, "component_" <> IntegerString[recoilTarget, 10, 4] <> ".wl"}];
  If[FileExistsQ[recoilTargetFile], gate["existing target is the exact accepted recoil component", Get[recoilTargetFile] === recoilCompleted],
    Put[recoilCompleted, recoilTargetFile <> ".tmp"];
    gate["exact native completed recoil component reload", Get[recoilTargetFile <> ".tmp"] === recoilCompleted];
    RenameFile[recoilTargetFile <> ".tmp", recoilTargetFile]];
  Print["REUSED_ACCEPTED_RECOIL_COMPONENT ", recoilTarget],
  {recoilTarget, recoilCompletionConfig["targets"]}];
gate["unique original completed real export", StringCount[rationalProgram, rationalOutput] === 1];
recoilCompletionProgram = StringReplace[rationalProgram, rationalOutput ->
  ("AssociateTo[result,{\"RecoilCompletionSourceHash\"->FileHash[recoilCompletionPath,\"SHA256\"],\"RecoilFactorizationComparisonHash\"->FileHash[recoilCompletionProofPath,\"SHA256\"]}];\n" <> rationalOutput)];
gate["complete original real export syntax", SyntaxQ[recoilCompletionProgram]];
ToExpression[recoilCompletionProgram, InputForm];

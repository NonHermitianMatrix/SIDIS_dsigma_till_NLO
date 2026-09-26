(* Original integration with the accepted own-channel rational master products. *)
$HistoryLength = 0;
rationalDispatchPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_rational.wls"}];
rationalBaselinePath = FileNameJoin[{Directory[], "common", "s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[rationalBaselinePath, "SHA256"], 16, 64] =!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243", Quit[1]];
rationalText = Import[rationalBaselinePath, "Text"];
If[!SyntaxQ[Import[rationalDispatchPath, "Text"]] || StringCount[rationalText, "\nslots="] =!= 1, Quit[1]];
rationalPrefix = First[StringSplit[rationalText, "\nslots="]];
rationalTail = "\nslots=" <> Last[StringSplit[rationalText, "\nslots="]];
rationalOldCall = "terms=KeyValueMap[Function[{m,c},epsilonSeries[(c/.D->4-2eps)regions[\"OrdinaryMasters\"][m],0,\n    \"ordinary cut coefficient\"]],coefficients];\n  ordinary=Total[terms];";
If[StringCount[rationalPrefix, rationalOldCall] =!= 1, Quit[1]];
rationalPrefix = StringReplace[rationalPrefix, rationalOldCall -> "ordinary=rationalOrdinary[component,index];"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
rationalPrefix = StringReplace[rationalPrefix, "Get[\"FeynCalc`\"]" -> "Null"];
If[!SyntaxQ[rationalPrefix] || !SyntaxQ[rationalTail], Quit[1]];
ToExpression[rationalPrefix, InputForm];
rationalProofPath = FileNameJoin[{root, channel, "s12_rational_series_result", "s12_result.wl"}];
rationalExpectedSHA = Environment["POLARIZED_SIDIS_RATIONAL_PROOF_SHA256"];
gate["pinned own rational master comparison", StringQ[rationalExpectedSHA] &&
  IntegerString[FileHash[rationalProofPath, "SHA256"], 16, 64] === rationalExpectedSHA];
rationalReceipt = Import[FileNameJoin[{DirectoryName[rationalProofPath], "s12_execution.json"}], "RawJSON"];
gate["successful own rational comparison receipt", TrueQ[rationalReceipt["passed"]] &&
  rationalReceipt["result_sha256"][channel <> "/s12_rational_series_result/s12_result.wl"] === rationalExpectedSHA];
rationalProof = Get[rationalProofPath];
rationalComparisonPath = FileNameJoin[{root, "common", "s12_check_rational_master_product.wls"}];
rationalConfigPath = FileNameJoin[{root, "common", "s12_rational_series_inputs.json"}];
rationalConfig = Import[rationalConfigPath, "RawJSON"];
gate["accepted complete rational comparison", channel === "Hqqbar" && rationalProof["Channel"] === channel &&
  rationalProof["Schema"] === "polarized-sidis-rational-master-product-comparison-v1" &&
  And @@ Values[rationalProof["Checks"]] && TrueQ[rationalProof["Checks"]["complete own accepted ordinary contribution reproduced"]] &&
  rationalProof["SourceHash"] === FileHash[rationalComparisonPath, "SHA256"] &&
  rationalProof["ProductionSourceHash"] === sourceHash &&
  rationalProof["ConfigurationHash"] === FileHash[rationalConfigPath, "SHA256"] &&
  rationalProof["ReferenceSourceHash"] === FileHash[FileNameJoin[{root, rationalConfig["reference"]}], "SHA256"] &&
  rationalProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["rational comparison exact production inputs", rationalProof["InputHash"] === inputHash && rationalProof["InputHashes"] === inputHashes];
gate["original endpoint and series equations unchanged", rationalProof["OriginalDefinitions"] ===
  {DownValues[epsilonSeries], DownValues[laurentProduct], DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint]}];
rationalComparisonText = Import[rationalComparisonPath, "Text"];
rationalPredicateStart = "\nzeroCoefficient[value_] := "; rationalPredicateEnd = "\ncheckedRationalSeries[";
gate["unique executed rational-zero predicate", StringCount[rationalComparisonText, rationalPredicateStart] === 1 &&
  StringCount[rationalComparisonText, rationalPredicateEnd] === 1];
rationalPredicate = rationalPredicateStart <> First[StringSplit[Last[StringSplit[rationalComparisonText, rationalPredicateStart]], rationalPredicateEnd]];
gate["complete rational-zero predicate syntax", SyntaxQ[rationalPredicate]];
ToExpression[rationalPredicate, InputForm];
DownValues[rationalSeries] = rationalProof["RationalDefinitions"];
DownValues[checkedRationalSeries] = rationalProof["CheckedRationalDefinitions"];
DownValues[ordinaryMasterProduct] = rationalProof["ProductDefinitions"];
DownValues[candidateOrdinary] = rationalProof["CandidateDefinitions"];
gate["exact accepted rational definitions installed",
  DownValues[rationalSeries] === rationalProof["RationalDefinitions"] &&
  DownValues[checkedRationalSeries] === rationalProof["CheckedRationalDefinitions"] &&
  DownValues[ordinaryMasterProduct] === rationalProof["ProductDefinitions"] &&
  DownValues[candidateOrdinary] === rationalProof["CandidateDefinitions"]];
rationalTargetIndex = rationalProof["TargetIndex"];
gate["tested ordinary component belongs to current map", IntegerQ[rationalTargetIndex] && 1 <= rationalTargetIndex <= Length[mapped["Components"]]];
rationalTargetHash = Hash[mapped["Components"][[rationalTargetIndex]], "SHA256"];
rationalTargetValue = rationalProof["CandidateValue"];
rationalOrdinary[component_, index_] := If[index === rationalTargetIndex,
  gate["reused ordinary contribution exact task", Hash[component, "SHA256"] === rationalTargetHash]; rationalTargetValue,
  candidateOrdinary[component, index]];
rationalDistribute = "DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,";
rationalOutput = "put[result,FileNameJoin[{resultDir,\"s12_result.wl\"}]];";
gate["unique original worker and output interfaces", StringCount[rationalTail, rationalDistribute] === 1 &&
  StringCount[rationalTail, rationalOutput] === 1];
rationalProgram = StringReplace[rationalTail, {
  rationalDistribute -> (rationalDistribute <> "rationalSeries,checkedRationalSeries,ordinaryMasterProduct,candidateOrdinary,zeroCoefficient,rationalOrdinary,rationalTargetIndex,rationalTargetHash,rationalTargetValue,"),
  rationalOutput -> ("AssociateTo[result,{\"DispatchSourceHash\"->FileHash[rationalDispatchPath,\"SHA256\"],\"RationalMasterComparisonHash\"->FileHash[rationalProofPath,\"SHA256\"]}];\n" <> rationalOutput)}];
gate["complete rational integration program syntax", SyntaxQ[rationalProgram]];
ToExpression[rationalProgram, InputForm];

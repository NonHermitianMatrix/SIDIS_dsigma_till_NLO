(* Reuse the executed standalone rational recurrence after an own-input comparison. *)
$HistoryLength = 0;
referenceSeriesPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_reference_series.wls"}];
referenceSeriesBase = FileNameJoin[{Directory[], "common", "s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[referenceSeriesBase, "SHA256"], 16, 64] =!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243", Quit[1]];
referenceSeriesText = Import[referenceSeriesBase, "Text"];
referenceSeriesBoundary = "\nslots=";
If[StringCount[referenceSeriesText, referenceSeriesBoundary] =!= 1 ||
  !SyntaxQ[Import[referenceSeriesPath, "Text"]], Print["FAIL: complete reference-series source syntax"]; Quit[1]];
referenceSeriesPrefix = First[StringSplit[referenceSeriesText, referenceSeriesBoundary]];
referenceSeriesTail = referenceSeriesBoundary <> Last[StringSplit[referenceSeriesText, referenceSeriesBoundary]];
referenceSeriesOldCall = "terms=KeyValueMap[Function[{m,c},epsilonSeries[(c/.D->4-2eps)regions[\"OrdinaryMasters\"][m],0,\n    \"ordinary cut coefficient\"]],coefficients];\n  ordinary=Total[terms];";
If[StringCount[referenceSeriesPrefix, referenceSeriesOldCall] =!= 1 ||
  StringCount[referenceSeriesPrefix, "Get[\"FeynCalc`\"]"] =!= 1, Quit[1]];
referenceSeriesPrefix = StringReplace[referenceSeriesPrefix, {
  referenceSeriesOldCall -> "ordinary=referenceSeriesOrdinary[component,index];",
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]"}];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
If[!SyntaxQ[referenceSeriesPrefix] || !SyntaxQ[referenceSeriesTail], Quit[1]];
ToExpression[referenceSeriesPrefix, InputForm];
referenceSeriesParentRelative = "Hqqbar/s12_rational_series_result/s12_result.wl";
referenceSeriesParentPath = FileNameJoin[{root, referenceSeriesParentRelative}];
referenceSeriesReceiptPath = FileNameJoin[{root, "Hqqbar", "s12_rational_series_result", "s12_execution.json"}];
gate["pinned executed reference recurrence and receipt",
  IntegerString[FileHash[referenceSeriesParentPath, "SHA256"], 16, 64] === "0724c147d2349bd44183ecb90936a56d1c7790f7ebd6dade58459cd0c1f8373a" &&
  IntegerString[FileHash[referenceSeriesReceiptPath, "SHA256"], 16, 64] === "406139892f2afcce55da23b0c374078dcc99e52d38166406fa06c7cdc2346874"];
referenceSeriesParent = Get[referenceSeriesParentPath];
referenceSeriesReceipt = Import[referenceSeriesReceiptPath, "RawJSON"];
referenceSeriesComparisonPath = FileNameJoin[{root, "common", "s12_check_rational_master_product.wls"}];
gate["accepted reference recurrence with unchanged equations", TrueQ[referenceSeriesReceipt["passed"]] &&
  referenceSeriesReceipt["result_sha256"][referenceSeriesParentRelative] === IntegerString[FileHash[referenceSeriesParentPath, "SHA256"], 16, 64] &&
  referenceSeriesParent["Schema"] === "polarized-sidis-rational-master-product-comparison-v1" &&
  AssociationQ[referenceSeriesParent["Checks"]] && Length[referenceSeriesParent["Checks"]] > 0 &&
  And @@ Values[referenceSeriesParent["Checks"]] &&
  referenceSeriesParent["SourceHash"] === FileHash[referenceSeriesComparisonPath, "SHA256"] &&
  referenceSeriesParent["ProductionSourceHash"] === sourceHash &&
  referenceSeriesParent["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  referenceSeriesParent["OriginalDefinitions"] === {DownValues[epsilonSeries], DownValues[laurentProduct],
    DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint]}];
referenceSeriesStandalonePath = FileNameJoin[{root, "common", "s12_result", "reference", "s12_standalone_rational_series.wls"}];
gate["same standalone reference implementation", referenceSeriesParent["ReferenceSourceHash"] === FileHash[referenceSeriesStandalonePath, "SHA256"]];
Do[gate["same accepted scalar master " <> stage,
  referenceSeriesParent["InputHashes"][library["Library"][stage]["File"]] === inputHashes[library["Library"][stage]["File"]]],
  {stage, {"s08", "s10", "s15"}}];
referenceSeriesComparisonText = Import[referenceSeriesComparisonPath, "Text"];
referenceSeriesPredicateStart = "\nzeroCoefficient[value_] := ";
referenceSeriesPredicateEnd = "\ncheckedRationalSeries[";
gate["unique executed recurrence predicate", StringCount[referenceSeriesComparisonText, referenceSeriesPredicateStart] === 1 &&
  StringCount[referenceSeriesComparisonText, referenceSeriesPredicateEnd] === 1];
referenceSeriesPredicate = referenceSeriesPredicateStart <>
  First[StringSplit[Last[StringSplit[referenceSeriesComparisonText, referenceSeriesPredicateStart]], referenceSeriesPredicateEnd]];
gate["native recurrence predicate syntax", SyntaxQ[referenceSeriesPredicate]];
ToExpression[referenceSeriesPredicate, InputForm];
DownValues[rationalSeries] = referenceSeriesParent["RationalDefinitions"];
DownValues[checkedRationalSeries] = referenceSeriesParent["CheckedRationalDefinitions"];
DownValues[ordinaryMasterProduct] = referenceSeriesParent["ProductDefinitions"];
DownValues[candidateOrdinary] = referenceSeriesParent["CandidateDefinitions"];
gate["exact executed recurrence definitions installed",
  DownValues[rationalSeries] === referenceSeriesParent["RationalDefinitions"] &&
  DownValues[checkedRationalSeries] === referenceSeriesParent["CheckedRationalDefinitions"] &&
  DownValues[ordinaryMasterProduct] === referenceSeriesParent["ProductDefinitions"] &&
  DownValues[candidateOrdinary] === referenceSeriesParent["CandidateDefinitions"]];
referenceSeriesControlCode = "referenceOriginalOrdinary[component_] := Module[{coefficients,terms,ordinary},\n" <>
  "coefficients=Select[component[\"ReducedCoefficients\"],#=!=0&]/.transverseRule;\n" <>
  referenceSeriesOldCall <> "\nordinary];";
gate["original ordinary coefficient calculation syntax", SyntaxQ[referenceSeriesControlCode]];
ToExpression[referenceSeriesControlCode, InputForm];
referenceSeriesIndices = Select[Range[Length[mapped["Components"]]],
  AnyTrue[Values[mapped["Components"][[#]]["ReducedCoefficients"]], # =!= 0 &] &];
gate["own nonzero ordinary control available", referenceSeriesIndices =!= {}];
referenceSeriesControlIndex = First[MinimalBy[referenceSeriesIndices,
  ByteCount[mapped["Components"][[#]]["ReducedCoefficients"]] &]];
referenceSeriesControl = mapped["Components"][[referenceSeriesControlIndex]];
referenceSeriesControlHash = Hash[referenceSeriesControl, "SHA256"];
referenceSeriesStudyDirectory = FileNameJoin[{root, channel, "s12_reference_series_result"}];
If[!DirectoryQ[referenceSeriesStudyDirectory], CreateDirectory[referenceSeriesStudyDirectory, CreateIntermediateDirectories -> True]];
referenceSeriesStudyPath = FileNameJoin[{referenceSeriesStudyDirectory, "s12_result.wl"}];
referenceSeriesStudy = If[FileExistsQ[referenceSeriesStudyPath], Get[referenceSeriesStudyPath], <||>];
referenceSeriesBinding = Hash[{FileHash[referenceSeriesPath, "SHA256"], inputHash,
  FileHash[referenceSeriesParentPath, "SHA256"], referenceSeriesControlHash, $Version, $FeynCalcVersion}, "SHA256"];
If[Lookup[referenceSeriesStudy, "Binding", None] === referenceSeriesBinding &&
  TrueQ[Lookup[referenceSeriesStudy, "Accepted", False]] && AssociationQ[Lookup[referenceSeriesStudy, "Checks", None]] &&
  Length[referenceSeriesStudy["Checks"]] > 0 && And @@ Values[referenceSeriesStudy["Checks"]],
  referenceSeriesControlValue = referenceSeriesStudy["CandidateValue"],
  Print["OWN_REFERENCE_SERIES_CONTROL ", channel, " component ", referenceSeriesControlIndex,
    " input_bytes ", ByteCount[referenceSeriesControl["ReducedCoefficients"]]];
  ClearSystemCache[];
  {referenceSeriesOriginalSeconds, referenceSeriesOriginalValue} = AbsoluteTiming[referenceOriginalOrdinary[referenceSeriesControl]];
  ClearSystemCache[];
  {referenceSeriesCandidateSeconds, referenceSeriesControlValue} = AbsoluteTiming[candidateOrdinary[referenceSeriesControl, referenceSeriesControlIndex]];
  gate["own complete original ordinary contribution reproduced", bounded[
    zeroCoefficient[Expand[referenceSeriesControlValue - referenceSeriesOriginalValue, eps]], "own ordinary reference comparison"]];
  referenceSeriesStudy = <|"Schema" -> "polarized-sidis-own-reference-series-v1", "Channel" -> channel,
    "Binding" -> referenceSeriesBinding, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "SourceHash" -> FileHash[referenceSeriesPath, "SHA256"], "ParentProofHash" -> FileHash[referenceSeriesParentPath, "SHA256"],
    "ControlIndex" -> referenceSeriesControlIndex, "ControlHash" -> referenceSeriesControlHash,
    "ControlCoefficients" -> referenceSeriesControl["ReducedCoefficients"], "CandidateValue" -> referenceSeriesControlValue,
    "OriginalValue" -> referenceSeriesOriginalValue, "OriginalSeconds" -> referenceSeriesOriginalSeconds,
    "CandidateSeconds" -> referenceSeriesCandidateSeconds, "NativeVersions" -> {$Version, $FeynCalcVersion},
    "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
  referenceSeriesSerialized = "Uncompress[" <> ToString[Compress[referenceSeriesStudy], InputForm] <> "]\n";
  gate["bounded own recurrence comparison output", StringLength[referenceSeriesSerialized] < 128*1024^2];
  Export[referenceSeriesStudyPath <> ".tmp", referenceSeriesSerialized, "Text"];
  gate["exact own recurrence comparison reload", Get[referenceSeriesStudyPath <> ".tmp"] === referenceSeriesStudy];
  RenameFile[referenceSeriesStudyPath <> ".tmp", referenceSeriesStudyPath, OverwriteTarget -> True]];
gate["own reference recurrence comparison accepted", TrueQ[referenceSeriesStudy["Accepted"]] &&
  TrueQ[referenceSeriesStudy["Checks"]["own complete original ordinary contribution reproduced"]]];
Print["OWN_REFERENCE_SERIES_ACCEPTED ", channel, " ", InputForm[KeyTake[referenceSeriesStudy,
  {"ControlIndex", "OriginalSeconds", "CandidateSeconds"}]]];
referenceSeriesOrdinary[component_, index_] := If[index === referenceSeriesControlIndex,
  gate["reused own ordinary coefficient exact task", Hash[component, "SHA256"] === referenceSeriesControlHash];
  referenceSeriesControlValue, candidateOrdinary[component, index]];
referenceSeriesDistribute = "DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,";
referenceSeriesOutput = "put[result,FileNameJoin[{resultDir,\"s12_result.wl\"}]];";
referenceSeriesChanges = {
  referenceSeriesDistribute -> (referenceSeriesDistribute <>
    "rationalSeries,checkedRationalSeries,ordinaryMasterProduct,candidateOrdinary,zeroCoefficient,referenceSeriesOrdinary,referenceSeriesControlIndex,referenceSeriesControlHash,referenceSeriesControlValue,"),
  referenceSeriesOutput -> ("AssociateTo[result,{\"ReferenceSeriesSourceHash\"->FileHash[referenceSeriesPath,\"SHA256\"],\"OwnReferenceSeriesComparisonHash\"->FileHash[referenceSeriesStudyPath,\"SHA256\"]}];\n" <> referenceSeriesOutput)};
gate["unique unchanged integration worker and output interfaces", And @@ (StringCount[referenceSeriesTail, First[#]] === 1 & /@ referenceSeriesChanges)];
referenceSeriesRunTail = StringReplace[referenceSeriesTail, referenceSeriesChanges];
gate["complete original integration tail retained", StringReplace[referenceSeriesRunTail, Reverse /@ referenceSeriesChanges] === referenceSeriesTail && SyntaxQ[referenceSeriesRunTail]];
ToExpression[referenceSeriesRunTail, InputForm];

(* Reuse the standalone reference's exact rational summation on the saved SIDIS input. *)
$HistoryLength = 0;
sumRoot = Directory[];
sumSource = FileNameJoin[{sumRoot, "common", "s08_rational_sum_check.wls"}];
sumConfigPath = FileNameJoin[{sumRoot, "common", "s08_rational_sum_inputs.json"}];
sumConfig = Import[sumConfigPath, "RawJSON"];
sumMapper = FileNameJoin[{sumRoot, "common", "s08_map_real_spin.wls"}];
If[IntegerString[FileHash[sumMapper, "SHA256"], 16, 64] =!=
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f", Quit[1]];
sumMapperText = Import[sumMapper, "Text"];
sumStop = First[First[StringPosition[sumMapperText, "\ncomponents = {}; targets = {};"]]];
ToExpression[StringTake[sumMapperText, sumStop - 1], InputForm];
gate["complete rational-sum comparison syntax", SyntaxQ[Import[sumSource, "Text"]]];
gate["known rational-sum input schema", sumConfig["schema"] === "polarized-sidis-rational-sum-comparison-inputs-v1"];
Do[gate["pinned rational-sum input " <> key, IntegerString[
  FileHash[FileNameJoin[{root, sumConfig[key]}], "SHA256"], 16, 64] === sumConfig[key <> "_sha256"]],
  {key, {"standalone_source", "raw_profile_source", "raw_map"}}];
sumReferencePath = FileNameJoin[{root, sumConfig["standalone_source"]}];
sumReferenceText = Import[sumReferencePath, "Text"];
sumBegin = First[First[StringPosition[sumReferenceText, "rationalReduce[expression_] := Module["]]];
sumEnd = First[First[StringPosition[sumReferenceText, "\nexactZero[expression_]"]]];
sumReferenceCode = StringTake[sumReferenceText, {sumBegin, sumEnd - 1}];
ToExpression[sumReferenceCode, InputForm];
sumRaw = Get[FileNameJoin[{root, sumConfig["raw_map"]}]];
sumExpectedInputHash = Hash[{FileHash[FileNameJoin[{root, sumConfig["raw_profile_source"]}], "SHA256"],
  inputHashes, FileHash[FileNameJoin[{root, "common", "s05_result", "reference",
    "s05_real_spin_response_before_parallel_spin_checks.wls"}], "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
gate["raw map exact producer and physical input binding", sumRaw["InputHash"] === sumExpectedInputHash];
gate["raw map has complete executed reconstruction", And @@ Values[sumRaw["MappingChecks"]] &&
  TrueQ[sumRaw["MappingChecks"]["complete cut-family map reconstructs the input tensor"]]];
gate["same actual component as saved raw map", channel === "Hqqprime" && KeyDrop[First[tasks], "Value"] === sumRaw["Task"]];
sumCoefficients = sumRaw["Coefficients"];
sumRuleMap = Association[reduction["Rules"]];
sumMissing = Complement[Keys[sumCoefficients], Keys[sumRuleMap]];
sumRuleMap = Join[sumRuleMap, AssociationThread[sumMissing, sumMissing]];
sumMasters = Union[Cases[Total[KeyValueMap[Times, sumCoefficients]] /. reduction["Rules"], _CutIntegral, Infinity]];
sumPackets = Table[sumTerms = KeyValueMap[#2 Coefficient[sumRuleMap[#1], master] &, sumCoefficients];
  <|"Master" -> master, "Terms" -> sumTerms, "Bytes" -> ByteCount[sumTerms],
    "NonzeroTerms" -> Count[sumTerms, Except[0]]|>, {master, sumMasters}];
sumControlCandidates = Select[sumPackets, #["NonzeroTerms"] > 1 &];
gate["nontrivial same-channel reference control exists", sumControlCandidates =!= {}];
sumControl = First[MinimalBy[sumControlCandidates, #["Bytes"] &]];
Print["REFERENCE_SUM_CONTROL ", InputForm[KeyDrop[sumControl, "Terms"]]];
{sumControlSeconds, sumControlValue} = AbsoluteTiming[
  referenceCoefficients[sumCoefficients, {sumControl["Master"]}, "same-channel original control"]];
sumValues = <||>; sumTimings = {};
Do[
  sumMaster = sumPacket["Master"];
  Print["REFERENCE_PAIRWISE_SUM ", InputForm[sumMaster], " input bytes ", sumPacket["Bytes"]];
  {sumSeconds, sumValue} = AbsoluteTiming[bounded[rationalReduce[Total[sumPacket["Terms"]]],
    {"standalone rational sum", sumMaster}]];
  gate["exact rational-sum reconstruction " <> ToString[sumMaster, InputForm],
    bounded[rationalReduce[Total[sumPacket["Terms"]] - sumValue], {"rational-sum reconstruction", sumMaster}] === 0];
  If[sumMaster === sumControl["Master"], gate["original same-channel master coefficient unchanged",
    bounded[zero[sumValue - sumControlValue[sumMaster]], "original master coefficient comparison"]]];
  AssociateTo[sumValues, sumMaster -> sumValue];
  AppendTo[sumTimings, <|"Master" -> sumMaster, "Seconds" -> sumSeconds,
    "InputBytes" -> sumPacket["Bytes"], "OutputBytes" -> ByteCount[sumValue], "NonzeroTerms" -> sumPacket["NonzeroTerms"]|>];
  Print["REFERENCE_PAIRWISE_SUM_ACCEPTED ", InputForm[sumMaster], " seconds ", sumSeconds];
  ClearSystemCache[], {sumPacket, sumPackets}];
gate["complete master coefficient inventory", Keys[sumValues] === sumMasters];
gate["fully scalar exact reduced coefficients", FreeQ[sumValues, _CutIntegral | _Real | $Failed | $Aborted | _Integrate | _SeriesData]];
sumResult = <|"Schema" -> "polarized-sidis-rational-sum-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[sumSource, "SHA256"], "MapperSourceHash" -> FileHash[sumMapper, "SHA256"],
  "StandaloneSourceHash" -> FileHash[sumReferencePath, "SHA256"], "InputHashes" -> inputHashes,
  "ConfigHash" -> FileHash[sumConfigPath, "SHA256"], "RawMapHash" -> FileHash[FileNameJoin[{root, sumConfig["raw_map"]}], "SHA256"],
  "Task" -> sumRaw["Task"], "ReferenceCode" -> sumReferenceCode, "ReferenceDefinitions" -> DownValues[rationalReduce],
  "ControlMaster" -> sumControl["Master"], "ControlOriginalSeconds" -> sumControlSeconds,
  "ReducedCoefficients" -> sumValues, "Timings" -> sumTimings, "Checks" -> checks,
  "FiniteNLOFHatsComputed" -> False|>;
sumDir = FileNameJoin[{root, channel, "s08_rational_result"}];
If[!DirectoryQ[sumDir], CreateDirectory[sumDir, CreateIntermediateDirectories -> True]];
put[sumResult, FileNameJoin[{sumDir, "s08_result.wl"}]];
Export[FileNameJoin[{sumDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_rational_sum_check"]; Quit[0];

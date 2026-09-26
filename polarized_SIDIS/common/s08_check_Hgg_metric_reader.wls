(* Restore the scalar field at an empty task index; preserve every response read. *)
$HistoryLength=0;
metricReaderSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_metric_reader.wls"}];
metricReaderBase=FileNameJoin[{Directory[],"common","s08_check_Hgg_additive_reconstruction.wls"}];
If[!SyntaxQ[ReadString[metricReaderSource]]||IntegerString[FileHash[metricReaderBase,"SHA256"],16,64]=!=
 "61071a42a311a84ebdbf30fdb33bd7b9e8d9c86c21a17172b4e1b5004ddfd221",Quit[1]];
metricReaderText=ReadString[metricReaderBase];metricReaderBoundary=StringPosition[metricReaderText,"\nadditiveTaskPositions="];
If[Length[metricReaderBoundary]=!=1,Quit[1]];
metricReaderPrefix=StringTake[metricReaderText,First[First[metricReaderBoundary]]-1];
If[!SyntaxQ[metricReaderPrefix],Quit[1]];ToExpression[metricReaderPrefix,InputForm];
metricFailure=readAccepted["Hgg/s08_metric_input_result/s08_result.wl"];
gate["exact saved scalar-reader failure",metricFailure["Schema"]==="polarized-sidis-metric-extraction-input-v1"&&
 metricFailure["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_export_Hgg_metric_input.wls"}],"SHA256"]&&
 metricFailure["InputHashes"]===record["InputHashes"]&&metricFailure["TargetInputHash"]===record["TargetInputHash"]&&
 metricFailure["NativeVersions"]===importedNativeVersions&&metricFailure["Equation"]==={}];
metricIndex=metricFailure["Component"];metricTask=hggTaskMetadata[[metricIndex]];
gate["same complete original metric task",metricTask===metricFailure["Task"]&&
 hggTaskSources[[metricIndex]]===metricFailure["TaskSource"]&&metricTask["Kind"]==="PhotonMetricD"];
metricOriginalReader=DownValues[hggTaskValue];metricOriginalInitializer=DownValues[hggInitializeTasks];
gate["same complete original reader",metricOriginalReader===productionTaskDefinitions&&
 metricOriginalReader===additiveReaderProof["OriginalTaskDefinitions"]];
metricOld=bounded[localSelectedTaskValue[metricIndex],"reproduce original metric return"];
gate["original empty-index failure reproduced",metricOld===metricFailure["Equation"]];
metricSpinPath=FileNameJoin[{root,"Hgg","s05_result","s05_result.wl"}];
metricExpected=hggMapRead[Get[metricSpinPath]["Sectors"][metricTask["Sector"]]["PhotonMetricD"],"original complete S05 scalar field"];
gate["original S05 metric is a scalar field",!ListQ[metricExpected]&&
 FreeQ[metricExpected,$Failed|$Aborted|_Missing|Indeterminate]];
gate["native empty Extract explains the complete failed return",Extract[metricExpected,{}]===metricOld];
metricOldReturn="Extract[hggCachedValue, row[\"Index\"]]";
metricNewReturn="If[row[\"Index\"] === {}, hggCachedValue, Extract[hggCachedValue, row[\"Index\"]]]";
gate["single original scalar-return interface",StringCount[inputFunctions,metricOldReturn]===1];
metricCorrectedText=StringReplace[inputFunctions,metricOldReturn->metricNewReturn];
gate["only the empty-index return changes",SyntaxQ[metricCorrectedText]&&
 StringReplace[metricCorrectedText,metricNewReturn->metricOldReturn]===inputFunctions];
ToExpression[metricCorrectedText,InputForm];
metricCandidateReader=DownValues[hggTaskValue]/.{Get->hggResponseNativeGet,bounded->hggMapRead};
DownValues[hggTaskValue]=metricCandidateReader;
gate["complete task initialization unchanged",DownValues[hggInitializeTasks]===metricOriginalInitializer];
{metricReadSeconds,metricActual}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[metricIndex],"corrected original metric return"]];
gate["complete corrected metric equals original S05 field",metricActual===metricExpected];
metricValueBytes=ByteCount[metricActual];
metricDirectory=FileNameJoin[{root,"Hgg","s08_metric_reader_result"}];
If[!DirectoryQ[metricDirectory],CreateDirectory[metricDirectory]];
Clear[metricExpected,metricActual,hggCachedKey,hggCachedValue];ClearSystemCache[];
{metricOwnSeconds,metricOwnValue}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[record["Component"]],"unchanged accepted own response"]];
gate["entire accepted own response equation unchanged",(metricOwnValue/.coordinateRules)===record["Expression"]];
Clear[metricOwnValue,hggCachedKey,hggCachedValue];ClearSystemCache[];
metricResult=<|"Schema"->"polarized-sidis-metric-reader-correction-v1","Channel"->channel,
 "SourceHash"->FileHash[metricReaderSource,"SHA256"],"BaseHash"->FileHash[metricReaderBase,"SHA256"],
 "ComponentSourceHash"->FileHash[componentSource,"SHA256"],"ReaderProofHash"->FileHash[
 FileNameJoin[{root,"Hgg","s08_selected_entry_read_result","s08_result.wl"}],"SHA256"],
 "FailureProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_metric_input_result","s08_result.wl"}],"SHA256"],
 "TaskInventoryHash"->Hash[{hggTaskMetadata,hggTaskSources},"SHA256"],"Component"->metricIndex,"Task"->metricTask,
 "OriginalReaderDefinitions"->metricOriginalReader,"CandidateReaderDefinitions"->metricCandidateReader,
 "OriginalReturn"->metricOldReturn,"CandidateReturn"->metricNewReturn,
 "OriginalEmptyIndexFailureReproduced"->True,"ActualMetricComparison"->True,"OwnAcceptedComparison"->True,
 "MetricValueBytes"->metricValueBytes,
 "MetricReadSeconds"->metricReadSeconds,"OwnReadSeconds"->metricOwnSeconds,
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->importedNativeVersions,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
saveNative[metricResult,FileNameJoin[{metricDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{metricDirectory,"s08_checks.json"}],<|"checks"->checks,"component"->metricIndex,
 "metric_read_seconds"->metricReadSeconds,"own_read_seconds"->metricOwnSeconds,
 "metric_value_bytes"->metricValueBytes,"peak_kernel_memory_bytes"->MaxMemoryUsed[],
 "job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_metric_reader"];Quit[0];

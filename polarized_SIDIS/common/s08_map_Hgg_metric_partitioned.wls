(* Correct the scalar empty-index return in the accepted Hgg partition pipeline. *)
$HistoryLength=0;
metricSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_metric_partitioned.wls"}];
metricBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_early_affine_partitioned.wls"}];
If[!SyntaxQ[ReadString[metricSource]]||IntegerString[FileHash[metricBase,"SHA256"],16,64]=!=
 "baad8ab821ddf00a3a2d92a7383046ae4ff5bd6afd62aa46433d81a493982b88",Quit[1]];
metricText=StringTrim[ReadString[metricBase]];metricTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[metricText,metricTerminal],Quit[1]];
metricPrefix=StringDrop[metricText,-StringLength[metricTerminal]];
If[!SyntaxQ[metricPrefix],Quit[1]];ToExpression[metricPrefix,InputForm];

metricInstall[]:=Module[{relative,path,receipt,producer,proof,original,candidate,selected},
 relative="Hgg/s08_metric_reader_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_Hgg_metric_reader.wls"}];
 gate["accepted complete scalar-reader comparison",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_Hgg_metric_reader.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];original=DownValues[selectedOriginalTaskValue]/.selectedOriginalTaskValue->hggTaskValue;
 selected=DownValues[hggTaskValue];
 gate["same complete scalar reader and production input",proof["Schema"]==="polarized-sidis-metric-reader-correction-v1"&&
  proof["Channel"]===channel&&proof["SourceHash"]===FileHash[producer,"SHA256"]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["ComponentSourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hgg_component_inputs.wls"}],"SHA256"]&&
  proof["ReaderProofHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_selected_entry_read_result","s08_result.wl"}],"SHA256"]&&
  proof["FailureProofHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_metric_input_result","s08_result.wl"}],"SHA256"]&&
  proof["TaskInventoryHash"]===Hash[{hggTaskMetadata,hggTaskSources},"SHA256"]&&
  proof["Task"]===hggTaskMetadata[[proof["Component"]]]&&original===proof["OriginalReaderDefinitions"]&&
  TrueQ[proof["ActualMetricComparison"]]&&TrueQ[proof["OwnAcceptedComparison"]]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]];
 candidate=proof["CandidateReaderDefinitions"]/.hggTaskValue->selectedOriginalTaskValue;
 gate["exact entire corrected fallback alias",(candidate/.selectedOriginalTaskValue->hggTaskValue)===proof["CandidateReaderDefinitions"]];
 DownValues[selectedOriginalTaskValue]=candidate;
 gate["selected response dispatch remains unchanged",DownValues[hggTaskValue]===selected&&
  DownValues[selectedOriginalTaskValue]===candidate];
 AssociateTo[hggPolynomialEvidence,"MetricReader"-><|"SourceHash"->FileHash[metricSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "ActualMetricComparison"->True,"OwnAcceptedComparison"->True,"Component"->proof["Component"],
  "MetricValueBytes"->proof["MetricValueBytes"]|>];
 Print["ACCEPTED_METRIC_READER_INSTALLED"];
 Clear[hggCachedKey,hggCachedValue];ClearSystemCache[]];

metricOriginalInstallDefinitions=DownValues[externalInstall];
DownValues[metricOriginalInstall]=metricOriginalInstallDefinitions/.externalInstall->metricOriginalInstall;
If[(DownValues[metricOriginalInstall]/.metricOriginalInstall->externalInstall)=!=metricOriginalInstallDefinitions,Quit[1]];
externalInstall[]:=(metricOriginalInstall[];metricInstall[]);
ToExpression[partitionRun,InputForm];

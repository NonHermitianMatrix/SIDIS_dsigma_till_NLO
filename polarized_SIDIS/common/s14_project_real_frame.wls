(* Preserve exactly the saved real-tensor fields read by finite assembly. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];
sourcePath=FileNameJoin[{root,"common","s14_project_real_frame.wls"}];checks=<||>;
gate[name_,value_] := If[TrueQ[value],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName,"login"]];
gate["isolated native runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
gate["complete projection syntax",SyntaxQ[Import[sourcePath,"Text"]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
producerRelative=channel<>"/s05_result/s05_result.wl";
producerPath=FileNameJoin[{root,producerRelative}];
receiptPath=FileNameJoin[{root,channel,"s05_result","s05_execution.json"}];
producerReceipt=Import[receiptPath,"RawJSON"];
gate["accepted real producer",TrueQ[producerReceipt["passed"]]];
KeyValueMap[gate["bound producer result "<>#1,
  IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,producerReceipt["result_sha256"]];
memoryBefore=MemoryInUse[];
{readSeconds,full}=AbsoluteTiming[Get[producerPath]];
gate["accepted own real tensor",AssociationQ[full] && full["Channel"]===channel &&
  AssociationQ[full["Checks"]] && And@@Values[full["Checks"]]];
retainedKeys={"Channel","Checks","Frame"};
gate["complete finite-assembly frame interface",And@@(KeyExistsQ[full,#]&/@retainedKeys) && AssociationQ[full["Frame"]]];
projection=KeyTake[full,retainedKeys];
gate["exact saved consumer fields",And@@(projection[#]===full[#]&/@retainedKeys)];
evidence=<|"SourceBytes"->ByteCount[full],"ProjectionBytes"->ByteCount[projection],
  "MemoryBefore"->memoryBefore,"MemoryLoaded"->MemoryInUse[],"ReadSeconds"->readSeconds|>;
Print["ACTUAL_REAL_FRAME ",InputForm[projection["Frame"]]];
Clear[full];ClearSystemCache[];
AssociateTo[evidence,{"MemoryAfterRelease"->MemoryInUse[],"NativePeakMemory"->MaxMemoryUsed[]}];
Print["REAL_FRAME_PROJECTION_EVIDENCE ",InputForm[evidence]];
result=<|"Schema"->"polarized-sidis-real-frame-projection-v1","Channel"->channel,
  "SourceHash"->FileHash[sourcePath,"SHA256"],"ProducerResultHash"->FileHash[producerPath,"SHA256"],
  "ProducerReceiptHash"->FileHash[receiptPath,"SHA256"],"ProducerResultHashes"->producerReceipt["result_sha256"],
  "RetainedKeys"->retainedKeys,"Projection"->projection,"Evidence"->evidence,
  "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True|>;
directory=FileNameJoin[{root,channel,"s14_frame_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
path=FileNameJoin[{directory,"s14_result.wl"}];
serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded frame record",StringLength[serialized]<128*1024^2];
Export[path<>".tmp",serialized,"Text"];
gate["exact native frame reload",Get[path<>".tmp"]===result];
RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s14_checks.json"}],<|"checks"->checks,"evidence"->evidence,
  "channel"->channel,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_project_real_frame"];Quit[0];

(* Combine each channel's preserved real tensor with the actual Kira rules. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
gate[name_, condition_] := If[!TrueQ[condition], Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S11Failure"],CloseKernels[];Quit[1]]];
put[value_,path_] := (Put[value,path<>".tmp"];RenameFile[path<>".tmp",path,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
valuation[value_,variable_] := If[value===0,Infinity,With[{rational=Together[value]},
  Exponent[Numerator[rational],variable,Min]-Exponent[Denominator[rational],variable,Min]]];
reduction=Get[FileNameJoin[{root,"s04_result.wl"}]];
sourceManifest=Get[FileNameJoin[{root,"s03_result.wl"}]];
gate["accepted complete real mapping",TrueQ[sourceManifest["Accepted"]]];
gate["accepted Kira real reduction",TrueQ[reduction["Accepted"]]];
masterList=reduction["Masters"]; ruleMap=Association[reduction["Rules"]];
sourceHash=FileHash[$InputFileName,"SHA256"];
reductionHash=FileHash[FileNameJoin[{root,"s04_result.wl"}],"SHA256"];
task[channel_,key_,coefficients_,mapHash_] := Catch[Module[
  {inputHash,cache,file,saved,result,values,epsOrders,softOrders,terms},
  inputHash=Hash[{sourceHash,reductionHash,mapHash,key},"SHA256"];
  cache=FileNameJoin[{root,channel,"s11_cache",IntegerString[inputHash,16]}];
  If[!DirectoryQ[cache],CreateDirectory[cache,CreateIntermediateDirectories->True]];
  file=FileNameJoin[{cache,"s11_result.wl"}];
  If[FileExistsQ[file],saved=Get[file];If[saved["InputHash"]===inputHash&&TrueQ[saved["Accepted"]],Return[saved]]];
  Print["REAL_COEFFICIENTS ",channel," ",key," kernel ",$KernelID];
  gate["every source target has a Kira rule",Complement[Keys[coefficients],Keys[ruleMap]]==={}];
  values=Association@Table[
    terms=KeyValueMap[#2 Coefficient[ruleMap[#1],master] &,coefficients];
    master -> bounded[Factor[Together[Total[terms]]],channel<>" "<>key<>" "<>ToString[master,InputForm]],
    {master,masterList}];
  gate["coefficients contain only scalar rational functions",FreeQ[values,
    _CutIntegral|_Real|$Failed|$Aborted|_Integrate|_SeriesData]];
  epsOrders=Map[valuation[# /. D->4-2 eps,eps] &,values];
  softOrders=Map[valuation[#,w] &,values];
  result=<|"Channel"->channel,"TensorKey"->key,"Coefficients"->values,
    "EpsilonValuations"->epsOrders,"SoftValuations"->softOrders,
    "InputHash"->inputHash,"SourceHash"->sourceHash,"MappingHash"->mapHash,
    "ReductionHash"->reductionHash,"Accepted"->True,"IntegralEvaluationPerformed"->False|>;
  put[result,file];ClearSystemCache[];Print["REAL_COEFFICIENTS_ACCEPTED ",channel," ",key];result],"S11Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0];DistributeDefinitions[gate,put,bounded,valuation,
  task,root,sourceHash,reductionHash,ruleMap,masterList]];
$DistributedContexts=None;channelResults=<||>;
Do[
  sourceFile=FileNameJoin[{root,channel,"s03_result.wl"}];mapping=Get[sourceFile];
  gate[channel<>" accepted scalar mapping",TrueQ[mapping["PairSumsAccepted"]] &&
    TrueQ[mapping["ReconstructionPassed"]] &&
    FileHash[sourceFile,"SHA256"]===sourceManifest["Channels"][channel]["SHA256"]];
  mapHash=FileHash[sourceFile,"SHA256"];
  tasks=KeyValueMap[{channel,#1,#2,mapHash} &,mapping["Coefficients"]];
  values=If[workers>0,ParallelMap[task@@# &,tasks,Method->"FinestGrained"],task@@# & /@tasks];
  gate[channel<>" all components reduced",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"Accepted"]];
  result=<|"Channel"->channel,"Components"->AssociationThread[Keys[mapping["Coefficients"]],values],
    "SourceHash"->sourceHash,"MappingHash"->mapHash,"ReductionHash"->reductionHash,
    "Accepted"->True,"IntegralEvaluationPerformed"->False|>;
  file=FileNameJoin[{root,channel,"s11_result.wl"}];put[result,file];
  AssociateTo[channelResults,channel-><|"File"->channel<>"/s11_result.wl","Hash"->FileHash[file,"SHA256"]|>];
  Clear[mapping,tasks,values,result];ClearSystemCache[],
  {channel,{"Hqq","Hqg","Hgq","Hgg","Hqqbar","Hqqprime"}}];
CloseKernels[];
put[<|"Channels"->channelResults,"SourceHash"->sourceHash,"ReductionHash"->reductionHash,
  "Masters"->masterList,"Accepted"->True|>,FileNameJoin[{root,"s11_result.wl"}]];
Print["S11_SUCCESS: all six channels expressed in the actual Kira cut masters."];
Quit[0];

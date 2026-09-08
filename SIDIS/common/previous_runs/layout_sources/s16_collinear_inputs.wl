(* Re-evaluate the unchanged real-only collinear convolutions and projectors. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[$InputFileName];
gate[name_,test_] := If[!TrueQ[test],Print["FAIL: ",name];
  If[$KernelID>0,Throw[$Failed,"S16Failure"],CloseKernels[];Quit[1]]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
sourceHash=FileHash[$InputFileName,"SHA256"];
channelTask[channel_] := Catch[Module[{reference,source,body,phaseDefinition,directory,
    originalHashes,packet,metadata},
  reference=FileNameJoin[{root,channel,"s01_reference_sources","s05_factorize.wls"}];
  source=Import[reference,"Text"];
  body=StringTake[source,{First[First[StringPosition[source,"physical="]]],
    First[First[StringPosition[source,"If[!FileExistsQ[\"s04_result/real.wl\"]"]]]-1}];
  gate[channel<>" selected block contains only the unchanged subtraction and projectors",
    !AnyTrue[{"TID[","PaVe","s04_result/","Fhats.wl"},StringContainsQ[body,#]&]];
  phaseDefinition=StringCases[source,RegularExpression["phaseCT=[^;]+;"]];
  gate[channel<>" unique source-defined subtraction prefactor",Length[phaseDefinition]===1];
  directory=FileNameJoin[{root,channel,"s16_result"}];
  If[!DirectoryQ[directory],CreateDirectory[directory]];
  originalHashes=Association@Table[file->FileHash[FileNameJoin[{root,channel,"s01_inputs","s02_result",file}],"SHA256"],
    {file,{"kinematics.wl","born_qg.wl","born_gq.wl"}}];
  body=StringReplace[body,{
    "Get[\"s02_result/"->"Get[\""<>FileNameJoin[{root,channel,"s01_inputs","s02_result"}]<>"/",
    "\"s05_result/"->"\""<>directory<>"/"}];
  Export[FileNameJoin[{directory,"s16_extracted_source.txt"}],body<>First[phaseDefinition],"Text"];
  Global`require[test_,message_] := gate[channel<>" "<>message,test];
  Print["COLLINEAR_INPUTS ",channel," kernel ",$KernelID];
  (* Each worker evaluates one channel source in its isolated kernel. *)
  MemoryConstrained[TimeConstrained[ToExpression[body<>First[phaseDefinition]],900,
    gate[channel<>" subtraction time limit",False]],2*1024^3,
    gate[channel<>" subtraction memory limit",False]];
  metadata=Get[FileNameJoin[{directory,"counterterms.wl"}]];
  packet=<|"Channel"->channel,"Convolutions"->metadata["convolutions"],
    "FactorizationMetadata"->metadata,"Projectors"->Get[FileNameJoin[{directory,"projectors.wl"}]],
    "PhaseCT"->Global`phaseCT,"Scheme"->"MSbar","SourceHash"->sourceHash,
    "PreservedSourceHash"->FileHash[reference,"SHA256"],"InputHashes"->originalHashes,
    "AcceptedSubtractionInputs"->True,"RealIntegrationPerformed"->False|>;
  gate[channel<>" evaluated finite source expressions",FreeQ[packet,$Failed|$Aborted|_Integrate|_ToExpression|_Missing]];
  put[packet,FileNameJoin[{root,channel,"s16_result.wl"}]];
  Print["COLLINEAR_INPUTS_ACCEPTED ",channel];packet],"S16Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]]];
workers=Length[Kernels[]];
If[workers>0,ParallelEvaluate[$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"]];
  DistributeDefinitions[gate,put,channelTask,root,sourceHash]];
$DistributedContexts=None;
channels={"Hgg","Hqqbar","Hqqprime"};
values=If[workers>0,ParallelMap[channelTask,channels,Method->"FinestGrained"],channelTask /@channels];
CloseKernels[];
gate["all requested subtraction inputs completed",FreeQ[values,$Failed|$Aborted]&&And@@Lookup[values,"AcceptedSubtractionInputs"]];
put[<|"Channels"->AssociationThread[channels,values],"SourceHash"->sourceHash,
  "AcceptedSubtractionInputs"->True|>,FileNameJoin[{root,"s16_result.wl"}]];
Print["S16_SUCCESS: real-only collinear subtraction and tensor projectors evaluated."];
Quit[0];

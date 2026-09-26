(* Merge completed Hgg groups with the unchanged accepted coefficient algorithm. *)
$HistoryLength=0;
root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];
source=FileNameJoin[{root,"misc","s07_merge_Hgg_coefficients.wls"}];
configPath=FileNameJoin[{root,"misc","s07_inputs.json"}];config=Import[configPath,"RawJSON"];
manifestPath=FileNameJoin[{root,"misc","s07_imported_groups.json"}];manifest=Import[manifestPath,"RawJSON"];
checks=<||>;gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True],Print["FAIL: ",name];Quit[1]];
SetAttributes[bounded,HoldFirst];targetTimeLimit=3600;targetMemoryLimit=3*1024^3;
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,targetTimeLimit,
 Print["FAIL: time bound ",InputForm[label]];Quit[2]],targetMemoryLimit,
 Print["FAIL: operation memory bound ",InputForm[label]];Quit[3]];
gate["authorized local runtime",Environment["POLARIZED_SIDIS_LOCAL_AUTHORIZED"]==="1"&&$VersionNumber===15.];
gate["complete source identity",SyntaxQ[ReadString[source]]&&
 IntegerString[FileHash[source,"SHA256"],16,64]===config["source_sha256"]];
KeyValueMap[Function[{relative,identity},gate["pinned input "<>relative,
 IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===identity]],config["input_sha256"]];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
nativeVersions={$Version,FeynCalc`$FeynCalcVersion};
readAccepted[relative_,receiptName_:"s08_execution.json"]:=Module[{path,receipt,value},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{DirectoryName[path],receiptName}],"RawJSON"];
 gate["accepted receipt "<>relative,TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 value=Get[path];gate["accepted checks "<>relative,AssociationQ[value["Checks"]]&&
  Length[value["Checks"]]>0&&And@@Values[value["Checks"]]];value];
ownInput=readAccepted["Hgg/s08_mapping_inputs_result/s08_component_0008.wl","s08_recovery_execution.json"];
own=readAccepted["Hgg/s08_external_factor_result/s08_result.wl"];
proof=readAccepted["Hqqbar/s08_pair_merge_result/s08_result.wl"];
gate["accepted coefficient producer identity",proof["SourceHash"]===
 FileHash[FileNameJoin[{root,"common","s08_check_pair_merge_linearity.wls"}],"SHA256"]];
importedVersions=ownInput["NativeVersions"];
gate["same imported native conventions",own["NativeVersions"]===importedVersions&&proof["NativeVersions"]===importedVersions&&
 Last[importedVersions]===FeynCalc`$FeynCalcVersion&&TrueQ[own["OwnAcceptedComparison"]]];
gate["same complete own scientific input",own["InputHashes"]===ownInput["InputHashes"]&&
 own["TargetInputHash"]===ownInput["TargetInputHash"]];
DownValues[merge]=proof["OriginalMergeDefinitions"];
gate["same accepted own merge definitions",DownValues[merge]===ownInput["OriginalMergeDefinitions"]];
sourceBlock[relative_,first_,last_]:=Module[{text,begin,end,block},
 text=ReadString[FileNameJoin[{root,relative}]];begin=StringPosition[text,first];end=StringPosition[text,last];
 gate["unique complete source block "<>relative,Length[begin]===1&&Length[end]===1];
 block=StringTake[text,{First[First[begin]],First[First[end]]-1}];
 gate["source block syntax "<>relative,SyntaxQ[block]];block];
ToExpression[sourceBlock["common/s08_result/reference/s08_map_real_spin_before_known_denominator.wls",
 "\nzero[value_]","\nconfigPath ="],InputForm];
ToExpression[sourceBlock["common/s08_check_pair_merge_linearity.wls",
 "\nmergeSave[value_, path_]","\ncertifyPairMerge[maps_, grouped_, coefficients_]"],InputForm];
mergeStudyHash=Hash[{FileHash[source,"SHA256"],FileHash[configPath,"SHA256"],nativeVersions},"SHA256"];
output=FileNameJoin[{root,"misc","s07_result"}];
mergeCache=FileNameJoin[{output,"coefficients",IntegerString[mergeStudyHash,16]}];
If[!DirectoryQ[mergeCache],CreateDirectory[mergeCache,CreateIntermediateDirectories->True]];
CloseKernels[];TimeConstrained[LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
 "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel","KernelCount"->2,"TimeConstraint"->30]],40,$Failed];
workers=Length[Kernels[]];gate["bounded local worker count",0<=workers<=2];
If[workers>0,
 ParallelEvaluate[$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"]];
 gate["local workers share machine and native versions",And@@(SameQ[#,{$MachineName,nativeVersions}]&/@
  ParallelEvaluate[{$MachineName,{$Version,FeynCalc`$FeynCalcVersion}}])];
 DistributeDefinitions[gate,bounded,targetTimeLimit,targetMemoryLimit,zero,merge,mergeSave,mergeKey,mergeStudyHash,mergeCache]];
$DistributedContexts=None;
readGroup[row_]:=Module[{path,value},path=FileNameJoin[{root,row["file"]}];
 gate["exact imported group "<>row["file"],FileByteCount[path]===row["bytes"]&&
  IntegerString[FileHash[path,"SHA256"],16,64]===row["sha256"]];
 value=bounded[Get[path],{"read group",row["file"]}];
 gate["accepted group arithmetic "<>row["file"],TrueQ[value["Accepted"]]&&AssociationQ[value["Coefficients"]]&&
  Length[value["Checks"]]>0&&And@@Values[value["Checks"]]];
 Print["LOCAL_MERGE_GROUP_READ ",FileNameTake[path]," memory ",MemoryInUse[]];value["Coefficients"]];
runMerge[rows_,label_]:=Module[{maps,grouped,keys,packets,results,seconds,result,inventory},
 maps=readGroup/@rows;grouped=Merge[maps,Identity];keys=Keys[grouped];
 packets=MapIndexed[Function[{key,position},<|"Component"->label,"Position"->First[position],
  "Key"->key,"Values"->grouped[key]|>],keys];Clear[maps,grouped];ClearSystemCache[];
 Print["LOCAL_MERGE_BEGIN ",label," keys ",Length[packets]," input_bytes ",ByteCount[packets]," memory ",MemoryInUse[]];
 {seconds,results}=AbsoluteTiming[If[workers>0,ParallelMap[mergeKey,packets,Method->"FinestGrained"],mergeKey/@packets]];
 gate["complete merge records "<>label,Length[results]===Length[packets]&&AllTrue[results,AssociationQ]&&
  And@@Lookup[results,"ReconstructionPassed"]&&And@@Flatten[Values[#["Checks"]]&/@results]&&
  Lookup[results,"Key"]===keys&&Lookup[results,"Binding"]===(Hash[{mergeStudyHash,#},"SHA256"]&/@packets)];
 result=Select[AssociationThread[keys,Lookup[results,"Value"]],#=!=0&];
 inventory=Map[Function[record,Module[{path},path=FileNameJoin[{mergeCache,"coefficient_"<>IntegerString[record["Binding"],16]<>".wl"}];
  Join[KeyDrop[record,"Value"],<|"File"->StringDrop[path,StringLength[root]+1],"SHA256"->IntegerString[FileHash[path,"SHA256"],16,64]|>]]],results];
 Print["LOCAL_MERGE_DONE ",label," seconds ",seconds," memory ",MemoryInUse[]];
 <|"Coefficients"->result,"Inventory"->inventory,"Seconds"->seconds,"InputFiles"->rows|>];
ownMerged=runMerge[manifest["own_groups"],"own_component_8"];
gate["entire accepted own Hgg map reproduced",Sort[Keys[ownMerged["Coefficients"]]]===Sort[Keys[own["OwnCoefficients"]]]&&
 And@@KeyValueMap[(#2===own["OwnCoefficients"][#1]||bounded[zero[#2-own["OwnCoefficients"][#1]],{"own coefficient",#1}])&,ownMerged["Coefficients"]]];
ownSeconds=ownMerged["Seconds"];Clear[ownMerged,ownInput,own,proof];ClearSystemCache[];
Print["LOCAL_COMPLETE_OWN_MERGE_ACCEPTED"];
metric=runMerge[manifest["groups"],"metric_component_98"];
result=<|"Schema"->"polarized-sidis-local-Hgg-coefficient-merge-v1","Channel"->"Hgg",
 "SourceHash"->FileHash[source,"SHA256"],"ConfigurationHash"->FileHash[configPath,"SHA256"],
 "ManifestHash"->FileHash[manifestPath,"SHA256"],"InputHash"->mergeStudyHash,
 "NativeVersions"->nativeVersions,"ImportedNativeVersions"->importedVersions,"WorkerCount"->workers,
 "OriginalMergeDefinitions"->DownValues[merge],"CoefficientDefinitions"->DownValues[mergeKey],
 "OwnAcceptedComparison"->True,"OwnSeconds"->ownSeconds,"Metric"->KeyDrop[metric,"Coefficients"],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
mergeSave[result,FileNameJoin[{output,"s07_result.wl"}]];
Export[FileNameJoin[{output,"s07_checks.json"}],<|"checks"->checks,"workers"->workers,"native_versions"->nativeVersions,
 "own_seconds"->ownSeconds,"metric_seconds"->metric["Seconds"],"coefficients"->Length[metric["Inventory"]],
 "finite_nlo_fhats_computed"->False|>,"RawJSON"];
CloseKernels[];Print["PASS: local Hgg coefficient merge"];Quit[0];

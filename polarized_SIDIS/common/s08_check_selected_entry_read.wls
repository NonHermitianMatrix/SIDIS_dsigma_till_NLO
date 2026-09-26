(* Compare the existing selected-entry reader with accepted Hoffman2 inputs. *)
$HistoryLength=0;root=Directory[];channel="Hgg";checks=<||>;
source=FileNameJoin[{root,"common","s08_check_selected_entry_read.wls"}];
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,1200,gate["operation time "<>ToString[label,InputForm],False]],4*1024^3,gate["operation memory "<>ToString[label,InputForm],False]];
SetAttributes[hggMapRead,HoldFirst];
hggMapRead[value_,label_]:=MemoryConstrained[TimeConstrained[value,1200,gate["read time "<>ToString[label,InputForm],False]],16*1024^3,gate["read memory "<>ToString[label,InputForm],False]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&StringStartsQ[$UserBaseDirectory,root<>"/"]];
gate["complete comparison syntax",SyntaxQ[ReadString[source]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;Get["FeynCalc`"];
readAccepted[relative_,receiptName_:"s08_execution.json"]:=Module[{path,receipt,value},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{DirectoryName[path],receiptName}],"RawJSON"];
 gate["accepted native identity "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 value=bounded[Get[path],{"accepted input",relative}];
 gate["accepted native checks "<>relative,AssociationQ[value]&&AssociationQ[value["Checks"]]&&Length[value["Checks"]]>0&&And@@Values[value["Checks"]]];value];
sourceBlock[path_,first_,last_]:=Module[{text,begin,end,value},
 text=ReadString[path];begin=StringPosition[text,first];end=StringPosition[text,last];
 gate["unique complete source block "<>FileNameTake[path],Length[begin]===1&&Length[end]===1];
 value=StringTake[text,{First[First[begin]],First[First[end]]-1}];
 gate["complete source block syntax "<>FileNameTake[path],SyntaxQ[value]];value];
record=readAccepted["Hgg/s08_mapping_inputs_result/s08_component_0008.wl","s08_recovery_execution.json"];
gate["own native mapping input",record["Schema"]==="polarized-sidis-native-mapping-input-v1"&&record["Channel"]===channel&&record["Component"]===8&&record["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
importedNativeVersions=record["NativeVersions"];localRoot=root;coordinateRules=record["CoordinateRules"];
KeyValueMap[Function[{relative,identity},gate["same scientific input "<>relative,FileHash[FileNameJoin[{root,relative}],"SHA256"]===identity]],record["InputHashes"]];
reader=readAccepted["Hgg/s08_response_read_result/s08_result.wl"];
gate["same accepted response reader",reader["NativeVersions"]===importedNativeVersions&&TrueQ[reader["OwnAcceptedComparison"]]&&
 reader["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_response_read.wls"}],"SHA256"]&&
 reader["StorageSourceHash"]===FileHash[FileNameJoin[{root,"common","s05_project_Hgg_piecewise_storage.wls"}],"SHA256"]];
DownValues[responseOnlyRead]=reader["ReaderDefinitions"];
hggResponseNativeGet[path_]:=responseOnlyRead[path,FileHash[path,"SHA256"]];
componentSource=FileNameJoin[{root,"common","s08_map_Hgg_component_inputs.wls"}];
gate["same original component loader",IntegerString[FileHash[componentSource,"SHA256"],16,64]==="f33a42480fefbc830a0b99bb0d9c957d490ee7dd1a7c278bd26aac221fabf7ce"];
inputFunctions=sourceBlock[componentSource,"\nhggInitializeTasks[]","\nhggBaselinePath ="];
ToExpression[inputFunctions,InputForm];originalTaskDefinitions=DownValues[hggTaskValue];
productionTaskDefinitions=originalTaskDefinitions/.{Get->hggResponseNativeGet,bounded->hggMapRead};
gate["exact existing production reader interface",Count[originalTaskDefinitions,_Get,Infinity]===1&&Count[originalTaskDefinitions,_bounded,Infinity]===1&&
 (productionTaskDefinitions/.{hggResponseNativeGet->Get,hggMapRead->bounded})===originalTaskDefinitions];
DownValues[hggTaskValue]=productionTaskDefinitions;
metadataPath=FileNameJoin[{root,"Hgg","s05_result","s05_metadata.wl"}];spin=Get[metadataPath];
gate["accepted metadata checks",spin["Channel"]===channel&&And@@Values[spin["Checks"]]];
hggInitializeTasks[];
gate["same own task identity",hggTaskMetadata[[record["Component"]]]===record["Task"]];
selectedSource=FileNameJoin[{root,"misc","s06_map_Hgg_local.wls"}];
gate["exact existing selected-entry implementation",IntegerString[FileHash[selectedSource,"SHA256"],16,64]==="5c5df1555ef2bd27cddf563f945ce9babeacfeb0b99ad7e6a6140801745fe8d7"];
selectedText=sourceBlock[selectedSource,"\nlocalSelectedTaskValue[index_]","\ngate[\"own native task identity\""];
ToExpression[selectedText,InputForm];
selectedDefinitions=DownValues[localSelectedTaskValue];
candidateTaskDefinitions=selectedDefinitions/.{hggTaskValue->selectedOriginalTaskValue,localSelectedTaskValue->hggTaskValue};
gate["only reader and fallback names change",(candidateTaskDefinitions/.{hggTaskValue->localSelectedTaskValue,selectedOriginalTaskValue->hggTaskValue})===selectedDefinitions];
ownRelative=reader["OwnFile"];ownPath=FileNameJoin[{root,ownRelative}];
ownManifestPath=FileNameJoin[{DirectoryName[ownPath],"s05_payload_manifest.json"}];
ownReceiptPath=FileNameJoin[{DirectoryName[ownPath],"s05_execution.json"}];
gate["exact accepted piecewise comparison fixture",FileHash[ownPath,"SHA256"]===reader["OwnHash"]&&
 FileHash[ownManifestPath,"SHA256"]===reader["OwnManifestHash"]&&FileHash[ownReceiptPath,"SHA256"]===reader["OwnReceiptHash"]&&
 StringContainsQ[ReadString[ownPath],"response=ArrayReshape[Table[readPiece[k]"]];
ownIndices=Select[Range[Length[hggTaskSources]],hggTaskSources[[#]]["Payload"]["File"]===ownRelative&&hggTaskSources[[#]]["Field"]==="Response"&];
gate["nonempty actual piecewise task inventory",Length[ownIndices]>0];ownIndex=First[ownIndices];
Print["SELECTED_OWN_READ_START ",ownIndex," ",InputForm[hggTaskMetadata[[ownIndex]]]];
{selectedSeconds,selectedValue}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[ownIndex],"selected own task"]];
selectedBytes=ByteCount[selectedValue];
Clear[hggCachedKey,hggCachedValue];ClearSystemCache[];
Print["CURRENT_COLD_OWN_READ_START ",ownIndex];
{originalSeconds,originalValue}=AbsoluteTiming[hggMapRead[hggTaskValue[ownIndex],"current cold own task"]];
gate["complete selected value equals current reader",originalValue===selectedValue];
originalRetainedBytes=ByteCount[hggCachedValue];
gate["executed own selected-read improvement",selectedSeconds<originalSeconds&&selectedBytes<originalRetainedBytes];
ownValueHash=Hash[selectedValue,"SHA256"];
Clear[originalValue,selectedValue,hggCachedValue,hggCachedKey,spin];ClearSystemCache[];
gate["comparison payload unchanged",FileHash[ownPath,"SHA256"]===reader["OwnHash"]&&FileHash[ownManifestPath,"SHA256"]===reader["OwnManifestHash"]];
result=<|"Schema"->"polarized-sidis-selected-entry-cluster-reader-v1","Channel"->channel,
 "SourceHash"->FileHash[source,"SHA256"],"SelectedSourceHash"->FileHash[selectedSource,"SHA256"],
 "ComponentSourceHash"->FileHash[componentSource,"SHA256"],"MetadataHash"->FileHash[metadataPath,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeInputHash"->FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}],"SHA256"],
 "ResponseReaderProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_response_read_result","s08_result.wl"}],"SHA256"],
 "TaskInventoryHash"->Hash[{hggTaskMetadata,hggTaskSources},"SHA256"],
 "OriginalTaskDefinitions"->productionTaskDefinitions,"CandidateTaskDefinitions"->candidateTaskDefinitions,
 "ResponseReaderDefinitions"->DownValues[responseOnlyRead],"ResponseDispatchDefinitions"->DownValues[hggResponseNativeGet],
 "OwnAcceptedComparison"->True,"SpeedupObserved"->True,
 "OwnComponent"->ownIndex,"OwnTask"->hggTaskMetadata[[ownIndex]],"OwnValueHash"->ownValueHash,
 "OwnFile"->ownRelative,"OwnHash"->reader["OwnHash"],"OwnManifestHash"->reader["OwnManifestHash"],"OwnReceiptHash"->reader["OwnReceiptHash"],
 "OriginalReadSeconds"->originalSeconds,"SelectedReadSeconds"->selectedSeconds,
 "OriginalRetainedBytes"->originalRetainedBytes,"SelectedRetainedBytes"->selectedBytes,
 "NativeVersions"->importedNativeVersions,"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
directory=FileNameJoin[{root,"Hgg","s08_selected_entry_read_result"}];If[!DirectoryQ[directory],CreateDirectory[directory]];
resultPath=FileNameJoin[{directory,"s08_result.wl"}];Put[result,resultPath<>".tmp"];
gate["exact selected-reader proof reload",Get[resultPath<>".tmp"]===result];RenameFile[resultPath<>".tmp",resultPath,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"original_seconds"->originalSeconds,
 "selected_seconds"->selectedSeconds,"original_retained_bytes"->originalRetainedBytes,"selected_retained_bytes"->selectedBytes,
 "own_component"->ownIndex,"own_file"->ownRelative,"peak_kernel_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_selected_entry_read"];Quit[0];

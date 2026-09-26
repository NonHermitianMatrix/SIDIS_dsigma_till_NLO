(* Preserve exact pending mapping equations for bounded native continuation. *)
$HistoryLength=0;
extractRoot=Directory[];extractChannel=Environment["POLARIZED_SIDIS_CHANNEL"];
extractSource=FileNameJoin[{extractRoot,"common","s08_extract_mapping_inputs.wls"}];
If[!MemberQ[{"Hqg","Hgg"},extractChannel]||!SyntaxQ[Import[extractSource,"Text"]],Quit[1]];
If[extractChannel==="Hqg",
 extractBase=FileNameJoin[{extractRoot,"common","s08_map_Hqg_grouped_packets.wls"}];
 If[IntegerString[FileHash[extractBase,"SHA256"],16,64]=!="0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838",Quit[1]];
 extractText=Import[extractBase,"Text"];extractBoundary=StringPosition[extractText,"\ngroupPacketOriginalTask="];
 If[Length[extractBoundary]=!=1,Quit[1]];
 extractPrefix=StringTake[extractText,First[First[extractBoundary]]-1];
 If[!SyntaxQ[extractPrefix],Quit[1]];ToExpression[extractPrefix,InputForm],
 extractBase=FileNameJoin[{extractRoot,"common","s08_map_Hgg_response_inputs.wls"}];
 If[IntegerString[FileHash[extractBase,"SHA256"],16,64]=!="80e0d148094ce46df049c434453aec556b9be7f5b51481e460ca488967e34016",Quit[1]];
 extractText=StringTrim[Import[extractBase,"Text"]];extractTerminal="ToExpression[hggResponseRun,InputForm];";
 If[!StringEndsQ[extractText,extractTerminal],Quit[1]];
 extractPrefix=StringDrop[extractText,-StringLength[extractTerminal]];
 If[!SyntaxQ[extractPrefix],Quit[1]];ToExpression[extractPrefix,InputForm];
 extractBoundary=StringPosition[hggResponseRun,"\nhggOwnSizes="];
 If[Length[extractBoundary]=!=1,Quit[1]];
 extractPrefix=StringTake[hggResponseRun,First[First[extractBoundary]]-1];
 If[!SyntaxQ[extractPrefix],Quit[1]];ToExpression[extractPrefix,InputForm]];
gate["extraction uses unchanged channel initialization",root===extractRoot&&channel===extractChannel];
extractFailurePath=FileNameJoin[{root,channel,"s08_targets_result","s08_execution.json"}];
extractFailure=Import[extractFailurePath,"RawJSON"];
gate["bound incomplete mapping execution",!TrueQ[extractFailure["passed"]]&&
 MemberQ[{"wall_limit","normal_exit"},extractFailure["reason"]]];
extractDirectory=FileNameJoin[{root,channel,"s08_mapping_inputs_result"}];
If[!DirectoryQ[extractDirectory],CreateDirectory[extractDirectory,CreateIntermediateDirectories->True]];
extractSave[value_,path_]:=Module[{serialized},
 serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
 gate["bounded native equation file",StringLength[serialized]<128*1024^2];
 Export[path<>".tmp",serialized,"Text"];
 gate["entire saved equation reloads exactly",Get[path<>".tmp"]===value];
 RenameFile[path<>".tmp",path,OverwriteTarget->True]];
extractCached=Select[Range[Length[tasks]],FileExistsQ[FileNameJoin[{targetCache,"component_"<>IntegerString[#,10,4]<>".wl"}]]&];
extractPending=Complement[Range[Length[tasks]],extractCached];
extractIndices=If[channel==="Hqg",Union[{groupPacketProof["ComponentIndex"]},extractPending],{8}];
gate["requested equations are actual native tasks",And@@(IntegerQ[#]&&1<=#<=Length[tasks]&/@extractIndices)];
extractFiles=<||>;
Do[Module[{value,record,path,readable,readablePath},
 Print["EXTRACT_ACTUAL_MAPPING_INPUT ",index,"/",Length[tasks]];
 value=tasks[[index]]["Value"]/.coordinateRules;
 record=<|"Schema"->"polarized-sidis-native-mapping-input-v1","Channel"->channel,
  "Component"->index,"Task"->KeyDrop[tasks[[index]],"Value"],"Expression"->value,
  "InputHash"->inputHash,"InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,
  "CoordinateRules"->coordinateRules,"Denominators"->denominators,"Directions"->directions,
  "Families"->families,"Geometry"->geometry,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
  "OriginalMappingDefinitions"->DownValues[mapExpression],"OriginalFamilyDefinitions"->DownValues[familyRows],
  "OriginalMergeDefinitions"->DownValues[merge],"GroupingDefinitions"->DownValues[groupDenominators],
  "GroupingCertificateDefinitions"->DownValues[certifyGrouping],
  "MergeCertificateDefinitions"->DownValues[certifyPairMerge],"GroupMergeDefinitions"->DownValues[certifyGroupMerge],
  "ReconstructionDefinitions"->DownValues[pairReconstruct],
  "SourceHash"->FileHash[extractSource,"SHA256"],"InitializationHash"->FileHash[extractBase,"SHA256"],
  "FailedReceiptHash"->FileHash[extractFailurePath,"SHA256"],"Checks"->checks,
  "FiniteNLOFHatsComputed"->False|>;
 path=FileNameJoin[{extractDirectory,"s08_component_"<>IntegerString[index,10,4]<>".wl"}];
 extractSave[record,path];AssociateTo[extractFiles,StringDrop[path,StringLength[root]+1]->IntegerString[FileHash[path,"SHA256"],16,64]];
 readable=ToString[value,InputForm,PageWidth->120];
 gate["bounded complete readable equation",StringLength[readable]<128*1024^2];
 readablePath=FileNameJoin[{extractDirectory,"s08_component_"<>IntegerString[index,10,4]<>"_equation.wl"}];
 Export[readablePath,readable,"Text"];
 AssociateTo[extractFiles,StringDrop[readablePath,StringLength[root]+1]->IntegerString[FileHash[readablePath,"SHA256"],16,64]];
 Print["SAVED_ACTUAL_MAPPING_INPUT ",index," native_bytes ",ByteCount[value]," file_bytes ",FileByteCount[path]]],
 {index,extractIndices}];
Export[FileNameJoin[{extractDirectory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,
 "files"->extractFiles,"pending_components"->extractPending,"cached_components"->extractCached,
 "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_extract_mapping_inputs"];Quit[0];

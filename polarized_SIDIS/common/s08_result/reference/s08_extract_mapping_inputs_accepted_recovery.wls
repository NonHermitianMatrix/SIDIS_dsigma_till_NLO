(* Preserve exact pending mapping equations for bounded native continuation. *)
$HistoryLength=0;
extractRoot=Directory[];extractChannel=Environment["POLARIZED_SIDIS_CHANNEL"];
extractSource=FileNameJoin[{extractRoot,"common","s08_extract_mapping_inputs.wls"}];
If[!MemberQ[{"Hqg","Hgg"},extractChannel]||!SyntaxQ[Import[extractSource,"Text"]],Quit[1]];
checks=<||>;
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
extractSameGeometry[left_Association,right_Association]:=Keys[left]===Keys[right]&&And@@KeyValueMap[extractSameGeometry[#2,right[#1]]&,left];
extractSameGeometry[left_List,right_List]:=Length[left]===Length[right]&&And@@MapThread[extractSameGeometry,{left,right}];
extractSameGeometry[left_Rule,right_Rule]:=First[left]===First[right]&&extractSameGeometry[Last[left],Last[right]];
extractSameGeometry[left_,right_]:=left===right||(FreeQ[{left,right},_String|_Association|_Rule|_List,{1,Infinity}]&&Factor[Together[left-right]]===0);
extractWrite[value_,path_]:=Module[{serialized,loaded,changed,normalized},
 serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
 gate["bounded native equation file",StringLength[serialized]<128*1024^2];
 Export[path<>".write.tmp",serialized,"Text"];loaded=Get[path<>".write.tmp"];
 gate["complete saved record keys",AssociationQ[loaded]&&Keys[loaded]===Keys[value]];
 changed=Select[Keys[value],value[#]=!=loaded[#]&];Print["RELOAD_CHANGED_FIELDS ",InputForm[changed]];
 gate["exact saved equation and nongeometry fields",KeyDrop[loaded,{"Families","Geometry"}]===KeyDrop[value,{"Families","Geometry"}]];
 gate["exact saved family geometry",extractSameGeometry[loaded["Families"],value["Families"]]&&extractSameGeometry[loaded["Geometry"],value["Geometry"]]];
 normalized="Uncompress["<>ToString[Compress[loaded],InputForm]<>"]\n";
 gate["bounded normalized native record",StringLength[normalized]<128*1024^2];
 Export[path<>".write.tmp",normalized,"Text"];
 gate["entire normalized record reloads exactly",Get[path<>".write.tmp"]===loaded];
 RenameFile[path<>".write.tmp",path,OverwriteTarget->True]];
extractReadable[value_,path_]:=Module[{readable},
 readable=ToString[value,InputForm,PageWidth->120];
 gate["bounded complete readable equation",StringLength[readable]<128*1024^2];
 Export[path,readable,"Text"]];
If[Environment["POLARIZED_SIDIS_RECOVER_INPUT"]==="1",
 gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&StringStartsQ[$UserBaseDirectory,extractRoot<>"/"]];
 PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
 extractDirectory=FileNameJoin[{extractRoot,extractChannel,"s08_mapping_inputs_result"}];
 extractIndex=If[extractChannel==="Hqg",4,8];
 extractPath=FileNameJoin[{extractDirectory,"s08_component_"<>IntegerString[extractIndex,10,4]<>".wl"}];
 extractWrapper=ToExpression[Import[extractPath<>".tmp","Text"],InputForm,HoldComplete];
 extractStrings=Cases[extractWrapper,_String,Infinity];gate["single saved native record",Length[extractStrings]===1];
 extractHeld=Uncompress[First[extractStrings],HoldComplete];extractRecord=Uncompress[First[extractStrings]];
 extractBefore=Association[Cases[extractHeld,HoldPattern[Rule[key_String,value_]]:>(key->HoldComplete[value]),{2}]];
 extractAfter=Association[KeyValueMap[Function[{key,value},key->HoldComplete[value]],extractRecord]];
 extractChanged=Select[Keys[extractBefore],extractBefore[#]=!=extractAfter[#]&];
 Print["RECOVERED_EVALUATION_FIELDS ",InputForm[extractChanged]];
 gate["saved equation is structurally unchanged",extractBefore["Expression"]===extractAfter["Expression"]];
 gate["saved native mapping contract",extractRecord["Schema"]==="polarized-sidis-native-mapping-input-v1"&&extractRecord["Channel"]===extractChannel&&extractRecord["Component"]===extractIndex&&And@@Values[extractRecord["Checks"]]&&extractRecord["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
 extractOrigin=FileNameJoin[{extractRoot,"common","s08_result","reference","s08_extract_mapping_inputs_before_stable_reload.wls"}];
 gate["exact failed exporter identity",IntegerString[FileHash[extractOrigin,"SHA256"],16,64]==="433001a7a8a3b334b23326fed3bfbb66810b5b9e4b8bc4376099a8521150e74d"&&extractRecord["SourceHash"]===FileHash[extractOrigin,"SHA256"]];
 extractFailurePath=FileNameJoin[{extractRoot,extractChannel,"s08_targets_result","s08_execution.json"}];
 gate["unchanged originating mapping receipt",extractRecord["FailedReceiptHash"]===FileHash[extractFailurePath,"SHA256"]];
 KeyValueMap[Function[{name,hash},gate["unchanged saved input "<>name,FileHash[FileNameJoin[{extractRoot,name}],"SHA256"]===hash]],extractRecord["InputHashes"]];
 extractGeometry=Get[FileNameJoin[{extractRoot,"common","s06_result","reference","s02_result.wl"}]]/.{Q2->Q^2,w->s23};
 gate["recovered exact family geometry",extractSameGeometry[extractGeometry,extractRecord["Geometry"]]&&extractSameGeometry[extractGeometry["Families"],extractRecord["Families"]]&&extractSameGeometry[extractGeometry["OnCutUncutPropagators"],extractRecord["Denominators"]]];
 extractWrite[extractRecord,extractPath];
 extractReadable[extractRecord["Expression"],StringDrop[extractPath,-3]<>"_equation.wl"];
 Export[FileNameJoin[{extractDirectory,"s08_recovery_checks.json"}],<|"channel"->extractChannel,"component"->extractIndex,"checks"->checks,"evaluation_changed_fields"->extractChanged,"original_file_sha256"->IntegerString[FileHash[extractPath<>".tmp","SHA256"],16,64],"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
 Print["PASS: s08_recover_mapping_inputs"];Quit[0]];
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
 extractWrite[record,path];AssociateTo[extractFiles,StringDrop[path,StringLength[root]+1]->IntegerString[FileHash[path,"SHA256"],16,64]];
 readablePath=FileNameJoin[{extractDirectory,"s08_component_"<>IntegerString[index,10,4]<>"_equation.wl"}];
 extractReadable[value,readablePath];
 AssociateTo[extractFiles,StringDrop[readablePath,StringLength[root]+1]->IntegerString[FileHash[readablePath,"SHA256"],16,64]];
 Print["SAVED_ACTUAL_MAPPING_INPUT ",index," native_bytes ",ByteCount[value]," file_bytes ",FileByteCount[path]]],
 {index,extractIndices}];
Export[FileNameJoin[{extractDirectory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,
 "files"->extractFiles,"pending_components"->extractPending,"cached_components"->extractCached,
 "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_extract_mapping_inputs"];Quit[0];

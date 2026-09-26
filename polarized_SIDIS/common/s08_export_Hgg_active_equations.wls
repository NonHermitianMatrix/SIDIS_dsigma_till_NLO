(* Read the two active Hgg target equations without changing their algebra. *)
$HistoryLength=0; root=Directory[]; checks=<||>;
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&StringStartsQ[$UserBaseDirectory,root<>"/"]];
source=FileNameJoin[{root,"common","s08_export_Hgg_active_equations.wls"}];
gate["complete source syntax",SyntaxQ[Import[source,"Text"]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
acceptedRead[relative_,receiptRelative_]:=Module[{path,receipt},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{root,receiptRelative}],"RawJSON"];
 gate["accepted input "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 Get[path]];
controlRelative="Hgg/s08_mapping_inputs_result/s08_component_0008.wl";
controlReceipt="Hgg/s08_mapping_inputs_result/s08_recovery_execution.json";
control=acceptedRead[controlRelative,controlReceipt];
gate["accepted own coordinate conventions",control["Channel"]==="Hgg"&&control["Schema"]==="polarized-sidis-native-mapping-input-v1"&&control["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[control["Checks"]]];
KeyValueMap[Function[{name,identity},gate["unchanged scientific input "<>name,FileHash[FileNameJoin[{root,name}],"SHA256"]===identity]],control["InputHashes"]];
relative="Hgg/s05_projected_components_result/Photon_1/s05_result.wl";
receiptRelative="Hgg/s05_projected_components_result/Photon_1/s05_execution.json";
packet=acceptedRead[relative,receiptRelative];
gate["accepted original photon response",packet["Channel"]==="Hgg"&&packet["Schema"]==="polarized-sidis-complete-photon-spin-component-v1"&&packet["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[packet["Checks"]]];
metadata=Get[FileNameJoin[{root,"Hgg","s05_result","s05_metadata.wl"}]];
gate["metadata belongs to accepted scalar input",metadata["Channel"]==="Hgg"&&And@@Values[metadata["Checks"]]];
selected=Take[metadata["MappingTaskMetadata"],2];sources=Take[metadata["MappingTaskSources"],2];
gate["two active tasks use the exact loaded response",And@@(#["Payload"]["File"]===relative&&#["Payload"]["Hash"]===FileHash[FileNameJoin[{root,relative}],"SHA256"]&&#["Field"]==="Response"&/@sources)];
directory=FileNameJoin[{root,"Hgg","s08_active_equations_result"}];If[!DirectoryQ[directory],CreateDirectory[directory]];
files=<||>;measurements={};
Do[Module[{value,text,path},
 value=Extract[packet["Response"],sources[[index]]["Index"]]/.control["CoordinateRules"];
 path=FileNameJoin[{directory,"s08_component_"<>IntegerString[index,10,4]<>"_equation.wl"}];
 text=ToString[value,InputForm,PageWidth->120];
 gate["bounded readable equation "<>ToString[index],StringLength[text]<128*1024^2];
 Export[path,text,"Text"];
 gate["entire saved equation reloads unchanged "<>ToString[index],Get[path]===value];
 AssociateTo[files,StringDrop[path,StringLength[root]+1]->IntegerString[FileHash[path,"SHA256"],16,64]];
 AppendTo[measurements,<|"Component"->index,"Task"->ToString[selected[[index]],InputForm],"ExpressionBytes"->ByteCount[value],"FileBytes"->FileByteCount[path]|>];
 Print["EXPORTED_ACTIVE_EQUATION ",InputForm[Last[measurements]]]],{index,Length[selected]}];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"files"->files,"measurements"->measurements,"input_sha256"->AssociationMap[IntegerString[FileHash[FileNameJoin[{root,#}],"SHA256"],16,64]&,{relative,receiptRelative,controlRelative,controlReceipt,"Hgg/s05_result/s05_metadata.wl"}],"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_export_Hgg_active_equations"];Quit[0];

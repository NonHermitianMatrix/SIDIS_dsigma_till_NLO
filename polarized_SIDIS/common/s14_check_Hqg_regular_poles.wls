(* Reuse the accepted common-root routine on Hqg's saved regular pole. *)
$HistoryLength=0;root=Directory[];checks=<||>;
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
SetAttributes[poleBounded,HoldFirst];
poleBounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,300,
 gate["time "<>ToString[label,InputForm],False]],3*1024^3,gate["memory "<>ToString[label,InputForm],False]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
source=FileNameJoin[{root,"common","s14_check_Hqg_regular_poles.wls"}];
settingsPath=FileNameJoin[{root,"common","s14_Hqg_regular_pole_inputs.json"}];
settings=Import[settingsPath,"RawJSON"];
gate["complete checker syntax",SyntaxQ[Import[source,"Text"]]];
KeyValueMap[gate["bound input "<>#1,
 IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,settings["files"]];
loadAccepted[relative_]:=Module[{path,receipt,value},
 path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s14_execution.json"}],"RawJSON"];
 gate["accepted proof "<>relative,TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 value=Get[path];gate["native proof contract "<>relative,TrueQ[value["Accepted"]]&&
  And@@Values[value["Checks"]]&&value["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];value];
rootProof=loadAccepted["Hqq/s14_pole_refinement_result/s14_result.wl"];
endpointProof=loadAccepted["Hqg/s14_pole_refinement_result/s14_result.wl"];
baseline=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];
gate["unchanged existing root algorithm",rootProof["Schema"]==="polarized-sidis-own-pole-refinement-v1"&&
 rootProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqq_pole_refinement.wls"}],"SHA256"]];
gate["unchanged own endpoint proof",endpointProof["Schema"]==="polarized-sidis-Hqg-pole-refinement-v1"&&
 endpointProof["Channel"]==="Hqg"&&endpointProof["BaselineSourceHash"]===FileHash[baseline,"SHA256"]&&
 endpointProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqg_pole_refinement.wls"}],"SHA256"]];
DownValues[ownPoleRefine]=rootProof["Definitions"];
DownValues[refineUVResidual]=rootProof["RefinementDefinitions"];
gate["exact accepted root definitions installed",{DownValues[ownPoleRefine],DownValues[refineUVResidual]}===
 Lookup[rootProof,{"Definitions","RefinementDefinitions"}]];
text=Import[baseline,"Text"];
begin=StringPosition[text,"reduce[value_,assumptions_"];end=StringPosition[text,"\nepsSeries[value_]"];
gate["unique original reduction interface",Length[begin]===1&&Length[end]===1];
definitions=StringTake[text,{First[First[begin]],First[First[end]]-1}];
gate["complete original reduction syntax",SyntaxQ[definitions]];ToExpression[definitions,InputForm];
gate["same original own zero predicate",DownValues[zero]===endpointProof["OriginalZeroDefinitions"]];
domainText=StringCases[text,RegularExpression["(?:softPhysical|physical)=[^;]+;"]];
gate["original physical domains available",Length[domainText]===2&&And@@(SyntaxQ/@domainText)];
Scan[ToExpression[#,InputForm]&,domainText];
conditions[label_]:=(If[Last[label]==="Regular",physical,softPhysical]/.t->label[[2]]omega-s)&&
 If[label[[2]]===0,True,omega>0];
gate["same original own endpoint domain",conditions[endpointProof["FailedLabel"]]===endpointProof["PhysicalConditions"]];
actualPath=FileNameJoin[{root,settings["actual"]}];controlPath=FileNameJoin[{root,settings["control"]}];
actual=Get[actualPath];control=Get[controlPath];
gate["same actual own scientific input",actual["Accepted"]===False&&
 actual["InputHash"]===endpointProof["InputHash"]&&actual["InputHash"]===control["InputHash"]&&
 Length[actual["InputParts"]]===3&&Last[actual["Label"]]==="Regular"&&Length[actual["PoleResiduals"]]>0];
gate["complete own accepted control",TrueQ[control["Accepted"]]&&KeyExistsQ[control,"Finite"]&&
 control["Label"]===endpointProof["ControlLabel"]&&FileHash[controlPath,"SHA256"]===endpointProof["ControlHash"]];
actualConditions=conditions[actual["Label"]];controlConditions=conditions[control["Label"]];
ownPoleRootEvidence=<||>;
controlRows=KeyValueMap[Function[{power,value},Module[{timed},
 gate["original own control accepted "<>ToString[power],poleBounded[zero[value,controlConditions],"original control"]];
 timed=AbsoluteTiming[poleBounded[ownPoleRefine[value,controlConditions],"common-root control"]];
 gate["complete own control unchanged "<>ToString[power],Last[timed]===0];
 <|"Power"->power,"Residual"->Last[timed],"Seconds"->First[timed]|>]],control["PoleResiduals"]];
combined=poleBounded[Expand[Total[actual["InputParts"]],eps],"original Laurent input sum"];
rows=KeyValueMap[Function[{power,value},Module[{savedTiming,inputTiming,original},
 Print["HQG_REGULAR_POLE_BEGIN ",power," bytes ",ByteCount[value]];
 savedTiming=AbsoluteTiming[poleBounded[ownPoleRefine[value,actualConditions],"actual saved regular pole"]];
 gate["actual saved regular pole vanishes "<>ToString[power],Last[savedTiming]===0];
 original=poleBounded[reduce[Coefficient[combined,eps,power],actualConditions],"original production reduction"];
 gate["original input sum reproduces saved residual "<>ToString[power],original===value];
 inputTiming=AbsoluteTiming[poleBounded[ownPoleRefine[Coefficient[combined,eps,power],actualConditions],"original regular input sum"]];
 gate["original regular input-sum pole vanishes "<>ToString[power],Last[inputTiming]===0];
 Print["HQG_REGULAR_POLE_ACCEPTED ",power," saved_seconds ",First[savedTiming]," input_seconds ",First[inputTiming]];
 <|"Power"->power,"Residual"->Last[savedTiming],"InputSumResidual"->Last[inputTiming],
  "Seconds"->First[savedTiming],"InputSumSeconds"->First[inputTiming]|>]],actual["PoleResiduals"]];
gate["complete own and actual pole inventory accepted",Length[rows]===Length[actual["PoleResiduals"]]&&
 AllTrue[rows,#["Residual"]===0&&#["InputSumResidual"]===0&]&&AllTrue[controlRows,#["Residual"]===0&]];
result=<|"Schema"->"polarized-sidis-Hqg-regular-pole-refinement-v1","Channel"->"Hqg","Accepted"->True,
 "InputHash"->actual["InputHash"],"ActualLabel"->actual["Label"],"ControlLabel"->control["Label"],
 "ActualConditions"->actualConditions,"ControlConditions"->controlConditions,"ActualRows"->rows,"ControlRows"->controlRows,
 "ActualCheckpointHash"->FileHash[actualPath,"SHA256"],"ControlCheckpointHash"->FileHash[controlPath,"SHA256"],
 "ControlFiniteHash"->Hash[control["Finite"],"SHA256"],"Definitions"->DownValues[ownPoleRefine],
 "RefinementDefinitions"->DownValues[refineUVResidual],"RootEvidence"->ownPoleRootEvidence,
 "OriginalZeroDefinitions"->DownValues[zero],"OriginalFinitePartDefinitions"->endpointProof["OriginalFinitePartDefinitions"],
 "ExistingProofHash"->FileHash[FileNameJoin[{root,"Hqq","s14_pole_refinement_result","s14_result.wl"}],"SHA256"],
 "EndpointProofHash"->FileHash[FileNameJoin[{root,"Hqg","s14_pole_refinement_result","s14_result.wl"}],"SHA256"],
 "SourceHash"->FileHash[source,"SHA256"],"ConfigHash"->FileHash[settingsPath,"SHA256"],
 "BaselineSourceHash"->FileHash[baseline,"SHA256"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,"Hqg","s14_regular_pole_result"}];
If[!DirectoryQ[out],CreateDirectory[out,CreateIntermediateDirectories->True]];
path=FileNameJoin[{out,"s14_result.wl"}];
serialized="Uncompress["<>ToString[poleBounded[Compress[result],"proof serialization"],InputForm]<>"]\n";
gate["bounded native proof",StringLength[serialized]<128*1024^2];
Export[path<>".tmp",serialized,"Text"];
gate["exact native proof reload",Get[path<>".tmp"]===result];
RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{out,"s14_checks.json"}],<|"checks"->checks,"actual_rows"->rows,"control_rows"->controlRows,
 "accepted"->True,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_check_Hqg_regular_poles"];Quit[0];

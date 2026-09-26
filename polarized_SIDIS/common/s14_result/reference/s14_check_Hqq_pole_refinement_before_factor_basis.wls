(* Compare an existing exact residual routine against this channel's saved equations. *)
$HistoryLength=0;
ownPoleSource=FileNameJoin[{Directory[],"common","s14_check_Hqq_pole_refinement.wls"}];
ownPoleParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
If[IntegerString[FileHash[ownPoleParent,"SHA256"],16,64]=!=
 "0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b",Quit[1]];
ownPoleText=StringTrim[Import[ownPoleParent,"Text"]];
ownPoleTerminal="ToExpression[cachedPartsRun,InputForm];";
If[!StringEndsQ[ownPoleText,ownPoleTerminal]||!SyntaxQ[Import[ownPoleSource,"Text"]],Quit[1]];
ownPolePrefix=StringDrop[ownPoleText,-StringLength[ownPoleTerminal]];
If[!SyntaxQ[ownPolePrefix],Quit[1]];ToExpression[ownPolePrefix,InputForm];

SetAttributes[ownPoleBounded,HoldFirst];
ownPoleBounded[value_,label_] := MemoryConstrained[TimeConstrained[value,300,
 gate["own pole time bound "<>ToString[label,InputForm],False]],2*1024^3,
 gate["own pole memory bound "<>ToString[label,InputForm],False]];
ownPoleRefine[value_,conditions_] := Module[{roots,rules,normalized,identity,answer,rows={},started=AbsoluteTime[]},
 roots=DeleteDuplicates[Cases[value,power:Power[_,_Rational]:>power,{0,Infinity}]];
 rules=Map[Function[power,
   normalized=Refine[PowerExpand[Factor[power[[1]]]^power[[2]],Assumptions->conditions],conditions];
   identity=If[normalized===power,0,FullSimplify[power-normalized,conditions,TimeConstraint->20]];
   gate["exact own physical root identity",identity===0];
   AppendTo[rows,<|"Original"->power,"Normalized"->normalized,"Residual"->identity|>];
   power->normalized],roots];
 Print["OWN_POLE_ROOT_EQUATIONS ",InputForm[rows]];
 normalized=value/.rules;
 answer=Factor[Together[normalized]];
 Print["OWN_POLE_COLLECTED_EQUATION ",InputForm[answer]];
 If[answer=!=0,answer=Block[{physical=conditions},refineUVResidual[answer]]];
 AssociateTo[ownPoleRootEvidence,Hash[{value,conditions},"SHA256"]->
   <|"RootRows"->rows,"Seconds"->AbsoluteTime[]-started,"Result"->answer|>];answer];
ownPoleConditions[label_] := (If[Last[label]==="Regular",physical,softPhysical]/.t->label[[2]]omega-s)&&
 If[label[[2]]===0,True,omega>0]&&flavorDomain;

ownPoleCompare[] := Module[{settingsPath,settings,actualPath,controlPath,actual,control,uvPath,uv,receipt,
 controlConditions,actualConditions,controlRows,actualRows,combined,timed,sumTimed,original,priorSeconds,
 result,directory,path,serialized},
 settingsPath=FileNameJoin[{root,"common","s14_Hqq_pole_inputs.json"}];
 settings=Import[settingsPath,"RawJSON"];
 gate["own pole channel",channel===settings["channel"]];
 KeyValueMap[gate["own bound pole input "<>#1,
   IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,settings["files"]];
 actualPath=FileNameJoin[{root,settings["actual"]}];controlPath=FileNameJoin[{root,settings["control"]}];
 actual=Get[actualPath];control=Get[controlPath];
 gate["same actual scientific input",actual["InputHash"]===inputHash&&
   !TrueQ[actual["Accepted"]]&&KeyExistsQ[actual,"InputParts"]&&Length[actual["PoleResiduals"]]>0];
 gate["same accepted own control input",control["InputHash"]===inputHash&&
   TrueQ[control["Accepted"]]&&KeyExistsQ[control,"Finite"]&&Length[control["PoleResiduals"]]>0];
 uvPath=FileNameJoin[{root,"Hqg","s13_branch_result","s13_result.wl"}];uv=Get[uvPath];
 receipt=Import[FileNameJoin[{DirectoryName[uvPath],"s13_execution.json"}],"RawJSON"];
 gate["accepted exact existing residual routine",TrueQ[receipt["passed"]]&&TrueQ[uv["Accepted"]]&&
   And@@Values[uv["Checks"]]&&uv["RefinedOriginalResidual"]===0&&uv["RefinedSumResidual"]===0&&
   uv["SourceHash"]===FileHash[FileNameJoin[{root,"common","s13_check_uv_branches.wls"}],"SHA256"]&&
   uv["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
   receipt["result_sha256"]["Hqg/s13_branch_result/s13_result.wl"]===IntegerString[FileHash[uvPath,"SHA256"],16,64]];
 DownValues[refineUVResidual]=uv["Definitions"];
 gate["exact existing equations installed",DownValues[refineUVResidual]===uv["Definitions"]];
 ownPoleRootEvidence=<||>;
 controlConditions=ownPoleConditions[control["Label"]];actualConditions=ownPoleConditions[actual["Label"]];
 Print["OWN_POLE_CONDITIONS ",InputForm[<|"Control"->controlConditions,"Actual"->actualConditions|>]];
 controlRows=KeyValueMap[Function[{power,value},
   {priorSeconds,original}=AbsoluteTiming[ownPoleBounded[zero[value,controlConditions],"original own control"]];
   gate["original own accepted control predicate",TrueQ[original]];
   timed=AbsoluteTiming[ownPoleBounded[ownPoleRefine[value,controlConditions],"refined own control"]];
   gate["complete own accepted pole unchanged",Last[timed]===0];
   <|"Power"->power,"OriginalSeconds"->priorSeconds,"Seconds"->First[timed],"Residual"->Last[timed]|>],control["PoleResiduals"]];
 combined=Expand[Total[actual["InputParts"]],eps];
 actualRows=KeyValueMap[Function[{power,value},
   Print["OWN_ACTUAL_POLE_BEGIN ",power," bytes ",ByteCount[value]];
   timed=AbsoluteTiming[ownPoleBounded[ownPoleRefine[value,actualConditions],"actual saved pole"]];
   gate["actual saved pole vanishes",Last[timed]===0];
   sumTimed=AbsoluteTiming[ownPoleBounded[ownPoleRefine[Coefficient[combined,eps,power],actualConditions],"actual original sum pole"]];
   gate["actual original contribution pole vanishes",Last[sumTimed]===0];
   Print["OWN_ACTUAL_POLE_REFINED ",power," seconds ",First[timed]," sum_seconds ",First[sumTimed]];
   <|"Power"->power,"Seconds"->First[timed],"Residual"->Last[timed],
     "InputSumSeconds"->First[sumTimed],"InputSumResidual"->Last[sumTimed]|>],actual["PoleResiduals"]];
 result=<|"Schema"->"polarized-sidis-own-pole-refinement-v1","Channel"->channel,"Accepted"->True,
   "SourceHash"->FileHash[ownPoleSource,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
   "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"ConfigHash"->FileHash[settingsPath,"SHA256"],
   "OriginalZeroDefinitions"->DownValues[zero],"OriginalFinitePartDefinitions"->DownValues[finitePart],
   "Definitions"->DownValues[ownPoleRefine],"RefinementDefinitions"->DownValues[refineUVResidual],
   "ExistingProofHash"->FileHash[uvPath,"SHA256"],"ActualCheckpointHash"->FileHash[actualPath,"SHA256"],
   "ControlCheckpointHash"->FileHash[controlPath,"SHA256"],"ControlFiniteHash"->Hash[control["Finite"],"SHA256"],
   "ActualLabel"->actual["Label"],"ControlLabel"->control["Label"],"ControlConditions"->controlConditions,
   "ActualConditions"->actualConditions,"ControlRows"->controlRows,"ActualRows"->actualRows,
   "RootEvidence"->ownPoleRootEvidence,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
 directory=FileNameJoin[{root,channel,"s14_pole_refinement_result"}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 path=FileNameJoin[{directory,"s14_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded own pole proof",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];
 gate["exact own pole proof reload",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
 Export[FileNameJoin[{directory,"s14_checks.json"}],<|"checks"->checks,"accepted"->True,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
 Print["PASS: s14_check_Hqq_pole_refinement"];Quit[0]];
ownPoleAnchor="cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
ownPoleReplacement="cachedPartsRecord[];ownPoleCompare[];";
If[StringCount[cachedPartsRun,ownPoleAnchor]=!=1,Quit[1]];
ownPoleRun=StringReplace[cachedPartsRun,ownPoleAnchor->ownPoleReplacement];
If[!SyntaxQ[ownPoleRun]||StringReplace[ownPoleRun,ownPoleReplacement->ownPoleAnchor]=!=cachedPartsRun,Quit[1]];
ToExpression[ownPoleRun,InputForm];

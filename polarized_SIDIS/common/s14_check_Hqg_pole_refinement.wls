(* Reuse the accepted factor certificate on Hqg's exact saved assembly inputs. *)
$HistoryLength=0;root=Directory[];checks=<||>;
gate[label_,test_]:=If[TrueQ[test],AssociateTo[checks,label->True];Print["PASS: ",label],Print["FAIL: ",label];Quit[1]];
SetAttributes[poleBounded,HoldFirst];
poleBounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,300,gate["time "<>ToString[label,InputForm],False]],2*1024^3,gate["memory "<>ToString[label,InputForm],False]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
source=FileNameJoin[{root,"common","s14_check_Hqg_pole_refinement.wls"}];
baseline=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];
gate["source syntax",SyntaxQ[Import[source,"Text"]]];
gate["unchanged finite assembler",IntegerString[FileHash[baseline,"SHA256"],16,64]==="9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a"];
proofRelative="Hqqbar/s14_pole_factorization_result/s14_result.wl";proofPath=FileNameJoin[{root,proofRelative}];
receiptPath=FileNameJoin[{DirectoryName[proofPath],"s14_execution.json"}];receipt=Import[receiptPath,"RawJSON"];
gate["accepted existing factorization proof",TrueQ[receipt["passed"]]&&receipt["result_sha256"][proofRelative]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
proof=Get[proofPath];
gate["existing exact factorization contract",proof["Schema"]==="polarized-sidis-assembly-pole-refinement-v1"&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
 proof["NativeVersions"]==={$Version,$FeynCalcVersion}&&proof["BaselineSourceHash"]===FileHash[baseline,"SHA256"]&&
 proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_pole_factorization.wls"}],"SHA256"]];
text=Import[baseline,"Text"];
begin=StringPosition[text,"reduce[value_,assumptions_]"];end=StringPosition[text,"\nepsSeries[value_]"];
gate["unique complete reduction definitions",Length[begin]===1&&Length[end]===1];
definitions=StringTake[text,{First[First[begin]],First[First[end]]-1}];gate["complete reduction syntax",SyntaxQ[definitions]];ToExpression[definitions,InputForm];
gate["identical original zero predicate",DownValues[zero]===proof["OriginalZeroDefinitions"]];
DownValues[refineUVResidual]=proof["RefinementDefinitions"];DownValues[refineAssemblyPole]=proof["Definitions"];
gate["exact accepted refinement installed",{DownValues[refineUVResidual],DownValues[refineAssemblyPole]}===Lookup[proof,{"RefinementDefinitions","Definitions"}]];
domainText=StringCases[text,RegularExpression["softPhysical=[^;]+;"]];gate["one original soft domain",Length[domainText]===1];ToExpression[First[domainText],InputForm];
cacheRelative="cache/s14/Hqg/47e69226250f205317044df52dc3a4b6a756cabf6996d9f92b772464c140c584/";
failedPath=FileNameJoin[{root,cacheRelative<>"finite_6fcb2f9004c78e81fb9b7b4216a945e6266355c36373a07beda4124fb49f9f10.wl"}];
controlPath=FileNameJoin[{root,cacheRelative<>"finite_55f4c0e022e967106a18426881916a63265cfa018773fb288ca904de981865d7.wl"}];
gate["exact failed saved input",IntegerString[FileHash[failedPath,"SHA256"],16,64]==="21588f5e5cc51db69a7e4e7764d840c3b2a3368f60acdd182433197c7deb8340"];
gate["exact own accepted control",IntegerString[FileHash[controlPath,"SHA256"],16,64]==="023727b95804718534df3352e47e9c7948f7d2393196950c8a683912498066db"];
failed=Get[failedPath];control=Get[controlPath];
gate["same native assembly input identity",failed["Accepted"]===False&&TrueQ[control["Accepted"]]&&failed["InputHash"]===control["InputHash"]&&Length[failed["InputParts"]]===3];
conditions[label_]:=(softPhysical/.t->label[[2]] omega-s)&&If[label[[2]]===0,True,omega>0];
poleFactorCertificates=<||>;
controlRows=KeyValueMap[Function[{power,value},Module[{answer},
 gate["original own control pole "<>ToString[power],poleBounded[zero[value,conditions[control["Label"]]],"original control"]];
 answer=poleBounded[refineAssemblyPole[value,conditions[control["Label"]]],"refined control"];
 gate["own accepted pole unchanged "<>ToString[power],answer===0];<|"Power"->power,"Refined"->answer|>]],control["PoleResiduals"]];
combined=Expand[Total[failed["InputParts"]],eps];
rows=KeyValueMap[Function[{power,value},Module[{savedTiming,sumTiming,actualReduced},
 savedTiming=AbsoluteTiming[poleBounded[refineAssemblyPole[value,conditions[failed["Label"]]],{"saved",power}]];
 sumTiming=AbsoluteTiming[
  actualReduced=poleBounded[reduce[Coefficient[combined,eps,power],conditions[failed["Label"]]],{"original production input reduction",power}];
  gate["original input sum reproduces exact saved residual "<>ToString[power],actualReduced===value];
  poleBounded[refineAssemblyPole[actualReduced,conditions[failed["Label"]]],{"input sum",power}]];
 Print["ACTUAL_HQG_POLE ",power," saved ",Last[savedTiming]," input sum ",Last[sumTiming]];
 <|"Power"->power,"Refined"->Last[savedTiming],"InputSumRefined"->Last[sumTiming],"Seconds"->First[savedTiming],"InputSumSeconds"->First[sumTiming]|>]],failed["PoleResiduals"]];
gate["every saved Hqg pole vanishes",AllTrue[rows,#["Refined"]===0&]];
gate["every original Hqg input-sum pole vanishes",AllTrue[rows,#["InputSumRefined"]===0&]];
result=<|"Schema"->"polarized-sidis-Hqg-pole-refinement-v1","Channel"->"Hqg","Accepted"->True,
 "InputHash"->failed["InputHash"],"PhysicalConditions"->conditions[failed["Label"]],"FailedLabel"->failed["Label"],"FailedCheckpoint"->failed,
 "FailedCheckpointHash"->FileHash[failedPath,"SHA256"],"ControlLabel"->control["Label"],"ControlHash"->FileHash[controlPath,"SHA256"],
 "ControlFiniteHash"->Hash[control["Finite"],"SHA256"],"ControlRows"->controlRows,"Rows"->rows,"FactorCertificates"->poleFactorCertificates,
 "OriginalZeroDefinitions"->DownValues[zero],"RefinementDefinitions"->DownValues[refineUVResidual],"Definitions"->DownValues[refineAssemblyPole],
 "OriginalFinitePartDefinitions"->proof["OriginalFinitePartDefinitions"],"ExistingProofHash"->FileHash[proofPath,"SHA256"],
 "SourceHash"->FileHash[source,"SHA256"],"BaselineSourceHash"->FileHash[baseline,"SHA256"],"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,"Hqg","s14_pole_refinement_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
resultPath=FileNameJoin[{out,"s14_result.wl"}];
serialized="Uncompress["<>ToString[poleBounded[Compress[result],"proof compression"],InputForm]<>"]\n";
gate["bounded complete native proof file",StringLength[serialized]<128*1024^2];
Export[resultPath<>".tmp",serialized,"Text"];
gate["exact native result reload",Get[resultPath<>".tmp"]===result];
RenameFile[resultPath<>".tmp",resultPath,OverwriteTarget->True];
Export[FileNameJoin[{out,"s14_checks.json"}],<|"channel"->"Hqg","checks"->checks,"accepted"->True,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_Hqg_pole_refinement"];Quit[0];

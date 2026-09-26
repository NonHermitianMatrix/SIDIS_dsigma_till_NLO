(* Reuse the accepted residual refinement on the actual failed assembly pole. *)
$HistoryLength=0;
poleRoot=Directory[];
poleSource=FileNameJoin[{poleRoot,"common","s14_check_Hgq_pole_factorization.wls"}];
poleConfigPath=FileNameJoin[{poleRoot,"common","s14_Hgq_pole_factorization_inputs.json"}];
poleSettings=Import[poleConfigPath,"RawJSON"];
poleBaseline=FileNameJoin[{poleRoot,"common","s14_assemble_finite_spin.wls"}];
If[IntegerString[FileHash[poleBaseline,"SHA256"],16,64]=!=poleSettings["baseline_sha256"],Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
poleText=Import[poleBaseline,"Text"];
If[StringCount[poleText,"\nindices=Tuples"]=!=1,Quit[1]];
polePrefix=First[StringSplit[poleText,"\nindices=Tuples"]];
If[StringCount[polePrefix,"Get[\"FeynCalc`\"]"]=!=1,Quit[1]];
polePrefix=StringReplace[polePrefix,"Get[\"FeynCalc`\"]"->"Null"];
poleFrameAnchor="realFrame=spinReal[\"Frame\"];";
poleFrameRelease=poleFrameAnchor<>"Clear[spinReal];ClearSystemCache[];";
If[StringCount[polePrefix,poleFrameAnchor]=!=1,Quit[1]];
poleUnreleasedPrefix=polePrefix;
polePrefix=StringReplace[polePrefix,poleFrameAnchor->poleFrameRelease];
If[StringReplace[polePrefix,poleFrameRelease->poleFrameAnchor]=!=poleUnreleasedPrefix,Quit[1]];
If[!SyntaxQ[polePrefix]||!SyntaxQ[Import[poleSource,"Text"]],Quit[1]];
ToExpression[polePrefix,InputForm];
gate["own pole comparison channel",channel===poleSettings["channel"]&&channel==="Hgq"&&core];
KeyValueMap[gate["bound pole comparison input "<>#1,
  IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,poleSettings["files"]];
poleFailedPath=FileNameJoin[{root,poleSettings["failed_checkpoint"]}];
poleControlPath=FileNameJoin[{root,poleSettings["control_checkpoint"]}];
poleFailed=Get[poleFailedPath];poleControl=Get[poleControlPath];
gate["failed checkpoint retains exact assembly inputs",poleFailed["InputHash"]===inputHash&&
  !TrueQ[poleFailed["Accepted"]]&&KeyExistsQ[poleFailed,"InputParts"]&&
  Length[poleFailed["PoleResiduals"]]>0];
gate["own accepted control identity",poleControl["InputHash"]===inputHash&&
  TrueQ[poleControl["Accepted"]]&&KeyExistsQ[poleControl,"Finite"]&&
  Length[poleControl["PoleResiduals"]]>0];
poleReceipt=Import[FileNameJoin[{root,poleSettings["failed_receipt"]}],"RawJSON"];
gate["failed execution binds the unchanged assembly",poleReceipt["job_id"]===poleSettings["failed_job_id"]&&
  !TrueQ[poleReceipt["passed"]]&&poleReceipt["exit_code"]===1&&
  poleReceipt["reviewed_sha256"]["common/s14_assemble_finite_spin.wls"]===poleSettings["baseline_sha256"]];
KeyValueMap[gate["failed execution input unchanged "<>#1,
  poleReceipt["reviewed_sha256"][#1]===IntegerString[#2,16,64]]&,inputHashes];
poleUV=Get[FileNameJoin[{root,"Hqg","s13_branch_result","s13_result.wl"}]];
poleUVReceipt=Import[FileNameJoin[{root,"Hqg","s13_branch_result","s13_execution.json"}],"RawJSON"];
gate["accepted existing residual routine",TrueQ[poleUVReceipt["passed"]]&&TrueQ[poleUV["Accepted"]]&&
  And@@Values[poleUV["Checks"]]&&poleUV["RefinedOriginalResidual"]===0&&poleUV["RefinedSumResidual"]===0&&
  poleUV["SourceHash"]===FileHash[FileNameJoin[{root,"common","s13_check_uv_branches.wls"}],"SHA256"]&&
  poleUV["NativeVersions"]==={$Version,$FeynCalcVersion}];
DownValues[refineUVResidual]=poleUV["Definitions"];
gate["exact existing residual routine installed",DownValues[refineUVResidual]===poleUV["Definitions"]];
poleFactorCertificates=<||>;
poleInheritedPath=FileNameJoin[{root,"Hqqbar","s14_pole_factorization_result","s14_result.wl"}];
poleInherited=Get[poleInheritedPath];
poleInheritedReceipt=Import[FileNameJoin[{DirectoryName[poleInheritedPath],"s14_execution.json"}],"RawJSON"];
gate["accepted inherited assembly refinement",TrueQ[poleInheritedReceipt["passed"]]&&
  poleInheritedReceipt["job_id"]==="14806606"&&TrueQ[poleInherited["Accepted"]]&&
  And@@Values[poleInherited["Checks"]]&&
  poleInheritedReceipt["result_sha256"]["Hqqbar/s14_pole_factorization_result/s14_result.wl"]===
    IntegerString[FileHash[poleInheritedPath,"SHA256"],16,64]&&
  poleInherited["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_pole_factorization.wls"}],"SHA256"]&&
  poleInherited["BaselineSourceHash"]===sourceHash&&poleInherited["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  AllTrue[poleInherited["Rows"],#["Refined"]===0&&#["InputSumRefined"]===0&]&&
  AllTrue[poleInherited["ControlRows"],#["Refined"]===0&]];
gate["unchanged original predicates and refinement definitions",
  DownValues[zero]===poleInherited["OriginalZeroDefinitions"]&&
  DownValues[finitePart]===poleInherited["OriginalFinitePartDefinitions"]&&
  DownValues[refineUVResidual]===poleInherited["RefinementDefinitions"]];
DownValues[refineAssemblyPole]=poleInherited["Definitions"];
gate["exact accepted assembly refinement installed",DownValues[refineAssemblyPole]===poleInherited["Definitions"]];

poleConditions[label_] := (If[Last[label]==="Regular",physical,softPhysical]/.t->label[[2]]omega-s)&&
  If[label[[2]]===0,True,omega>0]&&flavorDomain;
SetAttributes[poleBounded,HoldFirst];
poleBounded[value_,label_] := MemoryConstrained[TimeConstrained[value,300,
  gate["pole comparison time bound "<>ToString[label,InputForm],False]],2*1024^3,
  gate["pole comparison memory bound "<>ToString[label,InputForm],False]];
poleControlConditions=poleConditions[poleControl["Label"]];
poleControlRows=KeyValueMap[Function[{power,value},
  gate["own original pole predicate "<>ToString[power],poleBounded[zero[value,poleControlConditions],"original control"]];
  timed=AbsoluteTiming[poleBounded[refineAssemblyPole[value,poleControlConditions],"refined control"]];
  gate["own accepted pole unchanged "<>ToString[power],Last[timed]===0];
  <|"Power"->power,"Seconds"->First[timed],"Refined"->Last[timed]|>],poleControl["PoleResiduals"]];
poleActualConditions=poleConditions[poleFailed["Label"]];
poleCombined=Expand[Total[poleFailed["InputParts"]],eps];
poleRows=KeyValueMap[Function[{power,value},
  factored=poleBounded[Factor[Together[value]],"actual saved residue factorization"];
  Print["ACTUAL_FACTORED_POLE ",power," ",InputForm[factored]];
  timed=AbsoluteTiming[poleBounded[refineAssemblyPole[value,poleActualConditions],"actual saved residue refinement"]];
  sumTimed=AbsoluteTiming[poleBounded[
    actual=reduce[Coefficient[poleCombined,eps,power],poleActualConditions];
    gate["original input reduction exactly reproduces saved residue "<>ToString[power],
      actual===value||Together[actual-value]===0];
    Last[timed],"complete original input pole"]];

  Print["ACTUAL_REFINED_POLE ",power," ",InputForm[Last[timed]]," INPUT_SUM ",InputForm[Last[sumTimed]]];
  <|"Power"->power,"Original"->value,"Factored"->factored,"Refined"->Last[timed],
    "InputSumRefined"->Last[sumTimed],"InputSumMethod"->"OriginalReductionAndExactSavedResidueEquality","Seconds"->First[timed],"InputSumSeconds"->First[sumTimed]|>],poleFailed["PoleResiduals"]];
poleResult=<|"Schema"->"polarized-sidis-assembly-pole-refinement-v1","Channel"->channel,
  "SourceHash"->FileHash[poleSource,"SHA256"],"BaselineSourceHash"->sourceHash,
  "ConfigHash"->FileHash[poleConfigPath,"SHA256"],"InheritedPoleProofHash"->FileHash[poleInheritedPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
  "NativeVersions"->{$Version,$FeynCalcVersion},"OriginalZeroDefinitions"->DownValues[zero],
  "OriginalFinitePartDefinitions"->DownValues[finitePart],"Definitions"->DownValues[refineAssemblyPole],
  "RefinementDefinitions"->DownValues[refineUVResidual],"ExistingProofHash"->
    FileHash[FileNameJoin[{root,"Hqg","s13_branch_result","s13_result.wl"}],"SHA256"],
  "FailedCheckpoint"->poleFailed,"FailedCheckpointHash"->FileHash[poleFailedPath,"SHA256"],
  "PhysicalConditions"->poleActualConditions,"ControlLabel"->poleControl["Label"],
  "ControlHash"->FileHash[poleControlPath,"SHA256"],"ControlFiniteHash"->Hash[poleControl["Finite"],"SHA256"],
  "ControlRows"->poleControlRows,"Rows"->poleRows,"FactorCertificates"->poleFactorCertificates,"Checks"->checks,"Accepted"->False,"FiniteNLOFHatsComputed"->False|>;
poleDirectory=FileNameJoin[{root,channel,"s14_pole_factorization_result"}];
If[!DirectoryQ[poleDirectory],CreateDirectory[poleDirectory,CreateIntermediateDirectories->True]];
put[poleResult,FileNameJoin[{poleDirectory,"s14_unaccepted.wl"}]];
gate["every actual saved residue vanishes",And@@(#["Refined"]===0&/@poleRows)];
gate["every original input-sum pole vanishes",And@@(#["InputSumRefined"]===0&/@poleRows)];
AssociateTo[poleResult,{"Accepted"->True,"Checks"->checks}];
polePath=FileNameJoin[{poleDirectory,"s14_result.wl"}];
poleSerialized="Uncompress["<>ToString[poleBounded[Compress[poleResult],"proof compression"],InputForm]<>"]\n";
gate["pole proof file bound",StringLength[poleSerialized]<128*1024^2];
Export[polePath<>".tmp",poleSerialized,"Text"];
gate["pole proof exact native reload",Get[polePath<>".tmp"]===poleResult];
RenameFile[polePath<>".tmp",polePath,OverwriteTarget->True];
DeleteFile[FileNameJoin[{poleDirectory,"s14_unaccepted.wl"}]];
Export[FileNameJoin[{poleDirectory,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "accepted"->True,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_Hgq_pole_factorization"];Quit[0];

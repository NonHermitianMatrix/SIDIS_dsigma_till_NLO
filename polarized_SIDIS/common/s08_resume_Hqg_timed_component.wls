(* Use an already checked family expansion only for the recorded timed-out task. *)
$HistoryLength=0;
loopAdapterPath=FileNameJoin[{Directory[],"common","s08_resume_Hqg_timed_component.wls"}];
loopBasePath=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
If[IntegerString[FileHash[loopBasePath,"SHA256"],16,64]=!="0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838"||!SyntaxQ[Import[loopAdapterPath,"Text"]],Quit[1]];
loopResumeInstall[]:=Module[{cfg,prior,proofPath,proofReceipt,proof,original},
 cfg=Import[FileNameJoin[{root,"common","s08_Hqg_timed_component_inputs.json"}],"RawJSON"];
 gate["timed-component continuation contract",cfg["schema"]==="polarized-sidis-timed-component-resume-v1"&&channel==="Hqg"&&cfg["channel"]===channel];
 KeyValueMap[Function[{key,row},gate["unchanged interruption input "<>key,IntegerString[FileHash[FileNameJoin[{root,row["file"]}],"SHA256"],16,64]===row["sha256"]]],cfg["files"]];
 prior=Import[FileNameJoin[{root,cfg["files"]["execution"]["file"]}],"RawJSON"];
 gate["recorded incomplete mapping execution",prior["job_id"]===cfg["prior_job"]&&!TrueQ[prior["passed"]]&&prior["reason"]==="wall_limit"];
 loopComponents=cfg["component_indices"];
 gate["only recorded timed-out tasks selected",loopComponents=!={}&&DuplicateFreeQ[loopComponents]&&AllTrue[loopComponents,IntegerQ[#]&&1<=#<=Length[tasks]&]&&And@@(StringContainsQ[Import[FileNameJoin[{root,cfg["files"]["log"]["file"]}],"Text"],#]&/@cfg["failure_lines"])];
 proofPath=FileNameJoin[{root,"Hqg","s08_loop_expansion_result","s08_result.wl"}];
 proofReceipt=Import[FileNameJoin[{DirectoryName[proofPath],"s08_execution.json"}],"RawJSON"];
 gate["accepted full own expansion comparison",TrueQ[proofReceipt["passed"]]&&proofReceipt["result_sha256"]["Hqg/s08_loop_expansion_result/s08_result.wl"]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
 proof=Get[proofPath];
 gate["unchanged exact expansion proof inputs",proof["Schema"]==="polarized-sidis-loop-coordinate-expansion-v1"&&proof["Channel"]===channel&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,$FeynCalcVersion}&&proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&proof["BaseHash"]===FileHash[loopBasePath,"SHA256"]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hqg_loop_expansion.wls"}],"SHA256"]&&proof["OwnComparisonHash"]===FileHash[groupPacketProofPath,"SHA256"]&&proof["OwnReceiptHash"]===FileHash[groupPacketReceiptPath,"SHA256"]&&proof["OriginalFamilyDefinitions"]===DownValues[familyRows]];
 loopFamilyDefinitions=proof["CandidateFamilyDefinitions"];
 original=DownValues[mapTargetTask];DownValues[loopOriginalTarget]=original/.mapTargetTask->loopOriginalTarget;
 gate["complete original target function retained",(DownValues[loopOriginalTarget]/.loopOriginalTarget->mapTargetTask)===original];
 Clear[mapTargetTask];
 mapTargetTask[index_]:=If[MemberQ[loopComponents,index],
   Block[{familyRows},DownValues[familyRows]=loopFamilyDefinitions;loopOriginalTarget[index]],loopOriginalTarget[index]];
 loopResumeEvidence=<|"SourceHash"->FileHash[loopAdapterPath,"SHA256"],"ComparisonHash"->FileHash[proofPath,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[proofPath],"s08_execution.json"}],"SHA256"],"Components"->loopComponents,"OwnAcceptedComparison"->True,"OriginalFamilyDefinitions"->proof["OriginalFamilyDefinitions"],"CandidateFamilyDefinitions"->loopFamilyDefinitions|>;
 Print["TARGETED_ACCEPTED_EXPANSION ",InputForm[KeyDrop[loopResumeEvidence,{"OriginalFamilyDefinitions","CandidateFamilyDefinitions"}]]]];
loopResumeFinish[]:=Module[{old,new,before},
 old="DistributeDefinitions[groupDenominators, certifyGrouping";
 new="DistributeDefinitions[loopOriginalTarget, loopComponents, loopFamilyDefinitions, groupDenominators, certifyGrouping";
 gate["unique targeted worker distribution",StringCount[groupPacketCandidateTail,old]===1];
 before=groupPacketCandidateTail;groupPacketCandidateTail=StringReplace[before,old->new];
 gate["unchanged worker code beyond accepted definitions",StringReplace[groupPacketCandidateTail,new->old]===before];
 old="\"GroupedMappingComparison\" -> groupPacketEvidence,";
 new=old<>" \"TimedComponentExpansion\" -> loopResumeEvidence,";
 gate["unique continuation evidence export",StringCount[groupPacketCandidateTail,old]===1];
 before=groupPacketCandidateTail;groupPacketCandidateTail=StringReplace[before,old->new];
 gate["unchanged full target output contract",StringReplace[groupPacketCandidateTail,new->old]===before&&SyntaxQ[groupPacketCandidateTail]];
 packetSourcePath=loopAdapterPath];
loopText=Import[loopBasePath,"Text"];
loopEdits={"ToExpression[groupPacketTask,InputForm];"->"ToExpression[groupPacketTask,InputForm];loopResumeInstall[];",
 "packetSourcePath=groupPacketSource;"->"packetSourcePath=groupPacketSource;loopResumeFinish[];"};
If[!And@@(StringCount[loopText,First[#]]===1&/@loopEdits),Print["FAIL: unique targeted continuation hooks"];Quit[1]];
loopRun=StringReplace[loopText,loopEdits];
If[!SyntaxQ[loopRun]||StringReplace[loopRun,Reverse/@loopEdits]=!=loopText,Print["FAIL: unchanged original grouped implementation"];Quit[1]];
ToExpression[loopRun,InputForm];

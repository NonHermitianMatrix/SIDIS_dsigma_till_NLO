(* Restrict the reference numerator expansion to its declared loop coordinates. *)
$HistoryLength=0;
loopSource=FileNameJoin[{Directory[],"common","s08_check_Hqg_loop_expansion.wls"}];
loopBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
If[IntegerString[FileHash[loopBase,"SHA256"],16,64]=!=
  "0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838" ||
  !SyntaxQ[Import[loopSource,"Text"]],Quit[1]];
loopText=Import[loopBase,"Text"];
loopBoundary=StringPosition[loopText,"\ngroupPacketOriginalTask="];
If[Length[loopBoundary]=!=1,Quit[1]];
loopPrefix=StringTake[loopText,First[First[loopBoundary]]-1];
If[!SyntaxQ[loopPrefix],Quit[1]];ToExpression[loopPrefix,InputForm];
gate["own loop expansion comparison channel",channel==="Hqg"];
loopProof=groupPacketProof;loopProofPath=groupPacketProofPath;
loopTask=loopProof["Task"];loopExpression=loopTask["Value"]/.coordinateRules;
gate["complete actual accepted equation",loopExpression===loopProof["ActualExpression"] &&
  loopProof["Denominators"]===denominators];
loopReference=loopProof["Coefficients"];
loopOriginalDefinitions=DownValues[familyRows];
loopVariableLists=Cases[loopOriginalDefinitions,HoldPattern[CoefficientRules[_,vars_List]]:>vars,Infinity];
gate["unique original polynomial variable declaration",Length[loopVariableLists]===1 &&
  DuplicateFreeQ[First[loopVariableLists]] && AllTrue[First[loopVariableLists],Head[#]===Symbol&]];
loopVariables=First[loopVariableLists];
loopStart=StringPosition[targetMapperText,"familyRows[expression_, family_]"];
loopEnd=StringPosition[targetMapperText,"\nmapExpression[expression_]"];
gate["complete unique original family function",Length[loopStart]===1 && Length[loopEnd]===1];
loopDefinition=StringTake[targetMapperText,{First[First[loopStart]],First[First[loopEnd]]-1}];
loopOld="numerator = Expand[Numerator[transformed]];";
loopNew="numerator = Expand[Numerator[transformed], "<>ToString[Alternatives@@loopVariables,InputForm]<>"];";
gate["one original numerator expansion",StringCount[loopDefinition,loopOld]===1];
loopCandidateDefinition=StringReplace[loopDefinition,loopOld->loopNew];
gate["only declared-coordinate expansion differs",SyntaxQ[loopCandidateDefinition] &&
  StringReplace[loopCandidateDefinition,loopNew->loopOld]===loopDefinition];
ToExpression[loopDefinition,InputForm];
gate["exact original native family definition",DownValues[familyRows]===loopOriginalDefinitions];
ToExpression[loopCandidateDefinition,InputForm];loopCandidateDefinitions=DownValues[familyRows];
gate["unchanged complete native mapper and merge",DownValues[mapExpression]===
  loopProof["AlgorithmDefinitions"]["OriginalMappingDefinitions"] && DownValues[merge]===
  loopProof["AlgorithmDefinitions"]["OriginalMergeDefinitions"]];
groupInputHash=Hash[{FileHash[loopSource,"SHA256"],FileHash[loopProofPath,"SHA256"],
  inputHashes,targetInputHash,loopOriginalDefinitions,loopCandidateDefinitions,$Version,$FeynCalcVersion},"SHA256"];
groupCache=FileNameJoin[{root,"cache","s08_Hqg_loop_expansion",IntegerString[groupInputHash,16]}];
If[!DirectoryQ[groupCache],CreateDirectory[groupCache,CreateIntermediateDirectories->True]];
Clear[spin,sector,tasks,groupPacketProof];ClearSystemCache[];
Print["LOOP_EXPANSION_INPUT ",InputForm[<|"Task"->KeyDrop[loopTask,"Value"],
  "Variables"->loopVariables,"EquationBytes"->ByteCount[loopExpression],"Denominators"->denominators|>]];
{loopSeconds,loopCoefficients}=AbsoluteTiming[groupedMapExpression[loopExpression,"own_complete_control"]];
{loopEqualitySeconds,loopEqual}=AbsoluteTiming[loopCoefficients===loopReference ||
  bounded[zero[pairReconstruct[loopCoefficients]-pairReconstruct[loopReference]],"entire own loop-expansion map comparison"]];
gate["entire own accepted grouped map reproduced",loopEqual];
loopResult=<|"Schema"->"polarized-sidis-loop-coordinate-expansion-v1","Channel"->channel,
  "SourceHash"->FileHash[loopSource,"SHA256"],"BaseHash"->FileHash[loopBase,"SHA256"],
  "OwnComparisonFile"->groupPacketProofRelative,"OwnComparisonHash"->FileHash[loopProofPath,"SHA256"],
  "OwnReceiptHash"->FileHash[groupPacketReceiptPath,"SHA256"],"InputHashes"->inputHashes,
  "TargetInputHash"->targetInputHash,"InputHash"->groupInputHash,"NativeVersions"->{$Version,$FeynCalcVersion},
  "Variables"->loopVariables,"Task"->KeyDrop[loopTask,"Value"],"ExpressionHash"->Hash[loopExpression,"SHA256"],
  "OriginalFamilyDefinitions"->loopOriginalDefinitions,"CandidateFamilyDefinitions"->loopCandidateDefinitions,
  "Coefficients"->loopCoefficients,"OwnAcceptedComparison"->True,
  "PriorGroupedSeconds"->loopProof["CandidateSeconds"],"PriorJobId"->groupPacketReceipt["job_id"],
  "PriorNode"->groupPacketReceipt["node"],"CandidateSeconds"->loopSeconds,"EqualitySeconds"->loopEqualitySeconds,
  "CurrentNode"->$MachineName,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"Checks"->checks,
  "FiniteNLOFHatsComputed"->False|>;
loopDirectory=FileNameJoin[{root,channel,"s08_loop_expansion_result"}];
If[!DirectoryQ[loopDirectory],CreateDirectory[loopDirectory,CreateIntermediateDirectories->True]];
loopResultPath=FileNameJoin[{loopDirectory,"s08_result.wl"}];
loopSerialized="Uncompress["<>ToString[bounded[Compress[loopResult],"loop comparison compression"],InputForm]<>"]\n";
gate["bounded loop comparison export",StringLength[loopSerialized]<128*1024^2];
Export[loopResultPath<>".tmp",loopSerialized,"Text"];
gate["exact saved loop comparison",Get[loopResultPath<>".tmp"]===loopResult];
RenameFile[loopResultPath<>".tmp",loopResultPath,OverwriteTarget->True];
Export[FileNameJoin[{loopDirectory,"s08_checks.json"}],<|"checks"->checks,
  "prior_grouped_seconds"->loopProof["CandidateSeconds"],"prior_node"->groupPacketReceipt["node"],
  "candidate_seconds"->loopSeconds,"current_node"->$MachineName,"equality_seconds"->loopEqualitySeconds,
  "own_complete_comparison"->loopEqual,"peak_kernel_memory_bytes"->MaxMemoryUsed[],
  "job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hqg_loop_expansion"];Quit[0];

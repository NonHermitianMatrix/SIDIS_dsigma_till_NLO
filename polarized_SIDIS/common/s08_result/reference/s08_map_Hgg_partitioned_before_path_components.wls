(* Disjoint dispatch of the accepted Hgg mapper; no mapping equation changes. *)
$HistoryLength=0;
partitionSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_partitioned.wls"}];
partitionBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_exact_additive.wls"}];
If[!SyntaxQ[Import[partitionSource,"Text"]]||IntegerString[FileHash[partitionBase,"SHA256"],16,64]=!=
 "fe08e56d0a4f0a22080f160584b27145e96fa9557c2431bd5740b55d1a4f94a6",Quit[1]];
partitionInteger[name_,maximum_]:=Module[{value=Environment[name]},
 If[!StringQ[value]||!StringMatchQ[value,DigitCharacter..],Quit[1]];
 value=FromDigits[value];If[!TrueQ[0<value<=maximum],Quit[1]];value];
partitionCount=partitionInteger["POLARIZED_SIDIS_PARTITION_COUNT",8];
partitionIndex=partitionInteger["POLARIZED_SIDIS_PARTITION_INDEX",partitionCount];
partitionJob=Environment["JOB_ID"];
If[!StringQ[partitionJob]||!StringMatchQ[partitionJob,DigitCharacter..],Quit[1]];
partitionJobTag=partitionJob<>"_batch_"<>ToString[partitionIndex];
partitionCheckOnly=Environment["POLARIZED_SIDIS_PARTITION_CHECK"]==="1";
partitionOwner=If[partitionCheckOnly,"s08_partition_interface","s08_partition_"<>IntegerString[partitionIndex,10,2]];
partitionKernelDirectory[]:="kernel_"<>partitionJobTag<>"_"<>ToString[$KernelID];
partitionText=StringTrim[Import[partitionBase,"Text"]];
partitionTerminal="ToExpression[externalConsumerRun,InputForm];";
If[!StringEndsQ[partitionText,partitionTerminal],Quit[1]];
partitionPrefix=StringDrop[partitionText,-StringLength[partitionTerminal]];
If[!SyntaxQ[partitionPrefix],Quit[1]];ToExpression[partitionPrefix,InputForm];

partitionSameCoefficients[left_,right_]:=AssociationQ[left]&&AssociationQ[right]&&
 Sort[Keys[left]]===Sort[Keys[right]]&&
 And@@KeyValueMap[(#2===right[#1]||bounded[zero[#2-right[#1]],{"partition own coefficient",#1}])&,left];
partitionWritePath[path_String]:=Module[{directory},
 If[DirectoryName[DirectoryName[path]]=!=partitionPieceDirectory||
  !StringStartsQ[FileNameTake[DirectoryName[path]],"kernel_"],Return[path]];
 directory=FileNameJoin[{partitionPieceDirectory,partitionKernelDirectory[]}];
 If[!DirectoryQ[directory],CreateDirectory[directory]];
 FileNameJoin[{directory,FileNameTake[path]}]];
partitionRoutedWrite[value_,path_]:=partitionNativeWrite[value,partitionWritePath[path]];
partitionWorkerControl[]:=Catch[Block[{checks=<||>},Module[{proof,value},
 proof=Get[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}]];
 value=Block[{sharedReadPiece},sharedReadPiece[path_String,binding_Integer]:=<||>;
  bounded[polynomialPieceMap[proof["ActualInput"]["Equation"]],"partition worker own group"]];
 gate["partition worker complete own coefficients",partitionSameCoefficients[value,proof["FreshCoefficients"]]];
 gate["partition worker writes only its own packet directory",
  Length[FileNames["*.wl",FileNameJoin[{partitionPieceDirectory,partitionKernelDirectory[]}]]]===Length[proof["ActualInput"]["Pieces"]]];
 <|"Kernel"->$KernelID,"Directory"->partitionKernelDirectory[],"Checks"->checks,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>]],"TargetMapFailure"];
partitionInstall[]:=Module[{original,proof,path,receipt,relative,miss,hit,files,before},
 original=DownValues[polynomialPieceMap];
 partitionOriginalPieceDefinitions=original;
 partitionOriginalWriterDefinitions=DownValues[saveNative];
 DownValues[partitionNativeWrite]=partitionOriginalWriterDefinitions/.saveNative->partitionNativeWrite;
 gate["complete original native writer retained",
  (DownValues[partitionNativeWrite]/.partitionNativeWrite->saveNative)===partitionOriginalWriterDefinitions];
 partitionPieceDirectory=FileNameJoin[{root,"cache","s08_Hqg_polynomial_terms",IntegerString[pieceScientificHash,16]}];
 DownValues[saveNative]=DownValues[partitionRoutedWrite]/.partitionRoutedWrite->saveNative;
 gate["complete polynomial mapper unchanged",DownValues[polynomialPieceMap]===original];
 partitionCandidatePieceDefinitions=DownValues[polynomialPieceMap];
 partitionCandidateWriterDefinitions=DownValues[saveNative];
 relative="Hgg/s08_partition_interface_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 If[partitionCheckOnly,
  proof=Get[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}]];
  partitionOwnDirectory=FileNameJoin[{root,"cache","s08_Hqg_polynomial_terms",
   IntegerString[pieceScientificHash,16],partitionKernelDirectory[]}];
  gate["new isolated partition writer",!DirectoryQ[partitionOwnDirectory]];
  {partitionMissSeconds,miss}=AbsoluteTiming[Block[{sharedReadPiece},
   sharedReadPiece[path_String,binding_Integer]:=<||>;
   bounded[polynomialPieceMap[proof["ActualInput"]["Equation"]],"partition own cache miss"]]];
  gate["partition miss preserves complete accepted own coefficients",partitionSameCoefficients[miss,proof["FreshCoefficients"]]];
  files=Sort[FileNames["*.wl",partitionOwnDirectory]];
  gate["own piece writes use only isolated namespace",Length[files]===Length[proof["ActualInput"]["Pieces"]]];
  before=FileHash[#,"SHA256"]&/@files;
  {partitionHitSeconds,hit}=AbsoluteTiming[bounded[polynomialPieceMap[proof["ActualInput"]["Equation"]],"partition own cache hit"]];
  gate["partition hit preserves complete accepted own coefficients",partitionSameCoefficients[hit,miss]];
  gate["partition hit leaves saved packets unchanged",files===Sort[FileNames["*.wl",partitionOwnDirectory]]&&
   before===(FileHash[#,"SHA256"]&/@files)];
  partitionOwnComparison=True,
  receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
  gate["accepted partition interface execution",TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
   receipt["reviewed_sha256"]["common/s08_map_Hgg_partitioned.wls"]===IntegerString[FileHash[partitionSource,"SHA256"],16,64]];
  proof=Get[path];
  gate["same exact partition input and complete mapper contract",
   proof["Schema"]==="polarized-sidis-partition-interface-v1"&&proof["Channel"]===channel&&
   proof["SourceHash"]===FileHash[partitionSource,"SHA256"]&&proof["BaseHash"]===FileHash[partitionBase,"SHA256"]&&
   proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
   proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["PartitionCount"]===partitionCount&&
   proof["OriginalPieceDefinitions"]===original&&proof["CandidatePieceDefinitions"]===DownValues[polynomialPieceMap]&&
   proof["OriginalWriterDefinitions"]===partitionOriginalWriterDefinitions&&
   proof["CandidateWriterDefinitions"]===DownValues[saveNative]&&
   TrueQ[proof["OwnAcceptedComparison"]]&&Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]]];
 AssociateTo[hggPolynomialEvidence,"PartitionDispatch"-><|"SourceHash"->FileHash[partitionSource,"SHA256"],
  "BaseHash"->FileHash[partitionBase,"SHA256"],"Count"->partitionCount,"Index"->partitionIndex,
  "JobTag"->partitionJobTag,"CheckOnly"->partitionCheckOnly|>];
 Print["DISJOINT_PARTITION_DIRECTORY_INSTALLED ",partitionJobTag]];

partitionDispatch[]:=Module[{sets,all=targetRest,workerResults,directory,result},
 sets=Table[Pick[all,Mod[Range[Length[all]]-1,partitionCount],k-1],{k,partitionCount}];
 gate["complete disjoint native component coverage",Sort[Flatten[sets]]===Sort[all]&&
  DuplicateFreeQ[Flatten[sets]]&&Length[sets]===partitionCount&&AllTrue[sets,Length[#]>0&]&&
  Intersection[Flatten[sets],{13}]==={}&&Union[Flatten[sets],{13}]===Range[Length[tasks]]];
 targetRest=sets[[partitionIndex]];
 Print["PARTITION_COMPONENT_INDICES ",InputForm[<|"Index"->partitionIndex,"Count"->partitionCount,"Components"->targetRest|>]];
 If[partitionCheckOnly,
  gate["multiple native workers for namespace interface",workers>1];
  workerResults=ParallelEvaluate[partitionWorkerControl[]];
  gate["every worker preserves accepted complete own output",AllTrue[workerResults,AssociationQ]&&
   And@@Flatten[Values[#["Checks"]]&/@workerResults]];
  gate["native worker write namespaces are disjoint",DuplicateFreeQ[Lookup[workerResults,"Directory"]]&&
   FreeQ[Lookup[workerResults,"Directory"],partitionKernelDirectory[]]&&
   AllTrue[Lookup[workerResults,"Directory"],StringStartsQ[#,"kernel_"<>partitionJobTag<>"_"]&]];
  directory=FileNameJoin[{root,"Hgg","s08_partition_interface_result"}];
  If[!DirectoryQ[directory],CreateDirectory[directory]];
  result=<|"Schema"->"polarized-sidis-partition-interface-v1","Channel"->channel,
   "SourceHash"->FileHash[partitionSource,"SHA256"],"BaseHash"->FileHash[partitionBase,"SHA256"],
   "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
   "PartitionCount"->partitionCount,"Partitions"->sets,"WorkerResults"->workerResults,
   "OriginalPieceDefinitions"->partitionOriginalPieceDefinitions,"CandidatePieceDefinitions"->partitionCandidatePieceDefinitions,
   "OriginalWriterDefinitions"->partitionOriginalWriterDefinitions,"CandidateWriterDefinitions"->partitionCandidateWriterDefinitions,
   "OwnAcceptedComparison"->partitionOwnComparison,"MissSeconds"->partitionMissSeconds,"HitSeconds"->partitionHitSeconds,
   "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
  saveNative[result,FileNameJoin[{directory,"s08_result.wl"}]];
  Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"partitions"->sets,
   "worker_directories"->Lookup[workerResults,"Directory"],"miss_seconds"->partitionMissSeconds,
   "hit_seconds"->partitionHitSeconds,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
  CloseKernels[];Print["PASS: s08_Hgg_partition_interface"];Quit[0]]];

partitionOriginalInstallDefinitions=DownValues[externalInstall];
DownValues[partitionOriginalInstall]=partitionOriginalInstallDefinitions/.externalInstall->partitionOriginalInstall;
If[(DownValues[partitionOriginalInstall]/.partitionOriginalInstall->externalInstall)=!=partitionOriginalInstallDefinitions,Quit[1]];
externalInstall[]:=(partitionOriginalInstall[];partitionInstall[]);
partitionOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[partitionOriginalTail]=partitionOriginalTailDefinitions/.coordinateTail->partitionOriginalTail;
If[(DownValues[partitionOriginalTail]/.partitionOriginalTail->coordinateTail)=!=partitionOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=partitionOriginalTail[text],anchor},
 changed=coordinateReplace[changed,"DistributeDefinitions[selectedOriginalTaskValue,",
  "DistributeDefinitions[partitionNativeWrite,partitionWritePath,partitionPieceDirectory,partitionWorkerControl,partitionSameCoefficients,partitionKernelDirectory,partitionJobTag,selectedOriginalTaskValue,"];
 anchor="targetRest = Complement[Range[Length[tasks]],{13}]; gate[\"disjoint complete component partition\",Intersection[targetRest,{13}]==={}&&Union[targetRest,{13}]===Range[Length[tasks]]];";
 changed=coordinateReplace[changed,anchor,anchor<>" partitionDispatch[];"];
 changed=coordinateReplace[changed,"\"s08_other_group_components_result\"",ToString[partitionOwner<>"_result",InputForm]];
 changed=coordinateReplace[changed,"PASS: s08_Hgg_other_group_components","PASS: s08_Hgg_partition_components"];
 changed];
If[StringCount[externalConsumerRun,"\"s08_other_group_control_result\""]=!=1,Quit[1]];
partitionRun=StringReplace[externalConsumerRun,"\"s08_other_group_control_result\""->ToString[partitionOwner<>"_control_result",InputForm]];
If[!SyntaxQ[partitionRun]||StringReplace[partitionRun,
 ToString[partitionOwner<>"_control_result",InputForm]->"\"s08_other_group_control_result\""]=!=externalConsumerRun,Quit[1]];
ToExpression[partitionRun,InputForm];

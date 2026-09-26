(* Load the accepted raw map on workers without recursively broadcasting its array. *)
$HistoryLength=0;
workerFileSource=FileNameJoin[{Directory[],"common","s08_map_real_spin_worker_files.wls"}];
workerFileBaseline=FileNameJoin[{Directory[],"common","s08_map_real_spin_compact_inputs.wls"}];
If[!SyntaxQ[Import[workerFileSource,"Text"]]||IntegerString[FileHash[workerFileBaseline,"SHA256"],16,64]=!=
 "aea8d3ac781c29b85a00d341a994420d3af5ee7f450ff7ddc0f2074e8851475f",Quit[1]];
workerFileText=Import[workerFileBaseline,"Text"];
workerFileStart=StringPosition[workerFileText,"  DistributeDefinitions[gate, bounded, put, putCompressed, zero,"];
workerFileEnd=StringPosition[workerFileText,"\n  compactDistributionSeconds ="];
If[Length[workerFileStart]=!=1||Length[workerFileEnd]=!=1,Quit[1]];
workerFileOriginal=StringTake[workerFileText,{First[First[workerFileStart]],First[First[workerFileEnd]]-1}];

workerFilePrepare[]:=Module[{},
 workerRawPath=rawTargetPath;workerRawFileHash=FileHash[workerRawPath,"SHA256"];
 workerRawArrayHash=Hash[rawTargetComponents,"SHA256"];
 workerRawMetadata=KeyTake[#,{"Sector","Kind","Index"}]&/@rawTargetComponents;
 workerRawCount=Length[rawTargetComponents];
 workerRawChannel=channel;
 workerRawVersions={$Version,FeynCalc`$FeynCalcVersion};
 gate["worker file source is accepted complete native raw map",workerRawCount>0&&
  AllTrue[rawTargetComponents,TrueQ[#["ReconstructionPassed"]]&&AssociationQ[#["Checks"]]&&And@@Values[#["Checks"]]&]]];

workerFileLoad[]:=Module[{data,seconds},
 {seconds,data}=AbsoluteTiming[
  If[FileHash[workerRawPath,"SHA256"]=!=workerRawFileHash,Return[<|"Accepted"->False,"Reason"->"FileHash"|>]];
  Get[workerRawPath]];
 If[!AssociationQ[data]||data["Schema"]=!="polarized-sidis-real-target-map-v1"||
   data["Channel"]=!=workerRawChannel||data["NativeVersions"]=!=workerRawVersions||
   !TrueQ[data["MappingAccepted"]]||!And@@Values[data["Checks"]],
  Return[<|"Accepted"->False,"Reason"->"NativeSchema"|>]];
 rawTargetComponents=data["Components"];Clear[data];
 <|"Accepted"->TrueQ[
   {$Version,FeynCalc`$FeynCalcVersion}===workerRawVersions&&
   Length[rawTargetComponents]===workerRawCount&&Hash[rawTargetComponents,"SHA256"]===workerRawArrayHash&&
   (KeyTake[#,{"Sector","Kind","Index"}]&/@rawTargetComponents)===workerRawMetadata&&
   AllTrue[rawTargetComponents,TrueQ[#["ReconstructionPassed"]]&&AssociationQ[#["Checks"]]&&And@@Values[#["Checks"]]&]],
  "ArrayHash"->Hash[rawTargetComponents,"SHA256"],"ComponentCount"->Length[rawTargetComponents],
  "Seconds"->seconds,"PeakMemoryBytes"->MaxMemoryUsed[],"Kernel"->$KernelID,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>];

workerFileDistribution=
 "  workerFilePrepare[];\n"<>
 "  Block[{rawTargetComponents},\n"<>workerFileOriginal<>"\n"<>
 "    DistributeDefinitions[workerFileLoad,workerRawPath,workerRawFileHash,workerRawArrayHash,workerRawMetadata,workerRawCount,workerRawChannel,workerRawVersions]];\n"<>
 "  workerFileEvidence=ParallelEvaluate[workerFileLoad[],DistributedContexts->None];\n"<>
 "  gate[\"workers loaded the exact complete parent raw map\",Length[workerFileEvidence]===workers&&AllTrue[workerFileEvidence,AssociationQ[#]&&TrueQ[#[\"Accepted\"]]&]];";
workerFileCandidate=StringReplace[workerFileText,workerFileOriginal->workerFileDistribution];
If[!SyntaxQ[workerFileDistribution]||!SyntaxQ[workerFileCandidate]||
 StringReplace[workerFileCandidate,workerFileDistribution->workerFileOriginal]=!=workerFileText,Quit[1]];

If[Environment["POLARIZED_SIDIS_WORKER_FILE_VALIDATE_ONLY"]==="1",
 root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];checks=<||>;
 gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];CloseKernels[];Quit[1]];
 gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&StringStartsQ[$UserBaseDirectory,root<>"/"]];
 PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 rawTargetPath=FileNameJoin[{root,channel,"s08_targets_result","s08_result.wl"}];
 workerFileReceiptPath=FileNameJoin[{DirectoryName[rawTargetPath],"s08_execution.json"}];
 workerFileReceipt=Import[workerFileReceiptPath,"RawJSON"];
 gate["accepted actual raw-map receipt",TrueQ[workerFileReceipt["passed"]]&&
  workerFileReceipt["result_sha256"][channel<>"/s08_targets_result/s08_result.wl"]===IntegerString[FileHash[rawTargetPath,"SHA256"],16,64]];
 workerFileParent=Get[rawTargetPath];
 gate["complete actual raw-map contract",workerFileParent["Schema"]==="polarized-sidis-real-target-map-v1"&&
  workerFileParent["Channel"]===channel&&workerFileParent["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[workerFileParent["MappingAccepted"]]&&And@@Values[workerFileParent["Checks"]]];
 rawTargetComponents=workerFileParent["Components"];Clear[workerFileParent];
 workerFilePrepare[];workerFileParentBytes=ByteCount[rawTargetComponents];
 workerFileDefinitionsStart=StringPosition[workerFileText,"\ncoefficientControl[]"];
 workerFileDefinitionsEnd=StringPosition[workerFileText,"\n(* Only consumer data changes;"];
 gate["unique unchanged component consumer definitions",Length[workerFileDefinitionsStart]===1&&Length[workerFileDefinitionsEnd]===1];
 workerFileDefinitions=StringTake[workerFileText,{First[First[workerFileDefinitionsStart]],First[First[workerFileDefinitionsEnd]]-1}];
 gate["complete unchanged component consumer syntax",SyntaxQ[workerFileDefinitions]];ToExpression[workerFileDefinitions,InputForm];
 slots=ToExpression[Environment["NSLOTS"]];gate["parallel interface allocation",IntegerQ[slots]&&slots>1];
 CloseKernels[];
 TimeConstrained[LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[8,slots],"TimeConstraint"->300]],300,$Failed];
 workers=Length[Kernels[]];gate["requested comparison workers available",workers===Min[8,slots]];
 ParallelEvaluate[$HistoryLength=0;PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;Get["FeynCalc`"],DistributedContexts->None];
 compactDistributionStart=AbsoluteTime[];
 ToExpression[workerFileDistribution,InputForm];
 compactDistributionSeconds=AbsoluteTime[]-compactDistributionStart;
 gate["parent raw map remains unchanged",Hash[rawTargetComponents,"SHA256"]===workerRawArrayHash];
 CloseKernels[];
 workerFileResult=<|"Schema"->"polarized-sidis-worker-file-input-v1","Channel"->channel,
  "SourceHash"->FileHash[workerFileSource,"SHA256"],"BaselineHash"->FileHash[workerFileBaseline,"SHA256"],
  "RawMapHash"->workerRawFileHash,"RawReceiptHash"->FileHash[workerFileReceiptPath,"SHA256"],
  "RawArrayHash"->workerRawArrayHash,"ParentBytes"->workerFileParentBytes,"ComponentCount"->workerRawCount,
  "DistributionSeconds"->compactDistributionSeconds,"Workers"->workerFileEvidence,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,"MathematicsChanged"->False|>;
 workerFileDirectory=FileNameJoin[{root,channel,"s08_worker_file_input_result"}];
 If[!DirectoryQ[workerFileDirectory],CreateDirectory[workerFileDirectory]];
 workerFileResultPath=FileNameJoin[{workerFileDirectory,"s08_result.wl"}];Put[workerFileResult,workerFileResultPath];
 gate["worker input evidence exact native export",Get[workerFileResultPath]===workerFileResult];
 Export[FileNameJoin[{workerFileDirectory,"s08_checks.json"}],<|"checks"->checks,
  "distribution_seconds"->compactDistributionSeconds,"parent_bytes"->workerFileParentBytes,
  "component_count"->workerRawCount,"workers"->workerFileEvidence|>,"RawJSON"];
 Print["PASS: s08_worker_file_input"];Quit[0]];

workerFileProofPath=FileNameJoin[{Directory[],Environment["POLARIZED_SIDIS_CHANNEL"],"s08_worker_file_input_result","s08_result.wl"}];
workerFileProofReceipt=Import[FileNameJoin[{DirectoryName[workerFileProofPath],"s08_execution.json"}],"RawJSON"];
workerFileProof=Get[workerFileProofPath];
If[!TrueQ[workerFileProofReceipt["passed"]]||
 workerFileProofReceipt["result_sha256"][Environment["POLARIZED_SIDIS_CHANNEL"]<>"/s08_worker_file_input_result/s08_result.wl"]=!=IntegerString[FileHash[workerFileProofPath,"SHA256"],16,64]||
 workerFileProof["SourceHash"]=!=FileHash[workerFileSource,"SHA256"]||!And@@Values[workerFileProof["Checks"]]||
 workerFileProof["RawMapHash"]=!=FileHash[FileNameJoin[{Directory[],Environment["POLARIZED_SIDIS_CHANNEL"],"s08_targets_result","s08_result.wl"}],"SHA256"],Quit[1]];
workerFileResultEdit="\nresult = <|"->"\nresult = <|\"WorkerInputDispatchHash\"->FileHash[workerFileSource,\"SHA256\"],\"WorkerInputEvidence\"->workerFileEvidence,";
If[StringCount[workerFileCandidate,First[workerFileResultEdit]]=!=1,Quit[1]];
workerFileProduction=StringReplace[workerFileCandidate,workerFileResultEdit];
If[!SyntaxQ[workerFileProduction]||StringReplace[workerFileProduction,Reverse[workerFileResultEdit]]=!=workerFileCandidate,Quit[1]];
workerFileEvidence={};
ToExpression[workerFileProduction,InputForm];

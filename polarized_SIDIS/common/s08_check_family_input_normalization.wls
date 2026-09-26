(* Compare a single family-input normalization with the accepted full scalar map. *)
$HistoryLength=0;
normalizationSource=FileNameJoin[{Directory[],"common","s08_check_family_input_normalization.wls"}];
normalizationBasePath=FileNameJoin[{Directory[],"common","s08_check_scalar_reconstruction_certificates.wls"}];
If[!SyntaxQ[Import[normalizationSource,"Text"]]||IntegerString[FileHash[normalizationBasePath,"SHA256"],16,64]=!=
 "af45a3609fbbeaa1417bb2022a7b562cf9f3597563a455d3e4302c32471468f1",Quit[1]];
normalizationBaseText=Import[normalizationBasePath,"Text"];
normalizationBegin=StringPosition[normalizationBaseText,"\ncertificateTerms="];
normalizationEnd=StringPosition[normalizationBaseText,"\ncertificateResult=<|"];
If[Length[normalizationBegin]=!=1||Length[normalizationEnd]=!=1,Quit[1]];
normalizationSetup=StringTake[normalizationBaseText,First[First[normalizationBegin]]-1];
normalizationComparison=StringTake[normalizationBaseText,{First[First[normalizationBegin]],First[First[normalizationEnd]]-1}];
If[!SyntaxQ[normalizationSetup]||!SyntaxQ[normalizationComparison],Quit[1]];
ToExpression[normalizationSetup,InputForm];
normalizationProofRelative="Hgg/s08_scalar_certificate_result/s08_result.wl";
normalizationProofPath=FileNameJoin[{root,normalizationProofRelative}];
normalizationReceiptPath=FileNameJoin[{DirectoryName[normalizationProofPath],"s08_execution.json"}];
normalizationReceipt=Import[normalizationReceiptPath,"RawJSON"];
gate["accepted original scalar-certificate execution",TrueQ[normalizationReceipt["passed"]]&&
 normalizationReceipt["result_sha256"][normalizationProofRelative]===IntegerString[FileHash[normalizationProofPath,"SHA256"],16,64]];
normalizationProof=Get[normalizationProofPath];
gate["identical accepted mapping and native input contract",TrueQ[normalizationProof["OwnAcceptedComparison"]]&&
 TrueQ[normalizationProof["ActualAcceptedComparison"]]&&And@@Values[normalizationProof["Checks"]]&&
 normalizationProof["SourceHash"]===FileHash[normalizationBasePath,"SHA256"]&&
 normalizationProof["InputHashes"]===record["InputHashes"]&&normalizationProof["TargetInputHash"]===record["TargetInputHash"]&&
 normalizationProof["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&
 normalizationProof["ActualGroupHash"]===FileHash[certificateGroupPath,"SHA256"]&&
 normalizationProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 normalizationProof["FamilyDefinitions"]===DownValues[familyRows]&&
 normalizationProof["MappingDefinitions"]===DownValues[mapExpression]];
normalizationOriginalMap=DownValues[mapExpression];
normalizationOriginalFamily=DownValues[familyRows];
normalizationEdit=
 "value = Cancel[prefactor coefficient/(Times @@ MapThread[Power, {denominators, indices}])];"->
 "value = prefactor coefficient/(Times @@ MapThread[Power, {denominators, indices}]);";
gate["unique preliminary family normalization",StringCount[certificateMapCandidate,First[normalizationEdit]]===1];
normalizationCandidateText=StringReplace[certificateMapCandidate,normalizationEdit];
gate["complete reversible mapping edit",SyntaxQ[normalizationCandidateText]&&
 StringReplace[normalizationCandidateText,Reverse[normalizationEdit]]===certificateMapCandidate];
gate["unchanged family begins with Together",StringCount[certificateFamilyCandidate,"rational=Together[expression];"]===1];

Print["NORMALIZATION_ORIGINAL_BEGIN"];
ToExpression[normalizationComparison,InputForm];
normalizationOriginalOwn=certificateOwnCoefficients;
normalizationOriginalActual=certificateActualCoefficients;
normalizationOriginalTimes=<|"OwnMapping"->Total[Lookup[certificatePackets,"Seconds"]],
 "OwnMerge"->certificateMergeSeconds,"ActualMapping"->certificateActualSeconds|>;
Print["NORMALIZATION_ORIGINAL_TIMES ",InputForm[normalizationOriginalTimes]];
ClearSystemCache[];
ToExpression[normalizationCandidateText,InputForm];
gate["family algebra unchanged",DownValues[familyRows]===normalizationOriginalFamily];
Print["NORMALIZATION_CANDIDATE_BEGIN"];
ToExpression[normalizationComparison,InputForm];
normalizationCandidateTimes=<|"OwnMapping"->Total[Lookup[certificatePackets,"Seconds"]],
 "OwnMerge"->certificateMergeSeconds,"ActualMapping"->certificateActualSeconds|>;
gate["fresh complete own original output reproduced",Sort[Keys[certificateOwnCoefficients]]===Sort[Keys[normalizationOriginalOwn]]&&
 And@@KeyValueMap[(#2===normalizationOriginalOwn[#1]||zero[#2-normalizationOriginalOwn[#1]])&,certificateOwnCoefficients]];
gate["fresh complete actual original output reproduced",Sort[Keys[certificateActualCoefficients]]===Sort[Keys[normalizationOriginalActual]]&&
 And@@KeyValueMap[(#2===normalizationOriginalActual[#1]||zero[#2-normalizationOriginalActual[#1]])&,certificateActualCoefficients]];
Print["NORMALIZATION_CANDIDATE_TIMES ",InputForm[normalizationCandidateTimes]];
normalizationSpeedup=Total[Values[normalizationCandidateTimes]]<Total[Values[normalizationOriginalTimes]];
normalizationResult=<|"Schema"->"polarized-sidis-family-input-normalization-v1","Channel"->channel,
 "SourceHash"->FileHash[normalizationSource,"SHA256"],"ComparisonSourceHash"->FileHash[normalizationBasePath,"SHA256"],
 "ProofHash"->FileHash[normalizationProofPath,"SHA256"],"ProofReceiptHash"->FileHash[normalizationReceiptPath,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],
 "ActualGroupFile"->StringDrop[certificateGroupPath,StringLength[root]+1],
 "ActualGroupHash"->FileHash[certificateGroupPath,"SHA256"],"ActualGroupBinding"->certificateGroupReference["Binding"],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "OriginalMappingDefinitions"->normalizationOriginalMap,"MappingDefinitions"->DownValues[mapExpression],
 "FamilyDefinitions"->DownValues[familyRows],"OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
 "OwnCoefficients"->certificateOwnCoefficients,"ActualCoefficients"->certificateActualCoefficients,
 "OriginalTimes"->normalizationOriginalTimes,"CandidateTimes"->normalizationCandidateTimes,
 "SpeedupObserved"->normalizationSpeedup,"PeakKernelMemoryBytes"->MaxMemoryUsed[],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
normalizationDirectory=FileNameJoin[{root,channel,"s08_family_normalization_result"}];
If[!DirectoryQ[normalizationDirectory],CreateDirectory[normalizationDirectory]];
saveNative[normalizationResult,FileNameJoin[{normalizationDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{normalizationDirectory,"s08_checks.json"}],<|"checks"->checks,
 "original_seconds"->normalizationOriginalTimes,"candidate_seconds"->normalizationCandidateTimes,
 "speedup_observed"->normalizationSpeedup,"peak_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_family_input_normalization"];Quit[0];


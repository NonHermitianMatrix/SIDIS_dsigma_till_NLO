(* Reuse identical loop-monomial substitutions; retain the accepted coefficient algebra. *)
$HistoryLength=0;
reuseSource=FileNameJoin[{Directory[],"common","s08_check_monomial_substitution_reuse.wls"}];
reuseBasePath=FileNameJoin[{Directory[],"common","s08_check_scalar_reconstruction_certificates.wls"}];
If[!SyntaxQ[Import[reuseSource,"Text"]]||IntegerString[FileHash[reuseBasePath,"SHA256"],16,64]=!=
 "af45a3609fbbeaa1417bb2022a7b562cf9f3597563a455d3e4302c32471468f1",Quit[1]];
reuseBaseText=Import[reuseBasePath,"Text"];
reuseBegin=StringPosition[reuseBaseText,"\ncertificateTerms="];
reuseEnd=StringPosition[reuseBaseText,"\ncertificateResult=<|"];
If[Length[reuseBegin]=!=1||Length[reuseEnd]=!=1,Quit[1]];
reuseSetup=StringTake[reuseBaseText,First[First[reuseBegin]]-1];
reuseComparison=StringTake[reuseBaseText,{First[First[reuseBegin]],First[First[reuseEnd]]-1}];
If[!SyntaxQ[reuseSetup]||!SyntaxQ[reuseComparison],Quit[1]];
ToExpression[reuseSetup,InputForm];

reuseBaselineRelative="Hgg/s08_scalar_certificate_result/s08_result.wl";
reuseBaselinePath=FileNameJoin[{root,reuseBaselineRelative}];
reuseBaselineReceiptPath=FileNameJoin[{DirectoryName[reuseBaselinePath],"s08_execution.json"}];
reuseBaselineReceipt=Import[reuseBaselineReceiptPath,"RawJSON"];
gate["accepted scalar-certificate baseline",TrueQ[reuseBaselineReceipt["passed"]]&&
 reuseBaselineReceipt["result_sha256"][reuseBaselineRelative]===IntegerString[FileHash[reuseBaselinePath,"SHA256"],16,64]];
reuseBaseline=Get[reuseBaselinePath];
gate["same complete baseline implementation and inputs",TrueQ[reuseBaseline["OwnAcceptedComparison"]]&&
 TrueQ[reuseBaseline["ActualAcceptedComparison"]]&&And@@Values[reuseBaseline["Checks"]]&&
 reuseBaseline["SourceHash"]===FileHash[reuseBasePath,"SHA256"]&&
 reuseBaseline["InputHashes"]===record["InputHashes"]&&reuseBaseline["TargetInputHash"]===record["TargetInputHash"]&&
 reuseBaseline["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&
 reuseBaseline["ActualGroupHash"]===FileHash[certificateGroupPath,"SHA256"]&&
 reuseBaseline["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 reuseBaseline["FamilyDefinitions"]===DownValues[familyRows]&&
 reuseBaseline["MappingDefinitions"]===DownValues[mapExpression]];
reuseOriginalFamily=DownValues[familyRows];
reuseOriginalMapping=DownValues[mapExpression];
reuseRuleCache=<||>;reuseRuleHits=0;reuseRuleMisses=0;reuseRuleSeconds=0.;
reuseMonomialRules[expression_,variables_List]:=Module[{key,rows,seconds},
 key=HoldComplete[expression,variables];
 If[KeyExistsQ[reuseRuleCache,key],reuseRuleHits++;Return[reuseRuleCache[key]]];
 reuseRuleMisses++;
 {seconds,rows}=AbsoluteTiming[CoefficientRules[Expand[expression],variables]];
 reuseRuleSeconds+=seconds;
 AssociateTo[reuseRuleCache,key->rows];rows];
reuseEdit="shiftRules=CoefficientRules[Expand[shifted],polynomialVariables];"->
 "shiftRules=reuseMonomialRules[shifted,polynomialVariables];";
gate["unique repeated substitution call",StringCount[certificateFamilyCandidate,First[reuseEdit]]===1];
reuseFamilyText=StringReplace[certificateFamilyCandidate,reuseEdit];
gate["all coefficient algebra and checks retained",SyntaxQ[reuseFamilyText]&&
 StringReplace[reuseFamilyText,Reverse[reuseEdit]]===certificateFamilyCandidate];
ToExpression[reuseFamilyText,InputForm];

(* Run the unchanged complete own-map and actual production-group comparisons. *)
ToExpression[reuseComparison,InputForm];
gate["scalar mapping definition unchanged",DownValues[mapExpression]===reuseOriginalMapping];
gate["cache inventory matches evaluated substitutions",Length[reuseRuleCache]===reuseRuleMisses];
reuseResult=<|"Schema"->"polarized-sidis-monomial-substitution-reuse-v1","Channel"->channel,
 "SourceHash"->FileHash[reuseSource,"SHA256"],"ComparisonSourceHash"->FileHash[reuseBasePath,"SHA256"],
 "BaselineHash"->FileHash[reuseBaselinePath,"SHA256"],"BaselineReceiptHash"->FileHash[reuseBaselineReceiptPath,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],
 "ActualGroupFile"->StringDrop[certificateGroupPath,StringLength[root]+1],
 "ActualGroupHash"->FileHash[certificateGroupPath,"SHA256"],"ActualGroupBinding"->certificateGroupReference["Binding"],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "OriginalFamilyDefinitions"->reuseOriginalFamily,"FamilyDefinitions"->DownValues[familyRows],
 "ReuseDefinitions"->DownValues[reuseMonomialRules],"MappingDefinitions"->DownValues[mapExpression],
 "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
 "OwnCoefficients"->certificateOwnCoefficients,"ActualCoefficients"->certificateActualCoefficients,
 "OwnMappingSeconds"->Total[Lookup[certificatePackets,"Seconds"]],"OwnMergeSeconds"->certificateMergeSeconds,
 "ActualMappingSeconds"->certificateActualSeconds,
 "BaselineOwnMappingSeconds"->reuseBaseline["OwnMappingSeconds"],
 "BaselineOwnMergeSeconds"->reuseBaseline["OwnMergeSeconds"],
 "BaselineActualMappingSeconds"->reuseBaseline["ActualMappingSeconds"],
 "CacheHits"->reuseRuleHits,"CacheMisses"->reuseRuleMisses,"CacheBytes"->ByteCount[reuseRuleCache],
 "UniqueSubstitutionSeconds"->reuseRuleSeconds,"PeakKernelMemoryBytes"->MaxMemoryUsed[],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
reuseDirectory=FileNameJoin[{root,channel,"s08_monomial_reuse_result"}];
If[!DirectoryQ[reuseDirectory],CreateDirectory[reuseDirectory]];
saveNative[reuseResult,FileNameJoin[{reuseDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{reuseDirectory,"s08_checks.json"}],<|"checks"->checks,
 "own_mapping_seconds"->reuseResult["OwnMappingSeconds"],"own_merge_seconds"->certificateMergeSeconds,
 "actual_seconds"->certificateActualSeconds,
 "baseline_own_mapping_seconds"->reuseResult["BaselineOwnMappingSeconds"],
 "baseline_actual_seconds"->reuseResult["BaselineActualMappingSeconds"],
 "cache_hits"->reuseRuleHits,"cache_misses"->reuseRuleMisses,"cache_bytes"->ByteCount[reuseRuleCache],
 "unique_substitution_seconds"->reuseRuleSeconds,"peak_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_monomial_substitution_reuse"];Quit[0];

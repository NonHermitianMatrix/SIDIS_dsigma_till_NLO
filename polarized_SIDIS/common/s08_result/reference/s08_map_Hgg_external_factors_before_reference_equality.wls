(* Install the independently compared external-factor map for unfinished Hgg groups. *)
$HistoryLength=0;
externalConsumerSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_external_factors.wls"}];
externalConsumerBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_other_group_components.wls"}];
If[!SyntaxQ[Import[externalConsumerSource,"Text"]]||IntegerString[FileHash[externalConsumerBase,"SHA256"],16,64]=!=
 "3e6e4453f904c177ec222586c5205e86dd5b7d458cb01b5f4d3be7cb1aacc939",Quit[1]];
externalInstall[]:=Module[{relative,path,receipt,proof,comparison,variables,definitions},
 relative="Hgg/s08_external_factor_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 comparison=FileNameJoin[{root,"common","s08_check_external_factor_mapping.wls"}];
 gate["accepted external-factor execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_external_factor_mapping.wls"]===IntegerString[FileHash[comparison,"SHA256"],16,64]];
 proof=Get[path];
 gate["same complete external-factor comparison contract",
  proof["Schema"]==="polarized-sidis-external-factor-map-comparison-v1"&&proof["Channel"]===channel&&
  proof["SourceHash"]===FileHash[comparison,"SHA256"]&&TrueQ[proof["OwnAcceptedComparison"]]&&
  TrueQ[proof["ActualAcceptedComparison"]]&&Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["NativeInputHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}],"SHA256"]&&
  proof["NativeInputReceiptHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_recovery_execution.json"}],"SHA256"]&&
  proof["ActualGroupHash"]===FileHash[FileNameJoin[{root,proof["ActualGroupFile"]}],"SHA256"]];
 gate["external-factor comparison measured an actual improvement",TrueQ[proof["SpeedupObserved"]]&&
  proof["CandidateActualSeconds"]<proof["OriginalActualSeconds"]];
 gate["exact live original mapping family and merge",{DownValues[mapExpression],DownValues[familyRows],DownValues[merge]}===
  Lookup[proof,{"OriginalMappingDefinitions","FamilyDefinitions","MergeDefinitions"}]];
 variables=First/@families[First[familyNames]]["UncutCoordinateRules"];
 gate["same actual native external-factor coordinates",variables===atomVariables&&variables===proof["Variables"]];
 externalVariables=variables;externalEvidence={};externalFallbackCount=0;
 DownValues[externalAtomCompatible]=proof["CompatibilityDefinitions"];
 DownValues[externalSplit]=proof["SplitDefinitions"];
 DownValues[externalFactorMap]=proof["FactorMappingDefinitions"];
 DownValues[externalOriginalMap]=proof["OriginalAliasDefinitions"];
 DownValues[mapExpression]=proof["MappingDefinitions"];
 definitions={DownValues[externalSplit],DownValues[externalFactorMap],DownValues[externalOriginalMap],DownValues[mapExpression],DownValues[externalAtomCompatible]};
 gate["exact compared external-factor definitions installed",definitions===
  Lookup[proof,{"SplitDefinitions","FactorMappingDefinitions","OriginalAliasDefinitions","MappingDefinitions","CompatibilityDefinitions"}]];
 AssociateTo[hggPolynomialEvidence,"ExternalFactors"-><|"ConsumerSourceHash"->FileHash[externalConsumerSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
  "OriginalActualSeconds"->proof["OriginalActualSeconds"],"CandidateActualSeconds"->proof["CandidateActualSeconds"]|>];
 Print["EXTERNAL_FACTOR_PRODUCTION_INSTALLED"]];
externalConsumerText=StringTrim[Import[externalConsumerBase,"Text"]];
externalConsumerTerminal="ToExpression[coordinateRun,InputForm];";
If[!StringEndsQ[externalConsumerText,externalConsumerTerminal],Quit[1]];
externalConsumerPrefix=StringDrop[externalConsumerText,-StringLength[externalConsumerTerminal]];
If[!SyntaxQ[externalConsumerPrefix],Quit[1]];ToExpression[externalConsumerPrefix,InputForm];
externalOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[externalOriginalTail]=externalOriginalTailDefinitions/.coordinateTail->externalOriginalTail;
If[(DownValues[externalOriginalTail]/.externalOriginalTail->coordinateTail)=!=externalOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=externalOriginalTail[text]},
 gate["direct worker functions do not use obsolete group library",
  FreeQ[{DownValues[groupDenominators],DownValues[groupedMapExpression],
   DownValues[hggPhaseMap],DownValues[numericPhaseMap]},
   HoldPattern[hggFactoredGroups[___]]|HoldPattern[hggAcceptedGroups]]];
 Print["WORKER_LIBRARY_OMITTED_BYTES ",ByteCount[hggAcceptedGroups]];
 changed=coordinateReplace[changed,
  "hggOriginalGrouping,hggFactoredGroups,hggAcceptedGroups,hggPhaseMap,",
  "hggOriginalGrouping,hggPhaseMap,"];
 changed=coordinateReplace[changed,"DistributeDefinitions[hggComponentBound,",
  "DistributeDefinitions[externalSplit,externalAtomCompatible,externalFallbackCount,externalFactorMap,externalOriginalMap,externalVariables,externalEvidence,hggComponentBound,"];
 changed=coordinateReplace[changed,"  Clear[hggCachedKey, hggCachedValue];",
  "  externalDistributionStart=AbsoluteTime[]; Print[\"WORKER_DISTRIBUTION_START\"]; Clear[hggCachedKey, hggCachedValue];"];
 changed=coordinateReplace[changed,"$DistributedContexts = None;",
  "$DistributedContexts = None; If[workers>0, gate[\"obsolete group library absent on every worker\", And@@ParallelEvaluate[OwnValues[hggAcceptedGroups]==={}&&DownValues[hggFactoredGroups]==={}]]; Print[\"WORKER_DISTRIBUTION_SECONDS \",AbsoluteTime[]-externalDistributionStart]];"];
 changed];
externalConsumerEdits={
 "compactResumeInstall[];directGroupingInstall[];"->"compactResumeInstall[];directGroupingInstall[];externalInstall[];"};
If[!And@@(StringCount[coordinateRun,First[#]]===1&/@externalConsumerEdits),
 Print["FAIL: unique external-factor production handoffs"];Quit[1]];
externalConsumerRun=StringReplace[coordinateRun,externalConsumerEdits];
If[!SyntaxQ[externalConsumerRun]||StringReplace[externalConsumerRun,Reverse/@externalConsumerEdits]=!=coordinateRun,
 Print["FAIL: unchanged remaining-component production pipeline"];Quit[1]];
ToExpression[externalConsumerRun,InputForm];

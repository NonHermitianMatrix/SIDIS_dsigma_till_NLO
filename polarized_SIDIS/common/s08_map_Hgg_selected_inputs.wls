(* Install the independently compared external-factor map for unfinished Hgg groups. *)
$HistoryLength=0;
externalConsumerSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_selected_inputs.wls"}];
externalConsumerBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_other_group_components.wls"}];
If[!SyntaxQ[Import[externalConsumerSource,"Text"]]||IntegerString[FileHash[externalConsumerBase,"SHA256"],16,64]=!=
 "3e6e4453f904c177ec222586c5205e86dd5b7d458cb01b5f4d3be7cb1aacc939",Quit[1]];
selectedEntryInstall[]:=Module[{relative,path,receipt,proof,producer,original,alias},
 relative="Hgg/s08_selected_entry_read_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_selected_entry_read.wls"}];
 gate["accepted selected-entry execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_selected_entry_read.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];
 gate["same selected-entry input and serialization contract",
  proof["Schema"]==="polarized-sidis-selected-entry-cluster-reader-v1"&&proof["Channel"]===channel&&
  proof["SourceHash"]===FileHash[producer,"SHA256"]&&TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["SpeedupObserved"]]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["SelectedSourceHash"]===FileHash[FileNameJoin[{root,"misc","s06_map_Hgg_local.wls"}],"SHA256"]&&
  proof["ComponentSourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hgg_component_inputs.wls"}],"SHA256"]&&
  proof["MetadataHash"]===FileHash[FileNameJoin[{root,"Hgg","s05_result","s05_metadata.wl"}],"SHA256"]&&
  proof["NativeInputHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}],"SHA256"]&&
  proof["ResponseReaderProofHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_response_read_result","s08_result.wl"}],"SHA256"]&&
  proof["OwnHash"]===FileHash[FileNameJoin[{root,proof["OwnFile"]}],"SHA256"]&&
  proof["OwnManifestHash"]===FileHash[FileNameJoin[{root,DirectoryName[proof["OwnFile"]],"s05_payload_manifest.json"}],"SHA256"]&&
  proof["OwnReceiptHash"]===FileHash[FileNameJoin[{root,DirectoryName[proof["OwnFile"]],"s05_execution.json"}],"SHA256"]&&
  proof["TaskInventoryHash"]===Hash[{hggTaskMetadata,hggTaskSources},"SHA256"]];
 original=DownValues[hggTaskValue];
 gate["same entire live reader and fallback",original===proof["OriginalTaskDefinitions"]&&
  DownValues[responseOnlyRead]===proof["ResponseReaderDefinitions"]&&
  DownValues[hggResponseNativeGet]===proof["ResponseDispatchDefinitions"]];
 alias=original/.hggTaskValue->selectedOriginalTaskValue;
 gate["unchanged complete fallback reader",(alias/.selectedOriginalTaskValue->hggTaskValue)===original];
 DownValues[selectedOriginalTaskValue]=alias;
 importedNativeVersions=proof["NativeVersions"];localRoot=root;
 DownValues[hggTaskValue]=proof["CandidateTaskDefinitions"];
 gate["exact compared selected-entry reader installed",DownValues[hggTaskValue]===proof["CandidateTaskDefinitions"]&&
  DownValues[selectedOriginalTaskValue]===alias];
 AssociateTo[hggPolynomialEvidence,"SelectedEntryRead"-><|"ConsumerSourceHash"->FileHash[externalConsumerSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"OriginalSeconds"->proof["OriginalReadSeconds"],"SelectedSeconds"->proof["SelectedReadSeconds"],
  "OriginalRetainedBytes"->proof["OriginalRetainedBytes"],"SelectedRetainedBytes"->proof["SelectedRetainedBytes"]|>];
 Print["SELECTED_ENTRY_READER_INSTALLED"]];
sharedCacheInstall[]:=Module[{relative,path,receipt,packet,producer},
 relative="Hgg/s08_shared_piece_cache_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_shared_piece_cache.wls"}];
 gate["accepted shared-piece comparison",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_shared_piece_cache.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 packet=Get[path];
 gate["same complete shared-piece input and algebra contract",
  packet["Schema"]==="polarized-sidis-shared-piece-cache-v1"&&packet["Channel"]===channel&&
  packet["SourceHash"]===FileHash[producer,"SHA256"]&&packet["InputHashes"]===inputHashes&&
  packet["TargetInputHash"]===targetInputHash&&packet["PieceScientificHash"]===pieceScientificHash&&
  packet["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[packet["OwnAcceptedComparison"]]&&TrueQ[packet["SpeedupObserved"]]&&
  Length[packet["Checks"]]>0&&And@@Values[packet["Checks"]]&&
  packet["PolynomialProofHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_polynomial_group_result","s08_result.wl"}],"SHA256"]&&
  packet["ExternalProofHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_external_factor_result","s08_result.wl"}],"SHA256"]&&
  packet["OriginalPieceDefinitions"]===DownValues[polynomialPieceMap]&&
  packet["AlgebraDefinitions"]==={DownValues[mapExpression],DownValues[familyRows],DownValues[merge],
   DownValues[polynomialAdditivePieces],DownValues[certifyGroupMerge]}];
 DownValues[sharedPieceValid]=packet["ValidityDefinitions"];
 DownValues[sharedReadPiece]=packet["ReadDefinitions"];
 DownValues[polynomialPieceMap]=packet["CandidatePieceDefinitions"];sharedPieceHits={};
 gate["exact compared shared-piece reader installed",{DownValues[sharedPieceValid],DownValues[sharedReadPiece],
  DownValues[polynomialPieceMap]}===Lookup[packet,{"ValidityDefinitions","ReadDefinitions","CandidatePieceDefinitions"}]];
 AssociateTo[hggPolynomialEvidence,"SharedPieceCache"-><|"ProofHash"->FileHash[path,"SHA256"],
  "ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "SourceHash"->FileHash[producer,"SHA256"],"OwnAcceptedComparison"->True,
  "FreshSeconds"->packet["FreshSeconds"],"CachedSeconds"->packet["CachedSeconds"]|>];
 Print["SHARED_PIECE_CACHE_INSTALLED"]];
externalInstall[]:=Module[{relative,path,receipt,proof,comparison,variables,definitions,
 referenceRelative,referencePath,referenceReceipt,referenceProof},
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
 referenceRelative="Hgg/s08_reference_map_comparison_result/s08_result.wl";
 referencePath=FileNameJoin[{root,referenceRelative}];
 referenceReceipt=Import[FileNameJoin[{DirectoryName[referencePath],"s08_execution.json"}],"RawJSON"];
 gate["accepted complete fresh-reference comparison",TrueQ[referenceReceipt["passed"]]&&
  referenceReceipt["result_sha256"][referenceRelative]===IntegerString[FileHash[referencePath,"SHA256"],16,64]];
 referenceProof=Get[referencePath];
 gate["same exact fresh-reference comparison inputs and algorithm",
  referenceProof["Schema"]==="polarized-sidis-reference-map-comparison-v1"&&
  referenceProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_reference_map.wls"}],"SHA256"]&&
  referenceProof["ProofHash"]===FileHash[path,"SHA256"]&&referenceProof["FixtureHash"]===FileHash[targetFixturePath,"SHA256"]&&
  referenceProof["InputHashes"]===inputHashes&&referenceProof["TargetInputHash"]===targetInputHash&&
  referenceProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[referenceProof["SameKeys"]]&&TrueQ[referenceProof["ExactEquality"]]&&And@@Values[referenceProof["Checks"]]];
 AssociateTo[hggPolynomialEvidence,"ExternalFactors"-><|"ConsumerSourceHash"->FileHash[externalConsumerSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "FreshReferenceComparisonHash"->FileHash[referencePath,"SHA256"],
  "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
  "OriginalActualSeconds"->proof["OriginalActualSeconds"],"CandidateActualSeconds"->proof["CandidateActualSeconds"]|>];
 sharedCacheInstall[];selectedEntryInstall[];
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
 changed=coordinateReplace[changed,
  "gate[\"fresh worker reproduces entire reference map\", value === targetFixture[\"Coefficients\"]];",
  "gate[\"fresh worker reproduces entire reference map\", AssociationQ[value] && Sort[Keys[value]] === Sort[Keys[targetFixture[\"Coefficients\"]]] && And @@ KeyValueMap[(#2 === targetFixture[\"Coefficients\"][#1] || bounded[zero[#2 - targetFixture[\"Coefficients\"][#1]], {\"complete fresh-reference coefficient\", #1}]) &, value]];"];
 gate["direct worker functions do not use obsolete group library",
  FreeQ[{DownValues[groupDenominators],DownValues[groupedMapExpression],
   DownValues[hggPhaseMap],DownValues[numericPhaseMap]},
   HoldPattern[hggFactoredGroups[___]]|HoldPattern[hggAcceptedGroups]]];
 Print["WORKER_LIBRARY_OMITTED_BYTES ",ByteCount[hggAcceptedGroups]];
 changed=coordinateReplace[changed,
  "hggOriginalGrouping,hggFactoredGroups,hggAcceptedGroups,hggPhaseMap,",
  "hggOriginalGrouping,hggPhaseMap,"];
 changed=coordinateReplace[changed,"DistributeDefinitions[hggComponentBound,",
  "DistributeDefinitions[selectedOriginalTaskValue,importedNativeVersions,localRoot,localStoredEntry,sharedPieceValid,sharedReadPiece,sharedPieceHits,externalSplit,externalAtomCompatible,externalFallbackCount,externalFactorMap,externalOriginalMap,externalVariables,externalEvidence,hggComponentBound,"];
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

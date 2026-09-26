(* Reuse accepted grouped-mapping algorithms on the complete own Hqg control. *)
$HistoryLength=0;
ownGroupedSource=FileNameJoin[{Directory[],"common","s08_check_Hqg_grouped_mapping.wls"}];
ownGroupedBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_target_packets.wls"}];
If[IntegerString[FileHash[ownGroupedBase,"SHA256"],16,64]=!=
 "2be9cfe584e8b1714827d89db0e75c542a31a96bf8e1b413bb767324a61551a4"||
 !SyntaxQ[Import[ownGroupedSource,"Text"]],Quit[1]];
ownGroupedText=Import[ownGroupedBase,"Text"];
ownGroupedBoundary=StringPosition[ownGroupedText,"\nslots ="];
If[Length[ownGroupedBoundary]=!=1,Quit[1]];
ownGroupedPrefix=StringTake[ownGroupedText,First[First[ownGroupedBoundary]]-1];
If[!SyntaxQ[ownGroupedPrefix],Quit[1]];ToExpression[ownGroupedPrefix,InputForm];
gate["own grouped comparison is Hqg",channel==="Hqg"];
ownGroupedProofRelative="Hgq/s08_certified_denominator_result/s08_result.wl";
ownGroupedProofPath=FileNameJoin[{root,ownGroupedProofRelative}];
ownGroupedReceiptPath=FileNameJoin[{DirectoryName[ownGroupedProofPath],"s08_execution.json"}];
ownGroupedReceipt=Import[ownGroupedReceiptPath,"RawJSON"];
gate["accepted grouped algorithm receipt",TrueQ[ownGroupedReceipt["passed"]]&&
 ownGroupedReceipt["result_sha256"][ownGroupedProofRelative]===IntegerString[FileHash[ownGroupedProofPath,"SHA256"],16,64]];
ownGroupedProof=Get[ownGroupedProofPath];
gate["complete accepted grouped algorithm and common inputs",
 ownGroupedProof["Channel"]==="Hgq"&&ownGroupedProof["Schema"]==="polarized-sidis-certified-denominator-comparison-v1"&&
 And@@Values[ownGroupedProof["Checks"]]&&And@@Lookup[ownGroupedProof["Components"],"ReconstructionPassed"]&&
 And@@Flatten[Values[#["Checks"]]&/@ownGroupedProof["Components"]]&&TrueQ[First[ownGroupedProof["Components"]]["OwnAcceptedComparison"]]&&
 ownGroupedProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&
 ownGroupedProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_certified_denominator_mapping.wls"}],"SHA256"]&&
 ownGroupedProof["ConfigurationHash"]===FileHash[FileNameJoin[{root,"common","s08_certified_denominator_inputs.json"}],"SHA256"]&&
 KeyDrop[ownGroupedProof["InputHashes"],"Hgq/s05_result/s05_result.wl"]===KeyDrop[inputHashes,"Hqg/s05_result/s05_result.wl"]];
gate["same original native mapper and merge",ownGroupedProof["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
 ownGroupedProof["OriginalMergeDefinitions"]===DownValues[merge]];
DownValues[groupDenominators]=ownGroupedProof["GroupingDefinitions"];
DownValues[certifyGrouping]=ownGroupedProof["GroupingCertificateDefinitions"];
DownValues[certifyPairMerge]=ownGroupedProof["MergeCertificateDefinitions"];
DownValues[certifyGroupMerge]=ownGroupedProof["GroupMergeDefinitions"];
DownValues[pairReconstruct]=ownGroupedProof["ReconstructionDefinitions"];
DownValues[groupedMapExpression]=ownGroupedProof["MappingDefinitions"];
gate["exact installed grouping and reconstruction definitions",{
 DownValues[groupDenominators],DownValues[certifyGrouping],DownValues[certifyPairMerge],
 DownValues[certifyGroupMerge],DownValues[pairReconstruct],DownValues[groupedMapExpression]}===
 Lookup[ownGroupedProof,{"GroupingDefinitions","GroupingCertificateDefinitions","MergeCertificateDefinitions",
 "GroupMergeDefinitions","ReconstructionDefinitions","MappingDefinitions"}]];
ownControlRelative=Environment["POLARIZED_SIDIS_OWN_TARGET_FILE"];
ownControlPath=FileNameJoin[{root,ownControlRelative}];
gate["pinned actual own target control",StringQ[ownControlRelative]&&
 IntegerString[FileHash[ownControlPath,"SHA256"],16,64]===Environment["POLARIZED_SIDIS_OWN_TARGET_SHA256"]];
ownControl=Get[ownControlPath];
ownIndices=Select[Range[Length[tasks]],KeyDrop[tasks[[#]],"Value"]===KeyTake[ownControl,{"Sector","Kind","Index"}]&];
gate["own control exact target identity",Length[ownIndices]===1&&ownControl["InputHash"]===targetInputHash&&
 TrueQ[ownControl["ReconstructionPassed"]]&&And@@Values[ownControl["Checks"]]];
ownIndex=First[ownIndices];ownTask=tasks[[ownIndex]];ownExpression=ownTask["Value"]/.coordinateRules;
Clear[spin,sector,tasks];ClearSystemCache[];
groupInputHash=Hash[{FileHash[ownGroupedSource,"SHA256"],FileHash[ownGroupedProofPath,"SHA256"],
 inputHashes,targetInputHash,FileHash[ownControlPath,"SHA256"],$Version,$FeynCalcVersion},"SHA256"];
groupCache=FileNameJoin[{root,"cache","s08_Hqg_grouped_comparison",IntegerString[groupInputHash,16]}];
If[!DirectoryQ[groupCache],CreateDirectory[groupCache,CreateIntermediateDirectories->True]];
Print["OWN_GROUPED_INPUT ",InputForm[<|"Index"->ownIndex,"Task"->KeyDrop[ownTask,"Value"],
 "Bytes"->ByteCount[ownExpression],"Denominators"->denominators,"FirstNativeTerm"->If[Head[ownExpression]===Plus,First[ownExpression],ownExpression]|>]];
{ownSeconds,ownCoefficients}=AbsoluteTiming[groupedMapExpression[ownExpression,"component_"<>ToString[ownIndex]]];
{ownEqualitySeconds,ownEqual}=AbsoluteTiming[ownCoefficients===ownControl["Coefficients"]||bounded[
 zero[pairReconstruct[ownCoefficients]-pairReconstruct[ownControl["Coefficients"]]],"complete own Hqg map comparison"]];
gate["entire accepted own Hqg map reproduced",ownEqual];
ownResult=<|"Schema"->"polarized-sidis-Hqg-grouped-comparison-v1","Channel"->channel,"Accepted"->True,
 "SourceHash"->FileHash[ownGroupedSource,"SHA256"],"AlgorithmProofHash"->FileHash[ownGroupedProofPath,"SHA256"],
 "ControlFile"->ownControlRelative,"ControlHash"->FileHash[ownControlPath,"SHA256"],
 "ComponentIndex"->ownIndex,"Task"->ownTask,"ActualExpression"->ownExpression,"Denominators"->denominators,
 "InputHashes"->inputHashes,"InputHash"->groupInputHash,"TargetInputHash"->targetInputHash,"MappingInputHash"->inputHash,
 "NativeVersions"->{$Version,$FeynCalcVersion},"Coefficients"->ownCoefficients,"OwnAcceptedComparison"->ownEqual,
 "OriginalSeconds"->ownControl["Seconds"],"CandidateSeconds"->ownSeconds,"EqualitySeconds"->ownEqualitySeconds,
 "AlgorithmDefinitions"->KeyTake[ownGroupedProof,{"OriginalMappingDefinitions","OriginalMergeDefinitions","GroupingDefinitions",
 "GroupingCertificateDefinitions","MergeCertificateDefinitions","GroupMergeDefinitions","ReconstructionDefinitions","MappingDefinitions"}],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
ownDirectory=FileNameJoin[{root,channel,"s08_grouped_comparison_result"}];
If[!DirectoryQ[ownDirectory],CreateDirectory[ownDirectory,CreateIntermediateDirectories->True]];
ownResultPath=FileNameJoin[{ownDirectory,"s08_result.wl"}];
ownSerialized="Uncompress["<>ToString[bounded[Compress[ownResult],"own comparison compression"],InputForm]<>"]\n";
gate["bounded own comparison export",StringLength[ownSerialized]<128*1024^2];
Export[ownResultPath<>".tmp",ownSerialized,"Text"];
gate["exact own comparison native reload",Get[ownResultPath<>".tmp"]===ownResult];
RenameFile[ownResultPath<>".tmp",ownResultPath,OverwriteTarget->True];
Export[FileNameJoin[{ownDirectory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,
 "original_seconds"->ownControl["Seconds"],"candidate_seconds"->ownSeconds,"equality_seconds"->ownEqualitySeconds,
 "own_complete_comparison"->ownEqual,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_check_Hqg_grouped_mapping"];Quit[0];

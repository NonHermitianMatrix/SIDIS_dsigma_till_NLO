(* Use the accepted denominator-group algorithm after an exact own Hgg comparison. *)
$HistoryLength=0;
hggGroupedSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_grouped_inputs.wls"}];
hggGroupedBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_bounded_reads.wls"}];
If[IntegerString[FileHash[hggGroupedBase,"SHA256"],16,64]=!=
 "97360f5dc30672b79e763c3623c8761600bcbf58fb214825ee9eefd6f572d7e0"||
 !SyntaxQ[Import[hggGroupedSource,"Text"]],Quit[1]];
hggGroupedBaseText=StringTrim[Import[hggGroupedBase,"Text"]];
hggGroupedTerminal="ToExpression[hggRunText,InputForm];";
If[!StringEndsQ[hggGroupedBaseText,hggGroupedTerminal],Quit[1]];
hggGroupedBasePrefix=StringDrop[hggGroupedBaseText,-StringLength[hggGroupedTerminal]];
If[!SyntaxQ[hggGroupedBasePrefix],Quit[1]];ToExpression[hggGroupedBasePrefix,InputForm];
If[hggMode=!= "targets",Quit[1]];
hggGroupedBoundary=StringPosition[hggRunText,"\nslots ="];
If[Length[hggGroupedBoundary]=!=1,Quit[1]];
hggGroupedPrefix=StringTake[hggRunText,First[First[hggGroupedBoundary]]-1];
If[!SyntaxQ[hggGroupedPrefix],Quit[1]];ToExpression[hggGroupedPrefix,InputForm];
gate["own grouped comparison is Hgg",channel==="Hgg"];
hggAlgorithmRelative="Hgq/s08_certified_denominator_result/s08_result.wl";
hggAlgorithmPath=FileNameJoin[{root,hggAlgorithmRelative}];
hggAlgorithmReceiptPath=FileNameJoin[{DirectoryName[hggAlgorithmPath],"s08_execution.json"}];
hggAlgorithmReceipt=Import[hggAlgorithmReceiptPath,"RawJSON"];
gate["accepted grouped algorithm receipt",TrueQ[hggAlgorithmReceipt["passed"]]&&
 hggAlgorithmReceipt["result_sha256"][hggAlgorithmRelative]===IntegerString[FileHash[hggAlgorithmPath,"SHA256"],16,64]];
hggAlgorithm=Get[hggAlgorithmPath];
gate["accepted grouped algorithm and identical scalar inputs",
 hggAlgorithm["Channel"]==="Hgq"&&hggAlgorithm["Schema"]==="polarized-sidis-certified-denominator-comparison-v1"&&
 And@@Values[hggAlgorithm["Checks"]]&&And@@Lookup[hggAlgorithm["Components"],"ReconstructionPassed"]&&
 And@@Flatten[Values[#["Checks"]]&/@hggAlgorithm["Components"]]&&TrueQ[First[hggAlgorithm["Components"]]["OwnAcceptedComparison"]]&&
 hggAlgorithm["NativeVersions"]==={$Version,$FeynCalcVersion}&&
 hggAlgorithm["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_certified_denominator_mapping.wls"}],"SHA256"]&&
 hggAlgorithm["ConfigurationHash"]===FileHash[FileNameJoin[{root,"common","s08_certified_denominator_inputs.json"}],"SHA256"]&&
 KeyDrop[hggAlgorithm["InputHashes"],"Hgq/s05_result/s05_result.wl"]===KeyDrop[inputHashes,"Hgg/s05_result/s05_result.wl"]];
gate["same original mapping and merge definitions",hggAlgorithm["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
 hggAlgorithm["OriginalMergeDefinitions"]===DownValues[merge]];
DownValues[groupDenominators]=hggAlgorithm["GroupingDefinitions"];
DownValues[certifyGrouping]=hggAlgorithm["GroupingCertificateDefinitions"];
DownValues[certifyPairMerge]=hggAlgorithm["MergeCertificateDefinitions"];
DownValues[certifyGroupMerge]=hggAlgorithm["GroupMergeDefinitions"];
DownValues[pairReconstruct]=hggAlgorithm["ReconstructionDefinitions"];
DownValues[groupedMapExpression]=hggAlgorithm["MappingDefinitions"];
gate["exact accepted grouping definitions installed",{
 DownValues[groupDenominators],DownValues[certifyGrouping],DownValues[certifyPairMerge],
 DownValues[certifyGroupMerge],DownValues[pairReconstruct],DownValues[groupedMapExpression]}===
 Lookup[hggAlgorithm,{"GroupingDefinitions","GroupingCertificateDefinitions","MergeCertificateDefinitions",
 "GroupMergeDefinitions","ReconstructionDefinitions","MappingDefinitions"}]];
hggOwnIndices=Select[Range[Length[tasks]],hggTaskSources[[#]]["Payload"]===First[hggTaskSources]["Payload"]&&
 hggTaskSources[[#]]["Field"]==="Response"&];
gate["own accepted nonzero response inventory",hggOwnIndices=!={}];
hggOwnSizes=Association@Table[i->ByteCount[tasks[[i]]["Value"]],{i,hggOwnIndices}];
hggOwnIndex=First[MinimalBy[hggOwnIndices,hggOwnSizes[#]&]];
hggOwnExpression=tasks[[hggOwnIndex]]["Value"]/.coordinateRules;
gate["selected actual own expression is nonzero",hggOwnExpression=!=0];
Print["HGG_OWN_GROUPED_INPUT ",InputForm[<|"Index"->hggOwnIndex,"Task"->KeyDrop[tasks[[hggOwnIndex]],"Value"],
 "MeasuredCandidateBytes"->hggOwnSizes,"ExpressionBytes"->ByteCount[hggOwnExpression],"Denominators"->denominators|>]];
hggOwnOriginal=mapTargetTask[hggOwnIndex];
gate["complete original own map accepted",AssociationQ[hggOwnOriginal]&&
 hggOwnOriginal["InputHash"]===targetInputHash&&TrueQ[hggOwnOriginal["ReconstructionPassed"]]&&And@@Values[hggOwnOriginal["Checks"]]];
groupInputHash=Hash[{FileHash[hggGroupedSource,"SHA256"],FileHash[hggAlgorithmPath,"SHA256"],
 inputHashes,targetInputHash,hggOwnIndex,Hash[hggOwnExpression,"SHA256"],$Version,$FeynCalcVersion},"SHA256"];
groupCache=FileNameJoin[{root,"cache","s08_Hgg_grouped",IntegerString[groupInputHash,16]}];
If[!DirectoryQ[groupCache],CreateDirectory[groupCache,CreateIntermediateDirectories->True]];
hggOwnResultPath=FileNameJoin[{root,channel,"s08_grouped_comparison_result","s08_result.wl"}];
If[!DirectoryQ[DirectoryName[hggOwnResultPath]],CreateDirectory[DirectoryName[hggOwnResultPath],CreateIntermediateDirectories->True]];
hggOwnProof=If[FileExistsQ[hggOwnResultPath],Get[hggOwnResultPath],<||>];
If[Lookup[hggOwnProof,"InputHash",None]=!=groupInputHash||!TrueQ[Lookup[hggOwnProof,"OwnAcceptedComparison",False]]||
 !AssociationQ[Lookup[hggOwnProof,"Checks",None]]||!TrueQ[And@@Values[Lookup[hggOwnProof,"Checks",<||>]]],
 {hggOwnSeconds,hggOwnCoefficients}=AbsoluteTiming[groupedMapExpression[hggOwnExpression,"component_"<>ToString[hggOwnIndex]]];
 {hggOwnEqualitySeconds,hggOwnEqual}=AbsoluteTiming[hggOwnCoefficients===hggOwnOriginal["Coefficients"]||bounded[
  zero[pairReconstruct[hggOwnCoefficients]-pairReconstruct[hggOwnOriginal["Coefficients"]]],"complete own Hgg map comparison"]];
 gate["entire original own Hgg map reproduced",hggOwnEqual];
 hggOwnProof=<|"Schema"->"polarized-sidis-Hgg-grouped-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[hggGroupedSource,"SHA256"],"AlgorithmProofHash"->FileHash[hggAlgorithmPath,"SHA256"],
  "InputHash"->groupInputHash,"TargetInputHash"->targetInputHash,"InputHashes"->inputHashes,
  "ComponentIndex"->hggOwnIndex,"Task"->KeyDrop[tasks[[hggOwnIndex]],"Value"],
  "ExpressionHash"->Hash[hggOwnExpression,"SHA256"],"Denominators"->denominators,
  "OwnAcceptedComparison"->True,"OriginalSeconds"->hggOwnOriginal["Seconds"],
  "GroupedSeconds"->hggOwnSeconds,"EqualitySeconds"->hggOwnEqualitySeconds,
  "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
 put[hggOwnProof,hggOwnResultPath];
 gate["exact saved own comparison",Get[hggOwnResultPath]===hggOwnProof]];
gate["own comparison bound to current original map",hggOwnProof["ComponentIndex"]===hggOwnIndex&&
 hggOwnProof["ExpressionHash"]===Hash[hggOwnExpression,"SHA256"]&&hggOwnProof["TargetInputHash"]===targetInputHash&&
 hggOwnProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&hggOwnProof["Denominators"]===denominators&&
 Length[hggOwnProof["Checks"]]>0&&And@@Values[hggOwnProof["Checks"]]];
hggGroupedTask=targetSection[hggRunText];
hggGroupedOldCall="mapExpression[hggLoadedValue /. coordinateRules]";
hggGroupedNewCall="groupedMapExpression[hggLoadedValue /. coordinateRules, \"component_\" <> ToString[index]]";
gate["unique grouped Hgg mapping call",StringCount[hggGroupedTask,hggGroupedOldCall]===1];
hggGroupedTaskCandidate=StringReplace[hggGroupedTask,hggGroupedOldCall->hggGroupedNewCall];
gate["entire target task contract retained",SyntaxQ[hggGroupedTaskCandidate]&&
 StringReplace[hggGroupedTaskCandidate,hggGroupedNewCall->hggGroupedOldCall]===hggGroupedTask];
ToExpression[hggGroupedTaskCandidate,InputForm];
hggGroupedEvidence=Join[KeyTake[hggOwnProof,{"ComponentIndex","OriginalSeconds","GroupedSeconds","EqualitySeconds","InputHash"}],
 <|"SourceHash"->FileHash[hggGroupedSource,"SHA256"],"ComparisonHash"->FileHash[hggOwnResultPath,"SHA256"],
 "OwnOriginalMapComparisonPassed"->True|>];
hggGroupedTail=StringDrop[hggRunText,First[First[hggGroupedBoundary]]-1];
hggGroupedEdits={
 "DistributeDefinitions[gate, bounded,"->
  "DistributeDefinitions[groupDenominators, certifyGrouping, certifyPairMerge, certifyGroupMerge, pairReconstruct, groupedMapExpression, groupInputHash, groupCache, gate, bounded,",
 "\ntargetResult = <|"->"\ntargetResult = <|\"GroupedMappingComparison\"->hggGroupedEvidence, "};
gate["unique grouped worker and output edits",And@@(StringCount[hggGroupedTail,First[#]]===1&/@hggGroupedEdits)];
hggGroupedCandidateTail=StringReplace[hggGroupedTail,hggGroupedEdits];
gate["all original worker and final gates retained",SyntaxQ[hggGroupedCandidateTail]&&
 StringReplace[hggGroupedCandidateTail,Reverse/@hggGroupedEdits]===hggGroupedTail];
Clear[hggOwnExpression,hggOwnOriginal,hggOwnCoefficients,hggAlgorithm,hggOwnProof];ClearSystemCache[];
Print["S08_HGG_GROUPED_OWN_COMPARISON ",InputForm[hggGroupedEvidence]];
ToExpression[hggGroupedCandidateTail,InputForm];

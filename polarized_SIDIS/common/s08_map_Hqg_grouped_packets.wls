(* Reuse the executed own grouped map through the assigned-component interface. *)
$HistoryLength=0;
groupPacketSource=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
groupPacketBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_target_packets.wls"}];
If[IntegerString[FileHash[groupPacketBase,"SHA256"],16,64]=!=
 "2be9cfe584e8b1714827d89db0e75c542a31a96bf8e1b413bb767324a61551a4"||
 !SyntaxQ[Import[groupPacketSource,"Text"]],Quit[1]];
groupPacketText=Import[groupPacketBase,"Text"];
groupPacketBoundary=StringPosition[groupPacketText,"\nslots ="];
If[Length[groupPacketBoundary]=!=1,Quit[1]];
groupPacketPrefix=StringTake[groupPacketText,First[First[groupPacketBoundary]]-1];
If[!SyntaxQ[groupPacketPrefix],Quit[1]];ToExpression[groupPacketPrefix,InputForm];
groupPacketProofRelative="Hqg/s08_grouped_comparison_result/s08_result.wl";
groupPacketProofPath=FileNameJoin[{root,groupPacketProofRelative}];
groupPacketReceiptPath=FileNameJoin[{DirectoryName[groupPacketProofPath],"s08_execution.json"}];
groupPacketReceipt=Import[groupPacketReceiptPath,"RawJSON"];
gate["accepted own grouped packet receipt",TrueQ[groupPacketReceipt["passed"]]&&
 groupPacketReceipt["result_sha256"][groupPacketProofRelative]===IntegerString[FileHash[groupPacketProofPath,"SHA256"],16,64]];
groupPacketProof=Get[groupPacketProofPath];
gate["complete own grouped packet proof",groupPacketProof["Schema"]==="polarized-sidis-Hqg-grouped-comparison-v1"&&
 groupPacketProof["Channel"]===channel&&TrueQ[groupPacketProof["Accepted"]]&&TrueQ[groupPacketProof["OwnAcceptedComparison"]]&&
 And@@Values[groupPacketProof["Checks"]]&&groupPacketProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&
 groupPacketProof["InputHashes"]===inputHashes&&groupPacketProof["TargetInputHash"]===targetInputHash&&
 groupPacketProof["MappingInputHash"]===inputHash&&groupPacketProof["Denominators"]===denominators&&
 groupPacketProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hqg_grouped_mapping.wls"}],"SHA256"]&&
 groupPacketProof["AlgorithmProofHash"]===FileHash[FileNameJoin[{root,"Hgq","s08_certified_denominator_result","s08_result.wl"}],"SHA256"]&&
 groupPacketProof["ControlHash"]===FileHash[FileNameJoin[{root,groupPacketProof["ControlFile"]}],"SHA256"]&&
 groupPacketProof["Task"]===tasks[[groupPacketProof["ComponentIndex"]]]];
groupPacketDefinitions=groupPacketProof["AlgorithmDefinitions"];
gate["unchanged own native mapper and merge",groupPacketDefinitions["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
 groupPacketDefinitions["OriginalMergeDefinitions"]===DownValues[merge]];
DownValues[groupDenominators]=groupPacketDefinitions["GroupingDefinitions"];
DownValues[certifyGrouping]=groupPacketDefinitions["GroupingCertificateDefinitions"];
DownValues[certifyPairMerge]=groupPacketDefinitions["MergeCertificateDefinitions"];
DownValues[certifyGroupMerge]=groupPacketDefinitions["GroupMergeDefinitions"];
DownValues[pairReconstruct]=groupPacketDefinitions["ReconstructionDefinitions"];
DownValues[groupedMapExpression]=groupPacketDefinitions["MappingDefinitions"];
gate["exact executed grouped packet definitions",{
 DownValues[groupDenominators],DownValues[certifyGrouping],DownValues[certifyPairMerge],
 DownValues[certifyGroupMerge],DownValues[pairReconstruct],DownValues[groupedMapExpression]}===
 Lookup[groupPacketDefinitions,{"GroupingDefinitions","GroupingCertificateDefinitions","MergeCertificateDefinitions",
 "GroupMergeDefinitions","ReconstructionDefinitions","MappingDefinitions"}]];
groupInputHash=groupPacketProof["InputHash"];
groupCache=FileNameJoin[{root,"cache","s08_Hqg_grouped_comparison",IntegerString[groupInputHash,16]}];
gate["own completed grouped cache exists",DirectoryQ[groupCache]];
groupPacketOriginalTask=targetSection[groupPacketText];
groupPacketOldCall="mapExpression[task[\"Value\"] /. coordinateRules]";
groupPacketNewCall="groupedMapExpression[task[\"Value\"] /. coordinateRules, \"component_\" <> ToString[index]]";
gate["unique own grouped task call",StringCount[groupPacketOriginalTask,groupPacketOldCall]===1];
groupPacketTask=StringReplace[groupPacketOriginalTask,groupPacketOldCall->groupPacketNewCall];
gate["canonical target contract unchanged",SyntaxQ[groupPacketTask]&&
 StringReplace[groupPacketTask,groupPacketNewCall->groupPacketOldCall]===groupPacketOriginalTask];
ToExpression[groupPacketTask,InputForm];
groupedControlRecord=Join[KeyDrop[groupPacketProof["Task"],"Value"],<|
 "Coefficients"->groupPacketProof["Coefficients"],
 "MissingTargets"->Complement[Keys[groupPacketProof["Coefficients"]],ruleKeys,reduction["Masters"]],
 "InputHash"->targetInputHash,"ReconstructionPassed"->True,"Checks"->groupPacketProof["Checks"],
 "Seconds"->groupPacketProof["CandidateSeconds"],"InputBytes"->ByteCount[groupPacketProof["Task"]["Value"]],
 "OutputBytes"->ByteCount[groupPacketProof["Coefficients"]]|>];
groupPacketEvidence=<|"SourceHash"->FileHash[groupPacketSource,"SHA256"],
 "ComparisonHash"->FileHash[groupPacketProofPath,"SHA256"],"ReceiptHash"->FileHash[groupPacketReceiptPath,"SHA256"],
 "ControlIndex"->groupPacketProof["ComponentIndex"],"OwnOriginalMapComparisonPassed"->True,
 "OriginalSeconds"->groupPacketProof["OriginalSeconds"],"GroupedSeconds"->groupPacketProof["CandidateSeconds"],
 "EqualitySeconds"->groupPacketProof["EqualitySeconds"],"InputHash"->targetInputHash|>;
groupPacketTail=StringDrop[groupPacketText,First[First[groupPacketBoundary]]-1];
groupPacketEdits={
 "packetOriginal = mapTargetTask[packetControlIndex];"->
  "gate[\"same own grouped control selected\", packetControlIndex === groupPacketEvidence[\"ControlIndex\"]]; packetOriginal = groupedControlRecord;",
 "mapTargetPacket[packet_] := Catch[Module["->"mapTargetPacket[packet_] := Catch[Block[{checks = <||>}, Module[",
 "mapTargetTask[index]]], \"TargetMapFailure\"];"->"mapTargetTask[index]]]], \"TargetMapFailure\"];",
 "DistributeDefinitions[mapTargetPacket, packetControlFunction, packetControlCache,"->
  "DistributeDefinitions[groupDenominators, certifyGrouping, certifyPairMerge, certifyGroupMerge, pairReconstruct, groupedMapExpression, groupInputHash, groupCache, mapTargetPacket, packetControlFunction, packetControlCache,",
 "\"AssignedComponentFootprint\" -> packetInputFootprint,"->
  "\"AssignedComponentFootprint\" -> packetInputFootprint, \"GroupedMappingComparison\" -> groupPacketEvidence,"
};
gate["unique grouped packet dispatch edits",And@@(StringCount[groupPacketTail,First[#]]===1&/@groupPacketEdits)];
groupPacketCandidateTail=StringReplace[groupPacketTail,groupPacketEdits];
gate["all other packet and final gates unchanged",StringReplace[groupPacketCandidateTail,Reverse/@groupPacketEdits]===groupPacketTail&&
 SyntaxQ[groupPacketCandidateTail]];
packetSourcePath=groupPacketSource;
Clear[groupPacketProof,groupPacketDefinitions];ClearSystemCache[];
Print["S08_GROUPED_PACKET_PROOF ",InputForm[groupPacketEvidence]];
ToExpression[groupPacketCandidateTail,InputForm];

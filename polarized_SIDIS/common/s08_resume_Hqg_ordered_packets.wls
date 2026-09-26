(* Preserve the accepted mapper; compare integral dictionaries in canonical order. *)
$HistoryLength=0;
orderedSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_ordered_packets.wls"}];
orderedBase=FileNameJoin[{Directory[],"common","s08_resume_Hqg_factored_groups.wls"}];
orderedChecks=<||>;
orderedGate[name_,test_]:=If[TrueQ[test],AssociateTo[orderedChecks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
packetOrderRecord[record_Association]:=Join[KeyDrop[record,{"Seconds","Checks","Coefficients"}],
 <|"Coefficients"->KeySort[record["Coefficients"]]|>];
orderedGate["complete ordered packet source syntax",SyntaxQ[Import[orderedSource,"Text"]]];
orderedGate["unchanged accepted factored mapper",IntegerString[FileHash[orderedBase,"SHA256"],16,64]===
 "49d523467d59f0b275002f86125ed7cbbc79e344953262ea6cd78564e01f41b3"];
orderedProofRelative="Hqg/s08_packet_record_result/s08_result.wl";
orderedProofPath=FileNameJoin[{Directory[],orderedProofRelative}];
orderedReceiptPath=FileNameJoin[{DirectoryName[orderedProofPath],"s08_execution.json"}];
orderedReceipt=Import[orderedReceiptPath,"RawJSON"];
orderedGate["accepted actual packet record comparison",TrueQ[orderedReceipt["passed"]]&&
 orderedReceipt["result_sha256"][orderedProofRelative]===IntegerString[FileHash[orderedProofPath,"SHA256"],16,64]];
orderedProof=Get[orderedProofPath];
orderedGate["actual mismatch is only coefficient key order",orderedProof["Schema"]==="polarized-sidis-Hqg-packet-record-comparison-v1"&&
 orderedProof["NativeVersions"][[1]]===$Version&&And@@Values[orderedProof["Checks"]]&&
 TrueQ[orderedProof["Details"]["ScientificMetadataEqual"]]&&TrueQ[orderedProof["Details"]["AllCoefficientsExactlyEqual"]]&&
 orderedProof["Details"]["ChangedCoefficientCount"]===0&&orderedProof["Details"]["CoefficientKeysInSameOrder"]===False];
orderedFiles=Select[Keys[orderedProof["InputHashes"]],StringStartsQ[#,"cache/s08_target_packets/Hqg/"]&];
orderedGate["both exact saved packets selected",Length[orderedFiles]===2&&And@@(IntegerString[
 FileHash[FileNameJoin[{Directory[],#}],"SHA256"],16,64]===orderedProof["InputHashes"][#]&/@orderedFiles)];
orderedRecords=Get[FileNameJoin[{Directory[],#}]]&/@orderedFiles;
orderedGate["original record comparison reproduces failure",KeyDrop[orderedRecords[[1]],{"Seconds","Checks"}]=!=
 KeyDrop[orderedRecords[[2]],{"Seconds","Checks"}]];
orderedGate["canonical key ordering gives exact complete record equality",SameQ@@(packetOrderRecord/@orderedRecords)];
orderedEvidence=<|"SourceHash"->FileHash[orderedSource,"SHA256"],"ProofHash"->FileHash[orderedProofPath,"SHA256"],
 "ReceiptHash"->FileHash[orderedReceiptPath,"SHA256"],"PacketHashes"->KeyTake[orderedProof["InputHashes"],orderedFiles],
 "ComparatorDefinitions"->DownValues[packetOrderRecord],"ExactCompleteRecordEquality"->True|>;
Clear[orderedProof,orderedRecords];
installPacketOrdering[]:=Module[{original,edits,candidate},
 original=groupPacketCandidateTail;
 edits={"KeyDrop[packetCandidate, {\"Seconds\", \"Checks\"}]"->"packetOrderRecord[packetCandidate]",
 "KeyDrop[packetOriginal, {\"Seconds\", \"Checks\"}]"->"packetOrderRecord[packetOriginal]"};
 gate["both own gate and evidence hashes use canonical integral keys",And@@(StringCount[original,First[#]]===2&/@edits)];
 candidate=StringReplace[original,edits];
 gate["only key ordering changes complete packet comparison",SyntaxQ[candidate]&&StringReplace[candidate,Reverse/@edits]===original];
 groupPacketCandidateTail=candidate;packetSourcePath=orderedSource];
orderedBaseText=Import[orderedBase,"Text"];
orderedBoundary=StringPosition[orderedBaseText,"ToExpression[hqgFactoredRun,InputForm];"];
orderedGate["unique accepted mapper dispatch boundary",Length[orderedBoundary]===1];
orderedPrefix=StringTake[orderedBaseText,First[First[orderedBoundary]]-1];
orderedGate["complete accepted mapper initialization syntax",SyntaxQ[orderedPrefix]];ToExpression[orderedPrefix,InputForm];
orderedAnchor="packetSourcePath=polynomialSource];";
orderedReplacement="packetSourcePath=polynomialSource;installPacketOrdering[]];";
orderedGate["unique final comparison installation",StringCount[hqgFactoredRun,orderedAnchor]===1];
orderedRun=StringReplace[hqgFactoredRun,orderedAnchor->orderedReplacement];
orderedGate["accepted complete mapping dispatch unchanged",SyntaxQ[orderedRun]&&
 StringReplace[orderedRun,orderedReplacement->orderedAnchor]===hqgFactoredRun];
If[Environment["POLARIZED_SIDIS_PACKET_ORDER_ONLY"]==="1",
 orderedPacketText=Import[FileNameJoin[{Directory[],"common","s08_map_Hqg_target_packets.wls"}],"Text"];
 orderedGate["unchanged packet comparison source",IntegerString[FileHash[FileNameJoin[{Directory[],"common","s08_map_Hqg_target_packets.wls"}],"SHA256"],16,64]===
 "2be9cfe584e8b1714827d89db0e75c542a31a96bf8e1b413bb767324a61551a4"];
 groupPacketCandidateTail=orderedPacketText;gate[name_,test_]:=orderedGate[name,test];installPacketOrdering[];
 orderedDirectory=FileNameJoin[{Directory[],"Hqg","s08_packet_order_result"}];
 If[!DirectoryQ[orderedDirectory],CreateDirectory[orderedDirectory]];
 orderedResult=<|"Schema"->"polarized-sidis-Hqg-ordered-packet-v1","Evidence"->orderedEvidence,
 "Checks"->orderedChecks,"NativeVersion"->$Version|>;
 orderedPath=FileNameJoin[{orderedDirectory,"s08_result.wl"}];
 Export[orderedPath<>".tmp","Uncompress["<>ToString[Compress[orderedResult],InputForm]<>"]\n","Text"];
 orderedGate["exact corrected interface native export",Get[orderedPath<>".tmp"]===orderedResult];
 RenameFile[orderedPath<>".tmp",orderedPath,OverwriteTarget->True];
 Export[FileNameJoin[{orderedDirectory,"s08_checks.json"}],<|"checks"->orderedChecks|>,"RawJSON"];
 Print["PASS: s08_Hqg_ordered_packet_control"];Quit[0]];
Print["S08_ORDERED_PACKET_EVIDENCE ",InputForm[orderedEvidence]];
ToExpression[orderedRun,InputForm];

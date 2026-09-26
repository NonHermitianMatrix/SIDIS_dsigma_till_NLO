(* Reuse the accepted polynomial family function in the existing parallel mapper. *)
$HistoryLength=0;
polynomialSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_polynomial_maps.wls"}];
polynomialBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
If[!SyntaxQ[Import[polynomialSource,"Text"]]||IntegerString[FileHash[polynomialBase,"SHA256"],16,64]=!=
 "0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838",Quit[1]];
installPolynomialFamily[]:=Module[{path,receipt,proof,original,candidate},
 path=FileNameJoin[{root,channel,"s08_polynomial_group_result","s08_result.wl"}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted own polynomial mapping execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][channel<>"/s08_polynomial_group_result/s08_result.wl"]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["same complete polynomial mapping contract",channel==="Hqg"&&proof["Schema"]==="polarized-sidis-polynomial-family-group-v1"&&proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&proof["OriginalFamilyDefinitions"]===DownValues[familyRows]&&proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]&&proof["OwnComparisonHash"]===FileHash[groupPacketProofPath,"SHA256"]&&proof["OwnReceiptHash"]===FileHash[groupPacketReceiptPath,"SHA256"]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}],"SHA256"]];
 DownValues[familyRows]=proof["CandidateFamilyDefinitions"];polynomialVariables=proof["PolynomialVariables"];
 gate["exact accepted family definitions installed",DownValues[familyRows]===proof["CandidateFamilyDefinitions"]];
 DownValues[polynomialAdditivePieces]=proof["AdditivePiecesDefinitions"];DownValues[polynomialPieceMap]=proof["PieceMappingDefinitions"];DownValues[saveNative]=proof["PieceStorageDefinitions"];pieceScientificHash=proof["PieceScientificHash"];
 original=DownValues[groupedMapExpression];candidate=original/.mapExpression->polynomialPieceMap;
 gate["only group mapping uses accepted linear pieces",Count[original,_mapExpression,Infinity]===1&&(candidate/.polynomialPieceMap->mapExpression)===original];
 DownValues[groupedMapExpression]=candidate;
 gate["accepted piece mapping installed exactly",DownValues[polynomialAdditivePieces]===proof["AdditivePiecesDefinitions"]&&DownValues[polynomialPieceMap]===proof["PieceMappingDefinitions"]&&DownValues[groupedMapExpression]===candidate];
 polynomialEvidence=KeyTake[proof,{"SourceHash","OwnComparisonHash","ControlHash","OriginalControlSeconds","ControlSeconds","BlockedSeconds"}];
 AssociateTo[polynomialEvidence,"ProofHash"->FileHash[path,"SHA256"]]];
finishPolynomialDispatch[]:=Module[{edits,original},
 original=groupPacketCandidateTail;
 edits={"DistributeDefinitions[groupDenominators,"->"DistributeDefinitions[polynomialVariables,polynomialAdditivePieces,polynomialPieceMap,saveNative,pieceScientificHash,groupDenominators,",
  "\"GroupedMappingComparison\" -> groupPacketEvidence,"->"\"GroupedMappingComparison\" -> groupPacketEvidence, \"PolynomialFamilyMapping\" -> polynomialEvidence,"};
 gate["unique polynomial worker and evidence edits",And@@(StringCount[original,First[#]]===1&/@edits)];
 groupPacketCandidateTail=StringReplace[original,edits];
 gate["unchanged complete parallel mapping contract",SyntaxQ[groupPacketCandidateTail]&&StringReplace[groupPacketCandidateTail,Reverse/@edits]===original];
 packetSourcePath=polynomialSource];
polynomialText=Import[polynomialBase,"Text"];
polynomialEdits={"ToExpression[groupPacketTask,InputForm];"->"ToExpression[groupPacketTask,InputForm];installPolynomialFamily[];",
 "packetSourcePath=groupPacketSource;"->"packetSourcePath=groupPacketSource;finishPolynomialDispatch[];"};
If[!And@@(StringCount[polynomialText,First[#]]===1&/@polynomialEdits),Quit[1]];
polynomialRun=StringReplace[polynomialText,polynomialEdits];
If[!SyntaxQ[polynomialRun]||StringReplace[polynomialRun,Reverse/@polynomialEdits]=!=polynomialText,Quit[1]];
ToExpression[polynomialRun,InputForm];

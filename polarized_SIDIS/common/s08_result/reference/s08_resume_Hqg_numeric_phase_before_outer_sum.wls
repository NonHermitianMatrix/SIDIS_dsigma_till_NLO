(* Reuse the accepted polynomial family function in the existing parallel mapper. *)
$HistoryLength=0;
polynomialSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_polynomial_maps.wls"}];
polynomialBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
If[!SyntaxQ[Import[polynomialSource,"Text"]]||IntegerString[FileHash[polynomialBase,"SHA256"],16,64]=!=
 "0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838",Quit[1]];
numericOuterFactor[expression_]:=Module[{factors,numbers,rest,factor},
 If[Head[expression]=!=Times,Return[{1,expression}]];
 factors=List@@expression;numbers=Select[factors,NumberQ];rest=Select[factors,!NumberQ[#]&];
 If[numbers==={}||Length[rest]=!=1||Head[First[rest]]=!=Plus||!FreeQ[numbers,_Real],Return[{1,expression}]];
 factor=Times@@numbers;
 gate["exact nonzero numeric outer factor",NumberQ[factor]&&factor=!=0&&factor First[rest]===expression];
 {factor,First[rest]}];
numericPhaseMap[expression_,key_]:=Module[{split,factor,core,rows,scaled},
 split=numericOuterFactor[expression];{factor,core}=split;
 If[factor===1,Return[groupedMapExpression[expression,key]]];
 Print["NUMERIC_PHASE_MAP ",key," factor ",InputForm[factor]," additive_terms ",Length[core]];
 rows=Block[{groupCache=numericPhaseCache},groupedMapExpression[core,key]];
 scaled=Map[factor #&,rows];
 gate["numeric phase preserves every mapped coefficient",Keys[scaled]===Keys[rows]&&And@@KeyValueMap[(#2/factor===rows[#1]||zero[#2/factor-rows[#1]])&,scaled]];
 gate["numeric phase preserves original complete input",factor core===expression];
 scaled];
installNumericPhase[]:=Module[{relative,path,receipt,record,split,control,seconds,candidate,original,changed},
 relative="Hqg/s08_mapping_inputs_result/s08_component_0028.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_pending_execution.json"}],"RawJSON"];
 gate["accepted actual outer-phase input",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 record=Get[path];
 gate["same exact pending phase input",record["Channel"]===channel&&record["Component"]===28&&record["InputHashes"]===inputHashes&&record["TargetInputHash"]===targetInputHash&&record["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[record["Checks"]]&&record["Expression"]===(tasks[[record["Component"]]]["Value"]/.coordinateRules)];
 split=numericOuterFactor[record["Expression"]];gate["actual input exposes a numeric outer phase",First[split]=!=1&&Head[Last[split]]===Plus];
 control=groupPacketProof["ActualExpression"];
 gate["phase control retains the entire original core",Last[numericOuterFactor[First[split] control]]===control];
 {seconds,candidate}=AbsoluteTiming[Block[{numericPhaseCache=groupCache},numericPhaseMap[First[split] control,"component_"<>ToString[groupPacketProof["ComponentIndex"]]]]];
 gate["complete own accepted map with restored numeric phase",Sort[Keys[candidate]]===Sort[Keys[groupPacketProof["Coefficients"]]]&&And@@KeyValueMap[zero[#2-First[split] groupPacketProof["Coefficients"][#1]]&,candidate]];
 numericPhaseCache=groupCache<>"_numeric_phase";If[!DirectoryQ[numericPhaseCache],CreateDirectory[numericPhaseCache,CreateIntermediateDirectories->True]];
 original=DownValues[mapTargetTask];changed=original/.groupedMapExpression->numericPhaseMap;
 gate["only numeric phase handling changes target mapping",Count[original,_groupedMapExpression,Infinity]===1&&(changed/.numericPhaseMap->groupedMapExpression)===original];
 DownValues[mapTargetTask]=changed;
 numericPhaseEvidence=<|"SourceHash"->FileHash[polynomialSource,"SHA256"],"NativeInputHash"->FileHash[path,"SHA256"],"NativeReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_pending_execution.json"}],"SHA256"],"ControlProofHash"->FileHash[groupPacketProofPath,"SHA256"],"ControlSeconds"->seconds,"OwnAcceptedComparison"->True,"NumericFactor"->First[split],"ExtractionDefinitions"->DownValues[numericOuterFactor],"MappingDefinitions"->DownValues[numericPhaseMap]|>;
 Print["NUMERIC_PHASE_CONTROL_ACCEPTED ",seconds]];
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
 AssociateTo[polynomialEvidence,"ProofHash"->FileHash[path,"SHA256"]];installNumericPhase[]];
finishPolynomialDispatch[]:=Module[{edits,original},
 original=groupPacketCandidateTail;
 edits={"DistributeDefinitions[groupDenominators,"->"DistributeDefinitions[numericOuterFactor,numericPhaseMap,numericPhaseCache,polynomialVariables,polynomialAdditivePieces,polynomialPieceMap,saveNative,pieceScientificHash,groupDenominators,",
  "\"GroupedMappingComparison\" -> groupPacketEvidence,"->"\"GroupedMappingComparison\" -> groupPacketEvidence, \"PolynomialFamilyMapping\" -> polynomialEvidence, \"NumericPhaseMapping\" -> numericPhaseEvidence,"};
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

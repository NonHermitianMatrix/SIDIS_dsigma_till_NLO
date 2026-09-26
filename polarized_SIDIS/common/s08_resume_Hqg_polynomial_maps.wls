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
numericPhaseMap[expression_,key_]:=Module[{split,factor,core,rows,scaled,terms,packets},
 split=numericOuterFactor[expression];{factor,core}=split;
 If[factor===1,
  If[Head[expression]===Plus,
   terms=List@@expression;
   If[AnyTrue[numericOuterFactor/@terms,First[#]=!=1&],
    gate["complete outer phase-term inventory",Total[terms]===expression];
    Print["NUMERIC_PHASE_OUTER_TERMS ",key," count ",Length[terms]];
    packets=MapIndexed[Function[{term,index},Block[{checks=<||>},Module[{mapped},
      mapped=numericPhaseMap[term,key<>"_outer_"<>ToString[First[index]]];
      <|"Coefficients"->mapped,"Checks"->checks,"Accepted"->True|>]]],terms];
    gate["all outer phase maps retain reconstruction",And@@Lookup[packets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@packets]];
    rows=merge[Lookup[packets,"Coefficients"]];gate["complete outer phase maps reconstruct",certifyGroupMerge[packets,rows]];Return[rows]]];
  Return[groupedMapExpression[expression,key]]];
 Print["NUMERIC_PHASE_MAP ",key," factor ",InputForm[factor]," additive_terms ",Length[core]];
 rows=Block[{groupCache=numericPhaseCache},groupedMapExpression[core,key]];
 scaled=Map[factor #&,rows];
 gate["numeric phase preserves every mapped coefficient",Keys[scaled]===Keys[rows]&&And@@KeyValueMap[(#2/factor===rows[#1]||zero[#2/factor-rows[#1]])&,scaled]];
 gate["numeric phase preserves original complete input",factor core===expression];
 scaled];
installNumericPhase[]:=Module[{relative,path,receipt,record,split,control,seconds,candidate,original,changed,outer,found},
 relative="Hqg/s08_mapping_inputs_result/s08_component_0028.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_pending_execution.json"}],"RawJSON"];
 gate["accepted actual outer-phase input",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 record=Get[path];
 gate["same exact pending phase input",record["Channel"]===channel&&record["Component"]===28&&record["InputHashes"]===inputHashes&&record["TargetInputHash"]===targetInputHash&&record["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[record["Checks"]]];
 If[!TrueQ[numericPhaseControlOnly],gate["pending equation equals complete production input",record["Expression"]===(tasks[[record["Component"]]]["Value"]/.coordinateRules)]];
 outer=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
 gate["saved outer term inventory reconstructs exactly",Total[outer]===record["Expression"]];
 found=Select[numericOuterFactor/@outer,First[#]=!=1&&Head[Last[#]]===Plus&];
 gate["actual outer terms expose numeric phases",Length[found]>0];split=First[found];
 Print["NUMERIC_PHASE_ACTUAL_INPUT outer_terms ",Length[outer]," wrapped_sums ",Length[found]," inner_terms ",Length[Last[#]]&/@found];
 control=groupPacketProof["ActualExpression"];
 gate["phase control retains the entire original core",Last[numericOuterFactor[First[split] control]]===control];
 {seconds,candidate}=AbsoluteTiming[Block[{numericPhaseCache=groupCache},numericPhaseMap[First[split] control,"component_"<>ToString[groupPacketProof["ComponentIndex"]]]]];
 gate["complete own accepted map with restored numeric phase",Sort[Keys[candidate]]===Sort[Keys[groupPacketProof["Coefficients"]]]&&And@@KeyValueMap[zero[#2-First[split] groupPacketProof["Coefficients"][#1]]&,candidate]];
 numericPhaseCache=groupCache<>"_numeric_phase";If[!DirectoryQ[numericPhaseCache],CreateDirectory[numericPhaseCache,CreateIntermediateDirectories->True]];
 If[!TrueQ[numericPhaseControlOnly],
  original=DownValues[mapTargetTask];changed=original/.groupedMapExpression->numericPhaseMap;
  gate["only numeric phase handling changes target mapping",Count[original,_groupedMapExpression,Infinity]===1&&(changed/.numericPhaseMap->groupedMapExpression)===original];DownValues[mapTargetTask]=changed];
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
numericPhaseControlOnly=Environment["POLARIZED_SIDIS_PHASE_CONTROL_ONLY"]==="1";
If[numericPhaseControlOnly,
 phaseBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
 If[IntegerString[FileHash[phaseBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
 phaseBootstrapText=Import[phaseBootstrapPath,"Text"];phaseBootstrapBoundary=StringPosition[phaseBootstrapText,"\nIf[channel===\"Hgg\","];
 If[Length[phaseBootstrapBoundary]=!=1,Quit[1]];
 phaseBootstrap=StringTake[phaseBootstrapText,First[First[phaseBootstrapBoundary]]-1];If[!SyntaxQ[phaseBootstrap],Quit[1]];ToExpression[phaseBootstrap,InputForm];
 targetMapperPath=mapper;inputHashes=record["InputHashes"];targetInputHash=record["TargetInputHash"];
 groupPacketProofPath=FileNameJoin[{root,"Hqg","s08_grouped_comparison_result","s08_result.wl"}];
 groupPacketReceiptPath=FileNameJoin[{DirectoryName[groupPacketProofPath],"s08_execution.json"}];phaseOwnReceipt=Import[groupPacketReceiptPath,"RawJSON"];
 gate["accepted native own phase-control proof",TrueQ[phaseOwnReceipt["passed"]]&&phaseOwnReceipt["result_sha256"]["Hqg/s08_grouped_comparison_result/s08_result.wl"]===IntegerString[FileHash[groupPacketProofPath,"SHA256"],16,64]];
 groupPacketProof=Get[groupPacketProofPath];
 gate["same complete own phase-control inputs",TrueQ[groupPacketProof["Accepted"]]&&TrueQ[groupPacketProof["OwnAcceptedComparison"]]&&And@@Values[groupPacketProof["Checks"]]&&groupPacketProof["InputHashes"]===inputHashes&&groupPacketProof["TargetInputHash"]===targetInputHash&&groupPacketProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
 groupInputHash=groupPacketProof["InputHash"];groupCache=FileNameJoin[{root,"cache","s08_Hqg_grouped_comparison",IntegerString[groupInputHash,16]}];
 phaseDefinitions=groupPacketProof["AlgorithmDefinitions"];
 DownValues[groupDenominators]=phaseDefinitions["GroupingDefinitions"];DownValues[certifyGrouping]=phaseDefinitions["GroupingCertificateDefinitions"];DownValues[groupedMapExpression]=phaseDefinitions["MappingDefinitions"];
 DownValues[familyRows]=termOriginalFamily;
 put[value_,path_]:=saveNative[value,path];
 installPolynomialFamily[];
 phaseDirectory=FileNameJoin[{root,"Hqg","s08_numeric_phase_control_result"}];If[!DirectoryQ[phaseDirectory],CreateDirectory[phaseDirectory]];
 saveNative[<|"Schema"->"polarized-sidis-numeric-phase-control-v1","Evidence"->numericPhaseEvidence,"Checks"->checks,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"InputHashes"->inputHashes,"TargetInputHash"->targetInputHash|>,FileNameJoin[{phaseDirectory,"s08_result.wl"}]];
 Export[FileNameJoin[{phaseDirectory,"s08_checks.json"}],<|"checks"->checks,"own_control_seconds"->numericPhaseEvidence["ControlSeconds"],"source_sha256"->IntegerString[FileHash[polynomialSource,"SHA256"],16,64]|>,"RawJSON"];
 Print["PASS: s08_numeric_phase_control"];Quit[0]];
polynomialText=Import[polynomialBase,"Text"];
polynomialEdits={"ToExpression[groupPacketTask,InputForm];"->"ToExpression[groupPacketTask,InputForm];installPolynomialFamily[];",
 "packetSourcePath=groupPacketSource;"->"packetSourcePath=groupPacketSource;finishPolynomialDispatch[];"};
If[!And@@(StringCount[polynomialText,First[#]]===1&/@polynomialEdits),Quit[1]];
polynomialRun=StringReplace[polynomialText,polynomialEdits];
If[!SyntaxQ[polynomialRun]||StringReplace[polynomialRun,Reverse/@polynomialEdits]=!=polynomialText,Quit[1]];
ToExpression[polynomialRun,InputForm];

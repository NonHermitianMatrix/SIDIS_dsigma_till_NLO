(* Reuse the accepted polynomial group mapper with the own original-term control. *)
$HistoryLength=0;
hggPolynomialSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_polynomial_inputs.wls"}];
hggResponseEntry=FileNameJoin[{Directory[],"common","s08_map_Hgg_response_inputs.wls"}];
If[!SyntaxQ[Import[hggPolynomialSource,"Text"]]||Environment["POLARIZED_SIDIS_COMPONENT_STAGE"]=!="targets"||
 IntegerString[FileHash[hggResponseEntry,"SHA256"],16,64]=!="80e0d148094ce46df049c434453aec556b9be7f5b51481e460ca488967e34016",Quit[1]];
hggTermControl[]:=Module[{relative,path,receipt,proof,inputRelative,inputPath,inputReceipt,record},
 relative="Hgg/s08_termwise_comparison_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted complete own original-term execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["complete own original-term mapping contract",proof["Schema"]==="polarized-sidis-original-term-map-v1"&&proof["Channel"]===channel&&proof["Component"]===hggOwnIndex&&proof["Task"]===KeyDrop[tasks[[hggOwnIndex]],"Value"]&&proof["InputHash"]===targetInputHash&&proof["InputHashes"]===inputHashes&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["ReconstructionPassed"]]&&And@@Values[proof["Checks"]]&&proof["ComparisonKind"]==="EveryOriginalTermAndCompleteLinearMerge"&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hgg_original_terms.wls"}],"SHA256"]&&proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]];
 inputRelative=channel<>"/s08_mapping_inputs_result/s08_component_"<>IntegerString[hggOwnIndex,10,4]<>".wl";inputPath=FileNameJoin[{root,inputRelative}];
 inputReceipt=Import[FileNameJoin[{DirectoryName[inputPath],"s08_recovery_execution.json"}],"RawJSON"];
 gate["accepted exact own control equation",TrueQ[inputReceipt["passed"]]&&inputReceipt["result_sha256"][inputRelative]===IntegerString[FileHash[inputPath,"SHA256"],16,64]&&proof["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&proof["NativeInputReceiptHash"]===FileHash[FileNameJoin[{DirectoryName[inputPath],"s08_recovery_execution.json"}],"SHA256"]];
 record=Get[inputPath];
 gate["actual entire own control equation unchanged",record["Expression"]===hggOwnExpression&&record["InputHashes"]===inputHashes&&record["TargetInputHash"]===targetInputHash&&And@@Values[record["Checks"]]];
 hggTermEvidence=<|"ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],"ComparisonKind"->proof["ComparisonKind"],"NativeInputHash"->FileHash[inputPath,"SHA256"],"PolynomialProofHash"->proof["PolynomialProofHash"]|>;
 Join[proof["Task"],<|"Coefficients"->proof["Coefficients"],"InputHash"->proof["InputHash"],"ReconstructionPassed"->True,"Checks"->proof["Checks"],"Seconds"->proof["MappingSeconds"]+proof["MergeSeconds"]|>]];
hggPolynomialInstall[]:=Module[{relative,path,receipt,proof,original,candidate,phasePath,phaseText,begin,end,phaseBlock},
 relative="Hqg/s08_polynomial_group_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted polynomial group execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["identical accepted scalar polynomial mapping",TrueQ[proof["Accepted"]]&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["OriginalFamilyDefinitions"]===DownValues[familyRows]&&proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}],"SHA256"]&&KeyDrop[proof["InputHashes"],"Hqg/s05_result/s05_result.wl"]===KeyDrop[inputHashes,"Hgg/s05_result/s05_result.wl"]&&hggTermEvidence["PolynomialProofHash"]===FileHash[path,"SHA256"]];
 DownValues[familyRows]=proof["CandidateFamilyDefinitions"];polynomialVariables=proof["PolynomialVariables"];
 DownValues[polynomialAdditivePieces]=proof["AdditivePiecesDefinitions"];DownValues[polynomialPieceMap]=proof["PieceMappingDefinitions"];DownValues[saveNative]=proof["PieceStorageDefinitions"];pieceScientificHash=Hash[{proof["PieceScientificHash"],targetInputHash,FileHash[hggPolynomialSource,"SHA256"]},"SHA256"];
 original=DownValues[groupedMapExpression];candidate=original/.mapExpression->polynomialPieceMap;
 gate["only group family evaluation changes",Count[original,_mapExpression,Infinity]===1&&(candidate/.polynomialPieceMap->mapExpression)===original];DownValues[groupedMapExpression]=candidate;
 phasePath=FileNameJoin[{root,"common","s08_resume_Hqg_polynomial_maps.wls"}];
 gate["reviewed exact numeric-phase implementation",IntegerString[FileHash[phasePath,"SHA256"],16,64]==="1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9"];
 phaseText=Import[phasePath,"Text"];
 begin=StringPosition[phaseText,"\nnumericOuterFactor[expression_]"];end=StringPosition[phaseText,"\ninstallNumericPhase[]"];
 gate["unique complete numeric-factor implementation",Length[begin]===1&&Length[end]===1];
 phaseBlock=StringTake[phaseText,{First[First[begin]],First[First[end]]-1}];gate["complete numeric-factor source syntax",SyntaxQ[phaseBlock]];ToExpression[phaseBlock,InputForm];
 hggPolynomialEvidence=<|"SourceHash"->FileHash[hggPolynomialSource,"SHA256"],"PolynomialProofHash"->FileHash[path,"SHA256"],"NumericPhaseSourceHash"->FileHash[phasePath,"SHA256"],"OriginalTermComparison"->hggTermEvidence|>];
hggPhaseMap[expression_,key_]:=Block[{numericPhaseCache=groupCache<>"_numeric_phase"},
 If[!DirectoryQ[numericPhaseCache],CreateDirectory[numericPhaseCache,CreateIntermediateDirectories->True]];
 numericPhaseMap[expression,key]];

hggResponseText0=StringTrim[Import[hggResponseEntry,"Text"]];hggResponseTerminal="ToExpression[hggResponseRun,InputForm];";
If[!StringEndsQ[hggResponseText0,hggResponseTerminal],Quit[1]];
hggResponseBootstrap=StringDrop[hggResponseText0,-StringLength[hggResponseTerminal]];
If[!SyntaxQ[hggResponseBootstrap],Quit[1]];ToExpression[hggResponseBootstrap,InputForm];
hggPolynomialEdits={
 "hggGroupedSource=FileNameJoin[{Directory[],\"common\",\"s08_map_Hgg_grouped_inputs.wls\"}];"->"hggGroupedSource=hggPolynomialSource;",
 "hggOwnOriginal=mapTargetTask[hggOwnIndex];"->"hggOwnOriginal=hggTermControl[];hggPolynomialInstall[];",
 "AbsoluteTiming[groupedMapExpression[hggOwnExpression,"->"AbsoluteTiming[hggPhaseMap[hggOwnExpression,",
 "hggGroupedNewCall=\"groupedMapExpression["->"hggGroupedNewCall=\"hggPhaseMap[",
 "DistributeDefinitions[groupDenominators, certifyGrouping,"->"DistributeDefinitions[hggPhaseMap,numericOuterFactor,numericPhaseMap,polynomialVariables,polynomialAdditivePieces,polynomialPieceMap,saveNative,pieceScientificHash,groupDenominators, certifyGrouping,",
 "\"OwnOriginalMapComparisonPassed\"->True|>];"->"\"OwnOriginalMapComparisonPassed\"->True,\"PolynomialMapping\"->hggPolynomialEvidence|>];"};
If[!And@@(StringCount[hggResponseRun,First[#]]===1&/@hggPolynomialEdits),Print["FAIL: unique Hgg polynomial handoffs"];Quit[1]];
hggPolynomialRun=StringReplace[hggResponseRun,hggPolynomialEdits];
If[!SyntaxQ[hggPolynomialRun]||StringReplace[hggPolynomialRun,Reverse/@hggPolynomialEdits]=!=hggResponseRun,Print["FAIL: complete original Hgg contract restoration"];Quit[1]];
ToExpression[hggPolynomialRun,InputForm];

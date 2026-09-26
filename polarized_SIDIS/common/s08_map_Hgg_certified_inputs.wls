(* Keep validated coefficient algebra and install accepted scalar reconstruction certificates. *)
certificateConsumerSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_certified_inputs.wls"}];
If[!SyntaxQ[Import[certificateConsumerSource,"Text"]]||IntegerString[FileHash[
 FileNameJoin[{Directory[],"common","s08_map_Hgg_factored_inputs.wls"}],"SHA256"],16,64]=!=
 "b9e6263fb6b83d585e5e50e09f7aee8d3b9299a406cff8f23b97031be98443be",Quit[1]];
hggCertificateInstall[]:=Module[{relative,path,receipt,proof,atomPath,ownPath},
 relative="Hgg/s08_scalar_certificate_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted full scalar reconstruction comparison",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["same complete scalar reconstruction contract",proof["Schema"]==="polarized-sidis-scalar-reconstruction-certificates-v1"&&
  proof["Channel"]===channel&&TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["ActualAcceptedComparison"]]&&
  And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["OriginalFamilyDefinitions"]===DownValues[familyRows]&&proof["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
  proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_scalar_reconstruction_certificates.wls"}],"SHA256"]&&
  proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]&&
  proof["PolynomialProofHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_polynomial_group_result","s08_result.wl"}],"SHA256"]];
 atomPath=FileNameJoin[{root,"Hgg","s08_factored_atom_certificate_result","s08_result.wl"}];
 ownPath=FileNameJoin[{root,"Hgg","s08_termwise_comparison_result","s08_result.wl"}];
 gate["exact accepted atom and original-term dependencies",proof["AtomProofHash"]===FileHash[atomPath,"SHA256"]&&
  proof["AtomReceiptHash"]===FileHash[FileNameJoin[{DirectoryName[atomPath],"s08_execution.json"}],"SHA256"]&&
  proof["OwnProofHash"]===FileHash[ownPath,"SHA256"]&&
  proof["OwnReceiptHash"]===FileHash[FileNameJoin[{DirectoryName[ownPath],"s08_execution.json"}],"SHA256"]&&
  proof["ActualGroupHash"]===FileHash[FileNameJoin[{root,proof["ActualGroupFile"]}],"SHA256"]&&
  proof["NativeInputHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}],"SHA256"]&&
  proof["NativeInputReceiptHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_recovery_execution.json"}],"SHA256"]];
 gate["measured actual-input improvement available",proof["ActualMappingSeconds"]<proof["PreviousActualSeconds"]];
 DownValues[familyRows]=proof["FamilyDefinitions"];DownValues[mapExpression]=proof["MappingDefinitions"];
 DownValues[certifyFamilyLaurent]=proof["FamilyCertificateDefinitions"];
 DownValues[certifyScalarReconstruction]=proof["MappingCertificateDefinitions"];
 gate["exact accepted scalar certificate definitions installed",{
  DownValues[familyRows],DownValues[mapExpression],DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction]}===
  Lookup[proof,{"FamilyDefinitions","MappingDefinitions","FamilyCertificateDefinitions","MappingCertificateDefinitions"}]];
 AssociateTo[hggPolynomialEvidence,"ScalarReconstruction"-><|"ConsumerSourceHash"->FileHash[certificateConsumerSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
  "ActualMappingSeconds"->proof["ActualMappingSeconds"],"PreviousActualSeconds"->proof["PreviousActualSeconds"]|>]];
(* Reuse the accepted polynomial group mapper with the own original-term control. *)
$HistoryLength=0;
hggPolynomialSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_factored_inputs.wls"}];
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
hggFactoredInstall[]:=Module[{relative,path,receipt,proof,recordPath,record,original},
 relative="Hgg/s08_factored_atom_certificate_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted complete factored-atom certificate execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];recordPath=FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}];record=Get[recordPath];
 gate["identical full extraction and grouping contract",proof["Schema"]==="polarized-sidis-factored-denominator-extraction-v1"&&proof["Channel"]===channel&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&proof["OriginalExtractionDefinitions"]===DownValues[extractAtoms]&&proof["OriginalGroupingCertificateDefinitions"]===DownValues[certifyGrouping]&&record["GroupingDefinitions"]===DownValues[groupDenominators]&&proof["NativeInputHash"]===FileHash[recordPath,"SHA256"]&&proof["NativeInputReceiptHash"]===FileHash[FileNameJoin[{DirectoryName[recordPath],"s08_recovery_execution.json"}],"SHA256"]&&proof["MapperHash"]===FileHash[targetMapperPath,"SHA256"]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_extract_factored_atom_certificate.wls"}],"SHA256"]&&proof["GroupingCertificateSourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_group_reconstruction.wls"}],"SHA256"]];
 gate["complete actual groups belong to accepted equations",proof["ActiveEquationReceiptHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_active_equations_result","s08_execution.json"}],"SHA256"]&&And@@(TrueQ[#["Accepted"]]&&FileHash[FileNameJoin[{root,#["File"]}],"SHA256"]===#["FileHash"]&/@proof["ActualGroups"])];
 atomVariables=proof["Variables"];DownValues[factoredAtoms]=proof["FactoredExtractionDefinitions"];DownValues[extractAtoms]=proof["DispatchDefinitions"];
 DownValues[factoredAtomCertificate]=proof["AtomCertificateDefinitions"];DownValues[certifyGrouping]=proof["GroupingCertificateDefinitions"];
 hggAcceptedGroups=proof["ActualGroups"];
 original=DownValues[groupDenominators];DownValues[hggOriginalGrouping]=original/.groupDenominators->hggOriginalGrouping;
 gate["unchanged original group construction",(DownValues[hggOriginalGrouping]/.hggOriginalGrouping->groupDenominators)===original];
 groupDenominators[value_]:=hggFactoredGroups[value];
 hggFactoredEvidence=<|"ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],"SourceHash"->proof["SourceHash"],"ControlComparisons"->proof["ControlComparisons"],"ActualGroups"->(KeyDrop[#,"Groups"]&/@hggAcceptedGroups),"OwnAcceptedComparison"->True|>];
hggFactoredGroups[expression_]:=Module[{identity,saved},
 identity=Hash[expression,"SHA256"];saved=SelectFirst[hggAcceptedGroups,#["ExpressionHash"]===identity&,Missing["UncachedInput"]];
 If[MissingQ[saved],Return[hggOriginalGrouping[expression]]];
 gate["exact accepted complete denominator grouping reused",TrueQ[saved["Accepted"]]&&saved["ExpressionHash"]===identity];
 Print["REUSED_COMPLETE_DENOMINATOR_GROUPS ",saved["Component"]];saved["Groups"]];
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
 hggPolynomialEvidence=<|"SourceHash"->FileHash[hggPolynomialSource,"SHA256"],"PolynomialProofHash"->FileHash[path,"SHA256"],"NumericPhaseSourceHash"->FileHash[phasePath,"SHA256"],"OriginalTermComparison"->hggTermEvidence|>;hggFactoredInstall[];hggCertificateInstall[];AssociateTo[hggPolynomialEvidence,"FactoredExtraction"->hggFactoredEvidence]];
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
 "DistributeDefinitions[groupDenominators, certifyGrouping,"->"DistributeDefinitions[certifyFamilyLaurent,certifyScalarReconstruction,factoredAtoms,factoredAtomCertificate,atomVariables,hggOriginalGrouping,hggFactoredGroups,hggAcceptedGroups,hggPhaseMap,numericOuterFactor,numericPhaseMap,polynomialVariables,polynomialAdditivePieces,polynomialPieceMap,saveNative,pieceScientificHash,groupDenominators, certifyGrouping,",
 "\"OwnOriginalMapComparisonPassed\"->True|>];"->"\"OwnOriginalMapComparisonPassed\"->True,\"PolynomialMapping\"->hggPolynomialEvidence|>];"};
If[!And@@(StringCount[hggResponseRun,First[#]]===1&/@hggPolynomialEdits),Print["FAIL: unique Hgg polynomial handoffs"];Quit[1]];
hggPolynomialRun=StringReplace[hggResponseRun,hggPolynomialEdits];
If[!SyntaxQ[hggPolynomialRun]||StringReplace[hggPolynomialRun,Reverse/@hggPolynomialEdits]=!=hggResponseRun,Print["FAIL: complete original Hgg contract restoration"];Quit[1]];
If[Environment["POLARIZED_SIDIS_SCALAR_CONSUMER_ONLY"]==="1",
 consumerBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
 If[IntegerString[FileHash[consumerBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
 consumerBootstrapText=Import[consumerBootstrapPath,"Text"];
 consumerBoundary=StringPosition[consumerBootstrapText,"\nIf[channel===\"Hgg\","];
 If[Length[consumerBoundary]=!=1,Quit[1]];
 consumerBootstrap=StringTake[consumerBootstrapText,First[First[consumerBoundary]]-1];
 If[!SyntaxQ[consumerBootstrap],Quit[1]];ToExpression[consumerBootstrap,InputForm];
 inputHashes=record["InputHashes"];targetInputHash=record["TargetInputHash"];targetMapperPath=mapper;
 DownValues[groupDenominators]=record["GroupingDefinitions"];
 DownValues[certifyGrouping]=record["GroupingCertificateDefinitions"];hggPolynomialEvidence=<||>;
 hggFactoredInstall[];hggCertificateInstall[];
 consumerDirectory=FileNameJoin[{root,"Hgg","s08_scalar_consumer_result"}];
 If[!DirectoryQ[consumerDirectory],CreateDirectory[consumerDirectory]];
 saveNative[<|"Schema"->"polarized-sidis-Hgg-scalar-certificate-consumer-v1",
  "Evidence"->hggPolynomialEvidence["ScalarReconstruction"],"DispatchHash"->Hash[hggPolynomialRun,"SHA256"],"Checks"->checks,
  "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>,
  FileNameJoin[{consumerDirectory,"s08_result.wl"}]];
 Export[FileNameJoin[{consumerDirectory,"s08_checks.json"}],<|"checks"->checks|>,"RawJSON"];
 Print["PASS: s08_Hgg_scalar_certificate_consumer"];Quit[0]];

ToExpression[hggPolynomialRun,InputForm];

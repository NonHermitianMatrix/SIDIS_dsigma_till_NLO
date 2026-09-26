(* Retain the accepted Hqg dispatcher and install receipt-bound factored grouping. *)
$HistoryLength=0;
hqgFactoredSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_factored_groups.wls"}];
hqgPhaseSource=FileNameJoin[{Directory[],"common","s08_resume_Hqg_polynomial_maps.wls"}];
If[!SyntaxQ[Import[hqgFactoredSource,"Text"]]||IntegerString[FileHash[hqgPhaseSource,"SHA256"],16,64]=!="1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9",Quit[1]];
hqgInstallFactoredGroups[]:=Module[{relative,path,receipt,proof,definitions,original},
 relative="Hqg/s08_factored_groups_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted own factored-group execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];definitions=proof["Definitions"];
 gate["same complete own factored-group contract",proof["Schema"]==="polarized-sidis-Hqg-factored-groups-v1"&&proof["Channel"]===channel&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&definitions["OriginalExtractionDefinitions"]===DownValues[extractAtoms]&&definitions["OriginalGroupingCertificateDefinitions"]===DownValues[certifyGrouping]&&proof["OriginalGroupingDefinitions"]===DownValues[groupDenominators]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hqg_factored_groups.wls"}],"SHA256"]];
 gate["bound complete own input and accepted algorithm",proof["NativeInputHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_mapping_inputs_result","s08_component_0004.wl"}],"SHA256"]&&proof["NativeInputReceiptHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_mapping_inputs_result","s08_recovery_execution.json"}],"SHA256"]&&proof["AlgorithmProofHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_factored_atom_certificate_result","s08_result.wl"}],"SHA256"]&&proof["AlgorithmReceiptHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_factored_atom_certificate_result","s08_execution.json"}],"SHA256"]];
 gate["complete saved core groups retain actual input identities",proof["PendingReceiptHash"]===FileHash[FileNameJoin[{root,"Hqg","s08_mapping_inputs_result","s08_pending_execution.json"}],"SHA256"]&&And@@(TrueQ[#["Accepted"]]&&#["FileHash"]===FileHash[FileNameJoin[{root,#["File"]}],"SHA256"]&&And@@Lookup[#["Cores"],"Accepted"]&/@proof["ActualGroups"])];
 atomVariables=definitions["Variables"];DownValues[factoredAtoms]=definitions["FactoredExtractionDefinitions"];
 DownValues[extractAtoms]=definitions["DispatchDefinitions"];DownValues[factoredAtomCertificate]=definitions["AtomCertificateDefinitions"];DownValues[certifyGrouping]=definitions["GroupingCertificateDefinitions"];
 hqgAcceptedGroups=Flatten[Lookup[proof["ActualGroups"],"Cores"]];
 original=DownValues[groupDenominators];DownValues[hqgOriginalGrouping]=original/.groupDenominators->hqgOriginalGrouping;
 gate["original Hqg group construction preserved",(DownValues[hqgOriginalGrouping]/.hqgOriginalGrouping->groupDenominators)===original];
 groupDenominators[value_]:=hqgFactoredGroups[value];
 AssociateTo[polynomialEvidence,"FactoredGrouping"-><|"SourceHash"->FileHash[hqgFactoredSource,"SHA256"],"ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],"OwnAcceptedComparison"->True,"OwnStructurallyIdenticalGroups"->proof["OwnStructurallyIdenticalGroups"]|>]];
hqgFactoredGroups[expression_]:=Module[{identity,saved},
 identity=Hash[expression,"SHA256"];saved=SelectFirst[hqgAcceptedGroups,#["ExpressionHash"]===identity&,Missing["UncachedInput"]];
 If[MissingQ[saved],Return[hqgOriginalGrouping[expression]]];
 gate["exact complete accepted Hqg core grouping reused",TrueQ[saved["Accepted"]]&&saved["ExpressionHash"]===identity];
 Print["REUSED_COMPLETE_HQG_CORE_GROUPS ",identity];saved["Groups"]];
hqgPhaseText=Import[hqgPhaseSource,"Text"];
hqgFactoredEdits={
 "polynomialSource=FileNameJoin[{Directory[],\"common\",\"s08_resume_Hqg_polynomial_maps.wls\"}];"->"polynomialSource=hqgFactoredSource;",
 "AssociateTo[polynomialEvidence,\"ProofHash\"->FileHash[path,\"SHA256\"]];installNumericPhase[]"->"AssociateTo[polynomialEvidence,\"ProofHash\"->FileHash[path,\"SHA256\"]];hqgInstallFactoredGroups[];installNumericPhase[]",
 "DistributeDefinitions[numericOuterFactor,"->"DistributeDefinitions[factoredAtoms,factoredAtomCertificate,atomVariables,hqgOriginalGrouping,hqgFactoredGroups,hqgAcceptedGroups,numericOuterFactor,",
 "phaseDirectory=FileNameJoin[{root,\"Hqg\",\"s08_numeric_phase_control_result\"}];"->"phaseDirectory=FileNameJoin[{root,\"Hqg\",\"s08_factored_control_result\"}];"};
If[!And@@(StringCount[hqgPhaseText,First[#]]===1&/@hqgFactoredEdits),Print["FAIL: unique Hqg factored handoffs"];Quit[1]];
hqgFactoredRun=StringReplace[hqgPhaseText,hqgFactoredEdits];
If[!SyntaxQ[hqgFactoredRun]||StringReplace[hqgFactoredRun,Reverse/@hqgFactoredEdits]=!=hqgPhaseText,Print["FAIL: complete Hqg dispatch restoration"];Quit[1]];
ToExpression[hqgFactoredRun,InputForm];

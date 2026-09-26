(* Reuse the executed factored-denominator algorithm on native Hqg inputs. *)
$HistoryLength=0;
reuseSource=FileNameJoin[{Directory[],"common","s08_check_Hqg_factored_groups.wls"}];
reuseBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
If[!SyntaxQ[Import[reuseSource,"Text"]]||IntegerString[FileHash[reuseBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
reuseBootstrapText=Import[reuseBootstrapPath,"Text"];reuseBoundary=StringPosition[reuseBootstrapText,"\nIf[channel===\"Hgg\","];
If[Length[reuseBoundary]=!=1,Quit[1]];
reuseBootstrap=StringTake[reuseBootstrapText,First[First[reuseBoundary]]-1];
If[!SyntaxQ[reuseBootstrap],Quit[1]];ToExpression[reuseBootstrap,InputForm];
gate["own Hqg factored-group comparison",channel==="Hqg"];
reuseRelative="Hgg/s08_factored_atom_certificate_result/s08_result.wl";reusePath=FileNameJoin[{root,reuseRelative}];
reuseReceiptPath=FileNameJoin[{DirectoryName[reusePath],"s08_execution.json"}];reuseReceipt=Import[reuseReceiptPath,"RawJSON"];
gate["accepted factored algorithm execution",TrueQ[reuseReceipt["passed"]]&&reuseReceipt["result_sha256"][reuseRelative]===IntegerString[FileHash[reusePath,"SHA256"],16,64]];
reuseProof=Get[reusePath];
gate["identical original scalar extraction contract",reuseProof["Schema"]==="polarized-sidis-factored-denominator-extraction-v1"&&reuseProof["Channel"]==="Hgg"&&TrueQ[reuseProof["OwnAcceptedComparison"]]&&And@@Values[reuseProof["Checks"]]&&reuseProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&reuseProof["MapperHash"]===FileHash[mapper,"SHA256"]&&reuseProof["OriginalExtractionDefinitions"]===DownValues[extractAtoms]&&reuseProof["OriginalGroupingCertificateDefinitions"]===record["GroupingCertificateDefinitions"]&&KeyDrop[reuseProof["InputHashes"],"Hgg/s05_result/s05_result.wl"]===KeyDrop[record["InputHashes"],"Hqg/s05_result/s05_result.wl"]&&reuseProof["Variables"]===(First/@families[First[familyNames]]["UncutCoordinateRules"])];
gate["accepted extraction source identity",reuseProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_extract_factored_atom_certificate.wls"}],"SHA256"]&&reuseProof["GroupingCertificateSourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_group_reconstruction.wls"}],"SHA256"]];
reuseDefinitions=KeyTake[reuseProof,{"OriginalExtractionDefinitions","OriginalGroupingCertificateDefinitions","FactoredExtractionDefinitions","DispatchDefinitions","AtomCertificateDefinitions","GroupingCertificateDefinitions","Variables"}];Clear[reuseProof];
atomVariables=reuseDefinitions["Variables"];DownValues[factoredAtoms]=reuseDefinitions["FactoredExtractionDefinitions"];
DownValues[factoredAtomCertificate]=reuseDefinitions["AtomCertificateDefinitions"];
reuseTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
gate["complete own original input inventory",Total[reuseTerms]===record["Expression"]];
reuseComparisons=MapIndexed[Function[{value,index},Module[{old,new,oldSeconds,newSeconds},
 Print["HQG_FACTORED_CONTROL_START ",First[index],"/",Length[reuseTerms]];
 {oldSeconds,old}=AbsoluteTiming[bounded[extractAtoms[value],{"own original atom",First[index]}]];
 {newSeconds,new}=AbsoluteTiming[bounded[factoredAtoms[value],{"reused atom",First[index]}]];
 gate["own original propagator powers reproduced",First[new]===First[old]];
 gate["own original full numerator reproduced",Last[new]===Last[old]||bounded[zero[Last[new]-Last[old]],{"own complete numerator",First[index]}]];
 <|"Index"->First[index],"OriginalAtom"->old,"OriginalSeconds"->oldSeconds,"CandidateSeconds"->newSeconds,"Accepted"->True|>]],reuseTerms];
gate["every own atom compared",Lookup[reuseComparisons,"Index"]===Range[Length[reuseTerms]]&&And@@Lookup[reuseComparisons,"Accepted"]];
reuseOriginalGroups=GroupBy[Lookup[reuseComparisons,"OriginalAtom"],First->Last,Total];
DownValues[extractAtoms]=reuseDefinitions["DispatchDefinitions"];DownValues[certifyGrouping]=reuseDefinitions["GroupingCertificateDefinitions"];
DownValues[groupDenominators]=record["GroupingDefinitions"];
{reuseOwnSeconds,reuseOwnGroups}=AbsoluteTiming[bounded[groupDenominators[record["Expression"]],"complete own Hqg grouping"]];
gate["complete own original grouping reproduced",Keys[reuseOwnGroups]===Keys[reuseOriginalGroups]&&And@@KeyValueMap[zero[#2-reuseOriginalGroups[#1]]&,reuseOwnGroups]];
reuseOwnIdentical=(reuseOwnGroups===reuseOriginalGroups);
reuseComparisons=KeyDrop[#,"OriginalAtom"]&/@reuseComparisons;Clear[reuseOwnGroups,reuseOriginalGroups,reuseTerms];
reusePhasePath=FileNameJoin[{root,"common","s08_resume_Hqg_polynomial_maps.wls"}];
gate["accepted numeric phase implementation",IntegerString[FileHash[reusePhasePath,"SHA256"],16,64]==="1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9"];
reusePhaseText=Import[reusePhasePath,"Text"];reusePhaseStart=StringPosition[reusePhaseText,"\nnumericOuterFactor[expression_]"];reusePhaseEnd=StringPosition[reusePhaseText,"\nnumericPhaseMap[expression_,key_]"];
gate["unique entire numeric factor helper",Length[reusePhaseStart]===1&&Length[reusePhaseEnd]===1];
reusePhaseBlock=StringTake[reusePhaseText,{First[First[reusePhaseStart]],First[First[reusePhaseEnd]]-1}];gate["numeric helper syntax",SyntaxQ[reusePhaseBlock]];ToExpression[reusePhaseBlock,InputForm];
factoredCoreInputs[value_]:=Module[{split,terms,packets},
 split=numericOuterFactor[value];
 If[First[split]=!=1,Return[{<|"Factor"->First[split],"Core"->Last[split]|>}]];
 If[Head[value]===Plus,terms=List@@value;
  If[AnyTrue[numericOuterFactor/@terms,First[#]=!=1&],
   packets=Flatten[factoredCoreInputs/@terms];
   gate["complete numeric core inventory reconstructs",Total[(#["Factor"] #["Core"])&/@packets]===value];Return[packets]]];
 {<|"Factor"->1,"Core"->value|>}];
reusePendingRelative="Hqg/s08_mapping_inputs_result/s08_pending_execution.json";reusePendingPath=FileNameJoin[{root,reusePendingRelative}];reusePendingReceipt=Import[reusePendingPath,"RawJSON"];
gate["accepted saved remaining inputs",TrueQ[reusePendingReceipt["passed"]]];
reuseActual=Table[Module[{relative,path,native,cores,groups,seconds},
 relative="Hqg/s08_mapping_inputs_result/s08_component_"<>IntegerString[index,10,4]<>".wl";path=FileNameJoin[{root,relative}];
 gate["accepted actual Hqg equation "<>ToString[index],reusePendingReceipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 native=Get[path];
 gate["same actual complete mapping input",native["Channel"]===channel&&native["Component"]===index&&native["InputHashes"]===record["InputHashes"]&&native["TargetInputHash"]===record["TargetInputHash"]&&native["NativeVersions"]===record["NativeVersions"]&&native["Denominators"]===denominators&&native["CoordinateRules"]===record["CoordinateRules"]&&And@@Values[native["Checks"]]];
 cores=factoredCoreInputs[native["Expression"]];
 gate["entire actual phase decomposition reconstructs",Total[(#["Factor"] #["Core"])&/@cores]===native["Expression"]];
 groups=MapIndexed[Function[{packet,position},Module[{value=packet["Core"],mapped,elapsed},
  Print["HQG_FACTORED_ACTUAL_START ",index," core ",First[position]," bytes ",ByteCount[value]];
  {elapsed,mapped}=AbsoluteTiming[bounded[groupDenominators[value],{"actual Hqg groups",index,First[position]}]];
  Print["HQG_FACTORED_ACTUAL_DONE ",index," core ",First[position]," seconds ",elapsed," groups ",Length[mapped]];
  <|"Factor"->packet["Factor"],"ExpressionHash"->Hash[value,"SHA256"],"Groups"->mapped,"Seconds"->elapsed,"Accepted"->True|>]],cores];
 <|"Component"->index,"File"->relative,"FileHash"->FileHash[path,"SHA256"],"Task"->native["Task"],"ExpressionHash"->Hash[native["Expression"],"SHA256"],"Cores"->groups,"Accepted"->True|>],{index,{30,31}}];
reuseResult=<|"Schema"->"polarized-sidis-Hqg-factored-groups-v1","Channel"->channel,"SourceHash"->FileHash[reuseSource,"SHA256"],"AlgorithmProofHash"->FileHash[reusePath,"SHA256"],"AlgorithmReceiptHash"->FileHash[reuseReceiptPath,"SHA256"],"NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],"PendingReceiptHash"->FileHash[reusePendingPath,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],"Definitions"->reuseDefinitions,"OriginalGroupingDefinitions"->record["GroupingDefinitions"],"OwnAcceptedComparison"->True,"OwnGroupingSeconds"->reuseOwnSeconds,"OwnStructurallyIdenticalGroups"->reuseOwnIdentical,"ControlComparisons"->reuseComparisons,"ActualGroups"->reuseActual,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
reuseDirectory=FileNameJoin[{root,channel,"s08_factored_groups_result"}];If[!DirectoryQ[reuseDirectory],CreateDirectory[reuseDirectory]];
saveNative[reuseResult,FileNameJoin[{reuseDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{reuseDirectory,"s08_checks.json"}],<|"checks"->checks,"control_measurements"->reuseComparisons,"own_structurally_identical_groups"->reuseOwnIdentical,"actual_measurements"->(Join[KeyTake[#,{"Component","Accepted"}],<|"Cores"->(KeyTake[#,{"Seconds","Accepted"}]&/@#["Cores"])|>]&/@reuseActual),"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_check_Hqg_factored_groups"];Quit[0];

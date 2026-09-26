(* Extract explicit denominator factors without recombining the large numerator. *)
$HistoryLength=0;
atomSource=FileNameJoin[{Directory[],"common","s08_extract_factored_denominators.wls"}];
atomBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
If[!SyntaxQ[Import[atomSource,"Text"]]||IntegerString[FileHash[atomBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
atomBootstrapText=Import[atomBootstrapPath,"Text"];
atomBoundary=StringPosition[atomBootstrapText,"\nIf[channel===\"Hgg\","];
If[Length[atomBoundary]=!=1,Quit[1]];
atomBootstrap=StringTake[atomBootstrapText,First[First[atomBoundary]]-1];
If[!SyntaxQ[atomBootstrap],Quit[1]];ToExpression[atomBootstrap,InputForm];
gate["own Hgg atom extraction comparison",channel==="Hgg"];
atomOriginalDefinitions=DownValues[extractAtoms];
atomVariables=First/@families[First[familyNames]]["UncutCoordinateRules"];
factoredAtoms[expression_]:=Module[{numerator,denominator,factors,powers,found,ratio,product,scale,prefactor},
 numerator=Numerator[expression];denominator=Denominator[expression];
 gate["original explicit rational input reconstructs",numerator/denominator===expression];
 gate["explicit numerator is a loop polynomial",PolynomialQ[numerator,atomVariables]];
 gate["explicit denominator is a loop polynomial",PolynomialQ[denominator,atomVariables]];
 factors=Rest[FactorList[denominator]];powers=ConstantArray[0,Length[denominators]];
 Do[If[!FreeQ[factor[[1]],Alternatives@@atomVariables],
   found=SelectFirst[Range[Length[denominators]],Function[index,
     ratio=Cancel[factor[[1]]/denominators[[index]]];ratio=!=0&&FreeQ[ratio,Alternatives@@atomVariables]],Missing["UnknownPropagator"]];
   gate["every loop-dependent factor is a generated propagator",!MissingQ[found]];
   powers[[found]]+=factor[[2]]],{factor,factors}];
 product=Times@@MapThread[Power,{denominators,powers}];
 scale=Cancel[product/denominator];
 gate["denominator ratio is loop independent",FreeQ[scale,Alternatives@@atomVariables]];
 gate["complete denominator scale reconstructs",Cancel[scale denominator-product]===0];
 prefactor=scale numerator;
 gate["atom extraction leaves a polynomial numerator",PolynomialQ[prefactor,atomVariables]];
 {powers,prefactor}];
atomTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
gate["complete own control term inventory",Total[atomTerms]===record["Expression"]];
atomComparisons=MapIndexed[Function[{value,index},Module[{old,new,oldSeconds,newSeconds},
 Print["FACTORED_ATOM_CONTROL_START ",First[index],"/",Length[atomTerms]];
 {oldSeconds,old}=AbsoluteTiming[bounded[extractAtoms[value],{"original atom",First[index]}]];
 {newSeconds,new}=AbsoluteTiming[bounded[factoredAtoms[value],{"factored atom",First[index]}]];
 gate["own original propagator powers unchanged",First[new]===First[old]];
 gate["own original polynomial prefactor reproduced",Last[new]===Last[old]||bounded[zero[Last[new]-Last[old]],{"own atom equality",First[index]}]];
 Print["FACTORED_ATOM_CONTROL_DONE ",First[index]," original ",oldSeconds," candidate ",newSeconds];
 <|"Index"->First[index],"OriginalSeconds"->oldSeconds,"CandidateSeconds"->newSeconds,"Accepted"->True|>]],atomTerms];
gate["entire own original extraction comparison passed",Lookup[atomComparisons,"Index"]===Range[Length[atomTerms]]&&And@@Lookup[atomComparisons,"Accepted"]];
DownValues[groupDenominators]=record["GroupingDefinitions"];
DownValues[certifyGrouping]=record["GroupingCertificateDefinitions"];
extractAtoms[value_]:=factoredAtoms[value];
atomReceiptRelative="Hgg/s08_active_equations_result/s08_execution.json";
atomReceipt=Import[FileNameJoin[{root,atomReceiptRelative}],"RawJSON"];
gate["accepted complete active equation export",TrueQ[atomReceipt["passed"]]];
atomActual=Table[Module[{relative,path,value,seconds,groups},
 relative="Hgg/s08_active_equations_result/s08_component_"<>IntegerString[index,10,4]<>"_equation.wl";
 path=FileNameJoin[{root,relative}];
 gate["actual equation hash "<>ToString[index],atomReceipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 value=Get[path];Print["FACTORED_ATOM_ACTUAL_START ",index," bytes ",ByteCount[value]];
 {seconds,groups}=AbsoluteTiming[bounded[groupDenominators[value],{"complete actual grouping",index}]];
 Print["FACTORED_ATOM_ACTUAL_DONE ",index," seconds ",seconds," groups ",Length[groups]];
 <|"Component"->index,"File"->relative,"FileHash"->FileHash[path,"SHA256"],"ExpressionHash"->Hash[value,"SHA256"],"Groups"->groups,"Seconds"->seconds,"Accepted"->True|>],{index,2}];
atomResult=<|"Schema"->"polarized-sidis-factored-denominator-extraction-v1","Channel"->channel,"SourceHash"->FileHash[atomSource,"SHA256"],"MapperHash"->FileHash[mapper,"SHA256"],"NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],"ActiveEquationReceiptHash"->FileHash[FileNameJoin[{root,atomReceiptRelative}],"SHA256"],"OriginalExtractionDefinitions"->atomOriginalDefinitions,"FactoredExtractionDefinitions"->DownValues[factoredAtoms],"DispatchDefinitions"->DownValues[extractAtoms],"Variables"->atomVariables,"OwnAcceptedComparison"->True,"ControlComparisons"->atomComparisons,"ActualGroups"->atomActual,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
atomDirectory=FileNameJoin[{root,channel,"s08_factored_atoms_result"}];If[!DirectoryQ[atomDirectory],CreateDirectory[atomDirectory]];
saveNative[atomResult,FileNameJoin[{atomDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{atomDirectory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,"control_measurements"->atomComparisons,"actual_measurements"->(KeyTake[#,{"Component","File","Seconds","Accepted"}]&/@atomActual),"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_extract_factored_denominators"];Quit[0];

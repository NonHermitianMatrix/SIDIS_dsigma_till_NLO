(* Reuse original scalar maps before assembling the external spin coefficients. *)
$HistoryLength=0;
basisSource=FileNameJoin[{Directory[],"common","s08_map_scalar_basis.wls"}];
basisBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
If[!SyntaxQ[Import[basisSource,"Text"]]||
 IntegerString[FileHash[basisBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
basisBootstrapText=Import[basisBootstrapPath,"Text"];
basisBoundary=StringPosition[basisBootstrapText,"\nIf[channel===\"Hgg\","];
If[Length[basisBoundary]=!=1,Quit[1]];
basisBootstrap=StringTake[basisBootstrapText,First[First[basisBoundary]]-1];
If[!SyntaxQ[basisBootstrap],Quit[1]];ToExpression[basisBootstrap,InputForm];
gate["isolated Hgg scalar-basis comparison",channel==="Hgg"];
DownValues[familyRows]=termOriginalFamily;
gate["unchanged original basis mapper",DownValues[mapExpression]===record["OriginalMappingDefinitions"]&&DownValues[familyRows]===record["OriginalFamilyDefinitions"]];
basisVariables=First/@families[First[familyNames]]["UncutCoordinateRules"];
gate["same original loop variables for every family",DuplicateFreeQ[basisVariables]&&And@@((First/@#["UncutCoordinateRules"])===basisVariables&/@Values[families])];
basisScientificHash=Hash[{FileHash[basisSource,"SHA256"],FileHash[mapper,"SHA256"],geometry,basisVariables,$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
basisRecords=<||>;basisConstructionSeconds=0;

basisUnitMap[powers_List,exponents_List]:=Module[{key,value,binding,saved,seconds,coefficients,evidence},
 key=Hash[{powers,exponents},"SHA256"];
 value=(Times@@MapThread[Power,{basisVariables,exponents}])/(Times@@MapThread[Power,{denominators,powers}]);
 binding=Hash[{basisScientificHash,powers,exponents,value},"SHA256"];
 saved=Lookup[basisRecords,key,Missing["NewScalarBasis"]];
 If[AssociationQ[saved],
  gate["scalar basis cache retains exact input",saved["Binding"]===binding&&TrueQ[saved["Accepted"]]&&And@@Values[saved["Checks"]]];
  Return[saved["Coefficients"]]];
 {seconds,evidence}=AbsoluteTiming[Block[{checks=<||>},
   coefficients=bounded[mapExpression[value],{"original scalar basis",powers,exponents}];
   <|"Binding"->binding,"Powers"->powers,"Exponents"->exponents,"Coefficients"->coefficients,"Checks"->checks,"Accepted"->True|>]];
 gate["complete original scalar basis checks passed",TrueQ[evidence["Accepted"]]&&Length[evidence["Checks"]]>0&&And@@Values[evidence["Checks"]]];
 AssociateTo[evidence,"Seconds"->seconds];AssociateTo[basisRecords,key->evidence];
 basisConstructionSeconds+=seconds;
 Print["SCALAR_BASIS_ACCEPTED ",Length[basisRecords]," seconds ",seconds];
 evidence["Coefficients"]];

scalarBasisMap[expression_]:=Module[{powers,numerator,rules,reconstructed,packets,rows,coefficients},
 If[expression===0,Return[<||>]];
 {powers,numerator}=extractAtoms[expression];
 gate["actual scalar numerator is polynomial",PolynomialQ[numerator,basisVariables]];
 rules=CoefficientRules[numerator,basisVariables];
 reconstructed=Total[(Last[#] Times@@MapThread[Power,{basisVariables,First[#]}])&/@rules];
 gate["complete actual monomial inventory reconstructs",zero[reconstructed-numerator]];
 gate["all extracted coefficients are loop independent",FreeQ[Last/@rules,Alternatives@@basisVariables]];
 packets=Map[Function[entry,
   coefficients=basisUnitMap[powers,First[entry]];
   Map[Last[entry] #&,coefficients]],rules];
 rows=merge[packets];
 gate["complete scalar basis map reconstructs actual input",zero[pairReconstruct[rows]-expression]];
 gate["scalar basis preserves both physical cuts",And@@(Take[#[[2]],Length[geometry["CutMomenta"]]]===ConstantArray[1,Length[geometry["CutMomenta"]]]&/@Keys[rows])];
 rows];

basisReferenceRelative=channel<>"/s08_termwise_comparison_result/s08_result.wl";
basisReferencePath=FileNameJoin[{root,basisReferenceRelative}];
basisReferenceReceiptPath=FileNameJoin[{DirectoryName[basisReferencePath],"s08_execution.json"}];
basisReferenceReceipt=Import[basisReferenceReceiptPath,"RawJSON"];
gate["accepted own original-term reference receipt",TrueQ[basisReferenceReceipt["passed"]]&&basisReferenceReceipt["result_sha256"][basisReferenceRelative]===IntegerString[FileHash[basisReferencePath,"SHA256"],16,64]];
basisReference=Get[basisReferencePath];
gate["same complete own scalar input and conventions",basisReference["Schema"]==="polarized-sidis-original-term-map-v1"&&basisReference["Channel"]===channel&&basisReference["Component"]===component&&basisReference["Task"]===record["Task"]&&basisReference["InputHash"]===record["TargetInputHash"]&&basisReference["InputHashes"]===record["InputHashes"]&&basisReference["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&basisReference["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&basisReference["NativeInputReceiptHash"]===FileHash[inputReceiptPath,"SHA256"]&&basisReference["MapperHash"]===FileHash[mapper,"SHA256"]&&TrueQ[basisReference["OwnAcceptedComparison"]]&&TrueQ[basisReference["ReconstructionPassed"]]&&And@@Values[basisReference["Checks"]]];
basisTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
gate["complete original outer input retained",Total[basisTerms]===record["Expression"]];
{basisMappingSeconds,basisPackets}=AbsoluteTiming[MapIndexed[Function[{term,index},Block[{checks=<||>},Module[{seconds,coefficients},
 Print["SCALAR_BASIS_TERM_START ",First[index],"/",Length[basisTerms]];
 {seconds,coefficients}=AbsoluteTiming[bounded[scalarBasisMap[term],{"actual scalar basis term",First[index]}]];
 Print["SCALAR_BASIS_TERM_DONE ",First[index]," seconds ",seconds," basis_count ",Length[basisRecords]];
 <|"Index"->First[index],"Accepted"->True,"Coefficients"->coefficients,"Seconds"->seconds,"Checks"->checks|>]]],basisTerms]];
gate["every complete original term accepted once",Lookup[basisPackets,"Index"]===Range[Length[basisTerms]]&&And@@Lookup[basisPackets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@basisPackets]];
{basisMergeSeconds,basisCoefficients}=AbsoluteTiming[bounded[merge[Lookup[basisPackets,"Coefficients"]],"complete scalar basis merge"]];
gate["complete scalar basis linear merge",bounded[certifyGroupMerge[basisPackets,basisCoefficients],"complete scalar basis merge certificate"]];
{basisEqualitySeconds,basisEqual}=AbsoluteTiming[bounded[basisCoefficients===basisReference["Coefficients"]||zero[pairReconstruct[basisCoefficients]-pairReconstruct[basisReference["Coefficients"]]],"entire own original map comparison"]];
gate["entire accepted own Hgg map reproduced",basisEqual];
basisResult=<|"Schema"->"polarized-sidis-scalar-basis-map-v1","Channel"->channel,"Component"->component,"Accepted"->True,"OwnAcceptedComparison"->basisEqual,"Coefficients"->basisCoefficients,"BasisRecords"->basisRecords,"BasisVariables"->basisVariables,"ScientificHash"->basisScientificHash,"MappingDefinitions"->DownValues[scalarBasisMap],"UnitMappingDefinitions"->DownValues[basisUnitMap],"OriginalMappingDefinitions"->record["OriginalMappingDefinitions"],"OriginalFamilyDefinitions"->record["OriginalFamilyDefinitions"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],"NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],"ReferenceHash"->FileHash[basisReferencePath,"SHA256"],"ReferenceReceiptHash"->FileHash[basisReferenceReceiptPath,"SHA256"],"MapperHash"->FileHash[mapper,"SHA256"],"SourceHash"->FileHash[basisSource,"SHA256"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"MappingSeconds"->basisMappingSeconds,"MergeSeconds"->basisMergeSeconds,"EqualitySeconds"->basisEqualitySeconds,"BasisConstructionSeconds"->basisConstructionSeconds,"TermEvidence"->(KeyDrop[#,"Coefficients"]&/@basisPackets),"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
basisDirectory=FileNameJoin[{root,channel,"s08_scalar_basis_result"}];If[!DirectoryQ[basisDirectory],CreateDirectory[basisDirectory]];
saveNative[basisResult,FileNameJoin[{basisDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{basisDirectory,"s08_checks.json"}],<|"channel"->channel,"component"->component,"checks"->checks,"mapping_seconds"->basisMappingSeconds,"merge_seconds"->basisMergeSeconds,"equality_seconds"->basisEqualitySeconds,"basis_construction_seconds"->basisConstructionSeconds,"basis_count"->Length[basisRecords],"reference_polynomial_term_seconds_sum"->Total[Lookup[basisReference["TermEvidence"],"Seconds"]],"native_peak_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_map_scalar_basis"];Quit[0];

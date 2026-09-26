(* Transform the small loop polynomial before assembling external coefficients. *)
$HistoryLength=0;root=Directory[];channel="Hqg";checks=<||>;
source=FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}];
gate[name_,test_]:=If[TrueQ[test],If[!KeyExistsQ[checks,name],Print["PASS: ",name]];AssociateTo[checks,name->True],Print["FAIL: ",name];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,1800,gate[ToString[{label,"time"},InputForm],False]],8*1024^3,gate[ToString[{label,"memory"},InputForm],False]];
zero[value_]:=Factor[Together[value]]===0;
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]&&StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[source,"Text"]]];
blockedPath=FileNameJoin[{root,channel,"s08_blocked_input_result","s08_result.wl"}];
blockedReceiptPath=FileNameJoin[{DirectoryName[blockedPath],"s08_execution.json"}];
blockedReceipt=Import[blockedReceiptPath,"RawJSON"];
gate["accepted native blocked input",TrueQ[blockedReceipt["passed"]]&&blockedReceipt["result_sha256"][channel<>"/s08_blocked_input_result/s08_result.wl"]===IntegerString[FileHash[blockedPath,"SHA256"],16,64]];
blocked=Get[blockedPath];gate["blocked input schema",blocked["Schema"]==="polarized-sidis-blocked-input-v1"&&blocked["Channel"]===channel&&And@@Values[blocked["Checks"]]];
KeyValueMap[Function[{name,hash},gate["unchanged actual input "<>name,FileHash[FileNameJoin[{root,name}],"SHA256"]===hash]],blocked["InputHashes"]];
ownPath=FileNameJoin[{root,channel,"s08_grouped_comparison_result","s08_result.wl"}];
ownReceiptPath=FileNameJoin[{DirectoryName[ownPath],"s08_execution.json"}];ownReceipt=Import[ownReceiptPath,"RawJSON"];
gate["accepted own grouped comparison",TrueQ[ownReceipt["passed"]]&&ownReceipt["result_sha256"][channel<>"/s08_grouped_comparison_result/s08_result.wl"]===IntegerString[FileHash[ownPath,"SHA256"],16,64]];
own=Get[ownPath];
gate["same own mapping inputs",own["Schema"]==="polarized-sidis-Hqg-grouped-comparison-v1"&&own["Channel"]===channel&&TrueQ[own["Accepted"]]&&TrueQ[own["OwnAcceptedComparison"]]&&And@@Values[own["Checks"]]&&own["NativeVersions"]==={$Version,$FeynCalcVersion}&&own["InputHashes"]===blocked["InputHashes"]&&own["TargetInputHash"]===blocked["TargetInputHash"]&&own["Denominators"]===blocked["Denominators"]];
geometryPath=FileNameJoin[{root,"common","s06_result","reference","s02_result.wl"}];geometry=Get[geometryPath]/.{Q2->Q^2,w->s23};
denominators=geometry["OnCutUncutPropagators"];directions=geometry["UncutDirections"];families=geometry["Families"];familyNames=Keys[families];
sameGeometry[left_Association,right_Association]:=Keys[left]===Keys[right]&&And@@KeyValueMap[sameGeometry[#2,right[#1]]&,left];
sameGeometry[left_List,right_List]:=Length[left]===Length[right]&&And@@MapThread[sameGeometry,{left,right}];
sameGeometry[left_Rule,right_Rule]:=First[left]===First[right]&&sameGeometry[Last[left],Last[right]];
sameGeometry[left_,right_]:=left===right||(FreeQ[{left,right},_String|_Association|_Rule|_List,{1,Infinity}]&&zero[left-right]);
gate["exact recorded geometry",sameGeometry[denominators,blocked["Denominators"]]&&sameGeometry[families,blocked["Families"]]];
families=blocked["Families"];
mapper=FileNameJoin[{root,"common","s08_result","reference","s08_map_real_spin_before_known_denominator.wls"}];
gate["original reference mapper identity",IntegerString[FileHash[mapper,"SHA256"],16,64]==="e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f"];
mapperText=Import[mapper,"Text"];starts=StringPosition[mapperText,"\nmerge[pieces_List]"];ends=StringPosition[mapperText,"\ncoefficientPath ="];
gate["unique original mapping block",Length[starts]===1&&Length[ends]===1];
mappingBlock=StringTake[mapperText,{First[First[starts]],First[First[ends]]-1}];gate["original mapping syntax",SyntaxQ[mappingBlock]];ToExpression[mappingBlock,InputForm];
definitions=own["AlgorithmDefinitions"];
gate["same complete original mapper",DownValues[mapExpression]===definitions["OriginalMappingDefinitions"]&&DownValues[merge]===definitions["OriginalMergeDefinitions"]];
DownValues[groupDenominators]=definitions["GroupingDefinitions"];DownValues[certifyGrouping]=definitions["GroupingCertificateDefinitions"];
DownValues[certifyPairMerge]=definitions["MergeCertificateDefinitions"];DownValues[certifyGroupMerge]=definitions["GroupMergeDefinitions"];DownValues[pairReconstruct]=definitions["ReconstructionDefinitions"];
groupInputHash=own["InputHash"];groupCache=FileNameJoin[{root,"cache","s08_Hqg_grouped_comparison",IntegerString[groupInputHash,16]}];
gate["blocked group exact original binding",Hash[{groupInputHash,"component_"<>ToString[blocked["Component"]],blocked["Group"],blocked["Value"]},"SHA256"]===blocked["GroupBinding"]];
controlGroups=bounded[groupDenominators[own["ActualExpression"]],"own accepted groups"];
controlPositions=Flatten[Position[Keys[controlGroups],blocked["GroupPowers"],{1}]];
gate["own accepted group has same denominator powers",Length[controlPositions]===1];controlIndex=First[controlPositions];
controlValues=KeyValueMap[#2/(Times@@MapThread[Power,{denominators,#1}])&,controlGroups];controlValue=controlValues[[controlIndex]];
controlKey="component_"<>ToString[own["ComponentIndex"]];
controlPath=FileNameJoin[{groupCache,controlKey<>"_group_"<>IntegerString[controlIndex,10,4]<>".wl"}];control=Get[controlPath];
gate["original control checkpoint binding",TrueQ[control["Accepted"]]&&And@@Values[control["Checks"]]&&control["Binding"]===Hash[{groupInputHash,controlKey,controlIndex,controlValue},"SHA256"]];
originalFamilyDefinitions=DownValues[familyRows];
variableLists=Cases[originalFamilyDefinitions,HoldPattern[CoefficientRules[_,vars_List]]:>vars,Infinity];
gate["original declared polynomial variables",Length[variableLists]===1&&DuplicateFreeQ[First[variableLists]]];polynomialVariables=First[variableLists];
familyRows[expression_,family_]:=Module[{spec,variables,rational,numerator,denominator,powers,constant,inputRules,inputReconstruction,pieces,polynomial,rows,reconstruction},
 spec=families[family];variables=First/@spec["UncutCoordinateRules"];
 Print["POLYNOMIAL_FAMILY_INPUT ",family];
 rational=Together[expression];numerator=Numerator[rational];denominator=Factor[Denominator[rational]/.spec["UncutCoordinateRules"]];
 gate["original family numerator polynomial",PolynomialQ[numerator,variables]];
 powers=Exponent[denominator,#]&/@polynomialVariables;
 constant=Cancel[denominator/(Times@@MapThread[Power,{polynomialVariables,powers}])];
 gate["family denominator is a Laurent monomial",FreeQ[constant,Alternatives@@polynomialVariables]];
 inputRules=CoefficientRules[numerator,variables];
 inputReconstruction=Total[(Last[#] Times@@MapThread[Power,{variables,First[#]}])&/@inputRules];
 gate["original numerator coefficients reconstruct",zero[inputReconstruction-numerator]];
 pieces=Map[Function[entry,Module[{monomial,shifted,shiftRules,shiftReconstruction},
   monomial=Times@@MapThread[Power,{variables,First[entry]}];shifted=monomial/.spec["UncutCoordinateRules"];
   shiftRules=CoefficientRules[Expand[shifted],polynomialVariables];
   shiftReconstruction=Total[(Last[#] Times@@MapThread[Power,{polynomialVariables,First[#]}])&/@shiftRules];
   gate["loop monomial substitution reconstructs",zero[shiftReconstruction-shifted]];
   Association[(First[#]->Last[entry] Last[#])&/@shiftRules]]],inputRules];
 polynomial=Merge[pieces,Total];
 rows=Association@KeyValueMap[Function[{key,value},CutIntegral[family,Join[ConstantArray[1,Length[geometry["CutMomenta"]]],powers-key]]->Factor[Together[value/constant]]],polynomial];
 rows=Select[rows,#=!=0&];
 reconstruction=Total[KeyValueMap[Function[{integral,coefficient},coefficient Times@@MapThread[Power,{polynomialVariables,-Drop[integral[[2]],2]}]],rows]];
 gate["family Laurent coefficients reconstruct",zero[reconstruction-(expression/.spec["UncutCoordinateRules"])]];rows];
candidateFamilyDefinitions=DownValues[familyRows];
{controlSeconds,controlCandidate}=AbsoluteTiming[bounded[mapExpression[controlValue],"own polynomial group map"]];
gate["every own accepted group coefficient unchanged",Sort[Keys[controlCandidate]]===Sort[Keys[control["Coefficients"]]]&&And@@KeyValueMap[zero[#2-control["Coefficients"][#1]]&,controlCandidate]];
{blockedSeconds,blockedCoefficients}=AbsoluteTiming[bounded[mapExpression[blocked["Value"]],"recorded blocked polynomial map"]];
proof=<|"Schema"->"polarized-sidis-polynomial-family-group-v1","Channel"->channel,"Accepted"->True,"OwnAcceptedComparison"->True,
 "InputHashes"->blocked["InputHashes"],"TargetInputHash"->blocked["TargetInputHash"],"GroupBinding"->blocked["GroupBinding"],
 "Component"->blocked["Component"],"Group"->blocked["Group"],"Coefficients"->blockedCoefficients,
 "OriginalFamilyDefinitions"->originalFamilyDefinitions,"CandidateFamilyDefinitions"->candidateFamilyDefinitions,"PolynomialVariables"->polynomialVariables,
 "SourceHash"->FileHash[source,"SHA256"],"MapperHash"->FileHash[mapper,"SHA256"],"BlockedInputHash"->FileHash[blockedPath,"SHA256"],
 "OwnComparisonHash"->FileHash[ownPath,"SHA256"],"OwnReceiptHash"->FileHash[ownReceiptPath,"SHA256"],"ControlHash"->FileHash[controlPath,"SHA256"],
 "OriginalControlSeconds"->control["Seconds"],"ControlSeconds"->controlSeconds,"BlockedSeconds"->blockedSeconds,"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
directory=FileNameJoin[{root,channel,"s08_polynomial_group_result"}];If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
saveNative[value_,path_]:=Module[{serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n"},gate["native file bound",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];gate["exact native export",Get[path<>".tmp"]===value];RenameFile[path<>".tmp",path,OverwriteTarget->True]];
proofPath=FileNameJoin[{directory,"s08_result.wl"}];saveNative[proof,proofPath];
checkpoint=<|"Binding"->blocked["GroupBinding"],"Accepted"->True,"Coefficients"->blockedCoefficients,"Checks"->checks,"Seconds"->blockedSeconds,"InputBytes"->ByteCount[blocked["Value"]],"PolynomialProofHash"->FileHash[proofPath,"SHA256"]|>;
checkpointPath=FileNameJoin[{groupCache,"component_"<>ToString[blocked["Component"]]<>"_group_"<>IntegerString[blocked["Group"],10,4]<>".wl"}];gate["no accepted checkpoint overwritten",!FileExistsQ[checkpointPath]];saveNative[checkpoint,checkpointPath];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,"original_control_seconds"->control["Seconds"],"control_seconds"->controlSeconds,"blocked_seconds"->blockedSeconds,"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_map_Hqg_polynomial_group"];Quit[0];

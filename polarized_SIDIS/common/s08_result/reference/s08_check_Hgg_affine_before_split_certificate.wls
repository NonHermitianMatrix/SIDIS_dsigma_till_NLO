(* Retain the input's native affine polynomial basis in the accepted family map. *)
$HistoryLength=0;
basisSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_affine_family_basis.wls"}];
basisSetup=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
If[!SyntaxQ[ReadString[basisSource]]||IntegerString[FileHash[basisSetup,"SHA256"],16,64]=!=
 "4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15",Quit[1]];
basisText=ReadString[basisSetup];basisBoundary=StringPosition[basisText,"\nreferenceConfigPath="];
If[Length[basisBoundary]=!=1,Quit[1]];
basisPrefix=StringTake[basisText,First[First[basisBoundary]]-1];
If[!SyntaxQ[basisPrefix],Quit[1]];ToExpression[basisPrefix,InputForm];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
basisRelative="Hgg/s08_failed_group_input_result/s08_result.wl";
basisPath=FileNameJoin[{root,basisRelative}];
basisReceipt=Import[FileNameJoin[{DirectoryName[basisPath],"s08_execution.json"}],"RawJSON"];
gate["accepted exact failed-group input export",TrueQ[basisReceipt["passed"]]&&
 basisReceipt["result_sha256"][basisRelative]===IntegerString[FileHash[basisPath,"SHA256"],16,64]];
basisInput=Get[basisPath];
gate["same failed group and entire native mapping contract",
 basisInput["Schema"]==="polarized-sidis-failed-group-input-v1"&&basisInput["Channel"]===channel&&
 basisInput["Component"]===38&&basisInput["Outer"]===2&&basisInput["Group"]===5&&
 basisInput["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_export_Hgg_failed_group_input.wls"}],"SHA256"]&&
 basisInput["InputHashes"]===record["InputHashes"]&&basisInput["TargetInputHash"]===record["TargetInputHash"]&&
 basisInput["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[basisInput["Checks"]]&&
 basisInput["Families"]===families&&basisInput["Denominators"]===denominators&&
 basisInput["FamilyDefinitions"]===DownValues[familyRows]&&
 basisInput["MappingDefinitions"]===DownValues[mapExpression]&&
 basisInput["OriginalMapDefinitions"]===DownValues[externalOriginalMap]];
basisOriginalFamily=DownValues[familyRows];
basisFixedDefinitions={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
 DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]};
basisVariables=First/@families[First[familyNames]]["UncutCoordinateRules"];
basisPowerBases=Cases[Last/@basisInput["ExternalSplits"],
 Power[base_,n_Integer?(#>0&)]/;!FreeQ[base,Alternatives@@basisVariables]:>base,Infinity];
basisCandidates=Map[Function[variable,Select[denominators,
 !FreeQ[#,variable]&&FreeQ[#,Alternatives@@DeleteCases[basisVariables,variable]]&&
 PolynomialQ[#,basisVariables]&&AllTrue[CoefficientRules[#,basisVariables],Total[First[#]]<=1&]&]],basisVariables];
gate["native numerator has a complete affine basis",AllTrue[basisCandidates,Length[#]>0&]];
basisScores=Map[Function[list,Count[basisPowerBases,#,{1}]&/@list],basisCandidates];
basisForms=MapThread[Function[{list,scores},First[Pick[list,scores,Max[scores]]]],{basisCandidates,basisScores}];
gate["input-derived affine coordinates differ from original variables",basisForms=!=basisVariables];
basisCoordinates=Table[Unique["sidisAffine$"],{Length[basisVariables]}];
basisSolutions=Solve[Thread[basisCoordinates==basisForms],basisVariables];
gate["native affine inverse is unique",Length[basisSolutions]===1];basisInverse=First[basisSolutions];
basisForward=Thread[basisCoordinates->basisForms];
gate["native affine inverse covers every original variable",Sort[First/@basisInverse]===Sort[basisVariables]];
gate["both complete affine compositions are identities",
 And@@MapThread[zero[#1-#2]&,{basisForms/.basisInverse,basisCoordinates}]&&
 And@@MapThread[zero[#1-#2]&,{(basisVariables/.basisInverse)/.basisForward,basisVariables}]];
Print["NATIVE_AFFINE_BASIS ",InputForm[<|"Variables"->basisVariables,"Candidates"->basisCandidates,
 "Scores"->basisScores,"Forms"->basisForms,"Inverse"->basisInverse|>]];

basisPrepareFamily[expression_,spec_]:=Module[{prepared,rules,originalCoordinates,reconstructedCoordinates},
 gate["family uses the recorded original loop variables",First/@spec["UncutCoordinateRules"]===basisVariables];
 prepared=expression/.basisInverse;
 gate["entire actual family input round trips exactly",(prepared/.basisForward)===expression||
  bounded[zero[(prepared/.basisForward)-expression],"entire actual affine roundtrip"]];
 rules=Thread[basisCoordinates->(basisForms/.spec["UncutCoordinateRules"])];
 originalCoordinates=basisVariables/.spec["UncutCoordinateRules"];
 reconstructedCoordinates=(basisVariables/.basisInverse)/.rules;
 gate["affine family routing equals entire original routing",
  And@@MapThread[zero[#1-#2]&,{originalCoordinates,reconstructedCoordinates}]];
 <|"Expression"->prepared,"Variables"->basisCoordinates,"CoordinateRules"->rules|>];

gate["complete current family source available",SyntaxQ[certificateFamilyCandidate]];
ToExpression[certificateFamilyCandidate,InputForm];
gate["complete original family source equals saved implementation",DownValues[familyRows]===basisOriginalFamily];
basisEdits={"Module[{spec,variables,rational,"->"Module[{basisPacket,spec,variables,rational,",
 "spec=families[family];variables=First/@spec[\"UncutCoordinateRules\"];"->
 "spec=families[family];basisPacket=basisPrepareFamily[expression,spec];spec=Append[spec,\"UncutCoordinateRules\"->basisPacket[\"CoordinateRules\"]];variables=basisPacket[\"Variables\"];",
 "rational=Together[expression];"->"rational=Together[basisPacket[\"Expression\"]];"};
gate["unique affine preparation interfaces",And@@(StringCount[certificateFamilyCandidate,First[#]]===1&/@basisEdits)];
basisCandidateText=StringReplace[certificateFamilyCandidate,basisEdits];
gate["all remaining family algebra restores exactly",SyntaxQ[basisCandidateText]&&
 StringReplace[basisCandidateText,Reverse/@basisEdits]===certificateFamilyCandidate];
ToExpression[basisCandidateText,InputForm];
basisSharedPath=FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}];
gate["exact own accepted group comparison binding",FileHash[basisSharedPath,"SHA256"]===basisInput["OwnProofHash"]];
basisShared=Get[basisSharedPath];
gate["same complete own accepted coefficients",TrueQ[basisShared["OwnAcceptedComparison"]]&&
 And@@Values[basisShared["Checks"]]&&basisShared["ActualInput"]["Equation"]===basisInput["OwnAcceptedEquation"]&&
 basisShared["FreshCoefficients"]===basisInput["OwnAcceptedCoefficients"]];
DownValues[polynomialAdditivePieces]=basisShared["AlgebraDefinitions"][[4]];
basisBinding=Hash[{FileHash[basisSource,"SHA256"],FileHash[basisPath,"SHA256"],basisForms,
 basisInput["InputHashes"],basisInput["TargetInputHash"],$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
basisCache=FileNameJoin[{root,"cache","s08_Hgg_affine_basis",IntegerString[basisBinding,16]}];
If[!DirectoryQ[basisCache],CreateDirectory[basisCache,CreateIntermediateDirectories->True]];
basisMapPieces[value_,label_]:=Module[{parts,packets,rows},
 parts=polynomialAdditivePieces[value];
 gate["complete affine input piece reconstruction "<>label,bounded[zero[Total[parts]-value],"affine piece identity"]];
 packets=MapIndexed[Function[{piece,index},Module[{path,binding,saved},
  binding=Hash[{basisBinding,piece},"SHA256"];
  path=FileNameJoin[{basisCache,IntegerString[binding,16]<>".wl"}];
  saved=If[FileExistsQ[path],Get[path],<||>];
  If[Lookup[saved,"Binding",None]=!=binding||!TrueQ[Lookup[saved,"Accepted",False]]||
   !AssociationQ[Lookup[saved,"Checks",None]]||Length[saved["Checks"]]===0||!And@@Values[saved["Checks"]],
   Print["AFFINE_MAP_PIECE_START ",label," ",First[index],"/",Length[parts]];
   saved=Block[{checks=<||>},Module[{seconds,coefficients},
    {seconds,coefficients}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
     mapExpression[piece],1800,gate["affine piece time bound",False]],4*1024^3,gate["affine piece original memory bound",False]]];
    <|"Binding"->binding,"Accepted"->True,"Coefficients"->coefficients,"Checks"->checks,"Seconds"->seconds|>]];
   saveNative[saved,path];Print["AFFINE_MAP_PIECE_DONE ",label," ",First[index]," seconds ",saved["Seconds"]]];saved]],parts];
 gate["all affine pieces accepted "<>label,And@@Lookup[packets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@packets]];
 rows=bounded[merge[Lookup[packets,"Coefficients"]],"affine full coefficient merge"];
 gate["no temporary affine coordinate in output "<>label,FreeQ[rows,Alternatives@@basisCoordinates]];
 gate["complete affine group merge reconstructs "<>label,certifyGroupMerge[packets,rows]];
 <|"Coefficients"->rows,"Pieces"->(KeyDrop[#,"Coefficients"]&/@packets)|>];

{basisOwnSeconds,basisOwn}=AbsoluteTiming[basisMapPieces[basisInput["OwnAcceptedEquation"],"own"]];
basisOwnRows=basisOwn["Coefficients"];
gate["every independently accepted own coefficient unchanged",Sort[Keys[basisOwnRows]]===Sort[Keys[basisInput["OwnAcceptedCoefficients"]]]&&
 And@@KeyValueMap[(#2===basisInput["OwnAcceptedCoefficients"][#1]||
  bounded[zero[#2-basisInput["OwnAcceptedCoefficients"][#1]],{"affine own coefficient",#1}])&,basisOwnRows]];
{basisActualSeconds,basisActual}=AbsoluteTiming[MemoryConstrained[
 basisMapPieces[basisInput["Equation"],"actual"],4*1024^3,gate["complete actual group original memory bound",False]]];
gate["all original mapping geometry and certificates unchanged",basisFixedDefinitions===
 {DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
  DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]}&&basisInput["Families"]===families];
basisResult=<|"Schema"->"polarized-sidis-affine-family-basis-v1","Channel"->channel,"Accepted"->True,
 "SourceHash"->FileHash[basisSource,"SHA256"],"InputHash"->FileHash[basisPath,"SHA256"],
 "InputHashes"->basisInput["InputHashes"],"TargetInputHash"->basisInput["TargetInputHash"],
 "Variables"->basisVariables,"Candidates"->basisCandidates,"Scores"->basisScores,"Forms"->basisForms,
 "Coordinates"->basisCoordinates,"Inverse"->basisInverse,"Forward"->basisForward,
 "PreparationDefinitions"->DownValues[basisPrepareFamily],"OriginalFamilyDefinitions"->basisOriginalFamily,
 "CandidateFamilyDefinitions"->DownValues[familyRows],"FixedDefinitions"->basisFixedDefinitions,
 "OwnAcceptedComparison"->True,"OwnCoefficients"->basisOwnRows,"OwnSeconds"->basisOwnSeconds,
 "ActualCoefficients"->basisActual["Coefficients"],"ActualPieces"->basisActual["Pieces"],"ActualSeconds"->basisActualSeconds,
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,
 "PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
basisDirectory=FileNameJoin[{root,"Hgg","s08_affine_basis_result"}];
If[!DirectoryQ[basisDirectory],CreateDirectory[basisDirectory]];
saveNative[basisResult,FileNameJoin[{basisDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{basisDirectory,"s08_checks.json"}],<|"checks"->checks,
 "forms_input_form"->ToString[basisForms,InputForm],"scores"->basisScores,"own_seconds"->basisOwnSeconds,
 "actual_seconds"->basisActualSeconds,"peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_affine_family_basis"];Quit[0];

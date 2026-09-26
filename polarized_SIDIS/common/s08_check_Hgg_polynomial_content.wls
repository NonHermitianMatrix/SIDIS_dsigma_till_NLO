(* Compare exact polynomial-content extraction before the accepted affine mapper. *)
$HistoryLength=0;
contentSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_polynomial_content.wls"}];
contentSetup=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
If[!SyntaxQ[ReadString[contentSource]]||IntegerString[FileHash[contentSetup,"SHA256"],16,64]=!=
 "4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15",Quit[1]];
contentText=ReadString[contentSetup];contentBoundary=StringPosition[contentText,"\nreferenceConfigPath="];
If[Length[contentBoundary]=!=1,Quit[1]];
contentPrefix=StringTake[contentText,First[First[contentBoundary]]-1];
If[!SyntaxQ[contentPrefix],Quit[1]];ToExpression[contentPrefix,InputForm];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
contentRead[relative_String]:=Module[{path,receipt},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted content comparison input "<>relative,TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];Get[path]];
contentAffine=contentRead["Hgg/s08_affine_piece_basis_result/s08_result.wl"];
contentSlow=contentRead["Hgg/s08_slow_group_input_result/s08_result.wl"];
contentKnown=contentRead["Hgg/s08_failed_group_input_result/s08_result.wl"];
contentShared=contentRead["Hgg/s08_shared_piece_cache_result/s08_result.wl"];
gate["complete accepted affine definitions and input identity",
 contentAffine["Schema"]==="polarized-sidis-affine-family-basis-v1"&&TrueQ[contentAffine["Accepted"]]&&
 TrueQ[contentAffine["OwnAcceptedComparison"]]&&And@@Values[contentAffine["Checks"]]&&
 contentAffine["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_affine_family_basis.wls"}],"SHA256"]&&
 contentAffine["OriginalFamilyDefinitions"]===DownValues[familyRows]&&
 contentAffine["FixedDefinitions"]==={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
  DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]}];
gate["both actual inputs retain the complete scalar contract",And@@Map[
 Function[item,item["InputHashes"]===record["InputHashes"]&&item["TargetInputHash"]===record["TargetInputHash"]&&
 item["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[item["Checks"]]&&
 item["Denominators"]===denominators&&item["FamilyDefinitions"]===DownValues[familyRows]&&
 item["MappingDefinitions"]===DownValues[mapExpression]&&item["OriginalMapDefinitions"]===DownValues[externalOriginalMap]],
 {contentSlow,contentKnown}]];
gate["exact accepted slow input source and selection",contentSlow["Schema"]==="polarized-sidis-selected-group-input-v1"&&
 contentSlow["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_export_Hgg_slow_group_input.wls"}],"SHA256"]&&
 {contentSlow["Component"],contentSlow["Outer"],contentSlow["Group"]}==={37,1,34}];
basisVariables=contentAffine["Variables"];basisForms=contentAffine["Forms"];basisCoordinates=contentAffine["Coordinates"];
basisInverse=contentAffine["Inverse"];basisForward=contentAffine["Forward"];
DownValues[basisPrepareFamily]=contentAffine["PreparationDefinitions"];
DownValues[basisPieceCertificate]=contentAffine["PieceCertificateDefinitions"];
DownValues[familyRows]=contentAffine["CandidateFamilyDefinitions"];
DownValues[polynomialAdditivePieces]=contentShared["AlgebraDefinitions"][[4]];
contentFixed={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],DownValues[familyRows],
 DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]};
contentEvidence={};
contentSplit[expression_]:=Module[{outer,core,prepared,numerator,denominator,factors,selected,remaining,
 factor,primitive,restored,seconds},
 {outer,core}=externalSplit[expression];prepared=core/.basisInverse;
 gate["content basis round trips the whole actual core",(prepared/.basisForward)===core||bounded[zero[(prepared/.basisForward)-core],"content roundtrip"]];
 numerator=Numerator[prepared];denominator=Denominator[prepared];
 gate["content numerator and denominator reconstruct exactly",numerator/denominator===prepared];
 gate["content numerator is a polynomial in the native loop basis",PolynomialQ[numerator,basisCoordinates]];
 Print["CONTENT_FACTOR_START bytes ",ByteCount[numerator]];
 {seconds,factors}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
  FactorTermsList[numerator,basisCoordinates],120,$Aborted],4*1024^3,$Aborted]];
 gate["bounded native polynomial-content extraction",ListQ[factors]&&Length[factors]>0];
 gate["every polynomial-content factor reconstructs the actual numerator",
  MemoryConstrained[TimeConstrained[Expand[Times@@factors-numerator]===0,120,False],4*1024^3,False]];
 selected=Select[factors,FreeQ[#,Alternatives@@basisCoordinates]&];
 remaining=Select[factors,!FreeQ[#,Alternatives@@basisCoordinates]&];
 factor=Times@@selected;primitive=Times@@remaining;
 gate["complete content factor partition",factor primitive===Times@@factors&&FreeQ[factor,Alternatives@@basisCoordinates]];
 restored=(primitive/denominator)/.basisForward;
 gate["content output has only original loop variables",FreeQ[{factor,restored},Alternatives@@basisCoordinates]];
 AppendTo[contentEvidence,<|"InputHash"->Hash[expression,"SHA256"],"FactorInputForm"->ToString[factor,InputForm],
  "InputBytes"->ByteCount[core],"CoreBytes"->ByteCount[restored],"NumeratorBytes"->ByteCount[numerator],
  "PrimitiveBytes"->ByteCount[primitive],"Seconds"->seconds|>];
 Print["CONTENT_FACTOR_DONE ",InputForm[Last[contentEvidence]]];{outer factor,restored}];
contentMap[expression_]:=Module[{factor,core,rows},
 If[expression===0,Return[mapExpression[expression]]];
 {factor,core}=contentSplit[expression];rows=mapExpression[core];Map[factor #&,rows]];
contentGroup[value_,label_]:=Module[{parts,packets,rows},
 parts=polynomialAdditivePieces[value];
 gate["complete content additive input "<>label,basisPieceCertificate[value,parts]];
 packets=MapIndexed[Function[{piece,index},Block[{checks=<||>},Module[{seconds,rows},
  Print["CONTENT_MAP_START ",label," ",First[index],"/",Length[parts]];
  {seconds,rows}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
   contentMap[piece],600,gate["content piece time bound",False]],4*1024^3,gate["content piece memory bound",False]]];
  Print["CONTENT_MAP_DONE ",label," ",First[index]," seconds ",seconds];
  <|"Coefficients"->rows,"Seconds"->seconds,"Checks"->checks,"Accepted"->True|>]]],parts];
 gate["every complete content piece accepted "<>label,And@@Lookup[packets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@packets]];
 rows=bounded[merge[Lookup[packets,"Coefficients"]],"content full merge"];
 gate["complete content group merge reconstructs "<>label,certifyGroupMerge[packets,rows]];
 <|"Coefficients"->rows,"PieceSeconds"->Lookup[packets,"Seconds"]|>];
contentSame[actual_,expected_]:=Sort[Keys[actual]]===Sort[Keys[expected]]&&
 And@@KeyValueMap[(#2===expected[#1]||bounded[zero[#2-expected[#1]],{"content coefficient",#1}])&,actual];
{contentOwnSeconds,contentOwn}=AbsoluteTiming[contentGroup[contentKnown["OwnAcceptedEquation"],"own"]];
gate["content mapper preserves every independently accepted own coefficient",contentSame[contentOwn["Coefficients"],contentAffine["OwnCoefficients"]]];
{contentKnownSeconds,contentKnownMap}=AbsoluteTiming[contentGroup[contentKnown["Equation"],"accepted38"]];
gate["content mapper preserves every accepted component38 group coefficient",contentSame[contentKnownMap["Coefficients"],contentAffine["ActualCoefficients"]]];
{contentSlowSeconds,contentSlowMap}=AbsoluteTiming[contentGroup[contentSlow["Equation"],"actual37"]];
gate["all original affine mapping and scalar certificates unchanged",contentFixed===
 {DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],DownValues[familyRows],
 DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]}];
contentResult=<|"Schema"->"polarized-sidis-polynomial-content-comparison-v1","Channel"->channel,
 "SourceHash"->FileHash[contentSource,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"OwnAcceptedComparison"->True,"KnownAcceptedComparison"->True,
 "OwnCoefficients"->contentOwn["Coefficients"],"KnownCoefficients"->contentKnownMap["Coefficients"],
 "ActualCoefficients"->contentSlowMap["Coefficients"],"OwnSeconds"->contentOwnSeconds,"KnownSeconds"->contentKnownSeconds,
 "ActualSeconds"->contentSlowSeconds,"Evidence"->contentEvidence,"SplitDefinitions"->DownValues[contentSplit],
 "MapDefinitions"->DownValues[contentMap],"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
contentDirectory=FileNameJoin[{root,"Hgg","s08_polynomial_content_result"}];
If[!DirectoryQ[contentDirectory],CreateDirectory[contentDirectory]];
saveNative[contentResult,FileNameJoin[{contentDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{contentDirectory,"s08_checks.json"}],<|"checks"->checks,"own_seconds"->contentOwnSeconds,
 "known_seconds"->contentKnownSeconds,"actual_seconds"->contentSlowSeconds,"evidence"->contentEvidence,
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_polynomial_content"];Quit[0];

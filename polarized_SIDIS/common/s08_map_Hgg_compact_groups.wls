(* Remove unused reconstructed sums; preserve all accepted exact certificates. *)
$HistoryLength=0;
compactSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_compact_groups.wls"}];
compactBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_certified_inputs.wls"}];
If[!SyntaxQ[Import[compactSource,"Text"]]||IntegerString[FileHash[compactBase,"SHA256"],16,64]=!=
 "27b5d28bff24828735784d339403c52888513c4d4b54c11e36a5ca66b5d1774f",Quit[1]];
compactBaseText=Import[compactBase,"Text"];
compactBegin=StringPosition[compactBaseText,"\nhggResponseText0="];
If[Length[compactBegin]=!=1,Quit[1]];
compactDefinitions=StringTake[compactBaseText,First[First[compactBegin]]-1];
If[!SyntaxQ[compactDefinitions],Quit[1]];ToExpression[compactDefinitions,InputForm];

compactGroupInstall[]:=Module[{source,text,begin,middle,end,groupOriginal,mapOriginal,
 oldGroup,oldMap,groupAssignment,mapAssignment,groupCandidate,mapCandidate,certificates},
 source=FileNameJoin[{root,"common","s08_grouped_mapping_check.wls"}];text=Import[source,"Text"];
 begin=StringPosition[text,"groupDenominators[expression_] :="];
 middle=StringPosition[text,"\n(* The reconstruction uses"];
 end=StringPosition[text,"\ngroupControlExpression ="];
 gate["unique full grouping source boundaries",Length[begin]===1&&Length[middle]===1&&Length[end]===1];
 groupOriginal=StringReplace[StringTake[text,{First[First[begin]],First[First[middle]]-1}],{
  "zero[expression - reconstructed]"->"certifyGrouping[expression, terms, atoms, groups]",
  "groupDenominators"->"hggOriginalGrouping"}];
 begin=StringPosition[text,"groupedMapExpression[expression_, key_]"];
 gate["unique full grouped map boundary",Length[begin]===1];
 mapOriginal=StringReplace[StringTake[text,{First[First[begin]],First[First[end]]-1}],
  "zero[reconstruction - expression]"->"certifyGroupMerge[packets, rows]"];
 oldGroup=DownValues[hggOriginalGrouping];oldMap=DownValues[groupedMapExpression];
 certificates={DownValues[certifyGrouping],DownValues[certifyGroupMerge],DownValues[extractAtoms],
  DownValues[mapExpression],DownValues[merge]};
 gate["entire original grouping sources parse",SyntaxQ[groupOriginal]&&SyntaxQ[mapOriginal]];
 ToExpression[groupOriginal,InputForm];ToExpression[mapOriginal,InputForm];
 gate["exact accepted grouping definitions restored",DownValues[hggOriginalGrouping]===oldGroup&&DownValues[groupedMapExpression]===oldMap];
 groupAssignment="  reconstructed = Total[KeyValueMap[#2/(Times @@ MapThread[Power, {denominators, #1}]) &, groups]];";
 mapAssignment="  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},\n    coefficient Times @@ MapThread[Power,\n      {families[integral[[1]]][\"OnCutUncutPropagators\"], -Drop[integral[[2]], 2]}]], rows]];";
 gate["exactly two unused reconstruction assignments",StringCount[groupOriginal,groupAssignment]===1&&StringCount[mapOriginal,mapAssignment]===1];
 groupCandidate=StringReplace[groupOriginal,groupAssignment->"  (* Grouping certificate retains the complete identity. *)"];
 mapCandidate=StringReplace[mapOriginal,mapAssignment->"  (* Merge certificate retains the complete identity. *)"];
 gate["only unused assignments removed",StringReplace[groupCandidate,"  (* Grouping certificate retains the complete identity. *)"->groupAssignment]===groupOriginal&&
  StringReplace[mapCandidate,"  (* Merge certificate retains the complete identity. *)"->mapAssignment]===mapOriginal];
 gate["complete compact grouping source syntax",SyntaxQ[groupCandidate]&&SyntaxQ[mapCandidate]];
 ToExpression[groupCandidate,InputForm];ToExpression[mapCandidate,InputForm];
 gate["all coefficient algorithms and exact certificates retained",certificates==={DownValues[certifyGrouping],DownValues[certifyGroupMerge],
  DownValues[extractAtoms],DownValues[mapExpression],DownValues[merge]}];
 compactOriginalDefinitions={oldGroup,oldMap};compactCandidateDefinitions={DownValues[hggOriginalGrouping],DownValues[groupedMapExpression]};];

If[Environment["POLARIZED_SIDIS_COMPACT_GROUP_CHECK"]==="1",
 compactBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
 If[IntegerString[FileHash[compactBootstrapPath,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
 compactBootstrapText=Import[compactBootstrapPath,"Text"];compactBoundary=StringPosition[compactBootstrapText,"\nIf[channel===\"Hgg\","];
 If[Length[compactBoundary]=!=1,Quit[1]];
 compactBootstrap=StringTake[compactBootstrapText,First[First[compactBoundary]]-1];
 If[!SyntaxQ[compactBootstrap],Quit[1]];ToExpression[compactBootstrap,InputForm];
 inputHashes=record["InputHashes"];targetInputHash=record["TargetInputHash"];targetMapperPath=mapper;
 DownValues[groupDenominators]=record["GroupingDefinitions"];DownValues[certifyGrouping]=record["GroupingCertificateDefinitions"];
 compactAlgorithmPath=FileNameJoin[{root,"Hgq","s08_certified_denominator_result","s08_result.wl"}];
 compactAlgorithmReceipt=Import[FileNameJoin[{DirectoryName[compactAlgorithmPath],"s08_execution.json"}],"RawJSON"];
 gate["accepted grouped-map definitions",TrueQ[compactAlgorithmReceipt["passed"]]&&compactAlgorithmReceipt["result_sha256"]["Hgq/s08_certified_denominator_result/s08_result.wl"]===IntegerString[FileHash[compactAlgorithmPath,"SHA256"],16,64]];
 compactAlgorithm=Get[compactAlgorithmPath];
 gate["same native grouped-map contract",compactAlgorithm["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[compactAlgorithm["Checks"]]&&
  compactAlgorithm["GroupingDefinitions"]===record["GroupingDefinitions"]&&compactAlgorithm["GroupMergeDefinitions"]===DownValues[certifyGroupMerge]&&
  compactAlgorithm["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_certified_denominator_mapping.wls"}],"SHA256"]];
 DownValues[groupedMapExpression]=compactAlgorithm["MappingDefinitions"];Clear[compactAlgorithm];
 hggPolynomialEvidence=<||>;hggFactoredInstall[];hggCertificateInstall[];compactGroupInstall[];
 groupInputHash=Hash[{FileHash[hggPolynomialSource,"SHA256"],FileHash[compactAlgorithmPath,"SHA256"],inputHashes,targetInputHash,
  component,Hash[record["Expression"],"SHA256"],$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
 groupCache=FileNameJoin[{root,"cache","s08_Hgg_grouped",IntegerString[groupInputHash,16]}];
 gate["existing complete own group checkpoints",DirectoryQ[groupCache]];
 put[value_,path_]:=saveNative[value,path];
 compactOwnPath=FileNameJoin[{root,"Hgg","s08_termwise_comparison_result","s08_result.wl"}];
 compactOwnReceipt=Import[FileNameJoin[{DirectoryName[compactOwnPath],"s08_execution.json"}],"RawJSON"];
 gate["accepted own original map",TrueQ[compactOwnReceipt["passed"]]&&compactOwnReceipt["result_sha256"]["Hgg/s08_termwise_comparison_result/s08_result.wl"]===IntegerString[FileHash[compactOwnPath,"SHA256"],16,64]];
 compactOwn=Get[compactOwnPath];
 gate["identical own full-map input",compactOwn["InputHash"]===targetInputHash&&compactOwn["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&
  compactOwn["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[compactOwn["Checks"]]&&TrueQ[compactOwn["OwnAcceptedComparison"]]];
 Print["COMPACT_GROUP_OWN_START ",component];
 {compactOwnSeconds,compactOwnRows}=AbsoluteTiming[bounded[groupedMapExpression[record["Expression"],"component_"<>ToString[component]],"complete compact own map"]];
 gate["entire accepted own raw map unchanged",Sort[Keys[compactOwnRows]]===Sort[Keys[compactOwn["Coefficients"]]]&&
  And@@KeyValueMap[(#2===compactOwn["Coefficients"][#1]||bounded[zero[#2-compactOwn["Coefficients"][#1]],{"own coefficient",#1}])&,compactOwnRows]];
 Print["COMPACT_GROUP_OWN_ACCEPTED seconds ",compactOwnSeconds];Clear[compactOwnRows,compactOwn];ClearSystemCache[];
 compactReceiptPath=FileNameJoin[{root,"Hgg","s08_blocked_equations_result","s08_execution.json"}];
 compactReceipt=Import[compactReceiptPath,"RawJSON"];gate["accepted actual failed equations",TrueQ[compactReceipt["passed"]]];
 compactMeasurements=Table[Module[{relative,path,value,seconds,groups,bytes},
  relative="Hgg/s08_blocked_equations_result/s08_component_"<>IntegerString[index,10,4]<>"_equation.wl";path=FileNameJoin[{root,relative}];
  gate["exact actual failed equation "<>ToString[index],compactReceipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
  value=Get[path];bytes=ByteCount[value];Print["COMPACT_GROUP_ACTUAL_START ",index," bytes ",bytes];
  {seconds,groups}=AbsoluteTiming[bounded[hggOriginalGrouping[value],{"actual compact grouping",index}]];
  Print["COMPACT_GROUP_ACTUAL_ACCEPTED ",index," groups ",Length[groups]," seconds ",seconds];
  <|"Component"->index,"EquationHash"->FileHash[path,"SHA256"],"ExpressionBytes"->bytes,"GroupCount"->Length[groups],"Seconds"->seconds,
    "GroupsHash"->Hash[groups,"SHA256"],"MemoryBytes"->MemoryInUse[]|>],{index,{12,13}}];
 compactResult=<|"Schema"->"polarized-sidis-compact-grouping-v1","Channel"->channel,"SourceHash"->FileHash[compactSource,"SHA256"],
  "BaseHash"->FileHash[compactBase,"SHA256"],"InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,
  "OriginalDefinitions"->compactOriginalDefinitions,"CandidateDefinitions"->compactCandidateDefinitions,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"OwnAcceptedComparison"->True,"OwnMappingSeconds"->compactOwnSeconds,
  "ActualEquationReceiptHash"->FileHash[compactReceiptPath,"SHA256"],"ActualMeasurements"->compactMeasurements,"Checks"->checks,
  "PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
 compactDirectory=FileNameJoin[{root,"Hgg","s08_compact_groups_result"}];If[!DirectoryQ[compactDirectory],CreateDirectory[compactDirectory]];
 saveNative[compactResult,FileNameJoin[{compactDirectory,"s08_result.wl"}]];
 Export[FileNameJoin[{compactDirectory,"s08_checks.json"}],<|"checks"->checks,"own_seconds"->compactOwnSeconds,"actual"->compactMeasurements,
  "peak_kernel_memory_bytes"->MaxMemoryUsed[],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
 Print["PASS: s08_Hgg_compact_groups"];Quit[0]];
Print["FAIL: compact grouping production requires accepted comparison and explicit installation"];Quit[1];

(* Separate the saved metric spin polynomial before the accepted scalar mapper. *)
$HistoryLength=0;
spinSplitSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_metric_spin_split.wls"}];
spinSplitBase=FileNameJoin[{Directory[],"common","s08_check_Hgg_additive_reconstruction.wls"}];
If[!SyntaxQ[ReadString[spinSplitSource]]||IntegerString[FileHash[spinSplitBase,"SHA256"],16,64]=!=
 "61071a42a311a84ebdbf30fdb33bd7b9e8d9c86c21a17172b4e1b5004ddfd221",Quit[1]];
spinSplitText=ReadString[spinSplitBase];spinSplitBoundary=StringPosition[spinSplitText,"\nadditiveTaskPositions="];
If[Length[spinSplitBoundary]=!=1,Quit[1]];
spinSplitPrefix=StringTake[spinSplitText,First[First[spinSplitBoundary]]-1];
If[!SyntaxQ[spinSplitPrefix],Quit[1]];ToExpression[spinSplitPrefix,InputForm];
spinSplitReader=readAccepted["Hgg/s08_metric_reader_result/s08_result.wl"];
gate["same accepted full metric reader",spinSplitReader["Schema"]==="polarized-sidis-metric-reader-correction-v1"&&
 spinSplitReader["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_metric_reader.wls"}],"SHA256"]&&
 spinSplitReader["InputHashes"]===record["InputHashes"]&&spinSplitReader["TargetInputHash"]===record["TargetInputHash"]&&
 spinSplitReader["NativeVersions"]===importedNativeVersions&&TrueQ[spinSplitReader["ActualMetricComparison"]]&&
 spinSplitReader["OriginalReaderDefinitions"]===DownValues[hggTaskValue]&&
 spinSplitReader["TaskInventoryHash"]===Hash[{hggTaskMetadata,hggTaskSources},"SHA256"]];
DownValues[hggTaskValue]=spinSplitReader["CandidateReaderDefinitions"];
spinSplitIndex=spinSplitReader["Component"];spinSplitTask=hggTaskMetadata[[spinSplitIndex]];
gate["accepted scalar task identity",spinSplitTask===spinSplitReader["Task"]&&spinSplitTask["Kind"]==="PhotonMetricD"];
spinSplitVariables=DeleteDuplicates[DeleteCases[Join[spin["ComponentStorage"]["IncomingVariables"],
 spin["ComponentStorage"]["OutgoingVariables"]],1]];
gate["spin variables are independent recorded symbols",Length[spinSplitVariables]>0&&
 AllTrue[spinSplitVariables,Head[#]===Symbol&]&&Intersection[spinSplitVariables,externalVariables]==={}];
Print["METRIC_SPIN_VARIABLES ",InputForm[spinSplitVariables]];
Print["METRIC_SPIN_READ_START ",spinSplitIndex];
{spinSplitReadSeconds,spinSplitRaw}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[spinSplitIndex],"complete accepted scalar input"]];
spinSplitExpression=bounded[spinSplitRaw/.coordinateRules,"exact metric coordinates"];
Clear[spinSplitRaw,hggCachedValue,hggCachedKey];ClearSystemCache[];
{spinSplitGroupingSeconds,spinSplitGroups}=AbsoluteTiming[bounded[hggOriginalGrouping[spinSplitExpression],"complete metric denominator grouping"]];
spinSplitGroupIndex=4;
gate["selected slow production group exists",Length[spinSplitGroups]>=spinSplitGroupIndex];
spinSplitPowers=Keys[spinSplitGroups][[spinSplitGroupIndex]];
spinSplitEquation=Values[spinSplitGroups][[spinSplitGroupIndex]]/(Times@@MapThread[Power,{denominators,spinSplitPowers}]);
Clear[spinSplitExpression,spinSplitGroups,spin];ClearSystemCache[];
spinSplitGroupHash=Hash[{FileHash[FileNameJoin[{root,"common","s08_map_Hgg_factored_inputs.wls"}],"SHA256"],
 FileHash[FileNameJoin[{root,"Hgq","s08_certified_denominator_result","s08_result.wl"}],"SHA256"],
 record["InputHashes"],record["TargetInputHash"],record["Component"],Hash[record["Expression"],"SHA256"],
 $Version,FeynCalc`$FeynCalcVersion},"SHA256"];
spinSplitCacheRelative=FileNameJoin[{"cache","s08_Hgg_grouped",IntegerString[spinSplitGroupHash,16],
 "component_"<>ToString[spinSplitIndex]<>"_group_"<>IntegerString[spinSplitGroupIndex,10,4]<>".wl"}];
spinSplitCachePath=FileNameJoin[{root,spinSplitCacheRelative}];
gate["pinned accepted complete metric group",IntegerString[FileHash[spinSplitCachePath,"SHA256"],16,64]===
 "b7978d3fe12b33c60b54a4596361b741b0a9b1915d286cf6c0049cd775f99d61"];
spinSplitExpected=bounded[Get[spinSplitCachePath],"accepted complete metric map"];
gate["entire actual group input binding",TrueQ[spinSplitExpected["Accepted"]]&&Length[spinSplitExpected["Checks"]]>0&&
 And@@Values[spinSplitExpected["Checks"]]&&spinSplitExpected["Binding"]===Hash[{spinSplitGroupHash,
 "component_"<>ToString[spinSplitIndex],spinSplitGroupIndex,spinSplitEquation},"SHA256"]];
spinSplitAffine=readAccepted["Hgg/s08_affine_piece_basis_result/s08_result.wl"];
gate["same accepted affine mapping definitions",TrueQ[spinSplitAffine["Accepted"]]&&TrueQ[spinSplitAffine["OwnAcceptedComparison"]]&&
 spinSplitAffine["InputHashes"]===record["InputHashes"]&&spinSplitAffine["TargetInputHash"]===record["TargetInputHash"]&&
 spinSplitAffine["NativeVersions"]===importedNativeVersions&&spinSplitAffine["OriginalFamilyDefinitions"]===DownValues[familyRows]&&
 spinSplitAffine["FixedDefinitions"]==={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
 DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]}];
basisVariables=spinSplitAffine["Variables"];basisForms=spinSplitAffine["Forms"];basisCoordinates=spinSplitAffine["Coordinates"];
basisInverse=spinSplitAffine["Inverse"];basisForward=spinSplitAffine["Forward"];
DownValues[basisPrepareFamily]=spinSplitAffine["PreparationDefinitions"];
DownValues[familyRows]=spinSplitAffine["CandidateFamilyDefinitions"];
spinSplitEarly=readAccepted["Hgg/s08_affine_cancel_exact_result/s08_result.wl"];
spinSplitFixed={DownValues[mapExpression],DownValues[merge],DownValues[familyRows],DownValues[certifyFamilyLaurent],
 DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]};
gate["same accepted early affine mapper",TrueQ[spinSplitEarly["OwnAcceptedComparison"]]&&TrueQ[spinSplitEarly["KnownAcceptedComparison"]]&&
 spinSplitEarly["InputHashes"]===record["InputHashes"]&&spinSplitEarly["TargetInputHash"]===record["TargetInputHash"]&&
 spinSplitEarly["NativeVersions"]===importedNativeVersions&&spinSplitEarly["FixedDefinitions"]===spinSplitFixed&&
 spinSplitEarly["OriginalMappingDefinitions"]===DownValues[externalOriginalMap]&&
 (spinSplitEarly["CandidateMappingDefinitions"]/.earlyAffineCancel->Cancel)===DownValues[externalOriginalMap]];
DownValues[earlyAffineCancel]=spinSplitEarly["CancelDefinitions"];
DownValues[externalOriginalMap]=spinSplitEarly["CandidateMappingDefinitions"];cancelEvidence={};
spinPolynomialPieces[expression_]:=Module[{numerator,denominator,rules,monomials,reconstructed,seconds},
 numerator=Numerator[expression];denominator=Denominator[expression];
 gate["spin polynomial complete rational input",numerator/denominator===expression];
 gate["spin independent denominator",FreeQ[denominator,Alternatives@@spinSplitVariables]];
 gate["polynomial in the saved spin basis",PolynomialQ[numerator,spinSplitVariables]];
 {seconds,rules}=AbsoluteTiming[bounded[CoefficientRules[numerator,spinSplitVariables],"native spin coefficient extraction"]];
 gate["native nonempty spin polynomial",ListQ[rules]&&Length[rules]>0&&AllTrue[rules,MatchQ[#,_Rule]&]];
 monomials=(Times@@MapThread[Power,{spinSplitVariables,First[#]}])&/@rules;
 reconstructed=Total[MapThread[Times,{monomials,Last/@rules}]];
 gate["every spin coefficient reconstructs the entire numerator",bounded[Expand[reconstructed-numerator]===0,"exact complete spin polynomial reconstruction"]];
 gate["all extracted coefficients are spin independent",FreeQ[Last/@rules,Alternatives@@spinSplitVariables]];
 Print["METRIC_SPIN_SPLIT ",InputForm[<|"InputBytes"->ByteCount[expression],"Terms"->Length[rules],
 "CoefficientBytes"->(ByteCount/@(Last/@rules)),"Seconds"->seconds|>]];
 MapThread[{#1,#2/denominator}&,{monomials,Last/@rules}]];
spinPolynomialMap[expression_]:=Module[{parts,packets,rows},
 parts=spinPolynomialPieces[expression];
 packets=MapIndexed[Function[{part,index},Block[{checks=<||>},Module[{seconds,scalar,weighted},
 Print["METRIC_SPIN_MAP_START ",First[index],"/",Length[parts]," monomial ",InputForm[First[part]]];
 {seconds,scalar}=AbsoluteTiming[bounded[mapExpression[Last[part]],{"metric scalar spin coefficient",First[index]}]];
 weighted=Map[First[part] #&,scalar];
 gate["spin monomial independent of every loop coordinate",FreeQ[First[part],Alternatives@@externalVariables]];
 gate["spin restoration preserves the integral inventory",Keys[weighted]===Keys[scalar]];
 Print["METRIC_SPIN_MAP_DONE ",First[index]," seconds ",seconds];
 <|"Coefficients"->weighted,"Seconds"->seconds,"Checks"->checks,"Accepted"->True|>]]],parts];
 gate["all complete spin coefficient maps accepted",And@@Lookup[packets,"Accepted"]&&And@@Flatten[Values[# ["Checks"]]&/@packets]];
 rows=bounded[merge[Lookup[packets,"Coefficients"]],"complete spin polynomial map merge"];
 gate["entire spin polynomial merge reconstructs",certifyGroupMerge[packets,rows]];
 <|"Coefficients"->rows,"PieceSeconds"->Lookup[packets,"Seconds"],"PieceChecks"->Lookup[packets,"Checks"]|>];
spinSplitDirectory=FileNameJoin[{root,"Hgg","s08_metric_spin_split_result"}];
If[!DirectoryQ[spinSplitDirectory],CreateDirectory[spinSplitDirectory]];
saveNative[<|"Equation"->spinSplitEquation,"SpinVariables"->spinSplitVariables,"Denominators"->denominators,
 "Component"->spinSplitIndex,"Group"->spinSplitGroupIndex,"Powers"->spinSplitPowers,
 "Binding"->spinSplitExpected["Binding"]|>,FileNameJoin[{spinSplitDirectory,"s08_input_equation.wl"}]];
{spinSplitSeconds,spinSplitActual}=AbsoluteTiming[spinPolynomialMap[spinSplitEquation]];
gate["identical complete accepted metric integral inventory",Sort[Keys[spinSplitActual["Coefficients"]]]===Sort[Keys[spinSplitExpected["Coefficients"]]]];
gate["every accepted metric group coefficient agrees exactly",And@@KeyValueMap[
 (#2===spinSplitExpected["Coefficients"][#1]||bounded[zero[#2-spinSplitExpected["Coefficients"][#1]],{"complete metric coefficient",#1}])&,
 spinSplitActual["Coefficients"]]];
gate["all inherited mapping algorithms remain unchanged",spinSplitFixed==={DownValues[mapExpression],DownValues[merge],
 DownValues[familyRows],DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]}&&
 DownValues[externalOriginalMap]===spinSplitEarly["CandidateMappingDefinitions"]];
spinSplitResult=<|"Schema"->"polarized-sidis-metric-spin-polynomial-v1","Channel"->channel,
 "SourceHash"->FileHash[spinSplitSource,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->importedNativeVersions,"Component"->spinSplitIndex,"Task"->spinSplitTask,
 "Group"->spinSplitGroupIndex,"Powers"->spinSplitPowers,"SpinVariables"->spinSplitVariables,
 "AcceptedGroupFile"->spinSplitCacheRelative,"AcceptedGroupHash"->FileHash[spinSplitCachePath,"SHA256"],
 "AcceptedGroupBinding"->spinSplitExpected["Binding"],"OwnAcceptedComparison"->True,
 "OriginalSeconds"->spinSplitExpected["Seconds"],"CandidateSeconds"->spinSplitSeconds,
 "SpeedupObserved"->TrueQ[spinSplitSeconds<spinSplitExpected["Seconds"]],
 "ReadSeconds"->spinSplitReadSeconds,"GroupingSeconds"->spinSplitGroupingSeconds,
 "Coefficients"->spinSplitActual["Coefficients"],"PieceSeconds"->spinSplitActual["PieceSeconds"],
 "PieceChecks"->spinSplitActual["PieceChecks"],"PieceDefinitions"->DownValues[spinPolynomialPieces],
 "MappingDefinitions"->DownValues[spinPolynomialMap],"FixedDefinitions"->spinSplitFixed,
 "Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
saveNative[spinSplitResult,FileNameJoin[{spinSplitDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{spinSplitDirectory,"s08_checks.json"}],<|"checks"->checks,
 "original_seconds"->spinSplitResult["OriginalSeconds"],"candidate_seconds"->spinSplitSeconds,
 "piece_seconds"->spinSplitActual["PieceSeconds"],"speedup_observed"->spinSplitResult["SpeedupObserved"],
 "read_seconds"->spinSplitReadSeconds,"grouping_seconds"->spinSplitGroupingSeconds,
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_metric_spin_split"];Quit[0];

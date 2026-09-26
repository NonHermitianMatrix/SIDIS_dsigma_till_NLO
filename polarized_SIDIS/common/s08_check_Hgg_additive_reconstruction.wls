(* Reproduce the observed additive reconstruction failure on its native Hgg input. *)
$HistoryLength=0;
additiveSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_additive_reconstruction.wls"}];
additiveSetup=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
If[!SyntaxQ[ReadString[additiveSource]]||IntegerString[FileHash[additiveSetup,"SHA256"],16,64]=!=
 "4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15",Quit[1]];
additiveText=ReadString[additiveSetup];additiveBoundary=StringPosition[additiveText,"\nreferenceConfigPath="];
If[Length[additiveBoundary]=!=1,Quit[1]];
additivePrefix=StringTake[additiveText,First[First[additiveBoundary]]-1];
If[!SyntaxQ[additivePrefix],Quit[1]];ToExpression[additivePrefix,InputForm];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
additiveSetupChecks=checks;
additiveReaderSource=FileNameJoin[{root,"common","s08_check_selected_entry_read.wls"}];
gate["accepted selected-reader setup source",IntegerString[FileHash[additiveReaderSource,"SHA256"],16,64]===
 "c05455bfbfda6dc1270da95a6278c74bc449cd84bb4219ae81221f96dbad8379"];
additiveReaderText=ReadString[additiveReaderSource];additiveReaderBoundary=StringPosition[additiveReaderText,"\nownRelative=reader[\"OwnFile\"]"];
gate["unique reader setup boundary",Length[additiveReaderBoundary]===1];
additiveReaderPrefix=StringTake[additiveReaderText,First[First[additiveReaderBoundary]]-1];
gate["complete reader setup syntax",SyntaxQ[additiveReaderPrefix]];
additivePackageOld="Get[\"FeynCalc`\"];";
additivePackageNew="gate[\"reuse identical already loaded native package\",{$Version,FeynCalc`$FeynCalcVersion}===record[\"NativeVersions\"]];";
gate["one reader package initialization",StringCount[additiveReaderPrefix,additivePackageOld]===1];
additiveReaderRun=StringReplace[additiveReaderPrefix,additivePackageOld->additivePackageNew];
gate["only duplicate initialization removed",SyntaxQ[additiveReaderRun]&&
 StringReplace[additiveReaderRun,additivePackageNew->additivePackageOld]===additiveReaderPrefix];
additiveSetupChecks=checks;ToExpression[additiveReaderRun,InputForm];
checks=Join[additiveSetupChecks,checks];
additiveReaderProof=readAccepted["Hgg/s08_selected_entry_read_result/s08_result.wl"];
gate["same accepted selected-reader and task inventory",TrueQ[additiveReaderProof["OwnAcceptedComparison"]]&&
 additiveReaderProof["SourceHash"]===FileHash[additiveReaderSource,"SHA256"]&&
 additiveReaderProof["InputHashes"]===record["InputHashes"]&&additiveReaderProof["TargetInputHash"]===record["TargetInputHash"]&&
 additiveReaderProof["NativeVersions"]===importedNativeVersions&&additiveReaderProof["CandidateTaskDefinitions"]===candidateTaskDefinitions&&
 additiveReaderProof["TaskInventoryHash"]===Hash[{hggTaskMetadata,hggTaskSources},"SHA256"]];
additiveCompact=readAccepted["Hgg/s08_compact_groups_result/s08_result.wl"];
gate["same accepted compact grouping contract",TrueQ[additiveCompact["OwnAcceptedComparison"]]&&
 additiveCompact["InputHashes"]===record["InputHashes"]&&additiveCompact["TargetInputHash"]===record["TargetInputHash"]&&
 additiveCompact["NativeVersions"]===importedNativeVersions];
DownValues[hggOriginalGrouping]=First[additiveCompact["CandidateDefinitions"]];
DownValues[certifyGrouping]=certificateAtomProof["GroupingCertificateDefinitions"];
additiveShared=readAccepted["Hgg/s08_shared_piece_cache_result/s08_result.wl"];
gate["same accepted polynomial mapping contract",TrueQ[additiveShared["OwnAcceptedComparison"]]&&
 additiveShared["InputHashes"]===record["InputHashes"]&&additiveShared["TargetInputHash"]===record["TargetInputHash"]&&
 additiveShared["NativeVersions"]===importedNativeVersions&&
 additiveShared["AlgebraDefinitions"][[1;;3]]==={DownValues[mapExpression],DownValues[familyRows],DownValues[merge]}];
DownValues[polynomialAdditivePieces]=additiveShared["AlgebraDefinitions"][[4]];
DownValues[polynomialPieceMap]=additiveShared["CandidatePieceDefinitions"];
DownValues[sharedPieceValid]=additiveShared["ValidityDefinitions"];
DownValues[sharedReadPiece]=additiveShared["ReadDefinitions"];sharedPieceHits={};
pieceScientificHash=additiveShared["PieceScientificHash"];
additiveOriginalPiece=DownValues[polynomialPieceMap];
additivePhaseSource=FileNameJoin[{root,"common","s08_resume_Hqg_polynomial_maps.wls"}];
gate["unchanged numeric-phase extraction source",IntegerString[FileHash[additivePhaseSource,"SHA256"],16,64]===
 "1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9"];
ToExpression[sourceBlock[additivePhaseSource,"\nnumericOuterFactor[expression_]","\nnumericPhaseMap[expression_,key_]"],InputForm];
additiveTaskPositions=Select[Range[Length[hggTaskMetadata]],hggTaskMetadata[[#]]===
 <|"Sector"->"Real","Kind"->"ExtendedResponse","Index"->{4,2,1}|>&];
gate["unique actual task reported by failed worker",Length[additiveTaskPositions]===1];additiveIndex=First[additiveTaskPositions];
Print["ADDITIVE_ACTUAL_READ_START ",additiveIndex];
{additiveReadSeconds,additiveRaw}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[additiveIndex],"actual failed task"]];
additiveExpression=bounded[additiveRaw/.coordinateRules,"actual failed coordinate input"];Clear[additiveRaw];ClearSystemCache[];
additiveTerms=If[Head[additiveExpression]===Plus,List@@additiveExpression,{additiveExpression}];
gate["actual complete outer inventory reconstructs",Total[additiveTerms]===additiveExpression];
gate["reported outer-term dispatch is active",Head[additiveExpression]===Plus&&AnyTrue[numericOuterFactor/@additiveTerms,First[#]=!=1&]];
additiveOuter=1;additiveSplit=numericOuterFactor[additiveTerms[[additiveOuter]]];
gate["entire selected phase term reconstructs",Times@@additiveSplit===additiveTerms[[additiveOuter]]];
Print["ADDITIVE_ACTUAL_GROUPING_START ",additiveIndex];
{additiveGroupingSeconds,additiveGroups}=AbsoluteTiming[bounded[hggOriginalGrouping[Last[additiveSplit]],"actual failed outer grouping"]];
additiveGroupPositions=Flatten[Position[Keys[additiveGroups],{0,2,0,0,2,0},{1}]];
gate["unique reported denominator group",Length[additiveGroupPositions]===1];additiveGroup=First[additiveGroupPositions];
gate["reported failed group ordering retained",additiveGroup===21];
additivePowers=Keys[additiveGroups][[additiveGroup]];
additiveEquation=Values[additiveGroups][[additiveGroup]]/(Times@@MapThread[Power,{denominators,additivePowers}]);
additivePieces=polynomialAdditivePieces[additiveEquation];
additiveDirectory=FileNameJoin[{root,"Hgg","s08_additive_reconstruction_result"}];
If[!DirectoryQ[additiveDirectory],CreateDirectory[additiveDirectory]];
additiveInput=<|"Component"->additiveIndex,"Task"->hggTaskMetadata[[additiveIndex]],"Outer"->additiveOuter,"Group"->additiveGroup,
 "Powers"->additivePowers,"NumericFactor"->First[additiveSplit],"Equation"->additiveEquation,"Pieces"->additivePieces,
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"]|>;
saveNative[additiveInput,FileNameJoin[{additiveDirectory,"s08_input_equation.wl"}]];
Print["ADDITIVE_ACTUAL_INPUT ",InputForm[KeyDrop[additiveInput,{"Equation","Pieces","InputHashes"}]]," bytes ",ByteCount[additiveEquation]];
Clear[additiveExpression,additiveTerms,additiveGroups,additiveSplit,spin];ClearSystemCache[];
{additiveOriginalSeconds,additiveExpandedDifference}=AbsoluteTiming[bounded[Expand[Total[additivePieces]-additiveEquation],"original actual additive reconstruction"]];
additiveOriginalPass=additiveExpandedDifference===0;
{additiveExactSeconds,additiveExactDifference}=AbsoluteTiming[bounded[Factor[Together[Total[additivePieces]-additiveEquation]],"exact actual additive reconstruction"]];
saveNative[<|"OriginalPass"->additiveOriginalPass,"ExpandedDifference"->additiveExpandedDifference,
 "ExactDifference"->additiveExactDifference|>,FileNameJoin[{additiveDirectory,"s08_reconstruction.wl"}]];
Print["ADDITIVE_RECONSTRUCTION ",InputForm[<|"OriginalPass"->additiveOriginalPass,"ExactDifference"->additiveExactDifference|>]];
gate["actual production reconstruction failure reproduced",!additiveOriginalPass];
gate["every actual additive piece reconstructs exactly",additiveExactDifference===0];
additivePieceSource=sourceBlock[FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}],
 "\npolynomialPieceMap[expression_]","\n{controlSeconds,controlCandidate}="];
additiveSharedEdits={"saved=If[FileExistsQ[path],Get[path],<||>];"->"saved=sharedReadPiece[path,binding];",
 "And@@Values[saved[\"Checks\"]],Return[saved]];"->"And@@Values[saved[\"Checks\"]],Null,",
 "seconds];saved]]],pieces];"->"seconds]];saved]]],pieces];"};
gate["unique accepted shared-reader edits",And@@(StringCount[additivePieceSource,First[#]]===1&/@additiveSharedEdits)];
additiveSharedSource=StringReplace[additivePieceSource,additiveSharedEdits];
gate["exact shared-reader source restoration",SyntaxQ[additiveSharedSource]&&
 StringReplace[additiveSharedSource,Reverse/@additiveSharedEdits]===additivePieceSource];
ToExpression[additiveSharedSource,InputForm];
gate["complete current piece function reproduced",DownValues[polynomialPieceMap]===additiveOriginalPiece];
additiveDecision="Expand[Total[pieces]-expression]===0";
gate["one original reconstruction test",StringCount[additiveSharedSource,additiveDecision]===1];
additiveCandidateSource=StringReplace[additiveSharedSource,additiveDecision->"zero[Total[pieces]-expression]"];
gate["only reconstruction decision changes",SyntaxQ[additiveCandidateSource]&&
 StringReplace[additiveCandidateSource,"zero[Total[pieces]-expression]"->additiveDecision]===additiveSharedSource];
ToExpression[additiveCandidateSource,InputForm];additiveCandidate=DownValues[polynomialPieceMap];
additiveOwn=additiveShared["ActualInput"]["Equation"];
additiveOwnWrites=0;
{additiveOwnSeconds,additiveOwnRows}=AbsoluteTiming[Block[{saveNative},saveNative[_,_]:=(additiveOwnWrites++);
 bounded[polynomialPieceMap[additiveOwn],"accepted own group after reconstruction repair"]]];
gate["every own accepted coefficient unchanged",AssociationQ[additiveOwnRows]&&
 Sort[Keys[additiveOwnRows]]===Sort[Keys[additiveShared["FreshCoefficients"]]]&&
 And@@KeyValueMap[(#2===additiveShared["FreshCoefficients"][#1]||zero[#2-additiveShared["FreshCoefficients"][#1]])&,additiveOwnRows]];
gate["own comparison reuses accepted pieces without writes",additiveOwnWrites===0];
additiveResult=<|"Schema"->"polarized-sidis-additive-reconstruction-v1","Channel"->channel,
 "SourceHash"->FileHash[additiveSource,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "SharedProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}],"SHA256"],
 "ReaderProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_selected_entry_read_result","s08_result.wl"}],"SHA256"],
 "OriginalPieceDefinitions"->additiveOriginalPiece,"CandidatePieceDefinitions"->additiveCandidate,
 "AlgebraDefinitions"->{DownValues[mapExpression],DownValues[familyRows],DownValues[merge],DownValues[polynomialAdditivePieces],DownValues[zero]},
 "ActualInput"->additiveInput,"OriginalFailureReproduced"->!additiveOriginalPass,"ExactDifference"->additiveExactDifference,
 "OwnAcceptedComparison"->True,"OwnCoefficients"->additiveOwnRows,"OwnSeconds"->additiveOwnSeconds,
 "OriginalSeconds"->additiveOriginalSeconds,"ExactSeconds"->additiveExactSeconds,"ReadSeconds"->additiveReadSeconds,
 "GroupingSeconds"->additiveGroupingSeconds,"NativeVersions"->importedNativeVersions,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
saveNative[additiveResult,FileNameJoin[{additiveDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{additiveDirectory,"s08_checks.json"}],<|"checks"->checks,"component"->additiveIndex,"outer"->additiveOuter,
 "group"->additiveGroup,"original_failure_reproduced"->!additiveOriginalPass,"exact_difference"->additiveExactDifference,
 "read_seconds"->additiveReadSeconds,"grouping_seconds"->additiveGroupingSeconds,"original_seconds"->additiveOriginalSeconds,
 "exact_seconds"->additiveExactSeconds,"own_seconds"->additiveOwnSeconds,"peak_kernel_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_additive_reconstruction"];Quit[0];

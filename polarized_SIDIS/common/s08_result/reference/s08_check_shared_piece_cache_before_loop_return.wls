(* Reuse input-bound polynomial packets across worker folders; preserve all algebra. *)
$HistoryLength=0;
reuseSource=FileNameJoin[{Directory[],"common","s08_check_shared_piece_cache.wls"}];
reuseSetupPath=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
If[!SyntaxQ[Import[reuseSource,"Text"]]||IntegerString[FileHash[reuseSetupPath,"SHA256"],16,64]=!=
 "4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15",Quit[1]];
reuseSetupText=Import[reuseSetupPath,"Text"];
reuseBoundary=StringPosition[reuseSetupText,"\nreferenceConfigPath="];
If[Length[reuseBoundary]=!=1,Quit[1]];
reuseSetup=StringTake[reuseSetupText,First[First[reuseBoundary]]-1];
If[!SyntaxQ[reuseSetup],Quit[1]];ToExpression[reuseSetup,InputForm];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
DownValues[polynomialAdditivePieces]=proof["AdditivePiecesDefinitions"];
DownValues[polynomialPieceMap]=proof["PieceMappingDefinitions"];
reuseOriginalPiece=DownValues[polynomialPieceMap];
reuseAlgebra={DownValues[mapExpression],DownValues[familyRows],DownValues[merge],
 DownValues[polynomialAdditivePieces],DownValues[certifyGroupMerge]};
pieceScientificHash=Hash[{proof["PieceScientificHash"],record["TargetInputHash"],
 FileHash[FileNameJoin[{root,"common","s08_map_Hgg_factored_inputs.wls"}],"SHA256"]},"SHA256"];
reuseCache=FileNameJoin[{root,"cache","s08_Hqg_polynomial_terms",IntegerString[pieceScientificHash,16]}];
gate["existing input-bound Hgg polynomial cache",DirectoryQ[reuseCache]&&$KernelID===0];

sharedPieceValid[packet_,binding_]:=AssociationQ[packet]&&
 Lookup[packet,"Binding",None]===binding&&TrueQ[Lookup[packet,"Accepted",False]]&&
 AssociationQ[Lookup[packet,"Checks",None]]&&Length[packet["Checks"]]>0&&And@@Values[packet["Checks"]];
sharedReadPiece[path_String,binding_Integer]:=Module[{saved,alternatives,packet},
 saved=If[FileExistsQ[path],Get[path],<||>];
 If[sharedPieceValid[saved,binding],Return[saved]];
 alternatives=DeleteCases[Sort[FileNames[FileNameTake[path],
   FileNames["kernel_*",DirectoryName[DirectoryName[path]]]]],path];
 Do[packet=Get[alternative];If[sharedPieceValid[packet,binding],
   AppendTo[sharedPieceHits,<|"Path"->alternative,"FileHash"->FileHash[alternative,"SHA256"],
     "Binding"->binding,"SavedSeconds"->Lookup[packet,"Seconds",0]|>];
   Print["REUSED_POLYNOMIAL_PIECE ",FileNameTake[DirectoryName[alternative]]," ",FileNameTake[alternative]];
   Return[packet]],{alternative,alternatives}];saved];
sharedPieceHits={};
reusePieceText=Import[FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}],"Text"];
reuseBegin=StringPosition[reusePieceText,"\npolynomialPieceMap[expression_]"];
reuseEnd=StringPosition[reusePieceText,"\n{controlSeconds,controlCandidate}="];
gate["unique entire original piece function",Length[reuseBegin]===1&&Length[reuseEnd]===1];
reusePieceOriginal=StringTake[reusePieceText,{First[First[reuseBegin]],First[First[reuseEnd]]-1}];
gate["complete original piece syntax",SyntaxQ[reusePieceOriginal]];
ToExpression[reusePieceOriginal,InputForm];
gate["exact accepted original piece function",DownValues[polynomialPieceMap]===reuseOriginalPiece];
reuseEdit="saved=If[FileExistsQ[path],Get[path],<||>];"->"saved=sharedReadPiece[path,binding];";
gate["single cache-read substitution",StringCount[reusePieceOriginal,First[reuseEdit]]===1];
reusePieceCandidate=StringReplace[reusePieceOriginal,reuseEdit];
gate["only checkpoint lookup changes",SyntaxQ[reusePieceCandidate]&&
 StringReplace[reusePieceCandidate,Reverse[reuseEdit]]===reusePieceOriginal];
reuseWorkerEdit="\"kernel_\"<>ToString[$KernelID]"->"\"kernel_comparison_\"<>ToString[Environment[\"JOB_ID\"]]";
gate["single worker-directory boundary",StringCount[reusePieceOriginal,First[reuseWorkerEdit]]===1&&
 StringCount[reusePieceCandidate,First[reuseWorkerEdit]]===1];
reuseFreshTest=StringReplace[reusePieceOriginal,reuseWorkerEdit];
reuseCachedTest=StringReplace[reusePieceCandidate,reuseWorkerEdit];
gate["comparison changes only the empty worker directory",SyntaxQ[reuseFreshTest]&&SyntaxQ[reuseCachedTest]&&
 StringReplace[reuseFreshTest,Reverse[reuseWorkerEdit]]===reusePieceOriginal&&
 StringReplace[reuseCachedTest,Reverse[reuseWorkerEdit]]===reusePieceCandidate];
reuseCompactRelative="Hgg/s08_compact_groups_result/s08_result.wl";
reuseCompactPath=FileNameJoin[{root,reuseCompactRelative}];
reuseCompactReceipt=Import[FileNameJoin[{DirectoryName[reuseCompactPath],"s08_execution.json"}],"RawJSON"];
gate["accepted own compact grouping",TrueQ[reuseCompactReceipt["passed"]]&&
 reuseCompactReceipt["result_sha256"][reuseCompactRelative]===IntegerString[FileHash[reuseCompactPath,"SHA256"],16,64]];
reuseCompact=Get[reuseCompactPath];
gate["same own grouping inputs and native versions",reuseCompact["InputHashes"]===record["InputHashes"]&&
 reuseCompact["TargetInputHash"]===record["TargetInputHash"]&&
 reuseCompact["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 TrueQ[reuseCompact["OwnAcceptedComparison"]]&&And@@Values[reuseCompact["Checks"]]];
DownValues[hggOriginalGrouping]=First[reuseCompact["CandidateDefinitions"]];
DownValues[certifyGrouping]=certificateAtomProof["GroupingCertificateDefinitions"];
reuseActualGroups=Prepend[certificateAtomProof["ActualGroups"],
 <|"Component"->component,"Groups"->bounded[hggOriginalGrouping[record["Expression"]],"own exact grouping"]|>];

reuseSelection=Catch[
 Do[Do[Module[{powers,value,pieces,bindings,paths,groupPath,packet},
   powers=Keys[actual["Groups"]][[index]];
   value=Values[actual["Groups"]][[index]]/(Times@@MapThread[Power,{denominators,powers}]);
   pieces=polynomialAdditivePieces[value];bindings=Hash[{pieceScientificHash,#},"SHA256"]&/@pieces;
   paths=FileNames[IntegerString[#,16]<>".wl",FileNames["kernel_*",reuseCache]]&/@bindings;
   If[AnyTrue[paths,#==={}&],Continue[]];
   groupPath=FileNameJoin[{root,"cache","s08_Hgg_grouped",IntegerString[certificateGroupHash,16],
     "component_"<>ToString[actual["Component"]]<>"_group_"<>IntegerString[index,10,4]<>".wl"}];
   If[!FileExistsQ[groupPath],Continue[]];packet=Get[groupPath];
   If[!sharedPieceValid[packet,Hash[{certificateGroupHash,"component_"<>ToString[actual["Component"]],index,value},"SHA256"]],Continue[]];
   Throw[<|"Component"->actual["Component"],"Group"->index,"Equation"->value,"Pieces"->pieces,
     "Bindings"->bindings,"Paths"->paths,"ReferencePath"->groupPath,"Reference"->packet|>,"ActualGroup"]],
  {index,Length[actual["Groups"]]}],{actual,reuseActualGroups}];$Failed,"ActualGroup"];
gate["actual Hgg group has accepted pieces on other workers",AssociationQ[reuseSelection]];
reuseEquation=reuseSelection["Equation"];reuseReference=reuseSelection["Reference"];
Print["ACTUAL_SHARED_CACHE_INPUT ",InputForm[KeyTake[reuseSelection,{"Component","Group","Equation","Bindings"}]]];
reuseDirectory=FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result"}];
If[!DirectoryQ[reuseDirectory],CreateDirectory[reuseDirectory]];
reuseEquationPacket=Join[KeyTake[reuseSelection,{"Component","Group","Equation","Pieces","Bindings"}],
 <|"Denominators"->denominators,"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"]|>];
Put[reuseEquationPacket,FileNameJoin[{reuseDirectory,"s08_input_equation.wl"}]];
gate["exact readable input equation export",Get[FileNameJoin[{reuseDirectory,"s08_input_equation.wl"}]]===reuseEquationPacket];
reuseScratch=FileNameJoin[{root,"cache","s08_shared_piece_comparison",ToString[Environment["JOB_ID"]]}];
If[!DirectoryQ[reuseScratch],CreateDirectory[reuseScratch,CreateIntermediateDirectories->True]];
DownValues[reuseNativeWrite]=DownValues[saveNative]/.saveNative->reuseNativeWrite;
gate["unchanged native comparison writer",(DownValues[reuseNativeWrite]/.reuseNativeWrite->saveNative)===DownValues[saveNative]];
ToExpression[reuseFreshTest,InputForm];
{reuseFreshSeconds,reuseFresh}=AbsoluteTiming[Block[{saveNative},
 saveNative[value_,path_]:=reuseNativeWrite[value,FileNameJoin[{reuseScratch,FileNameTake[path]}]];
 bounded[polynomialPieceMap[reuseEquation],"fresh complete actual Hgg group"]]];
gate["fresh complete group matches own accepted output",Sort[Keys[reuseFresh]]===Sort[Keys[reuseReference["Coefficients"]]]&&
 And@@KeyValueMap[(#2===reuseReference["Coefficients"][#1]||zero[#2-reuseReference["Coefficients"][#1]])&,reuseFresh]];
ToExpression[reuseCachedTest,InputForm];
gate["every algebraic implementation remains unchanged",reuseAlgebra==={DownValues[mapExpression],DownValues[familyRows],
 DownValues[merge],DownValues[polynomialAdditivePieces],DownValues[certifyGroupMerge]}];
{reuseCachedSeconds,reuseCached}=AbsoluteTiming[Block[{saveNative},
 saveNative[value_,path_]:=reuseNativeWrite[value,FileNameJoin[{reuseScratch,FileNameTake[path]}]];
 bounded[polynomialPieceMap[reuseEquation],"shared-cache complete actual Hgg group"]]];
gate["every complete coefficient equals fresh and own accepted output",Sort[Keys[reuseCached]]===Sort[Keys[reuseFresh]]&&
 And@@KeyValueMap[(#2===reuseFresh[#1]||zero[#2-reuseFresh[#1]])&,reuseCached]];
gate["all actual pieces reused from another worker",Length[sharedPieceHits]===Length[reuseSelection["Pieces"]]&&
 Sort[Lookup[sharedPieceHits,"Binding"]]===Sort[reuseSelection["Bindings"]]];
gate["executed shared-cache speedup",reuseCachedSeconds<reuseFreshSeconds];
ToExpression[reusePieceCandidate,InputForm];reuseCandidatePiece=DownValues[polynomialPieceMap];
reuseResult=<|"Schema"->"polarized-sidis-shared-piece-cache-v1","Channel"->channel,
 "SourceHash"->FileHash[reuseSource,"SHA256"],"SetupSourceHash"->FileHash[reuseSetupPath,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "PolynomialProofHash"->FileHash[proofPath,"SHA256"],"ExternalProofHash"->FileHash[referenceProofPath,"SHA256"],
 "GroupingProofHash"->FileHash[reuseCompactPath,"SHA256"],
 "PieceScientificHash"->pieceScientificHash,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "ActualInput"->reuseEquationPacket,"ReferenceHash"->FileHash[reuseSelection["ReferencePath"],"SHA256"],
 "OriginalPieceDefinitions"->reuseOriginalPiece,"CandidatePieceDefinitions"->reuseCandidatePiece,
 "ValidityDefinitions"->DownValues[sharedPieceValid],"ReadDefinitions"->DownValues[sharedReadPiece],
 "AlgebraDefinitions"->reuseAlgebra,"OwnAcceptedComparison"->True,"SpeedupObserved"->True,
 "FreshSeconds"->reuseFreshSeconds,"CachedSeconds"->reuseCachedSeconds,"ReusedPieces"->sharedPieceHits,
 "FreshCoefficients"->reuseFresh,"CachedCoefficients"->reuseCached,"Checks"->checks,
 "PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
saveNative[reuseResult,FileNameJoin[{reuseDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{reuseDirectory,"s08_checks.json"}],<|"checks"->checks,
 "component"->reuseSelection["Component"],"group"->reuseSelection["Group"],
 "fresh_seconds"->reuseFreshSeconds,"cached_seconds"->reuseCachedSeconds,
 "reused_pieces"->Length[sharedPieceHits],"cache_namespace"->IntegerString[pieceScientificHash,16],
 "peak_kernel_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
DeleteDirectory[reuseScratch,DeleteContents->True];
reuseEmptyWorker=FileNameJoin[{reuseCache,"kernel_comparison_"<>ToString[Environment["JOB_ID"]]}];
If[DirectoryQ[reuseEmptyWorker]&&FileNames["*",reuseEmptyWorker]==={},DeleteDirectory[reuseEmptyWorker]];
Print["PASS: s08_check_shared_piece_cache"];Quit[0];

(* Export the actual slow group using the accepted native input reader. *)
$HistoryLength=0;
failedSource=FileNameJoin[{Directory[],"common","s08_export_Hgg_slow_group_input.wls"}];
failedBase=FileNameJoin[{Directory[],"common","s08_check_Hgg_additive_reconstruction.wls"}];
If[!SyntaxQ[ReadString[failedSource]]||IntegerString[FileHash[failedBase,"SHA256"],16,64]=!=
 "61071a42a311a84ebdbf30fdb33bd7b9e8d9c86c21a17172b4e1b5004ddfd221",Quit[1]];
failedText=ReadString[failedBase];
failedBoundary=StringPosition[failedText,"\nadditivePieces=polynomialAdditivePieces[additiveEquation];"];
If[Length[failedBoundary]=!=1,Quit[1]];
failedPrefix=StringTake[failedText,First[First[failedBoundary]]-1];
failedSelections={"<|\"Sector\"->\"Real\",\"Kind\"->\"ExtendedResponse\",\"Index\"->{4,2,1}|>"->"hggTaskMetadata[[37]]",
 "{0,2,0,0,2,0}"->"{2,0,0,1,0,1}","additiveGroup===21"->"additiveGroup===34"};
If[!And@@(StringCount[failedPrefix,First[#]]===1&/@failedSelections),Quit[1]];
failedRun=StringReplace[failedPrefix,failedSelections];
If[!SyntaxQ[failedRun]||StringReplace[failedRun,Reverse/@failedSelections]=!=failedPrefix,Quit[1]];
ToExpression[failedRun,InputForm];
gate["exact production slow component and group",additiveIndex===37&&additiveOuter===1&&additiveGroup===34];
failedPieces=polynomialAdditivePieces[additiveEquation];
failedSplits=externalSplit/@failedPieces;
gate["every exported piece retains its entire external factor",
 And@@MapThread[(Times@@#1===#2)&,{failedSplits,failedPieces}]];
failedDirectory=FileNameJoin[{root,"Hgg","s08_slow_group_input_result"}];
If[!DirectoryQ[failedDirectory],CreateDirectory[failedDirectory]];
failedInput=<|"Schema"->"polarized-sidis-selected-group-input-v1","Channel"->channel,
 "SourceHash"->FileHash[failedSource,"SHA256"],"BaseHash"->FileHash[failedBase,"SHA256"],
 "Component"->additiveIndex,"Task"->hggTaskMetadata[[additiveIndex]],"Outer"->additiveOuter,
 "Group"->additiveGroup,"Powers"->additivePowers,"NumericFactor"->First[additiveSplit],
 "Equation"->additiveEquation,"Pieces"->failedPieces,"ExternalSplits"->failedSplits,
 "Denominators"->denominators,"Families"->families,
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->importedNativeVersions,"ReadSeconds"->additiveReadSeconds,
 "GroupingSeconds"->additiveGroupingSeconds,"EquationBytes"->ByteCount[additiveEquation],
 "MappingDefinitions"->DownValues[mapExpression],"FamilyDefinitions"->DownValues[familyRows],
 "OriginalMapDefinitions"->DownValues[externalOriginalMap],
 "ExternalSplitDefinitions"->DownValues[externalSplit],
 "OwnAcceptedEquation"->additiveShared["ActualInput"]["Equation"],
 "OwnAcceptedCoefficients"->additiveShared["FreshCoefficients"],
 "OwnProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}],"SHA256"],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
saveNative[failedInput,FileNameJoin[{failedDirectory,"s08_result.wl"}]];
failedReadable=FileNameJoin[{failedDirectory,"s08_equations.wl"}];
failedEquations=KeyTake[failedInput,{"Task","Outer","Group","Powers","NumericFactor",
 "Equation","Pieces","ExternalSplits","Denominators","FamilyDefinitions","OriginalMapDefinitions"}];
Put[failedEquations,failedReadable];
gate["entire readable native equation reload",Get[failedReadable]===failedEquations];
Export[FileNameJoin[{failedDirectory,"s08_checks.json"}],<|"checks"->checks,
 "component"->additiveIndex,"outer"->additiveOuter,"group"->additiveGroup,"powers"->additivePowers,
 "read_seconds"->additiveReadSeconds,"grouping_seconds"->additiveGroupingSeconds,
 "equation_bytes"->ByteCount[additiveEquation],"piece_bytes"->(ByteCount/@failedPieces),
 "split_bytes"->(ByteCount/@failedSplits),"readable_file_bytes"->FileByteCount[failedReadable],
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["FAILED_GROUP_INPUT_EXPORTED ",InputForm[KeyTake[failedInput,
 {"Task","Outer","Group","Powers","NumericFactor","EquationBytes","ReadSeconds","GroupingSeconds"}]]];
Print["PASS: s08_export_Hgg_slow_group_input"];Quit[0];

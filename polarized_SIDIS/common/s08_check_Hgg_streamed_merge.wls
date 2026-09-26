(* Compare the accepted streamed rational sum on a complete own Hgg group merge. *)
$HistoryLength=0;root=Directory[];checks=<||>;
source=FileNameJoin[{root,"common","s08_check_Hgg_streamed_merge.wls"}];
gate[label_,test_]:=If[TrueQ[test],If[!KeyExistsQ[checks,label],Print["PASS: ",label]];AssociateTo[checks,label->True],Print["FAIL: ",label];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,1800,gate["time "<>ToString[label,InputForm],False]],4*1024^3,gate["memory "<>ToString[label,InputForm],False]];
zero[value_]:=Factor[Together[value]]===0;
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete comparison source syntax",SyntaxQ[Import[source,"Text"]]];
accepted[relative_]:=Module[{path,receipt},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted native artifact "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 Get[path]];
stream=accepted["Hqqprime/s08_streamed_result/s08_result.wl"];
gate["exact executed streamed algorithm",stream["Schema"]==="polarized-sidis-streamed-numerator-validation-v1"&&
 stream["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[stream["Checks"]]&&
 TrueQ[stream["Coefficient"]["Evidence"]["ExactTermwiseReconstructionPassed"]]&&
 stream["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_streamed_numerator.wls"}],"SHA256"]];
DownValues[streamedDenominatorSum]=stream["Definitions"];
DownValues[cancelAvailableDenominatorFactors]=stream["CancellationDefinitions"];
gate["unchanged accepted sum and cancellation definitions",
 {DownValues[streamedDenominatorSum],DownValues[cancelAvailableDenominatorFactors]}===Lookup[stream,{"Definitions","CancellationDefinitions"}]];
own=accepted["Hgg/s08_termwise_comparison_result/s08_result.wl"];
gate["accepted own complete map",own["Schema"]==="polarized-sidis-original-term-map-v1"&&own["Channel"]==="Hgg"&&
 own["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&TrueQ[own["OwnAcceptedComparison"]]&&
 TrueQ[own["ReconstructionPassed"]]&&And@@Values[own["Checks"]]];
manifestPath=FileNameJoin[{root,"common","s08_Hgg_streamed_merge_inputs.json"}];
manifest=Import[manifestPath,"RawJSON"];
gate["unique complete saved group-file inventory",Length[manifest["groups"]]>0&&DuplicateFreeQ[manifest["groups"]]&&
 And@@(StringMatchQ[FileNameTake[#],"component_"<>ToString[own["Component"]]<>"_group_"~~DigitCharacter..~~".wl"]&/@manifest["groups"])];
KeyValueMap[Function[{relative,hash},gate["exact saved merge input "<>relative,
 IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===hash]],manifest["sha256"]];
reference=Get[FileNameJoin[{root,manifest["reference"]}]];
gate["same own canonical input and task",reference["InputHash"]===own["InputHash"]&&
 KeyTake[reference,{"Sector","Kind","Index"}]===own["Task"]&&TrueQ[reference["ReconstructionPassed"]]&&And@@Values[reference["Checks"]]];
packets=Get[FileNameJoin[{root,#}]]&/@manifest["groups"];
gate["all saved group packets accepted",AllTrue[packets,AssociationQ]&&And@@Lookup[packets,"Accepted"]&&
 And@@Flatten[Values[#["Checks"]]&/@packets]];
pieces=Lookup[packets,"Coefficients"];
mapper=FileNameJoin[{root,"common","s08_result","reference","s08_map_real_spin_before_known_denominator.wls"}];
gate["same original mapper",FileHash[mapper,"SHA256"]===own["MapperHash"]];
text=Import[mapper,"Text"];begin=StringPosition[text,"\nmerge[pieces_List]"];end=StringPosition[text,"\n(* All partial-fraction"];
gate["unique complete original merge definition",Length[begin]===1&&Length[end]===1];
definition=StringTake[text,{First[First[begin]],First[First[end]]-1}];
gate["original merge syntax",SyntaxQ[definition]];ToExpression[definition,InputForm];
originalDefinitions=DownValues[merge];
compareMaps[left_Association,right_Association,label_]:=Module[{keys},
 keys=Union[Keys[left],Keys[right]];
 gate[label,And@@(bounded[zero[Lookup[left,#,0]-Lookup[right,#,0]],{label,#}]&/@keys)]];
Print["ORIGINAL_GROUP_MERGE_START ",own["Component"]," groups ",Length[pieces]];
{originalSeconds,original}=AbsoluteTiming[bounded[merge[pieces],"original complete group merge"]];
compareMaps[original,own["Coefficients"],"original merge reproduces accepted complete own map"];
compareMaps[original,reference["Coefficients"],"original merge reproduces canonical map"];
Print["ORIGINAL_GROUP_MERGE_DONE seconds ",originalSeconds];
mergeEvidence=<||>;
streamedMerge[values_List]:=Module[{grouped,rows},
 grouped=Merge[values,Identity];
 rows=Association@KeyValueMap[Function[{key,terms},Module[{packet},
  packet=streamedDenominatorSum[terms,{"Hgg group merge",key}];
  gate["exact streamed coefficient reconstruction "<>ToString[key,InputForm],
   DeleteCases[terms,0]==={}||TrueQ[packet["Evidence"]["ExactTermwiseReconstructionPassed"]]];
  AssociateTo[mergeEvidence,key->packet["Evidence"]];key->packet["Value"]]],grouped];
 Select[rows,#=!=0&]];
Print["STREAMED_GROUP_MERGE_START"];
{candidateSeconds,candidate}=AbsoluteTiming[bounded[streamedMerge[pieces],"streamed complete group merge"]];
compareMaps[candidate,original,"every original merged coefficient unchanged"];
gate["original mapper unchanged",DownValues[merge]===originalDefinitions];
Print["STREAMED_GROUP_MERGE_DONE seconds ",candidateSeconds," original ",originalSeconds];
result=<|"Schema"->"polarized-sidis-Hgg-streamed-merge-comparison-v1","Channel"->"Hgg","Accepted"->True,
 "Component"->own["Component"],"InputHash"->own["InputHash"],"InputHashes"->own["InputHashes"],
 "OwnMapHash"->FileHash[FileNameJoin[{root,"Hgg","s08_termwise_comparison_result","s08_result.wl"}],"SHA256"],
 "StreamedProofHash"->FileHash[FileNameJoin[{root,"Hqqprime","s08_streamed_result","s08_result.wl"}],"SHA256"],
 "ManifestHash"->FileHash[manifestPath,"SHA256"],"GroupFiles"->manifest,"OriginalDefinitions"->originalDefinitions,
 "CandidateDefinitions"->DownValues[streamedMerge],"StreamedDefinitions"->DownValues[streamedDenominatorSum],
 "CancellationDefinitions"->DownValues[cancelAvailableDenominatorFactors],"Coefficients"->candidate,"Evidence"->mergeEvidence,
 "OriginalSeconds"->originalSeconds,"CandidateSeconds"->candidateSeconds,"SpeedupObserved"->TrueQ[candidateSeconds<originalSeconds],
 "SourceHash"->FileHash[source,"SHA256"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,
 "PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,"Hgg","s08_streamed_merge_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
path=FileNameJoin[{out,"s08_result.wl"}];
serialized="Uncompress["<>ToString[bounded[Compress[result],"native compression"],InputForm]<>"]\n";
gate["native file bound",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];
gate["exact complete native reload",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{out,"s08_checks.json"}],<|"checks"->checks,"original_seconds"->originalSeconds,
 "candidate_seconds"->candidateSeconds,"speedup_observed"->result["SpeedupObserved"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_check_Hgg_streamed_merge"];Quit[0];


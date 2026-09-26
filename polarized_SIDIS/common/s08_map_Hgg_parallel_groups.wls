(* Schedule independent metric groups on the existing accepted native workers. *)
$HistoryLength=0;
metricParallelSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_parallel_groups.wls"}];
metricParallelBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_metric_partitioned.wls"}];
If[!SyntaxQ[ReadString[metricParallelSource]]||IntegerString[FileHash[metricParallelBase,"SHA256"],16,64]=!=
 "177ae0baf676d0c9751e67c432e230d7ec911d1c60d01cebe35bebc6499e97a0",Quit[1]];
metricParallelText=StringTrim[ReadString[metricParallelBase]];metricParallelTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[metricParallelText,metricParallelTerminal],Quit[1]];
metricParallelPrefix=StringDrop[metricParallelText,-StringLength[metricParallelTerminal]];
If[!SyntaxQ[metricParallelPrefix],Quit[1]];ToExpression[metricParallelPrefix,InputForm];

metricParallelStart[]:=Module[{original,candidate,fixed,relative,path,receipt,own,serial,parallel,serialSeconds,parallelSeconds},
 gate["metric group parallelism uses allocated initialized kernels",$KernelID===0&&workers>1&&Length[Kernels[]]===workers];
 original=DownValues[groupedMapExpression];
 gate["one independent group table",Count[original,HoldPattern[Table[_,_]],Infinity]===1];
 candidate=original/.HoldPattern[Table[body_,iterator_]]:>
  ParallelTable[body,iterator,Method->"FinestGrained",DistributedContexts->"Global`"];
 gate["entire serial group code restored exactly",(candidate/.
  HoldPattern[ParallelTable[body_,iterator_,Method->"FinestGrained",DistributedContexts->"Global`"]]:>Table[body,iterator])===original];
 fixed={DownValues[groupDenominators],DownValues[polynomialPieceMap],DownValues[mapExpression],
  DownValues[familyRows],DownValues[merge],DownValues[certifyGroupMerge],DownValues[put],DownValues[saveNative]};
 relative="Hgg/s08_mapping_inputs_result/s08_component_0008.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_recovery_execution.json"}],"RawJSON"];
 gate["accepted complete own dispatch input",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 own=Get[path];
 gate["same own dispatch scientific conventions",own["InputHashes"]===inputHashes&&own["TargetInputHash"]===targetInputHash&&
  own["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&Length[own["Checks"]]>0&&And@@Values[own["Checks"]]];
 {serialSeconds,serial}=AbsoluteTiming[bounded[groupedMapExpression[own["Expression"],
  "component_"<>ToString[own["Component"]]],"original serial own group dispatch"]];
 DownValues[groupedMapExpression]=candidate;
 {parallelSeconds,parallel}=AbsoluteTiming[bounded[groupedMapExpression[own["Expression"],
  "component_"<>ToString[own["Component"]]],"parallel complete own group dispatch"]];
 gate["complete serial and parallel own coefficients agree",partitionSameCoefficients[parallel,serial]];
 gate["all scalar group cache and serialization algorithms unchanged",fixed===
  {DownValues[groupDenominators],DownValues[polynomialPieceMap],DownValues[mapExpression],
   DownValues[familyRows],DownValues[merge],DownValues[certifyGroupMerge],DownValues[put],DownValues[saveNative]}];
 metricParallelEvidence=<|"SourceHash"->FileHash[metricParallelSource,"SHA256"],"BaseHash"->FileHash[metricParallelBase,"SHA256"],
  "OwnInputHash"->FileHash[path,"SHA256"],"OwnAcceptedComparison"->True,"WorkerCount"->workers,
  "SerialOwnSeconds"->serialSeconds,"ParallelOwnSeconds"->parallelSeconds,
  "OriginalGroupDefinitions"->original,"ParallelGroupDefinitions"->candidate,"FixedDefinitions"->fixed|>;
 Print["ACCEPTED_PARALLEL_METRIC_GROUP_DISPATCH workers ",workers," own_seconds ",InputForm[{serialSeconds,parallelSeconds}]];
 ClearSystemCache[]];

metricParallelOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[metricParallelOriginalTail]=metricParallelOriginalTailDefinitions/.coordinateTail->metricParallelOriginalTail;
If[(DownValues[metricParallelOriginalTail]/.metricParallelOriginalTail->coordinateTail)=!=metricParallelOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=metricParallelOriginalTail[text],old,new},
 old="targetComponents = If[workers > 0,\n  ParallelMap[mapTargetTask, targetRest, Method -> \"FinestGrained\"], mapTargetTask /@ targetRest];";
 new="metricParallelStart[];\ntargetComponents = mapTargetTask /@ targetRest;";
 changed=coordinateReplace[changed,old,new];
 coordinateReplace[changed,"\ntargetResult = <|","\ntargetResult = <|\"MetricGroupDispatch\"->metricParallelEvidence, "]];
ToExpression[partitionRun,InputForm];

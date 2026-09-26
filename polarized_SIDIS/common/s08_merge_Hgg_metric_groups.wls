(* Reuse the accepted per-integral merge on the completed Hgg group maps. *)
$HistoryLength=0;
metricMergeSource=FileNameJoin[{Directory[],"common","s08_merge_Hgg_metric_groups.wls"}];
metricMergeBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_metric_partitioned.wls"}];
If[!SyntaxQ[ReadString[metricMergeSource]]||IntegerString[FileHash[metricMergeBase,"SHA256"],16,64]=!=
 "177ae0baf676d0c9751e67c432e230d7ec911d1c60d01cebe35bebc6499e97a0",Quit[1]];
metricMergeText=StringTrim[ReadString[metricMergeBase]];metricMergeTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[metricMergeText,metricMergeTerminal],Quit[1]];
metricMergePrefix=StringDrop[metricMergeText,-StringLength[metricMergeTerminal]];
If[!SyntaxQ[metricMergePrefix],Quit[1]];ToExpression[metricMergePrefix,InputForm];

metricGroupMerge[pieces_List]:=Module[{grouped,identity,work,results,rows,seconds},
 gate["metric merge owns root dispatcher",$KernelID===0&&workers>1&&Length[Kernels[]]===workers];
 grouped=Merge[pieces,Identity];identity=Hash[{metricMergeHash,pieces},"SHA256"];
 work=MapIndexed[Function[{integral,position},<|"Component"->identity,"Position"->First[position],
   "Key"->integral,"Values"->grouped[integral]|>],Keys[grouped]];
 Print["METRIC_COEFFICIENT_MERGE_BEGIN keys ",Length[work]," bytes ",ByteCount[pieces]];
 {seconds,results}=AbsoluteTiming[ParallelMap[metricMergeKey,work,Method->"FinestGrained"]];
 gate["every metric coefficient merge accepted",Length[results]===Length[work]&&AllTrue[results,AssociationQ]&&
  And@@Lookup[results,"ReconstructionPassed"]&&And@@Flatten[Values[#["Checks"]]&/@results]&&
  Lookup[results,"Key"]===Keys[grouped]];
 rows=Select[AssociationThread[Lookup[results,"Key"],Lookup[results,"Value"]],#=!=0&];
 AppendTo[metricMergeMeasurements,<|"InputHash"->identity,"IntegralCount"->Length[work],
  "InputBytes"->ByteCount[pieces],"OutputBytes"->ByteCount[rows],"Seconds"->seconds,
  "CoefficientEvidence"->(KeyDrop[#,"Value"]&/@results)|>];
 Print["METRIC_COEFFICIENT_MERGE_DONE keys ",Length[work]," seconds ",seconds];rows];

metricMergeStart[]:=Module[{relative,path,receipt,producer,proof,text,begin,end,block,renamed,names,
 original,candidate,fixed,own,serial,parallel,serialSeconds,parallelSeconds},
 relative="Hqqbar/s08_pair_merge_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_pair_merge_linearity.wls"}];
 gate["accepted per-integral merge execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_pair_merge_linearity.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];
 gate["same reference merge and native conventions",proof["Schema"]==="polarized-sidis-pair-merge-linearity-v1"&&
  proof["SourceHash"]===FileHash[producer,"SHA256"]&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["OriginalMergeDefinitions"]===DownValues[merge]&&proof["CertificateDefinitions"]===DownValues[certifyPairMerge]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]];
 text=ReadString[producer];begin=StringPosition[text,"\nmergeSave[value_, path_]"];
 end=StringPosition[text,"\ncertifyPairMerge[maps_, grouped_, coefficients_]"];
 gate["complete accepted per-integral implementation boundaries",Length[begin]===1&&Length[end]===1];
 block=StringTake[text,{First[First[begin]],First[First[end]]-1}];
 names={"mergeSave"->"metricMergeSave","mergeKey"->"metricMergeKey",
  "mergeStudyHash"->"metricMergeHash","mergeCache"->"metricMergeCache"};
 renamed=StringReplace[block,names];
 gate["only merge implementation names change",SyntaxQ[renamed]&&StringReplace[renamed,Reverse/@names]===block];
 ToExpression[renamed,InputForm];
 metricMergeHash=Hash[{FileHash[metricMergeSource,"SHA256"],FileHash[producer,"SHA256"],FileHash[path,"SHA256"],
  inputHashes,targetInputHash,groupInputHash,$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
 metricMergeCache=FileNameJoin[{root,"cache","s08_Hgg_coefficient_merge",IntegerString[metricMergeHash,16]}];
 If[!DirectoryQ[metricMergeCache],CreateDirectory[metricMergeCache,CreateIntermediateDirectories->True]];
 metricMergeMeasurements={};
 DistributeDefinitions[metricMergeSave,metricMergeKey,metricMergeHash,metricMergeCache,
  gate,bounded,targetTimeLimit,targetMemoryLimit,merge,zero];
 original=DownValues[groupedMapExpression];
 gate["one complete outer group merge",Count[original,HoldPattern[merge[Lookup[_,"Coefficients"]]],Infinity]===1];
 candidate=original/.HoldPattern[merge[Lookup[packetSymbol_,"Coefficients"]]]:>
  metricGroupMerge[Lookup[packetSymbol,"Coefficients"]];
 gate["entire original grouped implementation restores exactly",(candidate/.
  HoldPattern[metricGroupMerge[values_]]:>merge[values])===original];
 fixed={DownValues[groupDenominators],DownValues[polynomialPieceMap],DownValues[mapExpression],
  DownValues[familyRows],DownValues[merge],DownValues[certifyGroupMerge],DownValues[put],DownValues[saveNative]};
 relative="Hgg/s08_mapping_inputs_result/s08_component_0008.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_recovery_execution.json"}],"RawJSON"];
 gate["accepted complete own merge input",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 own=Get[path];
 gate["same complete own merge conventions",own["InputHashes"]===inputHashes&&own["TargetInputHash"]===targetInputHash&&
  own["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&Length[own["Checks"]]>0&&And@@Values[own["Checks"]]];
 {serialSeconds,serial}=AbsoluteTiming[bounded[groupedMapExpression[own["Expression"],
  "component_"<>ToString[own["Component"]]],"original complete own group merge"]];
 DownValues[groupedMapExpression]=candidate;
 {parallelSeconds,parallel}=AbsoluteTiming[bounded[groupedMapExpression[own["Expression"],
  "component_"<>ToString[own["Component"]]],"per-integral complete own group merge"]];
 gate["all own original and per-integral coefficients agree",partitionSameCoefficients[parallel,serial]];
 gate["all scalar grouping cache and certificate definitions retained",fixed===
  {DownValues[groupDenominators],DownValues[polynomialPieceMap],DownValues[mapExpression],
   DownValues[familyRows],DownValues[merge],DownValues[certifyGroupMerge],DownValues[put],DownValues[saveNative]}];
 metricMergeEvidence=<|"SourceHash"->FileHash[metricMergeSource,"SHA256"],"BaseHash"->FileHash[metricMergeBase,"SHA256"],
  "MergeSourceHash"->FileHash[producer,"SHA256"],"OwnInputHash"->FileHash[path,"SHA256"],
  "OwnAcceptedComparison"->True,"WorkerCount"->workers,"SerialOwnSeconds"->serialSeconds,
  "ParallelOwnSeconds"->parallelSeconds,"OriginalGroupDefinitions"->original,"CandidateGroupDefinitions"->candidate,
  "PerIntegralDefinitions"->DownValues[metricMergeKey],"CheckpointDefinitions"->DownValues[metricMergeSave],
  "FixedDefinitions"->fixed|>;
 Print["ACCEPTED_METRIC_COEFFICIENT_MERGE workers ",workers," own_seconds ",InputForm[{serialSeconds,parallelSeconds}]];
 ClearSystemCache[]];

metricMergeOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[metricMergeOriginalTail]=metricMergeOriginalTailDefinitions/.coordinateTail->metricMergeOriginalTail;
If[(DownValues[metricMergeOriginalTail]/.metricMergeOriginalTail->coordinateTail)=!=metricMergeOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=metricMergeOriginalTail[text],old,new},
 old="targetComponents = If[workers > 0,\n  ParallelMap[mapTargetTask, targetRest, Method -> \"FinestGrained\"], mapTargetTask /@ targetRest];";
 new="metricMergeStart[];\ntargetComponents = mapTargetTask /@ targetRest;";
 changed=coordinateReplace[changed,old,new];
 coordinateReplace[changed,"\ntargetResult = <|",
  "\ntargetResult = <|\"MetricCoefficientMerge\"->Join[metricMergeEvidence,<|\"Measurements\"->metricMergeMeasurements|>], "]];
ToExpression[partitionRun,InputForm];

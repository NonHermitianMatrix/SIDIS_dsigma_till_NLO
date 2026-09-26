(* Use the accepted compact grouping body directly for remaining components. *)
$HistoryLength=0;
coordinateSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_direct_groups.wls"}];
coordinateBase=FileNameJoin[{Directory[],"common","s08_resume_Hgg_compact_groups.wls"}];
If[!SyntaxQ[Import[coordinateSource,"Text"]]||IntegerString[FileHash[coordinateBase,"SHA256"],16,64]=!=
 "50d21381fbe2d71fc8e4b21002de24527bbad5a85e760e4e010016cbdd4551ad",Quit[1]];
coordinateMode=Environment["POLARIZED_SIDIS_DIRECT_GROUP_COMPONENT"];
coordinateSubset=coordinateMode==="13";
If[!MemberQ[{$Failed,"","13"},coordinateMode],Quit[1]];
coordinateReplace[text_,old_,new_]:=Module[{changed},
 gate["unique coordinate resource interface",StringCount[text,old]===1];
 changed=StringReplace[text,old->new];
 gate["entire coordinate task restored exactly",SyntaxQ[changed]&&StringReplace[changed,new->old]===text];changed];
SetAttributes[hggComponentBound,HoldFirst];
hggComponentBound[value_,label_]:=MemoryConstrained[
 TimeConstrained[value,targetTimeLimit,gate["complete component time "<>ToString[label,InputForm],False]],
 8*1024^3,gate["complete component memory "<>ToString[label,InputForm],False]];
coordinateTask[text_]:=Module[{old,new},
 old="With[{hggLoadedValue=task[\"Value\"]}, bounded[hggPhaseMap[hggLoadedValue /. coordinateRules, \"component_\" <> ToString[index]],\n    {\"complete raw cut mapping\", index}]]";
 new="With[{hggLoadedValue=task[\"Value\"]}, With[{hggCoordinateValue=bounded[hggLoadedValue /. coordinateRules, {\"coordinate substitution\", index}]}, coordinateInputCheck[hggCoordinateValue,index]; hggComponentBound[hggPhaseMap[hggCoordinateValue, \"component_\" <> ToString[index]],\n    {\"complete raw cut mapping\", index}]]]";
 coordinateReplace[text,old,new]];
directGroupingInstall[]:=Module[{wrapper,original,candidate},
 wrapper=DownValues[groupDenominators];original=DownValues[hggOriginalGrouping];
 gate["one current grouping lookup wrapper",Length[wrapper]===1&&Count[wrapper,_hggFactoredGroups,Infinity]===1];
 candidate=original/.hggOriginalGrouping->groupDenominators;
 gate["complete accepted grouping body restored exactly",Length[original]===1&&
  (candidate/.groupDenominators->hggOriginalGrouping)===original&&FreeQ[candidate,hggFactoredGroups]];
 DownValues[groupDenominators]=candidate;
 gate["direct accepted compact grouping installed",DownValues[groupDenominators]===candidate];
 directGroupingEvidence=<|"OriginalWrapper"->wrapper,"AcceptedBody"->original,
  "InstalledBody"->candidate,"SourceHash"->FileHash[coordinateSource,"SHA256"]|>;
 AssociateTo[hggPolynomialEvidence,"DirectGrouping"->directGroupingEvidence];
 Print["DIRECT_COMPACT_GROUPING_INSTALLED"]];

coordinateInputCheck[value_,index_]:=If[TrueQ[coordinateSubset]&&index===13,Module[{relative,path,receipt},
 relative="Hgg/s08_blocked_equations_result/s08_component_0013_equation.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted exact coordinate comparison equation",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 gate["entire actual coordinate input unchanged",hggMapRead[Get[path]===value,"actual coordinate input equality"]];
 Print["COORDINATE_INPUT_ACCEPTED ",index," bytes ",ByteCount[value]]]];
coordinateTail[text_]:=Module[{changed=text,relative,path,receipt,proof,evidence},
 evidence=<|"SourceHash"->FileHash[coordinateSource,"SHA256"],"BaseHash"->FileHash[coordinateBase,"SHA256"],
  "SeparateCoordinateBound"->True,"CompleteChannel"->!coordinateSubset,
  "ComponentMemoryBytes"->8*1024^3,"OperationMemoryBytes"->targetMemoryLimit,
  "ComponentBoundDefinitions"->DownValues[hggComponentBound],"DirectGrouping"->directGroupingEvidence|>;
 If[!coordinateSubset,
  relative="Hgg/s08_direct_group_component_result/s08_result.wl";path=FileNameJoin[{root,relative}];
  receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
  gate["accepted actual coordinate-boundary component",TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
   receipt["reviewed_sha256"]["common/s08_map_Hgg_direct_groups.wls"]===IntegerString[FileHash[coordinateSource,"SHA256"],16,64]];
  proof=Get[path];
  gate["complete coordinate-boundary validation contract",proof["Schema"]==="polarized-sidis-real-target-subset-v1"&&
   proof["Channel"]===channel&&proof["InputHash"]===targetInputHash&&proof["InputHashes"]===inputHashes&&
   proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["SelectedComponentIndices"]==={13}&&
   TrueQ[proof["MappingAccepted"]]&&And@@Values[proof["Checks"]]&&Length[proof["Components"]]===1&&
   TrueQ[First[proof["Components"]]["ReconstructionPassed"]]&&And@@Values[First[proof["Components"]]["Checks"]]&&
   TrueQ[First[proof["Components"]]["Checks"]["entire actual coordinate input unchanged"]]];
  AssociateTo[evidence,{"ValidationHash"->FileHash[path,"SHA256"],"ValidationReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"]}]];
 changed=coordinateReplace[changed,"DistributeDefinitions[certifyFamilyLaurent,",
  "DistributeDefinitions[hggComponentBound,coordinateSubset,coordinateInputCheck,certifyFamilyLaurent,"];
 changed=coordinateReplace[changed,"\ntargetResult = <|","\ntargetResult = <|\"CoordinateBoundary\"->"<>ToString[evidence,InputForm]<>", "];
 If[coordinateSubset,
  changed=coordinateReplace[changed,"targetRest = Range[If[channel === \"Hqqprime\", 2, 1], Length[tasks]];","targetRest = {13};"];
  changed=coordinateReplace[changed,"Length[targetComponents] === Length[tasks]","Length[targetComponents] === Length[targetRest]"];
  changed=coordinateReplace[changed,"\"Schema\" -> \"polarized-sidis-real-target-map-v1\"","\"Schema\" -> \"polarized-sidis-real-target-subset-v1\", \"SelectedComponentIndices\"->targetRest"];
  changed=coordinateReplace[changed,"targetDir = FileNameJoin[{root, channel, \"s08_targets_result\"}];","targetDir = FileNameJoin[{root, channel, \"s08_direct_group_component_result\"}];"];
  changed=coordinateReplace[changed,"PASS: s08_map_real_targets","PASS: s08_Hgg_direct_group_component"]];changed];
coordinateText=StringTrim[Import[coordinateBase,"Text"]];coordinateTerminal="ToExpression[compactResumeRun,InputForm];";
If[!StringEndsQ[coordinateText,coordinateTerminal],Quit[1]];
coordinatePrefix=StringDrop[coordinateText,-StringLength[coordinateTerminal]];
If[!SyntaxQ[coordinatePrefix],Quit[1]];ToExpression[coordinatePrefix,InputForm];
coordinateEdits={
 "compactResumeInstall[];"->"compactResumeInstall[];directGroupingInstall[];",
 "\"s08_grouped_comparison_result\""->"\"s08_direct_group_control_result\"",
 "If[Lookup[hggOwnProof,\"InputHash\",None]"->"If[coordinateSubset||Lookup[hggOwnProof,\"InputHash\",None]",
 "ToExpression[hggGroupedTaskCandidate,InputForm];"->"hggGroupedTaskCandidate=coordinateTask[hggGroupedTaskCandidate];ToExpression[hggGroupedTaskCandidate,InputForm];",
 "ToExpression[hggGroupedCandidateTail,InputForm];"->"hggGroupedCandidateTail=coordinateTail[hggGroupedCandidateTail];ToExpression[hggGroupedCandidateTail,InputForm];"};
If[!And@@(StringCount[compactResumeRun,First[#]]===1&/@coordinateEdits),Print["FAIL: unique full coordinate stage handoffs"];Quit[1]];
coordinateRun=StringReplace[compactResumeRun,coordinateEdits];
If[!SyntaxQ[coordinateRun]||StringReplace[coordinateRun,Reverse/@coordinateEdits]=!=compactResumeRun,
 Print["FAIL: unchanged complete coordinate-boundary pipeline"];Quit[1]];
ToExpression[coordinateRun,InputForm];

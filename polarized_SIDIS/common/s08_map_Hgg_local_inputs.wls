(* Bind large dispatcher inputs once; retain the complete accepted mapping. *)
$HistoryLength=0;
coordinateSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_local_inputs.wls"}];
coordinateBase=FileNameJoin[{Directory[],"common","s08_resume_Hgg_compact_groups.wls"}];
If[!SyntaxQ[Import[coordinateSource,"Text"]]||IntegerString[FileHash[coordinateBase,"SHA256"],16,64]=!=
 "50d21381fbe2d71fc8e4b21002de24527bbad5a85e760e4e010016cbdd4551ad",Quit[1]];
coordinateMode=Environment["POLARIZED_SIDIS_LOCAL_INPUT_COMPONENT"];
coordinateSubset=coordinateMode==="13";
If[!MemberQ[{$Failed,"","13"},coordinateMode],Quit[1]];
coordinateReplace[text_,old_,new_]:=Module[{changed},
 gate["unique coordinate resource interface",StringCount[text,old]===1];
 changed=StringReplace[text,old->new];
 gate["entire coordinate task restored exactly",SyntaxQ[changed]&&StringReplace[changed,new->old]===text];changed];
coordinateTask[text_]:=Module[{old,new},
 old="With[{hggLoadedValue=task[\"Value\"]}, bounded[hggPhaseMap[hggLoadedValue /. coordinateRules, \"component_\" <> ToString[index]],\n    {\"complete raw cut mapping\", index}]]";
 new="With[{hggLoadedValue=task[\"Value\"]}, With[{hggCoordinateValue=bounded[hggLoadedValue /. coordinateRules, {\"coordinate substitution\", index}]}, coordinateInputCheck[hggCoordinateValue,index]; bounded[hggPhaseMap[hggCoordinateValue, \"component_\" <> ToString[index]],\n    {\"complete raw cut mapping\", index}]]]";
 coordinateReplace[text,old,new]];

localInputInstall[]:=Module[{path,text,starts,finish,original,candidate,old,header,newHeader,variable,measurements={}},
 path=FileNameJoin[{root,"common","s08_resume_Hqg_polynomial_maps.wls"}];
 gate["pinned entire phase implementation",IntegerString[FileHash[path,"SHA256"],16,64]===
  "1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9"];
 text=Import[path,"Text"];
 Do[
  starts=StringPosition[text,spec[[1]]];finish=StringPosition[text,spec[[2]]];
  gate["unique complete local-input function",Length[starts]===1&&Length[finish]===1];
  original=StringTrim[StringTake[text,{First[First[starts]],First[First[finish]]-1}]];
  old=Switch[spec[[3]],"outer",DownValues[numericOuterFactor],"phase",DownValues[numericPhaseMap]];
  gate["original complete local-input source syntax",SyntaxQ[original]];ToExpression[original,InputForm];
  gate["original complete local-input definition unchanged",old===
   Switch[spec[[3]],"outer",DownValues[numericOuterFactor],"phase",DownValues[numericPhaseMap]]];
  header=spec[[1]];variable=spec[[4]];
  newHeader=header<>variable<>"=expression,";
  gate["local input name absent from original function",StringFreeQ[original,variable]&&StringStartsQ[original,header]];
  candidate=newHeader<>StringReplace[StringDrop[original,StringLength[header]],"expression"->variable];
  gate["exact complete local binding source reversal",SyntaxQ[candidate]&&
   header<>StringReplace[StringDrop[candidate,StringLength[newHeader]],variable->"expression"]===original&&
   StringCount[candidate,"expression"]===StringCount[header,"expression"]+1];
  ToExpression[candidate,InputForm];
  AppendTo[measurements,<|"Function"->spec[[3]],"OriginalDefinitions"->old,
   "CandidateDefinitions"->Switch[spec[[3]],"outer",DownValues[numericOuterFactor],"phase",DownValues[numericPhaseMap]],
   "OriginalArgumentOccurrences"->StringCount[original,"expression"],
   "CandidateArgumentOccurrences"->StringCount[candidate,"expression"]|>],
  {spec,{{"numericOuterFactor[expression_]:=Module[{","\nnumericPhaseMap[expression_,key_]","outer","boundOuterInput"},
   {"numericPhaseMap[expression_,key_]:=Module[{","\ninstallNumericPhase[]","phase","boundPhaseInput"}}}];
 localInputEvidence=<|"SourceHash"->FileHash[coordinateSource,"SHA256"],"OriginalSourceHash"->FileHash[path,"SHA256"],
  "Functions"->measurements|>;
 AssociateTo[hggPolynomialEvidence,"LocalInputBinding"->localInputEvidence];
 Print["LOCAL_INPUT_BINDINGS_INSTALLED ",InputForm[KeyTake[#,{
  "Function","OriginalArgumentOccurrences","CandidateArgumentOccurrences"}]&/@measurements]]];

coordinateInputCheck[value_,index_]:=If[TrueQ[coordinateSubset]&&index===13,Module[{relative,path,receipt},
 relative="Hgg/s08_blocked_equations_result/s08_component_0013_equation.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted exact coordinate comparison equation",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 gate["entire actual coordinate input unchanged",hggMapRead[Get[path]===value,"actual coordinate input equality"]];
 Print["COORDINATE_INPUT_ACCEPTED ",index," bytes ",ByteCount[value]]]];
coordinateTail[text_]:=Module[{changed=text,relative,path,receipt,proof,evidence},
 evidence=<|"SourceHash"->FileHash[coordinateSource,"SHA256"],"BaseHash"->FileHash[coordinateBase,"SHA256"],
  "SeparateCoordinateBound"->True,"CompleteChannel"->!coordinateSubset,"LocalInputBinding"->localInputEvidence|>;
 If[!coordinateSubset,
  relative="Hgg/s08_local_input_component_result/s08_result.wl";path=FileNameJoin[{root,relative}];
  receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
  gate["accepted actual coordinate-boundary component",TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
   receipt["reviewed_sha256"]["common/s08_map_Hgg_local_inputs.wls"]===IntegerString[FileHash[coordinateSource,"SHA256"],16,64]];
  proof=Get[path];
  gate["complete coordinate-boundary validation contract",proof["Schema"]==="polarized-sidis-real-target-subset-v1"&&
   proof["Channel"]===channel&&proof["InputHash"]===targetInputHash&&proof["InputHashes"]===inputHashes&&
   proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["SelectedComponentIndices"]==={13}&&
   TrueQ[proof["MappingAccepted"]]&&And@@Values[proof["Checks"]]&&Length[proof["Components"]]===1&&
   TrueQ[First[proof["Components"]]["ReconstructionPassed"]]&&And@@Values[First[proof["Components"]]["Checks"]]&&
   TrueQ[First[proof["Components"]]["Checks"]["entire actual coordinate input unchanged"]]];
  AssociateTo[evidence,{"ValidationHash"->FileHash[path,"SHA256"],"ValidationReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"]}]];
 changed=coordinateReplace[changed,"DistributeDefinitions[certifyFamilyLaurent,",
  "DistributeDefinitions[coordinateSubset,coordinateInputCheck,certifyFamilyLaurent,"];
 changed=coordinateReplace[changed,"\ntargetResult = <|","\ntargetResult = <|\"CoordinateBoundary\"->"<>ToString[evidence,InputForm]<>", "];
 If[coordinateSubset,
  changed=coordinateReplace[changed,"targetRest = Range[If[channel === \"Hqqprime\", 2, 1], Length[tasks]];","targetRest = {13};"];
  changed=coordinateReplace[changed,"Length[targetComponents] === Length[tasks]","Length[targetComponents] === Length[targetRest]"];
  changed=coordinateReplace[changed,"\"Schema\" -> \"polarized-sidis-real-target-map-v1\"","\"Schema\" -> \"polarized-sidis-real-target-subset-v1\", \"SelectedComponentIndices\"->targetRest"];
  changed=coordinateReplace[changed,"targetDir = FileNameJoin[{root, channel, \"s08_targets_result\"}];","targetDir = FileNameJoin[{root, channel, \"s08_local_input_component_result\"}];"];
  changed=coordinateReplace[changed,"PASS: s08_map_real_targets","PASS: s08_Hgg_local_input_component"]];changed];
coordinateText=StringTrim[Import[coordinateBase,"Text"]];coordinateTerminal="ToExpression[compactResumeRun,InputForm];";
If[!StringEndsQ[coordinateText,coordinateTerminal],Quit[1]];
coordinatePrefix=StringDrop[coordinateText,-StringLength[coordinateTerminal]];
If[!SyntaxQ[coordinatePrefix],Quit[1]];ToExpression[coordinatePrefix,InputForm];
coordinateEdits={
 "compactResumeInstall[];"->"compactResumeInstall[];localInputInstall[];",
 "\"s08_grouped_comparison_result\""->"\"s08_local_input_control_result\"",
 "If[Lookup[hggOwnProof,\"InputHash\",None]"->"If[True||Lookup[hggOwnProof,\"InputHash\",None]",
 "ToExpression[hggGroupedTaskCandidate,InputForm];"->"hggGroupedTaskCandidate=coordinateTask[hggGroupedTaskCandidate];ToExpression[hggGroupedTaskCandidate,InputForm];",
 "ToExpression[hggGroupedCandidateTail,InputForm];"->"hggGroupedCandidateTail=coordinateTail[hggGroupedCandidateTail];ToExpression[hggGroupedCandidateTail,InputForm];"};
If[!And@@(StringCount[compactResumeRun,First[#]]===1&/@coordinateEdits),Print["FAIL: unique full coordinate stage handoffs"];Quit[1]];
coordinateRun=StringReplace[compactResumeRun,coordinateEdits];
If[!SyntaxQ[coordinateRun]||StringReplace[coordinateRun,Reverse/@coordinateEdits]=!=compactResumeRun,
 Print["FAIL: unchanged complete coordinate-boundary pipeline"];Quit[1]];
ToExpression[coordinateRun,InputForm];

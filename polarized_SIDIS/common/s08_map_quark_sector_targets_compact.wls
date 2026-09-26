(* Complete the canonical target map using the verified reference pair order. *)
$HistoryLength=0;
pairDispatchPath=FileNameJoin[{Directory[],"common","s08_map_quark_sector_targets_compact.wls"}];
pairComparisonPath=FileNameJoin[{Directory[],"common","s08_check_quark_sector_pair_mapping.wls"}];
If[IntegerString[FileHash[pairComparisonPath,"SHA256"],16,64]=!=
  "25e5127b4e274c5742581cd168740836471307b3ba4958b8df6765bfc9680c18",Quit[1]];
pairProgramText=Import[pairComparisonPath,"Text"];
If[!SyntaxQ[Import[pairDispatchPath,"Text"]]||
  StringCount[pairProgramText,"\nslots ="]=!=1||
  StringCount[pairProgramText,"\nCloseKernels[];\npairResult ="]=!=1,Quit[1]];
pairInitializationEnd=First[First[StringPosition[pairProgramText,"\nslots ="]]];
pairExecutionEnd=First[First[StringPosition[pairProgramText,"\nCloseKernels[];\npairResult ="]]];
pairInitialization=StringTake[pairProgramText,pairInitializationEnd-1];
pairExecution=StringTake[pairProgramText,{pairInitializationEnd,pairExecutionEnd-1}];
If[!SyntaxQ[pairInitialization]||!SyntaxQ[pairExecution],Quit[1]];
ToExpression[pairInitialization,InputForm];
pairProofPath=FileNameJoin[{root,channel,"s08_pair_mapping_result","s08_result.wl"}];
pairReceipt=Import[FileNameJoin[{root,channel,"s08_pair_mapping_result","s08_execution.json"}],"RawJSON"];
gate["accepted complete pair comparison receipt",TrueQ[pairReceipt["passed"]]&&
  pairReceipt["result_sha256"][channel<>"/s08_pair_mapping_result/s08_result.wl"]===
    IntegerString[FileHash[pairProofPath,"SHA256"],16,64]];
pairProof=Get[pairProofPath];
gate["accepted complete own-channel pair comparison",
  pairProof["Schema"]==="polarized-sidis-pair-mapping-comparison-v1"&&
  pairProof["Channel"]===channel&&And@@Values[pairProof["Checks"]]&&
  TrueQ[pairProof["Checks"]["entire own accepted control map reproduced"]]&&
  AllTrue[pairProof["Components"],TrueQ[#["ReconstructionPassed"]]&]];
gate["pair comparison exact production source and inputs",
  pairProof["SourceHash"]===FileHash[pairComparisonPath,"SHA256"]&&
  pairProof["ConfigurationHash"]===FileHash[pairConfigPath,"SHA256"]&&
  pairProof["InputHashes"]===inputHashes&&pairProof["TargetInputHash"]===targetInputHash&&
  pairProof["MappingInputHash"]===inputHash&&pairProof["InputHash"]===pairStudyHash&&
  pairProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
gate["pair comparison unchanged functions and inventory",
  pairProof["PairFiles"]===pairNames&&pairProof["PairInputHashes"]===pairConfig["files"]&&
  pairProof["OriginalMappingDefinitions"]===DownValues[mapExpression]&&
  pairProof["OriginalMergeDefinitions"]===DownValues[merge]&&
  pairProof["SelectedIndices"]===pairSelected];
pairProofSelected=pairSelected;
pairSectorIndices=Select[Range[Length[tasks]],tasks[[#]]["Sector"]===pairLabel&];
pairOtherIndices=Complement[Range[Length[tasks]],pairSectorIndices];
gate["sector dispatch exactly partitions original tasks",Sort[Join[pairSectorIndices,pairOtherIndices]]===Range[Length[tasks]]];
pairOriginalTargetFunction=targetSection[pairBaseText];
gate["unchanged other-sector mapper syntax",SyntaxQ[pairOriginalTargetFunction]];
ToExpression[pairOriginalTargetFunction,InputForm];
pairOtherMap[packet_] := Catch[Block[{tasks=ConstantArray[Null,packet["TaskCount"]],checks=<||>},
  tasks[[packet["TaskIndex"]]]=packet["Task"];
  gate["assigned original task hash",Hash[tasks[[packet["TaskIndex"]]],"SHA256"]===packet["TaskHash"]];
  gate["assigned original task index and count",tasks[[packet["TaskIndex"]]]===packet["Task"]&&Length[tasks]===packet["TaskCount"]];
  mapTargetTask[packet["TaskIndex"]]],"TargetMapFailure"];

pairControlStart=First[First[StringPosition[pairBaseText,"targetControlTaskFunction[unused_]"]]];
pairControlEnd=First[First[StringPosition[pairBaseText,"\nIf[!IntegerQ[slots]"]]];
pairControlText=StringTake[pairBaseText,{pairControlStart,pairControlEnd-1}];
gate["original fresh-worker control syntax",SyntaxQ[pairControlText]];
ToExpression[pairControlText,InputForm];

pairWorkerInterface="DistributeDefinitions[gate, bounded, targetTimeLimit, targetMemoryLimit, pairSave, pairMap, pairCache,";
pairLoopEntry="  task = tasks[[index]];";
pairLoopExit="  AppendTo[pairComponents, component]; Print[\"REFERENCE_PAIR_COMPONENT_ACCEPTED \", index];";
pairLoopRange="{index, pairSelected}];";
pairDispatchBoundary="$DistributedContexts = None;";
gate["unique pair production interfaces",And@@(StringCount[pairExecution,#]===1&/@
  {pairWorkerInterface,pairLoopEntry,pairLoopExit,pairLoopRange,pairDispatchBoundary})];
pairResumeCode="\n  canonicalPath=FileNameJoin[{targetCache,\"component_\"<>IntegerString[index,10,4]<>\".wl\"}];\n"<>
  "  canonicalSaved=If[FileExistsQ[canonicalPath],Get[canonicalPath],<||>];\n"<>
  "  If[Lookup[canonicalSaved,\"InputHash\",None]===targetInputHash&&"<>
  "TrueQ[Lookup[canonicalSaved,\"ReconstructionPassed\",False]]&&"<>
  "AssociationQ[Lookup[canonicalSaved,\"Checks\",None]]&&Length[canonicalSaved[\"Checks\"]]>0&&"<>
  "And@@Values[canonicalSaved[\"Checks\"]],\n"<>
  "    gate[\"canonical checkpoint task identity\",KeyTake[canonicalSaved,{\"Sector\",\"Kind\",\"Index\"}]===KeyDrop[task,\"Value\"]];\n"<>
  "    AppendTo[pairComponents,canonicalSaved];Print[\"REUSED_CANONICAL_TARGET \",index];Continue[]];";
pairAcceptCode="\n  component=Join[component,<|\"DispatchSourceHash\"->FileHash[pairDispatchPath,\"SHA256\"],"<>
  "\"PairComparisonHash\"->FileHash[pairProofPath,\"SHA256\"]|>];\n"<>
  "  pairSave[component,canonicalPath];\n"<>
  "  If[!MemberQ[pairProofSelected,index],Do[DeleteFile[FileNameJoin[{pairCache,"<>
  "\"component_\"<>ToString[index]<>\"_pair_\"<>ToString[pairNumber]<>\".wl\"}]],"<>
  "{pairNumber,Length[pairNames]}]];\n"<>pairLoopExit;
pairFreshControl="\n"<>
  "targetControl=First[If[workers>0,ParallelMap[targetControlTaskFunction,{1}],targetControlTaskFunction/@{1}]];\n"<>
  "gate[\"fresh target worker accepted\",AssociationQ[targetControl]&&And@@Values[targetControl[\"Checks\"]]];\n";
pairExecution=StringReplace[pairExecution,{
  pairWorkerInterface->("Block[{tasks}, "<>pairWorkerInterface<>"\n    targetControlTaskFunction,targetControlTask,targetFixture,put,pairOtherMap,mapTargetTask,targetCache,targetInputHash,coordinateRules,ruleKeys,reduction,"),
  "familyNames, geometry]];"->"familyNames, geometry]]];",
  pairLoopEntry->(pairLoopEntry<>pairResumeCode),pairLoopExit->pairAcceptCode,
  pairLoopRange->"{index,pairSectorIndices}];",
  pairDispatchBoundary->(pairDispatchBoundary<>pairFreshControl)}];
gate["compact worker distribution boundary",StringCount[pairExecution,"Block[{tasks}, DistributeDefinitions["]===1];
gate["complete pair production syntax",SyntaxQ[pairExecution]];
ToExpression[pairExecution,InputForm];
pairOtherPackets=Table[<|"TaskIndex"->index,"TaskCount"->Length[tasks],"Task"->tasks[[index]],
  "TaskHash"->Hash[tasks[[index]],"SHA256"]|>,{index,pairOtherIndices}];
pairOtherComponents=If[workers>0,
  ParallelMap[pairOtherMap,pairOtherPackets,Method->"FinestGrained"],pairOtherMap/@pairOtherPackets];
CloseKernels[];
pairIndexedComponents=Join[AssociationThread[pairSectorIndices->pairComponents],
  AssociationThread[pairOtherIndices->pairOtherComponents]];
targetComponents=Lookup[pairIndexedComponents,Range[Length[tasks]]];
gate["complete original task order preserved",And@@MapThread[
  KeyTake[#1,{"Sector","Kind","Index"}]===KeyDrop[#2,"Value"]&,{targetComponents,tasks}]];
pairExportStart=First[First[StringPosition[pairBaseText,"\ngate[\"all real target maps accepted\""]]];
pairExport=StringDrop[pairBaseText,pairExportStart-1];
pairResultMetadata="targetSerialized = \"Uncompress[\" <> ToString[bounded[Compress[targetResult]";
gate["unique canonical target export interface",StringCount[pairExport,pairResultMetadata]===1];
pairExport=StringReplace[pairExport,pairResultMetadata->
  ("targetResult=Join[targetResult,<|\"DispatchSourceHash\"->FileHash[pairDispatchPath,\"SHA256\"],"<>
   "\"PairComparisonHash\"->FileHash[pairProofPath,\"SHA256\"]|>];\n"<>pairResultMetadata)];
gate["complete canonical target export syntax",SyntaxQ[pairExport]];
ToExpression[pairExport,InputForm];

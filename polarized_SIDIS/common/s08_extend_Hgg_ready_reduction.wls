(* Overlap accepted subset reduction with mapping; reuse it in full reduction. *)
$HistoryLength=0;
readySource=FileNameJoin[{Directory[],"common","s08_extend_Hgg_ready_reduction.wls"}];
readyBase=FileNameJoin[{Directory[],"common","s08_extend_reused_real_reduction.wls"}];
readyOnly=Environment["POLARIZED_SIDIS_REDUCTION_SUBSET_ONLY"]==="1";
If[!SyntaxQ[Import[readySource,"Text"]]||IntegerString[FileHash[readyBase,"SHA256"],16,64]=!=
 "d5671f76872bc66bbaf3142507e6d919db3205bdbba3845c5cf5311f450c8e22",Quit[1]];
readyChange[text_,edits_]:=Module[{changed},
 If[!And@@(StringCount[text,First[#]]===1&/@edits),Print["FAIL: unique ready-reduction interface"];Quit[1]];
 changed=StringReplace[text,edits];
 If[!SyntaxQ[changed]||StringReplace[changed,Reverse/@edits]=!=text,
  Print["FAIL: unchanged ready-reduction base restored"];Quit[1]];changed];
readyPrefix[text_]:=Module[{changed=text},
 If[readyOnly,changed=readyChange[changed,{
  "mapPath = FileNameJoin[{root, channel, \"s08_targets_result\", \"s08_result.wl\"}];"->
  "mapPath = FileNameJoin[{root, channel, \"s08_direct_group_component_result\", \"s08_result.wl\"}];",
  "map[\"Schema\"] === \"polarized-sidis-real-target-map-v1\""->
  "map[\"Schema\"] === \"polarized-sidis-real-target-subset-v1\" && map[\"SelectedComponentIndices\"] === {13}",
  "accepted complete real target map"->"accepted complete supplied component13 target map"}]];
 readyChange[changed,{"reuseSetup[];\ninputHashes = Association["->
  "reuseSetup[];readySetup[];\ninputHashes = Association["}]];
readySetup[]:=Module[{relative,path,receipt,packet,incoming,common},
 gate["ready reduction is Hgg production",channel==="Hgg"&&!reuseControl];
 AppendTo[inputPaths,readySource];readySubsetHash=None;readySubsetReceiptHash=None;readyOverlapCount=0;
 If[readyOnly,
  relative="Hgg/s08_direct_group_component_result/s08_result.wl";
  path=FileNameJoin[{root,"Hgg","s08_direct_group_component_result","s08_execution.json"}];
  receipt=Import[path,"RawJSON"];
  gate["authentic complete component13 map receipt",TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][relative]===IntegerString[FileHash[mapPath,"SHA256"],16,64]&&
   map["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&Length[map["Components"]]===1&&
   TrueQ[First[map["Components"]]["ReconstructionPassed"]]&&And@@Values[First[map["Components"]]["Checks"]]];
  AppendTo[inputPaths,path];Return[Null]];
 relative="Hgg/s08_ready_reduction_result/s08_reduction.wl";path=FileNameJoin[{root,relative}];
 readyReceiptPath=FileNameJoin[{DirectoryName[path],"s08_execution.json"}];receipt=Import[readyReceiptPath,"RawJSON"];
 gate["authentic completed subset reduction",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_extend_Hgg_ready_reduction.wls"]===IntegerString[FileHash[readySource,"SHA256"],16,64]];
 packet=Get[path];
 gate["same accepted subset reduction contract",packet["Schema"]==="polarized-sidis-real-reduction-subset-v1"&&
  packet["Channel"]===channel&&TrueQ[packet["Accepted"]]&&And@@Values[packet["Checks"]]&&
  packet["ChannelCoverageComplete"]===False&&packet["SelectedComponentIndices"]==={13}&&
  packet["SubsetDispatchSourceHash"]===FileHash[readySource,"SHA256"]&&
  packet["DispatchSourceHash"]===FileHash[readyBase,"SHA256"]&&packet["SourceHash"]===FileHash[reuseBase,"SHA256"]&&
  packet["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  packet["MappingInputHashes"]===map["InputHashes"]&&
  packet["GeometryHash"]===reuseProof["GeometryHash"]&&packet["BaselineReductionHash"]===reuseProof["BaselineReductionHash"]&&
  Sort[packet["Masters"]]===Sort[baseline["Masters"]]&&packet["CutEnergyConditions"]===geometry["CutEnergyConditions"]&&
  packet["Families"]===KeyTake[geometry["Families"],Keys[packet["Families"]]]];
 KeyValueMap[gate["unchanged subset reduction input "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,
  packet["InputHashes"]];
 incoming=Association[packet["Rules"]];
 gate["complete exact subset rule inventory",Length[incoming]===Length[packet["Rules"]]&&
  Complement[packet["Targets"],Keys[incoming]]==={}&&Complement[packet["Targets"],targets]==={}&&
  Complement[Cases[Values[incoming],_CutIntegral,Infinity],baseline["Masters"]]==={}&&
  FreeQ[incoming,_Real|$Failed|$Aborted|_Missing]];
 common=Intersection[Keys[incoming],Keys[reuseRuleMap]];
 gate["all accepted subset and reused overlaps agree",And@@Table[
  incoming[key]===reuseRuleMap[key]||bounded[zero[incoming[key]-reuseRuleMap[key]],
   {"subset rule overlap",key}],{key,common}]];
 AssociateTo[reuseRuleMap,Normal[KeyDrop[incoming,Keys[reuseRuleMap]]]];
 readySubsetHash=FileHash[path,"SHA256"];readySubsetReceiptHash=FileHash[readyReceiptPath,"SHA256"];
 readyOverlapCount=Length[common];inputPaths=Join[inputPaths,{path,readyReceiptPath}];
 Print["ACCEPTED_SUBSET_RULES_REUSED ",Length[incoming]," overlap ",readyOverlapCount]];
readySuffix[text_]:=Module[{changed=text,marker},
 If[readyOnly,changed=readyChange[changed,{
  "resultDir = FileNameJoin[{root, channel, \"s08_reduction_result\"}];"->
  "resultDir = FileNameJoin[{root, channel, \"s08_ready_reduction_result\"}];",
  "\"Schema\" -> \"polarized-sidis-real-reduction-extension-v1\""->
  "\"Schema\" -> \"polarized-sidis-real-reduction-subset-v1\"",
  "complete actual spin-target coverage"->"complete supplied component13 target coverage"}]];
 marker="\nput[result, FileNameJoin[{resultDir, \"s08_reduction.wl\"}]];";
 readyChange[changed,{marker->
  "\nresult=Join[result,<|\"SubsetDispatchSourceHash\"->FileHash[readySource,\"SHA256\"],\"ChannelCoverageComplete\"->!readyOnly,\"SelectedComponentIndices\"->If[readyOnly,map[\"SelectedComponentIndices\"],All],\"NativeVersions\"->{$Version,FeynCalc`$FeynCalcVersion},\"MappingInputHashes\"->map[\"InputHashes\"],\"AcceptedSubsetReductionHash\"->readySubsetHash,\"AcceptedSubsetReceiptHash\"->readySubsetReceiptHash,\"AcceptedSubsetOverlapCount\"->readyOverlapCount|>];"<>marker}]];
readyText=Import[readyBase,"Text"];
readyRun=readyChange[readyText,{
 "ToExpression[reusePrefixCandidate,InputForm];"->"ToExpression[readyPrefix[reusePrefixCandidate],InputForm];",
 "ToExpression[reuseSuffixCandidate,InputForm];"->"ToExpression[readySuffix[reuseSuffixCandidate],InputForm];"}];
ToExpression[readyRun,InputForm];

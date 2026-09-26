(* Preserve the reference Kira workflow and reuse accepted covered targets. *)
$HistoryLength=0;
reuseSource=FileNameJoin[{Directory[],"common","s08_extend_reused_real_reduction.wls"}];
reuseBase=FileNameJoin[{Directory[],"common","s08_extend_real_reduction.wls"}];
If[!SyntaxQ[Import[reuseSource,"Text"]]||IntegerString[FileHash[reuseBase,"SHA256"],16,64]=!=
 "db9875bb42086b9e52a405bc61b46262661cf91b72681dc57c22c977121a22e7",Quit[1]];
reuseControl=Environment["POLARIZED_SIDIS_REDUCTION_REUSE_CONTROL"]==="1";
reuseSetup[]:=Module[{relative,path,receipt,collector},
 relative="Hgg/s08_compatible_reductions_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 reuseReceiptPath=FileNameJoin[{DirectoryName[path],"s08_execution.json"}];
 receipt=Import[reuseReceiptPath,"RawJSON"];
 gate["accepted compatible-rule execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 reuseProof=Get[path];collector=FileNameJoin[{root,"common","s08_collect_compatible_reductions.wls"}];
 gate["same complete compatible-rule library",reuseProof["Schema"]==="polarized-sidis-compatible-cut-reductions-v1"&&
  TrueQ[reuseProof["Accepted"]]&&TrueQ[reuseProof["OwnComparisonPassed"]]&&And@@Values[reuseProof["Checks"]]&&
  reuseProof["SourceHash"]===FileHash[collector,"SHA256"]&&reuseProof["OriginalExtensionSourceHash"]===FileHash[reuseBase,"SHA256"]&&
  reuseProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  reuseProof["GeometryHash"]===FileHash[FileNameJoin[{root,library["Library"]["s02"]["File"]}],"SHA256"]&&
  reuseProof["BaselineReductionHash"]===FileHash[FileNameJoin[{root,library["Library"]["s04"]["File"]}],"SHA256"]&&
  Sort[reuseProof["Masters"]]===Sort[baseline["Masters"]]&&reuseProof["Families"]===geometry["Families"]&&
  reuseProof["CutEnergyConditions"]===geometry["CutEnergyConditions"]];
 KeyValueMap[gate["unchanged compatible-rule input "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,
  reuseProof["InputHashes"]];
 reusePath=path;reuseRuleMap=Association[reuseProof["Rules"]];
 gate["unique accepted reusable rule keys",Length[reuseRuleMap]===Length[reuseProof["Rules"]]];
 inputPaths=Join[inputPaths,{reuseSource,path,reuseReceiptPath,collector}]];
reuseText=Import[reuseBase,"Text"];
reuseBegin="\n(* BEGIN REFERENCE KIRA WORKFLOW *)\n";reuseEnd="\n(* END REFERENCE KIRA WORKFLOW *)\n";
If[StringCount[reuseText,reuseBegin]=!=1||StringCount[reuseText,reuseEnd]=!=1,Quit[1]];
reuseSplit=StringSplit[reuseText,reuseBegin];reusePrefix=First[reuseSplit];
reuseSplit=StringSplit[Last[reuseSplit],reuseEnd];reuseNativeBlock=First[reuseSplit];reuseSuffix=Last[reuseSplit];
If[reusePrefix<>reuseBegin<>reuseNativeBlock<>reuseEnd<>reuseSuffix=!=reuseText,Quit[1]];
reuseOld="inputHashes = Association[";reuseNew="reuseSetup[];\ninputHashes = Association[";
If[StringCount[reusePrefix,reuseOld]=!=1,Quit[1]];
reusePrefixCandidate=StringReplace[reusePrefix,reuseOld->reuseNew];
If[!SyntaxQ[reusePrefixCandidate]||StringReplace[reusePrefixCandidate,reuseNew->reuseOld]=!=reusePrefix,Quit[1]];
ToExpression[reusePrefixCandidate,InputForm];
gate["supported exact reduction-reuse mode",If[reuseControl,channel==="Hqg",channel==="Hgg"]];
reuseFullTargets=targets;reuseFullNames=names;reuseFullFamilies=families;
reuseUncovered=Complement[reuseFullTargets,Keys[reuseRuleMap]];
reuseKiraPerformed=reuseUncovered=!={};reuseNativeTargets={};
Print["REUSE_REDUCTION_TARGETS full ",Length[reuseFullTargets]," uncovered ",Length[reuseUncovered]];
If[reuseKiraPerformed,
 targets=Union[baseline["Targets"],First/@baseline["Rules"],baseline["Masters"],reuseUncovered];
 reuseNativeTargets=targets;names=Sort[DeleteDuplicates[targets[[All,1]]]];families=KeyTake[geometry["Families"],names];
 gate["original family and preferred-master configuration retained",names===reuseFullNames&&families===reuseFullFamilies];
 gate["reference Kira block syntax",SyntaxQ[reuseNativeBlock]];
 ToExpression[reuseNativeBlock,InputForm];
 reuseNativeRules=Association[rules];reuseOverlap=Intersection[Keys[reuseNativeRules],Keys[reuseRuleMap]];
 gate["all fresh and reused rule overlaps agree exactly",And@@Table[
  reuseNativeRules[key]===reuseRuleMap[key]||bounded[zero[reuseNativeRules[key]-reuseRuleMap[key]],
   {"fresh/reused Kira rule",key}],{key,reuseOverlap}]];
 reuseSelectedKeys=Complement[reuseFullTargets,Keys[reuseNativeRules]];
 gate["every omitted target has an accepted rule",Complement[reuseSelectedKeys,Keys[reuseRuleMap]]==={}];
 rules=Normal[Join[KeyTake[reuseRuleMap,reuseSelectedKeys],reuseNativeRules]],
 reuseSelectedKeys=reuseFullTargets;rules=Normal[KeyTake[reuseRuleMap,reuseSelectedKeys]];
 bounds=<||>;ruleFiles={};reuseOverlap={};
 If[DirectoryQ[config]&&FileNames["*",config]==={},DeleteDirectory[config]];
 If[DirectoryQ[work]&&FileNames["*",work]==={},DeleteDirectory[work]]];
targets=reuseFullTargets;names=reuseFullNames;families=reuseFullFamilies;
masters=Sort[DeleteDuplicates[Cases[Last/@rules,_CutIntegral,Infinity]]];
gate["unique complete reused reduction keys",DuplicateFreeQ[First/@rules]&&Complement[targets,First/@rules]==={}];
gate["reused coefficients remain exact",FreeQ[rules,_Real|$Failed|$Aborted|_Missing]];
If[reuseControl,
 reuseOwnRelative="Hqg/s08_reduction_result/s08_reduction.wl";
 reuseOwnReceipt=Import[FileNameJoin[{root,"Hqg","s08_reduction_result","s08_execution.json"}],"RawJSON"];
 gate["authentic own completed reduction",TrueQ[reuseOwnReceipt["passed"]]&&
  reuseOwnReceipt["result_sha256"][reuseOwnRelative]===IntegerString[FileHash[FileNameJoin[{root,reuseOwnRelative}],"SHA256"],16,64]];
 reuseOwn=Get[FileNameJoin[{root,reuseOwnRelative}]];reuseAssembled=Association[rules];
 gate["own complete target inventory unchanged",Sort[targets]===Sort[reuseOwn["Targets"]]];
 gate["own entire accepted reduction output reproduced",And@@Map[
  (KeyExistsQ[reuseAssembled,First[#]]&&(reuseAssembled[First[#]]===Last[#]||
   bounded[zero[reuseAssembled[First[#]]-Last[#]],{"complete own output",First[#]}]))&,reuseOwn["Rules"]]];
 gate["own covered reduction avoided Kira",!reuseKiraPerformed]];
reuseExportOld="\nput[result, FileNameJoin[{resultDir, \"s08_reduction.wl\"}]];";
reuseExportNew="\nresult=Join[result,<|\"DispatchSourceHash\"->FileHash[reuseSource,\"SHA256\"],\"CompatibleRuleLibraryHash\"->FileHash[reusePath,\"SHA256\"],\"CompatibleRuleReceiptHash\"->FileHash[reuseReceiptPath,\"SHA256\"],\"KiraRunPerformed\"->reuseKiraPerformed,\"KiraRequestedTargets\"->reuseNativeTargets,\"ReusedTargets\"->reuseSelectedKeys,\"FreshReusedOverlapCount\"->Length[reuseOverlap],\"ReferenceKiraBlockHash\"->Hash[reuseNativeBlock,\"SHA256\"],\"WorkDirectory\"->If[reuseKiraPerformed,work,None]|>];"<>reuseExportOld;
reuseSuffixEdits={reuseExportOld->reuseExportNew};
If[reuseControl,AppendTo[reuseSuffixEdits,
 "resultDir = FileNameJoin[{root, channel, \"s08_reduction_result\"}];"->
 "resultDir = FileNameJoin[{root, \"Hgg\", \"s08_reduction_reuse_control_result\"}];"]];
gate["unique reduction provenance and control-owner edits",And@@(StringCount[reuseSuffix,First[#]]===1&/@reuseSuffixEdits)];
reuseSuffixCandidate=StringReplace[reuseSuffix,reuseSuffixEdits];
gate["all original final reduction gates retained",SyntaxQ[reuseSuffixCandidate]&&
 StringReplace[reuseSuffixCandidate,Reverse/@reuseSuffixEdits]===reuseSuffix];
ToExpression[reuseSuffixCandidate,InputForm];

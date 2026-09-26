(* Reuse accepted native cut rules on the complete local Hgg target inventory. *)
$HistoryLength=0;
localReductionRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[localReductionRoot];
localReductionSource=FileNameJoin[{localReductionRoot,"misc","s09_reduce_Hgg_targets.wls"}];
localReductionConfigPath=FileNameJoin[{localReductionRoot,"misc","s09_inputs.json"}];
localReductionConfig=Import[localReductionConfigPath,"RawJSON"];
require[name_,test_]:=If[!TrueQ[test],Print["FAIL: ",name];Quit[1]];
require["local reduction source",SyntaxQ[ReadString[localReductionSource]]&&
 IntegerString[FileHash[localReductionSource,"SHA256"],16,64]===localReductionConfig["source_sha256"]];
KeyValueMap[Function[{relative,identity},require["local reduction input "<>relative,
 IntegerString[FileHash[FileNameJoin[{localReductionRoot,relative}],"SHA256"],16,64]===identity]],localReductionConfig["input_sha256"]];
localReductionChange[text_,edits_]:=Module[{changed},
 require["unique local reduction interfaces",And@@(StringCount[text,First[#]]===1&/@edits)];
 changed=StringReplace[text,edits];require["complete unchanged reduction restored",SyntaxQ[changed]&&StringReplace[changed,Reverse/@edits]===text];changed];
localReductionBlock[path_,first_,last_]:=Module[{text,begin,end,block},text=ReadString[path];
 begin=StringPosition[text,first];end=StringPosition[text,last];
 require["complete reviewed reduction boundaries",Length[begin]===1&&Length[end]===1];
 block=StringTake[text,{First[First[begin]],First[First[end]]-1}];require["reduction block syntax",SyntaxQ[block]];block];
reuseBase=FileNameJoin[{localReductionRoot,"common","s08_extend_real_reduction.wls"}];
reuseSource=FileNameJoin[{localReductionRoot,"common","s08_extend_reused_real_reduction.wls"}];
readySource=FileNameJoin[{localReductionRoot,"common","s08_extend_Hgg_ready_reduction.wls"}];readyBase=reuseSource;
localReductionOriginal=ReadString[reuseBase];
require["unique executable-selection boundary",StringCount[localReductionOriginal,"\nkira = settings["]===1];
localReductionPrefix=First[StringSplit[localReductionOriginal,"\nkira = settings["]];
localReductionEdits={
 "gate[\"compute allocation\", StringQ[Environment[\"JOB_ID\"]] && !StringStartsQ[$MachineName, \"login\"]];"->
 "gate[\"authorized local reduction\",Environment[\"POLARIZED_SIDIS_LOCAL_AUTHORIZED\"]===\"1\"&&$VersionNumber===15.];",
 "gate[\"isolated runtime\", StringStartsQ[$UserBaseDirectory, root <> \"/\"]];"->
 "gate[\"local runtime recorded separately\",True];",
 "mapPath = FileNameJoin[{root, channel, \"s08_targets_result\", \"s08_result.wl\"}];"->
 "mapPath = FileNameJoin[{root, \"misc\", \"s08_result\", \"s08_result.wl\"}];",
 "mapperSources = {"->"mapperSources = {FileNameJoin[{root,\"misc\",\"s08_collect_Hgg_targets.wls\"}],"};
SetEnvironment["POLARIZED_SIDIS_CHANNEL"->"Hgg"];
ToExpression[localReductionChange[localReductionPrefix,localReductionEdits],InputForm];
localMapReceiptPath=FileNameJoin[{DirectoryName[mapPath],"s08_execution.json"}];localMapReceipt=Import[localMapReceiptPath,"RawJSON"];
gate["accepted complete local map receipt",TrueQ[localMapReceipt["passed"]]&&
 localMapReceipt["result_sha256"]["misc/s08_result/s08_result.wl"]===IntegerString[FileHash[mapPath,"SHA256"],16,64]&&
 map["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&map["ComponentStorage"]==="hash-pinned-raw-component-files-v1"];
localImportedVersions=map["ImportedNativeVersions"];reuseControl=False;readyOnly=False;
inputPaths={localReductionSource,localReductionConfigPath,mapPath,localMapReceiptPath,libraryPath,configPath,originalSource,
 mapperSource,previousMapperSource,reuseBase,readySource};
inputPaths=Join[inputPaths,(FileNameJoin[{root,library["Library"][#]["File"]}]&)/@{"s02","s04"}];
localReuseBlock=localReductionBlock[reuseSource,"\nreuseSetup[]","\nreuseText="];
localReuseBlock=localReductionChange[localReuseBlock,{
 "reuseProof[\"NativeVersions\"]==={$Version,FeynCalc`$FeynCalcVersion}"->"reuseProof[\"NativeVersions\"]===localImportedVersions"}];
ToExpression[localReuseBlock,InputForm];reuseSetup[];
localReadyBlock=localReductionBlock[readySource,"\nreadySetup[]","\nreadySuffix["];
localReadyBlock=localReductionChange[localReadyBlock,{
 "packet[\"NativeVersions\"]==={$Version,FeynCalc`$FeynCalcVersion}"->"packet[\"NativeVersions\"]===localImportedVersions"}];
ToExpression[localReadyBlock,InputForm];readySetup[];
localUncovered=Complement[targets,Keys[reuseRuleMap]];
localReductionOutput=FileNameJoin[{root,"misc","s09_result"}];
If[!DirectoryQ[localReductionOutput],CreateDirectory[localReductionOutput,CreateIntermediateDirectories->True]];
Print["LOCAL_REDUCTION_COVERAGE targets ",Length[targets]," uncovered ",Length[localUncovered]];
If[localUncovered=!={},Put[<|"Targets"->localUncovered,"MappingArtifactHash"->FileHash[mapPath,"SHA256"],
 "RuleLibraryHash"->FileHash[reusePath,"SHA256"],"SubsetReductionHash"->readySubsetHash,"Accepted"->False|>,
 FileNameJoin[{localReductionOutput,"s09_uncovered.wl"}]];Print["NEEDS_NATIVE_KIRA: uncovered local targets"];Quit[4]];
rules=Normal[KeyTake[reuseRuleMap,targets]];
masters=Sort[DeleteDuplicates[Cases[Last/@rules,_CutIntegral,Infinity]]];
gate["unique complete reused reduction keys",DuplicateFreeQ[First/@rules]&&Complement[targets,First/@rules]==={}];
gate["reused coefficients remain exact",FreeQ[rules,_Real|$Failed|$Aborted|_Missing]];
localFinalGates=localReductionBlock[reuseBase,"\ngate[\"unchanged complete original cut-master basis\"","\nresultDir ="];
ToExpression[localFinalGates,InputForm];
inputPaths=DeleteDuplicates[inputPaths];
inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths];
inputHash=Hash[{FileHash[localReductionSource,"SHA256"],inputHashes,$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
result=<|"Schema"->"polarized-sidis-real-reduction-extension-v1","Channel"->channel,
 "Rules"->rules,"Masters"->masters,"Targets"->targets,"AdditionalTargets"->map["MissingTargets"],
 "Bounds"-><||>,"Families"->families,"CutEnergyConditions"->geometry["CutEnergyConditions"],
 "SourceHash"->FileHash[reuseBase,"SHA256"],"DispatchSourceHash"->FileHash[localReductionSource,"SHA256"],
 "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "ImportedNativeVersions"->localImportedVersions,"ExecutionBackend"->"local",
 "GeometryHash"->FileHash[FileNameJoin[{root,library["Library"]["s02"]["File"]}],"SHA256"],
 "BaselineReductionHash"->FileHash[FileNameJoin[{root,library["Library"]["s04"]["File"]}],"SHA256"],
 "MappingArtifactHash"->FileHash[mapPath,"SHA256"],"CompatibleRuleLibraryHash"->FileHash[reusePath,"SHA256"],
 "CompatibleRuleReceiptHash"->FileHash[reuseReceiptPath,"SHA256"],"AcceptedSubsetReductionHash"->readySubsetHash,
 "AcceptedSubsetReceiptHash"->readySubsetReceiptHash,"AcceptedSubsetOverlapCount"->readyOverlapCount,
 "KiraRunPerformed"->False,"ReusedTargets"->targets,"WorkDirectory"->None,"RuleFiles"->{},
 "Checks"->checks,"Accepted"->True,"MasterEvaluationPerformed"->False,"FiniteNLOFHatsComputed"->False|>;
resultPath=FileNameJoin[{localReductionOutput,"s09_reduction.wl"}];
serialized="Uncompress["<>ToString[bounded[Compress[result],"local reduction compression"],InputForm]<>"]\n";
gate["bounded reduction output",StringLength[serialized]<128*1024^2];Export[resultPath<>".tmp",serialized,"Text"];
gate["exact native reduction reload",Get[resultPath<>".tmp"]===result];RenameFile[resultPath<>".tmp",resultPath,OverwriteTarget->True];
Export[FileNameJoin[{localReductionOutput,"s09_checks.json"}],<|"checks"->checks,"targets"->Length[targets],
 "masters"->Length[masters],"kira_run_performed"->False,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: local Hgg complete reused reduction"];Quit[0];

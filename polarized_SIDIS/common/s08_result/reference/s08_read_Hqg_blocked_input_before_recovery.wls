(* Display the exact saved input at the recorded blocked group; no mapping is run. *)
$HistoryLength=0;
blockedSource=FileNameJoin[{Directory[],"common","s08_read_Hqg_blocked_input.wls"}];
blockedBase=FileNameJoin[{Directory[],"common","s08_map_Hqg_grouped_packets.wls"}];
If[!SyntaxQ[Import[blockedSource,"Text"]]||IntegerString[FileHash[blockedBase,"SHA256"],16,64]=!=
 "0c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838",Quit[1]];
blockedText=Import[blockedBase,"Text"];
blockedBoundary=StringPosition[blockedText,"\ngroupPacketOriginalTask="];
If[Length[blockedBoundary]=!=1,Quit[1]];
blockedPrefix=StringTake[blockedText,First[First[blockedBoundary]]-1];
If[!SyntaxQ[blockedPrefix],Quit[1]];
ToExpression[blockedPrefix,InputForm];
blockedConfigPath=FileNameJoin[{root,"common","s08_Hqg_blocked_input.json"}];
blockedConfig=Import[blockedConfigPath,"RawJSON"];
gate["blocked-input contract",blockedConfig["channel"]===channel&&
 blockedConfig["schema"]==="polarized-sidis-blocked-input-v1"];
KeyValueMap[Function[{name,hash},gate["recorded failure identity "<>name,
 IntegerString[FileHash[FileNameJoin[{root,name}],"SHA256"],16,64]===hash]],blockedConfig["files"]];
blockedIndex=blockedConfig["component"];blockedGroup=blockedConfig["group"];
gate["recorded component exists",IntegerQ[blockedIndex]&&1<=blockedIndex<=Length[tasks]];
blockedTask=tasks[[blockedIndex]];
blockedExpression=blockedTask["Value"]/.coordinateRules;
blockedGroups=bounded[groupDenominators[blockedExpression],"recorded blocked input groups"];
blockedValues=KeyValueMap[#2/(Times@@MapThread[Power,{denominators,#1}])&,blockedGroups];
gate["recorded group exists",IntegerQ[blockedGroup]&&1<=blockedGroup<=Length[blockedValues]];
blockedValue=blockedValues[[blockedGroup]];
blockedResult=<|"Schema"->"polarized-sidis-blocked-input-v1","Channel"->channel,
 "Component"->blockedIndex,"Group"->blockedGroup,"Task"->KeyDrop[blockedTask,"Value"],
 "Value"->blockedValue,"GroupPowers"->Keys[blockedGroups][[blockedGroup]],
 "Denominators"->denominators,"CoordinateRules"->coordinateRules,"Families"->families,
 "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,
 "GroupBinding"->Hash[{groupInputHash,"component_"<>ToString[blockedIndex],blockedGroup,blockedValue},"SHA256"],
 "SourceHash"->FileHash[blockedSource,"SHA256"],"ConfigHash"->FileHash[blockedConfigPath,"SHA256"],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
blockedDirectory=FileNameJoin[{root,channel,"s08_blocked_input_result"}];
If[!DirectoryQ[blockedDirectory],CreateDirectory[blockedDirectory,CreateIntermediateDirectories->True]];
blockedPath=FileNameJoin[{blockedDirectory,"s08_result.wl"}];
blockedSerialized="Uncompress["<>ToString[Compress[blockedResult],InputForm]<>"]\n";
Export[blockedPath<>".tmp",blockedSerialized,"Text"];
gate["readable input file bound",FileByteCount[blockedPath<>".tmp"]<128*1024^2];
gate["exact saved blocked input",Get[blockedPath<>".tmp"]===blockedResult];
RenameFile[blockedPath<>".tmp",blockedPath,OverwriteTarget->True];
Put[blockedResult,FileNameJoin[{blockedDirectory,"s08_readable_input.wl"}]];
Export[FileNameJoin[{blockedDirectory,"s08_checks.json"}],<|"channel"->channel,"checks"->checks,
 "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["BLOCKED_INPUT_BYTES ",FileByteCount[blockedPath]];
Print["PASS: s08_read_Hqg_blocked_input"];Quit[0];

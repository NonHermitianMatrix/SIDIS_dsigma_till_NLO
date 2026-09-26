(* Preserve the accepted mapper; separate native loading from algebra allocation. *)
$HistoryLength=0;
hggReadAdapterPath=FileNameJoin[{Directory[],"common","s08_map_Hgg_bounded_reads.wls"}];
hggReadBasePath=FileNameJoin[{Directory[],"common","s08_map_Hgg_component_inputs.wls"}];
If[IntegerString[FileHash[hggReadBasePath,"SHA256"],16,64]=!=
 "f33a42480fefbc830a0b99bb0d9c957d490ee7dd1a7c278bd26aac221fabf7ce"||
 !SyntaxQ[Import[hggReadAdapterPath,"Text"]],Quit[1]];
hggReadText=StringTrim[Import[hggReadBasePath,"Text"]];
hggReadTerminal="ToExpression[hggRunText, InputForm];";
If[!StringEndsQ[hggReadText,hggReadTerminal],Quit[1]];
hggReadPrefix=StringDrop[hggReadText,-StringLength[hggReadTerminal]];
If[!SyntaxQ[hggReadPrefix],Quit[1]];ToExpression[hggReadPrefix,InputForm];

SetAttributes[hggMapRead,HoldFirst];
hggMapRead[expression_,purpose_] := MemoryConstrained[
 TimeConstrained[expression,1200,gate["Hgg native read time "<>ToString[purpose,InputForm],False]],
 16*1024^3,gate["Hgg native read memory "<>ToString[purpose,InputForm],False]];
hggReadOriginalDefinition=DownValues[hggTaskValue];
hggReadDefinition=hggReadOriginalDefinition/.bounded->hggMapRead;
If[Count[hggReadOriginalDefinition,_bounded,Infinity]=!=1||
 (hggReadDefinition/.hggMapRead->bounded)=!=hggReadOriginalDefinition,Quit[1]];
DownValues[hggTaskValue]=hggReadDefinition;
If[DownValues[hggTaskValue]=!=hggReadDefinition,Quit[1]];
hggRunText=hggReplace[hggRunText,
 "DistributeDefinitions[hggTaskValue, hggTaskMetadata",
 "DistributeDefinitions[hggMapRead, hggTaskValue, hggTaskMetadata"];
hggReadCall=If[hggMode==="targets",
 "bounded[mapExpression[task[\"Value\"] /. coordinateRules],\n    {\"complete raw cut mapping\", index}]",
 "bounded[mapExpression[task[\"Value\"] /. coordinateRules], {index, \"real mapping\"}]"];
hggReadReplacement="With[{hggLoadedValue=task[\"Value\"]}, "<>
 StringReplace[hggReadCall,"task[\"Value\"]"->"hggLoadedValue"]<>"]";
hggRunText=hggReplace[hggRunText,hggReadCall,hggReadReplacement];
hggRunText=hggReplace[hggRunText,hggOutputStart,
 hggOutputStart<>"\"ComponentInputReadSourceHash\"->FileHash[hggReadAdapterPath,\"SHA256\"], "];
Print["PASS: bounded native reads preserve mapping equations and input identities"];
ToExpression[hggRunText,InputForm];

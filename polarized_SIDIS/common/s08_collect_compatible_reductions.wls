(* Reuse native Kira rules only with identical geometry, cuts and master basis. *)
$HistoryLength=0;root=Directory[];checks=<||>;
source=FileNameJoin[{root,"common","s08_collect_compatible_reductions.wls"}];
gate[name_,test_]:=If[TrueQ[test],If[!KeyExistsQ[checks,name],Print["PASS: ",name]];
 AssociateTo[checks,name->True],Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[source,"Text"]]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,900,
 gate["time bound "<>ToString[label,InputForm],False]],2*1024^3,
 gate["memory bound "<>ToString[label,InputForm],False]];
zero[value_]:=Factor[Together[value]]===0;
paths={source};
read[relative_]:=(AppendTo[paths,FileNameJoin[{root,relative}]];
 If[StringEndsQ[relative,".json"],Import[Last[paths],"RawJSON"],Get[Last[paths]]]);
library=read["common/s06_result/s06_result.wl"];
gate["accepted common scalar library",library["Schema"]==="polarized-sidis-scalar-library-v1"&&And@@Values[library["Checks"]]];
readLibrary[stage_]:=Module[{row=library["Library"][stage],path},
 path=FileNameJoin[{root,row["File"]}];
 gate[stage<>" exact common scalar input",IntegerString[FileHash[path,"SHA256"],16,64]===row["SHA256"]];read[row["File"]]];
geometry=readLibrary["s02"];baseline=readLibrary["s04"];
gate["accepted baseline and physical cut support",TrueQ[geometry["Accepted"]]&&TrueQ[baseline["Accepted"]]&&
 baseline["CutEnergyConditions"]===geometry["CutEnergyConditions"]];
geometryHash=FileHash[FileNameJoin[{root,library["Library"]["s02"]["File"]}],"SHA256"];
baselineHash=FileHash[FileNameJoin[{root,library["Library"]["s04"]["File"]}],"SHA256"];
extensionSource=FileNameJoin[{root,"common","s08_extend_real_reduction.wls"}];AppendTo[paths,extensionSource];
ruleMap=Association[baseline["Rules"]];
gate["unique baseline rules",Length[ruleMap]===Length[baseline["Rules"]]];
owners=<||>;overlapCounts=<||>;acceptedResults=<||>;
Do[relative=owner<>"/s08_reduction_result/s08_reduction.wl";
 receipt=read[owner<>"/s08_reduction_result/s08_execution.json"];
 gate[owner<>" authentic accepted reduction",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_extend_real_reduction.wls"]===IntegerString[FileHash[extensionSource,"SHA256"],16,64]];
 native=read[relative];
 gate[owner<>" same complete scalar reduction contract",native["Schema"]==="polarized-sidis-real-reduction-extension-v1"&&
  native["Channel"]===owner&&TrueQ[native["Accepted"]]&&And@@Values[native["Checks"]]&&
  native["SourceHash"]===FileHash[extensionSource,"SHA256"]&&native["GeometryHash"]===geometryHash&&
  native["BaselineReductionHash"]===baselineHash&&Sort[native["Masters"]]===Sort[baseline["Masters"]]&&
  native["CutEnergyConditions"]===geometry["CutEnergyConditions"]];
 gate[owner<>" identical native family definitions",KeyTake[geometry["Families"],Keys[native["Families"]]]===native["Families"]];
 incoming=Association[native["Rules"]];
 gate[owner<>" complete unique rule inventory",Length[incoming]===Length[native["Rules"]]&&
  Complement[native["Targets"],Keys[incoming]]==={}&&
  Complement[Cases[Values[incoming],_CutIntegral,Infinity],baseline["Masters"]]==={}];
 common=Intersection[Keys[ruleMap],Keys[incoming]];
 gate[owner<>" exact overlapping reductions",And@@Table[
  ruleMap[key]===incoming[key]||bounded[zero[ruleMap[key]-incoming[key]],{owner,key}],{key,common}]];
 AssociateTo[overlapCounts,owner->Length[common]];
 AssociateTo[ruleMap,Normal[KeyDrop[incoming,Keys[ruleMap]]]];
 AssociateTo[owners,owner-><|"ResultHash"->FileHash[FileNameJoin[{root,relative}],"SHA256"],
  "ReceiptHash"->FileHash[FileNameJoin[{root,owner,"s08_reduction_result","s08_execution.json"}],"SHA256"],
  "KiraHash"->native["KiraHash"],"FermatHash"->native["FermatHash"]|>];
 AssociateTo[acceptedResults,owner->incoming],{owner,{"Hqg","Hgq"}}];
Do[gate[owner<>" entire accepted output reproduced",And@@KeyValueMap[
 (#2===ruleMap[#1]||bounded[zero[#2-ruleMap[#1]],{owner,"complete rule comparison",#1}])&,acceptedResults[owner]]],
 {owner,Keys[acceptedResults]}];
gate["combined rules end only in inherited masters",Complement[Cases[Values[ruleMap],_CutIntegral,Infinity],baseline["Masters"]]==={}];
gate["all inherited masters retained",Sort[DeleteDuplicates[Cases[Values[ruleMap],_CutIntegral,Infinity]]]===Sort[baseline["Masters"]]];
relative="Hgg/s08_direct_group_component_result/s08_result.wl";
ownReceipt=read["Hgg/s08_direct_group_component_result/s08_execution.json"];
gate["accepted complete own component13 map",TrueQ[ownReceipt["passed"]]&&
 ownReceipt["result_sha256"][relative]===IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]];
own=read[relative];
gate["actual own subset identity",own["Channel"]==="Hgg"&&own["SelectedComponentIndices"]==={13}&&
 TrueQ[own["MappingAccepted"]]&&And@@Values[own["Checks"]]];
missing=Complement[own["Targets"],Keys[ruleMap]];
Print["OWN_HGG13_REDUCTION_COVERAGE ",Length[own["Targets"]]-Length[missing],"/",Length[own["Targets"]],
 " missing ",InputForm[missing]];
paths=DeleteDuplicates[paths];
result=<|"Schema"->"polarized-sidis-compatible-cut-reductions-v1","Channel"->"Hgg",
 "Rules"->Normal[ruleMap],"Masters"->baseline["Masters"],"Families"->geometry["Families"],
 "CutEnergyConditions"->geometry["CutEnergyConditions"],"GeometryHash"->geometryHash,"BaselineReductionHash"->baselineHash,
 "SourceHash"->FileHash[source,"SHA256"],"OriginalExtensionSourceHash"->FileHash[extensionSource,"SHA256"],
 "InputHashes"->Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@paths],
 "Owners"->owners,"OverlapCounts"->overlapCounts,"OwnComparisonPassed"->True,
 "OwnSubsetMappingHash"->FileHash[FileNameJoin[{root,relative}],"SHA256"],
 "OwnSubsetTargetCount"->Length[own["Targets"]],"OwnSubsetMissingTargets"->missing,
 "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
directory=FileNameJoin[{root,"Hgg","s08_compatible_reductions_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory]];path=FileNameJoin[{directory,"s08_result.wl"}];
serialized="Uncompress["<>ToString[bounded[Compress[result],"compatible rule serialization"],InputForm]<>"]\n";
gate["bounded compatible rule export",StringLength[serialized]<128*1024^2];
Export[path<>".tmp",serialized,"Text"];
gate["exact compatible rule reload",bounded[Get[path<>".tmp"]===result,"compatible rule reload"]];
RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"rule_count"->Length[ruleMap],
 "overlap_counts"->overlapCounts,"own_subset_target_count"->Length[own["Targets"]],
 "own_subset_missing_count"->Length[missing],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_collect_compatible_reductions"];Quit[0];

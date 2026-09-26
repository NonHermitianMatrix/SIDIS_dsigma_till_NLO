(* Compare the actual saved own-control packet with its accepted producer. *)
$HistoryLength=0;
root=Directory[];checks=<||>;
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
bounded[value_]:=MemoryConstrained[TimeConstrained[value,300,$Failed],2*1024^3,$Failed];
SetAttributes[bounded,HoldFirst];
source="common/s08_check_Hqg_packet_record.wls";
gate["complete packet comparison syntax",SyntaxQ[Import[FileNameJoin[{root,source}],"Text"]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
candidateFile="cache/s08_target_packets/Hqg/27f8b96029e9c36e9db39a18a6a84384f97c1d28fe54f2a126f3176c0169b6fa/component_0004.wl";
priorFile="cache/s08_target_packets/Hqg/afe4c76b18177c9a5540c9a27dbbb7ffe161b7c5b9270793a8467c042881268c/component_0004.wl";
proofFile="Hqg/s08_grouped_comparison_result/s08_result.wl";
expected=<|candidateFile->"8bb2c14a675be8ba0ec476016f51c3a4b47896716f09c4a9dab1a88d7434c00a",
 priorFile->"e64e1c4ff836f7f9d9a1c0e3d071d97777697f85cb1cca749bd545da32243681",
 proofFile->"082a4e59961aca18189d6566ec27b47a717d32cf25ecc2edbb88a023a85b2c08",
 "common/s06_result/s06_result.wl"->"2408dec8ef08029c96a1d02993e73921ee969dfaba1abd5ca75ab06cda3afda1"|>;
KeyValueMap[gate["bound saved input "<>#1,IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,expected];
candidate=Get[FileNameJoin[{root,candidateFile}]];prior=Get[FileNameJoin[{root,priorFile}]];
proof=Get[FileNameJoin[{root,proofFile}]];
receipt=Import[FileNameJoin[{root,"Hqg/s08_grouped_comparison_result/s08_execution.json"}],"RawJSON"];
gate["accepted original grouped proof",TrueQ[receipt["passed"]]&&receipt["result_sha256"][proofFile]===expected[proofFile]&&
 TrueQ[proof["Accepted"]]&&TrueQ[proof["OwnAcceptedComparison"]]&&And@@Values[proof["Checks"]]&&
 proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
library=Get[FileNameJoin[{root,"common/s06_result/s06_result.wl"}]];row=library["Library"]["s04"];
gate["unchanged reference reduction",IntegerString[FileHash[FileNameJoin[{root,row["File"]}],"SHA256"],16,64]===row["SHA256"]];
reduction=Get[FileNameJoin[{root,row["File"]}]]/.{Q2->Q^2,w->s23};ruleKeys=First/@reduction["Rules"];
original=Join[KeyDrop[proof["Task"],"Value"],<|"Coefficients"->proof["Coefficients"],
 "MissingTargets"->Complement[Keys[proof["Coefficients"]],ruleKeys,reduction["Masters"]],
 "InputHash"->proof["TargetInputHash"],"ReconstructionPassed"->True,"Checks"->proof["Checks"],
 "Seconds"->proof["CandidateSeconds"],"InputBytes"->ByteCount[proof["Task"]["Value"]],
 "OutputBytes"->ByteCount[proof["Coefficients"]]|>];
gate["both actual packet reconstructions passed",And@@(AssociationQ[#]&&TrueQ[#["ReconstructionPassed"]]&&
 AssociationQ[#["Checks"]]&&Length[#["Checks"]]>0&&And@@Values[#["Checks"]]&/@{candidate,prior})];
fields=Union[Keys[candidate],Keys[original]];
different=Select[fields,Lookup[candidate,#,Missing["Absent"]]=!=Lookup[original,#,Missing["Absent"]]&];
Print["DIFFERING_RECORD_FIELDS ",InputForm[different]];
diagnostics={"Seconds","Checks","InputBytes","OutputBytes"};
metadataEqual=KeySort[KeyDrop[candidate,Append[diagnostics,"Coefficients"]]]===
 KeySort[KeyDrop[original,Append[diagnostics,"Coefficients"]]];
keysEqual=Sort[Keys[candidate["Coefficients"]]]===Sort[Keys[original["Coefficients"]]];
gate["same complete coefficient inventory",keysEqual];
keys=Keys[original["Coefficients"]];
changed=Select[keys,candidate["Coefficients"][#]=!=original["Coefficients"][#]&];
Print["STRUCTURALLY_DIFFERENT_COEFFICIENT_COUNT ",Length[changed]];
{seconds,residuals}=AbsoluteTiming[Association[Map[Function[key,key->bounded[
 Factor[Together[candidate["Coefficients"][key]-original["Coefficients"][key]]]]],changed]]];
same=AllTrue[Values[residuals],#===0&];
details=<|"CandidateDiagnostics"->KeyTake[candidate,DeleteCases[diagnostics,"Checks"]],
 "OriginalDiagnostics"->KeyTake[original,DeleteCases[diagnostics,"Checks"]],
 "ScientificMetadataEqual"->metadataEqual,"CoefficientInventoryEqual"->keysEqual,
 "CoefficientAssociationSameQ"->(candidate["Coefficients"]===original["Coefficients"]),
 "CoefficientKeysInSameOrder"->(Keys[candidate["Coefficients"]]===Keys[original["Coefficients"]]),
 "AllCoefficientsExactlyEqual"->same,"ChangedCoefficientCount"->Length[changed],
 "WholeRecordSameQWithoutTimingChecks"->(KeyDrop[candidate,{"Seconds","Checks"}]===KeyDrop[original,{"Seconds","Checks"}]),
 "PriorPacketSameQWithoutTimingChecks"->(KeyDrop[prior,{"Seconds","Checks"}]===KeyDrop[original,{"Seconds","Checks"}]),
 "DifferingFields"->different,"ComparisonSeconds"->seconds|>;
Print["ACTUAL_PACKET_COMPARISON ",InputForm[details]];
Print["SCIENTIFIC_METADATA_CANDIDATE ",InputForm[KeyDrop[candidate,Append[diagnostics,"Coefficients"]]]];
Print["SCIENTIFIC_METADATA_ORIGINAL ",InputForm[KeyDrop[original,Append[diagnostics,"Coefficients"]]]];
examples=Association[Map[Function[key,key-><|"Candidate"->candidate["Coefficients"][key],
 "Original"->original["Coefficients"][key],"ExactResidual"->residuals[key]|>],Take[changed,UpTo[3]]]];
directory=FileNameJoin[{root,"Hqg","s08_packet_record_result"}];If[!DirectoryQ[directory],CreateDirectory[directory]];
result=<|"Schema"->"polarized-sidis-Hqg-packet-record-comparison-v1","Details"->details,
 "ExactResiduals"->residuals,"Examples"->examples,"InputHashes"->expected,
 "SourceHash"->FileHash[FileNameJoin[{root,source}],"SHA256"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks|>;
serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
path=FileNameJoin[{directory,"s08_result.wl"}];Export[path<>".tmp",serialized,"Text"];
gate["exact comparison native round trip",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s08_equations.wl"}],ToString[InputForm[examples]]<>"\n","Text"];
gate["unchanged scientific metadata",metadataEqual];gate["all mapped coefficients exactly equal",same];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"details"->details|>,"RawJSON"];
Print["PASS: s08_check_Hqg_packet_record"];Quit[0];

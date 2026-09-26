(* Combine the own accepted trace ordering and early scalar-power reduction. *)
$HistoryLength=0;
earlyDispatchPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hqg_early_power.wls"}];
earlyBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_precontracted.wls"}];
If[IntegerString[FileHash[earlyBasePath,"SHA256"],16,64]=!="bc2466cae6df3ae392895efac2b74061b6da02e7b646bac5460fef478f3d5a02",Quit[1]];
earlyBaseText=Import[earlyBasePath,"Text"];earlyBoundary="\nToExpression[precontractRunTail,InputForm];";
If[StringCount[earlyBaseText,earlyBoundary]=!=1 || !SyntaxQ[Import[earlyDispatchPath,"Text"]],Quit[1]];
earlyPrefix=First[StringSplit[earlyBaseText,earlyBoundary]];
If[!SyntaxQ[earlyPrefix],Quit[1]];ToExpression[earlyPrefix,InputForm];
earlyProofRelative=channel<>"/s05_scalar_power_result/s05_result.wl";
earlyProofPath=FileNameJoin[{root,earlyProofRelative}];earlyProof=Get[earlyProofPath];
earlyReceipt=Import[FileNameJoin[{DirectoryName[earlyProofPath],"s05_execution.json"}],"RawJSON"];
gate["accepted own early-power scalar comparison",channel==="Hqg" && TrueQ[earlyReceipt["passed"]] &&
  earlyReceipt["result_sha256"][earlyProofRelative]===IntegerString[FileHash[earlyProofPath,"SHA256"],16,64] &&
  earlyProof["Schema"]==="polarized-sidis-own-scalar-power-comparison-v1" && earlyProof["Channel"]===channel &&
  earlyProof["InputHash"]===inputHash && earlyProof["InputHashes"]===inputHashes &&
  earlyProof["NativeVersions"]==={$Version,$FeynCalcVersion} &&
  earlyProof["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"] &&
  earlyProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_Hqg_scalar_power.wls"}],"SHA256"] &&
  earlyProof["OwnAngularProofHash"]===FileHash[zeroProofPath,"SHA256"] &&
  And@@Values[earlyProof["Checks"]] && TrueQ[earlyProof["Checks"]["complete own accepted scalar value reproduced"]]];
gate["unchanged native scalar reducer",DownValues[algebraicReduceOne]===earlyProof["OriginalDefinitions"]];
DownValues[earlyPowerReduce]=earlyProof["CandidateDefinitions"];
gate["exact own executed early-power algorithm installed",DownValues[earlyPowerReduce]===earlyProof["CandidateDefinitions"]];
earlyOriginalCheckpoint=DownValues[restoredScalarComponent];
gate["unchanged own zero-angular checkpoint before early powers",earlyOriginalCheckpoint===
  (zeroProof["GuardedCheckpointDefinitions"]/.zeroCheckpointedScalarComponent->restoredScalarComponent)];
gate["single nonzero scalar reduction boundary",Count[earlyOriginalCheckpoint,algebraicReduce,Infinity,Heads->True]===1];
earlyCandidateCheckpoint=earlyOriginalCheckpoint/.algebraicReduce->earlyPowerReduce;
gate["all other checkpoint operations retained",(earlyCandidateCheckpoint/.earlyPowerReduce->algebraicReduce)===earlyOriginalCheckpoint];
DownValues[restoredScalarComponent]=earlyCandidateCheckpoint;
gate["complete own early-power checkpoint installed",DownValues[restoredScalarComponent]===earlyCandidateCheckpoint];
earlyWorkerNeedle="precontractValue, precontractedTrace, precontractSavedRows, coefficientAlgorithmHash";
earlyMetadataNeedle="AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
earlyChanges={earlyWorkerNeedle->"precontractValue, precontractedTrace, precontractSavedRows, earlyPowerReduce, coefficientAlgorithmHash",
  earlyMetadataNeedle->(earlyMetadataNeedle<>"\nAssociateTo[result,{\"EarlyPowerProofHash\"->FileHash[earlyProofPath,\"SHA256\"],\"EarlyPowerDispatchHash\"->FileHash[earlyDispatchPath,\"SHA256\"]}];")};
gate["unique early-power production interfaces",And@@(StringCount[precontractRunTail,First[#]]===1&/@earlyChanges)];
earlyRunTail=StringReplace[precontractRunTail,earlyChanges];
gate["unchanged complete trace pair and tensor assembly",StringReplace[earlyRunTail,Reverse/@earlyChanges]===precontractRunTail && SyntaxQ[earlyRunTail]];
ToExpression[earlyRunTail,InputForm];

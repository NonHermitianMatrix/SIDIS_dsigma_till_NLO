(* Install the own executed early-power reduction only at the scalar checkpoint. *)
$HistoryLength=0;
earlyDispatchPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_early_power.wls"}];
earlyBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_zero_angular.wls"}];
If[IntegerString[FileHash[earlyBasePath,"SHA256"],16,64]=!="4934c38481b95443fb63f924e8ede4f57ebf27e81220c6c220afd06d58fa0c8d",Quit[1]];
earlyBaseText=Import[earlyBasePath,"Text"];
earlyBoundary="\nToExpression[ownZeroRunTail, InputForm];";
If[StringCount[earlyBaseText,earlyBoundary]=!=1 || !SyntaxQ[Import[earlyDispatchPath,"Text"]],Quit[1]];
earlyPrefix=First[StringSplit[earlyBaseText,earlyBoundary]];
If[!SyntaxQ[earlyPrefix],Quit[1]];ToExpression[earlyPrefix,InputForm];
earlyProofRelative=channel<>"/s05_scalar_power_result/s05_result.wl";
earlyProofPath=FileNameJoin[{root,earlyProofRelative}];
earlyProof=Get[earlyProofPath];
earlyReceipt=Import[FileNameJoin[{DirectoryName[earlyProofPath],"s05_execution.json"}],"RawJSON"];
gate["accepted own early-power scalar comparison",channel==="Hgg" && TrueQ[earlyReceipt["passed"]] &&
  earlyReceipt["result_sha256"][earlyProofRelative]===IntegerString[FileHash[earlyProofPath,"SHA256"],16,64] &&
  earlyProof["Schema"]==="polarized-sidis-scalar-power-comparison-v1" && earlyProof["Channel"]===channel &&
  earlyProof["InputHash"]===inputHash && earlyProof["InputHashes"]===inputHashes &&
  earlyProof["NativeVersions"]==={$Version,$FeynCalcVersion} &&
  earlyProof["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"] &&
  earlyProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_scalar_power_reduction.wls"}],"SHA256"] &&
  earlyProof["ParentHash"]===FileHash[ownZeroProofPath,"SHA256"] &&
  And@@Values[earlyProof["Checks"]] && TrueQ[earlyProof["Checks"]["complete original scalar value reproduced"]] &&
  TrueQ[earlyProof["Checks"]["own accepted projected coefficient reproduced"]]];
gate["unchanged native scalar reducer",DownValues[algebraicReduceOne]===earlyProof["OriginalDefinitions"]];
DownValues[earlyPowerReduce]=earlyProof["CandidateDefinitions"];
gate["exact executed early-power algorithm installed",DownValues[earlyPowerReduce]===earlyProof["CandidateDefinitions"]];
installOwnEarlyPower[] := Module[{original,candidate},
  original=DownValues[restoredScalarComponent];
  gate["unchanged own zero-angular checkpoint before early powers",original===
    (ownZeroProof["GuardedCheckpointDefinitions"]/.zeroCheckpointedScalarComponent->restoredScalarComponent)];
  gate["single nonzero scalar reduction boundary",Count[original,algebraicReduce,Infinity,Heads->True]===1];
  candidate=original/.algebraicReduce->earlyPowerReduce;
  gate["all other checkpoint operations retained",(candidate/.earlyPowerReduce->algebraicReduce)===original];
  DownValues[restoredScalarComponent]=candidate;
  gate["complete early-power checkpoint installed",DownValues[restoredScalarComponent]===candidate]];
earlyInstallNeedle="  installOwnZeroAngular[];";
earlyWorkerNeedle="compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, coefficientAlgorithmHash";
earlyMetadataNeedle="AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
earlyChanges={earlyInstallNeedle->(earlyInstallNeedle<>"\n  installOwnEarlyPower[];"),
  earlyWorkerNeedle->"compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, earlyPowerReduce, coefficientAlgorithmHash",
  earlyMetadataNeedle->(earlyMetadataNeedle<>"\nAssociateTo[result,{\"EarlyPowerProofHash\"->FileHash[earlyProofPath,\"SHA256\"],\"EarlyPowerDispatchHash\"->FileHash[earlyDispatchPath,\"SHA256\"]}];")};
gate["unique early-power production interfaces",And@@(StringCount[ownZeroRunTail,First[#]]===1&/@earlyChanges)];
earlyRunTail=StringReplace[ownZeroRunTail,earlyChanges];
gate["unchanged complete real assembly",StringReplace[earlyRunTail,Reverse/@earlyChanges]===ownZeroRunTail && SyntaxQ[earlyRunTail]];
ToExpression[earlyRunTail,InputForm];

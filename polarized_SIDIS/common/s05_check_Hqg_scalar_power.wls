(* Reuse the executed polynomial algorithm and an accepted own scalar coefficient. *)
$HistoryLength=0;
studyPath=FileNameJoin[{Directory[],"common","s05_check_Hqg_scalar_power.wls"}];
productionPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[productionPath,"SHA256"],16,64]=!="ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",Quit[1]];
productionText=Import[productionPath,"Text"];boundary="\nDo[\n  amplitudes =";
If[StringCount[productionText,boundary]=!=1 || !SyntaxQ[Import[studyPath,"Text"]],Quit[1]];
prefix=First[StringSplit[productionText,boundary]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
If[StringCount[prefix,"Get[\"FeynCalc`\"]"] =!= 1,Quit[1]];
prefix=StringReplace[prefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[prefix],Quit[1]];ToExpression[prefix,InputForm];
gate["own scalar power comparison channel",channel==="Hqg"];
parentRelative="Hgg/s05_scalar_power_result/s05_result.wl";
parentPath=FileNameJoin[{root,parentRelative}];parent=Get[parentPath];
parentReceipt=Import[FileNameJoin[{DirectoryName[parentPath],"s05_execution.json"}],"RawJSON"];
gate["accepted executed early-power algorithm",TrueQ[parentReceipt["passed"]] &&
  parentReceipt["result_sha256"][parentRelative]===IntegerString[FileHash[parentPath,"SHA256"],16,64] &&
  parent["Schema"]==="polarized-sidis-scalar-power-comparison-v1" && parent["Channel"]==="Hgg" &&
  parent["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_scalar_power_reduction.wls"}],"SHA256"] &&
  parent["ProductionSourceHash"]===FileHash[productionPath,"SHA256"] &&
  parent["NativeVersions"]==={$Version,$FeynCalcVersion} && And@@Values[parent["Checks"]] &&
  parent["OriginalDefinitions"]===DownValues[algebraicReduceOne]];
DownValues[earlyPowerReduce]=parent["CandidateDefinitions"];
gate["exact executed early-power definition",DownValues[earlyPowerReduce]===parent["CandidateDefinitions"]];
ownRelative=channel<>"/s05_zero_angular_result/s05_result.wl";ownPath=FileNameJoin[{root,ownRelative}];
own=Get[ownPath];ownReceipt=Import[FileNameJoin[{DirectoryName[ownPath],"s05_execution.json"}],"RawJSON"];
configPath=FileNameJoin[{root,"common","s05_zero_angular_inputs.json"}];studyConfig=Import[configPath,"RawJSON"];
gate["accepted own scalar equation inventory",TrueQ[ownReceipt["passed"]] &&
  ownReceipt["result_sha256"][ownRelative]===IntegerString[FileHash[ownPath,"SHA256"],16,64] &&
  own["Schema"]==="polarized-sidis-zero-angular-shortcut-validation-v1" && own["Channel"]===channel &&
  own["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_zero_angular.wls"}],"SHA256"] &&
  own["ConfigHash"]===FileHash[configPath,"SHA256"] && own["InputHash"]===inputHash && own["InputHashes"]===inputHashes &&
  own["NativeVersions"]==={$Version,$FeynCalcVersion} && And@@Values[own["Checks"]]];
row=SelectFirst[own["RecordedInputs"],!TrueQ[#["Shortcut"]]&,None];
gate["own nonzero recorded equation exists",AssociationQ[row]];
entry=SelectFirst[studyConfig["recorded_inputs"],#["sha256"]===IntegerString[row["RecordHash"],16,64]&,None];
gate["own recorded file identified",AssociationQ[entry]];
recordPath=FileNameJoin[{root,entry["retained"]}];
gate["exact retained equation file",FileHash[recordPath,"SHA256"]===row["RecordHash"]];record=Get[recordPath];
gate["recorded equation native and physical identities",record["Schema"]==="polarized-sidis-pending-scalar-input-v1" &&
  record["Channel"]===channel && record["InputHash"]===inputHash && record["NativeVersions"]==={$Version,$FeynCalcVersion} &&
  record["CoefficientAlgorithmHash"]===coefficientAlgorithmHash && record["TransverseConstraint"]===transverseConstraint &&
  record["ArgumentHash"]===row["ArgumentHash"] && Hash[{inputHash,coefficientAlgorithmHash,record["ScalarInput"]},"SHA256"]===row["ArgumentHash"]];
acceptedPath=FileNameJoin[{coefficientDirectory,IntegerString[record["ArgumentHash"],16,64]<>".wl"}];
gate["own completed original coefficient exists",FileExistsQ[acceptedPath]];accepted=Get[acceptedPath];
gate["own completed original coefficient exact input",accepted["InputHash"]===inputHash &&
  accepted["ArgumentHash"]===record["ArgumentHash"] && KeyExistsQ[accepted,"Value"]];
ClearSystemCache[];
{candidateSeconds,candidateValue}=AbsoluteTiming[bounded[earlyPowerReduce[record["ScalarInput"]],"own recorded scalar early powers"]];
gate["complete own accepted scalar value reproduced",bounded[zero[candidateValue-accepted["Value"]],"own complete scalar comparison"]];
gate["original scalar and angular equations retained",own["OriginalReductionDefinitions"]===
  {DownValues[algebraicReduce],DownValues[algebraicReduceOne],DownValues[angularAverage],DownValues[angularAverageOne]}];
result=<|"Schema"->"polarized-sidis-own-scalar-power-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[studyPath,"SHA256"],"ProductionSourceHash"->FileHash[productionPath,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,$FeynCalcVersion},
  "ParentHash"->FileHash[parentPath,"SHA256"],"OwnAngularProofHash"->FileHash[ownPath,"SHA256"],
  "RecordFile"->entry["retained"],"RecordHash"->FileHash[recordPath,"SHA256"],"Record"->record,
  "AcceptedCoefficientFile"->acceptedPath,"AcceptedCoefficientHash"->FileHash[acceptedPath,"SHA256"],
  "AcceptedValue"->accepted["Value"],"CandidateValue"->candidateValue,"CandidateSeconds"->candidateSeconds,
  "OriginalDefinitions"->DownValues[algebraicReduceOne],"CandidateDefinitions"->DownValues[earlyPowerReduce],
  "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
directory=FileNameJoin[{root,channel,"s05_scalar_power_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
path=FileNameJoin[{directory,"s05_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded own scalar comparison output",StringLength[serialized]<128*1024^2];
Export[path<>".tmp",serialized,"Text"];gate["exact own scalar comparison reload",Get[path<>".tmp"]===result];
RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s05_checks.json"}],<|"checks"->checks,"candidate_seconds"->candidateSeconds,
  "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["OWN_SCALAR_POWER_COMPARISON seconds ",candidateSeconds];
Print["PASS: s05_check_Hqg_scalar_power"];Quit[0];

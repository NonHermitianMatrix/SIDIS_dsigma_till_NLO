(* Compare response-only loading against an entire accepted native projection. *)
$HistoryLength = 0;
root = Directory[]; checks = <||>;
source = FileNameJoin[{root,"common","s08_check_Hgg_response_read.wls"}];
gate[name_,test_] := If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],
  Print["FAIL: ",name];Quit[1]];
SetAttributes[readBound,HoldFirst];
readBound[value_] := MemoryConstrained[TimeConstrained[value,1200,
  gate["native read time bound",False]],16*1024^3,gate["native read memory bound",False]];
gate["compute allocation",StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName,"login"] &&
  StringStartsQ[$UserBaseDirectory,root<>"/"]];
gate["complete source syntax",SyntaxQ[Import[source,"Text"]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];

responseOnlyRead[path_,identity_] := Module[{text,old,new,candidate,location,literal,value},
  gate["response input native identity",FileExistsQ[path] && FileHash[path,"SHA256"]===identity];
  text=Import[path,"Text"];
  old="cdr=readPiece[Length[groups]];";
  If[StringCount[text,old]===0,Return[Get[path]]];
  gate["unique unused native CDR assignment",StringCount[text,old]===1];
  new="cdr=Missing[\"CDRNotRequestedByResponseConsumer\"];";
  gate["new response-reader marker absent",StringCount[text,new]===0];
  candidate=StringReplace[text,old->new];
  gate["all original response and payload checks retained",SyntaxQ[candidate] &&
    StringReplace[candidate,new->old]===text];
  location="DirectoryName[$InputFileName]";literal=ToString[DirectoryName[path],InputForm];
  gate["unique native payload directory binding",StringCount[candidate,location]===1 &&
    StringCount[candidate,literal]===0];
  candidate=StringReplace[candidate,location->literal];
  gate["only payload directory and unused field differ",SyntaxQ[candidate] &&
    StringReplace[candidate,{literal->location,new->old}]===text];
  value=ToExpression[candidate,InputForm];
  gate["same accepted piecewise projection writer",AssociationQ[value] &&
    value["Schema"]==="polarized-sidis-complete-photon-spin-component-v1" &&
    value["Channel"]==="Hgg" && KeyExistsQ[value,"Response"] &&
    value["StorageDispatchHash"]===FileHash[FileNameJoin[{Directory[],"common",
      "s05_project_Hgg_piecewise_storage.wls"}],"SHA256"] &&
    MissingQ[value["CDRPhotonCoefficient"]] && And@@Values[value["Checks"]]];
  value];

relative="Hgg/s05_projected_components_result/Photon_4/s05_result.wl";
path=FileNameJoin[{root,relative}];
receiptPath=FileNameJoin[{DirectoryName[path],"s05_execution.json"}];
receipt=Import[receiptPath,"RawJSON"];identity=FileHash[path,"SHA256"];
gate["own complete projection accepted",TrueQ[receipt["passed"]] &&
  receipt["result_sha256"][relative]===IntegerString[identity,16,64]];
manifestPath=FileNameJoin[{DirectoryName[path],"s05_payload_manifest.json"}];
manifest=Import[manifestPath,"RawJSON"];
gate["own exact native payload round trip",TrueQ[manifest["exact_round_trip"]] &&
  manifest["result_sha256"]===IntegerString[identity,16,64]];
Print["RESPONSE_READ_ORIGINAL ",relative];
{originalSeconds,original}=AbsoluteTiming[readBound[KeyDrop[Get[path],"CDRPhotonCoefficient"]]];
gate["original complete native conventions",AssociationQ[original] &&
  original["NativeVersions"]==={$Version,$FeynCalcVersion} && And@@Values[original["Checks"]]];
originalBytes=ByteCount[original];ClearSystemCache[];
Print["RESPONSE_READ_CANDIDATE ",relative];
{candidateSeconds,candidate}=AbsoluteTiming[readBound[KeyDrop[responseOnlyRead[path,identity],"CDRPhotonCoefficient"]]];
gate["entire own response and every retained field reproduced",candidate===original];
gate["unchanged original native file",FileHash[path,"SHA256"]===identity];
result=<|"Schema"->"polarized-sidis-response-only-native-read-v1","Channel"->"Hgg",
  "SourceHash"->FileHash[source,"SHA256"],"OwnFile"->relative,"OwnHash"->identity,
  "OwnReceiptHash"->FileHash[receiptPath,"SHA256"],"OwnManifestHash"->FileHash[manifestPath,"SHA256"],
  "StorageSourceHash"->FileHash[FileNameJoin[{root,"common","s05_project_Hgg_piecewise_storage.wls"}],"SHA256"],
  "NativeVersions"->{$Version,$FeynCalcVersion},"ReaderDefinitions"->DownValues[responseOnlyRead],
  "OwnAcceptedComparison"->True,"ResponseHash"->Hash[original["Response"],"SHA256"],
  "RetainedFieldsHash"->Hash[original,"SHA256"],"OriginalReadSeconds"->originalSeconds,
  "CandidateReadSeconds"->candidateSeconds,"RetainedBytes"->originalBytes,
  "PeakKernelMemoryBytes"->MaxMemoryUsed[],"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
Clear[original,candidate];ClearSystemCache[];
directory=FileNameJoin[{root,"Hgg","s08_response_read_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
resultPath=FileNameJoin[{directory,"s08_result.wl"}];Put[result,resultPath<>".tmp"];
gate["exact native comparison reload",Get[resultPath<>".tmp"]===result];
RenameFile[resultPath<>".tmp",resultPath,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,
  "original_seconds"->originalSeconds,"candidate_seconds"->candidateSeconds,
  "retained_bytes"->originalBytes,"peak_kernel_memory_bytes"->MaxMemoryUsed[],
  "job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_response_read"];Quit[0];

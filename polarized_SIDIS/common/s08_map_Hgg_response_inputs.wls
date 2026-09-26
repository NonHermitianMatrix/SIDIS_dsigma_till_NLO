(* Reuse an accepted complete-response read comparison in the existing mapper. *)
$HistoryLength=0;
hggResponseAdapterPath=FileNameJoin[{Directory[],"common","s08_map_Hgg_response_inputs.wls"}];
hggResponseMode=Environment["POLARIZED_SIDIS_COMPONENT_STAGE"];
If[!MemberQ[{"targets","coefficients"},hggResponseMode] ||
  !SyntaxQ[Import[hggResponseAdapterPath,"Text"]],Quit[1]];
hggResponseBasePath=FileNameJoin[{Directory[],"common",If[hggResponseMode==="targets",
  "s08_map_Hgg_grouped_inputs.wls","s08_map_Hgg_bounded_reads.wls"]}];
If[IntegerString[FileHash[hggResponseBasePath,"SHA256"],16,64]=!=If[hggResponseMode==="targets",
  "08db7db98fe1d07b12742428ea2ea2ea544b86fee60668f529e643ef79753de8",
  "97360f5dc30672b79e763c3623c8761600bcbf58fb214825ee9eefd6f572d7e0"],Quit[1]];

hggResponseNativeGet[path_] := responseOnlyRead[path,FileHash[path,"SHA256"]];
hggResponseInstall[] := Module[{relative,proofPath,receiptPath,receipt,proof,original,candidate},
  relative="Hgg/s08_response_read_result/s08_result.wl";
  proofPath=FileNameJoin[{root,relative}];
  receiptPath=FileNameJoin[{DirectoryName[proofPath],"s08_execution.json"}];
  receipt=Import[receiptPath,"RawJSON"];
  gate["accepted complete response-read comparison",TrueQ[receipt["passed"]] &&
    receipt["result_sha256"][relative]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
  proof=Get[proofPath];
  gate["unchanged own response comparison inputs",proof["Schema"]==="polarized-sidis-response-only-native-read-v1" &&
    proof["Channel"]===channel && TrueQ[proof["OwnAcceptedComparison"]] && And@@Values[proof["Checks"]] &&
    proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion} &&
    proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_check_Hgg_response_read.wls"}],"SHA256"] &&
    proof["OwnHash"]===FileHash[FileNameJoin[{root,proof["OwnFile"]}],"SHA256"] &&
    proof["OwnReceiptHash"]===FileHash[FileNameJoin[{root,DirectoryName[proof["OwnFile"]],"s05_execution.json"}],"SHA256"] &&
    proof["OwnManifestHash"]===FileHash[FileNameJoin[{root,DirectoryName[proof["OwnFile"]],"s05_payload_manifest.json"}],"SHA256"] &&
    proof["StorageSourceHash"]===FileHash[FileNameJoin[{root,"common","s05_project_Hgg_piecewise_storage.wls"}],"SHA256"]];
  DownValues[responseOnlyRead]=proof["ReaderDefinitions"];
  gate["exact accepted response reader installed",DownValues[responseOnlyRead]===proof["ReaderDefinitions"]];
  original=DownValues[hggTaskValue];candidate=original/.Get->hggResponseNativeGet;
  gate["only the native task read changes",Count[original,_Get,Infinity]===1 &&
    (candidate/.hggResponseNativeGet->Get)===original];
  DownValues[hggTaskValue]=candidate;
  gate["entire task and inventory contract retained",DownValues[hggTaskValue]===candidate];
  hggResponseEvidence=<|"SourceHash"->FileHash[hggResponseAdapterPath,"SHA256"],
    "ComparisonHash"->FileHash[proofPath,"SHA256"],"ReceiptHash"->FileHash[receiptPath,"SHA256"],
    "OwnAcceptedComparison"->True,"OriginalReadSeconds"->proof["OriginalReadSeconds"],
    "CandidateReadSeconds"->proof["CandidateReadSeconds"]|>;
  Print["S08_RESPONSE_READ_COMPARISON ",InputForm[hggResponseEvidence]]];
hggResponseConfigure[] := (
  hggRunText=hggReplace[hggRunText,"DistributeDefinitions[hggMapRead, hggTaskValue",
    "DistributeDefinitions[responseOnlyRead, hggResponseNativeGet, hggMapRead, hggTaskValue"];
  hggRunText=hggReplace[hggRunText,hggOutputStart,
    hggOutputStart<>"\"ComponentResponseReadComparison\"->hggResponseEvidence, "]);

hggResponseText=Import[hggResponseBasePath,"Text"];
hggResponseOld=If[hggResponseMode==="targets",
  "If[!SyntaxQ[hggGroupedPrefix],Quit[1]];ToExpression[hggGroupedPrefix,InputForm];",
  "ToExpression[hggRunText,InputForm];"];
hggResponseNew=If[hggResponseMode==="targets",
  hggResponseOld<>"\nhggResponseInstall[];hggResponseConfigure[];",
  "hggResponseConfigure[];\nhggRunText=hggReplace[hggRunText,\"hggInitializeTasks[];\",\"hggInitializeTasks[];hggResponseInstall[];\"];\n"<>hggResponseOld];
If[StringCount[hggResponseText,hggResponseOld]=!=1,Print["FAIL: unique response reader handoff"];Quit[1]];
hggResponseRun=StringReplace[hggResponseText,hggResponseOld->hggResponseNew];
If[!SyntaxQ[hggResponseRun] || StringReplace[hggResponseRun,hggResponseNew->hggResponseOld]=!=hggResponseText,
  Print["FAIL: unchanged full mapping implementation"];Quit[1]];
ToExpression[hggResponseRun,InputForm];

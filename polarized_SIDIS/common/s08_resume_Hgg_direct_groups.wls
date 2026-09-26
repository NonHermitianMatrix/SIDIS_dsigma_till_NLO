(* Resume unchanged direct mapping with its already executed own validation. *)
$HistoryLength=0;
directResumeSource=FileNameJoin[{Directory[],"common","s08_resume_Hgg_direct_groups.wls"}];
directResumeBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_direct_groups.wls"}];
If[IntegerString[FileHash[directResumeBase,"SHA256"],16,64]=!=
 "31d514025ffc2f38c42b26aa30c42920243414341d1ff94316faf2d757a19c97"||
 !SyntaxQ[Import[directResumeSource,"Text"]],Quit[1]];
directResumeRestore[target_]:=Module[{directory,receiptPath,proofPath,receipt,proof,relative,evidence},
 directory=FileNameJoin[{root,"Hgg","s08_direct_group_control_result","reference","resume_14882067"}];
 receiptPath=FileNameJoin[{directory,"s08_execution.json"}];proofPath=FileNameJoin[{directory,"s08_result.wl"}];
 gate["immutable executed resume inputs",
  IntegerString[FileHash[receiptPath,"SHA256"],16,64]==="1cf31fd6801102c596ee3c9d42305b4bd8f61815eff17e2b72840b792b780f69"&&
  IntegerString[FileHash[proofPath,"SHA256"],16,64]==="176069d91e6e2feed20cc9cfa1d17312df1caa80358f6406beab5adeec2e86b8"];
 receipt=Import[receiptPath,"RawJSON"];relative="Hgg/s08_direct_group_control_result/s08_result.wl";
 gate["same mapper completed own validation before wall limit",receipt["job_id"]==="14882067"&&
  receipt["passed"]===False&&receipt["reason"]==="wall_limit"&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[proofPath,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_map_Hgg_direct_groups.wls"]===
   IntegerString[FileHash[directResumeBase,"SHA256"],16,64]];
 proof=Get[proofPath];
 gate["complete own saved direct-map comparison",proof["Schema"]==="polarized-sidis-Hgg-grouped-comparison-v1"&&
  proof["Channel"]===channel&&channel==="Hgg"&&TrueQ[coordinateSubset]&&
  proof["InputHash"]===groupInputHash&&proof["TargetInputHash"]===targetInputHash&&
  proof["InputHashes"]===inputHashes&&proof["ComponentIndex"]===hggOwnIndex&&
  proof["ExpressionHash"]===Hash[hggOwnExpression,"SHA256"]&&proof["Denominators"]===denominators&&
  proof["SourceHash"]===FileHash[hggGroupedSource,"SHA256"]&&
  proof["AlgorithmProofHash"]===FileHash[hggAlgorithmPath,"SHA256"]&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[proof["OwnAcceptedComparison"]]&&Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
  TrueQ[proof["Checks"]["direct accepted compact grouping installed"]]&&
  TrueQ[proof["Checks"]["entire original own Hgg map reproduced"]]];
 gate["own comparison output owner unchanged",target===FileNameJoin[{root,relative}]];
 If[FileExistsQ[target],gate["existing own validation is identical",FileHash[target,"SHA256"]===FileHash[proofPath,"SHA256"]],
  CopyFile[proofPath,target]];
 gate["exact saved own validation restored",Get[target]===proof];
 evidence=<|"SourceHash"->FileHash[directResumeSource,"SHA256"],"ReceiptHash"->FileHash[receiptPath,"SHA256"],
  "ComparisonHash"->FileHash[proofPath,"SHA256"],"OriginalGroupedSeconds"->proof["GroupedSeconds"],
  "AllSourceInputNativeBindingsChecked"->True|>;
 AssociateTo[hggPolynomialEvidence,"OwnComparisonReuse"->evidence];
 Print["HGG_DIRECT_COMPARISON_REUSED ",InputForm[evidence]]];
directResumeText=StringTrim[Import[directResumeBase,"Text"]];
directResumeEntry="ToExpression[coordinateRun,InputForm];";
If[!StringEndsQ[directResumeText,directResumeEntry],Quit[1]];
directResumePrefix=StringDrop[directResumeText,-StringLength[directResumeEntry]];
If[!SyntaxQ[directResumePrefix],Quit[1]];ToExpression[directResumePrefix,InputForm];
directResumeRead="hggOwnProof=If[FileExistsQ[hggOwnResultPath],Get[hggOwnResultPath],<||>];";
directResumeEdits={
 directResumeRead->("directResumeRestore[hggOwnResultPath];"<>directResumeRead),
 "If[coordinateSubset||Lookup[hggOwnProof,\"InputHash\",None]"->"If[Lookup[hggOwnProof,\"InputHash\",None]"};
If[!And@@(StringCount[coordinateRun,First[#]]===1&/@directResumeEdits),Quit[1]];
directResumeRun=StringReplace[coordinateRun,directResumeEdits];
If[!SyntaxQ[directResumeRun]||StringReplace[directResumeRun,Reverse/@directResumeEdits]=!=coordinateRun,Quit[1]];
ToExpression[directResumeRun,InputForm];

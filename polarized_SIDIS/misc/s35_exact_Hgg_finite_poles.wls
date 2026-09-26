(* Exact rational/algebraic summation with the already accepted native transfer. *)
localFiniteSumRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localFiniteSumSource=ExpandFileName[$InputFileName];
Get[FileNameJoin[{localFiniteSumRoot,"misc","s31_exact_Hgg_recoil_sum.wls"}]];
localFiniteExactSum[value_]:=Module[{answer},
 If[NumberQ[value],Return[value]];
 answer=Block[{localRecoilTerms,localRecoilSource=localFiniteSumSource},
  localRecoilTerms[input_]:=Module[{terms=If[Head[input]===Plus,List@@input,{input}]},
   gate["entire finite sum exactly decomposed",Total[terms]===input];terms];
  localExactRecoilRatio[value]];
 answer];

If[Environment["POLARIZED_SIDIS_VALIDATE_FINITE_SUM"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=localFiniteSumRoot;SetDirectory[root];source=localFiniteSumSource;checks=<||>;
 gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];
 bounded[v_,label_]:=MemoryConstrained[TimeConstrained[v,300,gate[ToString[label]<>" time",False]],
  2*1024^3,gate[ToString[label]<>" memory",False]];
 configPath=FileNameJoin[{root,"misc","s35_inputs.json"}];config=Import[configPath,"RawJSON"];
 checkpointPath=FileNameJoin[{root,config["failed_checkpoint"]}];
 gate["exact failed checkpoint identity",IntegerString[FileHash[checkpointPath,"SHA256"],16,64]===config["failed_checkpoint_sha256"]];
 gate["actual failing execution retained",IntegerString[FileHash[FileNameJoin[{root,"misc","s14_result","s14_execution.json"}],"SHA256"],16,64]===config["failed_receipt_sha256"]];
 checkpoint=Get[checkpointPath];
 gate["actual unsimplified failed pole input",AssociationQ[checkpoint["PoleResiduals"]]&&!TrueQ[checkpoint["Accepted"]]&&
  KeyExistsQ[checkpoint,"InputParts"]];
 proofPath=FileNameJoin[{root,"misc","s31_result","s31_result.wl"}];
 receipt=Import[FileNameJoin[{root,"misc","s31_result","s31_execution.json"}],"RawJSON"];
 gate["accepted exact sum implementation",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"]["misc/s31_result/s31_result.wl"]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
 proof=Get[proofPath];capturePath=FileNameJoin[{root,"misc","s30_result","s30_result.wl"}];
 gate["own native scalar reference and helper source",proof["CaptureHash"]===FileHash[capturePath,"SHA256"]&&
  proof["SourceHash"]===FileHash[FileNameJoin[{root,"misc","s31_exact_Hgg_recoil_sum.wls"}],"SHA256"]&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[proof["Checks"]]];
 capture=Get[capturePath];controlTerms=localRecoilTerms[capture["Own"]["Rational"]];
 controlInput=Total[controlTerms];controlExpected=proof["OwnRatio"];
 gate["nonzero own accepted control retained",controlExpected=!=0];
 {controlSeconds,controlValue}=AbsoluteTiming[localFiniteExactSum[controlInput]];
 gate["complete own accepted scalar reconstructed",bounded[Factor[Together[controlValue-controlExpected]],"own finite-sum comparison"]===0];
 Print["OWN_EXACT_SUM seconds ",controlSeconds," input_bytes ",ByteCount[controlInput]," output_bytes ",ByteCount[controlValue]];
 {actualSeconds,actualValues}=AbsoluteTiming[Map[localFiniteExactSum,checkpoint["PoleResiduals"]]];
 Print["ACTUAL_EXACT_POLES seconds ",actualSeconds," input_bytes ",ByteCount[checkpoint["PoleResiduals"]],
  " output_bytes ",ByteCount[actualValues]];
 If[ByteCount[actualValues]<65536,Print["ACTUAL_REDUCED_POLE_EQUATIONS ",InputForm[actualValues]]];
 result=<|"Schema"->"polarized-sidis-exact-finite-pole-comparison-v1","SourceHash"->FileHash[source,"SHA256"],
  "ConfigHash"->FileHash[configPath,"SHA256"],"CheckpointHash"->FileHash[checkpointPath,"SHA256"],
  "CheckpointLabel"->checkpoint["Label"],"OriginalInputHash"->checkpoint["InputHash"],
  "ReferenceHash"->FileHash[proofPath,"SHA256"],"OwnInput"->controlInput,"OwnValue"->controlValue,
  "OwnSeconds"->controlSeconds,"ActualValues"->actualValues,"ActualSeconds"->actualSeconds,
  "PoleCancellationResolved"->AllTrue[Values[actualValues],#===0&],"Checks"->checks,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>;
 out=FileNameJoin[{root,"misc","s35_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded exact pole result",StringLength[serialized]<128*1024^2];
 resultPath=FileNameJoin[{out,"s35_result.wl"}];Export[resultPath,serialized,"Text"];
 gate["exact pole result reload",Get[resultPath]===result];
 gate["saved residual is identically zero",TrueQ[result["PoleCancellationResolved"]]];
 Export[FileNameJoin[{out,"s35_checks.json"}],<|"checks"->checks,"own_seconds"->controlSeconds,
  "actual_seconds"->actualSeconds,"pole_cancellation_resolved"->result["PoleCancellationResolved"]|>,"RawJSON"];
 Print["PASS: exact Hgg finite pole sum validated"];Quit[0]];

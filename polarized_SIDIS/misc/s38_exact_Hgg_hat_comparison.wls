
(* Exact reference comparison without expanding kinematic numerator polynomials. *)
localHatSumRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localHatSumSource=ExpandFileName[$InputFileName];
Get[FileNameJoin[{localHatSumRoot,"misc","s31_exact_Hgg_recoil_sum.wls"}]];

localHatGroupedBackendReady=False;
localHatInstallBackend[]:=Module[{backendPath,receiptPath,receipt,proofPath,definitions,candidate},
 If[TrueQ[localHatGroupedBackendReady],Return[True]];
 backendPath=FileNameJoin[{localHatSumRoot,"misc","s39_grouped_hat_polynomials.py"}];
 receiptPath=FileNameJoin[{localHatSumRoot,"misc","s39_result","s39_execution.json"}];
 proofPath=FileNameJoin[{localHatSumRoot,"misc","s39_result","s39_result.json"}];
 receipt=Import[receiptPath,"RawJSON"];
 gate["accepted grouped actual polynomial backend",TrueQ[receipt["passed"]]&&
  receipt["source_sha256"]===IntegerString[FileHash[backendPath,"SHA256"],16,64]&&
  receipt["result_sha256"]["misc/s39_result/s39_result.json"]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
 definitions=DownValues[localExactRecoilRatio];
 gate["unique accepted native backend path",Count[definitions,"s31_sum_recoil_polynomials.py",Infinity]===1];
 candidate=definitions/."s31_sum_recoil_polynomials.py"->"s39_grouped_hat_polynomials.py";
 gate["entire native polynomial transfer retained",
  (candidate/."s39_grouped_hat_polynomials.py"->"s31_sum_recoil_polynomials.py")===definitions];
 DownValues[localExactRecoilRatio]=candidate;localHatGroupedBackendReady=True;True];

localHatRationalTerms[input_]:=Module[
 {denominators,denSymbols,denRules,reverseDen,tagged,pattern,coefficients={},coefficientSymbols={},
  index=<||>,cut,skeleton,expanded,terms,key,position,value,restore},
 denominators=DeleteDuplicates[Cases[input,p:Power[base_,n_Integer]/;n<0&&!NumberQ[base]:>p,Infinity]];
 If[denominators==={},Return[{input}]];
 denSymbols=Table[Symbol["Global`hatDenAtom"<>ToString[i]],{i,Length[denominators]}];
 gate["unassigned denominator generators",AllTrue[denSymbols,OwnValues[#]==={}&]];
 denRules=Thread[denominators->denSymbols];reverseDen=Reverse/@denRules;
 tagged=input/.denRules;
 gate["exact denominator-generator restoration",(tagged/.reverseDen)===input];
 pattern=Alternatives@@denSymbols;
 cut[x_]:=If[FreeQ[x,pattern],
   If[NumberQ[x],Return[x]];
   key=Hash[x,"SHA256"];
   If[KeyExistsQ[index,key],position=index[key];gate["exact repeated opaque coefficient",coefficients[[position]]===x],
    AppendTo[coefficients,x];position=Length[coefficients];AssociateTo[index,key->position];
    AppendTo[coefficientSymbols,Symbol["Global`hatCoefficientAtom"<>ToString[position]]]];
   coefficientSymbols[[position]],
   If[AtomQ[x],x,Map[cut,x]]];
 skeleton=cut[tagged];Clear[cut];
 gate["unassigned opaque polynomial generators",AllTrue[coefficientSymbols,OwnValues[#]==={}&]];
 restore=Thread[coefficientSymbols->coefficients];
 gate["exact full opaque-coefficient restoration",(skeleton/.restore)===tagged];
 expanded=Expand[skeleton];
 gate["exact native distributive reconstruction",Expand[expanded-skeleton]===0];
 terms=If[Head[expanded]===Plus,List@@expanded,{expanded}];
 terms=(terms/.restore)/.reverseDen;
 Print["FACTORED_REFERENCE_TERMS count ",Length[terms]," input_bytes ",ByteCount[input],
  " skeleton_bytes ",ByteCount[skeleton]," terms_bytes ",ByteCount[terms]];
 terms];

localHatExactSum[input_]:=Module[{atoms,symbols,rules,reverse,generic,answer},
 localHatInstallBackend[];
 If[NumberQ[input],Return[input]];
 atoms=DeleteDuplicates[Join[
  Cases[input,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im|_Abs,Infinity],
  Cases[input,p_Power/;!IntegerQ[p[[2]]],Infinity],Cases[input,_Complex,Infinity]]];
 symbols=Table[Symbol["Global`hatFunctionAtom"<>ToString[i]],{i,Length[atoms]}];
 gate["unassigned exact functional generators",AllTrue[symbols,OwnValues[#]==={}&]];
 rules=Thread[atoms->symbols];reverse=Reverse/@rules;generic=input/.rules;
 gate["exact full functional-atom restoration",(generic/.reverse)===input];
 answer=Block[{localRecoilSource=localHatSumSource,localRecoilTerms},
  localRecoilTerms[value_]:=localHatRationalTerms[value];
  localExactRecoilRatio[generic]];
 answer=answer/.reverse;
 gate["all physical functional generators restored",FreeQ[answer,Alternatives@@symbols]];
 answer];

localHatExactReduce[value_,assumptions_]:=Module[{expression,arguments,rules},
 expression=localHatExactSum[value];
 Print["REFERENCE_PRECOMPRESSION input_bytes ",ByteCount[value]," output_bytes ",ByteCount[expression]];
 expression=Refine[expression,assumptions];
 arguments=DeleteDuplicates[Cases[expression,Log[arg_]:>arg,Infinity]];
 rules=Thread[(Log/@arguments)->(Log[Factor[#]]&/@arguments)];
 expression=PowerExpand[expression/.rules,Assumptions->assumptions];
 localHatExactSum[expression]];

If[Environment["POLARIZED_SIDIS_VALIDATE_HAT_SUM"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=localHatSumRoot;SetDirectory[root];checks=<||>;
 gate[n_,x_]:=If[TrueQ[x],If[!KeyExistsQ[checks,n],Print["PASS: ",n]];
  AssociateTo[checks,n->True],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];
 bounded[x_,label_]:=MemoryConstrained[TimeConstrained[x,1200,
  gate[ToString[label]<>" time",False]],2*1024^3,gate[ToString[label]<>" memory",False]];
 capturePath=FileNameJoin[{root,"misc","s37_result","s37_result.wl"}];
 receipt=Import[FileNameJoin[{root,"misc","s37_result","s37_execution.json"}],"RawJSON"];
 gate["accepted exact final comparison capture",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"]["misc/s37_result/s37_result.wl"]===
  IntegerString[FileHash[capturePath,"SHA256"],16,64]];
 capture=Get[capturePath];
 gate["accepted comparison runtime and complete input",TrueQ[capture["Accepted"]]&&And@@Values[capture["Checks"]]&&
  capture["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  capture["Actual"]-capture["Expected"]===capture["Difference"]];
 capture=KeyDrop[capture,{"Actual","Expected"}];ClearSystemCache[];
 controlPath=FileNameJoin[{root,"misc","s35_result","s35_result.wl"}];
 controlReceipt=Import[FileNameJoin[{root,"misc","s35_result","s35_execution.json"}],"RawJSON"];
 gate["accepted nonzero scalar control",TrueQ[controlReceipt["passed"]]&&
  controlReceipt["result_sha256"]["misc/s35_result/s35_result.wl"]===IntegerString[FileHash[controlPath,"SHA256"],16,64]];
 control=Get[controlPath];functions=DeleteDuplicates[Cases[capture["Difference"],_Log,Infinity]];
 controlFunction=SelectFirst[functions,!FreeQ[#,mu2]&,Missing["NoActualScaleLog"]];
 gate["actual logarithmic control factor",!MissingQ[controlFunction]&&control["OwnValue"]=!=0];
 controlInput=control["OwnInput"] controlFunction;controlExpected=control["OwnValue"] controlFunction;
 {controlSeconds,controlValue}=AbsoluteTiming[localHatExactReduce[controlInput,capture["Assumptions"]]];
 gate["complete accepted nonzero functional control",bounded[
  FullSimplify[Factor[Together[controlValue-controlExpected]],capture["Assumptions"]],"functional control"]===0];
 Print["REFERENCE_SUM_CONTROL seconds ",controlSeconds," bytes ",ByteCount[controlValue]];
 {actualSeconds,actualValue}=AbsoluteTiming[localHatExactReduce[capture["Difference"],capture["Assumptions"]]];
 Print["REFERENCE_SUM_ACTUAL seconds ",actualSeconds," input_bytes ",ByteCount[capture["Difference"]],
  " output_bytes ",ByteCount[actualValue]];
 If[ByteCount[actualValue]<16384,Print["REFERENCE_REDUCED_EQUATION ",InputForm[actualValue]]];
 result=<|"Schema"->"polarized-sidis-exact-hat-comparison-v1",
  "SourceHash"->FileHash[localHatSumSource,"SHA256"],"CaptureHash"->FileHash[capturePath,"SHA256"],
  "ControlHash"->FileHash[controlPath,"SHA256"],"ControlValue"->controlValue,
  "ControlSeconds"->controlSeconds,"ActualValue"->actualValue,"ActualSeconds"->actualSeconds,
  "Checks"->checks,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>;
 out=FileNameJoin[{root,"misc","s38_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 path=FileNameJoin[{out,"s38_result.wl"}];
 Export[path,"Uncompress["<>ToString[Compress[result],InputForm]<>"]\n","Text"];
 gate["exact reference sum proof reload",Get[path]===result];
 {zeroSeconds,isZero}=AbsoluteTiming[actualValue===0||
  bounded[FullSimplify[actualValue,capture["Assumptions"]],"remaining exact comparison"]===0];
 gate["actual original final F1 comparison",isZero];
 Export[FileNameJoin[{out,"s38_checks.json"}],<|"checks"->checks,"actual_seconds"->actualSeconds,
  "remaining_zero_seconds"->zeroSeconds,"reference_comparison_passed"->isZero|>,"RawJSON"];
 Print["PASS: exact Hgg final reference comparison"];Quit[0]];


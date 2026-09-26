(* Reuse the accepted exact polynomial factorization for the recoil coefficient itself. *)
localCoefficientSource=ExpandFileName[$InputFileName];
localExactRecoilCoefficient[coefficient_]:=Module[{value},
 If[NumberQ[coefficient],Return[coefficient]];
 value=Block[{localRecoilTerms,localRecoilSource=localCoefficientSource},
  localRecoilTerms[input_]:={input};
  localExactRecoilRatio[coefficient]];
 value];

If[Environment["POLARIZED_SIDIS_VALIDATE_COEFFICIENT"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];
 source=ExpandFileName[$InputFileName];checks=<||>;
 gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];bounded[v_,label_]:=MemoryConstrained[
  TimeConstrained[v,300,gate[label<>" time",False]],2*1024^3,gate[label<>" memory",False]];
 readAccepted[relative_,receiptRelative_]:=Module[{p=FileNameJoin[{root,relative}],receipt},
  receipt=Import[FileNameJoin[{root,receiptRelative}],"RawJSON"];
  gate["accepted input "<>relative,TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][relative]===IntegerString[FileHash[p,"SHA256"],16,64]];Get[p]];
 factorProof=readAccepted["misc/s31_result/s31_result.wl","misc/s31_result/s31_execution.json"];
 helper=FileNameJoin[{root,"misc","s31_exact_Hgg_recoil_sum.wls"}];Get[helper];
 gate["unchanged accepted exact factorization helper",factorProof["SourceHash"]===FileHash[helper,"SHA256"]&&
  factorProof["Definitions"]===DownValues[localExactRecoilRatio]&&And@@Values[factorProof["Checks"]]&&
  factorProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
 captured=readAccepted["misc/s30_result/s30_result.wl","misc/s30_result/s30_execution.json"];
 own=readAccepted["misc/s23_result/s23_result.wl","misc/s23_result/s23_execution.json"];
 mapPath=FileNameJoin[{root,"misc","s10_result","s10_result.wl"}];
 gate["exact captured coefficient map",captured["InputHash"]===FileHash[mapPath,"SHA256"]];
 mapped=readAccepted["misc/s10_result/s10_result.wl","misc/s10_result/s10_execution.json"];
 label=captured["Actual"]["Facts"]["Label"];index=label[[2]];master=label[[3]];
 rawActual=(mapped["Components"][[index]]["ReducedCoefficients"][master]/.mapped["TransverseSubstitution"])/.t->omega-s;
 rawOwn=own["Packet"]["Coefficient"]/.t->omega-s;
 Clear[mapped,own];ClearSystemCache[];
 originalHelper=DownValues[localRecoilTerms];originalSource=localRecoilSource;
 {ownSeconds,ownValue}=AbsoluteTiming[localExactRecoilCoefficient[rawOwn]];
 gate["entire own reference coefficient reproduced",
  bounded[Cancel[Together[ownValue-captured["Own"]["Rational"]]]===0,"own factor comparison"]];
 {actualSeconds,actualValue}=AbsoluteTiming[localExactRecoilCoefficient[rawActual]];
 gate["entire actual reference coefficient reproduced",
  bounded[Cancel[Together[actualValue-captured["Actual"]["Rational"]]]===0,"actual factor comparison"]];
 gate["derivative helper and cache namespace restored",
  DownValues[localRecoilTerms]===originalHelper&&localRecoilSource===originalSource];
 result=<|"Schema"->"polarized-sidis-exact-recoil-coefficient-comparison-v1",
  "SourceHash"->FileHash[source,"SHA256"],"HelperHash"->FileHash[helper,"SHA256"],
  "CaptureHash"->FileHash[FileNameJoin[{root,"misc","s30_result","s30_result.wl"}],"SHA256"],
  "Definitions"->DownValues[localExactRecoilCoefficient],"OwnValue"->ownValue,"ActualValue"->actualValue,
  "OwnSeconds"->ownSeconds,"ActualSeconds"->actualSeconds,
  "OwnNativeFormIdentical"->(ownValue===captured["Own"]["Rational"]),
  "ActualNativeFormIdentical"->(actualValue===captured["Actual"]["Rational"]),
  "Checks"->checks,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Accepted"->True|>;
 out=FileNameJoin[{root,"misc","s32_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded complete coefficient proof",StringLength[serialized]<128*1024^2];
 file=FileNameJoin[{out,"s32_result.wl"}];Export[file,serialized,"Text"];
 gate["exact coefficient proof reload",Get[file]===result];
 Export[FileNameJoin[{out,"s32_checks.json"}],<|"checks"->checks,"own_seconds"->ownSeconds,
  "actual_seconds"->actualSeconds,"own_native_form_identical"->result["OwnNativeFormIdentical"],
  "actual_native_form_identical"->result["ActualNativeFormIdentical"]|>,"RawJSON"];
 Print["PASS: exact Hgg recoil coefficient factorization validated"];Quit[0]];

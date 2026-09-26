(* Preserve special-function arguments exactly while comparing scalar records. *)
localCanonicalScalarArguments[value_]:=Module[{calls,rules},
 calls=DeleteDuplicates[Cases[value,_Log|_PolyLog,{0,Infinity}]];
 rules=Map[Function[call,Module[{argument=Last[call],canonical},
   canonical=Factor[Together[argument]];
   gate["canonical special-function argument exactly preserved",
    Factor[Together[argument-canonical]]===0];
   call->ReplacePart[call,-1->canonical]]],calls];
 value/.rules];

If[Environment["POLARIZED_SIDIS_VALIDATE_ARGUMENTS"]==="1",
 $HistoryLength=0;
 reviewRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
 reviewSource=FileNameJoin[{reviewRoot,"misc","s24_canonical_Hgg_arguments.wls"}];
 checks=<||>;
 gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],
  Print["FAIL: ",name];Quit[1]];
 reviewPath=FileNameJoin[{reviewRoot,"misc","s23_result","s23_result.wl"}];
 reviewReceipt=Import[FileNameJoin[{reviewRoot,"misc","s23_result","s23_execution.json"}],"RawJSON"];
 gate["actual failed product capture accepted",TrueQ[reviewReceipt["passed"]]&&
  reviewReceipt["result_sha256"]["misc/s23_result/s23_result.wl"]===IntegerString[FileHash[reviewPath,"SHA256"],16,64]];
 captured=Get[reviewPath];
 packet=captured["Packet"];
 normalizedResidual=Factor[Together[localCanonicalScalarArguments[packet["RetainedResidual"]]]];
 gate["actual retained product residual is exactly zero",normalizedResidual===0];
 normalizedAnswer=localCanonicalScalarArguments[Normal[Series[packet["Answer"],{eps,0,packet["Order"]}]]];
 normalizedDirect=localCanonicalScalarArguments[packet["Direct"]];
 gate["actual complete retained products agree",Factor[Together[normalizedAnswer-normalizedDirect]]===0];
 argumentCalls=DeleteDuplicates[Cases[packet["RetainedResidual"],_Log|_PolyLog,{0,Infinity}]];
 argumentRecords=Map[<|"Original"->Last[#],"Canonical"->Factor[Together[Last[#]]]|>&,argumentCalls];
 gate["all actual argument mappings reconstruct",And@@(Factor[Together[#["Original"]-#["Canonical"]]]===0&/@argumentRecords)];
 gate["saved coefficient and master remain unchanged",captured===Get[reviewPath]];
 reviewOut=FileNameJoin[{reviewRoot,"misc","s24_result"}];
 If[!DirectoryQ[reviewOut],CreateDirectory[reviewOut,CreateIntermediateDirectories->True]];
 result=<|"Schema"->"polarized-sidis-exact-function-argument-comparison-v1",
  "SourceHash"->FileHash[reviewSource,"SHA256"],"CaptureHash"->FileHash[reviewPath,"SHA256"],
  "Definitions"->DownValues[localCanonicalScalarArguments],"ArgumentMappings"->argumentRecords,
  "RetainedResidual"->normalizedResidual,"Checks"->checks,"NativeVersion"->$Version,
  "CoefficientAlgorithmChanged"->False,"Accepted"->True|>;
 Put[result,FileNameJoin[{reviewOut,"s24_result.wl"}]];
 Export[FileNameJoin[{reviewOut,"s24_checks.json"}],<|"checks"->checks,
  "retained_residual"->normalizedResidual,"coefficient_algorithm_changed"->False|>,"RawJSON"];
 Print["ACTUAL_ARGUMENT_MAPS ",InputForm[argumentRecords]];
 Print["PASS: exact Hgg special-function argument comparison"];Quit[0]];

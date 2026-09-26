(* Reuse the accepted own contraction-before-trace comparison. *)
$HistoryLength=0;
precontractDispatchPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_precontracted.wls"}];
precontractBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_zero_angular.wls"}];
If[IntegerString[FileHash[precontractBasePath,"SHA256"],16,64]=!="2fc40e6a92e854cde292568c4e8ec09c600a113ec0e35d2085f9fc17b07cf2f3",Quit[1]];
precontractBaseText=Import[precontractBasePath,"Text"];
precontractBoundary="\nToExpression[zeroDispatchRunTail, InputForm];";
If[StringCount[precontractBaseText,precontractBoundary]=!=1 || !SyntaxQ[Import[precontractDispatchPath,"Text"]],Quit[1]];
precontractPrefix=First[StringSplit[precontractBaseText,precontractBoundary]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
If[StringCount[precontractPrefix,"Get[\"FeynCalc`\"]"] =!= 1,Quit[1]];
precontractPrefix=StringReplace[precontractPrefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[precontractPrefix],Quit[1]];ToExpression[precontractPrefix,InputForm];
precontractProofRelative=channel<>"/s05_precontracted_trace_result/s05_result.wl";
precontractProofPath=FileNameJoin[{root,precontractProofRelative}];
precontractReceiptPath=FileNameJoin[{DirectoryName[precontractProofPath],"s05_execution.json"}];
precontractProof=Get[precontractProofPath];precontractReceipt=Import[precontractReceiptPath,"RawJSON"];
gate["accepted own precontracted trace comparison",channel==="Hqg" && TrueQ[precontractReceipt["passed"]] &&
  precontractReceipt["result_sha256"][precontractProofRelative]===IntegerString[FileHash[precontractProofPath,"SHA256"],16,64] &&
  precontractProof["Schema"]==="polarized-sidis-precontracted-trace-comparison-v1" && precontractProof["Channel"]===channel &&
  precontractProof["InputHash"]===inputHash && precontractProof["InputHashes"]===inputHashes &&
  precontractProof["NativeVersions"]==={$Version,$FeynCalcVersion} &&
  precontractProof["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"] &&
  precontractProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_precontracted_traces.wls"}],"SHA256"] &&
  And@@Values[precontractProof["Checks"]] && TrueQ[precontractProof["Checks"]["own full trace difference vanishes through accepted scalar reader"]]];
gate["same own native trace equations",precontractProof["TracePacketHash"]===FileHash[FileNameJoin[{root,channel,"s05_trace_input_result","s05_result.wl"}],"SHA256"]];
DownValues[precontractedTrace]=precontractProof["TraceDefinitions"];
gate["exact executed trace definitions installed",DownValues[precontractedTrace]===precontractProof["TraceDefinitions"]];
precontractSavedRows=precontractProof["Rows"];
precontractValue[expression_] := Module[{row},
  row=SelectFirst[precontractSavedRows,#["ExpressionHash"]===Hash[expression,"SHA256"]&,None];
  If[AssociationQ[row],Print["REUSED_EXACT_PRECONTRACTED_TRACE ",InputForm[row["Pair"]]," ",InputForm[row["PhotonIndices"]]];
    row["Value"],precontractedTrace[expression]["Value"]]];
precontractTraceNeedle="Contract[DiracSimplify[expression, DiracTraceEvaluate -> True]]";
precontractWorkerNeedle="compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, coefficientAlgorithmHash";
precontractOutputNeedle="AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
precontractChanges={
  precontractTraceNeedle->"precontractValue[expression]",
  precontractWorkerNeedle->"compactSpinResponse, restoredScalarComponent, profiledNative, exactAngularZero, precontractValue, precontractedTrace, precontractSavedRows, coefficientAlgorithmHash",
  precontractOutputNeedle->(precontractOutputNeedle<>"\nAssociateTo[result,{\"PrecontractedTraceProofHash\"->FileHash[precontractProofPath,\"SHA256\"],\"PrecontractedTraceDispatchHash\"->FileHash[precontractDispatchPath,\"SHA256\"]}];")};
gate["unique trace-order production interfaces",And@@(StringCount[zeroDispatchRunTail,First[#]]===1&/@precontractChanges)];
precontractRunTail=StringReplace[zeroDispatchRunTail,precontractChanges];
gate["complete unchanged scalar pair and tensor assembly",StringReplace[precontractRunTail,Reverse/@precontractChanges]===zeroDispatchRunTail && SyntaxQ[precontractRunTail]];
ToExpression[precontractRunTail,InputForm];

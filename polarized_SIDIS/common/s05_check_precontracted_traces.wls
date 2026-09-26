(* Compare native contraction before trace evaluation on the exact saved inputs. *)
$HistoryLength=0;
traceInputPath=FileNameJoin[{Directory[],"common","s05_check_precontracted_traces.wls"}];
traceBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[traceBasePath,"SHA256"],16,64]=!="ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",Quit[1]];
traceBaseText=Import[traceBasePath,"Text"];
traceBoundary="\nDo[\n  amplitudes =";
If[StringCount[traceBaseText,traceBoundary]=!=1 || !SyntaxQ[Import[traceInputPath,"Text"]],Quit[1]];
tracePrefix=First[StringSplit[traceBaseText,traceBoundary]];
If[StringCount[tracePrefix,"Get[\"FeynCalc`\"]"] =!= 1,Quit[1]];
tracePrefix=StringReplace[tracePrefix,"Get[\"FeynCalc`\"]"->"If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]"];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
If[!SyntaxQ[tracePrefix],Quit[1]];ToExpression[tracePrefix,InputForm];
gate["own Hqg trace inputs",channel==="Hqg" && labels==={"Real"}];
label=First[labels];
traceSector=StringDrop[sourceSection[traceBaseText,traceBoundary,"\n  slots ="],StringLength["\nDo["]];
gate["unchanged complete native sector syntax",SyntaxQ[traceSector]];
ToExpression[traceSector,InputForm];
tracePacketPath=FileNameJoin[{root,channel,"s05_trace_input_result","s05_result.wl"}];
tracePacketReceipt=Import[FileNameJoin[{DirectoryName[tracePacketPath],"s05_execution.json"}],"RawJSON"];
tracePacket=Get[tracePacketPath];
gate["accepted own saved trace equations",TrueQ[tracePacketReceipt["passed"]] &&
  tracePacketReceipt["result_sha256"][channel<>"/s05_trace_input_result/s05_result.wl"]===IntegerString[FileHash[tracePacketPath,"SHA256"],16,64] &&
  tracePacket["Schema"]==="polarized-sidis-native-trace-inputs-v1" && tracePacket["InputHash"]===inputHash &&
  tracePacket["InputHashes"]===inputHashes && tracePacket["NativeVersions"]==={$Version,$FeynCalcVersion} &&
  tracePacket["ScalarRestore"]===scalarRestore && And@@Values[tracePacket["Checks"]]];
precontractStudy=FileNameJoin[{root,channel,"s05_precontracted_trace_result"}];
If[!DirectoryQ[precontractStudy],CreateDirectory[precontractStudy,CreateIntermediateDirectories->True]];
precontractedTrace[expression_] := Module[{contracted,traced,contractSeconds,traceSeconds},
  {contractSeconds,contracted}=AbsoluteTiming[Contract[FCI[expression]]];
  Print["PRECONTRACTED_TRACE_INPUT seconds ",contractSeconds," original_bytes ",ByteCount[expression]," contracted_bytes ",ByteCount[contracted]];
  {traceSeconds,traced}=AbsoluteTiming[Contract[DiracSimplify[contracted,DiracTraceEvaluate->True]]];
  gate["complete precontracted trace evaluated",FreeQ[traced,_DiracTrace|_DiracGamma|_Spinor|$Failed|$Aborted]];
  Print["PRECONTRACTED_TRACE_EVALUATED seconds ",traceSeconds," bytes ",ByteCount[traced]];
  <|"Value"->traced,"ContractSeconds"->contractSeconds,"TraceSeconds"->traceSeconds,
    "OriginalBytes"->ByteCount[expression],"ContractedBytes"->ByteCount[contracted],"TraceBytes"->ByteCount[traced]|>];
precontractControlConfig=Import[FileNameJoin[{root,"common","s05_zero_angular_inputs.json"}],"RawJSON"];
precontractControlEntry=First[precontractControlConfig["comparisons"]];
precontractControlPath=FileNameJoin[{root,precontractControlEntry["accepted_file"]}];
precontractOriginalTracePath=FileNameJoin[{root,precontractControlEntry["trace_file"]}];
gate["own accepted complete trace-control artifacts",IntegerString[FileHash[precontractControlPath,"SHA256"],16,64]===precontractControlEntry["accepted_sha256"] &&
  IntegerString[FileHash[precontractOriginalTracePath,"SHA256"],16,64]===precontractControlEntry["trace_sha256"]];
precontractControl=Get[precontractControlPath];precontractOriginalTrace=Get[precontractOriginalTracePath];
gate["own complete control physical identity",precontractControl["InputHash"]===inputHash && precontractOriginalTrace["InputHash"]===inputHash &&
  precontractOriginalTrace["Pair"]===precontractControlEntry["pair"] && precontractOriginalTrace["PhotonIndices"]===precontractControlEntry["photon_indices"]];
precontractRow=SelectFirst[tracePacket["Rows"],#["Pair"]===precontractControlEntry["pair"] && #["PhotonIndices"]===precontractControlEntry["photon_indices"]&];
gate["complete own control input present",AssociationQ[precontractRow] && Hash[precontractRow["Expression"],"SHA256"]===precontractRow["ExpressionHash"]];
precontractControlTrace=bounded[precontractedTrace[precontractRow["Expression"]],"own precontracted control trace"];
(* Reuse the accepted scalar/angle routine on the full trace difference. *)
precontractCoefficientDirectory=coefficientDirectory;
coefficientDirectory=FileNameJoin[{precontractStudy,"control_cache"}];
If[!DirectoryQ[coefficientDirectory],CreateDirectory[coefficientDirectory]];
precontractDifference=bounded[reduceScalar[precontractControlTrace["Value"]-precontractOriginalTrace["TracedExpression"]],"complete trace-difference reduction"];
gate["own full trace difference vanishes through accepted scalar reader",zero[precontractDifference]];
coefficientDirectory=precontractCoefficientDirectory;
precontractResults={Join[KeyTake[precontractRow,{"Pair","PhotonIndices","ExpressionHash"}],precontractControlTrace,<|"OwnAcceptedTraceCompared"->True|>]};
Do[
  gate["exact target trace equation",Hash[row["Expression"],"SHA256"]===row["ExpressionHash"]];
  Print["PRECONTRACTED_TRACE_TARGET ",InputForm[row["Pair"]]," ",InputForm[row["PhotonIndices"]]];
  answer=bounded[precontractedTrace[row["Expression"]],{"actual target trace",row["Pair"],row["PhotonIndices"]}];
  target=Join[KeyTake[row,{"Pair","PhotonIndices","ExpressionHash"}],answer,<|"OwnAcceptedTraceCompared"->False|>];
  AppendTo[precontractResults,target],{row,Select[tracePacket["Rows"],#["PhotonIndices"]==={3,2}&]}];
precontractResult=<|"Schema"->"polarized-sidis-precontracted-trace-comparison-v1","Channel"->channel,"InputHash"->inputHash,"InputHashes"->inputHashes,
  "SourceHash"->FileHash[traceInputPath,"SHA256"],"ProductionSourceHash"->FileHash[traceBasePath,"SHA256"],
  "TracePacketHash"->FileHash[tracePacketPath,"SHA256"],"ControlHash"->FileHash[precontractControlPath,"SHA256"],
  "OriginalTraceHash"->FileHash[precontractOriginalTracePath,"SHA256"],"TraceDefinitions"->DownValues[precontractedTrace],
  "Rows"->precontractResults,"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
precontractSerialized="Uncompress["<>ToString[Compress[precontractResult],InputForm]<>"]\n";
gate["bounded precontracted comparison output",StringLength[precontractSerialized]<128*1024^2];
precontractFile=FileNameJoin[{precontractStudy,"s05_result.wl"}];
Export[precontractFile<>".tmp",precontractSerialized,"Text"];
gate["exact native precontracted comparison reload",Get[precontractFile<>".tmp"]===precontractResult];
RenameFile[precontractFile<>".tmp",precontractFile,OverwriteTarget->True];
Export[FileNameJoin[{precontractStudy,"s05_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s05_check_precontracted_traces"];Quit[0];

(* Save the actual native inputs of the slow trace calls without evaluating them. *)
$HistoryLength=0;
traceInputPath=FileNameJoin[{Directory[],"common","s05_prepare_trace_inputs.wls"}];
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
traceRows=Flatten[Table[
  tracePair=bounded[buildPair[First[pair],Last[pair],None],{"trace input",pair}];
  Table[
    traceExpression=photonProject[tracePair,photonSymbols[[First[indices]]],photonSymbols[[Last[indices]]]];
    gate["closed projected trace input",FreeQ[traceExpression,_Spinor|keptSpinSum] && !FreeQ[traceExpression,_DiracTrace]];
    Print["TRACE_INPUT_SAVED ",InputForm[pair]," ",InputForm[indices]," bytes ",ByteCount[traceExpression]];
    <|"Pair"->pair,"PhotonIndices"->indices,"Expression"->traceExpression,"ExpressionHash"->Hash[traceExpression,"SHA256"]|>,
    {indices,{{1,1},{3,2}}}],{pair,{{1,6},{1,7}}}],1];
traceResult=<|"Schema"->"polarized-sidis-native-trace-inputs-v1","Channel"->channel,"InputHash"->inputHash,
  "InputHashes"->inputHashes,"SourceHash"->FileHash[traceInputPath,"SHA256"],"ProductionSourceHash"->FileHash[traceBasePath,"SHA256"],
  "Rows"->traceRows,"ScalarRestore"->scalarRestore,"SpinVariables"->{outVariables,inVariables},
  "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"TracesEvaluated"->False|>;
traceDirectory=FileNameJoin[{root,channel,"s05_trace_input_result"}];
If[!DirectoryQ[traceDirectory],CreateDirectory[traceDirectory,CreateIntermediateDirectories->True]];
traceText=ToString[traceResult,InputForm]<>"\n";
gate["bounded native trace equations",StringLength[traceText]<128*1024^2];
traceResultFile=FileNameJoin[{traceDirectory,"s05_result.wl"}];
Export[traceResultFile<>".tmp",traceText,"Text"];
gate["exact native trace input reload",Get[traceResultFile<>".tmp"]===traceResult];
RenameFile[traceResultFile<>".tmp",traceResultFile,OverwriteTarget->True];
Export[FileNameJoin[{traceDirectory,"s05_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],"traces_evaluated"->False|>,"RawJSON"];
Print["PASS: s05_prepare_trace_inputs"];Quit[0];

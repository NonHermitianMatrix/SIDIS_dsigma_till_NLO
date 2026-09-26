(* Reuse the accepted local-input comparison and continue complete Hgg mapping. *)
$HistoryLength=0;
localResumeSource=FileNameJoin[{Directory[],"common","s08_resume_Hgg_local_inputs.wls"}];
localResumeBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_local_inputs.wls"}];
If[!SyntaxQ[Import[localResumeSource,"Text"]]||IntegerString[FileHash[localResumeBase,"SHA256"],16,64]=!=
 "55a5d6eb1f3a0af3193d1e5ba79fe8e93d43dcbc239f7a772f93387eda2528c6",Print["FAIL: pinned complete local-input entry"];Quit[1]];
If[!MemberQ[{$Failed,""},Environment["POLARIZED_SIDIS_LOCAL_INPUT_COMPONENT"]],
 Print["FAIL: continuation requires the complete channel"];Quit[1]];
localResumeReceiptPath=FileNameJoin[{Directory[],"Hgg","s08_local_input_component_result","s08_execution.json"}];
localResumeReceipt=Import[localResumeReceiptPath,"RawJSON"];
If[!AssociationQ[localResumeReceipt]||!TrueQ[localResumeReceipt["passed"]]||
 localResumeReceipt["reviewed_sha256"]["common/s08_map_Hgg_local_inputs.wls"]=!=IntegerString[FileHash[localResumeBase,"SHA256"],16,64]||
 !KeyExistsQ[localResumeReceipt["result_sha256"],"Hgg/s08_local_input_control_result/s08_result.wl"]||
 !And@@KeyValueMap[FileExistsQ[FileNameJoin[{Directory[],#1}]]&&
  IntegerString[FileHash[FileNameJoin[{Directory[],#1}],"SHA256"],16,64]===#2&,localResumeReceipt["result_sha256"]],
 Print["FAIL: complete accepted local-input comparison and actual component required"];Quit[1]];
localResumeText=StringTrim[Import[localResumeBase,"Text"]];
localResumeTerminal="ToExpression[coordinateRun,InputForm];";
If[!StringEndsQ[localResumeText,localResumeTerminal],Quit[1]];
localResumePrefix=StringDrop[localResumeText,-StringLength[localResumeTerminal]];
If[!SyntaxQ[localResumePrefix],Quit[1]];ToExpression[localResumePrefix,InputForm];
localResumeOld="If[True||Lookup[hggOwnProof,\"InputHash\",None]";
localResumeNew="If[Lookup[hggOwnProof,\"InputHash\",None]";
If[StringCount[coordinateRun,localResumeOld]=!=1,Print["FAIL: unique accepted control reuse condition"];Quit[1]];
localResumeRun=StringReplace[coordinateRun,localResumeOld->localResumeNew];
If[!SyntaxQ[localResumeRun]||StringReplace[localResumeRun,localResumeNew->localResumeOld]=!=coordinateRun,
 Print["FAIL: unchanged complete local-input production pipeline"];Quit[1]];
Print["ACCEPTED_LOCAL_INPUT_CONTINUATION source ",IntegerString[FileHash[localResumeSource,"SHA256"],16,64],
 " receipt ",IntegerString[FileHash[localResumeReceiptPath,"SHA256"],16,64]];
ToExpression[localResumeRun,InputForm];

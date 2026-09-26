(* Execute the existing Hgg scheme-only stage in the authorized local runtime. *)
$HistoryLength=0;
localRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localDirectory=FileNameJoin[{localRoot,"misc"}];SetDirectory[localRoot];
localSource=FileNameJoin[{localDirectory,"s05_prepare_Hgg_scheme.wls"}];
localConfiguration=Import[FileNameJoin[{localDirectory,"s05_inputs.json"}],"RawJSON"];
localChecks=<||>;
localGate[name_,test_]:=If[TrueQ[test],AssociateTo[localChecks,name->True];Print["PASS: ",name],
 Print["FAIL: ",name];Quit[1]];
localGate["reviewed complete local source",SyntaxQ[ReadString[localSource]]&&
 IntegerString[FileHash[localSource,"SHA256"],16,64]===localConfiguration["source_sha256"]];
KeyValueMap[Function[{relative,expected},localGate["bound local input "<>relative,
 IntegerString[FileHash[FileNameJoin[{localRoot,relative}],"SHA256"],16,64]===expected]],
 localConfiguration["input_sha256"]];
localGate["explicit local scheme-only invocation",
 Environment["POLARIZED_SIDIS_LOCAL_AUTHORIZED"]==="1"&&
 Environment["POLARIZED_SIDIS_CHANNEL"]==="Hgg"&&
 Environment["POLARIZED_SIDIS_SCHEME_ONLY"]==="1"];
localSubtractionReceipt=Import[FileNameJoin[{localRoot,"Hgg","s11_native_result","s11_execution.json"}],"RawJSON"];
localPreviousReceipt=Import[FileNameJoin[{localRoot,"Hgg","s15_scheme_result","reference",
 "before_dimensional_completion","s15_execution.json"}],"RawJSON"];
localGate["authentic accepted subtraction input",TrueQ[localSubtractionReceipt["passed"]]&&
 localSubtractionReceipt["result_sha256"]["Hgg/s11_native_result/s11_result.wl"]===
 localConfiguration["input_sha256"]["Hgg/s11_native_result/s11_result.wl"]];
localGate["authentic accepted previous scheme input",TrueQ[localPreviousReceipt["passed"]]&&
 localPreviousReceipt["result_sha256"]["Hgg/s15_scheme_result/s15_result.wl"]===
 localConfiguration["input_sha256"]["Hgg/s15_scheme_result/reference/before_dimensional_completion/s15_result.wl"]];
localBase=FileNameJoin[{localRoot,"common","s15_finalize_Hgg_coefficients.wls"}];
localBaseText=StringTrim[Import[localBase,"Text"]];
localTerminal="ToExpression[gluonFinalCode,InputForm];";
localGate["unique complete Hgg entry boundary",StringEndsQ[localBaseText,localTerminal]&&
 StringCount[localBaseText,localTerminal]===1];
localPrefix=StringDrop[localBaseText,-StringLength[localTerminal]];
localGate["complete inherited entry syntax",SyntaxQ[localPrefix]];
ToExpression[localPrefix,InputForm];
localOutput=FileNameJoin[{localDirectory,"s05_result"}];
localEdits={
 "gate[\"compute allocation\", StringQ[Environment[\"JOB_ID\"]] && !StringStartsQ[$MachineName, \"login\"]];"->
  "gate[\"authorized local Engine15 runtime\",Environment[\"POLARIZED_SIDIS_LOCAL_AUTHORIZED\"]===\"1\"&&$VersionNumber===15.];",
 "gate[\"isolated runtime\", StringStartsQ[$UserBaseDirectory, root <> \"/\"]];"->
  "gate[\"isolated local output owner\",localOutput===FileNameJoin[{root,\"misc\",\"s05_result\"}]];",
 "schemeDirectory = FileNameJoin[{root,channel,\"s15_native_scheme_result\"}];"->
  "checks=Join[localChecks,checks];scheme=Join[scheme,<|\"Checks\"->checks,\"LocalSourceHash\"->FileHash[localSource,\"SHA256\"],\"LocalNativeVersions\"->{$Version,$FeynCalcVersion},\"ExecutionBackend\"->\"local\",\"LocalInputManifestHash\"->FileHash[FileNameJoin[{localDirectory,\"s05_inputs.json\"}],\"SHA256\"],\"InputExecutionCommands\"->{localSubtractionReceipt[\"command\"],localPreviousReceipt[\"command\"]}|>];schemeDirectory=localOutput;",
 "schemePath = FileNameJoin[{schemeDirectory, \"s15_result.wl\"}];"->
  "schemePath = FileNameJoin[{schemeDirectory, \"s05_result.wl\"}];",
 "FileNameJoin[{schemeDirectory, \"s15_checks.json\"}]"->
  "FileNameJoin[{schemeDirectory, \"s05_checks.json\"}]",
 "\"job_id\" -> Environment[\"JOB_ID\"]"->
  "\"execution_backend\"->\"local\",\"run_id\"->localConfiguration[\"run_id\"]"};
localGate["exact local runtime and storage interfaces",
 Map[StringCount[gluonFinalCode,First[#]]&,localEdits]==={1,1,1,1,1,2}];
localRun=StringReplace[gluonFinalCode,localEdits];
localGate["entire inherited calculation unchanged",SyntaxQ[localRun]&&
 StringReplace[localRun,Reverse/@localEdits]===gluonFinalCode];
If[Environment["POLARIZED_SIDIS_LOCAL_PREFLIGHT"]==="1",
 Print["PASS: s05_local_scheme_interface"];Quit[0]];
ToExpression[localRun,InputForm];

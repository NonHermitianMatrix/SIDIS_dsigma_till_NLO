(* Retain the native transverse coordinate until after the regulator recurrence. *)
$HistoryLength=0;
symbolicPath=FileNameJoin[{Directory[],"common","s12_assemble_real_symbolic_transverse.wls"}];
symbolicBase=FileNameJoin[{Directory[],"common","s12_assemble_real_retained_series.wls"}];
If[IntegerString[FileHash[symbolicBase,"SHA256"],16,64]=!=
  "ebbb1a516ab4852aa1cbe0c328c4b4303cce46641369614c33eaa0a906d4bab1",Quit[1]];
symbolicBaseText=Import[symbolicBase,"Text"];
symbolicBoundary="\nretainedControlPath=";
If[StringCount[symbolicBaseText,symbolicBoundary]=!=1 || !SyntaxQ[Import[symbolicPath,"Text"]],Quit[1]];
ToExpression[First[StringSplit[symbolicBaseText,symbolicBoundary]],InputForm];
symbolicOriginalOrdinary=DownValues[candidateOrdinary];
DownValues[symbolicPriorOrdinary]=symbolicOriginalOrdinary/.HoldPattern[candidateOrdinary]->symbolicPriorOrdinary;
gate["prior ordinary caller retained exactly",(DownValues[symbolicPriorOrdinary]/.HoldPattern[symbolicPriorOrdinary]->candidateOrdinary)===symbolicOriginalOrdinary];
Clear[candidateOrdinary];
candidateOrdinary[component_,index_] := Module[{coefficients,ordinary,value,seconds},
  coefficients=Select[component["ReducedCoefficients"],#=!=0&];
  gate["transverse substitution independent of regulator",FreeQ[Last[transverseRule],eps|D]];
  gate["ordinary masters independent of transverse placeholder",And@@
    (FreeQ[regions["OrdinaryMasters"][#],First[transverseRule]]&/@Keys[coefficients])];
  {seconds,ordinary}=AbsoluteTiming[Total[KeyValueMap[ordinaryMasterProduct[#2/.D->4-2eps,
    regions["OrdinaryMasters"][#1],0,{index,#1}]&,coefficients]]];
  value=ordinary/.transverseRule;
  gate["physical transverse coordinate restored after recurrence",FreeQ[value,First[transverseRule]]];
  Print["SYMBOLIC_TRANSVERSE_ORDINARY ",index," seconds ",seconds,
    " symbolic_input_bytes ",ByteCount[coefficients]," physical_input_bytes ",ByteCount[coefficients/.transverseRule],
    " symbolic_output_bytes ",ByteCount[ordinary]," physical_output_bytes ",ByteCount[value]];
  value];
symbolicRegressionCode="  symbolicRegression=Table[\n"<>
  "    symbolicRegressionTask=Join[retainedRegressionTask,<|\"ReducedCoefficients\"->KeyTake[retainedRegressionTask[\"ReducedCoefficients\"],{symbolicRegressionRow[\"Master\"]}]|>];\n"<>
  "    symbolicRegressionOriginal=symbolicPriorOrdinary[symbolicRegressionTask,retainedResidual[\"ComponentIndex\"]];\n"<>
  "    symbolicRegressionValue=candidateOrdinary[symbolicRegressionTask,retainedResidual[\"ComponentIndex\"]];\n"<>
  "    gate[\"deferred substitution matches actual empty-support product\",symbolicRegressionValue===symbolicRegressionOriginal || bounded[zeroCoefficient[Expand[symbolicRegressionValue-symbolicRegressionOriginal,eps]],\"actual deferred substitution comparison\"]];\n"<>
  "    <|\"Master\"->symbolicRegressionRow[\"Master\"],\"Original\"->symbolicRegressionOriginal,\"Candidate\"->symbolicRegressionValue|>,\n"<>
  "    {symbolicRegressionRow,retainedRegressionRows}];\n";
symbolicTail=symbolicBoundary<>Last[StringSplit[symbolicBaseText,symbolicBoundary]];
symbolicChanges={
  "\"s12_retained_series_result\""->"\"s12_symbolic_transverse_result\"",
  "  {retainedSeconds,retainedValue}="->(symbolicRegressionCode<>"  {retainedSeconds,retainedValue}="),
  "\"polarized-sidis-retained-series-comparison-v1\""->"\"polarized-sidis-symbolic-transverse-comparison-v1\"",
  "    \"NativeVersions\"->{$Version,$FeynCalcVersion},\"Checks\"->checks,\"Accepted\"->True|>;"->
    "    \"OrdinaryDefinitions\"->DownValues[candidateOrdinary],\"DeferredSubstitutionRegression\"->symbolicRegression,\n    \"NativeVersions\"->{$Version,$FeynCalcVersion},\"Checks\"->checks,\"Accepted\"->True|>;",
  "PASS: s12_retained_series_comparison"->"PASS: s12_symbolic_transverse_comparison",
  "RetainedSeriesSourceHash"->"SymbolicTransverseSourceHash",
  "RetainedSeriesComparisonHash"->"SymbolicTransverseComparisonHash"};
gate["unique symbolic transverse interfaces",And@@(StringCount[symbolicTail,First[#]]===1&/@symbolicChanges)];
symbolicRun=StringReplace[symbolicTail,symbolicChanges];
gate["unchanged integration and comparison gates",SyntaxQ[symbolicRun] &&
  StringReplace[symbolicRun,Reverse/@symbolicChanges]===symbolicTail];
retainedPath=symbolicPath;
ToExpression[symbolicRun,InputForm];

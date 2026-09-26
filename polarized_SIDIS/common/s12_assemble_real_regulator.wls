(* Use the verified regulator series in the unchanged real-integration pipeline. *)
$HistoryLength=0;
regulatorDispatchPath=FileNameJoin[{Directory[],"common","s12_assemble_real_regulator.wls"}];
regulatorBaselinePath=FileNameJoin[{Directory[],"common","s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[regulatorBaselinePath,"SHA256"],16,64]=!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243",Quit[1]];
regulatorText=Import[regulatorBaselinePath,"Text"];
If[!SyntaxQ[Import[regulatorDispatchPath,"Text"]]||StringCount[regulatorText,"\nslots="]=!=1,Quit[1]];
regulatorBoundary=First[First[StringPosition[regulatorText,"\nslots="]]];
regulatorPrefix=StringTake[regulatorText,regulatorBoundary-1];
regulatorTail=StringDrop[regulatorText,regulatorBoundary-1];
regulatorOldCall="epsilonSeries[(c/.D->4-2eps)regions[\"OrdinaryMasters\"][m],0,";
If[StringCount[regulatorPrefix,regulatorOldCall]=!=1,Quit[1]];
regulatorPrefix=StringReplace[regulatorPrefix,regulatorOldCall->
  "regulatorMasterSeries[c,regions[\"OrdinaryMasters\"][m],0,"];
If[!SyntaxQ[regulatorPrefix]||!SyntaxQ[regulatorTail],Quit[1]];
ToExpression[regulatorPrefix,InputForm];
regulatorProofPath=FileNameJoin[{root,channel,"s12_regulator_result","s12_result.wl"}];
regulatorReceipt=Import[FileNameJoin[{root,channel,"s12_regulator_result","s12_execution.json"}],"RawJSON"];
gate["accepted regulator comparison receipt",TrueQ[regulatorReceipt["passed"]]&&
  regulatorReceipt["result_sha256"][channel<>"/s12_regulator_result/s12_result.wl"]===
    IntegerString[FileHash[regulatorProofPath,"SHA256"],16,64]];
regulatorProof=Get[regulatorProofPath];
gate["accepted complete regulator comparison",
  regulatorProof["Schema"]==="polarized-sidis-regulator-series-check-v1"&&
  TrueQ[regulatorProof["Accepted"]]&&And@@Values[regulatorProof["Checks"]]&&
  Lookup[regulatorProof["ControlRows"],"Index"]===Range[6]];
gate["regulator comparison source and native version",
  regulatorProof["OriginalSourceHash"]===sourceHash&&regulatorProof["NativeVersion"]===$Version&&
  regulatorProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s12_check_regulator_series.wls"}],"SHA256"]];
gate["regulator comparison exact production inputs",channel==="Hqqprime"&&
  regulatorProof["Channel"]===channel&&regulatorProof["InputHash"]===inputHash&&
  regulatorProof["InputHashes"]===inputHashes];
DownValues[regulatorMasterSeries]=regulatorProof["Definitions"];
gate["executed regulator series installed",DownValues[regulatorMasterSeries]===regulatorProof["Definitions"]];
regulatorDistribute="DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,";
regulatorOutput="put[result,FileNameJoin[{resultDir,\"s12_result.wl\"}]];";
gate["unique unchanged worker and output interfaces",
  StringCount[regulatorTail,regulatorDistribute]===1&&StringCount[regulatorTail,regulatorOutput]===1];
regulatorProgram=StringReplace[regulatorTail,{
  regulatorDistribute->"DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,regulatorMasterSeries,",
  regulatorOutput->("result=Join[result,<|\"DispatchSourceHash\"->FileHash[regulatorDispatchPath,\"SHA256\"],"<>
    "\"RegulatorComparisonHash\"->FileHash[regulatorProofPath,\"SHA256\"]|>];\n"<>regulatorOutput)}];
gate["complete regulator integration syntax",SyntaxQ[regulatorProgram]];
ToExpression[regulatorProgram,InputForm];

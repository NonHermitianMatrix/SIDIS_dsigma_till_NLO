(* Execute the actual transfer and native consumer comparison with the legacy file-based loader. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
reviewRoot="/home/physics/projects/AI_Assisted_SIDIS/scripts/polarized_SIDIS";SetDirectory[reviewRoot];
reviewProducer=FileNameJoin[{reviewRoot,"misc","s17_compare_Hgg_exact_polynomials.wls"}];
reviewText=ReadString[reviewProducer];
reviewPrefix=StringTake[reviewText,First[First[StringPosition[reviewText,"\npolynomialCases="]]]-1];
reviewPrefix=StringReplace[reviewPrefix,"$FeynCalcStartupMessages=False;Get[\"FeynCalc`\"];"->"Null;"];
If[!SyntaxQ[reviewPrefix],Quit[1]];ToExpression[reviewPrefix,InputForm];
reviewHelper=FileNameJoin[{root,"misc","s20_Hgg_exact_sum.wls"}];
gate["complete exact-sum adapter syntax",SyntaxQ[ReadString[reviewHelper]]];Get[reviewHelper];
reviewOwnPath=FileNameJoin[{root,"misc","s19_result","s19_result.wl"}];
reviewOwnReceipt=Import[FileNameJoin[{root,"misc","s19_result","s19_execution.json"}],"RawJSON"];
gate["accepted own Hgg comparison receipt",TrueQ[reviewOwnReceipt["passed"]]&&
 reviewOwnReceipt["result_sha256"]["misc/s19_result/s19_result.wl"]===IntegerString[FileHash[reviewOwnPath,"SHA256"],16,64]];
reviewOwn=Get[reviewOwnPath];
gate["complete own Hgg native comparison",TrueQ[reviewOwn["AcceptedOwnHggComparisonPassed"]]&&
 And@@Values[reviewOwn["Checks"]]&&Length[reviewOwn["Evidence"]]===reviewOwn["CoefficientCount"]&&
 AllTrue[reviewOwn["Evidence"],TrueQ[#["expected_comparison_passed"]]&&TrueQ[#["exact_termwise_reconstruction_passed"]]&]];
reviewTransferPath=FileNameJoin[{root,"misc","s20_result","s20_transfer.json"}];
{reviewSeconds,reviewMappings}=AbsoluteTiming[localPolynomialTransfer[{
 <|"Label"->"accepted_reference_control","Terms"->controlTerms,"Expected"->controlValue|>,
 <|"Label"->"Hgg_component_1_first_master","Terms"->comparisonTerms|>},reviewTransferPath]];
reviewOldPayload=Import[FileNameJoin[{root,"misc","s17_result","s17_input.json"}],"RawJSON"];
reviewNewPayload=Import[reviewTransferPath,"RawJSON"];
gate["entire actual polynomial transfer exactly unchanged",reviewNewPayload===reviewOldPayload];
reviewBackendOutput=Import[FileNameJoin[{root,"misc","s17_result","s17_output.json"}],"RawJSON"];
reviewActualRow=Last[reviewBackendOutput["cases"]];
reviewActualValue=(ToExpression[reviewActualRow["numerator"],InputForm]/ToExpression[reviewActualRow["denominator"],InputForm])/.
 reviewMappings["Hgg_component_1_first_master"];
reviewActualRecord=Get[FileNameJoin[{root,"misc","s17_result","s17_result.wl"}]];
gate["actual native candidate import exactly unchanged",reviewActualValue===reviewActualRecord["Value"]];
localPolynomialBackendPath=FileNameJoin[{root,"misc","s18_sum_exact_polynomials.py"}];
localPolynomialBackendHash=FileHash[localPolynomialBackendPath,"SHA256"];
localPolynomialProofHash=FileHash[reviewOwnPath,"SHA256"];
gate["own comparison used this exact backend",reviewOwn["BackendHash"]===localPolynomialBackendHash];
cache=FileNameJoin[{root,"misc","s20_result","interface_work"}];
reviewControl=localExactPolynomialSum[controlTerms,"complete native adapter control"];
gate["production adapter reproduces accepted reference control",zero[reviewControl["Value"]-controlValue]&&
 TrueQ[reviewControl["Evidence"]["ExactTermwiseReconstructionPassed"]]];
reviewResult=<|"checks"->checks,"source_sha256"->IntegerString[FileHash[reviewHelper,"SHA256"],16,64],
 "backend_sha256"->IntegerString[localPolynomialBackendHash,16,64],
 "own_proof_sha256"->IntegerString[localPolynomialProofHash,16,64],"actual_transfer_seconds"->reviewSeconds,
 "actual_transfer_bytes"->FileByteCount[reviewTransferPath],"peak_native_memory_bytes"->MaxMemoryUsed[],
 "input_payload_sha256"->IntegerString[FileHash[FileNameJoin[{root,"misc","s17_result","s17_input.json"}],"SHA256"],16,64]|>;
Export[FileNameJoin[{root,"misc","s20_interface_review.json"}],reviewResult,"RawJSON"];
DeleteFile[reviewTransferPath];If[DirectoryQ[cache],DeleteDirectory[cache,DeleteContents->True]];
Print["PASS: complete exact-sum native interface review"];Quit[0];

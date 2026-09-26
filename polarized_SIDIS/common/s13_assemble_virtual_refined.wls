(* Preserve the accepted virtual pipeline; refine its exact UV residual. *)
$HistoryLength = 0;
refinedSource = FileNameJoin[{Directory[], "common", "s13_assemble_virtual_refined.wls"}];
refinedBaseline = FileNameJoin[{Directory[], "common", "s13_assemble_virtual_spin.wls"}];
If[IntegerString[FileHash[refinedBaseline, "SHA256"], 16, 64] =!=
 "44bc4684e7aa164e7d9e0928bb2572c7f7ea146e8215653516fef6bf1e729989", Quit[1]];
refinedText = Import[refinedBaseline, "Text"];
refinedBoundary = StringPosition[refinedText, "\nkeys = Keys[mapped[\"Components\"]];"];
If[Length[refinedBoundary] =!= 1 || !SyntaxQ[Import[refinedSource, "Text"]], Quit[1]];
refinedPrefix = StringTake[refinedText, First[First[refinedBoundary]] - 1];
refinedTail = StringDrop[refinedText, First[First[refinedBoundary]] - 1];
If[!SyntaxQ[refinedPrefix] || !SyntaxQ[refinedTail], Quit[1]];
ToExpression[refinedPrefix, InputForm];
refinedProofPath = FileNameJoin[{root, "Hqg", "s13_branch_result", "s13_result.wl"}];
refinedReceipt = Import[FileNameJoin[{root, "Hqg", "s13_branch_result", "s13_execution.json"}], "RawJSON"];
gate["accepted residual refinement receipt", TrueQ[refinedReceipt["passed"]] &&
 refinedReceipt["result_sha256"]["Hqg/s13_branch_result/s13_result.wl"] === IntegerString[FileHash[refinedProofPath, "SHA256"], 16, 64]];
refinedProof = Get[refinedProofPath];
gate["accepted physical residual refinement", refinedProof["Schema"] === "polarized-sidis-uv-branch-comparison-v1" &&
 TrueQ[refinedProof["Accepted"]] && And @@ Values[refinedProof["Checks"]] &&
 refinedProof["RefinedOriginalResidual"] === 0 && refinedProof["RefinedSumResidual"] === 0];
gate["refinement source and physical conventions", refinedProof["BaselineSourceHash"] === FileHash[refinedBaseline, "SHA256"] &&
 IntegerString[refinedProof["SourceHash"], 16, 64] === "55494a9171c36213d476b2f518a748d7f8023921e98dc51124c6461dd7f5348a" &&
 refinedProof["PhysicalConditions"] === physical && refinedProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["refinement uses these exact Hqg inputs", channel === refinedProof["Channel"] && refinedProof["InputHashes"] === inputHashes];
DownValues[refineUVResidual] = refinedProof["Definitions"];
gate["executed residual refinement installed", DownValues[refineUVResidual] === refinedProof["Definitions"]];
refinedGate = "      gate[\"complete UV cancellation \" <> ToString[key, InputForm], residual === 0];";
refinedMetadata = "put[result, FileNameJoin[{resultDir, \"s13_result.wl\"}]];";
gate["unique original residual gate and output", StringCount[refinedTail, refinedGate] === 1 && StringCount[refinedTail, refinedMetadata] === 1];
refinedProgram = StringReplace[refinedTail, {
 refinedGate -> ("      residual = bounded[refineUVResidual[residual], {key, \"physical UV residual refinement\"}];\n" <> refinedGate),
 refinedMetadata -> ("result = Join[result, <|\"DispatchSourceHash\" -> FileHash[refinedSource, \"SHA256\"], \"ResidualRefinementHash\" -> FileHash[refinedProofPath, \"SHA256\"]|>];\n" <> refinedMetadata)}];
gate["complete refined assembly syntax", SyntaxQ[refinedProgram]];
ToExpression[refinedProgram, InputForm];

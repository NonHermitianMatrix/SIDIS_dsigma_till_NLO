$HistoryLength = 0;

ClearAll[
  assert, fileSHA256, compiledS12, compiledS13, compiledS23,
  compiledU1, compiledU2, compiledU3, compiledQ2
];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S11_FATAL: " <> message];
  Exit[1]
];

fileSHA256[path_String] := IntegerString[FileHash[path, "SHA256"], 16, 64];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
evaluatorPath = FileNameJoin[{checkDirectory, "s09_four_dimensional_unit_projections"}];
inputCSVPath = FileNameJoin[{checkDirectory, "s10_cut_phase_space_points.csv"}];
inputMetadataPath = FileNameJoin[{checkDirectory, "s10_cut_phase_space_metadata.json"}];
outputCSVPath = FileNameJoin[{checkDirectory, "s11_local_vs_madgraph_points.csv"}];
outputJSONPath = FileNameJoin[{checkDirectory, "s11_pointwise_comparison.json"}];

expectedEvaluatorHash =
  "bb6b23a17ab97f6db9cd511c197344a715f415c125700fa95e74c5470dc93a6a";
expectedInputCSVHash =
  "7b83e42e960649402b03a26e7dd768737d0a6cb7d724acf7aee2a7602f5d0441";
expectedInputMetadataHash =
  "086a3809c90d24f66aea6f29648c950a37fd9955fe9987f3e9368c6f6020c824";

assert[fileSHA256[evaluatorPath] === expectedEvaluatorHash,
  "the accepted S09 evaluator hash is invalid"];
assert[fileSHA256[inputCSVPath] === expectedInputCSVHash,
  "the accepted S10 CSV hash is invalid"];
assert[fileSHA256[inputMetadataPath] === expectedInputMetadataHash,
  "the accepted S10 metadata hash is invalid"];
assert[! FileExistsQ[outputCSVPath] && ! FileExistsQ[outputJSONPath],
  "an S11 output already exists"];

evaluator = Quiet[Check[Get[evaluatorPath], $Failed]];
assert[
  AssociationQ[evaluator] && evaluator["Status"] === "Complete" &&
    evaluator["Stage"] === "HqqbarFourDimensionalEvaluator-v1" &&
    evaluator["CompiledBenchmark"]["CompilationTarget"] === "WVM" &&
    TrueQ[evaluator["CompiledBenchmark"]["Passed"]],
  "the S09 evaluator metadata is invalid"
];
unitProjections = evaluator["UnitCouplingProjections"];
assert[
  AssociationQ[unitProjections] && Keys[unitProjections] === {"Pg", "PPP"},
  "the S09 evaluator projection schema is invalid"
];

metadata = Quiet[Check[Import[inputMetadataPath, "RawJSON"], $Failed]];
assert[
  AssociationQ[metadata] && metadata["status"] === "complete" &&
    metadata["stage"] === "HqqbarFiniteCutMadGraphSample-v1",
  "the S10 metadata did not load as the accepted stage"
];

rawCSV = Quiet[Check[Import[inputCSVPath, "CSV"], $Failed]];
expectedHeader = {
  "s12", "s13", "s23", "u1", "u2", "u3", "Q2",
  "madgraph_azimuthal_average"
};
assert[
  ListQ[rawCSV] && Length[rawCSV] > 1 && First[rawCSV] === expectedHeader,
  "the S10 CSV header or payload is invalid"
];
data = Rest[rawCSV];
assert[
  Length[data] === metadata["accepted_events"] &&
    Dimensions[data] === {metadata["accepted_events"], 8} &&
    MatrixQ[data, MachineNumberQ],
  "the S10 CSV row count, dimensions, or numeric type is invalid"
];

compiledBody = {
  unitProjections["Pg"], unitProjections["PPP"]
} /. {
  Global`s12 -> compiledS12,
  Global`s13 -> compiledS13,
  Global`s23 -> compiledS23,
  Global`u1 -> compiledU1,
  Global`u2 -> compiledU2,
  Global`u3 -> compiledU3,
  Global`q2Symbolic -> compiledQ2
};

Print["S11_STAGE: compiling the accepted S09 projections to WVM"];
compileTiming = AbsoluteTiming[
  compiledEvaluator = Compile[
    {
      {compiledS12, _Real}, {compiledS13, _Real}, {compiledS23, _Real},
      {compiledU1, _Real}, {compiledU2, _Real}, {compiledU3, _Real},
      {compiledQ2, _Real}
    },
    Evaluate[compiledBody],
    CompilationTarget -> "WVM",
    RuntimeOptions -> "Speed",
    CompilationOptions -> {"ExpressionOptimization" -> True}
  ];
][[1]];
assert[Head[compiledEvaluator] === CompiledFunction,
  "the S11 WVM evaluator did not compile"];

invariantRows = data[[All, 1 ;; 7]];
madGraphValues = data[[All, 8]];
Print["S11_STAGE: evaluating ", Length[invariantRows], " common-bin rows"];
evaluationTiming = AbsoluteTiming[
  unitProjectionValues = Apply[compiledEvaluator, #] & /@ invariantRows;
][[1]];
assert[
  Dimensions[unitProjectionValues] === {Length[invariantRows], 2} &&
    MatrixQ[unitProjectionValues, MachineNumberQ],
  "the compiled evaluator returned an invalid array"
];

alphaS = metadata["alpha_s"];
alphaEMInverse = 132.507;
electricCoupling = Sqrt[4.0 Pi/alphaEMInverse];
strongCoupling = Sqrt[4.0 Pi alphaS];
projectionCouplingFactor = electricCoupling^2 strongCoupling^4;
physicalPg = projectionCouplingFactor unitProjectionValues[[All, 1]];
physicalPPP = projectionCouplingFactor unitProjectionValues[[All, 2]];

sHatValues = Total /@ invariantRows[[All, 1 ;; 3]];
q2Values = invariantRows[[All, 7]];
xHatValues = q2Values/(sHatValues + q2Values);
f1Values = -physicalPg/2.0 + 2.0 xHatValues^2 physicalPPP/q2Values;
f2Values = -xHatValues physicalPg + 12.0 xHatValues^3 physicalPPP/q2Values;

sValue = metadata["s_gev2"];
leptonicPPPOverPDotQ =
  2.0 sValue (sValue - sHatValues - q2Values)/(sHatValues + q2Values);
hadronicLeptonicContractions =
  2.0 q2Values f1Values + leptonicPPPOverPDotQ f2Values;
localValues =
  (1.0/2.0) (4.0/9.0) electricCoupling^2 *
    hadronicLeptonicContractions/q2Values^2;

assert[
  VectorQ[localValues, MachineNumberQ] &&
    Min[localValues] > 0.0,
  "the local matrix array contains a nonfinite or nonpositive value"
];

signedDifferences = localValues - madGraphValues;
relativeDifferences = MapThread[
  Abs[#1 - #2]/Max[Abs[#1], Abs[#2]] &,
  {localValues, madGraphValues}
];
maximumRelativeDifference = Max[relativeDifferences];
meanRelativeDifference = Mean[relativeDifferences];
medianRelativeDifference = Median[relativeDifferences];
quantile99RelativeDifference = Quantile[relativeDifferences, 99/100];
maximumAbsoluteDifference = Max[Abs[signedDifferences]];

Print["S11_MAX_RELATIVE_DIFFERENCE=", maximumRelativeDifference];
Print["S11_MEAN_RELATIVE_DIFFERENCE=", meanRelativeDifference];
Print["S11_MEDIAN_RELATIVE_DIFFERENCE=", medianRelativeDifference];
Print["S11_99PCT_RELATIVE_DIFFERENCE=", quantile99RelativeDifference];
assert[maximumRelativeDifference < 2 10^-9,
  "a common-bin point exceeds the maximum relative-difference tolerance"];
assert[quantile99RelativeDifference < 2 10^-11,
  "the 99th-percentile relative difference exceeds tolerance"];

outputHeader = Join[
  expectedHeader,
  {"local_projected_matrix_element", "signed_difference", "relative_difference"}
];
outputRows = MapThread[
  Join[#1, {#2, #3, #4}] &,
  {data, localValues, signedDifferences, relativeDifferences}
];
outputCSVTemporary = outputCSVPath <> ".tmp." <> ToString[$ProcessID];
Export[outputCSVTemporary, Prepend[outputRows, outputHeader], "CSV"];
assert[FileExistsQ[outputCSVTemporary] && FileByteCount[outputCSVTemporary] > 0,
  "the S11 CSV temporary write failed"];
RenameFile[outputCSVTemporary, outputCSVPath];

summary = <|
  "stage" -> "HqqbarFiniteCutPointwiseComparison-v1",
  "status" -> "complete",
  "common_bin_rows" -> Length[data],
  "compile_seconds" -> compileTiming,
  "evaluation_seconds" -> evaluationTiming,
  "evaluations_per_second" -> Length[data]/evaluationTiming,
  "maximum_relative_difference" -> maximumRelativeDifference,
  "mean_relative_difference" -> meanRelativeDifference,
  "median_relative_difference" -> medianRelativeDifference,
  "relative_difference_99th_percentile" -> quantile99RelativeDifference,
  "maximum_absolute_difference" -> maximumAbsoluteDifference,
  "all_local_values_positive" -> True,
  "input_sha256" -> <|
    "s09_four_dimensional_unit_projections" -> expectedEvaluatorHash,
    "s10_cut_phase_space_points.csv" -> expectedInputCSVHash,
    "s10_cut_phase_space_metadata.json" -> expectedInputMetadataHash
  |>,
  "source_sha256" -> fileSHA256[ExpandFileName[$InputFileName]],
  "output_csv_sha256" -> fileSHA256[outputCSVPath],
  "checks" -> <|
    "input_hashes_exact" -> True,
    "row_count_exact" -> True,
    "wvm_compile_and_shape_valid" -> True,
    "all_local_values_finite_positive" -> True,
    "maximum_relative_difference_below_2e-9" -> True,
    "99th_percentile_relative_difference_below_2e-11" -> True
  |>
|>;
outputJSONTemporary = outputJSONPath <> ".tmp." <> ToString[$ProcessID];
Export[outputJSONTemporary, summary, "RawJSON"];
assert[FileExistsQ[outputJSONTemporary] && FileByteCount[outputJSONTemporary] > 0,
  "the S11 JSON temporary write failed"];
RenameFile[outputJSONTemporary, outputJSONPath];

Print["S11_OUTPUT_CSV_SHA256=", summary["output_csv_sha256"]];
Print["S11_SUCCESS"];
Exit[0];

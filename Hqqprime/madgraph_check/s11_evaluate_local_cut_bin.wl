$HistoryLength = 0;

ClearAll[
  assert, fileSHA256, relativeDifference,
  parseScientificDecimal, parameterValue,
  compiledS12, compiledS13, compiledS23,
  compiledU1, compiledU2, compiledU3, compiledQ2,
  s11S, s11SHat, s11Q2, s11EllDotP,
  s11EllPrimeDotP, s11PDotQ
];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S11_FATAL: " <> message];
  Exit[1]
];

fileSHA256[path_String] := IntegerString[
  FileHash[path, "SHA256"],
  16,
  64
];

relativeDifference[first_, second_] := If[
  TrueQ[first === second],
  0,
  Abs[first - second]/Max[Abs[first], Abs[second]]
];

parseScientificDecimal[token_String] := Module[
  {
    normalized, sign, exponentParts, mantissa, exponent,
    decimalParts, integerPart, fractionalPart, digits
  },
  normalized = ToLowerCase[StringTrim[token]];
  assert[
    StringMatchQ[
      normalized,
      RegularExpression["[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[ed][+-]?[0-9]+)?"]
    ],
    "parameter-card number has an unsupported format: " <> token
  ];
  sign = 1;
  If[StringStartsQ[normalized, "+"], normalized = StringDrop[normalized, 1]];
  If[StringStartsQ[normalized, "-"],
    sign = -1;
    normalized = StringDrop[normalized, 1]
  ];
  exponentParts = StringSplit[normalized, RegularExpression["[ed]"]];
  assert[MemberQ[{1, 2}, Length[exponentParts]],
    "parameter-card exponent split failed"];
  mantissa = First[exponentParts];
  exponent = If[
    Length[exponentParts] === 2,
    ToExpression[Last[exponentParts]],
    0
  ];
  decimalParts = StringSplit[mantissa, ".", All];
  assert[MemberQ[{1, 2}, Length[decimalParts]],
    "parameter-card mantissa split failed"];
  integerPart = If[First[decimalParts] === "", "0", First[decimalParts]];
  fractionalPart = If[Length[decimalParts] === 2, Last[decimalParts], ""];
  digits = FromDigits[integerPart <> fractionalPart];
  sign digits 10^(exponent - StringLength[fractionalPart])
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
evaluatorPath = FileNameJoin[{
  checkDirectory, "s09_four_dimensional_physical_projections"
}];
inputCSVPath = FileNameJoin[{
  checkDirectory, "s10_cut_phase_space_points.csv"
}];
inputMetadataPath = FileNameJoin[{
  checkDirectory, "s10_cut_phase_space_metadata.json"
}];
parameterCardPath = FileNameJoin[{
  checkDirectory, "generated_process", "Cards", "param_card.dat"
}];
outputCSVPath = FileNameJoin[{
  checkDirectory, "s11_local_vs_madgraph_points.csv"
}];
outputJSONPath = FileNameJoin[{
  checkDirectory, "s11_pointwise_comparison.json"
}];
programPath = ExpandFileName[$InputFileName];

expectedEvaluatorHash =
  "51cb470c5309e06a8122dc48612078967a13b06710ff2b0784e553f755165722";
expectedInputCSVHash =
  "acffeddd2c9c5d0da793cf192648dc5f8d093a7265d9b3d6234df7656e81ffdb";
expectedInputMetadataHash =
  "ac6a208789613ffc39a2eca5a9c7a6ee3017d75e1388a6ca68252aeb30721350";
expectedParameterCardHash =
  "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64";

assert[fileSHA256[evaluatorPath] === expectedEvaluatorHash,
  "accepted S09 evaluator hash is invalid"];
assert[fileSHA256[inputCSVPath] === expectedInputCSVHash,
  "accepted S10 CSV hash is invalid"];
assert[fileSHA256[inputMetadataPath] === expectedInputMetadataHash,
  "accepted S10 metadata hash is invalid"];
assert[fileSHA256[parameterCardPath] === expectedParameterCardHash,
  "accepted generated parameter-card hash is invalid"];
assert[
  ! FileExistsQ[outputCSVPath] && ! FileExistsQ[outputJSONPath],
  "an S11 output already exists"
];

evaluator = Quiet[Check[Get[evaluatorPath], $Failed]];
assert[
  AssociationQ[evaluator] && evaluator["Status"] === "Complete" &&
    evaluator["Stage"] === "HqqprimeFourDimensionalEvaluator-v1" &&
    evaluator["CompiledBenchmark", "CompilationTarget"] === "WVM" &&
    TrueQ[evaluator["CompiledBenchmark", "Passed"]] &&
    And @@ Values[evaluator["Checks"]],
  "S09 evaluator metadata is invalid"
];
unitProjections = evaluator["UnitCouplingPhysicalProjections"];
assert[
  AssociationQ[unitProjections] && Keys[unitProjections] === {"Pg", "PPP"},
  "S09 physical projection schema is invalid"
];

metadata = Quiet[Check[Import[inputMetadataPath, "RawJSON"], $Failed]];
assert[
  AssociationQ[metadata] && metadata["status"] === "complete" &&
    metadata["stage"] === "HqqprimeFiniteCutMadGraphSample-v1" &&
    metadata["csv_sha256"] === expectedInputCSVHash,
  "S10 metadata did not load as the accepted stage"
];

rawCSV = Quiet[Check[Import[inputCSVPath, "CSV"], $Failed]];
expectedHeader = {
  "s12", "s13", "s23", "u1", "u2", "u3", "Q2",
  "madgraph_azimuthal_average"
};
assert[
  ListQ[rawCSV] && Length[rawCSV] > 1 && First[rawCSV] === expectedHeader,
  "S10 CSV header or payload is invalid"
];
data = Rest[rawCSV];
assert[
  Length[data] === metadata["accepted_events"] &&
    Dimensions[data] === {metadata["accepted_events"], 8} &&
    MatrixQ[data, MachineNumberQ],
  "S10 CSV row count, dimensions, or numeric type is invalid"
];

parameterLines = Import[parameterCardPath, "Lines"];
parameterValue[tag_String] := Module[{matches},
  matches = Flatten @ StringCases[
    parameterLines,
    RegularExpression[
      "^\\s*[0-9]+\\s+([-+0-9.eEdD]+)\\s+#\\s*" <> tag <>
        "(?:\\s|$)"
    ] -> "$1"
  ];
  assert[Length[matches] === 1,
    "parameter-card tag is missing or duplicated: " <> tag];
  parseScientificDecimal[First[matches]]
];
alphaS = parameterValue["aS"];
alphaEMInverse = parameterValue["aEWM1"];
assert[Abs[N[alphaS] - metadata["alpha_s"]] < 10^-15,
  "S10 alpha_s differs from the current parameter card"];

compiledBody = {
  unitProjections["Pg"],
  unitProjections["PPP"]
} /. {
  Global`s12 -> compiledS12,
  Global`s13 -> compiledS13,
  Global`s23 -> compiledS23,
  Global`u1 -> compiledU1,
  Global`u2 -> compiledU2,
  Global`u3 -> compiledU3
};

Print["S11_STAGE: compiling accepted S09 physical projections to WVM"];
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
  "S11 WVM evaluator did not compile"];

invariantRows = data[[All, 1 ;; 7]];
madGraphValues = data[[All, 8]];
Print["S11_STAGE: evaluating ", Length[invariantRows], " identical rows"];
evaluationTiming = AbsoluteTiming[
  unitProjectionValues = Apply[compiledEvaluator, #] & /@ invariantRows;
][[1]];
assert[
  Dimensions[unitProjectionValues] === {Length[invariantRows], 2} &&
    MatrixQ[unitProjectionValues, MachineNumberQ],
  "compiled evaluator returned an invalid array"
];

electricCoupling = Sqrt[4.0 Pi/N[alphaEMInverse]];
strongCoupling = Sqrt[4.0 Pi * N[alphaS]];
projectionCouplingFactor = electricCoupling^2 * strongCoupling^4;
physicalPg = projectionCouplingFactor * unitProjectionValues[[All, 1]];
physicalPPP = projectionCouplingFactor * unitProjectionValues[[All, 2]];

sHatValues = Total /@ invariantRows[[All, 1 ;; 3]];
q2Values = invariantRows[[All, 7]];
xHatValues = q2Values/(sHatValues + q2Values);
f1Values = -physicalPg/2.0 +
  2.0 * xHatValues^2 * physicalPPP/q2Values;
f2Values = -xHatValues * physicalPg +
  12.0 * xHatValues^3 * physicalPPP/q2Values;

(* Derive the lepton scalar products from s=(ell+p)^2,
   shat=(p+q)^2, and q=ell-ellPrime. *)
leptonicSolutions = Solve[
  {
    2 * s11EllDotP == s11S,
    -s11Q2 + 2 * s11PDotQ == s11SHat,
    s11EllPrimeDotP == s11EllDotP - s11PDotQ
  },
  {s11EllDotP, s11EllPrimeDotP, s11PDotQ}
];
assert[Length[leptonicSolutions] === 1,
  "leptonic scalar-product definitions did not solve uniquely"];
leptonicPPPOverPDotQExpression = FullSimplify[
  4 * s11EllDotP * s11EllPrimeDotP/s11PDotQ /.
    First[leptonicSolutions]
];
sValue = metadata["s_gev2"];
leptonicPPPOverPDotQ = leptonicPPPOverPDotQExpression /. {
  s11S -> sValue,
  s11SHat -> sHatValues,
  s11Q2 -> q2Values
};
hadronicLeptonicContractions =
  2.0 * q2Values * f1Values + leptonicPPPOverPDotQ * f2Values;
localValues = electricCoupling^2 *
  hadronicLeptonicContractions/q2Values^2;

assert[
  VectorQ[localValues, MachineNumberQ] && Min[localValues] > 0.0,
  "local matrix array contains a nonfinite or nonpositive value"
];

signedDifferences = localValues - madGraphValues;
relativeDifferences = MapThread[
  relativeDifference,
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
assert[
  maximumRelativeDifference < 2 10^-9,
  "a common-bin point exceeds the maximum relative-difference tolerance"
];
assert[
  quantile99RelativeDifference < 2 10^-11,
  "the 99th-percentile relative difference exceeds tolerance"
];

outputHeader = Join[
  expectedHeader,
  {
    "local_projected_matrix_element",
    "signed_difference",
    "relative_difference"
  }
];
outputRows = MapThread[
  Join[#1, {#2, #3, #4}] &,
  {data, localValues, signedDifferences, relativeDifferences}
];
outputCSVTemporary = outputCSVPath <> ".tmp." <> ToString[$ProcessID];
assert[! FileExistsQ[outputCSVTemporary],
  "stale S11 CSV temporary exists"];
Export[outputCSVTemporary, Prepend[outputRows, outputHeader], "CSV"];
assert[
  FileExistsQ[outputCSVTemporary] && FileByteCount[outputCSVTemporary] > 0,
  "S11 CSV temporary write failed"
];
RenameFile[outputCSVTemporary, outputCSVPath];

checks = <|
  "input_hashes_exact" -> True,
  "row_count_and_order_exact" -> True,
  "wvm_compile_and_shape_valid" -> True,
  "parameter_card_couplings_derived" -> True,
  "leptonic_ratio_derived_from_definitions" -> True,
  "physical_charge_weights_not_reapplied" -> True,
  "all_local_values_finite_positive" -> True,
  "maximum_relative_difference_below_2e-9" -> True,
  "99th_percentile_relative_difference_below_2e-11" -> True
|>;
summary = <|
  "stage" -> "HqqprimeFiniteCutPointwiseComparison-v1",
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
  "normalization" -> <|
    "s09_physical_charge_combination_consumed" -> True,
    "hadronic_coupling_factor" -> "EL^2 g_s^4",
    "electron_side_factor" -> "EL^2/Q^4",
    "extra_charge_or_symmetry_factor" -> "none"
  |>,
  "derived_leptonic_ratio" ->
    ToString[InputForm[leptonicPPPOverPDotQExpression]],
  "input_sha256" -> <|
    "s09_four_dimensional_physical_projections" -> expectedEvaluatorHash,
    "s10_cut_phase_space_points.csv" -> expectedInputCSVHash,
    "s10_cut_phase_space_metadata.json" -> expectedInputMetadataHash,
    "param_card.dat" -> expectedParameterCardHash
  |>,
  "source_sha256" -> fileSHA256[programPath],
  "output_csv_sha256" -> fileSHA256[outputCSVPath],
  "checks" -> checks
|>;
outputJSONTemporary = outputJSONPath <> ".tmp." <> ToString[$ProcessID];
assert[! FileExistsQ[outputJSONTemporary],
  "stale S11 JSON temporary exists"];
Export[outputJSONTemporary, summary, "RawJSON"];
assert[
  FileExistsQ[outputJSONTemporary] && FileByteCount[outputJSONTemporary] > 0,
  "S11 JSON temporary write failed"
];
reloadedSummary = Quiet[Check[
  Import[outputJSONTemporary, "RawJSON"],
  $Failed
]];
assert[
  AssociationQ[reloadedSummary] &&
    reloadedSummary["status"] === "complete" &&
    reloadedSummary["common_bin_rows"] === Length[data] &&
    reloadedSummary["output_csv_sha256"] === fileSHA256[outputCSVPath] &&
    And @@ Values[reloadedSummary["checks"]],
  "S11 temporary JSON failed reload validation"
];
RenameFile[outputJSONTemporary, outputJSONPath];

Print["S11_OUTPUT_CSV_SHA256=", summary["output_csv_sha256"]];
Print["S11_SUCCESS"];
Exit[0];

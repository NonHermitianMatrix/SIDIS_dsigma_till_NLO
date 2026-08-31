$HistoryLength = 0;
$RecursionLimit = 100000;

Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, finiteNumberQ, minkowskiDot, invariantSquare,
  momentumVector, inversePropagator, evaluateDenominators,
  evaluateScalar, relativeDifference, parseScientificDecimal,
  parameterValue
];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S07_FATAL: " <> message];
  Exit[1]
];

finiteNumberQ[value_] :=
  NumberQ[value] &&
    FreeQ[value, Indeterminate | ComplexInfinity | DirectedInfinity[_]];

minkowskiDot[first_List, second_List] :=
  first[[1]] second[[1]] -
    Sum[first[[index]] second[[index]], {index, 2, 4}];
invariantSquare[momentum_List] := minkowskiDot[momentum, momentum];

relativeDifference[first_, second_] := If[
  TrueQ[first === second],
  0,
  N[Abs[first - second]/Max[Abs[first], Abs[second]], 25]
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
  exponent = If[Length[exponentParts] === 2,
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
copiedS01Path = FileNameJoin[{checkDirectory, "upstream_copies", "s01_result"}];
copiedS06Path = FileNameJoin[{checkDirectory, "upstream_copies", "s06_result"}];
copiedS07Path = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];
madGraphPath = FileNameJoin[{checkDirectory, "s05_bridge_validation.json"}];
directSourcePath = FileNameJoin[{checkDirectory, "s04_direct_madgraph_reference.f90"}];
parameterCardPath = FileNameJoin[{
  checkDirectory, "generated_process", "Cards", "param_card.dat"
}];
outputPath = FileNameJoin[{
  checkDirectory, "s07_local_tensor_and_projections.json"
}];
programPath = ExpandFileName[$InputFileName];

expectedHashes = <|
  copiedS01Path ->
    "f9dc6222b793830691c2a82db1d2ce045b2cb92ebd2dacc21948382adf3fa4be",
  copiedS06Path ->
    "dd1ccc91960f3a37b4acc397acc90f91da64340a79dd89132cdf4fcd9f5616e3",
  copiedS07Path ->
    "94bcbf6259f59d67dad3051f60f31041475fcd61d96a9fd1e31b473bd8550197",
  madGraphPath ->
    "4c2539090384363c6be3906f8d34258fd35cf8e053095940614754af1bc6d52e",
  directSourcePath ->
    "d74129339f483b94dde95c2f802283550a863a832da14ca8899ec62d0656184d"
|>;

KeyValueMap[
  Function[{path, expectedHash},
    assert[FileExistsQ[path], "required input is missing: " <> path];
    assert[
      IntegerString[FileHash[path, "SHA256"], 16, 64] === expectedHash,
      "input hash mismatch: " <> path
    ]
  ],
  expectedHashes
];
assert[FileExistsQ[parameterCardPath], "generated parameter card is missing"];
assert[! FileExistsQ[outputPath], "S07 output already exists"];

Print["S07_STAGE: loading copied Hgg tensors and projections"];
s01 = Quiet[Check[Get[copiedS01Path], $Failed]];
s06 = Quiet[Check[Get[copiedS06Path], $Failed]];
s07 = Quiet[Check[Get[copiedS07Path], $Failed]];
madGraph = Quiet[Check[Import[madGraphPath, "RawJSON"], $Failed]];

assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Channel"] === "Hgg only",
  "copied S01 result did not load as accepted"
];
assert[
  AssociationQ[s06] && s06["Status"] === "Complete" &&
    s06["Channel"] === "Hgg only",
  "copied S06 result did not load as accepted"
];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Channel"] === "Hgg only",
  "copied S07 result did not load as accepted"
];
assert[
  AssociationQ[madGraph] && madGraph["Status"] === "Complete" &&
    madGraph["StageVersion"] === "HggMadGraphBridgeValidation-v1" &&
    And @@ Values[madGraph["Checks"]],
  "accepted MadGraph validation did not load as complete"
];
assert[
  IntegerString[FileHash[parameterCardPath, "SHA256"], 16, 64] ===
    madGraph["SHA256", "ParameterCard"],
  "generated parameter-card hash differs from accepted S05"
];

projectorKeys = {"Pg", "PPP"};
tensors = s06[
  "SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hgg;q_qbar"
];
projections = s07[
  "ScalarProjections",
  "NLOReal_OAlphaS2",
  "Hgg;q_qbar"
];
assert[
  tensors =!= $Failed && tensors =!= 0,
  "copied S06 Hgg tensor schema is invalid"
];
assert[
  AssociationQ[projections] && Keys[projections] === projectorKeys,
  "copied S07 Hgg projector schema is invalid"
];

representativeCharge =
  madGraph["CopiedLocalMetadata", "f3_charge_numerator"]/
    madGraph["CopiedLocalMetadata", "f3_charge_denominator"];
assert[
  representativeCharge === 2/3 &&
    madGraph["CopiedLocalMetadata", "final_identity_divisor"] === 1,
  "current Hgg representative charge or final identity is invalid"
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
alphaEMInverse = parameterValue["aEWM1"];
alphaS = parameterValue["aS"];
electricCoupling = Sqrt[4 Pi/alphaEMInverse];
strongCoupling = Sqrt[4 Pi alphaS];

rootThree = Sqrt[3];
outgoingEnergy = 250;
incomingElectron = {500, 0, 0, 500};
incomingGluon = {500, 0, 0, -500};
outgoingElectron = outgoingEnergy {
  1, 1/rootThree, 1/rootThree, 1/rootThree
};
outgoingK1 = outgoingEnergy {
  1, 1/rootThree, -1/rootThree, -1/rootThree
};
outgoingK2 = outgoingEnergy {
  1, -1/rootThree, 1/rootThree, -1/rootThree
};
outgoingK3 = outgoingEnergy {
  1, -1/rootThree, -1/rootThree, 1/rootThree
};
photonMomentum = incomingElectron - outgoingElectron;

momentumRules = {
  p -> incomingGluon,
  q -> photonMomentum,
  k1 -> outgoingK1,
  k2 -> outgoingK2,
  k3 -> outgoingK3,
  ellIn -> incomingElectron,
  ellOut -> outgoingElectron
};

q2Value = -invariantSquare[photonMomentum];
sHatValue = invariantSquare[incomingGluon + photonMomentum];
s12Value = invariantSquare[outgoingK1 + outgoingK2];
s13Value = invariantSquare[outgoingK1 + outgoingK3];
s23Value = invariantSquare[outgoingK2 + outgoingK3];
t1Value = invariantSquare[photonMomentum - outgoingK1];
t2Value = invariantSquare[photonMomentum - outgoingK2];
t3Value = invariantSquare[photonMomentum - outgoingK3];
u1Value = invariantSquare[incomingGluon - outgoingK1];
u2Value = invariantSquare[incomingGluon - outgoingK2];
u3Value = invariantSquare[incomingGluon - outgoingK3];

assert[
  Simplify[sHatValue - s12Value - s13Value - s23Value] === 0,
  "three-body invariant sum failed"
];
assert[
  q2Value > 0 && sHatValue > 0 &&
    And @@ Thread[{s12Value, s13Value, s23Value} > 0] &&
    And @@ Thread[{u1Value, u2Value, u3Value} < 0],
  "reference point is outside the physical region"
];
assert[
  Abs[N[-q2Value, 17] - madGraph["PhotonQ2"]] < 10^-8,
  "local reference point differs from accepted S04/S05 photon virtuality"
];

kinematicRules = {
  Q2 -> q2Value,
  sHat -> sHatValue,
  s12 -> s12Value,
  s13 -> s13Value,
  s23 -> s23Value,
  t1 -> t1Value,
  t2 -> t2Value,
  t3 -> t3Value,
  u1 -> u1Value,
  u2 -> u2Value,
  u3 -> u3Value
};

physicalRulesBeforeContraction = {
  epsilon -> 0,
  ScaleMu -> 1,
  CA -> 3,
  CF -> 4/3,
  SUNN -> 3,
  FeynCalc`SMP["g_s"] -> strongCoupling,
  FeynCalc`FCGV["EL"] -> electricCoupling
};

momentumVector[expression_] := Module[{answer},
  answer = Expand[expression] /. momentumRules;
  assert[
    VectorQ[answer, NumericQ] && Length[answer] === 4,
    "a propagator momentum did not map to a numerical four-vector"
  ];
  answer
];

inversePropagator[
    FeynCalc`PropagatorDenominator[
      coefficient_. FeynCalc`Momentum[expression_, dimension_], mass_
    ]
  ] := Module[{vector, denominator},
  vector = coefficient momentumVector[expression];
  denominator = FullSimplify[invariantSquare[vector] - mass^2];
  assert[
    ! TrueQ[PossibleZeroQ[denominator]],
    "reference point lies on a propagator pole"
  ];
  1/denominator
];

inversePropagator[other_] := (
  Print["S07_DIAGNOSTIC_UNMAPPED_PROPAGATOR_HEAD=", Head[other]];
  assert[False, "an unsupported propagator denominator was encountered"];
  0
);

evaluateDenominators[expression_] := expression /.
  HoldPattern[FeynCalc`FeynAmpDenominator[arguments__]] :>
    Times @@ (inversePropagator /@ {arguments});

evaluateScalar[expression_, label_String] := Module[{answer},
  answer = expression /. D -> 4;
  answer = Quiet[Check[N[answer, 40], $Failed]];
  If[! finiteNumberQ[answer],
    Print["S07_DIAGNOSTIC_LABEL=", label];
    Print["S07_DIAGNOSTIC_HEAD=", Head[answer]];
    Print["S07_DIAGNOSTIC_LEAF_COUNT=", LeafCount[answer]];
    If[
      IntegerQ[LeafCount[answer]] && LeafCount[answer] <= 100,
      Print["S07_DIAGNOSTIC_SMALL_RESIDUAL=", InputForm[answer]]
    ];
  ];
  assert[finiteNumberQ[answer], label <> " did not become finite and numeric"];
  assert[Abs[Im[answer]] < 10^-25, label <> " retained an imaginary part"];
  Re[answer]
];

FeynCalc`FCClearScalarProducts[];
momentumSymbols = {p, q, k1, k2, k3, ellIn, ellOut};
momentumVectors = momentumSymbols /. momentumRules;
Do[
  With[
    {
      left = momentumSymbols[[first]],
      right = momentumSymbols[[second]],
      value = minkowskiDot[
        momentumVectors[[first]], momentumVectors[[second]]
      ]
    },
    FeynCalc`SPD[left, right] = value;
    FeynCalc`SP[left, right] = value;
  ],
  {first, Length[momentumSymbols]},
  {second, first, Length[momentumSymbols]}
];

muIndex = FeynCalc`LorentzIndex[s05Mu, D];
nuIndex = FeynCalc`LorentzIndex[s05Nu, D];
leptonicTensor = 2 (
  FeynCalc`Pair[FeynCalc`Momentum[ellIn, D], muIndex]
    FeynCalc`Pair[FeynCalc`Momentum[ellOut, D], nuIndex] +
  FeynCalc`Pair[FeynCalc`Momentum[ellIn, D], nuIndex]
    FeynCalc`Pair[FeynCalc`Momentum[ellOut, D], muIndex] -
  FeynCalc`Pair[
    FeynCalc`Momentum[ellIn, D],
    FeynCalc`Momentum[ellOut, D]
  ] FeynCalc`Pair[muIndex, nuIndex]
);
pgProjector = FeynCalc`Pair[muIndex, nuIndex];

comparisonTolerance = 3 10^-10;
Print["S07_STAGE: reducing sole Hgg tensor"];
reducedTensor = evaluateDenominators[tensors] /.
  kinematicRules /. physicalRulesBeforeContraction;

leptonContraction = Quiet[Check[
  FeynCalc`Contract[leptonicTensor reducedTensor],
  $Failed
]];
assert[leptonContraction =!= $Failed, "Hgg lepton contraction failed"];
physicalLeptonContraction = evaluateScalar[
  leptonContraction,
  "Hgg lepton contraction"
];

tensorPg = Quiet[Check[
  FeynCalc`Contract[pgProjector reducedTensor],
  $Failed
]];
assert[tensorPg =!= $Failed, "Hgg fresh Pg contraction failed"];
freshPgValue = evaluateScalar[tensorPg, "Hgg fresh S06 Pg"];

tensorPPP = Quiet[Check[
  FeynCalc`Contract[
    FeynCalc`Pair[FeynCalc`Momentum[p, D], nuIndex]
      FeynCalc`Contract[
        FeynCalc`Pair[FeynCalc`Momentum[p, D], muIndex] reducedTensor
      ]
  ],
  $Failed
]];
assert[tensorPPP =!= $Failed, "Hgg fresh PPP contraction failed"];
freshPPPValue = evaluateScalar[tensorPPP, "Hgg fresh S06 PPP"];

copiedPgValue = evaluateScalar[
  evaluateDenominators[projections["Pg"]] /.
    kinematicRules /. physicalRulesBeforeContraction,
  "Hgg copied S07 Pg"
];
copiedPPPValue = evaluateScalar[
  evaluateDenominators[projections["PPP"]] /.
    kinematicRules /. physicalRulesBeforeContraction,
  "Hgg copied S07 PPP"
];
pgRelativeDifference = relativeDifference[freshPgValue, copiedPgValue];
pppRelativeDifference = relativeDifference[freshPPPValue, copiedPPPValue];
assert[
  pgRelativeDifference < comparisonTolerance,
  "copied S07 Pg differs from fresh S06 contraction"
];
assert[
  pppRelativeDifference < comparisonTolerance,
  "copied S07 PPP differs from fresh S06 contraction"
];
localTensorMatrix = N[
  electricCoupling^2 physicalLeptonContraction/q2Value^2,
  30
];
madGraphIdentityCorrection = madGraph["GeneratedFinalIdentityDivisor"];
madGraphFixedOrientation = madGraph["BridgeMatrixElement"];
madGraphLabeledFixedOrientation =
  madGraphIdentityCorrection madGraphFixedOrientation;
tensorMadGraphRelative = relativeDifference[
  localTensorMatrix,
  madGraphLabeledFixedOrientation
];
Print["S07_DIAGNOSTIC_LOCAL_TENSOR_MATRIX=", InputForm[localTensorMatrix]];
Print[
  "S07_DIAGNOSTIC_MADGRAPH_LABELED_MATRIX=",
  InputForm[madGraphLabeledFixedOrientation]
];
Print[
  "S07_DIAGNOSTIC_LOCAL_TO_MADGRAPH_RATIO=",
  InputForm[N[localTensorMatrix/madGraphLabeledFixedOrientation, 30]]
];
assert[
  tensorMadGraphRelative < comparisonTolerance,
  "physical copied-S06 tensor differs from fixed-orientation MadGraph"
];

physicalPgValue = copiedPgValue;
physicalPPPValue = copiedPPPValue;
xHatValue = q2Value/(sHatValue + q2Value);
f1Value = -physicalPgValue/2 +
  2 xHatValue^2 physicalPPPValue/q2Value;
f2Value = -xHatValue physicalPgValue +
  12 xHatValue^3 physicalPPPValue/q2Value;
leptonicPPP = 4 minkowskiDot[incomingElectron, incomingGluon] *
  minkowskiDot[outgoingElectron, incomingGluon];
projectedLeptonContraction =
  2 q2Value f1Value +
    leptonicPPP/minkowskiDot[incomingGluon, photonMomentum] f2Value;
projectedLocalMatrix = N[
  electricCoupling^2 projectedLeptonContraction/q2Value^2,
  30
];
projectedSingleOrientationDifference = relativeDifference[
  projectedLocalMatrix,
  madGraphLabeledFixedOrientation
];

Print["S07_STAGE: physical Hgg up-representative reconstruction"];
Print["S07_F3_CHARGE=", InputForm[representativeCharge]];
Print["S07_LOCAL_TENSOR_MATRIX=", InputForm[localTensorMatrix]];
Print[
  "S07_MADGRAPH_LABELED_MATRIX=",
  InputForm[madGraphLabeledFixedOrientation]
];
Print[
  "S07_TENSOR_MADGRAPH_RELATIVE=",
  InputForm[tensorMadGraphRelative]
];
Print["S07_PHYSICAL_PG=", InputForm[physicalPgValue]];
Print["S07_PHYSICAL_PPP=", InputForm[physicalPPPValue]];

projectionOutput = <|
  "lepton_contraction" -> N[physicalLeptonContraction, 17],
  "fresh_s06_pg" -> N[freshPgValue, 17],
  "copied_s07_pg" -> N[copiedPgValue, 17],
  "pg_relative_difference" -> N[pgRelativeDifference, 17],
  "fresh_s06_ppp" -> N[freshPPPValue, 17],
  "copied_s07_ppp" -> N[copiedPPPValue, 17],
  "ppp_relative_difference" -> N[pppRelativeDifference, 17]
|>;

output = <|
  "stage" -> "HggLocalTensorAndProjectionValidation-v1",
  "status" -> "complete",
  "program_sha256" ->
    IntegerString[FileHash[programPath, "SHA256"], 16, 64],
  "reference_point" -> <|
    "sqrt_s" -> 1000.0,
    "q2" -> N[q2Value, 17],
    "s_hat" -> N[sHatValue, 17],
    "s12" -> N[s12Value, 17],
    "s13" -> N[s13Value, 17],
    "s23" -> N[s23Value, 17],
    "u1" -> N[u1Value, 17],
    "u2" -> N[u2Value, 17],
    "u3" -> N[u3Value, 17]
  |>,
  "parameter_card" -> <|
    "alpha_s" -> N[alphaS, 17],
    "alpha_em_inverse" -> N[alphaEMInverse, 17],
    "sha256" -> madGraph["SHA256", "ParameterCard"]
  |>,
  "physical_representative" -> <|
    "incoming" -> "g",
    "fragmenting" -> "g",
    "spectator_pair" -> {"u", "ubar"},
    "f3_charge_derived_by_s05" -> N[representativeCharge, 17]
  |>,
  "projection_components" -> projectionOutput,
  "fixed_orientation" -> <|
    "copied_s06_physical_matrix" -> N[localTensorMatrix, 17],
    "madgraph_matrix" -> N[madGraphFixedOrientation, 17],
    "madgraph_final_identity_correction" -> madGraphIdentityCorrection,
    "madgraph_labeled_matrix" -> N[madGraphLabeledFixedOrientation, 17],
    "relative_difference" -> N[tensorMadGraphRelative, 17]
  |>,
  "projected" -> <|
    "physical_pg" -> N[physicalPgValue, 17],
    "physical_ppp" -> N[physicalPPPValue, 17],
    "f1_from_copied_s07" -> N[f1Value, 17],
    "f2_from_copied_s07" -> N[f2Value, 17],
    "copied_s07_projected_local_matrix" -> N[projectedLocalMatrix, 17],
    "single_orientation_difference_not_acceptance_test" ->
      N[projectedSingleOrientationDifference, 17]
  |>,
  "checks" -> <|
    "sole_hgg_tensor_used_without_extra_charge_weight" -> True,
    "representative_charge_derived_by_s05_from_smqcd" -> True,
    "parameter_card_couplings_parsed_from_current_generated_process" -> True,
    "copied_s06_tensor_matches_fixed_orientation_madgraph" -> True,
    "copied_s07_pg_matches_fresh_s06_contraction" -> True,
    "copied_s07_ppp_matches_fresh_s06_contraction" -> True,
    "unit_final_state_identity_correction_consumed_from_s05" -> True,
    "projected_single_orientation_not_used_as_acceptance_test" -> True
  |>,
  "normalization" -> <|
    "incoming_gluon_spin_color_average" ->
      "already present in copied S06/S07",
    "incoming_electron_spin_average" ->
      "included in L_munu",
    "quark_electromagnetic_charge" ->
      "SMQCD F3 charge already present in copied S06/S07",
    "added_electron_side" -> "e^2/Q^4",
    "final_state_identity" ->
      "generated final identity correction consumed from accepted S05"
  |>,
  "sha256" -> Join[
    Association @ KeyValueMap[
      Function[{path, expectedHash}, FileNameTake[path] -> expectedHash],
      expectedHashes
    ],
    <|"param_card.dat" -> madGraph["SHA256", "ParameterCard"]|>
  ]
|>;

temporaryPath = outputPath <> ".tmp." <> ToString[$ProcessID];
assert[! FileExistsQ[temporaryPath], "stale S07 temporary output exists"];
Export[temporaryPath, output, "RawJSON"];
assert[
  FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
  "S07 temporary JSON write failed"
];
reloadedOutput = Quiet[Check[Import[temporaryPath, "RawJSON"], $Failed]];
assert[
  AssociationQ[reloadedOutput] &&
    reloadedOutput["status"] === "complete" &&
    And @@ Values[reloadedOutput["checks"]],
  "S07 temporary JSON reload validation failed"
];
RenameFile[temporaryPath, outputPath];
assert[FileExistsQ[outputPath], "S07 atomic output rename failed"];

Print["S07_SUCCESS"];
Print["S07_OUTPUT=", outputPath];
Exit[0];

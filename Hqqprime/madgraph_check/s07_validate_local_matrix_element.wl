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
    "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b",
  copiedS06Path ->
    "92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607",
  copiedS07Path ->
    "b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026",
  madGraphPath ->
    "95191bfbfa5b804f2e38cc0837cc908198fe1d92ba0e605ad56fd12bf4a8384d",
  directSourcePath ->
    "65a118edbf42d13998b3644cfa11f5204af1ca6cd8ce6bca23da8f4608a78503"
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

Print["S07_STAGE: loading copied Hqqprime tensors and projections"];
s01 = Quiet[Check[Get[copiedS01Path], $Failed]];
s06 = Quiet[Check[Get[copiedS06Path], $Failed]];
s07 = Quiet[Check[Get[copiedS07Path], $Failed]];
madGraph = Quiet[Check[Import[madGraphPath, "RawJSON"], $Failed]];

assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqqprimeS01-v1",
  "copied S01 result did not load as accepted"
];
assert[
  AssociationQ[s06] && s06["Status"] === "Complete" &&
    s06["Stage"] === "HqqprimeS06-v1",
  "copied S06 result did not load as accepted"
];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqqprimeS07-v1",
  "copied S07 result did not load as accepted"
];
assert[
  AssociationQ[madGraph] && madGraph["Status"] === "Complete" &&
    madGraph["StageVersion"] === "HqqprimeMadGraphBridgeValidation-v1" &&
    And @@ Values[madGraph["Checks"]],
  "accepted MadGraph validation did not load as complete"
];
assert[
  IntegerString[FileHash[parameterCardPath, "SHA256"], 16, 64] ===
    madGraph["SHA256", "ParameterCard"],
  "generated parameter-card hash differs from accepted S05"
];

chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
projectorKeys = {"Pg", "PPP"};
tensors = s06["Tensors", "SpinColorAveragedChargeTensors"];
projections = s07[
  "ScalarProjections",
  "NLOReal_OAlphaS2",
  "Hqqprime;q_qbarPrime"
];
assert[
  AssociationQ[tensors] && Keys[tensors] === chargeKeys,
  "copied S06 charge-tensor schema is invalid"
];
assert[
  AssociationQ[projections] && Keys[projections] === projectorKeys &&
    And @@ (
      AssociationQ[projections[#]] && Keys[projections[#]] === chargeKeys & /@
        projectorKeys
    ),
  "copied S07 projector/charge schema is invalid"
];

physicalRepresentative = s01["RepresentativeChargeAssignments", "up_up"];
assert[AssociationQ[physicalRepresentative],
  "copied S01 up/up charge assignment is missing"];
incomingCharge = physicalRepresentative["IncomingCharge"];
primeCharge = physicalRepresentative["PrimeCharge"];
assert[
  incomingCharge === s01["ModelChargeCoefficients", "UpType"] &&
    primeCharge === s01["ModelChargeCoefficients", "UpType"],
  "current incoming-up/prime-charm charges were not derived from copied S01"
];
chargeWeights = <|
  "IncomingChargeSquared" -> incomingCharge^2,
  "PrimeChargeSquared" -> primeCharge^2,
  "MixedIncomingPrimeCharge" -> incomingCharge primeCharge
|>;
assert[
  s06["ChargeBookkeeping", "SeparatedTensorKeys"] === chargeKeys &&
    s06["ChargeBookkeeping", "CoefficientTensorsRemainChargeFree"] === True &&
    s06["SymmetryBookkeeping", "NontrivialSymmetryFactorRequired"] === False,
  "copied S06 charge or final-state bookkeeping is inconsistent"
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
incomingQuark = {500, 0, 0, -500};
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
  p -> incomingQuark,
  q -> photonMomentum,
  k1 -> outgoingK1,
  k2 -> outgoingK2,
  k3 -> outgoingK3,
  ellIn -> incomingElectron,
  ellOut -> outgoingElectron
};

q2Value = -invariantSquare[photonMomentum];
sHatValue = invariantSquare[incomingQuark + photonMomentum];
s12Value = invariantSquare[outgoingK1 + outgoingK2];
s13Value = invariantSquare[outgoingK1 + outgoingK3];
s23Value = invariantSquare[outgoingK2 + outgoingK3];
t1Value = invariantSquare[photonMomentum - outgoingK1];
t2Value = invariantSquare[photonMomentum - outgoingK2];
t3Value = invariantSquare[photonMomentum - outgoingK3];
u1Value = invariantSquare[incomingQuark - outgoingK1];
u2Value = invariantSquare[incomingQuark - outgoingK2];
u3Value = invariantSquare[incomingQuark - outgoingK3];

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
leptonContractions = <||>;
freshPgValues = <||>;
copiedPgValues = <||>;
pgRelativeDifferences = <||>;
freshPPPValues = <||>;
copiedPPPValues = <||>;
pppRelativeDifferences = <||>;

Do[
  Print["S07_STAGE: reducing charge tensor " <> chargeKey];
  reducedTensor = evaluateDenominators[tensors[chargeKey]] /.
    kinematicRules /. physicalRulesBeforeContraction;

  leptonContraction = Quiet[Check[
    FeynCalc`Contract[leptonicTensor reducedTensor],
    $Failed
  ]];
  assert[leptonContraction =!= $Failed,
    chargeKey <> " lepton contraction failed"];
  leptonContractions[chargeKey] = evaluateScalar[
    leptonContraction,
    chargeKey <> " lepton contraction"
  ];

  tensorPg = Quiet[Check[
    FeynCalc`Contract[pgProjector reducedTensor],
    $Failed
  ]];
  assert[tensorPg =!= $Failed, chargeKey <> " fresh Pg contraction failed"];
  freshPgValues[chargeKey] = evaluateScalar[
    tensorPg,
    chargeKey <> " fresh S06 Pg"
  ];

  tensorPPP = Quiet[Check[
    FeynCalc`Contract[
      FeynCalc`Pair[FeynCalc`Momentum[p, D], nuIndex]
        FeynCalc`Contract[
          FeynCalc`Pair[FeynCalc`Momentum[p, D], muIndex] reducedTensor
        ]
    ],
    $Failed
  ]];
  assert[tensorPPP =!= $Failed,
    chargeKey <> " fresh PPP contraction failed"];
  freshPPPValues[chargeKey] = evaluateScalar[
    tensorPPP,
    chargeKey <> " fresh S06 PPP"
  ];

  copiedPgValues[chargeKey] = evaluateScalar[
    evaluateDenominators[projections["Pg", chargeKey]] /.
      kinematicRules /. physicalRulesBeforeContraction,
    chargeKey <> " copied S07 Pg"
  ];
  copiedPPPValues[chargeKey] = evaluateScalar[
    evaluateDenominators[projections["PPP", chargeKey]] /.
      kinematicRules /. physicalRulesBeforeContraction,
    chargeKey <> " copied S07 PPP"
  ];
  pgRelativeDifferences[chargeKey] = relativeDifference[
    freshPgValues[chargeKey],
    copiedPgValues[chargeKey]
  ];
  pppRelativeDifferences[chargeKey] = relativeDifference[
    freshPPPValues[chargeKey],
    copiedPPPValues[chargeKey]
  ];
  assert[
    pgRelativeDifferences[chargeKey] < comparisonTolerance,
    chargeKey <> " copied S07 Pg differs from fresh S06 contraction"
  ];
  assert[
    pppRelativeDifferences[chargeKey] < comparisonTolerance,
    chargeKey <> " copied S07 PPP differs from fresh S06 contraction"
  ];
  Print[
    "S07_CHARGE_RESULT: " <> chargeKey <>
      " Pg=" <> ToString[InputForm[pgRelativeDifferences[chargeKey]]] <>
      " PPP=" <> ToString[InputForm[pppRelativeDifferences[chargeKey]]]
  ];

  Clear[reducedTensor, leptonContraction, tensorPg, tensorPPP];
  Share[];
,
  {chargeKey, chargeKeys}
];

physicalLeptonContraction = Total[
  chargeWeights[#] leptonContractions[#] & /@ chargeKeys
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
assert[
  tensorMadGraphRelative < comparisonTolerance,
  "physical copied-S06 tensor differs from fixed-orientation MadGraph"
];

physicalPgValue = Total[
  chargeWeights[#] copiedPgValues[#] & /@ chargeKeys
];
physicalPPPValue = Total[
  chargeWeights[#] copiedPPPValues[#] & /@ chargeKeys
];
xHatValue = q2Value/(sHatValue + q2Value);
f1Value = -physicalPgValue/2 +
  2 xHatValue^2 physicalPPPValue/q2Value;
f2Value = -xHatValue physicalPgValue +
  12 xHatValue^3 physicalPPPValue/q2Value;
leptonicPPP = 4 minkowskiDot[incomingElectron, incomingQuark] *
  minkowskiDot[outgoingElectron, incomingQuark];
projectedLeptonContraction =
  2 q2Value f1Value +
    leptonicPPP/minkowskiDot[incomingQuark, photonMomentum] f2Value;
projectedLocalMatrix = N[
  electricCoupling^2 projectedLeptonContraction/q2Value^2,
  30
];
projectedSingleOrientationDifference = relativeDifference[
  projectedLocalMatrix,
  madGraphLabeledFixedOrientation
];

Print["S07_STAGE: physical up/charm reconstruction"];
Print["S07_INCOMING_CHARGE=", InputForm[incomingCharge]];
Print["S07_PRIME_CHARGE=", InputForm[primeCharge]];
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

chargeComponentOutput = AssociationMap[
  Function[key,
    <|
      "physical_charge_weight" -> N[chargeWeights[key], 17],
      "lepton_contraction" -> N[leptonContractions[key], 17],
      "fresh_s06_pg" -> N[freshPgValues[key], 17],
      "copied_s07_pg" -> N[copiedPgValues[key], 17],
      "pg_relative_difference" -> N[pgRelativeDifferences[key], 17],
      "fresh_s06_ppp" -> N[freshPPPValues[key], 17],
      "copied_s07_ppp" -> N[copiedPPPValues[key], 17],
      "ppp_relative_difference" -> N[pppRelativeDifferences[key], 17]
    |>
  ],
  chargeKeys
];

output = <|
  "stage" -> "HqqprimeLocalTensorAndProjectionValidation-v1",
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
    "incoming" -> "u",
    "prime_fragmenting" -> "c",
    "incoming_charge_from_copied_s01" -> N[incomingCharge, 17],
    "prime_charge_from_copied_s01" -> N[primeCharge, 17]
  |>,
  "charge_components" -> chargeComponentOutput,
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
    "all_three_charge_tensors_retained_until_physical_assembly" -> True,
    "physical_charges_derived_from_copied_s01" -> True,
    "parameter_card_couplings_parsed_from_current_generated_process" -> True,
    "copied_s06_tensor_matches_fixed_orientation_madgraph" -> True,
    "all_copied_s07_pg_match_fresh_s06_contractions" -> True,
    "all_copied_s07_ppp_match_fresh_s06_contractions" -> True,
    "distinct_final_state_identity_correction_consumed_from_s05" -> True,
    "projected_single_orientation_not_used_as_acceptance_test" -> True
  |>,
  "normalization" -> <|
    "incoming_quark_spin_color_average" ->
      "already present in copied S06/S07",
    "incoming_electron_spin_average" ->
      "included in L_munu",
    "quark_electromagnetic_charge_weights" ->
      "derived from copied S01 and applied once",
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

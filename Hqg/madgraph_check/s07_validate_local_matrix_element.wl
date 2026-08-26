$HistoryLength = 0;
$RecursionLimit = 100000;

Needs["FeynCalc`"];
$FCAdvice = False;
$PrePrint = .;

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
      RegularExpression[
        "[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[ed][+-]?[0-9]+)?"
      ]
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
    "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198",
  copiedS06Path ->
    "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55",
  copiedS07Path ->
    "c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6",
  madGraphPath ->
    "28dc6ca1c25643ace19fe5f2dc3257a0759ff08a49cb04458d37702d13356b74",
  directSourcePath ->
    "78ce3f1fe6cf346066eabcca5f800fc3afdf8aab82bc959174a924c3590119e1"
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

Print["S07_STAGE: loading copied Hqg tensor and projections"];
s01 = Quiet[Check[Get[copiedS01Path], $Failed]];
s06 = Quiet[Check[Get[copiedS06Path], $Failed]];
s07 = Quiet[Check[Get[copiedS07Path], $Failed]];
madGraph = Quiet[Check[Import[madGraphPath, "RawJSON"], $Failed]];

assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqgS01-v3",
  "copied S01 result did not load as accepted"
];
assert[
  AssociationQ[s06] && s06["Status"] === "Complete" &&
    s06["Stage"] === "HqgS06-v4",
  "copied S06 result did not load as accepted"
];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v5",
  "copied S07 result did not load as accepted"
];
assert[
  AssociationQ[madGraph] && madGraph["Status"] === "Complete" &&
    madGraph["StageVersion"] === "HqgMadGraphBridgeValidation-v1" &&
    And @@ Values[madGraph["Checks"]],
  "accepted MadGraph validation did not load as complete"
];
assert[
  IntegerString[FileHash[parameterCardPath, "SHA256"], 16, 64] ===
    madGraph["SHA256", "ParameterCard"],
  "generated parameter-card hash differs from accepted S05"
];

tensor = Quiet[Check[
  s06["SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hqg;qg"],
  $Failed
]];
projections = Quiet[Check[
  s07["ScalarProjections", "NLOReal_OAlphaS2", "Hqg;qg"],
  $Failed
]];
projectorDefinitions = Lookup[s07, "ProjectorDefinitions", $Failed];
assert[tensor =!= $Failed, "copied S06 Hqg real tensor is missing"];
assert[
  AssociationQ[projections] && Keys[projections] === {"Pg", "PPP"},
  "copied S07 projection schema is invalid"
];
assert[
  AssociationQ[projectorDefinitions] &&
    Keys[projectorDefinitions] === {"Pg", "PPP"},
  "copied S07 projector-definition schema is invalid"
];
assert[
  s06["ElectricChargeNormalization"] === s01["ElectricChargeNormalization"] &&
    s07["ElectricChargeNormalization"] === s01["ElectricChargeNormalization"],
  "copied charge-normalization lineage is inconsistent"
];
assert[
  TrueQ[s06["Checks", "RealFinalGluonsUseDMinus2PhysicalAxialSums"]] &&
    TrueQ[s06["Checks", "FragmentingGluonIsK1"]] &&
    TrueQ[s07["Checks", "FragmentingGluonIsInheritedK1"]],
  "copied physical real-gluon state convention is not accepted"
];

referenceCharge = Together[
  s01["ElectricChargeNormalization", "ReferenceCharge"]
];
stripFactor = Together[
  s01["ElectricChargeNormalization", "AmplitudeStripFactor"]
];
assert[
  Together[referenceCharge stripFactor] === 1,
  "copied charge and strip factor are not exact reciprocals"
];
chargeSquared = referenceCharge^2;

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
  Abs[N[-q2Value, 17] - First[madGraph["PhotonQ2Values"]]] < 10^-8,
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
      IntegerQ[LeafCount[answer]] && LeafCount[answer] <= 40,
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

photonIndices = s06["PhotonIndices"];
assert[
  ListQ[photonIndices] && Length[photonIndices] === 2 &&
    DuplicateFreeQ[photonIndices],
  "copied photon indices are not a unique pair"
];
muIndex = FeynCalc`LorentzIndex[photonIndices[[1]], D];
nuIndex = FeynCalc`LorentzIndex[photonIndices[[2]], D];

leptonicTrace = (1/2) FeynCalc`DiracTrace[
  FeynCalc`DiracGamma[FeynCalc`Momentum[ellOut, D]] .
  FeynCalc`DiracGamma[muIndex] .
  FeynCalc`DiracGamma[FeynCalc`Momentum[ellIn, D]] .
  FeynCalc`DiracGamma[nuIndex]
];
leptonicTensor = Quiet[Check[
  FeynCalc`DiracSimplify[
    leptonicTrace,
    FeynCalc`DiracTraceEvaluate -> True
  ],
  $Failed
]];
assert[
  leptonicTensor =!= $Failed && FreeQ[leptonicTensor, _FeynCalc`DiracTrace],
  "spin-averaged electron Dirac trace did not evaluate"
];

qSquared = FeynCalc`SPD[q, q];
pDotQ = FeynCalc`SPD[p, q];
transverseMetric =
  FeynCalc`Pair[muIndex, nuIndex] -
    FeynCalc`Pair[FeynCalc`Momentum[q, D], muIndex] *
      FeynCalc`Pair[FeynCalc`Momentum[q, D], nuIndex]/qSquared;
transversePMu =
  FeynCalc`Pair[FeynCalc`Momentum[p, D], muIndex] -
    pDotQ FeynCalc`Pair[FeynCalc`Momentum[q, D], muIndex]/qSquared;
transversePNu =
  FeynCalc`Pair[FeynCalc`Momentum[p, D], nuIndex] -
    pDotQ FeynCalc`Pair[FeynCalc`Momentum[q, D], nuIndex]/qSquared;
azimuthIndependentBasis = {transverseMetric, transversePMu transversePNu};
projectorMatrix = Table[
  evaluateScalar[
    FeynCalc`Contract[
      projectorDefinitions[projectorName]
        azimuthIndependentBasis[[basisIndex]]
    ],
    "projector-basis element " <> projectorName <> "/" <>
      ToString[basisIndex]
  ],
  {projectorName, {"Pg", "PPP"}},
  {basisIndex, Length[azimuthIndependentBasis]}
];
assert[
  ! TrueQ[PossibleZeroQ[Det[projectorMatrix]]],
  "copied projector matrix is singular on the transverse tensor basis"
];

Print["S07_STAGE: evaluating copied Hqg tensor at the reference point"];
reducedTensor = evaluateDenominators[tensor] /.
  kinematicRules /. physicalRulesBeforeContraction;
leptonContraction = Quiet[Check[
  FeynCalc`Contract[leptonicTensor reducedTensor],
  $Failed
]];
assert[leptonContraction =!= $Failed, "electron-hadron contraction failed"];
leptonContractionValue = evaluateScalar[
  leptonContraction,
  "copied S06 electron-hadron contraction"
];

freshProjectionValues = AssociationMap[
  Function[projectorName,
    contracted = Quiet[Check[
      FeynCalc`Contract[
        (projectorDefinitions[projectorName] /. D -> 4) reducedTensor
      ],
      $Failed
    ]];
    assert[contracted =!= $Failed,
      "fresh " <> projectorName <> " contraction failed"];
    evaluateScalar[contracted, "fresh S06 " <> projectorName]
  ],
  {"Pg", "PPP"}
];
copiedProjectionValues = AssociationMap[
  Function[projectorName,
    evaluateScalar[
      evaluateDenominators[projections[projectorName]] /.
        kinematicRules /. physicalRulesBeforeContraction,
      "copied S07 " <> projectorName
    ]
  ],
  {"Pg", "PPP"}
];
projectionRelativeDifferences = AssociationMap[
  Function[projectorName,
    relativeDifference[
      freshProjectionValues[projectorName],
      copiedProjectionValues[projectorName]
    ]
  ],
  {"Pg", "PPP"}
];
comparisonTolerance = 3 10^-10;
assert[
  Max[Values[projectionRelativeDifferences]] < comparisonTolerance,
  "a copied S07 projection differs from the fresh S06 contraction"
];

localTensorMatrix = N[
  chargeSquared electricCoupling^2 leptonContractionValue/q2Value^2,
  30
];
madGraphFixedOrientation = First[madGraph["BridgeMatrixElements"]];
generatedIdentityDivisor = madGraph["GeneratedFinalIdentityDivisor"];
identityCandidates = DeleteDuplicates[
  {1, generatedIdentityDivisor, 1/generatedIdentityDivisor}
];
identityCandidateComparisons = Map[
  Function[correction,
    {
      correction,
      relativeDifference[
        localTensorMatrix,
        correction madGraphFixedOrientation
      ]
    }
  ],
  identityCandidates
];
acceptedIdentityCandidates = Select[
  identityCandidateComparisons,
  Last[#] < comparisonTolerance &
];
assert[
  Length[acceptedIdentityCandidates] === 1,
  "generated identity candidates do not select one unique local normalization"
];
identityCorrection = First[First[acceptedIdentityCandidates]];
madGraphLabeledFixedOrientation =
  identityCorrection madGraphFixedOrientation;
tensorMadGraphRelative = relativeDifference[
  localTensorMatrix,
  madGraphLabeledFixedOrientation
];

basisCoefficients = LinearSolve[
  projectorMatrix,
  Lookup[copiedProjectionValues, {"Pg", "PPP"}]
];
projectorReconstructionResidual =
  projectorMatrix . basisCoefficients -
    Lookup[copiedProjectionValues, {"Pg", "PPP"}];
assert[
  Max[Abs[N[projectorReconstructionResidual, 25]]] < 10^-20,
  "projector-basis linear solve did not reconstruct Pg/PPP"
];
reconstructedAzimuthIndependentTensor =
  basisCoefficients . azimuthIndependentBasis;
projectedLeptonContraction = evaluateScalar[
  FeynCalc`Contract[
    leptonicTensor reconstructedAzimuthIndependentTensor
  ],
  "Pg/PPP reconstructed electron-hadron contraction"
];
projectedLocalMatrix = N[
  chargeSquared electricCoupling^2 projectedLeptonContraction/q2Value^2,
  30
];

Print["S07_REFERENCE_CHARGE=", InputForm[referenceCharge]];
Print["S07_STRIP_FACTOR=", InputForm[stripFactor]];
Print["S07_FRESH_PG_RELATIVE=", InputForm[projectionRelativeDifferences["Pg"]]];
Print["S07_FRESH_PPP_RELATIVE=", InputForm[projectionRelativeDifferences["PPP"]]];
Print["S07_IDENTITY_CANDIDATES=", InputForm[identityCandidateComparisons]];
Print["S07_SELECTED_IDENTITY_CORRECTION=", InputForm[identityCorrection]];
Print["S07_LOCAL_TENSOR_MATRIX=", InputForm[localTensorMatrix]];
Print["S07_MADGRAPH_LABELED_MATRIX=", InputForm[madGraphLabeledFixedOrientation]];
Print["S07_TENSOR_MADGRAPH_RELATIVE=", InputForm[tensorMadGraphRelative]];
Print["S07_PROJECTED_LOCAL_MATRIX=", InputForm[projectedLocalMatrix]];

identityCandidateOutput = Map[
  <|
    "correction" -> N[First[#], 17],
    "relative_difference" -> N[Last[#], 17]
  |> &,
  identityCandidateComparisons
];
output = <|
  "stage" -> "HqgLocalTensorAndProjectionValidation-v1",
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
    "fragmenting" -> "g(k1)",
    "reference_charge_from_copied_s01" -> N[referenceCharge, 17],
    "amplitude_strip_factor_from_copied_s01" -> N[stripFactor, 17]
  |>,
  "fresh_projection_checks" -> <|
    "fresh_s06_pg" -> N[freshProjectionValues["Pg"], 17],
    "copied_s07_pg" -> N[copiedProjectionValues["Pg"], 17],
    "pg_relative_difference" -> N[projectionRelativeDifferences["Pg"], 17],
    "fresh_s06_ppp" -> N[freshProjectionValues["PPP"], 17],
    "copied_s07_ppp" -> N[copiedProjectionValues["PPP"], 17],
    "ppp_relative_difference" -> N[projectionRelativeDifferences["PPP"], 17]
  |>,
  "fixed_orientation" -> <|
    "copied_s06_labeled_matrix" -> N[localTensorMatrix, 17],
    "madgraph_matrix" -> N[madGraphFixedOrientation, 17],
    "generated_final_identity_divisor" -> generatedIdentityDivisor,
    "identity_candidate_comparisons" -> identityCandidateOutput,
    "selected_identity_correction" -> N[identityCorrection, 17],
    "madgraph_labeled_matrix" -> N[madGraphLabeledFixedOrientation, 17],
    "relative_difference" -> N[tensorMadGraphRelative, 17]
  |>,
  "projected" -> <|
    "physical_pg" -> N[chargeSquared copiedProjectionValues["Pg"], 17],
    "physical_ppp" -> N[chargeSquared copiedProjectionValues["PPP"], 17],
    "projector_matrix" -> N[projectorMatrix, 17],
    "basis_coefficients" -> N[basisCoefficients, 17],
    "projector_reconstruction_max_residual" ->
      If[
        TrueQ[
          PossibleZeroQ[Max[Abs[projectorReconstructionResidual]]]
        ],
        0,
        N[Max[Abs[projectorReconstructionResidual]], 17]
      ],
    "copied_s07_projected_local_matrix" -> N[projectedLocalMatrix, 17]
  |>,
  "checks" -> <|
    "physical_charge_and_strip_factor_derived_from_copied_s01" -> True,
    "physical_real_gluon_state_inherited_from_copied_s06" -> True,
    "electron_tensor_derived_by_spin_averaged_dirac_trace" -> True,
    "parameter_card_couplings_parsed_from_current_generated_process" -> True,
    "copied_s06_tensor_matches_fixed_orientation_madgraph" -> True,
    "copied_s07_pg_matches_fresh_s06_contraction" -> True,
    "copied_s07_ppp_matches_fresh_s06_contraction" -> True,
    "unique_identity_correction_selected_from_generated_divisor" -> True,
    "pg_ppp_reconstruction_derived_by_linear_solve" -> True,
    "projected_value_deferred_to_four_angle_s08_acceptance" -> True
  |>,
  "normalization" -> <|
    "incoming_quark_spin_color_average" ->
      "already present in copied S06/S07",
    "incoming_electron_spin_average" ->
      "derived in the program from one-half DiracTrace",
    "representative_charge" ->
      "derived from copied S01 and squared exactly once",
    "added_electron_side" -> "second electromagnetic vertex and photon propagator",
    "final_state_identity" ->
      "uniquely selected by local/generated pointwise equality from S05-derived candidates"
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

$HistoryLength = 0;
$RecursionLimit = 200000;
$MaxExtraPrecision = 10000;
$LoadAddOns = {};

Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  hqqV2MGRequire, hqqV2MGFiniteNumberQ, hqqV2MGHash,
  hqqV2MGMinkowskiDot, hqqV2MGInvariantSquare,
  hqqV2MGRelativeDifference, hqqV2MGRationalRecord,
  hqqV2MGMomentumVector, hqqV2MGInversePropagator,
  hqqV2MGEvaluateDenominators, hqqV2MGEvaluateScalar,
  hqqV2MGNumberString
];

hqqV2MGRequire[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S04_FATAL: " <> message];
  Exit[1]
];

hqqV2MGFiniteNumberQ[value_] :=
  NumberQ[value] &&
    FreeQ[value, Indeterminate | ComplexInfinity | DirectedInfinity[_]];

hqqV2MGHash[path_String] :=
  FileHash[path, "SHA256", "HexString"];

hqqV2MGMinkowskiDot[first_List, second_List] :=
  first[[1]] second[[1]] -
    Sum[first[[index]] second[[index]], {index, 2, 4}];

hqqV2MGInvariantSquare[momentum_List] :=
  hqqV2MGMinkowskiDot[momentum, momentum];

hqqV2MGRelativeDifference[first_, second_] := Module[{scale},
  scale = Max[Abs[first], Abs[second]];
  If[TrueQ[PossibleZeroQ[scale]], 0, N[Abs[first - second]/scale, 25]]
];

hqqV2MGRationalRecord[record_Association, label_String] := Module[
  {numerator, denominator, answer},
  numerator = record["numerator"];
  denominator = record["denominator"];
  hqqV2MGRequire[
    IntegerQ[numerator] && IntegerQ[denominator] && denominator > 0,
    label <> " rational record is invalid"
  ];
  answer = numerator/denominator;
  hqqV2MGRequire[
    hqqV2MGRelativeDifference[N[answer, 17], record["float"]] < 10^-15,
    label <> " rational and floating records differ"
  ];
  answer
];

hqqV2MGNumberString[value_] :=
  ToString[InputForm[N[value, 17]]];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
channelDirectory = DirectoryName[checkDirectory];
sourcePath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{channelDirectory,
  "s01_generate_hqq_amplitudes.wl"}];
s01ResultPath = FileNameJoin[{channelDirectory, "s01_result.wl"}];
s02SourcePath = FileNameJoin[{channelDirectory,
  "s02_build_hqq_tensors.wl"}];
s02ResultPath = FileNameJoin[{channelDirectory, "s02_result.wl"}];
s03ProgramPath = FileNameJoin[{checkDirectory,
  "s03_evaluate_madgraph_reference.py"}];
s03ResultPath = FileNameJoin[{checkDirectory,
  "s03_madgraph_reference.json"}];
outputPath = FileNameJoin[{checkDirectory,
  "s04_local_vs_madgraph.json"}];
reportPath = FileNameJoin[{checkDirectory,
  "s04_local_vs_madgraph.md"}];

expectedHashes = <|
  s01SourcePath ->
    "5125f6f8a2c2ac7cfa44fc3b8bb437e1f5fdf26c52169d9c4991f5b35ab660d1",
  s01ResultPath ->
    "83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911",
  s02SourcePath ->
    "2559c4b388b9fcb746dcf37bebbd33731f6adf7584e749ac632e4db68854fe73",
  s02ResultPath ->
    "316c6e18b49bd7c446506fc866546d0c998f6d61cec3c3813693cbf72b735c83",
  s03ProgramPath ->
    "1e2d6ce4cafed9b1f1d00ef5f6cad936792611364d8941d50fb1e49b4d7a489b",
  s03ResultPath ->
    "90fa221e5d423109d78b1570b9cec2193b94ba2dbed2301d3455b478c6406baf"
|>;

KeyValueMap[
  Function[{path, expectedHash},
    hqqV2MGRequire[FileExistsQ[path] && FileByteCount[path] > 0,
      "required input is missing or empty: " <> path];
    hqqV2MGRequire[hqqV2MGHash[path] === expectedHash,
      "required input hash changed: " <> path]
  ],
  expectedHashes
];

hqqV2MGRequire[! FileExistsQ[outputPath] && ! FileExistsQ[reportPath],
  "canonical S04 output already exists"];
hqqV2MGRequire[
  FileNames["s04_local_vs_madgraph.*.tmp.*", checkDirectory] === {},
  "stale S04 temporary output exists"
];

Print["S04_STAGE=load and validate Hqq_v2 and MadGraph inputs"];
s01 = Quiet[Check[Get[s01ResultPath], $Failed]];
s02 = Quiet[Check[Get[s02ResultPath], $Failed]];
madGraph = Quiet[Check[Import[s03ResultPath, "RawJSON"], $Failed]];

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
hqqV2MGRequire[
  AssociationQ[s01] && s01["Stage"] === "HqqV2S01-v1" &&
    s01["ScopeTag"] === scopeTag && And @@ Values[s01["Checks"]],
  "accepted S01 schema or gates changed"
];
hqqV2MGRequire[
  AssociationQ[s02] && s02["Stage"] === "HqqV2S02-v1" &&
    s02["ScopeTag"] === scopeTag && And @@ Values[s02["Checks"]],
  "accepted S02 schema or gates changed"
];
hqqV2MGRequire[
  s01["Source", "SHA256"] === expectedHashes[s01SourcePath] &&
    s02["Source", "SHA256"] === expectedHashes[s02SourcePath] &&
    s02["S01", "SourceSHA256"] === expectedHashes[s01SourcePath] &&
    s02["S01", "ResultSHA256"] === expectedHashes[s01ResultPath],
  "accepted S01/S02 embedded provenance changed"
];
hqqV2MGRequire[
  AssociationQ[madGraph] &&
    madGraph["Stage"] === "HqqV2MadGraphS03-v1" &&
    madGraph["Status"] === "CompleteMadGraphReference" &&
    And @@ Values[madGraph["Checks"]] &&
    madGraph["Program", "SHA256"] === expectedHashes[s03ProgramPath],
  "S03 MadGraph reference is absent, stale, or incomplete"
];

expectedFamilies = {
  "Hqq;gg",
  "Hqq;q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime"
};
tensors = s02["Tensors", "Real"];
hqqV2MGRequire[
  AssociationQ[tensors] && Sort[Keys[tensors]] === Sort[expectedFamilies],
  "accepted S02 real-tensor family schema changed"
];

processList = Values[madGraph["Processes"]];
hqqV2MGRequire[
  Length[processList] === Length[expectedFamilies] &&
    And @@ (AssociationQ /@ processList),
  "S03 process coverage changed"
];
processByFamily = Association[
  (#1["family"] -> #1) & /@ processList
];
hqqV2MGRequire[
  Sort[Keys[processByFamily]] === Sort[expectedFamilies],
  "MadGraph-to-Hqq_v2 family map changed"
];
Do[
  hqqV2MGRequire[
    s01["DiagramLedger", family, "SelectedCount"] ===
      processByFamily[family]["metadata", "diagram_count"],
    family <> " FeynArts/MadGraph diagram counts differ"
  ],
  {family, expectedFamilies}
];

beamFactorRecords = DeleteDuplicates[
  (#1["metadata", "beam_helicity_average_factors"] &) /@ processList
];
hqqV2MGRequire[
  Length[beamFactorRecords] === 1 &&
    MatchQ[First[beamFactorRecords], {_Integer?Positive, _Integer?Positive}],
  "MadGraph beam-helicity factors are not common positive integers"
];
electronSpinStates = First[First[beamFactorRecords]];
quarkSpinStates = Last[First[beamFactorRecords]];
sunNValue = madGraph["InitialColorStatesFromIDEN"];
hqqV2MGRequire[IntegerQ[sunNValue] && sunNValue > 0,
  "MadGraph-derived incoming color-state count is invalid"];
hqqV2MGRequire[
  quarkSpinStates === s02["InitialStateNormalization", "InitialSpinStates"],
  "Hqq_v2 and MadGraph incoming-quark spin counts differ"
];
colorSymbol = s02["InitialStateNormalization", "InitialColorStates"];
hqqV2MGRequire[Head[colorSymbol] === Symbol,
  "S02 initial color-state object is not symbolic"];
hqqV2MGRequire[
  Together[
    s02["InitialStateNormalization", "InitialStateAverage"] /.
      colorSymbol -> sunNValue
  ] === 1/(quarkSpinStates sunNValue),
  "S02 initial-state average does not match derived spin/color states"
];
hqqV2MGRequire[
  madGraph["InitialStateAveragingDenominatorFromIDEN"] ===
    electronSpinStates quarkSpinStates sunNValue,
  "MadGraph IDEN initial-state factorization changed"
];

alphaS = hqqV2MGRationalRecord[
  madGraph["CouplingsFromParameterCard", "AlphaS"], "alpha_s"
];
alphaEMInverse = hqqV2MGRationalRecord[
  madGraph["CouplingsFromParameterCard", "AlphaEMInverse"],
  "alpha_em inverse"
];
electricCoupling = Sqrt[4 Pi/alphaEMInverse];
strongCoupling = Sqrt[4 Pi alphaS];
upCharge = s01["ChargeConvention", "UpTypeModelCharge"];
downCharge = s01["ChargeConvention", "DownTypeModelCharge"];
hqqV2MGRequire[
  Element[upCharge, Rationals] && Element[downCharge, Rationals] &&
    upCharge =!= 0 && downCharge =!= 0 &&
    Abs[upCharge] =!= Abs[downCharge],
  "S01 model-derived charge ledger is invalid"
];

Print["S04_STAGE=derive and validate common physical benchmark"];
benchmarkConstruction = madGraph["BenchmarkConstruction"];
incomingEnergy = Rationalize[
  benchmarkConstruction["incoming_energy"], 0
];
outgoingCount = benchmarkConstruction["outgoing_count"];
hqqV2MGRequire[IntegerQ[outgoingCount] && outgoingCount > 0,
  "benchmark outgoing-state count is invalid"];
outgoingEnergy = 2 incomingEnergy/outgoingCount;
hqqV2MGRequire[
  hqqV2MGRelativeDifference[
    N[outgoingEnergy, 17], benchmarkConstruction["outgoing_energy"]
  ] < 10^-15,
  "benchmark outgoing energy was not reproduced"
];

rootThree = Sqrt[3];
incomingElectron = {incomingEnergy, 0, 0, incomingEnergy};
incomingQuark = {incomingEnergy, 0, 0, -incomingEnergy};
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
momentaParticleMajor = {
  incomingElectron, incomingQuark, outgoingElectron,
  outgoingK1, outgoingK2, outgoingK3
};
hqqV2MGRequire[
  Dimensions[madGraph["MomentaParticleMajor"]] === {6, 4} &&
    Max[Abs[Flatten[
      N[momentaParticleMajor, 17] - madGraph["MomentaParticleMajor"]
    ]]] < 10^-12,
  "Mathematica and MadGraph benchmark momenta differ"
];

photonMomentum = incomingElectron - outgoingElectron;
momentumResidual = incomingElectron + incomingQuark -
  Total[{outgoingElectron, outgoingK1, outgoingK2, outgoingK3}];
massSquares = hqqV2MGInvariantSquare /@ momentaParticleMajor;
q2Value = -hqqV2MGInvariantSquare[photonMomentum];
hqqV2MGRequire[momentumResidual === {0, 0, 0, 0},
  "exact benchmark momentum conservation failed"];
hqqV2MGRequire[And @@ (PossibleZeroQ /@ massSquares),
  "exact benchmark masslessness failed"];
hqqV2MGRequire[q2Value > 0,
  "benchmark photon is not spacelike"];
hqqV2MGRequire[
  hqqV2MGRelativeDifference[
    N[-q2Value, 17], benchmarkConstruction["photon_q2"]
  ] < 10^-15,
  "Mathematica and MadGraph photon virtualities differ"
];

momentumRules = {
  p -> incomingQuark,
  q -> photonMomentum,
  k1 -> outgoingK1,
  k2 -> outgoingK2,
  k3 -> outgoingK3,
  ellIn -> incomingElectron,
  ellOut -> outgoingElectron
};
sHatValue = hqqV2MGInvariantSquare[incomingQuark + photonMomentum];
s12Value = hqqV2MGInvariantSquare[outgoingK1 + outgoingK2];
s13Value = hqqV2MGInvariantSquare[outgoingK1 + outgoingK3];
s23Value = hqqV2MGInvariantSquare[outgoingK2 + outgoingK3];
t1Value = hqqV2MGInvariantSquare[photonMomentum - outgoingK1];
t2Value = hqqV2MGInvariantSquare[photonMomentum - outgoingK2];
t3Value = hqqV2MGInvariantSquare[photonMomentum - outgoingK3];
u1Value = hqqV2MGInvariantSquare[incomingQuark - outgoingK1];
u2Value = hqqV2MGInvariantSquare[incomingQuark - outgoingK2];
u3Value = hqqV2MGInvariantSquare[incomingQuark - outgoingK3];
hqqV2MGRequire[
  Simplify[sHatValue - s12Value - s13Value - s23Value] === 0,
  "three-body invariant sum failed"
];
hqqV2MGRequire[
  q2Value > 0 && sHatValue > 0 &&
    And @@ Thread[{s12Value, s13Value, s23Value} > 0] &&
    And @@ Thread[{u1Value, u2Value, u3Value} < 0],
  "benchmark is outside the real-emission physical region"
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

hqqV2MGMomentumVector[expression_] := Module[{answer},
  answer = Expand[expression] /. momentumRules;
  hqqV2MGRequire[
    VectorQ[answer, NumericQ] && Length[answer] === 4,
    "a propagator momentum did not map to a numerical four-vector"
  ];
  answer
];

hqqV2MGInversePropagator[
  FeynCalc`PropagatorDenominator[
    coefficient_. FeynCalc`Momentum[expression_, dimension_], mass_
  ]
] := Module[{vector, denominator},
  vector = coefficient hqqV2MGMomentumVector[expression];
  denominator = FullSimplify[hqqV2MGInvariantSquare[vector] - mass^2];
  hqqV2MGRequire[! TrueQ[PossibleZeroQ[denominator]],
    "benchmark lies on a propagator pole"];
  1/denominator
];

hqqV2MGInversePropagator[other_] := (
  Print["S04_DIAGNOSTIC_UNMAPPED_PROPAGATOR=", InputForm[other]];
  hqqV2MGRequire[False,
    "an unsupported propagator denominator was encountered"];
  0
);

hqqV2MGEvaluateDenominators[expression_] := expression /.
  HoldPattern[FeynCalc`FeynAmpDenominator[arguments__]] :>
    Times @@ (hqqV2MGInversePropagator /@ {arguments});

hqqV2MGEvaluateScalar[expression_, label_String] := Module[{answer},
  answer = expression /. D -> 4;
  answer = Quiet[Check[N[answer, 40], $Failed]];
  hqqV2MGRequire[hqqV2MGFiniteNumberQ[answer],
    label <> " did not become finite and numeric"];
  hqqV2MGRequire[Abs[Im[answer]] < 10^-25,
    label <> " retained an imaginary part"];
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
      value = hqqV2MGMinkowskiDot[
        momentumVectors[[first]], momentumVectors[[second]]
      ]
    },
    FeynCalc`SPD[left, right] = value;
    FeynCalc`SP[left, right] = value
  ],
  {first, Length[momentumSymbols]},
  {second, first, Length[momentumSymbols]}
];

photonIndexSymbols = s02["PhotonIndices"];
hqqV2MGRequire[
  MatchQ[photonIndexSymbols, {_Symbol, _Symbol}] &&
    UnsameQ @@ photonIndexSymbols,
  "S02 photon-index ledger is invalid"
];
muIndex = FeynCalc`LorentzIndex[photonIndexSymbols[[1]], D];
nuIndex = FeynCalc`LorentzIndex[photonIndexSymbols[[2]], D];

Print["S04_STAGE=derive spin-averaged electron tensor with FeynCalc"];
leptonicTrace = (1/electronSpinStates) FeynCalc`DiracTrace[
  FeynCalc`DiracGamma[FeynCalc`Momentum[ellOut, D], D] .
  FeynCalc`DiracGamma[muIndex, D] .
  FeynCalc`DiracGamma[FeynCalc`Momentum[ellIn, D], D] .
  FeynCalc`DiracGamma[nuIndex, D]
];
leptonicTensor = Quiet[Check[
  FeynCalc`DiracSimplify[
    leptonicTrace,
    FeynCalc`DiracTrace -> True,
    FeynCalc`DiracTraceEvaluate -> True,
    FeynCalc`FCVerbose -> 0
  ],
  $Failed
]];
hqqV2MGRequire[
  leptonicTensor =!= $Failed &&
    FreeQ[leptonicTensor, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma] &&
    ! FreeQ[leptonicTensor, muIndex] &&
    ! FreeQ[leptonicTensor, nuIndex],
  "FeynCalc did not derive the open electron tensor"
];

physicalRules = {
  epsilon -> 0,
  colorSymbol -> sunNValue,
  Global`FAGS -> strongCoupling,
  FeynCalc`FCGV["EL"] -> electricCoupling,
  HqqV2Charge["UpType"] -> upCharge,
  HqqV2Charge["DownType"] -> downCharge
};

comparisonAbsoluteTolerance = 10^-20;
comparisonRelativeTolerance = 10^-9;
processOutputRules = {};

Do[
  Print["S04_STAGE=evaluate local tensor " <> family];
  reducedTensor = hqqV2MGEvaluateDenominators[tensors[family]] /.
    kinematicRules /. physicalRules;
  hqqV2MGRequire[
    FreeQ[reducedTensor,
      _FeynCalc`FeynAmpDenominator | HqqV2Charge | Global`FAGS |
        FeynCalc`FCGV["EL"] | colorSymbol],
    family <> " retained an unresolved denominator, coupling, charge, or color symbol"
  ];
  leptonContraction = Quiet[Check[
    FeynCalc`Contract[leptonicTensor reducedTensor],
    $Failed
  ]];
  hqqV2MGRequire[leptonContraction =!= $Failed,
    family <> " electron-tensor contraction failed"];
  contractionValue = hqqV2MGEvaluateScalar[
    leptonContraction, family <> " electron-tensor contraction"
  ];
  localMatrix = N[
    electricCoupling^2 contractionValue/q2Value^2,
    30
  ];
  hqqV2MGRequire[
    hqqV2MGFiniteNumberQ[localMatrix] && localMatrix > 0,
    family <> " local squared matrix element is not positive and finite"
  ];

  processRecord = processByFamily[family];
  madGraphRaw = processRecord["bridge_matrix_element"];
  identityCorrection =
    processRecord["metadata", "labeled_final_state_factor"];
  madGraphLabeled = identityCorrection madGraphRaw;
  hqqV2MGRequire[
    hqqV2MGRelativeDifference[
      madGraphLabeled,
      processRecord["labeled_madgraph_matrix_element"]
    ] < 10^-15,
    family <> " MadGraph labeled-state reconstruction failed"
  ];
  signedDifference = N[localMatrix - madGraphLabeled, 25];
  absoluteDifference = N[Abs[signedDifference], 25];
  relativeDifference = hqqV2MGRelativeDifference[
    localMatrix, madGraphLabeled
  ];
  toleranceAtPoint = N[
    comparisonAbsoluteTolerance + comparisonRelativeTolerance
      Max[Abs[localMatrix], Abs[madGraphLabeled]],
    25
  ];
  withinTolerance = TrueQ[absoluteDifference <= toleranceAtPoint];

  Print["S04_RESULT_FAMILY=", family];
  Print["S04_RESULT_LOCAL=", InputForm[N[localMatrix, 17]]];
  Print["S04_RESULT_MADGRAPH_LABELED=",
    InputForm[N[madGraphLabeled, 17]]];
  Print["S04_RESULT_RELATIVE_DIFFERENCE=",
    InputForm[N[relativeDifference, 17]]];
  Print["S04_RESULT_WITHIN_TOLERANCE=", withinTolerance];

  AppendTo[
    processOutputRules,
    family -> <|
      "MadGraphProcessCommand" -> processRecord["process_command"],
      "MadGraphPDGs" -> processRecord["metadata", "pdgs"],
      "DiagramCount" -> processRecord["metadata", "diagram_count"],
      "MadGraphIdentityDenominator" ->
        processRecord["metadata", "identity_denominator"],
      "LabeledFinalStateFactor" -> identityCorrection,
      "MadGraphRaw" -> N[madGraphRaw, 17],
      "MadGraphLabeled" -> N[madGraphLabeled, 17],
      "LocalHqqV2Labeled" -> N[localMatrix, 17],
      "LocalMinusMadGraph" -> N[signedDifference, 17],
      "AbsoluteDifference" -> N[absoluteDifference, 17],
      "RelativeDifference" -> N[relativeDifference, 17],
      "ToleranceAtPoint" -> N[toleranceAtPoint, 17],
      "WithinTolerance" -> withinTolerance,
      "InputTensorLeafCount" -> LeafCount[tensors[family]]
    |>
  ];

  Clear[
    reducedTensor, leptonContraction, contractionValue, localMatrix,
    processRecord, madGraphRaw, madGraphLabeled, identityCorrection,
    signedDifference, absoluteDifference, relativeDifference,
    toleranceAtPoint, withinTolerance
  ];
  Share[];
,
  {family, expectedFamilies}
];

processResults = Association[processOutputRules];
allWithinTolerance = And @@ Lookup[Values[processResults], "WithinTolerance"];
maximumAbsoluteDifference = Max[
  Lookup[Values[processResults], "AbsoluteDifference"]
];
maximumRelativeDifference = Max[
  Lookup[Values[processResults], "RelativeDifference"]
];

output = <|
  "Stage" -> "HqqV2MadGraphS04-v1",
  "Status" -> "CompleteLocalVsMadGraphRealTensorComparison",
  "Program" -> <|
    "Path" -> sourcePath,
    "SHA256" -> hqqV2MGHash[sourcePath]
  |>,
  "Inputs" -> Association @ KeyValueMap[
    Function[{path, expectedHash},
      FileNameTake[path] -> <|"Path" -> path, "SHA256" -> expectedHash|>
    ],
    expectedHashes
  ],
  "ComparisonLevel" ->
    "unintegrated fixed-orientation tree-level real squared matrix element",
  "DifferenceDirection" -> "local Hqq_v2 minus MadGraph labeled",
  "Benchmark" -> <|
    "MomentaParticleMajorExact" -> ToString[
      InputForm[momentaParticleMajor]
    ],
    "Q2" -> N[q2Value, 17],
    "sHat" -> N[sHatValue, 17],
    "s12" -> N[s12Value, 17],
    "s13" -> N[s13Value, 17],
    "s23" -> N[s23Value, 17],
    "t1" -> N[t1Value, 17],
    "t2" -> N[t2Value, 17],
    "t3" -> N[t3Value, 17],
    "u1" -> N[u1Value, 17],
    "u2" -> N[u2Value, 17],
    "u3" -> N[u3Value, 17]
  |>,
  "ToolDerivedNormalization" -> <|
    "ElectronSpinStatesFromMadGraph" -> electronSpinStates,
    "QuarkSpinStatesFromMadGraph" -> quarkSpinStates,
    "ColorStatesFromMadGraphIDEN" -> sunNValue,
    "HqqV2InitialStateAverage" -> ToString[
      InputForm[s02["InitialStateNormalization", "InitialStateAverage"]]
    ],
    "UpChargeFromHqqV2S01" -> ToString[InputForm[upCharge]],
    "DownChargeFromHqqV2S01" -> ToString[InputForm[downCharge]],
    "AlphaSFromMadGraphCard" -> N[alphaS, 17],
    "AlphaEMInverseFromMadGraphCard" -> N[alphaEMInverse, 17],
    "ElectronTensor" -> "FeynCalc Dirac trace with MadGraph-derived spin average",
    "ElectronSidePhotonFactor" -> "e^2/Q^4 derived from card coupling and benchmark Q2",
    "FinalIdentityFactors" -> AssociationMap[
      processResults[#, "LabeledFinalStateFactor"] &,
      expectedFamilies
    ]
  |>,
  "Processes" -> processResults,
  "Checks" -> <|
    "HqqV2S01AndS02HashesExact" -> True,
    "HqqV2S01AndS02GatesAccepted" -> True,
    "MadGraphS03HashExact" -> True,
    "MadGraphS03GatesAccepted" -> True,
    "AllThreeRealFamiliesCovered" -> True,
    "FeynArtsAndMadGraphDiagramCountsAgree" -> True,
    "BenchmarkMomentaAgree" -> True,
    "MomentumConservationExact" -> True,
    "MasslessnessExact" -> True,
    "PhotonSpacelike" -> True,
    "PhysicalRealEmissionRegion" -> True,
    "ElectronTensorDerivedByFeynCalc" -> True,
    "SpinColorNormalizationDerivedAndMatched" -> True,
    "ChargesReadFromHqqV2S01" -> True,
    "CouplingsReadFromMadGraphCard" -> True,
    "AllLocalValuesPositiveAndFinite" -> True
  |>,
  "Summary" -> <|
    "ComparisonCount" -> Length[processResults],
    "AllFamiliesWithinTolerance" -> allWithinTolerance,
    "MaximumAbsoluteDifference" -> N[maximumAbsoluteDifference, 17],
    "MaximumRelativeDifference" -> N[maximumRelativeDifference, 17],
    "AbsoluteTolerance" -> N[comparisonAbsoluteTolerance, 17],
    "RelativeTolerance" -> N[comparisonRelativeTolerance, 17],
    "ToleranceRule" ->
      "abs(local-MadGraph) <= 1e-20 + 1e-9 max(abs(local),abs(MadGraph))"
  |>
|>;

reportRows = Map[
  Function[family,
    StringRiffle[{
      "| " <> family,
      hqqV2MGNumberString[processResults[family, "LocalHqqV2Labeled"]],
      hqqV2MGNumberString[processResults[family, "MadGraphLabeled"]],
      hqqV2MGNumberString[processResults[family, "LocalMinusMadGraph"]],
      hqqV2MGNumberString[processResults[family, "RelativeDifference"]],
      ToString[processResults[family, "WithinTolerance"]] <> " |"
    }, " | "]
  ],
  expectedFamilies
];
report = StringRiffle[
  Join[
    {
      "# Hqq_v2 MadGraph real-tensor check",
      "",
      "Comparison level: unintegrated fixed-orientation tree-level real squared matrix elements.",
      "",
      "Signed difference: **local Hqq_v2 minus MadGraph labeled**.",
      "",
      "| Family | Local Hqq_v2 | MadGraph labeled | Difference | Relative difference | Within tolerance |",
      "|---|---:|---:|---:|---:|:---:|"
    },
    reportRows,
    {
      "",
      "Comparisons: " <> ToString[Length[processResults]] <> ".",
      "",
      "All families within tolerance: `" <>
        ToString[allWithinTolerance] <> "`.",
      "",
      "Maximum absolute difference: `" <>
        hqqV2MGNumberString[maximumAbsoluteDifference] <> "`.",
      "",
      "Maximum relative difference: `" <>
        hqqV2MGNumberString[maximumRelativeDifference] <> "`.",
      "",
      "This check does not directly test the integrated, endpoint-expanded, virtual, or MS-bar-factorized final hats."
    }
  ],
  "\n"
] <> "\n";

jsonTemporaryPath = outputPath <> ".tmp." <> ToString[$ProcessID];
reportTemporaryPath = reportPath <> ".tmp." <> ToString[$ProcessID];
hqqV2MGRequire[
  ! FileExistsQ[jsonTemporaryPath] && ! FileExistsQ[reportTemporaryPath],
  "process-specific S04 temporary output already exists"
];
Export[jsonTemporaryPath, output, "RawJSON"];
Export[reportTemporaryPath, report, "Text"];
hqqV2MGRequire[
  FileExistsQ[jsonTemporaryPath] && FileByteCount[jsonTemporaryPath] > 0 &&
    FileExistsQ[reportTemporaryPath] && FileByteCount[reportTemporaryPath] > 0,
  "S04 temporary output write failed"
];
reloadedOutput = Quiet[Check[
  Import[jsonTemporaryPath, "RawJSON"],
  $Failed
]];
hqqV2MGRequire[
  AssociationQ[reloadedOutput] &&
    reloadedOutput["Status"] ===
      "CompleteLocalVsMadGraphRealTensorComparison" &&
    reloadedOutput["Summary", "ComparisonCount"] ===
      Length[expectedFamilies] &&
    And @@ Values[reloadedOutput["Checks"]],
  "S04 temporary JSON reload validation failed"
];
RenameFile[jsonTemporaryPath, outputPath];
RenameFile[reportTemporaryPath, reportPath];
hqqV2MGRequire[
  FileExistsQ[outputPath] && FileExistsQ[reportPath],
  "S04 atomic output rename failed"
];

Print["S04_COMPARISON_COUNT=", Length[processResults]];
Print["S04_ALL_WITHIN_TOLERANCE=", allWithinTolerance];
Print["S04_MAX_ABS=", InputForm[N[maximumAbsoluteDifference, 17]]];
Print["S04_MAX_REL=", InputForm[N[maximumRelativeDifference, 17]]];
Print["S04_JSON_OUTPUT=", outputPath];
Print["S04_REPORT_OUTPUT=", reportPath];
Print["S04_SUCCESS"];
Exit[0];

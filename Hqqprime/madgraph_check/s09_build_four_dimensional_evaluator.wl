$HistoryLength = 0;

ClearAll[
  assert, atomicPutAssociation, relativeDifference,
  quadraticForm, linearInvariantSquare, invariantPropagator,
  mapDenominators, remainingSymbols, allowedSymbolSetQ,
  compiledS12, compiledS13, compiledS23,
  compiledU1, compiledU2, compiledU3, compiledQ2,
  s09DotPK1, s09DotPK2, s09DotPK3,
  s09DotK1K2, s09DotK1K3, s09DotK2K3
];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S09_FATAL: " <> message];
  Exit[1]
];

relativeDifference[first_, second_] := If[
  TrueQ[first === second],
  0,
  N[Abs[first - second]/Max[Abs[first], Abs[second]], 25]
];

atomicPutAssociation[association_Association, path_String] := Module[
  {temporaryPath, reloaded},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[path] && ! FileExistsQ[temporaryPath],
    "the evaluator result or its temporary path already exists"
  ];
  Put[association, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "the evaluator temporary write failed"
  ];
  reloaded = Quiet[Check[Get[temporaryPath], $Failed]];
  assert[
    AssociationQ[reloaded] && reloaded["Status"] === "Complete" &&
      reloaded["Stage"] === "HqqprimeFourDimensionalEvaluator-v1" &&
      And @@ Values[reloaded["Checks"]],
    "the evaluator temporary result failed reload validation"
  ];
  RenameFile[temporaryPath, path];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    "the evaluator atomic rename failed"
  ];
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
copiedS01Path = FileNameJoin[{checkDirectory, "upstream_copies", "s01_result"}];
copiedS07Path = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];
projectedPointPath = FileNameJoin[{
  checkDirectory, "s07_local_tensor_and_projections.json"
}];
azimuthalValidationPath = FileNameJoin[{
  checkDirectory, "s08_azimuthal_average_validation.json"
}];
parameterCardPath = FileNameJoin[{
  checkDirectory, "generated_process", "Cards", "param_card.dat"
}];
outputPath = FileNameJoin[{
  checkDirectory, "s09_four_dimensional_physical_projections"
}];
programPath = ExpandFileName[$InputFileName];

expectedHashes = <|
  copiedS01Path ->
    "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b",
  copiedS07Path ->
    "b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026",
  projectedPointPath ->
    "79cf7e55218025f35c601c5e08a688644347f227ecd3061aa9d95b03608b9b00",
  azimuthalValidationPath ->
    "c869f3fa105253fb7aa6994fc21c29d696260e5087cbf322a767f00083670cfe",
  parameterCardPath ->
    "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64"
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
assert[! FileExistsQ[outputPath], "S09 evaluator output already exists"];

Print["S09_STAGE: loading accepted charge-resolved projections"];
s01 = Quiet[Check[Get[copiedS01Path], $Failed]];
s07 = Quiet[Check[Get[copiedS07Path], $Failed]];
projectedPoint = Quiet[Check[
  Import[projectedPointPath, "RawJSON"],
  $Failed
]];
azimuthalValidation = Quiet[Check[
  Import[azimuthalValidationPath, "RawJSON"],
  $Failed
]];
assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqqprimeS01-v1",
  "copied S01 result did not load as accepted"
];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqqprimeS07-v1",
  "copied S07 result did not load as accepted"
];
assert[
  AssociationQ[projectedPoint] &&
    projectedPoint["status"] === "complete" &&
    projectedPoint["stage"] ===
      "HqqprimeLocalTensorAndProjectionValidation-v1" &&
    And @@ Values[projectedPoint["checks"]],
  "corrected S07 projected point did not load as accepted"
];
assert[
  AssociationQ[azimuthalValidation] &&
    azimuthalValidation["status"] === "complete" &&
    azimuthalValidation["stage"] ===
      "HqqprimeMadGraphAzimuthalAverageValidation-v1" &&
    And @@ Values[azimuthalValidation["checks"]],
  "S08 azimuthal validation did not load as accepted"
];

chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
projectorKeys = {"Pg", "PPP"};
projections = Quiet[Check[
  s07[
    "ScalarProjections",
    "NLOReal_OAlphaS2",
    "Hqqprime;q_qbarPrime"
  ],
  $Failed
]];
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
  "copied S01 physical representative is missing"];
incomingCharge = physicalRepresentative["IncomingCharge"];
primeCharge = physicalRepresentative["PrimeCharge"];
assert[
  incomingCharge === s01["ModelChargeCoefficients", "UpType"] &&
    primeCharge === s01["ModelChargeCoefficients", "UpType"],
  "physical up/charm charge assignment is invalid"
];
chargeWeights = <|
  "IncomingChargeSquared" -> incomingCharge^2,
  "PrimeChargeSquared" -> primeCharge^2,
  "MixedIncomingPrimeCharge" -> incomingCharge primeCharge
|>;

(* Derive every independent scalar product from the definitions of the
   six three-body invariants; no propagator invariant is transcribed. *)
basisMomentumSymbols = {Global`p, Global`k1, Global`k2, Global`k3};
dotVariables = {
  s09DotPK1, s09DotPK2, s09DotPK3,
  s09DotK1K2, s09DotK1K3, s09DotK2K3
};
dotMatrix = {
  {0, s09DotPK1, s09DotPK2, s09DotPK3},
  {s09DotPK1, 0, s09DotK1K2, s09DotK1K3},
  {s09DotPK2, s09DotK1K2, 0, s09DotK2K3},
  {s09DotPK3, s09DotK1K3, s09DotK2K3, 0}
};
quadraticForm[coefficients_List] := Expand[
  coefficients . dotMatrix . coefficients
];
invariantDefinitionEquations = {
  quadraticForm[{0, 1, 1, 0}] == Global`s12,
  quadraticForm[{0, 1, 0, 1}] == Global`s13,
  quadraticForm[{0, 0, 1, 1}] == Global`s23,
  quadraticForm[{1, -1, 0, 0}] == Global`u1,
  quadraticForm[{1, 0, -1, 0}] == Global`u2,
  quadraticForm[{1, 0, 0, -1}] == Global`u3
};
dotSolutions = Solve[invariantDefinitionEquations, dotVariables];
assert[Length[dotSolutions] === 1,
  "the invariant definitions did not uniquely determine scalar products"];
dotSolution = First[dotSolutions];
assert[FreeQ[Values[dotSolution], Alternatives @@ dotVariables],
  "a scalar-product unknown remains after the invariant solve"];

linearInvariantSquare[expression_] := Module[
  {expanded, coefficients, remainder},
  expanded = Expand[expression];
  coefficients = Coefficient[expanded, #] & /@ basisMomentumSymbols;
  remainder = Expand[
    expanded - Total[MapThread[Times, {coefficients, basisMomentumSymbols}]]
  ];
  assert[remainder === 0,
    "a propagator momentum is not linear in p,k1,k2,k3"];
  Expand[quadraticForm[coefficients] /. dotSolution]
];

invariantPropagator[
    Global`PropagatorDenominator[
      coefficient_. Global`Momentum[expression_, dimension_], mass_
    ]
  ] := Module[{denominator},
  denominator = Expand[
    coefficient^2 linearInvariantSquare[expression] - mass^2
  ];
  assert[
    ! TrueQ[PossibleZeroQ[denominator]],
    "a mapped propagator denominator is identically zero"
  ];
  1/denominator
];
invariantPropagator[other_] := (
  Print["S09_DIAGNOSTIC_UNMAPPED_PROPAGATOR=", InputForm[other]];
  assert[False, "an unsupported propagator denominator was encountered"];
  0
);
mapDenominators[expression_] := expression /.
  HoldPattern[Global`FeynAmpDenominator[arguments__]] :>
    Times @@ (invariantPropagator /@ {arguments});

unitFourDimensionalRules = {
  D -> 4,
  Global`epsilon -> 0,
  Global`ScaleMu -> 1,
  Global`CA -> 3,
  Global`CF -> 4/3,
  Global`SUNN -> 3,
  Global`SMP["g_s"] -> 1,
  Global`FCGV["EL"] -> 1
};

Print["S09_STAGE: mapping six charge/projector payloads to invariants"];
unitChargeProjections = AssociationMap[
  Function[projectorName,
    AssociationMap[
      Function[chargeKey,
        mapDenominators[projections[projectorName, chargeKey]] /.
          unitFourDimensionalRules
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];
physicalUnitProjections = AssociationMap[
  Function[projectorName,
    Total[
      chargeWeights[#] unitChargeProjections[projectorName, #] & /@
        chargeKeys
    ]
  ],
  projectorKeys
];

allowedSymbols = {
  Global`s12, Global`s13, Global`s23,
  Global`u1, Global`u2, Global`u3
};
remainingSymbols[expression_] := DeleteDuplicates @ Cases[
  Unevaluated[expression],
  symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`",
  Infinity,
  Heads -> True
];
allowedSymbolSetQ[expression_] := And @@ (
  MemberQ[allowedSymbols, #] & /@ remainingSymbols[expression]
);
allMappedExpressions = Join[
  Flatten[Values /@ Values[unitChargeProjections]],
  Values[physicalUnitProjections]
];
assert[
  And @@ (allowedSymbolSetQ /@ allMappedExpressions),
  "a non-kinematic project symbol remains after four-dimensional mapping"
];
assert[
  And @@ (
    FreeQ[
      #,
      _Global`FeynAmpDenominator | _Global`PropagatorDenominator |
        _Global`Momentum | _Global`SMP | _Global`FCGV |
        Global`epsilon | Global`ScaleMu | Global`CA | Global`CF |
        Global`SUNN | D
    ] & /@ allMappedExpressions
  ),
  "an inert or dimensional object remains after four-dimensional mapping"
];

chargeProjectionLeafCounts = AssociationMap[
  Function[projectorName,
    AssociationMap[
      LeafCount[unitChargeProjections[projectorName, #]] &,
      chargeKeys
    ]
  ],
  projectorKeys
];
physicalProjectionLeafCounts = AssociationMap[
  LeafCount[physicalUnitProjections[#]] &,
  projectorKeys
];
Print[
  "S09_PHYSICAL_UNIT_LEAF_COUNTS=",
  InputForm[physicalProjectionLeafCounts]
];

compiledBody = {
  physicalUnitProjections["Pg"],
  physicalUnitProjections["PPP"]
} /. {
  Global`s12 -> compiledS12,
  Global`s13 -> compiledS13,
  Global`s23 -> compiledS23,
  Global`u1 -> compiledU1,
  Global`u2 -> compiledU2,
  Global`u3 -> compiledU3
};

Print["S09_STAGE: compiling physical invariant evaluator to WVM"];
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
  "the invariant evaluator did not compile"];

referencePoint = projectedPoint["reference_point"];
benchmarkRow = N[{
  referencePoint["s12"], referencePoint["s13"], referencePoint["s23"],
  referencePoint["u1"], referencePoint["u2"], referencePoint["u3"],
  referencePoint["q2"]
}, MachinePrecision];
benchmarkUnit = Apply[compiledEvaluator, benchmarkRow];
assert[
  VectorQ[benchmarkUnit, MachineNumberQ] && Length[benchmarkUnit] === 2,
  "the compiled evaluator did not return two machine reals"
];

alphaS = projectedPoint["parameter_card", "alpha_s"];
alphaEMInverse = projectedPoint["parameter_card", "alpha_em_inverse"];
assert[
  alphaS === azimuthalValidation["alpha_s"] &&
    projectedPoint["parameter_card", "sha256"] ===
      expectedHashes[parameterCardPath],
  "accepted coupling metadata is inconsistent"
];
electricCoupling = Sqrt[4.0 Pi/alphaEMInverse];
strongCoupling = Sqrt[4.0 Pi alphaS];
hadronicCouplingFactor = electricCoupling^2 strongCoupling^4;
benchmarkPhysical = hadronicCouplingFactor benchmarkUnit;
expectedPhysical = {
  projectedPoint["projected", "physical_pg"],
  projectedPoint["projected", "physical_ppp"]
};
benchmarkRelativeDifferences = MapThread[
  relativeDifference,
  {benchmarkPhysical, expectedPhysical}
];
assert[
  Max[benchmarkRelativeDifferences] < 5 10^-12,
  "compiled unit evaluator does not reconstruct corrected S07 projections"
];

benchmarkRepetitions = 1000;
evaluationTiming = AbsoluteTiming[
  Do[Apply[compiledEvaluator, benchmarkRow], {benchmarkRepetitions}];
][[1]];
Print["S09_COMPILE_SECONDS=", compileTiming];
Print[
  "S09_EVALUATIONS_PER_SECOND=",
  benchmarkRepetitions/evaluationTiming
];
Print[
  "S09_BENCHMARK_RELATIVE_DIFFERENCES=",
  InputForm[benchmarkRelativeDifferences]
];

checks = <|
  "AllInputHashesExact" -> True,
  "ScalarProductsDerivedFromInvariantDefinitions" -> True,
  "AllSixChargeProjectorPayloadsMapped" -> True,
  "PhysicalChargesDerivedFromCopiedS01" -> True,
  "OnlySixInvariantSymbolsRemain" -> True,
  "NoInertDimensionalOrCouplingObjectRemains" -> True,
  "PhysicalEvaluatorCompiledToWVM" -> True,
  "CorrectedS07BenchmarkReconstructed" -> True,
  "AcceptedS08Pinned" -> True
|>;

output = <|
  "Status" -> "Complete",
  "Stage" -> "HqqprimeFourDimensionalEvaluator-v1",
  "ProgramSHA256" ->
    IntegerString[FileHash[programPath, "SHA256"], 16, 64],
  "InputSHA256" -> Association @ KeyValueMap[
    Function[{path, expectedHash}, FileNameTake[path] -> expectedHash],
    expectedHashes
  ],
  "VariablesInOrder" -> {
    "s12", "s13", "s23", "u1", "u2", "u3", "Q2"
  },
  "PhysicalRepresentative" -> <|
    "Incoming" -> "u",
    "PrimeFragmenting" -> "c",
    "IncomingCharge" -> incomingCharge,
    "PrimeCharge" -> primeCharge,
    "ChargeWeights" -> chargeWeights
  |>,
  "CouplingConvention" ->
    "EL=1 and g_s=1 in stored projections; multiply by EL^2 g_s^4",
  "ColorConvention" -> "SU(3): CA=3, CF=4/3, SUNN=3",
  "Dimension" -> 4,
  "ScaleMu" -> 1,
  "InvariantScalarProductSolution" -> dotSolution,
  "UnitCouplingChargeProjections" -> unitChargeProjections,
  "UnitCouplingPhysicalProjections" -> physicalUnitProjections,
  "LeafCounts" -> <|
    "ChargeResolved" -> chargeProjectionLeafCounts,
    "Physical" -> physicalProjectionLeafCounts
  |>,
  "CompiledBenchmark" -> <|
    "CompilationTarget" -> "WVM",
    "CompileSeconds" -> compileTiming,
    "RepeatedEvaluations" -> benchmarkRepetitions,
    "EvaluationSeconds" -> evaluationTiming,
    "EvaluationsPerSecond" -> benchmarkRepetitions/evaluationTiming,
    "PhysicalRelativeDifferences" -> benchmarkRelativeDifferences,
    "Passed" -> True
  |>,
  "Checks" -> checks
|>;

Print["S09_STAGE: atomically writing validated physical projections"];
atomicPutAssociation[output, outputPath];
Print["S09_SUCCESS"];
Exit[0];

$HistoryLength = 0;

ClearAll[
  assert, atomicPutAssociation, q2Symbolic,
  compiledS12, compiledS13, compiledS23,
  compiledU1, compiledU2, compiledU3, compiledQ2
];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S09_FATAL: " <> message];
  Exit[1]
];

atomicPutAssociation[association_Association, path_String] := Module[
  {temporaryPath, reloaded},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  assert[! FileExistsQ[path] && ! FileExistsQ[temporaryPath],
    "the evaluator result or its temporary path already exists"];
  Put[association, temporaryPath];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "the evaluator temporary write failed"];
  reloaded = Quiet[Check[Get[temporaryPath], $Failed]];
  assert[
    AssociationQ[reloaded] && reloaded["Status"] === "Complete" &&
      reloaded["Stage"] === "HqqbarFourDimensionalEvaluator-v1",
    "the evaluator temporary result failed reload validation"
  ];
  RenameFile[temporaryPath, path];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "the evaluator atomic rename failed"];
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
copiedResultPath = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];
projectedPointPath = FileNameJoin[{checkDirectory, "s07_projected_local_point.json"}];
outputPath = FileNameJoin[{checkDirectory, "s09_four_dimensional_unit_projections"}];

expectedCopiedResultHash =
  "a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50";
expectedProjectedPointHash =
  "8f8e8319301efb68cadf8226907ed4cce71df51660e5abe9e27e47142d754ca5";
assert[
  IntegerString[FileHash[copiedResultPath, "SHA256"], 16, 64] ===
    expectedCopiedResultHash,
  "the copied S07 result hash is invalid"
];
assert[
  IntegerString[FileHash[projectedPointPath, "SHA256"], 16, 64] ===
    expectedProjectedPointHash,
  "the projected-point hash is invalid"
];

result = Quiet[Check[Get[copiedResultPath], $Failed]];
assert[AssociationQ[result], "the copied S07 result did not load"];
projections = Quiet[Check[
  result["ScalarProjections"]["NLOReal_OAlphaS2"]["Hqqbar;q_q"],
  $Failed
]];
assert[
  AssociationQ[projections] && Keys[projections] === {"Pg", "PPP"},
  "the copied projection schema is invalid"
];

sHatSymbolic = Global`s12 + Global`s13 + Global`s23;
t1Symbolic = Global`s23 - sHatSymbolic - q2Symbolic - Global`u1;
t2Symbolic = Global`s13 - sHatSymbolic - q2Symbolic - Global`u2;
t3Symbolic = Global`s12 - sHatSymbolic - q2Symbolic - Global`u3;

denominatorRules = {
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k3, D], 0]
    ]
  ] :> 1/Global`s13,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k2 + Global`k3, D], 0]
    ]
  ] :> 1/sHatSymbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k2 - Global`p, D], 0]
    ]
  ] :> 1/Global`u2,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k2 - Global`p, D], 0]
    ]
  ] :> 1/t3Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k3, D], 0]
    ]
  ] :> 1/Global`s13,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/t2Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k2 + Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/t1Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k2, D], 0]
    ]
  ] :> 1/Global`s12,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k2, D], 0]
    ]
  ] :> 1/Global`s12,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/Global`u3
};

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

Print["S09_STAGE: mapping copied S07 to unit-coupling four-dimensional invariants"];
unitProjections = Association @ KeyValueMap[
  Function[{name, expression},
    name -> (expression /. denominatorRules /. unitFourDimensionalRules)
  ],
  projections
];
allowedSymbols = {
  Global`s12, Global`s13, Global`s23,
  Global`u1, Global`u2, Global`u3, q2Symbolic
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
assert[
  And @@ (allowedSymbolSetQ /@ Values[unitProjections]),
  "a non-kinematic project symbol remains after four-dimensional mapping"
];
assert[
  And @@ (
    FreeQ[#, _Global`FeynAmpDenominator | _Global`PropagatorDenominator |
      _Global`Momentum | _Global`SMP | _Global`FCGV | Global`epsilon |
      Global`ScaleMu | Global`CA | Global`CF | Global`SUNN | D] & /@
      Values[unitProjections]
  ),
  "an inert or dimensional object remains after four-dimensional mapping"
];

projectionLeafCounts = Association @ KeyValueMap[
  Function[{name, expression}, name -> LeafCount[expression]],
  unitProjections
];
Print["S09_UNIT_LEAF_COUNTS=", InputForm[projectionLeafCounts]];

compiledBody = {
  unitProjections["Pg"], unitProjections["PPP"]
} /. {
  Global`s12 -> compiledS12,
  Global`s13 -> compiledS13,
  Global`s23 -> compiledS23,
  Global`u1 -> compiledU1,
  Global`u2 -> compiledU2,
  Global`u3 -> compiledU3,
  q2Symbolic -> compiledQ2
};

Print["S09_STAGE: compiling the invariant evaluator to WVM"];
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

rootThree = Sqrt[3];
q2Value = 250000 (1 - 1/rootThree);
benchmarkRow = N[{
  500000/3,
  500000/3,
  500000/3,
  -250000 (1 + 1/rootThree),
  -250000 (1 - 1/rootThree),
  -250000 (1 - 1/rootThree),
  q2Value
}, 17];
benchmarkUnit = Apply[compiledEvaluator, benchmarkRow];
assert[
  VectorQ[benchmarkUnit, MachineNumberQ] && Length[benchmarkUnit] === 2,
  "the compiled evaluator did not return two machine reals"
];

alphaS = 0.118;
alphaEMInverse = 132.507;
electricCoupling = Sqrt[4.0 Pi/alphaEMInverse];
strongCoupling = Sqrt[4.0 Pi alphaS];
couplingFactor = electricCoupling^2 strongCoupling^4;
benchmarkPhysical = couplingFactor benchmarkUnit;
projectedPoint = Import[projectedPointPath, "RawJSON"];
expectedPhysical = {projectedPoint["pg"], projectedPoint["ppp"]};
benchmarkRelativeDifferences = MapThread[
  Abs[#1 - #2]/Max[Abs[#1], Abs[#2]] &,
  {benchmarkPhysical, expectedPhysical}
];
assert[
  Max[benchmarkRelativeDifferences] < 5 10^-12,
  "the compiled unit evaluator does not reconstruct the accepted projected point"
];

benchmarkRepetitions = 1000;
evaluationTiming = AbsoluteTiming[
  Do[Apply[compiledEvaluator, benchmarkRow], {benchmarkRepetitions}];
][[1]];
Print["S09_COMPILE_SECONDS=", compileTiming];
Print["S09_EVALUATIONS_PER_SECOND=", benchmarkRepetitions/evaluationTiming];
Print["S09_BENCHMARK_RELATIVE_DIFFERENCES=", benchmarkRelativeDifferences];

output = <|
  "Status" -> "Complete",
  "Stage" -> "HqqbarFourDimensionalEvaluator-v1",
  "CopiedS07ResultSHA256" -> expectedCopiedResultHash,
  "ProjectedPointSHA256" -> expectedProjectedPointHash,
  "VariablesInOrder" -> {
    "s12", "s13", "s23", "u1", "u2", "u3", "Q2"
  },
  "CouplingConvention" -> "EL=1 and g_s=1; multiply both projections by EL^2 g_s^4",
  "ColorConvention" -> "SU(3): CA=3, CF=4/3, SUNN=3",
  "Dimension" -> 4,
  "UnitCouplingProjections" -> unitProjections,
  "LeafCounts" -> projectionLeafCounts,
  "CompiledBenchmark" -> <|
    "CompilationTarget" -> "WVM",
    "CompileSeconds" -> compileTiming,
    "RepeatedEvaluations" -> benchmarkRepetitions,
    "EvaluationSeconds" -> evaluationTiming,
    "EvaluationsPerSecond" -> benchmarkRepetitions/evaluationTiming,
    "PhysicalRelativeDifferences" -> benchmarkRelativeDifferences,
    "Passed" -> True
  |>
|>;

Print["S09_STAGE: atomically writing the validated unit projections"];
atomicPutAssociation[output, outputPath];
Print["S09_SUCCESS"];
Exit[0];

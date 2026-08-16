(* ::Package:: *)

(*
  Hqq stage s12: apply Eq. (46) collinear factorization to the fully
  UV-renormalized, endpoint-acted S10 result.

  The four S11 counterterms were constructed at fixed generic partonic
  variables.  They cannot be substituted directly after their splitting
  distributions have acted, because the S10 test function and endpoint
  subtraction live on the physical S08 interval 0 <= s23 <= B(xi).  This
  stage therefore reuses S11's validated D-dimensional Hqq/Hqg/Hgq Born
  projections and rebuilds the four actions after the exact S08 map.

  Every Laurent coefficient is represented as

    endpointCoefficient Phi(0)
      + Integral_0^B ds23 [
          integrandPhiS Phi(s23) + integrandPhi0 Phi(0)
        ].

  This makes the cancellation of independent distributions/test-function
  structures an exact algebraic gate.  Only after the epsilon^-2 and
  epsilon^-1 gates pass for Pg and PPP are the two finite hatted Hqq hard
  functions written.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

requestedParallelKernels = 2;
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel";
parallelKernelConfiguration = If[
  Length[$ConfiguredKernels] > 0,
  ReplacePart[
    First[$ConfiguredKernels],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernels,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ],
  Missing["NoLocalKernelConfiguration"]
];
parallelLaunchResult = {};
parallelKernelCount = 0;
parallelKernelIDs = {};
parallelKernelIDsSeen = {};
parallelExecutionValidated = False;

ClearAll[
  fatal, assert, structuralLogDegree, exactPhysicalCoefficientZeroQ,
  physicalEndpointSinglePoleZeroQ, zeroEquivalentResidual, seriesChecked,
  seriesMinimumPower, shiftedCoefficient, pairAdd, pairScale,
  pairToAction, bornM2, s23Function, pqqPair, regularKernelPair,
  splitRealKernel, nonPiecewiseSeriesCoefficients,
  singleTermSeriesCoefficients,
  summandwiseSeriesCoefficientData, convolveLaurentCoefficientData,
  atomicPut, termPartDirectory, termPartPath,
  loadCoefficientCacheField, mergeCoefficientCacheFields,
  validTermPartPayloadQ, loadValidTermPart, writeTermPart,
  currentAvailableMemory, initialWorkerMemoryEstimate,
  ensureParallelKernels, closeParallelKernels,
  refreshParallelKernels, termwiseSeriesCoefficients,
  splitVirtualEpsilonSums, virtualTermPower,
  extractVirtualLaurentCoefficients, applyVirtualConvention,
  physicalHermitianEndpointProjection,
  S10ConvolutionTest
];

fatal[message_String] := (
  Print["S12_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s10Path = FileNameJoin[{scriptDirectory, "s10_result"}];
s11Path = FileNameJoin[{scriptDirectory, "s11_result"}];
s10VirtualCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v2_virtual_laurent"
}];
resultPath = FileNameJoin[{scriptDirectory, "s12_result"}];
residualDiagnosticPath = FileNameJoin[{
  scriptDirectory, "s12_last_nonzero_residual"
}];
s12TermPartRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v4_term_parts"
}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
realChannels = {
  "Hqq;gg", "Hqq;q_qbar_sameFlavor", "Hqq;qPrime_qbarPrime"
};
realChannelWeights = <|
  "Hqq;gg" -> 1/2,
  "Hqq;q_qbar_sameFlavor" -> 1,
  "Hqq;qPrime_qbarPrime" -> (Nf - 1)
|>;
channelFileStem = <|
  "Hqq;gg" -> "Hqq_gg",
  "Hqq;q_qbar_sameFlavor" -> "Hqq_q_qbar_sameFlavor",
  "Hqq;qPrime_qbarPrime" -> "Hqq_qPrime_qbarPrime"
|>;
s09ProjectorSuffix = <|"Pg" -> "g", "PPP" -> "pp"|>;
endpointProjectorSuffix = <|"Pg" -> "pg", "PPP" -> "ppp"|>;
ggAlpha2TermIndex = <|"Pg" -> 15, "PPP" -> 10|>;
coupledEndpointRepairVersion = 1;
coupledEndpointGroups = <|
  "Pg" -> {{17, 29, 39, 55}},
  "PPP" -> {{8, 35, 42, 57}}
|>;
gibibyte = 1024^3;
memoryReserveBytes = 6 gibibyte;
(*
  WSL and the main kernel retain at least 6 GiB of reported available memory.
  Completed endpoint checkpoints peak below 153 MiB, while the structured
  extractor below keeps the former whole-Series outliers below 100 MiB in
  isolated tests.  A 1 GiB worker floor also covers FeynCalc/kernel overhead;
  together with the 6 GiB reserve it limits normal WSL concurrency to two.
*)
minimumWorkerBudgetBytes = 1 gibibyte;
workerEstimateSafetyFactor = 5/4;
(*
  At most half of memory above the hard reserve is admitted to worker
  computations.  The other half covers the main-kernel source terms,
  WSTP result copies, atomic serialization, and runtime overhead.
*)
workerAllocationFraction = 1/2;
maximumTermsPerEpoch = 8;
largeTermLeafThreshold = 50000;

s09RealCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s09_cache_v1_" <> channelFileStem[channel] <> "_" <>
    s09ProjectorSuffix[projector]
}];
endpointCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s9p5_cache_v3_endpoint_" <> channelFileStem[channel] <> "_" <>
    endpointProjectorSuffix[projector]
}];
s12CoefficientCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s12_cache_v3_coefficients_" <> channelFileStem[channel] <> "_" <>
    endpointProjectorSuffix[projector]
}];
termPartDirectory[
    channel_String, projector_String, family_String
  ] := FileNameJoin[{
  s12TermPartRoot,
  channelFileStem[channel],
  endpointProjectorSuffix[projector],
  family
}];
termPartPath[
    channel_String, projector_String, family_String, position_Integer
  ] := FileNameJoin[{
  termPartDirectory[channel, projector, family],
  "term_" <> IntegerString[position, 10, 4]
}];

(*
  QCD uses T_F=1/2.  The remaining replacements only canonicalize exact
  special constants that occur in the inherited angular/loop expansions.
*)
qcdAndConstantRules = {
  FeynCalc`TF -> 1/2,
  FeynCalc`CF ->
    (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA),
  PolyGamma[0, 1/2] -> -EulerGamma - 2 Log[2],
  Log[16] -> 4 Log[2],
  Log[8] -> 3 Log[2],
  Log[4] -> 2 Log[2]
};

physicalAssumptions =
  0 < xB < xi < 1 && 0 < zH < 1 && Q2 > 0 && PHT2 > 0 &&
    ScaleMu > 0;
residualReductionTimeoutSeconds = 120;

(*
  Determine the logarithmic degree without expanding a large expression.
  A negative power or a nonlinear function containing a logarithm is rejected
  rather than silently treated as a polynomial in logarithms.
*)
structuralLogDegree[expression_] := Module[{degree},
  ClearAll[degree];
  degree[value_] /; FreeQ[value, _Log] := 0;
  degree[value_Log] := 1;
  degree[value_Plus] := Max[degree /@ (List @@ value)];
  degree[value_Times] := Total[degree /@ (List @@ value)];
  degree[Power[base_, exponent_Integer]] /; exponent >= 0 :=
    exponent degree[base];
  degree[_] := Infinity;
  degree[expression]
];

exactPhysicalCoefficientZeroQ[expression_, assumptions_] := Module[
  {combined, simplified},
  combined = Quiet@Check[
    TimeConstrained[
      Together[expression],
      residualReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  If[combined === $Failed, Return[False]];
  If[TrueQ[combined === 0], Return[True]];
  simplified = Quiet@Check[
    TimeConstrained[
      FullSimplify[combined, Assumptions -> assumptions],
      residualReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  TrueQ[simplified === 0]
];

(*
  The physical endpoint single-pole residual inherits several syntactically
  different presentations of one square root and of the same principal
  logarithms from the virtual evaluator.  Whole-expression Together and
  FullSimplify expand this object past one million leaves and can time out.

  Use the invertible physical parametrization

    xi   = xB (1 + a),
    PHT2 = rT Q2 a zH (1-zH),

  where a>0 and 0<rT<1.  The latter is exactly the positive-s23-upper-bound
  condition.  Every half-integer power must have the one validated radicand.
  Resolve its positive square root separately on the two signs of
  delta=a zH-rT(1-zH), expand only a finite list of sign-proven principal
  logarithms, and prove each independent log coefficient and the constant
  by exact algebra.  No branch-blind PowerExpand is used.
*)
physicalEndpointSinglePoleZeroQ[expression_] := Module[
  {
    aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    physicalSubstitution, transformed, rootRadicands,
    expectedRootRadicand, originalTerms, structuralDegrees,
    logTwo, logPi, logMu, logA, logQ, logRT, logOneMinusRT,
    logZ, logOneMinusZ, logDenominator, logOnePlusA,
    logBasis, logBasisLabels, baseLogArguments, logForms,
    logArgumentMap, rootSign, positiveRoot, rootRule,
    canonicalArgument, expandLog, resolvePiecewise, unmatchedLog,
    branchTransformed, branchExpression,
    unmatchedLogs, branchTerms, branchAssumptions, coefficient,
    constant, zeroLogRules, coefficientIndex
  },

  denominatorPhysical =
    rTPhysical + zH - rTPhysical zH;
  deltaPhysical =
    aPhysical zH - rTPhysical (1 - zH);
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  transformed = expression /. physicalSubstitution;
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  rootRadicands = DeleteDuplicates[
    Cases[
      transformed,
      Power[
        radicand_,
        power_Rational?((Denominator[#] === 2) &)
      ] :> radicand,
      Infinity
    ]
  ];
  If[
    rootRadicands === {} ||
      !And @@ (
        TrueQ[Cancel[Together[# - expectedRootRadicand]] === 0] & /@
          rootRadicands
      ),
    Return[False]
  ];

  logBasis = {
    logTwo, logPi, logMu, logA, logQ, logRT, logOneMinusRT,
    logZ, logOneMinusZ, logDenominator, logOnePlusA
  };
  logBasisLabels = {
    "Log[2]", "Log[Pi]", "Log[ScaleMu]", "Log[a]", "Log[Q2]",
    "Log[rT]", "Log[1-rT]", "Log[zH]", "Log[1-zH]",
    "Log[rT+zH-rT zH]", "Log[1+a]"
  };
  baseLogArguments = {
    2 Pi/ScaleMu,
    aPhysical (-1 + rTPhysical)
      (-rTPhysical - zH + rTPhysical zH)/
        ((1 + aPhysical) rTPhysical),
    (-1 + rTPhysical) (-1 + zH),
    aPhysical Q2 (-1 + rTPhysical) (-1 + zH),
    1/(4 Pi),
    -zH/(aPhysical Q2 rTPhysical (-1 + zH)),
    ScaleMu^2/Q2,
    -ScaleMu^2/(aPhysical Q2),
    -ScaleMu^2/(aPhysical Pi Q2),
    ScaleMu^2 (-rTPhysical - zH + rTPhysical zH)/
      ((1 + aPhysical) Q2 rTPhysical (-1 + zH)),
    Pi,
    ScaleMu^2 (-rTPhysical - zH + rTPhysical zH)/
      ((1 + aPhysical) Pi Q2 rTPhysical (-1 + zH)),
    2 Pi,
    4 Pi,
    -ScaleMu^2 (-rTPhysical - zH + rTPhysical zH)/
      ((1 + aPhysical) Q2 zH),
    -(1 + aPhysical) zH/
      (-rTPhysical - zH + rTPhysical zH),
    -(-rTPhysical - zH + rTPhysical zH)/
      ((1 + aPhysical) zH)
  };
  logForms = {
    logTwo + logPi - logMu,
    logA + logOneMinusRT + logDenominator - logOnePlusA - logRT,
    logOneMinusRT + logOneMinusZ,
    logA + logQ + logOneMinusRT + logOneMinusZ,
    -2 logTwo - logPi,
    logZ - logA - logQ - logRT - logOneMinusZ,
    2 logMu - logQ,
    2 logMu - logA - logQ + I Pi,
    2 logMu - logA - logQ - logPi + I Pi,
    2 logMu + logDenominator - logOnePlusA - logQ - logRT -
      logOneMinusZ,
    logPi,
    2 logMu + logDenominator - logOnePlusA - logPi - logQ -
      logRT - logOneMinusZ,
    logTwo + logPi,
    2 logTwo + logPi,
    2 logMu + logDenominator - logOnePlusA - logQ - logZ,
    logOnePlusA + logZ - logDenominator,
    logDenominator - logOnePlusA - logZ
  };
  logArgumentMap = AssociationThread[
    ToString[InputForm[Factor[Together[#]]]] & /@ baseLogArguments,
    logForms
  ];
  zeroLogRules = Thread[logBasis -> 0];

  Do[
    positiveRoot =
      rootSign Q2 deltaPhysical/denominatorPhysical;
    rootRule = HoldPattern[
      Power[
        rootArgument_,
        rootPower_Rational?((Denominator[#] === 2) &)
      ]
    ] :> positiveRoot^(2 rootPower);
    canonicalArgument[value_] := FixedPoint[
      (Factor[Together[#]] /. rootRule) &,
      value,
      3
    ];
    expandLog[value_] := Module[{canonical = canonicalArgument[value]},
      Lookup[
        logArgumentMap,
        ToString[InputForm[canonical]],
        unmatchedLog[canonical]
      ]
    ];
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && ScaleMu > 0 && rootSign deltaPhysical > 0;
    resolvePiecewise[value_] := FixedPoint[
      Function[currentValue,
        currentValue /. piece_Piecewise :> Module[
          {rows, default, truthValues, truePosition},
          rows = piece[[1]];
          default = If[Length[piece] >= 2, piece[[2]], 0];
          truthValues = Quiet@Check[
            FullSimplify[
              rows[[All, 2]],
              Assumptions -> branchAssumptions
            ],
            $Failed
          ];
          If[truthValues === $Failed, Return[piece, Module]];
          truePosition = FirstPosition[truthValues, True];
          Which[
            ! MissingQ[truePosition],
              rows[[First[truePosition], 1]],
            And @@ (TrueQ[# === False] & /@ truthValues),
              default,
            True,
              piece
          ]
        ]
      ],
      value,
      3
    ];
    branchTransformed = resolvePiecewise[transformed];
    If[! FreeQ[branchTransformed, _Piecewise], Return[False]];
    originalTerms = If[
      Head[branchTransformed] === Plus,
      List @@ branchTransformed,
      {branchTransformed}
    ];
    structuralDegrees = structuralLogDegree /@ originalTerms;
    If[
      !VectorQ[
        structuralDegrees,
        IntegerQ[#] && 0 <= # <= 1 &
      ],
      Return[False]
    ];
    branchExpression =
      (branchTransformed /. rootRule) /. Log[value_] :> expandLog[value];
    unmatchedLogs = DeleteDuplicates[
      Cases[branchExpression, _unmatchedLog, Infinity]
    ];
    If[unmatchedLogs =!= {}, Return[False]];
    branchTerms = If[
      Head[branchExpression] === Plus,
      List @@ branchExpression,
      {branchExpression}
    ];
    Print[
      "S12_POLE_REDUCTION_STAGE: endpoint single pole rootSign=",
      rootSign,
      " coefficients=", Length[logBasis] + 1
    ];
    Do[
      coefficient = Total[
        Coefficient[#, logBasis[[coefficientIndex]]] & /@ branchTerms
      ];
      If[
        !exactPhysicalCoefficientZeroQ[coefficient, branchAssumptions],
        Return[False]
      ];
      Print[
        "S12_POLE_REDUCTION_CHECK: rootSign=", rootSign,
        " coefficient=", logBasisLabels[[coefficientIndex]],
        " status=zero"
      ];,
      {coefficientIndex, Length[logBasis]}
    ];
    constant = Total[(# /. zeroLogRules) & /@ branchTerms];
    If[
      !exactPhysicalCoefficientZeroQ[constant, branchAssumptions],
      Return[False]
    ];
    Print[
      "S12_POLE_REDUCTION_CHECK: rootSign=", rootSign,
      " coefficient=constant status=zero"
    ];
    Clear[
      positiveRoot, rootRule, canonicalArgument, expandLog,
      resolvePiecewise, branchTransformed, branchExpression,
      unmatchedLogs, branchTerms, coefficient, constant
    ];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];
  True
];

zeroEquivalentResidual[
    expression_, label_String,
    components_: Missing["NotCaptured"]
  ] := Module[
  {
    residual, simplified, structuredEndpointResult,
    diagnosticExpression, diagnosticPayload
  },
  residual = expression /. qcdAndConstantRules;
  If[TrueQ[residual === 0], Return[0]];
  If[
    MemberQ[
      {"Pg epsilon^-1 Endpoint", "PPP epsilon^-1 Endpoint"},
      label
    ] && LeafCount[residual] > 100000,
    Print[
      "S12_POLE_REDUCTION_STAGE: using exact physical endpoint " <>
        "single-pole decomposition for " <> label
    ];
    structuredEndpointResult = Quiet@Check[
      physicalEndpointSinglePoleZeroQ[residual],
      False
    ];
    If[TrueQ[structuredEndpointResult],
      Print[
        "S12_POLE_REDUCTION_RESULT: " <> label <>
          " exact zero in both physical root regions"
      ];
      Return[0]
    ];
    Print[
      "S12_POLE_REDUCTION_RESULT: structured proof unavailable for " <>
        label <> "; trying the generic exact reducer"
    ]
  ];
  simplified = Quiet@Check[
    TimeConstrained[
      Together[Cancel[residual]],
      residualReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  If[TrueQ[simplified === 0], Return[0]];
  If[simplified === $Failed, simplified = residual];
  simplified = Quiet@Check[
    TimeConstrained[
      FullSimplify[
        simplified,
        Assumptions -> physicalAssumptions
      ],
      residualReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  If[TrueQ[simplified === 0],
    0,
    diagnosticExpression = If[simplified === $Failed, residual, simplified];
    diagnosticPayload = <|
      "SchemaVersion" -> 1,
      "Label" -> label,
      "GeneratedAt" -> DateString[Now, "ISODateTime"],
      "ReductionTimedOut" -> TrueQ[simplified === $Failed],
      "LeafCount" -> LeafCount[diagnosticExpression],
      "Expression" -> diagnosticExpression
    |>;
    If[AssociationQ[components],
      AssociateTo[diagnosticPayload, "Components" -> components]
    ];
    atomicPut[diagnosticPayload, residualDiagnosticPath];
    Print[
      "S12_NONZERO_RESIDUAL label=", label,
      " leafCount=", LeafCount[diagnosticExpression],
      " diagnostic=", residualDiagnosticPath
    ];
    If[LeafCount[diagnosticExpression] <= 1000,
      Print[
        "S12_NONZERO_RESIDUAL_EXPRESSION label=", label,
        " expression=", InputForm[diagnosticExpression]
      ]
    ];
    fatal[
      "Nonzero or unreduced residual: " <> label <>
        ". Exact diagnostic was written to " <> residualDiagnosticPath <> "."
    ]
  ]
];

seriesChecked[expression_, maximum_Integer, label_String] := Module[
  {answer},
  Print["S12_STAGE: series " <> label <> " through epsilon^" <>
    ToString[maximum]];
  answer = Quiet@Check[
    TimeConstrained[
      Series[expression, {epsilon, 0, maximum}],
      3600,
      $Failed
    ],
    $Failed
  ];
  If[answer === $Failed, fatal["Laurent expansion failed: " <> label]];
  answer
];

seriesMinimumPower[series_] := If[
  Head[series] === SeriesData,
  series[[4]]/series[[6]],
  0
];

shiftedCoefficient[series_, shift_Integer, power_Integer] := Module[
  {answer},
  answer = Coefficient[
    Normal[series] epsilon^shift,
    epsilon,
    power + shift
  ];
  assert[FreeQ[answer, epsilon],
    "An extracted Laurent coefficient still contains epsilon."];
  answer
];

splitRealKernel[expression_, label_String] := Module[
  {
    factors, singularPositions, remainderIndex, remainder,
    prefactorIndices
  },
  assert[Head[expression] === Times,
    label <> " is not in the expected factored product form."];
  factors = List @@ expression;
  singularPositions = Flatten@Position[
    factors,
    factor_ /; SameQ[factor, s23^(-epsilon)],
    {1},
    Heads -> False
  ];
  assert[Length[singularPositions] === 1,
    label <> " does not contain exactly one s23^(-epsilon) factor."];
  remainderIndex = First@Ordering[LeafCount /@ factors, -1];
  assert[remainderIndex =!= First[singularPositions],
    label <> " selected s23^(-epsilon) as its remainder."];
  remainder = factors[[remainderIndex]];
  assert[Head[remainder] === Plus,
    label <> " has no additive rational remainder."];
  prefactorIndices = Complement[
    Range[Length[factors]],
    {First[singularPositions], remainderIndex}
  ];
  <|
    "Prefactor" -> Times @@ factors[[prefactorIndices]],
    "Terms" -> List @@ remainder
  |>
];

atomicPut[expression_, path_String] := Module[
  {directory, temporaryPath},
  directory = DirectoryName[path];
  If[! DirectoryQ[directory],
    CreateDirectory[directory, CreateIntermediateDirectories -> True]
  ];
  temporaryPath = path <> ".tmp-" <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Check[
    Put[expression, temporaryPath],
    fatal["Atomic cache write failed for " <> path <> "."]
  ];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Atomic cache temporary file is absent or empty for " <> path <> "."];
  Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    fatal["Atomic cache rename failed for " <> path <> "."]
  ];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic cache destination is absent or empty for " <> path <> "."];
  path
];

loadCoefficientCacheField[path_String, key_String] := Module[
  {payload, answer},
  payload = Quiet@Check[Get[path], $Failed];
  If[! AssociationQ[payload],
    fatal["Coefficient cache is unreadable: " <> path <> "."]
  ];
  answer = If[
    KeyExistsQ[payload, key],
    payload[key],
    Missing["Absent"]
  ];
  Clear[payload];
  ClearSystemCache[];
  answer
];

mergeCoefficientCacheFields[
    path_String, fields_Association
  ] := Module[{payload},
  payload = Quiet@Check[Get[path], $Failed];
  If[! AssociationQ[payload],
    fatal["Coefficient cache is unreadable during merge: " <> path <> "."]
  ];
  AssociateTo[payload, Normal[fields]];
  atomicPut[payload, path];
  Clear[payload];
  ClearSystemCache[];
  path
];

validTermPartPayloadQ[
    payload_, channel_String, projector_String, family_String,
    position_Integer, originalTermIndex_Integer, inputHash_Integer,
    powers_List, maximum_Integer
  ] := TrueQ[
  AssociationQ[payload] &&
  payload["CacheVersion"] === 4 &&
  payload["Channel"] === channel &&
  payload["Projector"] === projector &&
  payload["Family"] === family &&
  payload["Position"] === position &&
  payload["OriginalTermIndex"] === originalTermIndex &&
  payload["InputSHA256"] === inputHash &&
  payload["Powers"] === powers &&
  payload["Maximum"] === maximum &&
  AssociationQ[payload["Coefficients"]] &&
  Sort[Keys[payload["Coefficients"]]] === Sort[powers] &&
  FreeQ[
    payload["Coefficients"],
    epsilon | _SeriesData | $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
  ]
];

loadValidTermPart[
    channel_String, projector_String, family_String,
    position_Integer, originalTermIndex_Integer, inputHash_Integer,
    powers_List, maximum_Integer
  ] := Module[{path, payload},
  path = termPartPath[channel, projector, family, position];
  If[! FileExistsQ[path], Return[Missing["Absent"]]];
  payload = Quiet@Check[Get[path], $Failed];
  If[validTermPartPayloadQ[
      payload, channel, projector, family, position,
      originalTermIndex, inputHash, powers, maximum
    ],
    payload,
    Print[
      "S12_TERM_CACHE_INVALID: deleting mismatched part " <> path
    ];
    DeleteFile[path];
    Missing["Invalid"]
  ]
];

writeTermPart[
    workerPayload_Association,
    channel_String, projector_String, family_String,
    position_Integer, originalTermIndex_Integer, inputHash_Integer,
    powers_List, maximum_Integer
  ] := atomicPut[
  <|
    "CacheVersion" -> 4,
    "Channel" -> channel,
    "Projector" -> projector,
    "Family" -> family,
    "Position" -> position,
    "OriginalTermIndex" -> originalTermIndex,
    "InputSHA256" -> inputHash,
    "Powers" -> powers,
    "Maximum" -> maximum,
    "WorkerPeakBytes" -> workerPayload["WorkerPeakBytes"],
    "WorkerMemoryInUseBytes" -> Lookup[
      workerPayload, "WorkerMemoryInUseBytes", Missing["NotRecorded"]
    ],
    "Coefficients" -> workerPayload["Coefficients"]
  |>,
  termPartPath[channel, projector, family, position]
];

currentAvailableMemory[] := Module[{available},
  available = Quiet@Check[MemoryAvailable[], $Failed];
  If[! IntegerQ[available] || available <= 0,
    fatal["The operating-system available-memory reading failed."]
  ];
  available
];

initialWorkerMemoryEstimate[label_String] := If[
  StringContainsQ[label, "q_qbar_sameFlavor"],
  3 gibibyte,
  768 1024^2
];

summandwiseSeriesCoefficientData[
    expression_, maximum_Integer
  ] := Module[
  {
    parts, coefficients, reportedMinima, part, partSeries,
    partMinimum, shift, normalizedPart, power, coefficient,
    nonzeroPowers, minimumPower
  },
  parts = If[Head[expression] === Plus, List @@ expression, {expression}];
  coefficients = <||>;
  reportedMinima = {};
  Do[
    partSeries = Quiet@Check[
      Series[part, {epsilon, 0, maximum}],
      $Failed
    ];
    If[
      partSeries === $Failed || ! (
        Head[partSeries] === SeriesData || FreeQ[partSeries, epsilon]
      ),
      Return[$Failed, Module]
    ];
    partMinimum = seriesMinimumPower[partSeries];
    If[! IntegerQ[partMinimum], Return[$Failed, Module]];
    AppendTo[reportedMinima, partMinimum];
    shift = Max[0, -partMinimum];
    normalizedPart = Normal[partSeries] epsilon^shift;
    Do[
      coefficient = Coefficient[
        normalizedPart,
        epsilon,
        power + shift
      ];
      If[! FreeQ[coefficient, epsilon], Return[$Failed, Module]];
      If[! TrueQ[coefficient === 0],
        AssociateTo[
          coefficients,
          power -> Lookup[coefficients, power, 0] + coefficient
        ]
      ];,
      {power, partMinimum, maximum}
    ];
    Clear[partSeries, normalizedPart, coefficient];,
    {part, parts}
  ];
  nonzeroPowers = Select[
    Sort[Keys[coefficients]],
    ! TrueQ[coefficients[#] === 0] &
  ];
  minimumPower = If[
    Length[nonzeroPowers] > 0,
    First[nonzeroPowers],
    Min[reportedMinima]
  ];
  <|
    "MinimumPower" -> minimumPower,
    "MaximumPower" -> maximum,
    "Coefficients" -> AssociationMap[
      coefficients[#] &,
      nonzeroPowers
    ]
  |>
];

convolveLaurentCoefficientData[
    factorData_List, maximum_Integer
  ] := Module[
  {
    answer, nextAnswer, remainingMinimum, maximumPartialPower,
    factor, totalPower
  },
  answer = <|0 -> 1|>;
  Do[
    factor = factorData[[factorIndex]];
    remainingMinimum = Total[
      (#1["MinimumPower"] &) /@ Drop[factorData, factorIndex]
    ];
    maximumPartialPower = maximum - remainingMinimum;
    nextAnswer = <||>;
    KeyValueMap[
      Function[{leftPower, leftCoefficient},
        KeyValueMap[
          Function[{rightPower, rightCoefficient},
            totalPower = leftPower + rightPower;
            If[totalPower <= maximumPartialPower,
              AssociateTo[
                nextAnswer,
                totalPower -> Lookup[nextAnswer, totalPower, 0] +
                  leftCoefficient rightCoefficient
              ]
            ]
          ],
          factor["Coefficients"]
        ]
      ],
      answer
    ];
    answer = nextAnswer;,
    {factorIndex, Length[factorData]}
  ];
  answer
];

nonPiecewiseSeriesCoefficients[
    canonicalTerm_, powers_List, maximum_Integer
  ] := Module[
  {
    factors, regularFactor, dependentFactors, pilotData, factorMinima,
    totalMinimum, requiredMaxima, factorData, productCoefficients,
    coefficients, power, coefficient
  },
  If[FreeQ[canonicalTerm, epsilon],
    Return[AssociationMap[If[# === 0, canonicalTerm, 0] &, powers]]
  ];
  factors = If[
    Head[canonicalTerm] === Times,
    List @@ canonicalTerm,
    {canonicalTerm}
  ];
  regularFactor = Times @@ Select[factors, FreeQ[#, epsilon] &];
  dependentFactors = Select[factors, ! FreeQ[#, epsilon] &];
  pilotData =
    summandwiseSeriesCoefficientData[#, 0] & /@ dependentFactors;
  If[MemberQ[pilotData, $Failed], Return[$Failed]];
  factorMinima = (#1["MinimumPower"] &) /@ pilotData;
  totalMinimum = Total[factorMinima];
  If[totalMinimum < Min[powers], Return[$Failed]];
  requiredMaxima = maximum - (totalMinimum - #) & /@ factorMinima;
  factorData = MapThread[
    Function[{pilot, factor, neededMaximum},
      If[
        neededMaximum <= 0,
        pilot,
        summandwiseSeriesCoefficientData[factor, neededMaximum]
      ]
    ],
    {pilotData, dependentFactors, requiredMaxima}
  ];
  If[MemberQ[factorData, $Failed], Return[$Failed]];
  If[! And @@ MapThread[
      TrueQ[#1["MinimumPower"] === #2] &,
      {factorData, factorMinima}
    ],
    Return[$Failed]
  ];
  productCoefficients = convolveLaurentCoefficientData[
    factorData,
    maximum
  ];
  coefficients = <||>;
  Do[
    coefficient = regularFactor Lookup[productCoefficients, power, 0];
    If[! FreeQ[coefficient, epsilon], Return[$Failed]];
    AssociateTo[coefficients, power -> coefficient];,
    {power, powers}
  ];
  coefficients
];

singleTermSeriesCoefficients[
    term_, powers_List, maximum_Integer, memoryLimit_Integer
  ] := Module[{answer, workerPeakBytes, workerMemoryInUseBytes},
  answer = Quiet@Check[
    MemoryConstrained[
      TimeConstrained[
        Module[
          {
            canonicalTerm, piecewiseRows, branchValues,
            branchConditions, defaultValue, branchAnswers,
            defaultAnswer
          },
          canonicalTerm = term /. qcdAndConstantRules;
          If[Head[canonicalTerm] =!= Piecewise,
            Return[
              nonPiecewiseSeriesCoefficients[
                canonicalTerm, powers, maximum
              ],
              Module
            ]
          ];
          piecewiseRows = canonicalTerm[[1]];
          defaultValue = canonicalTerm[[2]];
          branchValues = piecewiseRows[[All, 1]];
          branchConditions = piecewiseRows[[All, 2]];
          If[! And @@ (FreeQ[#, epsilon] & /@ branchConditions),
            Return[$Failed, Module]
          ];
          Print[
            "S12_PIECEWISE_SERIES: branches=", Length[branchValues],
            " powers=", InputForm[powers]
          ];
          branchAnswers =
            nonPiecewiseSeriesCoefficients[#, powers, maximum] & /@
              branchValues;
          defaultAnswer = nonPiecewiseSeriesCoefficients[
            defaultValue, powers, maximum
          ];
          If[MemberQ[branchAnswers, $Failed] || defaultAnswer === $Failed,
            Return[$Failed, Module]
          ];
          AssociationMap[
            Function[currentPower,
              Piecewise[
                MapThread[
                  Function[{branchAnswer, condition},
                    {
                      Lookup[branchAnswer, currentPower, 0],
                      condition
                    }
                  ],
                  {branchAnswers, branchConditions}
                ],
                Lookup[defaultAnswer, currentPower, 0]
              ]
            ],
            powers
          ]
        ],
        1200,
        $Failed
      ],
      memoryLimit,
      $Failed
    ],
    $Failed
  ];
  If[answer === $Failed, Return[$Failed]];
  workerPeakBytes = MaxMemoryUsed[];
  workerMemoryInUseBytes = MemoryInUse[];
  ClearSystemCache[];
  <|
    "Coefficients" -> answer,
    "WorkerPeakBytes" -> workerPeakBytes,
    "WorkerMemoryInUseBytes" -> workerMemoryInUseBytes
  |>
];

ensureParallelKernels[reason_String] := Module[
  {launchResult, currentIDs},
  If[
    $KernelCount === requestedParallelKernels,
    currentIDs = Sort[ParallelEvaluate[$KernelID]];
    If[
      Length[currentIDs] === requestedParallelKernels &&
        DuplicateFreeQ[currentIDs],
      parallelKernelCount = $KernelCount;
      parallelKernelIDs = currentIDs;
      Return[currentIDs]
    ]
  ];
  If[$KernelCount > 0, Quiet[CloseKernels[]]];
  ClearSystemCache[];
  launchResult = Quiet@Check[
    If[
      MissingQ[parallelKernelConfiguration],
      {},
      LaunchKernels[parallelKernelConfiguration]
    ],
    {}
  ];
  parallelKernelCount = $KernelCount;
  If[parallelKernelCount =!= requestedParallelKernels,
    fatal[
      "Parallel launch created " <> ToString[parallelKernelCount] <>
        " of the required " <> ToString[requestedParallelKernels] <>
        " bounded workers."
    ]
  ];
  DistributeDefinitions[
    qcdAndConstantRules, seriesMinimumPower,
    summandwiseSeriesCoefficientData,
    convolveLaurentCoefficientData,
    nonPiecewiseSeriesCoefficients,
    singleTermSeriesCoefficients
  ];
  parallelKernelIDs = Sort[ParallelEvaluate[
    $HistoryLength = 0;
    ClearSystemCache[];
    $KernelID
  ]];
  assert[
    Length[parallelKernelIDs] === requestedParallelKernels &&
      DuplicateFreeQ[parallelKernelIDs],
    "The bounded worker set does not contain distinct kernel IDs."
  ];
  parallelKernelIDsSeen = Union[
    parallelKernelIDsSeen,
    parallelKernelIDs
  ];
  parallelExecutionValidated = True;
  Print[
    "S12_PARALLEL_KERNELS: reason=" <> reason <>
      " count=" <> ToString[parallelKernelCount] <> " IDs=" <>
      ToString[InputForm[parallelKernelIDs]]
  ];
  launchResult
];

closeParallelKernels[reason_String] := Module[{},
  If[$KernelCount > 0,
    Print[
      "S12_MEMORY_STAGE: closing bounded workers after " <> reason
    ];
    Quiet[CloseKernels[]]
  ];
  parallelKernelCount = 0;
  parallelKernelIDs = {};
  ClearSystemCache[];
];

refreshParallelKernels[reason_String] := Module[{},
  closeParallelKernels[reason];
  ensureParallelKernels["recycle after " <> reason]
];

termwiseSeriesCoefficients[
    terms_List, termIndices_List, powers_List, maximum_Integer,
    label_String, channel_String, projector_String, family_String
  ] := Module[
  {
    positions, inputHashes, termLeafCounts,
    validPositions, cachedWorkerPeaks,
    measuredWorkerPeak, pendingPositions,
    epochPositions, submittedPositions, successfulPositions,
    evaluationQueue, waitState, completedPair, completedPosition,
    completedPayload, nextEpochIndex, stopSubmitting,
    failedPositions, untouchedPositions, successfulPeaks,
    availableBytes, usableBytes,
    workerMemoryEstimate, maximumBatchSize, batchSize,
    batchMemoryLimit, isolatedLargeTerm,
    submitPosition, payload, answer, power, position
  },
  assert[Length[terms] === Length[termIndices],
    label <> " term-index metadata length is inconsistent."];
  If[Length[terms] === 0, Return[AssociationMap[0 &, powers]]];
  positions = Range[Length[terms]];
  inputHashes = Hash[HoldComplete[#], "SHA256"] & /@ terms;
  termLeafCounts = LeafCount /@ terms;
  cachedWorkerPeaks = {};
  validPositions = Select[
    positions,
    Function[currentPosition,
      payload = loadValidTermPart[
        channel, projector, family, currentPosition,
        termIndices[[currentPosition]], inputHashes[[currentPosition]],
        powers, maximum
      ];
      If[AssociationQ[payload],
        If[IntegerQ[Lookup[payload, "WorkerPeakBytes", Missing["Absent"]]],
          AppendTo[cachedWorkerPeaks, payload["WorkerPeakBytes"]]
        ];
        Clear[payload];
        True,
        Clear[payload];
        False
      ]
    ]
  ];
  ClearSystemCache[];
  pendingPositions = SortBy[
    Complement[positions, validPositions],
    Function[currentPosition,
      {-termLeafCounts[[currentPosition]], currentPosition}
    ]
  ];
  Print[
    "S12_TERM_RESUME: " <> label <> " completed=" <>
      ToString[Length[validPositions]] <> "/" <>
      ToString[Length[positions]] <> " missing=" <>
      ToString[Length[pendingPositions]]
  ];
  measuredWorkerPeak = If[
    Length[cachedWorkerPeaks] > 0,
    Max[cachedWorkerPeaks],
    Missing["NoMeasuredPeak"]
  ];
  workerMemoryEstimate = If[
    MissingQ[measuredWorkerPeak],
    initialWorkerMemoryEstimate[label],
    Max[minimumWorkerBudgetBytes, measuredWorkerPeak]
  ];
  Print[
    "S12_MEMORY_ESTIMATE: " <> label <> " measuredPeakGiB=" <>
      If[
        MissingQ[measuredWorkerPeak],
        "none",
        ToString[N[measuredWorkerPeak/gibibyte, 3]]
      ] <> " admittedEstimateGiB=" <>
      ToString[N[workerMemoryEstimate/gibibyte, 3]]
  ];
  Clear[cachedWorkerPeaks];
  maximumBatchSize = requestedParallelKernels;

  While[Length[pendingPositions] > 0,
    ensureParallelKernels[label];
    pendingPositions = SortBy[
      pendingPositions,
      Function[currentPosition,
        {-termLeafCounts[[currentPosition]], currentPosition}
      ]
    ];
    availableBytes = currentAvailableMemory[];
    usableBytes = availableBytes - memoryReserveBytes;
    If[usableBytes < minimumWorkerBudgetBytes,
      fatal[
        label <> " paused safely: available memory is " <>
          ToString[N[availableBytes/gibibyte, 3]] <>
          " GiB, below the " <>
          ToString[N[memoryReserveBytes/gibibyte, 3]] <>
          " GiB reserve plus one worker budget. " <>
          "Completed term checkpoints are intact."
      ]
    ];
    batchSize = Min[
      maximumBatchSize,
      Length[pendingPositions],
      Max[1, Floor[
        workerAllocationFraction usableBytes/
          (workerEstimateSafetyFactor workerMemoryEstimate)
      ]]
    ];
    isolatedLargeTerm =
      termLeafCounts[[First[pendingPositions]]] >=
        largeTermLeafThreshold;
    If[isolatedLargeTerm, batchSize = 1];
    batchMemoryLimit = Floor[
      workerAllocationFraction usableBytes/batchSize
    ];
    If[batchMemoryLimit < minimumWorkerBudgetBytes,
      fatal[
        label <> " paused safely because no worker can be admitted " <>
        "above the memory reserve. Completed checkpoints are intact."
      ]
    ];
    epochPositions = If[
      isolatedLargeTerm,
      {First[pendingPositions]},
      Take[pendingPositions, UpTo[maximumTermsPerEpoch]]
    ];
    submittedPositions = {};
    successfulPositions = {};
    successfulPeaks = {};
    evaluationQueue = {};
    nextEpochIndex = 1;
    stopSubmitting = False;
    submitPosition = Function[queuedPosition,
      With[
        {
          heldPosition = queuedPosition,
          heldTerm = terms[[queuedPosition]],
          heldPowers = powers,
          heldMaximum = maximum,
          heldMemoryLimit = batchMemoryLimit
        },
        ParallelSubmit[{
          heldPosition,
          singleTermSeriesCoefficients[
            heldTerm, heldPowers, heldMaximum, heldMemoryLimit
          ]
        }]
      ]
    ];
    Print[
      "S12_TERM_STAGE: " <> label <> " positions=" <>
        ToString[InputForm[epochPositions]] <> "/" <>
        ToString[Length[terms]] <> " active=" <>
        ToString[batchSize] <> " launched=" <>
        ToString[parallelKernelCount] <> " availableGiB=" <>
        ToString[N[availableBytes/gibibyte, 3]] <>
        " workerLimitGiB=" <>
        ToString[N[batchMemoryLimit/gibibyte, 3]] <> " epoch=" <>
        ToString[Length[epochPositions]] <> " isolatedLarge=" <>
        ToString[isolatedLargeTerm]
    ];
    While[
      nextEpochIndex <= Min[batchSize, Length[epochPositions]],
      position = epochPositions[[nextEpochIndex]];
      AppendTo[submittedPositions, position];
      AppendTo[evaluationQueue, submitPosition[position]];
      nextEpochIndex++
    ];
    While[Length[evaluationQueue] > 0,
      waitState = WaitNext[evaluationQueue];
      completedPair = First[waitState];
      evaluationQueue = Last[waitState];
      If[
        MatchQ[completedPair, {_Integer, _Association}] &&
          MemberQ[submittedPositions, completedPair[[1]]] &&
          ! MemberQ[successfulPositions, completedPair[[1]]] &&
          AssociationQ[
            Lookup[completedPair[[2]], "Coefficients", Missing["Absent"]]
          ] &&
          IntegerQ[
            Lookup[completedPair[[2]], "WorkerPeakBytes", Missing["Absent"]]
          ],
        completedPosition = completedPair[[1]];
        completedPayload = completedPair[[2]];
        writeTermPart[
          completedPayload, channel, projector, family,
          completedPosition, termIndices[[completedPosition]],
          inputHashes[[completedPosition]], powers, maximum
        ];
        AppendTo[successfulPositions, completedPosition];
        AppendTo[successfulPeaks, completedPayload["WorkerPeakBytes"]];
        Print[
          "S12_TERM_CHECKPOINT: " <> label <> " position " <>
            ToString[completedPosition] <> "/" <>
            ToString[Length[terms]]
        ],
        stopSubmitting = True
      ];
      Clear[waitState, completedPair, completedPayload];
      ClearSystemCache[];
      If[
        ! stopSubmitting && nextEpochIndex <= Length[epochPositions],
        position = epochPositions[[nextEpochIndex]];
        AppendTo[submittedPositions, position];
        AppendTo[evaluationQueue, submitPosition[position]];
        nextEpochIndex++
      ]
    ];
    failedPositions = Complement[
      submittedPositions,
      successfulPositions
    ];
    untouchedPositions = Drop[
      epochPositions,
      Length[submittedPositions]
    ];
    pendingPositions = Join[
      failedPositions,
      untouchedPositions,
      Drop[pendingPositions, Length[epochPositions]]
    ];
    If[Length[successfulPeaks] > 0,
      measuredWorkerPeak = If[
        MissingQ[measuredWorkerPeak],
        Max[successfulPeaks],
        Max[measuredWorkerPeak, Max[successfulPeaks]]
      ];
      workerMemoryEstimate = Max[
        minimumWorkerBudgetBytes,
        measuredWorkerPeak
      ]
    ];
    Clear[
      evaluationQueue, successfulPositions, successfulPeaks,
      submitPosition
    ];
    ClearSystemCache[];
    If[
      Length[pendingPositions] > 0,
      refreshParallelKernels[
        label <> " positions " <> ToString[submittedPositions]
      ],
      closeParallelKernels[
        label <> " completed positions " <> ToString[submittedPositions]
      ]
    ];
    If[Length[failedPositions] > 0,
      Print[
        "S12_MEMORY_RETRY: " <> label <> " positions " <>
          ToString[failedPositions] <>
          " exceeded their constrained allocation or failed; " <>
          "retrying with lower concurrency."
      ];
      If[batchSize === 1,
        fatal[
          label <> " position " <> ToString[First[failedPositions]] <>
            " cannot complete within the safe single-worker memory " <>
            "budget. All earlier term checkpoints are intact."
        ]
      ];
      maximumBatchSize = Max[1, Floor[batchSize/2]];
      workerMemoryEstimate = Max[
        workerMemoryEstimate,
        Ceiling[batchMemoryLimit/workerAllocationFraction]
      ]
    ];
  ];

  Print[
    "S12_TERM_AGGREGATE: streaming " <> ToString[Length[positions]] <>
      " saved parts for " <> label
  ];
  answer = AssociationMap[0 &, powers];
  Do[
    payload = loadValidTermPart[
      channel, projector, family, position, termIndices[[position]],
      inputHashes[[position]], powers, maximum
    ];
    assert[AssociationQ[payload],
      label <> " term checkpoint disappeared before aggregation."];
    Do[
      answer[power] = answer[power] + payload["Coefficients"][power],
      {power, powers}
    ];
    Clear[payload];
    ClearSystemCache[];,
    {position, positions}
  ];
  answer
];

If[TrueQ[Environment["S12_RESOURCE_SELF_TEST"] === "1"],
  Print["S12_RESOURCE_SELF_TEST_STAGE: starting guarded scheduler test"];
  s12TermPartRoot = FileNameJoin[{
    scriptDirectory, "s12_cache_v4_resource_selftest_parts"
  }];
  Print["S12_RESOURCE_SELF_TEST_STAGE: synthetic factor identity"];
  selfTestStructuredTerm =
    (1 + 2 epsilon + 3 epsilon^2) *
      (epsilon^-1 + 4 + 5 epsilon + 6 epsilon^2);
  selfTestStructuredPayload = singleTermSeriesCoefficients[
    selfTestStructuredTerm,
    {-1, 0, 1},
    1,
    minimumWorkerBudgetBytes
  ];
  assert[
    AssociationQ[selfTestStructuredPayload] &&
      selfTestStructuredPayload["Coefficients"] ===
        <|-1 -> 1, 0 -> 6, 1 -> 16|>,
    "The structured factor-Laurent identity failed."
  ];
  Print["S12_RESOURCE_SELF_TEST_STAGE: synthetic factor identity passed"];
  Print["S12_RESOURCE_SELF_TEST_STAGE: real endpoint outlier position 9"];
  selfTestEndpointPayload = Check[
    Get[endpointCachePath["Hqq;q_qbar_sameFlavor", "Pg"]],
    $Failed
  ];
  assert[
    AssociationQ[selfTestEndpointPayload] &&
      Length[selfTestEndpointPayload["FiniteCoefficients"]] >= 9,
    "The real endpoint outlier self-test input is unavailable."
  ];
  selfTestOutlierPayload = singleTermSeriesCoefficients[
    selfTestEndpointPayload["FiniteCoefficients"][[9]],
    {-1, 0, 1},
    1,
    minimumWorkerBudgetBytes
  ];
  assert[
    AssociationQ[selfTestOutlierPayload] &&
      AssociationQ[selfTestOutlierPayload["Coefficients"]] &&
      FreeQ[
        selfTestOutlierPayload["Coefficients"],
        epsilon | $Failed | Indeterminate | ComplexInfinity
      ],
    "The structured real endpoint outlier extraction failed."
  ];
  Print[
    "S12_RESOURCE_SELF_TEST_STRUCTURED_OUTLIER_PEAK_BYTES=",
    selfTestOutlierPayload["WorkerPeakBytes"]
  ];
  Print["S12_RESOURCE_SELF_TEST_STAGE: real endpoint outlier passed"];
  Clear[
    selfTestStructuredTerm, selfTestStructuredPayload,
    selfTestEndpointPayload, selfTestOutlierPayload
  ];
  ClearSystemCache[];
  Print["S12_RESOURCE_SELF_TEST_STAGE: parallel checkpoint queue"];
  selfTestTerms = Table[index + index epsilon, {index, 1, 9}];
  selfTestIndices = Range[Length[selfTestTerms]];
  selfTestChannel = "Hqq;qPrime_qbarPrime";
  selfTestProjector = "Pg";
  selfTestFamily = "scheduler_queue_roundtrip";
  selfTestFirst = termwiseSeriesCoefficients[
    selfTestTerms, selfTestIndices, {0}, 0,
    "S12 resource self-test", selfTestChannel,
    selfTestProjector, selfTestFamily
  ];
  selfTestPaths = termPartPath[
      selfTestChannel, selfTestProjector, selfTestFamily, #
    ] & /@ Range[Length[selfTestTerms]];
  assert[And @@ (FileExistsQ /@ selfTestPaths),
    "The self-test did not atomically write all term parts."];
  selfTestDates = FileDate /@ selfTestPaths;
  selfTestFirstHashes = FileHash[#, "SHA256"] & /@ selfTestPaths;
  selfTestSecond = termwiseSeriesCoefficients[
    selfTestTerms, selfTestIndices, {0}, 0,
    "S12 resource self-test", selfTestChannel,
    selfTestProjector, selfTestFamily
  ];
  assert[
    selfTestFirst === <|0 -> 45|> &&
    selfTestSecond === selfTestFirst &&
    TrueQ[parallelExecutionValidated] &&
    (FileDate /@ selfTestPaths) === selfTestDates &&
    (FileHash[#, "SHA256"] & /@ selfTestPaths) === selfTestFirstHashes,
    "The self-test write/aggregate/resume identity failed."
  ];
  Print["S12_RESOURCE_SELF_TEST_SUCCESS"];
  Quit[0]
];

splitVirtualEpsilonSums[term_] := Module[
  {factors, position, commonFactor, summands},
  If[FreeQ[term, epsilon], Return[{term}]];
  factors = If[Head[term] === Times, List @@ term, {term}];
  position = FirstPosition[
    factors,
    factor_ /; Head[factor] === Plus && ! FreeQ[factor, epsilon],
    Missing["NotFound"]
  ];
  If[MissingQ[position], Return[{term}]];
  commonFactor = Times @@ Delete[factors, First[position]];
  summands = List @@ Extract[factors, position];
  Flatten[
    (splitVirtualEpsilonSums[commonFactor #] &) /@ summands,
    1
  ]
];

virtualTermPower[term_] := Module[{factors, powers, power, coefficient},
  If[FreeQ[term, epsilon], Return[{0, term}]];
  factors = If[Head[term] === Times, List @@ term, {term}];
  powers = Map[
    Function[factor,
      Which[
        SameQ[factor, epsilon], 1,
        MatchQ[factor, Power[epsilon, _Integer]], factor[[2]],
        FreeQ[factor, epsilon], 0,
        True, 10^6
      ]
    ],
    factors
  ];
  assert[FreeQ[powers, 10^6],
    "A virtual Laurent term has nonmonomial epsilon dependence."];
  power = Total[powers];
  coefficient = term epsilon^(-power);
  assert[FreeQ[coefficient, epsilon],
    "A classified virtual Laurent coefficient retains epsilon."];
  {power, coefficient}
];

extractVirtualLaurentCoefficients[expression_, projector_String] := Module[
  {terms, classified, grouped},
  terms = If[Head[expression] === Plus, List @@ expression, {expression}];
  terms = Flatten[splitVirtualEpsilonSums /@ terms, 1];
  classified = virtualTermPower /@ terms;
  assert[Sort[DeleteDuplicates[classified[[All, 1]]]] === {-2, -1, 0},
    projector <> " virtual cache lacks an expected Laurent order."];
  grouped = GroupBy[classified, First -> Last, Total];
  <|
    "Minus2" -> grouped[-2],
    "Minus1" -> grouped[-1],
    "Finite" -> grouped[0]
  |>
];

(*
  S10 stores the Package-X Laurent polynomial in its evaluator convention.
  Convert it at the S10/S12 boundary to the paper's D-dimensional loop and
  explicit Hermitian-interference convention through

    (2 Pi/ScaleMu)^(2 epsilon)
      (1 - epsilon CA (1 + 24 I Pi)/(24 (CA + 2 CF))).

  Acting directly on the three saved coefficients avoids a new Series and
  preserves all completed real and virtual checkpoints.
*)
applyVirtualConvention[data_Association] := Module[
  {linear, quadratic},
  linear =
    2 Log[2 Pi/ScaleMu] -
      FeynCalc`CA (1 + 24 I Pi)/(
        24 (FeynCalc`CA + 2 FeynCalc`CF)
      );
  quadratic =
    2 Log[2 Pi/ScaleMu]^2 -
      FeynCalc`CA (1 + 24 I Pi) Log[2 Pi/ScaleMu]/(
        12 (FeynCalc`CA + 2 FeynCalc`CF)
      );
  <|
    "Minus2" -> data["Minus2"],
    "Minus1" -> data["Minus1"] + linear data["Minus2"],
    "Finite" ->
      data["Finite"] + linear data["Minus1"] +
        quadratic data["Minus2"]
  |>
];

physicalHermitianEndpointProjection[pair_Association] := Join[
  pair,
  <|"Endpoint" -> Re[pair["Endpoint"]]|>
];

pairAdd[pairs__Association] := Merge[{pairs}, Total];
pairScale[factor_, pair_Association] := Map[factor # &, pair];

pairToAction[pair_Association, projector_String] :=
  pair["Endpoint"] S10ConvolutionTest[projector, 0] +
    Inactive[Integrate][
      pair["IntegrandPhiS"] S10ConvolutionTest[projector, s23] +
        pair["IntegrandPhi0"] S10ConvolutionTest[projector, 0],
      {s23, 0, s23UpperB}
    ];

Print["S12_STAGE: loading and validating compact S11 input"];
assert[FileExistsQ[s11Path], "s11_result does not exist."];
s11 = Check[Get[s11Path], $Failed];
assert[AssociationQ[s11] &&
    s11["Status"] === "CompleteSymbolicCounterterms",
  "s11_result is absent, invalid, or incomplete."];
assert[And @@ Values[s11["Checks"]],
  "At least one S11 check is not True."];
assert[TrueQ[s11["CountertermCount"] === 4] &&
    Keys[s11["Counterterms"]] ===
      {"PgPDF", "PgFF", "PPPPDF", "PPPFF"},
  "S11 does not contain exactly the four expected counterterms."];
assert[FileExistsQ[paperPath], "The authoritative paper is absent."];

bornProjected = s11["BornProjectedSquaredAmplitudes"];
assert[Sort[Keys[bornProjected]] === Sort[{"Hqq", "Hqg", "Hgq"}],
  "S11 does not contain the three required Born channels."];
assert[And @@ (
    TrueQ[# === 0] & /@ Values[s11["HqqDirectRegenerationResiduals"]]
  ),
  "The saved S11 Hqq direct-regeneration residual is nonzero."];
Clear[s11];

Print["S12_STAGE: validating the S10/S09/S9.5 coefficient caches"];
assert[FileExistsQ[s10Path], "s10_result does not exist."];
assert[FileExistsQ[s10VirtualCachePath],
  "The validated S10 virtual Laurent cache does not exist."];
assert[And @@ Flatten@Table[
    FileExistsQ[s09RealCachePath[channel, projector]] &&
      FileExistsQ[endpointCachePath[channel, projector]],
    {channel, realChannels},
    {projector, projectors}
  ],
  "A required S09 real or S9.5 endpoint cache is absent."];

s23UpperB =
  Q2 (xi/xB - 1) (1 - zH) - PHT2/zH;

(* Exact S08 xi,zeta -> xi,s23 map. *)
xHatXi = xB/xi;
zetaXiS23 =
  (xHatXi PHT2 + zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi));
zHatXiS23 = zH/zetaXiS23;
k1TPartonic2XiS23 = PHT2/zetaXiS23^2;
xiS23Jacobian =
  (xHatXi^2 PHT2 + xHatXi zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi)^2);

expectedUpper =
  Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH;
assert[TrueQ[Together[s23UpperB - expectedUpper] === 0],
  "The S10 upper limit does not equal the exact S08 physical upper limit."];

bornM2[channel_String, projector_String, x_, z_, transverse2_] :=
  Together[
    bornProjected[channel, projector] /. {
      D -> 4 - 2 epsilon,
      sHat -> Q2 (1/x - 1),
      tHat -> -Q2 + z Q2 - transverse2/z,
      uHat -> -z Q2/x
    }
  ];

s23Function[x_, z_, transverse2_] :=
  Q2 (1/x - 1) (1 - z) - transverse2/z;

pdfScale = Q2 (1 - zHatXiS23)/xHatXi;
ffScale = Q2 (1/xHatXi - 1);
pdfSplittingVariable = 1 - s23/pdfScale;
ffSplittingVariable = 1 - s23/ffScale;

pdfInternalKinematics = <|
  "x" -> xHatXi/pdfSplittingVariable,
  "z" -> zHatXiS23,
  "k1T2" -> k1TPartonic2XiS23
|>;
ffInternalKinematics = <|
  "x" -> xHatXi,
  "z" -> zHatXiS23/ffSplittingVariable,
  "k1T2" ->
    k1TPartonic2XiS23/ffSplittingVariable^2
|>;

Print["S12_STAGE: validating the physical Eq. (46) delta roots"];
mappingResiduals = <|
  "ExternalS23" -> Together[
    s23Function[xHatXi, zHatXiS23, k1TPartonic2XiS23] - s23
  ],
  "PDFBornOnShell" -> Together[
    s23Function @@ Values[pdfInternalKinematics]
  ],
  "FFBornOnShell" -> Together[
    s23Function @@ Values[ffInternalKinematics]
  ],
  "PDFVariableAtEndpoint" -> Together[
    (pdfSplittingVariable /. s23 -> 0) - 1
  ],
  "FFVariableAtEndpoint" -> Together[
    (ffSplittingVariable /. s23 -> 0) - 1
  ]
|>;
assert[And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "At least one physical Eq. (46) mapping identity failed."];

twoBodyNormalization = (2 Pi)/(2 Pi)^4;
pdfBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          xiS23Jacobian twoBodyNormalization/pdfSplittingVariable *
            (*
              The PDF Born subprocess carries pPrime=y p.  Convert its
              saved PPP contraction pPrime^mu pPrime^nu to the external
              projector p^mu p^nu with 1/y^2.  Pg and both FF maps are
              unchanged.
            *)
            If[projector === "PPP", pdfSplittingVariable^-2, 1] *
            bornM2[
              channel,
              projector,
              pdfInternalKinematics["x"],
              pdfInternalKinematics["z"],
              pdfInternalKinematics["k1T2"]
            ]
        ]
      ],
      projectors
    ]
  ],
  {"Hqq", "Hgq"}
];
ffBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          xiS23Jacobian twoBodyNormalization/ffSplittingVariable *
            bornM2[
              channel,
              projector,
              ffInternalKinematics["x"],
              ffInternalKinematics["z"],
              ffInternalKinematics["k1T2"]
            ]
        ]
      ],
      projectors
    ]
  ],
  {"Hqq", "Hqg"}
];

(*
  After the Born delta is acted, the diagonal plus kernel maps to

    Integral_0^B ds (rho(s) Phi(s)-rho(0) Phi(0))/s
      + rho(0) Phi(0) Log[B/c(0)].

  The B/c(0) term follows by regulating y -> 1 before acting the Born delta;
  it is required because the physical outer s23 interval is shorter than the
  generic fixed-(xhat,zhat) S11 interval.
*)
pqqPair[density_, splittingVariable_, scale_] := Module[
  {density0, scale0},
  density0 = Together[density /. s23 -> 0];
  scale0 = Together[scale /. s23 -> 0];
  <|
    "Endpoint" -> 2 FeynCalc`CF density0 *
      (2 Log[s23UpperB/scale0] + 3/2),
    "IntegrandPhiS" -> 2 FeynCalc`CF (
      2 density/s23 - (1 + splittingVariable) density/scale
    ),
    "IntegrandPhi0" -> -4 FeynCalc`CF density0/s23
  |>
];

regularKernelPair[kernel_, density_, scale_] := <|
  "Endpoint" -> 0,
  "IntegrandPhiS" -> kernel density/scale,
  "IntegrandPhi0" -> 0
|>;

pgqKernel = 2 FeynCalc`CF (1 + (1 - pdfSplittingVariable)^2)/
  pdfSplittingVariable;
pqgKernel = 2 FeynCalc`TF (
  (1 - ffSplittingVariable)^2 + ffSplittingVariable^2
);

Print["S12_STAGE: constructing the four physically mapped counterterms"];
mappedCountertermComponents = AssociationMap[
  Function[projector,
    <|
      "PDF_Hqq_Pqq" -> pqqPair[
        pdfBornDensities["Hqq", projector],
        pdfSplittingVariable,
        pdfScale
      ],
      "PDF_Hgq_Pgq" -> regularKernelPair[
        pgqKernel,
        pdfBornDensities["Hgq", projector],
        pdfScale
      ],
      "FF_Hqq_Pqq" -> pqqPair[
        ffBornDensities["Hqq", projector],
        ffSplittingVariable,
        ffScale
      ],
      "FF_Hqg_Pqg" -> regularKernelPair[
        pqgKernel,
        ffBornDensities["Hqg", projector],
        ffScale
      ]
    |>
  ],
  projectors
];

mappedCountertermTotals = AssociationMap[
  Function[projector,
    pairAdd[
      mappedCountertermComponents[projector, "PDF_Hqq_Pqq"],
      mappedCountertermComponents[projector, "PDF_Hgq_Pgq"],
      mappedCountertermComponents[projector, "FF_Hqq_Pqq"],
      mappedCountertermComponents[projector, "FF_Hqg_Pqg"]
    ]
  ],
  projectors
];

(* Expand the unprefactored Eq. (46) actions A(epsilon). *)
mappedCountertermOrder0 = <||>;
mappedCountertermOrder1 = <||>;
Do[
  mappedCountertermOrder0[projector] = <||>;
  mappedCountertermOrder1[projector] = <||>;
  Do[
    countertermSeries = seriesChecked[
      mappedCountertermTotals[projector, field],
      1,
      projector <> " mapped counterterm " <> field
    ];
    assert[seriesMinimumPower[countertermSeries] >= 0,
      projector <> " mapped Born counterterm unexpectedly has an epsilon pole."];
    mappedCountertermOrder0[projector, field] =
      shiftedCoefficient[countertermSeries, 0, 0];
    mappedCountertermOrder1[projector, field] =
      shiftedCoefficient[countertermSeries, 0, 1];
    Clear[countertermSeries];,
    {field, pairFields}
  ];,
  {projector, projectors}
];

factorizationLoop = FeynCalc`SMP["g_s"]^2/(16 Pi^2);
sEpsilonLinearCoefficient = Log[4 Pi] - EulerGamma;
countertermPolePairs = AssociationMap[
  pairScale[factorizationLoop, mappedCountertermOrder0[#]] &,
  projectors
];
countertermFinitePairs = AssociationMap[
  Function[projector,
    pairScale[
      factorizationLoop,
      pairAdd[
        mappedCountertermOrder1[projector],
        pairScale[
          sEpsilonLinearCoefficient,
          mappedCountertermOrder0[projector]
        ]
      ]
    ]
  ],
  projectors
];

(*
  Low-memory reconstruction of the S10 Laurent data.

  Each S09 real cache has the exact factored form

    s23^(-epsilon) Prefactor(epsilon) Sum_i remainder_i(epsilon).

  S9.5 v3 stores the matching endpoint pole and finite coefficient for the
  standard alpha=1 terms and records the exceptional alpha=2 index/ratio.
  Expanding independent terms in bounded parallel batches avoids constructing
  a second copy of the multi-million-leaf weighted endpoint/regular sums.
  The S10 virtual cache is loaded only after all real-term workers are closed.
  It is already a four-term Laurent polynomial, so its terms are then
  classified by explicit monomial epsilon powers without a new Series.
*)
realLaurentPairs = <||>;
realEndpointMinus2ByChannel = <||>;
strongerEndpointPoleChecks = <||>;
Do[
  Print["S12_STAGE: termwise S10 real reconstruction for " <> projector];
  commonPrefactor = Missing["NotSet"];
  weightedRemainderCoefficients = <|-1 -> 0, 0 -> 0|>;
  weightedEndpointCoefficients = <|-1 -> 0, 0 -> 0, 1 -> 0|>;
  weightedStrongerPoleCoefficients = <|0 -> 0, 1 -> 0|>;
  specialAlpha2RemainderCoefficients = <|-1 -> 0, 0 -> 0|>;
  specialAlpha2EndpointRemainderCoefficients =
    <|-1 -> 0, 0 -> 0, 1 -> 0|>;
  specialAlpha2NestedRatio = Missing["NotSet"];
  endpointMinus1ByChannel = <||>;
  specialEndpointMinus1ByChannel = <||>;

  Do[
    realCache = Check[Get[s09RealCachePath[channel, projector]], $Failed];
    assert[AssociationQ[realCache] &&
        realCache["CacheVersion"] === 1 &&
        Head[realCache["Expression"]] === Times,
      channel <> " " <> projector <> " S09 real cache is invalid."];
    split = splitRealKernel[
      realCache["Expression"], channel <> " " <> projector
    ];
    If[MissingQ[commonPrefactor],
      commonPrefactor = split["Prefactor"],
      assert[SameQ[commonPrefactor, split["Prefactor"]],
        projector <> " real channels do not share the S10 prefactor."]
    ];

    endpointCache = Check[Get[endpointCachePath[channel, projector]], $Failed];
    assert[AssociationQ[endpointCache] &&
        endpointCache["CacheVersion"] === 3 &&
        endpointCache["RemainderTermCount"] === Length[split["Terms"]] &&
        ListQ[endpointCache["StandardTermIndices"]] &&
        Length[endpointCache["FiniteCoefficients"]] ===
          Length[endpointCache["StandardTermIndices"]] &&
        Length[endpointCache["PoleCoefficients"]] ===
          Length[endpointCache["StandardTermIndices"]],
      channel <> " " <> projector <> " S9.5 endpoint cache is invalid."];
    If[channel === "Hqq;q_qbar_sameFlavor",
      assert[
        Lookup[endpointCache, "CoupledLogEndpointRepairVersion", 0] ===
            coupledEndpointRepairVersion &&
          Lookup[endpointCache, "CoupledLogEndpointGroups", {}] ===
            coupledEndpointGroups[projector],
        channel <> " " <> projector <>
          " S9.5 endpoint cache predates the grouped physical-branch " <>
          "endpoint repair."]
    ];

    expectedSpecialIndex = If[
      channel === "Hqq;gg",
      ggAlpha2TermIndex[projector],
      Missing["NotApplicable"]
    ];
    specialIndex = endpointCache["SpecialAlpha2Index"];
    assert[SameQ[specialIndex, expectedSpecialIndex] &&
        TrueQ[endpointCache["SpecialAlpha2Validated"] ===
          ! MissingQ[specialIndex]],
      channel <> " " <> projector <>
        " S9.5 alpha metadata does not match corrected S10."];
    standardIndices = endpointCache["StandardTermIndices"];
    assert[Sort[Join[
          standardIndices,
          If[MissingQ[specialIndex], {}, {specialIndex}]
        ]] === Range[Length[split["Terms"]]],
      channel <> " " <> projector <>
        " S9.5 standard and alpha=2 indices do not cover the S09 terms."];
    standardRemainderTerms = split["Terms"][[standardIndices]];
    standardEndpointFiniteTerms = endpointCache["FiniteCoefficients"];
    standardStrongerPoleTerms = endpointCache["PoleCoefficients"];

    coefficientCacheFile = s12CoefficientCachePath[channel, projector];
    coefficientCache = If[
      FileExistsQ[coefficientCacheFile],
      Check[Get[coefficientCacheFile], $Failed],
      <|
        "CacheVersion" -> 3,
        "Channel" -> channel,
        "Projector" -> projector,
        "TermCount" -> Length[split["Terms"]],
        "StandardTermIndices" -> standardIndices,
        "SpecialAlpha2Index" -> specialIndex,
        "EndpointRepairVersion" -> If[
          channel === "Hqq;q_qbar_sameFlavor",
          coupledEndpointRepairVersion,
          Missing["NotApplicable"]
        ]
      |>
    ];
    assert[AssociationQ[coefficientCache] &&
        coefficientCache["CacheVersion"] === 3 &&
        coefficientCache["Channel"] === channel &&
        coefficientCache["Projector"] === projector &&
        coefficientCache["TermCount"] === Length[split["Terms"]] &&
        coefficientCache["StandardTermIndices"] === standardIndices &&
        SameQ[coefficientCache["SpecialAlpha2Index"], specialIndex] &&
        (channel =!= "Hqq;q_qbar_sameFlavor" ||
          Lookup[coefficientCache, "EndpointRepairVersion", 0] ===
            coupledEndpointRepairVersion),
      channel <> " " <> projector <> " S12 coefficient cache is invalid."];

    If[! FileExistsQ[coefficientCacheFile],
      atomicPut[coefficientCache, coefficientCacheFile]
    ];
    Clear[coefficientCache];
    If[MissingQ[specialIndex],
      Clear[realCache, split, endpointCache]
    ];
    ClearSystemCache[];

    remainderTermCoefficients = loadCoefficientCacheField[
      coefficientCacheFile,
      "RemainderCoefficients"
    ];
    If[AssociationQ[remainderTermCoefficients],
      Print["S12_STAGE: loading cached regular coefficients for " <>
        channel <> " " <> projector],
      assert[MissingQ[remainderTermCoefficients],
        channel <> " " <> projector <>
          " cached regular coefficients are invalid."];
      remainderTermCoefficients = termwiseSeriesCoefficients[
        standardRemainderTerms, standardIndices, {-1, 0}, 0,
        channel <> " " <> projector <> " regular remainder",
        channel, projector, "regular_remainder"
      ];
      mergeCoefficientCacheFields[
        coefficientCacheFile,
        <|"RemainderCoefficients" -> remainderTermCoefficients|>
      ];
    ];
    Do[
      weightedRemainderCoefficients[power] +=
        realChannelWeights[channel] remainderTermCoefficients[power],
      {power, {-1, 0}}
    ];
    Clear[remainderTermCoefficients, standardRemainderTerms];
    ClearSystemCache[];

    endpointTermCoefficients = loadCoefficientCacheField[
      coefficientCacheFile,
      "EndpointFiniteCoefficients"
    ];
    If[AssociationQ[endpointTermCoefficients],
      Print["S12_STAGE: loading cached endpoint coefficients for " <>
        channel <> " " <> projector],
      assert[MissingQ[endpointTermCoefficients],
        channel <> " " <> projector <>
          " cached endpoint coefficients are invalid."];
      endpointTermCoefficients = termwiseSeriesCoefficients[
        standardEndpointFiniteTerms, standardIndices, {-1, 0, 1}, 1,
        channel <> " " <> projector <> " endpoint finite coefficients",
        channel, projector, "endpoint_finite"
      ];
      mergeCoefficientCacheFields[
        coefficientCacheFile,
        <|"EndpointFiniteCoefficients" -> endpointTermCoefficients|>
      ];
    ];
    Do[
      weightedEndpointCoefficients[power] +=
        realChannelWeights[channel] endpointTermCoefficients[power],
      {power, {-1, 0, 1}}
    ];
    endpointMinus1ByChannel[channel] = endpointTermCoefficients[-1];
    Clear[endpointTermCoefficients, standardEndpointFiniteTerms];
    ClearSystemCache[];

    strongerPoleTermCoefficients = loadCoefficientCacheField[
      coefficientCacheFile,
      "StrongerPoleCoefficients"
    ];
    If[AssociationQ[strongerPoleTermCoefficients],
      Print["S12_STAGE: loading cached stronger-pole coefficients for " <>
        channel <> " " <> projector],
      assert[MissingQ[strongerPoleTermCoefficients],
        channel <> " " <> projector <>
          " cached stronger-pole coefficients are invalid."];
      strongerPoleTermCoefficients = termwiseSeriesCoefficients[
        standardStrongerPoleTerms, standardIndices, {0, 1}, 1,
        channel <> " " <> projector <>
          " endpoint stronger-pole coefficients",
        channel, projector, "stronger_pole"
      ];
      mergeCoefficientCacheFields[
        coefficientCacheFile,
        <|"StrongerPoleCoefficients" -> strongerPoleTermCoefficients|>
      ];
    ];
    Do[
      weightedStrongerPoleCoefficients[power] +=
        realChannelWeights[channel] strongerPoleTermCoefficients[power],
      {power, {0, 1}}
    ];
    Clear[strongerPoleTermCoefficients, standardStrongerPoleTerms];
    ClearSystemCache[];

    If[MissingQ[specialIndex],
      specialRemainderTermCoefficients = <|-1 -> 0, 0 -> 0|>;
      specialEndpointRemainderTermCoefficients =
        <|-1 -> 0, 0 -> 0, 1 -> 0|>,
      specialTerm = split["Terms"][[specialIndex]];
      nestedBases = Cases[
        specialTerm,
        Power[base_, -1 - epsilon] :> base,
        Infinity
      ];
      assert[Length[nestedBases] === 1,
        channel <> " " <> projector <>
          " special endpoint term lacks its unique nested base."];
      nestedBase = First[nestedBases];
      nestedRatio = Cancel[Together[nestedBase/s23]];
      nestedRatioEndpoint = Cancel[Together[nestedRatio /. s23 -> 0]];
      assert[FreeQ[nestedRatio, epsilon] && TrueQ[
          Cancel[Together[nestedRatioEndpoint - zH^2/PHT2]] === 0
        ] && TrueQ[
          Cancel[Together[
            endpointCache["SpecialAlpha2NestedRatioEndpoint"] -
              nestedRatioEndpoint
          ]] === 0
        ],
        channel <> " " <> projector <>
          " special nested endpoint ratio is inconsistent with S9.5 v3."];
      If[MissingQ[specialAlpha2NestedRatio],
        specialAlpha2NestedRatio = nestedRatio,
        assert[TrueQ[
            Cancel[Together[specialAlpha2NestedRatio - nestedRatio]] === 0
          ],
          projector <> " has inconsistent alpha=2 nested ratios."]
      ];
      specialRemainder =
        specialTerm/Power[nestedBase, -1 - epsilon];
      specialEndpointRemainder = Quiet@Check[
        TimeConstrained[specialRemainder /. s23 -> 0, 600, $Failed],
        $Failed
      ];
      assert[FreeQ[
          specialEndpointRemainder,
          s23 | $Failed | Indeterminate | Infinity | ComplexInfinity |
            Power[0, _?Negative]
        ],
        channel <> " " <> projector <>
          " alpha=2 remainder endpoint is not finite."];
      specialRemainderTermCoefficients = loadCoefficientCacheField[
        coefficientCacheFile,
        "SpecialAlpha2RemainderCoefficients"
      ];
      specialEndpointRemainderTermCoefficients =
        loadCoefficientCacheField[
          coefficientCacheFile,
          "SpecialAlpha2EndpointRemainderCoefficients"
        ];
      If[
        AssociationQ[specialRemainderTermCoefficients] &&
          AssociationQ[specialEndpointRemainderTermCoefficients],
        Print["S12_STAGE: loading cached alpha=2 remainder for " <>
          channel <> " " <> projector],
        assert[
          (MissingQ[specialRemainderTermCoefficients] ||
            AssociationQ[specialRemainderTermCoefficients]) &&
          (MissingQ[specialEndpointRemainderTermCoefficients] ||
            AssociationQ[specialEndpointRemainderTermCoefficients]),
          channel <> " " <> projector <>
            " cached alpha=2 coefficients are invalid."
        ];
        Clear[
          specialRemainderTermCoefficients,
          specialEndpointRemainderTermCoefficients
        ];
        ClearSystemCache[];
        specialRemainderTermCoefficients = termwiseSeriesCoefficients[
          {specialRemainder}, {specialIndex}, {-1, 0}, 0,
          channel <> " " <> projector <> " alpha=2 remainder",
          channel, projector, "alpha2_remainder"
        ];
        specialEndpointRemainderTermCoefficients =
          termwiseSeriesCoefficients[
            {specialEndpointRemainder}, {specialIndex}, {-1, 0, 1}, 1,
            channel <> " " <> projector <>
              " alpha=2 endpoint remainder",
            channel, projector, "alpha2_endpoint"
          ];
        mergeCoefficientCacheFields[
          coefficientCacheFile,
          <|
            "SpecialAlpha2RemainderCoefficients" ->
              specialRemainderTermCoefficients,
            "SpecialAlpha2EndpointRemainderCoefficients" ->
              specialEndpointRemainderTermCoefficients
          |>
        ];
      ]
    ];
    assert[FileExistsQ[coefficientCacheFile] &&
        FileByteCount[coefficientCacheFile] > 0,
      channel <> " " <> projector <> " coefficient cache was not written."];

    Do[
      specialAlpha2RemainderCoefficients[power] +=
        realChannelWeights[channel] specialRemainderTermCoefficients[power],
      {power, {-1, 0}}
    ];
    Do[
      specialAlpha2EndpointRemainderCoefficients[power] +=
        realChannelWeights[channel] *
          specialEndpointRemainderTermCoefficients[power],
      {power, {-1, 0, 1}}
    ];
    specialEndpointMinus1ByChannel[channel] =
      specialEndpointRemainderTermCoefficients[-1];

    Clear[
      realCache, split, endpointCache, coefficientCacheFile,
      coefficientCache, remainderTermCoefficients,
      endpointTermCoefficients, strongerPoleTermCoefficients,
      expectedSpecialIndex, specialIndex, standardIndices,
      standardRemainderTerms,
      standardEndpointFiniteTerms, standardStrongerPoleTerms,
      specialRemainderTermCoefficients,
      specialEndpointRemainderTermCoefficients,
      specialTerm, nestedBases, nestedBase, nestedRatio,
      nestedRatioEndpoint, specialRemainder, specialEndpointRemainder
    ];
    ClearSystemCache[];,
    {channel, realChannels}
  ];

  prefactorSeries = seriesChecked[
    commonPrefactor,
    1,
    projector <> " common real prefactor"
  ];
  endpointPrefactorSeries = seriesChecked[
    commonPrefactor /. s23 -> 0,
    2,
    projector <> " endpoint common prefactor"
  ];
  assert[seriesMinimumPower[prefactorSeries] >= 0 &&
      seriesMinimumPower[endpointPrefactorSeries] >= 0,
    projector <> " common real prefactor unexpectedly has an epsilon pole."];

  prefactor0 = shiftedCoefficient[prefactorSeries, 0, 0];
  prefactor1 = shiftedCoefficient[prefactorSeries, 0, 1];
  endpointPrefactor0 = shiftedCoefficient[endpointPrefactorSeries, 0, 0];
  endpointPrefactor1 = shiftedCoefficient[endpointPrefactorSeries, 0, 1];
  endpointPrefactor2 = shiftedCoefficient[endpointPrefactorSeries, 0, 2];

  rMinus1 = s23 prefactor0 weightedRemainderCoefficients[-1];
  r0 = s23 (
    prefactor0 weightedRemainderCoefficients[0] +
      prefactor1 weightedRemainderCoefficients[-1]
  );
  eMinus1 = endpointPrefactor0 weightedEndpointCoefficients[-1];
  e0 = endpointPrefactor0 weightedEndpointCoefficients[0] +
    endpointPrefactor1 weightedEndpointCoefficients[-1];
  e1 = endpointPrefactor0 weightedEndpointCoefficients[1] +
    endpointPrefactor1 weightedEndpointCoefficients[0] +
    endpointPrefactor2 weightedEndpointCoefficients[-1];
  assert[! MissingQ[specialAlpha2NestedRatio],
    projector <> " lacks its alpha=2 nested ratio."];
  rho = specialAlpha2NestedRatio;
  rhoEndpoint = Cancel[Together[rho /. s23 -> 0]];
  assert[FreeQ[rho, epsilon] && TrueQ[
      Cancel[Together[rhoEndpoint - zH^2/PHT2]] === 0
    ],
    projector <> " alpha=2 nested ratio is invalid."];
  specialKernel0 = prefactor0/rho;
  specialKernel1 =
    (prefactor1 - prefactor0 Log[rho])/rho;
  specialEndpointKernel0 = endpointPrefactor0/rhoEndpoint;
  specialEndpointKernel1 =
    (endpointPrefactor1 - endpointPrefactor0 Log[rhoEndpoint])/
      rhoEndpoint;
  specialEndpointKernel2 =
    (endpointPrefactor2 - endpointPrefactor1 Log[rhoEndpoint] +
      endpointPrefactor0 Log[rhoEndpoint]^2/2)/rhoEndpoint;
  gMinus1 = specialKernel0 specialAlpha2RemainderCoefficients[-1];
  g0 = specialKernel0 specialAlpha2RemainderCoefficients[0] +
    specialKernel1 specialAlpha2RemainderCoefficients[-1];
  aMinus1 = specialEndpointKernel0 *
    specialAlpha2EndpointRemainderCoefficients[-1];
  a0 = specialEndpointKernel0 *
      specialAlpha2EndpointRemainderCoefficients[0] +
    specialEndpointKernel1 *
      specialAlpha2EndpointRemainderCoefficients[-1];
  a1 = specialEndpointKernel0 *
      specialAlpha2EndpointRemainderCoefficients[1] +
    specialEndpointKernel1 *
      specialAlpha2EndpointRemainderCoefficients[0] +
      specialEndpointKernel2 *
      specialAlpha2EndpointRemainderCoefficients[-1];

  If[projector === "Pg",
    realEndpointMinus2ByChannel[projector] = <|
      "Hqq;gg alpha=1" ->
        -endpointPrefactor0 realChannelWeights["Hqq;gg"] *
          endpointMinus1ByChannel["Hqq;gg"],
      "Hqq;gg alpha=2" ->
        -specialEndpointKernel0 realChannelWeights["Hqq;gg"] *
          specialEndpointMinus1ByChannel["Hqq;gg"]/2,
      "Hqq;q_qbar_sameFlavor" ->
        -endpointPrefactor0 *
          realChannelWeights["Hqq;q_qbar_sameFlavor"] *
          endpointMinus1ByChannel["Hqq;q_qbar_sameFlavor"],
      "Hqq;qPrime_qbarPrime" ->
        -endpointPrefactor0 *
          realChannelWeights["Hqq;qPrime_qbarPrime"] *
          endpointMinus1ByChannel["Hqq;qPrime_qbarPrime"]
    |>
  ];

  strongerEndpointPoleChecks[projector] = <|
    "Epsilon0" -> zeroEquivalentResidual[
      weightedStrongerPoleCoefficients[0],
      projector <> " weighted stronger endpoint pole epsilon^0"
    ],
    "Epsilon1" -> zeroEquivalentResidual[
      weightedStrongerPoleCoefficients[1],
      projector <> " weighted stronger endpoint pole epsilon^1"
    ]
  |>;
  assert[And @@ (
      TrueQ[# === 0] & /@ Values[strongerEndpointPoleChecks[projector]]
    ),
    projector <> " weighted stronger endpoint pole contributes through finite order."];

  logB = Log[s23UpperB];
  logSOverB = Log[s23/s23UpperB];
  realLaurentPairs[projector] = <|
    "Minus2" -> <|
      "Endpoint" -> -eMinus1 - aMinus1/2,
      "IntegrandPhiS" -> 0,
      "IntegrandPhi0" -> 0
    |>,
    "Minus1" -> <|
      "Endpoint" ->
        -e0 + logB eMinus1 - a0/2 + logB aMinus1,
      "IntegrandPhiS" -> (rMinus1 + gMinus1)/s23,
      "IntegrandPhi0" -> (-eMinus1 - aMinus1)/s23
    |>,
    "Finite" -> <|
      "Endpoint" ->
        -e1 + logB e0 - logB^2 eMinus1/2 -
          a1/2 + logB a0 - logB^2 aMinus1,
      "IntegrandPhiS" ->
        (r0 - (logB + logSOverB) rMinus1 +
          g0 - 2 (logB + logSOverB) gMinus1)/s23,
      "IntegrandPhi0" ->
        (-e0 + (logB + logSOverB) eMinus1 -
          a0 + 2 (logB + logSOverB) aMinus1)/s23
    |>
  |>;

  Clear[
    commonPrefactor, weightedRemainderCoefficients,
    weightedEndpointCoefficients, weightedStrongerPoleCoefficients,
    specialAlpha2RemainderCoefficients,
    specialAlpha2EndpointRemainderCoefficients,
    specialAlpha2NestedRatio,
    prefactorSeries, endpointPrefactorSeries,
    prefactor0, prefactor1, endpointPrefactor0,
    endpointPrefactor1, endpointPrefactor2,
    rho, rhoEndpoint, specialKernel0, specialKernel1,
    specialEndpointKernel0, specialEndpointKernel1,
    specialEndpointKernel2,
    rMinus1, r0, eMinus1, e0, e1,
    gMinus1, g0, aMinus1, a0, a1,
    logB, logSOverB,
    endpointMinus1ByChannel, specialEndpointMinus1ByChannel
  ];
  ClearSystemCache[];,
  {projector, projectors}
];
closeParallelKernels["all real-term Laurent reconstruction"];
Print["S12_STAGE: loading the completed S10 virtual Laurent cache"];
virtualPayload = Check[Get[s10VirtualCachePath], $Failed];
assert[AssociationQ[virtualPayload] &&
    virtualPayload["CacheVersion"] === 2 &&
    TrueQ[virtualPayload["RegulatorsUnifiedAfterUVCheck"]] &&
    virtualPayload["OrdersRetained"] === {-2, -1, 0},
  "The S10 virtual Laurent cache is invalid."];
virtualCoefficientDataRaw = AssociationMap[
  extractVirtualLaurentCoefficients[
    virtualPayload["LaurentThroughFinite", #], #
  ] &,
  projectors
];
virtualCoefficientData = AssociationMap[
  applyVirtualConvention[virtualCoefficientDataRaw[#]] &,
  projectors
];
Clear[virtualPayload, virtualCoefficientDataRaw];
ClearSystemCache[];

s10LaurentPairs = AssociationMap[
  Function[projector,
    <|
      "Minus2" -> <|
        "Endpoint" ->
          virtualCoefficientData[projector, "Minus2"] +
            realLaurentPairs[projector, "Minus2", "Endpoint"],
        "IntegrandPhiS" ->
          realLaurentPairs[projector, "Minus2", "IntegrandPhiS"],
        "IntegrandPhi0" ->
          realLaurentPairs[projector, "Minus2", "IntegrandPhi0"]
      |>,
      "Minus1" -> <|
        "Endpoint" ->
          virtualCoefficientData[projector, "Minus1"] +
            realLaurentPairs[projector, "Minus1", "Endpoint"],
        "IntegrandPhiS" ->
          realLaurentPairs[projector, "Minus1", "IntegrandPhiS"],
        "IntegrandPhi0" ->
          realLaurentPairs[projector, "Minus1", "IntegrandPhi0"]
      |>,
      "Finite" -> <|
        "Endpoint" ->
          virtualCoefficientData[projector, "Finite"] +
            realLaurentPairs[projector, "Finite", "Endpoint"],
        "IntegrandPhiS" ->
          realLaurentPairs[projector, "Finite", "IntegrandPhiS"],
        "IntegrandPhi0" ->
          realLaurentPairs[projector, "Finite", "IntegrandPhi0"]
      |>
    |>
  ],
  projectors
];
doublePoleEndpointComponents = <|
  "Pg" -> Join[
    <|"Virtual Hqq;g" -> virtualCoefficientData["Pg", "Minus2"]|>,
    realEndpointMinus2ByChannel["Pg"]
  ]
|>;
Clear[
  virtualCoefficientData, realLaurentPairs,
  realEndpointMinus2ByChannel
];
ClearSystemCache[];

Print["S12_STAGE: adding Eq. (46) and checking every pole component"];
evaluatePoleResidual[projector_, order_, field_] := Module[
  {residualExpression, diagnosticComponents, result},
  Print[
    "S12_POLE_STAGE: projector=", projector,
    " order=", order, " field=", field
  ];
  residualExpression = If[order === "Minus2",
    s10LaurentPairs[projector, order, field],
    s10LaurentPairs[projector, order, field] +
      countertermPolePairs[projector, field]
  ];
  diagnosticComponents = If[order === "Minus2",
    If[projector === "Pg" && field === "Endpoint",
      doublePoleEndpointComponents["Pg"],
      Missing["NotEndpoint"]
    ],
    <|
      "S10RealPlusVirtual" ->
        s10LaurentPairs[projector, order, field],
      "Eq46Counterterm" ->
        countertermPolePairs[projector, field]
    |>
  ];
  result = zeroEquivalentResidual[
    residualExpression,
    projector <> " epsilon^-" <>
      If[order === "Minus2", "2 ", "1 "] <> field,
    diagnosticComponents
  ];
  If[projector === "Pg" && order === "Minus2" &&
      field === "Endpoint",
    Clear[doublePoleEndpointComponents]
  ];
  Clear[residualExpression, diagnosticComponents];
  ClearSystemCache[];
  result
];

poleResiduals = AssociationMap[
  Function[projector,
    <|
      "Minus2" -> AssociationMap[
        evaluatePoleResidual[projector, "Minus2", #] &,
        pairFields
      ],
      "Minus1" -> AssociationMap[
        evaluatePoleResidual[projector, "Minus1", #] &,
        pairFields
      ]
    |>
  ],
  projectors
];

assert[And @@ Flatten[
    Table[
      TrueQ[poleResiduals[projector, order, field] === 0],
      {projector, projectors},
      {order, {"Minus2", "Minus1"}},
      {field, pairFields}
    ]
  ],
  "At least one S12 collinear pole did not cancel."];
Clear[doublePoleEndpointComponents, evaluatePoleResidual];

s10FinitePairs = AssociationMap[
  s10LaurentPairs[#, "Finite"] &,
  projectors
];
Clear[s10LaurentPairs];
ClearSystemCache[];

finitePairs = AssociationMap[
  Map[
    (# /. qcdAndConstantRules) &,
    pairAdd[s10FinitePairs[#], countertermFinitePairs[#]]
  ] &,
  projectors
];
Clear[s10FinitePairs];
ClearSystemCache[];
Print[
  "S12_STAGE: applying the physical Hermitian real projection to finite " <>
    "virtual endpoints"
];
finitePairs = AssociationMap[
  physicalHermitianEndpointProjection[finitePairs[#]] &,
  projectors
];
assert[And @@ (
    ! FreeQ[finitePairs[#, "Endpoint"], _Re] & /@ projectors
  ),
  "The finite virtual endpoints do not retain the physical real projection."];
finiteHardFunctions = AssociationMap[
  pairToAction[finitePairs[#], #] &,
  projectors
];

forbiddenFinalObjects =
  _SeriesData | S11SEpsilon | _S11ConvolutionTest |
    _S11PlusDistribution | DiracDelta[s23] |
    _S09EndpointValue | _S09PlusDistribution;

s12Checks = <|
  "S10ValidatedCachesAndS11InputValidated" -> True,
  "NoWholeExpressionSeriesOnLargeS10Branches" -> True,
  "S9P5V3StandardAndAlpha2MetadataUsed" -> True,
  "SpecialAlpha2ExpandedFactorwise" -> True,
  "StructuredSummandAndFactorLaurentExtractionEnabled" -> True,
  "BoundedParallelKernelCapConfigured" ->
    TrueQ[1 <= requestedParallelKernels <= 8],
  "AllParallelWorkersClosedBeforeVirtualLoad" ->
    TrueQ[$KernelCount === 0],
  "VirtualLaurentCacheDeferredUntilWorkersClosed" -> True,
  "OneAggregateCoefficientCacheFieldLoadedAtATime" -> True,
  "DiskBackedPerTermResumeEnabled" -> True,
  "AtomicCheckpointWritesEnabled" -> True,
  "AdaptiveMemoryAdmissionAndWorkerLimitsEnabled" -> True,
  "StructuralOutliersRunAlone" -> True,
  "WorkersRecycledAfterEveryBoundedEpoch" -> True,
  "TwoGGNestedEndpointPowersRefactoredAsAlpha2" -> True,
  "PgEvanescentStrongerEndpointPoleAbsentThroughFiniteOrder" ->
    And @@ (TrueQ[# === 0] & /@
      Values[strongerEndpointPoleChecks["Pg"]]),
  "PPPEvanescentStrongerEndpointPoleAbsentThroughFiniteOrder" ->
    And @@ (TrueQ[# === 0] & /@
      Values[strongerEndpointPoleChecks["PPP"]]),
  "ExactlyFourS11CountertermsUsed" -> True,
  "PhysicalS08MapRebuiltBeforeDistributionAction" -> True,
  "AllMappedBornDeltaRootsValidated" ->
    And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "PaperSEpsilonExpandedOnlyAsFarAsFiniteOrderRequires" -> True,
  "StandardQCDTFHalfApplied" -> True,
  "PgDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@
      Values[poleResiduals["Pg", "Minus2"]]),
  "PgSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@
      Values[poleResiduals["Pg", "Minus1"]]),
  "PPPDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@
      Values[poleResiduals["PPP", "Minus2"]]),
  "PPPSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@
      Values[poleResiduals["PPP", "Minus1"]]),
  "PhysicalHermitianFiniteEndpointProjectionApplied" ->
    And @@ (
      ! FreeQ[finitePairs[#, "Endpoint"], _Re] & /@ projectors
    ),
  "FiniteFunctionsContainNoEpsilon" ->
    And @@ (FreeQ[#, epsilon] & /@ Values[finiteHardFunctions]),
  "FiniteFunctionsContainNoDistributionPlaceholder" ->
    And @@ (FreeQ[#, forbiddenFinalObjects] & /@
      Values[finiteHardFunctions]),
  "FiniteFunctionsRetainOrdinaryS23Integral" ->
    And @@ (! FreeQ[#, Inactive[Integrate][___]] & /@
      Values[finiteHardFunctions]),
  "FiniteFunctionsRetainArbitrarySymbolicTest" ->
    And @@ (! FreeQ[#, _S10ConvolutionTest] & /@
      Values[finiteHardFunctions]),
  "CalculationFullySymbolic" -> True
|>;
assert[And @@ Values[s12Checks],
  "At least one final S12 validation check is not True."];

s12Result = <|
  "Status" -> "CompleteFiniteFactorizedHqq",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> <|
    "UVRenormalizedRealVirtual" -> s10Path,
    "VirtualLaurentCache" -> s10VirtualCachePath,
    "ExpandedRealCaches" -> AssociationMap[
      Function[channel,
        AssociationMap[
          s09RealCachePath[channel, #] &,
          projectors
        ]
      ],
      realChannels
    ],
    "EndpointCoefficientCaches" -> AssociationMap[
      Function[channel,
        AssociationMap[
          endpointCachePath[channel, #] &,
          projectors
        ]
      ],
      realChannels
    ],
    "S12LaurentCoefficientCaches" -> AssociationMap[
      Function[channel,
        AssociationMap[
          s12CoefficientCachePath[channel, #] &,
          projectors
        ]
      ],
      realChannels
    ],
    "S12Version4TermPartCacheRoot" -> s12TermPartRoot,
    "FourCollinearCountertermsAndBornInputs" -> s11Path,
    "AuthoritativePaper" -> paperPath
  |>,
  "PaperReference" -> <|
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "SplittingFunctions" -> "Eqs. (51)-(53)"
  |>,
  "PhysicalMap" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "XHat" -> xHatXi,
    "ZHat" -> zHatXiS23,
    "PartonicTransverseMomentumSquared" -> k1TPartonic2XiS23,
    "Jacobian" -> xiS23Jacobian,
    "PDFSplittingVariable" -> pdfSplittingVariable,
    "FFSplittingVariable" -> ffSplittingVariable,
    "Checks" -> mappingResiduals
  |>,
  "FactorizationConvention" -> <|
    "Sign" ->
      "positive Eq. (46) counterterms added to the UV-renormalized unsubtracted S10 result",
    "LoopFactor" -> HoldForm[
      alphaS/(4 Pi) == FeynCalc`SMP["g_s"]^2/(16 Pi^2)
    ],
    "SEpsilonThroughRequiredOrder" -> HoldForm[
      S11SEpsilon ==
        1 + epsilon (Log[4 Pi] - EulerGamma) + O[epsilon]^2
    ],
    "ColorNormalization" -> HoldForm[FeynCalc`TF == 1/2],
    "HermitianFiniteProjection" -> HoldForm[
      EndpointFinitePhysical == Re[EndpointFiniteAfterEq46]
    ]
  |>,
  "ParallelExecution" -> <|
    "RequestedKernelCount" -> requestedParallelKernels,
    "ValidatedKernelIDsSeen" -> parallelKernelIDsSeen,
    "KernelExecutable" -> parallelKernelExecutable,
    "ParallelizedWork" ->
      "independent per-term Laurent expansions with two lazily launched workers; live available memory selects one or two active terms and structural outliers run alone",
    "MemorySafety" -> <|
      "PhysicalMemoryReserveBytes" -> memoryReserveBytes,
      "MinimumWorkerBudgetBytes" -> minimumWorkerBudgetBytes,
      "WorkerAllocationFraction" -> workerAllocationFraction,
      "LargeTermLeafThreshold" -> largeTermLeafThreshold,
      "MaximumTermsPerEpoch" -> maximumTermsPerEpoch,
      "PerWorkerMemoryConstrained" -> True,
      "SummandWiseFactorLaurentExtraction" -> True,
      "OneAggregateCoefficientCacheFieldLoadedAtATime" -> True,
      "LazyWorkerLaunch" -> True,
      "CloseWorkersBeforeAggregationAndVirtualLoad" -> True,
      "RecycleAllWorkersAfterEveryBoundedEpoch" -> True,
      "SafeFailurePolicy" ->
        "checkpoint successful terms, reduce concurrency after a constrained failure, and exit cleanly with checkpoints intact if one term cannot fit"
    |>,
    "CacheWritePolicy" ->
      "only the main kernel atomically writes SHA-256-bound version-4 term parts and complete version-3 coefficient caches; aggregation streams one term part at a time"
  |>,
  "EndpointSingularityRepair" -> <|
    "AffectedTerms" -> <|
      "Hqq;gg Pg" -> ggAlpha2TermIndex["Pg"],
      "Hqq;gg PPP" -> ggAlpha2TermIndex["PPP"]
    |>,
    "Finding" ->
      "each term contains a nested base B(s23)^(-1-epsilon) with B(s23)/s23 -> zH^2/PHT2; together with the explicit S09 s23^(-epsilon), the correct endpoint power is s23^(-1-2 epsilon)",
    "Action" ->
      "consume corrected S9.5 v3 standard indices exactly once; expand each exceptional remainder separately, convolve it with the common prefactor and nested ratio coefficients, and apply the alpha=2 delta/plus expansion without downstream double counting"
  |>,
  "MappedCountertermComponents" -> mappedCountertermComponents,
  "MappedCountertermLaurentPairs" -> <|
    "Pole" -> countertermPolePairs,
    "Finite" -> countertermFinitePairs
  |>,
  "EvanescentStrongerEndpointPoleChecks" -> strongerEndpointPoleChecks,
  "PoleResiduals" -> poleResiduals,
  "FiniteCoefficientPairsByProjector" -> finitePairs,
  "FiniteHattedHardFunctionsByProjector" -> finiteHardFunctions,
  "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s23=0 and independent of epsilon",
  "Checks" -> s12Checks,
  "NotPerformedAtThisStage" -> {
    "outer xi convolution with a concrete PDF",
    "choice or numerical evaluation of PDFs, fragmentation functions, or kinematics"
  }
|>;

Print["S12_STAGE: writing finite factorized Hqq result"];
atomicPut[s12Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "s12_result was not written or is empty."];

Print["S12_SUCCESS_FINITE_FACTORIZED_HQQ"];
Print["S12_RESULT_PATH=" <> resultPath];
Print["S12_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S12_POLE_RESIDUALS=", InputForm[poleResiduals]];
Print["S12_CHECKS=", InputForm[s12Checks]];
Quit[0];

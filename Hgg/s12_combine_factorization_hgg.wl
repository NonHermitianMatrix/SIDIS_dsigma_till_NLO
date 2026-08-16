(* ::Package:: *)

(*
  S12 for Hgg: combine the endpoint-resolved real action from S10 with the
  four Eq. (46) Pqg/Pgq counterterms from S11, prove every epsilon pole
  component vanishes, and save the finite symbolic hard functions.

  The large S10 Laurent expansion is performed source term by source term.
  Every completed term is atomically checkpointed so an interrupted WSL run
  resumes without repeating validated algebra.
*)

$HistoryLength = 0;

Needs["FeynCalc`"];

$HistoryLength = 0;

ClearAll["Global`*"];

fatal[message_String] := (
  Print["S12_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s10Path = FileNameJoin[{scriptDirectory, "s10_result"}];
s11Path = FileNameJoin[{scriptDirectory, "s11_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s12_result"}];
countertermCachePath = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_mapped_counterterms"
}];
partCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_s10_laurent_parts"
}];
aggregateCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_s10_laurent"
}];
residualDiagnosticPath = FileNameJoin[{
  scriptDirectory, "s12_last_nonzero_residual"
}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

stageVersion = "HggS12-v2";
cacheVersion = 2;
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
laurentPowers = {-2, -1, 0};
expectedOrdinaryTermCounts = <|"Pg" -> 69, "PPP" -> 93|>;
gibibyte = 1024^3;
perTermMemoryLimit = 4 gibibyte;
residualMemoryLimit = 5 gibibyte;
residualReductionTimeoutSeconds = 1200;
maximumNewTermsPerKernelEpoch = 16;
newTermsThisKernelEpoch = 0;

qcdAndConstantRules = {
  FeynCalc`TF -> 1/2,
  FeynCalc`CF ->
    (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA),
  S09HggFlavorChargeSum -> HggFlavorChargeSum,
  S11HggFlavorChargeSum -> HggFlavorChargeSum,
  PolyGamma[0, 1/2] -> -EulerGamma - 2 Log[2],
  Log[16] -> 4 Log[2],
  Log[8] -> 3 Log[2],
  Log[4] -> 2 Log[2]
};

physicalAssumptions =
  0 < xB < xi < 1 && 0 < zH < 1 && Q2 > 0 && PHT2 > 0 &&
    ScaleMu > 0;

feynCalcOwnedSymbolNames = {"CF", "CA", "TF", "SMP", "FCGV"};

accidentalGlobalFeynCalcSymbolQ[symbol_Symbol] := TrueQ[
  Context[Unevaluated[symbol]] === "Global`" &&
    MemberQ[
      feynCalcOwnedSymbolNames,
      SymbolName[Unevaluated[symbol]]
    ]
];

feynCalcContextCleanQ[expression_] := FreeQ[
  expression,
  _Symbol?accidentalGlobalFeynCalcSymbolQ,
  {0, Infinity},
  Heads -> True
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
    fatal["Atomic write failed for " <> path <> "."]
  ];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Atomic temporary file is absent or empty for " <> path <> "."];
  Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    fatal["Atomic rename failed for " <> path <> "."]
  ];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic destination is absent or empty for " <> path <> "."];
  path
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

seriesMinimumPower[series_] := If[
  Head[series] === SeriesData,
  series[[4]]/series[[6]],
  0
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
  pilotData = summandwiseSeriesCoefficientData[#, 0] & /@
    dependentFactors;
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
  ] := Module[{answer},
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
          branchAnswers =
            nonPiecewiseSeriesCoefficients[#, powers, maximum] & /@
              branchValues;
          defaultAnswer = nonPiecewiseSeriesCoefficients[
            defaultValue, powers, maximum
          ];
          If[MemberQ[branchAnswers, $Failed] ||
              defaultAnswer === $Failed,
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
  If[! AssociationQ[answer] ||
      Sort[Keys[answer]] =!= Sort[powers] ||
      ! FreeQ[
        answer,
        epsilon | _SeriesData | $Failed | Indeterminate |
          ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
      ],
    Return[$Failed]
  ];
  answer
];

partCachePath[
    projector_String, family_String, position_Integer
  ] := FileNameJoin[{
  partCacheRoot,
  ToLowerCase[projector] <> "_" <> ToLowerCase[family] <> "_" <>
    IntegerString[position, 10, 4]
}];

validPartPayloadQ[
    payload_, projector_String, family_String, position_Integer,
    termHash_Integer, s10SHA256_Integer
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Family", Missing["Absent"]] === family &&
  Lookup[payload, "Position", Missing["Absent"]] === position &&
  Lookup[payload, "TermSHA256", Missing["Absent"]] === termHash &&
  AssociationQ[Lookup[payload, "Coefficients", Missing["Absent"]]] &&
  Sort[Keys[payload["Coefficients"]]] === Sort[laurentPowers] &&
  FreeQ[
    payload["Coefficients"],
    epsilon | _SeriesData | $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
  ] &&
  feynCalcContextCleanQ[payload["Coefficients"]]
];

processS10Term[
    term_, projector_String, family_String, position_Integer,
    s10SHA256_Integer
  ] := Module[
  {path, termHash, payload, coefficients},
  path = partCachePath[projector, family, position];
  termHash = Hash[term, "SHA256"];
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[validPartPayloadQ[
        payload, projector, family, position, termHash, s10SHA256
      ],
      Print[
        "S12_TERM_RESUME: ", projector, " ", family,
        " position ", position
      ];
      Clear[payload];
      Return[path]
    ];
    Print["S12_TERM_CACHE_INVALID: deleting ", path];
    DeleteFile[path];
    Clear[payload]
  ];
  If[newTermsThisKernelEpoch >= maximumNewTermsPerKernelEpoch,
    Print[
      "S12_MEMORY_EPOCH_PAUSE: completed ",
      newTermsThisKernelEpoch,
      " new terms in this kernel; restart required before ",
      projector, " ", family, " position ", position
    ];
    Quit[75]
  ];
  Print[
    "S12_TERM_STAGE: ", projector, " ", family,
    " position ", position, " leafCount=", LeafCount[term],
    " memoryGiB=", N[MemoryInUse[]/gibibyte, 3]
  ];
  coefficients = singleTermSeriesCoefficients[
    term, laurentPowers, 0, perTermMemoryLimit
  ];
  If[coefficients === $Failed,
    fatal[
      projector <> " " <> family <> " position " <>
        ToString[position] <> " Laurent extraction failed or exceeded its " <>
        "bounded resource limit."
    ]
  ];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "S10SHA256" -> s10SHA256,
      "Projector" -> projector,
      "Field" -> "IntegrandPhiS",
      "Family" -> family,
      "Position" -> position,
      "TermSHA256" -> termHash,
      "Powers" -> laurentPowers,
      "Coefficients" -> coefficients
    |>,
    path
  ];
  newTermsThisKernelEpoch++;
  Print[
    "S12_TERM_CHECKPOINT: ", projector, " ", family,
    " position ", position
  ];
  Clear[coefficients];
  ClearSystemCache[];
  path
];

aggregateCachePath[projector_String, power_Integer] :=
  FileNameJoin[{
    aggregateCacheRoot,
    ToLowerCase[projector] <> "_power_" <>
      StringReplace[ToString[power], "-" -> "minus"]
  }];

validAggregatePayloadQ[
    payload_, projector_String, power_Integer, s10SHA256_Integer,
    partHashes_List
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Power", Missing["Absent"]] === power &&
  Lookup[payload, "PartSHA256", Missing["Absent"]] === partHashes &&
  KeyExistsQ[payload, "Coefficient"] &&
  FreeQ[
    payload["Coefficient"],
    epsilon | _SeriesData | $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
  ] &&
  feynCalcContextCleanQ[payload["Coefficient"]]
];

aggregateS10Parts[
    projector_String, power_Integer, paths_List, s10SHA256_Integer
  ] := Module[
  {path, partHashes, payload, sum, partPayload},
  path = aggregateCachePath[projector, power];
  partHashes = FileHash[#, "SHA256"] & /@ paths;
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[validAggregatePayloadQ[
        payload, projector, power, s10SHA256, partHashes
      ],
      Print[
        "S12_AGGREGATE_RESUME: ", projector,
        " epsilon^", power
      ];
      Clear[payload];
      Return[path]
    ];
    Print["S12_AGGREGATE_CACHE_INVALID: deleting ", path];
    DeleteFile[path];
    Clear[payload]
  ];
  Print[
    "S12_AGGREGATE_STAGE: ", projector, " epsilon^", power,
    " parts=", Length[paths]
  ];
  sum = 0;
  Do[
    partPayload = Quiet@Check[Get[paths[[position]]], $Failed];
    assert[AssociationQ[partPayload],
      "A validated S10 term cache became unreadable during aggregation."];
    sum = sum + Lookup[partPayload["Coefficients"], power, 0];
    Clear[partPayload];,
    {position, Length[paths]}
  ];
  assert[FreeQ[sum, epsilon | _SeriesData | $Failed],
    projector <> " aggregate coefficient is invalid."];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "S10SHA256" -> s10SHA256,
      "Projector" -> projector,
      "Field" -> "IntegrandPhiS",
      "Power" -> power,
      "PartSHA256" -> partHashes,
      "Coefficient" -> sum
    |>,
    path
  ];
  Print[
    "S12_AGGREGATE_CHECKPOINT: ", projector,
    " epsilon^", power, " leafCount=", LeafCount[sum]
  ];
  Clear[sum];
  ClearSystemCache[];
  path
];

loadAggregateCoefficient[
    projector_String, power_Integer
  ] := Module[{payload, coefficient},
  payload = Quiet@Check[
    Get[aggregateCachePath[projector, power]],
    $Failed
  ];
  assert[AssociationQ[payload] && KeyExistsQ[payload, "Coefficient"],
    "S10 aggregate Laurent cache is unreadable for " <> projector <>
      " epsilon^" <> ToString[power] <> "."];
  coefficient = payload["Coefficient"];
  Clear[payload];
  coefficient
];

projectorCompletePath[projector_String] := FileNameJoin[{
  aggregateCacheRoot,
  ToLowerCase[projector] <> "_complete"
}];

validProjectorCompletePayloadQ[
    payload_, projector_String, s10SHA256_Integer
  ] := Module[{aggregatePaths},
  aggregatePaths = aggregateCachePath[projector, #] & /@ laurentPowers;
  TrueQ[
    AssociationQ[payload] &&
    Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
    Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
    Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
    Lookup[payload, "Projector", Missing["Absent"]] === projector &&
    And @@ (FileExistsQ /@ aggregatePaths) &&
    Lookup[payload, "AggregateSHA256", Missing["Absent"]] ===
      (FileHash[#, "SHA256"] & /@ aggregatePaths)
  ]
];

actionToPair[action_, projector_String] := Module[
  {
    integrals, integral, specification, body, upper,
    endpointExpression, endpoint, integrandPhiS, integrandPhi0,
    testOccurrences
  },
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]],
    {0, Infinity}
  ];
  assert[Length[integrals] === 1,
    projector <> " S10 action does not contain exactly one ordinary integral."];
  integral = First[integrals];
  specification = integral[[2]];
  body = integral[[1]];
  upper = specification[[3]];
  assert[TrueQ[Cancel[Together[upper - s23UpperB]] === 0],
    projector <> " S10 integral upper limit differs from the S08 map."];
  endpointExpression = action /.
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]] :> 0;
  endpoint = Coefficient[
    endpointExpression,
    S10ConvolutionTest[projector, 0]
  ];
  integrandPhiS = Coefficient[
    body,
    S10ConvolutionTest[projector, s23]
  ];
  integrandPhi0 = Coefficient[
    body,
    S10ConvolutionTest[projector, 0]
  ];
  testOccurrences = DeleteDuplicates@Cases[
    action,
    test_S10ConvolutionTest :> HoldComplete[test],
    Infinity
  ];
  assert[
    Length[testOccurrences] >= 1 && And @@ (
      MemberQ[
        {
          HoldComplete[S10ConvolutionTest[projector, s23]],
          HoldComplete[S10ConvolutionTest[projector, 0]]
        },
        #
      ] & /@ testOccurrences
    ),
    projector <> " S10 action contains an unexpected test-function argument."
  ];
  <|
    "Endpoint" -> endpoint,
    "IntegrandPhiS" -> integrandPhiS,
    "IntegrandPhi0" -> integrandPhi0
  |>
];

splitHggPhiS[expression_, projector_String] := Module[
  {
    topTerms, sizes, largePosition, alphaPosition, largeTerm,
    alphaTerm, factors, plusPositions, remainderPosition,
    ordinaryRemainder, ordinaryPrefactor, ordinaryTerms
  },
  topTerms = If[Head[expression] === Plus, List @@ expression, {expression}];
  assert[Length[topTerms] === 2,
    projector <> " IntegrandPhiS is not the validated two-family sum."];
  sizes = LeafCount /@ topTerms;
  largePosition = First@Ordering[sizes, -1];
  alphaPosition = First@Complement[Range[2], {largePosition}];
  largeTerm = topTerms[[largePosition]];
  alphaTerm = topTerms[[alphaPosition]];
  factors = If[Head[largeTerm] === Times, List @@ largeTerm, {largeTerm}];
  plusPositions = Select[
    Range[Length[factors]],
    Head[factors[[#]]] === Plus &
  ];
  assert[Length[plusPositions] >= 1,
    projector <> " ordinary family has no additive source remainder."];
  remainderPosition = First@MaximalBy[
    plusPositions,
    LeafCount[factors[[#]]] &
  ];
  ordinaryRemainder = factors[[remainderPosition]];
  ordinaryPrefactor = Times @@ Delete[factors, remainderPosition];
  ordinaryTerms = List @@ ordinaryRemainder;
  assert[
    Length[ordinaryTerms] === expectedOrdinaryTermCounts[projector],
    projector <> " ordinary family term count changed from the validated S10 contract."
  ];
  <|
    "Alpha2Term" -> alphaTerm,
    "OrdinaryPrefactor" -> ordinaryPrefactor,
    "OrdinaryTerms" -> ordinaryTerms
  |>
];

processS10Projector[projector_String, s10SHA256_Integer] := Module[
  {
    s10, action, pair, split, alphaPath, ordinaryPaths, allPaths,
    position, term, completionPath, completionPayload, aggregatePaths
  },
  completionPath = projectorCompletePath[projector];
  If[FileExistsQ[completionPath],
    completionPayload = Quiet@Check[Get[completionPath], $Failed];
    If[validProjectorCompletePayloadQ[
        completionPayload, projector, s10SHA256
      ],
      Print["S12_S10_PROJECTOR_RESUME_COMPLETE: ", projector];
      Clear[completionPayload];
      Return[Null]
    ];
    Print["S12_PROJECTOR_MARKER_INVALID: deleting ", completionPath];
    DeleteFile[completionPath];
    Clear[completionPayload]
  ];
  Print["S12_S10_STAGE: loading ", projector, " action only"];
  s10 = Quiet@Check[Get[s10Path], $Failed];
  assert[AssociationQ[s10] &&
      s10["Status"] === "CompleteSymbolic" &&
      s10["Channel"] === "Hgg only" &&
      And @@ Values[s10["Checks"]],
    "S10 result is absent, invalid, or incomplete."];
  action = s10["DistributionActions"]["RealByProjector"][projector];
  assert[feynCalcContextCleanQ[action],
    projector <> " S10 action contains accidental Global-context " <>
      "FeynCalc/QCD symbols."];
  pair = actionToPair[action, projector];
  Clear[action, s10];
  assert[TrueQ[pair["Endpoint"] === 0] &&
      TrueQ[pair["IntegrandPhi0"] === 0],
    projector <> " unexpectedly has a nonzero endpoint or phi(0) S10 field."];
  split = splitHggPhiS[pair["IntegrandPhiS"], projector];
  Clear[pair];
  Print[
    "S12_S10_PARTITION: ", projector,
    " alpha2=1 regular=", Length[split["OrdinaryTerms"]]
  ];
  alphaPath = processS10Term[
    split["Alpha2Term"], projector, "Alpha2", 1, s10SHA256
  ];
  ordinaryPaths = Table[
    term = split["OrdinaryPrefactor"] split["OrdinaryTerms"][[position]];
    processS10Term[
      term, projector, "Regular", position, s10SHA256
    ],
    {position, Length[split["OrdinaryTerms"]]}
  ];
  allPaths = Prepend[ordinaryPaths, alphaPath];
  Clear[split, term, ordinaryPaths, alphaPath];
  ClearSystemCache[];
  Do[
    aggregateS10Parts[projector, power, allPaths, s10SHA256],
    {power, laurentPowers}
  ];
  aggregatePaths = aggregateCachePath[projector, #] & /@ laurentPowers;
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "S10SHA256" -> s10SHA256,
      "Projector" -> projector,
      "AggregateSHA256" ->
        (FileHash[#, "SHA256"] & /@ aggregatePaths)
    |>,
    completionPath
  ];
  Print["S12_S10_PROJECTOR_COMPLETE: ", projector];
  Clear[allPaths, aggregatePaths];
  ClearSystemCache[];
];

validCountertermCacheQ[
    payload_, s11SHA256_Integer, paperSHA256_Integer
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "S11SHA256", Missing["Absent"]] === s11SHA256 &&
  Lookup[payload, "PaperSHA256", Missing["Absent"]] === paperSHA256 &&
  AssociationQ[Lookup[payload, "Order0", Missing["Absent"]]] &&
  AssociationQ[Lookup[payload, "Order1", Missing["Absent"]]] &&
  And @@ Flatten@Table[
    AssociationQ[payload[order][projector]] &&
      Sort[Keys[payload[order][projector]]] === Sort[pairFields] &&
      FreeQ[payload[order][projector], epsilon | _SeriesData | $Failed],
    {order, {"Order0", "Order1"}},
    {projector, projectors}
  ] &&
  feynCalcContextCleanQ[{payload["Order0"], payload["Order1"]}]
];

regularKernelPair[kernel_, density_, scale_] := <|
  "Endpoint" -> 0,
  "IntegrandPhiS" -> kernel density/scale,
  "IntegrandPhi0" -> 0
|>;

Print["S12_STAGE: validating S10, S11, and authoritative paper bindings"];
assert[FileExistsQ[s10Path], "s10_result does not exist."];
assert[FileExistsQ[s11Path], "s11_result does not exist."];
assert[FileExistsQ[paperPath], "The authoritative paper does not exist."];
s10SHA256 = FileHash[s10Path, "SHA256"];
s11SHA256 = FileHash[s11Path, "SHA256"];
paperSHA256 = FileHash[paperPath, "SHA256"];

s10Metadata = Quiet@Check[Get[s10Path], $Failed];
assert[AssociationQ[s10Metadata] &&
    s10Metadata["Status"] === "CompleteSymbolic" &&
    s10Metadata["Channel"] === "Hgg only" &&
    And @@ Values[s10Metadata["Checks"]] &&
    FileExistsQ[s10Metadata["SourceResult"]] &&
    FileHash[s10Metadata["SourceResult"], "SHA256"] ===
      s10Metadata["SourceResultSHA256"],
  "S10 metadata or its upstream source binding is invalid."];
Clear[s10Metadata];
ClearSystemCache[];

s11 = Quiet@Check[Get[s11Path], $Failed];
assert[AssociationQ[s11] &&
    s11["Status"] === "CompleteSymbolicCounterterms" &&
    s11["Channel"] === "Hgg only" &&
    s11["StageVersion"] === "HggS11-v1" &&
    And @@ Values[s11["Checks"]] &&
    s11["CountertermCount"] === 4 &&
    Keys[s11["Counterterms"]] ===
      {"PgPDF", "PgFF", "PPPPDF", "PPPFF"} &&
    s11["SourceResults"]["AuthoritativePaperSHA256"] === paperSHA256,
  "S11 result, counterterm schema, or paper binding is invalid."];
bornProjected = s11["BornProjectedSquaredAmplitudes"];
assert[
  Sort[Keys[bornProjected]] ===
    Sort[{"Hqg", "HqbarG", "Hgq", "Hgqbar"}] &&
    And @@ Flatten@Table[
      KeyExistsQ[bornProjected[channel], projector],
      {channel, Keys[bornProjected]},
      {projector, projectors}
    ],
  "S11 does not contain all four required charge-resolved Born channels."
];
assert[feynCalcContextCleanQ[bornProjected],
  "S11 Born objects contain accidental Global-context FeynCalc/QCD symbols."];
Clear[s11];

s23UpperB = Q2 (xi/xB - 1) (1 - zH) - PHT2/zH;
xHatXi = xB/xi;
zetaXiS23 =
  (xHatXi PHT2 + zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi));
zHatXiS23 = zH/zetaXiS23;
k1TPartonic2XiS23 = PHT2/zetaXiS23^2;
xiS23Jacobian =
  (xHatXi^2 PHT2 + xHatXi zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi)^2);

expectedUpper = Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH;
assert[TrueQ[Together[s23UpperB - expectedUpper] === 0],
  "The S10 upper limit does not equal the S08 physical upper limit."];

bornM2[channel_String, projector_String, x_, z_, transverse2_] :=
  Together[
    bornProjected[channel][projector] /. {
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
  "k1T2" -> k1TPartonic2XiS23/ffSplittingVariable^2
|>;

mappingResiduals = <|
  "ExternalS23" -> Together[
    s23Function[xHatXi, zHatXiS23, k1TPartonic2XiS23] - s23
  ],
  "PDFBornOnShell" -> Together[
    s23Function[
      pdfInternalKinematics["x"],
      pdfInternalKinematics["z"],
      pdfInternalKinematics["k1T2"]
    ]
  ],
  "FFBornOnShell" -> Together[
    s23Function[
      ffInternalKinematics["x"],
      ffInternalKinematics["z"],
      ffInternalKinematics["k1T2"]
    ]
  ],
  "PDFVariableAtEndpoint" -> Together[
    (pdfSplittingVariable /. s23 -> 0) - 1
  ],
  "FFVariableAtEndpoint" -> Together[
    (ffSplittingVariable /. s23 -> 0) - 1
  ]
|>;
assert[And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "At least one physical Eq. (46) delta-root identity failed."];

Print["S12_STAGE: loading or constructing mapped Hgg Eq. (46) cache"];
countertermPayload = If[
  FileExistsQ[countertermCachePath],
  Quiet@Check[Get[countertermCachePath], $Failed],
  Missing["Absent"]
];

If[! validCountertermCacheQ[countertermPayload, s11SHA256, paperSHA256],
  If[FileExistsQ[countertermCachePath],
    Print["S12_COUNTERTERM_CACHE_INVALID: deleting ", countertermCachePath];
    DeleteFile[countertermCachePath]
  ];
  twoBodyNormalization = (2 Pi)/(2 Pi)^4;
  flavorChargeWeight = 9 HggFlavorChargeSum;
  pdfBornDensities = AssociationMap[
    Function[channel,
      AssociationMap[
        Function[projector,
          Together[
            xiS23Jacobian twoBodyNormalization/
              pdfSplittingVariable *
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
    {"Hqg", "HqbarG"}
  ];
  ffBornDensities = AssociationMap[
    Function[channel,
      AssociationMap[
        Function[projector,
          Together[
            xiS23Jacobian twoBodyNormalization/
              ffSplittingVariable *
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
    {"Hgq", "Hgqbar"}
  ];
  pqgPDFKernel = 2 FeynCalc`TF (
    (1 - pdfSplittingVariable)^2 + pdfSplittingVariable^2
  );
  pgqFFKernel = 2 FeynCalc`CF (
    1 + (1 - ffSplittingVariable)^2
  )/ffSplittingVariable;
  mappedCountertermComponents = AssociationMap[
    Function[projector,
      <|
        "PDF_Hqg_Pqg" -> pairScale[
          flavorChargeWeight,
          regularKernelPair[
            pqgPDFKernel,
            pdfBornDensities["Hqg"][projector],
            pdfScale
          ]
        ],
        "PDF_HqbarG_Pqg" -> pairScale[
          flavorChargeWeight,
          regularKernelPair[
            pqgPDFKernel,
            pdfBornDensities["HqbarG"][projector],
            pdfScale
          ]
        ],
        "FF_Hgq_Pgq" -> pairScale[
          flavorChargeWeight,
          regularKernelPair[
            pgqFFKernel,
            ffBornDensities["Hgq"][projector],
            ffScale
          ]
        ],
        "FF_Hgqbar_Pgq" -> pairScale[
          flavorChargeWeight,
          regularKernelPair[
            pgqFFKernel,
            ffBornDensities["Hgqbar"][projector],
            ffScale
          ]
        ]
      |>
    ],
    projectors
  ];
  mappedCountertermTotals = AssociationMap[
    Function[projector,
      pairAdd @@ Values[mappedCountertermComponents[projector]]
    ],
    projectors
  ];
  mappedOrder0 = <||>;
  mappedOrder1 = <||>;
  Do[
    mappedOrder0[projector] = <||>;
    mappedOrder1[projector] = <||>;
    Do[
      If[TrueQ[mappedCountertermTotals[projector][field] === 0],
        mappedOrder0[projector][field] = 0;
        mappedOrder1[projector][field] = 0,
        Print[
          "S12_COUNTERTERM_SERIES: ", projector, " ", field,
          " leafCount=", LeafCount[mappedCountertermTotals[projector][field]]
        ];
        countertermCoefficients = singleTermSeriesCoefficients[
          mappedCountertermTotals[projector][field],
          {0, 1},
          1,
          2 gibibyte
        ];
        If[countertermCoefficients === $Failed,
          fatal[projector <> " mapped counterterm " <> field <>
            " epsilon expansion failed."]
        ];
        mappedOrder0[projector][field] = countertermCoefficients[0];
        mappedOrder1[projector][field] = countertermCoefficients[1];
        Clear[countertermCoefficients]
      ];,
      {field, pairFields}
    ];,
    {projector, projectors}
  ];
  countertermPayload = <|
    "CacheVersion" -> cacheVersion,
    "StageVersion" -> stageVersion,
    "S11SHA256" -> s11SHA256,
    "PaperSHA256" -> paperSHA256,
    "MappingResiduals" -> mappingResiduals,
    "Order0" -> mappedOrder0,
    "Order1" -> mappedOrder1,
    "Species" -> {
      "PDF_Hqg", "PDF_HqbarG", "FF_Hgq", "FF_Hgqbar"
    },
    "SplittingKernels" -> {"PqgPDF", "PgqFF"},
    "FlavorWeightPerSpecies" -> flavorChargeWeight,
    "PPPPDFProjectorRescaling" -> HoldForm[1/y^2]
  |>;
  atomicPut[countertermPayload, countertermCachePath];
  Print["S12_COUNTERTERM_CHECKPOINT: mapped cache complete"];
  Clear[
    pdfBornDensities, ffBornDensities, mappedCountertermComponents,
    mappedCountertermTotals, mappedOrder0, mappedOrder1
  ];
  ClearSystemCache[],
  Print["S12_COUNTERTERM_RESUME: validated mapped cache"]
];

assert[validCountertermCacheQ[
    countertermPayload, s11SHA256, paperSHA256
  ],
  "Mapped Hgg counterterm cache failed its final validation."];
mappedCountertermOrder0 = countertermPayload["Order0"];
mappedCountertermOrder1 = countertermPayload["Order1"];
Clear[countertermPayload, bornProjected];
ClearSystemCache[];

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
Clear[mappedCountertermOrder0, mappedCountertermOrder1];
ClearSystemCache[];

Print[
  "S12_STAGE: extracting S10 Laurent coefficients serially with bounded " <>
    "per-term memory"
];
Do[
  processS10Projector[projector, s10SHA256],
  {projector, projectors}
];
If[newTermsThisKernelEpoch > 0,
  Print[
    "S12_MEMORY_EPOCH_PAUSE: completed projector checkpoint work; " <>
      "restarting before pole reduction"
  ];
  Quit[75]
];

zeroEquivalentResidual[
    expression_, label_String,
    components_: Missing["NotCaptured"]
  ] := Module[
  {residual, reduced, diagnosticPayload},
  residual = expression /. qcdAndConstantRules;
  If[TrueQ[residual === 0], Return[0]];
  Print[
    "S12_POLE_REDUCTION_STAGE: ", label,
    " leafCount=", LeafCount[residual]
  ];
  reduced = Quiet@Check[
    MemoryConstrained[
      TimeConstrained[
        Cancel[Together[residual]],
        residualReductionTimeoutSeconds,
        $Failed
      ],
      residualMemoryLimit,
      $Failed
    ],
    $Failed
  ];
  If[TrueQ[reduced === 0],
    Print["S12_POLE_REDUCTION_RESULT: ", label, " exact zero"];
    Return[0]
  ];
  If[reduced === $Failed, reduced = residual];
  reduced = Quiet@Check[
    MemoryConstrained[
      TimeConstrained[
        FullSimplify[reduced, Assumptions -> physicalAssumptions],
        residualReductionTimeoutSeconds,
        $Failed
      ],
      residualMemoryLimit,
      $Failed
    ],
    $Failed
  ];
  If[TrueQ[reduced === 0],
    Print["S12_POLE_REDUCTION_RESULT: ", label, " exact zero"];
    Return[0]
  ];
  diagnosticPayload = <|
    "SchemaVersion" -> 1,
    "StageVersion" -> stageVersion,
    "Label" -> label,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ReductionFailedOrTimedOut" -> TrueQ[reduced === $Failed],
    "LeafCount" -> LeafCount[If[reduced === $Failed, residual, reduced]],
    "Expression" -> If[reduced === $Failed, residual, reduced]
  |>;
  If[AssociationQ[components],
    AssociateTo[diagnosticPayload, "Components" -> components]
  ];
  atomicPut[diagnosticPayload, residualDiagnosticPath];
  fatal[
    "Nonzero or unreduced residual: " <> label <>
      ". Exact diagnostic was written to " <> residualDiagnosticPath <> "."
  ]
];

If[FileExistsQ[residualDiagnosticPath], DeleteFile[residualDiagnosticPath]];

Print["S12_STAGE: adding Eq. (46) and checking every pole component"];
poleResiduals = <||>;
Do[
  poleResiduals[projector] = <|"Minus2" -> <||>, "Minus1" -> <||>|>;
  Do[
    Do[
      Print[
        "S12_POLE_STAGE: projector=", projector,
        " order=", order, " field=", field
      ];
      s10Coefficient = If[
        field === "IntegrandPhiS",
        loadAggregateCoefficient[
          projector,
          If[order === "Minus2", -2, -1]
        ],
        0
      ];
      residualExpression = If[
        order === "Minus2",
        s10Coefficient,
        s10Coefficient + countertermPolePairs[projector][field]
      ];
      poleResiduals[projector][order][field] =
        zeroEquivalentResidual[
          residualExpression,
          projector <> " epsilon^-" <>
            If[order === "Minus2", "2 ", "1 "] <> field,
          <|
            "S10Real" -> s10Coefficient,
            "Eq46Counterterm" -> If[
              order === "Minus2",
              0,
              countertermPolePairs[projector][field]
            ]
          |>
        ];
      Clear[s10Coefficient, residualExpression];
      ClearSystemCache[];,
      {field, pairFields}
    ];,
    {order, {"Minus2", "Minus1"}}
  ];,
  {projector, projectors}
];

assert[And @@ Flatten@Table[
    TrueQ[poleResiduals[projector][order][field] === 0],
    {projector, projectors},
    {order, {"Minus2", "Minus1"}},
    {field, pairFields}
  ],
  "At least one Hgg S12 pole component did not cancel."];

Print["S12_STAGE: constructing finite Hgg coefficient pairs"];
finitePairs = <||>;
finiteHardFunctions = <||>;
Do[
  finiteS10PhiS = loadAggregateCoefficient[projector, 0];
  finitePairs[projector] = Map[
    (# /. qcdAndConstantRules) &,
    pairAdd[
      <|
        "Endpoint" -> 0,
        "IntegrandPhiS" -> finiteS10PhiS,
        "IntegrandPhi0" -> 0
      |>,
      countertermFinitePairs[projector]
    ]
  ];
  finiteHardFunctions[projector] = pairToAction[
    finitePairs[projector], projector
  ];
  Clear[finiteS10PhiS];
  ClearSystemCache[];,
  {projector, projectors}
];

forbiddenFinalObjects =
  epsilon | _SeriesData | S11SEpsilon | _S11ConvolutionTest |
    _S11PlusDistribution | DiracDelta[s23] |
    _S09EndpointValue | _S09PlusDistribution;

s12Checks = <|
  "S10ValidatedAndSourceBound" -> True,
  "S11ValidatedAndPaperBound" -> True,
  "ExactlyFourHggCountertermSpeciesMapped" -> True,
  "OnlyPqgPDFAndPgqFFUsed" -> True,
  "PhysicalS08MapRebuilt" -> True,
  "AllMappedBornDeltaRootsValidated" ->
    And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "PPPPDFOneOverYSquaredApplied" -> True,
  "PositiveEq46SignApplied" -> True,
  "PaperSEpsilonExpandedThroughFiniteOrder" -> True,
  "StandardQCDTFHalfApplied" -> True,
  "S10Alpha2AndOrdinaryFamiliesSeparatedStructurally" -> True,
  "S10TermCountPg69PlusAlpha2" -> True,
  "S10TermCountPPP93PlusAlpha2" -> True,
  "BoundedSerialPerTermLaurentExtraction" -> True,
  "DiskBackedPerTermResumeEnabled" -> True,
  "AtomicCheckpointWritesEnabled" -> True,
  "NoWholeExpressionSeriesOnLargeS10Action" -> True,
  "PgDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Pg"]["Minus2"]]),
  "PgSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Pg"]["Minus1"]]),
  "PPPDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["PPP"]["Minus2"]]),
  "PPPSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["PPP"]["Minus1"]]),
  "FiniteFunctionsContainNoEpsilonOrDistributionPlaceholder" ->
    And @@ (FreeQ[#, forbiddenFinalObjects] & /@ Values[finiteHardFunctions]),
  "FiniteFunctionsRetainOrdinaryS23Integral" ->
    And @@ (! FreeQ[#, Inactive[Integrate][___]] & /@
      Values[finiteHardFunctions]),
  "FiniteFunctionsRetainArbitrarySymbolicTest" ->
    And @@ (! FreeQ[#, _S10ConvolutionTest] & /@
      Values[finiteHardFunctions]),
  "PhysicalFlavorChargeWeightRetained" ->
    And @@ (! FreeQ[#, HggFlavorChargeSum] & /@
      Values[finiteHardFunctions]),
  "NoVirtualContributionIntroduced" -> True,
  "NoHermitianProjectionForced" ->
    And @@ (FreeQ[#, _Re] & /@ Values[finiteHardFunctions]),
  "NoAccidentalGlobalFeynCalcSymbols" ->
    feynCalcContextCleanQ[{
      countertermPolePairs,
      countertermFinitePairs,
      finiteHardFunctions
    }],
  "CalculationFullySymbolicAndExact" -> True
|>;

assert[And @@ Values[s12Checks],
  "At least one final Hgg S12 validation check is not True."];

s12Result = <|
  "Status" -> "CompleteFiniteFactorizedHgg",
  "Channel" -> "Hgg only",
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> <|
    "EndpointResolvedReal" -> s10Path,
    "EndpointResolvedRealSHA256" -> s10SHA256,
    "CollinearCounterterms" -> s11Path,
    "CollinearCountertermsSHA256" -> s11SHA256,
    "AuthoritativePaper" -> paperPath,
    "AuthoritativePaperSHA256" -> paperSHA256
  |>,
  "CalculationMode" ->
    "fully analytic, exact, symbolic, source-bound, and disk-checkpointed",
  "PhysicalMapping" -> <|
    "S23Upper" -> s23UpperB,
    "XHat" -> xHatXi,
    "Zeta" -> zetaXiS23,
    "ZHat" -> zHatXiS23,
    "K1TPartonicSquared" -> k1TPartonic2XiS23,
    "XiS23Jacobian" -> xiS23Jacobian,
    "Residuals" -> mappingResiduals
  |>,
  "FactorizationConvention" -> <|
    "Equation" -> "Eq. (46)",
    "Sign" -> "positive",
    "LoopPrefactor" -> factorizationLoop,
    "SEpsilonLinearCoefficient" -> sEpsilonLinearCoefficient,
    "PDFKernel" -> "Pqg",
    "FFKernel" -> "Pgq",
    "FlavorWeightPerQuarkOrAntiquarkSpecies" ->
      9 HggFlavorChargeSum
  |>,
  "S10LaurentCaches" -> <|
    "TermParts" -> partCacheRoot,
    "Aggregates" -> aggregateCacheRoot,
    "SourceSHA256" -> s10SHA256
  |>,
  "MappedCountertermCache" -> countertermCachePath,
  "PoleResiduals" -> poleResiduals,
  "FiniteCoefficientPairsByProjector" -> finitePairs,
  "FiniteHattedHardFunctionsByProjector" -> finiteHardFunctions,
  "VirtualContributionAtThisOrder" -> 0,
  "Checks" -> s12Checks,
  "MemoryStrategy" ->
    "serial Pg then PPP; one alpha-two term plus 69/93 ordinary source terms; 4 GiB per-term allocation bound; atomic per-term and aggregate checkpoints; no duplicate parallel expression copies",
  "NotPerformedAtThisStage" -> {
    "virtual-loop addition or UV renormalization, absent for Hgg at this order",
    "Hermitian real projection",
    "S13 combination into final F-hat structures",
    "numerical PDFs, FFs, or kinematics"
  }
|>;

Print["S12_STAGE: writing finite factorized Hgg result"];
atomicPut[s12Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "The final Hgg S12 result was not written."];
Print["S12_SUCCESS_FINITE_FACTORIZED_HGG"];
Print["S12_RESULT_PATH=", resultPath];
Print["S12_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S12_POLE_RESIDUALS=", InputForm[poleResiduals]];
Print["S12_CHECKS=", InputForm[s12Checks]];

Quit[0];

(* ::Package:: *)

(*
  S12 for Hqqbar: map the accepted S11 Eq. (46) counterterms into the
  accepted S10 physical variables, combine them with the endpoint-resolved
  real action, prove every Laurent pole component vanishes, and save the
  exact finite factorized Pg/PPP actions.  Eq. (9), F-hats, physical flavor
  weights, and BigTMD comparison are deliberately deferred.
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
  scriptDirectory, "s12_cache_hqqbar_mapped_counterterms"
}];
partCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_hqqbar_s10_laurent_parts"
}];
aggregateCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_hqqbar_s10_laurent"
}];
residualDiagnosticPath = FileNameJoin[{
  scriptDirectory, "s12_last_nonzero_residual"
}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

stageVersion = "HqqbarS12-v1";
cacheVersion = 1;
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
laurentPowers = {-2, -1, 0};
expectedOrdinaryTermCounts = <|"Pg" -> 75, "PPP" -> 77|>;
expectedS10SHA256 =
  "57e637d3eca490dfe08e341d866e5fa08ec1d69b14c7c476cf17c51890a65cb6";
expectedS10ProgramSHA256 =
  "793f9aaafbda74c605c3885915eabf9323e8b5761c84e9954d0759a5f890ac20";
expectedS10CacheSHA256 = <|
  "Pg" -> "e130cafa2e9b02748f16e9c812d60bfaf29d37d9225eb362045d061d30fc8185",
  "PPP" -> "173e44bc67623274801a8ad9cc2e92183c39456b20d4cb68a21544100f2b225e"
|>;
expectedS11SHA256 =
  "3cc321fc994a803f1d28a7fe35b84b4a4c466a9d95ed4e66bb3bca3e40aff889";
expectedS11ProgramSHA256 =
  "2864463cd41d8bbc00247d429244decc061201e877ff60a511664924ce78a3d4";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
compatibleLegacyS12ProgramSHA256 =
  "4341ba8d3280365ea8a26ad7403c76221acf0e9fb7eb1f33efd5bd79e52bc42e";

gibibyte = 1024^3;
perTermMemoryLimit = 4 gibibyte;
countertermMemoryLimit = 2 gibibyte;
residualMemoryLimit = 5 gibibyte;
residualReductionTimeoutSeconds = 1200;
maximumNewTermsPerKernelEpoch = 16;
newTermsThisKernelEpoch = 0;
preflightOnly = TrueQ[
  Environment["HQQBAR_S12_PREFLIGHT_ONLY"] === "1"
];

sha256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

programSHA256 = sha256Hex[ExpandFileName[$InputFileName]];

qcdAndConstantRules = {
  FeynCalc`TF -> 1/2,
  FeynCalc`CF ->
    (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA),
  S11SEpsilon -> (4 Pi)^epsilon/Gamma[1 - epsilon],
  PolyGamma[0, 1/2] -> -EulerGamma - 2 Log[2],
  Log[16] -> 4 Log[2],
  Log[8] -> 3 Log[2],
  Log[4] -> 2 Log[2]
};

colorCanonicalizationRules = {
  FeynCalc`SUNN -> FeynCalc`CA
};

canonicalizeForCombination[expression_] :=
  (expression /. qcdAndConstantRules) /. colorCanonicalizationRules;

physicalAssumptions =
  0 < xB < xi < 1 && 0 < zH < 1 && Q2 > 0 && PHT2 > 0 &&
    FeynCalc`ScaleMu > 0;

feynCalcOwnedSymbolNames = {
  "CF", "CA", "SUNN", "TF", "SMP", "FCGV", "ScaleMu"
};

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
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Atomic temporary file is absent or empty for " <> path <> "."
  ];
  Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    fatal["Atomic rename failed for " <> path <> "."]
  ];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic destination is absent or empty for " <> path <> "."
  ];
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
    parts, coefficients = <||>, reportedMinima = {}, partSeries,
    partMinimum, shift, normalizedPart, coefficient, nonzeroPowers,
    minimumPower
  },
  parts = If[Head[expression] === Plus, List @@ expression, {expression}];
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
    answer = <|0 -> 1|>, nextAnswer, remainingMinimum,
    maximumPartialPower, factor, totalPower
  },
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
    coefficients = <||>, coefficient
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
          If[
            MemberQ[branchAnswers, $Failed] || defaultAnswer === $Failed,
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
        1800,
        $Failed
      ],
      memoryLimit,
      $Failed
    ],
    $Failed
  ];
  If[answer === $Failed, Return[$Failed]];
  If[
    ! AssociationQ[answer] ||
      Sort[Keys[answer]] =!= Sort[powers] ||
      ! FreeQ[
        answer,
        epsilon | _SeriesData | $Failed | Indeterminate |
          ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
      ] ||
      ! feynCalcContextCleanQ[answer],
    Return[$Failed]
  ];
  answer
];

actionToPair[action_, projector_String] := Module[
  {
    integrals, integral, body, upper, endpointExpression, endpoint,
    integrandPhiS, integrandPhi0, testOccurrences
  },
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]],
    {0, Infinity}
  ];
  assert[
    Length[integrals] === 1,
    projector <> " S10 action does not contain exactly one ordinary integral."
  ];
  integral = First[integrals];
  body = integral[[1]];
  upper = integral[[2, 3]];
  assert[
    TrueQ[Cancel[Together[upper - s23UpperB]] === 0],
    projector <> " S10 integral upper limit differs from the physical map."
  ];
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

splitHqqbarPhiS[expression_, projector_String] := Module[
  {
    topTerms, sizes, ordinaryPosition, alphaTwoPosition,
    ordinaryFamily, factors, plusPositions, remainderPosition,
    ordinaryRemainder, ordinaryPrefactor, ordinaryTerms
  },
  topTerms = If[Head[expression] === Plus, List @@ expression, {expression}];
  assert[
    Length[topTerms] === 2,
    projector <> " IntegrandPhiS is not the validated two-family sum."
  ];
  sizes = LeafCount /@ topTerms;
  ordinaryPosition = First@Ordering[sizes, -1];
  alphaTwoPosition = First@Complement[Range[2], {ordinaryPosition}];
  ordinaryFamily = topTerms[[ordinaryPosition]];
  factors = If[
    Head[ordinaryFamily] === Times,
    List @@ ordinaryFamily,
    {ordinaryFamily}
  ];
  plusPositions = Select[
    Range[Length[factors]],
    Head[factors[[#]]] === Plus &
  ];
  assert[
    Length[plusPositions] >= 1,
    projector <> " ordinary family has no additive source remainder."
  ];
  remainderPosition = First@MaximalBy[
    plusPositions,
    LeafCount[factors[[#]]] &
  ];
  ordinaryRemainder = factors[[remainderPosition]];
  ordinaryPrefactor = Times @@ Delete[factors, remainderPosition];
  ordinaryTerms = List @@ ordinaryRemainder;
  assert[
    Length[ordinaryTerms] === expectedOrdinaryTermCounts[projector],
    projector <> " ordinary term count differs from the hash-pinned S10 manifest."
  ];
  assert[
    Count[expression, _Piecewise, Infinity] === 0,
    projector <> " unexpectedly contains a Piecewise expression."
  ];
  <|
    "Alpha2Term" -> topTerms[[alphaTwoPosition]],
    "OrdinaryPrefactor" -> ordinaryPrefactor,
    "OrdinaryTerms" -> ordinaryTerms,
    "TopFamilyLeafCounts" -> sizes
  |>
];

partCachePath[
    projector_String, family_String, position_Integer
  ] := FileNameJoin[{
  partCacheRoot,
  ToLowerCase[projector] <> "_" <> ToLowerCase[family] <> "_" <>
    IntegerString[position, 10, 4]
}];

validPartPayloadForProgramQ[
    payload_, projector_String, family_String, position_Integer,
    termHash_String, s10SHA256_String, expectedProgramSHA256_String
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "ProgramSHA256", Missing["Absent"]] ===
    expectedProgramSHA256 &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Field", Missing["Absent"]] === "IntegrandPhiS" &&
  Lookup[payload, "Family", Missing["Absent"]] === family &&
  Lookup[payload, "Position", Missing["Absent"]] === position &&
  Lookup[payload, "TermSHA256", Missing["Absent"]] === termHash &&
  Lookup[payload, "Powers", Missing["Absent"]] === laurentPowers &&
  AssociationQ[Lookup[payload, "Coefficients", Missing["Absent"]]] &&
  Sort[Keys[payload["Coefficients"]]] === Sort[laurentPowers] &&
  FreeQ[
    payload["Coefficients"],
    epsilon | _SeriesData | $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative]
  ] &&
  feynCalcContextCleanQ[payload["Coefficients"]]
];

validPartPayloadQ[
    payload_, projector_String, family_String, position_Integer,
    termHash_String, s10SHA256_String
  ] := validPartPayloadForProgramQ[
  payload, projector, family, position, termHash, s10SHA256,
  programSHA256
];

validLegacyPartPayloadQ[
    payload_, projector_String, family_String, position_Integer,
    termHash_String, s10SHA256_String
  ] := validPartPayloadForProgramQ[
  payload, projector, family, position, termHash, s10SHA256,
  compatibleLegacyS12ProgramSHA256
];

migrateLegacyPartPayload[
    payload_Association, path_String, projector_String, family_String,
    position_Integer, termHash_String, s10SHA256_String
  ] := Module[
  {originalFileSHA256, migratedPayload, reloadedPayload},
  assert[
    validLegacyPartPayloadQ[
      payload, projector, family, position, termHash, s10SHA256
    ],
    "Attempted to migrate a term payload that is not exact-legacy compatible."
  ];
  originalFileSHA256 = sha256Hex[path];
  migratedPayload = Join[
    payload,
    <|
      "ProgramSHA256" -> programSHA256,
      "ProvenanceMigration" -> <|
        "FromProgramSHA256" -> compatibleLegacyS12ProgramSHA256,
        "ToProgramSHA256" -> programSHA256,
        "OriginalFileSHA256" -> originalFileSHA256,
        "Reason" ->
          "downstream-only SUNN-to-CA combination canonicalization",
        "CoefficientChanged" -> False
      |>
    |>
  ];
  assert[
    TrueQ[
      migratedPayload["Coefficients"] === payload["Coefficients"]
    ],
    "A provenance migration attempted to change a term coefficient."
  ];
  atomicPut[migratedPayload, path];
  reloadedPayload = Quiet@Check[Get[path], $Failed];
  assert[
    validPartPayloadQ[
      reloadedPayload, projector, family, position, termHash, s10SHA256
    ] &&
      TrueQ[
        reloadedPayload["Coefficients"] === payload["Coefficients"]
      ] &&
      Lookup[
        reloadedPayload["ProvenanceMigration"],
        "OriginalFileSHA256",
        Missing["Absent"]
      ] === originalFileSHA256 &&
      TrueQ[
        Lookup[
          reloadedPayload["ProvenanceMigration"],
          "CoefficientChanged",
          Missing["Absent"]
        ] === False
      ],
    "The atomically migrated term payload failed exact revalidation."
  ];
  Print[
    "S12_TERM_PROVENANCE_MIGRATED: ", projector, " ", family,
    " position ", position
  ];
  Clear[migratedPayload, reloadedPayload];
  path
];

processS10Term[
    term_, projector_String, family_String, position_Integer,
    s10SHA256_String
  ] := Module[
  {path, termHash, payload, coefficients},
  path = partCachePath[projector, family, position];
  termHash = IntegerString[Hash[term, "SHA256"], 16, 64];
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[
      validPartPayloadQ[
        payload, projector, family, position, termHash, s10SHA256
      ],
      Print[
        "S12_TERM_RESUME: ", projector, " ", family,
        " position ", position
      ];
      Clear[payload];
      Return[path]
    ];
    If[
      validLegacyPartPayloadQ[
        payload, projector, family, position, termHash, s10SHA256
      ],
      migrateLegacyPartPayload[
        payload, path, projector, family, position, termHash, s10SHA256
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
      " new terms; restart required before ", projector, " ", family,
      " position ", position
    ];
    Quit[75]
  ];
  Print[
    "S12_TERM_STAGE: ", projector, " ", family,
    " position ", position, " leafCount=", LeafCount[term]
  ];
  coefficients = singleTermSeriesCoefficients[
    term,
    laurentPowers,
    0,
    perTermMemoryLimit
  ];
  If[
    coefficients === $Failed,
    fatal[
      projector <> " " <> family <> " position " <>
        ToString[position] <>
        " Laurent extraction failed or exceeded its bounded resource limit."
    ]
  ];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
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
    payload_, projector_String, power_Integer, s10SHA256_String,
    partHashes_List
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "ProgramSHA256", Missing["Absent"]] === programSHA256 &&
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
    projector_String, power_Integer, paths_List, s10SHA256_String
  ] := Module[
  {path, partHashes, payload, sum = 0, partPayload},
  path = aggregateCachePath[projector, power];
  partHashes = sha256Hex /@ paths;
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[
      validAggregatePayloadQ[
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
    "S12_AGGREGATE_STAGE: ", projector,
    " epsilon^", power, " parts=", Length[paths]
  ];
  Do[
    partPayload = Quiet@Check[Get[paths[[position]]], $Failed];
    assert[
      AssociationQ[partPayload],
      "A validated term cache became unreadable during aggregation."
    ];
    sum = sum + Lookup[partPayload["Coefficients"], power, 0];
    Clear[partPayload];,
    {position, Length[paths]}
  ];
  assert[
    FreeQ[sum, epsilon | _SeriesData | $Failed] &&
      feynCalcContextCleanQ[sum],
    projector <> " aggregate coefficient is invalid."
  ];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
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
  assert[
    AssociationQ[payload] && KeyExistsQ[payload, "Coefficient"],
    "Aggregate Laurent cache is unreadable for " <> projector <>
      " epsilon^" <> ToString[power] <> "."
  ];
  coefficient = payload["Coefficient"];
  Clear[payload];
  coefficient
];

projectorCompletePath[projector_String] := FileNameJoin[{
  aggregateCacheRoot,
  ToLowerCase[projector] <> "_complete"
}];

validProjectorCompletePayloadQ[
    payload_, projector_String, s10SHA256_String
  ] := Module[{aggregatePaths},
  aggregatePaths = aggregateCachePath[projector, #] & /@ laurentPowers;
  TrueQ[
    AssociationQ[payload] &&
    Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
    Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
    Lookup[payload, "ProgramSHA256", Missing["Absent"]] === programSHA256 &&
    Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
    Lookup[payload, "Projector", Missing["Absent"]] === projector &&
    And @@ (FileExistsQ /@ aggregatePaths) &&
    Lookup[payload, "AggregateSHA256", Missing["Absent"]] ===
      (sha256Hex /@ aggregatePaths)
  ]
];

processS10Projector[
    projector_String, s10SHA256_String
  ] := Module[
  {
    completionPath, completionPayload, s10, action, pair, split,
    alphaPath, ordinaryPaths, allPaths, term, aggregatePaths
  },
  completionPath = projectorCompletePath[projector];
  If[FileExistsQ[completionPath],
    completionPayload = Quiet@Check[Get[completionPath], $Failed];
    If[
      validProjectorCompletePayloadQ[
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
  assert[
    AssociationQ[s10] && s10["Status"] === "Complete" &&
      s10["Stage"] === "HqqbarS10-v1" &&
      s10["Channel"] === "Hqqbar only" &&
      And @@ Values[s10["Checks"]],
    "S10 result is absent, invalid, or incomplete."
  ];
  action = s10["DistributionActions"]["RealByProjector"][projector];
  assert[
    feynCalcContextCleanQ[action],
    projector <> " S10 action contains accidental Global-context QCD symbols."
  ];
  pair = actionToPair[action, projector];
  Clear[action, s10];
  assert[
    TrueQ[pair["Endpoint"] === 0] &&
      TrueQ[pair["IntegrandPhi0"] === 0],
    projector <> " unexpectedly has a nonzero endpoint or phi(0) field."
  ];
  split = splitHqqbarPhiS[pair["IntegrandPhiS"], projector];
  Clear[pair];
  Print[
    "S12_S10_PARTITION: ", projector,
    " alpha2=1 regular=", Length[split["OrdinaryTerms"]],
    " topLeafCounts=", InputForm[split["TopFamilyLeafCounts"]]
  ];
  alphaPath = processS10Term[
    split["Alpha2Term"], projector, "Alpha2", 1, s10SHA256
  ];
  ordinaryPaths = Table[
    term = split["OrdinaryPrefactor"] *
      split["OrdinaryTerms"][[position]];
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
      "ProgramSHA256" -> programSHA256,
      "S10SHA256" -> s10SHA256,
      "Projector" -> projector,
      "AggregateSHA256" -> (sha256Hex /@ aggregatePaths)
    |>,
    completionPath
  ];
  Print["S12_S10_PROJECTOR_COMPLETE: ", projector];
  Clear[allPaths, aggregatePaths];
  ClearSystemCache[]
];

validCountertermCacheQ[
    payload_, s10SHA256_String, s11SHA256_String, paperSHA256_String
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "ProgramSHA256", Missing["Absent"]] === programSHA256 &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "S11SHA256", Missing["Absent"]] === s11SHA256 &&
  Lookup[payload, "PaperSHA256", Missing["Absent"]] === paperSHA256 &&
  AssociationQ[Lookup[payload, "MappingResiduals", Missing["Absent"]]] &&
  And @@ (TrueQ[# === 0] & /@ Values[payload["MappingResiduals"]]) &&
  AssociationQ[Lookup[payload, "EquivalenceResiduals", Missing["Absent"]]] &&
  And @@ Flatten[
    Map[
      Function[projectorResiduals,
        TrueQ[# === 0] & /@ Values[projectorResiduals]
      ],
      Values[payload["EquivalenceResiduals"]]
    ]
  ] &&
  AssociationQ[Lookup[payload, "PolePairs", Missing["Absent"]]] &&
  AssociationQ[Lookup[payload, "FinitePairs", Missing["Absent"]]] &&
  And @@ Flatten@Table[
    AssociationQ[payload[kind][projector]] &&
      Sort[Keys[payload[kind][projector]]] === Sort[pairFields] &&
      FreeQ[
        payload[kind][projector],
        epsilon | _SeriesData | S11SEpsilon | $Failed
      ],
    {kind, {"PolePairs", "FinitePairs"}},
    {projector, projectors}
  ] &&
  feynCalcContextCleanQ[{payload["PolePairs"], payload["FinitePairs"]}]
];

validLegacyResidualDiagnosticQ[
    payload_, s10SHA256_String, s11SHA256_String
  ] := Module[{expression},
  If[! AssociationQ[payload], Return[False, Module]];
  expression = Lookup[payload, "Expression", Missing["Absent"]];
  TrueQ[
    Lookup[payload, "SchemaVersion", Missing["Absent"]] === 1 &&
    Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
    Lookup[payload, "ProgramSHA256", Missing["Absent"]] ===
      compatibleLegacyS12ProgramSHA256 &&
    Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
    Lookup[payload, "S11SHA256", Missing["Absent"]] === s11SHA256 &&
    Lookup[payload, "Label", Missing["Absent"]] ===
      "Pg epsilon^-1 IntegrandPhiS" &&
    TrueQ[
      Lookup[
        payload,
        "ReductionFailedOrTimedOut",
        Missing["Absent"]
      ] === False
    ] &&
    AssociationQ[Lookup[payload, "Components", Missing["Absent"]]] &&
    ! TrueQ[expression === 0] &&
    ! FreeQ[expression, FeynCalc`SUNN] &&
    ! FreeQ[expression, FeynCalc`CA] &&
    FreeQ[expression, epsilon | _SeriesData | _Real | $Failed] &&
    feynCalcContextCleanQ[expression] &&
    TrueQ[canonicalizeForCombination[expression] === 0]
  ]
];

Print["S12_STAGE: validating exact S10, S11, cache, and paper bindings"];
assert[FileExistsQ[s10Path], "s10_result does not exist."];
assert[FileExistsQ[s11Path], "s11_result does not exist."];
assert[FileExistsQ[paperPath], "The authoritative paper does not exist."];
s10SHA256 = sha256Hex[s10Path];
s11SHA256 = sha256Hex[s11Path];
paperSHA256 = sha256Hex[paperPath];
assert[s10SHA256 === expectedS10SHA256, "S10 result SHA-256 changed."];
assert[s11SHA256 === expectedS11SHA256, "S11 result SHA-256 changed."];
assert[paperSHA256 === expectedPaperSHA256, "Paper SHA-256 changed."];

colorCanonicalizationRegressionResidual = canonicalizeForCombination[
  FeynCalc`SUNN - FeynCalc`CA
];
assert[
  TrueQ[colorCanonicalizationRegressionResidual === 0],
  "The exact SUNN-to-CA color-canonicalization regression failed."
];
legacyResidualPresentAtStart = FileExistsQ[residualDiagnosticPath];
legacyResidualRegressionPassed = If[
  legacyResidualPresentAtStart,
  legacyResidualPayload = Quiet@Check[
    Get[residualDiagnosticPath],
    $Failed
  ];
  legacyResidualValidation = validLegacyResidualDiagnosticQ[
    legacyResidualPayload, s10SHA256, s11SHA256
  ];
  Clear[legacyResidualPayload];
  assert[
    legacyResidualValidation,
    "The saved legacy Pg pole diagnostic failed exact regression validation."
  ];
  Print[
    "S12_COLOR_REGRESSION: saved Pg simple-pole residual is exact zero " <>
      "under SUNN -> CA"
  ];
  True,
  False
];

s10Metadata = Quiet@Check[Get[s10Path], $Failed];
assert[
  AssociationQ[s10Metadata] &&
    s10Metadata["Status"] === "Complete" &&
    s10Metadata["Stage"] === "HqqbarS10-v1" &&
    s10Metadata["ResultSchemaVersion"] === 1 &&
    s10Metadata["Channel"] === "Hqqbar only" &&
    s10Metadata["ProgramSHA256"] === expectedS10ProgramSHA256 &&
    And @@ Values[s10Metadata["Checks"]] &&
    s10Metadata["Bookkeeping"]["AdditionalMultiplicativeWeightAtS10"] === 1 &&
    TrueQ[
      s10Metadata["Bookkeeping"]["Symmetry"][
        "IdenticalSpectatorFactorAppliedAtS08"
      ]
    ] &&
    TrueQ[
      s10Metadata["Bookkeeping"]["Charge"]["TensorIsChargeStripped"]
    ] &&
    TrueQ[
      ! s10Metadata["Bookkeeping"]["PhysicalFlavorChargeWeightAppliedAtS10"]
    ],
  "S10 identity, checks, or bookkeeping are invalid."
];
s10CachePaths = s10Metadata["CacheProvenance"]["EndpointCachePaths"];
assert[
  Sort[Keys[s10CachePaths]] === Sort[projectors] &&
    And @@ Table[
      FileExistsQ[s10CachePaths[projector]] &&
        sha256Hex[s10CachePaths[projector]] ===
          expectedS10CacheSHA256[projector] &&
        s10Metadata["CacheProvenance"]["EndpointCacheSHA256"][projector] ===
          expectedS10CacheSHA256[projector],
      {projector, projectors}
    ],
  "S10 endpoint-cache provenance is invalid."
];
Clear[s10Metadata, s10CachePaths];
ClearSystemCache[];

s11Metadata = Quiet@Check[Get[s11Path], $Failed];
assert[
  AssociationQ[s11Metadata] &&
    s11Metadata["Status"] === "Complete" &&
    s11Metadata["Stage"] === "HqqbarS11-v1" &&
    s11Metadata["ResultSchemaVersion"] === 1 &&
    s11Metadata["Channel"] === "Hqqbar only" &&
    s11Metadata["ProgramSHA256"] === expectedS11ProgramSHA256 &&
    And @@ Values[s11Metadata["Checks"]] &&
    s11Metadata["CountertermCount"] === 4 &&
    Keys[s11Metadata["Counterterms"]] ===
      {"PgPDF", "PgFF", "PPPPDF", "PPPFF"} &&
    Sort[Keys[s11Metadata["BornProjectedSquaredAmplitudes"]]] ===
      Sort[{"Hqg", "Hgqbar"}] &&
    s11Metadata["PaperReference"]["SHA256"] === paperSHA256 &&
    s11Metadata["InputProvenance"]["S10ResultSHA256"] === s10SHA256 &&
    s11Metadata["InputProvenance"]["S10SourceSHA256"] ===
      expectedS10ProgramSHA256 &&
    s11Metadata["Bookkeeping"]["AdditionalMultiplicativeWeightAtS11"] === 1 &&
    s11Metadata["Bookkeeping"]["VirtualContributionAtThisOrder"] === 0 &&
    TrueQ[
      s11Metadata["Bookkeeping"]["Charge"][
        "BornHardPartsAreChargeStripped"
      ]
    ] &&
    TrueQ[
      ! s11Metadata["Bookkeeping"]["Charge"][
        "PhysicalFlavorChargeWeightAppliedAtS11"
      ]
    ],
  "S11 identity, schema, checks, paper binding, or bookkeeping are invalid."
];
Clear[s11Metadata];
ClearSystemCache[];

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
  "Jacobian" -> Together[D[zetaXiS23, s23] - xiS23Jacobian],
  "UpperBound" -> Together[
    s23UpperB -
      (Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH)
  ],
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
assert[
  And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "At least one physical mapping or Eq. (46) delta-root identity failed."
];

buildMappedCountertermPayload[] := Module[
  {
    s11, bornProjected, savedCounterterms, convolutionMappings,
    twoBodyNormalization, bornM2, mapSavedDensity,
    factorizationPrefactor, rebuiltPDF, rebuiltFF, directPDF, directFF,
    equivalenceResiduals = <||>, mappedTotals = <||>, coefficients,
    polePairs = <||>, finitePairs = <||>, sEpsilonSeries
  },
  Print["S12_COUNTERTERM_STAGE: loading S11 and deriving mapped densities"];
  s11 = Quiet@Check[Get[s11Path], $Failed];
  assert[
    AssociationQ[s11] && s11["Status"] === "Complete" &&
      And @@ Values[s11["Checks"]],
    "S11 became unreadable while deriving mapped counterterms."
  ];
  bornProjected = s11["BornProjectedSquaredAmplitudes"];
  savedCounterterms = s11["Counterterms"];
  convolutionMappings = s11["ConvolutionMappings"];
  twoBodyNormalization = convolutionMappings["TwoBodyNormalization"];
  assert[
    TrueQ[twoBodyNormalization === 1/(8 Pi^3)] &&
      TrueQ[
        convolutionMappings[
          "PPPFinalStateAdditionalProjectorConversion"
        ] === 1
      ],
    "S11 two-body normalization or PPP-FF convention changed."
  ];
  bornM2[channel_String, projector_String, x_, z_, transverse2_] :=
    Together[
      bornProjected[channel][projector] /. {
        D -> 4 - 2 epsilon,
        sHat -> Q2 (1/x - 1),
        tHat -> -Q2 + z Q2 - transverse2/z,
        uHat -> -z Q2/x
      }
    ];
  mapSavedDensity[key_String, projector_String] := Module[
    {counterterm, integrals, integral, outside, body, density, tests},
    counterterm = savedCounterterms[key];
    integrals = Cases[
      counterterm,
      HoldPattern[Inactive[Integrate][_, {s11S23, 0, _}]],
      {0, Infinity}
    ];
    assert[
      Length[integrals] === 1,
      key <> " does not contain exactly one saved S11 integral."
    ];
    integral = First[integrals];
    assert[
      TrueQ[
        Together[
          integral[[2, 3]] - convolutionMappings["EndpointUpper"]
        ] === 0
      ],
      key <> " has an unexpected abstract S11 upper limit."
    ];
    tests = DeleteDuplicates@Cases[
      counterterm,
      test_S11ConvolutionTest :> HoldComplete[test],
      Infinity
    ];
    assert[
      tests === {
        HoldComplete[S11ConvolutionTest[projector, s11S23]]
      },
      key <> " has an unexpected S11 test-function occurrence."
    ];
    outside = counterterm /.
      HoldPattern[Inactive[Integrate][_, _]] :> 1;
    body = integral[[1]];
    density = Together[
      body/S11ConvolutionTest[projector, s11S23]
    ];
    Together[
      (xiS23Jacobian outside density) /. {
        xHat -> xHatXi,
        zHat -> zHatXiS23,
        s11S23 -> s23
      }
    ]
  ];
  factorizationPrefactor =
    S11SEpsilon FeynCalc`SMP["g_s"]^2/(16 Pi^2 epsilon);
  Do[
    directPDF = mapSavedDensity[projector <> "PDF", projector];
    directFF = mapSavedDensity[projector <> "FF", projector];
    rebuiltPDF = Together[
      factorizationPrefactor *
        (2 FeynCalc`CF (
          1 + (1 - pdfSplittingVariable)^2
        )/pdfSplittingVariable) *
        (xiS23Jacobian twoBodyNormalization/pdfSplittingVariable) *
        If[projector === "PPP", pdfSplittingVariable^-2, 1] *
        bornM2[
          "Hgqbar",
          projector,
          pdfInternalKinematics["x"],
          pdfInternalKinematics["z"],
          pdfInternalKinematics["k1T2"]
        ]/pdfScale
    ];
    rebuiltFF = Together[
      factorizationPrefactor *
        (2 FeynCalc`TF (
          (1 - ffSplittingVariable)^2 + ffSplittingVariable^2
        )) *
        (xiS23Jacobian twoBodyNormalization/ffSplittingVariable) *
        bornM2[
          "Hqg",
          projector,
          ffInternalKinematics["x"],
          ffInternalKinematics["z"],
          ffInternalKinematics["k1T2"]
        ]/ffScale
    ];
    equivalenceResiduals[projector] = <|
      "PDF" -> Together[directPDF - rebuiltPDF],
      "FF" -> Together[directFF - rebuiltFF]
    |>;
    assert[
      And @@ (
        TrueQ[# === 0] & /@ Values[equivalenceResiduals[projector]]
      ),
      projector <> " direct and independently rebuilt mapped densities differ."
    ];
    mappedTotals[projector] = directPDF + directFF;
    Print[
      "S12_COUNTERTERM_SERIES: ", projector,
      " leafCount=", LeafCount[mappedTotals[projector]]
    ];
    coefficients = singleTermSeriesCoefficients[
      mappedTotals[projector],
      {-1, 0},
      0,
      countertermMemoryLimit
    ];
    If[
      coefficients === $Failed,
      fatal[projector <> " mapped counterterm expansion failed."]
    ];
    polePairs[projector] = <|
      "Endpoint" -> 0,
      "IntegrandPhiS" -> coefficients[-1],
      "IntegrandPhi0" -> 0
    |>;
    finitePairs[projector] = <|
      "Endpoint" -> 0,
      "IntegrandPhiS" -> coefficients[0],
      "IntegrandPhi0" -> 0
    |>;
    Clear[
      directPDF, directFF, rebuiltPDF, rebuiltFF, coefficients
    ];,
    {projector, projectors}
  ];
  sEpsilonSeries = Normal@Series[
    (4 Pi)^epsilon/Gamma[1 - epsilon],
    {epsilon, 0, 1}
  ];
  assert[
    FreeQ[sEpsilonSeries, _Real | _SeriesData] &&
      TrueQ[Coefficient[sEpsilonSeries, epsilon, 0] === 1],
    "The exact MS-bar S-epsilon series gate failed."
  ];
  assert[
    FreeQ[
      {polePairs, finitePairs},
      epsilon | _SeriesData | S11SEpsilon | _Real | $Failed
    ] && feynCalcContextCleanQ[{polePairs, finitePairs}],
    "Mapped counterterm Laurent pairs are not exact and context-clean."
  ];
  Clear[
    s11, bornProjected, savedCounterterms, convolutionMappings,
    mappedTotals
  ];
  ClearSystemCache[];
  <|
    "CacheVersion" -> cacheVersion,
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "S10SHA256" -> s10SHA256,
    "S11SHA256" -> s11SHA256,
    "PaperSHA256" -> paperSHA256,
    "MappingResiduals" -> mappingResiduals,
    "EquivalenceResiduals" -> equivalenceResiduals,
    "SEpsilonDefinition" -> HoldForm[
      S11SEpsilon == (4 Pi)^epsilon/Gamma[1 - epsilon]
    ],
    "SEpsilonSeriesThroughOrder1" -> sEpsilonSeries,
    "Routes" -> <|"PDF" -> "Hgqbar x Pgq", "FF" -> "Hqg x Pqg"|>,
    "PPPPDFProjectorRescaling" -> HoldForm[1/y^2],
    "AdditionalMultiplicativeWeight" -> 1,
    "PolePairs" -> polePairs,
    "FinitePairs" -> finitePairs
  |>
];

preflightResumeTermBinding[
    term_, projector_String, family_String, position_Integer,
    s10SHA256_String
  ] := Module[
  {path, termHash, payload, currentQ, exactLegacyQ},
  path = partCachePath[projector, family, position];
  assert[
    FileExistsQ[path],
    "Expected completed S12 term cache is absent: " <> path <> "."
  ];
  termHash = IntegerString[Hash[term, "SHA256"], 16, 64];
  payload = Quiet@Check[Get[path], $Failed];
  currentQ = validPartPayloadQ[
    payload, projector, family, position, termHash, s10SHA256
  ];
  exactLegacyQ = validLegacyPartPayloadQ[
    payload, projector, family, position, termHash, s10SHA256
  ];
  assert[
    TrueQ[currentQ || exactLegacyQ],
    "Completed term cache failed current and exact-legacy validation: " <>
      path <> "."
  ];
  Clear[payload];
  If[TrueQ[currentQ], "Current", "ExactLegacy"]
];

preflightS10Projector[projector_String] := Module[
  {
    s10, action, pair, split, representative, alphaCoefficients,
    representativeCoefficients, resumeBindings, term, bindingCounts
  },
  Print["S12_PREFLIGHT_S10: loading ", projector];
  s10 = Quiet@Check[Get[s10Path], $Failed];
  assert[
    AssociationQ[s10] && s10["Status"] === "Complete" &&
      And @@ Values[s10["Checks"]],
    "S10 became unreadable during preflight."
  ];
  action = s10["DistributionActions"]["RealByProjector"][projector];
  pair = actionToPair[action, projector];
  Clear[action, s10];
  assert[
    TrueQ[pair["Endpoint"] === 0] &&
      TrueQ[pair["IntegrandPhi0"] === 0],
    projector <> " preflight found an unexpected nonzero action field."
  ];
  split = splitHqqbarPhiS[pair["IntegrandPhiS"], projector];
  Clear[pair];
  representative = split["OrdinaryPrefactor"] *
    First@MinimalBy[split["OrdinaryTerms"], LeafCount];
  alphaCoefficients = singleTermSeriesCoefficients[
    split["Alpha2Term"], laurentPowers, 0, countertermMemoryLimit
  ];
  representativeCoefficients = singleTermSeriesCoefficients[
    representative, laurentPowers, 0, countertermMemoryLimit
  ];
  assert[
    AssociationQ[alphaCoefficients] &&
      AssociationQ[representativeCoefficients],
    projector <> " representative Laurent preflight failed."
  ];
  resumeBindings = {
    preflightResumeTermBinding[
      split["Alpha2Term"], projector, "Alpha2", 1, s10SHA256
    ]
  };
  Do[
    term = split["OrdinaryPrefactor"] *
      split["OrdinaryTerms"][[position]];
    AppendTo[
      resumeBindings,
      preflightResumeTermBinding[
        term, projector, "Regular", position, s10SHA256
      ]
    ];,
    {position, Length[split["OrdinaryTerms"]]}
  ];
  assert[
    Length[resumeBindings] ===
      1 + expectedOrdinaryTermCounts[projector],
    projector <> " resume-cache inventory count changed."
  ];
  bindingCounts = <|
    "Current" -> Count[resumeBindings, "Current"],
    "ExactLegacy" -> Count[resumeBindings, "ExactLegacy"]
  |>;
  Print[
    "S12_PREFLIGHT_PARTITION: ", projector,
    " alpha2=1 regular=", Length[split["OrdinaryTerms"]],
    " representativeLeafCount=", LeafCount[representative],
    " currentCaches=", bindingCounts["Current"],
    " exactLegacyCaches=", bindingCounts["ExactLegacy"]
  ];
  Clear[
    split, representative, alphaCoefficients,
    representativeCoefficients, resumeBindings, term
  ];
  ClearSystemCache[];
  bindingCounts
];

If[preflightOnly,
  Print["S12_PREFLIGHT_STAGE: exact no-write mapping and Laurent probes"];
  preflightCounterterms = buildMappedCountertermPayload[];
  assert[
    validCountertermCacheQ[
      preflightCounterterms, s10SHA256, s11SHA256, paperSHA256
    ],
    "No-write mapped-counterterm preflight payload is invalid."
  ];
  Clear[preflightCounterterms];
  preflightBindingCounts = Merge[
    preflightS10Projector /@ projectors,
    Total
  ];
  assert[
    Total[Values[preflightBindingCounts]] ===
      2 + Total[Values[expectedOrdinaryTermCounts]],
    "No-write resume-cache inventory is incomplete."
  ];
  If[preflightBindingCounts["ExactLegacy"] > 0,
    assert[
      legacyResidualPresentAtStart && legacyResidualRegressionPassed,
      "Exact-legacy term caches require the validated saved color residual."
    ]
  ];
  Print[
    "S12_PREFLIGHT_CACHE_BINDINGS: ",
    InputForm[preflightBindingCounts]
  ];
  Print["S12_PREFLIGHT_SUCCESS_NO_WRITE"];
  Quit[0]
];

Print["S12_STAGE: loading or constructing mapped Eq. (46) cache"];
countertermPayload = If[
  FileExistsQ[countertermCachePath],
  Quiet@Check[Get[countertermCachePath], $Failed],
  Missing["Absent"]
];
If[
  ! validCountertermCacheQ[
    countertermPayload, s10SHA256, s11SHA256, paperSHA256
  ],
  If[FileExistsQ[countertermCachePath],
    Print["S12_COUNTERTERM_CACHE_INVALID: deleting ", countertermCachePath];
    DeleteFile[countertermCachePath]
  ];
  countertermPayload = buildMappedCountertermPayload[];
  atomicPut[countertermPayload, countertermCachePath];
  Print["S12_COUNTERTERM_CHECKPOINT: mapped cache complete"],
  Print["S12_COUNTERTERM_RESUME: validated mapped cache"]
];
assert[
  validCountertermCacheQ[
    countertermPayload, s10SHA256, s11SHA256, paperSHA256
  ],
  "Mapped counterterm cache failed final validation."
];
countertermPolePairs = countertermPayload["PolePairs"];
countertermFinitePairs = countertermPayload["FinitePairs"];
countertermCacheSHA256 = sha256Hex[countertermCachePath];
equivalenceResiduals = countertermPayload["EquivalenceResiduals"];
Clear[countertermPayload];
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
      "restart required before pole reduction"
  ];
  Quit[75]
];

zeroEquivalentResidual[
    expression_, label_String,
    components_: Missing["NotCaptured"]
  ] := Module[
  {residual, reduced, diagnosticPayload},
  residual = canonicalizeForCombination[expression];
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
    "ProgramSHA256" -> programSHA256,
    "S10SHA256" -> s10SHA256,
    "S11SHA256" -> s11SHA256,
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

If[FileExistsQ[residualDiagnosticPath],
  Print[
    "S12_DIAGNOSTIC_CLEANUP: deleting validated obsolete Pg pole residual"
  ];
  DeleteFile[residualDiagnosticPath];
  assert[
    ! FileExistsQ[residualDiagnosticPath],
    "The obsolete legacy residual diagnostic was not deleted."
  ]
];

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
          projector <> " epsilon^" <>
            If[order === "Minus2", "-2 ", "-1 "] <> field,
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
assert[
  And @@ Flatten@Table[
    TrueQ[poleResiduals[projector][order][field] === 0],
    {projector, projectors},
    {order, {"Minus2", "Minus1"}},
    {field, pairFields}
  ],
  "At least one Hqqbar S12 pole component did not cancel."
];

Print["S12_STAGE: constructing finite Hqqbar projector actions"];
finitePairs = <||>;
finiteFactorizedActions = <||>;
Do[
  finiteS10PhiS = loadAggregateCoefficient[projector, 0];
  finitePairs[projector] = Map[
    canonicalizeForCombination,
    pairAdd[
      <|
        "Endpoint" -> 0,
        "IntegrandPhiS" -> finiteS10PhiS,
        "IntegrandPhi0" -> 0
      |>,
      countertermFinitePairs[projector]
    ]
  ];
  finiteFactorizedActions[projector] = pairToAction[
    finitePairs[projector], projector
  ];
  Clear[finiteS10PhiS];
  ClearSystemCache[];,
  {projector, projectors}
];

forbiddenFinalObjects =
  epsilon | _SeriesData | S11SEpsilon | _S11ConvolutionTest |
    _S11PlusDistribution | DiracDelta[s23] | _S09EndpointValue |
    _S09PlusDistribution | FeynCalc`SUNN | _Real;

s12Checks = <|
  "ExactS10ProgramResultAndCachesPinned" -> True,
  "ExactS11ProgramResultAndPaperPinned" -> True,
  "AllAcceptedUpstreamChecksTrue" -> True,
  "FeynCalcLoadedBeforeSerializedArtifacts" -> True,
  "PhysicalEq29ToEq32MapRebuilt" -> True,
  "AllMapAndBornDeltaRootResidualsExactZero" ->
    And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "FourSavedCountertermKeysMapped" -> True,
  "DirectAndIndependentEq46RebuildsAgree" ->
    And @@ Flatten[
      Map[
        Function[projectorResiduals,
          TrueQ[# === 0] & /@ Values[projectorResiduals]
        ],
        Values[equivalenceResiduals]
      ]
    ],
  "OnlyHgqbarPgqPDFAndHqgPqgFFRoutesUsed" -> True,
  "OnlyPPPPDFReceivesOneOverYSquared" -> True,
  "PositiveEq46SignInherited" -> True,
  "ExactMSBarSEpsilonExpandedBySeries" -> True,
  "SUNNToCAColorCanonicalizationExact" ->
    TrueQ[colorCanonicalizationRegressionResidual === 0],
  "SavedLegacyPoleResidualRegressionPassedWhenPresent" -> If[
    legacyResidualPresentAtStart,
    TrueQ[legacyResidualRegressionPassed],
    True
  ],
  "NoAdditionalCountertermMuEpsilon" -> True,
  "S10RealScaleMuPowerNotReapplied" -> True,
  "S10ActionHasOnlyPhiSField" -> True,
  "S10PgOneAlpha2Plus75OrdinaryTerms" -> True,
  "S10PPPOneAlpha2Plus77OrdinaryTerms" -> True,
  "BoundedSerialPerTermLaurentExtraction" -> True,
  "AtomicProgramAndExpressionBoundResumeCaches" -> True,
  "NoWholeLargeActionSeries" -> True,
  "PgDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Pg"]["Minus2"]]),
  "PgSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Pg"]["Minus1"]]),
  "PPPDoublePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["PPP"]["Minus2"]]),
  "PPPSimplePoleCancels" ->
    And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["PPP"]["Minus1"]]),
  "FiniteActionsContainNoForbiddenObjectOrMachineNumber" ->
    And @@ (FreeQ[#, forbiddenFinalObjects] & /@
      Values[finiteFactorizedActions]),
  "FinitePairsAndActionsContainNoSUNN" -> FreeQ[
    {finitePairs, finiteFactorizedActions},
    FeynCalc`SUNN
  ],
  "FiniteActionsRetainOrdinaryS23Integral" ->
    And @@ (! FreeQ[#, Inactive[Integrate][___]] & /@
      Values[finiteFactorizedActions]),
  "FiniteActionsRetainArbitraryS10Test" ->
    And @@ (! FreeQ[#, _S10ConvolutionTest] & /@
      Values[finiteFactorizedActions]),
  "ChargeStrippedConventionPreserved" -> True,
  "PhysicalFlavorChargeWeightDeferred" -> True,
  "IdenticalSpectatorFactorNotReapplied" -> True,
  "NoLOOrVirtualContributionIntroduced" -> True,
  "NoHermitianProjectionIntroduced" ->
    And @@ (FreeQ[#, _Re] & /@ Values[finiteFactorizedActions]),
  "NoAccidentalGlobalFeynCalcSymbols" ->
    feynCalcContextCleanQ[{
      countertermPolePairs,
      countertermFinitePairs,
      finitePairs,
      finiteFactorizedActions
    }],
  "CalculationFullySymbolicAndExact" -> True,
  "Eq9FHatAndBigTMDDeferred" -> True
|>;
assert[
  And @@ Values[s12Checks],
  "At least one final Hqqbar S12 validation check is not True."
];

s12Result = <|
  "Status" -> "CompleteFiniteFactorizedHqqbar",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "finite Eq. (46)-factorized H_{q qbar; q q} projector actions",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> ExpandFileName[$InputFileName],
  "ProgramSHA256" -> programSHA256,
  "InputProvenance" -> <|
    "S10ResultPath" -> s10Path,
    "S10ResultSHA256" -> s10SHA256,
    "S10ProgramSHA256" -> expectedS10ProgramSHA256,
    "S10EndpointCacheSHA256" -> expectedS10CacheSHA256,
    "S11ResultPath" -> s11Path,
    "S11ResultSHA256" -> s11SHA256,
    "S11ProgramSHA256" -> expectedS11ProgramSHA256,
    "AuthoritativePaperPath" -> paperPath,
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
    "SEpsilonDefinition" -> HoldForm[
      S11SEpsilon == (4 Pi)^epsilon/Gamma[1 - epsilon]
    ],
    "PDFRoute" -> "Hgqbar^(LO) x Pgq",
    "FFRoute" -> "Hqg^(LO) x Pqg",
    "ColorCanonicalization" -> HoldForm[
      FeynCalc`SUNN == FeynCalc`CA
    ],
    "AdditionalMuEpsilonFromPartonicPDForFF" -> 0,
    "AdditionalMultiplicativeWeightAtS12" -> 1
  |>,
  "CountertermMappingEquivalenceResiduals" -> equivalenceResiduals,
  "S10LaurentCaches" -> <|
    "TermParts" -> partCacheRoot,
    "Aggregates" -> aggregateCacheRoot,
    "S10SourceSHA256" -> s10SHA256,
    "S12ProgramSHA256" -> programSHA256,
    "CompatibleLegacyTermProgramSHA256" ->
      compatibleLegacyS12ProgramSHA256,
    "LegacyMigrationChangesCoefficients" -> False
  |>,
  "MappedCountertermCache" -> countertermCachePath,
  "MappedCountertermCacheSHA256" -> countertermCacheSHA256,
  "PoleResiduals" -> poleResiduals,
  "FiniteCoefficientPairsByProjector" -> finitePairs,
  "FiniteFactorizedActionsByProjector" -> finiteFactorizedActions,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS12" -> 1,
    "ChargeStripped" -> True,
    "PhysicalFlavorChargeWeight" -> "Sum_q e_q^2 f_q D_qbar",
    "PhysicalFlavorChargeWeightApplied" -> False,
    "IdenticalSpectatorFactorAppliedUpstreamAtS08" -> 1/2,
    "IdenticalSpectatorFactorReappliedAtS12" -> False,
    "RealAbsoluteScaleInherited" -> FeynCalc`ScaleMu^(4 epsilon),
    "CountertermBornAbsoluteScaleInherited" -> FeynCalc`ScaleMu^(2 epsilon),
    "ColorBasisAtCombination" -> HoldForm[
      FeynCalc`SUNN == FeynCalc`CA
    ],
    "VirtualContributionAtThisOrder" -> 0
  |>,
  "Checks" -> s12Checks,
  "ParallelExecution" -> <|
    "Used" -> False,
    "Reason" ->
      "each Laurent unit is a single exact expression; projector copies would increase peak memory and OOM risk"
  |>,
  "MemoryStrategy" ->
    "serial Pg then PPP; one alpha-two plus 75/77 ordinary terms; 4-GiB per-term allocation bound; at most 16 new terms per kernel epoch; atomic term and aggregate checkpoints",
  "NotPerformedAtThisStage" -> {
    "paper Eq. (9) projector inversion",
    "F-hat extraction",
    "physical flavor-charge PDF/FF convolution",
    "BigTMD comparison",
    "numerical kinematics"
  }
|>;

Print["S12_STAGE: writing finite factorized Hqqbar result"];
atomicPut[s12Result, resultPath];
assert[
  FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "The final Hqqbar S12 result was not written."
];
Print["S12_SUCCESS_FINITE_FACTORIZED_HQQBAR"];
Print["S12_RESULT_PATH=", resultPath];
Print["S12_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S12_RESULT_SHA256=", sha256Hex[resultPath]];
Print["S12_POLE_RESIDUALS=", InputForm[poleResiduals]];
Print["S12_CHECKS=", InputForm[s12Checks]];

Quit[0];

(* ::Package:: *)

(*
  Hqg stage S12-v4: map the S11 Eq. (46) counterterms to the exact physical
  xi-s23 variables, combine them with the endpoint-resolved real and
  UV-renormalized virtual S10 action, prove every epsilon pole component,
  and save finite Pg/PPP hard actions.

  Reused corrected boundaries:
    - Hgg S12-v2 context-clean, bounded, restartable term extraction;
    - Hqq S12-v4 cache-first large-input and bounded-memory separation;
    - Hqq S12 Package-X-to-paper conversion and physical Hermitian endpoint;
    - Hqg routing PDF Hqg/Pqq and FF Hqg/Pgg + Hqq/Pgq.

  The 535 MB S10 wrapper is never loaded as one Wolfram expression.  Its
  SHA-256-bound metadata prefix, 18 MB RealByProjector value, and final
  provenance/check tail are located with a fixed-memory byte scan and parsed
  separately.  This avoids materializing the large VirtualByProjector and
  duplicated RealPlusVirtualByProjector values merely to extract the real
  action.

  A kernel that writes new term checkpoints exits cleanly with code 75 after
  a bounded epoch.  The production command relaunches the same source, which
  validates and resumes every cache before doing further work.
*)

$HistoryLength = 0;
$LoadFeynArts = False;
Needs["FeynCalc`"];
ClearAll["Global`*"];
$HistoryLength = 0;
$FCAdvice = False;

fatal[message_String] := (
  Print["S12_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s10Path = FileNameJoin[{scriptDirectory, "s10_result"}];
s11Path = FileNameJoin[{scriptDirectory, "s11_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s12_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
bigTMDPgPath = FileNameJoin[{
  DirectoryName[scriptDirectory], "Hqq", "bigTMD_check",
  "BigTMD_reference", "NLO", "Pg", "fchn3A.py"
}];
bigTMDPPPPath = FileNameJoin[{
  DirectoryName[scriptDirectory], "Hqq", "bigTMD_check",
  "BigTMD_reference", "NLO", "Ppp", "fchn3A.py"
}];

realPairCachePath = FileNameJoin[{
  scriptDirectory, "s12_cache_v3_s10_real_pairs"
}];
countertermCachePath = FileNameJoin[{
  scriptDirectory, "s12_cache_v1_mapped_counterterms"
}];
partCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_s10_laurent_parts"
}];
preS10V4PartCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_s10_laurent_parts_pre_s10v4"
}];
legacyPartCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v1_s10_laurent_parts"
}];
aggregateCacheRoot = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_s10_laurent"
}];
virtualCoefficientCachePath = FileNameJoin[{
  scriptDirectory, "s12_cache_v2_virtual_coefficients"
}];
residualDiagnosticPath = FileNameJoin[{
  scriptDirectory, "s12_last_nonzero_residual"
}];

stageVersion = "HqgS12-v4";
cacheVersion = 2;
validatedReusableV1ProgramSHA256 =
  8272707422148071960269416694084829053384590744805375770667325752931393648325;
validatedReusableV2ProgramSHA256 =
  36253891252279108345129822174944028505229473838296887013933493268778215803582;
preNestedPiecewiseFixProgramSHA256 =
  15941351316085368428946694735431957269316498526404105696331208242569894881569;
preS10V4ProgramSHA256 =
  64915749403762016847211063369570906257929456451641819133806794448870618513759;
validatedPreS10V4S10SHA256 =
  65146701543480292749347103432976904859306903589834590712825600398049466544887;
validatedPreS10V4RealPairSHA256 =
  2101970204138440450677776145226989298924727793610578208101696965305213031017;
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
laurentPowers = {-2, -1, 0};
validatedS10SHA256 =
  29975931372452105169281952251300394081028751839669998460276132876570430461653;
validatedS11SHA256 =
  109052492640906451903927622676425174136431964022378605209519033470945624700159;

gibibyte = 1024^3;
perTermMemoryLimit = 4 gibibyte;
residualMemoryLimit = 6 gibibyte;
residualReductionTimeoutSeconds = 1200;
maximumNewTermsPerKernelEpoch = 16;
maximumSplitLeafCount = 100000;
newTermsThisKernelEpoch = 0;
expectedFastPartitionTermCounts = Missing["NotLoaded"];

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
  Check[Put[expression, temporaryPath],
    fatal["Atomic write failed for " <> path <> "."]];
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

findUniqueByteMarkerOffsets[path_String, markers_List] := Module[
  {
    chunkSize = 1024^2, markerBytes, offsets, maximumMarkerLength,
    stream, overlap = {}, chunk, data, dataStart, positions, marker
  },
  markerBytes = AssociationThread[
    markers,
    (ToCharacterCode[#, "UTF8"] &) /@ markers
  ];
  offsets = AssociationThread[
    markers,
    ConstantArray[{}, Length[markers]]
  ];
  maximumMarkerLength = Max[Length /@ Values[markerBytes]];
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "The S10 result could not be opened for bounded byte scanning."];
  While[True,
    chunk = Quiet@Check[
      BinaryReadList[stream, "Byte", chunkSize],
      $Failed
    ];
    assert[chunk =!= $Failed,
      "The bounded S10 byte scan failed while reading a chunk."];
    If[chunk === {} || chunk === EndOfFile, Break[]];
    data = Join[overlap, chunk];
    dataStart = StreamPosition[stream] - Length[chunk] - Length[overlap];
    Do[
      positions = SequencePosition[data, markerBytes[marker]];
      offsets[marker] = Join[
        offsets[marker],
        (dataStart + First[#] - 1 &) /@ positions
      ];,
      {marker, markers}
    ];
    overlap = Take[
      data,
      -Min[Length[data], maximumMarkerLength - 1]
    ];
  ];
  Close[stream];
  offsets = Map[DeleteDuplicates, offsets];
  assert[AllTrue[Values[offsets], Length[#] === 1 &],
    "The validated S10 result does not contain exactly one copy of every " <>
      "required projected-load marker."];
  AssociationMap[First[offsets[#]] &, markers]
];

readUTF8ByteRange[
    path_String, start_Integer, count_Integer, label_String
  ] := Module[{stream, bytes},
  assert[start >= 0 && count >= 0,
    "Invalid byte range requested for " <> label <> "."];
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "The S10 result could not be opened for " <> label <> "."];
  SetStreamPosition[stream, start];
  bytes = Quiet@Check[BinaryReadList[stream, "Byte", count], $Failed];
  Close[stream];
  assert[ListQ[bytes] && Length[bytes] === count,
    "The bounded S10 read was incomplete for " <> label <> "."];
  FromCharacterCode[bytes, "UTF8"]
];

parseProjectedS10Text[text_String, label_String] := Module[{held},
  held = Quiet@Check[ToExpression[text, InputForm, HoldComplete], $Failed];
  assert[MatchQ[held, HoldComplete[_]],
    "The projected S10 text did not parse for " <> label <> "."];
  ReleaseHold[held]
];

dropTrailingFieldSeparator[text_String, label_String] := Module[
  {trimmed = StringTrim[text]},
  assert[StringEndsQ[trimmed, ","],
    "The projected S10 field boundary is malformed for " <> label <> "."];
  StringTrim[StringDrop[trimmed, -1]]
];

loadProjectedS10Result[path_String] := Module[
  {
    distributionMarker = "\"DistributionActions\" ->",
    realMarker = "\"RealByProjector\" ->",
    virtualMarker = "\"VirtualByProjector\" ->",
    tailMarker = "\"HardKernelWeight\" ->",
    markers, offsets, fileBytes, metadataPrefixText, realText, tailText,
    metadataPrefix, realActions, metadataTail
  },
  markers = {
    distributionMarker, realMarker, virtualMarker, tailMarker
  };
  fileBytes = FileByteCount[path];
  offsets = findUniqueByteMarkerOffsets[path, markers];
  assert[
    0 < offsets[distributionMarker] < offsets[realMarker] <
      offsets[virtualMarker] < offsets[tailMarker] < fileBytes,
    "The validated S10 projected-load fields are out of order."];

  metadataPrefixText = dropTrailingFieldSeparator[
    readUTF8ByteRange[
      path, 0, offsets[distributionMarker], "metadata prefix"
    ],
    "metadata prefix"
  ];
  metadataPrefix = parseProjectedS10Text[
    metadataPrefixText <> "|>",
    "metadata prefix"
  ];

  realText = dropTrailingFieldSeparator[
    readUTF8ByteRange[
      path,
      offsets[realMarker] +
        Length[ToCharacterCode[realMarker, "UTF8"]],
      offsets[virtualMarker] - offsets[realMarker] -
        Length[ToCharacterCode[realMarker, "UTF8"]],
      "RealByProjector"
    ],
    "RealByProjector"
  ];
  realActions = parseProjectedS10Text[realText, "RealByProjector"];

  tailText = readUTF8ByteRange[
    path,
    offsets[tailMarker],
    fileBytes - offsets[tailMarker],
    "final provenance/check tail"
  ];
  metadataTail = parseProjectedS10Text[
    "<|" <> tailText,
    "final provenance/check tail"
  ];

  assert[
    AssociationQ[metadataPrefix] && AssociationQ[realActions] &&
      AssociationQ[metadataTail],
    "The projected S10 slices do not have the required association schema."];
  <|
    "Metadata" -> Join[metadataPrefix, metadataTail],
    "RealActions" -> realActions,
    "MarkerOffsets" -> offsets,
    "FileBytes" -> fileBytes
  |>
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

actionToPair[action_, projector_String] := Module[
  {
    integrals, integral, body, upper, endpointExpression,
    endpoint, integrandPhiS, integrandPhi0, testOccurrences
  },
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]],
    {0, Infinity}
  ];
  assert[Length[integrals] === 1,
    projector <> " S10 real action does not contain exactly one integral."];
  integral = First[integrals];
  body = integral[[1]];
  upper = integral[[2, 3]];
  assert[TrueQ[Cancel[Together[upper - s23UpperB]] === 0],
    projector <> " S10 integral upper limit differs from the S08 map."];
  endpointExpression = action /.
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]] :> 0;
  endpoint = Coefficient[
    endpointExpression, S10ConvolutionTest[projector, 0]
  ];
  integrandPhiS = Coefficient[
    body, S10ConvolutionTest[projector, s23]
  ];
  integrandPhi0 = Coefficient[
    body, S10ConvolutionTest[projector, 0]
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
    projector <> " S10 action has an unexpected test-function argument."
  ];
  <|
    "Endpoint" -> endpoint,
    "IntegrandPhiS" -> integrandPhiS,
    "IntegrandPhi0" -> integrandPhi0
  |>
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
    parts, coefficients = <||>, reportedMinima = {}, part,
    partSeries, partMinimum, shift, normalizedPart, power,
    coefficient, nonzeroPowers, minimumPower
  },
  parts = If[Head[expression] === Plus, List @@ expression, {expression}];
  Do[
    partSeries = Quiet@Check[Series[part, {epsilon, 0, maximum}], $Failed];
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
        normalizedPart, epsilon, power + shift
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
    Sort[Keys[coefficients]], ! TrueQ[coefficients[#] === 0] &
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
      coefficients[#] &, nonzeroPowers
    ]
  |>
];

convolveLaurentCoefficientData[
    factorData_List, maximum_Integer
  ] := Module[
  {
    answer = <|0 -> 1|>, nextAnswer, remainingMinimum,
    maximumPartialPower, factor, totalPower, factorIndex
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
    coefficients = <||>, power, coefficient
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
    factorData, maximum
  ];
  Do[
    coefficient = regularFactor Lookup[productCoefficients, power, 0];
    If[! FreeQ[coefficient, epsilon], Return[$Failed]];
    AssociateTo[coefficients, power -> coefficient];,
    {power, powers}
  ];
  coefficients
];

liftSinglePiecewiseProductFactor[expression_] := Module[
  {
    factors, piecewisePositions, piecewiseFactor, commonFactor,
    rows, defaultValue, conditions
  },
  If[Head[expression] === Piecewise || Head[expression] =!= Times,
    Return[expression]
  ];
  factors = List @@ expression;
  piecewisePositions = Select[
    Range[Length[factors]],
    Head[factors[[#]]] === Piecewise &
  ];
  If[piecewisePositions === {}, Return[expression]];
  If[Length[piecewisePositions] =!= 1, Return[$Failed]];
  piecewiseFactor = factors[[First[piecewisePositions]]];
  rows = piecewiseFactor[[1]];
  defaultValue = If[Length[piecewiseFactor] === 2, piecewiseFactor[[2]], 0];
  If[! ListQ[rows] || ! And @@ (MatchQ[#, {_, _}] & /@ rows),
    Return[$Failed]
  ];
  conditions = If[rows === {}, {}, rows[[All, 2]]];
  If[! And @@ (FreeQ[#, epsilon] & /@ conditions), Return[$Failed]];
  commonFactor = Times @@ Delete[factors, First[piecewisePositions]];
  Piecewise[
    ({commonFactor #[[1]], #[[2]]} &) /@ rows,
    commonFactor defaultValue
  ]
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
            defaultAnswer, piecewiseFactorCount
          },
          canonicalTerm = term /. qcdAndConstantRules;
          piecewiseFactorCount = If[
            Head[canonicalTerm] === Times,
            Count[List @@ canonicalTerm, _Piecewise],
            0
          ];
          canonicalTerm = liftSinglePiecewiseProductFactor[canonicalTerm];
          If[canonicalTerm === $Failed, Return[$Failed, Module]];
          If[piecewiseFactorCount === 1,
            Print[
              "S12_PIECEWISE_FACTOR_LIFT: branches=",
              Length[canonicalTerm[[1]]]
            ]
          ];
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
                    {Lookup[branchAnswer, currentPower, 0], condition}
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
      ],
    Return[$Failed]
  ];
  answer
];

splitExactSourceTermsUnchecked[
    expression_, projector_String, field_String
  ] := Module[
  {
    topTerms, answer = {}, current, factors, plusPositions,
    selectedPosition, selectedPlus, commonFactor, splitTerms
  },
  topTerms = If[
    Head[expression] === Plus,
    List @@ expression,
    {expression}
  ];
  Do[
    current = topTerm;
    If[LeafCount[current] <= maximumSplitLeafCount,
      AppendTo[answer, current];
      Continue[]
    ];
    factors = If[Head[current] === Times, List @@ current, {current}];
    plusPositions = Select[
      Range[Length[factors]], Head[factors[[#]]] === Plus &
    ];
    If[plusPositions === {},
      AppendTo[answer, current];
      Continue[]
    ];
    selectedPosition = First@MaximalBy[
      plusPositions, LeafCount[factors[[#]]] &
    ];
    selectedPlus = factors[[selectedPosition]];
    commonFactor = Times @@ Delete[factors, selectedPosition];
    splitTerms = (commonFactor # &) /@ (List @@ selectedPlus);
    answer = Join[answer, splitTerms];,
    {topTerm, topTerms}
  ];
  assert[Length[answer] > 0,
    projector <> " " <> field <> " split produced no source terms."];
  answer
];

splitExactSourceTerms[
    expression_, projector_String, field_String
  ] := Module[{answer, expectedCount},
  answer = splitExactSourceTermsUnchecked[
    expression, projector, field
  ];
  assert[AssociationQ[expectedFastPartitionTermCounts] &&
      AssociationQ[expectedFastPartitionTermCounts[projector]],
    "The hash-bound S10 source-partition manifest is unavailable for " <>
      projector <> " " <> field <> "."];
  expectedCount = expectedFastPartitionTermCounts[projector, field];
  assert[
    IntegerQ[expectedCount] && expectedCount > 0 &&
      Length[answer] === expectedCount,
    projector <> " " <> field <>
      " fast source partition differs from its hash-bound manifest."
  ];
  Print[
    "S12_S10_PARTITION: projector=", projector,
    " field=", field,
    " terms=", Length[answer],
    " maxLeafCount=", Max[LeafCount /@ answer],
    " strategy=one-level-factorwise"
  ];
  answer
];

partCacheFileName[
    projector_String, field_String, position_Integer
  ] := ToLowerCase[projector] <> "_" <> ToLowerCase[field] <> "_" <>
    IntegerString[position, 10, 4];

partCachePath[
    projector_String, field_String, position_Integer
  ] := FileNameJoin[{
  partCacheRoot,
  partCacheFileName[projector, field, position]
}];

legacyPartCachePath[
    projector_String, field_String, position_Integer
  ] := FileNameJoin[{
  legacyPartCacheRoot,
  partCacheFileName[projector, field, position]
}];

preS10V4PartCachePath[
    projector_String, field_String, position_Integer
  ] := FileNameJoin[{
  preS10V4PartCacheRoot,
  partCacheFileName[projector, field, position]
}];

validReusableV1ProvenanceQ[payload_] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === 1 &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === "HqgS12-v1" &&
  Lookup[payload, "ProgramSHA256", Missing["Absent"]] ===
    validatedReusableV1ProgramSHA256
];

validV2ProvenanceQ[payload_] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  MemberQ[
    {
      programSHA256,
      validatedReusableV2ProgramSHA256,
      preNestedPiecewiseFixProgramSHA256,
      preS10V4ProgramSHA256
    },
    Lookup[payload, "ProgramSHA256", Missing["Absent"]]
  ]
];

validPartPayloadQ[
    payload_, projector_String, field_String, position_Integer,
    termHash_Integer, s10SHA256_Integer, realPairSHA256_Integer
  ] := TrueQ[
  validV2ProvenanceQ[payload] &&
  MemberQ[
    {s10SHA256, validatedPreS10V4S10SHA256},
    Lookup[payload, "S10SHA256", Missing["Absent"]]
  ] &&
  Lookup[payload, "RealPairCacheSHA256", Missing["Absent"]] ===
    realPairSHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Field", Missing["Absent"]] === field &&
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

validReusablePreS10V4PartPayloadQ[
    payload_, projector_String, field_String, position_Integer,
    termHash_Integer
  ] := TrueQ[
  AssociationQ[payload] &&
  Lookup[payload, "CacheVersion", Missing["Absent"]] === cacheVersion &&
  Lookup[payload, "StageVersion", Missing["Absent"]] === stageVersion &&
  Lookup[payload, "ProgramSHA256", Missing["Absent"]] ===
    preS10V4ProgramSHA256 &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] ===
    validatedPreS10V4S10SHA256 &&
  Lookup[payload, "RealPairCacheSHA256", Missing["Absent"]] ===
    validatedPreS10V4RealPairSHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Field", Missing["Absent"]] === field &&
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

validReusableV1PartPayloadQ[
    payload_, projector_String, field_String, position_Integer,
    termHash_Integer, s10SHA256_Integer, realPairSHA256_Integer
  ] := TrueQ[
  validReusableV1ProvenanceQ[payload] &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "RealPairCacheSHA256", Missing["Absent"]] ===
    realPairSHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Field", Missing["Absent"]] === field &&
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
    term_, projector_String, field_String, position_Integer,
    s10SHA256_Integer, realPairSHA256_Integer
  ] := Module[
  {
    path, preS10V4Path, legacyPath, termHash, payload,
    preS10V4Payload, preS10V4PayloadSHA256, legacyPayload,
    legacyPayloadSHA256, coefficients
  },
  path = partCachePath[projector, field, position];
  preS10V4Path = preS10V4PartCachePath[
    projector, field, position
  ];
  legacyPath = legacyPartCachePath[projector, field, position];
  termHash = Hash[Unevaluated[term], "SHA256"];
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[validPartPayloadQ[
        payload, projector, field, position, termHash,
        s10SHA256, realPairSHA256
      ],
      Print[
        "S12_TERM_RESUME: ", projector, " ", field,
        " position ", position
      ];
      Clear[payload];
      Return[path]
    ];
    Print["S12_TERM_CACHE_INVALID: deleting ", path];
    DeleteFile[path];
    Clear[payload]
  ];
  If[FileExistsQ[preS10V4Path],
    preS10V4Payload = Quiet@Check[Get[preS10V4Path], $Failed];
    If[validReusablePreS10V4PartPayloadQ[
        preS10V4Payload, projector, field, position, termHash
      ],
      preS10V4PayloadSHA256 = FileHash[preS10V4Path, "SHA256"];
      atomicPut[
        <|
          "CacheVersion" -> cacheVersion,
          "StageVersion" -> stageVersion,
          "ProgramSHA256" -> programSHA256,
          "S10SHA256" -> s10SHA256,
          "RealPairCacheSHA256" -> realPairSHA256,
          "Projector" -> projector,
          "Field" -> field,
          "Position" -> position,
          "TermSHA256" -> termHash,
          "Powers" -> laurentPowers,
          "Coefficients" -> preS10V4Payload["Coefficients"],
          "ReusedPreS10V4PayloadSHA256" -> preS10V4PayloadSHA256,
          "ReuseGate" ->
            "exact corrected source-term SHA256 plus fixed old provenance"
        |>,
        path
      ];
      DeleteFile[preS10V4Path];
      Print[
        "S12_TERM_REUSE_PRE_S10V4: ", projector, " ", field,
        " position ", position
      ];
      Clear[preS10V4Payload, preS10V4PayloadSHA256];
      Return[path],
      Print[
        "S12_TERM_PRE_S10V4_INVALID: deleting changed quarantined part ",
        preS10V4Path
      ];
      DeleteFile[preS10V4Path];
      Clear[preS10V4Payload]
    ]
  ];
  If[FileExistsQ[legacyPath],
    legacyPayload = Quiet@Check[Get[legacyPath], $Failed];
    If[validReusableV1PartPayloadQ[
        legacyPayload, projector, field, position, termHash,
        s10SHA256, realPairSHA256
      ],
      legacyPayloadSHA256 = FileHash[legacyPath, "SHA256"];
      atomicPut[
        <|
          "CacheVersion" -> cacheVersion,
          "StageVersion" -> stageVersion,
          "ProgramSHA256" -> programSHA256,
          "S10SHA256" -> s10SHA256,
          "RealPairCacheSHA256" -> realPairSHA256,
          "Projector" -> projector,
          "Field" -> field,
          "Position" -> position,
          "TermSHA256" -> termHash,
          "Powers" -> laurentPowers,
          "Coefficients" -> legacyPayload["Coefficients"],
          "ReusedV1Path" -> legacyPath,
          "ReusedV1PayloadSHA256" -> legacyPayloadSHA256
        |>,
        path
      ];
      Print[
        "S12_TERM_REUSE_V1: ", projector, " ", field,
        " position ", position
      ];
      Clear[legacyPayload, legacyPayloadSHA256];
      Return[path]
    ];
    Clear[legacyPayload]
  ];
  If[newTermsThisKernelEpoch >= maximumNewTermsPerKernelEpoch,
    Print[
      "S12_MEMORY_EPOCH_PAUSE: completed ",
      newTermsThisKernelEpoch,
      " new terms; restart required before ",
      projector, " ", field, " position ", position
    ];
    Quit[75]
  ];
  Print[
    "S12_TERM_STAGE: ", projector, " ", field,
    " position ", position,
    " leafCount=", LeafCount[term],
    " memoryGiB=", N[MemoryInUse[]/gibibyte, 3]
  ];
  coefficients = singleTermSeriesCoefficients[
    term, laurentPowers, 0, perTermMemoryLimit
  ];
  If[coefficients === $Failed,
    fatal[
      projector <> " " <> field <> " position " <>
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
      "RealPairCacheSHA256" -> realPairSHA256,
      "Projector" -> projector,
      "Field" -> field,
      "Position" -> position,
      "TermSHA256" -> termHash,
      "Powers" -> laurentPowers,
      "Coefficients" -> coefficients
    |>,
    path
  ];
  newTermsThisKernelEpoch++;
  Print[
    "S12_TERM_CHECKPOINT: ", projector, " ", field,
    " position ", position
  ];
  Clear[coefficients];
  ClearSystemCache[];
  path
];

aggregateCachePath[
    projector_String, field_String, power_Integer
  ] := FileNameJoin[{
  aggregateCacheRoot,
  ToLowerCase[projector] <> "_" <> ToLowerCase[field] <>
    "_power_" <> StringReplace[ToString[power], "-" -> "minus"]
}];

validAggregatePayloadQ[
    payload_, projector_String, field_String, power_Integer,
    s10SHA256_Integer, realPairSHA256_Integer, partHashes_List
  ] := TrueQ[
  validV2ProvenanceQ[payload] &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "RealPairCacheSHA256", Missing["Absent"]] ===
    realPairSHA256 &&
  Lookup[payload, "Projector", Missing["Absent"]] === projector &&
  Lookup[payload, "Field", Missing["Absent"]] === field &&
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
    projector_String, field_String, power_Integer, paths_List,
    s10SHA256_Integer, realPairSHA256_Integer
  ] := Module[
  {path, partHashes, payload, sum = 0, partPayload, position},
  path = aggregateCachePath[projector, field, power];
  partHashes = FileHash[#, "SHA256"] & /@ paths;
  If[FileExistsQ[path],
    payload = Quiet@Check[Get[path], $Failed];
    If[validAggregatePayloadQ[
        payload, projector, field, power, s10SHA256,
        realPairSHA256, partHashes
      ],
      Print[
        "S12_AGGREGATE_RESUME: ", projector, " ", field,
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
    "S12_AGGREGATE_STAGE: ", projector, " ", field,
    " epsilon^", power, " parts=", Length[paths]
  ];
  Do[
    partPayload = Quiet@Check[Get[paths[[position]]], $Failed];
    assert[AssociationQ[partPayload],
      "A validated S10 term cache became unreadable during aggregation."];
    sum = sum + Lookup[partPayload["Coefficients"], power, 0];
    Clear[partPayload];,
    {position, Length[paths]}
  ];
  assert[FreeQ[sum, epsilon | _SeriesData | $Failed],
    projector <> " " <> field <> " aggregate is invalid."];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "S10SHA256" -> s10SHA256,
      "RealPairCacheSHA256" -> realPairSHA256,
      "Projector" -> projector,
      "Field" -> field,
      "Power" -> power,
      "PartSHA256" -> partHashes,
      "Coefficient" -> sum
    |>,
    path
  ];
  Print[
    "S12_AGGREGATE_CHECKPOINT: ", projector, " ", field,
    " epsilon^", power, " leafCount=", LeafCount[sum]
  ];
  Clear[sum];
  ClearSystemCache[];
  path
];

loadAggregateCoefficient[
    projector_String, field_String, power_Integer
  ] := Module[{payload, coefficient},
  payload = Quiet@Check[
    Get[aggregateCachePath[projector, field, power]],
    $Failed
  ];
  assert[AssociationQ[payload] && KeyExistsQ[payload, "Coefficient"],
    "S10 aggregate is unreadable for " <> projector <> " " <> field <>
      " epsilon^" <> ToString[power] <> "."];
  coefficient = payload["Coefficient"];
  Clear[payload];
  coefficient
];

projectorCompletePath[projector_String] := FileNameJoin[{
  aggregateCacheRoot, ToLowerCase[projector] <> "_complete"
}];

validProjectorCompletePayloadQ[
    payload_, projector_String, s10SHA256_Integer,
    realPairSHA256_Integer
  ] := Module[{aggregatePaths},
  aggregatePaths = Flatten@Table[
    aggregateCachePath[projector, field, power],
    {field, pairFields},
    {power, laurentPowers}
  ];
  TrueQ[
    validV2ProvenanceQ[payload] &&
    Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
    Lookup[payload, "RealPairCacheSHA256", Missing["Absent"]] ===
      realPairSHA256 &&
    Lookup[payload, "Projector", Missing["Absent"]] === projector &&
    And @@ (FileExistsQ /@ aggregatePaths) &&
    Lookup[payload, "AggregateSHA256", Missing["Absent"]] ===
      (FileHash[#, "SHA256"] & /@ aggregatePaths)
  ]
];

processS10Projector[
    projector_String, s10SHA256_Integer, realPairSHA256_Integer
  ] := Module[
  {
    completionPath, completionPayload, realPairPayload, pair,
    field, terms, paths, position, aggregatePaths, fieldTermCounts = <||>
  },
  completionPath = projectorCompletePath[projector];
  If[FileExistsQ[completionPath],
    completionPayload = Quiet@Check[Get[completionPath], $Failed];
    If[validProjectorCompletePayloadQ[
        completionPayload, projector, s10SHA256, realPairSHA256
      ],
      Print["S12_S10_PROJECTOR_RESUME_COMPLETE: ", projector];
      Clear[completionPayload];
      Return[Null]
    ];
    Print["S12_PROJECTOR_MARKER_INVALID: deleting ", completionPath];
    DeleteFile[completionPath];
    Clear[completionPayload]
  ];
  realPairPayload = Quiet@Check[Get[realPairCachePath], $Failed];
  assert[AssociationQ[realPairPayload] &&
      AssociationQ[realPairPayload["Pairs", projector]],
    "The compact S10 real-pair cache is unreadable."];
  pair = realPairPayload["Pairs", projector];
  Clear[realPairPayload];
  Do[
    terms = splitExactSourceTerms[pair[field], projector, field];
    fieldTermCounts[field] = Length[terms];
    paths = Table[
      processS10Term[
        terms[[position]], projector, field, position,
        s10SHA256, realPairSHA256
      ],
      {position, Length[terms]}
    ];
    Do[
      aggregateS10Parts[
        projector, field, power, paths,
        s10SHA256, realPairSHA256
      ],
      {power, laurentPowers}
    ];
    Clear[terms, paths];
    ClearSystemCache[];,
    {field, pairFields}
  ];
  Clear[pair];
  aggregatePaths = Flatten@Table[
    aggregateCachePath[projector, field, power],
    {field, pairFields},
    {power, laurentPowers}
  ];
  atomicPut[
    <|
      "CacheVersion" -> cacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "S10SHA256" -> s10SHA256,
      "RealPairCacheSHA256" -> realPairSHA256,
      "Projector" -> projector,
      "FieldTermCounts" -> fieldTermCounts,
      "AggregateSHA256" ->
        (FileHash[#, "SHA256"] & /@ aggregatePaths)
    |>,
    completionPath
  ];
  Print["S12_S10_PROJECTOR_COMPLETE: ", projector];
  Clear[aggregatePaths];
  ClearSystemCache[]
];

validRealPairCacheQ[payload_, s10SHA256_Integer] := TrueQ[
  AssociationQ[payload] &&
  (
    validReusableV1ProvenanceQ[payload] ||
    validV2ProvenanceQ[payload]
  ) &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  TrueQ[Lookup[payload, "S10AllChecksTrue", False]] &&
  AssociationQ[Lookup[payload, "S10MarkerOffsets", Missing["Absent"]]] &&
  AssociationQ[Lookup[payload, "Pairs", Missing["Absent"]]] &&
  Sort[Keys[payload["Pairs"]]] === Sort[projectors] &&
  AssociationQ[
    Lookup[payload, "FieldTermCounts", Missing["Absent"]]
  ] &&
  And @@ Flatten@Table[
    AssociationQ[payload["Pairs", projector]] &&
      Sort[Keys[payload["Pairs", projector]]] === Sort[pairFields] &&
      AssociationQ[payload["FieldTermCounts", projector]] &&
      Sort[Keys[payload["FieldTermCounts", projector]]] ===
        Sort[pairFields] &&
      AllTrue[
        Values[payload["FieldTermCounts", projector]],
        IntegerQ[#] && # > 0 &
      ],
    {projector, projectors}
  ] &&
  FileExistsQ[Lookup[payload, "S10VirtualLaurentCache", ""]] &&
  FileHash[payload["S10VirtualLaurentCache"], "SHA256"] ===
    Lookup[payload, "S10VirtualLaurentCacheSHA256", Missing["Absent"]] &&
  feynCalcContextCleanQ[payload["Pairs"]]
];

validCountertermCacheQ[
    payload_, s11SHA256_Integer, paperSHA256_Integer
  ] := TrueQ[
  AssociationQ[payload] &&
  (
    validReusableV1ProvenanceQ[payload] ||
    validV2ProvenanceQ[payload]
  ) &&
  Lookup[payload, "S11SHA256", Missing["Absent"]] === s11SHA256 &&
  Lookup[payload, "PaperSHA256", Missing["Absent"]] === paperSHA256 &&
  AssociationQ[Lookup[payload, "Order0", Missing["Absent"]]] &&
  AssociationQ[Lookup[payload, "Order1", Missing["Absent"]]] &&
  And @@ Flatten@Table[
    AssociationQ[payload[order, projector]] &&
      Sort[Keys[payload[order, projector]]] === Sort[pairFields] &&
      FreeQ[payload[order, projector], epsilon | _SeriesData | $Failed],
    {order, {"Order0", "Order1"}},
    {projector, projectors}
  ] &&
  feynCalcContextCleanQ[{payload["Order0"], payload["Order1"]}]
];

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

pggPair[density_, splittingVariable_, scale_] := Module[
  {density0, scale0, deltaCoefficient},
  density0 = Together[density /. s23 -> 0];
  scale0 = Together[scale /. s23 -> 0];
  deltaCoefficient =
    (11 FeynCalc`CA - 4 FeynCalc`TF FeynCalc`Nf)/3;
  <|
    "Endpoint" -> density0 *
      (4 FeynCalc`CA Log[s23UpperB/scale0] + deltaCoefficient),
    "IntegrandPhiS" -> 4 FeynCalc`CA * (
      density/s23 +
        (1/splittingVariable - 2 +
          splittingVariable (1 - splittingVariable)) density/scale
    ),
    "IntegrandPhi0" -> -4 FeynCalc`CA density0/s23
  |>
];

regularKernelPair[kernel_, density_, scale_] := <|
  "Endpoint" -> 0,
  "IntegrandPhiS" -> kernel density/scale,
  "IntegrandPhi0" -> 0
|>;

Print["S12_STAGE: validating S10, S11, paper, and BigTMD bindings"];
assert[FileExistsQ[s10Path], "s10_result does not exist."];
assert[FileExistsQ[s11Path], "s11_result does not exist."];
assert[FileExistsQ[paperPath], "The authoritative paper is absent."];
assert[FileExistsQ[bigTMDPgPath] && FileExistsQ[bigTMDPPPPath],
  "The local BigTMD Hqg channel-3A references are absent."];
s10SHA256 = FileHash[s10Path, "SHA256"];
s11SHA256 = FileHash[s11Path, "SHA256"];
paperSHA256 = FileHash[paperPath, "SHA256"];
assert[s10SHA256 === validatedS10SHA256,
  "The independently validated Hqg S10 artifact has changed."];
assert[s11SHA256 === validatedS11SHA256,
  "The independently validated Hqg S11 artifact has changed."];

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
  "The physical S08 upper-limit identity failed."];

Print["S12_STAGE: loading or constructing compact S10 real-pair cache"];
realPairCacheCreatedThisKernel = False;
realPairPayload = If[
  FileExistsQ[realPairCachePath],
  Quiet@Check[Get[realPairCachePath], $Failed],
  Missing["Absent"]
];
If[! validRealPairCacheQ[realPairPayload, s10SHA256],
  If[FileExistsQ[realPairCachePath],
    Print["S12_REAL_PAIR_CACHE_INVALID: deleting ", realPairCachePath];
    DeleteFile[realPairCachePath]
  ];
  Print[
    "S12_STAGE: bounded projected load of S10 metadata and real actions"
  ];
  s10Projection = loadProjectedS10Result[s10Path];
  s10Metadata = s10Projection["Metadata"];
  s10RealActions = s10Projection["RealActions"];
  s10EndpointData =
    s10Metadata["EndpointResolution", "EndpointDataByProjector"];
  assert[
    AssociationQ[s10Metadata] && AssociationQ[s10RealActions] &&
      s10Metadata["Status"] === "CompleteSymbolic" &&
      s10Metadata["Stage"] === "HqgS10-v4" &&
      s10Metadata["Channel"] === "Hqg only" &&
      AllTrue[Values[s10Metadata["Checks"]], TrueQ] &&
      s10Metadata["ReferencePDFSHA256"] === paperSHA256 &&
      KeyTake[
        s10Metadata["BigTMDProjectorMapping"],
        {"Pg", "PPP"}
      ] === <|
        "Pg" -> "NLO.Pg.fchn3A",
        "PPP" -> "NLO.Ppp.fchn3A"
      |> &&
      s10Metadata[
        "ElectricChargeNormalization", "AmplitudeStripFactor"
      ] === -3 &&
      s10Metadata["HardKernelWeight", "AppliedMultiplicativeWeight"] ===
        1 &&
      s10Metadata[
        "HardKernelWeight", "BigTMDLuminosityAppliedDownstream"
      ] ===
        "Sum_q e_q^2 f_q D_g" &&
      FileExistsQ[s10Metadata["Program"]] &&
      s10Metadata["ProgramSHA256"] ===
        FileHash[s10Metadata["Program"], "SHA256"] &&
      FileExistsQ[s10Metadata["SourceResult"]] &&
      s10Metadata["SourceResultSHA256"] ===
        FileHash[s10Metadata["SourceResult"], "SHA256"] &&
      FileExistsQ[s10Metadata["SourceS08"]] &&
      s10Metadata["SourceS08SHA256"] ===
        FileHash[s10Metadata["SourceS08"], "SHA256"] &&
      FileExistsQ[s10Metadata["SourceS07"]] &&
      s10Metadata["SourceS07SHA256"] ===
        FileHash[s10Metadata["SourceS07"], "SHA256"] &&
      AssociationQ[s10EndpointData] &&
      Sort[Keys[s10EndpointData]] === Sort[projectors] &&
      AllTrue[
        Values[s10EndpointData],
        Length[#["StandardTermIndices"]] +
            Length[#["Alpha2TermIndices"]] ===
          #["RemainderTermCount"] &
      ] &&
      s10EndpointData[
        "Pg", "CoupledLogEndpointGroups"
      ] === {{65, 66}} &&
      s10EndpointData[
        "PPP", "CoupledLogEndpointGroups"
      ] === {{38, 47}} &&
      AllTrue[
        Values[s10EndpointData[[All, "CoupledLogEndpointRepairApplied"]]],
        TrueQ
      ] &&
      TrueQ[s10Metadata[
        "Checks", "PhysicalBranchCoupledEndpointRepairApplied"
      ]] &&
      s10Metadata[
        "ParallelExecution", "RequestedEndpointWorkerCount"
      ] === 5 &&
      s10Metadata[
        "ParallelExecution", "RawEndpointParallelWorkRequired"
      ] === False &&
      s10Metadata[
        "ParallelExecution", "ValidatedKernelIDsSeen"
      ] === {} &&
      TrueQ[s10Metadata[
        "Checks", "EndpointWorkersUsedOnlyWhenRawTermsRequired"
      ]] &&
      TrueQ[s10Metadata[
        "Checks", "AllEndpointWorkersClosedBeforeFinalVirtualAssembly"
      ]] &&
      Sort[Keys[s10RealActions]] === Sort[projectors],
    "S10 identity, convention, checks, or upstream binding is invalid."
  ];
  s10VirtualLaurentCache =
    s10Metadata["VirtualLaurentExpansion", "LaurentCache"];
  s10VirtualLaurentCacheSHA256 =
    s10Metadata["VirtualLaurentExpansion", "LaurentCacheSHA256"];
  assert[
    FileExistsQ[s10VirtualLaurentCache] &&
      FileHash[s10VirtualLaurentCache, "SHA256"] ===
        s10VirtualLaurentCacheSHA256,
    "The S10 virtual Laurent cache binding is stale."
  ];
  realPairs = AssociationMap[
    actionToPair[s10RealActions[#], #] &,
    projectors
  ];
  assert[feynCalcContextCleanQ[realPairs],
    "S10 real actions contain accidental Global-context FeynCalc symbols."];
  pairFieldTermCounts = <||>;
  Do[
    pairFieldTermCounts[projector] = <||>;
    Do[
      partitionTerms = splitExactSourceTermsUnchecked[
        realPairs[projector, field], projector, field
      ];
      pairFieldTermCounts[projector, field] = Length[partitionTerms];
      Clear[partitionTerms];,
      {field, pairFields}
    ];,
    {projector, projectors}
  ];
  realPairPayload = <|
    "CacheVersion" -> cacheVersion,
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "S10SHA256" -> s10SHA256,
    "S10Program" -> s10Metadata["Program"],
    "S10ProgramSHA256" -> s10Metadata["ProgramSHA256"],
    "S10SourceResult" -> s10Metadata["SourceResult"],
    "S10SourceResultSHA256" -> s10Metadata["SourceResultSHA256"],
    "S10VirtualLaurentCache" -> s10VirtualLaurentCache,
    "S10VirtualLaurentCacheSHA256" -> s10VirtualLaurentCacheSHA256,
    "S10AllChecksTrue" ->
      AllTrue[Values[s10Metadata["Checks"]], TrueQ],
    "S10MarkerOffsets" -> s10Projection["MarkerOffsets"],
    "S10FileBytes" -> s10Projection["FileBytes"],
    "FieldTermCounts" -> pairFieldTermCounts,
    "LoadStrategy" ->
      "fixed-memory marker scan plus metadata/RealByProjector/tail slices",
    "Pairs" -> realPairs
  |>;
  Clear[
    s10Projection, s10Metadata, s10RealActions, s10EndpointData,
    realPairs, pairFieldTermCounts, partitionTerms
  ];
  ClearSystemCache[];
  atomicPut[realPairPayload, realPairCachePath];
  realPairCacheCreatedThisKernel = True;
  Print["S12_REAL_PAIR_CHECKPOINT: compact S10 real pairs complete"],
  Print["S12_REAL_PAIR_RESUME: validated compact S10 real pairs"]
];
assert[validRealPairCacheQ[realPairPayload, s10SHA256],
  "The compact S10 real-pair cache failed final validation."];
realPairCacheSHA256 = FileHash[realPairCachePath, "SHA256"];
s10ProgramSHA256 = realPairPayload["S10ProgramSHA256"];
s10VirtualLaurentCache = realPairPayload["S10VirtualLaurentCache"];
s10VirtualLaurentCacheSHA256 =
  realPairPayload["S10VirtualLaurentCacheSHA256"];
expectedFastPartitionTermCounts = realPairPayload["FieldTermCounts"];
Clear[realPairPayload];
ClearSystemCache[];
If[realPairCacheCreatedThisKernel,
  Print[
    "S12_MEMORY_EPOCH_PAUSE: compact S10 real-pair cache created; " <>
      "restart required before mapped counterterms and Laurent terms"
  ];
  Quit[75]
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
  Flatten[(splitVirtualEpsilonSums[commonFactor #] &) /@ summands, 1]
];

virtualTermPower[term_] := Module[
  {factors, powers, power, coefficient},
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

extractVirtualLaurentCoefficients[
    expression_, projector_String
  ] := Module[{terms, classified, grouped},
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

validVirtualCoefficientCacheQ[
    payload_, s10SHA256_Integer, sourceVirtualSHA256_Integer
  ] := TrueQ[
  validV2ProvenanceQ[payload] &&
  Lookup[payload, "S10SHA256", Missing["Absent"]] === s10SHA256 &&
  Lookup[payload, "SourceVirtualSHA256", Missing["Absent"]] ===
    sourceVirtualSHA256 &&
  AssociationQ[Lookup[payload, "Data", Missing["Absent"]]] &&
  Sort[Keys[payload["Data"]]] === Sort[projectors] &&
  And @@ Flatten@Table[
    AssociationQ[payload["Data", projector]] &&
      Sort[Keys[payload["Data", projector]]] ===
        Sort[{"Minus2", "Minus1", "Finite"}] &&
      FreeQ[
        payload["Data", projector],
        epsilon | _SeriesData | $Failed | Indeterminate |
          ComplexInfinity | DirectedInfinity[_]
      ],
    {projector, projectors}
  ] &&
  feynCalcContextCleanQ[payload["Data"]]
];

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
      Together[expression], residualReductionTimeoutSeconds, $Failed
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
  Branch-safe exact reducer inherited from corrected Hqq S12.  It is used
  only for large virtual endpoint simple poles and accepts only the already
  proven physical root and principal-log basis; otherwise it returns False
  and the guarded generic reducer remains authoritative.
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
    branchTransformed, branchExpression, unmatchedLogs, branchTerms,
    branchAssumptions, coefficient, constant, zeroLogRules,
    coefficientIndex
  },
  denominatorPhysical = rTPhysical + zH - rTPhysical zH;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  transformed = expression /. physicalSubstitution;
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  rootRadicands = DeleteDuplicates@Cases[
    transformed,
    Power[
      radicand_,
      power_Rational?((Denominator[#] === 2) &)
    ] :> radicand,
    Infinity
  ];
  If[
    rootRadicands === {} ||
      ! And @@ (
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
    positiveRoot = rootSign Q2 deltaPhysical/denominatorPhysical;
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
              rows[[All, 2]], Assumptions -> branchAssumptions
            ],
            $Failed
          ];
          If[truthValues === $Failed, Return[piece, Module]];
          truePosition = FirstPosition[truthValues, True];
          Which[
            ! MissingQ[truePosition], rows[[First[truePosition], 1]],
            And @@ (TrueQ[# === False] & /@ truthValues), default,
            True, piece
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
      ! VectorQ[
        structuralDegrees,
        IntegerQ[#] && 0 <= # <= 1 &
      ],
      Return[False]
    ];
    branchExpression =
      (branchTransformed /. rootRule) /. Log[value_] :> expandLog[value];
    unmatchedLogs = DeleteDuplicates@Cases[
      branchExpression, _unmatchedLog, Infinity
    ];
    If[unmatchedLogs =!= {}, Return[False]];
    branchTerms = If[
      Head[branchExpression] === Plus,
      List @@ branchExpression,
      {branchExpression}
    ];
    Print[
      "S12_POLE_REDUCTION_STAGE: endpoint single pole rootSign=",
      rootSign, " coefficients=", Length[logBasis] + 1
    ];
    Do[
      coefficient = Total[
        Coefficient[#, logBasis[[coefficientIndex]]] & /@ branchTerms
      ];
      If[
        ! exactPhysicalCoefficientZeroQ[coefficient, branchAssumptions],
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
      ! exactPhysicalCoefficientZeroQ[constant, branchAssumptions],
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
    residual, reduced, structuredEndpointResult,
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
      physicalEndpointSinglePoleZeroQ[residual], False
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
  Print[
    "S12_POLE_REDUCTION_STAGE: ", label,
    " leafCount=", LeafCount[residual]
  ];
  reduced = Quiet@Check[
    MemoryConstrained[
      TimeConstrained[
        Together[Cancel[residual]],
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
  diagnosticExpression = If[reduced === $Failed, residual, reduced];
  diagnosticPayload = <|
    "SchemaVersion" -> 1,
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "Label" -> label,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ReductionFailedOrTimedOut" -> TrueQ[reduced === $Failed],
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
  fatal[
    "Nonzero or unreduced residual: " <> label <>
      ". Exact diagnostic was written to " <> residualDiagnosticPath <> "."
  ]
];

Print["S12_STAGE: loading and validating compact Hqg S11 input"];
s11 = Quiet@Check[Get[s11Path], $Failed];
assert[
  AssociationQ[s11] &&
    s11["Status"] === "CompleteSymbolicCounterterms" &&
    s11["Stage"] === "HqgS11-v2" &&
    s11["Channel"] === "Hqg only" &&
    AllTrue[Values[s11["Checks"]], TrueQ] &&
    s11["CountertermCount"] === 4 &&
    Keys[s11["Counterterms"]] ===
      {"PgPDF", "PgFF", "PPPPDF", "PPPFF"} &&
    s11["SourceResults", "AuthoritativePaperSHA256"] === paperSHA256 &&
    s11["AppliedDirectBornNormalizationFactor"] === 9 &&
    s11["PhysicalLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g" &&
    s11["BigTMDConvention", "ChannelNumber"] === 3 &&
    s11["BigTMDConvention", "ChargeCase"] === "A only" &&
    s11["BigTMDConvention", "ProjectorMapping"] === <|
      "Pg" -> "NLO.Pg.fchn3A",
      "PPP" -> "NLO.Ppp.fchn3A"
    |>,
  "S11 identity, checks, charge, paper, or BigTMD convention is invalid."
];
bornProjected = s11["BornProjectedSquaredAmplitudes"];
assert[
  Sort[Keys[bornProjected]] === Sort[{"Hqg", "Hqq"}] &&
    And @@ Flatten@Table[
      KeyExistsQ[bornProjected[channel], projector],
      {channel, {"Hqg", "Hqq"}},
      {projector, projectors}
    ],
  "S11 lacks an Hqg or Hqq Born projector pair."
];
assert[feynCalcContextCleanQ[bornProjected],
  "S11 Born objects contain accidental Global-context FeynCalc symbols."];
bigTMDReferenceSHA256 = <|
  "Pg" -> FileHash[bigTMDPgPath, "SHA256"],
  "PPP" -> FileHash[bigTMDPPPPath, "SHA256"]
|>;
assert[bigTMDReferenceSHA256 ===
    s11["BigTMDConvention", "ReferenceSHA256"],
  "The local BigTMD channel-3A reference binding has changed."];
Clear[s11];

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
assert[AllTrue[Values[mappingResiduals], TrueQ[# === 0] &],
  "At least one physical Eq. (46) delta-root identity failed."];

Print["S12_STAGE: loading or constructing mapped Hqg Eq. (46) cache"];
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
  pdfBornDensities = AssociationMap[
    Function[projector,
      Together[
        xiS23Jacobian twoBodyNormalization/pdfSplittingVariable *
          If[projector === "PPP", pdfSplittingVariable^-2, 1] *
          bornM2[
            "Hqg", projector,
            pdfInternalKinematics["x"],
            pdfInternalKinematics["z"],
            pdfInternalKinematics["k1T2"]
          ]
      ]
    ],
    projectors
  ];
  ffBornDensities = AssociationMap[
    Function[channel,
      AssociationMap[
        Function[projector,
          Together[
            xiS23Jacobian twoBodyNormalization/ffSplittingVariable *
              bornM2[
                channel, projector,
                ffInternalKinematics["x"],
                ffInternalKinematics["z"],
                ffInternalKinematics["k1T2"]
              ]
          ]
        ],
        projectors
      ]
    ],
    {"Hqg", "Hqq"}
  ];
  pgqFFKernel = 2 FeynCalc`CF *
    (1 + (1 - ffSplittingVariable)^2)/ffSplittingVariable;
  mappedCountertermComponents = AssociationMap[
    Function[projector,
      <|
        "PDF_Hqg_Pqq" -> pqqPair[
          pdfBornDensities[projector],
          pdfSplittingVariable,
          pdfScale
        ],
        "FF_Hqg_Pgg" -> pggPair[
          ffBornDensities["Hqg", projector],
          ffSplittingVariable,
          ffScale
        ],
        "FF_Hqq_Pgq" -> regularKernelPair[
          pgqFFKernel,
          ffBornDensities["Hqq", projector],
          ffScale
        ]
      |>
    ],
    projectors
  ];
  mappedCountertermTotals = AssociationMap[
    pairAdd @@ Values[mappedCountertermComponents[#]] &,
    projectors
  ];
  mappedOrder0 = <||>;
  mappedOrder1 = <||>;
  Do[
    mappedOrder0[projector] = <||>;
    mappedOrder1[projector] = <||>;
    Do[
      Print[
        "S12_COUNTERTERM_SERIES: ", projector, " ", field,
        " leafCount=", LeafCount[mappedCountertermTotals[projector, field]]
      ];
      countertermCoefficients = singleTermSeriesCoefficients[
        mappedCountertermTotals[projector, field],
        {0, 1}, 1, 2 gibibyte
      ];
      If[countertermCoefficients === $Failed,
        fatal[projector <> " mapped counterterm " <> field <>
          " epsilon expansion failed."]
      ];
      mappedOrder0[projector, field] = countertermCoefficients[0];
      mappedOrder1[projector, field] = countertermCoefficients[1];
      Clear[countertermCoefficients];,
      {field, pairFields}
    ];,
    {projector, projectors}
  ];
  countertermPayload = <|
    "CacheVersion" -> cacheVersion,
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "S11SHA256" -> s11SHA256,
    "PaperSHA256" -> paperSHA256,
    "MappingResiduals" -> mappingResiduals,
    "Order0" -> mappedOrder0,
    "Order1" -> mappedOrder1,
    "Species" -> {"PDF_Hqg_Pqq", "FF_Hqg_Pgg", "FF_Hqq_Pgq"},
    "SplittingKernels" -> {"PqqPDF", "PggFF", "PgqFF"},
    "AppliedDirectBornNormalizationFactor" -> 9,
    "PhysicalLuminosityAppliedDownstream" ->
      "Sum_q e_q^2 f_q D_g",
    "PPPPDFProjectorRescaling" -> HoldForm[1/y^2],
    "PggDeltaCoefficient" -> HoldForm[
      (11 FeynCalc`CA - 4 FeynCalc`TF FeynCalc`Nf)/3
    ]
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
If[Lookup[countertermPayload, "ProgramSHA256", Missing["Absent"]] =!=
    programSHA256,
  reusedCountertermPayloadSHA256 = FileHash[
    countertermCachePath, "SHA256"
  ];
  countertermPayload = Join[
    countertermPayload,
    <|
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "ReusedPreS10V4PayloadSHA256" ->
        reusedCountertermPayloadSHA256,
      "ReuseReason" ->
        "mathematically bound only to unchanged S11 and paper inputs"
    |>
  ];
  atomicPut[countertermPayload, countertermCachePath];
  Print["S12_COUNTERTERM_REBOUND: current program provenance installed"];
  Clear[reusedCountertermPayloadSHA256]
];
assert[validCountertermCacheQ[
    countertermPayload, s11SHA256, paperSHA256
  ],
  "The mapped Hqg counterterm cache failed final validation."];
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
  "S12_STAGE: extracting S10 real Laurent coefficients serially with " <>
    "bounded per-term memory"
];
Do[
  processS10Projector[
    projector, s10SHA256, realPairCacheSHA256
  ],
  {projector, projectors}
];
If[newTermsThisKernelEpoch > 0,
  Print[
    "S12_MEMORY_EPOCH_PAUSE: completed projector checkpoint work; " <>
      "restart required before virtual conversion and pole reduction"
  ];
  Quit[75]
];

Print["S12_STAGE: loading or constructing converted virtual cache"];
virtualCoefficientCacheCreatedThisKernel = False;
virtualCoefficientPayload = If[
  FileExistsQ[virtualCoefficientCachePath],
  Quiet@Check[Get[virtualCoefficientCachePath], $Failed],
  Missing["Absent"]
];
If[! validVirtualCoefficientCacheQ[
    virtualCoefficientPayload,
    s10SHA256,
    s10VirtualLaurentCacheSHA256
  ],
  If[FileExistsQ[virtualCoefficientCachePath],
    Print[
      "S12_VIRTUAL_CACHE_INVALID: deleting ",
      virtualCoefficientCachePath
    ];
    DeleteFile[virtualCoefficientCachePath]
  ];
  Print["S12_STAGE: loading the 233 MB S10 evaluator Laurent cache"];
  sourceVirtualPayload = Quiet@Check[
    Get[s10VirtualLaurentCache],
    $Failed
  ];
  assert[
    AssociationQ[sourceVirtualPayload] &&
      sourceVirtualPayload["CacheVersion"] === 1 &&
      sourceVirtualPayload["StageVersion"] === "HqgS10-v3" &&
      sourceVirtualPayload["OrdersRetained"] === {-2, -1, 0} &&
      TrueQ[sourceVirtualPayload["RegulatorsUnifiedAfterUVCheck"]] &&
      AssociationQ[sourceVirtualPayload["LaurentThroughFinite"]] &&
      Sort[Keys[sourceVirtualPayload["LaurentThroughFinite"]]] ===
        Sort[projectors] &&
      feynCalcContextCleanQ[
        sourceVirtualPayload["LaurentThroughFinite"]
      ],
    "The source S10 virtual Laurent cache is invalid."
  ];
  virtualCoefficientDataRaw = AssociationMap[
    extractVirtualLaurentCoefficients[
      sourceVirtualPayload["LaurentThroughFinite", #], #
    ] &,
    projectors
  ];
  virtualCoefficientDataConverted = AssociationMap[
    applyVirtualConvention[virtualCoefficientDataRaw[#]] &,
    projectors
  ];
  Clear[sourceVirtualPayload, virtualCoefficientDataRaw];
  ClearSystemCache[];
  assert[
    FreeQ[
      virtualCoefficientDataConverted,
      epsilon | _SeriesData | $Failed | Indeterminate |
        ComplexInfinity | DirectedInfinity[_]
    ] && feynCalcContextCleanQ[virtualCoefficientDataConverted],
    "Converted virtual coefficients are invalid or context-contaminated."
  ];
  virtualCoefficientPayload = <|
    "CacheVersion" -> cacheVersion,
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "S10SHA256" -> s10SHA256,
    "SourceVirtualCache" -> s10VirtualLaurentCache,
    "SourceVirtualSHA256" -> s10VirtualLaurentCacheSHA256,
    "Conversion" -> HoldForm[
      (2 Pi/ScaleMu)^(2 epsilon) *
        (1 - epsilon FeynCalc`CA (1 + 24 I Pi)/(
          24 (FeynCalc`CA + 2 FeynCalc`CF)
        ))
    ],
    "Data" -> virtualCoefficientDataConverted
  |>;
  Clear[virtualCoefficientDataConverted];
  atomicPut[virtualCoefficientPayload, virtualCoefficientCachePath];
  virtualCoefficientCacheCreatedThisKernel = True;
  Print["S12_VIRTUAL_CHECKPOINT: converted virtual cache complete"],
  Print["S12_VIRTUAL_RESUME: validated converted virtual cache"]
];
If[
  Lookup[virtualCoefficientPayload, "ProgramSHA256", Missing["Absent"]] =!=
      programSHA256 ||
    Lookup[virtualCoefficientPayload, "S10SHA256", Missing["Absent"]] =!=
      s10SHA256,
  reusedVirtualPayloadSHA256 = FileHash[
    virtualCoefficientCachePath, "SHA256"
  ];
  virtualCoefficientPayload = Join[
    virtualCoefficientPayload,
    <|
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "S10SHA256" -> s10SHA256,
      "ReusedPreS10V4PayloadSHA256" -> reusedVirtualPayloadSHA256,
      "ReuseReason" ->
        "unchanged source virtual Laurent cache SHA256"
    |>
  ];
  atomicPut[virtualCoefficientPayload, virtualCoefficientCachePath];
  Print["S12_VIRTUAL_REBOUND: current S10 and program provenance installed"];
  Clear[reusedVirtualPayloadSHA256]
];
assert[validVirtualCoefficientCacheQ[
    virtualCoefficientPayload,
    s10SHA256,
    s10VirtualLaurentCacheSHA256
  ],
  "The converted virtual coefficient cache failed final validation."];
If[virtualCoefficientCacheCreatedThisKernel,
  Clear[virtualCoefficientPayload];
  ClearSystemCache[];
  Print[
    "S12_MEMORY_EPOCH_PAUSE: converted virtual cache created; " <>
      "restart required before pole reduction"
  ];
  Quit[75]
];
virtualCoefficientData = virtualCoefficientPayload["Data"];
Clear[virtualCoefficientPayload];
ClearSystemCache[];

If[FileExistsQ[residualDiagnosticPath],
  DeleteFile[residualDiagnosticPath]
];

Print["S12_STAGE: adding Eq. (46) and checking every pole component"];
poleResiduals = <||>;
Do[
  poleResiduals[projector] = <|"Minus2" -> <||>, "Minus1" -> <||>|>;
  Do[
    Do[
      Print[
        "S12_POLE_STAGE: projector=", projector,
        " order=", order,
        " field=", field
      ];
      realCoefficient = loadAggregateCoefficient[
        projector,
        field,
        If[order === "Minus2", -2, -1]
      ];
      virtualCoefficient = If[
        field === "Endpoint",
        virtualCoefficientData[
          projector,
          If[order === "Minus2", "Minus2", "Minus1"]
        ],
        0
      ];
      s10Coefficient = realCoefficient + virtualCoefficient;
      residualExpression = If[
        order === "Minus2",
        s10Coefficient,
        s10Coefficient + countertermPolePairs[projector, field]
      ];
      poleResiduals[projector, order, field] = zeroEquivalentResidual[
        residualExpression,
        projector <> " epsilon^-" <>
          If[order === "Minus2", "2 ", "1 "] <> field,
        <|
          "S10Real" -> realCoefficient,
          "S10VirtualPaperConvention" -> virtualCoefficient,
          "Eq46Counterterm" -> If[
            order === "Minus2",
            0,
            countertermPolePairs[projector, field]
          ]
        |>
      ];
      Clear[
        realCoefficient, virtualCoefficient, s10Coefficient,
        residualExpression
      ];
      ClearSystemCache[];,
      {field, pairFields}
    ];,
    {order, {"Minus2", "Minus1"}}
  ];,
  {projector, projectors}
];

assert[
  And @@ Flatten@Table[
    TrueQ[poleResiduals[projector, order, field] === 0],
    {projector, projectors},
    {order, {"Minus2", "Minus1"}},
    {field, pairFields}
  ],
  "At least one Hqg S12 pole component did not cancel."
];

physicalHermitianEndpointProjection[pair_Association] := Join[
  pair,
  <|"Endpoint" -> Re[pair["Endpoint"]]|>
];

Print["S12_STAGE: constructing finite Hqg coefficient pairs"];
finitePairs = <||>;
finiteHardFunctions = <||>;
Do[
  finitePairs[projector] = <||>;
  Do[
    realFiniteCoefficient = loadAggregateCoefficient[
      projector, field, 0
    ];
    virtualFiniteCoefficient = If[
      field === "Endpoint",
      virtualCoefficientData[projector, "Finite"],
      0
    ];
    finitePairs[projector, field] =
      (realFiniteCoefficient + virtualFiniteCoefficient +
          countertermFinitePairs[projector, field]) /.
        qcdAndConstantRules;
    Clear[realFiniteCoefficient, virtualFiniteCoefficient];,
    {field, pairFields}
  ];
  Print[
    "S12_STAGE: applying physical Hermitian endpoint projection to ",
    projector
  ];
  finitePairs[projector] =
    physicalHermitianEndpointProjection[finitePairs[projector]];
  finiteHardFunctions[projector] = pairToAction[
    finitePairs[projector], projector
  ];
  ClearSystemCache[];,
  {projector, projectors}
];
Clear[virtualCoefficientData];
ClearSystemCache[];

assert[
  AllTrue[
    projectors,
    ! FreeQ[finitePairs[#, "Endpoint"], _Re] &
  ],
  "The finite Hqg endpoints do not retain the physical Re projection."
];

forbiddenFinalObjects =
  epsilon | _SeriesData | S11SEpsilon | _S11ConvolutionTest |
    _S11PlusDistribution | DiracDelta[s23] |
    _S09EndpointValue | _S09PlusDistribution;

projectorTermCounts = AssociationMap[
  Function[projector,
    completionPayload = Quiet@Check[
      Get[projectorCompletePath[projector]],
      $Failed
    ];
    assert[AssociationQ[completionPayload] &&
        AssociationQ[completionPayload["FieldTermCounts"]],
      projector <> " completion marker lacks field term counts."];
    counts = completionPayload["FieldTermCounts"];
    Clear[completionPayload];
    counts
  ],
  projectors
];

s12Checks = <|
  "CurrentS10AndS11ArtifactsValidated" -> True,
  "S10PhysicalBranchCoupledEndpointRepairValidated" -> True,
  "AuthoritativePaperAndBigTMDChannel3ABound" -> True,
  "FeynCalcInitializedBeforeAllArtifactImports" -> True,
  "MonolithicS10ResultLoadExcluded" -> True,
  "ProjectedS10ByteScanUsesFixedMemoryChunks" -> True,
  "CompactS10RealPairCacheSourceBound" -> True,
  "NoWholeExpressionSeriesOnLargeS10Actions" -> True,
  "BoundedSerialPerTermLaurentExtraction" -> True,
  "DiskBackedPerTermAndAggregateResumeEnabled" -> True,
  "PreS10V4TermReuseRequiresExactCorrectedTermHash" -> True,
  "IndependentCountertermAndVirtualCachesReboundToCurrentSources" -> True,
  "AtomicCheckpointAndResultWritesEnabled" -> True,
  "FreshKernelMemoryEpochsEnabled" -> True,
  "ExactlyThreeMappedHqgComponents" -> True,
  "PDFContainsOnlyHqgPqq" -> True,
  "FFContainsHqgPggAndHqqPgq" -> True,
  "NoPqgOrHggBornContribution" -> True,
  "DirectBornNormalizationFactorIsNine" -> True,
  "PhysicalLuminosityDeferred" -> True,
  "PhysicalS08MapRebuilt" -> True,
  "AllMappedBornDeltaRootsValidated" ->
    AllTrue[Values[mappingResiduals], TrueQ[# === 0] &],
  "PPPPDFOneOverYSquaredApplied" -> True,
  "PggNfDependenceRetained" ->
    AllTrue[
      projectors,
      ! FreeQ[countertermPolePairs[#, "Endpoint"], FeynCalc`Nf] &
    ],
  "PositiveEq46SignApplied" -> True,
  "PaperSEpsilonExpandedThroughFiniteOrder" -> True,
  "StandardQCDTFHalfApplied" -> True,
  "PackageXToPaperVirtualConversionAppliedExactlyOnce" -> True,
  "PgDoublePoleCancels" ->
    AllTrue[Values[poleResiduals["Pg", "Minus2"]], TrueQ[# === 0] &],
  "PgSimplePoleCancels" ->
    AllTrue[Values[poleResiduals["Pg", "Minus1"]], TrueQ[# === 0] &],
  "PPPDoublePoleCancels" ->
    AllTrue[Values[poleResiduals["PPP", "Minus2"]], TrueQ[# === 0] &],
  "PPPSimplePoleCancels" ->
    AllTrue[Values[poleResiduals["PPP", "Minus1"]], TrueQ[# === 0] &],
  "PhysicalHermitianFiniteEndpointProjectionApplied" ->
    AllTrue[projectors, ! FreeQ[finitePairs[#, "Endpoint"], _Re] &],
  "FiniteFunctionsContainNoEpsilonOrDistributionPlaceholder" ->
    AllTrue[Values[finiteHardFunctions], FreeQ[#, forbiddenFinalObjects] &],
  "FiniteFunctionsRetainOrdinaryS23Integral" ->
    AllTrue[
      Values[finiteHardFunctions],
      ! FreeQ[#, Inactive[Integrate][___]] &
    ],
  "FiniteFunctionsRetainArbitrarySymbolicTest" ->
    AllTrue[Values[finiteHardFunctions], ! FreeQ[#, _S10ConvolutionTest] &],
  "NoAccidentalGlobalFeynCalcSymbols" ->
    feynCalcContextCleanQ[{
      countertermPolePairs,
      countertermFinitePairs,
      finiteHardFunctions
    }],
  "CalculationFullySymbolicAndExact" ->
    FreeQ[finiteHardFunctions, _Real]
|>;

assert[AllTrue[Values[s12Checks], TrueQ],
  "At least one final Hqg S12 validation check is not True."];

s12Result = <|
  "Status" -> "CompleteFiniteFactorizedHqg",
  "Stage" -> stageVersion,
  "StageVersion" -> stageVersion,
  "Channel" -> "Hqg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResults" -> <|
    "UVRenormalizedRealVirtual" -> s10Path,
    "UVRenormalizedRealVirtualSHA256" -> s10SHA256,
    "S10VirtualLaurentCache" -> s10VirtualLaurentCache,
    "S10VirtualLaurentCacheSHA256" -> s10VirtualLaurentCacheSHA256,
    "CollinearCounterterms" -> s11Path,
    "CollinearCountertermsSHA256" -> s11SHA256,
    "AuthoritativePaper" -> paperPath,
    "AuthoritativePaperSHA256" -> paperSHA256
  |>,
  "PaperReference" -> <|
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "PrintedSplittingFunctions" -> "Eqs. (51)-(53)",
    "PggStatus" ->
      "standard one-loop Pgg in the same alpha_s/(4 Pi) normalization",
    "VirtualLoopAndHermitianConvention" ->
      "Appendix E Eqs. (E1) and (E7)"
  |>,
  "BigTMDConvention" -> <|
    "ChannelNumber" -> 3,
    "ChargeCase" -> "A only",
    "FragmentingParton" -> "gluon g(k1)",
    "ProjectorMapping" -> <|
      "Pg" -> "NLO.Pg.fchn3A",
      "PPP" -> "NLO.Ppp.fchn3A"
    |>,
    "ReferenceFiles" -> <|
      "Pg" -> bigTMDPgPath,
      "PPP" -> bigTMDPPPPath
    |>,
    "ReferenceSHA256" -> bigTMDReferenceSHA256,
    "ComparisonBoundary" ->
      "finite factorized projector actions saved here; Eq. (9) F-hat construction and direct BigTMD comparison remain S13"
  |>,
  "PhysicalMap" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "XHat" -> xHatXi,
    "Zeta" -> zetaXiS23,
    "ZHat" -> zHatXiS23,
    "PartonicTransverseMomentumSquared" -> k1TPartonic2XiS23,
    "Jacobian" -> xiS23Jacobian,
    "PDFSplittingVariable" -> pdfSplittingVariable,
    "FFSplittingVariable" -> ffSplittingVariable,
    "Residuals" -> mappingResiduals
  |>,
  "SpeciesRouting" -> <|
    "PDF" -> {"Hqg x Pqq"},
    "FF" -> {"Hqg x Pgg", "Hqq x Pgq"},
    "VanishingLOSpecies" -> {"Hgg"},
    "AppliedDirectBornNormalizationFactor" -> 9,
    "PhysicalLuminosityAppliedDownstream" ->
      "Sum_q e_q^2 f_q D_g"
  |>,
  "FactorizationConvention" -> <|
    "Sign" ->
      "positive Eq. (46) counterterms added to the UV-renormalized unsubtracted S10 action",
    "LoopFactor" -> HoldForm[
      alphaS/(4 Pi) == FeynCalc`SMP["g_s"]^2/(16 Pi^2)
    ],
    "SEpsilonThroughRequiredOrder" -> HoldForm[
      S11SEpsilon ==
        1 + epsilon (Log[4 Pi] - EulerGamma) + O[epsilon]^2
    ],
    "ColorNormalization" -> HoldForm[FeynCalc`TF == 1/2],
    "Pgg" -> HoldForm[
      Pgg[y] == 4 FeynCalc`CA (
        S11PlusDistribution[1/(1 - y), {y, 0, 1}] +
          1/y - 2 + y (1 - y)
      ) + (11 FeynCalc`CA - 4 FeynCalc`TF FeynCalc`Nf) *
          DiracDelta[1 - y]/3
    ],
    "EvaluatorToPaperVirtualConversion" -> HoldForm[
      (2 Pi/ScaleMu)^(2 epsilon) *
        (1 - epsilon FeynCalc`CA (1 + 24 I Pi)/(
          24 (FeynCalc`CA + 2 FeynCalc`CF)
        ))
    ],
    "HermitianFiniteProjection" -> HoldForm[
      EndpointFinitePhysical == Re[EndpointFiniteAfterEq46]
    ]
  |>,
  "S12Caches" -> <|
    "CompactS10RealPairs" -> realPairCachePath,
    "MappedCounterterms" -> countertermCachePath,
    "RealLaurentTermParts" -> partCacheRoot,
    "RealLaurentAggregates" -> aggregateCacheRoot,
    "ConvertedVirtualCoefficients" -> virtualCoefficientCachePath,
    "ProgramSHA256" -> programSHA256,
    "S10SHA256" -> s10SHA256,
    "S11SHA256" -> s11SHA256
  |>,
  "RealSourceTermCountsByProjector" -> projectorTermCounts,
  "MappedCountertermLaurentPairs" -> <|
    "Pole" -> countertermPolePairs,
    "Finite" -> countertermFinitePairs
  |>,
  "PoleResiduals" -> poleResiduals,
  "FiniteCoefficientPairsByProjector" -> finitePairs,
  "FiniteHattedHardFunctionsByProjector" -> finiteHardFunctions,
  "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s23=0 and independent of epsilon",
  "Checks" -> s12Checks,
  "MemoryStrategy" ->
    "fixed-memory projected S10 metadata/real-action/tail load; compact real-pair checkpoint; pre-S10-v4 term parts reused only after exact corrected term-hash and fixed old-provenance checks, with changed parts deleted; serial exact source-term Laurent checkpoints; sixteen new terms per fresh Engine epoch; counterterm and converted-virtual caches rebound only to unchanged mathematical sources; no whole-action Series",
  "NotPerformedAtThisStage" -> {
    "outer xi convolution with a concrete quark PDF or gluon fragmentation function",
    "physical Sum_q e_q^2 flavor luminosity multiplication",
    "Eq. (9) F1Hat/F2Hat construction reserved for S13",
    "direct numerical BigTMD fchn3A comparison reserved for S13",
    "numerical kinematics, PDFs, or fragmentation functions"
  }
|>;

Print["S12_STAGE: writing finite factorized Hqg result"];
atomicPut[s12Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "The final Hqg S12 result was not written."];
Print["S12_SUCCESS_FINITE_FACTORIZED_HQG"];
Print["S12_RESULT_PATH=", resultPath];
Print["S12_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S12_POLE_RESIDUALS=", InputForm[poleResiduals]];
Print["S12_CHECKS=", InputForm[s12Checks]];

Quit[0];

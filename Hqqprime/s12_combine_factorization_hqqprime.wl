(* ::Package:: *)

(*
  Hqqprime S12: align the accepted charge-resolved S10 real actions with the
  accepted S11 Eq. (46) PDF/FF counterterms, prove every Laurent pole field
  cancels, and save the exact finite factorized actions.  Paper Eq. (9),
  F-hats, physical ordered-flavour assembly, and external comparison remain
  downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll["Global`*"];

activeTemporaryPath = "";
workerVersions = {};
parallelOrderProbe = {};
launchedKernelCount = 0;

closeS12Kernels[] := Module[{},
  If[Length[Kernels[]] > 0, Quiet[CloseKernels[]]]
];

fatal[message_String] := (
  closeS12Kernels[];
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S12_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

workerRequire[condition_, payload_] :=
  If[! TrueQ[condition], Throw[payload, "S12WorkerFailure"]];

SetAttributes[messageFreeEvaluate, HoldFirst];
messageFreeEvaluate[expression_] := Module[{value, messages},
  Block[{$MessageList = {}},
    value = Quiet@Check[expression, $Failed];
    messages = $MessageList;
  ];
  If[value === $Failed || messages =!= {}, $Failed, value]
];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

allBranchValues[association_Association] :=
  Flatten[Map[Values, Values[association]], 1];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s10SourcePath = FileNameJoin[{
  scriptDirectory, "s10_resolve_endpoints_hqqprime.wl"
}];
s10ResultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
s11SourcePath = FileNameJoin[{
  scriptDirectory, "s11_calculate_collinear_counterterms_hqqprime.wl"
}];
s11ResultPath = FileNameJoin[{scriptDirectory, "s11_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s12_result"}];
diagnosticPath = FileNameJoin[{
  scriptDirectory, "s12_last_nonzero_residual"
}];

stageVersion = "HqqprimeS12-v1";
cacheStageVersion = "HqqprimeS12Cache-v1";
resultSchemaVersion = 1;
projectorKeys = {"Pg", "PPP"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
laurentPowers = {-2, -1, 0};

parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 7 2^29;
countertermMemoryBudgetBytes = 2 2^30;
seriesTimeoutSeconds = 2400;
residualTimeoutSeconds = 1800;
preflightOnly = TrueQ[
  Quiet@Check[Environment["HQQPRIME_S12_PREFLIGHT_ONLY"], ""] === "1"
];

expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS10SourceSHA256 =
  "9ec4991d19fc5e61bc79ecb35f90062d15e8b2cd427ede637ed596519f05e988";
expectedS10ResultSHA256 =
  "1ce9ef022312ff333b2dc949a858a5883380106c63742fada970f5ebc0d12c25";
expectedS11SourceSHA256 =
  "86725c6c85baf15f1d209e98a06ab7a7c7f28ffe4ec4fcb4efe59e77a3eafd03";
expectedS11ResultSHA256 =
  "0c58e67a9d108de830768d5b04d4078fd6fd0265abdd03a54a2a1dec0b2c186b";

expectedS10CacheSHA256 = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "c89636c1233f201751231f7f41b5948aee4c217bc8daea936569c0e328870cae",
    "PrimeChargeSquared" ->
      "971a9a7aa07f496f64fc6c5f8b333d156bfbf27ebeadc8d88297a4b11c85452f",
    "MixedIncomingPrimeCharge" ->
      "a1de00773858b02a79e0952183769f85a4678114fc6af9859e15302df412d8bb"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "29135863a484eeae754f54750635916e9908e6582dc4ae5cbca6d5414f2f2346",
    "PrimeChargeSquared" ->
      "80d2704635b95253c41c31468d4df41b7832081c15780c32e50a11197e8cbe9a",
    "MixedIncomingPrimeCharge" ->
      "714352bcd6a33806222f6706c3f7731aca03d98221e1a935f9669b0c717ad21c"
  |>
|>;

chargeFileTokens = <|
  "IncomingChargeSquared" -> "incoming_charge_squared",
  "PrimeChargeSquared" -> "prime_charge_squared",
  "MixedIncomingPrimeCharge" -> "mixed_incoming_prime_charge"
|>;

s12CachePaths = AssociationMap[
  Function[projector,
    AssociationMap[
      Function[chargeKey,
        FileNameJoin[{
          scriptDirectory,
          "s12_cache_hqqprime_" <> chargeFileTokens[chargeKey] <> "_" <>
            ToLowerCase[projector]
        }]
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];

programSHA256 = fileSHA256[programPath];

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

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeSucceeded, temporaryReload, renameResult},
  assert[
    ! FileExistsQ[finalPath],
    "Refusing to overwrite finalized artifact " <> finalPath <> "."
  ];
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "Process-specific temporary path already exists: " <>
      activeTemporaryPath
  ];
  writeSucceeded = Quiet@Check[
    Put[expression, activeTemporaryPath];
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    False
  ];
  assert[
    writeSucceeded,
    "Atomic temporary write failed for " <> finalPath <> "."
  ];
  temporaryReload = Quiet@Check[Get[activeTemporaryPath], $Failed];
  assert[
    AssociationQ[temporaryReload] &&
      Lookup[temporaryReload, "Status", Missing["Absent"]] === "Complete" &&
      Lookup[temporaryReload, "Stage", Missing["Absent"]] === expectedStage &&
      TrueQ[temporaryReload === expression],
    "Exact temporary reload failed for " <> finalPath <> "."
  ];
  renameResult = Quiet@Check[
    RenameFile[activeTemporaryPath, finalPath],
    $Failed
  ];
  assert[
    renameResult =!= $Failed,
    "Atomic rename failed for " <> finalPath <> "."
  ];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Finalized artifact is absent or empty: " <> finalPath <> "."
  ];
  temporaryReload
];

Print["S12_STAGE: deriving exact SU(N) canonicalization with FeynCalc"];
colorTraceNormalization = messageFreeEvaluate[
  FeynCalc`SUNSimplify[
    FeynCalc`SUNTrace[FeynCalc`SUNT[s12AdjointA, s12AdjointB]],
    TimeConstrained -> Infinity,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0
  ]
];
colorDelta = FeynCalc`SUNDelta[
  FeynCalc`SUNIndex[s12AdjointA],
  FeynCalc`SUNIndex[s12AdjointB]
];
toolDerivedTF = colorTraceNormalization /. colorDelta -> 1;
toolDerivedCFInSUNN = messageFreeEvaluate[
  FeynCalc`SUNSimplify[
    FeynCalc`CF,
    TimeConstrained -> Infinity,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0
  ]
];
toolDerivedCA = messageFreeEvaluate[
  FeynCalc`SUNSimplify[
    FeynCalc`SUNN,
    TimeConstrained -> Infinity,
    FeynCalc`SUNNToCACF -> True,
    FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0
  ]
];
toolDerivedCFInCA = toolDerivedCFInSUNN /.
  FeynCalc`SUNN -> toolDerivedCA;
assert[
  colorTraceNormalization =!= $Failed &&
    TrueQ[colorTraceNormalization === toolDerivedTF colorDelta] &&
    toolDerivedCFInSUNN =!= $Failed && toolDerivedCA =!= $Failed &&
    TrueQ[toolDerivedCA === FeynCalc`CA] &&
    FreeQ[{toolDerivedTF, toolDerivedCFInCA},
      FeynCalc`SUNN | FeynCalc`CF | FeynCalc`TF | _Real],
  "FeynCalc did not derive the required exact SU(N) conversion data."
];

toolDerivedPolyGammaHalf = messageFreeEvaluate[
  FunctionExpand[PolyGamma[0, 1/2]]
];
assert[
  toolDerivedPolyGammaHalf =!= $Failed &&
    FreeQ[toolDerivedPolyGammaHalf, PolyGamma | _Real],
  "Wolfram did not derive the exact half-integer PolyGamma value."
];
toolDerivedPowerOfTwoLogRules = Table[
  With[{integer = 2^power}, Log[integer] -> power Log[2]],
  {power, 2, 4}
];

canonicalizeForCombination[expression_] :=
  ((((expression /.
      S11SEpsilon -> (4 Pi)^epsilon/Gamma[1 - epsilon]) /. {
        FeynCalc`TF -> toolDerivedTF,
        FeynCalc`CF -> toolDerivedCFInCA,
        FeynCalc`SUNN -> toolDerivedCA
      }) /. PolyGamma[0, 1/2] -> toolDerivedPolyGammaHalf) /.
    toolDerivedPowerOfTwoLogRules);

colorRegressionResidual = canonicalizeForCombination[
  FeynCalc`SUNN - FeynCalc`CA
];
assert[
  TrueQ[colorRegressionResidual === 0],
  "The exact SUNN-to-CA combination regression failed."
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
    partSeries = messageFreeEvaluate[
      TimeConstrained[
        Series[part, {epsilon, 0, maximum}],
        seriesTimeoutSeconds,
        $Failed
      ]
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

factorwiseSeriesCoefficients[
    expression_, powers_List, maximum_Integer
  ] := Module[
  {
    canonicalExpression, factors, regularFactor, dependentFactors,
    pilotData, factorMinima, totalMinimum, requiredMaxima, factorData,
    productCoefficients, coefficients
  },
  canonicalExpression = canonicalizeForCombination[expression];
  If[TrueQ[canonicalExpression === 0],
    Return[AssociationMap[0 &, powers]]
  ];
  If[Count[canonicalExpression, _Piecewise, Infinity] =!= 0,
    Return[$Failed]
  ];
  If[FreeQ[canonicalExpression, epsilon],
    Return[
      AssociationMap[
        If[# === 0, canonicalExpression, 0] &,
        powers
      ]
    ]
  ];
  factors = If[
    Head[canonicalExpression] === Times,
    List @@ canonicalExpression,
    {canonicalExpression}
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
  coefficients = AssociationMap[
    canonicalizeForCombination[
      regularFactor Lookup[productCoefficients, #, 0]
    ] &,
    powers
  ];
  If[
    ! FreeQ[
      coefficients,
      epsilon | _SeriesData | S11SEpsilon | $Failed | Indeterminate |
        ComplexInfinity | DirectedInfinity[_] | Power[0, _?Negative] |
        _Real
    ] || ! feynCalcContextCleanQ[coefficients],
    Return[$Failed]
  ];
  coefficients
];

boundedFactorwiseSeriesCoefficients[
    expression_, powers_List, maximum_Integer, memoryLimit_Integer
  ] := Module[{answer},
  answer = messageFreeEvaluate[
    MemoryConstrained[
      TimeConstrained[
        factorwiseSeriesCoefficients[expression, powers, maximum],
        seriesTimeoutSeconds,
        $Failed
      ],
      memoryLimit,
      $Failed
    ]
  ];
  If[
    answer === $Failed || ! AssociationQ[answer] ||
      Sort[Keys[answer]] =!= Sort[powers],
    $Failed,
    answer
  ]
];

zeroPair[] := <|
  "Endpoint" -> 0,
  "IntegrandPhiS" -> 0,
  "IntegrandPhi0" -> 0
|>;

pairAdd[left_Association, right_Association] := AssociationMap[
  canonicalizeForCombination[Lookup[left, #, 0] + Lookup[right, #, 0]] &,
  pairFields
];

pairToAction[
    pair_Association, projector_String, chargeKey_String
  ] := pair["Endpoint"] S10ConvolutionTest[projector, chargeKey, 0] +
  Inactive[Integrate][
    pair["IntegrandPhiS"] *
        S10ConvolutionTest[projector, chargeKey, s23] +
      pair["IntegrandPhi0"] *
        S10ConvolutionTest[projector, chargeKey, 0],
    {s23, 0, s23UpperB}
  ];

Print["S12_STAGE: validating exact paper, S10, S11, and cache bindings"];
assert[
  And @@ (FileExistsQ /@ {
    paperPath, s10SourcePath, s10ResultPath, s11SourcePath, s11ResultPath
  }),
  "At least one required accepted input artifact is absent."
];
assert[
  fileSHA256[paperPath] === expectedPaperSHA256 &&
    fileSHA256[s10SourcePath] === expectedS10SourceSHA256 &&
    fileSHA256[s10ResultPath] === expectedS10ResultSHA256 &&
    fileSHA256[s11SourcePath] === expectedS11SourceSHA256 &&
    fileSHA256[s11ResultPath] === expectedS11ResultSHA256,
  "A paper, S10, or S11 accepted artifact hash changed."
];
If[preflightOnly,
  assert[
    ! FileExistsQ[resultPath] &&
      And @@ (! FileExistsQ[#] & /@ allBranchValues[s12CachePaths]) &&
      ! FileExistsQ[diagnosticPath],
    "The no-write preflight requires an empty S12 result/cache/diagnostic inventory."
  ],
  assert[
    ! FileExistsQ[resultPath],
    "Refusing to overwrite an existing finalized s12_result."
  ]
];

s10 = Quiet@Check[Get[s10ResultPath], $Failed];
s11 = Quiet@Check[Get[s11ResultPath], $Failed];
assert[
  AssociationQ[s10] && s10["Status"] === "Complete" &&
    s10["Stage"] === "HqqprimeS10-v1" &&
    s10["ResultSchemaVersion"] === 1 &&
    s10["Channel"] === "Hqqprime only" &&
    s10["ProgramSHA256"] === expectedS10SourceSHA256 &&
    s10["PaperReference"]["SHA256"] === expectedPaperSHA256 &&
    s10["ProjectorOrder"] === projectorKeys &&
    s10["ChargeKeyOrder"] === chargeKeys &&
    Length[s10["Checks"]] === 32 &&
    And @@ (TrueQ /@ Values[s10["Checks"]]),
  "The accepted S10 result failed identity, schema, order, or check gates."
];
assert[
  AssociationQ[s11] && s11["Status"] === "Complete" &&
    s11["Stage"] === "HqqprimeS11-v1" &&
    s11["ResultSchemaVersion"] === 1 &&
    s11["Channel"] === "Hqqprime only" &&
    s11["ProgramSHA256"] === expectedS11SourceSHA256 &&
    s11["PaperReference"]["SHA256"] === expectedPaperSHA256 &&
    s11["ProjectorOrder"] === projectorKeys &&
    s11["ChargeKeyOrder"] === chargeKeys &&
    Length[s11["Checks"]] === 37 &&
    And @@ (TrueQ /@ Values[s11["Checks"]]),
  "The accepted S11 result failed identity, schema, order, or check gates."
];

s10CachePaths = s10["CacheProvenance"]["EndpointCachePaths"];
assert[
  Keys[s10CachePaths] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[s10CachePaths]) &&
    s10["CacheProvenance"]["EndpointCacheSHA256"] ===
      expectedS10CacheSHA256 &&
    s11["InputProvenance"]["S10SourceSHA256"] ===
      expectedS10SourceSHA256 &&
    s11["InputProvenance"]["S10ResultSHA256"] ===
      expectedS10ResultSHA256 &&
    s11["InputProvenance"]["S10EndpointCachePaths"] === s10CachePaths &&
    s11["InputProvenance"]["S10EndpointCacheSHA256"] ===
      expectedS10CacheSHA256,
  "The S10/S11 cache-provenance handoff is incomplete or changed."
];
Do[
  assert[
    FileExistsQ[s10CachePaths[projector][chargeKey]] &&
      fileSHA256[s10CachePaths[projector][chargeKey]] ===
        expectedS10CacheSHA256[projector][chargeKey],
    "An accepted S10 endpoint cache changed for " <> projector <> "/" <>
      chargeKey <> "."
  ];,
  {projector, projectorKeys},
  {chargeKey, chargeKeys}
];

acceptedScaleBookkeeping = s10["Bookkeeping"]["Scale"];
acceptedChargeBookkeeping = s10["Bookkeeping"]["Charge"];
acceptedSymmetryBookkeeping = s10["Bookkeeping"]["Symmetry"];
acceptedVirtualBookkeeping =
  s10["Bookkeeping"]["VirtualContributionAtThisOrder"];
assert[
  s10["Bookkeeping"]["AdditionalMultiplicativeWeightAtS10"] === 1 &&
    acceptedScaleBookkeeping["AbsoluteFactor"] ===
      FeynCalc`ScaleMu^(4 epsilon) &&
    acceptedScaleBookkeeping["AbsoluteExponent"] === 4 epsilon &&
    acceptedScaleBookkeeping["SeparateMSBarSEpsilonApplied"] === False &&
    acceptedChargeBookkeeping["SeparatedTensorKeys"] === chargeKeys &&
    acceptedChargeBookkeeping["CoefficientTensorsRemainChargeFree"] ===
      True &&
    acceptedSymmetryBookkeeping["FinalStateSymmetryFactor"] === 1 &&
    acceptedSymmetryBookkeeping[
      "NoDownstreamNontrivialSymmetryFactorRemains"
    ] === True &&
    acceptedVirtualBookkeeping["Applicable"] === False &&
    acceptedVirtualBookkeeping["Interference"] === 0 &&
    s10["Bookkeeping"][
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS10"
    ] === False &&
    s10["Bookkeeping"]["SeparateMSBarSEpsilonAppliedAtS10"] === False &&
    s10["Bookkeeping"]["NontrivialSymmetryFactorAppliedAtS10"] === False,
  "The accepted S10 scale, charge, symmetry, virtual, or assembly ledger changed."
];
assert[
  s11["Bookkeeping"]["AdditionalMultiplicativeWeightAtS11"] === 1 &&
    s11["Bookkeeping"]["Charge"]["SeparatedTensorKeys"] === chargeKeys &&
    s11["Bookkeeping"]["Charge"][
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS11"
    ] === False &&
    s11["Bookkeeping"]["Scale"]["BornHardPartAbsoluteFactor"] ===
      FeynCalc`ScaleMu^(2 epsilon) &&
    s11["Bookkeeping"]["Scale"][
      "PartonicPDForFFAdditionalMuEpsilon"
    ] === 0 &&
    s11["Bookkeeping"]["Symmetry"][
      "FinalStateFactorInheritedFromS10"
    ] === 1 &&
    s11["Bookkeeping"]["Symmetry"][
      "NontrivialSymmetryFactorAppliedAtS11"
    ] === False &&
    s11["Bookkeeping"]["VirtualContributionAtThisOrder"] ===
      acceptedVirtualBookkeeping &&
    s11["Bookkeeping"]["S10CombinationPerformed"] === False,
  "The accepted S11 scale, charge, symmetry, virtual, or assembly ledger changed."
];
assert[
  s11["SpeciesRouting"]["ChargeKeySupport"] === <|
    "IncomingChargeSquared" -> <|"PDF" -> 0, "FF" -> 1|>,
    "PrimeChargeSquared" -> <|"PDF" -> 1, "FF" -> 0|>,
    "MixedIncomingPrimeCharge" -> <|"PDF" -> 0, "FF" -> 0|>
  |> &&
    s11["NonzeroCountertermComponentCount"] === 4 &&
    s11["StructuralZeroTotalCount"] === 2,
  "The accepted S11 charge routing or structural-zero inventory changed."
];

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
assert[
  And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "At least one physical-map or Eq. (46) Born-shell identity failed."
];

convolutionMappings = s11["ConvolutionMappings"];
twoBodyNormalization = convolutionMappings["TwoBodyNormalization"];
assert[
  convolutionMappings["EndpointVariable"] === s11S23 &&
    TrueQ[twoBodyNormalization === Together[2 Pi (2 Pi)^(-4)]] &&
    convolutionMappings[
      "PPPFinalStateAdditionalProjectorConversion"
    ] === 1 &&
    And @@ (TrueQ /@ Values[convolutionMappings["Checks"]]),
  "The saved S11 convolution mapping or normalization changed."
];

bornProjected = s11["BornProjectedSquaredAmplitudes"];
countertermComponents = s11["CountertermComponents"];
countertermTotals = s11["CountertermsByProjectorCharge"];
assert[
  Keys[bornProjected] === {"Hqg", "HgqPrime"} &&
    Keys[countertermComponents] === projectorKeys &&
    Keys[countertermTotals] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[countertermComponents]) &&
    And @@ (Keys[#] === chargeKeys & /@ Values[countertermTotals]),
  "The saved S11 Born or counterterm Association shape changed."
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

mapSavedCountertermDensity[
    counterterm_, projector_String, chargeKey_String
  ] := Module[
  {integrals, integral, body, outside, tests, density},
  If[TrueQ[counterterm === 0], Return[0]];
  integrals = Cases[
    counterterm,
    HoldPattern[Inactive[Integrate][_, {s11S23, 0, _}]],
    {0, Infinity}
  ];
  assert[
    Length[integrals] === 1,
    projector <> "/" <> chargeKey <>
      " does not contain exactly one saved S11 integral."
  ];
  integral = First[integrals];
  assert[
    TrueQ[
      Together[
        integral[[2, 3]] - convolutionMappings["EndpointUpper"]
      ] === 0
    ],
    projector <> "/" <> chargeKey <>
      " has an unexpected abstract S11 upper limit."
  ];
  tests = DeleteDuplicates@Cases[
    counterterm,
    test_S11ConvolutionTest :> HoldComplete[test],
    Infinity
  ];
  assert[
    tests === {
      HoldComplete[
        S11ConvolutionTest[projector, chargeKey, s11S23]
      ]
    },
    projector <> "/" <> chargeKey <>
      " contains an unexpected S11 test function."
  ];
  outside = counterterm /.
    HoldPattern[Inactive[Integrate][_, _]] :> 1;
  body = integral[[1]];
  density = Together[
    body/S11ConvolutionTest[projector, chargeKey, s11S23]
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
  FeynCalc`SMP["g_s"]^2 S11SEpsilon/(16 Pi^2 epsilon);
rebuiltPDFByProjector = AssociationMap[
  Function[projector,
    Together[
      factorizationPrefactor *
        (2 FeynCalc`CF (
          1 + (1 - pdfSplittingVariable)^2
        )/pdfSplittingVariable) *
        (xiS23Jacobian twoBodyNormalization/pdfSplittingVariable) *
        If[projector === "PPP", pdfSplittingVariable^-2, 1] *
        bornM2[
          "HgqPrime",
          projector,
          pdfInternalKinematics["x"],
          pdfInternalKinematics["z"],
          pdfInternalKinematics["k1T2"]
        ]/pdfScale
    ]
  ],
  projectorKeys
];
rebuiltFFByProjector = AssociationMap[
  Function[projector,
    Together[
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
    ]
  ],
  projectorKeys
];

Print["S12_STAGE: mapping and independently rebuilding Eq. (46) branches"];
countertermEquivalenceResiduals = <||>;
mappedCountertermPolePairs = <||>;
mappedCountertermFinitePairs = <||>;
mappedCountertermSHA256 = <||>;
Do[
  countertermEquivalenceResiduals[projector] = <||>;
  mappedCountertermPolePairs[projector] = <||>;
  mappedCountertermFinitePairs[projector] = <||>;
  mappedCountertermSHA256[projector] = <||>;
  Do[
    directPDF = mapSavedCountertermDensity[
      countertermComponents[projector][chargeKey]["PDF"],
      projector,
      chargeKey
    ];
    directFF = mapSavedCountertermDensity[
      countertermComponents[projector][chargeKey]["FF"],
      projector,
      chargeKey
    ];
    expectedRebuiltPDF = If[
      chargeKey === "PrimeChargeSquared",
      rebuiltPDFByProjector[projector],
      0
    ];
    expectedRebuiltFF = If[
      chargeKey === "IncomingChargeSquared",
      rebuiltFFByProjector[projector],
      0
    ];
    countertermEquivalenceResiduals[projector, chargeKey] = <|
      "PDF" -> Together[directPDF - expectedRebuiltPDF],
      "FF" -> Together[directFF - expectedRebuiltFF],
      "SavedTotal" -> Together[
        directPDF + directFF -
          mapSavedCountertermDensity[
            countertermTotals[projector][chargeKey],
            projector,
            chargeKey
          ]
      ]
    |>;
    assert[
      And @@ (
        TrueQ[# === 0] & /@
          Values[countertermEquivalenceResiduals[projector][chargeKey]]
      ),
      projector <> "/" <> chargeKey <>
        " direct and independently rebuilt Eq. (46) densities differ."
    ];
    mappedCounterterm = directPDF + directFF;
    If[chargeKey === "MixedIncomingPrimeCharge",
      assert[
        TrueQ[mappedCounterterm === 0] &&
          TrueQ[countertermTotals[projector][chargeKey] === 0],
        projector <> " mixed counterterm is not the required structural zero."
      ]
    ];
    countertermCoefficients = boundedFactorwiseSeriesCoefficients[
      mappedCounterterm,
      {-1, 0},
      0,
      countertermMemoryBudgetBytes
    ];
    assert[
      AssociationQ[countertermCoefficients],
      projector <> "/" <> chargeKey <>
        " mapped counterterm Laurent expansion failed."
    ];
    mappedCountertermPolePairs[projector, chargeKey] = <|
      "Endpoint" -> 0,
      "IntegrandPhiS" -> countertermCoefficients[-1],
      "IntegrandPhi0" -> 0
    |>;
    mappedCountertermFinitePairs[projector, chargeKey] = <|
      "Endpoint" -> 0,
      "IntegrandPhiS" -> countertermCoefficients[0],
      "IntegrandPhi0" -> 0
    |>;
    mappedCountertermSHA256[projector, chargeKey] =
      expressionSHA256[canonicalizeForCombination[mappedCounterterm]];
    Clear[
      directPDF, directFF, expectedRebuiltPDF, expectedRebuiltFF,
      mappedCounterterm, countertermCoefficients
    ];,
    {chargeKey, chargeKeys}
  ];,
  {projector, projectorKeys}
];

sEpsilonSeriesThroughOrder1 = messageFreeEvaluate[
  Normal@Series[
    (4 Pi)^epsilon/Gamma[1 - epsilon],
    {epsilon, 0, 1}
  ]
];
assert[
  sEpsilonSeriesThroughOrder1 =!= $Failed &&
    FreeQ[sEpsilonSeriesThroughOrder1, _SeriesData | _Real] &&
    TrueQ[Coefficient[sEpsilonSeriesThroughOrder1, epsilon, 0] === 1] &&
    FreeQ[
      {mappedCountertermPolePairs, mappedCountertermFinitePairs},
      epsilon | _SeriesData | S11SEpsilon | _Real | $Failed
    ] &&
    feynCalcContextCleanQ[{
      mappedCountertermPolePairs,
      mappedCountertermFinitePairs
    }],
  "The exact MS-bar or mapped-counterterm coefficient gate failed."
];

Clear[
  bornProjected, countertermComponents, countertermTotals,
  rebuiltPDFByProjector, rebuiltFFByProjector
];
ClearSystemCache[];

validateS10CacheWorker[
    cache_, projector_String, chargeKey_String
  ] := Module[{action, termCount},
  workerRequire[
    AssociationQ[cache],
    "S10 cache is not an Association for " <> projector <> "/" <> chargeKey
  ];
  action = Lookup[cache, "ResolvedAction", Missing["Absent"]];
  termCount = Lookup[cache, "SourceTermCount", Missing["Absent"]];
  workerRequire[
    cache["Status"] === "Complete" &&
      cache["Stage"] === "HqqprimeS10Cache-v1" &&
      cache["ResultSchemaVersion"] === 1 &&
      cache["Channel"] === "Hqqprime only" &&
      cache["Projector"] === projector &&
      cache["ChargeKey"] === chargeKey &&
      cache["ProgramSHA256"] === expectedS10SourceSHA256 &&
      cache["PaperSHA256"] === expectedPaperSHA256 &&
      IntegerQ[termCount] && termCount > 0 &&
      cache["TopLevelFactorCount"] === 11 &&
      cache["SourceTermIndices"] === Range[termCount] &&
      Length[cache["SourceTermSHA256"]] === termCount &&
      cache["AlphaClass"] === 1 &&
      cache["ExceptionalPowerTermIndices"] === {} &&
      cache["DirectSingularLogTermIndices"] === {} &&
      cache["ResolvedActionSHA256"] === expressionSHA256[action] &&
      cache["ResolvedActionLeafCount"] === LeafCount[action] &&
      cache["ResolvedActionByteCount"] === ByteCount[action] &&
      cache["AdditionalMultiplicativeWeight"] === 1 &&
      cache["ScaleBookkeeping"] === acceptedScaleBookkeeping &&
      cache["ChargeBookkeeping"] === acceptedChargeBookkeeping &&
      cache["SymmetryBookkeeping"] === acceptedSymmetryBookkeeping &&
      cache["FinalStateSymmetryFactor"] === 1 &&
      cache["VirtualContributionAtThisOrder"] ===
        acceptedVirtualBookkeeping &&
      cache["PhysicalOrderedFlavorChargeAssemblyAppliedAtS10"] === False &&
      cache["SeparateMSBarSEpsilonAppliedAtS10"] === False &&
      cache["NontrivialSymmetryFactorAppliedAtS10"] === False &&
      AssociationQ[cache["Checks"]] &&
      And @@ (TrueQ /@ Values[cache["Checks"]]) &&
      Count[action, Inactive[Integrate][___], Infinity] === 1 &&
      Count[
        action,
        candidate_ /; SameQ[
          candidate,
          FeynCalc`ScaleMu^(4 epsilon)
        ],
        Infinity
      ] === 1 &&
      FreeQ[
        action,
        _S09EndpointValue | _S09PlusDistribution |
          _S09RegularEndpointFunction | _S09ExpandedKernelReference |
          DiracDelta[s23] | _Real | $Failed | Indeterminate
      ] &&
      feynCalcContextCleanQ[action],
    "S10 cache validation failed for " <> projector <> "/" <> chargeKey
  ];
  action
];

actionToPairWorker[
    action_, projector_String, chargeKey_String
  ] := Module[
  {
    integrals, integral, body, endpointExpression, endpoint,
    integrandPhiS, integrandPhi0, tests
  },
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]],
    {0, Infinity}
  ];
  workerRequire[
    Length[integrals] === 1,
    "Action integral count changed for " <> projector <> "/" <> chargeKey
  ];
  integral = First[integrals];
  workerRequire[
    TrueQ[Together[integral[[2, 3]] - s23UpperB] === 0],
    "Action upper limit changed for " <> projector <> "/" <> chargeKey
  ];
  body = integral[[1]];
  endpointExpression = action /.
    HoldPattern[Inactive[Integrate][_, {s23, 0, _}]] :> 0;
  endpoint = Coefficient[
    endpointExpression,
    S10ConvolutionTest[projector, chargeKey, 0]
  ];
  integrandPhiS = Coefficient[
    body,
    S10ConvolutionTest[projector, chargeKey, s23]
  ];
  integrandPhi0 = Coefficient[
    body,
    S10ConvolutionTest[projector, chargeKey, 0]
  ];
  tests = DeleteDuplicates@Cases[
    action,
    test_S10ConvolutionTest :> HoldComplete[test],
    Infinity
  ];
  workerRequire[
    tests === {
      HoldComplete[
        S10ConvolutionTest[projector, chargeKey, s23]
      ]
    } && TrueQ[endpoint === 0] &&
      ! TrueQ[integrandPhiS === 0] && TrueQ[integrandPhi0 === 0],
    "Action field or test structure changed for " <> projector <> "/" <>
      chargeKey
  ];
  <|
    "Endpoint" -> endpoint,
    "IntegrandPhiS" -> integrandPhiS,
    "IntegrandPhi0" -> integrandPhi0
  |>
];

sourcePartitionAuditWorker[
    expression_, cache_Association, projector_String, chargeKey_String
  ] := Module[
  {factors, plusPositions, maximalPositions, sourceRemainder, sourceTerms},
  factors = If[Head[expression] === Times, List @@ expression, {expression}];
  plusPositions = Select[
    Range[Length[factors]],
    Head[factors[[#]]] === Plus &
  ];
  maximalPositions = MaximalBy[
    plusPositions,
    LeafCount[factors[[#]]] &
  ];
  workerRequire[
    Length[factors] === 12 && Length[plusPositions] >= 1 &&
      Length[maximalPositions] === 1 &&
      Count[expression, _Piecewise, Infinity] === 0,
    "Action factor partition changed for " <> projector <> "/" <> chargeKey
  ];
  sourceRemainder = factors[[First[maximalPositions]]];
  sourceTerms = List @@ sourceRemainder;
  workerRequire[
    Length[sourceTerms] === cache["SourceTermCount"],
    "Measured source-term count disagrees with S10 for " <> projector <> "/" <>
      chargeKey
  ];
  <|
    "ActionFactorCount" -> Length[factors],
    "AdditiveFactorTermCounts" ->
      (Length[List @@ factors[[#]]] & /@ plusPositions),
    "SourceTermCount" -> Length[sourceTerms],
    "SourceTermIndices" -> Range[Length[sourceTerms]],
    "SourceRemainderLeafCount" -> LeafCount[sourceRemainder],
    "AlphaClass" -> cache["AlphaClass"],
    "ExceptionalPowerTermIndices" -> cache["ExceptionalPowerTermIndices"]
  |>
];

zeroEquivalentWorker[expression_] := Module[{residual, reduced},
  residual = canonicalizeForCombination[expression];
  If[TrueQ[residual === 0], Return[0]];
  reduced = messageFreeEvaluate[
    MemoryConstrained[
      TimeConstrained[
        Cancel[Together[residual]],
        residualTimeoutSeconds,
        $Failed
      ],
      workerMemoryBudgetBytes,
      $Failed
    ]
  ];
  If[TrueQ[reduced === 0], Return[0]];
  If[reduced === $Failed, reduced = residual];
  reduced = messageFreeEvaluate[
    MemoryConstrained[
      TimeConstrained[
        FullSimplify[
          reduced,
          Assumptions ->
            0 < xB < xi < 1 && 0 < zH < 1 && Q2 > 0 &&
              PHT2 > 0 && FeynCalc`ScaleMu > 0 && FeynCalc`CA > 0
        ],
        residualTimeoutSeconds,
        $Failed
      ],
      workerMemoryBudgetBytes,
      $Failed
    ]
  ];
  If[TrueQ[reduced === 0], 0, $Failed]
];

processBranchWorker[
    s10CachePath_String, projector_String, chargeKey_String,
    countertermPolePair_Association, countertermFinitePair_Association,
    countertermHash_String
  ] := Module[
  {
    cache, action, actionPair, partitionAudit, realCoefficients,
    realLaurentPairs, poleResiduals, doubleExpression, simpleExpression,
    doubleResidual, simpleResidual, finitePair, finiteAction, checks
  },
  cache = Quiet@Check[Get[s10CachePath], $Failed];
  action = validateS10CacheWorker[cache, projector, chargeKey];
  actionPair = actionToPairWorker[action, projector, chargeKey];
  partitionAudit = sourcePartitionAuditWorker[
    actionPair["IntegrandPhiS"], cache, projector, chargeKey
  ];
  Print[
    "S12_WORKER_BRANCH: ", projector, "/", chargeKey,
    " sourceTerms=", partitionAudit["SourceTermCount"],
    " leafCount=", LeafCount[actionPair["IntegrandPhiS"]]
  ];
  realCoefficients = boundedFactorwiseSeriesCoefficients[
    actionPair["IntegrandPhiS"],
    laurentPowers,
    0,
    workerMemoryBudgetBytes
  ];
  workerRequire[
    AssociationQ[realCoefficients],
    "Real Laurent extraction failed for " <> projector <> "/" <> chargeKey
  ];
  realLaurentPairs = AssociationMap[
    Function[power,
      <|
        "Endpoint" -> 0,
        "IntegrandPhiS" -> realCoefficients[power],
        "IntegrandPhi0" -> 0
      |>
    ],
    laurentPowers
  ];
  poleResiduals = <|"Minus2" -> <||>, "Minus1" -> <||>|>;
  Do[
    doubleExpression = realLaurentPairs[-2][field];
    simpleExpression =
      realLaurentPairs[-1][field] + countertermPolePair[field];
    doubleResidual = zeroEquivalentWorker[doubleExpression];
    simpleResidual = zeroEquivalentWorker[simpleExpression];
    workerRequire[
      TrueQ[doubleResidual === 0],
      <|
        "Label" -> projector <> "/" <> chargeKey <>
          " epsilon^-2 " <> field,
        "Expression" -> canonicalizeForCombination[doubleExpression],
        "S10Real" -> realLaurentPairs[-2][field],
        "Eq46Counterterm" -> 0
      |>
    ];
    workerRequire[
      TrueQ[simpleResidual === 0],
      <|
        "Label" -> projector <> "/" <> chargeKey <>
          " epsilon^-1 " <> field,
        "Expression" -> canonicalizeForCombination[simpleExpression],
        "S10Real" -> realLaurentPairs[-1][field],
        "Eq46Counterterm" -> countertermPolePair[field]
      |>
    ];
    poleResiduals["Minus2", field] = 0;
    poleResiduals["Minus1", field] = 0;,
    {field, pairFields}
  ];
  finitePair = pairAdd[realLaurentPairs[0], countertermFinitePair];
  finiteAction = pairToAction[finitePair, projector, chargeKey];
  checks = <|
    "ExactS10CacheAndResolvedActionValidated" -> True,
    "OnlyIntegrandPhiSActionFieldNonzero" -> True,
    "CurrentSourcePartitionRemeasured" -> True,
    "CurrentSourceCountMatchesS10Cache" -> True,
    "AlphaOneOnly" -> True,
    "FactorwiseLaurentThroughFiniteOrderComplete" -> True,
    "DoublePoleAllFieldsExactZero" ->
      And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Minus2"]]),
    "SimplePoleAllFieldsExactZero" ->
      And @@ (TrueQ[# === 0] & /@ Values[poleResiduals["Minus1"]]),
    "FinitePairAndActionExactAndContextClean" ->
      FreeQ[
        {finitePair, finiteAction},
        epsilon | _SeriesData | S11SEpsilon | _S11ConvolutionTest |
          _S11PlusDistribution | _S09EndpointValue |
          _S09PlusDistribution | _S09RegularEndpointFunction |
          _S09ExpandedKernelReference | DiracDelta[s23] |
          FeynCalc`SUNN | FeynCalc`CF | FeynCalc`TF | _Real |
          $Failed | Indeterminate | ComplexInfinity | DirectedInfinity[_] |
          Power[0, _?Negative]
      ] && feynCalcContextCleanQ[{finitePair, finiteAction}],
    "FiniteActionRetainsOneOrdinaryIntegral" ->
      Count[
        finiteAction,
        Inactive[Integrate][___],
        {0, Infinity}
      ] === 1,
    "FiniteActionRetainsMatchingArbitraryS10Test" ->
      DeleteDuplicates@Cases[
        finiteAction,
        test_S10ConvolutionTest :> HoldComplete[test],
        Infinity
      ] === {
        HoldComplete[
          S10ConvolutionTest[projector, chargeKey, s23]
        ]
      },
    "UnitWeightSymmetryAndAbsentVirtualPreserved" -> True,
    "PhysicalOrderedFlavorChargeAssemblyDeferred" -> True,
    "Eq9FHatAndExternalComparisonDeferred" -> True
  |>;
  If[! And @@ (TrueQ /@ Values[checks]),
    Print[
      "S12_WORKER_CHECK_FAILURE: ", projector, "/", chargeKey,
      " checks=", InputForm[checks]
    ]
  ];
  workerRequire[
    And @@ (TrueQ /@ Values[checks]),
    <|
      "Message" ->
        "Final branch checks failed for " <> projector <> "/" <> chargeKey,
      "Checks" -> checks
    |>
  ];
  <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "ResultSchemaVersion" -> resultSchemaVersion,
    "Channel" -> "Hqqprime only",
    "Projector" -> projector,
    "ChargeKey" -> chargeKey,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "PaperSHA256" -> expectedPaperSHA256,
    "S10SourceSHA256" -> expectedS10SourceSHA256,
    "S10ResultSHA256" -> expectedS10ResultSHA256,
    "S10CachePath" -> s10CachePath,
    "S10CacheSHA256" -> expectedS10CacheSHA256[projector][chargeKey],
    "S10ResolvedActionSHA256" -> cache["ResolvedActionSHA256"],
    "S10ResolvedActionLeafCount" -> cache["ResolvedActionLeafCount"],
    "S10ResolvedActionByteCount" -> cache["ResolvedActionByteCount"],
    "S11SourceSHA256" -> expectedS11SourceSHA256,
    "S11ResultSHA256" -> expectedS11ResultSHA256,
    "MappedCountertermSHA256" -> countertermHash,
    "SourcePartitionAudit" -> partitionAudit,
    "RealLaurentPairs" -> realLaurentPairs,
    "RealLaurentPairSHA256" -> Map[expressionSHA256, realLaurentPairs],
    "CountertermPolePair" -> countertermPolePair,
    "CountertermFinitePair" -> countertermFinitePair,
    "PoleResiduals" -> poleResiduals,
    "FiniteCoefficientPair" -> finitePair,
    "FiniteCoefficientPairSHA256" -> expressionSHA256[finitePair],
    "FiniteFactorizedAction" -> finiteAction,
    "FiniteFactorizedActionSHA256" -> expressionSHA256[finiteAction],
    "FiniteFactorizedActionLeafCount" -> LeafCount[finiteAction],
    "FiniteFactorizedActionByteCount" -> ByteCount[finiteAction],
    "Bookkeeping" -> <|
      "AdditionalMultiplicativeWeightAtS12" -> 1,
      "SeparatedChargeTensorKeys" -> chargeKeys,
      "PhysicalOrderedFlavorChargeAssemblyApplied" -> False,
      "FinalStateSymmetryFactorInherited" -> 1,
      "NontrivialSymmetryFactorAppliedAtS12" -> False,
      "RealAbsoluteScaleInherited" ->
        FeynCalc`ScaleMu^(4 epsilon),
      "CountertermBornAbsoluteScaleInherited" ->
        FeynCalc`ScaleMu^(2 epsilon),
      "AdditionalPartonicPDForFFMuEpsilon" -> 0,
      "ColorBasisAtCombination" -> HoldForm[
        FeynCalc`SUNN == FeynCalc`CA
      ],
      "VirtualContributionAtThisOrder" -> acceptedVirtualBookkeeping
    |>,
    "Checks" -> checks
  |>
];

processChargeTask[task_Association] := Module[
  {caught, chargeKey, requestedProjectors, records},
  caught = Catch[
    chargeKey = task["ChargeKey"];
    requestedProjectors = task["RequestedProjectors"];
    records = AssociationMap[
      Function[projector,
        processBranchWorker[
          task["S10CachePaths"][projector],
          projector,
          chargeKey,
          task["CountertermPolePairs"][projector],
          task["CountertermFinitePairs"][projector],
          task["MappedCountertermSHA256"][projector]
        ]
      ],
      requestedProjectors
    ];
    <|
      "Success" -> True,
      "ChargeKey" -> chargeKey,
      "RequestedProjectors" -> requestedProjectors,
      "Records" -> records
    |>,
    "S12WorkerFailure"
  ];
  If[
    AssociationQ[caught] && TrueQ[Lookup[caught, "Success", False]],
    caught,
    <|
      "Success" -> False,
      "ChargeKey" -> Lookup[task, "ChargeKey", "Unknown"],
      "Failure" -> caught
    |>
  ]
];

launchS12Kernels[kernelCount_Integer] := Module[
  {localCandidates, configuration, launched},
  closeS12Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet@Check[#1["Class"] === "LocalKernels", False] &
  ];
  assert[
    Length[localCandidates] >= 1,
    "No local Wolfram kernel configuration is available."
  ];
  configuration = ReplacePart[
    First[localCandidates],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> kernelCount,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ];
  assert[
    configuration["KernelCommand"] === parallelKernelExecutable &&
      configuration["KernelCount"] === kernelCount &&
      configuration["UseKernelForking"] === False,
    "The in-memory Engine-15 kernel configuration is invalid."
  ];
  launched = Quiet@Check[LaunchKernels[configuration], $Failed];
  assert[
    ListQ[launched] && Length[launched] === kernelCount &&
      $KernelCount === kernelCount,
    "Failed to launch the required Engine-15 local kernels."
  ];
  launchedKernelCount = kernelCount;
  ParallelNeeds["FeynCalc`"];
  ParallelEvaluate[$HistoryLength = 0; $FCAdvice = False;];
  workerVersions = ParallelEvaluate[$Version];
  assert[
    Length[workerVersions] === kernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
    "A local worker is not the verified Engine 15.0 runtime."
  ];
  DistributeDefinitions[
    workerRequire, messageFreeEvaluate, expressionSHA256,
    accidentalGlobalFeynCalcSymbolQ, feynCalcContextCleanQ,
    canonicalizeForCombination, seriesMinimumPower,
    summandwiseSeriesCoefficientData, convolveLaurentCoefficientData,
    factorwiseSeriesCoefficients, boundedFactorwiseSeriesCoefficients,
    zeroPair, pairAdd, pairToAction, validateS10CacheWorker,
    actionToPairWorker, sourcePartitionAuditWorker,
    zeroEquivalentWorker, processBranchWorker, processChargeTask,
    expectedPaperSHA256, expectedS10SourceSHA256,
    expectedS10ResultSHA256, expectedS11SourceSHA256,
    expectedS11ResultSHA256, expectedS10CacheSHA256,
    acceptedScaleBookkeeping, acceptedChargeBookkeeping,
    acceptedSymmetryBookkeeping, acceptedVirtualBookkeeping,
    toolDerivedTF, toolDerivedCFInCA, toolDerivedCA,
    toolDerivedPolyGammaHalf, toolDerivedPowerOfTwoLogRules,
    programPath, programSHA256, cacheStageVersion, resultSchemaVersion,
    projectorKeys, chargeKeys, pairFields, laurentPowers,
    workerMemoryBudgetBytes, seriesTimeoutSeconds,
    residualTimeoutSeconds, s23UpperB, feynCalcOwnedSymbolNames,
    S09EndpointValue, S09PlusDistribution,
    S09RegularEndpointFunction, S09ExpandedKernelReference,
    S11ConvolutionTest, S11PlusDistribution, S10ConvolutionTest
  ];
  True
];

validBranchPayloadQ[
    payload_, projector_String, chargeKey_String
  ] := TrueQ[
  AssociationQ[payload] &&
    payload["Status"] === "Complete" &&
    payload["Stage"] === cacheStageVersion &&
    payload["ResultSchemaVersion"] === resultSchemaVersion &&
    payload["Channel"] === "Hqqprime only" &&
    payload["Projector"] === projector &&
    payload["ChargeKey"] === chargeKey &&
    payload["ProgramSHA256"] === programSHA256 &&
    payload["PaperSHA256"] === expectedPaperSHA256 &&
    payload["S10SourceSHA256"] === expectedS10SourceSHA256 &&
    payload["S10ResultSHA256"] === expectedS10ResultSHA256 &&
    payload["S10CachePath"] === s10CachePaths[projector][chargeKey] &&
    payload["S10CacheSHA256"] ===
      expectedS10CacheSHA256[projector][chargeKey] &&
    payload["S11SourceSHA256"] === expectedS11SourceSHA256 &&
    payload["S11ResultSHA256"] === expectedS11ResultSHA256 &&
    payload["MappedCountertermSHA256"] ===
      mappedCountertermSHA256[projector][chargeKey] &&
    AssociationQ[payload["SourcePartitionAudit"]] &&
    payload["SourcePartitionAudit"]["AlphaClass"] === 1 &&
    payload["SourcePartitionAudit"]["ExceptionalPowerTermIndices"] === {} &&
    AssociationQ[payload["RealLaurentPairs"]] &&
    Keys[payload["RealLaurentPairs"]] === laurentPowers &&
    payload["RealLaurentPairSHA256"] ===
      Map[expressionSHA256, payload["RealLaurentPairs"]] &&
    payload["CountertermPolePair"] ===
      mappedCountertermPolePairs[projector][chargeKey] &&
    payload["CountertermFinitePair"] ===
      mappedCountertermFinitePairs[projector][chargeKey] &&
    And @@ Flatten@Table[
      TrueQ[payload["PoleResiduals"][order][field] === 0],
      {order, {"Minus2", "Minus1"}},
      {field, pairFields}
    ] &&
    payload["FiniteCoefficientPairSHA256"] ===
      expressionSHA256[payload["FiniteCoefficientPair"]] &&
    payload["FiniteFactorizedActionSHA256"] ===
      expressionSHA256[payload["FiniteFactorizedAction"]] &&
    payload["FiniteFactorizedActionLeafCount"] ===
      LeafCount[payload["FiniteFactorizedAction"]] &&
    payload["FiniteFactorizedActionByteCount"] ===
      ByteCount[payload["FiniteFactorizedAction"]] &&
    Count[
      payload["FiniteFactorizedAction"],
      Inactive[Integrate][___],
      {0, Infinity}
    ] === 1 &&
    FreeQ[
      {payload["FiniteCoefficientPair"],
        payload["FiniteFactorizedAction"]},
      epsilon | _SeriesData | S11SEpsilon | _S11ConvolutionTest |
        _S11PlusDistribution | _S09EndpointValue |
        _S09PlusDistribution | _S09RegularEndpointFunction |
        _S09ExpandedKernelReference | DiracDelta[s23] |
        FeynCalc`SUNN | FeynCalc`CF | FeynCalc`TF | _Real |
        $Failed | Indeterminate | ComplexInfinity | DirectedInfinity[_] |
        Power[0, _?Negative]
    ] &&
    feynCalcContextCleanQ[{
      payload["FiniteCoefficientPair"],
      payload["FiniteFactorizedAction"]
    }] &&
    payload["Bookkeeping"]["AdditionalMultiplicativeWeightAtS12"] === 1 &&
    payload["Bookkeeping"]["SeparatedChargeTensorKeys"] === chargeKeys &&
    payload["Bookkeeping"][
      "PhysicalOrderedFlavorChargeAssemblyApplied"
    ] === False &&
    payload["Bookkeeping"]["FinalStateSymmetryFactorInherited"] === 1 &&
    payload["Bookkeeping"][
      "NontrivialSymmetryFactorAppliedAtS12"
    ] === False &&
    payload["Bookkeeping"]["VirtualContributionAtThisOrder"] ===
      acceptedVirtualBookkeeping &&
    AssociationQ[payload["Checks"]] &&
    And @@ (TrueQ /@ Values[payload["Checks"]])
];

Print["S12_STAGE: checking source-bound branch-cache resume inventory"];
branchPayloads = AssociationMap[Function[unused, <||>], projectorKeys];
missingProjectorsByCharge = AssociationMap[Function[unused, {}], chargeKeys];
If[preflightOnly,
  Do[
    missingProjectorsByCharge[chargeKey] = projectorKeys,
    {chargeKey, chargeKeys}
  ];
  Print["S12_PREFLIGHT_STAGE: ignoring S12 caches and writing nothing"],
  Do[
    currentS12CachePath = s12CachePaths[projector][chargeKey];
    If[FileExistsQ[currentS12CachePath],
      existingPayload = Quiet@Check[Get[currentS12CachePath], $Failed];
      If[validBranchPayloadQ[existingPayload, projector, chargeKey],
        branchPayloads[projector, chargeKey] = existingPayload;
        Print["S12_BRANCH_RESUME: ", projector, "/", chargeKey],
        Print["S12_BRANCH_CACHE_INVALID: deleting ", currentS12CachePath];
        DeleteFile[currentS12CachePath];
        AppendTo[missingProjectorsByCharge[chargeKey], projector]
      ],
      AppendTo[missingProjectorsByCharge[chargeKey], projector]
    ];
    Clear[existingPayload];,
    {projector, projectorKeys},
    {chargeKey, chargeKeys}
  ]
];

chargeTasks = Select[
  Table[
    <|
      "ChargeKey" -> chargeKey,
      "RequestedProjectors" -> missingProjectorsByCharge[chargeKey],
      "S10CachePaths" -> AssociationMap[
        s10CachePaths[#][chargeKey] &,
        missingProjectorsByCharge[chargeKey]
      ],
      "CountertermPolePairs" -> AssociationMap[
        mappedCountertermPolePairs[#][chargeKey] &,
        missingProjectorsByCharge[chargeKey]
      ],
      "CountertermFinitePairs" -> AssociationMap[
        mappedCountertermFinitePairs[#][chargeKey] &,
        missingProjectorsByCharge[chargeKey]
      ],
      "MappedCountertermSHA256" -> AssociationMap[
        mappedCountertermSHA256[#][chargeKey] &,
        missingProjectorsByCharge[chargeKey]
      ]
    |>,
    {chargeKey, chargeKeys}
  ],
  Length[#1["RequestedProjectors"]] > 0 &
];

If[Length[chargeTasks] > 0,
  assert[
    Length[chargeTasks] <= requestedParallelKernelCount,
    "The missing charge-task count exceeds the contracted worker count."
  ];
  Print[
    "S12_STAGE: launching ", Length[chargeTasks],
    " Engine-15 charge workers"
  ];
  launchS12Kernels[Length[chargeTasks]];
  parallelOrderProbe = ParallelMap[
    Identity,
    Lookup[chargeTasks, "ChargeKey"],
    Method -> "FinestGrained"
  ];
  assert[
    parallelOrderProbe === Lookup[chargeTasks, "ChargeKey"],
    "Parallel charge ordering is not deterministic."
  ];
  chargeResults = Quiet@Check[
    ParallelMap[
      processChargeTask,
      chargeTasks,
      Method -> "FinestGrained"
    ],
    $Failed
  ];
  closeS12Kernels[];
  assert[
    ListQ[chargeResults] &&
      Length[chargeResults] === Length[chargeTasks] &&
      And @@ (AssociationQ /@ chargeResults) &&
      And @@ (TrueQ[Lookup[#, "Success", False]] & /@ chargeResults),
    "A charge worker failed: " <>
      ToString[InputForm[Lookup[chargeResults, "Failure", None]]]
  ];
  assert[
    Lookup[chargeResults, "ChargeKey"] ===
      Lookup[chargeTasks, "ChargeKey"],
    "Charge-worker results returned in the wrong order."
  ];
  Do[
    chargeKey = chargeResult["ChargeKey"];
    Do[
      branchRecord = chargeResult["Records"][projector];
      assert[
        validBranchPayloadQ[branchRecord, projector, chargeKey],
        "A returned branch payload failed main-kernel validation for " <>
          projector <> "/" <> chargeKey <> "."
      ];
      If[preflightOnly,
        branchPayloads[projector, chargeKey] = branchRecord;
        Print[
          "S12_PREFLIGHT_BRANCH_VALIDATED: ", projector, "/", chargeKey
        ],
        currentS12CachePath = s12CachePaths[projector][chargeKey];
        atomicPutAssociation[
          branchRecord,
          currentS12CachePath,
          cacheStageVersion
        ];
        reloadedBranch = Quiet@Check[Get[currentS12CachePath], $Failed];
        assert[
          validBranchPayloadQ[reloadedBranch, projector, chargeKey] &&
            TrueQ[reloadedBranch === branchRecord],
          "Published branch cache failed exact reload validation for " <>
            projector <> "/" <> chargeKey <> "."
        ];
        branchPayloads[projector, chargeKey] = reloadedBranch;
        Print[
          "S12_BRANCH_CHECKPOINT: ", projector, "/", chargeKey,
          " sha256=", fileSHA256[currentS12CachePath]
        ]
      ];
      Clear[branchRecord, reloadedBranch];,
      {projector, chargeResult["RequestedProjectors"]}
    ];,
    {chargeResult, chargeResults}
  ];
  Clear[chargeResults, chargeTasks];
  ClearSystemCache[],
  Print["S12_STAGE: all six source-bound branch caches already complete"]
];

assert[
  Keys[branchPayloads] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[branchPayloads]) &&
    And @@ Flatten@Table[
      validBranchPayloadQ[
        branchPayloads[projector][chargeKey],
        projector,
        chargeKey
      ],
      {projector, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "The complete six-branch S12 payload inventory is invalid."
];

s12CacheSHA256 = If[
  preflightOnly,
  AssociationMap[
    Function[projector,
      AssociationMap[
        expressionSHA256[branchPayloads[projector][#]] &,
        chargeKeys
      ]
    ],
    projectorKeys
  ],
  AssociationMap[
    Function[projector,
      AssociationMap[
        fileSHA256[s12CachePaths[projector][#]] &,
        chargeKeys
      ]
    ],
    projectorKeys
  ]
];
branchSummaries = AssociationMap[
  Function[projector,
    AssociationMap[
      Function[chargeKey,
        With[{payload = branchPayloads[projector][chargeKey]},
          <|
            "SourceTermCount" ->
              payload["SourcePartitionAudit"]["SourceTermCount"],
            "MappedCountertermSHA256" ->
              payload["MappedCountertermSHA256"],
            "PoleResiduals" -> payload["PoleResiduals"],
            "FiniteCoefficientPairSHA256" ->
              payload["FiniteCoefficientPairSHA256"],
            "FiniteFactorizedActionSHA256" ->
              payload["FiniteFactorizedActionSHA256"],
            "FiniteFactorizedActionLeafCount" ->
              payload["FiniteFactorizedActionLeafCount"],
            "FiniteFactorizedActionByteCount" ->
              payload["FiniteFactorizedActionByteCount"]
          |>
        ]
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];

allPoleResiduals = AssociationMap[
  Function[projector,
    AssociationMap[
      branchPayloads[projector][#]["PoleResiduals"] &,
      chargeKeys
    ]
  ],
  projectorKeys
];

s12Checks = <|
  "ExactPaperS10S11ProgramsAndResultsPinned" -> True,
  "AllSixS10EndpointCachesPinned" -> True,
  "AllAcceptedS10AndS11ChecksTrue" -> True,
  "FeynCalcLoadedBeforeSerializedArtifacts" -> True,
  "ProjectorAndChargeOrderPreserved" -> True,
  "PhysicalEq29ToEq32MapRebuilt" -> True,
  "AllPhysicalMapAndBornShellResidualsExactZero" ->
    And @@ (TrueQ[# === 0] & /@ Values[mappingResiduals]),
  "FourNonzeroAndTwoStructuralZeroCountertermsPreserved" -> True,
  "EverySavedCountertermMappedAndIndependentlyRebuilt" ->
    And @@ (
      TrueQ[# === 0] & /@
        Flatten[
          Values /@ allBranchValues[countertermEquivalenceResiduals]
        ]
    ),
  "OnlyPPPPDFReceivesOneOverYSquared" -> True,
  "PositiveEq46SignInherited" -> True,
  "ExactMSBarSEpsilonExpandedByWolframSeries" -> True,
  "FeynCalcDerivedTFAndCFCanonicalization" -> True,
  "SUNNToCACombinationRegressionExact" ->
    TrueQ[colorRegressionResidual === 0],
  "AllSixCurrentS10ActionPartitionsRemeasured" -> True,
  "AllSixBranchesAlphaOneOnly" -> True,
  "AllSixDoublePoleRecordsExactZeroByField" ->
    And @@ Flatten@Table[
      TrueQ[
        allPoleResiduals[projector][chargeKey]["Minus2"][field] === 0
      ],
      {projector, projectorKeys},
      {chargeKey, chargeKeys},
      {field, pairFields}
    ],
  "AllSixSimplePoleRecordsExactZeroByField" ->
    And @@ Flatten@Table[
      TrueQ[
        allPoleResiduals[projector][chargeKey]["Minus1"][field] === 0
      ],
      {projector, projectorKeys},
      {chargeKey, chargeKeys},
      {field, pairFields}
    ],
  "MixedSimplePolesCancelWithStructuralZeroCounterterms" ->
    And @@ Table[
      mappedCountertermPolePairs[projector][
        "MixedIncomingPrimeCharge"
      ] === zeroPair[] &&
        And @@ (
          TrueQ[# === 0] & /@
            Values[
              allPoleResiduals[projector][
                "MixedIncomingPrimeCharge"
              ]["Minus1"]
            ]
        ),
      {projector, projectorKeys}
    ],
  "SixFiniteCoefficientPairsAndActionsSavedInCaches" -> True,
  "SixFiniteActionsExactContextCleanAndOneIntegral" ->
    And @@ Flatten@Table[
      TrueQ[
        branchPayloads[projector][chargeKey]["Checks"][
          "FinitePairAndActionExactAndContextClean"
        ] &&
          branchPayloads[projector][chargeKey]["Checks"][
            "FiniteActionRetainsOneOrdinaryIntegral"
          ]
      ],
      {projector, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "UnitWeightFinalStateFactorAndAbsentVirtualPreserved" -> True,
  "ThreeChargeTensorsRemainSeparateAndChargeFree" -> True,
  "NoAdditionalScaleOrMSBarFactorApplied" -> True,
  "PhysicalOrderedFlavorChargeAssemblyDeferred" -> True,
  "ExactlyThreeWorkersUsedForFreshThreeChargeRun" ->
    If[
      launchedKernelCount > 0,
      launchedKernelCount === requestedParallelKernelCount &&
        Length[workerVersions] === requestedParallelKernelCount,
      True
    ],
  "WorkersReturnedDeterministicChargeOrderAndWroteNothing" -> True,
  "SixAtomicSourceBoundCachesReloadValidated" -> True,
  "CompactResultDoesNotDuplicateFiniteActions" -> True,
  "Eq9FHatPhysicalAssemblyAndExternalComparisonDeferred" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[s12Checks]),
  "At least one final Hqqprime S12 check is not True."
];

s12Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "finite Eq. (46)-factorized charge-resolved H_{q qPrime; q qbarPrime} projector actions",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ProjectorOrder" -> projectorKeys,
  "ChargeKeyOrder" -> chargeKeys,
  "InputProvenance" -> <|
    "AuthoritativePaperPath" -> paperPath,
    "AuthoritativePaperSHA256" -> expectedPaperSHA256,
    "S10SourcePath" -> s10SourcePath,
    "S10SourceSHA256" -> expectedS10SourceSHA256,
    "S10ResultPath" -> s10ResultPath,
    "S10ResultSHA256" -> expectedS10ResultSHA256,
    "S10EndpointCachePaths" -> s10CachePaths,
    "S10EndpointCacheSHA256" -> expectedS10CacheSHA256,
    "S11SourcePath" -> s11SourcePath,
    "S11SourceSHA256" -> expectedS11SourceSHA256,
    "S11ResultPath" -> s11ResultPath,
    "S11ResultSHA256" -> expectedS11ResultSHA256
  |>,
  "CalculationMode" ->
    "fully exact symbolic factorwise Laurent combination with branch caches",
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
    "Scheme" -> "MSbar",
    "SEpsilonDefinition" -> HoldForm[
      S11SEpsilon == (4 Pi)^epsilon/Gamma[1 - epsilon]
    ],
    "SEpsilonSeriesThroughOrder1" -> sEpsilonSeriesThroughOrder1,
    "PDFRoute" -> "HgqPrime^(LO) x Pgq -> PrimeChargeSquared",
    "FFRoute" -> "Hqg^(LO) x Pqg -> IncomingChargeSquared",
    "MixedRoute" -> 0,
    "ToolDerivedTF" -> toolDerivedTF,
    "ToolDerivedCFInCA" -> toolDerivedCFInCA,
    "ColorCanonicalization" -> HoldForm[
      FeynCalc`SUNN == FeynCalc`CA
    ],
    "AdditionalMuEpsilonFromPartonicPDForFF" -> 0,
    "AdditionalMultiplicativeWeightAtS12" -> 1
  |>,
  "CountertermMappingEquivalenceResiduals" ->
    countertermEquivalenceResiduals,
  "MappedCountertermSHA256" -> mappedCountertermSHA256,
  "PoleResidualsByProjectorChargeAndField" -> allPoleResiduals,
  "FiniteActionCaches" -> <|
    "StageVersion" -> cacheStageVersion,
    "Paths" -> s12CachePaths,
    "SHA256" -> s12CacheSHA256,
    "FiniteCoefficientPairField" -> "FiniteCoefficientPair",
    "FiniteFactorizedActionField" -> "FiniteFactorizedAction",
    "ProgramSHA256" -> programSHA256,
    "AtomicMainWriterAndExactReloadValidated" -> True
  |>,
  "BranchSummaries" -> branchSummaries,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS12" -> 1,
    "Charge" -> <|
      "SeparatedTensorKeys" -> chargeKeys,
      "CoefficientTensorsRemainChargeFree" -> True,
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS12" -> False,
      "PhysicalAssemblyInstruction" ->
        acceptedChargeBookkeeping["PhysicalAssemblyInstruction"]
    |>,
    "Scale" -> <|
      "RealAbsoluteFactorInheritedFromS10" ->
        FeynCalc`ScaleMu^(4 epsilon),
      "CountertermBornAbsoluteFactorInheritedFromS11" ->
        FeynCalc`ScaleMu^(2 epsilon),
      "PartonicPDForFFAdditionalMuEpsilon" -> 0,
      "SeparateMSBarSEpsilonAppliedToS10" -> False
    |>,
    "Symmetry" -> <|
      "FinalStateFactorInherited" -> 1,
      "AdditionalSymmetryOrFlavorMultiplicityAtS12" -> 1,
      "NontrivialSymmetryFactorAppliedAtS12" -> False
    |>,
    "VirtualContributionAtThisOrder" -> acceptedVirtualBookkeeping
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedFreshLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> launchedKernelCount,
    "WorkerVersions" -> workerVersions,
    "ChargeKeysProcessedIndependently" ->
      If[launchedKernelCount > 0, parallelOrderProbe, {}],
    "ProjectorsSerialWithinEachChargeWorker" -> projectorKeys,
    "ConcurrentCacheWrites" -> False,
    "DeterministicResultOrder" -> True
  |>,
  "Checks" -> s12Checks,
  "MemoryStrategy" ->
    "three charge workers; Pg then PPP serial within each worker; exact factorwise series and bounded residual reduction; workers write nothing; main atomically publishes six branch caches and compact result",
  "NotPerformedAtThisStage" -> {
    "paper Eq. (9) Pg/PPP inversion",
    "F-hat extraction",
    "physical ordered q,qPrime flavour/charge assembly",
    "external-code comparison",
    "numerical kinematics"
  },
  "DownstreamInstruction" ->
    "Load FeynCalc, verify this compact result and each hash-pinned HqqprimeS12Cache-v1 payload, then read FiniteCoefficientPair or FiniteFactorizedAction in projector-first and charge-second order; do not combine charge tensors before the separately authorized physical assembly."
|>;

assert[
  FreeQ[
    s12Result,
    HoldPattern[Rule["FiniteFactorizedAction", _]] |
      HoldPattern[Rule["FiniteCoefficientPair", _]]
  ],
  "The compact result unexpectedly duplicates a finite branch payload."
];

Print[
  If[
    preflightOnly,
    "S12_PREFLIGHT_STAGE: validating compact result candidate without writing",
    "S12_STAGE: writing and exactly reloading compact finite result"
  ]
];
If[preflightOnly,
  assert[
    ! FileExistsQ[resultPath] &&
      And @@ (! FileExistsQ[#] & /@ allBranchValues[s12CachePaths]) &&
      ! FileExistsQ[diagnosticPath],
    "The S12 preflight wrote a forbidden result, cache, or diagnostic artifact."
  ];
  Print["S12_PREFLIGHT_SUCCESS_NO_WRITE"];
  Print["S12_PREFLIGHT_SOURCE_TERM_COUNTS=", InputForm[
    Map[
      Map[#1["SourceTermCount"] &, #] &,
      branchSummaries
    ]
  ]];
  Print["S12_PREFLIGHT_POLE_RESIDUALS=", InputForm[allPoleResiduals]];
  Print["S12_PREFLIGHT_CHECKS=", InputForm[s12Checks]];
  Quit[0]
];
atomicPutAssociation[s12Result, resultPath, stageVersion];
reloadedResult = Quiet@Check[Get[resultPath], $Failed];
assert[
  AssociationQ[reloadedResult] && TrueQ[reloadedResult === s12Result] &&
    reloadedResult["FiniteActionCaches"]["SHA256"] ===
      s12CacheSHA256 &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "The published compact S12 result failed exact reload validation."
];
Do[
  reloadedBranch = Quiet@Check[
    Get[s12CachePaths[projector][chargeKey]],
    $Failed
  ];
  assert[
    validBranchPayloadQ[reloadedBranch, projector, chargeKey] &&
      fileSHA256[s12CachePaths[projector][chargeKey]] ===
        s12CacheSHA256[projector][chargeKey],
    "A finalized branch cache failed the embedded artifact verification for " <>
      projector <> "/" <> chargeKey <> "."
  ];
  Clear[reloadedBranch];,
  {projector, projectorKeys},
  {chargeKey, chargeKeys}
];
assert[
  ! FileExistsQ[diagnosticPath],
  "A nonzero-residual diagnostic unexpectedly remains after success."
];

Print["S12_SUCCESS_FINITE_FACTORIZED_HQQPRIME"];
Print["S12_RESULT_PATH=", resultPath];
Print["S12_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S12_RESULT_SHA256=", fileSHA256[resultPath]];
Print["S12_CACHE_SHA256=", InputForm[s12CacheSHA256]];
Print["S12_SOURCE_TERM_COUNTS=", InputForm[
  Map[
    Map[#1["SourceTermCount"] &, #] &,
    branchSummaries
  ]
]];
Print["S12_POLE_RESIDUALS=", InputForm[allPoleResiduals]];
Print["S12_CHECKS=", InputForm[s12Checks]];

Quit[0];

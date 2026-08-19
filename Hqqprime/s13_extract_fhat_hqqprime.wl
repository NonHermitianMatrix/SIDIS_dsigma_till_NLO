(* ::Package:: *)

(*
  Hqqprime S13: consume the accepted finite charge-resolved Pg/PPP
  coefficient pairs from S12, derive the paper Eq. (9) extraction matrix,
  and publish exact F1Hat/F2Hat coefficient pairs and actions.  Physical
  ordered-flavour/charge assembly and external comparison remain downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll["Global`*"];

activeTemporaryPath = "";
workerVersions = {};
launchedKernelCount = 0;

closeS13Kernels[] := Module[{},
  If[Length[Kernels[]] > 0, Quiet[CloseKernels[]]]
];

fatal[message_String] := (
  closeS13Kernels[];
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S13_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

workerRequire[condition_, payload_] :=
  If[! TrueQ[condition], Throw[payload, "S13WorkerFailure"]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

allNestedValues[association_Association] :=
  Flatten[Map[Values, Values[association]], 1];

allChecksTrueQ[checks_] := TrueQ[
  AssociationQ[checks] && And @@ (TrueQ /@ Values[checks])
];

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

symbolSet[expression_] := DeleteDuplicates@Cases[
  expression,
  _Symbol,
  {0, Infinity},
  Heads -> True
];

pairToAction[
    pair_Association, structureFunction_String, chargeKey_String,
    interval_List
  ] :=
  pair["Endpoint"] *
      S13ConvolutionTest[structureFunction, chargeKey, 0] +
    Inactive[Integrate][
      pair["IntegrandPhiS"] *
          S13ConvolutionTest[
            structureFunction, chargeKey, First[interval]
          ] +
        pair["IntegrandPhi0"] *
          S13ConvolutionTest[structureFunction, chargeKey, 0],
      interval
    ];

singleExactIntegralOnIntervalQ[action_, interval_List] := Module[
  {integrals},
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, _List]],
    {0, Infinity}
  ];
  TrueQ[
    Length[integrals] === 1 && integrals[[1, 2]] === interval
  ]
];

matchingS13TestOnlyQ[
    action_, structureFunction_String, chargeKey_String
  ] := TrueQ[
  DeleteDuplicates@Cases[
    action,
    HoldPattern[S13ConvolutionTest[label_, key_, _]] :> {label, key},
    {0, Infinity}
  ] === {{structureFunction, chargeKey}}
];

zeroPoleLedgerQ[ledger_] := TrueQ[
  AssociationQ[ledger] &&
    And @@ Flatten@Table[
      AssociationQ[ledger[projector][chargeKey][poleOrder]] &&
        And @@ Table[
          TrueQ[
            ledger[projector][chargeKey][poleOrder][field] === 0
          ],
          {field, pairFields}
        ],
      {projector, projectorKeys},
      {chargeKey, chargeKeys},
      {poleOrder, {"Minus2", "Minus1"}}
    ]
];

zeroSingleCachePoleLedgerQ[ledger_] := TrueQ[
  AssociationQ[ledger] &&
    And @@ Flatten@Table[
      TrueQ[ledger[poleOrder][field] === 0],
      {poleOrder, {"Minus2", "Minus1"}},
      {field, pairFields}
    ]
];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeSucceeded, renameResult, finalReload},
  assert[
    ! FileExistsQ[finalPath],
    "Atomic destination already exists: " <> finalPath
  ];
  activeTemporaryPath =
    finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "Atomic temporary path already exists: " <> activeTemporaryPath
  ];
  writeSucceeded = Quiet@Check[
    Put[expression, activeTemporaryPath]; True,
    False
  ];
  If[
    ! TrueQ[writeSucceeded] || ! FileExistsQ[activeTemporaryPath] ||
      FileByteCount[activeTemporaryPath] <= 0,
    fatal["Atomic temporary write failed for " <> finalPath <> "."]
  ];
  renameResult = Quiet@Check[
    RenameFile[activeTemporaryPath, finalPath],
    $Failed
  ];
  activeTemporaryPath = "";
  If[
    renameResult === $Failed || ! FileExistsQ[finalPath] ||
      FileByteCount[finalPath] <= 0,
    fatal["Atomic rename failed for " <> finalPath <> "."]
  ];
  finalReload = Quiet@Check[Get[finalPath], $Failed];
  If[
    ! TrueQ[
      AssociationQ[finalReload] &&
        finalReload["Status"] === "Complete" &&
        finalReload["Stage"] === expectedStage &&
        finalReload === expression
    ],
    If[FileExistsQ[finalPath], Quiet[DeleteFile[finalPath]]];
    fatal["Atomic final exact-reload gate failed for " <> finalPath <> "."]
  ];
  finalReload
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s12SourcePath = FileNameJoin[{
  scriptDirectory, "s12_combine_factorization_hqqprime.wl"
}];
s12ResultPath = FileNameJoin[{scriptDirectory, "s12_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s13_result"}];

stageVersion = "HqqprimeS13-v1";
cacheStageVersion = "HqqprimeS13Cache-v1";
sourceStageVersion = "HqqprimeS12-v1";
sourceCacheStageVersion = "HqqprimeS12Cache-v1";
resultSchemaVersion = 1;
projectorKeys = {"Pg", "PPP"};
structureFunctions = {"F1Hat", "F2Hat"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};

parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = Length[chargeKeys];

preflightOnly = TrueQ[
  Quiet@Check[Environment["HQQPRIME_S13_PREFLIGHT_ONLY"], ""] === "1"
];

expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS12SourceSHA256 =
  "e66cb95ce187146e7c5c356b0fd0b12e0c59202c31c38418dc21aa1662ecb76e";
expectedS12ResultSHA256 =
  "c7ba66cf0bb12cd77822d3831dbcf3e0ff64a1be18b28f040df6caf12ee19dbf";

chargeFileTokens = <|
  "IncomingChargeSquared" -> "incoming_charge_squared",
  "PrimeChargeSquared" -> "prime_charge_squared",
  "MixedIncomingPrimeCharge" -> "mixed_incoming_prime_charge"
|>;

expectedS12CacheSHA256 = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "f02f3c2868d86013d11d75a3faa4d64441b2b092a02f12951d59d4546e583073",
    "PrimeChargeSquared" ->
      "5fdab81e9aba825f637f7f207707b33f2d2e1bbdde688ad43c63538e4adba5a7",
    "MixedIncomingPrimeCharge" ->
      "283246c13375c77a52da2351e18febe57a13593b79b9038478118f650ac64b02"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "3556a2da658e3b856302890412db5bad11fd8c1b37b77144749b728ec0f5472e",
    "PrimeChargeSquared" ->
      "961b388a5bde4b6edaea25bde101365e3aca53af9f63ba870a887495da78b558",
    "MixedIncomingPrimeCharge" ->
      "3329786307d17486a62f0ce0a887797f1b2ddfcd869bec06028030ff6d19d504"
  |>
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

s13CachePaths = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[chargeKey,
        FileNameJoin[{
          scriptDirectory,
          "s13_cache_hqqprime_" <> chargeFileTokens[chargeKey] <> "_" <>
            ToLowerCase[structureFunction]
        }]
      ],
      chargeKeys
    ]
  ],
  structureFunctions
];

programSHA256 = fileSHA256[programPath];

inputForbiddenPattern =
  epsilon | _SeriesData | S11SEpsilon | _S10ConvolutionTest |
    _S11ConvolutionTest | _S11PlusDistribution |
    _S09EndpointValue | _S09PlusDistribution |
    _S09RegularEndpointFunction | _S09ExpandedKernelReference |
    _DiracDelta | FeynCalc`SUNN | FeynCalc`CF | FeynCalc`TF |
    _Real | $Failed | Indeterminate | ComplexInfinity |
    DirectedInfinity[_] | Power[0, _?Negative] | _Re | _Im |
    _Conjugate;

outputForbiddenPattern =
  epsilon | _SeriesData | S11SEpsilon | _S10ConvolutionTest |
    _S11ConvolutionTest | _S11PlusDistribution |
    _S09EndpointValue | _S09PlusDistribution |
    _S09RegularEndpointFunction | _S09ExpandedKernelReference |
    _DiracDelta | FeynCalc`SUNN | FeynCalc`CF | FeynCalc`TF |
    _Real | $Failed | Indeterminate | ComplexInfinity |
    DirectedInfinity[_] | Power[0, _?Negative] | _Re | _Im |
    _Conjugate;

allOutputPaths = allNestedValues[s13CachePaths];

Print["S13_STAGE: validating exact accepted S12 handoff"];
assert[
  And @@ (
    FileExistsQ[#] && FileByteCount[#] > 0 & /@
      {paperPath, s12SourcePath, s12ResultPath}
  ),
  "A required paper/S12 input is absent or empty."
];
assert[
  fileSHA256[paperPath] === expectedPaperSHA256 &&
    fileSHA256[s12SourcePath] === expectedS12SourceSHA256 &&
    fileSHA256[s12ResultPath] === expectedS12ResultSHA256,
  "The paper or accepted S12 source/result hash changed."
];
assert[
  FileNames["s13_*.tmp.*", scriptDirectory] === {},
  "A stale S13 atomic temporary file exists."
];
assert[
  And @@ (! FileExistsQ[#] & /@ Append[allOutputPaths, resultPath]),
  "S13 requires an empty final cache/result inventory."
];

s12 = Quiet@Check[Get[s12ResultPath], $Failed];
inputResultBindingQ = TrueQ[
  AssociationQ[s12] &&
    s12["Status"] === "Complete" &&
    s12["Stage"] === sourceStageVersion &&
    s12["ResultSchemaVersion"] === 1 &&
    s12["Channel"] === "Hqqprime only" &&
    s12["ProgramPath"] === s12SourcePath &&
    s12["ProgramSHA256"] === expectedS12SourceSHA256 &&
    s12["ProjectorOrder"] === projectorKeys &&
    s12["ChargeKeyOrder"] === chargeKeys &&
    allChecksTrueQ[s12["Checks"]] &&
    s12["InputProvenance"]["AuthoritativePaperPath"] === paperPath &&
    s12["InputProvenance"]["AuthoritativePaperSHA256"] ===
      expectedPaperSHA256 &&
    s12["FiniteActionCaches"]["StageVersion"] ===
      sourceCacheStageVersion &&
    s12["FiniteActionCaches"]["Paths"] === s12CachePaths &&
    s12["FiniteActionCaches"]["SHA256"] ===
      expectedS12CacheSHA256 &&
    s12["FiniteActionCaches"]["FiniteCoefficientPairField"] ===
      "FiniteCoefficientPair" &&
    Keys[s12["BranchSummaries"]] === projectorKeys &&
    And @@ (
      Keys[s12["BranchSummaries"][#]] === chargeKeys & /@
        projectorKeys
    ) &&
    AssociationQ[s12["PhysicalMapping"]] &&
    AssociationQ[s12["PhysicalMapping"]["Residuals"]] &&
    And @@ (
      TrueQ[# === 0] & /@
        Values[s12["PhysicalMapping"]["Residuals"]]
    )
];
assert[
  inputResultBindingQ,
  "The accepted compact S12 result failed its schema/source/map gate."
];

inputCacheDiskBindingQ = TrueQ[
  And @@ Flatten@Table[
    FileExistsQ[s12CachePaths[projector][chargeKey]] &&
      FileByteCount[s12CachePaths[projector][chargeKey]] > 0 &&
      fileSHA256[s12CachePaths[projector][chargeKey]] ===
        expectedS12CacheSHA256[projector][chargeKey],
    {projector, projectorKeys},
    {chargeKey, chargeKeys}
  ]
];
assert[
  inputCacheDiskBindingQ,
  "At least one accepted S12 cache is absent, empty, or hash-changed."
];

s12PoleLedger = s12["PoleResidualsByProjectorChargeAndField"];
poleSafetyQ = zeroPoleLedgerQ[s12PoleLedger];
assert[
  poleSafetyQ,
  "An S12 projector/charge/action field has a nonzero stored pole."
];

physicalMapping = s12["PhysicalMapping"];
xHat = physicalMapping["XHat"];
s23Upper = physicalMapping["S23Upper"];
integrationInterval = {s23, 0, s23Upper};
assert[
  FreeQ[{xHat, integrationInterval}, _Real | $Failed] &&
    ! FreeQ[integrationInterval, s23],
  "The accepted S12 physical mapping is not exact and usable."
];

inheritedChargeBookkeeping = s12["Bookkeeping"]["Charge"];
inheritedScaleBookkeeping = s12["Bookkeeping"]["Scale"];
inheritedSymmetryBookkeeping = s12["Bookkeeping"]["Symmetry"];
inheritedVirtualBookkeeping =
  s12["Bookkeeping"]["VirtualContributionAtThisOrder"];
additionalMultiplicativeWeightAtS13 = Times @@ {};

bookkeepingInputQ = TrueQ[
  AssociationQ[inheritedChargeBookkeeping] &&
    inheritedChargeBookkeeping["SeparatedTensorKeys"] === chargeKeys &&
    inheritedChargeBookkeeping[
      "CoefficientTensorsRemainChargeFree"
    ] === True &&
    inheritedChargeBookkeeping[
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS12"
    ] === False &&
    AssociationQ[inheritedScaleBookkeeping] &&
    inheritedScaleBookkeeping[
      "PartonicPDForFFAdditionalMuEpsilon"
    ] === 0 &&
    inheritedScaleBookkeeping[
      "SeparateMSBarSEpsilonAppliedToS10"
    ] === False &&
    AssociationQ[inheritedSymmetryBookkeeping] &&
    inheritedSymmetryBookkeeping["FinalStateFactorInherited"] === 1 &&
    inheritedSymmetryBookkeeping[
      "AdditionalSymmetryOrFlavorMultiplicityAtS12"
    ] === 1 &&
    inheritedSymmetryBookkeeping[
      "NontrivialSymmetryFactorAppliedAtS12"
    ] === False &&
    additionalMultiplicativeWeightAtS13 === 1
];
assert[
  bookkeepingInputQ,
  "The accepted S12 charge/scale/symmetry bookkeeping changed."
];

expectedS12PairSHA256 = AssociationMap[
  Function[projector,
    AssociationMap[
      s12["BranchSummaries"][projector][#][
        "FiniteCoefficientPairSHA256"
      ] &,
      chargeKeys
    ]
  ],
  projectorKeys
];

Clear[s12];
ClearSystemCache[];

Print["S13_STAGE: deriving the paper Eq. (9) extraction with Wolfram"];
eq9DefinitionsD = <|
  "F1Hat" ->
    (-s13PgDummy/2 + 2 xHat^2 s13PPPDummy/Q2)/(1 - epsilon),
  "F2Hat" ->
    4 xHat^3 (3 - 2 epsilon) s13PPPDummy/
        (Q2 (1 - epsilon)) -
      xHat s13PgDummy/(1 - epsilon)
|>;
projectorDummies = <|
  "Pg" -> s13PgDummy,
  "PPP" -> s13PPPDummy
|>;

projectorWeightsD = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[projector,
        Together@Coefficient[
          Expand[eq9DefinitionsD[structureFunction]],
          projectorDummies[projector]
        ]
      ],
      projectorKeys
    ]
  ],
  structureFunctions
];

eq9DefinitionResiduals = AssociationMap[
  Function[structureFunction,
    Together[
      eq9DefinitionsD[structureFunction] -
        Total[
          projectorWeightsD[structureFunction][#] *
              projectorDummies[#] & /@
            projectorKeys
        ]
    ]
  ],
  structureFunctions
];
eq9DimensionalDerivationQ = TrueQ[
  And @@ (TrueQ[# === 0] & /@ Values[eq9DefinitionResiduals]) &&
    And @@ Flatten@Table[
      FreeQ[
        projectorWeightsD[structureFunction][projector],
        s13PgDummy | s13PPPDummy | _Real
      ],
      {structureFunction, structureFunctions},
      {projector, projectorKeys}
    ]
];
assert[
  eq9DimensionalDerivationQ,
  "Wolfram coefficient extraction failed to reconstruct paper Eq. (9)."
];

projectorWeights4D = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[projector,
        Together@Limit[
          projectorWeightsD[structureFunction][projector],
          epsilon -> 0
        ]
      ],
      projectorKeys
    ]
  ],
  structureFunctions
];

finiteWeightsQ = TrueQ[
  poleSafetyQ &&
    FreeQ[projectorWeights4D, epsilon | _Real | $Failed |
      Indeterminate | ComplexInfinity | DirectedInfinity[_]]
];
assert[
  finiteWeightsQ,
  "The Eq. (9) finite-weight limit failed after the S12 pole gate."
];

weightMatrix4D = Table[
  projectorWeights4D[structureFunction][projector],
  {structureFunction, structureFunctions},
  {projector, projectorKeys}
];
weightMatrixDeterminant = Together[Det[weightMatrix4D]];
weightMatrixInvertibleQ = TrueQ[
  PossibleZeroQ[weightMatrixDeterminant] === False
];
assert[
  weightMatrixInvertibleQ,
  "Wolfram did not establish a nonzero Eq. (9) determinant."
];

inverseWeightMatrix4D = Map[
  Together,
  Inverse[weightMatrix4D],
  {2}
];
leftInverseResidual = Map[
  Together,
  inverseWeightMatrix4D . weightMatrix4D -
    IdentityMatrix[Length[projectorKeys]],
  {2}
];
rightInverseResidual = Map[
  Together,
  weightMatrix4D . inverseWeightMatrix4D -
    IdentityMatrix[Length[structureFunctions]],
  {2}
];
dummyProjectorVector = projectorDummies /@ projectorKeys;
dummyReconstructionResidual = Together /@ (
  inverseWeightMatrix4D .
      (weightMatrix4D . dummyProjectorVector) -
    dummyProjectorVector
);
matrixInversionQ = TrueQ[
  And @@ (TrueQ[# === 0] & /@ Flatten[leftInverseResidual]) &&
    And @@ (TrueQ[# === 0] & /@ Flatten[rightInverseResidual]) &&
    And @@ (TrueQ[# === 0] & /@ dummyReconstructionResidual)
];
assert[
  matrixInversionQ,
  "The Wolfram-derived Eq. (9) matrix failed exact inverse identities."
];

validateS12CacheWorker[
    cache_, projector_String, task_Association
  ] := Module[{pair, requiredKeys, validQ},
  requiredKeys = {
    "Status", "Stage", "ResultSchemaVersion", "Channel",
    "Projector", "ChargeKey", "ProgramSHA256", "PaperSHA256",
    "PoleResiduals", "FiniteCoefficientPair",
    "FiniteCoefficientPairSHA256", "Bookkeeping", "Checks"
  };
  workerRequire[
    AssociationQ[cache] &&
      And @@ (KeyExistsQ[cache, #] & /@ requiredKeys),
    <|
      "Message" -> "S12 cache schema keys are absent.",
      "Projector" -> projector,
      "ChargeKey" -> task["ChargeKey"]
    |>
  ];
  pair = cache["FiniteCoefficientPair"];
  validQ = TrueQ[
    cache["Status"] === "Complete" &&
      cache["Stage"] === sourceCacheStageVersion &&
      cache["ResultSchemaVersion"] === 1 &&
      cache["Channel"] === "Hqqprime only" &&
      cache["Projector"] === projector &&
      cache["ChargeKey"] === task["ChargeKey"] &&
      cache["ProgramSHA256"] === expectedS12SourceSHA256 &&
      cache["PaperSHA256"] === expectedPaperSHA256 &&
      zeroSingleCachePoleLedgerQ[cache["PoleResiduals"]] &&
      AssociationQ[pair] && Keys[pair] === pairFields &&
      cache["FiniteCoefficientPairSHA256"] ===
        task["PairSHA256"][projector] &&
      cache["FiniteCoefficientPairSHA256"] ===
        expressionSHA256[pair] &&
      TrueQ[pair["Endpoint"] === 0] &&
      ! TrueQ[pair["IntegrandPhiS"] === 0] &&
      TrueQ[pair["IntegrandPhi0"] === 0] &&
      FreeQ[pair, inputForbiddenPattern] &&
      feynCalcContextCleanQ[pair] &&
      allChecksTrueQ[cache["Checks"]] &&
      AssociationQ[cache["Bookkeeping"]] &&
      cache["Bookkeeping"][
        "AdditionalMultiplicativeWeightAtS12"
      ] === 1 &&
      cache["Bookkeeping"]["SeparatedChargeTensorKeys"] ===
        chargeKeys &&
      cache["Bookkeeping"][
        "PhysicalOrderedFlavorChargeAssemblyApplied"
      ] === False &&
      cache["Bookkeeping"]["FinalStateSymmetryFactorInherited"] === 1 &&
      cache["Bookkeeping"][
        "NontrivialSymmetryFactorAppliedAtS12"
      ] === False &&
      cache["Bookkeeping"]["VirtualContributionAtThisOrder"] ===
        task["InheritedVirtualBookkeeping"]
  ];
  workerRequire[
    validQ,
    <|
      "Message" -> "Accepted S12 cache validation failed.",
      "Projector" -> projector,
      "ChargeKey" -> task["ChargeKey"]
    |>
  ];
  pair
];

buildS13CacheWorker[
    task_Association, structureFunction_String,
    sourcePairs_Association
  ] := Module[
  {
    chargeKey, weightsD, weights4D, pair, action,
    inputAndWeightSymbols, actionAllowedSymbols, checks,
    pairConstructionQ, actionConstructionQ, pairSymbolProvenanceQ,
    actionSymbolProvenanceQ
  },
  chargeKey = task["ChargeKey"];
  weightsD = projectorWeightsD[structureFunction];
  weights4D = projectorWeights4D[structureFunction];
  pair = AssociationMap[
    Function[field,
      weights4D["Pg"] * sourcePairs["Pg"][field] +
        weights4D["PPP"] * sourcePairs["PPP"][field]
    ],
    pairFields
  ];
  action = pairToAction[
    pair, structureFunction, chargeKey, task["IntegrationInterval"]
  ];
  pairConstructionQ = TrueQ[
    And @@ Table[
      pair[field] ===
        weights4D["Pg"] * sourcePairs["Pg"][field] +
          weights4D["PPP"] * sourcePairs["PPP"][field],
      {field, pairFields}
    ]
  ];
  actionConstructionQ = TrueQ[
    action === pairToAction[
      pair, structureFunction, chargeKey, task["IntegrationInterval"]
    ]
  ];
  inputAndWeightSymbols = symbolSet[{sourcePairs, weightsD, weights4D}];
  pairSymbolProvenanceQ = TrueQ[
    Complement[symbolSet[pair], inputAndWeightSymbols] === {}
  ];
  actionAllowedSymbols = Union[
    symbolSet[pair],
    {S13ConvolutionTest, Inactive, Integrate, List}
  ];
  actionSymbolProvenanceQ = TrueQ[
    Complement[symbolSet[action], actionAllowedSymbols] === {}
  ];
  checks = <|
    "AcceptedS12CacheSchemasHashesPolesAndBookkeepingValidated" -> True,
    "StructureFunctionAndChargeOrdersPreserved" -> TrueQ[
      MemberQ[structureFunctions, structureFunction] &&
        MemberQ[chargeKeys, chargeKey]
    ],
    "DimensionalAndFiniteWeightsWolframDerived" -> TrueQ[
      AssociationQ[weightsD] && Keys[weightsD] === projectorKeys &&
        AssociationQ[weights4D] && Keys[weights4D] === projectorKeys &&
        FreeQ[weights4D, epsilon | _Real]
    ],
    "PairDerivedFieldwiseFromPgAndPPP" -> pairConstructionQ,
    "PairFieldSchemaExact" -> TrueQ[Keys[pair] === pairFields],
    "EndpointAndPhi0ExactZero" -> TrueQ[
      pair["Endpoint"] === 0 && pair["IntegrandPhi0"] === 0
    ],
    "IntegrandPhiSNonzero" -> ! TrueQ[
      pair["IntegrandPhiS"] === 0
    ],
    "PairExactForbiddenObjectAndContextClean" -> TrueQ[
      FreeQ[pair, outputForbiddenPattern | _S13ConvolutionTest] &&
        feynCalcContextCleanQ[pair]
    ],
    "ActionExactlyRebuiltFromPair" -> actionConstructionQ,
    "ActionRetainsOneExactPhysicalIntegral" ->
      singleExactIntegralOnIntervalQ[
        action, task["IntegrationInterval"]
      ],
    "ActionRetainsOnlyMatchingS13Test" ->
      matchingS13TestOnlyQ[action, structureFunction, chargeKey],
    "ActionExactForbiddenObjectAndContextClean" -> TrueQ[
      FreeQ[action, outputForbiddenPattern] &&
        feynCalcContextCleanQ[action]
    ],
    "NoHermitianOperationIntroduced" -> TrueQ[
      FreeQ[{pair, action}, _Re | _Im | _Conjugate]
    ],
    "NoUnboundSymbolIncludingPhysicalChargeIntroduced" -> TrueQ[
      pairSymbolProvenanceQ && actionSymbolProvenanceQ
    ],
    "NoNewScaleMSbarColorSymmetryOrVirtualFactorIntroduced" ->
      pairConstructionQ
  |>;
  workerRequire[
    allChecksTrueQ[checks],
    <|
      "Message" -> "A final S13 branch check failed.",
      "StructureFunction" -> structureFunction,
      "ChargeKey" -> chargeKey,
      "FailedChecks" -> Select[checks, ! TrueQ[#] &]
    |>
  ];
  <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "ResultSchemaVersion" -> resultSchemaVersion,
    "Channel" -> "Hqqprime only",
    "StructureFunction" -> structureFunction,
    "ChargeKey" -> chargeKey,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperSHA256,
    "S12SourcePath" -> s12SourcePath,
    "S12SourceSHA256" -> expectedS12SourceSHA256,
    "S12ResultPath" -> s12ResultPath,
    "S12ResultSHA256" -> expectedS12ResultSHA256,
    "S12InputCaches" -> <|
      "Paths" -> task["CachePaths"],
      "SHA256" -> task["CacheSHA256"],
      "FiniteCoefficientPairSHA256" -> task["PairSHA256"]
    |>,
    "ProjectorOrder" -> projectorKeys,
    "DimensionalProjectorWeights" -> weightsD,
    "FiniteProjectorWeights" -> weights4D,
    "PhysicalMapping" -> task["PhysicalMapping"],
    "IntegrationInterval" -> task["IntegrationInterval"],
    "FiniteCoefficientPair" -> pair,
    "FiniteCoefficientPairSHA256" -> expressionSHA256[pair],
    "FiniteCoefficientPairLeafCount" -> LeafCount[pair],
    "FiniteCoefficientPairByteCount" -> ByteCount[pair],
    "FiniteHattedAction" -> action,
    "FiniteHattedActionSHA256" -> expressionSHA256[action],
    "FiniteHattedActionLeafCount" -> LeafCount[action],
    "FiniteHattedActionByteCount" -> ByteCount[action],
    "Bookkeeping" -> <|
      "AdditionalMultiplicativeWeightAtS13" ->
        additionalMultiplicativeWeightAtS13,
      "SeparatedChargeTensorKeys" -> chargeKeys,
      "PhysicalOrderedFlavorChargeAssemblyApplied" -> False,
      "ChargeBookkeepingInheritedFromS12" ->
        task["InheritedChargeBookkeeping"],
      "ScaleBookkeepingInheritedFromS12" ->
        task["InheritedScaleBookkeeping"],
      "SymmetryBookkeepingInheritedFromS12" ->
        task["InheritedSymmetryBookkeeping"],
      "VirtualContributionAtThisOrder" ->
        task["InheritedVirtualBookkeeping"],
      "HermitianProjectionAppliedAtS13" -> False
    |>,
    "Checks" -> checks
  |>
];

processChargeTask[task_Association] := Module[
  {caught, sourcePairs, records},
  caught = Catch[
    sourcePairs = AssociationMap[
      Function[projector,
        validateS12CacheWorker[
          Quiet@Check[Get[task["CachePaths"][projector]], $Failed],
          projector,
          task
        ]
      ],
      projectorKeys
    ];
    records = AssociationMap[
      buildS13CacheWorker[task, #, sourcePairs] &,
      structureFunctions
    ];
    Clear[sourcePairs];
    <|
      "Success" -> True,
      "ChargeKey" -> task["ChargeKey"],
      "WorkerKernelID" -> $KernelID,
      "Records" -> records
    |>,
    "S13WorkerFailure"
  ];
  If[
    AssociationQ[caught] && TrueQ[Lookup[caught, "Success", False]],
    caught,
    <|
      "Success" -> False,
      "ChargeKey" -> Lookup[task, "ChargeKey", "Unknown"],
      "WorkerKernelID" -> $KernelID,
      "Failure" -> caught
    |>
  ]
];

launchS13Kernels[kernelCount_Integer] := Module[
  {localCandidates, configuration, launched},
  closeS13Kernels[];
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
    workerRequire, expressionSHA256, allChecksTrueQ,
    accidentalGlobalFeynCalcSymbolQ, feynCalcContextCleanQ,
    symbolSet, pairToAction, singleExactIntegralOnIntervalQ,
    matchingS13TestOnlyQ, zeroSingleCachePoleLedgerQ,
    validateS12CacheWorker, buildS13CacheWorker, processChargeTask,
    inputForbiddenPattern, outputForbiddenPattern,
    feynCalcOwnedSymbolNames, stageVersion, cacheStageVersion,
    sourceCacheStageVersion, resultSchemaVersion, projectorKeys,
    structureFunctions, chargeKeys, pairFields, projectorWeightsD,
    projectorWeights4D, additionalMultiplicativeWeightAtS13,
    programPath, programSHA256, paperPath, s12SourcePath,
    s12ResultPath, expectedPaperSHA256, expectedS12SourceSHA256,
    expectedS12ResultSHA256, S09EndpointValue,
    S09PlusDistribution, S09RegularEndpointFunction,
    S09ExpandedKernelReference, S10ConvolutionTest,
    S11ConvolutionTest, S11PlusDistribution, S11SEpsilon,
    S13ConvolutionTest
  ];
  True
];

validS13CachePayloadQ[
    payload_, structureFunction_String, chargeKey_String
  ] := TrueQ[
  AssociationQ[payload] &&
    payload["Status"] === "Complete" &&
    payload["Stage"] === cacheStageVersion &&
    payload["ResultSchemaVersion"] === resultSchemaVersion &&
    payload["Channel"] === "Hqqprime only" &&
    payload["StructureFunction"] === structureFunction &&
    payload["ChargeKey"] === chargeKey &&
    payload["ProgramPath"] === programPath &&
    payload["ProgramSHA256"] === programSHA256 &&
    payload["PaperPath"] === paperPath &&
    payload["PaperSHA256"] === expectedPaperSHA256 &&
    payload["S12SourcePath"] === s12SourcePath &&
    payload["S12SourceSHA256"] === expectedS12SourceSHA256 &&
    payload["S12ResultPath"] === s12ResultPath &&
    payload["S12ResultSHA256"] === expectedS12ResultSHA256 &&
    payload["S12InputCaches"]["Paths"] ===
      AssociationMap[s12CachePaths[#][chargeKey] &, projectorKeys] &&
    payload["S12InputCaches"]["SHA256"] ===
      AssociationMap[
        expectedS12CacheSHA256[#][chargeKey] &,
        projectorKeys
      ] &&
    payload["S12InputCaches"]["FiniteCoefficientPairSHA256"] ===
      AssociationMap[
        expectedS12PairSHA256[#][chargeKey] &,
        projectorKeys
      ] &&
    payload["ProjectorOrder"] === projectorKeys &&
    payload["DimensionalProjectorWeights"] ===
      projectorWeightsD[structureFunction] &&
    payload["FiniteProjectorWeights"] ===
      projectorWeights4D[structureFunction] &&
    payload["PhysicalMapping"] === physicalMapping &&
    payload["IntegrationInterval"] === integrationInterval &&
    AssociationQ[payload["FiniteCoefficientPair"]] &&
    Keys[payload["FiniteCoefficientPair"]] === pairFields &&
    payload["FiniteCoefficientPairSHA256"] ===
      expressionSHA256[payload["FiniteCoefficientPair"]] &&
    payload["FiniteCoefficientPairLeafCount"] ===
      LeafCount[payload["FiniteCoefficientPair"]] &&
    payload["FiniteCoefficientPairByteCount"] ===
      ByteCount[payload["FiniteCoefficientPair"]] &&
    payload["FiniteHattedActionSHA256"] ===
      expressionSHA256[payload["FiniteHattedAction"]] &&
    payload["FiniteHattedActionLeafCount"] ===
      LeafCount[payload["FiniteHattedAction"]] &&
    payload["FiniteHattedActionByteCount"] ===
      ByteCount[payload["FiniteHattedAction"]] &&
    TrueQ[payload["FiniteCoefficientPair"]["Endpoint"] === 0] &&
    ! TrueQ[
      payload["FiniteCoefficientPair"]["IntegrandPhiS"] === 0
    ] &&
    TrueQ[payload["FiniteCoefficientPair"]["IntegrandPhi0"] === 0] &&
    FreeQ[
      payload["FiniteCoefficientPair"],
      outputForbiddenPattern | _S13ConvolutionTest
    ] &&
    FreeQ[payload["FiniteHattedAction"], outputForbiddenPattern] &&
    feynCalcContextCleanQ[{
      payload["FiniteCoefficientPair"],
      payload["FiniteHattedAction"]
    }] &&
    singleExactIntegralOnIntervalQ[
      payload["FiniteHattedAction"], integrationInterval
    ] &&
    matchingS13TestOnlyQ[
      payload["FiniteHattedAction"], structureFunction, chargeKey
    ] &&
    payload["Bookkeeping"]["AdditionalMultiplicativeWeightAtS13"] ===
      additionalMultiplicativeWeightAtS13 &&
    payload["Bookkeeping"]["SeparatedChargeTensorKeys"] === chargeKeys &&
    payload["Bookkeeping"][
      "PhysicalOrderedFlavorChargeAssemblyApplied"
    ] === False &&
    payload["Bookkeeping"]["ChargeBookkeepingInheritedFromS12"] ===
      inheritedChargeBookkeeping &&
    payload["Bookkeeping"]["ScaleBookkeepingInheritedFromS12"] ===
      inheritedScaleBookkeeping &&
    payload["Bookkeeping"]["SymmetryBookkeepingInheritedFromS12"] ===
      inheritedSymmetryBookkeeping &&
    payload["Bookkeeping"]["VirtualContributionAtThisOrder"] ===
      inheritedVirtualBookkeeping &&
    payload["Bookkeeping"]["HermitianProjectionAppliedAtS13"] === False &&
    allChecksTrueQ[payload["Checks"]]
];

chargeTasks = Table[
  <|
    "ChargeKey" -> chargeKey,
    "CachePaths" -> AssociationMap[
      s12CachePaths[#][chargeKey] &,
      projectorKeys
    ],
    "CacheSHA256" -> AssociationMap[
      expectedS12CacheSHA256[#][chargeKey] &,
      projectorKeys
    ],
    "PairSHA256" -> AssociationMap[
      expectedS12PairSHA256[#][chargeKey] &,
      projectorKeys
    ],
    "PhysicalMapping" -> physicalMapping,
    "IntegrationInterval" -> integrationInterval,
    "InheritedChargeBookkeeping" -> inheritedChargeBookkeeping,
    "InheritedScaleBookkeeping" -> inheritedScaleBookkeeping,
    "InheritedSymmetryBookkeeping" -> inheritedSymmetryBookkeeping,
    "InheritedVirtualBookkeeping" -> inheritedVirtualBookkeeping
  |>,
  {chargeKey, chargeKeys}
];

Print[
  "S13_STAGE: launching ", requestedParallelKernelCount,
  " Engine-15 charge workers"
];
launchS13Kernels[requestedParallelKernelCount];
chargeResults = Quiet@Check[
  ParallelMap[
    processChargeTask,
    chargeTasks,
    Method -> "CoarsestGrained"
  ],
  $Failed
];
closeS13Kernels[];

assert[
  ListQ[chargeResults] &&
    Length[chargeResults] === requestedParallelKernelCount &&
    And @@ (AssociationQ /@ chargeResults) &&
    And @@ (TrueQ[Lookup[#, "Success", False]] & /@ chargeResults),
  "At least one S13 charge worker failed: " <>
    ToString[
      InputForm[
        If[ListQ[chargeResults], Lookup[chargeResults, "Failure", None],
          chargeResults]
      ]
    ]
];
assert[
  Lookup[chargeResults, "ChargeKey"] === chargeKeys,
  "Charge-worker results returned in a nondeterministic order."
];
workerKernelIDs = Lookup[chargeResults, "WorkerKernelID"];
oneChargePerWorkerQ = TrueQ[
  Length[DeleteDuplicates[workerKernelIDs]] ===
    requestedParallelKernelCount
];
assert[
  oneChargePerWorkerQ,
  "The three independent charge tasks did not use three distinct workers."
];

workerOutputInventoryUntouchedQ = TrueQ[
  And @@ (! FileExistsQ[#] & /@ Append[allOutputPaths, resultPath]) &&
    FileNames["s13_*.tmp.*", scriptDirectory] === {}
];
assert[
  workerOutputInventoryUntouchedQ,
  "A read-only charge worker created an S13 output."
];

chargeResultByKey = AssociationThread[chargeKeys, chargeResults];
branchPayloads = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      chargeResultByKey[#]["Records"][structureFunction] &,
      chargeKeys
    ]
  ],
  structureFunctions
];

allReturnedPayloadsValidQ = TrueQ[
  And @@ Flatten@Table[
    validS13CachePayloadQ[
      branchPayloads[structureFunction][chargeKey],
      structureFunction,
      chargeKey
    ],
    {structureFunction, structureFunctions},
    {chargeKey, chargeKeys}
  ]
];
assert[
  allReturnedPayloadsValidQ,
  "A returned S13 cache payload failed main-kernel validation."
];

Print[
  If[preflightOnly,
    "S13_PREFLIGHT_STAGE: validating six payloads without writing",
    "S13_STAGE: atomically publishing six F-hat caches"
  ]
];

publishedPayloads = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[chargeKey,
        Module[{payload, published},
          payload = branchPayloads[structureFunction][chargeKey];
          published = If[
            preflightOnly,
            payload,
            atomicPutAssociation[
              payload,
              s13CachePaths[structureFunction][chargeKey],
              cacheStageVersion
            ]
          ];
          assert[
            validS13CachePayloadQ[
              published, structureFunction, chargeKey
            ],
            "A candidate/published S13 cache failed validation for " <>
              structureFunction <> "/" <> chargeKey <> "."
          ];
          Print[
            If[preflightOnly,
              "S13_PREFLIGHT_BRANCH_VALIDATED: ",
              "S13_CACHE_CHECKPOINT: "
            ],
            structureFunction, "/", chargeKey,
            If[
              preflightOnly,
              "",
              " sha256=" <>
                fileSHA256[
                  s13CachePaths[structureFunction][chargeKey]
                ]
            ]
          ];
          published
        ]
      ],
      chargeKeys
    ]
  ],
  structureFunctions
];

Clear[branchPayloads, chargeResultByKey, chargeResults];
ClearSystemCache[];

cacheDiskSHA256 = If[
  preflightOnly,
  AssociationMap[
    Function[structureFunction,
      AssociationMap[
        Function[chargeKey, Missing["PreflightNoDiskArtifact"]],
        chargeKeys
      ]
    ],
    structureFunctions
  ],
  AssociationMap[
    Function[structureFunction,
      AssociationMap[
        fileSHA256[s13CachePaths[structureFunction][#]] &,
        chargeKeys
      ]
    ],
    structureFunctions
  ]
];

branchSummaries = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[chargeKey,
        With[{payload = publishedPayloads[structureFunction][chargeKey]},
          <|
            "S12InputFiniteCoefficientPairSHA256" ->
              payload["S12InputCaches"][
                "FiniteCoefficientPairSHA256"
              ],
            "FiniteProjectorWeights" ->
              payload["FiniteProjectorWeights"],
            "FiniteCoefficientPairSHA256" ->
              payload["FiniteCoefficientPairSHA256"],
            "FiniteCoefficientPairLeafCount" ->
              payload["FiniteCoefficientPairLeafCount"],
            "FiniteCoefficientPairByteCount" ->
              payload["FiniteCoefficientPairByteCount"],
            "FiniteHattedActionSHA256" ->
              payload["FiniteHattedActionSHA256"],
            "FiniteHattedActionLeafCount" ->
              payload["FiniteHattedActionLeafCount"],
            "FiniteHattedActionByteCount" ->
              payload["FiniteHattedActionByteCount"],
            "CheckCount" -> Length[payload["Checks"]],
            "AllChecksTrue" -> allChecksTrueQ[payload["Checks"]]
          |>
        ]
      ],
      chargeKeys
    ]
  ],
  structureFunctions
];

allPublishedPayloadsValidQ = TrueQ[
  And @@ Flatten@Table[
    validS13CachePayloadQ[
      publishedPayloads[structureFunction][chargeKey],
      structureFunction,
      chargeKey
    ],
    {structureFunction, structureFunctions},
    {chargeKey, chargeKeys}
  ]
];

Clear[publishedPayloads];
ClearSystemCache[];

s13ChecksBase = <|
  "ExactPaperS12SourceResultAndSixCachesPinned" -> TrueQ[
    inputResultBindingQ && inputCacheDiskBindingQ
  ],
  "FeynCalcLoadedBeforeS12Deserialization" -> True,
  "AllS12PoleFieldsExactZeroBeforeFiniteLimit" -> poleSafetyQ,
  "PaperEq9DefinitionsReconstructedFromWolframCoefficients" ->
    eq9DimensionalDerivationQ,
  "FiniteEq9WeightsDerivedOnlyAfterPoleGate" -> finiteWeightsQ,
  "Eq9WeightMatrixDeterminantAndInverseToolValidated" -> TrueQ[
    weightMatrixInvertibleQ && matrixInversionQ
  ],
  "ProjectorStructureFunctionAndChargeOrdersPreserved" -> TrueQ[
    projectorKeys === {"Pg", "PPP"} &&
      structureFunctions === {"F1Hat", "F2Hat"} &&
      chargeKeys === Keys[chargeFileTokens]
  ],
  "AcceptedPhysicalMappingAndIntervalRetained" -> TrueQ[
    AssociationQ[physicalMapping] &&
      integrationInterval === {s23, 0, s23Upper}
  ],
  "AllSixCandidateOrPublishedCachesValidated" ->
    allPublishedPayloadsValidQ,
  "ChargeTensorsRemainSeparateAndPhysicalAssemblyDeferred" -> TrueQ[
    inheritedChargeBookkeeping["SeparatedTensorKeys"] === chargeKeys &&
      inheritedChargeBookkeeping[
        "PhysicalOrderedFlavorChargeAssemblyAppliedAtS12"
      ] === False
  ],
  "ScaleSymmetryColorAndVirtualBookkeepingOnlyInherited" ->
    bookkeepingInputQ,
  "AdditionalMultiplicativeWeightAtS13IsToolDerivedUnity" -> TrueQ[
    additionalMultiplicativeWeightAtS13 === 1
  ],
  "ExactlyThreeEngine15ChargeWorkersUsedOnceEach" -> TrueQ[
    launchedKernelCount === requestedParallelKernelCount &&
      Length[workerVersions] === requestedParallelKernelCount &&
      oneChargePerWorkerQ
  ],
  "WorkersReturnedDeterministicOrderAndWroteNothing" -> TrueQ[
    workerOutputInventoryUntouchedQ
  ],
  "OnlyMainKernelPublishesWithAtomicExactReload" -> True,
  "OuterConvolutionPhysicalAssemblyComparisonAndNumericsDeferred" -> True
|>;
assert[
  allChecksTrueQ[s13ChecksBase],
  "At least one compact S13 result check failed before construction."
];

s13ResultBase = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "finite Eq. (9)-extracted charge-resolved F1Hat/F2Hat actions for H_{q qPrime; q qbarPrime}",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ProjectorOrder" -> projectorKeys,
  "StructureFunctionOrder" -> structureFunctions,
  "ChargeKeyOrder" -> chargeKeys,
  "InputProvenance" -> <|
    "AuthoritativePaperPath" -> paperPath,
    "AuthoritativePaperSHA256" -> expectedPaperSHA256,
    "S12SourcePath" -> s12SourcePath,
    "S12SourceSHA256" -> expectedS12SourceSHA256,
    "S12ResultPath" -> s12ResultPath,
    "S12ResultSHA256" -> expectedS12ResultSHA256,
    "S12CachePaths" -> s12CachePaths,
    "S12CacheSHA256" -> expectedS12CacheSHA256,
    "S12FiniteCoefficientPairSHA256" -> expectedS12PairSHA256
  |>,
  "PaperReference" -> <|
    "HadronicTensorDecomposition" -> "Eq. (5)",
    "ExtractionTensors" -> "Eqs. (7)-(9)",
    "PartonicTensorDecomposition" -> "Eq. (16)",
    "HadronicConvolution" -> "Eqs. (17)-(18), deferred"
  |>,
  "PoleSafetyForFiniteExtraction" -> <|
    "AllS12ProjectorChargeFieldPolesExactZero" -> poleSafetyQ,
    "S12PoleLedgerSHA256" -> expressionSHA256[s12PoleLedger],
    "EpsilonLimitAppliedAfterPoleGate" -> True
  |>,
  "Eq9Extraction" -> <|
    "DimensionalDefinitions" -> eq9DefinitionsD,
    "DimensionalProjectorWeights" -> projectorWeightsD,
    "DimensionalDefinitionResiduals" -> eq9DefinitionResiduals,
    "FiniteProjectorWeights" -> projectorWeights4D,
    "FiniteWeightMatrix" -> weightMatrix4D,
    "FiniteWeightMatrixDeterminant" -> weightMatrixDeterminant,
    "InverseFiniteWeightMatrix" -> inverseWeightMatrix4D,
    "LeftInverseResidual" -> leftInverseResidual,
    "RightInverseResidual" -> rightInverseResidual,
    "DummyReconstructionResidual" -> dummyReconstructionResidual
  |>,
  "PhysicalMapping" -> <|
    "AcceptedS12Mapping" -> physicalMapping,
    "IntegrationInterval" -> integrationInterval
  |>,
  "FiniteActionCaches" -> <|
    "StageVersion" -> cacheStageVersion,
    "Paths" -> s13CachePaths,
    "SHA256" -> cacheDiskSHA256,
    "FiniteCoefficientPairField" -> "FiniteCoefficientPair",
    "FiniteHattedActionField" -> "FiniteHattedAction",
    "ProgramSHA256" -> programSHA256,
    "StructureFunctionFirstChargeSecondOrder" -> True,
    "AtomicMainWriterExactReloadValidated" -> ! preflightOnly
  |>,
  "BranchSummaries" -> branchSummaries,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS13" ->
      additionalMultiplicativeWeightAtS13,
    "ChargeInheritedFromS12" -> inheritedChargeBookkeeping,
    "ScaleInheritedFromS12" -> inheritedScaleBookkeeping,
    "SymmetryInheritedFromS12" -> inheritedSymmetryBookkeeping,
    "VirtualContributionAtThisOrder" ->
      inheritedVirtualBookkeeping,
    "PhysicalOrderedFlavorChargeAssemblyAppliedAtS13" -> False,
    "NewMSbarScaleColorChargeOrSymmetryFactorAppliedAtS13" -> False,
    "HermitianProjectionAppliedAtS13" -> False
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> launchedKernelCount,
    "WorkerVersions" -> workerVersions,
    "WorkerKernelIDs" -> workerKernelIDs,
    "OneChargeKeyPerWorker" -> oneChargePerWorkerQ,
    "StructureFunctionsSerialWithinEachChargeWorker" ->
      structureFunctions,
    "ConcurrentCacheWrites" -> False,
    "DeterministicResultOrder" -> True
  |>,
  "MemoryStrategy" ->
    "three read-only charge workers load Pg/PPP pairs and form F1Hat then F2Hat serially; only the main kernel atomically writes six caches and the compact result",
  "NotPerformedAtThisStage" -> {
    "outer xi convolution",
    "physical ordered q,qPrime!=q flavour/charge assembly",
    "PDF or fragmentation-function insertion",
    "other-channel assembly",
    "external-code comparison",
    "numerical kinematics"
  },
  "DownstreamInstruction" ->
    "Load FeynCalc, verify this compact result and six hash-pinned HqqprimeS13Cache-v1 payloads in structure-function-first/charge-second order, and keep charge tensors separate until the explicitly authorized physical ordered-flavour assembly."
|>;

compactResultQ = TrueQ[
  FreeQ[
    s13ResultBase,
    HoldPattern[Rule["FiniteCoefficientPair", _]] |
      HoldPattern[Rule["FiniteHattedAction", _]]
  ]
];
s13Checks = Join[
  s13ChecksBase,
  <|"CompactResultDoesNotDuplicateFinitePayloads" -> compactResultQ|>
];
s13Result = Join[s13ResultBase, <|"Checks" -> s13Checks|>];

validS13ResultQ[result_, expectedCacheSHA256_Association] := TrueQ[
  AssociationQ[result] &&
    result["Status"] === "Complete" &&
    result["Stage"] === stageVersion &&
    result["ResultSchemaVersion"] === resultSchemaVersion &&
    result["Channel"] === "Hqqprime only" &&
    result["ProgramPath"] === programPath &&
    result["ProgramSHA256"] === programSHA256 &&
    result["ProjectorOrder"] === projectorKeys &&
    result["StructureFunctionOrder"] === structureFunctions &&
    result["ChargeKeyOrder"] === chargeKeys &&
    result["InputProvenance"]["AuthoritativePaperSHA256"] ===
      expectedPaperSHA256 &&
    result["InputProvenance"]["S12SourceSHA256"] ===
      expectedS12SourceSHA256 &&
    result["InputProvenance"]["S12ResultSHA256"] ===
      expectedS12ResultSHA256 &&
    result["InputProvenance"]["S12CachePaths"] === s12CachePaths &&
    result["InputProvenance"]["S12CacheSHA256"] ===
      expectedS12CacheSHA256 &&
    result["InputProvenance"]["S12FiniteCoefficientPairSHA256"] ===
      expectedS12PairSHA256 &&
    result["Eq9Extraction"]["DimensionalDefinitionResiduals"] ===
      eq9DefinitionResiduals &&
    result["Eq9Extraction"]["FiniteProjectorWeights"] ===
      projectorWeights4D &&
    result["Eq9Extraction"]["FiniteWeightMatrix"] ===
      weightMatrix4D &&
    result["Eq9Extraction"]["InverseFiniteWeightMatrix"] ===
      inverseWeightMatrix4D &&
    result["FiniteActionCaches"]["Paths"] === s13CachePaths &&
    result["FiniteActionCaches"]["SHA256"] ===
      expectedCacheSHA256 &&
    result["BranchSummaries"] === branchSummaries &&
    result["Bookkeeping"][
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS13"
    ] === False &&
    result["Bookkeeping"][
      "NewMSbarScaleColorChargeOrSymmetryFactorAppliedAtS13"
    ] === False &&
    allChecksTrueQ[result["Checks"]] &&
    FreeQ[
      result,
      HoldPattern[Rule["FiniteCoefficientPair", _]] |
        HoldPattern[Rule["FiniteHattedAction", _]]
    ]
];

assert[
  compactResultQ && allChecksTrueQ[s13Checks] &&
    validS13ResultQ[s13Result, cacheDiskSHA256],
  "The compact S13 result candidate failed validation."
];

If[preflightOnly,
  assert[
    And @@ (! FileExistsQ[#] & /@ Append[allOutputPaths, resultPath]) &&
      FileNames["s13_*.tmp.*", scriptDirectory] === {},
    "The no-write S13 preflight changed the output inventory."
  ];
  Print[
    "S13_PREFLIGHT_BRANCH_SUMMARIES=",
    InputForm[branchSummaries]
  ];
  Print["S13_PREFLIGHT_SUCCESS_NO_WRITE"];
  Quit[0]
];

Print["S13_STAGE: atomically publishing compact s13_result"];
reloadedResult = atomicPutAssociation[
  s13Result, resultPath, stageVersion
];
assert[
  validS13ResultQ[reloadedResult, cacheDiskSHA256] &&
    reloadedResult === s13Result,
  "The published compact S13 result failed embedded validation."
];
Clear[reloadedResult];

assert[
  And @@ (
    FileExistsQ[#] && FileByteCount[#] > 0 & /@
      Append[allOutputPaths, resultPath]
  ) && FileNames["s13_*.tmp.*", scriptDirectory] === {},
  "The final S13 inventory is incomplete or contains a temporary file."
];

Print["S13_RESULT_SHA256=", fileSHA256[resultPath]];
Print["S13_CACHE_SHA256=", InputForm[cacheDiskSHA256]];
Print["S13_SUCCESS_FINITE_FHAT_HQQPRIME"];
Quit[0];

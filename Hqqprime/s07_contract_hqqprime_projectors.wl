(* ::Package:: *)

(*
  Hqqprime S07: contract each separately retained, spin/color-averaged S06
  charge tensor with the two paper extraction tensors

    P_g^(mu nu)  = g^(mu nu),
    P_PP^(mu nu) = p^mu p^nu,

  where p is the incoming parton momentum in the partonic decomposition.
  The six outputs remain exact, D-dimensional, charge-resolved, scalar, and
  unintegrated.  This stage does not form Eq. (9) F1/F2 combinations and adds
  no phase space, flavor assembly, symmetry factor, virtual term, or
  factorization operation.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, expressionSHA256, atomicPutAssociation,
  closeS07Kernels, hasExactlyExpectedScaleQ, scalarProjectionValidQ,
  validateInputTensor, validateScalarProjection, setThreeBodyKinematics,
  deriveWardPoint, cacheMetadataValidQ, loadValidatedCache, writeCache,
  processChargeTask, launchS07Kernels, runOrderedChargeTasks
];

activeTemporaryPath = "";

closeS07Kernels[] := If[
  IntegerQ[$KernelCount] && $KernelCount > 0,
  Quiet[CloseKernels[]]
];

fatal[message_String] := (
  closeS07Kernels[];
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S07_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  assert[
    ! FileExistsQ[finalPath],
    "refusing to overwrite existing artifact " <> finalPath
  ];
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "process-specific temporary artifact already exists"
  ];

  writeResult = Quiet @ Check[
    Put[expression, activeTemporaryPath];
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    False
  ];
  If[! TrueQ[writeResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic temporary write failed"]
  ];

  loaded = Quiet @ Check[Get[activeTemporaryPath], $Failed];
  If[
    ! AssociationQ[loaded] ||
      loaded["Status"] =!= "Complete" ||
      loaded["Stage"] =!= expectedStage,
    Quiet[DeleteFile[activeTemporaryPath]];
    fatal["temporary Association failed status/stage reload validation"]
  ];

  renameResult = Quiet @ Check[
    RenameFile[activeTemporaryPath, finalPath];
    True,
    False
  ];
  If[! TrueQ[renameResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic rename failed"]
  ];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "finalized artifact is missing or empty"
  ];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s06SourcePath = FileNameJoin[{
  scriptDirectory, "s06_spin_color_sum_average_hqqprime.wl"
}];
s06ResultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];

stageVersion = "HqqprimeS07-v1";
cacheStageVersion = "HqqprimeS07Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S07_PREFLIGHT_ONLY"], ""] === "1";
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 3 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS06SourceHash =
  "eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc";
expectedS06ResultHash =
  "92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607";
expectedS05SourceHash =
  "95a405581e6b5c9f24af44b513895cfa42c6524c097bc23e624de5c8df1c66f5";
expectedS05ResultHash =
  "d78577388379acf513733d6d21e85a30ab34200a1a35e7b7605e6241bfbfdec7";
expectedS01SourceHash =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultHash =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedS04SourceHash =
  "9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc";
expectedS04ResultHash =
  "2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84";

chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
projectorKeys = {"Pg", "PPP"};
chargeKeySlugs = <|
  "IncomingChargeSquared" -> "incoming_charge_squared",
  "PrimeChargeSquared" -> "prime_charge_squared",
  "MixedIncomingPrimeCharge" -> "mixed_incoming_prime_charge"
|>;
projectorSlugs = <|"Pg" -> "pg", "PPP" -> "ppp"|>;
cachePaths = AssociationMap[
  Function[chargeKey,
    AssociationMap[
      Function[projectorName,
        FileNameJoin[{
          scriptDirectory,
          "s07_cache_hqqprime_" <> chargeKeySlugs[chargeKey] <> "_" <>
            projectorSlugs[projectorName]
        }]
      ],
      projectorKeys
    ]
  ],
  chargeKeys
];

programHash = fileSHA256[programPath];
staleTemporaryPaths = Join[
  FileNames["s07_result.tmp.*", scriptDirectory],
  FileNames["s07_cache_hqqprime_*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "a stale S07 temporary artifact must be resolved before running"
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[s07ResultPath],
    "s07_result already exists; validate it or deliberately remove it before regeneration"
  ]
];

Print["S07_STAGE: validating the paper and accepted S06 handoff"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing"];
    assert[
      fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff"
    ];
  ],
  <|
    "authoritative paper" -> {paperPath, expectedPaperHash},
    "S06 source" -> {s06SourcePath, expectedS06SourceHash},
    "S06 result" -> {s06ResultPath, expectedS06ResultHash}
  |>
];

s06 = Quiet @ Check[Get[s06ResultPath], $Failed];
assert[AssociationQ[s06], "s06_result is not an Association"];
assert[
  s06["Status"] === "Complete" &&
    s06["Stage"] === "HqqprimeS06-v1" &&
    s06["ResultSchemaVersion"] === 1 &&
    s06["Channel"] === "Hqqprime only" &&
    s06["Contribution"] ===
      "H_{q qPrime; q qbarPrime} charge-resolved spin/color-summed and incoming-averaged real tensors" &&
    s06["PerturbativeOrder"] === "O(alpha_s^2)",
  "S06 status/stage/schema/channel/contribution is invalid"
];
assert[
  s06["ProgramSHA256"] === expectedS06SourceHash &&
    s06["PaperReference", "SHA256"] === expectedPaperHash,
  "S06 source or paper binding is invalid"
];
assert[
  s06["Input", "S05SourceSHA256"] === expectedS05SourceHash &&
    s06["Input", "S05ResultSHA256"] === expectedS05ResultHash &&
    s06["Input", "S01SourceSHA256"] === expectedS01SourceHash &&
    s06["Input", "S01ResultSHA256"] === expectedS01ResultHash &&
    s06["Input", "S04SourceSHA256"] === expectedS04SourceHash &&
    s06["Input", "S04ResultSHA256"] === expectedS04ResultHash,
  "an inherited S05/S01/S04 identity is invalid"
];
assert[
  Length[s06["Checks"]] === 35 &&
    And @@ (TrueQ /@ Values[s06["Checks"]]),
  "an accepted S06 check is not True"
];
assert[
  s06["Input", "S05TensorPath"] ===
      "ChargeResolvedBilinears/ScaleAttachedChargeTensors" &&
    s06["CacheProvenance", "StageVersion"] ===
      "HqqprimeS06Cache-v1" &&
    s06["CacheProvenance", "ProgramSHA256"] ===
      expectedS06SourceHash,
  "S06 tensor-path or cache provenance is invalid"
];
assert[
  s06["ExternalStateBookkeeping", "Incoming"] === "q(p)" &&
    s06["ExternalStateBookkeeping", "Fragmenting"] === "qPrime(k1)" &&
    s06["ExternalStateBookkeeping", "Unobserved"] ===
      {"q(k2)", "qbarPrime(k3)"} &&
    s06["ExternalStateBookkeeping",
      "AllFourFermionSpinsSummedPerChargeTensor"] === True &&
    s06["ExternalStateBookkeeping",
      "AllInitialAndFinalColorsSummedPerChargeTensor"] === True &&
    s06["ExternalStateBookkeeping",
      "FinalStatesAreSummedNotAveraged"] === True,
  "S06 external-state bookkeeping is invalid"
];
assert[
  s06["ExternalStateBookkeeping", "InitialStateAverageFactor"] ===
      1/(2 FeynCalc`SUNN) &&
    s06["ExternalStateBookkeeping", "InitialStateAverageDenominator"] ===
      2 FeynCalc`SUNN,
  "S06 incoming-state average ledger is invalid"
];
assert[
  s06["ChargeBookkeeping", "SeparatedTensorKeys"] === chargeKeys &&
    s06["ChargeBookkeeping", "CoefficientTensorsRemainChargeFree"] ===
      True &&
    s06["ChargeBookkeeping", "PhysicalOrderedFlavorSumAppliedAtS06"] ===
      False,
  "S06 charge-key or physical-flavor bookkeeping is invalid"
];
assert[
  s06["ScaleBookkeeping", "AbsoluteFactor"] ===
      FeynCalc`ScaleMu^(4 epsilon) &&
    s06["ScaleBookkeeping", "AbsoluteExponent"] === 4 epsilon &&
    s06["ScaleBookkeeping", "PowerPreservedExactlyOncePerChargeTensor"] ===
      True &&
    s06["ScaleBookkeeping", "SeparateMSBarSEpsilonApplied"] === False,
  "S06 scale bookkeeping is invalid"
];
assert[
  s06["SymmetryBookkeeping", "DistinctFinalStateIdentities"] ===
      {"qPrime(k1)", "q(k2)", "qbarPrime(k3)"} &&
    s06["SymmetryBookkeeping", "NontrivialSymmetryFactorRequired"] ===
      False &&
    s06["SymmetryBookkeeping", "SymmetryFactorAppliedAtS06"] === False &&
    And @@ (# === 1 & /@
      Values[s06["SymmetryBookkeeping",
        "DerivedFinalStateSymmetryFactors"]]),
  "S06 symmetry bookkeeping is invalid"
];
assert[
  s06["VirtualContributionAtThisOrder", "Applicable"] === False &&
    s06["VirtualContributionAtThisOrder", "Interference"] === 0 &&
    s06["VirtualContributionAtThisOrder", "SourceDisposition"] ===
      "NotApplicableAtThisOrder",
  "S06 violates the real-only virtual-absence contract"
];
assert[
  s06["PhotonIndices"] === {s05Mu, s05Nu},
  "S06 photon-index ledger is invalid"
];

inputTensors = s06["Tensors", "SpinColorAveragedChargeTensors"];
colorSummedInputTensors =
  s06["Tensors", "ColorSummedUnaveragedChargeTensors"];
assert[
  AssociationQ[inputTensors] && AssociationQ[colorSummedInputTensors] &&
    Keys[inputTensors] === chargeKeys &&
    Keys[colorSummedInputTensors] === chargeKeys,
  "S06 tensor associations have the wrong keys or order"
];
assert[
  And @@ (
    inputTensors[#] ===
      colorSummedInputTensors[#]/(2 FeynCalc`SUNN) & /@ chargeKeys
  ),
  "an S06 charge tensor fails the exact incoming-average audit"
];
genericChargeSymbols =
  s06["ChargeBookkeeping", "GenericChargeSymbols"];
assert[
  MatchQ[genericChargeSymbols, {_Symbol, _Symbol}] &&
    DuplicateFreeQ[genericChargeSymbols],
  "S06 generic charge-symbol ledger is invalid"
];
dimensionalScaleExponent = s06["ScaleBookkeeping", "AbsoluteExponent"];
dimensionalScaleFactor = s06["ScaleBookkeeping", "AbsoluteFactor"];
inputTensorHashes = AssociationThread[
  chargeKeys,
  expressionSHA256 /@ Lookup[inputTensors, chargeKeys]
];
assert[
  Keys[inputTensorHashes] === chargeKeys &&
    And @@ (
      StringQ[#] && StringLength[#] === 64 &&
        StringMatchQ[#, Repeated[HexadecimalCharacter, {64}]] & /@
        Values[inputTensorHashes]
    ),
  "the freshly derived S07 input-tensor hash association is invalid"
];

hasExactlyExpectedScaleQ[expression_] := Module[
  {
    marker, scaleExponents, markedExpression, markerDegree,
    markerConstant, scaleFreeCoefficient, reconstructionResidual
  },
  marker = Unique["s07ScaleMarker$"];
  scaleExponents = DeleteDuplicates @ Cases[
    expression,
    HoldPattern[Power[FeynCalc`ScaleMu, exponent_]] :> exponent,
    Infinity
  ];
  If[
    scaleExponents === {} ||
      ! And @@ (
        TrueQ[
          Quiet @ Check[
            Simplify[# - dimensionalScaleExponent] === 0,
            False
          ]
        ] & /@ scaleExponents
      ),
    Return[False]
  ];
  markedExpression = expression /. HoldPattern[
      Power[FeynCalc`ScaleMu, exponent_]
    ] :> marker;
  markerDegree = Quiet @ Check[
    Exponent[markedExpression, marker],
    $Failed
  ];
  markerConstant = Quiet @ Check[
    Coefficient[markedExpression, marker, 0],
    $Failed
  ];
  scaleFreeCoefficient = Quiet @ Check[
    Coefficient[markedExpression, marker, 1],
    $Failed
  ];
  reconstructionResidual = Quiet @ Check[
    Expand[
      expression - dimensionalScaleFactor scaleFreeCoefficient
    ],
    $Failed
  ];
  FreeQ[markedExpression, FeynCalc`ScaleMu] &&
    markerDegree === 1 && markerConstant === 0 &&
    FreeQ[scaleFreeCoefficient, FeynCalc`ScaleMu] &&
    reconstructionResidual === 0
];

explicitStateDiracColorPattern =
  _FeynCalc`Spinor | _FeynCalc`Polarization |
  _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
  _FeynCalc`DiracChain | _FeynCalc`SUNFIndex |
  _FeynCalc`SUNIndex | _FeynCalc`SUNT | _FeynCalc`SUNF |
  _FeynCalc`SUNDelta | _FeynCalc`SUNTrace |
  _FeynCalc`SumOver | FeynCalc`ComplexConjugate;
loopOrRegulatorPattern =
  FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`A00 | FeynCalc`B0 |
  FeynCalc`B1 | FeynCalc`B00 | FeynCalc`B11 | FeynCalc`C0 |
  FeynCalc`D0 | FeynCalc`E0 | FeynCalc`TID | FeynCalc`TIDL |
  FeynCalc`GLI | FeynCalc`FCTopology | FeynCalc`EpsilonUV |
  FeynCalc`EpsilonIR;
phaseSpaceOrDistributionPattern =
  _DiracDelta | _HeavisideTheta | _ConditionalExpression |
  _InterpolatingFunction;

validateInputTensor[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero"
  ];
  assert[
    ! FreeQ[expression, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expression, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lacks an open photon index"
  ];
  assert[
    FreeQ[expression, explicitStateDiracColorPattern],
    label <> " contains an external-state, Dirac, or color object"
  ];
  assert[
    And @@ (FreeQ[expression, #] & /@ genericChargeSymbols),
    label <> " contains a generic charge symbol"
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not retain exactly the accepted global scale factor"
  ];
  assert[
    FreeQ[expression, loopOrRegulatorPattern | _Real | $Failed],
    label <> " contains a loop/regulator, machine number, or failure object"
  ];
  True
];

scalarProjectionValidQ[expression_] :=
  expression =!= $Failed && expression =!= 0 &&
    FreeQ[
      expression,
      _FeynCalc`LorentzIndex | FeynCalc`Contract |
      explicitStateDiracColorPattern | loopOrRegulatorPattern |
      phaseSpaceOrDistributionPattern | _Real | $Failed
    ] &&
    FreeQ[expression, s05Mu | s05Nu] &&
    And @@ (FreeQ[expression, #] & /@ genericChargeSymbols) &&
    hasExactlyExpectedScaleQ[expression] &&
    ! FreeQ[expression, _FeynCalc`FeynAmpDenominator];

validateScalarProjection[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero"
  ];
  assert[
    FreeQ[expression, _FeynCalc`LorentzIndex | FeynCalc`Contract] &&
      FreeQ[expression, s05Mu | s05Nu],
    label <> " retains an index or unevaluated Contract"
  ];
  assert[
    FreeQ[expression, explicitStateDiracColorPattern],
    label <> " contains an external-state, Dirac, or color object"
  ];
  assert[
    And @@ (FreeQ[expression, #] & /@ genericChargeSymbols),
    label <> " contains a generic charge symbol"
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not retain exactly the accepted global scale factor"
  ];
  assert[
    FreeQ[
      expression,
      loopOrRegulatorPattern | phaseSpaceOrDistributionPattern |
      _Real | $Failed
    ],
    label <> " contains a loop, downstream, machine, or failure object"
  ];
  assert[
    ! FreeQ[expression, _FeynCalc`FeynAmpDenominator],
    label <> " does not retain the inert ordinary tree denominators"
  ];
  True
];

And @@ KeyValueMap[
  validateInputTensor[#2, "accepted S06 " <> #1 <> " tensor"] &,
  inputTensors
];

setThreeBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[k3, k3] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[q, k1] = (-Q2 - t1)/2;
  FeynCalc`SPD[q, k2] = (-Q2 - t2)/2;
  FeynCalc`SPD[q, k3] = (-Q2 - t3)/2;
  FeynCalc`SPD[p, k1] = -u1/2;
  FeynCalc`SPD[p, k2] = -u2/2;
  FeynCalc`SPD[p, k3] = -u3/2;
  FeynCalc`SPD[k1, k2] = s12/2;
  FeynCalc`SPD[k1, k3] = s13/2;
  FeynCalc`SPD[k2, k3] = s23/2;
);

projectors = <|
  "Pg" -> FeynCalc`Pair[
    FeynCalc`LorentzIndex[s05Mu, D],
    FeynCalc`LorentzIndex[s05Nu, D]
  ],
  "PPP" -> Times[
    FeynCalc`Pair[
      FeynCalc`Momentum[p, D],
      FeynCalc`LorentzIndex[s05Mu, D]
    ],
    FeynCalc`Pair[
      FeynCalc`Momentum[p, D],
      FeynCalc`LorentzIndex[s05Nu, D]
    ]
  ]
|>;
wardProjector = Times[
  FeynCalc`Pair[
    FeynCalc`Momentum[q, D],
    FeynCalc`LorentzIndex[s05Mu, D]
  ],
  FeynCalc`Pair[
    FeynCalc`Momentum[q, D],
    FeynCalc`LorentzIndex[s05Nu, D]
  ]
];

wardPointRelations = {
  sHat == s12 + s13 + s23,
  u1 + u2 + u3 == -(sHat + Q2),
  t1 + t2 + t3 == -sHat - 2 Q2,
  s23 == sHat + Q2 + t1 + u1,
  s13 == sHat + Q2 + t2 + u2,
  s12 == sHat + Q2 + t3 + u3
};
wardPointVariables = {
  Q2, sHat, t1, u1, t2, u2, t3, u3, s12, s13, s23
};
wardPointCondition = And[
  And @@ wardPointRelations,
  Q2 > 0,
  sHat > 0,
  And @@ Thread[{t1, u1, t2, u2, t3, u3} < 0],
  And @@ Thread[{s12, s13, s23} > 0]
];

deriveWardPoint[] := Module[{instances, rules},
  instances = Quiet @ Check[
    FindInstance[
      wardPointCondition,
      wardPointVariables,
      Rationals,
      1
    ],
    $Failed
  ];
  assert[
    ListQ[instances] && Length[instances] === 1 &&
      MatchQ[First[instances], {(_Rule)..}],
    "Wolfram did not derive exactly one rational Ward-test point"
  ];
  rules = First[instances];
  assert[
    Sort[First /@ rules] === Sort[wardPointVariables] &&
      FreeQ[rules, _Real | D | epsilon | FeynCalc`ScaleMu],
    "the derived Ward-test point is incomplete or not exact/symbolic-safe"
  ];
  assert[
    And @@ (TrueQ /@ (wardPointRelations /. rules)) &&
      TrueQ[wardPointCondition /. rules],
    "the derived Ward-test point violates a conservation/sign relation"
  ];
  rules
];

Print["S07_STAGE: deriving the exact current-channel Ward-test point"];
wardPointRules = deriveWardPoint[];
Print["S07_WARD_POINT=", InputForm[wardPointRules]];

cacheMetadataValidQ[
    cache_, chargeKey_String, projectorName_String
  ] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqprime only" &&
    Lookup[cache, "ChargeKey", Missing["ChargeKey"]] === chargeKey &&
    Lookup[cache, "Projector", Missing["Projector"]] === projectorName &&
    Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
      programHash &&
    Lookup[cache, "PaperSHA256", Missing["PaperSHA256"]] ===
      expectedPaperHash &&
    Lookup[cache, "S06SourceSHA256", Missing["S06SourceSHA256"]] ===
      expectedS06SourceHash &&
    Lookup[cache, "S06ResultSHA256", Missing["S06ResultSHA256"]] ===
      expectedS06ResultHash &&
    Lookup[cache, "InputTensorPath", Missing["InputTensorPath"]] ===
      "Tensors/SpinColorAveragedChargeTensors/" <> chargeKey &&
    Lookup[cache, "InputTensorSHA256", Missing["InputTensorSHA256"]] ===
      inputTensorHashes[chargeKey] &&
    KeyExistsQ[cache, "Expression"] &&
    Lookup[cache, "ExpressionSHA256", Missing["ExpressionSHA256"]] ===
      expressionSHA256[cache["Expression"]];

loadValidatedCache[
    path_String, chargeKey_String, projectorName_String
  ] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path],
    Return[Missing["NotAvailable"]]
  ];
  Print[
    "S07_STAGE: inspecting ", chargeKey, " ", projectorName, " cache"
  ];
  cache = Quiet @ Check[Get[path], $Failed];
  If[
    ! TrueQ[cacheMetadataValidQ[cache, chargeKey, projectorName]] ||
      ! TrueQ[scalarProjectionValidQ[cache["Expression"]]],
    Print[
      "S07_STAGE: deleting stale or invalid ", chargeKey, " ",
      projectorName, " cache"
    ];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];
  Print[
    "S07_STAGE: accepted source-bound ", chargeKey, " ",
    projectorName, " cache"
  ];
  cache["Expression"]
];

writeCache[
    path_String, chargeKey_String, projectorName_String, expression_
  ] := Module[{cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "Channel" -> "Hqqprime only",
    "ChargeKey" -> chargeKey,
    "Projector" -> projectorName,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperHash,
    "S06SourcePath" -> s06SourcePath,
    "S06SourceSHA256" -> expectedS06SourceHash,
    "S06ResultPath" -> s06ResultPath,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "InputTensorPath" ->
      "Tensors/SpinColorAveragedChargeTensors/" <> chargeKey,
    "InputTensorSHA256" -> inputTensorHashes[chargeKey],
    "ExpressionSHA256" -> expressionSHA256[expression],
    "Expression" -> expression
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

processChargeTask[task_Association] := Module[
  {
    chargeKey, tensor, pointRules, requestedProjectors,
    wardResidual, projections, projection
  },
  chargeKey = task["ChargeKey"];
  tensor = task["Tensor"];
  pointRules = task["WardPointRules"];
  requestedProjectors = task["RequestedProjectors"];
  setThreeBodyKinematics[];

  wardResidual = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        Together[
          FeynCalc`FeynAmpDenominatorExplicit[
            FeynCalc`Contract[wardProjector tensor]
          ] /. pointRules
        ],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  If[wardResidual =!= 0,
    Return[<|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" ->
        "double-photon Ward residual is nonzero, failed, or over budget"
    |>]
  ];

  projections = <||>;
  Do[
    projection = MemoryConstrained[
      CheckAbort[
        Quiet @ Check[
          FeynCalc`Contract[projectors[projectorName] tensor],
          $Failed
        ],
        $Failed
      ],
      workerMemoryBudgetBytes,
      $Failed
    ];
    If[projection === $Failed,
      Return[<|
        "Success" -> False,
        "ChargeKey" -> chargeKey,
        "Failure" -> projectorName <>
          " contraction failed or exceeded worker memory"
      |>]
    ];
    projections[projectorName] = projection;
  ,
    {projectorName, requestedProjectors}
  ];

  <|
    "Success" -> True,
    "ChargeKey" -> chargeKey,
    "WardResidual" -> wardResidual,
    "RequestedProjectors" -> requestedProjectors,
    "Projections" -> AssociationThread[
      requestedProjectors,
      Lookup[projections, requestedProjectors]
    ],
    "LeafCounts" -> AssociationThread[
      requestedProjectors,
      LeafCount /@ Lookup[projections, requestedProjectors]
    ]
  |>
];

launchS07Kernels[] := Module[{localCandidates, configuration, launched},
  closeS07Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet @ Check[# ["Class"] === "LocalKernels", False] &
  ];
  assert[
    Length[localCandidates] >= 1,
    "no local Wolfram kernel configuration is available"
  ];
  configuration = ReplacePart[
    First[localCandidates],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernelCount
    }
  ];
  assert[
    configuration["KernelCommand"] === parallelKernelExecutable &&
      configuration["KernelCount"] === requestedParallelKernelCount,
    "the in-memory Engine-15 local kernel configuration is invalid"
  ];
  launched = Quiet @ Check[LaunchKernels[configuration], $Failed];
  assert[
    ListQ[launched] &&
      Length[launched] === requestedParallelKernelCount &&
      $KernelCount === requestedParallelKernelCount,
    "failed to launch exactly three Engine-15 local kernels"
  ];
  ParallelNeeds["FeynCalc`"];
  ParallelEvaluate[$HistoryLength = 0; $FCAdvice = False;];
  workerVersions = ParallelEvaluate[$Version];
  assert[
    Length[workerVersions] === requestedParallelKernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
    "a local worker is not the verified Engine 15.0 runtime"
  ];
  parallelOrderProbe = ParallelMap[
    Identity,
    chargeKeys,
    Method -> "FinestGrained"
  ];
  assert[
    parallelOrderProbe === chargeKeys,
    "parallel result ordering is not deterministic"
  ];
  DistributeDefinitions[
    setThreeBodyKinematics,
    processChargeTask,
    workerMemoryBudgetBytes,
    wardProjector,
    projectors
  ];
  True
];

runOrderedChargeTasks[tasks_List] := Module[{results, returnedKeys},
  Print[
    "S07_STAGE: dispatching three charge tasks across three Engine-15 kernels"
  ];
  results = Quiet @ Check[
    ParallelMap[processChargeTask, tasks, Method -> "FinestGrained"],
    $Failed
  ];
  assert[
    ListQ[results] && Length[results] === Length[tasks] &&
      And @@ (AssociationQ /@ results),
    "parallel charge-task dispatch failed"
  ];
  assert[
    And @@ (TrueQ[# ["Success"]] & /@ results),
    "a charge worker reported failure: " <>
      ToString[InputForm[Lookup[results, "Failure", None]]]
  ];
  returnedKeys = Lookup[results, "ChargeKey"];
  assert[
    returnedKeys === Lookup[tasks, "ChargeKey"] &&
      returnedKeys === chargeKeys,
    "parallel charge results returned in the wrong key order"
  ];
  results
];

scalarProjectionsByCharge = AssociationMap[<||> &, chargeKeys];
cacheReusedByCharge = AssociationMap[
  AssociationThread[projectorKeys, ConstantArray[False, 2]] &,
  chargeKeys
];

Do[
  cachedProjection = loadValidatedCache[
    cachePaths[chargeKey, projectorName],
    chargeKey,
    projectorName
  ];
  If[! MissingQ[cachedProjection],
    scalarProjectionsByCharge[chargeKey, projectorName] = cachedProjection;
    cacheReusedByCharge[chargeKey, projectorName] = True
  ];
,
  {chargeKey, chargeKeys},
  {projectorName, projectorKeys}
];

pendingProjectorsByCharge = AssociationMap[
  Function[chargeKey,
    Select[
      projectorKeys,
      ! KeyExistsQ[scalarProjectionsByCharge[chargeKey], #] &
    ]
  ],
  chargeKeys
];
chargeTasks = (
  <|
    "ChargeKey" -> #,
    "Tensor" -> inputTensors[#],
    "WardPointRules" -> wardPointRules,
    "RequestedProjectors" -> pendingProjectorsByCharge[#]
  |> & /@ chargeKeys
);

Print["S07_STAGE: launching the three independent charge-tensor workers"];
launchS07Kernels[];
launchedParallelKernelCount = $KernelCount;
chargeResults = runOrderedChargeTasks[chargeTasks];
closeS07Kernels[];

wardResidualsByCharge = <||>;
Do[
  chargeKey = chargeResult["ChargeKey"];
  assert[
    chargeResult["WardResidual"] === 0,
    chargeKey <> " lost its exact Ward residual"
  ];
  wardResidualsByCharge[chargeKey] = chargeResult["WardResidual"];
  Do[
    projection = chargeResult["Projections", projectorName];
    validateScalarProjection[
      projection,
      chargeKey <> " fresh " <> projectorName <> " projection"
    ];
    scalarProjectionsByCharge[chargeKey, projectorName] = projection;
    writeCache[
      cachePaths[chargeKey, projectorName],
      chargeKey,
      projectorName,
      projection
    ];
    Print[
      "S07_CHECKPOINT: ", chargeKey, " ", projectorName,
      " leaf count ", LeafCount[projection]
    ];
  ,
    {projectorName, chargeResult["RequestedProjectors"]}
  ];
,
  {chargeResult, chargeResults}
];
wardResidualsByCharge = AssociationThread[
  chargeKeys,
  Lookup[wardResidualsByCharge, chargeKeys]
];

scalarProjectionsByCharge = AssociationThread[
  chargeKeys,
  AssociationThread[
    projectorKeys,
    Lookup[scalarProjectionsByCharge[#], projectorKeys]
  ] & /@ chargeKeys
];
assert[
  Keys[scalarProjectionsByCharge] === chargeKeys &&
    And @@ (
      Keys[scalarProjectionsByCharge[#]] === projectorKeys & /@ chargeKeys
    ),
  "final projections lost their required charge/projector order"
];

scalarProjectionsByProjector = AssociationThread[
  projectorKeys,
  AssociationThread[
    chargeKeys,
    scalarProjectionsByCharge[#2, #1] & @@@
      Thread[{ConstantArray[#, Length[chargeKeys]], chargeKeys}]
  ] & /@ projectorKeys
];
assert[
  Keys[scalarProjectionsByProjector] === projectorKeys &&
    And @@ (
      Keys[scalarProjectionsByProjector[#]] === chargeKeys & /@
        projectorKeys
    ),
  "projector-first projections have the wrong key order"
];
assert[
  And @@ Flatten[
    Values /@ Values[
      Map[
        scalarProjectionValidQ,
        scalarProjectionsByProjector,
        {2}
      ]
    ]
  ],
  "at least one final scalar projection failed validation"
];
assert[
  inputTensors === s06["Tensors", "SpinColorAveragedChargeTensors"],
  "the Ward/projection calculations altered the symbolic input tensors"
];

projectionLeafCounts = Map[
  LeafCount,
  scalarProjectionsByProjector,
  {2}
];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "CurrentS06SourceAndResultHashesValidated" -> True,
  "S06InheritedS05S01S04BindingsValidated" -> True,
  "AllThirtyFiveS06ChecksValidated" -> True,
  "OnlySpinColorAveragedChargeTensorsConsumed" -> True,
  "ExactThreeOrderedChargeKeysPreserved" ->
    (And @@ (Keys[scalarProjectionsByProjector[#]] === chargeKeys & /@
      projectorKeys)),
  "ExactIncomingQuarkAverageInherited" -> True,
  "ExactThreeBodyKinematicsInstalled" -> True,
  "WardPointDerivedByWolframFindInstance" -> True,
  "WardPointConservationAndSignsValidated" ->
    (And @@ (TrueQ /@ (wardPointRelations /. wardPointRules)) &&
      TrueQ[wardPointCondition /. wardPointRules]),
  "ExactDoublePhotonWardResidualZeroForEveryChargeTensor" ->
    And @@ (# === 0 & /@ Values[wardResidualsByCharge]),
  "PaperPgMetricProjectorApplied" -> True,
  "PaperPPPIncomingPartonMomentumProjectorApplied" -> True,
  "ExactlySixScalarProjectionsProduced" ->
    (Total[Length /@ Values[scalarProjectionsByProjector]] === 6),
  "ProjectorFirstOutputOrderPgThenPPP" ->
    (Keys[scalarProjectionsByProjector] === projectorKeys),
  "PhotonIndexMuContractedEverywhere" ->
    FreeQ[scalarProjectionsByProjector, s05Mu],
  "PhotonIndexNuContractedEverywhere" ->
    FreeQ[scalarProjectionsByProjector, s05Nu],
  "NoLorentzIndexOrContractRemains" ->
    FreeQ[
      scalarProjectionsByProjector,
      _FeynCalc`LorentzIndex | FeynCalc`Contract
    ],
  "DAndEpsilonKeptSymbolic" -> True,
  "AbsoluteScaleMuPowerFourEpsilonPreservedInEveryScalar" ->
    And @@ Flatten[
      Values /@ Values[
        Map[
          hasExactlyExpectedScaleQ,
          scalarProjectionsByProjector,
          {2}
        ]
      ]
    ],
  "CoefficientScalarsRemainFreeOfGenericCharges" ->
    And @@ Flatten[
      Values /@ Values[
        Map[
          Function[expression,
            And @@ (FreeQ[expression, #] & /@ genericChargeSymbols)
          ],
          scalarProjectionsByProjector,
          {2}
        ]
      ]
    ],
  "PhysicalOrderedFlavorChargeAssemblyDeferred" -> True,
  "FinalStateSymmetryFactorNotIntroduced" -> True,
  "VirtualContributionRemainsAbsent" -> True,
  "Eq9F1F2CombinationsDeferred" -> True,
  "NoPhaseSpaceOrFactorizationFactorApplied" -> True,
  "TreePropagatorDenominatorsRemainForLaterReduction" ->
    And @@ Flatten[
      Values /@ Values[
        Map[
          (! FreeQ[#, _FeynCalc`FeynAmpDenominator]) &,
          scalarProjectionsByProjector,
          {2}
        ]
      ]
    ],
  "NoExternalStateDiracColorOrMachineObjects" ->
    FreeQ[
      scalarProjectionsByProjector,
      explicitStateDiracColorPattern | _Real | $Failed
    ],
  "ExactlyThreeEngine15ChargeWorkersUsed" ->
    (launchedParallelKernelCount === requestedParallelKernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions)),
  "PgAndPPPSerialWithinEachChargeWorker" -> True,
  "OnlyMainKernelWritesCaches" -> True,
  "CachesBoundToProgramPaperS06ChargeProjectorAndInput" -> True,
  "AtomicCacheAndResultProtocolConfigured" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "at least one S07 validation check is not True"
];

If[
  preflightOnly,
  Print["S07_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S07_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print[
    "S07_DYNAMIC_PREFLIGHT_LEAF_COUNTS=",
    InputForm[projectionLeafCounts]
  ];
  Quit[0]
];

cacheProvenanceByProjector = AssociationThread[
  projectorKeys,
  AssociationThread[
    chargeKeys,
    <|
      "Path" -> cachePaths[#2, #1],
      "SHA256" -> fileSHA256[cachePaths[#2, #1]],
      "CacheReused" -> cacheReusedByCharge[#2, #1],
      "InputTensorSHA256" -> inputTensorHashes[#2]
    |> & @@@ Thread[{ConstantArray[#, Length[chargeKeys]], chargeKeys}]
  ] & /@ projectorKeys
];

s07Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "H_{q qPrime; q qbarPrime} charge-resolved real Pg/PPP scalar projections",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "ProjectorEquations" -> "Eqs. (7), (16), and (19)"
  |>,
  "Input" -> <|
    "S06SourcePath" -> s06SourcePath,
    "S06SourceSHA256" -> expectedS06SourceHash,
    "S06ResultPath" -> s06ResultPath,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "TensorPath" -> "Tensors/SpinColorAveragedChargeTensors",
    "InputTensorSHA256ByChargeKey" -> inputTensorHashes
  |>,
  "ProjectorDefinitions" -> <|
    "Pg" -> HoldForm[PSubg[mu, nu] == MetricTensor[mu, nu]],
    "PPPPartonic" -> HoldForm[PSubPP[mu, nu] == p[mu] p[nu]],
    "HadronicToPartonicMomentumReplacement" -> HoldForm[P -> p],
    "Eq9F1F2CombinationStatus" -> "Deferred"
  |>,
  "WardIdentity" -> <|
    "Diagnostic" -> "q_mu q_nu W_charge^(mu nu) for every charge key",
    "PointDerivation" ->
      "Wolfram FindInstance over exact rational conservation/sign constraints",
    "ExactPointRules" -> wardPointRules,
    "MomentumConservationRelations" -> wardPointRelations,
    "DimensionAndScaleLeftSymbolic" -> True,
    "TreeDenominatorsMadeExplicitOnlyInDiagnostic" -> True,
    "ResidualsByChargeKey" -> wardResidualsByCharge,
    "PassedForEveryChargeKey" -> True
  |>,
  "KinematicConventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "SavedProjectionsRemainSymbolic" -> True,
    "MasslessExternalMomenta" -> {p, k1, k2, k3},
    "PhotonVirtuality" -> HoldForm[q^2 == -Q2],
    "ThreeBodyInvariants" ->
      {sHat, t1, t2, t3, u1, u2, u3, s12, s13, s23}
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> launchedParallelKernelCount,
    "WorkerVersions" -> workerVersions,
    "ChargeKeysProcessedIndependently" -> chargeKeys,
    "ProjectorsSerialWithinEachChargeWorker" -> projectorKeys,
    "DeterministicResultOrder" -> True,
    "ConcurrentCacheWrites" -> False
  |>,
  "ExternalStateBookkeeping" -> s06["ExternalStateBookkeeping"],
  "ChargeBookkeeping" -> s06["ChargeBookkeeping"],
  "ScaleBookkeeping" -> <|
    "AbsoluteFactor" -> dimensionalScaleFactor,
    "AbsoluteExponent" -> dimensionalScaleExponent,
    "PowerPreservedExactlyOnceInEveryProjection" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "SymmetryBookkeeping" -> s06["SymmetryBookkeeping"],
  "VirtualContributionAtThisOrder" ->
    s06["VirtualContributionAtThisOrder"],
  "ScalarProjections" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqprime;q_qbarPrime" -> scalarProjectionsByProjector
    |>
  |>,
  "ProjectionCount" -> 6,
  "LeafCounts" -> projectionLeafCounts,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "ByProjectorAndChargeKey" -> cacheProvenanceByProjector,
    "AtomicMainKernelWritesOnly" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "Eq. (9) P1/P2 linear combinations for F1/F2",
    "physical ordered q,qPrime flavor/charge assembly",
    "a final-state symmetry factor",
    "a virtual contribution",
    "three-body phase-space normalization or angular integration",
    "MS-bar PDF/FF collinear factorization",
    "endpoint distributions, F-hat inversion, or external-code comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized Hqqprime S08 may consume each ScalarProjections/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key> scalar independently for the paper three-body phase-space/angular stage while preserving every charge, scale, symmetry, and real-only ledger."
|>;

Print["S07_STAGE: atomically writing the Hqqprime S07 result"];
atomicPutAssociation[s07Result, s07ResultPath, stageVersion];

reloadedResult = Quiet @ Check[Get[s07ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion,
  "final s07_result failed status/stage/schema reload validation"
];
assert[
  reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input", "S06SourceSHA256"] ===
      expectedS06SourceHash &&
    reloadedResult["Input", "S06ResultSHA256"] ===
      expectedS06ResultHash &&
    reloadedResult["PaperReference", "SHA256"] === expectedPaperHash,
  "final s07_result failed source/upstream/paper hash validation"
];
reloadedProjections = reloadedResult[
  "ScalarProjections",
  "NLOReal_OAlphaS2",
  "Hqqprime;q_qbarPrime"
];
assert[
  reloadedResult["ProjectionCount"] === 6 &&
    Keys[reloadedProjections] === projectorKeys &&
    And @@ (Keys[reloadedProjections[#]] === chargeKeys & /@
      projectorKeys) &&
    reloadedProjections === scalarProjectionsByProjector,
  "final s07_result does not contain the exact ordered six projections"
];
assert[
  Length[reloadedResult["Checks"]] === Length[checks] &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "final s07_result contains a failed check"
];
assert[
  reloadedResult["WardIdentity", "ResidualsByChargeKey"] ===
      wardResidualsByCharge &&
    And @@ (# === 0 & /@
      Values[reloadedResult["WardIdentity", "ResidualsByChargeKey"]]),
  "final s07_result lost the exact per-charge Ward gates"
];
assert[
  And @@ Flatten[
    Values /@ Values[
      Map[scalarProjectionValidQ, reloadedProjections, {2}]
    ]
  ],
  "a reloaded final scalar projection failed validation"
];
assert[
  And @@ Flatten[
    Table[
      fileSHA256[cachePaths[chargeKey, projectorName]] ===
        reloadedResult[
          "CacheProvenance",
          "ByProjectorAndChargeKey",
          projectorName,
          chargeKey,
          "SHA256"
        ],
      {projectorName, projectorKeys},
      {chargeKey, chargeKeys}
    ]
  ],
  "a final cache disk hash does not match result provenance"
];

Print["S07_SUCCESS"];
Print["S07_PROGRAM_SHA256=" <> programHash];
Print["S07_RESULT_PATH=" <> s07ResultPath];
Print["S07_RESULT_SHA256=" <> fileSHA256[s07ResultPath]];
Print["S07_PROJECTION_COUNT=", 6];
Print["S07_LEAF_COUNTS=", InputForm[projectionLeafCounts]];
Print["S07_CHECK_COUNT=", Length[checks]];
Print["S07_RESULT_BYTES=", FileByteCount[s07ResultPath]];

Quit[0];

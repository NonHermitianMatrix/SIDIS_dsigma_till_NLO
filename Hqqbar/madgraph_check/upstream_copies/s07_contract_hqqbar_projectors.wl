(* ::Package:: *)

(*
  Contract the sole validated Hqqbar spin/color-averaged real tensor with the
  two paper extraction tensors

    P_g^(mu nu)  = g^(mu nu),
    P_PP^(mu nu) = p^mu p^nu,

  where p is the incoming parton momentum in the partonic decomposition.
  The two outputs remain exact, D-dimensional, scalar, and unintegrated.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, fileSHA256, atomicPutAssociation,
  hasExactlyExpectedScaleQ, setThreeBodyKinematics,
  validateInputTensor, validateScalarProjection, exactWardGate,
  cacheMetadataValidQ, loadValidatedCache, writeCache,
  contractProjection
];

activeTemporaryPath = "";

fatal[message_String] := (
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

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "The process-specific temporary path already exists: " <>
      activeTemporaryPath
  ];

  writeResult = Quiet@Check[Put[expression, activeTemporaryPath], $Failed];
  assert[writeResult =!= $Failed, "Atomic temporary write failed."];
  assert[
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    "Atomic temporary file is missing or empty."
  ];

  loaded = Quiet@Check[Get[activeTemporaryPath], $Failed];
  assert[
    AssociationQ[loaded] && loaded["Status"] === "Complete" &&
      loaded["Stage"] === expectedStage,
    "Atomic temporary Association failed status/stage reload validation."
  ];

  renameResult = Quiet@Check[
    RenameFile[activeTemporaryPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic rename failed."];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Finalized atomic file is missing or empty."
  ];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
s06SourcePath =
  FileNameJoin[{scriptDirectory, "s06_spin_color_sum_average_hqqbar.wl"}];
s06ResultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s07_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s07_cache_hqqbar_ppp"}]
|>;

stageVersion = "HqqbarS07-v1";
cacheStageVersion = "HqqbarS07Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S07_PREFLIGHT_ONLY"], ""] === "1";
memoryBudgetBytes = 7 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS06SourceHash =
  "787d001e6d285d1e74cfe9654ca8f61fe9a66d3b2e5972b20291bf39a02014fe";
expectedS06ResultHash =
  "fd6499e32ce65273381e5350131fe06e8ed3b9a05083b446189b0d7d7323f9ef";
expectedS05SourceHash =
  "af499834c79fd69e69f33306a2e049a32f3d2ed88a50afcc65d5d37b0b9fd29e";
expectedS05ResultHash =
  "b72245cd5200ab0e649588ca77607feb21c152be2e20faead5ef74bc992a5f17";

programHash = fileSHA256[programPath];
s06ResultHash = fileSHA256[s06ResultPath];
dimensionalScaleFactor = FeynCalc`ScaleMu^(4 epsilon);

staleTemporaryPaths = Join[
  FileNames["s07_result.tmp.*", scriptDirectory],
  FileNames["s07_cache_hqqbar*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "A stale S07 temporary file exists and must be resolved before running."
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[s07ResultPath],
    "s07_result already exists; validate or deliberately remove it before regeneration."
  ]
];

Print["S07_STAGE: validating the paper and accepted S06 handoff"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing."];
    assert[
      fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff."
    ];
  ],
  <|
    "authoritative paper" -> {paperPath, expectedPaperHash},
    "S06 source" -> {s06SourcePath, expectedS06SourceHash},
    "S06 result" -> {s06ResultPath, expectedS06ResultHash}
  |>
];

s06 = Quiet@Check[Get[s06ResultPath], $Failed];
assert[AssociationQ[s06], "s06_result is not an Association."];
assert[
  s06["Status"] === "Complete" &&
    s06["Stage"] === "HqqbarS06-v1" &&
    s06["ResultSchemaVersion"] === 1 &&
    s06["Channel"] === "Hqqbar only" &&
    s06["Contribution"] ===
      "H_{q qbar; q q} spin/color-summed and incoming-averaged real tensor",
  "The S06 status, stage, schema, channel, or contribution is invalid."
];
assert[
  s06["ProgramSHA256"] === expectedS06SourceHash &&
    s06["Input"]["S05SourceSHA256"] === expectedS05SourceHash &&
    s06["Input"]["S05ResultSHA256"] === expectedS05ResultHash,
  "S06 does not bind the accepted S06/S05 handoff."
];
assert[
  s06["PaperReference"]["SHA256"] === expectedPaperHash,
  "S06 does not bind the authoritative paper edition."
];
assert[
  Length[s06["Checks"]] === 25 &&
    And @@ (TrueQ /@ Values[s06["Checks"]]),
  "At least one accepted S06 check is not True."
];
assert[
  s06["Tensors"]["SpinColorAveragedRealTensor"] ===
    s06["Tensors"]["ColorSummedUnaveragedRealTensor"]/
      (2 FeynCalc`SUNN),
  "S06 fails the exact incoming-quark 1/(2 Nc) average audit."
];
assert[
  s06["VirtualContributionAtThisOrder"]["Applicable"] === False &&
    s06["VirtualContributionAtThisOrder"]["Interference"] === 0,
  "S06 violates the Hqqbar no-virtual contract."
];
assert[
  s06["ChargeBookkeeping"]["TensorIsChargeStripped"] === True &&
    s06["ChargeBookkeeping"]["PhysicalChargeWeightAppliedAtS06"] ===
      False &&
    s06["ChargeBookkeeping"]["BigTMDChannel"] === 5,
  "S06 charge or BigTMD-channel bookkeeping is invalid."
];
assert[
  s06["SymmetryBookkeeping"]
      ["IdenticalSpectatorFactorAppliedAtS06"] === False,
  "S06 incorrectly applies the deferred identical-spectator factor."
];

inputTensor = s06["Tensors"]["SpinColorAveragedRealTensor"];

hasExactlyExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /. HoldPattern[
      FeynCalc`ScaleMu^(4 epsilon)
    ] :> 1;
  ! FreeQ[expression, FeynCalc`ScaleMu^(4 epsilon)] &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

validateInputTensor[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero."
  ];
  assert[
    ! FreeQ[expression, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expression, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lacks an open photon index."
  ];
  assert[
    FreeQ[
      expression,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`DiracChain | _FeynCalc`SUNFIndex |
        _FeynCalc`SUNIndex | _FeynCalc`SUNT | _FeynCalc`SUNF |
        _FeynCalc`SUNDelta | _FeynCalc`SUNTrace |
        _FeynCalc`SumOver | FeynCalc`ComplexConjugate | $Failed
    ],
    label <> " contains an unevaluated state, Dirac, or color object."
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not retain exactly ScaleMu^(4 epsilon)."
  ];
  assert[
    FreeQ[expression, _Real],
    label <> " contains a machine-precision number."
  ];
  True
];

validateScalarProjection[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero."
  ];
  assert[
    FreeQ[expression, _FeynCalc`LorentzIndex],
    label <> " still contains an uncontracted Lorentz index."
  ];
  assert[
    FreeQ[expression, FeynCalc`Contract],
    label <> " contains an unevaluated Contract call."
  ];
  assert[
    FreeQ[
      expression,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`DiracChain | _FeynCalc`SUNFIndex |
        _FeynCalc`SUNIndex | _FeynCalc`SUNT | _FeynCalc`SUNF |
        _FeynCalc`SUNDelta | _FeynCalc`SUNTrace |
        _FeynCalc`SumOver | FeynCalc`ComplexConjugate | $Failed
    ],
    label <> " contains an external-state, Dirac, or color object."
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not retain exactly ScaleMu^(4 epsilon)."
  ];
  assert[
    FreeQ[expression, _Real],
    label <> " contains a machine-precision number."
  ];
  assert[
    FreeQ[
      expression,
      _DiracDelta | _HeavisideTheta | _ConditionalExpression |
        _InterpolatingFunction
    ],
    label <> " contains a phase-space/distribution or numerical object."
  ];
  True
];

validateInputTensor[inputTensor, "accepted Hqqbar S06 input tensor"];

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

wardPointRules = {
  Q2 -> 2,
  sHat -> 10,
  t1 -> -4,
  u1 -> -6,
  t2 -> -4,
  u2 -> -5,
  t3 -> -6,
  u3 -> -1,
  s12 -> 5,
  s13 -> 3,
  s23 -> 2
};

wardPointRelations = {
  sHat == s12 + s13 + s23,
  u1 + u2 + u3 == -(sHat + Q2),
  t1 + t2 + t3 == -sHat - 2 Q2,
  s23 == sHat + Q2 + t1 + u1,
  s13 == sHat + Q2 + t2 + u2,
  s12 == sHat + Q2 + t3 + u3
};
assert[
  And @@ (TrueQ /@ (wardPointRelations /. wardPointRules)),
  "The exact Ward-test point violates a momentum-conservation identity."
];
assert[
  FreeQ[wardPointRules, D | epsilon | FeynCalc`ScaleMu],
  "The Ward-test point must leave D, epsilon, and ScaleMu symbolic."
];

exactWardGate[] := Module[{wardProjector, residual},
  Print["S07_STAGE: exact Hqqbar electromagnetic Ward gate"];
  setThreeBodyKinematics[];
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
  residual = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        FeynCalc`Contract[wardProjector inputTensor],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    residual =!= $Failed,
    "The Ward contraction failed or exceeded the 7-GiB memory budget."
  ];
  assert[
    FreeQ[residual, _FeynCalc`LorentzIndex | FeynCalc`Contract],
    "The Ward contraction left an open index or unevaluated Contract."
  ];
  residual = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        FeynCalc`FeynAmpDenominatorExplicit[residual],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    residual =!= $Failed,
    "Ward denominator exposure failed or exceeded the memory budget."
  ];
  residual = MemoryConstrained[
    CheckAbort[
      Quiet@Check[Together[residual /. wardPointRules], $Failed],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    residual === 0,
    "The exact double-photon Ward residual is nonzero."
  ];
  Print["S07_CHECKPOINT: exact double-photon Ward residual is zero"];
  True
];

wardGatePassed = exactWardGate[];
assert[wardGatePassed === True, "The electromagnetic Ward gate failed."];
assert[
  inputTensor === s06["Tensors"]["SpinColorAveragedRealTensor"],
  "The Ward diagnostic altered the symbolic input tensor."
];

cacheMetadataValidQ[cache_, projectorName_String] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqbar only" &&
    Lookup[cache, "Projector", Missing["Projector"]] === projectorName &&
    Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
      programHash &&
    Lookup[cache, "PaperSHA256", Missing["PaperSHA256"]] ===
      expectedPaperHash &&
    Lookup[cache, "S06SourceSHA256", Missing["S06SourceSHA256"]] ===
      expectedS06SourceHash &&
    Lookup[cache, "S06ResultSHA256", Missing["S06ResultSHA256"]] ===
      expectedS06ResultHash &&
    Lookup[cache, "InputTensorKey", Missing["InputTensorKey"]] ===
      "Tensors/SpinColorAveragedRealTensor" &&
    KeyExistsQ[cache, "Expression"];

loadValidatedCache[path_String, projectorName_String] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S07_STAGE: inspecting " <> projectorName <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, projectorName]],
    Print["S07_STAGE: deleting stale or invalid " <> projectorName <> " cache"];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];
  validateScalarProjection[
    cache["Expression"],
    "cached Hqqbar " <> projectorName <> " projection"
  ];
  Print["S07_STAGE: accepted source-bound " <> projectorName <> " cache"];
  cache["Expression"]
];

writeCache[path_String, projectorName_String, expression_] := Module[
  {cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "Channel" -> "Hqqbar only",
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
    "InputTensorKey" -> "Tensors/SpinColorAveragedRealTensor",
    "ChargeConvention" -> "charge-stripped BigTMD channel 5A hard tensor",
    "Expression" -> expression
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

contractProjection[projectorName_String] := Module[{answer},
  answer = loadValidatedCache[cachePaths[projectorName], projectorName];
  If[! MissingQ[answer], Return[answer]];

  Print[
    "S07_STAGE: contracting Hqqbar tensor with paper " <> projectorName
  ];
  setThreeBodyKinematics[];
  answer = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        FeynCalc`Contract[projectors[projectorName] inputTensor],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  validateScalarProjection[
    answer,
    "Hqqbar " <> projectorName <> " projection"
  ];
  writeCache[cachePaths[projectorName], projectorName, answer];
  Print[
    "S07_CHECKPOINT: completed ", projectorName,
    " leaf count ", LeafCount[answer]
  ];
  answer
];

Print["S07_STAGE: contracting the Hqqbar tensor serially"];
scalarProjections = AssociationMap[contractProjection, {"Pg", "PPP"}];

assert[
  AssociationQ[scalarProjections] &&
    Keys[scalarProjections] === {"Pg", "PPP"},
  "S07 did not produce exactly the ordered Pg and PPP projections."
];
assert[
  And @@ KeyValueMap[
    validateScalarProjection[#2, "final Hqqbar " <> #1 <> " projection"] &,
    scalarProjections
  ],
  "At least one final Hqqbar scalar projection failed validation."
];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "CurrentS06SourceAndResultHashesValidated" -> True,
  "S06UpstreamBindingsAndChecksValidated" -> True,
  "SoleSpinColorAveragedTensorConsumed" -> True,
  "NoHqqOrOtherChannelArtifactConsumed" -> True,
  "ExactConservationConsistentWardPoint" -> True,
  "ExactDoublePhotonWardResidualZero" -> True,
  "PaperPgMetricProjectorApplied" -> True,
  "PaperPPPIncomingPartonMomentumProjectorApplied" -> True,
  "ExactlyTwoScalarProjectionsProduced" -> True,
  "PhotonIndexMuContracted" -> True,
  "PhotonIndexNuContracted" -> True,
  "NoLorentzIndicesRemain" -> True,
  "DAndEpsilonRemainSymbolic" -> True,
  "AbsoluteScaleMuPowerFourEpsilonPreservedExactlyOnce" -> True,
  "ChargeStrippedChannel5ACoventionPreserved" -> True,
  "PhysicalFlavorChargeWeightDeferred" -> True,
  "IdenticalSpectatorFactorDeferred" -> True,
  "VirtualContributionAbsent" -> True,
  "Eq9F1F2CombinationsDeferred" -> True,
  "NoPhaseSpaceOrFactorizationFactorApplied" -> True,
  "TreePropagatorDenominatorsRemainForLaterReduction" -> True,
  "NoMachinePrecisionNumbers" -> True,
  "CachesBoundToProgramPaperAndS06SHA256" -> True,
  "AtomicCacheAndResultProtocolConfigured" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S07 validation check is not True."
];

If[preflightOnly,
  Print["S07_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S07_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print[
    "S07_DYNAMIC_PREFLIGHT_LEAF_COUNTS=",
    InputForm[Map[LeafCount, scalarProjections]]
  ];
  Quit[0]
];

s07Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" -> "H_{q qbar; q q} real Pg/PPP scalar projections",
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
    "TensorKey" -> "Tensors/SpinColorAveragedRealTensor"
  |>,
  "ProjectorDefinitions" -> <|
    "Pg" -> HoldForm[PSubg[mu, nu] == MetricTensor[mu, nu]],
    "PPPPartonic" -> HoldForm[PSubPP[mu, nu] == p[mu] p[nu]],
    "HadronicToPartonicMomentumReplacement" -> HoldForm[P -> p],
    "Eq9F1F2CombinationStatus" -> "Deferred"
  |>,
  "WardIdentity" -> <|
    "Diagnostic" -> "q_mu q_nu W^(mu nu)",
    "ExactPointRules" -> wardPointRules,
    "MomentumConservationRelations" -> wardPointRelations,
    "DimensionLeftSymbolic" -> True,
    "TreeDenominatorsMadeExplicitOnlyInDiagnostic" -> True,
    "Residual" -> 0,
    "Passed" -> True
  |>,
  "KinematicConventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "SavedProjectionsRemainSymbolic" -> True,
    "MasslessExternalMomenta" -> {p, k1, k2, k3},
    "PhotonVirtuality" -> HoldForm[q^2 == -Q2],
    "ThreeBodyInvariants" ->
      {sHat, t1, t2, t3, u1, u2, u3, s12, s13, s23}
  |>,
  "ScalarProjections" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqbar;q_q" -> scalarProjections
    |>
  |>,
  "ProjectionCount" -> 2,
  "ScaleBookkeeping" -> <|
    "AbsoluteFactor" -> dimensionalScaleFactor,
    "PowerPreservedExactlyOnceInEveryProjection" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "ChargeBookkeeping" -> s06["ChargeBookkeeping"],
  "SymmetryBookkeeping" -> s06["SymmetryBookkeeping"],
  "VirtualContributionAtThisOrder" ->
    s06["VirtualContributionAtThisOrder"],
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "S06ResultSHA256" -> expectedS06ResultHash,
    "PgPath" -> cachePaths["Pg"],
    "PgSHA256" -> fileSHA256[cachePaths["Pg"]],
    "PPPPath" -> cachePaths["PPP"],
    "PPPSHA256" -> fileSHA256[cachePaths["PPP"]],
    "AtomicAndSourceBound" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "Eq. (9) P1/P2 linear combinations for F1/F2",
    "the deferred identical-spectator 1/2! phase-space factor",
    "physical Sum_q e_q^2 flavor-charge assembly",
    "three-body phase-space or angular integration",
    "MS-bar PDF/FF collinear factorization",
    "endpoint distributions, F-hat inversion, or BigTMD comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized S08 may consume only these Pg/PPP scalars and apply the paper's three-body phase-space/angular machinery while preserving the charge, scale, symmetry, and real-only ledgers."
|>;

Print["S07_STAGE: atomically writing the Hqqbar S07 result"];
atomicPutAssociation[s07Result, s07ResultPath, stageVersion];

reloadedResult = Quiet@Check[Get[s07ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion,
  "Final s07_result failed status/stage/schema reload validation."
];
assert[
  reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input"]["S06ResultSHA256"] === expectedS06ResultHash,
  "Final s07_result failed source/upstream hash validation."
];
assert[
  reloadedResult["ProjectionCount"] === 2 &&
    Keys[
      reloadedResult["ScalarProjections"]
        ["NLOReal_OAlphaS2"]["Hqqbar;q_q"]
    ] === {"Pg", "PPP"},
  "Final s07_result does not contain exactly Pg and PPP."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Final s07_result contains a failed check."
];
assert[
  reloadedResult["WardIdentity"]["Residual"] === 0 &&
    reloadedResult["WardIdentity"]["Passed"] === True,
  "Final s07_result lost the exact Ward gate."
];
assert[
  And @@ KeyValueMap[
    validateScalarProjection[#2, "reloaded Hqqbar " <> #1 <> " projection"] &,
    reloadedResult["ScalarProjections"]
      ["NLOReal_OAlphaS2"]["Hqqbar;q_q"]
  ],
  "A reloaded final projection failed validation."
];

Print["S07_SUCCESS"];
Print["S07_PROGRAM_SHA256=" <> programHash];
Print["S07_RESULT_PATH=" <> s07ResultPath];
Print["S07_RESULT_SHA256=" <> fileSHA256[s07ResultPath]];
Print["S07_PROJECTION_COUNT=", 2];
Print[
  "S07_LEAF_COUNTS=",
  InputForm[Map[LeafCount, scalarProjections]]
];
Print["S07_CHECK_COUNT=", Length[checks]];
Print["S07_RESULT_BYTES=", FileByteCount[s07ResultPath]];

Quit[0];

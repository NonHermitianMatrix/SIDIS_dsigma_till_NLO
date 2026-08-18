(* ::Package:: *)

(*
  Sum every external-fermion spin and color state in the sole Hqqbar real
  bilinear and apply exactly the incoming-quark average 1/(2 N_c):

    gamma*(q) + q(p) -> qbar(k1, fragmenting) + q(k2) + q(k3).

  The photon indices s05Mu and s05Nu remain open.  This stage introduces no
  gluon polarization sum, virtual term, physical charge weight, identical-
  spectator 1/2!, phase-space factor, projector, or numerical approximation.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, fileSHA256, atomicPutAssociation,
  hasExactlyExpectedScaleQ, validatePostDiracTensor,
  validateColorSummedTensor, setThreeBodyKinematics,
  cacheMetadataValidQ, loadValidatedCache, writeCache
];

activeTemporaryPath = "";

fatal[message_String] := (
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S06_FATAL: " <> message];
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
s05SourcePath =
  FileNameJoin[{scriptDirectory, "s05_form_hqqbar_real_bilinear.wl"}];
s05ResultPath = FileNameJoin[{scriptDirectory, "s05_result"}];
s06ResultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
postDiracCachePath =
  FileNameJoin[{scriptDirectory, "s06_cache_hqqbar_after_dirac"}];
finalCachePath =
  FileNameJoin[{scriptDirectory, "s06_cache_hqqbar_spin_color"}];

stageVersion = "HqqbarS06-v1";
cacheStageVersion = "HqqbarS06Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S06_PREFLIGHT_ONLY"], ""] === "1";
memoryBudgetBytes = 7 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS05SourceHash =
  "af499834c79fd69e69f33306a2e049a32f3d2ed88a50afcc65d5d37b0b9fd29e";
expectedS05ResultHash =
  "b72245cd5200ab0e649588ca77607feb21c152be2e20faead5ef74bc992a5f17";
expectedS01SourceHash =
  "750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71";
expectedS01ResultHash =
  "69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4";
expectedS04SourceHash =
  "b4afa7ff960449b2df5dbd38886e8e2a49aa2c14ed06d4cea515edcca65284e3";
expectedS04ResultHash =
  "b92526579c1aff40f40d305fe0087b000dde45355391843364c4ea5e52f72e9e";

programHash = fileSHA256[programPath];
s05ResultHash = fileSHA256[s05ResultPath];
dimensionalScaleFactor = FeynCalc`ScaleMu^(4 epsilon);
initialAverageDenominator = 2 FeynCalc`SUNN;

staleTemporaryPaths = Join[
  FileNames["s06_result.tmp.*", scriptDirectory],
  FileNames["s06_cache_hqqbar*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "A stale S06 temporary file exists and must be resolved before running."
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[s06ResultPath],
    "s06_result already exists; validate or deliberately remove it before regeneration."
  ]
];

Print["S06_STAGE: validating the paper and accepted S05 handoff"];
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
    "S05 source" -> {s05SourcePath, expectedS05SourceHash},
    "S05 result" -> {s05ResultPath, expectedS05ResultHash}
  |>
];

s05 = Quiet@Check[Get[s05ResultPath], $Failed];
assert[AssociationQ[s05], "s05_result is not an Association."];
assert[
  s05["Status"] === "Complete" &&
    s05["Stage"] === "HqqbarS05-v1" &&
    s05["ResultSchemaVersion"] === 1 &&
    s05["Channel"] === "Hqqbar only" &&
    s05["Contribution"] === "H_{q qbar; q q} real bilinear",
  "The S05 status, stage, schema, channel, or contribution is invalid."
];
assert[
  s05["ProgramSHA256"] === expectedS05SourceHash,
  "S05 does not bind the accepted S05 source."
];
assert[
  s05["Input"]["S01SourceSHA256"] === expectedS01SourceHash &&
    s05["Input"]["S01ResultSHA256"] === expectedS01ResultHash &&
    s05["Input"]["S04SourceSHA256"] === expectedS04SourceHash &&
    s05["Input"]["S04ResultSHA256"] === expectedS04ResultHash,
  "An S05 upstream SHA-256 binding is invalid."
];
assert[
  And @@ (TrueQ /@ Values[s05["Checks"]]),
  "At least one accepted S05 check is not True."
];
assert[
  s05["DiagramCounts"]["NLORealHqqbarQQ"] === 8 &&
    s05["DiagramCounts"]["CoherentOrderedDiagramPairs"] === 64,
  "S05 does not contain the accepted eight-diagram coherent real square."
];
assert[
  s05["VirtualContributionAtThisOrder"]["Applicable"] === False &&
    s05["VirtualContributionAtThisOrder"]["Interference"] === 0,
  "S05 violates the Hqqbar no-virtual contract."
];
assert[
  s05["ChargeBookkeeping"]["FullAmplitudesAreChargeStripped"] === True &&
    s05["ChargeBookkeeping"]["PhysicalChargeWeightAppliedAtS05"] === False &&
    s05["ChargeBookkeeping"]["BigTMDChannel"] === 5,
  "S05 charge stripping or deferred physical-charge bookkeeping is invalid."
];
assert[
  s05["SymmetryAndAverageBookkeeping"]
      ["IdenticalSpectatorFactorAppliedAtS05"] === False &&
    s05["SymmetryAndAverageBookkeeping"]
      ["IncomingQuarkSpinColorAverageAppliedAtS05"] === False,
  "S05 symmetry-factor or incoming-average deferral is invalid."
];

expectedExternalSpinors = {
  FeynCalc`Spinor[FeynCalc`Momentum[p, D], 0, 1],
  FeynCalc`Spinor[-FeynCalc`Momentum[k1, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k2, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k3, D], 0, 1]
};
storedExternalSpinors = s05["ExternalProcess"]["ExternalSpinors"];
assert[
  Length[storedExternalSpinors] === 4 &&
    And @@ (MemberQ[storedExternalSpinors, #] & /@ expectedExternalSpinors),
  "S05 does not record exactly the four expected external fermion spinors."
];

inputCoreTensor = s05["Bilinear"]["ChargeStrippedCore"];
inputTensor = s05["Bilinear"]["ScaleAttachedRealTensor"];
assert[
  s05["Bilinear"]["DimensionalScaleFactor"] ===
      dimensionalScaleFactor &&
    inputTensor === dimensionalScaleFactor inputCoreTensor &&
    FreeQ[inputCoreTensor, FeynCalc`ScaleMu],
  "S05's absolute ScaleMu^(4 epsilon) attachment is invalid."
];
assert[
  inputCoreTensor ===
    s05["FullExternalStateAmplitudes"]["OpenPhotonIndexMu"]
      s05["FullExternalStateAmplitudes"]
        ["ConjugateOpenPhotonIndexNu"],
  "S05's coherent open-index bilinear does not reconstruct exactly."
];
assert[
  And @@ (MemberQ[Cases[inputTensor, _FeynCalc`Spinor, Infinity], #] & /@
    expectedExternalSpinors),
  "The S06 input lacks at least one required external spinor."
];
assert[
  ! FreeQ[inputTensor, FeynCalc`LorentzIndex[s05Mu, D]] &&
    ! FreeQ[inputTensor, FeynCalc`LorentzIndex[s05Nu, D]],
  "The S06 input is missing an open photon index."
];
assert[
  FreeQ[inputTensor, _FeynCalc`Polarization],
  "The all-fermion Hqqbar input unexpectedly contains a polarization vector."
];
assert[
  FreeQ[
    inputTensor,
    FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`TID | FeynCalc`EpsilonUV |
      FeynCalc`EpsilonIR
  ] && FreeQ[inputTensor, _Real],
  "The S06 input contains loop/regulator data or machine numbers."
];

hasExactlyExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /. HoldPattern[
      FeynCalc`ScaleMu^(4 epsilon)
    ] :> 1;
  ! FreeQ[expression, FeynCalc`ScaleMu^(4 epsilon)] &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

validatePostDiracTensor[expression_, label_String] := Module[{},
  assert[expression =!= $Failed, label <> " evaluation returned $Failed."];
  assert[
    FreeQ[expression, _FeynCalc`Spinor],
    label <> " still contains an external spinor."
  ];
  assert[
    FreeQ[expression, _FeynCalc`Polarization],
    label <> " contains an external polarization vector."
  ];
  assert[
    FreeQ[
      expression,
      _FeynCalc`DiracTrace | _FeynCalc`DiracGamma |
        _FeynCalc`DiracChain
    ],
    label <> " still contains an unevaluated Dirac object."
  ];
  assert[
    ! FreeQ[expression, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expression, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost an open photon index."
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

validateColorSummedTensor[expression_, label_String] := Module[{},
  validatePostDiracTensor[expression, label];
  assert[
    FreeQ[
      expression,
      _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex | _FeynCalc`SUNT |
        _FeynCalc`SUNF | _FeynCalc`SUNDelta | _FeynCalc`SUNTrace |
        _FeynCalc`SumOver
    ],
    label <> " still contains an explicit color index, generator, or sum."
  ];
  True
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

cacheMetadataValidQ[cache_, cacheKind_String] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "CacheKind", Missing["CacheKind"]] === cacheKind &&
    Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
      programHash &&
    Lookup[cache, "S05SourceSHA256", Missing["S05SourceSHA256"]] ===
      expectedS05SourceHash &&
    Lookup[cache, "S05ResultSHA256", Missing["S05ResultSHA256"]] ===
      expectedS05ResultHash &&
    AssociationQ[Lookup[cache, "Payload", Missing["Payload"]]];

loadValidatedCache[path_String, cacheKind_String] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S06_STAGE: inspecting " <> cacheKind <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, cacheKind]],
    Print["S06_STAGE: deleting stale or invalid " <> cacheKind <> " cache"];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];

  If[cacheKind === "PostDirac",
    assert[
      KeyExistsQ[cache["Payload"], "PostDiracTensor"],
      "The PostDirac cache lacks its tensor payload."
    ];
    validatePostDiracTensor[
      cache["Payload"]["PostDiracTensor"],
      "cached post-Dirac Hqqbar tensor"
    ],
    assert[
      KeyExistsQ[cache["Payload"], "ColorSummedUnaveragedTensor"] &&
        KeyExistsQ[cache["Payload"], "SpinColorAveragedTensor"],
      "The Final cache lacks a required tensor payload."
    ];
    validateColorSummedTensor[
      cache["Payload"]["ColorSummedUnaveragedTensor"],
      "cached color-summed unaveraged Hqqbar tensor"
    ];
    validateColorSummedTensor[
      cache["Payload"]["SpinColorAveragedTensor"],
      "cached spin/color-averaged Hqqbar tensor"
    ];
    assert[
      cache["Payload"]["SpinColorAveragedTensor"] ===
        cache["Payload"]["ColorSummedUnaveragedTensor"]/
          initialAverageDenominator,
      "The Final cache does not contain exactly one 1/(2 Nc) average."
    ]
  ];
  Print["S06_STAGE: accepted source-bound " <> cacheKind <> " cache"];
  cache
];

writeCache[path_String, cacheKind_String, payload_Association] := Module[
  {cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "CacheKind" -> cacheKind,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "S05SourcePath" -> s05SourcePath,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultPath" -> s05ResultPath,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "Payload" -> payload
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

Print["S06_STAGE: processing the coherent Hqqbar real tensor"];
setThreeBodyKinematics[];

finalCache = loadValidatedCache[finalCachePath, "Final"];
If[MissingQ[finalCache],
  postDiracCache = loadValidatedCache[postDiracCachePath, "PostDirac"];

  If[MissingQ[postDiracCache],
    Print["S06_STAGE: summing all four external fermion spins"];
    postDiracTensor = MemoryConstrained[
      CheckAbort[
        Quiet@Check[
          FeynCalc`FermionSpinSum[
            inputTensor,
            FeynCalc`FCParallelize -> False,
            FeynCalc`FCVerbose -> 0
          ],
          $Failed
        ],
        $Failed
      ],
      memoryBudgetBytes,
      $Failed
    ];
    assert[
      postDiracTensor =!= $Failed,
      "FermionSpinSum failed or exceeded the 7-GiB kernel memory budget."
    ];

    Print["S06_STAGE: evaluating all D-dimensional Dirac traces"];
    postDiracTensor = MemoryConstrained[
      CheckAbort[
        Quiet@Check[
          FeynCalc`DiracSimplify[
            postDiracTensor,
            FeynCalc`DiracTrace -> True,
            FeynCalc`DiracTraceEvaluate -> True,
            FeynCalc`DiracSubstitute67 -> True,
            FeynCalc`ToDiracGamma67 -> False,
            FeynCalc`FCParallelize -> False,
            FeynCalc`FCVerbose -> 0,
            FeynCalc`Factoring -> False
          ],
          $Failed
        ],
        $Failed
      ],
      memoryBudgetBytes,
      $Failed
    ];
    validatePostDiracTensor[postDiracTensor, "post-Dirac Hqqbar tensor"];
    writeCache[
      postDiracCachePath,
      "PostDirac",
      <|"PostDiracTensor" -> postDiracTensor|>
    ];
    Print[
      "S06_CHECKPOINT: post-Dirac tensor leaf count ",
      LeafCount[postDiracTensor]
    ],
    postDiracTensor = postDiracCache["Payload"]["PostDiracTensor"]
  ];

  Print["S06_STAGE: summing all colors"];
  colorSummedUnaveragedTensor = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        FeynCalc`SUNSimplify[
          postDiracTensor,
          TimeConstrained -> Infinity,
          FeynCalc`SUNNToCACF -> True,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0
        ],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  validateColorSummedTensor[
    colorSummedUnaveragedTensor,
    "color-summed unaveraged Hqqbar tensor"
  ];

  Print["S06_STAGE: applying exactly the incoming-quark average 1/(2 Nc)"];
  spinColorAveragedTensor =
    colorSummedUnaveragedTensor/initialAverageDenominator;
  validateColorSummedTensor[
    spinColorAveragedTensor,
    "spin/color-averaged Hqqbar tensor"
  ];
  assert[
    spinColorAveragedTensor ===
      colorSummedUnaveragedTensor/initialAverageDenominator,
    "The final tensor does not equal the color-summed tensor divided by 2 Nc."
  ];
  writeCache[
    finalCachePath,
    "Final",
    <|
      "ColorSummedUnaveragedTensor" -> colorSummedUnaveragedTensor,
      "SpinColorAveragedTensor" -> spinColorAveragedTensor
    |>
  ];
  Print[
    "S06_CHECKPOINT: final tensor leaf count ",
    LeafCount[spinColorAveragedTensor]
  ],
  colorSummedUnaveragedTensor =
    finalCache["Payload"]["ColorSummedUnaveragedTensor"];
  spinColorAveragedTensor =
    finalCache["Payload"]["SpinColorAveragedTensor"]
];

validateColorSummedTensor[
  colorSummedUnaveragedTensor,
  "final color-summed unaveraged Hqqbar tensor"
];
validateColorSummedTensor[
  spinColorAveragedTensor,
  "final spin/color-averaged Hqqbar tensor"
];
assert[
  spinColorAveragedTensor ===
    colorSummedUnaveragedTensor/initialAverageDenominator,
  "Final exact incoming-average audit failed."
];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "S05SourceHashValidated" -> True,
  "S05ResultHashValidated" -> True,
  "S05UpstreamBindingsValidated" -> True,
  "S05ChecksValidated" -> True,
  "SoleEightDiagramRealSquareProcessed" -> True,
  "AllFourExternalFermionSpinsSummed" -> True,
  "AllDDiracTracesEvaluated" -> True,
  "AllFundamentalColorsSummed" -> True,
  "IncomingQuarkSpinAverageOneHalfAppliedExactlyOnce" -> True,
  "IncomingQuarkColorAverageOneOverNcAppliedExactlyOnce" -> True,
  "FinalStatesSummedNotAveraged" -> True,
  "NoGluonOrPhotonPolarizationSumApplied" -> True,
  "PhotonIndexMuPreserved" -> True,
  "PhotonIndexNuPreserved" -> True,
  "AbsoluteScaleMuPowerFourEpsilonPreservedExactlyOnce" -> True,
  "NoSeparateMSBarSEpsilonAdded" -> True,
  "PhysicalFlavorChargeWeightDeferred" -> True,
  "IdenticalSpectatorFactorDeferred" -> True,
  "VirtualContributionAbsent" -> True,
  "NoProjectorOrPhaseSpaceFactorApplied" -> True,
  "NoLoopOrRegulatorDataIntroduced" -> True,
  "NoMachinePrecisionNumbers" -> True,
  "CachesBoundToProgramAndS05SHA256" -> True,
  "AtomicCacheAndResultProtocolConfigured" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S06 validation check is not True."
];

If[preflightOnly,
  Print["S06_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S06_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print[
    "S06_DYNAMIC_PREFLIGHT_POST_DIRAC_LEAF_COUNT=",
    LeafCount[postDiracTensor]
  ];
  Print[
    "S06_DYNAMIC_PREFLIGHT_FINAL_LEAF_COUNT=",
    LeafCount[spinColorAveragedTensor]
  ];
  Quit[0]
];

s06Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "H_{q qbar; q q} spin/color-summed and incoming-averaged real tensor",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "NormalizationStatements" -> {
      "Eq. (14): incoming unpolarized spin average 1/2 and final-state sum",
      "Eq. (19): squared amplitudes feed the later phase-space integral",
      "Eqs. (38)-(39): labelled three-body phase space is later"
    }
  |>,
  "Input" -> <|
    "S05SourcePath" -> s05SourcePath,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultPath" -> s05ResultPath,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "S05TensorKey" -> "Bilinear/ScaleAttachedRealTensor"
  |>,
  "ExternalStateBookkeeping" -> <|
    "Incoming" -> "q(p)",
    "Fragmenting" -> "qbar(k1)",
    "Unobserved" -> {"q(k2)", "q(k3)"},
    "AllFourFermionSpinsSummed" -> True,
    "AllFinalAndInitialColorsSummed" -> True,
    "InitialStateAverage" -> HoldForm[1/(2 FeynCalc`SUNN)],
    "InitialSpinStates" -> 2,
    "InitialColorStates" -> FeynCalc`SUNN,
    "FinalStatesAreSummedNotAveraged" -> True
  |>,
  "KinematicConventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "MasslessExternalMomenta" -> {p, k1, k2, k3},
    "PhotonVirtuality" -> HoldForm[q^2 == -Q2],
    "ThreeBodyInvariants" -> {sHat, t1, t2, t3, u1, u2, u3, s12, s13, s23}
  |>,
  "ScaleBookkeeping" -> <|
    "AbsoluteFactor" -> dimensionalScaleFactor,
    "PowerPreservedExactlyOnce" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "ChargeBookkeeping" -> <|
    "TensorIsChargeStripped" -> True,
    "PhysicalChargeWeight" -> "Sum_q e_q^2 f_q D_qbar",
    "PhysicalChargeWeightAppliedAtS06" -> False,
    "BigTMDChannel" -> 5,
    "BigTMDChargeCase" -> "A only"
  |>,
  "SymmetryBookkeeping" -> <|
    "IdenticalUnobservedQuarks" -> {"q(k2)", "q(k3)"},
    "IdenticalSpectatorFactorAppliedAtS06" -> False,
    "IdenticalSpectatorFactorDeferred" -> HoldForm[1/2!],
    "Destination" -> "fully integrated three-body spectator phase space"
  |>,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "Tensors" -> <|
    "ColorSummedUnaveragedRealTensor" -> colorSummedUnaveragedTensor,
    "SpinColorAveragedRealTensor" -> spinColorAveragedTensor
  |>,
  "SpinColorAveragedTensors" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqbar;q_q" -> spinColorAveragedTensor
    |>
  |>,
  "VirtualContributionAtThisOrder" -> <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" ->
      s05["VirtualContributionAtThisOrder"]["SourceDisposition"]
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "PostDiracPath" -> postDiracCachePath,
    "PostDiracSHA256" -> fileSHA256[postDiracCachePath],
    "FinalPath" -> finalCachePath,
    "FinalSHA256" -> fileSHA256[finalCachePath],
    "AtomicAndSourceBound" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "gluon or photon polarization sums",
    "the deferred identical-spectator 1/2! phase-space factor",
    "physical Sum_q e_q^2 flavor-charge assembly",
    "projector contraction",
    "three-body phase-space integration",
    "MS-bar PDF/FF collinear factorization",
    "F-hat inversion or BigTMD comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized S07 may contract only Tensors/SpinColorAveragedRealTensor with the paper's Pg and PPP projectors. It must preserve the charge, scale, symmetry, and real-only ledgers recorded here."
|>;

Print["S06_STAGE: atomically writing the Hqqbar S06 result"];
atomicPutAssociation[s06Result, s06ResultPath, stageVersion];

reloadedResult = Quiet@Check[Get[s06ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion,
  "Final s06_result failed status/stage/schema reload validation."
];
assert[
  reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input"]["S05ResultSHA256"] === expectedS05ResultHash,
  "Final s06_result failed source/upstream hash validation."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Final s06_result contains a failed check."
];
assert[
  reloadedResult["Tensors"]["SpinColorAveragedRealTensor"] ===
    reloadedResult["Tensors"]["ColorSummedUnaveragedRealTensor"]/
      initialAverageDenominator,
  "Final s06_result failed the exact 1/(2 Nc) reload audit."
];
validateColorSummedTensor[
  reloadedResult["Tensors"]["SpinColorAveragedRealTensor"],
  "reloaded final Hqqbar tensor"
];

Print["S06_SUCCESS"];
Print["S06_PROGRAM_SHA256=" <> programHash];
Print["S06_RESULT_PATH=" <> s06ResultPath];
Print["S06_RESULT_SHA256=" <> fileSHA256[s06ResultPath]];
Print["S06_CHECK_COUNT=", Length[checks]];
Print["S06_FINAL_LEAF_COUNT=", LeafCount[spinColorAveragedTensor]];
Print["S06_RESULT_BYTES=", FileByteCount[s06ResultPath]];

Quit[0];

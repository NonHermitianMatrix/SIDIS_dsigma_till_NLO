(* ::Package:: *)

(*
  Contract the three spin/color-averaged Hqg tensors in s06_result with the
  two extraction tensors used in the paper:

    P_g^(mu nu)  = g^(mu nu),
    P_PP^(mu nu) = p^mu p^nu  (partonic analogue of P^mu P^nu).

  The six outputs remain exact, scalar, and unintegrated.  They are bound to
  BigTMD channel 3, case A, whose separate Pg/Ppp fchn3A kernel families are
  compared only after phase space, real-virtual combination, and collinear
  factorization.  No Eq. (9) P1/P2 combination or cross-section normalization
  is applied at this stage.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setTwoBodyKinematics, setThreeBodyKinematics,
  validateInputTensor, validateScalarProjection, loadValidatedCache,
  writeValidatedCache, contractProjection, contractBothProjectors
];

fatal[message_String] := (
  Print["S07_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s06Path = FileNameJoin[{scriptDirectory, "s06_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
stageVersion = "HqgS07-v3";

cachePaths = <|
  "LO" -> <|
    "Pg" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_lo_g"}],
    "PPP" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_lo_pp"}]
  |>,
  "RealQG" -> <|
    "Pg" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_real_qg_g"}],
    "PPP" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_real_qg_pp"}]
  |>,
  "VirtualInterference" -> <|
    "Pg" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_virtual_interference_g"
    }],
    "PPP" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_virtual_interference_pp"
    }]
  |>
|>;

Print["S07_STAGE: loading validated Hqg s06_result"];
assert[FileExistsQ[s06Path], "s06_result does not exist."];
s06 = Check[Get[s06Path], $Failed];
assert[AssociationQ[s06], "s06_result did not load as an Association."];
assert[
  s06["Status"] === "Complete" &&
    s06["Stage"] === "HqgS06-v3" &&
    s06["Channel"] === "Hqg only",
  "s06_result is not the complete Hqg S06 result."
];
assert[
  AllTrue[Values[s06["Checks"]], TrueQ],
  "At least one S06 validation check is not True."
];
assert[
  FileExistsQ[s06["SourceResult"]] &&
    s06["SourceResultSHA256"] ===
      FileHash[s06["SourceResult"], "SHA256"],
  "The S06 source-result binding is stale."
];
assert[
  FileExistsQ[s06["Program"]] &&
    s06["ProgramSHA256"] === FileHash[s06["Program"], "SHA256"],
  "The S06 program binding is stale."
];
assert[
  IntegerQ[s06["ReferencePDFSHA256"]],
  "S06 has no exact reference-paper hash."
];
assert[
  s06["BigTMDConvention", "ChannelNumber"] === 3 &&
    s06["BigTMDConvention", "ChargeCase"] === "A only",
  "S06 is not bound to BigTMD Hqg channel 3, case A."
];
assert[
  s06["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s06["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s06["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g",
  "S06 is not in the corrected charge-stripped hard-kernel convention."
];
assert[
  s06["InitialState"] === "quark q(p)" &&
    s06["FragmentingParton"] === "gluon g(k1)" &&
    s06["InitialStateAverage"] === HoldForm[1/(2 FeynCalc`SUNN)],
  "S06 does not preserve the Hqg initial/fragmenting-state convention."
];

s06SHA256 = FileHash[s06Path, "SHA256"];

tensors = <|
  "LO" -> s06["SpinColorAveragedTensors", "LO_OAlphaS"],
  "RealQG" -> s06[
    "SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hqg;qg"
  ],
  "VirtualInterference" -> s06[
    "SpinColorAveragedTensors",
    "NLOVirtualInterference_OAlphaS2_Symbolic"
  ]
|>;

validateInputTensor[expr_, label_String] := Module[{},
  assert[expr =!= $Failed && expr =!= 0,
    label <> " is failed or identically zero."];
  assert[
    ! FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lacks an open photon index."
  ];
  assert[
    FreeQ[
      expr,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
        FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
    ],
    label <> " contains an unevaluated state/color object or machine real."
  ];
  True
];

assert[Length[tensors] === 3, "Expected exactly three Hqg input tensors."];
assert[
  And @@ KeyValueMap[
    validateInputTensor[#2, "Hqg " <> #1 <> " tensor"] &,
    tensors
  ],
  "At least one Hqg input tensor failed validation."
];
assert[
  ! FreeQ[tensors["VirtualInterference"], dZq1] &&
    ! FreeQ[tensors["VirtualInterference"], dZGG1] &&
    ! FreeQ[tensors["VirtualInterference"], dZgs1],
  "The Hqg virtual tensor lacks symbolic QCD counterterms."
];

setTwoBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[k1, k2] = sHat/2;
  FeynCalc`SPD[q, k1] = (-Q2 - tHat)/2;
  FeynCalc`SPD[q, k2] = (sHat + tHat)/2;
  FeynCalc`SPD[p, k1] = (Q2 + sHat + tHat)/2;
  FeynCalc`SPD[p, k2] = -tHat/2;
);

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

validateScalarProjection[expr_, label_String] := Module[{},
  assert[expr =!= $Failed && expr =!= 0,
    label <> " is failed or identically zero."];
  assert[
    FreeQ[expr, _FeynCalc`LorentzIndex],
    label <> " still contains an uncontracted Lorentz index."
  ];
  assert[
    FreeQ[expr, FeynCalc`Contract],
    label <> " contains an unevaluated Contract call."
  ];
  assert[
    FreeQ[
      expr,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
        FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
    ],
    label <> " contains an external-state/color object or machine real."
  ];
  True
];

loadValidatedCache[
    path_String, tensorRole_String, projectorName_String
  ] := Module[{cache, validMetadata},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print[
    "S07_STAGE: inspecting " <> tensorRole <> " " <>
      projectorName <> " cache"
  ];
  cache = Quiet@Check[Get[path], $Failed];
  validMetadata =
    AssociationQ[cache] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === tensorRole &&
    cache["Projector"] === projectorName &&
    cache["SourceS06SHA256"] === s06SHA256 &&
    cache["ProgramSHA256"] === programSHA256 &&
    cache["BigTMDChannel"] === 3 &&
    cache["BigTMDChargeCase"] === "A only" &&
    cache["ElectricChargeNormalization"] ===
      s06["ElectricChargeNormalization"] &&
    cache["FragmentingParton"] === "g(k1)" &&
    KeyExistsQ[cache, "Expression"];
  If[! TrueQ[validMetadata],
    Print[
      "S07_STAGE: deleting stale or invalid " <> tensorRole <> " " <>
        projectorName <> " cache"
    ];
    DeleteFile[path];
    Return[Missing["InvalidCache"]]
  ];
  validateScalarProjection[
    cache["Expression"],
    "cached Hqg " <> tensorRole <> " " <> projectorName <> " projection"
  ];
  Print[
    "S07_STAGE: loading validated " <> tensorRole <> " " <>
      projectorName <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[
    path_String, tensorRole_String, projectorName_String, expr_
  ] := Module[{temporaryPath, cache},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> tensorRole,
    "Projector" -> projectorName,
    "SourceS06" -> s06Path,
    "SourceS06SHA256" -> s06SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "BigTMDChannel" -> 3,
    "BigTMDChargeCase" -> "A only",
    "ElectricChargeNormalization" -> s06["ElectricChargeNormalization"],
    "FragmentingParton" -> "g(k1)",
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    tensorRole <> " " <> projectorName <>
      " temporary cache was not written."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    tensorRole <> " " <> projectorName <> " cache was not finalized."
  ];
];

contractProjection[
    tensor_, tensorRole_String, projectorName_String,
    kinematicsSetup_Symbol, label_String
  ] := Module[{answer, path},
  path = cachePaths[tensorRole][projectorName];
  answer = loadValidatedCache[path, tensorRole, projectorName];
  If[! MissingQ[answer], Return[answer]];
  Print[
    "S07_STAGE: contracting " <> label <> " with " <> projectorName
  ];
  kinematicsSetup[];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`Contract[projectors[projectorName] tensor],
      $Failed
    ],
    $Failed
  ];
  validateScalarProjection[
    answer, "Hqg " <> tensorRole <> " " <> projectorName <> " projection"
  ];
  writeValidatedCache[path, tensorRole, projectorName, answer];
  Print[
    "S07_CHECKPOINT: completed " <> tensorRole <> " " <>
      projectorName <> " leaf count " <> ToString[LeafCount[answer]]
  ];
  answer
];

contractBothProjectors[
    tensor_, tensorRole_String, kinematicsSetup_Symbol, label_String
  ] := AssociationMap[
  contractProjection[
    tensor, tensorRole, #, kinematicsSetup, label
  ] &,
  {"Pg", "PPP"}
];

Print["S07_STAGE: contracting all three Hqg tensors"];

loProjections = contractBothProjectors[
  tensors["LO"], "LO", setTwoBodyKinematics, "Hqg LO square"
];
realQGProjections = contractBothProjectors[
  tensors["RealQG"],
  "RealQG",
  setThreeBodyKinematics,
  "Hqg;qg real square"
];
virtualProjections = contractBothProjectors[
  tensors["VirtualInterference"],
  "VirtualInterference",
  setTwoBodyKinematics,
  "Hqg LO-virtual interference"
];

projectionSets = <|
  "LO" -> loProjections,
  "RealQG" -> realQGProjections,
  "VirtualInterference" -> virtualProjections
|>;
assert[
  And @@ (AssociationQ /@ Values[projectionSets]),
  "At least one Hqg projection pair is not an Association."
];
assert[
  And @@ (Sort[Keys[#]] === Sort[{"Pg", "PPP"}] & /@
      Values[projectionSets]),
  "At least one Hqg result does not contain exactly Pg and PPP."
];
finalValidationResults = Flatten[
  Values[
    Map[
      validateScalarProjection[#, "final Hqg scalar projection"] &,
      #
    ]
  ] & /@ Values[projectionSets]
];
assert[
  AllTrue[finalValidationResults, TrueQ],
  "At least one final Hqg scalar projection failed validation."
];
assert[
  And @@ (! FreeQ[#, dZq1] & /@ Values[virtualProjections]) &&
    And @@ (! FreeQ[#, dZGG1] & /@ Values[virtualProjections]) &&
    And @@ (! FreeQ[#, dZgs1] & /@ Values[virtualProjections]),
  "At least one virtual projection lost symbolic QCD counterterms."
];

s07Checks = <|
  "CurrentS06SourceAndProgramBindingsVerified" -> True,
  "PaperReferenceHashPreserved" -> True,
  "BigTMDChannel3CaseAEnforced" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "FragmentingGluonIsK1" -> True,
  "ThreeHqgInputTensorsLoaded" -> True,
  "BothProjectorsAppliedToEveryTensor" -> True,
  "SixScalarProjectionsProduced" -> True,
  "PhotonIndexMuContracted" -> True,
  "PhotonIndexNuContracted" -> True,
  "NoLorentzIndicesRemain" -> True,
  "D DimensionalContractionsRetained" -> True,
  "CalculationFullySymbolic" -> True,
  "VirtualQCDCountertermsPreserved" -> True,
  "Eq9F1F2CombinationsDeferred" -> True,
  "NoPhaseSpaceOrFlavorFactorsApplied" -> True,
  "BigTMDFiniteKernelNormalizationDeferred" -> True,
  "EveryCacheBoundToS06AndProgramSHA256" -> True
|>;

s07Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg LO, Hqg;qg real, and Hqg;q virtual Pg/PPP scalar projections",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s06Path,
  "SourceResultSHA256" -> s06SHA256,
  "ReferencePDFSHA256" -> s06["ReferencePDFSHA256"],
  "BigTMDConvention" -> s06["BigTMDConvention"],
  "ElectricChargeNormalization" -> s06["ElectricChargeNormalization"],
  "BigTMDProjectorMapping" -> <|
    "Pg" -> "NLO.Pg.fchn3A",
    "PPP" -> "NLO.Ppp.fchn3A",
    "ComparisonStatus" ->
      "Deferred until phase space, real-virtual combination, factorization, and finite regular/delta/plus assembly."
  |>,
  "FragmentingParton" -> "gluon g(k1)",
  "ProjectorDefinitions" -> <|
    "Pg" -> HoldForm[PSubg[mu, nu] == MetricTensor[mu, nu]],
    "PPPPartonic" -> HoldForm[PSubPP[mu, nu] == p[mu] p[nu]],
    "PaperReference" -> "Eqs. (7), (16), and (19)",
    "Eq9P1P2CombinationStatus" -> "Deferred"
  |>,
  "ScalarProjections" -> <|
    "LO_OAlphaS" -> loProjections,
    "NLOReal_OAlphaS2" -> <|
      "Hqg;qg" -> realQGProjections
    |>,
    "NLOVirtualInterference_OAlphaS2_Symbolic" ->
      virtualProjections
  |>,
  "ProjectionCount" -> 6,
  "VirtualRenormalizationStatus" ->
    s06["VirtualRenormalizationStatus"],
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "SourceS06SHA256" -> s06SHA256,
    "ProgramSHA256" -> programSHA256,
    "Paths" -> cachePaths,
    "EveryCacheBoundToSourceS06AndProgramSHA256" -> True
  |>,
  "Checks" -> s07Checks,
  "NotPerformedAtThisStage" -> {
    "Eq. (9) P1/P2 linear combinations for F1/F2",
    "two- and three-body phase-space integration",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "real-virtual infrared cancellation",
    "PDF/FF collinear-factorization subtraction",
    "BigTMD cross-section/Jacobian/photon-spin normalization",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels"
  }
|>;

leafCounts = Map[
  Map[LeafCount, #] &,
  projectionSets
];

Print["S07_STAGE: writing " <> resultPath];
Put[s07Result, resultPath];

assert[FileExistsQ[resultPath], "The s07_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s07_result file is empty."];

Print["S07_SUCCESS"];
Print["S07_RESULT_PATH=" <> resultPath];
Print["S07_PROJECTION_COUNT=", s07Result["ProjectionCount"]];
Print["S07_LEAF_COUNTS=", InputForm[leafCounts]];
Print["S07_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S07_CHECKS=", InputForm[s07Checks]];

Quit[0];

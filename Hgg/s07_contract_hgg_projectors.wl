(* ::Package:: *)

(*
  Contract the sole spin/color-averaged Hgg real tensor in s06_result with
  the two extraction tensors used in the paper:

    P_g^(mu nu)  = g^(mu nu),
    P_PP^(mu nu) = p^mu p^nu.

  This produces two exact scalar, unintegrated squared-amplitude projections.
  Phase-space factors, the physical flavor-charge sum, factorization
  subtractions, and the P1/P2 combinations for F1/F2 are not applied here.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setThreeBodyKinematics, validateScalarProjection,
  loadValidatedCache, writeValidatedCache, contractProjection
];

fatal[message_String] := (
  Print["S07_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s06Path = FileNameJoin[{scriptDirectory, "s06_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
stageVersion = "HggS07-v1";

cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s07_cache_hgg_real_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s07_cache_hgg_real_pp"}]
|>;

Print["S07_STAGE: loading validated Hgg s06_result"];
assert[FileExistsQ[s06Path], "s06_result does not exist."];
s06 = Check[Get[s06Path], $Failed];
assert[AssociationQ[s06], "s06_result did not load as an Association."];
assert[s06["Status"] === "Complete", "s06_result is not marked complete."];
assert[s06["Channel"] === "Hgg only", "s06_result is not Hgg-only."];
assert[
  AllTrue[Values[s06["Checks"]], TrueQ],
  "At least one s06 validation check is not True."
];
assert[
  s06["SourceResultSHA256"] ===
    FileHash[s06["SourceResult"], "SHA256"],
  "The S06 source binding is stale."
];
assert[
  s06["VirtualContributionAtThisOrder"] === 0,
  "The S06 no-virtual Hgg contract is not satisfied."
];
s06SHA256 = FileHash[s06Path, "SHA256"];

hggTensor = s06[
  "SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hgg;q_qbar"
];

assert[
  ! FreeQ[hggTensor, FeynCalc`LorentzIndex[s05Mu, D]],
  "The Hgg tensor is missing photon index s05Mu."
];
assert[
  ! FreeQ[hggTensor, FeynCalc`LorentzIndex[s05Nu, D]],
  "The Hgg tensor is missing photon index s05Nu."
];
assert[
  FreeQ[
    hggTensor,
    _FeynCalc`Spinor | _FeynCalc`Polarization |
      _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
      _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex | _Real
  ],
  "The Hgg input tensor contains an unevaluated state/color object or machine real."
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

validateScalarProjection[expr_, label_String] := Module[{},
  assert[expr =!= $Failed, label <> " returned $Failed."];
  assert[expr =!= 0, label <> " is unexpectedly identically zero."];
  assert[
    FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]],
    label <> " still contains photon index s05Mu."
  ];
  assert[
    FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " still contains photon index s05Nu."
  ];
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
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex
    ],
    label <> " contains an external-state or explicit-color object."
  ];
  assert[
    FreeQ[expr, _Real],
    label <> " contains machine-precision numbers."
  ];
  True
];

loadValidatedCache[path_String, projectorName_String] := Module[{cache},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S07_STAGE: inspecting " <> projectorName <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  If[
    ! AssociationQ[cache] ||
      cache["Status"] =!= "Complete" ||
      cache["StageVersion"] =!= stageVersion ||
      cache["Projector"] =!= projectorName ||
      cache["SourceS06SHA256"] =!= s06SHA256 ||
      ! KeyExistsQ[cache, "Expression"],
    Print[
      "S07_STAGE: deleting stale or invalid " <> projectorName <> " cache"
    ];
    DeleteFile[path];
    Return[Missing["InvalidCache"]]
  ];
  validateScalarProjection[
    cache["Expression"],
    "cached Hgg " <> projectorName <> " projection"
  ];
  Print["S07_STAGE: loading validated " <> projectorName <> " cache"];
  cache["Expression"]
];

writeValidatedCache[path_String, projectorName_String, expr_] :=
 Module[{temporaryPath, cache},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Projector" -> projectorName,
    "SourceS06" -> s06Path,
    "SourceS06SHA256" -> s06SHA256,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    projectorName <> " temporary cache was not written."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    projectorName <> " cache was not finalized."
  ];
];

contractProjection[projectorName_String] := Module[{answer},
  answer = loadValidatedCache[cachePaths[projectorName], projectorName];
  If[! MissingQ[answer], Return[answer]];
  Print["S07_STAGE: contracting Hgg tensor with " <> projectorName];
  setThreeBodyKinematics[];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`Contract[projectors[projectorName] hggTensor],
      $Failed
    ],
    $Failed
  ];
  validateScalarProjection[answer, "Hgg " <> projectorName <> " projection"];
  writeValidatedCache[cachePaths[projectorName], projectorName, answer];
  Print[
    "S07_CHECKPOINT: completed ", projectorName,
    " leaf count ", LeafCount[answer]
  ];
  answer
];

Print["S07_STAGE: contracting the Hgg tensor with both projectors"];
hggProjections = AssociationMap[contractProjection, {"Pg", "PPP"}];

assert[AssociationQ[hggProjections], "The Hgg projections are not an Association."];
assert[
  Sort[Keys[hggProjections]] === Sort[{"Pg", "PPP"}],
  "The Hgg result does not contain exactly Pg and PPP."
];
assert[
  AllTrue[
    KeyValueMap[
      validateScalarProjection[#2, "final Hgg " <> #1 <> " projection"] &,
      hggProjections
    ],
    TrueQ
  ],
  "At least one final Hgg scalar projection failed validation."
];

s07Checks = <|
  "CurrentS06SourceBindingVerified" -> True,
  "SoleHggTensorLoaded" -> True,
  "BothProjectorsApplied" -> True,
  "TwoScalarProjectionsProduced" -> True,
  "PhotonIndexMuContracted" -> True,
  "PhotonIndexNuContracted" -> True,
  "NoLorentzIndicesRemain" -> True,
  "D DimensionalContractionsRetained" -> True,
  "CalculationFullySymbolic" -> True,
  "NoPhaseSpaceOrFlavorFactorsApplied" -> True,
  "VirtualContributionAbsent" -> True
|>;

s07Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hgg only",
  "Contribution" -> "Hgg;q qbar real scalar projections",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s06Path,
  "SourceResultSHA256" -> s06SHA256,
  "ProjectorDefinitions" -> <|
    "Pg" -> HoldForm[PSubg[mu, nu] == MetricTensor[mu, nu]],
    "PPPPartonic" -> HoldForm[PSubPP[mu, nu] == p[mu] p[nu]],
    "PaperReference" -> "Eqs. (7), (16), and (19)"
  |>,
  "ScalarProjections" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hgg;q_qbar" -> hggProjections
    |>
  |>,
  "ProjectionCount" -> 2,
  "VirtualContributionAtThisOrder" -> 0,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "Pg" -> cachePaths["Pg"],
    "PPP" -> cachePaths["PPP"],
    "EveryCacheBoundToSourceS06SHA256" -> True
  |>,
  "Checks" -> s07Checks,
  "NotPerformedAtThisStage" -> {
    "P1/P2 linear combinations for F1/F2",
    "physical Sum_f e_f^2 flavor-charge sum",
    "three-body phase-space angular integration",
    "PDF/FF collinear-factorization subtraction"
  }
|>;

Print["S07_STAGE: writing " <> resultPath];
Put[s07Result, resultPath];

assert[FileExistsQ[resultPath], "The s07_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s07_result file is empty."];

Print["S07_SUCCESS"];
Print["S07_RESULT_PATH=" <> resultPath];
Print["S07_PROJECTION_COUNT=", s07Result["ProjectionCount"]];
Print[
  "S07_LEAF_COUNTS=",
  InputForm[Map[LeafCount, hggProjections]]
];
Print["S07_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S07_CHECKS=", InputForm[s07Checks]];

Quit[0];

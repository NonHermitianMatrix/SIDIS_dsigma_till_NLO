(* ::Package:: *)

(*
  Spin/color sum and initial-state average of the real Hgg bilinear in
  s05_result.  In D dimensions this stage performs, in order,

    1. incoming-gluon p and fragmenting-gluon k1 polarization sums,
    2. final q(k2) and qbar(k3) spin sums,
    3. Dirac trace evaluation,
    4. all color sums,
    5. the incoming-gluon average 1/((D-2) (N_c^2-1)).

  The photon indices s05Mu and s05Nu remain open.  There is no photon
  polarization sum or average, no virtual branch, and no flavor-charge sum at
  this stage.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setThreeBodyKinematics, validatePostDiracTensor,
  validateSummedTensor, loadValidatedCache, writeValidatedCache
];

fatal[message_String] := (
  Print["S06_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s05Path = FileNameJoin[{scriptDirectory, "s05_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
postDiracCachePath = FileNameJoin[{
  scriptDirectory, "s06_cache_hgg_real_after_dirac"
}];
finalCachePath = FileNameJoin[{
  scriptDirectory, "s06_cache_hgg_real"
}];
stageVersion = "HggS06-v1";

Print["S06_STAGE: loading validated Hgg s05_result"];
assert[FileExistsQ[s05Path], "s05_result does not exist."];
s05 = Check[Get[s05Path], $Failed];
assert[AssociationQ[s05], "s05_result did not load as an Association."];
assert[s05["Status"] === "Complete", "s05_result is not marked complete."];
assert[s05["Channel"] === "Hgg only", "s05_result is not Hgg-only."];
assert[
  AllTrue[Values[s05["Checks"]], TrueQ],
  "At least one s05 validation check is not True."
];
assert[
  s05["VirtualContributionAtThisOrder", "Applicable"] === False &&
    s05["VirtualContributionAtThisOrder", "Interference"] === 0,
  "The S05 no-virtual Hgg contract is not satisfied."
];

s05SourceResults = s05["SourceResults"];
assert[
  s05SourceResults["S01SHA256"] ===
    FileHash[s05SourceResults["S01"], "SHA256"],
  "The S05 S01 source binding is stale."
];
assert[
  s05SourceResults["S04SHA256"] ===
    FileHash[s05SourceResults["S04"], "SHA256"],
  "The S05 S04 source binding is stale."
];
s05SHA256 = FileHash[s05Path, "SHA256"];

inputBilinear = s05[
  "Bilinears", "NLORealSquare_OAlphaS2", "Hgg;q_qbar"
];

assert[
  ! FreeQ[inputBilinear, _FeynCalc`Spinor],
  "The input Hgg bilinear contains no external spinors."
];
assert[
  ! FreeQ[inputBilinear, FeynCalc`Polarization[p, ___]],
  "The input Hgg bilinear lacks the incoming-gluon polarization."
];
assert[
  ! FreeQ[inputBilinear, FeynCalc`Polarization[k1, ___]],
  "The input Hgg bilinear lacks the fragmenting-gluon polarization."
];
assert[
  ! FreeQ[inputBilinear, FeynCalc`LorentzIndex[s05Mu, D]] &&
    ! FreeQ[inputBilinear, FeynCalc`LorentzIndex[s05Nu, D]],
  "The input Hgg bilinear is missing an open photon index."
];
assert[
  FreeQ[inputBilinear, FeynCalc`Polarization[q, ___]],
  "The input Hgg bilinear unexpectedly contains a photon polarization."
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

validatePostDiracTensor[expr_, label_String] := Module[{},
  assert[expr =!= $Failed, label <> " evaluation returned $Failed."];
  assert[
    FreeQ[expr, _FeynCalc`Spinor],
    label <> " still contains external spinors."
  ];
  assert[
    FreeQ[expr, _FeynCalc`Polarization],
    label <> " still contains an external polarization vector."
  ];
  assert[
    FreeQ[expr, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " still contains unevaluated Dirac objects."
  ];
  assert[
    ! FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost an open photon index."
  ];
  assert[
    FreeQ[expr, _Real],
    label <> " contains machine-precision numbers."
  ];
  True
];

validateSummedTensor[expr_, label_String] := Module[{},
  validatePostDiracTensor[expr, label];
  assert[
    FreeQ[expr, _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex],
    label <> " still contains explicit color indices."
  ];
  True
];

loadValidatedCache[path_String, cacheStage_String] :=
 Module[{cache},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S06_STAGE: inspecting cache " <> path];
  cache = Quiet@Check[Get[path], $Failed];
  If[
    ! AssociationQ[cache] ||
      cache["Status"] =!= "Complete" ||
      cache["StageVersion"] =!= stageVersion ||
      cache["CacheStage"] =!= cacheStage ||
      cache["SourceS05SHA256"] =!= s05SHA256 ||
      ! KeyExistsQ[cache, "Expression"],
    Print["S06_STAGE: deleting stale or invalid cache " <> path];
    DeleteFile[path];
    Return[Missing["InvalidCache"]]
  ];
  If[
    cacheStage === "PostDirac",
    validatePostDiracTensor[cache["Expression"], "cached post-Dirac tensor"],
    validateSummedTensor[cache["Expression"], "cached final tensor"]
  ];
  Print["S06_STAGE: loading validated " <> cacheStage <> " cache"];
  cache["Expression"]
];

writeValidatedCache[path_String, cacheStage_String, expr_] :=
 Module[{temporaryPath, cache},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "CacheStage" -> cacheStage,
    "SourceS05" -> s05Path,
    "SourceS05SHA256" -> s05SHA256,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    cacheStage <> " temporary cache was not written."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    cacheStage <> " cache was not finalized."
  ];
];

Print["S06_STAGE: processing the Hgg real bilinear"];
finalTensor = loadValidatedCache[finalCachePath, "Final"];

If[MissingQ[finalTensor],
  postDiracTensor = loadValidatedCache[postDiracCachePath, "PostDirac"];

  If[MissingQ[postDiracTensor],
    Print["S06_STAGE: setting massless three-body kinematics"];
    setThreeBodyKinematics[];

    Print[
      "S06_STAGE: summing incoming p and fragmenting k1 gluon polarizations"
    ];
    postDiracTensor = Fold[
      Function[{current, momentum},
        CheckAbort[
          Quiet@Check[
            FeynCalc`DoPolarizationSums[
              current,
              momentum,
              0,
              TimeConstrained -> Infinity,
              FeynCalc`FCParallelize -> False,
              FeynCalc`FCVerbose -> 0
            ],
            $Failed
          ],
          $Failed
        ]
      ],
      inputBilinear,
      {p, k1}
    ];
    assert[
      postDiracTensor =!= $Failed,
      "The Hgg gluon polarization sums failed."
    ];

    Print["S06_STAGE: summing final q and qbar spins"];
    postDiracTensor = CheckAbort[
      Quiet@Check[
        FeynCalc`FermionSpinSum[
          postDiracTensor,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0
        ],
        $Failed
      ],
      $Failed
    ];
    assert[
      postDiracTensor =!= $Failed,
      "The Hgg fermion spin sum failed."
    ];

    Print["S06_STAGE: evaluating all Dirac traces"];
    postDiracTensor = CheckAbort[
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
    ];
    validatePostDiracTensor[postDiracTensor, "post-Dirac Hgg tensor"];
    writeValidatedCache[
      postDiracCachePath,
      "PostDirac",
      postDiracTensor
    ];
    Print[
      "S06_CHECKPOINT: post-Dirac tensor leaf count ",
      LeafCount[postDiracTensor]
    ];
  ];

  Print["S06_STAGE: summing colors and applying incoming-gluon average"];
  initialGluonAverageDenominator =
    (D - 2) (FeynCalc`SUNN^2 - 1);
  finalTensor = CheckAbort[
    Quiet@Check[
      FeynCalc`SUNSimplify[
        postDiracTensor/initialGluonAverageDenominator,
        TimeConstrained -> Infinity,
        FeynCalc`SUNNToCACF -> True,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  validateSummedTensor[finalTensor, "spin/color-averaged Hgg tensor"];
  writeValidatedCache[finalCachePath, "Final", finalTensor];
  Print[
    "S06_CHECKPOINT: final tensor leaf count ",
    LeafCount[finalTensor]
  ];
];

validateSummedTensor[finalTensor, "final Hgg output tensor"];

s06Checks = <|
  "S05SourceBindingsCurrent" -> True,
  "S05NoVirtualContractEnforced" -> True,
  "SoleHggRealBilinearProcessed" -> True,
  "IncomingGluonPolarizationSummed" -> True,
  "FragmentingGluonPolarizationSummed" -> True,
  "FinalQuarkAndAntiquarkSpinsSummed" -> True,
  "AllDiracTracesEvaluated" -> True,
  "AllColorsSummed" -> True,
  "InitialGluonSpinAveragedByDMinus2" -> True,
  "InitialGluonColorAveragedByNcSquaredMinus1" -> True,
  "PhotonPolarizationNotSummed" -> True,
  "PhotonIndexMuPreserved" -> True,
  "PhotonIndexNuPreserved" -> True,
  "CalculationFullySymbolic" -> True,
  "VirtualContributionAbsent" -> True
|>;

s06Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hgg only",
  "Contribution" -> "Hgg;q qbar spin/color-averaged real tensor",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s05Path,
  "SourceResultSHA256" -> s05SHA256,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "InitialState" -> "gluon p",
  "InitialStateAverage" ->
    HoldForm[1/((D - 2) (FeynCalc`SUNN^2 - 1))],
  "InitialSpinStates" -> HoldForm[D - 2],
  "InitialColorStates" -> HoldForm[FeynCalc`SUNN^2 - 1],
  "PolarizationSumConvention" ->
    "D-dimensional massless-vector sum -g^(rho sigma), applied to incoming p and fragmenting k1 before the initial-gluon average.",
  "KinematicConventions" -> <|
    "ThreeBody" -> {
      HoldForm[p^2 == 0],
      HoldForm[q^2 == -Q2],
      HoldForm[k1^2 == 0],
      HoldForm[k2^2 == 0],
      HoldForm[k3^2 == 0],
      HoldForm[(p + q)^2 == sHat],
      HoldForm[ti == (q - ki)^2],
      HoldForm[ui == (p - ki)^2],
      HoldForm[sij == (ki + kj)^2]
    }
  |>,
  "SpinColorAveragedTensors" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hgg;q_qbar" -> finalTensor
    |>
  |>,
  "VirtualContributionAtThisOrder" -> 0,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "PostDirac" -> postDiracCachePath,
    "Final" -> finalCachePath,
    "EveryCacheBoundToSourceS05SHA256" -> True
  |>,
  "Checks" -> s06Checks,
  "NotPerformedAtThisStage" -> {
    "physical Sum_f e_f^2 flavor-charge sum",
    "projection onto the paper's g and PP tensor structures",
    "three-body phase-space angular integration",
    "PDF/FF collinear-factorization subtraction"
  }
|>;

Print["S06_STAGE: writing " <> resultPath];
Put[s06Result, resultPath];

assert[FileExistsQ[resultPath], "The s06_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s06_result file is empty."];

Print["S06_SUCCESS"];
Print["S06_RESULT_PATH=" <> resultPath];
Print["S06_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S06_FINAL_LEAF_COUNT=", LeafCount[finalTensor]];
Print["S06_CHECKS=", InputForm[s06Checks]];

Quit[0];

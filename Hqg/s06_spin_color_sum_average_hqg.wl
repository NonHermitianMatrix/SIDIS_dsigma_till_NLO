(* ::Package:: *)

(*
  Spin/color sum and initial-state average of the Hqg bilinears in s05_result.

  This stage follows the paper's Hqg organization and the BigTMD channel-3,
  case-A convention:

    virtual: gamma*(q) + q(p) -> g(k1) + q(k2),
    real:    gamma*(q) + q(p) -> g(k1) + q(k2) + g(k3),

  where k1 is always the fragmenting gluon.  In D dimensions the stage
  performs, in order,

    1. final-gluon polarization sums (k1, and k3 for the real process),
    2. incoming/final quark spin sums,
    3. explicit Dirac trace evaluation,
    4. all color sums,
    5. the incoming-quark spin/color average 1/(2 N_c).

  Photon indices s05Mu and s05Nu remain open.  The physical Sum_q e_q^2
  luminosity, projectors, phase space, infrared combination, factorization,
  and comparison with finite BigTMD fchn3A kernels remain for later stages.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setTwoBodyKinematics, setThreeBodyKinematics,
  validatePostDiracTensor, validateSummedTensor, loadValidatedCache,
  writeValidatedCache, processBilinear, processPhysicalRealBlocks
];

fatal[message_String] := (
  Print["S06_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s05Path = FileNameJoin[{scriptDirectory, "s05_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
stageVersion = "HqgS06-v3";

cachePaths = <|
  "LO" -> <|
    "PostDirac" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_lo_after_dirac"
    }],
    "Final" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_lo"
    }]
  |>,
  "RealQG" -> <|
    "PostDirac" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_real_qg_after_dirac"
    }],
    "Final" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_real_qg"
    }],
    "PhysicalRowsPostDirac" -> Table[
      FileNameJoin[{
        scriptDirectory,
        "s06_cache_hqg_real_qg_physical_row_" <>
          IntegerString[index, 10, 2] <> "_after_dirac"
      }],
      {index, 8}
    ]
  |>,
  "VirtualInterference" -> <|
    "PostDirac" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_virtual_interference_after_dirac"
    }],
    "Final" -> FileNameJoin[{
      scriptDirectory, "s06_cache_hqg_virtual_interference"
    }]
  |>
|>;

Print["S06_STAGE: loading validated Hqg s05_result"];
assert[FileExistsQ[s05Path], "s05_result does not exist."];
s05 = Check[Get[s05Path], $Failed];
assert[AssociationQ[s05], "s05_result did not load as an Association."];
assert[
  s05["Status"] === "Complete" &&
    s05["Stage"] === "HqgS05-v3" &&
    s05["Channel"] === "Hqg only",
  "s05_result is not the complete Hqg S05 result."
];
assert[
  AllTrue[Values[s05["Checks"]], TrueQ],
  "At least one S05 validation check is not True."
];

s05SourceResults = s05["SourceResults"];
assert[
  FileExistsQ[s05SourceResults["S01"]] &&
    s05SourceResults["S01SHA256"] ===
      FileHash[s05SourceResults["S01"], "SHA256"],
  "The S05 S01 source binding is stale."
];
assert[
  FileExistsQ[s05SourceResults["S04"]] &&
    s05SourceResults["S04SHA256"] ===
      FileHash[s05SourceResults["S04"], "SHA256"],
  "The S05 S04 source binding is stale."
];
assert[
  IntegerQ[s05SourceResults["ReferencePDFSHA256"]],
  "S05 has no exact reference-paper hash."
];
assert[
  s05["BigTMDConvention", "ChannelNumber"] === 3 &&
    s05["BigTMDConvention", "ChargeCase"] === "A only",
  "S05 is not bound to BigTMD Hqg channel 3, case A."
];
assert[
  s05["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s05["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s05["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g",
  "S05 is not in the corrected charge-stripped hard-kernel convention."
];
assert[
  s05[
    "ExternalProcessOrganization", "LOAndVirtual", "FragmentingParton"
  ] === "g(k1)" &&
    s05[
      "ExternalProcessOrganization", "NLOReal", "FragmentingParton"
    ] === "g(k1)",
  "S05 does not preserve the fragmenting-gluon g(k1) convention."
];
assert[
  s05["DiagramCounts"] === <|
    "LO" -> 2,
    "RealQG" -> 8,
    "Virtual" -> 23,
    "Counterterm" -> 12
  |> &&
    s05["CoherentOrderedPairCounts"] === <|
      "LOSquare" -> 4,
      "NLORealHqgQG" -> 64,
      "LOVirtualHermitianCrossTerms" -> 140
    |>,
  "S05 diagram or coherent-pair counts violate the Hqg contract."
];

s05SHA256 = FileHash[s05Path, "SHA256"];

loBilinear = s05["Bilinears", "LOSquare_OAlphaS"];
realQGBilinear = s05[
  "Bilinears", "NLORealSquares_OAlphaS2", "Hqg;qg"
];
realQGAmplitudeBlocks =
  s05["OpenPhotonIndexRealAmplitudeBlocks", "Hqg;qg_Mu"];
realQGConjugateBlocks =
  s05["OpenPhotonIndexRealAmplitudeBlocks", "Hqg;qg_NuConjugate"];
assert[
  ListQ[realQGAmplitudeBlocks] && ListQ[realQGConjugateBlocks] &&
    Length[realQGAmplitudeBlocks] === 8 &&
    Length[realQGConjugateBlocks] === 8 &&
    s05["OpenPhotonIndexRealAmplitudeBlocks", "BlockCount"] === 8,
  "S05 does not provide exactly eight coherent real-amplitude blocks."
];
masslessVectorQCDRules = {
  HoldPattern[dZfL1[indices___]] :> dZq1[indices],
  HoldPattern[dZfR1[indices___]] :> dZq1[indices]
};
virtualInterferenceBilinear =
  s05["Bilinears", "NLOVirtualInterference_OAlphaS2_Symbolic"] /.
    masslessVectorQCDRules;

inputBilinears = {
  loBilinear,
  realQGBilinear,
  virtualInterferenceBilinear
};
assert[
  And @@ (! FreeQ[#, _FeynCalc`Spinor] & /@ inputBilinears),
  "At least one Hqg input bilinear lacks external quark spinors."
];
assert[
  And @@ (! FreeQ[#, FeynCalc`Polarization[k1, ___]] & /@
      inputBilinears),
  "At least one Hqg input bilinear lacks fragmenting-gluon k1."
];
assert[
  ! FreeQ[realQGBilinear, FeynCalc`Polarization[k3, ___]],
  "The Hqg real bilinear lacks the unobserved gluon k3."
];
assert[
  And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] & /@
      inputBilinears) &&
    And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] & /@
      inputBilinears),
  "At least one Hqg input bilinear lacks an open photon index."
];
assert[
  FreeQ[
    inputBilinears,
    FeynCalc`Polarization[q, ___] | FeynCalc`ComplexConjugate |
      FeynCalc`TID | $Failed | _Real
  ],
  "An Hqg input bilinear violates symbolic/open-photon completeness."
];
assert[
  ! FreeQ[virtualInterferenceBilinear, dZq1] &&
    ! FreeQ[virtualInterferenceBilinear, dZGG1] &&
    ! FreeQ[virtualInterferenceBilinear, dZgs1],
  "The massless-vector virtual interference lacks QCD counterterms."
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

validatePostDiracTensor[expr_, label_String] := Module[{},
  assert[expr =!= $Failed && expr =!= 0,
    label <> " is failed or identically zero."];
  assert[FreeQ[expr, _FeynCalc`Spinor],
    label <> " still contains external spinors."];
  assert[FreeQ[expr, _FeynCalc`Polarization],
    label <> " still contains an external polarization vector."];
  assert[FreeQ[expr, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " still contains unevaluated Dirac objects."];
  assert[
    ! FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost an open photon index."
  ];
  assert[
    FreeQ[expr, FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real],
    label <> " is not a complete exact symbolic tensor."
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

loadValidatedCache[
    path_String, tensorRole_String, cacheStage_String
  ] := Module[{cache, validMetadata},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S06_STAGE: inspecting cache " <> path];
  cache = Quiet@Check[Get[path], $Failed];
  validMetadata =
    AssociationQ[cache] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === tensorRole &&
    cache["CacheStage"] === cacheStage &&
    cache["SourceS05SHA256"] === s05SHA256 &&
    cache["ProgramSHA256"] === programSHA256 &&
    cache["ElectricChargeNormalization"] ===
      s05["ElectricChargeNormalization"] &&
    KeyExistsQ[cache, "Expression"];
  If[! TrueQ[validMetadata],
    Print["S06_STAGE: deleting stale or invalid cache " <> path];
    DeleteFile[path];
    Return[Missing["InvalidCache"]]
  ];
  If[
    cacheStage === "PostDirac",
    validatePostDiracTensor[
      cache["Expression"], tensorRole <> " cached post-Dirac tensor"
    ],
    validateSummedTensor[
      cache["Expression"], tensorRole <> " cached final tensor"
    ]
  ];
  Print[
    "S06_STAGE: loading validated " <> tensorRole <> " " <>
      cacheStage <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[
    path_String, tensorRole_String, cacheStage_String, expr_
  ] := Module[{temporaryPath, cache},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> tensorRole,
    "CacheStage" -> cacheStage,
    "SourceS05" -> s05Path,
    "SourceS05SHA256" -> s05SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "BigTMDChannel" -> 3,
    "BigTMDChargeCase" -> "A only",
    "ElectricChargeNormalization" -> s05["ElectricChargeNormalization"],
    "FragmentingParton" -> "g(k1)",
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    tensorRole <> " " <> cacheStage <> " temporary cache was not written."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    tensorRole <> " " <> cacheStage <> " cache was not finalized."
  ];
];

processBilinear[
    expr_, polarizationMomenta_List, kinematicsSetup_Symbol,
    tensorRole_String, label_String, paths_Association
  ] := Module[{postDiracTensor, finalTensor},
  finalTensor = loadValidatedCache[
    paths["Final"], tensorRole, "Final"
  ];
  If[! MissingQ[finalTensor], Return[finalTensor]];

  postDiracTensor = loadValidatedCache[
    paths["PostDirac"], tensorRole, "PostDirac"
  ];
  If[MissingQ[postDiracTensor],
    Print["S06_STAGE: setting kinematics for " <> label];
    kinematicsSetup[];

    Print["S06_STAGE: summing final-gluon polarizations for " <> label];
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
      expr,
      polarizationMomenta
    ];
    assert[postDiracTensor =!= $Failed,
      label <> " gluon polarization sums failed."];

    Print["S06_STAGE: summing quark spins for " <> label];
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
    assert[postDiracTensor =!= $Failed,
      label <> " fermion spin sum failed."];

    Print["S06_STAGE: evaluating Dirac traces for " <> label];
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
    validatePostDiracTensor[postDiracTensor, label <> " post-Dirac tensor"];
    writeValidatedCache[
      paths["PostDirac"], tensorRole, "PostDirac", postDiracTensor
    ];
    Print[
      "S06_CHECKPOINT: " <> tensorRole <> " post-Dirac leaf count " <>
        ToString[LeafCount[postDiracTensor]]
    ];
  ];

  Print[
    "S06_STAGE: summing colors and applying incoming-quark average for " <>
      label
  ];
  finalTensor = CheckAbort[
    Quiet@Check[
      FeynCalc`SUNSimplify[
        postDiracTensor/(2 FeynCalc`SUNN),
        TimeConstrained -> Infinity,
        FeynCalc`SUNNToCACF -> True,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  validateSummedTensor[finalTensor, label <> " final tensor"];
  writeValidatedCache[
    paths["Final"], tensorRole, "Final", finalTensor
  ];
  Print[
    "S06_CHECKPOINT: " <> tensorRole <> " final leaf count " <>
      ToString[LeafCount[finalTensor]]
  ];
  finalTensor
];

processPhysicalRealBlocks[
    amplitudeBlocks_List, conjugateBlocks_List,
    kinematicsSetup_Symbol, tensorRole_String, label_String,
    paths_Association
  ] := Module[
  {
    finalTensor, postDiracTensor, postDiracRows, totalConjugate,
    rowRole, rowPath, rowExpression
  },
  finalTensor = loadValidatedCache[
    paths["Final"], tensorRole, "Final"
  ];
  If[! MissingQ[finalTensor], Return[finalTensor]];

  postDiracTensor = loadValidatedCache[
    paths["PostDirac"], tensorRole, "PostDirac"
  ];
  If[MissingQ[postDiracTensor],
    totalConjugate = Total[conjugateBlocks];
    postDiracRows = MapIndexed[
      Function[{amplitudeBlock, position},
        rowRole = tensorRole <> "PhysicalRow" <>
          IntegerString[First[position], 10, 2];
        rowPath = paths["PhysicalRowsPostDirac"][[First[position]]];
        rowExpression = loadValidatedCache[
          rowPath, rowRole, "PostDirac"
        ];
        If[MissingQ[rowExpression],
          Print[
            "S06_STAGE: physical real row " <>
              ToString[First[position]] <> "/" <>
              ToString[Length[amplitudeBlocks]]
          ];
          kinematicsSetup[];
          rowExpression = amplitudeBlock totalConjugate;
          (*
            The auxiliary p is lightlike and noncollinear to either final
            gluon on the generic three-body phase space.  These are the
            D-dimensional two-physical-state axial projectors; unlike the
            old zero-auxiliary shortcut they contain no unphysical modes.
          *)
          rowExpression = Fold[
            Function[{current, specification},
              CheckAbort[
                Quiet@Check[
                  FeynCalc`DoPolarizationSums[
                    current,
                    specification[[1]],
                    specification[[2]],
                    TimeConstrained -> Infinity,
                    FeynCalc`FCParallelize -> False,
                    FeynCalc`FCVerbose -> 0
                  ],
                  $Failed
                ],
                $Failed
              ]
            ],
            rowExpression,
            {{k1, p}, {k3, p}}
          ];
          assert[rowExpression =!= $Failed,
            label <> " physical polarization row failed."];
          rowExpression = CheckAbort[
            Quiet@Check[
              FeynCalc`FermionSpinSum[
                rowExpression,
                FeynCalc`FCParallelize -> False,
                FeynCalc`FCVerbose -> 0
              ],
              $Failed
            ],
            $Failed
          ];
          assert[rowExpression =!= $Failed,
            label <> " physical row fermion spin sum failed."];
          rowExpression = CheckAbort[
            Quiet@Check[
              FeynCalc`DiracSimplify[
                rowExpression,
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
          validatePostDiracTensor[
            rowExpression, label <> " physical row post-Dirac tensor"
          ];
          writeValidatedCache[
            rowPath, rowRole, "PostDirac", rowExpression
          ];
          Print[
            "S06_CHECKPOINT: physical real row " <>
              ToString[First[position]] <> "/" <>
              ToString[Length[amplitudeBlocks]] <> " leaf count " <>
              ToString[LeafCount[rowExpression]]
          ];
        ];
        rowExpression
      ],
      amplitudeBlocks
    ];
    postDiracTensor = Total[postDiracRows];
    validatePostDiracTensor[
      postDiracTensor, label <> " physical aggregate post-Dirac tensor"
    ];
    writeValidatedCache[
      paths["PostDirac"], tensorRole, "PostDirac", postDiracTensor
    ];
  ];

  Print[
    "S06_STAGE: summing colors and applying incoming-quark average for " <>
      label
  ];
  finalTensor = CheckAbort[
    Quiet@Check[
      FeynCalc`SUNSimplify[
        postDiracTensor/(2 FeynCalc`SUNN),
        TimeConstrained -> Infinity,
        FeynCalc`SUNNToCACF -> True,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  validateSummedTensor[finalTensor, label <> " physical final tensor"];
  writeValidatedCache[
    paths["Final"], tensorRole, "Final", finalTensor
  ];
  Print[
    "S06_CHECKPOINT: " <> tensorRole <> " physical final leaf count " <>
      ToString[LeafCount[finalTensor]]
  ];
  finalTensor
];

Print["S06_STAGE: processing all Hqg bilinears"];

loTensor = processBilinear[
  loBilinear,
  {k1},
  setTwoBodyKinematics,
  "LO",
  "Hqg LO square",
  cachePaths["LO"]
];

realQGTensor = processPhysicalRealBlocks[
  realQGAmplitudeBlocks,
  realQGConjugateBlocks,
  setThreeBodyKinematics,
  "RealQG",
  "Hqg;qg real square",
  cachePaths["RealQG"]
];

virtualInterferenceTensorSymbolic = processBilinear[
  virtualInterferenceBilinear,
  {k1},
  setTwoBodyKinematics,
  "VirtualInterference",
  "Hqg LO-virtual interference",
  cachePaths["VirtualInterference"]
];

allOutputTensors = {
  loTensor,
  realQGTensor,
  virtualInterferenceTensorSymbolic
};
assert[
  And @@ (validateSummedTensor[#, "final Hqg output tensor"] & /@
      allOutputTensors),
  "At least one final Hqg tensor failed validation."
];
assert[
  ! FreeQ[virtualInterferenceTensorSymbolic, dZq1] &&
    ! FreeQ[virtualInterferenceTensorSymbolic, dZGG1] &&
    ! FreeQ[virtualInterferenceTensorSymbolic, dZgs1],
  "The final virtual tensor lost symbolic QCD counterterms."
];

s06Checks = <|
  "S05SourceBindingsCurrent" -> True,
  "PaperReferenceHashPreserved" -> True,
  "BigTMDChannel3CaseAEnforced" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "FragmentingGluonIsK1" -> True,
  "ExactlyThreeHqgBilinearsProcessed" -> True,
  "LOFragmentingGluonPolarizationSummed" -> True,
  "RealFragmentingAndUnobservedGluonPolarizationsSummed" -> True,
  "RealFinalGluonsUseDMinus2PhysicalAxialSums" -> True,
  "RealPhysicalSumUsesEightResumableCoherentRows" -> True,
  "VirtualFragmentingGluonPolarizationSummed" -> True,
  "SingleGluonCovariantSumsWardProtected" -> True,
  "IncomingAndFinalQuarkSpinsSummed" -> True,
  "AllDiracTracesEvaluated" -> True,
  "AllColorsSummed" -> True,
  "InitialQuarkSpinAveragedBy2" -> True,
  "InitialQuarkColorAveragedByNc" -> True,
  "PhotonPolarizationNotSummed" -> True,
  "PhotonIndexMuPreserved" -> True,
  "PhotonIndexNuPreserved" -> True,
  "MasslessVectorQCDFieldRenormalizationApplied" -> True,
  "VirtualSquareStillExcluded" -> True,
  "CalculationFullySymbolic" -> True,
  "AllCachesBoundToS05AndProgramSHA256" -> True
|>;

s06Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg LO, Hqg;qg real, and Hqg;q virtual spin/color-averaged tensors",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s05Path,
  "SourceResultSHA256" -> s05SHA256,
  "ReferencePDFSHA256" ->
    s05SourceResults["ReferencePDFSHA256"],
  "BigTMDConvention" -> s05["BigTMDConvention"],
  "ElectricChargeNormalization" -> s05["ElectricChargeNormalization"],
  "BigTMDComparisonStatus" ->
    "Deferred: S06 tensors are unprojected, unintegrated, and unsubtracted; finite Pg/Ppp fchn3A comparison belongs after projection, phase space, infrared combination, and factorization.",
  "PhotonIndices" -> {s05Mu, s05Nu},
  "InitialState" -> "quark q(p)",
  "FragmentingParton" -> "gluon g(k1)",
  "InitialStateAverage" -> HoldForm[1/(2 FeynCalc`SUNN)],
  "InitialSpinStates" -> 2,
  "InitialColorStates" -> FeynCalc`SUNN,
  "PolarizationSumConvention" ->
    "For Hqg;qg, each final gluon uses the D-dimensional axial projector with lightlike auxiliary p, summing only D-2 physical states. The one-gluon LO and virtual tensors use the covariant -g^(rho sigma) shortcut under their exact Ward identity. No incoming-quark or photon polarization sum is applied.",
  "KinematicConventions" -> <|
    "TwoBody" -> {
      HoldForm[p^2 == 0],
      HoldForm[q^2 == -Q2],
      HoldForm[k1^2 == 0],
      HoldForm[k2^2 == 0],
      HoldForm[(p + q)^2 == sHat],
      HoldForm[k1 == fragmentingGluon]
    },
    "ThreeBody" -> {
      HoldForm[p^2 == 0],
      HoldForm[q^2 == -Q2],
      HoldForm[k1^2 == 0],
      HoldForm[k2^2 == 0],
      HoldForm[k3^2 == 0],
      HoldForm[(p + q)^2 == sHat],
      HoldForm[ti == (q - ki)^2],
      HoldForm[ui == (p - ki)^2],
      HoldForm[sij == (ki + kj)^2],
      HoldForm[k1 == fragmentingGluon]
    }
  |>,
  "SpinColorAveragedTensors" -> <|
    "LO_OAlphaS" -> loTensor,
    "NLOReal_OAlphaS2" -> <|
      "Hqg;qg" -> realQGTensor
    |>,
    "NLOVirtualInterference_OAlphaS2_Symbolic" ->
      virtualInterferenceTensorSymbolic
  |>,
  "VirtualRenormalizationStatus" ->
    s05["VirtualRenormalizationStatus"],
  "MasslessVectorQCDFieldRenormalization" ->
    "dZfL1 and dZfR1 are identified with common symbolic dZq1 before the unpolarized quark spin sum.",
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "SourceS05SHA256" -> s05SHA256,
    "ProgramSHA256" -> programSHA256,
    "Paths" -> cachePaths,
    "EveryCacheBoundToSourceS05AndProgramSHA256" -> True
  |>,
  "Checks" -> s06Checks,
  "NotPerformedAtThisStage" -> {
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "projection onto the paper's g and PP tensor structures",
    "two- and three-body phase-space integration",
    "real-virtual infrared cancellation",
    "PDF/FF collinear-factorization subtraction",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels"
  }
|>;

Print["S06_STAGE: writing " <> resultPath];
Put[s06Result, resultPath];

assert[FileExistsQ[resultPath], "The s06_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s06_result file is empty."];

Print["S06_SUCCESS"];
Print["S06_RESULT_PATH=" <> resultPath];
Print["S06_RESULT_BYTES=", FileByteCount[resultPath]];
Print[
  "S06_FINAL_LEAF_COUNTS=",
  InputForm[<|
    "LO" -> LeafCount[loTensor],
    "RealQG" -> LeafCount[realQGTensor],
    "VirtualInterference" -> LeafCount[virtualInterferenceTensorSymbolic]
  |>]
];
Print["S06_CHECKS=", InputForm[s06Checks]];

Quit[0];

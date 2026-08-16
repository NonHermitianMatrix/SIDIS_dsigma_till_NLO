(* ::Package:: *)

(*
  Contract the five spin/color-averaged Hqq tensors in s06_result with the
  two extraction tensors used in the paper:

    P_g^(mu nu)  = g^(mu nu),
    P_PP^(mu nu) = p^mu p^nu  (partonic analogue of P^mu P^nu).

  This produces ten scalar, unintegrated squared-amplitude projections. The
  phase-space factors, flavor/symmetry factors, factorization subtractions,
  and the P_1/P_2 combinations that extract F_1/F_2 are not applied here.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setTwoBodyKinematics, setThreeBodyKinematics,
  validateScalarProjection, contractProjection, contractBothProjectors
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

cachePath[label_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s07_cache_" <> label <> "_" <> ToLowerCase[projector]
}];

Print["S07_STAGE: loading s06_result"];
assert[FileExistsQ[s06Path], "s06_result does not exist."];
s06 = Check[Get[s06Path], $Failed];
assert[AssociationQ[s06], "s06_result did not load as an Association."];
assert[s06["Status"] === "Complete", "s06_result is not marked complete."];
assert[s06["Channel"] === "Hqq only", "s06_result is not Hqq-only."];
assert[And @@ Values[s06["Checks"]],
  "At least one s06 validation check is not True."];

tensors = <|
  "LO" -> s06["SpinColorAveragedTensors", "LO_OAlphaS"],
  "RealQGG" ->
    s06["SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hqq;gg"],
  "RealSameFlavor" -> s06[
    "SpinColorAveragedTensors", "NLOReal_OAlphaS2",
    "Hqq;q_qbar_sameFlavor"
  ],
  "RealDifferentFlavor" -> s06[
    "SpinColorAveragedTensors", "NLOReal_OAlphaS2",
    "Hqq;qPrime_qbarPrime"
  ],
  "VirtualInterference" -> s06[
    "SpinColorAveragedTensors",
    "NLOVirtualInterference_OAlphaS2_Symbolic"
  ]
|>;

assert[Length[tensors] === 5, "Expected exactly five input tensors."];
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] & /@
      Values[tensors]),
  "At least one input tensor is missing photon index s05Mu."];
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] & /@
      Values[tensors]),
  "At least one input tensor is missing photon index s05Nu."];

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
  "g" -> FeynCalc`Pair[
    FeynCalc`LorentzIndex[s05Mu, D],
    FeynCalc`LorentzIndex[s05Nu, D]
  ],
  "PP" -> Times[
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
  assert[FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]],
    label <> " still contains photon index s05Mu."];
  assert[FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " still contains photon index s05Nu."];
  assert[FreeQ[expr, _FeynCalc`LorentzIndex],
    label <> " still contains an uncontracted Lorentz index."];
  assert[FreeQ[expr, FeynCalc`Contract],
    label <> " contains an unevaluated Contract call."];
  assert[FreeQ[
      expr,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex
    ],
    label <> " contains an external-state or explicit color object."];
  True
];

contractProjection[
    tensor_, projectorName_String, kinematicsSetup_Symbol,
    label_String, cache_String
  ] := Module[{answer},
  If[FileExistsQ[cache],
    Print[
      "S07_STAGE: loading " <> projectorName <> " cache for " <> label
    ];
    answer = Check[Get[cache], $Failed];
    validateScalarProjection[
      answer, label <> " cached " <> projectorName <> " projection"
    ];
    Return[answer]
  ];

  Print[
    "S07_STAGE: contracting " <> label <> " with P_" <> projectorName
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
    answer, label <> " " <> projectorName <> " projection"
  ];
  Put[answer, cache];
  assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
    label <> " " <> projectorName <> " cache was not written."];
  Print[
    "S07_STAGE: completed " <> label <> " P_" <> projectorName <>
      ", leaf count " <> ToString[LeafCount[answer]]
  ];
  answer
];

contractBothProjectors[
    tensor_, kinematicsSetup_Symbol, label_String, cacheLabel_String
  ] := <|
  "Pg" -> contractProjection[
    tensor, "g", kinematicsSetup, label, cachePath[cacheLabel, "g"]
  ],
  "PPP" -> contractProjection[
    tensor, "PP", kinematicsSetup, label, cachePath[cacheLabel, "PP"]
  ]
|>;

Print["S07_STAGE: contracting all five tensors"];

loProjections = contractBothProjectors[
  tensors["LO"], setTwoBodyKinematics, "LO square", "lo"
];

sameProjections = contractBothProjectors[
  tensors["RealSameFlavor"],
  setThreeBodyKinematics,
  "NLO real same-flavor q qbar square",
  "real_same_flavor"
];

differentProjections = contractBothProjectors[
  tensors["RealDifferentFlavor"],
  setThreeBodyKinematics,
  "NLO real different-flavor q' qbar' square",
  "real_different_flavor"
];

qggProjections = contractBothProjectors[
  tensors["RealQGG"],
  setThreeBodyKinematics,
  "NLO real Hqq;gg square",
  "real_qgg"
];

virtualProjections = contractBothProjectors[
  tensors["VirtualInterference"],
  setTwoBodyKinematics,
  "NLO LO-virtual interference",
  "virtual_interference"
];

allProjectionPairs = {
  loProjections,
  qggProjections,
  sameProjections,
  differentProjections,
  virtualProjections
};
assert[And @@ (AssociationQ /@ allProjectionPairs),
  "At least one output projection pair is not an Association."];
assert[And @@ (Sort[Keys[#]] === Sort[{"Pg", "PPP"}] & /@
      allProjectionPairs),
  "At least one output does not contain both Pg and PPP."];
finalValidationResults = Map[
  Function[pair,
    Map[
      Function[projection,
        validateScalarProjection[projection, "final scalar projection"]
      ],
      Values[pair]
    ]
  ],
  allProjectionPairs
];
assert[And @@ Flatten[finalValidationResults],
  "At least one final scalar projection failed validation."];

s07Checks = <|
  "FiveInputTensorsLoaded" -> True,
  "BothProjectorsAppliedToEveryTensor" -> True,
  "TenScalarProjectionsProduced" -> True,
  "PhotonIndexMuContracted" -> True,
  "PhotonIndexNuContracted" -> True,
  "NoLorentzIndicesRemain" -> True,
  "D dimensionalContractionsRetained" -> True,
  "NoPhaseSpaceFactorsApplied" -> True
|>;

s07Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s06Path,
  "ProjectorDefinitions" -> <|
    "Pg" -> HoldForm[PSubg[mu, nu] == MetricTensor[mu, nu]],
    "PPPPartonic" -> HoldForm[PSubPP[mu, nu] == p[mu] p[nu]],
    "PaperReference" -> "Eqs. (7), (16), and (19)"
  |>,
  "ScalarProjections" -> <|
    "LO_OAlphaS" -> loProjections,
    "NLOReal_OAlphaS2" -> <|
      "Hqq;gg" -> qggProjections,
      "Hqq;q_qbar_sameFlavor" -> sameProjections,
      "Hqq;qPrime_qbarPrime" -> differentProjections
    |>,
    "NLOVirtualInterference_OAlphaS2_Symbolic" -> virtualProjections
  |>,
  "ProjectionCount" -> 10,
  "VirtualRenormalizationStatus" ->
    s06["VirtualRenormalizationStatus"],
  "Checks" -> s07Checks,
  "NotPerformedAtThisStage" -> {
    "P1/P2 linear combinations for F1/F2",
    "two- or three-body phase-space integration",
    "identical-particle symmetry and different-flavor multiplicity factors",
    "real-virtual infrared cancellation",
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
Print["S07_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S07_CHECKS=", InputForm[s07Checks]];

Quit[0];

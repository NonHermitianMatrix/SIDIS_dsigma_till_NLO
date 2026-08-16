(* ::Package:: *)

(*
  Spin/color sum and initial-state average of the Hqq bilinears in s05_result.

  For every LO, NLO-real, and NLO virtual-interference contribution this stage
  performs, in D dimensions,

    1. final-gluon polarization sums,
    2. all external-fermion spin sums,
    3. Dirac trace evaluation,
    4. final- and initial-state color sums,
    5. the incoming-quark spin/color average 1/(2 N_c).

  The photon indices s05Mu and s05Nu remain open. There is no photon
  polarization sum or average. Different real final states remain separate;
  their phase-space measures and flavor/symmetry factors are not applied here.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, setTwoBodyKinematics, setThreeBodyKinematics,
  validateSummedTensor, processBilinear
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

cachePaths = <|
  "LO" -> FileNameJoin[{scriptDirectory, "s06_cache_lo"}],
  "RealQGG" -> FileNameJoin[{scriptDirectory, "s06_cache_real_qgg"}],
  "RealSameFlavor" ->
    FileNameJoin[{scriptDirectory, "s06_cache_real_same_flavor"}],
  "RealDifferentFlavor" ->
    FileNameJoin[{scriptDirectory, "s06_cache_real_different_flavor"}],
  "VirtualInterference" ->
    FileNameJoin[{scriptDirectory, "s06_cache_virtual_interference"}]
|>;

Print["S06_STAGE: loading s05_result"];
assert[FileExistsQ[s05Path], "s05_result does not exist."];
s05 = Check[Get[s05Path], $Failed];
assert[AssociationQ[s05], "s05_result did not load as an Association."];
assert[s05["Status"] === "Complete", "s05_result is not marked complete."];
assert[s05["Channel"] === "Hqq only", "s05_result is not Hqq-only."];
assert[And @@ Values[s05["Checks"]],
  "At least one s05 validation check is not True."];

loBilinear = s05["Bilinears", "LOSquare_OAlphaS"];
qggBilinear =
  s05["Bilinears", "NLORealSquares_OAlphaS2", "Hqq;gg"];
sameBilinear = s05[
  "Bilinears", "NLORealSquares_OAlphaS2", "Hqq;q_qbar_sameFlavor"
];
differentBilinear = s05[
  "Bilinears", "NLORealSquares_OAlphaS2", "Hqq;qPrime_qbarPrime"
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
  qggBilinear,
  sameBilinear,
  differentBilinear,
  virtualInterferenceBilinear
};
assert[And @@ (! FreeQ[#, _FeynCalc`Spinor] & /@ inputBilinears),
  "At least one input bilinear contains no external spinors."];
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] & /@
      inputBilinears),
  "At least one input bilinear is missing photon index s05Mu."];
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] & /@
      inputBilinears),
  "At least one input bilinear is missing photon index s05Nu."];

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

validateSummedTensor[expr_, label_String] := Module[{},
  assert[expr =!= $Failed, label <> " evaluation returned $Failed."];
  assert[FreeQ[expr, _FeynCalc`Spinor],
    label <> " still contains external spinors."];
  assert[FreeQ[expr, _FeynCalc`Polarization],
    label <> " still contains an external polarization vector."];
  assert[FreeQ[expr, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " still contains unevaluated Dirac objects."];
  assert[FreeQ[expr, _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex],
    label <> " still contains explicit color indices."];
  assert[! FreeQ[expr, FeynCalc`LorentzIndex[s05Mu, D]],
    label <> " lost photon index s05Mu."];
  assert[! FreeQ[expr, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost photon index s05Nu."];
  True
];

processBilinear[
    expr_, polarizationMomenta_List, kinematicsSetup_Symbol,
    label_String, cachePath_String
  ] := Module[{answer, diracCachePath},
  If[FileExistsQ[cachePath],
    Print["S06_STAGE: loading cache for " <> label];
    answer = Check[Get[cachePath], $Failed];
    validateSummedTensor[answer, label <> " cached tensor"];
    Return[answer]
  ];

  diracCachePath = cachePath <> "_after_dirac";
  If[FileExistsQ[diracCachePath],
    Print["S06_STAGE: loading post-Dirac cache for " <> label];
    answer = Check[Get[diracCachePath], $Failed];
    assert[answer =!= $Failed,
      label <> " post-Dirac cache did not load."],

  Print["S06_STAGE: setting kinematics for " <> label];
  kinematicsSetup[];

  Print["S06_STAGE: final-gluon polarization sums for " <> label];
  answer = Fold[
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
  assert[answer =!= $Failed,
    label <> " final-gluon polarization sum failed."];

  Print["S06_STAGE: fermion spin sums for " <> label];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`FermionSpinSum[
        answer,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  assert[answer =!= $Failed, label <> " fermion spin sum failed."];

  Print["S06_STAGE: evaluating Dirac traces for " <> label];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`DiracSimplify[
        answer,
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
  assert[answer =!= $Failed, label <> " Dirac trace evaluation failed."];
  assert[FreeQ[answer, _FeynCalc`Spinor],
    label <> " still contains spinors after FermionSpinSum."];
  assert[FreeQ[answer, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " still contains Dirac objects after explicit trace evaluation."];
  Put[answer, diracCachePath];
  assert[FileExistsQ[diracCachePath] && FileByteCount[diracCachePath] > 0,
    label <> " post-Dirac cache was not written."];
  ];

  assert[FreeQ[answer, _FeynCalc`Spinor],
    label <> " post-Dirac expression contains spinors."];
  assert[FreeQ[answer, _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " post-Dirac expression contains unevaluated Dirac objects."];

  (* Insert both incoming-quark averages before color simplification. *)
  answer = answer/(2 FeynCalc`SUNN);

  Print["S06_STAGE: color sums and initial average for " <> label];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`SUNSimplify[
        answer,
        TimeConstrained -> Infinity,
        FeynCalc`SUNNToCACF -> True,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  validateSummedTensor[answer, label];

  Put[answer, cachePath];
  assert[FileExistsQ[cachePath] && FileByteCount[cachePath] > 0,
    label <> " cache was not written."];
  Print[
    "S06_STAGE: completed " <> label <> ", leaf count " <>
      ToString[LeafCount[answer]]
  ];
  answer
];

Print["S06_STAGE: processing all bilinears"];

loTensor = processBilinear[
  loBilinear,
  {k2},
  setTwoBodyKinematics,
  "LO square",
  cachePaths["LO"]
];

sameTensor = processBilinear[
  sameBilinear,
  {},
  setThreeBodyKinematics,
  "NLO real same-flavor q qbar square",
  cachePaths["RealSameFlavor"]
];

differentTensor = processBilinear[
  differentBilinear,
  {},
  setThreeBodyKinematics,
  "NLO real different-flavor q' qbar' square",
  cachePaths["RealDifferentFlavor"]
];

qggTensor = processBilinear[
  qggBilinear,
  {k2, k3},
  setThreeBodyKinematics,
  "NLO real Hqq;gg square",
  cachePaths["RealQGG"]
];

virtualInterferenceTensorSymbolic = processBilinear[
  virtualInterferenceBilinear,
  {k2},
  setTwoBodyKinematics,
  "NLO LO-virtual interference",
  cachePaths["VirtualInterference"]
];

allOutputTensors = {
  loTensor,
  qggTensor,
  sameTensor,
  differentTensor,
  virtualInterferenceTensorSymbolic
};
assert[And @@ (validateSummedTensor[#, "final output tensor"] & /@
      allOutputTensors),
  "At least one final output tensor failed validation."];

s06Checks = <|
  "AllFiveBilinearsProcessed" -> True,
  "FinalFermionSpinsSummed" -> True,
  "FinalGluonPolarizationsSummed" -> True,
  "AllColorsSummed" -> True,
  "InitialQuarkSpinAveraged" -> True,
  "InitialQuarkColorAveraged" -> True,
  "PhotonPolarizationNotSummed" -> True,
  "PhotonIndexMuPreserved" -> True,
  "PhotonIndexNuPreserved" -> True,
  "VirtualSquareStillExcluded" -> True
|>;

s06Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s05Path,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "InitialStateAverage" -> HoldForm[1/(2 FeynCalc`SUNN)],
  "PolarizationSumConvention" ->
    "D-dimensional massless final-gluon sum -g^(rho sigma), applied to each complete same-process amplitude sum.",
  "KinematicConventions" -> <|
    "TwoBody" -> {
      HoldForm[p^2 == 0], HoldForm[q^2 == -Q2],
      HoldForm[k1^2 == 0], HoldForm[k2^2 == 0],
      HoldForm[(p + q)^2 == sHat]
    },
    "ThreeBody" -> {
      HoldForm[p^2 == 0], HoldForm[q^2 == -Q2],
      HoldForm[k1^2 == 0], HoldForm[k2^2 == 0],
      HoldForm[k3^2 == 0],
      HoldForm[ti == (q - ki)^2],
      HoldForm[ui == (p - ki)^2],
      HoldForm[sij == (ki + kj)^2]
    }
  |>,
  "SpinColorAveragedTensors" -> <|
    "LO_OAlphaS" -> loTensor,
    "NLOReal_OAlphaS2" -> <|
      "Hqq;gg" -> qggTensor,
      "Hqq;q_qbar_sameFlavor" -> sameTensor,
      "Hqq;qPrime_qbarPrime" -> differentTensor
    |>,
    "NLOVirtualInterference_OAlphaS2_Symbolic" ->
      virtualInterferenceTensorSymbolic
  |>,
  "VirtualRenormalizationStatus" -> s05["VirtualRenormalizationStatus"],
  "MasslessVectorQCDFieldRenormalization" ->
    "dZfL1 and dZfR1 are identified with the common symbolic dZq1 before the unpolarized spin sum.",
  "Checks" -> s06Checks,
  "NotPerformedAtThisStage" -> {
    "phase-space integration and identical-particle symmetry factors",
    "different-flavor multiplicity sum",
    "real-virtual infrared cancellation",
    "PDF/FF collinear-factorization subtraction",
    "projection onto the paper's g and PP tensor structures"
  }
|>;

Print["S06_STAGE: writing " <> resultPath];
Put[s06Result, resultPath];

assert[FileExistsQ[resultPath], "The s06_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s06_result file is empty."];

Print["S06_SUCCESS"];
Print["S06_RESULT_PATH=" <> resultPath];
Print["S06_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S06_CHECKS=", InputForm[s06Checks]];

Quit[0];

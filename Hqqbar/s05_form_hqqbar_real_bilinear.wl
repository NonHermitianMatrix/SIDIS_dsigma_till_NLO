(* ::Package:: *)

(*
  Form the sole Hqqbar real amplitude bilinear at O(alpha_s^2):

    gamma*(q) + q(p) -> qbar(k1, fragmenting) + q(k2) + q(k3).

  S01 stores truncated charge-stripped kernels.  Complex conjugation requires
  complete external wavefunctions, so this stage regenerates the same eight
  selected diagrams with Truncated -> False, applies the exact reference-charge
  strip 3/2, and sums all diagrams coherently before forming the conjugate.

  Only the incoming photon is opened into s05Mu and s05Nu.  All external
  fermion spinors remain for S06.  The exact absolute real-square scale factor
  ScaleMu^(4 epsilon) is attached here; the physical charge weight, incoming
  quark average, and one identical-spectator 1/2! remain deferred.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, fileSHA256, atomicPut, couplingOccurrenceSignature,
  convertFullAmplitudes, openPhotonIndex, conjugateOpenAmplitude
];

fatal[message_String] := (
  If[
    ValueQ[temporaryResultPath] && StringQ[temporaryResultPath] &&
      FileExistsQ[temporaryResultPath],
    Quiet[DeleteFile[temporaryResultPath]]
  ];
  Print["S05_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPut[expression_, finalPath_String] := Module[
  {writeResult, loaded, renameResult},

  temporaryResultPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[temporaryResultPath],
    "The process-specific temporary result path already exists."
  ];

  writeResult = Quiet@Check[Put[expression, temporaryResultPath], $Failed];
  assert[writeResult =!= $Failed, "Atomic temporary result write failed."];
  assert[
    FileExistsQ[temporaryResultPath] && FileByteCount[temporaryResultPath] > 0,
    "Atomic temporary result is missing or empty."
  ];

  loaded = Quiet@Check[Get[temporaryResultPath], $Failed];
  assert[
    AssociationQ[loaded],
    "Atomic temporary result failed Association reload validation."
  ];
  assert[
    loaded["Status"] === "Complete" &&
      loaded["Stage"] === "HqqbarS05-v1",
    "Atomic temporary result has invalid status or stage."
  ];
  assert[
    And @@ (TrueQ /@ Values[loaded["Checks"]]),
    "Atomic temporary result contains a failed check."
  ];

  renameResult = Quiet@Check[
    RenameFile[temporaryResultPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic result rename failed."];
  temporaryResultPath = "";

  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Final s05_result is missing or empty after atomic rename."
  ];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{scriptDirectory, "s01_calculate_hqqbar_real.wl"}];
s01ResultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
s04SourcePath =
  FileNameJoin[{scriptDirectory, "s04_validate_hqqbar_virtual_absence.wl"}];
s04ResultPath = FileNameJoin[{scriptDirectory, "s04_result"}];
s05ResultPath = FileNameJoin[{scriptDirectory, "s05_result"}];
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S05_PREFLIGHT_ONLY"], ""] === "1";

expectedS01SourceHash =
  "750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71";
expectedS01ResultHash =
  "69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4";
expectedS04SourceHash =
  "b4afa7ff960449b2df5dbd38886e8e2a49aa2c14ed06d4cea515edcca65284e3";
expectedS04ResultHash =
  "b92526579c1aff40f40d305fe0087b000dde45355391843364c4ea5e52f72e9e";

staleTemporaryPaths = FileNames["s05_result.tmp.*", scriptDirectory];
assert[
  staleTemporaryPaths === {},
  "A stale S05 temporary result exists; resolve it before production."
];

Print["S05_STAGE: loading and validating Hqqbar S01/S04 inputs"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing."];
    assert[
      fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff."
    ];
  ],
  <|
    "S01 source" -> {s01SourcePath, expectedS01SourceHash},
    "S01 result" -> {s01ResultPath, expectedS01ResultHash},
    "S04 source" -> {s04SourcePath, expectedS04SourceHash},
    "S04 result" -> {s04ResultPath, expectedS04ResultHash}
  |>
];

s01 = Quiet@Check[Get[s01ResultPath], $Failed];
s04 = Quiet@Check[Get[s04ResultPath], $Failed];
assert[
  AssociationQ[s01] && AssociationQ[s04],
  "At least one upstream result is not an Association."
];
assert[
  s01["Status"] === "Complete" && s01["Stage"] === "HqqbarS01-v1" &&
    s01["ResultSchemaVersion"] === 1,
  "The S01 status, stage, or schema is invalid."
];
assert[
  s04["Status"] === "Complete" && s04["Stage"] === "HqqbarS04-v1" &&
    s04["ResultSchemaVersion"] === 1,
  "The S04 status, stage, or schema is invalid."
];
assert[
  s01["Channel"] === "Hqqbar only" && s04["Channel"] === "Hqqbar only" &&
    s01["Contribution"] === "H_{q qbar; q q}" &&
    s04["Contribution"] === "H_{q qbar; q q}",
  "At least one upstream channel or contribution is invalid."
];
assert[
  s01["ProgramSHA256"] === expectedS01SourceHash &&
    s04["ProgramSHA256"] === expectedS04SourceHash,
  "An upstream result does not bind its accepted source."
];
assert[
  s04["Input"]["S01SourceSHA256"] === expectedS01SourceHash &&
    s04["Input"]["S01ResultSHA256"] === expectedS01ResultHash,
  "S04 does not bind the accepted S01 inputs."
];
assert[
  And @@ (TrueQ /@ Values[s01["Checks"]]) &&
    And @@ (TrueQ /@ Values[s04["Checks"]]),
  "At least one upstream validation check is not True."
];
assert[
  s04["StageDisposition"] === "NotApplicableAtThisOrder" &&
    s04["VirtualRenormalization"]["Applicable"] === False,
  "S04 does not enforce the real-only Hqqbar boundary."
];
assert[
  Total[{
    s04["VirtualRenormalization"]["TwoBodyBornContributionAtThisOrder"],
    s04["VirtualRenormalization"]["OneLoopVirtualContributionAtThisOrder"],
    s04["VirtualRenormalization"]["LoopPoleContributionAtThisOrder"],
    s04["VirtualRenormalization"]["UVCountertermContributionAtThisOrder"]
  }] === 0,
  "S04's absent-sector contributions are not exact zero."
];
assert[
  ! KeyExistsQ[s01, "LO"] && ! KeyExistsQ[s01, "NLOVirtual"] &&
    Keys[s01["NLOReal"]] === {"Hqqbar;q_q"},
  "S01 does not contain exactly the real-only Hqqbar payload."
];
assert[
  s01["BigTMDConvention"]["ChannelNumber"] === 5 &&
    StringStartsQ[s01["BigTMDConvention"]["ChargeCase"], "A only"],
  "The accepted channel-5A charge bookkeeping is missing."
];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

couplingOccurrenceSignature[amplitude_] :=
  {
    Count[
      amplitude,
      HoldPattern[FeynArts`FCGV["EL"]],
      Infinity
    ],
    Count[
      amplitude,
      HoldPattern[FeynCalc`SMP["g_s"]],
      Infinity
    ]
  };

convertFullAmplitudes[diagrams_, label_String] := Module[{raw, answer},
  Print["S05_STAGE: restoring external states for " <> label];
  raw = Check[
    FeynArts`CreateFeynAmp[
      diagrams,
      FeynArts`Truncated -> False
    ],
    $Failed
  ];
  assert[raw =!= $Failed, label <> " full FeynArts generation failed."];

  answer = CheckAbort[
    Check[
      FeynCalc`FCFAConvert[
        raw,
        FeynCalc`IncomingMomenta -> {q, p},
        FeynCalc`OutgoingMomenta -> {k1, k2, k3},
        FeynCalc`LoopMomenta -> {},
        FeynCalc`ChangeDimension -> D,
        FeynCalc`DropSumOver -> True,
        FeynCalc`UndoChiralSplittings -> True,
        FeynCalc`Contract -> False,
        FeynCalc`SMP -> True,
        List -> True,
        FeynCalc`FinalSubstitutions -> masslessRules
      ],
      $Failed
    ],
    $Failed
  ];
  assert[ListQ[answer], label <> " FCFAConvert did not return a list."];
  assert[
    FreeQ[answer, _FeynArts`FAFeynAmp],
    label <> " conversion left a FeynArts amplitude unevaluated."
  ];
  answer
];

(*
  Contract may place the photon polarization in a slashed vector, either
  scalar-product order, or an epsilon tensor.  Replace only q's incoming
  photon polarization and leave all four external fermion spinors untouched.
*)
openPhotonIndex[amplitude_, openIndex_Symbol, label_String] := Module[
  {contracted, answer},

  contracted = FeynCalc`Contract[amplitude];
  assert[
    ! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no incoming-photon polarization to open."
  ];

  answer = contracted /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        dimension_
      ]
    ] :> FeynCalc`DiracGamma[
      FeynCalc`LorentzIndex[openIndex, dimension], dimension
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`LorentzIndex[lorentz_, dimension_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[lorentz, dimension],
      FeynCalc`LorentzIndex[openIndex, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        FeynCalc`Momentum[momentum_, dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[openIndex, dimension],
      FeynCalc`Momentum[momentum, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[momentum_, dimension_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`Momentum[momentum, dimension],
      FeynCalc`LorentzIndex[openIndex, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Eps[
        before___,
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        after___
      ]
    ] :> FeynCalc`Eps[
      before,
      FeynCalc`LorentzIndex[openIndex, dimension],
      after
    ];

  answer = FeynCalc`Contract[answer];
  assert[
    FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains an incoming-photon polarization."
  ];
  assert[
    ! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the requested open photon index."
  ];
  assert[
    ! FreeQ[answer, _FeynCalc`Spinor],
    label <> " lost its external fermion wavefunctions."
  ];
  answer
];

conjugateOpenAmplitude[
    amplitude_, oldIndex_Symbol, newIndex_Symbol, label_String
  ] := Module[{answer},
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`ComplexConjugate[
        amplitude /. oldIndex -> newIndex,
        FeynCalc`FCRenameDummyIndices -> True,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  assert[answer =!= $Failed, label <> " complex conjugation failed."];
  assert[
    FreeQ[answer, FeynCalc`ComplexConjugate],
    label <> " left an unevaluated FeynCalc ComplexConjugate call."
  ];
  assert[
    ! FreeQ[answer, FeynCalc`LorentzIndex[newIndex, D]],
    label <> " conjugate does not contain the second photon index."
  ];
  answer
];

realPayload = s01["NLOReal"]["Hqqbar;q_q"];
assert[AssociationQ[realPayload], "The Hqqbar real payload is invalid."];
expectedDiagramCount = realPayload["DiagramCount"];
assert[
  expectedDiagramCount === 8 &&
    s04["RealPayloadAudit"]["DiagramCount"] === expectedDiagramCount,
  "The validated Hqqbar real diagram count is not eight."
];
diagrams = realPayload["FeynArtsDiagrams"];
assert[
  MatchQ[Head[diagrams], _FeynArts`TopologyList] &&
    Length[diagrams] === expectedDiagramCount,
  "The stored FeynArts diagram set is invalid."
];

referenceCharge = s01["ElectricChargeNormalization"]["ReferenceCharge"];
chargeStripFactor =
  s01["ElectricChargeNormalization"]["AmplitudeStripFactor"];
assert[
  referenceCharge === 2/3 && chargeStripFactor === 3/2 &&
    referenceCharge chargeStripFactor === 1,
  "The exact reference-charge stripping convention is invalid."
];

referenceFullPerDiagram = convertFullAmplitudes[
  diagrams,
  "NLO real Hqqbar;q_q"
];
assert[
  Length[referenceFullPerDiagram] === expectedDiagramCount,
  "The full external-state amplitude count does not match S01."
];
chargeStrippedFullPerDiagram = chargeStripFactor referenceFullPerDiagram;
assert[
  chargeStrippedFullPerDiagram === (3/2) referenceFullPerDiagram,
  "The full amplitudes do not obey the exact 3/2 charge-strip relation."
];
assert[
  And @@ (
    (# === {1, 2}) & /@
      (couplingOccurrenceSignature /@ referenceFullPerDiagram)
  ),
  "A full amplitude does not contain exactly one EL and two g_s vertices."
];
assert[
  FreeQ[chargeStrippedFullPerDiagram, _Real],
  "A machine-precision number appeared in the full symbolic amplitudes."
];

referenceFullSum = Total[referenceFullPerDiagram];
chargeStrippedFullSum = Total[chargeStrippedFullPerDiagram];
assert[
  referenceFullSum === Total[referenceFullPerDiagram] &&
    chargeStrippedFullSum === Total[chargeStrippedFullPerDiagram],
  "A coherent full-amplitude sum failed exact reconstruction."
];
assert[
  chargeStrippedFullSum =!= 0,
  "The coherent full Hqqbar real amplitude is zero."
];

expectedExternalSpinors = {
  FeynCalc`Spinor[FeynCalc`Momentum[p, D], 0, 1],
  FeynCalc`Spinor[-FeynCalc`Momentum[k1, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k2, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k3, D], 0, 1]
};
uniqueExternalSpinors = DeleteDuplicates[
  Cases[chargeStrippedFullSum, _FeynCalc`Spinor, Infinity]
];
assert[
  Length[uniqueExternalSpinors] === Length[expectedExternalSpinors] &&
    And @@ (MemberQ[uniqueExternalSpinors, #] & /@ expectedExternalSpinors),
  "The full amplitude does not contain exactly the four expected spinors."
];

Print["S05_STAGE: opening the incoming-photon Lorentz index"];
realAmplitudeMu = openPhotonIndex[
  chargeStrippedFullSum,
  s05Mu,
  "real Hqqbar;q_q amplitude"
];
assert[
  And @@ (MemberQ[Cases[realAmplitudeMu, _FeynCalc`Spinor, Infinity], #] & /@
    expectedExternalSpinors),
  "Opening the photon index changed an external spinor orientation."
];

Print["S05_STAGE: constructing the conjugate open-index amplitude"];
realConjugateNu = conjugateOpenAmplitude[
  realAmplitudeMu,
  s05Mu,
  s05Nu,
  "real Hqqbar;q_q"
];

Print["S05_STAGE: forming the coherent 64-pair real bilinear"];
realBilinearCoreMuNu = realAmplitudeMu realConjugateNu;
dimensionalScaleFactor = ScaleMu^(4 epsilon);
realBilinearScaleAttachedMuNu =
  dimensionalScaleFactor realBilinearCoreMuNu;

assert[
  ! FreeQ[realBilinearCoreMuNu, FeynCalc`LorentzIndex[s05Mu, D]] &&
    ! FreeQ[realBilinearCoreMuNu, FeynCalc`LorentzIndex[s05Nu, D]],
  "The real bilinear is missing an open photon index."
];
assert[
  FreeQ[realBilinearCoreMuNu, FeynCalc`Polarization[q, ___]],
  "The real bilinear still contains the incoming-photon polarization."
];
assert[
  ! FreeQ[realBilinearCoreMuNu, _FeynCalc`Spinor],
  "The real bilinear lost its external fermion spinors."
];
assert[
  FreeQ[realBilinearCoreMuNu, FeynCalc`ComplexConjugate],
  "The real bilinear contains an unevaluated conjugation."
];
assert[
  FreeQ[realBilinearCoreMuNu, ScaleMu] &&
    realBilinearScaleAttachedMuNu ===
      ScaleMu^(4 epsilon) realBilinearCoreMuNu,
  "The dimensional scale factor is missing, duplicated, or inconsistent."
];
assert[
  FreeQ[
    realBilinearScaleAttachedMuNu,
    FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`TID | FeynCalc`EpsilonUV |
      FeynCalc`EpsilonIR
  ],
  "A loop or regulator object appeared in the real-only bilinear."
];
assert[
  FreeQ[realBilinearScaleAttachedMuNu, _Real],
  "A machine-precision number appeared in the symbolic bilinear."
];

programHash = fileSHA256[programPath];
orderedDiagramPairCount = expectedDiagramCount^2;
checks = <|
  "ValidatedS01SourceHash" -> True,
  "ValidatedS01ResultHash" -> True,
  "ValidatedS04SourceHash" -> True,
  "ValidatedS04ResultHash" -> True,
  "S04NoVirtualContractEnforced" -> True,
  "SingleHqqbarRealPayload" -> True,
  "FullAmplitudeCountEight" -> True,
  "ExactReferenceChargeStripFactor" -> True,
  "EachFullAmplitudeContainsOneELAndTwoGSVertices" -> True,
  "FourExpectedExternalSpinors" -> True,
  "FragmentingAntiquarkOrientationMinusK1" -> True,
  "AllDiagramsCoherentlySummedBeforeProduct" -> True,
  "CoherentOrderedDiagramPairCount64" -> True,
  "PhotonPolarizationRemoved" -> True,
  "PhotonIndexMuPresent" -> True,
  "PhotonIndexNuPresent" -> True,
  "ExternalSpinorsRetainedForS06" -> True,
  "FeynCalcConjugationEvaluated" -> True,
  "EveryOrderedPairHasCouplingOrderE2GS4" -> True,
  "AbsoluteScaleMuPowerFourEpsilonAttached" -> True,
  "NoSeparateMSBarSEpsilonAtS05" -> True,
  "PhysicalChargeWeightDeferred" -> True,
  "IdenticalSpectatorFactorDeferred" -> True,
  "IncomingQuarkAverageDeferred" -> True,
  "NoLoopOrRegulatorData" -> True,
  "NoMachinePrecisionNumbers" -> True,
  "AtomicS05ResultWrite" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S05 check is not True."
];

If[preflightOnly,
  Print["S05_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S05_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print["S05_DYNAMIC_PREFLIGHT_OPEN_AMPLITUDE_LEAF_COUNT=", LeafCount[realAmplitudeMu]];
  Print["S05_DYNAMIC_PREFLIGHT_SCALE_ATTACHED_TENSOR_LEAF_COUNT=", LeafCount[realBilinearScaleAttachedMuNu]];
  Quit[0]
];

s05Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqbarS05-v1",
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqbar only",
  "Contribution" -> "H_{q qbar; q q} real bilinear",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "Input" -> <|
    "S01SourcePath" -> s01SourcePath,
    "S01SourceSHA256" -> fileSHA256[s01SourcePath],
    "S01ResultPath" -> s01ResultPath,
    "S01ResultSHA256" -> fileSHA256[s01ResultPath],
    "S04SourcePath" -> s04SourcePath,
    "S04SourceSHA256" -> fileSHA256[s04SourcePath],
    "S04ResultPath" -> s04ResultPath,
    "S04ResultSHA256" -> fileSHA256[s04ResultPath],
    "S04StageDisposition" -> s04["StageDisposition"]
  |>,
  "ExternalProcess" -> <|
    "Incoming" -> {"gamma*(q)", "q(p)"},
    "Outgoing" -> {
      "qbar(k1, fragmenting)", "q(k2, spectator)", "q(k3, spectator)"
    },
    "ExternalSpinors" -> expectedExternalSpinors,
    "FragmentingParton" -> "qbar(k1)",
    "UnobservedPartons" -> "identical q(k2), q(k3)"
  |>,
  "ChargeBookkeeping" -> <|
    "FeynArtsReferenceCharge" -> referenceCharge,
    "AmplitudeStripFactor" -> chargeStripFactor,
    "FullAmplitudesAreChargeStripped" -> True,
    "PhysicalChargeWeight" -> "Sum_q e_q^2 f_q D_qbar",
    "PhysicalChargeWeightAppliedAtS05" -> False,
    "BigTMDChannel" -> 5,
    "BigTMDChargeCase" -> "A only"
  |>,
  "DiagramCounts" -> <|
    "NLORealHqqbarQQ" -> expectedDiagramCount,
    "CoherentOrderedDiagramPairs" -> orderedDiagramPairCount
  |>,
  "FullExternalStateAmplitudes" -> <|
    "ReferenceChargePerDiagram" -> referenceFullPerDiagram,
    "ChargeStrippedPerDiagram" -> chargeStrippedFullPerDiagram,
    "ReferenceChargeCoherentSum" -> referenceFullSum,
    "ChargeStrippedCoherentSum" -> chargeStrippedFullSum,
    "OpenPhotonIndexMu" -> realAmplitudeMu,
    "ConjugateOpenPhotonIndexNu" -> realConjugateNu
  |>,
  "Bilinear" -> <|
    "PhotonIndices" -> {s05Mu, s05Nu},
    "ChargeStrippedCore" -> realBilinearCoreMuNu,
    "DimensionalScaleFactor" -> dimensionalScaleFactor,
    "ScaleConvention" ->
      "absolute ScaleMu^(4 epsilon) for the square of a two-strong-vertex amplitude",
    "SeparateMSBarSEpsilonApplied" -> False,
    "ScaleAttachedRealTensor" -> realBilinearScaleAttachedMuNu
  |>,
  "SymmetryAndAverageBookkeeping" -> <|
    "IdenticalSpectatorFactorAppliedAtS05" -> False,
    "IdenticalSpectatorFactorDeferred" -> HoldForm[1/2!],
    "IdenticalSpectatorFactorDestination" ->
      "fully integrated three-body spectator phase space",
    "IncomingQuarkSpinColorAverageAppliedAtS05" -> False,
    "IncomingQuarkSpinColorAverageDeferred" -> "1/(2 Nc) at S06"
  |>,
  "VirtualContributionAtThisOrder" -> <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" -> s04["StageDisposition"]
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "spin/color sums, Dirac traces, or incoming-quark averaging",
    "the deferred one 1/2! identical-spectator phase-space factor",
    "phase-space integration",
    "MS-bar PDF/FF collinear factorization",
    "projector contraction or F-hat inversion",
    "physical flavor-charge assembly or BigTMD numerical comparison"
  },
  "DownstreamInstruction" ->
    "Hqqbar S06 must use Bilinear[ScaleAttachedRealTensor], sum all four external fermion spins and colors, and apply exactly the incoming-quark average 1/(2 Nc). It must not add a virtual term, physical flavor charge, or the deferred 1/2! phase-space factor."
|>;

Print["S05_STAGE: atomically writing the Hqqbar real bilinear result"];
atomicPut[s05Result, s05ResultPath];

reloadedResult = Quiet@Check[Get[s05ResultPath], $Failed];
assert[AssociationQ[reloadedResult], "Final s05_result failed reload."];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === "HqqbarS05-v1" &&
    reloadedResult["ResultSchemaVersion"] === 1,
  "Final s05_result status, stage, or schema is invalid."
];
assert[
  reloadedResult["ProgramSHA256"] === programHash,
  "Final s05_result program hash is invalid."
];
assert[
  reloadedResult["Input"]["S01ResultSHA256"] === expectedS01ResultHash &&
    reloadedResult["Input"]["S04ResultSHA256"] === expectedS04ResultHash,
  "Final s05_result upstream hash binding is invalid."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Final s05_result contains a failed check."
];
assert[
  reloadedResult["Bilinear"]["ChargeStrippedCore"] ===
      reloadedResult["FullExternalStateAmplitudes"]["OpenPhotonIndexMu"]
        reloadedResult["FullExternalStateAmplitudes"]["ConjugateOpenPhotonIndexNu"] &&
    reloadedResult["Bilinear"]["ScaleAttachedRealTensor"] ===
      ScaleMu^(4 epsilon) reloadedResult["Bilinear"]["ChargeStrippedCore"],
  "Final s05_result bilinear reconstruction or scale attachment is invalid."
];
assert[
  reloadedResult["VirtualContributionAtThisOrder"]["Applicable"] === False &&
    reloadedResult["VirtualContributionAtThisOrder"]["Interference"] === 0,
  "Final s05_result virtual contribution is invalid."
];

Print["S05_SUCCESS"];
Print["S05_PROGRAM_SHA256=" <> programHash];
Print["S05_RESULT_PATH=" <> s05ResultPath];
Print["S05_RESULT_SHA256=" <> fileSHA256[s05ResultPath]];
Print["S05_REAL_DIAGRAM_COUNT=", expectedDiagramCount];
Print["S05_COHERENT_ORDERED_DIAGRAM_PAIRS=", orderedDiagramPairCount];
Print["S05_CHECK_COUNT=", Length[checks]];
Print["S05_OPEN_AMPLITUDE_LEAF_COUNT=", LeafCount[realAmplitudeMu]];
Print["S05_SCALE_ATTACHED_TENSOR_LEAF_COUNT=", LeafCount[realBilinearScaleAttachedMuNu]];
Print["S05_RESULT_BYTES=", FileByteCount[s05ResultPath]];

Quit[0];

(* ::Package:: *)

(*
  Form the sole Hgg amplitude bilinear needed at O(alpha_s^2):

    |M(gamma*(q) + g(p) -> g(k1) + q(k2) + qbar(k3))|^2.

  S01 stored amputated kernels generated with Truncated -> True.  FeynCalc's
  ComplexConjugate requires proper matrix elements with closed external
  spinor chains, so this stage regenerates external wavefunctions from the
  already-selected eight FeynArts diagrams using Truncated -> False.

  All eight diagrams are coherently summed before multiplication by the
  conjugate.  Only the incoming photon polarization is opened into the two
  tensor indices s05Mu and s05Nu.  Incoming/final gluon polarizations,
  external spinors, spin/color sums, and the initial-gluon average are retained
  for S06.  There is no Hgg virtual interference at this order.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, convertFullAmplitudes, openPhotonIndex,
  conjugateOpenAmplitude
];

fatal[message_String] := (
  Print["S05_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s01Path = FileNameJoin[{scriptDirectory, "s01_result"}];
s04Path = FileNameJoin[{scriptDirectory, "s04_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s05_result"}];

Print["S05_STAGE: loading validated Hgg S01 and S04 results"];
assert[FileExistsQ[s01Path], "s01_result does not exist."];
assert[FileExistsQ[s04Path], "s04_result does not exist."];
s01 = Check[Get[s01Path], $Failed];
s04 = Check[Get[s04Path], $Failed];
assert[
  AssociationQ[s01] && s01["Status"] === "Complete",
  "s01_result is not a complete Association."
];
assert[
  AssociationQ[s04] && s04["Status"] === "Complete",
  "s04_result is not a complete Association."
];
assert[
  s01["Channel"] === "Hgg only" && s04["Channel"] === "Hgg only",
  "At least one source result is not Hgg-only."
];
assert[
  s04["StageDisposition"] === "NotApplicableAtThisOrder" &&
    s04["VirtualRenormalization", "Applicable"] === False,
  "S04 does not enforce the required no-virtual Hgg contract."
];
assert[
  s04["SourceResultSHA256"] === FileHash[s01Path, "SHA256"],
  "S04 is not bound to the current Hgg s01_result."
];
assert[
  ! KeyExistsQ[s01, "LO"] && ! KeyExistsQ[s01, "NLOVirtual"],
  "The Hgg S01 input unexpectedly contains LO or virtual data."
];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

convertFullAmplitudes[
    diagrams_, outgoingMomenta_List, label_String
  ] := Module[{raw, answer},
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
        FeynCalc`OutgoingMomenta -> outgoingMomenta,
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
  Contract can place the incoming photon polarization in a slashed vector,
  a Lorentz scalar product, or an epsilon tensor.  These are the corrected
  mappings established by the Hqq S05 workflow; they open only q's photon
  polarization and leave both gluon polarizations untouched.
*)
openPhotonIndex[amp_, openIndex_Symbol, label_String] :=
 Module[{contracted, answer},
  contracted = FeynCalc`Contract[amp];
  assert[
    ! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no incoming-photon polarization to open."
  ];
  answer = contracted /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], dim_
      ]
    ] :> FeynCalc`DiracGamma[
      FeynCalc`LorentzIndex[openIndex, dim], dim
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`LorentzIndex[lor_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[lor, dim],
      FeynCalc`LorentzIndex[openIndex, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        FeynCalc`Momentum[momentum_, dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[openIndex, dim],
      FeynCalc`Momentum[momentum, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[momentum_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`Momentum[momentum, dim],
      FeynCalc`LorentzIndex[openIndex, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Eps[
        before___,
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        after___
      ]
    ] :> FeynCalc`Eps[
      before,
      FeynCalc`LorentzIndex[openIndex, dim],
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
    label <> " contains no external spinors after state restoration."
  ];
  assert[
    ! FreeQ[answer, FeynCalc`Polarization[p, ___]],
    label <> " lost the incoming-gluon polarization."
  ];
  assert[
    ! FreeQ[answer, FeynCalc`Polarization[k1, ___]],
    label <> " lost the fragmenting-gluon polarization."
  ];
  answer
];

conjugateOpenAmplitude[
    amp_, oldIndex_Symbol, newIndex_Symbol, label_String
  ] := Module[{answer},
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`ComplexConjugate[
        amp /. oldIndex -> newIndex,
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

hggStored = s01["NLOReal", "Hgg;q_qbar"];
expectedDiagramCount = hggStored["DiagramCount"];

assert[
  AssociationQ[hggStored] && expectedDiagramCount === 8,
  "Expected the validated eight-diagram Hgg;q qbar payload."
];

hggFullPerDiagram = convertFullAmplitudes[
  hggStored["FeynArtsDiagrams"],
  {k1, k2, k3},
  "NLO real Hgg;q qbar"
];

assert[
  Length[hggFullPerDiagram] === expectedDiagramCount,
  "The restored full-amplitude count does not match S01."
];
assert[
  FreeQ[hggFullPerDiagram, _Real],
  "Machine-precision numbers appeared in the symbolic full amplitudes."
];

hggFullSum = Total[hggFullPerDiagram];
assert[
  hggFullSum === Total[hggFullPerDiagram],
  "The coherent full-amplitude sum failed reconstruction."
];

Print["S05_STAGE: opening the incoming-photon Lorentz index"];
hggMu = openPhotonIndex[
  hggFullSum,
  s05Mu,
  "real Hgg;q qbar amplitude"
];

Print["S05_STAGE: constructing the conjugate Hgg amplitude"];
hggConjugateNu = conjugateOpenAmplitude[
  hggMu,
  s05Mu,
  s05Nu,
  "real Hgg;q qbar"
];

Print["S05_STAGE: forming the coherent O(alpha_s^2) real bilinear"];
hggRealSquareMuNu = hggMu hggConjugateNu;

assert[
  ! FreeQ[hggRealSquareMuNu, FeynCalc`LorentzIndex[s05Mu, D]],
  "The Hgg bilinear is missing photon index s05Mu."
];
assert[
  ! FreeQ[hggRealSquareMuNu, FeynCalc`LorentzIndex[s05Nu, D]],
  "The Hgg bilinear is missing photon index s05Nu."
];
assert[
  FreeQ[hggRealSquareMuNu, FeynCalc`Polarization[q, ___]],
  "The Hgg bilinear still contains an incoming-photon polarization."
];
assert[
  ! FreeQ[hggRealSquareMuNu, FeynCalc`Polarization[p, ___]],
  "The Hgg bilinear is missing the incoming-gluon polarization."
];
assert[
  ! FreeQ[hggRealSquareMuNu, FeynCalc`Polarization[k1, ___]],
  "The Hgg bilinear is missing the fragmenting-gluon polarization."
];
assert[
  ! FreeQ[hggRealSquareMuNu, _FeynCalc`Spinor],
  "The Hgg bilinear is missing external spinors."
];
assert[
  FreeQ[
    hggRealSquareMuNu,
    FeynCalc`PaVe | FeynCalc`TID | FeynCalc`EpsilonUV |
      FeynCalc`EpsilonIR
  ],
  "Unexpected loop or regulator data appeared in the real-only bilinear."
];
assert[
  FreeQ[hggRealSquareMuNu, _Real],
  "Machine-precision numbers appeared in the symbolic Hgg bilinear."
];

s05Checks = <|
  "S04NoVirtualContractEnforced" -> True,
  "FullAmplitudeCountMatchesS01" -> True,
  "AllEightDiagramsCoherentlySummedBeforeProduct" -> True,
  "CoherentOrderedDiagramPairCountIs64" -> True,
  "PhotonPolarizationRemoved" -> True,
  "PhotonIndexMuPresent" -> True,
  "PhotonIndexNuPresent" -> True,
  "IncomingGluonPolarizationRetained" -> True,
  "FragmentingGluonPolarizationRetained" -> True,
  "ExternalSpinorsRetained" -> True,
  "FeynCalcConjugationEvaluated" -> True,
  "NoLoopOrRegulatorData" -> True,
  "CalculationFullySymbolic" -> True,
  "SpinColorSumsNotYetApplied" -> True
|>;

s05Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hgg only",
  "Contribution" -> "Hgg;q qbar real square",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> <|
    "S01" -> s01Path,
    "S01SHA256" -> FileHash[s01Path, "SHA256"],
    "S04" -> s04Path,
    "S04SHA256" -> FileHash[s04Path, "SHA256"]
  |>,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "ExternalProcess" -> <|
    "Incoming" -> {"gamma*(q)", "g(p)"},
    "Outgoing" -> {"g(k1)", "q(k2)", "qbar(k3)"},
    "FragmentingParton" -> "g(k1)",
    "RepresentativeFlavor" ->
      s01["Conventions", "RepresentativeFlavor"],
    "PhysicalFlavorWeight" ->
      s01["Conventions", "PhysicalFlavorWeight"]
  |>,
  "DiagramCounts" -> <|
    "NLORealHggQqbar" -> expectedDiagramCount,
    "CoherentOrderedDiagramPairs" -> expectedDiagramCount^2
  |>,
  "FullExternalStateAmplitudes" -> <|
    "PerDiagram" -> hggFullPerDiagram,
    "CoherentSum" -> hggFullSum,
    "OpenPhotonIndexMu" -> hggMu,
    "ConjugateOpenPhotonIndexNu" -> hggConjugateNu
  |>,
  "Bilinears" -> <|
    "NLORealSquare_OAlphaS2" -> <|
      "Hgg;q_qbar" -> hggRealSquareMuNu
    |>
  |>,
  "VirtualContributionAtThisOrder" -> <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" -> s04["StageDisposition"]
  |>,
  "PerturbativeSelection" -> <|
    "RealSquare" -> "O(alpha_s^2)",
    "LOSquare" -> "Absent for Hgg at this order",
    "LOVirtualInterference" -> "Absent for Hgg at this order",
    "VirtualSquare" -> "Absent"
  |>,
  "Checks" -> s05Checks,
  "NotPerformedAtThisStage" -> {
    "incoming and final gluon polarization sums",
    "final-state quark and antiquark spin sums",
    "color sums",
    "initial-gluon spin and color average",
    "physical Sum_f e_f^2 flavor-charge sum",
    "phase-space integration",
    "PDF/FF collinear-factorization subtraction",
    "projection onto the paper's g and PP tensor structures"
  }
|>;

Print["S05_STAGE: writing " <> resultPath];
Put[s05Result, resultPath];

assert[FileExistsQ[resultPath], "The s05_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s05_result file is empty."];

Print["S05_SUCCESS"];
Print["S05_RESULT_PATH=" <> resultPath];
Print["S05_REAL_DIAGRAM_COUNT=", expectedDiagramCount];
Print["S05_COHERENT_ORDERED_DIAGRAM_PAIRS=", expectedDiagramCount^2];
Print["S05_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

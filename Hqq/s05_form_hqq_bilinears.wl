(* ::Package:: *)

(*
  Form the Hqq amplitude bilinears needed through O(alpha_s^2):

    |M_LO|^2,
    |M_real,i|^2 for each distinct real subprocess i,
    M_LO^mu (M_V,ren^nu)^* + M_V,ren^mu (M_LO^nu)^*.

  The FeynArts diagrams stored in s01_result were originally converted with
  Truncated -> True and therefore contain amputated kernels.  FeynCalc's
  ComplexConjugate requires proper matrix elements with closed external spinor
  chains.  This stage consequently regenerates the external wavefunctions from
  the already selected FeynArts diagrams, converts them to FeynCalc, removes
  only the incoming photon polarization, and keeps the photon indices s05Mu
  and s05Nu open.

  Diagrams with identical external particles are coherently summed before
  multiplication by their conjugates.  Different real subprocesses remain
  separate.  Spin/color/polarization sums and initial-state averages are not
  performed here.  |M_V,ren|^2 is deliberately absent because it starts beyond
  O(alpha_s^2).
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, convertFullAmplitudes, reduceFullVirtualAmplitude,
  openPhotonIndex, conjugateOpenAmplitude
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
virtualTIDCachePath = FileNameJoin[{
  scriptDirectory, "s05_virtual_full_tid_cache"
}];

Print["S05_STAGE: loading s01_result and s04_result"];
assert[FileExistsQ[s01Path], "s01_result does not exist."];
assert[FileExistsQ[s04Path], "s04_result does not exist."];
s01 = Check[Get[s01Path], $Failed];
s04 = Check[Get[s04Path], $Failed];
assert[AssociationQ[s01] && s01["Status"] === "Complete",
  "s01_result is not a complete Association."];
assert[AssociationQ[s04] && s04["Status"] === "Complete",
  "s04_result is not a complete Association."];
assert[s01["Channel"] === "Hqq only" && s04["Channel"] === "Hqq only",
  "At least one source result is not Hqq-only."];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

convertFullAmplitudes[
    diagrams_, outgoingMomenta_List, loopMomenta_List, label_String
  ] := Module[{raw, answer},
  Print["S05_STAGE: restoring external states for " <> label];
  raw = Check[
    FeynArts`CreateFeynAmp[
      diagrams,
      FeynArts`Truncated -> False
    ],
    $Failed
  ];
  assert[raw =!= $Failed, label <> " full FeynArts amplitude generation failed."];
  answer = CheckAbort[
    Check[
      FeynCalc`FCFAConvert[
        raw,
        FeynCalc`IncomingMomenta -> {q, p},
        FeynCalc`OutgoingMomenta -> outgoingMomenta,
        FeynCalc`LoopMomenta -> loopMomenta,
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
  assert[FreeQ[answer, _FeynArts`FAFeynAmp],
    label <> " conversion left a FeynArts amplitude unevaluated."];
  answer
];

expectedCounts = <|
  "LO" -> 2,
  "RealQGG" -> 8,
  "RealSameFlavor" -> 8,
  "RealDifferentFlavor" -> 4,
  "Virtual" -> 23,
  "Counterterm" -> 12
|>;

loFullPerDiagram = convertFullAmplitudes[
  s01["LO", "FeynArtsDiagrams"], {k1, k2}, {}, "LO"
];
qggFullPerDiagram = convertFullAmplitudes[
  s01["NLOReal", "Hqq;gg", "FeynArtsDiagrams"],
  {k1, k2, k3}, {}, "NLO real Hqq;gg"
];
sameFullPerDiagram = convertFullAmplitudes[
  s01["NLOReal", "Hqq;q_qbar_sameFlavor", "FeynArtsDiagrams"],
  {k1, k2, k3}, {}, "NLO real same-flavor q qbar"
];
differentFullPerDiagram = convertFullAmplitudes[
  s01["NLOReal", "Hqq;qPrime_qbarPrime", "FeynArtsDiagrams"],
  {k1, k2, k3}, {}, "NLO real different-flavor q' qbar'"
];
virtualFullPerDiagram = convertFullAmplitudes[
  s01["NLOVirtual", "BareLoop", "FeynArtsDiagrams"],
  {k1, k2}, {ell}, "NLO bare virtual"
];
countertermFullPerDiagramOriginal = convertFullAmplitudes[
  s01["NLOVirtual", "UVCounterterms", "FeynArtsDiagrams"],
  {k1, k2}, {}, "NLO UV counterterms"
];

convertedCounts = <|
  "LO" -> Length[loFullPerDiagram],
  "RealQGG" -> Length[qggFullPerDiagram],
  "RealSameFlavor" -> Length[sameFullPerDiagram],
  "RealDifferentFlavor" -> Length[differentFullPerDiagram],
  "Virtual" -> Length[virtualFullPerDiagram],
  "Counterterm" -> Length[countertermFullPerDiagramOriginal]
|>;
assert[convertedCounts === expectedCounts,
  "Full-amplitude diagram counts do not match s01_result."];

(* Massless 2 -> 2 kinematics used by the virtual TID reduction. *)
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

reduceFullVirtualAmplitude[amp_, index_Integer] := Module[{answer},
  Print[
    "S05_STAGE: TID full virtual diagram " <> ToString[index] <> "/" <>
      ToString[expectedCounts["Virtual"]]
  ];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`TID[
        amp,
        ell,
        FeynCalc`ToPaVe -> True,
        FeynCalc`UsePaVeBasis -> True,
        FeynCalc`FeynAmpDenominatorSimplify -> False,
        FeynCalc`ApartFF -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  answer
];

Print["S05_STAGE: reducing full virtual amplitudes"];
virtualFullTIDPerDiagram = If[FileExistsQ[virtualTIDCachePath],
  Print["S05_STAGE: loading validated full-virtual TID cache"];
  Check[Get[virtualTIDCachePath], $Failed],
  cacheAnswer = MapIndexed[
    reduceFullVirtualAmplitude[#1, First[#2]] &,
    virtualFullPerDiagram
  ];
  If[FreeQ[cacheAnswer, $Failed] &&
      FreeQ[cacheAnswer, FeynCalc`TID] &&
      Length[cacheAnswer] === expectedCounts["Virtual"],
    Put[cacheAnswer, virtualTIDCachePath]
  ];
  cacheAnswer
];
assert[FreeQ[virtualFullTIDPerDiagram, $Failed],
  "At least one full virtual TID reduction failed."];
assert[ListQ[virtualFullTIDPerDiagram] &&
    Length[virtualFullTIDPerDiagram] === expectedCounts["Virtual"],
  "The full virtual TID collection has the wrong length."];
assert[FreeQ[virtualFullTIDPerDiagram, FeynCalc`TID],
  "At least one full virtual TID call remained unevaluated."];

qcdProjectionRules = s04["QCDProjection", "RulesApplied"];
countertermFullPerDiagramQCD =
  Expand[# /. qcdProjectionRules] & /@ countertermFullPerDiagramOriginal;
assert[FreeQ[countertermFullPerDiagramQCD, dZAA1 | dZe1 | dZZA1],
  "An electroweak counterterm survived the s04 QCD projection."];
assert[FreeQ[countertermFullPerDiagramQCD, _dMf1],
  "A quark-mass counterterm survived the massless-QCD projection."];

loFullSum = Total[loFullPerDiagram];
qggFullSum = Total[qggFullPerDiagram];
sameFullSum = Total[sameFullPerDiagram];
differentFullSum = Total[differentFullPerDiagram];
bareVirtualFullTIDSum = Total[virtualFullTIDPerDiagram];
countertermFullQCDSum = Total[countertermFullPerDiagramQCD];
renormalizedVirtualFullSumSymbolic =
  bareVirtualFullTIDSum + countertermFullQCDSum;

(*
  Contract converts gamma^rho epsilon_rho(q) to a slashed photon
  polarization. Replacing that unique object by gamma^mu opens only the
  photon index; all external spinors and final-state polarizations remain.
*)
openPhotonIndex[amp_, openIndex_Symbol, label_String] :=
 Module[{contracted, answer},
  contracted = FeynCalc`Contract[amp];
  assert[! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no incoming-photon polarization to open."];
  answer = contracted /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], dim_
      ]
    ] :> FeynCalc`DiracGamma[FeynCalc`LorentzIndex[openIndex, dim], dim];
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
  assert[FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains an incoming-photon polarization."];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the requested open photon index."];
  assert[! FreeQ[answer, _FeynCalc`Spinor],
    label <> " contains no external spinors after wavefunction restoration."];
  answer
];

Print["S05_STAGE: opening the photon Lorentz index"];
loMu = openPhotonIndex[loFullSum, s05Mu, "LO amplitude"];
qggMu = openPhotonIndex[qggFullSum, s05Mu, "real Hqq;gg amplitude"];
sameMu = openPhotonIndex[
  sameFullSum, s05Mu, "real same-flavor q qbar amplitude"
];
differentMu = openPhotonIndex[
  differentFullSum, s05Mu, "real different-flavor q' qbar' amplitude"
];
bareVirtualMu = openPhotonIndex[
  bareVirtualFullTIDSum, s05Mu, "bare virtual amplitude"
];
countertermMu = openPhotonIndex[
  countertermFullQCDSum, s05Mu, "QCD counterterm amplitude"
];
renormalizedVirtualMuSymbolic = bareVirtualMu + countertermMu;

qcdRealityRules = {
  HoldPattern[Conjugate[dZGG1]] -> dZGG1,
  HoldPattern[Conjugate[dZgs1]] -> dZgs1,
  HoldPattern[Conjugate[dZfL1[indices___]]] :> dZfL1[indices],
  HoldPattern[Conjugate[dZfR1[indices___]]] :> dZfR1[indices]
};

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
  answer = answer /. qcdRealityRules;
  assert[FreeQ[answer, FeynCalc`ComplexConjugate],
    label <> " left an unevaluated FeynCalc ComplexConjugate call."];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[newIndex, D]],
    label <> " conjugate does not contain the second photon index."];
  answer
];

Print["S05_STAGE: constructing conjugate amplitudes"];
loConjugateNu = conjugateOpenAmplitude[loMu, s05Mu, s05Nu, "LO"];
qggConjugateNu = conjugateOpenAmplitude[
  qggMu, s05Mu, s05Nu, "real Hqq;gg"
];
sameConjugateNu = conjugateOpenAmplitude[
  sameMu, s05Mu, s05Nu, "real same-flavor q qbar"
];
differentConjugateNu = conjugateOpenAmplitude[
  differentMu, s05Mu, s05Nu, "real different-flavor q' qbar'"
];
renormalizedVirtualConjugateNuSymbolic = conjugateOpenAmplitude[
  renormalizedVirtualMuSymbolic,
  s05Mu,
  s05Nu,
  "renormalized virtual"
];

Print["S05_STAGE: forming O(alpha_s) and O(alpha_s^2) bilinears"];

loSquareMuNu = loMu loConjugateNu;
qggSquareMuNu = qggMu qggConjugateNu;
sameSquareMuNu = sameMu sameConjugateNu;
differentSquareMuNu = differentMu differentConjugateNu;

virtualInterferenceMuNuSymbolic =
  loMu renormalizedVirtualConjugateNuSymbolic +
  renormalizedVirtualMuSymbolic loConjugateNu;

bilinears = <|
  "LOSquare_OAlphaS" -> loSquareMuNu,
  "NLORealSquares_OAlphaS2" -> <|
    "Hqq;gg" -> qggSquareMuNu,
    "Hqq;q_qbar_sameFlavor" -> sameSquareMuNu,
    "Hqq;qPrime_qbarPrime" -> differentSquareMuNu
  |>,
  "NLOVirtualInterference_OAlphaS2_Symbolic" ->
    virtualInterferenceMuNuSymbolic
|>;

allBilinearExpressions = {
  loSquareMuNu,
  qggSquareMuNu,
  sameSquareMuNu,
  differentSquareMuNu,
  virtualInterferenceMuNuSymbolic
};
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] & /@
      allBilinearExpressions),
  "At least one bilinear is missing photon index s05Mu."];
assert[And @@ (! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] & /@
      allBilinearExpressions),
  "At least one bilinear is missing photon index s05Nu."];
assert[And @@ (FreeQ[#, FeynCalc`Polarization[q, ___]] & /@
      allBilinearExpressions),
  "At least one bilinear still contains a photon polarization vector."];
assert[And @@ (! FreeQ[#, _FeynCalc`Spinor] & /@ allBilinearExpressions),
  "At least one bilinear is missing external spinors."];

s05Checks = <|
  "FullAmplitudeCountsMatchS01" -> True,
  "AllDiagramsCoherentlySummedBeforeProducts" -> True,
  "PhotonPolarizationRemoved" -> True,
  "PhotonIndexMuPresent" -> True,
  "PhotonIndexNuPresent" -> True,
  "ExternalSpinorsPresent" -> True,
  "FeynCalcConjugationEvaluated" -> True,
  "VirtualCountertermsIncluded" -> True,
  "VirtualSquareExcludedBeyondOAlphaS2" -> True,
  "SpinColorSumsNotYetApplied" -> True
|>;

s05Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> {s01Path, s04Path},
  "PhotonIndices" -> {s05Mu, s05Nu},
  "ExternalProcessOrganization" -> <|
    "LOAndVirtual" -> "gamma*(q) + q(p) -> q(k1) + g(k2)",
    "NLOReal" -> {
      "gamma*(q) + q(p) -> q(k1) + g(k2) + g(k3)",
      "gamma*(q) + q(p) -> q(k1) + q(k2) + qbar(k3)",
      "gamma*(q) + q(p) -> q(k1) + q'(k2) + qbar'(k3)"
    }
  |>,
  "DiagramCounts" -> convertedCounts,
  "OpenPhotonIndexAmplitudeSums" -> <|
    "LO_Mu" -> loMu,
    "NLOReal_Mu" -> <|
      "Hqq;gg" -> qggMu,
      "Hqq;q_qbar_sameFlavor" -> sameMu,
      "Hqq;qPrime_qbarPrime" -> differentMu
    |>,
    "NLOVirtualBare_Mu" -> bareVirtualMu,
    "NLOVirtualCounterterm_Mu" -> countertermMu,
    "NLOVirtualRenormalized_Mu_Symbolic" ->
      renormalizedVirtualMuSymbolic
  |>,
  "Bilinears" -> bilinears,
  "PerturbativeSelection" -> <|
    "LOSquare" -> "O(alpha_s)",
    "RealSquares" -> "O(alpha_s^2)",
    "LOVirtualInterference" -> "O(alpha_s^2)",
    "VirtualSquare" -> "Excluded: begins beyond O(alpha_s^2)"
  |>,
  "VirtualRenormalizationStatus" ->
    s04["Interpretation", "RenormalizationSchemeStatus"],
  "Checks" -> s05Checks,
  "NotPerformedAtThisStage" -> {
    "final-state spin, color, and polarization sums",
    "initial-quark spin and color averages",
    "phase-space integration",
    "real-virtual infrared cancellation",
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
Print["S05_DIAGRAM_COUNTS=", InputForm[convertedCounts]];
Print["S05_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

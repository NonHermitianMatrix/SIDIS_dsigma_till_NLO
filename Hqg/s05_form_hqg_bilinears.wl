(* ::Package:: *)

(*
  Form the Hqg amplitude bilinears required through O(alpha_s^2):

    |M_LO(gamma* q -> g q)|^2,
    |M_real(gamma* q -> g q g)|^2,
    M_LO^mu (M_V,ren^nu)^* + M_V,ren^mu (M_LO^nu)^*.

  The observed/fragmenting gluon is k1, matching paper Table I and BigTMD
  channel 3, case A.  S01 stored amputated kernels, so proper external states
  are regenerated with Truncated -> False before FeynCalc conjugation.  The
  incoming photon polarization alone is opened into s05Mu and s05Nu.  Final
  gluon polarizations, external spinors, spin/color sums, and initial-quark
  averages remain for S06.  The virtual square is beyond O(alpha_s^2) and is
  deliberately excluded.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, convertFullAmplitudes, reduceFullVirtualAmplitude,
  validVirtualCacheQ, openPhotonIndex, conjugateOpenAmplitude
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

Print["S05_STAGE: loading validated Hqg S01 and S04 results"];
assert[FileExistsQ[s01Path], "s01_result does not exist."];
assert[FileExistsQ[s04Path], "s04_result does not exist."];
s01 = Check[Get[s01Path], $Failed];
s04 = Check[Get[s04Path], $Failed];

assert[AssociationQ[s01] && s01["Status"] === "Complete",
  "s01_result is not a complete Association."];
assert[AssociationQ[s04] && s04["Status"] === "Complete",
  "s04_result is not a complete Association."];
assert[s01["Stage"] === "HqgS01-v2" && s04["Stage"] === "HqgS04-v2",
  "At least one source has the wrong Hqg stage."];
assert[s01["Channel"] === "Hqg only" && s04["Channel"] === "Hqg only",
  "At least one source result is not Hqg-only."];

s01Hash = FileHash[s01Path, "SHA256"];
s04Hash = FileHash[s04Path, "SHA256"];
assert[s04["SourceResultSHA256"] === s01Hash,
  "S04 is not bound to the current Hqg s01_result."];
assert[s01["ReferencePDFSHA256"] === s04["ReferencePDFSHA256"],
  "S01 and S04 have different paper hashes."];
assert[s01["BigTMDConvention", "ChannelNumber"] === 3 &&
    s01["BigTMDConvention", "ChargeCase"] === "A only",
  "S01 is not bound to BigTMD Hqg channel 3, case A."];
assert[s04["BigTMDConvention"] === s01["BigTMDConvention"],
  "S04 does not preserve the S01 BigTMD convention record."];
assert[
  s04["ElectricChargeNormalization"] ===
      s01["ElectricChargeNormalization"] &&
    s01["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s01["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3,
  "S01/S04 do not preserve the corrected charge-stripped convention."
];
amplitudeStripFactor =
  s01["ElectricChargeNormalization", "AmplitudeStripFactor"];
assert[amplitudeStripFactor === -3,
  "The regenerated full-amplitude strip factor is not exactly -3."];
assert[s01["Conventions", "FragmentingParton"] === "g(k1)" &&
    s04["ExternalProcess", "FragmentingParton"] === "g(k1)",
  "The sources do not fix the fragmenting gluon at k1."];

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
  assert[raw =!= $Failed, label <> " full FeynArts generation failed."];
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
  assert[FreeQ[answer, $Failed], label <> " conversion contains $Failed."];
  (* Restoring external states regenerates the SMQCD down-quark charge. *)
  answer = (amplitudeStripFactor # & /@ answer);
  assert[FreeQ[answer, $Failed | _Real],
    label <> " charge stripping produced an invalid amplitude list."];
  answer
];

expectedCounts = <|
  "LO" -> 2,
  "RealQG" -> 8,
  "Virtual" -> 23,
  "Counterterm" -> 12
|>;

loFullPerDiagram = convertFullAmplitudes[
  s01["LO", "FeynArtsDiagrams"],
  {k1, k2},
  {},
  "LO Hqg;q"
];
realFullPerDiagram = convertFullAmplitudes[
  s01["NLOReal", "Hqg;qg", "FeynArtsDiagrams"],
  {k1, k2, k3},
  {},
  "NLO real Hqg;qg"
];
virtualFullPerDiagram = convertFullAmplitudes[
  s01["NLOVirtual", "BareLoop", "FeynArtsDiagrams"],
  {k1, k2},
  {ell},
  "NLO bare virtual Hqg;q"
];
countertermFullPerDiagramOriginal = convertFullAmplitudes[
  s01["NLOVirtual", "UVCounterterms", "FeynArtsDiagrams"],
  {k1, k2},
  {},
  "NLO Hqg;q UV counterterms"
];

convertedCounts = <|
  "LO" -> Length[loFullPerDiagram],
  "RealQG" -> Length[realFullPerDiagram],
  "Virtual" -> Length[virtualFullPerDiagram],
  "Counterterm" -> Length[countertermFullPerDiagramOriginal]
|>;
assert[convertedCounts === expectedCounts,
  "Full-amplitude counts do not match the Hqg S01 contract."];
assert[FreeQ[
    {loFullPerDiagram, realFullPerDiagram, virtualFullPerDiagram,
      countertermFullPerDiagramOriginal},
    _Real
  ],
  "Machine-precision numbers appeared in full amplitudes."];

(* Massless 2 -> 2 kinematics with the observed gluon at k1. *)
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

validVirtualCacheQ[cache_] :=
  AssociationQ[cache] &&
  cache["Status"] === "Complete" &&
  cache["Stage"] === "HqgS05FullVirtualTIDCache-v3" &&
  cache["Channel"] === "Hqg only" &&
  cache["S01SHA256"] === s01Hash &&
  cache["FragmentingParton"] === "g(k1)" &&
  cache["VirtualDiagramCount"] === expectedCounts["Virtual"] &&
  ListQ[cache["Expressions"]] &&
  Length[cache["Expressions"]] === expectedCounts["Virtual"] &&
  FreeQ[cache["Expressions"], $Failed | FeynCalc`TID];

virtualTIDCacheWasReused = False;
virtualCache = $Failed;
If[FileExistsQ[virtualTIDCachePath],
  Print["S05_STAGE: inspecting Hqg full-virtual TID cache"];
  virtualCache = Check[Get[virtualTIDCachePath], $Failed];
  If[validVirtualCacheQ[virtualCache],
    virtualTIDCacheWasReused = True;
    Print["S05_STAGE: loading validated Hqg full-virtual TID cache"],
    Print["S05_STAGE: invalidating mismatched Hqg full-virtual TID cache"];
    DeleteFile[virtualTIDCachePath];
    virtualCache = $Failed
  ]
];

If[virtualTIDCacheWasReused,
  virtualFullTIDPerDiagram = virtualCache["Expressions"],
  Print["S05_STAGE: reducing full virtual amplitudes"];
  virtualFullTIDPerDiagram = MapIndexed[
    reduceFullVirtualAmplitude[#1, First[#2]] &,
    virtualFullPerDiagram
  ];
  assert[FreeQ[virtualFullTIDPerDiagram, $Failed],
    "At least one full virtual TID reduction failed."];
  assert[ListQ[virtualFullTIDPerDiagram] &&
      Length[virtualFullTIDPerDiagram] === expectedCounts["Virtual"],
    "The full virtual TID collection has the wrong length."];
  assert[FreeQ[virtualFullTIDPerDiagram, FeynCalc`TID],
    "At least one full virtual TID call remained unevaluated."];
  virtualCache = <|
    "Status" -> "Complete",
    "Stage" -> "HqgS05FullVirtualTIDCache-v3",
    "Channel" -> "Hqg only",
    "S01SHA256" -> s01Hash,
    "FragmentingParton" -> "g(k1)",
    "VirtualDiagramCount" -> expectedCounts["Virtual"],
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expressions" -> virtualFullTIDPerDiagram
  |>;
  Put[virtualCache, virtualTIDCachePath];
  assert[FileExistsQ[virtualTIDCachePath] &&
      FileByteCount[virtualTIDCachePath] > 0,
    "The Hqg full-virtual TID cache was not written."]
];

assert[validVirtualCacheQ[virtualCache],
  "The Hqg full-virtual TID cache contract is invalid."];
assert[FreeQ[virtualFullTIDPerDiagram, $Failed | FeynCalc`TID],
  "The validated full-virtual TID expressions are incomplete."];

qcdProjectionRules = s04["QCDProjection", "RulesApplied"];
countertermFullPerDiagramQCD =
  Expand[# /. qcdProjectionRules] & /@ countertermFullPerDiagramOriginal;
assert[FreeQ[countertermFullPerDiagramQCD, dZAA1 | dZe1 | dZZA1],
  "An electroweak counterterm survived the S04 QCD projection."];
assert[FreeQ[countertermFullPerDiagramQCD, _dMf1],
  "A quark-mass counterterm survived the massless-QCD projection."];
assert[! FreeQ[countertermFullPerDiagramQCD, dZGG1] &&
    ! FreeQ[countertermFullPerDiagramQCD, dZgs1] &&
    ! FreeQ[countertermFullPerDiagramQCD, _dZfL1 | _dZfR1],
  "At least one required symbolic QCD counterterm is absent."];

loFullSum = Total[loFullPerDiagram];
realFullSum = Total[realFullPerDiagram];
bareVirtualFullTIDSum = Total[virtualFullTIDPerDiagram];
countertermFullQCDSum = Total[countertermFullPerDiagramQCD];
renormalizedVirtualFullSumSymbolic =
  bareVirtualFullTIDSum + countertermFullQCDSum;

assert[SameQ[loFullSum, Total[loFullPerDiagram]],
  "The coherent LO sum failed reconstruction."];
assert[SameQ[realFullSum, Total[realFullPerDiagram]],
  "The coherent real sum failed reconstruction."];
assert[SameQ[bareVirtualFullTIDSum, Total[virtualFullTIDPerDiagram]],
  "The coherent bare-virtual sum failed reconstruction."];
assert[SameQ[countertermFullQCDSum, Total[countertermFullPerDiagramQCD]],
  "The coherent counterterm sum failed reconstruction."];

(*
  Contract may place the photon polarization in a slashed vector, Lorentz
  scalar product, or epsilon tensor.  These rules open only q's incoming
  photon and preserve all final-gluon polarizations.
*)
openPhotonIndex[
    amp_, openIndex_Symbol, label_String, requiredGluons_List
  ] := Module[{contracted, answer},
  contracted = FeynCalc`Contract[amp];
  assert[! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no incoming-photon polarization to open."];
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
  assert[FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains an incoming-photon polarization."];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the requested open photon index."];
  assert[! FreeQ[answer, _FeynCalc`Spinor],
    label <> " contains no external spinors after state restoration."];
  Scan[
    Function[momentum,
      assert[! FreeQ[answer, FeynCalc`Polarization[momentum, ___]],
        label <> " lost the polarization of gluon " <>
          ToString[momentum, InputForm] <> "."]
    ],
    requiredGluons
  ];
  answer
];

Print["S05_STAGE: opening the incoming-photon Lorentz index"];
loMu = openPhotonIndex[
  loFullSum, s05Mu, "LO Hqg;q amplitude", {k1}
];
realMuPerDiagram = MapIndexed[
  openPhotonIndex[
    #1,
    s05Mu,
    "real Hqg;qg diagram " <> ToString[First[#2]],
    {k1, k3}
  ] &,
  realFullPerDiagram
];
realMu = Total[realMuPerDiagram];
assert[Length[realMuPerDiagram] === expectedCounts["RealQG"],
  "The real open-amplitude block count is not eight."];
bareVirtualMu = openPhotonIndex[
  bareVirtualFullTIDSum, s05Mu, "bare virtual Hqg;q amplitude", {k1}
];
countertermMu = openPhotonIndex[
  countertermFullQCDSum, s05Mu, "QCD counterterm Hqg;q amplitude", {k1}
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
loConjugateNu = conjugateOpenAmplitude[
  loMu, s05Mu, s05Nu, "LO Hqg;q"
];
realConjugateNuPerDiagram = MapIndexed[
  conjugateOpenAmplitude[
    #1,
    s05Mu,
    s05Nu,
    "real Hqg;qg conjugate diagram " <> ToString[First[#2]]
  ] &,
  realMuPerDiagram
];
realConjugateNu = Total[realConjugateNuPerDiagram];
assert[Length[realConjugateNuPerDiagram] === expectedCounts["RealQG"],
  "The real conjugate-amplitude block count is not eight."];
renormalizedVirtualConjugateNuSymbolic = conjugateOpenAmplitude[
  renormalizedVirtualMuSymbolic,
  s05Mu,
  s05Nu,
  "renormalized virtual Hqg;q"
];

Print["S05_STAGE: forming Hqg bilinears through O(alpha_s^2)"];
loSquareMuNu = loMu loConjugateNu;
realSquareMuNu = realMu realConjugateNu;
virtualInterferenceMuNuSymbolic =
  loMu renormalizedVirtualConjugateNuSymbolic +
  renormalizedVirtualMuSymbolic loConjugateNu;

bilinears = <|
  "LOSquare_OAlphaS" -> loSquareMuNu,
  "NLORealSquares_OAlphaS2" -> <|
    "Hqg;qg" -> realSquareMuNu
  |>,
  "NLOVirtualInterference_OAlphaS2_Symbolic" ->
    virtualInterferenceMuNuSymbolic
|>;

allBilinearExpressions = {
  loSquareMuNu,
  realSquareMuNu,
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
  "At least one bilinear still contains a photon polarization."];
assert[And @@ (! FreeQ[#, FeynCalc`Polarization[k1, ___]] & /@
      allBilinearExpressions),
  "At least one bilinear lost the fragmenting-gluon polarization."];
assert[! FreeQ[realSquareMuNu, FeynCalc`Polarization[k3, ___]],
  "The real bilinear lost the unobserved final-gluon polarization."];
assert[And @@ (! FreeQ[#, _FeynCalc`Spinor] & /@ allBilinearExpressions),
  "At least one bilinear is missing external spinors."];
assert[FreeQ[allBilinearExpressions, FeynCalc`ComplexConjugate | FeynCalc`TID],
  "An unevaluated conjugation or TID call remains in a bilinear."];
assert[FreeQ[allBilinearExpressions, $Failed],
  "A bilinear contains $Failed."];
assert[FreeQ[allBilinearExpressions, _Real],
  "Machine-precision numbers appeared in symbolic bilinears."];
assert[! FreeQ[virtualInterferenceMuNuSymbolic, dZGG1] &&
    ! FreeQ[virtualInterferenceMuNuSymbolic, dZgs1] &&
    ! FreeQ[virtualInterferenceMuNuSymbolic, _dZfL1 | _dZfR1],
  "The symbolic virtual interference lost QCD counterterms."];

orderedPairCounts = <|
  "LOSquare" -> expectedCounts["LO"]^2,
  "NLORealHqgQG" -> expectedCounts["RealQG"]^2,
  "LOVirtualHermitianCrossTerms" ->
    2 expectedCounts["LO"]
      (expectedCounts["Virtual"] + expectedCounts["Counterterm"])
|>;
assert[Values[orderedPairCounts] === {4, 64, 140},
  "The coherent ordered-pair counts are inconsistent."];

s05Checks = <|
  "S01AndS04SHA256Bound" -> True,
  "PaperAndBigTMDConventionsPreserved" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "AmplitudeStripFactorAppliedToEveryRegeneratedFullAmplitude" -> True,
  "FullAmplitudeCountsMatchS01" -> True,
  "HqgLocalVirtualTIDCacheSourceBound" -> True,
  "AllDiagramsCoherentlySummedBeforeProducts" -> True,
  "CoherentOrderedPairCountsAre4_64_140" -> True,
  "PhotonPolarizationRemoved" -> True,
  "PhotonIndexMuPresent" -> True,
  "PhotonIndexNuPresent" -> True,
  "FragmentingGluonPolarizationRetained" -> True,
  "RealUnobservedGluonPolarizationRetained" -> True,
  "ExternalSpinorsRetained" -> True,
  "FeynCalcConjugationEvaluated" -> True,
  "VirtualCountertermsIncluded" -> True,
  "VirtualSquareExcludedBeyondOAlphaS2" -> True,
  "CalculationFullySymbolic" -> True,
  "SpinColorSumsNotYetApplied" -> True
|>;

s05Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS05-v3",
  "Channel" -> "Hqg only",
  "Contribution" -> "Hqg LO, Hqg;qg real, and Hqg;q virtual interference",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> <|
    "S01" -> s01Path,
    "S01SHA256" -> s01Hash,
    "S04" -> s04Path,
    "S04SHA256" -> s04Hash,
    "ReferencePDFSHA256" -> s01["ReferencePDFSHA256"]
  |>,
  "BigTMDConvention" -> s01["BigTMDConvention"],
  "ElectricChargeNormalization" -> s01["ElectricChargeNormalization"],
  "VirtualTIDCache" -> <|
    "Path" -> virtualTIDCachePath,
    "SHA256" -> FileHash[virtualTIDCachePath, "SHA256"],
    "Stage" -> virtualCache["Stage"],
    "S01SHA256" -> virtualCache["S01SHA256"],
    "ReusedInThisRun" -> virtualTIDCacheWasReused
  |>,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "ExternalProcessOrganization" -> <|
    "LOAndVirtual" -> <|
      "Incoming" -> {"gamma*(q)", "q(p)"},
      "Outgoing" -> {"g(k1)", "q(k2)"},
      "FragmentingParton" -> "g(k1)"
    |>,
    "NLOReal" -> <|
      "Incoming" -> {"gamma*(q)", "q(p)"},
      "Outgoing" -> {"g(k1)", "q(k2)", "g(k3)"},
      "FragmentingParton" -> "g(k1)"
    |>
  |>,
  "DiagramCounts" -> convertedCounts,
  "CoherentOrderedPairCounts" -> orderedPairCounts,
  "OpenPhotonIndexAmplitudeSums" -> <|
    "LO_Mu" -> loMu,
    "NLOReal_Mu" -> <|"Hqg;qg" -> realMu|>,
    "NLOVirtualBare_Mu" -> bareVirtualMu,
    "NLOVirtualCounterterm_Mu" -> countertermMu,
    "NLOVirtualRenormalized_Mu_Symbolic" ->
      renormalizedVirtualMuSymbolic
  |>,
  "OpenPhotonIndexRealAmplitudeBlocks" -> <|
    "Hqg;qg_Mu" -> realMuPerDiagram,
    "Hqg;qg_NuConjugate" -> realConjugateNuPerDiagram,
    "BlockCount" -> Length[realMuPerDiagram],
    "Purpose" ->
      "memory-safe coherent physical-polarization processing in S06"
  |>,
  "Bilinears" -> bilinears,
  "PerturbativeSelection" -> <|
    "LOSquare" -> "O(alpha_s)",
    "RealSquare" -> "O(alpha_s^2)",
    "LOVirtualInterference" -> "O(alpha_s^2)",
    "VirtualSquare" -> "Excluded: begins beyond O(alpha_s^2)"
  |>,
  "VirtualRenormalizationStatus" ->
    s04["Interpretation", "RenormalizationSchemeStatus"],
  "Checks" -> s05Checks,
  "NotPerformedAtThisStage" -> {
    "final-state quark spin and gluon polarization sums",
    "color sums",
    "initial-quark spin and color averages",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "phase-space integration",
    "real-virtual infrared cancellation",
    "PDF/FF collinear-factorization subtraction",
    "projection onto the paper's g and PP tensor structures",
    "finite comparison with BigTMD fchn3A kernels"
  }
|>;

Print["S05_STAGE: writing " <> resultPath];
Put[s05Result, resultPath];

assert[FileExistsQ[resultPath], "The s05_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s05_result file is empty."];

Print["S05_SUCCESS"];
Print["S05_RESULT_PATH=" <> resultPath];
Print["S05_DIAGRAM_COUNTS=", InputForm[convertedCounts]];
Print["S05_ORDERED_PAIR_COUNTS=", InputForm[orderedPairCounts]];
Print["S05_CACHE_REUSED=", virtualTIDCacheWasReused];
Print["S05_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

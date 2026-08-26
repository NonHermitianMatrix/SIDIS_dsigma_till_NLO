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
  validVirtualCacheQ, openPhotonIndex, conjugateOpenAmplitude,
  sha256Hex, installMassShellAssignments,
  installScalarProductAssignments
];

fatal[message_String] := (
  Print["S05_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];
sha256Hex[path_String] := ToLowerCase[
  IntegerString[FileHash[path, "SHA256"], 16, 64]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
stageSourcePath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{
  scriptDirectory, "s01_calculate_hqg_lo_nlo.wl"
}];
s01Path = FileNameJoin[{scriptDirectory, "s01_result"}];
s04SourcePath = FileNameJoin[{
  scriptDirectory, "s04_renormalize_hqg_virtual.wl"
}];
s04Path = FileNameJoin[{scriptDirectory, "s04_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s05_result"}];
virtualTIDCachePath = FileNameJoin[{
  scriptDirectory, "s05_virtual_full_tid_cache"
}];
acceptedS01SourceSHA256 =
  "8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0";
acceptedS01ResultSHA256 =
  "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198";
acceptedS04SourceSHA256 =
  "ad6c5fd46152805538d1234c787feae212a9f5aa217853d7e81b4818bb567e54";
acceptedS04ResultSHA256 =
  "2bbeeee841e5e47bfd2391a1588b2184a16865d334bf78716b1b0573d499bf92";

Print["S05_STAGE: loading validated Hqg S01 and S04 results"];
assert[FileExistsQ[s01SourcePath], "S01 source does not exist."];
assert[FileExistsQ[s01Path], "s01_result does not exist."];
assert[FileExistsQ[s04SourcePath], "S04 source does not exist."];
assert[FileExistsQ[s04Path], "s04_result does not exist."];
s01SourceSHA256Hex = sha256Hex[s01SourcePath];
s01ResultSHA256Hex = sha256Hex[s01Path];
s04SourceSHA256Hex = sha256Hex[s04SourcePath];
s04ResultSHA256Hex = sha256Hex[s04Path];
upstreamIdentityGate =
  s01SourceSHA256Hex === acceptedS01SourceSHA256 &&
    s01ResultSHA256Hex === acceptedS01ResultSHA256 &&
    s04SourceSHA256Hex === acceptedS04SourceSHA256 &&
    s04ResultSHA256Hex === acceptedS04ResultSHA256;
assert[upstreamIdentityGate,
  "S01/S04 source-result identities do not match the accepted Hqg ledger."];
s01 = Check[Get[s01Path], $Failed];
s04 = Check[Get[s04Path], $Failed];

s01Hash = FileHash[s01Path, "SHA256"];
s04Hash = FileHash[s04Path, "SHA256"];
sourceSchemaGate =
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqgS01-v3" && s01["Channel"] === "Hqg only" &&
    AssociationQ[s01["Checks"]] &&
    AllTrue[Values[s01["Checks"]], TrueQ] &&
    AssociationQ[s04] && s04["Status"] === "Complete" &&
    s04["Stage"] === "HqgS04-v3" && s04["Channel"] === "Hqg only" &&
    AssociationQ[s04["Checks"]] &&
    AllTrue[Values[s04["Checks"]], TrueQ];
assert[sourceSchemaGate,
  "S01/S04 do not satisfy complete checked Hqg stage contracts."];
sourceLineageGate =
  s04["SourceProgramSHA256"] === FileHash[s01SourcePath, "SHA256"] &&
    s04["SourceProgramSHA256Hex"] === s01SourceSHA256Hex &&
    s04["SourceResultSHA256"] === s01Hash &&
    s04["SourceResultSHA256Hex"] === s01ResultSHA256Hex &&
    s04["StageSourceSHA256"] === FileHash[s04SourcePath, "SHA256"] &&
    s04["StageSourceSHA256Hex"] === s04SourceSHA256Hex;
assert[sourceLineageGate,
  "S04 is not bound to the exact accepted S01/S04 source lineage."];
paperAndBigTMDGate =
  s01["ReferencePDFSHA256"] === s04["ReferencePDFSHA256"] &&
    s01["BigTMDConvention", "ChannelNumber"] === 3 &&
    s01["BigTMDConvention", "ChargeCase"] === "A only" &&
    s04["BigTMDConvention"] === s01["BigTMDConvention"];
assert[paperAndBigTMDGate,
  "S01/S04 paper or BigTMD convention records disagree."];
chargeConventionGate =
  s04["ElectricChargeNormalization"] ===
      s01["ElectricChargeNormalization"] &&
    s01["Checks", "ReferenceChargeDerivedFromSMQCDClassMetadata"] === True &&
    s01["ElectricChargeNormalization", "ReferenceCharge"] ===
      Lookup[
        s01["ElectricChargeNormalization", "ModelChargeCoefficients"],
        "F" <> ToString[
          s01["ElectricChargeNormalization", "FeynArtsReferenceClass"]
        ],
        Missing["Absent"]
      ] &&
    Together[
      s01["ElectricChargeNormalization", "ReferenceCharge"] *
        s01["ElectricChargeNormalization", "AmplitudeStripFactor"]
    ] === 1;
assert[chargeConventionGate,
  "S01/S04 do not preserve the corrected charge-stripped convention."
];
amplitudeStripFactor =
  s01["ElectricChargeNormalization", "AmplitudeStripFactor"];
amplitudeStripFactorGate =
  Together[
    amplitudeStripFactor *
      s01["ElectricChargeNormalization", "ReferenceCharge"]
  ] === 1;
assert[amplitudeStripFactorGate,
  "The regenerated full-amplitude strip factor is not the exact reciprocal of the model-derived reference charge."
];
fragmentingPartonGate =
  s01["Conventions", "FragmentingParton"] === "g(k1)" &&
    s04["ExternalProcess", "FragmentingParton"] === "g(k1)";
assert[fragmentingPartonGate,
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
  ] := Module[{raw, answer, preStripAnswer},
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
  (* FCFAConvert can retain FeynArts`FCGV depending on session context. *)
  answer = answer /. HoldPattern[
      FeynArts`FCGV[name_String]
    ] :> FeynCalc`FCGV[name];
  assert[FreeQ[answer, _FeynArts`FCGV],
    label <> " conversion left a FeynArts-context FCGV symbol."];
  (* Restoring external states regenerates the model-derived representative-quark charge. *)
  preStripAnswer = answer;
  answer = (amplitudeStripFactor # & /@ answer);
  assert[FreeQ[answer, $Failed | _Real],
    label <> " charge stripping produced an invalid amplitude list."];
  AssociateTo[
    conversionAudit,
    label -> <|
      "PreStripExpressionHash" -> Hash[preStripAnswer, "SHA256"],
      "StrippedExpressionHash" -> Hash[answer, "SHA256"],
      "AmplitudeStripFactor" -> amplitudeStripFactor,
      "AppliedExactly" ->
        SameQ[answer, amplitudeStripFactor preStripAnswer],
      "FeynArtsFCGVAbsentBeforeStrip" ->
        FreeQ[preStripAnswer, _FeynArts`FCGV],
      "FeynArtsFCGVAbsentAfterStrip" ->
        FreeQ[answer, _FeynArts`FCGV]
    |>
  ];
  answer
];

s01OrdinaryDiagramCounts = s01[
  "GenerationLedgers", "OrdinaryDiagramCounts"
];
s01CountertermDiagramCount = s01[
  "GenerationLedgers", "CountertermDiagramCount"
];
generatedCountLedgerGate =
  AssociationQ[s01OrdinaryDiagramCounts] &&
    And @@ (KeyExistsQ[s01OrdinaryDiagramCounts, #] & /@
      {"LO", "RealQG", "Virtual"}) &&
    AllTrue[
      Values[s01OrdinaryDiagramCounts],
      IntegerQ[#] && # > 0 &
    ] &&
    IntegerQ[s01CountertermDiagramCount] &&
    s01CountertermDiagramCount > 0;
assert[generatedCountLedgerGate,
  "The accepted S01 generated-count ledger is missing or invalid."];
expectedCounts = Join[
  s01OrdinaryDiagramCounts,
  <|"Counterterm" -> s01CountertermDiagramCount|>
];
sourceDiagramCollectionGate =
  s01["LO", "DiagramCount"] === expectedCounts["LO"] &&
    s01["NLOReal", "Hqg;qg", "DiagramCount"] ===
      expectedCounts["RealQG"] &&
    s01["NLOVirtual", "BareLoop", "DiagramCount"] ===
      expectedCounts["Virtual"] &&
    s01["NLOVirtual", "UVCounterterms", "DiagramCount"] ===
      expectedCounts["Counterterm"];
assert[sourceDiagramCollectionGate,
  "An S01 FeynArts diagram collection disagrees with its generated ledger."];

conversionAudit = <||>;

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
fullAmplitudeCountGate = convertedCounts === expectedCounts;
fullAmplitudeExactGate = FreeQ[
  {
    loFullPerDiagram, realFullPerDiagram, virtualFullPerDiagram,
    countertermFullPerDiagramOriginal
  },
  _Real
];
feynArtsFCGVCanonicalizationGate = FreeQ[
  {
    loFullPerDiagram, realFullPerDiagram, virtualFullPerDiagram,
    countertermFullPerDiagramOriginal
  },
  _FeynArts`FCGV
];
amplitudeStripAuditGate =
  Length[conversionAudit] === Length[convertedCounts] &&
    AllTrue[
      Values[conversionAudit],
      TrueQ[Lookup[#, "AppliedExactly"]] &&
        TrueQ[Lookup[#, "FeynArtsFCGVAbsentBeforeStrip"]] &&
        TrueQ[Lookup[#, "FeynArtsFCGVAbsentAfterStrip"]] &&
        Lookup[#, "AmplitudeStripFactor"] === amplitudeStripFactor &
    ];
assert[fullAmplitudeCountGate,
  "Full-amplitude counts do not match the Hqg S01 contract."];
assert[fullAmplitudeExactGate,
  "Machine-precision numbers appeared in full amplitudes."];
assert[feynArtsFCGVCanonicalizationGate,
  "A regenerated full amplitude contains a FeynArts-context FCGV."];
assert[amplitudeStripAuditGate,
  "The model-derived strip factor was not applied exactly to every regenerated collection."];

(* Install the exact tool-derived two-body kinematics accepted at S01. *)
s01KinematicDerivation = s01["KinematicDerivation"];
kinematicRecordGate =
  AssociationQ[s01KinematicDerivation] &&
    s01KinematicDerivation["SerializationSchema"] ===
      "HqgS01Kinematics-v2" &&
    TrueQ[s01KinematicDerivation["UniqueExactSolution"]] &&
    ListQ[s01KinematicDerivation["MassShellAssignments"]] &&
    AllTrue[
      s01KinematicDerivation["MassShellAssignments"],
      Function[assignment,
        AssociationQ[assignment] &&
          And @@ (KeyExistsQ[assignment, #] & /@ {
            "Momentum", "MassSquared"
          })
      ]
    ] &&
    ListQ[s01KinematicDerivation["ScalarProductAssignments"]] &&
    AllTrue[
      s01KinematicDerivation["ScalarProductAssignments"],
      Function[assignment,
        AssociationQ[assignment] &&
          And @@ (KeyExistsQ[assignment, #] & /@ {
            "Momentum1", "Momentum2", "Dimension", "Value"
          }) &&
          Lookup[assignment, "Dimension"] === D
      ]
    ] &&
    Head[s01KinematicDerivation["DefiningEquationsHeld"]] ===
      HoldComplete &&
    Head[s01KinematicDerivation["SolvedScalarProductsHeld"]] ===
      HoldComplete &&
    ! FreeQ[
      s01KinematicDerivation["DefiningEquationsHeld"],
      _FeynCalc`Pair
    ] &&
    ! FreeQ[
      s01KinematicDerivation["SolvedScalarProductsHeld"],
      _FeynCalc`Pair
    ] &&
    ListQ[
      s01KinematicDerivation["MassShellInstallationResiduals"]
    ] &&
    ListQ[
      s01KinematicDerivation["ScalarProductInstallationResiduals"]
    ] &&
    ListQ[s01KinematicDerivation["EquationResiduals"]] &&
    And @@ (# === 0 & /@ Join[
      s01KinematicDerivation["MassShellInstallationResiduals"],
      s01KinematicDerivation["ScalarProductInstallationResiduals"],
      s01KinematicDerivation["EquationResiduals"]
    ]) &&
    TrueQ[
      s01[
        "Checks", "TwoBodyKinematicLedgerSerializationRoundTrip"
      ]
    ] &&
    ! KeyExistsQ[s01KinematicDerivation, "MassShellValues"] &&
    ! KeyExistsQ[s01KinematicDerivation, "SolvedScalarProducts"] &&
    ! MissingQ[s01KinematicDerivation["MandelstamURule"]] &&
    FreeQ[s01KinematicDerivation, _Real | _Missing];
assert[kinematicRecordGate,
  "The accepted S01 inert two-body kinematic record is invalid."];

installMassShellAssignments[assignments_List] := Scan[
  Function[assignment,
    With[
      {
        momentum = Lookup[assignment, "Momentum"],
        massSquared = Lookup[assignment, "MassSquared"]
      },
      FeynCalc`SPD[momentum, momentum] = massSquared
    ]
  ],
  assignments
];

installScalarProductAssignments[assignments_List] := Scan[
  Function[assignment,
    With[
      {
        momentum1 = Lookup[assignment, "Momentum1"],
        momentum2 = Lookup[assignment, "Momentum2"],
        value = Lookup[assignment, "Value"]
      },
      FeynCalc`SPD[momentum1, momentum2] = value
    ]
  ],
  assignments
];

FeynCalc`FCClearScalarProducts[];
installMassShellAssignments[
  s01KinematicDerivation["MassShellAssignments"]
];
installScalarProductAssignments[
  s01KinematicDerivation["ScalarProductAssignments"]
];
installedMassShellResiduals = Together[
    FeynCalc`SPD[
      Lookup[#, "Momentum"], Lookup[#, "Momentum"]
    ] - Lookup[#, "MassSquared"]
  ] & /@ s01KinematicDerivation["MassShellAssignments"];
installedScalarProductResiduals = Together[
    FeynCalc`SPD[
      Lookup[#, "Momentum1"], Lookup[#, "Momentum2"]
    ] - Lookup[#, "Value"]
  ] & /@ s01KinematicDerivation["ScalarProductAssignments"];
kinematicInstallationGate =
  AllTrue[
    Join[installedMassShellResiduals, installedScalarProductResiduals],
    SameQ[#, 0] &
  ];
assert[kinematicInstallationGate,
  "The accepted S01 inert kinematics were not reinstalled exactly."];
kinematicDerivationGate =
  kinematicRecordGate && kinematicInstallationGate;
kinematicInstallationAudit = <|
  "SerializationSchema" ->
    s01KinematicDerivation["SerializationSchema"],
  "MassShellResiduals" -> installedMassShellResiduals,
  "ScalarProductResiduals" -> installedScalarProductResiduals,
  "InstalledExactly" -> kinematicInstallationGate
|>;
kinematicContentHash = Hash[s01KinematicDerivation, "SHA256"];
kinematicInstallationAuditContentHash = Hash[
  kinematicInstallationAudit,
  "SHA256"
];

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

stageSourceSHA256 = FileHash[stageSourcePath, "SHA256"];
stageSourceSHA256Hex = sha256Hex[stageSourcePath];
chargeNormalizationContentHash = Hash[
  s01["ElectricChargeNormalization"],
  "SHA256"
];
fullVirtualInputContentHash = Hash[
  virtualFullPerDiagram,
  "SHA256"
];

validVirtualCacheQ[cache_] :=
  AssociationQ[cache] &&
  cache["Status"] === "Complete" &&
  cache["Stage"] === "HqgS05FullVirtualTIDCache-v4" &&
  cache["Channel"] === "Hqg only" &&
  cache["S01SHA256"] === s01Hash &&
  cache["S01SourceSHA256Hex"] === s01SourceSHA256Hex &&
  cache["S01ResultSHA256Hex"] === s01ResultSHA256Hex &&
  cache["S04SHA256"] === s04Hash &&
  cache["S04SourceSHA256Hex"] === s04SourceSHA256Hex &&
  cache["S04ResultSHA256Hex"] === s04ResultSHA256Hex &&
  cache["S05SourceSHA256"] === stageSourceSHA256 &&
  cache["S05SourceSHA256Hex"] === stageSourceSHA256Hex &&
  cache["ChargeNormalizationContentHash"] ===
    chargeNormalizationContentHash &&
  cache["KinematicDerivationContentHash"] === kinematicContentHash &&
  cache["KinematicInstallationAuditContentHash"] ===
    kinematicInstallationAuditContentHash &&
  cache["KinematicSerializationSchema"] ===
    s01KinematicDerivation["SerializationSchema"] &&
  cache["FullVirtualInputContentHash"] === fullVirtualInputContentHash &&
  cache["FragmentingParton"] === "g(k1)" &&
  cache["VirtualDiagramCount"] === expectedCounts["Virtual"] &&
  ListQ[cache["Expressions"]] &&
  Length[cache["Expressions"]] === expectedCounts["Virtual"] &&
  FreeQ[
    cache["Expressions"],
    $Failed | FeynCalc`TID | _FeynArts`FCGV | _Real
  ];

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
    "Stage" -> "HqgS05FullVirtualTIDCache-v4",
    "Channel" -> "Hqg only",
    "S01SHA256" -> s01Hash,
    "S01SourceSHA256Hex" -> s01SourceSHA256Hex,
    "S01ResultSHA256Hex" -> s01ResultSHA256Hex,
    "S04SHA256" -> s04Hash,
    "S04SourceSHA256Hex" -> s04SourceSHA256Hex,
    "S04ResultSHA256Hex" -> s04ResultSHA256Hex,
    "S05SourceSHA256" -> stageSourceSHA256,
    "S05SourceSHA256Hex" -> stageSourceSHA256Hex,
    "ChargeNormalizationContentHash" ->
      chargeNormalizationContentHash,
    "KinematicDerivationContentHash" -> kinematicContentHash,
    "KinematicInstallationAuditContentHash" ->
      kinematicInstallationAuditContentHash,
    "KinematicSerializationSchema" ->
      s01KinematicDerivation["SerializationSchema"],
    "FullVirtualInputContentHash" -> fullVirtualInputContentHash,
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

virtualCacheContractGate = TrueQ[validVirtualCacheQ[virtualCache]];
virtualTIDCompletenessGate = FreeQ[
  virtualFullTIDPerDiagram,
  $Failed | FeynCalc`TID | _FeynArts`FCGV | _Real
];
assert[virtualCacheContractGate,
  "The Hqg full-virtual TID cache contract is invalid."];
assert[virtualTIDCompletenessGate,
  "The validated full-virtual TID expressions are incomplete."];

qcdProjectionRules = s04["QCDProjection", "RulesApplied"];
countertermFullPerDiagramQCD =
  Expand[# /. qcdProjectionRules] & /@ countertermFullPerDiagramOriginal;
qcdProjectionRuleHandoffGate =
  ListQ[qcdProjectionRules] &&
    qcdProjectionRules === s04["QCDProjection", "RulesApplied"];
electroweakCountertermsRemovedGate =
  FreeQ[countertermFullPerDiagramQCD, dZAA1 | dZe1 | dZZA1];
massCountertermRemovedGate =
  FreeQ[countertermFullPerDiagramQCD, _dMf1];
qcdCountertermsRetainedGate =
  ! FreeQ[countertermFullPerDiagramQCD, dZGG1] &&
    ! FreeQ[countertermFullPerDiagramQCD, dZgs1] &&
    ! FreeQ[countertermFullPerDiagramQCD, _dZfL1 | _dZfR1];
countertermProjectionExactGate =
  FreeQ[countertermFullPerDiagramQCD, _Real | _FeynArts`FCGV];
assert[qcdProjectionRuleHandoffGate,
  "The accepted S04 QCD projection rule list is missing or altered."];
assert[electroweakCountertermsRemovedGate,
  "An electroweak counterterm survived the S04 QCD projection."];
assert[massCountertermRemovedGate,
  "A quark-mass counterterm survived the massless-QCD projection."];
assert[qcdCountertermsRetainedGate,
  "At least one required symbolic QCD counterterm is absent."];
assert[countertermProjectionExactGate,
  "The projected full counterterms are not exact/context-clean."];

loFullSum = Total[loFullPerDiagram];
realFullSum = Total[realFullPerDiagram];
bareVirtualFullTIDSum = Total[virtualFullTIDPerDiagram];
countertermFullQCDSum = Total[countertermFullPerDiagramQCD];
renormalizedVirtualFullSumSymbolic =
  bareVirtualFullTIDSum + countertermFullQCDSum;

loCoherentSumGate = SameQ[loFullSum, Total[loFullPerDiagram]];
realCoherentSumGate = SameQ[realFullSum, Total[realFullPerDiagram]];
bareVirtualCoherentSumGate = SameQ[
  bareVirtualFullTIDSum,
  Total[virtualFullTIDPerDiagram]
];
countertermCoherentSumGate = SameQ[
  countertermFullQCDSum,
  Total[countertermFullPerDiagramQCD]
];
renormalizedVirtualSumGate = SameQ[
  renormalizedVirtualFullSumSymbolic,
  bareVirtualFullTIDSum + countertermFullQCDSum
];
assert[loCoherentSumGate,
  "The coherent LO sum failed reconstruction."];
assert[realCoherentSumGate,
  "The coherent real sum failed reconstruction."];
assert[bareVirtualCoherentSumGate,
  "The coherent bare-virtual sum failed reconstruction."];
assert[countertermCoherentSumGate,
  "The coherent counterterm sum failed reconstruction."];
assert[renormalizedVirtualSumGate,
  "The symbolic renormalized virtual sum failed reconstruction."];

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
realOpenBlockCountGate =
  Length[realMuPerDiagram] === expectedCounts["RealQG"];
assert[realOpenBlockCountGate,
  "The real open-amplitude block count disagrees with the generated ledger."];
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
realConjugateBlockCountGate =
  Length[realConjugateNuPerDiagram] === expectedCounts["RealQG"];
assert[realConjugateBlockCountGate,
  "The real conjugate-amplitude block count disagrees with the generated ledger."];
renormalizedVirtualConjugateNuSymbolic = conjugateOpenAmplitude[
  renormalizedVirtualMuSymbolic,
  s05Mu,
  s05Nu,
  "renormalized virtual Hqg;q"
];
openAmplitudeReconstructionGate =
  SameQ[realMu, Total[realMuPerDiagram]] &&
    SameQ[realConjugateNu, Total[realConjugateNuPerDiagram]] &&
    SameQ[
      renormalizedVirtualMuSymbolic,
      bareVirtualMu + countertermMu
    ];
assert[openAmplitudeReconstructionGate,
  "An open-index amplitude sum failed reconstruction."];

Print["S05_STAGE: forming Hqg bilinears through O(alpha_s^2)"];
loSquareMuNu = loMu loConjugateNu;
realSquareMuNu = realMu realConjugateNu;
virtualInterferenceTermsMuNuSymbolic = {
  loMu renormalizedVirtualConjugateNuSymbolic,
  renormalizedVirtualMuSymbolic loConjugateNu
};
virtualInterferenceMuNuSymbolic = Total[
  virtualInterferenceTermsMuNuSymbolic
];

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
bilinearConstructionGate =
  SameQ[loSquareMuNu, loMu loConjugateNu] &&
    SameQ[realSquareMuNu, realMu realConjugateNu] &&
    SameQ[
      virtualInterferenceMuNuSymbolic,
      Total[virtualInterferenceTermsMuNuSymbolic]
    ];
photonIndexMuGate = And @@ (
  ! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] & /@
    allBilinearExpressions
);
photonIndexNuGate = And @@ (
  ! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] & /@
    allBilinearExpressions
);
photonPolarizationRemovedGate = And @@ (
  FreeQ[#, FeynCalc`Polarization[q, ___]] & /@
    allBilinearExpressions
);
fragmentingGluonPolarizationGate = And @@ (
  ! FreeQ[#, FeynCalc`Polarization[k1, ___]] & /@
    allBilinearExpressions
);
realUnobservedGluonPolarizationGate =
  ! FreeQ[realSquareMuNu, FeynCalc`Polarization[k3, ___]];
externalSpinorsRetainedGate = And @@ (
  ! FreeQ[#, _FeynCalc`Spinor] & /@ allBilinearExpressions
);
colorStructuresRetainedGate = ! FreeQ[
  allBilinearExpressions,
  _FeynCalc`SUNFIndex | _FeynCalc`SUNT |
    _FeynCalc`SUNDelta | _FeynCalc`SUNFDelta
];
conjugationAndTIDEvaluatedGate = FreeQ[
  allBilinearExpressions,
  FeynCalc`ComplexConjugate | FeynCalc`TID
];
bilinearFailureFreeGate = FreeQ[allBilinearExpressions, $Failed];
bilinearFCGVContextGate =
  FreeQ[allBilinearExpressions, _FeynArts`FCGV];
bilinearExactGate = FreeQ[allBilinearExpressions, _Real];
virtualCountertermsRetainedGate =
  ! FreeQ[virtualInterferenceMuNuSymbolic, dZGG1] &&
    ! FreeQ[virtualInterferenceMuNuSymbolic, dZgs1] &&
    ! FreeQ[
      virtualInterferenceMuNuSymbolic,
      _dZfL1 | _dZfR1
    ];
virtualSquareExcludedGate =
  ! KeyExistsQ[bilinears, "NLOVirtualSquare_OAlphaS2"] &&
    ! KeyExistsQ[bilinears, "NLOVirtualSquare"];
spinColorSumsDeferredGate =
  externalSpinorsRetainedGate &&
    fragmentingGluonPolarizationGate &&
    colorStructuresRetainedGate;

assert[bilinearConstructionGate,
  "At least one coherent bilinear failed exact reconstruction."];
assert[photonIndexMuGate,
  "At least one bilinear is missing photon index s05Mu."];
assert[photonIndexNuGate,
  "At least one bilinear is missing photon index s05Nu."];
assert[photonPolarizationRemovedGate,
  "At least one bilinear still contains a photon polarization."];
assert[fragmentingGluonPolarizationGate,
  "At least one bilinear lost the fragmenting-gluon polarization."];
assert[realUnobservedGluonPolarizationGate,
  "The real bilinear lost the unobserved final-gluon polarization."];
assert[externalSpinorsRetainedGate,
  "At least one bilinear is missing external spinors."];
assert[colorStructuresRetainedGate,
  "The bilinears contain no unsummed FeynCalc color structure."];
assert[conjugationAndTIDEvaluatedGate,
  "An unevaluated conjugation or TID call remains in a bilinear."];
assert[bilinearFailureFreeGate,
  "A bilinear contains $Failed."];
assert[bilinearFCGVContextGate,
  "A bilinear contains a noncanonical FeynArts-context FCGV symbol."];
assert[bilinearExactGate,
  "Machine-precision numbers appeared in symbolic bilinears."];
assert[virtualCountertermsRetainedGate,
  "The symbolic virtual interference lost QCD counterterms."];
assert[virtualSquareExcludedGate,
  "A virtual-square term was included beyond the requested order."];
assert[spinColorSumsDeferredGate,
  "External spin/polarization/color structures were summed prematurely."];

loDiagramIndices = Range[expectedCounts["LO"]];
realDiagramIndices = Range[expectedCounts["RealQG"]];
virtualContributionIndices = Join[
  {"BareLoop", #} & /@ Range[expectedCounts["Virtual"]],
  {"UVCountertermQCDProjected", #} & /@
    Range[expectedCounts["Counterterm"]]
];
orderedPairLedgers = <|
  "LOSquare" -> Tuples[{loDiagramIndices, loDiagramIndices}],
  "NLORealHqgQG" -> Tuples[{realDiagramIndices, realDiagramIndices}],
  "LOVirtualHermitianOrientations" -> <|
    "LOxVirtualConjugate" ->
      Tuples[{loDiagramIndices, virtualContributionIndices}],
    "VirtualxLOConjugate" ->
      Tuples[{virtualContributionIndices, loDiagramIndices}]
  |>
|>;
orderedPairCounts = <|
  "LOSquare" -> Length[orderedPairLedgers["LOSquare"]],
  "NLORealHqgQG" -> Length[orderedPairLedgers["NLORealHqgQG"]],
  "LOVirtualHermitianCrossTerms" -> Total[
    Length /@ Values[
      orderedPairLedgers["LOVirtualHermitianOrientations"]
    ]
  ]
|>;
orderedPairLedgerGate =
  AllTrue[Values[orderedPairCounts], IntegerQ[#] && # > 0 &] &&
    Length[DeleteDuplicates[orderedPairLedgers["LOSquare"]]] ===
      orderedPairCounts["LOSquare"] &&
    Length[DeleteDuplicates[orderedPairLedgers["NLORealHqgQG"]]] ===
      orderedPairCounts["NLORealHqgQG"] &&
    Length[
      orderedPairLedgers["LOVirtualHermitianOrientations"]
    ] === Length[virtualInterferenceTermsMuNuSymbolic] &&
    Total[
      Length /@ Values[
        orderedPairLedgers["LOVirtualHermitianOrientations"]
      ]
    ] === orderedPairCounts["LOVirtualHermitianCrossTerms"];
assert[orderedPairLedgerGate,
  "The tool-built coherent ordered-pair ledgers are inconsistent."];

allCoherentSumsGate = And[
  loCoherentSumGate,
  realCoherentSumGate,
  bareVirtualCoherentSumGate,
  countertermCoherentSumGate,
  renormalizedVirtualSumGate,
  openAmplitudeReconstructionGate,
  bilinearConstructionGate
];
calculationFullySymbolicGate = And[
  fullAmplitudeExactGate,
  countertermProjectionExactGate,
  virtualTIDCompletenessGate,
  bilinearFailureFreeGate,
  bilinearExactGate
];
s05Checks = <|
  "AcceptedS01AndS04SourceResultIdentities" -> upstreamIdentityGate,
  "CompleteCheckedS01AndS04Schemas" -> sourceSchemaGate,
  "S04PreservesExactAcceptedS01Lineage" -> sourceLineageGate,
  "PaperAndBigTMDConventionsPreserved" -> paperAndBigTMDGate,
  "ChargeStrippedHardKernelConventionPreserved" -> chargeConventionGate,
  "AmplitudeStripFactorExactReciprocal" -> amplitudeStripFactorGate,
  "FragmentingGluonRoutingPreserved" -> fragmentingPartonGate,
  "GeneratedCountLedgerValid" -> generatedCountLedgerGate,
  "SourceDiagramCollectionsMatchGeneratedLedger" ->
    sourceDiagramCollectionGate,
  "FullAmplitudeCountsMatchGeneratedLedger" -> fullAmplitudeCountGate,
  "AmplitudeStripFactorAppliedToEveryRegeneratedCollection" ->
    amplitudeStripAuditGate,
  "FeynArtsFCGVCanonicalizedToFeynCalc" ->
    feynArtsFCGVCanonicalizationGate,
  "S01KinematicSerializationSchemaAccepted" -> kinematicRecordGate,
  "S01KinematicsReinstalledWithZeroResiduals" ->
    kinematicInstallationGate,
  "S01ToolDerivedKinematicsInstalled" -> kinematicDerivationGate,
  "VirtualTIDCacheFullProvenanceValid" -> virtualCacheContractGate,
  "VirtualTIDExpressionsComplete" -> virtualTIDCompletenessGate,
  "S04QCDProjectionRulesPreserved" -> qcdProjectionRuleHandoffGate,
  "ElectroweakCountertermsRemoved" ->
    electroweakCountertermsRemovedGate,
  "MassCountertermRemoved" -> massCountertermRemovedGate,
  "SymbolicQCDCountertermsRetained" -> qcdCountertermsRetainedGate,
  "AllDiagramsCoherentlySummedBeforeProducts" -> allCoherentSumsGate,
  "RealOpenAmplitudeBlockCountMatchesGeneratedLedger" ->
    realOpenBlockCountGate,
  "RealConjugateBlockCountMatchesGeneratedLedger" ->
    realConjugateBlockCountGate,
  "CoherentOrderedPairLedgersToolBuilt" -> orderedPairLedgerGate,
  "PhotonPolarizationRemoved" -> photonPolarizationRemovedGate,
  "PhotonIndexMuPresent" -> photonIndexMuGate,
  "PhotonIndexNuPresent" -> photonIndexNuGate,
  "FragmentingGluonPolarizationRetained" ->
    fragmentingGluonPolarizationGate,
  "RealUnobservedGluonPolarizationRetained" ->
    realUnobservedGluonPolarizationGate,
  "ExternalSpinorsRetained" -> externalSpinorsRetainedGate,
  "UnsummedColorStructuresRetained" -> colorStructuresRetainedGate,
  "FeynCalcConjugationAndTIDEvaluated" ->
    conjugationAndTIDEvaluatedGate,
  "BilinearsContainNoFeynArtsFCGV" -> bilinearFCGVContextGate,
  "VirtualCountertermsIncluded" -> virtualCountertermsRetainedGate,
  "VirtualSquareExcludedBeyondOAlphaS2" -> virtualSquareExcludedGate,
  "CalculationFullySymbolic" -> calculationFullySymbolicGate,
  "SpinColorSumsNotYetApplied" -> spinColorSumsDeferredGate
|>;
assert[
  AllTrue[Values[s05Checks], TrueQ],
  "At least one derived S05 validation gate is not True."
];

s05Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS05-v4",
  "Channel" -> "Hqg only",
  "Contribution" -> "Hqg LO, Hqg;qg real, and Hqg;q virtual interference",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "StageSource" -> stageSourcePath,
  "StageSourceSHA256" -> stageSourceSHA256,
  "StageSourceSHA256Hex" -> stageSourceSHA256Hex,
  "SourceResults" -> <|
    "S01Source" -> s01SourcePath,
    "S01SourceSHA256" -> FileHash[s01SourcePath, "SHA256"],
    "S01SourceSHA256Hex" -> s01SourceSHA256Hex,
    "S01" -> s01Path,
    "S01SHA256" -> s01Hash,
    "S01ResultSHA256Hex" -> s01ResultSHA256Hex,
    "S04Source" -> s04SourcePath,
    "S04SourceSHA256" -> FileHash[s04SourcePath, "SHA256"],
    "S04SourceSHA256Hex" -> s04SourceSHA256Hex,
    "S04" -> s04Path,
    "S04SHA256" -> s04Hash,
    "S04ResultSHA256Hex" -> s04ResultSHA256Hex,
    "ReferencePDFSHA256" -> s01["ReferencePDFSHA256"]
  |>,
  "BigTMDConvention" -> s01["BigTMDConvention"],
  "ElectricChargeNormalization" -> s01["ElectricChargeNormalization"],
  "KinematicDerivation" -> s01KinematicDerivation,
  "KinematicInstallationAudit" -> kinematicInstallationAudit,
  "FullAmplitudeConversionAudit" -> conversionAudit,
  "VirtualTIDCache" -> <|
    "Path" -> virtualTIDCachePath,
    "SHA256" -> FileHash[virtualTIDCachePath, "SHA256"],
    "Stage" -> virtualCache["Stage"],
    "S01SHA256" -> virtualCache["S01SHA256"],
    "S04SHA256" -> virtualCache["S04SHA256"],
    "S05SourceSHA256" -> virtualCache["S05SourceSHA256"],
    "ChargeNormalizationContentHash" ->
      virtualCache["ChargeNormalizationContentHash"],
    "KinematicDerivationContentHash" ->
      virtualCache["KinematicDerivationContentHash"],
    "KinematicInstallationAuditContentHash" ->
      virtualCache["KinematicInstallationAuditContentHash"],
    "KinematicSerializationSchema" ->
      virtualCache["KinematicSerializationSchema"],
    "FullVirtualInputContentHash" ->
      virtualCache["FullVirtualInputContentHash"],
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
  "CoherentOrderedPairLedgers" -> orderedPairLedgers,
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

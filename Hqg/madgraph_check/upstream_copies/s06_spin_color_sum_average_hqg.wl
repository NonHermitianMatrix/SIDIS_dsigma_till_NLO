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
  assert, fatal, sha256Hex, scalarProductAssignment,
  installMassShellAssignments, installScalarProductAssignments,
  installKinematicRecord, deriveThreeBodyKinematics,
  setTwoBodyKinematics, setThreeBodyKinematics,
  gluonPolarizationMomenta, cacheProvenanceFor,
  deleteCacheIfPresent,
  validatePostDiracTensor, validateSummedTensor,
  cacheMetadataValidQ, loadValidatedCache, writeValidatedCache,
  processBilinear, processPhysicalRealBlocks
];

fatal[message_String] := (
  Print["S06_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];
sha256Hex[path_String] := ToLowerCase[
  IntegerString[FileHash[path, "SHA256"], 16, 64]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s05SourcePath = FileNameJoin[{
  scriptDirectory, "s05_form_hqg_bilinears.wl"
}];
s05Path = FileNameJoin[{scriptDirectory, "s05_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s06_result"}];
stageVersion = "HqgS06-v4";
acceptedS05SourceSHA256 =
  "750707b417051fa9380772702fc7737f1f659fa160df285186ee82562b8d0e74";
acceptedS05ResultSHA256 =
  "ab5d6e6ff2513c19ecdbe4f95c72de79bbf1d1b3724803db22fc5526c5e21878";
acceptedS01SourceSHA256 =
  "8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0";
acceptedS01ResultSHA256 =
  "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198";
acceptedS04SourceSHA256 =
  "ad6c5fd46152805538d1234c787feae212a9f5aa217853d7e81b4818bb567e54";
acceptedS04ResultSHA256 =
  "2bbeeee841e5e47bfd2391a1588b2184a16865d334bf78716b1b0573d499bf92";

Print["S06_STAGE: loading validated Hqg s05_result"];
assert[FileExistsQ[s05SourcePath], "The accepted S05 source is absent."];
assert[FileExistsQ[s05Path], "s05_result does not exist."];
s05SourceSHA256Hex = sha256Hex[s05SourcePath];
s05ResultSHA256Hex = sha256Hex[s05Path];
s05IdentityGate =
  s05SourceSHA256Hex === acceptedS05SourceSHA256 &&
    s05ResultSHA256Hex === acceptedS05ResultSHA256;
assert[s05IdentityGate,
  "S05 source/result identities do not match the accepted Hqg ledger."];
s05 = Check[Get[s05Path], $Failed];
assert[AssociationQ[s05], "s05_result did not load as an Association."];
sourceSchemaGate =
  s05["Status"] === "Complete" &&
    s05["Stage"] === "HqgS05-v4" &&
    s05["Channel"] === "Hqg only" &&
    AssociationQ[s05["Checks"]] &&
    AllTrue[Values[s05["Checks"]], TrueQ] &&
    s05["StageSource"] === s05SourcePath &&
    s05["StageSourceSHA256"] === FileHash[s05SourcePath, "SHA256"] &&
    s05["StageSourceSHA256Hex"] === s05SourceSHA256Hex;
assert[sourceSchemaGate,
  "s05_result is not the accepted complete checked Hqg S05 result."];

s05SourceResults = s05["SourceResults"];
embeddedLineageGate =
  AssociationQ[s05SourceResults] &&
    And @@ (FileExistsQ[s05SourceResults[#]] & /@ {
      "S01Source", "S01", "S04Source", "S04"
    }) &&
    s05SourceResults["S01SourceSHA256"] ===
      FileHash[s05SourceResults["S01Source"], "SHA256"] &&
    s05SourceResults["S01SourceSHA256Hex"] ===
      acceptedS01SourceSHA256 &&
    s05SourceResults["S01SHA256"] ===
      FileHash[s05SourceResults["S01"], "SHA256"] &&
    s05SourceResults["S01ResultSHA256Hex"] ===
      acceptedS01ResultSHA256 &&
    s05SourceResults["S04SourceSHA256"] ===
      FileHash[s05SourceResults["S04Source"], "SHA256"] &&
    s05SourceResults["S04SourceSHA256Hex"] ===
      acceptedS04SourceSHA256 &&
    s05SourceResults["S04SHA256"] ===
      FileHash[s05SourceResults["S04"], "SHA256"] &&
    s05SourceResults["S04ResultSHA256Hex"] ===
      acceptedS04ResultSHA256;
assert[embeddedLineageGate,
  "S05 does not preserve the exact accepted repaired S01/S04 lineage."];
s01 = Check[Get[s05SourceResults["S01"]], $Failed];
assert[AssociationQ[s01], "The S01 provenance result did not load."];
paperReferenceGate =
  IntegerQ[s05SourceResults["ReferencePDFSHA256"]] &&
    s05SourceResults["ReferencePDFSHA256"] ===
      s01["ReferencePDFSHA256"];
assert[paperReferenceGate, "S05 has no exact accepted reference-paper hash."];
bigTMDConventionGate =
  s05["BigTMDConvention", "ChannelNumber"] === 3 &&
    s05["BigTMDConvention", "ChargeCase"] === "A only" &&
    s05["BigTMDConvention"] === s01["BigTMDConvention"];
assert[bigTMDConventionGate,
  "S05 is not bound to BigTMD Hqg channel 3, case A."];
chargeConventionGate =
  AssociationQ[s05["ElectricChargeNormalization"]] &&
    s05["ElectricChargeNormalization"] ===
      s01["ElectricChargeNormalization"] &&
    s05["ElectricChargeNormalization", "ReferenceCharge"] ===
      Lookup[
        s05["ElectricChargeNormalization", "ModelChargeCoefficients"],
        "F" <> ToString[
          s05["ElectricChargeNormalization", "FeynArtsReferenceClass"]
        ],
        Missing["Absent"]
      ] &&
    Together[
      s05["ElectricChargeNormalization", "ReferenceCharge"] *
        s05["ElectricChargeNormalization", "AmplitudeStripFactor"]
    ] === 1 &&
    s05["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g";
assert[chargeConventionGate,
  "S05 is not in the corrected charge-stripped hard-kernel convention."];
fragmentingPartonGate =
  s05[
    "ExternalProcessOrganization", "LOAndVirtual", "FragmentingParton"
  ] === "g(k1)" &&
    s05[
      "ExternalProcessOrganization", "NLOReal", "FragmentingParton"
    ] === "g(k1)";
assert[fragmentingPartonGate,
  "S05 does not preserve the fragmenting-gluon g(k1) convention."];

s05DiagramCounts = s05["DiagramCounts"];
s05OrderedPairLedgers = s05["CoherentOrderedPairLedgers"];
derivedOrderedPairCounts = <|
  "LOSquare" -> Length[s05OrderedPairLedgers["LOSquare"]],
  "NLORealHqgQG" ->
    Length[s05OrderedPairLedgers["NLORealHqgQG"]],
  "LOVirtualHermitianCrossTerms" -> Total[
    Length /@ Values[
      s05OrderedPairLedgers["LOVirtualHermitianOrientations"]
    ]
  ]
|>;
countLedgerGate =
  AssociationQ[s05DiagramCounts] &&
    AllTrue[Values[s05DiagramCounts], IntegerQ[#] && # > 0 &] &&
    AssociationQ[s05OrderedPairLedgers] &&
    s05["CoherentOrderedPairCounts"] === derivedOrderedPairCounts;
assert[countLedgerGate,
  "S05 diagram or coherent-pair ledgers are not internally derived."];

initialStateNormalization = s01["InitialStateNormalization"];
initialSpinStates = initialStateNormalization["InitialSpinStates"];
initialColorStates = initialStateNormalization["InitialColorStates"];
initialStateAverage = initialStateNormalization["InitialStateAverage"];
initialStateNormalizationGate =
  AssociationQ[initialStateNormalization] &&
    TrueQ[initialStateNormalization["FermionHeadVerified"]] &&
    TrueQ[initialStateNormalization["FundamentalColorIndexVerified"]] &&
    initialSpinStates =!= 0 && initialColorStates =!= 0 &&
    Together[
      initialStateAverage initialSpinStates initialColorStates
    ] === 1 &&
    TrueQ[s01["Checks", "InitialStateAverageToolDerived"]] &&
    FreeQ[initialStateNormalization, _Real | _Missing];
assert[initialStateNormalizationGate,
  "The incoming-quark state normalization is not tool-derived and exact."];

s05SHA256 = FileHash[s05Path, "SHA256"];

loBilinear = s05["Bilinears", "LOSquare_OAlphaS"];
realQGBilinear = s05[
  "Bilinears", "NLORealSquares_OAlphaS2", "Hqg;qg"
];
realQGAmplitudeBlocks =
  s05["OpenPhotonIndexRealAmplitudeBlocks", "Hqg;qg_Mu"];
realQGConjugateBlocks =
  s05["OpenPhotonIndexRealAmplitudeBlocks", "Hqg;qg_NuConjugate"];
realCoherentRowCount = Length[realQGAmplitudeBlocks];
realBlockCountGate =
  ListQ[realQGAmplitudeBlocks] && ListQ[realQGConjugateBlocks] &&
    Length[realQGConjugateBlocks] === realCoherentRowCount &&
    s05["OpenPhotonIndexRealAmplitudeBlocks", "BlockCount"] ===
      realCoherentRowCount &&
    s05DiagramCounts["RealQG"] === realCoherentRowCount &&
    Length[s05OrderedPairLedgers["NLORealHqgQG"]] ===
      realCoherentRowCount Length[realQGConjugateBlocks];
assert[realBlockCountGate,
  "S05 coherent real-amplitude blocks disagree with its generated ledgers."];
masslessVectorQCDRules = {
  HoldPattern[dZfL1[indices___]] :> dZq1[indices],
  HoldPattern[dZfR1[indices___]] :> dZq1[indices]
};
virtualInterferenceBilinear =
  s05["Bilinears", "NLOVirtualInterference_OAlphaS2_Symbolic"] /.
    masslessVectorQCDRules;

inputTensorRoles = <|
  "LO" -> loBilinear,
  "RealQG" -> realQGBilinear,
  "VirtualInterference" -> virtualInterferenceBilinear
|>;
inputContentRecords = <|
  "LO" -> <|"Bilinear" -> loBilinear|>,
  "RealQG" -> <|
    "Bilinear" -> realQGBilinear,
    "AmplitudeBlocks" -> realQGAmplitudeBlocks,
    "ConjugateBlocks" -> realQGConjugateBlocks
  |>,
  "VirtualInterference" -> <|
    "Bilinear" -> virtualInterferenceBilinear
  |>
|>;
inputContentHashes = Map[Hash[#, "SHA256"] &, inputContentRecords];
Clear[inputContentRecords];

gluonPolarizationMomenta[expression_] := SortBy[
  DeleteDuplicates[
    Cases[
      expression,
      FeynCalc`Polarization[momentum_, ___] :> momentum,
      Infinity
    ]
  ],
  ToString[#, InputForm] &
];
loGluonMomenta = gluonPolarizationMomenta[loBilinear];
realGluonMomenta = gluonPolarizationMomenta[realQGBilinear];
virtualGluonMomenta =
  gluonPolarizationMomenta[virtualInterferenceBilinear];
realExternalQuarkMomenta = DeleteDuplicates[
  Cases[
    realQGBilinear,
    FeynCalc`Spinor[
      FeynCalc`Momentum[momentum_, D], ___
    ] :> momentum,
    Infinity
  ]
];
realFinalQuarkMomenta = DeleteCases[realExternalQuarkMomenta, p];
threeBodyFinalMomenta = SortBy[
  DeleteDuplicates[Join[realGluonMomenta, realFinalQuarkMomenta]],
  ToString[#, InputForm] &
];
polarizationSpecifications = <|
  "LO" -> ({#, 0} & /@ loGluonMomenta),
  "RealQG" -> ({#, p} & /@ realGluonMomenta),
  "VirtualInterference" -> ({#, 0} & /@ virtualGluonMomenta)
|>;
singleGluonCovariantConventionGate =
  loGluonMomenta === {k1} && virtualGluonMomenta === {k1} &&
    polarizationSpecifications["LO"] === {{k1, 0}} &&
    polarizationSpecifications["VirtualInterference"] === {{k1, 0}};
realPhysicalAxialConventionGate =
  realGluonMomenta === {k1, k3} &&
    First /@ polarizationSpecifications["RealQG"] ===
      realGluonMomenta &&
    AllTrue[
      Last /@ polarizationSpecifications["RealQG"],
      SameQ[#, p] &
    ];
realExternalStateMomentumGate =
  MemberQ[realExternalQuarkMomenta, p] &&
    realFinalQuarkMomenta === {k2} &&
    threeBodyFinalMomenta === {k1, k2, k3};
assert[singleGluonCovariantConventionGate,
  "The one-gluon branches do not use the accepted covariant convention."];
assert[realPhysicalAxialConventionGate,
  "The real branch does not use axial projectors for both final gluons."];
assert[realExternalStateMomentumGate,
  "The accepted real bilinear does not derive the ordered k1,k2,k3 final state."];

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
      {index, realCoherentRowCount}
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

scalarProductAssignment[pair_, value_] := Module[
  {pairComponents, leftComponents, rightComponents},
  pairComponents = List @@ pair;
  assert[
    Length[pairComponents] === 2 &&
      And @@ (Head[#] === FeynCalc`Momentum & /@ pairComponents),
    "A solved scalar-product object is not a two-momentum FeynCalc Pair."
  ];
  leftComponents = List @@ pairComponents[[1]];
  rightComponents = List @@ pairComponents[[2]];
  assert[
    Length[leftComponents] === 2 && Length[rightComponents] === 2 &&
      Last[leftComponents] === Last[rightComponents],
    "A solved scalar-product Pair has inconsistent momentum dimensions."
  ];
  <|
    "Momentum1" -> First[leftComponents],
    "Momentum2" -> First[rightComponents],
    "Dimension" -> Last[leftComponents],
    "Value" -> value
  |>
];

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

installKinematicRecord[record_Association] := Module[
  {massResiduals, scalarResiduals, audit},
  FeynCalc`FCClearScalarProducts[];
  installMassShellAssignments[record["MassShellAssignments"]];
  installScalarProductAssignments[record["ScalarProductAssignments"]];
  massResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum"], Lookup[#, "Momentum"]
      ] - Lookup[#, "MassSquared"]
    ] & /@ record["MassShellAssignments"];
  scalarResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum1"], Lookup[#, "Momentum2"]
      ] - Lookup[#, "Value"]
    ] & /@ record["ScalarProductAssignments"];
  audit = <|
    "SerializationSchema" -> record["SerializationSchema"],
    "MassShellResiduals" -> massResiduals,
    "ScalarProductResiduals" -> scalarResiduals,
    "InstalledExactly" -> AllTrue[
      Join[massResiduals, scalarResiduals],
      SameQ[#, 0] &
    ]
  |>;
  assert[TrueQ[audit["InstalledExactly"]],
    "An inert kinematic record was not installed exactly."];
  audit
];

twoBodyKinematicRecord = s05["KinematicDerivation"];
twoBodyKinematicRecordGate =
  AssociationQ[twoBodyKinematicRecord] &&
    twoBodyKinematicRecord["SerializationSchema"] ===
      "HqgS01Kinematics-v2" &&
    TrueQ[twoBodyKinematicRecord["UniqueExactSolution"]] &&
    Head[twoBodyKinematicRecord["DefiningEquationsHeld"]] ===
      HoldComplete &&
    Head[twoBodyKinematicRecord["SolvedScalarProductsHeld"]] ===
      HoldComplete &&
    ! FreeQ[
      twoBodyKinematicRecord["DefiningEquationsHeld"],
      _FeynCalc`Pair
    ] &&
    ! FreeQ[
      twoBodyKinematicRecord["SolvedScalarProductsHeld"],
      _FeynCalc`Pair
    ] &&
    ListQ[twoBodyKinematicRecord["MassShellAssignments"]] &&
    ListQ[twoBodyKinematicRecord["ScalarProductAssignments"]] &&
    AllTrue[
      Join[
        twoBodyKinematicRecord["MassShellInstallationResiduals"],
        twoBodyKinematicRecord["ScalarProductInstallationResiduals"],
        twoBodyKinematicRecord["EquationResiduals"]
      ],
      SameQ[#, 0] &
    ] &&
    TrueQ[
      s05["Checks", "S01KinematicSerializationSchemaAccepted"]
    ] &&
    TrueQ[
      s05["Checks", "S01KinematicsReinstalledWithZeroResiduals"]
    ] &&
    FreeQ[twoBodyKinematicRecord, _Real | _Missing];
assert[twoBodyKinematicRecordGate,
  "S05 does not contain the accepted inert two-body kinematic record."];
twoBodyKinematicInstallationAudit =
  installKinematicRecord[twoBodyKinematicRecord];

deriveThreeBodyKinematics[] := Module[
  {
    finalMomenta, tInvariants, uInvariants, pairMomenta,
    pairInvariants, massShellAssignments, massShellResiduals,
    definingEquations, definingEquationsHeld, pairObjects,
    algebraicVariables, pairToVariableRules, algebraicEquations,
    solutions, solution, pairRules, solvedScalarProductsHeld,
    scalarProductAssignments, equationResiduals,
    scalarInstallationResiduals
  },
  FeynCalc`FCClearScalarProducts[];
  finalMomenta = threeBodyFinalMomenta;
  tInvariants = {t1, t2, t3};
  uInvariants = {u1, u2, u3};
  pairMomenta = Subsets[{k1, k2, k3}, {2}];
  pairInvariants = {s12, s13, s23};
  assert[
    Length[finalMomenta] === Length[tInvariants] &&
      Length[finalMomenta] === Length[uInvariants] &&
      Length[pairMomenta] === Length[pairInvariants],
    "The three-body invariant labels do not cover the final momenta."
  ];
  massShellAssignments = Join[
    {
      <|"Momentum" -> p, "MassSquared" -> 0|>,
      <|"Momentum" -> q, "MassSquared" -> -Q2|>
    },
    (<|"Momentum" -> #, "MassSquared" -> 0|> & /@ finalMomenta)
  ];
  installMassShellAssignments[massShellAssignments];
  massShellResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum"], Lookup[#, "Momentum"]
      ] - Lookup[#, "MassSquared"]
    ] & /@ massShellAssignments;
  definingEquations = Join[
    {
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[p + q, p + q]
      ] == sHat
    },
    MapThread[
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[q - #1, q - #1]
      ] == #2 &,
      {finalMomenta, tInvariants}
    ],
    MapThread[
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[p - #1, p - #1]
      ] == #2 &,
      {finalMomenta, uInvariants}
    ],
    MapThread[
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[Total[#1], Total[#1]]
      ] == #2 &,
      {pairMomenta, pairInvariants}
    ]
  ];
  definingEquationsHeld = ToExpression[
    ToString[definingEquations, InputForm],
    InputForm,
    HoldComplete
  ];
  pairObjects = DeleteDuplicates[
    Cases[definingEquations, _FeynCalc`Pair, Infinity]
  ];
  algebraicVariables = Array[
    s06ThreeBodyScalar,
    Length[pairObjects]
  ];
  pairToVariableRules = Thread[pairObjects -> algebraicVariables];
  algebraicEquations = definingEquations /. pairToVariableRules;
  solutions = Solve[algebraicEquations, algebraicVariables];
  assert[ListQ[solutions] && Length[solutions] === 1,
    "The defining three-body invariant system is not uniquely solved."];
  solution = First[solutions];
  pairRules = Thread[
    pairObjects -> (algebraicVariables /. solution)
  ];
  solvedScalarProductsHeld = ToExpression[
    ToString[pairRules, InputForm],
    InputForm,
    HoldComplete
  ];
  scalarProductAssignments = MapThread[
    scalarProductAssignment,
    {pairObjects, algebraicVariables /. solution}
  ];
  equationResiduals = Together[
      (#[[1]] - #[[2]]) /. solution
    ] & /@ algebraicEquations;
  installScalarProductAssignments[scalarProductAssignments];
  scalarInstallationResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum1"], Lookup[#, "Momentum2"]
      ] - Lookup[#, "Value"]
    ] & /@ scalarProductAssignments;
  assert[
    AllTrue[
      Join[
        massShellResiduals, equationResiduals,
        scalarInstallationResiduals
      ],
      SameQ[#, 0] &
    ] &&
      AllTrue[scalarProductAssignments, AssociationQ] &&
      FreeQ[
        {
          definingEquationsHeld, solvedScalarProductsHeld,
          scalarProductAssignments
        },
        _Real | _Missing
      ],
    "The tool-derived three-body kinematic record failed exact gates."
  ];
  <|
    "SerializationSchema" -> "HqgS06ThreeBodyKinematics-v1",
    "MassShellAssignments" -> massShellAssignments,
    "MassShellInstallationResiduals" -> massShellResiduals,
    "DefiningEquationsHeld" -> definingEquationsHeld,
    "ScalarProductAssignments" -> scalarProductAssignments,
    "SolvedScalarProductsHeld" -> solvedScalarProductsHeld,
    "ScalarProductInstallationResiduals" ->
      scalarInstallationResiduals,
    "EquationResiduals" -> equationResiduals,
    "UniqueExactSolution" -> (Length[solutions] === 1),
    "FinalMomenta" -> finalMomenta,
    "TInvariants" -> tInvariants,
    "UInvariants" -> uInvariants,
    "PairMomenta" -> pairMomenta,
    "PairInvariants" -> pairInvariants
  |>
];

threeBodyKinematicRecord = deriveThreeBodyKinematics[];
threeBodyKinematicRecordGate =
  AssociationQ[threeBodyKinematicRecord] &&
    threeBodyKinematicRecord["SerializationSchema"] ===
      "HqgS06ThreeBodyKinematics-v1" &&
    TrueQ[threeBodyKinematicRecord["UniqueExactSolution"]] &&
    Head[threeBodyKinematicRecord["DefiningEquationsHeld"]] ===
      HoldComplete &&
    Head[threeBodyKinematicRecord["SolvedScalarProductsHeld"]] ===
      HoldComplete &&
    ! FreeQ[
      threeBodyKinematicRecord["DefiningEquationsHeld"],
      _FeynCalc`Pair
    ] &&
    ! FreeQ[
      threeBodyKinematicRecord["SolvedScalarProductsHeld"],
      _FeynCalc`Pair
    ] &&
    AllTrue[
      Join[
        threeBodyKinematicRecord["MassShellInstallationResiduals"],
        threeBodyKinematicRecord["ScalarProductInstallationResiduals"],
        threeBodyKinematicRecord["EquationResiduals"]
      ],
      SameQ[#, 0] &
    ] &&
    FreeQ[threeBodyKinematicRecord, _Real | _Missing];
assert[threeBodyKinematicRecordGate,
  "The tool-derived inert three-body kinematic record is invalid."];
threeBodyKinematicInstallationAudit =
  installKinematicRecord[threeBodyKinematicRecord];

setTwoBodyKinematics[] :=
  installKinematicRecord[twoBodyKinematicRecord];
setThreeBodyKinematics[] :=
  installKinematicRecord[threeBodyKinematicRecord];

kinematicContentHashes = <|
  "TwoBody" -> Hash[twoBodyKinematicRecord, "SHA256"],
  "ThreeBody" -> Hash[threeBodyKinematicRecord, "SHA256"]
|>;
stateNormalizationContentHash = Hash[
  initialStateNormalization,
  "SHA256"
];
commonCacheProvenance = <|
  "StageVersion" -> stageVersion,
  "S06Program" -> programPath,
  "S06ProgramSHA256" -> programSHA256,
  "S05Source" -> s05SourcePath,
  "S05SourceSHA256" -> FileHash[s05SourcePath, "SHA256"],
  "S05SourceSHA256Hex" -> s05SourceSHA256Hex,
  "S05Result" -> s05Path,
  "S05ResultSHA256" -> s05SHA256,
  "S05ResultSHA256Hex" -> s05ResultSHA256Hex,
  "EmbeddedSourceResults" -> s05SourceResults,
  "BigTMDConvention" -> s05["BigTMDConvention"],
  "ExternalProcessOrganization" ->
    s05["ExternalProcessOrganization"],
  "PhotonIndices" -> s05["PhotonIndices"],
  "ElectricChargeNormalization" ->
    s05["ElectricChargeNormalization"],
  "InitialStateNormalization" -> initialStateNormalization,
  "InitialStateNormalizationContentHash" ->
    stateNormalizationContentHash,
  "KinematicContentHashes" -> kinematicContentHashes,
  "InputContentHashes" -> inputContentHashes,
  "RealCoherentRowCount" -> realCoherentRowCount
|>;

cacheProvenanceFor[
    tensorRole_String, kinematicRole_String,
    specifications_List, inputContentHash_, rowIdentity_
  ] := Join[
  commonCacheProvenance,
  <|
    "TensorRole" -> tensorRole,
    "KinematicRole" -> kinematicRole,
    "KinematicContentHash" ->
      kinematicContentHashes[kinematicRole],
    "PolarizationSpecifications" -> specifications,
    "InputContentHash" -> inputContentHash,
    "RowIdentity" -> rowIdentity
  |>
];

expectedCachePaths = Join[
  Values[cachePaths["LO"]],
  {
    cachePaths["RealQG", "PostDirac"],
    cachePaths["RealQG", "Final"]
  },
  cachePaths["RealQG", "PhysicalRowsPostDirac"],
  Values[cachePaths["VirtualInterference"]]
];

preflightOnlyQ = Environment["HQG_S06_PREFLIGHT_ONLY"] === "1";
If[preflightOnlyQ,
  preflightAggregateProvenances = <|
    "LO" -> cacheProvenanceFor[
      "LO", "TwoBody", polarizationSpecifications["LO"],
      inputContentHashes["LO"], "Aggregate"
    ],
    "RealQG" -> cacheProvenanceFor[
      "RealQG", "ThreeBody", polarizationSpecifications["RealQG"],
      inputContentHashes["RealQG"], "Aggregate"
    ],
    "VirtualInterference" -> cacheProvenanceFor[
      "VirtualInterference", "TwoBody",
      polarizationSpecifications["VirtualInterference"],
      inputContentHashes["VirtualInterference"], "Aggregate"
    ]
  |>;
  preflightRealTotalConjugate = Total[realQGConjugateBlocks];
  preflightRealRowProvenances = MapIndexed[
    Function[{amplitudeBlock, position},
      cacheProvenanceFor[
        "RealQGPhysicalRow" <>
          IntegerString[First[position], 10, 2],
        "ThreeBody",
        polarizationSpecifications["RealQG"],
        Hash[
          {amplitudeBlock, preflightRealTotalConjugate},
          "SHA256"
        ],
        First[position]
      ]
    ],
    realQGAmplitudeBlocks
  ];
  preflightChecks = <|
    "CurrentProgramHashComputed" ->
      (programSHA256 === FileHash[programPath, "SHA256"] &&
        StringLength[sha256Hex[programPath]] === 64),
    "AcceptedS05SourceAndResultIdentity" -> s05IdentityGate,
    "CompleteCheckedS05Schema" -> sourceSchemaGate,
    "EmbeddedRepairedS01S04Lineage" -> embeddedLineageGate,
    "PaperReferenceHashPreserved" -> paperReferenceGate,
    "BigTMDChannel3CaseAEnforced" -> bigTMDConventionGate,
    "ChargeConventionPreserved" -> chargeConventionGate,
    "FragmentingPartonPreserved" -> fragmentingPartonGate,
    "DiagramAndOrderedPairLedgersDerived" -> countLedgerGate,
    "InitialStateNormalizationToolDerived" ->
      initialStateNormalizationGate,
    "RealBlockCountDerived" -> realBlockCountGate,
    "SingleGluonCovariantConvention" ->
      singleGluonCovariantConventionGate,
    "RealTwoGluonAxialConvention" ->
      realPhysicalAxialConventionGate,
    "RealFinalStateMomentaDerivedInInvariantOrder" ->
      realExternalStateMomentumGate,
    "TwoBodyInertKinematicRecordAccepted" ->
      twoBodyKinematicRecordGate,
    "TwoBodyRecordInstalledExactly" ->
      TrueQ[twoBodyKinematicInstallationAudit["InstalledExactly"]],
    "ThreeBodyKinematicRecordToolDerived" ->
      threeBodyKinematicRecordGate,
    "ThreeBodyRecordInstalledExactly" ->
      TrueQ[threeBodyKinematicInstallationAudit["InstalledExactly"]],
    "ThreeBodyInvariantOrderingExact" ->
      (threeBodyKinematicRecord["FinalMomenta"] ===
          threeBodyFinalMomenta &&
        threeBodyFinalMomenta === {k1, k2, k3}),
    "ThreeBodyDefiningAndInstallationResidualsZero" ->
      AllTrue[
        Join[
          threeBodyKinematicRecord[
            "MassShellInstallationResiduals"
          ],
          threeBodyKinematicRecord[
            "ScalarProductInstallationResiduals"
          ],
          threeBodyKinematicRecord["EquationResiduals"]
        ],
        SameQ[#, 0] &
      ],
    "InputContentHashesExact" ->
      (Keys[inputContentHashes] === Keys[inputTensorRoles] &&
        FreeQ[inputContentHashes, _Real | _Missing]),
    "CachePathsDerivedAndUnique" ->
      (Length[
          cachePaths["RealQG", "PhysicalRowsPostDirac"]
        ] === realCoherentRowCount &&
        DuplicateFreeQ[expectedCachePaths]),
    "AggregateCacheProvenanceComplete" ->
      (Keys[preflightAggregateProvenances] ===
          Keys[inputTensorRoles] &&
        AllTrue[
          Values[preflightAggregateProvenances],
          AssociationQ[#] &&
            #["S06ProgramSHA256"] === programSHA256 &&
            #["S05ResultSHA256Hex"] ===
              acceptedS05ResultSHA256 &&
            #["InitialStateNormalizationContentHash"] ===
              stateNormalizationContentHash &&
            #["KinematicContentHashes"] ===
              kinematicContentHashes &&
            #["InputContentHashes"] === inputContentHashes &
        ]),
    "EveryRealRowProvenanceDerived" ->
      (Length[preflightRealRowProvenances] ===
          realCoherentRowCount &&
        Lookup[
          preflightRealRowProvenances, "RowIdentity",
          Missing["Absent"]
        ] === Range[realCoherentRowCount] &&
        AllTrue[preflightRealRowProvenances, AssociationQ]),
    "StoppedBeforeCacheInitialization" -> ! ValueQ[cacheAudit],
    "NoGeneratedArtifacts" ->
      (! FileExistsQ[resultPath] &&
        AllTrue[expectedCachePaths, ! FileExistsQ[#] &] &&
        FileNames[
          "s06_result.tmp.*", scriptDirectory
        ] === {} &&
        FileNames[
          "s06_cache*.tmp.*", scriptDirectory
        ] === {})
  |>;
  Print["S06_PREFIX_GATES=", InputForm[preflightChecks]];
  assert[AllTrue[Values[preflightChecks], TrueQ],
    "At least one S06 semantic preflight gate is not True."];
  Print["HQG_S06_KINV2_PREFIX_PREFLIGHT_OK"];
  Quit[0]
];

cacheAudit = <||>;
processingAudit = <||>;

deleteCacheIfPresent[path_String] := If[
  FileExistsQ[path],
  Print["S06_STAGE: deleting stale or inconsistent cache " <> path];
  DeleteFile[path];
  assert[! FileExistsQ[path], "A stale cache could not be deleted."]
];

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

cacheMetadataValidQ[
    cache_, tensorRole_String, cacheStage_String,
    expectedProvenance_Association
  ] :=
  AssociationQ[cache] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === tensorRole &&
    cache["CacheStage"] === cacheStage &&
    cache["SourceS05SHA256"] === s05SHA256 &&
    cache["ProgramSHA256"] === programSHA256 &&
    cache["Provenance"] === expectedProvenance &&
    cache["BigTMDChannel"] ===
      s05["BigTMDConvention", "ChannelNumber"] &&
    cache["BigTMDChargeCase"] ===
      s05["BigTMDConvention", "ChargeCase"] &&
    cache["ElectricChargeNormalization"] ===
      s05["ElectricChargeNormalization"] &&
    cache["InitialStateAverage"] === initialStateAverage &&
    cache["FragmentingParton"] ===
      s05[
        "ExternalProcessOrganization", "NLOReal",
        "FragmentingParton"
      ] &&
    KeyExistsQ[cache, "Expression"];

loadValidatedCache[
    path_String, tensorRole_String, cacheStage_String,
    expectedProvenance_Association
  ] := Module[{cache, validMetadata},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S06_STAGE: inspecting cache " <> path];
  cache = Quiet@Check[Get[path], $Failed];
  validMetadata = cacheMetadataValidQ[
    cache, tensorRole, cacheStage, expectedProvenance
  ];
  If[! TrueQ[validMetadata],
    deleteCacheIfPresent[path];
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
  AssociateTo[cacheAudit, path -> True];
  Print[
    "S06_STAGE: loading validated " <> tensorRole <> " " <>
      cacheStage <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[
    path_String, tensorRole_String, cacheStage_String,
    expectedProvenance_Association, expr_
  ] := Module[{temporaryPath, cache, reloadedCache},
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
    "Provenance" -> expectedProvenance,
    "BigTMDChannel" ->
      s05["BigTMDConvention", "ChannelNumber"],
    "BigTMDChargeCase" ->
      s05["BigTMDConvention", "ChargeCase"],
    "ElectricChargeNormalization" -> s05["ElectricChargeNormalization"],
    "InitialStateAverage" -> initialStateAverage,
    "FragmentingParton" ->
      s05[
        "ExternalProcessOrganization", "NLOReal",
        "FragmentingParton"
      ],
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
  reloadedCache = Quiet@Check[Get[path], $Failed];
  assert[
    cacheMetadataValidQ[
      reloadedCache, tensorRole, cacheStage, expectedProvenance
    ] && SameQ[reloadedCache["Expression"], expr],
    tensorRole <> " " <> cacheStage <>
      " cache failed post-write reload validation."
  ];
  AssociateTo[cacheAudit, path -> True];
];

processBilinear[
    expr_, specifications_List, kinematicsSetup_Symbol,
    kinematicRole_String, tensorRole_String, label_String,
    paths_Association, inputContentHash_
  ] := Module[
  {postDiracTensor, finalTensor, expectedProvenance},
  expectedProvenance = cacheProvenanceFor[
    tensorRole, kinematicRole, specifications,
    inputContentHash, "Aggregate"
  ];
  finalTensor = loadValidatedCache[
    paths["Final"], tensorRole, "Final", expectedProvenance
  ];
  If[! MissingQ[finalTensor],
    postDiracTensor = loadValidatedCache[
      paths["PostDirac"], tensorRole, "PostDirac",
      expectedProvenance
    ];
    If[
      MissingQ[postDiracTensor],
      Print[
        "S06_STAGE: final cache has no matching post-Dirac cache; " <>
          "invalidating the final cache"
      ];
      deleteCacheIfPresent[paths["Final"]],
      AssociateTo[processingAudit, tensorRole -> <|
        "KinematicRole" -> kinematicRole,
        "PolarizationSpecifications" -> specifications,
        "InputContentHash" -> inputContentHash,
        "InitialStateAverage" -> initialStateAverage,
        "PostDiracContentHash" -> Hash[postDiracTensor, "SHA256"],
        "FinalContentHash" -> Hash[finalTensor, "SHA256"],
        "CacheReused" -> True
      |>];
      Return[finalTensor]
    ]
  ];

  postDiracTensor = loadValidatedCache[
    paths["PostDirac"], tensorRole, "PostDirac",
    expectedProvenance
  ];
  If[MissingQ[postDiracTensor],
    Print["S06_STAGE: setting kinematics for " <> label];
    kinematicsSetup[];

    Print["S06_STAGE: summing final-gluon polarizations for " <> label];
    postDiracTensor = Fold[
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
      expr,
      specifications
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
      paths["PostDirac"], tensorRole, "PostDirac",
      expectedProvenance, postDiracTensor
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
        postDiracTensor initialStateAverage,
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
    paths["Final"], tensorRole, "Final",
    expectedProvenance, finalTensor
  ];
  Print[
    "S06_CHECKPOINT: " <> tensorRole <> " final leaf count " <>
      ToString[LeafCount[finalTensor]]
  ];
  AssociateTo[processingAudit, tensorRole -> <|
    "KinematicRole" -> kinematicRole,
    "PolarizationSpecifications" -> specifications,
    "InputContentHash" -> inputContentHash,
    "InitialStateAverage" -> initialStateAverage,
    "PostDiracContentHash" -> Hash[postDiracTensor, "SHA256"],
    "FinalContentHash" -> Hash[finalTensor, "SHA256"],
    "CacheReused" -> False
  |>];
  finalTensor
];

processPhysicalRealBlocks[
    amplitudeBlocks_List, conjugateBlocks_List,
    kinematicsSetup_Symbol, kinematicRole_String,
    specifications_List, tensorRole_String, label_String,
    paths_Association, inputContentHash_
  ] := Module[
  {
    finalTensor, postDiracTensor, postDiracRows, totalConjugate,
    aggregateProvenance, rowRole, rowPath, rowExpression,
    rowInputHash, rowProvenance
  },
  aggregateProvenance = cacheProvenanceFor[
    tensorRole, kinematicRole, specifications,
    inputContentHash, "Aggregate"
  ];
  totalConjugate = Total[conjugateBlocks];
  finalTensor = loadValidatedCache[
    paths["Final"], tensorRole, "Final", aggregateProvenance
  ];
  If[! MissingQ[finalTensor],
    postDiracTensor = loadValidatedCache[
      paths["PostDirac"], tensorRole, "PostDirac",
      aggregateProvenance
    ];
    postDiracRows = If[
      MissingQ[postDiracTensor],
      {},
      MapIndexed[
        Function[{amplitudeBlock, position},
          rowRole = tensorRole <> "PhysicalRow" <>
            IntegerString[First[position], 10, 2];
          rowPath = paths["PhysicalRowsPostDirac"][[First[position]]];
          rowInputHash = Hash[
            {amplitudeBlock, totalConjugate},
            "SHA256"
          ];
          rowProvenance = cacheProvenanceFor[
            rowRole, kinematicRole, specifications,
            rowInputHash, First[position]
          ];
          loadValidatedCache[
            rowPath, rowRole, "PostDirac", rowProvenance
          ]
        ],
        amplitudeBlocks
      ]
    ];
    If[
      ! MissingQ[postDiracTensor] &&
        AllTrue[postDiracRows, ! MissingQ[#] &] &&
        SameQ[Total[postDiracRows], postDiracTensor],
      AssociateTo[processingAudit, tensorRole -> <|
        "KinematicRole" -> kinematicRole,
        "PolarizationSpecifications" -> specifications,
        "InputContentHash" -> inputContentHash,
        "InitialStateAverage" -> initialStateAverage,
        "CoherentRowCount" -> Length[postDiracRows],
        "RowContentHashes" -> (Hash[#, "SHA256"] & /@ postDiracRows),
        "PostDiracContentHash" -> Hash[postDiracTensor, "SHA256"],
        "FinalContentHash" -> Hash[finalTensor, "SHA256"],
        "RowsSummedBeforeColorAndAverage" ->
          SameQ[Total[postDiracRows], postDiracTensor],
        "CacheReused" -> True
      |>];
      Return[finalTensor],
      Print[
        "S06_STAGE: real final/aggregate/row cache layers are " <>
          "inconsistent; invalidating aggregate layers"
      ];
      deleteCacheIfPresent[paths["Final"]];
      deleteCacheIfPresent[paths["PostDirac"]]
    ]
  ];

  postDiracTensor = loadValidatedCache[
    paths["PostDirac"], tensorRole, "PostDirac",
    aggregateProvenance
  ];
  If[! MissingQ[postDiracTensor],
    postDiracRows = MapIndexed[
      Function[{amplitudeBlock, position},
        rowRole = tensorRole <> "PhysicalRow" <>
          IntegerString[First[position], 10, 2];
        rowPath = paths["PhysicalRowsPostDirac"][[First[position]]];
        rowInputHash = Hash[
          {amplitudeBlock, totalConjugate},
          "SHA256"
        ];
        rowProvenance = cacheProvenanceFor[
          rowRole, kinematicRole, specifications,
          rowInputHash, First[position]
        ];
        loadValidatedCache[
          rowPath, rowRole, "PostDirac", rowProvenance
        ]
      ],
      amplitudeBlocks
    ];
    If[
      ! AllTrue[postDiracRows, ! MissingQ[#] &] ||
        ! SameQ[Total[postDiracRows], postDiracTensor],
      Print[
        "S06_STAGE: aggregate real cache has incomplete or unequal " <>
          "row dependencies; invalidating the aggregate"
      ];
      deleteCacheIfPresent[paths["PostDirac"]];
      postDiracTensor = Missing["InconsistentCache"]
    ]
  ];
  If[MissingQ[postDiracTensor],
    postDiracRows = MapIndexed[
      Function[{amplitudeBlock, position},
        rowRole = tensorRole <> "PhysicalRow" <>
          IntegerString[First[position], 10, 2];
        rowPath = paths["PhysicalRowsPostDirac"][[First[position]]];
        rowInputHash = Hash[
          {amplitudeBlock, totalConjugate},
          "SHA256"
        ];
        rowProvenance = cacheProvenanceFor[
          rowRole, kinematicRole, specifications,
          rowInputHash, First[position]
        ];
        rowExpression = loadValidatedCache[
          rowPath, rowRole, "PostDirac", rowProvenance
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
            specifications
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
            rowPath, rowRole, "PostDirac",
            rowProvenance, rowExpression
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
      paths["PostDirac"], tensorRole, "PostDirac",
      aggregateProvenance, postDiracTensor
    ]
  ];

  Print[
    "S06_STAGE: summing colors and applying incoming-quark average for " <>
      label
  ];
  finalTensor = CheckAbort[
    Quiet@Check[
      FeynCalc`SUNSimplify[
        postDiracTensor initialStateAverage,
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
    paths["Final"], tensorRole, "Final",
    aggregateProvenance, finalTensor
  ];
  Print[
    "S06_CHECKPOINT: " <> tensorRole <> " physical final leaf count " <>
      ToString[LeafCount[finalTensor]]
  ];
  AssociateTo[processingAudit, tensorRole -> <|
    "KinematicRole" -> kinematicRole,
    "PolarizationSpecifications" -> specifications,
    "InputContentHash" -> inputContentHash,
    "InitialStateAverage" -> initialStateAverage,
    "CoherentRowCount" -> Length[postDiracRows],
    "RowContentHashes" -> (Hash[#, "SHA256"] & /@ postDiracRows),
    "PostDiracContentHash" -> Hash[postDiracTensor, "SHA256"],
    "FinalContentHash" -> Hash[finalTensor, "SHA256"],
    "RowsSummedBeforeColorAndAverage" ->
      SameQ[Total[postDiracRows], postDiracTensor],
    "CacheReused" -> False
  |>];
  finalTensor
];

Print["S06_STAGE: processing all Hqg bilinears"];

loTensor = processBilinear[
  loBilinear,
  polarizationSpecifications["LO"],
  setTwoBodyKinematics,
  "TwoBody",
  "LO",
  "Hqg LO square",
  cachePaths["LO"],
  inputContentHashes["LO"]
];

realQGTensor = processPhysicalRealBlocks[
  realQGAmplitudeBlocks,
  realQGConjugateBlocks,
  setThreeBodyKinematics,
  "ThreeBody",
  polarizationSpecifications["RealQG"],
  "RealQG",
  "Hqg;qg real square",
  cachePaths["RealQG"],
  inputContentHashes["RealQG"]
];

virtualInterferenceTensorSymbolic = processBilinear[
  virtualInterferenceBilinear,
  polarizationSpecifications["VirtualInterference"],
  setTwoBodyKinematics,
  "TwoBody",
  "VirtualInterference",
  "Hqg LO-virtual interference",
  cachePaths["VirtualInterference"],
  inputContentHashes["VirtualInterference"]
];

outputTensors = <|
  "LO" -> loTensor,
  "RealQG" -> realQGTensor,
  "VirtualInterference" -> virtualInterferenceTensorSymbolic
|>;
allOutputTensors = Values[outputTensors];
outputTensorValidationGate = And @@ (
  validateSummedTensor[#, "final Hqg output tensor"] & /@
    allOutputTensors
);
assert[outputTensorValidationGate,
  "At least one final Hqg tensor failed validation."];
virtualCountertermsRetainedGate =
  ! FreeQ[virtualInterferenceTensorSymbolic, dZq1] &&
    ! FreeQ[virtualInterferenceTensorSymbolic, dZGG1] &&
    ! FreeQ[virtualInterferenceTensorSymbolic, dZgs1];
assert[virtualCountertermsRetainedGate,
  "The final virtual tensor lost symbolic QCD counterterms."];

tensorRoleGate = Keys[outputTensors] === Keys[inputTensorRoles];
allPolarizationsSummedGate = FreeQ[
  allOutputTensors,
  _FeynCalc`Polarization
];
allQuarkSpinsSummedGate = FreeQ[
  allOutputTensors,
  _FeynCalc`Spinor
];
allDiracTracesEvaluatedGate = FreeQ[
  allOutputTensors,
  _FeynCalc`DiracTrace | _FeynCalc`DiracGamma
];
allColorsSummedGate = FreeQ[
  allOutputTensors,
  _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex
];
photonPolarizationNotSummedGate = FreeQ[
  allOutputTensors,
  FeynCalc`Polarization[q, ___]
];
photonIndexMuGate = AllTrue[
  allOutputTensors,
  ! FreeQ[#, FeynCalc`LorentzIndex[s05Mu, D]] &
];
photonIndexNuGate = AllTrue[
  allOutputTensors,
  ! FreeQ[#, FeynCalc`LorentzIndex[s05Nu, D]] &
];
masslessVectorQCDGate =
  ! FreeQ[virtualInterferenceBilinear, dZq1] &&
    FreeQ[virtualInterferenceBilinear, _dZfL1 | _dZfR1] &&
    virtualCountertermsRetainedGate;
virtualSquareExcludedGate =
  ! KeyExistsQ[s05["Bilinears"], "NLOVirtualSquare_OAlphaS2"] &&
    ! KeyExistsQ[s05["Bilinears"], "NLOVirtualSquare"];
calculationFullySymbolicGate = FreeQ[
  allOutputTensors,
  $Failed | FeynCalc`ComplexConjugate | FeynCalc`TID |
    _FeynArts`FCGV | _Real
];
stateAverageApplicationGate =
  initialStateNormalizationGate &&
    Keys[processingAudit] === Keys[outputTensors] &&
    AllTrue[
      Values[processingAudit],
      Lookup[#, "InitialStateAverage", Missing["Absent"]] ===
        initialStateAverage &
    ];
realRowProcessingGate =
  processingAudit["RealQG", "CoherentRowCount"] ===
      realCoherentRowCount &&
    Length[processingAudit["RealQG", "RowContentHashes"]] ===
      realCoherentRowCount &&
    TrueQ[
      processingAudit[
        "RealQG", "RowsSummedBeforeColorAndAverage"
      ]
    ];
realAxialReferenceGate =
  realPhysicalAxialConventionGate &&
    threeBodyKinematicInstallationAudit["InstalledExactly"] === True &&
    FeynCalc`SPD[p, p] === 0;
singleGluonWardProtectedConventionGate =
  singleGluonCovariantConventionGate &&
    TrueQ[
      s05["Checks", "FragmentingGluonPolarizationRetained"]
    ] &&
    loGluonMomenta === virtualGluonMomenta;
cacheBindingGate =
  AllTrue[expectedCachePaths, FileExistsQ] &&
    AllTrue[
      Lookup[cacheAudit, expectedCachePaths, False],
      TrueQ
    ] &&
    FileNames["s06_cache*.tmp.*", scriptDirectory] === {};

s06Checks = <|
  "AcceptedS05SourceAndResultIdentity" -> s05IdentityGate,
  "CompleteCheckedS05Schema" -> sourceSchemaGate,
  "EmbeddedRepairedS01S04Lineage" -> embeddedLineageGate,
  "PaperReferenceHashPreserved" -> paperReferenceGate,
  "BigTMDChannel3CaseAEnforced" -> bigTMDConventionGate,
  "ChargeStrippedHardKernelConventionPreserved" ->
    chargeConventionGate,
  "FragmentingGluonIsK1" -> fragmentingPartonGate,
  "DiagramAndOrderedPairLedgersDerived" -> countLedgerGate,
  "RealBlockCountMatchesGeneratedLedger" -> realBlockCountGate,
  "RealFinalStateMomentaDerivedInInvariantOrder" ->
    realExternalStateMomentumGate,
  "ExpectedTensorRolesProcessed" -> tensorRoleGate,
  "TwoBodyInertKinematicsAccepted" -> twoBodyKinematicRecordGate,
  "ThreeBodyKinematicsToolDerived" -> threeBodyKinematicRecordGate,
  "LOFragmentingGluonPolarizationSummed" ->
    (allPolarizationsSummedGate && loGluonMomenta === {k1}),
  "RealFragmentingAndUnobservedGluonPolarizationsSummed" ->
    (allPolarizationsSummedGate && realGluonMomenta === {k1, k3}),
  "RealFinalGluonsUseDMinus2PhysicalAxialSums" ->
    realAxialReferenceGate,
  "RealPhysicalSumUsesDerivedResumableCoherentRows" ->
    realRowProcessingGate,
  "VirtualFragmentingGluonPolarizationSummed" ->
    (allPolarizationsSummedGate && virtualGluonMomenta === {k1}),
  "SingleGluonCovariantSumsUseAcceptedWardProtectedConvention" ->
    singleGluonWardProtectedConventionGate,
  "IncomingAndFinalQuarkSpinsSummed" -> allQuarkSpinsSummedGate,
  "AllDiracTracesEvaluated" -> allDiracTracesEvaluatedGate,
  "AllColorsSummed" -> allColorsSummedGate,
  "InitialStateNormalizationToolDerived" ->
    initialStateNormalizationGate,
  "InitialStateAverageAppliedToEveryBranch" ->
    stateAverageApplicationGate,
  "PhotonPolarizationNotSummed" -> photonPolarizationNotSummedGate,
  "PhotonIndexMuPreserved" -> photonIndexMuGate,
  "PhotonIndexNuPreserved" -> photonIndexNuGate,
  "MasslessVectorQCDFieldRenormalizationApplied" ->
    masslessVectorQCDGate,
  "VirtualCountertermsRetained" ->
    virtualCountertermsRetainedGate,
  "VirtualSquareStillExcluded" -> virtualSquareExcludedGate,
  "CalculationFullySymbolic" -> calculationFullySymbolicGate,
  "AllCachesBoundToFullProvenance" -> cacheBindingGate,
  "AllFinalTensorsValidated" -> outputTensorValidationGate
|>;
assert[AllTrue[Values[s06Checks], TrueQ],
  "At least one computed S06 validation gate is not True."];

s06Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg LO, Hqg;qg real, and Hqg;q virtual spin/color-averaged tensors",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ProgramSHA256Hex" -> sha256Hex[programPath],
  "SourceProgram" -> s05SourcePath,
  "SourceProgramSHA256" -> FileHash[s05SourcePath, "SHA256"],
  "SourceProgramSHA256Hex" -> s05SourceSHA256Hex,
  "SourceResult" -> s05Path,
  "SourceResultSHA256" -> s05SHA256,
  "SourceResultSHA256Hex" -> s05ResultSHA256Hex,
  "SourceLineage" -> s05SourceResults,
  "ReferencePDFSHA256" ->
    s05SourceResults["ReferencePDFSHA256"],
  "BigTMDConvention" -> s05["BigTMDConvention"],
  "ElectricChargeNormalization" -> s05["ElectricChargeNormalization"],
  "BigTMDComparisonStatus" ->
    "Deferred: S06 tensors are unprojected, unintegrated, and unsubtracted; finite Pg/Ppp fchn3A comparison belongs after projection, phase space, infrared combination, and factorization.",
  "PhotonIndices" -> s05["PhotonIndices"],
  "InitialState" -> "quark q(p)",
  "FragmentingParton" ->
    s05[
      "ExternalProcessOrganization", "NLOReal", "FragmentingParton"
    ],
  "InitialStateAverage" -> initialStateAverage,
  "InitialSpinStates" -> initialSpinStates,
  "InitialColorStates" -> initialColorStates,
  "InitialStateNormalizationDerivation" -> initialStateNormalization,
  "InputContentHashes" -> inputContentHashes,
  "DiagramCounts" -> s05DiagramCounts,
  "RealCoherentRowCount" -> realCoherentRowCount,
  "RealFinalStateMomenta" -> threeBodyFinalMomenta,
  "PolarizationSumSpecifications" -> polarizationSpecifications,
  "PolarizationSumConvention" ->
    "For Hqg;qg, each final gluon uses the D-dimensional axial projector with lightlike auxiliary p, summing only D-2 physical states. The one-gluon LO and virtual tensors use the covariant -g^(rho sigma) shortcut under their exact Ward identity. No incoming-quark or photon polarization sum is applied.",
  "KinematicConventions" -> <|
    "TwoBody" -> twoBodyKinematicRecord,
    "ThreeBody" -> threeBodyKinematicRecord
  |>,
  "KinematicInstallationAudits" -> <|
    "TwoBody" -> twoBodyKinematicInstallationAudit,
    "ThreeBody" -> threeBodyKinematicInstallationAudit
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
  "ProcessingAudit" -> processingAudit,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "SourceS05ProgramSHA256" -> FileHash[s05SourcePath, "SHA256"],
    "SourceS05SHA256" -> s05SHA256,
    "ProgramSHA256" -> programSHA256,
    "Paths" -> cachePaths,
    "CommonProvenance" -> commonCacheProvenance,
    "ValidatedPaths" -> cacheAudit,
    "EveryCacheBoundToFullProvenance" -> cacheBindingGate
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

resultTemporaryPath = resultPath <> ".tmp." <> ToString[$ProcessID];
If[FileExistsQ[resultTemporaryPath], DeleteFile[resultTemporaryPath]];
Print["S06_STAGE: atomically writing " <> resultPath];
Put[s06Result, resultTemporaryPath];
assert[
  FileExistsQ[resultTemporaryPath] &&
    FileByteCount[resultTemporaryPath] > 0,
  "The temporary s06_result file was not created correctly."
];
temporaryResultReload = Quiet@Check[Get[resultTemporaryPath], $Failed];
assert[SameQ[temporaryResultReload, s06Result],
  "The temporary s06_result failed exact reload validation."];
RenameFile[resultTemporaryPath, resultPath, OverwriteTarget -> True];
assert[FileExistsQ[resultPath], "The s06_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s06_result file is empty."];
finalResultReload = Quiet@Check[Get[resultPath], $Failed];
assert[SameQ[finalResultReload, s06Result],
  "The published s06_result failed exact reload validation."];
assert[! FileExistsQ[resultTemporaryPath],
  "The temporary s06_result survived atomic publication."];

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

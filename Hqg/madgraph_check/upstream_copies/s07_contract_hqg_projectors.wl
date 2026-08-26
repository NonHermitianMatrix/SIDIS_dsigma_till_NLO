(* ::Package:: *)

(*
  Contract the accepted Hqg S06 spin/color-averaged tensors with the two
  extraction tensors defined in Eq. (7) of the reference paper. This stage
  remains exact, D dimensional, scalar, unintegrated, and unsubtracted.
  Eq. (9) structure-function combinations remain explicitly downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  assert, fatal, sha256Hex, artifactIdentity,
  installMassShellAssignments, installScalarProductAssignments,
  installKinematicRecord, kinematicRecordValidQ,
  validateInputTensor, scalarProjectionValidQ, validateScalarProjection,
  expectedProvenanceFor, cacheMetadataValidQ, deleteCacheIfPresent,
  loadValidatedCache, writeValidatedCache, contractProjection,
  contractBothProjectors
];

fatal[message_String] := (
  Print["S07_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

sha256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

artifactIdentity[path_String] := If[
  FileExistsQ[path],
  <|
    "SHA256Hex" -> sha256Hex[path],
    "ByteCount" -> FileByteCount[path]
  |>,
  Missing["Absent"]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
programSHA256Hex = sha256Hex[programPath];
s06ProgramPath = FileNameJoin[{
  scriptDirectory, "s06_spin_color_sum_average_hqg.wl"
}];
s06Path = FileNameJoin[{scriptDirectory, "s06_result"}];
referencePDFPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
resultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
stageVersion = "HqgS07-v5";
preflightOnlyQ = Environment["HQG_S07_PREFLIGHT_ONLY"] === "1";

acceptedS06ProgramSHA256Hex =
  "d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6";
acceptedS06ResultSHA256Hex =
  "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55";
acceptedS05ProgramSHA256Hex =
  "750707b417051fa9380772702fc7737f1f659fa160df285186ee82562b8d0e74";
acceptedS05ResultSHA256Hex =
  "ab5d6e6ff2513c19ecdbe4f95c72de79bbf1d1b3724803db22fc5526c5e21878";
acceptedSourceLineageHex = <|
  "S01SourceSHA256Hex" ->
    "8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0",
  "S01ResultSHA256Hex" ->
    "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198",
  "S04SourceSHA256Hex" ->
    "ad6c5fd46152805538d1234c787feae212a9f5aa217853d7e81b4818bb567e54",
  "S04ResultSHA256Hex" ->
    "2bbeeee841e5e47bfd2391a1588b2184a16865d334bf78716b1b0573d499bf92"
|>;
lineageFileBindings = {
  {"S01Source", "S01SourceSHA256Hex"},
  {"S01", "S01ResultSHA256Hex"},
  {"S04Source", "S04SourceSHA256Hex"},
  {"S04", "S04ResultSHA256Hex"}
};

cachePaths = <|
  "LO" -> <|
    "Pg" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_lo_g"}],
    "PPP" -> FileNameJoin[{scriptDirectory, "s07_cache_hqg_lo_pp"}]
  |>,
  "RealQG" -> <|
    "Pg" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_real_qg_g"
    }],
    "PPP" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_real_qg_pp"
    }]
  |>,
  "VirtualInterference" -> <|
    "Pg" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_virtual_interference_g"
    }],
    "PPP" -> FileNameJoin[{
      scriptDirectory, "s07_cache_hqg_virtual_interference_pp"
    }]
  |>
|>;

cacheSpecifications = Flatten[
  KeyValueMap[
    Function[{tensorRole, projectorAssociation},
      KeyValueMap[
        Function[{projectorName, path},
          <|
            "TensorRole" -> tensorRole,
            "Projector" -> projectorName,
            "Path" -> path
          |>
        ],
        projectorAssociation
      ]
    ],
    cachePaths
  ],
  1
];
expectedCachePaths = Lookup[cacheSpecifications, "Path"];
s07ArtifactPaths = Append[expectedCachePaths, resultPath];
initialArtifactSnapshot = AssociationMap[
  artifactIdentity,
  s07ArtifactPaths
];

Print["S07_STAGE: loading exact accepted Hqg S06 result"];
assert[FileExistsQ[s06ProgramPath], "The accepted S06 program is absent."];
assert[FileExistsQ[s06Path], "The accepted s06_result is absent."];
assert[FileExistsQ[referencePDFPath], "The reference paper is absent."];

s06 = Quiet@Check[Get[s06Path], $Failed];
requiredS06Keys = {
  "Status", "Stage", "Channel", "Program", "ProgramSHA256",
  "ProgramSHA256Hex", "SourceProgram", "SourceProgramSHA256Hex",
  "SourceResult", "SourceResultSHA256Hex", "SourceLineage",
  "ReferencePDFSHA256", "BigTMDConvention",
  "ElectricChargeNormalization", "PhotonIndices", "InitialState",
  "FragmentingParton", "InitialStateAverage", "InitialSpinStates",
  "InitialColorStates", "InitialStateNormalizationDerivation",
  "RealFinalStateMomenta", "KinematicConventions",
  "SpinColorAveragedTensors", "VirtualRenormalizationStatus",
  "Checks"
};
sourceSchemaGate =
  AssociationQ[s06] &&
    AllTrue[requiredS06Keys, KeyExistsQ[s06, #] &] &&
    s06["Status"] === "Complete" &&
    s06["Stage"] === "HqgS06-v4" &&
    s06["Channel"] === "Hqg only" &&
    AssociationQ[s06["Checks"]] &&
    AllTrue[Values[s06["Checks"]], TrueQ];
assert[sourceSchemaGate,
  "s06_result does not satisfy the complete accepted S06 schema."];

s06ResultSHA256 = FileHash[s06Path, "SHA256"];
s06ResultSHA256Hex = sha256Hex[s06Path];
s06ProgramSHA256 = FileHash[s06ProgramPath, "SHA256"];
s06ProgramSHA256Hex = sha256Hex[s06ProgramPath];
s06IdentityGate =
  s06ProgramSHA256Hex === acceptedS06ProgramSHA256Hex &&
    s06ResultSHA256Hex === acceptedS06ResultSHA256Hex &&
    s06["Program"] === s06ProgramPath &&
    s06["ProgramSHA256"] === s06ProgramSHA256 &&
    s06["ProgramSHA256Hex"] === s06ProgramSHA256Hex &&
    s06["SourceProgramSHA256Hex"] ===
      acceptedS05ProgramSHA256Hex &&
    s06["SourceResultSHA256Hex"] === acceptedS05ResultSHA256Hex;
assert[s06IdentityGate,
  "The S06 source/result identity is not the accepted immutable pair."];

s06SourceLineage = s06["SourceLineage"];
lineageHexGate =
  AssociationQ[s06SourceLineage] &&
    And @@ KeyValueMap[
      Lookup[s06SourceLineage, #1, Missing["Absent"]] === #2 &,
      acceptedSourceLineageHex
    ];
lineageFilesCurrentGate = And @@ (
  Function[binding,
    With[{
      path = Lookup[
        s06SourceLineage, First[binding], Missing["Absent"]
      ],
      expectedHex = Lookup[
        acceptedSourceLineageHex, Last[binding], Missing["Absent"]
      ]
    },
      StringQ[path] && FileExistsQ[path] &&
        sha256Hex[path] === expectedHex
    ]
  ] /@ lineageFileBindings
);
s05FilesCurrentGate =
  StringQ[s06["SourceProgram"]] &&
    FileExistsQ[s06["SourceProgram"]] &&
    sha256Hex[s06["SourceProgram"]] ===
      acceptedS05ProgramSHA256Hex &&
    StringQ[s06["SourceResult"]] &&
    FileExistsQ[s06["SourceResult"]] &&
    sha256Hex[s06["SourceResult"]] === acceptedS05ResultSHA256Hex;
embeddedLineageGate =
  lineageHexGate && lineageFilesCurrentGate && s05FilesCurrentGate;
assert[embeddedLineageGate,
  "The accepted S05/S01/S04 lineage embedded in S06 is stale."];

paperReferenceGate =
  IntegerQ[s06["ReferencePDFSHA256"]] &&
    FileHash[referencePDFPath, "SHA256"] ===
      s06["ReferencePDFSHA256"] &&
    s06SourceLineage["ReferencePDFSHA256"] ===
      s06["ReferencePDFSHA256"];
assert[paperReferenceGate,
  "The accepted reference-paper identity is not preserved."];

bigTMDConventionGate =
  AssociationQ[s06["BigTMDConvention"]] &&
    s06["BigTMDConvention", "ChannelNumber"] === 3 &&
    s06["BigTMDConvention", "ChargeCase"] === "A only";
assert[bigTMDConventionGate,
  "S06 is not bound to BigTMD Hqg channel 3, case A."];

electricChargeNormalization = s06["ElectricChargeNormalization"];
chargeConventionGate =
  AssociationQ[electricChargeNormalization] &&
    electricChargeNormalization["ReferenceCharge"] === Lookup[
      electricChargeNormalization["ModelChargeCoefficients"],
      "F" <> ToString[
        electricChargeNormalization["FeynArtsReferenceClass"]
      ],
      Missing["Absent"]
    ] &&
    Together[
      electricChargeNormalization["ReferenceCharge"] *
        electricChargeNormalization["AmplitudeStripFactor"]
    ] === 1 &&
    electricChargeNormalization[
      "BigTMDLuminosityAppliedDownstream"
    ] === "Sum_q e_q^2 f_q D_g";
assert[chargeConventionGate,
  "The corrected charge-stripped Hqg convention was not preserved."];

initialStateNormalization =
  s06["InitialStateNormalizationDerivation"];
initialSpinStates = initialStateNormalization["InitialSpinStates"];
initialColorStates = initialStateNormalization["InitialColorStates"];
initialStateAverage = initialStateNormalization["InitialStateAverage"];
initialStateNormalizationGate =
  AssociationQ[initialStateNormalization] &&
    TrueQ[initialStateNormalization["FermionHeadVerified"]] &&
    TrueQ[
      initialStateNormalization["FundamentalColorIndexVerified"]
    ] &&
    initialSpinStates =!= 0 && initialColorStates =!= 0 &&
    Together[
      initialStateAverage initialSpinStates initialColorStates
    ] === 1 &&
    initialStateAverage === s06["InitialStateAverage"] &&
    initialSpinStates === s06["InitialSpinStates"] &&
    initialColorStates === s06["InitialColorStates"] &&
    s06["InitialState"] === "quark q(p)" &&
    FreeQ[initialStateNormalization, _Real | _Missing];
assert[initialStateNormalizationGate,
  "The S06 incoming-state normalization is not tool-derived and exact."];

kinematicRecords = s06["KinematicConventions"];
twoBodyKinematicRecord = kinematicRecords["TwoBody"];
threeBodyKinematicRecord = kinematicRecords["ThreeBody"];

kinematicRecordValidQ[record_, expectedSchema_String] :=
  AssociationQ[record] &&
    record["SerializationSchema"] === expectedSchema &&
    TrueQ[record["UniqueExactSolution"]] &&
    Head[record["DefiningEquationsHeld"]] === HoldComplete &&
    Head[record["SolvedScalarProductsHeld"]] === HoldComplete &&
    ! FreeQ[record["DefiningEquationsHeld"], _FeynCalc`Pair] &&
    ! FreeQ[record["SolvedScalarProductsHeld"], _FeynCalc`Pair] &&
    ListQ[record["MassShellAssignments"]] &&
    ListQ[record["ScalarProductAssignments"]] &&
    AllTrue[
      Join[
        record["MassShellInstallationResiduals"],
        record["ScalarProductInstallationResiduals"],
        record["EquationResiduals"]
      ],
      SameQ[#, 0] &
    ] &&
    FreeQ[record, _Real | _Missing];

twoBodyKinematicRecordGate =
  AssociationQ[kinematicRecords] &&
    kinematicRecordValidQ[
      twoBodyKinematicRecord, "HqgS01Kinematics-v2"
    ];
threeBodyKinematicRecordGate =
  AssociationQ[kinematicRecords] &&
    kinematicRecordValidQ[
      threeBodyKinematicRecord, "HqgS06ThreeBodyKinematics-v1"
    ] &&
    threeBodyKinematicRecord["FinalMomenta"] ===
      s06["RealFinalStateMomenta"];
assert[twoBodyKinematicRecordGate && threeBodyKinematicRecordGate,
  "S06 does not carry both accepted inert kinematic records."];

installMassShellAssignments[assignments_List] := Scan[
  Function[entry,
    With[{
      momentum = Lookup[entry, "Momentum"],
      massSquared = Lookup[entry, "MassSquared"]
    },
      FeynCalc`SPD[momentum, momentum] = massSquared
    ]
  ],
  assignments
];

installScalarProductAssignments[assignments_List] := Scan[
  Function[entry,
    With[{
      momentum1 = Lookup[entry, "Momentum1"],
      momentum2 = Lookup[entry, "Momentum2"],
      value = Lookup[entry, "Value"]
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
    "An inherited inert kinematic record was not installed exactly."];
  audit
];

twoBodyInstallationAudit =
  installKinematicRecord[twoBodyKinematicRecord];
threeBodyInstallationAudit =
  installKinematicRecord[threeBodyKinematicRecord];
kinematicInstallationGate =
  TrueQ[twoBodyInstallationAudit["InstalledExactly"]] &&
    TrueQ[threeBodyInstallationAudit["InstalledExactly"]];
assert[kinematicInstallationGate,
  "At least one inherited kinematic record failed exact installation."];

twoBodyMassMomenta = Lookup[
  twoBodyKinematicRecord["MassShellAssignments"],
  "Momentum"
];
stateProbeMomenta = DeleteDuplicates@Cases[
  initialStateNormalization["SpinTraceProbe"],
  FeynCalc`Momentum[momentum_, D] :> momentum,
  Infinity
];
incomingMomentumCandidates = Select[
  stateProbeMomenta,
  MemberQ[twoBodyMassMomenta, #] &
];
incomingMomentumGate = Length[incomingMomentumCandidates] === 1;
assert[incomingMomentumGate,
  "The incoming momentum was not uniquely derived from the state probe."];
incomingMomentum = First[incomingMomentumCandidates];

realFinalStateMomenta = s06["RealFinalStateMomenta"];
fragmentingPartonGate =
  ListQ[realFinalStateMomenta] &&
    Length[realFinalStateMomenta] >= 1 &&
    s06["FragmentingParton"] === "g(k1)" &&
    First[realFinalStateMomenta] === k1;
assert[fragmentingPartonGate,
  "S06 does not preserve the fragmenting-gluon g(k1) convention."];
fragmentingMomentum = First[realFinalStateMomenta];

photonIndices = s06["PhotonIndices"];
photonIndexGate =
  ListQ[photonIndices] &&
    Length[photonIndices] === 2 &&
    DuplicateFreeQ[photonIndices] &&
    AllTrue[photonIndices, MatchQ[#, _Symbol] &];
assert[photonIndexGate,
  "The two open photon indices were not inherited uniquely from S06."];
{photonMu, photonNu} = photonIndices;

tensors = <|
  "LO" -> s06["SpinColorAveragedTensors", "LO_OAlphaS"],
  "RealQG" -> s06[
    "SpinColorAveragedTensors", "NLOReal_OAlphaS2", "Hqg;qg"
  ],
  "VirtualInterference" -> s06[
    "SpinColorAveragedTensors",
    "NLOVirtualInterference_OAlphaS2_Symbolic"
  ]
|>;
kinematicRoles = <|
  "LO" -> "TwoBody",
  "RealQG" -> "ThreeBody",
  "VirtualInterference" -> "TwoBody"
|>;

validateInputTensor[expr_, label_String] := Module[{gate},
  gate =
    expr =!= $Failed && expr =!= 0 &&
      ! FreeQ[expr, FeynCalc`LorentzIndex[photonMu, D]] &&
      ! FreeQ[expr, FeynCalc`LorentzIndex[photonNu, D]] &&
      FreeQ[
        expr,
        _FeynCalc`Spinor | _FeynCalc`Polarization |
          _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
          _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
          FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
      ];
  assert[gate, label <> " failed the accepted open-tensor contract."];
  gate
];

tensorRoleGate =
  Keys[tensors] === Keys[kinematicRoles] && Length[tensors] === 3;
inputTensorValidationGate =
  tensorRoleGate &&
    And @@ KeyValueMap[
      validateInputTensor[#2, "Hqg " <> #1 <> " input tensor"] &,
      tensors
    ];
assert[inputTensorValidationGate,
  "At least one accepted S06 tensor failed input validation."];
virtualInputCountertermGate =
  ! FreeQ[tensors["VirtualInterference"], dZq1] &&
    ! FreeQ[tensors["VirtualInterference"], dZGG1] &&
    ! FreeQ[tensors["VirtualInterference"], dZgs1];
assert[virtualInputCountertermGate,
  "The accepted virtual input lacks symbolic QCD counterterms."];

projectors = <|
  "Pg" -> FeynCalc`Pair[
    FeynCalc`LorentzIndex[photonMu, D],
    FeynCalc`LorentzIndex[photonNu, D]
  ],
  "PPP" -> Times[
    FeynCalc`Pair[
      FeynCalc`Momentum[incomingMomentum, D],
      FeynCalc`LorentzIndex[photonMu, D]
    ],
    FeynCalc`Pair[
      FeynCalc`Momentum[incomingMomentum, D],
      FeynCalc`LorentzIndex[photonNu, D]
    ]
  ]
|>;

projectorStructureGate =
  Keys[projectors] === {"Pg", "PPP"} &&
    ! FreeQ[projectors["Pg"], FeynCalc`LorentzIndex[photonMu, D]] &&
    ! FreeQ[projectors["Pg"], FeynCalc`LorentzIndex[photonNu, D]] &&
    FreeQ[projectors["Pg"], _FeynCalc`Momentum] &&
    ! FreeQ[
      projectors["PPP"],
      FeynCalc`Momentum[incomingMomentum, D]
    ] &&
    ! FreeQ[projectors["PPP"], FeynCalc`LorentzIndex[photonMu, D]] &&
    ! FreeQ[projectors["PPP"], FeynCalc`LorentzIndex[photonNu, D]] &&
    FreeQ[projectors, _Real | _Missing];
assert[projectorStructureGate,
  "The Eq. (7) Pg/PPP projectors were not built from inherited data."];

inputTensorContentHashes = Map[Hash[#, "SHA256"] &, tensors];
kinematicContentHashes = Map[Hash[#, "SHA256"] &, kinematicRecords];
projectorContentHashes = Map[Hash[#, "SHA256"] &, projectors];
initialStateNormalizationContentHash = Hash[
  initialStateNormalization, "SHA256"
];
photonIndexContentHash = Hash[photonIndices, "SHA256"];

commonCacheProvenance = <|
  "StageVersion" -> stageVersion,
  "S07Program" -> programPath,
  "S07ProgramSHA256" -> programSHA256,
  "S07ProgramSHA256Hex" -> programSHA256Hex,
  "S06Program" -> s06ProgramPath,
  "S06ProgramSHA256" -> s06ProgramSHA256,
  "S06ProgramSHA256Hex" -> s06ProgramSHA256Hex,
  "S06Result" -> s06Path,
  "S06ResultSHA256" -> s06ResultSHA256,
  "S06ResultSHA256Hex" -> s06ResultSHA256Hex,
  "S06SourceLineage" -> s06SourceLineage,
  "ReferencePDFSHA256" -> s06["ReferencePDFSHA256"],
  "BigTMDConvention" -> s06["BigTMDConvention"],
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "InitialStateNormalization" -> initialStateNormalization,
  "InitialStateNormalizationContentHash" ->
    initialStateNormalizationContentHash,
  "PhotonIndices" -> photonIndices,
  "PhotonIndexContentHash" -> photonIndexContentHash,
  "InputTensorContentHashes" -> inputTensorContentHashes,
  "KinematicContentHashes" -> kinematicContentHashes,
  "ProjectorContentHashes" -> projectorContentHashes
|>;

expectedProvenanceFor[
    tensorRole_String, projectorName_String
  ] := Module[{kinematicRole},
  kinematicRole = kinematicRoles[tensorRole];
  Join[
    commonCacheProvenance,
    <|
      "TensorRole" -> tensorRole,
      "KinematicRole" -> kinematicRole,
      "KinematicContentHash" ->
        kinematicContentHashes[kinematicRole],
      "InputTensorContentHash" ->
        inputTensorContentHashes[tensorRole],
      "Projector" -> projectorName,
      "ProjectorDefinition" -> projectors[projectorName],
      "ProjectorContentHash" -> projectorContentHashes[projectorName]
    |>
  ]
];

cacheSpecificationGate =
  Length[cacheSpecifications] === Length[tensors] Length[projectors] &&
    DuplicateFreeQ[expectedCachePaths] &&
    AllTrue[
      cacheSpecifications,
      KeyExistsQ[tensors, #["TensorRole"]] &&
        KeyExistsQ[projectors, #["Projector"]] &&
        DirectoryName[#["Path"]] === scriptDirectory &
    ];
assert[cacheSpecificationGate,
  "The six S07 cache paths are not unique and fully derived."];

preflightChecks = <|
  "AcceptedS06SourceAndResultIdentity" -> s06IdentityGate,
  "CompleteCheckedS06Schema" -> sourceSchemaGate,
  "EmbeddedAcceptedS05S01S04Lineage" -> embeddedLineageGate,
  "PaperReferenceHashPreserved" -> paperReferenceGate,
  "BigTMDChannel3CaseAEnforced" -> bigTMDConventionGate,
  "ChargeStrippedHardKernelConventionPreserved" -> chargeConventionGate,
  "InitialStateNormalizationToolDerived" ->
    initialStateNormalizationGate,
  "IncomingMomentumDerivedFromStateProbe" -> incomingMomentumGate,
  "FragmentingGluonIsInheritedK1" -> fragmentingPartonGate,
  "PhotonIndicesInheritedUniquely" -> photonIndexGate,
  "TwoBodyInertKinematicsAccepted" -> twoBodyKinematicRecordGate,
  "ThreeBodyInertKinematicsAccepted" -> threeBodyKinematicRecordGate,
  "InheritedKinematicsInstalledExactly" -> kinematicInstallationGate,
  "ThreeAcceptedInputTensorsValidated" -> inputTensorValidationGate,
  "VirtualInputCountertermsRetained" -> virtualInputCountertermGate,
  "PaperEq7ProjectorsBuiltFromInheritedData" -> projectorStructureGate,
  "SixUniqueContentBoundCacheSpecifications" -> cacheSpecificationGate,
  "ExactContentHashesComputed" ->
    (Keys[inputTensorContentHashes] === Keys[tensors] &&
      Keys[kinematicContentHashes] === Keys[kinematicRecords] &&
      Keys[projectorContentHashes] === Keys[projectors] &&
      AllTrue[
        Join[
          Values[inputTensorContentHashes],
          Values[kinematicContentHashes],
          Values[projectorContentHashes],
          {initialStateNormalizationContentHash, photonIndexContentHash}
        ],
        IntegerQ
      ])
|>;
assert[AllTrue[Values[preflightChecks], TrueQ],
  "At least one computed S07 preflight gate is not True."];

If[preflightOnlyQ,
  finalArtifactSnapshot = AssociationMap[
    artifactIdentity,
    s07ArtifactPaths
  ];
  noWriteGate =
    SameQ[initialArtifactSnapshot, finalArtifactSnapshot] &&
      FileNames["s07*.tmp.*", scriptDirectory] === {};
  assert[noWriteGate,
    "The S07 semantic preflight modified a result/cache artifact."];
  Print["S07_PREFLIGHT_CHECKS=", InputForm[preflightChecks]];
  Print["S07_PREFLIGHT_NO_WRITE=", InputForm[noWriteGate]];
  Print["HQG_S07_KINV2_PREFIX_PREFLIGHT_OK"];
  Quit[0]
];

scalarProjectionValidQ[expr_] :=
  expr =!= $Failed && expr =!= 0 &&
    FreeQ[expr, _FeynCalc`LorentzIndex] &&
    FreeQ[expr, FeynCalc`Contract] &&
    FreeQ[
      expr,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
        FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
    ];

validateScalarProjection[expr_, label_String] := Module[{gate},
  gate = scalarProjectionValidQ[expr];
  assert[gate, label <> " failed the exact scalar-output contract."];
  gate
];

cacheMetadataValidQ[
    cache_, tensorRole_String, projectorName_String
  ] :=
  AssociationQ[cache] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === tensorRole &&
    cache["Projector"] === projectorName &&
    cache["SourceS06ProgramSHA256Hex"] === s06ProgramSHA256Hex &&
    cache["SourceS06ResultSHA256Hex"] === s06ResultSHA256Hex &&
    cache["ProgramSHA256"] === programSHA256 &&
    cache["ProgramSHA256Hex"] === programSHA256Hex &&
    cache["Provenance"] ===
      expectedProvenanceFor[tensorRole, projectorName] &&
    cache["BigTMDChannel"] ===
      s06["BigTMDConvention", "ChannelNumber"] &&
    cache["BigTMDChargeCase"] ===
      s06["BigTMDConvention", "ChargeCase"] &&
    cache["ElectricChargeNormalization"] ===
      electricChargeNormalization &&
    cache["InitialStateAverage"] === initialStateAverage &&
    cache["FragmentingParton"] === s06["FragmentingParton"] &&
    KeyExistsQ[cache, "Expression"] &&
    IntegerQ[cache["ExpressionContentHash"]] &&
    cache["ExpressionContentHash"] ===
      Hash[cache["Expression"], "SHA256"] &&
    scalarProjectionValidQ[cache["Expression"]];

deleteCacheIfPresent[path_String] := If[
  FileExistsQ[path],
  DeleteFile[path]
];

cacheAudit = <||>;

loadValidatedCache[
    path_String, tensorRole_String, projectorName_String
  ] := Module[{cache, validMetadata},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print[
    "S07_STAGE: inspecting " <> tensorRole <> " " <>
      projectorName <> " cache"
  ];
  cache = Quiet@Check[Get[path], $Failed];
  validMetadata = cacheMetadataValidQ[
    cache, tensorRole, projectorName
  ];
  If[! TrueQ[validMetadata],
    Print[
      "S07_STAGE: deleting stale or invalid " <> tensorRole <> " " <>
        projectorName <> " cache"
    ];
    deleteCacheIfPresent[path];
    AssociateTo[cacheAudit, path -> <|
      "Validated" -> False,
      "DeletedAsStale" -> True,
      "Reused" -> False
    |>];
    Return[Missing["InvalidCache"]]
  ];
  AssociateTo[cacheAudit, path -> <|
    "Validated" -> True,
    "DeletedAsStale" -> False,
    "Reused" -> True,
    "ExpressionContentHash" -> cache["ExpressionContentHash"]
  |>];
  Print[
    "S07_STAGE: loading validated " <> tensorRole <> " " <>
      projectorName <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[
    path_String, tensorRole_String, projectorName_String, expr_
  ] := Module[{temporaryPath, cache, temporaryReload, finalReload},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> tensorRole,
    "Projector" -> projectorName,
    "SourceS06Program" -> s06ProgramPath,
    "SourceS06ProgramSHA256Hex" -> s06ProgramSHA256Hex,
    "SourceS06Result" -> s06Path,
    "SourceS06ResultSHA256Hex" -> s06ResultSHA256Hex,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "ProgramSHA256Hex" -> programSHA256Hex,
    "Provenance" -> expectedProvenanceFor[tensorRole, projectorName],
    "BigTMDChannel" -> s06["BigTMDConvention", "ChannelNumber"],
    "BigTMDChargeCase" -> s06["BigTMDConvention", "ChargeCase"],
    "ElectricChargeNormalization" -> electricChargeNormalization,
    "InitialStateAverage" -> initialStateAverage,
    "FragmentingParton" -> s06["FragmentingParton"],
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ExpressionContentHash" -> Hash[expr, "SHA256"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    tensorRole <> " " <> projectorName <>
      " temporary cache was not written."
  ];
  temporaryReload = Quiet@Check[Get[temporaryPath], $Failed];
  assert[SameQ[temporaryReload, cache],
    tensorRole <> " " <> projectorName <>
      " temporary cache failed exact reload validation."];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    tensorRole <> " " <> projectorName <>
      " cache was not finalized."];
  finalReload = Quiet@Check[Get[path], $Failed];
  assert[
    SameQ[finalReload, cache] &&
      cacheMetadataValidQ[finalReload, tensorRole, projectorName],
    tensorRole <> " " <> projectorName <>
      " published cache failed exact validation."
  ];
  assert[! FileExistsQ[temporaryPath],
    tensorRole <> " " <> projectorName <>
      " temporary cache survived publication."];
  AssociateTo[cacheAudit, path -> <|
    "Validated" -> True,
    "DeletedAsStale" -> False,
    "Reused" -> False,
    "ExpressionContentHash" -> cache["ExpressionContentHash"]
  |>]
];

contractProjection[
    tensor_, tensorRole_String, projectorName_String, label_String
  ] := Module[
  {answer, path, kinematicRole, installationAudit},
  path = cachePaths[tensorRole][projectorName];
  kinematicRole = kinematicRoles[tensorRole];
  installationAudit = installKinematicRecord[
    kinematicRecords[kinematicRole]
  ];
  assert[TrueQ[installationAudit["InstalledExactly"]],
    label <> " kinematics were not installed exactly."];
  answer = loadValidatedCache[path, tensorRole, projectorName];
  If[! MissingQ[answer], Return[answer]];
  Print[
    "S07_STAGE: contracting " <> label <> " with " <> projectorName
  ];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`Contract[projectors[projectorName] tensor],
      $Failed
    ],
    $Failed
  ];
  validateScalarProjection[
    answer, "Hqg " <> tensorRole <> " " <> projectorName <> " projection"
  ];
  writeValidatedCache[path, tensorRole, projectorName, answer];
  Print[
    "S07_CHECKPOINT: completed " <> tensorRole <> " " <>
      projectorName <> " leaf count " <> ToString[LeafCount[answer]]
  ];
  answer
];

contractBothProjectors[
    tensor_, tensorRole_String, label_String
  ] := AssociationMap[
  contractProjection[tensor, tensorRole, #, label] &,
  Keys[projectors]
];

Print["S07_STAGE: contracting all three accepted Hqg tensors"];
loProjections = contractBothProjectors[
  tensors["LO"], "LO", "Hqg LO square"
];
realQGProjections = contractBothProjectors[
  tensors["RealQG"], "RealQG", "Hqg;qg physical real square"
];
virtualProjections = contractBothProjectors[
  tensors["VirtualInterference"],
  "VirtualInterference",
  "Hqg LO-virtual interference"
];

projectionSets = <|
  "LO" -> loProjections,
  "RealQG" -> realQGProjections,
  "VirtualInterference" -> virtualProjections
|>;
allProjections = Flatten[Values /@ Values[projectionSets], 1];
expectedProjectionCount = Length[tensors] Length[projectors];
projectionShapeGate =
  Keys[projectionSets] === Keys[tensors] &&
    AllTrue[Values[projectionSets], AssociationQ] &&
    AllTrue[Values[projectionSets], Keys[#] === Keys[projectors] &] &&
    Length[allProjections] === expectedProjectionCount;
finalScalarValidationGate =
  projectionShapeGate && AllTrue[allProjections, scalarProjectionValidQ];
assert[finalScalarValidationGate,
  "At least one final S07 scalar projection failed validation."];

virtualCountertermGate =
  AllTrue[
    Values[virtualProjections],
    ! FreeQ[#, dZq1] && ! FreeQ[#, dZGG1] && ! FreeQ[#, dZgs1] &
  ];
assert[virtualCountertermGate,
  "At least one virtual projection lost a symbolic QCD counterterm."];

photonIndicesContractedGate =
  FreeQ[allProjections, FeynCalc`LorentzIndex[photonMu, D]] &&
    FreeQ[allProjections, FeynCalc`LorentzIndex[photonNu, D]];
noLorentzIndicesGate = FreeQ[allProjections, _FeynCalc`LorentzIndex];
dDimensionalGate = AllTrue[allProjections, ! FreeQ[#, D] &];
fullySymbolicGate = FreeQ[
  allProjections,
  $Failed | _Real | FeynCalc`ComplexConjugate | FeynCalc`TID |
    FeynCalc`Contract | _FeynCalc`Spinor | _FeynCalc`Polarization |
    _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
    _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex
];
eq9CombinationDeferredGate =
  Keys[projectors] === {"Pg", "PPP"} &&
    FreeQ[allProjections, F1 | F2 | P1 | P2];
phaseSpaceIntegrationDeferredGate = FreeQ[
  allProjections,
  _Integrate | _NIntegrate | _DiracDelta | _HeavisideTheta
];

finalCacheValidation = Association@Map[
  Function[specification,
    With[{
      tensorRole = specification["TensorRole"],
      projectorName = specification["Projector"],
      path = specification["Path"]
    },
      (tensorRole <> ":" <> projectorName) -> Module[{cache},
        cache = Quiet@Check[Get[path], $Failed];
        FileExistsQ[path] &&
          cacheMetadataValidQ[cache, tensorRole, projectorName] &&
          SameQ[
            cache["Expression"],
            projectionSets[tensorRole][projectorName]
          ]
      ]
    ]
  ],
  cacheSpecifications
];
cacheBindingGate =
  AllTrue[Values[finalCacheValidation], TrueQ] &&
    AllTrue[expectedCachePaths, KeyExistsQ[cacheAudit, #] &] &&
    FileNames["s07_cache*.tmp.*", scriptDirectory] === {};
assert[cacheBindingGate,
  "At least one final S07 cache failed full provenance validation."];

s07Checks = <|
  "AcceptedS06SourceAndResultIdentity" -> s06IdentityGate,
  "CompleteCheckedS06Schema" -> sourceSchemaGate,
  "EmbeddedAcceptedS05S01S04Lineage" -> embeddedLineageGate,
  "PaperReferenceHashPreserved" -> paperReferenceGate,
  "BigTMDChannel3CaseAEnforced" -> bigTMDConventionGate,
  "ChargeStrippedHardKernelConventionPreserved" -> chargeConventionGate,
  "InitialStateNormalizationToolDerived" ->
    initialStateNormalizationGate,
  "IncomingMomentumDerivedFromStateProbe" -> incomingMomentumGate,
  "FragmentingGluonIsInheritedK1" -> fragmentingPartonGate,
  "PhotonIndicesInheritedUniquely" -> photonIndexGate,
  "TwoBodyInertKinematicsAccepted" -> twoBodyKinematicRecordGate,
  "ThreeBodyInertKinematicsAccepted" -> threeBodyKinematicRecordGate,
  "InheritedKinematicsInstalledExactly" -> kinematicInstallationGate,
  "ThreeAcceptedInputTensorsValidated" -> inputTensorValidationGate,
  "BothPaperEq7ProjectorsAppliedToEveryTensor" -> projectionShapeGate,
  "ProjectionCountDerivedAndExact" ->
    (Length[allProjections] === expectedProjectionCount),
  "AllScalarProjectionsValidated" -> finalScalarValidationGate,
  "BothPhotonIndicesContracted" -> photonIndicesContractedGate,
  "NoLorentzIndicesRemain" -> noLorentzIndicesGate,
  "DDimensionalContractionsRetained" -> dDimensionalGate,
  "CalculationFullySymbolic" -> fullySymbolicGate,
  "VirtualQCDCountertermsPreserved" -> virtualCountertermGate,
  "Eq9F1F2CombinationsDeferred" -> eq9CombinationDeferredGate,
  "PhaseSpaceIntegrationDeferred" -> phaseSpaceIntegrationDeferredGate,
  "AllCachesBoundToFullContentProvenance" -> cacheBindingGate
|>;
assert[AllTrue[Values[s07Checks], TrueQ],
  "At least one computed final S07 validation gate is not True."];

leafCounts = Map[Map[LeafCount, #] &, projectionSets];
s07Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Accepted Hqg LO, Hqg;qg real, and Hqg;q virtual Eq. (7) Pg/PPP scalar projections",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ProgramSHA256Hex" -> programSHA256Hex,
  "SourceProgram" -> s06ProgramPath,
  "SourceProgramSHA256" -> s06ProgramSHA256,
  "SourceProgramSHA256Hex" -> s06ProgramSHA256Hex,
  "SourceResult" -> s06Path,
  "SourceResultSHA256" -> s06ResultSHA256,
  "SourceResultSHA256Hex" -> s06ResultSHA256Hex,
  "SourceLineage" -> s06SourceLineage,
  "ReferencePDFSHA256" -> s06["ReferencePDFSHA256"],
  "BigTMDConvention" -> s06["BigTMDConvention"],
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "InitialState" -> s06["InitialState"],
  "InitialStateNormalizationDerivation" -> initialStateNormalization,
  "InitialStateAverage" -> initialStateAverage,
  "FragmentingParton" -> s06["FragmentingParton"],
  "FragmentingMomentum" -> fragmentingMomentum,
  "PhotonIndices" -> photonIndices,
  "IncomingMomentum" -> incomingMomentum,
  "PaperProjectorContract" -> <|
    "ReferenceEquation" -> "Eq. (7)",
    "ProjectorNames" -> Keys[projectors],
    "StructureFunctionCombinationReference" -> "Eq. (9)",
    "StructureFunctionCombinationStatus" -> "Deferred"
  |>,
  "ProjectorDefinitions" -> projectors,
  "ProjectorContentHashes" -> projectorContentHashes,
  "KinematicConventions" -> kinematicRecords,
  "KinematicInstallationAudits" -> <|
    "TwoBody" -> twoBodyInstallationAudit,
    "ThreeBody" -> threeBodyInstallationAudit
  |>,
  "InputTensorContentHashes" -> inputTensorContentHashes,
  "ScalarProjections" -> <|
    "LO_OAlphaS" -> loProjections,
    "NLOReal_OAlphaS2" -> <|
      "Hqg;qg" -> realQGProjections
    |>,
    "NLOVirtualInterference_OAlphaS2_Symbolic" ->
      virtualProjections
  |>,
  "ProjectionCount" -> expectedProjectionCount,
  "ProjectionLeafCounts" -> leafCounts,
  "VirtualRenormalizationStatus" -> s06["VirtualRenormalizationStatus"],
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "CommonProvenance" -> commonCacheProvenance,
    "Paths" -> cachePaths,
    "Specifications" -> cacheSpecifications,
    "RunAudit" -> cacheAudit,
    "FinalValidation" -> finalCacheValidation,
    "EveryCacheBoundToFullContentProvenance" -> cacheBindingGate
  |>,
  "Checks" -> s07Checks,
  "NotPerformedAtThisStage" -> {
    "Eq. (9) P1/P2 linear combinations for F1/F2",
    "two- and three-body phase-space integration",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "real-virtual infrared cancellation",
    "PDF/FF collinear-factorization subtraction",
    "BigTMD cross-section/Jacobian/photon-spin normalization",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels"
  }
|>;

resultTemporaryPath = resultPath <> ".tmp." <> ToString[$ProcessID];
If[FileExistsQ[resultTemporaryPath], DeleteFile[resultTemporaryPath]];
Print["S07_STAGE: atomically writing " <> resultPath];
Put[s07Result, resultTemporaryPath];
assert[
  FileExistsQ[resultTemporaryPath] && FileByteCount[resultTemporaryPath] > 0,
  "The temporary s07_result file was not created correctly."
];
temporaryResultReload = Quiet@Check[Get[resultTemporaryPath], $Failed];
assert[SameQ[temporaryResultReload, s07Result],
  "The temporary s07_result failed exact reload validation."];
RenameFile[resultTemporaryPath, resultPath, OverwriteTarget -> True];
assert[FileExistsQ[resultPath], "The s07_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s07_result file is empty."];
finalResultReload = Quiet@Check[Get[resultPath], $Failed];
assert[SameQ[finalResultReload, s07Result],
  "The published s07_result failed exact reload validation."];
assert[! FileExistsQ[resultTemporaryPath],
  "The temporary s07_result survived atomic publication."];

Print["S07_SUCCESS"];
Print["S07_RESULT_PATH=" <> resultPath];
Print["S07_PROJECTION_COUNT=", s07Result["ProjectionCount"]];
Print["S07_LEAF_COUNTS=", InputForm[leafCounts]];
Print["S07_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S07_CHECKS=", InputForm[s07Checks]];

Quit[0];

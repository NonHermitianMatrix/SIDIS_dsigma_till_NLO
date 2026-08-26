(* ::Package:: *)

(*
  Hqg stage S08: apply the paper's fixed-observed-k1 phase-space operations
  to the six validated S07 scalar projections.

    1. Apply the two-body k2 phase space to LO and renormalized virtual
       Pg/PPP projections, writing the constraint as DiracDelta[s23].
       Expand propagators only for LO; preserve the validated symbolic
       virtual projections to avoid expanding on-shell counterterm placeholders.
    2. Integrate the sole real Hqg;qg Pg/PPP pair over the unobserved
       q(k2),g(k3) angles in D=4-2 epsilon using Appendices B and D.
    3. Apply Eqs. (29)-(32), replacing zeta by s23 with the exact Jacobian
       and physical xi/s23 limits.
    4. Prove the resulting zHat, Jacobian, s, t, and endpoint B maps are
       exactly the maps used by BigTMD channel 3A after PHT2=zH^2 qT^2.

  Endpoint distributions, Appendix-F expansions, real-virtual cancellation,
  Eq. (46) collinear factorization, and finite fchn3A comparison are deferred.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, sha256Hex, artifactIdentity, splitTerms,
  installMassShellAssignments, installScalarProductAssignments,
  installKinematicRecord, kinematicRecordValidQ,
  setTwoBodyKinematics, setThreeBodyKinematics, validateScalarInput,
  makeTwoBodyPair, discoverCanonicalDenominatorRules,
  makeRealExplicit, laurentPower, denominatorADMVs, presentADMVs,
  typeOfADMV, sameTypeOffender, reduceSameTypeTerms, affineVector,
  tripleUnityRelation, reduceTripleTerms, chooseBasis, basisRules,
  reduceNumerators, reduceAppendixD, linearCoefficients,
  reducedLinearCoefficients, frameMinkowskiDot, coefficientDot,
  masslessGeometry,
  case2Geometry, appendixB18, angularKeyAndCoefficient, masterFromKey,
  integrateReducedTerms, validateAngularExpression,
  expectedCacheProvenance, cacheMetadataValidQ, deleteCacheIfPresent,
  loadValidatedCache, writeValidatedCache, processRealProjection,
  validateProjectionPair, validateTwoBodyPair, transformPair,
  validateXiS23Pair, zeroCoefficientVectorQ,
  extractPythonAssignmentRHS, parseBigTMDExpression, S08Case2Master
];

fatal[message_String] := (
  Print["S08_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

sha256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

artifactIdentity[path_String] := If[
  FileExistsQ[path],
  <|"SHA256Hex" -> sha256Hex[path],
    "ByteCount" -> FileByteCount[path]|>,
  Missing["Absent"]
];

splitTerms[expression_] :=
  If[Head[expression] === Plus, List @@ expression, {expression}];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
programSHA256Hex = sha256Hex[programPath];
s07ProgramPath = FileNameJoin[{
  scriptDirectory, "s07_contract_hqg_projectors.wl"
}];
s07Path = FileNameJoin[{scriptDirectory, "s07_result"}];
referencePDFPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
resultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
stageVersion = "HqgS08-v5";
preflightOnlyQ = Environment["HQG_S08_PREFLIGHT_ONLY"] === "1";

acceptedS07ProgramSHA256Hex =
  "baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09";
acceptedS07ResultSHA256Hex =
  "c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6";
acceptedS06ProgramSHA256Hex =
  "d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6";
acceptedS06ResultSHA256Hex =
  "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55";

cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_pp"}]
|>;
expectedCachePaths = Values[cachePaths];
s08ArtifactPaths = Append[expectedCachePaths, resultPath];
initialArtifactSnapshot = AssociationMap[
  artifactIdentity,
  s08ArtifactPaths
];

Print["S08_STAGE: loading exact accepted Hqg S07-v5 result"];
assert[FileExistsQ[s07ProgramPath], "The accepted S07 source is absent."];
assert[FileExistsQ[s07Path], "The accepted s07_result is absent."];
assert[FileExistsQ[referencePDFPath], "The reference paper is absent."];
s07 = Quiet@Check[Get[s07Path], $Failed];

requiredS07Keys = {
  "Status", "Stage", "Channel", "Program", "ProgramSHA256",
  "ProgramSHA256Hex", "SourceProgram", "SourceProgramSHA256",
  "SourceProgramSHA256Hex", "SourceResult", "SourceResultSHA256",
  "SourceResultSHA256Hex", "SourceLineage", "ReferencePDFSHA256",
  "BigTMDConvention", "ElectricChargeNormalization", "InitialState",
  "InitialStateNormalizationDerivation", "InitialStateAverage",
  "FragmentingParton", "FragmentingMomentum", "PhotonIndices",
  "ProjectorDefinitions", "ProjectorContentHashes",
  "KinematicConventions", "KinematicInstallationAudits",
  "InputTensorContentHashes", "ScalarProjections", "ProjectionCount",
  "Checks"
};
sourceSchemaGate =
  AssociationQ[s07] &&
    AllTrue[requiredS07Keys, KeyExistsQ[s07, #] &] &&
    s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v5" &&
    s07["Channel"] === "Hqg only" &&
    AssociationQ[s07["Checks"]] &&
    AllTrue[Values[s07["Checks"]], TrueQ];
assert[sourceSchemaGate,
  "s07_result does not satisfy the complete accepted S07-v5 schema."];

s07ProgramSHA256 = FileHash[s07ProgramPath, "SHA256"];
s07ProgramSHA256Hex = sha256Hex[s07ProgramPath];
s07SHA256 = FileHash[s07Path, "SHA256"];
s07SHA256Hex = sha256Hex[s07Path];
s07IdentityGate =
  s07ProgramSHA256Hex === acceptedS07ProgramSHA256Hex &&
    s07SHA256Hex === acceptedS07ResultSHA256Hex &&
    s07["Program"] === s07ProgramPath &&
    s07["ProgramSHA256"] === s07ProgramSHA256 &&
    s07["ProgramSHA256Hex"] === s07ProgramSHA256Hex &&
    s07["SourceProgramSHA256Hex"] ===
      acceptedS06ProgramSHA256Hex &&
    s07["SourceResultSHA256Hex"] === acceptedS06ResultSHA256Hex &&
    FileExistsQ[s07["SourceProgram"]] &&
    sha256Hex[s07["SourceProgram"]] === acceptedS06ProgramSHA256Hex &&
    FileExistsQ[s07["SourceResult"]] &&
    sha256Hex[s07["SourceResult"]] === acceptedS06ResultSHA256Hex;
assert[s07IdentityGate,
  "The S07-v5 source/result or embedded S06 identity is stale."];

paperReferenceGate =
  IntegerQ[s07["ReferencePDFSHA256"]] &&
    FileHash[referencePDFPath, "SHA256"] ===
      s07["ReferencePDFSHA256"];
assert[paperReferenceGate,
  "The accepted reference-paper identity is not preserved."];

bigTMDConventionGate =
  AssociationQ[s07["BigTMDConvention"]] &&
    s07["BigTMDConvention", "ChannelNumber"] === 3 &&
    s07["BigTMDConvention", "ChargeCase"] === "A only";
assert[bigTMDConventionGate,
  "S07 is not bound to BigTMD Hqg channel 3, case A."];

electricChargeNormalization = s07["ElectricChargeNormalization"];
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
  "The corrected charge-stripped Hqg convention is stale."];

initialStateNormalization =
  s07["InitialStateNormalizationDerivation"];
stateAndFragmentingGate =
  AssociationQ[initialStateNormalization] &&
    Together[
      initialStateNormalization["InitialStateAverage"] *
        initialStateNormalization["InitialSpinStates"] *
        initialStateNormalization["InitialColorStates"]
    ] === 1 &&
    s07["InitialStateAverage"] ===
      initialStateNormalization["InitialStateAverage"] &&
    s07["InitialState"] === "quark q(p)" &&
    s07["FragmentingParton"] === "g(k1)" &&
    s07["FragmentingMomentum"] === k1 &&
    FreeQ[initialStateNormalization, _Real | _Missing];
assert[stateAndFragmentingGate,
  "S07 state normalization or fragmenting routing is invalid."];

projectorNames = Keys[s07["ProjectorDefinitions"]];
projectorLedgerGate =
  projectorNames === {"Pg", "PPP"} &&
    s07["ProjectorContentHashes"] === Map[
      Hash[#, "SHA256"] &,
      s07["ProjectorDefinitions"]
    ];
assert[projectorLedgerGate,
  "The accepted S07 projector ledger is invalid."];

bigTMDReferenceRoot = FileNameJoin[{
  scriptDirectory, "bigTMD_check", "BigTMD_reference"
}];
bigTMDNLODirectory = FileNameJoin[{bigTMDReferenceRoot, "NLO"}];
bigTMDSidisPath = FileNameJoin[{bigTMDReferenceRoot, "sidis.py"}];
chargeCaseToken = First@StringCases[
  s07["BigTMDConvention", "ChargeCase"],
  RegularExpression["[A-Z]"]
];
kernelFileName =
  "fchn" <>
    ToString[s07["BigTMDConvention", "ChannelNumber"]] <>
    chargeCaseToken <> ".py";
bigTMDProjectorDirectories = AssociationMap[
  Function[projectorName,
    Module[{candidates},
      candidates = Select[
        FileNames["*", bigTMDNLODirectory],
        DirectoryQ[#] &&
          ToLowerCase[FileNameTake[#]] ===
            ToLowerCase[projectorName] &
      ];
      assert[Length[candidates] === 1,
        "BigTMD projector directory routing is not unique."];
      First[candidates]
    ]
  ],
  projectorNames
];
bigTMDKernelPaths = Map[
  FileNameJoin[{#, kernelFileName}] &,
  bigTMDProjectorDirectories
];
bigTMDProjectorMapping = Map[
  StringRiffle[{
    "NLO", FileNameTake[DirectoryName[#]], FileBaseName[#]
  }, "."] &,
  bigTMDKernelPaths
];
bigTMDReferencePaths = Join[
  <|"sidis.py" -> bigTMDSidisPath|>,
  Association@KeyValueMap[
    ("Kernel:" <> #1) -> #2 &,
    bigTMDKernelPaths
  ]
];
bigTMDReferenceHashes = Map[sha256Hex, bigTMDReferencePaths];
bigTMDSidisText = Import[bigTMDSidisPath, "Text"];
dispatchLines = StringCases[
  bigTMDSidisText,
  RegularExpression[
    "(?m)^\\s*elif\\s+chn==" <>
      ToString[s07["BigTMDConvention", "ChannelNumber"]] <>
      "\\s+and\\s+case=='" <> chargeCaseToken <> "'.*$"
  ]
];
bigTMDRoutingGate =
  DirectoryQ[bigTMDReferenceRoot] &&
    FileExistsQ[bigTMDSidisPath] &&
    AllTrue[Values[bigTMDKernelPaths], FileExistsQ] &&
    Length[dispatchLines] === 1 &&
    AllTrue[
      Values[bigTMDProjectorMapping],
      StringContainsQ[First[dispatchLines], Last[StringSplit[#, "."]]] &
    ] &&
    AllTrue[Values[bigTMDReferenceHashes], StringQ[#] && StringLength[#] === 64 &];
assert[bigTMDRoutingGate,
  "The measured BigTMD channel/projector routing is stale or ambiguous."];

kinematicRecords = s07["KinematicConventions"];
twoBodyKinematicRecord = kinematicRecords["TwoBody"];
threeBodyKinematicRecord = kinematicRecords["ThreeBody"];

kinematicRecordValidQ[record_, schema_String] :=
  AssociationQ[record] &&
    record["SerializationSchema"] === schema &&
    TrueQ[record["UniqueExactSolution"]] &&
    Head[record["DefiningEquationsHeld"]] === HoldComplete &&
    Head[record["SolvedScalarProductsHeld"]] === HoldComplete &&
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

kinematicRecordGate =
  AssociationQ[kinematicRecords] &&
    kinematicRecordValidQ[
      twoBodyKinematicRecord, "HqgS01Kinematics-v2"
    ] &&
    kinematicRecordValidQ[
      threeBodyKinematicRecord, "HqgS06ThreeBodyKinematics-v1"
    ];
assert[kinematicRecordGate,
  "S07 does not preserve both accepted inert kinematic records."];

installMassShellAssignments[assignments_List] := Scan[
  Function[entry,
    With[{momentum = Lookup[entry, "Momentum"],
      value = Lookup[entry, "MassSquared"]},
      FeynCalc`SPD[momentum, momentum] = value
    ]
  ],
  assignments
];

installScalarProductAssignments[assignments_List] := Scan[
  Function[entry,
    With[{momentum1 = Lookup[entry, "Momentum1"],
      momentum2 = Lookup[entry, "Momentum2"],
      value = Lookup[entry, "Value"]},
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
      FeynCalc`SPD[Lookup[#, "Momentum"], Lookup[#, "Momentum"]] -
        Lookup[#, "MassSquared"]
    ] & /@ record["MassShellAssignments"];
  scalarResiduals = Together[
      FeynCalc`SPD[Lookup[#, "Momentum1"], Lookup[#, "Momentum2"]] -
        Lookup[#, "Value"]
    ] & /@ record["ScalarProductAssignments"];
  audit = <|
    "SerializationSchema" -> record["SerializationSchema"],
    "MassShellResiduals" -> massResiduals,
    "ScalarProductResiduals" -> scalarResiduals,
    "InstalledExactly" -> AllTrue[
      Join[massResiduals, scalarResiduals], SameQ[#, 0] &
    ]
  |>;
  assert[TrueQ[audit["InstalledExactly"]],
    "An inherited kinematic record did not install exactly."];
  audit
];

setTwoBodyKinematics[] :=
  installKinematicRecord[twoBodyKinematicRecord];
setThreeBodyKinematics[] :=
  installKinematicRecord[threeBodyKinematicRecord];
twoBodyInstallationAudit = setTwoBodyKinematics[];
threeBodyInstallationAudit = setThreeBodyKinematics[];
kinematicInstallationGate =
  TrueQ[twoBodyInstallationAudit["InstalledExactly"]] &&
    TrueQ[threeBodyInstallationAudit["InstalledExactly"]];
assert[kinematicInstallationGate,
  "Inherited two-/three-body kinematic installation failed."];

loInput = s07["ScalarProjections", "LO_OAlphaS"];
realQGInput = s07[
  "ScalarProjections", "NLOReal_OAlphaS2", "Hqg;qg"
];
virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];
inputPairs = <|
  "LO" -> loInput,
  "RealQG" -> realQGInput,
  "VirtualInterference" -> virtualInput
|>;

validateScalarInput[pair_Association, label_String] := Module[{gate},
  gate =
    Keys[pair] === projectorNames &&
      AllTrue[Values[pair], # =!= $Failed && # =!= 0 &] &&
      FreeQ[
        Values[pair],
        _FeynCalc`LorentzIndex | FeynCalc`Contract |
          _FeynCalc`Spinor | _FeynCalc`Polarization |
          _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
          _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
          FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
      ];
  assert[gate, label <> " failed the accepted scalar-pair contract."];
  gate
];

inputPairValidationGate = And @@ KeyValueMap[
  validateScalarInput[#2, "Hqg " <> #1 <> " input"] &,
  inputPairs
];
virtualInputCountertermGate =
  AllTrue[
    Values[virtualInput],
    ! FreeQ[#, dZq1] && ! FreeQ[#, dZGG1] && ! FreeQ[#, dZgs1] &
  ];
assert[inputPairValidationGate && virtualInputCountertermGate,
  "At least one accepted S07 input pair failed validation."];

inputContentHashes = Map[Hash[#, "SHA256"] &, inputPairs];
kinematicContentHashes = Map[Hash[#, "SHA256"] &, kinematicRecords];

paperOverallNormalization = 1/(2 Pi)^4;
paperTwoBodyMeasureFactor = 2 Pi DiracDelta[s23];
twoBodyPhaseFactor = Together[
  paperOverallNormalization paperTwoBodyMeasureFactor
];
paperThreeBodyMeasurePrefactor =
  s23^(-epsilon) 2^(-2 - epsilon) Pi^(-epsilon) *
    Gamma[1 - epsilon]/
      ((2 Pi)^(2 - 2 epsilon) Gamma[1 - 2 epsilon]);
threeBodyPhasePrefactor = Together[
  paperOverallNormalization paperThreeBodyMeasurePrefactor
];
paperEq38DirectPrefactor =
  s23^(-epsilon) 2^(-2 - epsilon) Pi^(-epsilon) *
    Gamma[1 - epsilon]/
      ((2 Pi)^(6 - 2 epsilon) Gamma[1 - 2 epsilon]);
phaseSpaceNormalizationGate =
  TrueQ[
    Together[
      twoBodyPhaseFactor -
        2 Pi DiracDelta[s23]/(2 Pi)^4
    ] === 0
  ] &&
    TrueQ[
      Together[
        threeBodyPhasePrefactor - paperEq38DirectPrefactor
      ] === 0
    ] &&
    ! TrueQ[
      Together[
        threeBodyPhasePrefactor -
          s23^(-epsilon) 2^(-2) Pi^(-epsilon) *
            Gamma[1 - epsilon]/
              ((2 Pi)^(6 - 2 epsilon) Gamma[1 - 2 epsilon])
      ] === 0
    ];
assert[phaseSpaceNormalizationGate,
  "The paper Eq. (19)/(34)/(38)/(39) normalization failed."];

makeTwoBodyPair[
    input_Association, label_String, expandPropagatorsQ_
  ] := Module[{answer},
  Print["S08_STAGE: applying two-body phase space to " <> label];
  If[TrueQ[expandPropagatorsQ], setTwoBodyKinematics[]];
  answer = Map[
    Function[projection,
      twoBodyPhaseFactor *
        ((If[
            TrueQ[expandPropagatorsQ],
            FeynCalc`FeynAmpDenominatorExplicit[projection],
            projection
          ]) /. D -> 4 - 2 epsilon)
    ],
    input
  ];
  answer
];

validateTwoBodyPair[
    pair_Association, label_String, requireExplicitQ_
  ] := Module[{gate},
  gate =
    Keys[pair] === projectorNames &&
      AllTrue[Values[pair], # =!= $Failed && # =!= 0 &] &&
      AllTrue[Values[pair], ! FreeQ[#, DiracDelta[s23]] &] &&
      FreeQ[
        Values[pair],
        D | Indeterminate | ComplexInfinity | _DirectedInfinity | _Real
      ] &&
      (! TrueQ[requireExplicitQ] ||
        FreeQ[
          Values[pair],
          _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
        ]);
  assert[gate, label <> " failed the exact two-body phase-space contract."];
  gate
];

admv = {t2, t3, u2, u3, s12, s13};
typeOfADMV[variable_] := Which[
  MemberQ[{t2, t3}, variable], "t",
  MemberQ[{u2, u3}, variable], "u",
  MemberQ[{s12, s13}, variable], "s",
  True, "none"
];

setThreeBodyKinematics[];
appendixDRearrangements = {
  {q - k1, k2 + k3 - p},
  {p - k1, k2 + k3 - q},
  {p + q, k1 + k2 + k3},
  {p + q - k2, k1 + k3}
};
appendixDResiduals = Together[
    FeynCalc`ExpandScalarProduct[
      FeynCalc`SPD[First[#]] - FeynCalc`SPD[Last[#]]
    ]
  ] & /@ appendixDRearrangements;
appendixDRelations = Thread[appendixDResiduals == 0];
globalMomentumConservationResidual = Together[
  FeynCalc`ExpandScalarProduct[
    FeynCalc`SPD[p + q - k1] - FeynCalc`SPD[k2 + k3]
  ]
];
q2ConstraintSolutions = Solve[
  globalMomentumConservationResidual == 0,
  Q2
];
assert[Length[q2ConstraintSolutions] === 1,
  "The global three-body invariant constraint did not solve uniquely."];
q2ConstraintRule = First[q2ConstraintSolutions];

relationVariables = {
  t2, t3, u2, u3, s12, s13, sHat, t1, u1, s23, Q2
};
kinematicReductionResiduals = Append[
  appendixDResiduals,
  globalMomentumConservationResidual
];
appendixDGroebnerBasis = GroebnerBasis[
  kinematicReductionResiduals,
  relationVariables
];
appendixDRelationGate =
  Length[appendixDResiduals] === 4 &&
    Length[kinematicReductionResiduals] === 5 &&
    AllTrue[
      kinematicReductionResiduals,
      PolynomialQ[#, relationVariables] &
    ] &&
    Length[appendixDGroebnerBasis] >= 5 &&
    FreeQ[kinematicReductionResiduals, _Real | _Missing];
assert[appendixDRelationGate,
  "The tool-derived Appendix-D relation system is incomplete."];

sameTypePairs = Values[GroupBy[admv, typeOfADMV]];
sameTypeData = Map[
  Function[pair,
    Module[{matchingResiduals, solution, constant},
      matchingResiduals = Select[
        appendixDResiduals,
        Sort@DeleteDuplicates@Cases[#, Alternatives @@ admv, Infinity] ===
          Sort[pair] &
      ];
      assert[Length[matchingResiduals] === 1,
        "A same-type Appendix-D relation was not uniquely derived."];
      solution = Solve[
        First[matchingResiduals] == 0,
        Last[pair]
      ];
      assert[Length[solution] === 1,
        "A same-type relation did not solve uniquely."];
      constant = Together[Total[pair] /. First[solution]];
      assert[FreeQ[constant, Alternatives @@ admv],
        "A same-type relation retained an ADMV."];
      {pair, constant}
    ]
  ],
  sameTypePairs
];

canonicalInvariantCandidates = {
  sHat, t1, u1, s23, t2, t3, u2, u3, s12, s13, Q2
};

discoverCanonicalDenominatorRules[
    projection_, label_String
  ] := Module[
  {explicit, bases, compositeBases, candidateMatches, rules},
  setThreeBodyKinematics[];
  explicit = FeynCalc`FeynAmpDenominatorExplicit[projection];
  bases = DeleteDuplicates@Cases[
    explicit,
    Power[base_, power_Integer] /; power < 0 :> base,
    Infinity
  ];
  compositeBases = Select[
    bases,
    ! MemberQ[canonicalInvariantCandidates, #] &&
      ! FreeQ[#, Alternatives @@ admv] &
  ];
  rules = Map[
    Function[base,
      candidateMatches = Select[
        canonicalInvariantCandidates,
        TrueQ[
          Last@PolynomialReduce[
            Expand[base - #],
            appendixDGroebnerBasis,
            relationVariables
          ] === 0
        ] &
      ];
      Print[
        "S08_DENOMINATOR_DISCOVERY: ", label,
        " base=", InputForm[base],
        " candidates=", InputForm[candidateMatches]
      ];
      assert[Length[candidateMatches] === 1,
        label <> " composite denominator lacks a unique invariant image."];
      base -> First[candidateMatches]
    ],
    compositeBases
  ];
  <|
    "NegativePowerBases" -> bases,
    "CompositeBases" -> compositeBases,
    "DerivedRules" -> rules,
    "EveryCompositeBaseMappedUniquely" ->
      (Length[rules] === Length[compositeBases])
  |>
];

denominatorDiscovery = AssociationMap[
  discoverCanonicalDenominatorRules[
    realQGInput[#], "Hqg;qg " <> #
  ] &,
  projectorNames
];
denominatorDiscoveryGate =
  AllTrue[
    Values[denominatorDiscovery],
    AssociationQ[#] &&
      TrueQ[# ["EveryCompositeBaseMappedUniquely"]] &&
      ListQ[# ["DerivedRules"]] &
  ];
assert[denominatorDiscoveryGate,
  "At least one Hqg real denominator discovery failed."];

makeRealExplicit[
    projection_, projectorName_String
  ] := Module[{answer, discovered},
  setThreeBodyKinematics[];
  answer = FeynCalc`FeynAmpDenominatorExplicit[projection];
  discovered = DeleteDuplicates@Cases[
    answer,
    Power[base_, power_Integer] /; power < 0 :> base,
    Infinity
  ];
  assert[
    SameQ[
      Sort[ToString[#, InputForm] & /@ discovered],
      Sort[
        ToString[#, InputForm] & /@
          denominatorDiscovery[projectorName, "NegativePowerBases"]
      ]
    ],
    projectorName <> " denominator inventory changed after discovery."
  ];
  answer = Together[
    answer /.
      denominatorDiscovery[projectorName, "DerivedRules"] /.
      D -> 4 - 2 epsilon
  ];
  Expand[answer]
];

laurentPower[term_, variable_] := Module[{factors},
  factors = If[Head[term] === Times, List @@ term, {term}];
  Total@Map[
    Function[factor,
      Which[
        factor === variable, 1,
        Head[factor] === Power && First[factor] === variable &&
          IntegerQ[Last[factor]], Last[factor],
        True, 0
      ]
    ],
    factors
  ]
];

denominatorADMVs[term_] :=
  Select[admv, laurentPower[term, #] < 0 &];

presentADMVs[term_] :=
  Select[admv, laurentPower[term, #] =!= 0 &];

sameTypeOffender[term_] := SelectFirst[
  sameTypeData,
  Function[data, And @@ (laurentPower[term, #] < 0 & /@ First[data])],
  Missing["NotFound"]
];

reduceSameTypeTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, offender},
  While[
    changed = AnyTrue[terms, ! MissingQ[sameTypeOffender[#]] &];
    changed,
    iteration++;
    assert[
      iteration <= 12,
      "Appendix D same-type reduction exceeded 12 iterations."
    ];
    terms = Flatten[
      Map[
        Function[term,
          offender = sameTypeOffender[term];
          If[
            MissingQ[offender],
            {term},
            splitTerms@Expand[term Total[First[offender]]/Last[offender]]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

affineVector[variable_] := Module[{coefficients},
  coefficients = reducedLinearCoefficients[variable];
  assert[
    ListQ[coefficients] && Length[coefficients] === 3,
    "The Frame-2 affine coefficient vector is malformed."
  ];
  {coefficients[[2]], coefficients[[3]], coefficients[[1]]}
];

tripleUnityRelation[variables_List] := Module[
  {vectors, nullVector, constant, lhs},
  assert[
    Length[variables] === 3,
    "A three-variable Appendix D relation was requested incorrectly."
  ];
  vectors = affineVector /@ variables;
  nullVector = First@NullSpace[Transpose[Take[#, 2] & /@ vectors]];
  lhs = Together[nullVector . variables];
  constant = Together[nullVector . (Last /@ vectors)];
  assert[
    ! TrueQ[constant === 0],
    "A three-variable Appendix D unity denominator vanished."
  ];
  {lhs, constant}
];

reduceTripleTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, variables, relation},
  While[
    changed = AnyTrue[terms, Length[denominatorADMVs[#]] > 2 &];
    changed,
    iteration++;
    assert[
      iteration <= 12,
      "Appendix D triple reduction exceeded 12 iterations."
    ];
    terms = Flatten[
      Map[
        Function[term,
          variables = denominatorADMVs[term];
          If[
            Length[variables] <= 2,
            {term},
            assert[
              Length[variables] === 3,
              "Same-type reduction left more than three denominator ADMVs."
            ];
            relation = tripleUnityRelation[variables];
            splitTerms@Expand[term First[relation]/Last[relation]]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

chooseBasis[term_] := Module[{variables, firstVariable, partner},
  variables = denominatorADMVs[term];
  Which[
    Length[variables] === 2,
      assert[
        typeOfADMV[First[variables]] =!= typeOfADMV[Last[variables]],
        "Two same-type denominator ADMVs survived Appendix D."
      ];
      variables,
    Length[variables] === 1,
      firstVariable = First[variables];
      partner = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &
      ];
      {firstVariable, partner},
    Length[variables] === 0,
      {t2, u2},
    True,
      fatal["chooseBasis received an unreduced term."]
  ]
];

basisRules[basis_List] := basisRules[basis] = Module[
  {eliminate, solution},
  eliminate = Complement[admv, basis];
  solution = Solve[appendixDRelations, eliminate];
  assert[
    Length[solution] >= 1,
    "Could not solve Appendix D relations for a numerator basis."
  ];
  First[solution]
];

reduceNumerators[inputTerms_List] := Flatten[
  Map[
    Function[term, splitTerms@Expand[term /. basisRules[chooseBasis[term]]]],
    inputTerms
  ],
  1
];

reduceAppendixD[expression_, label_String] := Module[
  {terms, afterSame, afterTriple, reduced, invalid},
  terms = splitTerms[Expand[expression]];
  Print[
    "S08_STAGE: Appendix D start " <> label <>
      ", terms " <> ToString[Length[terms]]
  ];
  afterSame = reduceSameTypeTerms[terms];
  Print[
    "S08_STAGE: Appendix D same-type complete " <> label <>
      ", terms " <> ToString[Length[afterSame]]
  ];
  afterTriple = reduceTripleTerms[afterSame];
  Print[
    "S08_STAGE: Appendix D triple complete " <> label <>
      ", terms " <> ToString[Length[afterTriple]]
  ];
  reduced = reduceNumerators[afterTriple];
  invalid = Select[
    reduced,
    Function[term,
      Length[presentADMVs[term]] > 2 ||
        (Length[presentADMVs[term]] === 2 &&
          typeOfADMV[First[presentADMVs[term]]] ===
            typeOfADMV[Last[presentADMVs[term]]])
    ]
  ];
  assert[
    invalid === {},
    label <> " did not reduce to two different ADMV types."
  ];
  Print[
    "S08_STAGE: Appendix D numerator complete " <> label <>
      ", terms " <> ToString[Length[reduced]]
  ];
  reduced
];

(* Appendix-B frame 2, generated from Eqs. (B5)-(B16). *)
frameMinkowskiDot[first_List, second_List] :=
  first[[1]] second[[1]] - Rest[first] . Rest[second];

frameP0 = (s23 - t1)/(2 Sqrt[s23]);
frameQ0 = (sHat + t1)/(2 Sqrt[s23]);
frameQMagnitude = Sqrt[frameQ0^2 + Q2];
frameK10 = -(s23 - sHat)/(2 Sqrt[s23]);
frameDiscriminant = Sqrt[s23 u1 (Q2 s23 + sHat t1)];
frameSinTheta2 =
  2 frameDiscriminant/((sHat - s23) (s23 - t1));
frameSinAlpha2 =
  2 frameDiscriminant/
    ((s23 - t1) Sqrt[4 Q2 s23 + (sHat + t1)^2]);

frameCosThetaSolutions = Solve[
  frameP0 frameK10 (1 - cosTheta2Symbol) == -u1/2,
  cosTheta2Symbol
];
frameCosAlphaSolutions = Solve[
  frameP0 (frameQ0 - frameQMagnitude cosAlpha2Symbol) ==
    (sHat + Q2)/2,
  cosAlpha2Symbol
];
frameCosineSolutionGate =
  Length[frameCosThetaSolutions] === 1 &&
    Length[frameCosAlphaSolutions] === 1;
assert[frameCosineSolutionGate,
  "The Frame-2 cosine equations did not solve uniquely."];
frameCosTheta2 =
  cosTheta2Symbol /. First[frameCosThetaSolutions];
frameCosAlpha2 =
  cosAlpha2Symbol /. First[frameCosAlphaSolutions];

frameP = {frameP0, 0, 0, frameP0};
frameQ = {
  frameQ0, 0,
  frameQMagnitude frameSinAlpha2,
  frameQMagnitude frameCosAlpha2
};
frameK1 = {
  frameK10, 0,
  frameK10 frameSinTheta2,
  frameK10 frameCosTheta2
};
frameK2 = Sqrt[s23]/2 *
  {1, 0, frameSinBetaCos, frameCosBeta};
frameK3 = Sqrt[s23]/2 *
  {1, 0, -frameSinBetaCos, -frameCosBeta};

frameInvariantExpressions = <|
  t2 -> Expand[-Q2 - 2 frameMinkowskiDot[frameQ, frameK2]],
  t3 -> Expand[-Q2 - 2 frameMinkowskiDot[frameQ, frameK3]],
  u2 -> Expand[-2 frameMinkowskiDot[frameP, frameK2]],
  u3 -> Expand[-2 frameMinkowskiDot[frameP, frameK3]],
  s12 -> Expand[2 frameMinkowskiDot[frameK1, frameK2]],
  s13 -> Expand[2 frameMinkowskiDot[frameK1, frameK3]]
|>;

linearCoefficients[variable_] := Module[{expression},
  assert[KeyExistsQ[frameInvariantExpressions, variable],
    "Unknown ADMV in linearCoefficients."];
  expression = frameInvariantExpressions[variable];
  {
    expression /. {frameCosBeta -> 0, frameSinBetaCos -> 0},
    Coefficient[expression, frameCosBeta],
    Coefficient[expression, frameSinBetaCos]
  }
];

reducedLinearCoefficients[variable_] :=
  reducedLinearCoefficients[variable] =
    (Together /@ (linearCoefficients[variable] /. q2ConstraintRule));

frameAngleResiduals = PowerExpand /@ (Together /@ (
  {
    frameSinTheta2^2 + frameCosTheta2^2 - 1,
    frameSinAlpha2^2 + frameCosAlpha2^2 - 1,
    frameMinkowskiDot[frameP, frameK1] + u1/2,
    frameMinkowskiDot[frameP, frameQ] - (sHat + Q2)/2,
    frameMinkowskiDot[frameP, frameP],
    frameMinkowskiDot[frameQ, frameQ] + Q2,
    frameMinkowskiDot[frameK1, frameK1]
  } /. q2ConstraintRule
));
frameAngleGate = AllTrue[frameAngleResiduals, SameQ[#, 0] &];

frameLinearReconstructionResiduals = Flatten@Map[
  Function[variable,
    {
      Together[
        frameInvariantExpressions[variable] -
          linearCoefficients[variable] .
            {1, frameCosBeta, frameSinBetaCos}
      ]
    }
  ],
  admv
];
frameLinearReconstructionGate =
  AllTrue[frameLinearReconstructionResiduals, SameQ[#, 0] &];

frameAppendixDResiduals = PowerExpand /@ (Together /@ (
  appendixDResiduals /. Normal[frameInvariantExpressions] /.
    q2ConstraintRule
));
frameAppendixDGate =
  AllTrue[frameAppendixDResiduals, SameQ[#, 0] &];
assert[
  frameAngleGate && frameLinearReconstructionGate && frameAppendixDGate,
  "The tool-generated Frame-2 geometry failed an exact invariant gate."
];

coefficientDot[first_List, second_List] :=
  first[[2]] second[[2]] + first[[3]] second[[3]];

masslessGeometry[first_, second_] :=
  masslessGeometry[first, second] = Module[
    {firstCoefficients, secondCoefficients, cosine},
    firstCoefficients = reducedLinearCoefficients[first];
    secondCoefficients = reducedLinearCoefficients[second];
    cosine = Together[
      coefficientDot[firstCoefficients, secondCoefficients]/
        (First[firstCoefficients] First[secondCoefficients])
    ];
    {First[firstCoefficients], First[secondCoefficients], cosine}
  ];

case2Geometry[tVariable_, masslessVariable_] :=
  case2Geometry[tVariable, masslessVariable] = Module[
    {tCoefficients, masslessCoefficients, radiusSquared, radius,
     dCoefficient, cosine},
    tCoefficients = reducedLinearCoefficients[tVariable];
    masslessCoefficients = reducedLinearCoefficients[masslessVariable];
    radiusSquared = Together[
      coefficientDot[tCoefficients, tCoefficients]
    ];
    radius = Sqrt[radiusSquared];
    dCoefficient = Together[-First[tCoefficients]/radius];
    cosine = Together[
      -coefficientDot[tCoefficients, masslessCoefficients]/
        (radius First[masslessCoefficients])
    ];
    {-radius, First[masslessCoefficients], dCoefficient, cosine}
  ];

appendixB18[j_Integer, l_Integer, cosine_, epsilonSymbol_] :=
  2 Pi Gamma[1 - 2 epsilonSymbol]/Gamma[1 - epsilonSymbol]^2 *
    2^(-j - l) *
    Beta[1 - epsilonSymbol - j, 1 - epsilonSymbol - l] *
    Hypergeometric2F1[
      j, l, 1 - epsilonSymbol, (1 + cosine)/2
    ];

angularKeyAndCoefficient[term_] := Module[
  {variables, firstVariable, secondVariable, firstPower,
   secondPower, coefficient, ordered},
  variables = presentADMVs[term];
  Which[
    Length[variables] === 0,
      Return[{{"Area"}, term /. q2ConstraintRule}],
    Length[variables] === 1,
      firstVariable = First[variables];
      secondVariable = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &
      ];
      variables = {firstVariable, secondVariable},
    Length[variables] === 2,
      Null,
    True,
      fatal["Angular integration received more than two ADMVs."]
  ];
  ordered = If[
    MemberQ[typeOfADMV /@ variables, "t"],
    Join[
      Select[variables, typeOfADMV[#] === "t" &],
      Select[variables, typeOfADMV[#] =!= "t" &]
    ],
    SortBy[variables, First@First@Position[admv, #] &]
  ];
  firstVariable = First[ordered];
  secondVariable = Last[ordered];
  firstPower = laurentPower[term, firstVariable];
  secondPower = laurentPower[term, secondVariable];
  coefficient = Cancel[
    term/(firstVariable^firstPower secondVariable^secondPower)
  ] /. q2ConstraintRule;
  If[
    typeOfADMV[firstVariable] === "t",
    {
      {"B19", firstVariable, firstPower, secondVariable, secondPower},
      coefficient
    },
    {
      {"B18", firstVariable, firstPower, secondVariable, secondPower},
      coefficient
    }
  ]
];

masterFromKey[{"Area"}] := 2 Pi/(1 - 2 epsilon);

masterFromKey[
    {"B18", first_, firstPower_Integer, second_, secondPower_Integer}
  ] := Module[{geometry},
  geometry = masslessGeometry[first, second];
  geometry[[1]]^firstPower geometry[[2]]^secondPower *
    appendixB18[-firstPower, -secondPower, geometry[[3]], epsilon]
];

masterFromKey[
    {"B19", tVariable_, tPower_Integer,
     masslessVariable_, masslessPower_Integer}
  ] := Module[{geometry},
  geometry = case2Geometry[tVariable, masslessVariable];
  geometry[[1]]^tPower geometry[[2]]^masslessPower *
    S08Case2Master[
      -tPower, -masslessPower, geometry[[3]], geometry[[4]], epsilon
    ]
];

integrateReducedTerms[terms_List, label_String] := Module[
  {keyed, grouped, answer},
  Print["S08_STAGE: grouping angular masters for " <> label];
  keyed = angularKeyAndCoefficient /@ terms;
  grouped = Merge[(First[#] -> Last[#]) & /@ keyed, Total];
  Print[
    "S08_STAGE: angular master count " <> label <> " = " <>
      ToString[Length[grouped]]
  ];
  answer = Total[(Last[#] masterFromKey[First[#]]) & /@ Normal[grouped]];
  answer
];

validateAngularExpression[expr_, label_String] := Module[{},
  assert[expr =!= $Failed && expr =!= 0,
    label <> " is failed or identically zero."];
  assert[
    FreeQ[
      expr,
      t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2 |
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum |
        Indeterminate | ComplexInfinity | _DirectedInfinity | $Failed | _Real
    ],
    label <> " contains an angular, propagator, infinity, or machine-real object."
  ];
  assert[FreeQ[expr, D], label <> " still contains D rather than epsilon."];
  True
];

expectedCacheProvenance[projectorName_String] := <|
  "StageVersion" -> stageVersion,
  "ProgramSHA256Hex" -> programSHA256Hex,
  "SourceS07ProgramSHA256Hex" -> s07ProgramSHA256Hex,
  "SourceS07ResultSHA256Hex" -> s07SHA256Hex,
  "ReferencePDFSHA256" -> s07["ReferencePDFSHA256"],
  "BigTMDReferenceSHA256Hex" -> bigTMDReferenceHashes,
  "Projector" -> projectorName,
  "ProjectorDefinitionSHA256" ->
    s07["ProjectorContentHashes", projectorName],
  "InputExpressionSHA256" ->
    Hash[realQGInput[projectorName], "SHA256"],
  "AllInputContentSHA256" -> inputContentHashes,
  "KinematicContentSHA256" -> kinematicContentHashes,
  "PhaseSpaceDefinitionSHA256" -> Hash[
    {paperOverallNormalization, paperTwoBodyMeasureFactor,
      paperThreeBodyMeasurePrefactor, threeBodyPhasePrefactor},
    "SHA256"
  ],
  "AppendixDSystemSHA256" -> Hash[
    {appendixDResiduals, globalMomentumConservationResidual,
      kinematicReductionResiduals, appendixDRelations,
      appendixDGroebnerBasis},
    "SHA256"
  ],
  "DenominatorDiscoverySHA256" ->
    Hash[denominatorDiscovery[projectorName], "SHA256"],
  "FrameDefinitionSHA256" -> Hash[
    {frameInvariantExpressions,
      AssociationMap[reducedLinearCoefficients, admv]},
    "SHA256"
  ],
  "XiS23DefinitionSHA256" -> xiS23DefinitionSHA256
|>;

cacheMetadataValidQ[cache_, projectorName_String] := Module[
  {requiredKeys},
  requiredKeys = {
    "Status", "StageVersion", "Channel", "TensorRole", "Projector",
    "Provenance", "ExpressionSHA256", "Expression"
  };
  AssociationQ[cache] &&
    AllTrue[requiredKeys, KeyExistsQ[cache, #] &] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === "RealQG" &&
    cache["Projector"] === projectorName &&
    cache["Provenance"] === expectedCacheProvenance[projectorName] &&
    cache["ExpressionSHA256"] ===
      Hash[cache["Expression"], "SHA256"]
];

deleteCacheIfPresent[path_String] := If[
  FileExistsQ[path],
  DeleteFile[path]
];

loadValidatedCache[path_String, projectorName_String] := Module[
  {cache},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S08_STAGE: inspecting RealQG " <> projectorName <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, projectorName]],
    Print[
      "S08_STAGE: deleting stale or invalid RealQG " <>
        projectorName <> " cache"
    ];
    deleteCacheIfPresent[path];
    Return[Missing["InvalidCache"]]
  ];
  validateAngularExpression[
    cache["Expression"],
    "cached Hqg RealQG " <> projectorName <> " angular result"
  ];
  Print[
    "S08_STAGE: loading validated RealQG " <> projectorName <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[path_String, projectorName_String, expr_] := Module[
  {temporaryPath, cache, temporaryReload, finalReload},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  deleteCacheIfPresent[temporaryPath];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> "RealQG",
    "Projector" -> projectorName,
    "Provenance" -> expectedCacheProvenance[projectorName],
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ExpressionSHA256" -> Hash[expr, "SHA256"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    projectorName <> " temporary cache was not written."
  ];
  temporaryReload = Quiet@Check[Get[temporaryPath], $Failed];
  assert[
    SameQ[temporaryReload, cache] &&
      cacheMetadataValidQ[temporaryReload, projectorName],
    projectorName <> " temporary cache failed exact reload validation."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    projectorName <> " cache was not finalized."
  ];
  finalReload = Quiet@Check[Get[path], $Failed];
  assert[
    SameQ[finalReload, cache] &&
      cacheMetadataValidQ[finalReload, projectorName],
    projectorName <> " finalized cache failed exact reload validation."
  ];
];

processRealProjection[projection_, projectorName_String] := Module[
  {answer, explicit, reducedTerms, angularResult},
  answer = loadValidatedCache[cachePaths[projectorName], projectorName];
  If[! MissingQ[answer], Return[answer]];

  Print[
    "S08_STAGE: making propagators explicit for Hqg;qg " <> projectorName
  ];
  explicit = makeRealExplicit[projection, projectorName];
  assert[
    FreeQ[explicit, _FeynCalc`FeynAmpDenominator] &&
      FreeQ[explicit, _FeynCalc`Momentum],
    "Hqg;qg " <> projectorName <>
      " still contains an explicit propagator object."
  ];
  reducedTerms = reduceAppendixD[
    explicit,
    "Hqg;qg " <> projectorName
  ];
  angularResult = threeBodyPhasePrefactor *
    integrateReducedTerms[reducedTerms, "Hqg;qg " <> projectorName];
  validateAngularExpression[
    angularResult,
    "Hqg;qg " <> projectorName <> " angular result"
  ];
  writeValidatedCache[
    cachePaths[projectorName],
    projectorName,
    angularResult
  ];
  Print[
    "S08_CHECKPOINT: completed ", projectorName,
    " angular integration leaf count ", LeafCount[angularResult]
  ];
  angularResult
];

validateProjectionPair[pair_Association, label_String] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain exactly Pg and PPP."
  ];
  Scan[validateAngularExpression[#, label <> " projection"] &, Values[pair]];
  True
];

(* Eqs. (25)-(32) and (40), solved from their defining equations. *)
xHatXi = xB/xi;
paperEq40 =
  s23 ==
    (Q2 (zHatPaper (1 - xHatPaper) -
          zHatPaper^2 (1 - xHatPaper)) -
        xHatPaper k1T2Paper)/(xHatPaper zHatPaper);
fragmentationDefinitions = {
  xHatPaper -> xHatXi,
  zHatPaper -> zH/zeta,
  k1T2Paper -> PHT2/zeta^2
};
zetaSolutions = Solve[
  paperEq40 /. fragmentationDefinitions,
  zeta
];
assert[Length[zetaSolutions] === 1,
  "Paper Eq. (40) did not solve uniquely for zeta."];
zetaXiS23 = Together[zeta /. First[zetaSolutions]];
zHatXiS23 = Together[zH/zetaXiS23];
k1TPartonic2XiS23 = Together[PHT2/zetaXiS23^2];
xiS23Jacobian = Together[D[zetaXiS23, s23]];

xiLowerSolutions = Solve[
  Together[(zetaXiS23 /. s23 -> 0) - 1] == 0,
  xi
];
s23UpperSolutions = Solve[
  Together[zetaXiS23 - 1] == 0,
  s23
];
assert[
  Length[xiLowerSolutions] === 1 &&
    Length[s23UpperSolutions] === 1,
  "The Eq. (31)/(32) physical boundaries were not derived uniquely."
];
xiLowerA = Together[xi /. First[xiLowerSolutions]];
s23UpperB = Together[s23 /. First[s23UpperSolutions]];

partonicInvariantEquations = {
  sHat == Q2 (1/xHatXi - 1),
  t1 == -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  u1 == -zHatXiS23 Q2/xHatXi
};
partonicInvariantSolutions = Solve[
  partonicInvariantEquations,
  {sHat, t1, u1}
];
assert[Length[partonicInvariantSolutions] === 1,
  "Paper Eqs. (25)-(27) did not solve uniquely."];
partonicInvariantRules = First[partonicInvariantSolutions];
partonicSXi = Together[sHat /. partonicInvariantRules];
partonicTXiS23 = Together[t1 /. partonicInvariantRules];
partonicUXiS23 = Together[u1 /. partonicInvariantRules];
partonicToXiS23Rules = Join[
  partonicInvariantRules,
  {tHat -> partonicTXiS23}
];

eq40Residual = Together[
  Subtract @@ (List @@ paperEq40) /.
    fragmentationDefinitions /. First[zetaSolutions]
];
xiBoundaryResidual = Together[
  (zetaXiS23 /. s23 -> 0 /. First[xiLowerSolutions]) - 1
];
s23BoundaryResidual = Together[
  (zetaXiS23 /. First[s23UpperSolutions]) - 1
];
partonicInvariantResiduals = Together /@
  (Subtract @@@ (List @@@ partonicInvariantEquations) /.
    partonicInvariantRules);
partonicConstraintResidual = Together[
  globalMomentumConservationResidual /. partonicInvariantRules
];
xiS23DerivationGate =
  SameQ[eq40Residual, 0] &&
    SameQ[xiBoundaryResidual, 0] &&
    SameQ[s23BoundaryResidual, 0] &&
    AllTrue[partonicInvariantResiduals, SameQ[#, 0] &] &&
    SameQ[partonicConstraintResidual, 0] &&
    FreeQ[
      {zetaXiS23, xiS23Jacobian, xiLowerA, s23UpperB,
        partonicInvariantRules},
      _Real | _Missing | $Failed
    ];
assert[xiS23DerivationGate,
  "The tool-derived xi/s23 change of variables failed."];

(* Parse the measured BigTMD Python assignments rather than transcribing them. *)
extractPythonAssignmentRHS[name_String] := Module[{matches},
  matches = StringCases[
    bigTMDSidisText,
    RegularExpression[
      "(?m)^\\s*" <> name <> "\\s*=\\s*([^#\\r\\n]+)"
    ] -> "$1"
  ];
  assert[Length[matches] === 1,
    "BigTMD assignment " <> name <> " was not uniquely located."];
  StringTrim[First[matches]]
];

parseBigTMDExpression[name_String, extraReplacements_List] := Module[
  {rhs, translated, held},
  rhs = extractPythonAssignmentRHS[name];
  translated = StringReplace[
    rhs,
    Join[
      {
        "Q**2" -> "(Q2)",
        "qT**2" -> "(qT2BigTMD)",
        RegularExpression["\\bxh\\b"] -> "(xHatXi)",
        RegularExpression["\\bs23\\b"] -> "(s23)"
      },
      extraReplacements,
      {"**" -> "^"}
    ]
  ];
  assert[
    StringFreeQ[translated, "="] &&
      StringMatchQ[
        translated,
        RegularExpression["[A-Za-z0-9_+\\-*/^(). \\t]+"]
      ],
    "BigTMD assignment " <> name <> " contains unsupported syntax."
  ];
  held = Quiet@Check[
    ToExpression[translated, InputForm, HoldComplete],
    $Failed
  ];
  assert[Head[held] === HoldComplete,
    "BigTMD assignment " <> name <> " did not parse inertly."];
  ReleaseHold[held]
];

qT2Solutions = Solve[PHT2 == zH^2 qT2Reference, qT2Reference];
assert[Length[qT2Solutions] === 1,
  "The PHT2-to-qT2 map did not solve uniquely."];
qT2BigTMD = Together[qT2Reference /. First[qT2Solutions]];
bigTMDZHatXiS23 = parseBigTMDExpression["zh", {}];
bigTMDZetaXiS23 = parseBigTMDExpression[
  "zeta",
  {
    RegularExpression["\\bz\\b"] -> "(zH)",
    RegularExpression["\\bzh\\b"] -> "(bigTMDZHatXiS23)"
  }
];
bigTMDJacobianXiS23 = parseBigTMDExpression[
  "jac",
  {
    RegularExpression["\\bzeta\\b"] -> "(bigTMDZetaXiS23)"
  }
];
bigTMDPartonicSXi = parseBigTMDExpression["s", {}];
bigTMDPartonicTXiS23 = parseBigTMDExpression[
  "t",
  {RegularExpression["\\bzh\\b"] -> "(bigTMDZHatXiS23)"}
];
bigTMDS23UpperB = parseBigTMDExpression[
  "B",
  {RegularExpression["\\bz\\b"] -> "(zH)"}
];

bigTMDKinematicChecks = <|
  "ZHatS23MapExact" ->
    TrueQ[Together[zHatXiS23 - bigTMDZHatXiS23] === 0],
  "ZetaMapExact" ->
    TrueQ[Together[zetaXiS23 - bigTMDZetaXiS23] === 0],
  "JacobianExact" ->
    TrueQ[Together[xiS23Jacobian - bigTMDJacobianXiS23] === 0],
  "PartonicSExact" ->
    TrueQ[Together[partonicSXi - bigTMDPartonicSXi] === 0],
  "PartonicTExact" ->
    TrueQ[Together[partonicTXiS23 - bigTMDPartonicTXiS23] === 0],
  "EndpointBExact" ->
    TrueQ[Together[s23UpperB - bigTMDS23UpperB] === 0]
|>;
bigTMDKinematicGate =
  AllTrue[Values[bigTMDKinematicChecks], TrueQ];
assert[bigTMDKinematicGate,
  "At least one parsed BigTMD kinematic assignment disagrees."];

xiS23DefinitionSHA256 = Hash[
  {
    HoldComplete[paperEq40], fragmentationDefinitions,
    zetaXiS23, xiS23Jacobian, xiLowerA, s23UpperB,
    partonicInvariantEquations, partonicInvariantRules,
    bigTMDKinematicChecks
  },
  "SHA256"
];

transformPair[pair_Association] := Map[
  Function[expression,
    xiS23Jacobian * (expression /. partonicToXiS23Rules)
  ],
  pair
];

validateXiS23Pair[pair_Association, label_String] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " transformed pair has the wrong projector keys."
  ];
  assert[
    And @@ Map[
      Function[expression, expression =!= $Failed && expression =!= 0],
      Values[pair]
    ],
    label <> " contains a failed or zero transformed expression."
  ];
  assert[
    And @@ (FreeQ[
        #,
        zeta | sHat | tHat | t1 | u1 |
          Indeterminate | ComplexInfinity | _DirectedInfinity | $Failed | _Real
      ] & /@ Values[pair]),
    label <> " retains a replaced variable, infinity, or machine real."
  ];
  assert[
    And @@ Map[
      Function[expression,
        ! FreeQ[expression, xi] && ! FreeQ[expression, s23]
      ],
      Values[pair]
    ],
    label <> " does not retain both xi and s23 dependence."
  ];
  True
];

zeroCoefficientVectorQ[vector_List] :=
  And @@ (TrueQ[Together[# /. q2ConstraintRule] === 0] & /@ vector);

Print["S08_STAGE: validating Appendix D and BigTMD kinematic identities"];
appendixDIdentityChecks = AssociationThread[
  {"D5", "D6", "D7", "D8"},
  SameQ[#, 0] & /@ frameAppendixDResiduals
];
masslessGeometryChecks = AssociationMap[
  Function[variable,
    Module[{coefficients = reducedLinearCoefficients[variable]},
      TrueQ[
        PowerExpand[Together[
          First[coefficients]^2 -
            coefficientDot[coefficients, coefficients]
        ]] === 0
      ]
    ]
  ],
  {u2, u3, s12, s13}
];
assert[
  AllTrue[Values[appendixDIdentityChecks], TrueQ] &&
    AllTrue[Values[masslessGeometryChecks], TrueQ],
  "An Appendix-D or massless angular-geometry identity failed."
];

preflightChecks = <|
  "AcceptedS07Schema" -> sourceSchemaGate,
  "AcceptedS07AndS06Identities" -> s07IdentityGate,
  "ReferencePaperIdentity" -> paperReferenceGate,
  "BigTMDConvention" -> bigTMDConventionGate,
  "ChargeConvention" -> chargeConventionGate,
  "StateAndFragmentingRouting" -> stateAndFragmentingGate,
  "ProjectorLedger" -> projectorLedgerGate,
  "BigTMDRoutingAndFiles" -> bigTMDRoutingGate,
  "InheritedKinematics" -> kinematicRecordGate,
  "KinematicInstallation" -> kinematicInstallationGate,
  "InputPairs" -> inputPairValidationGate,
  "VirtualCounterterms" -> virtualInputCountertermGate,
  "PhaseSpaceNormalization" -> phaseSpaceNormalizationGate,
  "AppendixDSystem" -> appendixDRelationGate,
  "DenominatorDiscovery" -> denominatorDiscoveryGate,
  "FrameAngles" -> frameAngleGate,
  "FrameLinearReconstruction" -> frameLinearReconstructionGate,
  "FrameAppendixD" -> frameAppendixDGate,
  "MasslessAngularGeometry" ->
    AllTrue[Values[masslessGeometryChecks], TrueQ],
  "XiS23Derivation" -> xiS23DerivationGate,
  "ParsedBigTMDKinematics" -> bigTMDKinematicGate
|>;
assert[AllTrue[Values[preflightChecks], TrueQ],
  "At least one S08 preflight gate failed."];

If[preflightOnlyQ,
  preflightArtifactSnapshot = AssociationMap[
    artifactIdentity,
    s08ArtifactPaths
  ];
  preflightTemporaryPaths = FileNames["s08_*.tmp.*", scriptDirectory];
  preflightNoWriteGate =
    preflightArtifactSnapshot === initialArtifactSnapshot &&
      preflightTemporaryPaths === {};
  assert[preflightNoWriteGate,
    "The S08 preflight changed an output/cache or left a temporary."];
  Print["S08_PREFLIGHT_CHECKS=", InputForm[preflightChecks]];
  Print["S08_PREFLIGHT_ARTIFACT_SNAPSHOT=",
    InputForm[preflightArtifactSnapshot]];
  Print["HQG_S08_KINV2_PREFIX_PREFLIGHT_OK"];
  Quit[0]
];

Print["S08_STAGE: applying two-body Hqg phase space"];
twoBodyResults = <|
  "LO_OAlphaS" -> makeTwoBodyPair[loInput, "Hqg LO", True],
  "NLOVirtualInterference_OAlphaS2_Symbolic" ->
    makeTwoBodyPair[
      virtualInput,
      "Hqg renormalized virtual interference",
      False
    ]
|>;
twoBodyValidationChecks = <|
  "LO" -> validateTwoBodyPair[
    twoBodyResults["LO_OAlphaS"],
    "Hqg LO two-body result",
    True
  ],
  "Virtual" -> validateTwoBodyPair[
    twoBodyResults["NLOVirtualInterference_OAlphaS2_Symbolic"],
    "Hqg virtual two-body result",
    False
  ]
|>;
virtualOutputCountertermGate = AllTrue[
  Values[twoBodyResults[
    "NLOVirtualInterference_OAlphaS2_Symbolic"
  ]],
  ! FreeQ[#, dZq1] && ! FreeQ[#, dZGG1] && ! FreeQ[#, dZgs1] &
];
assert[virtualOutputCountertermGate,
  "The two-body virtual pair lost symbolic QCD counterterms."
];

Print["S08_STAGE: integrating the Hqg;qg real projections"];
realAngularResults = <|
  "Pg" -> processRealProjection[realQGInput["Pg"], "Pg"],
  "PPP" -> processRealProjection[realQGInput["PPP"], "PPP"]
|>;
realProjectionValidationGate = validateProjectionPair[
  realAngularResults,
  "Hqg;qg angular result"
];
cacheReloads = AssociationMap[
  Quiet@Check[Get[cachePaths[#]], $Failed] &,
  projectorNames
];
cacheValidationChecks = AssociationMap[
  Function[projectorName,
    cacheMetadataValidQ[cacheReloads[projectorName], projectorName] &&
      SameQ[
        cacheReloads[projectorName, "Expression"],
        realAngularResults[projectorName]
      ]
  ],
  projectorNames
];
assert[AllTrue[Values[cacheValidationChecks], TrueQ],
  "A finalized S08 real cache failed metadata or raw-expression equality."];
cacheArtifactIdentities = Map[artifactIdentity, cachePaths];

Print["S08_STAGE: applying zeta-to-s23 change of variables"];
xiS23Kernels = <|
  "TwoBody" -> Map[transformPair, twoBodyResults],
  "ThreeBodyReal" -> <|
    "Hqg;qg" -> transformPair[realAngularResults]
  |>
|>;
xiS23ValidationChecks = Join[
  AssociationMap[
    validateXiS23Pair[
      xiS23Kernels["TwoBody", #],
      "TwoBody:" <> #
    ] &,
    Keys[xiS23Kernels["TwoBody"]]
  ],
  <|
    "ThreeBodyReal:Hqg;qg" -> validateXiS23Pair[
      xiS23Kernels["ThreeBodyReal", "Hqg;qg"],
      "Hqg;qg xi-s23 kernel"
    ]
  |>
];

case2Masters = DeleteDuplicates@Cases[
  Values[realAngularResults],
  _S08Case2Master,
  Infinity
];

twoBodyExpressionList = Flatten[Values /@ Values[twoBodyResults]];
realExpressionList = Values[realAngularResults];
xiTwoBodyExpressionList = Flatten[
  Values /@ Values[xiS23Kernels["TwoBody"]]
];
xiRealExpressionList =
  Values[xiS23Kernels["ThreeBodyReal", "Hqg;qg"]];
allOutputExpressions = Join[
  twoBodyExpressionList,
  realExpressionList,
  xiTwoBodyExpressionList,
  xiRealExpressionList
];

projectionKeyGate =
  AllTrue[
    Join[
      Values[twoBodyResults],
      {realAngularResults},
      Values[xiS23Kernels["TwoBody"]],
      {xiS23Kernels["ThreeBodyReal", "Hqg;qg"]}
    ],
    Keys[#] === projectorNames &
  ];
twoBodyDeltaGate = AllTrue[
  twoBodyExpressionList,
  ! FreeQ[#, DiracDelta[s23]] &
];
angleEliminationGate = FreeQ[
  realExpressionList,
  beta1 | beta2 | frameCosBeta | frameSinBetaCos |
    t2 | t3 | u2 | u3 | s12 | s13
];
explicitRealPropagatorGate = FreeQ[
  realExpressionList,
  _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
];
fullySymbolicGate = FreeQ[
  allOutputExpressions,
  _Real | _Missing | $Failed | Indeterminate | ComplexInfinity |
    _DirectedInfinity
];
zetaEliminationGate = FreeQ[
  Join[xiTwoBodyExpressionList, xiRealExpressionList],
  zeta | sHat | tHat | t1 | u1
];
xiS23DependenceGate = AllTrue[
  Join[xiTwoBodyExpressionList, xiRealExpressionList],
  ! FreeQ[#, xi] && ! FreeQ[#, s23] &
];

transformVerificationResiduals = Flatten@Join[
  KeyValueMap[
    Function[{order, transformedPair},
      MapThread[
        Together[#1 - xiS23Jacobian (#2 /. partonicToXiS23Rules)] &,
        {
          Values[transformedPair],
          Values[twoBodyResults[order]]
        }
      ]
    ],
    xiS23Kernels["TwoBody"]
  ],
  {
    MapThread[
      Together[#1 - xiS23Jacobian (#2 /. partonicToXiS23Rules)] &,
      {xiRealExpressionList, realExpressionList}
    ]
  }
];
xiS23JacobianApplicationGate =
  AllTrue[transformVerificationResiduals, SameQ[#, 0] &];

currentImmutableIdentityGate =
  sha256Hex[programPath] === programSHA256Hex &&
    sha256Hex[s07ProgramPath] === acceptedS07ProgramSHA256Hex &&
    sha256Hex[s07Path] === acceptedS07ResultSHA256Hex &&
    FileHash[referencePDFPath, "SHA256"] ===
      s07["ReferencePDFSHA256"] &&
    Map[sha256Hex, bigTMDReferencePaths] === bigTMDReferenceHashes;
prePublicationTemporaryGate =
  FileNames["s08_*.tmp.*", scriptDirectory] === {};

s08Checks = <|
  "ImmutableInputsUnchanged" -> currentImmutableIdentityGate,
  "EveryPreflightGatePassed" ->
    AllTrue[Values[preflightChecks], TrueQ],
  "TwoBodyPairsValidated" ->
    AllTrue[Values[twoBodyValidationChecks], TrueQ],
  "VirtualCountertermsPreserved" -> virtualOutputCountertermGate,
  "RealAngularPairValidated" -> realProjectionValidationGate,
  "EveryRealCacheMetadataAndRawExpressionValidated" ->
    AllTrue[Values[cacheValidationChecks], TrueQ],
  "EveryXiS23PairValidated" ->
    AllTrue[Values[xiS23ValidationChecks], TrueQ],
  "EveryContributionRetainsBothProjectors" -> projectionKeyGate,
  "TwoBodyConstraintIsDeltaS23" -> twoBodyDeltaGate,
  "AppendixDIdentitiesD5ThroughD8Verified" ->
    AllTrue[Values[appendixDIdentityChecks], TrueQ],
  "AngularVariablesAndADMVsEliminated" -> angleEliminationGate,
  "ExplicitRealPropagatorObjectsEliminated" ->
    explicitRealPropagatorGate,
  "XiS23VariablesReplaced" -> zetaEliminationGate,
  "EveryXiS23KernelRetainsXiAndS23" -> xiS23DependenceGate,
  "XiS23JacobianAppliedExactly" -> xiS23JacobianApplicationGate,
  "ParsedBigTMDKinematicMapExact" -> bigTMDKinematicGate,
  "CalculationFullySymbolic" -> fullySymbolicGate,
  "NoPrePublicationTemporarySurvives" ->
    prePublicationTemporaryGate
|>;
assert[AllTrue[Values[s08Checks], TrueQ],
  "At least one computed S08 production acceptance gate failed."];

s08Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg LO/virtual two-body and Hqg;qg real angular-integrated Pg/PPP kernels",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ProgramSHA256Hex" -> programSHA256Hex,
  "SourceProgram" -> s07ProgramPath,
  "SourceProgramSHA256" -> s07ProgramSHA256,
  "SourceProgramSHA256Hex" -> s07ProgramSHA256Hex,
  "SourceResult" -> s07Path,
  "SourceResultSHA256" -> s07SHA256,
  "SourceResultSHA256Hex" -> s07SHA256Hex,
  "SourceLineage" -> <|
    "S07ProgramSHA256Hex" -> s07ProgramSHA256Hex,
    "S07ResultSHA256Hex" -> s07SHA256Hex,
    "S06ProgramSHA256Hex" ->
      s07["SourceProgramSHA256Hex"],
    "S06ResultSHA256Hex" ->
      s07["SourceResultSHA256Hex"]
  |>,
  "ReferencePDFSHA256" -> s07["ReferencePDFSHA256"],
  "BigTMDConvention" -> s07["BigTMDConvention"],
  "ElectricChargeNormalization" -> s07["ElectricChargeNormalization"],
  "InitialStateNormalizationDerivation" ->
    s07["InitialStateNormalizationDerivation"],
  "InitialStateAverage" -> s07["InitialStateAverage"],
  "BigTMDProjectorMapping" -> bigTMDProjectorMapping,
  "BigTMDReferenceFiles" -> <|
    "Paths" -> bigTMDReferencePaths,
    "SHA256Hex" -> bigTMDReferenceHashes,
    "DispatchLine" -> First[dispatchLines]
  |>,
  "BigTMDKinematicMapping" -> <|
    "PHT2Relation" -> HoldForm[PHT2 == zH^2 qT2Reference],
    "ZHatExpression" -> zHatXiS23,
    "BigTMDZHatExpression" -> bigTMDZHatXiS23,
    "BigTMDZetaExpression" -> bigTMDZetaXiS23,
    "JacobianExpression" -> xiS23Jacobian,
    "BigTMDJacobianExpression" -> bigTMDJacobianXiS23,
    "PartonicS" -> partonicSXi,
    "PartonicT" -> partonicTXiS23,
    "S23UpperB" -> s23UpperB,
    "Checks" -> bigTMDKinematicChecks,
    "FiniteKernelComparisonStatus" ->
      "Deferred until endpoint expansion, real-virtual combination, factorization, and finite regular/delta/plus assembly."
  |>,
  "DimensionalConvention" -> HoldForm[D == 4 - 2 epsilon],
  "FragmentingParton" -> "gluon g(k1)",
  "ObservedMomentumTreatment" ->
    "fragmenting g(k1) is kept differential; only unobserved q(k2),g(k3) real-phase-space angles are integrated",
  "KinematicConventions" -> kinematicRecords,
  "KinematicInstallationAudits" -> <|
    "TwoBody" -> twoBodyInstallationAudit,
    "ThreeBody" -> threeBodyInstallationAudit
  |>,
  "InputContentSHA256" -> inputContentHashes,
  "KinematicContentSHA256" -> kinematicContentHashes,
  "PhaseSpaceDefinitions" -> <|
    "OverallEq19" -> paperOverallNormalization,
    "TwoBodyEq34" -> twoBodyPhaseFactor,
    "ThreeBodyEq38Eq39" -> threeBodyPhasePrefactor,
    "NormalizationGate" -> phaseSpaceNormalizationGate
  |>,
  "TwoBodyPhaseSpaceIntegrated" -> twoBodyResults,
  "ThreeBodyAngularIntegrated" -> <|
    "Hqg;qg" -> realAngularResults
  |>,
  "XiS23ConvolutionKernels" -> xiS23Kernels,
  "XiS23ChangeOfVariables" -> <|
    "Replacement" -> HoldForm[zeta == zetaXiS23],
    "DefiningEquation" -> HoldComplete[paperEq40],
    "FragmentationDefinitions" -> fragmentationDefinitions,
    "ZetaExpression" -> zetaXiS23,
    "Jacobian_dXi_dZeta_to_dXi_dS23" -> xiS23Jacobian,
    "DerivationGate" -> xiS23DerivationGate,
    "XiRange" -> {xi, xiLowerA, 1},
    "S23RangeAtFixedXi" -> {s23, 0, s23UpperB},
    "XiLowerA" -> xiLowerA,
    "S23UpperB" -> s23UpperB,
    "PartonicKinematicRules" -> partonicToXiS23Rules,
    "DefinitionSHA256" -> xiS23DefinitionSHA256
  |>,
  "AngularMasterBasis" -> <|
    "MasslessMassless" -> "Eq. (B18), evaluated explicitly",
    "VirtualPhotonMassless" -> "I[j,l] of Eq. (B19)",
    "Case2MastersUsed" -> case2Masters,
    "Case2MasterCount" -> Length[case2Masters],
    "Case2MasterDefinition" -> HoldComplete[
      S08Case2Master[j, l, dCoefficient, cosineChi, epsilon] ==
        With[{n = 4 - 2 epsilon},
          (-1)^(l + 1) 2^(1 - l - j) Pi Gamma[n - 3] *
            Gamma[2 + l - n/2] Gamma[n/2 - l - 1]/
            (Gamma[n/2 - 1]^2 Gamma[n/2 - 2] *
              Gamma[3 - n/2]) *
            Inactive[Integrate][
              zMaster^(n/2 - 2) (1 - zMaster)^(n/2 - l - 2)/
                (zMaster + (dCoefficient - 1)/2)^j *
                Hypergeometric2F1[
                  j, l, n/2 - 1,
                  (1 + cosineChi) zMaster/
                    (dCoefficient - 1 + 2 zMaster)
                ],
              {zMaster, 0, 1}
            ]
        ]
    ]
  |>,
  "AppendixDReduction" -> <|
    "DefiningRearrangements" -> HoldComplete[appendixDRearrangements],
    "ToolDerivedResiduals" -> appendixDResiduals,
    "ToolDerivedGlobalResidual" ->
      globalMomentumConservationResidual,
    "CanonicalizationResiduals" -> kinematicReductionResiduals,
    "ToolDerivedRelations" -> appendixDRelations,
    "IdentityChecks" -> appendixDIdentityChecks,
    "DenominatorDiscovery" -> denominatorDiscovery
  |>,
  "Frame2Geometry" -> <|
    "InvariantExpressions" -> frameInvariantExpressions,
    "ReducedLinearCoefficients" ->
      AssociationMap[reducedLinearCoefficients, admv],
    "AngleResiduals" -> frameAngleResiduals,
    "AppendixDResiduals" -> frameAppendixDResiduals,
    "MasslessGeometryChecks" -> masslessGeometryChecks
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "Paths" -> cachePaths,
    "Expected" -> AssociationMap[
      expectedCacheProvenance,
      projectorNames
    ],
    "ArtifactIdentities" -> cacheArtifactIdentities,
    "ValidationChecks" -> cacheValidationChecks
  |>,
  "PaperReferences" -> {
    "two-body phase space: Eqs. (34)-(35)",
    "three-body phase space: Eqs. (38)-(40)",
    "angular master integrals: Appendix B",
    "partial fractions: Appendix D",
    "zeta to s23: Eqs. (29)-(32)"
  },
  "Checks" -> s08Checks,
  "NotPerformedAtThisStage" -> {
    "Appendix F epsilon expansion of I[j,l] masters",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "s23 endpoint delta/plus-distribution expansion",
    "real-virtual infrared-pole cancellation",
    "initial-state PDF and final-state FF subtraction from Eq. (46)",
    "epsilon -> 0 limit",
    "BigTMD cross-section/luminosity/photon-spin normalization",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels"
  }
|>;

angularLeafCounts = Map[LeafCount, realAngularResults];
transformedLeafCounts = <|
  "TwoBody" -> Map[
    Map[LeafCount, #] &,
    xiS23Kernels["TwoBody"]
  ],
  "ThreeBodyReal" -> Map[
    LeafCount,
    xiS23Kernels["ThreeBodyReal", "Hqg;qg"]
  ]
|>;

Print["S08_STAGE: writing " <> resultPath];
temporaryResultPath = resultPath <> ".tmp." <> ToString[$ProcessID];
deleteCacheIfPresent[temporaryResultPath];
Put[s08Result, temporaryResultPath];
assert[
  FileExistsQ[temporaryResultPath] && FileByteCount[temporaryResultPath] > 0,
  "The temporary s08_result was not written."
];
temporaryResultReload = Quiet@Check[Get[temporaryResultPath], $Failed];
temporaryResultReloadGate =
  SameQ[temporaryResultReload, s08Result] &&
    AssociationQ[temporaryResultReload] &&
    temporaryResultReload["Status"] === "Complete" &&
    temporaryResultReload["Stage"] === stageVersion &&
    AllTrue[Values[temporaryResultReload["Checks"]], TrueQ];
assert[temporaryResultReloadGate,
  "The temporary s08_result failed exact reload validation."];
RenameFile[temporaryResultPath, resultPath, OverwriteTarget -> True];
assert[FileExistsQ[resultPath], "s08_result was not created."];
assert[FileByteCount[resultPath] > 0, "s08_result is empty."];
finalResultReload = Quiet@Check[Get[resultPath], $Failed];
finalResultReloadGate =
  SameQ[finalResultReload, s08Result] &&
    AllTrue[Values[finalResultReload["Checks"]], TrueQ];
postPublicationIdentityGate =
  sha256Hex[programPath] === programSHA256Hex &&
    sha256Hex[s07ProgramPath] === acceptedS07ProgramSHA256Hex &&
    sha256Hex[s07Path] === acceptedS07ResultSHA256Hex &&
    FileHash[referencePDFPath, "SHA256"] ===
      s07["ReferencePDFSHA256"] &&
    Map[sha256Hex, bigTMDReferencePaths] === bigTMDReferenceHashes;
postPublicationTemporaryGate =
  FileNames["s08_*.tmp.*", scriptDirectory] === {};
assert[
  finalResultReloadGate && postPublicationIdentityGate &&
    postPublicationTemporaryGate,
  "The finalized S08 result or its post-publication provenance failed."
];

Print["S08_SUCCESS"];
Print["S08_RESULT_PATH=" <> resultPath];
Print["S08_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S08_RESULT_SHA256_HEX=" <> sha256Hex[resultPath]];
Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
Print["S08_ANGULAR_LEAF_COUNTS=", InputForm[angularLeafCounts]];
Print["S08_TRANSFORMED_LEAF_COUNTS=", InputForm[transformedLeafCounts]];
Print["S08_CHECKS=", InputForm[s08Checks]];
Print["S08_CACHE_VALIDATION_CHECKS=",
  InputForm[cacheValidationChecks]];
Print["S08_ATOMIC_RELOAD_CHECKS=",
  InputForm[{temporaryResultReloadGate, finalResultReloadGate,
    postPublicationIdentityGate, postPublicationTemporaryGate}]];

Quit[0];

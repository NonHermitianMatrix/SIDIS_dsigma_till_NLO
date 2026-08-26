(* ::Package:: *)

(*
  Hqg stage S09: expand the Eq. (B19) masters retained by the accepted
  S08 physical post-1/2! Pg/PPP pair, apply the already accepted xi,s23
  change of variables, and record the formal bounded endpoint-distribution
  handoff.

  Physics sources: Appendix B Eqs. (B18), (B19), (B21)-(B31) and Appendix F
  Eqs. (F1)-(F29) of the authoritative paper.  This stage does not resolve
  endpoint coefficients, apply Eq. (46) factorization, take epsilon -> 0,
  extract F-hats, or compare with BigTMD.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, mapAssociationValues,
  atomicPutAssociation, boundedOperation, scalePowerInventory,
  derivePolynomialB19Expansion, appendixFBaseF8,
  derivedF9Expansion, appendixFExpansion, appendixFZeroJ, expandOneMaster,
  expandAppendixFMasters, expandCase1Functions,
  toRecurrenceBasis, recurrenceResidual, b19F8MomentResiduals,
  f9B19ReducedNumeric, b27Expansion, expandAllRequiredFunctions,
  expandedKernelValidQ,
  validateExpandedKernel, cacheMetadataValidQ,
  loadValidatedCache, processProjector,
  formalEndpointDistribution, buildResultCandidate,
  compactResultCandidateValidQ,
  S08Case2Master, S09EndpointValue, S09PlusDistribution,
  S09RegularEndpointFunction, S09ExpandedKernelReference,
  S09K, S09A, S09B
];

activeTemporaryPath = "";

fatal[message_String] := (
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S09_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

mapAssociationValues[function_, association_Association] :=
  Map[function, association];

associationValueMappingProbe = mapAssociationValues[
  StringLength,
  <|"Pg" -> "pg", "PPP" -> "ppp"|>
];
assert[
  associationValueMappingProbe === <|"Pg" -> 2, "PPP" -> 3|>,
  "Association value mapping does not preserve projector keys and values."
];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  assert[
    ! FileExistsQ[finalPath],
    "Refusing to overwrite an existing finalized artifact: " <> finalPath
  ];
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "The process-specific temporary path already exists: " <>
      activeTemporaryPath
  ];
  writeResult = Check[Put[expression, activeTemporaryPath], $Failed];
  assert[
    writeResult =!= $Failed && FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    "Atomic temporary write failed for " <> finalPath
  ];
  loaded = Check[Get[activeTemporaryPath], $Failed];
  assert[
    AssociationQ[loaded] && loaded["Status"] === "Complete" &&
      loaded["Stage"] === expectedStage,
    "Atomic temporary reload failed status/stage validation for " <>
      finalPath
  ];
  renameResult = Check[
    RenameFile[activeTemporaryPath, finalPath],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic rename failed for " <> finalPath];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Finalized atomic file is missing or empty: " <> finalPath
  ];
  loaded
];

SetAttributes[boundedOperation, HoldRest];
boundedOperation[label_String, expression_] := Module[{answer},
  answer = Check[
    MemoryConstrained[expression, memoryBudgetBytes, $Aborted],
    $Failed
  ];
  assert[
    answer =!= $Failed && answer =!= $Aborted,
    label <> " failed, emitted a message, or exceeded the memory budget."
  ];
  answer
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
s07SourcePath =
  FileNameJoin[{scriptDirectory, "s07_contract_hqg_projectors.wl"}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
s08SourcePath =
  FileNameJoin[{scriptDirectory, "s08_phase_space_integrate_hqg.wl"}];
s08ResultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
s08CachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_pp"}]
|>;
resultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s09_cache_hqg_real_qg_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s09_cache_hqg_real_qg_pp"}]
|>;

stageVersion = "HqgS09-v5";
cacheStageVersion = "HqgS09Cache-v2";
resultSchemaVersion = 2;
preflightOnly =
  Quiet@Check[Environment["HQG_S09_PREFLIGHT_ONLY"], ""] === "1";
memoryBudgetBytes = 12 2^30;
projectorOrder = {"Pg", "PPP"};

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS06SourceHash =
  "d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6";
expectedS06ResultHash =
  "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55";
expectedS07SourceHash =
  "baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09";
expectedS07ResultHash =
  "c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6";
expectedS08SourceHash =
  "28a2a552c09470844c5418c7261e88c7abcc80bc3f9388f348cb8e6e4dbf8803";
expectedS08ResultHash =
  "a25bafca0c9e33790418d9a491b985a73e12a75b9260f7a1864c315c7e608052";
expectedS08CacheHashes = <|
  "Pg" ->
    "26990faf2f3e5167e4ff3d78f10b937963ec0caa53e1d6941472f3361102b275",
  "PPP" ->
    "9eedf24bb955fe576ff46b016ab63979f88d2a821c9fd3c3cf8858dbdf80359a"
|>;
expectedS08Lineage = <|
  "S07ProgramSHA256Hex" -> expectedS07SourceHash,
  "S07ResultSHA256Hex" -> expectedS07ResultHash,
  "S06ProgramSHA256Hex" -> expectedS06SourceHash,
  "S06ResultSHA256Hex" -> expectedS06ResultHash
|>;

programHash = fileSHA256[programPath];
preflightArtifactSnapshot = Sort@FileNames["s09_*", scriptDirectory];
staleTemporaryPaths = Join[
  FileNames["s09_result.tmp.*", scriptDirectory],
  FileNames["s09_cache_hqg_real_qg_*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "A stale S09 temporary artifact must be resolved before execution."
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[resultPath],
    "s09_result already exists; validate or deliberately invalidate it before regeneration."
  ]
];

Print["S09_STAGE: validating the paper and accepted Hqg S07/S08 handoff"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing."];
    assert[
      fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff."
    ];
  ],
  <|
    "authoritative paper" -> {paperPath, expectedPaperHash},
    "S07 source" -> {s07SourcePath, expectedS07SourceHash},
    "S07 result" -> {s07ResultPath, expectedS07ResultHash},
    "S08 source" -> {s08SourcePath, expectedS08SourceHash},
    "S08 result" -> {s08ResultPath, expectedS08ResultHash},
    "S08 Pg cache" -> {s08CachePaths["Pg"], expectedS08CacheHashes["Pg"]},
    "S08 PPP cache" ->
      {s08CachePaths["PPP"], expectedS08CacheHashes["PPP"]}
  |>
];

s08 = Check[Get[s08ResultPath], $Failed];
assert[AssociationQ[s08], "s08_result is not an Association."];
s08StatusGate =
  s08["Status"] === "Complete" &&
  s08["Stage"] === "HqgS08-v5" &&
  s08["Channel"] === "Hqg only" &&
  s08["Program"] === s08SourcePath &&
  s08["ProgramSHA256Hex"] === expectedS08SourceHash &&
  s08["SourceProgram"] === s07SourcePath &&
  s08["SourceProgramSHA256Hex"] === expectedS07SourceHash &&
  s08["SourceResult"] === s07ResultPath &&
  s08["SourceResultSHA256Hex"] === expectedS07ResultHash &&
  s08["ReferencePDFSHA256"] === FileHash[paperPath, "SHA256"];
assert[s08StatusGate,
  "s08_result failed status, channel, source, lineage-head, or paper validation."];

s08ChecksGate =
  AssociationQ[s08["Checks"]] &&
  Length[s08["Checks"]] === 18 &&
  AllTrue[Values[s08["Checks"]], TrueQ];
assert[s08ChecksGate,
  "The accepted S08 result does not contain exactly 18 computed true checks."];

s08LineageGate = s08["SourceLineage"] === expectedS08Lineage;
assert[s08LineageGate,
  "The accepted S08 result lost its exact S06/S07 embedded lineage."];

s08CacheLedgerGate =
  AssociationQ[s08["CacheProvenance"]] &&
  s08["CacheProvenance", "StageVersion"] === "HqgS08-v5" &&
  s08["CacheProvenance", "Paths"] === s08CachePaths &&
  AssociationQ[s08["CacheProvenance", "Expected"]] &&
  AssociationQ[s08["CacheProvenance", "ArtifactIdentities"]] &&
  s08["CacheProvenance", "ArtifactIdentities", "Pg", "SHA256Hex"] ===
    expectedS08CacheHashes["Pg"] &&
  s08["CacheProvenance", "ArtifactIdentities", "PPP", "SHA256Hex"] ===
    expectedS08CacheHashes["PPP"] &&
  AllTrue[
    Values[s08["CacheProvenance", "ValidationChecks"]],
    TrueQ
  ];
assert[s08CacheLedgerGate,
  "The accepted S08 cache-provenance handoff is incomplete or stale."];

physicalAngular =
  s08["ThreeBodyAngularIntegrated", "Hqg;qg"];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicToXiS23Rules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["Jacobian_dXi_dZeta_to_dXi_dS23"];
s23UpperB = changeOfVariables["S23UpperB"];

assert[
  AssociationQ[physicalAngular] && Keys[physicalAngular] === projectorOrder,
  "S08 does not contain exactly the ordered physical Hqg;qg Pg/PPP angular pair."
];
assert[
  ListQ[partonicToXiS23Rules] && Length[partonicToXiS23Rules] > 0 &&
    ! MissingQ[xiS23Jacobian] && ! MissingQ[s23UpperB] &&
    changeOfVariables["S23RangeAtFixedXi"] === {s23, 0, s23UpperB},
  "The accepted exact xi,s23 transformation is incomplete."
];

chargeBookkeeping = <|
  "ElectricChargeNormalization" -> s08["ElectricChargeNormalization"],
  "BigTMDConvention" -> s08["BigTMDConvention"],
  "BigTMDProjectorMapping" -> s08["BigTMDProjectorMapping"],
  "FragmentingParton" -> s08["FragmentingParton"]
|>;
chargeBookkeepingGate =
  chargeBookkeeping["BigTMDConvention", "ChannelNumber"] === 3 &&
  chargeBookkeeping["BigTMDConvention", "ChargeCase"] === "A only" &&
  chargeBookkeeping["ElectricChargeNormalization",
    "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g" &&
  Together[
    chargeBookkeeping["ElectricChargeNormalization", "ReferenceCharge"] *
    chargeBookkeeping["ElectricChargeNormalization", "AmplitudeStripFactor"]
  ] === 1 &&
  chargeBookkeeping["FragmentingParton"] === "gluon g(k1)";
assert[chargeBookkeepingGate,
  "The accepted charge-stripped channel-3A fragmenting-gluon convention changed."];

initialStateBookkeeping = <|
  "Derivation" -> s08["InitialStateNormalizationDerivation"],
  "Average" -> s08["InitialStateAverage"]
|>;
dimensionalBookkeeping = <|
  "Convention" -> s08["DimensionalConvention"],
  "ObservedMomentumTreatment" -> s08["ObservedMomentumTreatment"],
  "SeparateMSBarSEpsilonAppliedAtS09" -> False
|>;

inputExpressionHashes = mapAssociationValues[
  Hash[#, "SHA256"] &,
  physicalAngular
];
s08CachePayloadEqualityChecks = <||>;
Do[
  acceptedS08Cache = Check[Get[s08CachePaths[projector]], $Failed];
  s08CachePayloadEqualityChecks[projector] =
    AssociationQ[acceptedS08Cache] &&
    acceptedS08Cache["Status"] === "Complete" &&
    acceptedS08Cache["StageVersion"] === "HqgS08-v5" &&
    acceptedS08Cache["Channel"] === "Hqg only" &&
    acceptedS08Cache["TensorRole"] === "RealQG" &&
    acceptedS08Cache["Projector"] === projector &&
    acceptedS08Cache["Provenance"] ===
      s08["CacheProvenance", "Expected", projector] &&
    acceptedS08Cache["ExpressionSHA256"] ===
      inputExpressionHashes[projector] &&
    acceptedS08Cache["Expression"] === physicalAngular[projector];
  assert[
    s08CachePayloadEqualityChecks[projector],
    "The accepted S08 " <> projector <>
      " cache failed exact metadata/hash/payload equality."
  ];
  Clear[acceptedS08Cache],
  {projector, projectorOrder}
];

twoBodyReferenceHashes = Association@Map[
  Function[sector,
    sector -> mapAssociationValues[
      Hash[#, "SHA256"] &,
      s08["TwoBodyPhaseSpaceIntegrated", sector]
    ]
  ],
  {"LO_OAlphaS", "NLOVirtualInterference_OAlphaS2_Symbolic"}
];
twoBodyReferenceGate =
  Keys[twoBodyReferenceHashes] ===
    {"LO_OAlphaS", "NLOVirtualInterference_OAlphaS2_Symbolic"} &&
  AllTrue[
    Values[twoBodyReferenceHashes],
    AssociationQ[#] && Keys[#] === projectorOrder &
  ];
assert[twoBodyReferenceGate,
  "The accepted hash-only LO/virtual projector references are incomplete."];

scalePowerInventory[expression_] :=
  Sort@DeleteDuplicates@Cases[
    expression,
    HoldPattern[Power[FeynCalc`ScaleMu, power_]] :> power,
    Infinity
  ];
scalePowersByProjector =
  mapAssociationValues[scalePowerInventory, physicalAngular];
scaleBookkeepingGate =
  Keys[scalePowersByProjector] === projectorOrder &&
  SameQ @@ Values[scalePowersByProjector] &&
  scalePowersByProjector === <|"Pg" -> {}, "PPP" -> {}|>;
assert[scaleBookkeepingGate,
  "The accepted S08 inputs do not preserve their measured empty ScaleMu inventory."];

unitWeightSolutions = Solve[
  s09Weight s09NonzeroKernel == s09NonzeroKernel,
  s09Weight
];
additionalMultiplicativeWeight =
  s09Weight /. First[unitWeightSolutions];
unitWeightGate =
  unitWeightSolutions === {{s09Weight -> 1}} &&
  additionalMultiplicativeWeight === 1;
assert[unitWeightGate,
  "The symbolic substitution-stage weight derivation did not give exactly one."];

masterOccurrencesByProjector = mapAssociationValues[
  Cases[#, _S08Case2Master, Infinity] &,
  physicalAngular
];
masterOccurrenceCounts =
  mapAssociationValues[Length, masterOccurrencesByProjector];
distinctMasterInstancesByProjector =
  mapAssociationValues[DeleteDuplicates, masterOccurrencesByProjector];
distinctMasterInstanceCounts =
  mapAssociationValues[Length, distinctMasterInstancesByProjector];
actualPairsByProjector = mapAssociationValues[
  Sort@DeleteDuplicates[
    ({#[[1]], #[[2]]} &) /@ #
  ] &,
  distinctMasterInstancesByProjector
];
pairClassCounts = mapAssociationValues[Length, actualPairsByProjector];
allDistinctMasterInstances =
  DeleteDuplicates@Flatten[Values[distinctMasterInstancesByProjector], 1];
allActualPairs =
  Sort@DeleteDuplicates@Flatten[Values[actualPairsByProjector], 1];

masterInventoryCompletenessGate =
  And @@ KeyValueMap[
    Function[{projector, occurrences},
      Length[occurrences] ===
        Count[physicalAngular[projector], _S08Case2Master, Infinity] &&
      AllTrue[
        occurrences,
        MatchQ[#, S08Case2Master[
          _Integer, _Integer, _, _, epsilon
        ]] &
      ]
    ],
    masterOccurrencesByProjector
  ];
masterInventoryMeasurementGate =
  masterOccurrenceCounts === <|"Pg" -> 61, "PPP" -> 43|> &&
  distinctMasterInstanceCounts === <|"Pg" -> 61, "PPP" -> 43|> &&
  pairClassCounts === <|"Pg" -> 24, "PPP" -> 18|> &&
  Length[allDistinctMasterInstances] === 63 &&
  Length[allActualPairs] === 25;
assert[masterInventoryCompletenessGate,
  "A malformed or omitted exact B19 master escaped the runtime inventory."];
assert[masterInventoryMeasurementGate,
  "The measured Hqg B19 occurrence/instance/class inventory changed."];

Print["S09_MASTER_PAIRS_BY_PROJECTOR=", InputForm[actualPairsByProjector]];
Print["S09_MASTER_OCCURRENCES=", InputForm[masterOccurrenceCounts]];
Print[
  "S09_MASTER_DISTINCT_INSTANCES=",
  InputForm[distinctMasterInstanceCounts]
];

Clear[s08];
ClearSystemCache[];

derivePolynomialB19Expansion[
    j_Integer, l_Integer, dSymbol_, cSymbol_, epsSymbol_
  ] := Module[{betaOne, betaTwo, integrand, exactIntegral, expansion},
  integrand =
    Sin[betaOne]^(1 - 2 epsSymbol) *
    Sin[betaTwo]^(-2 epsSymbol) *
    (dSymbol - Cos[betaOne])^(-j) *
    (1 - cSymbol Cos[betaOne] -
      Sqrt[1 - cSymbol^2] Sin[betaOne] Cos[betaTwo])^(-l);
  exactIntegral = Integrate[
    Expand[integrand],
    {betaTwo, 0, Pi},
    {betaOne, 0, Pi},
    Assumptions ->
      0 < epsSymbol < 1/4 && dSymbol > 1 && -1 < cSymbol < 1,
    GenerateConditions -> False
  ];
  assert[
    FreeQ[
      exactIntegral,
      _Integrate | _Inactive | _ConditionalExpression | $Failed | $Aborted |
        _Real
    ],
    "The direct two-angle B19 polynomial integration did not complete exactly."
  ];
  expansion = FullSimplify[
    Normal@Series[exactIntegral, {epsSymbol, 0, 2}],
    Assumptions -> dSymbol > 1 && -1 < cSymbol < 1
  ];
  assert[
    FreeQ[expansion, _SeriesData | _Integrate | _Inactive | $Failed | _Real],
    "A direct B19 polynomial expansion retained an invalid object."
  ];
  expansion
];

polynomialB19Expansions = <|
  HoldComplete[-2, -1] -> derivePolynomialB19Expansion[
    -2, -1, s09PolynomialD, s09PolynomialC, s09PolynomialEpsilon
  ],
  HoldComplete[-1, -2] -> derivePolynomialB19Expansion[
    -1, -2, s09PolynomialD, s09PolynomialC, s09PolynomialEpsilon
  ]
|>;
polynomialB19DerivationGate =
  Keys[polynomialB19Expansions] ===
    {HoldComplete[-2, -1], HoldComplete[-1, -2]} &&
  AllTrue[Values[polynomialB19Expansions], # =!= 0 &];
assert[polynomialB19DerivationGate,
  "The exact Hqg-only B19 polynomial derivation table is incomplete."];

appendixFBaseF8[d_, c_, eps_] :=
  Pi (5 c^3 d^2 - 4 c^3/3 -
    (c d - 1) (5 c^2 d^2 - 3 c^2 - 4 c d - 3 d^2 + 5) *
      Log[(d + 1)/(d - 1)]/2 -
    9 c^2 d - 3 c d^2 + 8 c + 3 d) +
  Pi eps (-(c d - 1) *
    (c^2 (5 d^2 - 3) - 4 c d - 3 d^2 + 5) *
      (PolyLog[2, 2/(d + 1)] - PolyLog[2, -2/(d - 1)])/2 +
    (117 c^3 d^2 - 32 c^3 -
      27 (c d - 1) (c^2 d^2 - c^2 - d^2 + 1) *
        Log[(d + 1)/(d - 1)]/2 -
      189 c^2 d - 81 c d^2 + 156 c + 81 d)/9);

derivedF9Canonical = FullSimplify[
  Normal@Series[
    -D[
      appendixFBaseF8[s09F9D, s09F9C, s09F9Epsilon],
      s09F9D
    ],
    {s09F9Epsilon, 0, 1}
  ],
  Assumptions -> s09F9D > 1 && -1 < s09F9C < 1
];
assert[
  FreeQ[
    derivedF9Canonical,
    _Derivative | _SeriesData | _Hypergeometric2F1 | $Failed | $Aborted |
      _Real
  ],
  "The Wolfram-derived corrected F9 expansion retained an invalid object."
];
derivedF9Expansion[d_, c_, eps_] :=
  derivedF9Canonical /. {
    s09F9D -> d,
    s09F9C -> c,
    s09F9Epsilon -> eps
  };

(* Appendix F abbreviations F1-F5 and required formulas F8-F29. *)
appendixFExpansion[j_Integer, l_Integer, d_, c_, eps_] := Module[
  {ll, kk, ff, gg},
  ll = Log[(d + 1)/(d - 1)];
  kk = PolyLog[2, 2/(d + 1)] - PolyLog[2, -2/(d - 1)];
  ff = c^2 (1 - 3 d^2) + 4 c d + d^2 - 3;
  gg = c^2 (3 d^2 - 1) - 4 c d - d^2 + 3;

  Switch[{j, l},
    (* Hqg-only polynomial B19 classes, derived above from the definition. *)
    {-2, -1},
      Lookup[
        polynomialB19Expansions,
        HoldComplete[-2, -1],
        $Failed
      ] /. {
        s09PolynomialD -> d,
        s09PolynomialC -> c,
        s09PolynomialEpsilon -> eps
      },

    {-1, -2},
      Lookup[
        polynomialB19Expansions,
        HoldComplete[-1, -2],
        $Failed
      ] /. {
        s09PolynomialD -> d,
        s09PolynomialC -> c,
        s09PolynomialEpsilon -> eps
      },

    (* F8. *)
    {1, -3},
      appendixFBaseF8[d, c, eps],

    (* Required corrected F9, generated from the B19 derivative relation. *)
    {2, -3},
      derivedF9Expansion[d, c, eps],

    (* F12-F13. *)
    {1, -2},
      Pi (d - 3 c^2 d + 4 c - ff ll/2) +
      Pi eps (-gg ll Log[(d - 1) (d + 1)^3/16]/4 -
        ll (-c^2 d^2 + c^2 + d^2 - 1)/2 +
        Pi^2 (c^2 (3 d^2 - 1) - 4 c d - d^2 + 3)/6 +
        c (8 - 7 c d) + 3 d -
        gg PolyLog[2, (d - 1)/(d + 1)]),

    {2, -2},
      Pi/(d^2 - 1) (c^2 (6 d^2 - 4) -
        (d^2 - 1) (c (3 c d - 2) - d) ll -
        4 c d - 2 d^2 + 4) +
      Pi eps (4 (2 c^2 + d (c d - 1)^2 ll/(2 (d^2 - 1)) - 1) -
        (c (3 c d - 2) - d) kk),

    (* F15-F25. *)
    {-1, -1},
      2 Pi (c/3 + d) + Pi eps (16 c/9 + 4 d),

    {-2, 0},
      2 Pi/3 (3 d^2 + 1) + 4 Pi eps/9 (9 d^2 + 4),

    {-1, 0},
      2 Pi d + 4 Pi d eps,

    {1, 0},
      Pi ll + Pi eps kk,

    {2, 0},
      2 Pi/(d^2 - 1) + 2 Pi eps d ll/(d^2 - 1),

    {1, -1},
      Pi (-(c d - 1) ll + 2 c) +
      Pi eps (4 c - Pi^2 (c d - 1)/3 +
        (c d - 1) ll Log[(d - 1) (d + 1)^3/16]/2 +
        2 (c d - 1) PolyLog[2, (d - 1)/(d + 1)]),

    {2, -1},
      -Pi (-c (d^2 - 1) ll + 2 c d - 2)/(d^2 - 1) +
      Pi eps (-ll (c (d^2 - 1) *
          Log[(d - 1) (d + 1)^3/16] + 4 d (c d - 1))/
          (2 (d^2 - 1)) + Pi^2 c/3 -
        2 c PolyLog[2, (d - 1)/(d + 1)]),

    {-2, 1},
      -Pi (c - d)^2/eps + Pi (-3 c^2 + 4 c d + 1) +
        Pi eps (-7 c^2 + 8 c d + 3),

    {-1, 1},
      Pi (c - d)/eps + 2 Pi c + 4 Pi eps c,

    {1, 1},
      Pi/(eps (c - d)) +
      Pi Log[(d^2 - 1)/(d - c)^2]/(c - d) +
      2 Pi eps/(c - d) (
        PolyLog[2, (c - 1)/(d - 1)] -
        PolyLog[2, (d - c)/(d + 1)] +
        Log[c + 1] Log[(d + 1)/(d - c)] +
        Log[d - c] Log[(d - c)/(d - 1)] -
        ll Log[(d - 1) (d + 1)^3]/4 + Pi^2/6),

    {2, 1},
      -Pi/(eps (d - c)^2) +
      Pi/((d^2 - 1) (c - d)^2) (
        (d^2 - 1) Log[(d - c)^2/(d^2 - 1)] - 2 c d + 2) +
      2 Pi eps/(c - d)^2 (
        PolyLog[2, (d - c)/(d + 1)] -
        PolyLog[2, (c - 1)/(d - 1)]) -
      Pi eps/(6 (d^2 - 1) (c - d)^2) (
        12 Log[d + 1] ((d^2 - 1) Log[c + 1] +
          c + d^2 - d - 1) -
        12 Log[d - 1] ((d^2 - 1) Log[d - c] +
          c - d^2 - d + 1) +
        (d^2 - 1) (2 (6 Log[d - c] *
          (Log[(d - c)/(c + 1)] - 2) + Pi^2) -
          3 ll Log[(d - 1) (d + 1)^3])),

    (* F27-F29. *)
    {-1, 2},
      -Pi c/eps + Pi (c - d) + Pi eps (d - c),

    {1, 2},
      Pi (1 - c d)/(eps (c - d)^3) +
      Pi/(c - d)^3 (-c^2 - 2 c d + d^2 + 2 +
        (c d - 1) Log[(d - c)^2/(d^2 - 1)]),

    {2, 2},
      Pi (c^2 + 2 c d - 3)/(eps (c - d)^4) +
      Pi/((d^2 - 1) (c - d)^4) (
        c^2 (7 d^2 - 5) +
        (d^2 - 1) (c^2 + 2 c d - 3) *
          Log[(d^2 - 1)/(d - c)^2] +
        2 (d^2 - 3) c d - d^2 (d^2 + 5) + 8),

    _, $Failed
  ]
];

(* B18: j=0 is independent of D and C. *)
appendixFZeroJ[l_Integer, eps_] := Module[{exact},
  exact = 2 Pi Gamma[1 - 2 eps]/Gamma[1 - eps]^2 *
    2^(-l) Beta[1 - eps, 1 - eps - l];
  Normal@Series[FunctionExpand[exact], {eps, 0, 2}]
];

zeroJLValues = Sort@DeleteDuplicates[
  Last /@ Select[allActualPairs, First[#] === 0 &]
];
zeroJExpansions = Association@Map[
  Function[l, ToString[l] -> appendixFZeroJ[l, epsilon]],
  zeroJLValues
];
zeroJCoverageGate =
  Length[zeroJExpansions] === Length[zeroJLValues] &&
  AllTrue[
    Values[zeroJExpansions],
    # =!= $Failed && FreeQ[#, _Beta | _Gamma | _SeriesData | _Real] &
  ];
assert[zeroJCoverageGate,
  "The runtime-derived exact B18 j=0 expansion table is incomplete."];

implementedNonzeroPairs =
  Sort@Select[allActualPairs, First[#] =!= 0 &];
nonzeroFormulaCoverageGate = AllTrue[
  implementedNonzeroPairs,
  With[{
    formula = appendixFExpansion[
      #[[1]], #[[2]], s09CoverageD, s09CoverageC, epsilon
    ]
  },
    formula =!= $Failed &&
    FreeQ[formula, $Failed | _Derivative | _SeriesData | _Real]
  ] &
];
assert[nonzeroFormulaCoverageGate,
  "At least one runtime-inventoried Hqg nonzero-j formula is unavailable."];

polynomialB19SubstitutionResiduals = <|
  "jMinus2_lMinus1" -> FullSimplify[
    appendixFExpansion[
      -2, -1, s09PolynomialD, s09PolynomialC,
      s09PolynomialEpsilon
    ] - Lookup[
      polynomialB19Expansions,
      HoldComplete[-2, -1],
      $Failed
    ],
    Assumptions ->
      s09PolynomialD > 1 && -1 < s09PolynomialC < 1
  ],
  "jMinus1_lMinus2" -> FullSimplify[
    appendixFExpansion[
      -1, -2, s09PolynomialD, s09PolynomialC,
      s09PolynomialEpsilon
    ] - Lookup[
      polynomialB19Expansions,
      HoldComplete[-1, -2],
      $Failed
    ],
    Assumptions ->
      s09PolynomialD > 1 && -1 < s09PolynomialC < 1
  ]
|>;
polynomialB19ResidualGate =
  AllTrue[Values[polynomialB19SubstitutionResiduals], TrueQ[# === 0] &];
assert[polynomialB19ResidualGate,
  "An Hqg-only polynomial substitution differs from its direct B19 derivation."];

correctedF9RecurrenceResidual = FullSimplify[
  Together@Normal@Series[
    D[
      appendixFBaseF8[s09F9D, s09F9C, s09F9Epsilon],
      s09F9D
    ] + derivedF9Expansion[
      s09F9D, s09F9C, s09F9Epsilon
    ],
    {s09F9Epsilon, 0, 1}
  ],
  Assumptions -> s09F9D > 1 && -1 < s09F9C < 1
];
correctedF9RecurrenceGate = correctedF9RecurrenceResidual === 0;
assert[correctedF9RecurrenceGate,
  "The corrected required F9 is not exactly -D_D F8 through epsilon^1."];

masterExpansionRule = HoldPattern[
  S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon]
] :> If[
    j === 0,
    Lookup[zeroJExpansions, ToString[l], $Failed],
    appendixFExpansion[j, l, d, c, epsilon]
  ];

expandOneMaster[master_S08Case2Master] :=
  master /. masterExpansionRule;

expandAppendixFMasters[expression_] :=
  expression /. masterExpansionRule;

(*
  Exact recurrence audit from B19:
      partial_D I[j,l](D,C) = -j I[j+1,l](D,C).
  All logarithm rewrites below are valid on Appendix F's physical branch
  D>1, -1<C<1.  They are explicit physical-branch identities.
*)
toRecurrenceBasis[expression_, d_Symbol, c_Symbol] := Module[
  {lp, lm, lc, ldc, logTwo, answer},
  lp = Log[d + 1];
  lm = Log[d - 1];
  lc = Log[c + 1];
  ldc = Log[d - c];
  logTwo = Log[2];
  answer = expression /. {
    (HoldPattern[PolyLog[2, argument_]] /;
        TrueQ[Together[argument + 2/(d - 1)] === 0]) :>
      PolyLog[2, 2/(d + 1)] - S09K[d],
    (HoldPattern[PolyLog[2, argument_]] /;
        TrueQ[Together[argument - (d - 1)/(d + 1)] === 0]) :>
      Pi^2/6 - S09K[d]/2 -
        (lp - lm) (lm + 3 lp - 4 logTwo)/4,
    (HoldPattern[PolyLog[2, argument_]] /;
        TrueQ[Together[argument - (c - 1)/(d - 1)] === 0]) :>
      S09A[c, d],
    (HoldPattern[PolyLog[2, argument_]] /;
        TrueQ[Together[argument - (d - c)/(d + 1)] === 0]) :>
      S09B[c, d],
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d + 1)/(d - 1)] === 0]) :>
      lp - lm,
    (HoldPattern[Log[argument_]] /;
        TrueQ[
          Together[argument - (d - 1) (d + 1)^3/16] === 0
        ]) :>
      lm + 3 lp - 4 logTwo,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d - 1) (d + 1)^3] === 0]) :>
      lm + 3 lp,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d - c)^2/(d^2 - 1)] === 0]) :>
      2 ldc - lm - lp,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d^2 - 1)/(d - c)^2] === 0]) :>
      lm + lp - 2 ldc,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d + 1)/(d - c)] === 0]) :>
      lp - ldc,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d - c)/(d - 1)] === 0]) :>
      ldc - lm,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (d - c)/(c + 1)] === 0]) :>
      ldc - lc,
    (HoldPattern[Log[argument_]] /;
        TrueQ[Together[argument - (c + 1)/(d + 1)] === 0]) :>
      lc - lp
  };
  answer
];

recurrenceResidual[j_Integer, l_Integer, order_Integer] := Module[
  {d, c, left, right, residual},
  d = s09RecurrenceD;
  c = s09RecurrenceC;
  left = If[
    j === 0,
    appendixFZeroJ[l, epsilon],
    appendixFExpansion[j, l, d, c, epsilon]
  ];
  right = If[
    j + 1 === 0,
    appendixFZeroJ[l, epsilon],
    appendixFExpansion[j + 1, l, d, c, epsilon]
  ];
  assert[left =!= $Failed && right =!= $Failed,
    "A recurrence partner formula is unavailable."];
  left = toRecurrenceBasis[left, d, c];
  right = toRecurrenceBasis[right, d, c];
  residual = D[left, d] + j right;
  residual = residual /. {
    (HoldPattern[Derivative[1][S09K][argument_]] /;
        SameQ[argument, d]) :>
      -2 d (Log[d + 1] - Log[d - 1])/(d^2 - 1),
    (HoldPattern[Derivative[0, 1][S09A][cArgument_, dArgument_]] /;
        SameQ[cArgument, c] && SameQ[dArgument, d]) :>
      (Log[d - c] - Log[d - 1])/(d - 1),
    (HoldPattern[Derivative[0, 1][S09B][cArgument_, dArgument_]] /;
        SameQ[cArgument, c] && SameQ[dArgument, d]) :>
      -(c + 1) (Log[c + 1] - Log[d + 1])/
        ((d + 1) (d - c))
  };
  residual = toRecurrenceBasis[residual, d, c];
  residual = Normal@Series[residual, {epsilon, 0, order}];
  FullSimplify[
    Together[Expand[residual]],
    Assumptions -> d > 1 && -1 < c < 1
  ]
];

recurrencePairSpecifications = Map[
  Function[pair,
    <|
      "Pair" -> pair,
      "Order" -> If[pair === {1, 2}, 0, 1]
    |>
  ],
  Select[
    allActualPairs,
    Function[pair,
      First[pair] =!= 0 &&
      MemberQ[allActualPairs, {First[pair] + 1, Last[pair]}]
    ]
  ]
];
recurrenceInventoryGate =
  Length[recurrencePairSpecifications] > 0 &&
  AllTrue[
    recurrencePairSpecifications,
    MemberQ[allActualPairs, #["Pair"]] &&
      MemberQ[
        allActualPairs,
        {First[#["Pair"]] + 1, Last[#["Pair"]]}
      ] &
  ];
assert[recurrenceInventoryGate,
  "No complete runtime-derived adjacent B19 recurrence inventory was found."];

b19F8MomentResiduals[] := Module[
  {
    x, y, d, c, eps, betaTwo, unitVariable, betaTwoMomentsExact,
    betaTwoMomentSeries, angularNumerator, betaTwoReducedSeries,
    betaOneNumeratorSeries, logIdentityResidual,
    canonicalNumeratorSeries, leadingPolynomial, epsilonPolynomial,
    epsilonOrdinaryPolynomial, epsilonLogPolynomial,
    plainPolynomialMoments, logarithmicPolynomialMoments,
    logSplitResidual, kkFirstInactive, kkSecondInactive,
    kkFirstTransformed, kkSecondTransformed,
    kkFirstOrientation, kkSecondOrientation,
    kkFirstDefinition, kkSecondDefinition,
    llDefinition, kkDefinition, llResidual, kkResidual,
    ordinaryMoment, logarithmicMoment, directLeading, directEpsilon,
    paperLeading, paperEpsilon, canonicalizePaper, maxDegree
  },
  x = s09MomentX;
  y = s09MomentY;
  d = s09MomentD;
  c = s09MomentC;
  eps = s09MomentEpsilon;
  betaTwo = s09MomentBetaTwo;
  unitVariable = s09MomentUnitVariable;

  betaTwoMomentsExact = AssociationMap[
    Function[k,
      FullSimplify[
        Integrate[
          Sin[betaTwo]^(-2 eps) Cos[betaTwo]^k,
          {betaTwo, 0, Pi},
          Assumptions -> 0 < eps < 1/4,
          GenerateConditions -> False
        ],
        Assumptions -> 0 < eps < 1/4
      ]
    ],
    Range[0, 3]
  ];
  betaTwoMomentSeries = Map[
    Function[moment,
      FullSimplify[
        FunctionExpand[Normal@Series[moment, {eps, 0, 1}]],
        Assumptions -> 0 < eps < 1/4
      ]
    ],
    betaTwoMomentsExact
  ];
  assert[
    AllTrue[
      Values[betaTwoMomentSeries],
      FreeQ[
        #,
        _Integrate | _Inactive | _Hypergeometric2F1 | _Derivative |
          _SeriesData | $Failed | $Aborted | _Real
      ] &
    ],
    "The exact beta-two B19 moment derivation did not complete."
  ];

  angularNumerator = Expand[
    (1 - c x - Sqrt[1 - c^2] Sqrt[1 - x^2] y)^3
  ];
  betaTwoReducedSeries = Normal@Series[
    Sum[
      Coefficient[angularNumerator, y, k] *
        betaTwoMomentSeries[k],
      {k, 0, 3}
    ],
    {eps, 0, 1}
  ];
  betaOneNumeratorSeries = Expand@Normal@Series[
    (1 - x^2)^(-eps) betaTwoReducedSeries,
    {eps, 0, 1}
  ];

  logIdentityResidual = FullSimplify[
    Log[1 - x^2] - (Log[4] - Log[4/(1 - x^2)]),
    Assumptions -> -1 < x < 1
  ];
  assert[logIdentityResidual === 0,
    "The physical-branch logarithm identity for the F8 moment audit failed."];

  canonicalNumeratorSeries = With[
    {xSymbol = x},
    betaOneNumeratorSeries /.
      HoldPattern[Log[1 - xSymbol^2]] :>
        Log[4] - s09MomentLogX
  ];
  leadingPolynomial = Expand@Coefficient[
    canonicalNumeratorSeries,
    eps,
    0
  ];
  epsilonPolynomial = Expand@Coefficient[
    canonicalNumeratorSeries,
    eps,
    1
  ];
  epsilonOrdinaryPolynomial =
    Expand[epsilonPolynomial /. s09MomentLogX -> 0];
  epsilonLogPolynomial =
    Expand@Coefficient[epsilonPolynomial, s09MomentLogX, 1];

  plainPolynomialMoments = AssociationMap[
    Function[k,
      Integrate[x^k, {x, -1, 1}, GenerateConditions -> False]
    ],
    Range[0, 3]
  ];
  logarithmicPolynomialMoments = AssociationMap[
    Function[k,
      FullSimplify[
        Integrate[
          x^k Log[4/(1 - x^2)],
          {x, -1, 1},
          Assumptions -> -1 < x < 1,
          GenerateConditions -> False
        ]
      ]
    ],
    Range[0, 3]
  ];
  assert[
    AllTrue[
      Join[
        Values[plainPolynomialMoments],
        Values[logarithmicPolynomialMoments]
      ],
      FreeQ[#,
        _Integrate | _Inactive | _ConditionalExpression | $Failed |
          $Aborted | _Real] &
    ],
    "A beta-one ordinary/logarithmic polynomial moment was not derived exactly."
  ];

  llDefinition = FullSimplify[
    Integrate[
      1/(d - x),
      {x, -1, 1},
      Assumptions -> d > 1,
      GenerateConditions -> False
    ],
    Assumptions -> d > 1
  ];
  logSplitResidual = FullSimplify[
    Log[4/(1 - x^2)] -
      Log[2/(1 - x)] - Log[2/(1 + x)],
    Assumptions -> -1 < x < 1
  ];
  assert[logSplitResidual === 0,
    "The physical-domain K logarithm split was not exact."];
  kkFirstInactive = Inactive[Integrate][
    Log[2/(1 - x)]/(d - x),
    {x, -1, 1}
  ];
  kkSecondInactive = Inactive[Integrate][
    Log[2/(1 + x)]/(d - x),
    {x, -1, 1}
  ];
  kkFirstTransformed = Quiet@Check[
    IntegrateChangeVariables[
      kkFirstInactive,
      unitVariable,
      unitVariable == (1 - x)/2
    ],
    $Failed
  ];
  kkSecondTransformed = Quiet@Check[
    IntegrateChangeVariables[
      kkSecondInactive,
      unitVariable,
      unitVariable == (1 + x)/2
    ],
    $Failed
  ];
  assert[
    kkFirstTransformed =!= $Failed &&
      kkSecondTransformed =!= $Failed &&
      Head[kkFirstTransformed] === Inactive[Integrate] &&
      Head[kkSecondTransformed] === Inactive[Integrate],
    "The branch-safe K change of variables did not complete."
  ];
  kkFirstOrientation = FullSimplify[
    Sign[D[(1 - x)/2, x]],
    Assumptions -> -1 < x < 1
  ];
  kkSecondOrientation = FullSimplify[
    Sign[D[(1 + x)/2, x]],
    Assumptions -> -1 < x < 1
  ];
  kkFirstDefinition = FullSimplify[
    kkFirstOrientation Activate[kkFirstTransformed],
    Assumptions -> d > 1
  ];
  kkSecondDefinition = FullSimplify[
    kkSecondOrientation Activate[kkSecondTransformed],
    Assumptions -> d > 1
  ];
  kkDefinition = FullSimplify[
    kkFirstDefinition + kkSecondDefinition,
    Assumptions -> d > 1
  ];
  llResidual = FullSimplify[
    llDefinition - Log[(d + 1)/(d - 1)],
    Assumptions -> d > 1
  ];
  kkResidual = FullSimplify[
    kkDefinition -
      (PolyLog[2, 2/(d + 1)] - PolyLog[2, -2/(d - 1)]),
    Assumptions -> d > 1
  ];

  ordinaryMoment[n_Integer] :=
    d^n s09MomentL - If[
      n === 0,
      0,
      Sum[
        d^(n - 1 - k) plainPolynomialMoments[k],
        {k, 0, n - 1}
      ]
    ];
  logarithmicMoment[n_Integer] :=
    d^n s09MomentK - If[
      n === 0,
      0,
      Sum[
        d^(n - 1 - k) logarithmicPolynomialMoments[k],
        {k, 0, n - 1}
      ]
    ];

  maxDegree = Max[
    Exponent[leadingPolynomial, x],
    Exponent[epsilonOrdinaryPolynomial, x],
    Exponent[epsilonLogPolynomial, x]
  ];
  directLeading = Sum[
    Coefficient[leadingPolynomial, x, n] ordinaryMoment[n],
    {n, 0, maxDegree}
  ];
  directEpsilon = Sum[
    Coefficient[epsilonOrdinaryPolynomial, x, n] ordinaryMoment[n] +
      Coefficient[epsilonLogPolynomial, x, n] logarithmicMoment[n],
    {n, 0, maxDegree}
  ];

  canonicalizePaper[expression_] := Together@Expand[
    expression /. {
      (HoldPattern[PolyLog[2, argument_]] /;
          TrueQ[Together[argument + 2/(d - 1)] === 0]) :>
        PolyLog[2, 2/(d + 1)] - s09MomentK,
      (HoldPattern[Log[argument_]] /;
          TrueQ[Together[argument - (d + 1)/(d - 1)] === 0]) :>
        s09MomentL
    }
  ];
  paperLeading = canonicalizePaper[
    Coefficient[
      appendixFBaseF8[d, c, epsilon],
      epsilon,
      0
    ]
  ];
  paperEpsilon = canonicalizePaper[
    Coefficient[
      appendixFBaseF8[d, c, epsilon],
      epsilon,
      1
    ]
  ];

  <|
    "BetaTwoOddMomentOne" -> betaTwoMomentSeries[1],
    "BetaTwoOddMomentThree" -> betaTwoMomentSeries[3],
    "KLogSplitResidual" -> logSplitResidual,
    "LDefinitionResidual" -> llResidual,
    "KDefinitionResidual" -> kkResidual,
    "F8LeadingFromB19Moments" ->
      FullSimplify[
        Together[paperLeading - directLeading],
        Assumptions -> d > 1 && -1 < c < 1
      ],
    "F8EpsilonFromB19Moments" ->
      FullSimplify[
        Together[paperEpsilon - directEpsilon],
        Assumptions -> d > 1 && -1 < c < 1
      ]
  |>
];

f9B19AngularFactor =
  1 - s09F9ReductionC Cos[s09NumericBetaOne] -
    Sqrt[1 - s09F9ReductionC^2] Sin[s09NumericBetaOne] *
      Cos[s09NumericBetaTwo];
f9B19BetaTwoExact = FullSimplify[
  Integrate[
    Sin[s09NumericBetaTwo]^(-2 s09F9ReductionEpsilon) *
      f9B19AngularFactor^3,
    {s09NumericBetaTwo, 0, Pi},
    Assumptions ->
      0 < s09F9ReductionEpsilon < 1/4 &&
      -1 < s09F9ReductionC < 1 &&
      0 < s09NumericBetaOne < Pi,
    GenerateConditions -> False
  ],
  Assumptions ->
    0 < s09F9ReductionEpsilon < 1/4 &&
    -1 < s09F9ReductionC < 1 &&
    0 < s09NumericBetaOne < Pi
];
f9B19BetaTwoMomentReconstruction = FullSimplify[
  Sum[
    Coefficient[
      Expand[f9B19AngularFactor^3],
      Cos[s09NumericBetaTwo],
      power
    ] *
      Integrate[
        Sin[s09NumericBetaTwo]^(-2 s09F9ReductionEpsilon) *
          Cos[s09NumericBetaTwo]^power,
        {s09NumericBetaTwo, 0, Pi},
        Assumptions -> 0 < s09F9ReductionEpsilon < 1/4,
        GenerateConditions -> False
      ],
    {power, 0, 3}
  ],
  Assumptions ->
    0 < s09F9ReductionEpsilon < 1/4 &&
    -1 < s09F9ReductionC < 1 &&
    0 < s09NumericBetaOne < Pi
];
f9B19BetaTwoReductionResidual = FullSimplify[
  f9B19BetaTwoExact - f9B19BetaTwoMomentReconstruction,
  Assumptions ->
    0 < s09F9ReductionEpsilon < 1/4 &&
    -1 < s09F9ReductionC < 1 &&
    0 < s09NumericBetaOne < Pi
];
f9B19BetaTwoReductionGate =
  f9B19BetaTwoReductionResidual === 0 &&
  f9B19BetaTwoExact =!= 0 &&
  FreeQ[
    f9B19BetaTwoExact,
    _Integrate | _Inactive | _ConditionalExpression | $Failed | $Aborted |
      _Real
  ];
assert[f9B19BetaTwoReductionGate,
  "The exact F9 B19 beta-two reduction did not complete."];

f9B19ReducedNumeric[
    dValue_?NumericQ, cValue_?NumericQ, epsValue_?NumericQ
  ] := NIntegrate[
  Evaluate[
    Sin[s09NumericBetaOne]^(1 - 2 s09F9ReductionEpsilon) *
      f9B19BetaTwoExact/
      (s09F9ReductionD - Cos[s09NumericBetaOne])^2 /. {
        s09F9ReductionD -> dValue,
        s09F9ReductionC -> cValue,
        s09F9ReductionEpsilon -> epsValue
      }
  ],
  {s09NumericBetaOne, 0, Pi},
  WorkingPrecision -> 50,
  AccuracyGoal -> 25,
  PrecisionGoal -> 25,
  MaxRecursion -> 18,
  Method -> {
    "GlobalAdaptive",
    "SymbolicProcessing" -> 0,
    "MaxErrorIncreases" -> 1000
  }
];

f9B19TestPoints = {{2, 0}, {5/2, 1/3}, {3, -1/4}};
f9B19EpsilonValues = {1/200, 1/400, 1/800};
f9B19NumericData = Association@Map[
  Function[point,
    ToString[InputForm[point]] -> Module[
      {residuals, scaledResiduals, relativeDrift, decreasing},
      residuals = Map[
        Function[epsValue,
          N[
            derivedF9Expansion[
              s09F9D, s09F9C, s09F9Epsilon
            ] /. {
              s09F9D -> point[[1]],
              s09F9C -> point[[2]],
              s09F9Epsilon -> epsValue
            },
            50
          ] -
          f9B19ReducedNumeric[
            N[point[[1]], 50], N[point[[2]], 50],
            N[epsValue, 50]
          ]
        ],
        f9B19EpsilonValues
      ];
      scaledResiduals =
        residuals/(N[f9B19EpsilonValues, 50]^2);
      relativeDrift =
        Abs[(scaledResiduals[[-1]] - scaledResiduals[[-2]])/
          scaledResiduals[[-1]]];
      decreasing =
        And @@ Thread[
          Rest[Abs[residuals]] < Most[Abs[residuals]]
        ];
      <|
        "Residuals" -> residuals,
        "ScaledResiduals" -> scaledResiduals,
        "RelativeFinalDrift" -> relativeDrift,
        "ResidualMagnitudeDecreases" -> decreasing,
        "OrderGate" -> TrueQ[
          decreasing && relativeDrift < 1/50 &&
          AllTrue[
            residuals,
            Precision[#] > 30 && Accuracy[#] > 20 &
          ]
        ]
      |>
    ]
  ],
  f9B19TestPoints
];
f9B19NumericOrderGate =
  AllTrue[Values[f9B19NumericData], TrueQ[#["OrderGate"]] &];
assert[f9B19NumericOrderGate,
  "Corrected F9 failed the reduced high-precision B19 O(epsilon^2) regression."];

Print["S09_STAGE: checking Appendix-F formulas with the exact B19 recurrence"];
appendixFRecurrenceResiduals = Association@Map[
  Function[specification,
    With[{pair = specification["Pair"]},
      ToString[InputForm[pair]] -> recurrenceResidual[
        pair[[1]],
        pair[[2]],
        specification["Order"]
      ]
    ]
  ],
  recurrencePairSpecifications
];
b19F8Residuals = b19F8MomentResiduals[];
appendixFRecurrenceGate =
  AllTrue[Values[appendixFRecurrenceResiduals], TrueQ[# === 0] &];
b19F8Gate =
  AllTrue[Values[b19F8Residuals], TrueQ[# === 0] &];
Print[
  "S09_APPENDIX_F_RECURRENCE_RESIDUALS=",
  InputForm[appendixFRecurrenceResiduals]
];
Print[
  "S09_F8_B19_MOMENT_RESIDUALS=",
  InputForm[b19F8Residuals]
];
assert[appendixFRecurrenceGate,
  "At least one runtime-required exact Appendix-F/B18 recurrence failed."];
assert[b19F8Gate,
  "F8 failed its independent exact B19 angular-moment validation."];

hypergeometricSignaturesByProjector = mapAssociationValues[
  Sort@DeleteDuplicates@Cases[
    #,
    Hypergeometric2F1[a_, b_, cc_, w_] :> HoldComplete[a, b, cc],
    Infinity
  ] &,
  physicalAngular
];
hypergeometricCountsByProjector = mapAssociationValues[
  Count[#, _Hypergeometric2F1, Infinity] &,
  physicalAngular
];
hypergeometricSignatureCountsByProjector = mapAssociationValues[
  Function[expression,
    Counts@Cases[
      expression,
      Hypergeometric2F1[a_, b_, cc_, w_] :>
        HoldComplete[a, b, cc],
      Infinity
    ]
  ],
  physicalAngular
];
betaObjects = Sort@DeleteDuplicates@Cases[
  Values[physicalAngular],
  _Beta,
  Infinity
];
betaSignatures = betaObjects /. Beta[a_, b_] :> HoldComplete[a, b];
gammaObjects = Sort@DeleteDuplicates@Cases[
  Values[physicalAngular],
  _Gamma,
  Infinity
];

Print[
  "S09_B27_B30_SIGNATURES=",
  InputForm[hypergeometricSignaturesByProjector]
];
Print[
  "S09_B27_B30_COUNTS=",
  InputForm[hypergeometricCountsByProjector]
];
Print["S09_B18_BETA_SIGNATURES=", InputForm[betaSignatures]];
Print["S09_B18_GAMMA_OBJECTS=", InputForm[gammaObjects]];

hypergeometricInventoryGate =
  hypergeometricSignaturesByProjector === <|
    "Pg" -> {
      HoldComplete[1, 1, 1 - epsilon],
      HoldComplete[1, 2, 1 - epsilon]
    },
    "PPP" -> {HoldComplete[1, 1, 1 - epsilon]}
  |> &&
  hypergeometricCountsByProjector === <|"Pg" -> 3, "PPP" -> 2|> &&
  Total[Values[hypergeometricCountsByProjector]] === 5;
assert[hypergeometricInventoryGate,
  "The measured residual B27/B30 hypergeometric inventory changed."];

betaGammaInventoryGate =
  Sort[betaSignatures] === Sort@{
    HoldComplete[2 - epsilon, 2 - epsilon],
    HoldComplete[2 - epsilon, -epsilon],
    HoldComplete[3 - epsilon, 2 - epsilon],
    HoldComplete[3 - epsilon, -epsilon],
    HoldComplete[-epsilon, -1 - epsilon],
    HoldComplete[-epsilon, 2 - epsilon],
    HoldComplete[-epsilon, -epsilon]
  } &&
  gammaObjects === {Gamma[1 - 2 epsilon], Gamma[1 - epsilon]};
assert[betaGammaInventoryGate,
  "The exact current-input B18 Beta/Gamma inventory changed."];

b27Expansion[argument_] :=
  (1 - argument)^(-1 - epsilon) *
    (1 + epsilon^2 PolyLog[2, argument]);

b30Equation =
  s09B30F12 ==
    1/(1 - s09B30W) *
      (-epsilon + (epsilon + 1) s09B30F11);
b30SolveRules = Solve[b30Equation, s09B30F12];
b30SolveGate =
  Length[b30SolveRules] === 1 &&
  MatchQ[First[b30SolveRules], {Rule[s09B30F12, _]}];
assert[b30SolveGate,
  "Wolfram Solve did not uniquely derive F(1,2,1-epsilon) from Eq. B30."];

b30ExpansionCanonical = Together@Normal@Series[
  (s09B30F12 /. First[b30SolveRules]) /.
    s09B30F11 -> b27Expansion[s09B30W],
  {epsilon, 0, 2}
];
b30ExpansionPurityGate = FreeQ[
  b30ExpansionCanonical,
  _Hypergeometric2F1 | _Derivative | _SeriesData | $Failed | $Aborted |
    _Real
];
assert[b30ExpansionPurityGate,
  "The Eq. B30/B27-derived expansion retained an invalid object."];

b30DefiningSeriesCoefficientResidual = FullSimplify[
  FunctionExpand[
    Pochhammer[1, s09SeriesIndex] *
      Pochhammer[2, s09SeriesIndex]/
      (Pochhammer[1 - epsilon, s09SeriesIndex] *
        Factorial[s09SeriesIndex]) -
    (s09SeriesIndex + 1) *
      Pochhammer[1, s09SeriesIndex]^2/
      (Pochhammer[1 - epsilon, s09SeriesIndex] *
        Factorial[s09SeriesIndex])
  ],
  Assumptions ->
    Element[s09SeriesIndex, Integers] && s09SeriesIndex >= 0
];
b30DefiningSeriesCoefficientGate =
  b30DefiningSeriesCoefficientResidual === 0;
assert[b30DefiningSeriesCoefficientGate,
  "The arbitrary-index defining-series coefficient identity for F(1,2) failed."];

b30RegressionWValues = {1/5, 2/5, 3/5};
b30RegressionEpsilonValues = {1/1000, 1/2000, 1/4000};
b30NumericalRegression = Association@Map[
  Function[wValue,
    ToString[InputForm[wValue]] -> Module[
      {residuals, scaledResiduals, relativeDrift},
      residuals = Map[
        Function[epsValue,
          N[
            Hypergeometric2F1[
              1, 2, 1 - epsValue, wValue
            ],
            60
          ] -
          N[
            b30ExpansionCanonical /. {
              s09B30W -> wValue,
              epsilon -> epsValue
            },
            60
          ]
        ],
        b30RegressionEpsilonValues
      ];
      scaledResiduals =
        residuals/(N[b30RegressionEpsilonValues, 60]^3);
      relativeDrift =
        Abs[(scaledResiduals[[-1]] - scaledResiduals[[-2]])/
          scaledResiduals[[-1]]];
      <|
        "Residuals" -> residuals,
        "ScaledResiduals" -> scaledResiduals,
        "RelativeFinalDrift" -> relativeDrift,
        "OrderGate" -> TrueQ[
          relativeDrift < 1/100 &&
          AllTrue[residuals, Precision[#] > 40 &]
        ]
      |>
    ]
  ],
  b30RegressionWValues
];
b30NumericalOrderGate =
  AllTrue[Values[b30NumericalRegression], TrueQ[#["OrderGate"]] &];
assert[b30NumericalOrderGate,
  "The Eq. B30/B27 expansion failed its high-precision O(epsilon^3) regression."];

betaRules = Map[
  Function[betaObject,
    betaObject -> Normal@Series[
      FunctionExpand[betaObject],
      {epsilon, 0, 2}
    ]
  ],
  betaObjects
];
betaExpansionGate =
  AllTrue[
    Last /@ betaRules,
    FreeQ[#,
      _Beta | _Gamma | _Hypergeometric2F1 | _SeriesData | $Failed |
        $Aborted | _Real] &
  ];
assert[betaExpansionGate,
  "At least one measured Beta object failed exact expansion through epsilon^2."];

gammaRatio1 = Normal@Series[
  Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2,
  {epsilon, 0, 2}
];
gammaRatio2 = Normal@Series[
  Gamma[1 - epsilon]/Gamma[1 - 2 epsilon],
  {epsilon, 0, 2}
];
gammaOneSeries = Normal@Series[
  Gamma[1 - epsilon],
  {epsilon, 0, 2}
];
gammaTwoSeries = Normal@Series[
  Gamma[1 - 2 epsilon],
  {epsilon, 0, 2}
];
gammaSeriesRatioRegression = <|
  "GammaOneMinusTwoEpsilonOverGammaOneMinusEpsilonSquared" ->
    Together@Normal@Series[
      gammaTwoSeries/gammaOneSeries^2 - gammaRatio1,
      {epsilon, 0, 2}
    ],
  "GammaOneMinusEpsilonOverGammaOneMinusTwoEpsilon" ->
    Together@Normal@Series[
      gammaOneSeries/gammaTwoSeries - gammaRatio2,
      {epsilon, 0, 2}
    ]
|>;
gammaSeriesRatioGate =
  AllTrue[Values[gammaSeriesRatioRegression], TrueQ[# === 0] &];
assert[gammaSeriesRatioGate,
  "Individual Gamma series do not reconstruct both required ratios through epsilon^2."];

case1ExpansionRules = Join[
  {
    HoldPattern[
      Hypergeometric2F1[1, 2, 1 - epsilon, w_]
    ] :> (b30ExpansionCanonical /. s09B30W -> w),
    HoldPattern[
      Hypergeometric2F1[1, 1, 1 - epsilon, w_]
    ] :> b27Expansion[w]
  },
  betaRules,
  {
    HoldPattern[
      Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2
    ] :> gammaRatio1,
    HoldPattern[
      Gamma[1 - epsilon]/Gamma[1 - 2 epsilon]
    ] :> gammaRatio2,
    (HoldPattern[Gamma[argument_]] /;
        TrueQ[Together[argument - (1 - epsilon)] === 0]) :>
      gammaOneSeries,
    (HoldPattern[Gamma[argument_]] /;
        TrueQ[Together[argument - (1 - 2 epsilon)] === 0]) :>
      gammaTwoSeries
  }
];

expandCase1Functions[expression_] :=
  expression /. case1ExpansionRules;

allExpansionRules = Prepend[case1ExpansionRules, masterExpansionRule];
expandAllRequiredFunctions[expression_] :=
  expression /. allExpansionRules;

expansionFusionProbeObjects = DeleteDuplicates@Join[
  Flatten[Values[distinctMasterInstancesByProjector]],
  Cases[Values[physicalAngular], _Hypergeometric2F1, Infinity],
  betaObjects,
  gammaObjects,
  {
    Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2,
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon]
  }
];
expansionFusionProbe = Total[expansionFusionProbeObjects];
expansionFusionResidual =
  expandAllRequiredFunctions[expansionFusionProbe] -
    expandCase1Functions[expandAppendixFMasters[expansionFusionProbe]];
expansionFusionGate = SameQ[expansionFusionResidual, 0];
assert[expansionFusionGate,
  "The fused Appendix-F/B18/B27/B30 replacement differs from the sequential route."];
Clear[expansionFusionProbe];

masterMapCommutationChecks = mapAssociationValues[
  Function[masters,
    And @@ Map[
      Function[master,
        SameQ[
          expandOneMaster[master] /. partonicToXiS23Rules,
          expandOneMaster[master /. partonicToXiS23Rules]
        ]
      ],
      masters
    ]
  ],
  distinctMasterInstancesByProjector
];
assert[
  And @@ (TrueQ /@ Values[masterMapCommutationChecks]),
  "Appendix-F substitution does not commute with the accepted exact kinematic map."
];

case1Objects = DeleteDuplicates@Join[
  Cases[Values[physicalAngular], _Hypergeometric2F1, Infinity],
  betaObjects,
  gammaObjects
];
case1MapCommutationCheck = And @@ Map[
  Function[object,
    SameQ[
      expandCase1Functions[object] /. partonicToXiS23Rules,
      expandCase1Functions[object /. partonicToXiS23Rules]
    ]
  ],
  case1Objects
];
assert[
  case1MapCommutationCheck,
  "B18/B27 substitution does not commute with the accepted exact kinematic map."
];

formulaCertificate = <|
  "PolynomialB19DerivationResiduals" ->
    polynomialB19SubstitutionResiduals,
  "CorrectedF9RecurrenceResidual" ->
    correctedF9RecurrenceResidual,
  "F9B19BetaTwoReductionResidual" ->
    f9B19BetaTwoReductionResidual,
  "AppendixFRecurrenceResiduals" ->
    appendixFRecurrenceResiduals,
  "F8B19MomentResiduals" -> b19F8Residuals,
  "B30DefiningSeriesCoefficientResidual" ->
    b30DefiningSeriesCoefficientResidual,
  "GammaSeriesRatioResiduals" ->
    gammaSeriesRatioRegression,
  "MasterMapCommutationChecks" ->
    masterMapCommutationChecks,
  "Case1MapCommutationCheck" ->
    case1MapCommutationCheck,
  "FusedReplacementResidual" -> expansionFusionResidual
|>;
formulaCertificateHash = Hash[formulaCertificate, "SHA256"];
formulaCertificateGate =
  polynomialB19ResidualGate &&
  correctedF9RecurrenceGate &&
  f9B19BetaTwoReductionGate &&
  appendixFRecurrenceGate &&
  b19F8Gate &&
  b30DefiningSeriesCoefficientGate &&
  gammaSeriesRatioGate &&
  expansionFusionGate &&
  AllTrue[Values[masterMapCommutationChecks], TrueQ] &&
  TrueQ[case1MapCommutationCheck];
assert[formulaCertificateGate,
  "The aggregate exact Hqg S09 formula certificate failed."];

f9B19NumericSummary = Map[
  Function[data,
    <|
      "RelativeFinalDrift" ->
        ToString[InputForm[N[data["RelativeFinalDrift"], 20]]],
      "ResidualMagnitudeDecreases" ->
        TrueQ[data["ResidualMagnitudeDecreases"]],
      "OrderGate" -> TrueQ[data["OrderGate"]]
    |>
  ],
  f9B19NumericData
];
b30NumericalSummary = Map[
  Function[data,
    <|
      "RelativeFinalDrift" ->
        ToString[InputForm[N[data["RelativeFinalDrift"], 20]]],
      "OrderGate" -> TrueQ[data["OrderGate"]]
    |>
  ],
  b30NumericalRegression
];

expandedKernelValidQ[expression_, projector_String] :=
  expression =!= 0 &&
  expression =!= $Failed &&
  FreeQ[
    expression,
    _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma |
      _FeynCalc`FeynAmpDenominator | _Real | Indeterminate |
      ComplexInfinity | DirectedInfinity | _Inactive | $Failed | $Aborted
  ] &&
  FreeQ[
    expression,
    sHat | t1 | tHat | u1 | zeta | zHat | beta1 | beta2
  ] &&
  scalePowerInventory[expression] === scalePowersByProjector[projector] &&
  FreeQ[expression, FeynCalc`ScaleMu];

validateExpandedKernel[expression_, projector_String] := Module[
  {gate},
  gate = expandedKernelValidQ[expression, projector];
  assert[gate,
    projector <>
      " expanded kernel failed exact content/map/scale validation."];
  gate
];

cacheMetadataValidQ[cache_, projector_String] := Module[
  {expression},
  If[! AssociationQ[cache] || ! KeyExistsQ[cache, "Expression"],
    Return[False]
  ];
  expression = cache["Expression"];
  Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
  Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
  Lookup[cache, "ResultSchemaVersion", Missing["Schema"]] ===
    resultSchemaVersion &&
  Lookup[cache, "Channel", Missing["Channel"]] === "Hqg only" &&
  Lookup[cache, "TensorRole", Missing["Role"]] === "RealQG" &&
  Lookup[cache, "Projector", Missing["Projector"]] === projector &&
  Lookup[cache, "ProgramSHA256", Missing["Program"]] === programHash &&
  Lookup[cache, "PaperSHA256", Missing["Paper"]] === expectedPaperHash &&
  Lookup[cache, "S08SourceSHA256", Missing["S08Source"]] ===
    expectedS08SourceHash &&
  Lookup[cache, "S08ResultSHA256", Missing["S08Result"]] ===
    expectedS08ResultHash &&
  Lookup[cache, "S08CacheSHA256", Missing["S08Cache"]] ===
    expectedS08CacheHashes[projector] &&
  Lookup[cache, "InputKey", Missing["InputKey"]] ===
    "ThreeBodyAngularIntegrated/Hqg;qg/" <> projector &&
  Lookup[cache, "InputExpressionSHA256", Missing["InputHash"]] ===
    inputExpressionHashes[projector] &&
  Lookup[cache, "MasterPairs", Missing["Pairs"]] ===
    actualPairsByProjector[projector] &&
  Lookup[cache, "MasterOccurrenceCount", Missing["Occurrences"]] ===
    masterOccurrenceCounts[projector] &&
  Lookup[cache, "DistinctMasterInstanceCount", Missing["Instances"]] ===
    distinctMasterInstanceCounts[projector] &&
  Lookup[cache, "DistinctMasterInstancesSHA256", Missing["InstanceHash"]] ===
    Hash[distinctMasterInstancesByProjector[projector], "SHA256"] &&
  Lookup[cache, "HypergeometricSignatures", Missing["HyperSignatures"]] ===
    hypergeometricSignaturesByProjector[projector] &&
  Lookup[cache, "HypergeometricOccurrenceCount", Missing["HyperCount"]] ===
    hypergeometricCountsByProjector[projector] &&
  Lookup[cache, "BetaSignatures", Missing["Beta"]] === betaSignatures &&
  Lookup[cache, "GammaObjects", Missing["Gamma"]] === gammaObjects &&
  Lookup[cache, "FormulaCertificateSHA256", Missing["FormulaHash"]] ===
    formulaCertificateHash &&
  Lookup[cache, "AdditionalMultiplicativeWeight", Missing["Weight"]] ===
    additionalMultiplicativeWeight &&
  Lookup[cache, "ScalePowers", Missing["Scale"]] ===
    scalePowersByProjector[projector] &&
  Lookup[cache, "ChargeBookkeeping", Missing["Charge"]] ===
    chargeBookkeeping &&
  Lookup[cache, "InitialStateBookkeeping", Missing["InitialState"]] ===
    initialStateBookkeeping &&
  Lookup[cache, "TwoBodyReferenceHashes", Missing["TwoBody"]] ===
    twoBodyReferenceHashes &&
  Lookup[cache, "ExpressionValidationMethod", Missing["Validation"]] ===
    "Exact content validation plus atomic write/reload equality and finalized file SHA-256" &&
  Lookup[cache, "ExpandedLeafCount", Missing["Leaves"]] ===
    LeafCount[expression] &&
  Lookup[cache, "ExpandedByteCount", Missing["Bytes"]] ===
    ByteCount[expression] &&
  expandedKernelValidQ[expression, projector]
];

loadValidatedCache[projector_String] := Module[{path, cache, valid},
  If[preflightOnly, Return[Missing["PreflightBypass"]]];
  path = cachePaths[projector];
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S09_STAGE: validating existing " <> projector <> " cache"];
  cache = Check[Get[path], $Failed];
  valid = cacheMetadataValidQ[cache, projector];
  If[
    ! TrueQ[valid],
    Clear[cache];
    DeleteFile[path];
    Print[
      "S09_STAGE: removed invalidated S09 cache before regenerating " <>
        projector
    ];
    Return[Missing["Invalidated"]]
  ];
  cache
];

processProjector[projector_String] := Module[
  {
    cached, angularInput, mappedInput, expandedXiS23,
    payload, reloaded, summary,
    residualExpansionInventory, angularExpansionGate,
    transformedExpansionGate, reloadGate
  },
  angularInput = Lookup[physicalAngular, projector, $Failed];
  assert[
    angularInput =!= $Failed && angularInput =!= 0,
    "The physical angular input is unavailable for " <> projector
  ];
  KeyDropFrom[physicalAngular, projector];
  ClearSystemCache[];
  cached = loadValidatedCache[projector];
  If[
    AssociationQ[cached],
    transformedExpansionGate =
      validateExpandedKernel[cached["Expression"], projector];
    reloadGate = cacheMetadataValidQ[cached, projector];
    summary = <|
      "Projector" -> projector,
      "MasterPairs" -> cached["MasterPairs"],
      "MasterOccurrenceCount" -> cached["MasterOccurrenceCount"],
      "DistinctMasterInstanceCount" ->
        cached["DistinctMasterInstanceCount"],
      "ExpandedLeafCount" -> cached["ExpandedLeafCount"],
      "ExpandedByteCount" -> cached["ExpandedByteCount"],
      "CacheResumed" -> FileExistsQ[cachePaths[projector]],
      "CurrentExpandedExpressionValidated" ->
        transformedExpansionGate,
      "CurrentCacheReloadValidated" -> reloadGate
    |>;
    Clear[cached, angularInput];
    ClearSystemCache[];
    Return[summary]
  ];

  Print[
    "S09_STAGE: applying accepted exact xi,s23 map to angular input " <>
      projector
  ];
  mappedInput = boundedOperation[
    projector <> " xi,s23 input transformation",
    angularInput /. partonicToXiS23Rules
  ];
  Clear[angularInput];
  ClearSystemCache[];

  Print[
    "S09_STAGE: fused Appendix-F/B18/B27/B30 expansion for Hqg " <>
      projector
  ];
  expandedXiS23 = boundedOperation[
    projector <> " fused mapped angular-master expansion",
    additionalMultiplicativeWeight *
      xiS23Jacobian *
      expandAllRequiredFunctions[mappedInput]
  ];
  Clear[mappedInput];
  ClearSystemCache[];
  residualExpansionInventory = <|
    "Case2MasterCount" ->
      Count[expandedXiS23, _S08Case2Master, Infinity],
    "HypergeometricCount" ->
      Count[expandedXiS23, _Hypergeometric2F1, Infinity],
    "BetaCount" -> Count[expandedXiS23, _Beta, Infinity],
    "GammaCount" -> Count[expandedXiS23, _Gamma, Infinity],
    "FailedCount" -> Count[expandedXiS23, $Failed, Infinity],
    "MachineRealCount" -> Count[expandedXiS23, _Real, Infinity]
  |>;
  angularExpansionGate =
    AllTrue[Values[residualExpansionInventory], TrueQ[# === 0] &];
  Print[
    "S09_", projector, "_RESIDUAL_EXPANSION_INVENTORY=",
    InputForm[residualExpansionInventory]
  ];
  assert[angularExpansionGate,
    projector <> " angular-master expansion is incomplete."];
  transformedExpansionGate =
    validateExpandedKernel[expandedXiS23, projector];

  summary = <|
    "Projector" -> projector,
    "MasterPairs" -> actualPairsByProjector[projector],
    "MasterOccurrenceCount" -> masterOccurrenceCounts[projector],
    "DistinctMasterInstanceCount" ->
      distinctMasterInstanceCounts[projector],
    "ExpandedLeafCount" -> LeafCount[expandedXiS23],
    "ExpandedByteCount" -> ByteCount[expandedXiS23],
    "CacheResumed" -> FileExistsQ[cachePaths[projector]],
    "CurrentExpandedExpressionValidated" -> transformedExpansionGate,
    "CurrentCacheReloadValidated" -> If[
      preflightOnly,
      Missing["NoWritePreflight"],
      FileExistsQ[cachePaths[projector]]
    ]
  |>;

  If[
    ! preflightOnly,
    payload = <|
      "Status" -> "Complete",
      "Stage" -> cacheStageVersion,
      "ResultSchemaVersion" -> resultSchemaVersion,
      "Channel" -> "Hqg only",
      "TensorRole" -> "RealQG",
      "Projector" -> projector,
      "GeneratedAt" -> DateString[Now, "ISODateTime"],
      "ProgramPath" -> programPath,
      "ProgramSHA256" -> programHash,
      "PaperPath" -> paperPath,
      "PaperSHA256" -> expectedPaperHash,
      "S08SourcePath" -> s08SourcePath,
      "S08SourceSHA256" -> expectedS08SourceHash,
      "S08ResultPath" -> s08ResultPath,
      "S08ResultSHA256" -> expectedS08ResultHash,
      "S08CachePath" -> s08CachePaths[projector],
      "S08CacheSHA256" -> expectedS08CacheHashes[projector],
      "InputKey" ->
        "ThreeBodyAngularIntegrated/Hqg;qg/" <> projector,
      "InputExpressionSHA256" -> inputExpressionHashes[projector],
      "MasterPairs" -> actualPairsByProjector[projector],
      "MasterOccurrenceCount" -> masterOccurrenceCounts[projector],
      "DistinctMasterInstanceCount" ->
        distinctMasterInstanceCounts[projector],
      "DistinctMasterInstancesSHA256" ->
        Hash[distinctMasterInstancesByProjector[projector], "SHA256"],
      "HypergeometricSignatures" ->
        hypergeometricSignaturesByProjector[projector],
      "HypergeometricOccurrenceCount" ->
        hypergeometricCountsByProjector[projector],
      "BetaSignatures" -> betaSignatures,
      "GammaObjects" -> gammaObjects,
      "ExpansionOrders" -> <|
        "NonzeroJExceptF28F29" -> "through epsilon^1",
        "F28F29" -> "through epsilon^0",
        "B18ZeroJ" -> "through epsilon^2",
        "B27AndB30" -> "through epsilon^2"
      |>,
      "FormulaCertificateSHA256" -> formulaCertificateHash,
      "AdditionalMultiplicativeWeight" ->
        additionalMultiplicativeWeight,
      "ScalePowers" -> scalePowersByProjector[projector],
      "ChargeBookkeeping" -> chargeBookkeeping,
      "InitialStateBookkeeping" -> initialStateBookkeeping,
      "DimensionalBookkeeping" -> dimensionalBookkeeping,
      "TwoBodyReferenceHashes" -> twoBodyReferenceHashes,
      "ExpandedLeafCount" -> summary["ExpandedLeafCount"],
      "ExpandedByteCount" -> summary["ExpandedByteCount"],
      "ExpressionValidationMethod" ->
        "Exact content validation plus atomic write/reload equality and finalized file SHA-256",
      "Expression" -> expandedXiS23
    |>;
    reloaded = atomicPutAssociation[
      payload,
      cachePaths[projector],
      cacheStageVersion
    ];
    reloadGate =
      cacheMetadataValidQ[reloaded, projector] &&
      reloaded["Expression"] === expandedXiS23;
    assert[reloadGate,
      projector <> " cache failed exact atomic write/reload validation."];
    summary["CurrentCacheReloadValidated"] = reloadGate;
    Clear[payload, reloaded]
  ];

  Print[
    "S09_CHECKPOINT: completed ", projector,
    " expanded leaf/byte counts ",
    InputForm[{
      summary["ExpandedLeafCount"],
      summary["ExpandedByteCount"]
    }]
  ];
  Clear[expandedXiS23];
  summary
];

(* Exact bounded-distribution coefficient/sign check on a quadratic test. *)
endpointExactTestIntegral = s09Upper^(-epsilon) (
  s09F0/(-epsilon) +
  s09F1 s09Upper/(1 - epsilon) +
  s09F2 s09Upper^2/(2 - epsilon)
);
endpointTruncatedTestAction = s09Upper^(-epsilon) (
  -s09F0/epsilon +
  Sum[
    (-epsilon)^n/Factorial[n] *
      Sum[
        s09Fk[k] (-1)^n Factorial[n] s09Upper^k/k^(n + 1),
        {k, 1, 2}
      ],
    {n, 0, 2}
  ]
) /. {s09Fk[1] -> s09F1, s09Fk[2] -> s09F2};
endpointIdentityPolynomialResidual = Together@Normal@Series[
  endpointExactTestIntegral - endpointTruncatedTestAction,
  {epsilon, 0, 2}
];
assert[
  endpointIdentityPolynomialResidual === 0,
  "The bounded endpoint delta/plus coefficient or sign check failed."
];

plusDistributionAction = HoldComplete[
  Inactive[Integrate][
    S09PlusDistribution[n, s23, upper] testFunction[s23],
    {s23, 0, upper}
  ] == Inactive[Integrate][
    Log[s23/upper]^n/s23 *
      (testFunction[s23] - testFunction[0]),
    {s23, 0, upper}
  ]
];
regularFunctionDefinition = HoldComplete[
  S09RegularEndpointFunction[projector, s23] ==
    s23^(1 + epsilon) S09ExpandedKernelReference[projector, s23]
];

formalEndpointDistribution[projector_String] :=
  -s23UpperB^(-epsilon)/epsilon *
      S09EndpointValue[projector, s23 -> 0] DiracDelta[s23] +
    s23UpperB^(-epsilon) *
      S09RegularEndpointFunction[projector, s23] *
      Sum[
        (-epsilon)^n/Factorial[n] *
          S09PlusDistribution[n, s23, s23UpperB],
        {n, 0, 2}
      ];

formalEndpointDistributions = <|
  "Pg" -> formalEndpointDistribution["Pg"],
  "PPP" -> formalEndpointDistribution["PPP"]
|>;
assert[
  AllTrue[
    Values[formalEndpointDistributions],
    ! FreeQ[#, DiracDelta[s23]] &&
      Count[#, _S09PlusDistribution, Infinity] === 3 &&
      ! FreeQ[#, _S09EndpointValue] &&
      ! FreeQ[#, _S09RegularEndpointFunction] &
  ],
  "A formal endpoint descriptor has the wrong delta/plus structure."
];

formalEndpointStructureGate =
  Keys[formalEndpointDistributions] === projectorOrder &&
  AllTrue[
    Values[formalEndpointDistributions],
    Count[#, DiracDelta[s23], Infinity] === 1 &&
      Count[#, _S09PlusDistribution, Infinity] === 3 &&
      Count[#, _S09EndpointValue, Infinity] === 1 &&
      Count[#, _S09RegularEndpointFunction, Infinity] === 1 &
  ];
assert[formalEndpointStructureGate,
  "A formal endpoint descriptor has the wrong one-delta/three-plus structure."];

Print["S09_STAGE: processing expanded projectors serially"];
projectorSummaries = <||>;
projectorSummaries["Pg"] =
  processProjector["Pg"];
ClearSystemCache[];
projectorSummaries["PPP"] =
  processProjector["PPP"];
ClearSystemCache[];

inputEvictionGate = physicalAngular === <||>;
projectorSummaryGate =
  Keys[projectorSummaries] === projectorOrder &&
  inputEvictionGate &&
  AllTrue[
    Values[projectorSummaries],
    #["ExpandedLeafCount"] > 0 &&
      #["ExpandedByteCount"] > 0 &&
      TrueQ[#["CurrentExpandedExpressionValidated"]] &&
      If[
        preflightOnly,
        MissingQ[#["CurrentCacheReloadValidated"]],
        TrueQ[#["CurrentCacheReloadValidated"]]
      ] &
  ];
assert[projectorSummaryGate,
  "At least one serial projector expansion summary is incomplete."];

paperIdentityGate =
  fileSHA256[paperPath] === expectedPaperHash;
acceptedSourceIdentityGate =
  fileSHA256[s07SourcePath] === expectedS07SourceHash &&
  fileSHA256[s07ResultPath] === expectedS07ResultHash &&
  fileSHA256[s08SourcePath] === expectedS08SourceHash &&
  fileSHA256[s08ResultPath] === expectedS08ResultHash &&
  mapAssociationValues[fileSHA256, s08CachePaths] ===
    expectedS08CacheHashes;
associationValueMappingGate =
  associationValueMappingProbe === <|"Pg" -> 2, "PPP" -> 3|>;
endpointIdentityGate =
  endpointIdentityPolynomialResidual === 0;
mapCommutationGate =
  AllTrue[Values[masterMapCommutationChecks], TrueQ] &&
  TrueQ[case1MapCommutationCheck];
specialFunctionDerivationGate =
  hypergeometricInventoryGate &&
  betaGammaInventoryGate &&
  b30SolveGate &&
  b30ExpansionPurityGate &&
  b30DefiningSeriesCoefficientGate &&
  b30NumericalOrderGate &&
  betaExpansionGate &&
  gammaSeriesRatioGate;
endpointSemanticGate =
  endpointIdentityGate &&
  formalEndpointStructureGate &&
  FreeQ[formalEndpointDistributions, _Limit];

baseChecks = <|
  "AuthoritativePaperHashValidated" ->
    paperIdentityGate,
  "AcceptedS07AndS08DiskIdentitiesValidated" ->
    acceptedSourceIdentityGate,
  "AcceptedS08StatusAndEighteenComputedChecksValidated" ->
    (s08StatusGate && s08ChecksGate),
  "AcceptedS08EmbeddedS06S07LineageValidated" ->
    s08LineageGate,
  "AcceptedS08CacheLedgerValidated" ->
    s08CacheLedgerGate,
  "S08CacheExpressionsExactlyMatchResultAngularInputs" ->
    AllTrue[Values[s08CachePayloadEqualityChecks], TrueQ],
  "OrderedPhysicalHqgQGProjectorInputValidated" ->
    (Keys[inputExpressionHashes] === projectorOrder),
  "CompleteRuntimeB19MasterInventoryValidated" ->
    masterInventoryCompletenessGate,
  "MeasuredSixtyOneFortyThreeOccurrenceAndSixtyThreeInstanceInventoryValidated" ->
    masterInventoryMeasurementGate,
  "AllRuntimeNonzeroJFormulaCoverageValidated" ->
    nonzeroFormulaCoverageGate,
  "AllRuntimeZeroJFormulaCoverageValidated" ->
    zeroJCoverageGate,
  "HqgPolynomialB19DerivationsAndResidualsValidated" ->
    (polynomialB19DerivationGate && polynomialB19ResidualGate),
  "CorrectedF9ExactRecurrenceReducedB19AndOrderValidated" ->
    (correctedF9RecurrenceGate &&
      f9B19BetaTwoReductionGate && f9B19NumericOrderGate),
  "DynamicAppendixFB19RecurrencesValidated" ->
    (recurrenceInventoryGate && appendixFRecurrenceGate),
  "F8ExactB19MomentDerivationValidated" ->
    b19F8Gate,
  "MeasuredB27B30BetaGammaInventoryAndExpansionsValidated" ->
    specialFunctionDerivationGate,
  "FormulaCertificateAggregateValidated" ->
    formulaCertificateGate,
  "FusedSinglePassExpansionMatchesSequentialRules" ->
    expansionFusionGate,
  "MasterAndResidualFunctionSubstitutionsCommuteWithMap" ->
    mapCommutationGate,
  "MappedInputsEvictedDuringSerialProcessing" ->
    inputEvictionGate,
  "BothExpandedProjectorsCompletedSerially" ->
    projectorSummaryGate,
  "AssociationValueMappingShapeAndValuesVerified" ->
    associationValueMappingGate,
  "AdditionalMultiplicativeWeightDerivedAsExactlyOne" ->
    unitWeightGate,
  "InheritedScaleStructureMeasuredAndPreserved" ->
    scaleBookkeepingGate,
  "ChargeStrippedChannel3AFragmentingGluonConventionPreserved" ->
    chargeBookkeepingGate,
  "LOAndVirtualPairsRetainedOnlyAsHashReferences" ->
    twoBodyReferenceGate,
  "FormalBoundedEndpointIdentityAndUnresolvedSemanticsValidated" ->
    endpointSemanticGate
|>;
assert[
  AllTrue[Values[baseChecks], TrueQ],
  "At least one computed Hqg S09 base validation check failed."
];

buildResultCandidate[
    cacheHashAssociation_Association,
    checkAssociation_Association
  ] := <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg;qg Appendix-F/B18/B27/B30-expanded real Pg/PPP kernels with formal endpoint handoff",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" ->
      "Appendix B Eqs. (B18)-(B31) and Appendix F Eqs. (F1)-(F29)"
  |>,
  "InputProvenance" -> <|
    "S07SourcePath" -> s07SourcePath,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultPath" -> s07ResultPath,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "S08SourcePath" -> s08SourcePath,
    "S08SourceSHA256" -> expectedS08SourceHash,
    "S08ResultPath" -> s08ResultPath,
    "S08ResultSHA256" -> expectedS08ResultHash,
    "S08CachePaths" -> s08CachePaths,
    "S08CacheSHA256" -> expectedS08CacheHashes,
    "S08EmbeddedLineage" -> expectedS08Lineage,
    "InputKey" ->
      "ThreeBodyAngularIntegrated/Hqg;qg/{Pg,PPP}",
    "InputExpressionSHA256" -> inputExpressionHashes,
    "S08CachesUsedAsEqualityProvenanceWitnesses" ->
      AllTrue[Values[s08CachePayloadEqualityChecks], TrueQ]
  |>,
  "AppendixFExpansion" -> <|
    "PairsByProjector" -> actualPairsByProjector,
    "AllPairs" -> allActualPairs,
    "MasterOccurrencesByProjector" -> masterOccurrenceCounts,
    "DistinctMasterInstancesByProjector" ->
      distinctMasterInstanceCounts,
    "DistinctMasterInstanceUnionCount" ->
      Length[allDistinctMasterInstances],
    "ExpansionOrders" -> <|
      "NonzeroJExceptF28F29" -> "through epsilon^1",
      "F28F29" -> "through epsilon^0",
      "B18ZeroJ" -> "through epsilon^2",
      "B27AndB30" -> "through epsilon^2"
    |>,
    "HypergeometricSignaturesByProjector" ->
      hypergeometricSignaturesByProjector,
    "HypergeometricOccurrenceCountsByProjector" ->
      hypergeometricCountsByProjector,
    "HypergeometricSignatureCountsByProjector" ->
      hypergeometricSignatureCountsByProjector,
    "B18BetaSignatures" -> betaSignatures,
    "B18GammaObjectsBeforeExpansion" -> gammaObjects,
    "RecurrenceDefinition" -> HoldComplete[
      D[S09B19Integral[j, l, d, c, epsilon], d] ==
        -j S09B19Integral[j + 1, l, d, c, epsilon]
    ],
    "FormulaCertificate" -> formulaCertificate,
    "FormulaCertificateSHA256" -> formulaCertificateHash,
    "F9ReducedB19NumericalOrderSummary" ->
      f9B19NumericSummary,
    "B30NumericalOrderSummary" ->
      b30NumericalSummary,
    "ProjectorSummaries" -> projectorSummaries
  |>,
  "ExpandedKernelCaches" -> <|
    "StageVersion" -> cacheStageVersion,
    "Paths" -> cachePaths,
    "SHA256" -> cacheHashAssociation,
    "ExpressionField" -> "Expression",
    "ExpressionValidationMethod" ->
      "Exact content validation plus atomic write/reload equality and finalized file SHA-256",
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S08ResultSHA256" -> expectedS08ResultHash
  |>,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS09" ->
      additionalMultiplicativeWeight,
    "MeasuredScalePowersByProjector" ->
      scalePowersByProjector,
    "Charge" -> chargeBookkeeping,
    "InitialState" -> initialStateBookkeeping,
    "Dimensional" -> dimensionalBookkeeping,
    "LOAndVirtualReferenceExpressionSHA256" ->
      twoBodyReferenceHashes,
    "LOOrVirtualCombinedAtS09" ->
      SameQ[0, 1],
    "PhysicalFlavorChargeWeightAppliedAtS09" ->
      SameQ[0, 1],
    "AdditionalFinalStateSymmetryFactorAppliedAtS09" ->
      SameQ[0, 1]
  |>,
  "EndpointExpansion" -> <|
    "Status" ->
      "Formal bounded distribution only; endpoint values and stronger singularities deliberately unresolved",
    "Interval" -> {s23, 0, s23UpperB},
    "UpperLimit" -> s23UpperB,
    "ExpansionThrough" -> "epsilon^2 with O(epsilon^3) remainder",
    "RegularFunctionDefinition" -> regularFunctionDefinition,
    "ExpandedKernelReferenceMeaning" ->
      "For each projector, the exact Expression field of its hash-pinned S09 cache",
    "PlusDistributionAction" -> plusDistributionAction,
    "FormalDistributionByProjector" ->
      formalEndpointDistributions,
    "QuadraticTestFunctionResidualThroughEpsilonSquared" ->
      endpointIdentityPolynomialResidual,
    "EndpointValuesResolved" ->
      SameQ[0, 1],
    "StrongerSingularitiesResolved" ->
      SameQ[0, 1],
    "DownstreamResolutionRequired" ->
      SameQ[1, 1]
  |>,
  "Checks" -> checkAssociation,
  "MemoryStrategy" ->
    "Pg then PPP processed serially; each exact expression is released after its atomic cache or no-write validation",
  "NotPerformedAtThisStage" -> {
    "evaluation of either formal endpoint value",
    "structural resolution of stronger s23 singularities",
    "combination with the hash-pinned LO or symbolic virtual pairs",
    "Eq. (46) initial-state PDF and final-state FF subtraction",
    "resolved Laurent pole-cancellation test",
    "epsilon -> 0 finite hard-part limit",
    "Eq. (9) Pg/PPP inversion or F-hat extraction",
    "physical Sum_q e_q^2 f_q D_g assembly",
    "BigTMD finite-kernel comparison"
  },
  "DownstreamInstruction" ->
    "Corrected S10 must load only the two hash-pinned S09 cache expressions for the real branch, resolve every endpoint singularity class, and consume the accepted S08/S07 LO/virtual branch separately."
|>;

compactResultCandidateValidQ[candidate_Association] :=
  ! KeyExistsQ[candidate["ExpandedKernelCaches"], "Expression"] &&
  candidate[
    "AppendixFExpansion", "B18GammaObjectsBeforeExpansion"
  ] === gammaObjects &&
  FreeQ[
    candidate,
    _S08Case2Master | _FeynCalc`FeynAmpDenominator
  ] &&
  ByteCount[candidate] <
    Total[Lookup[Values[projectorSummaries], "ExpandedByteCount"]];

preflightCacheHashes = AssociationMap[
  Function[projector, Missing["NoWritePreflight", projector]],
  projectorOrder
];
preflightResultCandidate =
  buildResultCandidate[preflightCacheHashes, baseChecks];
preflightResultCandidateGate =
  AssociationQ[preflightResultCandidate] &&
  preflightResultCandidate["Stage"] === stageVersion &&
  preflightResultCandidate["Channel"] === "Hqg only" &&
  preflightResultCandidate["ExpandedKernelCaches", "Paths"] ===
    cachePaths &&
  preflightResultCandidate["EndpointExpansion",
    "EndpointValuesResolved"] === False &&
  ! KeyExistsQ[
    preflightResultCandidate["ExpandedKernelCaches"],
    "Expression"
  ] &&
  compactResultCandidateValidQ[preflightResultCandidate];

assert[preflightResultCandidateGate,
  "The compact Hqg S09 result candidate failed its source-native gate."];

If[
  preflightOnly,
  preflightArtifactInventoryGate =
    Sort@FileNames["s09_*", scriptDirectory] ===
      preflightArtifactSnapshot;
  assert[preflightArtifactInventoryGate,
    "The no-write S09 preflight changed the S09 artifact inventory."];
  Print["S09_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S09_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[baseChecks]];
  Print[
    "S09_DYNAMIC_PREFLIGHT_SUMMARIES=",
    InputForm[projectorSummaries]
  ];
  Print[
    "S09_DYNAMIC_PREFLIGHT_RESULT_CANDIDATE_GATE=",
    InputForm[preflightResultCandidateGate]
  ];
  Quit[0]
];

Print["S09_STAGE: validating finalized source-bound projector caches"];
finalizedCacheValidationChecks = AssociationMap[
  Function[projector,
    finalizedCache = Check[Get[cachePaths[projector]], $Failed];
    finalizedGate =
      cacheMetadataValidQ[finalizedCache, projector] &&
      finalizedCache["ExpandedLeafCount"] ===
        projectorSummaries[projector]["ExpandedLeafCount"] &&
      finalizedCache["ExpandedByteCount"] ===
        projectorSummaries[projector]["ExpandedByteCount"];
    Clear[finalizedCache];
    ClearSystemCache[];
    finalizedGate
  ],
  projectorOrder
];
atomicCacheValidationGate =
  AllTrue[Values[finalizedCacheValidationChecks], TrueQ];
assert[atomicCacheValidationGate,
  "A finalized projector cache failed exact independent reload validation."];

cacheHashes = mapAssociationValues[fileSHA256, cachePaths];
cacheDiskHashGate =
  Keys[cacheHashes] === projectorOrder &&
  AllTrue[
    Values[cacheHashes],
    StringLength[#] === 64 &&
      StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
  ] &&
  mapAssociationValues[fileSHA256, cachePaths] === cacheHashes;
assert[cacheDiskHashGate,
  "The finalized cache-hash Association has wrong shape or disk values."];

productionChecksPreCompact = Join[
  baseChecks,
  <|
    "AtomicProjectorCachesReloadedAndValidated" ->
      atomicCacheValidationGate,
    "ActualDiskCacheHashesMappedByAssociationValues" ->
      cacheDiskHashGate,
    "SourceNativeCompactResultCandidateValidated" ->
      preflightResultCandidateGate
  |>
];
productionCandidate =
  buildResultCandidate[cacheHashes, productionChecksPreCompact];
compactResultGate =
  compactResultCandidateValidQ[productionCandidate];
checks = Append[
  productionChecksPreCompact,
  "CompactResultDoesNotDuplicateExpandedKernels" ->
    compactResultGate
];
assert[AllTrue[Values[checks], TrueQ],
  "At least one computed final Hqg S09 validation check failed."];

s09Result = buildResultCandidate[cacheHashes, checks];

Print["S09_STAGE: atomically writing the compact Hqg S09 result"];
reloadedResult =
  atomicPutAssociation[s09Result, resultPath, stageVersion];
resultReloadGate =
  reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
  reloadedResult["ProgramSHA256"] === programHash &&
  reloadedResult["InputProvenance", "S08ResultSHA256"] ===
    expectedS08ResultHash &&
  reloadedResult["ExpandedKernelCaches", "Paths"] === cachePaths &&
  reloadedResult["ExpandedKernelCaches", "SHA256"] === cacheHashes &&
  reloadedResult["EndpointExpansion", "EndpointValuesResolved"] ===
    False &&
  AllTrue[Values[reloadedResult["Checks"]], TrueQ];
assert[resultReloadGate,
  "The final compact S09 result failed exact reload validation."];

resultCacheDiskBindingGate =
  And @@ KeyValueMap[
    Function[{projector, path},
      reloadedResult["ExpandedKernelCaches", "SHA256", projector] ===
        fileSHA256[path]
    ],
    cachePaths
  ];
assert[resultCacheDiskBindingGate,
  "The final S09 result cache hashes do not match the real disk files."];

temporaryCleanupGate =
  FileNames["s09_result.tmp.*", scriptDirectory] === {} &&
  FileNames[
    "s09_cache_hqg_real_qg_*.tmp.*",
    scriptDirectory
  ] === {};
assert[temporaryCleanupGate,
  "An S09 temporary file remains after finalization."];

upstreamIdentityPreservationGate =
  fileSHA256[s07SourcePath] === expectedS07SourceHash &&
  fileSHA256[s07ResultPath] === expectedS07ResultHash &&
  fileSHA256[s08SourcePath] === expectedS08SourceHash &&
  fileSHA256[s08ResultPath] === expectedS08ResultHash &&
  mapAssociationValues[fileSHA256, s08CachePaths] ===
    expectedS08CacheHashes;
assert[upstreamIdentityPreservationGate,
  "An accepted upstream identity changed during Hqg S09 production."];

resultHash = fileSHA256[resultPath];
Print["S09_SUCCESS"];
Print["S09_PROGRAM_SHA256=" <> programHash];
Print["S09_RESULT_PATH=" <> resultPath];
Print["S09_RESULT_SHA256=" <> resultHash];
Print["S09_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S09_CACHE_SHA256=", InputForm[cacheHashes]];
Print["S09_CHECKS=", InputForm[checks]];
Print["S09_RESULT_RELOAD_GATE=", InputForm[resultReloadGate]];
Print[
  "S09_UPSTREAM_IDENTITIES_UNCHANGED=",
  InputForm[upstreamIdentityPreservationGate]
];

Quit[0];

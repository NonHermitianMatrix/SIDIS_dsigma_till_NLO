(* ::Package:: *)

(*
  Hqqbar stage S08: integrate the unobserved q(k2),q(k3) three-body
  phase-space angles of the two accepted Hqqbar Pg/PPP projections while
  keeping the observed fragmenting antiquark k1 differential.

  The implementation follows paper Eqs. (19), (29)-(32), (38)-(40) and
  Appendices B and D.  It applies the sole identical-spectator factor 1/2!
  when the labelled three-body phase-space measure is attached.  Appendix-F
  epsilon expansions, endpoint distributions, factorization, F-hat
  extraction, and BigTMD comparison are deliberately deferred to S09.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, mapAssociationValues,
  atomicPutAssociation, splitTerms,
  hasExactlyExpectedScaleQ, validateScalarInput, setThreeBodyKinematics,
  prepareRealExplicit, laurentPower, denominatorADMVs, presentADMVs,
  typeOfADMV, sameTypeOffender, reduceSameTypeTerms, affineVector,
  tripleUnityRelation, reduceTripleTerms, chooseBasis, basisRules,
  reduceNumerators, reduceAndCertifyChunk, reduceAppendixD,
  linearCoefficients,
  reducedLinearCoefficients, coefficientDot, masslessGeometry,
  case2Geometry, appendixB18, angularKeyAndCoefficient, masterFromKey,
  integrateReducedTerms, validateAngularExpression, validateAngularRecord,
  cacheMetadataValidQ,
  loadValidatedCache, writeCache, processRealProjection,
  validateProjectionPair, transformPair, validateXiS23Pair,
  zeroCoefficientVectorQ, S08Case2Master
];

activeTemporaryPath = "";

fatal[message_String] := (
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S08_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

mapAssociationValues[function_, association_Association] :=
  Map[function, association];

cacheValueMappingProbe = mapAssociationValues[
  StringLength,
  <|"Pg" -> "pg", "PPP" -> "ppp"|>
];
assert[
  cacheValueMappingProbe === <|"Pg" -> 2, "PPP" -> 3|>,
  "Association value mapping does not preserve projector keys and values."
];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "The process-specific temporary path already exists: " <>
      activeTemporaryPath
  ];
  writeResult = Quiet@Check[Put[expression, activeTemporaryPath], $Failed];
  assert[writeResult =!= $Failed, "Atomic temporary write failed."];
  assert[
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    "Atomic temporary file is missing or empty."
  ];
  loaded = Quiet@Check[Get[activeTemporaryPath], $Failed];
  assert[
    AssociationQ[loaded] && loaded["Status"] === "Complete" &&
      loaded["Stage"] === expectedStage,
    "Atomic temporary Association failed status/stage reload validation."
  ];
  renameResult = Quiet@Check[
    RenameFile[activeTemporaryPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic rename failed."];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Finalized atomic file is missing or empty."
  ];
];

splitTerms[expression_] :=
  If[Head[expression] === Plus, List @@ expression, {expression}];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
s07SourcePath =
  FileNameJoin[{scriptDirectory, "s07_contract_hqqbar_projectors.wl"}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
s08ResultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s08_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s08_cache_hqqbar_ppp"}]
|>;

stageVersion = "HqqbarS08-v1";
cacheStageVersion = "HqqbarS08Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S08_PREFLIGHT_ONLY"], ""] === "1";
memoryBudgetBytes = 7 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS07SourceHash =
  "4631639ae9e06a266e507d8854ee0cadf55d9106faff5ab13fe616f33fb50db4";
expectedS07ResultHash =
  "a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50";
expectedS06SourceHash =
  "787d001e6d285d1e74cfe9654ca8f61fe9a66d3b2e5972b20291bf39a02014fe";
expectedS06ResultHash =
  "fd6499e32ce65273381e5350131fe06e8ed3b9a05083b446189b0d7d7323f9ef";
expectedS05SourceHash =
  "af499834c79fd69e69f33306a2e049a32f3d2ed88a50afcc65d5d37b0b9fd29e";
expectedS05ResultHash =
  "b72245cd5200ab0e649588ca77607feb21c152be2e20faead5ef74bc992a5f17";

programHash = fileSHA256[programPath];
dimensionalScaleFactor = FeynCalc`ScaleMu^(4 epsilon);

staleTemporaryPaths = Join[
  FileNames["s08_result.tmp.*", scriptDirectory],
  FileNames["s08_cache_hqqbar*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "A stale S08 temporary file exists and must be resolved before running."
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[s08ResultPath],
    "s08_result already exists; validate or deliberately remove it before regeneration."
  ]
];

Print["S08_STAGE: validating the paper and accepted Hqqbar S07 handoff"];
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
    "S07 result" -> {s07ResultPath, expectedS07ResultHash}
  |>
];

s07 = Quiet@Check[Get[s07ResultPath], $Failed];
assert[AssociationQ[s07], "s07_result is not an Association."];
assert[
  s07["Status"] === "Complete" &&
    s07["Stage"] === "HqqbarS07-v1" &&
    s07["ResultSchemaVersion"] === 1 &&
    s07["Channel"] === "Hqqbar only" &&
    s07["Contribution"] ===
      "H_{q qbar; q q} real Pg/PPP scalar projections",
  "The S07 status, stage, schema, channel, or contribution is invalid."
];
assert[
  s07["ProgramSHA256"] === expectedS07SourceHash &&
    s07["Input"]["S06SourceSHA256"] === expectedS06SourceHash &&
    s07["Input"]["S06ResultSHA256"] === expectedS06ResultHash &&
    s07["Input"]["S05SourceSHA256"] === expectedS05SourceHash &&
    s07["Input"]["S05ResultSHA256"] === expectedS05ResultHash,
  "S07 does not bind the accepted S07/S06/S05 handoff."
];
assert[
  s07["PaperReference"]["SHA256"] === expectedPaperHash,
  "S07 does not bind the authoritative paper edition."
];
assert[
  s07["ProjectionCount"] === 2 && Length[s07["Checks"]] === 25 &&
    And @@ (TrueQ /@ Values[s07["Checks"]]),
  "S07 projection count or accepted checks are invalid."
];
assert[
  s07["WardIdentity"]["Residual"] === 0 &&
    s07["WardIdentity"]["Passed"] === True,
  "S07 does not retain its exact electromagnetic Ward gate."
];
assert[
  s07["ScaleBookkeeping"]["AbsoluteFactor"] ===
      dimensionalScaleFactor &&
    s07["ScaleBookkeeping"]
      ["PowerPreservedExactlyOnceInEveryProjection"] === True &&
    s07["ScaleBookkeeping"]["SeparateMSBarSEpsilonApplied"] === False,
  "S07 scale bookkeeping is invalid."
];
assert[
  s07["ChargeBookkeeping"]["TensorIsChargeStripped"] === True &&
    s07["ChargeBookkeeping"]["PhysicalChargeWeightAppliedAtS06"] ===
      False &&
    s07["ChargeBookkeeping"]["BigTMDChannel"] === 5 &&
    s07["ChargeBookkeeping"]["BigTMDChargeCase"] === "A only",
  "S07 charge-stripped channel-5A bookkeeping is invalid."
];
assert[
  s07["SymmetryBookkeeping"]
      ["IdenticalSpectatorFactorAppliedAtS06"] === False,
  "S07 input has already applied the identical-spectator factor."
];
assert[
  s07["VirtualContributionAtThisOrder"]["Applicable"] === False &&
    s07["VirtualContributionAtThisOrder"]["Interference"] === 0,
  "S07 violates the Hqqbar no-virtual contract."
];

realInput =
  s07["ScalarProjections"]["NLOReal_OAlphaS2"]["Hqqbar;q_q"];
assert[
  AssociationQ[realInput] && Keys[realInput] === {"Pg", "PPP"},
  "S07 does not contain exactly the ordered Hqqbar Pg/PPP pair."
];

hasExactlyExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /. HoldPattern[
      FeynCalc`ScaleMu^(4 epsilon)
    ] :> 1;
  ! FreeQ[expression, FeynCalc`ScaleMu^(4 epsilon)] &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

validateScalarInput[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero."
  ];
  assert[
    FreeQ[
      expression,
      _FeynCalc`LorentzIndex | FeynCalc`Contract |
        _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
        FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
    ],
    label <> " is not a complete exact scalar projection."
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not contain exactly ScaleMu^(4 epsilon)."
  ];
  True
];

assert[
  And @@ KeyValueMap[
    validateScalarInput[#2, "S07 Hqqbar " <> #1] &,
    realInput
  ],
  "At least one S07 input projection failed validation."
];

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

propagatorInvariantRules = {
  s12 + s13 + s23 -> sHat,
  s23 + u2 + u3 -> t1,
  s12 + u1 + u2 -> t3,
  s13 + u1 + u3 -> t2
};

spectatorExchangeRules = {
  t2 -> t3, t3 -> t2,
  u2 -> u3, u3 -> u2,
  s12 -> s13, s13 -> s12
};

prepareRealExplicit[projection_, projectorName_String] := Module[
  {raw, combined, expanded, exchangeResidual},
  Print[
    "S08_STAGE: exposing and combining Hqqbar " <> projectorName <>
      " propagators"
  ];
  setThreeBodyKinematics[];
  raw = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        FeynCalc`FeynAmpDenominatorExplicit[projection],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    raw =!= $Failed,
    projectorName <> " propagator exposure failed or exceeded memory."
  ];
  combined = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        Together[
          raw /. propagatorInvariantRules /. D -> 4 - 2 epsilon
        ],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  Clear[raw];
  assert[
    combined =!= $Failed,
    projectorName <> " exact rational combination failed or exceeded memory."
  ];
  assert[
    FreeQ[
      combined,
      _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum | D | _Real
    ],
    projectorName <>
      " retains a propagator, momentum, D, or machine-real object."
  ];
  exchangeResidual = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        Together[
          combined - (combined /. spectatorExchangeRules)
        ],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    exchangeResidual === 0,
    projectorName <>
      " is not exactly invariant under k2/k3 spectator exchange."
  ];
  expanded = MemoryConstrained[
    CheckAbort[Quiet@Check[Expand[combined], $Failed], $Failed],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    expanded =!= $Failed,
    projectorName <> " exact expansion failed or exceeded memory."
  ];
  <|
    "CombinedLeafCount" -> LeafCount[combined],
    "ExpandedTermCount" -> Length[splitTerms[expanded]],
    "ExpandedLeafCount" -> LeafCount[expanded],
    "SpectatorExchangeResidual" -> exchangeResidual,
    "SpectatorExchangePassed" -> True,
    "Expression" -> expanded
  |>
];

admv = {t2, t3, u2, u3, s12, s13};
sameTypeData = {
  {{t2, t3}, u1 - s23 - Q2},
  {{u2, u3}, t1 - s23},
  {{s12, s13}, sHat - s23}
};

appendixDRelations = {
  t2 + t3 == u1 - s23 - Q2,
  u2 + u3 == t1 - s23,
  s12 + s13 == sHat - s23,
  s13 == sHat + Q2 + t2 + u2
};

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

typeOfADMV[variable_] := Which[
  MemberQ[{t2, t3}, variable], "t",
  MemberQ[{u2, u3}, variable], "u",
  MemberQ[{s12, s13}, variable], "s",
  True, "none"
];

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
            splitTerms@Expand[
              term Total[First[offender]]/Last[offender]
            ]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

affineVector[variable_] := Switch[variable,
  t2, {1, 0, 0},
  t3, {-1, 0, u1 - s23 - Q2},
  u2, {0, 1, 0},
  u3, {0, -1, t1 - s23},
  s13, {1, 1, sHat + Q2},
  s12, {-1, -1, -s23 - Q2},
  _, fatal["Unknown ADMV in affineVector."]
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
    Function[term,
      splitTerms@Expand[term /. basisRules[chooseBasis[term]]]
    ],
    inputTerms
  ],
  1
];

reduceAndCertifyChunk[
    inputTerms_List, commonRules_List, label_String,
    chunkIndex_Integer, chunkCount_Integer
  ] := Module[
  {afterSame, afterTriple, reduced, reconstructionResidual},
  afterSame = reduceSameTypeTerms[inputTerms];
  afterTriple = reduceTripleTerms[afterSame];
  reduced = reduceNumerators[afterTriple];
  reconstructionResidual = MemoryConstrained[
    CheckAbort[
      Quiet@Check[
        Together[
          (Total[reduced] - Total[inputTerms]) /. commonRules
        ],
        $Failed
      ],
      $Failed
    ],
    memoryBudgetBytes,
    $Failed
  ];
  assert[
    reconstructionResidual === 0,
    label <> " Appendix-D reconstruction failed in exact chunk " <>
      ToString[chunkIndex] <> "/" <> ToString[chunkCount] <> "."
  ];
  If[
    Mod[chunkIndex, 8] === 0 || chunkIndex === chunkCount,
    Print[
      "S08_STAGE: exact reconstruction " <> label <> " chunk " <>
        ToString[chunkIndex] <> "/" <> ToString[chunkCount]
    ]
  ];
  <|
    "Terms" -> reduced,
    "InputTermCount" -> Length[inputTerms],
    "AfterSameTypeTermCount" -> Length[afterSame],
    "AfterTripleTermCount" -> Length[afterTriple],
    "ReducedTermCount" -> Length[reduced],
    "ReconstructionResidual" -> reconstructionResidual
  |>
];

reduceAppendixD[expression_, label_String] := Module[
  {terms, termChunks, chunkResults, reduced, invalid, commonRules,
   reconstructionChunkSize = 64, reconstructionChunkCount},
  terms = splitTerms[Expand[expression]];
  Print[
    "S08_STAGE: Appendix D start " <> label <> ", terms " <>
      ToString[Length[terms]]
  ];
  termChunks = Partition[terms, UpTo[reconstructionChunkSize]];
  reconstructionChunkCount = Length[termChunks];
  commonRules = basisRules[{t2, u2}];
  Print[
    "S08_STAGE: Appendix D exact partitioned reconstruction " <> label <>
      ", chunks " <> ToString[reconstructionChunkCount] <>
      " of at most " <> ToString[reconstructionChunkSize] <> " terms"
  ];
  chunkResults = MapIndexed[
    reduceAndCertifyChunk[
      #1,
      commonRules,
      label,
      First[#2],
      reconstructionChunkCount
    ] &,
    termChunks
  ];
  reduced = Flatten[Lookup[chunkResults, "Terms"], 1];
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
    label <> " did not reduce to at most two different ADMV types."
  ];
  assert[
    And @@ (TrueQ[# === 0] & /@
      Lookup[chunkResults, "ReconstructionResidual"]),
    label <> " has a nonzero exact reconstruction chunk."
  ];
  Print[
    "S08_STAGE: Appendix D partitioned reconstruction passed " <> label <>
      ", terms " <> ToString[Length[reduced]]
  ];
  <|
    "Terms" -> reduced,
    "Audit" -> <|
      "InputTermCount" -> Length[terms],
      "AfterSameTypeTermCount" ->
        Total[Lookup[chunkResults, "AfterSameTypeTermCount"]],
      "AfterTripleTermCount" ->
        Total[Lookup[chunkResults, "AfterTripleTermCount"]],
      "ReducedTermCount" -> Length[reduced],
      "InvalidReducedTermCount" -> Length[invalid],
      "CommonBasis" -> {t2, u2},
      "ReconstructionMethod" ->
        "exact common-basis residual for every disjoint input-term partition",
      "ReconstructionChunkSize" -> reconstructionChunkSize,
      "ReconstructionChunkCount" -> reconstructionChunkCount,
      "ReconstructionResidual" -> 0,
      "EveryReconstructionChunkResidualZero" -> True,
      "ReconstructionPassed" -> True
    |>
  |>
];

(* Appendix-B frame 2:
   a + b Cos[beta1] + c Sin[beta1] Cos[beta2]. *)
linearCoefficients[variable_] := Module[
  {rho, yCoefficient, sConstant, sCosine, tConstant, tCosine, uHalf},
  rho = Sqrt[s23 u1 (Q2 s23 + sHat t1)];
  yCoefficient = rho/(s23 - t1);
  sConstant = (sHat - s23)/2;
  sCosine = sConstant + u1 s23/(s23 - t1);
  tConstant = -Q2 - (sHat + t1)/2;
  tCosine = ((sHat + t1) (s23 - t1) -
      2 s23 (sHat + Q2))/(2 (s23 - t1));
  uHalf = (s23 - t1)/2;
  Switch[variable,
    t2, {tConstant, tCosine, yCoefficient},
    t3, {tConstant, -tCosine, -yCoefficient},
    u2, {-uHalf, uHalf, 0},
    u3, {-uHalf, -uHalf, 0},
    s12, {sConstant, -sCosine, -yCoefficient},
    s13, {sConstant, sCosine, yCoefficient},
    _, fatal["Unknown ADMV in linearCoefficients."]
  ]
];

q2ConstraintRule = Q2 -> s23 - sHat - t1 - u1;

reducedLinearCoefficients[variable_] :=
  reducedLinearCoefficients[variable] =
    (Together /@ (linearCoefficients[variable] /. q2ConstraintRule));

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
    {tCoefficients, masslessCoefficients, radius, dCoefficient, cosine},
    tCoefficients = reducedLinearCoefficients[tVariable];
    masslessCoefficients = reducedLinearCoefficients[masslessVariable];
    radius = (Sqrt[(sHat + t1)^2 + 4 Q2 s23]/2) /.
      q2ConstraintRule;
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
  answer = Total[
    (Last[#] masterFromKey[First[#]]) & /@ Normal[grouped]
  ];
  <|
    "Expression" -> answer,
    "MasterKeys" -> Keys[grouped],
    "MasterCount" -> Length[grouped]
  |>
];

(* Eq. (39), and its multiplication by Eq. (19)'s common 1/(2 Pi)^4. *)
eq19CommonFactor = 1/(2 Pi)^4;
eq39ThreeBodyPrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(2 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];
threeBodyPhasePrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(6 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];
identicalSpectatorFactor = 1/2;

assert[
  TrueQ[
    Together[
      eq19CommonFactor eq39ThreeBodyPrefactor -
        threeBodyPhasePrefactor
    ] === 0
  ],
  "Eq. (19) times Eq. (39) does not reproduce the Eq. (38) prefactor."
];
assert[
  identicalSpectatorFactor === 1/2,
  "The identical-spectator factor is not the exact rational 1/2."
];

validateAngularExpression[expression_, label_String] := Module[{},
  assert[
    expression =!= $Failed && expression =!= 0,
    label <> " is failed or identically zero."
  ];
  assert[
    FreeQ[
      expression,
      t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2 |
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum | D |
        Indeterminate | ComplexInfinity | _DirectedInfinity | $Failed |
        _Real
    ],
    label <>
      " contains an angular, propagator, D, infinity, or machine-real object."
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    label <> " does not preserve exactly ScaleMu^(4 epsilon)."
  ];
  True
];

validateAngularRecord[record_Association, projectorName_String] := Module[
  {before, physical},
  assert[
    KeyExistsQ[record, "BeforeIdenticalSpectatorFactor"] &&
      KeyExistsQ[record, "PhysicalAfterIdenticalSpectatorFactor"] &&
      KeyExistsQ[record, "PreparationAudit"] &&
      KeyExistsQ[record, "ReductionAudit"] &&
      KeyExistsQ[record, "MasterKeys"] &&
      KeyExistsQ[record, "MasterCount"],
    projectorName <> " angular record is incomplete."
  ];
  before = record["BeforeIdenticalSpectatorFactor"];
  physical = record["PhysicalAfterIdenticalSpectatorFactor"];
  validateAngularExpression[before, projectorName <> " pre-symmetry result"];
  validateAngularExpression[physical, projectorName <> " physical result"];
  assert[
    TrueQ[Together[physical - before/2] === 0],
    projectorName <> " physical result is not exactly pre-symmetry/2."
  ];
  assert[
    record["PreparationAudit"]["SpectatorExchangeResidual"] === 0 &&
      record["PreparationAudit"]["SpectatorExchangePassed"] === True,
    projectorName <> " angular record lost the spectator-exchange gate."
  ];
  assert[
    record["ReductionAudit"]["InvalidReducedTermCount"] === 0 &&
      record["ReductionAudit"]["ReconstructionResidual"] === 0 &&
      record["ReductionAudit"]["ReconstructionPassed"] === True,
    projectorName <> " angular record lost Appendix-D reconstruction."
  ];
  assert[
    IntegerQ[record["MasterCount"]] &&
      record["MasterCount"] === Length[record["MasterKeys"]] &&
      record["MasterCount"] > 0,
    projectorName <> " angular-master inventory is invalid."
  ];
  True
];

cacheMetadataValidQ[cache_, projectorName_String] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqbar only" &&
    Lookup[cache, "Projector", Missing["Projector"]] === projectorName &&
    Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
      programHash &&
    Lookup[cache, "PaperSHA256", Missing["PaperSHA256"]] ===
      expectedPaperHash &&
    Lookup[cache, "S07SourceSHA256", Missing["S07SourceSHA256"]] ===
      expectedS07SourceHash &&
    Lookup[cache, "S07ResultSHA256", Missing["S07ResultSHA256"]] ===
      expectedS07ResultHash &&
    Lookup[cache, "InputProjectionKey", Missing["InputProjectionKey"]] ===
      "ScalarProjections/NLOReal_OAlphaS2/Hqqbar;q_q/" <>
        projectorName &&
    Lookup[cache, "ScaleBookkeeping", Missing["ScaleBookkeeping"]] ===
      s07["ScaleBookkeeping"] &&
    Lookup[cache, "ChargeBookkeeping", Missing["ChargeBookkeeping"]] ===
      s07["ChargeBookkeeping"] &&
    Lookup[
      cache,
      "UpstreamSymmetryBookkeeping",
      Missing["UpstreamSymmetryBookkeeping"]
    ] === s07["SymmetryBookkeeping"] &&
    Lookup[
      cache,
      "IdenticalSpectatorFactorAppliedAtS08",
      Missing["IdenticalSpectatorFactorAppliedAtS08"]
    ] === True &&
    Lookup[
      cache,
      "IdenticalSpectatorFactor",
      Missing["IdenticalSpectatorFactor"]
    ] === 1/2 &&
    KeyExistsQ[cache, "AngularRecord"];

loadValidatedCache[path_String, projectorName_String] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path],
    Return[Missing["NotAvailable"]]
  ];
  Print["S08_STAGE: inspecting " <> projectorName <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, projectorName]],
    Print[
      "S08_STAGE: deleting stale or invalid " <> projectorName <>
        " cache"
    ];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];
  assert[
    validateAngularRecord[cache["AngularRecord"], projectorName],
    projectorName <> " cached angular record failed validation."
  ];
  Print[
    "S08_STAGE: accepted source-bound " <> projectorName <> " cache"
  ];
  cache["AngularRecord"]
];

writeCache[
    path_String, projectorName_String, angularRecord_Association
  ] := Module[{cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "Channel" -> "Hqqbar only",
    "Projector" -> projectorName,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperHash,
    "S07SourcePath" -> s07SourcePath,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultPath" -> s07ResultPath,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "InputProjectionKey" ->
      "ScalarProjections/NLOReal_OAlphaS2/Hqqbar;q_q/" <>
        projectorName,
    "ScaleBookkeeping" -> s07["ScaleBookkeeping"],
    "ChargeBookkeeping" -> s07["ChargeBookkeeping"],
    "UpstreamSymmetryBookkeeping" -> s07["SymmetryBookkeeping"],
    "IdenticalSpectatorFactor" -> identicalSpectatorFactor,
    "IdenticalSpectatorFactorAppliedAtS08" -> True,
    "AngularRecord" -> angularRecord
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

processRealProjection[projection_, projectorName_String] := Module[
  {cached, prepared, reduction, angularData, before, physical, record},
  cached = loadValidatedCache[cachePaths[projectorName], projectorName];
  If[AssociationQ[cached], Return[cached]];

  prepared = prepareRealExplicit[projection, projectorName];
  reduction = reduceAppendixD[
    prepared["Expression"],
    "Hqqbar;q q " <> projectorName
  ];
  angularData = integrateReducedTerms[
    reduction["Terms"],
    "Hqqbar;q q " <> projectorName
  ];
  before = threeBodyPhasePrefactor angularData["Expression"];
  physical = identicalSpectatorFactor before;
  record = <|
    "PreparationAudit" -> KeyDrop[prepared, {"Expression"}],
    "ReductionAudit" -> reduction["Audit"],
    "MasterKeys" -> angularData["MasterKeys"],
    "MasterCount" -> angularData["MasterCount"],
    "BeforeIdenticalSpectatorFactor" -> before,
    "PhysicalAfterIdenticalSpectatorFactor" -> physical
  |>;
  assert[
    validateAngularRecord[record, projectorName],
    projectorName <> " angular record failed validation."
  ];
  writeCache[cachePaths[projectorName], projectorName, record];
  Print[
    "S08_CHECKPOINT: completed ", projectorName,
    " pre/physical leaf counts ",
    InputForm[{LeafCount[before], LeafCount[physical]}]
  ];
  record
];

validateProjectionPair[pair_Association, label_String] := Module[{},
  assert[
    Keys[pair] === {"Pg", "PPP"},
    label <> " does not contain exactly ordered Pg and PPP."
  ];
  And @@ KeyValueMap[
    validateAngularExpression[#2, label <> " " <> #1] &,
    pair
  ]
];

(* Eqs. (29)-(32): xB, zH, and PHT2 are external hadronic variables. *)
xHatXi = xB/xi;
xiLowerA = xB + xB PHT2/(zH (1 - zH) Q2);
s23UpperB = Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH;
zetaXiS23 =
  (xHatXi PHT2 + zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi));
zHatXiS23 = zH/zetaXiS23;
k1TPartonic2XiS23 = PHT2/zetaXiS23^2;
xiS23Jacobian =
  (xHatXi^2 PHT2 + xHatXi zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi)^2);

partonicToXiS23Rules = {
  sHat -> Q2 (1/xHatXi - 1),
  t1 -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  tHat -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  u1 -> -zHatXiS23 Q2/xHatXi
};

transformPair[pair_Association] := Map[
  Function[expression,
    xiS23Jacobian * (expression /. partonicToXiS23Rules)
  ],
  pair
];

validateXiS23Pair[pair_Association, label_String] := Module[{},
  assert[
    Keys[pair] === {"Pg", "PPP"},
    label <> " transformed pair has the wrong projector keys."
  ];
  assert[
    And @@ (FreeQ[
        #,
        zeta | sHat | tHat | t1 | u1 | t2 | t3 | u2 | u3 | s12 |
          s13 | beta1 | beta2 | D |
          _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum |
          Indeterminate | ComplexInfinity | _DirectedInfinity | _Real
      ] & /@ Values[pair]),
    label <> " retains a replaced, angular, or non-symbolic object."
  ];
  assert[
    And @@ (hasExactlyExpectedScaleQ /@ Values[pair]),
    label <> " does not preserve exactly ScaleMu^(4 epsilon)."
  ];
  True
];

zeroCoefficientVectorQ[vector_List] :=
  And @@ (TrueQ[Together[# /. q2ConstraintRule] === 0] & /@ vector);

Print["S08_STAGE: validating Appendix-D frame identities"];
appendixDIdentityChecks = <|
  "D5_t2_plus_t3" -> zeroCoefficientVectorQ[
    linearCoefficients[t2] + linearCoefficients[t3] -
      {u1 - s23 - Q2, 0, 0}
  ],
  "D6_u2_plus_u3" -> zeroCoefficientVectorQ[
    linearCoefficients[u2] + linearCoefficients[u3] -
      {t1 - s23, 0, 0}
  ],
  "D7_s12_plus_s13" -> zeroCoefficientVectorQ[
    linearCoefficients[s12] + linearCoefficients[s13] -
      {sHat - s23, 0, 0}
  ],
  "D8_s13_relation" -> zeroCoefficientVectorQ[
    linearCoefficients[s13] - linearCoefficients[t2] -
      linearCoefficients[u2] - {sHat + Q2, 0, 0}
  ]
|>;
assert[
  And @@ (TrueQ /@ Values[appendixDIdentityChecks]),
  "At least one Appendix-D frame identity failed."
];

eq40S23Expression =
  (Q2 (
      zHatXiS23 (1 - xHatXi) -
        zHatXiS23^2 (1 - xHatXi)
    ) - xHatXi k1TPartonic2XiS23)/
    (xHatXi zHatXiS23);

variableChangeChecks = <|
  "JacobianDerivativeIdentity" -> TrueQ[
    Together[D[zetaXiS23, s23] - xiS23Jacobian] === 0
  ],
  "Eq40ReconstructsS23" -> TrueQ[
    Together[eq40S23Expression - s23] === 0
  ],
  "PartonicConservationAfterMap" -> TrueQ[
    Together[
      (sHat + t1 + u1 + Q2 - s23) /.
        partonicToXiS23Rules
    ] === 0
  ],
  "XiLowerBoundCollapsesS23UpperBound" -> TrueQ[
    Together[s23UpperB /. xi -> xiLowerA] === 0
  ],
  "S23UpperBoundMapsToZetaOne" -> TrueQ[
    Together[(zetaXiS23 /. s23 -> s23UpperB) - 1] === 0
  ]
|>;
assert[
  And @@ (TrueQ /@ Values[variableChangeChecks]),
  "At least one exact xi-to-s23 variable-change identity failed."
];

Print["S08_STAGE: integrating the two Hqqbar projections serially"];
angularRecords = <|
  "Pg" -> processRealProjection[realInput["Pg"], "Pg"],
  "PPP" -> processRealProjection[realInput["PPP"], "PPP"]
|>;

preSymmetryAngularResults = Map[
  Function[record, record["BeforeIdenticalSpectatorFactor"]],
  angularRecords
];
physicalAngularResults = Map[
  Function[record, record["PhysicalAfterIdenticalSpectatorFactor"]],
  angularRecords
];
assert[
  validateProjectionPair[
    preSymmetryAngularResults,
    "Hqqbar pre-symmetry angular result"
  ],
  "Pre-symmetry angular pair failed validation."
];
assert[
  validateProjectionPair[
    physicalAngularResults,
    "Hqqbar physical angular result"
  ],
  "Physical angular pair failed validation."
];
assert[
  And @@ MapThread[
    TrueQ[Together[#1 - #2/2] === 0] &,
    {Values[physicalAngularResults], Values[preSymmetryAngularResults]}
  ],
  "A physical angular projection is not exactly pre-symmetry/2."
];

Print["S08_STAGE: applying the exact zeta-to-s23 change of variables"];
xiS23Kernels = transformPair[physicalAngularResults];
assert[
  validateXiS23Pair[xiS23Kernels, "Hqqbar xi-s23 kernel"],
  "The Hqqbar xi-s23 kernels failed validation."
];

case2Masters = DeleteDuplicates@Cases[
  Values[physicalAngularResults],
  _S08Case2Master,
  Infinity
];

appendixDReconstructionChecks = Map[
  Function[record,
    TrueQ[
      record["ReductionAudit"]["ReconstructionResidual"] === 0 &&
        record["ReductionAudit"]["ReconstructionPassed"] === True &&
        record["ReductionAudit"]["InvalidReducedTermCount"] === 0
    ]
  ],
  angularRecords
];

spectatorExchangeChecks = Map[
  Function[record,
    TrueQ[
      record["PreparationAudit"]["SpectatorExchangeResidual"] === 0 &&
        record["PreparationAudit"]["SpectatorExchangePassed"] === True
    ]
  ],
  angularRecords
];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "CurrentS07SourceAndResultHashesValidated" -> True,
  "S07UpstreamBindingsAndTwentyFiveChecksValidated" -> True,
  "SoleHqqbarS07PgPPPInputConsumed" -> True,
  "NoHqqOrOtherChannelArtifactConsumed" -> True,
  "ExactRationalCombinationPrecedesAngularClassification" -> True,
  "PgSpectatorExchangeResidualZero" ->
    spectatorExchangeChecks["Pg"],
  "PPPSpectatorExchangeResidualZero" ->
    spectatorExchangeChecks["PPP"],
  "AppendixDIdentitiesD5ThroughD8Verified" ->
    And @@ (TrueQ /@ Values[appendixDIdentityChecks]),
  "PgAppendixDExactReconstruction" ->
    appendixDReconstructionChecks["Pg"],
  "PPPAppendixDExactReconstruction" ->
    appendixDReconstructionChecks["PPP"],
  "BothProjectorsAngularIntegrated" -> True,
  "AppendixB18EvaluatedExactly" -> True,
  "AppendixB19RetainedAsExactSymbolicMaster" -> True,
  "Eq19TimesEq39NormalizationVerified" -> True,
  "Eq39NumericPowerTwoIsMinusTwo" -> True,
  "IdenticalSpectatorFactorIsExactOneHalf" -> True,
  "IdenticalSpectatorFactorAppliedExactlyOnceAtS08" -> True,
  "PhysicalResultsEqualPreSymmetryResultsOverTwo" -> True,
  "NoAngularVariablesOrPropagatorObjectsRemain" -> True,
  "XiS23JacobianDerivativeIdentityVerified" ->
    variableChangeChecks["JacobianDerivativeIdentity"],
  "PaperEq40Verified" ->
    variableChangeChecks["Eq40ReconstructsS23"],
  "PartonicConservationAfterXiS23MapVerified" ->
    variableChangeChecks["PartonicConservationAfterMap"],
  "XiAndS23BoundaryIdentitiesVerified" -> TrueQ[
    variableChangeChecks["XiLowerBoundCollapsesS23UpperBound"] &&
      variableChangeChecks["S23UpperBoundMapsToZetaOne"]
  ],
  "PhysicalXiAndS23LimitsStored" -> True,
  "AbsoluteScaleMuPowerFourEpsilonPreservedExactlyOnce" -> True,
  "ChargeStrippedChannel5AConventionPreserved" -> True,
  "PhysicalFlavorChargeWeightDeferred" -> True,
  "VirtualContributionRemainsAbsent" -> True,
  "CalculationFullySymbolic" -> True,
  "CacheHashValueMappingShapeVerified" -> True,
  "AtomicCachesBindProgramPaperAndS07Hashes" -> True,
  "AppendixFEpsilonExpansionNotApplied" -> True,
  "EndpointDistributionExpansionNotApplied" -> True,
  "CollinearFactorizationNotApplied" -> True,
  "FHatExtractionAndBigTMDComparisonNotApplied" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S08 validation check is not True."
];

angularLeafCounts = <|
  "PreSymmetry" -> Map[LeafCount, preSymmetryAngularResults],
  "Physical" -> Map[LeafCount, physicalAngularResults]
|>;
transformedLeafCounts = Map[LeafCount, xiS23Kernels];

If[preflightOnly,
  Print["S08_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S08_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
  Print[
    "S08_DYNAMIC_PREFLIGHT_ANGULAR_LEAF_COUNTS=",
    InputForm[angularLeafCounts]
  ];
  Print[
    "S08_DYNAMIC_PREFLIGHT_TRANSFORMED_LEAF_COUNTS=",
    InputForm[transformedLeafCounts]
  ];
  Quit[0]
];

Print["S08_STAGE: validating finalized per-projector caches"];
assert[
  And @@ KeyValueMap[
    Function[{projectorName, path},
      FileExistsQ[path] &&
        TrueQ[
          cacheMetadataValidQ[
            Quiet@Check[Get[path], $Failed],
            projectorName
          ]
        ]
    ],
    cachePaths
  ],
  "At least one finalized S08 cache has invalid metadata."
];
cacheHashes = mapAssociationValues[fileSHA256, cachePaths];

symmetryBookkeeping = <|
  "Upstream" -> s07["SymmetryBookkeeping"],
  "IdenticalUnobservedQuarks" -> {"q(k2)", "q(k3)"},
  "LabelledIntegrandSpectatorExchangeSymmetric" -> True,
  "IdenticalSpectatorFactor" -> identicalSpectatorFactor,
  "IdenticalSpectatorFactorAppliedAtS08" -> True,
  "ApplicationCountThroughS08" -> 1,
  "PhysicalExpressionEqualsPreSymmetryOverTwo" -> True,
  "DownstreamReapplicationForbidden" -> True
|>;

s08Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "H_{q qbar; q q} three-body angular-integrated Pg/PPP kernels",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" ->
      "Eqs. (19), (29)-(32), (38)-(40), Appendices B and D"
  |>,
  "Input" -> <|
    "S07SourcePath" -> s07SourcePath,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultPath" -> s07ResultPath,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "ProjectionKey" ->
      "ScalarProjections/NLOReal_OAlphaS2/Hqqbar;q_q/{Pg,PPP}"
  |>,
  "DimensionalConvention" -> HoldForm[D == 4 - 2 epsilon],
  "ObservedMomentumTreatment" ->
    "fragmenting qbar(k1) remains differential; only unobserved identical q(k2),q(k3) angles are integrated",
  "PhaseSpaceNormalization" -> <|
    "Eq19CommonFactor" -> eq19CommonFactor,
    "Eq39OutsideAngularWeights" -> eq39ThreeBodyPrefactor,
    "Eq38CombinedPrefactor" -> threeBodyPhasePrefactor,
    "Eq39ExactNumericPower" -> HoldForm[2^(-2)],
    "AngularWeightsIntegrated" -> HoldForm[
      Sin[beta1]^(1 - 2 epsilon) Sin[beta2]^(-2 epsilon)
    ],
    "NormalizationIdentityVerified" -> True
  |>,
  "ScaleBookkeeping" -> s07["ScaleBookkeeping"],
  "ChargeBookkeeping" -> s07["ChargeBookkeeping"],
  "SymmetryBookkeeping" -> symmetryBookkeeping,
  "VirtualContributionAtThisOrder" ->
    s07["VirtualContributionAtThisOrder"],
  "PreSymmetryAngularAudit" -> <|
    "Hqqbar;q_q" -> preSymmetryAngularResults
  |>,
  "ThreeBodyAngularIntegrated" -> <|
    "Hqqbar;q_q" -> physicalAngularResults
  |>,
  "XiS23ConvolutionKernels" -> <|
    "ThreeBodyReal" -> <|
      "Hqqbar;q_q" -> xiS23Kernels
    |>
  |>,
  "XiS23ChangeOfVariables" -> <|
    "Replacement" -> HoldForm[zeta == zetaXiS23],
    "XHat" -> xHatXi,
    "ZetaExpression" -> zetaXiS23,
    "ZHatExpression" -> zHatXiS23,
    "PartonicK1TransverseMomentumSquared" -> k1TPartonic2XiS23,
    "Jacobian_dXi_dZeta_to_dXi_dS23" -> xiS23Jacobian,
    "XiRange" -> {xi, xiLowerA, 1},
    "S23RangeAtFixedXi" -> {s23, 0, s23UpperB},
    "XiLowerA" -> xiLowerA,
    "S23UpperB" -> s23UpperB,
    "PartonicKinematicRules" -> partonicToXiS23Rules,
    "Checks" -> variableChangeChecks,
    "RemainingXiS23ConvolutionPerformed" -> False
  |>,
  "AngularMasterBasis" -> <|
    "MasslessMassless" -> "Eq. (B18), evaluated exactly",
    "VirtualPhotonMassless" ->
      "Eq. (B19), retained as exact S08Case2Master",
    "Case2MastersUsed" -> case2Masters,
    "Case2MasterCount" -> Length[case2Masters],
    "PerProjectorMasterKeys" -> Map[
      Function[record, record["MasterKeys"]],
      angularRecords
    ],
    "PerProjectorMasterCounts" -> Map[
      Function[record, record["MasterCount"]],
      angularRecords
    ],
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
  "AppendixD" -> <|
    "IdentityChecks" -> appendixDIdentityChecks,
    "ProjectionAudits" -> Map[
      Function[record, record["ReductionAudit"]],
      angularRecords
    ],
    "ExactCommonBasisReconstructionPassed" ->
      appendixDReconstructionChecks
  |>,
  "SpectatorExchangeAudit" -> <|
    "Rules" -> spectatorExchangeRules,
    "ProjectionChecks" -> spectatorExchangeChecks
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "Paths" -> cachePaths,
    "SHA256" -> cacheHashes,
    "AtomicAndSourceBound" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "Appendix-F epsilon expansion of Eq. (B19) masters",
    "B21-B27 analytic continuation formulas",
    "s23 endpoint delta/plus-distribution expansion",
    "remaining xi and s23 convolution",
    "physical Sum_q e_q^2 f_q D_qbar assembly",
    "MS-bar PDF/FF collinear factorization",
    "epsilon -> 0 limit",
    "F-hat extraction or BigTMD comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized S09 may expand the retained masters and endpoint distributions. It must consume the physical post-1/2 kernels and must not reapply the identical-spectator factor."
|>;

Print["S08_STAGE: atomically writing the Hqqbar S08 result"];
atomicPutAssociation[s08Result, s08ResultPath, stageVersion];

reloadedResult = Quiet@Check[Get[s08ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion,
  "Final s08_result failed status/stage/schema reload validation."
];
assert[
  reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input"]["S07SourceSHA256"] ===
      expectedS07SourceHash &&
    reloadedResult["Input"]["S07ResultSHA256"] ===
      expectedS07ResultHash &&
    reloadedResult["PaperReference"]["SHA256"] === expectedPaperHash,
  "Final s08_result failed source/upstream/paper hash validation."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Final s08_result contains a failed check."
];
assert[
  reloadedResult["PreSymmetryAngularAudit"]["Hqqbar;q_q"] ===
      preSymmetryAngularResults &&
    reloadedResult["ThreeBodyAngularIntegrated"]["Hqqbar;q_q"] ===
      physicalAngularResults &&
    reloadedResult["XiS23ConvolutionKernels"]["ThreeBodyReal"]
      ["Hqqbar;q_q"] === xiS23Kernels,
  "Final s08_result failed exact payload reload validation."
];
assert[
  reloadedResult["SymmetryBookkeeping"]
      ["IdenticalSpectatorFactorAppliedAtS08"] === True &&
    reloadedResult["SymmetryBookkeeping"]
      ["IdenticalSpectatorFactor"] === 1/2 &&
    reloadedResult["SymmetryBookkeeping"]
      ["ApplicationCountThroughS08"] === 1,
  "Final s08_result lost the one-time identical-spectator ledger."
];
assert[
  And @@ KeyValueMap[
    Function[{projectorName, path},
      reloadedResult["CacheProvenance"]["SHA256"][projectorName] ===
        fileSHA256[path]
    ],
    cachePaths
  ],
  "Final s08_result cache hashes do not match disk."
];
assert[
  FileNames["s08_result.tmp.*", scriptDirectory] === {} &&
    FileNames["s08_cache_hqqbar*.tmp.*", scriptDirectory] === {},
  "An S08 temporary file remains after finalization."
];

Print["S08_SUCCESS"];
Print["S08_PROGRAM_SHA256=" <> programHash];
Print["S08_RESULT_PATH=" <> s08ResultPath];
Print["S08_RESULT_SHA256=" <> fileSHA256[s08ResultPath]];
Print["S08_CACHE_SHA256=", InputForm[cacheHashes]];
Print["S08_CHECK_COUNT=", Length[checks]];
Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
Print["S08_ANGULAR_LEAF_COUNTS=", InputForm[angularLeafCounts]];
Print["S08_TRANSFORMED_LEAF_COUNTS=", InputForm[transformedLeafCounts]];
Print["S08_RESULT_BYTES=", FileByteCount[s08ResultPath]];

Quit[0];

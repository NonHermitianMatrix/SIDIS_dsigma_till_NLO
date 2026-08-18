(* ::Package:: *)

(*
  Hqqbar stage S09: expand the Eq. (B19) masters retained by the accepted
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
  atomicPutAssociation, boundedOperation, hasExactlyExpectedScaleQ,
  appendixFExpansion, appendixFZeroJ, expandOneMaster,
  expandAppendixFMasters, expandCase1Functions,
  toRecurrenceBasis, recurrenceResidual, b19F8MomentResiduals,
  validateExpandedKernel, cacheMetadataValidQ,
  loadValidatedCache, processProjector,
  formalEndpointDistribution,
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
  FileNameJoin[{scriptDirectory, "s07_contract_hqqbar_projectors.wl"}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
s08SourcePath =
  FileNameJoin[{scriptDirectory, "s08_phase_space_integrate_hqqbar.wl"}];
s08ResultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
s08CachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s08_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s08_cache_hqqbar_ppp"}]
|>;
resultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s09_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s09_cache_hqqbar_ppp"}]
|>;

stageVersion = "HqqbarS09-v1";
cacheStageVersion = "HqqbarS09Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S09_PREFLIGHT_ONLY"], ""] === "1";
memoryBudgetBytes = 7 2^30;
projectorOrder = {"Pg", "PPP"};

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS07SourceHash =
  "4631639ae9e06a266e507d8854ee0cadf55d9106faff5ab13fe616f33fb50db4";
expectedS07ResultHash =
  "a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50";
expectedS08SourceHash =
  "2947bef60f303969ba451fc69cf1af76b0550a4f0d18bc2632d43568bf95bda6";
expectedS08ResultHash =
  "163eea0d42febe7642abb106599aa7d8c594eed2e6888a62cc1dde7985ec0dec";
expectedS08CacheHashes = <|
  "Pg" ->
    "a762eb92f48397e9150c1c1aed22278979c4104642eede680f9eea7e32a8baec",
  "PPP" ->
    "57e7ae86126b054513258fdd8a125f8736151b7526fc6cf6e9bfad193947e03b"
|>;

programHash = fileSHA256[programPath];
preflightArtifactSnapshot = Sort@FileNames["s09_*", scriptDirectory];
staleTemporaryPaths = Join[
  FileNames["s09_result.tmp.*", scriptDirectory],
  FileNames["s09_cache_hqqbar*.tmp.*", scriptDirectory]
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

Print["S09_STAGE: validating the paper and accepted Hqqbar S07/S08 handoff"];
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
assert[
  s08["Status"] === "Complete" &&
    s08["Stage"] === "HqqbarS08-v1" &&
    s08["ResultSchemaVersion"] === 1 &&
    s08["Channel"] === "Hqqbar only" &&
    s08["ProgramSHA256"] === expectedS08SourceHash &&
    s08["PaperReference"]["SHA256"] === expectedPaperHash,
  "s08_result failed status, schema, channel, program, or paper validation."
];
assert[
  And @@ (TrueQ /@ Values[s08["Checks"]]) &&
    Length[s08["Checks"]] === 36,
  "The accepted S08 result does not contain exactly 36 true checks."
];
assert[
  s08["Input"]["S07SourceSHA256"] === expectedS07SourceHash &&
    s08["Input"]["S07ResultSHA256"] === expectedS07ResultHash,
  "The S08 result lost its accepted S07 source/result binding."
];
assert[
  s08["CacheProvenance"]["ProgramSHA256"] === expectedS08SourceHash &&
    s08["CacheProvenance"]["PaperSHA256"] === expectedPaperHash &&
    s08["CacheProvenance"]["S07SourceSHA256"] ===
      expectedS07SourceHash &&
    s08["CacheProvenance"]["S07ResultSHA256"] ===
      expectedS07ResultHash &&
    s08["CacheProvenance"]["Paths"] === s08CachePaths &&
    s08["CacheProvenance"]["SHA256"] === expectedS08CacheHashes &&
    s08["CacheProvenance"]["AtomicAndSourceBound"] === True,
  "The S08 cache-provenance handoff is incomplete or stale."
];

physicalAngular =
  s08["ThreeBodyAngularIntegrated"]["Hqqbar;q_q"];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicToXiS23Rules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["Jacobian_dXi_dZeta_to_dXi_dS23"];
s23UpperB = changeOfVariables["S23UpperB"];
scaleBookkeeping = s08["ScaleBookkeeping"];
chargeBookkeeping = s08["ChargeBookkeeping"];
symmetryBookkeeping = s08["SymmetryBookkeeping"];
virtualBookkeeping = s08["VirtualContributionAtThisOrder"];

assert[
  AssociationQ[physicalAngular] && Keys[physicalAngular] === projectorOrder,
  "S08 does not contain exactly the ordered physical Pg/PPP angular pair."
];
assert[
  ListQ[partonicToXiS23Rules] && Length[partonicToXiS23Rules] === 4 &&
    ! MissingQ[xiS23Jacobian] && ! MissingQ[s23UpperB],
  "The accepted exact xi,s23 transformation is incomplete."
];
assert[
  scaleBookkeeping === <|
    "AbsoluteFactor" -> FeynCalc`ScaleMu^(4 epsilon),
    "PowerPreservedExactlyOnceInEveryProjection" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "The accepted one-scale/no-extra-MS-bar ledger changed."
];
assert[
  chargeBookkeeping === <|
    "TensorIsChargeStripped" -> True,
    "PhysicalChargeWeight" -> "Sum_q e_q^2 f_q D_qbar",
    "PhysicalChargeWeightAppliedAtS06" -> False,
    "BigTMDChannel" -> 5,
    "BigTMDChargeCase" -> "A only"
  |>,
  "The accepted charge-stripped channel-5A ledger changed."
];
assert[
  symmetryBookkeeping["IdenticalSpectatorFactor"] === 1/2 &&
    symmetryBookkeeping["IdenticalSpectatorFactorAppliedAtS08"] === True &&
    symmetryBookkeeping["ApplicationCountThroughS08"] === 1 &&
    symmetryBookkeeping["DownstreamReapplicationForbidden"] === True,
  "The one-time identical-spectator bookkeeping changed."
];
assert[
  virtualBookkeeping === <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" -> "NotApplicableAtThisOrder"
  |>,
  "A forbidden Hqqbar virtual branch appeared in the S08 handoff."
];

Do[
  acceptedS08Cache = Check[Get[s08CachePaths[projector]], $Failed];
  assert[
    AssociationQ[acceptedS08Cache] &&
      acceptedS08Cache["Status"] === "Complete" &&
      acceptedS08Cache["Stage"] === "HqqbarS08Cache-v1" &&
      acceptedS08Cache["Projector"] === projector &&
      acceptedS08Cache["ProgramSHA256"] === expectedS08SourceHash &&
      acceptedS08Cache["PaperSHA256"] === expectedPaperHash &&
      acceptedS08Cache["S07SourceSHA256"] === expectedS07SourceHash &&
      acceptedS08Cache["S07ResultSHA256"] === expectedS07ResultHash &&
      acceptedS08Cache["IdenticalSpectatorFactor"] === 1/2 &&
      acceptedS08Cache["IdenticalSpectatorFactorAppliedAtS08"] === True &&
      acceptedS08Cache["AngularRecord"]
        ["PhysicalAfterIdenticalSpectatorFactor"] ===
          physicalAngular[projector],
    "The accepted S08 " <> projector <>
      " cache failed metadata or exact-payload validation."
  ];
  Clear[acceptedS08Cache],
  {projector, projectorOrder}
];

hasExactlyExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /. HoldPattern[
      FeynCalc`ScaleMu^(4 epsilon)
    ] :> 1;
  ! FreeQ[expression, FeynCalc`ScaleMu^(4 epsilon)] &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

assert[
  AllTrue[Values[physicalAngular], hasExactlyExpectedScaleQ],
  "An S08 physical angular input lost the exact single scale factor."
];

masterOccurrencesByProjector = mapAssociationValues[
  Cases[#, _S08Case2Master, Infinity] &,
  physicalAngular
];
assert[
  And @@ KeyValueMap[
    Function[{projector, occurrences},
      Length[occurrences] ===
        Count[physicalAngular[projector], _S08Case2Master, Infinity]
    ],
    masterOccurrencesByProjector
  ],
  "A malformed B19 master occurrence escaped the inventory."
];

actualPairsByProjector = mapAssociationValues[
  Sort@DeleteDuplicates@Map[
    Function[master, {master[[1]], master[[2]]}],
    #
  ] &,
  masterOccurrencesByProjector
];
masterOccurrenceCounts = mapAssociationValues[
  Length,
  masterOccurrencesByProjector
];
distinctMasterInstancesByProjector = mapAssociationValues[
  DeleteDuplicates,
  masterOccurrencesByProjector
];

expectedPairsByProjector = <|
  "Pg" -> Sort@{
    {-1, 0}, {-1, 1}, {-1, 2},
    {0, -1}, {0, 1}, {0, 2},
    {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
    {2, -1}, {2, 0}, {2, 1}, {2, 2}
  },
  "PPP" -> Sort@{
    {-2, 0}, {-2, 1},
    {-1, -1}, {-1, 0}, {-1, 1},
    {0, -2}, {0, -1}, {0, 1}, {0, 2},
    {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
    {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
  }
|>;
expectedAllPairs = Sort@{
  {-2, 0}, {-2, 1},
  {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {0, -2}, {0, -1}, {0, 1}, {0, 2},
  {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};

assert[
  actualPairsByProjector === expectedPairsByProjector,
  "The exact per-projector S08 B19 pair inventory changed."
];
assert[
  masterOccurrenceCounts === <|"Pg" -> 68, "PPP" -> 73|> &&
    Total[Values[masterOccurrenceCounts]] === 141 &&
    Sort@DeleteDuplicates@Flatten[
      Values[actualPairsByProjector],
      1
    ] === expectedAllPairs &&
    Length@DeleteDuplicates@Flatten[
      Values[distinctMasterInstancesByProjector],
      1
    ] === 59,
  "The accepted 21-class/141-occurrence/59-instance master inventory changed."
];
Print["S09_MASTER_PAIRS=", InputForm[expectedAllPairs]];
Print["S09_MASTER_OCCURRENCES=", InputForm[masterOccurrenceCounts]];

(* Appendix F abbreviations F1-F5 and required formulas F8-F29. *)
appendixFExpansion[j_Integer, l_Integer, d_, c_, eps_] := Module[
  {ll, kk, ff, gg},
  ll = Log[(d + 1)/(d - 1)];
  kk = PolyLog[2, 2/(d + 1)] - PolyLog[2, -2/(d - 1)];
  ff = c^2 (1 - 3 d^2) + 4 c d + d^2 - 3;
  gg = c^2 (3 d^2 - 1) - 4 c d - d^2 + 3;

  Switch[{j, l},
    (* F8. *)
    {1, -3},
      Pi (5 c^3 d^2 - 4 c^3/3 -
        (c d - 1) (5 c^2 d^2 - 3 c^2 - 4 c d - 3 d^2 + 5) ll/2 -
        9 c^2 d - 3 c d^2 + 8 c + 3 d) +
      Pi eps (-(c d - 1) *
        (c^2 (5 d^2 - 3) - 4 c d - 3 d^2 + 5) kk/2 +
        (117 c^3 d^2 - 32 c^3 -
          27 (c d - 1) (c^2 d^2 - c^2 - d^2 + 1) ll/2 -
          189 c^2 d - 81 c d^2 + 156 c + 81 d)/9),

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

zeroJExpansions = Association@Map[
  Function[l, ToString[l] -> appendixFZeroJ[l, epsilon]],
  {-2, -1, 0, 1, 2}
];
assert[
  Keys[zeroJExpansions] === {"-2", "-1", "0", "1", "2"} &&
    AllTrue[Values[zeroJExpansions], FreeQ[#, _Beta | _Gamma] &],
  "The exact B18 j=0 expansion table is incomplete."
];

implementedNonzeroPairs = Sort@{
  {-2, 0}, {-2, 1},
  {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};
assert[
  AllTrue[
    implementedNonzeroPairs,
    appendixFExpansion[#[[1]], #[[2]], s09D, s09C, epsilon] =!=
      $Failed &
  ] &&
    SubsetQ[
      implementedNonzeroPairs,
      Select[expectedAllPairs, First[#] =!= 0 &]
    ],
  "At least one physical nonzero-j Appendix-F formula is unavailable."
];

expandOneMaster[master_S08Case2Master] := master /. HoldPattern[
    S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon]
  ] :> If[
    j === 0,
    Lookup[zeroJExpansions, ToString[l], $Failed],
    appendixFExpansion[j, l, d, c, epsilon]
  ];

expandAppendixFMasters[expression_] := expression /. HoldPattern[
    S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon]
  ] :> If[
    j === 0,
    Lookup[zeroJExpansions, ToString[l], $Failed],
    appendixFExpansion[j, l, d, c, epsilon]
  ];

(*
  Exact recurrence audit from B19:
      partial_D I[j,l](D,C) = -j I[j+1,l](D,C).
  All logarithm rewrites below are valid on Appendix F's physical branch
  D>1, -1<C<1.  They are explicit identities, not PowerExpand.
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

recurrenceSpecifications = {
  {"F16_to_F17_l0", -2, 0, 1},
  {"F22_to_F23_l1", -2, 1, 1},
  {"F15_to_B18_lMinus1", -1, -1, 1},
  {"F17_to_B18_l0", -1, 0, 1},
  {"F23_to_B18_l1", -1, 1, 1},
  {"F27_to_B18_l2", -1, 2, 1},
  {"F12_to_F13_lMinus2", 1, -2, 1},
  {"F20_to_F21_lMinus1", 1, -1, 1},
  {"F18_to_F19_l0", 1, 0, 1},
  {"F24_to_F25_l1", 1, 1, 1},
  {"F28_to_F29_l2", 1, 2, 0}
};

(*
  The printed epsilon term of F9 is not used: at C=0,D=2 it disagrees with
  a direct high-precision evaluation of the defining B19 angular integral,
  while F8 agrees.  Validate the physically required F8 independently and
  exactly instead.  After integrating beta2, the l=-3 B19 integral has

    P(x) = (1-C x)^3 + 3/2 (1-C x)(1-C^2)(1-x^2)

  at epsilon^0, and R(x)+P(x) Log[4/(1-x^2)] at epsilon^1, with
  R(x)=3/2 (1-C x)(1-C^2)(1-x^2).  Polynomial division reduces the beta1
  integral to J_n and H_n.  The only base integrals are

    J_0=L, H_0=K,
    Integral[x^k]=2/(k+1) for even k,
    Integral[Log[4/(1-x^2)]]=4,
    Integral[x^2 Log[4/(1-x^2)]]=16/9.

  This is an exact symbolic consequence of B19 and is independent of F9.
*)
b19F8MomentResiduals[] := Module[
  {x, d, c, ll, kk, a, p, r, ordinaryMoment, logMoment,
    directLeading, directEpsilon, paperLeading, paperEpsilon,
    canonicalizePaper},
  x = s09MomentX;
  d = s09MomentD;
  c = s09MomentC;
  ll = s09MomentL;
  kk = s09MomentK;
  a = 1 - c x;
  p = Expand[a^3 + 3 a (1 - c^2) (1 - x^2)/2];
  r = Expand[3 a (1 - c^2) (1 - x^2)/2];

  ordinaryMoment[n_Integer] := d^n ll - If[
    n === 0,
    0,
    Sum[
      d^(n - 1 - k) If[EvenQ[k], 2/(k + 1), 0],
      {k, 0, n - 1}
    ]
  ];
  logMoment[n_Integer] := d^n kk - If[
    n === 0,
    0,
    Sum[
      d^(n - 1 - k) Switch[k, 0, 4, 1, 0, 2, 16/9],
      {k, 0, n - 1}
    ]
  ];

  directLeading = Sum[
    Coefficient[p, x, n] ordinaryMoment[n],
    {n, 0, 3}
  ];
  directEpsilon = Sum[
    Coefficient[r, x, n] ordinaryMoment[n] +
      Coefficient[p, x, n] logMoment[n],
    {n, 0, 3}
  ];

  canonicalizePaper[expression_] := Together@Expand[
    expression /. {
      (HoldPattern[PolyLog[2, argument_]] /;
          TrueQ[Together[argument + 2/(d - 1)] === 0]) :>
        PolyLog[2, 2/(d + 1)] - kk,
      (HoldPattern[Log[argument_]] /;
          TrueQ[Together[argument - (d + 1)/(d - 1)] === 0]) :>
        ll
    }
  ];
  paperLeading = canonicalizePaper[
    Coefficient[
      appendixFExpansion[1, -3, d, c, epsilon]/Pi,
      epsilon,
      0
    ]
  ];
  paperEpsilon = canonicalizePaper[
    Coefficient[
      appendixFExpansion[1, -3, d, c, epsilon]/Pi,
      epsilon,
      1
    ]
  ];
  <|
    "F8LeadingFromB19Moments" ->
      Together[Expand[paperLeading - directLeading]],
    "F8EpsilonFromB19Moments" ->
      Together[Expand[paperEpsilon - directEpsilon]]
  |>
];

Print["S09_STAGE: checking Appendix-F formulas with the exact B19 recurrence"];
appendixFRecurrenceResiduals = Association@Map[
  Function[specification,
    specification[[1]] -> recurrenceResidual[
      specification[[2]],
      specification[[3]],
      specification[[4]]
    ]
  ],
  recurrenceSpecifications
];
b19F8Residuals = b19F8MomentResiduals[];
Print[
  "S09_APPENDIX_F_RECURRENCE_RESIDUALS=",
  InputForm[appendixFRecurrenceResiduals]
];
Print[
  "S09_F8_B19_MOMENT_RESIDUALS=",
  InputForm[b19F8Residuals]
];
assert[
  AllTrue[Values[appendixFRecurrenceResiduals], TrueQ[# === 0] &],
  "At least one exact Appendix-F/B18 derivative recurrence failed."
];
assert[
  AllTrue[Values[b19F8Residuals], TrueQ[# === 0] &],
  "F8 failed its independent exact B19 moment-reduction validation."
];
Print[
  "S09_APPENDIX_F_RECURRENCE_CHECKS=",
  InputForm[Map[TrueQ[# === 0] &, appendixFRecurrenceResiduals]]
];

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
  "S09_B27_SIGNATURES=",
  InputForm[hypergeometricSignaturesByProjector]
];
Print[
  "S09_B27_COUNTS=",
  InputForm[hypergeometricCountsByProjector]
];
Print["S09_B18_BETA_SIGNATURES=", InputForm[betaSignatures]];
Print["S09_B18_GAMMA_OBJECTS=", InputForm[gammaObjects]];

assert[
  hypergeometricSignaturesByProjector === <|
    "Pg" -> {HoldComplete[1, 1, 1 - epsilon]},
    "PPP" -> {HoldComplete[1, 1, 1 - epsilon]}
  |> &&
    hypergeometricCountsByProjector === <|"Pg" -> 3, "PPP" -> 3|> &&
    Total[Values[hypergeometricCountsByProjector]] === 6,
  "The residual B27 hypergeometric inventory changed."
];
assert[
  Sort[betaSignatures] === Sort@{
    HoldComplete[2 - epsilon, -epsilon],
    HoldComplete[3 - epsilon, -epsilon],
    HoldComplete[-epsilon, 2 - epsilon],
    HoldComplete[-epsilon, -epsilon]
  } &&
    gammaObjects === {Gamma[1 - 2 epsilon], Gamma[1 - epsilon]},
  "The exact B18 Beta/Gamma inventory changed."
];

betaRules = Map[
  Function[betaObject,
    betaObject -> Normal@Series[
      FunctionExpand[betaObject],
      {epsilon, 0, 2}
    ]
  ],
  betaObjects
];
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
assert[
  AllTrue[Values[gammaSeriesRatioRegression], TrueQ[# === 0] &],
  "Individual Gamma series do not reconstruct both required ratios through epsilon^2."
];

expandCase1Functions[expression_] := Module[{answer},
  answer = expression /. HoldPattern[
      Hypergeometric2F1[1, 1, 1 - epsilon, w_]
    ] :> (1 - w)^(-1 - epsilon) *
      (1 + epsilon^2 PolyLog[2, w]);
  answer = answer /. betaRules;
  answer = answer /. HoldPattern[
      Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2
    ] :> gammaRatio1;
  answer = answer /. HoldPattern[
      Gamma[1 - epsilon]/Gamma[1 - 2 epsilon]
    ] :> gammaRatio2;
  answer = answer /. {
    (HoldPattern[Gamma[argument_]] /;
        TrueQ[Together[argument - (1 - epsilon)] === 0]) :>
      gammaOneSeries,
    (HoldPattern[Gamma[argument_]] /;
        TrueQ[Together[argument - (1 - 2 epsilon)] === 0]) :>
      gammaTwoSeries
  };
  answer
];

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

validateExpandedKernel[expression_, projector_String] := Module[{},
  assert[
    expression =!= 0 && expression =!= $Failed &&
      FreeQ[
        expression,
        _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma |
          _FeynCalc`FeynAmpDenominator | _Real | Indeterminate |
          ComplexInfinity | DirectedInfinity | _Inactive
      ],
    projector <>
      " expanded kernel retains a master/special/numerical/invalid object."
  ];
  assert[
    FreeQ[expression, sHat | t1 | tHat | u1 | zeta | zHat | beta1 | beta2],
    projector <> " expanded kernel was not fully mapped to xi,s23 variables."
  ];
  assert[
    hasExactlyExpectedScaleQ[expression],
    projector <> " expanded kernel lost the exact single ScaleMu factor."
  ];
  True
];

cacheMetadataValidQ[cache_, projector_String] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "ResultSchemaVersion", Missing["Schema"]] ===
      resultSchemaVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqbar only" &&
    Lookup[cache, "Projector", Missing["Projector"]] === projector &&
    Lookup[cache, "ProgramSHA256", Missing["Program"]] === programHash &&
    Lookup[cache, "PaperSHA256", Missing["Paper"]] === expectedPaperHash &&
    Lookup[cache, "S07SourceSHA256", Missing["S07Source"]] ===
      expectedS07SourceHash &&
    Lookup[cache, "S07ResultSHA256", Missing["S07Result"]] ===
      expectedS07ResultHash &&
    Lookup[cache, "S08SourceSHA256", Missing["S08Source"]] ===
      expectedS08SourceHash &&
    Lookup[cache, "S08ResultSHA256", Missing["S08Result"]] ===
      expectedS08ResultHash &&
    Lookup[cache, "S08CacheSHA256", Missing["S08Cache"]] ===
      expectedS08CacheHashes[projector] &&
    Lookup[cache, "InputKey", Missing["InputKey"]] ===
      "ThreeBodyAngularIntegrated/Hqqbar;q_q/" <> projector &&
    Lookup[cache, "MasterPairs", Missing["Pairs"]] ===
      expectedPairsByProjector[projector] &&
    Lookup[cache, "MasterOccurrenceCount", Missing["Occurrences"]] ===
      masterOccurrenceCounts[projector] &&
    Lookup[cache, "AdditionalMultiplicativeWeight", Missing["Weight"]] ===
      1 &&
    Lookup[cache, "ScaleBookkeeping", Missing["Scale"]] ===
      scaleBookkeeping &&
    Lookup[cache, "ChargeBookkeeping", Missing["Charge"]] ===
      chargeBookkeeping &&
    Lookup[cache, "SymmetryBookkeeping", Missing["Symmetry"]] ===
      symmetryBookkeeping &&
    Lookup[cache, "VirtualContributionAtThisOrder", Missing["Virtual"]] ===
      virtualBookkeeping &&
    KeyExistsQ[cache, "Expression"];

loadValidatedCache[projector_String] := Module[{path, cache},
  If[preflightOnly, Return[Missing["PreflightBypass"]]];
  path = cachePaths[projector];
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S09_STAGE: validating existing " <> projector <> " cache"];
  cache = Check[Get[path], $Failed];
  assert[
    cacheMetadataValidQ[cache, projector],
    "Existing " <> projector <>
      " S09 cache is stale or invalid; it was not silently reused or deleted."
  ];
  assert[
    validateExpandedKernel[cache["Expression"], projector],
    "Existing " <> projector <> " S09 cache expression failed validation."
  ];
  cache
];

processProjector[input_, projector_String] := Module[
  {cached, expandedAngular, expandedXiS23, payload, reloaded, summary,
    residualExpansionInventory},
  cached = loadValidatedCache[projector];
  If[
    AssociationQ[cached],
    summary = <|
      "Projector" -> projector,
      "MasterPairs" -> cached["MasterPairs"],
      "MasterOccurrenceCount" -> cached["MasterOccurrenceCount"],
      "ExpandedLeafCount" -> cached["ExpandedLeafCount"],
      "ExpandedByteCount" -> cached["ExpandedByteCount"],
      "CacheResumed" -> True,
      "CurrentExpandedExpressionValidated" -> True,
      "CurrentCacheReloadValidated" -> True
    |>;
    Clear[cached];
    Return[summary]
  ];

  Print[
    "S09_STAGE: Appendix-F/B18/B27 expansion for Hqqbar " <> projector
  ];
  expandedAngular = boundedOperation[
    projector <> " angular-master expansion",
    expandCase1Functions[expandAppendixFMasters[input]]
  ];
  residualExpansionInventory = <|
    "Case2MasterCount" ->
      Count[expandedAngular, _S08Case2Master, Infinity],
    "HypergeometricCount" ->
      Count[expandedAngular, _Hypergeometric2F1, Infinity],
    "BetaCount" -> Count[expandedAngular, _Beta, Infinity],
    "GammaCount" -> Count[expandedAngular, _Gamma, Infinity],
    "FailedCount" -> Count[expandedAngular, $Failed, Infinity],
    "MachineRealCount" -> Count[expandedAngular, _Real, Infinity],
    "UniqueCase2Masters" ->
      DeleteDuplicates@Cases[expandedAngular, _S08Case2Master, Infinity],
    "UniqueHypergeometrics" ->
      DeleteDuplicates@Cases[expandedAngular, _Hypergeometric2F1, Infinity],
    "UniqueBetas" -> DeleteDuplicates@Cases[expandedAngular, _Beta, Infinity],
    "UniqueGammas" -> DeleteDuplicates@Cases[expandedAngular, _Gamma, Infinity]
  |>;
  Print[
    "S09_", projector, "_RESIDUAL_EXPANSION_INVENTORY=",
    InputForm[residualExpansionInventory]
  ];
  assert[
    FreeQ[
      expandedAngular,
      _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma | $Failed |
        _Real
    ],
    projector <> " angular-master expansion is incomplete."
  ];

  Print[
    "S09_STAGE: applying accepted exact xi,s23 map to " <> projector
  ];
  expandedXiS23 = boundedOperation[
    projector <> " xi,s23 transformation",
    xiS23Jacobian * (expandedAngular /. partonicToXiS23Rules)
  ];
  Clear[expandedAngular];
  assert[
    validateExpandedKernel[expandedXiS23, projector],
    projector <> " transformed expanded kernel failed validation."
  ];

  summary = <|
    "Projector" -> projector,
    "MasterPairs" -> expectedPairsByProjector[projector],
    "MasterOccurrenceCount" -> masterOccurrenceCounts[projector],
    "ExpandedLeafCount" -> LeafCount[expandedXiS23],
    "ExpandedByteCount" -> ByteCount[expandedXiS23],
    "CacheResumed" -> False,
    "CurrentExpandedExpressionValidated" -> True,
    "CurrentCacheReloadValidated" -> If[
      preflightOnly,
      "Not applicable in no-write preflight",
      False
    ]
  |>;

  If[
    ! preflightOnly,
    payload = <|
      "Status" -> "Complete",
      "Stage" -> cacheStageVersion,
      "ResultSchemaVersion" -> resultSchemaVersion,
      "Channel" -> "Hqqbar only",
      "Projector" -> projector,
      "GeneratedAt" -> DateString[Now, "ISODateTime"],
      "ProgramPath" -> programPath,
      "ProgramSHA256" -> programHash,
      "PaperPath" -> paperPath,
      "PaperSHA256" -> expectedPaperHash,
      "S07SourceSHA256" -> expectedS07SourceHash,
      "S07ResultSHA256" -> expectedS07ResultHash,
      "S08SourcePath" -> s08SourcePath,
      "S08SourceSHA256" -> expectedS08SourceHash,
      "S08ResultPath" -> s08ResultPath,
      "S08ResultSHA256" -> expectedS08ResultHash,
      "S08CachePath" -> s08CachePaths[projector],
      "S08CacheSHA256" -> expectedS08CacheHashes[projector],
      "InputKey" ->
        "ThreeBodyAngularIntegrated/Hqqbar;q_q/" <> projector,
      "MasterPairs" -> expectedPairsByProjector[projector],
      "MasterOccurrenceCount" -> masterOccurrenceCounts[projector],
      "ExpansionOrders" -> <|
        "NonzeroJExceptF28F29" -> "through epsilon^1",
        "F28F29" -> "through epsilon^0",
        "B18ZeroJ" -> "through epsilon^2",
        "B27" -> "through epsilon^2"
      |>,
      "ResidualB27Signature" -> HoldComplete[1, 1, 1 - epsilon],
      "ResidualB27OccurrenceCount" ->
        hypergeometricCountsByProjector[projector],
      "IndividualGammaSeriesRatioRegressionPassed" -> True,
      "XiS23MapAppliedAfterMasterExpansion" -> True,
      "MasterAndCase1MapCommutationVerified" -> True,
      "AdditionalMultiplicativeWeight" -> 1,
      "ScaleBookkeeping" -> scaleBookkeeping,
      "ChargeBookkeeping" -> chargeBookkeeping,
      "SymmetryBookkeeping" -> symmetryBookkeeping,
      "VirtualContributionAtThisOrder" -> virtualBookkeeping,
      "ExpandedLeafCount" -> summary["ExpandedLeafCount"],
      "ExpandedByteCount" -> summary["ExpandedByteCount"],
      "Expression" -> expandedXiS23
    |>;
    reloaded = atomicPutAssociation[
      payload,
      cachePaths[projector],
      cacheStageVersion
    ];
    assert[
      cacheMetadataValidQ[reloaded, projector] &&
        reloaded["Expression"] === expandedXiS23 &&
        validateExpandedKernel[reloaded["Expression"], projector],
      projector <> " cache failed exact atomic write/reload validation."
    ];
    summary["CurrentCacheReloadValidated"] = True;
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

baseChecks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS07SourceAndResultHashesValidated" -> True,
  "AcceptedS08SourceResultAndBothCacheHashesValidated" -> True,
  "AllThirtySixS08ChecksValidated" -> True,
  "S08CachePayloadsExactlyMatchPhysicalPostHalfInputs" -> True,
  "OrderedPgPPPInputOnly" -> True,
  "ExactTwentyOneMasterClassInventoryValidated" -> True,
  "ExactSixtyEightAndSeventyThreeOccurrencesValidated" -> True,
  "ExactFiftyNineDistinctMasterInstancesValidated" -> True,
  "AllPhysicalAppendixFFormulasImplemented" -> True,
  "ElevenExactB19DerivativeRecurrencesPassed" -> True,
  "F8ExactB19MomentReductionPassed" -> True,
  "B18ZeroJExpandedThroughEpsilonSquared" -> True,
  "OnlyB27ResidualHypergeometricSignatureAndThreePerProjectorPresent" ->
    True,
  "B27ExpandedThroughEpsilonSquared" -> True,
  "IndividualGammaSeriesReconstructBothRatiosThroughEpsilonSquared" ->
    True,
  "AllBetaGammaAndCase2MasterHeadsRemoved" -> True,
  "AppendixFSubstitutionCommutesWithExactXiS23Map" -> True,
  "B18B27SubstitutionCommutesWithExactXiS23Map" -> True,
  "BothExpandedProjectorsCompletedSerially" -> True,
  "AssociationValueMappingShapeAndValuesVerified" -> True,
  "AdditionalMultiplicativeWeightIsExactlyOne" -> True,
  "IdenticalSpectatorHalfNotReapplied" -> True,
  "SingleInheritedScaleMuPowerPreserved" -> True,
  "NoExtraMSBarSEpsilonIntroduced" -> True,
  "ChargeStrippedChannel5AConventionPreserved" -> True,
  "PhysicalFlavorChargeWeightStillDeferred" -> True,
  "NoVirtualBranchIntroduced" -> True,
  "FormalBoundedEndpointIdentityValidatedThroughEpsilonSquared" -> True,
  "EndpointValuesExplicitlyUnresolved" -> True,
  "Eq46FactorizationNotApplied" -> True,
  "FiniteLimitFHatAndBigTMDComparisonNotClaimed" -> True
|>;

Print["S09_STAGE: processing expanded projectors serially"];
projectorSummaries = <||>;
projectorSummaries["Pg"] = processProjector[physicalAngular["Pg"], "Pg"];
KeyDropFrom[physicalAngular, "Pg"];
ClearSystemCache[];
projectorSummaries["PPP"] = processProjector[physicalAngular["PPP"], "PPP"];
KeyDropFrom[physicalAngular, "PPP"];
ClearSystemCache[];

assert[
  Keys[projectorSummaries] === projectorOrder &&
    AllTrue[
      Values[projectorSummaries],
      #["ExpandedLeafCount"] > 0 &&
        #["ExpandedByteCount"] > 0 &&
        #["CurrentExpandedExpressionValidated"] === True &&
        If[
          preflightOnly,
          #["CurrentCacheReloadValidated"] ===
            "Not applicable in no-write preflight",
          #["CurrentCacheReloadValidated"] === True
        ] &
    ],
  "At least one serial projector expansion summary is incomplete."
];
assert[
  And @@ (TrueQ /@ Values[baseChecks]),
  "At least one S09 base validation check is not True."
];

If[
  preflightOnly,
  assert[
    Sort@FileNames["s09_*", scriptDirectory] === preflightArtifactSnapshot,
    "The no-write S09 preflight changed the S09 artifact inventory."
  ];
  Print["S09_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S09_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[baseChecks]];
  Print[
    "S09_DYNAMIC_PREFLIGHT_SUMMARIES=",
    InputForm[projectorSummaries]
  ];
  Quit[0]
];

Print["S09_STAGE: validating finalized source-bound projector caches"];
Do[
  finalizedCache = Check[Get[cachePaths[projector]], $Failed];
  assert[
    cacheMetadataValidQ[finalizedCache, projector] &&
      validateExpandedKernel[finalizedCache["Expression"], projector] &&
      finalizedCache["ExpandedLeafCount"] ===
        projectorSummaries[projector]["ExpandedLeafCount"] &&
      finalizedCache["ExpandedByteCount"] ===
        projectorSummaries[projector]["ExpandedByteCount"],
    "Finalized " <> projector <> " cache failed independent reload validation."
  ];
  Clear[finalizedCache];
  ClearSystemCache[],
  {projector, projectorOrder}
];

cacheHashes = mapAssociationValues[fileSHA256, cachePaths];
assert[
  Keys[cacheHashes] === projectorOrder &&
    AllTrue[
      Values[cacheHashes],
      StringLength[#] === 64 &&
        StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    And @@ KeyValueMap[
      Function[{projector, path},
        cacheHashes[projector] === fileSHA256[path]
      ],
      cachePaths
    ],
  "The finalized cache-hash Association has wrong shape or disk values."
];

checks = Join[
  baseChecks,
  <|
    "AtomicProjectorCachesReloadedAndValidated" -> True,
    "ActualDiskCacheHashesMappedByAssociationValues" -> True,
    "CompactResultDoesNotDuplicateExpandedKernels" -> True
  |>
];
assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one final S09 validation check is not True."
];

s09Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "H_{q qbar; q q} Appendix-F-expanded real Pg/PPP kernels with formal endpoint handoff",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" ->
      "Appendix B Eqs. (B18),(B19),(B21)-(B31); Appendix F Eqs. (F1)-(F29)"
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
    "InputKey" ->
      "ThreeBodyAngularIntegrated/Hqqbar;q_q/{Pg,PPP}; physical post-1/2!"
  |>,
  "AppendixFExpansion" -> <|
    "ExactPairsByProjector" -> expectedPairsByProjector,
    "ExactAllPairs" -> expectedAllPairs,
    "MasterOccurrencesByProjector" -> masterOccurrenceCounts,
    "DistinctMasterInstanceCount" -> 59,
    "ExpansionOrders" -> <|
      "NonzeroJExceptF28F29" -> "through epsilon^1",
      "F28F29" -> "through epsilon^0",
      "B18ZeroJ" -> "through epsilon^2",
      "B27" -> "through epsilon^2"
    |>,
    "ResidualB27SignaturesByProjector" ->
      hypergeometricSignaturesByProjector,
    "ResidualB27OccurrenceCountsByProjector" ->
      hypergeometricCountsByProjector,
    "B18BetaSignatures" -> betaSignatures,
    "B18GammaObjectsBeforeExpansion" -> gammaObjects,
    "IndividualGammaSeriesRatioRegressionResiduals" ->
      gammaSeriesRatioRegression,
    "RecurrenceDefinition" -> HoldComplete[
      D[S09B19Integral[j, l, d, c, epsilon], d] ==
        -j S09B19Integral[j + 1, l, d, c, epsilon]
    ],
    "RecurrenceResiduals" -> appendixFRecurrenceResiduals,
    "AllRecurrenceResidualsExactZero" -> True,
    "F8B19MomentResiduals" -> b19F8Residuals,
    "AllF8B19MomentResidualsExactZero" -> True,
    "NoPowerExpandOrNumericalBranchSelection" -> True,
    "ProjectorSummaries" -> projectorSummaries
  |>,
  "ExpandedKernelCaches" -> <|
    "StageVersion" -> cacheStageVersion,
    "Paths" -> cachePaths,
    "SHA256" -> cacheHashes,
    "ExpressionField" -> "Expression",
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S08ResultSHA256" -> expectedS08ResultHash,
    "AtomicSourceBoundAndDiskHashValidated" -> True
  |>,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS09" -> 1,
    "Scale" -> scaleBookkeeping,
    "Charge" -> chargeBookkeeping,
    "Symmetry" -> symmetryBookkeeping,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PhysicalFlavorChargeWeightAppliedAtS09" -> False,
    "SeparateMSBarSEpsilonAppliedAtS09" -> False,
    "IdenticalSpectatorFactorReappliedAtS09" -> False
  |>,
  "EndpointExpansion" -> <|
    "Status" ->
      "Formal bounded distribution only; endpoint values and stronger singularities unresolved",
    "Interval" -> {s23, 0, s23UpperB},
    "UpperLimit" -> s23UpperB,
    "ExpansionThrough" -> "epsilon^2 with O(epsilon^3) remainder",
    "RegularFunctionDefinition" -> regularFunctionDefinition,
    "ExpandedKernelReferenceMeaning" ->
      "For each projector, the exact Expression field of its hash-pinned S09 cache",
    "PlusDistributionAction" -> plusDistributionAction,
    "FormalDistributionByProjector" -> formalEndpointDistributions,
    "QuadraticTestFunctionResidualThroughEpsilonSquared" ->
      endpointIdentityPolynomialResidual,
    "EndpointValuesResolved" -> False,
    "StrongerSingularitiesResolved" -> False,
    "DownstreamResolutionRequired" -> True
  |>,
  "Checks" -> checks,
  "MemoryStrategy" ->
    "Pg and PPP expanded serially; each exact kernel is atomically cached and released before the next projector; no parallel duplicate of a large expression",
  "NotPerformedAtThisStage" -> {
    "numerical or symbolic substitution for unresolved endpoint values",
    "structural resolution of stronger s23 poles",
    "Eq. (46) initial-state PDF and final-state FF subtraction",
    "resolved Laurent pole-cancellation test",
    "epsilon -> 0 finite hard-part limit",
    "Eq. (9) Pg/PPP inversion or F-hat extraction",
    "BigTMD comparison",
    "physical Sum_q e_q^2 f_q D_qbar assembly"
  },
  "DownstreamInstruction" ->
    "A separately authorized endpoint stage must load the exact hash-pinned cache expressions, resolve all s23 singularity classes termwise, and must not reapply the S08 1/2!, physical charge weight, or dimensional scale."
|>;

Print["S09_STAGE: atomically writing the compact Hqqbar S09 result"];
reloadedResult = atomicPutAssociation[s09Result, resultPath, stageVersion];
assert[
  reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["InputProvenance"]["S08ResultSHA256"] ===
      expectedS08ResultHash &&
    reloadedResult["ExpandedKernelCaches"]["Paths"] === cachePaths &&
    reloadedResult["ExpandedKernelCaches"]["SHA256"] === cacheHashes &&
    reloadedResult["EndpointExpansion"]["EndpointValuesResolved"] ===
      False &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "The final compact S09 result failed exact reload validation."
];
assert[
  And @@ KeyValueMap[
    Function[{projector, path},
      reloadedResult["ExpandedKernelCaches"]["SHA256"][projector] ===
        fileSHA256[path]
    ],
    cachePaths
  ],
  "The final S09 result cache hashes do not match the real disk files."
];
assert[
  FileNames["s09_result.tmp.*", scriptDirectory] === {} &&
    FileNames["s09_cache_hqqbar*.tmp.*", scriptDirectory] === {},
  "An S09 temporary file remains after finalization."
];

resultHash = fileSHA256[resultPath];
Print["S09_SUCCESS"];
Print["S09_PROGRAM_SHA256=" <> programHash];
Print["S09_RESULT_PATH=" <> resultPath];
Print["S09_RESULT_SHA256=" <> resultHash];
Print["S09_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S09_CACHE_SHA256=", InputForm[cacheHashes]];
Print["S09_CHECKS=", InputForm[checks]];

Quit[0];

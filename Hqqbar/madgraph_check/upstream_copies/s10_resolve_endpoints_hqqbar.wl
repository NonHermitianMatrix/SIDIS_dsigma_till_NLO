(* ::Package:: *)

(*
  Hqqbar stage S10: combined endpoint-cache completion and symbolic
  delta/plus-distribution action.

  Physics authority: the paper in scripts/.  The corrected Hqq S9.5/S10
  code supplies the factorwise and physical-branch algorithms only.  This
  channel has one physical, charge-stripped real contribution and no LO or
  virtual branch at O(alpha_s^2).  Eq. (46) factorization is downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, mapAssociationValues,
  atomicPutAssociation, hasExpectedScaleQ, invalidEndpointQ,
  vanishingEndpointQ,
  exceptionalPowerTermIndices, directSingularLogTermIndices,
  exactPhysicalZeroQ, physicalBranchLogInventory,
  coupledEndpointGroupFinite, repairCoupledEndpointGroups,
  splitEndpointProjection, endpointFactorwiseLaurent,
  endpointTermLaurent, structuralAlpha2EndpointData,
  cacheMetadataValidQ, loadExpansion, processProjection,
  S09EndpointValue, S09PlusDistribution, S09RegularEndpointFunction,
  S09ExpandedKernelReference, S10ConvolutionTest,
  S10EndpointCA, S10EndpointCF, S10EndpointFCGV, S10EndpointSMP
];

activeTemporaryPath = "";

fatal[message_String] := (
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S10_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := IntegerString[FileHash[path, "SHA256"], 16, 64];

mapAssociationValues[function_, association_Association] :=
  Map[function, association];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String,
    allowReplace_?BooleanQ
  ] := Module[{writeResult, loaded, renameResult},
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
    AssociationQ[loaded] && loaded["Stage"] === expectedStage,
    "Atomic temporary reload failed for " <> finalPath
  ];
  renameResult = Check[
    RenameFile[
      activeTemporaryPath,
      finalPath,
      OverwriteTarget -> allowReplace
    ],
    $Failed
  ];
  assert[renameResult =!= $Failed,
    "Atomic rename failed for " <> finalPath];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "Finalized atomic file is missing or empty: " <> finalPath
  ];
  loaded
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
s09SourcePath =
  FileNameJoin[{scriptDirectory, "s09_expand_endpoints_hqqbar.wl"}];
s09ResultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
s09CachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s09_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s09_cache_hqqbar_ppp"}]
|>;
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
endpointCachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_hqqbar_ppp"}]
|>;

stageVersion = "HqqbarS10-v1";
cacheStageVersion = "HqqbarS10Cache-v1";
resultSchemaVersion = 1;
coupledEndpointRepairVersion = 1;
projectors = {"Pg", "PPP"};
preflightOnly =
  Quiet@Check[Environment["HQQBAR_S10_PREFLIGHT_ONLY"], ""] === "1";
expectedRemainderTermCounts = <|"Pg" -> 76, "PPP" -> 78|>;
expectedAlpha2TermIndices = <|"Pg" -> {8}, "PPP" -> {6}|>;
coupledEndpointGroups = <|
  "Pg" -> {{12, 22, 57, 75}, {13, 23, 39, 74}, {40, 73}, {61, 76}},
  "PPP" -> {{12, 35, 48, 77}, {13, 32, 46, 70}, {47, 78}, {64, 73}}
|>;
expectedBranchZeroTerms = <|
  "Pg" -> <|
    "1" -> {12, 13, 22, 23, 39, 57, 74, 75},
    "-1" -> {40, 61, 73, 76}
  |>,
  "PPP" -> <|
    "1" -> {12, 13, 32, 35, 46, 48, 70, 77},
    "-1" -> {47, 64, 73, 78}
  |>
|>;
expectedBranchUnresolvedTerms = <|
  "Pg" -> <|"1" -> {12, 13, 22, 23}, "-1" -> {}|>,
  "PPP" -> <|"1" -> {12, 13, 32, 35}, "-1" -> {}|>
|>;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS09SourceHash =
  "71c4f10cc35cf767f5ae01a895e78d1beee751100f71b83524cd95e796561280";
expectedS09ResultHash =
  "2b50259061ec86cd735b1c04b0a73712d7cae1ff7176d6d97776a9746a1d7a15";
expectedS09CacheHashes = <|
  "Pg" ->
    "1f34249af61f94bd91d81cb0315f51480fc9256e03c7558c441e9f7a7f8415b7",
  "PPP" ->
    "0e208d193319eb6f34b18825fd2805b18a2bf9cddbdeb54e95e27486a7552324"
|>;
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
expectedExpandedLeafCounts = <|"Pg" -> 2450525, "PPP" -> 1855694|>;
expectedExpandedByteCounts = <|"Pg" -> 69980312, "PPP" -> 52825896|>;

programHash = fileSHA256[programPath];
preflightArtifactSnapshot = Sort@FileNames["s10_*", scriptDirectory];
staleTemporaryPaths = Join[
  FileNames["s10_result.tmp.*", scriptDirectory],
  FileNames["s10_cache_hqqbar_*.tmp.*", scriptDirectory]
];
assert[staleTemporaryPaths === {},
  "A stale S10 temporary artifact must be resolved before execution."];
assert[
  mapAssociationValues[StringLength, <|"Pg" -> "pg", "PPP" -> "ppp"|>] ===
    <|"Pg" -> 2, "PPP" -> 3|>,
  "Association value mapping failed its exact key/shape/value regression."
];

Print["S10_STAGE: validating paper and accepted Hqqbar S09 handoff"];
assert[fileSHA256[paperPath] === expectedPaperHash,
  "The authoritative paper hash changed."];
assert[fileSHA256[s09SourcePath] === expectedS09SourceHash,
  "The accepted S09 source hash changed."];
assert[fileSHA256[s09ResultPath] === expectedS09ResultHash,
  "The accepted S09 result hash changed."];
assert[mapAssociationValues[fileSHA256, s09CachePaths] ===
    expectedS09CacheHashes,
  "An accepted S09 projector-cache hash changed."];

s09 = Check[Get[s09ResultPath], $Failed];
assert[AssociationQ[s09], "s09_result is not an Association."];
assert[
  s09["Status"] === "Complete" &&
    s09["Stage"] === "HqqbarS09-v1" &&
    s09["ResultSchemaVersion"] === 1 &&
    s09["Channel"] === "Hqqbar only" &&
    s09["ProgramSHA256"] === expectedS09SourceHash &&
    s09["PaperReference"]["SHA256"] === expectedPaperHash,
  "s09_result failed status, schema, channel, program, or paper validation."
];
assert[
  Length[s09["Checks"]] === 35 &&
    And @@ (TrueQ /@ Values[s09["Checks"]]),
  "The accepted S09 result does not contain exactly 35 true checks."
];
assert[
  s09["InputProvenance"]["S08SourceSHA256"] === expectedS08SourceHash &&
    s09["InputProvenance"]["S08ResultSHA256"] === expectedS08ResultHash &&
    s09["ExpandedKernelCaches"]["Paths"] === s09CachePaths &&
    s09["ExpandedKernelCaches"]["SHA256"] === expectedS09CacheHashes &&
    s09["ExpandedKernelCaches"]["ProgramSHA256"] ===
      expectedS09SourceHash,
  "The accepted S09 provenance/cache handoff is stale."
];

scaleBookkeeping = s09["Bookkeeping"]["Scale"];
chargeBookkeeping = s09["Bookkeeping"]["Charge"];
symmetryBookkeeping = s09["Bookkeeping"]["Symmetry"];
virtualBookkeeping = s09["Bookkeeping"]["VirtualContributionAtThisOrder"];
assert[
  s09["Bookkeeping"]["AdditionalMultiplicativeWeightAtS09"] === 1 &&
    s09["Bookkeeping"]["PhysicalFlavorChargeWeightAppliedAtS09"] === False &&
    s09["Bookkeeping"]["SeparateMSBarSEpsilonAppliedAtS09"] === False &&
    s09["Bookkeeping"]["IdenticalSpectatorFactorReappliedAtS09"] === False &&
    scaleBookkeeping["AbsoluteFactor"] === FeynCalc`ScaleMu^(4 epsilon) &&
    scaleBookkeeping["SeparateMSBarSEpsilonApplied"] === False &&
    chargeBookkeeping["TensorIsChargeStripped"] === True &&
    chargeBookkeeping["BigTMDChannel"] === 5 &&
    chargeBookkeeping["BigTMDChargeCase"] === "A only" &&
    symmetryBookkeeping["IdenticalSpectatorFactor"] === 1/2 &&
    symmetryBookkeeping["ApplicationCountThroughS08"] === 1 &&
    symmetryBookkeeping["DownstreamReapplicationForbidden"] === True &&
    virtualBookkeeping === <|
      "Applicable" -> False,
      "Interference" -> 0,
      "SourceDisposition" -> "NotApplicableAtThisOrder"
    |>,
  "The accepted one-time scale/charge/symmetry/virtual ledger changed."
];

s23UpperB = s09["EndpointExpansion"]["UpperLimit"];
formalEndpointDistributions =
  s09["EndpointExpansion"]["FormalDistributionByProjector"];
endpointPlaceholderCount =
  Count[Values[formalEndpointDistributions], _S09EndpointValue, Infinity];
assert[
  s09["EndpointExpansion"]["EndpointValuesResolved"] === False &&
    s09["EndpointExpansion"]["StrongerSingularitiesResolved"] === False &&
    s09["EndpointExpansion"]["DownstreamResolutionRequired"] === True &&
    Keys[formalEndpointDistributions] === projectors &&
    endpointPlaceholderCount === 2 &&
    Total[Count[#, _S09PlusDistribution, Infinity] & /@
      Values[formalEndpointDistributions]] === 6 &&
    ! MissingQ[s23UpperB],
  "The accepted S09 formal endpoint handoff is incomplete."
];
additionalMultiplicativeWeight = 1;
Clear[s09, formalEndpointDistributions];
ClearSystemCache[];
Print["S10_CHECKPOINT: accepted S09 metadata validated and released"];

hasExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /. HoldPattern[
      FeynCalc`ScaleMu^(4 epsilon)
    ] :> 1;
  ! FreeQ[expression, FeynCalc`ScaleMu^(4 epsilon)] &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | $Aborted | Indeterminate | ComplexInfinity |
    DirectedInfinity | _Limit | Log[0] | Power[0, _?Negative] | _Real
];

vanishingEndpointQ[expression_] := Module[{value, reduced},
  value = Quiet@Check[expression /. s23 -> 0, $Failed];
  If[TrueQ[value === 0], Return[True]];
  If[invalidEndpointQ[value] || ! FreeQ[value, s23], Return[False]];
  reduced = Quiet@Check[
    TimeConstrained[Cancel[Together[value]], 60, $Failed],
    $Failed
  ];
  TrueQ[reduced === 0]
];

exceptionalPowerTermIndices[terms_List] := Flatten@MapIndexed[
  Function[{term, position},
    If[
      Cases[
        term,
        Power[base_, exponent_] /;
          ! FreeQ[exponent, epsilon] && vanishingEndpointQ[base],
        Infinity
      ] === {},
      Nothing,
      First[position]
    ]
  ],
  terms
];

directSingularLogTermIndices[terms_List] := Flatten@MapIndexed[
  Function[{term, position},
    If[
      AnyTrue[
        Cases[term, Log[argument_] :> argument, Infinity],
        Function[argument,
          Module[{value = Quiet@Check[argument /. s23 -> 0, $Failed]},
            TrueQ[value === 0] || invalidEndpointQ[value]
          ]
        ]
      ],
      First[position],
      Nothing
    ]
  ],
  terms
];

exactPhysicalZeroQ[expression_, assumptions_] := Module[
  {combined, simplified},
  combined = Quiet@Check[
    TimeConstrained[Together[expression], 300, $Failed],
    $Failed
  ];
  If[combined === $Failed, Return[False]];
  If[TrueQ[combined === 0], Return[True]];
  simplified = Quiet@Check[
    TimeConstrained[
      FullSimplify[combined, Assumptions -> assumptions],
      300,
      $Failed
    ],
    $Failed
  ];
  TrueQ[simplified === 0]
];

(*
  A direct s23->0 scan misses Log arguments hidden by Sqrt[delta^2].
  Resolve both physical roots after

    xi=xB(1+a), PHT2=rT Q2 a zH(1-zH),
    delta=a zH-rT(1-zH).

  The returned source indices are a source-bound structural certificate.  A
  slow nonzero argument may remain unevaluated here only when all its source
  terms already belong to a group whose full finite coefficient is proved
  below; the coupled proof itself may not retain an invalid object.
*)
physicalBranchLogInventory[
    terms_List, projector_String
  ] := Module[
  {
    aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    expectedRootRadicand, physicalSubstitution, allArguments,
    rootSign, rootRule, branchValue, branchValues, zeroPositions,
    failedPositions, sourceIndicesForPositions, audit = <||>
  },
  aPhysical = S10APhysical;
  rTPhysical = S10RTPhysical;
  denominatorPhysical = rTPhysical + zH - rTPhysical zH;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  allArguments = DeleteDuplicates@Cases[
    terms,
    Log[argument_] :> argument,
    Infinity
  ];
  sourceIndicesForPositions[positions_List] :=
    Sort@DeleteDuplicates@Flatten@Map[
      Function[argumentPosition,
        Flatten@MapIndexed[
          Function[{term, termPosition},
            If[
              MemberQ[
                DeleteDuplicates@Cases[
                  term, Log[argument_] :> argument, Infinity
                ],
                allArguments[[argumentPosition]]
              ],
              First[termPosition],
              Nothing
            ]
          ],
          terms
        ]
      ],
      positions
    ];
  Do[
    rootRule = HoldPattern[
      Power[
        rootArgument_,
        rootPower_Rational?((Denominator[#] === 2) &)
      ]
    ] /; TrueQ[
      Quiet@Check[
        Cancel[Together[rootArgument - expectedRootRadicand]],
        $Failed
      ] === 0
    ] :> (rootSign Q2 deltaPhysical/denominatorPhysical)^(2 rootPower);
    branchValues = Map[
      Function[argument,
        branchValue = Quiet@Check[
          TimeConstrained[
            FixedPoint[
              Factor[Together[# /. rootRule]] &,
              (argument /. physicalSubstitution) /. s23 -> 0,
              3
            ],
            60,
            $Failed
          ],
          $Failed
        ];
        branchValue
      ],
      allArguments
    ];
    zeroPositions = Flatten@Position[
      branchValues,
      value_ /; TrueQ[value === 0],
      {1},
      Heads -> False
    ];
    failedPositions = Flatten@Position[
      branchValues,
      value_ /; SameQ[value, $Failed] || invalidEndpointQ[value],
      {1},
      Heads -> False
    ];
    audit[ToString[rootSign]] = <|
      "ZeroArgumentPositions" -> zeroPositions,
      "ZeroSourceTermIndices" -> sourceIndicesForPositions[zeroPositions],
      "UnresolvedArgumentPositions" -> failedPositions,
      "UnresolvedSourceTermIndices" ->
        sourceIndicesForPositions[failedPositions]
    |>;,
    {rootSign, {1, -1}}
  ];
  audit
];

coupledEndpointGroupFinite[
    sourceTerms_List, finiteTerms_List, sourceIndices_List,
    label_String
  ] := Module[
  {
    aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    expectedRootRadicand, physicalSubstitution, inverseSubstitution,
    originalDelta, endpointLog, heldLog, heldPolyLog, qcdRules,
    branchResults = <||>, rootSign, positiveRoot, rootRule,
    branchAssumptions, canonical, transformTerm, branchTerms,
    maximumDegree, coefficient, constant, groupResult, groupPosition
  },
  assert[
    Length[sourceTerms] === Length[finiteTerms] ===
      Length[sourceIndices],
    label <> " coupled endpoint group has inconsistent term lists."
  ];
  aPhysical = S10APhysical;
  rTPhysical = S10RTPhysical;
  denominatorPhysical = rTPhysical + zH - rTPhysical zH;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  inverseSubstitution = {
    aPhysical -> xi/xB - 1,
    rTPhysical ->
      PHT2/(Q2 (xi/xB - 1) zH (1 - zH))
  };
  originalDelta = Factor[Together[deltaPhysical /. inverseSubstitution]];
  qcdRules = {
    FeynCalc`TF -> 1/2,
    FeynCalc`CF -> (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA)
  };

  Do[
    positiveRoot = rootSign Q2 deltaPhysical/denominatorPhysical;
    rootRule = HoldPattern[
      Power[
        rootArgument_,
        rootPower_Rational?((Denominator[#] === 2) &)
      ]
    ] /; TrueQ[
      Quiet@Check[
        Cancel[Together[rootArgument - expectedRootRadicand]],
        $Failed
      ] === 0
    ] :> positiveRoot^(2 rootPower);
    canonical[value_] := Module[{answer},
      answer = Quiet@Check[
        TimeConstrained[
          FixedPoint[Factor[Together[# /. rootRule]] &, value, 3],
          60,
          $Failed
        ],
        $Failed
      ];
      If[answer === $Failed, value /. rootRule, answer]
    ];
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && rootSign deltaPhysical > 0;

    transformTerm[sourceTerm_, finiteTerm_, sourceIndex_] := Module[
      {
        held, transformed, rootRadicands, sourceLogArguments,
        zeroSourceLogArguments, slopes, slope, zeroHeldLogCount = 0,
        argument, result
      },
      held = finiteTerm /. Log[value_] :> heldLog[value];
      held = held /. PolyLog[order_, value_] :>
        heldPolyLog[order, value];
      transformed = held /. physicalSubstitution;
      rootRadicands = DeleteDuplicates@Cases[
        transformed,
        Power[
          radicand_,
          power_Rational?((Denominator[#] === 2) &)
        ] :> radicand,
        Infinity
      ];
      assert[
        And @@ (
          TrueQ[
            Quiet@Check[
              Cancel[Together[# - expectedRootRadicand]],
              $Failed
            ] === 0
          ] & /@ rootRadicands
        ),
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected physical endpoint square root."
      ];
      transformed = transformed /. rootRule;

      sourceLogArguments = DeleteDuplicates@Cases[
        sourceTerm,
        Log[value_] :> value,
        Infinity
      ];
      zeroSourceLogArguments = Select[
        sourceLogArguments,
        TrueQ[
          canonical[(# /. physicalSubstitution) /. s23 -> 0] === 0
        ] &
      ];
      slopes = {};
      slope = Missing["NotNeeded"];

      transformed = transformed /. heldLog[value_] :> Module[{},
        argument = canonical[value];
        If[
          TrueQ[argument === 0],
          zeroHeldLogCount++;
          If[
            slopes === {},
            slopes = Quiet@DeleteDuplicates[
              canonical[
                ((D[#, s23] /. s23 -> 0) /. physicalSubstitution)
              ] & /@ zeroSourceLogArguments
            ];
            assert[
              Length[slopes] === 1 &&
                And @@ (
                  FreeQ[#, s23] && ! invalidEndpointQ[#] &&
                    ! TrueQ[# === 0] & /@ slopes
                ),
              label <> " term " <> ToString[sourceIndex] <>
                " has a nonlinear or invalid vanishing logarithm."
            ];
            slope = First[slopes]
          ];
          assert[
            ! MissingQ[slope] && ! invalidEndpointQ[slope],
            label <> " term " <> ToString[sourceIndex] <>
              " cannot match its endpoint logarithm to a source slope."
          ];
          endpointLog + heldLog[slope],
          heldLog[argument]
        ]
      ];
      transformed = transformed /.
        heldPolyLog[order_, value_] :>
          heldPolyLog[order, canonical[value]];
      assert[
        zeroHeldLogCount <= 2,
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected number of endpoint logarithms."
      ];
      result = transformed /.
        heldLog[value_] :> Log[value] /.
        heldPolyLog[order_, value_] :> PolyLog[order, value];
      assert[
        FreeQ[result, heldLog | heldPolyLog] &&
          ! invalidEndpointQ[result] && FreeQ[result, s23],
        label <> " term " <> ToString[sourceIndex] <>
          " did not produce a valid branch-resolved endpoint value."
      ];
      result
    ];

    branchTerms = MapThread[
      transformTerm,
      {sourceTerms, finiteTerms, sourceIndices}
    ] /. qcdRules;
    maximumDegree = Max[
      0,
      Sequence @@ Replace[
        Exponent[#, endpointLog] & /@ branchTerms,
        -Infinity -> 0,
        {1}
      ]
    ];
    Do[
      coefficient = Total[
        Coefficient[#, endpointLog, groupPosition] & /@ branchTerms
      ];
      assert[
        exactPhysicalZeroQ[coefficient, branchAssumptions],
        label <> " retains endpoint Log[s23]^" <>
          ToString[groupPosition] <> " on root sign " <>
          ToString[rootSign] <> "."
      ];
      Print[
        "S10_COUPLED_LOG_CHECK: label=", label,
        " rootSign=", rootSign,
        " logPower=", groupPosition,
        " status=zero"
      ];,
      {groupPosition, maximumDegree, 1, -1}
    ];
    constant = Total[(# /. endpointLog -> 0) & /@ branchTerms];
    assert[
      FreeQ[constant, endpointLog | s23] && ! invalidEndpointQ[constant],
      label <> " has an invalid grouped endpoint constant on root sign " <>
        ToString[rootSign] <> "."
    ];
    branchResults[ToString[rootSign]] = constant;
    Clear[branchTerms, coefficient, constant];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];

  groupResult = Piecewise[
    {{branchResults["1"] /. inverseSubstitution, originalDelta >= 0}},
    branchResults["-1"] /. inverseSubstitution
  ];
  assert[
    FreeQ[groupResult, endpointLog | heldLog | heldPolyLog | s23] &&
      ! invalidEndpointQ[groupResult],
    label <> " grouped endpoint result is invalid."
  ];
  groupResult
];

repairCoupledEndpointGroups[
    standardTerms_List, standardIndices_List, finite_List,
    groups_List, label_String
  ] := Module[
  {repaired = finite, group, positions, groupedFinite},
  Do[
    positions = Flatten[
      FirstPosition[standardIndices, #, Missing["NotFound"]] & /@ group
    ];
    assert[
      Length[positions] === Length[group] &&
        And @@ (IntegerQ /@ positions),
      label <> " coupled endpoint source indices are missing."
    ];
    Print[
      "S10_COUPLED_LOG_STAGE: label=", label,
      " sourceTerms=", InputForm[group]
    ];
    groupedFinite = coupledEndpointGroupFinite[
      standardTerms[[positions]], repaired[[positions]], group, label
    ];
    repaired[[First[positions]]] = groupedFinite;
    Scan[(repaired[[#]] = 0) &, Rest[positions]];,
    {group, groups}
  ];
  repaired
];

endpointInertRules = {
  FeynCalc`CA -> S10EndpointCA,
  FeynCalc`CF -> S10EndpointCF,
  HoldPattern[FeynCalc`FCGV[arguments___]] :>
    S10EndpointFCGV[arguments],
  HoldPattern[FeynCalc`SMP[arguments___]] :>
    S10EndpointSMP[arguments]
};
endpointActiveRules = {
  S10EndpointCA -> FeynCalc`CA,
  S10EndpointCF -> FeynCalc`CF,
  HoldPattern[S10EndpointFCGV[arguments___]] :>
    FeynCalc`FCGV[arguments],
  HoldPattern[S10EndpointSMP[arguments___]] :>
    FeynCalc`SMP[arguments]
};

(*
  For a remainder term term, S10 needs the Laurent coefficients of
  s23 term at s23=0.  If one multiplicative factor q is singular,

    q = q[-2]/s23^2 + q[-1]/s23 + O(1),

  while the complementary product r is regular, then

    pole   = r(0) q[-2],
    finite = r(0) q[-1] + r'(0) q[-2].

  This is the corrected low-memory Hqq S10 algorithm.
*)
endpointFactorwiseLaurent[
    term_, label_String, index_Integer
  ] := Module[
  {
    inertTerm, factors, factorTermLists, factorEndpointTermValues,
    factorRegularFlags, singularIndices, remainderIndex, remainderTerms,
    regularIndices, regularFactorValues, regularDerivativeTermValues,
    regularFactorDerivatives, regular0, regular1, regularizedTerms,
    minus2Terms, minus1Terms, minus2Coefficient, minus1Coefficient,
    poleCoefficient, finiteCoefficient
  },
  If[Head[term] =!= Times, Return[$Failed]];
  inertTerm = term /. endpointInertRules;
  factors = List @@ inertTerm;
  factorTermLists =
    (If[Head[#] === Plus, List @@ #, {#}] &) /@ factors;
  factorEndpointTermValues = Quiet@Check[
    TimeConstrained[
      ((# /. s23 -> 0 &) /@ # &) /@ factorTermLists,
      120,
      $Failed
    ],
    $Failed
  ];
  If[factorEndpointTermValues === $Failed, Return[$Failed]];
  factorRegularFlags = Map[
    Function[values,
      AllTrue[values, ! invalidEndpointQ[#] && FreeQ[#, s23] &]
    ],
    factorEndpointTermValues
  ];
  singularIndices = Flatten@Position[
    factorRegularFlags, False, {1}, Heads -> False
  ];
  If[Length[singularIndices] === 0,
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> 0,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "factorwise regular"
    |>]
  ];
  If[Length[singularIndices] =!= 1, Return[$Failed]];
  remainderIndex = First[singularIndices];
  remainderTerms = factorTermLists[[remainderIndex]];
  regularIndices = Complement[Range[Length[factors]], {remainderIndex}];
  regularFactorValues = Total /@
    factorEndpointTermValues[[regularIndices]];
  regular0 = Times @@ regularFactorValues;
  If[invalidEndpointQ[regular0] || ! FreeQ[regular0, s23],
    Return[$Failed]
  ];
  regularizedTerms = Quiet@Check[
    TimeConstrained[(Cancel[s23^2 #] &) /@ remainderTerms, 600, $Failed],
    $Failed
  ];
  If[regularizedTerms === $Failed, Return[$Failed]];
  minus2Terms = Quiet[(# /. s23 -> 0) & /@ regularizedTerms];
  If[AnyTrue[minus2Terms, invalidEndpointQ] ||
      ! AllTrue[minus2Terms, FreeQ[#, s23] &],
    Return[$Failed]
  ];
  minus1Terms = Quiet@Check[
    TimeConstrained[
      (D[#, s23] /. s23 -> 0 &) /@ regularizedTerms,
      600,
      $Failed
    ],
    $Failed
  ];
  If[minus1Terms === $Failed || AnyTrue[minus1Terms, invalidEndpointQ] ||
      ! AllTrue[minus1Terms, FreeQ[#, s23] &],
    Return[$Failed]
  ];
  minus2Coefficient = Total[minus2Terms];
  minus1Coefficient = Total[minus1Terms];
  regular1 = 0;
  If[! TrueQ[minus2Coefficient === 0],
    regularDerivativeTermValues = Quiet@Check[
      TimeConstrained[
        Table[
          (D[#, s23] /. s23 -> 0 &) /@
            factorTermLists[[factorIndex]],
          {factorIndex, regularIndices}
        ],
        600,
        $Failed
      ],
      $Failed
    ];
    If[regularDerivativeTermValues === $Failed ||
        AnyTrue[Flatten[regularDerivativeTermValues], invalidEndpointQ] ||
        ! AllTrue[
          Flatten[regularDerivativeTermValues], FreeQ[#, s23] &
        ],
      Return[$Failed]
    ];
    regularFactorDerivatives = Total /@ regularDerivativeTermValues;
    regular1 = Sum[
      regularFactorDerivatives[[factorIndex]] *
        Times @@ Delete[regularFactorValues, factorIndex],
      {factorIndex, Length[regularFactorValues]}
    ];
  ];
  poleCoefficient =
    (regular0 minus2Coefficient) /. endpointActiveRules;
  finiteCoefficient =
    (regular0 minus1Coefficient + regular1 minus2Coefficient) /.
      endpointActiveRules;
  If[invalidEndpointQ[poleCoefficient] ||
      invalidEndpointQ[finiteCoefficient] ||
      ! FreeQ[poleCoefficient, s23] || ! FreeQ[finiteCoefficient, s23],
    Return[$Failed]
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> ! TrueQ[poleCoefficient === 0],
    "Method" -> "factorwise singular"
  |>
];

endpointTermLaurent[
    term_, label_String, index_Integer, total_Integer
  ] := Module[
  {factorwise, direct, cancelled, numerator, denominator, poleOrder,
    poleCoefficient, finiteCoefficient},
  Print["S10_TERM: " <> label <> " endpoint " <>
    ToString[index] <> "/" <> ToString[total]];
  factorwise = endpointFactorwiseLaurent[term, label, index];
  If[AssociationQ[factorwise], Return[factorwise]];
  direct = If[
    LeafCount[term] > 30000,
    $Failed,
    Quiet@Check[
      TimeConstrained[(s23 term) /. s23 -> 0, 60, $Failed],
      $Failed
    ]
  ];
  If[! invalidEndpointQ[direct] && FreeQ[direct, s23],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "direct"
    |>]
  ];
  cancelled = Quiet@Check[
    TimeConstrained[Cancel[s23 term], 600, $Failed],
    $Failed
  ];
  assert[cancelled =!= $Failed,
    label <> " term " <> ToString[index] <>
      " failed or timed out during rational cancellation."];
  direct = Quiet[cancelled /. s23 -> 0];
  If[! invalidEndpointQ[direct] && FreeQ[direct, s23],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "cancelled direct"
    |>]
  ];
  numerator = Numerator[cancelled];
  denominator = Denominator[cancelled];
  poleOrder = Exponent[denominator, s23, Min] -
    Exponent[numerator, s23, Min];
  assert[poleOrder === 1,
    label <> " term " <> ToString[index] <>
      " has endpoint pole order " <> ToString[poleOrder] <>
      " after multiplication by s23."];
  poleCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, -1}], 600, $Failed
    ],
    $Failed
  ];
  finiteCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, 0}], 600, $Failed
    ],
    $Failed
  ];
  assert[
    ! invalidEndpointQ[poleCoefficient] &&
    ! invalidEndpointQ[finiteCoefficient] &&
    FreeQ[poleCoefficient, s23] && FreeQ[finiteCoefficient, s23],
    label <> " term " <> ToString[index] <>
      " has a failed endpoint Laurent coefficient."
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> True,
    "Method" -> "full Laurent fallback"
  |>
];

splitEndpointProjection[expression_, label_String] := Module[
  {factors, singularPositions, remainderIndex, remainder,
    prefactorIndices, prefactor, terms},
  assert[Head[expression] === Times,
    label <> " is not in the expected factored product form."];
  factors = List @@ expression;
  singularPositions = Flatten@Position[
    factors,
    factor_ /; SameQ[factor, s23^(-epsilon)],
    {1},
    Heads -> False
  ];
  assert[Length[singularPositions] === 1,
    label <> " does not contain exactly one s23^(-epsilon) factor."];
  remainderIndex = First@Ordering[LeafCount /@ factors, -1];
  assert[remainderIndex =!= First[singularPositions],
    label <> " selected s23^(-epsilon) as its remainder."];
  remainder = factors[[remainderIndex]];
  assert[Head[remainder] === Plus,
    label <> " has no additive rational remainder."];
  terms = List @@ remainder;
  assert[Length[terms] > 0,
    label <> " has an empty additive endpoint remainder."];
  prefactorIndices = Complement[
    Range[Length[factors]],
    {First[singularPositions], remainderIndex}
  ];
  prefactor = Times @@ factors[[prefactorIndices]];
  <|
    "Prefactor" -> prefactor,
    "Terms" -> terms,
    "RemainderTermCount" -> Length[terms]
  |>
];

(*
  A structurally detected factor base^(-1-epsilon), with base=s23 ratio
  and finite nonzero ratio(0), changes the endpoint exponent from alpha=1
  to alpha=2.  Refactor it without relying on any channel-specific index.
*)
structuralAlpha2EndpointData[
    prefactor_, term_, index_Integer, label_String
  ] := Module[
  {
    powers, nestedBase, nestedExponent, nestedPower, nestedRatio,
    ratioEndpoint, specialRemainder, regularFunction, endpointValue
  },
  powers = DeleteDuplicates@Cases[
    term,
    power : Power[base_, exponent_] /;
      ! FreeQ[exponent, epsilon] && vanishingEndpointQ[base] :>
        {base, exponent, power},
    Infinity
  ];
  assert[Length[powers] === 1,
    label <> " structurally exceptional term " <> ToString[index] <>
      " does not contain exactly one vanishing epsilon-dependent power."];
  {nestedBase, nestedExponent, nestedPower} = First[powers];
  assert[TrueQ[nestedExponent === -1 - epsilon],
    label <> " structurally exceptional term " <> ToString[index] <>
      " has unsupported exponent " <> ToString[InputForm[nestedExponent]] <>
      "; expected -1-epsilon."];
  nestedRatio = Quiet@Check[
    TimeConstrained[Cancel[Together[nestedBase/s23]], 120, $Failed],
    $Failed
  ];
  assert[nestedRatio =!= $Failed,
    label <> " alpha-two nested-ratio reduction failed."];
  ratioEndpoint = Quiet@Check[
    TimeConstrained[
      Cancel[Together[nestedRatio /. s23 -> 0]],
      120,
      $Failed
    ],
    $Failed
  ];
  assert[
    ratioEndpoint =!= $Failed &&
    ! invalidEndpointQ[ratioEndpoint] &&
    FreeQ[ratioEndpoint, s23] &&
    ! TrueQ[ratioEndpoint === 0],
    label <> " alpha-two nested ratio has no finite nonzero endpoint."];
  assert[TrueQ[
      Cancel[Together[ratioEndpoint - zH^2/PHT2]] === 0
    ],
    label <> " alpha-two nested ratio does not match zH^2/PHT2."];
  specialRemainder = term/nestedPower;
  regularFunction = Quiet@Check[
    TimeConstrained[
      Cancel[Together[
        prefactor nestedRatio^(-1 - epsilon) specialRemainder
      ]],
      600,
      $Failed
    ],
    $Failed
  ];
  assert[regularFunction =!= $Failed,
    label <> " alpha-two regular-function construction failed."];
  endpointValue = Quiet@Check[
    TimeConstrained[regularFunction /. s23 -> 0, 600, $Failed],
    $Failed
  ];
  assert[
    ! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    label <> " alpha-two endpoint value is not finite."];
  Print["S10_CHECKPOINT: " <> label <> " term " <> ToString[index] <>
    " structurally refactored as alpha=2"];
  <|
    "SourceTermIndex" -> index,
    "NestedExponent" -> nestedExponent,
    "NestedRatioEndpoint" -> ratioEndpoint,
    "RegularFunction" -> regularFunction,
    "EndpointValue" -> endpointValue
  |>
];

cacheMetadataValidQ[
    cache_, projector_String, termCount_Integer,
    standardIndices_List, alpha2Indices_List,
    branchInventory_Association
  ] :=
  AssociationQ[cache] &&
    MemberQ[{"InProgress", "Complete"},
      Lookup[cache, "Status", Missing["Status"]]] &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "ResultSchemaVersion", Missing["Schema"]] ===
      resultSchemaVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqbar only" &&
    Lookup[cache, "Projector", Missing["Projector"]] === projector &&
    Lookup[cache, "ProgramSHA256", Missing["Program"]] === programHash &&
    Lookup[cache, "PaperSHA256", Missing["Paper"]] === expectedPaperHash &&
    Lookup[cache, "S09SourceSHA256", Missing["S09Source"]] ===
      expectedS09SourceHash &&
    Lookup[cache, "S09ResultSHA256", Missing["S09Result"]] ===
      expectedS09ResultHash &&
    Lookup[cache, "S09ExpansionCachePath", Missing["S09CachePath"]] ===
      s09CachePaths[projector] &&
    Lookup[cache, "S09ExpansionCacheSHA256", Missing["S09Cache"]] ===
      expectedS09CacheHashes[projector] &&
    Lookup[cache, "RemainderTermCount", Missing["TermCount"]] ===
      termCount &&
    Lookup[cache, "StandardTermIndices", Missing["Standard"]] ===
      standardIndices &&
    Lookup[cache, "Alpha2TermIndices", Missing["Alpha2"]] ===
      alpha2Indices &&
    Lookup[cache, "Alpha2NestedRatioEndpoints", Missing["Ratios"]] ===
      ConstantArray[zH^2/PHT2, Length[alpha2Indices]] &&
    Lookup[cache, "DirectSingularLogTermIndices", Missing["DirectLogs"]] ===
      {} &&
    Lookup[cache, "PhysicalBranchLogInventory", Missing["BranchLogs"]] ===
      branchInventory &&
    Lookup[cache, "CoupledLogEndpointGroups", Missing["Groups"]] ===
      coupledEndpointGroups[projector] &&
    Lookup[cache, "CoupledLogEndpointRepairVersion", Missing["RepairVersion"]] ===
      coupledEndpointRepairVersion &&
    BooleanQ[
      Lookup[cache, "CoupledLogEndpointRepairApplied", Missing["RepairApplied"]]
    ] &&
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
    If[
      Lookup[cache, "Status", Missing["Status"]] === "Complete",
      Lookup[cache, "CoupledLogEndpointRepairApplied", False] === True &&
        Lookup[cache, "CompletedStandardTermCount", -1] ===
          Length[standardIndices],
      Lookup[cache, "CoupledLogEndpointRepairApplied", True] === False
    ];

loadExpansion[projector_String] := Module[{payload, expression},
  Print["S10_STAGE: loading accepted S09 expansion cache for " <> projector];
  payload = Check[Get[s09CachePaths[projector]], $Failed];
  assert[
    AssociationQ[payload] &&
      payload["Status"] === "Complete" &&
      payload["Stage"] === "HqqbarS09Cache-v1" &&
      payload["ResultSchemaVersion"] === 1 &&
      payload["Channel"] === "Hqqbar only" &&
      payload["Projector"] === projector &&
      payload["ProgramSHA256"] === expectedS09SourceHash &&
      payload["PaperSHA256"] === expectedPaperHash &&
      payload["S08SourceSHA256"] === expectedS08SourceHash &&
      payload["S08ResultSHA256"] === expectedS08ResultHash &&
      payload["S08CacheSHA256"] === expectedS08CacheHashes[projector] &&
      payload["AdditionalMultiplicativeWeight"] === 1 &&
      payload["ScaleBookkeeping"] === scaleBookkeeping &&
      payload["ChargeBookkeeping"] === chargeBookkeeping &&
      payload["SymmetryBookkeeping"] === symmetryBookkeeping &&
      payload["VirtualContributionAtThisOrder"] === virtualBookkeeping,
    projector <> " S09 cache failed metadata or bookkeeping validation."
  ];
  expression = payload["Expression"];
  assert[
    LeafCount[expression] === expectedExpandedLeafCounts[projector] &&
      ByteCount[expression] === expectedExpandedByteCounts[projector] &&
      expression =!= 0 && expression =!= $Failed &&
      FreeQ[
        expression,
        _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma |
          _FeynCalc`FeynAmpDenominator | _Real | Indeterminate |
          ComplexInfinity | DirectedInfinity | _Inactive
      ] &&
      FreeQ[expression, sHat | t1 | tHat | u1 | zeta | zHat | beta1 | beta2] &&
      hasExpectedScaleQ[expression],
    projector <> " accepted S09 expression failed size, purity, map, or scale validation."
  ];
  Clear[payload];
  expression
];

processProjection[projector_String] := Module[
  {
    label, expression, split, terms, prefactor, termCount,
    exceptionalIndices, directLogIndices, branchInventory, groups,
    groupedIndices, unresolvedIndices, alpha2Data,
    standardIndices, standardTerms, standardTermCount,
    preflightIndices, preflightAnswers, preflightFinite,
    preflightRepaired, preflightPosition, preflightSourceIndex,
    cachePath, cachePayload, makeCachePayload, repairApplied = False,
    poles = {}, finite = {}, flags = {}, methods = {},
    remainingPositions, batchWidth, batchPositions, batchInputs,
    batchAnswers, batchOffset, position, sourceIndex, termAnswer,
    rawPoleResidual, reducedPoleResidual, poleOrders,
    prefactorEndpoint, endpointValue, regularFunction,
    alpha2RegularFunction, alpha2EndpointValue,
    testAtS, testAtZero, logarithmTower, alpha2LogarithmTower, action,
    finalizedCache, finalizedCacheHash
  },
  label = "Hqqbar;q_q " <> projector;
  expression = loadExpansion[projector];
  split = splitEndpointProjection[expression, label];
  terms = split["Terms"];
  prefactor = split["Prefactor"];
  termCount = split["RemainderTermCount"];
  assert[
    termCount === expectedRemainderTermCounts[projector],
    projector <> " S09 remainder-term count changed."
  ];
  Print[
    "S10_STAGE: structural endpoint scan for ", projector,
    " terms=", termCount
  ];
  exceptionalIndices = exceptionalPowerTermIndices[terms];
  assert[
    exceptionalIndices === expectedAlpha2TermIndices[projector],
    projector <> " structural alpha-two term inventory changed."
  ];
  directLogIndices = directSingularLogTermIndices[terms];
  assert[
    directLogIndices === {},
    projector <> " contains a directly singular endpoint logarithm outside the physical-root treatment."
  ];
  branchInventory = physicalBranchLogInventory[terms, projector];
  Print[
    "S10_BRANCH_LOG_INVENTORY_", projector, "=",
    InputForm[branchInventory]
  ];
  assert[
    branchInventory["1"]["ZeroSourceTermIndices"] ===
        expectedBranchZeroTerms[projector]["1"] &&
      branchInventory["-1"]["ZeroSourceTermIndices"] ===
        expectedBranchZeroTerms[projector]["-1"] &&
      branchInventory["1"]["UnresolvedSourceTermIndices"] ===
        expectedBranchUnresolvedTerms[projector]["1"] &&
      branchInventory["-1"]["UnresolvedSourceTermIndices"] ===
        expectedBranchUnresolvedTerms[projector]["-1"],
    projector <> " physical-root logarithm inventory changed."
  ];
  groups = coupledEndpointGroups[projector];
  groupedIndices = Sort@DeleteDuplicates@Flatten[groups];
  unresolvedIndices = Sort@DeleteDuplicates@Flatten[{
    branchInventory["1"]["UnresolvedSourceTermIndices"],
    branchInventory["-1"]["UnresolvedSourceTermIndices"]
  }];
  assert[
    Sort@DeleteDuplicates@Flatten[Values[expectedBranchZeroTerms[projector]]] ===
        groupedIndices &&
      Complement[unresolvedIndices, groupedIndices] === {},
    projector <> " coupled-log groups do not cover the physical-root inventory."
  ];
  alpha2Data = Map[
    structuralAlpha2EndpointData[
      prefactor, terms[[#]], #, label
    ] &,
    exceptionalIndices
  ];
  assert[
    Lookup[alpha2Data, "NestedRatioEndpoint", {}] ===
      ConstantArray[zH^2/PHT2, Length[exceptionalIndices]],
    projector <> " alpha-two nested-ratio gate changed."
  ];
  standardIndices = Complement[Range[termCount], exceptionalIndices];
  standardTerms = terms[[standardIndices]];
  standardTermCount = Length[standardTerms];
  assert[
    standardTermCount + Length[alpha2Data] === termCount &&
      Intersection[groupedIndices, exceptionalIndices] === {},
    projector <> " structural endpoint partition is incomplete."
  ];

  If[
    preflightOnly,
    Print[
      "S10_PREFLIGHT_STAGE: proving coupled endpoint groups for " <>
        projector
    ];
    preflightIndices = groupedIndices;
    preflightAnswers = Map[
      Function[index,
        endpointTermLaurent[terms[[index]], label, index, termCount]
      ],
      preflightIndices
    ];
    assert[
      And @@ (AssociationQ /@ preflightAnswers),
      projector <> " coupled-group preflight term extraction failed."
    ];
    preflightFinite = ConstantArray[0, standardTermCount];
    Do[
      preflightSourceIndex = preflightIndices[[preflightPosition]];
      preflightFinite[[
        First@FirstPosition[standardIndices, preflightSourceIndex]
      ]] = preflightAnswers[[preflightPosition]]["FiniteCoefficient"];,
      {preflightPosition, Length[preflightIndices]}
    ];
    preflightRepaired = repairCoupledEndpointGroups[
      standardTerms,
      standardIndices,
      preflightFinite,
      groups,
      label
    ];
    assert[
      ListQ[preflightRepaired] &&
        Length[preflightRepaired] === standardTermCount &&
        ! invalidEndpointQ[preflightRepaired] &&
        FreeQ[preflightRepaired, s23],
      projector <> " coupled-group preflight did not produce finite endpoints."
    ];
    Return[<|
      "Projector" -> projector,
      "PreflightOnly" -> True,
      "RemainderTermCount" -> termCount,
      "StandardTermIndices" -> standardIndices,
      "Alpha2TermIndices" -> exceptionalIndices,
      "Alpha2NestedRatioEndpoints" ->
        Lookup[alpha2Data, "NestedRatioEndpoint", {}],
      "PhysicalBranchLogInventory" -> branchInventory,
      "CoupledLogEndpointGroups" -> groups,
      "CoupledGroupProofPassed" -> True
    |>]
  ];

  cachePath = endpointCachePaths[projector];
  makeCachePayload[status_String, repaired_?BooleanQ] := <|
    "Status" -> status,
    "Stage" -> cacheStageVersion,
    "ResultSchemaVersion" -> resultSchemaVersion,
    "Channel" -> "Hqqbar only",
    "Projector" -> projector,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperHash,
    "S09SourcePath" -> s09SourcePath,
    "S09SourceSHA256" -> expectedS09SourceHash,
    "S09ResultPath" -> s09ResultPath,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCachePath" -> s09CachePaths[projector],
    "S09ExpansionCacheSHA256" -> expectedS09CacheHashes[projector],
    "RemainderTermCount" -> termCount,
    "StandardTermIndices" -> standardIndices,
    "Alpha2TermIndices" -> exceptionalIndices,
    "Alpha2NestedRatioEndpoints" ->
      Lookup[alpha2Data, "NestedRatioEndpoint", {}],
    "DirectSingularLogTermIndices" -> directLogIndices,
    "PhysicalBranchLogInventory" -> branchInventory,
    "CoupledLogEndpointRepairVersion" -> coupledEndpointRepairVersion,
    "CoupledLogEndpointGroups" -> groups,
    "CoupledLogEndpointRepairApplied" -> repaired,
    "AdditionalMultiplicativeWeight" -> additionalMultiplicativeWeight,
    "ScaleBookkeeping" -> scaleBookkeeping,
    "ChargeBookkeeping" -> chargeBookkeeping,
    "SymmetryBookkeeping" -> symmetryBookkeeping,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PoleCoefficients" -> poles,
    "FiniteCoefficients" -> finite,
    "RequiredPoleSubtraction" -> flags,
    "Methods" -> methods,
    "CompletedStandardTermCount" -> Length[poles]
  |>;

  If[
    FileExistsQ[cachePath],
    Print["S10_STAGE: validating resumable " <> projector <> " cache"];
    cachePayload = Check[Get[cachePath], $Failed];
    assert[
      cacheMetadataValidQ[
        cachePayload,
        projector,
        termCount,
        standardIndices,
        exceptionalIndices,
        branchInventory
      ],
      projector <> " endpoint cache is stale or invalid; it was not deleted."
    ];
    poles = Lookup[cachePayload, "PoleCoefficients", {}];
    finite = Lookup[cachePayload, "FiniteCoefficients", {}];
    flags = Lookup[cachePayload, "RequiredPoleSubtraction", {}];
    methods = Lookup[cachePayload, "Methods", {}];
    repairApplied = TrueQ[
      Lookup[cachePayload, "CoupledLogEndpointRepairApplied", False]
    ];
    assert[
      ListQ[poles] && ListQ[finite] && ListQ[flags] && ListQ[methods] &&
        Length[poles] === Length[finite] === Length[flags] ===
          Length[methods] &&
        Length[poles] <= standardTermCount &&
        If[repairApplied, Length[poles] === standardTermCount, True],
      projector <> " endpoint cache has inconsistent completed lists."
    ];
    Print[
      "S10_STAGE: resuming ", projector, " cache at ",
      Length[poles], "/", standardTermCount,
      " repaired=", repairApplied
    ]
  ];

  remainingPositions = Range[Length[poles] + 1, standardTermCount];
  While[remainingPositions =!= {},
    batchWidth = If[$KernelCount > 0, Min[2, $KernelCount], 1];
    batchPositions = Take[remainingPositions, UpTo[batchWidth]];
    batchInputs = Map[
      Function[currentPosition,
        {
          standardTerms[[currentPosition]],
          label,
          standardIndices[[currentPosition]],
          termCount
        }
      ],
      batchPositions
    ];
    Print[
      "S10_STAGE: ordered endpoint batch ", projector, " positions ",
      First[batchPositions], "-", Last[batchPositions], "/",
      standardTermCount
    ];
    batchAnswers = If[
      $KernelCount > 0,
      Quiet@Check[
        ParallelMap[
          Function[input,
            MemoryConstrained[
              endpointTermLaurent[
                input[[1]], input[[2]], input[[3]], input[[4]]
              ],
              2 1024^3,
              $Failed
            ]
          ],
          batchInputs,
          Method -> "FinestGrained"
        ],
        $Failed
      ],
      endpointTermLaurent[#[[1]], #[[2]], #[[3]], #[[4]]] & /@
        batchInputs
    ];
    If[
      batchAnswers === $Failed || ! ListQ[batchAnswers],
      batchAnswers = ConstantArray[$Failed, Length[batchInputs]]
    ];
    Do[
      If[
        ! AssociationQ[batchAnswers[[batchOffset]]],
        Print[
          "S10_CHECKPOINT: serial fallback for ", projector,
          " source term ", batchInputs[[batchOffset, 3]]
        ];
        batchAnswers[[batchOffset]] = endpointTermLaurent[
          batchInputs[[batchOffset, 1]],
          batchInputs[[batchOffset, 2]],
          batchInputs[[batchOffset, 3]],
          batchInputs[[batchOffset, 4]]
        ]
      ];
      assert[
        AssociationQ[batchAnswers[[batchOffset]]],
        projector <> " endpoint batch returned an invalid term result."
      ];
      termAnswer = batchAnswers[[batchOffset]];
      AppendTo[poles, termAnswer["PoleCoefficient"]];
      AppendTo[finite, termAnswer["FiniteCoefficient"]];
      AppendTo[flags, termAnswer["RequiredPoleSubtraction"]];
      AppendTo[methods, termAnswer["Method"]];,
      {batchOffset, Length[batchAnswers]}
    ];
    repairApplied = False;
    cachePayload = makeCachePayload["InProgress", False];
    cachePayload = atomicPutAssociation[
      cachePayload,
      cachePath,
      cacheStageVersion,
      FileExistsQ[cachePath]
    ];
    Print[
      "S10_CACHE_CHECKPOINT: ", projector, " ", Length[poles], "/",
      standardTermCount, " standard terms"
    ];
    remainingPositions = Drop[remainingPositions, Length[batchPositions]];
  ];
  assert[
    Length[poles] === standardTermCount &&
      Length[finite] === standardTermCount,
    projector <> " endpoint cache does not cover every standard term."
  ];

  If[
    ! repairApplied,
    Print["S10_STAGE: applying coupled-log endpoint repair for " <> projector];
    finite = repairCoupledEndpointGroups[
      standardTerms,
      standardIndices,
      finite,
      groups,
      label
    ];
    repairApplied = True;
    cachePayload = makeCachePayload["Complete", True];
    cachePayload = atomicPutAssociation[
      cachePayload,
      cachePath,
      cacheStageVersion,
      FileExistsQ[cachePath]
    ]
  ];
  finalizedCache = Check[Get[cachePath], $Failed];
  assert[
    cacheMetadataValidQ[
      finalizedCache,
      projector,
      termCount,
      standardIndices,
      exceptionalIndices,
      branchInventory
    ] &&
      finalizedCache["Status"] === "Complete" &&
      finalizedCache["CoupledLogEndpointRepairApplied"] === True &&
      finalizedCache["PoleCoefficients"] === poles &&
      finalizedCache["FiniteCoefficients"] === finite &&
      Length[finite] === standardTermCount,
    projector <> " finalized endpoint cache failed exact reload validation."
  ];
  finalizedCacheHash = fileSHA256[cachePath];
  Clear[finalizedCache, cachePayload];

  Print["S10_STAGE: reducing stronger endpoint pole for " <> projector];
  rawPoleResidual = Total[poles];
  reducedPoleResidual = Quiet@Check[
    TimeConstrained[Cancel[Together[rawPoleResidual]], 900, $Failed],
    $Failed
  ];
  assert[
    reducedPoleResidual =!= $Failed,
    projector <> " stronger endpoint-pole reduction failed or timed out."
  ];
  poleOrders = <|
    "Epsilon0" -> Quiet@Check[
      TimeConstrained[
        Cancel[Together[reducedPoleResidual /. epsilon -> 0]],
        900,
        $Failed
      ],
      $Failed
    ],
    "Epsilon1" -> Quiet@Check[
      TimeConstrained[
        Cancel[Together[
          D[reducedPoleResidual, epsilon] /. epsilon -> 0
        ]],
        900,
        $Failed
      ],
      $Failed
    ]
  |>;
  assert[
    FreeQ[Values[poleOrders], $Failed] &&
      And @@ (TrueQ[# === 0] & /@ Values[poleOrders]),
    projector <> " has a nonzero stronger endpoint pole through the finite-order requirement."
  ];
  Print[
    "S10_CHECKPOINT: ", projector,
    " stronger endpoint pole vanishes through epsilon^1"
  ];

  prefactorEndpoint = Quiet@Check[prefactor /. s23 -> 0, $Failed];
  assert[
    ! invalidEndpointQ[prefactorEndpoint] && FreeQ[prefactorEndpoint, s23],
    projector <> " common prefactor has no finite endpoint."
  ];
  endpointValue = additionalMultiplicativeWeight *
    prefactorEndpoint * Total[finite];
  regularFunction = additionalMultiplicativeWeight * (
    s23 prefactor Total[standardTerms] -
      prefactor reducedPoleResidual/s23
  );
  alpha2RegularFunction = additionalMultiplicativeWeight *
    Total[Lookup[alpha2Data, "RegularFunction", {}]];
  alpha2EndpointValue = additionalMultiplicativeWeight *
    Total[Lookup[alpha2Data, "EndpointValue", {}]];
  assert[
    ! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23] &&
      ! invalidEndpointQ[alpha2EndpointValue] &&
      FreeQ[alpha2EndpointValue, s23],
    projector <> " ordinary or alpha-two endpoint value is invalid."
  ];

  testAtS = S10ConvolutionTest[projector, s23];
  testAtZero = S10ConvolutionTest[projector, 0];
  logarithmTower = 1 - epsilon Log[s23/s23UpperB] +
    epsilon^2 Log[s23/s23UpperB]^2/2;
  alpha2LogarithmTower = 1 - 2 epsilon Log[s23/s23UpperB] +
    2 epsilon^2 Log[s23/s23UpperB]^2;
  action = -s23UpperB^(-epsilon) endpointValue testAtZero/epsilon -
    s23UpperB^(-2 epsilon) alpha2EndpointValue testAtZero/(2 epsilon) +
    Inactive[Integrate][
      s23UpperB^(-epsilon) logarithmTower/s23 *
        (regularFunction testAtS - endpointValue testAtZero) +
      s23UpperB^(-2 epsilon) alpha2LogarithmTower/s23 *
        (alpha2RegularFunction testAtS -
          alpha2EndpointValue testAtZero),
      {s23, 0, s23UpperB}
    ];
  assert[
    FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution |
        _S09RegularEndpointFunction | _S09ExpandedKernelReference |
        DiracDelta[s23]
    ] &&
      ! FreeQ[action, Inactive[Integrate][___]] &&
      ! FreeQ[action, _S10ConvolutionTest] &&
      ! invalidEndpointQ[action] && hasExpectedScaleQ[action],
    projector <> " acted distribution failed placeholder, integral, purity, or scale validation."
  ];
  Print[
    "S10_CHECKPOINT: completed symbolic distribution action for ",
    projector
  ];
  <|
    "Projector" -> projector,
    "PreflightOnly" -> False,
    "RemainderTermCount" -> termCount,
    "StandardTermIndices" -> standardIndices,
    "Alpha2TermIndices" -> exceptionalIndices,
    "Alpha2NestedRatioEndpoints" ->
      Lookup[alpha2Data, "NestedRatioEndpoint", {}],
    "DirectSingularLogTermIndices" -> directLogIndices,
    "PhysicalBranchLogInventory" -> branchInventory,
    "CoupledLogEndpointGroups" -> groups,
    "CoupledLogEndpointRepairVersion" -> coupledEndpointRepairVersion,
    "PoleSubtractionTermCount" -> Count[flags, True],
    "EndpointCache" -> cachePath,
    "EndpointCacheSHA256" -> finalizedCacheHash,
    "ReducedStrongerPoleResidual" -> reducedPoleResidual,
    "StrongerPoleOrders" -> poleOrders,
    "EndpointValue" -> endpointValue,
    "Alpha2EndpointValue" -> alpha2EndpointValue,
    "Action" -> action,
    "MethodCounts" -> Counts[methods]
  |>
];

If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[resultPath],
    "s10_result already exists; validate or explicitly invalidate it before regeneration."
  ]
];

requestedParallelKernels = If[
  preflightOnly,
  0,
  If[Quiet@Check[MemoryAvailable[], 0] >= 10 1024^3, 2, 1]
];
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel";
parallelKernelConfiguration = If[
  requestedParallelKernels > 0 && Length[$ConfiguredKernels] > 0,
  ReplacePart[
    First[$ConfiguredKernels],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernels,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ],
  Missing["NoParallelLaunch"]
];
parallelLaunchResult = Quiet@Check[
  If[
    MissingQ[parallelKernelConfiguration],
    {},
    LaunchKernels[parallelKernelConfiguration]
  ],
  {}
];
parallelKernelCount = $KernelCount;
assert[
  0 <= parallelKernelCount <= 2,
  "The endpoint worker count exceeded the two-worker memory bound."
];
Print[
  "S10_ENDPOINT_PARALLEL_KERNELS=", parallelKernelCount,
  " requested=", requestedParallelKernels
];
If[
  parallelKernelCount > 0,
  DistributeDefinitions[
    invalidEndpointQ,
    endpointInertRules,
    endpointActiveRules,
    endpointFactorwiseLaurent,
    endpointTermLaurent,
    assert,
    fatal
  ]
];

Print["S10_STAGE: resolving Pg endpoint Laurent data and action"];
pgData = processProjection["Pg"];
ClearSystemCache[];
Print["S10_MEMORY_STAGE: Pg complete; processing PPP serially"];
pppData = processProjection["PPP"];

If[
  parallelKernelCount > 0,
  Quiet[CloseKernels[]]
];

If[
  preflightOnly,
  assert[
    TrueQ[pgData["PreflightOnly"]] &&
      TrueQ[pppData["PreflightOnly"]] &&
      TrueQ[pgData["CoupledGroupProofPassed"]] &&
      TrueQ[pppData["CoupledGroupProofPassed"]] &&
      Sort@FileNames["s10_*", scriptDirectory] ===
        preflightArtifactSnapshot,
    "The no-write S10 preflight failed or changed the S10 artifact inventory."
  ];
  Print["S10_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print[
    "S10_DYNAMIC_PREFLIGHT_SUMMARIES=",
    InputForm[<|"Pg" -> pgData, "PPP" -> pppData|>]
  ];
  Quit[0]
];

endpointDataByProjector = <|
  "Pg" -> KeyDrop[pgData, {"Action"}],
  "PPP" -> KeyDrop[pppData, {"Action"}]
|>;
realConvolutionActions = <|
  "Pg" -> pgData["Action"],
  "PPP" -> pppData["Action"]
|>;
Clear[pgData, pppData];
ClearSystemCache[];

endpointCacheHashes = mapAssociationValues[fileSHA256, endpointCachePaths];
assert[
  Keys[endpointCacheHashes] === projectors &&
    AllTrue[
      Values[endpointCacheHashes],
      StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    And @@ KeyValueMap[
      Function[{projector, path},
        endpointCacheHashes[projector] === fileSHA256[path]
      ],
      endpointCachePaths
    ],
  "The finalized endpoint-cache hashes have wrong shape or disk values."
];

s10Checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS09SourceResultAndBothCacheHashesValidated" -> True,
  "AllThirtyFiveS09ChecksValidated" -> True,
  "FeynCalcContextLoadedBeforeArtifactDeserialization" -> True,
  "ExactlyTwoS09EndpointPlaceholdersReceived" ->
    endpointPlaceholderCount === 2,
  "BothProjectorsProcessedSerially" ->
    Keys[endpointDataByProjector] === projectors,
  "ExactSeventySixAndSeventyEightTermInventories" ->
    endpointDataByProjector[[All, "RemainderTermCount"]] ===
      expectedRemainderTermCounts,
  "TwoAlpha2TermsDetectedStructurally" ->
    endpointDataByProjector[[All, "Alpha2TermIndices"]] ===
      expectedAlpha2TermIndices,
  "AllAlpha2NestedRatiosEqualZH2OverPHT2" ->
    AllTrue[
      Flatten@Values[
        endpointDataByProjector[[All, "Alpha2NestedRatioEndpoints"]]
      ],
      TrueQ[Cancel[Together[# - zH^2/PHT2]] === 0] &
    ],
  "PhysicalBranchLogInventoriesValidated" ->
    And @@ Map[
      Function[projector,
        endpointDataByProjector[projector]["PhysicalBranchLogInventory"]["1"]
            ["ZeroSourceTermIndices"] ===
          expectedBranchZeroTerms[projector]["1"] &&
        endpointDataByProjector[projector]["PhysicalBranchLogInventory"]["-1"]
            ["ZeroSourceTermIndices"] ===
          expectedBranchZeroTerms[projector]["-1"]
      ],
      projectors
    ],
  "CoupledEndpointGroupsRepairedOnBothBranches" ->
    endpointDataByProjector[[All, "CoupledLogEndpointGroups"]] ===
      coupledEndpointGroups &&
      And @@ (
        # === coupledEndpointRepairVersion & /@
          Values[
            endpointDataByProjector[[All, "CoupledLogEndpointRepairVersion"]]
          ]
      ),
  "AllOneHundredFiftyFourTermsResolved" ->
    Total[
      (Length[#["StandardTermIndices"]] +
          Length[#["Alpha2TermIndices"]]) & /@
        Values[endpointDataByProjector]
    ] === 154,
  "StrongerEndpointPoleAbsentThroughFiniteRequirement" ->
    AllTrue[
      Flatten[
        Values /@ Values[
          endpointDataByProjector[[All, "StrongerPoleOrders"]]
        ]
      ],
      TrueQ[# === 0] &
    ],
  "EndpointValuesAreS23Independent" ->
    AllTrue[
      Join[
        Values[endpointDataByProjector[[All, "EndpointValue"]]],
        Values[endpointDataByProjector[[All, "Alpha2EndpointValue"]]]
      ],
      FreeQ[#, s23] &
    ],
  "AdditionalMultiplicativeWeightIsExactlyOne" ->
    additionalMultiplicativeWeight === 1,
  "IdenticalSpectatorHalfNotReapplied" -> True,
  "PhysicalFlavorChargeWeightStillDeferred" -> True,
  "NoExtraMSBarSEpsilonIntroduced" -> True,
  "SingleInheritedScaleMuPowerPreserved" ->
    AllTrue[Values[realConvolutionActions], hasExpectedScaleQ],
  "NoVirtualOrLOBranchIntroduced" -> True,
  "DiracDeltaAndAllPlusDistributionsActed" -> True,
  "FinalActionsContainNoDistributionPlaceholders" ->
    AllTrue[
      Values[realConvolutionActions],
      FreeQ[
        #,
        _S09EndpointValue | _S09PlusDistribution |
          _S09RegularEndpointFunction | _S09ExpandedKernelReference |
          DiracDelta[s23]
      ] &
    ],
  "FinalActionsContainEndpointSubtractedIntegrals" ->
    AllTrue[
      Values[realConvolutionActions],
      ! FreeQ[#, Inactive[Integrate][___]] &
    ],
  "CalculationRemainsExactAndSymbolic" ->
    FreeQ[Values[realConvolutionActions], _Real | $Failed | Indeterminate],
  "AtomicSourceBoundEndpointCachesDiskHashValidated" -> True,
  "Eq46FactorizationFiniteFHatAndBigTMDNotClaimed" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[s10Checks]),
  "At least one final S10 validation check is not True."
];

s10Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "H_{q qbar; q q} real alpha-one/alpha-two endpoint resolution and symbolic distribution action",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" -> "Eqs. (40)-(46), with Eq. (46) explicitly deferred"
  |>,
  "InputProvenance" -> <|
    "S09SourcePath" -> s09SourcePath,
    "S09SourceSHA256" -> expectedS09SourceHash,
    "S09ResultPath" -> s09ResultPath,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCachePaths" -> s09CachePaths,
    "S09ExpansionCacheSHA256" -> expectedS09CacheHashes
  |>,
  "CalculationMode" ->
    "fully exact and symbolic; no numerical kinematics, PDFs, FFs, or concrete test function",
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlaceholderCountAfter" -> 0,
    "Method" ->
      "corrected Hqq factorwise endpoint Laurent extraction; source-derived physical-root coupled-log repair; structurally detected alpha-two refactorization with delta coefficient -1/(2 epsilon) and doubled logarithmic tower",
    "EndpointDataByProjector" -> endpointDataByProjector
  |>,
  "DistributionActions" -> <|
    "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
    "TestFunctionAssumption" ->
      "arbitrary symbolic function regular at s23=0 and independent of epsilon",
    "EndpointDeltaConvention" ->
      "the lower-endpoint delta has full weight, matching the paper's bounded endpoint identity",
    "RealByProjector" -> realConvolutionActions,
    "VirtualByProjector" -> <|"Pg" -> 0, "PPP" -> 0|>,
    "RemainingIntegralType" ->
      "ordinary endpoint-subtracted integral on 0<=s23<=B(xi); a concrete PDF/FF test function is intentionally not supplied"
  |>,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS10" -> 1,
    "Scale" -> scaleBookkeeping,
    "Charge" -> chargeBookkeeping,
    "Symmetry" -> symmetryBookkeeping,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PhysicalFlavorChargeWeightAppliedAtS10" -> False,
    "SeparateMSBarSEpsilonAppliedAtS10" -> False,
    "IdenticalSpectatorFactorReappliedAtS10" -> False
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "EndpointCachePaths" -> endpointCachePaths,
    "EndpointCacheSHA256" -> endpointCacheHashes,
    "ProgramSHA256" -> programHash,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCacheSHA256" -> expectedS09CacheHashes,
    "AtomicSourceBoundAndDiskHashValidated" -> True
  |>,
  "ParallelExecution" -> <|
    "RequestedEndpointWorkerCount" -> requestedParallelKernels,
    "AvailableEndpointWorkerCount" -> parallelKernelCount,
    "OrderingAndWriteDiscipline" ->
      "deterministic batches of at most two independent terms; only the parent writes caches; projector processing remains serial"
  |>,
  "MemoryStrategy" ->
    "validate and process Pg then PPP; use at most two 2-GiB-bounded term workers with exact serial fallback; atomically checkpoint each ordered batch",
  "Checks" -> s10Checks,
  "NotPerformedAtThisStage" -> {
    "virtual-loop evaluation or QCD UV renormalization, absent for Hqqbar at this order",
    "paper Eq. (46) initial-state PDF and final-state FF subtraction",
    "claim of remaining collinear-pole cancellation before factorization",
    "epsilon -> 0 finite hard-part limit",
    "paper Eq. (9) Pg/PPP inversion or F-hat extraction",
    "BigTMD comparison",
    "physical Sum_q e_q^2 f_q D_qbar assembly"
  }
|>;

Print["S10_STAGE: atomically writing compact Hqqbar S10 result"];
reloadedResult = atomicPutAssociation[
  s10Result,
  resultPath,
  stageVersion,
  False
];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["InputProvenance"]["S09ResultSHA256"] ===
      expectedS09ResultHash &&
    reloadedResult["CacheProvenance"]["EndpointCacheSHA256"] ===
      endpointCacheHashes &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]) &&
    And @@ KeyValueMap[
      Function[{projector, path},
        reloadedResult["CacheProvenance"]["EndpointCacheSHA256"][projector] ===
          fileSHA256[path]
      ],
      endpointCachePaths
    ],
  "The final S10 result failed exact reload or real-disk cache-hash validation."
];
assert[
  Join[
    FileNames["s10_result.tmp.*", scriptDirectory],
    FileNames["s10_cache_hqqbar_*.tmp.*", scriptDirectory]
  ] === {},
  "A finalized S10 temporary artifact remains."
];

Print["S10_SUCCESS_SYMBOLIC"];
Print["S10_PROGRAM_SHA256=" <> programHash];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_SHA256=" <> fileSHA256[resultPath]];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CACHE_SHA256=", InputForm[endpointCacheHashes]];
Print["S10_CHECKS=", InputForm[s10Checks]];

Quit[0];

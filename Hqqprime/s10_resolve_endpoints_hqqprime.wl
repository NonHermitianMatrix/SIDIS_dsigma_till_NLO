(* ::Package:: *)

(*
  Hqqprime stage S10: resolve the six accepted S09 endpoint classes and act
  the bounded endpoint distributions on arbitrary symbolic test functions.

  Physics authority: Eqs. (29)-(32), the discussion following Eq. (40), and
  Appendix B Eqs. (B22)-(B23) of the paper in scripts/.  This stage preserves
  both projectors and all three charge tensors separately.  Eq. (46)
  factorization, the finite hard part, Eq. (9), flavour assembly, F-hats, and
  external comparison remain downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, workerRequire, closeS10Kernels, fileSHA256,
  expressionSHA256, mapAssociationValues, mapNestedAssociationValues,
  allBranchValues, atomicPutAssociation, hasExpectedScaleQ,
  expandedKernelValidQ, validateS09Cache, invalidEndpointQ,
  vanishingEndpointQ, splitEndpointProjection,
  exceptionalPowerTermIndices, directSingularLogTermIndices,
  colorCanonicalize, exactPhysicalZeroQ, physicalBranchLogInventory,
  deriveCoupledGroups, coupledEndpointGroupFinite,
  repairCoupledEndpointGroups, endpointFactorwiseLaurent,
  endpointTermLaurent, formalDistributionCoefficients,
  buildDistributionAction, processBranchCore, processChargeTask,
  launchS10Kernels, runOrderedChargeTasks, cacheMetadataValidQ,
  makeCachePayload, branchInventoryMatchesExpectedQ,
  coupledCertificatesValidQ,
  S09EndpointValue, S09PlusDistribution, S09RegularEndpointFunction,
  S09ExpandedKernelReference, S10ConvolutionTest, S10ScaleMarker,
  S10PhysicalA, S10PhysicalRT, S10EndpointLog, S10HeldLog,
  S10HeldPolyLog, S10EndpointCA, S10EndpointCF, S10EndpointFCGV,
  S10EndpointSMP
];

activeTemporaryPath = "";
workerVersions = {};
parallelOrderProbe = {};

closeS10Kernels[] := Module[{},
  If[Length[Kernels[]] > 0, Quiet[CloseKernels[]]]
];

fatal[message_String] := (
  closeS10Kernels[];
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

workerRequire[condition_, message_String] :=
  If[! TrueQ[condition], Throw[message, "S10WorkerFailure"]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

mapAssociationValues[function_, association_Association] :=
  Map[function, association];

mapNestedAssociationValues[function_, association_Association] :=
  Map[Map[function, #] &, association];

allBranchValues[association_Association] :=
  Flatten[Map[Values, Values[association]], 1];

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
  writeResult = Quiet @ Check[
    Put[expression, activeTemporaryPath];
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    False
  ];
  assert[writeResult, "Atomic temporary write failed for " <> finalPath];
  loaded = Quiet @ Check[Get[activeTemporaryPath], $Failed];
  assert[
    AssociationQ[loaded] && loaded["Status"] === "Complete" &&
      loaded["Stage"] === expectedStage,
    "Atomic temporary reload failed for " <> finalPath
  ];
  renameResult = Quiet @ Check[
    RenameFile[activeTemporaryPath, finalPath],
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
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s09SourcePath = FileNameJoin[{
  scriptDirectory, "s09_expand_endpoints_hqqprime.wl"
}];
s09ResultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];

stageVersion = "HqqprimeS10-v1";
cacheStageVersion = "HqqprimeS10Cache-v1";
resultSchemaVersion = 1;
endpointProofVersion = 1;
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S10_PREFLIGHT_ONLY"], ""] === "1";
reconstructOnly =
  Quiet @ Check[Environment["HQQPRIME_S10_RECONSTRUCT_ONLY"], ""] === "1";
assert[
  ! (preflightOnly && reconstructOnly),
  "Preflight-only and reconstruction-only modes are mutually exclusive."
];

parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 4 2^30;
projectorKeys = {"Pg", "PPP"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
dimensionalScaleFactor = FeynCalc`ScaleMu^(4 epsilon);
additionalMultiplicativeWeight = Times @@ {1};

s09CachePaths = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_incoming_charge_squared_pg"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_prime_charge_squared_pg"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_mixed_incoming_prime_charge_pg"
    }]
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_incoming_charge_squared_ppp"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_prime_charge_squared_ppp"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s09_cache_hqqprime_mixed_incoming_prime_charge_ppp"
    }]
  |>
|>;

endpointCachePaths = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_incoming_charge_squared_pg"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_prime_charge_squared_pg"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_mixed_incoming_prime_charge_pg"
    }]
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_incoming_charge_squared_ppp"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_prime_charge_squared_ppp"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s10_cache_hqqprime_mixed_incoming_prime_charge_ppp"
    }]
  |>
|>;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS09SourceHash =
  "d1e2c26ccbb5bb0413f930f36b0428346dd621c27d9b52101f54bad16c06ae5f";
expectedS09ResultHash =
  "f2da97c62e8de83e24bbec0c80f89ca1dd966db66effe37902c70fce49fe0193";
expectedS09CacheHashes = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "159b8d9926103ca9cdc317886cec8cd72fe165420f99a237a2fb7202e86da512",
    "PrimeChargeSquared" ->
      "6290657216f198e91b72f7fed91652b2a1ec77007394894621bdc28a1af75c06",
    "MixedIncomingPrimeCharge" ->
      "165cce56c1eb186ef6ea1647d2314c9a264bdaadfc5b50daf181a4bad867c75a"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "a75be55b428da0fb9f4be7932a53004898a7d1e0f7f59172b364f9038f1cd8ef",
    "PrimeChargeSquared" ->
      "b861d0d7e6b3cf9cce07faefd4ae605545f2428bd90b8d9a8081a71283d3504d",
    "MixedIncomingPrimeCharge" ->
      "4ed9ff250fd5097ddf0918407e07725a35386ca1dabfa49b2fae3ccf998f2f6c"
  |>
|>;

expectedS09ExpressionHashes = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "3ccbb910ad6b6b57d83ee69ccc0104d22281e4a5340b47dd832843d3e0f59565",
    "PrimeChargeSquared" ->
      "dd695f20493bf58ef31594d5e570682d17a0f590f3d68116fa297ea3f16c8307",
    "MixedIncomingPrimeCharge" ->
      "5d34083b48de543067c84a3311a99d38f4232a0a50cf2bc7de5f52479e07b3d0"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "10434ca718fd7b8694d44587755a9c1e123e2a16e79fb14877f7d59d171d5d90",
    "PrimeChargeSquared" ->
      "eb2e744b858c58efdac058b7db0aef8a4d1666518b78507280195e035db13353",
    "MixedIncomingPrimeCharge" ->
      "241001c0e62d193dab649ca25f4d9cfafe12048d7a50355d4a7bc729ffb95585"
  |>
|>;

expectedExpandedLeafCounts = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> 146839,
    "PrimeChargeSquared" -> 110679,
    "MixedIncomingPrimeCharge" -> 555363
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> 99781,
    "PrimeChargeSquared" -> 105885,
    "MixedIncomingPrimeCharge" -> 564118
  |>
|>;

expectedExpandedByteCounts = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> 4201920,
    "PrimeChargeSquared" -> 3160376,
    "MixedIncomingPrimeCharge" -> 15821008
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> 2848360,
    "PrimeChargeSquared" -> 3013568,
    "MixedIncomingPrimeCharge" -> 16046064
  |>
|>;

expectedSourceTermCounts = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> 17,
    "PrimeChargeSquared" -> 13,
    "MixedIncomingPrimeCharge" -> 28
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> 10,
    "PrimeChargeSquared" -> 12,
    "MixedIncomingPrimeCharge" -> 30
  |>
|>;

expectedCoupledGroups = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> {{14, 15}},
    "PrimeChargeSquared" -> {{8, 10}},
    "MixedIncomingPrimeCharge" -> {{11}, {12}, {27}, {28}}
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> {{8, 10}},
    "PrimeChargeSquared" -> {{9, 11}},
    "MixedIncomingPrimeCharge" -> {{15}, {17}, {28}, {30}}
  |>
|>;

expectedRootSourceInventories = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> <|
      "1" -> <|"Zero" -> {14, 15}, "Unresolved" -> {14}|>,
      "-1" -> <|"Zero" -> {}, "Unresolved" -> {}|>
    |>,
    "PrimeChargeSquared" -> <|
      "1" -> <|"Zero" -> {8, 10}, "Unresolved" -> {10}|>,
      "-1" -> <|"Zero" -> {}, "Unresolved" -> {}|>
    |>,
    "MixedIncomingPrimeCharge" -> <|
      "1" -> <|"Zero" -> {11, 27}, "Unresolved" -> {}|>,
      "-1" -> <|"Zero" -> {12, 28}, "Unresolved" -> {}|>
    |>
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> <|
      "1" -> <|"Zero" -> {8, 10}, "Unresolved" -> {10}|>,
      "-1" -> <|"Zero" -> {}, "Unresolved" -> {}|>
    |>,
    "PrimeChargeSquared" -> <|
      "1" -> <|"Zero" -> {9, 11}, "Unresolved" -> {9}|>,
      "-1" -> <|"Zero" -> {}, "Unresolved" -> {}|>
    |>,
    "MixedIncomingPrimeCharge" -> <|
      "1" -> <|"Zero" -> {15, 30}, "Unresolved" -> {}|>,
      "-1" -> <|"Zero" -> {17, 28}, "Unresolved" -> {}|>
    |>
  |>
|>;

associationValueMappingProbe = mapNestedAssociationValues[
  StringLength,
  <|
    "Pg" -> <|
      "IncomingChargeSquared" -> "i",
      "PrimeChargeSquared" -> "pp",
      "MixedIncomingPrimeCharge" -> "mix"
    |>,
    "PPP" -> <|
      "IncomingChargeSquared" -> "in",
      "PrimeChargeSquared" -> "p",
      "MixedIncomingPrimeCharge" -> "mixed"
    |>
  |>
];
assert[
  associationValueMappingProbe === <|
    "Pg" -> <|
      "IncomingChargeSquared" -> 1,
      "PrimeChargeSquared" -> 2,
      "MixedIncomingPrimeCharge" -> 3
    |>,
    "PPP" -> <|
      "IncomingChargeSquared" -> 2,
      "PrimeChargeSquared" -> 1,
      "MixedIncomingPrimeCharge" -> 5
    |>
  |>,
  "Nested Association value mapping lost projector/charge order."
];

programHash = fileSHA256[programPath];
preflightArtifactSnapshot = Sort @ FileNames["s10_*", scriptDirectory];
finalArtifactPaths = Join[
  {resultPath},
  allBranchValues[endpointCachePaths]
];
staleTemporaryPaths = Join[
  FileNames["s10_result.tmp.*", scriptDirectory],
  FileNames["s10_cache_hqqprime*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "A stale S10 temporary artifact must be resolved before execution."
];
If[
  ! preflightOnly && ! reconstructOnly,
  assert[
    And @@ (! FileExistsQ[#] & /@ finalArtifactPaths),
    "A finalized S10 artifact already exists; validate it rather than overwriting it."
  ]
];
If[
  reconstructOnly,
  assert[
    And @@ (FileExistsQ /@ finalArtifactPaths),
    "Fresh reconstruction requires the complete finalized S10 artifact set."
  ]
];

Print["S10_STAGE: validating paper and accepted Hqqprime S09 handoff"];
assert[fileSHA256[paperPath] === expectedPaperHash,
  "The authoritative paper hash changed."];
assert[fileSHA256[s09SourcePath] === expectedS09SourceHash,
  "The accepted S09 source hash changed."];
assert[fileSHA256[s09ResultPath] === expectedS09ResultHash,
  "The accepted S09 result hash changed."];
assert[
  mapNestedAssociationValues[fileSHA256, s09CachePaths] ===
    expectedS09CacheHashes,
  "An accepted S09 branch-cache hash changed."
];

s09 = Quiet @ Check[Get[s09ResultPath], $Failed];
assert[AssociationQ[s09], "s09_result is not an Association."];
assert[
  s09["Status"] === "Complete" &&
    s09["Stage"] === "HqqprimeS09-v1" &&
    s09["ResultSchemaVersion"] === 1 &&
    s09["Channel"] === "Hqqprime only" &&
    s09["ProgramSHA256"] === expectedS09SourceHash &&
    s09["PaperReference"]["SHA256"] === expectedPaperHash &&
    s09["ProjectorOrder"] === projectorKeys &&
    s09["ChargeKeyOrder"] === chargeKeys,
  "s09_result failed status, schema, channel, program, paper, or order validation."
];
assert[
  Length[s09["Checks"]] === 44 &&
    And @@ (TrueQ /@ Values[s09["Checks"]]),
  "The accepted S09 result does not contain exactly 44 true checks."
];
assert[
  s09["ExpandedKernelCaches"]["StageVersion"] ===
      "HqqprimeS09Cache-v1" &&
    s09["ExpandedKernelCaches"]["Paths"] === s09CachePaths &&
    s09["ExpandedKernelCaches"]["SHA256"] === expectedS09CacheHashes &&
    s09["ExpandedKernelCaches"]["ProgramSHA256"] ===
      expectedS09SourceHash &&
    s09["ExpandedKernelCaches"]["PaperSHA256"] === expectedPaperHash &&
    s09["ExpandedKernelCaches"][
      "AtomicSourceBoundMainWriterAndDiskHashValidated"
    ] === True,
  "The accepted S09 cache-provenance handoff is incomplete or stale."
];

s09InputProvenance = s09["InputProvenance"];
scaleBookkeeping = s09["Bookkeeping"]["Scale"];
chargeBookkeeping = s09["Bookkeeping"]["Charge"];
symmetryBookkeeping = s09["Bookkeeping"]["Symmetry"];
virtualBookkeeping =
  s09["Bookkeeping"]["VirtualContributionAtThisOrder"];
speciesMultiplicities = symmetryBookkeeping["SpeciesMultiplicities"];
derivedFinalStateSymmetryFactor =
  1/Times @@ (Factorial /@ Values[speciesMultiplicities]);

assert[
  additionalMultiplicativeWeight === 1 &&
    s09["Bookkeeping"]["AdditionalMultiplicativeWeightAtS09"] === 1 &&
    s09["Bookkeeping"]["FinalStateSymmetryFactorDerivedAtS09"] ===
      derivedFinalStateSymmetryFactor &&
    derivedFinalStateSymmetryFactor === 1 &&
    s09["Bookkeeping"]["NontrivialSymmetryFactorAppliedAtS09"] ===
      False &&
    s09["Bookkeeping"][
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS09"
    ] === False &&
    s09["Bookkeeping"]["SeparateMSBarSEpsilonAppliedAtS09"] === False &&
    scaleBookkeeping["AbsoluteFactor"] === dimensionalScaleFactor &&
    scaleBookkeeping["AbsoluteExponent"] === 4 epsilon &&
    scaleBookkeeping["SeparateMSBarSEpsilonApplied"] === False &&
    chargeBookkeeping["SeparatedTensorKeys"] === chargeKeys &&
    chargeBookkeeping["CoefficientTensorsRemainChargeFree"] === True &&
    symmetryBookkeeping["FinalStateSymmetryFactor"] === 1 &&
    symmetryBookkeeping["NontrivialSymmetryFactorRequired"] === False &&
    symmetryBookkeeping[
      "NoDownstreamNontrivialSymmetryFactorRemains"
    ] === True &&
    virtualBookkeeping["Applicable"] === False &&
    virtualBookkeeping["Interference"] === 0 &&
    virtualBookkeeping["SourceDisposition"] ===
      "NotApplicableAtThisOrder",
  "The accepted S09 scale, charge, symmetry, weight, or virtual ledger changed."
];

s23UpperB = s09["EndpointExpansion"]["UpperLimit"];
formalEndpointDistributions =
  s09["EndpointExpansion"][
    "FormalDistributionByProjectorAndCharge"
  ];
endpointPlaceholderCount = Count[
  allBranchValues[formalEndpointDistributions],
  _S09EndpointValue,
  Infinity
];
endpointPlusPlaceholderCount = Total[
  Count[#, _S09PlusDistribution, Infinity] & /@
    allBranchValues[formalEndpointDistributions]
];
assert[
  s09["EndpointExpansion"]["EndpointValuesResolved"] === False &&
    s09["EndpointExpansion"]["StrongerSingularitiesResolved"] === False &&
    s09["EndpointExpansion"]["DistributionActionPerformed"] === False &&
    s09["EndpointExpansion"]["DownstreamResolutionRequired"] === True &&
    s09["EndpointExpansion"]["Interval"] ===
      {s23, 0, s23UpperB} &&
    Keys[formalEndpointDistributions] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@
      Values[formalEndpointDistributions]) &&
    endpointPlaceholderCount === 6 &&
    endpointPlusPlaceholderCount === 18,
  "The accepted six-branch formal endpoint handoff is incomplete."
];

colorCanonicalizationProbe = Quiet @ Check[
  FeynCalc`SUNSimplify[
    {FeynCalc`CA, FeynCalc`CF, FeynCalc`TF},
    TimeConstrained -> Infinity,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0
  ],
  $Failed
];
assert[
  ListQ[colorCanonicalizationProbe] &&
    Length[colorCanonicalizationProbe] === 3 &&
    FreeQ[
      colorCanonicalizationProbe,
      FeynCalc`CA | FeynCalc`CF | _Real | $Failed
    ] &&
    ! FreeQ[colorCanonicalizationProbe, FeynCalc`SUNN] &&
    ! FreeQ[colorCanonicalizationProbe, FeynCalc`TF],
  "FeynCalc failed to derive the exact SU(N) proof canonicalization."
];

hasExpectedScaleQ[expression_] := Module[{stripped},
  stripped = expression /.
    (candidate_ /; SameQ[candidate, dimensionalScaleFactor]) :> 1;
  ! FreeQ[
    expression,
    candidate_ /; SameQ[candidate, dimensionalScaleFactor]
  ] && FreeQ[stripped, FeynCalc`ScaleMu]
];

expandedKernelValidQ[expression_] :=
  expression =!= 0 && expression =!= $Failed &&
    FreeQ[
      expression,
      _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma |
        _FeynCalc`FeynAmpDenominator | _Real | Indeterminate |
        _SeriesData | $Failed | $Aborted | ComplexInfinity |
        DirectedInfinity | _Inactive | S01Qq | S01QqPrime
    ] &&
    FreeQ[
      expression,
      sHat | t1 | t2 | t3 | tHat | u1 | u2 | u3 | s12 | s13 |
        zeta | zHat | beta1 | beta2
    ] &&
    hasExpectedScaleQ[expression];

validateS09Cache[
    payload_, projectorName_String, chargeKey_String
  ] := Module[{expression},
  assert[
    AssociationQ[payload] &&
      payload["Status"] === "Complete" &&
      payload["Stage"] === "HqqprimeS09Cache-v1" &&
      payload["ResultSchemaVersion"] === 1 &&
      payload["Channel"] === "Hqqprime only" &&
      payload["Projector"] === projectorName &&
      payload["ChargeKey"] === chargeKey &&
      payload["ProgramSHA256"] === expectedS09SourceHash &&
      payload["PaperSHA256"] === expectedPaperHash &&
      payload["S08SourceSHA256"] ===
        s09InputProvenance["S08SourceSHA256"] &&
      payload["S08ResultSHA256"] ===
        s09InputProvenance["S08ResultSHA256"] &&
      payload["S08CachePath"] ===
        s09InputProvenance["S08CachePaths"]
          [projectorName][chargeKey] &&
      payload["S08CacheSHA256"] ===
        s09InputProvenance["S08CacheSHA256"]
          [projectorName][chargeKey] &&
      payload["AdditionalMultiplicativeWeight"] === 1 &&
      payload["ScaleBookkeeping"] === scaleBookkeeping &&
      payload["ChargeBookkeeping"] === chargeBookkeeping &&
      payload["SymmetryBookkeeping"] === symmetryBookkeeping &&
      payload["FinalStateSymmetryFactor"] === 1 &&
      payload["VirtualContributionAtThisOrder"] === virtualBookkeeping &&
      payload["ExpandedLeafCount"] ===
        expectedExpandedLeafCounts[projectorName][chargeKey] &&
      payload["ExpandedByteCount"] ===
        expectedExpandedByteCounts[projectorName][chargeKey] &&
      payload["ExpressionSHA256"] ===
        expectedS09ExpressionHashes[projectorName][chargeKey],
    projectorName <> " " <> chargeKey <>
      " S09 cache failed metadata or bookkeeping validation."
  ];
  expression = payload["Expression"];
  assert[
    LeafCount[expression] ===
        expectedExpandedLeafCounts[projectorName][chargeKey] &&
      ByteCount[expression] ===
        expectedExpandedByteCounts[projectorName][chargeKey] &&
      expressionSHA256[expression] ===
        expectedS09ExpressionHashes[projectorName][chargeKey] &&
      expandedKernelValidQ[expression],
    projectorName <> " " <> chargeKey <>
      " S09 expression failed hash, size, purity, map, or scale validation."
  ];
  expression
];

Print["S10_STAGE: loading and validating the six accepted S09 caches"];
s09Expressions = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> Module[{payload, expression},
      payload = Quiet @ Check[
        Get[s09CachePaths[projectorName][chargeKey]],
        $Failed
      ];
      expression = validateS09Cache[payload, projectorName, chargeKey];
      Clear[payload];
      expression
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];
assert[
  Keys[s09Expressions] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[s09Expressions]),
  "The six validated S09 expressions lost projector/charge order."
];
Print["S10_CHECKPOINT: accepted S09 metadata and expressions validated"];

invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | $Aborted | Indeterminate | ComplexInfinity |
    DirectedInfinity | _Limit | Log[0] | Power[0, _?Negative] | _Real
];

vanishingEndpointQ[expression_] := Module[{value, reduced},
  value = Quiet @ Check[expression /. s23 -> 0, $Failed];
  If[TrueQ[value === 0], Return[True]];
  If[invalidEndpointQ[value] || ! FreeQ[value, s23], Return[False]];
  reduced = Quiet @ Check[
    TimeConstrained[Cancel[Together[value]], 60, $Failed],
    $Failed
  ];
  TrueQ[reduced === 0]
];

splitEndpointProjection[
    expression_, projectorName_String, chargeKey_String
  ] := Module[
  {
    label, markedExpression, scaleFreeExpression, factors,
    regulatorPositions, remainderIndex, remainder, prefactorIndices,
    prefactor, terms
  },
  label = projectorName <> " " <> chargeKey;
  markedExpression = expression /.
    (candidate_ /; SameQ[candidate, dimensionalScaleFactor]) :>
      S10ScaleMarker;
  workerRequire[
    TrueQ[(markedExpression /. S10ScaleMarker -> 0) === 0],
    label <> " is not homogeneous with zero scale-marker constant term"
  ];
  scaleFreeExpression = Quiet @ Check[
    TimeConstrained[D[markedExpression, S10ScaleMarker], 300, $Failed],
    $Failed
  ];
  workerRequire[
    scaleFreeExpression =!= $Failed &&
      FreeQ[
        scaleFreeExpression,
        S10ScaleMarker | FeynCalc`ScaleMu | _Real
      ],
    label <> " failed exact degree-one scale-core extraction"
  ];
  factors = List @@ scaleFreeExpression;
  workerRequire[
    Head[scaleFreeExpression] === Times && Length[factors] === 11,
    label <> " does not have the measured 11-factor scale-free shape"
  ];
  regulatorPositions = Flatten @ Position[
    factors,
    factor_ /; SameQ[factor, s23^(-epsilon)],
    {1},
    Heads -> False
  ];
  workerRequire[
    Length[regulatorPositions] === 1,
    label <> " does not contain exactly one common s23^(-epsilon)"
  ];
  remainderIndex = First @ Ordering[LeafCount /@ factors, -1];
  workerRequire[
    remainderIndex =!= First[regulatorPositions],
    label <> " selected the regulator as its additive remainder"
  ];
  remainder = factors[[remainderIndex]];
  workerRequire[
    Head[remainder] === Plus,
    label <> " has no dominant top-level additive endpoint remainder"
  ];
  terms = List @@ remainder;
  workerRequire[Length[terms] > 0,
    label <> " has an empty endpoint source-term list"];
  prefactorIndices = Complement[
    Range[Length[factors]],
    {First[regulatorPositions], remainderIndex}
  ];
  prefactor = Times @@ factors[[prefactorIndices]];
  workerRequire[
    FreeQ[
      prefactor,
      s23^(-epsilon) | S10ScaleMarker | FeynCalc`ScaleMu | _Real
    ],
    label <> " scale-free endpoint prefactor retained a forbidden factor"
  ];
  <|
    "ScaleHomogeneityCertificate" -> <|
      "MarkerZeroIsExactZero" -> True,
      "FirstDerivativeIsMarkerFree" -> True,
      "ScaleFreeCoreContainsNoScaleMu" -> True
    |>,
    "ScaleFreeExpressionSHA256" -> expressionSHA256[scaleFreeExpression],
    "TopLevelFactorCount" -> Length[factors],
    "Prefactor" -> prefactor,
    "PrefactorSHA256" -> expressionSHA256[prefactor],
    "Terms" -> terms,
    "SourceTermSHA256" -> expressionSHA256 /@ terms,
    "SourceTermCount" -> Length[terms]
  |>
];

exceptionalPowerTermIndices[terms_List] := Flatten @ MapIndexed[
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

directSingularLogTermIndices[terms_List] := Flatten @ MapIndexed[
  Function[{term, position},
    If[
      AnyTrue[
        Cases[term, Log[argument_] :> argument, Infinity],
        Function[argument,
          Module[{value = Quiet @ Check[argument /. s23 -> 0, $Failed]},
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

colorCanonicalize[expression_] := Quiet @ Check[
  TimeConstrained[
    FeynCalc`SUNSimplify[
      expression,
      TimeConstrained -> Infinity,
      FeynCalc`SUNNToCACF -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0
    ],
    300,
    $Failed
  ],
  $Failed
];

exactPhysicalZeroQ[expression_, assumptions_] := Module[
  {combined, colorCanonical, simplified},
  combined = Quiet @ Check[
    TimeConstrained[Together[expression], 300, $Failed],
    $Failed
  ];
  If[combined === $Failed, Return[False]];
  If[TrueQ[combined === 0], Return[True]];
  colorCanonical = colorCanonicalize[combined];
  If[colorCanonical === $Failed, Return[False]];
  If[TrueQ[colorCanonical === 0], Return[True]];
  simplified = Quiet @ Check[
    TimeConstrained[
      FullSimplify[colorCanonical, Assumptions -> assumptions],
      300,
      $Failed
    ],
    $Failed
  ];
  TrueQ[simplified === 0]
];

physicalBranchLogInventory[
    terms_List, projectorName_String, chargeKey_String
  ] := Module[
  {
    label, aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    expectedRootRadicand, physicalSubstitution, allArguments,
    sourceIndicesForPositions, rootSign, rootRule, canonical,
    branchValues, zeroPositions, unresolvedPositions, zeroRecords,
    slope, audit = <||>
  },
  label = projectorName <> " " <> chargeKey;
  aPhysical = S10PhysicalA;
  rTPhysical = S10PhysicalRT;
  denominatorPhysical = rTPhysical + zH - rTPhysical zH;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  allArguments = DeleteDuplicates @ Cases[
    terms,
    Log[argument_] :> argument,
    Infinity
  ];
  sourceIndicesForPositions[positions_List] :=
    Sort @ DeleteDuplicates @ Flatten @ Map[
      Function[argumentPosition,
        Flatten @ MapIndexed[
          Function[{term, termPosition},
            If[
              MemberQ[
                DeleteDuplicates @ Cases[
                  term,
                  Log[argument_] :> argument,
                  Infinity
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
      Quiet @ Check[
        Cancel[Together[rootArgument - expectedRootRadicand]],
        $Failed
      ] === 0
    ] :> (rootSign Q2 deltaPhysical/denominatorPhysical)^(2 rootPower);
    canonical[value_] := Quiet @ Check[
      TimeConstrained[
        FixedPoint[Factor[Together[# /. rootRule]] &, value, 3],
        90,
        $Failed
      ],
      $Failed
    ];
    branchValues = canonical[
      ((# /. physicalSubstitution) /. s23 -> 0)
    ] & /@ allArguments;
    zeroPositions = Flatten @ Position[
      branchValues,
      value_ /; TrueQ[value === 0],
      {1},
      Heads -> False
    ];
    unresolvedPositions = Flatten @ Position[
      branchValues,
      value_ /; SameQ[value, $Failed] || invalidEndpointQ[value],
      {1},
      Heads -> False
    ];
    zeroRecords = Table[
      slope = canonical[
        ((D[allArguments[[position]], s23] /. s23 -> 0) /.
          physicalSubstitution)
      ];
      workerRequire[
        slope =!= $Failed && ! invalidEndpointQ[slope] &&
          FreeQ[slope, s23] && ! TrueQ[slope === 0],
        label <> " has a zero logarithm with no finite nonzero slope"
      ];
      <|
        "ArgumentPosition" -> position,
        "SourceTermIndices" -> sourceIndicesForPositions[{position}],
        "EndpointSlope" -> slope,
        "EndpointSlopeSHA256" -> expressionSHA256[slope]
      |>,
      {position, zeroPositions}
    ];
    audit[ToString[rootSign]] = <|
      "ZeroArgumentPositions" -> zeroPositions,
      "ZeroSourceTermIndices" ->
        sourceIndicesForPositions[zeroPositions],
      "UnresolvedArgumentPositions" -> unresolvedPositions,
      "UnresolvedSourceTermIndices" ->
        sourceIndicesForPositions[unresolvedPositions],
      "ZeroArgumentRecords" -> zeroRecords
    |>;,
    {rootSign, {1, -1}}
  ];
  audit
];

deriveCoupledGroups[branchInventory_Association] := Module[
  {records, incidence, vertices, edges},
  records = Join[
    branchInventory["1"]["ZeroArgumentRecords"],
    branchInventory["-1"]["ZeroArgumentRecords"]
  ];
  incidence = DeleteDuplicates @ Lookup[
    records,
    "SourceTermIndices",
    {}
  ];
  incidence = Select[incidence, Length[#] > 0 &];
  vertices = Sort @ DeleteDuplicates @ Flatten[incidence];
  If[vertices === {}, Return[{}]];
  edges = DeleteDuplicates @ Flatten[
    (UndirectedEdge @@@ Subsets[#, {2}] &) /@ incidence
  ];
  Sort[
    Sort /@ ConnectedComponents[Graph[vertices, edges]],
    First[#1] < First[#2] &
  ]
];

branchInventoryMatchesExpectedQ[
    branchInventory_Association,
    projectorName_String,
    chargeKey_String
  ] := Module[{expected},
  expected = expectedRootSourceInventories[projectorName][chargeKey];
  And @@ Flatten @ Table[
    branchInventory[rootKey]["ZeroSourceTermIndices"] ===
        expected[rootKey]["Zero"] &&
      branchInventory[rootKey]["UnresolvedSourceTermIndices"] ===
        expected[rootKey]["Unresolved"],
    {rootKey, {"1", "-1"}}
  ]
];

coupledCertificatesValidQ[
    certificates_List, expectedGroups_List
  ] := Length[certificates] === Length[expectedGroups] &&
  And @@ MapThread[
    Function[{certificate, group},
      AssociationQ[certificate] &&
        certificate["SourceTermIndices"] === group &&
        StringMatchQ[
          certificate["FiniteAnchorSHA256"],
          RegularExpression["[0-9a-f]{64}"]
        ] &&
        AssociationQ[certificate["RootCertificates"]] &&
        Keys[certificate["RootCertificates"]] === {"1", "-1"} &&
        AllTrue[
          Values[certificate["RootCertificates"]],
          AssociationQ[#] &&
            IntegerQ[#["MaximumEndpointLogDegree"]] &&
            #["MaximumEndpointLogDegree"] >= 0 &&
            AssociationQ[#["PositiveLogPowerChecks"]] &&
            And @@ (TrueQ /@ Values[#["PositiveLogPowerChecks"]]) &&
            StringMatchQ[
              #["FiniteConstantSHA256"],
              RegularExpression["[0-9a-f]{64}"]
            ] &
        ]
    ],
    {certificates, expectedGroups}
  ];

coupledEndpointGroupFinite[
    sourceTerms_List, finiteTerms_List, sourceIndices_List,
    projectorName_String, chargeKey_String
  ] := Module[
  {
    label, aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    expectedRootRadicand, physicalSubstitution, inverseSubstitution,
    originalDelta, rootSign, positiveRoot, rootRule, canonical,
    branchAssumptions, transformTerm, branchTerms, maximumDegree,
    coefficient, constant, groupResult, rootCertificates = <||>,
    groupPosition
  },
  label = projectorName <> " " <> chargeKey <> " group " <>
    ToString[InputForm[sourceIndices]];
  workerRequire[
    Length[sourceTerms] === Length[finiteTerms] === Length[sourceIndices],
    label <> " has inconsistent source and finite term lists"
  ];
  aPhysical = S10PhysicalA;
  rTPhysical = S10PhysicalRT;
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
  Do[
    positiveRoot = rootSign Q2 deltaPhysical/denominatorPhysical;
    rootRule = HoldPattern[
      Power[
        rootArgument_,
        rootPower_Rational?((Denominator[#] === 2) &)
      ]
    ] /; TrueQ[
      Quiet @ Check[
        Cancel[Together[rootArgument - expectedRootRadicand]],
        $Failed
      ] === 0
    ] :> positiveRoot^(2 rootPower);
    canonical[value_] := Quiet @ Check[
      TimeConstrained[
        FixedPoint[Factor[Together[# /. rootRule]] &, value, 3],
        90,
        $Failed
      ],
      $Failed
    ];
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && rootSign deltaPhysical > 0;

    transformTerm[
        sourceTerm_, finiteTerm_, sourceIndex_Integer
      ] := Module[
      {
        held, transformed, rootRadicands, sourceLogArguments,
        zeroSourceLogArguments, slopes = {}, slope = Missing["NotNeeded"],
        argument, zeroHeldLogCount = 0, result
      },
      held = finiteTerm /. Log[value_] :> S10HeldLog[value];
      held = held /. PolyLog[order_, value_] :>
        S10HeldPolyLog[order, value];
      transformed = held /. physicalSubstitution;
      rootRadicands = DeleteDuplicates @ Cases[
        transformed,
        Power[
          radicand_,
          power_Rational?((Denominator[#] === 2) &)
        ] :> radicand,
        Infinity
      ];
      workerRequire[
        And @@ (
          TrueQ[
            Quiet @ Check[
              Cancel[Together[# - expectedRootRadicand]],
              $Failed
            ] === 0
          ] & /@ rootRadicands
        ),
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected physical endpoint square root"
      ];
      transformed = transformed /. rootRule;
      sourceLogArguments = DeleteDuplicates @ Cases[
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
      transformed = transformed /. S10HeldLog[value_] :> Module[{},
        argument = canonical[value];
        If[
          TrueQ[argument === 0],
          zeroHeldLogCount++;
          If[
            slopes === {},
            slopes = Quiet @ DeleteDuplicates[
              canonical[
                ((D[#, s23] /. s23 -> 0) /. physicalSubstitution)
              ] & /@ zeroSourceLogArguments
            ];
            workerRequire[
              Length[slopes] === 1 &&
                And @@ (
                  FreeQ[#, s23] && ! invalidEndpointQ[#] &&
                    ! TrueQ[# === 0] & /@ slopes
                ),
              label <> " term " <> ToString[sourceIndex] <>
                " has a nonlinear or invalid vanishing logarithm"
            ];
            slope = First[slopes]
          ];
          workerRequire[
            ! MissingQ[slope] && ! invalidEndpointQ[slope],
            label <> " term " <> ToString[sourceIndex] <>
              " cannot match its endpoint logarithm to a source slope"
          ];
          S10EndpointLog + S10HeldLog[slope],
          S10HeldLog[argument]
        ]
      ];
      transformed = transformed /.
        S10HeldPolyLog[order_, value_] :>
          S10HeldPolyLog[order, canonical[value]];
      result = transformed /.
        S10HeldLog[value_] :> Log[value] /.
        S10HeldPolyLog[order_, value_] :> PolyLog[order, value];
      workerRequire[
        FreeQ[result, S10HeldLog | S10HeldPolyLog] &&
          ! invalidEndpointQ[result] && FreeQ[result, s23],
        label <> " term " <> ToString[sourceIndex] <>
          " did not produce a valid branch-resolved endpoint value"
      ];
      result
    ];

    branchTerms = MapThread[
      transformTerm,
      {sourceTerms, finiteTerms, sourceIndices}
    ];
    maximumDegree = Max[
      0,
      Sequence @@ Replace[
        Exponent[#, S10EndpointLog] & /@ branchTerms,
        -Infinity -> 0,
        {1}
      ]
    ];
    Do[
      coefficient = Total[
        Coefficient[#, S10EndpointLog, groupPosition] & /@ branchTerms
      ];
      workerRequire[
        exactPhysicalZeroQ[coefficient, branchAssumptions],
        label <> " retains endpoint Log[s23]^" <>
          ToString[groupPosition] <> " on root sign " <>
          ToString[rootSign]
      ];,
      {groupPosition, maximumDegree, 1, -1}
    ];
    constant = Total[(# /. S10EndpointLog -> 0) & /@ branchTerms];
    workerRequire[
      FreeQ[constant, S10EndpointLog | s23] &&
        ! invalidEndpointQ[constant],
      label <> " has an invalid grouped endpoint constant on root sign " <>
        ToString[rootSign]
    ];
    rootCertificates[ToString[rootSign]] = <|
      "MaximumEndpointLogDegree" -> maximumDegree,
      "PositiveLogPowerChecks" ->
        Association@Table[
          ToString[power] -> True,
          {power, 1, maximumDegree}
        ],
      "FiniteConstantSHA256" -> expressionSHA256[constant],
      "FiniteConstant" -> constant
    |>;
    Clear[branchTerms, coefficient, constant];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];
  groupResult = Piecewise[
    {{rootCertificates["1"]["FiniteConstant"] /.
        inverseSubstitution, originalDelta >= 0}},
    rootCertificates["-1"]["FiniteConstant"] /. inverseSubstitution
  ];
  workerRequire[
    FreeQ[groupResult, S10EndpointLog | S10HeldLog |
        S10HeldPolyLog | s23] &&
      ! invalidEndpointQ[groupResult],
    label <> " grouped endpoint result is invalid"
  ];
  <|
    "SourceTermIndices" -> sourceIndices,
    "FiniteAnchor" -> groupResult,
    "FiniteAnchorSHA256" -> expressionSHA256[groupResult],
    "RootCertificates" -> Map[KeyDrop[#, {"FiniteConstant"}] &,
      rootCertificates]
  |>
];

repairCoupledEndpointGroups[
    sourceTerms_List, finiteTerms_List, groups_List,
    projectorName_String, chargeKey_String
  ] := Module[
  {repaired = finiteTerms, certificates = {}, group, groupData},
  Do[
    groupData = coupledEndpointGroupFinite[
      sourceTerms[[group]],
      repaired[[group]],
      group,
      projectorName,
      chargeKey
    ];
    repaired[[First[group]]] = groupData["FiniteAnchor"];
    Scan[(repaired[[#]] = 0) &, Rest[group]];
    AppendTo[certificates, KeyDrop[groupData, {"FiniteAnchor"}]];,
    {group, groups}
  ];
  <|
    "FiniteCoefficients" -> repaired,
    "Certificates" -> certificates
  |>
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
  factorEndpointTermValues = Quiet @ Check[
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
  singularIndices = Flatten @ Position[
    factorRegularFlags,
    False,
    {1},
    Heads -> False
  ];
  If[
    Length[singularIndices] === 0,
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
    Return[$Failed]];
  regularizedTerms = Quiet @ Check[
    TimeConstrained[(Cancel[s23^2 #] &) /@ remainderTerms, 600, $Failed],
    $Failed
  ];
  If[regularizedTerms === $Failed, Return[$Failed]];
  minus2Terms = Quiet[(# /. s23 -> 0) & /@ regularizedTerms];
  If[
    AnyTrue[minus2Terms, invalidEndpointQ] ||
      ! AllTrue[minus2Terms, FreeQ[#, s23] &],
    Return[$Failed]
  ];
  minus1Terms = Quiet @ Check[
    TimeConstrained[
      (D[#, s23] /. s23 -> 0 &) /@ regularizedTerms,
      600,
      $Failed
    ],
    $Failed
  ];
  If[
    minus1Terms === $Failed || AnyTrue[minus1Terms, invalidEndpointQ] ||
      ! AllTrue[minus1Terms, FreeQ[#, s23] &],
    Return[$Failed]
  ];
  minus2Coefficient = Total[minus2Terms];
  minus1Coefficient = Total[minus1Terms];
  regular1 = 0;
  If[
    ! TrueQ[minus2Coefficient === 0],
    regularDerivativeTermValues = Quiet @ Check[
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
    If[
      regularDerivativeTermValues === $Failed ||
        AnyTrue[Flatten[regularDerivativeTermValues], invalidEndpointQ] ||
        ! AllTrue[
          Flatten[regularDerivativeTermValues],
          FreeQ[#, s23] &
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
  If[
    invalidEndpointQ[poleCoefficient] ||
      invalidEndpointQ[finiteCoefficient] ||
      ! FreeQ[poleCoefficient, s23] ||
      ! FreeQ[finiteCoefficient, s23],
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
    term_, label_String, index_Integer
  ] := Module[
  {
    factorwise, direct, cancelled, numerator, denominator, poleOrder,
    poleCoefficient, finiteCoefficient
  },
  factorwise = endpointFactorwiseLaurent[term, label, index];
  If[AssociationQ[factorwise], Return[factorwise]];
  direct = If[
    LeafCount[term] > 30000,
    $Failed,
    Quiet @ Check[
      TimeConstrained[(s23 term) /. s23 -> 0, 60, $Failed],
      $Failed
    ]
  ];
  If[
    ! invalidEndpointQ[direct] && FreeQ[direct, s23],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "direct"
    |>]
  ];
  cancelled = Quiet @ Check[
    TimeConstrained[Cancel[s23 term], 600, $Failed],
    $Failed
  ];
  workerRequire[
    cancelled =!= $Failed,
    label <> " term " <> ToString[index] <>
      " failed exact rational cancellation"
  ];
  direct = Quiet[cancelled /. s23 -> 0];
  If[
    ! invalidEndpointQ[direct] && FreeQ[direct, s23],
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
  workerRequire[
    poleOrder === 1,
    label <> " term " <> ToString[index] <>
      " has unsupported endpoint pole order " <> ToString[poleOrder]
  ];
  poleCoefficient = Quiet @ Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, -1}],
      600,
      $Failed
    ],
    $Failed
  ];
  finiteCoefficient = Quiet @ Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, 0}],
      600,
      $Failed
    ],
    $Failed
  ];
  workerRequire[
    ! invalidEndpointQ[poleCoefficient] &&
      ! invalidEndpointQ[finiteCoefficient] &&
      FreeQ[poleCoefficient, s23] && FreeQ[finiteCoefficient, s23],
    label <> " term " <> ToString[index] <>
      " failed exact endpoint Laurent extraction"
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> True,
    "Method" -> "full Laurent fallback"
  |>
];

formalDistributionCoefficients[
    formalDistribution_, projectorName_String, chargeKey_String
  ] := Module[
  {
    label, skeleton, plusRecords, plusOrders, deltaCoefficient,
    plusCoefficients, rebuilt
  },
  label = projectorName <> " " <> chargeKey;
  skeleton = formalDistribution /.
    HoldPattern[S09EndpointValue[___]] :> 1 /.
    HoldPattern[S09RegularEndpointFunction[___]] :> 1;
  plusRecords = DeleteDuplicates @ Cases[
    skeleton,
    S09PlusDistribution[order_, variable_, upper_] :>
      {order, variable, upper},
    Infinity
  ];
  workerRequire[
    Length[plusRecords] === 3 &&
      And @@ (
        SameQ[#[[2]], s23] && SameQ[#[[3]], s23UpperB] & /@
          plusRecords
      ),
    label <> " formal S09 plus-distribution records changed"
  ];
  plusOrders = Sort[plusRecords[[All, 1]]];
  workerRequire[
    plusOrders === Range[0, 2] &&
      Count[skeleton, DiracDelta[s23], Infinity] === 1,
    label <> " formal S09 delta/plus order inventory changed"
  ];
  deltaCoefficient = skeleton /.
    HoldPattern[S09PlusDistribution[___]] :> 0 /.
    DiracDelta[s23] -> 1;
  plusCoefficients = Association@Table[
    ToString[order] -> (
      skeleton /.
        DiracDelta[s23] -> 0 /.
        HoldPattern[S09PlusDistribution[currentOrder_, ___]] :>
          If[SameQ[currentOrder, order], 1, 0]
    ),
    {order, plusOrders}
  ];
  rebuilt = deltaCoefficient DiracDelta[s23] + Total@Table[
    plusCoefficients[ToString[order]] *
      S09PlusDistribution[order, s23, s23UpperB],
    {order, plusOrders}
  ];
  workerRequire[
    SameQ[Expand[rebuilt], Expand[skeleton]] &&
      ! invalidEndpointQ[deltaCoefficient] &&
      FreeQ[deltaCoefficient, s23 | _Real] &&
      AllTrue[
        Values[plusCoefficients],
        ! invalidEndpointQ[#] && FreeQ[#, s23 | _Real] &
      ],
    label <> " formal S09 distribution coefficients failed extraction"
  ];
  <|
    "PlusOrders" -> plusOrders,
    "DeltaCoefficient" -> deltaCoefficient,
    "PlusCoefficients" -> plusCoefficients,
    "ExactSkeletonReconstruction" -> True
  |>
];

buildDistributionAction[
    formalDistribution_, endpointCore_, regularCore_,
    projectorName_String, chargeKey_String
  ] := Module[
  {
    coefficients, testAtS, testAtZero, plusDensity, actionCore,
    action
  },
  coefficients = formalDistributionCoefficients[
    formalDistribution,
    projectorName,
    chargeKey
  ];
  testAtS = S10ConvolutionTest[projectorName, chargeKey, s23];
  testAtZero = S10ConvolutionTest[projectorName, chargeKey, 0];
  plusDensity = Total@Table[
    coefficients["PlusCoefficients"][ToString[order]] *
      Log[s23/s23UpperB]^order/s23,
    {order, coefficients["PlusOrders"]}
  ];
  actionCore =
    coefficients["DeltaCoefficient"] endpointCore testAtZero +
      Inactive[Integrate][
        plusDensity *
          (regularCore testAtS - endpointCore testAtZero),
        {s23, 0, s23UpperB}
      ];
  action = dimensionalScaleFactor actionCore;
  workerRequire[
    FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution |
        _S09RegularEndpointFunction | _S09ExpandedKernelReference |
        DiracDelta[s23] | _Real | $Failed | Indeterminate
    ] &&
      Count[action, Inactive[Integrate][___], Infinity] === 1 &&
      ! FreeQ[action, _S10ConvolutionTest] &&
      hasExpectedScaleQ[action] &&
      Count[
        action,
        candidate_ /; SameQ[candidate, dimensionalScaleFactor],
        Infinity
      ] === 1 &&
      FreeQ[actionCore, FeynCalc`ScaleMu],
    projectorName <> " " <> chargeKey <>
      " resolved distribution action failed structure, purity, or scale validation"
  ];
  <|
    "FormalDistributionCoefficients" -> coefficients,
    "Action" -> action,
    "ActionSHA256" -> expressionSHA256[action]
  |>
];

processBranchCore[
    expression_, formalDistribution_, projectorName_String,
    chargeKey_String, preflightFlag_?BooleanQ
  ] := Module[
  {
    label, split, terms, prefactor, termCount, exceptionalIndices,
    directLogIndices, branchInventory, derivedGroups, expectedGroups,
    groupedIndices, zeroIndices, unresolvedIndices, representativeIndices,
    termAnswers, poles, finite, flags, methods, repair,
    repairedFinite, repairCertificates, rawPoleResidual,
    reducedPoleResidual, strongerPoleOrders, prefactorEndpoint,
    endpointCore, regularCore, actionData, preflightAction
  },
  label = "Hqqprime " <> projectorName <> " " <> chargeKey;
  split = splitEndpointProjection[
    expression,
    projectorName,
    chargeKey
  ];
  terms = split["Terms"];
  prefactor = split["Prefactor"];
  termCount = split["SourceTermCount"];
  workerRequire[
    termCount === expectedSourceTermCounts[projectorName][chargeKey],
    label <> " source-term count changed"
  ];
  exceptionalIndices = exceptionalPowerTermIndices[terms];
  workerRequire[
    exceptionalIndices === {},
    label <> " acquired an unsupported alpha-two or exceptional regulator class"
  ];
  directLogIndices = directSingularLogTermIndices[terms];
  workerRequire[
    directLogIndices === {},
    label <> " contains a direct singular logarithm outside root treatment"
  ];
  branchInventory = physicalBranchLogInventory[
    terms,
    projectorName,
    chargeKey
  ];
  workerRequire[
    branchInventoryMatchesExpectedQ[
      branchInventory,
      projectorName,
      chargeKey
    ],
    label <> " physical-root source inventory changed"
  ];
  derivedGroups = deriveCoupledGroups[branchInventory];
  expectedGroups = expectedCoupledGroups[projectorName][chargeKey];
  workerRequire[
    derivedGroups === expectedGroups,
    label <> " source-derived coupled-log groups changed"
  ];
  groupedIndices = Sort @ DeleteDuplicates @ Flatten[derivedGroups];
  zeroIndices = Sort @ DeleteDuplicates @ Flatten[
    Lookup[Values[branchInventory], "ZeroSourceTermIndices"]
  ];
  unresolvedIndices = Sort @ DeleteDuplicates @ Flatten[
    Lookup[Values[branchInventory], "UnresolvedSourceTermIndices"]
  ];
  workerRequire[
    groupedIndices === zeroIndices &&
      Complement[unresolvedIndices, groupedIndices] === {} &&
      Intersection[groupedIndices, exceptionalIndices] === {},
    label <> " coupled groups do not exactly cover the root inventory"
  ];

  If[
    preflightFlag,
    representativeIndices = Sort @ DeleteDuplicates @ Join[
      groupedIndices,
      Take[
        Complement[Range[termCount], groupedIndices],
        UpTo[1]
      ]
    ];
    termAnswers = Map[
      endpointTermLaurent[terms[[#]], label, #] &,
      representativeIndices
    ];
    workerRequire[
      And @@ (AssociationQ /@ termAnswers),
      label <> " representative Laurent extraction failed"
    ];
    finite = ConstantArray[0, termCount];
    Do[
      finite[[representativeIndices[[position]]]] =
        termAnswers[[position]]["FiniteCoefficient"];
      ,
      {position, Length[representativeIndices]}
    ];
    repair = repairCoupledEndpointGroups[
      terms,
      finite,
      derivedGroups,
      projectorName,
      chargeKey
    ];
    repairedFinite = repair["FiniteCoefficients"];
    workerRequire[
      AllTrue[
        repairedFinite[[groupedIndices]],
        ! invalidEndpointQ[#] && FreeQ[#, s23] &
      ],
      label <> " coupled-group preflight retained an invalid endpoint"
    ];
    preflightAction = buildDistributionAction[
      formalDistribution,
      1,
      1,
      projectorName,
      chargeKey
    ];
    Return[<|
      "Projector" -> projectorName,
      "ChargeKey" -> chargeKey,
      "PreflightOnly" -> True,
      "ScaleHomogeneityCertificate" ->
        split["ScaleHomogeneityCertificate"],
      "TopLevelFactorCount" -> split["TopLevelFactorCount"],
      "SourceTermCount" -> termCount,
      "ExceptionalPowerTermIndices" -> exceptionalIndices,
      "DirectSingularLogTermIndices" -> directLogIndices,
      "PhysicalBranchLogInventory" -> branchInventory,
      "DerivedCoupledLogGroups" -> derivedGroups,
      "RepresentativeTermIndices" -> representativeIndices,
      "RepresentativeMethodCounts" ->
        Counts[Lookup[termAnswers, "Method"]],
      "CoupledGroupCertificates" -> repair["Certificates"],
      "FormalDistributionCoefficientGatePassed" ->
        TrueQ[
          preflightAction["FormalDistributionCoefficients"][
            "ExactSkeletonReconstruction"
          ]
        ],
      "RepresentativeActionStructureGatePassed" -> True
    |>]
  ];

  termAnswers = MapIndexed[
    endpointTermLaurent[
      #1,
      label,
      First[#2]
    ] &,
    terms
  ];
  workerRequire[
    Length[termAnswers] === termCount &&
      And @@ (AssociationQ /@ termAnswers),
    label <> " complete Laurent extraction failed"
  ];
  poles = Lookup[termAnswers, "PoleCoefficient"];
  finite = Lookup[termAnswers, "FiniteCoefficient"];
  flags = Lookup[termAnswers, "RequiredPoleSubtraction"];
  methods = Lookup[termAnswers, "Method"];
  repair = repairCoupledEndpointGroups[
    terms,
    finite,
    derivedGroups,
    projectorName,
    chargeKey
  ];
  repairedFinite = repair["FiniteCoefficients"];
  repairCertificates = repair["Certificates"];
  rawPoleResidual = Total[poles];
  reducedPoleResidual = Quiet @ Check[
    TimeConstrained[Cancel[Together[rawPoleResidual]], 900, $Failed],
    $Failed
  ];
  workerRequire[
    reducedPoleResidual =!= $Failed,
    label <> " stronger endpoint-pole reduction failed"
  ];
  strongerPoleOrders = <|
    "Epsilon0" -> Quiet @ Check[
      TimeConstrained[
        Cancel[Together[reducedPoleResidual /. epsilon -> 0]],
        900,
        $Failed
      ],
      $Failed
    ],
    "Epsilon1" -> Quiet @ Check[
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
  workerRequire[
    FreeQ[Values[strongerPoleOrders], $Failed] &&
      And @@ (TrueQ[# === 0] & /@ Values[strongerPoleOrders]),
    label <> " has a nonzero stronger endpoint pole through epsilon^1"
  ];
  prefactorEndpoint = Quiet @ Check[prefactor /. s23 -> 0, $Failed];
  workerRequire[
    ! invalidEndpointQ[prefactorEndpoint] &&
      FreeQ[prefactorEndpoint, s23 | FeynCalc`ScaleMu],
    label <> " common scale-free prefactor has no finite endpoint"
  ];
  endpointCore = additionalMultiplicativeWeight *
    prefactorEndpoint * Total[repairedFinite];
  regularCore = additionalMultiplicativeWeight * (
    s23 prefactor Total[terms] -
      prefactor reducedPoleResidual/s23
  );
  workerRequire[
    ! invalidEndpointQ[endpointCore] &&
      FreeQ[endpointCore, s23 | FeynCalc`ScaleMu],
    label <> " resolved endpoint value is invalid"
  ];
  actionData = buildDistributionAction[
    formalDistribution,
    endpointCore,
    regularCore,
    projectorName,
    chargeKey
  ];
  <|
    "Projector" -> projectorName,
    "ChargeKey" -> chargeKey,
    "PreflightOnly" -> False,
    "ScaleHomogeneityCertificate" ->
      split["ScaleHomogeneityCertificate"],
    "ScaleFreeExpressionSHA256" -> split["ScaleFreeExpressionSHA256"],
    "TopLevelFactorCount" -> split["TopLevelFactorCount"],
    "PrefactorSHA256" -> split["PrefactorSHA256"],
    "SourceTermSHA256" -> split["SourceTermSHA256"],
    "SourceTermCount" -> termCount,
    "SourceTermIndices" -> Range[termCount],
    "ExceptionalPowerTermIndices" -> exceptionalIndices,
    "AlphaClass" -> 1,
    "DirectSingularLogTermIndices" -> directLogIndices,
    "PhysicalBranchLogInventory" -> branchInventory,
    "DerivedCoupledLogGroups" -> derivedGroups,
    "CoupledGroupCertificates" -> repairCertificates,
    "PoleCoefficients" -> poles,
    "FiniteCoefficients" -> repairedFinite,
    "RequiredPoleSubtraction" -> flags,
    "ExtractionMethods" -> methods,
    "MethodCounts" -> Counts[methods],
    "ReducedStrongerPoleResidual" -> reducedPoleResidual,
    "StrongerPoleOrders" -> strongerPoleOrders,
    "EndpointValue" -> dimensionalScaleFactor endpointCore,
    "EndpointValueSHA256" ->
      expressionSHA256[dimensionalScaleFactor endpointCore],
    "FormalDistributionCoefficients" ->
      actionData["FormalDistributionCoefficients"],
    "ResolvedAction" -> actionData["Action"],
    "ResolvedActionSHA256" -> actionData["ActionSHA256"]
  |>
];

processChargeTask[task_Association] := Module[
  {
    chargeKey, requestedProjectors, inputs, formalDistributions,
    preflightFlag, caught
  },
  chargeKey = task["ChargeKey"];
  requestedProjectors = task["RequestedProjectors"];
  inputs = task["Inputs"];
  formalDistributions = task["FormalDistributions"];
  preflightFlag = task["PreflightOnly"];
  caught = Catch[
    Module[{records},
      workerRequire[
        MemberQ[chargeKeys, chargeKey],
        "worker received an unknown charge key"
      ];
      workerRequire[
        DuplicateFreeQ[requestedProjectors] &&
          requestedProjectors === projectorKeys,
        "worker received an invalid projector order"
      ];
      workerRequire[
        AssociationQ[inputs] && Keys[inputs] === requestedProjectors &&
          AssociationQ[formalDistributions] &&
          Keys[formalDistributions] === requestedProjectors,
        "worker received malformed branch inputs"
      ];
      records = Association@Table[
        projectorName -> MemoryConstrained[
          processBranchCore[
            inputs[projectorName],
            formalDistributions[projectorName],
            projectorName,
            chargeKey,
            preflightFlag
          ],
          workerMemoryBudgetBytes,
          Throw[
            projectorName <> " " <> chargeKey <>
              " exceeded the worker memory budget",
            "S10WorkerFailure"
          ]
        ],
        {projectorName, requestedProjectors}
      ];
      <|
        "Success" -> True,
        "ChargeKey" -> chargeKey,
        "RequestedProjectors" -> requestedProjectors,
        "Records" -> records
      |>
    ],
    "S10WorkerFailure"
  ];
  If[
    AssociationQ[caught] && TrueQ[caught["Success"]],
    caught,
    <|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" -> ToString[InputForm[caught]]
    |>
  ]
];

launchS10Kernels[] := Module[
  {localCandidates, configuration, launched},
  closeS10Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet @ Check[#["Class"] === "LocalKernels", False] &
  ];
  assert[
    Length[localCandidates] >= 1,
    "No local Wolfram kernel configuration is available."
  ];
  configuration = ReplacePart[
    First[localCandidates],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernelCount,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ];
  assert[
    configuration["KernelCommand"] === parallelKernelExecutable &&
      configuration["KernelCount"] === requestedParallelKernelCount &&
      configuration["UseKernelForking"] === False,
    "The in-memory Engine-15 local kernel configuration is invalid."
  ];
  launched = Quiet @ Check[LaunchKernels[configuration], $Failed];
  assert[
    ListQ[launched] &&
      Length[launched] === requestedParallelKernelCount &&
      $KernelCount === requestedParallelKernelCount,
    "Failed to launch exactly three Engine-15 local kernels."
  ];
  ParallelNeeds["FeynCalc`"];
  ParallelEvaluate[$HistoryLength = 0; $FCAdvice = False;];
  workerVersions = ParallelEvaluate[$Version];
  assert[
    Length[workerVersions] === requestedParallelKernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
    "A local worker is not the verified Engine 15.0 runtime."
  ];
  parallelOrderProbe = ParallelMap[
    Identity,
    chargeKeys,
    Method -> "FinestGrained"
  ];
  assert[
    parallelOrderProbe === chargeKeys,
    "Parallel charge result ordering is not deterministic."
  ];
  DistributeDefinitions[
    workerRequire, expressionSHA256, hasExpectedScaleQ,
    invalidEndpointQ, vanishingEndpointQ, splitEndpointProjection,
    exceptionalPowerTermIndices, directSingularLogTermIndices,
    colorCanonicalize, exactPhysicalZeroQ, physicalBranchLogInventory,
    deriveCoupledGroups, branchInventoryMatchesExpectedQ,
    coupledEndpointGroupFinite, repairCoupledEndpointGroups,
    endpointInertRules, endpointActiveRules,
    endpointFactorwiseLaurent, endpointTermLaurent,
    formalDistributionCoefficients, buildDistributionAction,
    processBranchCore, processChargeTask, dimensionalScaleFactor,
    additionalMultiplicativeWeight, workerMemoryBudgetBytes,
    projectorKeys, chargeKeys, expectedSourceTermCounts,
    expectedCoupledGroups, expectedRootSourceInventories,
    s23UpperB, S09EndpointValue, S09PlusDistribution,
    S09RegularEndpointFunction, S09ExpandedKernelReference,
    S10ConvolutionTest, S10ScaleMarker, S10PhysicalA,
    S10PhysicalRT, S10EndpointLog, S10HeldLog, S10HeldPolyLog,
    S10EndpointCA, S10EndpointCF, S10EndpointFCGV,
    S10EndpointSMP
  ];
  True
];

runOrderedChargeTasks[tasks_List] := Module[{results, returnedKeys},
  Print[
    "S10_STAGE: dispatching three charge tasks across three Engine-15 kernels"
  ];
  results = Quiet @ Check[
    ParallelMap[processChargeTask, tasks, Method -> "FinestGrained"],
    $Failed
  ];
  assert[
    ListQ[results] && Length[results] === Length[tasks] &&
      And @@ (AssociationQ /@ results),
    "Parallel charge-task dispatch failed."
  ];
  assert[
    And @@ (TrueQ[#["Success"]] & /@ results),
    "A charge worker reported failure: " <>
      ToString[InputForm[Lookup[results, "Failure", None]]]
  ];
  returnedKeys = Lookup[results, "ChargeKey"];
  assert[
    returnedKeys === Lookup[tasks, "ChargeKey"] &&
      returnedKeys === chargeKeys,
    "Parallel charge results returned in the wrong key order."
  ];
  results
];

chargeTasks = Table[
  <|
    "ChargeKey" -> chargeKey,
    "RequestedProjectors" -> projectorKeys,
    "Inputs" -> Association@Table[
      projectorName -> s09Expressions[projectorName][chargeKey],
      {projectorName, projectorKeys}
    ],
    "FormalDistributions" -> Association@Table[
      projectorName ->
        formalEndpointDistributions[projectorName][chargeKey],
      {projectorName, projectorKeys}
    ],
    "PreflightOnly" -> preflightOnly
  |>,
  {chargeKey, chargeKeys}
];
assert[
  Lookup[chargeTasks, "ChargeKey"] === chargeKeys &&
    And @@ (
      Keys[#["Inputs"]] === projectorKeys &&
        Keys[#["FormalDistributions"]] === projectorKeys & /@
      chargeTasks
    ),
  "The ordered charge-task construction failed."
];

Clear[s09Expressions, s09];
ClearSystemCache[];

Print["S10_STAGE: launching the contracted three-worker calculation"];
launchS10Kernels[];
chargeResults = runOrderedChargeTasks[chargeTasks];
closeS10Kernels[];
Clear[chargeTasks];
ClearSystemCache[];

branchRecords = Association@Table[
  projectorName -> Association@Table[
    chargeKeys[[chargePosition]] ->
      chargeResults[[chargePosition]]["Records"][projectorName],
    {chargePosition, Length[chargeKeys]}
  ],
  {projectorName, projectorKeys}
];

assert[
  Keys[branchRecords] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[branchRecords]),
  "The returned branch records lost projector-first/charge-second order."
];
Clear[chargeResults];

If[
  preflightOnly,
  assert[
    AllTrue[
      allBranchValues[branchRecords],
      AssociationQ[#] && TrueQ[#["PreflightOnly"]] &&
        TrueQ[#["FormalDistributionCoefficientGatePassed"]] &&
        TrueQ[#["RepresentativeActionStructureGatePassed"]] &
    ] &&
      mapNestedAssociationValues[
        #["SourceTermCount"] &,
        branchRecords
      ] === expectedSourceTermCounts &&
      mapNestedAssociationValues[
        #["DerivedCoupledLogGroups"] &,
        branchRecords
      ] === expectedCoupledGroups &&
      AllTrue[
        allBranchValues[branchRecords],
        #["ExceptionalPowerTermIndices"] === {} &&
          #["DirectSingularLogTermIndices"] === {} &
      ] &&
      Sort @ FileNames["s10_*", scriptDirectory] ===
        preflightArtifactSnapshot,
    "The complete no-write S10 preflight failed or changed the S10 inventory."
  ];
  preflightSummaries = mapNestedAssociationValues[
    KeyTake[
      #,
      {
        "Projector", "ChargeKey", "SourceTermCount",
        "ExceptionalPowerTermIndices", "DirectSingularLogTermIndices",
        "DerivedCoupledLogGroups", "RepresentativeTermIndices",
        "RepresentativeMethodCounts",
        "FormalDistributionCoefficientGatePassed",
        "RepresentativeActionStructureGatePassed"
      }
    ] &,
    branchRecords
  ];
  Print["S10_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print[
    "S10_DYNAMIC_PREFLIGHT_SUMMARIES=",
    InputForm[preflightSummaries]
  ];
  Quit[0]
];

makeCachePayload[
    record_Association, projectorName_String, chargeKey_String
  ] := Module[
  {poleHashes, finiteHashes, checks},
  poleHashes = expressionSHA256 /@ record["PoleCoefficients"];
  finiteHashes = expressionSHA256 /@ record["FiniteCoefficients"];
  checks = <|
    "AcceptedS09FileAndExpressionHashesBound" -> True,
    "ProjectorAndChargeOrderPreserved" -> True,
    "ExactSourceTermInventoryValidated" -> True,
    "DegreeOneInheritedScaleCoreDerived" -> True,
    "AlphaOneOnlyInventoryValidated" -> True,
    "DirectSingularLogInventoryEmpty" -> True,
    "PhysicalRootInventoryValidated" -> True,
    "CoupledGroupsDerivedFromCurrentSource" -> True,
    "EveryCoupledEndpointLogCancellationProved" -> True,
    "AllSourceTermsLaurentResolved" -> True,
    "StrongerPoleAbsentThroughEpsilonOne" -> True,
    "FormalS09DistributionCoefficientsExtractedExactly" -> True,
    "DeltaAndPlusDistributionsActed" -> True,
    "ResolvedActionContainsOneSubtractedIntegral" -> True,
    "SingleInheritedScaleFactorPreserved" -> True,
    "ThreeChargeTensorsRemainSeparate" -> True,
    "UnitWeightAndFinalStateFactorPreserved" -> True,
    "NoVirtualBranchIntroduced" -> True,
    "NoFactorizationEq9OrPhysicalFlavorAssembly" -> True,
    "CalculationExactAndSymbolic" -> True
  |>;
  <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "ResultSchemaVersion" -> resultSchemaVersion,
    "Channel" -> "Hqqprime only",
    "Projector" -> projectorName,
    "ChargeKey" -> chargeKey,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperHash,
    "S09SourcePath" -> s09SourcePath,
    "S09SourceSHA256" -> expectedS09SourceHash,
    "S09ResultPath" -> s09ResultPath,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCachePath" ->
      s09CachePaths[projectorName][chargeKey],
    "S09ExpansionCacheSHA256" ->
      expectedS09CacheHashes[projectorName][chargeKey],
    "S09ExpressionSHA256" ->
      expectedS09ExpressionHashes[projectorName][chargeKey],
    "S09ExpandedLeafCount" ->
      expectedExpandedLeafCounts[projectorName][chargeKey],
    "S09ExpandedByteCount" ->
      expectedExpandedByteCounts[projectorName][chargeKey],
    "EndpointProofVersion" -> endpointProofVersion,
    "ScaleHomogeneityCertificate" ->
      record["ScaleHomogeneityCertificate"],
    "ScaleFreeExpressionSHA256" ->
      record["ScaleFreeExpressionSHA256"],
    "TopLevelFactorCount" -> record["TopLevelFactorCount"],
    "PrefactorSHA256" -> record["PrefactorSHA256"],
    "SourceTermCount" -> record["SourceTermCount"],
    "SourceTermIndices" -> record["SourceTermIndices"],
    "SourceTermSHA256" -> record["SourceTermSHA256"],
    "AlphaClass" -> record["AlphaClass"],
    "ExceptionalPowerTermIndices" ->
      record["ExceptionalPowerTermIndices"],
    "DirectSingularLogTermIndices" ->
      record["DirectSingularLogTermIndices"],
    "PhysicalBranchLogInventory" ->
      record["PhysicalBranchLogInventory"],
    "DerivedCoupledLogGroups" ->
      record["DerivedCoupledLogGroups"],
    "CoupledGroupCertificates" ->
      record["CoupledGroupCertificates"],
    "PoleCoefficientSHA256" -> poleHashes,
    "FiniteCoefficientSHA256" -> finiteHashes,
    "RequiredPoleSubtraction" ->
      record["RequiredPoleSubtraction"],
    "ExtractionMethods" -> record["ExtractionMethods"],
    "MethodCounts" -> record["MethodCounts"],
    "ReducedStrongerPoleResidual" ->
      record["ReducedStrongerPoleResidual"],
    "StrongerPoleOrders" -> record["StrongerPoleOrders"],
    "EndpointValue" -> record["EndpointValue"],
    "EndpointValueSHA256" -> record["EndpointValueSHA256"],
    "FormalDistributionCoefficients" ->
      record["FormalDistributionCoefficients"],
    "ResolvedAction" -> record["ResolvedAction"],
    "ResolvedActionSHA256" -> record["ResolvedActionSHA256"],
    "ResolvedActionLeafCount" -> LeafCount[record["ResolvedAction"]],
    "ResolvedActionByteCount" -> ByteCount[record["ResolvedAction"]],
    "AdditionalMultiplicativeWeight" ->
      additionalMultiplicativeWeight,
    "ScaleBookkeeping" -> scaleBookkeeping,
    "ChargeBookkeeping" -> chargeBookkeeping,
    "SymmetryBookkeeping" -> symmetryBookkeeping,
    "FinalStateSymmetryFactor" ->
      derivedFinalStateSymmetryFactor,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PhysicalOrderedFlavorChargeAssemblyAppliedAtS10" -> False,
    "SeparateMSBarSEpsilonAppliedAtS10" -> False,
    "NontrivialSymmetryFactorAppliedAtS10" -> False,
    "Checks" -> checks
  |>
];

cacheMetadataValidQ[
    cache_, projectorName_String, chargeKey_String
  ] := Module[{termCount, action},
  If[! AssociationQ[cache], Return[False]];
  termCount = expectedSourceTermCounts[projectorName][chargeKey];
  If[! KeyExistsQ[cache, "ResolvedAction"], Return[False]];
  action = cache["ResolvedAction"];
  cache["Status"] === "Complete" &&
    cache["Stage"] === cacheStageVersion &&
    cache["ResultSchemaVersion"] === resultSchemaVersion &&
    cache["Channel"] === "Hqqprime only" &&
    cache["Projector"] === projectorName &&
    cache["ChargeKey"] === chargeKey &&
    cache["ProgramSHA256"] === programHash &&
    cache["PaperSHA256"] === expectedPaperHash &&
    cache["S09SourceSHA256"] === expectedS09SourceHash &&
    cache["S09ResultSHA256"] === expectedS09ResultHash &&
    cache["S09ExpansionCachePath"] ===
      s09CachePaths[projectorName][chargeKey] &&
    cache["S09ExpansionCacheSHA256"] ===
      expectedS09CacheHashes[projectorName][chargeKey] &&
    cache["S09ExpressionSHA256"] ===
      expectedS09ExpressionHashes[projectorName][chargeKey] &&
    cache["S09ExpandedLeafCount"] ===
      expectedExpandedLeafCounts[projectorName][chargeKey] &&
    cache["S09ExpandedByteCount"] ===
      expectedExpandedByteCounts[projectorName][chargeKey] &&
    cache["EndpointProofVersion"] === endpointProofVersion &&
    AssociationQ[cache["ScaleHomogeneityCertificate"]] &&
    And @@ (TrueQ /@
      Values[cache["ScaleHomogeneityCertificate"]]) &&
    cache["TopLevelFactorCount"] === 11 &&
    cache["SourceTermCount"] === termCount &&
    cache["SourceTermIndices"] === Range[termCount] &&
    Length[cache["SourceTermSHA256"]] === termCount &&
    AllTrue[
      cache["SourceTermSHA256"],
      StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    cache["AlphaClass"] === 1 &&
    cache["ExceptionalPowerTermIndices"] === {} &&
    cache["DirectSingularLogTermIndices"] === {} &&
    branchInventoryMatchesExpectedQ[
      cache["PhysicalBranchLogInventory"],
      projectorName,
      chargeKey
    ] &&
    cache["DerivedCoupledLogGroups"] ===
      expectedCoupledGroups[projectorName][chargeKey] &&
    coupledCertificatesValidQ[
      cache["CoupledGroupCertificates"],
      expectedCoupledGroups[projectorName][chargeKey]
    ] &&
    Length[cache["PoleCoefficientSHA256"]] === termCount &&
    Length[cache["FiniteCoefficientSHA256"]] === termCount &&
    AllTrue[
      Join[
        cache["PoleCoefficientSHA256"],
        cache["FiniteCoefficientSHA256"]
      ],
      StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    Length[cache["RequiredPoleSubtraction"]] === termCount &&
    Length[cache["ExtractionMethods"]] === termCount &&
    And @@ (TrueQ[# === 0] & /@
      Values[cache["StrongerPoleOrders"]]) &&
    cache["EndpointValueSHA256"] ===
      expressionSHA256[cache["EndpointValue"]] &&
    cache["ResolvedActionSHA256"] === expressionSHA256[action] &&
    cache["ResolvedActionLeafCount"] === LeafCount[action] &&
    cache["ResolvedActionByteCount"] === ByteCount[action] &&
    cache["FormalDistributionCoefficients"][
      "ExactSkeletonReconstruction"
    ] === True &&
    cache["FormalDistributionCoefficients"]["PlusOrders"] ===
      Range[0, 2] &&
    cache["AdditionalMultiplicativeWeight"] === 1 &&
    cache["ScaleBookkeeping"] === scaleBookkeeping &&
    cache["ChargeBookkeeping"] === chargeBookkeeping &&
    cache["SymmetryBookkeeping"] === symmetryBookkeeping &&
    cache["FinalStateSymmetryFactor"] === 1 &&
    cache["VirtualContributionAtThisOrder"] === virtualBookkeeping &&
    cache["PhysicalOrderedFlavorChargeAssemblyAppliedAtS10"] === False &&
    cache["SeparateMSBarSEpsilonAppliedAtS10"] === False &&
    cache["NontrivialSymmetryFactorAppliedAtS10"] === False &&
    AssociationQ[cache["Checks"]] &&
    And @@ (TrueQ /@ Values[cache["Checks"]]) &&
    FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution |
        _S09RegularEndpointFunction | _S09ExpandedKernelReference |
        DiracDelta[s23] | _Real | $Failed | Indeterminate
    ] &&
    Count[action, Inactive[Integrate][___], Infinity] === 1 &&
    hasExpectedScaleQ[action] &&
    Count[
      action,
      candidate_ /; SameQ[candidate, dimensionalScaleFactor],
      Infinity
    ] === 1
];

If[
  reconstructOnly,
  Print["S10_STAGE: comparing fresh reconstruction with finalized caches"];
  Do[
    reconstructedRecord = branchRecords[projectorName][chargeKey];
    publishedCache = Quiet @ Check[
      Get[endpointCachePaths[projectorName][chargeKey]],
      $Failed
    ];
    assert[
      cacheMetadataValidQ[publishedCache, projectorName, chargeKey] &&
        publishedCache["ScaleFreeExpressionSHA256"] ===
          reconstructedRecord["ScaleFreeExpressionSHA256"] &&
        publishedCache["PrefactorSHA256"] ===
          reconstructedRecord["PrefactorSHA256"] &&
        publishedCache["SourceTermSHA256"] ===
          reconstructedRecord["SourceTermSHA256"] &&
        publishedCache["PoleCoefficientSHA256"] ===
          (expressionSHA256 /@
            reconstructedRecord["PoleCoefficients"]) &&
        publishedCache["FiniteCoefficientSHA256"] ===
          (expressionSHA256 /@
            reconstructedRecord["FiniteCoefficients"]) &&
        publishedCache["ExtractionMethods"] ===
          reconstructedRecord["ExtractionMethods"] &&
        publishedCache["CoupledGroupCertificates"] ===
          reconstructedRecord["CoupledGroupCertificates"] &&
        publishedCache["ReducedStrongerPoleResidual"] ===
          reconstructedRecord["ReducedStrongerPoleResidual"] &&
        publishedCache["EndpointValue"] ===
          reconstructedRecord["EndpointValue"] &&
        publishedCache["ResolvedAction"] ===
          reconstructedRecord["ResolvedAction"],
      projectorName <> " " <> chargeKey <>
        " fresh reconstruction differs from the finalized cache."
    ];
    Clear[reconstructedRecord, publishedCache];
    ClearSystemCache[];,
    {projectorName, projectorKeys},
    {chargeKey, chargeKeys}
  ];
  publishedResult = Quiet @ Check[Get[resultPath], $Failed];
  reconstructedCacheHashes =
    mapNestedAssociationValues[fileSHA256, endpointCachePaths];
  assert[
    AssociationQ[publishedResult] &&
      publishedResult["Status"] === "Complete" &&
      publishedResult["Stage"] === stageVersion &&
      publishedResult["ProgramSHA256"] === programHash &&
      publishedResult["ProjectorOrder"] === projectorKeys &&
      publishedResult["ChargeKeyOrder"] === chargeKeys &&
      publishedResult["InputProvenance"]["S09ResultSHA256"] ===
        expectedS09ResultHash &&
      publishedResult["CacheProvenance"]["EndpointCachePaths"] ===
        endpointCachePaths &&
      publishedResult["CacheProvenance"]["EndpointCacheSHA256"] ===
        reconstructedCacheHashes &&
      And @@ (TrueQ /@ Values[publishedResult["Checks"]]) &&
      Sort @ FileNames["s10_*", scriptDirectory] ===
        preflightArtifactSnapshot,
    "The fresh reconstruction result/provenance or no-write gate failed."
  ];
  Print["S10_FRESH_RECONSTRUCTION_SUCCESS"];
  Print[
    "S10_FRESH_RECONSTRUCTION_CACHE_SHA256=",
    InputForm[reconstructedCacheHashes]
  ];
  Quit[0]
];

Print["S10_STAGE: atomically publishing six source-bound endpoint caches"];
Do[
  cachePayload = makeCachePayload[
    branchRecords[projectorName][chargeKey],
    projectorName,
    chargeKey
  ];
  reloadedCache = atomicPutAssociation[
    cachePayload,
    endpointCachePaths[projectorName][chargeKey],
    cacheStageVersion
  ];
  assert[
    cacheMetadataValidQ[reloadedCache, projectorName, chargeKey] &&
      reloadedCache["ResolvedAction"] ===
        branchRecords[projectorName][chargeKey]["ResolvedAction"],
    "Atomic S10 cache write/reload failed for " <>
      projectorName <> " " <> chargeKey
  ];
  Clear[cachePayload, reloadedCache];
  ClearSystemCache[];,
  {projectorName, projectorKeys},
  {chargeKey, chargeKeys}
];

endpointCacheHashes =
  mapNestedAssociationValues[fileSHA256, endpointCachePaths];
assert[
  Keys[endpointCacheHashes] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[endpointCacheHashes]) &&
    AllTrue[
      allBranchValues[endpointCacheHashes],
      StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    And @@ Flatten@Table[
      endpointCacheHashes[projectorName][chargeKey] ===
        fileSHA256[endpointCachePaths[projectorName][chargeKey]],
      {projectorName, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "The finalized endpoint-cache hashes have wrong shape or disk values."
];

endpointSummaries = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> Module[{record},
      record = branchRecords[projectorName][chargeKey];
      <|
        "Projector" -> projectorName,
        "ChargeKey" -> chargeKey,
        "SourceTermCount" -> record["SourceTermCount"],
        "AlphaClass" -> record["AlphaClass"],
        "ExceptionalPowerTermIndices" ->
          record["ExceptionalPowerTermIndices"],
        "DirectSingularLogTermIndices" ->
          record["DirectSingularLogTermIndices"],
        "PhysicalRootZeroSourceTermIndices" -> <|
          "1" -> record["PhysicalBranchLogInventory"]["1"][
            "ZeroSourceTermIndices"
          ],
          "-1" -> record["PhysicalBranchLogInventory"]["-1"][
            "ZeroSourceTermIndices"
          ]
        |>,
        "PhysicalRootUnresolvedSourceTermIndices" -> <|
          "1" -> record["PhysicalBranchLogInventory"]["1"][
            "UnresolvedSourceTermIndices"
          ],
          "-1" -> record["PhysicalBranchLogInventory"]["-1"][
            "UnresolvedSourceTermIndices"
          ]
        |>,
        "DerivedCoupledLogGroups" ->
          record["DerivedCoupledLogGroups"],
        "MethodCounts" -> record["MethodCounts"],
        "StrongerPoleOrders" -> record["StrongerPoleOrders"],
        "EndpointValueSHA256" -> record["EndpointValueSHA256"],
        "ResolvedActionSHA256" -> record["ResolvedActionSHA256"],
        "EndpointCachePath" ->
          endpointCachePaths[projectorName][chargeKey],
        "EndpointCacheSHA256" ->
          endpointCacheHashes[projectorName][chargeKey]
      |>
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

s10Checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS09SourceResultAndSixCacheHashesValidated" -> True,
  "AcceptedS09ExpressionHashesAndSizesValidated" -> True,
  "AllFortyFourS09ChecksValidated" -> True,
  "FeynCalcLoadedBeforeArtifactDeserialization" -> True,
  "ProjectorFirstChargeSecondOrderPreserved" -> True,
  "SixFormalEndpointDescriptorsReceived" ->
    endpointPlaceholderCount === 6,
  "EighteenFormalPlusHeadsReceived" ->
    endpointPlusPlaceholderCount === 18,
  "ExactSixSourceTermInventoriesValidated" ->
    mapNestedAssociationValues[
      #["SourceTermCount"] &,
      branchRecords
    ] === expectedSourceTermCounts,
  "AllSixScaleCoresDerivedByDegreeOneCertificate" ->
    AllTrue[
      allBranchValues[branchRecords],
      And @@ (TrueQ /@
        Values[#["ScaleHomogeneityCertificate"]]) &
    ],
  "AllSixBranchesAreAlphaOneOnly" ->
    AllTrue[
      allBranchValues[branchRecords],
      #["AlphaClass"] === 1 &&
        #["ExceptionalPowerTermIndices"] === {} &
    ],
  "AllDirectSingularLogInventoriesEmpty" ->
    AllTrue[
      allBranchValues[branchRecords],
      #["DirectSingularLogTermIndices"] === {} &
    ],
  "PhysicalRootInventoriesValidated" ->
    And @@ Flatten@Table[
      branchInventoryMatchesExpectedQ[
        branchRecords[projectorName][chargeKey][
          "PhysicalBranchLogInventory"
        ],
        projectorName,
        chargeKey
      ],
      {projectorName, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "CoupledGroupsDerivedAndValidated" ->
    mapNestedAssociationValues[
      #["DerivedCoupledLogGroups"] &,
      branchRecords
    ] === expectedCoupledGroups,
  "AllSourceTermsResolvedWithCompleteOrderedCoverage" ->
    AllTrue[
      allBranchValues[branchRecords],
      Length[#["PoleCoefficients"]] === #["SourceTermCount"] &&
        Length[#["FiniteCoefficients"]] === #["SourceTermCount"] &&
        Length[#["ExtractionMethods"]] === #["SourceTermCount"] &&
        Length[#["RequiredPoleSubtraction"]] ===
          #["SourceTermCount"] &
    ],
  "StrongerEndpointPoleAbsentThroughFiniteRequirement" ->
    AllTrue[
      allBranchValues[branchRecords],
      And @@ (TrueQ[# === 0] & /@
        Values[#["StrongerPoleOrders"]]) &
    ],
  "FormalDistributionSkeletonsReconstructedExactly" ->
    AllTrue[
      allBranchValues[branchRecords],
      TrueQ[
        #["FormalDistributionCoefficients"][
          "ExactSkeletonReconstruction"
        ]
      ] &
    ],
  "AllSixDistributionActionsResolved" -> True,
  "FinalActionsContainNoDistributionPlaceholders" ->
    AllTrue[
      allBranchValues[branchRecords],
      FreeQ[
        #["ResolvedAction"],
        _S09EndpointValue | _S09PlusDistribution |
          _S09RegularEndpointFunction | _S09ExpandedKernelReference |
          DiracDelta[s23]
      ] &
    ],
  "FinalActionsContainOneEndpointSubtractedIntegralEach" ->
    AllTrue[
      allBranchValues[branchRecords],
      Count[
        #["ResolvedAction"],
        Inactive[Integrate][___],
        Infinity
      ] === 1 &
    ],
  "AdditionalMultiplicativeWeightIsExactlyOne" ->
    additionalMultiplicativeWeight === 1,
  "DistinctFinalStateFactorRemainsExactlyOne" ->
    derivedFinalStateSymmetryFactor === 1,
  "ThreeChargeTensorsRemainSeparateAndChargeFree" -> True,
  "PhysicalOrderedFlavorChargeAssemblyStillDeferred" -> True,
  "SingleInheritedScaleMuPowerPreserved" ->
    AllTrue[
      allBranchValues[branchRecords],
      hasExpectedScaleQ[#["ResolvedAction"]] &&
        Count[
          #["ResolvedAction"],
          candidate_ /; SameQ[candidate, dimensionalScaleFactor],
          Infinity
        ] === 1 &
    ],
  "NoExtraMSBarSEpsilonIntroduced" -> True,
  "NoVirtualBranchIntroduced" -> True,
  "ExactlyThreeEngine15ChargeWorkersUsed" ->
    Length[workerVersions] === requestedParallelKernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
  "WorkersReturnedDeterministicChargeOrder" ->
    parallelOrderProbe === chargeKeys,
  "SixAtomicSourceBoundCachesDiskHashValidated" -> True,
  "CompactResultDoesNotDuplicateResolvedActions" -> True,
  "Eq46FiniteHardPartEq9FHatAndExternalComparisonNotClaimed" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[s10Checks]),
  "At least one final S10 validation check is not True."
];

s10Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "H_{q qPrime; q qbarPrime} charge-resolved alpha-one endpoint resolution and symbolic distribution action",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "ProjectorOrder" -> projectorKeys,
  "ChargeKeyOrder" -> chargeKeys,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" ->
      "Eqs. (29)-(32), discussion after Eq. (40), and Appendix B Eqs. (B22)-(B23); Eq. (46) deferred"
  |>,
  "InputProvenance" -> <|
    "S09SourcePath" -> s09SourcePath,
    "S09SourceSHA256" -> expectedS09SourceHash,
    "S09ResultPath" -> s09ResultPath,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCachePaths" -> s09CachePaths,
    "S09ExpansionCacheSHA256" -> expectedS09CacheHashes,
    "S09ExpressionSHA256" -> expectedS09ExpressionHashes
  |>,
  "CalculationMode" ->
    "fully exact and symbolic; no numerical kinematics, PDFs, FFs, or concrete test function",
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlusHeadCountBefore" -> endpointPlusPlaceholderCount,
    "PlaceholderCountAfter" -> 0,
    "AlphaClassesPresent" -> {1},
    "Method" ->
      "degree-one scale-core extraction, exact factorwise endpoint Laurent resolution, and source-derived two-root coupled-log repair",
    "BranchSummaries" -> endpointSummaries
  |>,
  "DistributionActions" -> <|
    "CacheField" -> "ResolvedAction",
    "TestFunction" ->
      HoldForm[S10ConvolutionTest[projector, chargeKey, s23]],
    "TestFunctionAssumption" ->
      "arbitrary symbolic function regular at s23=0 and independent of epsilon",
    "EndpointDeltaConvention" ->
      "lower-endpoint delta has full weight, inherited directly from the accepted S09 bounded identity",
    "RemainingIntegralType" ->
      "one ordinary endpoint-subtracted inactive integral per projector/charge branch on 0<=s23<=B(xi)",
    "VirtualByProjectorAndCharge" ->
      mapNestedAssociationValues[0 &, expectedSourceTermCounts]
  |>,
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS10" ->
      additionalMultiplicativeWeight,
    "Scale" -> scaleBookkeeping,
    "Charge" -> chargeBookkeeping,
    "Symmetry" -> symmetryBookkeeping,
    "FinalStateSymmetryFactorAtS10" ->
      derivedFinalStateSymmetryFactor,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PhysicalOrderedFlavorChargeAssemblyAppliedAtS10" -> False,
    "SeparateMSBarSEpsilonAppliedAtS10" -> False,
    "NontrivialSymmetryFactorAppliedAtS10" -> False
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "EndpointCachePaths" -> endpointCachePaths,
    "EndpointCacheSHA256" -> endpointCacheHashes,
    "ResolvedActionField" -> "ResolvedAction",
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S09ResultSHA256" -> expectedS09ResultHash,
    "S09ExpansionCacheSHA256" -> expectedS09CacheHashes,
    "S09ExpressionSHA256" -> expectedS09ExpressionHashes,
    "AtomicSourceBoundMainWriterAndDiskHashValidated" -> True
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> Length[workerVersions],
    "WorkerVersions" -> workerVersions,
    "ChargeKeysProcessedIndependently" -> chargeKeys,
    "ProjectorsSerialWithinEachChargeWorker" -> projectorKeys,
    "DeterministicResultOrder" -> True,
    "ConcurrentCacheWrites" -> False
  |>,
  "Checks" -> s10Checks,
  "MemoryStrategy" ->
    "exactly three Engine-15 workers process one charge key each with Pg then PPP serially; workers return records and write nothing; only the main kernel atomically publishes six action caches and this compact result",
  "NotPerformedAtThisStage" -> {
    "paper Eq. (46) initial-state PDF and final-state FF subtraction/factorization",
    "claim of remaining collinear-pole cancellation before factorization",
    "epsilon -> 0 finite hard-part limit",
    "paper Eq. (9) Pg/PPP inversion or F-hat extraction",
    "physical ordered q,qPrime flavour/charge assembly",
    "external-code comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized factorization stage must load ResolvedAction only from each hash-pinned S10 cache, preserve projector-first/charge-second order and all inherited bookkeeping, and add the correct Eq. (46) counterterms before any finite-hard-part claim."
|>;

assert[
  FreeQ[s10Result, HoldPattern[Rule["ResolvedAction", _]]],
  "The compact S10 result unexpectedly duplicates a resolved action."
];

Clear[branchRecords];
ClearSystemCache[];

Print["S10_STAGE: atomically writing compact Hqqprime S10 result"];
reloadedResult = atomicPutAssociation[
  s10Result,
  resultPath,
  stageVersion
];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["ProjectorOrder"] === projectorKeys &&
    reloadedResult["ChargeKeyOrder"] === chargeKeys &&
    reloadedResult["InputProvenance"]["S09ResultSHA256"] ===
      expectedS09ResultHash &&
    reloadedResult["CacheProvenance"]["EndpointCachePaths"] ===
      endpointCachePaths &&
    reloadedResult["CacheProvenance"]["EndpointCacheSHA256"] ===
      endpointCacheHashes &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]) &&
    And @@ Flatten@Table[
      reloadedResult["CacheProvenance"]["EndpointCacheSHA256"]
          [projectorName][chargeKey] ===
        fileSHA256[endpointCachePaths[projectorName][chargeKey]],
      {projectorName, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "The final S10 result failed exact reload or disk-cache validation."
];
assert[
  Join[
    FileNames["s10_result.tmp.*", scriptDirectory],
    FileNames["s10_cache_hqqprime*.tmp.*", scriptDirectory]
  ] === {},
  "A finalized S10 temporary artifact remains."
];

Print["S10_SUCCESS"];
Print["S10_PROGRAM_SHA256=" <> programHash];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_SHA256=" <> fileSHA256[resultPath]];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CACHE_SHA256=", InputForm[endpointCacheHashes]];
Print["S10_CHECKS=", InputForm[s10Checks]];

Quit[0];

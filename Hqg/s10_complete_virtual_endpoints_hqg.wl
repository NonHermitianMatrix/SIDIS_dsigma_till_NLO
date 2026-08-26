(* ::Package:: *)

(*
  Hqg stage s10, corrected current-lineage implementation.

  This stage is fully analytic and symbolic.  It does not choose numerical
  kinematics, PDFs, fragmentation functions, or a numerical test function.

  Requested operations:
    1. Evaluate every PaVe coefficient and every scalar B0/C0/D0 master in
       the inherited one-loop virtual interference, with Package-X analytic
       continuation and separate UV/IR regulators.
    2. Insert the explicit one-loop QCD coupling and massless on-shell field
       constants.  The saved counterterm amplitudes already contain the LSZ
       external-leg coefficients, so they are removed before the explicit
       constants are inserted once through their validated LO multiplier.
    3. Verify UV cancellation and expand the virtual coefficient through the
       finite term in epsilon.
    4. Resolve the two bounded-limit S09EndpointValue placeholders by an exact
       channel-by-channel algebraic endpoint extraction.
    5. Act every endpoint delta and plus distribution on an arbitrary symbolic
       test function over 0 <= s23 <= B(xi), leaving only ordinary subtracted
       inactive integrals and no distributional placeholder.

  Eq. (46) PDF/FF collinear factorization is not part of this requested stage.
  The Package-X Laurent polynomial is retained in its evaluator convention;
  the exact paper loop-measure/Hermitian conversion is recorded for S12 and is
  not applied twice or before the finite factorized endpoint is assembled.
*)

$HistoryLength = 0;
$S10BootstrapDirectory = DirectoryName[ExpandFileName[$InputFileName]];
$S10BundledApplicationsPath = FileNameJoin[{
  $S10BootstrapDirectory,
  "Applications"
}];
If[
  DirectoryQ[$S10BundledApplicationsPath] &&
    FreeQ[$Path, $S10BundledApplicationsPath],
  PrependTo[$Path, $S10BundledApplicationsPath]
];
$LoadFeynArts = False;
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];
$FCAdvice = False;

gibibyte = 1024^3;
parallelMemoryReserveBytes = 6 gibibyte;
endpointWorkerMemoryLimitBytes = 1280 1024^2;
endpointParallelBatchTimeLimitSeconds = 900;
availableMemoryAtLaunch = Quiet@Check[MemoryAvailable[], 0];
schedulerSlotText = Environment["NSLOTS"];
schedulerSlots = If[
  StringQ[schedulerSlotText] &&
    StringMatchQ[schedulerSlotText, DigitCharacter ..],
  FromDigits[schedulerSlotText],
  Missing["NoSchedulerSlotContract"]
];
requestedParallelKernels = If[
  IntegerQ[schedulerSlots],
  Min[8, Max[0, schedulerSlots - 1]],
  Min[
    8,
    Max[
      2,
      Floor[
        Max[0, availableMemoryAtLaunch - parallelMemoryReserveBytes]/
          endpointWorkerMemoryLimitBytes
      ]
    ]
  ]
];
parallelKernelExecutable = With[
  {configured = Environment["HQG_WOLFRAM_KERNEL"]},
  If[
    StringQ[configured] && configured =!= "" && FileExistsQ[configured],
    configured,
    If[
      $VersionNumber >= 14,
      "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel",
      First[$CommandLine]
    ]
  ]
];
parallelKernelConfiguration = If[
  $VersionNumber >= 14 && Length[$ConfiguredKernels] > 0,
  ReplacePart[
    First[$ConfiguredKernels],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernels,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ],
  Missing["NativeLocalLaunch"]
];
parallelKernelCount = 0;
parallelKernelIDsSeen = {};
parallelKernelLaunchIDSetsSeen = {};
alpha2ParallelKernelIDSetsSeen = {};
endpointParallelWorkRequired = False;
Print[
  "S10_ENDPOINT_MEMORY_PLAN: availableGiB=",
  N[availableMemoryAtLaunch/gibibyte, 4],
  " reserveGiB=", N[parallelMemoryReserveBytes/gibibyte, 3],
  " perWorkerLimitGiB=",
  N[endpointWorkerMemoryLimitBytes/gibibyte, 3],
  " schedulerSlots=", InputForm[schedulerSlots],
  " requestedKernels=", requestedParallelKernels,
  " batchDeadlineSeconds=", endpointParallelBatchTimeLimitSeconds,
  " kernel=", parallelKernelExecutable
];
Print[
  "S10_MEMORY_STAGE: virtual reconstruction remains serial; bounded " <>
    "workers are launched only after completed virtual data is released"
];

ClearAll[
  fatal, assert, writeAtomic, zeroEquivalentQ, fileSHA256Hex,
  atomicReloadSameQ, resolveRecordedOrColocated,
  immutableInputIdentitiesQ, compactS10ResultValidQ,
  installMassShellAssignments,
  installScalarProductAssignments, installKinematicRecord,
  setTwoBodyKinematics,
  ensureEndpointParallelKernels, closeEndpointParallelKernels,
  endpointWorkerEvaluate,
  evaluatePaVe, obtainPaVeRules, transformTwoBodyCoefficient,
  virtualLaurentTerms, boundedLaurentPieces, partitionLaurentPieces,
  pppTerm2FactorwiseLaurent, cleanupLaurentSubpartCaches,
  laurentSubpartCachePath, laurentSubpartCachePattern,
  finiteLaurentTerm,
  finiteLaurentProjector, finiteLaurentPair,
  migrateAcceptedVirtualCache, migrateAcceptedEndpointCacheMetadata,
  invalidEndpointQ, vanishingEndpointQ,
  exceptionalPowerTermIndices, singularLogTermIndices,
  splitEndpointProjection, endpointFactorwiseLaurent,
  endpointTermLaurent, alpha2ExactAgreementQ,
  alpha2SeriesDataCoefficientAssociation,
  alpha2CoefficientChunkWorker,
  parallelAlpha2InvalidFactorEndpoint,
  structuralAlpha2EndpointData, exactPhysicalZeroQ,
  discoverCoupledEndpointGroups, seriesKnownThroughZeroQ,
  seriesMinimumPower, coupledEndpointGroupLaurent,
  loadExpansion, processProjection, S10ConvolutionTest,
  S10EndpointCA, S10EndpointCF, S10EndpointFCGV, S10EndpointSMP,
  S10PhysicalA, S10PhysicalRT, S10EndpointT, S10CommonRoot,
  S10EndpointLog, S10RootOccurrence, S10SharedFunctionOccurrence
];

fatal[message_String] := (
  Print["S10_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

ensureEndpointParallelKernels[reason_String] := Module[
  {launchResult, currentIDs},
  If[$KernelCount > 0, Quiet[CloseKernels[]]];
  ClearSystemCache[];
  assert[requestedParallelKernels > 0,
    "The scheduler or local planner allocated no endpoint workers."];
  launchResult = Quiet@Check[
    If[
      $VersionNumber < 14,
      Block[
        {$DefaultKernels = {"localhost"}},
        LaunchKernels[requestedParallelKernels]
      ],
      If[
        MissingQ[parallelKernelConfiguration],
        {},
        LaunchKernels[parallelKernelConfiguration]
      ]
    ],
    {}
  ];
  parallelKernelCount = $KernelCount;
  assert[parallelKernelCount === requestedParallelKernels,
    "Endpoint parallel launch created " <>
      ToString[parallelKernelCount] <> " of the required " <>
      ToString[requestedParallelKernels] <> " workers."];
  With[
    {applicationsPath = $S10BundledApplicationsPath},
    ParallelEvaluate[
      $HistoryLength = 0;
      If[
        DirectoryQ[applicationsPath] && FreeQ[$Path, applicationsPath],
        PrependTo[$Path, applicationsPath]
      ];
      $LoadFeynArts = False;
      $LoadAddOns = {"FeynHelpers"};
      Needs["FeynCalc`"];
      $FCAdvice = False;
    ]
  ];
  DistributeDefinitions[
    fatal, assert, invalidEndpointQ, alpha2ExactAgreementQ,
    alpha2SeriesDataCoefficientAssociation,
    alpha2CoefficientChunkWorker, endpointInertRules,
    endpointActiveRules, endpointFactorwiseLaurent,
    endpointTermLaurent, endpointWorkerEvaluate,
    endpointWorkerMemoryLimitBytes, s23, epsilon
  ];
  currentIDs = Sort[ParallelEvaluate[
    $HistoryLength = 0;
    ClearSystemCache[];
    $KernelID
  ]];
  assert[
    Length[currentIDs] === requestedParallelKernels &&
      DuplicateFreeQ[currentIDs],
    "The endpoint worker set does not contain the requested number of " <>
      "distinct kernels."];
  parallelKernelIDsSeen = currentIDs;
  AppendTo[parallelKernelLaunchIDSetsSeen, currentIDs];
  Print[
    "S10_ENDPOINT_PARALLEL_KERNELS: reason=" <> reason <>
      " count=" <> ToString[parallelKernelCount] <> " IDs=" <>
      ToString[InputForm[currentIDs]] <> " perWorkerLimitGiB=" <>
      ToString[N[endpointWorkerMemoryLimitBytes/1024.^3, 3]]
  ];
  launchResult
];

closeEndpointParallelKernels[reason_String] := Module[{},
  If[$KernelCount > 0,
    Print["S10_MEMORY_STAGE: closing endpoint workers after " <> reason];
    Quiet[CloseKernels[]]
  ];
  parallelKernelCount = 0;
  ClearSystemCache[];
];

writeAtomic[expression_, path_String] := Module[{temporaryPath},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Put[expression, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Temporary output was not written for " <> path <> "."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic output was not installed at " <> path <> "."
  ];
];

zeroEquivalentQ[expression_, seconds_Integer : 600] := Module[{answer},
  If[TrueQ[expression === 0], Return[True]];
  answer = Check[
    TimeConstrained[
      Together[Cancel[expression]],
      seconds,
      $Failed
    ],
    $Failed
  ];
  TrueQ[answer === 0]
];

fileSHA256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicReloadSameQ[expression_, path_String] := Module[{reloaded},
  reloaded = Quiet@Check[Get[path], $Failed];
  TrueQ[reloaded =!= $Failed && SameQ[reloaded, expression]]
];

resolveRecordedOrColocated[path_] := Module[{colocated},
  If[! StringQ[path], Return[Missing["InvalidRecordedPath", path]]];
  colocated = FileNameJoin[{scriptDirectory, FileNameTake[path]}];
  Which[
    FileExistsQ[path], ExpandFileName[path],
    FileExistsQ[colocated], ExpandFileName[colocated],
    True, ExpandFileName[path]
  ]
];

scriptDirectory = $S10BootstrapDirectory;
programPath = ExpandFileName[$InputFileName];
programSHA256 = fileSHA256Hex[programPath];
s09Path = FileNameJoin[{scriptDirectory, "s09_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
paperCandidates = {
  FileNameJoin[{
    scriptDirectory,
    "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
  }],
  FileNameJoin[{
    DirectoryName[scriptDirectory],
    "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
  }]
};
paperPath = SelectFirst[paperCandidates, FileExistsQ, First[paperCandidates]];
stageVersion = "HqgS10-v6";
resultSchemaVersion = 2;
preflightOnly = TrueQ[Environment["HQG_S10_PREFLIGHT_ONLY"] === "1"];
acceptedS09ProgramSHA256 =
  "f7a88a6863d90f76972b45f8c0281001d3f16e8f5da220b6c3ae977234d994d0";
acceptedS09ResultSHA256 =
  "a1f585334a749146230b1ea0f32e98df34290217798cc8293bbfdbc9ec2b6624";
acceptedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
paVeCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v2_virtual_pax_rules"
}];
scalarMasterCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v2_virtual_scalar_rules"
}];
laurentCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v2_virtual_laurent"
}];
laurentProgressCachePath[projector_String] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v2_virtual_laurent_progress_" <> ToLowerCase[projector]
}];
laurentSubtermCachePath[projector_String, index_Integer] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v2_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index]
}];
laurentSubpartCachePath[
    projector_String, index_Integer, subindex_Integer, partindex_Integer
  ] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v2_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index] <> "_subterm_" <> ToString[subindex] <>
    "_part_" <> IntegerString[partindex, 10, 3]
}];
laurentSubpartCachePattern[
    projector_String, index_Integer, subindex_Integer
  ] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v2_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index] <> "_subterm_" <> ToString[subindex] <>
    "_part_*"
}];
paVeCacheVersion = 2;
scalarMasterCacheVersion = 2;
laurentCacheVersion = 2;
laurentProgressCacheVersion = 2;
laurentSubtermCacheVersion = 2;
laurentSubpartCacheVersion = 2;
pppLaurentPartLeafBudget = 1000000;
pppLaurentPartHardLeafLimit = 2500000;
endpointCacheVersion = 14;
coupledEndpointRepairVersion = 9;
coupledGroupSeriesEvaluatorVersion = 10;
alpha2EndpointConstructionVersion = 2;
acceptedLegacyVirtualProgramSHA256 =
  "238ebcf663b4ba9f7b3ad36d6137850b9237212f4803f58c6e54d856b3a340f4";
acceptedLegacyVirtualCacheSHA256ByName = <|
  "s10_cache_v2_virtual_pax_rules" ->
    "60e4e280bcd833acf653613664aa19727f225a5db0e7a8e018939f66c0773b8f",
  "s10_cache_v2_virtual_scalar_rules" ->
    "2ff61fb658d347f47b093b6a8f50f789a7cb5dfa3a4e09383ac32615954c437b",
  "s10_cache_v2_virtual_laurent" ->
    "73e57a95016d73655f91166c47a0d5e52f0c3cc879f428c07327fd89bfea4a3b"
|>;
acceptedFirstMigrationVirtualProgramSHA256 =
  "a5fbed83c006ef40b94224a8b86785813f765c6024b57f354db38f1ce84ede2c";
acceptedFirstMigrationVirtualCacheSHA256ByName = <|
  "s10_cache_v2_virtual_pax_rules" ->
    "5cea57973979562820ce3522585265a09fe9fc99620e6aedff3a7129925ffa1f",
  "s10_cache_v2_virtual_scalar_rules" ->
    "1a85ce5e1ec0ed9bc60343353445546f99a1fefce2e8b9d53f9057fe769b2b78",
  "s10_cache_v2_virtual_laurent" ->
    "eacc384e773d6b069bab6ba1d20712023416e2e34bb70cf7fdd7066c3638697c"
|>;
acceptedSecondMigrationVirtualProgramSHA256 =
  "db7a88decaf2352d412b8cedb0b1219e92c84528b06acd78a4bcfd8bc55177b8";
acceptedSecondMigrationVirtualCacheSHA256ByName = <|
  "s10_cache_v2_virtual_pax_rules" ->
    "1864b732643310a247b88eb119ba7354a13adf0e85cb80954b7c9ee0e047509b",
  "s10_cache_v2_virtual_scalar_rules" ->
    "9ea773df0fb3b86dfa9b6474aaa8dc7795cb19d98ea050035af99f3a2870d774",
  "s10_cache_v2_virtual_laurent" ->
    "c5cfe5dabb96e88deadf9790699cbea2c2e2aec8d89a6dbb674e84c19b3bd911"
|>;
acceptedThirdMigrationVirtualProgramSHA256 =
  "897f28aad15069992e2c98f780ed31aef9d3e92cda3cdf23a811c987239bd734";
acceptedThirdMigrationVirtualCacheSHA256ByName = <|
  "s10_cache_v2_virtual_pax_rules" ->
    "fd041bbaec122f3b032461be3f417eda41b21ea89bb0ea670cdbcf1a50fd4968",
  "s10_cache_v2_virtual_scalar_rules" ->
    "1bdf75464a1f0b6b705109728a2475c5fe67378f324151d4c9bd56c6fc4b7940",
  "s10_cache_v2_virtual_laurent" ->
    "e2692af9f27441af720e52c1b81c432bf6aa62ff88c4e8a017e51ef64e80133d"
|>;
acceptedFourthMigrationVirtualProgramSHA256 =
  "ea92ac48df30d1292463a03ee6f36fd6d4b80cc3881aabc2c32255004fe665b8";
acceptedFourthMigrationVirtualCacheSHA256ByName = <|
  "s10_cache_v2_virtual_pax_rules" ->
    "cbd17459c7ddf1b782f0047a481831be404cdc86d98c94b38d98f07eb31d02cf",
  "s10_cache_v2_virtual_scalar_rules" ->
    "94229575151abb56a059cfd1e797318fd25974a7087adb75f820aec0d81a5f98",
  "s10_cache_v2_virtual_laurent" ->
    "b0d8e18a9af40c09d62e511c2bc0c9db27ffcf719560cb783770625af8f1c2e2"
|>;
virtualCacheMigrationRecords = <||>;
acceptedEndpointMetadataCorrectionProgramSHA256 =
  "ea92ac48df30d1292463a03ee6f36fd6d4b80cc3881aabc2c32255004fe665b8";
acceptedEndpointMetadataCorrectionCacheSHA256ByProjector = <|
  "Pg" ->
    "8d6e117c53d489bf46ee4b9e0388f70295b1cfee77252c70e3f1d17e034c104c"
|>;
endpointCacheMetadataMigrationRecords = <||>;
acceptedAlpha2InvalidFactorEndpointSHA256HexByProjector = <|
  "Pg" -> {
    "7e469c3695147752a91c50630fb855149d5b7e355839079c1884ffddd9d0b5ae"
  }
|>;
projectors = {"Pg", "PPP"};
endpointParallelBatchTimeoutCountByProjector = AssociationMap[0 &, projectors];
endpointSerialFallbackSourceIndices = AssociationMap[{} &, projectors];
endpointCachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_v14_endpoint_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_v14_endpoint_pp"}]
|>;

migrateAcceptedVirtualCache[
    cache_String, expectedVersion_Integer, expectedType_String
  ] := Module[
  {
    cacheName, acceptedDiskSHA256, acceptedFirstMigrationDiskSHA256,
    acceptedSecondMigrationDiskSHA256, acceptedThirdMigrationDiskSHA256,
    acceptedFourthMigrationDiskSHA256, diskSHA256Before, payload,
    migrationSourceProgramSHA256,
    migrationSourceGate, typeGate, migrationMetadataKeys,
    dependencyMetadataUpdates, mathematicalPayloadBefore, migratedPayload,
    reloadedPayload, diskSHA256After, dependencyMetadataGate
  },
  If[! FileExistsQ[cache], Return[False]];
  cacheName = FileNameTake[cache];
  acceptedDiskSHA256 = Lookup[
    acceptedLegacyVirtualCacheSHA256ByName,
    cacheName,
    Missing["NoAcceptedLegacyCache"]
  ];
  acceptedFirstMigrationDiskSHA256 = Lookup[
    acceptedFirstMigrationVirtualCacheSHA256ByName,
    cacheName,
    Missing["NoAcceptedFirstMigrationCache"]
  ];
  acceptedSecondMigrationDiskSHA256 = Lookup[
    acceptedSecondMigrationVirtualCacheSHA256ByName,
    cacheName,
    Missing["NoAcceptedSecondMigrationCache"]
  ];
  acceptedThirdMigrationDiskSHA256 = Lookup[
    acceptedThirdMigrationVirtualCacheSHA256ByName,
    cacheName,
    Missing["NoAcceptedThirdMigrationCache"]
  ];
  acceptedFourthMigrationDiskSHA256 = Lookup[
    acceptedFourthMigrationVirtualCacheSHA256ByName,
    cacheName,
    Missing["NoAcceptedFourthMigrationCache"]
  ];
  payload = Quiet@Check[Get[cache], $Failed];
  assert[AssociationQ[payload],
    "The existing virtual cache " <> cacheName <> " is unreadable."];
  If[Lookup[payload, "ProgramSHA256", Missing[]] === programSHA256,
    Return[False]
  ];
  diskSHA256Before = fileSHA256Hex[cache];
  migrationSourceProgramSHA256 = Lookup[
    payload, "ProgramSHA256", Missing[]
  ];
  migrationSourceGate = TrueQ[
    (
      diskSHA256Before === acceptedDiskSHA256 &&
        migrationSourceProgramSHA256 ===
          acceptedLegacyVirtualProgramSHA256
    ) || (
      diskSHA256Before === acceptedFirstMigrationDiskSHA256 &&
        migrationSourceProgramSHA256 ===
          acceptedFirstMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigratedFromProgramSHA256", Missing[]] ===
          acceptedLegacyVirtualProgramSHA256 &&
        Lookup[payload, "MigrationSourceCacheSHA256", Missing[]] ===
          acceptedDiskSHA256
    ) || (
      diskSHA256Before === acceptedSecondMigrationDiskSHA256 &&
        migrationSourceProgramSHA256 ===
          acceptedSecondMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigratedFromProgramSHA256", Missing[]] ===
          acceptedFirstMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigrationSourceCacheSHA256", Missing[]] ===
          acceptedFirstMigrationDiskSHA256 &&
        Lookup[payload, "OriginalAcceptedProgramSHA256", Missing[]] ===
          acceptedLegacyVirtualProgramSHA256 &&
        Lookup[payload, "OriginalAcceptedCacheSHA256", Missing[]] ===
          acceptedDiskSHA256
    ) || (
      diskSHA256Before === acceptedThirdMigrationDiskSHA256 &&
        migrationSourceProgramSHA256 ===
          acceptedThirdMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigratedFromProgramSHA256", Missing[]] ===
          acceptedSecondMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigrationSourceCacheSHA256", Missing[]] ===
          acceptedSecondMigrationDiskSHA256 &&
        Lookup[payload, "OriginalAcceptedProgramSHA256", Missing[]] ===
          acceptedLegacyVirtualProgramSHA256 &&
        Lookup[payload, "OriginalAcceptedCacheSHA256", Missing[]] ===
          acceptedDiskSHA256
    ) || (
      diskSHA256Before === acceptedFourthMigrationDiskSHA256 &&
        migrationSourceProgramSHA256 ===
          acceptedFourthMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigratedFromProgramSHA256", Missing[]] ===
          acceptedThirdMigrationVirtualProgramSHA256 &&
        Lookup[payload, "MigrationSourceCacheSHA256", Missing[]] ===
          acceptedThirdMigrationDiskSHA256 &&
        Lookup[payload, "OriginalAcceptedProgramSHA256", Missing[]] ===
          acceptedLegacyVirtualProgramSHA256 &&
        Lookup[payload, "OriginalAcceptedCacheSHA256", Missing[]] ===
          acceptedDiskSHA256
    )
  ];
  assert[
    ! MissingQ[acceptedDiskSHA256] &&
      ! MissingQ[acceptedFirstMigrationDiskSHA256] &&
      ! MissingQ[acceptedSecondMigrationDiskSHA256] &&
      ! MissingQ[acceptedThirdMigrationDiskSHA256] &&
      ! MissingQ[acceptedFourthMigrationDiskSHA256] &&
      migrationSourceGate &&
      Lookup[payload, "StageVersion", Missing[]] === stageVersion &&
      Lookup[payload, "CacheVersion", Missing[]] === expectedVersion &&
      Lookup[payload, "SourceS09SHA256", Missing[]] === s09SHA256 &&
      Lookup[payload, "SourceS08SHA256", Missing[]] === s08SHA256 &&
      Lookup[payload, "SourceS07SHA256", Missing[]] === s07SHA256,
    "The legacy virtual cache " <> cacheName <>
      " does not match the exact accepted migration lineage."
  ];
  typeGate = Which[
    expectedType === "PaVe" || expectedType === "scalar master",
      Lookup[payload, "IntegralType", Missing[]] === expectedType &&
        ListQ[Lookup[payload, "Integrals", Missing[]]] &&
        ListQ[Lookup[payload, "Values", Missing[]]] &&
        Length[payload["Integrals"]] === Length[payload["Values"]],
    expectedType === "virtual Laurent",
      AssociationQ[Lookup[payload, "LaurentThroughFinite", Missing[]]] &&
        Sort[Keys[payload["LaurentThroughFinite"]]] === Sort[projectors] &&
        AllTrue[
          Values[payload["LaurentThroughFinite"]],
          # =!= $Failed && # =!= 0 &
        ],
    True,
      False
  ];
  assert[typeGate,
    "The legacy virtual cache " <> cacheName <>
      " fails its type-specific mathematical payload gate."];
  migrationMetadataKeys = {
    "Program", "ProgramSHA256", "MigratedFromProgramSHA256",
    "MigrationSourceCacheSHA256", "OriginalAcceptedProgramSHA256",
    "OriginalAcceptedCacheSHA256"
  };
  dependencyMetadataUpdates = <||>;
  If[expectedType === "virtual Laurent",
    migrationMetadataKeys = Join[
      migrationMetadataKeys,
      {
        "PaVeCache", "PaVeCacheSHA256", "ScalarMasterCache",
        "ScalarMasterCacheSHA256"
      }
    ];
    dependencyMetadataUpdates = <|
      "PaVeCache" -> paVeCachePath,
      "PaVeCacheSHA256" -> fileSHA256Hex[paVeCachePath],
      "ScalarMasterCache" -> scalarMasterCachePath,
      "ScalarMasterCacheSHA256" ->
        fileSHA256Hex[scalarMasterCachePath]
|>
  ];
  mathematicalPayloadBefore = KeyDrop[
    payload,
    migrationMetadataKeys
  ];
  migratedPayload = Join[
    payload,
    <|
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "MigratedFromProgramSHA256" ->
        migrationSourceProgramSHA256,
      "MigrationSourceCacheSHA256" -> diskSHA256Before,
      "OriginalAcceptedProgramSHA256" ->
        acceptedLegacyVirtualProgramSHA256,
      "OriginalAcceptedCacheSHA256" -> acceptedDiskSHA256
    |>,
    dependencyMetadataUpdates
  ];
  writeAtomic[migratedPayload, cache];
  reloadedPayload = Quiet@Check[Get[cache], $Failed];
  diskSHA256After = fileSHA256Hex[cache];
  dependencyMetadataGate = TrueQ[
    expectedType =!= "virtual Laurent" || (
      reloadedPayload["PaVeCache"] === paVeCachePath &&
        reloadedPayload["PaVeCacheSHA256"] ===
          fileSHA256Hex[paVeCachePath] &&
        reloadedPayload["ScalarMasterCache"] === scalarMasterCachePath &&
        reloadedPayload["ScalarMasterCacheSHA256"] ===
          fileSHA256Hex[scalarMasterCachePath]
    )
  ];
  assert[
    AssociationQ[reloadedPayload] &&
      reloadedPayload["ProgramSHA256"] === programSHA256 &&
      reloadedPayload["MigratedFromProgramSHA256"] ===
        migrationSourceProgramSHA256 &&
      reloadedPayload["MigrationSourceCacheSHA256"] ===
        diskSHA256Before &&
      reloadedPayload["OriginalAcceptedProgramSHA256"] ===
        acceptedLegacyVirtualProgramSHA256 &&
      reloadedPayload["OriginalAcceptedCacheSHA256"] ===
        acceptedDiskSHA256 &&
      dependencyMetadataGate &&
      SameQ[
        KeyDrop[reloadedPayload, migrationMetadataKeys],
        mathematicalPayloadBefore
      ],
    "The virtual cache migration changed mathematical content for " <>
      cacheName <> "."
  ];
  AssociateTo[
    virtualCacheMigrationRecords,
    cacheName -> <|
      "Migrated" -> True,
      "CacheType" -> expectedType,
      "SourceProgramSHA256" -> migrationSourceProgramSHA256,
      "SourceCacheSHA256" -> diskSHA256Before,
      "OriginalAcceptedProgramSHA256" ->
        acceptedLegacyVirtualProgramSHA256,
      "OriginalAcceptedCacheSHA256" -> acceptedDiskSHA256,
      "MigratedCacheSHA256" -> diskSHA256After,
      "MathematicalPayloadUnchanged" -> True,
      "DependencyMetadataRefreshed" ->
        TrueQ[expectedType === "virtual Laurent" && dependencyMetadataGate]
    |>
  ];
  Print[
    "S10_VIRTUAL_CACHE_MIGRATED: cache=", cacheName,
    " sourceSHA256=", diskSHA256Before,
    " migratedSHA256=", diskSHA256After
  ];
  True
];

migrateAcceptedEndpointCacheMetadata[
    projector_String, cache_String, standardTermCount_Integer,
    groups_List, groupedPositions_List
  ] := Module[
  {
    acceptedDiskSHA256, diskSHA256Before, payload, groupSourceIndices,
    expectedAbsorbedCount, methods, migrationMetadataKeys,
    mathematicalPayloadBefore, migratedPayload, reloadedPayload,
    diskSHA256After
  },
  If[! FileExistsQ[cache], Return[False]];
  payload = Quiet@Check[Get[cache], $Failed];
  assert[AssociationQ[payload],
    "The existing endpoint cache for " <> projector <> " is unreadable."];
  If[Lookup[payload, "ProgramSHA256", Missing[]] === programSHA256,
    Return[False]
  ];
  acceptedDiskSHA256 = Lookup[
    acceptedEndpointMetadataCorrectionCacheSHA256ByProjector,
    projector,
    Missing["NoAcceptedEndpointMetadataCorrectionCache"]
  ];
  diskSHA256Before = fileSHA256Hex[cache];
  groupSourceIndices = Lookup[groups, "SourceIndices", Missing[]];
  assert[
    ListQ[groupSourceIndices] &&
      AllTrue[groupSourceIndices, ListQ] &&
      Length[groupSourceIndices] === Length[groups],
    projector <> " endpoint groups lack exact source-index lists."
  ];
  expectedAbsorbedCount =
    Total[Length /@ groupSourceIndices] - Length[groups];
  methods = Lookup[payload, "Methods", Missing[]];
  assert[
    ! MissingQ[acceptedDiskSHA256] &&
      diskSHA256Before === acceptedDiskSHA256 &&
      Lookup[payload, "ProgramSHA256", Missing[]] ===
        acceptedEndpointMetadataCorrectionProgramSHA256 &&
      Lookup[payload, "CacheVersion", Missing[]] === endpointCacheVersion &&
      Lookup[payload, "StageVersion", Missing[]] === stageVersion &&
      Lookup[payload, "SourceS09SHA256", Missing[]] === s09SHA256 &&
      Lookup[payload, "SourceS08SHA256", Missing[]] === s08SHA256 &&
      Lookup[payload, "SourceS07SHA256", Missing[]] === s07SHA256 &&
      Lookup[payload, "PaperSHA256", Missing[]] === referencePDFSHA256 &&
      Lookup[payload, "Projector", Missing[]] === projector &&
      Lookup[payload, "SourceExpansionSHA256", Missing[]] ===
        expansionCacheSHA256[projector] &&
      Lookup[payload, "CoupledLogEndpointGroups", Missing[]] === groups &&
      TrueQ[Lookup[payload, "GroupedBeforeIndividualLaurent", False]] &&
      TrueQ[Lookup[payload, "CoupledLogEndpointRepairApplied", False]] &&
      AssociationQ[Lookup[
        payload, "PreIndividualGroupAnswers", Missing[]
      ]] &&
      Sort[Keys[payload["PreIndividualGroupAnswers"]]] ===
        groupedPositions &&
      ListQ[Lookup[payload, "CoupledGroupCertificates", Missing[]]] &&
      Length[payload["CoupledGroupCertificates"]] === Length[groups] &&
      ListQ[methods] && Length[methods] === standardTermCount &&
      Lookup[payload, "CompletedStandardTermCount", Missing[]] ===
        standardTermCount &&
      Length[Lookup[payload, "PoleCoefficients", {}]] ===
        standardTermCount &&
      Length[Lookup[payload, "FiniteCoefficients", {}]] ===
        standardTermCount &&
      Length[Lookup[payload, "RequiredPoleSubtraction", {}]] ===
        standardTermCount &&
      Count[methods, "physical-branch grouped Laurent"] ===
        Length[groups] &&
      Count[
        methods,
        "absorbed into pre-individual physical-branch group"
      ] === expectedAbsorbedCount,
    "The endpoint cache for " <> projector <>
      " does not match the exact accepted metadata-correction lineage."
  ];
  migrationMetadataKeys = {
    "Program", "ProgramSHA256", "MigratedFromProgramSHA256",
    "MigrationSourceCacheSHA256", "OriginalAcceptedProgramSHA256",
    "OriginalAcceptedCacheSHA256"
  };
  mathematicalPayloadBefore = KeyDrop[payload, migrationMetadataKeys];
  migratedPayload = Join[
    payload,
    <|
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "MigratedFromProgramSHA256" ->
        acceptedEndpointMetadataCorrectionProgramSHA256,
      "MigrationSourceCacheSHA256" -> diskSHA256Before,
      "OriginalAcceptedProgramSHA256" ->
        acceptedEndpointMetadataCorrectionProgramSHA256,
      "OriginalAcceptedCacheSHA256" -> acceptedDiskSHA256
    |>
  ];
  writeAtomic[migratedPayload, cache];
  reloadedPayload = Quiet@Check[Get[cache], $Failed];
  diskSHA256After = fileSHA256Hex[cache];
  assert[
    AssociationQ[reloadedPayload] &&
      reloadedPayload["Program"] === programPath &&
      reloadedPayload["ProgramSHA256"] === programSHA256 &&
      reloadedPayload["MigratedFromProgramSHA256"] ===
        acceptedEndpointMetadataCorrectionProgramSHA256 &&
      reloadedPayload["MigrationSourceCacheSHA256"] ===
        diskSHA256Before &&
      reloadedPayload["OriginalAcceptedProgramSHA256"] ===
        acceptedEndpointMetadataCorrectionProgramSHA256 &&
      reloadedPayload["OriginalAcceptedCacheSHA256"] ===
        acceptedDiskSHA256 &&
      SameQ[
        KeyDrop[reloadedPayload, migrationMetadataKeys],
        mathematicalPayloadBefore
      ],
    "The endpoint cache metadata migration changed mathematical content " <>
      "for " <> projector <> "."
  ];
  AssociateTo[
    endpointCacheMetadataMigrationRecords,
    projector -> <|
      "Migrated" -> True,
      "Projector" -> projector,
      "SourceProgramSHA256" ->
        acceptedEndpointMetadataCorrectionProgramSHA256,
      "SourceCacheSHA256" -> diskSHA256Before,
      "OriginalAcceptedProgramSHA256" ->
        acceptedEndpointMetadataCorrectionProgramSHA256,
      "OriginalAcceptedCacheSHA256" -> acceptedDiskSHA256,
      "MigratedCacheSHA256" -> diskSHA256After,
      "MathematicalPayloadUnchanged" -> True
    |>
  ];
  Print[
    "S10_ENDPOINT_CACHE_METADATA_MIGRATED: projector=", projector,
    " sourceSHA256=", diskSHA256Before,
    " migratedSHA256=", diskSHA256After
  ];
  True
];

Print["S10_STAGE: loading and validating s09, s08, and s07 inputs"];
assert[FileExistsQ[s09Path], "s09_result does not exist."];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09], "s09_result did not load as an Association."];
s09SHA256 = fileSHA256Hex[s09Path];
s09IdentityGate = TrueQ[
  s09["Status"] === "Complete" &&
    s09["Stage"] === "HqgS09-v5" &&
    s09["ResultSchemaVersion"] === 2 &&
    s09["Channel"] === "Hqg only" &&
    s09SHA256 === acceptedS09ResultSHA256
];
assert[s09IdentityGate,
  "s09_result is not the validated Hqg S09 artifact."
];
s09ChecksGate = AssociationQ[s09["Checks"]] &&
  AllTrue[Values[s09["Checks"]], TrueQ];
assert[s09ChecksGate,
  "At least one s09 validation check is not True."];
s09ProgramRecordedPath = s09["ProgramPath"];
s09ProgramPath = resolveRecordedOrColocated[s09ProgramRecordedPath];
s09ProgramSHA256 = s09["ProgramSHA256"];
s09ProgramGate = TrueQ[
  FileExistsQ[s09ProgramPath] &&
    s09ProgramSHA256 === acceptedS09ProgramSHA256 &&
    s09ProgramSHA256 === fileSHA256Hex[s09ProgramPath]
];
assert[s09ProgramGate, "The accepted S09 source binding is stale."];

s08RecordedPath = s09["InputProvenance", "S08ResultPath"];
s08Path = resolveRecordedOrColocated[s08RecordedPath];
assert[FileExistsQ[s08Path], "The s08 source result recorded by s09 is absent."];
s08 = Check[Get[s08Path], $Failed];
s08SHA256 = fileSHA256Hex[s08Path];
s08IdentityGate = TrueQ[
  AssociationQ[s08] && s08["Status"] === "Complete" &&
    s08["Stage"] === "HqgS08-v5" && s08["Channel"] === "Hqg only" &&
    s08SHA256 === s09["InputProvenance", "S08ResultSHA256"]
];
assert[s08IdentityGate,
  "s08_result is absent, invalid, or incomplete."];
s08ChecksGate = AssociationQ[s08["Checks"]] &&
  AllTrue[Values[s08["Checks"]], TrueQ];
assert[s08ChecksGate,
  "At least one s08 validation check is not True."];
s08ProgramRecordedPath = s09["InputProvenance", "S08SourcePath"];
s08ProgramPath = resolveRecordedOrColocated[s08ProgramRecordedPath];
s08ProgramSHA256 = s09["InputProvenance", "S08SourceSHA256"];
s08ProgramGate = TrueQ[
  s08["Program"] === s08ProgramRecordedPath &&
    s08["ProgramSHA256Hex"] === s08ProgramSHA256 &&
    FileExistsQ[s08ProgramPath] &&
    fileSHA256Hex[s08ProgramPath] === s08ProgramSHA256
];
assert[s08ProgramGate,
  "An S08 source/program binding is stale."
];

s07RecordedPath = s09["InputProvenance", "S07ResultPath"];
s07Path = resolveRecordedOrColocated[s07RecordedPath];
assert[FileExistsQ[s07Path], "The s07 source result recorded by s08 is absent."];
s07 = Check[Get[s07Path], $Failed];
s07SHA256 = fileSHA256Hex[s07Path];
s07IdentityGate = TrueQ[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v5" && s07["Channel"] === "Hqg only" &&
    s07SHA256 === s09["InputProvenance", "S07ResultSHA256"] &&
    s08["SourceResult"] === s07RecordedPath &&
    s08["SourceResultSHA256Hex"] === s07SHA256
];
assert[s07IdentityGate,
  "s07_result is absent, invalid, or incomplete."];
s07ChecksGate = AssociationQ[s07["Checks"]] &&
  AllTrue[Values[s07["Checks"]], TrueQ];
assert[s07ChecksGate,
  "At least one s07 validation check is not True."];
s07ProgramRecordedPath = s09["InputProvenance", "S07SourcePath"];
s07ProgramPath = resolveRecordedOrColocated[s07ProgramRecordedPath];
s07ProgramSHA256 = s09["InputProvenance", "S07SourceSHA256"];
s07ProgramGate = TrueQ[
  s07["Program"] === s07ProgramRecordedPath &&
    s07["ProgramSHA256Hex"] === s07ProgramSHA256 &&
    FileExistsQ[s07ProgramPath] &&
    fileSHA256Hex[s07ProgramPath] === s07ProgramSHA256 &&
    s08["SourceProgram"] === s07ProgramRecordedPath &&
    s08["SourceProgramSHA256Hex"] === s07ProgramSHA256
];
assert[s07ProgramGate,
  "An S07 source/program binding is stale."
];
assert[FileExistsQ[paperPath], "The reference paper is absent."];
recordedPaperPath = s09["PaperReference", "Path"];
referencePDFSHA256 = fileSHA256Hex[paperPath];
paperBindingGate = TrueQ[
  FileExistsQ[paperPath] && referencePDFSHA256 === acceptedPaperSHA256 &&
    StringQ[recordedPaperPath] &&
    FileNameTake[recordedPaperPath] === FileNameTake[paperPath] &&
    s09["PaperReference", "SHA256"] === referencePDFSHA256 &&
    IntegerString[s08["ReferencePDFSHA256"], 16, 64] ===
      referencePDFSHA256 &&
    IntegerString[s07["ReferencePDFSHA256"], 16, 64] ===
      referencePDFSHA256
];
assert[paperBindingGate,
  "The S07-S09 paper binding is stale or inconsistent."
];
chargeBookkeeping = s09["Bookkeeping", "Charge"];
electricChargeNormalization =
  chargeBookkeeping["ElectricChargeNormalization"];
bigTMDConvention = chargeBookkeeping["BigTMDConvention"];
bigTMDProjectorMapping = chargeBookkeeping["BigTMDProjectorMapping"];
fragmentingParton = chargeBookkeeping["FragmentingParton"];
initialStateBookkeeping = s09["Bookkeeping", "InitialState"];
dimensionalBookkeeping = s09["Bookkeeping", "Dimensional"];
chargeBookkeepingGate = TrueQ[
  bigTMDConvention["ChannelNumber"] === 3 &&
    bigTMDConvention["ChargeCase"] === "A only" &&
    bigTMDProjectorMapping["Pg"] === "NLO.Pg.fchn3A" &&
    bigTMDProjectorMapping["PPP"] === "NLO.Ppp.fchn3A" &&
    AssociationQ[electricChargeNormalization] &&
    electricChargeNormalization["ReferenceCharge"] ===
      Lookup[
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
    ] === "Sum_q e_q^2 f_q D_g" &&
    fragmentingParton === "gluon g(k1)" &&
    electricChargeNormalization === s08["ElectricChargeNormalization"] &&
    electricChargeNormalization === s07["ElectricChargeNormalization"]
];
assert[chargeBookkeepingGate,
  "The S09 BigTMD/charge/fragmentation convention is invalid."
];

virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];
loInput = s07["ScalarProjections", "LO_OAlphaS"];
loReference = s08[
  "XiS23ConvolutionKernels", "TwoBody", "LO_OAlphaS"
];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicRules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["Jacobian_dXi_dZeta_to_dXi_dS23"];
s23UpperB = changeOfVariables["S23UpperB"];
recordedExpansionCachePaths = s09["ExpandedKernelCaches", "Paths"];
expansionCachePaths = AssociationMap[
  resolveRecordedOrColocated[recordedExpansionCachePaths[#]] &,
  projectors
];
recordedExpansionCacheSHA256 = s09["ExpandedKernelCaches", "SHA256"];
assert[
  AssociationQ[recordedExpansionCachePaths] &&
    Sort[Keys[recordedExpansionCachePaths]] === Sort[projectors] &&
    AssociationQ[expansionCachePaths] &&
    Sort[Keys[expansionCachePaths]] === Sort[projectors] &&
    AllTrue[Values[expansionCachePaths], FileExistsQ],
  "S09 does not provide both expansion caches."
];
expansionCacheSHA256 = AssociationMap[
  fileSHA256Hex[expansionCachePaths[#]] &,
  projectors
];
expansionCacheDiskHashGate = TrueQ[
  expansionCacheSHA256 === recordedExpansionCacheSHA256
];
assert[expansionCacheDiskHashGate,
  "An S09 expansion-cache disk hash is stale."];
formalEndpointDistributions =
  s09["EndpointExpansion", "FormalDistributionByProjector"];
endpointPlaceholderCountsByProjector = AssociationMap[
  Count[formalEndpointDistributions[#], _S09EndpointValue, Infinity] &,
  projectors
];
endpointPlaceholderCount = Total[Values[endpointPlaceholderCountsByProjector]];
assert[
  Sort[Keys[formalEndpointDistributions]] === Sort[projectors] &&
    AllTrue[Values[endpointPlaceholderCountsByProjector], TrueQ[# > 0] &],
  "The accepted S09 formal endpoint handoff is incomplete."
];
hardKernelWeight =
  s09["Bookkeeping", "AdditionalMultiplicativeWeightAtS09"];
assert[hardKernelWeight === 1,
  "The S09 Hqg hard-kernel weight is not unity."];
flavorChargeWeight = hardKernelWeight;
expandedKernelCacheStageVersion =
  s09["ExpandedKernelCaches", "StageVersion"];
measuredScalePowersByProjector =
  s09["Bookkeeping", "MeasuredScalePowersByProjector"];
loAndVirtualReferenceExpressionSHA256 =
  s09["Bookkeeping", "LOAndVirtualReferenceExpressionSHA256"];
physicalFlavorChargeWeightAppliedAtS09 =
  s09["Bookkeeping", "PhysicalFlavorChargeWeightAppliedAtS09"];

assert[Sort[Keys[virtualInput]] === Sort[projectors],
  "The s07 virtual input lacks Pg or PPP."];
assert[Sort[Keys[loInput]] === Sort[projectors],
  "The s07 LO input lacks Pg or PPP."];
assert[Sort[Keys[loReference]] === Sort[projectors],
  "The accepted S08 transformed LO reference lacks Pg or PPP."];
s07InputContentSHA256 = <|
  "LO" -> Hash[loInput, "SHA256"],
  "VirtualInterference" -> Hash[virtualInput, "SHA256"]
|>;
s07InputContentHashGate = TrueQ[
  s07InputContentSHA256["LO"] ===
      s08["InputContentSHA256", "LO"] &&
    s07InputContentSHA256["VirtualInterference"] ===
      s08["InputContentSHA256", "VirtualInterference"]
];
twoBodyReferenceExpressionSHA256 = Association@Map[
  Function[sector,
    sector -> AssociationMap[
      Hash[
        s08["TwoBodyPhaseSpaceIntegrated", sector, #],
        "SHA256"
      ] &,
      projectors
    ]
  ],
  {"LO_OAlphaS", "NLOVirtualInterference_OAlphaS2_Symbolic"}
];
s09TwoBodyReferenceHashGate = TrueQ[
  twoBodyReferenceExpressionSHA256 ===
    s09["Bookkeeping", "LOAndVirtualReferenceExpressionSHA256"]
];
loVirtualReferenceHashGate = TrueQ[
  s07InputContentHashGate && s09TwoBodyReferenceHashGate
];
assert[loVirtualReferenceHashGate,
  "The accepted raw S07 inputs or S08 two-body references do not match " <>
    "their S08/S09 content ledgers."];

twoBodyKinematicRecord = s07["KinematicConventions", "TwoBody"];
twoBodyKinematicRecordGate = TrueQ[
  AssociationQ[twoBodyKinematicRecord] &&
    twoBodyKinematicRecord["SerializationSchema"] ===
      "HqgS01Kinematics-v2" &&
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
    FreeQ[twoBodyKinematicRecord, _Real | _Missing]
];
assert[twoBodyKinematicRecordGate,
  "S07 does not preserve the accepted inert two-body kinematic record."];

installMassShellAssignments[assignments_List] := Scan[
  Function[entry,
    With[
      {
        momentum = Lookup[entry, "Momentum"],
        value = Lookup[entry, "MassSquared"]
      },
      FeynCalc`SPD[momentum, momentum] = value
    ]
  ],
  assignments
];

installScalarProductAssignments[assignments_List] := Scan[
  Function[entry,
    With[
      {
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
    "The inherited two-body kinematic record did not install exactly."];
  audit
];

(*
  Remove all saved symbolic QCD counterterm coefficients before evaluating the
  bare loops.  Their explicit values are inserted once below.  In the saved
  unpolarized interference the exact counterterm/LO multiplier is

    dZGG1 + 2 dZgs1 + 2 dZq1[3,1,1].

  The saved pair 2 dZq1 is the aggregate contribution of the two external
  quark legs.  deltaZqAggregate below represents that complete pair and must
  therefore be inserted once; no extra LSZ factor is added.
*)
countertermZeroRules = {
  dZGG1 -> 0,
  dZgs1 -> 0,
  HoldPattern[dZq1[___]] -> 0
};

virtualDimensional = Map[(# /. D -> 4 - 2 epsilon) &, virtualInput];
bareVirtualSymbolicD = Map[(# /. countertermZeroRules) &, virtualInput];
bareVirtualDimensional =
  Map[(# /. D -> 4 - 2 epsilon) &, bareVirtualSymbolicD];

inheritedCountertermPresenceGate = And @@ (! FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualDimensional]);
assert[inheritedCountertermPresenceGate,
  "The inherited virtual pair does not contain the expected QCD counterterms."];
bareCountertermRemovalGate = And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[bareVirtualDimensional]);
assert[bareCountertermRemovalGate,
  "A symbolic QCD counterterm survived the bare-loop split."];

uniquePaVe = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional], _FeynCalc`PaVe, Infinity
];
uniqueScalarMasters = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional],
  _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0,
  Infinity
];
assert[
  Length[uniquePaVe] > 0 && DuplicateFreeQ[uniquePaVe] &&
    Length[uniqueScalarMasters] > 0 &&
    DuplicateFreeQ[uniqueScalarMasters] &&
    AllTrue[
      uniqueScalarMasters,
      MatchQ[#, _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0] &
    ],
  "The runtime virtual-integral inventory is empty or malformed."
];
virtualIntegralBasis = <|
  "PaVeCount" -> Length[uniquePaVe],
  "PaVeInventorySHA256" -> Hash[uniquePaVe, "SHA256"],
  "B0Count" -> Count[uniqueScalarMasters, _FeynCalc`B0],
  "C0Count" -> Count[uniqueScalarMasters, _FeynCalc`C0],
  "D0Count" -> Count[uniqueScalarMasters, _FeynCalc`D0],
  "DirectScalarMasterCount" -> Length[uniqueScalarMasters],
  "DirectScalarMasters" -> uniqueScalarMasters,
  "DirectScalarMasterInventorySHA256" ->
    Hash[uniqueScalarMasters, "SHA256"]
|>;
virtualIntegralInventoryGate = TrueQ[
  virtualIntegralBasis["PaVeCount"] === Length[uniquePaVe] &&
    Total[Lookup[
      virtualIntegralBasis,
      {"B0Count", "C0Count", "D0Count"}
    ]] === virtualIntegralBasis["DirectScalarMasterCount"] &&
    virtualIntegralBasis["PaVeInventorySHA256"] ===
      Hash[uniquePaVe, "SHA256"] &&
    virtualIntegralBasis["DirectScalarMasterInventorySHA256"] ===
      Hash[uniqueScalarMasters, "SHA256"]
];
assert[virtualIntegralInventoryGate,
  "The runtime virtual-integral inventory failed its content gates."];
Print["S10_RUNTIME_VIRTUAL_INVENTORY=", InputForm[virtualIntegralBasis]];

expansionCacheValidation = <||>;
expansionCacheSummaries = <||>;
loadExpansion[projector_String] := Module[
  {
    payload, path, metadataChecks, metadataGate, expressionGate,
    expression
  },
  path = expansionCachePaths[projector];
  Print["S10_STAGE: loading accepted S09 cache for " <> projector];
  assert[
    fileSHA256Hex[path] === recordedExpansionCacheSHA256[projector],
    projector <> " S09 cache no longer has its accepted disk identity."
  ];
  payload = Quiet@Check[Get[path], $Failed];
  assert[AssociationQ[payload],
    projector <> " S09 expansion cache is not an Association."];
  metadataChecks = <|
    "Status" -> TrueQ[payload["Status"] === "Complete"],
    "Stage" -> TrueQ[
      payload["Stage"] === expandedKernelCacheStageVersion
    ],
    "ResultSchemaVersion" -> TrueQ[
      payload["ResultSchemaVersion"] === 2
    ],
    "Channel" -> TrueQ[payload["Channel"] === "Hqg only"],
    "TensorRole" -> TrueQ[payload["TensorRole"] === "RealQG"],
    "Projector" -> TrueQ[payload["Projector"] === projector],
    "ProgramPath" -> TrueQ[
      payload["ProgramPath"] === s09ProgramRecordedPath
    ],
    "ProgramSHA256" -> TrueQ[
      payload["ProgramSHA256"] === s09ProgramSHA256
    ],
    "PaperPath" -> TrueQ[payload["PaperPath"] === recordedPaperPath],
    "PaperSHA256" -> TrueQ[
      payload["PaperSHA256"] === referencePDFSHA256
    ],
    "S08SourcePath" -> TrueQ[
      payload["S08SourcePath"] === s08ProgramRecordedPath
    ],
    "S08SourceSHA256" -> TrueQ[
      payload["S08SourceSHA256"] === s08ProgramSHA256
    ],
    "S08ResultPath" -> TrueQ[
      payload["S08ResultPath"] === s08RecordedPath
    ],
    "S08ResultSHA256" -> TrueQ[
      payload["S08ResultSHA256"] === s08SHA256
    ],
    "AdditionalMultiplicativeWeight" -> TrueQ[
      payload["AdditionalMultiplicativeWeight"] === hardKernelWeight
    ],
    "ScalePowers" -> TrueQ[
      payload["ScalePowers"] ===
        measuredScalePowersByProjector[projector]
    ],
    "ChargeBookkeeping" -> TrueQ[
      payload["ChargeBookkeeping"] === chargeBookkeeping
    ],
    "InitialStateBookkeeping" -> TrueQ[
      payload["InitialStateBookkeeping"] === initialStateBookkeeping
    ],
    "DimensionalBookkeeping" -> TrueQ[
      payload["DimensionalBookkeeping"] === dimensionalBookkeeping
    ],
    "TwoBodyReferenceHashes" -> TrueQ[
      payload["TwoBodyReferenceHashes"] ===
        loAndVirtualReferenceExpressionSHA256
    ],
    "ExpandedLeafCount" -> TrueQ[
      IntegerQ[payload["ExpandedLeafCount"]] &&
        payload["ExpandedLeafCount"] > 0
    ],
    "ExpandedByteCount" -> TrueQ[
      IntegerQ[payload["ExpandedByteCount"]] &&
        payload["ExpandedByteCount"] > 0
    ]
  |>;
  metadataGate = AllTrue[Values[metadataChecks], TrueQ];
  If[! metadataGate,
    Print[
      "S10_S09_METADATA_FALSE_KEYS_" <> projector <> "=",
      InputForm[Keys@Select[metadataChecks, ! TrueQ[#] &]]
    ]
  ];
  assert[metadataGate,
    projector <> " S09 expansion cache has invalid current provenance."];
  expression = Lookup[payload, "Expression", Missing["Absent"]];
  expressionGate = TrueQ[
    ! MissingQ[expression] && expression =!= 0 && expression =!= $Failed
  ];
  assert[expressionGate,
    projector <> " S09 expansion cache lacks a valid expression."];
  AssociateTo[expansionCacheValidation, projector ->
    <|"Metadata" -> metadataGate, "ExpressionPresent" -> expressionGate|>];
  AssociateTo[expansionCacheSummaries, projector -> <|
    "ExpandedLeafCount" -> payload["ExpandedLeafCount"],
    "ExpandedByteCount" -> payload["ExpandedByteCount"],
    "DiskSHA256" -> recordedExpansionCacheSHA256[projector]
  |>];
  Clear[payload];
  expression
];

If[preflightOnly,
  preflightArtifactPathsBefore = Sort@FileNames[
    FileNameJoin[{scriptDirectory, "s10_cache_*"}]
  ];
  preflightExpansionExpressions = AssociationMap[loadExpansion, projectors];
  preflightExpansionShapeGate = TrueQ[
    Sort[Keys[preflightExpansionExpressions]] === Sort[projectors] &&
      AllTrue[Values[preflightExpansionExpressions], # =!= 0 &]
  ];
  Clear[preflightExpansionExpressions];
  ClearSystemCache[];
  preflightArtifactPathsAfter = Sort@FileNames[
    FileNameJoin[{scriptDirectory, "s10_cache_*"}]
  ];
  preflightChecks = <|
    "AcceptedS09IdentityAndChecksValidated" ->
      (s09IdentityGate && s09ChecksGate && s09ProgramGate),
    "AcceptedS08IdentityAndChecksValidated" ->
      (s08IdentityGate && s08ChecksGate && s08ProgramGate),
    "AcceptedS07IdentityAndChecksValidated" ->
      (s07IdentityGate && s07ChecksGate && s07ProgramGate),
    "PaperAndChargeBookkeepingValidated" ->
      (paperBindingGate && chargeBookkeepingGate),
    "LOAndVirtualReferenceHashesValidated" -> loVirtualReferenceHashGate,
    "S09CacheDiskHashesValidated" -> expansionCacheDiskHashGate,
    "BothS09CachePayloadsValidated" ->
      AllTrue[Flatten[Values /@ Values[expansionCacheValidation]], TrueQ],
    "RuntimeVirtualIntegralInventoryDerived" ->
      virtualIntegralInventoryGate,
    "FormalEndpointPlaceholderInventoryDerived" ->
      (endpointPlaceholderCount ===
        Total[Values[endpointPlaceholderCountsByProjector]]),
    "BothExpansionExpressionsLoaded" -> preflightExpansionShapeGate,
    "EndpointParallelBatchDeadlineConfigured" -> TrueQ[
      IntegerQ[endpointParallelBatchTimeLimitSeconds] &&
        endpointParallelBatchTimeLimitSeconds > 0 &&
        endpointParallelBatchTimeoutCountByProjector ===
          AssociationMap[0 &, projectors] &&
        endpointSerialFallbackSourceIndices ===
          AssociationMap[{} &, projectors]
    ],
    "NoS10CacheArtifactCreated" ->
      (preflightArtifactPathsBefore === preflightArtifactPathsAfter),
    "NoS10ResultCreated" -> ! FileExistsQ[resultPath]
  |>;
  assert[AllTrue[Values[preflightChecks], TrueQ],
    "At least one Hqg S10 prefix-preflight check failed."];
  Print["S10_PREFIX_PREFLIGHT_CHECKS=", InputForm[preflightChecks]];
  Print["HQG_S10_V6_PREFIX_PREFLIGHT_OK"];
  Quit[0]
];

evaluatePaVe[
    integral_, index_Integer, total_Integer, label_String
  ] := Module[{answer},
  Print[
    "S10_STAGE: analytic " <> label <> " evaluation " <>
      ToString[index] <> "/" <> ToString[total]
  ];
  answer = CheckAbort[
    Quiet@Check[
      TimeConstrained[
        FeynCalc`PaXEvaluateUVIRSplit[
          integral,
          ell,
          FeynCalc`PaXImplicitPrefactor -> 1,
          FeynCalc`PaXC0Expand -> True,
          FeynCalc`PaXD0Expand -> True,
          FeynCalc`PaXAnalytic -> True
        ],
        600,
        $Failed
      ],
      $Failed
    ],
    $Failed
  ];
  assert[answer =!= $Failed,
    "Package-X failed or timed out on " <> label <> " integral " <>
      ToString[index] <> "."];
  assert[FreeQ[
      answer,
      _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`PaXEvaluateUVIRSplit
    ],
    "A Package-X " <> label <> " evaluation remained unresolved at " <>
      "integral " <> ToString[index] <> "."];
  answer
];

ruleCacheValidation = <||>;
obtainPaVeRules[
    integrals_List, cache_String, version_Integer, label_String
  ] := Module[
  {
    payload, cachedIntegrals = {}, values = {}, index, total,
    inventoryHash, reloadGate, finalCacheGate
  },
  total = Length[integrals];
  inventoryHash = Hash[integrals, "SHA256"];
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading resumable Package-X cache"];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === version &&
        payload["StageVersion"] === stageVersion &&
        payload["IntegralType"] === label &&
        payload["IntegralInventorySHA256"] === inventoryHash &&
        payload["SourceS09SHA256"] === s09SHA256 &&
        payload["SourceS08SHA256"] === s08SHA256 &&
        payload["SourceS07SHA256"] === s07SHA256 &&
        payload["ProgramSHA256"] === programSHA256,
      "The Package-X " <> label <> " cache is invalid."];
    cachedIntegrals = payload["Integrals"];
    values = payload["Values"];
    assert[ListQ[cachedIntegrals] && ListQ[values] &&
        Length[cachedIntegrals] === Length[values] &&
        Length[values] <= total,
      "The Package-X " <> label <> " cache has inconsistent list lengths."];
    assert[SameQ[cachedIntegrals, Take[integrals, Length[cachedIntegrals]]],
      "The Package-X " <> label <>
        " cache does not match the current integral ordering."];
  ];
  For[index = Length[values] + 1, index <= total, index++,
    AppendTo[cachedIntegrals, integrals[[index]]];
    AppendTo[values,
      evaluatePaVe[integrals[[index]], index, total, label]];
    payload = <|
      "CacheVersion" -> version,
      "StageVersion" -> stageVersion,
      "IntegralType" -> label,
      "IntegralInventorySHA256" -> inventoryHash,
      "SourceS09" -> s09Path,
      "SourceS09SHA256" -> s09SHA256,
      "SourceS08" -> s08Path,
      "SourceS08SHA256" -> s08SHA256,
      "SourceS07" -> s07Path,
      "SourceS07SHA256" -> s07SHA256,
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "AnalyticContinuation" -> True,
      "ImplicitPrefactor" -> 1,
      "Integrals" -> cachedIntegrals,
      "Values" -> values
    |>;
    writeAtomic[payload, cache];
    reloadGate = atomicReloadSameQ[payload, cache];
    assert[reloadGate,
      "The resumable Package-X " <> label <>
        " cache failed atomic reload equality."];
  ];
  assert[Length[values] === total,
    "The Package-X " <> label <> " cache has incomplete coverage."];
  assert[And @@ (FreeQ[
        #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
          _FeynCalc`PaXEvaluateUVIRSplit
      ] & /@ values),
    "At least one cached Package-X " <> label <> " value is unresolved."];
  payload = Quiet@Check[Get[cache], $Failed];
  finalCacheGate = TrueQ[
    AssociationQ[payload] &&
      payload["IntegralInventorySHA256"] === inventoryHash &&
      SameQ[payload["Integrals"], integrals] &&
      SameQ[payload["Values"], values]
  ];
  assert[finalCacheGate,
    "The finalized Package-X " <> label <> " cache is incomplete."
  ];
  AssociateTo[ruleCacheValidation, label -> finalCacheGate];
  Thread[integrals -> values]
];

Scan[
  Function[specification,
    migrateAcceptedVirtualCache @@ specification
  ],
  {
    {paVeCachePath, paVeCacheVersion, "PaVe"},
    {
      scalarMasterCachePath,
      scalarMasterCacheVersion,
      "scalar master"
    },
    {laurentCachePath, laurentCacheVersion, "virtual Laurent"}
  }
];

Print["S10_STAGE: completing all analytic scalar one-loop integrals"];
paVeRules = obtainPaVeRules[
  uniquePaVe, paVeCachePath, paVeCacheVersion, "PaVe"
];
scalarMasterRules = obtainPaVeRules[
  uniqueScalarMasters, scalarMasterCachePath,
  scalarMasterCacheVersion, "scalar master"
];
loopIntegralRules = Join[paVeRules, scalarMasterRules];
bareVirtualSplit = Map[
  (# /. Dispatch[loopIntegralRules]) &,
  bareVirtualSymbolicD
];
loopIntegralResolutionGate = And @@ (FreeQ[
      #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`PaXEvaluateUVIRSplit
    ] & /@ Values[bareVirtualSplit]);
assert[loopIntegralResolutionGate,
  "A PaVe, scalar master, or Package-X evaluator remains in the virtual pair."];
uvRegulatorPresenceGate = And @@ (! FreeQ[#, FeynCalc`EpsilonUV] & /@
      Values[bareVirtualSplit]);
assert[uvRegulatorPresenceGate,
  "A bare virtual projector lacks its explicit UV regulator."];
irRegulatorPresenceGate = And @@ (! FreeQ[#, FeynCalc`EpsilonIR] & /@
      Values[bareVirtualSplit]);
assert[irRegulatorPresenceGate,
  "A bare virtual projector lacks its explicit IR regulator."];

setTwoBodyKinematics[] := installKinematicRecord[twoBodyKinematicRecord];

Print["S10_STAGE: resolving ordinary tree propagator denominators"];
twoBodyInstallationAudit = setTwoBodyKinematics[];
bareVirtualExplicit = Map[
  Function[expression,
    Quiet@Check[
      FeynCalc`FeynAmpDenominatorExplicit[expression] /.
        D -> 4 - 2 epsilon,
      $Failed
    ]
  ],
  bareVirtualSplit
];
loExplicit = Map[
  Function[expression,
    Quiet@Check[
      FeynCalc`FeynAmpDenominatorExplicit[expression] /.
        D -> 4 - 2 epsilon,
      $Failed
    ]
  ],
  loInput
];
assert[FreeQ[Values[bareVirtualExplicit], $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity],
  "Bare-loop propagator expansion failed or became indeterminate."];
assert[FreeQ[Values[loExplicit], $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity],
  "LO propagator expansion failed or became indeterminate."];
bareDenominatorResolutionGate = And @@ (FreeQ[
      #, _FeynCalc`FeynAmpDenominator
    ] & /@ Values[bareVirtualExplicit]);
assert[bareDenominatorResolutionGate,
  "A bare-loop FeynAmpDenominator remains unresolved."];
loDenominatorResolutionGate = And @@ (FreeQ[
      #, _FeynCalc`FeynAmpDenominator
    ] & /@ Values[loExplicit]);
assert[loDenominatorResolutionGate,
  "An LO FeynAmpDenominator remains unresolved."];
scalarPairResolutionGate = And @@ (FreeQ[#, _FeynCalc`Pair] & /@
      Join[Values[bareVirtualExplicit], Values[loExplicit]]);
assert[scalarPairResolutionGate,
  "A scalar Pair survived the symbolic-D denominator expansion."];

(* Solve the explicit one-loop QCD definitions in the saved-amplitude convention. *)
aSLoop = FeynCalc`SMP["g_s"]^2/(16 Pi^2);
countertermDefinitionEquations = {
  s10DeltaZGG ==
    aSLoop (5 FeynCalc`CA/3 - 2 FeynCalc`Nf/3) *
      (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR),
  s10DeltaZgs ==
    -aSLoop (11 FeynCalc`CA/6 - FeynCalc`Nf/3) /
      FeynCalc`EpsilonUV,
  s10DeltaZqAggregate ==
    -2 aSLoop FeynCalc`CF *
      (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR)
};
countertermDefinitionSolutions = Solve[
  countertermDefinitionEquations,
  {s10DeltaZGG, s10DeltaZgs, s10DeltaZqAggregate}
];
assert[Length[countertermDefinitionSolutions] === 1,
  "The explicit QCD counterterm definitions lack a unique solution."];
countertermDefinitionSolution = First[countertermDefinitionSolutions];
deltaZGG = s10DeltaZGG /. countertermDefinitionSolution;
deltaZgs = s10DeltaZgs /. countertermDefinitionSolution;
deltaZqAggregate = s10DeltaZqAggregate /. countertermDefinitionSolution;
explicitCountertermMultiplier =
  deltaZGG + 2 deltaZgs + deltaZqAggregate;

colorDefinitionSolutions = Solve[
  2 FeynCalc`CA FeynCalc`CF == FeynCalc`CA^2 - 1,
  FeynCalc`CF
];
assert[Length[colorDefinitionSolutions] === 1,
  "The fundamental-color defining relation lacks a unique solution."];
colorRule = First[colorDefinitionSolutions];

Print["S10_STAGE: validating the explicit UV counterterm cancellation"];
bareUVResidues = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        SeriesCoefficient[
          bareVirtualExplicit[projector],
          {FeynCalc`EpsilonUV, 0, -1}
        ] /. epsilon -> 0,
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[FreeQ[Values[bareUVResidues], $Failed],
  "Extraction of a bare UV residue failed or timed out."];

bareUVRatios = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Together@Cancel[
          (bareUVResidues[projector]/
              (loExplicit[projector] /. epsilon -> 0)) /. colorRule
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[FreeQ[Values[bareUVRatios], $Failed],
  "Derivation of a bare UV/LO ratio failed or timed out."];
expectedBareUVRatio = First[Values[bareUVRatios]];
bareUVRatioResiduals = AssociationMap[
  Together@Cancel[bareUVRatios[#] - expectedBareUVRatio] &,
  projectors
];
bareUVCommonRatioGate =
  And @@ (TrueQ[# === 0] & /@ Values[bareUVRatioResiduals]);
assert[bareUVCommonRatioGate,
  "The evaluated bare UV residues do not derive one common LO multiple."];

countertermUVRatio = SeriesCoefficient[
  explicitCountertermMultiplier,
  {FeynCalc`EpsilonUV, 0, -1}
];
uvCancellationRatio = Together@Cancel[
  expectedBareUVRatio + (countertermUVRatio /. colorRule)
];
uvCancellationGate = TrueQ[uvCancellationRatio === 0];
assert[uvCancellationGate,
  "The explicit QCD constants do not cancel the bare UV residue."];

(*
  The coefficient (without DiracDelta[s23]) is transformed exactly as in s08:
  multiply by 2 Pi/(2 Pi)^4 and by d zeta/d s23, apply the saved partonic
  substitutions, and then enforce the two-body endpoint s23=0.
*)
twoBodyPhaseFactor = s08["PhaseSpaceDefinitions", "TwoBodyEq34"];
twoBodyPhaseCoefficient =
  twoBodyPhaseFactor /. DiracDelta[s23] -> 1;
twoBodyPhaseDefinitionGate = TrueQ[
  ! FreeQ[twoBodyPhaseFactor, DiracDelta[s23]] &&
    FreeQ[twoBodyPhaseCoefficient, DiracDelta[s23] | _Real]
];
assert[twoBodyPhaseDefinitionGate,
  "The accepted S08 two-body phase definition is invalid."];
transformTwoBodyCoefficient[expression_] :=
  (twoBodyPhaseCoefficient xiS23Jacobian *
      (expression /. partonicRules)) /. s23 -> 0;

Print["S10_STAGE: applying the exact s08 two-body normalization and map"];
loTransformed = Map[transformTwoBodyCoefficient, loExplicit];
loStoredCoefficients = Map[
  Function[expression,
    (expression /. DiracDelta[s23] -> 1) /. s23 -> 0
  ],
  loReference
];
loNormalizationResiduals = AssociationMap[
  loTransformed[#] - loStoredCoefficients[#] &,
  projectors
];
loNormalizationGate = And @@ (zeroEquivalentQ[#, 600] & /@
      Values[loNormalizationResiduals]);
assert[loNormalizationGate,
  "The reconstructed two-body normalization does not match the s09 LO reference."];

bareVirtualTransformed = Map[
  transformTwoBodyCoefficient,
  bareVirtualExplicit
];
renormalizedVirtualSplit = AssociationMap[
  bareVirtualTransformed[#] +
    loStoredCoefficients[#] explicitCountertermMultiplier &,
  projectors
];
explicitCountertermInsertionResiduals = AssociationMap[
  renormalizedVirtualSplit[#] -
    (bareVirtualTransformed[#] +
      loStoredCoefficients[#] explicitCountertermMultiplier) &,
  projectors
];
explicitCountertermInsertionGate =
  AllTrue[Values[explicitCountertermInsertionResiduals], SameQ[#, 0] &];
assert[explicitCountertermInsertionGate,
  "The explicit QCD counterterm insertion residual is nonzero."];
renormalizedVirtualResolutionGate = And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1 | _FeynCalc`PaVe | _FeynCalc`B0 |
        _FeynCalc`C0 | _FeynCalc`D0 | _FeynCalc`FeynAmpDenominator
    ] & /@ Values[renormalizedVirtualSplit]);
assert[renormalizedVirtualResolutionGate,
  "The renormalized virtual pair retains a symbolic dZ, loop integral, or denominator."];

(*
  The source associations and the successive bare-loop representations are
  large and are no longer needed once the two renormalized projector
  expressions have been constructed.  Releasing them here is essential: a
  monolithic Series otherwise coexists with several complete copies of the
  virtual input and can exhaust WSL memory.
*)
Print["S10_MEMORY_STAGE: releasing superseded virtual inputs before Laurent expansion"];
Clear[
  s09, s08, s07, virtualInput, loInput, loReference,
  changeOfVariables, partonicRules, xiS23Jacobian,
  virtualDimensional, bareVirtualSymbolicD, bareVirtualDimensional,
  paVeRules, scalarMasterRules, loopIntegralRules,
  bareVirtualSplit, bareVirtualExplicit, loExplicit,
  bareUVResidues, loTransformed, loNormalizationResiduals,
  bareVirtualTransformed
];
ClearSystemCache[];

(*
  Series is linear.  Split only at an already-present additive boundary and
  expand one summand at a time.  This avoids constructing SeriesData for the
  complete projector at once and does not perform an algebraic Expand.
*)
virtualLaurentTerms[expression_] := Module[
  {factors, plusPositions, splitPosition, commonFactor},
  If[Head[expression] === Plus,
    Return[<|"CommonFactor" -> 1, "Summands" -> (List @@ expression)|>]
  ];
  If[Head[expression] =!= Times,
    Return[<|"CommonFactor" -> 1, "Summands" -> {expression}|>]
  ];
  factors = List @@ expression;
  plusPositions = Flatten@Position[
    factors, _Plus, {1}, Heads -> False
  ];
  If[Length[plusPositions] === 0,
    Return[<|"CommonFactor" -> 1, "Summands" -> {expression}|>]
  ];
  splitPosition = First@MaximalBy[
    plusPositions,
    Length[List @@ factors[[#]]] &
  ];
  commonFactor = Times @@ Delete[factors, splitPosition];
  <|
    "CommonFactor" -> commonFactor,
    "Summands" -> (List @@ factors[[splitPosition]])
  |>
];

(*)
  PPP coarse term 2 contains huge rational kinematic factors that are exactly
  independent of all dimensional regulators.  Pull them outside Series,
  expose bounded additive pieces of the regulator-dependent product, and
  checkpoint their exactly linear Laurent expansions.  This is used only for
  the refined subterms of that one coarse term.
*)
boundedLaurentPieces[expression_, leafBudget_Integer] := Module[
  {walk, harvested},
  walk[current_] := Module[
    {currentLeafCount, pieces, commonFactor, summands},
    currentLeafCount = LeafCount[current];
    If[currentLeafCount <= leafBudget,
      Sow[current, "S10BoundedLaurentPiece"];
      Return[Null]
    ];
    pieces = virtualLaurentTerms[current];
    commonFactor = pieces["CommonFactor"];
    summands = pieces["Summands"];
    Clear[pieces];
    If[Length[summands] <= 1,
      Sow[current, "S10BoundedLaurentPiece"];
      Return[Null]
    ];
    Scan[
      Function[summand,
        walk[If[TrueQ[commonFactor === 1], summand,
          commonFactor summand]]
      ],
      summands
    ];
    Null
  ];
  harvested = Reap[
    walk[expression],
    "S10BoundedLaurentPiece"
  ][[2]];
  If[Length[harvested] === 0, {}, First[harvested]]
];

partitionLaurentPieces[pieces_List, leafBudget_Integer] := Module[
  {answer = {}, current = {}, currentLeafCount = 0, pieceLeafCount},
  Scan[
    Function[piece,
      pieceLeafCount = LeafCount[piece];
      If[Length[current] > 0 &&
          currentLeafCount + pieceLeafCount > leafBudget,
        AppendTo[answer, Total[current]];
        current = {};
        currentLeafCount = 0
      ];
      AppendTo[current, piece];
      currentLeafCount += pieceLeafCount
    ],
    pieces
  ];
  If[Length[current] > 0, AppendTo[answer, Total[current]]];
  answer
];

cleanupLaurentSubpartCaches[
    projector_String, index_Integer, subindex_Integer
  ] := Module[{paths},
  paths = FileNames[laurentSubpartCachePattern[projector, index, subindex]];
  Scan[Function[path, If[FileExistsQ[path], DeleteFile[path]]], paths];
  If[Length[paths] > 0,
    Print[
      "S10_CACHE_CLEANUP: removed " <> ToString[Length[paths]] <>
        " completed Laurent part caches for " <> projector <> " term " <>
        ToString[index] <> " subterm " <> ToString[subindex]
    ]
  ]
];

pppTerm2FactorwiseLaurent[
    expression_, inputHash_, subindex_Integer
  ] := Module[
  {
    factors, staticFactors, dynamicFactors, staticFactor, dynamicFactor,
    dynamicExpressionHash, boundedPieces, parts, partLeafCounts, partCount,
    partExpressionHashes, partindex, partExpression, partExpressionHash,
    partCache, payload,
    partAnswer, partAnswers = {}
  },
  factors = If[Head[expression] === Times, List @@ expression, {expression}];
  staticFactors = Select[
    factors,
    FreeQ[#, epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR] &
  ];
  dynamicFactors = Select[
    factors,
    ! FreeQ[#, epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR] &
  ];
  staticFactor = Times @@ staticFactors;
  dynamicFactor = Times @@ dynamicFactors;
  Print[
    "S10_TERM_OPTIMIZATION: PPP term 2 factorwise Laurent staticFactors=" <>
      ToString[Length[staticFactors]] <> " dynamicFactors=" <>
      ToString[Length[dynamicFactors]] <> " dynamicLeafCount=" <>
      ToString[LeafCount[dynamicFactor]]
  ];
  If[Length[dynamicFactors] === 0, Return[staticFactor]];
  boundedPieces = boundedLaurentPieces[
    dynamicFactor, pppLaurentPartLeafBudget
  ];
  parts = partitionLaurentPieces[
    boundedPieces, pppLaurentPartLeafBudget
  ];
  Clear[boundedPieces];
  partLeafCounts = LeafCount /@ parts;
  partCount = Length[parts];
  assert[partCount >= 1,
    "PPP term 2 dynamic factor produced no bounded Laurent part."];
  assert[Max[partLeafCounts] <= pppLaurentPartHardLeafLimit,
    "PPP term 2 bounded Laurent part exceeds the hard leaf limit."];
  partExpressionHashes = Hash[#, "SHA256"] & /@ parts;
  dynamicExpressionHash = Hash[
    {inputHash, subindex, partExpressionHashes},
    "SHA256"
  ];
  Print[
    "S10_TERM_REFINEMENT: PPP term 2 subterm " <> ToString[subindex] <>
      " boundedParts=" <> ToString[partCount] <> " maxPartLeafCount=" <>
      ToString[Max[partLeafCounts]]
  ];
  Clear[partLeafCounts, dynamicFactor, dynamicFactors, factors];
  For[partindex = 1, partindex <= partCount, partindex++,
    partExpression = parts[[partindex]];
    parts[[partindex]] = Null;
    partExpressionHash = partExpressionHashes[[partindex]];
    partExpressionHashes[[partindex]] = Null;
    partCache = laurentSubpartCachePath["PPP", 2, subindex, partindex];
    If[FileExistsQ[partCache],
      payload = Check[Get[partCache], $Failed];
      assert[AssociationQ[payload] &&
          payload["CacheVersion"] === laurentSubpartCacheVersion &&
          payload["ProgramSHA256"] === programSHA256 &&
          payload["Projector"] === "PPP" &&
          payload["CoarseTermIndex"] === 2 &&
          payload["SubtermIndex"] === subindex &&
          payload["InputHash"] === inputHash &&
          payload["DynamicExpressionHash"] === dynamicExpressionHash &&
          payload["PartIndex"] === partindex &&
          payload["PartCount"] === partCount &&
          payload["PartExpressionHash"] === partExpressionHash &&
          payload["LeafBudget"] === pppLaurentPartLeafBudget,
        "PPP bounded Laurent part cache is invalid."];
      partAnswer = payload["LaurentPart"];
      assert[partAnswer =!= $Failed,
        "PPP bounded Laurent part cache contains a failed value."];
      Print[
        "S10_STAGE: loaded PPP term 2 subterm " <> ToString[subindex] <>
          " Laurent part " <> ToString[partindex] <> "/" <>
          ToString[partCount]
      ],
      partAnswer = Check[
        TimeConstrained[
          Normal@Series[
            partExpression /. {
              FeynCalc`EpsilonUV -> epsilon,
              FeynCalc`EpsilonIR -> epsilon
            },
            {epsilon, 0, 0}
          ],
          900,
          $Failed
        ],
        $Failed
      ];
      assert[partAnswer =!= $Failed,
        "PPP term 2 subterm " <> ToString[subindex] <> " Laurent part " <>
          ToString[partindex] <> " failed or timed out."];
      payload = <|
        "CacheVersion" -> laurentSubpartCacheVersion,
        "ProgramSHA256" -> programSHA256,
        "Projector" -> "PPP",
        "CoarseTermIndex" -> 2,
        "SubtermIndex" -> subindex,
        "InputHash" -> inputHash,
        "DynamicExpressionHash" -> dynamicExpressionHash,
        "PartIndex" -> partindex,
        "PartCount" -> partCount,
        "PartExpressionHash" -> partExpressionHash,
        "LeafBudget" -> pppLaurentPartLeafBudget,
        "LaurentPart" -> partAnswer
      |>;
      writeAtomic[payload, partCache];
      assert[atomicReloadSameQ[payload, partCache],
        "PPP bounded Laurent part cache failed reload equality."];
      Print[
        "S10_PART_CHECKPOINT: PPP virtual Laurent term 2 subterm " <>
          ToString[subindex] <> " part " <> ToString[partindex] <> "/" <>
          ToString[partCount]
      ]
    ];
    AppendTo[partAnswers, partAnswer];
    Clear[partAnswer, partExpression, payload];
    ClearSystemCache[]
  ];
  staticFactor Total[partAnswers]
];

finiteLaurentTerm[
    commonFactor_, term_, projector_String, index_Integer, inputHash_
  ] := Module[
  {
    pieces, subCommonFactor, subterms, subtermCache, payload,
    values = {}, subindex, subtotal, subtermAnswer
  },
  pieces = virtualLaurentTerms[term];
  subCommonFactor = pieces["CommonFactor"];
  subterms = pieces["Summands"];
  Clear[pieces];
  subtotal = Length[subterms];
  If[subtotal === 1,
    Return@Check[
      TimeConstrained[
        Normal@Series[
          (commonFactor term) /. {
            FeynCalc`EpsilonUV -> epsilon,
            FeynCalc`EpsilonIR -> epsilon
          },
          {epsilon, 0, 0}
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ];
  subtermCache = laurentSubtermCachePath[projector, index];
  Print[
    "S10_STAGE: refined virtual Laurent term " <> projector <> " " <>
      ToString[index] <> " into " <> ToString[subtotal] <> " subterms"
  ];
  If[FileExistsQ[subtermCache],
    Print[
      "S10_STAGE: loading refined Laurent progress for " <> projector <>
        " term " <> ToString[index]
    ];
    payload = Check[Get[subtermCache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === laurentSubtermCacheVersion &&
        payload["StageVersion"] === stageVersion &&
        payload["ProgramSHA256"] === programSHA256 &&
        payload["Projector"] === projector &&
        payload["CoarseTermIndex"] === index &&
        payload["InputHash"] === inputHash &&
        payload["SubtermCount"] === subtotal,
      projector <> " virtual Laurent subterm cache is invalid."];
    values = payload["LaurentSubterms"];
    assert[ListQ[values] && Length[values] <= subtotal,
      projector <> " virtual Laurent subterm progress is invalid."];
  ];
  For[subindex = Length[values] + 1, subindex <= subtotal, subindex++,
    subtermAnswer = If[
      projector === "PPP" && index === 2,
      pppTerm2FactorwiseLaurent[
        commonFactor subCommonFactor subterms[[subindex]],
        inputHash,
        subindex
      ],
      Check[
        TimeConstrained[
          Normal@Series[
            (commonFactor subCommonFactor subterms[[subindex]]) /. {
              FeynCalc`EpsilonUV -> epsilon,
              FeynCalc`EpsilonIR -> epsilon
            },
            {epsilon, 0, 0}
          ],
          900,
          $Failed
        ],
        $Failed
      ]
    ];
    assert[subtermAnswer =!= $Failed,
      projector <> " virtual Laurent term " <> ToString[index] <>
        " subterm " <> ToString[subindex] <> " failed or timed out."];
    AppendTo[values, subtermAnswer];
    payload = <|
      "CacheVersion" -> laurentSubtermCacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "Projector" -> projector,
      "CoarseTermIndex" -> index,
      "InputHash" -> inputHash,
      "SubtermCount" -> subtotal,
      "LaurentSubterms" -> values
    |>;
    writeAtomic[payload, subtermCache];
    assert[atomicReloadSameQ[payload, subtermCache],
      projector <> " virtual Laurent subterm cache failed reload equality."];
    Print[
      "S10_SUBTERM_CHECKPOINT: " <> projector <> " virtual Laurent term " <>
        ToString[index] <> " subterm " <> ToString[subindex] <> "/" <>
        ToString[subtotal]
    ];
    cleanupLaurentSubpartCaches[projector, index, subindex];
    Clear[subtermAnswer];
    ClearSystemCache[];
  ];
  Total[values]
];

finiteLaurentProjector[
    expression_, projector_String, progressCache_String
  ] := Module[
  {
    pieces, commonFactor, terms, inputHash, payload, values = {},
    index, total, termAnswer
  },
  Print["S10_MEMORY_STAGE: locating additive boundary for " <> projector];
  pieces = virtualLaurentTerms[expression];
  commonFactor = pieces["CommonFactor"];
  terms = pieces["Summands"];
  Clear[pieces];
  total = Length[terms];
  assert[total > 1,
    projector <> " virtual expression has no safe additive split boundary."];
  inputHash = Hash[
    {
      programSHA256,
      s09SHA256,
      s08SHA256,
      s07SHA256,
      fileSHA256Hex[paVeCachePath],
      fileSHA256Hex[scalarMasterCachePath],
      projector,
      laurentProgressCacheVersion
    },
    "SHA256"
  ];
  If[FileExistsQ[progressCache],
    Print["S10_STAGE: loading resumable virtual Laurent progress for " <>
      projector];
    payload = Check[Get[progressCache], $Failed];
    assert[AssociationQ[payload],
      projector <> " virtual Laurent progress cache is invalid."];
    values = payload["LaurentTerms"];
    assert[
        payload["CacheVersion"] === laurentProgressCacheVersion &&
        payload["StageVersion"] === stageVersion &&
        payload["ProgramSHA256"] === programSHA256 &&
        payload["Projector"] === projector &&
        payload["InputHash"] === inputHash &&
        payload["TermCount"] === total,
      projector <> " virtual Laurent progress cache is invalid."];
    assert[ListQ[values] && Length[values] <= total,
      projector <> " virtual Laurent progress has an invalid term list."];
  ];
  Print[
    "S10_STAGE: bounded virtual Laurent terms for " <> projector <>
      " completed=" <> ToString[Length[values]] <> "/" <> ToString[total]
  ];
  For[index = Length[values] + 1, index <= total, index++,
    termAnswer = finiteLaurentTerm[
      commonFactor, terms[[index]], projector, index, inputHash
    ];
    assert[termAnswer =!= $Failed,
      projector <> " virtual Laurent term " <> ToString[index] <>
        " failed or timed out."];
    AppendTo[values, termAnswer];
    payload = <|
      "CacheVersion" -> laurentProgressCacheVersion,
      "StageVersion" -> stageVersion,
      "ProgramSHA256" -> programSHA256,
      "Projector" -> projector,
      "InputHash" -> inputHash,
      "TermCount" -> total,
      "LaurentTerms" -> values
    |>;
    writeAtomic[payload, progressCache];
    assert[atomicReloadSameQ[payload, progressCache],
      projector <> " virtual Laurent progress cache failed reload equality."];
    If[FileExistsQ[laurentSubtermCachePath[projector, index]],
      DeleteFile[laurentSubtermCachePath[projector, index]]
    ];
    Print[
      "S10_TERM_CHECKPOINT: " <> projector <> " virtual Laurent term " <>
        ToString[index] <> "/" <> ToString[total]
    ];
    Clear[termAnswer];
    ClearSystemCache[];
  ];
  Total[values]
];

virtualLaurentCacheValidationGate = False;
finiteLaurentPair[pair_Association, cache_String] := Module[
  {
    payload, answer = <||>, projector, projectorExpression, progressCache,
    cacheMetadataGate, reloadGate
  },
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading virtual Laurent cache"];
    payload = Check[Get[cache], $Failed];
    cacheMetadataGate = TrueQ[AssociationQ[payload] &&
        payload["CacheVersion"] === laurentCacheVersion &&
        payload["StageVersion"] === stageVersion &&
        payload["SourceS09SHA256"] === s09SHA256 &&
        payload["SourceS08SHA256"] === s08SHA256 &&
        payload["SourceS07SHA256"] === s07SHA256 &&
        payload["ProgramSHA256"] === programSHA256 &&
        payload["PaVeCacheSHA256"] === fileSHA256Hex[paVeCachePath] &&
        payload["ScalarMasterCacheSHA256"] ===
          fileSHA256Hex[scalarMasterCachePath]];
    assert[cacheMetadataGate,
      "The virtual Laurent cache is invalid."];
    answer = payload["LaurentThroughFinite"];
    assert[AssociationQ[answer] && Sort[Keys[answer]] === Sort[projectors],
      "The virtual Laurent cache has invalid projector keys."];
    virtualLaurentCacheValidationGate = TrueQ[
      cacheMetadataGate &&
        AllTrue[Values[answer], # =!= $Failed && # =!= 0 &]
    ];
    Scan[
      Function[projector,
        progressCache = laurentProgressCachePath[projector];
        If[FileExistsQ[progressCache], DeleteFile[progressCache]]
      ],
      projectors
    ];
    Return[answer]
  ];
  Do[
    Print["S10_STAGE: virtual Laurent expansion through finite term for " <>
      projector];
    projectorExpression = pair[projector];
    progressCache = laurentProgressCachePath[projector];
    AssociateTo[
      answer,
      projector -> finiteLaurentProjector[
        projectorExpression, projector, progressCache
      ]
    ];
    Clear[projectorExpression];
    ClearSystemCache[],
    {projector, projectors}
  ];
  payload = <|
    "CacheVersion" -> laurentCacheVersion,
    "StageVersion" -> stageVersion,
    "SourceS09" -> s09Path,
    "SourceS09SHA256" -> s09SHA256,
    "SourceS08" -> s08Path,
    "SourceS08SHA256" -> s08SHA256,
    "SourceS07" -> s07Path,
    "SourceS07SHA256" -> s07SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "PaVeCache" -> paVeCachePath,
    "PaVeCacheSHA256" -> fileSHA256Hex[paVeCachePath],
    "ScalarMasterCache" -> scalarMasterCachePath,
    "ScalarMasterCacheSHA256" ->
      fileSHA256Hex[scalarMasterCachePath],
    "RegulatorsUnifiedAfterUVCheck" -> True,
    "EvaluatorConvention" -> "Package-X implicit prefactor 1",
    "OrdersRetained" -> {-2, -1, 0},
    "LaurentThroughFinite" -> answer
  |>;
  writeAtomic[payload, cache];
  reloadGate = atomicReloadSameQ[payload, cache];
  assert[reloadGate,
    "The virtual Laurent cache failed atomic reload equality."];
  virtualLaurentCacheValidationGate = TrueQ[
    reloadGate && Sort[Keys[answer]] === Sort[projectors] &&
      AllTrue[Values[answer], # =!= $Failed && # =!= 0 &]
  ];
  Scan[
    Function[projector,
      progressCache = laurentProgressCachePath[projector];
      If[FileExistsQ[progressCache], DeleteFile[progressCache]]
    ],
    projectors
  ];
  answer
];

Print["S10_STAGE: completing the renormalized virtual Laurent expansion"];
virtualLaurent = finiteLaurentPair[
  renormalizedVirtualSplit,
  laurentCachePath
];
virtualLaurentResolutionGate = And @@ (FreeQ[
      #,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator |
        dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualLaurent]);
assert[virtualLaurentResolutionGate,
  "A completed virtual Laurent coefficient retains an unresolved object."];

virtualDoublePoleDefinitionSolutions = Solve[
  s10VirtualDoublePoleRatio ==
    -FeynCalc`SMP["g_s"]^2 *
      (2 FeynCalc`CF + FeynCalc`CA)/(8 Pi^2),
  s10VirtualDoublePoleRatio
];
assert[Length[virtualDoublePoleDefinitionSolutions] === 1,
  "The virtual double-pole defining equation lacks a unique solution."];
expectedVirtualDoublePoleRatio =
  s10VirtualDoublePoleRatio /.
    First[virtualDoublePoleDefinitionSolutions];
virtualDoublePoleResiduals = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Together@Cancel[
          (SeriesCoefficient[
              virtualLaurent[projector], {epsilon, 0, -2}
            ]/(loStoredCoefficients[projector] /. epsilon -> 0) -
            expectedVirtualDoublePoleRatio) /. colorRule
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
virtualDoublePoleGate =
  And @@ (TrueQ[# === 0] & /@ Values[virtualDoublePoleResiduals]);
assert[virtualDoublePoleGate,
  "The renormalized virtual double pole is not the universal LO multiple."];

invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | Indeterminate | ComplexInfinity | DirectedInfinity |
    _Limit | Log[0] | Power[0, _?Negative]
];

vanishingEndpointQ[expression_] := Module[{value, reduced},
  value = Quiet@Check[expression /. s23 -> 0, $Failed];
  If[TrueQ[value === 0], Return[True]];
  If[invalidEndpointQ[value] || ! FreeQ[value, s23], Return[False]];
  reduced = Quiet@Check[
    TimeConstrained[Cancel[Together[value]], 30, $Failed],
    $Failed
  ];
  TrueQ[reduced === 0]
];

exactPhysicalZeroQ[expression_, assumptions_] := Module[
  {combined, simplified},
  If[TrueQ[expression === 0], Return[True]];
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
  Root-coupled Hqg terms are not individual Laurent objects.  Discover their
  exact groups first.  The grouped evaluator below derives the single common
  radicand and every exact s23 scaling from the source, introduces a positive
  endpoint coordinate through s23=t^2, and derives both physical root jets
  from the defining square equation.  Every literal Log and PolyLog occurrence
  is reversibly compressed, normalized to a shared runtime basis, and expanded
  once per root sign.  Only the complete group may be tested for negative
  endpoint powers and endpoint logarithms.  No branch-blind PowerExpand is
  used and grouped source positions never call endpointTermLaurent.
*)
discoverCoupledEndpointGroups[
    standardTerms_List, standardIndices_List, label_String
  ] := Module[
  {
    aPhysical, rTPhysical, deltaPhysical, physicalSubstitution,
    baseAssumptions, canonicalRadicand, branchRootData,
    records, groupedRecords, groups
  },
  assert[Length[standardTerms] === Length[standardIndices],
    label <> " standard endpoint term/index lists are inconsistent."];
  aPhysical = S10PhysicalA;
  rTPhysical = S10PhysicalRT;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  baseAssumptions =
    aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 && Q2 > 0;
  canonicalRadicand[value_] := Quiet@Check[
    Factor[Together[value /. s23 -> 0]],
    $Failed
  ];
  branchRootData[radicand_] := Module[
    {canonical, plusRoot, minusRoot, gate},
    canonical = canonicalRadicand[radicand];
    If[canonical === $Failed || invalidEndpointQ[canonical], Return[$Failed]];
    plusRoot = Quiet@Check[
      FullSimplify[
        Sqrt[canonical],
        Assumptions -> baseAssumptions && deltaPhysical > 0
      ],
      $Failed
    ];
    minusRoot = Quiet@Check[
      FullSimplify[
        Sqrt[canonical],
        Assumptions -> baseAssumptions && deltaPhysical < 0
      ],
      $Failed
    ];
    gate = TrueQ[
      plusRoot =!= $Failed && minusRoot =!= $Failed &&
        FreeQ[plusRoot, Abs | Sign | s23] &&
        FreeQ[minusRoot, Abs | Sign | s23] &&
        plusRoot =!= minusRoot &&
        Together[plusRoot + minusRoot] === 0 &&
        Together[plusRoot^2 - canonical] === 0 &&
        Together[minusRoot^2 - canonical] === 0
    ];
    If[
      gate,
      <|
        "PhysicalRootRadicand" -> canonical,
        "RootByDeltaSign" -> <|1 -> plusRoot, -1 -> minusRoot|>
      |>,
      $Failed
    ]
  ];
  records = MapThread[
    Function[{term, sourceIndex},
      Module[{radicands, branchRecords},
        radicands = DeleteDuplicates[
          (# /. physicalSubstitution) & /@ Cases[
            term,
            Power[
              radicand_,
              power_Rational?((Denominator[#] === 2) &)
            ] :> radicand,
            Infinity
          ]
        ];
        branchRecords = DeleteCases[
          branchRootData /@ radicands,
          $Failed
        ];
        branchRecords = DeleteDuplicatesBy[
          branchRecords,
          # ["PhysicalRootRadicand"] &
        ];
        If[branchRecords === {},
          Nothing,
          assert[Length[branchRecords] === 1,
            label <> " term " <> ToString[sourceIndex] <>
              " contains multiple inequivalent physical branch roots."];
          Append[First[branchRecords], "SourceIndex" -> sourceIndex]
        ]
      ]
    ],
    {standardTerms, standardIndices}
  ];
  assert[records =!= {},
    label <> " has no tool-detected physical root-coupled endpoint terms."];
  groupedRecords = GatherBy[records, # ["PhysicalRootRadicand"] &];
  groups = Map[
    Function[groupRecords,
      <|
        "SourceIndices" -> Sort@DeleteDuplicates@Lookup[
          groupRecords, "SourceIndex"
        ],
        "PhysicalRootRadicand" ->
          First[groupRecords]["PhysicalRootRadicand"],
        "RootByDeltaSign" -> First[groupRecords]["RootByDeltaSign"]
      |>
    ],
    groupedRecords
  ];
  assert[
    DuplicateFreeQ[Flatten[Lookup[groups, "SourceIndices"]]] &&
      AllTrue[Lookup[groups, "SourceIndices"], Length[#] > 1 &],
    label <> " root-coupled groups overlap or lack a cancellation partner."
  ];
  Print[
    "S10_DERIVED_COUPLED_ENDPOINT_GROUPS: label=", label,
    " groups=", InputForm[Lookup[groups, "SourceIndices"]]
  ];
  groups
];

seriesKnownThroughZeroQ[value_] := Which[
  Head[value] === SeriesData,
    TrueQ[value[[5]]/value[[6]] > 0],
  TrueQ[value === 0],
    True,
  FreeQ[value, S10EndpointT],
    True,
  True,
    False
];

seriesMinimumPower[value_] := Which[
  Head[value] === SeriesData,
    value[[4]]/value[[6]],
  TrueQ[value === 0],
    Infinity,
  FreeQ[value, S10EndpointT],
    0,
  True,
    Quiet@Check[Exponent[value, S10EndpointT, Min], $Failed]
];

coupledEndpointGroupLaurent[
    sourceTerms_List, sourceIndices_List, expectedRootRadicand_,
    rootByDeltaSign_Association, label_String
  ] := Module[
  {
    sourceHashesBefore, aPhysical, rTPhysical, deltaPhysical,
    physicalSubstitution, inverseSubstitution, originalDelta,
    branchAssumptions, qcdRules, endpointPowerTransform,
    exactUniqueExpressions, rootPowerExpressions, physicalRootBases,
    commonCandidates,
    commonRadicand, commonEndpointRadicand, rootRecords,
    rootPlaceholderRules, rootReverseRules, rootFormulaRules,
    rootPlaceholderDispatch, rootReverseDispatch, rootFormulaDispatch,
    rawFunctions, functionPlaceholderRules, functionReverseRules,
    functionPlaceholderDispatch, functionReverseDispatch,
    placeholderTerms, reconstructionGate, compressedTerms,
    normalizeFunctionRecord, functionRecords, basisFunctions,
    functionBasisIDs, basisFunctionHashToID, commonRadicandT,
    deriveRootPolynomial,
    rootResidualCoefficients, rootProbeOrder, rootProbePolynomials,
    termFactorLists, supportFactors, supportFactorHashes,
    supportFactorHashToID, termSupportFactorIDs,
    supportMinimumPower, supportMinimumPowersBySign,
    termSupportBoundsBySign, finiteSupportBounds,
    requiredFunctionSeriesOrder, requiredRootSeriesOrder,
    rootPolynomials, rootResiduals, rootGate,
    seriesKnownThroughOrderQ, normalizeGeneratedEndpointLogs,
    deriveFunctionSeries, factorSeriesCoefficientData,
    convolveLaurentCoefficientData, functionSeriesBySign,
    functionSeriesGate,
    branchResults = <||>, branchCertificates = <||>, rootSign,
    branchFunctionRules, branchSubstitutionDispatch,
    branchBaseFactorLists,
    branchFactorizationGate, branchFactorLists,
    branchFactorHashGroups, branchUniqueFactors, branchFactorHashes,
    branchFactorHashToID, branchTermFactorIDs,
    branchPilotFactorData, branchFactorMinimumPowerBounds,
    branchTermMinimumPowerBounds, branchRequiredFactorMaxima,
    branchFactorData, branchTermCoefficientData,
    branchTotalCoefficients, negativePowers, negativeResiduals,
    finiteCoefficient, maximumLogDegree, logPowers, logResiduals,
    branchConstant, groupResult, sourceHashesAfter,
    expressionSHA256Hex
  },
  assert[
    Length[sourceTerms] === Length[sourceIndices] &&
      Length[sourceTerms] > 1,
    label <> " coupled endpoint group has inconsistent source lists."
  ];
  assert[
    FreeQ[
      sourceTerms,
      _S10RootOccurrence | _S10SharedFunctionOccurrence |
        S10CommonRoot | S10EndpointT | S10EndpointLog
    ],
    label <> " source group already contains an internal series symbol."
  ];
  sourceHashesBefore = Hash[#, "SHA256"] & /@ sourceTerms;
  expressionSHA256Hex[value_] := IntegerString[
    Hash[value, "SHA256"], 16, 64
  ];
  aPhysical = S10PhysicalA;
  rTPhysical = S10PhysicalRT;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
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
  endpointPowerTransform[value_] :=
    (value /. HoldPattern[
        Power[s23, power_?((IntegerQ[2 #]) &)]
      ] :> S10EndpointT^(2 power)) /. s23 -> S10EndpointT^2;

  exactUniqueExpressions[values_List, objectLabel_String] := Module[
    {hashGroups},
    hashGroups = GatherBy[values, Hash[#, "SHA256"] &];
    assert[
      AllTrue[
        hashGroups,
        Function[currentGroup,
          AllTrue[Rest[currentGroup], SameQ[First[currentGroup], #] &]
        ]
      ],
      label <> " has a SHA-256 collision in " <> objectLabel <> "."
    ];
    First /@ hashGroups
  ];

  Print["S10_GROUP_PHASE_START: label=", label,
    " phase=root-inventory"];

  rootPowerExpressions = exactUniqueExpressions[
    Cases[
      sourceTerms,
      HoldPattern[Power[rootBase_, rootExponent_Rational]] /;
          Denominator[rootExponent] === 2 && rootBase =!= s23 :>
        Power[rootBase, rootExponent],
      Infinity
    ],
    "root occurrences"
  ];
  assert[rootPowerExpressions =!= {},
    label <> " coupled group contains no half-integer root powers."];
  physicalRootBases = exactUniqueExpressions[
    (#[[1]] /. physicalSubstitution) & /@ rootPowerExpressions,
    "physical root bases"
  ];
  commonCandidates = Select[
    physicalRootBases,
    Function[currentBase,
      Module[{endpoint},
        endpoint = Quiet@Check[
          Factor[Together[currentBase /. s23 -> 0]],
          $Failed
        ];
        endpoint =!= $Failed && ! invalidEndpointQ[endpoint] &&
          ! TrueQ[endpoint === 0] &&
          zeroEquivalentQ[endpoint - expectedRootRadicand, 120]
      ]
    ]
  ];
  assert[commonCandidates =!= {},
    label <> " cannot derive its common endpoint radicand."];
  commonRadicand = First@SortBy[
    exactUniqueExpressions[commonCandidates, "common radicands"],
    Hash[#, "SHA256"] &
  ];
  commonEndpointRadicand = Quiet@Check[
    Factor[Together[commonRadicand /. s23 -> 0]],
    $Failed
  ];
  assert[
    commonEndpointRadicand =!= $Failed &&
      zeroEquivalentQ[
        commonEndpointRadicand - expectedRootRadicand,
        120
      ] &&
      AllTrue[
        {1, -1},
        Function[currentSign,
          Module[{root0},
            root0 = Lookup[
              rootByDeltaSign,
              currentSign,
              Missing["Absent"]
            ];
            ! MissingQ[root0] &&
              zeroEquivalentQ[root0^2 - commonEndpointRadicand, 120]
          ]
        ]
      ],
    label <> " common root does not match both physical branches."
  ];
  rootRecords = MapIndexed[
    Function[{rootExpression, position},
      Module[
        {
          physicalBase, ratio, ratioNumerator, ratioDenominator,
          ratioExponent, rootExponent, formula
        },
        physicalBase = rootExpression[[1]] /. physicalSubstitution;
        rootExponent = rootExpression[[2]];
        ratio = Quiet@Check[
          Cancel[Together[physicalBase/commonRadicand]],
          $Failed
        ];
        assert[ratio =!= $Failed,
          label <> " root-radicand ratio reduction failed."];
        ratioNumerator = Numerator[ratio];
        ratioDenominator = Denominator[ratio];
        ratioExponent = Quiet@Check[
          Exponent[ratioNumerator, s23, Min] -
            Exponent[ratioDenominator, s23, Min],
          $Failed
        ];
        assert[
          IntegerQ[ratioExponent] && IntegerQ[2 rootExponent] &&
            IntegerQ[2 ratioExponent rootExponent] &&
            TrueQ[
              Cancel[Together[ratio - s23^ratioExponent]] === 0
            ],
          label <> " found a radical outside the one-root s23 basis."
        ];
        formula = S10CommonRoot^(2 rootExponent) *
          S10EndpointT^(2 ratioExponent rootExponent);
        <|
          "OccurrenceID" -> First[position],
          "Expression" -> rootExpression,
          "RatioExponent" -> ratioExponent,
          "RootExponent" -> rootExponent,
          "Formula" -> formula
        |>
      ]
    ],
    rootPowerExpressions
  ];
  rootPlaceholderRules = Map[
    # ["Expression"] -> S10RootOccurrence[# ["OccurrenceID"]] &,
    rootRecords
  ];
  rootReverseRules = Map[
    S10RootOccurrence[# ["OccurrenceID"]] -> # ["Expression"] &,
    rootRecords
  ];
  rootFormulaRules = Map[
    S10RootOccurrence[# ["OccurrenceID"]] -> # ["Formula"] &,
    rootRecords
  ];
  rootPlaceholderDispatch = Dispatch[rootPlaceholderRules];
  rootReverseDispatch = Dispatch[rootReverseRules];
  rootFormulaDispatch = Dispatch[rootFormulaRules];
  Print["S10_GROUP_PHASE_DONE: label=", label,
    " phase=root-inventory roots=", Length[rootPowerExpressions]];

  Print["S10_GROUP_PHASE_START: label=", label,
    " phase=function-inventory"];
  rawFunctions = exactUniqueExpressions[
    Cases[
      sourceTerms,
      currentFunction : (Log[_] | PolyLog[_, _]) :> currentFunction,
      Infinity
    ],
    "special-function occurrences"
  ];
  assert[
    rawFunctions =!= {} &&
      AllTrue[
        rawFunctions,
        MatchQ[#, Log[_] | PolyLog[2, _]] &
      ],
    label <> " has an empty or unsupported special-function inventory."
  ];
  functionPlaceholderRules = MapIndexed[
    #1 -> S10SharedFunctionOccurrence[First[#2]] &,
    rawFunctions
  ];
  functionReverseRules = MapIndexed[
    S10SharedFunctionOccurrence[First[#2]] -> #1 &,
    rawFunctions
  ];
  functionPlaceholderDispatch = Dispatch[functionPlaceholderRules];
  functionReverseDispatch = Dispatch[functionReverseRules];
  placeholderTerms = sourceTerms /.
    functionPlaceholderDispatch /. rootPlaceholderDispatch;
  reconstructionGate = And @@ MapThread[
    SameQ,
    {
      placeholderTerms /. rootReverseDispatch /. functionReverseDispatch,
      sourceTerms
    }
  ];
  assert[reconstructionGate,
    label <> " literal root/function compression failed reconstruction."];
  compressedTerms = endpointPowerTransform /@
    (placeholderTerms /. rootFormulaDispatch /. physicalSubstitution);
  assert[
    FreeQ[compressedTerms, s23 | _Log | _PolyLog | _S10RootOccurrence],
    label <> " compressed group retains an unresolved endpoint object."
  ];

  normalizeFunctionRecord[currentFunction_, occurrenceID_Integer] := Module[
    {
      transformedFunction, functionKind, functionOrder,
      functionArgument, normalizedArgument, normalizedFunction
    },
    transformedFunction = endpointPowerTransform[
      currentFunction /. rootPlaceholderDispatch /. rootFormulaDispatch /.
        physicalSubstitution
    ];
    functionKind = If[Head[currentFunction] === Log, "Log", "PolyLog"];
    functionOrder = If[
      functionKind === "Log",
      Missing["NotApplicable"],
      currentFunction[[1]]
    ];
    functionArgument = If[
      functionKind === "Log",
      transformedFunction[[1]],
      transformedFunction[[2]]
    ];
    normalizedArgument = Quiet@Check[
      Cancel[Together[functionArgument]],
      $Failed
    ];
    assert[
      normalizedArgument =!= $Failed &&
        FreeQ[normalizedArgument, s23 | _Log | _PolyLog],
      label <> " failed to normalize shared function occurrence " <>
        ToString[occurrenceID] <> "."
    ];
    normalizedFunction = If[
      functionKind === "Log",
      Log[normalizedArgument],
      PolyLog[functionOrder, normalizedArgument]
    ];
    <|
      "OccurrenceID" -> occurrenceID,
      "Kind" -> functionKind,
      "Order" -> functionOrder,
      "NormalizedArgument" -> normalizedArgument,
      "NormalizedFunction" -> normalizedFunction
    |>
  ];
  functionRecords = MapIndexed[
    Function[{currentFunction, currentPosition},
      Module[{answer},
        Print[
          "S10_GROUP_FUNCTION_NORMALIZE_START: label=", label,
          " function=", First[currentPosition], "/", Length[rawFunctions]
        ];
        answer = normalizeFunctionRecord[
          currentFunction,
          First[currentPosition]
        ];
        Print[
          "S10_GROUP_FUNCTION_NORMALIZE_DONE: label=", label,
          " function=", First[currentPosition],
          " valid=", AssociationQ[answer]
        ];
        answer
      ]
    ],
    rawFunctions
  ];
  basisFunctions = exactUniqueExpressions[
    Lookup[functionRecords, "NormalizedFunction"],
    "normalized shared-function basis"
  ];
  basisFunctionHashToID = AssociationThread[
    expressionSHA256Hex /@ basisFunctions,
    Range[Length[basisFunctions]]
  ];
  assert[
    Length[basisFunctionHashToID] === Length[basisFunctions],
    label <> " normalized shared-function basis has a hash collision."
  ];
  functionBasisIDs = Lookup[
    basisFunctionHashToID,
    expressionSHA256Hex /@ Lookup[
      functionRecords,
      "NormalizedFunction"
    ]
  ];
  assert[
    Length[basisFunctions] > 0 &&
      Length[functionBasisIDs] === Length[rawFunctions] &&
      AllTrue[functionBasisIDs, IntegerQ] &&
      FreeQ[functionBasisIDs, _Missing],
    label <> " shared function basis construction failed."
  ];
  Print["S10_GROUP_PHASE_DONE: label=", label,
    " phase=function-inventory occurrences=", Length[rawFunctions],
    " basis=", Length[basisFunctions]];

  commonRadicandT = endpointPowerTransform[commonRadicand];
  deriveRootPolynomial[root0_, maximumOrder_Integer] := Module[
    {
      polynomial = root0, coefficient, equation, solutions,
      currentOrder
    },
    Do[
      coefficient = Unique["S10RootCoefficient"];
      equation = Coefficient[
        Normal@Series[
          (polynomial + coefficient S10EndpointT^currentOrder)^2 -
            commonRadicandT,
          {S10EndpointT, 0, currentOrder}
        ],
        S10EndpointT,
        currentOrder
      ] == 0;
      solutions = Solve[equation, coefficient];
      If[Length[solutions] =!= 1, Return[$Failed]];
      polynomial = polynomial +
        (coefficient /. First[solutions]) *
          S10EndpointT^currentOrder;,
      {currentOrder, 1, maximumOrder}
    ];
    polynomial
  ];
  rootResidualCoefficients[polynomial_, maximumOrder_Integer] := Table[
    Factor[Together[Coefficient[
      Normal@Series[
        polynomial^2 - commonRadicandT,
        {S10EndpointT, 0, maximumOrder}
      ],
      S10EndpointT,
      currentOrder
    ]]],
    {currentOrder, 0, maximumOrder}
  ];
  rootProbeOrder = 6;
  rootProbePolynomials = Map[
    deriveRootPolynomial[#, rootProbeOrder] &,
    rootByDeltaSign
  ];
  assert[FreeQ[Values[rootProbePolynomials], $Failed],
    label <> " root-probe polynomial derivation failed."];

  Print["S10_GROUP_PHASE_START: label=", label,
    " phase=structural-support"];
  termFactorLists = Map[
    If[Head[#] === Times, List @@ #, {#}] &,
    compressedTerms
  ];
  supportFactors = exactUniqueExpressions[
    Flatten[termFactorLists, 1],
    "compressed top-level factors"
  ];
  supportFactorHashes = expressionSHA256Hex /@ supportFactors;
  supportFactorHashToID = AssociationThread[
    supportFactorHashes,
    Range[Length[supportFactors]]
  ];
  assert[
    Length[supportFactorHashToID] === Length[supportFactors],
    label <> " compressed top-level factors have a hash collision."
  ];
  termSupportFactorIDs = Map[
    Lookup[supportFactorHashToID, expressionSHA256Hex /@ #] &,
    termFactorLists
  ];
  assert[
    FreeQ[termSupportFactorIDs, _Missing] &&
      Length[termSupportFactorIDs] === Length[compressedTerms],
    label <> " cannot map its compressed factors."
  ];
  supportMinimumPower[
      currentFactor_, rootPolynomial_, currentSign_Integer,
      currentPosition_Integer
    ] := Module[
    {parts, partSeries, partMinimumPowers, finitePartMinimumPowers},
    Print[
      "S10_GROUP_SUPPORT_FACTOR_START: label=", label,
      " rootSign=", currentSign,
      " factor=", currentPosition, "/", Length[supportFactors]
    ];
    parts = If[
      Head[currentFactor] === Plus,
      List @@ currentFactor,
      {currentFactor}
    ];
    partSeries = Map[
      Function[currentPart,
        If[
          FreeQ[currentPart, S10EndpointT | S10CommonRoot],
          currentPart,
          CheckAbort[
            Quiet@Series[
              currentPart /.
                S10CommonRoot -> rootPolynomial /. qcdRules,
              {S10EndpointT, 0, 0}
            ],
            $Failed
          ]
        ]
      ],
      parts
    ];
    assert[
      FreeQ[partSeries, $Failed] &&
        AllTrue[partSeries, seriesKnownThroughZeroQ],
      label <> " structural-support factor " <>
        ToString[currentPosition] <> " failed on root sign " <>
        ToString[currentSign] <> "."
    ];
    partMinimumPowers = seriesMinimumPower /@ partSeries;
    finitePartMinimumPowers = DeleteCases[
      partMinimumPowers,
      Infinity
    ];
    assert[
      AllTrue[finitePartMinimumPowers, IntegerQ],
      label <> " structural-support factor has a noninteger power."
    ];
    Print[
      "S10_GROUP_SUPPORT_FACTOR_DONE: label=", label,
      " rootSign=", currentSign,
      " factor=", currentPosition,
      " minimumPowerBound=",
      If[finitePartMinimumPowers === {}, Infinity,
        Min[finitePartMinimumPowers]]
    ];
    If[
      finitePartMinimumPowers === {},
      Infinity,
      Min[finitePartMinimumPowers]
    ]
  ];
  supportMinimumPowersBySign = Association@Table[
    rootSign -> MapIndexed[
      supportMinimumPower[
        #1,
        rootProbePolynomials[rootSign],
        rootSign,
        First[#2]
      ] &,
      supportFactors
    ],
    {rootSign, {1, -1}}
  ];
  termSupportBoundsBySign = Association@Table[
    rootSign -> Map[
      Function[currentFactorIDs,
        Module[{currentBounds},
          currentBounds =
            supportMinimumPowersBySign[rootSign][[currentFactorIDs]];
          If[MemberQ[currentBounds, Infinity], Infinity,
            Total[currentBounds]]
        ]
      ],
      termSupportFactorIDs
    ],
    {rootSign, {1, -1}}
  ];
  finiteSupportBounds = DeleteCases[
    Flatten[Values[termSupportBoundsBySign]],
    Infinity
  ];
  assert[
    finiteSupportBounds =!= {} &&
      AllTrue[finiteSupportBounds, IntegerQ],
    label <> " grouped structural support is not integer-powered in t."
  ];
  requiredFunctionSeriesOrder = Max[0, -Min[finiteSupportBounds]];
  assert[requiredFunctionSeriesOrder <= 8,
    label <> " requires shared function order " <>
      ToString[requiredFunctionSeriesOrder] <>
      ", beyond the validated bounded evaluator."];
  requiredRootSeriesOrder = Max[
    rootProbeOrder,
    requiredFunctionSeriesOrder + 4
  ];
  Print["S10_GROUP_PHASE_DONE: label=", label,
    " phase=structural-support factors=", Length[supportFactors],
    " functionOrder=", requiredFunctionSeriesOrder,
    " rootOrder=", requiredRootSeriesOrder];
  rootPolynomials = Map[
    deriveRootPolynomial[#, requiredRootSeriesOrder] &,
    rootByDeltaSign
  ];
  rootResiduals = Map[
    rootResidualCoefficients[#, requiredRootSeriesOrder] &,
    rootPolynomials
  ];
  rootGate = TrueQ[
    FreeQ[Values[rootPolynomials], $Failed] &&
      AllTrue[Flatten[Values[rootResiduals]], # === 0 &]
  ];
  assert[rootGate,
    label <> " common-root defining-equation jet failed."];

  seriesKnownThroughOrderQ[value_, maximumOrder_Integer] := Module[
    {embeddedSeries, nonSeriesRemainder},
    Which[
      Head[value] === SeriesData,
        TrueQ[
          value[[1]] === S10EndpointT && value[[2]] === 0 &&
            value[[5]]/value[[6]] > maximumOrder
        ],
      TrueQ[value === 0],
        True,
      FreeQ[value, S10EndpointT],
        True,
      True,
        embeddedSeries = Cases[value, _SeriesData, {0, Infinity}];
        nonSeriesRemainder = value /. _SeriesData -> 0;
        TrueQ[
          embeddedSeries =!= {} &&
            AllTrue[
              embeddedSeries,
              Function[currentSeries,
                currentSeries[[1]] === S10EndpointT &&
                  currentSeries[[2]] === 0 &&
                  currentSeries[[5]]/currentSeries[[6]] > maximumOrder
              ]
            ] &&
            FreeQ[nonSeriesRemainder, S10EndpointT]
        ]
    ]
  ];
  normalizeGeneratedEndpointLogs[value_, maximumOrder_Integer] := Module[
    {
      endpointLogs, endpointLogRules, normalizedValue
    },
    endpointLogs = DeleteDuplicates@Cases[
      value,
      currentLog : Log[currentArgument_] /;
          ! FreeQ[currentArgument, S10EndpointT] :> currentLog,
      Infinity
    ];
    endpointLogRules = Map[
      Function[currentLog,
        Module[
          {
            argumentSeries, minimumPower, leadingCoefficient,
            unitSeries, replacement
          },
          argumentSeries = CheckAbort[
            Quiet@Series[
              currentLog[[1]],
              {S10EndpointT, 0, maximumOrder + 2}
            ],
            $Failed
          ];
          If[argumentSeries === $Failed, Return[$Failed]];
          minimumPower = seriesMinimumPower[argumentSeries];
          If[! IntegerQ[minimumPower],
            Return[$Failed]
          ];
          leadingCoefficient = Coefficient[
            Normal[argumentSeries],
            S10EndpointT,
            minimumPower
          ];
          If[
            invalidEndpointQ[leadingCoefficient] ||
              TrueQ[leadingCoefficient === 0],
            Return[$Failed]
          ];
          unitSeries = CheckAbort[
            Quiet@Series[
              Normal[argumentSeries]/(
                leadingCoefficient S10EndpointT^minimumPower
              ),
              {S10EndpointT, 0, maximumOrder}
            ],
            $Failed
          ];
          If[
            unitSeries === $Failed ||
              ! zeroEquivalentQ[
                (Normal[unitSeries] /. S10EndpointT -> 0) - 1,
                60
              ],
            Return[$Failed]
          ];
          replacement = minimumPower S10EndpointLog +
            Log[leadingCoefficient] +
            Normal@Series[
              Log[Normal[unitSeries]],
              {S10EndpointT, 0, maximumOrder}
            ];
          currentLog -> replacement
        ]
      ],
      endpointLogs
    ];
    If[MemberQ[endpointLogRules, $Failed], Return[$Failed]];
    normalizedValue = CheckAbort[
      Quiet@Series[
        Normal[value] /. endpointLogRules,
        {S10EndpointT, 0, maximumOrder}
      ],
      $Failed
    ];
    If[
      normalizedValue === $Failed ||
        Cases[
          normalizedValue,
          Log[currentArgument_] /;
            ! FreeQ[currentArgument, S10EndpointT],
          Infinity
        ] =!= {},
      $Failed,
      normalizedValue
    ]
  ];
  deriveFunctionSeries[
      normalizedFunction_, rootPolynomial_, maximumOrder_Integer
    ] := Module[
    {rawSeries, normalizedSeries},
    rawSeries = CheckAbort[
      Quiet@Series[
        normalizedFunction /.
          S10CommonRoot -> rootPolynomial,
        {S10EndpointT, 0, maximumOrder}
      ],
      $Failed
    ];
    If[rawSeries === $Failed, Return[$Failed]];
    normalizedSeries = normalizeGeneratedEndpointLogs[
      rawSeries,
      maximumOrder
    ];
    If[
      normalizedSeries === $Failed ||
        ! seriesKnownThroughOrderQ[normalizedSeries, maximumOrder] ||
        ! FreeQ[
          normalizedSeries,
          S10CommonRoot | _Series | _SeriesCoefficient |
            _ConditionalExpression
        ],
      $Failed,
      normalizedSeries
    ]
  ];
  factorSeriesCoefficientData[
      currentFactor_, currentSubstitutionDispatch_,
      maximumOrder_Integer
    ] := Module[
    {
      parts, transformedParts, partSeries, partMinimumPowers,
      finitePartMinimumPowers, minimumPowerBound,
      coefficientPowers, coefficients
    },
    parts = If[
      Head[currentFactor] === Plus,
      List @@ currentFactor,
      {currentFactor}
    ];
    transformedParts = parts /. currentSubstitutionDispatch;
    If[
      ! FreeQ[
        transformedParts,
        s23 | S10CommonRoot | _S10RootOccurrence |
          _S10SharedFunctionOccurrence
      ],
      Return[$Failed]
    ];
    partSeries = Map[
      Function[currentPart,
        If[
          FreeQ[currentPart, S10EndpointT],
          currentPart,
          CheckAbort[
            Quiet@Series[
              currentPart,
              {S10EndpointT, 0, maximumOrder}
            ],
            $Failed
          ]
        ]
      ],
      transformedParts
    ];
    If[
      ! FreeQ[partSeries, $Failed] ||
        ! AllTrue[
          partSeries,
          seriesKnownThroughOrderQ[#, maximumOrder] &
        ],
      Return[$Failed]
    ];
    partMinimumPowers = seriesMinimumPower /@ partSeries;
    finitePartMinimumPowers = DeleteCases[
      partMinimumPowers,
      Infinity
    ];
    If[
      ! AllTrue[finitePartMinimumPowers, IntegerQ],
      Return[$Failed]
    ];
    minimumPowerBound = If[
      finitePartMinimumPowers === {},
      Infinity,
      Min[finitePartMinimumPowers]
    ];
    coefficientPowers = If[
      minimumPowerBound === Infinity ||
        minimumPowerBound > maximumOrder,
      {},
      Range[minimumPowerBound, maximumOrder]
    ];
    coefficients = AssociationMap[
      Function[currentPower,
        Total[
          Coefficient[
            Normal[#],
            S10EndpointT,
            currentPower
          ] & /@ partSeries
        ]
      ],
      coefficientPowers
    ];
    If[
      ! FreeQ[
        Values[coefficients],
        s23 | S10EndpointT | S10CommonRoot | _S10RootOccurrence |
          _S10SharedFunctionOccurrence | _Series | _SeriesCoefficient
      ],
      Return[$Failed]
    ];
    <|
      "MinimumPowerBound" -> minimumPowerBound,
      "MaximumPower" -> maximumOrder,
      "Coefficients" -> coefficients
    |>
  ];
  convolveLaurentCoefficientData[
      currentFactorData_List, maximumOrder_Integer
    ] := Module[
    {
      answer = <|0 -> 1|>, nextAnswer, remainingMinimumBounds,
      maximumPartialPower, currentFactor, totalPower,
      currentFactorIndex
    },
    Do[
      currentFactor = currentFactorData[[currentFactorIndex]];
      remainingMinimumBounds = Lookup[
        Drop[currentFactorData, currentFactorIndex],
        "MinimumPowerBound"
      ];
      If[MemberQ[remainingMinimumBounds, Infinity],
        Return[<||>]
      ];
      maximumPartialPower = maximumOrder -
        Total[remainingMinimumBounds];
      nextAnswer = <||>;
      KeyValueMap[
        Function[{leftPower, leftCoefficient},
          KeyValueMap[
            Function[{rightPower, rightCoefficient},
              totalPower = leftPower + rightPower;
              If[totalPower <= maximumPartialPower,
                AssociateTo[
                  nextAnswer,
                  totalPower ->
                    Lookup[nextAnswer, totalPower, 0] +
                      leftCoefficient rightCoefficient
                ]
              ]
            ],
            currentFactor["Coefficients"]
          ]
        ],
        answer
      ];
      answer = nextAnswer;,
      {currentFactorIndex, Length[currentFactorData]}
    ];
    KeySelect[answer, # <= maximumOrder &]
  ];

  Print["S10_GROUP_PHASE_START: label=", label,
    " phase=shared-function-series"];
  functionSeriesBySign = Association@Table[
    rootSign -> MapIndexed[
      Function[{basisFunction, basisPosition},
        Module[{answer},
          Print[
            "S10_GROUP_FUNCTION_START: label=", label,
            " rootSign=", rootSign,
            " basis=", First[basisPosition], "/", Length[basisFunctions]
          ];
          answer = deriveFunctionSeries[
            basisFunction,
            rootPolynomials[rootSign],
            requiredFunctionSeriesOrder
          ];
          Print[
            "S10_GROUP_FUNCTION_DONE: label=", label,
            " rootSign=", rootSign,
            " basis=", First[basisPosition],
            " valid=", answer =!= $Failed
          ];
          answer
        ]
      ],
      basisFunctions
    ],
    {rootSign, {1, -1}}
  ];
  functionSeriesGate = TrueQ[
    FreeQ[Values[functionSeriesBySign], $Failed] &&
      AllTrue[
        Flatten[Values[functionSeriesBySign]],
        seriesKnownThroughOrderQ[#, requiredFunctionSeriesOrder] &
      ]
  ];
  assert[functionSeriesGate,
    label <> " shared group function series failed."];
  Print["S10_GROUP_PHASE_DONE: label=", label,
    " phase=shared-function-series basis=", Length[basisFunctions]];

  Do[
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && rootSign deltaPhysical > 0;
    branchFunctionRules = MapThread[
      S10SharedFunctionOccurrence[#1] ->
        functionSeriesBySign[rootSign][[#2]] &,
      {Range[Length[rawFunctions]], functionBasisIDs}
    ];
    branchSubstitutionDispatch = Dispatch@Join[
      {S10CommonRoot -> rootPolynomials[rootSign]},
      branchFunctionRules,
      qcdRules
    ];
    Print["S10_GROUP_PHASE_START: label=", label,
      " phase=branch-factor-ledger rootSign=", rootSign];
    branchBaseFactorLists = Map[
      If[Head[#] === Times, List @@ #, {#}] &,
      compressedTerms
    ];
    branchFactorizationGate = And @@ MapThread[
      SameQ[Times @@ #1, #2] &,
      {branchBaseFactorLists, compressedTerms}
    ];
    assert[branchFactorizationGate,
      label <> " branch factor split failed exact reconstruction."];
    branchFactorLists = MapIndexed[
      Function[{currentFactorList, currentPosition},
        Module[{answer},
          Print[
            "S10_GROUP_LEDGER_TERM_TRANSFORM_START: label=", label,
            " rootSign=", rootSign,
            " term=", First[currentPosition], "/",
            Length[branchBaseFactorLists]
          ];
          answer = Join[{S10EndpointT^2}, currentFactorList];
          Print[
            "S10_GROUP_LEDGER_TERM_TRANSFORM_DONE: label=", label,
            " rootSign=", rootSign,
            " term=", First[currentPosition],
            " factors=", Length[answer]
          ];
          answer
        ]
      ],
      branchBaseFactorLists
    ];
    assert[
      FreeQ[
        Flatten[branchFactorLists, 1],
        s23 | _Log | _PolyLog | _S10RootOccurrence
      ],
      label <> " branch factor ledger retains an uncompressed object."
    ];
    Print[
      "S10_GROUP_LEDGER_HASH_START: label=", label,
      " rootSign=", rootSign,
      " factors=", Length[Flatten[branchFactorLists, 1]]
    ];
    branchFactorHashGroups = GatherBy[
      Flatten[branchFactorLists, 1],
      expressionSHA256Hex
    ];
    assert[
      AllTrue[
        branchFactorHashGroups,
        Function[currentGroup,
          AllTrue[Rest[currentGroup], SameQ[First[currentGroup], #] &]
        ]
      ],
      label <> " branch factor ledger has a SHA-256 collision."
    ];
    branchUniqueFactors = First /@ branchFactorHashGroups;
    Print[
      "S10_GROUP_LEDGER_HASH_DONE: label=", label,
      " rootSign=", rootSign,
      " uniqueFactors=", Length[branchUniqueFactors]
    ];
    branchFactorHashes = expressionSHA256Hex /@ branchUniqueFactors;
    branchFactorHashToID = AssociationThread[
      branchFactorHashes,
      Range[Length[branchUniqueFactors]]
    ];
    assert[
      Length[branchFactorHashToID] === Length[branchUniqueFactors],
      label <> " branch factor ledger hash map is inconsistent."
    ];
    branchTermFactorIDs = Map[
      Lookup[branchFactorHashToID, expressionSHA256Hex /@ #] &,
      branchFactorLists
    ];
    assert[
      FreeQ[branchTermFactorIDs, _Missing],
      label <> " branch factor ledger cannot map a term factor."
    ];
    branchPilotFactorData = MapIndexed[
      Function[{currentFactor, currentPosition},
        Module[{answer},
          Print[
            "S10_GROUP_LEDGER_FACTOR_START: label=", label,
            " rootSign=", rootSign,
            " phase=pilot factor=", First[currentPosition], "/",
            Length[branchUniqueFactors]
          ];
          answer = factorSeriesCoefficientData[
            currentFactor,
            branchSubstitutionDispatch,
            0
          ];
          Print[
            "S10_GROUP_LEDGER_FACTOR_DONE: label=", label,
            " rootSign=", rootSign,
            " phase=pilot factor=", First[currentPosition],
            " valid=", AssociationQ[answer]
          ];
          answer
        ]
      ],
      branchUniqueFactors
    ];
    assert[
      FreeQ[branchPilotFactorData, $Failed] &&
        AllTrue[branchPilotFactorData, AssociationQ],
      label <> " branch factor pilot failed on root sign " <>
        ToString[rootSign] <> "."
    ];
    branchFactorMinimumPowerBounds = Lookup[
      branchPilotFactorData,
      "MinimumPowerBound"
    ];
    branchTermMinimumPowerBounds = Map[
      Function[currentFactorIDs,
        Module[{currentBounds},
          currentBounds =
            branchFactorMinimumPowerBounds[[currentFactorIDs]];
          If[MemberQ[currentBounds, Infinity], Infinity,
            Total[currentBounds]]
        ]
      ],
      branchTermFactorIDs
    ];
    branchRequiredFactorMaxima = ConstantArray[
      0,
      Length[branchUniqueFactors]
    ];
    MapThread[
      Function[{currentFactorIDs, currentTermMinimum},
        If[currentTermMinimum =!= Infinity,
          Scan[
            Function[currentFactorID,
              branchRequiredFactorMaxima[[currentFactorID]] = Max[
                branchRequiredFactorMaxima[[currentFactorID]],
                -(
                  currentTermMinimum -
                    branchFactorMinimumPowerBounds[[currentFactorID]]
                )
              ]
            ],
            currentFactorIDs
          ]
        ]
      ],
      {branchTermFactorIDs, branchTermMinimumPowerBounds}
    ];
    assert[
      AllTrue[branchRequiredFactorMaxima, IntegerQ] &&
        Max[branchRequiredFactorMaxima] <= 12,
      label <> " branch factor ledger requires unbounded support."
    ];
    branchFactorData = MapThread[
      Function[{pilotData, currentFactor, neededMaximum},
        If[
          neededMaximum <= 0,
          pilotData,
          Module[{answer},
            Print[
              "S10_GROUP_LEDGER_FACTOR_START: label=", label,
              " rootSign=", rootSign,
              " phase=extend maximum=", neededMaximum
            ];
            answer = factorSeriesCoefficientData[
              currentFactor,
              branchSubstitutionDispatch,
              neededMaximum
            ];
            Print[
              "S10_GROUP_LEDGER_FACTOR_DONE: label=", label,
              " rootSign=", rootSign,
              " phase=extend maximum=", neededMaximum,
              " valid=", AssociationQ[answer]
            ];
            answer
          ]
        ]
      ],
      {
        branchPilotFactorData,
        branchUniqueFactors,
        branchRequiredFactorMaxima
      }
    ];
    assert[
      FreeQ[branchFactorData, $Failed] &&
        AllTrue[branchFactorData, AssociationQ],
      label <> " branch factor extension failed on root sign " <>
        ToString[rootSign] <> "."
    ];
    branchTermCoefficientData = MapIndexed[
      Function[{currentFactorIDs, currentPosition},
        Print[
          "S10_GROUP_LEDGER_TERM: label=", label,
          " rootSign=", rootSign,
          " term=", First[currentPosition], "/",
          Length[branchTermFactorIDs]
        ];
        convolveLaurentCoefficientData[
          branchFactorData[[currentFactorIDs]],
          0
        ]
      ],
      branchTermFactorIDs
    ];
    assert[
      AllTrue[branchTermCoefficientData, AssociationQ] &&
        FreeQ[
          Values /@ branchTermCoefficientData,
          S10EndpointT | _Series | _SeriesCoefficient
        ],
      label <> " branch coefficient ledger is unresolved."
    ];
    branchTotalCoefficients = <||>;
    Scan[
      Function[currentTermCoefficients,
        KeyValueMap[
          Function[{currentPower, currentCoefficient},
            AssociateTo[
              branchTotalCoefficients,
              currentPower ->
                Lookup[branchTotalCoefficients, currentPower, 0] +
                  currentCoefficient
            ]
          ],
          currentTermCoefficients
        ]
      ],
      branchTermCoefficientData
    ];
    negativePowers = If[
      Min[DeleteCases[branchTermMinimumPowerBounds, Infinity]] < 0,
      Range[
        Min[DeleteCases[branchTermMinimumPowerBounds, Infinity]],
        -1
      ],
      {}
    ];
    negativeResiduals = AssociationMap[
      Lookup[branchTotalCoefficients, #, 0] &,
      negativePowers
    ];
    assert[
      AllTrue[
        Values[negativeResiduals],
        exactPhysicalZeroQ[#, branchAssumptions] &
      ],
      label <> " retains a negative endpoint-coordinate power on root " <>
        "sign " <> ToString[rootSign] <> "."
    ];
    finiteCoefficient = Lookup[branchTotalCoefficients, 0, 0];
    assert[PolynomialQ[finiteCoefficient, S10EndpointLog],
      label <> " finite group coefficient is not polynomial in its " <>
        "endpoint logarithm."];
    maximumLogDegree = Replace[
      Exponent[finiteCoefficient, S10EndpointLog],
      -Infinity -> 0
    ];
    logPowers = If[maximumLogDegree > 0,
      Range[maximumLogDegree, 1, -1],
      {}
    ];
    logResiduals = AssociationMap[
      Coefficient[finiteCoefficient, S10EndpointLog, #] &,
      logPowers
    ];
    assert[
      AllTrue[
        Values[logResiduals],
        exactPhysicalZeroQ[#, branchAssumptions] &
      ],
      label <> " retains an endpoint logarithm on root sign " <>
        ToString[rootSign] <> "."
    ];
    branchConstant = finiteCoefficient /. S10EndpointLog -> 0;
    assert[
      ! invalidEndpointQ[branchConstant] &&
        FreeQ[
          branchConstant,
          s23 | S10EndpointT | S10EndpointLog | S10CommonRoot |
            _S10RootOccurrence | _S10SharedFunctionOccurrence |
            _Series | _SeriesCoefficient
        ],
      label <> " has an invalid finite group value on root sign " <>
        ToString[rootSign] <> "."
    ];
    branchResults[rootSign] = branchConstant;
    branchCertificates[rootSign] = <|
      "TermMinimumPowerBounds" -> branchTermMinimumPowerBounds,
      "UniqueFactorCount" -> Length[branchUniqueFactors],
      "MaximumFactorOrder" -> Max[branchRequiredFactorMaxima],
      "NegativePowersChecked" -> negativePowers,
      "NegativePowerResidualsZero" -> True,
      "EndpointLogPowersChecked" -> logPowers,
      "EndpointLogResidualsZero" -> True,
      "FiniteCoefficientSHA256" ->
        expressionSHA256Hex[branchConstant]
    |>;
    Print[
      "S10_GROUP_BRANCH_COMPLETE: label=", label,
      " rootSign=", rootSign,
      " minimumPowerBound=",
      Min[DeleteCases[branchTermMinimumPowerBounds, Infinity]],
      " logDegree=", maximumLogDegree
    ];
    Print["S10_GROUP_PHASE_DONE: label=", label,
      " phase=branch-factor-ledger rootSign=", rootSign,
      " factors=", Length[branchUniqueFactors]];
    Clear[
      branchBaseFactorLists, branchFactorizationGate,
      branchSubstitutionDispatch,
      branchFactorLists, branchFactorHashGroups,
      branchUniqueFactors, branchPilotFactorData, branchFactorData,
      branchTermCoefficientData, branchTotalCoefficients,
      negativeResiduals, finiteCoefficient, logResiduals,
      branchConstant
    ];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];

  groupResult = Piecewise[
    {{branchResults[1] /. inverseSubstitution, originalDelta >= 0}},
    branchResults[-1] /. inverseSubstitution
  ];
  sourceHashesAfter = Hash[#, "SHA256"] & /@ sourceTerms;
  assert[
    sourceHashesAfter === sourceHashesBefore &&
      ! invalidEndpointQ[groupResult] &&
      FreeQ[
        groupResult,
        s23 | S10EndpointT | S10EndpointLog | S10CommonRoot |
          _S10RootOccurrence | _S10SharedFunctionOccurrence |
          _Series | _SeriesCoefficient
      ],
    label <> " grouped Laurent result is invalid or changed its source."
  ];
  <|
    "PoleCoefficient" -> 0,
    "FiniteCoefficient" -> groupResult,
    "RequiredPoleSubtraction" -> False,
    "FirstMethod" -> "physical-branch grouped Laurent",
    "AbsorbedMethod" ->
      "absorbed into pre-individual physical-branch group",
    "Certificate" -> <|
      "EvaluatorVersion" -> coupledGroupSeriesEvaluatorVersion,
      "SourceIndices" -> sourceIndices,
      "RootOccurrenceCount" -> Length[rootPowerExpressions],
      "CommonRadicandSHA256" ->
        expressionSHA256Hex[commonRadicand],
      "FunctionOccurrenceCount" -> Length[rawFunctions],
      "SharedFunctionBasisCount" -> Length[basisFunctions],
      "StructuralSupportFactorCount" -> Length[supportFactors],
      "StructuralTermPowerBoundsByBranch" ->
        termSupportBoundsBySign,
      "RequiredFunctionSeriesOrder" ->
        requiredFunctionSeriesOrder,
      "RequiredRootSeriesOrder" -> requiredRootSeriesOrder,
      "RootResidualsZero" -> rootGate,
      "AllFunctionSeriesResolved" -> functionSeriesGate,
      "LiteralReconstruction" -> reconstructionGate,
      "BranchCertificates" -> branchCertificates,
      "ExactSourceUnchanged" -> True
    |>
  |>
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

singularLogTermIndices[terms_List] := Flatten@MapIndexed[
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

  This is the corrected low-memory Hqg S10 algorithm.
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

endpointWorkerEvaluate[input_List] := MemoryConstrained[
  endpointTermLaurent[input[[1]], input[[2]], input[[3]], input[[4]]],
  endpointWorkerMemoryLimitBytes,
  $Failed
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
(* Exact coefficientwise alpha-two helpers accepted by the S10 diagnostic. *)
alpha2ExactAgreementQ[left_, right_] := If[
  SameQ[left, right],
  True,
  TrueQ[
    Quiet@Check[
      TimeConstrained[Cancel[Together[left - right]], 300, $Failed],
      $Failed
    ] === 0
  ]
];

alpha2SeriesDataCoefficientAssociation[expression_] := Module[
  {series, parts, powers, coefficients},
  series = Quiet@Check[
    TimeConstrained[Series[expression, {s23, 0, 0}], 60, $Failed],
    $Failed
  ];
  If[series === $Failed || ! FreeQ[series, _Series], Return[$Failed]];
  If[Head[series] =!= SeriesData,
    Return[
      If[
        ! invalidEndpointQ[series] && FreeQ[series, s23],
        <|0 -> series|>,
        $Failed
      ]
    ]
  ];
  parts = List @@ series;
  If[
    Length[parts] =!= 6 || ! SameQ[parts[[1]], s23] ||
      ! TrueQ[parts[[2]] === 0] || ! ListQ[parts[[3]]] ||
      ! IntegerQ[parts[[4]]] || ! IntegerQ[parts[[5]]] ||
      ! IntegerQ[parts[[6]]] || ! TrueQ[parts[[6]] > 0],
    Return[$Failed]
  ];
  powers = Range[parts[[4]], parts[[5]] - 1]/parts[[6]];
  coefficients = parts[[3]];
  If[
    Length[coefficients] > Length[powers] ||
      ! AllTrue[powers, TrueQ[# <= 0] &] ||
      ! AllTrue[coefficients, FreeQ[#, s23] &],
    Return[$Failed]
  ];
  coefficients = PadRight[coefficients, Length[powers], 0];
  Join[<|0 -> 0|>, AssociationThread[powers, coefficients]]
];

alpha2CoefficientChunkWorker[input_List] := Module[
  {
    sourcePositions, addends, perAddendPowerAssociations = {},
    structuralMismatchPositions = {}, localPosition, sourcePosition,
    addend, seriesDataRecord, seriesCoefficientValue,
    seriesDataConstant, agreementGate, chunkPowers, chunkPowerSums
  },
  If[Length[input] =!= 2,
    Return[<|
      "Success" -> False,
      "FailureReason" -> "MalformedChunkInput",
      "KernelID" -> $KernelID
    |>]
  ];
  sourcePositions = input[[1]];
  addends = input[[2]];
  If[
    ! ListQ[sourcePositions] || ! ListQ[addends] ||
      Length[sourcePositions] =!= Length[addends] ||
      sourcePositions === {},
    Return[<|
      "Success" -> False,
      "FailureReason" -> "InconsistentChunkInventory",
      "KernelID" -> $KernelID
    |>]
  ];
  Do[
    sourcePosition = sourcePositions[[localPosition]];
    addend = addends[[localPosition]];
    seriesDataRecord = alpha2SeriesDataCoefficientAssociation[addend];
    If[! AssociationQ[seriesDataRecord],
      Return[<|
        "Success" -> False,
        "FailureReason" -> "SeriesDataExtraction",
        "FailureSourcePosition" -> sourcePosition,
        "KernelID" -> $KernelID
      |>]
    ];
    seriesCoefficientValue = Quiet@Check[
      TimeConstrained[
        SeriesCoefficient[addend, {s23, 0, 0}],
        60,
        $Failed
      ],
      $Failed
    ];
    If[
      seriesCoefficientValue === $Failed ||
        invalidEndpointQ[seriesCoefficientValue] ||
        ! FreeQ[seriesCoefficientValue, s23],
      Return[<|
        "Success" -> False,
        "FailureReason" -> "SeriesCoefficientExtraction",
        "FailureSourcePosition" -> sourcePosition,
        "KernelID" -> $KernelID
      |>]
    ];
    seriesDataConstant = Lookup[seriesDataRecord, 0, 0];
    agreementGate = alpha2ExactAgreementQ[
      seriesDataConstant,
      seriesCoefficientValue
    ];
    If[! TrueQ[agreementGate],
      Return[<|
        "Success" -> False,
        "FailureReason" -> "ConstantCoefficientDisagreement",
        "FailureSourcePosition" -> sourcePosition,
        "KernelID" -> $KernelID
      |>]
    ];
    If[! SameQ[seriesDataConstant, seriesCoefficientValue],
      AppendTo[structuralMismatchPositions, sourcePosition]
    ];
    AppendTo[perAddendPowerAssociations, seriesDataRecord];
    Clear[
      addend,
      seriesDataRecord,
      seriesCoefficientValue,
      seriesDataConstant
    ];
    If[Mod[localPosition, 5] === 0, ClearSystemCache[]],
    {localPosition, Length[addends]}
  ];
  chunkPowers = Sort@DeleteDuplicates@Flatten[
    Keys /@ perAddendPowerAssociations
  ];
  If[
    chunkPowers === {} || ! MemberQ[chunkPowers, 0] ||
      ! AllTrue[chunkPowers, NumericQ[#] && TrueQ[# <= 0] &],
    Return[<|
      "Success" -> False,
      "FailureReason" -> "ChunkLaurentPowerInventory",
      "KernelID" -> $KernelID
    |>]
  ];
  chunkPowerSums = AssociationMap[
    Function[power,
      Total[Lookup[perAddendPowerAssociations, power, 0]]
    ],
    chunkPowers
  ];
  <|
    "Success" -> True,
    "KernelID" -> $KernelID,
    "SourcePositionRange" -> MinMax[sourcePositions],
    "ProcessedCount" -> Length[sourcePositions],
    "StructuralMismatchPositions" -> structuralMismatchPositions,
    "PowerSums" -> chunkPowerSums
  |>
];

parallelAlpha2InvalidFactorEndpoint[
    invalidFactor_, label_String
  ] := Module[
  {
    addends, chunkCount, chunkSize, chunks, waves, waveIndex,
    waveChunks, waveInputs, waveResults, currentIDs,
    waveKernelIDSets = {}, chunkResults = {}, chunkPowerSums,
    laurentPowers, coefficientSums, negativePowers,
    negativeReducedSums, endpoint, endpointSHA256Hex
  },
  assert[Head[invalidFactor] === Plus,
    label <> " invalid alpha-two factor is not additive."];
  addends = List @@ invalidFactor;
  assert[SameQ[invalidFactor, Total[addends]],
    label <> " invalid alpha-two addends do not reconstruct their factor."];
  chunkCount = 2 requestedParallelKernels;
  chunkSize = Ceiling[Length[addends]/chunkCount];
  chunks = Partition[Range[Length[addends]], UpTo[chunkSize]];
  waves = Partition[chunks, UpTo[requestedParallelKernels]];
  assert[Sort@Flatten[chunks] === Range[Length[addends]],
    label <> " alpha-two worker chunks do not cover every addend."];
  Do[
    ensureEndpointParallelKernels[
      label <> " alpha-two wave " <> ToString[waveIndex]
    ];
    currentIDs = Sort[ParallelEvaluate[$KernelID]];
    AppendTo[waveKernelIDSets, currentIDs];
    waveChunks = waves[[waveIndex]];
    waveInputs = Map[
      Function[chunk, {chunk, addends[[chunk]]}],
      waveChunks
    ];
    Print[
      "S10_ALPHA2_ENDPOINT_WAVE: label=", label,
      " wave=", waveIndex, "/", Length[waves],
      " state=start chunkRanges=", InputForm[MinMax /@ waveChunks]
    ];
    waveResults = Quiet@Check[
      ParallelMap[
        alpha2CoefficientChunkWorker,
        waveInputs,
        Method -> "FinestGrained"
      ],
      $Failed
    ];
    closeEndpointParallelKernels[
      label <> " alpha-two wave " <> ToString[waveIndex]
    ];
    assert[
      ListQ[waveResults] &&
        Length[waveResults] === Length[waveChunks] &&
        AllTrue[waveResults, AssociationQ] &&
        AllTrue[waveResults, TrueQ[Lookup[#, "Success", False]] &],
      label <> " alpha-two worker wave failed: " <>
        ToString[InputForm[waveResults]]
    ];
    Print[
      "S10_ALPHA2_ENDPOINT_WAVE: label=", label,
      " wave=", waveIndex, "/", Length[waves],
      " state=complete processed=",
      Total[Lookup[waveResults, "ProcessedCount"]],
      " mismatchCount=",
      Length@Flatten[
        Lookup[waveResults, "StructuralMismatchPositions"]
      ]
    ];
    chunkResults = Join[chunkResults, waveResults];
    Clear[waveInputs, waveResults];
    ClearSystemCache[],
    {waveIndex, Length[waves]}
  ];
  alpha2ParallelKernelIDSetsSeen = Join[
    alpha2ParallelKernelIDSetsSeen,
    waveKernelIDSets
  ];
  parallelKernelIDsSeen = {};
  assert[
    Length[waveKernelIDSets] === Length[waves] &&
      AllTrue[
        waveKernelIDSets,
        Length[#] === requestedParallelKernels && DuplicateFreeQ[#] &
      ],
    label <> " alpha-two worker sets are incomplete."];
  assert[
    Lookup[chunkResults, "SourcePositionRange", {}] ===
      (MinMax /@ chunks) &&
      Total[Lookup[chunkResults, "ProcessedCount", 0]] ===
        Length[addends],
    label <> " alpha-two worker result coverage is incomplete."];
  chunkPowerSums = Lookup[chunkResults, "PowerSums", {}];
  laurentPowers = Sort@DeleteDuplicates@Flatten[Keys /@ chunkPowerSums];
  assert[
    laurentPowers =!= {} && MemberQ[laurentPowers, 0] &&
      AllTrue[laurentPowers, NumericQ[#] && TrueQ[# <= 0] &],
    label <> " alpha-two Laurent power inventory is invalid."];
  coefficientSums = AssociationMap[
    Function[power, Total[Lookup[chunkPowerSums, power, 0]]],
    laurentPowers
  ];
  negativePowers = Select[laurentPowers, TrueQ[# < 0] &];
  negativeReducedSums = Map[
    Function[power,
      With[{value = Lookup[coefficientSums, power, $Failed]},
        If[SameQ[value, 0], 0, Cancel[Together[value]]]
      ]
    ],
    negativePowers
  ];
  assert[AllTrue[negativeReducedSums, SameQ[#, 0] &],
    label <> " alpha-two negative Laurent coefficients do not cancel."];
  endpoint = Lookup[coefficientSums, 0, $Failed];
  assert[
    endpoint =!= $Failed && ! invalidEndpointQ[endpoint] &&
      FreeQ[endpoint, s23],
    label <> " alpha-two invalid-factor endpoint is not finite."];
  endpointSHA256Hex = IntegerString[Hash[endpoint, "SHA256"], 16, 64];
  Print[
    "S10_ALPHA2_INVALID_FACTOR_ENDPOINT: label=", label,
    " addends=", Length[addends],
    " powers=", InputForm[laurentPowers],
    " endpointSHA256=", endpointSHA256Hex
  ];
  <|
    "Endpoint" -> endpoint,
    "EndpointSHA256Hex" -> endpointSHA256Hex,
    "AddendCount" -> Length[addends],
    "LaurentPowers" -> laurentPowers,
    "ChunkRanges" -> (MinMax /@ chunks),
    "WorkerKernelIDSets" -> waveKernelIDSets,
    "StructuralMismatchPositions" -> Sort@Flatten[
      Lookup[chunkResults, "StructuralMismatchPositions", {}]
    ]
  |>
];

structuralAlpha2EndpointData[
    prefactor_, term_, index_Integer, label_String, projector_String
  ] := Module[
  {
    powers, nestedBase, nestedExponent, nestedPower, nestedRatio,
    ratioEndpoint, termFactors, nestedFactorPositions,
    structuralRemainder, regularFunction, regularFactors,
    factorEndpointValues, factorEndpointValidity,
    invalidFactorPositions, invalidFactorData,
    invalidFactorEndpointSHA256Hex, expectedEndpointSHA256Hex,
    endpointValue, position
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
  termFactors = If[Head[term] === Times, List @@ term, {term}];
  nestedFactorPositions = Flatten@Position[
    termFactors,
    nestedPower,
    {1},
    Heads -> False
  ];
  assert[Length[nestedFactorPositions] === 1,
    label <> " alpha-two nested power is not one top-level factor."];
  structuralRemainder = Times @@ Delete[
    termFactors,
    First[nestedFactorPositions]
  ];
  assert[SameQ[term, nestedPower structuralRemainder],
    label <> " alpha-two structural factor removal failed reconstruction."];
  regularFunction =
    prefactor nestedRatio^(-1 - epsilon) structuralRemainder;
  regularFactors = If[
    Head[regularFunction] === Times,
    List @@ regularFunction,
    {regularFunction}
  ];
  assert[SameQ[regularFunction, Times @@ regularFactors],
    label <> " alpha-two regular factors do not reconstruct their source."];
  factorEndpointValues = Map[
    Function[factor,
      Quiet@Check[
        TimeConstrained[factor /. s23 -> 0, 120, $Failed],
        $Failed
      ]
    ],
    regularFactors
  ];
  factorEndpointValidity = Map[
    Function[value,
      TrueQ[
        value =!= $Failed && ! invalidEndpointQ[value] &&
          FreeQ[value, s23]
      ]
    ],
    factorEndpointValues
  ];
  invalidFactorPositions = Flatten@Position[
    factorEndpointValidity,
    False
  ];
  assert[invalidFactorPositions =!= {},
    label <> " alpha-two regular factor inventory has no invalid factor."];
  invalidFactorData = Map[
    parallelAlpha2InvalidFactorEndpoint[
      regularFactors[[#]],
      label <> " term " <> ToString[index] <>
        " factor " <> ToString[#]
    ] &,
    invalidFactorPositions
  ];
  invalidFactorEndpointSHA256Hex = Lookup[
    invalidFactorData,
    "EndpointSHA256Hex",
    {}
  ];
  If[
    KeyExistsQ[
      acceptedAlpha2InvalidFactorEndpointSHA256HexByProjector,
      projector
    ],
    expectedEndpointSHA256Hex =
      acceptedAlpha2InvalidFactorEndpointSHA256HexByProjector[projector];
    assert[
      invalidFactorEndpointSHA256Hex === expectedEndpointSHA256Hex,
      label <> " alpha-two invalid-factor endpoint hashes disagree with " <>
        "the independently accepted diagnostic: observed=" <>
        ToString[InputForm[invalidFactorEndpointSHA256Hex]] <>
        " expected=" <> ToString[InputForm[expectedEndpointSHA256Hex]]
    ]
  ];
  Do[
    factorEndpointValues[[invalidFactorPositions[[position]]]] =
      invalidFactorData[[position, "Endpoint"]],
    {position, Length[invalidFactorPositions]}
  ];
  assert[
    AllTrue[
      factorEndpointValues,
      # =!= $Failed && ! invalidEndpointQ[#] && FreeQ[#, s23] &
    ],
    label <> " alpha-two factor endpoints are not all finite."];
  endpointValue = Times @@ factorEndpointValues;
  assert[
    endpointValue =!= $Failed &&
      ! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    label <> " alpha-two endpoint value is not finite."];
  Print["S10_CHECKPOINT: " <> label <> " term " <> ToString[index] <>
    " structurally refactored as alpha=2 with endpoint method version " <>
    ToString[alpha2EndpointConstructionVersion]];
  <|
    "SourceTermIndex" -> index,
    "NestedExponent" -> nestedExponent,
    "NestedRatioEndpoint" -> ratioEndpoint,
    "NestedRatioEndpointSHA256" -> Hash[ratioEndpoint, "SHA256"],
    "EndpointConstructionVersion" -> alpha2EndpointConstructionVersion,
    "InvalidRegularFactorPositions" -> invalidFactorPositions,
    "InvalidFactorEndpointSHA256Hex" ->
      invalidFactorEndpointSHA256Hex,
    "InvalidFactorEndpointMetadata" ->
      (KeyDrop[#, {"Endpoint", "WorkerKernelIDSets"}] & /@
        invalidFactorData),
    "RegularFunction" -> regularFunction,
    "EndpointValue" -> endpointValue,
    "EndpointValueSHA256Hex" -> IntegerString[
      Hash[endpointValue, "SHA256"],
      16,
      64
    ]
  |>
];

processProjection[projector_String] := Module[
  {
    label, expression, split, terms, prefactor, termCount,
    exceptionalIndices, logIndices, alpha2Data,
    standardIndices, standardTerms, standardTermCount,
    groups, coupledSourceIndices, uncoveredLogIndices,
    groupedPositions, ordinaryPositions, groupCertificates = {},
    group, groupIndices, groupPositions, groupAnswer,
    groupAnswerByPosition = <||>,
    cachePath, cachePayload,
    poles = {}, finite = {}, flags = {}, methods = {}, startIndex,
    remainingPositions, batchPositions, batchAnswers,
    ordinaryBatchOffsets, ordinaryBatchPositions, ordinaryBatchInputs,
    ordinaryBatchAnswers, batchOffset, position, termAnswer,
    batchTimedOut,
    failedOffset,
    failedBatchOffsets, fallbackSourceIndices,
    rawPoleResidual, reducedPoleResidual, poleOrders,
    prefactorEndpoint, endpointValue, regularFunction,
    alpha2RegularFunction, alpha2EndpointValue,
    testAtS, testAtZero, logarithmTower, alpha2LogarithmTower, action,
    endpointCacheSHA256, endpointCacheReloadGate
  },
  label = "Hqg;qg " <> projector;
  expression = loadExpansion[projector];
  split = splitEndpointProjection[expression, label];
  terms = split["Terms"];
  prefactor = split["Prefactor"];
  termCount = split["RemainderTermCount"];
  Print["S10_STAGE: structural endpoint scan for " <> projector <>
    ", terms=" <> ToString[termCount]];
  exceptionalIndices = exceptionalPowerTermIndices[terms];
  logIndices = singularLogTermIndices[terms];
  Print["S10_CHECKPOINT: " <> projector <>
    " direct-substitution singular-log source terms " <>
    ToString[InputForm[logIndices]]];
  Print["S10_CHECKPOINT: " <> projector <>
    " structural alpha=2 source terms " <>
    ToString[InputForm[exceptionalIndices]]];
  alpha2Data = Map[
    structuralAlpha2EndpointData[
      prefactor, terms[[#]], #, label, projector
    ] &,
    exceptionalIndices
  ];
  standardIndices = Complement[Range[termCount], exceptionalIndices];
  standardTerms = terms[[standardIndices]];
  standardTermCount = Length[standardTerms];
  assert[standardTermCount + Length[alpha2Data] === termCount,
    projector <> " structural endpoint partition is incomplete."];
  groups = discoverCoupledEndpointGroups[
    standardTerms, standardIndices, label
  ];
  coupledSourceIndices = DeleteDuplicates@Flatten[
    Lookup[groups, "SourceIndices"]
  ];
  assert[groups =!= {} &&
      ContainsAll[standardIndices, coupledSourceIndices],
    projector <> " coupled endpoint groups are not contained in the " <>
      "standard source-term partition."];
  uncoveredLogIndices = Complement[logIndices, coupledSourceIndices];
  assert[uncoveredLogIndices === {},
    projector <> " has structurally detected singular endpoint logarithms " <>
      "outside the tool-derived physical-root groups at terms " <>
      ToString[InputForm[uncoveredLogIndices]] <> "."];
  Print[
    "S10_COUPLED_ENDPOINT_COVERAGE: projector=", projector,
    " singularLogTerms=", InputForm[logIndices],
    " coupledSourceTerms=", InputForm[coupledSourceIndices],
    " uncovered={}"];
  groupedPositions = Sort@Flatten[
    FirstPosition[standardIndices, #] & /@ coupledSourceIndices
  ];
  ordinaryPositions = Complement[
    Range[standardTermCount],
    groupedPositions
  ];
  assert[
    Length[groupedPositions] === Length[coupledSourceIndices] &&
      And @@ (IntegerQ /@ groupedPositions) &&
      DuplicateFreeQ[groupedPositions] &&
      Sort@Join[groupedPositions, ordinaryPositions] ===
        Range[standardTermCount],
    projector <> " grouped and ordinary standard positions do not form " <>
      "an exact partition."
  ];

  cachePath = endpointCachePaths[projector];
  migrateAcceptedEndpointCacheMetadata[
    projector, cachePath, standardTermCount, groups, groupedPositions
  ];
  If[FileExistsQ[cachePath],
    cachePayload = Check[Get[cachePath], $Failed];
    If[
      AssociationQ[cachePayload] &&
      cachePayload["CacheVersion"] === endpointCacheVersion &&
      cachePayload["StageVersion"] === stageVersion &&
      cachePayload["SourceS09SHA256"] === s09SHA256 &&
      cachePayload["SourceS08SHA256"] === s08SHA256 &&
      cachePayload["SourceS07SHA256"] === s07SHA256 &&
      cachePayload["ProgramSHA256"] === programSHA256 &&
      cachePayload["PaperSHA256"] === referencePDFSHA256 &&
      cachePayload["ElectricChargeNormalization"] ===
        electricChargeNormalization &&
      cachePayload["AppliedHardKernelWeight"] === hardKernelWeight &&
      cachePayload["Projector"] === projector &&
      cachePayload["SourceExpansionSHA256"] ===
        expansionCacheSHA256[projector] &&
      cachePayload["RemainderTermCount"] === termCount &&
      Lookup[cachePayload, "StandardTermIndices", $Failed] ===
        standardIndices &&
      Lookup[cachePayload, "Alpha2TermIndices", $Failed] ===
        exceptionalIndices &&
      Lookup[cachePayload, "Alpha2NestedRatioEndpoints", $Failed] ===
        Lookup[alpha2Data, "NestedRatioEndpoint", {}] &&
      Lookup[
        cachePayload,
        "Alpha2NestedRatioEndpointSHA256",
        $Failed
      ] === Lookup[alpha2Data, "NestedRatioEndpointSHA256", {}] &&
      Lookup[cachePayload, "Alpha2EndpointConstructionVersion", 0] ===
        alpha2EndpointConstructionVersion &&
      Lookup[
        cachePayload,
        "Alpha2InvalidFactorEndpointSHA256Hex",
        $Failed
      ] === Lookup[
        alpha2Data,
        "InvalidFactorEndpointSHA256Hex",
        {}
      ] &&
      Lookup[
        cachePayload,
        "Alpha2EndpointValueSHA256Hex",
        $Failed
      ] === Lookup[alpha2Data, "EndpointValueSHA256Hex", {}] &&
      Lookup[
        cachePayload,
        "Alpha2InvalidFactorEndpointMetadata",
        $Failed
      ] === Lookup[alpha2Data, "InvalidFactorEndpointMetadata", {}] &&
      Lookup[
        cachePayload,
        "DirectSubstitutionSingularLogTermIndices",
        $Failed
      ] === logIndices &&
      Lookup[
        cachePayload,
        "UncoveredSingularLogTermIndices",
        $Failed
      ] === uncoveredLogIndices &&
      Lookup[cachePayload, "CoupledLogEndpointRepairVersion", 0] ===
        coupledEndpointRepairVersion &&
      Lookup[cachePayload, "CoupledLogEndpointGroups", {}] === groups &&
      Lookup[cachePayload, "CoupledGroupSeriesEvaluatorVersion", 0] ===
        coupledGroupSeriesEvaluatorVersion &&
      TrueQ[Lookup[
        cachePayload,
        "GroupedBeforeIndividualLaurent",
        False
      ]] &&
      AssociationQ[Lookup[
        cachePayload,
        "PreIndividualGroupAnswers",
        Missing[]
      ]] &&
      Sort[Keys[cachePayload["PreIndividualGroupAnswers"]]] ===
        groupedPositions &&
      ListQ[Lookup[cachePayload, "CoupledGroupCertificates", Missing[]]] &&
      Length[cachePayload["CoupledGroupCertificates"]] === Length[groups] &&
      Lookup[cachePayload, "ParallelBatchTimeLimitSeconds", 0] ===
        endpointParallelBatchTimeLimitSeconds &&
      IntegerQ[
        Lookup[cachePayload, "ParallelBatchTimeoutCount", -1]
      ] &&
      Lookup[cachePayload, "ParallelBatchTimeoutCount", -1] >= 0 &&
      With[{
        fallbackIndices = Lookup[
          cachePayload,
          "SerialFallbackSourceIndices",
          $Failed
        ]
      },
        ListQ[fallbackIndices] && DuplicateFreeQ[fallbackIndices] &&
          ContainsAll[standardIndices, fallbackIndices]
      ] &&
      TrueQ[Lookup[
        cachePayload,
        "CoupledLogEndpointRepairApplied",
        False
      ]],
      poles = Lookup[cachePayload, "PoleCoefficients", {}];
      finite = Lookup[cachePayload, "FiniteCoefficients", {}];
      flags = Lookup[cachePayload, "RequiredPoleSubtraction", {}];
      methods = Lookup[cachePayload, "Methods", {}];
      groupAnswerByPosition = cachePayload["PreIndividualGroupAnswers"];
      groupCertificates = cachePayload["CoupledGroupCertificates"];
      endpointParallelBatchTimeoutCountByProjector[projector] = Lookup[
        cachePayload,
        "ParallelBatchTimeoutCount"
      ];
      endpointSerialFallbackSourceIndices[projector] = Lookup[
        cachePayload,
        "SerialFallbackSourceIndices"
      ];
      assert[
        ListQ[poles] && ListQ[finite] && ListQ[flags] && ListQ[methods] &&
        Length[poles] === Length[finite] === Length[flags] ===
          Length[methods] && Length[poles] <= standardTermCount,
        projector <> " endpoint cache has inconsistent completed lists."
      ];
      assert[AllTrue[
          Select[groupedPositions, # <= Length[poles] &],
          Function[currentPosition,
            Module[{savedAnswer},
              savedAnswer = groupAnswerByPosition[currentPosition];
              SameQ[poles[[currentPosition]],
                  savedAnswer["PoleCoefficient"]] &&
                SameQ[finite[[currentPosition]],
                  savedAnswer["FiniteCoefficient"]] &&
                SameQ[flags[[currentPosition]],
                  savedAnswer["RequiredPoleSubtraction"]] &&
                SameQ[methods[[currentPosition]], savedAnswer["Method"]]
            ]
          ]
        ],
        projector <> " cached grouped positions disagree with their " <>
          "pre-individual certificate."];
      Print["S10_STAGE: resuming " <> projector <> " endpoint cache at " <>
        ToString[Length[poles]] <> "/" <> ToString[standardTermCount]],
      Print["S10_STAGE: removing stale endpoint cache for " <> projector];
      DeleteFile[cachePath]
    ]
  ];
  If[groupAnswerByPosition === <||>,
    Print[
      "S10_GROUP_STAGE: projector=", projector,
      " groups=", InputForm[Lookup[groups, "SourceIndices"]]
    ];
    Do[
      groupIndices = group["SourceIndices"];
      groupPositions = Flatten[
        FirstPosition[standardIndices, #] & /@ groupIndices
      ];
      assert[
        Length[groupPositions] === Length[groupIndices] &&
          And @@ (IntegerQ /@ groupPositions),
        label <> " coupled group source positions are missing."
      ];
      groupAnswer = coupledEndpointGroupLaurent[
        standardTerms[[groupPositions]],
        groupIndices,
        group["PhysicalRootRadicand"],
        group["RootByDeltaSign"],
        label
      ];
      AssociateTo[
        groupAnswerByPosition,
        First[groupPositions] -> <|
          "PoleCoefficient" -> groupAnswer["PoleCoefficient"],
          "FiniteCoefficient" -> groupAnswer["FiniteCoefficient"],
          "RequiredPoleSubtraction" ->
            groupAnswer["RequiredPoleSubtraction"],
          "Method" -> groupAnswer["FirstMethod"]
        |>
      ];
      Scan[
        Function[currentPosition,
          AssociateTo[
            groupAnswerByPosition,
            currentPosition -> <|
              "PoleCoefficient" -> 0,
              "FiniteCoefficient" -> 0,
              "RequiredPoleSubtraction" -> False,
              "Method" -> groupAnswer["AbsorbedMethod"]
            |>
          ]
        ],
        Rest[groupPositions]
      ];
      AppendTo[groupCertificates, groupAnswer["Certificate"]];
      Print[
        "S10_GROUP_COMPLETE: projector=", projector,
        " sourceTerms=", InputForm[groupIndices],
        " functionOrder=",
        groupAnswer["Certificate", "RequiredFunctionSeriesOrder"],
        " rootOrder=",
        groupAnswer["Certificate", "RequiredRootSeriesOrder"]
      ];,
      {group, groups}
    ];
    assert[
      Sort[Keys[groupAnswerByPosition]] === groupedPositions &&
        Length[groupCertificates] === Length[groups],
      projector <> " pre-individual group evaluation has incomplete " <>
        "position coverage."
    ]
  ];
  startIndex = Length[poles] + 1;
  remainingPositions = Range[startIndex, standardTermCount];
  While[Length[remainingPositions] > 0,
    batchPositions = Take[
      remainingPositions,
      UpTo[requestedParallelKernels]
    ];
    Print[
      "S10_ENDPOINT_BATCH: " <> projector <> " positions=" <>
        ToString[First[batchPositions]] <> "-" <>
        ToString[Last[batchPositions]] <> "/" <>
        ToString[standardTermCount]
    ];
    batchAnswers = ConstantArray[$Failed, Length[batchPositions]];
    Do[
      If[KeyExistsQ[groupAnswerByPosition, batchPositions[[batchOffset]]],
        batchAnswers[[batchOffset]] =
          groupAnswerByPosition[batchPositions[[batchOffset]]]
      ],
      {batchOffset, Length[batchPositions]}
    ];
    ordinaryBatchOffsets = Flatten@Position[
      KeyExistsQ[groupAnswerByPosition, #] & /@ batchPositions,
      False
    ];
    ordinaryBatchPositions = batchPositions[[ordinaryBatchOffsets]];
    ordinaryBatchInputs = Map[
      Function[currentPosition,
        {
          standardTerms[[currentPosition]],
          label,
          standardIndices[[currentPosition]],
          termCount
        }
      ],
      ordinaryBatchPositions
    ];
    If[ordinaryBatchInputs =!= {},
      endpointParallelWorkRequired = True;
      If[$KernelCount =!= requestedParallelKernels,
        ensureEndpointParallelKernels[
          projector <> " ordinary endpoint worker recovery"
        ]
      ];
      batchTimedOut = False;
      ordinaryBatchAnswers = Quiet@Check[
        TimeConstrained[
          ParallelMap[
            endpointWorkerEvaluate,
            ordinaryBatchInputs,
            Method -> "FinestGrained"
          ],
          endpointParallelBatchTimeLimitSeconds,
          (batchTimedOut = True; $Failed)
        ],
        $Failed
      ];
      If[
        ordinaryBatchAnswers === $Failed ||
          ! ListQ[ordinaryBatchAnswers] ||
          Length[ordinaryBatchAnswers] =!= Length[ordinaryBatchInputs],
        If[TrueQ[batchTimedOut],
          endpointParallelBatchTimeoutCountByProjector[projector]++
        ];
        closeEndpointParallelKernels[
          projector <> " ordinary endpoint full-batch serial fallback"
        ];
        fallbackSourceIndices = standardIndices[[ordinaryBatchPositions]];
        endpointSerialFallbackSourceIndices[projector] =
          DeleteDuplicates@Join[
            endpointSerialFallbackSourceIndices[projector],
            fallbackSourceIndices
          ];
        Print[
          "S10_ENDPOINT_FALLBACK: parallel ordinary batch unavailable; " <>
            "evaluating " <> projector <> " positions " <>
            ToString[InputForm[ordinaryBatchPositions]] <> " serially" <>
            " timedOut=" <> ToString[TrueQ[batchTimedOut]] <>
            " deadlineSeconds=" <>
            ToString[endpointParallelBatchTimeLimitSeconds]
        ];
        ordinaryBatchAnswers = endpointTermLaurent[
            #[[1]], #[[2]], #[[3]], #[[4]]
          ] & /@ ordinaryBatchInputs,
        failedBatchOffsets = Flatten@Position[
          AssociationQ /@ ordinaryBatchAnswers,
          False
        ];
        If[failedBatchOffsets =!= {},
          closeEndpointParallelKernels[
            projector <> " ordinary endpoint partial serial fallback"
          ];
          fallbackSourceIndices = standardIndices[[
            ordinaryBatchPositions[[failedBatchOffsets]]
          ]];
          endpointSerialFallbackSourceIndices[projector] =
            DeleteDuplicates@Join[
              endpointSerialFallbackSourceIndices[projector],
              fallbackSourceIndices
            ];
          Do[
            Print[
              "S10_ENDPOINT_FALLBACK: worker memory bound reached for " <>
                projector <> " ordinary position " <>
                ToString[ordinaryBatchPositions[[failedOffset]]] <>
                "; evaluating that term serially"
            ];
            ordinaryBatchAnswers[[failedOffset]] = endpointTermLaurent[
              ordinaryBatchInputs[[failedOffset, 1]],
              ordinaryBatchInputs[[failedOffset, 2]],
              ordinaryBatchInputs[[failedOffset, 3]],
              ordinaryBatchInputs[[failedOffset, 4]]
            ],
            {failedOffset, failedBatchOffsets}
          ]
        ]
      ];
      assert[AllTrue[ordinaryBatchAnswers, AssociationQ],
        projector <> " ordinary endpoint batch returned an invalid result."];
      Do[
        batchAnswers[[ordinaryBatchOffsets[[batchOffset]]]] =
          ordinaryBatchAnswers[[batchOffset]],
        {batchOffset, Length[ordinaryBatchAnswers]}
      ],
      ordinaryBatchAnswers = {}
    ];
    assert[AllTrue[batchAnswers, AssociationQ],
      projector <> " endpoint batch returned an invalid result."];
    Do[
      termAnswer = batchAnswers[[batchOffset]];
      AppendTo[poles, termAnswer["PoleCoefficient"]];
      AppendTo[finite, termAnswer["FiniteCoefficient"]];
      AppendTo[flags, termAnswer["RequiredPoleSubtraction"]];
      AppendTo[methods, termAnswer["Method"]],
      {batchOffset, Length[batchAnswers]}
    ];
    position = Last[batchPositions];
    cachePayload = <|
      "CacheVersion" -> endpointCacheVersion,
      "StageVersion" -> stageVersion,
      "Channel" -> "Hqg only",
      "TensorRole" -> "RealQGEndpoint",
      "SourceS09" -> s09Path,
      "SourceS09SHA256" -> s09SHA256,
      "SourceS08" -> s08Path,
      "SourceS08SHA256" -> s08SHA256,
      "SourceS07" -> s07Path,
      "SourceS07SHA256" -> s07SHA256,
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "Paper" -> paperPath,
      "PaperSHA256" -> referencePDFSHA256,
      "ElectricChargeNormalization" -> electricChargeNormalization,
      "AppliedHardKernelWeight" -> hardKernelWeight,
      "Projector" -> projector,
      "SourceExpansionCache" -> expansionCachePaths[projector],
      "SourceExpansionSHA256" -> expansionCacheSHA256[projector],
      "RemainderTermCount" -> termCount,
      "StandardTermIndices" -> standardIndices,
      "Alpha2TermIndices" -> exceptionalIndices,
      "Alpha2NestedRatioEndpoints" ->
        Lookup[alpha2Data, "NestedRatioEndpoint", {}],
      "Alpha2NestedRatioEndpointSHA256" ->
        Lookup[alpha2Data, "NestedRatioEndpointSHA256", {}],
      "Alpha2EndpointConstructionVersion" ->
        alpha2EndpointConstructionVersion,
      "Alpha2InvalidFactorEndpointSHA256Hex" ->
        Lookup[alpha2Data, "InvalidFactorEndpointSHA256Hex", {}],
      "Alpha2EndpointValueSHA256Hex" ->
        Lookup[alpha2Data, "EndpointValueSHA256Hex", {}],
      "Alpha2InvalidFactorEndpointMetadata" ->
        Lookup[alpha2Data, "InvalidFactorEndpointMetadata", {}],
      "DirectSubstitutionSingularLogTermIndices" -> logIndices,
      "UncoveredSingularLogTermIndices" -> uncoveredLogIndices,
      "ParallelBatchTimeLimitSeconds" ->
        endpointParallelBatchTimeLimitSeconds,
      "ParallelBatchTimeoutCount" ->
        endpointParallelBatchTimeoutCountByProjector[projector],
      "SerialFallbackSourceIndices" ->
        endpointSerialFallbackSourceIndices[projector],
      "CoupledLogEndpointRepairVersion" ->
        coupledEndpointRepairVersion,
      "CoupledLogEndpointGroups" -> groups,
      "CoupledGroupSeriesEvaluatorVersion" ->
        coupledGroupSeriesEvaluatorVersion,
      "GroupedBeforeIndividualLaurent" -> True,
      "PreIndividualGroupAnswers" -> groupAnswerByPosition,
      "CoupledGroupCertificates" -> groupCertificates,
      "CoupledLogEndpointRepairApplied" -> True,
      "PoleCoefficients" -> poles,
      "FiniteCoefficients" -> finite,
      "RequiredPoleSubtraction" -> flags,
      "Methods" -> methods,
      "CompletedStandardTermCount" -> position
    |>;
    writeAtomic[cachePayload, cachePath];
    assert[atomicReloadSameQ[cachePayload, cachePath],
      projector <> " endpoint batch cache failed reload equality."];
    Print[
      "S10_CACHE_CHECKPOINT: " <> projector <> " " <>
        ToString[position] <> "/" <> ToString[standardTermCount] <>
        " standard terms"
    ];
    remainingPositions = Drop[
      remainingPositions,
      Length[batchPositions]
    ];
    Clear[
      ordinaryBatchInputs, ordinaryBatchAnswers,
      batchAnswers, termAnswer
    ];
    If[$KernelCount > 0,
      Quiet[ParallelEvaluate[ClearSystemCache[]]]
    ];
    ClearSystemCache[];
  ];
  assert[Length[poles] === standardTermCount &&
      Length[finite] === standardTermCount,
    projector <> " endpoint cache does not cover every standard term."];

  assert[
    TrueQ[cachePayload["GroupedBeforeIndividualLaurent"]] &&
      TrueQ[cachePayload["CoupledLogEndpointRepairApplied"]] &&
      Count[methods, "physical-branch grouped Laurent"] ===
        Length[groups] &&
      Count[
        methods,
        "absorbed into pre-individual physical-branch group"
      ] ===
        Total[Length /@ Lookup[groups, "SourceIndices"]] -
          Length[groups],
    projector <> " pre-individual grouped Laurent metadata is incomplete."
  ];

  Print["S10_STAGE: reducing stronger endpoint pole for " <> projector];
  rawPoleResidual = Total[poles];
  reducedPoleResidual = Quiet@Check[
    TimeConstrained[Cancel[Together[rawPoleResidual]], 900, $Failed],
    $Failed
  ];
  assert[reducedPoleResidual =!= $Failed,
    projector <> " stronger endpoint-pole reduction failed or timed out."];
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
        Cancel[Together[D[reducedPoleResidual, epsilon] /.
          epsilon -> 0]],
        900,
        $Failed
      ],
      $Failed
    ]
  |>;
  assert[FreeQ[Values[poleOrders], $Failed],
    projector <> " stronger-pole epsilon-order gate timed out."];
  assert[AllTrue[Values[poleOrders], TrueQ[# === 0] &],
    projector <> " has a nonzero stronger endpoint pole through the " <>
      "finite-order requirement."];
  Print["S10_CHECKPOINT: " <> projector <>
    " stronger endpoint pole vanishes through epsilon^1"];

  prefactorEndpoint = Quiet@Check[prefactor /. s23 -> 0, $Failed];
  assert[! invalidEndpointQ[prefactorEndpoint] &&
      FreeQ[prefactorEndpoint, s23],
    projector <> " common prefactor has no finite endpoint."];
  endpointValue = flavorChargeWeight * prefactorEndpoint * Total[finite];
  assert[! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    projector <> " endpoint value remains invalid or s23-dependent."];
  regularFunction = flavorChargeWeight * (
    s23 prefactor Total[standardTerms] -
      prefactor reducedPoleResidual/s23
  );
  alpha2RegularFunction = flavorChargeWeight *
    Total[Lookup[alpha2Data, "RegularFunction", {}]];
  alpha2EndpointValue = flavorChargeWeight *
    Total[Lookup[alpha2Data, "EndpointValue", {}]];
  assert[
    ! invalidEndpointQ[alpha2EndpointValue] &&
    FreeQ[alpha2EndpointValue, s23],
    projector <> " alpha-two endpoint value is invalid or s23-dependent."];
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
  assert[FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
    ],
    projector <> " action retains an endpoint distribution object."];
  assert[! FreeQ[action, Inactive[Integrate][___]],
    projector <> " action lacks its endpoint-subtracted integral."];
  assert[! FreeQ[action, _S10ConvolutionTest],
    projector <> " action lacks the symbolic test function."];
  cachePayload = Join[
    cachePayload,
    <|
      "Finalized" -> True,
      "ReducedStrongerPoleResidual" -> reducedPoleResidual,
      "StrongerPoleOrders" -> poleOrders,
      "EndpointValue" -> endpointValue,
      "Alpha2EndpointValue" -> alpha2EndpointValue,
      "Action" -> action
    |>
  ];
  writeAtomic[cachePayload, cachePath];
  endpointCacheReloadGate = atomicReloadSameQ[cachePayload, cachePath];
  assert[endpointCacheReloadGate,
    projector <> " finalized endpoint cache failed reload equality."];
  endpointCacheSHA256 = fileSHA256Hex[cachePath];
  Print["S10_CHECKPOINT: completed symbolic distribution action for " <>
    projector];
  <|
    "Projector" -> projector,
    "RemainderTermCount" -> termCount,
    "StandardTermIndices" -> standardIndices,
    "Alpha2TermIndices" -> exceptionalIndices,
    "Alpha2NestedRatioEndpoints" ->
      Lookup[alpha2Data, "NestedRatioEndpoint", {}],
    "Alpha2NestedRatioEndpointSHA256" ->
      Lookup[alpha2Data, "NestedRatioEndpointSHA256", {}],
    "Alpha2EndpointConstructionVersion" ->
      alpha2EndpointConstructionVersion,
    "Alpha2InvalidFactorEndpointSHA256Hex" ->
      Lookup[alpha2Data, "InvalidFactorEndpointSHA256Hex", {}],
    "Alpha2EndpointValueSHA256Hex" ->
      Lookup[alpha2Data, "EndpointValueSHA256Hex", {}],
    "Alpha2InvalidFactorEndpointMetadata" ->
      Lookup[alpha2Data, "InvalidFactorEndpointMetadata", {}],
    "DirectSubstitutionSingularLogTermIndices" -> logIndices,
    "UncoveredSingularLogTermIndices" -> uncoveredLogIndices,
    "ParallelBatchTimeLimitSeconds" ->
      endpointParallelBatchTimeLimitSeconds,
    "ParallelBatchTimeoutCount" ->
      endpointParallelBatchTimeoutCountByProjector[projector],
    "SerialFallbackSourceIndices" ->
      endpointSerialFallbackSourceIndices[projector],
    "CoupledLogEndpointRepairVersion" -> coupledEndpointRepairVersion,
    "CoupledLogEndpointGroups" -> groups,
    "CoupledGroupSeriesEvaluatorVersion" ->
      coupledGroupSeriesEvaluatorVersion,
    "GroupedBeforeIndividualLaurent" -> True,
    "CoupledGroupCertificates" -> groupCertificates,
    "CoupledLogEndpointRepairApplied" -> True,
    "PoleSubtractionTermCount" -> Count[flags, True],
    "EndpointCache" -> cachePath,
    "EndpointCacheSHA256" -> endpointCacheSHA256,
    "EndpointCacheReloadValidated" -> endpointCacheReloadGate,
    "ReducedStrongerPoleResidual" -> reducedPoleResidual,
    "StrongerPoleOrders" -> poleOrders,
    "EndpointValue" -> endpointValue,
    "Alpha2EndpointValue" -> alpha2EndpointValue,
    "Action" -> action,
    "MethodCounts" -> Counts[methods]
  |>
];

virtualLaurentCacheSHA256 = fileSHA256Hex[laurentCachePath];
paVeCacheSHA256 = fileSHA256Hex[paVeCachePath];
scalarMasterCacheSHA256 = fileSHA256Hex[scalarMasterCachePath];
Print["S10_MEMORY_STAGE: releasing completed virtual data before real endpoints"];
Clear[
  renormalizedVirtualSplit, virtualLaurent, loStoredCoefficients,
  explicitCountertermMultiplier
];
ClearSystemCache[];

Print["S10_STAGE: resolving Pg endpoint Laurent data and action"];
pgData = processProjection["Pg"];
ClearSystemCache[];
Print["S10_MEMORY_STAGE: Pg complete; processing PPP in bounded batches"];
pppData = processProjection["PPP"];
closeEndpointParallelKernels["Pg and PPP endpoint batches"];

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

Print["S10_STAGE: reloading validated virtual Laurent cache"];
virtualLaurent = finiteLaurentPair[<||>, laurentCachePath];
virtualConvolutionActions = AssociationMap[
  virtualLaurent[#] S10ConvolutionTest[#, 0] &,
  projectors
];
combinedConvolutionActions = AssociationMap[
  realConvolutionActions[#] + virtualConvolutionActions[#] &,
  projectors
];
virtualActionResolutionGate =
  AllTrue[
    Values[virtualConvolutionActions],
    FreeQ[
      #,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator | dZGG1 | dZgs1 | _dZq1
    ] &
  ];
assert[virtualActionResolutionGate,
  "A virtual action retains an unresolved loop, regulator, or counterterm."
];
realActionStructureGate = AllTrue[
  Values[realConvolutionActions],
  Function[action,
    FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
    ] &&
      ! FreeQ[action, _S10ConvolutionTest] &&
      ! FreeQ[action, Inactive[Integrate][___]]
  ]
];
assert[realActionStructureGate,
  "A real endpoint action has invalid symbolic-test-function structure."];
combinedActionResolutionGate =
  AllTrue[
    Values[combinedConvolutionActions],
    FreeQ[
      #,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23] |
        FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator | dZGG1 | dZgs1 | _dZq1
    ] &
  ];
assert[combinedActionResolutionGate,
  "A combined action retains an endpoint distribution placeholder."
];

endpointFinalCacheReloadGate = AllTrue[
  Values[
    endpointDataByProjector[[All, "EndpointCacheReloadValidated"]]
  ],
  TrueQ
];
endpointFinalCacheDiskHashGate = AllTrue[
  projectors,
  Function[projector,
    fileSHA256Hex[endpointDataByProjector[projector, "EndpointCache"]] ===
      endpointDataByProjector[projector, "EndpointCacheSHA256"]
  ]
];
alpha2RatioGate = AllTrue[
  projectors,
  Function[projector,
    Module[{ratios, hashes},
      ratios = endpointDataByProjector[
        projector, "Alpha2NestedRatioEndpoints"
      ];
      hashes = endpointDataByProjector[
        projector, "Alpha2NestedRatioEndpointSHA256"
      ];
      Length[ratios] > 0 && Length[ratios] === Length[hashes] &&
        AllTrue[
          ratios,
          ! invalidEndpointQ[#] && FreeQ[#, s23] && ! TrueQ[# === 0] &
        ] &&
        SameQ[Hash[#, "SHA256"] & /@ ratios, hashes]
    ]
  ]
];
alpha2EndpointConstructionGate =
  alpha2ParallelKernelIDSetsSeen =!= {} &&
  AllTrue[
    alpha2ParallelKernelIDSetsSeen,
    Length[#] === requestedParallelKernels && DuplicateFreeQ[#] &
  ] &&
  AllTrue[
    projectors,
    Function[projector,
      Module[
        {
          termIndices, invalidFactorHashes, endpointHashes,
          expectedHashes
        },
        termIndices = endpointDataByProjector[
          projector,
          "Alpha2TermIndices"
        ];
        invalidFactorHashes = endpointDataByProjector[
          projector,
          "Alpha2InvalidFactorEndpointSHA256Hex"
        ];
        endpointHashes = endpointDataByProjector[
          projector,
          "Alpha2EndpointValueSHA256Hex"
        ];
        expectedHashes = Lookup[
          acceptedAlpha2InvalidFactorEndpointSHA256HexByProjector,
          projector,
          Missing["NoIndependentHashContract"]
        ];
        endpointDataByProjector[
          projector,
          "Alpha2EndpointConstructionVersion"
        ] === alpha2EndpointConstructionVersion &&
          Length[termIndices] > 0 &&
          Length[invalidFactorHashes] === Length[termIndices] &&
          Length[endpointHashes] === Length[termIndices] &&
          AllTrue[invalidFactorHashes, ListQ[#] && # =!= {} &] &&
          AllTrue[
            Flatten[invalidFactorHashes],
            StringQ[#] && StringLength[#] === 64 &
          ] &&
          AllTrue[
            endpointHashes,
            StringQ[#] && StringLength[#] === 64 &
          ] &&
          If[
            MissingQ[expectedHashes],
            True,
            Flatten[invalidFactorHashes] === expectedHashes
          ]
      ]
    ]
  ];
derivedCoupledGroupGate = AllTrue[
  projectors,
  Function[projector,
    Module[{groups, certificates},
      groups = endpointDataByProjector[
        projector, "CoupledLogEndpointGroups"
      ];
      certificates = endpointDataByProjector[
        projector, "CoupledGroupCertificates"
      ];
      ListQ[groups] && groups =!= {} &&
        AllTrue[
          groups,
          AssociationQ[#] &&
            Length[Lookup[#, "SourceIndices", {}]] > 1 &&
            AssociationQ[Lookup[#, "RootByDeltaSign", <||>]] &
        ] &&
        DuplicateFreeQ[Flatten[Lookup[groups, "SourceIndices"]]] &&
        endpointDataByProjector[
          projector,
          "CoupledGroupSeriesEvaluatorVersion"
        ] === coupledGroupSeriesEvaluatorVersion &&
        TrueQ[endpointDataByProjector[
          projector,
          "GroupedBeforeIndividualLaurent"
        ]] &&
        ListQ[certificates] && Length[certificates] === Length[groups] &&
        AllTrue[
          certificates,
          AssociationQ[#] &&
            Lookup[#, "EvaluatorVersion", 0] ===
              coupledGroupSeriesEvaluatorVersion &&
            TrueQ[Lookup[#, "RootResidualsZero", False]] &&
            TrueQ[Lookup[#, "AllFunctionSeriesResolved", False]] &&
            TrueQ[Lookup[#, "LiteralReconstruction", False]] &&
            TrueQ[Lookup[#, "ExactSourceUnchanged", False]] &&
            Sort[Keys[Lookup[#, "BranchCertificates", <||>]]] ===
              {-1, 1} &
        ] &&
        TrueQ[endpointDataByProjector[
          projector, "CoupledLogEndpointRepairApplied"
        ]]
    ]
  ]
];
progressCacheCleanupGate = FileNames[
  FileNameJoin[{scriptDirectory, "s10_cache_v2_virtual_laurent_progress_*"}]
] === {};
temporaryArtifactGate = FileNames[
  FileNameJoin[{scriptDirectory, "s10_*.tmp.*"}]
] === {};
fullySymbolicActionGate = FreeQ[
  Join[
    Values[realConvolutionActions],
    Values[virtualConvolutionActions],
    Values[combinedConvolutionActions]
  ],
  _Real | $Failed | Indeterminate | ComplexInfinity | DirectedInfinity
];
endpointBatchRecoveryGate = TrueQ[
  IntegerQ[endpointParallelBatchTimeLimitSeconds] &&
    endpointParallelBatchTimeLimitSeconds > 0 &&
    AssociationQ[endpointParallelBatchTimeoutCountByProjector] &&
    AssociationQ[endpointSerialFallbackSourceIndices] &&
    Sort[Keys[endpointParallelBatchTimeoutCountByProjector]] ===
      Sort[projectors] &&
    Sort[Keys[endpointSerialFallbackSourceIndices]] === Sort[projectors] &&
    parallelKernelLaunchIDSetsSeen =!= {} &&
    AllTrue[
      parallelKernelLaunchIDSetsSeen,
      Length[#] === requestedParallelKernels && DuplicateFreeQ[#] &
    ] &&
    AllTrue[
      projectors,
      Function[projector,
        IntegerQ[endpointParallelBatchTimeoutCountByProjector[projector]] &&
          endpointParallelBatchTimeoutCountByProjector[projector] >= 0 &&
          ListQ[endpointSerialFallbackSourceIndices[projector]] &&
          DuplicateFreeQ[endpointSerialFallbackSourceIndices[projector]] &&
          AllTrue[
            endpointSerialFallbackSourceIndices[projector],
            IntegerQ
          ] &&
          ContainsAll[
            endpointDataByProjector[projector, "StandardTermIndices"],
            endpointSerialFallbackSourceIndices[projector]
          ]
      ]
    ]
];

immutableInputIdentitiesQ[] := TrueQ[
  fileSHA256Hex[programPath] === programSHA256 &&
    fileSHA256Hex[paperPath] === referencePDFSHA256 &&
    fileSHA256Hex[s09Path] === s09SHA256 &&
    fileSHA256Hex[s09ProgramPath] === s09ProgramSHA256 &&
    fileSHA256Hex[s08Path] === s08SHA256 &&
    fileSHA256Hex[s08ProgramPath] === s08ProgramSHA256 &&
    fileSHA256Hex[s07Path] === s07SHA256 &&
    fileSHA256Hex[s07ProgramPath] === s07ProgramSHA256 &&
    AssociationMap[
      fileSHA256Hex[expansionCachePaths[#]] &,
      projectors
    ] === recordedExpansionCacheSHA256
];
immutableInputIdentityGate = immutableInputIdentitiesQ[];
assert[immutableInputIdentityGate,
  "An accepted source, result, paper, or S09 cache identity changed before " <>
    "final S10 assembly."];
virtualCacheMigrationGate = AllTrue[
  Values[virtualCacheMigrationRecords],
  AssociationQ[#] && TrueQ[Lookup[#, "Migrated", False]] &&
    Lookup[#, "OriginalAcceptedProgramSHA256", Missing[]] ===
      acceptedLegacyVirtualProgramSHA256 &&
    MemberQ[
      Values[acceptedLegacyVirtualCacheSHA256ByName],
      Lookup[#, "OriginalAcceptedCacheSHA256", Missing[]]
    ] &&
    TrueQ[Lookup[#, "MathematicalPayloadUnchanged", False]] &&
    (
      Lookup[#, "CacheType", Missing[]] =!= "virtual Laurent" ||
        TrueQ[Lookup[#, "DependencyMetadataRefreshed", False]]
    ) &
];
endpointCacheMetadataMigrationGate = AllTrue[
  Values[endpointCacheMetadataMigrationRecords],
  AssociationQ[#] && TrueQ[Lookup[#, "Migrated", False]] &&
    Lookup[#, "OriginalAcceptedProgramSHA256", Missing[]] ===
      acceptedEndpointMetadataCorrectionProgramSHA256 &&
    Lookup[
      acceptedEndpointMetadataCorrectionCacheSHA256ByProjector,
      Lookup[#, "Projector", Missing[]],
      Missing[]
    ] === Lookup[#, "OriginalAcceptedCacheSHA256", Missing[]] &&
    TrueQ[Lookup[#, "MathematicalPayloadUnchanged", False]] &
];

s10Checks = <|
  "AcceptedS09S08S07IdentitiesAndChecksValidated" ->
    (s09IdentityGate && s09ChecksGate && s09ProgramGate &&
      s08IdentityGate && s08ChecksGate && s08ProgramGate &&
      s07IdentityGate && s07ChecksGate && s07ProgramGate),
  "PaperReferenceHashValidated" -> paperBindingGate,
  "InheritedChargeStateAndDimensionalBookkeepingValidated" ->
    chargeBookkeepingGate,
  "AcceptedTwoBodyKinematicsInstalledExactly" ->
    (twoBodyKinematicRecordGate &&
      TrueQ[twoBodyInstallationAudit["InstalledExactly"]]),
  "LOAndVirtualReferenceContentHashesValidated" ->
    loVirtualReferenceHashGate,
  "RuntimeVirtualIntegralInventoriesDerivedAndContentBound" ->
    virtualIntegralInventoryGate,
  "AllRuntimeLoopIntegralsEvaluated" -> loopIntegralResolutionGate,
  "PackageXRuleCachesExactlyReloaded" ->
    (Sort[Keys[ruleCacheValidation]] === Sort[{"PaVe", "scalar master"}] &&
      AllTrue[Values[ruleCacheValidation], TrueQ]),
  "LegacyVirtualCacheMigrationsAreExactWhenUsed" ->
    virtualCacheMigrationGate,
  "EndpointCacheMetadataMigrationsAreExactWhenUsed" ->
    endpointCacheMetadataMigrationGate,
  "SeparateBareUVAndIRRegulatorsPresent" ->
    (uvRegulatorPresenceGate && irRegulatorPresenceGate),
  "InheritedSymbolicCountertermsRemoved" ->
    (inheritedCountertermPresenceGate && bareCountertermRemovalGate),
  "PropagatorDenominatorsAndScalarPairsResolved" ->
    (bareDenominatorResolutionGate && loDenominatorResolutionGate &&
      scalarPairResolutionGate),
  "CountertermDefinitionsUniquelySolvedAndInserted" ->
    (Length[countertermDefinitionSolutions] === 1 &&
      explicitCountertermInsertionGate &&
      renormalizedVirtualResolutionGate),
  "BareUVResiduesDeriveOneCommonLOMultiple" -> bareUVCommonRatioGate,
  "ExplicitQCDCountertermsCancelUVPole" -> uvCancellationGate,
  "AcceptedS08TwoBodyNormalizationMatched" ->
    (twoBodyPhaseDefinitionGate && loNormalizationGate),
  "VirtualLaurentExpandedThroughFiniteTerm" ->
    (virtualLaurentResolutionGate && virtualLaurentCacheValidationGate),
  "VirtualDoublePoleMatchesDefinedUniversalFactor" ->
    virtualDoublePoleGate,
  "AcceptedS09CacheHashesAndMetadataValidated" ->
    (expansionCacheDiskHashGate &&
      AllTrue[
        Flatten[Values /@ Values[expansionCacheValidation]],
        TrueQ
      ]),
  "FormalEndpointPlaceholderInventoryDerived" ->
    (endpointPlaceholderCount ===
      Total[Values[endpointPlaceholderCountsByProjector]] &&
      AllTrue[
        Values[endpointPlaceholderCountsByProjector],
        TrueQ[# > 0] &
      ]),
  "BothProjectorsProcessed" ->
    Sort[Keys[endpointDataByProjector]] === Sort[projectors],
  "AllCurrentRemainderTermsStructurallyPartitioned" ->
    AllTrue[
      Values[endpointDataByProjector],
      Length[# ["StandardTermIndices"]] +
          Length[# ["Alpha2TermIndices"]] ===
        # ["RemainderTermCount"] &
    ],
  "AllExceptionalEndpointRatiosDerivedAndContentBound" -> alpha2RatioGate,
  "Alpha2EndpointsDerivedByTwoExactMethodsAndContentBound" ->
    alpha2EndpointConstructionGate,
  "NoSingularLogTermOutsideDerivedGroups" ->
    AllTrue[
      Values[endpointDataByProjector[[
        All, "UncoveredSingularLogTermIndices"
      ]]],
      # === {} &
    ],
  "PhysicalBranchGroupsDerivedBeforeIndividualLaurent" ->
    derivedCoupledGroupGate,
  "StrongerEndpointPoleAbsentThroughFiniteRequirement" ->
    AllTrue[
      Flatten[
        Values /@ Values[
          endpointDataByProjector[[All, "StrongerPoleOrders"]]
        ]
      ],
      TrueQ[# === 0] &
    ],
  "EndpointValuesAreFiniteAndS23Independent" ->
    AllTrue[
      Join[
        Values[endpointDataByProjector[[All, "EndpointValue"]]],
        Values[endpointDataByProjector[[All, "Alpha2EndpointValue"]]]
      ],
      ! invalidEndpointQ[#] && FreeQ[#, s23] &
    ],
  "RealActionsHaveSubtractedSymbolicTestFunctionForm" ->
    realActionStructureGate,
  "VirtualActionsContainNoUnresolvedLoopObjects" ->
    virtualActionResolutionGate,
  "CombinedActionsContainNoDistributionOrLoopPlaceholders" ->
    combinedActionResolutionGate,
  "EndpointCachesExactlyReloadedAndDiskBound" ->
    (endpointFinalCacheReloadGate && endpointFinalCacheDiskHashGate),
  "EndpointParallelBatchesBoundedAndFallbacksProvenanced" ->
    endpointBatchRecoveryGate,
  "UnitAdditionalHqgWeightRetained" -> TrueQ[hardKernelWeight === 1],
  "EndpointWorkersValidatedAndClosed" ->
    (AllTrue[
        parallelKernelLaunchIDSetsSeen,
        Length[#] === requestedParallelKernels && DuplicateFreeQ[#] &
      ] && If[
        endpointParallelWorkRequired,
        Length[parallelKernelIDsSeen] === requestedParallelKernels &&
          DuplicateFreeQ[parallelKernelIDsSeen],
        parallelKernelIDsSeen === {}
      ] && $KernelCount === 0),
  "CompletedLaurentProgressCachesRemoved" -> progressCacheCleanupGate,
  "NoTemporaryArtifactRemains" -> temporaryArtifactGate,
  "CalculationRemainsFullySymbolic" -> fullySymbolicActionGate,
  "ImmutableInputsUnchangedBeforePublication" ->
    immutableInputIdentityGate
|>;
assert[AllTrue[Values[s10Checks], TrueQ],
  "At least one final S10 validation check is not True."];

compactEndpointDataByProjector = Map[
  KeyDrop[
    #,
    {
      "Action", "EndpointValue", "Alpha2EndpointValue",
      "ReducedStrongerPoleResidual"
    }
  ] &,
  endpointDataByProjector
];
endpointCacheSHA256 = AssociationMap[
  endpointDataByProjector[#, "EndpointCacheSHA256"] &,
  projectors
];
virtualCachePaths = <|
  "PaVe" -> paVeCachePath,
  "ScalarMasters" -> scalarMasterCachePath,
  "Laurent" -> laurentCachePath
|>;
virtualCacheSHA256 = <|
  "PaVe" -> paVeCacheSHA256,
  "ScalarMasters" -> scalarMasterCacheSHA256,
  "Laurent" -> virtualLaurentCacheSHA256
|>;

compactS10ResultValidQ[candidate_Association] := Module[
  {endpointSummaries, distributionLedger, endpointCacheBytes},
  endpointSummaries = Quiet@Check[
    candidate[
      "EndpointResolution", "EndpointDataByProjector"
    ],
    $Failed
  ];
  distributionLedger = Quiet@Check[
    candidate["DistributionActions"],
    $Failed
  ];
  endpointCacheBytes = Total[FileByteCount /@ Values[endpointCachePaths]];
  AssociationQ[endpointSummaries] &&
    Sort[Keys[endpointSummaries]] === Sort[projectors] &&
    AllTrue[
      projectors,
      Function[projector,
        AssociationQ[endpointSummaries[projector]] &&
          Intersection[
            Keys[endpointSummaries[projector]],
            {
              "Action", "EndpointValue", "Alpha2EndpointValue",
              "ReducedStrongerPoleResidual"
            }
          ] === {}
      ]
    ] &&
    AssociationQ[distributionLedger] &&
    Intersection[
      Keys[distributionLedger],
      {"RealActions", "VirtualActions", "CombinedActions"}
    ] === {} &&
    distributionLedger["RealEndpointCacheByProjector"] ===
      endpointCachePaths &&
    distributionLedger["RealEndpointCacheSHA256"] ===
      endpointCacheSHA256 &&
    distributionLedger["VirtualLaurentCache"] === laurentCachePath &&
    distributionLedger["VirtualLaurentCacheSHA256"] ===
      virtualLaurentCacheSHA256 &&
    endpointCacheBytes > 0 && ByteCount[candidate] < endpointCacheBytes
];

s10Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg;qg real endpoint action plus UV-renormalized symbolic virtual action",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s09Path,
  "SourceResultSHA256" -> s09SHA256,
  "SourceS08" -> s08Path,
  "SourceS08SHA256" -> s08SHA256,
  "SourceS07" -> s07Path,
  "SourceS07SHA256" -> s07SHA256,
  "InputProvenance" -> <|
    "S09ResultPath" -> s09Path,
    "S09ResultSHA256" -> s09SHA256,
    "S09SourcePath" -> s09ProgramPath,
    "S09SourceSHA256" -> s09ProgramSHA256,
    "S08ResultPath" -> s08Path,
    "S08ResultSHA256" -> s08SHA256,
    "S08SourcePath" -> s08ProgramPath,
    "S08SourceSHA256" -> s08ProgramSHA256,
    "S07ResultPath" -> s07Path,
    "S07ResultSHA256" -> s07SHA256,
    "S07SourcePath" -> s07ProgramPath,
    "S07SourceSHA256" -> s07ProgramSHA256
  |>,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> referencePDFSHA256,
    "Equations" ->
      "endpoint identities and Appendix E virtual-convention handoff"
  |>,
  "ReferencePDFSHA256" -> referencePDFSHA256,
  "BigTMDConvention" -> bigTMDConvention,
  "BigTMDProjectorMapping" -> bigTMDProjectorMapping,
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "FragmentingParton" -> fragmentingParton,
  "Bookkeeping" -> <|
    "Charge" -> chargeBookkeeping,
    "InitialState" -> initialStateBookkeeping,
    "Dimensional" -> dimensionalBookkeeping,
    "AdditionalMultiplicativeWeightAtS10" -> hardKernelWeight,
    "PhysicalFlavorChargeWeightAppliedAtS10" ->
      physicalFlavorChargeWeightAppliedAtS09,
    "CollinearFactorizationAppliedAtS10" -> False
  |>,
  "CalculationMode" ->
    "fully analytic and symbolic; no numerical kinematics, PDFs, FFs, or concrete test function",
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlaceholderCountAfter" -> 0,
    "Method" ->
      "runtime-derived physical-root groups are resolved as complete equations on both root signs in one shared t-series basis before any individual extraction; only nongrouped ordinary alpha=1 terms use factorwise endpoint Laurent extraction; every Hqg-detected base^(-1-epsilon) with base/s23 finite is refactored into the alpha=2 delta coefficient and doubled logarithmic tower",
    "S09PlaceholderCountsByProjectorBefore" ->
      endpointPlaceholderCountsByProjector,
    "S09PlaceholderCountsByProjectorAfter" ->
      AssociationMap[Count[#, _S09EndpointValue, Infinity] &,
        combinedConvolutionActions],
    "Alpha2EndpointConstruction" -> <|
      "Version" -> alpha2EndpointConstructionVersion,
      "ExactCoefficientMethods" -> {"SeriesData", "SeriesCoefficient"},
      "AcceptedInvalidFactorEndpointSHA256HexByProjector" ->
        acceptedAlpha2InvalidFactorEndpointSHA256HexByProjector,
      "InvalidFactorEndpointSHA256HexByProjector" ->
        AssociationMap[
          endpointDataByProjector[
            #,
            "Alpha2InvalidFactorEndpointSHA256Hex"
          ] &,
          projectors
        ],
      "EndpointValueSHA256HexByProjector" ->
        AssociationMap[
          endpointDataByProjector[
            #,
            "Alpha2EndpointValueSHA256Hex"
          ] &,
          projectors
        ]
    |>,
    "EndpointDataByProjector" -> compactEndpointDataByProjector
  |>,
  "VirtualLaurentExpansion" -> <|
    "IntegralBasis" -> virtualIntegralBasis,
    "PackageXRuleCache" -> paVeCachePath,
    "PackageXRuleCacheSHA256" -> paVeCacheSHA256,
    "ScalarMasterRuleCache" -> scalarMasterCachePath,
    "ScalarMasterRuleCacheSHA256" -> scalarMasterCacheSHA256,
    "LaurentCache" -> laurentCachePath,
    "LaurentCacheSHA256" -> virtualLaurentCacheSHA256,
    "OrdersRetained" -> {-2, -1, 0},
    "UniversalDoublePoleRatio" -> expectedVirtualDoublePoleRatio,
    "UniversalDoublePoleResiduals" -> virtualDoublePoleResiduals,
    "EvaluatorConvention" ->
      "Package-X analytic continuation with implicit prefactor 1; UV/IR regulators unified only after explicit UV cancellation",
    "PaperConversionDeferredToS12" -> HoldForm[
      VirtualPaperConvention[epsilon] ==
        (2 Pi/ScaleMu)^(2 epsilon) *
          (1 - epsilon FeynCalc`CA (1 + 24 I Pi)/(
            24 (FeynCalc`CA + 2 FeynCalc`CF)
          ))
    ],
    "HermitianConvention" ->
      "paper Appendix E Eq. (E7) physical Re projection is applied only after Eq. (46) pole cancellation and finite endpoint assembly"
  |>,
  "DistributionActions" -> <|
    "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
    "TestFunctionAssumption" ->
      "arbitrary symbolic function regular at s23=0 and independent of epsilon",
    "EndpointDeltaConvention" ->
      "the lower-endpoint delta has full weight, matching the paper's endpoint identity",
    "RealEndpointCacheByProjector" -> endpointCachePaths,
    "RealEndpointCacheSHA256" -> endpointCacheSHA256,
    "RealActionField" -> "Action",
    "VirtualLaurentCache" -> laurentCachePath,
    "VirtualLaurentCacheSHA256" -> virtualLaurentCacheSHA256,
    "VirtualExpressionField" -> "LaurentThroughFinite",
    "CombinedActionDefinition" -> HoldComplete[
      S10CombinedAction[projector] ==
        S10RealActionFromEndpointCache[projector] +
          S10VirtualLaurentFromCache[projector] *
            S10ConvolutionTest[projector, 0]
    ],
    "RemainingIntegralType" ->
      "ordinary endpoint-subtracted integral on 0<=s23<=B(xi); a concrete PDF/FF test function is intentionally not supplied"
  |>,
  "HardKernelWeight" -> <|
    "AppliedMultiplicativeWeight" -> hardKernelWeight,
    "BigTMDLuminosityAppliedDownstream" -> "Sum_q e_q^2 f_q D_g",
    "NoHqqOrHggWeightImported" -> True
  |>,
  "VirtualContributionAtThisOrder" -> "evaluated through epsilon^0",
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "ProgramSHA256" -> programSHA256,
    "SourceS09SHA256" -> s09SHA256,
    "SourceS08SHA256" -> s08SHA256,
    "SourceS07SHA256" -> s07SHA256,
    "VirtualCaches" -> virtualCachePaths,
    "VirtualCacheSHA256" -> virtualCacheSHA256,
    "AcceptedLegacyVirtualProgramSHA256" ->
      acceptedLegacyVirtualProgramSHA256,
    "AcceptedLegacyVirtualCacheSHA256ByName" ->
      acceptedLegacyVirtualCacheSHA256ByName,
    "AcceptedFirstMigrationVirtualProgramSHA256" ->
      acceptedFirstMigrationVirtualProgramSHA256,
    "AcceptedFirstMigrationVirtualCacheSHA256ByName" ->
      acceptedFirstMigrationVirtualCacheSHA256ByName,
    "AcceptedSecondMigrationVirtualProgramSHA256" ->
      acceptedSecondMigrationVirtualProgramSHA256,
    "AcceptedSecondMigrationVirtualCacheSHA256ByName" ->
      acceptedSecondMigrationVirtualCacheSHA256ByName,
    "AcceptedThirdMigrationVirtualProgramSHA256" ->
      acceptedThirdMigrationVirtualProgramSHA256,
    "AcceptedThirdMigrationVirtualCacheSHA256ByName" ->
      acceptedThirdMigrationVirtualCacheSHA256ByName,
    "AcceptedFourthMigrationVirtualProgramSHA256" ->
      acceptedFourthMigrationVirtualProgramSHA256,
    "AcceptedFourthMigrationVirtualCacheSHA256ByName" ->
      acceptedFourthMigrationVirtualCacheSHA256ByName,
    "VirtualCacheMigrationRecords" -> virtualCacheMigrationRecords,
    "AcceptedEndpointMetadataCorrectionProgramSHA256" ->
      acceptedEndpointMetadataCorrectionProgramSHA256,
    "AcceptedEndpointMetadataCorrectionCacheSHA256ByProjector" ->
      acceptedEndpointMetadataCorrectionCacheSHA256ByProjector,
    "EndpointCacheMetadataMigrationRecords" ->
      endpointCacheMetadataMigrationRecords,
    "SourceExpansionCaches" -> expansionCachePaths,
    "SourceExpansionSHA256" -> expansionCacheSHA256,
    "EndpointCaches" -> endpointCachePaths,
    "EndpointCacheSHA256" -> endpointCacheSHA256,
    "AllCachesSourceBound" -> TrueQ[
      AllTrue[Values[ruleCacheValidation], TrueQ] &&
        virtualLaurentCacheValidationGate &&
        endpointFinalCacheReloadGate &&
        endpointFinalCacheDiskHashGate &&
        expansionCacheDiskHashGate
    ]
  |>,
  "ParallelExecution" -> <|
    "SchedulerSlots" -> schedulerSlots,
    "SchedulerSlotContractActive" -> IntegerQ[schedulerSlots],
    "RequestedEndpointWorkerCount" -> requestedParallelKernels,
    "RawEndpointParallelWorkRequired" -> endpointParallelWorkRequired,
    "ValidatedKernelIDsSeen" -> parallelKernelIDsSeen,
    "ParallelKernelLaunchIDSetsSeen" -> parallelKernelLaunchIDSetsSeen,
    "Alpha2WorkerKernelIDSetsSeen" -> alpha2ParallelKernelIDSetsSeen,
    "EndpointParallelBatchTimeLimitSeconds" ->
      endpointParallelBatchTimeLimitSeconds,
    "EndpointParallelBatchTimeoutCountByProjector" ->
      endpointParallelBatchTimeoutCountByProjector,
    "EndpointSerialFallbackSourceIndices" ->
      endpointSerialFallbackSourceIndices,
    "KernelExecutable" -> parallelKernelExecutable,
    "PerWorkerMemoryLimitBytes" -> endpointWorkerMemoryLimitBytes,
    "MemoryAvailableAtPlannerBytes" -> availableMemoryAtLaunch,
    "MemoryReserveBytes" -> parallelMemoryReserveBytes,
    "ParallelizedWork" ->
      If[
        endpointParallelWorkRequired,
        "independent uncached nongrouped endpoint Laurent terms in deterministic memory-admitted batches of up to the requested worker count; grouped positions never enter a worker",
        "none: every ordinary coefficient and every pre-individual grouped equation was present in the exact current-source cache"
      ],
    "CheckpointWriter" -> "parent kernel only, atomically after each batch",
    "Fallback" ->
      "a parent-deadline, malformed, or memory-bounded worker result closes all workers and is recomputed exactly once serially before checkpointing; later batches launch fresh bounded workers",
    "VirtualAlgebraMode" ->
      "serial bounded reconstruction; no large virtual expression is copied to a worker"
  |>,
  "MemoryStrategy" ->
    "validate or exactly migrate unchanged virtual caches; derive each physical-root group serially from one compressed shared root/function basis before individual extraction; release completed virtual expressions; launch two to eight 1.25-GiB bounded workers lazily only for missing nongrouped endpoint terms; impose a 900-second parent deadline per ordinary batch, close workers before exact serial fallback, and relaunch fresh workers for later batches; close any workers and reload only validated caches for final actions",
  "Checks" -> s10Checks,
  "NotPerformedAtThisStage" -> {
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "evaluator-to-paper virtual convention conversion reserved for S12",
    "physical Hermitian Re projection before finite Eq. (46) assembly",
    "Eq. (46) initial-state PDF and final-state FF subtraction",
    "claim of collinear-pole cancellation before factorization",
    "epsilon -> 0 finite hard-part limit",
    "finite comparison with BigTMD Pg/Ppp fchn3A kernels",
    "numerical PDF/FF convolution"
  }
|>;

compactResultGate = compactS10ResultValidQ[s10Result];
AssociateTo[
  s10Checks,
  "CompactResultReferencesCachesWithoutDuplicatingActions" ->
    compactResultGate
];
s10Result["Checks"] = s10Checks;
finalCompactResultGate = compactS10ResultValidQ[s10Result];
assert[
  compactResultGate && finalCompactResultGate &&
    AllTrue[Values[s10Result["Checks"]], TrueQ],
  "The compact S10 result candidate failed its source-native gate."
];

Print["S10_STAGE: writing " <> resultPath];
writeAtomic[s10Result, resultPath];
reloadedResult = Quiet@Check[Get[resultPath], $Failed];
resultReloadGate = TrueQ[
  AssociationQ[reloadedResult] && SameQ[reloadedResult, s10Result] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["ProgramSHA256"] === programSHA256 &&
    reloadedResult["InputProvenance", "S09ResultSHA256"] === s09SHA256 &&
    reloadedResult[
      "DistributionActions", "RealEndpointCacheSHA256"
    ] === endpointCacheSHA256 &&
    reloadedResult[
      "DistributionActions", "VirtualLaurentCacheSHA256"
    ] === virtualLaurentCacheSHA256 &&
    AllTrue[Values[reloadedResult["Checks"]], TrueQ] &&
    compactS10ResultValidQ[reloadedResult]
];
assert[resultReloadGate,
  "The final compact S10 result failed exact reload validation."];

resultCacheDiskBindingGate = TrueQ[
  AssociationMap[
    fileSHA256Hex[endpointCachePaths[#]] &,
    projectors
  ] === endpointCacheSHA256 &&
    AssociationMap[
      fileSHA256Hex[virtualCachePaths[#]] &,
      Keys[virtualCachePaths]
    ] === virtualCacheSHA256 &&
    AssociationMap[
      fileSHA256Hex[expansionCachePaths[#]] &,
      projectors
    ] === recordedExpansionCacheSHA256
];
assert[resultCacheDiskBindingGate,
  "The final S10 result cache identities do not match the disk files."];

postPublicationInputIdentityGate = immutableInputIdentitiesQ[];
assert[postPublicationInputIdentityGate,
  "An accepted input identity changed during S10 publication."];
postPublicationTemporaryArtifactGate = FileNames[
  FileNameJoin[{scriptDirectory, "s10_*.tmp.*"}]
] === {};
assert[postPublicationTemporaryArtifactGate,
  "An S10 temporary artifact remains after final publication."];

resultSHA256 = fileSHA256Hex[resultPath];
resultDiskIdentityGate = TrueQ[
  StringLength[resultSHA256] === 64 &&
    StringMatchQ[
      resultSHA256,
      RegularExpression["[0-9a-f]{64}"]
    ] &&
    fileSHA256Hex[resultPath] === resultSHA256
];
assert[resultDiskIdentityGate,
  "The finalized S10 result does not have a stable SHA-256 identity."];
resultCompactDiskSizeGate = TrueQ[
  FileByteCount[resultPath] <
    Total[FileByteCount /@ Values[endpointCachePaths]]
];
assert[resultCompactDiskSizeGate,
  "The finalized S10 result is not compact relative to its endpoint caches."];
Print["S10_SUCCESS_SYMBOLIC"];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_SHA256=" <> resultSHA256];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CHECKS=", InputForm[s10Checks]];
Print["S10_RESULT_RELOAD_GATE=", InputForm[resultReloadGate]];
Print[
  "S10_RESULT_CACHE_DISK_BINDING_GATE=",
  InputForm[resultCacheDiskBindingGate]
];
Print[
  "S10_UPSTREAM_IDENTITIES_UNCHANGED=",
  InputForm[postPublicationInputIdentityGate]
];

Quit[0];

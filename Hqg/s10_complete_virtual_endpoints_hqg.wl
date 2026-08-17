(* ::Package:: *)

(*
  Hqg stage s10.

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
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];
$FCAdvice = False;

gibibyte = 1024^3;
parallelMemoryReserveBytes = 6 gibibyte;
endpointWorkerMemoryLimitBytes = 1280 1024^2;
availableMemoryAtLaunch = Quiet@Check[MemoryAvailable[], 0];
requestedParallelKernels = Min[
  8,
  Max[
    2,
    Floor[
      Max[0, availableMemoryAtLaunch - parallelMemoryReserveBytes]/
        endpointWorkerMemoryLimitBytes
    ]
  ]
];
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel";
parallelKernelConfiguration = If[
  Length[$ConfiguredKernels] > 0,
  ReplacePart[
    First[$ConfiguredKernels],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernels,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ],
  Missing["NoLocalKernelConfiguration"]
];
parallelKernelCount = 0;
parallelKernelIDsSeen = {};
endpointParallelWorkRequired = False;
Print[
  "S10_ENDPOINT_MEMORY_PLAN: availableGiB=",
  N[availableMemoryAtLaunch/gibibyte, 4],
  " reserveGiB=", N[parallelMemoryReserveBytes/gibibyte, 3],
  " perWorkerLimitGiB=",
  N[endpointWorkerMemoryLimitBytes/gibibyte, 3],
  " requestedKernels=", requestedParallelKernels
];
Print[
  "S10_MEMORY_STAGE: virtual reconstruction remains serial; bounded " <>
    "workers are launched only after completed virtual data is released"
];

ClearAll[
  fatal, assert, writeAtomic, zeroEquivalentQ, setTwoBodyKinematics,
  ensureEndpointParallelKernels, closeEndpointParallelKernels,
  endpointWorkerEvaluate,
  evaluatePaVe, obtainPaVeRules, transformTwoBodyCoefficient,
  virtualLaurentTerms, boundedLaurentPieces, partitionLaurentPieces,
  pppTerm2FactorwiseLaurent, cleanupLaurentSubpartCaches,
  laurentSubpartCachePath, laurentSubpartCachePattern,
  validPreCorrectionProgramSHA256Q, validIndependentCacheStageVersionQ,
  validLaurentInputHashQ,
  finiteLaurentTerm,
  finiteLaurentProjector, finiteLaurentPair,
  invalidEndpointQ, vanishingEndpointQ,
  exceptionalPowerTermIndices, singularLogTermIndices,
  splitEndpointProjection, endpointFactorwiseLaurent,
  endpointTermLaurent, structuralAlpha2EndpointData, exactPhysicalZeroQ,
  coupledEndpointGroupFinite, repairCoupledEndpointGroups,
  loadExpansion, processProjection, S10ConvolutionTest,
  S10EndpointCA, S10EndpointCF, S10EndpointFCGV, S10EndpointSMP
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
  launchResult = Quiet@Check[
    If[
      MissingQ[parallelKernelConfiguration],
      {},
      LaunchKernels[parallelKernelConfiguration]
    ],
    {}
  ];
  parallelKernelCount = $KernelCount;
  assert[parallelKernelCount === requestedParallelKernels,
    "Endpoint parallel launch created " <>
      ToString[parallelKernelCount] <> " of the required " <>
      ToString[requestedParallelKernels] <> " workers."];
  DistributeDefinitions[
    fatal, assert, invalidEndpointQ, endpointInertRules,
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
  parallelKernelIDsSeen = Union[parallelKernelIDsSeen, currentIDs];
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

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s09Path = FileNameJoin[{scriptDirectory, "s09_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
stageVersion = "HqgS10-v4";
independentLegacyStageVersion = "HqgS10-v3";
paVeCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v1_virtual_pax_rules"
}];
scalarMasterCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v1_virtual_scalar_rules"
}];
laurentCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v1_virtual_laurent"
}];
laurentProgressCachePath[projector_String] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector]
}];
laurentSubtermCachePath[projector_String, index_Integer] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index]
}];
laurentSubpartCachePath[
    projector_String, index_Integer, subindex_Integer, partindex_Integer
  ] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index] <> "_subterm_" <> ToString[subindex] <>
    "_part_" <> IntegerString[partindex, 10, 3]
}];
laurentSubpartCachePattern[
    projector_String, index_Integer, subindex_Integer
  ] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index] <> "_subterm_" <> ToString[subindex] <>
    "_part_*"
}];
paVeCacheVersion = 1;
scalarMasterCacheVersion = 1;
laurentCacheVersion = 1;
laurentProgressCacheVersion = 1;
laurentSubtermCacheVersion = 1;
laurentSubpartCacheVersion = 1;
pppLaurentPartLeafBudget = 1000000;
pppLaurentPartHardLeafLimit = 2500000;
preMemoryCorrectionProgramSHA256 =
  105760057790227778240537465937350466528734936791302150062908418547664897330660;
preMemoryCorrectionPgInputHash =
  73690668794968757684088104940735542713574535462437010271582036713425121427451;
preMemoryCorrectionPPPInputHash =
  113207599498339542855002826815744439221100513971733186586557211857627814175290;
preStreamingCorrectionProgramSHA256 =
  88727092961982947139784268582512358451798471613035552058436348586515368963509;
preStreamingCorrectionPgInputHash =
  23632057988757400540690277099449042473169350800685535831980231815537741239398;
preStreamingCorrectionPPPInputHash =
  77039341318221425383923231772192566332462063065583882903867272228856932463173;
preEndpointParallelProgramSHA256 =
  29536845413302882737092486927461240061273268817742180667577153972701132942689;
preEndpointParallelPgInputHash =
  62844477781471776907482706440449183341738769456923699851445086865921914608489;
preEndpointParallelPPPInputHash =
  91935397678780209361012889363405298831864870963016118579034916187669593182187;
preAdaptiveEndpointProgramSHA256 =
  26580586771229033880957082344206381766879270180779290096376147513489070811866;
preCoupledEndpointRepairProgramSHA256 =
  68570205711600407259774659632846623623348185839062313821133718429552064183539;
endpointCacheVersion = 2;
legacyEndpointCacheVersion = 1;
coupledEndpointRepairVersion = 1;
coupledEndpointGroups = <|
  "Pg" -> {{65, 66}},
  "PPP" -> {{38, 47}}
|>;
projectors = {"Pg", "PPP"};
endpointCachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_v2_endpoint_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_v2_endpoint_pp"}]
|>;
legacyEndpointCachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_v1_endpoint_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_v1_endpoint_pp"}]
|>;

validPreCorrectionProgramSHA256Q[hash_] :=
  TrueQ[hash === programSHA256 ||
    hash === preMemoryCorrectionProgramSHA256 ||
    hash === preStreamingCorrectionProgramSHA256 ||
    hash === preEndpointParallelProgramSHA256 ||
    hash === preAdaptiveEndpointProgramSHA256 ||
    hash === preCoupledEndpointRepairProgramSHA256];

validIndependentCacheStageVersionQ[version_] :=
  MemberQ[{stageVersion, independentLegacyStageVersion}, version];

validLaurentInputHashQ[projector_String, hash_, currentHash_] := TrueQ[
  hash === currentHash ||
    (projector === "Pg" && hash === preMemoryCorrectionPgInputHash) ||
    (projector === "PPP" && hash === preMemoryCorrectionPPPInputHash) ||
    (projector === "Pg" && hash === preStreamingCorrectionPgInputHash) ||
    (projector === "PPP" && hash === preStreamingCorrectionPPPInputHash) ||
    (projector === "Pg" && hash === preEndpointParallelPgInputHash) ||
    (projector === "PPP" && hash === preEndpointParallelPPPInputHash)
];

Print["S10_STAGE: loading and validating s09, s08, and s07 inputs"];
assert[FileExistsQ[s09Path], "s09_result does not exist."];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09], "s09_result did not load as an Association."];
assert[
  s09["Status"] === "CompleteWithSymbolicVirtual" &&
    s09["Stage"] === "HqgS09-v3" &&
    s09["Channel"] === "Hqg only",
  "s09_result is not the validated Hqg S09 artifact."
];
assert[AllTrue[Values[s09["Checks"]], TrueQ],
  "At least one s09 validation check is not True."];
assert[
  FileExistsQ[s09["Program"]] &&
    s09["ProgramSHA256"] === FileHash[s09["Program"], "SHA256"] &&
    FileExistsQ[s09["SourceResult"]] &&
    s09["SourceResultSHA256"] ===
      FileHash[s09["SourceResult"], "SHA256"],
  "An S09 program/source binding is stale."
];
s09SHA256 = FileHash[s09Path, "SHA256"];

s08Path = s09["SourceResult"];
assert[FileExistsQ[s08Path], "The s08 source result recorded by s09 is absent."];
s08 = Check[Get[s08Path], $Failed];
assert[
  AssociationQ[s08] && s08["Status"] === "Complete" &&
    s08["Stage"] === "HqgS08-v4" && s08["Channel"] === "Hqg only",
  "s08_result is absent, invalid, or incomplete."];
assert[AllTrue[Values[s08["Checks"]], TrueQ],
  "At least one s08 validation check is not True."];
assert[
  s08Path === s09["SourceResult"] &&
    FileHash[s08Path, "SHA256"] === s09["SourceResultSHA256"] &&
    FileExistsQ[s08["Program"]] &&
    s08["ProgramSHA256"] === FileHash[s08["Program"], "SHA256"] &&
    FileExistsQ[s08["SourceResult"]] &&
    s08["SourceResultSHA256"] ===
      FileHash[s08["SourceResult"], "SHA256"],
  "An S08 source/program binding is stale."
];
s08SHA256 = FileHash[s08Path, "SHA256"];

s07Path = s08["SourceResult"];
assert[FileExistsQ[s07Path], "The s07 source result recorded by s08 is absent."];
s07 = Check[Get[s07Path], $Failed];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v3" && s07["Channel"] === "Hqg only",
  "s07_result is absent, invalid, or incomplete."];
assert[AllTrue[Values[s07["Checks"]], TrueQ],
  "At least one s07 validation check is not True."];
assert[
  s07Path === s08["SourceResult"] &&
    FileHash[s07Path, "SHA256"] === s08["SourceResultSHA256"] &&
    FileExistsQ[s07["Program"]] &&
    s07["ProgramSHA256"] === FileHash[s07["Program"], "SHA256"],
  "An S07 source/program binding is stale."
];
s07SHA256 = FileHash[s07Path, "SHA256"];
assert[
  FileExistsQ[paperPath] &&
    s09["ReferencePDFSHA256"] === FileHash[paperPath, "SHA256"] &&
    s08["ReferencePDFSHA256"] === s09["ReferencePDFSHA256"] &&
    s07["ReferencePDFSHA256"] === s09["ReferencePDFSHA256"],
  "The S07-S09 paper binding is stale or inconsistent."
];
assert[
  s09["BigTMDConvention", "ChannelNumber"] === 3 &&
    s09["BigTMDConvention", "ChargeCase"] === "A only" &&
    s09["BigTMDProjectorMapping", "Pg"] === "NLO.Pg.fchn3A" &&
    s09["BigTMDProjectorMapping", "PPP"] === "NLO.Ppp.fchn3A" &&
    s09["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s09["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s09[
      "ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"
    ] === "Sum_q e_q^2 f_q D_g" &&
    s09["FragmentingParton"] === "gluon g(k1)",
  "The S09 BigTMD/charge/fragmentation convention is invalid."
];
electricChargeNormalization = s09["ElectricChargeNormalization"];
s09ProgramSHA256 = s09["ProgramSHA256"];
bigTMDConvention = s09["BigTMDConvention"];
bigTMDProjectorMapping = s09["BigTMDProjectorMapping"];
referencePDFSHA256 = s09["ReferencePDFSHA256"];
fragmentingParton = s09["FragmentingParton"];

virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];
loInput = s07["ScalarProjections", "LO_OAlphaS"];
loReference = s09["LOReferenceKernels"];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicRules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["Jacobian_dXi_dZeta_to_dXi_dS23"];
s23UpperB = changeOfVariables["S23UpperB"];
expansionCachePaths = s09[
  "AppendixF", "ExpandedKernelCachesByProjector"
];
assert[
  AssociationQ[expansionCachePaths] &&
    Sort[Keys[expansionCachePaths]] === Sort[projectors] &&
    AllTrue[Values[expansionCachePaths], FileExistsQ],
  "S09 does not provide both expansion caches."
];
expansionCacheSHA256 = AssociationMap[
  FileHash[expansionCachePaths[#], "SHA256"] &,
  projectors
];
endpointPlaceholderCount = s09[
  "EndpointExpansion", "SymbolicPlaceholderCount"
];
assert[endpointPlaceholderCount === 2,
  "Expected exactly two S09 endpoint placeholders."];
hardKernelWeight = s09["HardKernelWeight", "AppliedMultiplicativeWeight"];
assert[hardKernelWeight === 1,
  "The S09 Hqg hard-kernel weight is not unity."];
flavorChargeWeight = hardKernelWeight;

assert[Sort[Keys[virtualInput]] === Sort[projectors],
  "The s07 virtual input lacks Pg or PPP."];
assert[Sort[Keys[loInput]] === Sort[projectors],
  "The s07 LO input lacks Pg or PPP."];
assert[Sort[Keys[loReference]] === Sort[projectors],
  "The s09 LO reference lacks Pg or PPP."];

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

assert[And @@ (! FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualDimensional]),
  "The inherited virtual pair does not contain the expected QCD counterterms."];
assert[And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[bareVirtualDimensional]),
  "A symbolic QCD counterterm survived the bare-loop split."];

uniquePaVe = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional], _FeynCalc`PaVe, Infinity
];
assert[Length[uniquePaVe] === 97,
  "Expected 97 unique virtual PaVe functions, found " <>
    ToString[Length[uniquePaVe]] <> "."];
uniqueScalarMasters = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional],
  _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0,
  Infinity
];
assert[Length[uniqueScalarMasters] === 4 &&
    Count[uniqueScalarMasters, _FeynCalc`B0] === 2 &&
    Count[uniqueScalarMasters, _FeynCalc`C0] === 2 &&
    Count[uniqueScalarMasters, _FeynCalc`D0] === 0,
  "Expected exactly two B0 and two C0 virtual scalar masters."];
expectedScalarMasters = {
  FeynCalc`C0[0, 0, sHat, 0, 0, 0],
  FeynCalc`B0[sHat, 0, 0],
  FeynCalc`B0[-Q2 - sHat - tHat, 0, 0],
  FeynCalc`C0[0, 0, -Q2 - sHat - tHat, 0, 0, 0]
};
assert[
  Sort[uniqueScalarMasters] === Sort[expectedScalarMasters],
  "The Hqg direct scalar-master basis differs from its audited basis."
];
virtualIntegralBasis = <|
  "PaVeCount" -> Length[uniquePaVe],
  "B0Count" -> Count[uniqueScalarMasters, _FeynCalc`B0],
  "C0Count" -> Count[uniqueScalarMasters, _FeynCalc`C0],
  "D0Count" -> Count[uniqueScalarMasters, _FeynCalc`D0],
  "DirectScalarMasters" -> uniqueScalarMasters
|>;

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

obtainPaVeRules[
    integrals_List, cache_String, version_Integer, label_String
  ] := Module[
  {payload, cachedIntegrals = {}, values = {}, index, total},
  total = Length[integrals];
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading resumable Package-X cache"];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === version &&
        validIndependentCacheStageVersionQ[payload["StageVersion"]] &&
        payload["IntegralType"] === label &&
        payload["SourceS07SHA256"] === s07SHA256 &&
        validPreCorrectionProgramSHA256Q[payload["ProgramSHA256"]],
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
    assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
      "The resumable Package-X " <> label <> " cache was not written."];
  ];
  assert[Length[values] === total,
    "The Package-X " <> label <> " cache has incomplete coverage."];
  assert[And @@ (FreeQ[
        #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
          _FeynCalc`PaXEvaluateUVIRSplit
      ] & /@ values),
    "At least one cached Package-X " <> label <> " value is unresolved."];
  Thread[integrals -> values]
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
assert[And @@ (FreeQ[
      #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`PaXEvaluateUVIRSplit
    ] & /@ Values[bareVirtualSplit]),
  "A PaVe, scalar master, or Package-X evaluator remains in the virtual pair."];
assert[And @@ (! FreeQ[#, FeynCalc`EpsilonUV] & /@
      Values[bareVirtualSplit]),
  "A bare virtual projector lacks its explicit UV regulator."];
assert[And @@ (! FreeQ[#, FeynCalc`EpsilonIR] & /@
      Values[bareVirtualSplit]),
  "A bare virtual projector lacks its explicit IR regulator."];

setTwoBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[k1, k2] = sHat/2;
  FeynCalc`SPD[q, k1] = (-Q2 - tHat)/2;
  FeynCalc`SPD[q, k2] = (sHat + tHat)/2;
  FeynCalc`SPD[p, k1] = (Q2 + sHat + tHat)/2;
  FeynCalc`SPD[p, k2] = -tHat/2;
);

Print["S10_STAGE: resolving ordinary tree propagator denominators"];
setTwoBodyKinematics[];
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
assert[And @@ (FreeQ[#, _FeynCalc`FeynAmpDenominator] & /@
      Values[bareVirtualExplicit]),
  "A bare-loop FeynAmpDenominator remains unresolved."];
assert[And @@ (FreeQ[#, _FeynCalc`FeynAmpDenominator] & /@
      Values[loExplicit]),
  "An LO FeynAmpDenominator remains unresolved."];
assert[And @@ (FreeQ[#, _FeynCalc`Pair] & /@
      Join[Values[bareVirtualExplicit], Values[loExplicit]]),
  "A scalar Pair survived the symbolic-D denominator expansion."];

(* Explicit one-loop QCD constants in the convention of the saved amplitudes. *)
aSLoop = FeynCalc`SMP["g_s"]^2/(16 Pi^2);
deltaZGG = aSLoop (5 FeynCalc`CA/3 - 2 FeynCalc`Nf/3) *
  (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR);
deltaZgs = -aSLoop (11 FeynCalc`CA/6 - FeynCalc`Nf/3) /
  FeynCalc`EpsilonUV;
deltaZqAggregate = -2 aSLoop FeynCalc`CF *
  (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR);
explicitCountertermMultiplier =
  deltaZGG + 2 deltaZgs + deltaZqAggregate;

expectedBareUVRatio =
  FeynCalc`SMP["g_s"]^2 (FeynCalc`CF + FeynCalc`CA)/(8 Pi^2);
colorRule = FeynCalc`CF ->
  (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA);

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

bareUVRatioResiduals = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Together@Cancel[
          (bareUVResidues[projector]/
              (loExplicit[projector] /. epsilon -> 0) -
            expectedBareUVRatio) /. colorRule
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[And @@ (TrueQ[# === 0] & /@ Values[bareUVRatioResiduals]),
  "The evaluated bare UV residue is not the expected multiple of LO."];

countertermUVRatio = SeriesCoefficient[
  explicitCountertermMultiplier,
  {FeynCalc`EpsilonUV, 0, -1}
];
uvCancellationRatio = Together@Cancel[
  (expectedBareUVRatio + countertermUVRatio) /. colorRule
];
assert[uvCancellationRatio === 0,
  "The explicit QCD constants do not cancel the bare UV residue."];

(*
  The coefficient (without DiracDelta[s23]) is transformed exactly as in s08:
  multiply by 2 Pi/(2 Pi)^4 and by d zeta/d s23, apply the saved partonic
  substitutions, and then enforce the two-body endpoint s23=0.
*)
twoBodyPhaseCoefficient = (2 Pi)/(2 Pi)^4;
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
assert[And @@ (zeroEquivalentQ[#, 600] & /@
      Values[loNormalizationResiduals]),
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
assert[And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1 | _FeynCalc`PaVe | _FeynCalc`B0 |
        _FeynCalc`C0 | _FeynCalc`D0 | _FeynCalc`FeynAmpDenominator
    ] & /@ Values[renormalizedVirtualSplit]),
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
    values = {}, reusedInputHashes = {}, subindex, subtotal, subtermAnswer
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
        payload["Projector"] === projector &&
        payload["CoarseTermIndex"] === index &&
        validLaurentInputHashQ[
          projector, payload["InputHash"], inputHash
        ] &&
        payload["SubtermCount"] === subtotal,
      projector <> " virtual Laurent subterm cache is invalid."];
    values = payload["LaurentSubterms"];
    assert[ListQ[values] && Length[values] <= subtotal,
      projector <> " virtual Laurent subterm progress is invalid."];
    reusedInputHashes = DeleteDuplicates@Join[
      Lookup[payload, "ReusedInputHashes", {}],
      If[payload["InputHash"] === inputHash, {}, {payload["InputHash"]}]
    ];
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
      "Projector" -> projector,
      "CoarseTermIndex" -> index,
      "InputHash" -> inputHash,
      "ReusedInputHashes" -> reusedInputHashes,
      "SubtermCount" -> subtotal,
      "LaurentSubterms" -> values
    |>;
    writeAtomic[payload, subtermCache];
    assert[FileExistsQ[subtermCache] && FileByteCount[subtermCache] > 0,
      projector <> " virtual Laurent subterm cache was not written."];
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
    reusedInputHashes = {}, index, total, termAnswer
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
      FileHash[$InputFileName, "SHA256"],
      FileHash[s07Path, "SHA256"],
      FileHash[paVeCachePath, "SHA256"],
      FileHash[scalarMasterCachePath, "SHA256"],
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
        payload["Projector"] === projector &&
        validLaurentInputHashQ[
          projector, payload["InputHash"], inputHash
        ] &&
        payload["TermCount"] === total,
      projector <> " virtual Laurent progress cache is invalid."];
    assert[ListQ[values] && Length[values] <= total,
      projector <> " virtual Laurent progress has an invalid term list."];
    reusedInputHashes = DeleteDuplicates@Join[
      Lookup[payload, "ReusedInputHashes", {}],
      If[payload["InputHash"] === inputHash, {}, {payload["InputHash"]}]
    ];
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
      "Projector" -> projector,
      "InputHash" -> inputHash,
      "ReusedInputHashes" -> reusedInputHashes,
      "TermCount" -> total,
      "LaurentTerms" -> values
    |>;
    writeAtomic[payload, progressCache];
    assert[FileExistsQ[progressCache] && FileByteCount[progressCache] > 0,
      projector <> " virtual Laurent progress cache was not written."];
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

finiteLaurentPair[pair_Association, cache_String] := Module[
  {payload, answer = <||>, projector, projectorExpression, progressCache},
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading virtual Laurent cache"];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === laurentCacheVersion &&
        validIndependentCacheStageVersionQ[payload["StageVersion"]] &&
        payload["SourceS07SHA256"] === s07SHA256 &&
        validPreCorrectionProgramSHA256Q[payload["ProgramSHA256"]] &&
        payload["PaVeCacheSHA256"] === FileHash[paVeCachePath, "SHA256"] &&
        payload["ScalarMasterCacheSHA256"] ===
          FileHash[scalarMasterCachePath, "SHA256"],
      "The virtual Laurent cache is invalid."];
    answer = payload["LaurentThroughFinite"];
    assert[AssociationQ[answer] && Sort[Keys[answer]] === Sort[projectors],
      "The virtual Laurent cache has invalid projector keys."];
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
    "SourceS07" -> s07Path,
    "SourceS07SHA256" -> s07SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "PaVeCache" -> paVeCachePath,
    "PaVeCacheSHA256" -> FileHash[paVeCachePath, "SHA256"],
    "ScalarMasterCache" -> scalarMasterCachePath,
    "ScalarMasterCacheSHA256" ->
      FileHash[scalarMasterCachePath, "SHA256"],
    "RegulatorsUnifiedAfterUVCheck" -> True,
    "EvaluatorConvention" -> "Package-X implicit prefactor 1",
    "OrdersRetained" -> {-2, -1, 0},
    "LaurentThroughFinite" -> answer
  |>;
  writeAtomic[payload, cache];
  assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
    "The virtual Laurent cache was not written."];
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
assert[And @@ (FreeQ[
      #,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator |
        dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualLaurent]),
  "A completed virtual Laurent coefficient retains an unresolved object."];

expectedVirtualDoublePoleRatio =
  -FeynCalc`SMP["g_s"]^2 (2 FeynCalc`CF + FeynCalc`CA)/(8 Pi^2);
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
assert[And @@ (TrueQ[# === 0] & /@ Values[virtualDoublePoleResiduals]),
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
  The Hqg endpoint logarithms in the proven groups are coupled through the
  physical square root

    Sqrt[Q2^2 (a zH-r (1-zH))^2/(r+zH-r zH)^2].

  Resolve that root separately on the two physical signs of
  delta=a zH-r (1-zH).  A logarithm that vanishes only after this branch
  resolution is represented as Log[s23]+Log[slope], and every positive
  power of the inert endpoint logarithm must cancel in the complete group.
  No branch-blind PowerExpand is used.
*)
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
  assert[Length[sourceTerms] === Length[finiteTerms] ===
      Length[sourceIndices],
    label <> " coupled endpoint group has inconsistent term lists."];
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
      Cancel[Together[rootArgument - expectedRootRadicand]] === 0
    ] :> positiveRoot^(2 rootPower);
    canonical[value_] := FixedPoint[
      Factor[Together[# /. rootRule]] &,
      value,
      3
    ];
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && rootSign deltaPhysical > 0;

    transformTerm[sourceTerm_, finiteTerm_, sourceIndex_] := Module[
      {
        held, transformed, rootRadicands, sourceLogArguments,
        zeroSourceLogArguments, slopes, slope,
        zeroHeldLogCount = 0, result
      },
      held = finiteTerm /. Log[value_] :> heldLog[value];
      held = held /. PolyLog[order_, value_] :> heldPolyLog[order, value];
      transformed = held /. physicalSubstitution;
      rootRadicands = DeleteDuplicates@Cases[
        transformed,
        Power[
          radicand_,
          power_Rational?((Denominator[#] === 2) &)
        ] :> radicand,
        Infinity
      ];
      assert[And @@ (
          TrueQ[Cancel[Together[# - expectedRootRadicand]] === 0] & /@
            rootRadicands
        ),
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected physical endpoint square root."];
      transformed = transformed /. rootRule;

      sourceLogArguments = DeleteDuplicates@Cases[
        sourceTerm,
        Log[value_] :> value,
        Infinity
      ];
      zeroSourceLogArguments = Select[
        sourceLogArguments,
        TrueQ[canonical[(# /. physicalSubstitution) /. s23 -> 0] === 0] &
      ];
      slopes = {};
      slope = Missing["NotNeeded"];

      transformed = transformed /. heldLog[value_] :> Module[
        {argument = canonical[value]},
        If[TrueQ[argument === 0],
          zeroHeldLogCount++;
          If[slopes === {},
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
                " has a non-linear or invalid vanishing logarithm."];
            slope = First[slopes]
          ];
          assert[! MissingQ[slope] && ! invalidEndpointQ[slope],
            label <> " term " <> ToString[sourceIndex] <>
              " cannot match its endpoint logarithm to a source slope."];
          endpointLog + heldLog[slope],
          heldLog[argument]
        ]
      ];
      transformed = transformed /.
        heldPolyLog[order_, value_] :> heldPolyLog[order, canonical[value]];
      assert[zeroHeldLogCount <= 2,
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected number of endpoint logarithms."];
      result = transformed /.
        heldLog[value_] :> Log[value] /.
        heldPolyLog[order_, value_] :> PolyLog[order, value];
      assert[
        FreeQ[result, heldLog | heldPolyLog] &&
          ! invalidEndpointQ[result] && FreeQ[result, s23],
        label <> " term " <> ToString[sourceIndex] <>
          " did not produce a valid branch-resolved endpoint value."];
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
    If[maximumDegree === 0,
      Print[
        "S10_COUPLED_ENDPOINT_CHECK: label=", label,
        " rootSign=", rootSign,
        " logPower=none status=log-free-after-branch-grouping"
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
          ToString[rootSign] <> "."];
      Print[
        "S10_COUPLED_ENDPOINT_CHECK: label=", label,
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
        ToString[rootSign] <> "."];
    branchResults[rootSign] = constant;
    Clear[branchTerms, coefficient, constant];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];

  groupResult = Piecewise[
    {{branchResults[1] /. inverseSubstitution, originalDelta >= 0}},
    branchResults[-1] /. inverseSubstitution
  ];
  assert[
    FreeQ[groupResult, endpointLog | heldLog | heldPolyLog | s23] &&
      ! invalidEndpointQ[groupResult],
    label <> " grouped endpoint result is invalid."];
  groupResult
];

repairCoupledEndpointGroups[
    standardTerms_List, standardIndices_List, finite_List,
    methods_List, groups_List, label_String
  ] := Module[
  {
    repairedFinite = finite, repairedMethods = methods,
    group, positions, groupedFinite
  },
  assert[DuplicateFreeQ[Flatten[groups]],
    label <> " coupled endpoint groups overlap."];
  Do[
    positions = Flatten[
      FirstPosition[standardIndices, #] & /@ group
    ];
    assert[Length[positions] === Length[group] &&
        And @@ (IntegerQ /@ positions),
      label <> " coupled endpoint source indices are missing."];
    Print[
      "S10_COUPLED_ENDPOINT_STAGE: label=", label,
      " sourceTerms=", group
    ];
    groupedFinite = coupledEndpointGroupFinite[
      standardTerms[[positions]], repairedFinite[[positions]], group, label
    ];
    repairedFinite[[First[positions]]] = groupedFinite;
    repairedMethods[[First[positions]]] =
      "physical-branch coupled group";
    Scan[(repairedFinite[[#]] = 0) &, Rest[positions]];
    Scan[
      (repairedMethods[[#]] = "absorbed into physical-branch group") &,
      Rest[positions]
    ];,
    {group, groups}
  ];
  <|
    "FiniteCoefficients" -> repairedFinite,
    "Methods" -> repairedMethods
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

loadExpansion[projector_String] := Module[{payload, path},
  path = expansionCachePaths[projector];
  Print["S10_STAGE: loading S09 Appendix-F cache for " <> projector];
  payload = Check[Get[path], $Failed];
  assert[AssociationQ[payload],
    projector <> " S09 expansion cache is not an Association."];
  assert[payload["StageVersion"] === "HqgS09-v3",
    projector <> " S09 expansion cache has the wrong stage version."];
  assert[
    payload["Channel"] === "Hqg only" &&
      payload["TensorRole"] === "RealQG" &&
      payload["ProgramSHA256"] === s09ProgramSHA256 &&
      payload["ElectricChargeNormalization"] ===
        electricChargeNormalization &&
      payload["AppliedHardKernelWeight"] === 1,
    projector <> " S09 expansion cache has invalid Hqg provenance."
  ];
  assert[payload["SourceS08SHA256"] === s08SHA256,
    projector <> " S09 expansion cache has stale S08 provenance."];
  assert[payload["Projector"] === projector,
    projector <> " S09 expansion cache has the wrong projector label."];
  assert[FreeQ[
      payload["Expression"],
      _S08Case2Master | _Hypergeometric2F1 | _Beta
    ],
    projector <> " S09 expansion cache is incomplete."];
  payload["Expression"]
];

processProjection[projector_String] := Module[
  {
    label, expression, split, terms, prefactor, termCount,
    exceptionalIndices, logIndices, alpha2Data,
    standardIndices, standardTerms, standardTermCount,
    groups, cachePath, cachePayload, legacyCachePath, legacyCachePayload,
    repairCurrent, repairResult,
    poles = {}, finite = {}, flags = {}, methods = {}, startIndex,
    remainingPositions, batchPositions, batchInputs, batchAnswers,
    batchOffset, position, sourceIndex, termAnswer,
    rawPoleResidual, reducedPoleResidual, poleOrders,
    prefactorEndpoint, endpointValue, regularFunction,
    alpha2RegularFunction, alpha2EndpointValue,
    testAtS, testAtZero, logarithmTower, alpha2LogarithmTower, action
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
  assert[logIndices === {},
    projector <> " has structurally detected singular endpoint logarithms " <>
      "at terms " <> ToString[logIndices] <>
      "; grouped treatment is required before continuation."];
  Print["S10_CHECKPOINT: " <> projector <>
    " structural alpha=2 source terms " <>
    ToString[InputForm[exceptionalIndices]]];
  alpha2Data = Map[
    structuralAlpha2EndpointData[
      prefactor, terms[[#]], #, label
    ] &,
    exceptionalIndices
  ];
  standardIndices = Complement[Range[termCount], exceptionalIndices];
  standardTerms = terms[[standardIndices]];
  standardTermCount = Length[standardTerms];
  assert[standardTermCount + Length[alpha2Data] === termCount,
    projector <> " structural endpoint partition is incomplete."];
  groups = Lookup[coupledEndpointGroups, projector, {}];
  assert[groups =!= {} &&
      ContainsAll[standardIndices, DeleteDuplicates[Flatten[groups]]],
    projector <> " coupled endpoint groups are not contained in the " <>
      "standard source-term partition."];

  cachePath = endpointCachePaths[projector];
  legacyCachePath = legacyEndpointCachePaths[projector];
  If[FileExistsQ[cachePath],
    cachePayload = Check[Get[cachePath], $Failed];
    If[
      AssociationQ[cachePayload] &&
      cachePayload["CacheVersion"] === endpointCacheVersion &&
      cachePayload["StageVersion"] === stageVersion &&
      cachePayload["SourceS09SHA256"] === s09SHA256 &&
      cachePayload["ProgramSHA256"] === programSHA256 &&
      cachePayload["ElectricChargeNormalization"] ===
        electricChargeNormalization &&
      cachePayload["AppliedHardKernelWeight"] === 1 &&
      cachePayload["Projector"] === projector &&
      cachePayload["SourceExpansionSHA256"] ===
        expansionCacheSHA256[projector] &&
      cachePayload["RemainderTermCount"] === termCount &&
      Lookup[cachePayload, "StandardTermIndices", $Failed] ===
        standardIndices &&
      Lookup[cachePayload, "Alpha2TermIndices", $Failed] ===
        exceptionalIndices &&
      Lookup[
        cachePayload,
        "DirectSubstitutionSingularLogTermIndices",
        $Failed
      ] === logIndices &&
      Lookup[cachePayload, "CoupledLogEndpointRepairVersion", 0] ===
        coupledEndpointRepairVersion &&
      Lookup[cachePayload, "CoupledLogEndpointGroups", {}] === groups &&
      MemberQ[
        {True, False},
        Lookup[cachePayload, "CoupledLogEndpointRepairApplied", Missing[]]
      ],
      poles = Lookup[cachePayload, "PoleCoefficients", {}];
      finite = Lookup[cachePayload, "FiniteCoefficients", {}];
      flags = Lookup[cachePayload, "RequiredPoleSubtraction", {}];
      methods = Lookup[cachePayload, "Methods", {}];
      assert[
        ListQ[poles] && ListQ[finite] && ListQ[flags] && ListQ[methods] &&
        Length[poles] === Length[finite] === Length[flags] ===
          Length[methods] && Length[poles] <= standardTermCount,
        projector <> " endpoint cache has inconsistent completed lists."
      ];
      assert[
        ! TrueQ[cachePayload["CoupledLogEndpointRepairApplied"]] ||
          Length[poles] === standardTermCount,
        projector <> " endpoint cache claims a repair before completion."
      ];
      Print["S10_STAGE: resuming " <> projector <> " endpoint cache at " <>
        ToString[Length[poles]] <> "/" <> ToString[standardTermCount]],
      Print["S10_STAGE: removing stale endpoint cache for " <> projector];
      DeleteFile[cachePath]
    ]
  ];
  If[! FileExistsQ[cachePath] && poles === {} &&
      FileExistsQ[legacyCachePath],
    Print[
      "S10_STAGE: validating and migrating v1 raw endpoint coefficients " <>
        "for " <> projector
    ];
    legacyCachePayload = Check[Get[legacyCachePath], $Failed];
    assert[
      AssociationQ[legacyCachePayload] &&
        legacyCachePayload["CacheVersion"] === legacyEndpointCacheVersion &&
        legacyCachePayload["StageVersion"] ===
          independentLegacyStageVersion &&
        legacyCachePayload["SourceS09SHA256"] === s09SHA256 &&
        validPreCorrectionProgramSHA256Q[
          legacyCachePayload["ProgramSHA256"]
        ] &&
        legacyCachePayload["ElectricChargeNormalization"] ===
          electricChargeNormalization &&
        legacyCachePayload["AppliedHardKernelWeight"] === 1 &&
        legacyCachePayload["Projector"] === projector &&
        legacyCachePayload["SourceExpansionSHA256"] ===
          expansionCacheSHA256[projector] &&
        legacyCachePayload["RemainderTermCount"] === termCount &&
        Lookup[legacyCachePayload, "StandardTermIndices", $Failed] ===
          standardIndices &&
        Lookup[legacyCachePayload, "Alpha2TermIndices", $Failed] ===
          exceptionalIndices &&
        Lookup[legacyCachePayload, "SingularLogTermIndices", $Failed] ===
          {} &&
        Lookup[
          legacyCachePayload,
          "CompletedStandardTermCount",
          0
        ] === standardTermCount,
      projector <> " legacy endpoint cache is invalid."
    ];
    poles = Lookup[legacyCachePayload, "PoleCoefficients", {}];
    finite = Lookup[legacyCachePayload, "FiniteCoefficients", {}];
    flags = Lookup[legacyCachePayload, "RequiredPoleSubtraction", {}];
    methods = Lookup[legacyCachePayload, "Methods", {}];
    assert[
      ListQ[poles] && ListQ[finite] && ListQ[flags] && ListQ[methods] &&
        Length[poles] === Length[finite] === Length[flags] ===
          Length[methods] === standardTermCount,
      projector <> " legacy endpoint cache has incomplete coefficient lists."
    ];
    cachePayload = legacyCachePayload
  ];
  startIndex = Length[poles] + 1;
  remainingPositions = Range[startIndex, standardTermCount];
  While[Length[remainingPositions] > 0,
    endpointParallelWorkRequired = True;
    If[$KernelCount =!= requestedParallelKernels,
      ensureEndpointParallelKernels[
        projector <> " endpoint worker recovery"
      ]
    ];
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
    batchAnswers = Quiet@Check[
      ParallelMap[
        endpointWorkerEvaluate,
        batchInputs,
        Method -> "FinestGrained"
      ],
      $Failed
    ];
    If[batchAnswers === $Failed || ! ListQ[batchAnswers] ||
        Length[batchAnswers] =!= Length[batchInputs],
      Print[
        "S10_ENDPOINT_FALLBACK: parallel batch failed; evaluating " <>
          projector <> " positions " <>
          ToString[InputForm[batchPositions]] <> " serially"
      ];
      batchAnswers = endpointTermLaurent[
          #[[1]], #[[2]], #[[3]], #[[4]]
        ] & /@ batchInputs,
      Do[
        If[! AssociationQ[batchAnswers[[batchOffset]]],
          Print[
            "S10_ENDPOINT_FALLBACK: worker memory bound reached for " <>
              projector <> " position " <>
              ToString[batchPositions[[batchOffset]]] <>
              "; evaluating that term serially"
          ];
          batchAnswers[[batchOffset]] = endpointTermLaurent[
            batchInputs[[batchOffset, 1]],
            batchInputs[[batchOffset, 2]],
            batchInputs[[batchOffset, 3]],
            batchInputs[[batchOffset, 4]]
          ]
        ],
        {batchOffset, Length[batchAnswers]}
      ]
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
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "ElectricChargeNormalization" -> electricChargeNormalization,
      "AppliedHardKernelWeight" -> 1,
      "Projector" -> projector,
      "SourceExpansionCache" -> expansionCachePaths[projector],
      "SourceExpansionSHA256" -> expansionCacheSHA256[projector],
      "RemainderTermCount" -> termCount,
      "StandardTermIndices" -> standardIndices,
      "Alpha2TermIndices" -> exceptionalIndices,
      "Alpha2NestedRatioEndpoints" ->
        Lookup[alpha2Data, "NestedRatioEndpoint", {}],
      "DirectSubstitutionSingularLogTermIndices" -> logIndices,
      "CoupledLogEndpointRepairVersion" ->
        coupledEndpointRepairVersion,
      "CoupledLogEndpointGroups" -> groups,
      "CoupledLogEndpointRepairApplied" -> False,
      "PoleCoefficients" -> poles,
      "FiniteCoefficients" -> finite,
      "RequiredPoleSubtraction" -> flags,
      "Methods" -> methods,
      "CompletedStandardTermCount" -> position
    |>;
    writeAtomic[cachePayload, cachePath];
    Print[
      "S10_CACHE_CHECKPOINT: " <> projector <> " " <>
        ToString[position] <> "/" <> ToString[standardTermCount] <>
        " standard terms"
    ];
    remainingPositions = Drop[
      remainingPositions,
      Length[batchPositions]
    ];
    Clear[batchInputs, batchAnswers, termAnswer];
    If[$KernelCount > 0,
      Quiet[ParallelEvaluate[ClearSystemCache[]]]
    ];
    ClearSystemCache[];
  ];
  assert[Length[poles] === standardTermCount &&
      Length[finite] === standardTermCount,
    projector <> " endpoint cache does not cover every standard term."];

  repairCurrent = TrueQ[
    AssociationQ[cachePayload] &&
      Lookup[cachePayload, "CoupledLogEndpointRepairVersion", 0] ===
        coupledEndpointRepairVersion &&
      Lookup[cachePayload, "CoupledLogEndpointGroups", {}] === groups &&
      Lookup[cachePayload, "CoupledLogEndpointRepairApplied", False]
  ];
  If[! repairCurrent,
    repairResult = repairCoupledEndpointGroups[
      standardTerms, standardIndices, finite, methods, groups, label
    ];
    finite = repairResult["FiniteCoefficients"];
    methods = repairResult["Methods"];
    cachePayload = <|
      "CacheVersion" -> endpointCacheVersion,
      "StageVersion" -> stageVersion,
      "Channel" -> "Hqg only",
      "TensorRole" -> "RealQGEndpoint",
      "SourceS09" -> s09Path,
      "SourceS09SHA256" -> s09SHA256,
      "Program" -> programPath,
      "ProgramSHA256" -> programSHA256,
      "ElectricChargeNormalization" -> electricChargeNormalization,
      "AppliedHardKernelWeight" -> 1,
      "Projector" -> projector,
      "SourceExpansionCache" -> expansionCachePaths[projector],
      "SourceExpansionSHA256" -> expansionCacheSHA256[projector],
      "RemainderTermCount" -> termCount,
      "StandardTermIndices" -> standardIndices,
      "Alpha2TermIndices" -> exceptionalIndices,
      "Alpha2NestedRatioEndpoints" ->
        Lookup[alpha2Data, "NestedRatioEndpoint", {}],
      "DirectSubstitutionSingularLogTermIndices" -> logIndices,
      "CoupledLogEndpointRepairVersion" ->
        coupledEndpointRepairVersion,
      "CoupledLogEndpointGroups" -> groups,
      "CoupledLogEndpointRepairApplied" -> True,
      "PoleCoefficients" -> poles,
      "FiniteCoefficients" -> finite,
      "RequiredPoleSubtraction" -> flags,
      "Methods" -> methods,
      "CompletedStandardTermCount" -> standardTermCount
    |>;
    writeAtomic[cachePayload, cachePath];
    Print[
      "S10_COUPLED_ENDPOINT_SUCCESS: projector=", projector,
      " repairVersion=", coupledEndpointRepairVersion,
      " groups=", groups
    ]
  ];
  assert[
    TrueQ[cachePayload["CoupledLogEndpointRepairApplied"]] &&
      Count[methods, "physical-branch coupled group"] === Length[groups] &&
      Count[methods, "absorbed into physical-branch group"] ===
        Total[Length /@ groups] - Length[groups],
    projector <> " coupled endpoint repair metadata is incomplete."
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
  Print["S10_CHECKPOINT: completed symbolic distribution action for " <>
    projector];
  <|
    "Projector" -> projector,
    "RemainderTermCount" -> termCount,
    "StandardTermIndices" -> standardIndices,
    "Alpha2TermIndices" -> exceptionalIndices,
    "Alpha2NestedRatioEndpoints" ->
      Lookup[alpha2Data, "NestedRatioEndpoint", {}],
    "DirectSubstitutionSingularLogTermIndices" -> logIndices,
    "CoupledLogEndpointRepairVersion" -> coupledEndpointRepairVersion,
    "CoupledLogEndpointGroups" -> groups,
    "CoupledLogEndpointRepairApplied" -> True,
    "PoleSubtractionTermCount" -> Count[flags, True],
    "EndpointCache" -> cachePath,
    "EndpointCacheSHA256" -> FileHash[cachePath, "SHA256"],
    "ReducedStrongerPoleResidual" -> reducedPoleResidual,
    "StrongerPoleOrders" -> poleOrders,
    "EndpointValue" -> endpointValue,
    "Alpha2EndpointValue" -> alpha2EndpointValue,
    "Action" -> action,
    "MethodCounts" -> Counts[methods]
  |>
];

virtualLaurentCacheSHA256 = FileHash[laurentCachePath, "SHA256"];
paVeCacheSHA256 = FileHash[paVeCachePath, "SHA256"];
scalarMasterCacheSHA256 = FileHash[scalarMasterCachePath, "SHA256"];
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
assert[
  AllTrue[
    Values[virtualConvolutionActions],
    FreeQ[
      #,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator | dZGG1 | dZgs1 | _dZq1
    ] &
  ],
  "A virtual action retains an unresolved loop, regulator, or counterterm."
];
assert[
  AllTrue[
    Values[combinedConvolutionActions],
    FreeQ[#, _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]] &
  ],
  "A combined action retains an endpoint distribution placeholder."
];

s10Checks = <|
  "CurrentS09S08S07ProgramAndSourceBindingsVerified" -> True,
  "PaperReferenceHashPreserved" -> True,
  "BigTMDChannel3CaseAProjectorsPreserved" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "FragmentingGluonIsK1" -> True,
  "All97UniquePaVeFunctionsEvaluated" ->
    virtualIntegralBasis["PaVeCount"] === 97,
  "AllFourDirectScalarMastersEvaluated" ->
    Total[Lookup[virtualIntegralBasis, {"B0Count", "C0Count", "D0Count"}]] === 4,
  "PackageXAnalyticContinuationApplied" -> True,
  "SavedSymbolicCountertermsRemovedBeforeExplicitInsertion" -> True,
  "AggregateExternalLegCountertermInsertedExactlyOnce" -> True,
  "BareUVResidueMatchesLO" -> True,
  "ExplicitQCDCountertermsCancelUVPole" -> True,
  "VirtualDoublePoleMatchesUniversalIRFactor" -> True,
  "S09LONormalizationMatched" -> True,
  "VirtualLaurentExpandedThroughFiniteTerm" -> True,
  "EvaluatorToPaperConventionDeferredExactlyOnce" -> True,
  "HermitianProjectionDeferredUntilFiniteFactorizedEndpoint" -> True,
  "S09ExpansionCachesValidated" -> True,
  "ExactlyTwoS09EndpointPlaceholdersReceived" -> True,
  "BothProjectorsProcessed" -> True,
  "AllCurrentS09RemainderTermsResolved" ->
    AllTrue[
      Values[endpointDataByProjector],
      Length[# ["StandardTermIndices"]] +
          Length[# ["Alpha2TermIndices"]] ===
        # ["RemainderTermCount"] &
    ],
  "OneHqgAlpha2TermPerProjectorDetectedStructurally" ->
    AllTrue[
      Values[endpointDataByProjector[[All, "Alpha2TermIndices"]]],
      Length[#] === 1 &
    ],
  "AllDetectedAlpha2TermsHavePhysicalNestedRatio" ->
    AllTrue[
      Flatten[Values[
        endpointDataByProjector[[All, "Alpha2NestedRatioEndpoints"]]
      ]],
      TrueQ[Cancel[Together[# - zH^2/PHT2]] === 0] &
    ],
  "DirectEndpointLogScanHasNoAdditionalGroups" ->
    AllTrue[
      Values[
        endpointDataByProjector[[
          All,
          "DirectSubstitutionSingularLogTermIndices"
        ]]
      ],
      # === {} &
    ],
  "PhysicalBranchCoupledEndpointRepairApplied" ->
    AllTrue[
      projectors,
      Function[projector,
        endpointDataByProjector[
          projector,
          "CoupledLogEndpointRepairVersion"
        ] === coupledEndpointRepairVersion &&
          endpointDataByProjector[
            projector,
            "CoupledLogEndpointGroups"
          ] === coupledEndpointGroups[projector] &&
          TrueQ[endpointDataByProjector[
            projector,
            "CoupledLogEndpointRepairApplied"
          ]]
      ]
    ],
  "StrongerEndpointPoleAbsentThroughFiniteRequirement" ->
    AllTrue[
      Flatten[
        Values /@ Values[
          endpointDataByProjector[[All, "StrongerPoleOrders"]]
        ]
      ],
      TrueQ[# === 0] &
    ],
  "UnitHqgHardKernelWeightRetained" -> hardKernelWeight === 1,
  "EndpointValuesAreS23Independent" ->
    AllTrue[
      Join[
        Values[endpointDataByProjector[[All, "EndpointValue"]]],
        Values[endpointDataByProjector[[All, "Alpha2EndpointValue"]]]
      ],
      FreeQ[#, s23] &
    ],
  "DiracDeltaActedOnSymbolicTestFunction" -> True,
  "AllPlusDistributionsActedOnSymbolicTestFunction" -> True,
  "FinalActionsContainNoDistributionPlaceholders" ->
    AllTrue[Values[combinedConvolutionActions],
      FreeQ[
        #,
        _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
      ] &],
  "VirtualActionsContainNoUnresolvedLoopObjects" -> True,
  "RealVirtualSymbolicActionsFormed" -> True,
  "EndpointWorkersUsedOnlyWhenRawTermsRequired" ->
    If[
      endpointParallelWorkRequired,
      Length[parallelKernelIDsSeen] === requestedParallelKernels &&
        DuplicateFreeQ[parallelKernelIDsSeen],
      parallelKernelIDsSeen === {}
    ],
  "AllEndpointWorkersClosedBeforeFinalVirtualAssembly" ->
    $KernelCount === 0,
  "ParentOnlyAtomicEndpointCheckpointWrites" -> True,
  "AllCachesBoundToCurrentSourcesAndProgram" -> True,
  "PhysicalBigTMDLuminosityDeferred" -> True,
  "CalculationRemainsFullySymbolic" -> True,
  "CollinearFactorizationNotApplied" -> True
|>;
assert[AllTrue[Values[s10Checks], TrueQ],
  "At least one final S10 validation check is not True."];

s10Result = <|
  "Status" -> "CompleteSymbolic",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg;qg real endpoint action plus UV-renormalized symbolic virtual action",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s09Path,
  "SourceResultSHA256" -> s09SHA256,
  "SourceS08" -> s08Path,
  "SourceS08SHA256" -> s08SHA256,
  "SourceS07" -> s07Path,
  "SourceS07SHA256" -> s07SHA256,
  "ReferencePDFSHA256" -> referencePDFSHA256,
  "BigTMDConvention" -> bigTMDConvention,
  "BigTMDProjectorMapping" -> bigTMDProjectorMapping,
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "FragmentingParton" -> fragmentingParton,
  "CalculationMode" ->
    "fully analytic and symbolic; no numerical kinematics, PDFs, FFs, or concrete test function",
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlaceholderCountAfter" -> 0,
    "Method" ->
      "corrected Hqg factorwise endpoint Laurent extraction for structurally ordinary alpha=1 terms; proven root-coupled terms are resolved separately on both physical square-root signs before grouping; every Hqg-detected base^(-1-epsilon) with base/s23 finite is refactored into the alpha=2 delta coefficient and doubled logarithmic tower",
    "EndpointDataByProjector" -> endpointDataByProjector
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
    "RealByProjector" -> realConvolutionActions,
    "VirtualByProjector" -> virtualConvolutionActions,
    "RealPlusVirtualByProjector" -> combinedConvolutionActions,
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
    "VirtualCaches" -> <|
      "PaVe" -> paVeCachePath,
      "ScalarMasters" -> scalarMasterCachePath,
      "Laurent" -> laurentCachePath
    |>,
    "SourceExpansionCaches" -> expansionCachePaths,
    "SourceExpansionSHA256" -> expansionCacheSHA256,
    "EndpointCaches" -> endpointCachePaths,
    "AllCachesSourceBound" -> True
  |>,
  "ParallelExecution" -> <|
    "RequestedEndpointWorkerCount" -> requestedParallelKernels,
    "RawEndpointParallelWorkRequired" -> endpointParallelWorkRequired,
    "ValidatedKernelIDsSeen" -> parallelKernelIDsSeen,
    "KernelExecutable" -> parallelKernelExecutable,
    "PerWorkerMemoryLimitBytes" -> endpointWorkerMemoryLimitBytes,
    "MemoryAvailableAtPlannerBytes" -> availableMemoryAtLaunch,
    "MemoryReserveBytes" -> parallelMemoryReserveBytes,
    "ParallelizedWork" ->
      If[
        endpointParallelWorkRequired,
        "independent uncached standard endpoint Laurent terms in deterministic memory-admitted batches of up to the requested worker count",
        "none: every standard per-term coefficient was present in the validated migration input; physical-branch group repair is intrinsically serial"
      ],
    "CheckpointWriter" -> "parent kernel only, atomically after each batch",
    "Fallback" ->
      "a failed or memory-bounded worker result is recomputed serially before checkpointing",
    "VirtualAlgebraMode" ->
      "serial bounded reconstruction; no large virtual expression is copied to a worker"
  |>,
  "MemoryStrategy" ->
    "evaluate/checkpoint Package-X and bounded virtual Laurent work serially; release completed virtual expressions; launch two to eight 1.25-GiB bounded workers lazily only for missing real endpoint terms; apply physical-branch group repair serially; close any workers; reload only the validated Laurent cache for final actions",
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

Print["S10_STAGE: writing " <> resultPath];
writeAtomic[s10Result, resultPath];
Print["S10_SUCCESS_SYMBOLIC"];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CHECKS=", InputForm[s10Checks]];

Quit[0];

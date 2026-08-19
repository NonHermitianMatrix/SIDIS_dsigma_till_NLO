(* ::Package:: *)

(*
  Hqqprime stage S09: expand every Eq. (B19) master retained by the accepted
  S08 physical Pg/PPP and charge-resolved angular branches, apply the accepted
  exact xi,s23 change of variables, and record the formal bounded endpoint-
  distribution handoff.

  Physics sources: Appendix B Eqs. (B18), (B19), (B21)-(B31) and Appendix F
  Eqs. (F1)-(F29) of the authoritative paper. This stage does not resolve
  endpoint coefficients, apply factorization, take epsilon -> 0, combine
  projectors or charge tensors, assemble physical flavours, extract F-hats,
  perform an external comparison, or create/launch S10.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, workerRequire, closeS09Kernels, fileSHA256,
  expressionSHA256, mapAssociationValues, mapNestedAssociationValues,
  allBranchValues, atomicPutAssociation, hasExactlyExpectedScaleQ,
  appendixFExpansion, appendixFZeroJ, expandOneMaster,
  expandAppendixFMasters, expandCase1Functions, toRecurrenceBasis,
  recurrenceResidual, b19F8MomentResiduals, expandedKernelValidQ,
  validateExpandedKernel, cacheMetadataValidQ, loadValidatedCache,
  processBranchCore, processChargeTask, launchS09Kernels,
  runOrderedChargeTasks, formalEndpointDistribution,
  S08Case2Master, S09EndpointValue, S09PlusDistribution,
  S09RegularEndpointFunction, S09ExpandedKernelReference,
  S09K, S09A, S09B
];

activeTemporaryPath = "";
workerVersions = {};
parallelOrderProbe = {};

closeS09Kernels[] := Module[{},
  If[Length[Kernels[]] > 0, Quiet[CloseKernels[]]];
];

fatal[message_String] := (
  closeS09Kernels[];
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

workerRequire[condition_, message_String] :=
  If[! TrueQ[condition], Throw[message, "S09WorkerFailure"]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

mapAssociationValues[function_, association_Association] :=
  Map[function, association];

mapNestedAssociationValues[function_, association_Association] :=
  Map[Map[function, #] &, association];

allBranchValues[association_Association] :=
  Flatten[Map[Values, Values[association]], 1];

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
  "Nested Association value mapping lost projector/charge keys or values."
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
    "Atomic temporary reload failed status/stage validation for " <>
      finalPath
  ];
  renameResult = Quiet @ Check[
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

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s07SourcePath = FileNameJoin[{
  scriptDirectory, "s07_contract_hqqprime_projectors.wl"
}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
s08SourcePath = FileNameJoin[{
  scriptDirectory, "s08_phase_space_integrate_hqqprime.wl"
}];
s08ResultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s09_result"}];

stageVersion = "HqqprimeS09-v1";
cacheStageVersion = "HqqprimeS09Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S09_PREFLIGHT_ONLY"], ""] === "1";
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 3 2^30;
projectorKeys = {"Pg", "PPP"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
dimensionalScaleFactor = FeynCalc`ScaleMu^(4 epsilon);
additionalMultiplicativeWeight = Times @@ {1};

s08CachePaths = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_incoming_charge_squared_pg"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_prime_charge_squared_pg"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_mixed_incoming_prime_charge_pg"
    }]
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_incoming_charge_squared_ppp"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_prime_charge_squared_ppp"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_mixed_incoming_prime_charge_ppp"
    }]
  |>
|>;

cachePaths = <|
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

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS07SourceHash =
  "4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7";
expectedS07ResultHash =
  "b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026";
expectedS08SourceHash =
  "dbbc23d05697f4e45c23471be8f3ed12448d8db0d973e60d67cdebbcabec8ed4";
expectedS08ResultHash =
  "4916b943c1bbc7b1aeeb91d5fa022d00b5341166fc805b95e21e8ee4f99bb246";
expectedS08CacheHashes = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "855101208854c720385e89785464f77cfe71a947728fd6b6d022f95130d0f781",
    "PrimeChargeSquared" ->
      "5c3ead313a0e228174fa5c334d9144d8ce04bad5ec33dfb7d7170b3589d83c28",
    "MixedIncomingPrimeCharge" ->
      "f9ac39e5b22e1484ec012a17609bf0b5e00a54d3a153705d669ba8a29b63caaa"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "7518ed803aa4dd136405665f9a6c294f7c5b9056f3e911ea63e85a21e1b1e70c",
    "PrimeChargeSquared" ->
      "bf567c8652ba861dd029abf20bf74ebf992cc7d91aa93c440ae6058fd4ebba43",
    "MixedIncomingPrimeCharge" ->
      "e8e3de995b764e528495be129c99ff52b66f6207ca016db139a62d849366e491"
  |>
|>;

programHash = fileSHA256[programPath];
preflightArtifactSnapshot = Sort@FileNames["s09_*", scriptDirectory];
staleTemporaryPaths = Join[
  FileNames["s09_result.tmp.*", scriptDirectory],
  FileNames["s09_cache_hqqprime*.tmp.*", scriptDirectory]
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

Print["S09_STAGE: validating the paper and accepted Hqqprime S07/S08 handoff"];
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
    "S08 result" -> {s08ResultPath, expectedS08ResultHash}
  |>
];
Do[
  assert[
    FileExistsQ[s08CachePaths[projectorName][chargeKey]],
    "Accepted S08 cache is missing for " <> projectorName <> " " <> chargeKey
  ];
  assert[
    fileSHA256[s08CachePaths[projectorName][chargeKey]] ===
      expectedS08CacheHashes[projectorName][chargeKey],
    "Accepted S08 cache hash changed for " <> projectorName <> " " <> chargeKey
  ],
  {projectorName, projectorKeys},
  {chargeKey, chargeKeys}
];

s08 = Quiet @ Check[Get[s08ResultPath], $Failed];
assert[AssociationQ[s08], "s08_result is not an Association."];
assert[
  s08["Status"] === "Complete" &&
    s08["Stage"] === "HqqprimeS08-v1" &&
    s08["ResultSchemaVersion"] === 1 &&
    s08["Channel"] === "Hqqprime only" &&
    s08["Contribution"] ===
      "H_{q qPrime; q qbarPrime} charge-resolved three-body angular-integrated Pg/PPP kernels" &&
    s08["ProgramSHA256"] === expectedS08SourceHash &&
    s08["PaperReference"]["SHA256"] === expectedPaperHash,
  "s08_result failed status, schema, channel, contribution, program, or paper validation."
];
assert[
  Length[s08["Checks"]] === 38 &&
    And @@ (TrueQ /@ Values[s08["Checks"]]),
  "The accepted S08 result does not contain exactly 38 true checks."
];
assert[
  s08["Input"]["S07SourceSHA256"] === expectedS07SourceHash &&
    s08["Input"]["S07ResultSHA256"] === expectedS07ResultHash,
  "The S08 result lost its accepted S07 source/result binding."
];
assert[
  s08["ProjectorOrder"] === projectorKeys &&
    s08["ChargeKeyOrder"] === chargeKeys,
  "The accepted projector or charge order changed."
];
assert[
  s08["CacheProvenance"]["StageVersion"] === "HqqprimeS08Cache-v1" &&
    s08["CacheProvenance"]["ProgramSHA256"] === expectedS08SourceHash &&
    s08["CacheProvenance"]["PaperSHA256"] === expectedPaperHash &&
    s08["CacheProvenance"]["S07SourceSHA256"] === expectedS07SourceHash &&
    s08["CacheProvenance"]["S07ResultSHA256"] === expectedS07ResultHash &&
    s08["CacheProvenance"]["Paths"] === s08CachePaths &&
    s08["CacheProvenance"]["SHA256"] === expectedS08CacheHashes &&
    s08["CacheProvenance"]["AtomicAndMainKernelOnly"] === True,
  "The S08 cache-provenance handoff is incomplete or stale."
];

physicalAngular =
  s08["ThreeBodyAngularIntegrated"]["NLOReal_OAlphaS2"]["Hqqprime;q_qbarPrime"];
acceptedXiS23 =
  s08["XiS23ConvolutionKernels"]["ThreeBodyReal"]["NLOReal_OAlphaS2"]["Hqqprime;q_qbarPrime"];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicToXiS23Rules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["JacobianDerivedByWolfram"];
paperEq29Jacobian = changeOfVariables["PaperEq29Jacobian"];
s23UpperB = changeOfVariables["S23UpperB"];
scaleBookkeeping = s08["ScaleBookkeeping"];
chargeBookkeeping = s08["ChargeBookkeeping"];
symmetryBookkeeping = s08["SymmetryBookkeeping"];
virtualBookkeeping = s08["VirtualContributionAtThisOrder"];

assert[
  AssociationQ[physicalAngular] &&
    Keys[physicalAngular] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[physicalAngular]) &&
    AssociationQ[acceptedXiS23] &&
    Keys[acceptedXiS23] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[acceptedXiS23]),
  "S08 does not contain exactly the ordered six angular and mapped branches."
];
assert[
  ListQ[partonicToXiS23Rules] &&
    Length[partonicToXiS23Rules] === 4 &&
    ! MissingQ[xiS23Jacobian] && ! MissingQ[paperEq29Jacobian] &&
    ! MissingQ[s23UpperB] &&
    Together[xiS23Jacobian - paperEq29Jacobian] === 0 &&
    And @@ (TrueQ /@ Values[changeOfVariables["Checks"]]) &&
    changeOfVariables["RemainingXiS23ConvolutionPerformed"] === False,
  "The accepted exact xi,s23 transformation is incomplete."
];
assert[
  scaleBookkeeping === <|
    "AbsoluteFactor" -> dimensionalScaleFactor,
    "AbsoluteExponent" -> 4 epsilon,
    "PowerPreservedExactlyOnceInEveryProjection" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "The accepted one-scale/no-extra-MS-bar ledger changed."
];
assert[
  chargeBookkeeping === <|
    "SeparatedTensorKeys" -> chargeKeys,
    "GenericChargeSymbols" -> {S01Qq, S01QqPrime},
    "CoefficientTensorsRemainChargeFree" -> True,
    "PhysicalOrderedFlavorSumAppliedAtS06" -> False,
    "PhysicalAssemblyInstruction" ->
      "Sum over ordered q,qPrime with qPrime different from q while retaining Qq^2, QqPrime^2, and Qq QqPrime tensors separately; do not replace by a bare Nf or Nf-1 factor."
  |>,
  "The accepted three-charge/ordered-flavour ledger changed."
];
speciesMultiplicities = symmetryBookkeeping["SpeciesMultiplicities"];
derivedFinalStateSymmetryFactor =
  1/Times @@ (Factorial /@ Values[speciesMultiplicities]);
assert[
  symmetryBookkeeping["DistinctFinalStateIdentities"] ===
      {"qPrime(k1)", "q(k2)", "qbarPrime(k3)"} &&
    speciesMultiplicities === <|
      "qPrime" -> 1, "q" -> 1, "qbarPrime" -> 1
    |> &&
    derivedFinalStateSymmetryFactor ===
      symmetryBookkeeping["FactorDerivedFromSpeciesMultiplicities"] &&
    derivedFinalStateSymmetryFactor ===
      symmetryBookkeeping["FinalStateSymmetryFactor"] &&
    symmetryBookkeeping["NontrivialSymmetryFactorRequired"] === False &&
    symmetryBookkeeping["NontrivialSymmetryFactorAppliedAtS08"] === False &&
    symmetryBookkeeping["PhysicalExpressionEqualsPreSymmetryExpression"] ===
      True &&
    symmetryBookkeeping["NoDownstreamNontrivialSymmetryFactorRemains"] ===
      True,
  "The tool-derived distinct-final-state symmetry ledger changed."
];
assert[
  virtualBookkeeping["Applicable"] === False &&
    virtualBookkeeping["Interference"] === 0 &&
    virtualBookkeeping["SourceDisposition"] ===
      "NotApplicableAtThisOrder",
  "A forbidden virtual branch appeared in the S08 handoff."
];

Do[
  acceptedS08Cache =
    Quiet @ Check[Get[s08CachePaths[projectorName][chargeKey]], $Failed];
  assert[
    AssociationQ[acceptedS08Cache] &&
      acceptedS08Cache["Status"] === "Complete" &&
      acceptedS08Cache["Stage"] === "HqqprimeS08Cache-v1" &&
      acceptedS08Cache["Channel"] === "Hqqprime only" &&
      acceptedS08Cache["Projector"] === projectorName &&
      acceptedS08Cache["ChargeKey"] === chargeKey &&
      acceptedS08Cache["ProgramSHA256"] === expectedS08SourceHash &&
      acceptedS08Cache["PaperSHA256"] === expectedPaperHash &&
      acceptedS08Cache["S07SourceSHA256"] === expectedS07SourceHash &&
      acceptedS08Cache["S07ResultSHA256"] === expectedS07ResultHash &&
      acceptedS08Cache["ScaleBookkeeping"] === scaleBookkeeping &&
      acceptedS08Cache["ChargeBookkeeping"] === chargeBookkeeping &&
      acceptedS08Cache["VirtualContributionAtThisOrder"] ===
        virtualBookkeeping &&
      acceptedS08Cache["FinalStateSymmetryFactor"] ===
        derivedFinalStateSymmetryFactor &&
      acceptedS08Cache["NontrivialSymmetryFactorAppliedAtS08"] === False &&
      acceptedS08Cache["AngularRecordSHA256"] ===
        expressionSHA256[acceptedS08Cache["AngularRecord"]] &&
      acceptedS08Cache["AngularRecord"]["PhysicalAfterFinalStateSymmetryFactor"] ===
          physicalAngular[projectorName][chargeKey],
    "Accepted S08 cache failed exact payload validation for " <>
      projectorName <> " " <> chargeKey
  ];
  Clear[acceptedS08Cache],
  {projectorName, projectorKeys},
  {chargeKey, chargeKeys}
];

hasExactlyExpectedScaleQ[expression_] := Module[{contains, stripped},
  contains = ! FreeQ[
    expression,
    candidate_ /; SameQ[candidate, dimensionalScaleFactor]
  ];
  stripped = expression /.
    (candidate_ /; SameQ[candidate, dimensionalScaleFactor]) :> 1;
  contains && FreeQ[stripped, FeynCalc`ScaleMu]
];

assert[
  AllTrue[allBranchValues[physicalAngular], hasExactlyExpectedScaleQ] &&
    AllTrue[allBranchValues[acceptedXiS23], hasExactlyExpectedScaleQ],
  "An S08 branch lost the exact single scale factor."
];

xiMapReconstructionChecks = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> SameQ[
      acceptedXiS23[projectorName][chargeKey],
      xiS23Jacobian *
        (physicalAngular[projectorName][chargeKey] /.
          partonicToXiS23Rules)
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];
assert[
  And @@ (TrueQ /@ allBranchValues[xiMapReconstructionChecks]),
  "An accepted S08 xi,s23 branch does not reconstruct from its angular input."
];

masterOccurrencesByBranch = mapNestedAssociationValues[
  Cases[#, _S08Case2Master, Infinity] &,
  physicalAngular
];
actualPairsByBranch = mapNestedAssociationValues[
  Sort@DeleteDuplicates@Map[
    Function[master, {master[[1]], master[[2]]}],
    #
  ] &,
  masterOccurrencesByBranch
];
masterOccurrenceCounts = mapNestedAssociationValues[
  Length,
  masterOccurrencesByBranch
];
distinctMasterInstancesByBranch = mapNestedAssociationValues[
  DeleteDuplicates,
  masterOccurrencesByBranch
];
distinctMasterInstanceCounts = mapNestedAssociationValues[
  Length,
  distinctMasterInstancesByBranch
];
allMasterOccurrences =
  Join @@ Flatten[Map[Values, Values[masterOccurrencesByBranch]], 1];

expectedPairsByBranch = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> Sort@{
      {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {0, 2},
      {1, -1}, {1, 0}, {1, 1}, {1, 2},
      {2, -1}, {2, 0}, {2, 1}, {2, 2}
    },
    "PrimeChargeSquared" -> Sort@{
      {-1, 1}, {-1, 2}, {0, 1}, {0, 2},
      {1, -1}, {1, 0}, {1, 1}, {1, 2},
      {2, 0}, {2, 1}, {2, 2}
    },
    "MixedIncomingPrimeCharge" -> Sort@{
      {-1, 0}, {-1, 1}, {0, -1}, {0, 1},
      {1, -2}, {1, -1}, {1, 0}, {1, 1}
    }
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> Sort@{
      {-1, 1}, {0, 1}, {1, -1}, {1, 0}, {1, 1},
      {2, -2}, {2, -1}, {2, 0}, {2, 1}
    },
    "PrimeChargeSquared" -> Sort@{
      {0, 1}, {0, 2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
      {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
    },
    "MixedIncomingPrimeCharge" -> Sort@{
      {-2, 0}, {-2, 1}, {-1, -1}, {-1, 0}, {-1, 1},
      {0, -2}, {0, -1}, {0, 1},
      {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}
    }
  |>
|>;
expectedMasterOccurrenceCounts = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> 16,
    "PrimeChargeSquared" -> 12,
    "MixedIncomingPrimeCharge" -> 24
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> 9,
    "PrimeChargeSquared" -> 11,
    "MixedIncomingPrimeCharge" -> 26
  |>
|>;
expectedAllPairs = Sort@{
  {-2, 0}, {-2, 1},
  {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {0, -2}, {0, -1}, {0, 1}, {0, 2},
  {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};
actualAllPairs = Sort@DeleteDuplicates@Map[
  Function[master, {master[[1]], master[[2]]}],
  allMasterOccurrences
];

assert[
  actualPairsByBranch === expectedPairsByBranch,
  "The exact per-projector/per-charge S08 B19 class inventory changed."
];
assert[
  masterOccurrenceCounts === expectedMasterOccurrenceCounts &&
    distinctMasterInstanceCounts === expectedMasterOccurrenceCounts &&
    Length[allMasterOccurrences] === 98 &&
    Length[DeleteDuplicates[allMasterOccurrences]] === 47 &&
    actualAllPairs === expectedAllPairs &&
    AllTrue[allMasterOccurrences, Length[#] === 5 &],
  "The accepted 21-class/98-occurrence/47-instance master inventory changed."
];

inputExpressionHashes = mapNestedAssociationValues[
  expressionSHA256,
  physicalAngular
];

Print["S09_MASTER_PAIRS=", InputForm[actualAllPairs]];
Print["S09_MASTER_OCCURRENCES=", InputForm[masterOccurrenceCounts]];
Print[
  "S09_DISTINCT_MASTER_INSTANCES=",
  InputForm[distinctMasterInstanceCounts]
];

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

hypergeometricSignaturesByBranch = mapNestedAssociationValues[
  Sort@DeleteDuplicates@Cases[
    #,
    Hypergeometric2F1[a_, b_, cc_, w_] :> HoldComplete[a, b, cc],
    Infinity
  ] &,
  physicalAngular
];
hypergeometricCountsByBranch = mapNestedAssociationValues[
  Count[#, _Hypergeometric2F1, Infinity] &,
  physicalAngular
];
betaObjects = Sort@DeleteDuplicates@Cases[
  allBranchValues[physicalAngular],
  _Beta,
  Infinity
];
betaSignatures = betaObjects /. Beta[a_, b_] :> HoldComplete[a, b];
gammaObjects = Sort@DeleteDuplicates@Cases[
  allBranchValues[physicalAngular],
  _Gamma,
  Infinity
];

expectedHypergeometricSignaturesByBranch = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> {},
    "PrimeChargeSquared" -> {},
    "MixedIncomingPrimeCharge" ->
      {HoldComplete[1, 1, 1 - epsilon]}
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> {},
    "PrimeChargeSquared" -> {},
    "MixedIncomingPrimeCharge" ->
      {HoldComplete[1, 1, 1 - epsilon]}
  |>
|>;
expectedHypergeometricCountsByBranch = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> 0,
    "PrimeChargeSquared" -> 0,
    "MixedIncomingPrimeCharge" -> 1
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> 0,
    "PrimeChargeSquared" -> 0,
    "MixedIncomingPrimeCharge" -> 1
  |>
|>;

Print[
  "S09_B27_SIGNATURES=",
  InputForm[hypergeometricSignaturesByBranch]
];
Print[
  "S09_B27_COUNTS=",
  InputForm[hypergeometricCountsByBranch]
];
Print["S09_B18_BETA_SIGNATURES=", InputForm[betaSignatures]];
Print["S09_B18_GAMMA_OBJECTS=", InputForm[gammaObjects]];

assert[
  hypergeometricSignaturesByBranch ===
      expectedHypergeometricSignaturesByBranch &&
    hypergeometricCountsByBranch === expectedHypergeometricCountsByBranch &&
    Total[allBranchValues[hypergeometricCountsByBranch]] === 2,
  "The exact six-branch residual B27 hypergeometric inventory changed."
];
assert[
  Sort[betaSignatures] === Sort@{
    HoldComplete[1 - epsilon, 1 - epsilon],
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

masterMapCommutationChecks = mapNestedAssociationValues[
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
  distinctMasterInstancesByBranch
];
assert[
  And @@ (TrueQ /@ allBranchValues[masterMapCommutationChecks]),
  "Appendix-F substitution does not commute with the exact map in a branch."
];

case1ObjectsByBranch = mapNestedAssociationValues[
  Function[expression,
    DeleteDuplicates@Join[
      Cases[expression, _Hypergeometric2F1, Infinity],
      Cases[expression, _Beta, Infinity],
      Cases[expression, _Gamma, Infinity]
    ]
  ],
  physicalAngular
];
case1MapCommutationChecks = mapNestedAssociationValues[
  Function[objects,
    And @@ Map[
      Function[object,
        SameQ[
          expandCase1Functions[object] /. partonicToXiS23Rules,
          expandCase1Functions[object /. partonicToXiS23Rules]
        ]
      ],
      objects
    ]
  ],
  case1ObjectsByBranch
];
assert[
  And @@ (TrueQ /@ allBranchValues[case1MapCommutationChecks]),
  "B18/B27 substitution does not commute with the exact map in a branch."
];

expandedKernelValidQ[expression_] :=
  expression =!= 0 && expression =!= $Failed &&
    FreeQ[
      expression,
      _S08Case2Master | _Hypergeometric2F1 | _Beta | _Gamma |
        _FeynCalc`FeynAmpDenominator | _Real | Indeterminate |
        _SeriesData | $Failed | $Aborted | ComplexInfinity |
        DirectedInfinity | _Inactive |
        S01Qq | S01QqPrime
    ] &&
    FreeQ[
      expression,
      sHat | t1 | t2 | t3 | tHat | u1 | u2 | u3 | s12 | s13 |
        zeta | zHat | beta1 | beta2
    ] &&
    hasExactlyExpectedScaleQ[expression];

validateExpandedKernel[
    expression_, projectorName_String, chargeKey_String
  ] := Module[{},
  assert[
    expandedKernelValidQ[expression],
    projectorName <> " " <> chargeKey <>
      " expanded kernel failed exact symbolic/map/scale validation."
  ];
  True
];

cacheMetadataValidQ[
    cache_, projectorName_String, chargeKey_String
  ] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "ResultSchemaVersion", Missing["Schema"]] ===
      resultSchemaVersion &&
    Lookup[cache, "Channel", Missing["Channel"]] === "Hqqprime only" &&
    Lookup[cache, "Projector", Missing["Projector"]] === projectorName &&
    Lookup[cache, "ChargeKey", Missing["ChargeKey"]] === chargeKey &&
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
    Lookup[cache, "S08CachePath", Missing["S08CachePath"]] ===
      s08CachePaths[projectorName][chargeKey] &&
    Lookup[cache, "S08CacheSHA256", Missing["S08Cache"]] ===
      expectedS08CacheHashes[projectorName][chargeKey] &&
    Lookup[cache, "InputKey", Missing["InputKey"]] ===
      "ThreeBodyAngularIntegrated/NLOReal_OAlphaS2/" <>
        "Hqqprime;q_qbarPrime/" <> projectorName <> "/" <> chargeKey &&
    Lookup[cache, "InputExpressionSHA256", Missing["InputHash"]] ===
      inputExpressionHashes[projectorName][chargeKey] &&
    Lookup[cache, "AllMasterPairs", Missing["AllPairs"]] ===
      expectedAllPairs &&
    Lookup[cache, "BranchMasterPairs", Missing["Pairs"]] ===
      expectedPairsByBranch[projectorName][chargeKey] &&
    Lookup[cache, "MasterOccurrenceCount", Missing["Occurrences"]] ===
      masterOccurrenceCounts[projectorName][chargeKey] &&
    Lookup[cache, "DistinctMasterInstanceCount", Missing["Instances"]] ===
      distinctMasterInstanceCounts[projectorName][chargeKey] &&
    Lookup[cache, "ResidualB27Signatures", Missing["B27Signatures"]] ===
      hypergeometricSignaturesByBranch[projectorName][chargeKey] &&
    Lookup[cache, "ResidualB27OccurrenceCount", Missing["B27Count"]] ===
      hypergeometricCountsByBranch[projectorName][chargeKey] &&
    Lookup[cache, "ExpansionOrders", Missing["ExpansionOrders"]] === <|
      "NonzeroJExceptF28F29" -> "through epsilon^1",
      "F28F29" -> "through epsilon^0",
      "B18ZeroJ" -> "through epsilon^2",
      "B27" -> "through epsilon^2"
    |> &&
    Lookup[
      cache,
      "ResidualExpansionInventory",
      Missing["ResidualExpansionInventory"]
    ] === <|
      "Case2MasterCount" -> 0,
      "HypergeometricCount" -> 0,
      "BetaCount" -> 0,
      "GammaCount" -> 0,
      "FailedCount" -> 0,
      "MachineRealCount" -> 0
    |> &&
    Lookup[
      cache,
      "IndividualGammaSeriesRatioRegressionPassed",
      Missing["GammaRegression"]
    ] === True &&
    Lookup[
      cache,
      "XiS23MapAppliedAfterMasterExpansion",
      Missing["XiS23Map"]
    ] === True &&
    Lookup[
      cache,
      "MasterAndCase1MapCommutationVerified",
      Missing["MapCommutation"]
    ] === True &&
    Lookup[cache, "AdditionalMultiplicativeWeight", Missing["Weight"]] ===
      additionalMultiplicativeWeight &&
    Lookup[cache, "ScaleBookkeeping", Missing["Scale"]] ===
      scaleBookkeeping &&
    Lookup[cache, "ChargeBookkeeping", Missing["Charge"]] ===
      chargeBookkeeping &&
    Lookup[cache, "SymmetryBookkeeping", Missing["Symmetry"]] ===
      symmetryBookkeeping &&
    Lookup[cache, "FinalStateSymmetryFactor", Missing["Factor"]] ===
      derivedFinalStateSymmetryFactor &&
    Lookup[cache, "VirtualContributionAtThisOrder", Missing["Virtual"]] ===
      virtualBookkeeping &&
    IntegerQ[Lookup[cache, "ExpandedLeafCount", Missing["Leaves"]]] &&
    Lookup[cache, "ExpandedLeafCount", 0] > 0 &&
    IntegerQ[Lookup[cache, "ExpandedByteCount", Missing["Bytes"]]] &&
    Lookup[cache, "ExpandedByteCount", 0] > 0 &&
    StringMatchQ[
      Lookup[cache, "ExpressionSHA256", ""],
      RegularExpression["[0-9a-f]{64}"]
    ] &&
    KeyExistsQ[cache, "Expression"];

loadValidatedCache[
    projectorName_String, chargeKey_String
  ] := Module[{path, cache},
  If[preflightOnly, Return[Missing["PreflightBypass"]]];
  path = cachePaths[projectorName][chargeKey];
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print[
    "S09_STAGE: validating existing cache for ",
    projectorName, " ", chargeKey
  ];
  cache = Quiet @ Check[Get[path], $Failed];
  assert[
    cacheMetadataValidQ[cache, projectorName, chargeKey],
    "Existing S09 cache is stale or invalid for " <>
      projectorName <> " " <> chargeKey <>
      "; it was not silently reused or deleted."
  ];
  assert[
    cache["ExpressionSHA256"] === expressionSHA256[cache["Expression"]] &&
      cache["ExpandedLeafCount"] === LeafCount[cache["Expression"]] &&
      cache["ExpandedByteCount"] === ByteCount[cache["Expression"]] &&
      validateExpandedKernel[
        cache["Expression"], projectorName, chargeKey
      ],
    "Existing S09 cache expression failed exact validation for " <>
      projectorName <> " " <> chargeKey
  ];
  cache
];

processBranchCore[
    input_, projectorName_String, chargeKey_String, mapRules_List,
    jacobian_
  ] := Module[
  {expandedAngular, residualExpansionInventory, expandedXiS23},
  expandedAngular = Quiet @ Check[
    MemoryConstrained[
      expandCase1Functions[expandAppendixFMasters[input]],
      workerMemoryBudgetBytes,
      $Aborted
    ],
    $Failed
  ];
  workerRequire[
    expandedAngular =!= $Failed && expandedAngular =!= $Aborted,
    projectorName <> " " <> chargeKey <>
      " angular-master expansion failed or exceeded worker memory"
  ];
  residualExpansionInventory = <|
    "Case2MasterCount" ->
      Count[expandedAngular, _S08Case2Master, Infinity],
    "HypergeometricCount" ->
      Count[expandedAngular, _Hypergeometric2F1, Infinity],
    "BetaCount" -> Count[expandedAngular, _Beta, Infinity],
    "GammaCount" -> Count[expandedAngular, _Gamma, Infinity],
    "FailedCount" -> Count[expandedAngular, $Failed, Infinity],
    "MachineRealCount" -> Count[expandedAngular, _Real, Infinity]
  |>;
  workerRequire[
    residualExpansionInventory === <|
      "Case2MasterCount" -> 0,
      "HypergeometricCount" -> 0,
      "BetaCount" -> 0,
      "GammaCount" -> 0,
      "FailedCount" -> 0,
      "MachineRealCount" -> 0
    |>,
    projectorName <> " " <> chargeKey <>
      " angular-master expansion retained a forbidden object"
  ];
  expandedXiS23 = Quiet @ Check[
    MemoryConstrained[
      jacobian * (expandedAngular /. mapRules),
      workerMemoryBudgetBytes,
      $Aborted
    ],
    $Failed
  ];
  Clear[expandedAngular];
  workerRequire[
    expandedXiS23 =!= $Failed && expandedXiS23 =!= $Aborted &&
      expandedKernelValidQ[expandedXiS23],
    projectorName <> " " <> chargeKey <>
      " xi,s23 map failed exact symbolic validation"
  ];
  <|
    "Projector" -> projectorName,
    "ChargeKey" -> chargeKey,
    "ResidualExpansionInventory" -> residualExpansionInventory,
    "ExpandedLeafCount" -> LeafCount[expandedXiS23],
    "ExpandedByteCount" -> ByteCount[expandedXiS23],
    "Expression" -> expandedXiS23
  |>
];

processChargeTask[task_Association] := Module[
  {chargeKey, requestedProjectors, inputs, mapRules, jacobian, caught},
  chargeKey = task["ChargeKey"];
  requestedProjectors = task["RequestedProjectors"];
  inputs = task["Inputs"];
  mapRules = task["PartonicToXiS23Rules"];
  jacobian = task["XiS23Jacobian"];
  caught = Catch[
    Module[{records},
      workerRequire[
        MemberQ[chargeKeys, chargeKey],
        "worker received an unknown charge key"
      ];
      workerRequire[
        DuplicateFreeQ[requestedProjectors] &&
          And @@ (MemberQ[projectorKeys, #] & /@ requestedProjectors),
        "worker received an invalid projector request"
      ];
      workerRequire[
        AssociationQ[inputs] && Keys[inputs] === requestedProjectors,
        "worker received malformed branch inputs"
      ];
      records = Association@Table[
        projectorName -> processBranchCore[
          inputs[projectorName],
          projectorName,
          chargeKey,
          mapRules,
          jacobian
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
    "S09WorkerFailure"
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

launchS09Kernels[] := Module[{localCandidates, configuration, launched},
  closeS09Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet @ Check[# ["Class"] === "LocalKernels", False] &
  ];
  assert[
    Length[localCandidates] >= 1,
    "No local Wolfram kernel configuration is available."
  ];
  configuration = ReplacePart[
    First[localCandidates],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernelCount
    }
  ];
  assert[
    configuration["KernelCommand"] === parallelKernelExecutable &&
      configuration["KernelCount"] === requestedParallelKernelCount,
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
    workerRequire, hasExactlyExpectedScaleQ, appendixFExpansion,
    appendixFZeroJ, expandOneMaster, expandAppendixFMasters,
    expandCase1Functions, expandedKernelValidQ, processBranchCore,
    processChargeTask, zeroJExpansions, betaRules, gammaRatio1,
    gammaRatio2, gammaOneSeries, gammaTwoSeries,
    workerMemoryBudgetBytes, dimensionalScaleFactor,
    projectorKeys, chargeKeys, S08Case2Master
  ];
  True
];

runOrderedChargeTasks[tasks_List] := Module[{results, returnedKeys},
  Print[
    "S09_STAGE: dispatching three charge tasks across three Engine-15 kernels"
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
    And @@ (TrueQ[# ["Success"]] & /@ results),
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
  S09RegularEndpointFunction[projector, chargeKey, s23] ==
    s23^(1 + epsilon) *
      S09ExpandedKernelReference[projector, chargeKey, s23]
];

formalEndpointDistribution[
    projectorName_String, chargeKey_String
  ] :=
  -s23UpperB^(-epsilon)/epsilon *
      S09EndpointValue[
        projectorName, chargeKey, s23 -> 0
      ] DiracDelta[s23] +
    s23UpperB^(-epsilon) *
      S09RegularEndpointFunction[
        projectorName, chargeKey, s23
      ] *
      Sum[
        (-epsilon)^n/Factorial[n] *
          S09PlusDistribution[n, s23, s23UpperB],
        {n, 0, 2}
      ];

formalEndpointDistributions = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> formalEndpointDistribution[projectorName, chargeKey],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];
assert[
  AllTrue[
    allBranchValues[formalEndpointDistributions],
    ! FreeQ[#, DiracDelta[s23]] &&
      Count[#, _S09PlusDistribution, Infinity] === 3 &&
      ! FreeQ[#, _S09EndpointValue] &&
      ! FreeQ[#, _S09RegularEndpointFunction] &
  ],
  "A formal endpoint descriptor has the wrong delta/plus structure."
];

paperF8F9InventoryCheck =
  MemberQ[expectedAllPairs, {1, -3}] &&
    ! MemberQ[expectedAllPairs, {2, -3}];
assert[
  paperF8F9InventoryCheck,
  "The required F8 or excluded F9 inventory changed."
];

baseChecks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS07SourceAndResultHashesValidated" -> True,
  "AcceptedS08SourceResultAndSixCacheHashesValidated" -> True,
  "AllThirtyEightS08ChecksValidated" -> True,
  "SixS08CachePayloadsExactlyMatchPhysicalFactorOneInputs" -> True,
  "OrderedPgPPPAndThreeChargeInputsOnly" -> True,
  "AcceptedXiS23BranchesReconstructedExactlyFromAngularInputs" -> True,
  "ExactTwentyOneMasterClassUnionValidated" -> True,
  "ExactSixBranchMasterClassInventoriesValidated" -> True,
  "ExactNinetyEightMasterOccurrencesValidated" -> True,
  "ExactFortySevenDistinctMasterInstancesValidated" -> True,
  "EveryRetainedMasterHasFiveArguments" -> True,
  "AllPhysicalAppendixFFormulasImplemented" -> True,
  "ElevenExactB19DerivativeRecurrencesPassed" -> True,
  "RequiredF8ExactB19MomentReductionPassed" -> True,
  "PrintedUnusedF9ExcludedWithoutPatch" -> True,
  "B18ZeroJExpandedThroughEpsilonSquared" -> True,
  "OnlyB27ResidualSignatureAndTwoMixedOccurrencesPresent" -> True,
  "B27ExpandedThroughEpsilonSquared" -> True,
  "IndividualGammaSeriesReconstructBothRatiosThroughEpsilonSquared" ->
    True,
  "AllBetaGammaAndCase2MasterHeadsRemoved" -> True,
  "AppendixFSubstitutionCommutesWithExactXiS23MapByBranch" -> True,
  "B18B27SubstitutionCommutesWithExactXiS23MapByBranch" -> True,
  "AllSixExpandedBranchesCompleted" -> True,
  "NestedAssociationValueMappingShapeAndValuesVerified" -> True,
  "ExactlyThreeChargeWorkersUsed" -> True,
  "ProjectorsSerialWithinEachChargeWorker" -> True,
  "WorkersNeverWriteCachesOrResult" -> True,
  "AdditionalMultiplicativeWeightIsExactlyOne" -> True,
  "DistinctFinalStateSymmetryFactorDerivedAsOne" -> True,
  "NoNontrivialSymmetryFactorAppliedOrDeferred" -> True,
  "SingleInheritedScaleMuPowerPreserved" -> True,
  "NoExtraMSBarSEpsilonIntroduced" -> True,
  "ThreeChargeTensorsRemainSeparateAndChargeFree" -> True,
  "PhysicalOrderedFlavorChargeAssemblyStillDeferred" -> True,
  "NoVirtualBranchIntroduced" -> True,
  "FormalBoundedEndpointIdentityValidatedThroughEpsilonSquared" -> True,
  "AllSixEndpointValuesExplicitlyUnresolved" -> True,
  "FactorizationAndResolvedDistributionActionNotApplied" -> True,
  "Eq9FiniteLimitFHatAndExternalComparisonNotClaimed" -> True,
  "S10NotCreatedOrLaunched" -> True
|>;

cachedBranches = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> loadValidatedCache[projectorName, chargeKey],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

requestedProjectorsByCharge = Association@Table[
  chargeKey -> Select[
    projectorKeys,
    Function[projectorName,
      ! AssociationQ[cachedBranches[projectorName][chargeKey]]
    ]
  ],
  {chargeKey, chargeKeys}
];

tasks = Table[
  <|
    "ChargeKey" -> chargeKey,
    "RequestedProjectors" -> requestedProjectorsByCharge[chargeKey],
    "Inputs" -> Association@Table[
      projectorName -> physicalAngular[projectorName][chargeKey],
      {
        projectorName,
        requestedProjectorsByCharge[chargeKey]
      }
    ],
    "PartonicToXiS23Rules" -> partonicToXiS23Rules,
    "XiS23Jacobian" -> xiS23Jacobian
  |>,
  {chargeKey, chargeKeys}
];

Print["S09_STAGE: launching three independent charge workers"];
assert[launchS09Kernels[], "Engine-15 worker launch failed."];
workerResults = runOrderedChargeTasks[tasks];
closeS09Kernels[];
workerResultsByCharge = AssociationThread[chargeKeys, workerResults];

branchRecords = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> If[
      AssociationQ[cachedBranches[projectorName][chargeKey]],
      With[{cache = cachedBranches[projectorName][chargeKey]},
        <|
          "Projector" -> projectorName,
          "ChargeKey" -> chargeKey,
          "ResidualExpansionInventory" ->
            cache["ResidualExpansionInventory"],
          "ExpandedLeafCount" -> cache["ExpandedLeafCount"],
          "ExpandedByteCount" -> cache["ExpandedByteCount"],
          "Expression" -> cache["Expression"],
          "CacheResumed" -> True
        |>
      ],
      Join[
        workerResultsByCharge[chargeKey]["Records"][projectorName],
        <|"CacheResumed" -> False|>
      ]
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

Do[
  assert[
    AssociationQ[branchRecords[projectorName][chargeKey]] &&
      branchRecords[projectorName][chargeKey]["Projector"] ===
        projectorName &&
      branchRecords[projectorName][chargeKey]["ChargeKey"] === chargeKey &&
      branchRecords[projectorName][chargeKey]["ResidualExpansionInventory"] === <|
          "Case2MasterCount" -> 0,
          "HypergeometricCount" -> 0,
          "BetaCount" -> 0,
          "GammaCount" -> 0,
          "FailedCount" -> 0,
          "MachineRealCount" -> 0
        |> &&
      branchRecords[projectorName][chargeKey]["ExpandedLeafCount"] > 0 &&
      branchRecords[projectorName][chargeKey]["ExpandedByteCount"] > 0 &&
      branchRecords[projectorName][chargeKey]["ExpandedLeafCount"] ===
        LeafCount[branchRecords[projectorName][chargeKey]["Expression"]] &&
      branchRecords[projectorName][chargeKey]["ExpandedByteCount"] ===
        ByteCount[branchRecords[projectorName][chargeKey]["Expression"]] &&
      validateExpandedKernel[
        branchRecords[projectorName][chargeKey]["Expression"],
        projectorName,
        chargeKey
      ],
    "Expanded branch record failed main-kernel validation for " <>
      projectorName <> " " <> chargeKey
  ];
  Print[
    "S09_CHECKPOINT: completed ", projectorName, " ", chargeKey,
    " expanded leaf/byte counts ",
    InputForm[{
      branchRecords[projectorName][chargeKey]["ExpandedLeafCount"],
      branchRecords[projectorName][chargeKey]["ExpandedByteCount"]
    }]
  ],
  {projectorName, projectorKeys},
  {chargeKey, chargeKeys}
];

branchSummaries = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> Join[
      KeyDrop[
        branchRecords[projectorName][chargeKey],
        {"Expression"}
      ],
      <|
        "MasterPairs" ->
          expectedPairsByBranch[projectorName][chargeKey],
        "MasterOccurrenceCount" ->
          masterOccurrenceCounts[projectorName][chargeKey],
        "DistinctMasterInstanceCount" ->
          distinctMasterInstanceCounts[projectorName][chargeKey],
        "CurrentExpandedExpressionValidated" -> True,
        "CurrentCacheReloadValidated" -> If[
          preflightOnly,
          "Not applicable in no-write preflight",
          False
        ]
      |>
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

assert[
  And @@ (TrueQ /@ Values[baseChecks]) &&
    additionalMultiplicativeWeight === 1 &&
    derivedFinalStateSymmetryFactor === 1 &&
    Length[workerVersions] === requestedParallelKernelCount &&
    parallelOrderProbe === chargeKeys,
  "At least one S09 base, weight, symmetry, or parallel check failed."
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
    InputForm[branchSummaries]
  ];
  Quit[0]
];

Print["S09_STAGE: atomically publishing new source-bound branch caches"];
Do[
  If[
    ! AssociationQ[cachedBranches[projectorName][chargeKey]],
    record = branchRecords[projectorName][chargeKey];
    cachePayload = <|
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
      "S07SourcePath" -> s07SourcePath,
      "S07SourceSHA256" -> expectedS07SourceHash,
      "S07ResultPath" -> s07ResultPath,
      "S07ResultSHA256" -> expectedS07ResultHash,
      "S08SourcePath" -> s08SourcePath,
      "S08SourceSHA256" -> expectedS08SourceHash,
      "S08ResultPath" -> s08ResultPath,
      "S08ResultSHA256" -> expectedS08ResultHash,
      "S08CachePath" -> s08CachePaths[projectorName][chargeKey],
      "S08CacheSHA256" ->
        expectedS08CacheHashes[projectorName][chargeKey],
      "InputKey" ->
        "ThreeBodyAngularIntegrated/NLOReal_OAlphaS2/" <>
          "Hqqprime;q_qbarPrime/" <> projectorName <> "/" <> chargeKey,
      "InputExpressionSHA256" ->
        inputExpressionHashes[projectorName][chargeKey],
      "AllMasterPairs" -> expectedAllPairs,
      "BranchMasterPairs" ->
        expectedPairsByBranch[projectorName][chargeKey],
      "MasterOccurrenceCount" ->
        masterOccurrenceCounts[projectorName][chargeKey],
      "DistinctMasterInstanceCount" ->
        distinctMasterInstanceCounts[projectorName][chargeKey],
      "ExpansionOrders" -> <|
        "NonzeroJExceptF28F29" -> "through epsilon^1",
        "F28F29" -> "through epsilon^0",
        "B18ZeroJ" -> "through epsilon^2",
        "B27" -> "through epsilon^2"
      |>,
      "ResidualB27Signatures" ->
        hypergeometricSignaturesByBranch[projectorName][chargeKey],
      "ResidualB27OccurrenceCount" ->
        hypergeometricCountsByBranch[projectorName][chargeKey],
      "ResidualExpansionInventory" ->
        record["ResidualExpansionInventory"],
      "IndividualGammaSeriesRatioRegressionPassed" -> True,
      "XiS23MapAppliedAfterMasterExpansion" -> True,
      "MasterAndCase1MapCommutationVerified" -> True,
      "AdditionalMultiplicativeWeight" ->
        additionalMultiplicativeWeight,
      "ScaleBookkeeping" -> scaleBookkeeping,
      "ChargeBookkeeping" -> chargeBookkeeping,
      "SymmetryBookkeeping" -> symmetryBookkeeping,
      "FinalStateSymmetryFactor" ->
        derivedFinalStateSymmetryFactor,
      "VirtualContributionAtThisOrder" -> virtualBookkeeping,
      "ExpandedLeafCount" -> record["ExpandedLeafCount"],
      "ExpandedByteCount" -> record["ExpandedByteCount"],
      "ExpressionSHA256" -> expressionSHA256[record["Expression"]],
      "Expression" -> record["Expression"]
    |>;
    reloadedCache = atomicPutAssociation[
      cachePayload,
      cachePaths[projectorName][chargeKey],
      cacheStageVersion
    ];
    assert[
      cacheMetadataValidQ[
        reloadedCache, projectorName, chargeKey
      ] &&
        reloadedCache["ExpressionSHA256"] ===
          expressionSHA256[reloadedCache["Expression"]] &&
        reloadedCache["Expression"] === record["Expression"] &&
        validateExpandedKernel[
          reloadedCache["Expression"], projectorName, chargeKey
        ],
      "Atomic cache write/reload failed for " <>
        projectorName <> " " <> chargeKey
    ];
    Clear[cachePayload, reloadedCache, record]
  ],
  {projectorName, projectorKeys},
  {chargeKey, chargeKeys}
];

Clear[branchRecords, physicalAngular, acceptedXiS23];
ClearSystemCache[];

Print["S09_STAGE: validating all six finalized source-bound caches"];
finalizedCaches = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> Module[{cache},
      cache = Quiet @ Check[
        Get[cachePaths[projectorName][chargeKey]],
        $Failed
      ];
      assert[
        cacheMetadataValidQ[cache, projectorName, chargeKey] &&
          cache["ExpressionSHA256"] ===
            expressionSHA256[cache["Expression"]] &&
          cache["ExpandedLeafCount"] === LeafCount[cache["Expression"]] &&
          cache["ExpandedByteCount"] === ByteCount[cache["Expression"]] &&
          validateExpandedKernel[
            cache["Expression"], projectorName, chargeKey
          ],
        "Finalized cache failed independent reload validation for " <>
          projectorName <> " " <> chargeKey
      ];
      cache
    ],
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

finalBranchSummaries = Association@Table[
  projectorName -> Association@Table[
    chargeKey -> <|
      "Projector" -> projectorName,
      "ChargeKey" -> chargeKey,
      "MasterPairs" ->
        expectedPairsByBranch[projectorName][chargeKey],
      "MasterOccurrenceCount" ->
        masterOccurrenceCounts[projectorName][chargeKey],
      "DistinctMasterInstanceCount" ->
        distinctMasterInstanceCounts[projectorName][chargeKey],
      "ResidualExpansionInventory" ->
        finalizedCaches[projectorName][chargeKey]["ResidualExpansionInventory"],
      "ExpandedLeafCount" ->
        finalizedCaches[projectorName][chargeKey]["ExpandedLeafCount"],
      "ExpandedByteCount" ->
        finalizedCaches[projectorName][chargeKey]["ExpandedByteCount"],
      "CacheResumed" ->
        AssociationQ[cachedBranches[projectorName][chargeKey]],
      "CurrentExpandedExpressionValidated" -> True,
      "CurrentCacheReloadValidated" -> True
    |>,
    {chargeKey, chargeKeys}
  ],
  {projectorName, projectorKeys}
];

cacheHashes = mapNestedAssociationValues[fileSHA256, cachePaths];
assert[
  Keys[cacheHashes] === projectorKeys &&
    And @@ (Keys[#] === chargeKeys & /@ Values[cacheHashes]) &&
    AllTrue[
      allBranchValues[cacheHashes],
      StringLength[#] === 64 &&
        StringMatchQ[#, RegularExpression["[0-9a-f]{64}"]] &
    ] &&
    And @@ Flatten@Table[
      cacheHashes[projectorName][chargeKey] ===
        fileSHA256[cachePaths[projectorName][chargeKey]],
      {projectorName, projectorKeys},
      {chargeKey, chargeKeys}
    ],
  "The finalized nested cache hashes have wrong shape or disk values."
];

checks = Join[
  baseChecks,
  <|
    "SixAtomicBranchCachesReloadedAndValidated" -> True,
    "ActualDiskCacheHashesMappedByNestedAssociationValues" -> True,
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
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "H_{q qPrime; q qbarPrime} charge-resolved Appendix-F-expanded real Pg/PPP kernels with formal endpoint handoff",
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
      "ThreeBodyAngularIntegrated/NLOReal_OAlphaS2/" <>
        "Hqqprime;q_qbarPrime/<projector>/<charge-key>"
  |>,
  "AppendixFExpansion" -> <|
    "ExactPairsByProjectorAndCharge" -> expectedPairsByBranch,
    "ExactAllPairs" -> expectedAllPairs,
    "MasterOccurrencesByProjectorAndCharge" ->
      masterOccurrenceCounts,
    "DistinctMasterInstancesByProjectorAndCharge" ->
      distinctMasterInstanceCounts,
    "TotalMasterOccurrenceCount" -> Length[allMasterOccurrences],
    "TotalDistinctMasterInstanceCount" ->
      Length[DeleteDuplicates[allMasterOccurrences]],
    "ExpansionOrders" -> <|
      "NonzeroJExceptF28F29" -> "through epsilon^1",
      "F28F29" -> "through epsilon^0",
      "B18ZeroJ" -> "through epsilon^2",
      "B27" -> "through epsilon^2"
    |>,
    "ResidualB27SignaturesByProjectorAndCharge" ->
      hypergeometricSignaturesByBranch,
    "ResidualB27OccurrenceCountsByProjectorAndCharge" ->
      hypergeometricCountsByBranch,
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
    "PrintedF9EpsilonTermRequiredByCurrentInventory" -> False,
    "NoPowerExpandOrNumericalBranchSelection" -> True,
    "BranchSummaries" -> finalBranchSummaries
  |>,
  "ExpandedKernelCaches" -> <|
    "StageVersion" -> cacheStageVersion,
    "Paths" -> cachePaths,
    "SHA256" -> cacheHashes,
    "ExpressionField" -> "Expression",
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S08ResultSHA256" -> expectedS08ResultHash,
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
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS09" ->
      additionalMultiplicativeWeight,
    "Scale" -> scaleBookkeeping,
    "Charge" -> chargeBookkeeping,
    "Symmetry" -> symmetryBookkeeping,
    "FinalStateSymmetryFactorDerivedAtS09" ->
      derivedFinalStateSymmetryFactor,
    "NontrivialSymmetryFactorAppliedAtS09" -> False,
    "VirtualContributionAtThisOrder" -> virtualBookkeeping,
    "PhysicalOrderedFlavorChargeAssemblyAppliedAtS09" -> False,
    "SeparateMSBarSEpsilonAppliedAtS09" -> False
  |>,
  "EndpointExpansion" -> <|
    "Status" ->
      "Formal bounded distributions only; endpoint values and stronger singularities unresolved",
    "Interval" -> {s23, 0, s23UpperB},
    "UpperLimit" -> s23UpperB,
    "ExpansionThrough" -> "epsilon^2 with O(epsilon^3) remainder",
    "RegularFunctionDefinition" -> regularFunctionDefinition,
    "ExpandedKernelReferenceMeaning" ->
      "For each projector/charge branch, the exact Expression field of its hash-pinned S09 cache",
    "PlusDistributionAction" -> plusDistributionAction,
    "FormalDistributionByProjectorAndCharge" ->
      formalEndpointDistributions,
    "QuadraticTestFunctionResidualThroughEpsilonSquared" ->
      endpointIdentityPolynomialResidual,
    "EndpointValuesResolved" -> False,
    "StrongerSingularitiesResolved" -> False,
    "DistributionActionPerformed" -> False,
    "DownstreamResolutionRequired" -> True
  |>,
  "Checks" -> checks,
  "MemoryStrategy" ->
    "Exactly three Engine-15 workers process one charge key each, with Pg then PPP serial inside each worker; workers return expressions and write nothing; the main kernel atomically publishes six caches and a compact result.",
  "NotPerformedAtThisStage" -> {
    "numerical or symbolic substitution for unresolved endpoint values",
    "structural resolution of stronger s23 poles",
    "delta/plus-distribution action on a test function",
    "initial-state PDF or final-state FF subtraction/factorization",
    "resolved Laurent pole-cancellation test",
    "epsilon -> 0 finite hard-part limit",
    "Eq. (9) Pg/PPP inversion or F-hat extraction",
    "physical ordered q,qPrime flavour/charge assembly",
    "external-code comparison",
    "creation or launch of S10"
  },
  "DownstreamInstruction" ->
    "A separately authorized S10 may load the exact hash-pinned six cache expressions and resolve all s23 singularity classes termwise; it must preserve all three charge tensors, the inherited scale, the unit final-state factor, and the absent virtual branch."
|>;

assert[
  FreeQ[s09Result, HoldPattern[Rule["Expression", _]]],
  "The compact S09 result unexpectedly duplicates a cache expression."
];

Clear[finalizedCaches, cachedBranches];
ClearSystemCache[];

Print["S09_STAGE: atomically writing the compact Hqqprime S09 result"];
reloadedResult = atomicPutAssociation[s09Result, resultPath, stageVersion];
assert[
  reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["ProjectorOrder"] === projectorKeys &&
    reloadedResult["ChargeKeyOrder"] === chargeKeys &&
    reloadedResult["InputProvenance"]["S08ResultSHA256"] ===
      expectedS08ResultHash &&
    reloadedResult["ExpandedKernelCaches"]["Paths"] === cachePaths &&
    reloadedResult["ExpandedKernelCaches"]["SHA256"] === cacheHashes &&
    reloadedResult["EndpointExpansion"]["EndpointValuesResolved"] ===
      False &&
    reloadedResult["EndpointExpansion"]["DistributionActionPerformed"] ===
      False &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "The final compact S09 result failed exact reload validation."
];
assert[
  And @@ Flatten@Table[
    reloadedResult["ExpandedKernelCaches"]["SHA256"]
        [projectorName][chargeKey] ===
      fileSHA256[cachePaths[projectorName][chargeKey]],
    {projectorName, projectorKeys},
    {chargeKey, chargeKeys}
  ],
  "The final S09 result cache hashes do not match the real disk files."
];
assert[
  FileNames["s09_result.tmp.*", scriptDirectory] === {} &&
    FileNames["s09_cache_hqqprime*.tmp.*", scriptDirectory] === {},
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

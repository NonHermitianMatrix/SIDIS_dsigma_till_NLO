(* ::Package:: *)

(*
  Hqqprime S06: sum the four external-fermion spin/color states in each
  separately retained S05 charge tensor and apply exactly the incoming-quark
  average fixed by paper Eq. (14) and the fundamental color representation.

    gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3).

  The three charge structures and photon indices s05Mu,s05Nu remain
  separate/open.  This stage adds no virtual term, symmetry factor, physical
  flavor/charge assembly, projector, phase space, or factorization operation.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, expressionSHA256, atomicPutAssociation,
  hasExactlyExpectedScaleQ, validatePostDiracTensor,
  validateColorSummedTensor, setThreeBodyKinematics,
  cacheMetadataValidQ, loadValidatedCache, writeCache,
  processPostDiracTask, processFinalTask, launchS06Kernels,
  closeS06Kernels, runOrderedParallelTasks
];

activeTemporaryPath = "";

closeS06Kernels[] := If[
  IntegerQ[$KernelCount] && $KernelCount > 0,
  Quiet[CloseKernels[]]
];

fatal[message_String] := (
  closeS06Kernels[];
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S06_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  assert[! FileExistsQ[finalPath],
    "refusing to overwrite existing artifact " <> finalPath];
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[! FileExistsQ[activeTemporaryPath],
    "process-specific temporary artifact already exists"];

  writeResult = Quiet @ Check[
    Put[expression, activeTemporaryPath];
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    False
  ];
  If[! TrueQ[writeResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic temporary write failed"]
  ];

  loaded = Quiet @ Check[Get[activeTemporaryPath], $Failed];
  If[
    ! AssociationQ[loaded] ||
      loaded["Status"] =!= "Complete" ||
      loaded["Stage"] =!= expectedStage,
    Quiet[DeleteFile[activeTemporaryPath]];
    fatal["temporary Association failed status/stage reload validation"]
  ];

  renameResult = Quiet @ Check[
    RenameFile[activeTemporaryPath, finalPath];
    True,
    False
  ];
  If[! TrueQ[renameResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic rename failed"]
  ];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "finalized artifact is missing or empty"
  ];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s05SourcePath = FileNameJoin[{
  scriptDirectory, "s05_form_hqqprime_real_bilinear.wl"
}];
s05ResultPath = FileNameJoin[{scriptDirectory, "s05_result"}];
s06ResultPath = FileNameJoin[{scriptDirectory, "s06_result"}];

stageVersion = "HqqprimeS06-v1";
cacheStageVersion = "HqqprimeS06Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S06_PREFLIGHT_ONLY"], ""] === "1";
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 4 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS05SourceHash =
  "95a405581e6b5c9f24af44b513895cfa42c6524c097bc23e624de5c8df1c66f5";
expectedS05ResultHash =
  "d78577388379acf513733d6d21e85a30ab34200a1a35e7b7605e6241bfbfdec7";
expectedS01SourceHash =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultHash =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedS04SourceHash =
  "9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc";
expectedS04ResultHash =
  "2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84";

chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
chargeKeySlugs = <|
  "IncomingChargeSquared" -> "incoming_charge_squared",
  "PrimeChargeSquared" -> "prime_charge_squared",
  "MixedIncomingPrimeCharge" -> "mixed_incoming_prime_charge"
|>;
postDiracCachePaths = AssociationThread[
  chargeKeys,
  FileNameJoin[{
    scriptDirectory,
    "s06_cache_hqqprime_" <> chargeKeySlugs[#] <> "_after_dirac"
  }] & /@ chargeKeys
];
finalCachePaths = AssociationThread[
  chargeKeys,
  FileNameJoin[{
    scriptDirectory,
    "s06_cache_hqqprime_" <> chargeKeySlugs[#] <> "_spin_color"
  }] & /@ chargeKeys
];

programHash = fileSHA256[programPath];
s05ResultHash = fileSHA256[s05ResultPath];
staleTemporaryPaths = Join[
  FileNames["s06_result.tmp.*", scriptDirectory],
  FileNames["s06_cache_hqqprime_*.tmp.*", scriptDirectory]
];
assert[staleTemporaryPaths === {},
  "a stale S06 temporary artifact must be resolved before running"];
If[! preflightOnly,
  assert[! FileExistsQ[s06ResultPath],
    "s06_result already exists; validate it or deliberately remove it before regeneration"]
];

Print["S06_STAGE: validating the paper and accepted S05 handoff"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing"];
    assert[fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff"];
  ],
  <|
    "authoritative paper" -> {paperPath, expectedPaperHash},
    "S05 source" -> {s05SourcePath, expectedS05SourceHash},
    "S05 result" -> {s05ResultPath, expectedS05ResultHash}
  |>
];

s05 = Quiet @ Check[Get[s05ResultPath], $Failed];
assert[AssociationQ[s05], "s05_result is not an Association"];
assert[
  s05["Status"] === "Complete" &&
    s05["Stage"] === "HqqprimeS05-v1" &&
    s05["ResultSchemaVersion"] === 1 &&
    s05["Channel"] === "Hqqprime only" &&
    s05["Contribution"] ===
      "H_{q qPrime; q qbarPrime} charge-resolved real bilinear" &&
    s05["PerturbativeOrder"] === "O(alpha_s^2)",
  "S05 status/stage/schema/channel/contribution is invalid"
];
assert[
  s05["ProgramSHA256"] === expectedS05SourceHash &&
    s05["ReferencePDFSHA256"] === expectedPaperHash,
  "S05 source or paper binding is invalid"
];
assert[
  s05["Input", "S01SourceSHA256"] === expectedS01SourceHash &&
    s05["Input", "S01ResultSHA256"] === expectedS01ResultHash &&
    s05["Input", "S04SourceSHA256"] === expectedS04SourceHash &&
    s05["Input", "S04ResultSHA256"] === expectedS04ResultHash &&
    s05["Input", "S04StageDisposition"] === "NotApplicableAtThisOrder",
  "an inherited S01/S04 identity or disposition is invalid"
];
assert[
  Length[s05["Checks"]] === 35 &&
    And @@ (TrueQ /@ Values[s05["Checks"]]),
  "an accepted S05 check is not True"
];
assert[
  s05["VirtualContributionAtThisOrder", "Applicable"] === False &&
    s05["VirtualContributionAtThisOrder", "Interference"] === 0 &&
    s05["VirtualContributionAtThisOrder", "SourceDisposition"] ===
      "NotApplicableAtThisOrder",
  "S05 violates the real-only virtual-absence contract"
];
assert[
  s05["ChargeBookkeeping", "SeparatedTensorKeys"] === chargeKeys &&
    s05["ChargeBookkeeping", "PhysicalOrderedFlavorSumAppliedAtS05"] ===
      False,
  "S05 charge-key order or physical-flavor deferral is invalid"
];
assert[
  Keys[s05["ChargeResolvedBilinears", "UnscaledChargeTensors"]] ===
      chargeKeys &&
    Keys[s05["ChargeResolvedBilinears", "ScaleAttachedChargeTensors"]] ===
      chargeKeys &&
    Keys[s05["ChargeResolvedBilinears", "CoefficientExtractedTensors"]] ===
      chargeKeys,
  "an S05 charge-tensor association has the wrong keys or order"
];
assert[
  s05["SymmetryAndAverageBookkeeping",
      "NontrivialIdenticalFinalStateFactorRequired"] === False &&
    s05["SymmetryAndAverageBookkeeping",
      "SymmetryFactorAppliedAtS05"] === False &&
    s05["SymmetryAndAverageBookkeeping",
      "IncomingQuarkSpinColorAverageAppliedAtS05"] === False &&
    And @@ (# === 1 & /@
      Values[s05["SymmetryAndAverageBookkeeping",
        "DerivedFinalStateSymmetryFactors"]]),
  "S05 symmetry or incoming-average bookkeeping is invalid"
];

expectedExternalSpinors = {
  FeynCalc`Spinor[FeynCalc`Momentum[k1, D], 0, 1],
  FeynCalc`Spinor[-FeynCalc`Momentum[k3, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k2, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[p, D], 0, 1]
};
storedExternalSpinors = s05["ExternalProcess", "ExternalSpinors"];
assert[
  Length[storedExternalSpinors] === Length[expectedExternalSpinors] &&
    And @@ (MemberQ[storedExternalSpinors, #] & /@
      expectedExternalSpinors) &&
    And @@ (MemberQ[expectedExternalSpinors, #] & /@
      storedExternalSpinors),
  "S05 does not record exactly the four accepted external spinors"
];
assert[
  s05["ExternalProcess", "IncomingMomenta"] === {q, p} &&
    s05["ExternalProcess", "OutgoingMomenta"] === {k1, k2, k3} &&
    s05["ExternalProcess", "FragmentingParton"] === "qPrime(k1)" &&
    s05["ExternalProcess", "UnobservedPartons"] ===
      {"q(k2)", "qbarPrime(k3)"},
  "S05 external-state momentum or role ordering is invalid"
];

genericChargeSymbols = s05["ChargeBookkeeping", "GenericChargeSymbols"];
assert[
  MatchQ[genericChargeSymbols, {_Symbol, _Symbol}] &&
    DuplicateFreeQ[genericChargeSymbols],
  "S05 generic charge symbols are invalid"
];
inputCoreTensors =
  s05["ChargeResolvedBilinears", "UnscaledChargeTensors"];
inputTensors =
  s05["ChargeResolvedBilinears", "ScaleAttachedChargeTensors"];
dimensionalScaleExponent =
  s05["ChargeResolvedBilinears", "DimensionalScaleExponent"];
dimensionalScaleFactor =
  s05["ChargeResolvedBilinears", "DimensionalScaleFactor"];
assert[
  dimensionalScaleFactor ===
      FeynCalc`ScaleMu^dimensionalScaleExponent &&
    dimensionalScaleExponent === 4 epsilon &&
    s05["ChargeResolvedBilinears", "SeparateMSBarSEpsilonApplied"] ===
      False,
  "S05 dimensional scale ledger is invalid"
];
assert[
  And @@ (
    inputTensors[#] === dimensionalScaleFactor inputCoreTensors[#] &&
      FreeQ[inputCoreTensors[#], FeynCalc`ScaleMu] & /@ chargeKeys
  ),
  "an S05 charge tensor has a missing, duplicated, or inconsistent scale"
];
inputTensorHashes = AssociationThread[
  chargeKeys,
  expressionSHA256 /@ Lookup[inputTensors, chargeKeys]
];

hasExactlyExpectedScaleQ[expression_] := Module[
  {
    marker, scaleExponents, markedExpression, markerDegree,
    markerConstant, scaleFreeCoefficient, reconstructionResidual
  },
  marker = Unique["s06ScaleMarker$"];
  scaleExponents = DeleteDuplicates @ Cases[
    expression,
    HoldPattern[Power[FeynCalc`ScaleMu, exponent_]] :> exponent,
    Infinity
  ];
  If[
    scaleExponents === {} ||
      ! And @@ (
        TrueQ[Simplify[# - dimensionalScaleExponent] === 0] & /@
          scaleExponents
      ),
    Return[False]
  ];
  markedExpression = expression /. HoldPattern[
      Power[FeynCalc`ScaleMu, exponent_]
    ] :> marker;
  markerDegree = Quiet @ Check[
    Exponent[markedExpression, marker],
    $Failed
  ];
  markerConstant = Quiet @ Check[
    Coefficient[markedExpression, marker, 0],
    $Failed
  ];
  scaleFreeCoefficient = Quiet @ Check[
    Coefficient[markedExpression, marker, 1],
    $Failed
  ];
  reconstructionResidual = Quiet @ Check[
    Expand[
      expression - dimensionalScaleFactor scaleFreeCoefficient
    ],
    $Failed
  ];
  FreeQ[markedExpression, FeynCalc`ScaleMu] &&
    markerDegree === 1 && markerConstant === 0 &&
    FreeQ[scaleFreeCoefficient, FeynCalc`ScaleMu] &&
    reconstructionResidual === 0
];

explicitColorPattern =
  _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex | _FeynCalc`SUNT |
  _FeynCalc`SUNF | _FeynCalc`SUNDelta | _FeynCalc`SUNTrace |
  _FeynCalc`SumOver;
loopOrRegulatorPattern =
  FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`A00 | FeynCalc`B0 |
  FeynCalc`B1 | FeynCalc`B00 | FeynCalc`B11 | FeynCalc`C0 |
  FeynCalc`D0 | FeynCalc`E0 | FeynCalc`TID | FeynCalc`TIDL |
  FeynCalc`GLI | FeynCalc`FCTopology | FeynCalc`EpsilonUV |
  FeynCalc`EpsilonIR;

assert[
  And @@ Table[
    Module[{spinors},
      spinors = DeleteDuplicates @ Cases[
        inputTensors[key], _FeynCalc`Spinor, Infinity
      ];
      Length[spinors] === Length[expectedExternalSpinors] &&
        And @@ (MemberQ[spinors, #] & /@ expectedExternalSpinors) &&
        And @@ (MemberQ[expectedExternalSpinors, #] & /@ spinors) &&
        ! FreeQ[inputTensors[key], FeynCalc`LorentzIndex[s05Mu, D]] &&
        ! FreeQ[inputTensors[key], FeynCalc`LorentzIndex[s05Nu, D]] &&
        ! FreeQ[inputTensors[key], explicitColorPattern] &&
        FreeQ[inputTensors[key], _FeynCalc`Polarization] &&
        FreeQ[inputTensors[key], loopOrRegulatorPattern] &&
        FreeQ[inputTensors[key], _Real] &&
        hasExactlyExpectedScaleQ[inputTensors[key]] &&
        And @@ (FreeQ[inputTensors[key], #] & /@ genericChargeSymbols)
    ],
    {key, chargeKeys}
  ],
  "an S06 input tensor violates its state, color, scale, charge, or purity contract"
];

paperIncomingSpinAverage = 1/2;
incomingFundamentalColorStateCount = FeynCalc`SUNN;
incomingAverageFactor = Together[
  paperIncomingSpinAverage/incomingFundamentalColorStateCount
];
initialAverageDenominator = Together[1/incomingAverageFactor];
assert[
  incomingAverageFactor === 1/(2 FeynCalc`SUNN) &&
    initialAverageDenominator === 2 FeynCalc`SUNN,
  "paper-spin and fundamental-color inputs did not derive 1/(2 Nc)"
];

validatePostDiracTensor[expression_, label_String] := Module[{},
  assert[expression =!= $Failed && expression =!= 0,
    label <> " is failed or zero"];
  assert[FreeQ[expression, _FeynCalc`Spinor],
    label <> " still contains an external spinor"];
  assert[FreeQ[expression, _FeynCalc`Polarization],
    label <> " contains an external polarization"];
  assert[
    FreeQ[
      expression,
      _FeynCalc`DiracTrace | _FeynCalc`DiracGamma |
        _FeynCalc`DiracChain | FeynCalc`FermionSpinSum
    ],
    label <> " still contains an unevaluated Dirac/spin-sum object"
  ];
  assert[
    ! FreeQ[expression, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expression, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost an open photon index"
  ];
  assert[! FreeQ[expression, explicitColorPattern],
    label <> " unexpectedly lacks explicit color data before the color sum"];
  assert[hasExactlyExpectedScaleQ[expression],
    label <> " does not preserve exactly the accepted scale factor"];
  assert[
    FreeQ[expression, loopOrRegulatorPattern] && FreeQ[expression, _Real],
    label <> " contains loop/regulator data or a machine number"
  ];
  assert[And @@ (FreeQ[expression, #] & /@ genericChargeSymbols),
    label <> " contains a generic charge symbol"];
  True
];

validateColorSummedTensor[expression_, label_String] := Module[{},
  assert[expression =!= $Failed && expression =!= 0,
    label <> " is failed or zero"];
  assert[
    FreeQ[
      expression,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracTrace | _FeynCalc`DiracGamma |
        _FeynCalc`DiracChain | FeynCalc`FermionSpinSum
    ],
    label <> " contains an unevaluated external-state or Dirac object"
  ];
  assert[FreeQ[expression, explicitColorPattern],
    label <> " still contains an explicit color object"];
  assert[
    ! FreeQ[expression, FeynCalc`LorentzIndex[s05Mu, D]] &&
      ! FreeQ[expression, FeynCalc`LorentzIndex[s05Nu, D]],
    label <> " lost an open photon index"
  ];
  assert[hasExactlyExpectedScaleQ[expression],
    label <> " does not preserve exactly the accepted scale factor"];
  assert[
    FreeQ[expression, loopOrRegulatorPattern] && FreeQ[expression, _Real],
    label <> " contains loop/regulator data or a machine number"
  ];
  assert[And @@ (FreeQ[expression, #] & /@ genericChargeSymbols),
    label <> " contains a generic charge symbol"];
  True
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

setThreeBodyKinematics[];
kinematicChecks = <|
  "p2" -> (FeynCalc`SPD[p, p] === 0),
  "q2" -> (FeynCalc`SPD[q, q] === -Q2),
  "k12" -> (FeynCalc`SPD[k1, k1] === 0),
  "k22" -> (FeynCalc`SPD[k2, k2] === 0),
  "k32" -> (FeynCalc`SPD[k3, k3] === 0),
  "pq" -> (FeynCalc`SPD[p, q] === (sHat + Q2)/2),
  "qk1" -> (FeynCalc`SPD[q, k1] === (-Q2 - t1)/2),
  "qk2" -> (FeynCalc`SPD[q, k2] === (-Q2 - t2)/2),
  "qk3" -> (FeynCalc`SPD[q, k3] === (-Q2 - t3)/2),
  "pk1" -> (FeynCalc`SPD[p, k1] === -u1/2),
  "pk2" -> (FeynCalc`SPD[p, k2] === -u2/2),
  "pk3" -> (FeynCalc`SPD[p, k3] === -u3/2),
  "k1k2" -> (FeynCalc`SPD[k1, k2] === s12/2),
  "k1k3" -> (FeynCalc`SPD[k1, k3] === s13/2),
  "k2k3" -> (FeynCalc`SPD[k2, k3] === s23/2)
|>;
assert[And @@ Values[kinematicChecks],
  "the exact D-dimensional three-body scalar products were not installed"];

cacheMetadataValidQ[cache_, chargeKey_String, cacheKind_String] :=
  AssociationQ[cache] &&
    Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
    Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
    Lookup[cache, "CacheKind", Missing["CacheKind"]] === cacheKind &&
    Lookup[cache, "ChargeKey", Missing["ChargeKey"]] === chargeKey &&
    Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
      programHash &&
    Lookup[cache, "S05SourceSHA256", Missing["S05SourceSHA256"]] ===
      expectedS05SourceHash &&
    Lookup[cache, "S05ResultSHA256", Missing["S05ResultSHA256"]] ===
      expectedS05ResultHash &&
    Lookup[cache, "InputTensorSHA256", Missing["InputTensorSHA256"]] ===
      inputTensorHashes[chargeKey] &&
    AssociationQ[Lookup[cache, "Payload", Missing["Payload"]]];

loadValidatedCache[
    path_String, chargeKey_String, cacheKind_String
  ] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path],
    Return[Missing["NotAvailable"]]
  ];
  Print["S06_STAGE: inspecting ", chargeKey, " ", cacheKind, " cache"];
  cache = Quiet @ Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, chargeKey, cacheKind]],
    Print["S06_STAGE: deleting invalid ", chargeKey, " ",
      cacheKind, " cache"];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];

  If[cacheKind === "PostDirac",
    If[! KeyExistsQ[cache["Payload"], "PostDiracTensor"],
      Quiet[DeleteFile[path]];
      Return[Missing["InvalidCache"]]
    ];
    validatePostDiracTensor[
      cache["Payload", "PostDiracTensor"],
      "cached " <> chargeKey <> " post-Dirac tensor"
    ],
    If[
      ! KeyExistsQ[cache["Payload"], "ColorSummedUnaveragedTensor"] ||
        ! KeyExistsQ[cache["Payload"], "SpinColorAveragedTensor"],
      Quiet[DeleteFile[path]];
      Return[Missing["InvalidCache"]]
    ];
    validateColorSummedTensor[
      cache["Payload", "ColorSummedUnaveragedTensor"],
      "cached " <> chargeKey <> " color-summed tensor"
    ];
    validateColorSummedTensor[
      cache["Payload", "SpinColorAveragedTensor"],
      "cached " <> chargeKey <> " averaged tensor"
    ];
    If[
      cache["Payload", "SpinColorAveragedTensor"] =!=
        incomingAverageFactor *
          cache["Payload", "ColorSummedUnaveragedTensor"],
      Quiet[DeleteFile[path]];
      Return[Missing["InvalidCache"]]
    ]
  ];
  Print["S06_STAGE: accepted source-bound ", chargeKey, " ",
    cacheKind, " cache"];
  cache
];

writeCache[
    path_String, chargeKey_String, cacheKind_String,
    payload_Association
  ] := Module[{cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "CacheKind" -> cacheKind,
    "ChargeKey" -> chargeKey,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "S05SourcePath" -> s05SourcePath,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultPath" -> s05ResultPath,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "InputTensorSHA256" -> inputTensorHashes[chargeKey],
    "Payload" -> payload
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

processPostDiracTask[task_Association] := Module[
  {chargeKey, tensor, spinSummed, postDirac},
  chargeKey = task["ChargeKey"];
  tensor = task["Tensor"];
  setThreeBodyKinematics[];

  spinSummed = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        FeynCalc`FermionSpinSum[
          tensor,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0
        ],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  If[spinSummed === $Failed,
    Return[<|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" -> "FermionSpinSum failed or exceeded worker memory"
    |>]
  ];

  postDirac = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        FeynCalc`DiracSimplify[
          spinSummed,
          FeynCalc`DiracTrace -> True,
          FeynCalc`DiracTraceEvaluate -> True,
          FeynCalc`DiracSubstitute67 -> True,
          FeynCalc`ToDiracGamma67 -> False,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0,
          FeynCalc`Factoring -> False
        ],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  If[postDirac === $Failed,
    Return[<|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" -> "DiracSimplify failed or exceeded worker memory"
    |>]
  ];
  <|
    "Success" -> True,
    "ChargeKey" -> chargeKey,
    "PostDiracTensor" -> postDirac,
    "LeafCount" -> LeafCount[postDirac]
  |>
];

processFinalTask[task_Association] := Module[
  {chargeKey, postDirac, colorSummed, averaged},
  chargeKey = task["ChargeKey"];
  postDirac = task["PostDiracTensor"];
  setThreeBodyKinematics[];

  colorSummed = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        FeynCalc`SUNSimplify[
          postDirac,
          TimeConstrained -> Infinity,
          FeynCalc`SUNNToCACF -> True,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0
        ],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  If[colorSummed === $Failed,
    Return[<|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" -> "SUNSimplify failed or exceeded worker memory"
    |>]
  ];
  averaged = incomingAverageFactor colorSummed;
  <|
    "Success" -> True,
    "ChargeKey" -> chargeKey,
    "ColorSummedUnaveragedTensor" -> colorSummed,
    "SpinColorAveragedTensor" -> averaged,
    "UnaveragedLeafCount" -> LeafCount[colorSummed],
    "AveragedLeafCount" -> LeafCount[averaged]
  |>
];

launchS06Kernels[] := Module[{localCandidates, configuration, launched},
  closeS06Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet @ Check[#["Class"] === "LocalKernels", False] &
  ];
  assert[Length[localCandidates] >= 1,
    "no local Wolfram kernel configuration is available"];
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
    "the in-memory Engine-15 local kernel configuration is invalid"
  ];
  launched = Quiet @ Check[LaunchKernels[configuration], $Failed];
  assert[
    ListQ[launched] && Length[launched] === requestedParallelKernelCount &&
      $KernelCount === requestedParallelKernelCount,
    "failed to launch exactly three Engine-15 local kernels"
  ];
  ParallelNeeds["FeynCalc`"];
  ParallelEvaluate[$HistoryLength = 0; $FCAdvice = False;];
  workerVersions = ParallelEvaluate[$Version];
  assert[
    Length[workerVersions] === requestedParallelKernelCount &&
      DuplicateFreeQ[workerVersions] === False &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
    "a local worker is not the verified Engine 15.0 runtime"
  ];
  parallelOrderProbe = ParallelMap[
    Identity,
    chargeKeys,
    Method -> "FinestGrained"
  ];
  assert[parallelOrderProbe === chargeKeys,
    "parallel result ordering is not deterministic"];
  DistributeDefinitions[
    setThreeBodyKinematics,
    processPostDiracTask,
    processFinalTask,
    workerMemoryBudgetBytes,
    incomingAverageFactor
  ];
  True
];

runOrderedParallelTasks[tasks_List, workerFunction_, label_String] := Module[
  {results, returnedKeys},
  If[tasks === {}, Return[{}]];
  Print["S06_STAGE: dispatching ", Length[tasks], " ", label,
    " task(s) across three Engine-15 kernels"];
  results = Quiet @ Check[
    ParallelMap[workerFunction, tasks, Method -> "FinestGrained"],
    $Failed
  ];
  assert[ListQ[results] && Length[results] === Length[tasks],
    label <> " parallel dispatch failed"];
  assert[And @@ (AssociationQ /@ results),
    label <> " worker did not return an Association"];
  assert[And @@ (TrueQ[# ["Success"]] & /@ results),
    label <> " worker reported failure: " <>
      ToString[InputForm[Lookup[results, "Failure", None]]]];
  returnedKeys = Lookup[results, "ChargeKey"];
  assert[returnedKeys === Lookup[tasks, "ChargeKey"],
    label <> " results returned in the wrong key order"];
  results
];

Print["S06_STAGE: launching the three independent charge-tensor workers"];
launchS06Kernels[];
launchedParallelKernelCount = $KernelCount;

postDiracCaches = <||>;
finalCaches = <||>;
postDiracTensors = <||>;
colorSummedUnaveragedTensors = <||>;
spinColorAveragedTensors = <||>;
postDiracCacheReused = AssociationThread[chargeKeys, ConstantArray[False, 3]];
finalCacheReused = AssociationThread[chargeKeys, ConstantArray[False, 3]];

Do[
  postDiracCaches[key] = loadValidatedCache[
    postDiracCachePaths[key], key, "PostDirac"
  ];
  If[! MissingQ[postDiracCaches[key]],
    postDiracTensors[key] =
      postDiracCaches[key]["Payload", "PostDiracTensor"];
    postDiracCacheReused[key] = True
  ];
,
  {key, chargeKeys}
];

postDiracPendingKeys = Select[chargeKeys, ! KeyExistsQ[postDiracTensors, #] &];
postDiracTasks = (
  <|"ChargeKey" -> #, "Tensor" -> inputTensors[#]|> & /@
    postDiracPendingKeys
);
postDiracResults = runOrderedParallelTasks[
  postDiracTasks, processPostDiracTask, "post-Dirac"
];
Do[
  key = result["ChargeKey"];
  validatePostDiracTensor[
    result["PostDiracTensor"], key <> " fresh post-Dirac tensor"
  ];
  postDiracTensors[key] = result["PostDiracTensor"];
  writeCache[
    postDiracCachePaths[key], key, "PostDirac",
    <|"PostDiracTensor" -> postDiracTensors[key]|>
  ];
  Print["S06_CHECKPOINT: ", key, " post-Dirac leaf count ",
    LeafCount[postDiracTensors[key]]];
,
  {result, postDiracResults}
];
postDiracTensors = AssociationThread[
  chargeKeys, Lookup[postDiracTensors, chargeKeys]
];
assert[Keys[postDiracTensors] === chargeKeys,
  "post-Dirac tensors lost their required key order"];

Do[
  finalCaches[key] = loadValidatedCache[
    finalCachePaths[key], key, "Final"
  ];
  If[! MissingQ[finalCaches[key]],
    colorSummedUnaveragedTensors[key] =
      finalCaches[key]["Payload", "ColorSummedUnaveragedTensor"];
    spinColorAveragedTensors[key] =
      finalCaches[key]["Payload", "SpinColorAveragedTensor"];
    finalCacheReused[key] = True
  ];
,
  {key, chargeKeys}
];

finalPendingKeys = Select[
  chargeKeys,
  ! KeyExistsQ[spinColorAveragedTensors, #] &
];
finalTasks = (
  <|
    "ChargeKey" -> #,
    "PostDiracTensor" -> postDiracTensors[#]
  |> & /@ finalPendingKeys
);
finalResults = runOrderedParallelTasks[
  finalTasks, processFinalTask, "color-sum/average"
];
Do[
  key = result["ChargeKey"];
  validateColorSummedTensor[
    result["ColorSummedUnaveragedTensor"],
    key <> " fresh color-summed tensor"
  ];
  validateColorSummedTensor[
    result["SpinColorAveragedTensor"],
    key <> " fresh averaged tensor"
  ];
  assert[
    result["SpinColorAveragedTensor"] ===
      incomingAverageFactor result["ColorSummedUnaveragedTensor"],
    key <> " fresh tensor failed the exact incoming-average audit"
  ];
  colorSummedUnaveragedTensors[key] =
    result["ColorSummedUnaveragedTensor"];
  spinColorAveragedTensors[key] =
    result["SpinColorAveragedTensor"];
  writeCache[
    finalCachePaths[key], key, "Final",
    <|
      "ColorSummedUnaveragedTensor" ->
        colorSummedUnaveragedTensors[key],
      "SpinColorAveragedTensor" -> spinColorAveragedTensors[key]
    |>
  ];
  Print["S06_CHECKPOINT: ", key, " final leaf count ",
    LeafCount[spinColorAveragedTensors[key]]];
,
  {result, finalResults}
];
colorSummedUnaveragedTensors = AssociationThread[
  chargeKeys, Lookup[colorSummedUnaveragedTensors, chargeKeys]
];
spinColorAveragedTensors = AssociationThread[
  chargeKeys, Lookup[spinColorAveragedTensors, chargeKeys]
];
assert[
  Keys[colorSummedUnaveragedTensors] === chargeKeys &&
    Keys[spinColorAveragedTensors] === chargeKeys,
  "final tensors lost their required charge-key order"
];

Do[
  validatePostDiracTensor[
    postDiracTensors[key], key <> " final post-Dirac tensor"
  ];
  validateColorSummedTensor[
    colorSummedUnaveragedTensors[key],
    key <> " final color-summed tensor"
  ];
  validateColorSummedTensor[
    spinColorAveragedTensors[key],
    key <> " final averaged tensor"
  ];
  assert[
    spinColorAveragedTensors[key] ===
      incomingAverageFactor colorSummedUnaveragedTensors[key],
    key <> " failed the final exact incoming-average audit"
  ];
,
  {key, chargeKeys}
];

postDiracLeafCounts = LeafCount /@ postDiracTensors;
colorSummedUnaveragedLeafCounts =
  LeafCount /@ colorSummedUnaveragedTensors;
spinColorAveragedLeafCounts = LeafCount /@ spinColorAveragedTensors;
closeS06Kernels[];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "S05SourceHashValidated" -> True,
  "S05ResultHashValidated" -> True,
  "S05UpstreamBindingsValidated" -> True,
  "AllThirtyFiveS05ChecksValidated" -> True,
  "ExactThreeChargeTensorKeysPreserved" ->
    (Keys[spinColorAveragedTensors] === chargeKeys),
  "EveryInputHasFourExpectedSpinors" -> True,
  "EveryInputHasExplicitFundamentalColorData" -> True,
  "ExactThreeBodyKinematicsInstalled" -> And @@ Values[kinematicChecks],
  "ExactlyThreeEngine15WorkersLaunched" ->
    (launchedParallelKernelCount === requestedParallelKernelCount),
  "ParallelResultOrderDeterministic" -> (parallelOrderProbe === chargeKeys),
  "OnlyMainKernelWritesCaches" -> True,
  "AllFourExternalFermionSpinsSummedPerChargeTensor" -> True,
  "AllDDiracTracesEvaluatedPerChargeTensor" -> True,
  "AllInitialAndFinalFundamentalColorsSummedPerChargeTensor" -> True,
  "PaperIncomingSpinAverageOneHalfAppliedExactlyOnce" ->
    (paperIncomingSpinAverage === 1/2),
  "IncomingFundamentalColorAverageOneOverNcAppliedExactlyOnce" ->
    (incomingFundamentalColorStateCount === FeynCalc`SUNN),
  "FinalStatesSummedNotAveraged" -> True,
  "ExactIncomingAverageRelationForEveryChargeTensor" ->
    And @@ (
      spinColorAveragedTensors[#] ===
        incomingAverageFactor colorSummedUnaveragedTensors[#] & /@
      chargeKeys
    ),
  "NoGluonOrPhotonPolarizationSumApplied" -> True,
  "PhotonIndexMuPreservedForEveryChargeTensor" ->
    And @@ (! FreeQ[spinColorAveragedTensors[#],
      FeynCalc`LorentzIndex[s05Mu, D]] & /@ chargeKeys),
  "PhotonIndexNuPreservedForEveryChargeTensor" ->
    And @@ (! FreeQ[spinColorAveragedTensors[#],
      FeynCalc`LorentzIndex[s05Nu, D]] & /@ chargeKeys),
  "AbsoluteScaleMuPowerPreservedExactlyOncePerChargeTensor" ->
    And @@ (hasExactlyExpectedScaleQ[spinColorAveragedTensors[#]] & /@
      chargeKeys),
  "NoSeparateMSBarSEpsilonAdded" -> True,
  "NoGenericChargeSymbolInsideCoefficientTensors" ->
    And @@ Flatten[Table[
      FreeQ[spinColorAveragedTensors[key], charge],
      {key, chargeKeys}, {charge, genericChargeSymbols}
    ]],
  "PhysicalOrderedFlavorChargeAssemblyDeferred" -> True,
  "NoSymmetryFactorApplied" -> True,
  "VirtualContributionAbsent" -> True,
  "NoProjectorOrPhaseSpaceOperationApplied" -> True,
  "NoFactorizationOrSubtractionApplied" -> True,
  "NoLoopOrRegulatorDataIntroduced" ->
    FreeQ[spinColorAveragedTensors, loopOrRegulatorPattern],
  "NoMachinePrecisionNumbers" -> FreeQ[spinColorAveragedTensors, _Real],
  "CachesBoundToProgramS05KeyAndInputTensor" -> True,
  "AtomicCacheAndResultProtocolConfigured" -> True,
  "S07AndLaterOperationsDeferred" -> True
|>;
assert[And @@ (TrueQ /@ Values[checks]),
  "at least one S06 validation check is not True"];

If[preflightOnly,
  Print["S06_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S06_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print["S06_DYNAMIC_PREFLIGHT_POST_DIRAC_LEAF_COUNTS=",
    InputForm[postDiracLeafCounts]];
  Print["S06_DYNAMIC_PREFLIGHT_COLOR_SUMMED_LEAF_COUNTS=",
    InputForm[colorSummedUnaveragedLeafCounts]];
  Print["S06_DYNAMIC_PREFLIGHT_FINAL_LEAF_COUNTS=",
    InputForm[spinColorAveragedLeafCounts]];
  Print["S06_DYNAMIC_PREFLIGHT_WORKERS=", launchedParallelKernelCount];
  Quit[0]
];

cacheProvenance = AssociationThread[
  chargeKeys,
  Table[
    <|
      "InputTensorSHA256" -> inputTensorHashes[key],
      "PostDiracPath" -> postDiracCachePaths[key],
      "PostDiracSHA256" -> fileSHA256[postDiracCachePaths[key]],
      "PostDiracCacheReused" -> postDiracCacheReused[key],
      "FinalPath" -> finalCachePaths[key],
      "FinalSHA256" -> fileSHA256[finalCachePaths[key]],
      "FinalCacheReused" -> finalCacheReused[key]
    |>,
    {key, chargeKeys}
  ]
];

s06Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "H_{q qPrime; q qbarPrime} charge-resolved spin/color-summed and incoming-averaged real tensors",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "NormalizationStatements" -> {
      "Eq. (14): incoming unpolarized spin factor 1/2 and final-state sum",
      "Eq. (19): projector contraction and phase-space integration are later"
    }
  |>,
  "Input" -> <|
    "S05SourcePath" -> s05SourcePath,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultPath" -> s05ResultPath,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "S05TensorPath" ->
      "ChargeResolvedBilinears/ScaleAttachedChargeTensors",
    "InputTensorSHA256ByChargeKey" -> inputTensorHashes
  |>,
  "ExternalStateBookkeeping" -> <|
    "Incoming" -> "q(p)",
    "Fragmenting" -> "qPrime(k1)",
    "Unobserved" -> {"q(k2)", "qbarPrime(k3)"},
    "AllFourFermionSpinsSummedPerChargeTensor" -> True,
    "AllInitialAndFinalColorsSummedPerChargeTensor" -> True,
    "PaperIncomingSpinAverage" -> paperIncomingSpinAverage,
    "IncomingFundamentalColorStateCount" ->
      incomingFundamentalColorStateCount,
    "InitialStateAverageFactor" -> incomingAverageFactor,
    "InitialStateAverageDenominator" -> initialAverageDenominator,
    "FinalStatesAreSummedNotAveraged" -> True
  |>,
  "KinematicConventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "MasslessExternalMomenta" -> {p, k1, k2, k3},
    "PhotonVirtuality" -> HoldForm[q^2 == -Q2],
    "ThreeBodyInvariants" ->
      {sHat, t1, t2, t3, u1, u2, u3, s12, s13, s23},
    "ScalarProductChecks" -> kinematicChecks
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> launchedParallelKernelCount,
    "WorkerVersions" -> workerVersions,
    "ChargeKeysProcessedIndependently" -> chargeKeys,
    "DeterministicResultOrder" -> True,
    "ConcurrentCacheWrites" -> False,
    "AlgebraWithinEachTensorSerial" -> True
  |>,
  "ChargeBookkeeping" -> <|
    "SeparatedTensorKeys" -> chargeKeys,
    "GenericChargeSymbols" -> genericChargeSymbols,
    "CoefficientTensorsRemainChargeFree" -> True,
    "PhysicalOrderedFlavorSumAppliedAtS06" -> False,
    "PhysicalAssemblyInstruction" ->
      s05["ChargeBookkeeping", "PhysicalAssemblyInstruction"]
  |>,
  "ScaleBookkeeping" -> <|
    "AbsoluteFactor" -> dimensionalScaleFactor,
    "AbsoluteExponent" -> dimensionalScaleExponent,
    "PowerPreservedExactlyOncePerChargeTensor" -> True,
    "SeparateMSBarSEpsilonApplied" -> False
  |>,
  "SymmetryBookkeeping" -> <|
    "DistinctFinalStateIdentities" ->
      {"qPrime(k1)", "q(k2)", "qbarPrime(k3)"},
    "DerivedFinalStateSymmetryFactors" ->
      s05["SymmetryAndAverageBookkeeping",
        "DerivedFinalStateSymmetryFactors"],
    "NontrivialSymmetryFactorRequired" -> False,
    "SymmetryFactorAppliedAtS06" -> False
  |>,
  "PhotonIndices" -> {s05Mu, s05Nu},
  "Tensors" -> <|
    "ColorSummedUnaveragedChargeTensors" ->
      colorSummedUnaveragedTensors,
    "SpinColorAveragedChargeTensors" -> spinColorAveragedTensors
  |>,
  "SpinColorAveragedTensors" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqprime;q_qbarPrime" -> spinColorAveragedTensors
    |>
  |>,
  "LeafCounts" -> <|
    "PostDirac" -> postDiracLeafCounts,
    "ColorSummedUnaveraged" -> colorSummedUnaveragedLeafCounts,
    "SpinColorAveraged" -> spinColorAveragedLeafCounts
  |>,
  "VirtualContributionAtThisOrder" -> <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" ->
      s05["VirtualContributionAtThisOrder", "SourceDisposition"],
    "ZeroMeaning" ->
      s05["VirtualContributionAtThisOrder", "ZeroMeaning"]
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "ByChargeKey" -> cacheProvenance,
    "AtomicMainKernelWritesOnly" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "gluon or photon polarization sums",
    "physical ordered q,qPrime flavor/charge assembly",
    "a final-state symmetry factor",
    "a virtual contribution",
    "projector contraction",
    "three-body phase-space normalization or integration",
    "MS-bar PDF/FF collinear factorization",
    "F-hat inversion or external-code comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized Hqqprime S07 may contract each Tensors/SpinColorAveragedChargeTensors entry separately with the paper Pg and PPP projectors. It must preserve all three charge keys and the scale/symmetry/virtual ledgers and must not integrate phase space or assemble physical flavors."
|>;

Print["S06_STAGE: atomically writing the Hqqprime S06 result"];
atomicPutAssociation[s06Result, s06ResultPath, stageVersion];

reloadedResult = Quiet @ Check[Get[s06ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input", "S05ResultSHA256"] === expectedS05ResultHash,
  "final s06_result failed status/stage/schema/provenance reload validation"
];
assert[And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "final s06_result contains a failed check"];
assert[
  Keys[reloadedResult["Tensors",
      "SpinColorAveragedChargeTensors"]] === chargeKeys,
  "reloaded result lost the charge-key order"
];
Do[
  assert[
    reloadedResult["Tensors", "ColorSummedUnaveragedChargeTensors", key] ===
        colorSummedUnaveragedTensors[key] &&
      reloadedResult["Tensors", "SpinColorAveragedChargeTensors", key] ===
        spinColorAveragedTensors[key] &&
      reloadedResult["Tensors", "SpinColorAveragedChargeTensors", key] ===
        incomingAverageFactor *
          reloadedResult[
            "Tensors", "ColorSummedUnaveragedChargeTensors", key
          ],
    key <> " failed exact tensor/reload/average validation"
  ];
,
  {key, chargeKeys}
];

Print["S06_SUCCESS"];
Print["S06_PROGRAM_SHA256=" <> programHash];
Print["S06_RESULT_PATH=" <> s06ResultPath];
Print["S06_RESULT_SHA256=" <> fileSHA256[s06ResultPath]];
Print["S06_CHECK_COUNT=", Length[checks]];
Print["S06_POST_DIRAC_LEAF_COUNTS=", InputForm[postDiracLeafCounts]];
Print["S06_FINAL_LEAF_COUNTS=", InputForm[spinColorAveragedLeafCounts]];
Print["S06_RESULT_BYTES=", FileByteCount[s06ResultPath]];

Quit[0];

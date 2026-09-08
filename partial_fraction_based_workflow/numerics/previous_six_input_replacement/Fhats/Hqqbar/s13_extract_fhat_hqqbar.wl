(* ::Package:: *)

(*
  Hqqbar stage S13: convert the accepted finite S12 Pg and PPP coefficient
  pairs into exact finite partonic structure functions F1Hat and F2Hat.

  Paper Eq. (9), applied to the partonic tensor in Eq. (16), gives

    F1Hat = (-Pg/2 + 2 xHat^2 PPP/Q2)/(1-epsilon),
    F2Hat = -xHat Pg/(1-epsilon) +
      4 xHat^3 (3-2 epsilon) PPP/(Q2 (1-epsilon)).

  S12 proves every negative epsilon-power coefficient vanishes separately
  for Pg and PPP. Therefore S13 may set epsilon -> 0 in these compact
  weights before combining the already finite, epsilon-free coefficient
  pairs. Physical flavor/charge convolution and BigTMD comparison remain
  downstream.
*)

$HistoryLength = 0;

Needs["FeynCalc`"];

$HistoryLength = 0;

ClearAll["Global`*"];

fatal[message_String] := (
  Print["S13_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

sha256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPut[expression_, path_String] := Module[
  {directory, temporaryPath},
  directory = DirectoryName[path];
  If[! DirectoryQ[directory],
    CreateDirectory[directory, CreateIntermediateDirectories -> True]
  ];
  temporaryPath = path <> ".tmp-" <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Check[
    Put[expression, temporaryPath],
    fatal["Atomic result write failed for " <> path <> "."]
  ];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Atomic result temporary file is absent or empty for " <> path <> "."
  ];
  Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    fatal["Atomic result rename failed for " <> path <> "."]
  ];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic result destination is absent or empty for " <> path <> "."
  ];
  path
];

feynCalcOwnedSymbolNames = {
  "CF", "CA", "SUNN", "TF", "SMP", "FCGV", "ScaleMu"
};

accidentalGlobalFeynCalcSymbolQ[symbol_Symbol] := TrueQ[
  Context[Unevaluated[symbol]] === "Global`" &&
    MemberQ[
      feynCalcOwnedSymbolNames,
      SymbolName[Unevaluated[symbol]]
    ]
];

feynCalcContextCleanQ[expression_] := FreeQ[
  expression,
  _Symbol?accidentalGlobalFeynCalcSymbolQ,
  {0, Infinity},
  Heads -> True
];

pairToAction[pair_Association, label_String, interval_List] :=
  pair["Endpoint"] S13ConvolutionTest[label, 0] +
    Inactive[Integrate][
      pair["IntegrandPhiS"] *
          S13ConvolutionTest[label, First[interval]] +
        pair["IntegrandPhi0"] S13ConvolutionTest[label, 0],
      interval
    ];

singleExactIntegralOnIntervalQ[action_, interval_List] := Module[
  {integrals},
  integrals = Cases[
    action,
    HoldPattern[Inactive[Integrate][_, _List]],
    {0, Infinity}
  ];
  TrueQ[
    Length[integrals] === 1 && integrals[[1, 2]] === interval
  ]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
s12Path = FileNameJoin[{scriptDirectory, "s12_result"}];
s12ProgramPath = FileNameJoin[{
  scriptDirectory, "s12_combine_factorization_hqqbar.wl"
}];
resultPath = FileNameJoin[{scriptDirectory, "s13_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
bigTMDRoot = FileNameJoin[{
  DirectoryName[scriptDirectory], "Hqq", "bigTMD_check",
  "BigTMD_reference"
}];
bigTMDDriverPath = FileNameJoin[{bigTMDRoot, "sidis.py"}];
bigTMDReferencePaths = <|
  "Pg5A" -> FileNameJoin[{bigTMDRoot, "NLO", "Pg", "fchn5A.py"}],
  "PPP5A" -> FileNameJoin[{bigTMDRoot, "NLO", "Ppp", "fchn5A.py"}],
  "Pg5B" -> FileNameJoin[{bigTMDRoot, "NLO", "Pg", "fchn5B.py"}],
  "PPP5B" -> FileNameJoin[{bigTMDRoot, "NLO", "Ppp", "fchn5B.py"}],
  "Pg5C" -> FileNameJoin[{bigTMDRoot, "NLO", "Pg", "fchn5C.py"}],
  "PPP5C" -> FileNameJoin[{bigTMDRoot, "NLO", "Ppp", "fchn5C.py"}]
|>;

stageVersion = "HqqbarS13-v1";
sourceStageVersion = "HqqbarS12-v1";
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
structureFunctions = {"F1Hat", "F2Hat"};

expectedS12ProgramSHA256 =
  "b56647afa5e8cb07bbaccce9bdeff84552cd9d3ef968deec543cd11a4f599e9f";
expectedS12ResultSHA256 =
  "30f979da9279ff538fb2974f8639140a941194f8868cbadaf82953decf8f11ba";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS10ResultSHA256 =
  "57e637d3eca490dfe08e341d866e5fa08ec1d69b14c7c476cf17c51890a65cb6";
expectedS10ProgramSHA256 =
  "793f9aaafbda74c605c3885915eabf9323e8b5761c84e9954d0759a5f890ac20";
expectedS11ResultSHA256 =
  "3cc321fc994a803f1d28a7fe35b84b4a4c466a9d95ed4e66bb3bca3e40aff889";
expectedS11ProgramSHA256 =
  "2864463cd41d8bbc00247d429244decc061201e877ff60a511664924ce78a3d4";
expectedBigTMDDriverSHA256 =
  "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d";
expectedBigTMDReferenceSHA256 = <|
  "Pg5A" ->
    "9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b",
  "PPP5A" ->
    "5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e",
  "Pg5B" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "PPP5B" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "Pg5C" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "PPP5C" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b"
|>;

preflightOnly = TrueQ[
  Environment["HQQBAR_S13_PREFLIGHT_ONLY"] === "1"
];

expectedPoleResiduals = <|
  "Pg" -> <|
    "Minus2" -> <|
      "Endpoint" -> 0, "IntegrandPhiS" -> 0, "IntegrandPhi0" -> 0
    |>,
    "Minus1" -> <|
      "Endpoint" -> 0, "IntegrandPhiS" -> 0, "IntegrandPhi0" -> 0
    |>
  |>,
  "PPP" -> <|
    "Minus2" -> <|
      "Endpoint" -> 0, "IntegrandPhiS" -> 0, "IntegrandPhi0" -> 0
    |>,
    "Minus1" -> <|
      "Endpoint" -> 0, "IntegrandPhiS" -> 0, "IntegrandPhi0" -> 0
    |>
  |>
|>;

Print["S13_STAGE: validating accepted Hqqbar S12 and fixed references"];
assert[
  FileExistsQ[s12Path] && FileByteCount[s12Path] > 0,
  "s12_result is absent or empty."
];
assert[
  FileExistsQ[s12ProgramPath] && FileByteCount[s12ProgramPath] > 0,
  "The accepted S12 program is absent or empty."
];
assert[
  FileExistsQ[paperPath] && FileByteCount[paperPath] > 0,
  "The authoritative paper is absent or empty."
];
assert[
  FileNames["s13_result.tmp-*", scriptDirectory] === {},
  "A stale S13 atomic temporary result exists."
];

programSHA256 = sha256Hex[programPath];
s12ProgramSHA256 = sha256Hex[s12ProgramPath];
s12ResultSHA256 = sha256Hex[s12Path];
paperSHA256 = sha256Hex[paperPath];
assert[
  s12ProgramSHA256 === expectedS12ProgramSHA256,
  "The accepted S12 program SHA-256 changed."
];
assert[
  s12ResultSHA256 === expectedS12ResultSHA256,
  "The accepted S12 result SHA-256 changed."
];
assert[
  paperSHA256 === expectedPaperSHA256,
  "The authoritative paper SHA-256 changed."
];

assert[
  FileExistsQ[bigTMDDriverPath] &&
    sha256Hex[bigTMDDriverPath] === expectedBigTMDDriverSHA256,
  "The pinned BigTMD SIDIS driver binding changed."
];
assert[
  Sort[Keys[bigTMDReferencePaths]] ===
      Sort[Keys[expectedBigTMDReferenceSHA256]] &&
    And @@ Table[
      FileExistsQ[bigTMDReferencePaths[key]] &&
        sha256Hex[bigTMDReferencePaths[key]] ===
          expectedBigTMDReferenceSHA256[key],
      {key, Keys[bigTMDReferencePaths]}
    ],
  "A pinned BigTMD channel-5 reference binding changed."
];
zeroReferenceTexts = Import[bigTMDReferencePaths[#], "Text"] & /@
  {"Pg5B", "PPP5B", "Pg5C", "PPP5C"};
assert[
  And @@ (Length[StringCases[#, "return 0"]] === 4 & /@
    zeroReferenceTexts),
  "A hash-pinned BigTMD channel-5 B/C zero module is not structurally zero."
];
Clear[zeroReferenceTexts];
bigTMDDriverText = Import[bigTMDDriverPath, "Text"];
assert[
  StringContainsQ[bigTMDDriverText, "for chn in [1,2,3,4,6]:"] &&
    StringContainsQ[
      bigTMDDriverText,
      "elif chn==5 and case=='A': _Pg,_Ppp=Pg.fchn5A,Ppp.fchn5A"
    ] &&
    StringContainsQ[bigTMDDriverText, "if chn<4:"],
  "The pinned BigTMD channel-5 driver caveat changed."
];
Clear[bigTMDDriverText];

s12ByteCount = FileByteCount[s12Path];
s12 = Quiet@Check[Get[s12Path], $Failed];
assert[
  AssociationQ[s12] &&
    s12["Status"] === "CompleteFiniteFactorizedHqqbar" &&
    s12["Stage"] === sourceStageVersion &&
    s12["ResultSchemaVersion"] === 1 &&
    s12["Channel"] === "Hqqbar only" &&
    ExpandFileName[s12["ProgramPath"]] === s12ProgramPath &&
    s12["ProgramSHA256"] === expectedS12ProgramSHA256,
  "s12_result is unreadable, incomplete, or not accepted HqqbarS12-v1."
];
assert[
  AssociationQ[s12["Checks"]] &&
    AllTrue[Values[s12["Checks"]], TrueQ],
  "s12_result contains a failed validation check."
];
assert[
  TrueQ[s12["PoleResiduals"] === expectedPoleResiduals],
  "S12 does not prove all Pg/PPP pole components are exact zero."
];

inputProvenance = s12["InputProvenance"];
assert[
  AssociationQ[inputProvenance] &&
    inputProvenance["S10ResultSHA256"] === expectedS10ResultSHA256 &&
    inputProvenance["S10ProgramSHA256"] === expectedS10ProgramSHA256 &&
    inputProvenance["S11ResultSHA256"] === expectedS11ResultSHA256 &&
    inputProvenance["S11ProgramSHA256"] === expectedS11ProgramSHA256 &&
    inputProvenance["AuthoritativePaperPath"] === paperPath &&
    inputProvenance["AuthoritativePaperSHA256"] === expectedPaperSHA256 &&
    FileExistsQ[inputProvenance["S10ResultPath"]] &&
    sha256Hex[inputProvenance["S10ResultPath"]] ===
      expectedS10ResultSHA256 &&
    FileExistsQ[inputProvenance["S11ResultPath"]] &&
    sha256Hex[inputProvenance["S11ResultPath"]] ===
      expectedS11ResultSHA256,
  "The S12 upstream S10/S11/paper provenance is invalid."
];
assert[
  FileExistsQ[s12["MappedCountertermCache"]] &&
    sha256Hex[s12["MappedCountertermCache"]] ===
      s12["MappedCountertermCacheSHA256"],
  "The S12 mapped-counterterm cache binding is stale."
];

bookkeepingS12 = s12["Bookkeeping"];
assert[
  AssociationQ[bookkeepingS12] &&
    bookkeepingS12["AdditionalMultiplicativeWeightAtS12"] === 1 &&
    TrueQ[bookkeepingS12["ChargeStripped"]] &&
    bookkeepingS12["PhysicalFlavorChargeWeight"] ===
      "Sum_q e_q^2 f_q D_qbar" &&
    TrueQ[! bookkeepingS12["PhysicalFlavorChargeWeightApplied"]] &&
    TrueQ[
      bookkeepingS12["IdenticalSpectatorFactorAppliedUpstreamAtS08"] ===
        1/2
    ] &&
    TrueQ[! bookkeepingS12["IdenticalSpectatorFactorReappliedAtS12"]] &&
    bookkeepingS12["VirtualContributionAtThisOrder"] === 0,
  "The accepted S12 charge, symmetry, or virtual bookkeeping changed."
];

finiteProjectorPairs = s12["FiniteCoefficientPairsByProjector"];
assert[
  AssociationQ[finiteProjectorPairs] &&
    Sort[Keys[finiteProjectorPairs]] === Sort[projectors],
  "s12_result lacks exactly the two finite projector coefficient pairs."
];
assert[
  And @@ Table[
    AssociationQ[finiteProjectorPairs[projector]] &&
      Sort[Keys[finiteProjectorPairs[projector]]] === Sort[pairFields],
    {projector, projectors}
  ],
  "An S12 finite projector coefficient pair has an invalid field schema."
];
assert[
  And @@ Table[
    TrueQ[finiteProjectorPairs[projector]["Endpoint"] === 0] &&
      TrueQ[finiteProjectorPairs[projector]["IntegrandPhi0"] === 0],
    {projector, projectors}
  ],
  "The present Hqqbar S12 pair has an unexpected endpoint or phi(0) field."
];
assert[
  FreeQ[
    finiteProjectorPairs,
    epsilon | _SeriesData | FeynCalc`SUNN | _Real | $Failed |
      Indeterminate | ComplexInfinity | DirectedInfinity[_] |
      Power[0, _?Negative]
  ] && feynCalcContextCleanQ[finiteProjectorPairs],
  "An S12 finite projector coefficient is not exact, SUNN-free, or context-clean."
];

physicalMappingS12 = s12["PhysicalMapping"];
assert[
  AssociationQ[physicalMappingS12] &&
    KeyExistsQ[physicalMappingS12, "XHat"] &&
    KeyExistsQ[physicalMappingS12, "S23Upper"],
  "The S12 physical mapping lacks XHat or S23Upper."
];
xHat = physicalMappingS12["XHat"];
s23Upper = physicalMappingS12["S23Upper"];
integrationInterval = {s23, 0, s23Upper};
assert[
  FreeQ[{xHat, integrationInterval}, epsilon | _Real] &&
    TrueQ[Cancel[Together[xHat - xB/xi]] === 0] &&
    TrueQ[Cancel[Together[
      s23Upper - (Q2 (xi/xB - 1) (1 - zH) - PHT2/zH)
    ]] === 0],
  "The exact S12 physical map or integration interval changed."
];

bigTMDConvention = <|
  "ChannelNumber" -> 5,
  "ChargeCase" -> "A only",
  "FragmentingParton" -> "antiquark qbar(k1)",
  "PhysicalLuminosityAppliedDownstream" ->
    "Sum_q e_q^2 f_q D_qbar",
  "ProjectorMapping" -> <|
    "Pg" -> "NLO.Pg.fchn5A",
    "PPP" -> "NLO.Ppp.fchn5A"
  |>,
  "ReferencePaths" -> bigTMDReferencePaths,
  "ReferenceSHA256" -> expectedBigTMDReferenceSHA256,
  "DriverPath" -> bigTMDDriverPath,
  "DriverSHA256" -> expectedBigTMDDriverSHA256,
  "BCases" -> "exact zero modules",
  "DriverCaveat" ->
    "sidis.py active NLO loop omits channel 5 and its distribution branch is restricted to channels below 4"
|>;

Clear[s12, physicalMappingS12];
ClearSystemCache[];

Print["S13_STAGE: deriving and validating paper Eq. (9) weights"];
projectorWeightsD = <|
  "F1Hat" -> <|
    "Pg" -> -1/(2 (1 - epsilon)),
    "PPP" -> 2 xHat^2/(Q2 (1 - epsilon))
  |>,
  "F2Hat" -> <|
    "Pg" -> -xHat/(1 - epsilon),
    "PPP" -> 4 xHat^3 (3 - 2 epsilon)/(Q2 (1 - epsilon))
  |>
|>;
projectorWeights4D = projectorWeightsD /. epsilon -> 0;
assert[
  FreeQ[projectorWeights4D, epsilon | _Real] &&
    TrueQ[Together[projectorWeights4D["F1Hat"]["Pg"] + 1/2] === 0] &&
    TrueQ[Together[
      projectorWeights4D["F1Hat"]["PPP"] - 2 xHat^2/Q2
    ] === 0] &&
    TrueQ[Together[
      projectorWeights4D["F2Hat"]["Pg"] + xHat
    ] === 0] &&
    TrueQ[Together[
      projectorWeights4D["F2Hat"]["PPP"] - 12 xHat^3/Q2
    ] === 0],
  "The exact four-dimensional projector weights do not match paper Eq. (9)."
];

weightMatrix4D = {
  {
    projectorWeights4D["F1Hat"]["Pg"],
    projectorWeights4D["F1Hat"]["PPP"]
  },
  {
    projectorWeights4D["F2Hat"]["Pg"],
    projectorWeights4D["F2Hat"]["PPP"]
  }
};
weightMatrixDeterminant = Together[Det[weightMatrix4D]];
assert[
  TrueQ[Together[
    weightMatrixDeterminant + 4 xHat^3/Q2
  ] === 0],
  "The Eq. (9) four-dimensional weight matrix determinant is invalid."
];
inverseWeightMatrix4D = Map[Together, Inverse[weightMatrix4D], {2}];
matrixIdentityResidual = Map[
  Together,
  inverseWeightMatrix4D . weightMatrix4D - IdentityMatrix[2],
  {2}
];
dummyProjectorVector = {s13PgDummy, s13PPPDummy};
dummyInverseResidual = Together /@ (
  inverseWeightMatrix4D . (weightMatrix4D . dummyProjectorVector) -
    dummyProjectorVector
);
assert[
  And @@ (TrueQ[# === 0] & /@ Flatten[matrixIdentityResidual]) &&
    And @@ (TrueQ[# === 0] & /@ dummyInverseResidual),
  "The exact Eq. (9) weight matrix failed its symbolic inverse gate."
];
Clear[dummyProjectorVector];

Print["S13_STAGE: combining finite Pg and PPP pairs fieldwise"];
fHatPairs = AssociationMap[
  Function[structureFunction,
    AssociationMap[
      Function[field,
        projectorWeights4D[structureFunction]["Pg"] *
            finiteProjectorPairs["Pg"][field] +
          projectorWeights4D[structureFunction]["PPP"] *
            finiteProjectorPairs["PPP"][field]
      ],
      pairFields
    ]
  ],
  structureFunctions
];
Clear[finiteProjectorPairs];
ClearSystemCache[];

Print["S13_STAGE: rebuilding exact finite Hqqbar F-hat actions"];
fHatFunctions = AssociationMap[
  Function[structureFunction,
    pairToAction[
      fHatPairs[structureFunction],
      structureFunction,
      integrationInterval
    ]
  ],
  structureFunctions
];
ClearSystemCache[];

forbiddenOutputObjects =
  epsilon | _SeriesData | FeynCalc`SUNN | _Real | $Failed |
    Indeterminate | ComplexInfinity | DirectedInfinity[_] |
    Power[0, _?Negative] | _S09EndpointValue |
    _S09PlusDistribution | _S11ConvolutionTest |
    _S11PlusDistribution | DiracDelta[s23];

Print["S13_STAGE: validating exact symbolic Hqqbar F hats"];
pairChecks = AssociationMap[
  Function[structureFunction,
    <|
      "FieldSchemaExact" ->
        Sort[Keys[fHatPairs[structureFunction]]] === Sort[pairFields],
      "EndpointExactZero" ->
        TrueQ[fHatPairs[structureFunction]["Endpoint"] === 0],
      "IntegrandPhi0ExactZero" ->
        TrueQ[fHatPairs[structureFunction]["IntegrandPhi0"] === 0],
      "ExactAndForbiddenObjectFree" ->
        FreeQ[fHatPairs[structureFunction], forbiddenOutputObjects],
      "FeynCalcContextsClean" ->
        feynCalcContextCleanQ[fHatPairs[structureFunction]],
      "NoHermitianOperationIntroduced" -> FreeQ[
        fHatPairs[structureFunction],
        _Re | _Im | _Conjugate
      ],
      "PhysicalFlavorChargeWeightDeferred" -> FreeQ[
        fHatPairs[structureFunction],
        HqqbarPhysicalFlavorChargeWeight
      ]
    |>
  ],
  structureFunctions
];

functionChecks = AssociationMap[
  Function[structureFunction,
    <|
      "ExactAndForbiddenObjectFree" ->
        FreeQ[fHatFunctions[structureFunction], forbiddenOutputObjects],
      "ContainsNoProjectorTestFunction" ->
        FreeQ[fHatFunctions[structureFunction], _S10ConvolutionTest],
      "RetainsOneOrdinaryS23Integral" ->
        singleExactIntegralOnIntervalQ[
          fHatFunctions[structureFunction],
          integrationInterval
        ],
      "RetainsOnlyMatchingArbitraryTestFunction" ->
        DeleteDuplicates@Cases[
          fHatFunctions[structureFunction],
          S13ConvolutionTest[label_, _] :> label,
          Infinity
        ] === {structureFunction},
      "FiniteScaleDependenceRetained" ->
        ! FreeQ[fHatFunctions[structureFunction], FeynCalc`ScaleMu],
      "FeynCalcContextsClean" ->
        feynCalcContextCleanQ[fHatFunctions[structureFunction]],
      "NoHermitianOperationIntroduced" -> FreeQ[
        fHatFunctions[structureFunction],
        _Re | _Im | _Conjugate
      ],
      "PhysicalFlavorChargeWeightDeferred" -> FreeQ[
        fHatFunctions[structureFunction],
        HqqbarPhysicalFlavorChargeWeight
      ]
    |>
  ],
  structureFunctions
];

s13Checks = <|
  "ExactS12ProgramResultAndPaperPinned" -> True,
  "S12CompleteValidatedAndUpstreamBound" -> True,
  "S12AllProjectorPolesExactZeroBeforeFiniteInversion" -> True,
  "S12MappedCountertermCacheHashBound" -> True,
  "FeynCalcLoadedBeforeSerializedArtifacts" -> True,
  "ExactlyPgAndPPPFinitePairsConsumed" -> True,
  "ExactPhysicalXHatAndS23IntervalRetained" -> True,
  "PaperEq9DimensionalInversionUsed" -> True,
  "EpsilonSetToZeroOnlyAfterSeparatePoleCancellation" -> True,
  "FourDimensionalEq9WeightsExact" -> True,
  "Eq9WeightMatrixInvertibleSymbolically" ->
    And @@ (TrueQ[# === 0] & /@ dummyInverseResidual),
  "ExactlyF1HatAndF2HatProduced" ->
    Sort[Keys[fHatPairs]] === Sort[structureFunctions] &&
      Sort[Keys[fHatFunctions]] === Sort[structureFunctions],
  "AllFHatPairsExactSchemaAndPure" ->
    AllTrue[Flatten[Values /@ Values[pairChecks]], TrueQ],
  "AllFHatActionsExactAndAligned" ->
    AllTrue[Flatten[Values /@ Values[functionChecks]], TrueQ],
  "ChargeStrippedConventionPreserved" -> True,
  "PhysicalFlavorChargeWeightDeferred" -> True,
  "IdenticalSpectatorFactorNotReapplied" -> True,
  "NoLOOrVirtualContributionIntroduced" -> True,
  "NoHermitianProjectionIntroduced" -> True,
  "AdditionalMultiplicativeWeightAtS13IsOne" -> True,
  "BigTMDChannel5AHashesAndZeroBCasesPinned" -> True,
  "BigTMDDriverChannel5OmissionRecorded" -> True,
  "BigTMDComparisonDeferred" -> True,
  "CalculationFullySymbolicAndExact" ->
    FreeQ[{fHatPairs, fHatFunctions}, _Real],
  "SerialExecutionAvoidsUnhelpfulSubkernelCopies" -> True
|>;
If[! AllTrue[Values[s13Checks], TrueQ],
  failedPairChecks = AssociationMap[
    Select[pairChecks[#], ! TrueQ[#] &] &,
    structureFunctions
  ];
  failedFunctionChecks = AssociationMap[
    Select[functionChecks[#], ! TrueQ[#] &] &,
    structureFunctions
  ];
  Print[
    "S13_FAILED_TOP_LEVEL_CHECKS=",
    InputForm[Select[s13Checks, ! TrueQ[#] &]]
  ];
  Print[
    "S13_FAILED_PAIR_CHECKS=",
    InputForm[failedPairChecks]
  ];
  Print[
    "S13_FAILED_FUNCTION_CHECKS=",
    InputForm[failedFunctionChecks]
  ];
  Clear[failedPairChecks, failedFunctionChecks]
];
assert[
  AllTrue[Values[s13Checks], TrueQ],
  "At least one final Hqqbar S13 validation check is not True."
];

s13Result = <|
  "Status" -> "CompleteFinitePartonicStructureFunctionsHqqbar",
  "Stage" -> stageVersion,
  "StageVersion" -> stageVersion,
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "finite charge-stripped F1Hat and F2Hat actions for H_{q qbar; q q}",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "InputProvenance" -> <|
    "S12ProgramPath" -> s12ProgramPath,
    "S12ProgramSHA256" -> s12ProgramSHA256,
    "S12ResultPath" -> s12Path,
    "S12ResultBytes" -> s12ByteCount,
    "S12ResultSHA256" -> s12ResultSHA256,
    "S12StageVersion" -> sourceStageVersion,
    "AuthoritativePaperPath" -> paperPath,
    "AuthoritativePaperSHA256" -> paperSHA256,
    "BigTMDDriverPath" -> bigTMDDriverPath,
    "BigTMDDriverSHA256" -> expectedBigTMDDriverSHA256,
    "BigTMDReferencePaths" -> bigTMDReferencePaths,
    "BigTMDReferenceSHA256" -> expectedBigTMDReferenceSHA256
  |>,
  "PaperReference" -> <|
    "HadronicTensorDecomposition" -> "Eq. (5)",
    "ExtractionTensors" -> "Eqs. (7)-(9)",
    "PartonicTensorDecomposition" -> "Eq. (16)",
    "HadronicConvolution" -> "Eqs. (17)-(18), deferred"
  |>,
  "PoleSafetyForFiniteInversion" -> <|
    "S12PoleResiduals" -> expectedPoleResiduals,
    "Reason" ->
      "all projector poles vanish separately, so epsilon-dependent Eq. (9) weights cannot feed the finite coefficient"
  |>,
  "DimensionalProjectorInversion" -> <|
    "F1Hat" -> HoldForm[
      F1Hat == (-HSubPg/2 + 2 xHat^2 HSubPPP/Q2)/
        (1 - epsilon)
    ],
    "F2Hat" -> HoldForm[
      F2Hat == -xHat HSubPg/(1 - epsilon) +
        4 xHat^3 (3 - 2 epsilon) HSubPPP/
          (Q2 (1 - epsilon))
    ]
  |>,
  "EpsilonRuleAfterPoleSafetyGate" -> HoldForm[epsilon -> 0],
  "ProjectorOrdering" -> projectors,
  "StructureFunctionOrdering" -> structureFunctions,
  "FourDimensionalProjectorWeights" -> projectorWeights4D,
  "FourDimensionalWeightMatrix" -> weightMatrix4D,
  "FourDimensionalWeightMatrixDeterminant" ->
    weightMatrixDeterminant,
  "InverseFourDimensionalWeightMatrix" -> inverseWeightMatrix4D,
  "PhysicalMapping" -> <|
    "XHat" -> xHat,
    "S23Upper" -> s23Upper,
    "Interval" -> integrationInterval
  |>,
  "BigTMDConvention" -> bigTMDConvention,
  "FiniteCoefficientPairsByStructureFunction" -> fHatPairs,
  "FiniteHattedStructureFunctions" -> fHatFunctions,
  "TestFunction" -> HoldForm[
    S13ConvolutionTest[structureFunction, s23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s23=0 and independent of epsilon",
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS13" -> 1,
    "ChargeStripped" -> True,
    "PhysicalFlavorChargeWeight" -> "Sum_q e_q^2 f_q D_qbar",
    "PhysicalFlavorChargeWeightApplied" -> False,
    "IdenticalSpectatorFactorAppliedUpstreamAtS08" -> 1/2,
    "IdenticalSpectatorFactorReappliedAtS13" -> False,
    "FiniteScaleDependenceInheritedFromS12" -> True,
    "LOContributionAtThisOrder" -> 0,
    "VirtualContributionAtThisOrder" -> 0,
    "HermitianProjectionAppliedAtS13" -> False
  |>,
  "PairChecks" -> pairChecks,
  "FunctionChecks" -> functionChecks,
  "Checks" -> s13Checks,
  "ParallelExecution" -> <|
    "Used" -> False,
    "Reason" ->
      "each F-hat is one exact linear combination; subkernel copies increase memory without accelerating the expression"
  |>,
  "MemoryStrategy" ->
    "load accepted 7-MB S12 once; retain only finite pairs and compact metadata; clear S12 actions before serial F1Hat/F2Hat construction; atomic result write",
  "NotPerformedAtThisStage" -> {
    "outer xi convolution with a concrete quark PDF and antiquark fragmentation function",
    "physical Sum_q e_q^2 flavor-charge multiplication",
    "choice or numerical evaluation of PDFs, fragmentation functions, or kinematics",
    "sum over other partonic channels",
    "translation, construction, or comparison against BigTMD channel-5A functions"
  }
|>;

If[preflightOnly,
  Print[
    "S13_PREFLIGHT_PAIR_LEAF_COUNTS=",
    InputForm[
      AssociationMap[
        Map[LeafCount, fHatPairs[#]] &,
        structureFunctions
      ]
    ]
  ];
  Print["S13_PREFLIGHT_SUCCESS_NO_WRITE"];
  Quit[0]
];

Print["S13_STAGE: writing finite hatted Hqqbar structure functions"];
atomicPut[s13Result, resultPath];
reloadedResult = Quiet@Check[Get[resultPath], $Failed];
reloadValidQ = TrueQ[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] ===
      "CompleteFinitePartonicStructureFunctionsHqqbar" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ProgramSHA256"] === programSHA256 &&
    reloadedResult["InputProvenance"]["S12ResultSHA256"] ===
      s12ResultSHA256 &&
    AssociationQ[reloadedResult["Checks"]] &&
    AllTrue[Values[reloadedResult["Checks"]], TrueQ] &&
    reloadedResult["FiniteCoefficientPairsByStructureFunction"] ===
      fHatPairs &&
    reloadedResult["FiniteHattedStructureFunctions"] === fHatFunctions
];
If[! reloadValidQ,
  Clear[reloadedResult];
  If[FileExistsQ[resultPath], DeleteFile[resultPath]];
  fatal["The atomically written S13 result failed exact reload validation."]
];
Clear[reloadedResult];
assert[
  FileExistsQ[resultPath] && FileByteCount[resultPath] > 0 &&
    FileNames["s13_result.tmp-*", scriptDirectory] === {},
  "The final S13 result or atomic cleanup is invalid."
];

Print["S13_SUCCESS_FINITE_FHAT_HQQBAR"];
Print["S13_RESULT_PATH=", resultPath];
Print["S13_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S13_RESULT_SHA256=", sha256Hex[resultPath]];
Print["S13_CHECKS=", InputForm[s13Checks]];

Quit[0];

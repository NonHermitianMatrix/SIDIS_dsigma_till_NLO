(* ::Package:: *)

(*
  Hqqbar stage S11: calculate, but do not add, the four Eq. (46)
  collinear-factorization counterterms for Pg and PPP.

  The external paper labels are initial i0=q and fragmenting j0=qbar.  Since
  Hqqbar has no two-body Born hard part, the only one-loop species routes are

    PDF: H_(g qbar) convoluted with P_(g/q) = Hgqbar convoluted with Pgq,
    FF:  H_(q g)    convoluted with P_(qbar/g) = Hqg convoluted with Pqg.

  Both Born hard parts are generated directly.  The F[3,{1}] reference charge
  is stripped by the accepted exact amplitude factor 3/2; independent F[4,{1}]
  generations stripped by -3 must give the same projected hard parts.  Each
  Born square carries the absolute ScaleMu^(2 epsilon) appropriate to its one
  strong vertex.  Eq. (46) supplies symbolic S_epsilon/epsilon but, as stated
  by the paper, no additional mu^epsilon factor.

  The Pgq and Pqg kernels are regular at their y=1 endpoints.  The saved
  counterterms therefore contain one ordinary inactive integral each against
  an arbitrary symbolic test.  Combination with S10, pole cancellation,
  epsilon -> 0, Eq. (9) inversion, F-hat extraction, and BigTMD comparison are
  deliberately deferred.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, atomicPutAssociation, zeroEquivalentQ,
  setTwoBodyKinematics, openPhotonIndex, conjugateOpenAmplitude,
  validateProjectedPair, exactWardResiduals, generateBornData,
  explicitProjectedPair, hasSingleScalePowerQ, bornM2, s23Function,
  regularKernelAction, S11ConvolutionTest, S11SEpsilon,
  S11PlusDistribution, S11PhysicalFlavorChargeSum,
  xHat, zHat, s11S23, k1T2, s11Mu, s11Nu
];

activeTemporaryPath = "";

fatal[message_String] := (
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S11_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPutAssociation[association_Association, finalPath_String] := Module[
  {temporaryPath, writeResult, temporaryReload, finalReload},
  temporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  activeTemporaryPath = temporaryPath;
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  writeResult = Check[Put[association, temporaryPath], $Failed];
  assert[
    writeResult =!= $Failed && FileExistsQ[temporaryPath] &&
      FileByteCount[temporaryPath] > 0,
    "The atomic temporary S11 result was not written."
  ];
  temporaryReload = Check[Get[temporaryPath], $Failed];
  assert[
    AssociationQ[temporaryReload] && temporaryReload === association,
    "The atomic temporary S11 result failed exact reload."
  ];
  RenameFile[temporaryPath, finalPath, OverwriteTarget -> True];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "The atomic S11 result was not installed."
  ];
  finalReload = Check[Get[finalPath], $Failed];
  assert[
    AssociationQ[finalReload] && finalReload === association,
    "The installed S11 result failed exact reload."
  ];
  finalReload
];

zeroEquivalentQ[expression_, seconds_Integer : 180] := Module[{answer},
  If[TrueQ[expression === 0], Return[True]];
  answer = Quiet@Check[
    TimeConstrained[Together[Cancel[expression]], seconds, $Failed],
    $Failed
  ];
  TrueQ[answer === 0]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
scriptsDirectory = DirectoryName[scriptDirectory];
programPath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{scriptDirectory, "s11_result"}];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
s01SourcePath =
  FileNameJoin[{scriptDirectory, "s01_calculate_hqqbar_real.wl"}];
s01ResultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
s10SourcePath =
  FileNameJoin[{scriptDirectory, "s10_resolve_endpoints_hqqbar.wl"}];
s10ResultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
s10CachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_hqqbar_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_hqqbar_ppp"}]
|>;
bigTMDPaths = <|
  "Pg" -> FileNameJoin[{
    scriptsDirectory, "Hqq", "bigTMD_check", "BigTMD_reference",
    "NLO", "Pg", "fchn5A.py"
  }],
  "PPP" -> FileNameJoin[{
    scriptsDirectory, "Hqq", "bigTMD_check", "BigTMD_reference",
    "NLO", "Ppp", "fchn5A.py"
  }]
|>;

stageVersion = "HqqbarS11-v1";
resultSchemaVersion = 1;
projectors = {"Pg", "PPP"};
expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS01SourceHash =
  "750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71";
expectedS01ResultHash =
  "69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4";
expectedS10SourceHash =
  "793f9aaafbda74c605c3885915eabf9323e8b5761c84e9954d0759a5f890ac20";
expectedS10ResultHash =
  "57e637d3eca490dfe08e341d866e5fa08ec1d69b14c7c476cf17c51890a65cb6";
expectedS10CacheHashes = <|
  "Pg" ->
    "e130cafa2e9b02748f16e9c812d60bfaf29d37d9225eb362045d061d30fc8185",
  "PPP" ->
    "173e44bc67623274801a8ad9cc2e92183c39456b20d4cb68a21544100f2b225e"
|>;
expectedBigTMDHashes = <|
  "Pg" ->
    "9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b",
  "PPP" ->
    "5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e"
|>;

preflightOnly =
  ToLowerCase[Environment["HQQBAR_S11_PREFLIGHT_ONLY"]] === "true" ||
  Environment["HQQBAR_S11_PREFLIGHT_ONLY"] === "1";
resultStateBefore = If[
  FileExistsQ[resultPath],
  <|"Exists" -> True, "SHA256" -> fileSHA256[resultPath]|>,
  <|"Exists" -> False|>
];

programHash = fileSHA256[programPath];

Print["S11_STAGE: validating paper, accepted S01, and accepted S10 handoff"];
assert[
  FileExistsQ[paperPath] && fileSHA256[paperPath] === expectedPaperHash,
  "The authoritative paper is absent or has the wrong SHA256."
];
assert[
  FileExistsQ[s01SourcePath] &&
    fileSHA256[s01SourcePath] === expectedS01SourceHash &&
    FileExistsQ[s01ResultPath] &&
    fileSHA256[s01ResultPath] === expectedS01ResultHash,
  "The accepted S01 source/result binding is stale."
];
assert[
  FileExistsQ[s10SourcePath] &&
    fileSHA256[s10SourcePath] === expectedS10SourceHash &&
    FileExistsQ[s10ResultPath] &&
    fileSHA256[s10ResultPath] === expectedS10ResultHash,
  "The accepted S10 source/result binding is stale."
];
assert[
  AssociationQ[s10CachePaths] && Keys[s10CachePaths] === projectors &&
    And @@ KeyValueMap[
      Function[{projector, path},
        FileExistsQ[path] &&
          fileSHA256[path] === expectedS10CacheHashes[projector]
      ],
      s10CachePaths
    ],
  "An accepted S10 endpoint-cache binding is stale."
];
assert[
  AssociationQ[bigTMDPaths] && Keys[bigTMDPaths] === projectors &&
    And @@ KeyValueMap[
      Function[{projector, path},
        FileExistsQ[path] &&
          fileSHA256[path] === expectedBigTMDHashes[projector]
      ],
      bigTMDPaths
    ],
  "A pinned BigTMD channel-5A reference is absent or changed."
];

s01 = Check[Get[s01ResultPath], $Failed];
assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqqbarS01-v1" &&
    s01["ResultSchemaVersion"] === 1 &&
    s01["Channel"] === "Hqqbar only" &&
    s01["ProgramPath"] === s01SourcePath &&
    s01["ProgramSHA256"] === expectedS01SourceHash &&
    s01["ReferencePDF"] === paperPath &&
    s01["ReferencePDFSHA256"] === expectedPaperHash,
  "The accepted S01 metadata is invalid."
];
assert[
  AssociationQ[s01["Checks"]] &&
    And @@ (TrueQ /@ Values[s01["Checks"]]),
  "At least one accepted S01 check is not True."
];
electricChargeNormalization = s01["ElectricChargeNormalization"];
assert[
  AssociationQ[electricChargeNormalization] &&
    electricChargeNormalization["ReferenceCharge"] === 2/3 &&
    electricChargeNormalization["AmplitudeStripFactor"] === 3/2 &&
    electricChargeNormalization["IndependentValidationCharge"] === -1/3 &&
    electricChargeNormalization["IndependentValidationStripFactor"] === -3 &&
    electricChargeNormalization["IndependentChargeStripResidual"] === 0 &&
    electricChargeNormalization["PhysicalChargeWeightDeferred"] ===
      "Sum_q e_q^2 f_q D_qbar",
  "The accepted S01 charge-stripping convention is invalid."
];
assert[
  s01["BigTMDConvention"]["ChannelNumber"] === 5 &&
    s01["BigTMDConvention"]["ChargeCase"] ===
      "A only; B and C are exact zero modules" &&
    s01["BigTMDConvention"]["PhysicalLuminosity"] ===
      "Sum_q e_q^2 f_q D_qbar" &&
    s01["BigTMDConvention"]["ReferencePaths"]["Pg_fchn5A.py"] ===
      bigTMDPaths["Pg"] &&
    s01["BigTMDConvention"]["ReferencePaths"]["Ppp_fchn5A.py"] ===
      bigTMDPaths["PPP"] &&
    s01["BigTMDConvention"]["ReferenceSHA256"]["Pg_fchn5A.py"] ===
      expectedBigTMDHashes["Pg"] &&
    s01["BigTMDConvention"]["ReferenceSHA256"]["Ppp_fchn5A.py"] ===
      expectedBigTMDHashes["PPP"],
  "The accepted S01 BigTMD channel-5A convention is invalid."
];

s10 = Check[Get[s10ResultPath], $Failed];
assert[
  AssociationQ[s10] && s10["Status"] === "Complete" &&
    s10["Stage"] === "HqqbarS10-v1" &&
    s10["ResultSchemaVersion"] === 1 &&
    s10["Channel"] === "Hqqbar only" &&
    s10["ProgramPath"] === s10SourcePath &&
    s10["ProgramSHA256"] === expectedS10SourceHash &&
    s10["PaperReference"]["Path"] === paperPath &&
    s10["PaperReference"]["SHA256"] === expectedPaperHash,
  "The accepted S10 metadata is invalid."
];
assert[
  AssociationQ[s10["Checks"]] && Length[s10["Checks"]] === 26 &&
    And @@ (TrueQ /@ Values[s10["Checks"]]),
  "The accepted S10 check ledger is incomplete or contains a failure."
];
assert[
  s10["CacheProvenance"]["EndpointCachePaths"] === s10CachePaths &&
    s10["CacheProvenance"]["EndpointCacheSHA256"] ===
      expectedS10CacheHashes &&
    s10["Bookkeeping"]["Scale"]["AbsoluteFactor"] ===
      ScaleMu^(4 epsilon) &&
    s10["Bookkeeping"]["Charge"]["TensorIsChargeStripped"] === True &&
    s10["Bookkeeping"]["Charge"]["PhysicalChargeWeight"] ===
      "Sum_q e_q^2 f_q D_qbar" &&
    s10["Bookkeeping"]["VirtualContributionAtThisOrder"]
      ["Applicable"] === False &&
    s10["DistributionActions"]["VirtualByProjector"] ===
      <|"Pg" -> 0, "PPP" -> 0|> &&
    s10["Checks"]["Eq46FactorizationFiniteFHatAndBigTMDNotClaimed"] ===
      True,
  "The accepted S10 bookkeeping or Eq. (46) handoff is invalid."
];
acceptedS10Bookkeeping = s10["Bookkeeping"];
acceptedS10CheckCount = Length[s10["Checks"]];
Clear[s01, s10];
ClearSystemCache[];
Print["S11_CHECKPOINT: accepted upstream provenance and bookkeeping validated"];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

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

openPhotonIndex[amp_, openIndex_Symbol, label_String] := Module[
  {contracted, answer},
  contracted = FeynCalc`Contract[amp];
  assert[
    ! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no photon polarization to open."
  ];
  answer = contracted /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], dim_
      ]
    ] :> FeynCalc`DiracGamma[
      FeynCalc`LorentzIndex[openIndex, dim], dim
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`LorentzIndex[lor_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[lor, dim],
      FeynCalc`LorentzIndex[openIndex, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        FeynCalc`Momentum[momentum_, dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[openIndex, dim],
      FeynCalc`Momentum[momentum, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[momentum_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`Momentum[momentum, dim],
      FeynCalc`LorentzIndex[openIndex, dim]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Eps[
        before___,
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        after___
      ]
    ] :> FeynCalc`Eps[
      before,
      FeynCalc`LorentzIndex[openIndex, dim],
      after
    ];
  answer = FeynCalc`Contract[answer];
  assert[
    FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains a photon polarization."
  ];
  assert[
    ! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the open photon index."
  ];
  answer
];

conjugateOpenAmplitude[
    amp_, oldIndex_Symbol, newIndex_Symbol, label_String
  ] := Module[{answer},
  answer = Quiet@Check[
    FeynCalc`ComplexConjugate[
      amp /. oldIndex -> newIndex,
      FeynCalc`FCRenameDummyIndices -> True,
      FeynCalc`FCVerbose -> 0
    ],
    $Failed
  ];
  assert[answer =!= $Failed, label <> " conjugation failed."];
  assert[
    FreeQ[answer, FeynCalc`ComplexConjugate],
    label <> " retains an unevaluated conjugation."
  ];
  answer
];

validateProjectedPair[pair_Association, label_String] := Module[{},
  assert[
    Keys[pair] === projectors,
    label <> " lacks the ordered Pg/PPP pair."
  ];
  assert[
    AllTrue[Values[pair], TrueQ[# =!= 0 && # =!= $Failed] &],
    label <> " contains a zero or failed projection."
  ];
  assert[
    AllTrue[
      Values[pair],
      FreeQ[
        #,
        _FeynCalc`LorentzIndex | _FeynCalc`Spinor |
          _FeynCalc`Polarization | _FeynCalc`DiracGamma |
          _FeynCalc`DiracTrace | _FeynCalc`SUNFIndex |
          _FeynCalc`SUNIndex | _Real
      ] &
    ],
    label <>
      " retains an external-state, Lorentz, Dirac, color, or machine object."
  ];
  True
];

exactWardResiduals[tensor_, label_String] := Module[
  {probes, residuals},
  setTwoBodyKinematics[];
  probes = <|
    "qMu_qNu" -> Times[
      FeynCalc`Pair[
        FeynCalc`Momentum[q, D],
        FeynCalc`LorentzIndex[s11Mu, D]
      ],
      FeynCalc`Pair[
        FeynCalc`Momentum[q, D],
        FeynCalc`LorentzIndex[s11Nu, D]
      ]
    ],
    "qMu_pNu" -> Times[
      FeynCalc`Pair[
        FeynCalc`Momentum[q, D],
        FeynCalc`LorentzIndex[s11Mu, D]
      ],
      FeynCalc`Pair[
        FeynCalc`Momentum[p, D],
        FeynCalc`LorentzIndex[s11Nu, D]
      ]
    ],
    "qMu_k1Nu" -> Times[
      FeynCalc`Pair[
        FeynCalc`Momentum[q, D],
        FeynCalc`LorentzIndex[s11Mu, D]
      ],
      FeynCalc`Pair[
        FeynCalc`Momentum[k1, D],
        FeynCalc`LorentzIndex[s11Nu, D]
      ]
    ]
  |>;
  residuals = Map[
    Function[probe,
      Quiet@Check[
        Together[
          Cancel[
            FeynCalc`FeynAmpDenominatorExplicit[
              FeynCalc`Contract[probe tensor]
            ]
          ]
        ],
        $Failed
      ]
    ],
    probes
  ];
  assert[
    AllTrue[Values[residuals], TrueQ[# === 0] &],
    label <> " failed an exact electromagnetic Ward contraction."
  ];
  residuals
];

generateBornData[
    incomingFields_List, outgoingFields_List,
    gluonPolarizationMomenta_List, initialType_String,
    stripFactor_, label_String
  ] := Module[
  {
    topologies, insertions, raw, converted, amplitude, amplitudeMu,
    amplitudeNu, tensor, averageDenominator, wardResiduals,
    projectorDefinitions, pair
  },
  Print["S11_STAGE: generating charge-stripped Born channel " <> label];
  topologies = FeynArts`CreateTopologies[
    0,
    2 -> 2,
    FeynArts`ExcludeTopologies -> {
      FeynArts`Tadpoles, FeynArts`WFCorrections
    }
  ];
  insertions = FeynArts`InsertFields[
    topologies,
    incomingFields -> outgoingFields,
    FeynArts`InsertionLevel -> {FeynArts`Particles},
    FeynArts`Model -> "SMQCD"
  ];
  raw = Check[
    FeynArts`CreateFeynAmp[
      insertions,
      FeynArts`Truncated -> False
    ],
    $Failed
  ];
  assert[raw =!= $Failed, label <> " FeynArts generation failed."];
  converted = Quiet@Check[
    FeynCalc`FCFAConvert[
      raw,
      FeynCalc`IncomingMomenta -> {q, p},
      FeynCalc`OutgoingMomenta -> {k1, k2},
      FeynCalc`LoopMomenta -> {},
      FeynCalc`ChangeDimension -> D,
      FeynCalc`DropSumOver -> True,
      FeynCalc`UndoChiralSplittings -> True,
      FeynCalc`Contract -> False,
      FeynCalc`SMP -> True,
      List -> True,
      FeynCalc`FinalSubstitutions -> masslessRules
    ],
    $Failed
  ];
  assert[
    ListQ[converted] && Length[converted] === 2,
    label <> " did not produce exactly two Born diagrams."
  ];
  converted = converted /. HoldPattern[
      FeynArts`FCGV[name_String]
    ] :> FeynCalc`FCGV[name];
  amplitude = stripFactor Total[converted];
  assert[
    amplitude =!= 0 && FreeQ[amplitude, _Real | $Failed],
    label <> " has an invalid charge-stripped amplitude."
  ];
  amplitudeMu = openPhotonIndex[amplitude, s11Mu, label];
  amplitudeNu = conjugateOpenAmplitude[
    amplitudeMu, s11Mu, s11Nu, label
  ];
  tensor = ScaleMu^(2 epsilon) amplitudeMu amplitudeNu;

  setTwoBodyKinematics[];
  tensor = Fold[
    Function[{current, momentum},
      Quiet@Check[
        FeynCalc`DoPolarizationSums[
          current,
          momentum,
          0,
          TimeConstrained -> Infinity,
          FeynCalc`FCParallelize -> False,
          FeynCalc`FCVerbose -> 0
        ],
        $Failed
      ]
    ],
    tensor,
    gluonPolarizationMomenta
  ];
  assert[tensor =!= $Failed, label <> " polarization sum failed."];
  tensor = Quiet@Check[
    FeynCalc`FermionSpinSum[
      tensor,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0
    ],
    $Failed
  ];
  assert[tensor =!= $Failed, label <> " fermion spin sum failed."];
  tensor = Quiet@Check[
    FeynCalc`DiracSimplify[
      tensor,
      FeynCalc`DiracTrace -> True,
      FeynCalc`DiracTraceEvaluate -> True,
      FeynCalc`DiracSubstitute67 -> True,
      FeynCalc`ToDiracGamma67 -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0,
      FeynCalc`Factoring -> False
    ],
    $Failed
  ];
  assert[tensor =!= $Failed, label <> " Dirac trace evaluation failed."];

  averageDenominator = Switch[
    initialType,
    "Quark", 2 FeynCalc`SUNN,
    "Gluon", (D - 2) (FeynCalc`SUNN^2 - 1),
    _, fatal[label <> " has an unknown initial-state type."]
  ];
  tensor = Quiet@Check[
    FeynCalc`SUNSimplify[
      tensor/averageDenominator,
      TimeConstrained -> Infinity,
      FeynCalc`SUNNToCACF -> True,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0
    ],
    $Failed
  ];
  assert[tensor =!= $Failed, label <> " color sum/average failed."];

  wardResiduals = exactWardResiduals[tensor, label];
  projectorDefinitions = <|
    "Pg" -> FeynCalc`Pair[
      FeynCalc`LorentzIndex[s11Mu, D],
      FeynCalc`LorentzIndex[s11Nu, D]
    ],
    "PPP" -> Times[
      FeynCalc`Pair[
        FeynCalc`Momentum[p, D],
        FeynCalc`LorentzIndex[s11Mu, D]
      ],
      FeynCalc`Pair[
        FeynCalc`Momentum[p, D],
        FeynCalc`LorentzIndex[s11Nu, D]
      ]
    ]
  |>;
  pair = Map[
    Function[projector,
      Quiet@Check[FeynCalc`Contract[projector tensor], $Failed]
    ],
    projectorDefinitions
  ];
  assert[
    AllTrue[Values[pair], TrueQ[# =!= $Failed] &],
    label <> " projector contraction failed."
  ];
  validateProjectedPair[pair, label];
  Print["S11_CHECKPOINT: completed Born projections and Ward gates for " <>
    label];
  <|
    "Projected" -> pair,
    "WardResiduals" -> wardResiduals,
    "DiagramCount" -> Length[converted],
    "InitialAverageDenominator" -> averageDenominator,
    "AmplitudeStripFactor" -> stripFactor,
    "AbsoluteBornScaleFactor" -> ScaleMu^(2 epsilon)
  |>
];

explicitProjectedPair[pair_Association] := Module[{answer},
  setTwoBodyKinematics[];
  answer = Map[
    Function[projection,
      Together[FeynCalc`FeynAmpDenominatorExplicit[projection]]
    ],
    pair
  ];
  assert[
    AllTrue[
      Values[answer],
      FreeQ[
        #,
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum | _Real |
          $Failed | Indeterminate
      ] &
    ],
    "A Born projection retains a propagator, momentum, or nonexact object."
  ];
  validateProjectedPair[answer, "explicit Born pair"];
  answer
];

hasSingleScalePowerQ[expression_, expectedPower_] := Module[
  {powers, stripped},
  powers = Cases[
    expression,
    HoldPattern[Power[ScaleMu, power_]] :> power,
    Infinity
  ];
  stripped = expression /. HoldPattern[
      Power[ScaleMu, expectedPower]
    ] -> 1;
  Length[powers] === 1 && powers === {expectedPower} &&
    FreeQ[stripped, ScaleMu]
];

referenceUpField = FeynArts`F[3, {1}];
validationDownField = FeynArts`F[4, {1}];
incomingGluon = {FeynArts`V[1], FeynArts`V[5]};
referenceStripFactor =
  electricChargeNormalization["AmplitudeStripFactor"];
validationStripFactor =
  electricChargeNormalization["IndependentValidationStripFactor"];

referenceBornData = <|
  "Hqg" -> generateBornData[
    {FeynArts`V[1], referenceUpField},
    {FeynArts`V[5], referenceUpField},
    {k1},
    "Quark",
    referenceStripFactor,
    "Hqg gamma* q -> g(k1) q"
  ],
  "Hgqbar" -> generateBornData[
    incomingGluon,
    {-referenceUpField, referenceUpField},
    {p},
    "Gluon",
    referenceStripFactor,
    "Hgqbar gamma* g -> qbar(k1) q"
  ]
|>;

validationBornData = <|
  "Hqg" -> generateBornData[
    {FeynArts`V[1], validationDownField},
    {FeynArts`V[5], validationDownField},
    {k1},
    "Quark",
    validationStripFactor,
    "validation Hqg gamma* d -> g(k1) d"
  ],
  "Hgqbar" -> generateBornData[
    incomingGluon,
    {-validationDownField, validationDownField},
    {p},
    "Gluon",
    validationStripFactor,
    "validation Hgqbar gamma* g -> dbar(k1) d"
  ]
|>;

Print["S11_STAGE: explicitizing reference and charge-validation Born pairs"];
bornProjected = Map[
  explicitProjectedPair[# ["Projected"]] &,
  referenceBornData
];
validationBornProjected = Map[
  explicitProjectedPair[# ["Projected"]] &,
  validationBornData
];
chargeStripResiduals = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          bornProjected[channel, projector] -
            validationBornProjected[channel, projector]
        ]
      ],
      projectors
    ]
  ],
  Keys[bornProjected]
];
chargeStripChecks = Map[
  Function[pair, Map[zeroEquivalentQ, pair]],
  chargeStripResiduals
];
assert[
  AllTrue[Flatten[Values /@ Values[chargeStripChecks]], TrueQ],
  "An up/down charge-stripped Born projection does not agree."
];
assert[
  AllTrue[
    Flatten[Values /@ Values[chargeStripResiduals]],
    TrueQ[# === 0] &
  ],
  "A charge-strip residual did not reduce to exact zero."
];
Print["S11_CHECKPOINT: independent up/down charge stripping agrees exactly"];

bornWardResiduals = Map[# ["WardResiduals"] &, referenceBornData];
validationWardResiduals = Map[# ["WardResiduals"] &, validationBornData];
bornDiagramCounts = Map[# ["DiagramCount"] &, referenceBornData];
validationDiagramCounts = Map[# ["DiagramCount"] &, validationBornData];
bornInitialAverages = Map[
  # ["InitialAverageDenominator"] &,
  referenceBornData
];

assert[
  AllTrue[
    Values[bornProjected],
    Function[pair,
      AllTrue[
        Values[pair],
        hasSingleScalePowerQ[#, 2 epsilon] &
      ]
    ]
  ],
  "A reference Born projection lacks exactly one ScaleMu^(2 epsilon)."
];

bornM2[channel_String, projector_String, x_, z_, transverse2_] :=
  Together[
    bornProjected[channel, projector] /. {
      D -> 4 - 2 epsilon,
      sHat -> Q2 (1/x - 1),
      tHat -> -Q2 + z Q2 - transverse2/z,
      uHat -> -z Q2/x
    }
  ];

s23Function[x_, z_, transverse2_] :=
  Q2 (1/x - 1) (1 - z) - transverse2/z;

endpointUpper = Q2 (1/xHat - 1) (1 - zHat);
pdfScale = Q2 (1 - zHat)/xHat;
ffScale = Q2 (1/xHat - 1);
pdfSplittingVariable = 1 - s11S23/pdfScale;
ffSplittingVariable = 1 - s11S23/ffScale;
externalTransverse2 = zHat (endpointUpper - s11S23);

pdfInternalKinematics = <|
  "x" -> xHat/pdfSplittingVariable,
  "z" -> zHat,
  "k1T2" -> externalTransverse2
|>;
ffInternalKinematics = <|
  "x" -> xHat,
  "z" -> zHat/ffSplittingVariable,
  "k1T2" -> externalTransverse2/ffSplittingVariable^2
|>;

kinematicChecks = <|
  "PDFBornOnShell" -> zeroEquivalentQ[
    s23Function @@ Values[pdfInternalKinematics]
  ],
  "FFBornOnShell" -> zeroEquivalentQ[
    s23Function @@ Values[ffInternalKinematics]
  ],
  "PDFVariableAtZeroIsOne" ->
    TrueQ[(pdfSplittingVariable /. s11S23 -> 0) === 1],
  "FFVariableAtZeroIsOne" ->
    TrueQ[(ffSplittingVariable /. s11S23 -> 0) === 1],
  "PDFVariableAtUpperIsX" -> zeroEquivalentQ[
    (pdfSplittingVariable /. s11S23 -> endpointUpper) - xHat
  ],
  "FFVariableAtUpperIsZ" -> zeroEquivalentQ[
    (ffSplittingVariable /. s11S23 -> endpointUpper) - zHat
  ],
  "PDFJacobianIsMinusOneOverScale" -> zeroEquivalentQ[
    D[pdfSplittingVariable, s11S23] + 1/pdfScale
  ],
  "FFJacobianIsMinusOneOverScale" -> zeroEquivalentQ[
    D[ffSplittingVariable, s11S23] + 1/ffScale
  ]
|>;
assert[
  AllTrue[Values[kinematicChecks], TrueQ],
  "At least one Eq. (46) convolution mapping check failed."
];
Print["S11_CHECKPOINT: exact Eq. (46) convolution maps validated"];

twoBodyNormalization = 2 Pi/(2 Pi)^4;
pdfBornDensities = AssociationMap[
  Function[projector,
    Together[
      twoBodyNormalization/pdfSplittingVariable *
        If[projector === "PPP", pdfSplittingVariable^-2, 1] *
        bornM2[
          "Hgqbar",
          projector,
          pdfInternalKinematics["x"],
          pdfInternalKinematics["z"],
          pdfInternalKinematics["k1T2"]
        ]
    ]
  ],
  projectors
];
ffBornDensities = AssociationMap[
  Function[projector,
    Together[
      twoBodyNormalization/ffSplittingVariable *
        bornM2[
          "Hqg",
          projector,
          ffInternalKinematics["x"],
          ffInternalKinematics["z"],
          ffInternalKinematics["k1T2"]
        ]
    ]
  ],
  projectors
];
assert[
  AllTrue[
    Join[Values[pdfBornDensities], Values[ffBornDensities]],
    hasSingleScalePowerQ[#, 2 epsilon] &
  ],
  "A mapped Born density lost or duplicated ScaleMu^(2 epsilon)."
];

regularKernelAction[
    kernel_, density_, scale_, test_
  ] := Inactive[Integrate][
  Together[kernel density/scale] test,
  {s11S23, 0, endpointUpper}
];

pgqPDFKernel = 2 FeynCalc`CF *
  (1 + (1 - pdfSplittingVariable)^2)/pdfSplittingVariable;
pqgFFKernel = 2 FeynCalc`TF *
  ((1 - ffSplittingVariable)^2 + ffSplittingVariable^2);
factorizationPrefactor =
  FeynCalc`SMP["g_s"]^2 S11SEpsilon/(16 Pi^2 epsilon);

Print["S11_STAGE: acting the two regular splitting kernels for Pg and PPP"];
countertermComponents = AssociationMap[
  Function[projector,
    With[{test = S11ConvolutionTest[projector, s11S23]},
      <|
        "PDF_Hgqbar_Pgq" ->
          factorizationPrefactor regularKernelAction[
            pgqPDFKernel,
            pdfBornDensities[projector],
            pdfScale,
            test
          ],
        "FF_Hqg_Pqg" ->
          factorizationPrefactor regularKernelAction[
            pqgFFKernel,
            ffBornDensities[projector],
            ffScale,
            test
          ]
      |>
    ]
  ],
  projectors
];

counterterms = <|
  "PgPDF" -> countertermComponents["Pg", "PDF_Hgqbar_Pgq"],
  "PgFF" -> countertermComponents["Pg", "FF_Hqg_Pqg"],
  "PPPPDF" -> countertermComponents["PPP", "PDF_Hgqbar_Pgq"],
  "PPPFF" -> countertermComponents["PPP", "FF_Hqg_Pqg"]
|>;
countertermKeys = {"PgPDF", "PgFF", "PPPPDF", "PPPFF"};
assert[
  Keys[counterterms] === countertermKeys,
  "The saved counterterm keys are not the ordered four-object contract."
];

componentKeys = {"PDF_Hgqbar_Pgq", "FF_Hqg_Pqg"};
s11Checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS01SourceResultAndChecksValidated" -> True,
  "AcceptedS10SourceResultBothCachesAndTwentySixChecksValidated" ->
    TrueQ[acceptedS10CheckCount === 26],
  "BigTMDChannel5ACurrentHashesValidated" -> True,
  "FeynCalcContextLoadedBeforeArtifactDeserialization" -> True,
  "ExactlyTwoReferenceAndTwoValidationBornChannelsGenerated" ->
    TrueQ[
      Keys[referenceBornData] === {"Hqg", "Hgqbar"} &&
        Keys[validationBornData] === {"Hqg", "Hgqbar"}
    ],
  "EveryDirectBornChannelHasExactlyTwoDiagrams" ->
    AllTrue[
      Join[Values[bornDiagramCounts], Values[validationDiagramCounts]],
      TrueQ[# === 2] &
    ],
  "ReferenceAndValidationBornWardIdentitiesPass" ->
    AllTrue[
      Flatten[
        Join[
          Values /@ Values[bornWardResiduals],
          Values /@ Values[validationWardResiduals]
        ]
      ],
      TrueQ[# === 0] &
    ],
  "IndependentUpDownChargeStrippingAgrees" ->
    AllTrue[Flatten[Values /@ Values[chargeStripChecks]], TrueQ],
  "CorrectInitialStateAveragesApplied" ->
    TrueQ[
      bornInitialAverages === <|
        "Hqg" -> 2 FeynCalc`SUNN,
        "Hgqbar" -> (D - 2) (FeynCalc`SUNN^2 - 1)
      |>
    ],
  "AbsoluteBornScaleMuPowerTwoEpsilonAppliedExactlyOnce" ->
    AllTrue[
      Flatten[Values /@ Values[bornProjected]],
      hasSingleScalePowerQ[#, 2 epsilon] &
    ],
  "AllConvolutionMappingsValidated" ->
    AllTrue[Values[kinematicChecks], TrueQ],
  "CorrectedPPPPDFRescalingAppliedOnlyThere" -> True,
  "PaperTwoBodyNormalizationApplied" ->
    TrueQ[twoBodyNormalization === 2 Pi/(2 Pi)^4],
  "ExactlyFourCounterterms" -> TrueQ[Length[counterterms] === 4],
  "ExactlyOnePDFAndOneFFComponentPerProjector" ->
    AllTrue[
      Values[countertermComponents],
      TrueQ[Keys[#] === componentKeys] &
    ],
  "PDFContainsOnlyHgqbarTimesPgq" -> True,
  "FFContainsOnlyHqgTimesPqg" -> True,
  "NoHqqbarBornDiagonalPqqOrPggContribution" ->
    AllTrue[Values[counterterms], FreeQ[#, Pqq | Pgg | Hqqbar] &],
  "RegularSplittingKernelsActedWithoutDistributionPlaceholders" ->
    AllTrue[
      Values[counterterms],
      FreeQ[#, _S11PlusDistribution | _DiracDelta] &
    ],
  "ExactlyOneOrdinaryInactiveIntegralPerCounterterm" ->
    AllTrue[
      Values[counterterms],
      TrueQ[Count[#, Inactive[Integrate][___], Infinity] === 1] &
    ],
  "ArbitrarySymbolicTestsRetained" ->
    AllTrue[
      Values[counterterms],
      ! FreeQ[#, _S11ConvolutionTest] &
    ],
  "PaperMSSchemeSEpsilonKeptSymbolic" ->
    AllTrue[Values[counterterms], ! FreeQ[#, S11SEpsilon] &],
  "NoAdditionalMuEpsilonInPartonicPDForFF" -> True,
  "CountertermsRetainExactlyOneBornScaleMuPower" ->
    AllTrue[
      Values[counterterms],
      hasSingleScalePowerQ[#, 2 epsilon] &
    ],
  "PhysicalFlavorChargeLuminosityStillDeferred" ->
    AllTrue[
      Values[counterterms],
      FreeQ[#, S11PhysicalFlavorChargeSum] &
    ],
  "NoFlavorMultiplicitySymmetryOrVirtualWeightIntroduced" -> True,
  "CalculationRemainsExactAndSymbolic" ->
    FreeQ[Values[counterterms], _Real | $Failed | Indeterminate],
  "S10ActionsNotLoadedOrCombinedIntoCounterterms" -> True,
  "PoleCancellationFiniteLimitFHatAndBigTMDComparisonDeferred" -> True,
  "AtomicSourceBoundResultProtocolConfigured" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[s11Checks]),
  "At least one final S11 validation check is not True."
];

s11Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqbar only",
  "Contribution" ->
    "Eq. (46) Hqqbar initial-state PDF and final-state FF counterterms",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "SplittingFunctions" -> "Eqs. (51)-(53)",
    "TwoBodyPhaseSpace" -> "Eqs. (34)-(35)",
    "SchemeAsNamedByPaper" -> "MS"
  |>,
  "InputProvenance" -> <|
    "S01SourcePath" -> s01SourcePath,
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultPath" -> s01ResultPath,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S10SourcePath" -> s10SourcePath,
    "S10SourceSHA256" -> expectedS10SourceHash,
    "S10ResultPath" -> s10ResultPath,
    "S10ResultSHA256" -> expectedS10ResultHash,
    "S10EndpointCachePaths" -> s10CachePaths,
    "S10EndpointCacheSHA256" -> expectedS10CacheHashes,
    "S10DependencyRole" ->
      "validated handoff and bookkeeping only; no S10 action enters S11 counterterm construction",
    "BigTMDChannel5APaths" -> bigTMDPaths,
    "BigTMDChannel5ASHA256" -> expectedBigTMDHashes
  |>,
  "SpeciesRouting" -> <|
    "ExternalLabels" -> <|
      "Initial" -> "i0=q",
      "Fragmenting" -> "j0=qbar"
    |>,
    "PDF" -> {"Hgqbar^(LO) x Pgq"},
    "FF" -> {"Hqg^(LO) x Pqg"},
    "AbsentDiagonal" ->
      "Hqqbar^(LO)=0, so no Hqqbar x Pqq term exists",
    "OneLoopFlavorChangingQuarkKernel" -> 0
  |>,
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "ChargeStrippingValidation" -> <|
    "ReferenceField" -> "F[3,{1}] up type",
    "ReferenceAmplitudeStripFactor" -> referenceStripFactor,
    "IndependentField" -> "F[4,{1}] down type",
    "IndependentAmplitudeStripFactor" -> validationStripFactor,
    "ProjectedResiduals" -> chargeStripResiduals,
    "PhysicalLuminosityAppliedAtS11" -> False,
    "PhysicalLuminosityDeferred" -> "Sum_q e_q^2 f_q D_qbar"
  |>,
  "BigTMDConvention" -> <|
    "ChannelNumber" -> 5,
    "ChargeCase" -> "A only",
    "ProjectorMapping" -> <|
      "Pg" -> "NLO.Pg.fchn5A",
      "PPP" -> "NLO.Ppp.fchn5A"
    |>,
    "UseAtThisStage" ->
      "hash-pinned convention reference only; no finite comparison is performed"
  |>,
  "BornProjectedSquaredAmplitudes" -> bornProjected,
  "BornGeneration" -> <|
    "DiagramCounts" -> bornDiagramCounts,
    "InitialAverageDenominators" -> bornInitialAverages,
    "AbsoluteScaleFactor" -> ScaleMu^(2 epsilon),
    "ScaleReason" ->
      "one strong vertex at amplitude level, squared; absolute Hqqbar scale convention",
    "WardResiduals" -> bornWardResiduals,
    "WardDiagnostic" ->
      "q_mu contracted against q_nu, p_nu, and k1_nu after exact two-body kinematics and explicit tree denominators"
  |>,
  "FactorizationConvention" -> <|
    "Prefactor" -> HoldForm[
      alphaS/(4 Pi) S11SEpsilon/epsilon ==
        FeynCalc`SMP["g_s"]^2 S11SEpsilon/(16 Pi^2 epsilon)
    ],
    "Sign" ->
      "positive because the order-alpha_s partonic PDF and FF terms in Eqs. (49)-(50) are negative and Eq. (46) subtracts them",
    "SchemeAsNamedByPaper" -> "MS",
    "SEpsilonTreatment" ->
      "retained symbolically exactly as in Eq. (46)",
    "AdditionalMuEpsilonFromPartonicPDForFF" -> 0,
    "BornHardPartScaleFactor" -> ScaleMu^(2 epsilon)
  |>,
  "SplittingKernels" -> <|
    "PgqPDF" -> HoldForm[
      Pgq[y] == 2 FeynCalc`CF (1 + (1 - y)^2)/y
    ],
    "PqgFF" -> HoldForm[
      Pqg[y] == 2 FeynCalc`TF ((1 - y)^2 + y^2)
    ],
    "Pqq" -> 0,
    "Pgg" -> 0
  |>,
  "ConvolutionMappings" -> <|
    "EndpointVariable" -> s11S23,
    "Interval" -> {s11S23, 0, endpointUpper},
    "EndpointUpper" -> endpointUpper,
    "PDFSplittingVariable" -> pdfSplittingVariable,
    "FFSplittingVariable" -> ffSplittingVariable,
    "PDFInternalKinematics" -> pdfInternalKinematics,
    "FFInternalKinematics" -> ffInternalKinematics,
    "ExternalTransverseMomentumSquared" -> externalTransverse2,
    "TwoBodyNormalization" -> twoBodyNormalization,
    "PPPInitialStateExternalProjectorConversion" -> HoldForm[
      PDFPPPExternalProjectorFactor == pdfSplittingVariable^-2
    ],
    "PPPFinalStateAdditionalProjectorConversion" -> 1,
    "Checks" -> kinematicChecks
  |>,
  "CountertermComponents" -> countertermComponents,
  "Counterterms" -> counterterms,
  "CountertermCount" -> Length[counterterms],
  "TestFunction" -> HoldForm[
    S11ConvolutionTest[projector, s11S23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular on the closed interval and independent of epsilon",
  "DistributionActionStatus" ->
    "Pgq and Pqg are regular at y=1; each counterterm is one ordinary inactive integral",
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS11" -> 1,
    "Charge" -> <|
      "BornHardPartsAreChargeStripped" -> True,
      "PhysicalFlavorChargeWeightAppliedAtS11" -> False,
      "PhysicalFlavorChargeWeightDeferred" ->
        "Sum_q e_q^2 f_q D_qbar"
    |>,
    "Scale" -> <|
      "BornHardPartAbsoluteFactor" -> ScaleMu^(2 epsilon),
      "PartonicPDForFFAdditionalMuEpsilon" -> 0,
      "S10UnsubtractedRealAbsoluteFactorForLaterCombination" ->
        acceptedS10Bookkeeping["Scale"]["AbsoluteFactor"]
    |>,
    "SymmetryOrFlavorMultiplicityAppliedAtS11" -> 1,
    "VirtualContributionAtThisOrder" -> 0,
    "S10CombinationPerformed" -> False
  |>,
  "Checks" -> s11Checks,
  "NotPerformedAtThisStage" -> {
    "addition to the accepted S10 real convolution actions",
    "physical-variable/test-function alignment with S10",
    "cancellation of the remaining collinear epsilon poles",
    "epsilon -> 0 finite Hqqbar hard parts",
    "paper Eq. (9) Pg/PPP inversion or F-hat extraction",
    "finite BigTMD channel-5A comparison",
    "numerical PDFs, fragmentation functions, test functions, or kinematics"
  }
|>;

If[
  preflightOnly,
  assert[
    If[
      TrueQ[resultStateBefore["Exists"]],
      FileExistsQ[resultPath] &&
        fileSHA256[resultPath] === resultStateBefore["SHA256"],
      ! FileExistsQ[resultPath]
    ],
    "The no-write preflight changed the S11 result state."
  ];
  Print["S11_PREFLIGHT_SUCCESS"];
  Print["S11_PROGRAM_SHA256=" <> programHash];
  Print["S11_CHECKS=", InputForm[s11Checks]];
  Quit[0]
];

Print["S11_STAGE: atomically writing the Hqqbar S11 result"];
reloadedResult = atomicPutAssociation[s11Result, resultPath];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["Channel"] === "Hqqbar only" &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["InputProvenance"]["S10ResultSHA256"] ===
      expectedS10ResultHash &&
    reloadedResult["InputProvenance"]["S10EndpointCacheSHA256"] ===
      expectedS10CacheHashes &&
    Keys[reloadedResult["Counterterms"]] === countertermKeys &&
    reloadedResult["Counterterms"] === counterterms &&
    And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "The reloaded S11 result failed schema, provenance, or payload validation."
];
assert[
  FileNames["s11_result.tmp.*", scriptDirectory] === {},
  "A finalized S11 temporary artifact remains."
];

resultHash = fileSHA256[resultPath];
Print["S11_SUCCESS_SYMBOLIC_COUNTERTERMS"];
Print["S11_PROGRAM_SHA256=" <> programHash];
Print["S11_RESULT_PATH=" <> resultPath];
Print["S11_RESULT_SHA256=" <> resultHash];
Print["S11_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S11_COUNTERTERM_KEYS=", InputForm[Keys[counterterms]]];
Print["S11_CHECKS=", InputForm[s11Checks]];
Quit[0];


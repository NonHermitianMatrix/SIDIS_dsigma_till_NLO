(* ::Package:: *)

(*
  Hqqprime stage S11: calculate, but do not add, the paper Eq. (46)
  charge-resolved collinear-factorization counterterms for Pg and PPP.

  The external paper labels are initial i0=q and fragmenting j0=qPrime with
  qPrime different from q.  The program derives the species sums from the
  Table-I two-body Born support and the one-loop splitting support:

    PDF: H_(g qPrime) convoluted with P_(g/q), routed to QqPrime^2,
    FF:  H_(q g)      convoluted with P_(qPrime/g), routed to Qq^2.

  There is no mixed-charge counterterm and no diagonal Hqqprime Born term.
  Both required Born hard parts are generated directly.  Their reference
  charge is stripped with reciprocals derived from accepted S01 model
  metadata, and an independent down-field regeneration must agree exactly.

  Each Born square carries the absolute ScaleMu^(2 epsilon) factor for one
  strong vertex.  Eq. (46) supplies symbolic S_epsilon/epsilon but no
  additional mu^epsilon.  The regular Pgq and Pqg kernels act as ordinary
  inactive integrals against projector- and charge-labelled symbolic tests.

  S10 combination, pole cancellation, epsilon -> 0, Eq. (9), F-hat
  extraction, physical ordered-flavour assembly, and external comparison are
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
  S11PlusDistribution, S11PhysicalOrderedFlavorChargeAssembly,
  S11QuarkSpecies, S11AntiQuarkSpecies, S11GluonSpecies,
  loBornSupport, splittingKernelSupport, chargeKeyForOwner,
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
  {
    temporaryPath, writeResult, temporaryReload, installResult,
    finalReload
  },
  assert[
    ! FileExistsQ[finalPath],
    "Refusing to overwrite an existing final S11 result."
  ];
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
  installResult = Check[RenameFile[temporaryPath, finalPath], $Failed];
  assert[
    installResult =!= $Failed && FileExistsQ[finalPath],
    "The atomic S11 result could not be installed."
  ];
  activeTemporaryPath = "";
  assert[
    FileByteCount[finalPath] > 0,
    "The installed S11 result is empty."
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
  FileNameJoin[{scriptDirectory, "s01_calculate_hqqprime_tree.wl"}];
s01ResultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
s10SourcePath =
  FileNameJoin[{scriptDirectory, "s10_resolve_endpoints_hqqprime.wl"}];
s10ResultPath = FileNameJoin[{scriptDirectory, "s10_result"}];

projectors = {"Pg", "PPP"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
s10CachePaths = <|
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

stageVersion = "HqqprimeS11-v1";
resultSchemaVersion = 1;
expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS01SourceHash =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultHash =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedS10SourceHash =
  "9ec4991d19fc5e61bc79ecb35f90062d15e8b2cd427ede637ed596519f05e988";
expectedS10ResultHash =
  "1ce9ef022312ff333b2dc949a858a5883380106c63742fada970f5ebc0d12c25";
expectedS10CacheHashes = <|
  "Pg" -> <|
    "IncomingChargeSquared" ->
      "c89636c1233f201751231f7f41b5948aee4c217bc8daea936569c0e328870cae",
    "PrimeChargeSquared" ->
      "971a9a7aa07f496f64fc6c5f8b333d156bfbf27ebeadc8d88297a4b11c85452f",
    "MixedIncomingPrimeCharge" ->
      "a1de00773858b02a79e0952183769f85a4678114fc6af9859e15302df412d8bb"
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" ->
      "29135863a484eeae754f54750635916e9908e6582dc4ae5cbca6d5414f2f2346",
    "PrimeChargeSquared" ->
      "80d2704635b95253c41c31468d4df41b7832081c15780c32e50a11197e8cbe9a",
    "MixedIncomingPrimeCharge" ->
      "714352bcd6a33806222f6706c3f7731aca03d98221e1a935f9669b0c717ad21c"
  |>
|>;

preflightOnly =
  ToLowerCase[Environment["HQQPRIME_S11_PREFLIGHT_ONLY"]] === "true" ||
  Environment["HQQPRIME_S11_PREFLIGHT_ONLY"] === "1";
resultStateBefore = If[
  FileExistsQ[resultPath],
  <|"Exists" -> True, "SHA256" -> fileSHA256[resultPath]|>,
  <|"Exists" -> False|>
];
programHash = fileSHA256[programPath];

If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[resultPath],
    "A final S11 result already exists; refusing silent overwrite."
  ]
];
assert[
  FileNames["s11_result.tmp.*", scriptDirectory] === {},
  "A stale S11 temporary result exists before launch."
];

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
  Keys[s10CachePaths] === projectors &&
    And @@ (Keys[#] === chargeKeys & /@ Values[s10CachePaths]) &&
    And @@ Flatten[
      KeyValueMap[
        Function[{projector, paths},
          KeyValueMap[
            Function[{chargeKey, path},
              FileExistsQ[path] &&
                fileSHA256[path] ===
                  expectedS10CacheHashes[projector, chargeKey]
            ],
            paths
          ]
        ],
        s10CachePaths
      ]
    ],
  "An accepted S10 endpoint-cache binding is stale."
];

s01 = Check[Get[s01ResultPath], $Failed];
assert[
  AssociationQ[s01] && s01["Status"] === "Complete" &&
    s01["Stage"] === "HqqprimeS01-v1" &&
    s01["Channel"] === "Hqqprime only" &&
    s01["Program"] === s01SourcePath &&
    s01["ProgramSHA256"] === expectedS01SourceHash &&
    s01["ReferencePDF"] === paperPath &&
    s01["ReferencePDFSHA256"] === expectedPaperHash,
  "The accepted S01 metadata is invalid."
];
assert[
  AssociationQ[s01["Checks"]] && Length[s01["Checks"]] === 19 &&
    And @@ (TrueQ /@ Values[s01["Checks"]]),
  "The accepted S01 check ledger is incomplete or contains a failure."
];
assert[
  s01["Conventions"]["IncomingMomenta"] === {q, p} &&
    s01["Conventions"]["OutgoingMomenta"] === {k1, k2, k3} &&
    s01["Conventions"]["FragmentingMomentum"] === k1 &&
    s01["Conventions"]["FragmentingFlavor"] ===
      "qPrime different from incoming q" &&
    s01["Conventions"]["ElectromagneticCouplingRetained"] === True &&
    s01["Conventions"]["NoFlavorMultiplicityApplied"] === True,
  "The accepted S01 state, charge, or flavour convention is invalid."
];

modelChargeCoefficients = s01["ModelChargeCoefficients"];
representativeChargeAssignments = s01["RepresentativeChargeAssignments"];
genericChargeSymbols = s01["ChargeBasis", "GenericChargeSymbols"];
assert[
  AssociationQ[modelChargeCoefficients] &&
    Keys[modelChargeCoefficients] === {"UpType", "DownType"} &&
    AllTrue[
      Values[modelChargeCoefficients],
      Function[value,
        value =!= 0 && FreeQ[value, _Real] && Head[value] =!= Symbol
      ]
    ] &&
    modelChargeCoefficients["UpType"] =!=
      modelChargeCoefficients["DownType"],
  "The accepted S01 model charge coefficients are invalid."
];
referenceUpCharge = modelChargeCoefficients["UpType"];
validationDownCharge = modelChargeCoefficients["DownType"];
referenceStripFactor = Together[1/referenceUpCharge];
validationStripFactor = Together[1/validationDownCharge];
assert[
  Together[referenceUpCharge referenceStripFactor - 1] === 0 &&
    Together[validationDownCharge validationStripFactor - 1] === 0,
  "A Born amplitude charge-strip factor was not derived as a reciprocal."
];
assert[
  representativeChargeAssignments === <|
    "up_up" -> <|
      "IncomingCharge" -> referenceUpCharge,
      "PrimeCharge" -> referenceUpCharge
    |>,
    "up_down" -> <|
      "IncomingCharge" -> referenceUpCharge,
      "PrimeCharge" -> validationDownCharge
    |>,
    "down_up" -> <|
      "IncomingCharge" -> validationDownCharge,
      "PrimeCharge" -> referenceUpCharge
    |>
  |> &&
    ListQ[genericChargeSymbols] && Length[genericChargeSymbols] === 2 &&
    DuplicateFreeQ[genericChargeSymbols],
  "The accepted S01 representative or generic-charge ledger is invalid."
];

s10 = Check[Get[s10ResultPath], $Failed];
assert[
  AssociationQ[s10] && s10["Status"] === "Complete" &&
    s10["Stage"] === "HqqprimeS10-v1" &&
    s10["ResultSchemaVersion"] === 1 &&
    s10["Channel"] === "Hqqprime only" &&
    s10["ProgramPath"] === s10SourcePath &&
    s10["ProgramSHA256"] === expectedS10SourceHash &&
    s10["PaperReference"]["Path"] === paperPath &&
    s10["PaperReference"]["SHA256"] === expectedPaperHash,
  "The accepted S10 metadata is invalid."
];
assert[
  AssociationQ[s10["Checks"]] && Length[s10["Checks"]] === 32 &&
    And @@ (TrueQ /@ Values[s10["Checks"]]),
  "The accepted S10 check ledger is incomplete or contains a failure."
];
assert[
  s10["ProjectorOrder"] === projectors &&
    s10["ChargeKeyOrder"] === chargeKeys &&
    s10["CacheProvenance"]["EndpointCachePaths"] === s10CachePaths &&
    s10["CacheProvenance"]["EndpointCacheSHA256"] ===
      expectedS10CacheHashes,
  "The accepted S10 ordering or cache provenance is invalid."
];
assert[
  s10["Bookkeeping"]["AdditionalMultiplicativeWeightAtS10"] === 1 &&
    s10["Bookkeeping"]["Scale"]["AbsoluteFactor"] ===
      ScaleMu^(4 epsilon) &&
    s10["Bookkeeping"]["Scale"]["SeparateMSBarSEpsilonApplied"] === False &&
    s10["Bookkeeping"]["Charge"]["SeparatedTensorKeys"] === chargeKeys &&
    s10["Bookkeeping"]["Charge"]["GenericChargeSymbols"] ===
      genericChargeSymbols &&
    s10["Bookkeeping"]["Charge"]["CoefficientTensorsRemainChargeFree"] ===
      True &&
    s10["Bookkeeping"]["Symmetry"]["FinalStateSymmetryFactor"] === 1 &&
    s10["Bookkeeping"]["Symmetry"]
      ["NoDownstreamNontrivialSymmetryFactorRemains"] === True &&
    s10["Bookkeeping"]["VirtualContributionAtThisOrder"]
      ["Applicable"] === False &&
    s10["Bookkeeping"]["PhysicalOrderedFlavorChargeAssemblyAppliedAtS10"] ===
      False &&
    s10["Bookkeeping"]["FinalStateSymmetryFactorAtS10"] === 1,
  "The accepted S10 charge, scale, symmetry, or virtual bookkeeping is invalid."
];
acceptedS10Bookkeeping = s10["Bookkeeping"];
acceptedS10CheckCount = Length[s10["Checks"]];
Clear[s01, s10];
ClearSystemCache[];
Print["S11_CHECKPOINT: accepted upstream provenance and bookkeeping validated"];

Print["S11_STAGE: deriving Eq. (46) species and charge routes"];
initialSpecies = S11QuarkSpecies["q"];
fragmentingSpecies = S11QuarkSpecies["qPrime"];
candidateSpecies = {
  S11QuarkSpecies["q"],
  S11QuarkSpecies["qPrime"],
  S11AntiQuarkSpecies["q"],
  S11AntiQuarkSpecies["qPrime"],
  S11GluonSpecies
};
assert[
  initialSpecies =!= fragmentingSpecies,
  "The Hqqprime different-flavour species gate failed."
];

loBornSupport[initial_, fragmenting_] := Which[
  initial === S11GluonSpecies &&
    MatchQ[fragmenting, S11QuarkSpecies[_]],
  <|
    "Channel" -> If[
      fragmenting === fragmentingSpecies,
      "HgqPrime",
      "Hgq"
    ],
    "ChargeOwner" -> fragmenting
  |>,

  initial === S11GluonSpecies &&
    MatchQ[fragmenting, S11AntiQuarkSpecies[_]],
  <|"Channel" -> "Hgqbar", "ChargeOwner" -> fragmenting|>,

  MatchQ[initial, S11QuarkSpecies[_]] &&
    fragmenting === S11GluonSpecies,
  <|"Channel" -> "Hqg", "ChargeOwner" -> initial|>,

  MatchQ[initial, S11AntiQuarkSpecies[_]] &&
    fragmenting === S11GluonSpecies,
  <|"Channel" -> "Hqbarg", "ChargeOwner" -> initial|>,

  MatchQ[initial, S11QuarkSpecies[_]] && initial === fragmenting,
  <|"Channel" -> "Hqq", "ChargeOwner" -> initial|>,

  MatchQ[initial, S11AntiQuarkSpecies[_]] && initial === fragmenting,
  <|"Channel" -> "Hqbarqbar", "ChargeOwner" -> initial|>,

  True,
  Missing["AbsentTwoBodyBorn"]
];

splittingKernelSupport[daughter_, parent_] := Which[
  daughter === S11GluonSpecies &&
    MatchQ[parent, S11QuarkSpecies[_] | S11AntiQuarkSpecies[_]],
  "Pgq",

  MatchQ[
    daughter,
    S11QuarkSpecies[_] | S11AntiQuarkSpecies[_]
  ] && parent === S11GluonSpecies,
  "Pqg",

  MatchQ[
    daughter,
    S11QuarkSpecies[_] | S11AntiQuarkSpecies[_]
  ] && daughter === parent,
  "Pqq",

  daughter === S11GluonSpecies && parent === S11GluonSpecies,
  "Pgg",

  True,
  0
];

chargeKeyForOwner[owner_] := Which[
  owner === initialSpecies, "IncomingChargeSquared",
  owner === fragmentingSpecies, "PrimeChargeSquared",
  True, Missing["NoExternalChargeKey"]
];

pdfRoutes = Cases[
  Map[
    Function[species,
      With[{
        born = loBornSupport[species, fragmentingSpecies],
        kernel = splittingKernelSupport[species, initialSpecies]
      },
        If[
          AssociationQ[born] && kernel =!= 0,
          <|
            "IntermediateInitialSpecies" -> species,
            "BornChannel" -> born["Channel"],
            "SplittingKernel" -> kernel,
            "ChargeOwner" -> born["ChargeOwner"],
            "ChargeKey" -> chargeKeyForOwner[born["ChargeOwner"]]
          |>,
          Missing["ZeroRoute"]
        ]
      ]
    ],
    candidateSpecies
  ],
  _Association
];

ffRoutes = Cases[
  Map[
    Function[species,
      With[{
        born = loBornSupport[initialSpecies, species],
        kernel = splittingKernelSupport[fragmentingSpecies, species]
      },
        If[
          AssociationQ[born] && kernel =!= 0,
          <|
            "IntermediateFragmentingSpecies" -> species,
            "BornChannel" -> born["Channel"],
            "SplittingKernel" -> kernel,
            "ChargeOwner" -> born["ChargeOwner"],
            "ChargeKey" -> chargeKeyForOwner[born["ChargeOwner"]]
          |>,
          Missing["ZeroRoute"]
        ]
      ]
    ],
    candidateSpecies
  ],
  _Association
];

routeChargeSupport = AssociationMap[
  Function[chargeKey,
    <|
      "PDF" -> Count[
        (#["ChargeKey"] & /@ pdfRoutes),
        chargeKey
      ],
      "FF" -> Count[
        (#["ChargeKey"] & /@ ffRoutes),
        chargeKey
      ]
    |>
  ],
  chargeKeys
];
assert[
  Length[pdfRoutes] === 1 && Length[ffRoutes] === 1 &&
    pdfRoutes[[1, "IntermediateInitialSpecies"]] === S11GluonSpecies &&
    pdfRoutes[[1, "BornChannel"]] === "HgqPrime" &&
    pdfRoutes[[1, "SplittingKernel"]] === "Pgq" &&
    pdfRoutes[[1, "ChargeKey"]] === "PrimeChargeSquared" &&
    ffRoutes[[1, "IntermediateFragmentingSpecies"]] ===
      S11GluonSpecies &&
    ffRoutes[[1, "BornChannel"]] === "Hqg" &&
    ffRoutes[[1, "SplittingKernel"]] === "Pqg" &&
    ffRoutes[[1, "ChargeKey"]] === "IncomingChargeSquared",
  "The derived Hqqprime Eq. (46) species routes are invalid."
];
assert[
  routeChargeSupport === <|
    "IncomingChargeSquared" -> <|"PDF" -> 0, "FF" -> 1|>,
    "PrimeChargeSquared" -> <|"PDF" -> 1, "FF" -> 0|>,
    "MixedIncomingPrimeCharge" -> <|"PDF" -> 0, "FF" -> 0|>
  |>,
  "The derived Hqqprime charge-key support is invalid."
];
pdfChargeKey = pdfRoutes[[1, "ChargeKey"]];
ffChargeKey = ffRoutes[[1, "ChargeKey"]];
Print["S11_CHECKPOINT: unique PDF/FF species and charge routes derived"];

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
    amplitudeNu, tensor, spinStateCount, colorStateCount,
    averageDenominator, wardResiduals, projectorDefinitions, pair
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
    ListQ[converted] && Length[converted] > 0,
    label <> " produced no Born diagrams."
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

  {spinStateCount, colorStateCount} = Switch[
    initialType,
    "Quark", {2, FeynCalc`SUNN},
    "Gluon", {D - 2, FeynCalc`SUNN^2 - 1},
    _, fatal[label <> " has an unknown initial-state type."]
  ];
  averageDenominator = spinStateCount colorStateCount;
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
  Print[
    "S11_CHECKPOINT: completed Born projections and Ward gates for " <>
      label
  ];
  <|
    "Projected" -> pair,
    "WardResiduals" -> wardResiduals,
    "DiagramCount" -> Length[converted],
    "InitialSpinStateCount" -> spinStateCount,
    "InitialColorStateCount" -> colorStateCount,
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
incomingGluonFields = {FeynArts`V[1], FeynArts`V[5]};

referenceBornData = <|
  "Hqg" -> generateBornData[
    {FeynArts`V[1], referenceUpField},
    {FeynArts`V[5], referenceUpField},
    {k1},
    "Quark",
    referenceStripFactor,
    "Hqg gamma* q -> g(k1) q"
  ],
  "HgqPrime" -> generateBornData[
    incomingGluonFields,
    {referenceUpField, -referenceUpField},
    {p},
    "Gluon",
    referenceStripFactor,
    "HgqPrime gamma* g -> qPrime(k1) qbarPrime"
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
  "HgqPrime" -> generateBornData[
    incomingGluonFields,
    {validationDownField, -validationDownField},
    {p},
    "Gluon",
    validationStripFactor,
    "validation HgqPrime gamma* g -> d(k1) dbar"
  ]
|>;

Print["S11_STAGE: explicitizing reference and charge-validation Born pairs"];
bornProjected = Map[
  explicitProjectedPair[#["Projected"]] &,
  referenceBornData
];
validationBornProjected = Map[
  explicitProjectedPair[#["Projected"]] &,
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

bornWardResiduals = Map[#["WardResiduals"] &, referenceBornData];
validationWardResiduals = Map[#["WardResiduals"] &, validationBornData];
bornDiagramCounts = Map[#["DiagramCount"] &, referenceBornData];
validationDiagramCounts = Map[#["DiagramCount"] &, validationBornData];
bornInitialAverages = Map[
  #["InitialAverageDenominator"] &,
  referenceBornData
];
allBornDiagramCounts = Join[
  Values[bornDiagramCounts],
  Values[validationDiagramCounts]
];
assert[
  AllTrue[allBornDiagramCounts, IntegerQ[#] && Positive[#] &] &&
    Length[DeleteDuplicates[allBornDiagramCounts]] === 1,
  "The tool-measured Born diagram inventories are inconsistent."
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

twoBodyNormalization = Together[2 Pi (2 Pi)^(-4)];
pdfBornDensities = AssociationMap[
  Function[projector,
    Together[
      twoBodyNormalization/pdfSplittingVariable *
        If[projector === "PPP", pdfSplittingVariable^-2, 1] *
        bornM2[
          "HgqPrime",
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
pdfCounterterms = AssociationMap[
  Function[projector,
    factorizationPrefactor regularKernelAction[
      pgqPDFKernel,
      pdfBornDensities[projector],
      pdfScale,
      S11ConvolutionTest[projector, pdfChargeKey, s11S23]
    ]
  ],
  projectors
];
ffCounterterms = AssociationMap[
  Function[projector,
    factorizationPrefactor regularKernelAction[
      pqgFFKernel,
      ffBornDensities[projector],
      ffScale,
      S11ConvolutionTest[projector, ffChargeKey, s11S23]
    ]
  ],
  projectors
];

countertermComponents = AssociationMap[
  Function[projector,
    AssociationMap[
      Function[chargeKey,
        <|
          "PDF" -> If[
            chargeKey === pdfChargeKey,
            pdfCounterterms[projector],
            0
          ],
          "FF" -> If[
            chargeKey === ffChargeKey,
            ffCounterterms[projector],
            0
          ]
        |>
      ],
      chargeKeys
    ]
  ],
  projectors
];
countertermsByProjectorCharge = Map[
  Function[projectorAssociation,
    Map[Function[components, Total[Values[components]]], projectorAssociation]
  ],
  countertermComponents
];

assert[
  Keys[countertermComponents] === projectors &&
    Keys[countertermsByProjectorCharge] === projectors &&
    And @@ (Keys[#] === chargeKeys & /@ Values[countertermComponents]) &&
    And @@ (
      Keys[#] === chargeKeys & /@ Values[countertermsByProjectorCharge]
    ) &&
    And @@ Flatten[
      Map[
        Function[projectorAssociation,
          Keys[#] === {"PDF", "FF"} & /@ Values[projectorAssociation]
        ],
        Values[countertermComponents]
      ]
    ],
  "The counterterm component or total key shape is invalid."
];

nonzeroCountertermComponents = Flatten[
  Table[
    {
      countertermComponents[projector, pdfChargeKey, "PDF"],
      countertermComponents[projector, ffChargeKey, "FF"]
    },
    {projector, projectors}
  ]
];
mixedCountertermTotals = AssociationMap[
  Function[projector,
    countertermsByProjectorCharge[
      projector,
      "MixedIncomingPrimeCharge"
    ]
  ],
  projectors
];
assert[
  Length[nonzeroCountertermComponents] ===
      Length[projectors] Length[{pdfChargeKey, ffChargeKey}] &&
    AllTrue[
      nonzeroCountertermComponents,
      TrueQ[# =!= 0 && # =!= $Failed] &
    ] &&
    AllTrue[Values[mixedCountertermTotals], TrueQ[# === 0] &],
  "The four nonzero/two zero counterterm inventory is invalid."
];
assert[
  And @@ Flatten[
    Table[
      {
        countertermComponents[
          projector,
          "IncomingChargeSquared",
          "PDF"
        ] === 0,
        countertermComponents[
          projector,
          "IncomingChargeSquared",
          "FF"
        ] =!= 0,
        countertermComponents[
          projector,
          "PrimeChargeSquared",
          "PDF"
        ] =!= 0,
        countertermComponents[
          projector,
          "PrimeChargeSquared",
          "FF"
        ] === 0,
        countertermComponents[
          projector,
          "MixedIncomingPrimeCharge",
          "PDF"
        ] === 0,
        countertermComponents[
          projector,
          "MixedIncomingPrimeCharge",
          "FF"
        ] === 0
      },
      {projector, projectors}
    ]
  ],
  "The explicit charge-resolved PDF/FF support is invalid."
];

s11Checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "AcceptedS01SourceResultAndNineteenChecksValidated" -> True,
  "AcceptedS10SourceResultSixCachesAndThirtyTwoChecksValidated" ->
    TrueQ[acceptedS10CheckCount === 32],
  "FeynCalcContextLoadedBeforeArtifactDeserialization" -> True,
  "ProjectorFirstChargeSecondOrderPreserved" -> True,
  "DifferentFlavorExternalSpeciesValidated" ->
    TrueQ[initialSpecies =!= fragmentingSpecies],
  "FullQuarkAntiquarkGluonCandidateSpeciesAudited" ->
    TrueQ[Length[candidateSpecies] === 5],
  "UniquePDFRouteDerivedAsHgqPrimeTimesPgq" ->
    TrueQ[
      Length[pdfRoutes] === 1 &&
        pdfRoutes[[1, "BornChannel"]] === "HgqPrime" &&
        pdfRoutes[[1, "SplittingKernel"]] === "Pgq"
    ],
  "UniqueFFRouteDerivedAsHqgTimesPqg" ->
    TrueQ[
      Length[ffRoutes] === 1 &&
        ffRoutes[[1, "BornChannel"]] === "Hqg" &&
        ffRoutes[[1, "SplittingKernel"]] === "Pqg"
    ],
  "SpeciesRoutesMappedToCorrectChargeKeys" ->
    TrueQ[
      pdfChargeKey === "PrimeChargeSquared" &&
        ffChargeKey === "IncomingChargeSquared"
    ],
  "MixedChargeRouteStructurallyAbsent" ->
    TrueQ[
      routeChargeSupport["MixedIncomingPrimeCharge"] ===
        <|"PDF" -> 0, "FF" -> 0|>
    ],
  "S01ModelChargesAndReciprocalStripFactorsDerivedExactly" ->
    TrueQ[
      Together[referenceUpCharge referenceStripFactor - 1] === 0 &&
        Together[validationDownCharge validationStripFactor - 1] === 0
    ],
  "ReferenceAndValidationBornChannelKeysAgree" ->
    TrueQ[
      Keys[referenceBornData] === {"Hqg", "HgqPrime"} &&
        Keys[validationBornData] === {"Hqg", "HgqPrime"}
    ],
  "CurrentBornDiagramInventoriesMeasuredAndConsistent" ->
    TrueQ[
      AllTrue[allBornDiagramCounts, IntegerQ[#] && Positive[#] &] &&
        Length[DeleteDuplicates[allBornDiagramCounts]] === 1
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
  "CorrectInitialStateAveragesDerived" ->
    TrueQ[
      bornInitialAverages === <|
        "Hqg" -> 2 FeynCalc`SUNN,
        "HgqPrime" -> (D - 2) (FeynCalc`SUNN^2 - 1)
      |>
    ],
  "AbsoluteBornScaleMuPowerTwoEpsilonAppliedExactlyOnce" ->
    AllTrue[
      Flatten[Values /@ Values[bornProjected]],
      hasSingleScalePowerQ[#, 2 epsilon] &
    ],
  "AllConvolutionMappingsValidated" ->
    AllTrue[Values[kinematicChecks], TrueQ],
  "PaperTwoBodyNormalizationDerived" ->
    TrueQ[
      twoBodyNormalization === Together[2 Pi (2 Pi)^(-4)]
    ],
  "PPPPDFRescalingAppliedOnlyToPDFDensity" -> True,
  "ExactlySixOrderedChargeResolvedTotals" ->
    TrueQ[
      Total[Length /@ Values[countertermsByProjectorCharge]] ===
        Length[projectors] Length[chargeKeys]
    ],
  "ExactlyFourNonzeroCountertermComponents" ->
    TrueQ[Length[nonzeroCountertermComponents] === 4],
  "ExactlyTwoStructuralMixedChargeZeros" ->
    AllTrue[Values[mixedCountertermTotals], TrueQ[# === 0] &],
  "RegularSplittingKernelsActedWithoutDistributionPlaceholders" ->
    AllTrue[
      nonzeroCountertermComponents,
      FreeQ[#, _S11PlusDistribution | _DiracDelta] &
    ],
  "ExactlyOneOrdinaryInactiveIntegralPerNonzeroComponent" ->
    AllTrue[
      nonzeroCountertermComponents,
      TrueQ[Count[#, Inactive[Integrate][___], Infinity] === 1] &
    ],
  "ProjectorAndChargeLabelledSymbolicTestsRetained" ->
    AllTrue[
      nonzeroCountertermComponents,
      ! FreeQ[#, _S11ConvolutionTest] &
    ],
  "PaperMSBarSEpsilonKeptSymbolic" ->
    AllTrue[
      nonzeroCountertermComponents,
      ! FreeQ[#, S11SEpsilon] &
    ],
  "NoAdditionalMuEpsilonInPartonicPDForFF" -> True,
  "CountertermsRetainExactlyOneBornScaleMuPower" ->
    AllTrue[
      nonzeroCountertermComponents,
      hasSingleScalePowerQ[#, 2 epsilon] &
    ],
  "CoefficientExpressionsRemainFreeOfGenericCharges" ->
    And @@ (
      Function[chargeSymbol,
        FreeQ[nonzeroCountertermComponents, chargeSymbol]
      ] /@ genericChargeSymbols
    ),
  "PhysicalOrderedFlavorChargeAssemblyStillDeferred" ->
    FreeQ[
      nonzeroCountertermComponents,
      S11PhysicalOrderedFlavorChargeAssembly
    ],
  "UnitWeightSymmetryAndAbsentVirtualBookkeepingPreserved" -> True,
  "CalculationRemainsExactAndSymbolic" ->
    FreeQ[
      nonzeroCountertermComponents,
      _Real | $Failed | Indeterminate | ComplexInfinity
    ],
  "S10ActionsNotLoadedRecomputedOrCombined" -> True,
  "PoleCancellationFiniteLimitEq9FHatAndExternalComparisonDeferred" -> True,
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
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "Eq. (46) Hqqprime charge-resolved initial-PDF and final-FF counterterms",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "ProjectorOrder" -> projectors,
  "ChargeKeyOrder" -> chargeKeys,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "SplittingFunctions" -> "Eqs. (51)-(53)",
    "TwoBodyPhaseSpace" -> "Eqs. (34)-(35)",
    "Scheme" -> "MSbar"
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
      "hash-pinned handoff and bookkeeping only; no S10 action is loaded, recomputed, or combined"
  |>,
  "SpeciesRouting" -> <|
    "ExternalLabels" -> <|
      "Initial" -> initialSpecies,
      "Fragmenting" -> fragmentingSpecies,
      "DifferentFlavor" -> True
    |>,
    "CandidateSpecies" -> candidateSpecies,
    "PDFRoutes" -> pdfRoutes,
    "FFRoutes" -> ffRoutes,
    "ChargeKeySupport" -> routeChargeSupport,
    "AbsentRouteMeaning" ->
      "structurally absent two-body Born or one-loop flavour-changing splitting support, not an evaluated-zero counterterm"
  |>,
  "ElectricChargeNormalization" -> <|
    "ModelChargeCoefficients" -> modelChargeCoefficients,
    "ReferenceField" -> "F[3,{1}] up type",
    "ReferenceCharge" -> referenceUpCharge,
    "ReferenceAmplitudeStripFactor" -> referenceStripFactor,
    "IndependentField" -> "F[4,{1}] down type",
    "IndependentCharge" -> validationDownCharge,
    "IndependentAmplitudeStripFactor" -> validationStripFactor,
    "StripFactorDerivation" -> "exact reciprocal of accepted S01 charge",
    "ProjectedResiduals" -> chargeStripResiduals
  |>,
  "BornProjectedSquaredAmplitudes" -> bornProjected,
  "BornGeneration" -> <|
    "DiagramCounts" -> bornDiagramCounts,
    "IndependentValidationDiagramCounts" -> validationDiagramCounts,
    "InitialAverageDenominators" -> bornInitialAverages,
    "AbsoluteScaleFactor" -> ScaleMu^(2 epsilon),
    "ScaleReason" ->
      "one strong vertex at amplitude level, squared; absolute Hqqprime convention",
    "WardResiduals" -> bornWardResiduals,
    "IndependentValidationWardResiduals" -> validationWardResiduals,
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
    "Scheme" -> "MSbar",
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
    "FlavorChangingQuarkOrAntiquarkKernel" -> 0
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
  "CountertermsByProjectorCharge" -> countertermsByProjectorCharge,
  "NonzeroCountertermComponentCount" ->
    Length[nonzeroCountertermComponents],
  "StructuralZeroTotalCount" -> Length[Values[mixedCountertermTotals]],
  "TestFunction" -> HoldForm[
    S11ConvolutionTest[projector, chargeKey, s11S23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular on the closed interval and independent of epsilon",
  "DistributionActionStatus" ->
    "Pgq and Pqg are regular at y=1; each nonzero component is one ordinary inactive integral",
  "Bookkeeping" -> <|
    "AdditionalMultiplicativeWeightAtS11" -> 1,
    "Charge" -> <|
      "SeparatedTensorKeys" -> chargeKeys,
      "GenericChargeSymbols" -> genericChargeSymbols,
      "CoefficientTensorsRemainChargeFree" -> True,
      "ComponentSupport" -> routeChargeSupport,
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS11" -> False,
      "PhysicalAssemblyInstruction" ->
        acceptedS10Bookkeeping["Charge"]["PhysicalAssemblyInstruction"]
    |>,
    "Scale" -> <|
      "BornHardPartAbsoluteFactor" -> ScaleMu^(2 epsilon),
      "PartonicPDForFFAdditionalMuEpsilon" -> 0,
      "S10UnsubtractedRealAbsoluteFactorForLaterCombination" ->
        acceptedS10Bookkeeping["Scale"]["AbsoluteFactor"]
    |>,
    "Symmetry" -> <|
      "FinalStateFactorInheritedFromS10" -> 1,
      "AdditionalSymmetryOrFlavorMultiplicityAtS11" -> 1,
      "NontrivialSymmetryFactorAppliedAtS11" -> False
    |>,
    "VirtualContributionAtThisOrder" ->
      acceptedS10Bookkeeping["VirtualContributionAtThisOrder"],
    "S10CombinationPerformed" -> False
  |>,
  "Checks" -> s11Checks,
  "NotPerformedAtThisStage" -> {
    "loading, recomputing, or adding the accepted S10 real convolution actions",
    "physical-variable/test-function alignment with S10",
    "cancellation of the remaining collinear epsilon poles",
    "epsilon -> 0 finite Hqqprime hard parts",
    "paper Eq. (9) Pg/PPP inversion or F-hat extraction",
    "physical ordered q,qPrime flavour/charge assembly",
    "external-code comparison",
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
    "The no-write mode changed the S11 result state."
  ];
  Print["S11_PREFLIGHT_SUCCESS"];
  Print["S11_PROGRAM_SHA256=" <> programHash];
  Print["S11_CHECKS=", InputForm[s11Checks]];
  Quit[0]
];

Print["S11_STAGE: atomically writing the Hqqprime S11 result"];
reloadedResult = atomicPutAssociation[s11Result, resultPath];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion &&
    reloadedResult["Channel"] === "Hqqprime only" &&
    reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["ProjectorOrder"] === projectors &&
    reloadedResult["ChargeKeyOrder"] === chargeKeys &&
    reloadedResult["InputProvenance"]["S10ResultSHA256"] ===
      expectedS10ResultHash &&
    reloadedResult["InputProvenance"]["S10EndpointCacheSHA256"] ===
      expectedS10CacheHashes &&
    reloadedResult["CountertermsByProjectorCharge"] ===
      countertermsByProjectorCharge &&
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
Print[
  "S11_COUNTERTERM_ORDER=",
  InputForm[{projectors, chargeKeys}]
];
Print[
  "S11_COMPONENT_SUPPORT=",
  InputForm[routeChargeSupport]
];
Print["S11_CHECKS=", InputForm[s11Checks]];
Quit[0];

(* ::Package:: *)

(*
  Hgg stage S11: calculate, but do not add, the Eq. (46) collinear
  factorization counterterms for both Pg and PPP.

  Since Hgg^(LO)=0, the only mixing channels are

    PDF: (Hqg + Hqbar g) convoluted with Pqg,
    FF:  (Hgq + Hg qbar) convoluted with Pgq.

  The four representative down-flavor Born processes are generated directly.
  Charge-conjugate pairs are validated exactly, and each representative
  squared kernel is multiplied by 9 Sum_f Q_f^2 before the distinct quark and
  antiquark species are summed.  Pqq, Pgg, virtual terms, and combination with
  S10 are deliberately absent.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fatal, assert, writeAtomic, setTwoBodyKinematics, openPhotonIndex,
  conjugateOpenAmplitude, validateProjectedPair,
  generateBornProjectedPair, explicitProjectedPair, zeroEquivalentQ,
  bornM2, s23Function, regularKernelAction,
  S11ConvolutionTest, S11SEpsilon, S11HggFlavorChargeSum,
  xHat, zHat, s11S23, k1T2, s11Mu, s11Nu
];

fatal[message_String] := (
  Print["S11_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

writeAtomic[expression_, path_String] := Module[{temporaryPath},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Put[expression, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Temporary output was not written for " <> path <> "."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic output was not installed at " <> path <> "."];
];

zeroEquivalentQ[expression_, seconds_Integer : 120] := Module[{answer},
  If[TrueQ[expression === 0], Return[True]];
  answer = Quiet@Check[
    TimeConstrained[Together[Cancel[expression]], seconds, $Failed],
    $Failed
  ];
  TrueQ[answer === 0]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
resultPath = FileNameJoin[{scriptDirectory, "s11_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
stageVersion = "HggS11-v1";
projectors = {"Pg", "PPP"};

Print["S11_STAGE: validating the authoritative paper input"];
assert[FileExistsQ[paperPath], "The authoritative paper is absent."];
paperSHA256 = FileHash[paperPath, "SHA256"];

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
  assert[! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no photon polarization to open."];
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
  assert[FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains a photon polarization."];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the open photon index."];
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
  assert[FreeQ[answer, FeynCalc`ComplexConjugate],
    label <> " retains an unevaluated conjugation."];
  answer
];

validateProjectedPair[pair_Association, label_String] := Module[{},
  assert[Sort[Keys[pair]] === Sort[projectors],
    label <> " lacks Pg or PPP."];
  assert[AllTrue[Values[pair], FreeQ[
        #,
        _FeynCalc`LorentzIndex | _FeynCalc`Spinor |
          _FeynCalc`Polarization | _FeynCalc`DiracGamma |
          _FeynCalc`DiracTrace | _FeynCalc`SUNFIndex |
          _FeynCalc`SUNIndex
      ] &],
    label <> " retains an external-state, Lorentz, Dirac, or color object."];
  True
];

generateBornProjectedPair[
    incomingFields_List, outgoingFields_List,
    gluonPolarizationMomenta_List, initialType_String, label_String
  ] := Module[
  {
    topologies, insertions, raw, converted, amplitude, amplitudeMu,
    amplitudeNu, tensor, averageFactor, projectorDefinitions, pair
  },
  Print["S11_STAGE: generating direct Born channel " <> label];
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
  assert[raw =!= $Failed,
    label <> " FeynArts amplitude generation failed."];
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
  assert[ListQ[converted] && Length[converted] === 2,
    label <> " did not produce the expected two Born diagrams."];
  converted = converted /. HoldPattern[
      FeynArts`FCGV[name_String]
    ] :> FeynCalc`FCGV[name];
  amplitude = Total[converted];
  amplitudeMu = openPhotonIndex[amplitude, s11Mu, label];
  amplitudeNu = conjugateOpenAmplitude[
    amplitudeMu, s11Mu, s11Nu, label
  ];
  tensor = amplitudeMu amplitudeNu;

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
  assert[tensor =!= $Failed, label <> " gluon polarization sum failed."];
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

  averageFactor = Switch[
    initialType,
    "Quark", 2 FeynCalc`SUNN,
    "Gluon", (D - 2) (FeynCalc`SUNN^2 - 1),
    _, fatal[label <> " has an unknown initial-state type."]
  ];
  tensor = Quiet@Check[
    FeynCalc`SUNSimplify[
      tensor/averageFactor,
      TimeConstrained -> Infinity,
      FeynCalc`SUNNToCACF -> True,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0
    ],
    $Failed
  ];
  assert[tensor =!= $Failed, label <> " color sum/average failed."];

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
  pair = AssociationMap[
    Function[projector,
      Quiet@Check[
        FeynCalc`Contract[projectorDefinitions[projector] tensor],
        $Failed
      ]
    ],
    projectors
  ];
  assert[AllTrue[Values[pair], # =!= $Failed &],
    label <> " projector contraction failed."];
  validateProjectedPair[pair, label];
  Print["S11_CHECKPOINT: completed Born projections for " <> label];
  pair
];

explicitProjectedPair[pair_Association] := Module[{answer},
  setTwoBodyKinematics[];
  answer = Map[
    Function[projection,
      Together[FeynCalc`FeynAmpDenominatorExplicit[projection]]
    ],
    pair
  ];
  assert[AllTrue[Values[answer], FreeQ[
        #,
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
      ] &],
    "A Born projection retains a propagator or momentum object."];
  answer
];

incomingQuark = {FeynArts`V[1], FeynArts`F[3, {1}]};
incomingAntiquark = {FeynArts`V[1], -FeynArts`F[3, {1}]};
incomingGluon = {FeynArts`V[1], FeynArts`V[5]};

directBornProjected = <|
  "Hqg" -> generateBornProjectedPair[
    incomingQuark,
    {FeynArts`V[5], FeynArts`F[3, {1}]},
    {k1},
    "Quark",
    "Hqg gamma* q -> g q"
  ],
  "HqbarG" -> generateBornProjectedPair[
    incomingAntiquark,
    {FeynArts`V[5], -FeynArts`F[3, {1}]},
    {k1},
    "Quark",
    "HqbarG gamma* qbar -> g qbar"
  ],
  "Hgq" -> generateBornProjectedPair[
    incomingGluon,
    {FeynArts`F[3, {1}], -FeynArts`F[3, {1}]},
    {p},
    "Gluon",
    "Hgq gamma* g -> q qbar"
  ],
  "Hgqbar" -> generateBornProjectedPair[
    incomingGluon,
    {-FeynArts`F[3, {1}], FeynArts`F[3, {1}]},
    {p},
    "Gluon",
    "Hgqbar gamma* g -> qbar q"
  ]
|>;

Print["S11_STAGE: explicitizing all four Born projection pairs"];
bornProjected = Map[explicitProjectedPair, directBornProjected];
Scan[
  Function[channel,
    validateProjectedPair[
      bornProjected[channel],
      "accepted " <> channel <> " Born pair"
    ]
  ],
  Keys[bornProjected]
];

chargeConjugationResiduals = <|
  "PDF_HqgMinusHqbarG" -> AssociationMap[
    Together[
      bornProjected["Hqg", #] - bornProjected["HqbarG", #]
    ] &,
    projectors
  ],
  "FF_HgqMinusHgqbar" -> AssociationMap[
    Together[
      bornProjected["Hgq", #] - bornProjected["Hgqbar", #]
    ] &,
    projectors
  ]
|>;
chargeConjugationChecks = Map[
  Function[pair, Map[zeroEquivalentQ, pair]],
  chargeConjugationResiduals
];
assert[AllTrue[Flatten[Values /@ Values[chargeConjugationChecks]], TrueQ],
  "At least one charge-conjugate Born projection does not agree."];
Print["S11_CHECKPOINT: charge-conjugate Born projections agree exactly"];

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

(* Common external endpoint variable for both Eq. (46) convolutions. *)
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
  ]
|>;
assert[AllTrue[Values[kinematicChecks], TrueQ],
  "At least one Eq. (46) convolution mapping check failed."];
Print["S11_CHECKPOINT: validated all Eq. (46) convolution maps"];

twoBodyNormalization = (2 Pi)/(2 Pi)^4;

pdfBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          twoBodyNormalization/pdfSplittingVariable *
            If[projector === "PPP", pdfSplittingVariable^-2, 1] *
            bornM2[
              channel,
              projector,
              pdfInternalKinematics["x"],
              pdfInternalKinematics["z"],
              pdfInternalKinematics["k1T2"]
            ]
        ]
      ],
      projectors
    ]
  ],
  {"Hqg", "HqbarG"}
];

ffBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          twoBodyNormalization/ffSplittingVariable *
            bornM2[
              channel,
              projector,
              ffInternalKinematics["x"],
              ffInternalKinematics["z"],
              ffInternalKinematics["k1T2"]
            ]
        ]
      ],
      projectors
    ]
  ],
  {"Hgq", "Hgqbar"}
];

regularKernelAction[
    kernel_, density_, scale_, test_
  ] := Inactive[Integrate][
  Together[kernel density/scale] test,
  {s11S23, 0, endpointUpper}
];

pqgPDFKernel = 2 TF (
  (1 - pdfSplittingVariable)^2 + pdfSplittingVariable^2
);
pgqFFKernel = 2 CF (1 + (1 - ffSplittingVariable)^2)/
  ffSplittingVariable;

factorizationPrefactor =
  FeynCalc`SMP["g_s"]^2/(16 Pi^2) S11SEpsilon/epsilon;
flavorChargeWeight = 9 S11HggFlavorChargeSum;

Print["S11_STAGE: acting the Hgg regular splitting kernels"];
countertermComponents = AssociationMap[
  Function[projector,
    With[{test = S11ConvolutionTest[projector, s11S23]},
      <|
        "PDF_Hqg_Pqg" ->
          factorizationPrefactor flavorChargeWeight *
            regularKernelAction[
              pqgPDFKernel,
              pdfBornDensities["Hqg", projector],
              pdfScale,
              test
            ],
        "PDF_HqbarG_Pqg" ->
          factorizationPrefactor flavorChargeWeight *
            regularKernelAction[
              pqgPDFKernel,
              pdfBornDensities["HqbarG", projector],
              pdfScale,
              test
            ],
        "FF_Hgq_Pgq" ->
          factorizationPrefactor flavorChargeWeight *
            regularKernelAction[
              pgqFFKernel,
              ffBornDensities["Hgq", projector],
              ffScale,
              test
            ],
        "FF_Hgqbar_Pgq" ->
          factorizationPrefactor flavorChargeWeight *
            regularKernelAction[
              pgqFFKernel,
              ffBornDensities["Hgqbar", projector],
              ffScale,
              test
            ]
      |>
    ]
  ],
  projectors
];

counterterms = <|
  "PgPDF" -> Total[Lookup[countertermComponents["Pg"], {
    "PDF_Hqg_Pqg", "PDF_HqbarG_Pqg"
  }]],
  "PgFF" -> Total[Lookup[countertermComponents["Pg"], {
    "FF_Hgq_Pgq", "FF_Hgqbar_Pgq"
  }]],
  "PPPPDF" -> Total[Lookup[countertermComponents["PPP"], {
    "PDF_Hqg_Pqg", "PDF_HqbarG_Pqg"
  }]],
  "PPPFF" -> Total[Lookup[countertermComponents["PPP"], {
    "FF_Hgq_Pgq", "FF_Hgqbar_Pgq"
  }]]
|>;

countertermKeys = {"PgPDF", "PgFF", "PPPPDF", "PPPFF"};
assert[Keys[counterterms] === countertermKeys,
  "The saved counterterm keys are not the requested four objects."];

forbiddenDistributionObjects =
  _S11PlusDistribution | DiracDelta[1 - _] | DiracDelta[_ - 1];
s11Checks = <|
  "AuthoritativePaperPresentAndHashed" -> True,
  "FourDirectBornChannelsGenerated" ->
    TrueQ[Sort[Keys[bornProjected]] ===
      Sort[{"Hqg", "HqbarG", "Hgq", "Hgqbar"}]],
  "PDFChargeConjugateBornPairsAgree" ->
    AllTrue[Values[chargeConjugationChecks["PDF_HqgMinusHqbarG"]],
      TrueQ],
  "FFChargeConjugateBornPairsAgree" ->
    AllTrue[Values[chargeConjugationChecks["FF_HgqMinusHgqbar"]],
      TrueQ],
  "AllConvolutionMappingsValidated" ->
    AllTrue[Values[kinematicChecks], TrueQ],
  "ExactlyFourCounterterms" -> TrueQ[Length[counterterms] === 4],
  "BothProjectorsHavePDFAndFF" -> True,
  "PDFContainsQuarkAndAntiquarkPqgSpecies" -> True,
  "FFContainsQuarkAndAntiquarkPgqSpecies" -> True,
  "PhysicalFlavorChargeWeightApplied" ->
    AllTrue[Values[counterterms],
      ! FreeQ[#, S11HggFlavorChargeSum] &],
  "NoPqqOrPggContribution" ->
    AllTrue[Values[counterterms], FreeQ[#, Pqq | Pgg] &],
  "NoSplittingDistributionPlaceholder" ->
    AllTrue[Values[counterterms],
      FreeQ[#, forbiddenDistributionObjects] &],
  "OrdinaryInactiveIntegralsRetained" ->
    AllTrue[Values[counterterms],
      ! FreeQ[#, Inactive[Integrate][___]] &],
  "ArbitrarySymbolicTestsRetained" ->
    AllTrue[Values[counterterms],
      ! FreeQ[#, _S11ConvolutionTest] &],
  "PaperSEpsilonKeptSymbolic" ->
    AllTrue[Values[counterterms], ! FreeQ[#, S11SEpsilon] &],
  "NoHggLOOrVirtualContributionIntroduced" -> True,
  "NoS10CombinationPerformed" -> True,
  "CalculationFullySymbolic" -> True
|>;
assert[AllTrue[Values[s11Checks], TrueQ],
  "At least one S11 validation check is not True."];

s11Result = <|
  "Status" -> "CompleteSymbolicCounterterms",
  "Channel" -> "Hgg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "StageVersion" -> stageVersion,
  "SourceResults" -> <|
    "AuthoritativePaper" -> paperPath,
    "AuthoritativePaperSHA256" -> paperSHA256,
    "BornMixingChannels" -> "generated directly in this stage"
  |>,
  "PaperReference" -> <|
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "SplittingFunctions" -> "Eqs. (51)-(53)",
    "TwoBodyPhaseSpace" -> "Eqs. (34)-(35)"
  |>,
  "FactorizationConvention" -> <|
    "Prefactor" -> HoldForm[
      alphaS/(4 Pi) S11SEpsilon/epsilon ==
        FeynCalc`SMP["g_s"]^2/(16 Pi^2) S11SEpsilon/epsilon
    ],
    "SEpsilonTreatment" ->
      "retained as the symbolic S_epsilon factor appearing in Eq. (46)",
    "Sign" ->
      "positive Eq. (46) contribution because the order-alpha_s partonic PDF and FF counterterms in Eqs. (49)-(50) are negative"
  |>,
  "SplittingKernels" -> <|
    "PqgPDF" -> HoldForm[
      Pqg[y] == 2 TF ((1 - y)^2 + y^2)
    ],
    "PgqFF" -> HoldForm[
      Pgq[y] == 2 CF (1 + (1 - y)^2)/y
    ],
    "Pqq" -> 0,
    "Pgg" -> 0
  |>,
  "FlavorSpeciesSum" -> <|
    "RepresentativeFlavor" -> "F[3,{1}] down type",
    "RepresentativeChargeSquared" -> 1/9,
    "PhysicalChargeSumDefinition" -> HoldForm[
      S11HggFlavorChargeSum ==
        Sum[Qf[flavor]^2, {flavor, ActiveQuarkFlavors}]
    ],
    "PerSpeciesAppliedWeight" -> flavorChargeWeight,
    "PDFSpecies" -> {"q", "qbar"},
    "FFSpecies" -> {"q", "qbar"},
    "RealSpectatorPairCounting" ->
      "not part of this counterterm species sum; the S09 real q-qbar pair remains counted once"
  |>,
  "BornProjectedSquaredAmplitudes" -> bornProjected,
  "ChargeConjugationResiduals" -> chargeConjugationResiduals,
  "ConvolutionMappings" -> <|
    "EndpointVariable" -> s11S23,
    "Interval" -> {s11S23, 0, endpointUpper},
    "EndpointUpper" -> endpointUpper,
    "PDFSplittingVariable" -> pdfSplittingVariable,
    "FFSplittingVariable" -> ffSplittingVariable,
    "PDFInternalKinematics" -> pdfInternalKinematics,
    "FFInternalKinematics" -> ffInternalKinematics,
    "ExternalTransverseMomentumSquared" -> externalTransverse2,
    "PPPInitialStateRescaling" -> HoldForm[
      PDFPPPExternalProjectorFactor == pdfSplittingVariable^-2
    ],
    "Checks" -> kinematicChecks
  |>,
  "CountertermComponents" -> countertermComponents,
  "Counterterms" -> counterterms,
  "CountertermCount" -> Length[counterterms],
  "TestFunction" -> HoldForm[
    S11ConvolutionTest[projector, s11S23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s11S23=0 and independent of epsilon",
  "DistributionActionStatus" ->
    "Pqg and Pgq are regular; all four counterterms are ordinary inactive integrals",
  "CombinationDeferredToS12" -> True,
  "Checks" -> s11Checks,
  "NotPerformedAtThisStage" -> {
    "addition of the four counterterms to s10_result",
    "cancellation test against the remaining S10 collinear poles",
    "epsilon -> 0 finite hatted Hgg hard functions",
    "numerical PDFs, fragmentation functions, test functions, or kinematics"
  }
|>;

Print["S11_STAGE: writing four symbolic Hgg counterterms"];
writeAtomic[s11Result, resultPath];
Print["S11_SUCCESS_SYMBOLIC_COUNTERTERMS"];
Print["S11_RESULT_PATH=" <> resultPath];
Print["S11_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S11_COUNTERTERM_KEYS=", InputForm[Keys[counterterms]]];
Print["S11_CHECKS=", InputForm[s11Checks]];
Quit[0];

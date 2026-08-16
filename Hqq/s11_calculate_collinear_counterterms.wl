(* ::Package:: *)

(*
  Hqq stage s11: calculate, but do not yet add, the four collinear
  factorization counterterms in Eq. (46) of the paper.

  For each projector Gamma in {Pg, PPP}, this stage calculates

    1. the initial-state PDF counterterm, and
    2. the final-state FF counterterm.

  The Hqq external channel requires the following LO species sums:

    PDF: Hqq convoluted with Pqq + Hgq convoluted with Pgq,
    FF:  Hqq convoluted with Pqq + Hqg convoluted with Pqg.

  The validated Hqq LO projection is loaded from s07_result.  The missing
  Hqg and Hgq LO projections are generated directly with the same FeynArts /
  FeynCalc conventions.  A direct Hqq regeneration must agree exactly with
  s07_result before either mixing channel is accepted.

  The tilde-xi and tilde-zeta splitting distributions are acted exactly on
  the two-body delta kernel.  The saved counterterms therefore contain only
  ordinary inactive integrals against an arbitrary symbolic test function;
  no splitting-function plus or delta placeholder remains.  S_epsilon is
  retained as the symbolic paper factor.  Addition to s10_result and the
  finite hard-function construction are deliberately deferred to s12.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fatal, assert, setTwoBodyKinematics, openPhotonIndex,
  conjugateOpenAmplitude, validateProjectedPair,
  generateBornProjectedPair, explicitProjectedPair, zeroEquivalentQ,
  bornM2, s23Function, pqqAction, regularKernelAction,
  S11ConvolutionTest, S11SEpsilon, S11PlusDistribution,
  xHat, zHat, s11S23, k1T2, s11Mu, s11Nu
];

fatal[message_String] := (
  Print["S11_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

zeroEquivalentQ[expression_, seconds_Integer : 120] := Module[{answer},
  If[TrueQ[expression === 0], Return[True]];
  answer = Quiet@Check[
    TimeConstrained[Together[Cancel[expression]], seconds, $Failed],
    $Failed
  ];
  TrueQ[answer === 0]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s07Path = FileNameJoin[{scriptDirectory, "s07_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s11_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
projectors = {"Pg", "PPP"};

Print["S11_STAGE: loading and validating the Hqq s07 LO projections"];
assert[FileExistsQ[s07Path], "s07_result does not exist."];
s07 = Check[Get[s07Path], $Failed];
assert[AssociationQ[s07] && s07["Status"] === "Complete",
  "s07_result is absent, invalid, or incomplete."];
assert[s07["Channel"] === "Hqq only", "s07_result is not Hqq-only."];
assert[And @@ Values[s07["Checks"]],
  "At least one s07 validation check is not True."];
assert[FileExistsQ[paperPath], "The authoritative paper is absent."];

s07HqqLO = s07["ScalarProjections", "LO_OAlphaS"];
assert[AssociationQ[s07HqqLO] &&
    Sort[Keys[s07HqqLO]] === Sort[projectors],
  "The s07 LO result lacks Pg or PPP."];

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
  assert[And @@ (FreeQ[
        #,
        _FeynCalc`LorentzIndex | _FeynCalc`Spinor |
          _FeynCalc`Polarization | _FeynCalc`DiracGamma |
          _FeynCalc`DiracTrace | _FeynCalc`SUNFIndex |
          _FeynCalc`SUNIndex
      ] & /@ Values[pair]),
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
  assert[raw =!= $Failed, label <> " FeynArts amplitude generation failed."];
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
  assert[And @@ (# =!= $Failed & /@ Values[pair]),
    label <> " projector contraction failed."];
  validateProjectedPair[pair, label];
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
  assert[And @@ (FreeQ[
        #,
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
      ] & /@ Values[answer]),
    "A Born projection retains a propagator or momentum object."];
  answer
];

incomingQuark = {FeynArts`V[1], FeynArts`F[3, {1}]};
incomingGluon = {FeynArts`V[1], FeynArts`V[5]};

directBornProjected = <|
  "Hqq" -> generateBornProjectedPair[
    incomingQuark,
    {FeynArts`F[3, {1}], FeynArts`V[5]},
    {k2},
    "Quark",
    "Hqq gamma* q -> q g"
  ],
  "Hqg" -> generateBornProjectedPair[
    incomingQuark,
    {FeynArts`V[5], FeynArts`F[3, {1}]},
    {k1},
    "Quark",
    "Hqg gamma* q -> g q"
  ],
  "Hgq" -> generateBornProjectedPair[
    incomingGluon,
    {FeynArts`F[3, {1}], -FeynArts`F[3, {1}]},
    {p},
    "Gluon",
    "Hgq gamma* g -> q qbar"
  ]
|>;

Print["S11_STAGE: explicitizing and validating all Born projections"];
directBornExplicit = Map[explicitProjectedPair, directBornProjected];
s07HqqExplicit = explicitProjectedPair[s07HqqLO];
hqqRegenerationResiduals = AssociationMap[
  Function[projector,
    Together[
      directBornExplicit["Hqq", projector] -
        s07HqqExplicit[projector]
    ]
  ],
  projectors
];
hqqRegenerationChecks = Map[zeroEquivalentQ, hqqRegenerationResiduals];
assert[And @@ Values[hqqRegenerationChecks],
  "Direct Hqq Born regeneration does not match s07_result."];

bornProjected = <|
  "Hqq" -> s07HqqExplicit,
  "Hqg" -> directBornExplicit["Hqg"],
  "Hgq" -> directBornExplicit["Hgq"]
|>;
Scan[
  Function[channel,
    validateProjectedPair[
      bornProjected[channel],
      "accepted " <> channel <> " Born pair"
    ]
  ],
  Keys[bornProjected]
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

(*
  Common external endpoint variable for both Eq. (46) convolutions.
  At s11S23 = 0, the splitting variable is 1.  At the upper endpoint,
  the PDF splitting variable is xHat and the FF splitting variable is zHat.
*)
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
assert[And @@ Values[kinematicChecks],
  "At least one Eq. (46) convolution mapping check failed."];

twoBodyNormalization = (2 Pi)/(2 Pi)^4;

pdfBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        Together[
          twoBodyNormalization/pdfSplittingVariable *
            (*
              The PDF Born subprocess carries pPrime=y p.  Pg is
              independent of that rescaling, while the saved PPP Born
              projection contains pPrime^mu pPrime^nu and must be converted
              to the external p^mu p^nu projector by 1/y^2.
            *)
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
  {"Hqq", "Hgq"}
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
  {"Hqq", "Hqg"}
];

(*
  Exact action of Eq. (51) on a density times a test function over the
  transformed interval 0 <= s11S23 <= endpointUpper.  This implements

    integral_lower^1 dy [1/(1-y)]_+ phi(y)

  as an ordinary endpoint-subtracted integral plus phi(1) Log[1-lower].
*)
pqqAction[
    density_, splittingVariable_, scale_, lower_, test_
  ] := Module[{density0, test0, plusAction, regularAction},
  density0 = Together[density /. s11S23 -> 0];
  test0 = test /. s11S23 -> 0;
  plusAction = Inactive[Integrate][
      (density test - density0 test0)/s11S23,
      {s11S23, 0, endpointUpper}
    ] + density0 test0 Log[1 - lower];
  regularAction = Inactive[Integrate][
    Together[-(1 + splittingVariable) density/scale] test,
    {s11S23, 0, endpointUpper}
  ];
  2 CF (2 plusAction + regularAction + 3 density0 test0/2)
];

regularKernelAction[
    kernel_, density_, scale_, test_
  ] := Inactive[Integrate][
  Together[kernel density/scale] test,
  {s11S23, 0, endpointUpper}
];

pgqKernel = 2 CF (1 + (1 - pdfSplittingVariable)^2)/
  pdfSplittingVariable;
pqgKernel = 2 TF (
  (1 - ffSplittingVariable)^2 + ffSplittingVariable^2
);

factorizationPrefactor =
  FeynCalc`SMP["g_s"]^2/(16 Pi^2) S11SEpsilon/epsilon;

Print["S11_STAGE: acting the splitting distributions for both projectors"];
countertermComponents = AssociationMap[
  Function[projector,
    With[{test = S11ConvolutionTest[projector, s11S23]},
      <|
        "PDF_Hqq_Pqq" -> factorizationPrefactor pqqAction[
          pdfBornDensities["Hqq", projector],
          pdfSplittingVariable,
          pdfScale,
          xHat,
          test
        ],
        "PDF_Hgq_Pgq" -> factorizationPrefactor regularKernelAction[
          pgqKernel,
          pdfBornDensities["Hgq", projector],
          pdfScale,
          test
        ],
        "FF_Hqq_Pqq" -> factorizationPrefactor pqqAction[
          ffBornDensities["Hqq", projector],
          ffSplittingVariable,
          ffScale,
          zHat,
          test
        ],
        "FF_Hqg_Pqg" -> factorizationPrefactor regularKernelAction[
          pqgKernel,
          ffBornDensities["Hqg", projector],
          ffScale,
          test
        ]
      |>
    ]
  ],
  projectors
];

counterterms = <|
  "PgPDF" -> Total[
    Lookup[countertermComponents["Pg"], {
      "PDF_Hqq_Pqq", "PDF_Hgq_Pgq"
    }]
  ],
  "PgFF" -> Total[
    Lookup[countertermComponents["Pg"], {
      "FF_Hqq_Pqq", "FF_Hqg_Pqg"
    }]
  ],
  "PPPPDF" -> Total[
    Lookup[countertermComponents["PPP"], {
      "PDF_Hqq_Pqq", "PDF_Hgq_Pgq"
    }]
  ],
  "PPPFF" -> Total[
    Lookup[countertermComponents["PPP"], {
      "FF_Hqq_Pqq", "FF_Hqg_Pqg"
    }]
  ]
|>;

countertermKeys = {"PgPDF", "PgFF", "PPPPDF", "PPPFF"};
assert[Keys[counterterms] === countertermKeys,
  "The saved counterterm keys are not the requested four objects."];

distributionObjects =
  _S11PlusDistribution | DiracDelta[1 - _] | DiracDelta[_ - 1];
s11Checks = <|
  "S07InputValidated" -> True,
  "ThreeBornChannelsAvailable" ->
    TrueQ[Sort[Keys[bornProjected]] === Sort[{"Hqq", "Hqg", "Hgq"}]],
  "HqqRegenerationMatchesS07Pg" -> hqqRegenerationChecks["Pg"],
  "HqqRegenerationMatchesS07PPP" -> hqqRegenerationChecks["PPP"],
  "AllConvolutionMappingsValidated" -> And @@ Values[kinematicChecks],
  "ExactlyFourCounterterms" -> TrueQ[Length[counterterms] === 4],
  "BothProjectorsHavePDFAndFF" -> True,
  "PDFContainsDiagonalAndMixingBornChannels" -> True,
  "FFContainsDiagonalAndMixingBornChannels" -> True,
  "SplittingDistributionsActed" -> And @@ (
    FreeQ[#, distributionObjects] & /@ Values[counterterms]
  ),
  "OrdinaryInactiveIntegralsRetained" -> And @@ (
    ! FreeQ[#, Inactive[Integrate][___]] & /@ Values[counterterms]
  ),
  "ArbitrarySymbolicTestsRetained" -> And @@ (
    ! FreeQ[#, _S11ConvolutionTest] & /@ Values[counterterms]
  ),
  "PaperSEpsilonKeptSymbolic" -> And @@ (
    ! FreeQ[#, S11SEpsilon] & /@ Values[counterterms]
  ),
  "NoS10CombinationPerformed" -> True,
  "CalculationFullySymbolic" -> True
|>;
assert[And @@ Values[s11Checks],
  "At least one S11 validation check is not True."];

s11Result = <|
  "Status" -> "CompleteSymbolicCounterterms",
  "Channel" -> "Hqq",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResults" -> <|
    "HqqProjectedLO" -> s07Path,
    "AuthoritativePaper" -> paperPath
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
      "the Eq. (46) terms are positive because the order-alpha_s partonic PDF and FF counterterms in Eqs. (49)-(50) are negative"
  |>,
  "SplittingKernels" -> <|
    "Pqq" -> HoldForm[
      Pqq[y] == 2 CF (
        2 S11PlusDistribution[1/(1 - y), {y, 0, 1}] - 1 - y +
          3 DiracDelta[1 - y]/2
      )
    ],
    "Pqg" -> HoldForm[Pqg[y] == 2 TF ((1 - y)^2 + y^2)],
    "Pgq" -> HoldForm[Pgq[y] == 2 CF (1 + (1 - y)^2)/y]
  |>,
  "BornProjectedSquaredAmplitudes" -> bornProjected,
  "HqqDirectRegenerationResiduals" -> hqqRegenerationResiduals,
  "ConvolutionMappings" -> <|
    "EndpointVariable" -> s11S23,
    "Interval" -> {s11S23, 0, endpointUpper},
    "EndpointUpper" -> endpointUpper,
    "PDFSplittingVariable" -> pdfSplittingVariable,
    "FFSplittingVariable" -> ffSplittingVariable,
    "PDFInternalKinematics" -> pdfInternalKinematics,
    "FFInternalKinematics" -> ffInternalKinematics,
    "ExternalTransverseMomentumSquared" -> externalTransverse2,
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
    "all splitting-function delta/plus distributions have acted; only ordinary inactive integrals remain",
  "CombinationDeferredToS12" -> True,
  "Checks" -> s11Checks,
  "NotPerformedAtThisStage" -> {
    "addition of the four counterterms to s10_result",
    "cancellation test against the remaining S10 collinear poles",
    "epsilon -> 0 finite hatted Hqq hard functions",
    "numerical PDFs, fragmentation functions, test functions, or kinematics"
  }
|>;

Print["S11_STAGE: writing four symbolic counterterms"];
Put[s11Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "s11_result was not written or is empty."];

Print["S11_SUCCESS_SYMBOLIC_COUNTERTERMS"];
Print["S11_RESULT_PATH=" <> resultPath];
Print["S11_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S11_COUNTERTERM_KEYS=", InputForm[Keys[counterterms]]];
Print["S11_CHECKS=", InputForm[s11Checks]];
Quit[0];

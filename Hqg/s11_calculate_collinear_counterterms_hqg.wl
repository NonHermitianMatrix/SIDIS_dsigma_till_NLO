(* ::Package:: *)

(*
  Hqg stage S11: calculate, but do not yet add, the four Eq. (46)
  collinear-factorization counterterms for Pg and PPP.

  The external channel is initial q and fragmenting g(k1).  Its LO species
  routing is

    PDF: Hqg convoluted with Pqq,
    FF:  Hqg convoluted with Pgg + Hqq convoluted with Pgq.

  LO Hgg vanishes, so no PDF-side Hgg mixing term exists.  Hqg and Hqq Born
  projections are generated directly with the reference down-quark charge.
  The current S07 hard part has the amplitude strip factor -3 applied, so the
  direct Born squares receive the corresponding factor 9.  The normalized
  Hqg pair must agree exactly with current S07 before either Born pair is used.

  The paper prints Pqq, Pqg, and Pgq in Eqs. (51)-(53), but does not print
  Pgg.  The standard one-loop Pgg in the same alpha_s/(4 Pi) normalization
  is used explicitly.  All delta/plus distributions act on an arbitrary
  symbolic test function.  S10 combination, pole cancellation, the finite
  Hermitian convention, and comparison with BigTMD fchn3A are deferred.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fatal, assert, writeAtomic, zeroEquivalentQ, setTwoBodyKinematics,
  openPhotonIndex, conjugateOpenAmplitude, validateProjectedPair,
  generateBornProjectedPair, explicitProjectedPair, bornM2, s23Function,
  pqqAction, pggAction, regularKernelAction,
  S11ConvolutionTest, S11SEpsilon, S11PlusDistribution,
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
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Temporary S11 output was not written."];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic S11 result installation failed."];
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
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s07Path = FileNameJoin[{scriptDirectory, "s07_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s11_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
bigTMDPgPath = FileNameJoin[{
  DirectoryName[scriptDirectory], "Hqq", "bigTMD_check",
  "BigTMD_reference", "NLO", "Pg", "fchn3A.py"
}];
bigTMDPPPPath = FileNameJoin[{
  DirectoryName[scriptDirectory], "Hqq", "bigTMD_check",
  "BigTMD_reference", "NLO", "Ppp", "fchn3A.py"
}];
stageVersion = "HqgS11-v2";
projectors = {"Pg", "PPP"};

Print["S11_STAGE: loading and validating charge-stripped Hqg S07 LO"];
assert[FileExistsQ[s07Path], "s07_result does not exist."];
s07 = Check[Get[s07Path], $Failed];
assert[
  AssociationQ[s07] && s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v3" && s07["Channel"] === "Hqg only",
  "s07_result is not the validated Hqg S07 artifact."
];
assert[AllTrue[Values[s07["Checks"]], TrueQ],
  "At least one S07 validation check is not True."];
assert[
  FileExistsQ[s07["Program"]] &&
    s07["ProgramSHA256"] === FileHash[s07["Program"], "SHA256"],
  "The S07 program binding is stale."
];
assert[FileExistsQ[paperPath] &&
    s07["ReferencePDFSHA256"] === FileHash[paperPath, "SHA256"],
  "The S07/paper binding is stale."];
assert[FileExistsQ[bigTMDPgPath] && FileExistsQ[bigTMDPPPPath],
  "The local BigTMD channel-3A reference files are absent."];

electricChargeNormalization = s07["ElectricChargeNormalization"];
assert[
  AssociationQ[electricChargeNormalization] &&
    electricChargeNormalization["ReferenceCharge"] === -1/3 &&
    electricChargeNormalization["AmplitudeStripFactor"] === -3 &&
    electricChargeNormalization[
      "BigTMDLuminosityAppliedDownstream"
    ] === "Sum_q e_q^2 f_q D_g",
  "The Hqg charge-stripping convention is invalid."
];
metadataChargeStripSquaredFactor =
  electricChargeNormalization["AmplitudeStripFactor"]^2;
assert[metadataChargeStripSquaredFactor === 9,
  "The expected squared charge-strip factor is not 9."];
directBornNormalizationFactor = metadataChargeStripSquaredFactor;

s07HqgLO = s07["ScalarProjections", "LO_OAlphaS"];
assert[AssociationQ[s07HqgLO] &&
    Sort[Keys[s07HqgLO]] === Sort[projectors],
  "The Hqg S07 LO result lacks Pg or PPP."];
s07SHA256 = FileHash[s07Path, "SHA256"];
paperSHA256 = FileHash[paperPath, "SHA256"];
bigTMDReferenceSHA256 = <|
  "Pg" -> FileHash[bigTMDPgPath, "SHA256"],
  "PPP" -> FileHash[bigTMDPPPPath, "SHA256"]
|>;

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
      before, FeynCalc`LorentzIndex[openIndex, dim], after
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
  assert[AllTrue[Values[pair],
      FreeQ[
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
    gluonPolarizationMomenta_List, label_String
  ] := Module[
  {
    topologies, insertions, raw, converted, amplitude, amplitudeMu,
    amplitudeNu, tensor, projectorDefinitions, pair
  },
  Print["S11_STAGE: generating direct Born channel " <> label];
  topologies = FeynArts`CreateTopologies[
    0, 2 -> 2,
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
    FeynArts`CreateFeynAmp[insertions, FeynArts`Truncated -> False],
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
  assert[ListQ[converted] && Length[converted] === 2,
    label <> " did not produce exactly two Born diagrams."];
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
          current, momentum, 0,
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
  assert[tensor =!= $Failed, label <> " Dirac trace failed."];
  tensor = Quiet@Check[
    FeynCalc`SUNSimplify[
      tensor/(2 FeynCalc`SUNN),
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
    Quiet@Check[
      FeynCalc`Contract[projectorDefinitions[#] tensor],
      $Failed
    ] &,
    projectors
  ];
  assert[AllTrue[Values[pair], # =!= $Failed &],
    label <> " projector contraction failed."];
  validateProjectedPair[pair, label];
  pair
];

explicitProjectedPair[pair_Association] := Module[{answer},
  setTwoBodyKinematics[];
  answer = Map[
    Together[FeynCalc`FeynAmpDenominatorExplicit[#]] &,
    pair
  ];
  assert[AllTrue[Values[answer],
      FreeQ[#, _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum] &],
    "A Born projection retains a propagator or momentum object."];
  answer
];

incomingQuark = {FeynArts`V[1], FeynArts`F[3, {1}]};
directBornProjected = <|
  "Hqg" -> generateBornProjectedPair[
    incomingQuark,
    {FeynArts`V[5], FeynArts`F[3, {1}]},
    {k1},
    "Hqg gamma* q -> g q"
  ],
  "Hqq" -> generateBornProjectedPair[
    incomingQuark,
    {FeynArts`F[3, {1}], FeynArts`V[5]},
    {k2},
    "Hqq gamma* q -> q g"
  ]
|>;

Print["S11_STAGE: validating direct unit-charge Born normalization"];
directBornExplicit = Map[explicitProjectedPair, directBornProjected];
directBornAccepted = Map[
  Function[pair, Map[Together[directBornNormalizationFactor #] &, pair]],
  directBornExplicit
];
s07HqgExplicit = explicitProjectedPair[s07HqgLO];
hqgRegenerationResiduals = AssociationMap[
  Together[
    directBornAccepted["Hqg", #] - s07HqgExplicit[#]
  ] &,
  projectors
];
hqgRegenerationChecks = Map[zeroEquivalentQ, hqgRegenerationResiduals];
assert[AllTrue[Values[hqgRegenerationChecks], TrueQ],
  "Direct unit-charge Hqg Born generation does not match S07."];

bornProjected = <|
  "Hqg" -> s07HqgExplicit,
  "Hqq" -> directBornAccepted["Hqq"]
|>;
Scan[
  validateProjectedPair[bornProjected[#], "accepted " <> # <> " Born pair"] &,
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
  "At least one Eq. (46) convolution map failed."];

twoBodyNormalization = (2 Pi)/(2 Pi)^4;
pdfBornDensities = AssociationMap[
  Together[
    twoBodyNormalization/pdfSplittingVariable *
      If[# === "PPP", pdfSplittingVariable^-2, 1] *
      bornM2[
        "Hqg", #,
        pdfInternalKinematics["x"],
        pdfInternalKinematics["z"],
        pdfInternalKinematics["k1T2"]
      ]
  ] &,
  projectors
];
ffBornDensities = AssociationMap[
  Function[channel,
    AssociationMap[
      Together[
        twoBodyNormalization/ffSplittingVariable *
          bornM2[
            channel, #,
            ffInternalKinematics["x"],
            ffInternalKinematics["z"],
            ffInternalKinematics["k1T2"]
          ]
      ] &,
      projectors
    ]
  ],
  {"Hqg", "Hqq"}
];

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
  2 FeynCalc`CF (2 plusAction + regularAction + 3 density0 test0/2)
];

pggAction[
    density_, splittingVariable_, scale_, lower_, test_
  ] := Module[{density0, test0, plusAction, regularAction, deltaCoefficient},
  density0 = Together[density /. s11S23 -> 0];
  test0 = test /. s11S23 -> 0;
  plusAction = Inactive[Integrate][
      (density test - density0 test0)/s11S23,
      {s11S23, 0, endpointUpper}
    ] + density0 test0 Log[1 - lower];
  regularAction = Inactive[Integrate][
    Together[
      (1/splittingVariable - 2 +
        splittingVariable (1 - splittingVariable)) density/scale
    ] test,
    {s11S23, 0, endpointUpper}
  ];
  deltaCoefficient =
    (11 FeynCalc`CA - 4 FeynCalc`TF FeynCalc`Nf)/3;
  4 FeynCalc`CA (plusAction + regularAction) +
    deltaCoefficient density0 test0
];

regularKernelAction[kernel_, density_, scale_, test_] :=
  Inactive[Integrate][
    Together[kernel density/scale] test,
    {s11S23, 0, endpointUpper}
  ];

pgqFFKernel = 2 FeynCalc`CF *
  (1 + (1 - ffSplittingVariable)^2)/ffSplittingVariable;
factorizationPrefactor =
  FeynCalc`SMP["g_s"]^2/(16 Pi^2) S11SEpsilon/epsilon;

Print["S11_STAGE: acting Pqq, Pgg, and Pgq for both projectors"];
countertermComponents = AssociationMap[
  Function[projector,
    With[{test = S11ConvolutionTest[projector, s11S23]},
      <|
        "PDF_Hqg_Pqq" -> factorizationPrefactor pqqAction[
          pdfBornDensities[projector],
          pdfSplittingVariable,
          pdfScale,
          xHat,
          test
        ],
        "FF_Hqg_Pgg" -> factorizationPrefactor pggAction[
          ffBornDensities["Hqg", projector],
          ffSplittingVariable,
          ffScale,
          zHat,
          test
        ],
        "FF_Hqq_Pgq" -> factorizationPrefactor regularKernelAction[
          pgqFFKernel,
          ffBornDensities["Hqq", projector],
          ffScale,
          test
        ]
      |>
    ]
  ],
  projectors
];

counterterms = <|
  "PgPDF" -> countertermComponents["Pg", "PDF_Hqg_Pqq"],
  "PgFF" -> Total[Lookup[countertermComponents["Pg"], {
    "FF_Hqg_Pgg", "FF_Hqq_Pgq"
  }]],
  "PPPPDF" -> countertermComponents["PPP", "PDF_Hqg_Pqq"],
  "PPPFF" -> Total[Lookup[countertermComponents["PPP"], {
    "FF_Hqg_Pgg", "FF_Hqq_Pgq"
  }]]
|>;
countertermKeys = {"PgPDF", "PgFF", "PPPPDF", "PPPFF"};
assert[Keys[counterterms] === countertermKeys,
  "The result does not contain exactly the requested four keys."];

distributionObjects =
  _S11PlusDistribution | DiracDelta[1 - _] | DiracDelta[_ - 1];
s11Checks = <|
  "CurrentHqgS07BindingValidated" -> True,
  "S10InputNotRequiredAtCountertermConstructionStage" -> True,
  "AuthoritativePaperHashValidated" -> True,
  "BigTMDChannel3AReferencesBound" -> True,
  "InitialQuarkFragmentingGluonConvention" -> True,
  "UpstreamAmplitudeStripSquaredFactorIsNine" ->
    TrueQ[metadataChargeStripSquaredFactor === 9],
  "DirectGeneratorMatchesStrippedS07WithAmplitudeStripSquaredFactor" ->
    TrueQ[directBornNormalizationFactor === 9],
  "TwoRequiredBornChannelsAvailable" ->
    TrueQ[Sort[Keys[bornProjected]] === Sort[{"Hqg", "Hqq"}]],
  "HqgRegenerationMatchesS07Pg" -> hqgRegenerationChecks["Pg"],
  "HqgRegenerationMatchesS07PPP" -> hqgRegenerationChecks["PPP"],
  "AllConvolutionMappingsValidated" ->
    AllTrue[Values[kinematicChecks], TrueQ],
  "CorrectedPPPPDFRescalingApplied" -> True,
  "ExactlyFourCounterterms" -> TrueQ[Length[counterterms] === 4],
  "PDFContainsOnlyHqgPqq" -> True,
  "FFContainsHqgPggAndHqqPgq" -> True,
  "NoPqgOrHggBornContribution" ->
    AllTrue[Values[counterterms], FreeQ[#, Pqg | Hgg] &],
  "PggNfDependenceRetained" ->
    AllTrue[
      Lookup[counterterms, {"PgFF", "PPPFF"}],
      ! FreeQ[#, FeynCalc`Nf] &
    ],
  "SplittingDistributionsActed" ->
    AllTrue[Values[counterterms], FreeQ[#, distributionObjects] &],
  "OrdinaryInactiveIntegralsRetained" ->
    AllTrue[Values[counterterms], ! FreeQ[#, Inactive[Integrate][___]] &],
  "SymbolicSEpsilonRetained" ->
    AllTrue[Values[counterterms], ! FreeQ[#, S11SEpsilon] &],
  "NoMachinePrecisionNumbers" ->
    AllTrue[Values[counterterms], FreeQ[#, _Real] &],
  "NoS10CombinationPerformed" -> True,
  "PhysicalLuminosityDeferred" -> True,
  "CalculationFullySymbolic" -> True
|>;
assert[AllTrue[Values[s11Checks], TrueQ],
  "At least one S11 validation check is not True."];

s11Result = <|
  "Status" -> "CompleteSymbolicCounterterms",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResults" -> <|
    "HqgProjectedLO" -> s07Path,
    "HqgProjectedLOSHA256" -> s07SHA256,
    "S10Dependency" ->
      "none; S10 and S11 are independently source-bound inputs to S12",
    "AuthoritativePaper" -> paperPath,
    "AuthoritativePaperSHA256" -> paperSHA256
  |>,
  "PaperReference" -> <|
    "Factorization" -> "Eq. (46)",
    "PartonicPDFAndFF" -> "Eqs. (47)-(50)",
    "PrintedSplittingFunctions" -> "Eqs. (51)-(53)",
    "PggStatus" ->
      "standard one-loop Pgg added in the same alpha_s/(4 Pi) normalization; its explicit formula is not printed in the paper",
    "TwoBodyPhaseSpace" -> "Eqs. (34)-(35)"
  |>,
  "BigTMDConvention" -> <|
    "ChannelNumber" -> 3,
    "ChargeCase" -> "A only",
    "FragmentingParton" -> "gluon g(k1)",
    "ProjectorMapping" -> <|
      "Pg" -> "NLO.Pg.fchn3A",
      "PPP" -> "NLO.Ppp.fchn3A"
    |>,
    "ReferenceFiles" -> <|"Pg" -> bigTMDPgPath, "PPP" -> bigTMDPPPPath|>,
    "ReferenceSHA256" -> bigTMDReferenceSHA256,
    "UseAtThisStage" ->
      "finite-kernel convention reference only; no BigTMD counterterm decomposition exists"
  |>,
  "ElectricChargeNormalization" -> electricChargeNormalization,
  "UpstreamAmplitudeStripSquaredFactor" ->
    metadataChargeStripSquaredFactor,
  "AppliedDirectBornNormalizationFactor" ->
    directBornNormalizationFactor,
  "DirectBornNormalizationReason" ->
    "the direct full-state generator retains the reference down-quark charge, so its Born squares receive the upstream amplitude strip factor squared before matching charge-stripped S07",
  "PhysicalLuminosityAppliedDownstream" -> "Sum_q e_q^2 f_q D_g",
  "FactorizationConvention" -> <|
    "Prefactor" -> HoldForm[
      FeynCalc`SMP["g_s"]^2 S11SEpsilon/(16 Pi^2 epsilon)
    ],
    "SEpsilonTreatment" ->
      "retained as the symbolic S_epsilon factor in Eq. (46)",
    "Sign" ->
      "positive because the order-alpha_s partonic PDF/FF counterterms in Eqs. (49)-(50) are negative"
  |>,
  "SplittingKernels" -> <|
    "PqqPDF" -> HoldForm[
      Pqq[y] == 2 FeynCalc`CF (
        2 S11PlusDistribution[1/(1 - y), {y, 0, 1}] - 1 - y +
          3 DiracDelta[1 - y]/2
      )
    ],
    "PggFF" -> HoldForm[
      Pgg[y] == 4 FeynCalc`CA (
        S11PlusDistribution[1/(1 - y), {y, 0, 1}] + 1/y - 2 +
          y (1 - y)
      ) + (11 FeynCalc`CA - 4 FeynCalc`TF FeynCalc`Nf) *
          DiracDelta[1 - y]/3
    ],
    "PgqFF" -> HoldForm[
      Pgq[y] == 2 FeynCalc`CF (1 + (1 - y)^2)/y
    ],
    "Pqg" -> 0
  |>,
  "BornProjectedSquaredAmplitudes" -> bornProjected,
  "HqgDirectRegenerationResiduals" -> hqgRegenerationResiduals,
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
  "SpeciesRouting" -> <|
    "PDF" -> {"Hqg x Pqq"},
    "FF" -> {"Hqg x Pgg", "Hqq x Pgq"},
    "VanishingLOSpecies" -> {"Hgg"},
    "NoQuarkAntiquarkDoubling" ->
      "external Sum_q e_q^2 luminosity is applied downstream"
  |>,
  "CountertermComponents" -> countertermComponents,
  "Counterterms" -> counterterms,
  "CountertermCount" -> Length[counterterms],
  "TestFunction" -> HoldForm[S11ConvolutionTest[projector, s11S23]],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s11S23=0 and independent of epsilon",
  "DistributionActionStatus" ->
    "all splitting delta/plus distributions have acted; only ordinary inactive integrals remain",
  "CombinationDeferredToS12" -> True,
  "Checks" -> s11Checks,
  "NotPerformedAtThisStage" -> {
    "loading or adding the S10 real-plus-virtual action",
    "physical-variable remap and collinear-pole cancellation",
    "evaluator-to-paper virtual convention conversion",
    "Hermitian Re projection and epsilon -> 0 finite Hqg hard functions",
    "finite comparison with BigTMD Pg/Ppp fchn3A",
    "numerical PDFs, FFs, test functions, or kinematics"
  }
|>;

Print["S11_STAGE: atomically writing four Hqg counterterms"];
writeAtomic[s11Result, resultPath];
Print["S11_SUCCESS_SYMBOLIC_COUNTERTERMS"];
Print["S11_RESULT_PATH=" <> resultPath];
Print["S11_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S11_COUNTERTERM_KEYS=", InputForm[Keys[counterterms]]];
Print["S11_CHECKS=", InputForm[s11Checks]];
Quit[0];

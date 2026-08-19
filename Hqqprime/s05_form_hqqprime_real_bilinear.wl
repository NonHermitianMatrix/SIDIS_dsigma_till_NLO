(* ::Package:: *)

(*
  Hqqprime S05: form the charge-resolved real amplitude bilinear for

    gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3).

  S01 stores truncated kernels.  FeynCalc complex conjugation requires full
  external wavefunctions, so this stage regenerates only the accepted S01
  diagram containers with Truncated -> False.  Wolfram then derives the full
  incoming-line and prime-pair charge amplitudes, opens the photon indices,
  and extracts the Qq^2, QqPrime^2, and Qq QqPrime tensors from the generic
  product.  No relative charge-tensor sign is inserted by hand.

  Spin/color sums, the incoming-quark average, projectors, phase space,
  factorization, and physical flavor/charge assembly remain deferred.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, atomicPut, couplingOccurrenceSignature,
  convertFullAmplitudes, openPhotonIndex, conjugateOpenAmplitude,
  scriptDirectory, programPath, scriptsDirectory, s01SourcePath,
  s01ResultPath, s04SourcePath, s04ResultPath, referencePDFPath,
  s05ResultPath, preflightOnly, expectedS01SourceSHA256,
  expectedS01ResultSHA256, expectedS04SourceSHA256,
  expectedS04ResultSHA256, expectedReferencePDFSHA256,
  staleTemporaryPaths, inputSpecifications, s01, s04, conventions,
  representativeOrder, representatives, measuredDiagramCounts,
  requiredRepresentativeKeys, masslessRules, fullAmplitudesByRepresentative,
  fullDiagramCounts, fullCouplingSignatures, fullSumsByRepresentative,
  expectedExternalSpinors, externalSpinorsByRepresentative,
  externalSpinorChecks, outgoingFieldMultiplicities,
  derivedSymmetryFactors, modelChargeCoefficients,
  representativeChargeAssignments, chargeBasisSolutions,
  fullChargeBasisAmplitudes, incomingLineFullAmplitude,
  primePairFullAmplitude, fullRepresentativeResiduals,
  genericChargeSymbols, genericFullAmplitude,
  genericFullRepresentativeResiduals, chargeBasisSpinors,
  openRepresentativeAmplitudesMu, incomingLineOpenAmplitudeMu,
  primePairOpenAmplitudeMu, openRepresentativeResiduals,
  genericOpenAmplitudeMu, incomingLineConjugateAmplitudeNu,
  primePairConjugateAmplitudeNu, genericConjugateAmplitudeNu,
  incomingSquaredTensor, primeSquaredTensor,
  incomingPrimeOrderedTensor, primeIncomingOrderedTensor,
  mixedChargeTensor, chargeResolvedCoreTensors,
  genericChargePolynomialCore, expandedGenericChargePolynomial,
  coefficientExtractedTensors, coefficientExtractionResiduals,
  chargePolynomialReconstruction, chargePolynomialResidual,
  representativeDiagramCount, coherentOrderedDiagramPairCount,
  strongCouplingPowerInAmplitude, dimensionalScaleExponent,
  dimensionalScaleFactor, scaleAttachedChargeTensors,
  scaleAttachedGenericTensor, symbolicPayload, openTensorPayload,
  loopOrRegulatorPattern,
  programSHA256, checks, s05Result, reloadedResult,
  temporaryResultPath, resultSHA256
];

fatal[message_String] := (
  If[
    ValueQ[temporaryResultPath] && StringQ[temporaryResultPath] &&
      StringLength[temporaryResultPath] > 0 &&
      FileExistsQ[temporaryResultPath],
    Quiet[DeleteFile[temporaryResultPath]]
  ];
  Print["S05_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] := If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

atomicPut[expression_, finalPath_String] := Module[
  {writeSucceeded, loaded, renameSucceeded},

  assert[! FileExistsQ[finalPath],
    "refusing to overwrite the final S05 result"];
  temporaryResultPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[! FileExistsQ[temporaryResultPath],
    "process-specific S05 temporary result already exists"];

  writeSucceeded = Quiet @ Check[
    Put[expression, temporaryResultPath];
    FileExistsQ[temporaryResultPath] && FileByteCount[temporaryResultPath] > 0,
    False
  ];
  If[! TrueQ[writeSucceeded],
    If[FileExistsQ[temporaryResultPath], DeleteFile[temporaryResultPath]];
    fatal["failed to write the temporary S05 result"]
  ];

  loaded = Quiet @ Check[Get[temporaryResultPath], $Failed];
  If[
    ! AssociationQ[loaded] ||
      loaded["Status"] =!= "Complete" ||
      loaded["Stage"] =!= "HqqprimeS05-v1" ||
      ! And @@ (TrueQ /@ Values[loaded["Checks"]]),
    DeleteFile[temporaryResultPath];
    fatal["temporary S05 result failed reload/schema validation"]
  ];
  If[! SameQ[loaded, expression],
    DeleteFile[temporaryResultPath];
    fatal["temporary S05 result failed exact reload validation"]
  ];

  renameSucceeded = Quiet @ Check[
    RenameFile[temporaryResultPath, finalPath];
    True,
    False
  ];
  If[! TrueQ[renameSucceeded],
    If[FileExistsQ[temporaryResultPath], DeleteFile[temporaryResultPath]];
    fatal["failed to atomically publish the S05 result"]
  ];
  temporaryResultPath = "";

  assert[FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "published S05 result is missing or empty"];
];

couplingOccurrenceSignature[amplitude_] := {
  Count[amplitude, HoldPattern[FeynArts`FCGV["EL"]], Infinity],
  Count[amplitude, HoldPattern[FeynCalc`SMP["g_s"]], Infinity]
};

convertFullAmplitudes[diagrams_, label_String] := Module[{raw, converted},
  Print["S05_STAGE: restoring full external states for " <> label];
  raw = Quiet @ Check[
    FeynArts`CreateFeynAmp[
      diagrams,
      FeynArts`Truncated -> False
    ],
    $Failed
  ];
  assert[raw =!= $Failed,
    label <> " full FeynArts amplitude generation failed"];

  converted = CheckAbort[
    Quiet @ Check[
      FeynCalc`FCFAConvert[
        raw,
        FeynCalc`IncomingMomenta -> conventions["IncomingMomenta"],
        FeynCalc`OutgoingMomenta -> conventions["OutgoingMomenta"],
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
    ],
    $Failed
  ];
  assert[ListQ[converted],
    label <> " full FCFAConvert did not return a list"];
  assert[FreeQ[converted, _FeynArts`FAFeynAmp],
    label <> " full conversion left a FeynArts amplitude unevaluated"];
  converted
];

(*
  Contract can place the incoming photon polarization in a slashed vector,
  either scalar-product order, a Lorentz pair, or an epsilon tensor.  Only
  the q polarization is opened; every external fermion spinor is retained.
*)
openPhotonIndex[amplitude_, openIndex_Symbol, label_String] := Module[
  {contracted, answer},

  contracted = FeynCalc`Contract[amplitude];
  assert[! FreeQ[contracted, FeynCalc`Polarization[q, ___]],
    label <> " contains no incoming-photon polarization to open"];

  answer = contracted /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        dimension_
      ]
    ] :> FeynCalc`DiracGamma[
      FeynCalc`LorentzIndex[openIndex, dimension],
      dimension
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`LorentzIndex[lorentz_, dimension_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[lorentz, dimension],
      FeynCalc`LorentzIndex[openIndex, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        FeynCalc`LorentzIndex[lorentz_, dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[openIndex, dimension],
      FeynCalc`LorentzIndex[lorentz, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        FeynCalc`Momentum[momentum_, dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`LorentzIndex[openIndex, dimension],
      FeynCalc`Momentum[momentum, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[
        FeynCalc`Momentum[momentum_, dimension_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_]
      ]
    ] :> FeynCalc`Pair[
      FeynCalc`Momentum[momentum, dimension],
      FeynCalc`LorentzIndex[openIndex, dimension]
    ];
  answer = answer /. HoldPattern[
      FeynCalc`Eps[
        before___,
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dimension_],
        after___
      ]
    ] :> FeynCalc`Eps[
      before,
      FeynCalc`LorentzIndex[openIndex, dimension],
      after
    ];

  answer = FeynCalc`Contract[answer];
  assert[FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " still contains the incoming-photon polarization"];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[openIndex, D]],
    label <> " does not contain the requested open photon index"];
  assert[! FreeQ[answer, _FeynCalc`Spinor],
    label <> " lost its external fermion wavefunctions"];
  answer
];

conjugateOpenAmplitude[
    amplitude_, oldIndex_Symbol, newIndex_Symbol, label_String
  ] := Module[{answer},
  answer = CheckAbort[
    Quiet @ Check[
      FeynCalc`ComplexConjugate[
        amplitude /. oldIndex -> newIndex,
        FeynCalc`FCRenameDummyIndices -> True,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  assert[answer =!= $Failed, label <> " complex conjugation failed"];
  assert[FreeQ[answer, FeynCalc`ComplexConjugate],
    label <> " left an unevaluated FeynCalc ComplexConjugate call"];
  assert[! FreeQ[answer, FeynCalc`LorentzIndex[newIndex, D]],
    label <> " conjugate is missing the second photon index"];
  assert[! FreeQ[answer, _FeynCalc`Spinor],
    label <> " conjugate lost the external fermion wavefunctions"];
  answer
];

programPath = ExpandFileName[$InputFileName];
scriptDirectory = DirectoryName[programPath];
scriptsDirectory = DirectoryName[scriptDirectory];
s01SourcePath =
  FileNameJoin[{scriptDirectory, "s01_calculate_hqqprime_tree.wl"}];
s01ResultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
s04SourcePath = FileNameJoin[
  {scriptDirectory, "s04_validate_hqqprime_virtual_absence.wl"}
];
s04ResultPath = FileNameJoin[{scriptDirectory, "s04_result"}];
referencePDFPath = FileNameJoin[
  {
    scriptsDirectory,
    "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
      "Scattering_Beyond_Lowest_Order.pdf"
  }
];
s05ResultPath = FileNameJoin[{scriptDirectory, "s05_result"}];
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S05_PREFLIGHT_ONLY"], ""] === "1";

expectedS01SourceSHA256 =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultSHA256 =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedS04SourceSHA256 =
  "9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc";
expectedS04ResultSHA256 =
  "2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84";
expectedReferencePDFSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";

Print["S05_STAGE: validating clean boundary and pinned S01/S04 inputs"];

assert[! FileExistsQ[s05ResultPath],
  "s05_result already exists; refusing to overwrite it"];
staleTemporaryPaths = FileNames["s05_result.tmp.*", scriptDirectory];
assert[staleTemporaryPaths === {},
  "stale S05 temporary result exists: " <>
    ToString[staleTemporaryPaths, InputForm]];

inputSpecifications = <|
  "S01 source" -> {s01SourcePath, expectedS01SourceSHA256},
  "S01 result" -> {s01ResultPath, expectedS01ResultSHA256},
  "S04 source" -> {s04SourcePath, expectedS04SourceSHA256},
  "S04 result" -> {s04ResultPath, expectedS04ResultSHA256},
  "authoritative paper" -> {referencePDFPath, expectedReferencePDFSHA256}
|>;
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing"];
    assert[fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff"];
  ],
  inputSpecifications
];

s01 = Quiet @ Check[Get[s01ResultPath], $Failed];
s04 = Quiet @ Check[Get[s04ResultPath], $Failed];
assert[AssociationQ[s01] && AssociationQ[s04],
  "an upstream result did not reload as an Association"];

assert[
  s01["Status"] === "Complete" &&
    s01["Stage"] === "HqqprimeS01-v1" &&
    s01["Channel"] === "Hqqprime only",
  "accepted S01 identity mismatch"
];
assert[
  s04["Status"] === "Complete" &&
    s04["Stage"] === "HqqprimeS04-v1" &&
    s04["Channel"] === "Hqqprime only" &&
    s04["StageDisposition"] === "NotApplicableAtThisOrder",
  "accepted S04 identity or disposition mismatch"
];
assert[
  s01["ProgramSHA256"] === expectedS01SourceSHA256 &&
    s01["ReferencePDFSHA256"] === expectedReferencePDFSHA256 &&
    s04["ProgramSHA256"] === expectedS04SourceSHA256 &&
    s04["ReferencePDFSHA256"] === expectedReferencePDFSHA256,
  "an upstream result has incorrect embedded source/reference provenance"
];
assert[
  s04["Inputs", "S01ProgramSHA256"] === expectedS01SourceSHA256 &&
    s04["Inputs", "S01ResultSHA256"] === expectedS01ResultSHA256,
  "S04 does not bind the accepted S01 handoff"
];
assert[
  And @@ (TrueQ /@ Values[s01["Checks"]]) &&
    And @@ (TrueQ /@ Values[s04["Checks"]]),
  "an upstream check ledger contains a non-True entry"
];
assert[
  Keys[s04["AbsentContributions"]] === {
    "TwoBodyBorn", "OneLoopVirtual", "LoopPole", "UVCounterterm"
  } &&
  And @@ (
    IntegerQ[#] && # === 0 & /@ Values[s04["AbsentContributions"]]
  ),
  "S04 absent-sector ledger is invalid"
];

assert[
  s01["Process"] ===
    "gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3)" &&
  s01["PerturbativeOrder"] ===
    "tree 2->3 contribution to the O(alpha_s^2) hard part",
  "accepted S01 process/order mismatch"
];
conventions = s01["Conventions"];
assert[AssociationQ[conventions], "accepted S01 conventions are missing"];
assert[
  conventions["Dimension"] === HoldForm[D == 4 - 2 epsilon] &&
    conventions["IncomingMomenta"] === {q, p} &&
    conventions["OutgoingMomenta"] === {k1, k2, k3} &&
    conventions["FragmentingMomentum"] === k1 &&
    conventions["FragmentingFlavor"] ===
      "qPrime different from incoming q" &&
    conventions["UnobservedOrderedFlavors"] === {"q", "qbarPrime"} &&
    conventions["Masses"] === "all quarks massless" &&
    TrueQ[conventions["ElectromagneticCouplingRetained"]] &&
    TrueQ[conventions["NoFlavorMultiplicityApplied"]],
  "accepted S01 momentum/flavour/dimensional convention mismatch"
];

representativeOrder = {"up_up", "up_down", "down_up"};
representatives = s01["Representatives"];
measuredDiagramCounts = s01["MeasuredSelectedDiagramCounts"];
assert[
  AssociationQ[representatives] && Keys[representatives] === representativeOrder &&
    AssociationQ[measuredDiagramCounts] &&
    Keys[measuredDiagramCounts] === representativeOrder,
  "accepted representative/count order mismatch"
];
requiredRepresentativeKeys = {
  "Label", "IncomingField", "PrimeField", "OutgoingFields",
  "IncomingMomenta", "OutgoingMomenta", "SelectedDiagramNumbers",
  "SelectedDiagramCount", "SelectedDiagrams",
  "FeynCalcAmplitudesPerDiagram", "FeynCalcAmplitudeSum"
};
assert[
  AllTrue[
    representativeOrder,
    Function[label,
      ContainsAll[Keys[representatives[label]], requiredRepresentativeKeys] &&
      representatives[label, "Label"] === label &&
      representatives[label, "IncomingField"] =!=
        representatives[label, "PrimeField"] &&
      representatives[label, "OutgoingFields"] === {
        representatives[label, "PrimeField"],
        representatives[label, "IncomingField"],
        -representatives[label, "PrimeField"]
      } &&
      representatives[label, "IncomingMomenta"] ===
        conventions["IncomingMomenta"] &&
      representatives[label, "OutgoingMomenta"] ===
        conventions["OutgoingMomenta"] &&
      representatives[label, "SelectedDiagramCount"] ===
        measuredDiagramCounts[label] &&
      Length[representatives[label, "SelectedDiagrams"]] ===
        measuredDiagramCounts[label] &&
      Total[representatives[label, "FeynCalcAmplitudesPerDiagram"]] ===
        representatives[label, "FeynCalcAmplitudeSum"]
    ]
  ],
  "an accepted representative failed the S05 input contract"
];
assert[Apply[SameQ, Values[measuredDiagramCounts]],
  "accepted representative diagram counts are not equal"];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

Print["S05_STAGE: regenerating the three full-state representatives"];
fullAmplitudesByRepresentative = AssociationMap[
  Function[label,
    convertFullAmplitudes[
      representatives[label, "SelectedDiagrams"],
      label
    ]
  ],
  representativeOrder
];
fullDiagramCounts = Length /@ fullAmplitudesByRepresentative;
assert[fullDiagramCounts === measuredDiagramCounts,
  "full-state diagram counts do not reproduce accepted S01 counts"];

fullCouplingSignatures = Map[
  couplingOccurrenceSignature /@ # &,
  fullAmplitudesByRepresentative
];
assert[
  And @@ Flatten[
    Map[(# === {1, 2} & /@ #) &, Values[fullCouplingSignatures]]
  ],
  "a full amplitude does not contain exactly one EL and two g_s vertices"
];
assert[FreeQ[fullAmplitudesByRepresentative, _Real],
  "a machine-real number appeared in full representative amplitudes"];

fullSumsByRepresentative = Total /@ fullAmplitudesByRepresentative;
assert[And @@ (# =!= 0 & /@ Values[fullSumsByRepresentative]),
  "a coherent full representative amplitude is zero"];

expectedExternalSpinors = {
  FeynCalc`Spinor[FeynCalc`Momentum[k1, D], 0, 1],
  FeynCalc`Spinor[-FeynCalc`Momentum[k3, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[k2, D], 0, 1],
  FeynCalc`Spinor[FeynCalc`Momentum[p, D], 0, 1]
};
externalSpinorsByRepresentative = AssociationMap[
  DeleteDuplicates @ Cases[
    fullSumsByRepresentative[#],
    _FeynCalc`Spinor,
    Infinity
  ] &,
  representativeOrder
];
externalSpinorChecks = AssociationMap[
  Function[label,
    Length[externalSpinorsByRepresentative[label]] ===
      Length[expectedExternalSpinors] &&
    And @@ (
      MemberQ[externalSpinorsByRepresentative[label], #] & /@
        expectedExternalSpinors
    ) &&
    And @@ (
      MemberQ[expectedExternalSpinors, #] & /@
        externalSpinorsByRepresentative[label]
    )
  ],
  representativeOrder
];
assert[And @@ Values[externalSpinorChecks],
  "a full representative lacks the four measured spinor orientations"];

outgoingFieldMultiplicities = AssociationMap[
  Counts[representatives[#, "OutgoingFields"]] &,
  representativeOrder
];
derivedSymmetryFactors = AssociationMap[
  Function[label,
    Times @@ (
      (1/Factorial[#] &) /@ Values[outgoingFieldMultiplicities[label]]
    )
  ],
  representativeOrder
];
assert[And @@ (# === 1 & /@ Values[derivedSymmetryFactors]),
  "a nontrivial identical-final-state symmetry factor was derived"];

Print["S05_STAGE: solving the full external-state two-charge basis"];
modelChargeCoefficients = s01["ModelChargeCoefficients"];
representativeChargeAssignments = s01["RepresentativeChargeAssignments"];
assert[
  AssociationQ[modelChargeCoefficients] &&
    Keys[modelChargeCoefficients] === {"UpType", "DownType"} &&
    AllTrue[Values[modelChargeCoefficients],
      MatchQ[#, _Integer | _Rational] &] &&
    modelChargeCoefficients["UpType"] =!=
      modelChargeCoefficients["DownType"],
  "accepted SMQCD charge coefficients are invalid"
];
assert[
  AssociationQ[representativeChargeAssignments] &&
    Keys[representativeChargeAssignments] === representativeOrder &&
    FreeQ[representativeChargeAssignments, _Real],
  "accepted representative charge assignments are invalid"
];

chargeBasisSolutions = Solve[
  {
    s05RepresentativeUU ==
      representativeChargeAssignments["up_up", "IncomingCharge"] *
        s05IncomingLineFullAmplitude +
      representativeChargeAssignments["up_up", "PrimeCharge"] *
        s05PrimePairFullAmplitude,
    s05RepresentativeUD ==
      representativeChargeAssignments["up_down", "IncomingCharge"] *
        s05IncomingLineFullAmplitude +
      representativeChargeAssignments["up_down", "PrimeCharge"] *
        s05PrimePairFullAmplitude
  },
  {s05IncomingLineFullAmplitude, s05PrimePairFullAmplitude}
];
assert[Length[chargeBasisSolutions] === 1,
  "full external-state charge-basis solve was not unique"];

fullChargeBasisAmplitudes = Expand[
  {s05IncomingLineFullAmplitude, s05PrimePairFullAmplitude} /.
    First[chargeBasisSolutions] /.
    {
      s05RepresentativeUU -> fullSumsByRepresentative["up_up"],
      s05RepresentativeUD -> fullSumsByRepresentative["up_down"]
    }
];
incomingLineFullAmplitude = fullChargeBasisAmplitudes[[1]];
primePairFullAmplitude = fullChargeBasisAmplitudes[[2]];
assert[incomingLineFullAmplitude =!= 0 && primePairFullAmplitude =!= 0,
  "a derived full-state charge-basis amplitude is zero"];

fullRepresentativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      assignment["IncomingCharge"] incomingLineFullAmplitude +
      assignment["PrimeCharge"] primePairFullAmplitude -
      fullSumsByRepresentative[label]
    ]
  ],
  representativeChargeAssignments
];
assert[And @@ (# === 0 & /@ Values[fullRepresentativeResiduals]),
  "full-state charge basis failed representative reconstruction"];

genericChargeSymbols = s01["ChargeBasis", "GenericChargeSymbols"];
assert[MatchQ[genericChargeSymbols, {_Symbol, _Symbol}] &&
    DuplicateFreeQ[genericChargeSymbols],
  "accepted generic charge symbols are not two distinct symbols"];
genericFullAmplitude = Expand[
  genericChargeSymbols[[1]] incomingLineFullAmplitude +
  genericChargeSymbols[[2]] primePairFullAmplitude
];
genericFullRepresentativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      (genericFullAmplitude /.
        Thread[
          genericChargeSymbols -> {
            assignment["IncomingCharge"], assignment["PrimeCharge"]
          }
        ]) - fullSumsByRepresentative[label]
    ]
  ],
  representativeChargeAssignments
];
assert[And @@ (# === 0 & /@ Values[genericFullRepresentativeResiduals]),
  "generic full-state amplitude failed representative reconstruction"];

chargeBasisSpinors = <|
  "IncomingLineAmplitude" ->
    DeleteDuplicates @ Cases[
      incomingLineFullAmplitude, _FeynCalc`Spinor, Infinity
    ],
  "PrimePairLineAmplitude" ->
    DeleteDuplicates @ Cases[
      primePairFullAmplitude, _FeynCalc`Spinor, Infinity
    ]
|>;
assert[
  And @@ KeyValueMap[
    Function[{label, spinors},
      Length[spinors] === Length[expectedExternalSpinors] &&
      And @@ (MemberQ[spinors, #] & /@ expectedExternalSpinors) &&
      And @@ (MemberQ[expectedExternalSpinors, #] & /@ spinors)
    ],
    chargeBasisSpinors
  ],
  "a full charge-basis amplitude lacks the four external spinors"
];

Print["S05_STAGE: opening the incoming-photon index"];
openRepresentativeAmplitudesMu = AssociationMap[
  openPhotonIndex[
    fullSumsByRepresentative[#],
    s05Mu,
    # <> " representative"
  ] &,
  representativeOrder
];
incomingLineOpenAmplitudeMu = openPhotonIndex[
  incomingLineFullAmplitude,
  s05Mu,
  "incoming-line charge amplitude"
];
primePairOpenAmplitudeMu = openPhotonIndex[
  primePairFullAmplitude,
  s05Mu,
  "prime-pair charge amplitude"
];

openRepresentativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      assignment["IncomingCharge"] incomingLineOpenAmplitudeMu +
      assignment["PrimeCharge"] primePairOpenAmplitudeMu -
      openRepresentativeAmplitudesMu[label]
    ]
  ],
  representativeChargeAssignments
];
assert[And @@ (# === 0 & /@ Values[openRepresentativeResiduals]),
  "open-index charge basis failed representative reconstruction"];

genericOpenAmplitudeMu =
  genericChargeSymbols[[1]] incomingLineOpenAmplitudeMu +
  genericChargeSymbols[[2]] primePairOpenAmplitudeMu;

Print["S05_STAGE: evaluating the two charge-basis conjugates"];
incomingLineConjugateAmplitudeNu = conjugateOpenAmplitude[
  incomingLineOpenAmplitudeMu,
  s05Mu,
  s05Nu,
  "incoming-line charge amplitude"
];
primePairConjugateAmplitudeNu = conjugateOpenAmplitude[
  primePairOpenAmplitudeMu,
  s05Mu,
  s05Nu,
  "prime-pair charge amplitude"
];

(* Quark electric charges are real; keep them outside ComplexConjugate. *)
genericConjugateAmplitudeNu =
  genericChargeSymbols[[1]] incomingLineConjugateAmplitudeNu +
  genericChargeSymbols[[2]] primePairConjugateAmplitudeNu;

Print["S05_STAGE: deriving the three charge tensors from the generic product"];
incomingSquaredTensor =
  incomingLineOpenAmplitudeMu incomingLineConjugateAmplitudeNu;
primeSquaredTensor =
  primePairOpenAmplitudeMu primePairConjugateAmplitudeNu;
incomingPrimeOrderedTensor =
  incomingLineOpenAmplitudeMu primePairConjugateAmplitudeNu;
primeIncomingOrderedTensor =
  primePairOpenAmplitudeMu incomingLineConjugateAmplitudeNu;
mixedChargeTensor =
  incomingPrimeOrderedTensor + primeIncomingOrderedTensor;

chargeResolvedCoreTensors = <|
  "IncomingChargeSquared" -> incomingSquaredTensor,
  "PrimeChargeSquared" -> primeSquaredTensor,
  "MixedIncomingPrimeCharge" -> mixedChargeTensor
|>;
genericChargePolynomialCore =
  genericOpenAmplitudeMu genericConjugateAmplitudeNu;
expandedGenericChargePolynomial = Expand[genericChargePolynomialCore];
assert[
  PolynomialQ[expandedGenericChargePolynomial, genericChargeSymbols],
  "generic bilinear is not polynomial in the two charge symbols"
];
assert[
  (Exponent[expandedGenericChargePolynomial, #] === 2 &) /@
      genericChargeSymbols === {True, True},
  "generic bilinear is not quadratic in each charge symbol"
];

coefficientExtractedTensors = <|
  "IncomingChargeSquared" -> Coefficient[
    expandedGenericChargePolynomial,
    genericChargeSymbols[[1]],
    2
  ],
  "PrimeChargeSquared" -> Coefficient[
    expandedGenericChargePolynomial,
    genericChargeSymbols[[2]],
    2
  ],
  "MixedIncomingPrimeCharge" -> Coefficient[
    Coefficient[
      expandedGenericChargePolynomial,
      genericChargeSymbols[[1]],
      1
    ],
    genericChargeSymbols[[2]],
    1
  ]
|>;
coefficientExtractionResiduals = AssociationMap[
  Simplify @ Expand[
    coefficientExtractedTensors[#] - chargeResolvedCoreTensors[#]
  ] &,
  Keys[chargeResolvedCoreTensors]
];
assert[And @@ (# === 0 & /@ Values[coefficientExtractionResiduals]),
  "coefficient extraction failed to reproduce a charge tensor"];

chargePolynomialReconstruction =
  genericChargeSymbols[[1]]^2 incomingSquaredTensor +
  genericChargeSymbols[[2]]^2 primeSquaredTensor +
  genericChargeSymbols[[1]] genericChargeSymbols[[2]] mixedChargeTensor;
chargePolynomialResidual = Simplify @ Expand[
  genericChargePolynomialCore - chargePolynomialReconstruction
];
assert[chargePolynomialResidual === 0,
  "three-tensor charge polynomial reconstruction failed"];

representativeDiagramCount = First[Values[fullDiagramCounts]];
coherentOrderedDiagramPairCount = representativeDiagramCount^2;
assert[
  IntegerQ[representativeDiagramCount] && representativeDiagramCount > 0 &&
    IntegerQ[coherentOrderedDiagramPairCount] &&
    coherentOrderedDiagramPairCount > 0,
  "derived coherent diagram/pair count is invalid"
];

strongCouplingPowerInAmplitude =
  conventions["StrongCouplingPowerInAmplitude"];
assert[IntegerQ[strongCouplingPowerInAmplitude] &&
    strongCouplingPowerInAmplitude > 0,
  "accepted amplitude strong-coupling power is invalid"];
dimensionalScaleExponent =
  2 strongCouplingPowerInAmplitude epsilon;
dimensionalScaleFactor =
  FeynCalc`ScaleMu^dimensionalScaleExponent;
scaleAttachedChargeTensors = Map[
  dimensionalScaleFactor # &,
  chargeResolvedCoreTensors
];
scaleAttachedGenericTensor =
  dimensionalScaleFactor genericChargePolynomialCore;
assert[
  FreeQ[chargeResolvedCoreTensors, FeynCalc`ScaleMu] &&
    FreeQ[genericChargePolynomialCore, FeynCalc`ScaleMu] &&
    And @@ KeyValueMap[
      Function[{key, tensor},
        scaleAttachedChargeTensors[key] === dimensionalScaleFactor tensor
      ],
      chargeResolvedCoreTensors
    ] &&
    scaleAttachedGenericTensor ===
      dimensionalScaleFactor genericChargePolynomialCore,
  "dimensional scale attachment is missing, duplicated, or inconsistent"
];

symbolicPayload = {
  fullAmplitudesByRepresentative,
  fullChargeBasisAmplitudes,
  openRepresentativeAmplitudesMu,
  incomingLineOpenAmplitudeMu,
  primePairOpenAmplitudeMu,
  incomingLineConjugateAmplitudeNu,
  primePairConjugateAmplitudeNu,
  chargeResolvedCoreTensors,
  genericChargePolynomialCore,
  scaleAttachedChargeTensors,
  scaleAttachedGenericTensor
};
openTensorPayload = {
  openRepresentativeAmplitudesMu,
  incomingLineOpenAmplitudeMu,
  primePairOpenAmplitudeMu,
  genericOpenAmplitudeMu,
  incomingLineConjugateAmplitudeNu,
  primePairConjugateAmplitudeNu,
  genericConjugateAmplitudeNu,
  chargeResolvedCoreTensors,
  genericChargePolynomialCore,
  scaleAttachedChargeTensors,
  scaleAttachedGenericTensor
};
loopOrRegulatorPattern =
  FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`A00 | FeynCalc`B0 |
  FeynCalc`B1 | FeynCalc`B00 | FeynCalc`B11 | FeynCalc`C0 |
  FeynCalc`D0 | FeynCalc`E0 | FeynCalc`TID | FeynCalc`TIDL |
  FeynCalc`GLI | FeynCalc`FCTopology | FeynCalc`EpsilonUV |
  FeynCalc`EpsilonIR;

assert[FreeQ[openTensorPayload, FeynCalc`Polarization[q, ___]],
  "incoming-photon polarization remains in the opened/tensor S05 payload"];
assert[
  ! FreeQ[openTensorPayload, FeynCalc`LorentzIndex[s05Mu, D]] &&
    ! FreeQ[openTensorPayload, FeynCalc`LorentzIndex[s05Nu, D]],
  "an S05 photon tensor index is missing"
];
assert[! FreeQ[openTensorPayload, _FeynCalc`Spinor],
  "opened/tensor S05 payload lost external fermion wavefunctions"];
assert[FreeQ[openTensorPayload, FeynCalc`ComplexConjugate],
  "opened/tensor S05 payload contains unevaluated conjugation"];
assert[FreeQ[symbolicPayload, loopOrRegulatorPattern],
  "loop or UV/IR regulator data appeared in the real-only S05 payload"];
assert[FreeQ[symbolicPayload, _Real],
  "machine-real data appeared in the exact symbolic S05 payload"];
assert[
  FreeQ[
    symbolicPayload,
    FeynCalc`FermionSpinSum | FeynCalc`DiracTrace |
      FeynCalc`DoPolarizationSums | FeynCalc`SUNSimplify
  ],
  "a deferred spin/color/polarization operation appears in S05"
];
assert[
  And @@ (
    FreeQ[chargeResolvedCoreTensors, #] & /@ genericChargeSymbols
  ),
  "a charge-resolved coefficient tensor still contains generic charges"
];

programSHA256 = fileSHA256[programPath];
checks = <|
  "PinnedS01SourceHashExact" ->
    (fileSHA256[s01SourcePath] === expectedS01SourceSHA256),
  "PinnedS01ResultHashExact" ->
    (fileSHA256[s01ResultPath] === expectedS01ResultSHA256),
  "PinnedS04SourceHashExact" ->
    (fileSHA256[s04SourcePath] === expectedS04SourceSHA256),
  "PinnedS04ResultHashExact" ->
    (fileSHA256[s04ResultPath] === expectedS04ResultSHA256),
  "PinnedReferenceHashExact" ->
    (fileSHA256[referencePDFPath] === expectedReferencePDFSHA256),
  "AcceptedS01IdentityAndChecks" ->
    (s01["Stage"] === "HqqprimeS01-v1" &&
      And @@ (TrueQ /@ Values[s01["Checks"]])),
  "AcceptedS04NoVirtualGate" ->
    (s04["StageDisposition"] === "NotApplicableAtThisOrder" &&
      And @@ (# === 0 & /@ Values[s04["AbsentContributions"]])),
  "RepresentativeOrderExact" ->
    (Keys[representatives] === representativeOrder),
  "FullCountsMatchMeasuredS01" ->
    (fullDiagramCounts === measuredDiagramCounts),
  "EveryFullDiagramHasOneELAndTwoGSVertices" ->
    And @@ Flatten[
      Map[(# === {1, 2} & /@ #) &, Values[fullCouplingSignatures]]
    ],
  "AllRepresentativesHaveMeasuredExternalSpinors" ->
    And @@ Values[externalSpinorChecks],
  "FullChargeBasisSolveUnique" -> (Length[chargeBasisSolutions] === 1),
  "BothFullChargeBasisAmplitudesNonzero" ->
    (incomingLineFullAmplitude =!= 0 && primePairFullAmplitude =!= 0),
  "FullRepresentativeReconstructionsExact" ->
    And @@ (# === 0 & /@ Values[fullRepresentativeResiduals]),
  "GenericFullRepresentativeReconstructionsExact" ->
    And @@ (# === 0 & /@ Values[genericFullRepresentativeResiduals]),
  "OpenRepresentativeReconstructionsExact" ->
    And @@ (# === 0 & /@ Values[openRepresentativeResiduals]),
  "PhotonPolarizationRemoved" ->
    FreeQ[openTensorPayload, FeynCalc`Polarization[q, ___]],
  "PhotonIndexMuPresent" ->
    ! FreeQ[openTensorPayload, FeynCalc`LorentzIndex[s05Mu, D]],
  "PhotonIndexNuPresent" ->
    ! FreeQ[openTensorPayload, FeynCalc`LorentzIndex[s05Nu, D]],
  "ExternalSpinorsRetainedForS06" ->
    ! FreeQ[openTensorPayload, _FeynCalc`Spinor],
  "FeynCalcConjugationEvaluated" ->
    FreeQ[openTensorPayload, FeynCalc`ComplexConjugate],
  "ChargePolynomialIsQuadratic" ->
    PolynomialQ[expandedGenericChargePolynomial, genericChargeSymbols],
  "ThreeChargeCoefficientsExtractedExactly" ->
    And @@ (# === 0 & /@ Values[coefficientExtractionResiduals]),
  "ThreeTensorPolynomialReconstructionExact" ->
    (chargePolynomialResidual === 0),
  "CoherentPairCountDerivedFromCurrentChannel" ->
    (coherentOrderedDiagramPairCount === representativeDiagramCount^2),
  "AbsoluteScalePowerDerivedAndAttachedOnce" ->
    (dimensionalScaleExponent ===
      2 conventions["StrongCouplingPowerInAmplitude"] epsilon &&
      And @@ KeyValueMap[
        Function[{key, tensor},
          scaleAttachedChargeTensors[key] === dimensionalScaleFactor tensor
        ],
        chargeResolvedCoreTensors
      ]),
  "NoSeparateMSBarSEpsilonAtS05" -> True,
  "FinalStateSymmetryFactorDerivedAsOne" ->
    And @@ (# === 1 & /@ Values[derivedSymmetryFactors]),
  "NoSymmetryFactorAppliedAtS05" -> True,
  "PhysicalFlavorChargeAssemblyDeferred" -> True,
  "IncomingQuarkAverageDeferred" -> True,
  "SpinColorProjectorPhaseSpaceFactorizationDeferred" -> True,
  "NoLoopOrRegulatorData" -> FreeQ[symbolicPayload, loopOrRegulatorPattern],
  "NoMachinePrecisionNumbers" -> FreeQ[symbolicPayload, _Real],
  "AtomicS05ResultWrite" -> True
|>;
assert[And @@ (TrueQ /@ Values[checks]),
  "at least one final S05 acceptance check is false"];

If[preflightOnly,
  Print["S05_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S05_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print["S05_DYNAMIC_PREFLIGHT_DIAGRAM_COUNTS=",
    InputForm[fullDiagramCounts]];
  Print["S05_DYNAMIC_PREFLIGHT_ORDERED_PAIR_COUNT=",
    coherentOrderedDiagramPairCount];
  Print["S05_DYNAMIC_PREFLIGHT_SPINORS=",
    InputForm[expectedExternalSpinors]];
  Print["S05_DYNAMIC_PREFLIGHT_SYMMETRY_FACTORS=",
    InputForm[derivedSymmetryFactors]];
  Print["S05_DYNAMIC_PREFLIGHT_SCALE_FACTOR=",
    InputForm[dimensionalScaleFactor]];
  Print["S05_DYNAMIC_PREFLIGHT_TENSOR_LEAF_COUNTS=",
    InputForm[LeafCount /@ chargeResolvedCoreTensors]];
  Quit[0]
];

s05Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqprimeS05-v1",
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqprime only",
  "Contribution" -> "H_{q qPrime; q qbarPrime} charge-resolved real bilinear",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ReferencePDF" -> referencePDFPath,
  "ReferencePDFSHA256" -> expectedReferencePDFSHA256,
  "Input" -> <|
    "S01SourcePath" -> s01SourcePath,
    "S01SourceSHA256" -> expectedS01SourceSHA256,
    "S01ResultPath" -> s01ResultPath,
    "S01ResultSHA256" -> expectedS01ResultSHA256,
    "S04SourcePath" -> s04SourcePath,
    "S04SourceSHA256" -> expectedS04SourceSHA256,
    "S04ResultPath" -> s04ResultPath,
    "S04ResultSHA256" -> expectedS04ResultSHA256,
    "S04StageDisposition" -> s04["StageDisposition"]
  |>,
  "ExternalProcess" -> <|
    "Incoming" -> {"gamma*(q)", "q(p)"},
    "Outgoing" -> {
      "qPrime(k1, fragmenting)",
      "q(k2, unobserved)",
      "qbarPrime(k3, unobserved)"
    },
    "IncomingMomenta" -> conventions["IncomingMomenta"],
    "OutgoingMomenta" -> conventions["OutgoingMomenta"],
    "ExternalSpinors" -> expectedExternalSpinors,
    "FragmentingParton" -> "qPrime(k1)",
    "UnobservedPartons" -> {"q(k2)", "qbarPrime(k3)"}
  |>,
  "DiagramCounts" -> <|
    "FullRepresentatives" -> fullDiagramCounts,
    "PhysicalRepresentativeDiagramCount" -> representativeDiagramCount,
    "CoherentOrderedDiagramPairs" -> coherentOrderedDiagramPairCount
  |>,
  "FullExternalStateRepresentatives" -> <|
    "PerDiagram" -> fullAmplitudesByRepresentative,
    "CoherentSums" -> fullSumsByRepresentative,
    "CouplingOccurrenceSignatures" -> fullCouplingSignatures,
    "ExternalSpinors" -> externalSpinorsByRepresentative
  |>,
  "ChargeBookkeeping" -> <|
    "GenericChargeSymbols" -> genericChargeSymbols,
    "ModelChargeCoefficients" -> modelChargeCoefficients,
    "RepresentativeChargeAssignments" -> representativeChargeAssignments,
    "ChargeSymbolsTreatedAsReal" -> True,
    "SeparatedTensorKeys" -> Keys[chargeResolvedCoreTensors],
    "PhysicalOrderedFlavorSumAppliedAtS05" -> False,
    "PhysicalAssemblyInstruction" ->
      "Sum over ordered q,qPrime with qPrime different from q while retaining Qq^2, QqPrime^2, and Qq QqPrime tensors separately; do not replace by a bare Nf or Nf-1 factor."
  |>,
  "FullChargeBasis" -> <|
    "IncomingLineAmplitude" -> incomingLineFullAmplitude,
    "PrimePairLineAmplitude" -> primePairFullAmplitude,
    "GenericAmplitude" -> genericFullAmplitude,
    "RepresentativeResiduals" -> fullRepresentativeResiduals,
    "GenericRepresentativeResiduals" ->
      genericFullRepresentativeResiduals,
    "ExternalSpinorsByBasisAmplitude" -> chargeBasisSpinors,
    "Derivation" ->
      "Wolfram Solve from full up_up and up_down sums; full down_up is the independent gate"
  |>,
  "OpenPhotonChargeBasis" -> <|
    "PhotonIndices" -> {s05Mu, s05Nu},
    "RepresentativeAmplitudesMu" -> openRepresentativeAmplitudesMu,
    "IncomingLineAmplitudeMu" -> incomingLineOpenAmplitudeMu,
    "PrimePairLineAmplitudeMu" -> primePairOpenAmplitudeMu,
    "GenericAmplitudeMu" -> genericOpenAmplitudeMu,
    "IncomingLineConjugateNu" -> incomingLineConjugateAmplitudeNu,
    "PrimePairConjugateNu" -> primePairConjugateAmplitudeNu,
    "GenericConjugateNu" -> genericConjugateAmplitudeNu,
    "RepresentativeResiduals" -> openRepresentativeResiduals
  |>,
  "ChargeResolvedBilinears" -> <|
    "PhotonIndices" -> {s05Mu, s05Nu},
    "UnscaledChargeTensors" -> chargeResolvedCoreTensors,
    "MixedOrderedComponents" -> <|
      "IncomingMuPrimeNu" -> incomingPrimeOrderedTensor,
      "PrimeMuIncomingNu" -> primeIncomingOrderedTensor
    |>,
    "CoefficientExtractedTensors" -> coefficientExtractedTensors,
    "CoefficientExtractionResiduals" -> coefficientExtractionResiduals,
    "GenericChargePolynomialCore" -> genericChargePolynomialCore,
    "GenericChargePolynomialReconstruction" ->
      chargePolynomialReconstruction,
    "GenericChargePolynomialResidual" -> chargePolynomialResidual,
    "DimensionalScaleFactor" -> dimensionalScaleFactor,
    "DimensionalScaleExponent" -> dimensionalScaleExponent,
    "ScaleConvention" ->
      "absolute scale derived from two copies of the saved two-strong-vertex amplitude",
    "SeparateMSBarSEpsilonApplied" -> False,
    "ScaleAttachedChargeTensors" -> scaleAttachedChargeTensors,
    "ScaleAttachedGenericTensor" -> scaleAttachedGenericTensor
  |>,
  "SymmetryAndAverageBookkeeping" -> <|
    "OutgoingFieldMultiplicities" -> outgoingFieldMultiplicities,
    "DerivedFinalStateSymmetryFactors" -> derivedSymmetryFactors,
    "NontrivialIdenticalFinalStateFactorRequired" -> False,
    "SymmetryFactorAppliedAtS05" -> False,
    "IncomingQuarkSpinColorAverageAppliedAtS05" -> False,
    "IncomingQuarkSpinColorAverageDeferred" -> "1/(2 Nc) at S06"
  |>,
  "VirtualContributionAtThisOrder" -> <|
    "Applicable" -> False,
    "Interference" -> 0,
    "SourceDisposition" -> s04["StageDisposition"],
    "ZeroMeaning" -> s04["ZeroMeaning"]
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "fermion spin/color sums, Dirac traces, or incoming-quark averaging",
    "projector contraction",
    "phase-space normalization or integration",
    "collinear subtraction or factorization",
    "physical flavor/charge assembly or fragmentation multiplicity",
    "F-hat inversion or external-code comparison"
  },
  "DownstreamInstruction" ->
    "Hqqprime S06 must consume each ScaleAttachedChargeTensor separately, sum all four external fermion spin/color states, apply exactly the incoming-quark average 1/(2 Nc), and preserve s05Mu,s05Nu plus all three charge structures. It must not add a virtual term, symmetry factor, physical flavor sum, projector, or phase-space operation."
|>;

Print["S05_STAGE: atomically writing the Hqqprime charge-resolved result"];
atomicPut[s05Result, s05ResultPath];

reloadedResult = Quiet @ Check[Get[s05ResultPath], $Failed];
assert[AssociationQ[reloadedResult],
  "published s05_result failed final reload"];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === "HqqprimeS05-v1" &&
    reloadedResult["ResultSchemaVersion"] === 1 &&
    reloadedResult["ProgramSHA256"] === programSHA256,
  "published s05_result identity/program binding is invalid"
];
assert[
  reloadedResult["Input", "S01ResultSHA256"] ===
      expectedS01ResultSHA256 &&
    reloadedResult["Input", "S04ResultSHA256"] ===
      expectedS04ResultSHA256,
  "published s05_result upstream binding is invalid"
];
assert[And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "published s05_result contains a failed check"];
assert[
  And @@ (# === 0 & /@
    Values[
      reloadedResult[
        "ChargeResolvedBilinears",
        "CoefficientExtractionResiduals"
      ]
    ]) &&
  reloadedResult[
    "ChargeResolvedBilinears",
    "GenericChargePolynomialResidual"
  ] === 0,
  "published s05_result charge reconstruction is invalid"
];
assert[
  reloadedResult["VirtualContributionAtThisOrder", "Applicable"] === False &&
    reloadedResult["VirtualContributionAtThisOrder", "Interference"] === 0,
  "published s05_result virtual-absence handoff is invalid"
];

resultSHA256 = fileSHA256[s05ResultPath];

Print["S05_SUCCESS"];
Print["S05_PROGRAM_SHA256=", programSHA256];
Print["S05_RESULT_SHA256=", resultSHA256];
Print["S05_FULL_DIAGRAM_COUNTS=", InputForm[fullDiagramCounts]];
Print["S05_COHERENT_ORDERED_PAIR_COUNT=",
  coherentOrderedDiagramPairCount];
Print["S05_CHARGE_TENSOR_KEYS=",
  InputForm[Keys[chargeResolvedCoreTensors]]];
Print["S05_CHARGE_TENSOR_LEAF_COUNTS=",
  InputForm[LeafCount /@ chargeResolvedCoreTensors]];
Print["S05_SCALE_FACTOR=", InputForm[dimensionalScaleFactor]];
Print["S05_SYMMETRY_FACTORS=", InputForm[derivedSymmetryFactors]];
Print["S05_CHECK_COUNT=", Length[checks]];
Print["S05_RESULT_BYTES=", FileByteCount[s05ResultPath]];
Print["S05_RESULT=", s05ResultPath];

Quit[0];

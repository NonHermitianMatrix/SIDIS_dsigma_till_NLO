(* ::Package:: *)

(*
  Hqq channel for large-qT SIDIS through NLO QCD.

  Paper notation and subprocesses:
    LO and virtual: H_qq;g       gamma*(q) + q(p) -> q(k1) + g(k2)
    NLO real:       H_qq;gg      gamma*(q) + q(p) -> q(k1) + g(k2) + g(k3)
    NLO real:       H_qq;q qbar  gamma*(q) + q(p) -> q(k1) + q(k2) + qbar(k3)
    NLO real:       H_qq;q' qbar'gamma*(q) + q(p) -> q(k1) + q'(k2) + qbar'(k3)

  The first outgoing quark k1 is the fragmenting parton.  All quark masses
  are set to zero.  The virtual amplitude is kept in D dimensions, reduced
  diagram by diagram to Passarino--Veltman functions, and passed independently
  to PaXEvaluateUV and PaXEvaluateIR.  UV counterterm amplitudes are stored in
  their symbolic FeynArts renormalization-constant form, separate from both
  bare-loop UV poles and IR poles.

  Run with Wolfram Engine 15.0, e.g.
    WolframKernel -noprompt -script s01_calculate_hqq_lo_nlo.wl

  Successful completion writes the extensionless result file s01_result in
  this directory.  Get["s01_result"] returns the result Association.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, couplingSignature, rewrapFeynAmpList,
  generateOrdinaryProcess, containsNamedSymbolQ, convertAmplitudes,
  reduceVirtualAmplitude, evaluateUV, evaluateIR, processPayload
];

fatal[message_String] := (
  Print["S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
resultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
referencePath = FileNameJoin[{
   DirectoryName[scriptDirectory],
   "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

assert[FileExistsQ[referencePath], "The authoritative SIDIS reference PDF is missing."];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

incomingFields = {FeynArts`V[1], FeynArts`F[3, {1}]};

outgoingFields = <|
  "LO" -> {FeynArts`F[3, {1}], FeynArts`V[5]},
  "RealQGG" -> {FeynArts`F[3, {1}], FeynArts`V[5], FeynArts`V[5]},
  "RealSameFlavor" -> {
    FeynArts`F[3, {1}], FeynArts`F[3, {1}], -FeynArts`F[3, {1}]
  },
  "RealDifferentFlavor" -> {
    FeynArts`F[3, {1}], FeynArts`F[3, {2}], -FeynArts`F[3, {2}]
  },
  "Virtual" -> {FeynArts`F[3, {1}], FeynArts`V[5]}
|>;

externalMomenta = <|
  "LO" -> {k1, k2},
  "RealQGG" -> {k1, k2, k3},
  "RealSameFlavor" -> {k1, k2, k3},
  "RealDifferentFlavor" -> {k1, k2, k3},
  "Virtual" -> {k1, k2},
  "Counterterm" -> {k1, k2}
|>;

expectedCounts = <|
  "LO" -> 2,
  "RealQGG" -> 8,
  "RealSameFlavor" -> 8,
  "RealDifferentFlavor" -> 4,
  "Virtual" -> 23,
  "Counterterm" -> 12
|>;

couplingSignature[amp_] := Module[{tmp},
  tmp = Expand[
    amp /. FeynArts`FCGV["EL"] -> s01CouplingE /.
      FeynArts`FAGS -> s01CouplingGS
  ];
  {Exponent[tmp, s01CouplingE], Exponent[tmp, s01CouplingGS]}
];

rewrapFeynAmpList[wrapper_, positions_List] :=
  Apply[Head[wrapper], (List @@ wrapper)[[positions]]];

generateOrdinaryProcess[loopOrder_Integer, fields_List, wantedSignature_List] :=
 Module[{topologies, insertions, allRaw, rawList, signatures, positions},
  topologies = FeynArts`CreateTopologies[
    loopOrder,
    2 -> Length[fields],
    FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles, FeynArts`WFCorrections}
  ];
  insertions = FeynArts`InsertFields[
    topologies,
    incomingFields -> fields,
    FeynArts`InsertionLevel -> {FeynArts`Particles},
    FeynArts`Model -> "SMQCD"
  ];
  allRaw = FeynArts`CreateFeynAmp[
    insertions,
    FeynArts`Truncated -> True
  ];
  rawList = List @@ allRaw;
  signatures = couplingSignature /@ rawList;
  positions = Flatten[Position[signatures, wantedSignature, {1}]];
  <|
    "Topologies" -> topologies,
    "AllInsertionDiagrams" -> insertions,
    "AllAmplitudeCount" -> Length[rawList],
    "AllCouplingSignatures" -> Counts[signatures],
    "QCDDiagramNumbers" -> positions,
    "QCDDiagrams" -> FeynArts`DiagramExtract[insertions, positions],
    "QCDRawWrapper" -> rewrapFeynAmpList[allRaw, positions],
    "QCDRawAmplitudes" -> rawList[[positions]],
    "QCDDiagramCount" -> Length[positions]
  |>
];

containsNamedSymbolQ[expr_, names_List] := Module[{rawInputForm},
  rawInputForm = ToString[Unevaluated[expr], InputForm];
  AnyTrue[names, StringContainsQ[rawInputForm, #] &]
];

convertAmplitudes[wrapper_, outgoingMomenta_List, loopMomenta_List] :=
 CheckAbort[
  Check[
   FeynCalc`FCFAConvert[
    wrapper,
    FeynCalc`IncomingMomenta -> {q, p},
    FeynCalc`OutgoingMomenta -> outgoingMomenta,
    FeynCalc`LoopMomenta -> loopMomenta,
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

processPayload[generated_Association, converted_List] := <|
  "DiagramCount" -> generated["QCDDiagramCount"],
  "DiagramNumbersInSMQCDGeneration" -> generated["QCDDiagramNumbers"],
  "FeynArtsDiagrams" -> generated["QCDDiagrams"],
  "FeynArtsRawAmplitudes" -> generated["QCDRawAmplitudes"],
  "FeynCalcAmplitudesPerDiagram" -> converted,
  "FeynCalcAmplitudeSum" -> Total[converted],
  "UnfilteredSMQCDAmplitudeCount" -> generated["AllAmplitudeCount"],
  "UnfilteredCouplingSignatures" -> generated["AllCouplingSignatures"]
|>;

Print["S01_STAGE: generating all Hqq ordinary diagrams"];

loGenerated = generateOrdinaryProcess[0, outgoingFields["LO"], {1, 1}];
qggGenerated = generateOrdinaryProcess[0, outgoingFields["RealQGG"], {1, 2}];
sameGenerated = generateOrdinaryProcess[0, outgoingFields["RealSameFlavor"], {1, 2}];
differentGenerated = generateOrdinaryProcess[
  0, outgoingFields["RealDifferentFlavor"], {1, 2}
];
virtualGenerated = generateOrdinaryProcess[1, outgoingFields["Virtual"], {1, 3}];

assert[loGenerated["QCDDiagramCount"] === expectedCounts["LO"],
  "LO QCD diagram count mismatch."];
assert[qggGenerated["QCDDiagramCount"] === expectedCounts["RealQGG"],
  "Real qgg QCD diagram count mismatch."];
assert[sameGenerated["QCDDiagramCount"] === expectedCounts["RealSameFlavor"],
  "Real same-flavor QCD diagram count mismatch."];
assert[differentGenerated["QCDDiagramCount"] === expectedCounts["RealDifferentFlavor"],
  "Real different-flavor QCD diagram count mismatch."];
assert[virtualGenerated["QCDDiagramCount"] === expectedCounts["Virtual"],
  "Virtual QCD diagram count mismatch."];

Print["S01_STAGE: generating QCD-relevant UV counterterm diagrams"];

countertermTopologies = FeynArts`CreateCTTopologies[1, 2 -> 2];
countertermInsertions = FeynArts`InsertFields[
  countertermTopologies,
  incomingFields -> outgoingFields["LO"],
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD"
];
countertermAllRaw = FeynArts`CreateFeynAmp[
  countertermInsertions,
  FeynArts`Truncated -> True
];
countertermRawList = List @@ countertermAllRaw;
qcdCountertermSymbolNames = {
  "dZGG1", "dZgs1", "dZfL1", "dZfR1", "dMf1"
};
countertermPositions = Flatten@Position[
  containsNamedSymbolQ[#, qcdCountertermSymbolNames] & /@ countertermRawList,
  True,
  {1}
];
countertermRaw = rewrapFeynAmpList[countertermAllRaw, countertermPositions];
countertermDiagrams = FeynArts`DiagramExtract[
  countertermInsertions,
  countertermPositions
];

assert[Length[countertermPositions] === expectedCounts["Counterterm"],
  "QCD-relevant counterterm diagram count mismatch."];

Print["S01_STAGE: converting tree, real, virtual, and counterterm amplitudes"];

loFC = convertAmplitudes[
  loGenerated["QCDRawWrapper"], externalMomenta["LO"], {}
];
qggFC = convertAmplitudes[
  qggGenerated["QCDRawWrapper"], externalMomenta["RealQGG"], {}
];
sameFC = convertAmplitudes[
  sameGenerated["QCDRawWrapper"], externalMomenta["RealSameFlavor"], {}
];
differentFC = convertAmplitudes[
  differentGenerated["QCDRawWrapper"], externalMomenta["RealDifferentFlavor"], {}
];
virtualFC = convertAmplitudes[
  virtualGenerated["QCDRawWrapper"], externalMomenta["Virtual"], {ell}
];
countertermFC = convertAmplitudes[
  countertermRaw, externalMomenta["Counterterm"], {}
];

convertedCollections = <|
  "LO" -> loFC,
  "RealQGG" -> qggFC,
  "RealSameFlavor" -> sameFC,
  "RealDifferentFlavor" -> differentFC,
  "Virtual" -> virtualFC,
  "Counterterm" -> countertermFC
|>;

Scan[
  Function[label,
    assert[ListQ[convertedCollections[label]], label <> " conversion did not return a list."];
    assert[Length[convertedCollections[label]] === expectedCounts[label],
      label <> " converted-amplitude count mismatch."];
    assert[FreeQ[convertedCollections[label], _FeynArts`FAFeynAmp],
      label <> " conversion left a FeynArts amplitude unevaluated."]
  ],
  Keys[convertedCollections]
];

(* Massless 2->2 kinematics for the virtual Package-X reduction. *)
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

reduceVirtualAmplitude[amp_, index_Integer] := Module[{answer},
  Print[
    "S01_STAGE: TID virtual diagram " <> ToString[index] <> "/" <>
      ToString[expectedCounts["Virtual"]]
  ];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`TID[
        amp,
        ell,
        FeynCalc`ToPaVe -> True,
        FeynCalc`UsePaVeBasis -> True,
        FeynCalc`FeynAmpDenominatorSimplify -> False,
        FeynCalc`ApartFF -> False,
        FeynCalc`FCVerbose -> 0
      ],
      $Failed
    ],
    $Failed
  ];
  answer
];

Print["S01_STAGE: reducing all virtual amplitudes"];
virtualTID = MapIndexed[
  reduceVirtualAmplitude[#1, First[#2]] &,
  virtualFC
];

assert[FreeQ[virtualTID, $Failed], "At least one virtual TID reduction failed."];
assert[FreeQ[virtualTID, FeynCalc`TID], "At least one TID call remained unevaluated."];

evaluateUV[expr_, index_Integer] := Module[{answer},
  Print[
    "S01_STAGE: UV pole virtual diagram " <> ToString[index] <> "/" <>
      ToString[expectedCounts["Virtual"]]
  ];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`PaXEvaluateUV[
        expr,
        ell,
        FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D,
        FeynCalc`PaXC0Expand -> True,
        FeynCalc`PaXD0Expand -> True,
        FeynCalc`PaXAnalytic -> True
      ],
      $Failed
    ],
    $Failed
  ];
  answer
];

evaluateIR[expr_, index_Integer] := Module[{answer},
  Print[
    "S01_STAGE: IR pole virtual diagram " <> ToString[index] <> "/" <>
      ToString[expectedCounts["Virtual"]]
  ];
  answer = CheckAbort[
    Quiet@Check[
      FeynCalc`PaXEvaluateIR[
        expr,
        ell,
        FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D,
        FeynCalc`PaXC0Expand -> True,
        FeynCalc`PaXD0Expand -> True,
        FeynCalc`PaXAnalytic -> True
      ],
      $Failed
    ],
    $Failed
  ];
  answer
];

Print["S01_STAGE: evaluating UV poles independently"];
virtualUV = MapIndexed[evaluateUV[#1, First[#2]] &, virtualTID];

assert[FreeQ[virtualUV, $Failed], "At least one Package-X UV evaluation failed."];
assert[FreeQ[virtualUV, FeynCalc`PaXEvaluateUV],
  "At least one Package-X UV call remained unevaluated."];

Print["S01_STAGE: evaluating IR poles independently"];
virtualIR = MapIndexed[evaluateIR[#1, First[#2]] &, virtualTID];

assert[FreeQ[virtualIR, $Failed], "At least one Package-X IR evaluation failed."];
assert[FreeQ[virtualIR, FeynCalc`PaXEvaluateIR],
  "At least one Package-X IR call remained unevaluated."];

Print["S01_STAGE: evaluating first-diagram UV/IR split cross-check"];
virtualSplitCheck = CheckAbort[
  Quiet@Check[
    FeynCalc`PaXEvaluateUVIRSplit[
      First[virtualTID],
      ell,
      FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D,
      FeynCalc`PaXC0Expand -> True,
      FeynCalc`PaXD0Expand -> True,
      FeynCalc`PaXAnalytic -> True
    ],
    $Failed
  ],
  $Failed
];

assert[virtualSplitCheck =!= $Failed, "Package-X UV/IR split cross-check failed."];
assert[FreeQ[virtualSplitCheck, FeynCalc`PaXEvaluateUVIRSplit],
  "Package-X UV/IR split cross-check remained unevaluated."];
assert[! FreeQ[virtualUV, FeynCalc`EpsilonUV],
  "The UV collection contains no EpsilonUV pole."];
assert[! FreeQ[virtualIR, FeynCalc`EpsilonIR],
  "The IR collection contains no EpsilonIR pole."];
assert[FreeQ[virtualUV, FeynCalc`EpsilonIR],
  "An IR regulator leaked into the UV-only collection."];
assert[FreeQ[virtualIR, FeynCalc`EpsilonUV],
  "A UV regulator leaked into the IR-only collection."];

diagramCounts = <|
  "LO_gammaStar_q_to_q_g" -> Length[loFC],
  "NLOReal_gammaStar_q_to_q_g_g" -> Length[qggFC],
  "NLOReal_gammaStar_q_to_q_q_qbar_sameFlavor" -> Length[sameFC],
  "NLOReal_gammaStar_q_to_q_qPrime_qbarPrime" -> Length[differentFC],
  "NLOVirtualBare_gammaStar_q_to_q_g" -> Length[virtualFC],
  "NLOVirtualQCDRelevantCounterterms" -> Length[countertermFC],
  "TotalQCDDiagramsIncludingCounterterms" -> Total[Values[expectedCounts]]
|>;

s01Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "PerturbativeOrders" -> <|
    "LO" -> "O(alpha_s) hard part: tree gamma* q -> q g",
    "NLO" -> "O(alpha_s^2) hard part: one-loop 2->2 plus tree 2->3"
  |>,
  "ReferencePDF" -> referencePath,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Software" -> <|
    "WolframVersion" -> $Version,
    "FeynCalcVersion" -> FeynCalc`$FeynCalcVersion,
    "FeynArtsVersion" -> FeynArts`$FeynArtsVersion,
    "FeynHelpersPackageXInterface" -> "loaded through $LoadAddOns"
  |>,
  "Conventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "IncomingMomenta" -> {q, p},
    "FragmentingMomentum" -> k1,
    "Masses" -> "all quarks massless",
    "MandelstamRelation" -> HoldForm[uHat == -Q2 - sHat - tHat],
    "LoopIntegrationMeasure" -> HoldForm[1/(2 Pi)^D],
    "UVRegulator" -> FeynCalc`EpsilonUV,
    "IRRegulator" -> FeynCalc`EpsilonIR
  |>,
  "DiagramCounts" -> diagramCounts,
  "LO" -> processPayload[loGenerated, loFC],
  "NLOReal" -> <|
    "Hqq;gg" -> processPayload[qggGenerated, qggFC],
    "Hqq;q_qbar_sameFlavor" -> processPayload[sameGenerated, sameFC],
    "Hqq;qPrime_qbarPrime" -> processPayload[differentGenerated, differentFC]
  |>,
  "NLOVirtual" -> <|
    "BareLoop" -> Join[
      processPayload[virtualGenerated, virtualFC],
      <|
        "TIDPassarinoVeltmanPerDiagram" -> virtualTID,
        "TIDPassarinoVeltmanSum" -> Total[virtualTID]
      |>
    ],
    "UVCounterterms" -> <|
      "DiagramCount" -> Length[countertermFC],
      "QCDRenormalizationSymbols" -> qcdCountertermSymbolNames,
      "DiagramNumbersInSMQCDGeneration" -> countertermPositions,
      "FeynArtsDiagrams" -> countertermDiagrams,
      "FeynArtsRawAmplitudes" -> countertermRawList[[countertermPositions]],
      "FeynCalcAmplitudesPerDiagram" -> countertermFC,
      "FeynCalcAmplitudeSum" -> Total[countertermFC],
      "SchemeNote" -> "Counterterms are kept symbolic so UV renormalization is not mixed with bare-loop or IR poles."
    |>
  |>,
  "Poles" -> <|
    "UVPoles" -> <|
      "BareVirtualPerDiagram" -> virtualUV,
      "BareVirtualTotal" -> Total[virtualUV],
      "SymbolicCountertermPerDiagram" -> countertermFC,
      "SymbolicCountertermTotal" -> Total[countertermFC]
    |>,
    "IRPoles" -> <|
      "BareVirtualPerDiagram" -> virtualIR,
      "BareVirtualTotal" -> Total[virtualIR]
    |>,
    "UVIRSplitCrossCheckFirstVirtualDiagram" -> virtualSplitCheck,
    "SeparationChecks" -> <|
      "UVHasEpsilonUV" -> (! FreeQ[virtualUV, FeynCalc`EpsilonUV]),
      "UVHasNoEpsilonIR" -> FreeQ[virtualUV, FeynCalc`EpsilonIR],
      "IRHasEpsilonIR" -> (! FreeQ[virtualIR, FeynCalc`EpsilonIR]),
      "IRHasNoEpsilonUV" -> FreeQ[virtualIR, FeynCalc`EpsilonUV]
    |>
  |>,
  "NotIncludedAtThisStage" -> {
    "2->3 phase-space angular integration",
    "real-virtual infrared cancellation after phase-space integration",
    "PDF/FF collinear factorization subtractions of Eq. (46)",
    "other SIDIS channels"
  }
|>;

Print["S01_STAGE: writing " <> resultPath];
Put[s01Result, resultPath];

assert[FileExistsQ[resultPath], "The s01_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s01_result file is empty."];

Print["S01_SUCCESS"];
Print["S01_RESULT_PATH=" <> resultPath];
Print["S01_DIAGRAM_COUNTS=", InputForm[diagramCounts]];
Print["S01_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

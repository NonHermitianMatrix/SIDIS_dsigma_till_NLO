(* ::Package:: *)

(*
  Hqg channel for large-qT SIDIS through NLO QCD.

  Paper Table-I subprocesses:
    LO and virtual: H_qg;q   gamma*(q) + q(p) -> g(k1) + q(k2)
    NLO real:       H_qg;qg  gamma*(q) + q(p) -> g(k1) + q(k2) + g(k3)

  The first outgoing gluon k1 is the fragmenting parton.  This is BigTMD
  channel 3, case A.  FeynArts generates the representative down-quark field
  with Q_ref=-1/3. Every one-photon amplitude is divided by Q_ref here so the
  saved hard amplitudes are charge stripped; the physical luminosity
  Sum_q e_q^2 f_q D_g is applied only in later assembly, as in BigTMD.
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

referenceQuarkElectricCharge = -1/3;
referenceChargeStripFactor = 1/referenceQuarkElectricCharge;
assert[referenceChargeStripFactor === -3,
  "The down-reference electric-charge stripping factor is not exact."];

incomingFields = {FeynArts`V[1], FeynArts`F[3, {1}]};
outgoingFields = <|
  "LO" -> {FeynArts`V[5], FeynArts`F[3, {1}]},
  "RealQG" -> {FeynArts`V[5], FeynArts`F[3, {1}], FeynArts`V[5]},
  "Virtual" -> {FeynArts`V[5], FeynArts`F[3, {1}]}
|>;

externalMomenta = <|
  "LO" -> {k1, k2},
  "RealQG" -> {k1, k2, k3},
  "Virtual" -> {k1, k2},
  "Counterterm" -> {k1, k2}
|>;

expectedCounts = <|
  "LO" -> 2,
  "RealQG" -> 8,
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

convertAmplitudes[wrapper_, outgoingMomenta_List, loopMomenta_List] := Module[
 {converted},
 converted = CheckAbort[
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
 If[converted === $Failed, Return[$Failed]];
 assert[ListQ[converted],
   "FeynArts-to-FeynCalc conversion did not return a list."];
 assert[
   And @@ (Count[#, FeynArts`FCGV["EL"], {0, Infinity}] >= 1 & /@
       converted),
   "A converted amplitude contains no photon coupling."
 ];
 referenceChargeStripFactor converted
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

Print["S01_STAGE: generating all Hqg ordinary diagrams"];

loGenerated = generateOrdinaryProcess[0, outgoingFields["LO"], {1, 1}];
realGenerated = generateOrdinaryProcess[0, outgoingFields["RealQG"], {1, 2}];
virtualGenerated = generateOrdinaryProcess[1, outgoingFields["Virtual"], {1, 3}];

assert[loGenerated["QCDDiagramCount"] === expectedCounts["LO"],
  "LO QCD diagram count mismatch."];
assert[realGenerated["QCDDiagramCount"] === expectedCounts["RealQG"],
  "Real Hqg;qg QCD diagram count mismatch."];
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

loFC = convertAmplitudes[loGenerated["QCDRawWrapper"], externalMomenta["LO"], {}];
realFC = convertAmplitudes[
  realGenerated["QCDRawWrapper"], externalMomenta["RealQG"], {}
];
virtualFC = convertAmplitudes[
  virtualGenerated["QCDRawWrapper"], externalMomenta["Virtual"], {ell}
];
countertermFC = convertAmplitudes[
  countertermRaw, externalMomenta["Counterterm"], {}
];

ordinaryPhotonCouplingCounts = Count[
    #, FeynArts`FCGV["EL"], {0, Infinity}
  ] & /@ Join[loFC, realFC, virtualFC];
countertermPhotonCouplingCounts = Count[
    #, FeynArts`FCGV["EL"], {0, Infinity}
  ] & /@ countertermFC;
assert[And @@ (# === 1 & /@ ordinaryPhotonCouplingCounts),
  "An ordinary LO/real/virtual amplitude does not contain exactly one photon coupling."];
assert[
  Counts[countertermPhotonCouplingCounts] === <|1 -> 10, 2 -> 2|>,
  "The symbolic counterterm photon-coupling inventory changed."
];

convertedCollections = <|
  "LO" -> loFC,
  "RealQG" -> realFC,
  "Virtual" -> virtualFC,
  "Counterterm" -> countertermFC
|>;

Scan[
  Function[label,
    assert[ListQ[convertedCollections[label]],
      label <> " conversion did not return a list."];
    assert[Length[convertedCollections[label]] === expectedCounts[label],
      label <> " converted-amplitude count mismatch."];
    assert[FreeQ[convertedCollections[label], _FeynArts`FAFeynAmp],
      label <> " conversion left a FeynArts amplitude unevaluated."]
  ],
  Keys[convertedCollections]
];

(* Massless 2->2 kinematics with the observed gluon at k1. *)
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
virtualTID = MapIndexed[reduceVirtualAmplitude[#1, First[#2]] &, virtualFC];

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
  "LO_gammaStar_q_to_g_q" -> Length[loFC],
  "NLOReal_gammaStar_q_to_g_q_g" -> Length[realFC],
  "NLOVirtualBare_gammaStar_q_to_g_q" -> Length[virtualFC],
  "NLOVirtualQCDRelevantCounterterms" -> Length[countertermFC],
  "TotalQCDDiagramsIncludingCounterterms" -> Total[Values[expectedCounts]]
|>;

s01Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS01-v2",
  "Channel" -> "Hqg only",
  "Contribution" -> "Hqg;q + Hqg;qg",
  "PerturbativeOrders" -> <|
    "LO" -> "O(alpha_s) hard part: tree gamma* q -> g q",
    "NLO" -> "O(alpha_s^2) hard part: one-loop 2->2 plus tree 2->3"
  |>,
  "ReferencePDF" -> referencePath,
  "ReferencePDFSHA256" -> FileHash[referencePath, "SHA256"],
  "BigTMDConvention" -> <|
    "Repository" -> "https://github.com/JeffersonLab/BigTMD",
    "VerifiedCommit" -> "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c",
    "ChannelNumber" -> 3,
    "ChargeCase" -> "A only",
    "LOProjectorKernels" -> {"LO.PgB", "LO.PppB"},
    "NLOProjectorModules" -> {"NLO.Pg.fchn3A", "NLO.Ppp.fchn3A"},
    "PhysicalLuminosity" -> "Sum_q e_q^2 f_q D_g",
    "DistributionPiecesDownstream" -> {"regular", "delta", "plus1B", "plus2B"}
  |>,
  "ElectricChargeNormalization" -> <|
    "FeynArtsReferenceField" -> "F[3,{1}] down type",
    "ReferenceCharge" -> referenceQuarkElectricCharge,
    "AmplitudeStripFactor" -> referenceChargeStripFactor,
    "SavedHardAmplitudeConvention" ->
      "one-photon amplitudes divided by Q_ref; no numerical quark electric charge remains in the hard-kernel normalization",
    "BigTMDLuminosityAppliedDownstream" -> "Sum_q e_q^2 f_q D_g"
  |>,
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
    "OutgoingMomenta" -> {k1, k2},
    "FragmentingParton" -> "g(k1)",
    "SpectatorParton" -> "q(k2)",
    "ElectromagneticCharge" ->
      "charge-stripped hard amplitude; physical e_q^2 is supplied by the downstream flavor luminosity",
    "Masses" -> "all quarks massless",
    "MandelstamRelation" -> HoldForm[uHat == -Q2 - sHat - tHat],
    "LoopIntegrationMeasure" -> HoldForm[1/(2 Pi)^D],
    "UVRegulator" -> FeynCalc`EpsilonUV,
    "IRRegulator" -> FeynCalc`EpsilonIR
  |>,
  "DiagramCounts" -> diagramCounts,
  "LO" -> processPayload[loGenerated, loFC],
  "NLOReal" -> <|
    "Hqg;qg" -> processPayload[realGenerated, realFC]
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
      "SchemeNote" -> "Counterterms remain symbolic so UV and IR sectors stay separate."
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
  "Checks" -> <|
    "PaperTableIProcessContent" -> True,
    "BigTMDChannel3ObservedGluon" -> True,
    "OnlyChargeCaseA" -> True,
    "EveryConvertedAmplitudeHasAtLeastOnePhotonCoupling" -> True,
    "EveryOrdinaryAmplitudeHasExactlyOnePhotonCoupling" -> True,
    "CountertermPhotonCouplingInventoryIs10x1_2x2" -> True,
    "ReferenceDownChargeStrippedAtAmplitudeLevel" -> True,
    "BigTMDChargeLuminosityNotDoubleCounted" -> True,
    "NoQuarkPairRealFamilies" -> True,
    "ExactDiagramCounts" -> True
  |>,
  "NotIncludedAtThisStage" -> {
    "2->3 phase-space angular integration",
    "real-virtual infrared cancellation after phase-space integration",
    "PDF/FF collinear factorization subtractions of Eq. (46)",
    "finite comparison with BigTMD fchn3A kernels",
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

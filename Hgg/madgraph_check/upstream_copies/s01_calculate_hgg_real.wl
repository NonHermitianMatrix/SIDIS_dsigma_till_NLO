(* ::Package:: *)

(*
  First nonzero contribution to the Hgg channel at O(alpha_s^2):

    H_gg;q qbar    gamma*(q) + g(p) -> g(k1) + q(k2) + qbar(k3)

  The first outgoing gluon k1 is the fragmenting parton.  The quark and
  antiquark are an unordered spectator pair and are generated exactly once.
  A representative massless down-type quark is used at amplitude level;
  the physical Sum_f e_f^2 flavor-charge weight is deliberately deferred to
  the squared hard-part stage.  There is no Hgg two-body Born process and no
  Hgg virtual contribution at this perturbative order (paper Table I).

  Run with Wolfram Engine 15.0, e.g.
    WolframKernel -noinit -noprompt -script s01_calculate_hgg_real.wl

  Successful completion writes the extensionless result file s01_result in
  this directory.  Get["s01_result"] returns the result Association.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, couplingSignature, rewrapFeynAmpList,
  generateOrdinaryProcess, convertAmplitudes, processPayload
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

assert[
  FileExistsQ[referencePath],
  "The authoritative SIDIS reference PDF is missing."
];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

incomingFields = {FeynArts`V[1], FeynArts`V[5]};
outgoingFields = {
  FeynArts`V[5],
  FeynArts`F[3, {1}],
  -FeynArts`F[3, {1}]
};
incomingMomenta = {q, p};
outgoingMomenta = {k1, k2, k3};
wantedCouplingSignature = {1, 2};

assert[
  incomingFields === {FeynArts`V[1], FeynArts`V[5]},
  "The incoming fields are not photon plus gluon in the required order."
];
assert[
  First[outgoingFields] === FeynArts`V[5] &&
    First[outgoingMomenta] === k1,
  "The fragmenting parton is not the first outgoing gluon k1."
];
assert[
  Rest[outgoingFields] === {
    FeynArts`F[3, {1}], -FeynArts`F[3, {1}]
  },
  "The spectator fields are not one representative quark-antiquark pair."
];

couplingSignature[amp_] := Module[{tmp},
  tmp = Expand[
    amp /. FeynArts`FCGV["EL"] -> s01CouplingE /.
      FeynArts`FAGS -> s01CouplingGS
  ];
  {
    Exponent[tmp, s01CouplingE],
    Exponent[tmp, s01CouplingGS]
  }
];

rewrapFeynAmpList[wrapper_, positions_List] :=
  Apply[Head[wrapper], (List @@ wrapper)[[positions]]];

generateOrdinaryProcess[loopOrder_Integer, fields_List, wantedSignature_List] :=
 Module[{topologies, insertions, allRaw, rawList, signatures, positions},
  topologies = FeynArts`CreateTopologies[
    loopOrder,
    2 -> Length[fields],
    FeynArts`ExcludeTopologies -> {
      FeynArts`Tadpoles, FeynArts`WFCorrections
    }
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
    "AllCouplingSignaturesPerDiagram" -> signatures,
    "AllCouplingSignatures" -> Counts[signatures],
    "QCDDiagramNumbers" -> positions,
    "QCDDiagrams" -> FeynArts`DiagramExtract[insertions, positions],
    "QCDRawWrapper" -> rewrapFeynAmpList[allRaw, positions],
    "QCDRawAmplitudes" -> rawList[[positions]],
    "QCDDiagramCount" -> Length[positions]
  |>
];

convertAmplitudes[wrapper_, finalMomenta_List] :=
 CheckAbort[
  Check[
   FeynCalc`FCFAConvert[
    wrapper,
    FeynCalc`IncomingMomenta -> incomingMomenta,
    FeynCalc`OutgoingMomenta -> finalMomenta,
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

Print["S01_STAGE: generating tree Hgg;q qbar diagrams"];
hggGenerated = generateOrdinaryProcess[
  0,
  outgoingFields,
  wantedCouplingSignature
];

assert[
  hggGenerated["AllAmplitudeCount"] > 0,
  "SMQCD generated no amplitudes for gamma* g -> g q qbar."
];
assert[
  hggGenerated["QCDDiagramCount"] > 0,
  "No e g_s^2 Hgg;q qbar diagrams survived coupling-order selection."
];
assert[
  And @@ (
    (# === wantedCouplingSignature) & /@
      hggGenerated["AllCouplingSignaturesPerDiagram"][[
        hggGenerated["QCDDiagramNumbers"]
      ]]
  ),
  "At least one selected diagram does not have coupling order e g_s^2."
];

Print[
  "S01_STAGE: selected ", hggGenerated["QCDDiagramCount"],
  " e g_s^2 diagrams from ", hggGenerated["AllAmplitudeCount"],
  " SMQCD candidates"
];
Print["S01_STAGE: converting selected tree amplitudes to FeynCalc"];
hggFC = convertAmplitudes[
  hggGenerated["QCDRawWrapper"],
  outgoingMomenta
];

assert[ListQ[hggFC], "Hgg amplitude conversion did not return a list."];
assert[
  Length[hggFC] === hggGenerated["QCDDiagramCount"],
  "The converted-amplitude count does not match the selected diagram count."
];
assert[
  FreeQ[hggFC, _FeynArts`FAFeynAmp],
  "FeynCalc conversion left a FeynArts amplitude unevaluated."
];
assert[
  FreeQ[hggFC, FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`B0 |
    FeynCalc`C0 | FeynCalc`D0],
  "A loop integral unexpectedly appears in the tree Hgg amplitude."
];
assert[
  FreeQ[hggFC, FeynCalc`EpsilonUV | FeynCalc`EpsilonIR],
  "A UV or IR loop regulator unexpectedly appears in the tree amplitude."
];
assert[
  FreeQ[hggFC, _Real],
  "Machine-precision numbers unexpectedly appear in the symbolic amplitude."
];

validationChecks = <|
  "OnlyTreeThreeBodyProcess" -> True,
  "IncomingPhotonAndGluon" -> True,
  "FragmentingPartonIsFirstOutgoingGluonK1" -> True,
  "SpectatorsAreOneQuarkAntiquarkPair" -> True,
  "EverySelectedAmplitudeHasCouplingOrderEGS2" -> True,
  "NoLoopIntegrals" -> True,
  "NoUVOrIRLoopRegulators" -> True,
  "CalculationFullySymbolic" -> True,
  "RepresentativeFlavorOnlyAndChargeSumDeferred" -> True
|>;

diagramCounts = <|
  "NLOReal_gammaStar_g_to_g_q_qbar" -> Length[hggFC],
  "TotalQCDDiagramsAtThisStage" -> Length[hggFC]
|>;

s01Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hgg only",
  "Contribution" -> "Hgg;q qbar",
  "PerturbativeOrders" -> <|
    "FirstNonzeroHgg" ->
      "O(alpha_s^2) hard part: tree gamma* g -> g q qbar",
    "TwoBodyBornAtThisOrder" -> "Absent",
    "VirtualAtThisOrder" -> "Absent"
  |>,
  "ReferencePDF" -> referencePath,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Software" -> <|
    "WolframVersion" -> $Version,
    "FeynCalcVersion" -> FeynCalc`$FeynCalcVersion,
    "FeynArtsVersion" -> FeynArts`$FeynArtsVersion
  |>,
  "Conventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "IncomingFields" -> incomingFields,
    "OutgoingFields" -> outgoingFields,
    "IncomingMomenta" -> incomingMomenta,
    "OutgoingMomenta" -> outgoingMomenta,
    "FragmentingParton" -> "outgoing gluon with momentum k1",
    "SpectatorPair" -> "q(k2) plus qbar(k3), counted once",
    "Masses" -> "all quarks massless",
    "AmplitudeCouplingOrder" -> HoldForm[e gs^2],
    "RepresentativeFlavor" ->
      "FeynArts F[3,{1}] is a representative massless down-type flavor",
    "PhysicalFlavorWeight" ->
      "Defer Sum_f e_f^2 until the squared hard-part/flavor-sum stage; do not multiply this amplitude by a naive Nf"
  |>,
  "DiagramCounts" -> diagramCounts,
  "NLOReal" -> <|
    "Hgg;q_qbar" -> processPayload[hggGenerated, hggFC]
  |>,
  "ValidationChecks" -> validationChecks,
  "AbsentAtThisOrder" -> {
    "Hgg two-body Born hard part",
    "Hgg one-loop virtual hard part",
    "UV counterterm amplitudes"
  },
  "NotIncludedAtThisStage" -> {
    "amplitude conjugation and squared matrix element",
    "incoming-gluon spin and color averaging",
    "three-body phase-space angular integration",
    "PDF/FF collinear factorization subtractions of Eq. (46)",
    "physical Sum_f e_f^2 flavor-charge sum"
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

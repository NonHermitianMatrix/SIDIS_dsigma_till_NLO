(* ::Package:: *)

(*
  Generate the tree-level Hqqprime real amplitude for

    gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3),

  where k1 is the fragmenting momentum and qPrime differs from q.

  The paper's Table II requires separate incoming-line and prime-pair
  electromagnetic charge structures.  This stage derives those two amplitude
  components from independent SMQCD flavor representatives and validates the
  unused third representative exactly.  It performs no bilinear, sum,
  average, projection, phase-space integration, subtraction, or flavor sum.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, couplingSignature, rewrapFeynAmpList,
  generateRepresentative, convertAmplitudes, representativePayload,
  classEntry, quantumNumbers, electricQuantumNumber,
  chargeCoefficient, reconstructAmplitude
];

fatal[message_String] := (
  Print["S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptPath = ExpandFileName[$InputFileName];
scriptDirectory = DirectoryName[scriptPath];
resultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
referencePath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

assert[FileExistsQ[referencePath],
  "the authoritative SIDIS reference PDF is missing"];
assert[! FileExistsQ[resultPath],
  "s01_result already exists; refusing to overwrite it"];

programSHA256 = IntegerString[FileHash[scriptPath, "SHA256"], 16, 64];
referenceSHA256 = IntegerString[FileHash[referencePath, "SHA256"], 16, 64];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

wantedCouplingSignature = {1, 2};
incomingMomenta = {q, p};
outgoingMomenta = {k1, k2, k3};

representativeSpecifications = <|
  "up_up" -> <|
    "IncomingField" -> FeynArts`F[3, {1}],
    "PrimeField" -> FeynArts`F[3, {2}]
  |>,
  "up_down" -> <|
    "IncomingField" -> FeynArts`F[3, {1}],
    "PrimeField" -> FeynArts`F[4, {1}]
  |>,
  "down_up" -> <|
    "IncomingField" -> FeynArts`F[4, {1}],
    "PrimeField" -> FeynArts`F[3, {1}]
  |>
|>;

assert[
  And @@ KeyValueMap[
    Function[{label, specification},
      specification["IncomingField"] =!= specification["PrimeField"]
    ],
    representativeSpecifications
  ],
  "at least one representative does not use distinct flavors"
];

couplingSignature[amplitude_] := Module[{temporary},
  temporary = Expand[
    amplitude /. FeynArts`FCGV["EL"] -> s01CouplingE /.
      FeynArts`FAGS -> s01CouplingGS
  ];
  {
    Exponent[temporary, s01CouplingE],
    Exponent[temporary, s01CouplingGS]
  }
];

rewrapFeynAmpList[wrapper_, positions_List] :=
  Apply[Head[wrapper], (List @@ wrapper)[[positions]]];

convertAmplitudes[wrapper_] := CheckAbort[
  Quiet @ Check[
    FeynCalc`FCFAConvert[
      wrapper,
      FeynCalc`IncomingMomenta -> incomingMomenta,
      FeynCalc`OutgoingMomenta -> outgoingMomenta,
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

generateRepresentative[label_String, specification_Association] := Module[
  {
    incomingField, primeField, outgoingFields, topologies, insertions,
    allRawWrapper, allRawList, allSignatures, selectedPositions,
    selectedWrapper, selectedRaw, converted
  },
  incomingField = specification["IncomingField"];
  primeField = specification["PrimeField"];
  outgoingFields = {primeField, incomingField, -primeField};

  Print["S01_STAGE: generating representative " <> label];
  topologies = FeynArts`CreateTopologies[
    0,
    2 -> 3,
    FeynArts`ExcludeTopologies -> {
      FeynArts`Tadpoles,
      FeynArts`WFCorrections
    }
  ];
  insertions = FeynArts`InsertFields[
    topologies,
    {FeynArts`V[1], incomingField} -> outgoingFields,
    FeynArts`InsertionLevel -> {FeynArts`Particles},
    FeynArts`Model -> "SMQCD"
  ];
  allRawWrapper = Quiet @ Check[
    FeynArts`CreateFeynAmp[
      insertions,
      FeynArts`Truncated -> True
    ],
    $Failed
  ];
  assert[allRawWrapper =!= $Failed,
    label <> " FeynArts amplitude generation failed"];

  allRawList = List @@ allRawWrapper;
  allSignatures = couplingSignature /@ allRawList;
  selectedPositions = Flatten @ Position[
    allSignatures,
    wantedCouplingSignature,
    {1}
  ];
  assert[Length[selectedPositions] > 0,
    label <> " has no amplitude with the requested coupling signature"];

  selectedWrapper = rewrapFeynAmpList[allRawWrapper, selectedPositions];
  selectedRaw = allRawList[[selectedPositions]];
  assert[And @@ (couplingSignature[#] === wantedCouplingSignature & /@
      selectedRaw),
    label <> " selected a raw amplitude with the wrong coupling signature"];

  converted = convertAmplitudes[selectedWrapper];
  assert[ListQ[converted],
    label <> " FeynCalc conversion did not return a list"];
  assert[Length[converted] === Length[selectedPositions],
    label <> " converted count differs from selected count"];
  assert[And @@ (# =!= 0 & /@ converted),
    label <> " contains a zero converted amplitude"];
  assert[FreeQ[converted, _FeynArts`FAFeynAmp],
    label <> " retained an unevaluated FeynArts amplitude"];
  assert[! FreeQ[converted, D],
    label <> " does not retain the requested D-dimensional convention"];
  assert[
    FreeQ[
      converted,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | ell
    ],
    label <> " contains a loop momentum or UV/IR regulator"
  ];
  assert[
    FreeQ[
      converted,
      FeynCalc`SMP[massName_String] /;
        MemberQ[{"m_u", "m_d", "m_c", "m_s", "m_b", "m_t"}, massName]
    ],
    label <> " retained a quark mass"
  ];

  <|
    "Label" -> label,
    "IncomingField" -> incomingField,
    "PrimeField" -> primeField,
    "OutgoingFields" -> outgoingFields,
    "IncomingMomenta" -> incomingMomenta,
    "OutgoingMomenta" -> outgoingMomenta,
    "Topologies" -> topologies,
    "AllInsertionDiagrams" -> insertions,
    "UnfilteredSMQCDAmplitudeCount" -> Length[allRawList],
    "UnfilteredCouplingSignatures" -> Counts[allSignatures],
    "SelectedDiagramNumbers" -> selectedPositions,
    "SelectedDiagramCount" -> Length[selectedPositions],
    "SelectedDiagrams" -> FeynArts`DiagramExtract[
      insertions,
      selectedPositions
    ],
    "SelectedRawAmplitudes" -> selectedRaw,
    "FeynCalcAmplitudesPerDiagram" -> converted,
    "FeynCalcAmplitudeSum" -> Total[converted]
  |>
];

Print["S01_STAGE: generating three independent charge representatives"];
representatives = Association @ KeyValueMap[
  Function[{label, specification},
    label -> generateRepresentative[label, specification]
  ],
  representativeSpecifications
];

selectedCounts = Map[#1["SelectedDiagramCount"] &, representatives];
assert[Apply[Equal, Values[selectedCounts]],
  "the measured selected diagram counts differ across representatives"];

Print["S01_STAGE: deriving SMQCD electric charge coefficients"];
classDescriptionNames = Names["*M$ClassesDescription*"];
assert[Length[classDescriptionNames] === 1,
  "the loaded SMQCD class-description symbol is not unique"];
classDescriptions = ToExpression[First[classDescriptionNames]];

classEntry[class_Integer] := FirstCase[
  classDescriptions,
  HoldPattern[FeynArts`F[class] == rightHandSide_] :> rightHandSide,
  Missing["NotFound"]
];

quantumNumbers[class_Integer] := FirstCase[
  classEntry[class],
  Rule[key_, value_] /;
      SymbolName[Unevaluated[key]] === "QuantumNumbers" :> value,
  Missing["NotFound"],
  Infinity
];

electricQuantumNumber[class_Integer] := Module[{numbers},
  numbers = quantumNumbers[class];
  If[ListQ[numbers] && Length[numbers] >= 1,
    First[numbers],
    Missing["NotFound"]
  ]
];

electricQuantumNumbers = <|
  "F3" -> electricQuantumNumber[3],
  "F4" -> electricQuantumNumber[4]
|>;
assert[FreeQ[electricQuantumNumbers, _Missing],
  "SMQCD electric quantum-number metadata is missing"];

chargeMarkers = DeleteDuplicates @ Cases[
  Values[electricQuantumNumbers],
  symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "Charge",
  Infinity
];
assert[Length[chargeMarkers] === 1,
  "SMQCD electric quantum numbers do not contain one common charge marker"];
chargeMarker = First[chargeMarkers];

chargeCoefficient[class_Integer] := Simplify[
  electricQuantumNumber[class] /. chargeMarker -> 1
];

upTypeChargeCoefficient = chargeCoefficient[3];
downTypeChargeCoefficient = chargeCoefficient[4];
assert[
  FreeQ[{upTypeChargeCoefficient, downTypeChargeCoefficient}, _Missing] &&
    upTypeChargeCoefficient =!= downTypeChargeCoefficient,
  "the derived SMQCD charge coefficients are missing or not independent"
];

representativeChargeAssignments = <|
  "up_up" -> <|
    "IncomingCharge" -> upTypeChargeCoefficient,
    "PrimeCharge" -> upTypeChargeCoefficient
  |>,
  "up_down" -> <|
    "IncomingCharge" -> upTypeChargeCoefficient,
    "PrimeCharge" -> downTypeChargeCoefficient
  |>,
  "down_up" -> <|
    "IncomingCharge" -> downTypeChargeCoefficient,
    "PrimeCharge" -> upTypeChargeCoefficient
  |>
|>;

Print["S01_STAGE: solving the two-component charge basis"];
chargeBasisSolutions = Solve[
  {
    s01RepresentativeUU ==
      upTypeChargeCoefficient *
        (s01IncomingLineAmplitude + s01PrimePairLineAmplitude),
    s01RepresentativeUD ==
      upTypeChargeCoefficient * s01IncomingLineAmplitude +
        downTypeChargeCoefficient * s01PrimePairLineAmplitude
  },
  {s01IncomingLineAmplitude, s01PrimePairLineAmplitude}
];
assert[Length[chargeBasisSolutions] === 1,
  "the two-component charge-basis solve was not unique"];

chargeBasisAmplitudes = Expand[
  {s01IncomingLineAmplitude, s01PrimePairLineAmplitude} /.
    First[chargeBasisSolutions] /.
    {
      s01RepresentativeUU ->
        representatives["up_up", "FeynCalcAmplitudeSum"],
      s01RepresentativeUD ->
        representatives["up_down", "FeynCalcAmplitudeSum"]
    }
];
incomingLineAmplitude = chargeBasisAmplitudes[[1]];
primePairLineAmplitude = chargeBasisAmplitudes[[2]];

assert[incomingLineAmplitude =!= 0 && primePairLineAmplitude =!= 0,
  "at least one derived charge-basis amplitude is zero"];

reconstructAmplitude[incomingCharge_, primeCharge_] := Expand[
  incomingCharge * incomingLineAmplitude +
    primeCharge * primePairLineAmplitude
];

representativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      reconstructAmplitude[
        assignment["IncomingCharge"],
        assignment["PrimeCharge"]
      ] - representatives[label, "FeynCalcAmplitudeSum"]
    ]
  ],
  representativeChargeAssignments
];

assert[And @@ (# === 0 & /@ Values[representativeResiduals]),
  "the two-component charge basis failed a representative reconstruction"];

genericChargeAmplitude = Expand[
  S01Qq * incomingLineAmplitude +
    S01QqPrime * primePairLineAmplitude
];

genericRepresentativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      (genericChargeAmplitude /.
        {
          S01Qq -> assignment["IncomingCharge"],
          S01QqPrime -> assignment["PrimeCharge"]
        }) - representatives[label, "FeynCalcAmplitudeSum"]
    ]
  ],
  representativeChargeAssignments
];

assert[And @@ (# === 0 & /@ Values[genericRepresentativeResiduals]),
  "the generic charge amplitude failed a representative reconstruction"];

checks = <|
  "AuthoritativeReferencePresentAndHashed" -> True,
  "ResultAbsentAtStart" -> True,
  "RepresentativeFieldsAreDifferentFlavor" -> True,
  "SelectedDiagramSetsAreNonempty" -> True,
  "MeasuredSelectedCountsAgree" -> True,
  "SelectedCouplingSignaturesAreExact" -> True,
  "ConvertedCountsMatchSelections" -> True,
  "ConvertedAmplitudesAreNonzero" -> True,
  "NoUnevaluatedFeynArtsAmplitude" -> True,
  "MasslessDDimensionalConventionRetained" -> True,
  "NoLoopMomentumOrUVIRRegulator" -> True,
  "SMQCDElectricQuantumNumbersDerived" -> True,
  "SMQCDChargeCoefficientsAreIndependent" -> True,
  "ChargeBasisSolveIsUnique" -> True,
  "UpUpReconstructionIsExact" ->
    TrueQ[representativeResiduals["up_up"] === 0],
  "UpDownReconstructionIsExact" ->
    TrueQ[representativeResiduals["up_down"] === 0],
  "DownUpIndependentReconstructionIsExact" ->
    TrueQ[representativeResiduals["down_up"] === 0],
  "GenericChargeAmplitudeReconstructsAllRepresentatives" ->
    And @@ (# === 0 & /@ Values[genericRepresentativeResiduals]),
  "BothChargeBasisAmplitudesAreNonzero" ->
    TrueQ[incomingLineAmplitude =!= 0 && primePairLineAmplitude =!= 0]
|>;
assert[And @@ Values[checks],
  "at least one final S01 acceptance check is false"];

s01Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqprimeS01-v1",
  "Channel" -> "Hqqprime only",
  "Process" -> "gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3)",
  "PerturbativeOrder" ->
    "tree 2->3 contribution to the O(alpha_s^2) hard part",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> scriptPath,
  "ProgramSHA256" -> programSHA256,
  "ReferencePDF" -> referencePath,
  "ReferencePDFSHA256" -> referenceSHA256,
  "Software" -> <|
    "WolframVersion" -> $Version,
    "FeynCalcVersion" -> FeynCalc`$FeynCalcVersion,
    "FeynArtsVersion" -> FeynArts`$FeynArtsVersion,
    "FeynArtsModel" -> "SMQCD"
  |>,
  "Conventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "IncomingMomenta" -> incomingMomenta,
    "OutgoingMomenta" -> outgoingMomenta,
    "FragmentingMomentum" -> k1,
    "FragmentingFlavor" -> "qPrime different from incoming q",
    "UnobservedOrderedFlavors" -> {"q", "qbarPrime"},
    "Masses" -> "all quarks massless",
    "ElectromagneticCouplingRetained" -> True,
    "StrongCouplingPowerInAmplitude" -> Last[wantedCouplingSignature],
    "NoFlavorMultiplicityApplied" -> True
  |>,
  "ModelElectricQuantumNumbers" -> electricQuantumNumbers,
  "ModelChargeCoefficients" -> <|
    "UpType" -> upTypeChargeCoefficient,
    "DownType" -> downTypeChargeCoefficient
  |>,
  "RepresentativeChargeAssignments" -> representativeChargeAssignments,
  "MeasuredSelectedDiagramCounts" -> selectedCounts,
  "Representatives" -> representatives,
  "ChargeBasis" -> <|
    "GenericChargeSymbols" -> {S01Qq, S01QqPrime},
    "IncomingLineAmplitude" -> incomingLineAmplitude,
    "PrimePairLineAmplitude" -> primePairLineAmplitude,
    "GenericAmplitudeSum" -> genericChargeAmplitude,
    "RepresentativeResiduals" -> representativeResiduals,
    "GenericRepresentativeResiduals" -> genericRepresentativeResiduals,
    "Derivation" ->
      "Mathematica Solve from up/up and up/down; down/up is the independent exact gate"
  |>,
  "Checks" -> checks,
  "DownstreamBoundary" -> <|
    "BilinearsDeferred" -> True,
    "SpinColorPolarizationSumsDeferred" -> True,
    "IncomingAverageDeferred" -> True,
    "ProjectorsDeferred" -> True,
    "PhaseSpaceAndSubtractionsDeferred" -> True,
    "FlavorAndChargeTensorAssemblyDeferred" -> True
  |>
|>;

temporaryResultPath = resultPath <> ".tmp." <> ToString[$ProcessID];
assert[! FileExistsQ[temporaryResultPath],
  "a stale temporary S01 result exists"];

Print["S01_STAGE: writing and independently reloading the result"];
Put[s01Result, temporaryResultPath];
assert[
  FileExistsQ[temporaryResultPath] &&
    FileByteCount[temporaryResultPath] > 0,
  "temporary S01 result write failed"
];
reloadedResult = Quiet @ Check[Get[temporaryResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === "HqqprimeS01-v1" &&
    reloadedResult["ProgramSHA256"] === programSHA256 &&
    reloadedResult["ReferencePDFSHA256"] === referenceSHA256 &&
    AssociationQ[reloadedResult["Checks"]] &&
    And @@ Values[reloadedResult["Checks"]],
  "temporary S01 result reload validation failed"
];
RenameFile[temporaryResultPath, resultPath];

Print["S01_DIAGRAM_COUNTS=", InputForm[selectedCounts]];
Print[
  "S01_MODEL_CHARGE_COEFFICIENTS=",
  InputForm[<|
    "UpType" -> upTypeChargeCoefficient,
    "DownType" -> downTypeChargeCoefficient
  |>]
];
Print[
  "S01_CHARGE_BASIS_LEAF_COUNTS=",
  InputForm[LeafCount /@ chargeBasisAmplitudes]
];
Print["S01_PROGRAM_SHA256=", programSHA256];
Print["S01_REFERENCE_SHA256=", referenceSHA256];
Print["S01_SUCCESS"];
Print["S01_RESULT=", resultPath];
Quit[0];

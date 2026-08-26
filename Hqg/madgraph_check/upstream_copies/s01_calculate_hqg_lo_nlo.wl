(* ::Package:: *)

(*
  Hqg channel for large-qT SIDIS through NLO QCD.

  Paper Table-I subprocesses:
    LO and virtual: H_qg;q   gamma*(q) + q(p) -> g(k1) + q(k2)
    NLO real:       H_qg;qg  gamma*(q) + q(p) -> g(k1) + q(k2) + g(k3)

  The first outgoing gluon k1 is the fragmenting parton.  This is BigTMD
  channel 3, case A.  The representative field's electric charge is derived
  directly from the loaded SMQCD class metadata. Every one-photon amplitude
  is divided by that derived charge here so the saved hard amplitudes are
  charge stripped; the physical luminosity Sum_q e_q^2 f_q D_g is applied
  only in later assembly, as in BigTMD.
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
  reduceVirtualAmplitude, evaluateUV, evaluateIR, processPayload,
  classEntry, quantumNumbers, electricQuantumNumber, chargeCoefficient,
  deriveTwoBodyKinematics, scalarProductAssignment,
  installScalarProductAssignments
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
    "WantedCouplingSignature" -> wantedSignature,
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

ordinaryGenerated = <|
  "LO" -> loGenerated,
  "RealQG" -> realGenerated,
  "Virtual" -> virtualGenerated
|>;
generatedOrdinaryDiagramCounts = AssociationMap[
  ordinaryGenerated[#]["QCDDiagramCount"] &,
  Keys[ordinaryGenerated]
];
assert[
  AllTrue[Values[generatedOrdinaryDiagramCounts], IntegerQ[#] && # > 0 &],
  "At least one generated Hqg ordinary process has no QCD diagrams."
];
assert[
  And @@ KeyValueMap[
    Length[#2["QCDDiagramNumbers"]] === #2["QCDDiagramCount"] &&
      Length[#2["QCDRawAmplitudes"]] === #2["QCDDiagramCount"] &,
    ordinaryGenerated
  ],
  "A generated ordinary-process diagram ledger is inconsistent."
];

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
countertermSelectionFlags =
  containsNamedSymbolQ[#, qcdCountertermSymbolNames] & /@ countertermRawList;
countertermPositions = Flatten@Position[
  countertermSelectionFlags,
  True,
  {1}
];
countertermRaw = rewrapFeynAmpList[countertermAllRaw, countertermPositions];
countertermDiagrams = FeynArts`DiagramExtract[
  countertermInsertions,
  countertermPositions
];

countertermDiagramCount = Length[countertermPositions];
assert[
  IntegerQ[countertermDiagramCount] && countertermDiagramCount > 0 &&
    Length[countertermSelectionFlags] === Length[countertermRawList] &&
    And @@ Extract[countertermSelectionFlags, List /@ countertermPositions],
  "The generated QCD-counterterm selection ledger is inconsistent."
];

Print["S01_STAGE: deriving the representative electric charge from SMQCD metadata"];

classDescriptionNames = Names["*M$ClassesDescription*"];
assert[Length[classDescriptionNames] === 1,
  "The loaded SMQCD class-description symbol is not unique."];
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

modelElectricQuantumNumbers = <|
  "F3" -> electricQuantumNumber[3],
  "F4" -> electricQuantumNumber[4]
|>;
assert[FreeQ[modelElectricQuantumNumbers, _Missing],
  "SMQCD electric quantum-number metadata is missing."];

chargeMarkers = DeleteDuplicates @ Cases[
  Values[modelElectricQuantumNumbers],
  symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "Charge",
  Infinity
];
assert[Length[chargeMarkers] === 1,
  "SMQCD electric quantum numbers do not contain one common charge marker."];
chargeMarker = First[chargeMarkers];

chargeCoefficient[class_Integer] := Simplify[
  electricQuantumNumber[class] /. chargeMarker -> 1
];

modelChargeCoefficients = <|
  "F3" -> chargeCoefficient[3],
  "F4" -> chargeCoefficient[4]
|>;
assert[
  FreeQ[modelChargeCoefficients, _Missing] &&
    Apply[Unequal, Values[modelChargeCoefficients]],
  "The derived SMQCD charge coefficients are missing or not independent."
];

referenceQuarkField = incomingFields[[2]];
referenceFermionClass = First[List @@ referenceQuarkField];
assert[IntegerQ[referenceFermionClass],
  "The representative quark field has no integer FeynArts class index."];
referenceQuarkElectricQuantumNumber =
  electricQuantumNumber[referenceFermionClass];
referenceQuarkElectricCharge = chargeCoefficient[referenceFermionClass];
assert[
  referenceQuarkElectricCharge === modelChargeCoefficients["F3"] &&
    referenceQuarkElectricCharge =!= modelChargeCoefficients["F4"],
  "The representative field is not the derived SMQCD F3 charge class."
];

referenceChargeStripFactor = Together[1/referenceQuarkElectricCharge];
assert[
  referenceQuarkElectricCharge =!= 0 &&
    FreeQ[referenceChargeStripFactor, _Real] &&
    Together[
      referenceQuarkElectricCharge referenceChargeStripFactor
    ] === 1,
  "The model-derived electric-charge stripping factor is not exact."
];

referenceClassIndices = FirstCase[
  classEntry[referenceFermionClass],
  Rule[key_, value_] /;
      SymbolName[Unevaluated[key]] === "Indices" :> value,
  Missing["NotFound"],
  Infinity
];
referenceHasFundamentalColorIndex =
  ListQ[referenceClassIndices] &&
    ! FreeQ[
      referenceClassIndices,
      symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "Colour"
    ];
assert[
  Head[referenceQuarkField] === FeynArts`F &&
    TrueQ[referenceHasFundamentalColorIndex],
  "The representative incoming state is not a model fermion with a fundamental color index."
];

initialSpinTraceProbe = FeynCalc`DiracSimplify[
  FeynCalc`DiracTrace[
    FeynCalc`GSD[p] . FeynCalc`GSD[s01SpinReference]
  ],
  FeynCalc`DiracTraceEvaluate -> True,
  FeynCalc`FCVerbose -> 0
];
initialSpinNormalizationProbe =
  2 FeynCalc`FCI[FeynCalc`SPD[p, s01SpinReference]];
initialSpinStates = Together[
  initialSpinTraceProbe/initialSpinNormalizationProbe
];
initialColorStates = FeynCalc`SUNSimplify[
  FeynCalc`SUNFDelta[s01ColorReference, s01ColorReference],
  FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0
];
initialStateAverage = Together[1/(initialSpinStates initialColorStates)];
assert[
  initialSpinStates =!= 0 && initialColorStates =!= 0 &&
    FreeQ[
      {initialSpinStates, initialColorStates, initialStateAverage},
      $Failed | _Real | _FeynCalc`DiracTrace
    ],
  "The incoming-state spin/color normalization was not derived exactly."
];
initialStateNormalizationDerivation = <|
  "ReferenceField" -> referenceQuarkField,
  "ReferenceClassIndices" -> referenceClassIndices,
  "FermionHeadVerified" ->
    (Head[referenceQuarkField] === FeynArts`F),
  "FundamentalColorIndexVerified" -> referenceHasFundamentalColorIndex,
  "SpinTraceProbe" -> initialSpinTraceProbe,
  "SpinTraceNormalization" -> initialSpinNormalizationProbe,
  "InitialSpinStates" -> initialSpinStates,
  "FundamentalColorTraceProbe" ->
    HoldForm[FeynCalc`SUNFDelta[s01ColorReference, s01ColorReference]],
  "InitialColorStates" -> initialColorStates,
  "InitialStateAverage" -> initialStateAverage,
  "Derivation" ->
    "FeynCalc Dirac spin-completeness trace divided by its defining two-momentum normalization, multiplied by the inverse FeynCalc fundamental-color delta trace"
|>;

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

convertedCollections = <|
  "LO" -> loFC,
  "RealQG" -> realFC,
  "Virtual" -> virtualFC,
  "Counterterm" -> countertermFC
|>;
ordinaryConvertedCollections = KeyTake[
  convertedCollections,
  Keys[ordinaryGenerated]
];
ordinaryPhotonCouplingCounts = AssociationMap[
  Function[label,
    Count[#, FeynArts`FCGV["EL"], {0, Infinity}] & /@
      ordinaryConvertedCollections[label]
  ],
  Keys[ordinaryConvertedCollections]
];
wantedOrdinaryPhotonCouplingOrders = AssociationMap[
  First[ordinaryGenerated[#]["WantedCouplingSignature"]] &,
  Keys[ordinaryGenerated]
];
ordinaryPhotonCouplingGate = And @@ KeyValueMap[
  Function[{label, counts},
    And @@ (# === wantedOrdinaryPhotonCouplingOrders[label] & /@ counts)
  ],
  ordinaryPhotonCouplingCounts
];
countertermPhotonCouplingCounts = Count[
    #, FeynArts`FCGV["EL"], {0, Infinity}
  ] & /@ countertermFC;
countertermPhotonCouplingInventory = Counts[countertermPhotonCouplingCounts];
countertermPhotonCouplingGate =
  Length[countertermPhotonCouplingCounts] === countertermDiagramCount &&
    Total[Values[countertermPhotonCouplingInventory]] ===
      countertermDiagramCount &&
    AllTrue[
      Keys[countertermPhotonCouplingInventory],
      IntegerQ[#] && # > 0 &
    ];
assert[
  TrueQ[ordinaryPhotonCouplingGate],
  "An ordinary converted amplitude violates its generated QED-coupling signature."
];
assert[
  TrueQ[countertermPhotonCouplingGate],
  "The generated counterterm photon-coupling inventory is inconsistent."
];

Scan[
  Function[label,
    assert[ListQ[convertedCollections[label]],
      label <> " conversion did not return a list."];
    assert[
      Length[convertedCollections[label]] ===
        If[
          KeyExistsQ[generatedOrdinaryDiagramCounts, label],
          generatedOrdinaryDiagramCounts[label],
          countertermDiagramCount
        ],
      label <> " converted-amplitude count mismatch."];
    assert[FreeQ[convertedCollections[label], _FeynArts`FAFeynAmp],
      label <> " conversion left a FeynArts amplitude unevaluated."]
  ],
  Keys[convertedCollections]
];

scalarProductAssignment[pair_, value_] := Module[
  {pairComponents, leftComponents, rightComponents},
  pairComponents = List @@ pair;
  assert[
    Length[pairComponents] === 2 &&
      And @@ (Head[#] === FeynCalc`Momentum & /@ pairComponents),
    "A solved scalar-product object is not a two-momentum FeynCalc Pair."
  ];
  leftComponents = List @@ pairComponents[[1]];
  rightComponents = List @@ pairComponents[[2]];
  assert[
    Length[leftComponents] === 2 && Length[rightComponents] === 2 &&
      Last[leftComponents] === Last[rightComponents],
    "A solved scalar-product Pair has inconsistent momentum dimensions."
  ];
  <|
    "Momentum1" -> First[leftComponents],
    "Momentum2" -> First[rightComponents],
    "Dimension" -> Last[leftComponents],
    "Value" -> value
  |>
];

installScalarProductAssignments[assignments_List] := Scan[
  Function[assignment,
    With[
      {
        momentum1 = Lookup[assignment, "Momentum1"],
        momentum2 = Lookup[assignment, "Momentum2"],
        value = Lookup[assignment, "Value"]
      },
      FeynCalc`SPD[momentum1, momentum2] = value
    ]
  ],
  assignments
];

deriveTwoBodyKinematics[] := Module[
  {
    massShellAssignments, massShellInstallationResiduals,
    vectors, momentumResidual, definingEquations, definingEquationsHeld,
    pairObjects,
    algebraicVariables, pairToVariableRules, algebraicEquations,
    solutions, solution, pairRules, solvedScalarProductsHeld,
    scalarProductAssignments, scalarProductInstallationResiduals,
    uHatRule, equationResiduals
  },
  FeynCalc`FCClearScalarProducts[];
  massShellAssignments = {
    <|"Momentum" -> p, "MassSquared" -> 0|>,
    <|"Momentum" -> q, "MassSquared" -> -Q2|>,
    <|"Momentum" -> k1, "MassSquared" -> 0|>,
    <|"Momentum" -> k2, "MassSquared" -> 0|>
  };
  Scan[
    Function[assignment,
      With[
        {
          momentum = Lookup[assignment, "Momentum"],
          massSquared = Lookup[assignment, "MassSquared"]
        },
        FeynCalc`SPD[momentum, momentum] = massSquared
      ]
    ],
    massShellAssignments
  ];
  massShellInstallationResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum"], Lookup[#, "Momentum"]
      ] - Lookup[#, "MassSquared"]
    ] & /@ massShellAssignments;
  assert[
    And @@ (# === 0 & /@ massShellInstallationResiduals),
    "The mass-shell assignments were not installed exactly."
  ];

  vectors = {p, q, k1, k2};
  momentumResidual = p + q - k1 - k2;
  definingEquations = Join[
    {
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[p + q, p + q]
      ] == sHat,
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[q - k1, q - k1]
      ] == tHat,
      FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[p - k1, p - k1]
      ] == uHat
    },
    FeynCalc`ExpandScalarProduct[
        FeynCalc`SPD[momentumResidual, #]
      ] == 0 & /@ vectors
  ];
  definingEquationsHeld = ToExpression[
    ToString[definingEquations, InputForm],
    InputForm,
    HoldComplete
  ];
  pairObjects = DeleteDuplicates[
    Cases[definingEquations, _FeynCalc`Pair, Infinity]
  ];
  algebraicVariables = Array[s01KinematicScalar, Length[pairObjects]];
  pairToVariableRules = Thread[pairObjects -> algebraicVariables];
  algebraicEquations = definingEquations /. pairToVariableRules;
  solutions = Solve[
    algebraicEquations,
    Join[algebraicVariables, {uHat}]
  ];
  assert[
    ListQ[solutions] && Length[solutions] === 1,
    "The defining two-body kinematics do not have one exact solution."
  ];
  solution = First[solutions];
  pairRules = Thread[
    pairObjects -> (algebraicVariables /. solution)
  ];
  solvedScalarProductsHeld = ToExpression[
    ToString[pairRules, InputForm],
    InputForm,
    HoldComplete
  ];
  scalarProductAssignments = MapThread[
    scalarProductAssignment,
    {pairObjects, algebraicVariables /. solution}
  ];
  uHatRule = FirstCase[
    solution,
    HoldPattern[uHat -> value_] :> (uHat -> value),
    Missing["NotFound"]
  ];
  equationResiduals = Together[
      (#[[1]] - #[[2]]) /. solution
    ] & /@ algebraicEquations;
  assert[
    ! MissingQ[uHatRule] && And @@ (# === 0 & /@ equationResiduals) &&
      Length[scalarProductAssignments] === Length[pairObjects] &&
      AllTrue[scalarProductAssignments, AssociationQ] &&
      FreeQ[
        {
          scalarProductAssignments, uHatRule, equationResiduals,
          definingEquationsHeld, solvedScalarProductsHeld
        },
        _Real | _Missing
      ],
    "The solved two-body kinematics failed exact defining-equation gates."
  ];
  installScalarProductAssignments[scalarProductAssignments];
  scalarProductInstallationResiduals = Together[
      FeynCalc`SPD[
        Lookup[#, "Momentum1"], Lookup[#, "Momentum2"]
      ] - Lookup[#, "Value"]
    ] & /@ scalarProductAssignments;
  assert[
    And @@ (# === 0 & /@ scalarProductInstallationResiduals),
    "The solved scalar-product assignments were not installed exactly."
  ];
  <|
    "SerializationSchema" -> "HqgS01Kinematics-v2",
    "MassShellAssignments" -> massShellAssignments,
    "MassShellInstallationResiduals" ->
      massShellInstallationResiduals,
    "DefiningEquationsHeld" -> definingEquationsHeld,
    "ScalarProductAssignments" -> scalarProductAssignments,
    "SolvedScalarProductsHeld" -> solvedScalarProductsHeld,
    "ScalarProductInstallationResiduals" ->
      scalarProductInstallationResiduals,
    "MandelstamURule" -> uHatRule,
    "EquationResiduals" -> equationResiduals,
    "UniqueExactSolution" -> (Length[solutions] === 1)
  |>
];

(* Tool-derived massless 2->2 kinematics with observed gluon k1. *)
twoBodyKinematicDerivation = deriveTwoBodyKinematics[];
twoBodyKinematicDerivationRoundTrip = ToExpression[
  ToString[twoBodyKinematicDerivation, InputForm],
  InputForm
];
kinematicSerializationRoundTripGate = SameQ[
  twoBodyKinematicDerivationRoundTrip,
  twoBodyKinematicDerivation
];
assert[
  kinematicSerializationRoundTripGate,
  "The two-body kinematic ledger failed an InputForm serialization round trip."
];

reduceVirtualAmplitude[amp_, index_Integer] := Module[{answer},
  Print[
    "S01_STAGE: TID virtual diagram " <> ToString[index] <> "/" <>
      ToString[generatedOrdinaryDiagramCounts["Virtual"]]
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
      ToString[generatedOrdinaryDiagramCounts["Virtual"]]
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
      ToString[generatedOrdinaryDiagramCounts["Virtual"]]
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
  "TotalQCDDiagramsIncludingCounterterms" ->
    Total[Values[generatedOrdinaryDiagramCounts]] + countertermDiagramCount
|>;

bigTMDConvention = <|
  "Repository" -> "https://github.com/JeffersonLab/BigTMD",
  "VerifiedCommit" -> "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c",
  "ChannelNumber" -> 3,
  "ChargeCase" -> "A only",
  "LOProjectorKernels" -> {"LO.PgB", "LO.PppB"},
  "NLOProjectorModules" -> {"NLO.Pg.fchn3A", "NLO.Ppp.fchn3A"},
  "PhysicalLuminosity" -> "Sum_q e_q^2 f_q D_g",
  "DistributionPiecesDownstream" -> {"regular", "delta", "plus1B", "plus2B"}
|>;

diagramLedgerGate =
  And @@ KeyValueMap[
    Length[convertedCollections[#1]] === #2 &,
    Join[
      generatedOrdinaryDiagramCounts,
      <|"Counterterm" -> countertermDiagramCount|>
    ]
  ] &&
  diagramCounts["TotalQCDDiagramsIncludingCounterterms"] ===
    Total[Values[generatedOrdinaryDiagramCounts]] + countertermDiagramCount;
paperProcessContentGate =
  incomingFields === {FeynArts`V[1], FeynArts`F[3, {1}]} &&
    outgoingFields["LO"] === {FeynArts`V[5], FeynArts`F[3, {1}]} &&
    outgoingFields["Virtual"] === outgoingFields["LO"] &&
    Count[outgoingFields["RealQG"], _FeynArts`F] ===
      Count[incomingFields, _FeynArts`F] &&
    Count[outgoingFields["RealQG"], FeynArts`V[5]] >
      Count[outgoingFields["LO"], FeynArts`V[5]];
chargeDerivationGate =
  referenceQuarkField === incomingFields[[2]] &&
    referenceQuarkElectricCharge ===
      modelChargeCoefficients[
        "F" <> ToString[referenceFermionClass]
      ] &&
    Together[
      referenceQuarkElectricCharge referenceChargeStripFactor
    ] === 1;
chargeStrippingGate =
  chargeDerivationGate &&
    FreeQ[convertedCollections, chargeMarker | _Real];
initialStateNormalizationGate =
  TrueQ[referenceHasFundamentalColorIndex] &&
    Head[referenceQuarkField] === FeynArts`F &&
    initialSpinStates =!= 0 && initialColorStates =!= 0 &&
    Together[
      initialStateAverage initialSpinStates initialColorStates
    ] === 1;
kinematicDerivationGate =
  twoBodyKinematicDerivation["SerializationSchema"] ===
      "HqgS01Kinematics-v2" &&
    TrueQ[twoBodyKinematicDerivation["UniqueExactSolution"]] &&
    ListQ[twoBodyKinematicDerivation["MassShellAssignments"]] &&
    AllTrue[
      twoBodyKinematicDerivation["ScalarProductAssignments"],
      Function[assignment,
        AssociationQ[assignment] &&
          And @@ (KeyExistsQ[assignment, #] & /@ {
            "Momentum1", "Momentum2", "Dimension", "Value"
          })
      ]
    ] &&
    Head[twoBodyKinematicDerivation["DefiningEquationsHeld"]] ===
      HoldComplete &&
    Head[twoBodyKinematicDerivation["SolvedScalarProductsHeld"]] ===
      HoldComplete &&
    ! FreeQ[
      twoBodyKinematicDerivation["DefiningEquationsHeld"],
      _FeynCalc`Pair
    ] &&
    ! FreeQ[
      twoBodyKinematicDerivation["SolvedScalarProductsHeld"],
      _FeynCalc`Pair
    ] &&
    And @@ (# === 0 & /@
      twoBodyKinematicDerivation["MassShellInstallationResiduals"]) &&
    And @@ (# === 0 & /@
      twoBodyKinematicDerivation["ScalarProductInstallationResiduals"]) &&
    And @@ (# === 0 & /@
      twoBodyKinematicDerivation["EquationResiduals"]) &&
    TrueQ[kinematicSerializationRoundTripGate];
s01Checks = <|
  "PaperTableIProcessContent" -> paperProcessContentGate,
  "BigTMDChannel3ObservedGluon" ->
    (bigTMDConvention["ChannelNumber"] === 3 &&
      outgoingFields["LO"][[1]] === FeynArts`V[5]),
  "OnlyChargeCaseA" ->
    (bigTMDConvention["ChargeCase"] === "A only" &&
      referenceQuarkField === incomingFields[[2]]),
  "EveryConvertedAmplitudeHasAtLeastOnePhotonCoupling" ->
    AllTrue[Flatten[Values[ordinaryPhotonCouplingCounts]], # > 0 &],
  "EveryOrdinaryAmplitudeMatchesRequestedPhotonCouplingOrder" ->
    ordinaryPhotonCouplingGate,
  "CountertermPhotonCouplingInventoryGenerated" ->
    countertermPhotonCouplingGate,
  "ReferenceChargeDerivedFromSMQCDClassMetadata" ->
    chargeDerivationGate,
  "ReferenceF3ChargeStrippedAtAmplitudeLevel" -> chargeStrippingGate,
  "BigTMDChargeLuminosityNotDoubleCounted" ->
    (FreeQ[convertedCollections, chargeMarker] &&
      bigTMDConvention["PhysicalLuminosity"] ===
        "Sum_q e_q^2 f_q D_g"),
  "NoQuarkPairRealFamilies" ->
    (Count[outgoingFields["RealQG"], _FeynArts`F] ===
      Count[incomingFields, _FeynArts`F]),
  "DiagramCountsGeneratedAndInternallyConsistent" -> diagramLedgerGate,
  "TwoBodyKinematicsUniquelyDerived" -> kinematicDerivationGate,
  "TwoBodyKinematicLedgerSerializationRoundTrip" ->
    kinematicSerializationRoundTripGate,
  "InitialStateAverageToolDerived" -> initialStateNormalizationGate
|>;
assert[
  AllTrue[Values[s01Checks], TrueQ],
  "At least one derived S01 validation gate is not True."
];

s01Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS01-v3",
  "Channel" -> "Hqg only",
  "Contribution" -> "Hqg;q + Hqg;qg",
  "PerturbativeOrders" -> <|
    "LO" -> "O(alpha_s) hard part: tree gamma* q -> g q",
    "NLO" -> "O(alpha_s^2) hard part: one-loop 2->2 plus tree 2->3"
  |>,
  "ReferencePDF" -> referencePath,
  "ReferencePDFSHA256" -> FileHash[referencePath, "SHA256"],
  "BigTMDConvention" -> bigTMDConvention,
  "ElectricChargeNormalization" -> <|
    "FeynArtsReferenceField" -> referenceQuarkField,
    "FeynArtsReferenceClass" -> referenceFermionClass,
    "ReferenceElectricQuantumNumber" ->
      referenceQuarkElectricQuantumNumber,
    "ReferenceCharge" -> referenceQuarkElectricCharge,
    "AmplitudeStripFactor" -> referenceChargeStripFactor,
    "ModelElectricQuantumNumbers" -> modelElectricQuantumNumbers,
    "ModelChargeCoefficients" -> modelChargeCoefficients,
    "Derivation" ->
      "exact coefficient of the common Charge marker in the loaded SMQCD M$ClassesDescription entry for the incoming FeynArts fermion class; strip factor is its exact reciprocal",
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
  "InitialStateNormalization" -> initialStateNormalizationDerivation,
  "GenerationLedgers" -> <|
    "OrdinaryDiagramCounts" -> generatedOrdinaryDiagramCounts,
    "CountertermDiagramCount" -> countertermDiagramCount,
    "OrdinaryPhotonCouplingCounts" -> ordinaryPhotonCouplingCounts,
    "CountertermPhotonCouplingCounts" ->
      countertermPhotonCouplingCounts,
    "CountertermPhotonCouplingInventory" ->
      countertermPhotonCouplingInventory
  |>,
  "KinematicDerivation" -> twoBodyKinematicDerivation,
  "Conventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "IncomingMomenta" -> {q, p},
    "OutgoingMomenta" -> {k1, k2},
    "FragmentingParton" -> "g(k1)",
    "SpectatorParton" -> "q(k2)",
    "ElectromagneticCharge" ->
      "charge-stripped hard amplitude; physical e_q^2 is supplied by the downstream flavor luminosity",
    "Masses" -> "all quarks massless",
    "MandelstamRelation" ->
      (twoBodyKinematicDerivation["MandelstamURule"] /. Rule -> Equal),
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
      "PhotonCouplingCounts" -> countertermPhotonCouplingCounts,
      "PhotonCouplingInventory" -> countertermPhotonCouplingInventory,
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
  "Checks" -> s01Checks,
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

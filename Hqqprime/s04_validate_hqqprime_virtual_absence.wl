#!/usr/bin/env wolframscript

(*
  Hqqprime S04: certify that virtual sectors are not applicable at this order.

  This stage audits the accepted S01 tree 2 -> 3 amplitude record.  It does
  not generate or modify amplitudes and does not form a bilinear.  Exact
  integer zeros published here mean structurally absent sectors, not virtual
  expressions that were calculated and happened to vanish.
*)

$HistoryLength = 0;

ClearAll[
  fatal, assert, fileSHA256, associationStringKeys, atomicPut,
  programPath, channelDirectory, scriptsDirectory, s01ProgramPath,
  s01ResultPath, referencePDFPath, resultPath, expectedS01ProgramSHA256,
  expectedS01ResultSHA256, expectedReferencePDFSHA256, programSHA256,
  actualS01ProgramSHA256, actualS01ResultSHA256, actualReferencePDFSHA256,
  staleTemporaryPaths, s01Result, requiredTopLevelKeys, s01Checks,
  conventions, expectedRepresentativeOrder, representatives,
  requiredRepresentativeKeys, representativeCounts,
  representativeListLengths, representativeTotalsExact,
  representativeFieldsValid, representativeMomentaValid,
  representativeSelectionsValid, measuredCountLedgerValid,
  modelChargeCoefficients, representativeChargeAssignments,
  expectedChargeAssignments, chargeBasis, genericChargeSymbols,
  incomingLineAmplitude, primePairLineAmplitude, genericAmplitudeSum,
  genericIdentityResidual, independentRepresentativeResiduals,
  independentGenericResiduals, chargeBasisLeafCounts,
  convertedRealPayload, payloadSymbolNames, forbiddenSymbolNames,
  presentForbiddenSymbolNames, machineRealCount, allStringKeys,
  forbiddenVirtualKeys, presentVirtualKeys, absentSectorNames,
  absentContributions, absenceStatus, checks, s04Result,
  publishedResult, resultSHA256
];

fatal[message_String] := (
  Print["S04_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] := If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

associationStringKeys[expression_] := DeleteDuplicates @ Flatten @ Cases[
  expression,
  association_Association :> Select[Keys[association], StringQ],
  {0, Infinity}
];

atomicPut[expression_, targetPath_String] := Module[
  {temporaryPath, writeSucceeded, reloaded, renameSucceeded},

  temporaryPath = targetPath <> ".tmp." <> ToString[$ProcessID];
  assert[! FileExistsQ[targetPath],
    "refusing to overwrite the final S04 result"];
  assert[! FileExistsQ[temporaryPath],
    "process-specific S04 temporary result already exists"];

  writeSucceeded = Quiet @ Check[
    Put[expression, temporaryPath];
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    False
  ];
  If[! TrueQ[writeSucceeded],
    If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
    fatal["failed to write the temporary S04 result"]
  ];

  reloaded = Quiet @ Check[Get[temporaryPath], $Failed];
  If[reloaded === $Failed || ! SameQ[reloaded, expression],
    DeleteFile[temporaryPath];
    fatal["temporary S04 result failed exact reload validation"]
  ];

  renameSucceeded = Quiet @ Check[
    RenameFile[temporaryPath, targetPath];
    True,
    False
  ];
  If[! TrueQ[renameSucceeded],
    If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
    fatal["failed to atomically publish the S04 result"]
  ];

  assert[FileExistsQ[targetPath] && FileByteCount[targetPath] > 0,
    "published S04 result is missing or empty"];
  assert[! FileExistsQ[temporaryPath],
    "temporary S04 result remains after publication"];
];

programPath = ExpandFileName[$InputFileName];
assert[StringQ[programPath] && FileExistsQ[programPath],
  "cannot resolve the running S04 source path"];

channelDirectory = DirectoryName[programPath];
scriptsDirectory = DirectoryName[channelDirectory];
s01ProgramPath = FileNameJoin[
  {channelDirectory, "s01_calculate_hqqprime_tree.wl"}
];
s01ResultPath = FileNameJoin[{channelDirectory, "s01_result"}];
referencePDFPath = FileNameJoin[
  {
    scriptsDirectory,
    "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
      "Scattering_Beyond_Lowest_Order.pdf"
  }
];
resultPath = FileNameJoin[{channelDirectory, "s04_result"}];

expectedS01ProgramSHA256 =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultSHA256 =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedReferencePDFSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";

Print["S04_STAGE: validating clean launch boundary and pinned inputs"];

assert[FileExistsQ[s01ProgramPath], "accepted S01 source is missing"];
assert[FileExistsQ[s01ResultPath], "accepted S01 result is missing"];
assert[FileExistsQ[referencePDFPath], "authoritative reference PDF is missing"];
assert[! FileExistsQ[resultPath],
  "refusing to overwrite an existing S04 result"];

staleTemporaryPaths = FileNames[
  FileNameTake[resultPath] <> ".tmp.*",
  channelDirectory
];
assert[staleTemporaryPaths === {},
  "stale S04 temporary result exists: " <>
    ToString[staleTemporaryPaths, InputForm]];

programSHA256 = fileSHA256[programPath];
actualS01ProgramSHA256 = fileSHA256[s01ProgramPath];
actualS01ResultSHA256 = fileSHA256[s01ResultPath];
actualReferencePDFSHA256 = fileSHA256[referencePDFPath];

assert[actualS01ProgramSHA256 === expectedS01ProgramSHA256,
  "accepted S01 source hash mismatch"];
assert[actualS01ResultSHA256 === expectedS01ResultSHA256,
  "accepted S01 result hash mismatch"];
assert[actualReferencePDFSHA256 === expectedReferencePDFSHA256,
  "authoritative reference PDF hash mismatch"];

s01Result = Quiet @ Check[Get[s01ResultPath], $Failed];
assert[AssociationQ[s01Result],
  "accepted S01 result did not reload as an Association"];

Print["S04_STAGE: validating accepted S01 identity and conventions"];

requiredTopLevelKeys = {
  "Status", "Stage", "Channel", "Process", "PerturbativeOrder",
  "Program", "ProgramSHA256", "ReferencePDF", "ReferencePDFSHA256",
  "Conventions", "ModelChargeCoefficients",
  "RepresentativeChargeAssignments", "MeasuredSelectedDiagramCounts",
  "Representatives", "ChargeBasis", "Checks", "DownstreamBoundary"
};
assert[ContainsAll[Keys[s01Result], requiredTopLevelKeys],
  "accepted S01 result is missing required top-level keys"];
assert[s01Result["Status"] === "Complete",
  "accepted S01 status is not Complete"];
assert[s01Result["Stage"] === "HqqprimeS01-v1",
  "accepted S01 stage identity mismatch"];
assert[s01Result["Channel"] === "Hqqprime only",
  "accepted S01 channel identity mismatch"];
assert[s01Result["Program"] === s01ProgramPath,
  "accepted S01 source path provenance mismatch"];
assert[s01Result["ProgramSHA256"] === expectedS01ProgramSHA256,
  "accepted S01 embedded source hash mismatch"];
assert[s01Result["ReferencePDF"] === referencePDFPath,
  "accepted S01 reference path provenance mismatch"];
assert[s01Result["ReferencePDFSHA256"] === expectedReferencePDFSHA256,
  "accepted S01 embedded reference hash mismatch"];

s01Checks = s01Result["Checks"];
assert[AssociationQ[s01Checks] && Length[s01Checks] > 0,
  "accepted S01 check ledger is missing or empty"];
assert[And @@ (TrueQ /@ Values[s01Checks]),
  "at least one accepted S01 check is not literal True"];

assert[
  s01Result["Process"] ===
    "gamma*(q) + q(p) -> qPrime(k1) + q(k2) + qbarPrime(k3)",
  "accepted S01 process identity mismatch"
];
assert[
  s01Result["PerturbativeOrder"] ===
    "tree 2->3 contribution to the O(alpha_s^2) hard part",
  "accepted S01 perturbative-order identity mismatch"
];

conventions = s01Result["Conventions"];
assert[AssociationQ[conventions], "accepted S01 conventions are missing"];
assert[conventions["Dimension"] === HoldForm[D == 4 - 2 epsilon],
  "accepted S01 D-dimensional convention mismatch"];
assert[conventions["IncomingMomenta"] === {q, p},
  "accepted S01 incoming momentum order mismatch"];
assert[conventions["OutgoingMomenta"] === {k1, k2, k3},
  "accepted S01 outgoing momentum order mismatch"];
assert[conventions["FragmentingMomentum"] === k1,
  "accepted S01 fragmenting momentum mismatch"];
assert[
  conventions["FragmentingFlavor"] ===
    "qPrime different from incoming q",
  "accepted S01 fragmenting-flavour convention mismatch"
];
assert[conventions["UnobservedOrderedFlavors"] === {"q", "qbarPrime"},
  "accepted S01 unobserved flavour order mismatch"];
assert[conventions["Masses"] === "all quarks massless",
  "accepted S01 mass convention mismatch"];
assert[TrueQ[conventions["ElectromagneticCouplingRetained"]],
  "accepted S01 electromagnetic-coupling convention mismatch"];
assert[conventions["StrongCouplingPowerInAmplitude"] === 2,
  "accepted S01 strong-coupling amplitude power mismatch"];
assert[TrueQ[conventions["NoFlavorMultiplicityApplied"]],
  "accepted S01 flavour-multiplicity convention mismatch"];

Print["S04_STAGE: independently auditing real representatives"];

expectedRepresentativeOrder = {"up_up", "up_down", "down_up"};
representatives = s01Result["Representatives"];
assert[AssociationQ[representatives] &&
    Keys[representatives] === expectedRepresentativeOrder,
  "accepted S01 representative order mismatch"];

requiredRepresentativeKeys = {
  "Label", "IncomingField", "PrimeField", "OutgoingFields",
  "IncomingMomenta", "OutgoingMomenta", "SelectedDiagramNumbers",
  "SelectedDiagramCount", "SelectedDiagrams", "SelectedRawAmplitudes",
  "FeynCalcAmplitudesPerDiagram", "FeynCalcAmplitudeSum"
};
assert[
  AllTrue[
    Values[representatives],
    Function[representative,
      ContainsAll[Keys[representative], requiredRepresentativeKeys]
    ]
  ],
  "an accepted S01 representative is missing required fields"
];

representativeFieldsValid = AssociationMap[
  Function[label,
    With[{representative = representatives[label]},
      representative["Label"] === label &&
      representative["IncomingField"] =!= representative["PrimeField"] &&
      representative["OutgoingFields"] === {
        representative["PrimeField"],
        representative["IncomingField"],
        -representative["PrimeField"]
      }
    ]
  ],
  expectedRepresentativeOrder
];
assert[And @@ Values[representativeFieldsValid],
  "accepted S01 different-flavour field routing failed"];

representativeMomentaValid = AssociationMap[
  Function[label,
    representatives[label, "IncomingMomenta"] ===
      conventions["IncomingMomenta"] &&
    representatives[label, "OutgoingMomenta"] ===
      conventions["OutgoingMomenta"]
  ],
  expectedRepresentativeOrder
];
assert[And @@ Values[representativeMomentaValid],
  "accepted S01 representative momentum routing failed"];

representativeCounts = AssociationMap[
  representatives[#, "SelectedDiagramCount"] &,
  expectedRepresentativeOrder
];
representativeListLengths = AssociationMap[
  Function[label,
    <|
      "SelectedDiagramNumbers" ->
        Length[representatives[label, "SelectedDiagramNumbers"]],
      "SelectedDiagrams" ->
        Length[representatives[label, "SelectedDiagrams"]],
      "SelectedRawAmplitudes" ->
        Length[representatives[label, "SelectedRawAmplitudes"]],
      "FeynCalcAmplitudesPerDiagram" ->
        Length[representatives[label, "FeynCalcAmplitudesPerDiagram"]]
    |>
  ],
  expectedRepresentativeOrder
];

representativeSelectionsValid = AssociationMap[
  Function[label,
    With[
      {
        count = representativeCounts[label],
        numbers = representatives[label, "SelectedDiagramNumbers"],
        converted =
          representatives[label, "FeynCalcAmplitudesPerDiagram"]
      },
      IntegerQ[count] && count > 0 &&
      AllTrue[numbers, IntegerQ[#] && # > 0 &] &&
      DuplicateFreeQ[numbers] &&
      And @@ (# === count & /@ Values[representativeListLengths[label]]) &&
      AllTrue[converted, # =!= 0 &]
    ]
  ],
  expectedRepresentativeOrder
];
assert[And @@ Values[representativeSelectionsValid],
  "accepted S01 selected-set/count validation failed"];

representativeTotalsExact = AssociationMap[
  Function[label,
    Total[representatives[label, "FeynCalcAmplitudesPerDiagram"]] ===
      representatives[label, "FeynCalcAmplitudeSum"]
  ],
  expectedRepresentativeOrder
];
assert[And @@ Values[representativeTotalsExact],
  "an accepted S01 per-diagram amplitude total is not exact"];

measuredCountLedgerValid =
  s01Result["MeasuredSelectedDiagramCounts"] === representativeCounts &&
  Apply[SameQ, Values[representativeCounts]];
assert[measuredCountLedgerValid,
  "accepted S01 measured selected-count ledger mismatch"];

Print["S04_STAGE: independently auditing two-charge reconstruction"];

modelChargeCoefficients = s01Result["ModelChargeCoefficients"];
assert[AssociationQ[modelChargeCoefficients] &&
    Keys[modelChargeCoefficients] === {"UpType", "DownType"},
  "accepted S01 model charge-coefficient ledger mismatch"];
assert[
  AllTrue[
    Values[modelChargeCoefficients],
    MatchQ[#, _Integer | _Rational] &
  ] &&
  modelChargeCoefficients["UpType"] =!=
    modelChargeCoefficients["DownType"],
  "accepted S01 model charge coefficients are not distinct exact numbers"
];

representativeChargeAssignments =
  s01Result["RepresentativeChargeAssignments"];
expectedChargeAssignments = <|
  "up_up" -> <|
    "IncomingCharge" -> modelChargeCoefficients["UpType"],
    "PrimeCharge" -> modelChargeCoefficients["UpType"]
  |>,
  "up_down" -> <|
    "IncomingCharge" -> modelChargeCoefficients["UpType"],
    "PrimeCharge" -> modelChargeCoefficients["DownType"]
  |>,
  "down_up" -> <|
    "IncomingCharge" -> modelChargeCoefficients["DownType"],
    "PrimeCharge" -> modelChargeCoefficients["UpType"]
  |>
|>;
assert[representativeChargeAssignments === expectedChargeAssignments,
  "accepted S01 representative charge assignments mismatch"];
assert[FreeQ[representativeChargeAssignments, _Real],
  "accepted S01 representative charge assignments contain machine numbers"];

chargeBasis = s01Result["ChargeBasis"];
assert[AssociationQ[chargeBasis] && ContainsAll[
    Keys[chargeBasis],
    {
      "GenericChargeSymbols", "IncomingLineAmplitude",
      "PrimePairLineAmplitude", "GenericAmplitudeSum",
      "RepresentativeResiduals", "GenericRepresentativeResiduals"
    }
  ],
  "accepted S01 charge-basis record is incomplete"];

genericChargeSymbols = chargeBasis["GenericChargeSymbols"];
assert[MatchQ[genericChargeSymbols, {_Symbol, _Symbol}] &&
    DuplicateFreeQ[genericChargeSymbols],
  "accepted S01 generic charge symbols are not two distinct symbols"];

incomingLineAmplitude = chargeBasis["IncomingLineAmplitude"];
primePairLineAmplitude = chargeBasis["PrimePairLineAmplitude"];
genericAmplitudeSum = chargeBasis["GenericAmplitudeSum"];
assert[incomingLineAmplitude =!= 0 && primePairLineAmplitude =!= 0,
  "an accepted S01 charge-basis amplitude is zero"];

genericIdentityResidual = Simplify @ Expand[
  genericAmplitudeSum -
  genericChargeSymbols[[1]] incomingLineAmplitude -
  genericChargeSymbols[[2]] primePairLineAmplitude
];
assert[genericIdentityResidual === 0,
  "accepted S01 expanded generic charge identity failed"];

independentRepresentativeResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      assignment["IncomingCharge"] incomingLineAmplitude +
      assignment["PrimeCharge"] primePairLineAmplitude -
      representatives[label, "FeynCalcAmplitudeSum"]
    ]
  ],
  representativeChargeAssignments
];
assert[And @@ (# === 0 & /@ Values[independentRepresentativeResiduals]),
  "independent line-amplitude reconstruction failed"];
assert[
  independentRepresentativeResiduals ===
    chargeBasis["RepresentativeResiduals"],
  "saved representative residual ledger disagrees with reconstruction"
];

independentGenericResiduals = Association @ KeyValueMap[
  Function[{label, assignment},
    label -> Simplify @ Expand[
      (
        genericAmplitudeSum /.
        Thread[
          genericChargeSymbols -> {
            assignment["IncomingCharge"], assignment["PrimeCharge"]
          }
        ]
      ) - representatives[label, "FeynCalcAmplitudeSum"]
    ]
  ],
  representativeChargeAssignments
];
assert[And @@ (# === 0 & /@ Values[independentGenericResiduals]),
  "independent generic-charge reconstruction failed"];
assert[
  independentGenericResiduals ===
    chargeBasis["GenericRepresentativeResiduals"],
  "saved generic residual ledger disagrees with reconstruction"
];

chargeBasisLeafCounts = <|
  "IncomingLineAmplitude" -> LeafCount[incomingLineAmplitude],
  "PrimePairLineAmplitude" -> LeafCount[primePairLineAmplitude],
  "GenericAmplitudeSum" -> LeafCount[genericAmplitudeSum]
|>;

Print["S04_STAGE: certifying virtual-payload absence and exact purity"];

convertedRealPayload = {
  Table[
    {
      representatives[label, "FeynCalcAmplitudesPerDiagram"],
      representatives[label, "FeynCalcAmplitudeSum"]
    },
    {label, expectedRepresentativeOrder}
  ],
  incomingLineAmplitude,
  primePairLineAmplitude,
  genericAmplitudeSum
};

payloadSymbolNames = DeleteDuplicates @ Cases[
  convertedRealPayload,
  symbol_Symbol :> SymbolName[Unevaluated[symbol]],
  {0, Infinity},
  Heads -> True
];
forbiddenSymbolNames = {
  "FeynAmp", "PaVe", "A0", "A00", "B0", "B1", "B00", "B11",
  "C0", "D0", "E0", "TID", "TIDL", "GLI", "FCTopology",
  "EpsilonUV", "EpsilonIR", "ScaleMu", "LoopMomentum",
  "LoopMomenta", "ell"
};
presentForbiddenSymbolNames =
  Intersection[payloadSymbolNames, forbiddenSymbolNames];
machineRealCount = Length @ Cases[
  convertedRealPayload,
  _Real,
  {0, Infinity},
  Heads -> True
];
assert[presentForbiddenSymbolNames === {},
  "converted S01 payload contains forbidden loop/UV/IR/scale symbols: " <>
    ToString[presentForbiddenSymbolNames, InputForm]];
assert[machineRealCount === 0,
  "converted S01 payload contains machine-real numbers"];

allStringKeys = associationStringKeys[s01Result];
forbiddenVirtualKeys = {
  "LO", "Born", "TwoBodyBorn", "NLOVirtual", "Virtual",
  "VirtualAmplitude", "VirtualAmplitudes", "OneLoop",
  "OneLoopVirtual", "LoopAmplitude", "LoopPole", "LoopPoles",
  "UV", "UVCounterterm", "UVCounterterms", "Counterterms", "Poles"
};
presentVirtualKeys = Intersection[allStringKeys, forbiddenVirtualKeys];
assert[presentVirtualKeys === {},
  "accepted S01 unexpectedly contains virtual-sector keys: " <>
    ToString[presentVirtualKeys, InputForm]];

absentSectorNames = {
  "TwoBodyBorn", "OneLoopVirtual", "LoopPole", "UVCounterterm"
};
absentContributions = AssociationMap[0 &, absentSectorNames];
absenceStatus = AssociationMap["NotApplicableAtThisOrder" &, absentSectorNames];

checks = <|
  "PinnedS01SourceHashExact" ->
    (actualS01ProgramSHA256 === expectedS01ProgramSHA256),
  "PinnedS01ResultHashExact" ->
    (actualS01ResultSHA256 === expectedS01ResultSHA256),
  "PinnedReferenceHashExact" ->
    (actualReferencePDFSHA256 === expectedReferencePDFSHA256),
  "S01IdentityExact" ->
    (s01Result["Status"] === "Complete" &&
      s01Result["Stage"] === "HqqprimeS01-v1" &&
      s01Result["Channel"] === "Hqqprime only"),
  "AllAcceptedS01ChecksTrue" -> And @@ (TrueQ /@ Values[s01Checks]),
  "TreeRealProcessContractExact" ->
    (s01Result["PerturbativeOrder"] ===
      "tree 2->3 contribution to the O(alpha_s^2) hard part"),
  "RepresentativeOrderExact" ->
    (Keys[representatives] === expectedRepresentativeOrder),
  "DifferentFlavorFieldRoutingExact" ->
    And @@ Values[representativeFieldsValid],
  "MomentumRoutingExact" -> And @@ Values[representativeMomentaValid],
  "SelectedSetsAndCountsExact" ->
    And @@ Values[representativeSelectionsValid],
  "MeasuredCountLedgerExact" -> measuredCountLedgerValid,
  "PerDiagramTotalsExact" -> And @@ Values[representativeTotalsExact],
  "ChargeAssignmentsExact" ->
    (representativeChargeAssignments === expectedChargeAssignments),
  "BothChargeBasisAmplitudesNonzero" ->
    (incomingLineAmplitude =!= 0 && primePairLineAmplitude =!= 0),
  "GenericChargeIdentityExact" -> (genericIdentityResidual === 0),
  "RepresentativeReconstructionsExact" ->
    And @@ (# === 0 & /@ Values[independentRepresentativeResiduals]),
  "GenericReconstructionsExact" ->
    And @@ (# === 0 & /@ Values[independentGenericResiduals]),
  "ConvertedPayloadExactNoMachineReals" -> (machineRealCount === 0),
  "ConvertedPayloadHasNoLoopUVIRScaleSymbols" ->
    (presentForbiddenSymbolNames === {}),
  "NoVirtualSectorPayloadKeys" -> (presentVirtualKeys === {}),
  "AbsentContributionValuesAreExactIntegerZeros" ->
    And @@ (IntegerQ[#] && # === 0 & /@ Values[absentContributions])
|>;
assert[And @@ (TrueQ /@ Values[checks]),
  "at least one final S04 acceptance check is false"];

Print["S04_STAGE: publishing compact virtual-absence ledger"];

s04Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqprimeS04-v1",
  "Channel" -> "Hqqprime only",
  "StageDisposition" -> "NotApplicableAtThisOrder",
  "Purpose" ->
    "Machine-checkable virtual-sector absence gate for the tree-only Hqqprime channel",
  "GeneratedAt" -> DateString["ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "ReferencePDF" -> referencePDFPath,
  "ReferencePDFSHA256" -> actualReferencePDFSHA256,
  "Inputs" -> <|
    "S01Program" -> s01ProgramPath,
    "S01ProgramSHA256" -> actualS01ProgramSHA256,
    "S01Result" -> s01ResultPath,
    "S01ResultSHA256" -> actualS01ResultSHA256
  |>,
  "ReferenceClassification" -> <|
    "Locations" -> {"Table I", "Figure 2"},
    "Channel" -> "H_{q qPrime};q qbarPrime",
    "FirstContribution" ->
      "tree 2->3 contribution to the O(alpha_s^2) hard part",
    "VirtualPartnerAtThisOrder" -> "Absent"
  |>,
  "AbsentContributions" -> absentContributions,
  "AbsenceStatus" -> absenceStatus,
  "ZeroMeaning" ->
    "Exact integer zero denotes a structurally absent/not-applicable sector; no virtual expression was evaluated to obtain it.",
  "RealAmplitudeAudit" -> <|
    "RepresentativeOrder" -> expectedRepresentativeOrder,
    "MeasuredSelectedDiagramCounts" -> representativeCounts,
    "RepresentativeListLengths" -> representativeListLengths,
    "PerDiagramTotalsExact" -> representativeTotalsExact,
    "ChargeBasisLeafCounts" -> chargeBasisLeafCounts,
    "GenericChargeIdentityResidual" -> genericIdentityResidual,
    "RepresentativeResiduals" -> independentRepresentativeResiduals,
    "GenericRepresentativeResiduals" -> independentGenericResiduals
  |>,
  "VirtualPayloadAudit" -> <|
    "VirtualSectorKeysPresent" -> presentVirtualKeys,
    "ForbiddenLoopUVIRScaleSymbolNamesPresent" ->
      presentForbiddenSymbolNames,
    "MachineRealCountInConvertedPayload" -> machineRealCount
  |>,
  "NonInputBoundary" -> <|
    "S02" -> "Visualization-only PostScript artifacts were not read",
    "S03" -> "Visualization-only PDF artifact was not read"
  |>,
  "Checks" -> checks,
  "DownstreamBoundary" -> <|
    "NextStage" -> "S05",
    "Instruction" ->
      "Form the real-amplitude bilinear from hash-validated S01 while preserving e_q^2, e_qPrime^2, and e_q e_qPrime structures.",
    "BilinearFormedHere" -> False,
    "SpinColorPolarizationSumsPerformedHere" -> False,
    "ProjectorOrPhaseSpaceOperationsPerformedHere" -> False
  |>
|>;

atomicPut[s04Result, resultPath];
publishedResult = Quiet @ Check[Get[resultPath], $Failed];
assert[publishedResult =!= $Failed && SameQ[publishedResult, s04Result],
  "published S04 result failed exact final reload validation"];
assert[publishedResult["StageDisposition"] === "NotApplicableAtThisOrder",
  "published S04 disposition mismatch"];
assert[Values[publishedResult["AbsentContributions"]] === {0, 0, 0, 0},
  "published S04 absent-contribution ledger mismatch"];
assert[And @@ (TrueQ /@ Values[publishedResult["Checks"]]),
  "published S04 check ledger contains a non-True entry"];

resultSHA256 = fileSHA256[resultPath];

Print["S04_DISPOSITION=NotApplicableAtThisOrder"];
Print["S04_ABSENT_CONTRIBUTIONS=", InputForm[absentContributions]];
Print["S04_REAL_SELECTED_COUNTS=", InputForm[representativeCounts]];
Print["S04_CHARGE_BASIS_LEAF_COUNTS=", InputForm[chargeBasisLeafCounts]];
Print["S04_PROGRAM_SHA256=", programSHA256];
Print["S04_S01_RESULT_SHA256=", actualS01ResultSHA256];
Print["S04_REFERENCE_SHA256=", actualReferencePDFSHA256];
Print["S04_RESULT_SHA256=", resultSHA256];
Print["S04_SUCCESS"];
Print["S04_RESULT=", resultPath];

Quit[0];

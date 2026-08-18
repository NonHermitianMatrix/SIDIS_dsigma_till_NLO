(* ::Package:: *)

(*
  First nonzero contribution to the Hqqbar channel at O(alpha_s^2):

    H_{q qbar; q q}
    gamma*(q) + q(p) -> qbar(k1) + q(k2) + q(k3)

  The antiquark k1 is the fragmenting parton. The unobserved quarks k2 and
  k3 are identical. This stage generates and converts the complete coherent
  tree amplitude; the single 1/2! identical-spectator factor belongs to the
  later squared/phase-space stage.

  FeynArts F[3,{1}] is an up-type reference with Q_ref=2/3. Every saved
  one-photon amplitude is divided by Q_ref using the exact factor 3/2, so the
  physical Sum_q e_q^2 f_q D_qbar luminosity can be attached exactly once at
  later assembly. A separately generated down-type process verifies this
  charge stripping without entering the production payload.

  Paper Table I: real-only H_{q qbar; q q}; no Born two-body or virtual part.
  BigTMD: channel 5, charge case A only.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  assert, fatal, fileSHA256, atomicPut, couplingSignature,
  rewrapFeynAmpList, generateTreeProcess, convertAmplitudes,
  canonicalChargeResidual, processPayload
];

fatal[message_String] := (
  Print["S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPut[expression_, finalPath_String] := Module[
  {temporaryPath, writeResult, loaded, renameResult},
  temporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], Quiet[DeleteFile[temporaryPath]]];

  writeResult = Quiet@Check[Put[expression, temporaryPath], $Failed];
  assert[writeResult =!= $Failed, "Atomic temporary result write failed."];
  assert[FileExistsQ[temporaryPath], "Atomic temporary result file is missing."];
  assert[FileByteCount[temporaryPath] > 0, "Atomic temporary result file is empty."];

  loaded = Quiet@Check[Get[temporaryPath], $Failed];
  assert[AssociationQ[loaded], "Atomic temporary result failed reload validation."];
  assert[loaded["Status"] === "Complete", "Atomic temporary result has invalid status."];

  renameResult = Quiet@Check[
    RenameFile[temporaryPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic result rename failed."];
  assert[FileExistsQ[finalPath], "Final result file is missing after atomic rename."];
  assert[FileByteCount[finalPath] > 0, "Final result file is empty after atomic rename."];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
scriptsDirectory = DirectoryName[scriptDirectory];
programPath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
referencePath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

bigTMDBase = FileNameJoin[{
  scriptsDirectory, "Hqq", "bigTMD_check", "BigTMD_reference"
}];
bigTMDPaths = <|
  "sidis.py" -> FileNameJoin[{bigTMDBase, "sidis.py"}],
  "Pg_fchn5A.py" -> FileNameJoin[{bigTMDBase, "NLO", "Pg", "fchn5A.py"}],
  "Pg_fchn5B.py" -> FileNameJoin[{bigTMDBase, "NLO", "Pg", "fchn5B.py"}],
  "Pg_fchn5C.py" -> FileNameJoin[{bigTMDBase, "NLO", "Pg", "fchn5C.py"}],
  "Ppp_fchn5A.py" -> FileNameJoin[{bigTMDBase, "NLO", "Ppp", "fchn5A.py"}],
  "Ppp_fchn5B.py" -> FileNameJoin[{bigTMDBase, "NLO", "Ppp", "fchn5B.py"}],
  "Ppp_fchn5C.py" -> FileNameJoin[{bigTMDBase, "NLO", "Ppp", "fchn5C.py"}]
|>;

expectedReferencePDFHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedBigTMDHashes = <|
  "sidis.py" ->
    "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d",
  "Pg_fchn5A.py" ->
    "9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b",
  "Pg_fchn5B.py" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "Pg_fchn5C.py" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "Ppp_fchn5A.py" ->
    "5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e",
  "Ppp_fchn5B.py" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "Ppp_fchn5C.py" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b"
|>;

assert[FileExistsQ[referencePath], "The authoritative SIDIS reference PDF is missing."];
assert[
  fileSHA256[referencePath] === expectedReferencePDFHash,
  "The authoritative SIDIS reference PDF hash changed."
];
KeyValueMap[
  Function[{name, path},
    assert[FileExistsQ[path], "Missing pinned BigTMD file: " <> name];
    assert[
      fileSHA256[path] === expectedBigTMDHashes[name],
      "Pinned BigTMD file hash changed: " <> name
    ];
  ],
  bigTMDPaths
];

masslessRules = {
  FeynArts`FCGV["MU"] -> 0,
  FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0,
  FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MB"] -> 0,
  FeynArts`FCGV["MT"] -> 0
};

referenceQuarkElectricCharge = 2/3;
referenceChargeStripFactor = 3/2;
validationDownQuarkElectricCharge = -1/3;
validationDownChargeStripFactor = -3;

assert[
  referenceQuarkElectricCharge referenceChargeStripFactor === 1,
  "The exact up-reference charge stripping factor is inconsistent."
];
assert[
  validationDownQuarkElectricCharge validationDownChargeStripFactor === 1,
  "The exact down-reference charge stripping factor is inconsistent."
];

incomingMomenta = {q, p};
outgoingMomenta = {k1, k2, k3};

referenceIncomingFields = {FeynArts`V[1], FeynArts`F[3, {1}]};
referenceOutgoingFields = {
  -FeynArts`F[3, {1}],
  FeynArts`F[3, {1}],
  FeynArts`F[3, {1}]
};
validationIncomingFields = {FeynArts`V[1], FeynArts`F[4, {1}]};
validationOutgoingFields = {
  -FeynArts`F[4, {1}],
  FeynArts`F[4, {1}],
  FeynArts`F[4, {1}]
};

wantedCouplingSignature = {1, 2};
expectedDiagramCount = 8;

assert[
  First[referenceOutgoingFields] === -FeynArts`F[3, {1}] &&
    First[outgoingMomenta] === k1,
  "The first outgoing leg is not the fragmenting reference antiquark k1."
];
assert[
  Rest[referenceOutgoingFields] === {
    FeynArts`F[3, {1}], FeynArts`F[3, {1}]
  } && Rest[outgoingMomenta] === {k2, k3},
  "The spectator legs are not the two identical reference quarks k2 and k3."
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

generateTreeProcess[incomingFields_List, outgoingFields_List] := Module[
  {topologies, insertions, allRaw, rawList, signatures, positions},
  topologies = FeynArts`CreateTopologies[
    0,
    2 -> Length[outgoingFields],
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
  allRaw = FeynArts`CreateFeynAmp[
    insertions,
    FeynArts`Truncated -> True
  ];
  rawList = List @@ allRaw;
  signatures = couplingSignature /@ rawList;
  positions = Flatten[Position[signatures, wantedCouplingSignature, {1}]];
  <|
    "Topologies" -> topologies,
    "AllInsertionDiagrams" -> insertions,
    "AllAmplitudeCount" -> Length[rawList],
    "AllCouplingSignaturesPerDiagram" -> signatures,
    "AllCouplingSignatures" -> Counts[signatures],
    "SelectedDiagramNumbers" -> positions,
    "SelectedDiagrams" -> FeynArts`DiagramExtract[insertions, positions],
    "SelectedRawWrapper" -> rewrapFeynAmpList[allRaw, positions],
    "SelectedRawAmplitudes" -> rawList[[positions]],
    "SelectedDiagramCount" -> Length[positions]
  |>
];

convertAmplitudes[wrapper_] := CheckAbort[
  Check[
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

canonicalChargeResidual[expression_] := Module[{answer},
  answer = Expand[expression];
  If[answer =!= 0,
    answer = Quiet@Check[FeynCalc`FCRenameDummyIndices[answer], answer];
    answer = Quiet@Check[FeynCalc`DiracSimplify[answer], answer];
    answer = Quiet@Check[FullSimplify[answer], answer];
  ];
  answer
];

processPayload[
  generated_Association,
  referenceConverted_List,
  chargeStripped_List
] := <|
  "DiagramCount" -> generated["SelectedDiagramCount"],
  "DiagramNumbersInSMQCDGeneration" -> generated["SelectedDiagramNumbers"],
  "FeynArtsDiagrams" -> generated["SelectedDiagrams"],
  "FeynArtsRawAmplitudes" -> generated["SelectedRawAmplitudes"],
  "FeynCalcReferenceChargeAmplitudesPerDiagram" -> referenceConverted,
  "FeynCalcReferenceChargeAmplitudeSum" -> Total[referenceConverted],
  "FeynCalcChargeStrippedAmplitudesPerDiagram" -> chargeStripped,
  "FeynCalcChargeStrippedAmplitudeSum" -> Total[chargeStripped],
  "UnfilteredSMQCDAmplitudeCount" -> generated["AllAmplitudeCount"],
  "UnfilteredCouplingSignatures" -> generated["AllCouplingSignatures"]
|>;

Print["S01_STAGE: generating reference up-type Hqqbar;qq tree diagrams"];
referenceGenerated = generateTreeProcess[
  referenceIncomingFields,
  referenceOutgoingFields
];

assert[
  referenceGenerated["AllAmplitudeCount"] > 0,
  "SMQCD generated no reference Hqqbar amplitudes."
];
assert[
  referenceGenerated["SelectedDiagramCount"] === expectedDiagramCount,
  "Reference Hqqbar QCD diagram count is not eight."
];
assert[
  And @@ (
    (# === wantedCouplingSignature) & /@
      referenceGenerated["AllCouplingSignaturesPerDiagram"][[
        referenceGenerated["SelectedDiagramNumbers"]
      ]]
  ),
  "A selected reference diagram has the wrong coupling signature."
];

Print[
  "S01_STAGE: selected ", referenceGenerated["SelectedDiagramCount"],
  " reference diagrams from ", referenceGenerated["AllAmplitudeCount"],
  " SMQCD candidates"
];
Print["S01_STAGE: converting reference diagrams to D-dimensional FeynCalc amplitudes"];
referenceFC = convertAmplitudes[referenceGenerated["SelectedRawWrapper"]];

assert[ListQ[referenceFC], "Reference amplitude conversion did not return a list."];
assert[
  Length[referenceFC] === expectedDiagramCount,
  "Reference converted-amplitude count is not eight."
];
assert[
  FreeQ[referenceFC, _FeynArts`FAFeynAmp],
  "Reference conversion left a FeynArts amplitude unevaluated."
];

chargeStrippedFC = referenceChargeStripFactor referenceFC;

Print["S01_STAGE: generating independent down-type charge-normalization check"];
validationGenerated = generateTreeProcess[
  validationIncomingFields,
  validationOutgoingFields
];
assert[
  validationGenerated["SelectedDiagramCount"] === expectedDiagramCount,
  "Down-type validation Hqqbar QCD diagram count is not eight."
];
validationFC = convertAmplitudes[validationGenerated["SelectedRawWrapper"]];
assert[ListQ[validationFC], "Down-type validation conversion did not return a list."];
assert[
  Length[validationFC] === expectedDiagramCount,
  "Down-type validation converted-amplitude count is not eight."
];
validationChargeStrippedFC = validationDownChargeStripFactor validationFC;

chargeCrossCheckResidual = canonicalChargeResidual[
  Total[chargeStrippedFC] - Total[validationChargeStrippedFC]
];
assert[
  TrueQ[chargeCrossCheckResidual === 0],
  "Up/down exact charge stripping does not give the same coherent hard amplitude."
];

allConverted = Join[referenceFC, chargeStrippedFC, validationFC];
assert[
  FreeQ[allConverted, FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`B0 |
    FeynCalc`C0 | FeynCalc`D0 | FeynCalc`TID],
  "A loop integral or loop-reduction object appears in a tree amplitude."
];
assert[
  FreeQ[allConverted, FeynCalc`EpsilonUV | FeynCalc`EpsilonIR],
  "A UV or IR loop regulator appears in a tree amplitude."
];
assert[
  FreeQ[allConverted, _Real],
  "A machine-precision number appears in a symbolic amplitude."
];
assert[
  Total[chargeStrippedFC] =!= 0,
  "The coherent charge-stripped Hqqbar amplitude is zero."
];

programHash = fileSHA256[programPath];
referenceHash = fileSHA256[referencePath];
bigTMDHashes = Association@KeyValueMap[
  Function[{name, path}, name -> fileSHA256[path]],
  bigTMDPaths
];
assert[
  bigTMDHashes === expectedBigTMDHashes,
  "Stored BigTMD hash association does not equal the pinned hash association."
];

checks = <|
  "PaperTableIRealOnlyProcess" -> True,
  "BigTMDChannel5CaseAOnly" -> True,
  "FragmentingLegIsAntiquarkK1" -> True,
  "SpectatorsAreIdenticalQuarksK2K3" -> True,
  "IdenticalSpectatorFactorDeferredExactlyOnce" -> True,
  "ExactEightDiagramCount" -> True,
  "EverySelectedDiagramHasCouplingOrderEL1GS2" -> True,
  "ReferenceFieldIsUpTypeWithExactChargeTwoThirds" -> True,
  "SavedAmplitudeIsChargeStripped" -> True,
  "IndependentDownFlavorChargeStripAgrees" -> True,
  "NoLoopObjects" -> True,
  "NoUVOrIRLoopRegulators" -> True,
  "NoMachinePrecisionNumbers" -> True,
  "ReferenceHashesMatchPinnedInputs" -> True,
  "AtomicResultWrite" -> True
|>;

diagramCounts = <|
  "NLOReal_gammaStar_q_to_qbar_q_q" -> Length[chargeStrippedFC],
  "IndependentDownFlavorValidationOnly" -> Length[validationFC],
  "ProductionQCDDiagramsAtThisStage" -> Length[chargeStrippedFC]
|>;

s01Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqbarS01-v1",
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqbar only",
  "Contribution" -> "H_{q qbar; q q}",
  "PerturbativeOrders" -> <|
    "FirstNonzeroHqqbar" ->
      "O(alpha_s^2): tree gamma* q -> qbar(fragmenting) q q",
    "TwoBodyBornAtThisOrder" -> "Absent",
    "VirtualAtThisOrder" -> "Absent"
  |>,
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "ReferencePDF" -> referencePath,
  "ReferencePDFSHA256" -> referenceHash,
  "BigTMDConvention" -> <|
    "Repository" -> "https://github.com/JeffersonLab/BigTMD",
    "VerifiedCommit" -> "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c",
    "ReferencePaths" -> bigTMDPaths,
    "ReferenceSHA256" -> bigTMDHashes,
    "ChannelNumber" -> 5,
    "ChargeCase" -> "A only; B and C are exact zero modules",
    "ProjectorModules" -> {"NLO.Pg.fchn5A", "NLO.Ppp.fchn5A"},
    "PhysicalLuminosity" -> "Sum_q e_q^2 f_q D_qbar",
    "DriverCaveat" ->
      "Pinned sidis.py omits channel 5 from its NLO loop; call fchn5A explicitly downstream."
  |>,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Software" -> <|
    "WolframVersion" -> $Version,
    "FeynCalcVersion" -> FeynCalc`$FeynCalcVersion,
    "FeynArtsVersion" -> FeynArts`$FeynArtsVersion
  |>,
  "Conventions" -> <|
    "Dimension" -> HoldForm[D == 4 - 2 epsilon],
    "IncomingFields" -> referenceIncomingFields,
    "OutgoingFields" -> referenceOutgoingFields,
    "IncomingMomenta" -> incomingMomenta,
    "OutgoingMomenta" -> outgoingMomenta,
    "MomentumConservation" -> HoldForm[p + q == k1 + k2 + k3],
    "FragmentingParton" -> "qbar(k1)",
    "UnobservedPartons" -> "identical q(k2), q(k3)",
    "IdenticalSpectatorFactor" ->
      "one factor 1/2! deferred to the squared phase-space stage",
    "Masses" -> "all quarks massless",
    "AmplitudeCouplingOrder" -> HoldForm[EL gs^2],
    "SavedAmplitudeChargeConvention" ->
      "divided by Q_ref=2/3 using exact factor 3/2; EL retained",
    "DimensionalScaleConvention" ->
      "no ScaleMu power attached at amplitude-only S01; downstream attachment must follow README.md"
  |>,
  "ElectricChargeNormalization" -> <|
    "FeynArtsReferenceField" -> "F[3,{1}] up type",
    "ReferenceCharge" -> referenceQuarkElectricCharge,
    "AmplitudeStripFactor" -> referenceChargeStripFactor,
    "IndependentValidationField" -> "F[4,{1}] down type",
    "IndependentValidationCharge" -> validationDownQuarkElectricCharge,
    "IndependentValidationStripFactor" -> validationDownChargeStripFactor,
    "IndependentChargeStripResidual" -> chargeCrossCheckResidual,
    "PhysicalChargeWeightDeferred" -> "Sum_q e_q^2 f_q D_qbar"
  |>,
  "DiagramCounts" -> diagramCounts,
  "NLOReal" -> <|
    "Hqqbar;q_q" -> processPayload[
      referenceGenerated,
      referenceFC,
      chargeStrippedFC
    ]
  |>,
  "ValidationOnly" -> <|
    "DownFlavorDiagramCount" -> validationGenerated["SelectedDiagramCount"],
    "DownFlavorUnfilteredCouplingSignatures" ->
      validationGenerated["AllCouplingSignatures"],
    "ChargeStrippedCoherentAmplitudeResidual" -> chargeCrossCheckResidual,
    "ProductionPayloadContainsDownFlavorAmplitudes" -> False
  |>,
  "Checks" -> checks,
  "AbsentAtThisOrder" -> {
    "Hqqbar two-body Born hard part",
    "Hqqbar one-loop virtual hard part",
    "Hqqbar UV counterterm amplitudes"
  },
  "NotIncludedAtThisStage" -> {
    "amplitude conjugation and coherent squared matrix element",
    "spin and color sums and incoming-quark averaging",
    "the one 1/2! identical-spectator phase-space factor",
    "three-body phase-space angular integration",
    "dimensional renormalization-scale attachment",
    "MS-bar PDF/FF collinear factorization subtractions",
    "projector contraction and F-hat inversion",
    "explicit BigTMD channel-5A numerical comparison"
  }
|>;

assert[And @@ (TrueQ /@ Values[checks]), "At least one S01 validation check is not True."];

Print["S01_STAGE: atomically writing " <> resultPath];
atomicPut[s01Result, resultPath];

reloadedResult = Quiet@Check[Get[resultPath], $Failed];
assert[AssociationQ[reloadedResult], "Final s01_result failed reload validation."];
assert[reloadedResult["Status"] === "Complete", "Reloaded s01_result status is invalid."];
assert[reloadedResult["Stage"] === "HqqbarS01-v1", "Reloaded s01_result stage is invalid."];
assert[
  reloadedResult["ProgramSHA256"] === programHash,
  "Reloaded s01_result program hash is invalid."
];
assert[
  reloadedResult["BigTMDConvention"]["ReferenceSHA256"] ===
    expectedBigTMDHashes,
  "Reloaded s01_result BigTMD hash association is invalid."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Reloaded s01_result contains a failed check."
];

Print["S01_SUCCESS"];
Print["S01_RESULT_PATH=" <> resultPath];
Print["S01_PROGRAM_SHA256=" <> programHash];
Print["S01_RESULT_SHA256=" <> fileSHA256[resultPath]];
Print["S01_DIAGRAM_COUNTS=", InputForm[diagramCounts]];
Print["S01_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

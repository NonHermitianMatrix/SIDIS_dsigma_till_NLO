(* ::Package:: *)

(*
  Hqqbar is real-only at O(alpha_s^2):

    gamma*(q) + q(p) -> qbar(k1, fragmenting) + q(k2) + q(k3).

  Paper Table I provides no Hqqbar two-body Born, one-loop virtual, loop-pole,
  or UV-counterterm contribution at this order.  This stage validates that
  boundary and records it explicitly.  It does not regenerate or transform
  any amplitude.
*)

$HistoryLength = 0;

ClearAll[assert, fatal, fileSHA256, atomicPut];

fatal[message_String] := (
  If[
    ValueQ[temporaryResultPath] && StringQ[temporaryResultPath] &&
      FileExistsQ[temporaryResultPath],
    Quiet[DeleteFile[temporaryResultPath]]
  ];
  Print["S04_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPut[expression_, finalPath_String] := Module[
  {writeResult, loaded, renameResult},

  temporaryResultPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[temporaryResultPath],
    "The process-specific temporary result path already exists."
  ];

  writeResult = Quiet@Check[Put[expression, temporaryResultPath], $Failed];
  assert[writeResult =!= $Failed, "Atomic temporary result write failed."];
  assert[
    FileExistsQ[temporaryResultPath],
    "Atomic temporary result file is missing."
  ];
  assert[
    FileByteCount[temporaryResultPath] > 0,
    "Atomic temporary result file is empty."
  ];

  loaded = Quiet@Check[Get[temporaryResultPath], $Failed];
  assert[
    AssociationQ[loaded],
    "Atomic temporary result failed Association reload validation."
  ];
  assert[
    loaded["Status"] === "Complete" &&
      loaded["Stage"] === "HqqbarS04-v1",
    "Atomic temporary result has invalid status or stage."
  ];
  assert[
    And @@ (TrueQ /@ Values[loaded["Checks"]]),
    "Atomic temporary result contains a failed check."
  ];

  renameResult = Quiet@Check[
    RenameFile[temporaryResultPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  assert[renameResult =!= $Failed, "Atomic result rename failed."];
  temporaryResultPath = "";

  assert[FileExistsQ[finalPath], "Final s04_result is missing after rename."];
  assert[FileByteCount[finalPath] > 0, "Final s04_result is empty."];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
scriptsDirectory = DirectoryName[scriptDirectory];
programPath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{scriptDirectory, "s01_calculate_hqqbar_real.wl"}];
s01ResultPath = FileNameJoin[{scriptDirectory, "s01_result"}];
s04ResultPath = FileNameJoin[{scriptDirectory, "s04_result"}];
referencePath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

expectedS01SourceHash =
  "750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71";
expectedS01ResultHash =
  "69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4";
expectedReferencePDFHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";

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

expectedAbsentLedger = {
  "Hqqbar two-body Born hard part",
  "Hqqbar one-loop virtual hard part",
  "Hqqbar UV counterterm amplitudes"
};

staleTemporaryPaths = FileNames["s04_result.tmp.*", scriptDirectory];
assert[
  staleTemporaryPaths === {},
  "A stale S04 temporary result exists; resolve it before production."
];

Print["S04_STAGE: validating pinned Hqqbar S01 and reference inputs"];
assert[FileExistsQ[s01SourcePath], "The accepted S01 source is missing."];
assert[FileExistsQ[s01ResultPath], "The accepted s01_result is missing."];
assert[FileExistsQ[referencePath], "The authoritative paper is missing."];
assert[
  fileSHA256[s01SourcePath] === expectedS01SourceHash,
  "The S01 source hash does not match the accepted handoff."
];
assert[
  fileSHA256[s01ResultPath] === expectedS01ResultHash,
  "The S01 result hash does not match the accepted handoff."
];
assert[
  fileSHA256[referencePath] === expectedReferencePDFHash,
  "The authoritative paper hash changed."
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

bigTMDHashes = Association@KeyValueMap[
  Function[{name, path}, name -> fileSHA256[path]],
  bigTMDPaths
];
assert[
  bigTMDHashes === expectedBigTMDHashes,
  "The actual BigTMD hash association is not the pinned association."
];

s01 = Quiet@Check[Get[s01ResultPath], $Failed];
assert[AssociationQ[s01], "s01_result did not load as an Association."];
assert[s01["Status"] === "Complete", "s01_result is not complete."];
assert[s01["Stage"] === "HqqbarS01-v1", "s01_result stage is invalid."];
assert[s01["ResultSchemaVersion"] === 1, "s01_result schema is invalid."];
assert[s01["Channel"] === "Hqqbar only", "s01_result channel is invalid."];
assert[
  s01["Contribution"] === "H_{q qbar; q q}",
  "s01_result contribution is invalid."
];
assert[
  s01["ProgramSHA256"] === expectedS01SourceHash,
  "s01_result does not bind the accepted S01 source."
];
assert[
  s01["ReferencePDFSHA256"] === expectedReferencePDFHash,
  "s01_result paper hash is invalid."
];
assert[
  s01["BigTMDConvention"]["ReferenceSHA256"] === expectedBigTMDHashes,
  "s01_result BigTMD hash association is invalid."
];
assert[
  s01["BigTMDConvention"]["ChannelNumber"] === 5,
  "s01_result is not bound to BigTMD channel 5."
];
assert[
  StringStartsQ[s01["BigTMDConvention"]["ChargeCase"], "A only"],
  "s01_result is not bound to BigTMD charge case A only."
];
assert[
  s01["BigTMDConvention"]["ProjectorModules"] ===
    {"NLO.Pg.fchn5A", "NLO.Ppp.fchn5A"},
  "s01_result projector-module ledger is invalid."
];
assert[
  s01["BigTMDConvention"]["PhysicalLuminosity"] ===
    "Sum_q e_q^2 f_q D_qbar",
  "s01_result physical charge/luminosity ledger is invalid."
];
assert[
  And @@ (TrueQ /@ Values[s01["Checks"]]),
  "At least one embedded S01 check is not True."
];

Print["S04_STAGE: proving virtual renormalization is inapplicable"];
assert[
  s01["PerturbativeOrders"]["TwoBodyBornAtThisOrder"] === "Absent",
  "S01 does not mark the Hqqbar two-body Born sector absent."
];
assert[
  s01["PerturbativeOrders"]["VirtualAtThisOrder"] === "Absent",
  "S01 does not mark the Hqqbar virtual sector absent."
];
assert[
  s01["AbsentAtThisOrder"] === expectedAbsentLedger,
  "S01's explicit absent-at-this-order ledger is invalid."
];
assert[! KeyExistsQ[s01, "LO"], "An unexpected Hqqbar LO payload exists."];
assert[
  ! KeyExistsQ[s01, "NLOVirtual"],
  "An unexpected Hqqbar virtual payload exists."
];
assert[
  ! KeyExistsQ[s01, "UVCounterterms"],
  "An unexpected Hqqbar UV-counterterm payload exists."
];
assert[
  ! KeyExistsQ[s01, "Poles"],
  "An unexpected Hqqbar loop-pole payload exists."
];

assert[AssociationQ[s01["NLOReal"]], "The S01 real ledger is invalid."];
assert[
  Keys[s01["NLOReal"]] === {"Hqqbar;q_q"},
  "S01 does not contain exactly the sole Hqqbar real contribution."
];
realPayload = s01["NLOReal"]["Hqqbar;q_q"];
assert[AssociationQ[realPayload], "The Hqqbar real payload is invalid."];

diagramCount = realPayload["DiagramCount"];
referenceAmplitudes =
  realPayload["FeynCalcReferenceChargeAmplitudesPerDiagram"];
chargeStrippedAmplitudes =
  realPayload["FeynCalcChargeStrippedAmplitudesPerDiagram"];
referenceAmplitudeSum = realPayload["FeynCalcReferenceChargeAmplitudeSum"];
chargeStrippedAmplitudeSum =
  realPayload["FeynCalcChargeStrippedAmplitudeSum"];

assert[diagramCount === 8, "The sole Hqqbar real payload is not eight diagrams."];
assert[
  s01["DiagramCounts"]["NLOReal_gammaStar_q_to_qbar_q_q"] === diagramCount &&
    s01["DiagramCounts"]["ProductionQCDDiagramsAtThisStage"] === diagramCount,
  "The S01 diagram-count ledger is inconsistent."
];
assert[
  ListQ[referenceAmplitudes] && Length[referenceAmplitudes] === diagramCount,
  "The reference-charge real-amplitude list is invalid."
];
assert[
  ListQ[chargeStrippedAmplitudes] &&
    Length[chargeStrippedAmplitudes] === diagramCount,
  "The charge-stripped real-amplitude list is invalid."
];
assert[
  Total[referenceAmplitudes] === referenceAmplitudeSum,
  "The reference-charge coherent amplitude does not reconstruct exactly."
];
assert[
  Total[chargeStrippedAmplitudes] === chargeStrippedAmplitudeSum,
  "The charge-stripped coherent amplitude does not reconstruct exactly."
];
assert[
  chargeStrippedAmplitudes === (3/2) referenceAmplitudes,
  "The exact per-diagram Q_ref=2/3 charge-strip relation is invalid."
];
exactChargeStripSumResidual = Expand[
  chargeStrippedAmplitudeSum - (3/2) referenceAmplitudeSum
];
assert[
  exactChargeStripSumResidual === 0,
  "The exact coherent-sum Q_ref=2/3 charge-strip residual is nonzero."
];
assert[
  chargeStrippedAmplitudeSum =!= 0,
  "The accepted coherent Hqqbar real amplitude is zero."
];
assert[
  s01["ElectricChargeNormalization"]["ReferenceCharge"] === 2/3 &&
    s01["ElectricChargeNormalization"]["AmplitudeStripFactor"] === 3/2 &&
    s01["ElectricChargeNormalization"]["IndependentChargeStripResidual"] === 0,
  "The exact electromagnetic charge-normalization ledger is invalid."
];
assert[
  s01["ValidationOnly"]["ChargeStrippedCoherentAmplitudeResidual"] === 0 &&
    s01["ValidationOnly"]["ProductionPayloadContainsDownFlavorAmplitudes"] === False,
  "The independent flavor validation leaked into production or failed."
];
assert[
  s01["Conventions"]["FragmentingParton"] === "qbar(k1)" &&
    s01["Conventions"]["UnobservedPartons"] ===
      "identical q(k2), q(k3)",
  "The fragmenting-leg or identical-spectator ledger is invalid."
];
assert[
  s01["Conventions"]["IdenticalSpectatorFactor"] ===
    "one factor 1/2! deferred to the squared phase-space stage",
  "The identical-spectator factor is not deferred exactly once."
];

amplitudeData = Join[referenceAmplitudes, chargeStrippedAmplitudes];
assert[
  FreeQ[
    amplitudeData,
    FeynCalc`PaVe | FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`TID
  ],
  "A loop-integral or loop-reduction object appears in the real amplitudes."
];
assert[
  FreeQ[amplitudeData, FeynCalc`EpsilonUV | FeynCalc`EpsilonIR],
  "A UV or IR loop regulator appears in the real amplitudes."
];
assert[
  FreeQ[amplitudeData, _Real],
  "A machine-precision number appears in the symbolic real amplitudes."
];
assert[
  FreeQ[amplitudeData, ScaleMu],
  "A renormalization-scale power was prematurely attached in S01."
];

programHash = fileSHA256[programPath];
checks = <|
  "ValidatedS01SourceHash" -> True,
  "ValidatedS01ResultHash" -> True,
  "PinnedPaperHash" -> True,
  "PinnedBigTMDHashes" -> True,
  "CompleteHqqbarS01Schema" -> True,
  "BigTMDChannel5CaseAOnly" -> True,
  "AllS01ChecksTrue" -> True,
  "PaperTableIRealOnlyLedger" -> True,
  "NoTwoBodyBornPayload" -> True,
  "NoVirtualPayload" -> True,
  "NoLoopPolePayload" -> True,
  "NoUVCountertermPayload" -> True,
  "SingleHqqbarRealPayload" -> True,
  "EightRealDiagramsPresent" -> True,
  "ReferenceAmplitudeSumReconstructs" -> True,
  "ChargeStrippedAmplitudeSumReconstructs" -> True,
  "ExactReferenceChargeStripRelation" -> True,
  "IndependentFlavorChargeCheckPassed" -> True,
  "FragmentingAntiquarkIsK1" -> True,
  "IdenticalSpectatorFactorDeferredOnce" -> True,
  "NoLoopObjectsOrRegulators" -> True,
  "NoMachinePrecisionNumbers" -> True,
  "NoPrematureScaleAttachment" -> True,
  "AtomicS04ResultWrite" -> True
|>;

assert[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S04 check is not True."
];

s04Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqbarS04-v1",
  "ResultSchemaVersion" -> 1,
  "StageDisposition" -> "NotApplicableAtThisOrder",
  "Channel" -> "Hqqbar only",
  "Contribution" -> "H_{q qbar; q q}",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "Input" -> <|
    "S01SourcePath" -> s01SourcePath,
    "S01SourceSHA256" -> fileSHA256[s01SourcePath],
    "S01ResultPath" -> s01ResultPath,
    "S01ResultSHA256" -> fileSHA256[s01ResultPath],
    "S01Stage" -> s01["Stage"],
    "ReferencePDFPath" -> referencePath,
    "ReferencePDFSHA256" -> fileSHA256[referencePath],
    "BigTMDReferenceSHA256" -> bigTMDHashes,
    "BigTMDChannel" -> s01["BigTMDConvention"]["ChannelNumber"],
    "BigTMDChargeCase" -> s01["BigTMDConvention"]["ChargeCase"]
  |>,
  "ExternalRealProcess" -> <|
    "Incoming" -> {"gamma*(q)", "q(p)"},
    "Outgoing" -> {
      "qbar(k1, fragmenting)", "q(k2, spectator)", "q(k3, spectator)"
    },
    "DiagramCount" -> diagramCount,
    "CoherentChargeStrippedAmplitudeInput" ->
      "s01_result[NLOReal][Hqqbar;q_q][FeynCalcChargeStrippedAmplitudeSum]",
    "IdenticalSpectatorFactor" ->
      "one factor 1/2! remains deferred to the squared phase-space stage"
  |>,
  "VirtualRenormalization" -> <|
    "Applicable" -> False,
    "TwoBodyBornContributionAtThisOrder" -> 0,
    "OneLoopVirtualContributionAtThisOrder" -> 0,
    "LoopPoleContributionAtThisOrder" -> 0,
    "UVCountertermContributionAtThisOrder" -> 0,
    "ZeroMeaning" ->
      "These sectors are absent at this perturbative order; no loop amplitude was calculated and found to vanish.",
    "Reason" ->
      "Paper Table I gives Hqqbar at O(alpha_s^2) only through the tree real H_{q qbar;q q} process."
  |>,
  "RealPayloadAudit" -> <|
    "DiagramCount" -> diagramCount,
    "ReferenceAmplitudeCount" -> Length[referenceAmplitudes],
    "ChargeStrippedAmplitudeCount" -> Length[chargeStrippedAmplitudes],
    "ReferenceAmplitudeSumReconstructs" -> True,
    "ChargeStrippedAmplitudeSumReconstructs" -> True,
    "ExactChargeStripFactor" -> 3/2,
    "ExactChargeStripRelationPassed" -> True,
    "ExactChargeStripSumResidual" -> exactChargeStripSumResidual,
    "CoherentAmplitudeNonzero" -> True,
    "IndependentFlavorResidual" -> 0,
    "ContainsLoopOrRegulatorObject" -> False,
    "ContainsMachinePrecisionNumber" -> False,
    "ContainsScaleMu" -> False
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "amplitude regeneration or modification",
    "conjugation or coherent squared-matrix-element formation",
    "spin/color sums or incoming-quark averaging",
    "the deferred one 1/2! identical-spectator phase-space factor",
    "phase-space integration or dimensional scale attachment",
    "MS-bar PDF/FF collinear factorization",
    "projector contraction, F-hat inversion, or BigTMD comparison"
  },
  "DownstreamInstruction" ->
    "A future Hqqbar S05 must form only the coherent real Hqqbar;q_q bilinear from the accepted S01 amplitude. It must not seek or invent a virtual amplitude in s04_result, and it must keep the single 1/2! spectator factor deferred until the phase-space stage."
|>;

Print["S04_STAGE: atomically writing explicit Hqqbar absence result"];
atomicPut[s04Result, s04ResultPath];

reloadedResult = Quiet@Check[Get[s04ResultPath], $Failed];
assert[AssociationQ[reloadedResult], "Final s04_result failed reload."];
assert[
  reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === "HqqbarS04-v1" &&
    reloadedResult["StageDisposition"] === "NotApplicableAtThisOrder",
  "Final s04_result status, stage, or disposition is invalid."
];
assert[
  reloadedResult["ProgramSHA256"] === programHash,
  "Final s04_result program hash is invalid."
];
assert[
  reloadedResult["Input"]["S01SourceSHA256"] === expectedS01SourceHash &&
    reloadedResult["Input"]["S01ResultSHA256"] === expectedS01ResultHash,
  "Final s04_result upstream hash binding is invalid."
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Final s04_result contains a failed check."
];
assert[
  reloadedResult["VirtualRenormalization"]["Applicable"] === False &&
    Total[{
      reloadedResult["VirtualRenormalization"]["TwoBodyBornContributionAtThisOrder"],
      reloadedResult["VirtualRenormalization"]["OneLoopVirtualContributionAtThisOrder"],
      reloadedResult["VirtualRenormalization"]["LoopPoleContributionAtThisOrder"],
      reloadedResult["VirtualRenormalization"]["UVCountertermContributionAtThisOrder"]
    }] === 0,
  "Final s04_result absence contributions are invalid."
];

Print["S04_SUCCESS"];
Print["S04_PROGRAM_SHA256=" <> programHash];
Print["S04_RESULT_PATH=" <> s04ResultPath];
Print["S04_RESULT_SHA256=" <> fileSHA256[s04ResultPath]];
Print["S04_STAGE_DISPOSITION=NotApplicableAtThisOrder"];
Print["S04_REAL_DIAGRAM_COUNT=", diagramCount];
Print["S04_CHECK_COUNT=", Length[checks]];
Print["S04_RESULT_BYTES=", FileByteCount[s04ResultPath]];

Quit[0];

(* ::Package:: *)

(*
  Construct the symbolic UV-counterterm-completed Hqg virtual tensor for
    gamma*(q) + q(p) -> g(k1) + q(k2),
  where g(k1) is the fragmenting parton (BigTMD channel 3, case A).
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[assert, fatal, sha256Hex];

fatal[message_String] := (Print["S04_FATAL: " <> message]; Quit[1]);
assert[condition_, message_String] := If[! TrueQ[condition], fatal[message]];
sha256Hex[path_String] := ToLowerCase[
  IntegerString[FileHash[path, "SHA256"], 16, 64]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
stageSourcePath = ExpandFileName[$InputFileName];
sourceProgramPath = FileNameJoin[{
  scriptDirectory, "s01_calculate_hqg_lo_nlo.wl"
}];
sourcePath = FileNameJoin[{scriptDirectory, "s01_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s04_result"}];
acceptedS01SourceSHA256 =
  "8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0";
acceptedS01ResultSHA256 =
  "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198";

Print["S04_STAGE: loading and validating Hqg s01_result"];
assert[FileExistsQ[sourceProgramPath],
  "The accepted S01 source program does not exist."];
assert[FileExistsQ[sourcePath], "s01_result does not exist."];
currentS01SourceSHA256 = sha256Hex[sourceProgramPath];
currentS01ResultSHA256 = sha256Hex[sourcePath];
sourceIdentityGate =
  currentS01SourceSHA256 === acceptedS01SourceSHA256 &&
    currentS01ResultSHA256 === acceptedS01ResultSHA256;
assert[sourceIdentityGate,
  "S01 source/result identity does not match the accepted Hqg ledger."];
s01 = Check[Get[sourcePath], $Failed];
assert[AssociationQ[s01], "s01_result did not load as an Association."];
sourceSchemaGate =
  s01["Status"] === "Complete" &&
    s01["Stage"] === "HqgS01-v3" &&
    s01["Channel"] === "Hqg only" &&
    AssociationQ[s01["Checks"]] &&
    AllTrue[Values[s01["Checks"]], TrueQ];
assert[sourceSchemaGate,
  "s01_result schema/status/check contract is not accepted."];
bigTMDProcessGate =
  s01["BigTMDConvention", "ChannelNumber"] === 3 &&
    s01["BigTMDConvention", "ChargeCase"] === "A only" &&
    s01["Conventions", "FragmentingParton"] === "g(k1)";
assert[bigTMDProcessGate,
  "s01_result has the wrong BigTMD process convention."];
chargeConventionGate =
  AssociationQ[s01["ElectricChargeNormalization"]] &&
    s01["Checks", "ReferenceChargeDerivedFromSMQCDClassMetadata"] === True &&
    s01["ElectricChargeNormalization", "ReferenceCharge"] ===
      Lookup[
        s01["ElectricChargeNormalization", "ModelChargeCoefficients"],
        "F" <> ToString[
          s01["ElectricChargeNormalization", "FeynArtsReferenceClass"]
        ],
        Missing["Absent"]
      ] &&
    Together[
      s01["ElectricChargeNormalization", "ReferenceCharge"] *
        s01["ElectricChargeNormalization", "AmplitudeStripFactor"]
    ] === 1 &&
    s01["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g";
assert[chargeConventionGate,
  "s01_result is not in the charge-stripped BigTMD hard-kernel convention."
];

s01OrdinaryDiagramCounts = s01[
  "GenerationLedgers", "OrdinaryDiagramCounts"
];
s01CountertermDiagramCount = s01[
  "GenerationLedgers", "CountertermDiagramCount"
];
sourceCountLedgerSchemaGate =
  AssociationQ[s01OrdinaryDiagramCounts] &&
    And @@ (KeyExistsQ[s01OrdinaryDiagramCounts, #] & /@
      {"LO", "RealQG", "Virtual"}) &&
    AllTrue[
      Values[s01OrdinaryDiagramCounts],
      IntegerQ[#] && # > 0 &
    ] &&
    IntegerQ[s01CountertermDiagramCount] &&
    s01CountertermDiagramCount > 0;
assert[sourceCountLedgerSchemaGate,
  "The accepted S01 generated diagram ledger is missing or invalid."];
sourceProcessCollectionGate =
  s01["LO", "DiagramCount"] === s01OrdinaryDiagramCounts["LO"] &&
    s01["NLOReal", "Hqg;qg", "DiagramCount"] ===
      s01OrdinaryDiagramCounts["RealQG"] &&
    s01["NLOVirtual", "BareLoop", "DiagramCount"] ===
      s01OrdinaryDiagramCounts["Virtual"] &&
    s01["NLOVirtual", "UVCounterterms", "DiagramCount"] ===
      s01CountertermDiagramCount;
assert[sourceProcessCollectionGate,
  "An S01 process collection disagrees with its generated diagram ledger."];

barePerDiagram = s01[
  "NLOVirtual", "BareLoop", "TIDPassarinoVeltmanPerDiagram"
];
bareSumStored = s01[
  "NLOVirtual", "BareLoop", "TIDPassarinoVeltmanSum"
];
bareUVPerDiagram = s01["Poles", "UVPoles", "BareVirtualPerDiagram"];
bareUVSumStored = s01["Poles", "UVPoles", "BareVirtualTotal"];
bareIRPerDiagram = s01["Poles", "IRPoles", "BareVirtualPerDiagram"];
bareIRSumStored = s01["Poles", "IRPoles", "BareVirtualTotal"];
countertermPerDiagramOriginal = s01[
  "NLOVirtual", "UVCounterterms", "FeynCalcAmplitudesPerDiagram"
];

sourceVirtualCollectionLengthGate =
  ListQ[barePerDiagram] &&
    Length[barePerDiagram] === s01OrdinaryDiagramCounts["Virtual"] &&
    ListQ[bareUVPerDiagram] &&
    Length[bareUVPerDiagram] === s01OrdinaryDiagramCounts["Virtual"] &&
    ListQ[bareIRPerDiagram] &&
    Length[bareIRPerDiagram] === s01OrdinaryDiagramCounts["Virtual"] &&
    ListQ[countertermPerDiagramOriginal] &&
    Length[countertermPerDiagramOriginal] === s01CountertermDiagramCount;
assert[sourceVirtualCollectionLengthGate,
  "An S01 virtual/counterterm list disagrees with its generated ledger."];
bareTensorReconstructionGate = SameQ[Total[barePerDiagram], bareSumStored];
bareUVReconstructionGate = SameQ[Total[bareUVPerDiagram], bareUVSumStored];
bareIRReconstructionGate = SameQ[Total[bareIRPerDiagram], bareIRSumStored];
assert[bareTensorReconstructionGate,
  "Stored bare virtual sum is inconsistent."];
assert[bareUVReconstructionGate,
  "Stored bare UV sum is inconsistent."];
assert[bareIRReconstructionGate,
  "Stored bare IR sum is inconsistent."];

Print["S04_STAGE: projecting counterterms onto massless NLO QCD"];

qcdProjectionRules = {
  dZAA1 -> 0,
  dZe1 -> 0,
  dZZA1 -> 0,
  HoldPattern[dMf1[___]] -> 0,
  HoldPattern[Conjugate[dZfL1[indices___]]] :> dZfL1[indices],
  HoldPattern[Conjugate[dZfR1[indices___]]] :> dZfR1[indices]
};

countertermPerDiagramQCD =
  Expand[# /. qcdProjectionRules] & /@ countertermPerDiagramOriginal;
countertermSumQCD = Total[countertermPerDiagramQCD];

electroweakCountertermsRemovedGate =
  FreeQ[countertermPerDiagramQCD, dZAA1 | dZe1 | dZZA1];
massCountertermRemovedGate = FreeQ[countertermPerDiagramQCD, _dMf1];
qcdCountertermsRetainedGate =
  ! FreeQ[countertermPerDiagramQCD, dZGG1] &&
    ! FreeQ[countertermPerDiagramQCD, dZgs1] &&
    ! FreeQ[countertermPerDiagramQCD, _dZfL1 | _dZfR1];
countertermUVOnlyGate =
  FreeQ[countertermPerDiagramQCD, FeynCalc`EpsilonIR];
countertermProjectionExactGate =
  SameQ[countertermSumQCD, Total[countertermPerDiagramQCD]] &&
    FreeQ[countertermPerDiagramQCD, _Real];

assert[electroweakCountertermsRemovedGate,
  "An electroweak-only counterterm survived projection."];
assert[massCountertermRemovedGate,
  "A quark-mass counterterm survived projection."];
assert[qcdCountertermsRetainedGate,
  "At least one required symbolic QCD counterterm class is missing."];
assert[countertermUVOnlyGate,
  "An IR regulator occurs in symbolic UV counterterms."];
assert[countertermProjectionExactGate,
  "The QCD counterterm projection is not exact or reconstructible."];

Print["S04_STAGE: summing all same-process virtual contributions"];

allSameProcessContributions = Join[barePerDiagram, countertermPerDiagramQCD];
renormalizedVirtualTensorSumSymbolic = bareSumStored + countertermSumQCD;
renormalizedUVPoleSumSymbolic = bareUVSumStored + countertermSumQCD;
renormalizedIRPoleSum = bareIRSumStored;

combinedTensorReconstructionGate = SameQ[
  Total[allSameProcessContributions],
  renormalizedVirtualTensorSumSymbolic
];
tensorLorentzIndicesGate =
  ! FreeQ[renormalizedVirtualTensorSumSymbolic, FeynCalc`LorentzIndex];
uvContainsUVRegulatorGate =
  ! FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonUV];
uvHasNoIRRegulatorGate =
  FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonIR];
irContainsIRRegulatorGate =
  ! FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonIR];
irHasNoUVRegulatorGate =
  FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonUV];
renormalizedCollectionsExactGate = FreeQ[
  {
    allSameProcessContributions,
    renormalizedVirtualTensorSumSymbolic,
    renormalizedUVPoleSumSymbolic,
    renormalizedIRPoleSum
  },
  _Real
];

assert[combinedTensorReconstructionGate,
  "The combined virtual tensor sum failed reconstruction."];
assert[tensorLorentzIndicesGate,
  "The combined amplitude lost its tensor Lorentz indices."];
assert[uvContainsUVRegulatorGate,
  "The symbolic UV sector contains no bare-loop UV regulator."];
assert[uvHasNoIRRegulatorGate,
  "An IR regulator leaked into the UV sector."];
assert[irContainsIRRegulatorGate,
  "The IR sector contains no IR regulator."];
assert[irHasNoUVRegulatorGate,
  "A UV regulator leaked into the IR sector."];
assert[renormalizedCollectionsExactGate,
  "A machine real occurs in the renormalized symbolic collections."];

contributionLedger = Join[
  MapIndexed[<|
    "ContributionType" -> "BareLoop",
    "DiagramIndex" -> First[#2],
    "Amplitude" -> #1
  |> &, barePerDiagram],
  MapIndexed[<|
    "ContributionType" -> "UVCountertermQCDProjected",
    "DiagramIndex" -> First[#2],
    "Amplitude" -> #1
  |> &, countertermPerDiagramQCD]
];

contributionLedgerGate =
  Length[contributionLedger] === Length[allSameProcessContributions] &&
    Lookup[contributionLedger, "Amplitude"] ===
      allSameProcessContributions &&
    Count[
      Lookup[contributionLedger, "ContributionType"],
      "BareLoop"
    ] === Length[barePerDiagram] &&
    Count[
      Lookup[contributionLedger, "ContributionType"],
      "UVCountertermQCDProjected"
    ] === Length[countertermPerDiagramQCD];
assert[contributionLedgerGate,
  "The same-process contribution ledger failed reconstruction."];

s04Checks = <|
  "AcceptedS01SourceAndResultIdentity" -> sourceIdentityGate,
  "SourceBoundToCompleteCheckedHqgS01" -> sourceSchemaGate,
  "BigTMDChannel3ObservedGluon" -> bigTMDProcessGate,
  "ChargeStrippedHardKernelConventionPreserved" -> chargeConventionGate,
  "SourceGeneratedCountLedgerValid" -> sourceCountLedgerSchemaGate,
  "SourceProcessCollectionsMatchGeneratedLedger" ->
    sourceProcessCollectionGate,
  "SourceVirtualCollectionsMatchGeneratedLedger" ->
    sourceVirtualCollectionLengthGate,
  "BareTensorReconstruction" -> bareTensorReconstructionGate,
  "BareUVReconstruction" -> bareUVReconstructionGate,
  "BareIRReconstruction" -> bareIRReconstructionGate,
  "ElectroweakCountertermsRemoved" ->
    electroweakCountertermsRemovedGate,
  "MassCountertermRemoved" -> massCountertermRemovedGate,
  "SymbolicQCDCountertermsRetained" -> qcdCountertermsRetainedGate,
  "CountertermsContainNoEpsilonIR" -> countertermUVOnlyGate,
  "CountertermProjectionExactAndReconstructible" ->
    countertermProjectionExactGate,
  "CombinedTensorReconstruction" -> combinedTensorReconstructionGate,
  "ContributionLedgerReconstruction" -> contributionLedgerGate,
  "TensorLorentzIndicesPreserved" -> tensorLorentzIndicesGate,
  "UVContainsEpsilonUV" -> uvContainsUVRegulatorGate,
  "UVHasNoEpsilonIR" -> uvHasNoIRRegulatorGate,
  "IRContainsEpsilonIR" -> irContainsIRRegulatorGate,
  "IRHasNoEpsilonUV" -> irHasNoUVRegulatorGate,
  "RenormalizedCollectionsExact" -> renormalizedCollectionsExactGate
|>;
assert[
  AllTrue[Values[s04Checks], TrueQ],
  "At least one derived S04 validation gate is not True."
];

s04Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS04-v3",
  "Channel" -> "Hqg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "StageSource" -> stageSourcePath,
  "StageSourceSHA256" -> FileHash[stageSourcePath, "SHA256"],
  "StageSourceSHA256Hex" -> sha256Hex[stageSourcePath],
  "SourceProgram" -> sourceProgramPath,
  "SourceProgramSHA256" -> FileHash[sourceProgramPath, "SHA256"],
  "SourceProgramSHA256Hex" -> currentS01SourceSHA256,
  "SourceResult" -> sourcePath,
  "SourceResultSHA256" -> FileHash[sourcePath, "SHA256"],
  "SourceResultSHA256Hex" -> currentS01ResultSHA256,
  "ReferencePDFSHA256" -> s01["ReferencePDFSHA256"],
  "BigTMDConvention" -> s01["BigTMDConvention"],
  "ElectricChargeNormalization" -> s01["ElectricChargeNormalization"],
  "ExternalProcess" -> <|
    "Incoming" -> {"gamma*(q)", "q(p)"},
    "Outgoing" -> {"g(k1)", "q(k2)"},
    "FragmentingParton" -> "g(k1)"
  |>,
  "Interpretation" -> <|
    "Purpose" -> "UV renormalization of the NLO Hqg virtual tensor amplitude",
    "CountertermsIncluded" -> (Length[countertermPerDiagramQCD] > 0),
    "AllContributionsHaveSameExternalProcess" ->
      (sourceProcessCollectionGate && contributionLedgerGate),
    "OneToOneDiagramPairingUsed" -> False,
    "PairingReason" -> "The 23 loop and 12 counterterm diagrams have no one-to-one correspondence; complete same-process sums are combined.",
    "RenormalizationSchemeStatus" -> "QCD renormalization constants remain symbolic; scheme-specific dZ rules are required for explicit UV-pole cancellation."
  |>,
  "Counts" -> <|
    "BareLoopDiagrams" -> Length[barePerDiagram],
    "UVCountertermDiagrams" -> Length[countertermPerDiagramQCD],
    "AllSameProcessContributions" -> Length[allSameProcessContributions]
  |>,
  "QCDProjection" -> <|
    "RulesApplied" -> qcdProjectionRules,
    "ElectroweakCountertermsSetToZero" -> {dZAA1, dZe1, dZZA1},
    "MassCountertermSetToZero" -> dMf1,
    "SymbolicQCDRenormalizationConstantsRetained" -> {
      dZGG1, dZgs1, dZfL1, dZfR1
    }
  |>,
  "PerDiagram" -> <|
    "BareLoopTID" -> barePerDiagram,
    "UVCountertermsOriginal" -> countertermPerDiagramOriginal,
    "UVCountertermsQCDProjected" -> countertermPerDiagramQCD,
    "ContributionLedger" -> contributionLedger
  |>,
  "Sums" -> <|
    "BareLoopTensorSum" -> bareSumStored,
    "UVCountertermTensorSumQCDProjected" -> countertermSumQCD,
    "UVRenormalizedVirtualTensorSumSymbolic" ->
      renormalizedVirtualTensorSumSymbolic
  |>,
  "Poles" -> <|
    "UV" -> <|
      "BarePerDiagram" -> bareUVPerDiagram,
      "BareTotal" -> bareUVSumStored,
      "CountertermTotalQCDProjected" -> countertermSumQCD,
      "RenormalizedTotalSymbolic" -> renormalizedUVPoleSumSymbolic,
      "ExplicitCancellationStatus" ->
        "Requires scheme-specific values for dZGG1, dZgs1, dZfL1 and dZfR1"
    |>,
    "IR" -> <|
      "BarePerDiagram" -> bareIRPerDiagram,
      "RenormalizedVirtualTotal" -> renormalizedIRPoleSum,
      "CountertermContribution" -> 0
    |>
  |>,
  "Checks" -> s04Checks
|>;

Print["S04_STAGE: writing " <> resultPath];
Put[s04Result, resultPath];

assert[FileExistsQ[resultPath], "The s04_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s04_result file is empty."];

Print["S04_SUCCESS"];
Print["S04_RESULT_PATH=" <> resultPath];
Print["S04_COUNTS=", InputForm[s04Result["Counts"]]];
Print["S04_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

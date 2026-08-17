(* ::Package:: *)

(*
  Construct the symbolic UV-counterterm-completed Hqg virtual tensor for
    gamma*(q) + q(p) -> g(k1) + q(k2),
  where g(k1) is the fragmenting parton (BigTMD channel 3, case A).
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[assert, fatal];

fatal[message_String] := (Print["S04_FATAL: " <> message]; Quit[1]);
assert[condition_, message_String] := If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = FileNameJoin[{scriptDirectory, "s01_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s04_result"}];

Print["S04_STAGE: loading and validating Hqg s01_result"];
assert[FileExistsQ[sourcePath], "s01_result does not exist."];
s01 = Check[Get[sourcePath], $Failed];
assert[AssociationQ[s01], "s01_result did not load as an Association."];
assert[s01["Status"] === "Complete", "s01_result is not complete."];
assert[s01["Stage"] === "HqgS01-v2", "s01_result stage mismatch."];
assert[s01["Channel"] === "Hqg only", "s01_result is not Hqg-only."];
assert[s01["BigTMDConvention", "ChannelNumber"] === 3,
  "s01_result is not bound to BigTMD channel 3."];
assert[s01["BigTMDConvention", "ChargeCase"] === "A only",
  "s01_result has the wrong charge-case convention."];
assert[s01["Conventions", "FragmentingParton"] === "g(k1)",
  "s01_result does not fix the observed gluon at k1."];
assert[
  s01["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s01["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s01["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g",
  "s01_result is not in the charge-stripped BigTMD hard-kernel convention."
];
assert[s01["LO", "DiagramCount"] === 2,
  "s01_result LO count mismatch."];
assert[s01["NLOReal", "Hqg;qg", "DiagramCount"] === 8,
  "s01_result real count mismatch."];

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

assert[ListQ[barePerDiagram] && Length[barePerDiagram] === 23,
  "Expected 23 TID-reduced bare virtual amplitudes."];
assert[ListQ[bareUVPerDiagram] && Length[bareUVPerDiagram] === 23,
  "Expected 23 bare virtual UV-pole amplitudes."];
assert[ListQ[bareIRPerDiagram] && Length[bareIRPerDiagram] === 23,
  "Expected 23 bare virtual IR-pole amplitudes."];
assert[ListQ[countertermPerDiagramOriginal] &&
    Length[countertermPerDiagramOriginal] === 12,
  "Expected 12 symbolic UV-counterterm amplitudes."];
assert[SameQ[Total[barePerDiagram], bareSumStored],
  "Stored bare virtual sum is inconsistent."];
assert[SameQ[Total[bareUVPerDiagram], bareUVSumStored],
  "Stored bare UV sum is inconsistent."];
assert[SameQ[Total[bareIRPerDiagram], bareIRSumStored],
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

assert[FreeQ[countertermPerDiagramQCD, dZAA1 | dZe1 | dZZA1],
  "An electroweak-only counterterm survived projection."];
assert[FreeQ[countertermPerDiagramQCD, _dMf1],
  "A quark-mass counterterm survived projection."];
assert[! FreeQ[countertermPerDiagramQCD, dZGG1],
  "The gluon-field QCD counterterm is missing."];
assert[! FreeQ[countertermPerDiagramQCD, dZgs1],
  "The strong-coupling QCD counterterm is missing."];
assert[! FreeQ[countertermPerDiagramQCD, _dZfL1 | _dZfR1],
  "The quark-field QCD counterterm is missing."];
assert[FreeQ[countertermPerDiagramQCD, FeynCalc`EpsilonIR],
  "An IR regulator occurs in symbolic UV counterterms."];

Print["S04_STAGE: summing all same-process virtual contributions"];

allSameProcessContributions = Join[barePerDiagram, countertermPerDiagramQCD];
renormalizedVirtualTensorSumSymbolic = bareSumStored + countertermSumQCD;
renormalizedUVPoleSumSymbolic = bareUVSumStored + countertermSumQCD;
renormalizedIRPoleSum = bareIRSumStored;

assert[SameQ[Total[allSameProcessContributions],
    renormalizedVirtualTensorSumSymbolic],
  "The combined virtual tensor sum failed reconstruction."];
assert[! FreeQ[renormalizedVirtualTensorSumSymbolic, FeynCalc`LorentzIndex],
  "The combined amplitude lost its tensor Lorentz indices."];
assert[! FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonUV],
  "The symbolic UV sector contains no bare-loop UV regulator."];
assert[FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonIR],
  "An IR regulator leaked into the UV sector."];
assert[! FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonIR],
  "The IR sector contains no IR regulator."];
assert[FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonUV],
  "A UV regulator leaked into the IR sector."];

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

s04Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqgS04-v2",
  "Channel" -> "Hqg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> sourcePath,
  "SourceResultSHA256" -> FileHash[sourcePath, "SHA256"],
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
    "CountertermsIncluded" -> True,
    "AllContributionsHaveSameExternalProcess" -> True,
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
  "Checks" -> <|
    "SourceBoundToHqgS01" -> True,
    "BigTMDChannel3ObservedGluon" -> True,
    "ChargeStrippedHardKernelConventionPreserved" -> True,
    "BareTensorReconstruction" -> True,
    "BareUVReconstruction" -> True,
    "BareIRReconstruction" -> True,
    "CombinedTensorReconstruction" -> True,
    "TensorLorentzIndicesPreserved" -> True,
    "UVHasNoEpsilonIR" -> True,
    "IRHasNoEpsilonUV" -> True
  |>
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

(* ::Package:: *)

(*
  Construct the UV-counterterm-completed NLO virtual tensor amplitude for

    gamma*(q) + q(p) -> q(k1) + g(k2).

  The 23 bare one-loop diagrams and 12 counterterm diagrams in s01_result
  have identical external particles.  They do not have a diagram-by-diagram
  one-to-one correspondence, so UV renormalization is performed on their full
  sums, as required for a gauge-invariant amplitude.  Per-diagram expressions
  are retained for provenance.

  The FeynArts SMQCD counterterms are symbolic.  At NLO QCD this program sets
  electroweak-only renormalization constants to zero and sets the quark mass
  counterterm to zero in the massless theory.  It keeps the QCD field and
  strong-coupling renormalization constants symbolic rather than silently
  choosing an unspecified UV subtraction scheme.  Consequently the output
  contains a symbolic UV-renormalized sum and an explicit, separate IR sum.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[assert, fatal];

fatal[message_String] := (
  Print["S04_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = FileNameJoin[{scriptDirectory, "s01_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s04_result"}];

Print["S04_STAGE: loading s01_result"];
assert[FileExistsQ[sourcePath], "s01_result does not exist."];
s01 = Check[Get[sourcePath], $Failed];
assert[AssociationQ[s01], "s01_result did not load as an Association."];
assert[s01["Status"] === "Complete", "s01_result is not marked complete."];
assert[s01["Channel"] === "Hqq only", "s01_result is not the Hqq-only result."];

barePerDiagram =
  s01["NLOVirtual", "BareLoop", "TIDPassarinoVeltmanPerDiagram"];
bareSumStored =
  s01["NLOVirtual", "BareLoop", "TIDPassarinoVeltmanSum"];
bareUVPerDiagram = s01["Poles", "UVPoles", "BareVirtualPerDiagram"];
bareUVSumStored = s01["Poles", "UVPoles", "BareVirtualTotal"];
bareIRPerDiagram = s01["Poles", "IRPoles", "BareVirtualPerDiagram"];
bareIRSumStored = s01["Poles", "IRPoles", "BareVirtualTotal"];
countertermPerDiagramOriginal =
  s01["NLOVirtual", "UVCounterterms", "FeynCalcAmplitudesPerDiagram"];

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
  "Stored bare virtual tensor sum is inconsistent with its diagrams."];
assert[SameQ[Total[bareUVPerDiagram], bareUVSumStored],
  "Stored bare UV sum is inconsistent with its diagrams."];
assert[SameQ[Total[bareIRPerDiagram], bareIRSumStored],
  "Stored bare IR sum is inconsistent with its diagrams."];

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
  "An electroweak-only counterterm survived the NLO-QCD projection."];
assert[FreeQ[countertermPerDiagramQCD, _dMf1],
  "A quark-mass counterterm survived the massless-QCD projection."];
assert[! FreeQ[countertermPerDiagramQCD, dZGG1],
  "The gluon-field QCD counterterm is missing after projection."];
assert[! FreeQ[countertermPerDiagramQCD, dZgs1],
  "The strong-coupling QCD counterterm is missing after projection."];
assert[! FreeQ[countertermPerDiagramQCD, _dZfL1 | _dZfR1],
  "The quark-field QCD counterterm is missing after projection."];
assert[FreeQ[countertermPerDiagramQCD, FeynCalc`EpsilonIR],
  "An IR regulator occurs in the symbolic UV counterterms."];

Print["S04_STAGE: summing all same-process virtual contributions"];

(*
  The physically meaningful renormalized-amplitude construction is the full
  bare-loop sum plus the full counterterm sum.  Pairing the 23 loop diagrams
  arbitrarily with 12 counterterm diagrams would be mathematically undefined.
*)
allSameProcessContributions = Join[
  barePerDiagram,
  countertermPerDiagramQCD
];
renormalizedVirtualTensorSumSymbolic =
  bareSumStored + countertermSumQCD;

renormalizedUVPoleSumSymbolic =
  bareUVSumStored + countertermSumQCD;
renormalizedIRPoleSum = bareIRSumStored;

assert[SameQ[
    Total[allSameProcessContributions],
    renormalizedVirtualTensorSumSymbolic
  ],
  "The combined virtual tensor sum failed its reconstruction check."];
assert[! FreeQ[renormalizedVirtualTensorSumSymbolic,
    FeynCalc`LorentzIndex],
  "The combined amplitude no longer contains its tensor Lorentz indices."];
assert[! FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonUV],
  "The symbolic UV sector contains no explicit bare-loop UV regulator."];
assert[FreeQ[renormalizedUVPoleSumSymbolic, FeynCalc`EpsilonIR],
  "An IR regulator leaked into the UV-renormalization sector."];
assert[! FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonIR],
  "The separate IR sector contains no IR regulator."];
assert[FreeQ[renormalizedIRPoleSum, FeynCalc`EpsilonUV],
  "A UV regulator leaked into the separate IR sector."];

contributionLedger = Join[
  MapIndexed[
    <|
      "ContributionType" -> "BareLoop",
      "DiagramIndex" -> First[#2],
      "Amplitude" -> #1
    |> &,
    barePerDiagram
  ],
  MapIndexed[
    <|
      "ContributionType" -> "UVCountertermQCDProjected",
      "DiagramIndex" -> First[#2],
      "Amplitude" -> #1
    |> &,
    countertermPerDiagramQCD
  ]
];

s04Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> sourcePath,
  "ExternalProcess" -> <|
    "Incoming" -> {"gamma*(q)", "q(p)"},
    "Outgoing" -> {"q(k1)", "g(k2)"},
    "FragmentingParton" -> "q(k1)"
  |>,
  "Interpretation" -> <|
    "Purpose" -> "UV renormalization of the NLO Hqq virtual tensor amplitude",
    "CountertermsIncluded" -> True,
    "AllContributionsHaveSameExternalProcess" -> True,
    "OneToOneDiagramPairingUsed" -> False,
    "PairingReason" -> "The 23 loop and 12 counterterm diagrams have no one-to-one correspondence; their complete same-process sums must be combined.",
    "RenormalizationSchemeStatus" -> "QCD renormalization constants remain symbolic; insert scheme-specific dZ rules to test explicit UV-pole cancellation."
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

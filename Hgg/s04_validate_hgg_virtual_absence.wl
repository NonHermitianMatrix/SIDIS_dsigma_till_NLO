(* ::Package:: *)

(*
  Hgg has no two-body Born or one-loop virtual contribution at
  O(alpha_s^2).  Its first nonzero contribution at this order is the real

    gamma*(q) + g(p) -> g(k1) + q(k2) + qbar(k3).

  The Hqq S04 UV-renormalization algebra is therefore not applicable.  This
  stage makes that absence explicit and machine-checkable so later Hgg stages
  cannot silently import an Hqq virtual amplitude or UV counterterm.
*)

$HistoryLength = 0;

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

Print["S04_STAGE: loading and validating the Hgg S01 result"];
assert[FileExistsQ[sourcePath], "s01_result does not exist."];
s01 = Check[Get[sourcePath], $Failed];
assert[AssociationQ[s01], "s01_result did not load as an Association."];
assert[s01["Status"] === "Complete", "s01_result is not marked complete."];
assert[s01["Channel"] === "Hgg only", "s01_result is not Hgg-only."];
assert[
  s01["Contribution"] === "Hgg;q qbar",
  "s01_result is not the expected Hgg;q qbar contribution."
];

Print["S04_STAGE: checking that virtual renormalization is inapplicable"];
assert[! KeyExistsQ[s01, "LO"], "An unexpected Hgg LO payload is present."];
assert[
  ! KeyExistsQ[s01, "NLOVirtual"],
  "An unexpected Hgg virtual payload is present."
];
assert[
  ! KeyExistsQ[s01, "Poles"],
  "Unexpected loop-pole data are present in the Hgg S01 result."
];
assert[
  MemberQ[
    s01["AbsentAtThisOrder"],
    "Hgg two-body Born hard part"
  ],
  "S01 does not explicitly record the absence of the Hgg two-body Born part."
];
assert[
  MemberQ[
    s01["AbsentAtThisOrder"],
    "Hgg one-loop virtual hard part"
  ],
  "S01 does not explicitly record the absence of the Hgg virtual part."
];
assert[
  MemberQ[
    s01["AbsentAtThisOrder"],
    "UV counterterm amplitudes"
  ],
  "S01 does not explicitly record the absence of UV counterterms."
];

hggReal = s01["NLOReal", "Hgg;q_qbar"];
hggDiagramCount = hggReal["DiagramCount"];

assert[AssociationQ[hggReal], "The Hgg real payload is not an Association."];
assert[
  hggDiagramCount === 8,
  "The validated Hgg real payload does not contain eight diagrams."
];
assert[
  Length[hggReal["FeynCalcAmplitudesPerDiagram"]] === hggDiagramCount,
  "The Hgg real amplitude list does not match its diagram count."
];
assert[
  Total[hggReal["FeynCalcAmplitudesPerDiagram"]] ===
    hggReal["FeynCalcAmplitudeSum"],
  "The stored Hgg real amplitude sum does not reconstruct exactly."
];
assert[
  AllTrue[Values[s01["ValidationChecks"]], TrueQ],
  "At least one validated S01 input check is not true."
];

sourceSHA256 = FileHash[sourcePath, "SHA256"];

s04Result = <|
  "Status" -> "Complete",
  "StageDisposition" -> "NotApplicableAtThisOrder",
  "Channel" -> "Hgg only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> sourcePath,
  "SourceResultSHA256" -> sourceSHA256,
  "ReferencePDF" -> s01["ReferencePDF"],
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "ExternalRealProcess" -> <|
    "Incoming" -> {"gamma*(q)", "g(p)"},
    "Outgoing" -> {"g(k1)", "q(k2)", "qbar(k3)"},
    "FragmentingParton" -> "g(k1)",
    "DiagramCount" -> hggDiagramCount
  |>,
  "VirtualRenormalization" -> <|
    "Applicable" -> False,
    "TwoBodyBornContribution" -> 0,
    "OneLoopVirtualContributionAtThisOrder" -> 0,
    "UVCountertermContributionAtThisOrder" -> 0,
    "Reason" ->
      "Paper Table I gives Hgg at O(alpha_s^2) only through the tree real Hgg;q qbar process; there is no same-order Hgg two-body Born or virtual partner."
  |>,
  "ReuseFromHqqS04" -> <|
    "Reused" -> {
      "fatal/assert control flow",
      "complete source-association gate",
      "self-describing result and provenance pattern",
      "exact reconstruction checks"
    },
    "NotReused" -> {
      "bare one-loop amplitudes",
      "UV/IR pole collections",
      "QCD renormalization constants",
      "UV counterterm projection and virtual sums"
    }
  |>,
  "Checks" -> <|
    "CompleteHggSource" -> True,
    "EightRealDiagramsPresent" -> True,
    "RealAmplitudeSumReconstructs" -> True,
    "NoTwoBodyBornPayload" -> True,
    "NoVirtualPayload" -> True,
    "NoLoopPolePayload" -> True,
    "NoUVCountertermPayload" -> True,
    "AllS01ValidationChecksTrue" -> True
  |>,
  "DownstreamInstruction" ->
    "Hgg S05 must construct only the real Hgg;q qbar bilinear from s01_result; it must not seek a virtual amplitude in s04_result."
|>;

Print["S04_STAGE: writing explicit Hgg not-applicable result"];
Put[s04Result, resultPath];

assert[FileExistsQ[resultPath], "The s04_result file was not created."];
assert[FileByteCount[resultPath] > 0, "The s04_result file is empty."];

Print["S04_SUCCESS"];
Print["S04_RESULT_PATH=" <> resultPath];
Print["S04_STAGE_DISPOSITION=NotApplicableAtThisOrder"];
Print["S04_REAL_DIAGRAM_COUNT=", hggDiagramCount];
Print["S04_RESULT_BYTES=", FileByteCount[resultPath]];

Quit[0];

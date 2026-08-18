(* ::Package:: *)

(*
  Render the single validated Hqqbar S01 FeynArts diagram set as native
  PostScript. This stage is visualization/provenance only and performs no
  physics algebra. PDF assembly is deliberately left to a later S03.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fail, require, fileSHA256, atomicPut, atomicWritePostScript,
  regeneratedAmplitudeCount
];

fail[text_String] := (
  Print["S02_FATAL: " <> text];
  Quit[1]
);

require[test_, text_String] :=
  If[! TrueQ[test], fail[text]];

fileSHA256[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

atomicPut[expression_, finalPath_String] := Module[
  {temporaryPath, writeResult, loaded, renameResult},
  temporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], Quiet[DeleteFile[temporaryPath]]];

  writeResult = Quiet@Check[Put[expression, temporaryPath], $Failed];
  require[writeResult =!= $Failed, "Atomic temporary result write failed."];
  require[FileExistsQ[temporaryPath], "Atomic temporary result is missing."];
  require[FileByteCount[temporaryPath] > 0, "Atomic temporary result is empty."];

  loaded = Quiet@Check[Get[temporaryPath], $Failed];
  require[AssociationQ[loaded], "Atomic temporary result failed reload validation."];
  require[loaded["Status"] === "Complete", "Atomic temporary result status is invalid."];

  renameResult = Quiet@Check[
    RenameFile[temporaryPath, finalPath, OverwriteTarget -> True],
    $Failed
  ];
  require[renameResult =!= $Failed, "Atomic result rename failed."];
  require[FileExistsQ[finalPath], "Final result is missing after atomic rename."];
  require[FileByteCount[finalPath] > 0, "Final result is empty after atomic rename."];
];

atomicWritePostScript[path_String, content_String] := Module[
  {temporaryPath, stream, closeResult, renameResult},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], Quiet[DeleteFile[temporaryPath]]];

  stream = Quiet@Check[
    OpenWrite[temporaryPath, CharacterEncoding -> "ISO8859-1"],
    $Failed
  ];
  require[Head[stream] === OutputStream, "Could not open temporary PostScript file."];
  WriteString[stream, content];
  closeResult = Quiet@Check[Close[stream], $Failed];
  require[closeResult =!= $Failed, "Could not close temporary PostScript file."];
  require[FileExistsQ[temporaryPath], "Temporary PostScript file is missing."];
  require[FileByteCount[temporaryPath] > 0, "Temporary PostScript file is empty."];

  renameResult = Quiet@Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    $Failed
  ];
  require[renameResult =!= $Failed, "Atomic PostScript rename failed."];
  require[FileExistsQ[path], "Final PostScript file is missing."];
  require[FileByteCount[path] > 0, "Final PostScript file is empty."];
];

regeneratedAmplitudeCount[diagrams_] := Module[{amplitudes},
  amplitudes = Quiet@Check[
    FeynArts`CreateFeynAmp[diagrams, FeynArts`Truncated -> True],
    $Failed
  ];
  require[
    amplitudes =!= $Failed,
    "Could not regenerate amplitudes from the stored diagram set."
  ];
  Length[List @@ amplitudes]
];

workingDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{
  workingDirectory, "s01_calculate_hqqbar_real.wl"
}];
s01ResultPath = FileNameJoin[{workingDirectory, "s01_result"}];
s02ResultPath = FileNameJoin[{workingDirectory, "s02_result"}];
postScriptDirectory = FileNameJoin[{
  workingDirectory, ".s02_ghostscript", "pages"
}];

expectedS01SourceHash =
  "750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71";
expectedS01ResultHash =
  "69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4";

require[FileExistsQ[s01SourcePath], "Validated S01 source is missing."];
require[FileExistsQ[s01ResultPath], "Validated s01_result is missing."];
require[
  fileSHA256[s01SourcePath] === expectedS01SourceHash,
  "S01 source hash does not match the validated handoff hash."
];
require[
  fileSHA256[s01ResultPath] === expectedS01ResultHash,
  "s01_result hash does not match the validated handoff hash."
];

s01Result = Quiet@Check[Get[s01ResultPath], $Failed];
require[AssociationQ[s01Result], "s01_result did not load as an Association."];
require[s01Result["Status"] === "Complete", "s01_result is not complete."];
require[s01Result["Stage"] === "HqqbarS01-v1", "s01_result stage mismatch."];
require[s01Result["Channel"] === "Hqqbar only", "s01_result is not Hqqbar-only."];
require[
  s01Result["Contribution"] === "H_{q qbar; q q}",
  "s01_result contribution mismatch."
];
require[
  s01Result["ProgramSHA256"] === expectedS01SourceHash,
  "s01_result does not bind the validated S01 source hash."
];
require[
  AssociationQ[s01Result["Checks"]] &&
    And @@ (TrueQ /@ Values[s01Result["Checks"]]),
  "s01_result contains a failed or malformed check ledger."
];
require[
  s01Result["BigTMDConvention"]["ChannelNumber"] === 5,
  "s01_result is not bound to BigTMD channel 5."
];
require[
  StringStartsQ[s01Result["BigTMDConvention"]["ChargeCase"], "A only"],
  "s01_result has the wrong BigTMD charge-case convention."
];
require[
  ! KeyExistsQ[s01Result, "LO"] && ! KeyExistsQ[s01Result, "NLOVirtual"],
  "s01_result unexpectedly contains an Hqqbar LO or virtual payload."
];

realPayload = s01Result["NLOReal"]["Hqqbar;q_q"];
diagramCount = realPayload["DiagramCount"];
diagrams = realPayload["FeynArtsDiagrams"];

require[diagramCount === 8, "The S01 Hqqbar diagram count is not eight."];
require[
  s01Result["DiagramCounts"]["NLOReal_gammaStar_q_to_qbar_q_q"] ===
    diagramCount,
  "The two stored Hqqbar diagram counts disagree."
];
require[
  MatchQ[Head[diagrams], _FeynArts`TopologyList],
  "The stored diagram set is not a parametrized FeynArts TopologyList."
];
require[
  Length[diagrams] === diagramCount,
  "The stored TopologyList length does not equal the diagram count."
];
require[
  regeneratedAmplitudeCount[diagrams] === diagramCount,
  "Regenerated amplitude count does not equal the stored diagram count."
];

columnsAndRows = {3, 3};
diagramsPerPhysicalPage = Times @@ columnsAndRows;
expectedSetCount = 1;
expectedPhysicalPageCount = Ceiling[diagramCount/diagramsPerPhysicalPage];
require[expectedPhysicalPageCount === 1, "Hqqbar S02 should occupy one physical page."];

Print["S02_STAGE: painting the validated eight-diagram Hqqbar set"];
painted = Reap[
  FeynArts`Paint[
    diagrams,
    FeynArts`ColumnsXRows -> columnsAndRows,
    FeynArts`Numbering -> FeynArts`Simple,
    FeynArts`SheetHeader ->
      "NLO real Hqqbar;q q: gamma* q -> qbar(fragmenting) q q",
    ImageSize -> 900,
    DisplayFunction -> Function[page, Sow[page, "S02Pages"]; Null]
  ],
  "S02Pages"
];

require[
  Length[painted[[2]]] === 1,
  "FeynArts Paint produced no page collection."
];
pages = painted[[2, 1]];
require[
  Length[pages] === expectedSetCount,
  "FeynArts Paint did not produce exactly one diagram-set page object."
];
require[
  And @@ (MatchQ[Head[#], _FeynArts`FeynArtsGraphics] & /@ pages),
  "A painted page is not a parametrized FeynArtsGraphics object."
];

Print["S02_STAGE: rendering one native PostScript diagram set"];
postScriptSheets = Flatten[FeynArts`Render[#, "PS"] & /@ pages];
require[
  Length[postScriptSheets] === expectedSetCount,
  "Rendered PostScript set count is not one."
];
require[
  And @@ (StringQ /@ postScriptSheets),
  "A rendered PostScript set is not a string."
];
require[
  And @@ (StringStartsQ[#, "%!PS-Adobe"] & /@ postScriptSheets),
  "A rendered set lacks a PostScript header."
];
postScriptPageCounts = StringCount[#, "%%Page:"] & /@ postScriptSheets;
require[
  postScriptPageCounts === {expectedPhysicalPageCount},
  "PostScript physical-page marker count is not one."
];

If[
  ! DirectoryQ[postScriptDirectory],
  CreateDirectory[
    postScriptDirectory,
    CreateIntermediateDirectories -> True
  ]
];

stalePostScriptPaths = Join[
  FileNames["s02_set_*.ps", postScriptDirectory],
  FileNames["s02_page_*.ps", postScriptDirectory]
];
If[stalePostScriptPaths =!= {}, Scan[DeleteFile, stalePostScriptPaths]];

postScriptPaths = {
  FileNameJoin[{postScriptDirectory, "s02_set_001.ps"}]
};
MapThread[
  atomicWritePostScript,
  {postScriptPaths, postScriptSheets}
];

require[
  Sort@Join[
    FileNames["s02_set_*.ps", postScriptDirectory],
    FileNames["s02_page_*.ps", postScriptDirectory]
  ] === Sort[postScriptPaths],
  "The PostScript directory contains a stale, missing, or extra S02 file."
];
require[
  And @@ (FileExistsQ /@ postScriptPaths),
  "The expected PostScript output is missing."
];
require[
  And @@ ((FileByteCount[#] > 0) & /@ postScriptPaths),
  "The PostScript output is empty."
];

programHash = fileSHA256[programPath];
postScriptBytes = AssociationThread[
  postScriptPaths,
  FileByteCount /@ postScriptPaths
];
postScriptHashes = AssociationThread[
  postScriptPaths,
  fileSHA256 /@ postScriptPaths
];

checks = <|
  "ValidatedS01SourceHash" -> True,
  "ValidatedS01ResultHash" -> True,
  "S01CheckLedgerAllTrue" -> True,
  "PaperTableIRealOnlyPayload" -> True,
  "BigTMDChannel5CaseA" -> True,
  "SingleHqqbarDiagramSetOnly" -> True,
  "ExactStoredDiagramCountEight" -> True,
  "RegeneratedAmplitudeCountEight" -> True,
  "ParametrizedTopologyListAccepted" -> True,
  "ParametrizedFeynArtsGraphicsAccepted" -> True,
  "ThreeByThreeLayout" -> True,
  "OneDiagramSetObject" -> True,
  "OnePhysicalPostScriptPage" -> True,
  "PostScriptHeaderAndPageMarkersValid" -> True,
  "AtomicPostScriptWrite" -> True,
  "NoStaleOrExtraPostScriptFiles" -> True,
  "VisualizationOnlyNoPhysicsAlgebra" -> True,
  "AtomicS02ResultWrite" -> True
|>;

s02Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqbarS02-v1",
  "ResultSchemaVersion" -> 1,
  "Channel" -> "Hqqbar only",
  "Purpose" -> "FeynArts diagram visualization/provenance only",
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Input" -> <|
    "S01SourcePath" -> s01SourcePath,
    "S01SourceSHA256" -> fileSHA256[s01SourcePath],
    "S01ResultPath" -> s01ResultPath,
    "S01ResultSHA256" -> fileSHA256[s01ResultPath],
    "S01Stage" -> s01Result["Stage"],
    "BigTMDChannel" -> s01Result["BigTMDConvention"]["ChannelNumber"],
    "BigTMDChargeCase" -> s01Result["BigTMDConvention"]["ChargeCase"]
  |>,
  "DiagramSets" -> <|
    "Hqqbar;q_q" -> <|
      "Label" ->
        "NLO real Hqqbar;q q: gamma* q -> qbar(fragmenting) q q",
      "DiagramCount" -> diagramCount,
      "RegeneratedAmplitudeCount" -> regeneratedAmplitudeCount[diagrams]
    |>
  |>,
  "Layout" -> <|
    "ColumnsXRows" -> columnsAndRows,
    "DiagramsPerPhysicalPage" -> diagramsPerPhysicalPage,
    "DiagramSetObjectCount" -> Length[pages],
    "PhysicalPageCount" -> Total[postScriptPageCounts]
  |>,
  "PostScript" -> <|
    "Directory" -> postScriptDirectory,
    "Paths" -> postScriptPaths,
    "Bytes" -> postScriptBytes,
    "SHA256" -> postScriptHashes,
    "PhysicalPageCounts" -> AssociationThread[
      postScriptPaths,
      postScriptPageCounts
    ]
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "amplitude or squared-matrix-element algebra",
    "spin/color sums or identical-particle factors",
    "phase-space integration or factorization",
    "projector contraction or F-hat inversion",
    "PDF assembly or BigTMD numerical comparison"
  }
|>;

require[
  And @@ (TrueQ /@ Values[checks]),
  "At least one S02 check is not True."
];

Print["S02_STAGE: atomically writing " <> s02ResultPath];
atomicPut[s02Result, s02ResultPath];

reloadedResult = Quiet@Check[Get[s02ResultPath], $Failed];
require[AssociationQ[reloadedResult], "Final s02_result failed reload validation."];
require[reloadedResult["Status"] === "Complete", "Reloaded S02 status is invalid."];
require[reloadedResult["Stage"] === "HqqbarS02-v1", "Reloaded S02 stage is invalid."];
require[
  reloadedResult["ProgramSHA256"] === programHash,
  "Reloaded S02 program hash is invalid."
];
require[
  reloadedResult["Input"]["S01SourceSHA256"] === expectedS01SourceHash &&
    reloadedResult["Input"]["S01ResultSHA256"] === expectedS01ResultHash,
  "Reloaded S02 upstream hashes are invalid."
];
require[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "Reloaded S02 contains a failed check."
];

Print["S02_SUCCESS"];
Print["S02_PROGRAM_SHA256=" <> programHash];
Print["S02_RESULT_PATH=" <> s02ResultPath];
Print["S02_RESULT_SHA256=" <> fileSHA256[s02ResultPath]];
Print["S02_DIAGRAM_COUNT=", diagramCount];
Print["S02_POSTSCRIPT_PATH=" <> First[postScriptPaths]];
Print["S02_POSTSCRIPT_BYTES=", First[Values[postScriptBytes]]];
Print["S02_POSTSCRIPT_SHA256=" <> First[Values[postScriptHashes]]];
Print["S02_PHYSICAL_PAGE_COUNT=", Total[postScriptPageCounts]];

Quit[0];

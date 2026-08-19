(* ::Package:: *)

(* Export every accepted Hqqprime S01 representative diagram set as native
   PostScript and record a hash-bound S02 provenance manifest. *)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  cleanupTemporaryArtifacts, fail, require, sha256, regenerateCount,
  validateRepresentative, paintRepresentative, renderPage,
  writePostScriptSheet
];

workingDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{
  workingDirectory, "s01_calculate_hqqprime_tree.wl"
}];
s01ResultPath = FileNameJoin[{workingDirectory, "s01_result"}];
s02ResultPath = FileNameJoin[{workingDirectory, "s02_result"}];
postScriptRoot = FileNameJoin[{workingDirectory, ".s02_ghostscript"}];
finalPagesDirectory = FileNameJoin[{postScriptRoot, "pages"}];
temporaryPagesDirectory = FileNameJoin[{
  postScriptRoot, "pages.tmp." <> ToString[$ProcessID]
}];
temporaryResultPath = s02ResultPath <> ".tmp." <> ToString[$ProcessID];

expectedS01SourceSHA256 =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultSHA256 =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";

publicationOwnsFinalPages = False;
publicationOwnsFinalResult = False;

cleanupTemporaryArtifacts[] := Module[{},
  If[FileExistsQ[temporaryResultPath], DeleteFile[temporaryResultPath]];
  If[DirectoryQ[temporaryPagesDirectory],
    DeleteDirectory[temporaryPagesDirectory, DeleteContents -> True]
  ];
  If[TrueQ[publicationOwnsFinalResult] && FileExistsQ[s02ResultPath],
    DeleteFile[s02ResultPath]
  ];
  If[TrueQ[publicationOwnsFinalPages] && DirectoryQ[finalPagesDirectory],
    DeleteDirectory[finalPagesDirectory, DeleteContents -> True]
  ];
];

fail[text_String] := Module[{},
  cleanupTemporaryArtifacts[];
  Print["S02_FATAL: " <> text];
  Quit[1]
];
require[test_, text_String] := If[! TrueQ[test], fail[text]];
sha256[path_String] := IntegerString[FileHash[path, "SHA256"], 16, 64];

require[FileExistsQ[programPath], "S02 source path does not exist."];
require[FileExistsQ[s01SourcePath], "Accepted S01 source does not exist."];
require[FileExistsQ[s01ResultPath], "Accepted s01_result does not exist."];
require[! FileExistsQ[s02ResultPath],
  "s02_result already exists; refusing to overwrite it."];
require[! DirectoryQ[finalPagesDirectory],
  "Final S02 page directory already exists; refusing to overwrite it."];
require[! FileExistsQ[temporaryResultPath],
  "A stale process-specific temporary S02 result exists."];
require[! DirectoryQ[temporaryPagesDirectory],
  "A stale process-specific temporary S02 page directory exists."];

programSHA256 = sha256[programPath];
s01SourceSHA256 = sha256[s01SourcePath];
s01ResultSHA256 = sha256[s01ResultPath];
require[s01SourceSHA256 === expectedS01SourceSHA256,
  "S01 source hash differs from the accepted channel ledger."];
require[s01ResultSHA256 === expectedS01ResultSHA256,
  "s01_result hash differs from the accepted channel ledger."];

s01Result = Quiet @ Check[Get[s01ResultPath], $Failed];
require[AssociationQ[s01Result], "s01_result did not load as an Association."];
require[s01Result["Status"] === "Complete",
  "s01_result is not marked complete."];
require[s01Result["Stage"] === "HqqprimeS01-v1",
  "s01_result stage identity is wrong."];
require[s01Result["Channel"] === "Hqqprime only",
  "s01_result channel identity is wrong."];
require[s01Result["ProgramSHA256"] === s01SourceSHA256,
  "s01_result does not bind the current accepted S01 source."];
require[AssociationQ[s01Result["Checks"]] &&
    And @@ Values[s01Result["Checks"]],
  "At least one saved S01 acceptance check is false."];

representativeOrder = {"up_up", "up_down", "down_up"};
require[Sort[Keys[s01Result["Representatives"]]] ===
    Sort[representativeOrder],
  "The saved S01 representative set is incomplete or unexpected."];

regenerateCount[diagrams_] := Module[{amplitudes},
  amplitudes = Quiet @ Check[
    FeynArts`CreateFeynAmp[diagrams, FeynArts`Truncated -> True],
    $Failed
  ];
  require[amplitudes =!= $Failed,
    "Could not regenerate amplitudes from a stored diagram set."];
  Length[List @@ amplitudes]
];

validateRepresentative[label_String] := Module[
  {entry, diagrams, savedCount, regeneratedCount, chargeAssignment},
  entry = s01Result["Representatives", label];
  require[AssociationQ[entry], label <> " entry is not an Association."];
  require[entry["Label"] === label, label <> " label mismatch."];
  require[entry["IncomingField"] =!= entry["PrimeField"],
    label <> " does not contain different incoming and fragmenting flavors."];
  require[
    entry["OutgoingFields"] === {
      entry["PrimeField"], entry["IncomingField"], -entry["PrimeField"]
    },
    label <> " outgoing field order is wrong."
  ];
  require[entry["IncomingMomenta"] === {q, p},
    label <> " incoming momentum order is wrong."];
  require[entry["OutgoingMomenta"] === {k1, k2, k3},
    label <> " outgoing momentum order is wrong."];

  diagrams = entry["SelectedDiagrams"];
  savedCount = entry["SelectedDiagramCount"];
  require[IntegerQ[savedCount] && savedCount > 0,
    label <> " saved selected count is not a positive integer."];
  require[
    MatchQ[Head[diagrams], _FeynArts`TopologyList],
    label <> " selected diagrams are not a FeynArts TopologyList."
  ];
  require[savedCount === Length[entry["SelectedDiagramNumbers"]],
    label <> " selected-number length differs from its saved count."];
  regeneratedCount = regenerateCount[diagrams];
  require[regeneratedCount === savedCount,
    label <> " regenerated-amplitude count differs from its saved count."];

  chargeAssignment = s01Result["RepresentativeChargeAssignments", label];
  require[AssociationQ[chargeAssignment],
    label <> " charge assignment is missing."];

  <|
    "Label" -> label,
    "Diagrams" -> diagrams,
    "SavedDiagramCount" -> savedCount,
    "RegeneratedAmplitudeCount" -> regeneratedCount,
    "IncomingField" -> entry["IncomingField"],
    "PrimeField" -> entry["PrimeField"],
    "OutgoingFields" -> entry["OutgoingFields"],
    "IncomingMomenta" -> entry["IncomingMomenta"],
    "OutgoingMomenta" -> entry["OutgoingMomenta"],
    "ChargeAssignment" -> chargeAssignment
  |>
];

Print["S02_STAGE: validating accepted S01 representative diagram sets"];
validatedRepresentatives = AssociationMap[
  validateRepresentative,
  representativeOrder
];

savedDiagramCounts = AssociationMap[
  validatedRepresentatives[#, "SavedDiagramCount"] &,
  representativeOrder
];
regeneratedAmplitudeCounts = AssociationMap[
  validatedRepresentatives[#, "RegeneratedAmplitudeCount"] &,
  representativeOrder
];
require[savedDiagramCounts === s01Result["MeasuredSelectedDiagramCounts"],
  "Validated diagram counts differ from the S01 measured-count ledger."];
require[savedDiagramCounts === regeneratedAmplitudeCounts,
  "At least one regenerated amplitude count differs from S01."];

paintRepresentative[label_String] := Module[{harvest, pages},
  harvest = Quiet @ Check[
    Reap[
      FeynArts`Paint[
        validatedRepresentatives[label, "Diagrams"],
        FeynArts`ColumnsXRows -> {2, 2},
        FeynArts`Numbering -> FeynArts`Simple,
        FeynArts`SheetHeader ->
          ("HqqPrime " <> label <>
            ": gamma* q -> qPrime q qbarPrime"),
        ImageSize -> 900,
        DisplayFunction -> Function[
          page,
          Sow[page, "S02Pages"];
          Null
        ]
      ],
      "S02Pages"
    ],
    $Failed
  ];
  require[harvest =!= $Failed,
    label <> " FeynArts Paint failed."];
  require[Length[harvest[[2]]] === 1,
    label <> " FeynArts Paint produced no page collection."];
  pages = harvest[[2, 1]];
  require[Length[pages] > 0,
    label <> " FeynArts Paint produced zero pages."];
  require[And @@ (MatchQ[Head[#], _FeynArts`FeynArtsGraphics] & /@ pages),
    label <> " contains a painted object that is not FeynArtsGraphics."];
  MapIndexed[
    <|
      "Representative" -> label,
      "RepresentativePageIndex" -> First[#2],
      "Graphic" -> #1
    |> &,
    pages
  ]
];

Print["S02_STAGE: painting all accepted Hqqprime representative diagrams"];
pageRecords = Flatten[paintRepresentative /@ representativeOrder];
require[Length[pageRecords] > 0, "No Hqqprime pages were painted."];

paintedPageCounts = AssociationMap[
  Count[pageRecords[[All, "Representative"]], #] &,
  representativeOrder
];
require[And @@ (# > 0 & /@ Values[paintedPageCounts]),
  "At least one representative produced no painted page."];

renderPage[record_Association] := Module[{rendered},
  rendered = Quiet @ Check[
    Flatten @ {FeynArts`Render[record["Graphic"], "PS"]},
    $Failed
  ];
  require[rendered =!= $Failed,
    record["Representative"] <> " PostScript rendering failed."];
  require[Length[rendered] === 1,
    record["Representative"] <>
      " painted page did not render to exactly one PostScript sheet."];
  require[StringQ[First[rendered]] && StringLength[First[rendered]] > 0,
    record["Representative"] <> " rendered an empty non-string sheet."];
  require[StringStartsQ[First[rendered], "%!PS-Adobe"],
    record["Representative"] <> " rendered sheet lacks a PostScript header."];
  Append[KeyDrop[record, "Graphic"], "PostScript" -> First[rendered]]
];

Print["S02_STAGE: rendering native PostScript sheets"];
renderedRecords = renderPage /@ pageRecords;
require[Length[renderedRecords] === Length[pageRecords],
  "Rendered-sheet count differs from painted-page count."];

If[! DirectoryQ[postScriptRoot],
  CreateDirectory[postScriptRoot, CreateIntermediateDirectories -> True]
];
CreateDirectory[temporaryPagesDirectory];

temporaryPagePaths = MapIndexed[
  FileNameJoin[{
    temporaryPagesDirectory,
    "s02_page_" <> IntegerString[First[#2], 10, 3] <> ".ps"
  }] &,
  renderedRecords
];

writePostScriptSheet[path_String, content_String] := Module[{stream},
  stream = Quiet @ Check[
    OpenWrite[path, CharacterEncoding -> "ISO8859-1"],
    $Failed
  ];
  require[Head[stream] === OutputStream,
    "Could not open a temporary PostScript output file."];
  WriteString[stream, content];
  Close[stream]
];

MapThread[
  writePostScriptSheet[#1, #2["PostScript"]] &,
  {temporaryPagePaths, renderedRecords}
];
require[And @@ (FileExistsQ /@ temporaryPagePaths),
  "At least one temporary PostScript sheet was not written."];
require[And @@ (FileByteCount[#] > 0 & /@ temporaryPagePaths),
  "At least one temporary PostScript sheet is empty."];
require[
  And @@ (StringStartsQ[Import[#, "Text"], "%!PS-Adobe"] & /@
      temporaryPagePaths),
  "At least one written sheet lacks a PostScript header."
];
require[
  Sort[FileNames["s02_page_*.ps", temporaryPagesDirectory]] ===
    Sort[temporaryPagePaths],
  "Temporary page directory contains a stale or missing S02 page."
];

finalPagePaths = FileNameJoin[{
      finalPagesDirectory, FileNameTake[#]
    }] & /@ temporaryPagePaths;

pageManifest = MapThread[
  Function[{record, temporaryPath, finalPath, globalIndex},
    <|
      "GlobalPageIndex" -> globalIndex,
      "Representative" -> record["Representative"],
      "RepresentativePageIndex" -> record["RepresentativePageIndex"],
      "FileName" -> FileNameTake[finalPath],
      "RelativePath" -> FileNameJoin[{
        ".s02_ghostscript", "pages", FileNameTake[finalPath]
      }],
      "SHA256" -> sha256[temporaryPath],
      "Bytes" -> FileByteCount[temporaryPath],
      "PostScriptHeader" -> True
    |>
  ],
  {
    renderedRecords,
    temporaryPagePaths,
    finalPagePaths,
    Range[Length[temporaryPagePaths]]
  }
];

checks = <|
  "AcceptedS01SourceHash" -> True,
  "AcceptedS01ResultHash" -> True,
  "S01IdentityAndChecks" -> True,
  "RepresentativeSetExact" -> True,
  "DifferentFlavorAndMomentumOrder" -> True,
  "StoredDiagramContainersValid" -> True,
  "RegeneratedCountsMatchSavedCounts" ->
    TrueQ[savedDiagramCounts === regeneratedAmplitudeCounts],
  "EveryRepresentativePainted" ->
    And @@ (# > 0 & /@ Values[paintedPageCounts]),
  "PaintedObjectsAreFeynArtsGraphics" -> True,
  "OnePostScriptSheetPerPaintedPage" ->
    TrueQ[Length[renderedRecords] === Length[pageRecords]],
  "PostScriptHeadersAndSizesValid" -> True,
  "TemporaryPageSetExact" -> True,
  "NoPhysicsTransformation" -> True
|>;
require[And @@ Values[checks],
  "At least one final S02 acceptance check is false."];

s02Result = <|
  "Status" -> "Complete",
  "Stage" -> "HqqprimeS02-v1",
  "Channel" -> "Hqqprime only",
  "Purpose" -> "Diagram visualization and provenance only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "InputS01" -> <|
    "Source" -> s01SourcePath,
    "SourceSHA256" -> s01SourceSHA256,
    "Result" -> s01ResultPath,
    "ResultSHA256" -> s01ResultSHA256,
    "ReferencePDF" -> s01Result["ReferencePDF"],
    "ReferencePDFSHA256" -> s01Result["ReferencePDFSHA256"]
  |>,
  "Software" -> <|
    "WolframVersion" -> $Version,
    "FeynCalcVersion" -> FeynCalc`$FeynCalcVersion,
    "FeynArtsVersion" -> FeynArts`$FeynArtsVersion
  |>,
  "RepresentativeOrder" -> representativeOrder,
  "DiagramCounts" -> savedDiagramCounts,
  "RegeneratedAmplitudeCounts" -> regeneratedAmplitudeCounts,
  "PaintLayout" -> <|
    "ColumnsXRows" -> {2, 2},
    "PageCountsByRepresentative" -> paintedPageCounts,
    "TotalPageCount" -> Length[pageManifest]
  |>,
  "PageDirectory" -> finalPagesDirectory,
  "PageManifest" -> pageManifest,
  "Checks" -> checks,
  "DownstreamBoundary" -> <|
    "VisualizationOnly" -> True,
    "AmplitudesUnchanged" -> True,
    "PhysicsConsumptionForbidden" -> True,
    "S03MayOnlyConvertContainer" -> True
  |>
|>;

Print["S02_STAGE: writing and independently reloading the manifest"];
Put[s02Result, temporaryResultPath];
require[FileExistsQ[temporaryResultPath] &&
    FileByteCount[temporaryResultPath] > 0,
  "Temporary S02 result write failed."];
reloadedResult = Quiet @ Check[Get[temporaryResultPath], $Failed];
require[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === "HqqprimeS02-v1" &&
    reloadedResult["ProgramSHA256"] === programSHA256 &&
    reloadedResult["InputS01", "ResultSHA256"] === s01ResultSHA256 &&
    reloadedResult["PageManifest"] === pageManifest &&
    And @@ Values[reloadedResult["Checks"]],
  "Temporary S02 result reload validation failed."
];

RenameDirectory[temporaryPagesDirectory, finalPagesDirectory];
publicationOwnsFinalPages = True;
require[DirectoryQ[finalPagesDirectory],
  "Atomic publication of the final page directory failed."];
require[And @@ (FileExistsQ /@ finalPagePaths),
  "A final PostScript page is missing after publication."];
require[
  And @@ MapThread[
    sha256[#1] === #2["SHA256"] &,
    {finalPagePaths, pageManifest}
  ],
  "A final PostScript page hash changed during publication."
];

RenameFile[temporaryResultPath, s02ResultPath];
publicationOwnsFinalResult = True;
require[FileExistsQ[s02ResultPath],
  "Atomic publication of s02_result failed."];
require[Quiet @ Check[Get[s02ResultPath], $Failed] === s02Result,
  "Published s02_result differs from the validated manifest."];

publicationOwnsFinalPages = False;
publicationOwnsFinalResult = False;

Print["S02_DIAGRAM_COUNTS=", InputForm[savedDiagramCounts]];
Print["S02_REGENERATED_COUNTS=", InputForm[regeneratedAmplitudeCounts]];
Print["S02_PAGE_COUNTS=", InputForm[paintedPageCounts]];
Print["S02_PAGE_MANIFEST=", InputForm[pageManifest]];
Print["S02_PROGRAM_SHA256=", programSHA256];
Print["S02_INPUT_S01_RESULT_SHA256=", s01ResultSHA256];
Print["S02_RESULT_SHA256=", sha256[s02ResultPath]];
Print["S02_SUCCESS"];
Print["S02_RESULT=" <> s02ResultPath];
Print["S02_POSTSCRIPT_DIRECTORY=" <> finalPagesDirectory];
Quit[0];

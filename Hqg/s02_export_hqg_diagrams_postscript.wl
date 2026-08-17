(* ::Package:: *)

(* Render all validated Hqg S01 FeynArts diagram sets as native PostScript. *)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[
  fail, require, writePostScriptSheet, regeneratedAmplitudeCount,
  validatedSet
];

fail[text_String] := (Print["S02_FATAL: " <> text]; Quit[1]);
require[test_, text_String] := If[! TrueQ[test], fail[text]];

workingDirectory = DirectoryName[ExpandFileName[$InputFileName]];
resultPath = FileNameJoin[{workingDirectory, "s01_result"}];
postScriptDirectory = FileNameJoin[{workingDirectory, ".s02_ghostscript", "pages"}];

require[FileExistsQ[resultPath], "s01_result does not exist."];
result = Check[Get[resultPath], $Failed];
require[AssociationQ[result], "s01_result did not load as an Association."];
require[result["Status"] === "Complete", "s01_result is not complete."];
require[result["Stage"] === "HqgS01-v1", "s01_result stage mismatch."];
require[result["Channel"] === "Hqg only", "s01_result is not Hqg-only."];
require[result["BigTMDConvention", "ChannelNumber"] === 3,
  "s01_result is not bound to BigTMD channel 3."];
require[result["BigTMDConvention", "ChargeCase"] === "A only",
  "s01_result has the wrong BigTMD charge-case convention."];

regeneratedAmplitudeCount[diagrams_] := Module[{amplitudes},
  amplitudes = Check[
    FeynArts`CreateFeynAmp[diagrams, FeynArts`Truncated -> True],
    $Failed
  ];
  require[amplitudes =!= $Failed,
    "Could not regenerate amplitudes from a stored diagram set."];
  Length[List @@ amplitudes]
];

validatedSet[label_String, diagrams_, count_, expected_Integer] := Module[{},
  require[count === expected, label <> " count mismatch."];
  require[
    MatchQ[Head[diagrams], _FeynArts`TopologyList],
    label <> " is not a valid FeynArts TopologyList."
  ];
  require[regeneratedAmplitudeCount[diagrams] === count,
    label <> " regenerated-amplitude count mismatch."];
  {label, diagrams, count}
];

diagramSets = {
  validatedSet[
    "LO Hqg;q: gamma* q -> g q",
    result["LO", "FeynArtsDiagrams"],
    result["LO", "DiagramCount"],
    2
  ],
  validatedSet[
    "NLO real Hqg;qg: gamma* q -> g q g",
    result["NLOReal", "Hqg;qg", "FeynArtsDiagrams"],
    result["NLOReal", "Hqg;qg", "DiagramCount"],
    8
  ],
  validatedSet[
    "NLO virtual bare Hqg;q: gamma* q -> g q",
    result["NLOVirtual", "BareLoop", "FeynArtsDiagrams"],
    result["NLOVirtual", "BareLoop", "DiagramCount"],
    23
  ],
  validatedSet[
    "NLO Hqg;q QCD UV counterterms",
    result["NLOVirtual", "UVCounterterms", "FeynArtsDiagrams"],
    result["NLOVirtual", "UVCounterterms", "DiagramCount"],
    12
  ]
};

diagramCountAssociation = <|
  "LO" -> diagramSets[[1, 3]],
  "NLOReal" -> diagramSets[[2, 3]],
  "NLOVirtualBare" -> diagramSets[[3, 3]],
  "NLOVirtualCounterterms" -> diagramSets[[4, 3]]
|>;
require[Total[Values[diagramCountAssociation]] === 45,
  "The total Hqg diagram count is not 45."];

columnsAndRows = {3, 3};
expectedPageCount = Length[diagramSets];
require[expectedPageCount === 4, "The expected Hqg sheet count is not 4."];

Print["S02_STAGE: painting 45 stored Hqg diagrams in four sets"];
painted = Reap[
  Scan[
    Function[item,
      FeynArts`Paint[
        item[[2]],
        FeynArts`ColumnsXRows -> columnsAndRows,
        FeynArts`Numbering -> FeynArts`Simple,
        FeynArts`SheetHeader -> item[[1]],
        ImageSize -> 900,
        DisplayFunction -> Function[page, Sow[page, "S02Pages"]; Null]
      ]
    ],
    diagramSets
  ],
  "S02Pages"
];

require[Length[painted[[2]]] === 1, "FeynArts Paint produced no page collection."];
pages = painted[[2, 1]];
require[Length[pages] === expectedPageCount,
  "The painted-page count does not match the diagram layout."];
require[And @@ (MatchQ[Head[#], _FeynArts`FeynArtsGraphics] & /@ pages),
  "At least one painted page is not a FeynArtsGraphics object."];

Print["S02_STAGE: rendering ", Length[pages], " native PostScript sheets"];
postScriptSheets = Flatten[FeynArts`Render[#, "PS"] & /@ pages];
require[Length[postScriptSheets] === expectedPageCount,
  "The rendered PostScript-sheet count is wrong."];
require[And @@ (StringQ /@ postScriptSheets),
  "At least one PostScript sheet is not a string."];
require[And @@ (StringStartsQ[#, "%!PS-Adobe"] & /@ postScriptSheets),
  "At least one rendered sheet lacks a PostScript header."];

If[! DirectoryQ[postScriptDirectory],
  CreateDirectory[postScriptDirectory, CreateIntermediateDirectories -> True]
];
Scan[DeleteFile, FileNames["s02_page_*.ps", postScriptDirectory]];

postScriptPaths = MapIndexed[
  FileNameJoin[{
    postScriptDirectory,
    "s02_page_" <> IntegerString[First[#2], 10, 3] <> ".ps"
  }] &,
  postScriptSheets
];

writePostScriptSheet[path_String, content_String] := Module[{stream},
  stream = OpenWrite[path, CharacterEncoding -> "ISO8859-1"];
  require[Head[stream] === OutputStream,
    "Could not open a PostScript output file."];
  WriteString[stream, content];
  Close[stream]
];

MapThread[writePostScriptSheet, {postScriptPaths, postScriptSheets}];
require[And @@ (FileExistsQ /@ postScriptPaths),
  "At least one PostScript sheet was not written."];
require[And @@ ((FileByteCount[#] > 0) & /@ postScriptPaths),
  "At least one PostScript sheet is empty."];
require[
  Sort[FileNames["s02_page_*.ps", postScriptDirectory]] === Sort[postScriptPaths],
  "The output directory contains stale or missing S02 pages."
];

Print["S02_SUCCESS"];
Print["S02_INPUT_RESULT=" <> resultPath];
Print["S02_DIAGRAM_COUNTS=", InputForm[diagramCountAssociation]];
Print["S02_POSTSCRIPT_DIRECTORY=" <> postScriptDirectory];
Print["S02_POSTSCRIPT_SHEET_COUNT=", Length[postScriptSheets]];
Print["S02_POSTSCRIPT_BYTES=",
  InputForm[AssociationThread[postScriptPaths, FileByteCount /@ postScriptPaths]]];

Quit[0];

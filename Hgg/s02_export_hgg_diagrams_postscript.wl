(* ::Package:: *)

(*
  Render every FeynArts Hgg diagram stored in the validated s01_result as
  native PostScript sheets.  This stage performs no new physics algebra.
  A later S03 may convert these PostScript sheets into a combined PDF.
*)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];

FeynArts`$FAVerbose = 0;
$FCAdvice = False;

ClearAll[fail, require, writePostScriptSheet];

fail[text_String] := (
  Print["S02_FATAL: " <> text];
  Quit[1]
);

require[test_, text_String] :=
  If[! TrueQ[test], fail[text]];

workingDirectory = DirectoryName[ExpandFileName[$InputFileName]];
resultPath = FileNameJoin[{workingDirectory, "s01_result"}];
postScriptDirectory = FileNameJoin[{
  workingDirectory, ".s02_ghostscript", "pages"
}];

require[FileExistsQ[resultPath], "s01_result does not exist."];
result = Check[Get[resultPath], $Failed];
require[AssociationQ[result], "s01_result did not load as an Association."];
require[result["Status"] === "Complete", "s01_result is not marked complete."];
require[result["Channel"] === "Hgg only", "s01_result is not the Hgg channel."];
require[
  result["Contribution"] === "Hgg;q qbar",
  "s01_result does not contain the expected Hgg;q qbar contribution."
];
require[
  ! KeyExistsQ[result, "LO"] && ! KeyExistsQ[result, "NLOVirtual"],
  "s01_result unexpectedly contains an Hgg LO or virtual payload."
];

hggDiagramCount = result[
  "NLOReal", "Hgg;q_qbar", "DiagramCount"
];
hggDiagrams = result[
  "NLOReal", "Hgg;q_qbar", "FeynArtsDiagrams"
];

require[
  IntegerQ[hggDiagramCount] && hggDiagramCount > 0,
  "The stored Hgg diagram count is not a positive integer."
];
require[
  hggDiagramCount === result[
    "DiagramCounts", "NLOReal_gammaStar_g_to_g_q_qbar"
  ],
  "The two stored Hgg diagram counts disagree."
];
require[
  MatchQ[Head[hggDiagrams], _FeynArts`TopologyList] &&
    Length[hggDiagrams] === hggDiagramCount,
  "The stored Hgg diagrams are not a FeynArts TopologyList."
];

diagramSets = {
  {
    "NLO real Hgg;q qbar: gamma* g -> g q qbar",
    hggDiagrams,
    hggDiagramCount
  }
};

columnsAndRows = {3, 3};
diagramsPerPage = Times @@ columnsAndRows;
expectedPageCount = Total[
  Ceiling[#[[3]]/diagramsPerPage] & /@ diagramSets
];

Print[
  "S02_STAGE: painting ", hggDiagramCount,
  " stored Hgg;q qbar diagrams"
];
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

require[
  Length[painted[[2]]] === 1,
  "FeynArts Paint produced no page collection."
];
pages = painted[[2, 1]];
require[Length[pages] > 0, "FeynArts Paint produced zero pages."];
require[
  Length[pages] === expectedPageCount,
  "The painted-page count does not match the diagram layout."
];
require[
  And @@ (MatchQ[Head[#], _FeynArts`FeynArtsGraphics] & /@ pages),
  "At least one painted page is not a FeynArtsGraphics object."
];

Print[
  "S02_STAGE: rendering ", Length[pages],
  " native PostScript sheet(s)"
];
postScriptSheets = Flatten[FeynArts`Render[#, "PS"] & /@ pages];
require[
  Length[postScriptSheets] === expectedPageCount,
  "The rendered PostScript-sheet count does not match the painted pages."
];
require[
  And @@ (StringQ /@ postScriptSheets),
  "At least one FeynArts PostScript sheet is not a string."
];
require[
  And @@ (StringStartsQ[#, "%!PS-Adobe"] & /@ postScriptSheets),
  "At least one rendered sheet lacks a PostScript header."
];

If[
  ! DirectoryQ[postScriptDirectory],
  CreateDirectory[
    postScriptDirectory,
    CreateIntermediateDirectories -> True
  ]
];

Scan[
  DeleteFile,
  FileNames["s02_page_*.ps", postScriptDirectory]
];

postScriptPaths = MapIndexed[
  FileNameJoin[{
    postScriptDirectory,
    "s02_page_" <> IntegerString[First[#2], 10, 3] <> ".ps"
  }] &,
  postScriptSheets
];

writePostScriptSheet[path_String, content_String] := Module[{stream},
  stream = OpenWrite[path, CharacterEncoding -> "ISO8859-1"];
  require[Head[stream] === OutputStream, "Could not open a PostScript output file."];
  WriteString[stream, content];
  Close[stream]
];

MapThread[
  writePostScriptSheet,
  {postScriptPaths, postScriptSheets}
];

require[
  And @@ (FileExistsQ /@ postScriptPaths),
  "At least one PostScript sheet was not written."
];
require[
  And @@ ((FileByteCount[#] > 0) & /@ postScriptPaths),
  "At least one PostScript sheet is empty."
];
require[
  Sort[FileNames["s02_page_*.ps", postScriptDirectory]] ===
    Sort[postScriptPaths],
  "The output directory contains stale or missing S02 PostScript pages."
];

Print["S02_SUCCESS"];
Print["S02_INPUT_RESULT=" <> resultPath];
Print["S02_DIAGRAM_COUNT=", hggDiagramCount];
Print["S02_POSTSCRIPT_DIRECTORY=" <> postScriptDirectory];
Print["S02_POSTSCRIPT_SHEET_COUNT=", Length[postScriptSheets]];
Print[
  "S02_POSTSCRIPT_BYTES=",
  InputForm[AssociationThread[postScriptPaths, FileByteCount /@ postScriptPaths]]
];

Quit[0];

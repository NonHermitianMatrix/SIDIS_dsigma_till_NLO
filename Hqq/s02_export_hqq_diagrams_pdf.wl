(* Render every FeynArts Hqq diagram stored in s01_result as PostScript.
   Run s03_convert_hqq_diagrams_pdf.sh afterwards to create the PDF. *)

$HistoryLength = 0;
$LoadFeynArts = True;
Needs["FeynCalc`"];
FeynArts`$FAVerbose = 0;

ClearAll[fail, require];
fail[text_String] := (Print["S02_FATAL: " <> text]; Quit[1]);
require[test_, text_String] := If[! TrueQ[test], fail[text]];

workingDirectory = DirectoryName[ExpandFileName[$InputFileName]];
resultPath = FileNameJoin[{workingDirectory, "s01_result"}];
postScriptDirectory = FileNameJoin[{
  workingDirectory, ".s02_ghostscript", "pages"
}];

require[FileExistsQ[resultPath], "s01_result does not exist."];
result = Check[Get[resultPath], $Failed];
require[AssociationQ[result], "s01_result did not load as an Association."];
require[result["Status"] === "Complete", "s01_result is not marked complete."];

diagramSets = {
  {"LO: gamma* q -> q g", result["LO", "FeynArtsDiagrams"]},
  {"NLO real Hqq;gg: gamma* q -> q g g",
    result["NLOReal", "Hqq;gg", "FeynArtsDiagrams"]},
  {"NLO real Hqq;q qbar (same flavor)",
    result["NLOReal", "Hqq;q_qbar_sameFlavor", "FeynArtsDiagrams"]},
  {"NLO real Hqq;q' qbar' (different flavor)",
    result["NLOReal", "Hqq;qPrime_qbarPrime", "FeynArtsDiagrams"]},
  {"NLO bare virtual: gamma* q -> q g",
    result["NLOVirtual", "BareLoop", "FeynArtsDiagrams"]},
  {"NLO UV counterterms: gamma* q -> q g",
    result["NLOVirtual", "UVCounterterms", "FeynArtsDiagrams"]}
};

Print["S02_STAGE: painting all stored Hqq diagram sets"];
painted = Reap[
  Scan[
    Function[item,
      FeynArts`Paint[
        item[[2]],
        FeynArts`ColumnsXRows -> {3, 4},
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
require[Length[pages] > 0, "FeynArts Paint produced zero pages."];
require[And @@ (MatchQ[Head[#], _FeynArts`FeynArtsGraphics] & /@ pages),
  "At least one painted page is not a FeynArtsGraphics object."];

Print["S02_STAGE: rendering native PostScript sheets"];
postScriptSheets = Flatten[FeynArts`Render[#, "PS"] & /@ pages];
require[Length[postScriptSheets] > 0, "FeynArts rendered zero PostScript sheets."];
require[And @@ (StringQ /@ postScriptSheets),
  "At least one FeynArts PostScript sheet is not a string."];

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
MapThread[
  Function[{path, content},
    stream = OpenWrite[path, CharacterEncoding -> "ISO8859-1"];
    WriteString[stream, content];
    Close[stream]
  ],
  {postScriptPaths, postScriptSheets}
];
require[And @@ (FileExistsQ /@ postScriptPaths),
  "At least one PostScript sheet was not written."];

Print["S02_SUCCESS"];
Print["S02_POSTSCRIPT_DIRECTORY=" <> postScriptDirectory];
Print["S02_POSTSCRIPT_SHEET_COUNT=", Length[postScriptSheets]];
Quit[0];

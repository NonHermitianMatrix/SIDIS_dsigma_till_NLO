(* Register the accepted pair-assembly source in the unchanged reference reduction. *)
$HistoryLength = 0;
extensionDispatch = FileNameJoin[{Directory[], "common", "s08_extend_pair_reduction.wls"}];
extensionBase = FileNameJoin[{Directory[], "common", "s08_extend_real_reduction.wls"}];
If[IntegerString[FileHash[extensionBase, "SHA256"], 16, 64] =!=
  "db9875bb42086b9e52a405bc61b46262661cf91b72681dc57c22c977121a22e7", Quit[1]];
extensionText = Import[extensionBase, "Text"];
extensionSourceEntry = "\nmapperSource = SelectFirst[mapperSources,";
extensionExportEntry = "\nput[result, FileNameJoin[{resultDir, \"s08_reduction.wl\"}]];";
If[!SyntaxQ[Import[extensionDispatch, "Text"]] ||
  StringCount[extensionText, extensionSourceEntry] =!= 1 ||
  StringCount[extensionText, extensionExportEntry] =!= 1, Quit[1]];
extensionText = StringReplace[extensionText, {
  extensionSourceEntry -> ("\nAppendTo[mapperSources, FileNameJoin[{root, \"common\", \"s08_assemble_quark_pair_targets.wls\"}]];" <> extensionSourceEntry),
  extensionExportEntry -> ("\nresult=Join[result,<|\"DispatchSourceHash\"->FileHash[extensionDispatch,\"SHA256\"]|>];" <> extensionExportEntry)}];
If[!SyntaxQ[extensionText], Quit[1]];
ToExpression[extensionText, InputForm];

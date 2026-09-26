(* Preserve the complete final calculation; bound and verify its native file representation. *)
$HistoryLength=0;
compactFinalSource=FileNameJoin[{Directory[],"common","s15_finalize_spin_coefficients_compact.wls"}];
compactFinalBase=FileNameJoin[{Directory[],"common","s15_finalize_spin_coefficients.wls"}];
If[IntegerString[FileHash[compactFinalBase,"SHA256"],16,64]=!=
  "54838cdee6222b75e578a242a940bdb79bd1517d41e098cbd9ca18fd369463f8",Quit[1]];
compactFinalText=Import[compactFinalBase,"Text"];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
compactFinalReplacements={
  "Get[\"FeynCalc`\"]"->"If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]",
  "put[value_, path_] := (Put[value, path <> \".tmp\"]; RenameFile[path <> \".tmp\", path, OverwriteTarget -> True]);"->
  "put[value_, path_] := Module[{serialized},ClearSystemCache[];serialized=\"Uncompress[\"<>ToString[Compress[value],InputForm]<>\"]\\n\";gate[\"bounded final native file \"<>StringDrop[path,StringLength[root]+1],StringLength[serialized]<128*1024^2];Export[path<>\".tmp\",serialized,\"Text\"];Clear[serialized];ClearSystemCache[];gate[\"exact final native reload \"<>StringDrop[path,StringLength[root]+1],Get[path<>\".tmp\"]===value];RenameFile[path<>\".tmp\",path,OverwriteTarget->True]];",
  "resultDirectory = FileNameJoin[{root, channel, \"s15_result\"}];"->
  "AssociateTo[result,\"DispatchSourceHash\"->FileHash[compactFinalSource,\"SHA256\"]];Clear[raw];ClearSystemCache[];resultDirectory = FileNameJoin[{root, channel, \"s15_result\"}];",
  "KeyValueMap[put[#2, FileNameJoin[{resultDirectory, \"s15_\" <> #1 <> \"_hat.wl\"}]] &, hats];"->
  "Clear[result];ClearSystemCache[];KeyValueMap[put[#2, FileNameJoin[{resultDirectory, \"s15_\" <> #1 <> \"_hat.wl\"}]] &, hats];"};
If[!And@@(StringCount[compactFinalText,First[#]]===1&/@compactFinalReplacements),
  Print["FAIL: unique final native-storage interfaces"];Quit[1]];
compactFinalCode=StringReplace[compactFinalText,compactFinalReplacements];
If[StringReplace[compactFinalCode,Reverse/@compactFinalReplacements]=!=compactFinalText||
  !SyntaxQ[compactFinalCode]||!SyntaxQ[Import[compactFinalSource,"Text"]],
  Print["FAIL: unchanged final calculation and complete compact syntax"];Quit[1]];
ToExpression[compactFinalCode,InputForm];

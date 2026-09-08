If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
$HistoryLength = 0;
out = DirectoryName[$InputFileName]; root = ParentDirectory[out];
basis = Get[FileNameJoin[{root, "s05_result.wl"}]];
If[basis["SourceHash"] =!= FileHash[FileNameJoin[{root, "s05_real_angular_basis.wl"}], "SHA256"], Print["FAIL: source identity"]; Quit[1]];
results = Association@Table[
 denoms = basis["Basis"][key]["Denominators"];
 rows = Table[
   used = First[FirstPosition[denoms, denominator]];
   correct = First[FirstPosition[denoms, denominator, Missing["NotFound"], {1}]];
   <|"Requested" -> denominator, "UsedIndex" -> used, "Selected" -> denoms[[used]],
     "TopLevelIndex" -> correct, "Equal" -> (denoms[[used]] === denominator)|>, {denominator, denoms}];
 bad = Select[rows, !TrueQ[#["Equal"]] &];
 Print[key, " incorrect denominator selections: ", InputForm[bad]];
 key -> <|"Rows" -> rows, "Incorrect" -> bad|>, {key, {"RealSame_Charge0__Pg", "RealSame_Charge0__Ppp"}}];
Put[<|"Results" -> results, "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "InputHash" -> FileHash[FileNameJoin[{root, "s05_result.wl"}], "SHA256"]|>, FileNameJoin[{out, "s05_result.wl"}]];
Print["S05_SUCCESS: indexing diagnostic complete; no F hats accepted"];
Quit[];

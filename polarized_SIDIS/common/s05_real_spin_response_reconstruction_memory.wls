(* Resume one memory-bounded check without changing its mathematical predicate. *)
$HistoryLength = 0;
reconstructionMemorySource = FileNameJoin[{Directory[], "common", "s05_real_spin_response_reconstruction_memory.wls"}];
reconstructionMemoryHash = FileHash[reconstructionMemorySource, "SHA256"];
reconstructionMemoryBase = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[Environment["POLARIZED_SIDIS_CHANNEL"] =!= "Hqq" ||
  IntegerString[FileHash[reconstructionMemoryBase, "SHA256"], 16, 64] =!=
    "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
  Print["FAIL: reconstruction memory channel and source binding"]; Quit[1]];
reconstructionMemoryText = Import[reconstructionMemoryBase, "Text"];
reconstructionMemoryChanges = {
  "If[FreeQ[label, \"exact spin reconstruction\"], realMemoryLimit, 4*1024^3]" ->
    "If[label === {\"RealSame\", \"exact spin reconstruction\", 9}, 8*1024^3, If[FreeQ[label, \"exact spin reconstruction\"], realMemoryLimit, 4*1024^3]]",
  "\n$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; Get[\"FeynCalc`\"];" -> "\n$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]];",
  "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];" ->
    "AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];\nAssociateTo[result, \"ReconstructionMemoryDispatchHash\" -> reconstructionMemoryHash, \"ReconstructionMemoryOverride\" -> <|\"Label\" -> {\"RealSame\", \"exact spin reconstruction\", 9}, \"Bytes\" -> 8*1024^3|>];"};
If[!(And @@ (StringCount[reconstructionMemoryText, First[#]] === 1 & /@ reconstructionMemoryChanges)),
  Print["FAIL: unique reconstruction memory interfaces"]; Quit[1]];
reconstructionMemoryRun = StringReplace[reconstructionMemoryText, reconstructionMemoryChanges];
If[!SyntaxQ[Import[reconstructionMemorySource, "Text"]] || !SyntaxQ[reconstructionMemoryRun] ||
  StringReplace[reconstructionMemoryRun, Reverse /@ reconstructionMemoryChanges] =!= reconstructionMemoryText,
  Print["FAIL: complete unchanged reconstruction calculation"]; Quit[1]];
Print["PASS: reconstruction memory adapter preserves complete calculation"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
ToExpression[reconstructionMemoryRun, InputForm];

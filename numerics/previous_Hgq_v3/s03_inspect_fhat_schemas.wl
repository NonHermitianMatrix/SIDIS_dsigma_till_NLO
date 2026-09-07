(* Inspect frozen numerical-consumer interfaces without changing coefficients. *)
$HistoryLength = 0;
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
manifest = Import[FileNameJoin[{root, "s01_result"}], "RawJSON"];
cache = FileNameJoin[{root, "s03_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
sourceHash = IntegerString[FileHash[$InputFileName, "SHA256"], 16, 64];
keyText[k_] := If[StringQ[k], k, ToString[k, InputForm]];
ClearAll[describe, scalar];
scalar[e_] := Module[{n, syms, custom, small},
  n = LeafCount[e];
  syms = DeleteDuplicates[Cases[e,
    s_Symbol /; Context[s] =!= "System`" :> ToString[s, InputForm],
    Infinity, Heads -> True]];
  custom = DeleteDuplicates[Cases[e,
    x_ /; (!AtomQ[x] && !MemberQ[{Plus, Times, Power, List, Association,
      Rule, RuleDelayed, Log, PolyLog, Rational, Complex, Sqrt}, Head[x]]) :>
      ToString[Head[x], InputForm], Infinity]];
  small = If[n < 160, ToString[e, InputForm], "omitted: large expression"];
  <|"Head" -> ToString[Head[e], InputForm], "LeafCount" -> n,
    "Symbols" -> Sort[syms], "AdditionalHeads" -> Sort[custom],
    "SmallExpression" -> small|>
];
describe[e_Association, depth_:0] := Association@KeyValueMap[
  (keyText[#1] -> If[depth < 3, describe[#2, depth + 1], scalar[#2]]) &, e];
describe[e_, depth_:0] := scalar[e];
results = <||>;
Do[
  channel = entry["channel"];
  Print["S03_CHANNEL_START ", channel];
  files = Select[entry["files"], #["role"] === "terminal_fhat_payload" &];
  output = FileNameJoin[{cache, channel <> ".json"}];
  record = <|"Channel" -> channel, "SourceHash" -> sourceHash, "Files" -> <||>|>;
  Do[
    path = FileNameJoin[{root, file["copy"]}];
    actual = IntegerString[FileHash[path, "SHA256"], 16, 64];
    If[actual =!= file["sha256"], Print["S03_FATAL hash ", path]; Quit[1]];
    Print["S03_LOAD ", file["copy"]];
    value = Get[path];
    If[value === $Failed, Print["S03_FATAL Get ", path]; Quit[1]];
    AssociateTo[record["Files"], file["copy"] -> <|"SHA256" -> actual,
      "Schema" -> describe[value]|>];
    Print["S03_INSPECTED ", file["copy"], " memory=", MemoryInUse[]];
    Clear[value]; ClearSystemCache[],
    {file, files}];
  Export[output, record, "RawJSON"];
  AssociateTo[results, channel -> record];
  Clear[record]; ClearSystemCache[];
  Print["S03_CHANNEL_DONE ", channel],
  {entry, manifest["channels"]}];
Export[FileNameJoin[{root, "s03_result"}],
  <|"Stage" -> "s03", "Status" -> "Complete", "SourceHash" -> sourceHash,
    "Runtime" -> $Version, "Channels" -> results|>, "RawJSON"];
Print["S03_SUCCESS"];
Quit[0];

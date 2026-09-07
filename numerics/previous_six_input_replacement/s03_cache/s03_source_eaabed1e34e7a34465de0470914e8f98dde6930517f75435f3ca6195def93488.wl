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
require[b_,msg_] := If[!TrueQ[b],Print["S03_FATAL ",msg];Quit[1]];
previousPath=FileNameJoin[{root,"previous_Hgq_v3","s03_result"}];
previous=If[FileExistsQ[previousPath],Import[previousPath,"RawJSON"],<||>];
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
  If[KeyExistsQ[entry,"snapshot_reused_from"] && KeyExistsQ[Lookup[previous,"Channels",<||>],channel],
    record=previous["Channels"][channel];
    require[And@@Table[record["Files"][file["copy"]]["SHA256"]===file["sha256"],{file,files}],"reused schema input hashes"];
    AssociateTo[record,"ReusedFrom"-><|"Path"->"previous_Hgq_v3/s03_result",
      "SHA256"->FileHash[previousPath,"SHA256","HexString"]|>];
    Export[output,record,"RawJSON"];AssociateTo[results,channel->record];
    Print["S03_CHANNEL_REUSED ",channel];Continue[]];
  record = <|"Channel" -> channel, "SourceHash" -> sourceHash, "Files" -> <||>|>;
  Do[
    path = FileNameJoin[{root, file["copy"]}];
    actual = IntegerString[FileHash[path, "SHA256"], 16, 64];
    If[actual =!= file["sha256"], Print["S03_FATAL hash ", path]; Quit[1]];
    Print["S03_LOAD ", file["copy"]];
    value = Get[path];
    Print["S03_LOADED ",file["copy"]," memory=",MemoryInUse[]];
    If[value === $Failed, Print["S03_FATAL Get ", path]; Quit[1]];
    If[channel==="Hgq_v4",
      poles=Get[FileNameJoin[{root,"Fhats",channel,"s10_poles.wl"}]];
      sourcePath=FileNameJoin[{root,"Fhats",channel,"s10_final_hats.wl"}];
      checks=<|"source_hash"->(value["SourceHash"]===FileHash[sourcePath,"SHA256"]),
        "regulator_cancellation"->TrueQ[value["RegulatorCancellationPassed"]],
        "pole_acceptance"->TrueQ[poles["Accepted"]],
        "pole_input_identity"->(poles["InputHash"]===value["InputHash"]),
        "all_pole_residues_zero"->And@@(#===0&/@Flatten[Values/@Values[poles["PoleResidues"]]])|>;
      require[And@@Values[checks],"v4 frozen acceptance contract"];
      Print["S03_V4_ACCEPTANCE_PASSED"];
      plusObjects=DeleteDuplicates@Cases[Values[value["StructureFunctions"]],
        x_/;(!AtomQ[x] && SymbolName[Head[x]]==="PlusDistribution"):>x,Infinity];
      logArguments=DeleteDuplicates@Flatten[Cases[First[#],Log[a_]:>a,Infinity]&/@plusObjects];
      require[Length[logArguments]===1 && Length[plusObjects]>0,"v4 plus logarithm identity"];
      logarithmicPlus=SelectFirst[plusObjects,!FreeQ[First[#],Log]&];
      normalized=Together[First[logArguments]/(logarithmicPlus[[2,1]]/logarithmicPlus[[2,3]])]===1;
      require[normalized && logarithmicPlus[[2,2]]===0,"v4 normalized bounded plus definition"];
      Print["S03_V4_PLUS_PASSED ",InputForm[logArguments]];
      loExpressions=value["Hats"][#]["LODelta"]&/@Keys[value["Hats"]];
      nloExpressions=Flatten[Table[Values[value["Hats"][hat]["NLO"][branch]],
        {hat,Keys[value["Hats"]]},{branch,Keys[value["BranchCoordinates"]]}]];
      nonzero=Select[Join[loExpressions,nloExpressions],#=!=0&];
      chargeDegrees=DeleteDuplicates[Exponent[#,eq]&/@nonzero];
      Print["S03_V4_CHARGE_DEGREES ",InputForm[chargeDegrees]];
      loDegrees=DeleteDuplicates[Exponent[#,alphaS]&/@Select[loExpressions,#=!=0&]];
      Print["S03_V4_LO_DEGREES ",InputForm[loDegrees]];
      nloDegrees=DeleteDuplicates[Exponent[#,alphaS]&/@Select[nloExpressions,#=!=0&]];
      require[Length[chargeDegrees]===1 && Length[loDegrees]===1 && Length[nloDegrees]===1,"v4 coupling coverage"];
      consumer=<|"Status"->"Complete","InputSHA256"->actual,"Checks"->checks,
        "PlusDefinition"->ToString[value["PlusDefinition"],InputForm],
        "PlusLogArgument"->StringReplace[ToString[First[logArguments]/.s23->ss,InputForm],"^"->"**"],
        "NormalizedPlusLogarithm"->normalized,
        "BranchCoordinates"->ToString[value["BranchCoordinates"],InputForm],
        "BranchDomains"->ToString[value["BranchDomains"],InputForm],
        "CoordinateBoundaryPresent"->KeyExistsQ[value,"BoundaryAtTEqualsMinusS"],
        "ChargeDegree"->First[chargeDegrees],"LOAlphaDegree"->First[loDegrees],"NLOAlphaDegree"->First[nloDegrees]|>;
      Export[FileNameJoin[{cache,"Hgq_v4_consumer_contract"}],consumer,"RawJSON"];
      Print["S03_V4_CONSUMER ",InputForm[consumer]]];
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

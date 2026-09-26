(* Extend the original auxiliary UV reduction for recorded polarized targets. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
sourcePath = FileNameJoin[{root, "common", "s13_extend_uv_reduction.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate["time bound " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory bound " <> ToString[label, InputForm], False]];
put[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
resultDir = FileNameJoin[{root, channel, "s13_uv_reduction_result"}];
configPath = FileNameJoin[{resultDir, "s13_inputs.json"}];
settings = Import[configPath, "RawJSON"];
gate["owned extension inputs", settings["schema"] === "polarized-sidis-uv-extension-inputs-v1" && settings["channel"] === channel];
Do[gate["pinned missing-target packet " <> row["file"],
  IntegerString[FileHash[FileNameJoin[{root, row["file"]}], "SHA256"], 16, 64] === row["sha256"]], {row, settings["files"]}];
packets = Get[FileNameJoin[{root, #["file"]}]] & /@ settings["files"];
gate["recorded missing targets", Length[packets] > 0 && AllTrue[packets,
  AssociationQ[#] && MatchQ[#["MissingTargets"], {__GLI}] && AssociationQ[#["Coefficients"]] &]];
mappingInputHashes = DeleteDuplicates[Lookup[packets, "InputHash"]];
gate["one exact source calculation", Length[mappingInputHashes] === 1 && IntegerQ[First[mappingInputHashes]]];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
library = Get[libraryPath];
gate["accepted scalar library", library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
geometry = readLibrary["s02"]; uv = readLibrary["s14"];
assemblyConfigPath = FileNameJoin[{root, "common", "s13_inputs.json"}];
assemblyConfig = Import[assemblyConfigPath, "RawJSON"];
Do[gate["pinned UV reference " <> row["destination"], IntegerString[
  FileHash[FileNameJoin[{root, row["destination"]}], "SHA256"], 16, 64] === row["sha256"]], {row, assemblyConfig["files"]}];
baselinePath = FileNameJoin[{root, "common", "s13_result", "reference", "s14_reduction.wl"}];
mastersPath = FileNameJoin[{root, "common", "s13_result", "reference", "s14_master_values.wl"}];
baseline = Get[baselinePath]; masterValues = Get[mastersPath];
originalSource = FileNameJoin[{root, "common", "s06_result", "reference", "sources", "s14_uv_residues.wl"}];
gate["accepted original auxiliary reduction", TrueQ[baseline["Accepted"]] && baseline["InputHash"] === uv["InputHash"] &&
  baseline["SourceHash"] === uv["SourceHash"] && uv["SourceHash"] === FileHash[originalSource, "SHA256"]];
gate["accepted original auxiliary masters", Sort[Keys[masterValues]] === Sort[baseline["Masters"]] &&
  AllTrue[Values[masterValues], MatchQ[#, _SeriesData] &]];
families = baseline["Families"]; names = Sort[Keys[families]];
gate["unchanged recorded auxiliary families", AllTrue[packets,
  #["Families"] === Map[KeyTake[#, {"Momenta", "Masses"}] &, families] &]];
external = geometry["ExternalMomenta"];
externalGram = Take[geometry["CommonGram"], {1, Length[external]}, {1, Length[external]}] /. w -> 0;
additionalTargets = Union[Flatten[Lookup[packets, "MissingTargets"]]];
targets = Union[baseline["Targets"], First /@ baseline["Rules"], baseline["Masters"], additionalTargets];
gate["recorded coefficient target coverage", AllTrue[packets, Complement[Keys[#["Coefficients"]], targets] === {} &]];
gate["inherited target families", Complement[targets[[All, 1]], names] === {}];
kira = settings["kira"]["path"]; fermat = settings["fermat"]["path"];
Do[gate["reviewed executable " <> name, IntegerString[FileHash[settings[name]["path"], "SHA256"], 16, 64] === settings[name]["sha256"]],
  {name, {"kira", "fermat"}}];
SetEnvironment["FERMATPATH" -> fermat];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = Join[{configPath, libraryPath, assemblyConfigPath, baselinePath, mastersPath, originalSource},
  (FileNameJoin[{root, #["file"]}] &) /@ settings["files"],
  (FileNameJoin[{root, library["Library"][#]["File"]}] &) /@ {"s02", "s14"}];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, FileHash[kira, "SHA256"], FileHash[fermat, "SHA256"]}, "SHA256"];
mapWork = FileNameJoin[{root, "cache", "s13_uv_extension", channel, IntegerString[inputHash, 16]}];
work = FileNameJoin[{mapWork, "s14_kira"}]; config = FileNameJoin[{work, "config"}];
If[!DirectoryQ[config], CreateDirectory[config, CreateIntermediateDirectories -> True]];
put[<|"Packets" -> packets, "Families" -> families, "Targets" -> targets, "InputHash" -> inputHash,
  "SourceHash" -> sourceHash|>, FileNameJoin[{mapWork, "s14_scalar_maps.wl"}]];
originalText = Import[originalSource, "Text"]; ownText = Import[sourcePath, "Text"];
originalBlock = StringTake[originalText, {First[First[StringPosition[originalText, "text[expression_] :="]]],
  First[First[StringPosition[originalText, "\nreduction=<|"]]] - 1}];
ownBlock = StringTake[ownText, {Last[First[StringPosition[ownText, "\n(* BEGIN REFERENCE UV KIRA WORKFLOW *)\n"]]] + 1,
  First[First[StringPosition[ownText, "\n(* END REFERENCE UV KIRA WORKFLOW *)\n"]]] - 1}];
gate["unchanged complete UV Kira configuration and reader", StringTrim[originalBlock] === StringTrim[ownBlock]];
(* BEGIN REFERENCE UV KIRA WORKFLOW *)
text[expression_] := StringReplace[ToString[InputForm[expression]], Whitespace -> ""];
csv[list_] := "[" <> StringRiffle[text /@ list, ","] <> "]";
integralText[integral_] := integral[[1]] <> csv[integral[[2]]];
invariants = Union[{M2},Sort[DeleteDuplicates[Cases[externalGram,
  symbol_Symbol /; Context[symbol] === "Global`", Infinity]]]];
(* Fermat requires lower-case variable names. This is a name change only. *)
exportRules = {Q2 -> q2,M2->m2};
importRules = Reverse /@ exportRules;
gate["invariant rename is invertible", (invariants /. exportRules /. importRules) === invariants];
kinematics = {"kinematics:", "  incoming_momenta: " <> csv[external],
  "  outgoing_momenta: []", "  kinematic_invariants:"};
kinematics = Join[kinematics, ("    - [" <> text[# /. exportRules] <> ", 2]" & /@ invariants),
  {"  scalarproduct_rules:"}, Flatten[Table[
    "    - [[" <> text[external[[i]]] <> "," <> text[external[[j]]] <> "], " <>
      text[externalGram[[i, j]] /. exportRules] <> "]",
    {i, Length[external]}, {j, i, Length[external]}]]];
Export[FileNameJoin[{config, "kinematics.yaml"}], StringRiffle[kinematics, "\n"] <> "\n", "Text"];
familyLines = {"integralfamilies:"};
reductions = {};
preferred = {};
bounds = <||>;
globalR = Max[Total[Select[#, #>0 &]] & /@ targets[[All,2]]] + Length[First[Values[families]]["LoopMomenta"]];
globalS = Max[-Total[Select[#, #<0 &]] & /@ targets[[All,2]]] + Length[First[Values[families]]["LoopMomenta"]];
Do[
  spec = families[name];
  actual = Select[targets, #[[1]] === name &][[All, 2]];
  positiveSums = Total[Select[#, # > 0 &]] & /@ actual;
  negativeSums = -Total[Select[#, # < 0 &]] & /@ actual;
  sectors = Sort[DeleteDuplicates[Total[MapIndexed[
    If[#1 > 0, 2^(First[#2] - 1), 0] &, #]] & /@ actual]];
  topSectors = Select[sectors, Function[sector, !AnyTrue[DeleteCases[sectors, sector],
    BitAnd[sector, #] === sector &]]];
  rBound = globalR;
  sBound = globalS;
  AssociateTo[bounds, name -> <|"r" -> rBound, "s" -> sBound,
    "Sectors" -> sectors, "TopSectors" -> topSectors, "TargetCount" -> Length[actual]|>];
  familyLines = Join[familyLines, {"  - name: " <> name,
    "    loop_momenta: " <> csv[spec["LoopMomenta"]],
    "    top_level_sectors: " <> csv[topSectors], "    propagators:"},
    MapThread["      - [\"" <> text[#1] <> "\", " <> text[#2 /. exportRules] <> "]" &,
      {spec["PropagatorMomenta"], spec["PropagatorMassesSquared"]}],
    {}];
  AppendTo[reductions, "        - {topologies: [" <> name <> "], sectors: " <>
    csv[topSectors] <> ", r: " <> text[rBound] <> ", s: " <> text[sBound] <> "}"];
  preferred = Join[preferred, Table[GLI[name,
    Table[If[MemberQ[support, i], 1, 0], {i,Length[spec["PropagatorMomenta"]]}]],
    {support, Subsets[Range[Length[spec["PropagatorMomenta"]]]]}]],
  {name, names}];
Export[FileNameJoin[{config, "integralfamilies.yaml"}], StringRiffle[familyLines, "\n"] <> "\n", "Text"];
Export[FileNameJoin[{work, "targets"}], StringRiffle[integralText /@ targets, "\n"] <> "\n", "Text"];
Export[FileNameJoin[{work, "preferred"}], StringRiffle[integralText /@ preferred, "\n"] <> "\n", "Text"];
jobs = Join[{"jobs:", "  - reduce_sectors:", "      reduce:"}, reductions,
  {"      select_integrals:", "        select_mandatory_list:", "          - [targets]",
   "      preferred_masters: preferred", "      run_initiate: true",
   "      run_triangular: true", "      run_back_substitution: true",
   "  - kira2math:", "      target:", "        - [targets]"}];
Export[FileNameJoin[{work, "jobs.yaml"}], StringRiffle[jobs, "\n"] <> "\n", "Text"];
put[<|"InputHash" -> inputHash, "SourceHash" -> sourceHash, "Bounds" -> bounds,
  "Families" -> families, "Targets" -> targets, "PreferredCandidates" -> preferred,
  "ExportRules" -> exportRules, "ImportRules" -> importRules,
  "ScalarMapFile" -> "../s14_scalar_maps.wl"|>, FileNameJoin[{work, "s14_configuration.wl"}]];
Print["KIRA_START ", work, " target count ", Length[targets], " bounds ", InputForm[bounds]];
run = RunProcess[{kira, "--parallel=2", "jobs.yaml"}, All, ProcessDirectory -> work];
Export[FileNameJoin[{work, "s14_kira_stdout.log"}], run["StandardOutput"], "Text"];
Export[FileNameJoin[{work, "s14_kira_stderr.log"}], run["StandardError"], "Text"];
Print[StringTake[run["StandardOutput"], -Min[12000, StringLength[run["StandardOutput"]]]]];
If[run["StandardError"] =!= "", Print[run["StandardError"]]];
gate["Kira completed", run["ExitCode"] === 0];
ruleFiles = Sort[FileNames["kira_*.m", FileNameJoin[{work, "results"}], Infinity]];
gate["Kira exported symbolic rules", Length[ruleFiles] > 0];
rules = DeleteDuplicates[Flatten[Get /@ ruleFiles]];
gate["Kira output consists of rules", MatchQ[rules, {__Rule}]];
heads = Symbol /@ names;
toIntegral[expression_] := expression /. (HoldPattern[h_[indices__Integer]] /; MemberQ[heads, h]) :>
  GLI[SymbolName[h], {indices}];
masterFile = FileNameJoin[{work, "tmp", Last[names], "masters"}];
gate["final Kira master inventory exists", FileExistsQ[masterFile]];
declaredMasters = toIntegral[ToExpression /@ StringCases[Import[masterFile, "Text"],
  RegularExpression["[A-Z]+\\[[0-9, -]+\\]"]]];
gate["nonempty final Kira master inventory", MatchQ[declaredMasters, {__GLI}]];
rules = toIntegral[rules] /. importRules /. d -> D;
missingTargets = Complement[targets, First /@ rules];
gate["targets without explicit rules are declared masters",
  Complement[missingTargets, declaredMasters] === {}];
rules = Join[rules, (# -> # & /@ missingTargets)];
gate["each target has a reduction rule", Complement[targets, First /@ rules] === {}];
gate["rules have unique targets", DuplicateFreeQ[First /@ rules]];
masters = Sort[DeleteDuplicates[Cases[Last /@ rules, _GLI, Infinity]]];
closureFiles={};closurePass=0;
missingMasters=Complement[masters,declaredMasters];
While[missingMasters=!={} && closurePass<5,
  closurePass++;
  closureName="closure_"<>ToString[closurePass];
  Export[FileNameJoin[{work,closureName}],StringRiffle[integralText /@ missingMasters,"\n"]<>"\n","Text"];
  Export[FileNameJoin[{work,closureName<>".yaml"}],
    "jobs:\n  - kira2math:\n      target:\n        - ["<>closureName<>"]\n","Text"];
  Print["KIRA_EXPORT_CLOSURE ",InputForm[missingMasters]];
  closureRun=RunProcess[{kira,closureName<>".yaml"},All,ProcessDirectory->work];
  Export[FileNameJoin[{work,"s14_"<>closureName<>".log"}],closureRun["StandardOutput"]<>closureRun["StandardError"],"Text"];
  gate["Kira intermediate-integral export completed",closureRun["ExitCode"]===0];
  files=FileNames["kira_"<>closureName<>".m",FileNameJoin[{work,"results"}],Infinity];
  gate["Kira exported the needed intermediate rules",Length[files]>0];
  closureRules=toIntegral[DeleteDuplicates[Flatten[Get /@ files]]] /. importRules /. d->D;
  gate["every intermediate has a non-identity Kira rule",Complement[missingMasters,First /@ closureRules]==={} &&
    And@@(First[#]=!=Last[#]& /@ closureRules)];
  rules=(First[#]->Expand[Last[#] /. closureRules]& /@ rules);
  closureFiles=Join[closureFiles,files];
  masters=Sort[DeleteDuplicates[Cases[Last /@ rules,_GLI,Infinity]]];
  missingMasters=Complement[masters,declaredMasters]];
put[<|"ExportedMasters" -> masters,"FinalInventory" -> declaredMasters,
  "MissingFromInventory" -> Complement[masters,declaredMasters]|>,FileNameJoin[{work,"s14_master_inventory.wl"}]];
gate["every rule ends in Kira's final master inventory",
  Complement[masters, declaredMasters] === {}];
gate["final virtual basis consists of scalar unit-index masters",
  And @@ (Complement[#[[2]],{0,1}] === {} & /@ masters)];
gate["rule coefficients are rational in symbolic dimension and invariants",
  FreeQ[rules, _Real | $Failed | $Aborted]];
(* END REFERENCE UV KIRA WORKFLOW *)
gate["unchanged auxiliary master basis", Sort[masters] === Sort[baseline["Masters"]]];
Do[gate["original UV rule " <> ToString[First[row], InputForm],
  bounded[zero[(First[row] /. rules) - Last[row]], {"original UV rule comparison", First[row]}]], {row, baseline["Rules"]}];
gate["recorded new targets reduced", Complement[additionalTargets, First /@ rules] === {}];
completedPackets = Map[Function[packet, Module[{value},
  value = bounded[Factor[Together[Total[KeyValueMap[Times, packet["Coefficients"]]] /. (rules /. Q2 -> Q^2)]], "recorded UV coefficient map"];
  gate["recorded coefficient map contains only accepted masters", Complement[Union[Cases[value, _GLI, Infinity]], masters] === {}];
  <|"Coefficients" -> packet["Coefficients"], "Reduced" -> value|>]], packets];
result = <|"Schema" -> "polarized-sidis-uv-reduction-extension-v1", "Channel" -> channel,
  "Rules" -> rules, "Masters" -> masters, "Targets" -> targets, "AdditionalTargets" -> additionalTargets,
  "Families" -> families, "Bounds" -> bounds, "CompletedPackets" -> completedPackets,
  "MappingInputHash" -> First[mappingInputHashes], "BaselineReductionHash" -> FileHash[baselinePath, "SHA256"],
  "MasterValuesHash" -> FileHash[mastersPath, "SHA256"], "OriginalSourceHash" -> FileHash[originalSource, "SHA256"],
  "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "KiraHash" -> FileHash[kira, "SHA256"], "FermatHash" -> FileHash[fermat, "SHA256"],
  "WorkDirectory" -> work, "RuleFiles" -> ruleFiles, "ClosureRuleFiles" -> closureFiles,
  "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
put[result, FileNameJoin[{resultDir, "s13_result.wl"}]];
gate["exact saved UV extension roundtrip", Get[FileNameJoin[{resultDir, "s13_result.wl"}]] === result];
Export[FileNameJoin[{resultDir, "s13_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "additional_target_count" -> Length[additionalTargets], "master_count" -> Length[masters],
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s13_extend_uv_reduction"]; Quit[0];

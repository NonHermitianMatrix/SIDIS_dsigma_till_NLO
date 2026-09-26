(* Extend the actual polarized cut targets with the unchanged GitHub S04 workflow. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
sourcePath = FileNameJoin[{root, "common", "s08_extend_real_reduction.wls"}];
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
mapPath = FileNameJoin[{root, channel, "s08_targets_result", "s08_result.wl"}];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
configPath = FileNameJoin[{root, "common", "s08_extension_inputs.json"}];
map = Get[mapPath]; library = Get[libraryPath]; settings = Import[configPath, "RawJSON"];
gate["accepted complete real target map", map["Schema"] === "polarized-sidis-real-target-map-v1" &&
  map["Channel"] === channel && TrueQ[map["MappingAccepted"]] && And @@ Values[map["Checks"]]];
gate["accepted unchanged scalar library", library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
gate["known real extension configuration", settings["schema"] === "polarized-sidis-real-extension-inputs-v1"];
KeyValueMap[Function[{path, hash}, gate["mapped physical input " <> path,
  FileHash[FileNameJoin[{root, path}], "SHA256"] === hash]], map["InputHashes"]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
geometry = readLibrary["s02"]; baseline = readLibrary["s04"];
gate["accepted cut geometry and original reduction", TrueQ[geometry["Accepted"]] && TrueQ[baseline["Accepted"]]];
gate["original positive-energy support", baseline["CutEnergyConditions"] === geometry["CutEnergyConditions"]];
originalSource = FileNameJoin[{root, "common", "s06_result", "reference", "sources", "s04_reduce_real.wl"}];
mapperSources = {FileNameJoin[{root, "common", "s08_map_real_targets.wls"}],
  FileNameJoin[{root, "common", "s08_map_grouped_real_targets.wls"}],
  FileNameJoin[{root, "common", "s08_result", "reference", "s08_map_real_targets_before_memory_resume.wls"}]};
mapperSource = SelectFirst[mapperSources,
  FileExistsQ[#] && FileHash[#, "SHA256"] === map["SourceHash"] &, Missing["UnboundMapperSource"]];
gate["exact executed target-mapping source retained", StringQ[mapperSource]];
previousMapperSource = FileNameJoin[{root, "common", "s08_result", "reference", "s08_map_real_spin_before_known_denominator.wls"}];
gate["original reduction source binding", baseline["SourceHash"] === FileHash[originalSource, "SHA256"]];
gate["accepted target-mapping source binding", map["SourceHash"] === FileHash[mapperSource, "SHA256"] &&
  map["MapperSourceHash"] === FileHash[previousMapperSource, "SHA256"]];
targets = Union[baseline["Targets"], First /@ baseline["Rules"], baseline["Masters"], map["Targets"]];
names = Sort[DeleteDuplicates[targets[[All, 1]]]];
gate["every requested target has an inherited cut family", Complement[names, Keys[geometry["Families"]]] === {}];
families = KeyTake[geometry["Families"], names];
gate["all new spin targets requested", Complement[map["Targets"], targets] === {}];
kira = settings["kira"]["path"]; fermat = settings["fermat"]["path"];
Do[gate["reviewed executable " <> name, IntegerString[FileHash[settings[name]["path"], "SHA256"], 16, 64] === settings[name]["sha256"]],
  {name, {"kira", "fermat"}}];
SetEnvironment["FERMATPATH" -> fermat];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = Join[{mapPath, libraryPath, configPath, originalSource, mapperSource, previousMapperSource},
  (FileNameJoin[{root, library["Library"][#]["File"]}] &) /@ {"s02", "s04"}];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, FileHash[kira, "SHA256"], FileHash[fermat, "SHA256"]}, "SHA256"];
work = FileNameJoin[{root, "cache", "s08_extension", channel, IntegerString[inputHash, 16]}];
config = FileNameJoin[{work, "config"}];
If[!DirectoryQ[config], CreateDirectory[config, CreateIntermediateDirectories -> True]];
originalText = Import[originalSource, "Text"]; ownText = Import[sourcePath, "Text"];
originalBlock = StringTake[originalText, {First[First[StringPosition[originalText, "text[expression_] :="]]],
  First[First[StringPosition[originalText, "resultFile = FileNameJoin"]]] - 1}];
ownBlock = StringTake[ownText, {Last[First[StringPosition[ownText, "\n(* BEGIN REFERENCE KIRA WORKFLOW *)\n"]]] + 1,
  First[First[StringPosition[ownText, "\n(* END REFERENCE KIRA WORKFLOW *)\n"]]] - 1}];
gate["unchanged complete real Kira configuration and reader", StringTrim[originalBlock] === StringTrim[ownBlock]];
(* BEGIN REFERENCE KIRA WORKFLOW *)
text[expression_] := StringReplace[ToString[InputForm[expression]], Whitespace -> ""];
csv[list_] := "[" <> StringRiffle[text /@ list, ","] <> "]";
integralText[integral_] := integral[[1]] <> csv[integral[[2]]];
external = Take[geometry["BasisMomenta"], Length[geometry["BasisMomenta"]] -
  Length[geometry["CutMomenta"]] + 1];
externalGram = geometry["CommonGram"][[Range[Length[external]], Range[Length[external]]]];
invariants = Sort[DeleteDuplicates[Cases[externalGram,
  symbol_Symbol /; Context[symbol] === "Global`", Infinity]]];
(* Fermat requires lower-case variable names. This is a name change only. *)
exportRules = {Q2 -> q2};
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
Do[
  spec = families[name];
  actual = Select[targets, #[[1]] === name &][[All, 2]];
  positiveSums = Total[Select[#, # > 0 &]] & /@ actual;
  negativeSums = -Total[Select[#, # < 0 &]] & /@ actual;
  sectors = Sort[DeleteDuplicates[Total[MapIndexed[
    If[#1 > 0, 2^(First[#2] - 1), 0] &, #]] & /@ actual]];
  topSectors = Select[sectors, Function[sector, !AnyTrue[DeleteCases[sectors, sector],
    BitAnd[sector, #] === sector &]]];
  rBound = Max[positiveSums] + Length[spec["LoopMomenta"]];
  sBound = Max[negativeSums];
  AssociateTo[bounds, name -> <|"r" -> rBound, "s" -> sBound,
    "Sectors" -> sectors, "TopSectors" -> topSectors, "TargetCount" -> Length[actual]|>];
  familyLines = Join[familyLines, {"  - name: " <> name,
    "    loop_momenta: " <> csv[spec["LoopMomenta"]],
    "    top_level_sectors: " <> csv[topSectors], "    propagators:"},
    MapThread["      - [\"" <> text[#1] <> "\", " <> text[#2] <> "]" &,
      {spec["PropagatorMomenta"], spec["PropagatorMassesSquared"]}],
    {"    cut_propagators: " <> csv[spec["CutPositions"]]}];
  AppendTo[reductions, "        - {topologies: [" <> name <> "], sectors: " <>
    csv[topSectors] <> ", r: " <> text[rBound] <> ", s: " <> text[sBound] <> "}"];
  preferred = Join[preferred, Table[CutIntegral[name,
    Table[If[MemberQ[spec["CutPositions"], i] || MemberQ[support, i], 1, 0],
      {i, Length[spec["PropagatorMomenta"]]}]],
    {support, Subsets[Complement[Range[Length[spec["PropagatorMomenta"]]], spec["CutPositions"]]]}]],
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
  "CutEnergyConditions" -> geometry["CutEnergyConditions"]|>, FileNameJoin[{work, "s04_configuration.wl"}]];
Print["KIRA_START ", work, " target count ", Length[targets], " bounds ", InputForm[bounds]];
run = RunProcess[{kira, "--parallel=2", "jobs.yaml"}, All, ProcessDirectory -> work];
Export[FileNameJoin[{work, "s04_kira_stdout.log"}], run["StandardOutput"], "Text"];
Export[FileNameJoin[{work, "s04_kira_stderr.log"}], run["StandardError"], "Text"];
Print[StringTake[run["StandardOutput"], -Min[12000, StringLength[run["StandardOutput"]]]]];
If[run["StandardError"] =!= "", Print[run["StandardError"]]];
gate["Kira completed", run["ExitCode"] === 0];
ruleFiles = Sort[FileNames["kira_*.m", FileNameJoin[{work, "results"}], Infinity]];
gate["Kira exported symbolic rules", Length[ruleFiles] > 0];
rules = DeleteDuplicates[Flatten[Get /@ ruleFiles]];
gate["Kira output consists of rules", MatchQ[rules, {__Rule}]];
heads = Symbol /@ names;
toCut[expression_] := expression /. (HoldPattern[h_[indices__Integer]] /; MemberQ[heads, h]) :>
  CutIntegral[SymbolName[h], {indices}];
masterFile = FileNameJoin[{work, "tmp", Last[names], "masters"}];
gate["final Kira master inventory exists", FileExistsQ[masterFile]];
declaredMasters = toCut[ToExpression /@ StringCases[Import[masterFile, "Text"],
  RegularExpression["R[0-9]+\\[[0-9, -]+\\]"]]];
gate["nonempty final Kira master inventory", MatchQ[declaredMasters, {__CutIntegral}]];
rules = toCut[rules] /. importRules /. d -> D;
missingTargets = Complement[targets, First /@ rules];
gate["targets without explicit rules are declared masters",
  Complement[missingTargets, declaredMasters] === {}];
rules = Join[rules, (# -> # & /@ missingTargets)];
gate["each target has a reduction rule", Complement[targets, First /@ rules] === {}];
gate["rules have unique targets", DuplicateFreeQ[First /@ rules]];
masters = Sort[DeleteDuplicates[Cases[Last /@ rules, _CutIntegral, Infinity]]];
gate["every rule ends in Kira's final master inventory",
  Complement[masters, declaredMasters] === {}];
gate["both cut propagators survive in every master", And @@
  (And @@ (# > 0 & /@ #[[2, families[#[[1]]]["CutPositions"]]]) & /@ masters)];
gate["rule coefficients are rational in symbolic dimension and invariants",
  FreeQ[rules, _Real | $Failed | $Aborted]];

(* END REFERENCE KIRA WORKFLOW *)
gate["unchanged complete original cut-master basis", Sort[masters] === Sort[baseline["Masters"]]];
Do[gate["original Kira rule " <> ToString[First[row], InputForm],
  bounded[zero[(First[row] /. rules) - Last[row]], {"original cut-rule comparison", First[row]}]], {row, baseline["Rules"]}];
gate["complete actual spin-target coverage", Complement[map["Targets"], First /@ rules] === {}];
resultDir = FileNameJoin[{root, channel, "s08_reduction_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
result = <|"Schema" -> "polarized-sidis-real-reduction-extension-v1", "Channel" -> channel,
  "Rules" -> rules, "Masters" -> masters, "Targets" -> targets, "AdditionalTargets" -> map["MissingTargets"],
  "Bounds" -> bounds, "Families" -> families, "CutEnergyConditions" -> geometry["CutEnergyConditions"],
  "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "GeometryHash" -> FileHash[FileNameJoin[{root, library["Library"]["s02"]["File"]}], "SHA256"],
  "BaselineReductionHash" -> FileHash[FileNameJoin[{root, library["Library"]["s04"]["File"]}], "SHA256"],
  "MappingArtifactHash" -> FileHash[mapPath, "SHA256"],
  "KiraHash" -> FileHash[kira, "SHA256"], "FermatHash" -> FileHash[fermat, "SHA256"],
  "WorkDirectory" -> work, "RuleFiles" -> ruleFiles, "Checks" -> checks, "Accepted" -> True,
  "MasterEvaluationPerformed" -> False, "FiniteNLOFHatsComputed" -> False|>;
put[result, FileNameJoin[{resultDir, "s08_reduction.wl"}]];
Export[FileNameJoin[{resultDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "additional_target_count" -> Length[map["MissingTargets"]], "target_count" -> Length[targets],
  "missing_target_count" -> Length[Complement[map["Targets"], First /@ rules]],
  "master_count" -> Length[masters], "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_extend_real_reduction"]; Quit[0];

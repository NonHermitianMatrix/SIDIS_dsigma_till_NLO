(* Complete only uncovered polarized virtual targets using the original Kira workflow. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
sourcePath = FileNameJoin[{root, "common", "s09_extend_virtual_reduction.wls"}];
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
merge[pieces_List] := If[pieces === {}, <||>, Select[Merge[pieces, Factor[Together[Total[#]]] &], # =!= 0 &]];
mapPath = FileNameJoin[{root, channel, "s09_result", "s09_result.wl"}];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
configPath = FileNameJoin[{root, "common", "s09_extension_inputs.json"}];
map = Get[mapPath]; library = Get[libraryPath]; settings = Import[configPath, "RawJSON"];
gate["accepted exact virtual map", map["Schema"] === "polarized-sidis-virtual-scalar-map-v1" &&
  map["Channel"] === channel && TrueQ[map["MappingAccepted"]] && And @@ Values[map["Checks"]]];
gate["accepted unchanged scalar library", library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
geometry = readLibrary["s02"]; baseline = readLibrary["s09"]; parents = readLibrary["s12"]; evaluations = readLibrary["s13"];
gate["accepted reduction and master inputs", baseline["Accepted"] && parents["Accepted"] && evaluations["AcceptedEuclideanParents"]];
originalSource = FileNameJoin[{root, "common", "s06_result", "reference", "sources", "s09_reduce_virtual.wl"}];
gate["original reduction source binding", baseline["SourceHash"] === FileHash[originalSource, "SHA256"]];
mapperSource = FileNameJoin[{root, "common", "s09_map_virtual_spin.wls"}];
gate["original spin mapping source binding", map["SourceHash"] === FileHash[mapperSource, "SHA256"]];
external = geometry["ExternalMomenta"];
externalGram = Take[geometry["CommonGram"], {1, Length[external]}, {1, Length[external]}] /. w -> 0;
families = baseline["Families"]; changes = baseline["Canonicalization"]; canonicalRules = baseline["CanonicalizationRules"];
targets = Union[baseline["Targets"], First /@ baseline["Rules"], baseline["Masters"], map["Targets"]]; names = Sort[Keys[families]];
gate["every polarized target is covered by the requested extension", Complement[map["Targets"], targets, baseline["Masters"]] === {}];
gate["every requested target has an inherited family", Complement[targets[[All, 1]], names] === {}];
kira = settings["kira"]["path"]; fermat = settings["fermat"]["path"];
Do[gate["reviewed executable " <> name, IntegerString[FileHash[settings[name]["path"], "SHA256"], 16, 64] === settings[name]["sha256"]],
  {name, {"kira", "fermat"}}];
SetEnvironment["FERMATPATH" -> fermat];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = Join[{mapPath, libraryPath, configPath, originalSource, mapperSource},
  (FileNameJoin[{root, library["Library"][#]["File"]}] &) /@ {"s02", "s09", "s12", "s13"}];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, FileHash[kira, "SHA256"], FileHash[fermat, "SHA256"]}, "SHA256"];
work = FileNameJoin[{root, "cache", "s09_extension", channel, IntegerString[inputHash, 16]}];
config = FileNameJoin[{work, "config"}];
If[!DirectoryQ[config], CreateDirectory[config, CreateIntermediateDirectories -> True]];
originalText = Import[originalSource, "Text"]; ownText = Import[sourcePath, "Text"];
originalBlock = StringTake[originalText, {First[First[StringPosition[originalText, "text[expression_] :="]]],
  First[First[StringPosition[originalText, "resultFile = FileNameJoin"]]] - 1}];
ownBlock = StringTake[ownText, {Last[First[StringPosition[ownText, "\n(* BEGIN REFERENCE KIRA WORKFLOW *)\n"]]] + 1,
  First[First[StringPosition[ownText, "\n(* END REFERENCE KIRA WORKFLOW *)\n"]]] - 1}];
gate["unchanged complete Kira configuration and reader", StringTrim[originalBlock] === StringTrim[ownBlock]];
(* BEGIN REFERENCE KIRA WORKFLOW *)
text[expression_] := StringReplace[ToString[InputForm[expression]], Whitespace -> ""];
csv[list_] := "[" <> StringRiffle[text /@ list, ","] <> "]";
integralText[integral_] := integral[[1]] <> csv[integral[[2]]];
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
    MapThread["      - [\"" <> text[#1] <> "\", " <> text[#2] <> "]" &,
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
  "Canonicalization" -> changes, "CanonicalizationRules" -> canonicalRules|>, FileNameJoin[{work, "s09_configuration.wl"}]];
Print["KIRA_START ", work, " target count ", Length[targets], " bounds ", InputForm[bounds]];
run = RunProcess[{kira, "--parallel=2", "jobs.yaml"}, All, ProcessDirectory -> work];
Export[FileNameJoin[{work, "s09_kira_stdout.log"}], run["StandardOutput"], "Text"];
Export[FileNameJoin[{work, "s09_kira_stderr.log"}], run["StandardError"], "Text"];
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
  RegularExpression["V[0-9]+\\[[0-9, -]+\\]"]]];
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
  Export[FileNameJoin[{work,"s09_"<>closureName<>".log"}],closureRun["StandardOutput"]<>closureRun["StandardError"],"Text"];
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
  "MissingFromInventory" -> Complement[masters,declaredMasters]|>,FileNameJoin[{work,"s09_master_inventory.wl"}]];
gate["every rule ends in Kira's final master inventory",
  Complement[masters, declaredMasters] === {}];
gate["final virtual basis consists of scalar unit-index masters",
  And @@ (Complement[#[[2]],{0,1}] === {} & /@ masters)];
gate["rule coefficients are rational in symbolic dimension and invariants",
  FreeQ[rules, _Real | $Failed | $Aborted]];
(* END REFERENCE KIRA WORKFLOW *)
gate["unchanged complete original master basis", Sort[masters] === Sort[baseline["Masters"]]];
Do[gate["original Kira rule " <> ToString[First[row], InputForm],
  bounded[zero[(First[row] /. rules) - Last[row]], {"original reduction comparison", First[row]}]], {row, baseline["Rules"]}];
resultDir = FileNameJoin[{root, channel, "s09_reduction_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
reductionPath = FileNameJoin[{resultDir, "s09_reduction.wl"}];
put[<|"Schema" -> "polarized-sidis-virtual-reduction-extension-v1", "Rules" -> rules, "Masters" -> masters,
  "Targets" -> targets, "AdditionalTargets" -> map["MissingTargets"], "Bounds" -> bounds, "Families" -> families,
  "Canonicalization" -> changes, "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "BaselineReductionHash" -> FileHash[FileNameJoin[{root, library["Library"]["s09"]["File"]}], "SHA256"],
  "KiraHash" -> FileHash[kira, "SHA256"], "FermatHash" -> FileHash[fermat, "SHA256"],
  "WorkDirectory" -> work, "RuleFiles" -> ruleFiles, "ClosureRuleFiles" -> closureFiles,
  "Checks" -> checks, "Accepted" -> True|>, reductionPath];
completeCoefficients[coefficients_] := Module[{expression, remaining, values},
  expression = Total[KeyValueMap[Times, coefficients]] /. (rules /. Q2 -> Q^2);
  remaining = Union[Cases[expression, _GLI, Infinity]];
  gate["completed component uses only accepted masters", Complement[remaining, baseline["Masters"]] === {}];
  values = AssociationMap[Factor[Coefficient[Expand[expression], #]] &, remaining];
  gate["complete linear reduction reconstruction", zero[expression - Total[KeyValueMap[Times, values]]]];
  Select[values, # =!= 0 &]];
diagrams = Table[Join[diagram, <|"Components" -> Table[
  Join[component, <|"ReducedCoefficients" -> bounded[completeCoefficients[component["ReducedCoefficients"]],
    {diagram["Diagram"], component["Kind"], component["Index"]}], "MissingTargets" -> {}|>],
  {component, diagram["Components"]}]|>], {diagram, map["Diagrams"]}];
(* BEGIN INHERITED COMPONENT ASSEMBLY *)
allComponents = Flatten[Lookup[diagrams, "Components"], 1];
componentKeys = DeleteDuplicates[({#["Kind"], #["Index"]} &) /@ allComponents];
components = Association@Table[key -> merge[Lookup[Select[allComponents, {#["Kind"], #["Index"]} === key &], "ReducedCoefficients"]],
  {key, componentKeys}];
targets = Union[Flatten[Keys /@ Lookup[allComponents, "Coefficients"]]];
missingTargets = Union[Flatten[Lookup[allComponents, "MissingTargets"]]];
valuation[expression_] := If[expression === 0, Infinity, With[{rational = Together[expression /. D -> 4 - 2 eps]},
  Exponent[Numerator[rational], eps, Min] - Exponent[Denominator[rational], eps, Min]]];
requiredOrders = Merge[(Map[If[# === Infinity, 0, Max[0, -#]] &, Map[valuation, #]] &) /@ Values[components], Max];
masterCoverage = missingTargets === {};
depthCoverage = masterCoverage && And @@ KeyValueMap[Function[{master, order},
  With[{series = evaluations["Parents"][parents["VirtualMasterParents"][master]["ParentID"]]["Series"]},
    MatchQ[series, _SeriesData] && series[[5]] > order]], requiredOrders];
(* END INHERITED COMPONENT ASSEMBLY *)
gate["complete spin reduction coverage", masterCoverage];
gate["sufficient existing virtual master depth", depthCoverage];
result = Join[map, <|"Diagrams" -> diagrams, "Components" -> components,
  "MissingTargets" -> missingTargets, "RequiredOrders" -> requiredOrders,
  "ReductionCoverageComplete" -> masterCoverage, "MasterExpansionDepthSufficient" -> depthCoverage,
  "SourceHash" -> sourceHash, "InputHash" -> inputHash,
  "InputHashes" -> Join[map["InputHashes"], inputHashes], "MappingSourceHash" -> map["SourceHash"],
  "MappingArtifactHash" -> FileHash[mapPath, "SHA256"], "ReductionArtifactHash" -> FileHash[reductionPath, "SHA256"],
  "Checks" -> Join[map["Checks"], checks], "FiniteNLOFHatsComputed" -> False|>];
put[result, FileNameJoin[{resultDir, "s09_result.wl"}]];
Export[FileNameJoin[{resultDir, "s09_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "additional_target_count" -> Length[map["MissingTargets"]], "missing_target_count" -> Length[missingTargets],
  "master_count" -> Length[masters], "master_expansion_depth_sufficient" -> depthCoverage,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s09_extend_virtual_reduction"]; Quit[0];

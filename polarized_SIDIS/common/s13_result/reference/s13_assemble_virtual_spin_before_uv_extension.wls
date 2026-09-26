(* Physical loop integration and the reference auxiliary-mass UV subtraction. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s13_assemble_virtual_spin.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
validationOnly = Environment["POLARIZED_SIDIS_VALIDATE_ONLY"] === "1";
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "S13Failure"], CloseKernels[]; Quit[1]]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate["time bound " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory bound " <> ToString[label, InputForm], False]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
configPath = FileNameJoin[{root, "common", "s13_inputs.json"}];
config = Import[configPath, "RawJSON"];
Do[gate["pinned assembly input " <> row["destination"], IntegerString[
  FileHash[FileNameJoin[{root, row["destination"]}], "SHA256"], 16, 64] === row["sha256"]], {row, config["files"]}];
referenceRoot = FileNameJoin[{root, "common", "s13_result", "reference"}];
referenceVirtual = Get[FileNameJoin[{referenceRoot, "Hqq_virtual.wl"}]];
physicalMasters = Get[FileNameJoin[{referenceRoot, "s19_masters.wl"}]];
originalAssemblyHash = FileHash[FileNameJoin[{referenceRoot, "s19_assemble_virtual.wl"}], "SHA256"];
gate["accepted original physical assembly", TrueQ[referenceVirtual["Accepted"]] &&
  referenceVirtual["SourceHash"] === originalAssemblyHash &&
  referenceVirtual["MasterFile"] === config["original_master_file"]];
gate["physical master input binding", physicalMasters["InputHash"] ===
  Hash[{originalAssemblyHash, referenceVirtual["InputHashes"]}, "SHA256"]];
gate["accepted physical continuation records", AllTrue[physicalMasters["ContinuationRecords"],
  TrueQ[#["Accepted"]] && #["SourceHash"] === originalAssemblyHash &&
    #["InputHash"] === physicalMasters["InputHash"] &&
    #["Series"] === physicalMasters["Masters"][#["Master"]] &]];
libraryPath = FileNameJoin[{root, "common", "s06_result", "s06_result.wl"}];
library = Get[libraryPath];
gate["accepted scalar library", library["Schema"] === "polarized-sidis-scalar-library-v1" && And @@ Values[library["Checks"]]];
readLibrary[stage_] := Module[{row, path}, row = library["Library"][stage]; path = FileNameJoin[{root, row["File"]}];
  gate[stage <> " unchanged scalar input", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["SHA256"]]; Get[path]];
geometry = readLibrary["s02"] /. Q2 -> Q^2;
parents = readLibrary["s12"];
uv = readLibrary["s14"] /. Q2 -> Q^2;
Do[gate["physical assembly original input " <> stage,
  referenceVirtual["InputHashes"][stage <> "_result.wl"] ===
    FileHash[FileNameJoin[{root, library["Library"][stage]["File"]}], "SHA256"]],
  {stage, {"s12", "s13", "s14"}}];
uvReduction = Get[FileNameJoin[{referenceRoot, "s14_reduction.wl"}]] /. Q2 -> Q^2;
masterValues = Get[FileNameJoin[{referenceRoot, "s14_master_values.wl"}]] /. Q2 -> Q^2;
gate["unchanged master parent inventory", Sort[Keys[physicalMasters["Masters"]]] === Sort[Keys[parents["VirtualMasterParents"]]]];
gate["accepted auxiliary UV reduction", TrueQ[uvReduction["Accepted"]] &&
  uvReduction["InputHash"] === uv["InputHash"] && uvReduction["SourceHash"] === uv["SourceHash"]];
gate["complete auxiliary master values", Sort[Keys[masterValues]] === Sort[uvReduction["Masters"]] &&
  AllTrue[Values[masterValues], MatchQ[#, _SeriesData] &]];
virtualConfigPath = FileNameJoin[{root, "common", "s07_inputs.json"}];
virtualConfig = Import[virtualConfigPath, "RawJSON"];
gate["core virtual channel", KeyExistsQ[virtualConfig["channels"], channel]];
referencePath = FileNameJoin[{root, virtualConfig["channels"][channel]["destination"]}];
gate["pinned original virtual integrands", IntegerString[FileHash[referencePath, "SHA256"], 16, 64] ===
  virtualConfig["channels"][channel]["sha256"]];
reference = Get[referencePath];
gate["accepted original virtual map", TrueQ[reference["Accepted"]]];
physical = Q > 0 && s > 0 && t < 0 && Q^2 + s + t > 0 && mu > 0 && SUNN > 1;
reduce[value_] := Module[{refined, functions},
  refined = Refine[value, physical];
  functions = DeleteDuplicates[Cases[refined, _Log | _PolyLog | _Re | _Im, Infinity]];
  Collect[Expand[refined], functions, Factor]];

(* BEGIN UNCHANGED REFERENCE UV MAP *)
external={p,q,k1};externalGram=geometry["CommonGram"][[1;;3,1;;3]] /. w->0;
setKinematics[] := (FCClearScalarProducts[];
  Do[With[{left=external[[i]],right=external[[j]],value=externalGram[[i,j]]},
    SPD[left,right]=value],{i,Length[external]},{j,i,Length[external]}]);
setKinematics[];
loopProducts=FCI[SPD[ell,#]]& /@ Prepend[external,ell];
loopVariables=Array[uvx,Length[loopProducts]];
scalarRules=Thread[loopProducts->loopVariables];
coordinateVariables=Array[uvz,Length[loopProducts]];
families=<|
  "OS"-><|"Momenta"->{ell,ell+p,ell+q,ell+k1},"Masses"->{0,0,0,0}|>,
  "SE"-><|"Momenta"->{ell,ell+q,ell+p,ell+k1},"Masses"->{0,0,0,0}|>,
  "UV"-><|"Momenta"->{ell,ell+p,ell+q,ell+k1},"Masses"->{M2,M2,M2,M2}|>|>;
familyMaps=Association@KeyValueMap[Function[{id,data},Module[{polynomials,solution},
  polynomials=MapThread[ExpandScalarProduct[FCI[SPD[#1,#1]]]-#2 &,
    {data["Momenta"],data["Masses"]}] /. scalarRules;
  solution=Solve[Thread[polynomials==coordinateVariables],loopVariables];
  gate[id<>" unique loop scalar coordinate map",Length[solution]===1];
  id-><|"Polynomials"->polynomials,"Rules"->First[solution]|>]],families];
mapScalar[expression_,id_] := Module[{mapped,terms,coefficient,powers,values,reconstructed},
  If[expression===0,Return[<||>]];
  mapped=Expand[Cancel[expression /. familyMaps[id]["Rules"]]];
  terms=If[Head[mapped]===Plus,List@@mapped,{mapped}];
  values=Map[Function[term,
    powers=Table[Exponent[Numerator[Together[term]],z]-Exponent[Denominator[Together[term]],z],
      {z,coordinateVariables}];
    coefficient=Factor[term/(Times@@(coordinateVariables^powers))];
    gate[id<>" scalar coefficient has no loop coordinates",FreeQ[coefficient,Alternatives@@coordinateVariables]];
    GLI[id,-powers]->coefficient],terms];
  values=Map[Factor[Together[#]]&,Merge[Association /@ values,Total]];
  reconstructed=Total[KeyValueMap[#2 Times@@(familyMaps[id]["Polynomials"]^(-#1[[2]]))&,values]];
  gate[id<>" exact scalar-integrand reconstruction",zero[reconstructed-expression]];values];
toScalars[value_] := Factor[Together[ExpandScalarProduct[FeynAmpDenominatorExplicit[value]] /. scalarRules]];
uvExpansion[value_,label_] := Module[{rational,scaling,series,firstPower,pieces,regularized},
  rational=toScalars[value];If[rational===0,Return[<||>]];
  gate[label<>" closed scalar loop integrand",FreeQ[rational,_Pair|_FeynAmpDenominator|ell]];
  scaling=Thread[loopVariables->MapIndexed[#1 lam^(-If[First[#2]===1,2,1])&,loopVariables]];
  series=bounded[Normal[Series[rational /. scaling,{lam,0,4}]],label<>" UV expansion"];
  If[series===0,Return[<||>]];
  firstPower=Exponent[series,lam,Min];
  pieces=Association@Table[power->Factor[Coefficient[series,lam,power]],{power,firstPower,4}];
  regularized=Map[Function[piece,Expand[piece] /.
    Power[uvx[1],n_Integer /; n<0] :> (uvx[1]-M2)^n],pieces];
  gate[label<>" auxiliary mass leaves logarithmic asymptotics unchanged",
    zero[Coefficient[Normal[Series[(regularized[4]-pieces[4]) /. scaling,{lam,0,4}]],lam,4]]];
  Association@KeyValueMap[#1->mapScalar[#2,"UV"]&,regularized]];
(* END UNCHANGED REFERENCE UV MAP *)

uvSource = FileNameJoin[{root, "common", "s06_result", "reference", "sources", "s14_uv_residues.wl"}];
originalUVText = Import[uvSource, "Text"];
originalUVBlock = StringTake[originalUVText, {First[First[StringPosition[originalUVText, "external={p,q,k1};"]]],
  First[First[StringPosition[originalUVText, "(* Generate the two-point functions"]]] - 1}];
ownText = Import[sourcePath, "Text"];
ownUVBlock = StringTake[ownText, {Last[First[StringPosition[ownText, "(* BEGIN UNCHANGED REFERENCE UV MAP *)"]]] + 1,
  First[First[StringPosition[ownText, "(* END UNCHANGED REFERENCE UV MAP *)"]]] - 1}];
gate["byte-identical reference UV expansion", StringTrim[originalUVBlock] === StringTrim[ownUVBlock]];
gate["original UV source identity", FileHash[uvSource, "SHA256"] === uv["SourceHash"]];
ruleMap = Association[uvReduction["Rules"]];
measure = uv["Measure"];
gate["virtual and UV measures coincide", zero[(reference["Measure"] /. Epsilon -> eps) - measure]];
reduceMap[coefficients_] := Module[{missing, value},
  missing = Complement[Keys[coefficients], Keys[ruleMap]];
  If[missing =!= {}, put[<|"MissingTargets" -> missing, "Coefficients" -> coefficients,
    "Families" -> families, "InputHash" -> inputHash|>, FileNameJoin[{cache, "missing_uv_targets_" <> ToString[$KernelID] <> ".wl"}]]];
  gate["auxiliary Kira target coverage", missing === {}];
  value = Factor[Together[Total[KeyValueMap[#2 ruleMap[#1] &, coefficients]]]];
  gate["auxiliary reduction master coverage", Complement[Union[Cases[value, _GLI, Infinity]], Keys[masterValues]] === {}];
  value];
uvPole[coefficients_] := Module[{integrated, series},
  integrated = reduceMap[coefficients] /. D -> 4 - 2 eps /. Normal[masterValues];
  series = Series[measure integrated, {eps, 0, 0}];
  gate["UV residue expansion depth", series === 0 || (MatchQ[series, _SeriesData] && series[[5]] > -1)];
  Factor[Coefficient[Normal[series], eps, -1]]];
uvFromPowers[powers_, label_] := Module[{residues, physicalResidues},
  If[Length[powers] === 0, Return[0]];
  residues = Map[uvPole, powers];
  physicalResidues = Map[FullSimplify[Limit[#, M2 -> 0, Direction -> "FromAbove"], physical] &, residues];
  KeyValueMap[If[#1 < 4, gate[label <> " power-divergent auxiliary terms vanish", #2 === 0]] &, physicalResidues];
  gate[label <> " logarithmic residue independent of auxiliary mass", FreeQ[Lookup[residues, 4, 0], M2]];
  Factor[Total[Values[physicalResidues]]]];
sourceHash = FileHash[sourcePath, "SHA256"];
parallelValidationOnly = Environment["POLARIZED_SIDIS_UV_PARALLEL_VALIDATE_ONLY"] === "1";
serialPath = FileNameJoin[{referenceRoot, "s13_assemble_virtual_spin_before_parallel_uv.wls"}];
calculationSourceHash = FileHash[serialPath, "SHA256"];
gate["pinned serial calculation", IntegerString[calculationSourceHash, 16, 64] ===
  "930cb13c80514b51fbd2ae017feee7b1adac813651670e779258156f161aae6f"];
serialText = Import[serialPath, "Text"];
sourceSection[text_, start_, end_] := StringTake[text,
  {First[First[StringPosition[text, start]]], First[First[StringPosition[text, end]]] - 1}];
gate["unchanged complete virtual and UV definitions", StringTake[ownText,
    First[First[StringPosition[ownText, "\nsourceHash = FileHash"]]] - 1] ===
  StringReplace[StringTake[serialText, First[First[StringPosition[serialText, "\nsourceHash = FileHash"]]] - 1], {
    "Print[\"FAIL: \", name]; Quit[1]];" ->
      "Print[\"FAIL: \", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, \"S13Failure\"], CloseKernels[]; Quit[1]]];",
    "\"missing_uv_targets.wl\"" -> "\"missing_uv_targets_\" <> ToString[$KernelID] <> \".wl\""}]];
gate["unchanged inputs and checkpoint identity",
  sourceSection[ownText, "\ninputPaths = Join[", "\nuvTask[value_, label_]"] ===
    StringReplace[sourceSection[serialText, "\ninputPaths = Join[", "\nuvTask[value_, label_]"],
      "Hash[{sourceHash, inputHashes," -> "Hash[{calculationSourceHash, inputHashes,"]];
gate["unchanged task and reference comparison implementation",
  sourceSection[ownText, "\nuvTask[value_, label_]", "\nspinLoopRules ="] ===
    sourceSection[serialText, "\nuvTask[value_, label_]", "\nspinLoopRules ="]];
gate["unchanged complete final virtual assembly",
  sourceSection[ownText, "\nDo[gate[\"new-spin CDR UV residue", "\nresultDir = FileNameJoin[{root, channel, \"s13_result\"}]"] ===
    StringReplace[sourceSection[serialText, "\nDo[gate[\"new-spin CDR UV residue", "\nresultDir = FileNameJoin[{root, channel, \"s13_result\"}]"],
      "\"SourceHash\" -> sourceHash, \"InputHash\" -> inputHash" ->
        "\"SourceHash\" -> sourceHash, \"CalculationSourceHash\" -> calculationSourceHash, \"ParallelValidationHash\" -> parallelValidationHash, \"InputHash\" -> inputHash"]];

inputPaths = Join[{configPath, libraryPath, virtualConfigPath, referencePath, uvSource},
  (FileNameJoin[{root, #["destination"]}] &) /@ config["files"],
  (FileNameJoin[{root, library["Library"][#]["File"]}] &) /@ {"s02", "s12", "s14"}];
If[!validationOnly,
  spinPath = FileNameJoin[{root, channel, "s07_result", "s07_result.wl"}];
  mapRelative = Environment["POLARIZED_SIDIS_VIRTUAL_MAP"];
  If[!StringQ[mapRelative] || mapRelative === "", mapRelative = channel <> "/s09_result/s09_result.wl"];
  gate["owned virtual reduction input", MemberQ[{channel <> "/s09_result/s09_result.wl",
    channel <> "/s09_reduction_result/s09_result.wl"}, mapRelative]];
  mapPath = FileNameJoin[{root, mapRelative}];
  bornPath = FileNameJoin[{root, channel, "s03_result", "s03_result.wl"}];
  basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
  spin = Get[spinPath]; mapped = Get[mapPath]; born = Get[bornPath]; basis = Get[basisPath];
  gate["accepted spin and Born tensors", spin["Schema"] === "polarized-sidis-virtual-response-v1" &&
    born["Schema"] === "polarized-sidis-born-response-v2" && And @@ Values[spin["Checks"]] && And @@ Values[born["Checks"]]];
  gate["accepted complete virtual reduction", mapped["Schema"] === "polarized-sidis-virtual-scalar-map-v1" &&
    TrueQ[mapped["MappingAccepted"]] && TrueQ[mapped["ReductionCoverageComplete"]] &&
    TrueQ[mapped["MasterExpansionDepthSufficient"]] && And @@ Values[mapped["Checks"]]];
  gate["mapped inputs unchanged", And @@ KeyValueMap[
    FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2 &, mapped["InputHashes"]]];
  gate["mapped spin input identity", mapped["InputHashes"][channel <> "/s07_result/s07_result.wl"] === FileHash[spinPath, "SHA256"]];
  gate["accepted photon and spin basis", And @@ Values[basis["Checks"]]];
  inputPaths = Join[inputPaths, {spinPath, mapPath, bornPath, basisPath}]];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ DeleteDuplicates[inputPaths]];
inputHash = Hash[{calculationSourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s13", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
uvTask[value_, label_] := Module[{file, saved, result},
  file = FileNameJoin[{cache, "uv_" <> IntegerString[Hash[{label, value}, "SHA256"], 16] <> ".wl"}];
  saved = If[FileExistsQ[file], Get[file], <||>];
  If[Lookup[saved, "InputHash", None] === inputHash, Return[saved["Value"]]];
  Print["VIRTUAL_UV ", label];
  result = bounded[uvFromPowers[uvExpansion[value, label], label], label];
  put[<|"Value" -> result, "InputHash" -> inputHash, "Label" -> label|>, file]; result];
referenceResidues = Association@Table[mode -> Factor[Total[Table[
  uvTask[diagram["ContractedIntegrand"] /. Q2 -> Q^2, "reference " <> mode <> " " <> ToString[diagram["Diagram"]]],
  {diagram, Select[reference["DiagramMaps"], #["Mode"] === mode &]}]]], {mode, {"Pg", "Ppp"}}];
Do[gate["original UV residue " <> mode, zero[referenceResidues[mode] - uv["VirtualUVResidues"][channel][mode]]],
  {mode, Keys[referenceResidues]}];
If[validationOnly,
  resultDir = FileNameJoin[{root, channel, "s13_validation_result"}];
  If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
  put[<|"Schema" -> "polarized-sidis-virtual-assembly-validation-v1", "Channel" -> channel,
    "ReferenceUVResidues" -> referenceResidues, "PhysicalMasterCount" -> Length[physicalMasters["Masters"]],
    "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>, FileNameJoin[{resultDir, "s13_result.wl"}]];
  Print["PASS: s13_virtual_assembly_validation"]; Quit[0]];

spinLoopRules = Thread[spin["LoopScalarProducts"][[All, 3]] -> loopVariables];
uvTasks = {};
Do[
  tasks = {};
  MapIndexed[Function[{value, position}, If[value =!= 0,
    AppendTo[tasks, <|"Key" -> {"ExtendedResponse", position}, "Value" -> value|>]]], diagram["ExtendedResponse"], {3}];
  AppendTo[tasks, <|"Key" -> {"PhotonMetricD", {}}, "Value" -> diagram["PhotonMetricD"]|>];
  Do[AppendTo[tasks, <|"Key" -> {"CDR", {mode}}, "Value" -> diagram["CDRContractions"][mode]|>], {mode, {"Pg", "Ppp"}}];
  Do[AppendTo[uvTasks, <|"Key" -> task["Key"], "Value" -> (task["Value"] /. spinLoopRules),
    "Label" -> ("spin " <> ToString[diagram["Diagram"]] <> " " <> ToString[task["Key"], InputForm])|>],
    {task, tasks}], {diagram, spin["Diagrams"]}];
uvCacheFile[task_] := FileNameJoin[{cache,
  "uv_" <> IntegerString[Hash[{task["Label"], task["Value"]}, "SHA256"], 16] <> ".wl"}];
gate["independent UV task checkpoints", DuplicateFreeQ[uvCacheFile /@ uvTasks]];
runUVTask[task_, fresh_:False] := Catch[Block[{checks = <||>}, Module[{value, seconds},
  {seconds, value} = AbsoluteTiming[If[TrueQ[fresh],
    bounded[uvFromPowers[uvExpansion[task["Value"], task["Label"]], task["Label"]], task["Label"]],
    uvTask[task["Value"], task["Label"]]]];
  <|"Key" -> task["Key"], "Label" -> task["Label"], "Value" -> value,
    "Checks" -> checks, "ElapsedSeconds" -> seconds, "Accepted" -> True|>]], "S13Failure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1]; CloseKernels[];
If[slots > 1, TimeConstrained[LaunchKernels[KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60]], 60, $Failed]];
workers = Length[Kernels[]]; Print["Independent UV worker count = ", workers];
If[workers > 0,
  gate["workers share compute allocation", And @@ (SameQ[#, $MachineName] & /@ ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength = 0; checks = <||>;
    PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages = False; Get["FeynCalc`"]];
  DistributeDefinitions[gate, bounded, put, zero, setKinematics, external, externalGram, loopProducts,
    loopVariables, scalarRules, coordinateVariables, families, familyMaps, mapScalar, toScalars,
    uvExpansion, reduceMap, uvPole, uvFromPowers, uvTask, runUVTask,
    ruleMap, masterValues, measure, physical, inputHash, cache];
  ParallelEvaluate[setKinematics[]];
  gate["worker native versions agree", And @@ (SameQ[#, {$Version, $FeynCalcVersion}] & /@
    ParallelEvaluate[{$Version, $FeynCalcVersion}])]];
$DistributedContexts = None;
parallelValidationPath = FileNameJoin[{root, "Hgq", "s13_parallel_result", "s13_result.wl"}];
If[parallelValidationOnly,
  gate["parallel comparison allocated workers", workers > 0];
  selectedTask = SelectFirst[uvTasks, Function[task, Module[{file, saved}, file = uvCacheFile[task];
    If[!FileExistsQ[file], Return[False]]; saved = Get[file];
    Lookup[saved, "InputHash", None] === inputHash && Lookup[saved, "Value", 0] =!= 0]], Missing["NoSerialCheckpoint"]];
  gate["accepted nonzero serial comparison exists", AssociationQ[selectedTask]];
  selectedFile = uvCacheFile[selectedTask]; serialValue = Get[selectedFile];
  comparison = First[ParallelMap[runUVTask[#, True] &, {selectedTask}, Method -> "FinestGrained"]];
  gate["fresh worker accepted", AssociationQ[comparison] && TrueQ[comparison["Accepted"]] && And @@ Values[comparison["Checks"]]];
  gate["fresh worker reproduces accepted serial checkpoint", bounded[zero[comparison["Value"] - serialValue["Value"]], "worker comparison"]];
  CloseKernels[];
  resultDir = FileNameJoin[{root, channel, "s13_parallel_result"}];
  If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
  put[<|"Schema" -> "polarized-sidis-virtual-uv-parallel-validation-v1", "Channel" -> channel,
    "SourceHash" -> sourceHash, "CalculationSourceHash" -> calculationSourceHash,
    "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "SerialCheckpoint" -> StringDrop[selectedFile, StringLength[root] + 1],
    "SerialCheckpointHash" -> FileHash[selectedFile, "SHA256"], "TaskCount" -> Length[uvTasks],
    "Comparison" -> KeyDrop[comparison, "Value"], "NativeVersions" -> {$Version, $FeynCalcVersion},
    "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>,
    FileNameJoin[{resultDir, "s13_result.wl"}]];
  Export[FileNameJoin[{resultDir, "s13_checks.json"}], <|"channel" -> channel, "checks" -> checks,
    "job_id" -> Environment["JOB_ID"], "comparison_seconds" -> comparison["ElapsedSeconds"],
    "task_count" -> Length[uvTasks]|>, "RawJSON"];
  Print["PASS: s13_virtual_uv_parallel_validation"]; Quit[0]];
parallelValidation = Get[parallelValidationPath];
gate["accepted parallel UV comparison", parallelValidation["Schema"] === "polarized-sidis-virtual-uv-parallel-validation-v1" &&
  TrueQ[parallelValidation["Accepted"]] && And @@ Values[parallelValidation["Checks"]] &&
  parallelValidation["SourceHash"] === sourceHash && parallelValidation["CalculationSourceHash"] === calculationSourceHash &&
  parallelValidation["NativeVersions"] === {$Version, $FeynCalcVersion}];
parallelValidationHash = FileHash[parallelValidationPath, "SHA256"];
uvValues = If[workers > 0, ParallelMap[runUVTask, uvTasks, Method -> "FinestGrained"], runUVTask /@ uvTasks];
CloseKernels[];
gate["all independent UV tasks accepted", Length[uvValues] === Length[uvTasks] &&
  AllTrue[uvValues, AssociationQ] && And @@ Lookup[uvValues, "Accepted"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ uvValues]];
gate["UV component order preserved", Lookup[uvValues, "Label"] === Lookup[uvTasks, "Label"]];
spinUV = <||>;
Do[key = item["Key"]; value = item["Value"];
  AssociateTo[spinUV, key -> Factor[value + If[KeyExistsQ[spinUV, key], spinUV[key], 0]]], {item, uvValues}];
Do[gate["new-spin CDR UV residue " <> mode, zero[(spinUV[{"CDR", {mode}}] - referenceResidues[mode]) /.
    spin["TransverseSubstitution"]]], {mode, {"Pg", "Ppp"}}];
fieldSplits = Association@KeyValueMap[Function[{field, residue}, Module[{solution},
  solution = Solve[(residue/epsUV + ir/eps /. epsUV -> eps) == 0, ir];
  gate["unique scaleless UV/IR field split", Length[solution] === 1];
  field -> (residue/epsUV + (ir /. First[solution])/eps)]], uv["FieldUVResidues"]];
book = uv["FieldBookkeeping"][channel];
gate["vanishing bare on-shell residue", book["BareOnShellResidue"] === 0];
fields = Flatten[KeyValueMap[ConstantArray[#1, #2] &, book["FieldCounts"]]];
fieldFactor = Times @@ (Sqrt[1 + ord fieldSplits[#]] & /@ fields);
externalInterference = Coefficient[Normal[Series[fieldFactor^2, {ord, 0, 1}]], ord];
gate["external UV bookkeeping", zero[Coefficient[Expand[externalInterference], epsUV, -1] - book["ExternalUVResidue"]]];
gate["bare external contribution vanishes", zero[externalInterference /. epsUV -> eps]];
inVariables = {"U" -> 1, "X" -> xIn, "Y" -> yIn, "H" -> hIn, "E" -> eIn};
outVariables = {"U" -> 1, "X" -> xOut, "Y" -> yOut, "H" -> hOut, "E" -> eOut};
bornMetric = Tr[basis["PhotonMetric"].born["PhotonMatrix"]] + Sum[
  born["EvanescentPhotonResponse"][[j, i]] (born["ExtendedIncomingLabels"][[i]] /. inVariables)
    (born["ExtendedOutgoingLabels"][[j]] /. outVariables),
  {j, Length[born["ExtendedOutgoingLabels"]]}, {i, Length[born["ExtendedIncomingLabels"]]}];
bornComponent[key_] := Switch[First[key],
  "ExtendedResponse", Extract[born["ExtendedResponse"], Last[key]],
  "PhotonMetricD", bornMetric, "PhotonWardLeft", 0];
integrateComponent[coefficients_, key_] := Module[{terms},
  terms = KeyValueMap[Function[{master, coefficient}, Module[{series, value},
    gate["physical master exists", KeyExistsQ[physicalMasters["Masters"], master]];
    series = physicalMasters["Masters"][master] /. Q2 -> Q^2;
    value = bounded[Series[(mapped["Measure"] /. Epsilon -> eps)
      (coefficient /. D -> 4 - 2 eps) series, {eps, 0, 0}], {key, master, "loop integral"}];
    gate["new virtual coefficient epsilon depth", value === 0 || (MatchQ[value, _SeriesData] && value[[5]] > 0)];
    Normal[value]]], coefficients];
  Total[terms]];
keys = Keys[mapped["Components"]];
MapIndexed[Function[{value, position}, If[value =!= 0, AppendTo[keys, {"ExtendedResponse", position}]]], born["ExtendedResponse"], {3}];
keys = DeleteDuplicates[keys];
components = <||>;
Do[
  file = FileNameJoin[{cache, "assembled_" <> IntegerString[Hash[key, "SHA256"], 16] <> ".wl"}];
  saved = If[FileExistsQ[file], Get[file], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["VIRTUAL_ASSEMBLE ", key];
    coefficients = If[KeyExistsQ[mapped["Components"], key], mapped["Components"][key], <||>];
    pre = bounded[reduce[integrateComponent[coefficients, key] /. spin["TransverseSubstitution"]], {key, "physical loop sum"}];
    If[First[key] === "PhotonWardLeft",
      gate["integrated photon Ward " <> ToString[key, InputForm], bounded[FullSimplify[pre, physical], key] === 0];
      hermitian = 0; residual = 0; value = 0,
      hermitian = bounded[reduce[ComplexExpand[pre + Conjugate[pre], TargetFunctions -> {Re, Im}]], {key, "Hermitian interference"}];
      residue = If[KeyExistsQ[spinUV, key], spinUV[key], 0] /. spin["TransverseSubstitution"];
      fullUV = Factor[ComplexExpand[residue + Conjugate[residue]]];
      separated = hermitian + fullUV (1/epsUV - 1/eps);
      gate["UV separation preserves tensor", Expand[(separated /. epsUV -> eps) - hermitian] === 0];
      bornD = bornComponent[key] /. D -> 4 - 2 eps;
      counterterm = book["CouplingWeight"] uv["CouplingResidue"] (uv["MSPole"] /. eps -> epsUV) bornD;
      complete = separated + externalInterference bornD + counterterm;
      residual = bounded[FullSimplify[Coefficient[Expand[complete], epsUV, -1] /. eps -> 0, physical], {key, "UV cancellation"}];
      gate["complete UV cancellation " <> ToString[key, InputForm], residual === 0];
      value = bounded[reduce[Normal[Series[complete /. epsUV -> eps, {eps, 0, 0}]]], {key, "renormalized series"}]];
    gate["explicit renormalized virtual expression", FreeQ[value,
      _GLI | _PaVe | _Integrate | _Limit | _Series | _SeriesData | _Real | $Failed | $Aborted | epsUV | Indeterminate | ComplexInfinity]];
    saved = <|"InputHash" -> inputHash, "Key" -> key, "PreHermitian" -> pre,
      "RenormalizedVirtual" -> value, "UVResidual" -> residual, "ChecksPassed" -> True|>;
    put[saved, file]; ClearSystemCache[]];
  AssociateTo[components, key -> saved], {key, keys}];
gate["complete virtual component inventory", Keys[components] === keys && AllTrue[Values[components], TrueQ[#["ChecksPassed"]] &]];
result = Join[KeyTake[mapped, {"Channel", "PhotonLabels", "SpinLabels", "IncomingSpinLabels", "OutgoingSpinLabels", "IndexOrder",
    "CouplingsRemoved", "Measure", "LoopPrescription", "InterferenceConvention", "Gamma5Scheme"}],
  <|"Schema" -> "polarized-sidis-renormalized-virtual-v1", "Components" -> components,
    "VirtualUVResidues" -> spinUV, "FieldSplits" -> fieldSplits, "ExternalInterference" -> externalInterference,
    "CouplingResidue" -> uv["CouplingResidue"], "CouplingWeight" -> book["CouplingWeight"],
    "MSPole" -> uv["MSPole"], "Regulator" -> eps, "PhysicalConditions" -> physical,
    "SourceHash" -> sourceHash, "CalculationSourceHash" -> calculationSourceHash, "ParallelValidationHash" -> parallelValidationHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes, "Checks" -> checks,
    "LoopIntegrated" -> True, "UVRenormalized" -> True, "IntegratedWardChecksPassed" -> True,
    "FiniteAxialSchemeConversionApplied" -> False, "FiniteNLOFHatsComputed" -> False|>];
resultDir = FileNameJoin[{root, channel, "s13_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s13_result.wl"}]];
Export[FileNameJoin[{resultDir, "s13_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s13_assemble_virtual_spin"]; Quit[0];

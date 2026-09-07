If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
$HistoryLength = 0;
out = DirectoryName[$InputFileName];
root = ParentDirectory[out];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_] := MemoryConstrained[TimeConstrained[work, 180, $TimedOut], 2*1024^3, $MemoryLimit];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
basis = Get[FileNameJoin[{root, "s05_result.wl"}]];
angular = Get[FileNameJoin[{root, "s06_result.wl"}]];
gate["S05 source identity", basis["SourceHash"] === FileHash[FileNameJoin[{root, "s05_real_angular_basis.wl"}], "SHA256"]];
gate["S06 source identity", angular["SourceHash"] === FileHash[FileNameJoin[{root, "s06_angular_integrals.wl"}], "SHA256"]];
sources = {"s09_real_phase_space.wl", "s09_previous_14689322/s09_real_phase_space.wl", "s09_previous_14689353/s09_real_phase_space.wl"};
sourceHashes = FileHash[FileNameJoin[{root, #}], "SHA256"] & /@ sources;
gate["eligible phase-space source identities", IntegerString[#, 16, 64] & /@ sourceHashes ===
 {"a9d526a066831dc48736cee7da8b60d1a0a093a4108a5052ec9b10bda0398b9e", "7d77edcee8aa0be6174e084e471ac238c70c60609fce8b0f88f73d2344cedef4", "5f1d80b79cc35c07b960ffdd890c3b8208b3dd0bfce1e91767f0c72524f6d253"}];
upstreamHashes = FileHash[FileNameJoin[{root, #}], "SHA256"] & /@ {"s05_result.wl", "s06_result.wl"};
eligibleHashes = Hash[Prepend[upstreamHashes, #], "SHA256"] & /@ sourceHashes;
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], upstreamHashes, sourceHashes}, "SHA256"];
cache = FileNameJoin[{out, "s02_cache", IntegerString[inputHash, 16]}];
CreateDirectory[cache, CreateIntermediateDirectories -> True];
mode = "RealSame_Charge0__Pg";
assumptions[sign_] := Q2 > 0 && s > 0 && omega > 0 && mu > 0 && SUNN > 1 && B > 0 && -Q2 - s < sign omega - s < 0;
checkTerm[{index_, sign_}] := Module[{file, packet, value, rows, expected, difference, series, term, geoms, key, result},
 file = FileNameJoin[{cache, IntegerString[index, 10, 3] <> "_" <> ToString[sign] <> ".wl"}];
 If[FileExistsQ[file], Return[Get[file]]];
 Print["Direct soft-series check ", index, " branch ", sign];
 packet = Get[FileNameJoin[{root, "s09_cache", mode <> "_" <> IntegerString[index, 10, 3] <> ".wl"}]];
 If[!MemberQ[eligibleHashes, packet["InputHash"]], Return[<|"Index" -> index, "Branch" -> sign, "Difference" -> $InvalidInput|>]];
 value = packet["Value"]; rows = value["Soft"][sign];
 expected = Normal[Series[Total[(#[[3]] s23^#[[2]] Exp[-#[[1]] eps Log[s23]]) & /@ rows], {eps, 0, 0}]];
 difference = Coefficient[Expand[(value["Ordinary"] /. t -> sign omega - s) - expected], eps, 0];
 series = bounded[FullSimplify[Normal[Series[difference, {s23, 0, -1}, Assumptions -> assumptions[sign] && s23 > 0]], assumptions[sign] && s23 > 0]];
 term = basis["Basis"][mode]["Terms"][[index]];
 geoms = basis["Basis"][mode]["Geometry"][[term[[{1, 2}]]]];
 key = Which[And @@ Lookup[geoms, "Massless"], Prepend[term[[{3, 4}]], "LL"],
   geoms[[1]]["Massless"], Prepend[Reverse[term[[{3, 4}]]], "ML"], True, Prepend[term[[{3, 4}]], "ML"]];
 result = <|"Index" -> index, "Branch" -> sign, "MasterKey" -> key, "Term" -> term,
   "Difference" -> series, "SoftRows" -> rows, "InputHash" -> inputHash|>;
 atomicPut[result, file];
 Print["Term ", index, " branch ", sign, " difference: ", InputForm[series]];
 ClearSystemCache[]; result];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" -> "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots]], 60, $Failed]];
workerCount = Length[Kernels[]];
If[workerCount > 0,
 ParallelEvaluate[$HistoryLength = 0];
 DistributeDefinitions[bounded, atomicPut, basis, angular, root, cache, mode, inputHash, eligibleHashes, assumptions, checkTerm]];
$DistributedContexts = None;
Print["Allocated diagnostic workers: ", workerCount];
tasks = Flatten[Table[{index, sign}, {index, Length[basis["Basis"][mode]["Terms"]]}, {sign, {1, -1}}], 1];
results = If[workerCount > 0, ParallelMap[checkTerm, tasks, Method -> "FinestGrained"], checkTerm /@ tasks];
CloseKernels[];
nonzero = Select[results, #["Difference"] =!= 0 &];
Print["Nonzero or unevaluated cases: ", InputForm[Lookup[#, {"Index", "Branch", "MasterKey", "Difference"}] & /@ nonzero]];
atomicPut[<|"Status" -> "DiagnosticComplete", "Mode" -> mode, "Results" -> results, "NonzeroOrUnevaluated" -> nonzero,
 "SourceHash" -> FileHash[$InputFileName, "SHA256"], "InputHash" -> inputHash|>, FileNameJoin[{out, "s02_result.wl"}]];
Print["S02_SUCCESS: diagnostic completed; no F hats accepted; peak memory = ", MaxMemoryUsed[]];
Quit[];

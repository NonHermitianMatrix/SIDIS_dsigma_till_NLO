If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
$HistoryLength = 0;
out = DirectoryName[$InputFileName]; root = ParentDirectory[out];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_] := MemoryConstrained[TimeConstrained[work, 240, $TimedOut], 2*1024^3, $MemoryLimit];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
basis = Get[FileNameJoin[{root, "s05_result.wl"}]];
angular = Get[FileNameJoin[{root, "s06_result.wl"}]];
gate["S05 source identity", basis["SourceHash"] === FileHash[FileNameJoin[{root, "s05_real_angular_basis.wl"}], "SHA256"]];
gate["S06 source identity", angular["SourceHash"] === FileHash[FileNameJoin[{root, "s06_angular_integrals.wl"}], "SHA256"]];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], FileHash[FileNameJoin[{root, "s05_result.wl"}], "SHA256"], FileHash[FileNameJoin[{root, "s06_result.wl"}], "SHA256"]}, "SHA256"];
cache = FileNameJoin[{out, "s04_cache", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
keys = Select[Lookup[angular["Masters"], "Key"], #[[1]] === "ML" && #[[2]] > 0 && #[[3]] <= 0 &];
gate["massive denominator has no integration-domain zero", Reduce[d > 1 && -1 <= x <= 1 && d - x == 0, {d, x}, Reals] === False];
polarMeasure = FullSimplify[Sin[ArcCos[x]]^(1 - 2 eps) Abs[D[ArcCos[x], x]], -1 < x < 1 && Element[eps, Reals]];
masterValue[key_] := SelectFirst[angular["Masters"], #["Key"] === key &]["Value"]["Regular"];
check[key_] := Module[{file, j = key[[2]], l = key[[3]], azimuth, integrand, direct, difference, rows, result},
 file = FileNameJoin[{cache, StringRiffle[ToString /@ key, "_"] <> ".wl"}];
 If[FileExistsQ[file], Return[Get[file]]];
 Print["Direct mixed angular integration ", InputForm[key]];
 azimuth = bounded[Integrate[Expand[(1 - c x - Sqrt[1 - c^2] Sqrt[1 - x^2] Cos[phi])^(-l)] Sin[phi]^(-2 eps),
   {phi, 0, Pi}, Assumptions -> eps < 0 && -1 < c < 1 && -1 < x < 1, GenerateConditions -> False]];
 If[!FreeQ[azimuth, $TimedOut | $MemoryLimit | _Integrate | _ConditionalExpression],
   result = <|"Key" -> key, "Status" -> "UnevaluatedAzimuth", "Value" -> azimuth, "InputHash" -> inputHash|>;
   atomicPut[result, file]; Return[result]];
 rows = Table[
   Print["Direct polar integral ", InputForm[key], " epsilon order ", order];
   integrand = Coefficient[Normal[Series[polarMeasure azimuth, {eps, 0, 1}]], eps, order]/(d - x)^j;
   direct = bounded[Integrate[integrand, {x, -1, 1}, Assumptions -> d > 1 && -1 < c < 1, GenerateConditions -> False]];
   difference = If[FreeQ[direct, $TimedOut | $MemoryLimit | _Integrate | _ConditionalExpression],
     bounded[FullSimplify[FunctionExpand[direct - Coefficient[masterValue[key], eps, order]], d > 1 && -1 < c < 1]], $Unevaluated];
   Print["Mixed moment ", InputForm[key], " order ", order, " difference = ", InputForm[difference]];
   <|"Order" -> order, "Direct" -> direct, "Difference" -> difference|>, {order, 0, 1}];
 result = <|"Key" -> key, "Status" -> "Compared", "Rows" -> rows, "InputHash" -> inputHash|>;
 atomicPut[result, file]; ClearSystemCache[]; result];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" -> "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Length[keys]], "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Length[keys]]], 60, $Failed]];
workerCount = Length[Kernels[]];
If[workerCount > 0, ParallelEvaluate[$HistoryLength = 0]; DistributeDefinitions[bounded, atomicPut, angular, cache, inputHash, polarMeasure, masterValue, check]];
$DistributedContexts = None;
results = If[workerCount > 0, ParallelMap[check, keys, Method -> "FinestGrained"], check /@ keys];
CloseKernels[];
atomicPut[<|"Status" -> "DiagnosticComplete", "Results" -> results, "InputHash" -> inputHash, "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{out, "s04_result.wl"}]];
Print["S04_SUCCESS: diagnostic completed; no F hats accepted; peak memory = ", MaxMemoryUsed[]];
Quit[];

(* Paper Eq. 39 and Appendices B,D: integrated real tensor and soft distributions. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
ClearAll[gate, bounded, es, master, geometry, softRows, realTerm, reduce];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
es[value_, order_] := Normal[Series[value, {eps, 0, order}]];
input = Get[FileNameJoin[{root, "s05_result.wl"}]];
angular = Get[FileNameJoin[{root, "s06_result.wl"}]];
gate["complete evaluated angular masters exist", AssociationQ[angular]];
gate["S05 source identity", input["SourceHash"] === FileHash[FileNameJoin[{root, "s05_real_angular_basis.wl"}], "SHA256"]];
gate["S06 source identity", angular["SourceHash"] === FileHash[FileNameJoin[{root, "s06_angular_integrals.wl"}], "SHA256"]];
physical = input["PhysicalRegion"] && mu > 0 && SUNN > 1 && B > 0;
inputHash = Hash[Prepend[FileHash[FileNameJoin[{root, #}], "SHA256"] & /@
  {"s05_result.wl", "s06_result.wl"}, FileHash[$InputFileName, "SHA256"]], "SHA256"];
cache = FileNameJoin[{root, "s09_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
acceptedHashes = {inputHash};
phase = mu^(2 eps) 2^(-2) Pi^(-eps) Gamma[1 - eps]/
  ((2 Pi)^(2 - 2 eps) Gamma[1 - 2 eps]);
master[key_] := master[key] = SelectFirst[angular["Masters"], #["Key"] === key &]["Value"];
reduce[value_, assumptions_] := Module[{a, functions},
  a = Refine[value, assumptions];
  functions = DeleteDuplicates[Cases[a, _Log | _PolyLog | _ArcTan | _Re | _Im, Infinity]];
  Collect[Expand[a], functions, Factor]];

geometry[mode_, i_, j_] := geometry[mode, i, j] = Module[{first, second, cosine, keyType},
  {first, second} = input["Basis"][mode]["Geometry"][[{i, j}]];
  cosine = FullSimplify[first["Direction"].second["Direction"], physical];
  If[first["Massless"] && second["Massless"],
    <|"Type" -> "LL", "Reverse" -> False, "Scale" -> {first["Scale"], second["Scale"]},
      "Rules" -> {z -> Factor[(1 + cosine)/2]}|>,
    gate["one mixed denominator is massive", Xor[first["Massless"], second["Massless"]]];
    <|"Type" -> "ML", "Reverse" -> first["Massless"],
      "Scale" -> {first["Scale"], second["Scale"]},
      "Rules" -> {d -> If[first["Massless"], second, first]["d"], c -> cosine}|>]];

(* The defining hypergeometric series is finite here or used to the required soft order. *)
hgTaylor[a_, b_, cc_, argument_, order_Integer] := Sum[
  Pochhammer[a, n] Pochhammer[b, n] argument^n/(Pochhammer[cc, n] n!), {n, 0, order}];
llPrefactor[j_, l_] := 2 Pi Gamma[1 - 2 eps] 2^(-j - l) *
  Beta[1 - eps - j, 1 - eps - l]/Gamma[1 - eps]^2;
valuation[value_] := Module[{rational = Factor[value]},
  gate["endpoint valuation is rational", PolynomialQ[Numerator[rational], s23] &&
    PolynomialQ[Denominator[rational], s23]];
  Exponent[Numerator[rational], s23, Min] - Exponent[Denominator[rational], s23, Min]];
branchAssumptions[sign_] := Q2 > 0 && s > 0 && omega > 0 && mu > 0 && SUNN > 1 &&
  B > 0 && -Q2 - s < sign omega - s < 0;
softGeometry[map_, sign_] := softGeometry[map, sign] = FullSimplify[
  map["Rules"] /. t -> sign omega - s,
  branchAssumptions[sign] && s23 > 0 && (input["PhysicalRegion"] /. t -> sign omega - s)];
softMassiveLimit[rules_, sign_] := softMassiveLimit[rules, sign] = FullSimplify[
  Limit[d /. rules, s23 -> 0], branchAssumptions[sign]];

softRows[expression_, kappa_, assumptions_] := Module[{series, firstPower, values},
  series = bounded[Series[expression, {s23, 0, -1}, Assumptions -> assumptions], "soft recoil series"];
  If[Normal[series] === 0, Return[{}]];
  If[!(Head[series] === SeriesData && series[[6]] === 1),
    atomicPut[<|"Task" -> $RealTerm, "Expression" -> expression, "Series" -> series,
      "Kappa" -> kappa, "Assumptions" -> assumptions, "InputHash" -> inputHash|>,
      FileNameJoin[{root, "s09_laurent_unreduced_" <> ToString[$ProcessID] <> ".wl"}]];
    Print["Unreduced soft series for ", InputForm[$RealTerm], ": ", InputForm[series]]];
  gate["soft expansion is a Laurent series", Head[series] === SeriesData && series[[6]] === 1];
  firstPower = series[[4]];
  values = Table[{kappa, power, bounded[reduce[es[SeriesCoefficient[series, power], 1], assumptions],
      {"soft epsilon coefficient", power}]}, {power, firstPower, -1}];
  values = Map[Function[row, If[FreeQ[row, s23], row, ReplacePart[row, 3 -> bounded[
    reduce[PowerExpand[(row[[3]] /. a_ArcTanh :> FunctionExpand[a, assumptions && s23 > 0]) /.
      Log[arg_] :> Log[Factor[arg]],
      Assumptions -> assumptions && s23 > 0], assumptions && s23 > 0],
    "endpoint logarithms on the physical branch"]]]], values];
  values = Map[Function[row, If[FreeQ[row, s23], row, ReplacePart[row, 3 -> Module[
    {logPolynomial = Expand[row[[3]]], degree, coefficients},
    degree = Exponent[logPolynomial, Log[s23]];
    coefficients = Table[bounded[FullSimplify[Coefficient[logPolynomial, Log[s23], n],
      assumptions && s23 > 0], {"recoil logarithm coefficient", n}], {n, 1, degree}];
    Print["Simplified recoil-log coefficients: ", InputForm[coefficients]];
    (logPolynomial /. Log[s23] -> 0) + Sum[coefficients[[n]] Log[s23]^n, {n, 1, degree}]]]]], values];
  If[!FreeQ[values, s23],
    atomicPut[<|"Rows" -> values, "Expression" -> expression, "Assumptions" -> assumptions|>,
      FileNameJoin[{root, "s09_endpoint_unreduced_" <> ToString[$ProcessID] <> ".wl"}]];
    Print["Remaining recoil functions: ", InputForm[DeleteDuplicates[
      Cases[values, f : (_Log | _PolyLog) /; !FreeQ[f, s23] :> f, Infinity]]]]];
  gate["soft coefficients contain no recoil variable", FreeQ[values, s23]];
  Select[values, Last[#] =!= 0 &]];

softTerm[coefficient_, map_, powers_, sign_] := Module[{assumptions, replacement, prefactor,
  rules, j, l, argument, end, poleOrder, count, rows, w, qorder, h, cc, exponent,
  connectionA, connectionB, integerPower, kappa, polynomial, dEnd},
  assumptions = branchAssumptions[sign]; replacement = t -> sign omega - s;
  rules = softGeometry[map, sign];
  prefactor = Factor[coefficient /. replacement];
  {j, l} = powers;
  If[map["Type"] === "ML",
    dEnd = softMassiveLimit[rules, sign];
    gate["massive angular denominator stays separated at the soft endpoint",
      FullSimplify[dEnd > 1, assumptions]];
    Return[softRows[phase prefactor (master[{"ML", j, l}]["Regular"] /. rules),
      -Coefficient[-eps, eps], assumptions]]];
  argument = z /. rules;
  end = FullSimplify[Limit[argument, s23 -> 0], assumptions];
  poleOrder = valuation[prefactor];
  If[j <= 0 || l <= 0,
    count = Min[Select[{-j, -l}, # >= 0 &]];
    polynomial = hgTaylor[j, l, 1 - eps, argument, count];
    Return[softRows[phase prefactor llPrefactor[j, l] polynomial,
      -Coefficient[-eps, eps], assumptions]]];
  gate["massless soft argument is a hypergeometric endpoint", MemberQ[{0, 1}, end]];
  If[end === 0,
    count = Max[0, Ceiling[(-1 - poleOrder)/valuation[argument]]];
    Return[softRows[phase prefactor llPrefactor[j, l] hgTaylor[j, l, 1 - eps, argument, count],
      -Coefficient[-eps, eps], assumptions]]];
  (* Exact connection formula: DLMF 15.10.21, before any epsilon truncation. *)
  w = Factor[1 - argument]; qorder = valuation[w]; h = Factor[w/s23^qorder];
  gate["coalescing variable has a positive regular factor", qorder > 0 &&
    FullSimplify[Limit[h, s23 -> 0] > 0, assumptions]];
  cc = 1 - eps; exponent = cc - j - l;
  connectionA = Gamma[cc] Gamma[cc - j - l]/(Gamma[cc - j] Gamma[cc - l]);
  connectionB = Gamma[cc] Gamma[j + l - cc]/(Gamma[j] Gamma[l]);
  count = Max[0, Ceiling[(-1 - poleOrder)/qorder]];
  rows = softRows[phase prefactor llPrefactor[j, l] connectionA *
    hgTaylor[j, l, j + l - cc + 1, w, count], -Coefficient[-eps, eps], assumptions];
  integerPower = Expand[qorder exponent] /. eps -> 0;
  kappa = -Coefficient[-eps + qorder exponent, eps];
  count = Max[0, Ceiling[(-1 - poleOrder - integerPower)/qorder]];
  Join[rows, softRows[phase prefactor llPrefactor[j, l] connectionB s23^integerPower h^exponent *
    hgTaylor[cc - j, cc - l, cc - j - l + 1, w, count], kappa, assumptions]]];

realTerm[mode_, index_] := Module[{file, saved, term, map, powers, coefficient,
  value, ordinary, soft},
  file = FileNameJoin[{cache, mode <> "_" <> IntegerString[index, 10, 3] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedHashes, saved["InputHash"]], Return[saved["Value"]]]];
  Print[mode, " real term ", index, "/", Length[input["Basis"][mode]["Terms"]],
    "; memory = ", MemoryInUse[]];
  term = input["Basis"][mode]["Terms"][[index]];
  map = geometry[mode, term[[1]], term[[2]]];
  powers = term[[{3, 4}]];
  coefficient = Factor[(term[[5]] /. D -> 4 - 2 eps) Times @@ (map["Scale"]^(-powers))];
  If[map["Reverse"], powers = Reverse[powers]];
  value = master[Prepend[powers, map["Type"]]];
  ordinary = bounded[es[phase s23^(-eps) coefficient *
    ((value["Regular"] + (1 - z)^(-eps) value["Coalescing"]) /. map["Rules"]), 0],
    {mode, index, "ordinary"}];
  gate["ordinary real term is fully evaluated", FreeQ[ordinary,
    _Integrate | _Hypergeometric2F1 | _SeriesData | _SeriesCoefficient | _Derivative | _Real]];
  soft = Association@Table[sign -> bounded[softTerm[coefficient, map, powers, sign],
    {mode, index, "soft", sign}], {sign, {1, -1}}];
  value = <|"Ordinary" -> ordinary, "Soft" -> soft|>;
  atomicPut[<|"InputHash" -> inputHash, "Value" -> value|>, file];
  If[Mod[index, 10] === 0, ClearSystemCache[]]; value];

(* Integrating a constant test function fixes the delta coefficient. *)
endpointIntegral = Integrate[r^(-1 - kap ep), {r, 0, B},
  Assumptions -> kap > 0 && ep < 0 && B > 0, GenerateConditions -> False];
gate["regulated endpoint integral evaluated", FreeQ[endpointIntegral, _Integrate | _ConditionalExpression]];
logKernel = Normal[Series[Exp[-kap ep ell], {ep, 0, 2}]];
laurentProduct[laurent_, kernel_, order_] := Module[{polynomial = Expand[laurent], first, last},
  If[polynomial === 0, Return[0]];
  first = Exponent[polynomial, eps, Min]; last = Exponent[polynomial, eps];
  Total[Table[eps^n Coefficient[polynomial, eps, n] es[kernel, order - n], {n, first, last}]]];

realTask[spec_] := Block[{$RealTerm = spec}, Catch[realTerm @@ spec, "StageFailure"]];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
Print["Parallel budget inputs: ", InputForm[{slots, $ProcessorCount, $MaxLicenseSubprocesses}]];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Infinity],
  "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Infinity]], 60, $Failed]];
workerCount = If[ListQ[Kernels[]], Length[Kernels[]], 0];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["angular workers share compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[gate, bounded, atomicPut, es, master, geometry, reduce,
    hgTaylor, llPrefactor, valuation, branchAssumptions, softGeometry, softMassiveLimit,
    softRows, softTerm, realTerm, realTask, root, input, angular, physical, inputHash,
    cache, acceptedHashes, phase],
  runtimeEvidence = {}; Print["Parallel launch unavailable; bounded tasks run serially."]];
Print["Angular worker count = ", workerCount];
$DistributedContexts = None;
results = Association@Table[
  tasks = Table[{mode, index}, {index, Length[input["Basis"][mode]["Terms"]]}];
  terms = If[workerCount > 0, ParallelMap[realTask, tasks, Method -> "FinestGrained"], realTask /@ tasks];
  gate[mode <> " all real phase-space terms completed", FreeQ[terms, $Failed | $Aborted]];
  ordinary = Total[#["Ordinary"] & /@ terms];
  branches = Association@Table[
    branchFile = FileNameJoin[{cache, "s09_" <> mode <> "_branch_" <> ToString[sign] <> ".wl"}];
    branchSaved = If[FileExistsQ[branchFile], Get[branchFile], <||>];
    If[AssociationQ[branchSaved] && MemberQ[acceptedHashes, Lookup[branchSaved, "InputHash", None]],
      sign -> branchSaved["Value"],
    Print[mode, " assembling distribution branch ", sign];
    assumptions = branchAssumptions[sign];
    rows = Flatten[#["Soft"][sign] & /@ terms, 1];
    groups = GatherBy[rows, Take[#, 2] &];
    combined = Table[Print[mode, " branch ", sign, " soft group ", Take[group[[1]], 2]];
      {group[[1, 1]], group[[1, 2]], bounded[
      reduce[Total[group[[All, 3]]], assumptions], {mode, sign, "combine soft", Take[group[[1]], 2]}]},
      {group, groups}];
    Do[If[row[[2]] < -1, gate["stronger recoil poles cancel",
      bounded[FullSimplify[row[[3]], assumptions], "stronger recoil pole"] === 0]], {row, combined}];
    endpoints = Select[combined, #[[2]] === -1 &];
    endpointFunction = Total[#[[3]] s23^(-1 - #[[1]] eps) & /@ endpoints];
    Print[mode, " branch ", sign, " delta coefficient"];
    delta = bounded[Total[(laurentProduct[#[[3]],
      endpointIntegral /. {kap -> #[[1]], ep -> eps}, 0] &) /@ endpoints],
      {mode, sign, "delta"}];
    Print[mode, " branch ", sign, " plus coefficients"];
    plus = Table[bounded[Total[(laurentProduct[#[[3]], B^(-#[[1]] eps) *
      (Coefficient[logKernel, ell, n] /. {kap -> #[[1]], ep -> eps}), 0] &) /@ endpoints],
      {mode, sign, "plus", n}], {n, 0, 2}];
    gate["no higher logarithmic plus distribution survives", Factor[plus[[3]]] === 0];
    Print[mode, " branch ", sign, " regular remainder"];
    regular = (ordinary /. t -> sign omega - s) -
      Total[(laurentProduct[#[[3]], s23^(-1 - #[[1]] eps), 0] &) /@ endpoints];
    branchValue = <|"Delta" -> delta, "L0" -> plus[[1]], "L1" -> plus[[2]],
      "Regular" -> regular, "SoftCoefficients" -> endpoints, "Assumptions" -> assumptions|>;
    atomicPut[<|"InputHash" -> inputHash, "Value" -> branchValue|>, branchFile];
    Print[mode, " distribution branch ", sign, " saved."];
    sign -> branchValue],
    {sign, {1, -1}}];
  mode -> <|"Ordinary" -> ordinary, "Branches" -> branches|>, {mode, {"Pg", "Ppp"}}];
CloseKernels[];
atomicPut[<|"Real" -> results, "ParallelRuntime" -> runtimeEvidence, "Regulator" -> eps, "PhaseWithoutRecoilPower" -> phase,
  "BranchMap" -> (t -> sign omega - s), "PlusDefinition" -> "Ln=[Log[s23/B]^n/s23]_+ on [0,B]",
  "PhysicalRegion" -> physical, "CouplingsRemoved" -> "eq^2 gs^4",
  "AcceptedCacheInputHashes" -> acceptedHashes, "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "HardTensorNormalization" -> "(2 Pi)^(-4) applied at final assembly", "InputHash" -> inputHash|>,
  FileNameJoin[{root, "s09_result.wl"}]];
Print["S09_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

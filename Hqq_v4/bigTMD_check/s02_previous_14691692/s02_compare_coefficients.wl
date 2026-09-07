If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
parent = DirectoryName[root];
fail[label_] := (Print["FAIL: ", label]; If[TrueQ[$KernelID > 0],
  Throw[Failure["Benchmark", <|"Message" -> label|>], "BenchmarkFailure"], Quit[1]]);
gate[label_, test_] := If[TrueQ[test], Print["PASS: ", label], fail[label]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  fail["time bound " <> ToString[label]]], 2*1024^3,
  fail["memory bound " <> ToString[label]]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
sha[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];
frozen = Import[FileNameJoin[{root, "frozen_inputs.json"}], "RawJSON"];
KeyValueMap[(gate["frozen " <> #1, sha[FileNameJoin[{parent, #1}]] === #2]) &, frozen];
manifest = Import[FileNameJoin[{root, "s01_result.json"}], "RawJSON"];
gate["S01 source", manifest["SourceSHA256"] === sha[FileNameJoin[{root, "s01_prepare_reference.py"}]]];
gate["S01 result", manifest["ResultSHA256"] === sha[FileNameJoin[{root, "s01_result.wl"}]]];
KeyValueMap[(gate["reference " <> #1, sha[FileNameJoin[{root, "reference", #1}]] === #2]) &, manifest["Files"]];
reference = Get[FileNameJoin[{root, "s01_result.wl"}]];
production = bounded[Get[FileNameJoin[{parent, "s10_result.wl"}]], "load final hats"];
born = Get[FileNameJoin[{parent, "s02_result.wl"}]];
gate["accepted independent final hats", TrueQ[production["RegulatorCancellationPassed"]] &&
  production["AuthorsCoefficientsUsed"] === False &&
  production["SourceHash"] === FileHash[FileNameJoin[{parent, "s10_final_hats.wl"}], "SHA256"]];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], frozen, manifest}, "SHA256"];
cache = FileNameJoin[{root, "s02_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
driver = reference["Driver"];

(* Normalizations and projectors come from the imported driver expressions. *)
gsSquare = driver["gs2"] /. sourceAlphaS[_] -> alphaS;
commonMeasure = driver["factor00"] /. gs2 -> 1;
loNormalization = Factor[((driver["BornAddition"] /. referenceBorn[___] -> 1) /.
  factor0 -> driver["factor00"])/commonMeasure] /. gs2 -> gsSquare;
nloNormalization = Factor[driver["factor01"]/commonMeasure] /. gs2 -> gsSquare;
gate["same NLO coupling at endpoint and interior", Together[
  nloNormalization - (driver["factor1"]/(driver["factor1"] /. gs2 -> 1) /. gs2 -> gsSquare)] === 0];
projectors = Association@Table[name -> (driver[name <> "h"] /. {Fg -> hg, Fpp -> hpp, Q -> Sqrt[Q2]}),
  {name, {"F1", "F2"}}];
gate["authors projectors equal current-channel Eq. 9", And @@ Table[Together[
  projectors[item[[1]]] - (item[[2]] /. born["ProjectorsEpsilon"] /. eps -> 0)] === 0,
  {item, {{"F1", f1}, {"F2", f2}}}]];
sourceBorn = Map[(# /. born["BornKinematics"]) &, reference["LO"]];
gate["authors Hqq Born tensors equal current generated Born", And @@ Table[Together[
  sourceBorn[item[[1]]] - (born[item[[2]]] /. {D -> 4, SUNN -> 3})] === 0,
  {item, {{"Pg", "BornPg"}, {"Ppp", "BornPpp"}}}]];

(* Derive the basis change and nonconstant-coefficient transport. *)
rawKernel = (p10 + p20 Log[y])/y;
localKernel = (a0 + a1 (Log[y] - Log[B]))/y;
basisMap = First[Solve[Thread[CoefficientList[Expand[y (rawKernel - localKernel)], Log[y]] == 0], {a0, a1}]];
regularMap = Together[rr + (p1y + p2y Log[y])/y - (localKernel /. basisMap)];
gate["ordinary distribution conversion", Together[
  regularMap + (localKernel /. basisMap) - rr - (p1y + p2y Log[y])/y] === 0];
probe = 1 + aa y + bb y^2;
probeRules = {p10 -> c0, p20 -> d0, p1y -> c0 + c1 y, p2y -> d0 + d1 y, rr -> r0};
originalAction = Integrate[r0 probe + (((c0 + c1 y) probe - c0) +
  ((d0 + d1 y) probe - d0) Log[y])/y, {y, 0, B}, Assumptions -> B > 0];
convertedAction = Integrate[((regularMap /. probeRules) probe) +
  ((localKernel /. basisMap /. probeRules) (probe - 1)), {y, 0, B}, Assumptions -> B > 0];
gate["plus transport preserves defining test-function action", FullSimplify[originalAction - convertedAction, B > 0] === 0];

(* Select physical points where the actual reference denominator bases are nonzero. *)
referenceDivisors = DeleteDuplicates[Cases[reference["NLO"],
  (HoldPattern[Power[base_, power_?NumberQ]] /; TrueQ[power < 0]) :> base, Infinity]];
gate["reference divisors were extracted", Length[referenceDivisors] > 0];
makePoint[q_, xx_, ratio_, label_] := Module[{base, bvalue, mass, tvalue, rules, sign, support, divisors},
  base = {Q -> q, xh -> xx, qT -> q Sqrt[ratio]};
  bvalue = Factor[driver["B"] /. z -> driver["zh0"]/2 /. base];
  mass = bvalue/4;
  tvalue = Factor[driver["t"] /. zh -> driver["zh"] /. base /. s23 -> mass];
  rules = {Q2 -> q^2, s -> Factor[driver["s"] /. base], t -> tvalue, s23 -> mass,
    mu -> q, B -> bvalue, SUNN -> 3, Nf -> driver["nf"], alphaS -> 1/5};
  sign = Sign[(s + t) /. rules];
  support = FullSimplify[production["PhysicalRegion"] /. rules];
  If[TrueQ[support],
    divisors = Quiet[N[referenceDivisors /. rules /. {Q -> q, nf -> driver["nf"]}, 30]];
    support = AllTrue[divisors, NumberQ[#] && FreeQ[#, Indeterminate | _DirectedInfinity] && TrueQ[# != 0] &]];
  <|"ID" -> label, "Branch" -> sign, "Rules" -> rules, "Support" -> support,
    "Input" -> <|"Q" -> q, "s" -> (s /. rules), "t" -> tvalue, "s23" -> mass,
      "mu" -> q, "B" -> bvalue, "nf" -> driver["nf"], "SUNN" -> 3, "alphaS" -> 1/5,
      "xh" -> xx, "qT2" -> q^2 ratio|>|>];
points = Flatten[Table[Module[{candidates},
  candidates = Flatten[Table[makePoint[{2, 5, 10}[[i]], xx, ratio, "unused"],
    {xx, {1/5, 2/5, 3/5, 4/5}}, {ratio, {1/4, 1, 4}}]];
  candidates = RotateLeft[candidates, i - 1];
  Table[With[{chosen = SelectFirst[candidates, TrueQ[#["Support"]] && #["Branch"] === sign &, Missing["NoPoint"]]},
    gate["physical benchmark exists", AssociationQ[chosen]];
    Join[chosen, <|"ID" -> "q" <> ToString[i] <> If[sign === 1, "_positive", "_negative"]|>]],
    {sign, {1, -1}}]], {i, 3}]];
Print["Selected benchmarks: ", InputForm[(KeyTake[#, {"ID", "Branch", "Input"}] &) /@ points]];

number[expression_, label_] := Module[{v = bounded[N[expression, 70], label]},
  gate[label <> " finite and real", NumberQ[v] && FreeQ[v, Indeterminate | _DirectedInfinity] && Abs[Im[v]] < 10^-45];
  Re[v]];
endpoint[expression_, rules_, label_] := Module[{expr, value},
  expr = expression /. DeleteCases[rules, HoldPattern[s23 -> _]];
  value = Quiet[expr /. s23 -> 0];
  If[!NumberQ[Quiet[N[value, 30]]] || !FreeQ[value, Indeterminate | _DirectedInfinity],
    Print["Endpoint limit ", label];
    value = bounded[Limit[expr, s23 -> 0, Direction -> "FromAbove"], label]];
  number[value, label]];
pack[value_] := <|"Value" -> N[value, MachinePrecision], "HighPrecision" -> ToString[value, InputForm]|>;

runPoint[point_] := Module[{file, saved, rules, refRules, sign, raw, data, common, rows = {}, directs = {},
  flavor, chargeList, moments, chargeRules, localRules, weights, refCoefs, localValue, referenceValue,
  localDirect, refDirect, fromTable, pd, branchHats, loRef, selected, mode, case, name, dist},
  file = FileNameJoin[{cache, point["ID"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[saved["InputHash"] === inputHash, Return[saved["Value"]]]];
  Print["Point start ", point["ID"], " memory=", MemoryInUse[]];
  rules = point["Rules"]; sign = point["Branch"];
  refRules = Join[rules, {Q -> point["Input"]["Q"], nf -> (Nf /. rules)}];
  raw = Association@Table[mode -> Association@Table[case -> Module[{functions, values, endpoints},
    functions = reference["NLO"][mode][case];
    values = Association@Table[dist -> number[functions[dist] /. refRules,
      point["ID"] <> " " <> mode <> case <> " " <> dist], {dist, {"regular", "plus1B", "plus2B"}}];
    endpoints = Association@Table[dist -> endpoint[functions[dist], refRules,
      point["ID"] <> " " <> mode <> case <> " " <> dist <> " endpoint"], {dist, {"delta", "plus1B", "plus2B"}}];
    <|"Interior" -> values, "Endpoint" -> endpoints|>], {case, {"A", "C"}}], {mode, {"Pg", "Ppp"}}];
  common = Association@Table[mode -> Association@Table[case -> Module[{r = raw[mode][case], substitutions},
    substitutions = {p10 -> r["Endpoint"]["plus1B"], p20 -> r["Endpoint"]["plus2B"],
      p1y -> r["Interior"]["plus1B"], p2y -> r["Interior"]["plus2B"], rr -> r["Interior"]["regular"]};
    <|"Delta" -> r["Endpoint"]["delta"], "L0" -> (a0 /. basisMap /. substitutions /. rules),
      "L1" -> (a1 /. basisMap /. substitutions /. rules),
      "Regular" -> (regularMap /. substitutions /. y -> s23 /. rules)|>],
    {case, {"A", "C"}}], {mode, {"Pg", "Ppp"}}];
  Do[
    flavor = reference["Flavors"][selected]; weights = flavor["Weights"];
    chargeList = Insert[flavor["OtherCharges"], flavor["Charge"], production["ObservedFlavor"]];
    gate["active flavor count agrees", Length[chargeList] === flavor["Nf"] && flavor["Nf"] === (Nf /. rules)];
    moments = Map[(Activate[# /. Nf -> flavor["Nf"], Sum] /.
      flavorCharge[n_Integer] :> chargeList[[n]]) &, production["OtherChargeMomentDefinitions"]];
    chargeRules = Join[{eq -> flavor["Charge"]}, KeyValueMap[(otherChargeMoment[#1] -> #2) &, moments]];
    gate["driver primary charge weight", weights["A"] === flavor["Charge"]^2];
    gate["driver secondary charge weight equals saved flavor sum", weights["C"] === moments[2]];
    gate["physical mixed-charge luminosity vanishes", weights["B"] === 0];
    localRules = Join[rules, chargeRules];
    pd = Map[(# /. born["BornKinematics"] /. rules) &, projectors];
    Do[
      branchHats = production["Hats"][name]["NLO"][sign] /. production["BranchCoordinates"][sign];
      gate["saved endpoint coefficients do not depend on recoil", FreeQ[Values[KeyDrop[branchHats, "Regular"]], s23]];
      loRef = loNormalization weights["A"] (pd[name] /.
        {hg -> sourceBorn["Pg"], hpp -> sourceBorn["Ppp"]});
      refCoefs = Association@Table[dist -> (nloNormalization (pd[name] /.
        {hg -> Total[Table[weights[case] common["Pg"][case][dist], {case, {"A", "C"}}]],
         hpp -> Total[Table[weights[case] common["Ppp"][case][dist], {case, {"A", "C"}}]]})),
        {dist, {"Delta", "L0", "L1", "Regular"}}];
      Do[
        localValue = number[If[dist === "LODelta", production["Hats"][name]["LODelta"], branchHats[dist]] /. localRules,
          point["ID"] <> " local " <> selected <> " " <> name <> " " <> dist];
        referenceValue = number[If[dist === "LODelta", loRef, refCoefs[dist]] /. rules,
          point["ID"] <> " reference " <> selected <> " " <> name <> " " <> dist];
        AppendTo[rows, <|"Point" -> point["ID"], "Flavor" -> selected, "Hat" -> name, "Distribution" -> dist,
          "Local" -> pack[localValue], "Reference" -> pack[referenceValue]|>],
        {dist, {"LODelta", "Delta", "L0", "L1", "Regular"}}];
      localDirect = number[(production["StructureFunctions"][name] /.
        {DiracDelta[_] -> 0, PlusDistribution[argument_, _] :> argument}) /. localRules,
        point["ID"] <> " final expression " <> selected <> " " <> name];
      fromTable = number[(branchHats["Regular"] + branchHats["L0"]/s23 +
        branchHats["L1"] Log[s23/B]/s23) /. localRules, "ordinary local coefficient reconstruction"];
      gate["final expression equals ordinary coefficient assembly", Abs[localDirect - fromTable] <
        10^-45 Max[1, Abs[localDirect], Abs[fromTable]]];
      refDirect = number[(nloNormalization (pd[name] /.
        {hg -> Total[Table[weights[case] (raw["Pg"][case]["Interior"]["regular"] +
          (raw["Pg"][case]["Interior"]["plus1B"] + raw["Pg"][case]["Interior"]["plus2B"] Log[s23])/s23), {case, {"A", "C"}}]],
         hpp -> Total[Table[weights[case] (raw["Ppp"][case]["Interior"]["regular"] +
          (raw["Ppp"][case]["Interior"]["plus1B"] + raw["Ppp"][case]["Interior"]["plus2B"] Log[s23])/s23), {case, {"A", "C"}}]]})) /. rules,
        point["ID"] <> " ordinary reference " <> selected <> " " <> name];
      AppendTo[directs, <|"Point" -> point["ID"], "Flavor" -> selected, "Hat" -> name,
        "Local" -> pack[localDirect], "Reference" -> pack[refDirect]|>], {name, {"F1", "F2"}}],
    {selected, Keys[reference["Flavors"]]}];
  data = <|"Point" -> KeyTake[point, {"ID", "Branch", "Input"}], "Coefficients" -> rows, "Direct" -> directs|>;
  atomicPut[<|"InputHash" -> inputHash, "Value" -> data|>, file];
  Print["Point complete ", point["ID"], " memory=", MemoryInUse[]]; data];
pointTask[point_] := Catch[runPoint[point], "BenchmarkFailure"];

slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Length[points]], "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Length[points]]], 60, $Failed]];
workers = Length[Kernels[]];
If[workers > 0,
  ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[fail, gate, bounded, atomicPut, number, endpoint, pack, runPoint, pointTask,
    root, cache, inputHash, reference, production, born, driver, loNormalization,
    nloNormalization, projectors, sourceBorn, basisMap, regularMap]];
$DistributedContexts = None;
Print["Independent benchmark workers: ", workers];
results = If[workers > 0, ParallelMap[pointTask, points, Method -> "FinestGrained"], pointTask /@ points];
CloseKernels[];
gate["all benchmark results present", Length[results] === Length[points] && AllTrue[results, AssociationQ]];
output = <|"Results" -> results, "FrozenInputs" -> frozen, "ReferenceCommit" -> manifest["Commit"],
  "SourceSHA256" -> sha[$InputFileName], "InputHash" -> inputHash,
  "Conventions" -> <|"LONormalization" -> loNormalization, "NLONormalization" -> nloNormalization,
    "Projectors" -> projectors, "BasisMap" -> basisMap, "RegularMap" -> regularMap,
    "PhysicalRegion" -> production["PhysicalRegion"], "Flavors" -> reference["Flavors"]|>|>;
atomicPut[output, FileNameJoin[{root, "s02_result.wl"}]];
json = <|"Results" -> (results /. (r_Rational :> ToString[r, InputForm])),
  "FrozenInputs" -> frozen, "ReferenceCommit" -> manifest["Commit"],
  "SourceSHA256" -> sha[$InputFileName], "ResultSHA256" -> sha[FileNameJoin[{root, "s02_result.wl"}]],
  "Flavors" -> (reference["Flavors"] /. (r_Rational :> ToString[r, InputForm]))|>;
Export[FileNameJoin[{root, "s02_result.json"}], json, "RawJSON"];
Print["S02_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

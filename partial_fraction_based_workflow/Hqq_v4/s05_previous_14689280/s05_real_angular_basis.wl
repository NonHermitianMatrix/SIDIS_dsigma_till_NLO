If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
(* Paper Appendices B and D: exact invariant reduction and rest-frame geometry. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
ClearAll[gate, bounded, mink, sphere, splitDenominators, makeBasis];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
gate["accepted S03 input exists", FileExistsQ[FileNameJoin[{root, "s03_result.wl"}]]];
input = Get[FileNameJoin[{root, "s03_result.wl"}]];
gate["S03 source identity", input["SourceHash"] === FileHash[FileNameJoin[{root, "s03_contract_real.wl"}], "SHA256"]];
gate["all real Ward identities passed", And @@ (# === 0 & /@ Values[input["WardChecks"]])];
tensorKeys = input["TensorKeys"];
basisHash = Hash[{FileHash[$InputFileName, "SHA256"],
  FileHash[FileNameJoin[{root, "s03_result.wl"}], "SHA256"]}, "SHA256"];
basisCache = FileNameJoin[{root, "s05_cache", IntegerString[basisHash, 16]}];
If[!DirectoryQ[basisCache], CreateDirectory[basisCache, CreateIntermediateDirectories -> True]];
previousSource = FileNameJoin[{root, "s05_previous_14689149", "s05_real_angular_basis.wl"}];
gate["eligible previous source identity", IntegerString[FileHash[previousSource, "SHA256"], 16, 64] ===
  "494b83da3f208b019011e964e3bf692113a16d2d0811a245be2166577348eab0"];
previousHash = Hash[{FileHash[previousSource, "SHA256"],
  FileHash[FileNameJoin[{root, "s03_result.wl"}], "SHA256"]}, "SHA256"];
previousCache = FileNameJoin[{root, "s05_cache", IntegerString[previousHash, 16]}];
basisInputs = input["Contractions"];
taskGroups = Association@Table[key -> {key}, {key, tensorKeys}];
pairHashes = <||>;
pairDirectory = FileNameJoin[{root, "s03_cache", IntegerString[input["InputHash"], 16]}];
Do[
  component = First[StringSplit[key, "__"]];
  If[input["Components"][component]["Sector"] === "RealSame",
    projector = Last[StringSplit[key, "__"]];
    files = Sort[FileNames["RealSame_" <> projector <> "_*.wl", pairDirectory]];
    gate["same-flavor pair checkpoints exist", Length[files] > 0];
    packets = Get /@ files;
    gate["same-flavor pair identities match S03", And @@ Table[
      packet["InputHash"] === input["InputHash"] && packet["Component"] === component &&
      packet["Mode"] === projector, {packet, packets}]];
    gate[key <> " pair sum reconstructs accepted S03", bounded[
      Factor[Total[Lookup[packets, "Value"]] - input["Contractions"][key]], key <> " source pair sum"] === 0];
    aliases = Table[key <> "__Pair_" <> FileBaseName[files[[i]]], {i, Length[files]}];
    Do[AssociateTo[basisInputs, aliases[[i]] -> packets[[i]]["Value"]];
      AssociateTo[pairHashes, FileNameTake[files[[i]]] -> FileHash[files[[i]], "SHA256"]], {i, Length[files]}];
    AssociateTo[taskGroups, key -> aliases]], {key, tensorKeys}];
basisTasks = Flatten[Values[taskGroups]];
geometrySeeds = Flatten[Table[
  packet = Get[file]; gate["geometry seed source/input identity", packet["InputHash"] === previousHash];
  value = packet["Value"];
  Table[<|"Denominator" -> value["Denominators"][[i]], "Geometry" -> value["Geometry"][[i]]|>,
    {i, Length[value["Denominators"]]}],
  {file, Sort[FileNames["*.wl", previousCache]]}], 1];

physical = Q2 > 0 && s > s23 > 0 && s23 - Q2 - s < t < -Q2 s23/s;
$Assumptions = physical;
mink[v_, w_] := Expand[v.DiagonalMatrix[{1, -1, -1, -1}].w];
sphere[e_] := Factor[Expand[e] /. nx^2 -> 1 - ny^2 - nz^2];

(* Choose k1 along the last axis and solve every energy and component. *)
rest = {Sqrt[s23], 0, 0, 0};
pVector = {eP, pX, 0, pZ};
kVector = {eK, 0, 0, eK};
qVector = rest + kVector - pVector;
onShellP[e_] := Factor[Expand[e] /. pX^2 -> eP^2 - pZ^2];
energySolution = First[Solve[{
  onShellP[mink[pVector + qVector, pVector + qVector]] == s,
  onShellP[mink[qVector - kVector, qVector - kVector]] == t}, {eP, eK}]];
longitudinalSolution = First[Solve[
  (onShellP[mink[qVector, qVector]] /. energySolution) == -Q2, pZ]];
components = Join[energySolution, longitudinalSolution];
transverseSquared = Factor[(eP^2 - pZ^2) /. components];
gate["physical rest-frame transverse square", FullSimplify[transverseSquared > 0, physical]];
components = Append[components, pX -> Sqrt[transverseSquared]];
k2Vector = e2 {1, nx, ny, nz};
unobservedEnergy = First[Solve[sphere[mink[rest - k2Vector, rest - k2Vector]] == 0, e2]];
k2Vector = k2Vector /. unobservedEnergy;
frame = <|p -> (pVector /. components), q -> (qVector /. components),
  k1 -> (kVector /. components), k2 -> k2Vector, k3 -> rest - k2Vector|>;
frame = Map[FullSimplify[#, physical] &, frame];
gate["rest-frame conditions resolved in the physical region", FreeQ[frame, _ConditionalExpression]];
angularRules = {a12 -> sphere[mink[frame[k1] + frame[k2], frame[k1] + frame[k2]]],
  u3 -> sphere[mink[frame[p] - frame[k3], frame[p] - frame[k3]]]};
angularRules = FullSimplify[angularRules, physical];
gate["angular rules contain no unresolved conditions", FreeQ[angularRules, _ConditionalExpression]];
gate["rest frame reproduces all invariant scalar products", And @@
  (FullSimplify[sphere[mink[frame[#[[1]]], frame[#[[2]]]]] -
    (#[[3]] /. angularRules), physical] === 0 & /@ input["RealScalarProducts"])];

(* A change of spectator integration variables can identify an odd integrand. *)
momentumBasis = {p, q, k1, k2, k3};
gram = Table[First[Select[input["RealScalarProducts"],
  Sort[Take[#, 2]] === Sort[{v, w}] &]][[3]], {v, momentumBasis}, {w, momentumBasis}];
square[v_] := Factor[(Coefficient[v, #] & /@ momentumBasis).gram.(Coefficient[v, #] & /@ momentumBasis)];
exchangeRules = {a12 -> square[k1 + k3], u3 -> square[p - k2]};
gate["spectator exchange is an invariant involution",
  And @@ Thread[(Factor /@ (({a12, u3} /. exchangeRules /. exchangeRules) - {a12, u3})) == 0]];
gate["spectator exchange equals angular reversal",
  And @@ Thread[FullSimplify[((({a12, u3} /. exchangeRules) /. angularRules) -
    (({a12, u3} /. angularRules) /. {nx -> -nx, nz -> -nz})), physical] == 0]];
angularMeasure = Sin[theta]^(1 - 2 eps) Sin[phi]^(-2 eps);
angleExchange = {theta -> Pi - theta, phi -> Pi - phi};
gate["spectator exchange preserves the paper angular measure",
  FullSimplify[(angularMeasure /. angleExchange)/angularMeasure *
    Abs[Det[Outer[D, {theta, phi} /. angleExchange, {theta, phi}]]],
    0 < theta < Pi && 0 < phi < Pi && Element[eps, Reals]] === 1];

(* Multiplication by unity from the null space of denominator gradients. *)
splitDenominators[denominators_, powers_] := Module[{gradients, reduce, answer},
  gradients = ({Coefficient[#, a12], Coefficient[#, u3]} & /@ denominators);
  (* Use independent formal monomials so Total acts on coefficients only. *)
  Clear[reduce];
  reduce[exponents_List] := reduce[exponents] = Module[{support, subset, weights, constant},
    support = Flatten[Position[exponents, _?(# > 0 &)]];
    subset = SelectFirst[Subsets[support, {2}],
      Det[gradients[[#]]] === 0 &, Missing["None"]];
    If[MissingQ[subset] && Length[support] <= 2, Return[denominatorMonomial[exponents]]];
    If[MissingQ[subset], subset = Take[support, 3]];
    weights = First[NullSpace[Transpose[gradients[[subset]]]]];
    constant = Factor[weights.denominators[[subset]]];
    gate["angular partial-fraction unity relation", FreeQ[constant, a12 | u3] && constant =!= 0];
    Total[Table[weights[[i]]/constant reduce[ReplacePart[exponents,
      subset[[i]] -> exponents[[subset[[i]]]] - 1]], {i, Length[subset]}]]];
  answer = Collect[Expand[reduce[powers]], _denominatorMonomial, Factor];
  If[Head[answer] === Plus, List @@ answer, {answer}]];

geometryFor[denominator_] := geometryFor[denominator] = Module[
  {saved, value, expression, offset, vector, normSquared, massless, sign, scale, dValue},
  saved = SelectFirst[geometrySeeds, #["Denominator"] === denominator &, Missing["None"]];
  If[!MissingQ[saved],
    value = saved["Geometry"];
    gate["same-channel geometry reconstructs its defining angular form", bounded[
      FullSimplify[value["Scale"] (value["d"] - value["Direction"].{nx, ny, nz}) -
        (denominator /. angularRules), physical], "reused angular geometry"] === 0];
    Return[value]];
  expression = Expand[denominator /. angularRules];
  offset = expression /. {nx -> 0, ny -> 0, nz -> 0};
  vector = Coefficient[expression, #] & /@ {nx, ny, nz};
  normSquared = Factor[vector.vector];
  massless = FullSimplify[offset^2 - normSquared, physical] === 0;
  sign = FullSimplify[Sign[offset], physical];
  gate["angular scale sign determined", MemberQ[{-1, 1}, sign]];
  scale = If[massless, offset, sign Sqrt[normSquared]];
  dValue = FullSimplify[offset/scale, physical];
  gate["paper angular case applies", massless ||
    FullSimplify[normSquared > 0 && offset^2 > normSquared, physical]];
  <|"Massless" -> massless, "Scale" -> scale, "d" -> dValue, "Direction" -> -vector/scale|>];

makeBasis[mode_] := Module[{value, factors, angleFactors, denominators, powers,
  independent, numerator, split, terms = {}, monomial, coefficient, exponents,
  support, choice, solution, polynomial, rows, reconstructed, forms, geometries,
  rowCache = <||>, rowKey, rowFile, rowSaved},
  Print[mode, ": factoring angular denominators."];
  value = basisInputs[mode];
  If[bounded[Factor[value + (value /. exchangeRules)], {mode, "spectator parity"}] === 0,
    Print[mode, ": angular integral vanishes by exact spectator exchange."];
    Return[<|"Denominators" -> {}, "Terms" -> {}, "Geometry" -> {}, "ExchangeOdd" -> True|>]];
  factors = FactorList[Denominator[value]];
  angleFactors = Select[factors, !FreeQ[First[#], a12 | u3] &];
  denominators = DeleteDuplicates[Join[First /@ angleFactors, {a12, u3}]];
  powers = Table[Total[Last /@ Select[angleFactors, First[#] === denominator &]],
    {denominator, denominators}];
  geometries = geometryFor /@ denominators;
  independent = Times @@ (Power @@@ Select[factors, FreeQ[First[#], a12 | u3] &]);
  numerator = Numerator[value]/independent;
  split = splitDenominators[denominators, powers];
  Print[mode, ": reducing ", Length[split], " denominator terms."];
  Do[
    monomial = First[Cases[part, _denominatorMonomial, {0, Infinity}]];
    coefficient = part/monomial;
    exponents = monomial[[1]];
    support = Flatten[Position[exponents, _?(# > 0 &)]];
    choice = If[Length[support] === 2, support,
      SelectFirst[Subsets[Range[Length[denominators]], {2}],
        SubsetQ[#, support] && Det[({Coefficient[#, a12], Coefficient[#, u3]} & /@
          denominators[[#]])] =!= 0 &]];
    rowKey = StringRiffle[ToString /@ choice, "_"];
    If[!KeyExistsQ[rowCache, rowKey],
      rowFile = FileNameJoin[{basisCache, mode <> "_rows_" <> rowKey <> ".wl"}];
      rowSaved = If[FileExistsQ[rowFile], Get[rowFile], <||>];
      If[Lookup[rowSaved, "InputHash", None] === basisHash,
        rows = rowSaved["Rows"],
        Print[mode, ": coefficient coordinates ", choice];
        solution = FullSimplify[First[Solve[Thread[denominators[[choice]] == {v, w}], {a12, u3}]], physical];
        gate["denominator substitution conditions resolved", FreeQ[solution, _ConditionalExpression]];
        polynomial = numerator /. solution;
        rows = bounded[CoefficientRules[polynomial, {v, w}], {mode, choice, "coefficient rules"}];
        gate["coefficients contain no angular variables", FreeQ[Last /@ rows, a12 | u3 | v | w]];
        atomicPut[<|"InputHash" -> basisHash, "Rows" -> rows|>, rowFile]];
      AssociateTo[rowCache, rowKey -> rows]];
    rows = rowCache[rowKey];
    terms = Join[terms, ({choice[[1]], choice[[2]],
      exponents[[choice[[1]]]] - #[[1, 1]], exponents[[choice[[2]]]] - #[[1, 2]],
      coefficient #[[2]]} & /@ rows)], {part, split}];
  terms = ({#[[1, 1]], #[[1, 2]], #[[1, 3]], #[[1, 4]], Factor[Total[#[[All, 5]]]]} & /@
    GatherBy[terms, Take[#, 4] &]);
  terms = Select[terms, Last[#] =!= 0 &];
  reconstructed = Total[(#[[5]] denominators[[#[[1]]]]^(-#[[3]])
    denominators[[#[[2]]]]^(-#[[4]]) & /@ terms)];
  gate[mode <> " exact angular reconstruction", bounded[Together[value - reconstructed], mode] === 0];
  Print[mode, ": ", Length[terms], " angular monomials accepted."];
  <|"Denominators" -> denominators, "Terms" -> terms, "Geometry" -> geometries|>];

verifyBasis[mode_, value_] := Module[{denominators, reconstructed},
  If[TrueQ[Lookup[value, "ExchangeOdd", False]],
    Return[bounded[Factor[basisInputs[mode] +
      (basisInputs[mode] /. exchangeRules)], "cached spectator parity"] === 0]];
  denominators = value["Denominators"];
  reconstructed = Total[Table[row[[5]] denominators[[row[[1]]]]^(-row[[3]])
    denominators[[row[[2]]]]^(-row[[4]]), {row, value["Terms"]}]];
  bounded[Together[basisInputs[mode] - reconstructed], "cached angular reconstruction"] === 0];
basisTask[mode_] := Catch[Module[{file, saved, value, previousFile},
  file = FileNameJoin[{basisCache, mode <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[saved["InputHash"] === basisHash, Return[mode -> saved["Value"]]]];
  previousFile = FileNameJoin[{previousCache, mode <> ".wl"}];
  If[FileExistsQ[previousFile],
    saved = Get[previousFile];
    gate["previous component input identity", saved["InputHash"] === previousHash];
    value = saved["Value"];
    gate[mode <> " reused basis reconstructs current input", verifyBasis[mode, value]],
    value = MemoryConstrained[TimeConstrained[makeBasis[mode], 3600,
      gate[mode <> " whole-basis time limit", False]], 2*1024^3,
      gate[mode <> " whole-basis memory limit", False]]];
  atomicPut[<|"InputHash" -> basisHash, "Value" -> value|>, file];
  mode -> value], "StageFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
Print["Parallel budget inputs: ", InputForm[{slots, $ProcessorCount, $MaxLicenseSubprocesses}]];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Length[basisTasks]],
  "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Length[basisTasks]]], 60, $Failed]];
workerCount = If[ListQ[Kernels[]], Length[Kernels[]], 0];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["angular workers share compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[gate, bounded, atomicPut, mink, sphere, splitDenominators,
    geometryFor, geometrySeeds, makeBasis, verifyBasis, basisTask, root, input, basisInputs, physical,
    angularRules, exchangeRules, basisCache, basisHash, previousCache, previousHash];
  ParallelEvaluate[$Assumptions = physical],
  runtimeEvidence = {}; Print["Parallel launch unavailable; bounded tasks run serially."]];
Print["Angular worker count = ", workerCount];
$DistributedContexts = None;
values = If[workerCount > 0, ParallelMap[basisTask, basisTasks, Method -> "FinestGrained"],
  basisTask /@ basisTasks];
gate["all component angular bases completed", FreeQ[values, $Failed | $Aborted]];
partialBases = Association[values];
CloseKernels[];
mergeBases[key_] := Module[{aliases, pieces, denominators, geometries, matches, terms, groups,
  value, file, saved, coefficients, degree, remapped},
  aliases = taskGroups[key];
  If[Length[aliases] === 1 && First[aliases] === key, Return[partialBases[key]]];
  pieces = Lookup[partialBases, aliases];
  denominators = DeleteDuplicates[Flatten[Lookup[pieces, "Denominators"]]];
  geometries = Table[
    matches = Flatten[Table[Table[If[piece["Denominators"][[i]] === denominator,
      {piece["Geometry"][[i]]}, {}], {i, Length[piece["Denominators"]]}], {piece, pieces}], 2];
    gate["equal merged denominators have the same angular geometry", Length[matches] > 0 && SameQ @@ matches];
    First[matches], {denominator, denominators}];
  terms = Flatten[Table[
    Table[remapped = row;
      remapped[[1]] = First[FirstPosition[denominators, piece["Denominators"][[row[[1]]]]]];
      remapped[[2]] = First[FirstPosition[denominators, piece["Denominators"][[row[[2]]]]]];
      remapped, {row, piece["Terms"]}], {piece, pieces}], 1];
  groups = GatherBy[terms, Take[#, 4] &];
  Print[key, ": merging ", Length[aliases], " verified pairs into ", Length[groups], " angular monomials"];
  coefficients = Table[
    file = FileNameJoin[{basisCache, key <> "_merge_" <> ToString[i] <> ".wl"}];
    saved = If[FileExistsQ[file], Get[file], <||>];
    If[Lookup[saved, "InputHash", None] === basisHash, saved["Value"],
      Print[key, " merged coefficient ", i, "/", Length[groups]];
      value = bounded[Factor[Total[groups[[i, All, 5]]]], {key, i, "merged coefficient"}];
      gate["merged angular coefficient reconstructs its pair sum",
        bounded[Together[value - Total[groups[[i, All, 5]]]], {key, i, "merge identity"}] === 0];
      atomicPut[<|"InputHash" -> basisHash, "Value" -> value|>, file]; value],
    {i, Length[groups]}];
  terms = Table[Append[Take[First[groups[[i]]], 4], coefficients[[i]]], {i, Length[groups]}];
  terms = Select[terms, Last[#] =!= 0 &];
  Print[key, ": ", Length[terms], " angular monomials accepted by the exact pair/merge identity chain"];
  value = <|"Denominators" -> denominators, "Geometry" -> geometries, "Terms" -> terms,
    "VerifiedPairTasks" -> aliases, "ReconstructionProof" -> "S03 pair sum, each pair basis, each merged coefficient"|>;
  atomicPut[<|"InputHash" -> basisHash, "Value" -> value|>, FileNameJoin[{basisCache, key <> ".wl"}]];
  value];
result = Association@Table[key -> mergeBases[key], {key, tensorKeys}];
atomicPut[<|"Basis" -> result, "Components" -> input["Components"],
  "OtherChargeMomentDefinitions" -> input["OtherChargeMomentDefinitions"],
  "TensorKeys" -> tensorKeys, "PairInputHashes" -> pairHashes, "PairTaskGroups" -> taskGroups,
  "SpectatorExchangeRules" -> exchangeRules,
  "Frame" -> frame, "AngularRules" -> angularRules,
  "PhysicalRegion" -> physical, "ParallelRuntime" -> runtimeEvidence, "InputHash" -> FileHash[FileNameJoin[{root, "s03_result.wl"}], "SHA256"],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s05_result.wl"}]];
Print["S05_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

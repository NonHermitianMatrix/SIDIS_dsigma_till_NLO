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

makeBasis[mode_] := Module[{value, factors, angleFactors, denominators, powers,
  independent, numerator, split, terms = {}, monomial, coefficient, exponents,
  support, choice, solution, polynomial, rows, reconstructed, forms, geometries},
  Print[mode, ": factoring angular denominators."];
  value = input["Contractions"][mode];
  If[bounded[Factor[value + (value /. exchangeRules)], {mode, "spectator parity"}] === 0,
    Print[mode, ": angular integral vanishes by exact spectator exchange."];
    Return[<|"Denominators" -> {}, "Terms" -> {}, "Geometry" -> {}, "ExchangeOdd" -> True|>]];
  factors = FactorList[Denominator[value]];
  angleFactors = Select[factors, !FreeQ[First[#], a12 | u3] &];
  denominators = DeleteDuplicates[Join[First /@ angleFactors, {a12, u3}]];
  powers = Table[Total[Last /@ Select[angleFactors, First[#] === denominator &]],
    {denominator, denominators}];
  forms = Table[With[{expression = Expand[denominator /. angularRules]},
    {expression /. {nx -> 0, ny -> 0, nz -> 0},
      Coefficient[expression, #] & /@ {nx, ny, nz}}], {denominator, denominators}];
  geometries = Table[Module[{offset, vector, normSquared, massless, sign, scale, d},
    {offset, vector} = form;
    normSquared = Factor[vector.vector];
    massless = FullSimplify[offset^2 - normSquared, physical] === 0;
    sign = FullSimplify[Sign[offset], physical];
    gate["angular scale sign determined", MemberQ[{-1, 1}, sign]];
    scale = If[massless, offset, sign Sqrt[normSquared]];
    d = FullSimplify[offset/scale, physical];
    Print["Angular norm and gap: ", InputForm[{normSquared, Factor[offset^2 - normSquared]}]];
    gate["paper angular case applies", massless ||
      FullSimplify[normSquared > 0 && offset^2 > normSquared, physical]];
    <|"Massless" -> massless, "Scale" -> scale, "d" -> d, "Direction" -> -vector/scale|>],
    {form, forms}];
  independent = Times @@ (Power @@@ Select[factors, FreeQ[First[#], a12 | u3] &]);
  numerator = Collect[Numerator[value]/independent, {a12, u3}, Factor];
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
    solution = FullSimplify[First[Solve[Thread[denominators[[choice]] == {v, w}], {a12, u3}]], physical];
    gate["denominator substitution conditions resolved", FreeQ[solution, _ConditionalExpression]];
    polynomial = bounded[Collect[numerator /. solution, {v, w}, Factor], {mode, choice}];
    rows = CoefficientRules[polynomial, {v, w}];
    If[!FreeQ[Last /@ rows, a12 | u3 | v | w],
      atomicPut[<|"Solution" -> solution, "Polynomial" -> polynomial, "Rows" -> rows,
        "Choice" -> choice, "Denominators" -> denominators|>,
        FileNameJoin[{root, "s05_" <> mode <> "_coefficient_diagnostic.wl"}]]];
    gate["coefficients contain no angular variables", FreeQ[Last /@ rows, a12 | u3 | v | w]];
    terms = Join[terms, ({choice[[1]], choice[[2]],
      exponents[[choice[[1]]]] - #[[1, 1]], exponents[[choice[[2]]]] - #[[1, 2]],
      Factor[coefficient #[[2]]]} & /@ rows)], {part, split}];
  terms = ({#[[1, 1]], #[[1, 2]], #[[1, 3]], #[[1, 4]], Factor[Total[#[[All, 5]]]]} & /@
    GatherBy[terms, Take[#, 4] &]);
  terms = Select[terms, Last[#] =!= 0 &];
  reconstructed = Total[(#[[5]] denominators[[#[[1]]]]^(-#[[3]])
    denominators[[#[[2]]]]^(-#[[4]]) & /@ terms)];
  gate[mode <> " exact angular reconstruction", bounded[Together[value - reconstructed], mode] === 0];
  Print[mode, ": ", Length[terms], " angular monomials accepted."];
  <|"Denominators" -> denominators, "Terms" -> terms, "Geometry" -> geometries|>];

basisTask[mode_] := Catch[Module[{file, saved, value},
  file = FileNameJoin[{basisCache, mode <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[saved["InputHash"] === basisHash, Return[mode -> saved["Value"]]]];
  value = bounded[makeBasis[mode], mode <> " basis"];
  atomicPut[<|"InputHash" -> basisHash, "Value" -> value|>, file];
  mode -> value], "StageFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
Print["Parallel budget inputs: ", InputForm[{slots, $ProcessorCount, $MaxLicenseSubprocesses}]];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Length[tensorKeys]],
  "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Length[tensorKeys]]], 60, $Failed]];
workerCount = If[ListQ[Kernels[]], Length[Kernels[]], 0];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["angular workers share compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[gate, bounded, atomicPut, mink, sphere, splitDenominators,
    makeBasis, basisTask, root, input, physical, angularRules, exchangeRules, basisCache, basisHash];
  ParallelEvaluate[$Assumptions = physical],
  runtimeEvidence = {}; Print["Parallel launch unavailable; bounded tasks run serially."]];
Print["Angular worker count = ", workerCount];
$DistributedContexts = None;
values = If[workerCount > 0, ParallelMap[basisTask, tensorKeys, Method -> "FinestGrained"],
  basisTask /@ tensorKeys];
gate["all component angular bases completed", FreeQ[values, $Failed | $Aborted]];
result = Association[values];
CloseKernels[];
atomicPut[<|"Basis" -> result, "Components" -> input["Components"],
  "OtherChargeMomentDefinitions" -> input["OtherChargeMomentDefinitions"],
  "TensorKeys" -> tensorKeys, "SpectatorExchangeRules" -> exchangeRules,
  "Frame" -> frame, "AngularRules" -> angularRules,
  "PhysicalRegion" -> physical, "ParallelRuntime" -> runtimeEvidence, "InputHash" -> FileHash[FileNameJoin[{root, "s03_result.wl"}], "SHA256"],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s05_result.wl"}]];
Print["S05_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];


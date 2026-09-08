(* Paper B18-B28: angular master integrals, retaining the coalescing power. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
ClearAll[gate, bounded, expansion, hg, phiMoment, polarMoment, massivePolar,
  polynomialAngular, mixedPositive, evaluateMaster];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  gate["time limit " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[label, InputForm], False]];
expansion[expr_, order_] := Normal[Series[expr, {eps, 0, order}]];
gate["accepted angular basis exists", FileExistsQ[FileNameJoin[{root, "s05_result.wl"}]]];
input = Get[FileNameJoin[{root, "s05_result.wl"}]];
gate["S05 source identity", input["SourceHash"] === FileHash[FileNameJoin[{root, "s05_real_angular_basis.wl"}], "SHA256"]];
cache = FileNameJoin[{root, "s06_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"],
  FileHash[FileNameJoin[{root, "s05_result.wl"}], "SHA256"]}, "SHA256"];
acceptedHashes = {inputHash};
$Assumptions = d > 1 && -1 < c < 1;

requested = DeleteDuplicates[Flatten[Table[
  geometry = input["Basis"][mode]["Geometry"];
  Table[Which[
    geometry[[term[[1]]]]["Massless"] && geometry[[term[[2]]]]["Massless"],
      {"LL", term[[3]], term[[4]]},
    !geometry[[term[[1]]]]["Massless"] && geometry[[term[[2]]]]["Massless"],
      {"ML", term[[3]], term[[4]]},
    geometry[[term[[1]]]]["Massless"] && !geometry[[term[[2]]]]["Massless"],
      {"ML", term[[4]], term[[3]]}, True, gate["at most one massive angular denominator", False]],
    {term, input["Basis"][mode]["Terms"]}], {mode, {"Pg", "Ppp"}}], 1]];
Print["Required angular masters: ", Length[requested]];
atomicPut[requested, FileNameJoin[{root, "s06_required.wl"}]];

(* Euler transformation and the defining hypergeometric series generate B27. *)
parameters = {1, 1, 1 - eps};
eulerPower = parameters[[3]] - parameters[[1]] - parameters[[2]];
transformedParameters = {parameters[[3]] - parameters[[1]],
  parameters[[3]] - parameters[[2]], parameters[[3]]};
seriesTerm = (Gamma[transformedParameters[[1]] + n]/Gamma[transformedParameters[[1]]]) *
  (Gamma[transformedParameters[[2]] + n]/Gamma[transformedParameters[[2]]])/
  ((Gamma[transformedParameters[[3]] + n]/Gamma[transformedParameters[[3]]]) Gamma[n + 1]);
seriesFactors = If[Head[seriesTerm] === Times, List @@ seriesTerm, {seriesTerm}];
expandedFactors = Table[Print["Hypergeometric Gamma factor ", index, "/", Length[seriesFactors]];
  bounded[Normal[Series[seriesFactors[[index]], {eps, 0, 2},
    Assumptions -> Element[n, Integers] && n >= 1]], {"Gamma factor", index}],
  {index, Length[seriesFactors]}];
expandedSeriesTerm = expansion[Times @@ expandedFactors, 2];
seedCoefficients = Table[bounded[FullSimplify[Coefficient[expandedSeriesTerm, eps, order],
  Element[n, Integers] && n >= 1], {"hypergeometric coefficient", order}], {order, 0, 2}];
Print["Hypergeometric series coefficients: ", InputForm[seedCoefficients]];
seedTaylor = 1 + Sum[eps^order bounded[Sum[seedCoefficients[[order + 1]] z^n,
  {n, 1, Infinity}, Assumptions -> Abs[z] < 1], {"hypergeometric sum", order}], {order, 0, 2}];
seed = (1 - z)^eulerPower seedTaylor;
ode = z (1 - z) D[seed, {z, 2}] +
  (parameters[[3]] - (parameters[[1]] + parameters[[2]] + 1) z) D[seed, z] -
  parameters[[1]] parameters[[2]] seed;
gate["generated hypergeometric expansion satisfies its defining equation",
  FullSimplify[expansion[ode, 2], 0 < z < 1] === 0];

hg[j_Integer, l_Integer] := hg[j, l] = Which[
  j <= 0 || l <= 0, Sum[Pochhammer[j, k] Pochhammer[l, k] z^k/
    (Pochhammer[parameters[[3]], k] k!), {k, 0, Min[Select[{-j, -l}, # >= 0 &]]}],
  j == 1 && l == 1, hseed,
  j == 1, hg[l, j],
  True, Module[{a = j - 1, b = l, higher}, higher /. First[Solve[
    (parameters[[3]] - 2 a + (a - b) z) hg[a, b] + a (1 - z) higher -
    (parameters[[3]] - a) hg[a - 1, b] == 0, higher]]]];

(* These templates are integrated in their convergence domains, then continued. *)
betaTemplate = Integrate[y^aa (1 - y)^bb, {y, 0, 1},
  Assumptions -> aa > -1 && bb > -1, GenerateConditions -> False];
phiMoment[m_Integer] := phiMoment[m] = bounded[FullSimplify[
  Integrate[Cos[phi]^m Sin[phi]^(-2 eps), {phi, 0, Pi},
    Assumptions -> eps < 0, GenerateConditions -> False]], {"azimuth moment", m}];
polarMoment[m_Integer, l_Integer] := polarMoment[m, l] = Module[{prefactor, polynomial},
  prefactor = FullSimplify[-D[1 - 2 y, y] (1 - (1 - 2 y)^2)^(-eps)/
    (1 - (1 - 2 y))^l/(y^(-eps - l) (1 - y)^(-eps)),
    0 < y < 1 && Element[eps, Reals]];
  polynomial = Expand[(1 - 2 y)^m];
  prefactor Sum[Coefficient[polynomial, y, k] (betaTemplate /.
    {aa -> k - eps - l, bb -> -eps}), {k, 0, m}]];

singlePolarCoefficient[order_] := Module[{integrand, transformed, logArgument,
  logFactor, logReplacement, pieces, template, answer},
  Print["Single massive polar integral, coefficient ", order];
  integrand = Coefficient[expansion[(1 - x^2)^(-eps)/(d - x), 1], eps, order];
  transformed = (integrand /. x -> 2 y - 1) D[2 y - 1, y];
  logArgument = 1 - (2 y - 1)^2;
  logFactor = Cancel[logArgument/(y (1 - y))];
  logReplacement = Log[logFactor] + Log[y] + Log[1 - y];
  gate["polar logarithm splits in its integration domain", FullSimplify[
    Log[logArgument] - logReplacement, 0 < y < 1] === 0];
  transformed = Expand[transformed /. Log[logArgument] -> logReplacement];
  pieces = If[Head[transformed] === Plus, List @@ transformed, {transformed}];
  template = Integrate[Log[y]/(1 - z y), {y, 0, 1},
    Assumptions -> z < 1, GenerateConditions -> False];
  answer = Total[Map[Function[piece, Module[{term = piece, rational, denominator, parameter, constant},
    If[!FreeQ[term, Log[1 - y]], term = term /. y -> 1 - y];
    If[FreeQ[term, Log[y]], Return[Integrate[term, {y, 0, 1},
      Assumptions -> d > 1, GenerateConditions -> False]]];
    rational = Cancel[term/Log[y]]; denominator = Denominator[rational];
    parameter = Cancel[-Coefficient[denominator, y]/(denominator /. y -> 0)];
    constant = rational /. y -> 0;
    gate["log integral maps exactly to the linear template", Cancel[
      rational - constant/(1 - parameter y)] === 0];
    gate["linear template is used in its real domain", FullSimplify[parameter < 1, d > 1]];
    constant (template /. z -> parameter)]], pieces]];
  gate["single polar integral evaluated", FreeQ[answer, _Integrate | _ConditionalExpression]];
  FullSimplify[answer, d > 1]];
massivePolar[1] := massivePolar[1] = Total[Table[eps^order bounded[
  singlePolarCoefficient[order], {"single massive polar integral", order}], {order, 0, 1}]];
massivePolar[j_Integer] /; j > 1 := massivePolar[j] = Module[{normalization},
  normalization = FullSimplify[D[1/(d - x), {d, j - 1}] (d - x)^j];
  D[massivePolar[1], {d, j - 1}]/normalization];

polynomialAngular[j_Integer, l_Integer] := Module[{polynomial, rows, integratedPhi,
  quotient, remainder, shifted, answer},
  polynomial = If[j <= 0, Expand[(d - c x - Sqrt[1 - c^2] y)^(-j)],
    Expand[(1 - c x - Sqrt[1 - c^2] y)^(-l)]];
  rows = CoefficientRules[polynomial, {y}];
  integratedPhi = Total[(#[[2]] (1 - x^2)^(#[[1, 1]]/2) phiMoment[#[[1, 1]]] & /@ rows)];
  integratedPhi = Expand[integratedPhi];
  gate["azimuth integration leaves a polar polynomial", PolynomialQ[integratedPhi, x]];
  If[j <= 0,
    answer = Total[(#[[2]] polarMoment[#[[1, 1]], l] & /@
      CoefficientRules[integratedPhi, {x}])],
    {quotient, remainder} = PolynomialQuotientRemainder[integratedPhi, (d - x)^j, x];
    shifted = Expand[remainder /. x -> d - y];
    answer = Total[(#[[2]] polarMoment[#[[1, 1]], 0] & /@
      CoefficientRules[quotient, {x}])] +
      Total[(#[[2]] massivePolar[j - #[[1, 1]]] & /@ CoefficientRules[shifted, {y}])]];
  expansion[answer, 1]];

mixedBase[j_Integer, l_Integer] := Module[{dimension, prefactor, w, f, fSeries,
  endpoint, endpointTaylor, zeroth, first, regularIntegrands, regularIntegrals},
  dimension = 4 - 2 eps;
  prefactor = (-1)^(l + 1) 2^(1 - l - j) Pi Gamma[dimension - 3] *
    Gamma[2 + l - dimension/2] Gamma[dimension/2 - l - 1]/
    (Gamma[dimension/2 - 1]^2 Gamma[dimension/2 - 2] Gamma[3 - dimension/2]);
  w = (1 + c) z/(d - 1 + 2 z);
  f = z^(dimension/2 - 2)/(z + (d - 1)/2)^j *
    ((hg[j, l] /. hseed -> seed) /. z -> w);
  fSeries = expansion[f, 2];
  endpointTaylor[expr_] := Sum[(D[expr, {z, k}] /. z -> 1) (z - 1)^k/k!, {k, 0, l - 1}];
  endpoint = Sum[(D[fSeries, {z, k}] /. z -> 1) (-1)^k/k! *
    (betaTemplate /. {aa -> 0, bb -> -eps - l + k}), {k, 0, l - 1}];
  zeroth = Coefficient[fSeries, eps, 0]; first = Coefficient[fSeries, eps, 1];
  regularIntegrands = {Together[(zeroth - endpointTaylor[zeroth])/(1 - z)^l],
    Together[(first - endpointTaylor[first] - Log[1 - z] (zeroth - endpointTaylor[zeroth]))/(1 - z)^l]};
  regularIntegrals = Table[Print["Mixed master ", j, ",", l, "; regular coefficient ", order];
    bounded[Integrate[regularIntegrands[[order + 1]], {z, 0, 1},
      Assumptions -> d > 1 && -1 < c < 1, GenerateConditions -> False],
      {"mixed master", j, l, order}], {order, 0, 1}];
  expansion[prefactor (endpoint + regularIntegrals[[1]] + eps regularIntegrals[[2]]), 1]];

(* Integrate a polar total derivative in the regulated convergence domain. *)
mixedIBP[j_Integer, l_Integer] := Module[{a, b, flux, integrand, phiRule, rational,
  polynomial, relation, solved, normalization, assumptions},
  Print["Deriving angular integration by parts for ", j, ",", l];
  a = d - Cos[theta];
  b = 1 - c Cos[theta] - Sqrt[1 - c^2] Sin[theta] Cos[phi];
  flux = Sin[theta]^(1 - 2 eps) D[a, theta]/(a^j b^l);
  assumptions = d > 1 && -1 < c < 1 && 0 < phi < Pi && eps < -j - l - 2;
  gate["polar integration-by-parts boundary terms vanish", And @@ Table[
    FullSimplify[Limit[flux, theta -> endpoint, Assumptions -> assumptions], assumptions] === 0,
    {endpoint, {0, Pi}}]];
  integrand = FullSimplify[D[flux, theta]/Sin[theta]^(1 - 2 eps),
    d > 1 && -1 < c < 1 && 0 < theta < Pi && 0 < phi < Pi];
  phiRule = First[Solve[bb == (b /. {theta -> ArcCos[x], Cos[phi] -> yy}), yy]];
  rational = Factor[(TrigExpand[integrand] /. {theta -> ArcCos[x], Cos[phi] -> yy}) /. phiRule /. x -> d - aa];
  polynomial = Cancel[rational aa^(j + 1) bb^(l + 1)];
  If[!PolynomialQ[polynomial, {aa, bb}], Print["Unreduced polar relation: ", InputForm[polynomial]]];
  gate["polar total derivative reduces to angular monomials", PolynomialQ[polynomial, {aa, bb}]];
  relation = Total[(#[[2]] ml[j + 1 - #[[1, 1]], l + 1 - #[[1, 2]]] &) /@
    CoefficientRules[polynomial, {aa, bb}]];
  gate["integration-by-parts relation reconstructs its defining integrand", Factor[
    (relation /. ml[u_, v_] :> aa^(-u) bb^(-v)) - rational] === 0];
  solved = unknown /. First[Solve[(relation /. ml[j, l + 1] -> unknown) == 0, unknown]];
  gate["integration-by-parts relation isolates the requested master", FreeQ[solved, ml[j, l + 1] | unknown]];
  expansion[solved /. ml[u_Integer, v_Integer] :>
    If[u > 0 && v > 0, mixedPositive[u, v], polynomialAngular[u, v]], 1]];

mixedPositive[j_Integer, l_Integer] := mixedPositive[j, l] = Module[{file, saved, normalization},
  file = FileNameJoin[{cache, StringRiffle[ToString /@ {"ML", j, l}, "_"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedHashes, saved["InputHash"]],
    Return[saved["Value"]["Regular"]]]];
  Which[j > 1,
    normalization = FullSimplify[D[1/(d - x), {d, j - 1}] (d - x)^j];
    expansion[D[mixedPositive[1, l], {d, j - 1}]/normalization, 1],
    l > 1, mixedIBP[j, l - 1], True, mixedBase[j, l]]];

evaluateMaster[key_List] := Module[{file, saved, type, j, l, value, prefactor, reduced},
  {type, j, l} = key;
  file = FileNameJoin[{cache, StringRiffle[ToString /@ key, "_"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[AssociationQ[saved] && MemberQ[acceptedHashes, saved["InputHash"]],
    Return[saved["Value"]]]];
  Print["Angular master ", InputForm[key], "; memory = ", MemoryInUse[]];
  If[type === "LL",
    prefactor = 2 Pi Gamma[1 - 2 eps]/Gamma[1 - eps]^2 *
      2^(-j - l) Beta[1 - eps - j, 1 - eps - l];
    reduced = Together[hg[j, l]];
    gate["contiguous reduction is linear in its seed", Exponent[reduced, hseed] <= 1];
    value = <|"Regular" -> expansion[prefactor (reduced /. hseed -> 0), 1],
      "Coalescing" -> expansion[prefactor Coefficient[reduced, hseed]/(1 - z) seedTaylor, 1]|>,
    value = <|"Regular" -> bounded[If[j > 0 && l > 0, mixedPositive[j, l],
      polynomialAngular[j, l]], key], "Coalescing" -> 0|>];
  value = Map[FullSimplify[#, d > 1 && -1 < c < 1 && 0 < z < 1] &, value];
  gate["angular integral fully evaluated", FreeQ[value,
    _Integrate | _Sum | _ConditionalExpression | _SeriesCoefficient | _Derivative | _Real | hseed]];
  gate["at most a single angular pole", And @@ (PolynomialQ[Cancel[eps #], eps] & /@ Values[value])];
  atomicPut[<|"InputHash" -> inputHash, "Value" -> value|>, file];
  value];

masterTask[key_] := Catch[<|"Key" -> key, "Value" -> bounded[evaluateMaster[key], key]|>, "StageFailure"];
slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
If[!IntegerQ[slots] || slots < 1, slots = 1];
Print["Parallel budget inputs: ", InputForm[{slots, $ProcessorCount, $MaxLicenseSubprocesses}]];
CloseKernels[];
configuration = KernelConfiguration["localhost", "KernelCommand" ->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots, Length[requested]],
  "TimeConstraint" -> 60];
launch = TimeConstrained[LaunchKernels[configuration], 60, $Failed];
If[!ListQ[launch], launch = TimeConstrained[LaunchKernels[Min[8, slots, Length[requested]]], 60, $Failed]];
workerCount = If[ListQ[Kernels[]], Length[Kernels[]], 0];
If[workerCount > 0,
  runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
  gate["angular workers share compute node and runtime", And @@
    (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
  ParallelEvaluate[$HistoryLength = 0];
  DistributeDefinitions[gate, bounded, atomicPut, expansion, hg, phiMoment,
    polarMoment, singlePolarCoefficient, massivePolar, polynomialAngular, mixedBase,
    mixedIBP, mixedPositive, evaluateMaster, masterTask, cache, inputHash,
    acceptedHashes, parameters, seedTaylor, seed, betaTemplate, root],
  runtimeEvidence = {}; Print["Parallel launch unavailable; bounded tasks run serially."]];
Print["Angular worker count = ", workerCount];
$DistributedContexts = None;
If[workerCount > 0, ParallelEvaluate[$Assumptions = d > 1 && -1 < c < 1]];
masters = If[workerCount > 0, ParallelMap[masterTask, requested, Method -> "FinestGrained"], masterTask /@ requested];
gate["all requested angular masters completed", FreeQ[masters, $Failed | $Aborted]];
CloseKernels[];
atomicPut[<|"Masters" -> masters, "HypergeometricSeed" -> seed,
  "CoalescingFactor" -> (1 - z)^(-eps), "ParallelRuntime" -> runtimeEvidence, "InputHash" -> inputHash,
  "AcceptedCacheInputHashes" -> acceptedHashes, "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "Order" -> 1, "Regulator" -> eps|>, FileNameJoin[{root, "s06_result.wl"}]];
Print["S06_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

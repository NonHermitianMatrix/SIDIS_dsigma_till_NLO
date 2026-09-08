(* Derive the comparison identities from derivatives and endpoint values. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, logReduce, derive];
gate[label_, test_] := If[TrueQ[test], Print["PASS: ", label], Print["FAIL: ", label]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 120,
  Print["Time limit: ", label]; Quit[2]], 512*1024^2,
  Print["Memory limit: ", label]; Quit[3]];
domain = 0 < z < 1;
logReduce[input_] := FullSimplify[PowerExpand[
  FunctionExpand[input] /. Log[arg_] :> Log[Factor[arg]], Assumptions -> domain], domain];
basis = {PolyLog[2, z], Log[z]^2, Log[1-z]^2, Log[z] Log[1-z], Log[z], Log[1-z]};
coefficients = Array[c, Length[basis]];
derive[argument_] := Module[{target, derivative, logs, slots, polynomial, equations,
  solutions, expression, endpoints, endpoint, direction, constant, value},
  Print["Derive dilogarithm argument ", argument];
  target = PolyLog[2, argument];
  derivative = bounded[logReduce[D[target - coefficients . basis, z]], "identity derivative"];
  logs = DeleteDuplicates[Cases[derivative, _Log, Infinity]];
  slots = Array[ell, Length[logs]];
  polynomial = Numerator[Together[derivative /. Thread[logs -> slots]]];
  gate["identity derivative is polynomial in its formal log basis", PolynomialQ[polynomial, Join[{z}, slots]]];
  equations = Thread[(Last /@ CoefficientRules[polynomial, Join[{z}, slots]]) == 0];
  solutions = Solve[equations, coefficients];
  gate["derivative fixes the logarithmic coefficients uniquely", Length[solutions] === 1];
  expression = coefficients . basis /. First[solutions];
  endpoints = Select[{0, 1}, Function[point, FreeQ[
    Limit[argument, z -> point, Direction -> If[point === 0, "FromAbove", "FromBelow"]],
    Indeterminate | _DirectedInfinity | _Limit]]];
  gate["identity has a finite argument endpoint", endpoints =!= {}];
  endpoint = First[endpoints];
  direction = If[endpoint === 0, "FromAbove", "FromBelow"];
  constant = bounded[Limit[target - expression, z -> endpoint, Direction -> direction], "identity integration constant"];
  value = expression + constant;
  gate["identity constant is evaluated exactly", FreeQ[value, _Limit | _Real | Indeterminate | _DirectedInfinity]];
  gate["identity derivative vanishes", bounded[logReduce[D[target - value, z]] === 0, "identity derivative gate"]];
  gate["identity endpoint residual vanishes", bounded[
    Limit[target - value, z -> endpoint, Direction -> direction] === 0, "identity endpoint gate"]];
  <|"Argument" -> argument, "Value" -> value, "Domain" -> domain,
    "Endpoint" -> endpoint, "DerivativeResidual" -> 0, "EndpointResidual" -> 0|>];
identities = <||>;
Do[
  AssociateTo[identities, item[[1]] -> derive[item[[2]]]];
  Put[<|"Identities" -> identities, "Complete" -> False|>, FileNameJoin[{root, "s13_dilogarithms.wl"}]],
  {item, {{"Inverse", 1/z}, {"Mobius", z/(z-1)}, {"Complement", 1-z}}}];
summandAssumptions = domain && Element[k, Integers] && k >= 1;
realSummand = FullSimplify[Re[z^k/k^2], summandAssumptions];
imaginarySummand = FullSimplify[Im[z^k/k^2], summandAssumptions];
gate["defining series has a summable absolute majorant", FullSimplify[
  Abs[z^k/k^2] <= z^k, summandAssumptions] === True];
majorant = Sum[z^k, {k, 1, Infinity}, Assumptions -> domain];
gate["majorant sum is finite", FreeQ[majorant, _Sum | _DirectedInfinity | Indeterminate]];
realPart = Sum[realSummand, {k, 1, Infinity}, Assumptions -> domain];
imaginaryPart = Sum[imaginarySummand, {k, 1, Infinity}, Assumptions -> domain];
gate["defining real series equals the canonical dilogarithm", realPart === PolyLog[2,z]];
gate["defining imaginary series vanishes", imaginaryPart === 0];
Put[<|"Identities" -> identities, "RealPartOnUnitInterval" -> realPart,
  "ImaginaryPartOnUnitInterval" -> imaginaryPart, "AbsoluteMajorant" -> majorant,
  "Complete" -> True, "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>,
  FileNameJoin[{root, "s13_dilogarithms.wl"}]];
Print["Wrote exact dilogarithm identities."];

input = Get[FileNameJoin[{root, "s13_cache", "F1_1_Delta_input.wl"}]];
value = input["Difference"]; assumptions = input["Assumptions"];
diagnostics = <|"RawFinite" -> FreeQ[value, Indeterminate | _DirectedInfinity]|>;
Print["Delta diagnostic: raw finite = ", diagnostics["RawFinite"]];
Do[
  Print["Delta diagnostic stage ", stage];
  value = bounded[Switch[stage,
    "ArcTanh", value /. a_ArcTanh :> ComplexExpand[a],
    "Refine", Refine[value, assumptions],
    "LogArguments", value /. Log[arg_] :> Log[Factor[arg]],
    "PowerExpand", PowerExpand[value, Assumptions -> assumptions]], {"delta diagnostic", stage}];
  AssociateTo[diagnostics, stage -> FreeQ[value, Indeterminate | _DirectedInfinity]];
  Print["Delta diagnostic ", stage, " finite = ", diagnostics[stage]];
  If[!TrueQ[diagnostics[stage]], Break[]],
  {stage, {"ArcTanh", "Refine", "LogArguments", "PowerExpand"}}];
Put[<|"Checks" -> diagnostics, "Value" -> value, "InputHash" -> input["InputHash"]|>,
  FileNameJoin[{root, "s13_delta_transform_diagnostic.wl"}]];
Print["Wrote delta transformation diagnostic."];
raw = input["Difference"] /. a_ArcTanh :> ComplexExpand[a];
functions = DeleteDuplicates[Cases[raw, _Log | _ArcTan | _ArcTanh | _PolyLog | _Re | _Im, Infinity]];
slots = Array[opaque, Length[functions]];
formal = raw /. Thread[functions -> slots];
badFunctions = {};
Print["Inspect ", Length[functions], " distinct functions before refinement"];
Do[
  If[!FreeQ[formal, slots[[j]]],
    refinedFunction = bounded[Refine[functions[[j]], assumptions], {"function refinement", j}];
    If[!FreeQ[refinedFunction, Indeterminate | _DirectedInfinity],
      Print["Singular refinement at function ", j];
      coefficientsOfFunction = Rest[CoefficientList[Expand[formal, slots[[j]]], slots[[j]]]];
      algebraicCoefficients = bounded[Factor /@ coefficientsOfFunction, {"function coefficients", j}];
      physicalCoefficients = bounded[FullSimplify[algebraicCoefficients, assumptions],
        {"physical function coefficients", j}];
      AppendTo[badFunctions, <|"Index" -> j, "Function" -> functions[[j]],
        "RefinedFunction" -> refinedFunction, "Coefficients" -> algebraicCoefficients,
        "PhysicalCoefficients" -> physicalCoefficients|>]]];
  If[Mod[j, 10] === 0, ClearSystemCache[]; Print["Inspected functions ", j, "/", Length[functions]]],
  {j, Length[functions]}];
Put[<|"BadFunctions" -> badFunctions, "Functions" -> functions,
  "Assumptions" -> assumptions, "InputHash" -> input["InputHash"]|>,
  FileNameJoin[{root, "s13_delta_functions.wl"}]];
Print["Wrote delta function diagnostic; singular function count = ", Length[badFunctions]];
Quit[];

(* Exact equation-driven reduction of large final-reference differences.
   The caller supplies the original domain and bounded/gate functions. *)
Clear[referenceScalarFactor, referenceExactReduce];
referenceScalarFactor[value_, label_] := Module[
  {symbols, variables, aliases, formal, powers, shift, rows, rebuilt, reduced},
  If[value === 0, Return[0]];
  symbols = Select[{SUNN, EulerGamma}, !FreeQ[value, #] &];
  If[symbols === {}, Return[bounded[Factor[value], {label, "rational Factor"}]]];
  variables = Table[Unique["referenceScalar"], {Length[symbols]}];
  aliases = Thread[symbols -> variables]; formal = value /. aliases;
  gate["exact reference scalar aliases", (formal /. Reverse /@ aliases) === value];
  powers = Exponent[formal, #, List] & /@ variables;
  gate["integer reference Laurent support", And @@ (IntegerQ /@ Flatten[powers])];
  shift = Times @@ MapThread[Power, {variables, -(Min /@ powers)}];
  rows = bounded[CoefficientRules[shift formal, variables], {label, "scalar coefficients"}];
  gate["evaluated scalar coefficients", ListQ[rows] && FreeQ[rows, _CoefficientRules]];
  rebuilt = Total[(Last[#] Times @@ MapThread[Power, {variables, First[#]}]) & /@ rows];
  gate["exact reference scalar reconstruction",
    bounded[CoefficientRules[rebuilt, variables], {label, "scalar reconstruction"}] === rows];
  gate["independent reference scalar coefficients",
    And @@ (FreeQ[Last[#], Alternatives @@ variables] & /@ rows)];
  reduced = Table[
    Print["REFERENCE_SCALAR_COMPONENT ", InputForm[label], " ", index, "/", Length[rows]];
    First[rows[[index]]] -> bounded[Factor[Last[rows[[index]]]], {label, index, "scalar Factor"}],
    {index, Length[rows]}];
  Factor[(Total[(Last[#] Times @@ MapThread[Power, {variables, First[#]}]) & /@ reduced]/shift) /.
    Reverse /@ aliases]];

referenceExactReduce[input_, conditions_, label_] := Module[
  {started = AbsoluteTime[], functions, logRows, candidate, proof, rules,
   value, roots, rootRules, base, variables, functionRules, coefficientTable,
   abstract, formal, restorationRules, rows, rebuilt, reduced, coefficientValue,
   residual, nonAlgebraic = _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im},
  functions = DeleteDuplicates[Cases[input, _Log, Infinity]];
  logRows = Table[
    candidate = PowerExpand[fn /. Log[arg_] :> Log[Factor[arg]], Assumptions -> conditions];
    proof = If[candidate === fn, 0,
      bounded[FullSimplify[fn - candidate, conditions], {label, "log identity"}]];
    <|"Original" -> fn, "Replacement" -> If[proof === 0, candidate, fn],
      "Changed" -> (proof === 0 && candidate =!= fn)|>, {fn, functions}];
  rules = (#["Original"] -> #["Replacement"] & /@ logRows);
  value = input /. Dispatch[rules];
  roots = DeleteDuplicates[Cases[value, Power[_, _Rational], Infinity]];
  rootRules = Table[
    base = Factor[Together[r[[1]]]];
    gate["exact reference root argument", Together[r[[1]] - base] === 0];
    r -> Refine[base^r[[2]], conditions], {r, roots}];
  value = value /. Dispatch[rootRules];
  functions = DeleteDuplicates[Cases[value, nonAlgebraic, Infinity]];
  If[functions === {},
    residual = referenceScalarFactor[value, label];
    Return[<|"Residual" -> residual, "Seconds" -> (AbsoluteTime[] - started),
      "LogIdentities" -> logRows, "RootRules" -> rootRules, "CoefficientCount" -> 1,
      "ExactReconstruction" -> True|>]];
  variables = Table[Unique["referenceFunction"], {Length[functions]}];
  functionRules = Thread[functions -> variables]; coefficientTable = <||>;
  abstract[expr_] := Which[
    MatchQ[expr, nonAlgebraic], expr /. functionRules,
    NumberQ[expr], expr,
    FreeQ[expr, nonAlgebraic],
      If[KeyExistsQ[coefficientTable, expr], coefficientTable[expr],
        With[{symbol = Unique["referenceKinematic"]},
          AssociateTo[coefficientTable, expr -> symbol]; symbol]],
    Head[expr] === Plus || Head[expr] === Times, Map[abstract, expr],
    Head[expr] === Power && IntegerQ[expr[[2]]], abstract[expr[[1]]]^expr[[2]],
    True, Print["FAIL: unsupported reference polynomial structure ", InputForm[Shallow[expr]]]; Quit[1]];
  formal = bounded[abstract[value], {label, "function polynomial"}];
  restorationRules = Reverse /@ Normal[coefficientTable];
  gate["exact whole reference input restoration",
    (formal /. Dispatch[Reverse /@ functionRules] /. Dispatch[restorationRules]) === value];
  rows = bounded[CoefficientRules[formal, variables], {label, "function coefficients"}];
  gate["evaluated reference function coefficients", ListQ[rows] && FreeQ[rows, _CoefficientRules]];
  rebuilt = Total[(Last[#] Times @@ MapThread[Power, {variables, First[#]}]) & /@ rows];
  gate["exact reference function reconstruction",
    bounded[CoefficientRules[rebuilt, variables], {label, "function reconstruction"}] === rows];
  gate["independent reference function coefficients",
    And @@ (FreeQ[Last[#], Alternatives @@ variables] & /@ rows)];
  reduced = Table[
    Print["REFERENCE_FUNCTION_COMPONENT ", InputForm[label], " ", index, "/", Length[rows]];
    coefficientValue = Last[rows[[index]]] /. Dispatch[restorationRules];
    gate["complete reference coefficient restoration",
      Intersection[DeleteDuplicates[Cases[coefficientValue, _Symbol, Infinity]],
        Join[variables, First /@ restorationRules]] === {}];
    First[rows[[index]]] -> referenceScalarFactor[coefficientValue, {label, index}],
    {index, Length[rows]}];
  residual = Total[(Last[#] Times @@ MapThread[Power, {functions, First[#]}]) & /@ reduced];
  If[residual =!= 0,
    residual = bounded[FullSimplify[FunctionExpand[residual, conditions], conditions],
      {label, "remaining native function identities"}]];
  <|"Residual" -> residual, "Seconds" -> (AbsoluteTime[] - started),
    "LogIdentities" -> logRows, "RootRules" -> rootRules, "CoefficientCount" -> Length[rows],
    "ExactReconstruction" -> True|>];

(* Derive parent-loop Euler integrands for the actual Kira cut masters. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
zero[expression_] := Factor[Together[expression]] === 0;
put[value_, file_] := (Put[value, file <> ".tmp"];
  RenameFile[file <> ".tmp", file, OverwriteTarget -> True]);
SetAttributes[bounded, HoldFirst];
bounded[expression_, name_] := MemoryConstrained[TimeConstrained[expression, 900,
  gate["time limit " <> ToString[name, InputForm], False]], 2*1024^3,
  gate["memory limit " <> ToString[name, InputForm], False]];
geometry = Get[FileNameJoin[{root, "s02_result.wl"}]];
reduction = Get[FileNameJoin[{root, "s04_result.wl"}]];
gate["accepted real Kira reduction", TrueQ[reduction["Accepted"]] &&
  reduction["SourceHash"] === FileHash[FileNameJoin[{root, "s04_reduce_real.wl"}], "SHA256"]];
sourceHash = FileHash[$InputFileName, "SHA256"];
basis = geometry["BasisMomenta"]; gram = geometry["CommonGram"];
vector[momentum_] := Coefficient[Expand[momentum], #] & /@ basis;
dot[first_, second_] := Factor[vector[first].gram.vector[second]];
chordSymbol[i_, j_] := Symbol["c" <> ToString[Min[i, j]] <> ToString[Max[i, j]]];
directory = FileNameJoin[{root, "common", "s06_parent_inputs"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
entries = <||>; parentInputs = <||>;
Do[
  Print["PARENT_INPUT ", InputForm[master]];
  family = reduction["Families"][master[[1]]];
  gate["master has only zero or unit indices", Complement[master[[2]], {0, 1}] === {}];
  active = Flatten[Position[master[[2]], 1]];
  gate["both cut positions are active", Complement[family["CutPositions"], active] === {}];
  originalMomenta = family["PropagatorMomenta"][[active]];
  leading = Coefficient[#, r] & /@ originalMomenta;
  gate["loop routing uses unit loop coefficients", And @@ (MemberQ[{-1, 1}, #] & /@ leading)];
  routed = MapThread[Cancel[#1/#2] &, {originalMomenta, leading}];
  gate["routing signs preserve every quadratic denominator", And @@ MapThread[
    zero[dot[#1, #1] - dot[#2, #2]] &, {originalMomenta, routed}]];
  shifts = Expand[# - r] & /@ routed;
  distances = Table[dot[shifts[[i]] - shifts[[j]], shifts[[i]] - shifts[[j]]],
    {i, Length[shifts]}, {j, Length[shifts]}];
  (* Permuting scalar propagators changes neither the parent integral nor
     its measure. The chosen physical cut pair is tracked separately. *)
  permutations = Permutations[Range[Length[shifts]]];
  permutation = First[SortBy[permutations, Function[perm,
    Flatten[Map[If[zero[#], 0, 1] &, distances[[perm, perm]], {2}]]]]];
  orderedDistances = distances[[permutation, permutation]];
  cutSlots = Flatten[FirstPosition[permutation, #] & /@ family["CutPositions"]];
  cutSymbol = chordSymbol @@ cutSlots;
  count = Length[shifts];
  pattern = Map[If[zero[#], 0, 1] &, orderedDistances, {2}];
  id = "P" <> ToString[count] <> "_" <> StringJoin[ToString /@ Flatten[pattern]];
  pairs = Subsets[Range[count], {2}];
  nonzeroPairs = Select[pairs, Extract[pattern, #] === 1 &];
  coefficients = chordSymbol @@@ nonzeroPairs;
  physicalRules = Map[Function[pair, (chordSymbol @@ pair) -> -Extract[orderedDistances, pair]], nonzeroPairs];
  gate["selected cut chord is the recoil invariant", zero[(cutSymbol /. physicalRules) + w]];
  If[!KeyExistsQ[parentInputs, id],
    FCClearScalarProducts[];
    external = Take[{pv2, pv3, pv4}, count - 1];
    parentShifts = Prepend[external, 0];
    variables = Table[g[Min[i, j], Max[i, j]], {i, Length[external]}, {j, Length[external]}];
    unknowns = DeleteDuplicates[Flatten[variables]];
    parentVector[momentum_] := Coefficient[Expand[momentum], #] & /@ external;
    parentDot[first_, second_] := Expand[parentVector[first].variables.parentVector[second]];
    equations = Map[Function[pair, parentDot[
      parentShifts[[pair[[1]]]] - parentShifts[[pair[[2]]]],
      parentShifts[[pair[[1]]]] - parentShifts[[pair[[2]]]]] ==
      If[Extract[pattern, pair] === 0, 0, -chordSymbol @@ pair]], pairs];
    solutions = Solve[equations, unknowns];
    gate[id <> " unique generic parent Gram matrix", Length[solutions] === 1];
    gate[id <> " every chord reconstructs", And @@ (TrueQ[Simplify[# /. First[solutions]]] & /@ equations)];
    parentGram = Map[Factor, variables /. First[solutions], {2}];
    Do[With[{first = external[[i]], second = external[[j]], value = parentGram[[i, j]]},
      SPD[first, second] = value], {i, Length[external]}, {j, i, Length[external]}];
    propagators = SFAD[r + #] & /@ parentShifts;
    representation = bounded[FCFeynmanParametrize[Times @@ propagators, {r}, Names -> x,
      FCReplaceD -> {D -> 4 - 2 eps}, FeynmanIntegralPrefactor -> "Unity",
      FCFeynmanPrepare -> True], id <> " Feynman parametrization"];
    put[<|"Representation" -> representation, "ParentGram" -> parentGram,
      "Propagators" -> propagators, "SourceHash" -> sourceHash|>,
      FileNameJoin[{directory, id <> "_derivation.wl"}]];
    gate[id <> " explicit parameter representation", ListQ[representation] &&
      Length[representation] >= 3 && FreeQ[Take[representation, 3],
        _FCFeynmanParametrize | _Pair | r | $Failed | $Aborted]];
    {integrand, prefactor, parameters} = Take[representation, 3];
    gate[id <> " projective parameter count", Length[parameters] === count];
    assumptions = And @@ Join[{scale > 0, Element[eps, Reals]}, # > 0 & /@ Join[parameters, coefficients]];
    scaled = integrand /. Thread[parameters -> scale parameters];
    gate[id <> " projective homogeneity", bounded[
      FullSimplify[scaled scale^Length[parameters]/integrand == 1, assumptions], id <> " homogeneity"]];
    gauge = Last[parameters] -> 1;
    eulerVariables = Most[parameters];
    (* The tuple interface uses logarithmic parameter measures. *)
    tuple = {prefactor, (integrand /. gauge) Times @@ eulerVariables, eulerVariables, coefficients};
    data = <|"ParentID" -> id, "Propagators" -> propagators, "ParentGram" -> parentGram,
      "ZeroPattern" -> pattern, "Representation" -> representation, "Gauge" -> gauge,
      "SubTropicaInput" -> tuple, "EuclideanConditions" -> And @@ (# > 0 & /@ coefficients),
      "MeasureConvention" -> "Unnormalized Minkowski d^D r; FCFeynmanParametrize Unity",
      "ParameterMeasure" -> "Product d x_i / x_i after the recorded projective gauge",
      "SourceHash" -> sourceHash, "IntegralEvaluationPerformed" -> False,
      "Accepted" -> True|>;
    put[data, FileNameJoin[{directory, id <> ".wl"}]];
    AssociateTo[parentInputs, id -> data]];
  AssociateTo[entries, master -> <|"ParentID" -> id, "ActiveIndices" -> active,
    "RoutingSigns" -> leading, "OriginalShifts" -> shifts, "Permutation" -> permutation,
    "PhysicalCutSlots" -> cutSlots, "CutChordSymbol" -> cutSymbol,
    "PhysicalSubstitutions" -> physicalRules, "OriginalChordMatrix" -> distances,
    "CutEnergyConditions" -> geometry["CutEnergyConditions"],
    "CutExtractionPerformed" -> False|>], {master, reduction["Masters"]}];
put[<|"CutMasterParents" -> entries, "ParentInputs" -> parentInputs,
  "SourceHash" -> sourceHash, "ReductionHash" -> FileHash[FileNameJoin[{root, "s04_result.wl"}], "SHA256"],
  "Accepted" -> True, "IntegralEvaluationPerformed" -> False,
  "CutExtractionPerformed" -> False|>, FileNameJoin[{root, "s06_result.wl"}]];
Print["S06_SUCCESS: ", Length[entries], " cut masters use ", Length[parentInputs], " distinct parent Euler integrands."];
Quit[0];

(* Symbolic comparison with the published Hqg coefficients after S12 is fixed. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, checkFrozen, normalize, canonicalAuthors, compare,
  unitDilogarithm, reduceDilogarithm, reduceFunction, reduceAlgebraic];
gate[label_, test_] := If[TrueQ[test], Print["PASS: ", label], Print["FAIL: ", label]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
manifest = Import[FileNameJoin[{root, "s12_frozen_inputs.json"}], "RawJSON"];
checkFrozen[] := KeyValueMap[(gate["frozen " <> #1,
  IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2["sha256"]]) &,
  manifest["files"]];
checkFrozen[];
independent = KeyTake[Get[FileNameJoin[{root, "s12_result.wl"}]],
  {"Hats", "BranchCoordinates", "PhysicalRegion", "RegulatorCancellationPassed", "AuthorsCoefficientsUsed"}];
authors = Get[FileNameJoin[{root, "comparison", "s03_result.wl"}]];
authorMetadata = Import[FileNameJoin[{root, "comparison", "s01_result.json"}], "RawJSON"];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
dilogarithms = Get[FileNameJoin[{root, "s13_dilogarithms.wl"}]];
gate["dilogarithm identities are complete and source bound",
  dilogarithms["Complete"] === True && dilogarithms["SourceHash"] ===
    FileHash[FileNameJoin[{root, "s13_dilogarithm_identities.wl"}], "SHA256"]];
identityHash = FileHash[FileNameJoin[{root, "s13_dilogarithms.wl"}], "SHA256"];
gate["independent result was accepted without authors coefficients",
  independent["RegulatorCancellationPassed"] === True && independent["AuthorsCoefficientsUsed"] === False];
gate["comparison is the requested Hqg channel",
  authors["Channel"] === "incoming quark, observed gluon (Hqg)"];
authorHash = FileHash[FileNameJoin[{root, "comparison", "s03_result.wl"}], "SHA256"];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], manifest, authorHash, authorMetadata, identityHash}, "SHA256"];
cache = FileNameJoin[{root, "s13_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
priorSources = FileNames["s13_source_*.wl", cache];
acceptedInputHashes = DeleteDuplicates[Prepend[(Hash[
  {FileHash[#, "SHA256"], manifest, authorHash, authorMetadata, identityHash}, "SHA256"] &) /@ priorSources, inputHash]];

(* The Gram matrix and transverse projection implement the paper's definitions. *)
momenta = {p, q, k1};
basis = AssociationThread[momenta, IdentityMatrix[Length[momenta]]];
gram = {{pp, pq, pk}, {pq, qq, qk}, {pk, qk, kk}};
dot[a_, b_] := Expand[a . gram . b];
norm[a_] := dot[a, a];
invariantSolutions = Solve[{
  norm[basis[p]] == 0, norm[basis[q]] == -Q^2, norm[basis[k1]] == 0,
  norm[basis[p] + basis[q]] == s, norm[basis[q] - basis[k1]] == t,
  norm[basis[p] + basis[q] - basis[k1]] == s23}, DeleteDuplicates[Flatten[gram]]];
gate["invariant scalar products have a unique solution", Length[invariantSolutions] === 1];
invariantRules = First[invariantSolutions];
xhatExpression = Factor[Q^2/(2 dot[basis[p], basis[q]]) /. invariantRules];
zhatExpression = Factor[dot[basis[p], basis[k1]]/dot[basis[p], basis[q]] /. invariantRules];
kTransverse = basis[k1] - ap basis[p] - aq basis[q];
transverseSolutions = Solve[{
  dot[kTransverse, basis[p]] == 0, dot[kTransverse, basis[q]] == 0}, {ap, aq}];
gate["transverse projection has a unique solution", Length[transverseSolutions] === 1];
kTransverse = kTransverse /. First[transverseSolutions];
gate["transverse projection is orthogonal", And @@ (Factor[# /. invariantRules] === 0 & /@
  {dot[kTransverse, basis[p]], dot[kTransverse, basis[q]]})];
qTExpression = Factor[-norm[-kTransverse/zhatExpression] /. invariantRules];
uExpression = Factor[norm[basis[p] - basis[k1]] /. invariantRules];
kinematicSolutions = Solve[{xh == xhatExpression, qT2 == qTExpression,
  zh == zhatExpression, u == uExpression}, {s, t, zh, u}];
gate["physical-variable map has a unique algebraic solution", Length[kinematicSolutions] === 1];
kinematicRules = First[kinematicSolutions];
gate["derived variable map equals the authors map", And @@ Table[
  Factor[(symbol /. kinematicRules) - (symbol /. authors["KinematicRules"])] === 0,
  {symbol, {s, t, zh, u}}]];
squareScaleRule = First[Solve[Q2 == Q^2, Q2]];
gate["derived kinematics reduce to the independent Born definitions", And @@ Table[
  Factor[(symbol /. {xh -> xhatExpression, zh -> zhatExpression, qT2 -> qTExpression} /. s23 -> 0) -
    (symbol /. born["BornKinematics"] /. squareScaleRule)] === 0, {symbol, {xh, zh, qT2}}]];
colorValues = StringCases[authors["Order"], "SU(" ~~ (digits : DigitCharacter ..) ~~ ")" :> ToExpression[digits]];
gate["authors color specialization is explicit", Length[colorValues] === 1 && IntegerQ[First[colorValues]]];
commonRules = Join[squareScaleRule, {SUNN -> First[colorValues], Nf -> nf}];
names = Association@Table[name -> ("Fhat" <> StringDrop[name, 1]), {name, Keys[independent["Hats"]]}];
gate["both structure functions have author coefficients", Sort[Values[names]] === Sort[Keys[authors["NLOCoefficients"]]]];

(* Derive the coefficient-times-plus identity directly from its action. *)
actionDifference = Expand[(cValue fValue - cEndpoint fEndpoint) kernel -
  (a (fValue - fEndpoint) kernel + (cValue - a) fValue kernel)];
endpointWeightRule = First[Solve[Coefficient[actionDifference, fEndpoint] == 0, a]];
gate["coefficient-times-plus action reconstructs exactly", Expand[actionDifference /. endpointWeightRule] === 0];
scaleAssumptions = Q > 0 && B > 0 && s23 > 0;
logScaleShift = FullSimplify[Log[s23/Q^2] - Log[s23/B], scaleAssumptions];
gate["plus logarithm scale shift is recoil independent", FreeQ[logScaleShift, s23]];
gate["plus logarithm bases reconstruct exactly", FullSimplify[
  Log[s23/Q^2] - Log[s23/B] - logScaleShift, scaleAssumptions] === 0];
physical = authors["PhysicalSupport"] && s23 > 0 && Element[nf, Integers] && nf >= 0 &&
  alphaS > 0 && Element[eq, Reals];
softPhysical = (authors["PhysicalSupport"] /. s23 -> 0) && Element[nf, Integers] && nf >= 0 &&
  alphaS > 0 && Element[eq, Reals];

unitDilogarithm[argument_, assumptions_] := Module[{identity, candidates, chosen},
  identity = dilogarithms["Identities"]["Complement"];
  candidates = SortBy[DeleteDuplicates[{argument, Factor[identity["Argument"] /. z -> argument]}],
    {LeafCount, ToString[#, InputForm] &}];
  chosen = First[candidates];
  If[chosen === argument, Return[PolyLog[2, argument]]];
  gate["complement dilogarithm argument reconstructs", Factor[
    (identity["Argument"] /. z -> chosen) - argument] === 0];
  identity["Value"] /. z -> chosen];

reduceDilogarithm[argument_, assumptions_] := Module[{arg, identity, kind, solutions, rule},
  arg = Factor[argument];
  If[TrueQ[FullSimplify[0 < arg < 1, assumptions]], Return[unitDilogarithm[arg, assumptions]]];
  kind = Which[TrueQ[FullSimplify[arg < 0, assumptions]], "Mobius",
    TrueQ[FullSimplify[arg > 1, assumptions]], "Inverse", True, None];
  If[kind === None, Return[PolyLog[2, arg]]];
  identity = dilogarithms["Identities"][kind];
  solutions = Solve[identity["Argument"] == arg, z];
  gate["dilogarithm transformation has a unique inverse", Length[solutions] === 1];
  rule = First[solutions] /. Rule[a_, b_] :> Rule[a, Factor[b]];
  gate["dilogarithm transformation domain", FullSimplify[identity["Domain"] /. rule, assumptions] === True];
  gate["dilogarithm transformation reconstructs its argument", Factor[(identity["Argument"] /. rule) - arg] === 0];
  (identity["Value"] /. rule) /. PolyLog[2, a_] :> unitDilogarithm[Factor[a], assumptions]];

reduceFunction[function_, assumptions_] := Module[{file, saved, value, unitFunctions, realSlots, realRules, domain},
  file = FileNameJoin[{cache, "Function_" <> IntegerString[Hash[{function, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  value = function /. PolyLog[2, a_] :> reduceDilogarithm[a, assumptions];
  unitFunctions = Select[DeleteDuplicates[Cases[value, _PolyLog, {0, Infinity}]],
    TrueQ[FullSimplify[0 < #[[2]] < 1, assumptions]] &];
  realSlots = Array[realDilogarithm, Length[unitFunctions]];
  realRules = Thread[unitFunctions -> realSlots];
  domain = assumptions && Element[realSlots, Reals];
  value = value /. {Arg[a_] :> Arg[Factor[a]], Abs[a_] :> Abs[Factor[a]], Sign[a_] :> Sign[Factor[a]]};
  value = Refine[PowerExpand[(value /. realRules) /. Log[a_] :> Log[Factor[a]],
    Assumptions -> domain], domain] /. Thread[realSlots -> unitFunctions];
  If[MatchQ[function, _Arg | _Abs | _Sign], value = FullSimplify[value, assumptions]];
  gate["function normalization is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  Put[<|"InputHash" -> inputHash, "Function" -> function, "Assumptions" -> assumptions,
    "Value" -> value|>, file]; value];

reduceAlgebraic[expression_, assumptions_] := Module[{file, saved, value},
  file = FileNameJoin[{cache, "Algebraic_" <> IntegerString[Hash[{expression, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  value = bounded[Together[expression], "exact rational coefficient"];
  gate["rational coefficient reduction is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  Put[<|"InputHash" -> inputHash, "ExpressionHash" -> Hash[{expression, assumptions}, "SHA256"],
    "Value" -> value|>, file]; value];

normalize[input_, assumptions_] := Module[{value, roots, rules, functions, phases, slots, formal, coefficients,
  coefficientFile, saved, terms, rows, groups, answer, result},
  value = input /. a_ArcTanh :> ComplexExpand[a];
  roots = DeleteDuplicates[Cases[value, Power[_, power_Rational] /; Denominator[power] === 2, Infinity]];
  Print["Normalize ", Length[roots], " radicals"];
  rules = Table[radical -> bounded[FullSimplify[radical, assumptions], "one radical"], {radical, roots}];
  value = value /. rules;
  functions = DeleteDuplicates[Cases[value, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  Print["Normalize ", Length[functions], " distinct functions"];
  rules = Table[
    With[{answer = bounded[reduceFunction[functions[[j]], assumptions], {"one function", j}]},
      If[Mod[j, 10] === 0, ClearSystemCache[]; Print["Normalized function ", j, "/", Length[functions]]];
      functions[[j]] -> answer], {j, Length[functions]}];
  value = value /. rules;
  phases = DeleteDuplicates[Cases[value, _Arg | _Abs | _Sign, Infinity]];
  Print["Normalize ", Length[phases], " phase functions"];
  rules = Table[phase -> bounded[reduceFunction[phase, assumptions], "one phase function"], {phase, phases}];
  value = value /. rules;
  gate["normalized function assembly is finite", FreeQ[value, Indeterminate | _DirectedInfinity]];
  functions = DeleteDuplicates[Cases[value, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  If[functions === {}, Return[Factor[value]]];
  slots = Array[formalFunction, Length[functions]];
  formal = Expand[value /. Thread[functions -> slots], Alternatives @@ slots];
  gate["comparison is polynomial in its formal functions", PolynomialQ[formal, slots]];
  Print["Factored formal input leaves = ", LeafCount[formal]];
  coefficientFile = FileNameJoin[{cache, "GroupedCoefficients_" <>
    IntegerString[Hash[{formal, slots, assumptions}, "SHA256"], 16, 64] <> ".wl"}];
  saved = If[FileExistsQ[coefficientFile], Get[coefficientFile], <||>];
  coefficients = If[MemberQ[acceptedInputHashes, saved["InputHash"]], saved["Value"],
    terms = If[Head[formal] === Plus, List @@ formal, {formal}];
    rows = Map[Function[term, With[{factors = If[Head[term] === Times, List @@ term, {term}]},
      {Times @@ Select[factors, !FreeQ[#, Alternatives @@ slots] &],
       Times @@ Select[factors, FreeQ[#, Alternatives @@ slots] &]}]], terms];
    gate["term factors reconstruct exactly", And @@ MapThread[SameQ, {Times @@@ rows, terms}]];
    groups = GatherBy[rows, First];
    answer = ({#[[1, 1]], Total[#[[All, 2]]]} &) /@ groups;
    gate["grouped coefficient expression reconstructs exactly",
      Expand[Total[Times @@@ answer] - formal, Alternatives @@ slots] === 0];
    Put[<|"InputHash" -> inputHash, "Value" -> answer|>, coefficientFile]; answer];
  Print["Reduce ", Length[coefficients], " algebraic coefficients"];
  result = Table[
    Print["Reduce coefficient ", j, "/", Length[coefficients], "; leaves = ", LeafCount[Last[coefficients[[j]]]]];
    With[{coefficient = reduceAlgebraic[Last[coefficients[[j]]], assumptions]},
      ClearSystemCache[]; Print["Saved coefficient ", j, "/", Length[coefficients], "; zero = ", coefficient === 0];
      coefficient (First[coefficients[[j]]] /. Thread[slots -> functions])],
    {j, Length[coefficients]}];
  Total[result]];

canonicalAuthors[name_] := Module[{file, saved, coefficients, plus0, plus1, endpoint0, endpoint1, ordinary, value},
  file = FileNameJoin[{cache, "Authors_" <> name <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  Print["Canonical authors ", name];
  coefficients = authors["NLOCoefficients"][names[name]] /. authors["XhatRule"];
  plus0 = coefficients["plus0"] + logScaleShift coefficients["plus1"];
  plus1 = coefficients["plus1"];
  endpoint0 = bounded[Limit[plus0, s23 -> 0, Direction -> "FromAbove", Assumptions -> softPhysical], {name, "author L0 endpoint"}];
  endpoint1 = bounded[Limit[plus1, s23 -> 0, Direction -> "FromAbove", Assumptions -> softPhysical], {name, "author L1 endpoint"}];
  endpoint0 = a /. endpointWeightRule /. cEndpoint -> endpoint0;
  endpoint1 = a /. endpointWeightRule /. cEndpoint -> endpoint1;
  ordinary = coefficients["regular"] + coefficients["plus0"]/s23 + coefficients["plus1"] Log[s23/Q^2]/s23;
  value = <|"Delta" -> coefficients["delta"], "L0" -> endpoint0, "L1" -> endpoint1,
    "Regular" -> (ordinary - endpoint0/s23 - endpoint1 Log[s23/B]/s23)|>;
  gate["author endpoint coefficients are evaluated and recoil independent", FreeQ[
    {value["Delta"], endpoint0, endpoint1}, s23 | _Limit | _Integrate | _SeriesData | _Real]];
  gate["author ordinary distribution reconstructs exactly", bounded[FullSimplify[
    value["Regular"] + endpoint0/s23 + endpoint1 Log[s23/B]/s23 - ordinary, physical] === 0,
    {name, "author distribution reconstruction"}]];
  Put[<|"InputHash" -> inputHash, "Value" -> value|>, file]; value];

compare[label_, left_, right_, assumptions_, allowRadicalMap_] := Module[
  {file, saved, difference, mapped, mappedAssumptions, roots, base, solutions, rules = {}, reduced, equality, result},
  file = FileNameJoin[{cache, label <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedInputHashes, saved["InputHash"]], Return[saved["Value"]]]];
  ClearSystemCache[];
  Print["Compare ", label, "; memory = ", MemoryInUse[]];
  difference = left - right;
  mapped = difference; mappedAssumptions = assumptions;
  If[TrueQ[allowRadicalMap],
    roots = DeleteDuplicates[Cases[difference,
      (Power[rad_, power_Rational] /; Denominator[power] === 2 && !FreeQ[rad, omega] &&
        PolynomialQ[rad, s23] && Exponent[rad, s23] === 1) :> rad, Infinity]];
    If[roots =!= {},
      base = First[SortBy[roots, LeafCount]];
      gate["comparison radical is positive in its physical region", bounded[
        FullSimplify[base > 0, assumptions] === True, {label, "radical positivity"}]];
      solutions = Solve[radius^2 == base, s23];
      gate["radical coordinate has a unique inverse", Length[solutions] === 1];
      rules = First[solutions];
      gate["radical coordinate reconstructs its definition", Factor[(base /. rules) - radius^2] === 0];
      gate["radical substitution has an exact round trip", bounded[
        FullSimplify[(s23 /. rules /. radius -> Sqrt[base]) - s23, assumptions] === 0,
        {label, "radical round trip"}]];
      mapped = difference /. rules;
      mappedAssumptions = (assumptions /. rules) && radius > 0]];
  Put[<|"InputHash" -> inputHash, "Difference" -> difference, "AlgebraicMap" -> rules,
    "Assumptions" -> assumptions|>, FileNameJoin[{cache, label <> "_input.wl"}]];
  mapped = mapped /. p_Piecewise :> Refine[p, mappedAssumptions];
  reduced = bounded[normalize[mapped, mappedAssumptions], {label, "difference reduction"}];
  gate["comparison reduction is finite", FreeQ[reduced, Indeterminate | _DirectedInfinity]];
  equality = If[reduced === 0, True,
    bounded[FullSimplify[reduced == 0, mappedAssumptions], {label, "exact equality"}]];
  If[equality === True, reduced = 0];
  result = <|"Equality" -> equality, "Difference" -> reduced, "AlgebraicMap" -> rules,
    "Assumptions" -> mappedAssumptions|>;
  Put[<|"InputHash" -> inputHash, "Value" -> result|>, file];
  Print["Comparison ", label, ": ", If[equality === True, "equal", If[equality === False, "different", "unresolved equality"]]];
  result];

canonical = Association@Table[name -> canonicalAuthors[name], {name, Keys[names]}];
comparisons = <||>;
Do[
  AssociateTo[comparisons, name <> "_Born" -> compare[name <> "_Born",
    independent["Hats"][name]["LODelta"] /. commonRules,
    authors["BornDeltaCoefficients"][names[name]] /. authors["XhatRule"], softPhysical, False]],
  {name, Keys[names]}];
Do[
  branchRule = First[Solve[omega == (omega /. independent["BranchCoordinates"][sign]), t]];
  assumptions = (If[distribution === "Regular", physical, softPhysical] /. branchRule) && omega > 0;
  label = StringRiffle[{name, ToString[sign], distribution}, "_"];
  AssociateTo[comparisons, label -> compare[label,
    independent["Hats"][name]["NLO"][sign][distribution] /. commonRules,
    canonical[name][distribution] /. branchRule, assumptions, distribution === "Regular"]],
  {distribution, {"L1", "L0", "Delta", "Regular"}}, {name, Keys[names]},
  {sign, Keys[independent["Hats"][name]["NLO"]]}];
checkFrozen[];
gate["author comparison input was unchanged during the run", authorHash ===
  FileHash[FileNameJoin[{root, "comparison", "s03_result.wl"}], "SHA256"]];
deltaProofs = Get[FileNameJoin[{root, "s13_delta_nonidentity_result.wl"}]];
gate["delta decision proofs are complete and source bound", deltaProofs["Complete"] === True &&
  deltaProofs["SourceHash"] === FileHash[FileNameJoin[{root, "s13_delta_nonidentity.wl"}], "SHA256"]];
KeyValueMap[Function[{key, proof},
  gate["delta decision uses the accepted comparison checkpoint", MemberQ[acceptedInputHashes, proof["InputHash"]] &&
    proof["ComparisonFileHash"] === FileHash[FileNameJoin[{cache, key <> ".wl"}], "SHA256"]];
  AssociateTo[comparisons, key -> Join[comparisons[key], <|
    "EqualityForNonzeroCharge" -> proof["EqualityForNonzeroCharge"],
    "Difference" -> proof["Difference"], "NonidentityProof" -> proof|>]]], deltaProofs["Proofs"]];
Put[<|"Comparisons" -> comparisons, "AllEqual" -> And @@ (TrueQ[#["Equality"]] & /@ Values[comparisons]),
  "IndependentInputs" -> manifest, "AuthorSource" -> authors["Source"], "AuthorTree" -> authors["SourceTree"],
  "AuthorResultHash" -> authorHash, "ReconstructionAssumption" -> authors["ReconstructionAssumption"],
  "DilogarithmIdentityHash" -> identityHash,
  "DeltaNonidentityProof" -> deltaProofs,
  "AuthorMetadata" -> authorMetadata, "CommonRules" -> commonRules, "KinematicRules" -> kinematicRules,
  "PlusLogScaleShift" -> logScaleShift, "CoefficientTimesPlusRule" -> endpointWeightRule,
  "ComparisonDefinition" -> "Canonical distributions at fixed s,t; apply the verified physical-variable map to both coefficient and test function when changing variables.",
  "CanonicalAuthorCoefficients" -> canonical, "InputHash" -> inputHash,
  "AcceptedCacheInputHashes" -> acceptedInputHashes, "PriorSources" -> priorSources|>,
  FileNameJoin[{root, "s13_result.wl"}]];
Print["Wrote s13_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

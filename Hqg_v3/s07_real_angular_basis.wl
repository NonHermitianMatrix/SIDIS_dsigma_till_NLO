(* Paper Appendices B and D: exact invariant reduction and rest-frame geometry. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, mink, sphere, splitDenominators, makeBasis];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
gate["accepted S05 input exists", FileExistsQ[FileNameJoin[{root, "s05_result.wl"}]]];
input = Get[FileNameJoin[{root, "s05_result.wl"}]];
gate["all real Ward identities passed", And @@
  (input["Contractions"][#] === 0 & /@ {"PhotonWard", "Gluon1Ward", "Gluon3Ward"})];
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
angularRules = {a12 -> sphere[mink[frame[k1] + frame[k2], frame[k1] + frame[k2]]],
  u3 -> sphere[mink[frame[p] - frame[k3], frame[p] - frame[k3]]]};
gate["rest frame reproduces all invariant scalar products", And @@
  (FullSimplify[sphere[mink[frame[#[[1]]], frame[#[[2]]]]] -
    (#[[3]] /. angularRules), physical] === 0 & /@ input["RealScalarProducts"])];

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
  factors = FactorList[Denominator[value]];
  angleFactors = Select[factors, !FreeQ[First[#], a12 | u3] &];
  denominators = angleFactors[[All, 1]]; powers = angleFactors[[All, 2]];
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
    solution = First[Solve[Thread[denominators[[choice]] == {v, w}], {a12, u3}]];
    polynomial = bounded[Collect[numerator /. solution, {v, w}, Factor], {mode, choice}];
    rows = CoefficientRules[polynomial, {v, w}];
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

result = Association@Table[mode -> bounded[makeBasis[mode], mode <> " basis"],
  {mode, {"Pg", "Ppp"}}];
Put[<|"Basis" -> result, "Frame" -> frame, "AngularRules" -> angularRules,
  "PhysicalRegion" -> physical, "InputHash" -> FileHash[FileNameJoin[{root, "s05_result.wl"}], "SHA256"],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s07_result.wl"}]];
Print["Wrote s07_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

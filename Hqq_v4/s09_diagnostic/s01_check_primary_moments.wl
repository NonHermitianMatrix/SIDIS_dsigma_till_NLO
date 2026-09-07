If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
out = DirectoryName[$InputFileName];
root = ParentDirectory[out];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["FAIL: time limit ", label]; Quit[2]], 2*1024^3,
  Print["FAIL: memory limit ", label]; Quit[3]];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
real = Get[FileNameJoin[{root, "s03_result.wl"}]];
basis = Get[FileNameJoin[{root, "s05_result.wl"}]];
masters = Get[FileNameJoin[{root, "s06_result.wl"}]];
Scan[Function[row, gate[row[[1]] <> " source identity", row[[2]]["SourceHash"] ===
  FileHash[FileNameJoin[{root, row[[3]]}], "SHA256"]]],
  {{"S01", generated, "s01_generate_amplitudes.wl"}, {"S02", born, "s02_born_and_projectors.wl"},
   {"S03", real, "s03_contract_real.wl"}, {"S05", basis, "s05_real_angular_basis.wl"},
   {"S06", masters, "s06_angular_integrals.wl"}}];
component = SelectFirst[Keys[real["Components"]], real["Components"][#]["Sector"] === "RealDistinct" &&
  real["Components"][#]["ChargeRatioPower"] === 0 &];
physical = basis["PhysicalRegion"];
polarMeasure = FullSimplify[Sin[ArcCos[x]]^(1 - 2 eps) Abs[D[ArcCos[x], x]],
  -1 < x < 1 && Element[eps, Reals]];
moment[indices_List] := moment[indices] = Module[{a = indices[[1]], b = indices[[2]], azimuth, polar},
  Print["Direct angular moment ", indices];
  azimuth = bounded[Integrate[Cos[phi]^a Sin[phi]^(-2 eps), {phi, 0, Pi},
    Assumptions -> eps < 0, GenerateConditions -> False], {"azimuth", indices}];
  polar = bounded[Integrate[polarMeasure (1 - x^2)^(a/2) x^b, {x, -1, 1},
    Assumptions -> eps < 0, GenerateConditions -> False], {"polar", indices}];
  gate["defining angular moment evaluated", FreeQ[{azimuth, polar}, _Integrate | _ConditionalExpression]];
  FullSimplify[azimuth polar, eps < 0]];
masterValue[key_] := SelectFirst[masters["Masters"], #["Key"] === key &]["Value"];
comparisons = <||>;
Do[
  key = component <> "__" <> mode;
  polynomial = real["Contractions"][key] /. basis["AngularRules"] /. D -> 4 - 2 eps;
  gate["selected primary tensor is an angular polynomial", PolynomialQ[polynomial, {nx, nz}] && FreeQ[polynomial, ny]];
  rows = CoefficientRules[polynomial, {nx, nz}];
  direct = bounded[Total[(#[[2]] moment[#[[1]]]) & /@ rows], mode <> " direct moment sum"];
  recipe = Total[Table[
    geometry = basis["Basis"][key]["Geometry"][[term[[{1, 2}]]]];
    gate["primary polynomial recipe uses massless angular directions", And @@ Lookup[geometry, "Massless"]];
    cosine = FullSimplify[geometry[[1]]["Direction"].geometry[[2]]["Direction"], physical];
    value = masterValue[{"LL", term[[3]], term[[4]]}];
    (term[[5]] /. D -> 4 - 2 eps) Times @@ (Lookup[geometry, "Scale"]^(-term[[{3, 4}]])) *
      ((value["Regular"] + (1 - z)^(-eps) value["Coalescing"]) /. z -> (1 + cosine)/2),
    {term, basis["Basis"][key]["Terms"]}]];
  difference = bounded[FullSimplify[Normal[Series[direct - recipe, {eps, 0, 1}]], physical], mode <> " moment difference"];
  directLeading = bounded[FullSimplify[Limit[s23^2 direct, s23 -> 0,
    Assumptions -> Q2 > 0 && s > 0 && -Q2 - s < t < 0 && eps < 0],
    Q2 > 0 && s > 0 && -Q2 - s < t < 0 && eps < 0], mode <> " direct leading recoil"];
  AssociateTo[comparisons, mode -> <|"DirectAngularIntegral" -> direct, "MasterRecipe" -> recipe,
    "DifferenceThroughEpsilon" -> difference, "DirectLeadingRecoil" -> directLeading|>];
  Print[mode, " angular recipe difference = ", InputForm[difference]];
  Print[mode, " directly integrated leading recoil = ", InputForm[directLeading]],
  {mode, {"Pg", "Ppp"}}];
atomicPut[<|"Status" -> "AngularCompared", "Comparisons" -> comparisons|>,
  FileNameJoin[{out, "s01_angular.wl"}]];

FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
  SPD[v, w] = value; SP[v, w] = value]], born["RealScalarProducts"]];
amplitude = Total[Pick[generated["RealDistinct"], real["ChargeDegrees"]["RealDistinct"], 0]] /.
  {SMP["e"] -> 1, SMP["g_s"] -> 1};
full = <||>;
Do[
  Print["Full primary amplitude contraction ", mode];
  a = If[mode === "Ppp", amplitude /. Polarization[q, ___] -> p, amplitude];
  expression = bounded[FermionSpinSum[a ComplexConjugate[a], ExtraFactor -> born["InitialAverages"]["Hqq"]], mode <> " full spin sum"];
  expression = SUNSimplify[expression, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", expression = -DoPolarizationSums[expression, q, 0, VirtualBoson -> True]];
  expression = bounded[Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[
    Contract[DiracSimplify[expression, DiracTraceEvaluate -> True]]]]] *
    real["TagWeights"]["RealDistinct"]/born["ModelChargeSquared"], mode <> " full contraction"];
  gate["full primary contraction is scalar", FreeQ[expression,
    _Spinor | _DiracTrace | _DiracGamma | _Pair | _SUNTF | _Polarization | _Real]];
  difference = bounded[Factor[expression - real["Contractions"][component <> "__" <> mode]], mode <> " full/pair comparison"];
  AssociateTo[full, mode -> <|"FullContraction" -> expression, "DifferenceFromPairs" -> difference|>];
  Print[mode, " full-amplitude minus pairwise = ", InputForm[difference]], {mode, {"Pg", "Ppp"}}];
atomicPut[<|"Status" -> "DiagnosticComplete", "Component" -> component, "Angular" -> comparisons,
  "FullAmplitude" -> full, "PolarMeasure" -> polarMeasure,
  "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "InputHashes" -> Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
    {name, {"s01_result.wl", "s02_result.wl", "s03_result.wl", "s05_result.wl", "s06_result.wl"}}]|>,
  FileNameJoin[{out, "s01_result.wl"}]];
Print["S01_SUCCESS: diagnostic completed; no F hats accepted; peak memory = ", MaxMemoryUsed[]];
Quit[];

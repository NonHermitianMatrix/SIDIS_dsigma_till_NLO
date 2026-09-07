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
FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], value = row[[3]]},
  SPD[v, w] = value; SP[v, w] = value]], born["RealScalarProducts"]];
amplitude = Total[generated["RealSame"]] /.
  {SMP["e"] -> 1, SMP["g_s"] -> 1};
full = <||>;
Do[
  Print["Full same-flavor amplitude contraction ", mode];
  a = If[mode === "Ppp", amplitude /. Polarization[q, ___] -> p, amplitude];
  expression = bounded[FermionSpinSum[a ComplexConjugate[a], ExtraFactor -> born["InitialAverages"]["Hqq"]], mode <> " full spin sum"];
  expression = SUNSimplify[expression, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", expression = -DoPolarizationSums[expression, q, 0, VirtualBoson -> True]];
  expression = bounded[Factor[ExpandScalarProduct[FeynAmpDenominatorExplicit[
    Contract[DiracSimplify[expression, DiracTraceEvaluate -> True]]]]] *
    real["TagWeights"]["RealSame"]/born["ModelChargeSquared"], mode <> " full contraction"];
  gate["full same-flavor contraction is scalar", FreeQ[expression,
    _Spinor | _DiracTrace | _DiracGamma | _Pair | _SUNTF | _Polarization | _Real]];
  difference = bounded[Factor[expression - real["Contractions"]["RealSame_Charge0__" <> mode]], mode <> " full/pair comparison"];
  AssociateTo[full, mode -> <|"FullContraction" -> expression, "DifferenceFromPairs" -> difference|>];
  Print[mode, " full-amplitude minus pairwise = ", InputForm[difference]], {mode, {"Pg"}}];
angularTensor = real["Contractions"]["RealSame_Charge0__Pg"] /. basis["AngularRules"] /. D -> 4 - 2 eps;
Print["Computing full same-flavor unintegrated leading recoil"];
leading = bounded[FullSimplify[Limit[s23^2 angularTensor, s23 -> 0,
  Direction -> "FromAbove", Assumptions -> Q2 > 0 && s > 0 && -Q2 - s < t < 0 && -1 < nz < 1 && Element[{nx, eps}, Reals]],
  Q2 > 0 && s > 0 && -Q2 - s < t < 0 && -1 < nz < 1 && Element[{nx, eps}, Reals]], "unintegrated leading recoil"];
Print["Full same-flavor unintegrated leading recoil = ", InputForm[leading]];
atomicPut[<|"Status" -> "DiagnosticComplete", "FullAmplitude" -> full, "UnintegratedLeadingRecoil" -> leading,
  "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "InputHashes" -> Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
    {name, {"s01_result.wl", "s02_result.wl", "s03_result.wl", "s05_result.wl", "s06_result.wl"}}]|>,
  FileNameJoin[{out, "s03_result.wl"}]];
Print["S03_SUCCESS: diagnostic completed; no F hats accepted; peak memory = ", MaxMemoryUsed[]];
Quit[];

(* Paper Appendix E: diagram-wise interference, PV reduction, explicit loop measure. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
FeynCalc`$FeynHelpersLoadInterfaces = {"PackageX"};
$LoadAddOns = {"FeynHelpers"};
Print["Loading FeynCalc and the Package-X interface."];
Get["FeynCalc`"];
Print["Loop interface loaded."];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, contractVirtual, externalDenominators, evaluateDiagram];
gate[name_, condition_] := If[TrueQ[condition], Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
measure = mu^(2 Epsilon)/(2 Pi)^(4 - 2 Epsilon);
(* Package-X includes ScaleMu^(2 Epsilon); identify it with the paper's mu. *)
paxMeasure = measure/mu^(2 Epsilon);
$KeepLogDivergentScalelessIntegrals = True;

FCClearScalarProducts[];
SPD[r, r] = -Q2;
backend = bounded[PaXEvaluateUVIRSplit[FAD[ell, ell + r], ell,
  PaXImplicitPrefactor -> paxMeasure, PaXC0Expand -> True,
  PaXD0Expand -> True, PaXAnalytic -> True] /. ScaleMu -> mu, "loop backend"];
gate["loop backend evaluates the spacelike bubble", FreeQ[backend,
  _FeynAmpDenominator | _PaVe | _PaXEvaluateUVIRSplit | _PaXEvaluate]];
gate["bubble distinguishes UV from IR", !FreeQ[backend, EpsilonUV] &&
  FreeQ[backend, EpsilonIR]];
Put[<|"Bubble" -> backend, "Measure" -> measure,
  "Backend" -> "FeynHelpers bundled OneLoopFromPackageX"|>,
  FileNameJoin[{root, "s06_backend.wl"}]];
Print["Loop backend: ", InputForm[backend]];
If[Environment["HQG_VIRTUAL_MODE"] === "backend", Quit[]];

gate["accepted Born and real normalization inputs exist", And @@
  (FileExistsQ[FileNameJoin[{root, #}]] & /@
    {"s02_result.wl", "s04_result.wl", "s05_result.wl"})];
generated = Get[FileNameJoin[{root, "s04_result.wl"}]];
real = Get[FileNameJoin[{root, "s05_result.wl"}]];
chargeSquared = real["ModelChargeSquared"];
FCClearScalarProducts[];
Scan[Function[row, With[{v = row[[1]], w = row[[2]], val = row[[3]]},
  SPD[v, w] = val; SP[v, w] = val]], real["BornScalarProducts"]];
bornAmplitude = Total[generated["Born"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
virtualAmplitudes = generated["Virtual"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
physical = Q2 > 0 && s > 0 && -Q2 - s < t < 0 && mu > 0 && SUNN > 1;
$Assumptions = physical;
cache = FileNameJoin[{root, "s06_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"],
  FileHash[FileNameJoin[{root, "s04_result.wl"}], "SHA256"],
  FileHash[FileNameJoin[{root, "s05_result.wl"}], "SHA256"]}, "SHA256"];

externalDenominators[expression_] := expression /.
  FeynAmpDenominator[propagators__] :> Times @@
    (If[FreeQ[#, ell], FeynAmpDenominatorExplicit[FeynAmpDenominator[#]],
      FeynAmpDenominator[#]] & /@ {propagators});

contractVirtual[amplitude_, mode_] := Module[{a = amplitude, b = bornAmplitude, value},
  If[mode === "Ppp", a = a /. Polarization[q, ___] -> p;
    b = b /. Polarization[q, ___] -> p];
  value = FermionSpinSum[a ComplexConjugate[b], ExtraFactor -> 1/(2 SUNN)];
  value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  If[mode === "Pg", value = -DoPolarizationSums[value, q, 0, VirtualBoson -> True]];
  value = DoPolarizationSums[value, k1, p];
  value = Contract[DiracSimplify[value, DiracTraceEvaluate -> True]];
  value = FCReplaceMomenta[value, {k2 -> p + q - k1}];
  value = externalDenominators[value] // ExpandScalarProduct;
  value/chargeSquared];

evaluateDiagram[mode_, index_] := Module[{file, saved, contracted, reduced, evaluated},
  file = FileNameJoin[{cache, mode <> "_" <> IntegerString[index, 10, 2] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file];
    If[AssociationQ[saved] && saved["InputHash"] === inputHash, Return[saved["Value"]]]];
  Print[mode, " virtual diagram ", index, "; contracting; memory = ", MemoryInUse[]];
  contracted = bounded[contractVirtual[virtualAmplitudes[[index]], mode], {mode, index, "trace"}];
  gate["virtual interference has no open spin, color, or polarization objects",
    FreeQ[contracted, _Spinor | _DiracTrace | _DiracGamma | _SUNTF | _SUNTrace | _Polarization]];
  Print[mode, " virtual diagram ", index, "; PV reduction."];
  reduced = bounded[TID[contracted, ell, ToPaVe -> True, UsePaVeBasis -> True],
    {mode, index, "PV"}];
  gate["PV reduction eliminates loop momentum", FreeQ[reduced, ell]];
  Print[mode, " virtual diagram ", index, "; analytic loop integrals."];
  evaluated = bounded[PaXEvaluateUVIRSplit[reduced,
    PaXImplicitPrefactor -> paxMeasure, PaXC0Expand -> True, PaXD0Expand -> True,
    PaXAnalytic -> True] /. ScaleMu -> mu, {mode, index, "Package-X"}];
  gate["all loop integrals evaluated", FreeQ[evaluated,
    _PaVe | _A0 | _B0 | _C0 | _D0 | _FeynAmpDenominator |
    _PaXEvaluate | _PaXEvaluateUVIRSplit | _TID | _Real]];
  Put[<|"InputHash" -> inputHash, "Value" -> evaluated|>, file];
  evaluated];

result = Association@Table[mode -> Total[Table[evaluateDiagram[mode, index],
  {index, Length[virtualAmplitudes]}]], {mode, {"Pg", "Ppp"}}];
Put[<|"InterferenceBeforeHermitianConjugate" -> result,
  "HermitianRule" -> HoldForm[interference + Conjugate[interference]],
  "DimensionRegulator" -> Epsilon, "UVRegulator" -> EpsilonUV,
  "IRRegulator" -> EpsilonIR, "Measure" -> measure,
  "CouplingsRemoved" -> "eq^2 gs^4", "InputHash" -> inputHash,
  "ExternalLegs" -> generated["ExternalLegs"],
  "Renormalization" -> "not yet applied", "PhysicalRegion" -> physical|>,
  FileNameJoin[{root, "s06_result.wl"}]];
Print["Wrote s06_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

(* Decide saved delta equalities using exact special-function ranges. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded];
gate[label_, test_] := If[TrueQ[test], Print["PASS: ", label], Print["FAIL: ", label]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 120,
  Print["Time limit: ", label]; Quit[2]], 512*1024^2,
  Print["Memory limit: ", label]; Quit[3]];
range = bounded[FunctionRange[{PolyLog[2, z], 0 < z < 1}, z, y, Reals], "unit dilogarithm range"];
Print["Dilogarithm range: ", InputForm[range]];
gate["unit dilogarithm range was evaluated", FreeQ[range, _FunctionRange | _Reduce | _Resolve]];
positive = bounded[Resolve[ForAll[y, Implies[range, y > 0]], Reals], "range positivity"];
gate["range implies strictly positive dilogarithm", positive === True];
proofs = <||>;
Do[
  label = StringRiffle[{name, ToString[sign], "Delta"}, "_"];
  Print["Decide ", label];
  saved = Get[FileNameJoin[{root, "s13_cache", label <> ".wl"}]];
  value = saved["Value"];
  domain = value["Assumptions"] && eq != 0;
  functions = DeleteDuplicates[Cases[value["Equality"], _PolyLog, Infinity]];
  constraints = Table[
    gate["dilogarithm argument lies in the proved range domain", bounded[
      FullSimplify[0 < function[[2]] < 1, domain] === True, {label, "argument domain"}]];
    range /. y -> function, {function, functions}];
  equality = bounded[FullSimplify[value["Equality"], domain && And @@ constraints], {label, "equality decision"}];
  reduced = bounded[FullSimplify[value["Difference"], value["Assumptions"]], {label, "compact difference"}];
  AssociateTo[proofs, label -> <|"InputHash" -> saved["InputHash"],
    "ComparisonFileHash" -> FileHash[FileNameJoin[{root, "s13_cache", label <> ".wl"}], "SHA256"],
    "EqualityForNonzeroCharge" -> equality, "Difference" -> reduced,
    "Assumptions" -> domain, "FunctionConstraints" -> constraints|>];
  Print["Decision ", label, ": ", InputForm[equality]];
  Put[<|"Proofs" -> proofs, "DilogarithmRange" -> range, "Complete" -> False,
    "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>,
    FileNameJoin[{root, "s13_delta_nonidentity_result.wl"}]];
  ClearSystemCache[], {name, {"F1", "F2"}}, {sign, {1, -1}}];
Put[<|"Proofs" -> proofs, "DilogarithmRange" -> range, "Complete" -> True,
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>,
  FileNameJoin[{root, "s13_delta_nonidentity_result.wl"}]];
Print["Wrote s13_delta_nonidentity_result.wl."];
Quit[];

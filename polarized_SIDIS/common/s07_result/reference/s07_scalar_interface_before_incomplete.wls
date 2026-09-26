(* Inspect the actual first incomplete virtual projection without changing production. *)
$HistoryLength = 0;
diagnosticSource = FileNameJoin[{Directory[], "common", "s07_scalar_interface_check.wls"}];
productionSource = FileNameJoin[{Directory[], "common", "s07_virtual_spin_response.wls"}];
If[IntegerString[FileHash[productionSource, "SHA256"], 16, 64] =!=
  "77525d42492206f7e81802ff7bc0f8d8994969a2681518175200f76199c0f2e5", Quit[1]];
productionText = Import[productionSource, "Text"];
prefixEnd = First[First[StringPosition[productionText, "diagrams = {};\n"]]] - 1;
ToExpression[StringTake[productionText, prefixEnd]];
gate["diagnostic source syntax", SyntaxQ[Import[diagnosticSource, "Text"]]];
tasks = Flatten[Table[{index, a, b}, {index, Length[virtualAmplitudes]},
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}], 2];
projectionPath[{index_, a_, b_}] := FileNameJoin[{cache, "diagram_" <>
  IntegerString[index, 10, 2] <> "_P" <> ToString[a] <> "_" <> ToString[b] <> ".wl"}];
task = SelectFirst[tasks, !FileExistsQ[projectionPath[#]] &, Missing["NoIncompleteProjection"]];
gate["incomplete projection exists", ListQ[task]];
Print["INSPECT_VIRTUAL_PROJECTION ", task];
tensor = bounded[buildTensor[virtualAmplitudes[[First[task]]]], {task, "closure"}];
projected = photonProject[tensor, photonSymbols[[task[[2]]]], photonSymbols[[task[[3]]]]];
traced = bounded[Contract[DiracSimplify[projected, DiracTraceEvaluate -> True]], {task, "native trace"}];
value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[traced]]]]];
value = bounded[spinMap[Function[component, algebraicReduce[
  Factor[component /. epsilonRule] /. scalarRestore]], value], {task, "scalar boundary"}];
residual = DeleteDuplicates[Cases[value,
  _Pair | _Eps | _Spinor | _DiracGamma | _DiracTrace | _LorentzIndex | _Polarization |
  _SUNTF | _SUNTrace | _SUNF | _SUNDelta | _SUNFDelta | _FeynAmpDenominator, Infinity]];
Print["RESIDUAL_OBJECTS ", InputForm[residual]];
resultDir = FileNameJoin[{root, channel, "s07_scalar_interface_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[<|"Schema" -> "polarized-sidis-virtual-scalar-diagnostic-v1", "Channel" -> channel,
  "Task" -> task, "ResidualObjects" -> residual, "Expression" -> value,
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "ProductionSourceHash" -> sourceHash,
  "SourceHash" -> FileHash[diagnosticSource, "SHA256"], "Checks" -> checks,
  "AcceptedVirtualTensor" -> False|>, FileNameJoin[{resultDir, "s07_result.wl"}]];
Print["PASS: s07_scalar_interface_check"]; Quit[0];

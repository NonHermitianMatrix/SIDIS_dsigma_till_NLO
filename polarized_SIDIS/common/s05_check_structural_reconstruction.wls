(* Check the saved spin polynomial while retaining exact kinematic coefficients. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
source = FileNameJoin[{root, "common", "s05_check_structural_reconstruction.wls"}];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete comparison source syntax", SyntaxQ[Import[source, "Text"]]];
inputRelative = "Hqq/s05_reconstruction_equation_result/s05_result.wl";
inputPath = FileNameJoin[{root, inputRelative}];
receiptPath = FileNameJoin[{root, "Hqq", "s05_reconstruction_equation_result", "s05_execution.json"}];
gate["pinned actual equation packet", IntegerString[FileHash[inputPath, "SHA256"], 16, 64] ===
  "5e8e0d77dd233652180a509771ac8e770a80a99d4105ae651806e90dcc29d8ba"];
gate["pinned accepted equation receipt", IntegerString[FileHash[receiptPath, "SHA256"], 16, 64] ===
  "c97606f20b945ee4f8c023b4b4c2a935d2ad323a901efffc25a85440458a08ba"];
receipt = Import[receiptPath, "RawJSON"];
gate["equation reader accepted", TrueQ[receipt["passed"]]];
KeyValueMap[gate["reader artifact " <> #1, IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &,
  receipt["result_sha256"]];
input = Get[inputPath];
gate["actual channel and equation schema", input["Schema"] === "polarized-sidis-reconstruction-equations-v1" &&
  input["Channel"] === "Hqq" && input["Sector"] === "RealSame" && input["Components"] === {8, 9} &&
  And @@ Values[input["Checks"]] && input["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["equation reader source identity", input["SourceHash"] === FileHash[
  FileNameJoin[{root, "common", "s05_read_reconstruction_equations.wls"}], "SHA256"]];
gate["unchanged production source", input["ProductionSourceHash"] === FileHash[
  FileNameJoin[{root, "common", "s05_real_spin_response_cached_scalar.wls"}], "SHA256"]];
KeyValueMap[gate["physical input " <> #1, FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2] &, input["PhysicalInputHashes"]];
KeyValueMap[gate["saved equation input " <> #1, FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2] &, input["EquationInputHashes"]];
DownValues[compactSpinResponse] = input["ExtractionDefinitions"];
gate["unchanged native extraction installed", DownValues[compactSpinResponse] === input["ExtractionDefinitions"]];

structuralSpinReconstruction[expression_, response_, incoming_, outgoing_] := Module[
  {variables, pattern, replacements = {}, atom, shrink, opaque, extracted, reconstructed, restored,
   evidence, started = AbsoluteTime[]},
  variables = DeleteCases[Join[incoming, outgoing], 1]; pattern = Alternatives @@ variables;
  atom[value_] := atom[value] = Module[{symbol = Unique["sidisSpinCoefficient"]},
    AppendTo[replacements, symbol -> value]; symbol];
  shrink[value_] := If[FreeQ[value, pattern], If[AtomQ[value], value, atom[value]], Map[shrink, value]];
  opaque = shrink[expression];
  evidence = <|"DistinctSpinVariables" -> DuplicateFreeQ[variables],
    "SpinIndependentCoefficients" -> FreeQ[Last /@ replacements, pattern],
    "ExactExpressionRestoration" -> ((opaque /. replacements) === expression),
    "PolynomialSpinDependence" -> PolynomialQ[opaque, variables]|>;
  extracted = First[compactSpinResponse[{opaque}, incoming, outgoing]];
  reconstructed = Sum[incoming[[i]] outgoing[[j]] extracted[[j, i]], {i, Length[incoming]}, {j, Length[outgoing]}];
  restored = extracted /. replacements;
  AssociateTo[evidence, {"ExactAbstractReconstruction" -> (Expand[opaque - reconstructed] === 0),
    "ExactExistingResponse" -> (restored === response)}];
  <|"Accepted" -> (And @@ Values[evidence]), "Checks" -> evidence,
    "InputBytes" -> ByteCount[expression], "AbstractBytes" -> ByteCount[opaque],
    "CoefficientCount" -> Length[replacements], "Seconds" -> AbsoluteTime[] - started,
    "KernelMemoryBytes" -> MemoryInUse[], "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>];

measurements = Table[
  Print["STRUCTURAL_RECONSTRUCTION ", input["Components"][[i]]];
  binding = Hash[{input["InputHash"], input["Sector"],
    {input["Components"][[i]], input["Equations"][[i]], input["Responses"][[i]]},
    input["IncomingVariables"], input["OutgoingVariables"]}, "SHA256"];
  gate["exact task binding " <> ToString[input["Components"][[i]]], binding === input["Bindings"][[i]]];
  candidate = MemoryConstrained[TimeConstrained[
    structuralSpinReconstruction[input["Equations"][[i]], input["Responses"][[i]],
      input["IncomingVariables"], input["OutgoingVariables"]], 600, gate["comparison time bound", False]],
    4*1024^3, gate["comparison memory bound", False]];
  gate["complete check inventory " <> ToString[input["Components"][[i]]], Keys[candidate["Checks"]] ===
    {"DistinctSpinVariables", "SpinIndependentCoefficients", "ExactExpressionRestoration",
     "PolynomialSpinDependence", "ExactAbstractReconstruction", "ExactExistingResponse"}];
  KeyValueMap[gate[ToString[input["Components"][[i]]] <> " " <> #1, #2] &, candidate["Checks"]];
  gate["complete reconstruction accepted " <> ToString[input["Components"][[i]]], candidate["Accepted"]];
  If[i === 1, gate["own accepted reconstruction comparison", candidate["Accepted"] === input["AcceptedControl"]["Accepted"] &&
    input["AcceptedControl"]["Binding"] === binding]];
  row = Join[candidate, <|"Component" -> input["Components"][[i]], "Binding" -> binding|>];
  Print["STRUCTURAL_RECONSTRUCTION_MEASUREMENT ", InputForm[row]]; ClearSystemCache[]; row,
  {i, Length[input["Components"]]}];
controlResponse = First[input["Responses"]];
controlPositions = Position[controlResponse, value_ /; value =!= 0, {2}];
gate["nonzero saved response control", controlPositions =!= {}];
perturbation = Unique["incorrectSpinCoefficient"];
incorrectResponse = ReplacePart[controlResponse, First[controlPositions] ->
  (Extract[controlResponse, First[controlPositions]] + perturbation)];
negativeControl = MemoryConstrained[TimeConstrained[
  structuralSpinReconstruction[First[input["Equations"]], incorrectResponse,
    input["IncomingVariables"], input["OutgoingVariables"]], 600, gate["negative control time bound", False]],
  4*1024^3, gate["negative control memory bound", False]];
gate["changed response rejected", negativeControl["Accepted"] === False &&
  negativeControl["Checks"]["ExactExistingResponse"] === False &&
  And @@ Values[KeyDrop[negativeControl["Checks"], "ExactExistingResponse"]]];
result = <|"Schema" -> "polarized-sidis-structural-reconstruction-comparison-v1", "Channel" -> input["Channel"],
  "Sector" -> input["Sector"], "SourceHash" -> FileHash[source, "SHA256"],
  "EquationResultHash" -> FileHash[inputPath, "SHA256"], "EquationReceiptHash" -> FileHash[receiptPath, "SHA256"],
  "InputHash" -> input["InputHash"], "InputHashes" -> input["PhysicalInputHashes"],
  "EquationInputHashes" -> input["EquationInputHashes"], "IncomingVariables" -> input["IncomingVariables"],
  "OutgoingVariables" -> input["OutgoingVariables"], "Measurements" -> measurements,
  "NegativeControl" -> negativeControl, "CandidateDefinitions" -> DownValues[structuralSpinReconstruction],
  "ExtractionDefinitions" -> DownValues[compactSpinResponse], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
resultDirectory = FileNameJoin[{root, "Hqq", "s05_structural_reconstruction_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
resultPath = FileNameJoin[{resultDirectory, "s05_result.wl"}];
Put[result, resultPath]; gate["exact comparison result reload", Get[resultPath] === result];
Export[FileNameJoin[{resultDirectory, "s05_checks.json"}], <|"channel" -> input["Channel"], "checks" -> checks,
  "measurements" -> measurements, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_structural_reconstruction"]; Quit[0];

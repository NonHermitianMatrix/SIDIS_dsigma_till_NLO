(* Validate compact spin extraction against complete, input-bound matrix checkpoints. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
validationSourcePath = FileNameJoin[{root, "common", "s05_spin_extraction_check.wls"}];
productionPath = FileNameJoin[{root, "common", "s05_result", "reference", "s05_real_spin_response_before_spin_extraction.wls"}];
validationConfigPath = FileNameJoin[{root, "common", "s05_spin_extraction_inputs.json"}];
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["reviewed production generation", IntegerString[FileHash[productionPath, "SHA256"], 16, 64] ===
  "f6ba07013100d854647bc3d1677f58ba2b7b0dd50fd0b0397366e16361873d33"];
productionText = Import[productionPath, "Text"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
productionPrefix = StringTake[productionText, prefixEnd - 1];
oldSourceAssignment = "sourcePath = FileNameJoin[{root, \"common\", \"s05_real_spin_response.wls\"}];";
gate["one archived source assignment", StringCount[productionPrefix, oldSourceAssignment] === 1];
oldPackageInitialization = "$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; Get[\"FeynCalc`\"];";
gate["one inherited package initialization", StringCount[productionPrefix, oldPackageInitialization] === 1];
productionPrefix = StringReplace[productionPrefix, {
  oldSourceAssignment -> "sourcePath = productionPath;",
  oldPackageInitialization -> "gate[\"native package already initialized\", ValueQ[$FeynCalcVersion]];"}];
gate["complete prefix syntax", SyntaxQ[productionPrefix]];
ToExpression[productionPrefix];
gate["complete validation source syntax", SyntaxQ[Import[validationSourcePath, "Text"]]];
gate["bound archived production generation", IntegerString[FileHash[productionPath, "SHA256"], 16, 64] ===
  "f6ba07013100d854647bc3d1677f58ba2b7b0dd50fd0b0397366e16361873d33"];
validationConfig = Import[validationConfigPath, "RawJSON"];
gate["matrix fixture contract", validationConfig["schema"] === "polarized-sidis-spin-extraction-inputs-v1" &&
  channel === validationConfig["channel"] && channel === "Hqqprime"];
fixtureHashes = <||>;
records = Table[
  fixturePath = FileNameJoin[{root, row["path"]}];
  gate["pinned matrix fixture " <> FileNameTake[fixturePath], FileByteCount[fixturePath] === row["bytes"] &&
    IntegerString[FileHash[fixturePath, "SHA256"], 16, 64] === row["sha256"]];
  AssociateTo[fixtureHashes, row["path"] -> FileHash[fixturePath, "SHA256"]];
  record = bounded[Get[fixturePath], "read matrix fixture"];
  gate["accepted matrix fixture " <> FileNameTake[fixturePath], AssociationQ[record] &&
    record["InputHash"] === inputHash && And @@ Values[record["Checks"]]]; record,
  {row, validationConfig["files"]}];
gate["distinct saved matrix entries", DuplicateFreeQ[Lookup[records, "Key"]]];
sumValues = AssociationThread[Lookup[records, "Key"], Lookup[records, "Value"]];
matrix = Table[sumValues["Photon_" <> ToString[a] <> "_" <> ToString[b]],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
gate["complete saved photon matrix", Dimensions[matrix] === {Length[photonSymbols], Length[photonSymbols]} && FreeQ[matrix, _Missing]];
scalarModes = <|"PgD" -> sumValues["Scalar_PgD"], "PhotonWard" -> sumValues["Scalar_PhotonWard"]|>;
fermions = DeleteDuplicates[Cases[generated["amplitudes"], Spinor[sign_. Momentum[mom_, ___], ___] :> mom, Infinity]];
incomingQuark = MemberQ[fermions, p]; outgoingQuark = MemberQ[fermions, k1];
gate["fixture native quark species", incomingQuark && outgoingQuark];
inVariables = {1, xIn, yIn, hIn}; outVariables = {1, xOut, yOut, hOut};
gate["fixture photon Ward identity", scalarModes["PhotonWard"] === 0];
gate["fixture photon Hermiticity", zeroArray[bounded[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]], "matrix Hermiticity"]]];
photon = Tr[#.matrix] & /@ basis["PhotonDual"];
compactSpinResponse[photon_, incoming_, outgoing_] := Module[
  {variables, keys, monomialRows, rows},
  variables = DeleteCases[Join[incoming, outgoing], 1];
  gate["distinct spin polynomial variables", DuplicateFreeQ[variables]];
  keys = Table[
    monomialRows = CoefficientRules[incoming[[i]] outgoing[[j]], variables];
    gate["unit component spin monomial", Length[monomialRows] === 1 && Last[First[monomialRows]] === 1];
    First[First[monomialRows]], {j, Length[outgoing]}, {i, Length[incoming]}];
  gate["distinct component monomials", DuplicateFreeQ[Flatten[keys, 1]]];
  Table[
    gate["polynomial photon spin dependence", PolynomialQ[expression, variables]];
    rows = Association[CoefficientRules[expression, variables]];
    gate["all spin monomials represented", Complement[Keys[rows], Flatten[keys, 1]] === {}];
    Table[If[KeyExistsQ[rows, keys[[j, i]]], rows[keys[[j, i]]], 0],
      {j, Length[outgoing]}, {i, Length[incoming]}], {expression, photon}]];
{extractionSeconds, candidate} = AbsoluteTiming[bounded[
  compactSpinResponse[photon, inVariables, outVariables], "compact spin extraction"]];
gate["complete response dimensions", Dimensions[candidate] === {Length[basis["PhotonLabels"]], Length[outVariables], Length[inVariables]}];
reconstructedPhoton = Table[Sum[inVariables[[i]] outVariables[[j]] candidate[[a, j, i]],
  {i, Length[inVariables]}, {j, Length[outVariables]}], {a, Length[photon]}];
Do[gate["exact spin polynomial " <> ToString[a], bounded[Expand[photon[[a]] - reconstructedPhoton[[a]]] === 0,
    {"spin reconstruction", a}]], {a, Length[photon]}];
reconstructedMatrix = Total[MapThread[Times, {reconstructedPhoton, basis["PhotonBasis"]}]];
Do[gate["exact saved matrix " <> ToString[{a, b}, InputForm],
  bounded[Expand[matrix[[a, b]] - reconstructedMatrix[[a, b]]] === 0, {"matrix reconstruction", a, b}]],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
cdrRules = Thread[Join[Rest[inVariables], Rest[outVariables]] -> 0];
cdr = <|"Pg" -> algebraicReduce[scalarModes["PgD"] /. cdrRules],
  "Ppp" -> algebraicReduce[pComponents.(matrix /. cdrRules).pComponents]|>;
Do[referenceValue = reference[If[mode === "Pg", "g", "pp"]] /. {Nc -> SUNN, gs -> 1};
  gate["complete original reference " <> mode, bounded[
    algebraicReduce[cdr[mode] - (referenceValue /. coordinateRules)] === 0, {"CDR comparison", mode}]],
  {mode, {"Pg", "Ppp"}}];
oldCoefficientCode = sourceSection[productionText, "\n  coefficient[expr_", "\n  response = Table[bounded"];
gate["saved extraction definition syntax", SyntaxQ[oldCoefficientCode]];
ToExpression[oldCoefficientCode];
indices = Tuples[Range /@ Dimensions[candidate]];
polarizedIndices = Select[indices, (#[[2]] > 1 || #[[3]] > 1) && Extract[candidate, #] =!= 0 &];
gate["nonzero polarized comparison exists", Length[polarizedIndices] > 0];
comparisonIndex = First[MaximalBy[polarizedIndices, ByteCount[Extract[candidate, #]] &]];
{oldExtractionSeconds, oldComponent} = AbsoluteTiming[bounded[
  coefficient[coefficient[photon[[First[comparisonIndex]]], inVariables, Last[comparisonIndex]],
    outVariables, comparisonIndex[[2]]], "legacy representative extraction"]];
compactComponent = Extract[candidate, comparisonIndex];
gate["exact legacy polarized component", bounded[Expand[oldComponent - compactComponent] === 0, "legacy component comparison"]];
gate["smaller measured polarized component", ByteCount[compactComponent] < ByteCount[oldComponent]];
evidence = <|"ExtractionSeconds" -> extractionSeconds, "MatrixBytes" -> ByteCount[matrix],
  "CandidateResponseBytes" -> ByteCount[candidate], "ComponentCount" -> Length[indices],
  "ComparisonIndex" -> comparisonIndex, "LegacyComponentBytes" -> ByteCount[oldComponent],
  "CompactComponentBytes" -> ByteCount[compactComponent], "LegacyComponentSeconds" -> oldExtractionSeconds,
  "CompleteMatrixReconstructionPassed" -> True|>;
Print["EXTRACTION_EVIDENCE ", InputForm[evidence]];
result = <|"Schema" -> "polarized-sidis-spin-extraction-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[validationSourcePath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ConfigHash" -> FileHash[validationConfigPath, "SHA256"], "BaselineMatrixInputHashes" -> fixtureHashes,
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "BasisInputHash" -> FileHash[basisPath, "SHA256"],
  "ExtractionDefinitions" -> DownValues[compactSpinResponse], "Evidence" -> evidence,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s05_spin_extraction_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s05_result.wl"}]];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "evidence" -> evidence,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_spin_extraction_check"]; Quit[0];

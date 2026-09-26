(* Validate the saved complete real tensor and compare compact spin extraction. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
sourcePath = FileNameJoin[{root, "common", "s05_spin_extraction_check.wls"}];
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  gate[ToString[label, InputForm] <> " time bound", False]], 2*1024^3,
  gate[ToString[label, InputForm] <> " memory bound", False]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
spinPath = FileNameJoin[{root, "cache", "s05", "Hqqprime", "export_e92eb3ac", "s05_result.wl"}];
productionPath = FileNameJoin[{root, "common", "s05_real_spin_response.wls"}];
gate["reviewed production generation", IntegerString[FileHash[productionPath, "SHA256"], 16, 64] ===
  "f6ba07013100d854647bc3d1677f58ba2b7b0dd50fd0b0397366e16361873d33"];
gate["pinned complete compressed export", IntegerString[FileHash[spinPath, "SHA256"], 16, 64] ===
  "e92eb3ac49cab1ed8c99d1db5e6d5c5eda868557158dd7dc817e05818551181c"];
basis = Get[basisPath];
heldEncoding = ToExpression[Import[spinPath, "Text"], InputForm, HoldComplete];
gate["native compressed expression syntax", MatchQ[heldEncoding, HoldComplete[Uncompress[_String]]]];
encoding = heldEncoding[[1, 1]]; Clear[heldEncoding];
spin = bounded[Uncompress[encoding], "read complete compressed export"];
gate["complete native compression round trip", bounded[Compress[spin] === encoding, "native encoding comparison"]];
Clear[encoding]; ClearSystemCache[];
gate["complete comparison input checks", basis["Schema"] === "polarized-sidis-spin-basis-v1" &&
  spin["Schema"] === "polarized-sidis-real-response-v1" && spin["Channel"] === "Hqqprime" &&
  And @@ Values[basis["Checks"]] && And @@ Values[spin["Checks"]] &&
  spin["SourceHash"] === FileHash[productionPath, "SHA256"]];
gate["unchanged original calculation inputs", And @@ KeyValueMap[
  FileHash[FileNameJoin[{root, #1}], "SHA256"] === #2 &, spin["InputHashes"]]];
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
evidence = <||>;
Do[
  sector = spin["Sectors"][label]; matrix = sector["PhotonMatrix"];
  incoming = Take[{1, xIn, yIn, hIn, eIn}, Length[sector["IncomingSpinLabels"]]];
  outgoing = Take[{1, xOut, yOut, hOut, eOut}, Length[sector["OutgoingSpinLabels"]]];
  photon = Tr[#.matrix] & /@ basis["PhotonDual"];
  {seconds, candidate} = AbsoluteTiming[bounded[compactSpinResponse[photon, incoming, outgoing], label]];
  accepted = sector["ExtendedResponse"];
  gate[label <> " response dimensions", Dimensions[candidate] === Dimensions[accepted]];
  indices = Tuples[Range /@ Dimensions[candidate]];
  Do[gate[label <> " exact saved component " <> ToString[index, InputForm],
    bounded[Expand[Extract[candidate, index] - Extract[accepted, index]] === 0, {label, index}]];
    If[Last[index] === Last[Dimensions[candidate]], ClearSystemCache[]], {index, indices}];
  gate[label <> " exact spin reconstruction", bounded[And @@ Table[
    Expand[photon[[a]] - Sum[incoming[[i]] outgoing[[j]] candidate[[a, j, i]],
      {i, Length[incoming]}, {j, Length[outgoing]}]] === 0, {a, Length[photon]}], label <> " reconstruction"]];
  AssociateTo[evidence, label -> <|"ExtractionSeconds" -> seconds,
    "SavedResponseBytes" -> ByteCount[accepted], "CandidateResponseBytes" -> ByteCount[candidate],
    "ComponentCount" -> Length[indices], "ExactComparisonPassed" -> True|>];
  Print["EXTRACTION_EVIDENCE ", InputForm[evidence[label]]], {label, Keys[spin["Sectors"]]}];
result = <|"Schema" -> "polarized-sidis-spin-extraction-validation-v1", "Channel" -> "Hqqprime",
  "SourceHash" -> FileHash[sourcePath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "SpinInputHash" -> FileHash[spinPath, "SHA256"], "BasisInputHash" -> FileHash[basisPath, "SHA256"],
  "ExtractionDefinitions" -> DownValues[compactSpinResponse], "Evidence" -> evidence,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, "Hqqprime", "s05_spin_extraction_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s05_result.wl"}]];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "evidence" -> evidence,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
(* The mathematical result is unchanged; only its failed storage check is recovered. *)
finalDir = FileNameJoin[{root, "Hqqprime", "s05_result"}];
finalPath = FileNameJoin[{finalDir, "s05_result.wl"}];
gate["no accepted tensor overwritten", !FileExistsQ[finalPath]];
CopyFile[spinPath, finalPath <> ".verified.tmp"];
gate["accepted export is the verified expression", FileHash[finalPath <> ".verified.tmp", "SHA256"] === FileHash[spinPath, "SHA256"]];
RenameFile[finalPath <> ".verified.tmp", finalPath];
Export[FileNameJoin[{finalDir, "s05_checks.json"}], <|"channel" -> "Hqqprime",
  "checks" -> Join[spin["Checks"], checks], "sectors" -> Keys[spin["Sectors"]],
  "export_validation" -> "Hqqprime/s05_spin_extraction_result/s05_result.wl",
  "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s05_spin_extraction_check"]; Quit[0];

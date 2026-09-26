(* Reuse byte-identical accepted scalar work, without reevaluating integrals. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s06_reuse_scalar_integrals.wls"}];
checks = <||>;
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
configPath = FileNameJoin[{root, "common", "s06_inputs.json"}];
config = Import[configPath, "RawJSON"];
layoutPath = FileNameJoin[{root, config["layout_file"]}];
gate["pinned layout identity", IntegerString[FileHash[layoutPath, "SHA256"], 16, 64] === config["layout_sha256"]];
layout = Import[layoutPath, "RawJSON"];
gate["accepted layout", TrueQ[layout["Completed"]]];
library = <||>;
Do[
  path = FileNameJoin[{root, row["destination"]}];
  originalSource = FileNameJoin[{root, row["source_destination"]}];
  expectedResult = layout["AcceptedResultSHA256"][row["original_result"]];
  expectedSource = layout["Sources"][row["original_source"]]["OriginalSHA256"];
  gate[row["stage"] <> " exact accepted result", IntegerString[FileHash[path, "SHA256"], 16, 64] === expectedResult];
  gate[row["stage"] <> " exact executed source", IntegerString[FileHash[originalSource, "SHA256"], 16, 64] === expectedSource];
  packet = Get[path];
  gate[row["stage"] <> " native artifact", AssociationQ[packet] && FreeQ[packet, $Failed | $Aborted]];
  gate[row["stage"] <> " source binding", packet["SourceHash"] === FileHash[originalSource, "SHA256"]];
  Do[gate[row["stage"] <> " " <> key, packet[key]], {key, row["acceptance_keys"]}];
  AssociateTo[library, row["stage"] -> <|"File" -> row["destination"], "SHA256" -> expectedResult,
    "Source" -> row["source_destination"], "SourceSHA256" -> expectedSource,
    "NativeKeys" -> Keys[packet], "Role" -> row["role"]|>];
  Clear[packet], {row, config["artifacts"]}];
result = <|"Schema" -> "polarized-sidis-scalar-library-v1", "Library" -> library,
  "ReferenceCommit" -> config["commit"], "Checks" -> checks,
  "SourceHash" -> FileHash[sourcePath, "SHA256"], "ConfigurationHash" -> FileHash[configPath, "SHA256"],
  "LayoutHash" -> FileHash[layoutPath, "SHA256"],
  "ReevaluatedScalarIntegrals" -> False, "PolarizedTargetCoverageChecked" -> False,
  "ConsumerRequirements" -> {"Exact target-definition reconstruction and coverage",
    "Required regulator depth", "Original cut energy support and measures",
    "Recorded analytic continuation before Hermitian virtual assembly"},
  "FinitePolarizedFHatsComputed" -> False|>;
resultDir = FileNameJoin[{root, "common", "s06_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
Put[result, FileNameJoin[{resultDir, "s06_result.wl.tmp"}]];
RenameFile[FileNameJoin[{resultDir, "s06_result.wl.tmp"}], FileNameJoin[{resultDir, "s06_result.wl"}], OverwriteTarget -> True];
Export[FileNameJoin[{resultDir, "s06_checks.json"}], <|"checks" -> checks,
  "reused_stages" -> Keys[library], "finite_polarized_fhats_computed" -> False,
  "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s06_reuse_scalar_integrals"]; Quit[0];

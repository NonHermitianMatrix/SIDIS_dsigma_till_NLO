(* Exercise the exact native Get interface against an accepted saved tensor. *)
$HistoryLength = 0; root = Directory[]; checks = <||>;
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
source = FileNameJoin[{root, "common", "s05_check_chunked_result_io.wls"}];
ioSource = FileNameJoin[{root, "common", "s05_chunked_result_io.wls"}];
gate["complete storage sources syntax", SyntaxQ[Import[source, "Text"]] && SyntaxQ[Import[ioSource, "Text"]]];
Get[ioSource];
inputPath = FileNameJoin[{root, "Hqqprime", "s05_result", "s05_result.wl"}];
gate["pinned actual accepted tensor", IntegerString[FileHash[inputPath, "SHA256"], 16, 64] ===
  "07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f"];
input = Get[inputPath];
gate["accepted full real tensor", input["Schema"] === "polarized-sidis-real-response-v1" && And @@ Values[input["Checks"]]];
binding = Hash[{FileHash[source, "SHA256"], FileHash[ioSource, "SHA256"], FileHash[inputPath, "SHA256"], $Version}, "SHA256"];
relative = "cache/s05_chunked_io_check/" <> IntegerString[binding, 16];
path = FileNameJoin[{root, relative, "s05_result.wl"}];
manifest = writeChunkedNativeResult[input, path, 1024^2, relative];
gate["actual multi-part storage exercised", Length[manifest["payloads"]] > 1];
gate["unchanged existing Get interface", Get[path] === input];
output = FileNameJoin[{root, "Hgq", "s05_storage_validation_result"}];
If[!DirectoryQ[output], CreateDirectory[output, CreateIntermediateDirectories -> True]];
result = <|"Schema" -> "polarized-sidis-chunked-storage-validation-v1", "SourceHash" -> FileHash[source, "SHA256"],
  "IOSourceHash" -> FileHash[ioSource, "SHA256"], "InputHash" -> FileHash[inputPath, "SHA256"],
  "InputSchema" -> input["Schema"], "Manifest" -> manifest, "WriterDefinitions" -> DownValues[writeChunkedNativeResult],
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
Put[result, FileNameJoin[{output, "s05_result.wl"}]];
gate["storage proof exact native reload", Get[FileNameJoin[{output, "s05_result.wl"}]] === result];
Export[FileNameJoin[{output, "s05_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_chunked_result_io"]; Quit[0];

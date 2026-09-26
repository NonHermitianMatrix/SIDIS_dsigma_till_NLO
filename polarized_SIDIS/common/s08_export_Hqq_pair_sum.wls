(* Read the exact native equation at the failed pair-sum boundary. *)
$HistoryLength = 0;
readerSource = FileNameJoin[{Directory[], "common", "s08_export_Hqq_pair_sum.wls"}];
readerBase = FileNameJoin[{Directory[], "common", "s08_check_same_sector_pair_mapping.wls"}];
If[IntegerString[FileHash[readerBase, "SHA256"], 16, 64] =!=
  "bce641c29f3a4ea773e1f8539284913b56717f2d90a0c0e936c2c4f4f8cfced6", Quit[1]];
readerText = Import[readerBase, "Text"];
If[StringCount[readerText, "\nslots ="] =!= 1 || !SyntaxQ[Import[readerSource, "Text"]], Quit[1]];
readerPrefix = First[StringSplit[readerText, "\nslots ="]];
If[!SyntaxQ[readerPrefix], Quit[1]]; ToExpression[readerPrefix, InputForm];
index = 57; task = tasks[[index]];
gate["actual failed task belongs to the selected sector", task["Sector"] === pairLabel];
values = bounded[pairExpression[#, task] & /@ pairInputs, "original pair equation extraction"];
equation = Total[values] - task["Value"];
directory = FileNameJoin[{root, channel, "s08_pair_sum_equation_result"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
equationPath = FileNameJoin[{directory, "s08_equation.wl"}];
serialized = ToString[equation, InputForm] <> "\n";
gate["bounded readable equation", StringLength[serialized] < 128*1024^2];
Export[equationPath <> ".tmp", serialized, "Text"];
gate["exact original equation native reload", Get[equationPath <> ".tmp"] === equation];
RenameFile[equationPath <> ".tmp", equationPath, OverwriteTarget -> True];
result = <|"Schema" -> "polarized-sidis-pair-sum-equation-v1", "Channel" -> channel,
  "Component" -> index, "Task" -> task, "PairValues" -> values, "EquationHash" -> Hash[equation, "SHA256"],
  "ReadableEquationHash" -> FileHash[equationPath, "SHA256"], "SourceHash" -> FileHash[readerSource, "SHA256"],
  "PairSourceHash" -> FileHash[readerBase, "SHA256"], "InputHashes" -> inputHashes,
  "TargetInputHash" -> targetInputHash, "PairInputHash" -> pairStudyHash,
  "PairFileHashes" -> pairConfig["files"], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "EquationBytes" -> ByteCount[equation], "Checks" -> checks, "NewMappingEvaluated" -> False|>;
pairSave[result, FileNameJoin[{directory, "s08_result.wl"}]];
Export[FileNameJoin[{directory, "s08_checks.json"}], <|"checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "task" -> ToString[KeyDrop[task, "Value"], InputForm],
  "equation_bytes" -> ByteCount[equation], "readable_bytes" -> FileByteCount[equationPath],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_export_Hqq_pair_sum"]; Quit[0];

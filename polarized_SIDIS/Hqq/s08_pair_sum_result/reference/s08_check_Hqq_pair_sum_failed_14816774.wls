(* Exact expansion before the inherited rational zero test. *)
$HistoryLength = 0;
sumSource = FileNameJoin[{Directory[], "common", "s08_check_Hqq_pair_sum.wls"}];
sumBase = FileNameJoin[{Directory[], "common", "s08_check_same_sector_pair_mapping.wls"}];
If[IntegerString[FileHash[sumBase, "SHA256"], 16, 64] =!=
  "bce641c29f3a4ea773e1f8539284913b56717f2d90a0c0e936c2c4f4f8cfced6", Quit[1]];
sumText = Import[sumBase, "Text"];
If[StringCount[sumText, "\nslots ="] =!= 1 || !SyntaxQ[Import[sumSource, "Text"]], Quit[1]];
sumPrefix = First[StringSplit[sumText, "\nslots ="]];
If[!SyntaxQ[sumPrefix], Quit[1]]; ToExpression[sumPrefix, InputForm];
sumInputDir = FileNameJoin[{root, channel, "s08_pair_sum_equation_result"}];
sumInputPath = FileNameJoin[{sumInputDir, "s08_result.wl"}];
sumReceipt = Import[FileNameJoin[{sumInputDir, "s08_execution.json"}], "RawJSON"];
gate["accepted native equation export", TrueQ[sumReceipt["passed"]] &&
  sumReceipt["result_sha256"][channel <> "/s08_pair_sum_equation_result/s08_result.wl"] ===
    IntegerString[FileHash[sumInputPath, "SHA256"], 16, 64]];
sumInput = Get[sumInputPath];
gate["exact source input and runtime identities", sumInput["Channel"] === channel &&
  sumInput["PairSourceHash"] === FileHash[sumBase, "SHA256"] &&
  sumInput["InputHashes"] === inputHashes && sumInput["TargetInputHash"] === targetInputHash &&
  sumInput["PairInputHash"] === pairStudyHash && sumInput["PairFileHashes"] === pairConfig["files"] &&
  sumInput["NativeVersions"] === {$Version, $FeynCalcVersion}];
sumIndex = sumInput["Component"];
gate["saved task exactly matches production", sumInput["Task"] === tasks[[sumIndex]]];
sumEquation = Total[sumInput["PairValues"]] - sumInput["Task"]["Value"];
gate["exact saved cancellation equation", Hash[sumEquation, "SHA256"] === sumInput["EquationHash"]];
expandedPairZero[value_] := Module[{expanded = Expand[value]},
  If[expanded === 0, True, zero[expanded]]];
{sumSeconds, sumExpanded} = AbsoluteTiming[bounded[Expand[sumEquation], "saved cancellation expansion"]];
gate["saved failed cancellation is exactly zero after expansion", sumExpanded === 0];
sumControlTask = tasks[[pairControlIndex]];
sumControlValues = bounded[pairExpression[#, sumControlTask] & /@ pairInputs, "own control extraction"];
sumControlEquation = Total[sumControlValues] - sumControlTask["Value"];
{sumOldSeconds, sumOldValue} = AbsoluteTiming[bounded[zero[sumControlEquation], "own original zero test"]];
{sumNewSeconds, sumNewValue} = AbsoluteTiming[bounded[expandedPairZero[sumControlEquation], "own expanded zero test"]];
gate["own accepted control cancellation reproduced", TrueQ[sumOldValue] && sumNewValue === sumOldValue];
sumControlReconstruction = pairReconstruct[pairOwnControl["Coefficients"]] - (sumControlTask["Value"] /. coordinateRules);
gate["own accepted full map reconstruction preserved", bounded[expandedPairZero[sumControlReconstruction], "own full map comparison"]];
sumDir = FileNameJoin[{root, channel, "s08_pair_sum_result"}];
If[!DirectoryQ[sumDir], CreateDirectory[sumDir, CreateIntermediateDirectories -> True]];
sumResult = <|"Schema" -> "polarized-sidis-pair-sum-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[sumSource, "SHA256"], "PairSourceHash" -> FileHash[sumBase, "SHA256"],
  "EquationResultHash" -> FileHash[sumInputPath, "SHA256"], "EquationHash" -> Hash[sumEquation, "SHA256"],
  "InputHashes" -> inputHashes, "TargetInputHash" -> targetInputHash, "PairInputHash" -> pairStudyHash,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Component" -> sumIndex,
  "OriginalZeroDefinitions" -> DownValues[zero], "ExpandedZeroDefinitions" -> DownValues[expandedPairZero],
  "OriginalMappingDefinitions" -> DownValues[mapExpression], "OriginalMergeDefinitions" -> DownValues[merge],
  "Seconds" -> <|"SavedExpansion" -> sumSeconds, "OriginalControl" -> sumOldSeconds, "ExpandedControl" -> sumNewSeconds|>,
  "InputBytes" -> ByteCount[sumEquation], "ExpandedBytes" -> ByteCount[sumExpanded],
  "ControlIndex" -> pairControlIndex, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
pairSave[sumResult, FileNameJoin[{sumDir, "s08_result.wl"}]];
Export[FileNameJoin[{sumDir, "s08_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"],
  "seconds" -> sumResult["Seconds"], "input_bytes" -> ByteCount[sumEquation],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_Hqq_pair_sum"]; Quit[0];

(* Save completed scalar coefficients without changing their defining reduction. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s05_check_scalar_checkpoints.wls"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "24fe8bc812f0a7306ee73ab9346d0e772d6d0bba77839feee131da55142f5c65", Print["FAIL: reviewed scalar source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
prefix = StringTake[productionText, prefixEnd - 1];
prefix = StringReplace[prefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[prefix], Print["FAIL: scalar initialization syntax"]; Quit[1]];
ToExpression[prefix];
gate["complete scalar checkpoint comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
gate["own scalar checkpoint comparison channel", channel === "Hgg" && useRestoredScalar && useFactoredPair];
label = First[labels]; gate["single comparison sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged complete pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
controlPair = First[pairs];
gate["control pair is diagonal", SameQ @@ controlPair];
controlPath = FileNameJoin[{cache, label <> "_" <> ToString[First[controlPair]] <> "_" <> ToString[Last[controlPair]] <> ".wl"}];
gate["pinned accepted own control pair", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  "16e98e475d6b9922b571ea98bc9b6c6a8d2fe473b2a12a221986e4cc443f1a9b"];
control = Get[controlPath];
gate["complete own control input binding", control["InputHash"] === inputHash && And @@ Values[control["Checks"]]];
originalRestorationDefinitions = DownValues[restoredScalarComponent];
originalReductionDefinitions = {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]};
coefficientAlgorithmHash = Hash[{originalRestorationDefinitions, originalReductionDefinitions, transverseConstraint}, "SHA256"];
coefficientDirectory = FileNameJoin[{root, "cache", "s05_coefficients", channel, IntegerString[inputHash, 16], IntegerString[coefficientAlgorithmHash, 16]}];
If[!DirectoryQ[coefficientDirectory], CreateDirectory[coefficientDirectory, CreateIntermediateDirectories -> True]];
coefficientCacheHits = 0; coefficientCacheWrites = 0;
checkpointedScalarComponent[component_] := Module[{restored, argumentHash, path, saved, answer, seconds, record, serialized, temporary},
  restored = (component /. epsilonRule) /. scalarRestore;
  argumentHash = Hash[{inputHash, coefficientAlgorithmHash, restored}, "SHA256"];
  path = FileNameJoin[{coefficientDirectory, IntegerString[argumentHash, 16, 64] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "InputHash", None] === inputHash && Lookup[saved, "ArgumentHash", None] === argumentHash && KeyExistsQ[saved, "Value"],
    coefficientCacheHits++; Print["REUSED_SCALAR_COEFFICIENT ", IntegerString[argumentHash, 16, 64]]; Return[saved["Value"]]];
  {seconds, answer} = AbsoluteTiming[algebraicReduce[restored]];
  record = <|"InputHash" -> inputHash, "ArgumentHash" -> argumentHash, "Value" -> answer|>;
  serialized = "Uncompress[" <> ToString[Compress[record], InputForm] <> "]\n";
  gate["scalar coefficient below file bound", StringLength[serialized] < 128*1024^2];
  temporary = path <> "." <> ToString[$ProcessID] <> ".tmp";
  Export[temporary, serialized, "Text"];
  gate["scalar coefficient exact saved value", Get[temporary] === record];
  RenameFile[temporary, path, OverwriteTarget -> True]; coefficientCacheWrites++;
  Print["SAVED_SCALAR_COEFFICIENT ", IntegerString[argumentHash, 16, 64], " seconds ", seconds, " bytes ", FileByteCount[path]]; answer];
DownValues[restoredScalarComponent] = DownValues[checkpointedScalarComponent] /. checkpointedScalarComponent -> restoredScalarComponent;
gate["unchanged complete scalar reduction equations", originalReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]}];
tensor = bounded[buildPair[First[controlPair], Last[controlPair], None], "own scalar control closure"];
projected = photonProject[tensor, First[photonSymbols], First[photonSymbols]];
{traceSeconds, traced} = AbsoluteTiming[bounded[Contract[DiracSimplify[projected, DiracTraceEvaluate -> True]], "own scalar control trace"]];
{firstSeconds, firstValue} = AbsoluteTiming[bounded[reduceScalar[traced], "own scalar checkpoint control"]];
gate["complete own accepted projection reproduced", firstValue === control["PhotonMatrix"][[1, 1]] ||
  bounded[algebraicReduce[firstValue - control["PhotonMatrix"][[1, 1]]] === 0, "own scalar control equality"]];
firstWrites = coefficientCacheWrites; firstHits = coefficientCacheHits;
{reloadSeconds, reloadValue} = AbsoluteTiming[bounded[reduceScalar[traced], "own scalar checkpoint reload"]];
gate["complete cached projection exactly unchanged", reloadValue === firstValue];
gate["saved coefficients actually reused", coefficientCacheHits > firstHits && coefficientCacheWrites === firstWrites];
gate["all scalar equations retained", originalReductionDefinitions ===
  {DownValues[algebraicReduce], DownValues[algebraicReduceOne], DownValues[angularAverage], DownValues[angularAverageOne]}];
result = <|"Schema" -> "polarized-sidis-scalar-checkpoint-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "ControlHash" -> FileHash[controlPath, "SHA256"], "ControlPair" -> controlPair,
  "OriginalRestorationDefinitions" -> originalRestorationDefinitions, "ReductionDefinitions" -> originalReductionDefinitions,
  "CheckpointDefinitions" -> DownValues[checkpointedScalarComponent], "InstalledDefinitions" -> DownValues[restoredScalarComponent],
  "AlgorithmHash" -> coefficientAlgorithmHash, "TraceSeconds" -> traceSeconds, "FirstSeconds" -> firstSeconds,
  "ReloadSeconds" -> reloadSeconds, "CacheHits" -> coefficientCacheHits, "CacheWrites" -> coefficientCacheWrites,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultDir = FileNameJoin[{root, channel, "s05_scalar_checkpoint_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s05_result.wl"}]];
gate["scalar checkpoint proof exact reload", Get[FileNameJoin[{resultDir, "s05_result.wl"}]] === result];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"checks" -> checks, "trace_seconds" -> traceSeconds,
  "first_seconds" -> firstSeconds, "reload_seconds" -> reloadSeconds, "cache_hits" -> coefficientCacheHits,
  "cache_writes" -> coefficientCacheWrites, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_scalar_checkpoints"]; Quit[0];

(* Inspect the actual timed-out real coefficient and validate on-shell compaction. *)
$HistoryLength = 0;
profileRoot = Directory[];
profileSource = FileNameJoin[{profileRoot, "common", "s08_coefficient_check.wls"}];
profileMapper = FileNameJoin[{profileRoot, "common", "s08_map_real_spin.wls"}];
If[IntegerString[FileHash[profileMapper, "SHA256"], 16, 64] =!=
  "e23a79589bfce183535a6f1166eda799a9f119168feb9cff1b13feb669c8b21f", Quit[1]];
profileText = Import[profileMapper, "Text"];
profileStop = First[First[StringPosition[profileText, "\ncomponents = {}; targets = {};"]]];
ToExpression[StringTake[profileText, profileStop - 1], InputForm];
gate["complete coefficient check syntax", SyntaxQ[Import[profileSource, "Text"]]];
gate["comparison uses accepted Hqqprime tensor", channel === "Hqqprime" &&
  IntegerString[FileHash[spinPath, "SHA256"], 16, 64] ===
    "07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f"];
profileReductionPath = FileNameJoin[{root, "common", "s05_result", "reference",
  "s05_real_spin_response_before_parallel_spin_checks.wls"}];
gate["accepted on-shell reduction source", IntegerString[FileHash[profileReductionPath, "SHA256"], 16, 64] ===
  "46c45f60a0f97c18d430cd8a3ee05182bc5e10f5deb424e8b69487d76e75e500"];
profileReductionText = Import[profileReductionPath, "Text"];
profileReductionBegin = First[First[StringPosition[profileReductionText, "algebraicReduceOne[value_] := Module["]]];
profileReductionEnd = First[First[StringPosition[profileReductionText, "\npVector = Factor["]]];
profileReductionCode = StringTake[profileReductionText, {profileReductionBegin, profileReductionEnd - 1}];
ToExpression[profileReductionCode, InputForm];
transverseConstraint = spin["TransverseConstraint"];
gate["saved transverse constraint has no cut coordinates", FreeQ[transverseConstraint, a | b]];
profileHash = Hash[{FileHash[profileSource, "SHA256"], inputHashes,
  FileHash[profileReductionPath, "SHA256"], $Version, $FeynCalcVersion}, "SHA256"];
profileCache = FileNameJoin[{root, "cache", "s08_coefficient_check", IntegerString[profileHash, 16]}];
If[!DirectoryQ[profileCache], CreateDirectory[profileCache, CreateIntermediateDirectories -> True]];
profileTask = First[tasks];
Print["COEFFICIENT_INPUT ", KeyDrop[profileTask, "Value"]];
profileValue = profileTask["Value"] /. coordinateRules;
{profileMapSeconds, profileCoefficients} = AbsoluteTiming[bounded[mapExpression[profileValue], "actual failed raw map"]];
put[<|"InputHash" -> profileHash, "Task" -> KeyDrop[profileTask, "Value"],
  "Coefficients" -> profileCoefficients, "MappingChecks" -> checks|>,
  FileNameJoin[{profileCache, "s08_raw_map.wl"}]];
profileMaster = First[Sort[reduction["Masters"]]];
profileRuleMap = Association[reduction["Rules"]];
profileMissing = Complement[Keys[profileCoefficients], Keys[profileRuleMap]];
profileRuleMap = Join[profileRuleMap, AssociationThread[profileMissing, profileMissing]];
profileTerms = KeyValueMap[#2 Coefficient[profileRuleMap[#1], profileMaster] &, profileCoefficients];
profileInputEvidence = <|"InputBytes" -> ByteCount[profileValue], "RawMapSeconds" -> profileMapSeconds,
  "RawCoefficientBytes" -> ByteCount[profileCoefficients], "RawTargetCount" -> Length[profileCoefficients],
  "Master" -> profileMaster, "MasterTermBytes" -> ByteCount[profileTerms],
  "NonzeroMasterTerms" -> Count[profileTerms, Except[0]],
  "TransverseDegrees" -> DeleteDuplicates[Exponent[#, transverseK] & /@ Values[profileCoefficients]],
  "CoefficientSymbols" -> globalSymbols[Values[profileCoefficients]]|>;
Print["COEFFICIENT_INPUT_EVIDENCE ", InputForm[profileInputEvidence]];
put[profileInputEvidence, FileNameJoin[{profileCache, "s08_input_evidence.wl"}]];
profileCompact = <||>; profileTimings = {};
KeyValueMap[Function[{integral, value}, Module[{seconds, compact},
  Print["COMPACT_CUT_COEFFICIENT ", InputForm[integral], " bytes ", ByteCount[value]];
  {seconds, compact} = AbsoluteTiming[bounded[algebraicReduceOne[value], {"native on-shell compaction", integral}]];
  AssociateTo[profileCompact, integral -> compact];
  AppendTo[profileTimings, <|"Integral" -> integral, "Seconds" -> seconds,
    "InputBytes" -> ByteCount[value], "OutputBytes" -> ByteCount[compact]|>]]], profileCoefficients];
gate["compaction retains complete cut inventory", Keys[profileCompact] === Keys[profileCoefficients]];
put[<|"InputHash" -> profileHash, "Coefficients" -> profileCompact, "Timings" -> profileTimings,
  "Checks" -> checks|>, FileNameJoin[{profileCache, "s08_compact_map.wl"}]];
profileRemaining = Union[Cases[Total[KeyValueMap[Times, profileCompact]] /. reduction["Rules"], _CutIntegral, Infinity]];
{profileAssemblySeconds, profileReduced} = AbsoluteTiming[
  referenceCoefficients[profileCompact, profileRemaining, "on-shell coefficient comparison"]];
gate["compacted reduction exactly reconstructs", bounded[zero[
  (Total[KeyValueMap[Times, profileCompact]] /. reduction["Rules"]) -
  Total[KeyValueMap[Times, profileReduced]]], "compacted master reconstruction"]];
profileResult = <|"Schema" -> "polarized-sidis-real-coefficient-compaction-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[profileSource, "SHA256"], "MapperSourceHash" -> FileHash[profileMapper, "SHA256"],
  "ReductionSourceHash" -> FileHash[profileReductionPath, "SHA256"], "InputHash" -> profileHash,
  "InputHashes" -> inputHashes, "Task" -> KeyDrop[profileTask, "Value"],
  "InputEvidence" -> profileInputEvidence, "Timings" -> profileTimings,
  "CompactCoefficientBytes" -> ByteCount[profileCompact], "MasterAssemblySeconds" -> profileAssemblySeconds,
  "ReducedCoefficients" -> profileReduced, "OnShellReductionCode" -> profileReductionCode,
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
profileDir = FileNameJoin[{root, channel, "s08_coefficient_result"}];
If[!DirectoryQ[profileDir], CreateDirectory[profileDir, CreateIntermediateDirectories -> True]];
put[profileResult, FileNameJoin[{profileDir, "s08_result.wl"}]];
Export[FileNameJoin[{profileDir, "s08_checks.json"}], <|"channel" -> channel,
  "checks" -> checks, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_coefficient_check"]; Quit[0];

(* Preserve the reference cut mapper and map the measured denominator groups separately. *)
$HistoryLength = 0;
groupRoot = Directory[];
groupSourcePath = FileNameJoin[{groupRoot, "common", "s08_grouped_mapping_check.wls"}];
groupMapperPath = FileNameJoin[{groupRoot, "common", "s08_map_real_targets.wls"}];
groupAssert[name_, test_] := If[!TrueQ[test], Print["FAIL: ", name]; Quit[1]];
groupAssert["grouped comparison source syntax", SyntaxQ[Import[groupSourcePath, "Text"]]];
groupAssert["reviewed unchanged target mapper", IntegerString[FileHash[groupMapperPath, "SHA256"], 16, 64] ===
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9"];
groupMapperText = Import[groupMapperPath, "Text"];
groupBoundary = StringPosition[groupMapperText, "\nmapTargetTask[index_]"];
groupAssert["unique inherited mapping boundary", Length[groupBoundary] === 1];
groupPrefix = StringTake[groupMapperText, First[First[groupBoundary]] - 1];
groupAssert["complete inherited mapping initialization", SyntaxQ[groupPrefix]];
ToExpression[groupPrefix, InputForm];
gate["group comparison owns inspected channel", channel === "Hqqbar"];
groupInspectionPath = FileNameJoin[{root, channel, "s08_equation_result", "s08_result.wl"}];
gate["pinned actual equation inspection", IntegerString[FileHash[groupInspectionPath, "SHA256"], 16, 64] ===
  "1b22fb16c047be46bd56fa9988873eb4c0e8cd526bd939ca8a5ec3e93d5c6a64"];
groupInspection = Get[groupInspectionPath];
gate["accepted input equation reconstruction", groupInspection["Schema"] === "polarized-sidis-mapping-equation-inspection-v1" &&
  groupInspection["Channel"] === channel && groupInspection["InputHashes"] === inputHashes &&
  groupInspection["MappingInputHash"] === targetInputHash && And @@ Values[groupInspection["Checks"]] &&
  And @@ Lookup[groupInspection["Measurements"], "ExactReconstruction"]];
groupCalculationHash = FileHash[groupSourcePath, "SHA256"];
groupInputHash = Hash[{groupCalculationHash, inputHashes, targetInputHash, $Version, $FeynCalcVersion}, "SHA256"];
groupCache = FileNameJoin[{root, "cache", "s08_grouped_check", channel, IntegerString[groupInputHash, 16]}];
If[!DirectoryQ[groupCache], CreateDirectory[groupCache, CreateIntermediateDirectories -> True]];

groupDenominators[expression_] := Module[{terms, atoms, groups, reconstructed},
  terms = If[Head[expression] === Plus, List @@ expression, {expression}];
  gate["complete additive input reconstruction", Total[terms] === expression];
  atoms = extractAtoms /@ terms;
  groups = GroupBy[atoms, First -> Last, Total];
  reconstructed = Total[KeyValueMap[#2/(Times @@ MapThread[Power, {denominators, #1}]) &, groups]];
  gate["complete denominator-group reconstruction", zero[expression - reconstructed]];
  groups];

(* The reconstruction uses the exact measured propagators and cut powers of the reference mapper. *)
groupedMapExpression[expression_, key_] := Module[
  {groups, groupValues, packets, binding, path, saved, seconds, coefficients, rows, reconstruction},
  groups = bounded[groupDenominators[expression], {key, "derive denominator groups"}];
  groupValues = KeyValueMap[#2/(Times @@ MapThread[Power, {denominators, #1}]) &, groups];
  Print["GROUPED_MAP_INPUT ", key, " groups ", Length[groupValues], " bytes ", ByteCount[expression]];
  packets = Table[
    binding = Hash[{groupInputHash, key, index, groupValues[[index]]}, "SHA256"];
    path = FileNameJoin[{groupCache, key <> "_group_" <> IntegerString[index, 10, 4] <> ".wl"}];
    saved = If[FileExistsQ[path], Get[path], <||>];
    If[Lookup[saved, "Binding", None] =!= binding || !TrueQ[Lookup[saved, "Accepted", False]] ||
        !AssociationQ[Lookup[saved, "Checks", None]] || Length[saved["Checks"]] === 0 || !And @@ Values[saved["Checks"]],
      Print["GROUPED_MAP_PIECE ", key, " ", index, "/", Length[groupValues], " powers ", Keys[groups][[index]]];
      saved = Block[{checks = <||>},
        {seconds, coefficients} = AbsoluteTiming[bounded[mapExpression[groupValues[[index]]], {key, index, "unchanged reference mapping"}]];
        <|"Binding" -> binding, "Accepted" -> True, "Coefficients" -> coefficients, "Checks" -> checks,
          "Seconds" -> seconds, "InputBytes" -> ByteCount[groupValues[[index]]]|>];
      put[saved, path]; ClearSystemCache[]]; saved,
    {index, Length[groupValues]}];
  gate["every denominator group accepted", AllTrue[packets, AssociationQ] && And @@ Lookup[packets, "Accepted"] &&
    And @@ Flatten[Values[#["Checks"]] & /@ packets]];
  rows = bounded[merge[Lookup[packets, "Coefficients"]], {key, "merge exact group maps"}];
  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power,
      {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], rows]];
  gate["complete grouped cut-family map reconstructs input", bounded[zero[reconstruction - expression], {key, "complete map reconstruction"}]];
  gate["both physical cuts remain to unit power in every grouped target",
    And @@ (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[rows])];
  rows];

groupControlExpression = targetControlTask["Value"] /. coordinateRules;
groupControlPacket = Block[{checks = <||>},
  {groupControlSeconds, groupControlCoefficients} = AbsoluteTiming[
    groupedMapExpression[groupControlExpression, "accepted_control"]];
  groupReferenceExpression = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power,
      {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], targetFixture["Coefficients"]]];
  groupCandidateExpression = Total[KeyValueMap[Function[{integral, coefficient},
    coefficient Times @@ MapThread[Power,
      {families[integral[[1]]]["OnCutUncutPropagators"], -Drop[integral[[2]], 2]}]], groupControlCoefficients]];
  gate["complete own accepted control map comparison",
    bounded[zero[groupCandidateExpression - groupReferenceExpression], "own accepted control map comparison"]];
  <|"Seconds" -> groupControlSeconds, "Coefficients" -> groupControlCoefficients,
    "ReferenceHash" -> FileHash[targetFixturePath, "SHA256"],
    "IdenticalRawMap" -> (groupControlCoefficients === targetFixture["Coefficients"]), "Checks" -> checks|>];
gate["accepted control comparison completed", And @@ Values[groupControlPacket["Checks"]]];
Print["GROUPED_MAP_CONTROL seconds ", groupControlSeconds, " identical_raw_map ", groupControlPacket["IdenticalRawMap"]];
groupComponents = Table[Block[{checks = <||>},
  groupTask = tasks[[groupIndex]];
  groupExpression = groupTask["Value"] /. coordinateRules;
  gate["actual inspected component identity", groupExpression === groupInspection["Equations"][groupIndex]["OriginalValue"]];
  {groupSeconds, groupCoefficients} = AbsoluteTiming[groupedMapExpression[groupExpression, "component_" <> ToString[groupIndex]]];
  groupComponent = Join[KeyDrop[groupTask, "Value"], <|"ComponentIndex" -> groupIndex,
    "Coefficients" -> groupCoefficients, "MissingTargets" -> Complement[Keys[groupCoefficients], ruleKeys, reduction["Masters"]],
    "InputHash" -> targetInputHash, "ReconstructionPassed" -> True, "Checks" -> checks,
    "Seconds" -> groupSeconds, "InputBytes" -> ByteCount[groupTask["Value"]], "OutputBytes" -> ByteCount[groupCoefficients]|>];
  Print["GROUPED_MAP_COMPONENT_ACCEPTED ", groupIndex, " seconds ", groupSeconds,
    " targets ", Length[groupCoefficients], " bytes ", ByteCount[groupCoefficients]];
  groupComponent], {groupIndex, Keys[groupInspection["Equations"]]}];
gate["every inspected component accepted", And @@ Lookup[groupComponents, "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ groupComponents]];
groupResult = <|"Schema" -> "polarized-sidis-grouped-mapping-comparison-v1", "Channel" -> channel,
  "SourceHash" -> groupCalculationHash, "MapperSourceHash" -> FileHash[groupMapperPath, "SHA256"],
  "InputHashes" -> inputHashes, "InputHash" -> groupInputHash, "MappingInputHash" -> targetInputHash,
  "InspectionHash" -> FileHash[groupInspectionPath, "SHA256"], "ControlComparison" -> groupControlPacket,
  "Components" -> groupComponents, "GroupingDefinitions" -> DownValues[groupDenominators],
  "MappingDefinitions" -> DownValues[groupedMapExpression], "OriginalMappingDefinitions" -> DownValues[mapExpression],
  "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
groupResultDir = FileNameJoin[{root, channel, "s08_grouped_result"}];
If[!DirectoryQ[groupResultDir], CreateDirectory[groupResultDir, CreateIntermediateDirectories -> True]];
groupResultPath = FileNameJoin[{groupResultDir, "s08_result.wl"}];
groupSerialized = "Uncompress[" <> ToString[bounded[Compress[groupResult], "group comparison compression"], InputForm] <> "]\n";
gate["group comparison saved-file bound", StringLength[groupSerialized] < 128*1024^2];
Export[groupResultPath <> ".tmp", groupSerialized, "Text"];
gate["group comparison exact saved round trip", bounded[Get[groupResultPath <> ".tmp"] === groupResult, "group comparison reload"]];
RenameFile[groupResultPath <> ".tmp", groupResultPath, OverwriteTarget -> True];
Export[FileNameJoin[{groupResultDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_grouped_mapping_check"]; Quit[0];

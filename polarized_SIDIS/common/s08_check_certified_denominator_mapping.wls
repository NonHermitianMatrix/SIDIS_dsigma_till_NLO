(* Reuse executed term and merge certificates on the actual Hgq denominator groups. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s08_check_certified_denominator_mapping.wls"}];
comparisonConfigPath = FileNameJoin[{Directory[], "common", "s08_certified_denominator_inputs.json"}];
comparisonBasePath = FileNameJoin[{Directory[], "common", "s08_map_targets_by_denominator.wls"}];
comparisonRequire[name_, test_] := If[!TrueQ[test], Print["FAIL: ", name]; Quit[1]];
comparisonConfig = Import[comparisonConfigPath, "RawJSON"];
comparisonRequire["comparison input schema", comparisonConfig["schema"] === "polarized-sidis-certified-denominator-inputs-v1"];
KeyValueMap[Function[{relative, identity}, comparisonRequire["pinned comparison input " <> relative,
  IntegerString[FileHash[FileNameJoin[{Directory[], relative}], "SHA256"], 16, 64] === identity]], comparisonConfig["files"]];
comparisonBaseText = Import[comparisonBasePath, "Text"];
comparisonBoundary = StringPosition[comparisonBaseText, "\ngroupPreviousTargetHash ="];
comparisonRequire["unique unchanged initialization boundary", Length[comparisonBoundary] === 1];
comparisonPrefix = StringTake[comparisonBaseText, First[First[comparisonBoundary]] - 1];
comparisonRequire["complete initialization syntax", SyntaxQ[comparisonPrefix]];
ToExpression[comparisonPrefix, InputForm];
gate["complete certified denominator comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
gate["own accepted gluon-quark tensor", channel === "Hgq"];
groupCertificatePath = FileNameJoin[{root, "Hqqbar", "s08_group_certificate_result", "s08_result.wl"}];
mergeCertificatePath = FileNameJoin[{root, "Hqqbar", "s08_pair_merge_result", "s08_result.wl"}];
groupCertificate = Get[groupCertificatePath]; mergeCertificate = Get[mergeCertificatePath];
gate["accepted grouping certificate definitions", groupCertificate["Schema"] === "polarized-sidis-group-reconstruction-comparison-v1" &&
  And @@ Values[groupCertificate["Checks"]] && groupCertificate["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  groupCertificate["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s08_check_group_reconstruction.wls"}], "SHA256"] &&
  groupCertificate["GroupingProofHash"] === FileHash[groupProofPath, "SHA256"] &&
  groupCertificate["OriginalGroupingDefinitions"] === DownValues[groupDenominators] &&
  KeyDrop[groupCertificate["InputHashes"], "Hqqbar/s05_result/s05_result.wl"] === KeyDrop[inputHashes, channel <> "/s05_result/s05_result.wl"]];
gate["accepted original merge and native certificate", mergeCertificate["Schema"] === "polarized-sidis-pair-merge-linearity-v1" &&
  And @@ Values[mergeCertificate["Checks"]] && mergeCertificate["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  mergeCertificate["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s08_check_pair_merge_linearity.wls"}], "SHA256"] &&
  mergeCertificate["OriginalMappingDefinitions"] === DownValues[mapExpression] &&
  mergeCertificate["OriginalMergeDefinitions"] === DownValues[merge]];
originalMappingDefinitions = DownValues[mapExpression]; originalMergeDefinitions = DownValues[merge];
DownValues[certifyGrouping] = groupCertificate["CertificateDefinitions"];
DownValues[groupDenominators] = groupCertificate["GroupingDefinitions"];
DownValues[certifyPairMerge] = mergeCertificate["CertificateDefinitions"];
pairSourcePath = FileNameJoin[{root, "common", "s08_check_quark_pair_mapping.wls"}];
pairSourceText = Import[pairSourcePath, "Text"];
pairReconstructionText = StringTake[pairSourceText, {
  First[First[StringPosition[pairSourceText, "pairReconstruct[coefficients_]"]]],
  First[First[StringPosition[pairSourceText, "\nslots ="]]] - 1}];
gate["original pair reconstruction syntax", SyntaxQ[pairReconstructionText]];
ToExpression[pairReconstructionText];
certifyGroupMerge[packets_, coefficients_] := Module[{maps, grouped},
  maps = Lookup[packets, "Coefficients"]; grouped = Merge[maps, Identity];
  gate["every merged group coefficient equals its full input sum", And @@ KeyValueMap[
    bounded[zero[Lookup[coefficients, #1, 0] - Total[#2]], {"merged group coefficient reconstruction", #1}] &, grouped]];
  certifyPairMerge[maps, grouped, coefficients]];
groupCheckText = Import[groupCheckPath, "Text"];
groupMappingText = StringTake[groupCheckText, {
  First[First[StringPosition[groupCheckText, "groupedMapExpression[expression_, key_]"]]],
  First[First[StringPosition[groupCheckText, "\ngroupControlExpression ="]]] - 1}];
originalPredicate = "zero[reconstruction - expression]";
candidatePredicate = "certifyGroupMerge[packets, rows]";
gate["unique final reconstruction replacement", StringCount[groupMappingText, originalPredicate] === 1];
candidateMappingText = StringReplace[groupMappingText, originalPredicate -> candidatePredicate];
gate["all grouping and mapping operations otherwise unchanged",
  StringReplace[candidateMappingText, candidatePredicate -> originalPredicate] === groupMappingText];
gate["complete candidate mapping syntax", SyntaxQ[candidateMappingText]];
ToExpression[candidateMappingText];
groupInputHash = Hash[{FileHash[comparisonPath, "SHA256"], FileHash[comparisonConfigPath, "SHA256"],
  inputHashes, targetInputHash, $Version, $FeynCalcVersion}, "SHA256"];
groupCache = FileNameJoin[{root, "cache", "s08_certified_denominator", channel, IntegerString[groupInputHash, 16]}];
If[!DirectoryQ[groupCache], CreateDirectory[groupCache, CreateIntermediateDirectories -> True]];
comparisonSave[value_, path_] := Module[{temporary, serialized},
  temporary = path <> "." <> ToString[$ProcessID] <> ".tmp";
  serialized = "Uncompress[" <> ToString[bounded[Compress[value], "comparison compression"], InputForm] <> "]\n";
  gate["bounded comparison native file", StringLength[serialized] < 128*1024^2];
  Export[temporary, serialized, "Text"];
  gate["exact comparison native reload", bounded[Get[temporary] === value, "comparison reload"]];
  RenameFile[temporary, path, OverwriteTarget -> True]];
controls = Association@Table[
  controlPath = FileNameJoin[{root, relative}]; control = Get[controlPath];
  controlIndex = FromDigits[First[StringCases[FileBaseName[relative], DigitCharacter ..]]];
  gate["complete own control binding " <> ToString[controlIndex], control["InputHash"] === targetInputHash &&
    TrueQ[control["ReconstructionPassed"]] && And @@ Values[control["Checks"]] &&
    KeyTake[control, {"Sector", "Kind", "Index"}] === KeyDrop[tasks[[controlIndex]], "Value"]];
  controlIndex -> <|"File" -> relative, "Hash" -> FileHash[controlPath, "SHA256"], "Record" -> control|>,
  {relative, comparisonConfig["own_controls"]}];
controlIndex = First[MinimalBy[Keys[controls], controls[#]["Record"]["Seconds"] &]];
candidateIndices = Complement[Range[Length[tasks]], Keys[controls]];
gate["actual unfinished component inventory", candidateIndices =!= {}];
selected = {controlIndex, First[candidateIndices]};
comparisonComponents = Table[Block[{checks = <||>}, Module[{task, path, binding, saved, seconds, coefficients, reference, equalitySeconds, equal},
  task = tasks[[index]]; binding = Hash[{groupInputHash, index, task}, "SHA256"];
  path = FileNameJoin[{groupCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "Binding", None] === binding && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]], saved,
    {seconds, coefficients} = AbsoluteTiming[groupedMapExpression[task["Value"] /. coordinateRules, "component_" <> ToString[index]]];
    equalitySeconds = 0;
    If[index === controlIndex,
      reference = controls[index]["Record"]["Coefficients"];
      {equalitySeconds, equal} = AbsoluteTiming[coefficients === reference || bounded[
        zero[pairReconstruct[coefficients] - pairReconstruct[reference]], "entire own accepted Hgq map comparison"]];
      gate["entire own accepted Hgq map reproduced", equal]];
    saved = Join[KeyDrop[task, "Value"], <|"ComponentIndex" -> index, "Binding" -> binding,
      "Coefficients" -> coefficients, "InputHash" -> targetInputHash, "ComparisonInputHash" -> groupInputHash,
      "MissingTargets" -> Complement[Keys[coefficients], ruleKeys, reduction["Masters"]],
      "ReconstructionPassed" -> True, "Seconds" -> seconds, "EqualitySeconds" -> equalitySeconds,
      "OwnAcceptedComparison" -> (index === controlIndex), "InputBytes" -> ByteCount[task["Value"]], "Checks" -> checks|>];
    comparisonSave[saved, path]; Print["CERTIFIED_GROUP_COMPONENT ", index, " seconds ", seconds, " equality_seconds ", equalitySeconds];
    saved]]], {index, selected}];
gate["complete own-channel comparison and candidate", Lookup[comparisonComponents, "ComponentIndex"] === selected &&
  And @@ Lookup[comparisonComponents, "ReconstructionPassed"] && And @@ Flatten[Values[#["Checks"]] & /@ comparisonComponents] &&
  TrueQ[First[comparisonComponents]["OwnAcceptedComparison"]]];
gate["original reference mapping and merge unchanged", originalMappingDefinitions === DownValues[mapExpression] && originalMergeDefinitions === DownValues[merge]];
result = <|"Schema" -> "polarized-sidis-certified-denominator-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ConfigurationHash" -> FileHash[comparisonConfigPath, "SHA256"],
  "InputHashes" -> inputHashes, "TargetInputHash" -> targetInputHash, "MappingInputHash" -> inputHash,
  "InputHash" -> groupInputHash, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "GroupingCertificateHash" -> FileHash[groupCertificatePath, "SHA256"], "MergeCertificateHash" -> FileHash[mergeCertificatePath, "SHA256"],
  "ControlFiles" -> (KeyDrop[#, "Record"] & /@ controls), "ControlIndex" -> controlIndex, "SelectedIndices" -> selected,
  "OriginalMappingDefinitions" -> originalMappingDefinitions, "OriginalMergeDefinitions" -> originalMergeDefinitions,
  "GroupingDefinitions" -> DownValues[groupDenominators], "GroupingCertificateDefinitions" -> DownValues[certifyGrouping],
  "MergeCertificateDefinitions" -> DownValues[certifyPairMerge], "GroupMergeDefinitions" -> DownValues[certifyGroupMerge],
  "ReconstructionDefinitions" -> DownValues[pairReconstruct], "MappingDefinitions" -> DownValues[groupedMapExpression],
  "Components" -> comparisonComponents, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultDirectory = FileNameJoin[{root, channel, "s08_certified_denominator_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
comparisonSave[result, FileNameJoin[{resultDirectory, "s08_result.wl"}]];
Export[FileNameJoin[{resultDirectory, "s08_checks.json"}], <|"checks" -> checks,
  "components" -> selected, "measurements" -> (KeyTake[#, {"ComponentIndex", "Seconds", "EqualitySeconds", "InputBytes", "OwnAcceptedComparison"}] & /@ comparisonComponents),
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_certified_denominator_mapping"]; Quit[0];

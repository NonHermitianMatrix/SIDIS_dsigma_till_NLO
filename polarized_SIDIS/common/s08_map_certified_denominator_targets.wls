(* Own-channel certified group mapping with individual native worker packets. *)
$HistoryLength = 0;
certifiedPath = FileNameJoin[{Directory[], "common", "s08_map_certified_denominator_targets.wls"}];
certifiedBasePath = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
If[IntegerString[FileHash[certifiedBasePath, "SHA256"], 16, 64] =!=
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9", Quit[1]];
certifiedText = Import[certifiedBasePath, "Text"];
certifiedBoundary = StringPosition[certifiedText, "\nmapTargetTask[index_]"];
If[Length[certifiedBoundary] =!= 1 || !SyntaxQ[Import[certifiedPath, "Text"]], Quit[1]];
certifiedPrefix = StringTake[certifiedText, First[First[certifiedBoundary]] - 1];
If[!SyntaxQ[certifiedPrefix], Quit[1]];
ToExpression[certifiedPrefix, InputForm];
certifiedProofPath = FileNameJoin[{root, channel, "s08_certified_denominator_result", "s08_result.wl"}];
certifiedExpected = Environment["POLARIZED_SIDIS_DENOMINATOR_PROOF_SHA256"];
gate["pinned own certified mapping comparison", StringQ[certifiedExpected] &&
  IntegerString[FileHash[certifiedProofPath, "SHA256"], 16, 64] === certifiedExpected];
certifiedReceipt = Import[FileNameJoin[{DirectoryName[certifiedProofPath], "s08_execution.json"}], "RawJSON"];
gate["successful own certified comparison receipt", TrueQ[certifiedReceipt["passed"]] &&
  certifiedReceipt["result_sha256"][channel <> "/s08_certified_denominator_result/s08_result.wl"] === certifiedExpected];
certifiedProof = Get[certifiedProofPath];
certifiedSourcePath = FileNameJoin[{root, "common", "s08_check_certified_denominator_mapping.wls"}];
certifiedConfigPath = FileNameJoin[{root, "common", "s08_certified_denominator_inputs.json"}];
gate["complete accepted own certified comparison", channel === "Hgq" && certifiedProof["Channel"] === channel &&
  certifiedProof["Schema"] === "polarized-sidis-certified-denominator-comparison-v1" &&
  And @@ Values[certifiedProof["Checks"]] &&
  And @@ Lookup[certifiedProof["Components"], "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ certifiedProof["Components"]] &&
  TrueQ[First[certifiedProof["Components"]]["OwnAcceptedComparison"]] &&
  certifiedProof["SourceHash"] === FileHash[certifiedSourcePath, "SHA256"] &&
  certifiedProof["ConfigurationHash"] === FileHash[certifiedConfigPath, "SHA256"] &&
  certifiedProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["certified comparison exact production inputs", certifiedProof["InputHashes"] === inputHashes &&
  certifiedProof["TargetInputHash"] === targetInputHash && certifiedProof["MappingInputHash"] === inputHash];
gate["original reference mapping and merge unchanged", certifiedProof["OriginalMappingDefinitions"] === DownValues[mapExpression] &&
  certifiedProof["OriginalMergeDefinitions"] === DownValues[merge]];
DownValues[groupDenominators] = certifiedProof["GroupingDefinitions"];
DownValues[certifyGrouping] = certifiedProof["GroupingCertificateDefinitions"];
DownValues[certifyPairMerge] = certifiedProof["MergeCertificateDefinitions"];
DownValues[certifyGroupMerge] = certifiedProof["GroupMergeDefinitions"];
DownValues[pairReconstruct] = certifiedProof["ReconstructionDefinitions"];
DownValues[groupedMapExpression] = certifiedProof["MappingDefinitions"];
gate["all accepted mapping definitions installed", {
  DownValues[groupDenominators], DownValues[certifyGrouping], DownValues[certifyPairMerge],
  DownValues[certifyGroupMerge], DownValues[pairReconstruct], DownValues[groupedMapExpression]} ===
  Lookup[certifiedProof, {"GroupingDefinitions", "GroupingCertificateDefinitions", "MergeCertificateDefinitions",
    "GroupMergeDefinitions", "ReconstructionDefinitions", "MappingDefinitions"}]];
groupInputHash = certifiedProof["InputHash"];
groupCache = FileNameJoin[{root, "cache", "s08_certified_denominator", channel, IntegerString[groupInputHash, 16]}];
gate["accepted group checkpoint directory exists", DirectoryQ[groupCache]];
certifiedProofHash = FileHash[certifiedProofPath, "SHA256"];
certifiedComponents = Association[(#["ComponentIndex"] -> #) & /@ certifiedProof["Components"]];
gate["exact compared component inventory", Keys[certifiedComponents] === certifiedProof["SelectedIndices"]];

mapCertifiedPacket[packet_] := Catch[Block[{checks = <||>}, Module[
  {index, task, taskHash, path, saved, prior, coefficients, seconds, missing},
  {index, task, taskHash} = packet;
  gate["native worker received exact assigned task", Hash[task, "SHA256"] === taskHash];
  path = FileNameJoin[{targetCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  saved = If[FileExistsQ[path], Get[path], <||>];
  If[Lookup[saved, "InputHash", None] === targetInputHash && TrueQ[Lookup[saved, "ReconstructionPassed", False]] &&
    AssociationQ[Lookup[saved, "Checks", None]] && Length[saved["Checks"]] > 0 && And @@ Values[saved["Checks"]],
    gate["accepted canonical component exact task", KeyTake[saved, {"Sector", "Kind", "Index"}] === KeyDrop[task, "Value"]];
    Print["CERTIFIED_TARGET_REUSED_CANONICAL ", index]; Return[saved]];
  If[KeyExistsQ[certifiedComponents, index],
    prior = certifiedComponents[index];
    gate["accepted comparison component exact current task", prior["InputHash"] === targetInputHash &&
      KeyTake[prior, {"Sector", "Kind", "Index"}] === KeyDrop[task, "Value"] &&
      prior["ComparisonInputHash"] === groupInputHash && TrueQ[prior["ReconstructionPassed"]] && And @@ Values[prior["Checks"]]];
    saved = Join[prior, <|"CertifiedDenominatorProofHash" -> certifiedProofHash,
      "ReusedComparisonComponent" -> True, "Checks" -> Join[prior["Checks"], checks]|>];
    put[saved, path]; gate["reused complete component exact native reload", Get[path] === saved];
    Print["CERTIFIED_TARGET_REUSED_COMPARISON ", index]; Return[saved]];
  Print["CERTIFIED_TARGET_MAP ", index, " ", KeyDrop[task, "Value"], " kernel ", $KernelID];
  {seconds, coefficients} = AbsoluteTiming[groupedMapExpression[task["Value"] /. coordinateRules,
    "component_" <> ToString[index]]];
  missing = Complement[Keys[coefficients], ruleKeys, reduction["Masters"]];
  saved = Join[KeyDrop[task, "Value"], <|"Coefficients" -> coefficients, "MissingTargets" -> missing,
    "InputHash" -> targetInputHash, "CertifiedDenominatorProofHash" -> certifiedProofHash,
    "ReconstructionPassed" -> True, "Checks" -> checks, "Seconds" -> seconds,
    "InputBytes" -> ByteCount[task["Value"]], "OutputBytes" -> ByteCount[coefficients]|>];
  put[saved, path]; gate["complete mapped component exact native reload", Get[path] === saved];
  ClearSystemCache[]; Print["CERTIFIED_TARGET_ACCEPTED ", index, " seconds ", seconds]; saved]], "TargetMapFailure"];

certifiedTail = StringDrop[certifiedText, First[First[StringPosition[certifiedText, "\nslots ="]]]] ;
certifiedDistribution = "mapTargetTask, tasks, targetCache, targetInputHash, coordinateRules, ruleKeys, reduction,";
certifiedMap = "ParallelMap[mapTargetTask, targetRest, Method -> \"FinestGrained\"], mapTargetTask /@ targetRest";
certifiedExport = "targetResultPath = FileNameJoin[{targetDir, \"s08_result.wl\"}];";
gate["unique unchanged worker and export interfaces", StringCount[certifiedTail, certifiedDistribution] === 1 &&
  StringCount[certifiedTail, certifiedMap] === 1 && StringCount[certifiedTail, certifiedExport] === 1];
certifiedTail = StringReplace[certifiedTail, {
  certifiedDistribution -> "mapCertifiedPacket, certifiedComponents, certifiedProofHash, groupInputHash, groupCache, groupDenominators, certifyGrouping, certifyPairMerge, certifyGroupMerge, pairReconstruct, groupedMapExpression, targetCache, targetInputHash, coordinateRules, ruleKeys, reduction,",
  "targetComponents = If[workers > 0," -> "certifiedPackets = ({#, tasks[[#]], Hash[tasks[[#]], \"SHA256\"]} &) /@ targetRest;\nPrint[\"INDIVIDUAL_TARGET_PACKET_COUNT \", Length[certifiedPackets]];\ntargetComponents = If[workers > 0,",
  certifiedMap -> "ParallelMap[mapCertifiedPacket, certifiedPackets, Method -> \"FinestGrained\"], mapCertifiedPacket /@ certifiedPackets",
  certifiedExport -> ("AssociateTo[targetResult,{\"DispatchSourceHash\"->FileHash[certifiedPath,\"SHA256\"],\"CertifiedDenominatorProofHash\"->certifiedProofHash}];\n" <> certifiedExport)}];
gate["complete certified target continuation syntax", SyntaxQ[certifiedTail]];
ToExpression[certifiedTail, InputForm];

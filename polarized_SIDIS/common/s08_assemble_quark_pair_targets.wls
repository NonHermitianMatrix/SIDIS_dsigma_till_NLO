(* Assemble the accepted grouped components and the accepted reference pair maps. *)
$HistoryLength = 0;
assemblySource = FileNameJoin[{Directory[], "common", "s08_assemble_quark_pair_targets.wls"}];
assemblyBase = FileNameJoin[{Directory[], "common", "s08_map_certified_group_targets.wls"}];
If[IntegerString[FileHash[assemblyBase, "SHA256"], 16, 64] =!=
  "f38a83d6b7080e4acbd9919f05a38ce602800f445e3bd594263f18bb8e4a091c", Quit[1]];
assemblyText = Import[assemblyBase, "Text"];
If[StringCount[assemblyText, "\nmapTargetTask[index_]"] =!= 1 ||
  StringCount[assemblyText, "\ntargetInventory ="] =!= 1, Quit[1]];
assemblyPrefix = First[StringSplit[assemblyText, "\nmapTargetTask[index_]"]];
If[!SyntaxQ[assemblyPrefix] || !SyntaxQ[Import[assemblySource, "Text"]], Quit[1]];
ToExpression[assemblyPrefix, InputForm];
gate["own quark pair assembly channel", channel === "Hqqbar"];
pairProofPath = FileNameJoin[{root, channel, "s08_pair_mapping_result", "s08_result.wl"}];
pairReceiptPath = FileNameJoin[{root, channel, "s08_pair_mapping_result", "s08_execution.json"}];
pairReceipt = Import[pairReceiptPath, "RawJSON"];
gate["accepted complete pair receipt", TrueQ[pairReceipt["passed"]] &&
  pairReceipt["result_sha256"][channel <> "/s08_pair_mapping_result/s08_result.wl"] ===
    IntegerString[FileHash[pairProofPath, "SHA256"], 16, 64]];
pairProof = Get[pairProofPath];
pairSource = FileNameJoin[{root, "common", "s08_check_quark_pair_mapping.wls"}];
pairConfiguration = FileNameJoin[{root, "common", "s08_quark_pair_mapping_inputs.json"}];
gate["accepted complete own pair comparison", pairProof["Schema"] === "polarized-sidis-pair-mapping-comparison-v1" &&
  pairProof["Channel"] === channel && And @@ Values[pairProof["Checks"]] &&
  TrueQ[pairProof["Checks"]["entire own accepted control map reproduced"]] &&
  And @@ Lookup[pairProof["Components"], "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ pairProof["Components"]]];
gate["pair comparison exact source and inputs", pairProof["SourceHash"] === FileHash[pairSource, "SHA256"] &&
  pairProof["ConfigurationHash"] === FileHash[pairConfiguration, "SHA256"] &&
  pairProof["InputHashes"] === inputHashes && pairProof["TargetInputHash"] === targetInputHash &&
  pairProof["MappingInputHash"] === inputHash && pairProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["unchanged original mapping and merge equations", pairProof["OriginalMappingDefinitions"] === DownValues[mapExpression] &&
  pairProof["OriginalMergeDefinitions"] === DownValues[merge]];
proofComponents = Association[(#["ComponentIndex"] -> #) & /@ pairProof["Components"]];
gate["unique complete pair component inventory", Length[proofComponents] === Length[pairProof["Components"]] &&
  Sort[Keys[proofComponents]] === Sort[pairProof["SelectedIndices"]]];
reusedFiles = <||>;
targetComponents = Table[
  path = FileNameJoin[{targetCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  If[KeyExistsQ[proofComponents, index],
    record = Join[proofComponents[index], <|"PairMappingValidationHash" -> FileHash[pairProofPath, "SHA256"]|>],
    gate["accepted grouped component exists " <> ToString[index], FileExistsQ[path]];
    record = Get[path]; AssociateTo[reusedFiles, StringDrop[path, StringLength[root] + 1] -> FileHash[path, "SHA256"]]];
  gate["exact accepted component binding " <> ToString[index], record["InputHash"] === targetInputHash &&
    KeyTake[record, {"Sector", "Kind", "Index"}] === KeyDrop[tasks[[index]], "Value"] &&
    TrueQ[record["ReconstructionPassed"]] && AssociationQ[record["Checks"]] && Length[record["Checks"]] > 0 && And @@ Values[record["Checks"]]];
  gate["recorded component reduction coverage " <> ToString[index], record["MissingTargets"] ===
    Complement[Keys[record["Coefficients"]], ruleKeys, reduction["Masters"]]];
  record, {index, Length[tasks]}];
gate["every actual target component accepted", Length[targetComponents] === Length[tasks] && AllTrue[targetComponents, AssociationQ]];
targetSourceHash = FileHash[assemblySource, "SHA256"]; workers = 0;
assemblyTail = StringDrop[assemblyText, First[First[StringPosition[assemblyText, "\ntargetInventory ="]]] - 1];
assemblyMetadata = "\"SourceHash\" -> targetSourceHash,";
gate["unique reference export metadata", StringCount[assemblyTail, assemblyMetadata] === 1];
assemblyTail = StringReplace[assemblyTail, {
  assemblyMetadata -> (assemblyMetadata <> " \"PairMappingValidationHash\" -> FileHash[pairProofPath, \"SHA256\"], \"PairExecutionHash\" -> FileHash[pairReceiptPath, \"SHA256\"], \"ReusedComponentFiles\" -> reusedFiles,"),
  "PASS: s08_map_certified_group_targets" -> "PASS: s08_assemble_quark_pair_targets"}];
gate["complete unchanged grouped target export syntax", SyntaxQ[assemblyTail]];
ToExpression[assemblyTail, InputForm];

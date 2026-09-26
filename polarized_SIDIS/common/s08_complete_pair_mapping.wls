(* Complete the original pair-map export with accepted component reconstructions. *)
$HistoryLength = 0;
completionPath = FileNameJoin[{Directory[], "common", "s08_complete_pair_mapping.wls"}];
completionConfigPath = FileNameJoin[{Directory[], "common", "s08_pair_completion_inputs.json"}];
completionBase = FileNameJoin[{Directory[], "common", "s08_check_quark_pair_mapping.wls"}];
If[IntegerString[FileHash[completionBase, "SHA256"], 16, 64] =!=
  "890b96aead1f5c9de58b6cc6b8f1bac8d28eabcb5442b79de38da13bf8a9261a", Quit[1]];
completionText = Import[completionBase, "Text"];
If[StringCount[completionText, "\nslots ="] =!= 1 || StringCount[completionText, "\npairResult ="] =!= 1, Quit[1]];
completionPrefix = First[StringSplit[completionText, "\nslots ="]];
If[!SyntaxQ[completionPrefix], Quit[1]];
ToExpression[completionPrefix, InputForm];
gate["complete pair completion source syntax", SyntaxQ[Import[completionPath, "Text"]]];
completionConfig = Import[completionConfigPath, "RawJSON"];
gate["pair completion input schema", completionConfig["schema"] === "polarized-sidis-pair-completion-inputs-v1"];
KeyValueMap[Function[{relative, identity}, gate["pinned accepted pair component " <> relative,
  IntegerString[FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] === identity]], completionConfig["files"]];
completionProofPath = FileNameJoin[{root, channel, "s08_pair_merge_result", "s08_result.wl"}];
completionReceiptPath = FileNameJoin[{root, channel, "s08_pair_merge_result", "s08_execution.json"}];
completionReceipt = Import[completionReceiptPath, "RawJSON"];
gate["accepted complete pair merge receipt", TrueQ[completionReceipt["passed"]] &&
  completionReceipt["result_sha256"][channel <> "/s08_pair_merge_result/s08_result.wl"] ===
    IntegerString[FileHash[completionProofPath, "SHA256"], 16, 64]];
completionProof = Get[completionProofPath];
completionProofSource = FileNameJoin[{root, "common", "s08_check_pair_merge_linearity.wls"}];
gate["accepted exact pair merge implementation", IntegerString[FileHash[completionProofSource, "SHA256"], 16, 64] ===
  "531822a5be4cf830202ca16a9cfaae1d8d7fd9b53c429cc901867da421c58f72"];
gate["accepted complete merge reconstruction comparison", completionProof["Schema"] === "polarized-sidis-pair-merge-linearity-v1" &&
  completionProof["Channel"] === channel && And @@ Values[completionProof["Checks"]] &&
  TrueQ[completionProof["Checks"]["entire own accepted pair coefficient map identical"]] &&
  And @@ Lookup[completionProof["Components"], "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ completionProof["Components"]]];
gate["exact merge comparison source and physical input identity", completionProof["SourceHash"] === FileHash[completionProofSource, "SHA256"] &&
  completionProof["ConfigurationHash"] === FileHash[FileNameJoin[{root, "common", "s08_pair_merge_inputs.json"}], "SHA256"] &&
  completionProof["PairSourceHash"] === FileHash[completionBase, "SHA256"] && completionProof["PairInputHash"] === pairStudyHash &&
  completionProof["InputHashes"] === inputHashes && completionProof["TargetInputHash"] === targetInputHash &&
  completionProof["MappingInputHash"] === inputHash && completionProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["original mapping and merge definitions retained", completionProof["OriginalMappingDefinitions"] === DownValues[mapExpression] &&
  completionProof["OriginalMergeDefinitions"] === DownValues[merge]];
completionComponents = Association[(#["ComponentIndex"] -> #) & /@ completionProof["Components"]];
gate["exact comparison component inventory", Length[completionComponents] === Length[completionProof["Components"]] &&
  Keys[completionComponents] === completionProof["SelectedIndices"] &&
  completionProof["ControlIndex"] === pairControlIndex && MemberQ[Keys[completionComponents], pairControlIndex] &&
  Complement[Keys[completionComponents], pairSelected] === {}];
pairComponents = Table[
  componentPath = FileNameJoin[{pairCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  componentRelative = StringDrop[componentPath, StringLength[root] + 1];
  If[KeyExistsQ[completionConfig["files"], componentRelative],
    component = Get[componentPath];
    If[KeyExistsQ[completionComponents, index], gate["entire own accepted control map reproduced",
      component["Coefficients"] === completionComponents[index]["Coefficients"]]],
    gate["missing original component supplied by accepted comparison", KeyExistsQ[completionComponents, index]];
    component = completionComponents[index];
    gate["component exact accepted merge binding", component["MergeInputHash"] === completionProof["InputHash"]];
    AssociateTo[component, "MergeComparisonHash" -> FileHash[completionProofPath, "SHA256"]]];
  gate["exact complete component binding " <> ToString[index], component["ComponentIndex"] === index &&
    component["InputHash"] === targetInputHash && component["StudyInputHash"] === pairStudyHash &&
    KeyTake[component, {"Sector", "Kind", "Index"}] === KeyDrop[tasks[[index]], "Value"] &&
    TrueQ[component["ReconstructionPassed"]] && AssociationQ[component["Checks"]] && Length[component["Checks"]] > 0 &&
    And @@ Values[component["Checks"]]];
  gate["recorded pair component reduction coverage " <> ToString[index], component["MissingTargets"] ===
    Complement[Keys[component["Coefficients"]], ruleKeys, reduction["Masters"]]];
  gate["pair component physical cut powers retained " <> ToString[index], And @@
    (Take[#[[2]], 2] === ConstantArray[1, Length[geometry["CutMomenta"]]] & /@ Keys[component["Coefficients"]])];
  component, {index, pairSelected}];
gate["complete original selected pair inventory", Lookup[pairComponents, "ComponentIndex"] === pairSelected && DuplicateFreeQ[pairSelected]];
gate["accepted control included in original file inventory", KeyExistsQ[completionConfig["files"],
  StringDrop[FileNameJoin[{pairCache, "component_" <> IntegerString[pairControlIndex, 10, 4] <> ".wl"}], StringLength[root] + 1]]];
workers = 0;
completionTail = "pairResult =" <> Last[StringSplit[completionText, "\npairResult ="]];
completionBoundary = "pairResultDir = FileNameJoin";
gate["unique original pair export metadata boundary", StringCount[completionTail, completionBoundary] === 1];
completionTail = StringReplace[completionTail, completionBoundary ->
  ("AssociateTo[pairResult, {\"DispatchSourceHash\" -> FileHash[completionPath, \"SHA256\"], \"MergeComparisonHash\" -> FileHash[completionProofPath, \"SHA256\"], \"MergeExecutionHash\" -> FileHash[completionReceiptPath, \"SHA256\"], \"CompletionConfigurationHash\" -> FileHash[completionConfigPath, \"SHA256\"], \"ReusedComponentFiles\" -> completionConfig[\"files\"]}];\n" <> completionBoundary)];
completionTail = StringReplace[completionTail, "PASS: s08_check_quark_pair_mapping" -> "PASS: s08_complete_pair_mapping"];
gate["complete original pair export syntax", SyntaxQ[completionTail]];
ToExpression[completionTail, InputForm];

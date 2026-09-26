(* Assemble accepted reference maps and the accepted per-pair continuation. *)
$HistoryLength = 0;
assemblySource = FileNameJoin[{Directory[], "common", "s08_assemble_verified_targets.wls"}];
assemblyBase = FileNameJoin[{Directory[], "common", "s08_map_real_targets.wls"}];
If[IntegerString[FileHash[assemblyBase, "SHA256"], 16, 64] =!=
  "8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9", Print["FAIL: pinned target mapper"]; Quit[1]];
assemblyText = Import[assemblyBase, "Text"];
assemblyBoundary = StringPosition[assemblyText, "\nmapTargetTask[index_]"];
If[Length[assemblyBoundary] =!= 1, Print["FAIL: unique target initialization"]; Quit[1]];
assemblyPrefix = StringTake[assemblyText, First[First[assemblyBoundary]] - 1];
If[!SyntaxQ[assemblyPrefix], Print["FAIL: target initialization syntax"]; Quit[1]];
ToExpression[assemblyPrefix, InputForm];
gate["complete verified assembly syntax", SyntaxQ[Import[assemblySource, "Text"]]];
gate["accepted pair comparison channel", channel === "Hqqprime"];
pairProofPath = FileNameJoin[{root, channel, "s08_pair_mapping_result", "s08_result.wl"}];
gate["pinned complete pair mapping proof", IntegerString[FileHash[pairProofPath, "SHA256"], 16, 64] ===
  "a97381483fd34c34ad3046929efa64716bc1c84cc7edb3649d02662cdf3c278c"];
pairProof = Get[pairProofPath];
gate["accepted complete pair mapping comparison", pairProof["Schema"] === "polarized-sidis-pair-mapping-comparison-v1" &&
  pairProof["Channel"] === channel && And @@ Values[pairProof["Checks"]] &&
  TrueQ[pairProof["Checks"]["entire own accepted control map reproduced"]] &&
  And @@ Lookup[pairProof["Components"], "ReconstructionPassed"] &&
  And @@ Flatten[Values[#["Checks"]] & /@ pairProof["Components"]]];
gate["pair mapping exact source and inputs", pairProof["SourceHash"] ===
  FileHash[FileNameJoin[{root, "common", "s08_check_pair_mapping.wls"}], "SHA256"] &&
  pairProof["InputHashes"] === inputHashes && pairProof["TargetInputHash"] === targetInputHash &&
  pairProof["MappingInputHash"] === inputHash && pairProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
gate["unchanged original mapping and merge equations", pairProof["OriginalMappingDefinitions"] === DownValues[mapExpression] &&
  pairProof["OriginalMergeDefinitions"] === DownValues[merge]];
proofComponents = Association[(#["ComponentIndex"] -> #) & /@ pairProof["Components"]];
reusedFiles = <||>;
targetComponents = Table[
  path = FileNameJoin[{targetCache, "component_" <> IntegerString[index, 10, 4] <> ".wl"}];
  If[KeyExistsQ[proofComponents, index],
    record = Join[proofComponents[index], <|"PairMappingValidationHash" -> FileHash[pairProofPath, "SHA256"]|>],
    gate["accepted original component exists " <> ToString[index], FileExistsQ[path]];
    record = Get[path]; AssociateTo[reusedFiles, StringDrop[path, StringLength[root] + 1] -> FileHash[path, "SHA256"]]];
  gate["exact accepted component binding " <> ToString[index], record["InputHash"] === targetInputHash &&
    KeyTake[record, {"Sector", "Kind", "Index"}] === KeyDrop[tasks[[index]], "Value"] &&
    TrueQ[record["ReconstructionPassed"]] && AssociationQ[record["Checks"]] && Length[record["Checks"]] > 0 && And @@ Values[record["Checks"]]];
  gate["recorded component reduction coverage " <> ToString[index], record["MissingTargets"] ===
    Complement[Keys[record["Coefficients"]], ruleKeys, reduction["Masters"]]];
  record, {index, Length[tasks]}];
gate["every actual target component accepted", Length[targetComponents] === Length[tasks] && AllTrue[targetComponents, AssociationQ]];
targetSourceHash = FileHash[assemblySource, "SHA256"]; workers = 0;
assemblyTail = StringDrop[assemblyText, First[First[StringPosition[assemblyText, "targetInventory ="]]] - 1];
assemblyTail = StringReplace[assemblyTail, {
  "\"SourceHash\" -> targetSourceHash," -> "\"SourceHash\" -> targetSourceHash, \"PairMappingValidationHash\" -> FileHash[pairProofPath, \"SHA256\"], \"ReusedComponentFiles\" -> reusedFiles,",
  "PASS: s08_map_real_targets" -> "PASS: s08_assemble_verified_targets"}];
gate["complete unchanged target export syntax", SyntaxQ[assemblyTail]];
ToExpression[assemblyTail, InputForm];

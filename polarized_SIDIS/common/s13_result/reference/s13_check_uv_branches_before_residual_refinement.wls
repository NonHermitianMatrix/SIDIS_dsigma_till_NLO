(* Check physical-domain simplification on the exported failed UV equation. *)
$HistoryLength = 0;
root = Directory[]; checks = <||>;
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name]; AssociateTo[checks, name -> True], Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
source = FileNameJoin[{root, "common", "s13_check_uv_branches.wls"}];
baseline = FileNameJoin[{root, "common", "s13_assemble_virtual_spin.wls"}];
inspectionPath = FileNameJoin[{root, "Hqg", "s13_uv_inspection_result", "s13_result.wl"}];
gate["complete source syntax", SyntaxQ[Import[source, "Text"]]];
gate["pinned production source", IntegerString[FileHash[baseline, "SHA256"], 16, 64] === "44bc4684e7aa164e7d9e0928bb2572c7f7ea146e8215653516fef6bf1e729989"];
gate["pinned actual failed equation", IntegerString[FileHash[inspectionPath, "SHA256"], 16, 64] === "91c455e0a0e7e246a37d3ecb526dc3e2d172e5f179692f7f61b125b95a37cca5"];
inspection = Get[inspectionPath]; terms = inspection["Terms"];
gate["accepted inspection", TrueQ[inspection["InspectionComplete"]] && And @@ Values[inspection["Checks"]]];
physicalLine = Select[StringSplit[Import[baseline, "Text"], "\n"], StringStartsQ[#, "physical = "] &];
gate["unique inherited physical assumptions", Length[physicalLine] === 1];
ToExpression[First[physicalLine], InputForm];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 300, gate["time bound " <> label, False]], 2*1024^3, gate["memory bound " <> label, False]];
physicalUVHermitian[value_] := Factor[Refine[value + Conjugate[value], physical]];
{seconds, candidate} = AbsoluteTiming[bounded[physicalUVHermitian[terms["PreHermitianUV"]], "physical Hermitian residue"]];
Print["ACTUAL_CANDIDATE ", InputForm[candidate]];
candidateResidual = bounded[FullSimplify[Factor[Together[candidate + terms["ExternalUV"] + terms["CountertermUV"]]] /. eps -> 0, physical, TimeConstraint -> 120], "candidate UV residual"];
Print["ACTUAL_CANDIDATE_RESIDUAL ", InputForm[candidateResidual]];
originalResidual = bounded[FullSimplify[Refine[terms["FactoredResidual"], physical], physical, TimeConstraint -> 120], "original UV residual"];
Print["ACTUAL_ORIGINAL_RESIDUAL ", InputForm[originalResidual]];
gate["actual counterterms cancel candidate residue", candidateResidual === 0];
gate["original residual is zero on physical domain", originalResidual === 0];
definitionResidual = bounded[FullSimplify[candidate - (terms["PreHermitianUV"] + Conjugate[terms["PreHermitianUV"]]), physical, TimeConstraint -> 120], "Hermitian definition"];
gate["exact defining Hermitian sum", definitionResidual === 0];
result = <|"Schema" -> "polarized-sidis-uv-branch-comparison-v1", "Channel" -> "Hqg", "Key" -> inspection["Key"],
 "OriginalResidual" -> terms["Residual"], "RefinedOriginalResidual" -> originalResidual,
 "CandidateHermitianUV" -> candidate, "CandidateResidual" -> candidateResidual, "DefinitionResidual" -> definitionResidual,
 "Definitions" -> DownValues[physicalUVHermitian], "PhysicalConditions" -> physical, "ElapsedSeconds" -> seconds,
 "SourceHash" -> FileHash[source, "SHA256"], "BaselineSourceHash" -> FileHash[baseline, "SHA256"],
 "InspectionHash" -> FileHash[inspectionPath, "SHA256"], "InputHashes" -> inspection["InputHashes"],
 "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
directory = FileNameJoin[{root, "Hqg", "s13_branch_result"}];
If[!DirectoryQ[directory], CreateDirectory[directory, CreateIntermediateDirectories -> True]];
path = FileNameJoin[{directory, "s13_result.wl"}]; Put[result, path];
gate["exact native reload", Get[path] === result];
Export[FileNameJoin[{directory, "s13_checks.json"}], <|"checks" -> checks, "job_id" -> Environment["JOB_ID"], "accepted" -> True|>, "RawJSON"];
Print["PASS: s13_check_uv_branches"]; Quit[0];

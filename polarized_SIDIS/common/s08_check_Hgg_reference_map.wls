(* Compare the production external-factor map with the exact fresh-worker fixture. *)
$HistoryLength=0;
referenceSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_reference_map.wls"}];
referenceSetupPath=FileNameJoin[{Directory[],"common","s08_check_external_factor_mapping.wls"}];
If[IntegerString[FileHash[referenceSetupPath,"SHA256"],16,64]=!=
 "4c1c87e30ee55bc5aa61067dd081bb2646449bcddcb93590d6423e9e3a9f6407",Quit[1]];
referenceSetupText=Import[referenceSetupPath,"Text"];
referenceBoundary=StringPosition[referenceSetupText,"\nPrint[\"EXTERNAL_FACTOR_ORIGINAL_ACTUAL_START\"];"];
If[Length[referenceBoundary]=!=1,Quit[1]];
referenceSetup=StringTake[referenceSetupText,First[First[referenceBoundary]]-1];
If[!SyntaxQ[referenceSetup]||!SyntaxQ[Import[referenceSource,"Text"]],Quit[1]];
ToExpression[referenceSetup,InputForm];
referenceProofRelative="Hgg/s08_external_factor_result/s08_result.wl";
referenceProofPath=FileNameJoin[{root,referenceProofRelative}];
referenceReceiptPath=FileNameJoin[{DirectoryName[referenceProofPath],"s08_execution.json"}];
referenceReceipt=Import[referenceReceiptPath,"RawJSON"];
gate["accepted external-factor comparison receipt",TrueQ[referenceReceipt["passed"]]&&
 referenceReceipt["result_sha256"][referenceProofRelative]===IntegerString[FileHash[referenceProofPath,"SHA256"],16,64]];
referenceProof=Get[referenceProofPath];
gate["identical accepted scalar and external-factor definitions",
 referenceProof["SourceHash"]===FileHash[referenceSetupPath,"SHA256"]&&
 referenceProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 referenceProof["InputHashes"]===record["InputHashes"]&&referenceProof["TargetInputHash"]===record["TargetInputHash"]&&
 TrueQ[referenceProof["OwnAcceptedComparison"]]&&TrueQ[referenceProof["ActualAcceptedComparison"]]&&
 And@@Values[referenceProof["Checks"]]&&
 {DownValues[mapExpression],DownValues[familyRows],DownValues[merge],DownValues[externalSplit],DownValues[externalFactorMap],DownValues[externalAtomCompatible]}===
 Lookup[referenceProof,{"OriginalMappingDefinitions","FamilyDefinitions","MergeDefinitions","SplitDefinitions","FactorMappingDefinitions","CompatibilityDefinitions"}]];
referenceConfigPath=FileNameJoin[{root,"common","s08_rational_sum_inputs.json"}];
referenceConfig=Import[referenceConfigPath,"RawJSON"];
referenceFixturePath=FileNameJoin[{root,referenceConfig["raw_map"]}];
gate["exact failed fresh-worker fixture",IntegerString[FileHash[referenceFixturePath,"SHA256"],16,64]===referenceConfig["raw_map_sha256"]];
referenceFixture=Get[referenceFixturePath];
referenceSpinRelative="Hqqprime/s05_result/s05_result.wl";
referenceSpinPath=FileNameJoin[{root,referenceSpinRelative}];
gate["exact fresh-worker control tensor",IntegerString[FileHash[referenceSpinPath,"SHA256"],16,64]===
 "07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f"];
referenceSpin=Get[referenceSpinPath];referenceTask=referenceFixture["Task"];
referenceInputs=KeyDrop[record["InputHashes"],"Hgg/s05_result/s05_result.wl"];
AssociateTo[referenceInputs,referenceSpinRelative->FileHash[referenceSpinPath,"SHA256"]];
referenceFixtureHash=Hash[{FileHash[FileNameJoin[{root,referenceConfig["raw_profile_source"]}],"SHA256"],
 Association[Map[If[First[#]==="Hgg/s05_result/s05_result.wl",referenceSpinRelative->FileHash[referenceSpinPath,"SHA256"],#]&,Normal[record["InputHashes"]]]],
 FileHash[FileNameJoin[{root,"common","s05_result","reference","s05_real_spin_response_before_parallel_spin_checks.wls"}],"SHA256"],
 $Version,FeynCalc`$FeynCalcVersion},"SHA256"];
gate["reference fixture complete source and input identity",referenceFixture["InputHash"]===referenceFixtureHash&&
 And@@Values[referenceFixture["MappingChecks"]]&&And@@Values[referenceSpin["Checks"]]];
referenceExpression=Extract[referenceSpin["Sectors"][referenceTask["Sector"]][referenceTask["Kind"]],referenceTask["Index"]]/.record["CoordinateRules"];
Print["REFERENCE_TASK ",InputForm[referenceTask]];
Print["REFERENCE_INPUT_EQUATION ",InputForm[referenceExpression]];
{referenceOriginalSeconds,referenceOriginal}=AbsoluteTiming[bounded[mapExpression[referenceExpression],"complete original reference map"]];
gate["original scalar map reproduces complete fixture",Sort[Keys[referenceOriginal]]===Sort[Keys[referenceFixture["Coefficients"]]]&&
 And@@KeyValueMap[zero[#2-referenceFixture["Coefficients"][#1]]&,referenceOriginal]];
DownValues[externalOriginalMap]=referenceProof["OriginalAliasDefinitions"];
DownValues[mapExpression]=referenceProof["MappingDefinitions"];
gate["exact production external-factor definitions",DownValues[externalOriginalMap]===referenceProof["OriginalAliasDefinitions"]&&
 DownValues[mapExpression]===referenceProof["MappingDefinitions"]&&externalVariables===referenceProof["Variables"]];
{referenceCandidateSeconds,referenceCandidate}=AbsoluteTiming[bounded[mapExpression[referenceExpression],"complete external-factor reference map"]];
referenceSameKeys=Sort[Keys[referenceCandidate]]===Sort[Keys[referenceFixture["Coefficients"]]];
referenceDifferences=If[referenceSameKeys,Association@KeyValueMap[#1->bounded[Factor[Together[#2-referenceFixture["Coefficients"][#1]]],{"reference coefficient",#1}]&,referenceCandidate],<||>];
referenceExact=referenceSameKeys&&AllTrue[Values[referenceDifferences],#===0&];
referenceReport=<|"Schema"->"polarized-sidis-reference-map-comparison-v1","Channel"->channel,
 "SourceHash"->FileHash[referenceSource,"SHA256"],"SetupSourceHash"->FileHash[referenceSetupPath,"SHA256"],
 "ProofHash"->FileHash[referenceProofPath,"SHA256"],"ProofReceiptHash"->FileHash[referenceReceiptPath,"SHA256"],
 "FixtureHash"->FileHash[referenceFixturePath,"SHA256"],"ControlTensorHash"->FileHash[referenceSpinPath,"SHA256"],
 "Task"->referenceTask,"Expression"->referenceExpression,"ReferenceCoefficients"->referenceFixture["Coefficients"],
 "OriginalCoefficients"->referenceOriginal,"CandidateCoefficients"->referenceCandidate,"Differences"->referenceDifferences,
 "SameQ"->(referenceCandidate===referenceFixture["Coefficients"]),"SameKeys"->referenceSameKeys,"ExactEquality"->referenceExact,
 "OriginalSeconds"->referenceOriginalSeconds,"CandidateSeconds"->referenceCandidateSeconds,
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
referenceDirectory=FileNameJoin[{root,"Hgg","s08_reference_map_comparison_result"}];
If[!DirectoryQ[referenceDirectory],CreateDirectory[referenceDirectory]];
saveNative[referenceReport,FileNameJoin[{referenceDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{referenceDirectory,"s08_checks.json"}],<|"checks"->checks,
 "same_expression_form"->referenceReport["SameQ"],"same_integral_keys"->referenceSameKeys,"exact_equality"->referenceExact,
 "coefficient_count"->Length[referenceCandidate],"nonzero_difference_count"->Count[Values[referenceDifferences],Except[0]],
 "original_seconds"->referenceOriginalSeconds,"candidate_seconds"->referenceCandidateSeconds|>,"RawJSON"];
Print["REFERENCE_COMPARISON ",InputForm[KeyTake[referenceReport,{"SameQ","SameKeys","ExactEquality","OriginalSeconds","CandidateSeconds"}]]];
Print["REFERENCE_DIFFERENCES ",InputForm[Select[referenceDifferences,#=!=0&]]];
gate["every complete reference coefficient agrees exactly",referenceExact];
Print["PASS: s08_check_Hgg_reference_map"];Quit[0];

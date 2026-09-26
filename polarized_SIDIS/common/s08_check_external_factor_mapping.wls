(* Keep exact loop-independent factors outside the accepted scalar map. *)
$HistoryLength=0;
externalSource=FileNameJoin[{Directory[],"common","s08_check_external_factor_mapping.wls"}];
externalBase=FileNameJoin[{Directory[],"common","s08_check_family_input_normalization.wls"}];
If[!SyntaxQ[Import[externalSource,"Text"]]||IntegerString[FileHash[externalBase,"SHA256"],16,64]=!=
 "3d0825c8616d4cd34bab275f572288748c18f6b1a17efef97cc538f615e4bc83",Quit[1]];
externalBaseText=Import[externalBase,"Text"];
externalBoundary=StringPosition[externalBaseText,"\nnormalizationOriginalMap="];
If[Length[externalBoundary]=!=1,Quit[1]];
externalSetup=StringTake[externalBaseText,First[First[externalBoundary]]-1];
If[!SyntaxQ[externalSetup],Quit[1]];ToExpression[externalSetup,InputForm];
externalOriginalDefinitions=DownValues[mapExpression];
externalOriginalFamily=DownValues[familyRows];
externalOriginalMerge=DownValues[merge];
externalInitialDecompose=DownValues[decompose];
externalVariables=First/@families[First[familyNames]]["UncutCoordinateRules"];
gate["external-factor variables match actual atom coordinates",externalVariables===atomVariables];
externalEvidence={};
externalFallbackCount=0;
externalAtomCompatible[expression_]:=Catch[Block[{gate},
 gate[_,test_]:=If[TrueQ[test],True,Throw[False,"ExternalFactorIncompatible"]];
 TrueQ[factoredAtomCertificate[expression,extractAtoms[expression]]]],"ExternalFactorIncompatible"];
externalSplit[expression_]:=Module[{factors,selected,remaining,factor,core},
 factors=If[Head[expression]===Times,List@@expression,{expression}];
 selected=Select[factors,FreeQ[#,Alternatives@@externalVariables]&];
 remaining=Select[factors,!FreeQ[#,Alternatives@@externalVariables]&];
 factor=Times@@selected;core=Times@@remaining;
 gate["exact external factor reconstructs the whole input",factor core===expression];
 gate["external factor has no loop coordinate",FreeQ[factor,Alternatives@@externalVariables]];
 {factor,core}];
externalFactorMap[expression_]:=Module[{factor,core,rows,scaled},
 If[expression===0,Return[externalOriginalMap[expression]]];
 {factor,core}=externalSplit[expression];
 If[factor===1,Return[externalOriginalMap[expression]]];
 If[!TrueQ[externalAtomCompatible[core]],externalFallbackCount++;
  Print["EXTERNAL_FACTOR_ORIGINAL_FALLBACK ",Hash[expression,"SHA256"]];
  Return[externalOriginalMap[expression]]];
 AppendTo[externalEvidence,<|"ExpressionHash"->Hash[expression,"SHA256"],
  "CoreHash"->Hash[core,"SHA256"],"Factor"->factor,"InputBytes"->ByteCount[expression],
  "CoreBytes"->ByteCount[core]|>];
 Print["EXTERNAL_FACTOR_INPUT ",InputForm[factor]];
 rows=externalOriginalMap[core];scaled=Map[factor #&,rows];
 gate["external factor preserves the complete cut inventory",Keys[scaled]===Keys[rows]];
 scaled];

Print["EXTERNAL_FACTOR_ORIGINAL_ACTUAL_START"];
ClearSystemCache[];
{externalOriginalSeconds,externalOriginalActual}=AbsoluteTiming[
 bounded[mapExpression[certificateGroupValue],"original complete production group"]];
gate["fresh original actual map reproduces its accepted packet",
 Sort[Keys[externalOriginalActual]]===Sort[Keys[certificateGroupReference["Coefficients"]]]&&
 And@@KeyValueMap[(#2===certificateGroupReference["Coefficients"][#1]||
  zero[#2-certificateGroupReference["Coefficients"][#1]])&,externalOriginalActual]];
Print["EXTERNAL_FACTOR_ORIGINAL_ACTUAL_SECONDS ",externalOriginalSeconds];
DownValues[decompose]=externalInitialDecompose;
DownValues[externalOriginalMap]=externalOriginalDefinitions/.mapExpression->externalOriginalMap;
gate["complete original scalar map retained",
 (DownValues[externalOriginalMap]/.externalOriginalMap->mapExpression)===externalOriginalDefinitions];
mapExpression[expression_]:=externalFactorMap[expression];
gate["family and merge implementations unchanged",
 DownValues[familyRows]===externalOriginalFamily&&DownValues[merge]===externalOriginalMerge];
ClearSystemCache[];
Print["EXTERNAL_FACTOR_CANDIDATE_ACTUAL_START"];
{externalCandidateSeconds,externalCandidateActual}=AbsoluteTiming[
 bounded[mapExpression[certificateGroupValue],"factored complete production group"]];
gate["every complete actual coefficient equals the original",
 Sort[Keys[externalCandidateActual]]===Sort[Keys[externalOriginalActual]]&&
 And@@KeyValueMap[(#2===externalOriginalActual[#1]||zero[#2-externalOriginalActual[#1]])&,externalCandidateActual]];
Print["EXTERNAL_FACTOR_CANDIDATE_ACTUAL_SECONDS ",externalCandidateSeconds];

certificateTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
gate["complete own original input inventory",Total[certificateTerms]===record["Expression"]];
externalOwnPackets=MapIndexed[Function[{term,index},Block[{checks=<||>},Module[{seconds,coefficients},
 Print["EXTERNAL_FACTOR_OWN_START ",First[index],"/",Length[certificateTerms]];
 {seconds,coefficients}=AbsoluteTiming[bounded[mapExpression[term],{"own factored term",First[index]}]];
 Print["EXTERNAL_FACTOR_OWN_DONE ",First[index]," seconds ",seconds];
 <|"Index"->First[index],"Coefficients"->coefficients,"Seconds"->seconds,
  "Checks"->checks,"Accepted"->True|>]]],certificateTerms];
gate["every complete own term mapped",Lookup[externalOwnPackets,"Index"]===Range[Length[certificateTerms]]&&
 And@@Lookup[externalOwnPackets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@externalOwnPackets]];
{externalOwnMergeSeconds,externalOwnCoefficients}=AbsoluteTiming[
 bounded[merge[Lookup[externalOwnPackets,"Coefficients"]],"complete own factored merge"]];
gate["complete own factored merge reconstructs",certifyGroupMerge[externalOwnPackets,externalOwnCoefficients]];
gate["entire independently accepted own Hgg map reproduced",
 Sort[Keys[externalOwnCoefficients]]===Sort[Keys[certificateOwn["Coefficients"]]]&&
 And@@KeyValueMap[(#2===certificateOwn["Coefficients"][#1]||
  zero[#2-certificateOwn["Coefficients"][#1]])&,externalOwnCoefficients]];
externalResult=<|"Schema"->"polarized-sidis-external-factor-map-comparison-v1","Channel"->channel,
 "SourceHash"->FileHash[externalSource,"SHA256"],"SetupSourceHash"->FileHash[externalBase,"SHA256"],
 "ProofHash"->FileHash[normalizationProofPath,"SHA256"],"ProofReceiptHash"->FileHash[normalizationReceiptPath,"SHA256"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeInputHash"->FileHash[inputPath,"SHA256"],"NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],
 "ActualGroupFile"->StringDrop[certificateGroupPath,StringLength[root]+1],
 "ActualGroupHash"->FileHash[certificateGroupPath,"SHA256"],"ActualGroupBinding"->certificateGroupReference["Binding"],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"OriginalMappingDefinitions"->externalOriginalDefinitions,
 "FamilyDefinitions"->externalOriginalFamily,"MergeDefinitions"->externalOriginalMerge,
 "Variables"->externalVariables,"SplitDefinitions"->DownValues[externalSplit],
 "CompatibilityDefinitions"->DownValues[externalAtomCompatible],"OriginalFallbackCount"->externalFallbackCount,
 "FactorMappingDefinitions"->DownValues[externalFactorMap],"MappingDefinitions"->DownValues[mapExpression],
 "OriginalAliasDefinitions"->DownValues[externalOriginalMap],"FactorEvidence"->externalEvidence,
 "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
 "OwnCoefficients"->externalOwnCoefficients,"ActualCoefficients"->externalCandidateActual,
 "OriginalActualSeconds"->externalOriginalSeconds,"CandidateActualSeconds"->externalCandidateSeconds,
 "OwnMappingSeconds"->Total[Lookup[externalOwnPackets,"Seconds"]],"OwnMergeSeconds"->externalOwnMergeSeconds,
 "SpeedupObserved"->TrueQ[externalCandidateSeconds<externalOriginalSeconds],
 "PeakKernelMemoryBytes"->MaxMemoryUsed[],"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
externalDirectory=FileNameJoin[{root,channel,"s08_external_factor_result"}];
If[!DirectoryQ[externalDirectory],CreateDirectory[externalDirectory]];
saveNative[externalResult,FileNameJoin[{externalDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{externalDirectory,"s08_checks.json"}],<|"checks"->checks,
 "original_actual_seconds"->externalOriginalSeconds,"candidate_actual_seconds"->externalCandidateSeconds,
 "candidate_own_seconds"->externalResult["OwnMappingSeconds"],"candidate_own_merge_seconds"->externalOwnMergeSeconds,
 "factor_cases"->Length[externalEvidence],"speedup_observed"->externalResult["SpeedupObserved"],
 "original_fallback_count"->externalFallbackCount,
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_check_external_factor_mapping"];Quit[0];

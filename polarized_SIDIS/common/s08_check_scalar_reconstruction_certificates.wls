(* Reuse exact atom and merge certificates without expanding the complete spin numerator. *)
$HistoryLength=0;
certificateSource=FileNameJoin[{Directory[],"common","s08_check_scalar_reconstruction_certificates.wls"}];
certificateBootstrapPath=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
If[!SyntaxQ[Import[certificateSource,"Text"]]||IntegerString[FileHash[certificateBootstrapPath,"SHA256"],16,64]=!=
 "1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
certificateBootstrapText=Import[certificateBootstrapPath,"Text"];
certificateBoundary=StringPosition[certificateBootstrapText,"\nIf[channel===\"Hgg\","];
If[Length[certificateBoundary]=!=1,Quit[1]];
certificateBootstrap=StringTake[certificateBootstrapText,First[First[certificateBoundary]]-1];
If[!SyntaxQ[certificateBootstrap],Quit[1]];ToExpression[certificateBootstrap,InputForm];
gate["own Hgg scalar reconstruction comparison",channel==="Hgg"];
certificateOriginalFamily=DownValues[familyRows];certificateOriginalMap=DownValues[mapExpression];
certificateOriginalMerge=DownValues[merge];
certificateAtomRelative="Hgg/s08_factored_atom_certificate_result/s08_result.wl";
certificateAtomPath=FileNameJoin[{root,certificateAtomRelative}];
certificateAtomReceiptPath=FileNameJoin[{DirectoryName[certificateAtomPath],"s08_execution.json"}];
certificateAtomReceipt=Import[certificateAtomReceiptPath,"RawJSON"];
gate["accepted exact atom certificates",TrueQ[certificateAtomReceipt["passed"]]&&
 certificateAtomReceipt["result_sha256"][certificateAtomRelative]===IntegerString[FileHash[certificateAtomPath,"SHA256"],16,64]];
certificateAtomProof=Get[certificateAtomPath];
gate["same complete atom mapping contract",TrueQ[certificateAtomProof["OwnAcceptedComparison"]]&&
 And@@Values[certificateAtomProof["Checks"]]&&certificateAtomProof["InputHashes"]===record["InputHashes"]&&
 certificateAtomProof["TargetInputHash"]===record["TargetInputHash"]&&
 certificateAtomProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 certificateAtomProof["OriginalExtractionDefinitions"]===DownValues[extractAtoms]&&
 certificateAtomProof["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&
 certificateAtomProof["NativeInputReceiptHash"]===FileHash[inputReceiptPath,"SHA256"]&&
 certificateAtomProof["MapperHash"]===FileHash[mapper,"SHA256"]&&
 certificateAtomProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_extract_factored_atom_certificate.wls"}],"SHA256"]];
atomVariables=certificateAtomProof["Variables"];
DownValues[factoredAtoms]=certificateAtomProof["FactoredExtractionDefinitions"];
DownValues[extractAtoms]=certificateAtomProof["DispatchDefinitions"];
DownValues[factoredAtomCertificate]=certificateAtomProof["AtomCertificateDefinitions"];

certifyFamilyLaurent[polynomial_Association,rows_Association,powers_List,constant_,family_]:=Module[
 {keys,cutCount,integrals,symbols,formalInput,formalRows,inverseRules},
 keys=Keys[polynomial];cutCount=Length[geometry["CutMomenta"]];
 gate["complete polynomial exponent inventory",DuplicateFreeQ[keys]&&
  AllTrue[keys,Length[#]===Length[polynomialVariables]&&VectorQ[#,IntegerQ[#]&&#>=0&]&]];
 gate["Laurent certificate denominator is loop independent",FreeQ[constant,Alternatives@@polynomialVariables]];
 gate["Laurent certificate coefficients are loop independent",FreeQ[Values[polynomial],Alternatives@@polynomialVariables]];
 inverseRules=Thread[polynomialVariables->families[family]["OnCutUncutPropagators"]];
 gate["family coordinates invert to original loop coordinates",And@@(
  zero[First[#]-(Last[#]/.inverseRules)]&/@families[family]["UncutCoordinateRules"])];
 integrals=CutIntegral[family,Join[ConstantArray[1,cutCount],powers-#]]&/@keys;
 gate["Laurent integral inventory is one to one",DuplicateFreeQ[integrals]&&Complement[Keys[rows],integrals]==={}];
 gate["each complete family coefficient reconstructs",And@@MapThread[
  Function[{key,integral},bounded[zero[Lookup[rows,integral,0]-polynomial[key]/constant],{"family coefficient",integral}]],
  {keys,integrals}]];
 symbols=Table[Unique["laurentCoefficient"],{Length[keys]}];
 formalInput=Total[MapThread[#1 Times@@MapThread[Power,{polynomialVariables,#2}]&,{symbols,keys}]]/
  (Times@@MapThread[Power,{polynomialVariables,powers}]);
 formalRows=Total[MapThread[#1 Times@@MapThread[Power,{polynomialVariables,-Drop[#2[[2]],cutCount]}]&,{symbols,integrals}]];
 gate["native full Laurent exponent identity",zero[formalRows-formalInput]];True];

certifyScalarReconstruction[expression_,powers_,prefactor_,decomposition_,pieces_,rows_]:=Module[
 {unitInput,unitDecomposition},
 gate["exact actual atom reconstruction",factoredAtomCertificate[expression,{powers,prefactor}]];
 unitInput=1/(Times@@MapThread[Power,{denominators,powers}]);
 unitDecomposition=Total[KeyValueMap[#2/(Times@@MapThread[Power,{denominators,List@@#1}])&,decomposition]];
 gate["complete spin-independent partial fraction identity",bounded[zero[unitDecomposition-unitInput],"unit denominator reconstruction"]];
 gate["complete family merge reconstructs coefficient by coefficient",
  certifyGroupMerge[(<|"Coefficients"->#|>&/@pieces),rows]];True];

certificateFamilySource=FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}];
certificateFamilyText=Import[certificateFamilySource,"Text"];
certificateFamilyBegin=StringPosition[certificateFamilyText,"\nfamilyRows[expression_,family_]"];
certificateFamilyEnd=StringPosition[certificateFamilyText,"\ncandidateFamilyDefinitions="];
gate["unique accepted complete family implementation",Length[certificateFamilyBegin]===1&&Length[certificateFamilyEnd]===1];
certificateFamilyOriginal=StringTake[certificateFamilyText,{First[First[certificateFamilyBegin]],First[First[certificateFamilyEnd]]-1}];
gate["complete original family implementation syntax",SyntaxQ[certificateFamilyOriginal]];
ToExpression[certificateFamilyOriginal,InputForm];
gate["exact accepted family implementation restored",DownValues[familyRows]===certificateOriginalFamily];
certificateFamilyEdits={
 "reconstruction=Total[KeyValueMap[Function[{integral,coefficient},coefficient Times@@MapThread[Power,{polynomialVariables,-Drop[integral[[2]],2]}]],rows]];"->
 "(* Complete Laurent identity is checked coefficient by coefficient below. *)",
 "zero[reconstruction-(expression/.spec[\"UncutCoordinateRules\"])]"->
 "certifyFamilyLaurent[polynomial,rows,powers,constant,family]"};
gate["unique family reconstruction substitutions",And@@(StringCount[certificateFamilyOriginal,First[#]]===1&/@certificateFamilyEdits)];
certificateFamilyCandidate=StringReplace[certificateFamilyOriginal,certificateFamilyEdits];
gate["all family coefficient algebra unchanged",SyntaxQ[certificateFamilyCandidate]&&
 StringReplace[certificateFamilyCandidate,Reverse/@certificateFamilyEdits]===certificateFamilyOriginal];
ToExpression[certificateFamilyCandidate,InputForm];
certificateMapBegin=StringPosition[mappingBlock,"\nmapExpression[expression_]"];
gate["unique complete original scalar mapping function",Length[certificateMapBegin]===1];
certificateMapOriginal=StringDrop[mappingBlock,First[First[certificateMapBegin]]-1];
gate["complete original scalar mapping syntax",SyntaxQ[certificateMapOriginal]];
ToExpression[certificateMapOriginal,InputForm];
gate["exact original scalar mapping definition restored",DownValues[mapExpression]===certificateOriginalMap];
certificateMapEdits={
 "  reconstruction = Total[KeyValueMap[Function[{integral, coefficient},\n    coefficient Times @@ MapThread[Power,\n      {families[integral[[1]]][\"OnCutUncutPropagators\"], -Drop[integral[[2]], 2]}]], rows]];"->
 "  (* The same complete identity uses the accepted atom and merge certificates. *)",
 "zero[reconstruction - expression]"->
 "certifyScalarReconstruction[expression,powers,prefactor,decomposition,pieces,rows]"};
gate["unique complete scalar reconstruction substitutions",And@@(StringCount[certificateMapOriginal,First[#]]===1&/@certificateMapEdits)];
certificateMapCandidate=StringReplace[certificateMapOriginal,certificateMapEdits];
gate["all scalar mapping algebra and cut gates unchanged",SyntaxQ[certificateMapCandidate]&&
 StringReplace[certificateMapCandidate,Reverse/@certificateMapEdits]===certificateMapOriginal];
ToExpression[certificateMapCandidate,InputForm];

certificateOwnRelative="Hgg/s08_termwise_comparison_result/s08_result.wl";
certificateOwnPath=FileNameJoin[{root,certificateOwnRelative}];
certificateOwnReceiptPath=FileNameJoin[{DirectoryName[certificateOwnPath],"s08_execution.json"}];
certificateOwnReceipt=Import[certificateOwnReceiptPath,"RawJSON"];
gate["accepted complete own original-term map",TrueQ[certificateOwnReceipt["passed"]]&&
 certificateOwnReceipt["result_sha256"][certificateOwnRelative]===IntegerString[FileHash[certificateOwnPath,"SHA256"],16,64]];
certificateOwn=Get[certificateOwnPath];
gate["identical complete own map inputs",TrueQ[certificateOwn["OwnAcceptedComparison"]]&&
 And@@Values[certificateOwn["Checks"]]&&certificateOwn["InputHash"]===record["TargetInputHash"]&&
 certificateOwn["InputHashes"]===record["InputHashes"]&&certificateOwn["NativeInputHash"]===FileHash[inputPath,"SHA256"]&&
 certificateOwn["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
certificateGroupIndex=16;
certificateActual=SelectFirst[certificateAtomProof["ActualGroups"],#["Component"]===1&];
certificateGroups=certificateActual["Groups"];
certificateGroupValue=Values[certificateGroups][[certificateGroupIndex]]/
 (Times@@MapThread[Power,{denominators,Keys[certificateGroups][[certificateGroupIndex]]}]);
certificateProductionSource=FileNameJoin[{root,"common","s08_map_Hgg_factored_inputs.wls"}];
certificateAlgorithmPath=FileNameJoin[{root,"Hgq","s08_certified_denominator_result","s08_result.wl"}];
certificateGroupHash=Hash[{FileHash[certificateProductionSource,"SHA256"],FileHash[certificateAlgorithmPath,"SHA256"],
 record["InputHashes"],record["TargetInputHash"],component,Hash[record["Expression"],"SHA256"],$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
certificateGroupPath=FileNameJoin[{root,"cache","s08_Hgg_grouped",IntegerString[certificateGroupHash,16],
 "component_1_group_"<>IntegerString[certificateGroupIndex,10,4]<>".wl"}];
certificateGroupReference=Get[certificateGroupPath];
gate["accepted exact production group checkpoint",TrueQ[certificateGroupReference["Accepted"]]&&
 And@@Values[certificateGroupReference["Checks"]]&&certificateGroupReference["Binding"]===
 Hash[{certificateGroupHash,"component_1",certificateGroupIndex,certificateGroupValue},"SHA256"]];

certificateTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
gate["complete own original input inventory",Total[certificateTerms]===record["Expression"]];
certificatePackets=MapIndexed[Function[{term,index},Block[{checks=<||>},Module[{seconds,coefficients},
 Print["CERTIFIED_SCALAR_TERM_START ",First[index],"/",Length[certificateTerms]];
 {seconds,coefficients}=AbsoluteTiming[bounded[mapExpression[term],{"own certified scalar term",First[index]}]];
 Print["CERTIFIED_SCALAR_TERM_DONE ",First[index]," seconds ",seconds];
 <|"Index"->First[index],"Coefficients"->coefficients,"Seconds"->seconds,"Checks"->checks,"Accepted"->True|>]]],certificateTerms];
gate["every own original term accepted",Lookup[certificatePackets,"Index"]===Range[Length[certificateTerms]]&&
 And@@Lookup[certificatePackets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@certificatePackets]];
{certificateMergeSeconds,certificateOwnCoefficients}=AbsoluteTiming[bounded[merge[Lookup[certificatePackets,"Coefficients"]],"complete own scalar certificate merge"]];
gate["complete own merge certificate",certifyGroupMerge[certificatePackets,certificateOwnCoefficients]];
gate["entire own accepted map unchanged",Sort[Keys[certificateOwnCoefficients]]===Sort[Keys[certificateOwn["Coefficients"]]]&&
 And@@KeyValueMap[(#2===certificateOwn["Coefficients"][#1]||zero[#2-certificateOwn["Coefficients"][#1]])&,certificateOwnCoefficients]];

Print["CERTIFIED_SCALAR_ACTUAL_START group ",certificateGroupIndex," bytes ",ByteCount[certificateGroupValue]];
{certificateActualSeconds,certificateActualCoefficients}=AbsoluteTiming[bounded[mapExpression[certificateGroupValue],"complete actual production group"]];
gate["entire accepted actual group map unchanged",Sort[Keys[certificateActualCoefficients]]===Sort[Keys[certificateGroupReference["Coefficients"]]]&&
 And@@KeyValueMap[(#2===certificateGroupReference["Coefficients"][#1]||zero[#2-certificateGroupReference["Coefficients"][#1]])&,certificateActualCoefficients]];
Print["CERTIFIED_SCALAR_ACTUAL_DONE seconds ",certificateActualSeconds," saved_seconds ",certificateGroupReference["Seconds"]];
gate["original coefficient merge unchanged",DownValues[merge]===certificateOriginalMerge];
certificateResult=<|"Schema"->"polarized-sidis-scalar-reconstruction-certificates-v1","Channel"->channel,
 "SourceHash"->FileHash[certificateSource,"SHA256"],"MapperHash"->FileHash[mapper,"SHA256"],
 "PolynomialProofHash"->FileHash[proofPath,"SHA256"],"AtomProofHash"->FileHash[certificateAtomPath,"SHA256"],
 "AtomReceiptHash"->FileHash[certificateAtomReceiptPath,"SHA256"],"OwnProofHash"->FileHash[certificateOwnPath,"SHA256"],
 "OwnReceiptHash"->FileHash[certificateOwnReceiptPath,"SHA256"],"ActualGroupFile"->StringDrop[certificateGroupPath,StringLength[root]+1],
 "ActualGroupHash"->FileHash[certificateGroupPath,"SHA256"],"ActualGroupBinding"->certificateGroupReference["Binding"],
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],"NativeInputHash"->FileHash[inputPath,"SHA256"],
 "NativeInputReceiptHash"->FileHash[inputReceiptPath,"SHA256"],"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
 "OriginalFamilyDefinitions"->certificateOriginalFamily,"OriginalMappingDefinitions"->certificateOriginalMap,
 "FamilyDefinitions"->DownValues[familyRows],"MappingDefinitions"->DownValues[mapExpression],
 "FamilyCertificateDefinitions"->DownValues[certifyFamilyLaurent],"MappingCertificateDefinitions"->DownValues[certifyScalarReconstruction],
 "OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,"OwnCoefficients"->certificateOwnCoefficients,
 "ActualCoefficients"->certificateActualCoefficients,"OwnTermEvidence"->(KeyDrop[#,"Coefficients"]&/@certificatePackets),
 "OwnMappingSeconds"->Total[Lookup[certificatePackets,"Seconds"]],"OwnMergeSeconds"->certificateMergeSeconds,
 "ActualMappingSeconds"->certificateActualSeconds,"PreviousActualSeconds"->certificateGroupReference["Seconds"],
 "Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
certificateDirectory=FileNameJoin[{root,channel,"s08_scalar_certificate_result"}];If[!DirectoryQ[certificateDirectory],CreateDirectory[certificateDirectory]];
saveNative[certificateResult,FileNameJoin[{certificateDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{certificateDirectory,"s08_checks.json"}],<|"checks"->checks,
 "own_mapping_seconds"->certificateResult["OwnMappingSeconds"],"own_merge_seconds"->certificateMergeSeconds,
 "actual_seconds"->certificateActualSeconds,"previous_actual_seconds"->certificateGroupReference["Seconds"],
 "native_peak_memory_bytes"->MaxMemoryUsed[]|>,"RawJSON"];
Print["PASS: s08_check_scalar_reconstruction_certificates"];Quit[0];

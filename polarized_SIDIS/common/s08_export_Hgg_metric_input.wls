(* Export the exact dimensional-metric input rejected by factored extraction. *)
$HistoryLength=0;
metricSource=FileNameJoin[{Directory[],"common","s08_export_Hgg_metric_input.wls"}];
metricBase=FileNameJoin[{Directory[],"common","s08_check_Hgg_additive_reconstruction.wls"}];
If[!SyntaxQ[ReadString[metricSource]]||IntegerString[FileHash[metricBase,"SHA256"],16,64]=!=
 "61071a42a311a84ebdbf30fdb33bd7b9e8d9c86c21a17172b4e1b5004ddfd221",Quit[1]];
metricText=ReadString[metricBase];metricBoundary=StringPosition[metricText,"\nadditiveTaskPositions="];
If[Length[metricBoundary]=!=1,Quit[1]];
metricPrefix=StringTake[metricText,First[First[metricBoundary]]-1];
If[!SyntaxQ[metricPrefix],Quit[1]];ToExpression[metricPrefix,InputForm];
metricPositions=Select[Range[Length[hggTaskMetadata]],hggTaskMetadata[[#]]["Kind"]==="PhotonMetricD"&];
gate["unique original dimensional metric task",Length[metricPositions]===1];
metricIndex=First[metricPositions];metricTask=hggTaskMetadata[[metricIndex]];
metricInputSource=hggTaskSources[[metricIndex]];
gate["original scalar metric payload and index",metricInputSource["Field"]==="Value"&&metricInputSource["Index"]==={}];
Print["METRIC_INPUT_READ_START ",metricIndex];
{metricReadSeconds,metricRaw}=AbsoluteTiming[hggMapRead[localSelectedTaskValue[metricIndex],"original dimensional metric task"]];
metricExpression=bounded[metricRaw/.coordinateRules,"original metric coordinate conversion"];Clear[metricRaw];ClearSystemCache[];
metricOuter=If[Head[metricExpression]===Plus,List@@metricExpression,{metricExpression}];
gate["entire original metric term inventory",Total[metricOuter]===metricExpression];
metricSplits=numericOuterFactor/@metricOuter;
gate["all original numeric-phase factors retained",And@@MapThread[Times@@#1===#2&,{metricSplits,metricOuter}]];
metricAtomTerms=Flatten[(If[Head[Last[#]]===Plus,List@@Last[#],{Last[#]}]&/@metricSplits),1];
metricFlags=PolynomialQ[Numerator[#],atomVariables]&/@metricAtomTerms;
metricBadPositions=Flatten[Position[metricFlags,False]];
gate["production explicit-polynomial rejection reproduced",Length[metricBadPositions]>0];
metricBadIndex=First[metricBadPositions];metricBadTerm=metricAtomTerms[[metricBadIndex]];
metricNumerator=Numerator[metricBadTerm];metricDenominator=Denominator[metricBadTerm];
gate["entire rejected rational term retained",metricNumerator/metricDenominator===metricBadTerm];
metricNonPolynomialPowers=DeleteDuplicates[Cases[metricNumerator,
 value:Power[base_,exponent_]/;!FreeQ[base,Alternatives@@atomVariables]&&(!IntegerQ[exponent]||exponent<0),Infinity]];
metricDirectory=FileNameJoin[{root,"Hgg","s08_metric_input_result"}];
If[!DirectoryQ[metricDirectory],CreateDirectory[metricDirectory]];
metricResult=<|"Schema"->"polarized-sidis-metric-extraction-input-v1","Channel"->channel,
 "SourceHash"->FileHash[metricSource,"SHA256"],"BaseHash"->FileHash[metricBase,"SHA256"],
 "Component"->metricIndex,"Task"->metricTask,"TaskSource"->metricInputSource,
 "Equation"->metricExpression,"AtomTerms"->metricAtomTerms,"PolynomialNumeratorFlags"->metricFlags,
 "RejectedPositions"->metricBadPositions,"RejectedTerm"->metricBadTerm,
 "NonPolynomialPowers"->metricNonPolynomialPowers,"Variables"->atomVariables,
 "Denominators"->denominators,"Families"->families,"CoordinateRules"->coordinateRules,
 "InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "NativeVersions"->importedNativeVersions,"ReadSeconds"->metricReadSeconds,
 "OriginalExtractionDefinitions"->certificateAtomProof["OriginalExtractionDefinitions"],
 "FactoredExtractionDefinitions"->DownValues[factoredAtoms],"GroupingDefinitions"->DownValues[hggOriginalGrouping],
 "OwnAcceptedEquation"->additiveShared["ActualInput"]["Equation"],
 "OwnAcceptedCoefficients"->additiveShared["FreshCoefficients"],
 "OwnProofHash"->FileHash[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}],"SHA256"],
 "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
saveNative[metricResult,FileNameJoin[{metricDirectory,"s08_result.wl"}]];
metricReadable=<|"Task"->metricTask,"RejectedTerm"->metricBadTerm,"Numerator"->metricNumerator,
 "Denominator"->metricDenominator,"NonPolynomialPowers"->metricNonPolynomialPowers,
 "Variables"->atomVariables,"Denominators"->denominators,
 "OriginalExtractionDefinitions"->metricResult["OriginalExtractionDefinitions"],
 "FactoredExtractionDefinitions"->metricResult["FactoredExtractionDefinitions"]|>;
Put[metricReadable,FileNameJoin[{metricDirectory,"s08_equations.wl"}]];
gate["complete readable metric input reload",Get[FileNameJoin[{metricDirectory,"s08_equations.wl"}]]===metricReadable];
Export[FileNameJoin[{metricDirectory,"s08_checks.json"}],<|"checks"->checks,"component"->metricIndex,
 "read_seconds"->metricReadSeconds,"equation_bytes"->ByteCount[metricExpression],
 "atom_terms"->Length[metricAtomTerms],"rejected_positions"->metricBadPositions,
 "rejected_term_bytes"->ByteCount[metricBadTerm],"non_polynomial_powers"->Length[metricNonPolynomialPowers],
 "readable_file_bytes"->FileByteCount[FileNameJoin[{metricDirectory,"s08_equations.wl"}]],
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_export_Hgg_metric_input"];Quit[0];

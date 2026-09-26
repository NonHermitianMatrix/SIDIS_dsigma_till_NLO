(* Keep the standalone recurrence and check its required residual coefficients directly. *)
$HistoryLength=0;
retainedPath=FileNameJoin[{Directory[],"common","s12_assemble_real_retained_series.wls"}];
retainedBase=FileNameJoin[{Directory[],"common","s12_assemble_real_transverse_endpoint.wls"}];
If[IntegerString[FileHash[retainedBase,"SHA256"],16,64]=!=
  "c35d4ac121e8a962a986ba07670971ed78e5ac5d6a7daae4be5fb51fb207f3c7",Quit[1]];
retainedBaseText=Import[retainedBase,"Text"];
retainedBoundary="\nreferenceSeriesTail=transverseOutputTail;\nToExpression[transverseEndpointRun,InputForm];";
If[StringCount[retainedBaseText,retainedBoundary]=!=1 || !SyntaxQ[Import[retainedPath,"Text"]],Quit[1]];
ToExpression[First[StringSplit[retainedBaseText,retainedBoundary]],InputForm];
retainedOriginalDefinitions=DownValues[checkedRationalSeries];
retainedStart="\ncheckedRationalSeries[";retainedEnd="\nordinaryMasterProduct[";
gate["unique original rational check definition",StringCount[referenceSeriesComparisonText,retainedStart]===1 &&
  StringCount[referenceSeriesComparisonText,retainedEnd]===1];
retainedDefinition=retainedStart<>First[StringSplit[Last[StringSplit[referenceSeriesComparisonText,retainedStart]],retainedEnd]];
gate["original rational check syntax",SyntaxQ[retainedDefinition]];
ToExpression[retainedDefinition,InputForm];
gate["same accepted rational check implementation",DownValues[checkedRationalSeries]===retainedOriginalDefinitions];
retainedChanges={
  "  If[!bounded[zeroCoefficient[residual], \"rational numerator zero identity\"],"->"  If[residual =!= 0,",
  "    gate[\"integer rational identity coverage\", IntegerQ[first] && IntegerQ[last]];\n    gate[\"complete truncated rational numerator reconstruction\", And @@ Table[\n      bounded[zeroCoefficient[Coefficient[residual, eps, power]], \"rational residual coefficient\"], {power, first, last}]]];"->
    "    If[IntegerQ[first] && IntegerQ[last],\n      gate[\"integer rational identity coverage\", True];\n      gate[\"complete truncated rational numerator reconstruction\", And @@ Table[\n        bounded[zeroCoefficient[Coefficient[residual, eps, power]], \"rational residual coefficient\"], {power, first, last}]],\n      gate[\"reference exact zero for empty regulator support\",\n        bounded[zeroCoefficient[residual], \"rational numerator zero identity\"]]]];",
  "first, last, seconds},"->"first, last, seconds, checkStarted=AbsoluteTime[]},",
  "  value];"->"  Print[\"RETAINED_SERIES_CHECK \",description,\" total_seconds \",AbsoluteTime[]-checkStarted,\" residual_bytes \",ByteCount[residual]];\n  value];"};
gate["unique retained-check interfaces",And@@(StringCount[retainedDefinition,First[#]]===1&/@retainedChanges)];
retainedCandidateDefinition=StringReplace[retainedDefinition,retainedChanges];
gate["unchanged recurrence and retained identities",SyntaxQ[retainedCandidateDefinition] &&
  StringReplace[retainedCandidateDefinition,Reverse/@retainedChanges]===retainedDefinition];
ToExpression[retainedCandidateDefinition,InputForm];
retainedControlPath=FileNameJoin[{cache,"component_0043.wl"}];
gate["bound own accepted ordinary control",IntegerString[FileHash[retainedControlPath,"SHA256"],16,64]===
  "124fb11cb9867052bd0229f19f9a8e869679e3f1b9119203f6781bc464f85471"];
retainedControl=Get[retainedControlPath];
gate["accepted own control input and checks",TrueQ[retainedControl["Accepted"]] &&
  retainedControl["InputHash"]===inputHash && And@@Values[retainedControl["Checks"]]];
retainedIdentity={"Sector","Kind","Index"};
retainedControlIndex=First[FirstPosition[KeyTake[#,retainedIdentity]&/@mapped["Components"],
  KeyTake[retainedControl,retainedIdentity]]];
retainedTask=mapped["Components"][[retainedControlIndex]];
retainedDirectory=FileNameJoin[{root,channel,"s12_retained_series_result"}];
If[!DirectoryQ[retainedDirectory],CreateDirectory[retainedDirectory,CreateIntermediateDirectories->True]];
retainedProofPath=FileNameJoin[{retainedDirectory,"s12_result.wl"}];
retainedBinding=Hash[{FileHash[retainedPath,"SHA256"],FileHash[retainedBase,"SHA256"],
  FileHash[retainedControlPath,"SHA256"],Hash[retainedTask,"SHA256"],inputHash,$Version,$FeynCalcVersion},"SHA256"];
retainedProof=If[FileExistsQ[retainedProofPath],Get[retainedProofPath],<||>];
If[Lookup[retainedProof,"Binding",None]=!=retainedBinding || !TrueQ[Lookup[retainedProof,"Accepted",False]],
  retainedResidualPath=FileNameJoin[{root,channel,"s12_retained_residual_result","s12_result.wl"}];
  gate["bound actual empty-support regression input",IntegerString[FileHash[retainedResidualPath,"SHA256"],16,64]===
    "6cdf81ba17c53cd39c35a383ac8bae3edfb0a4ba5da07cc789a5dbe921704c4f"];
  retainedResidual=Get[retainedResidualPath];
  retainedRegressionTask=mapped["Components"][[retainedResidual["ComponentIndex"]]];
  gate["actual regression component unchanged",retainedResidual["InputHash"]===inputHash &&
    retainedResidual["ComponentHash"]===Hash[retainedRegressionTask,"SHA256"]];
  retainedRegressionRows=Select[retainedResidual["Rows"],!IntegerQ[#["First"]] || !IntegerQ[#["Last"]]&];
  gate["actual empty-support case covered",Length[retainedRegressionRows]>0];
  retainedRegression=Table[
    retainedRegressionMaster=retainedRegressionRow["Master"];
    retainedRegressionCoefficient=(retainedRegressionTask["ReducedCoefficients"][retainedRegressionMaster]/.transverseRule)/.D->4-2eps;
    retainedRegressionOrder=-Exponent[Expand[Normal[regions["OrdinaryMasters"][retainedRegressionMaster]],eps],eps,Min];
    gate["actual regression depth unchanged",retainedRegressionOrder===retainedRegressionRow["Order"]];
    retainedRegressionValue=checkedRationalSeries[retainedRegressionCoefficient,retainedRegressionOrder,
      {retainedResidual["ComponentIndex"],retainedRegressionMaster}];
    retainedRegressionOriginal=Block[{checkedRationalSeries},ToExpression[retainedDefinition,InputForm];
      checkedRationalSeries[retainedRegressionCoefficient,retainedRegressionOrder,"original empty-support case"]];
    gate["actual empty-support output exactly matches reference",retainedRegressionValue===retainedRegressionOriginal];
    <|"Master"->retainedRegressionMaster,"Order"->retainedRegressionOrder,
      "Original"->retainedRegressionOriginal,"Candidate"->retainedRegressionValue|>,
    {retainedRegressionRow,retainedRegressionRows}];
  {retainedSeconds,retainedValue}=AbsoluteTiming[candidateOrdinary[retainedTask,retainedControlIndex]];
  gate["entire own ordinary coefficient exactly unchanged",retainedValue===retainedControl["Ordinary"] ||
    bounded[zeroCoefficient[Expand[retainedValue-retainedControl["Ordinary"],eps]],"own retained-series comparison"]];
  retainedProof=<|"Schema"->"polarized-sidis-retained-series-comparison-v1","Channel"->channel,
    "SourceHash"->FileHash[retainedPath,"SHA256"],"BaseSourceHash"->FileHash[retainedBase,"SHA256"],
    "Binding"->retainedBinding,"InputHash"->inputHash,"InputHashes"->inputHashes,
    "ControlIndex"->retainedControlIndex,"ControlHash"->FileHash[retainedControlPath,"SHA256"],
    "ControlTaskHash"->Hash[retainedTask,"SHA256"],"OriginalOrdinary"->retainedControl["Ordinary"],
    "CandidateOrdinary"->retainedValue,"CandidateSeconds"->retainedSeconds,
    "EmptySupportInputHash"->FileHash[retainedResidualPath,"SHA256"],"EmptySupportRegression"->retainedRegression,
    "OriginalDefinitions"->retainedOriginalDefinitions,"CandidateDefinitions"->DownValues[checkedRationalSeries],
    "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True|>;
  retainedSerialized="Uncompress["<>ToString[Compress[retainedProof],InputForm]<>"]\n";
  gate["bounded retained-series proof",StringLength[retainedSerialized]<128*1024^2];
  Export[retainedProofPath<>".tmp",retainedSerialized,"Text"];
  gate["exact retained-series proof reload",Get[retainedProofPath<>".tmp"]===retainedProof];
  RenameFile[retainedProofPath<>".tmp",retainedProofPath,OverwriteTarget->True]];
gate["complete retained-series comparison accepted",retainedProof["Binding"]===retainedBinding &&
  TrueQ[retainedProof["Accepted"]] && And@@Values[retainedProof["Checks"]]];
If[Environment["POLARIZED_SIDIS_RETAINED_COMPARISON_ONLY"]==="1",Print["PASS: s12_retained_series_comparison"];Quit[0]];
retainedOutputNeedle="put[result,FileNameJoin[{resultDir,\"s12_result.wl\"}]];";
retainedOutputReplacement="AssociateTo[result,{\"RetainedSeriesSourceHash\"->FileHash[retainedPath,\"SHA256\"],\"RetainedSeriesComparisonHash\"->FileHash[retainedProofPath,\"SHA256\"]}];\n"<>retainedOutputNeedle;
gate["single retained-series output interface",StringCount[transverseOutputTail,retainedOutputNeedle]===1];
referenceSeriesTail=StringReplace[transverseOutputTail,retainedOutputNeedle->retainedOutputReplacement];
gate["unchanged remaining integration equations",SyntaxQ[referenceSeriesTail] &&
  StringReplace[referenceSeriesTail,retainedOutputReplacement->retainedOutputNeedle]===transverseOutputTail];
ToExpression[transverseEndpointRun,InputForm];

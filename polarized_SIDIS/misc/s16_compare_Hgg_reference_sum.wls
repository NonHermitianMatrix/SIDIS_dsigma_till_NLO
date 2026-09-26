(* Isolated measurement of the original reference operation on actual Hgg input. *)
$HistoryLength=0;
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
comparisonSource=ExpandFileName[$InputFileName];
comparisonRoot=DirectoryName[DirectoryName[comparisonSource]];
comparisonDriver=FileNameJoin[{comparisonRoot,"misc","s10_reduce_Hgg_coefficients.wls"}];
If[IntegerString[FileHash[comparisonDriver,"SHA256"],16,64]=!=
 "0e60864de5711c16810f66e8ddb0d26adb6b2cf66077c324352d7ded6f52f60c",Quit[1]];
comparisonText=ReadString[comparisonDriver];
comparisonPrefix=StringTake[comparisonText,
 First[First[StringPosition[comparisonText,"\nslots = 2;"]]]-1];
comparisonPrefix=StringReplace[comparisonPrefix,
 "$FeynCalcStartupMessages=False;Get[\"FeynCalc`\"];"->"Null;"];
If[!SyntaxQ[comparisonPrefix]||!SyntaxQ[ReadString[comparisonSource]],Quit[1]];
ToExpression[comparisonPrefix,InputForm];
comparisonRaw=localReadRaw[1];
comparisonRules=Association[reduction["Rules"]];
comparisonMasters=Union[Cases[Values[KeyTake[comparisonRules,Keys[comparisonRaw["Coefficients"]]]],
 _CutIntegral,Infinity]];
gate["actual Hgg comparison masters are accepted",comparisonMasters=!={}&&
 Complement[comparisonMasters,reduction["Masters"]]==={}];
comparisonMaster=First[comparisonMasters];
comparisonTerms=KeyValueMap[#2 Coefficient[comparisonRules[#1],comparisonMaster]&,
 comparisonRaw["Coefficients"]];
Print["ACTUAL_REFERENCE_INPUT ",InputForm[<|"Component"->1,"Master"->comparisonMaster,
 "TermCount"->Length[DeleteCases[comparisonTerms,0]],"Bytes"->ByteCount[comparisonTerms]|>]];
Print["ACTUAL_SMALLEST_INPUT ",InputForm[First[MinimalBy[DeleteCases[comparisonTerms,0],ByteCount]]]];
{comparisonSeconds,comparisonAnswer}=AbsoluteTiming[TimeConstrained[
 referenceCoefficients[comparisonRaw["Coefficients"],{comparisonMaster},"isolated direct reference"],
 180,Missing["TimeLimit"]]];
comparisonResult=<|"Schema"->"polarized-sidis-direct-reference-comparison-v1",
 "Channel"->channel,"Component"->1,"Master"->comparisonMaster,"Seconds"->comparisonSeconds,
 "SourceHash"->FileHash[comparisonSource,"SHA256"],"ProductionSourceHash"->FileHash[comparisonDriver,"SHA256"],
 "ProductionConfigurationHash"->FileHash[localConfigPath,"SHA256"],
 "InputHash"->inputHash,"RawInputHash"->localRawInputHash,
 "RawCoefficientSHA256"->rawTargetComponents[[1]]["RawCoefficientSHA256"],
 "NativeVersions"->{$Version,$FeynCalcVersion},"Coefficient"->comparisonAnswer,
 "Completed"->AssociationQ[comparisonAnswer],"AdoptedForProduction"->False,"Checks"->checks|>;
comparisonDir=FileNameJoin[{root,"misc","s16_result"}];
If[!DirectoryQ[comparisonDir],CreateDirectory[comparisonDir,CreateIntermediateDirectories->True]];
putCompressed[comparisonResult,FileNameJoin[{comparisonDir,"s16_result.wl"}]];
Print["DIRECT_REFERENCE_MEASUREMENT ",InputForm[KeyTake[comparisonResult,
 {"Seconds","Completed","Master","AdoptedForProduction"}]]];
Quit[0];

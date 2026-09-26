(* Compare exact polynomial summation with every accepted own-Hgg map coefficient. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
ownPolynomialSource=ExpandFileName[$InputFileName];
ownPolynomialRoot=DirectoryName[DirectoryName[ownPolynomialSource]];
ownPolynomialMerge=FileNameJoin[{ownPolynomialRoot,"misc","s07_merge_Hgg_coefficients.wls"}];
ownPolynomialTransfer=FileNameJoin[{ownPolynomialRoot,"misc","s17_compare_Hgg_exact_polynomials.wls"}];
ownPolynomialBackend=FileNameJoin[{ownPolynomialRoot,"misc","s18_sum_exact_polynomials.py"}];
If[IntegerString[FileHash[ownPolynomialMerge,"SHA256"],16,64]=!=
 "eef36a7e8e34543a3a623acb7f9d8b5da97c7174e841ecfe8abd4484d2d8ec51"||
 IntegerString[FileHash[ownPolynomialTransfer,"SHA256"],16,64]=!=
 "80620855756a4c5439f617371dc765e470e83f3ae09598dc921d7c26d8587cb2"||
 IntegerString[FileHash[ownPolynomialBackend,"SHA256"],16,64]=!=
 "5a8af32c6fb25426ff5fc3dcf4e4bbd65fafa2f47815d2dd705d31dfdf7a53a7",Quit[1]];
ownPolynomialText=ReadString[ownPolynomialMerge];
ownPolynomialPrefix=StringTake[ownPolynomialText,
 First[First[StringPosition[ownPolynomialText,"\n(* BEGIN METADATA PATH REPAIR *)"]]]-1];
ownPolynomialPrefix=StringReplace[ownPolynomialPrefix,
 "$FeynCalcStartupMessages=False;Get[\"FeynCalc`\"];"->"Null;"];
If[!SyntaxQ[ReadString[ownPolynomialSource]]||!SyntaxQ[ownPolynomialPrefix],Quit[1]];
ToExpression[ownPolynomialPrefix,InputForm];
ownPolynomialRead=StringTake[ownPolynomialText,{
 First[First[StringPosition[ownPolynomialText,"\nreadGroup[row_]"]]],
 First[First[StringPosition[ownPolynomialText,"\nrunMerge[rows_"]]]-1}];
gate["unchanged own group reader syntax",SyntaxQ[ownPolynomialRead]];
ToExpression[ownPolynomialRead,InputForm];
ownPolynomialTransferText=ReadString[ownPolynomialTransfer];
ownPolynomialProducer=StringTake[ownPolynomialTransferText,{
 First[First[StringPosition[ownPolynomialTransferText,"\npolynomialVariables=<||>;"]]],
 First[First[StringPosition[ownPolynomialTransferText,"\npolynomialCases="]]]-1}];
gate["unchanged native polynomial transfer syntax",SyntaxQ[ownPolynomialProducer]];
ToExpression[ownPolynomialProducer,InputForm];
ownPolynomialMaps=readGroup/@manifest["own_groups"];
ownPolynomialGrouped=Merge[ownPolynomialMaps,Identity];Clear[ownPolynomialMaps];
ownPolynomialKeys=Keys[ownPolynomialGrouped];
gate["accepted own coefficients have complete grouped support",
 Complement[Keys[own["OwnCoefficients"]],ownPolynomialKeys]==={}];
ownPolynomialExpected=Lookup[own["OwnCoefficients"],#,Total[{}]]&/@ownPolynomialKeys;
ownPolynomialLabels=Table["own_Hgg_raw_"<>IntegerString[i,10,4],{i,Length[ownPolynomialKeys]}];
ownPolynomialCases=MapThread[polynomialCase,{ownPolynomialLabels,
 Lookup[ownPolynomialGrouped,ownPolynomialKeys],ownPolynomialExpected}];
ownPolynomialDir=FileNameJoin[{root,"misc","s19_result"}];
If[!DirectoryQ[ownPolynomialDir],CreateDirectory[ownPolynomialDir,CreateIntermediateDirectories->True]];
ownPolynomialInput=FileNameJoin[{ownPolynomialDir,"s19_input.json"}];
ownPolynomialOutput=FileNameJoin[{ownPolynomialDir,"s19_output.json"}];
ownPolynomialPayload=<|"schema"->"polarized-sidis-exact-polynomial-input-v1","cases"->ownPolynomialCases|>;
Export[ownPolynomialInput,ownPolynomialPayload,"RawJSON"];
gate["exact own polynomial JSON round trip",Import[ownPolynomialInput,"RawJSON"]===ownPolynomialPayload];
Print["OWN_HGG_POLYNOMIAL_INPUT_READY ",Length[ownPolynomialKeys]," ",FileByteCount[ownPolynomialInput]];
ownPolynomialProcess=RunProcess[{"python3",ownPolynomialBackend,ownPolynomialInput,ownPolynomialOutput}];
Print[ownPolynomialProcess["StandardOutput"]];Print[ownPolynomialProcess["StandardError"]];
gate["own polynomial backend completed",ownPolynomialProcess["ExitCode"]===0&&FileExistsQ[ownPolynomialOutput]];
ownPolynomialAnswer=Import[ownPolynomialOutput,"RawJSON"];
gate["own polynomial complete output identity",ownPolynomialAnswer["schema"]==="polarized-sidis-exact-polynomial-output-v1"&&
 ownPolynomialAnswer["input_sha256"]===IntegerString[FileHash[ownPolynomialInput,"SHA256"],16,64]&&
 ownPolynomialAnswer["source_sha256"]===IntegerString[FileHash[ownPolynomialBackend,"SHA256"],16,64]&&
 ownPolynomialAnswer["flint_version"]==="0.8.0"&&
 Lookup[ownPolynomialAnswer["cases"],"label"]===ownPolynomialLabels];
ownPolynomialValues=Map[Function[row,
 gate["own exact coefficient reconstruction",TrueQ[row["exact_termwise_reconstruction_passed"]]&&TrueQ[row["expected_comparison_passed"]]];
 (ToExpression[row["numerator"],InputForm]/ToExpression[row["denominator"],InputForm])/.
 polynomialVariables[row["label"]]],ownPolynomialAnswer["cases"]];
gate["all native accepted own Hgg coefficients reproduced",
 And@@MapThread[bounded[zero[#1-#2],"native own coefficient equality"]&,{ownPolynomialValues,ownPolynomialExpected}]];
ownPolynomialResult=<|"Schema"->"polarized-sidis-own-Hgg-polynomial-sum-validation-v1","Channel"->"Hgg",
 "SourceHash"->FileHash[ownPolynomialSource,"SHA256"],"BackendHash"->FileHash[ownPolynomialBackend,"SHA256"],
 "TransferHash"->FileHash[ownPolynomialTransfer,"SHA256"],"ManifestHash"->FileHash[manifestPath,"SHA256"],
 "AcceptedOwnResultHash"->FileHash[FileNameJoin[{root,"Hgg","s08_external_factor_result","s08_result.wl"}],"SHA256"],
 "InputFileHash"->FileHash[ownPolynomialInput,"SHA256"],"OutputFileHash"->FileHash[ownPolynomialOutput,"SHA256"],
 "CoefficientKeys"->ownPolynomialKeys,"CoefficientCount"->Length[ownPolynomialKeys],
 "Evidence"->(KeyDrop[#,{"numerator","denominator"}]&/@ownPolynomialAnswer["cases"]),
 "NativeVersions"->nativeVersions,"ImportedNativeVersions"->importedVersions,"BackendVersion"->ownPolynomialAnswer["flint_version"],
 "AcceptedOwnHggComparisonPassed"->True,"Checks"->checks|>;
mergeSave[ownPolynomialResult,FileNameJoin[{ownPolynomialDir,"s19_result.wl"}]];
Print["PASS: complete own Hgg polynomial sum validation"];Quit[0];

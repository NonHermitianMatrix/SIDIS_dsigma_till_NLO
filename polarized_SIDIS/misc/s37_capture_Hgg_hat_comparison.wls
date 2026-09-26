
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
s14ReviewRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localHatCaptureSource=ExpandFileName[$InputFileName];
s14ReviewSource=FileNameJoin[{s14ReviewRoot,"misc","s14_assemble_Hgg_finite.wls"}];
s14ReviewText=StringTrim[ReadString[s14ReviewSource]];
s14ReviewManifest=Import[FileNameJoin[{s14ReviewRoot,"misc","s14_source_changes.json"}],"RawJSON"];
s14ReviewReconstructed=ReadString[FileNameJoin[{s14ReviewRoot,s14ReviewManifest["parent"]}]];
Do[If[StringCount[s14ReviewReconstructed,row["before"]]=!=1,Print["FAIL: source reconstruction"];Quit[1]];
 s14ReviewReconstructed=StringReplace[s14ReviewReconstructed,row["before"]->row["after"]],{row,s14ReviewManifest["changes"]}];
If[StringTrim[s14ReviewReconstructed]=!=s14ReviewText||!SyntaxQ[s14ReviewText],Print["FAIL: complete reviewed source"];Quit[1]];
s14ReviewTerminal="ToExpression[localFiniteChange[hggNativeFinal,localFiniteTailEdits],InputForm];";
If[!StringEndsQ[s14ReviewText,s14ReviewTerminal],Quit[1]];
s14ReviewPrefix=StringDrop[s14ReviewText,-StringLength[s14ReviewTerminal]];
s14ReviewRuntimeChanges={
 "localFiniteRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];"->"localFiniteRoot=s14ReviewRoot;",
 "Get[\"FeynCalc`\"]"->"Null"};
If[!And@@(StringCount[s14ReviewPrefix,First[#]]===1&/@s14ReviewRuntimeChanges),Print["FAIL: unique review runtime interfaces"];Quit[1]];
s14ReviewExecutable=StringReplace[s14ReviewPrefix,s14ReviewRuntimeChanges];
If[StringReplace[s14ReviewExecutable,Reverse/@s14ReviewRuntimeChanges]=!=s14ReviewPrefix||!SyntaxQ[s14ReviewExecutable],Quit[1]];
ToExpression[s14ReviewExecutable,InputForm];


gate["unchanged native assembly source",StringTrim[s14ReviewReconstructed]===s14ReviewText];
SetAttributes[finitePart,HoldFirst];
uPosition=First[FirstPosition[basis["SpinLabels"],"U"]];
localHatIndices=Table[{a,uPosition,uPosition},{a,Length[basis["PhotonLabels"]]}];
localHatBefore=MemoryInUse[];
{localHatSeconds,localHatRows}=AbsoluteTiming[Block[{checkedPhaseProduct},
 checkedPhaseProduct[___]:=(gate["no accepted phase calculation repeated",False];$Failed);
 assemble/@localHatIndices]];
gate["every cached unpolarized component accepted",AllTrue[localHatRows,AssociationQ]&&And@@Lookup[localHatRows,"Accepted"]];
localHatName="F1";localHatNumber=First[FirstPosition[Keys[referenceHats],localHatName]];
localHatSign=1;localHatDistribution="Regular";
localHatActual=Sum[hatPhotonWeights[[localHatNumber,a]]
 localHatRows[[a]]["Branches"][localHatSign][localHatDistribution],{a,Length[localHatRows]}];
localHatExpected=referenceHats[localHatName]/.t->localHatSign omega-s;
localHatAssumptions=(physical/.t->localHatSign omega-s)&&omega>0&&flavorDomain;
localHatDifference=localHatActual-localHatExpected;
gate["complete symbolic final comparison input",FreeQ[localHatDifference,
 eps|_Missing|_GLI|_CutIntegral|_PaVe|_Integrate|_Series|_Limit|_Real|Indeterminate|_DirectedInfinity]];
Print["ACTUAL_FINAL_COMPARE_INPUT actual_bytes ",ByteCount[localHatActual],
 " expected_bytes ",ByteCount[localHatExpected]," difference_bytes ",ByteCount[localHatDifference],
 " cached_assembly_seconds ",localHatSeconds];
localHatFunctions=DeleteDuplicates[Cases[localHatDifference,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
Print["ACTUAL_FINAL_FUNCTIONS ",InputForm[localHatFunctions]];
localHatTerms=If[Head[localHatDifference]===Plus,List@@localHatDifference,{localHatDifference}];
If[ByteCount[First[localHatTerms]]<16384,
 Print["ACTUAL_FINAL_COMPARISON_FIRST_TERM ",InputForm[First[localHatTerms]]],
 Print["ACTUAL_FINAL_COMPARISON_FIRST_TERM ",Short[InputForm[First[localHatTerms]],8]]];
result=<|"Schema"->"polarized-sidis-Hgg-final-comparison-capture-v1",
 "SourceHash"->FileHash[localHatCaptureSource,"SHA256"],"AssemblySourceHash"->FileHash[localFiniteSource,"SHA256"],
 "ConfigHash"->FileHash[localFiniteConfigPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
 "Name"->localHatName,"Sign"->localHatSign,"Distribution"->localHatDistribution,
 "Actual"->localHatActual,"Expected"->localHatExpected,"Difference"->localHatDifference,
 "Assumptions"->localHatAssumptions,"Indices"->localHatIndices,"Weights"->hatPhotonWeights,
 "CachedAssemblySeconds"->localHatSeconds,"Checks"->checks,"Accepted"->True,
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>;
out=FileNameJoin[{root,"misc","s37_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded final comparison capture",StringLength[serialized]<128*1024^2];
path=FileNameJoin[{out,"s37_result.wl"}];Export[path,serialized,"Text"];
gate["exact captured final comparison reload",Get[path]===result];
Export[FileNameJoin[{out,"s37_checks.json"}],<|"checks"->checks,"cached_assembly_seconds"->localHatSeconds,
 "actual_bytes"->ByteCount[localHatActual],"expected_bytes"->ByteCount[localHatExpected]|>,"RawJSON"];
Print["PASS: exact Hgg final comparison captured"];Quit[0];

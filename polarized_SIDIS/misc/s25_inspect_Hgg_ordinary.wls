(* Compare the saved original control to the unchanged recurrence on its exact input. *)
$HistoryLength=0;
reviewRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
reviewSource=FileNameJoin[{reviewRoot,"misc","s25_inspect_Hgg_ordinary.wls"}];
reviewParent=FileNameJoin[{reviewRoot,"misc","s11_assemble_Hgg_real.wls"}];
If[IntegerString[FileHash[reviewParent,"SHA256"],16,64]=!=
 "b3f7103b3e55058953f206d7454478e5dc97de61888444354860348fbe498090",Quit[1]];
reviewParentText=ReadString[reviewParent];reviewBoundary="\nreferenceSeriesControlCode = ";
If[StringCount[reviewParentText,reviewBoundary]=!=1,Quit[1]];
reviewInitialization=First[StringSplit[reviewParentText,reviewBoundary]];
If[!SyntaxQ[reviewInitialization]||!SyntaxQ[ReadString[reviewSource]],Quit[1]];
ToExpression[reviewInitialization,InputForm];
reviewIndices=Select[Range[Length[mapped["Components"]]],
 AnyTrue[Values[mapped["Components"][[#]]["ReducedCoefficients"]],#=!=0&]&];
reviewIndex=First[MinimalBy[reviewIndices,ByteCount[mapped["Components"][[#]]["ReducedCoefficients"]]&]];
reviewTask=mapped["Components"][[reviewIndex]];
reviewOriginalPath=FileNameJoin[{root,"misc","s11_result","own_reference","s12_original_ordinary.wl"}];
reviewOriginal=Get[reviewOriginalPath];
reviewBinding=Hash[{reviewTask,transverseRule,regions["OrdinaryMasters"],DownValues[epsilonSeries],
 $Version,$FeynCalcVersion,$Assumptions},"SHA256"];
gate["cached original has exact complete actual input",reviewOriginal["Binding"]===reviewBinding&&
 reviewOriginal["ValueHash"]===Hash[reviewOriginal["Value"],"SHA256"]];
{reviewSeconds,reviewCandidate}=AbsoluteTiming[candidateOrdinary[reviewTask,reviewIndex]];
reviewDifference=bounded[Expand[reviewCandidate-reviewOriginal["Value"],eps],"complete captured ordinary difference"];
reviewResidual=bounded[Factor[Together[localCanonicalScalarArguments[reviewDifference]]],"factored captured ordinary residual"];
reviewOutput=FileNameJoin[{root,"misc","s25_result"}];
If[!DirectoryQ[reviewOutput],CreateDirectory[reviewOutput,CreateIntermediateDirectories->True]];
reviewResult=<|"Schema"->"polarized-sidis-complete-ordinary-capture-v1","Channel"->channel,
 "ComponentIndex"->reviewIndex,"Task"->reviewTask,"Original"->reviewOriginal["Value"],
 "Candidate"->reviewCandidate,"Residual"->reviewResidual,"Difference"->reviewDifference,
 "OriginalBinding"->reviewBinding,"OriginalCacheHash"->FileHash[reviewOriginalPath,"SHA256"],
 "InputHash"->inputHash,"InputHashes"->inputHashes,"SourceHash"->FileHash[reviewSource,"SHA256"],
 "ParentSourceHash"->FileHash[reviewParent,"SHA256"],"Seconds"->reviewSeconds,
 "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"ProductionAccepted"->False|>;
put[reviewResult,FileNameJoin[{reviewOutput,"s25_result.wl"}]];
Export[FileNameJoin[{reviewOutput,"s25_equations.wl"}],ToString[reviewResidual,InputForm],"Text"];
Export[FileNameJoin[{reviewOutput,"s25_checks.json"}],<|"checks"->checks,"component_index"->reviewIndex,
 "residual_bytes"->ByteCount[reviewResidual],"seconds"->reviewSeconds,"production_accepted"->False|>,"RawJSON"];
Print["ACTUAL_ORDINARY_RESIDUAL ",InputForm[reviewResidual]];
Print["PASS: actual Hgg complete ordinary captured"];Quit[0];

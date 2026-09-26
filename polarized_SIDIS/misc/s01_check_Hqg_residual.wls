(* Bounded local comparison of actual saved Hqg residual equations. *)
$HistoryLength=0;
started=AbsoluteTime[];misc=DirectoryName[$InputFileName];root=DirectoryName[misc];
source=FileNameJoin[{misc,"s01_check_Hqg_residual.wls"}];checks=<||>;
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],
 Print["FAIL: ",name];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,120,
 Print["FAIL: time limit ",label];Quit[2]],2*1024^3,
 Print["FAIL: memory limit ",label];Quit[3]];
config=Import[FileNameJoin[{misc,"s01_inputs.json"}],"RawJSON"];
gate["complete entry point syntax",SyntaxQ[ReadString[source]]];
gate["reviewed local implementation",IntegerString[FileHash[source,"SHA256"],16,64]===config["source_sha256"]];
KeyValueMap[Function[{relative,expected},gate["bound input "<>relative,
 IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===expected]],config["input_sha256"]];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["native FeynCalc loaded",StringQ[$FeynCalcVersion]];
read[relative_]:=Get[FileNameJoin[{root,relative}]];
inspection=read["misc/s01_result/reference/s14_result.wl"];
current=read["Hqg/s11_result/s11_result.wl"];
previous=read["Hqg/s11_result/reference/before_dimensional_completion/s11_result.wl"];
basis=read["common/s02_result/s02_result.wl"];
kernels=read["common/s10_result/s10_result.wl"];
native=read["Hgq/s10_dimensional_gluon_result/s10_result.wl"];
gate["original diagnostic checks and schema",inspection["Channel"]==="Hqg"&&
 inspection["Schema"]==="polarized-sidis-reference-residual-inspection-v1"&&And@@Values[inspection["Checks"]]];
gate["exact current subtraction in failed assembly",inspection["InputHashes"]["Hqg/s11_result/s11_result.wl"]===
 FileHash[FileNameJoin[{root,"Hqg/s11_result/s11_result.wl"}],"SHA256"]];
gate["saved original subtraction identity",current["PreviousSubtractionHash"]===
 FileHash[FileNameJoin[{root,"Hqg/s11_result/reference/before_dimensional_completion/s11_result.wl"}],"SHA256"]];
gate["same physical labels and checked native inputs",current["PhotonLabels"]===basis["PhotonLabels"]&&
 current["SpinLabels"]===basis["SpinLabels"]&&current["SpinLabels"]===kernels["SpinLabels"]&&
 And@@Flatten[Values[#["Checks"]]&/@{current,previous,basis,kernels,native}]&&TrueQ[native["Accepted"]]];
basePath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];baseText=Import[basePath,"Text"];
gate["same original assembly",inspection["BaselineSourceHash"]===FileHash[basePath,"SHA256"]];
normalizationDefinitions=StringRiffle[{
 "dimension=4-2eps;",
 "hardNormalization=(2Pi)^(-Limit[dimension,eps->0]);",
 "couplingSquare=Factor[gs^2/.First[Solve[gs^2==4Pi alphaS,gs]]];"},"\n"];
gate["unchanged normalization definitions",And@@(StringCount[baseText,#]===1&/@StringSplit[normalizationDefinitions,"\n"])];
ToExpression[normalizationDefinitions,InputForm];
core=True;branches=<|1-><|"Delta"->1|>|>;
gate["saved normalization syntax",SyntaxQ[inspection["NormalizationSource"]]];
ToExpression[inspection["NormalizationSource"],InputForm];normalization=branches[1]["Delta"];
u=First[FirstPosition[basis["SpinLabels"],"U"]];
difference=bounded[Map[Factor,current["Counterterms"]["Delta"]-previous["Counterterms"]["Delta"],{3}],"counterterm difference"];
gate["exact saved finite counterterm difference",difference===current["CountertermDifference"]["Delta"]&&FreeQ[difference,eps|D]];
assumptions=inspection["PhysicalConditions"];
reduceTerms[value_]:=bounded[FullSimplify[FunctionExpand[value,assumptions],assumptions],"saved finite equation"];
rows=Table[
 input=inspection["Rows"][[n]];
 plain=read["misc/s01_result/reference/s14_residual_"<>input["Hat"]<>".wl"];
 gate["exact readable residual "<>input["Hat"],plain===input["Residual"]];
 correction=(normalization inspection["PhotonWeights"][[n]].difference[[All,u,u]])/.t->input["Branch"] omega-s;
 gate["same branch variables "<>input["Hat"],FreeQ[correction,t]];
 Print["COMPARE_BEGIN ",input["Hat"]];
 residual=reduceTerms[input["Residual"]];remaining=reduceTerms[input["Residual"]-correction];
 Print["RESIDUAL ",input["Hat"]," ",InputForm[residual]];
 Print["RESIDUAL_WITHOUT_COMPLETION ",input["Hat"]," ",InputForm[remaining]];
 <|"Hat"->input["Hat"],"Residual"->residual,"CompletionChange"->correction,
   "ResidualWithoutCompletion"->remaining,"Explained"->(remaining===0)|>,{n,Length[inspection["Rows"]]}];
route=Select[current["Routes"],#["Side"]==="FF"&&#["KernelKey"]==="gg"&];
gate["unique recorded gluon fragmentation route",Length[route]===1];
completion=current["IntermediateStateCompletions"][First[route]["ReferenceName"]];
gate["native and completed intermediate labels",completion["IntermediateLabels"]===native["SpinLabels"]];
e=First[FirstPosition[native["SpinLabels"],"E"]];
oldTransfer=bounded[kernels["Responses"]["gg"]["Kernel"].Transpose[completion["Conversion"]],"old operator reconstruction"];
oldEndpoint=Expand[oldTransfer[[u,e]]/.{kernelPlus[1/(1-z)]->plusMarker,kernelDelta[1-z]->deltaMarker}];
oldSoft=Coefficient[oldEndpoint,plusMarker];oldDelta=Coefficient[oldEndpoint,deltaMarker];
nativeSoft=native["FFSoftResidue"][[u,e]];
gate["native Gram dual identity",bounded[And@@(Factor[Together[#]]===0&/@Flatten[
 native["FFKernelD"]-native["RawDimensionalKernel"].native["DualMatrices"][p]]),"native operator identity"]];
endpointEvidence=<|"OldEToUSoft"->oldSoft,"OldEToUDelta"->oldDelta,
 "NativeEToUSoft"->nativeSoft,"SoftDifference"->Factor[oldSoft-nativeSoft]|>;
Print["ENDPOINT_EVIDENCE ",InputForm[endpointEvidence]];
result=<|"Schema"->"polarized-sidis-local-hqg-residual-comparison-v1","Channel"->"Hqg",
 "SourceSHA256"->config["source_sha256"],"InputSHA256"->config["input_sha256"],
 "LocalNativeVersions"->{$Version,$FeynCalcVersion},"InputNativeVersions"->inspection["NativeVersions"],
 "InputExecutionStatus"->"Preserved 14884507 native diagnostic; wrapper receipt unavailable",
 "Normalization"->normalization,"Rows"->rows,"EndpointEvidence"->endpointEvidence,"Checks"->checks,
 "AllResidualsExplained"->And@@Lookup[rows,"Explained"],"ProductionInputsChanged"->False,
 "FiniteNLOFHatsComputed"->False,"Seconds"->(AbsoluteTime[]-started),"PeakKernelMemoryBytes"->MaxMemoryUsed[]|>;
out=FileNameJoin[{misc,"s01_result","s01_result.wl"}];serialized=ToString[result,InputForm]<>"\n";
gate["bounded local result",StringLength[serialized]<4*1024^2];
Export[out<>".tmp",serialized,"Text"];gate["exact result reload",Get[out<>".tmp"]===result];
RenameFile[out<>".tmp",out,OverwriteTarget->True];
Export[FileNameJoin[{misc,"s01_result","s01_checks.json"}],<|"checks"->checks,
 "all_residuals_explained"->result["AllResidualsExplained"],"seconds"->result["Seconds"],
 "peak_kernel_memory_bytes"->result["PeakKernelMemoryBytes"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s01_check_Hqg_residual"];Quit[0];

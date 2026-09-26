(* Check the inherited CDR intermediate-state sum against the actual finite residual. *)
$HistoryLength=0;completionRoot=Directory[];
completionSource=FileNameJoin[{completionRoot,"common","s11_check_dimensional_convolution.wls"}];
completionBaseline=FileNameJoin[{completionRoot,"common","s11_small_collinear_spin.wls"}];
If[IntegerString[FileHash[completionBaseline,"SHA256"],16,64]=!=
  "44ac7b5470ce54c6d0276bfa685ab88a5fff8d78d90c3835e7548488c48ffc8a",Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
completionText=Import[completionBaseline,"Text"];
If[StringCount[completionText,"\ncontributions = <||>;"]=!=1,Quit[1]];
completionPrefix=First[StringSplit[completionText,"\ncontributions = <||>;"]];
If[StringCount[completionPrefix,"Get[\"FeynCalc`\"]"]=!=1,Quit[1]];
completionPrefix=StringReplace[completionPrefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[completionPrefix]||!SyntaxQ[Import[completionSource,"Text"]],Quit[1]];
ToExpression[completionPrefix,InputForm];
gate["completion comparison channel",channel==="Hqqprime"];
completionOldPath=FileNameJoin[{root,channel,"s11_result","s11_result.wl"}];
completionOld=Get[completionOldPath];
gate["same original subtraction",completionOld["SourceHash"]===FileHash[completionBaseline,"SHA256"]&&
  And@@Values[completionOld["Checks"]]&&completionOld["Routes"]===routes];
completionBasisPath=FileNameJoin[{root,"common","s02_result","s02_result.wl"}];
completionBasis=Get[completionBasisPath];gate["accepted photon basis",And@@Values[completionBasis["Checks"]]];
completionResidualPath=FileNameJoin[{root,channel,"s14_reference_residual_result","s14_result.wl"}];
gate["actual failed reference residual identity",IntegerString[FileHash[completionResidualPath,"SHA256"],16,64]===
  "a92ec00fbd123a2c27126eeb077e1086991cec9332753667e5ae30cd0818f28a"];
completionResidual=Get[completionResidualPath];
gate["residual binds this subtraction",completionResidual["InputHashes"][channel<>"/s11_result/s11_result.wl"]===
  FileHash[completionOldPath,"SHA256"]];
completionDiagnosticPath=FileNameJoin[{root,channel,"s14_dimensional_result","s14_result.wl"}];
gate["dimensional comparison identity",IntegerString[FileHash[completionDiagnosticPath,"SHA256"],16,64]===
  "45e1bb0654442f0446bbf6ac3e8151b93e722904ab5527907a0ad209987014c1"];
completionDiagnostic=Get[completionDiagnosticPath];
gate["full-dimensional metric poles exactly cancel",bounded[zeroArray[Values[
  completionDiagnostic["MetricCDRPoleResiduals"]]],"CDR metric exact pole check"]];

completeIntermediateBorn[data_,side_] := Module[{extended,physicalPositions,intermediateLabels,
  intermediatePositions,conversion,average,answer},
  extended=Join[data["ExtendedResponse"],{data["EvanescentPhotonResponse"]}];
  intermediateLabels=data[If[side==="PDF","ExtendedIncomingLabels","ExtendedOutgoingLabels"]];
  physicalPositions=Flatten[FirstPosition[data[If[side==="PDF","ExtendedOutgoingLabels","ExtendedIncomingLabels"]],#]&/@labels];
  intermediatePositions=Flatten[Position[intermediateLabels,"U"|"E"]];
  average=If[side==="PDF",data["CDRAverageConversion"],1];
  conversion=Table[If[labels[[i]]==="U",If[MemberQ[intermediatePositions,k],average,0],
    Boole[intermediateLabels[[k]]===labels[[i]]]],{k,Length[intermediateLabels]},{i,Length[labels]}];
  answer=If[side==="PDF",(#.conversion&/@extended[[All,physicalPositions,All]]),
    (Transpose[conversion].#&/@extended[[All,All,physicalPositions]])];
  <|"Response"->Map[Factor,answer,{3}],"Conversion"->conversion,
    "IntermediateLabels"->intermediateLabels,"PhysicalPositions"->physicalPositions|>];
completionContributions=<||>;completionBorns=<||>;
Do[key=route["Born"];side=route["Side"];
  completed=completeIntermediateBorn[borns[key],side];
  gate[route["Name"]<>" physical four-dimensional limit unchanged",zeroArray[
    (Take[completed["Response"],Length[photonLabels]]-borns[key]["Response"])/.D->4]];
  mapped=bounded[simplify[completed["Response"]/.mapRules[side]],{route["Name"],"completed Born"}];
  kernelMatrix=kernels["Responses"][route["Kernel"]]["Kernel"]/.z->roots[side];
  value=bounded[Map[Factor,measureWeights[side] If[side==="PDF",
    (Dot[#,kernelMatrix]&/@mapped),(Dot[kernelMatrix,#]&/@mapped)],{3}],route["Name"]];
  gate[route["Name"]<>" completed convolution evaluated",FreeQ[value,_Dot|_Missing|_Real|$Failed|$Aborted]];
  AssociateTo[completionBorns,route["Name"]->completed];
  AssociateTo[completionContributions,route["Name"]->value],{route,routes}];
completionRegular=Map[Factor,Total[Values[completionContributions]],{3}];
completionMetricWeights=Tr[completionBasis["PhotonMetric"].#]&/@completionBasis["PhotonBasis"];
completionPComponents=Take[LinearSolve[Transpose[realFrame/@{eL,eX,eY,q}],realFrame[p]],Length[{eL,eX,eY}]];
completionPWeights=Factor[completionPComponents.#.completionPComponents]&/@completionBasis["PhotonBasis"];
completionPhysical=Take[completionRegular,Length[photonLabels]];
completionCDRContractions=bornCoupling {
  completionMetricWeights.completionPhysical[[All,uPosition,uPosition]]+Last[completionRegular][[uPosition,uPosition]],
  completionPWeights.completionPhysical[[All,uPosition,uPosition]]};
gate["completed spin contraction reproduces both full-dimensional reference convolutions",
  zeroArray[completionCDRContractions-Lookup[referenceConvolutions,{"g","pp"}]]];
completionDifference=Map[Factor,completionPhysical-completionOld["ConvolutionsD"]["Regular"],{3}];
completionCorrection=Map[bounded[Normal[Series[completionOld["PhaseCT"] bornCoupling (#/.D->4-2eps),
  {eps,0,0}]],"finite dimensional counterterm correction"]&,completionDifference,{3}];
completionCorrection=Map[Factor,completionCorrection,{3}];
gate["dimensional correction changes no pole",FreeQ[completionCorrection,eps|D|_Series|_SeriesData|_Missing|_Real|$Failed|$Aborted]];
completionAssemblySource=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];
gate["unchanged final assembly source",IntegerString[FileHash[completionAssemblySource,"SHA256"],16,64]===
  "9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a"];
completionCouplingDefinitions=StringCases[Import[completionAssemblySource,"Text"],
  RegularExpression["(?m)^couplingSquare=[^;]+;"]];
gate["unique inherited coupling normalization",Length[completionCouplingDefinitions]===1];
ToExpression[First[completionCouplingDefinitions],InputForm];
completionNormalize[value_] := Block[{branches,normalization,core=False},
  branches=<|1-><|"Regular"->value|>|>;
  ToExpression[completionResidual["NormalizationSource"],InputForm];branches[1]["Regular"]];
completionHatCorrections=completionNormalize[completionResidual["PhotonWeights"].
  completionCorrection[[All,uPosition,uPosition]]/.t->omega-s];
completionRemaining=Map[Factor,Lookup[completionResidual["Rows"],"Residual"]+completionHatCorrections];
completionMatches=zeroArray[completionRemaining];
Print["COMPLETED_INTERMEDIATE_STATE_RESTORES_BOTH_HATS ",completionMatches];
Print["COMPLETION_REMAINING ",InputForm[completionRemaining]];
completionResult=<|"Schema"->"polarized-sidis-dimensional-convolution-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[completionSource,"SHA256"],"BaselineSourceHash"->FileHash[completionBaseline,"SHA256"],
  "OriginalSubtractionHash"->FileHash[completionOldPath,"SHA256"],
  "ResidualInspectionHash"->FileHash[completionResidualPath,"SHA256"],
  "DimensionalDiagnosticHash"->FileHash[completionDiagnosticPath,"SHA256"],
  "Definitions"->DownValues[completeIntermediateBorn],"CompletedBornStates"->completionBorns,
  "RouteConvolutionsD"->completionContributions,"RegularConvolutionD"->completionPhysical,
  "CountertermCorrection"->completionCorrection,"RemainingHatResiduals"->completionRemaining,
  "RestoresReferenceHats"->completionMatches,"Accepted"->completionMatches,
  "InputHashes"->completionOld["InputHashes"],"NativeVersions"->{$Version,$FeynCalcVersion},
  "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
completionDir=FileNameJoin[{root,channel,"s11_dimensional_result"}];
If[!DirectoryQ[completionDir],CreateDirectory[completionDir,CreateIntermediateDirectories->True]];
completionPath=FileNameJoin[{completionDir,"s11_result.wl"}];
put[completionResult,completionPath];gate["exact completion comparison reload",Get[completionPath]===completionResult];
Export[FileNameJoin[{completionDir,"s11_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "restores_reference_hats"->completionMatches,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s11_check_dimensional_convolution"];Quit[0];

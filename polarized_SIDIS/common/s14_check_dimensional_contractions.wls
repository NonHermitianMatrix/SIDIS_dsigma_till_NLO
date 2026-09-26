(* Locate the reference residual using the saved dimensional contractions. *)
$HistoryLength=0;diagnosticRoot=Directory[];
diagnosticSource=FileNameJoin[{diagnosticRoot,"common","s14_check_dimensional_contractions.wls"}];
diagnosticPhaseSource=FileNameJoin[{diagnosticRoot,"common","s14_check_phase_series.wls"}];
If[IntegerString[FileHash[diagnosticPhaseSource,"SHA256"],16,64]=!=
  "cb02337e0b7b4e6734a6d34fe452f90af7fbf29c40a0b6f38e076fad778176ce",Quit[1]];
diagnosticPrefix=First[StringSplit[Import[diagnosticPhaseSource,"Text"],"\nphaseControlLabels="]];
If[!SyntaxQ[diagnosticPrefix]||!SyntaxQ[Import[diagnosticSource,"Text"]],Quit[1]];
ToExpression[diagnosticPrefix,InputForm];
gate["dimensional diagnostic real-only quark channel",channel==="Hqqprime"&&!core];
diagnosticResidualPath=FileNameJoin[{root,channel,"s14_reference_residual_result","s14_result.wl"}];
gate["accepted residual inspection identity",IntegerString[FileHash[diagnosticResidualPath,"SHA256"],16,64]===
  "a92ec00fbd123a2c27126eeb077e1086991cec9332753667e5ae30cd0818f28a"];
diagnosticResidual=Get[diagnosticResidualPath];
gate["same assembly inputs",diagnosticResidual["InputHash"]===inputHash&&And@@Values[diagnosticResidual["Checks"]]];
diagnosticU=First[FirstPosition[basis["SpinLabels"],"U"]];
diagnosticAssumptions=diagnosticResidual["PhysicalConditions"];
diagnosticNormalize[value_] := Block[{branches,normalization},
  branches=<|1-><|"Regular"->value|>|>;
  ToExpression[diagnosticResidual["NormalizationSource"],InputForm];
  branches[1]["Regular"]];
diagnosticHatResiduals=Lookup[diagnosticResidual["Rows"],"Residual"];
diagnosticContractionResiduals=Map[Factor,LinearSolve[projectorWeights,diagnosticHatResiduals]];
gate["exact inverse scalar projections",Map[Factor,projectorWeights.diagnosticContractionResiduals-
  diagnosticHatResiduals]===ConstantArray[0,Length[diagnosticHatResiduals]]];
diagnosticPhysicalCT=diagnosticNormalize[({metricWeights,incomingWeights}.
  subtraction["Counterterms"]["Regular"][[All,diagnosticU,diagnosticU]])/.t->omega-s];
diagnosticCDRCT=Table[diagnosticNormalize[bounded[epsSeries[subtraction["PhaseCT"]
  (subtraction["ReferenceConvolutions"][mode]/.D->dimension)],{"CDR counterterm",mode}]/.t->omega-s],
  {mode,{"g","pp"}}];
diagnosticCTDifference=Map[Factor[Coefficient[Expand[#,eps],eps,0]]&,
  diagnosticPhysicalCT-diagnosticCDRCT];
diagnosticPPRemaining=Factor[diagnosticContractionResiduals[[2]]-diagnosticCTDifference[[2]]];
Print["DIMENSIONAL_PP_COUNTERTERM_EXPLAINS_RESIDUAL ",diagnosticPPRemaining===0];
Print["DIMENSIONAL_PP_REMAINING ",InputForm[diagnosticPPRemaining]];
diagnosticSector=First[Values[spinReal["Sectors"]]];
gate["no external dimensional gluon state",diagnosticSector["IncomingSpinLabels"]===basis["SpinLabels"]&&
  diagnosticSector["OutgoingSpinLabels"]===basis["SpinLabels"]];
diagnosticSpinSource=Import[FileNameJoin[{root,"common","s05_real_spin_response.wls"}],"Text"];
diagnosticVariableRows=StringCases[diagnosticSpinSource,
  RegularExpression["(?m)^  (inVariables|outVariables) = [^;]+;"]];
gate["two inherited spin-variable definitions",Length[diagnosticVariableRows]===2];
diagnosticSpinVariables=Block[{incomingQuark=True,outgoingQuark=True,inVariables,outVariables},
  ToExpression[StringRiffle[diagnosticVariableRows,"\n"],InputForm];Join[Rest[inVariables],Rest[outVariables]]];
gate["physical spin-variable inventory",Length[diagnosticSpinVariables]===
  Total[Length[#]-1&/@{diagnosticSector["IncomingSpinLabels"],diagnosticSector["OutgoingSpinLabels"]}]&&
  DuplicateFreeQ[diagnosticSpinVariables]];
diagnosticMetricRows=Select[real["Components"],#["Kind"]==="PhotonMetricD"&];
gate["one accepted dimensional metric",Length[diagnosticMetricRows]===1&&TrueQ[First[diagnosticMetricRows]["Accepted"]]];
diagnosticMetricReal=First[diagnosticMetricRows]["Branches"][1]["Regular"]/.
  Thread[diagnosticSpinVariables->0];
Print["DIMENSIONAL_METRIC_PHASE_BEGIN bytes ",ByteCount[diagnosticMetricReal]];
diagnosticMetricTimed=AbsoluteTiming[phaseProduct[strongFactor diagnosticMetricReal,phase,0,"dimensional metric"]];
diagnosticMetricCombined=Expand[diagnosticNormalize[diagnosticMetricTimed[[2]]]+First[diagnosticCDRCT],eps];
diagnosticPowers=Range[Min[Exponent[diagnosticMetricCombined,eps,Min],0],-1];
diagnosticMetricPoles=Association@Table[n->bounded[reduce[Coefficient[diagnosticMetricCombined,eps,n],
  diagnosticAssumptions],{"dimensional metric pole",n}],{n,diagnosticPowers}];
Print["DIMENSIONAL_METRIC_POLES ",InputForm[diagnosticMetricPoles]];
diagnosticExpectedContractions=LinearSolve[projectorWeights,Lookup[diagnosticResidual["Rows"],"Expected"]];
diagnosticMetricRemaining=bounded[reduce[Coefficient[diagnosticMetricCombined,eps,0]-
  First[diagnosticExpectedContractions],diagnosticAssumptions],"dimensional metric reference residual"];
Print["DIMENSIONAL_METRIC_REFERENCE_ZERO ",diagnosticMetricRemaining===0];
Print["DIMENSIONAL_METRIC_REMAINING ",InputForm[diagnosticMetricRemaining]];
diagnosticResult=<|"Schema"->"polarized-sidis-dimensional-contraction-diagnostic-v1","Channel"->channel,
  "SourceHash"->FileHash[diagnosticSource,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
  "ResidualInspectionHash"->FileHash[diagnosticResidualPath,"SHA256"],
  "ReferenceContractionResiduals"->diagnosticContractionResiduals,"CountertermDifferences"->diagnosticCTDifference,
  "PpResidualAfterCDRCounterterm"->diagnosticPPRemaining,"MetricCDRPoleResiduals"->diagnosticMetricPoles,
  "MetricCDRReferenceResidual"->diagnosticMetricRemaining,"MetricPhaseSeconds"->diagnosticMetricTimed[[1]],
  "SpinVariables"->diagnosticSpinVariables,"NativeVersions"->{$Version,$FeynCalcVersion},
  "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
diagnosticDir=FileNameJoin[{root,channel,"s14_dimensional_result"}];
If[!DirectoryQ[diagnosticDir],CreateDirectory[diagnosticDir,CreateIntermediateDirectories->True]];
diagnosticPath=FileNameJoin[{diagnosticDir,"s14_result.wl"}];
diagnosticSerialized="Uncompress["<>ToString[Compress[diagnosticResult],InputForm]<>"]\n";
gate["diagnostic file bound",StringLength[diagnosticSerialized]<128*1024^2];
Export[diagnosticPath<>".tmp",diagnosticSerialized,"Text"];
gate["diagnostic exact native reload",Get[diagnosticPath<>".tmp"]===diagnosticResult];
RenameFile[diagnosticPath<>".tmp",diagnosticPath,OverwriteTarget->True];
Export[FileNameJoin[{diagnosticDir,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_dimensional_contractions"];Quit[0];

(* Compare the saved finite residual with the executed dimensional counterterm change. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];checks=<||>;
sourcePath=FileNameJoin[{root,"common","s14_check_Hqg_reference_terms.wls"}];
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],
  Print["FAIL: ",name];Quit[1]];
gate["compute allocation",channel==="Hqg"&&StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[sourcePath,"Text"]]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,1200,
  gate[ToString[label,InputForm]<>" time limit",False]],2*1024^3,
  gate[ToString[label,InputForm]<>" memory limit",False]];
inspectionRelative=channel<>"/s14_reference_residual_result/s14_result.wl";
inspectionPath=FileNameJoin[{root,inspectionRelative}];inspection=Get[inspectionPath];
receipt=Import[FileNameJoin[{DirectoryName[inspectionPath],"s14_execution.json"}],"RawJSON"];
gate["accepted exact residual input",TrueQ[receipt["passed"]]&&receipt["job_id"]==="14884507"&&
  receipt["result_sha256"][inspectionRelative]===IntegerString[FileHash[inspectionPath,"SHA256"],16,64]&&
  inspection["Schema"]==="polarized-sidis-reference-residual-inspection-v1"&&inspection["Channel"]===channel&&
  inspection["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_inspect_Hqg_reference_residual.wls"}],"SHA256"]&&
  inspection["NativeVersions"]==={$Version,$FeynCalcVersion}&&And@@Values[inspection["Checks"]]];
basePath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];baseText=Import[basePath,"Text"];
gate["unchanged original assembly",inspection["BaselineSourceHash"]===FileHash[basePath,"SHA256"]];
normalizationDefinitions=StringRiffle[{
  "dimension=4-2eps;",
  "hardNormalization=(2Pi)^(-Limit[dimension,eps->0]);",
  "couplingSquare=Factor[gs^2/.First[Solve[gs^2==4Pi alphaS,gs]]];"},"\n"];
gate["exact original normalization definitions",And@@(StringCount[baseText,#]===1&/@StringSplit[normalizationDefinitions,"\n"])];
ToExpression[normalizationDefinitions,InputForm];
core=True;branches=<|1-><|"Delta"->1|>|>;
gate["inherited component normalization syntax",SyntaxQ[inspection["NormalizationSource"]]];
ToExpression[inspection["NormalizationSource"],InputForm];
normalizationFactor=branches[1]["Delta"];
basisPath=FileNameJoin[{root,"common","s02_result","s02_result.wl"}];basis=Get[basisPath];
currentPath=FileNameJoin[{root,channel,"s11_result","s11_result.wl"}];current=Get[currentPath];
previousPath=FileNameJoin[{root,channel,"s11_result","reference","before_dimensional_completion","s11_result.wl"}];
previous=Get[previousPath];
gate["same accepted subtraction input",FileHash[currentPath,"SHA256"]===inspection["InputHashes"][channel<>"/s11_result/s11_result.wl"]&&
  current["Channel"]===channel&&previous["Channel"]===channel&&And@@Values[current["Checks"]]&&And@@Values[previous["Checks"]]&&
  current["PreviousSubtractionHash"]===FileHash[previousPath,"SHA256"]&&
  current["PhotonLabels"]===basis["PhotonLabels"]&&current["SpinLabels"]===basis["SpinLabels"]&&
  FileHash[basisPath,"SHA256"]===inspection["InputHashes"]["common/s02_result/s02_result.wl"]];
u=First[FirstPosition[basis["SpinLabels"],"U"]];
difference=Map[Factor,current["Counterterms"]["Delta"]-previous["Counterterms"]["Delta"],{3}];
gate["actual saved dimensional correction",difference===current["CountertermDifference"]["Delta"]&&FreeQ[difference,eps|D]];
assumptions=inspection["PhysicalConditions"];
reduceTerms[value_]:=bounded[FullSimplify[FunctionExpand[value,assumptions],assumptions],"saved finite equation"];
rows=Table[
  input=inspection["Rows"][[n]];
  correction=(normalizationFactor inspection["PhotonWeights"][[n]].difference[[All,u,u]])/.
    t->input["Branch"] omega-s;
  gate["same branch variables "<>input["Hat"],FreeQ[correction,t]];
  residual=reduceTerms[input["Residual"]];
  remaining=reduceTerms[input["Residual"]-correction];
  Print["REFERENCE_TERM_COMPARISON ",input["Hat"]," residual ",InputForm[residual]];
  Print["REFERENCE_MINUS_DIMENSIONAL_CHANGE ",input["Hat"]," ",InputForm[remaining]];
  <|"Hat"->input["Hat"],"Branch"->input["Branch"],"Distribution"->input["Distribution"],
    "Residual"->residual,"DimensionalCountertermCorrection"->correction,
    "ResidualWithoutDimensionalChange"->remaining,"DimensionalChangeExplainsResidual"->(remaining===0)|>,
  {n,Length[inspection["Rows"]]}];
gate["finite evaluated comparison",FreeQ[rows,_Integrate|_Series|_Limit|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
result=<|"Schema"->"polarized-sidis-reference-term-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[sourcePath,"SHA256"],"InspectionHash"->FileHash[inspectionPath,"SHA256"],
  "SubtractionHash"->FileHash[currentPath,"SHA256"],"PreviousSubtractionHash"->FileHash[previousPath,"SHA256"],
  "AssemblySourceHash"->FileHash[basePath,"SHA256"],"NativeVersions"->{$Version,$FeynCalcVersion},
  "PhysicalConditions"->assumptions,"Normalization"->normalizationFactor,"Rows"->rows,"Checks"->checks,
  "ProductionChanged"->False,"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,channel,"s14_reference_terms_result"}];
If[!DirectoryQ[out],CreateDirectory[out,CreateIntermediateDirectories->True]];
file=FileNameJoin[{out,"s14_result.wl"}];
text=ToString[result,InputForm]<>"\n";gate["bounded readable comparison",StringLength[text]<128*1024^2];
Export[file<>".tmp",text,"Text"];gate["exact native comparison reload",Get[file<>".tmp"]===result];
RenameFile[file<>".tmp",file,OverwriteTarget->True];
Export[FileNameJoin[{out,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "dimensional_change_explains_residual"->Lookup[rows,"DimensionalChangeExplainsResidual"],
  "finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_Hqg_reference_terms"];Quit[0];

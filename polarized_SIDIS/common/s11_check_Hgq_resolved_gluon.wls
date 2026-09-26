(* Check the physical resolved-gluon route against the complete saved Hgq reference. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];checks=<||>;
studySource=FileNameJoin[{root,"common","s11_check_Hgq_resolved_gluon.wls"}];
gate[name_,test_]:=If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],
  Print["FAIL: ",name];Quit[1]];
gate["own compute allocation",channel==="Hgq"&&StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete comparison source",SyntaxQ[Import[studySource,"Text"]]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,1200,
  gate[ToString[label,InputForm]<>" time limit",False]],2*1024^3,
  gate[ToString[label,InputForm]<>" memory limit",False]];
zeroArray[value_]:=And@@(TrueQ[Factor[Together[#]]===0]&/@Flatten[{value}]);
inputPaths={};
read[relative_]:=Module[{path=FileNameJoin[{root,relative}]},
  AppendTo[inputPaths,path];If[StringEndsQ[path,".json"],Import[path,"RawJSON"],Get[path]]];
currentRelative=channel<>"/s11_result/reference/before_resolved_gluon/s11_result.wl";
previousRelative=channel<>"/s11_result/reference/before_dimensional_completion/s11_result.wl";
current=read[currentRelative];previous=read[previousRelative];
currentSource=FileNameJoin[{root,"common","s11_collinear_spin_convolutions.wls"}];
previousSource=FileNameJoin[{root,"common","s11_result","reference","s11_collinear_spin_convolutions_before_dimensional.wls"}];
gate["accepted current and original subtraction inputs",current["Channel"]===channel&&previous["Channel"]===channel&&
  And@@Values[current["Checks"]]&&And@@Values[previous["Checks"]]&&
  current["SourceHash"]===FileHash[currentSource,"SHA256"]&&previous["SourceHash"]===FileHash[previousSource,"SHA256"]&&
  current["PreviousSubtractionHash"]===FileHash[FileNameJoin[{root,previousRelative}],"SHA256"]&&
  current["Routes"]===previous["Routes"]&&current["Prefactor"]===previous["Prefactor"]&&current["MSPole"]===previous["MSPole"]];
Do[gate["unchanged subtraction equation input "<>name,
  FileHash[FileNameJoin[{root,name}],"SHA256"]===current["InputHashes"][name]],{name,Keys[current["InputHashes"]]}];
basis=read["common/s02_result/s02_result.wl"];kernels=read["common/s10_result/s10_result.wl"];
born=read[channel<>"/s03_result/s03_result.wl"];
gate["accepted own native spin operators",And@@Values[basis["Checks"]]&&And@@Values[kernels["Checks"]]&&
  And@@Values[born["Checks"]]&&basis["SpinLabels"]===current["SpinLabels"]&&kernels["SpinLabels"]===current["SpinLabels"]];
selfRoutes=Select[current["Routes"],#["KernelKey"]==="gg"&];
gate["one resolved gluon self route",Length[selfRoutes]===1&&
  First[selfRoutes]["BornChannel"]===channel&&First[selfRoutes]["Side"]==="PDF"];
self=First[selfRoutes];selfName=self["ReferenceName"];
delta=kernels["Responses"][self["KernelKey"]]["DeltaCoefficient"];
soft=kernels["Responses"][self["KernelKey"]]["SoftResidue"];
u=First[FirstPosition[basis["SpinLabels"],"U"]];
gate["native gluon endpoint is the physical spin identity",
  zeroArray[delta-delta[[u,u]]IdentityMatrix[Length[basis["SpinLabels"]]]]&&
  zeroArray[soft-soft[[u,u]]IdentityMatrix[Length[basis["SpinLabels"]]]]];
gate["original full dimensional Born endpoint retained",
  zeroArray[(#.delta&/@born["Response"])-delta[[u,u]]born["Response"]]&&
  zeroArray[(#.soft&/@born["Response"])-soft[[u,u]]born["Response"]]];
candidateRoutes=current["RouteConvolutionsD"];
AssociateTo[candidateRoutes,selfName->previous["RouteConvolutionsD"][selfName]];
Do[If[name=!=selfName,
  gate["unchanged nonself route "<>name,zeroArray[
    Values[current["RouteConvolutionsD"][name]]-Values[previous["RouteConvolutionsD"][name]]]]],
  {name,Keys[candidateRoutes]}];
candidateConvolutions=Association@Table[distribution->Map[Factor,
  Total[#[distribution]&/@Values[candidateRoutes]],{3}],{distribution,Keys[current["ConvolutionsD"]]}];
gate["exact original physical spin convolutions recovered",zeroArray[
  Values[candidateConvolutions]-Values[previous["ConvolutionsD"]]]];
correction=Association@Table[distribution->Map[Factor,
  previous["Counterterms"][distribution]-current["Counterterms"][distribution],{3}],
  {distribution,Keys[current["Counterterms"]]}];
gate["complete spin correction contains no regulator pole",FreeQ[correction,eps|D]];
gate["same executed subtraction source interface",
  StringCount[Import[previousSource,"Text"],"bornResponse = borns[key][\"Response\"];"]===1&&
  previous["ConvolutionsD"]===candidateConvolutions];
inspection=read[channel<>"/s14_reference_residual_result/s14_result.wl"];
termProof=read[channel<>"/s14_reference_terms_result/s14_result.wl"];
gate["exact established discrepancy input",termProof["InspectionHash"]===
  FileHash[FileNameJoin[{root,channel,"s14_reference_residual_result","s14_result.wl"}],"SHA256"]&&
  termProof["SubtractionHash"]===FileHash[FileNameJoin[{root,currentRelative}],"SHA256"]&&
  termProof["PreviousSubtractionHash"]===FileHash[FileNameJoin[{root,previousRelative}],"SHA256"]&&
  And@@Values[termProof["Checks"]]&&And@@Lookup[termProof["Rows"],"DimensionalChangeExplainsResidual"]&&
  termProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
assemblyPath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];assemblyText=Import[assemblyPath,"Text"];
gate["same finite assembly equations",inspection["BaselineSourceHash"]===FileHash[assemblyPath,"SHA256"]&&
  termProof["AssemblySourceHash"]===FileHash[assemblyPath,"SHA256"]];
domainLines=Select[StringSplit[assemblyText,"\n"],StringStartsQ[#,"physical="]||StringStartsQ[#,"softPhysical="]&];
gate["unique original domains",Length[domainLines]===2&&SyntaxQ[StringRiffle[domainLines,"\n"]]];
ToExpression[StringRiffle[domainLines,"\n"],InputForm];
reductionStart=StringPosition[assemblyText,"reduce[value_,assumptions_] :="];
reductionEnd=StringPosition[assemblyText,"\nzero[value_,assumptions_] :="];
gate["unique original finite reducer",Length[reductionStart]===1&&Length[reductionEnd]===1];
reductionText=StringTake[assemblyText,{First[First[reductionStart]],First[First[reductionEnd]]-1}];
gate["original finite reducer syntax",SyntaxQ[reductionText]];ToExpression[reductionText,InputForm];
hatConfig=read["common/s14_inputs.json"];
referenceHats=Association@KeyValueMap[Function[{name,relative},Module[{row},
  row=SelectFirst[hatConfig["files"],#["destination"]===relative&];
  gate["pinned final reference "<>name,IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===row["sha256"]];
  name->(read[relative]/.{Q2->Q^2,w->s23,Nc->SUNN})]],hatConfig["channels"][channel]["unpolarized_hats"]];
cache=FileNameJoin[{root,"cache","s14",channel,IntegerString[inspection["InputHash"],16]}];
photonWeights=inspection["PhotonWeights"];normalization=termProof["Normalization"];
checkpointHashes=<||>;comparisonRows={};
Do[
  distributionKeys=Keys[referenceHats[name]["NLO"][sign]];
  Do[
    Print["RESOLVED_GLUON_REFERENCE ",name," ",sign," ",distribution];
    values=Table[
      label={{a,u,u},sign,distribution};
      path=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
      saved=Get[path];
      gate["accepted own finite checkpoint "<>ToString[label,InputForm],
        saved["InputHash"]===inspection["InputHash"]&&saved["Label"]===label&&TrueQ[saved["Accepted"]]];
      AssociateTo[checkpointHashes,StringDrop[path,StringLength[root]+1]->FileHash[path,"SHA256"]];
      saved["Finite"],{a,Length[basis["PhotonLabels"]]}];
    change=If[KeyExistsQ[correction,distribution],correction[distribution][[All,u,u]],
      ConstantArray[0,Length[values]]]/.t->sign omega-s;
    candidate=normalization photonWeights[[First[FirstPosition[Keys[referenceHats],name]]]].(values+change);
    expected=referenceHats[name]["NLO"][sign][distribution];
    assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&If[sign===0,True,omega>0];
    difference=candidate-expected;
    functions=DeleteDuplicates[Cases[difference,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
    prepared=bounded[If[functions==={},Factor[difference],Collect[difference,functions,Factor]],"reference precollection"];
    gate["exact finite input reconstruction",bounded[Together[difference-prepared],"reference reconstruction"]===0];
    residual=bounded[reduce[prepared,assumptions],"original finite reduction"];
    residual=If[residual===0,0,bounded[FullSimplify[FunctionExpand[residual,assumptions],assumptions],"finite function identities"]];
    AppendTo[comparisonRows,<|"Hat"->name,"Branch"->sign,"Distribution"->distribution,"Residual"->residual,"Equal"->(residual===0)|>];
    Print["RESOLVED_GLUON_REFERENCE_RESIDUAL ",name," ",sign," ",distribution," ",InputForm[residual]];
    Clear[saved,values,candidate,expected,difference,prepared];ClearSystemCache[],
    {distribution,distributionKeys}],{name,Keys[referenceHats]},{sign,Keys[referenceHats[name]["NLO"]]}];
allEqual=And@@Lookup[comparisonRows,"Equal"];
inputPaths=DeleteDuplicates[Join[inputPaths,{currentSource,previousSource,assemblyPath}]];
result=<|"Schema"->"polarized-sidis-resolved-gluon-subtraction-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[studySource,"SHA256"],"InputHashes"->Association[
    (StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths],
  "OriginalAssemblyInputHash"->inspection["InputHash"],"CheckpointHashes"->checkpointHashes,
  "NativeVersions"->{$Version,$FeynCalcVersion},"SelfRoute"->self,"RouteConvolutionsD"->candidateRoutes,
  "ConvolutionsD"->candidateConvolutions,"Counterterms"->previous["Counterterms"],"Correction"->correction,
  "Comparisons"->comparisonRows,"AllReferenceComponentsRestored"->allEqual,"Checks"->checks,
  "Accepted"->allEqual,"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,channel,"s11_resolved_gluon_result"}];
If[!DirectoryQ[out],CreateDirectory[out,CreateIntermediateDirectories->True]];
path=FileNameJoin[{out,"s11_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded comparison export",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];
gate["exact native comparison reload",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{out,"s11_checks.json"}],<|"checks"->checks,"all_reference_components_restored"->allEqual,
  "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
gate["all finite reference components restored",allEqual];
Print["PASS: s11_check_Hgq_resolved_gluon"];Quit[0];

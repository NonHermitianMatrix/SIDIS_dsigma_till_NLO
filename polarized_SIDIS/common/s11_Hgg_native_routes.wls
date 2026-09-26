(* Apply the accepted native MS operators to Hgg's own saved Born routes. *)
$HistoryLength=0;nativeRouteSource=FileNameJoin[{Directory[],"common","s11_Hgg_native_routes.wls"}];
nativeRouteBase=FileNameJoin[{Directory[],"common","s11_small_collinear_spin.wls"}];
If[IntegerString[FileHash[nativeRouteBase,"SHA256"],16,64]=!=
 "b47acf502782cf5da4720163519a419c81a1a7f750679441a32685da2838f1af"||
 !SyntaxQ[Import[nativeRouteSource,"Text"]],Quit[1]];
nativeRouteText=Import[nativeRouteBase,"Text"];
nativeRouteBoundary="contributions = <||>; evanescentContributions = <||>; completedStates = <||>;";
If[StringCount[nativeRouteText,nativeRouteBoundary]=!=1,Quit[1]];
nativeRoutePrefix=First[StringSplit[nativeRouteText,nativeRouteBoundary]];
If[!SyntaxQ[nativeRoutePrefix],Quit[1]];ToExpression[nativeRoutePrefix,InputForm];
gate["own native Hgg subtraction",channel==="Hgg"];
nativeRouteRead[relative_]:=Module[{path=FileNameJoin[{root,relative}]},AppendTo[inputPaths,path];
 If[StringEndsQ[relative,".json"],Import[path,"RawJSON"],Get[path]]];
nativeRouteCurrentRelative=channel<>"/s11_result/s11_result.wl";
nativeRouteCurrent=nativeRouteRead[nativeRouteCurrentRelative];
nativeRouteCurrentReceipt=nativeRouteRead[channel<>"/s11_result/s11_execution.json"];
gate["accepted own complete subtraction",TrueQ[nativeRouteCurrentReceipt["passed"]]&&
 nativeRouteCurrentReceipt["result_sha256"][nativeRouteCurrentRelative]===IntegerString[FileHash[FileNameJoin[{root,nativeRouteCurrentRelative}],"SHA256"],16,64]&&
 nativeRouteCurrent["SourceHash"]===FileHash[nativeRouteBase,"SHA256"]&&nativeRouteCurrent["Channel"]===channel&&
 And@@Values[nativeRouteCurrent["Checks"]]&&nativeRouteCurrent["Routes"]===routes&&
 nativeRouteCurrent["SpinLabels"]===labels&&nativeRouteCurrent["PhotonLabels"]===photonLabels&&
 nativeRouteCurrent["BornCoupling"]===bornCoupling&&nativeRouteCurrent["PhaseCT"]===reference["PhaseCT"]];
KeyValueMap[gate["unchanged own subtraction input "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,
 nativeRouteCurrent["InputHashes"]];
nativeRouteTransferRelative=channel<>"/s10_offdiagonal_result/s10_result.wl";
nativeRouteTransfer=nativeRouteRead[nativeRouteTransferRelative];
nativeRouteTransferReceipt=nativeRouteRead[channel<>"/s10_offdiagonal_result/s10_execution.json"];
nativeRouteTransferSource=FileNameJoin[{root,"common","s10_Hgg_offdiagonal_transfer.wls"}];
gate["accepted complete native off-diagonal operators",TrueQ[nativeRouteTransferReceipt["passed"]]&&
 nativeRouteTransferReceipt["result_sha256"][nativeRouteTransferRelative]===IntegerString[FileHash[FileNameJoin[{root,nativeRouteTransferRelative}],"SHA256"],16,64]&&
 nativeRouteTransfer["Schema"]==="polarized-sidis-offdiagonal-transfer-v1"&&TrueQ[nativeRouteTransfer["Accepted"]]&&
 And@@Values[nativeRouteTransfer["Checks"]]&&nativeRouteTransfer["SourceHash"]===FileHash[nativeRouteTransferSource,"SHA256"]&&
 nativeRouteTransfer["NativeVersions"]==={$Version,$FeynCalcVersion}&&nativeRouteTransfer["SpinLabels"]===labels];
KeyValueMap[gate["unchanged off-diagonal input "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,
 nativeRouteTransfer["InputHashes"]];
nativeRouteOriginal=<||>;nativeRouteExtra=<||>;nativeRouteEvanescent=<||>;
Do[
 key=route["Born"];side=route["Side"];name=route["Name"];
 Print["OWN_NATIVE_ROUTE ",name];
 completedBorn=completeIntermediateBorn[borns[key],side];
 mapped=bounded[simplify[completedBorn["Response"]/.mapRules[side]],{name,"own mapped Born"}];
 leading=kernels["Responses"][route["Kernel"]]["Kernel"];
 transfer=nativeRouteTransfer[side][route["Kernel"]];
 gate[name<>" identical leading spin operator",zeroArray[leading-transfer["LeadingKernel"]]];
 deltaKernel=Map[Factor,transfer["MSOperatorD"]-leading,{2}];
 gate[name<>" exact native operator difference",zeroArray[deltaKernel-transfer["KernelDifferenceD"]]];
 leadingAtRoot=leading/.z->roots[side];deltaAtRoot=deltaKernel/.z->roots[side];
 originalValue=bounded[Map[Factor,measureWeights[side] If[side==="PDF",
  (Dot[#,leadingAtRoot]&/@mapped),(Dot[leadingAtRoot,#]&/@mapped)],{3}],{name,"original route"}];
 gate[name<>" whole accepted route reproduced",zeroArray[
  Take[originalValue,Length[photonLabels]]-nativeRouteCurrent["RouteConvolutionsD"][name]]];
 AssociateTo[nativeRouteOriginal,name->Take[originalValue,Length[photonLabels]]];
 extraValue=bounded[Map[Factor,measureWeights[side] If[side==="PDF",
  (Dot[#,deltaAtRoot]&/@mapped),(Dot[deltaAtRoot,#]&/@mapped)],{3}],{name,"native route difference"}];
 gate[name<>" unchanged physical-dimension convolution",zeroArray[Map[Limit[#,D->Length[realFrame[p]]]&,extraValue,{3}]]];
 gate[name<>" no new soft endpoint",zeroArray[bounded[FullSimplify[
  Limit[s23 extraValue,s23->0],endpointRegion],{name,"native endpoint"}]]];
 gate[name<>" exact evaluated additional convolution",FreeQ[extraValue,
  _Missing|_Dot|_Integrate|_Limit|_ConditionalExpression|_Piecewise|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
 AssociateTo[nativeRouteExtra,name->Take[extraValue,Length[photonLabels]]];
 AssociateTo[nativeRouteEvanescent,name->Last[extraValue]],{route,routes}];
nativeRouteOriginalRegular=Map[Factor,Total[Values[nativeRouteOriginal]],{3}];
gate["complete own original convolution reproduced",zeroArray[
 nativeRouteOriginalRegular-nativeRouteCurrent["ConvolutionsD"]["Regular"]]];
nativeRouteExpand[value_]:=Map[bounded[Normal[Series[reference["PhaseCT"] bornCoupling (#/.D->4-2eps),
 {eps,0,0}]],"own native counterterm expansion"]&,value,{3}];
nativeRouteOriginalCounterterm=nativeRouteExpand[nativeRouteOriginalRegular];
gate["complete own accepted counterterm reproduced",zeroArray[
 nativeRouteOriginalCounterterm-nativeRouteCurrent["Counterterms"]["Regular"]]];
nativeRouteAdded=Map[Factor,Total[Values[nativeRouteExtra]],{3}];
nativeRouteCorrection=Map[Factor,nativeRouteExpand[nativeRouteAdded],{3}];
gate["complete native counterterm change is finite",FreeQ[nativeRouteCorrection,
 eps|D|_Missing|_Integrate|_Limit|_Series|_SeriesData|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
nativeRouteCandidateRegular=Map[Factor,nativeRouteOriginalRegular+nativeRouteAdded,{3}];
nativeRouteCandidateCounterterm=nativeRouteExpand[nativeRouteCandidateRegular];
gate["full native expansion equals accepted counterterm plus addition",zeroArray[
 nativeRouteCandidateCounterterm-nativeRouteOriginalCounterterm-nativeRouteCorrection]];
nativeRouteCandidateRoutes=Association@KeyValueMap[#1->Map[Factor,#2+nativeRouteExtra[#1],{3}]&,nativeRouteOriginal];
nativeRouteConvolutions=Join[nativeRouteCurrent["ConvolutionsD"],<|"Regular"->nativeRouteCandidateRegular|>];
nativeRouteCounterterms=Join[nativeRouteCurrent["Counterterms"],<|"Regular"->nativeRouteCandidateCounterterm|>];
nativeRouteExtraPhoton=Association@KeyValueMap[#1->Map[Factor,#2+nativeRouteEvanescent[#1],{2}]&,
 nativeRouteCurrent["EvanescentPhotonConvolutionsD"]];
inputPaths=DeleteDuplicates[Join[inputPaths,{nativeRouteSource,nativeRouteBase,nativeRouteTransferSource},
 FileNameJoin[{root,#}]&/@Keys[nativeRouteCurrent["InputHashes"]],
 FileNameJoin[{root,#}]&/@Keys[nativeRouteTransfer["InputHashes"]]]];
nativeRouteInputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths];
nativeRouteResult=Join[nativeRouteCurrent,<|"RouteConvolutionsD"->nativeRouteCandidateRoutes,
 "ConvolutionsD"->nativeRouteConvolutions,"Counterterms"->nativeRouteCounterterms,
 "EvanescentPhotonConvolutionsD"->nativeRouteExtraPhoton,"NativeRouteAdditionsD"->nativeRouteExtra,
 "NativeCountertermDifference"->nativeRouteCorrection,"FiniteDimensionalSchemeConversionApplied"->True,
 "IntermediateStateConvention"->"Accepted CDR intermediate completeness with native MS off-diagonal operators",
 "SchemeStatus"->"Native crossed PDF and FF operators minus CDR regulator remainders; axial conversion deferred to S15",
 "AcceptedForProduction"->True,"OwnAcceptedSubtractionComparison"->True,
 "OriginalSubtractionHash"->FileHash[FileNameJoin[{root,nativeRouteCurrentRelative}],"SHA256"],
 "NativeTransferHash"->FileHash[FileNameJoin[{root,nativeRouteTransferRelative}],"SHA256"],
 "SourceHash"->FileHash[nativeRouteSource,"SHA256"],"BaseSourceHash"->FileHash[nativeRouteBase,"SHA256"],
 "InputHashes"->nativeRouteInputHashes,"Checks"->Join[nativeRouteCurrent["Checks"],checks],
 "FiniteNLOFHatsComputed"->False,"CompletePoleCancellationChecked"->False|>];
nativeRouteDirectory=FileNameJoin[{root,channel,"s11_native_result"}];
If[!DirectoryQ[nativeRouteDirectory],CreateDirectory[nativeRouteDirectory]];
nativeRouteOutput=FileNameJoin[{nativeRouteDirectory,"s11_result.wl"}];put[nativeRouteResult,nativeRouteOutput];
gate["bounded native subtraction export",FileByteCount[nativeRouteOutput]<128*1024^2];
gate["exact native subtraction reload",Get[nativeRouteOutput]===nativeRouteResult];
Export[FileNameJoin[{nativeRouteDirectory,"s11_checks.json"}],<|"checks"->checks,
 "changed_indices"->Position[nativeRouteCorrection,value_/;value=!=0,{3},Heads->False],
 "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s11_Hgg_native_routes"];Quit[0];

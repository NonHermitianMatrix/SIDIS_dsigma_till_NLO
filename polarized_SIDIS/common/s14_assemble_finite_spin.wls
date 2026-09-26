(* Componentwise adaptation of the pinned GitHub S20 assembly.
   This stage retains the minimally subtracted BMHV scheme explicitly. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];
sourcePath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];checks=<||>;
gate[name_,test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks,name],Print["PASS: ",name]];AssociateTo[checks,name->True],
  Print["FAIL: ",name];If[TrueQ[$KernelID>0],Throw[$Failed,"S14Failure"],CloseKernels[];Quit[1]]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[sourcePath,"Text"]]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[ToString[label,InputForm]<>" time limit",False]],2*1024^3,
  gate[ToString[label,InputForm]<>" memory limit",False]];
configPath=FileNameJoin[{root,"common","s14_inputs.json"}];config=Import[configPath,"RawJSON"];
basePath=FileNameJoin[{root,"common","s01_inputs.json"}];base=Import[basePath,"RawJSON"];
gate["known assembly channel",KeyExistsQ[config["channels"],channel]];
core=base["channel_contracts"][channel]["amplitude_schema"]==="core";
inputPaths={configPath,basePath};
readPinned[relative_] := Module[{row,path},
  row=SelectFirst[config["files"],#["destination"]===relative&];path=FileNameJoin[{root,relative}];
  gate["pinned "<>relative,IntegerString[FileHash[path,"SHA256"],16,64]===row["sha256"]];
  AppendTo[inputPaths,path];If[StringEndsQ[path,".json"],Import[path,"RawJSON"],Get[path]]];
referenceSource=FileNameJoin[{root,"common","s14_result","reference","s20_final_hats.wl"}];
referenceRow=SelectFirst[config["files"],#["destination"]==="common/s14_result/reference/s20_final_hats.wl"&];
gate["pinned original final assembly",IntegerString[FileHash[referenceSource,"SHA256"],16,64]===referenceRow["sha256"]];
AppendTo[inputPaths,referenceSource];
loadResult[relative_] := Module[{path=FileNameJoin[{root,relative}]},
  gate["required input "<>relative,FileExistsQ[path]];AppendTo[inputPaths,path];Get[path]];
basis=loadResult["common/s02_result/s02_result.wl"];
library=loadResult["common/s06_result/s06_result.wl"];
gate["accepted spin basis and scalar library",And@@Values[basis["Checks"]]&&And@@Values[library["Checks"]]];
readLibrary[stage_] := Module[{row=library["Library"][stage],path,value},
  path=FileNameJoin[{root,row["File"]}];gate[stage<>" pinned library geometry",
    IntegerString[FileHash[path,"SHA256"],16,64]===row["SHA256"]];
  AppendTo[inputPaths,path];value=Get[path];value/.{Q2->Q^2,w->s23}];
geometry=readLibrary["s02"];cutGeometry=readLibrary["s08"];
real=loadResult[channel<>"/s12_result/s12_result.wl"];
spinReal=loadResult[channel<>"/s05_result/s05_result.wl"];
subtraction=loadResult[channel<>"/s11_result/s11_result.wl"];
gate["accepted integrated real tensor",real["Schema"]==="polarized-sidis-real-distributions-v1"&&
  real["Channel"]===channel&&TrueQ[real["CutMeasureIntegrated"]]&&TrueQ[real["MasterExpansionDepthChecked"]]&&
  And@@Values[real["Checks"]]&&AllTrue[real["Components"],TrueQ[#["Accepted"]]&]];
gate["accepted real tensor and subtraction",spinReal["Channel"]===channel&&subtraction["Channel"]===channel&&
  And@@Values[spinReal["Checks"]]&&And@@Values[subtraction["Checks"]]];
gate["same physical spin and photon bases",real["PhotonLabels"]===basis["PhotonLabels"]&&
  real["SpinLabels"]===basis["SpinLabels"]&&subtraction["PhotonLabels"]===real["PhotonLabels"]&&
  subtraction["SpinLabels"]===real["SpinLabels"]];
gate["matching explicit regulator scheme",real["Gamma5Scheme"]==="BMHV"&&subtraction["Gamma5Scheme"]==="BMHV"];
physical=Q>0&&s>s23>0&&s23-Q^2-s<t<-Q^2 s23/s&&mu>0&&mu2>0&&B>0&&SUNN>1;
softPhysical=Q>0&&s>0&&t<0&&Q^2+s+t>0&&mu>0&&mu2>0&&B>0&&SUNN>1;
dimension=4-2eps;
stateNormalization=(2Pi)^D Times@@Table[(2Pi)^(-(D-1)),{momentum,geometry["CutMomenta"]}];
stateNormalization=FullSimplify[stateNormalization/.D->dimension];
angularJacobian=FullSimplify[cutGeometry["RadialPrefactor"]
  (cutGeometry["SphereAreaDefinition"]/.nn->D-1-Length[{theta,phi}]/.D->dimension)];
hardNormalization=(2Pi)^(-Limit[dimension,eps->0]);
couplingSquare=Factor[gs^2/.First[Solve[gs^2==4Pi alphaS,gs]]];
phaseInput=readPinned[config["channels"][channel]["phase"]];
sourcePhase=ToExpression[phaseInput["DefinitionExpression"]]/.{Q2->Q^2,w->s23};
projectorReference=readPinned[config["channels"][channel]["projectors"]];
referenceHats=Map[readPinned,config["channels"][channel]["unpolarized_hats"]]/.{Q2->Q^2,w->s23,Nc->SUNN};
gate["reference hat symbols match inherited conventions",FreeQ[referenceHats,Q2|w|Nc|Global`SUNN|Global`Nf]];
projectorDefinitions=If[core,
  ({f1,f2}/.projectorReference["ProjectorsEpsilon"]/.eps->0/.projectorReference["BornKinematics"])/.
    {hg->metricContraction,hpp->incomingContraction},
  ({f1,f2}/.projectorReference["Projectors"])/.
    {D->4,xh->Q^2/(s+Q^2),Hg->metricContraction,Hpp->incomingContraction}]/.Q2->Q^2;
gate["original projectors fully resolved",FreeQ[projectorDefinitions,f1|f2|hg|hpp|Hg|Hpp|xh|eps|D|_Missing]];
projectorWeights=Table[Coefficient[expression,symbol],{expression,projectorDefinitions},
  {symbol,{metricContraction,incomingContraction}}];
gate["linear original scalar projectors",Expand[projectorDefinitions-
  projectorWeights.{metricContraction,incomingContraction}]===ConstantArray[0,Length[projectorDefinitions]]];
photonAxes={eL,eX,eY};
realFrame=spinReal["Frame"];
frameMatrix=Transpose[realFrame/@Append[photonAxes,q]];
incomingExpansion=LinearSolve[frameMatrix,realFrame[p]];
gate["incoming vector reconstructed in photon frame",Expand[frameMatrix.incomingExpansion-realFrame[p]]===
  ConstantArray[0,Length[realFrame[p]]]];
incomingComponents=Take[incomingExpansion,Length[photonAxes]];
metricWeights=Tr[basis["PhotonMetric"].#]&/@basis["PhotonBasis"];
incomingWeights=Factor[incomingComponents.#.incomingComponents]&/@basis["PhotonBasis"];
hatPhotonWeights=Map[Factor,projectorWeights.{metricWeights,incomingWeights},{2}];
gate["original hat weights are independent of recoil and branch",FreeQ[hatPhotonWeights,t|s23|omega]];
flavorDomain=True;weights=<||>;bookkeeping=<||>;strongFactor=1;
If[core,
  virtual=loadResult[channel<>"/s13_result/s13_result.wl"];
  born=loadResult[channel<>"/s03_result/s03_result.wl"];
  gate["accepted renormalized virtual and Born tensors",virtual["Schema"]==="polarized-sidis-renormalized-virtual-v1"&&
    virtual["Channel"]===channel&&TrueQ[virtual["UVRenormalized"]]&&TrueQ[virtual["IntegratedWardChecksPassed"]]&&
    virtual["Gamma5Scheme"]==="BMHV"&&And@@Values[virtual["Checks"]]&&And@@Values[born["Checks"]]];
  gate["core counterterm normalization",subtraction["Schema"]==="polarized-sidis-collinear-convolutions-v1"&&
    !TrueQ[Lookup[subtraction,"CountertermsIncludePhaseAndCouplings",False]]];
  definitions=readPinned[config["channels"][channel]["bookkeeping"]];bookkeeping=definitions["Bookkeeping"];
  phase=mu^(2eps)stateNormalization;
  gate["original core phase normalization",bounded[FullSimplify[FunctionExpand[
    phase angularJacobian-sourcePhase s23^-eps],physical&&Element[eps,Reals]],"core normalization"]===0];
  If[channel==="Hqq",
    ranges=DeleteDuplicates[#[[2]]&/@Values[bookkeeping["OtherChargeMomentDefinitions"]]];
    gate["one inherited flavor range",Length[ranges]===1];range=First[ranges];
    flavorDomain=Reduce[Element[range[[3]],Integers]&&range[[2]]<=bookkeeping["ObservedFlavor"]<=range[[3]],range[[3]],Integers];
    originalCount=bookkeeping["DistinctFlavorMultiplicity"];
    canonicalCount=If[Head[originalCount]===Piecewise,originalCount[[1,1,1]],originalCount];
    gate["original flavor count on its complete domain",Reduce[flavorDomain&&originalCount!=canonicalCount,range[[3]],Integers]===False];
    weights=Map[FullSimplify[#["FlavorWeight"]/.originalCount->canonicalCount,flavorDomain]&,bookkeeping["Components"]]],
  gate["small counterterm normalization",subtraction["Schema"]==="polarized-sidis-small-collinear-convolutions-v1"&&
    TrueQ[subtraction["CountertermsIncludePhaseAndCouplings"]]];
  generated=loadResult[base["channel_contracts"][channel]["amplitude_file"]];
  fields=Lookup[generated,"outgoing_fields",Missing["ReadGeneratedProcess"]];
  If[MissingQ[fields],options=List@@Head[generated["graphs"]];
    fields=FirstCase[options,HoldPattern[Rule[key_Symbol,process_Rule]]/;SymbolName[key]==="Process":>Last[process],Missing["ProcessFields"]]];
  gate["generated fields match momenta",ListQ[fields]&&Length[fields]===Length[generated["outgoing"]]];
  observed=Position[generated["outgoing"],k1];gate["one tagged momentum",Length[observed]===1];
  spectators=Delete[fields,observed];weight=1/(Times@@(Factorial/@Values[Counts[spectators]]));
  gate["one small-channel sector",Length[Keys[real["Bookkeeping"]]]===1];
  sectorBook=First[Values[real["Bookkeeping"]]];
  gate["spectator weight matches contracted tensor",weight===sectorBook["TagWeight"]&&!TrueQ[sectorBook["TagWeightAppliedToTensor"]]];
  sourcePhase=sourcePhase/.symmetryWeight->weight;
  phase=weight mu2^(2eps)hardNormalization stateNormalization;
  gate["original small-channel phase normalization",bounded[FullSimplify[FunctionExpand[
    phase angularJacobian-sourcePhase/Pi],physical&&Element[eps,Reals]],"small normalization"]===0];
  strongFactor=Times@@Table[gs^Last[sectorBook["AmplitudeCouplingPowers"]],{factor,{"amplitude","conjugate amplitude"}}];
  gate["real and subtraction coupling degrees match",Exponent[strongFactor,gs]===
    Exponent[subtraction["PhaseCT"]subtraction["BornCoupling"],gs]]];
gate["no mixed color symbol contexts",FreeQ[{real,subtraction,bookkeeping},Global`SUNN|Global`Nf]];
sourceHash=FileHash[sourcePath,"SHA256"];
inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@DeleteDuplicates[inputPaths]];
inputHash=Hash[{sourceHash,inputHashes,$Version,$FeynCalcVersion},"SHA256"];
cache=FileNameJoin[{root,"cache","s14",channel,IntegerString[inputHash,16]}];
If[!DirectoryQ[cache],CreateDirectory[cache,CreateIntermediateDirectories->True]];
reduce[value_,assumptions_] := Module[{expression,functions},
  expression=Refine[value,assumptions];
  expression=PowerExpand[expression/.Log[arg_]:>Log[Factor[arg]],Assumptions->assumptions];
  functions=DeleteDuplicates[Cases[expression,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
  Collect[Expand[expression],functions,Factor]];
zero[value_,assumptions_] := Module[{expression=reduce[value,assumptions]},expression===0||FullSimplify[expression,assumptions]===0];
epsSeries[value_] := Normal[Series[value,{eps,0,0}]];
boundary[value_,assumptions_] := bounded[reduce[Limit[value,omega->0,
  Direction->"FromAbove",Assumptions->assumptions],assumptions],"common branch boundary"];
weighted[expression_,sector_] := If[channel=!= "Hqq",expression,Module[{rows,monomials,names},
  gate["polynomial distinct-flavor charge dependence",PolynomialQ[expression,chargeRatio]];
  rows=CoefficientRules[expression,{chargeRatio}];monomials=chargeRatio^First[First[#]]&/@rows;
  gate["exact charge decomposition",Expand[expression-Total[MapThread[Times,{Last/@rows,monomials}]]]===0];
  names=(sector<>"_Charge"<>ToString[First[First[#]]])&/@rows;
  gate["all charge components have inherited weights",AllTrue[names,KeyExistsQ[weights,#]&]];
  Total[MapThread[Times,{Last/@rows,weights/@names}]]]];
physicalComponents=Select[real["Components"],#["Kind"]==="ExtendedResponse"&&
  And@@Thread[Rest[#["Index"]]<=Length[basis["SpinLabels"]]]&];
componentKeys={#["Sector"],#["Index"]}&/@physicalComponents;
gate["unique integrated physical components",DuplicateFreeQ[componentKeys]];
componentRows[index_] := Select[physicalComponents,#["Index"]===index&];
realBranch[index_,sign_,distribution_] := Total[weighted[#["Branches"][sign][distribution],#["Sector"]]&/@componentRows[index]];
realOrdinary[index_] := Total[weighted[#["Ordinary"],#["Sector"]]&/@componentRows[index]];
virtualValue[index_] := If[!core,0,With[{key={"ExtendedResponse",index}},
  If[KeyExistsQ[virtual["Components"],key],2Pi virtual["Components"][key]["RenormalizedVirtual"]/.virtual["Regulator"]->eps,0]]];
subtractionValue[index_,distribution_] := If[distribution==="L1",0,Extract[subtraction["Counterterms"][distribution],index]];
finitePart[parts_,label_,assumptions_] := Module[{file,saved,combined,powers,residues,value},
  file=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
  saved=If[FileExistsQ[file],Get[file],<||>];
  If[Lookup[saved,"InputHash",None]===inputHash&&TrueQ[Lookup[saved,"Accepted",False]],Return[saved["Finite"]]];
  Print["POLE_ASSEMBLY ",label];
  gate["finite symbolic input parts",FreeQ[parts,_Integrate|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
  combined=Expand[Total[parts],eps];
  powers=Range[Min[Append[Cases[combined,Power[eps,n_Integer]/;n<0:>n,Infinity],0]],-1];
  gate["evaluated Laurent polynomial",PolynomialQ[Expand[eps^(-Min[Append[powers,0]])combined],eps]];
  residues=Association@Table[n->bounded[reduce[Coefficient[combined,eps,n],assumptions],{label,"pole simplification",n}],{n,powers}];
  put[<|"Label"->label,"PoleResiduals"->residues,"InputParts"->parts,"InputHash"->inputHash,"Accepted"->False|>,file];
  Do[gate[ToString[label,InputForm]<>" pole "<>ToString[n],bounded[zero[residues[n],assumptions],{label,"pole cancellation",n}]],{n,powers}];
  value=Coefficient[combined,eps,0];
  gate["finite evaluated tensor",FreeQ[value,eps|_Integrate|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
  put[<|"Label"->label,"PoleResiduals"->Map[Factor,residues],"Finite"->value,"InputHash"->inputHash,"Accepted"->True|>,file];value];
distributions={"Delta","L0","L1","Regular"};
assemble[index_] := Catch[Block[{checks=<||>},Module[
  {branches,middle,assumptions,virtualBoundary,limits,commonReal,value,normalization},
  branches=Association@Table[sign->Association@Table[
    assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&omega>0&&flavorDomain;
    value=finitePart[{bounded[epsSeries[phase strongFactor realBranch[index,sign,distribution]],{index,"real phase"}],
      If[distribution==="Delta",virtualValue[index],0]/.t->sign omega-s,
      subtractionValue[index,distribution]/.t->sign omega-s},{index,sign,distribution},assumptions];
    distribution->value,{distribution,distributions}],{sign,{1,-1}}];
  virtualBoundary=boundary[virtualValue[index]/.t->omega-s,
    (softPhysical/.t->-s)&&flavorDomain&&Element[eps,Reals]&&eps!=0];
  limits=Association@Table[distribution->Table[boundary[realBranch[index,sign,distribution],
    (softPhysical/.t->-s)&&flavorDomain],{sign,{1,-1}}],{distribution,{"Delta","L0","L1"}}];
  KeyValueMap[gate["real endpoint branches share a boundary",zero[Subtract@@#2,(softPhysical/.t->-s)&&flavorDomain]]&,limits];
  commonReal=Map[First,limits];
  AssociateTo[commonReal,"Regular"->((realOrdinary[index]/.t->-s)-commonReal["L0"]/s23-commonReal["L1"]Log[s23/B]/s23)];
  middle=Association@Table[assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->-s)&&flavorDomain;
    distribution->finitePart[{bounded[epsSeries[phase strongFactor commonReal[distribution]],{index,"boundary real phase"}],
      If[distribution==="Delta",virtualBoundary,0],subtractionValue[index,distribution]/.t->-s},
      {index,0,distribution},assumptions],{distribution,distributions}];
  branches=Join[branches,<|0->middle|>];
  normalization=If[core,eq^2 couplingSquare^2 hardNormalization,1];
  branches=Map[Function[branch,Map[normalization #&,branch]],branches];
  If[!core,branches=branches/.gs->Sqrt[couplingSquare];
    If[channel==="Hgg",branches=branches/.eq^2->chargeSum];
    If[channel==="Hqqbar",branches=branches/.eq^2->eq2]];
  gate["finite physical component",FreeQ[branches,eps|gs|_GLI|_CutIntegral|_PaVe|_Integrate|_Series|_Limit|_Real|Indeterminate|_DirectedInfinity]];
  <|"Index"->index,"Branches"->branches,"Checks"->checks,"Accepted"->True|>]],"S14Failure"];
indices=Tuples[{Range[Length[basis["PhotonLabels"]]],Range[Length[basis["SpinLabels"]]],Range[Length[basis["SpinLabels"]]]}];
values=assemble/@indices;
gate["all physical components finite",FreeQ[values,$Failed|$Aborted]&&AllTrue[values,AssociationQ]&&And@@Lookup[values,"Accepted"]];
gate["all component checks accepted",And@@Flatten[Values[#["Checks"]]&/@values]];
componentValues=AssociationThread[Lookup[values,"Index"],Lookup[values,"Branches"]];
dimensions={Length[basis["PhotonLabels"]],Length[basis["SpinLabels"]],Length[basis["SpinLabels"]]};
leadingResponse=If[core,eq^2 couplingSquare 2Pi hardNormalization born["ResponseD4"],ConstantArray[0,dimensions]];
finiteResponse=Association@Table[sign->Association@Table[distribution->Table[
  componentValues[{a,j,i}][sign][distribution],{a,dimensions[[1]]},{j,dimensions[[2]]},{i,dimensions[[3]]}],
  {distribution,distributions}],{sign,{1,-1,0}}];
hats=AssociationThread[{"F1","F2"},Table[<|"LODelta"->Table[
  Sum[hatPhotonWeights[[hatIndex,a]]leadingResponse[[a,j,i]],{a,dimensions[[1]]}],
  {j,dimensions[[2]]},{i,dimensions[[3]]}],
  "NLO"->Association@Table[sign->Association@Table[distribution->Table[
    Sum[hatPhotonWeights[[hatIndex,a]]finiteResponse[sign][distribution][[a,j,i]],{a,dimensions[[1]]}],
    {j,dimensions[[2]]},{i,dimensions[[3]]}],{distribution,distributions}],{sign,{1,-1,0}}]|>,
  {hatIndex,Length[projectorDefinitions]}]];
gate["finite original hat projections",FreeQ[hats,eps|gs|f1|f2|metricContraction|incomingContraction|
  _Missing|_GLI|_CutIntegral|_PaVe|_Integrate|_Series|_Limit|_Real|Indeterminate|_DirectedInfinity]];
uPosition=First[FirstPosition[basis["SpinLabels"],"U"]];
Do[
  expectedLeading=If[core,referenceHats[name]["LODelta"],0];
  gate[name<>" original unpolarized Born hat",bounded[zero[
    hats[name]["LODelta"][[uPosition,uPosition]]-expectedLeading,softPhysical&&flavorDomain],
    name<>" Born hat comparison"]];
  Do[expected=If[core,referenceHats[name]["NLO"][sign][distribution],
      If[distribution==="Regular",referenceHats[name]/.t->sign omega-s,0]];
    assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&
      If[sign===0,True,omega>0]&&flavorDomain;
    gate[name<>" original unpolarized finite hat "<>ToString[{sign,distribution},InputForm],bounded[zero[
      hats[name]["NLO"][sign][distribution][[uPosition,uPosition]]-expected,assumptions],
      {name,sign,distribution,"original finite hat comparison"}]],
    {sign,{1,-1,0}},{distribution,distributions}],{name,Keys[hats]}];
result=<|"Schema"->"polarized-sidis-finite-bmhv-response-v1","Channel"->channel,
  "PhotonLabels"->basis["PhotonLabels"],"SpinLabels"->basis["SpinLabels"],"IndexOrder"->real["IndexOrder"],
  "Components"->values,"LODeltaResponse"->leadingResponse,"NLOResponse"->finiteResponse,
  "FhatsBMHV"->hats,"FhatPhotonWeights"->hatPhotonWeights,"ProjectorDefinitions"->projectorDefinitions,
  "PhysicalFrame"->KeyTake[realFrame,Join[{p,q,k1},photonAxes,{eOutX,eOutY}]],
  "Bookkeeping"->bookkeeping,"RealPhase"->phase,"RestoredRealCoupling"->strongFactor,
  "HardNormalization"->hardNormalization,"PlusDefinition"->real["PlusDefinition"],
  "BranchConvention"->"sign=+1/-1 means t=sign omega-s, omega>0; sign=0 means t=-s",
  "PhysicalConditions"->physical,"FlavorDomain"->flavorDomain,"Gamma5Scheme"->"BMHV",
  "SubtractionScheme"->"Minimal subtraction with the recorded MSbar pole and unconverted BMHV spin operators",
  "CompletePoleCancellationChecked"->True,"UnpolarizedFinalReferenceComparisonPassed"->True,
  "FiniteMinimalSubtractionCoefficientsComputed"->True,
  "FiniteAxialSchemeConversionApplied"->False,"FiniteNLOFHatsComputed"->False,
  "SourceHash"->sourceHash,"InputHash"->inputHash,"InputHashes"->inputHashes,"Checks"->checks|>;
resultDir=FileNameJoin[{root,channel,"s14_result"}];
If[!DirectoryQ[resultDir],CreateDirectory[resultDir,CreateIntermediateDirectories->True]];
put[result,FileNameJoin[{resultDir,"s14_result.wl"}]];
Export[FileNameJoin[{resultDir,"s14_checks.json"}],<|"channel"->channel,"checks"->checks,
  "component_count"->Length[values],"finite_minimal_subtraction_coefficients_computed"->True,
  "finite_nlo_fhats_computed"->False,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_assemble_finite_spin"];Quit[0];

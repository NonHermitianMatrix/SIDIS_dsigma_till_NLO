(* Integrate the spin tensors with the pinned GitHub cut-master assembly. *)
$HistoryLength=0; root=Directory[];
sourcePath=FileNameJoin[{root,"common","s12_assemble_real_spin.wls"}];
channel=Environment["POLARIZED_SIDIS_CHANNEL"]; checks=<||>;
gate[name_,test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks,name],Print["PASS: ",name]];AssociateTo[checks,name->True],
  Print["FAIL: ",name];If[TrueQ[$KernelID>0],Throw[$Failed,"S12Failure"],CloseKernels[];Quit[1]]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[sourcePath,"Text"]]];
put[value_,file_] := (Put[value,file<>".tmp"];RenameFile[file<>".tmp",file,OverwriteTarget->True]);
SetAttributes[bounded,HoldFirst];
bounded[value_,label_] := MemoryConstrained[TimeConstrained[value,1200,
  gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
configPath=FileNameJoin[{root,"common","s12_inputs.json"}];
config=Import[configPath,"RawJSON"];
referencePath=FileNameJoin[{root,config["reference_source"]}];
gate["pinned GitHub real assembly",IntegerString[FileHash[referencePath,"SHA256"],16,64]===config["reference_sha256"]];
mapPath=FileNameJoin[{root,channel,"s08_result","s08_result.wl"}];
libraryPath=FileNameJoin[{root,"common","s06_result","s06_result.wl"}];
mapped=Get[mapPath];library=Get[libraryPath];
gate["accepted real scalar map",mapped["Schema"]==="polarized-sidis-real-scalar-map-v1"&&
  mapped["Channel"]===channel&&TrueQ[mapped["MappingAccepted"]]&&And@@Values[mapped["Checks"]]];
gate["complete real reduction coverage",TrueQ[mapped["ReductionCoverageComplete"]]&&mapped["MissingTargets"]==={}];
gate["accepted unchanged scalar library",library["Schema"]==="polarized-sidis-scalar-library-v1"&&And@@Values[library["Checks"]]];
readLibrary[stage_] := Module[{row,path},row=library["Library"][stage];path=FileNameJoin[{root,row["File"]}];
  gate[stage<>" unchanged scalar input",IntegerString[FileHash[path,"SHA256"],16,64]===row["SHA256"]];Get[path]];
inputsOriginal=readLibrary["s08"];evaluationsOriginal=readLibrary["s10"];regionsOriginal=readLibrary["s15"];
gate["accepted cut values and regions",TrueQ[inputsOriginal["AcceptedRepresentations"]]&&
  TrueQ[evaluationsOriginal["CutNormalizationAccepted"]]&&TrueQ[regionsOriginal["AcceptedCutMasterRegions"]]];
Do[stage=StringTake[key,3];
  gate["region input identity "<>key,KeyExistsQ[library["Library"],stage]&&
    FileHash[FileNameJoin[{root,library["Library"][stage]["File"]}],"SHA256"]===regionsOriginal["InputHashes"][key]],
  {key,{"s08_result.wl","s10_result.wl"}}];
(* The region receipt also binds the old unpolarized coefficient manifest.
   New spin coefficients establish their own expansion depth below. *)
regionCoefficientProvenance=regionsOriginal["InputHashes"]["s11_result.wl"];
gate["recorded scalar coordinate conversion",mapped["ScalarConventionRules"]==={Q2->Q^2,w->s23}];
inputs=inputsOriginal/.mapped["ScalarConventionRules"];
evaluations=evaluationsOriginal/.mapped["ScalarConventionRules"];
regions=regionsOriginal/.mapped["ScalarConventionRules"];
gate["every required master has its unchanged value",Complement[
  Union[Flatten[Keys[#["ReducedCoefficients"]]&/@mapped["Components"]]],Keys[regions["OrdinaryMasters"]]]==={}];
sourceHash=FileHash[sourcePath,"SHA256"];
inputPaths=Join[{configPath,referencePath,mapPath,libraryPath},
  FileNameJoin[{root,library["Library"][#]["File"]}]&/@{"s08","s10","s15"}];
inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths];
inputHash=Hash[{sourceHash,inputHashes,$Version},"SHA256"];
cache=FileNameJoin[{root,"cache","s12",channel,IntegerString[inputHash,16]}];
If[!DirectoryQ[cache],CreateDirectory[cache,CreateIntermediateDirectories->True]];
transverseRule=mapped["TransverseSubstitution"];
branchAssumptions[sign_] := Q>0&&s>0&&omega>0&&B>0&&
  -Q^2-s<sign omega-s<0&&SUNN>1&&Nc>1;
reduce[value_,assumptions_] := Module[{refined,functions},
  refined=Refine[value,assumptions];
  functions=DeleteDuplicates[Cases[refined,_Log|_PolyLog|_ArcTan|_Re|_Im,Infinity]];
  Collect[Expand[refined],functions,Factor]];
epsilonSeries[value_,order_,label_] := Module[{series},
  series=bounded[Series[value,{eps,0,order}],label];
  gate[label<>" regulator coverage",FreeQ[series,eps|_SeriesData|_Series]||(MatchQ[series,_SeriesData]&&series[[5]]>order)];
  Normal[series]];
endpointIntegral=Integrate[rr^(-1-kap ep),{rr,0,B},
  Assumptions->kap>0&&ep<0&&B>0,GenerateConditions->False];
gate["regulated endpoint integral evaluated",FreeQ[endpointIntegral,_Integrate|_ConditionalExpression]];
logKernel=Normal[Series[Exp[-kap ep ellLog],{ep,0,2}]];
laurentProduct[laurent_,kernel_,order_] := Module[{polynomial=Expand[laurent],first,last},
  If[polynomial===0,Return[0]];
  first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
  Total@Table[eps^n Coefficient[polynomial,eps,n] Normal[Series[kernel,{eps,0,order-n}]],{n,first,last}]];

softPieces[master_,sign_] := softPieces[master,sign]=Module[
  {data,metadata,assumptions,replacement,power,prefactor,value,pieces={},entry,
   definition,parameterRules,lambdaForm,lambdaPower,lambdaRegular,totalPower,regular},
  data=inputs["Masters"][master];metadata=regions["Masters"][master];
  assumptions=branchAssumptions[sign]&&s23>0;
  replacement=t->sign omega-s;
  power=metadata["PrefactorSoftPower"];
  prefactor=bounded[FullSimplify[(data["RegulatedPrefactor"]/s23^power)/.replacement,
    assumptions&&Element[eps,Reals]],"remove regulated cut recoil power"];
  If[metadata["DivergentParameters"]==={},
    value=(evaluations["Classes"][data["Class"]]["Series"]/.SubTropica`eps->eps)/.
      data["PhysicalSubstitutions"]/.replacement;
    Return[{<|"Power"->power,"Regular"->prefactor value|>}]];
  definition=regions["RegionMasterMap"][master]["ParameterDefinition"];
  parameterRules=Solve[First[definition]==Last[definition],SubTropica`\[Lambda]];
  gate["unique physical soft-region parameter",Length[parameterRules]===1];
  lambdaForm=Factor[SubTropica`\[Lambda]/.First[parameterRules]/.data["PhysicalSubstitutions"]/.replacement];
  lambdaPower=bounded[FullSimplify[Limit[s23 D[lambdaForm,s23]/lambdaForm,s23->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"region recoil valuation"];
  gate["region recoil valuation is a positive integer",IntegerQ[lambdaPower]&&lambdaPower>0];
  lambdaRegular=Factor[lambdaForm/s23^lambdaPower];
  gate["region expansion remains on its positive physical side",
    FullSimplify[Limit[lambdaRegular,s23->0,Direction->"FromAbove",Assumptions->branchAssumptions[sign]]>0,
      branchAssumptions[sign]]];
  Do[
    value=regions["RegionValues"][entry["IntegralID"]]["Series"];
    If[value===0,Continue[]];
    totalPower=Expand[power+lambdaPower(entry["LambdaPower"]/.SubTropica`eps->eps)];
    regular=prefactor lambdaRegular^(entry["LambdaPower"]/.SubTropica`eps->eps) value;
    AppendTo[pieces,<|"Power"->totalPower,"Regular"->regular,"Region"->entry["Region"]|>],
    {entry,regions["RegionMasterMap"][master]["Entries"]}];pieces];

pieceEndpoint[piece_,sign_] := pieceEndpoint[piece,sign]=bounded[
  FullSimplify[Limit[piece["Regular"],s23->0,Direction->"FromAbove",
    Assumptions->branchAssumptions[sign]&&Element[eps,Reals]],
    branchAssumptions[sign]&&Element[eps,Reals]],"regular master endpoint"];
softRows[coefficient_,piece_,sign_] := Module[
  {power=piece["Power"],integerPower,kappa,rational,valuation,firstPower,leading,value},
  integerPower=power/.eps->0;kappa=-Coefficient[power,eps];
  gate["regulated soft power is affine with integer recoil degree",
    IntegerQ[integerPower]&&PolynomialQ[power,eps]&&Exponent[power,eps]<=1];
  rational=Cancel[coefficient/.t->sign omega-s];
  valuation=bounded[FullSimplify[Limit[s23 D[rational,s23]/rational,s23->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],
    "spin coefficient recoil valuation"];
  gate["spin coefficient has integer recoil valuation",IntegerQ[valuation]];
  firstPower=valuation+integerPower;
  If[firstPower>=0,Return[{}]];
  gate["measured recoil degree needs only a leading endpoint coefficient",firstPower===-1];
  leading=bounded[FullSimplify[Limit[s23^(-valuation)rational,s23->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],
    "physical spin endpoint coefficient"];
  gate["rational endpoint coefficient is finite",FreeQ[leading,s23|Indeterminate|ComplexInfinity|_DirectedInfinity]];
  value=epsilonSeries[(leading/.D->4-2eps)pieceEndpoint[piece,sign],1,"leading soft epsilon coefficient"];
  value=bounded[reduce[value,branchAssumptions[sign]],"leading endpoint collection"];
  gate["endpoint coefficients are fully evaluated",FreeQ[value,s23|_Limit|_Derivative|_Series|_SeriesData|Indeterminate|ComplexInfinity]];
  If[value===0,{},{{kappa,firstPower,value}}]];

assemble[component_,index_] := Catch[Block[{checks=<||>},Module[
  {file,saved,coefficients,ordinary,terms,branches,rows,groups,combined,assumptions,
   endpoints,delta,plus,regular,result,master,started=AbsoluteTime[]},
  file=FileNameJoin[{cache,"component_"<>IntegerString[index,10,4]<>".wl"}];
  saved=If[FileExistsQ[file],Get[file],<||>];
  If[Lookup[saved,"InputHash",None]===inputHash&&TrueQ[Lookup[saved,"Accepted",False]],Return[saved]];
  Print["REAL_ASSEMBLY ",channel," ",index," ",component["Sector"]," ",component["Kind"]," ",component["Index"]];
  coefficients=Select[component["ReducedCoefficients"],#=!=0&]/.transverseRule;
  gate["physical transverse coordinate inserted",FreeQ[coefficients,First[transverseRule]]];
  terms=KeyValueMap[Function[{m,c},epsilonSeries[(c/.D->4-2eps)regions["OrdinaryMasters"][m],0,
    "ordinary cut coefficient"]],coefficients];
  ordinary=Total[terms];
  gate["ordinary cut contraction is symbolic and evaluated",FreeQ[ordinary,
    _CutIntegral|_SeriesData|_Series|_Integrate|_Missing|_Real|$Failed|$Aborted]];
  branches=Association@Table[
    Print["REAL_ENDPOINT ",channel," ",index," branch ",sign];
    assumptions=branchAssumptions[sign];rows={};
    Do[rows=Join[rows,Flatten[softRows[coefficients[master],#,sign]&/@softPieces[master,sign],1]],
      {master,Keys[coefficients]}];
    groups=GatherBy[rows,Take[#,2]&];
    combined=Table[{group[[1,1]],group[[1,2]],bounded[reduce[Total[group[[All,3]]],assumptions],
      "combine recoil coefficients"]},{group,groups}];
    Do[If[row[[2]]<-1,gate["stronger recoil singularities cancel",
      bounded[FullSimplify[row[[3]],assumptions],"stronger recoil cancellation"]===0]],{row,combined}];
    endpoints=Select[combined,#[[2]]===-1&&Last[#]=!=0&];
    gate["endpoint regulator has the defining convergence orientation",And@@(TrueQ[#[[1]]>0]&/@endpoints)];
    delta=bounded[reduce[Total[laurentProduct[#[[3]],endpointIntegral/.{kap->#[[1]],ep->eps},0]&/@endpoints],
      assumptions],"delta coefficient"];
    plus=Table[bounded[reduce[Total[laurentProduct[#[[3]],B^(-#[[1]]eps)
      (Coefficient[logKernel,ellLog,n]/.{kap->#[[1]],ep->eps}),0]&/@endpoints],assumptions],
      "plus coefficient"],{n,0,2}];
    gate["no higher logarithmic plus distribution survives",Factor[plus[[3]]]===0];
    regular=(ordinary/.t->sign omega-s)-Total[laurentProduct[#[[3]],s23^(-1-#[[1]]eps),0]&/@endpoints];
    sign-><|"Delta"->delta,"L0"->plus[[1]],"L1"->plus[[2]],"Regular"->regular,
      "SoftCoefficients"->endpoints,"Assumptions"->assumptions|>,{sign,{1,-1}}];
  result=Join[KeyTake[component,{"Sector","Kind","Index"}],<|"Ordinary"->ordinary,"Branches"->branches,
    "InputHash"->inputHash,"Checks"->checks,"Accepted"->True,"ElapsedSeconds"->AbsoluteTime[]-started|>];
  put[result,file];ClearSystemCache[];Print["REAL_ASSEMBLY_ACCEPTED ",channel," ",index];result]],"S12Failure"];
slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];
If[!IntegerQ[slots]||slots<1,slots=1];CloseKernels[];
If[slots>1,TimeConstrained[LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
  "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]],60,$Failed]];
workers=Length[Kernels[]];
If[workers>0,
  gate["workers share compute allocation",And@@(SameQ[#, $MachineName]&/@ParallelEvaluate[$MachineName])];
  ParallelEvaluate[$HistoryLength=0;checks=<||>;
    PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
    $FeynCalcStartupMessages=False;Get["FeynCalc`"]];
  DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,
    softPieces,pieceEndpoint,softRows,assemble,root,inputHash,sourceHash,inputs,evaluations,regions,
    endpointIntegral,logKernel,cache,channel,transverseRule]];
$DistributedContexts=None;
tasks=MapIndexed[{#1,First[#2]}&,mapped["Components"]];
values=If[workers>0,ParallelMap[assemble@@#&,tasks,Method->"FinestGrained"],assemble@@#&/@tasks];
CloseKernels[];
gate["all real spin components integrated",FreeQ[values,$Failed|$Aborted]&&Length[values]===Length[tasks]&&
  AllTrue[values,AssociationQ]&&And@@Lookup[values,"Accepted"]];
gate["all component checks accepted",And@@Flatten[Values[#["Checks"]]&/@values]];
result=Join[KeyTake[mapped,{"Channel","Bookkeeping","PhotonLabels","SpinLabels","IndexOrder",
  "CutMomenta","CutEnergySupport","Gamma5Scheme","CouplingsRemoved"}],
  <|"Schema"->"polarized-sidis-real-distributions-v1","Components"->values,
    "Measure"->inputs["MasterMeasure"],"PlusDefinition"->"Ln=[Log[s23/B]^n/s23]_+ on [0,B]",
    "BranchMap"->(t->sign omega-s),"Regulator"->eps,"CutMeasureIntegrated"->True,
    "MasterExpansionDepthChecked"->True,"PhaseAndWeightsApplied"->False,"FiniteNLOFHatsComputed"->False,
    "RegionReferenceCoefficientHash"->regionCoefficientProvenance,
    "SourceHash"->sourceHash,"InputHash"->inputHash,"InputHashes"->inputHashes,"Checks"->checks|>];
resultDir=FileNameJoin[{root,channel,"s12_result"}];
If[!DirectoryQ[resultDir],CreateDirectory[resultDir,CreateIntermediateDirectories->True]];
put[result,FileNameJoin[{resultDir,"s12_result.wl"}]];
Export[FileNameJoin[{resultDir,"s12_checks.json"}],<|"channel"->channel,"checks"->checks,
  "component_count"->Length[values],"finite_nlo_fhats_computed"->False,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s12_assemble_real_spin"];Quit[0];

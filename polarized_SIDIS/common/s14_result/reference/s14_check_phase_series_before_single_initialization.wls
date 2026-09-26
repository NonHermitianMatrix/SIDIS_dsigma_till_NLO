(* Check the reference Laurent product on actual integrated spin components. *)
$HistoryLength=0;
phaseProofRoot=Directory[];
phaseProofSource=FileNameJoin[{phaseProofRoot,"common","s14_check_phase_series.wls"}];
phaseBaseline=FileNameJoin[{phaseProofRoot,"common","s14_assemble_finite_spin.wls"}];
phaseLaurentSource=FileNameJoin[{phaseProofRoot,"common","s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[phaseBaseline,"SHA256"],16,64]=!=
  "9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a"||
  IntegerString[FileHash[phaseLaurentSource,"SHA256"],16,64]=!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243",Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
phaseBaselineText=Import[phaseBaseline,"Text"];
If[StringCount[phaseBaselineText,"\nindices=Tuples"]=!=1||!SyntaxQ[Import[phaseProofSource,"Text"]],Quit[1]];
ToExpression[First[StringSplit[phaseBaselineText,"\nindices=Tuples"]],InputForm];
gate["phase comparison channel",channel==="Hqqprime"];
phaseLaurentText=Import[phaseLaurentSource,"Text"];
phaseLaurentStart=First[First[StringPosition[phaseLaurentText,"laurentProduct[laurent_"]]];
phaseLaurentEnd=First[First[StringPosition[phaseLaurentText,"\n\nsoftPieces["]]];
phaseLaurentBlock=StringTake[phaseLaurentText,{phaseLaurentStart,phaseLaurentEnd-1}];
gate["reference Laurent product syntax",SyntaxQ[phaseLaurentBlock]];
ToExpression[phaseLaurentBlock,InputForm];
phaseProduct[coefficient_,kernel_,order_,label_] := Module[
  {polynomial,first,last,rows,reconstruction,answer},
  polynomial=bounded[Expand[coefficient,eps],{label,"Laurent collection"}];
  If[polynomial===0,Return[0]];
  first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
  gate["integer finite Laurent support",IntegerQ[first]&&IntegerQ[last]&&first<=last];
  gate["complete Laurent polynomial",PolynomialQ[Expand[eps^(-first)polynomial,eps],eps]];
  rows=Table[Coefficient[polynomial,eps,n],{n,first,last}];
  gate["regulator-independent Laurent coefficients",FreeQ[rows,eps]];
  reconstruction=Total[MapThread[Times,{rows,eps^Range[first,last]}]];
  gate["exact Laurent polynomial reconstruction",
    bounded[Expand[polynomial-reconstruction],{label,"Laurent reconstruction"}]===0];
  gate["phase kernel has no truncated input series",FreeQ[kernel,_SeriesData|_Series]];
  answer=bounded[laurentProduct[polynomial,kernel,order],{label,"reference Laurent product"}];
  gate["reference phase product evaluated",FreeQ[answer,_SeriesData|_Series|_Integrate|_Missing|$Failed|$Aborted]];
  answer];

phaseControlLabels={{{1,1,1},1,"Regular"},{{1,4,4},-1,"Regular"},{{3,4,4},-1,"Regular"}};
phaseControlRows=Table[
  phaseControlPath=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
  gate["own accepted assembly checkpoint exists",FileExistsQ[phaseControlPath]];
  saved=Get[phaseControlPath];
  gate["own accepted assembly checkpoint identity",TrueQ[saved["Accepted"]]&&saved["InputHash"]===inputHash&&saved["Label"]===label];
  index=label[[1]];sign=label[[2]];distribution=label[[3]];
  assumptions=(physical/.t->sign omega-s)&&omega>0&&flavorDomain;
  phaseTimed=AbsoluteTiming[phaseProduct[strongFactor realBranch[index,sign,distribution],phase,0,label]];
  phaseCombined=Expand[phaseTimed[[2]]+(subtractionValue[index,distribution]/.t->sign omega-s),eps];
  gate["own accepted finite coefficient equality "<>ToString[label,InputForm],
    bounded[zero[Coefficient[phaseCombined,eps,0]-saved["Finite"],assumptions],{label,"accepted finite equality"}]];
  phaseMinimum=Min[Append[Cases[phaseCombined,Power[eps,n_Integer]/;n<0:>n,Infinity],0]];
  Do[gate["own accepted pole equality "<>ToString[{label,n},InputForm],
    bounded[zero[Coefficient[phaseCombined,eps,n]-Lookup[saved["PoleResiduals"],n,0],assumptions],
      {label,"accepted pole equality",n}]],{n,phaseMinimum,-1}];
  Print["PHASE_CONTROL_ACCEPTED ",label," seconds ",phaseTimed[[1]]];
  <|"Label"->label,"Checkpoint"->StringDrop[phaseControlPath,StringLength[root]+1],
    "SHA256"->FileHash[phaseControlPath,"SHA256"],"Seconds"->phaseTimed[[1]]|>,{label,phaseControlLabels}];

phaseActualLabel={{4,1,1},1,"Regular"};
phaseActualCoefficient=strongFactor realBranch[phaseActualLabel[[1]],phaseActualLabel[[2]],phaseActualLabel[[3]]];
Print["ACTUAL_PHASE=",InputForm[phase]];
Print["ACTUAL_PHASE_COEFFICIENT_BYTES=",ByteCount[phaseActualCoefficient]];
phaseActualTimed=AbsoluteTiming[phaseProduct[phaseActualCoefficient,phase,0,phaseActualLabel]];
Print["ACTUAL_PHASE_PRODUCT_SECONDS=",phaseActualTimed[[1]]];
phaseProof=<|"Schema"->"polarized-sidis-phase-series-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[phaseProofSource,"SHA256"],"BaselineSourceHash"->sourceHash,
  "LaurentSourceHash"->FileHash[phaseLaurentSource,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
  "NativeVersions"->{$Version,$FeynCalcVersion},"Definitions"->DownValues[phaseProduct],
  "LaurentDefinitions"->DownValues[laurentProduct],"Controls"->phaseControlRows,
  "ActualLabel"->phaseActualLabel,"ActualSeconds"->phaseActualTimed[[1]],
  "ActualValue"->phaseActualTimed[[2]],"Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
phaseProofDir=FileNameJoin[{root,channel,"s14_phase_result"}];
If[!DirectoryQ[phaseProofDir],CreateDirectory[phaseProofDir,CreateIntermediateDirectories->True]];
phaseProofOutput=FileNameJoin[{phaseProofDir,"s14_result.wl"}];
phaseSerialized="Uncompress["<>ToString[bounded[Compress[phaseProof],"phase proof compression"],InputForm]<>"]\n";
gate["phase proof file bound",StringLength[phaseSerialized]<128*1024^2];
Export[phaseProofOutput<>".tmp",phaseSerialized,"Text"];
gate["phase proof exact native reload",Get[phaseProofOutput<>".tmp"]===phaseProof];
RenameFile[phaseProofOutput<>".tmp",phaseProofOutput,OverwriteTarget->True];
Export[FileNameJoin[{phaseProofDir,"s14_checks.json"}],<|"channel"->channel,"checks"->checks,
  "control_count"->Length[phaseControlRows],"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_phase_series"];Quit[0];

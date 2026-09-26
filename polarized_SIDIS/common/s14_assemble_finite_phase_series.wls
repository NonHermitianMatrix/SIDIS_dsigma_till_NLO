(* Original finite assembly with the accepted reference Laurent-product routine. *)
$HistoryLength=0;phaseRunRoot=Directory[];
phaseRunSource=FileNameJoin[{phaseRunRoot,"common","s14_assemble_finite_phase_series.wls"}];
phaseRunBaseline=FileNameJoin[{phaseRunRoot,"common","s14_assemble_finite_spin.wls"}];
phaseRunProofPath=FileNameJoin[{phaseRunRoot,"Hqqprime","s14_phase_result","s14_result.wl"}];
If[IntegerString[FileHash[phaseRunBaseline,"SHA256"],16,64]=!=
  "9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a"||
  IntegerString[FileHash[phaseRunProofPath,"SHA256"],16,64]=!=
  "2aec26ba5852ad86bf22f5bbbc797e071005d8916de3202923d4bee33fbf74a9",Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
phaseRunText=Import[phaseRunBaseline,"Text"];
If[StringCount[phaseRunText,"\nindices=Tuples"]=!=1||!SyntaxQ[Import[phaseRunSource,"Text"]],Quit[1]];
phaseRunPrefix=First[StringSplit[phaseRunText,"\nindices=Tuples"]];
phaseRunReplacements={
  "epsSeries[phase strongFactor realBranch[index,sign,distribution]]"->
    "checkedPhaseProduct[strongFactor realBranch[index,sign,distribution],phase,0,{index,sign,distribution}]",
  "epsSeries[phase strongFactor commonReal[distribution]]"->
    "checkedPhaseProduct[strongFactor commonReal[distribution],phase,0,{index,0,distribution}]",
  "Get[\"FeynCalc`\"]"->"Null"};
If[!And@@(StringCount[phaseRunPrefix,First[#]]===1&/@phaseRunReplacements),Quit[1]];
phaseRunPrefix=StringReplace[phaseRunPrefix,phaseRunReplacements];
If[!SyntaxQ[phaseRunPrefix],Quit[1]];
ToExpression[phaseRunPrefix,InputForm];
phaseRunProof=Get[phaseRunProofPath];
gate["accepted reference phase implementation",TrueQ[phaseRunProof["Accepted"]]&&
  And@@Values[phaseRunProof["Checks"]]&&phaseRunProof["BaselineSourceHash"]===sourceHash&&
  phaseRunProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_phase_series.wls"}],"SHA256"]&&
  phaseRunProof["LaurentSourceHash"]===FileHash[FileNameJoin[{root,"common","s12_assemble_real_spin.wls"}],"SHA256"]&&
  phaseRunProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
DownValues[phaseProduct]=phaseRunProof["Definitions"];
DownValues[laurentProduct]=phaseRunProof["LaurentDefinitions"];
phaseRunMonomialChecks=<||>;
phaseMonomialCheck[kernel_,power_,order_] := Module[{key,actual,expected},
  key=Hash[{kernel,power,order},"SHA256"];
  If[KeyExistsQ[phaseRunMonomialChecks,key],Return[True]];
  actual=bounded[laurentProduct[eps^power,kernel,order],{"phase monomial",power,order}];
  expected=bounded[Normal[Series[eps^power kernel,{eps,0,order}]],{"original phase monomial",power,order}];
  gate["own phase Laurent monomial equals original series "<>ToString[{power,order},InputForm],
    bounded[FullSimplify[actual-expected,physical&&Element[eps,Reals]&&eps!=0],
      {"phase monomial comparison",power,order}]===0];
  AssociateTo[phaseRunMonomialChecks,key-><|"Power"->power,"Order"->order,"Kernel"->kernel,"Accepted"->True|>];True];
checkedPhaseProduct[coefficient_,kernel_,order_,label_] := Module[{answer,polynomial,first,last},
  answer=phaseProduct[coefficient,kernel,order,label];
  polynomial=Expand[coefficient,eps];
  If[polynomial=!=0,
    first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
    Scan[phaseMonomialCheck[kernel,#,order]&,Range[first,last]]];answer];
phaseRunTail="indices=Tuples"<>Last[StringSplit[phaseRunText,"\nindices=Tuples"]];
phaseRunExport="put[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
gate["unique original finite export",StringCount[phaseRunTail,phaseRunExport]===1];
phaseRunTail=StringReplace[phaseRunTail,phaseRunExport->
  "AssociateTo[result,{\"DispatchSourceHash\"->FileHash[phaseRunSource,\"SHA256\"],\"PhaseComparisonHash\"->FileHash[phaseRunProofPath,\"SHA256\"],\"OwnPhaseMonomialChecks\"->phaseRunMonomialChecks}];"<>phaseRunExport];
gate["original finite assembly tail syntax",SyntaxQ[phaseRunTail]];
ToExpression[phaseRunTail,InputForm];

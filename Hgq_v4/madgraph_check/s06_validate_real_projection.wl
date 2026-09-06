$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[$InputFileName];
gate[label_,test_]:=If[TrueQ[test],Print["PASS: ",label],Print["FAIL: ",label];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[x_,label_]:=MemoryConstrained[TimeConstrained[x,180,Print["TIME LIMIT: ",label];Quit[2]],1024^3,Print["MEMORY LIMIT: ",label];Quit[3]];
sha[path_]:=IntegerString[FileHash[path,"SHA256"],16,64];
manifest=Import[FileNameJoin[{root,"s01_result.json"}],"RawJSON"];
KeyValueMap[Function[{name,record},gate[name<>" unchanged",sha[FileNameJoin[{root,"inputs",name}]]===record["sha256"]]],manifest["Inputs"]];
samples=Import[FileNameJoin[{root,"s03_result.json"}],"RawJSON"];
local=Import[FileNameJoin[{root,"s04_result.json"}],"RawJSON"];
generated=Get[FileNameJoin[{root,"inputs","s01_result.wl"}]];
born=Get[FileNameJoin[{root,"inputs","s02_result.wl"}]];
saved=Get[FileNameJoin[{root,"inputs","s03_result.wl"}]];
point=SelectFirst[samples["Rows"],#["Kind"]==="real"&];
prior=SelectFirst[local["Rows"],#["ID"]===point["ID"]&];
mom=Rationalize[point["HadronMomenta"],0];
metric=DiagonalMatrix[{1,-1,-1,-1}];dot[a_,b_]:=a.metric.b;
vectors=AssociationThread[{p,q,k1,k2,k3},Lookup[mom,{"p","q","k1","k2","k3"}]];
rules={Q2->-dot[vectors[q],vectors[q]],s->dot[vectors[p]+vectors[q],vectors[p]+vectors[q]],
 t->dot[vectors[q]-vectors[k1],vectors[q]-vectors[k1]],
 s23->dot[vectors[k2]+vectors[k3],vectors[k2]+vectors[k3]],
 a12->dot[vectors[k1]+vectors[k2],vectors[k1]+vectors[k2]],
 u3->dot[vectors[p]-vectors[k3],vectors[p]-vectors[k3]]};
residuals=Table[With[{direct=dot[vectors[row[[1]]],vectors[row[[2]]]],stored=row[[3]]/.rules},
 Abs[direct-stored]/Max[1,Sqrt[(vectors[row[[1]]].vectors[row[[1]]])*(vectors[row[[2]]].vectors[row[[2]]])],Abs[direct],Abs[stored]]],{row,born["RealScalarProducts"]}];
Print["SCALAR_PRODUCT_DIAGNOSTIC ",InputForm[Table[<|"Definition"->born["RealScalarProducts"][[i]],
 "Direct"->N[dot[vectors[born["RealScalarProducts"][[i,1]]],vectors[born["RealScalarProducts"][[i,2]]]],17],
 "Stored"->N[born["RealScalarProducts"][[i,3]]/.rules,17],"Residual"->N[residuals[[i]],17]|>,{i,Length[residuals]}]]];
gate["stored scalar products equal defining four-vector products",Max[residuals]<10^-12];
FCClearScalarProducts[];
Do[With[{a=pair[[1]],b=pair[[2]],v=dot[vectors[pair[[1]]],vectors[pair[[2]]]]},SPD[a,b]=v;SP[a,b]=v],
 {pair,Tuples[Keys[vectors],2]}];
(* Sample partons are massless; gate the rounding residual before imposing the defining on-shell condition. *)
Do[gate["sample mass shell "<>ToString[v],Abs[dot[vectors[v],vectors[v]]]/Max[1,vectors[v].vectors[v]]<10^-12];
 With[{a=v},SPD[a,a]=0;SP[a,a]=0],{v,{p,k1,k2,k3}}];
amp=Total[generated["Real"]]/.{SMP["e"]->1,SMP["g_s"]->1};
a=amp/.Polarization[q,___]->p;
value=bounded[FermionSpinSum[a ComplexConjugate[a],ExtraFactor->born["InitialAverages"]["Hgq"]],"total amplitude spin sum"];
value=bounded[SUNSimplify[value,Explicit->True,SUNNToCACF->False],"color sum"];
value=bounded[DoPolarizationSums[value,p,k1],"incoming gluon sum"];
value=bounded[DoPolarizationSums[value,k3,p],"outgoing gluon sum"];
value=bounded[Contract[DiracSimplify[value,DiracTraceEvaluate->True]],"Dirac trace"];
value=bounded[ExpandScalarProduct[FeynAmpDenominatorExplicit[value]],"scalar products"];
unit=value*saved["TagWeight"]/born["ModelChargeSquared"]/.{D->Length[metric],SUNN->manifest["Particles"]["u"]["color"]};
gate["fresh result is scalar",FreeQ[unit,_Spinor|_DiracTrace|_DiracGamma|_SUNTF|_SUNTrace|_Pair|_Polarization]];
n=Map[ToExpression,local["Normalization"]["real"]];
propagator=-I/dot[vectors[q],vectors[q]];
prefactor=Abs[n["AmplitudeCoupling"]*n["ChargeAmplitude"]*propagator]^2;
fresh=bounded[N[prefactor*unit,40],"fresh scaled projector"];
gate["fresh projector finite real",NumberQ[fresh]&&Abs[Im[fresh]]<10^-25 Max[1,Abs[Re[fresh]]]];
fresh=Re[fresh];stored=prior["LocalScaledPpp"];mg=point["MadGraphScaledPpp"];
relative[x_,y_]:=Abs[x-y]/Max[Abs[x],Abs[y]];
result=<|"Status"->"Complete","SourceSHA256"->sha[$InputFileName],"Point"->point["ID"],
 "InputManifestSHA256"->sha[FileNameJoin[{root,"s01_result.json"}]],
 "SampleSHA256"->sha[FileNameJoin[{root,"s03_result.json"}]],
 "MaximumScalarProductResidual"->N[Max[residuals],17],"FreshScaledPpp"->N[fresh,17],
 "StoredScaledPpp"->stored,"MadGraphScaledPpp"->mg,
 "FreshVsStoredRelativeDifference"->N[relative[fresh,stored],17],
 "FreshVsMadGraphRelativeDifference"->N[relative[fresh,mg],17]|>;
Print[InputForm[result]];
Export[FileNameJoin[{root,"s06_result.json"}],result,"RawJSON"];
Print["HGQ_MADGRAPH_S06_SUCCESS"];Quit[0];

$HistoryLength=0;$MaxExtraPrecision=1000;
root=DirectoryName[$InputFileName]; scripts=DirectoryName[root];SetDirectory[root];
comparisonSource=FileNameJoin[{root,"s03_compare_regular.wl"}];
log[x_]:=Print[DateString[{"ISODate","T","Time"}]," ",x];
gate[n_,v_]:=If[!TrueQ[v],Throw[<|"FailedGate"->n,"Value"->v|>,"stage"]];
bounded[e_,n_]:=TimeConstrained[MemoryConstrained[e,1800000000,Throw[<|"FailedGate"->n,"Reason"->"memory bound"|>,"stage"]],240,Throw[<|"FailedGate"->n,"Reason"->"time bound"|>,"stage"]];
SetAttributes[bounded,HoldFirst];
configuration=KernelConfiguration["localhost","KernelCommand"->"/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel","KernelCount"->4,"TimeConstraint"->60];
LaunchKernels[configuration];If[Length[Kernels[]]===0,log["FAILED no local kernels"];Exit[1]];
log[{"local comparison kernels",Length[Kernels[]]}];
Clear[canonicalLog,reduceExpression,calculate];
canonicalLog[arg_,domain_]:=Module[{f,fac,nfac,dfac,parts,phase,reconstructed,value},
 f=Factor[arg];If[f===1,Return[0]];
 nfac=FactorList[Numerator[f]];dfac=FactorList[Denominator[f]];
 fac=Join[nfac,({#[[1]],-#[[2]]}&/@dfac)];
 fac=Flatten[Map[If[MatchQ[#[[1]],_Integer|_Rational],With[{power=#[[2]]},({#[[1]],power #[[2]]}&/@FactorInteger[#[[1]]])],{#}]&,fac],1];
 reconstructed=Times@@(Power@@#&/@fac);
 gate["factorized logarithm argument reconstructs",Together[reconstructed-f]===0];
 phase=TimeConstrained[FullSimplify[Arg[f],domain],15,Arg[f]];
 parts=Total[(#[[2]] Log[Abs[#[[1]]]]&/@fac)];
 value=parts+I phase;
 value/.Abs[a_]:>TimeConstrained[Refine[Abs[a],domain],3,Abs[a]]
];
reduceExpression[expression_,wrule_,domain_]:=Module[{e,radicals,rr,logs,lr,fs,ss,sr,polynomial,result,coths,cr,ce},
 e=expression/.wrule;
 coths=DeleteDuplicates[Cases[e,_ArcCoth,Infinity]];
 cr=Table[ce=Refine[ComplexExpand[c],domain];
 gate["inverse hyperbolic identity",FullSimplify[ce-c,domain]===0];c->ce,{c,coths}];
 e=e/.cr;
 radicals=DeleteDuplicates[Cases[e,p:Power[_,_Rational]:>p,Infinity]];
 rr=Table[r->FullSimplify[Factor[First[r]]^Last[r],domain],{r,radicals}];
 e=e/.rr;
 logs=DeleteDuplicates[Cases[e,_Log,Infinity]];
 lr=Table[l->canonicalLog[First[l],domain],{l,logs}];
 e=e/.lr;
 fs=DeleteDuplicates[Cases[e,_Log|_Arg|_Abs|_PolyLog,Infinity]];
 ss=Table[Unique["f"],Length[fs]];sr=Thread[fs->ss];
 polynomial=Expand[e/.sr,Alternatives@@ss];
 result=Collect[polynomial,ss,Function[c,Factor[Together[c]]]]/.Thread[ss->fs];
 <|"Difference"->result,"InverseHyperbolicRules"->cr,"RadicalRules"->rr,"LogarithmRules"->lr,"FunctionBasis"->fs|>
];
calculate[task_]:=Module[{ch,case,mode,dst,parent,manifest,own,pj,author,literal,driver,inputHash,wrule,domain,
 norm,coupling,matrix,xrule,charge,caseMap,idx,local,raw,ref,delta,ep,complete,diff,reduced,omitted,out,path,
 genericLogGate,genericPhaseGate,litdiff,save},
 {ch,case,mode}=task;dst=FileNameJoin[{root,ch}];parent=FileNameJoin[{scripts,ch}];
 path=FileNameJoin[{dst,"s02_"<>case<>"_"<>mode<>"_result.wl"}];
 inputHash=Hash[{FileHash[comparisonSource,"SHA256"],FileHash[FileNameJoin[{dst,"s01_inputs.json"}],"SHA256"]},"SHA256"];
 If[FileExistsQ[path],save=Get[path];If[save["InputHash"]===inputHash&&TrueQ[save["Completed"]],Return[save]]];
 out=Catch[
 log[{"symbolic start",task}];
 manifest=Import[FileNameJoin[{dst,"s01_inputs.json"}],"RawJSON"];
 gate["current production hash",FileHash[FileNameJoin[{scripts,manifest["Production"]}],"SHA256","HexString"]===manifest["ProductionSHA256"]];
 own=Get[FileNameJoin[{scripts,manifest["Production"]}]];
 pj=Get[FileNameJoin[{parent,"s05_result","projectors.wl"}]];
 author=Get[FileNameJoin[{dst,"s01_reconstructed.wl"}]][mode][case];
 literal=Get[FileNameJoin[{dst,"s01_literal.wl"}]][mode][case];
 driver=Get[FileNameJoin[{dst,"s01_driver.wl"}]];
 coupling=First[driver["gs2"]]/.sourceAlphaS[_]->alphaS;
 norm=Cancel[(Last[driver["factor"]]/lum)/(z jac/(xi zeta^2))/.zh->z/zeta]/.gs2->coupling;
 gate["normalization independent of convolution coordinates",FreeQ[norm,xi|zeta|z|zh|jac|lum]];
 matrix=Table[Coefficient[({f1,f2}/.pj/.D->4)[[i]],h],{i,2},{h,{Hg,Hpp}}];
 gate["projectors equal pinned driver",And@@Table[Together[
 matrix[[i]].{Fg,Fpp}-(First[driver[{"F1h","F2h"}[[i]]]]/.Q->Sqrt[Q2]) ]===0,{i,2}]];
 xrule=First[Solve[s==(s/.own["hat_variable_rules"]),xh]];
 matrix=matrix/.xrule;
 wrule=First[Solve[rho^2==own["rho_squared"],w]];
 gate["radical coordinate inverse",Together[(own["rho_squared"]/.wrule)-rho^2]===0];
 domain=(ReleaseHold[own["support"]]/.wrule)&&rho>0&&mu2>0&&alphaS>0;
 genericLogGate=FullSimplify[Log[Abs[a b]]-Log[Abs[a]]-Log[Abs[b]],Element[{a,b},Reals]&&a!=0&&b!=0]===0;
 genericPhaseGate=FullSimplify[Log[a]-Log[Abs[a]]-I Arg[a],Element[a,Reals]&&a!=0]===0;
 gate["exact logarithm modulus and principal phase identities",genericLogGate&&genericPhaseGate];
 caseMap=<|"A"->"eq2","B"->"eq_eqp","C"->"eqp2"|>;
 idx=First@FirstPosition[{"Pg","Ppp"},mode];
 charge=Switch[ch,"Hgg_v2",chargeSum,"Hqqbar_v2",eq2,"Hqqprime_v2",1];
 local=If[ch==="Hqqprime_v2",Values[own["contraction_charge_components"][caseMap[case]]][[idx]],Values[own["contractions"]][[idx]]/charge]/.Nc->3;
 raw=author/.{Q->Sqrt[Q2],mu->Sqrt[mu2]};
 delta=Quiet[raw["delta"]/.w->0];
 ep=Quiet[Lookup[raw,{"plus1B","plus2B"}]/.w->0];
 gate["direct endpoint substitution finite",FreeQ[{delta,ep},Indeterminate|_DirectedInfinity]];
 gate["this channel has no delta or plus endpoint",delta===0&&ep==={0,0}&&own["delta"]==={0,0}&&own["plus"]==={0,0}];
 complete=raw["regular"]+raw["plus1B"]/w+raw["plus2B"]Log[w]/w;
 ref=norm complete;
 diff=local-ref;
 Put[<|"InputHash"->inputHash,"Independent"->local,"Reference"->ref,"Difference"->diff,"RadicalMap"->wrule,"Assumptions"->domain|>,FileNameJoin[{dst,"s02_"<>case<>"_"<>mode<>"_input.wl"}]];
 log[{"reducing complete tensor",task,LeafCount[diff]}];
 reduced=bounded[reduceExpression[diff,wrule,domain],{"tensor reduction",task}];
 log[{"tensor reduced",task,LeafCount[reduced["Difference"]],reduced["Difference"]===0}];
 omitted=norm(raw["plus1B"]/w+raw["plus2B"]Log[w]/w);
 litdiff=norm((literal["regular"]-author["regular"])+
 (literal["plus1B"]-author["plus1B"])/w+(literal["plus2B"]-author["plus2B"])Log[w]/w)/.{Q->Sqrt[Q2],mu->Sqrt[mu2]};
 out=<|"Completed"->True,"InputHash"->inputHash,"Channel"->ch,"Case"->case,"Tensor"->mode,
 "ProductionSHA256"->manifest["ProductionSHA256"],"Normalization"->norm,"ProjectorMatrix"->matrix,"ChargeFactor"->charge,
 "EndpointDelta"->delta,"EndpointPlus"->ep,"Independent"->local,"Reference"->ref,
 "RawDifference"->diff,"Reduced"->reduced,"Equal"->TrueQ[reduced["Difference"]===0],
 "DifferenceFromLiteralReference"->diff-litdiff,"LiteralMinusReconstructed"->litdiff,
 "DriverOmittedContribution"->omitted,"RadicalMap"->wrule,"PhysicalDomain"->domain,
 "LogIdentitiesChecked"->{genericLogGate,genericPhaseGate}|>;
 gate["unchanged production after comparison",FileHash[FileNameJoin[{scripts,manifest["Production"]}],"SHA256","HexString"]===manifest["ProductionSHA256"]];
 out,"stage"];
 If[!AssociationQ[out]||!TrueQ[out["Completed"]],out=<|"Completed"->False,"InputHash"->inputHash,"Channel"->ch,"Task"->task,"Failure"->out|>];
 Put[out,path];log[{"symbolic finished",task,out["Completed"],out["Equal"]}];ClearSystemCache[];out
];
DistributeDefinitions[root,scripts,comparisonSource,log,gate,bounded,canonicalLog,reduceExpression,calculate];
tasks=Join[Flatten[Table[{ch,"A",mode},{ch,{"Hgg_v2","Hqqbar_v2"}},{mode,{"Pg","Ppp"}}],1],
 Flatten[Table[{"Hqqprime_v2",c,m},{c,{"A","B","C"}},{m,{"Pg","Ppp"}}],1]];
results=ParallelMap[calculate,tasks,Method->"FinestGrained"];
Do[
 rows=Select[results,#["Channel"]===ch&];
 Put[<|"Channel"->ch,"Results"->rows,"AllCompleted"->AllTrue[rows,TrueQ[#["Completed"]]&],"AllTensorDifferencesZero"->AllTrue[rows,TrueQ[#["Equal"]]&]|>,FileNameJoin[{root,ch,"s02_result.wl"}]],
 {ch,{"Hgg_v2","Hqqbar_v2","Hqqprime_v2"}}];
CloseKernels[];log[{"S03_REGULAR_COMPARISONS_COMPLETE",Counts[Lookup[results,"Equal"]]}];
Exit[If[AllTrue[results,TrueQ[#["Completed"]]&],0,1]];

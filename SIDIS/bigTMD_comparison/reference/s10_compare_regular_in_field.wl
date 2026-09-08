If[!TrueQ[SyntaxQ[Import[$InputFileName,"Text"]]],Print["FAIL syntax"];Exit[1]];
$HistoryLength=0;$MaxExtraPrecision=2500;
root=DirectoryName[$InputFileName];scripts=DirectoryName[root];SetDirectory[root];
source=FileNameJoin[{root,"s10_compare_regular_in_field.wl"}];
log[x_]:=Print[DateString[{"ISODate","T","Time"}]," ",x];
gate[n_,v_]:=If[!TrueQ[v],Throw[<|"FailedGate"->n,"Value"->v|>,"field"]];
SetAttributes[bounded,HoldFirst];
bounded[e_,n_]:=TimeConstrained[MemoryConstrained[e,2500000000,Throw[<|"FailedGate"->n,"Reason"->"memory"|>,"field"]],600,Throw[<|"FailedGate"->n,"Reason"->"time"|>,"field"]];
helperText=Import[FileNameJoin[{root,"s05_compare_distributions.wl"}],"Text"];
helperCode=StringTake[helperText,{First[First[StringPosition[helperText,"unitDilogarithm[argument_"]]],First[First[StringPosition[helperText,"reduceAlgebraic[expression_"]]]-1}];
ToExpression[helperCode];
dilogarithms=Get[FileNameJoin[{scripts,"Hqg_v3","s13_dilogarithms.wl"}]];
fieldTerm[term_,polynomial_]:=Module[{value,n,d,nr,dr,extended,g,inverse,answer},
 value=Cancel[term];n=Numerator[value];d=Denominator[value];
 gate["rational coefficient polynomial numerator/denominator",PolynomialQ[n,radius]&&PolynomialQ[d,radius]];
 nr=PolynomialRemainder[n,polynomial,radius];dr=PolynomialRemainder[d,polynomial,radius];
 If[FreeQ[dr,radius],Return[Cancel[nr/dr]]];
 extended=PolynomialExtendedGCD[dr,polynomial,radius];g=First[extended];
 gate["denominator invertible in quadratic field",FreeQ[g,radius]&&g=!=0];
 inverse=extended[[2,1]]/g;
 gate["quadratic field inverse identity",Together[PolynomialRemainder[dr inverse-1,polynomial,radius]]===0];
 answer=PolynomialRemainder[nr inverse,polynomial,radius];
 gate["field representative has degree below defining polynomial",PolynomialQ[answer,radius]&&Exponent[answer,radius]<Exponent[polynomial,radius]];
 Cancel[answer]
];
rationalSum[terms_]:=Module[{factored,groups,reduced},
 factored=Factor/@terms;groups=GatherBy[factored,Denominator];
 gate["grouped rational sum preserves all terms",Sort[Flatten[groups,1]]===Sort[factored]];
 reduced=Cancel[Total[#]]&/@groups;
 Factor[Together[Total[reduced]]]
];
fieldTask[path_]:=Module[{dst,ch,label,raw,manifest,hash,cacheDir,resultPath,out,poly,gram,physical,mappedDomain,map,expr,roots,rr,
 fs,frules,value,converted,phases,functions,slots,formal,terms,rows,groups,coefs,answers,coefPath,saved,vectors,
 vals,a,b,e,final,points,checks,point,rv,sourceHashes},
 dst=DirectoryName[path];ch=FileNameTake[dst];label=StringReplace[FileBaseName[path],"_input"->""];
 cacheDir=FileNameJoin[{dst,label<>"_field_cache"}];If[!DirectoryQ[cacheDir],CreateDirectory[cacheDir]];
 resultPath=FileNameJoin[{dst,label<>"_field_result.wl"}];
 hash=Hash[{FileHash[source,"SHA256"],FileHash[path,"SHA256"],Hash[helperCode,"SHA256"],Hash[dilogarithms,"SHA256"]},"SHA256"];
 If[FileExistsQ[resultPath],saved=Get[resultPath];If[saved["InputHash"]===hash&&TrueQ[saved["Completed"]],Return[saved]]];
 out=Block[{cache=cacheDir,inputHash=hash,acceptedInputHashes={hash}},Catch[
 log[{"quadratic field comparison",ch,label}];
 manifest=Import[FileNameJoin[{dst,"s01_inputs.json"}],"RawJSON"];
 gate["production source unchanged",FileHash[FileNameJoin[{scripts,manifest["Production"]}],"SHA256","HexString"]===manifest["ProductionSHA256"]];
 raw=Get[path];map=raw["AlgebraicMap"];physical=raw["Assumptions"];
 gate["an invertible recoil coordinate was saved",Length[map]===1];
 poly=Factor[Numerator[Together[(s23/.map)-s23]]];
 poly=Cancel[poly/Coefficient[poly,radius,Exponent[poly,radius]]];
 gram=Together[radius^2-poly];
 gate["quadratic square-root defining relation",Exponent[poly,radius]===2&&FreeQ[gram,radius]];
 gate["positive physical square root",FullSimplify[gram>0,physical]===True];
 mappedDomain=(physical/.map)&&radius>0;
 expr=raw["Difference"];
 roots=DeleteDuplicates[Cases[expr,p:Power[_,_Rational]:>p,Infinity]];
 rr=Table[
 ratio=Factor[First[r]/gram];
 gate["all recoil radicals use the same derived root",FreeQ[ratio,s23|radius]&&FullSimplify[ratio>0,physical]===True];
 r->(ratio^Last[r] radius^(2 Last[r])),{r,roots}];
 expr=expr/.rr;
 fs=DeleteDuplicates[Cases[expr,_Log|_PolyLog|_ArcTan|_ArcTanh|_ArcCoth|_Re|_Im,Infinity]];
 frules=Table[
 value=f/.map;
 If[MatchQ[value,_ArcTanh|_ArcCoth],converted=Refine[ComplexExpand[value],mappedDomain];
 gate["inverse hyperbolic functional identity",bounded[FullSimplify[converted-value,mappedDomain],"hyperbolic identity"]===0];value=converted];
 f->bounded[reduceFunction[value,mappedDomain],"function normalization"],{f,fs}];
 expr=expr/.frules;
 phases=DeleteDuplicates[Cases[expr,_Arg|_Abs|_Sign,Infinity]];
 expr=expr/.Table[p->bounded[reduceFunction[p/.map,mappedDomain],"phase normalization"],{p,phases}];
 functions=DeleteDuplicates[Cases[expr,_Log|_PolyLog|_ArcTan|_ArcTanh|_ArcCoth|_Re|_Im,Infinity]];
 slots=Array[formalFunction,Length[functions]];
 formal=Expand[expr/.Thread[functions->slots],Alternatives@@slots];
 gate["polynomial in formal special functions",PolynomialQ[formal,slots]];
 terms=If[Head[formal]===Plus,List@@formal,{formal}];
 rows=Map[Function[term,With[{factors=If[Head[term]===Times,List@@term,{term}]},
 {Times@@Select[factors,!FreeQ[#,Alternatives@@slots]&],Times@@Select[factors,FreeQ[#,Alternatives@@slots]&]}]],terms];
 gate["formal term partition reconstructs input",And@@MapThread[SameQ,{Times@@@rows,terms}]];
 groups=GatherBy[rows,First];coefs=({#[[1,1]],Total[#[[All,2]]]}&/@groups);
 gate["coefficient grouping preserves rows",Sort[Flatten[groups,1]]===Sort[rows]];
 Put[<|"InputHash"->hash,"Polynomial"->poly,"RadicalRules"->rr,"FunctionRules"->frules,"Functions"->functions,"Coefficients"->coefs,
 "PhysicalDomain"->physical,"MappedDomain"->mappedDomain|>,FileNameJoin[{dst,label<>"_field_input.wl"}]];
 answers=Table[
 coefPath=FileNameJoin[{cacheDir,"Coefficient_"<>ToString[j]<>".wl"}];
 saved=If[FileExistsQ[coefPath],Get[coefPath],<||>];
 If[saved["InputHash"]===hash&&saved["CoefficientHash"]===Hash[Last[coefs[[j]]],"SHA256"],saved["Value"],
 log[{"field coefficient",ch,label,j,Length[coefs],LeafCount[Last[coefs[[j]]]]}];
 terms=If[Head[Last[coefs[[j]]]]===Plus,List@@Last[coefs[[j]]],{Last[coefs[[j]]]}];
 vectors=MapIndexed[Function[{term,index},
 value=bounded[fieldTerm[term,poly],{"field term",j,First[index]}];
 If[Mod[First[index],100]===0,log[{"field terms reduced",ch,label,j,First[index],Length[terms]}]];
 {Coefficient[value,radius,0],Coefficient[value,radius,1]}],terms];
 a=bounded[rationalSum[vectors[[All,1]]],{"constant field coefficient",j}];
 b=bounded[rationalSum[vectors[[All,2]]],{"linear field coefficient",j}];
 v=a+b radius;Put[<|"InputHash"->hash,"CoefficientHash"->Hash[Last[coefs[[j]]],"SHA256"],"Value"->v|>,coefPath];
 log[{"field coefficient finished",ch,label,j,v===0,LeafCount[v]}];v],
 {j,Length[coefs]}];
 final=Total[MapThread[Times,{answers,First/@coefs}]]/.Thread[slots->functions];
 points=Table[{Q->2,s->10,omega->1,mu->3,B->2,nf->4,alphaS->1/5,eq->2/3,otherChargeMoment[1]->0,otherChargeMoment[2]->0,s23->wvalue},{wvalue,{1/7,3/7}}];
 checks=Table[
 point=Join[p,{radius->Sqrt[gram/.p]}];
 gate["numeric point lies in physical field domain",TrueQ[physical/.point]&&TrueQ[(poly/.point)===0]];
 vals=bounded[N[{raw["Difference"],final}/.point,90],"original versus field validation"];
 gate["finite high-precision equality check",And@@(NumericQ/@vals)&&TrueQ[Abs[Subtract@@vals]<10^-60 Max[1,Abs[First[vals]],Abs[Last[vals]]]]];
 <|"Point"->point,"Values"->vals|>,{p,points}];
 <|"Completed"->True,"Channel"->ch,"InputHash"->hash,"InputSHA256"->FileHash[path,"SHA256","HexString"],
 "SourceSHA256"->FileHash[source,"SHA256","HexString"],"Difference"->final,"Equal"->TrueQ[final===0],
 "AlgebraicRelation"->(poly==0),"PhysicalDomain"->physical&&radius>0&&poly==0,"FunctionRules"->frules,
 "CoefficientRemainders"->answers,"NumericalChecks"->checks,"Method"->"Exact quadratic-field numerator/denominator reduction with checked polynomial inverses; coefficients remain in the original recoil variable."|>,"field"]];
 If[!AssociationQ[out]||!TrueQ[out["Completed"]],out=<|"Completed"->False,"InputHash"->hash,"Channel"->ch,"Failure"->out|>];
 Put[out,resultPath];log[{"field task finished",ch,label,out["Completed"],out["Equal"]}];out
];
paths=Flatten[FileNames["s02_*_Regular_input.wl",FileNameJoin[{root,#}]]&/@{"Hgq_v4","Hqq_v4"}];
paths=Select[paths,Function[p,With[{rp=StringReplace[p,"_input.wl"->"_result.wl"]},
 !FileExistsQ[rp]||!TrueQ[Get[rp]["Completed"]]||!TrueQ[Get[rp]["Equal"]]]]];
LaunchKernels[KernelConfiguration["localhost","KernelCommand"->"/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel","KernelCount"->Min[4,Max[1,Length[paths]]],"TimeConstraint"->60]];
If[Length[Kernels[]]===0,Print["FAIL no kernels"];Exit[1]];
ParallelEvaluate[$HistoryLength=0;$MaxExtraPrecision=2500];
DistributeDefinitions[root,scripts,source,log,gate,bounded,helperCode,dilogarithms,unitDilogarithm,reduceDilogarithm,reduceFunction,fieldTerm,rationalSum,fieldTask];
results=ParallelMap[fieldTask,paths,Method->"FinestGrained"];Put[results,"s10_result.wl"];CloseKernels[];
log["S10_FIELD_COMPARISON_FINISHED"];Exit[If[AllTrue[results,TrueQ[#["Completed"]]&],0,1]];


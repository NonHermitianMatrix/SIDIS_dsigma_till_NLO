(* Frozen-artifact hard-function preparation. No reference hard coefficients. *)
$HistoryLength = 0; $IterationLimit = Infinity;
$LoadAddOns = If[Environment["SIDIS_S05_MODE"]==="export",{"FeynHelpers"},{}]; $FeynCalcStartupMessages = False;
If[!MemberQ[$Packages,"FeynCalc`"],Get["FeynCalc`"]];
root = DirectoryName[$InputFileName];
scripts = ParentDirectory[root];
out = FileNameJoin[{root,"s05_cache"}];
If[!DirectoryQ[out],CreateDirectory[out]];
outputTag=Environment["SIDIS_OUTPUT_TAG"];
If[StringQ[outputTag] && outputTag=!="",out=FileNameJoin[{out,outputTag}];
 If[!DirectoryQ[out],CreateDirectory[out]]];
finish[code_] := If[Environment["SIDIS_WORKER"]==="1",Throw[code,"S05Exit"],Quit[code]];
require[b_,msg_] := If[!TrueQ[b],Print["S05_FATAL ",msg];finish[1]];
mode = Environment["SIDIS_S05_MODE"];
Print["S05_START ",mode];
require[mode === "export","unsupported mode"];
producerHash=FileHash[$InputFileName,"SHA256","HexString"];
sourceSnapshot=FileNameJoin[{out,"s05_source_"<>producerHash<>".wl"}];
If[!FileExistsQ[sourceSnapshot],CopyFile[$InputFileName,sourceSnapshot]];
channel = Environment["SIDIS_CHANNEL"];
selectedHat=Environment["SIDIS_HAT"];selectedBranch=Environment["SIDIS_BRANCH"];
manifest = Import[FileNameJoin[{root,"s01_result"}],"RawJSON"];
entry = SelectFirst[manifest["channels"],#["channel"]===channel&];
require[AssociationQ[entry],"unknown channel"];
Do[If[f["role"]==="terminal_fhat_payload",
 require[FileHash[FileNameJoin[{root,f["copy"]}],"SHA256","HexString"]===f["sha256"],"frozen input hash"]],
 {f,entry["files"]}];
maps = Import[FileNameJoin[{root,"s04_result"}],"RawJSON"];
require[maps["status"]==="Complete" && And@@Values[maps["checks"]],"S04 checks"];
invariantContractPath=FileNameJoin[{root,"s10_cache","s10_invariant_contract_result"}];
invariantContract=Import[invariantContractPath,"RawJSON"];
require[invariantContract["status"]==="Complete" && And@@Values[invariantContract["checks"]] &&
 invariantContract["input_sha256"]===FileHash[FileNameJoin[{root,"s04_result"}],"SHA256","HexString"],"inverse invariant map contract"];
invariantRules=KeyValueMap[ToExpression[#1]->ToExpression[#2]&,invariantContract["wolfram"]];
boundaryRows={};
If[MemberQ[{"Hqq_v4","Hgq_v4","Hqg_v3"},channel],
 v4Contract=Import[FileNameJoin[{root,"s03_cache",channel<>"_consumer_contract"}],"RawJSON"];
 require[v4Contract["Status"]==="Complete" && And@@Values[v4Contract["Checks"]] &&
  v4Contract["NormalizedPlusLogarithm"] && v4Contract["CoordinateBoundaryPresent"],"v4 consumer contract"];
 require[v4Contract["InputSHA256"]===FileHash[FileNameJoin[{root,"Fhats",channel,If[channel==="Hqg_v3","s12_result.wl","s10_result.wl"]}],"SHA256","HexString"],"v4 contract input identity"];
 actions=Import[FileNameJoin[{root,"s08_result"}],"RawJSON"];
 require[actions["status"]==="Complete" && And@@Values[actions["checks"]],"v4 flavor and boundary derivation"];
 boundaryRows=actions["v4_boundary_benchmark_rows"]];
Quiet[PaXEvaluate[A0[1]]];
require[NumberQ[N[PaXDiLog[2,1],25]],"Package-X numeric initialization"];
colorDimension=3; (* SU(3), the defining gauge group. *)
groupCF = SUNSimplify[SUNT[colA].SUNT[colA],SUNNToCACF->False] /. SUNN->colorDimension;
(* External physical couplings and charges remain arguments to the evaluator. *)
parameters={Q2,s,t,ss,B,mu2,xh,zH,PHT2,xB,xi,as,cq,co,ns,no,nf,csum,omega};
canonical[e_] := e /. {
  FeynCalc`FCGV["EL"]->1,FeynArts`FCGV["EL"]->1,
  SMP["g_s"]->Sqrt[4 Pi as], FAGS->Sqrt[4 Pi as],
  alphaS->as, eq->cq, eqp->co, eq2->cq^2, chargeSum->csum,
  otherChargeMoment[1]->co,otherChargeMoment[2]->ns,w->ss,Nf->nf, Nc->colorDimension,SUNN->colorDimension,CA->colorDimension,
  ScaleMu->Sqrt[mu2],mu->Sqrt[mu2],sHat->s,tHat->t,t1->t,
  xHat->xh,z->zH,s23->ss,sig->ss,BB->B,
  HqqV2Charge["UpType"]->cq,HqqV2Charge["DownType"]->co,
  HqqV2FlavorMultiplicity["UpType"]->ns,HqqV2FlavorMultiplicity["DownType"]->no,
  HggFlavorChargeSum->csum};
functionRecords={};
deltaNormalization=Integrate[DiracDelta[s05Recoil],{s05Recoil,-Infinity,Infinity}];
require[deltaNormalization===1,"delta distribution normalization"];
deltaSupportRule=ss->Integrate[s05Recoil DiracDelta[s05Recoil],{s05Recoil,-Infinity,Infinity}]/deltaNormalization;
(* CForm emits some atomic rationals as machine decimals. Preserve their
   numerator and denominator before formatting; the consumer executes division. *)
exactC[xx_] := ToString[xx /. r_Rational :> rational[Numerator[r],Denominator[r]],CForm];
heldC[HoldComplete[xx_]] := exactC[xx];
Clear[pax]; pax[a_?NumericQ,b_?NumericQ] := PaXDiLog[a,b];

compactRationalCoefficients[expression_,label_] := Module[
 {atoms,dummies,rules,polynomial,compacted,records={},result,oneCoefficient,
  rootAtoms,rootKeys,rootSymbols,rootRules,rootBack,rootIndex,collectionVariables},
 atoms=DeleteDuplicates@Cases[expression,
   _Log|_pax|_PolyLog|_ArcTan|_ArcTanh|_ArcCoth|_Re|_Im|_Conjugate,Infinity];
 If[atoms==={},
   result=Factor[Cancel[Together[expression]]];
   require[Cancel[Together[expression-result]]===0,"rational reconstruction "<>label];
   Print["S05_COMPACT_RATIONAL ",label," leaves=",LeafCount[result]];Return[result]];
 dummies=Table[Unique["s05Transcendental"],{Length[atoms]}];
 rules=Thread[atoms->dummies];
 polynomial=expression/.rules;
 rootAtoms=DeleteDuplicates@Cases[polynomial,Power[_,_Rational],Infinity];
 rootKeys=DeleteDuplicates[({#[[1]],Denominator[#[[2]]]}&/@rootAtoms)];
 rootSymbols=Table[Unique["s05Algebraic"],{Length[rootKeys]}];
 rootBack=MapThread[Rule,{rootSymbols,(#[[1]]^(1/#[[2]])&/@rootKeys)}];
 rootRules=Table[rootIndex=First@FirstPosition[rootKeys,{a[[1]],Denominator[a[[2]]]}];
   a->rootSymbols[[rootIndex]]^Numerator[a[[2]]],{a,rootAtoms}];
 require[And@@(TrueQ[Cancel[Together[First[#]-(Last[#]/.rootBack)]]===0]&/@rootRules),"algebraic root reconstruction "<>label];
 If[!TrueQ[PolynomialQ[polynomial,dummies]],Print["S05_COMPACT_NONPOLYNOMIAL ",label," atoms=",Length[atoms]," leaves=",LeafCount[polynomial]]];
 require[PolynomialQ[polynomial,dummies],"transcendental polynomial structure "<>label];
 collectionVariables=Join[dummies,Select[{as,cq,co,ns,no,nf},PolynomialQ[polynomial,#]&]];
 oneCoefficient[cc_] := Module[{simplified,residual,rational,cancelled},
   Print["S05_COEFFICIENT_START ",label," ",Length[records]+1," leaves=",LeafCount[cc]];
   rational=cc/.rootRules;
   cancelled=TimeConstrained[Cancel[Together[rational]],180,$Failed];
   require[cancelled=!=$Failed,"rational coefficient time limit "<>label];
   simplified=TimeConstrained[Factor[cancelled],30,HornerForm[Numerator[cancelled]]/HornerForm[Denominator[cancelled]]];
   residual=Cancel[Together[rational-simplified]];
   require[residual===0,"rational coefficient reconstruction "<>label];
   AppendTo[records,True];simplified/.rootBack];
 Print["S05_COMPACT_START ",label," atoms=",Length[atoms]," leaves=",LeafCount[expression]];
 compacted=Collect[polynomial,collectionVariables,oneCoefficient];
 result=compacted/.Thread[dummies->atoms];
 require[records=!={} && FreeQ[result,Alternatives@@dummies],"coefficient compaction gate "<>label];
 Print["S05_COMPACT_DONE ",label," rational_checks=",Length[records]," leaves=",LeafCount[result]];
 result
];

prepare[e0_,branch_,label_] := Module[{e=e0,rr,atoms,mplRules,h,zeroCoefficients,zeroDegree,original},
 e=canonical[e];
 If[channel==="Hqq_v2",
   (* Protect logs while replacing an exactly degenerate square root. *)
   e=e/.Log[a_]:>logHold[a];
   If[StringContainsQ[label,"Delta"],e=e/.u->-Q2-s-t];
   rootAtoms=DeleteDuplicates@Cases[e,Power[a_,b_Rational]/;Denominator[b]===2 && FreeQ[a,ss]:>Power[a,b],Infinity];
   rr=Table[a->FullSimplify[a,Element[{s,t,Q2},Reals] && s>0 && Q2>0 && -Q2-s<t<0 &&
       If[branch===1,s+t>0,s+t<0]],{a,rootAtoms}];
   e=e/.rr;
   atoms=DeleteDuplicates@Cases[e,logHold[a_]:>a,Infinity];
   e=e/.Table[logHold[a]->If[TrueQ[Cancel[a]===0],logZero,Log[a]],{a,atoms}];
   If[!FreeQ[e,logZero],
     Print["S05_LOGZERO_CHECK ",label];
     zeroDegree=Exponent[e,logZero];
     zeroCoefficients=Table[Cancel[Together[Coefficient[e,logZero,k]/.xB->xi xh/.invariantRules/.
       omega->Refine[Abs[s+t],Element[{s,t},Reals] && If[branch===1,s+t>0,s+t<0]]]],{k,1,zeroDegree}];
     zeroCoefficients=zeroCoefficients/.Log[a_]:>Log[Cancel[a]];
     If[!And@@(#===0&/@zeroCoefficients),Put[zeroCoefficients,
       FileNameJoin[{out,"s05_"<>channel<>"_"<>label<>"_logzero_residual.wl"}]]];
     require[And@@(#===0&/@zeroCoefficients),"uncancelled log(0): "<>label];
     e=e/.logZero->0;
   ];
 ];
 e=e/.PolyGamma[a_,b_]:>FunctionExpand[PolyGamma[a,b]];
 require[FreeQ[e,xx_ /; (!AtomQ[xx] && MemberQ[{"Mpl","Hlog"},SymbolName[Head[xx]]])],"current inputs require no MPL conversion"];
 e=e/.xx_ /; (!AtomQ[xx] && SymbolName[Head[xx]]==="mzv" && List@@xx==={2}):>
    Sum[1/kk^2,{kk,1,Infinity}];
 e=e/.PaXDiLog[a_,b_]:>pax[a,b];
 require[FreeQ[e,Indeterminate|ComplexInfinity|DirectedInfinity[_]|logZero],"nonfinite symbolic expression "<>label];
 original=e;
 If[MemberQ[{"Hqq_v4","Hgq_v4","Hqg_v3","Hgg_v2","Hqqbar_v2","Hqqprime_v2"},channel],
   Print["S05_REGULAR_EXACT ",label," leaves=",LeafCount[e]];
   Return[{original,e}]];
 e=e/.Log[a_]:>logHold[a];
 e=e/.xB->xi xh/.invariantRules;
 If[StringContainsQ[label,"Delta"],e=e/.deltaSupportRule];
 Print["S05_INVARIANT_MAP ",label," leaves=",LeafCount[e]];
 e=e/.omega->Refine[Abs[s+t],Element[{s,t},Reals] && If[branch===1,s+t>0,s+t<0]];
 rr=DeleteDuplicates@Cases[e,Power[a_,b_Rational]/;!FreeQ[a,xi]:>Power[a,b],Infinity];
 e=e/.Table[a->Refine[Power[Factor[a[[1]]],a[[2]]],xi>0],{a,rr}];
 atoms=DeleteDuplicates@Cases[e,logHold[a_]:>a,Infinity];
 e=e/.Table[logHold[a]->With[{value=Factor[Cancel[Together[a]]]},If[value===0,logZero,Log[value]]],{a,atoms}];
 e=e/.pax[a_,b_]:>pax[Factor[Cancel[Together[a]]],Factor[Cancel[Together[b]]]];
 If[!FreeQ[e,logZero],zeroDegree=Exponent[e,logZero];
   zeroCoefficients=Table[Cancel[Together[Coefficient[e,logZero,k]]],{k,1,zeroDegree}];
   require[And@@(#===0&/@zeroCoefficients),"mapped singular logarithm "<>label];e=e/.logZero->0];
 e=compactRationalCoefficients[e,label];
 require[FreeQ[e,xi|xB|zH|PHT2|xh],"redundant kinematic variables "<>label];
 {original,e}
];

evaluatePrepared[expression_,substitutions_,label_] := Module[{value,degree,coefficients,atoms,logs,precision=180,valid=False},
 atoms=DeleteDuplicates@Cases[expression,Log[a_]:>a,Infinity];
 While[!valid && precision<=780,
   logs=Table[Log[a]->With[{exact=Together[a/.substitutions]},
      If[PossibleZeroQ[exact],logZero,N[Log[exact],precision]]],{a,atoms}];
   value=(expression/.logs)/.N[substitutions,precision];
   If[!FreeQ[value,logZero],degree=Exponent[value,logZero];
     coefficients=Table[N[Coefficient[value,logZero,k],100],{k,1,degree}];
     require[And@@(TrueQ[Abs[#]<10^-60]&/@coefficients),"nonzero singular-log sample "<>label];value=value/.logZero->0];
   valid=NumberQ[value] && FreeQ[value,Indeterminate|ComplexInfinity|DirectedInfinity[_]] &&
      (TrueQ[Precision[value]>=80] || TrueQ[Abs[value]<10^-80]);
   If[!valid,Print["S05_PRECISION_REFINE ",label," digits=",precision];precision+=100]];
 require[valid,"nonfinite or imprecise Wolfram sample "<>label];N[value,100]
];

exportFunction[e0_,label_,branch_,endpoint_,jacobianIncluded_,chargeCase_:"A"] := Module[
 {name,e,opt,held,assignments,last,vars,unknown,records,rows,sub,value,values,args,lines,file,ret,prepared,original,originalValue},
 name=StringReplace[channel<>"_"<>label<>"_"<>ToString[branch],"-"->"m"];
 file=FileNameJoin[{out,name<>".json"}];
 If[FileExistsQ[file],
   ret=Import[file,"RawJSON"];
   If[ret["ProducerSHA256"]===producerHash,
     AppendTo[functionRecords,ret];Print["S05_RESUME ",name];Return[]]];
 Print["S05_PREPARE ",name," leaves=",LeafCount[e0]];
 prepared=prepare[e0,branch,label];original=prepared[[1]];e=prepared[[2]];Clear[prepared];
 unknown=Complement[DeleteDuplicates@Cases[e,sym_Symbol /; Context[sym]=!="System`":>sym,Infinity,Heads->True],
   Join[parameters,{pax}]];
 require[unknown==={},"remaining symbols "<>ToString[unknown,InputForm]<>" "<>name];
 rows=Select[Join[maps["benchmark_rows"],invariantContract["benchmark_rows"],boundaryRows],#["branch"]===branch &&
   (MemberQ[{"L0","L1"},Last[StringSplit[label,"_"]]] || #["endpoint"]===endpoint)&];
 require[Length[rows]>0,"no validation points"];
 records=Table[
   (* S04 supplies exact rational invariants after the transverse square is formed. *)
   sub=Table[par->Switch[par,
     ss,ToExpression[row["exact"]["s23"]],xh,ToExpression[row["exact"]["xHat"]],
     as,1/5,cq,2/3,co,-1/3,ns,2,no,2,nf,4,csum,Total[{2/3,-1/3,-1/3,2/3}^2],
     omega,Abs[ToExpression[row["exact"]["s"]]+ToExpression[row["exact"]["t"]]],
     _,ToExpression[row["exact"][ToString[par,InputForm]]]],{par,parameters}];
   value=evaluatePrepared[e,sub,name];originalValue=evaluatePrepared[original,sub,name<>" original"];
   require[TrueQ[Abs[value-originalValue]<10^-20 Max[1,Abs[originalValue]]],"original versus invariant expression "<>name];
   (* Machine reference fields match the consumer ABI and avoid RawJSON's
      nonstandard 0.e-accuracy spelling for arbitrary-precision zero. *)
   <|"Arguments"->SetPrecision[parameters/.sub,MachinePrecision],
     "Real"->SetPrecision[Re[value],MachinePrecision],"Imaginary"->SetPrecision[Im[value],MachinePrecision],
     "OriginalReal"->SetPrecision[Re[originalValue],MachinePrecision],
     "OriginalImaginary"->SetPrecision[Im[originalValue],MachinePrecision],"InvariantReconstruction"->True|>,{row,rows}];
 Clear[original];
 Print["S05_OPTIMIZE ",name," leaves=",LeafCount[e]];
 opt=Experimental`OptimizeExpression[e,"OptimizationLevel"->1,"OptimizationSymbol"->w];
 require[Head[opt]===Experimental`OptimizedExpression,"optimizer interface"];
 held=Apply[HoldComplete,opt];
 assignments=Cases[held,HoldPattern[Set[l_Symbol,r_]]:>{ToString[l,InputForm],exactC[r]},Infinity];
 last=held/.HoldComplete[Block[v_,CompoundExpression[sets___,last_]]]:>HoldComplete[last];
 If[last===held,last=held/.HoldComplete[Block[v_,last_]]:>HoldComplete[last]];
 require[FreeQ[last,Block|CompoundExpression|Set],"optimizer terminal extraction"];
 ret=<|"Name"->name,"Channel"->channel,"Label"->label,"Branch"->branch,"Endpoint"->endpoint,
   "ChargeCase"->chargeCase,"JacobianAlreadyIncluded"->jacobianIncluded,
   "ProducerSHA256"->producerHash,"FhatInputSHA256"->consumer["InputSHA256"],
   "CFormExactRationals"->True,"RationalCoefficientReconstruction"->False,
   "PreparationMethod"->If[MemberQ[{"Hqq_v4","Hgq_v4","Hqg_v3","Hgg_v2","Hqqbar_v2","Hqqprime_v2"},channel],"ExactUncollected","ExactRationalCoefficientCollection"],
   "InvariantContractSHA256"->FileHash[invariantContractPath,"SHA256","HexString"],
   "Arguments"->(ToString[#,InputForm]&/@parameters),"Assignments"->assignments,
   "ReturnC"->heldC[last],"Checks"->records,
   "InputLeafCount"->LeafCount[e0],"OptimizedLeafCount"->LeafCount[held],
   "PaxPositiveDirectionImagSign"->Sign[Im[N[PaXDiLog[2,1],25]]],
   "SpecialCForms"-><|"ArcCoth"->ToString[TrigToExp[ArcCoth[aa]],CForm]|>|>;
 Export[file,ret,"RawJSON"];
 AppendTo[functionRecords,ret];
 Print["S05_EXPORTED ",name," optimized=",LeafCount[held]];
 ClearSystemCache[];
];

consumer=Import[FileNameJoin[{root,"s03_cache",channel<>"_consumer_contract"}],"RawJSON"];
require[consumer["Status"]==="Complete" && And@@Values[consumer["Checks"]] &&
 consumer["JacobianAlreadyIncluded"]===False,"current partonic consumer contract"];
data=Get[FileNameJoin[{root,First[Select[entry["files"],#["role"]==="terminal_fhat_payload"&]]["copy"]}]];
require[consumer["InputSHA256"]===FileHash[FileNameJoin[{root,First[Select[entry["files"],#["role"]==="terminal_fhat_payload"&]]["copy"]}],"SHA256","HexString"],"consumer input binding"];
hats=If[StringQ[selectedHat] && selectedHat=!="",{selectedHat},{"F1","F2"}];
branches=If[StringQ[selectedBranch] && selectedBranch=!="",{ToExpression[selectedBranch]},If[KeyExistsQ[data,"Hats"],{1,-1,0},{1,-1}]];
If[KeyExistsQ[data,"Hats"],
 Do[
  exportFunction[data["Hats"][hat]["LODelta"],hat<>"_LODelta",branch,True,False];
  Do[ee=If[branch===0,data["BoundaryAtTEqualsMinusS"][hat][dist],data["Hats"][hat]["NLO"][branch][dist]];
   exportFunction[ee,hat<>"_"<>dist,branch,dist=!="Regular",False],
   {dist,{"Delta","L0","L1","Regular"}}],{hat,hats},{branch,branches}],
 require[data["delta"]==={0,0} && data["plus"]==={0,0},"regular-only supplied sectors"];
 If[channel==="Hqqprime_v2",
   labels=<|"eq2"->"IncomingChargeSquared","eqp2"->"PrimeChargeSquared","eq_eqp"->"MixedIncomingPrimeCharge"|>;
   Do[ee=data["charge_monomials"][key]*data["charge_components"][key][hat<>"hat"]/.rho->Sqrt[data["rho_squared"]];
     exportFunction[ee,hat<>"_"<>labels[key]<>"_Regular",branch,False,False,labels[key]],
     {hat,hats},{key,Keys[data["charge_components"]]},{branch,branches}],
   Do[ee=data["Fhats"][hat<>"hat"]/.rho->Sqrt[data["rho_squared"]];
     exportFunction[ee,hat<>"_Regular",branch,False,False],{hat,hats},{branch,branches}]]
];
Export[FileNameJoin[{out,channel<>"_result"}],<|"Stage"->"s05","Status"->"ExportComplete",
  "Channel"->channel,"Functions"->functionRecords|>,"RawJSON"];
Print["S05_CHANNEL_DONE ",channel];finish[0];

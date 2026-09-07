(* Frozen-artifact hard-function preparation. No reference hard coefficients. *)
$HistoryLength = 0; $IterationLimit = Infinity;
$LoadAddOns = If[Environment["SIDIS_S05_MODE"]==="export",{"FeynHelpers"},{}]; $FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = "/home/physics/projects/AI_Assisted_SIDIS/scripts/numerics";
scripts = ParentDirectory[root];
out = FileNameJoin[{root,"s05_cache","s05_worker_Hgq_F2_m1"}];
If[!DirectoryQ[out],CreateDirectory[out]];
require[b_,msg_] := If[!TrueQ[b],Print["S05_FATAL ",msg];Quit[1]];
mode = Environment["SIDIS_S05_MODE"];
Print["S05_START ",mode];
If[mode === "inspect",
 hqq = Get[FileNameJoin[{root,"Fhats","Hqq_v2","s08_result.wl"}]];
 expressions = Join[Values[hqq["F1Hat"]],Values[hqq["F2Hat"]]];
 atoms = DeleteDuplicates@Cases[expressions,
   x_ /; (!AtomQ[x] && MemberQ[{"Mpl","mzv","PaXDiLog","FCGV"},SymbolName[Head[x]]]) :>
     ToString[x,InputForm],Infinity];
 Print["S05_SPECIAL_ATOMS ",InputForm[atoms]];
 Put[atoms,FileNameJoin[{out,"special_atoms.wl"}]];
 Print["S05_LOAD_BORN Hqq_v2"];
 s03 = Get[FileNameJoin[{scripts,"Hqq_v2","s03_result.wl"}]];
 Print["S05_BORN_KEYS ",Keys[s03]];
 Print["S05_BORN ",InputForm[s03["Projected","Born"]]];
 Put[<|"Born"->s03["Projected","Born"],
    "Kinematics"->s03["Kinematics","TwoBody"],
    "SourceSHA256"->FileHash[FileNameJoin[{scripts,"Hqq_v2","s03_result.wl"}],"SHA256","HexString"]|>,
   FileNameJoin[{out,"hqq_born.wl"}]];
 test = Experimental`OptimizeExpression[(a+b c)^2+Log[a+b c],"OptimizationSymbol"->w];
 Print["S05_OPT_INTERFACE ",InputForm[test]];
 Print["S05_INSPECTION_DONE"];Quit[0]
];
require[mode === "export","unsupported mode"];
producerHash=FileHash[$InputFileName,"SHA256","HexString"];
sourceSnapshot=FileNameJoin[{out,"s05_source_"<>producerHash<>".wl"}];
If[!FileExistsQ[sourceSnapshot],CopyFile[$InputFileName,sourceSnapshot]];
channel = Environment["SIDIS_CHANNEL"];
If[channel==="Hqq_v2",
 consumerContract=Import[FileNameJoin[{root,"s10_cache","s10_consumer_contract_result"}],"RawJSON"];
 require[consumerContract["status"]==="Complete" && consumerContract["jacobian_already_included"]===False &&
   And@@Values[consumerContract["checks"]],"Hqq fragmentation Jacobian contract"]];
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
Quiet[PaXEvaluate[A0[1]]];
require[NumberQ[N[PaXDiLog[2,1],25]],"Package-X numeric initialization"];
Get[FileNameJoin[{scripts,"Hqq_v2","vendor","SubTropicaHyperIntica","HyperIntica.wl"}]];
HyperIntica`$QuietPrint=True; HyperIntica`$HyperVerbosity=0;
(* The repeated-letter integral is derived here from the Hlog definition. *)
repeatedLetter = Integrate[Integrate[1/(ww-aa),{ww,0,vv},Assumptions->aa<0 && vv>0]/(vv-aa),
   {vv,0,1},Assumptions->aa<0];
require[FreeQ[repeatedLetter,Integrate|ConditionalExpression],"repeated Hlog integral"];
colorDimension=3; (* SU(3), the defining gauge group. *)
groupCF = SUNSimplify[SUNT[colA].SUNT[colA],SUNNToCACF->False] /. SUNN->colorDimension;
(* External physical couplings and charges remain arguments to the evaluator. *)
parameters={Q2,s,t,ss,B,mu2,xh,zH,PHT2,xB,xi,as,cq,co,ns,no,nf,csum,omega};
canonical[e_] := e /. {
  FeynCalc`FCGV["EL"]->1,FeynArts`FCGV["EL"]->1,
  SMP["g_s"]->Sqrt[4 Pi as], FAGS->Sqrt[4 Pi as],
  alphaS->as, eq->cq, Nf->nf, Nc->colorDimension,SUNN->colorDimension,CA->colorDimension,
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
 If[MemberQ[{"Hgq_v3","Hqq_v2"},channel],
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
 atoms=DeleteDuplicates@Cases[e,xx_ /; (!AtomQ[xx] && SymbolName[Head[xx]]==="Mpl"):>xx,Infinity];
 mplRules=Table[
   h=HyperIntica`MplAsHlog@@(List@@Map[Cancel,a,{2}]);
   h=h/.HyperIntica`Hlog[1,{b_,c_}]/;TrueQ[Cancel[b-c]===0]:>(repeatedLetter/.aa->Cancel[b]);
   If[!FreeQ[h,HyperIntica`Hlog|HyperIntica`Mpl],Print["S05_MPL_DETAIL ",InputForm[{a,h,repeatedLetter}]]];
   require[FreeQ[h,HyperIntica`Hlog|HyperIntica`Mpl],"unreduced MPL "<>label];
   a->h,{a,atoms}];
 e=e/.mplRules;
 e=e/.xx_ /; (!AtomQ[xx] && SymbolName[Head[xx]]==="mzv" && List@@xx==={2}):>
    Sum[1/kk^2,{kk,1,Infinity}];
 e=e/.PaXDiLog[a_,b_]:>pax[a,b];
 require[FreeQ[e,Indeterminate|ComplexInfinity|DirectedInfinity[_]|logZero],"nonfinite symbolic expression "<>label];
 original=e;
 If[StringContainsQ[label,"Regular"],
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
 rows=Select[Join[maps["benchmark_rows"],invariantContract["benchmark_rows"]],#["branch"]===branch &&
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
   <|"Arguments"->N[parameters/.sub,17],"Real"->N[Re[value],17],"Imaginary"->N[Im[value],17],
     "OriginalReal"->N[Re[originalValue],17],"OriginalImaginary"->N[Im[originalValue],17],"InvariantReconstruction"->True|>,{row,rows}];
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
   "ProducerSHA256"->producerHash,
   "CFormExactRationals"->True,"RationalCoefficientReconstruction"->(!StringContainsQ[label,"Regular"]),
   "PreparationMethod"->If[StringContainsQ[label,"Regular"],"ExactUncollected","ExactRationalCoefficientCollection"],
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

Switch[channel,
 "Hqg_v3",
 data=Get[FileNameJoin[{root,"Fhats",channel,"s12_result.wl"}]];
 Do[
  exportFunction[data["Hats"][hat]["LODelta"],hat<>"_LODelta",branch,True,False];
  Do[exportFunction[data["Hats"][hat]["NLO"][branch][dist],hat<>"_"<>dist,branch,dist=!="Regular",False],
   {dist,{"Delta","L0","L1","Regular"}}],{hat,{"F1","F2"}},{branch,{1,-1}}],
 "Hqq_v2",
 data=Get[FileNameJoin[{root,"Fhats",channel,"s08_result.wl"}]];
 born=Get[FileNameJoin[{out,"hqq_born.wl"}]];
 bornValues=born["Born"]/.Pair[Momentum[k_,D],Momentum[k_,D]]->0/.D->4;
 Do[
  bornHat=Total@Table[data["ProjectorDerivation","WeightsFiniteXHat",hat,projector]*bornValues[projector],
    {projector,{"Pg","PPP"}}]*(2 Pi)/(2 Pi)^4;
  exportFunction[bornHat,hat<>"_LODelta",branch,True,False];
  exportFunction[data[hat,"Delta"],hat<>"_Delta",branch,True,False];
  plus=data[hat,"BoundedPlus"]/.HqqV2BoundedPlus[k_,a_,b_]:>plusTag[k];
  Do[
    cc=Coefficient[plus,plusTag[k]];
    exportFunction[cc,hat<>If[k===0,"_L0","_L1"],branch,True,False],{k,{0,1}}];
  exportFunction[data[hat,"Ordinary"],hat<>"_Regular",branch,False,False],{hat,{"F1Hat","F2Hat"}},{branch,{1,-1}}],
 "Hgq_v3",
 born=Get[FileNameJoin[{scripts,channel,"s01_result.m"}]];
 Do[
  bornHat=(If[hat==="F1hat",F1,F2]/.born["proj"])/.{Hg->born["A","Hg"],Hpp->born["A","Hpp"]}/.
    {eps->0,gs->Sqrt[4 Pi as],u->-Q2-s-t};
  exportFunction[bornHat*(2 Pi)/(2 Pi)^4,hat<>"_LODelta",branch,True,False];
  Do[
    ee=Get[FileNameJoin[{root,"Fhats",channel,"s09_fhats",hat<>"_"<>dist<>".m"}]];
    exportFunction[ee,hat<>"_"<>Switch[dist,"del","Delta","p1","L0","p2","L1","reg","Regular"],
      branch,dist=!="reg",False];Clear[ee];ClearSystemCache[],{dist,{"p2","p1","reg","del"}}],
   {hat,{"F2hat"}},{branch,{-1}}],
 "Hgg",
 data=Get[FileNameJoin[{root,"Fhats",channel,"s13_result"}]];
 Do[ee=data["FiniteHattedStructureFunctions",hat];
  require[Head[ee]===Inactive[Integrate],"Hgg action shape"];
  ee=First[ee]/.S13ConvolutionTest[___]->1;
  Do[exportFunction[ee,hat<>"_Regular",branch,False,True],{branch,{1,-1}}],{hat,{"F1Hat","F2Hat"}}],
 "Hqqbar",
 data=Get[FileNameJoin[{root,"Fhats",channel,"s13_result"}]];
 Do[require[data["FiniteCoefficientPairsByStructureFunction",hat,"Endpoint"]===0 &&
   data["FiniteCoefficientPairsByStructureFunction",hat,"IntegrandPhi0"]===0,"Hqqbar regular-only gate"];
  Do[exportFunction[cq^2*data["FiniteCoefficientPairsByStructureFunction",hat,"IntegrandPhiS"],hat<>"_Regular",branch,False,True],
    {branch,{1,-1}}],{hat,{"F1Hat","F2Hat"}}],
 "Hqqprime",
 Do[
  data=Get[FileNameJoin[{root,f["copy"]}]];
  require[data["FiniteCoefficientPair","Endpoint"]===0 && data["FiniteCoefficientPair","IntegrandPhi0"]===0,"Hqqprime regular-only gate"];
  ck=data["ChargeKey"];
  weight=Switch[ck,"IncomingChargeSquared",cq^2,"PrimeChargeSquared",co^2,"MixedIncomingPrimeCharge",cq co,_,$Failed];
  require[weight=!=$Failed,"Hqqprime charge key"];
  Do[exportFunction[weight*data["FiniteCoefficientPair","IntegrandPhiS"],data["StructureFunction"]<>"_"<>ck<>"_Regular",branch,False,True,ck],
   {branch,{1,-1}}];Clear[data];ClearSystemCache[],
  {f,Select[entry["files"],StringContainsQ[#["copy"],"s13_cache_"]&]}],
 _,require[False,"unimplemented channel"]
];
Export[FileNameJoin[{out,channel<>"_result"}],<|"Stage"->"s05","Status"->"ExportComplete",
  "Channel"->channel,"Functions"->functionRecords|>,"RawJSON"];
Print["S05_CHANNEL_DONE ",channel];Quit[0];

(* Frozen-artifact hard-function preparation. No reference hard coefficients. *)
$HistoryLength = 0; $IterationLimit = Infinity;
$LoadAddOns = {}; $FeynCalcStartupMessages = False;
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
If[MemberQ[{"Hqq","Hgq","Hqg"},channel],
 v4Contract=Import[FileNameJoin[{root,"s03_cache",channel<>"_consumer_contract"}],"RawJSON"];
 require[v4Contract["Status"]==="Complete" && And@@Values[v4Contract["Checks"]] &&
  v4Contract["NormalizedPlusLogarithm"] && v4Contract["CoordinateBoundaryPresent"],"v4 consumer contract"];
 require[v4Contract["InputSHA256"]===FileHash[FileNameJoin[{root,"Fhats",channel,"result.wl"}],"SHA256","HexString"],"v4 contract input identity"];
 actions=Import[FileNameJoin[{root,"s08_result"}],"RawJSON"];
 require[actions["status"]==="Complete" && And@@Values[actions["checks"]],"v4 flavor and boundary derivation"];
 boundaryRows=actions["v4_boundary_benchmark_rows"]];

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
Clear[pax];

SetAttributes[bounded,HoldFirst];
bounded[expression_] := MemoryConstrained[TimeConstrained[expression,1200,$Failed],2*1024^3,$Failed];
prepare[e0_,branch_,label_] := Module[{e=canonical[e0]},
 require[FreeQ[e,xx_ /; (!AtomQ[xx] && StringStartsQ[SymbolName[Head[xx]],"PaX"])],"no Package-X functions in SIDIS input"];
 require[FreeQ[e,Indeterminate|ComplexInfinity|DirectedInfinity[_]],"finite input "<>label];
 Print["S05_REGULAR_EXACT ",label," leaves=",LeafCount[e]];
 {e,e}
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
   If[ret["ProducerSHA256"]===producerHash &&
      Lookup[ret,"FhatInputSHA256",None]===consumer["InputSHA256"] &&
      ret["InvariantContractSHA256"]===FileHash[invariantContractPath,"SHA256","HexString"],
     AppendTo[functionRecords,ret];Print["S05_RESUME ",name];Return[]]];
 Print["S05_PREPARE ",name," leaves=",LeafCount[e0]];
 prepared=bounded[prepare[e0,branch,label]];require[prepared=!=$Failed,"preparation memory/time limit"];original=prepared[[1]];e=prepared[[2]];Clear[prepared];
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
 opt=bounded[Experimental`OptimizeExpression[e,"OptimizationLevel"->1,"OptimizationSymbol"->w]];
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
   "PreparationMethod"->If[MemberQ[{"Hqq","Hgq","Hqg","Hgg","Hqqbar","Hqqprime"},channel],"ExactUncollected","ExactRationalCoefficientCollection"],
   "InvariantContractSHA256"->FileHash[invariantContractPath,"SHA256","HexString"],
   "Arguments"->(ToString[#,InputForm]&/@parameters),"Assignments"->assignments,
   "ReturnC"->heldC[last],"Checks"->records,
   "InputLeafCount"->LeafCount[e0],"OptimizedLeafCount"->LeafCount[held],
   "PaxPositiveDirectionImagSign"->Length[Cases[e,_pax,Infinity]],
   "PaxABIFieldUnused"->FreeQ[e,_pax],
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
branches=If[StringQ[selectedBranch] && selectedBranch=!="",{ToExpression[selectedBranch]},If[AssociationQ[data["Fhats"]["F1"]],{1,-1,0},{1,-1}]];
If[AssociationQ[data["Fhats"]["F1"]],
 Do[
  exportFunction[data["Fhats"][hat]["LODelta"],hat<>"_LODelta",branch,True,False];
  Do[ee=data["Fhats"][hat]["NLO"][branch][dist];
   exportFunction[ee,hat<>"_"<>dist,branch,dist=!="Regular",False],
   {dist,{"Delta","L0","L1","Regular"}}],{hat,hats},{branch,branches}],
 require[And@@Flatten[Table[TrueQ[#===0]&/@Values[data[dist]],{dist,{"Delta","L0","L1"}}]],"regular-only supplied sectors"];
 If[channel==="Hqqprime",
   charges=Get[FileNameJoin[{root,"s03_cache","Hqqprime_charge_components.wl"}]];
   require[charges["InputSHA256"]===consumer["InputSHA256"],"charge decomposition source identity"];
   labels=<|"eq2"->"IncomingChargeSquared","eqp2"->"PrimeChargeSquared","eq_eqp"->"MixedIncomingPrimeCharge"|>;
   Do[ee=charges["Monomials"][key]*charges["Components"][key][hat];
     exportFunction[ee,hat<>"_"<>labels[key]<>"_Regular",branch,False,False,labels[key]],
     {hat,hats},{key,Keys[charges["Components"]]},{branch,branches}],
   Do[ee=data["Fhats"][hat];
     exportFunction[ee,hat<>"_Regular",branch,False,False],{hat,hats},{branch,branches}]]
];
Export[FileNameJoin[{out,channel<>"_result"}],<|"Stage"->"s05","Status"->"ExportComplete",
  "Channel"->channel,"Functions"->functionRecords|>,"RawJSON"];
Print["S05_CHANNEL_DONE ",channel];Print["S05_SUCCESS ",channel];finish[0];

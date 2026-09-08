(* Derive the consumer directly from the new SIDIS payloads. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;$LoadAddOns={};Get["FeynCalc`"];
root=DirectoryName[$InputFileName];source=$InputFileName;
cache=FileNameJoin[{root,"s03_cache"}];If[!DirectoryQ[cache],CreateDirectory[cache]];
require[test_,message_]:=If[!TrueQ[test],Print["FAIL: S03 ",message];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,message_]:=TimeConstrained[MemoryConstrained[value,2*1024^3,
 require[False,message<>" memory bound"]],300,require[False,message<>" time bound"]];
sha[path_]:=FileHash[path,"SHA256","HexString"];
homogeneousDegree[e_,variable_]:=Module[{degrees},
 If[FreeQ[e,variable],Return[0]];If[e===variable,Return[1]];
 Which[Head[e]===Times,Total[homogeneousDegree[#,variable]&/@(List@@e)],
  Head[e]===Plus,degrees=DeleteDuplicates[homogeneousDegree[#,variable]&/@(List@@e)];
   require[Length[degrees]===1,"homogeneous coupling/charge sum"];First[degrees],
  Head[e]===Power&&IntegerQ[e[[2]]],e[[2]]homogeneousDegree[e[[1]],variable],
  True,require[False,"unsupported coupling/charge expression"]]];
degree[expressions_,variable_]:=Module[{degrees},
 degrees=DeleteDuplicates[bounded[homogeneousDegree[#,variable],"homogeneity"]&/@Select[expressions,#=!=0&]];
 require[Length[degrees]===1,"one homogeneous degree"];First[degrees]];
manifest=Import[FileNameJoin[{root,"s01_result"}],"RawJSON"];
require[manifest["status"]==="Complete","completed import"];results=<||>;
Do[
 channel=entry["channel"];Print["S03_CHANNEL_START ",channel];
 payload=SelectFirst[entry["files"],#["role"]==="terminal_fhat_payload"&];
 path=FileNameJoin[{root,payload["copy"]}];require[sha[path]===payload["sha256"],"frozen payload hash"];value=Get[path];
 producer=SelectFirst[entry["files"],#["role"]==="producer_provenance_only"&];
 require[sha[FileNameJoin[{root,producer["copy"]}]]===producer["sha256"],"executed source snapshot hash"];
 inputHash=Hash[{value["SourceHash"],value["InputHashes"]},"SHA256"];
 poleFiles=Select[entry["files"],#["role"]==="acceptance_provenance"&];
 poleRows=Table[require[sha[FileNameJoin[{root,row["copy"]}]]===row["sha256"],"frozen pole hash"];
   Get[FileNameJoin[{root,row["copy"]}]],{row,poleFiles}];
 poleRows=Select[poleRows,#["InputHash"]===inputHash&];
 checks=<|"producer_acceptance"->TrueQ[value["Accepted"]],
  "source_identity"->(value["SourceHash"]===FileHash[FileNameJoin[{root,producer["copy"]}],"SHA256"]),
  "pole_input_identity"->(poleRows=!={}),"pole_acceptance"->AllTrue[poleRows,TrueQ[#["Accepted"]]&],
  "all_pole_residues_zero"->AllTrue[poleRows,AllTrue[Values[#["PoleResiduals"]],#===0&]&]|>;
 require[And@@Values[checks],"source-bound accepted pole contract"];
 hats=value["Fhats"];core=AssociationQ[hats["F1"]];
 expressions=If[core,Flatten[Table[Join[{hats[hat]["LODelta"]},Flatten[Values/@Values[hats[hat]["NLO"]]]],
   {hat,Keys[hats]}]],Values[hats]];
 AssociateTo[checks,{"partonic_variables"->FreeQ[expressions,zH|PHT2|xi|xB|zeta],
  "finite_coefficients"->FreeQ[expressions,eps|_Integrate|_SeriesData|_Series|_Limit|_GLI|_PaVe|Indeterminate|ComplexInfinity]}];
 require[And@@Values[checks],"finite partonic coefficients"];
 consumer=<|"Status"->"Complete","Channel"->channel,"InputSHA256"->payload["sha256"],
  "JacobianAlreadyIncluded"->False,"Checks"->checks,"PhysicalConditions"->ToString[value["PhysicalConditions"],InputForm]|>;
 If[core,
  lo=hats[#]["LODelta"]&/@Keys[hats];
  nlo=Flatten[Table[Values[hats[hat]["NLO"][branch]],{hat,Keys[hats]},{branch,Keys[hats["F1"]["NLO"]]}]];
  logText=StringCases[value["PlusDefinition"],RegularExpression["Log\\[([^]]+)\\]"]->"$1"];
  require[Length[logText]===1,"saved plus logarithm"];logArgument=ToExpression[First[logText]];
  normalized=Together[logArgument/.w->B]===1&&Together[(logArgument/.{w->lambda w,B->lambda B})-logArgument]===0;
  boundaryPresent=AllTrue[Values[hats],KeyExistsQ[#["NLO"],0]&&FreeQ[#["NLO"][0],omega]&];
  require[normalized&&boundaryPresent,"normalized plus and evaluated coordinate boundary"];
  AssociateTo[consumer,{"LOAlphaDegree"->degree[lo,alphaS],"NLOAlphaDegree"->degree[nlo,alphaS],
   "NormalizedPlusLogarithm"->normalized,"PlusDefinition"->value["PlusDefinition"],
   "PlusLogArgument"->StringReplace[ToString[logArgument/.w->ss,InputForm],"^"->"**"],
   "CoordinateBoundaryPresent"->boundaryPresent,"BranchConvention"->value["BranchConvention"]}];
  If[channel==="Hqq",
   momentDefinitions=value["Bookkeeping"]["OtherChargeMomentDefinitions"];
   flavorChecks=<|"odd_moment_absent"->FreeQ[expressions,otherChargeMoment[1]],
    "charge_conjugation"->((expressions/.eq->-eq)===expressions),
    "active_flavor_domains"->AllTrue[{4,5},TrueQ[FullSimplify[value["FlavorDomain"]/.Nf->#]]&]|>;
   require[And@@Values[flavorChecks],"current Hqq flavor definitions"];
   momentRows=Association@Table[ToString[n]->Table[
    chargeSymbols=Table[Symbol["charge"<>ToString[k]],{k,n}];ordered=Prepend[Delete[chargeSymbols,j],chargeSymbols[[j]]];
    Clear[flavorCharge];flavorCharge[k_Integer]:=ordered[[k]];
    moments=Map[Expand[Activate[#/.Nf->n]]&,momentDefinitions];
    require[FreeQ[moments,_Sum|_Inactive|_KroneckerDelta|flavorCharge],"evaluated defining flavor sums"];
    <|"ObservedIndex"->(j-1),"Moments"->Association@KeyValueMap[
      ToString[#1]->StringReplace[ToString[#2,InputForm],"^"->"**"]&,moments]|>,{j,n}],{n,{4,5}}];
   Clear[flavorCharge];AssociateTo[consumer,{"Checks"->Join[checks,flavorChecks],"FlavorMoments"->momentRows,
    "FlavorDomain"->ToString[value["FlavorDomain"],InputForm],"FlavorMomentDefinitions"->ToString[momentDefinitions,InputForm]}],
   AssociateTo[consumer,"ChargeDegree"->degree[expressions,eq]]],
  endpointChecks=AllTrue[{"Delta","L0","L1"},AllTrue[Values[value[#]],#===0&]&];
  require[endpointChecks,"real-only endpoint coefficients vanish"];
  AssociateTo[consumer,{"NLOAlphaDegree"->degree[expressions,alphaS],"RegularOnly"->endpointChecks}];
  If[channel==="Hqqprime",
   coefficients=Association@KeyValueMap[#1->bounded[CoefficientRules[#2,{eq,eqp}],"charge decomposition"]&,hats];
   measured=Union@@(First/@#&/@Values[coefficients]);orders=DeleteDuplicates[Total/@measured];
   require[Length[orders]===1,"one measured total charge degree"];
   indices=Select[Tuples[Range[0,First[orders]],Length[{eq,eqp}]],Total[#]===First[orders]&];
   names=Association@Table[index->Which[index[[2]]===0,"eq2",index[[1]]===0,"eqp2",True,"eq_eqp"],{index,indices}];
   monomials=Association@Table[names[index]->Times@@MapThread[Power,{{eq,eqp},index}],{index,indices}];
   require[Sort[Keys[monomials]]===Sort[{"eq2","eqp2","eq_eqp"}],"charge-sector labels"];
   components=Association@Table[names[index]->Association@Table[hat->Coefficient[Coefficient[hats[hat],eq,index[[1]]],eqp,index[[2]]],
     {hat,Keys[hats]}],{index,indices}];
   require[AllTrue[Keys[hats],bounded[Together[hats[#]-Total[Table[monomials[key]components[key][#],
    {key,Keys[monomials]}]]],"charge reconstruction"]===0&],"exact current charge reconstruction"];
   Block[{$ContextPath={"System`","Global`"}},Put[<|"InputSHA256"->payload["sha256"],"Monomials"->monomials,"Components"->components|>,
    FileNameJoin[{cache,channel<>"_charge_components.wl"}]]];
   AssociateTo[consumer,"ChargeMonomials"->Map[StringReplace[ToString[#,InputForm],"^"->"**"]&,monomials]],
   variable=If[channel==="Hgg",chargeSum,eq2];
   AssociateTo[consumer,{"ChargeParameter"->ToString[variable,InputForm],"ChargeParameterDegree"->degree[expressions,variable]}]]];
 Export[FileNameJoin[{cache,channel<>"_consumer_contract"}],consumer,"RawJSON"];
 AssociateTo[results,channel-><|"InputSHA256"->payload["sha256"],"Consumer"->consumer|>];
 Print["S03_CHANNEL_DONE ",channel," memory=",MemoryInUse[]];Clear[value,hats,expressions,poleRows,coefficients,components];ClearSystemCache[],
 {entry,manifest["channels"]}];
Export[FileNameJoin[{root,"s03_result"}],<|"Stage"->"s03","Status"->"Complete","SourceHash"->sha[source],"Channels"->results,"Runtime"->$Version|>,"RawJSON"];
Print["S03_SUCCESS"];Quit[0];

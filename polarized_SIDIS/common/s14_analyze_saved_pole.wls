(* Analyze the native failed Laurent record without modifying assembly inputs. *)
$HistoryLength=0;
root=Directory[];checks=<||>;
gate[label_,test_]:=If[TrueQ[test],AssociateTo[checks,label->True];Print["PASS: ",label],Print["FAIL: ",label];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,300,gate["time "<>label,False]],2*1024^3,gate["memory "<>label,False]];
source=FileNameJoin[{root,"common","s14_analyze_saved_pole.wls"}];
parent=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];
input=FileNameJoin[{root,"cache","s14","Hqg","47e69226250f205317044df52dc3a4b6a756cabf6996d9f92b772464c140c584","finite_6fcb2f9004c78e81fb9b7b4216a945e6266355c36373a07beda4124fb49f9f10.wl"}];
gate["source syntax",SyntaxQ[Import[source,"Text"]]];
gate["exact reviewed assembly",IntegerString[FileHash[parent,"SHA256"],16,64]==="9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a"];
gate["exact saved failed input",IntegerString[FileHash[input,"SHA256"],16,64]==="21588f5e5cc51db69a7e4e7764d840c3b2a3368f60acdd182433197c7deb8340"];
parentText=Import[parent,"Text"];
domainText=StringCases[parentText,RegularExpression["softPhysical=[^;]+;"]];
gate["one original endpoint domain",Length[domainText]===1&&SyntaxQ[First[domainText]]];
ToExpression[First[domainText],InputForm];
saved=Get[input];label=saved["Label"];
gate["failed delta record with three original parts",AssociationQ[saved]&&saved["Accepted"]===False&&Last[label]==="Delta"&&Length[saved["InputParts"]]===3];
domain=(softPhysical/.t->label[[2]] omega-s)&&omega>0;
gate["resolved original physical domain",FreeQ[domain,t|s23|_Missing]];
powers=Keys[saved["PoleResiduals"]];
parts=AssociationThread[{"Real","Virtual","Subtraction"},saved["InputParts"]];
partPoles=Association@KeyValueMap[Function[{name,value},name->Association@Table[n->Coefficient[Expand[value,eps],eps,n],{n,powers}]],parts];
radicals=DeleteDuplicates[Cases[{partPoles,saved["PoleResiduals"]},Power[base_,exponent_Rational]:>Power[base,exponent],Infinity]];
atomRows=Table[Module[{candidate,proof,seconds},
 {seconds,candidate}=AbsoluteTiming[bounded[FullSimplify[PowerExpand[radical,Assumptions->domain],domain,TimeConstraint->{1,15}],"radical reduction"]];
 proof=bounded[FullSimplify[radical==candidate,domain,TimeConstraint->{1,15}],"radical equality"];
 Print["RADICAL_REDUCTION ",index,"/",Length[radicals]," exact ",TrueQ[proof]];
 <|"Original"->radical,"Candidate"->candidate,"Exact"->TrueQ[proof],"Seconds"->seconds|>],{index,Length[radicals]},{radical,{radicals[[index]]}}];
atomRows=Flatten[atomRows,1];
rules=(#["Original"]->#["Candidate"])&/@Select[atomRows,TrueQ[#["Exact"]]&];
canonical[value_]:=bounded[FullSimplify[Factor[Together[Refine[PowerExpand[value/.rules,Assumptions->domain],domain]]],domain,TimeConstraint->{1,90}],"pole canonicalization"];
canonicalParts=Map[canonical,partPoles,{2}];
directPoles=Association@Table[n->Total[#[n]&/@Values[partPoles]],{n,powers}];
canonicalDirect=Map[canonical,directPoles];
canonicalSaved=Map[canonical,saved["PoleResiduals"]];
canonicalSum=Association@Table[n->canonical[Total[#[n]&/@Values[canonicalParts]]],{n,powers}];
variables=DeleteDuplicates[Cases[{domain,partPoles},v_Symbol/;Context[v]==="Global`",Infinity]];
variables=DeleteCases[variables,eps];
pointVariables=Select[variables,!FreeQ[domain,#]&];
pointRules=bounded[FindInstance[domain,pointVariables,Reals,3],"physical points"];
gate["native physical point construction",Length[pointRules]>0&&AllTrue[pointRules,TrueQ[domain/.#]&]];
numericRows=Table[<|"Rules"->point,"OriginalPoles"->N[directPoles/.point,60],
 "SavedPoles"->N[saved["PoleResiduals"]/.point,60],"CanonicalPoles"->N[canonicalDirect/.point,60],
 "SeparateParts"->N[partPoles/.point,60]|>,{point,pointRules}];
Print["CANONICAL_DIRECT ",canonicalDirect];Print["CANONICAL_SAVED ",canonicalSaved];Print["CANONICAL_SEPARATE_SUM ",canonicalSum];
Print["PHYSICAL_POINT_VALUES ",numericRows];
out=FileNameJoin[{root,"Hqg","s14_pole_analysis_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
result=<|"Schema"->"polarized-sidis-saved-pole-analysis-v1","Channel"->"Hqg","Label"->label,
 "Domain"->domain,"OriginalDomainSource"->First[domainText],"OriginalInputHash"->saved["InputHash"],
 "Parts"->partPoles,"SavedResiduals"->saved["PoleResiduals"],"RadicalCertificates"->atomRows,
 "CanonicalParts"->canonicalParts,"CanonicalDirect"->canonicalDirect,"CanonicalSaved"->canonicalSaved,
 "CanonicalSeparateSum"->canonicalSum,"PhysicalPoints"->numericRows,
 "AllDirectPolesStructurallyZero"->AllTrue[Values[canonicalDirect],#===0&],
 "FiniteNLOFHatsComputed"->False,"SourceHash"->FileHash[source,"SHA256"],"ParentHash"->FileHash[parent,"SHA256"],
 "InputFileHash"->FileHash[input,"SHA256"],"NativeVersion"->$Version,"Checks"->checks|>;
Put[result,FileNameJoin[{out,"s14_result.wl"}]];
gate["native exact output round trip",Get[FileNameJoin[{out,"s14_result.wl"}]]===result];
Export[FileNameJoin[{out,"s14_checks.json"}],<|"channel"->"Hqg","checks"->checks,"all_direct_poles_structurally_zero"->result["AllDirectPolesStructurallyZero"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_analyze_saved_pole"];Quit[0];

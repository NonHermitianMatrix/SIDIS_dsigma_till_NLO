(* Capture the unchanged native recoil derivative at the current slow boundary. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];checks=<||>;
source=ExpandFileName[$InputFileName];
gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
SetAttributes[bounded,HoldFirst];bounded[v_,label_]:=MemoryConstrained[TimeConstrained[v,240,gate[label<>" time",False]],2*1024^3,gate[label<>" memory",False]];
readAccepted[relative_,receiptRelative_]:=Module[{p=FileNameJoin[{root,relative}],receipt},
 receipt=Import[FileNameJoin[{root,receiptRelative}],"RawJSON"];
 gate["accepted input "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[p,"SHA256"],16,64]];Get[p]];
captured=readAccepted["misc/s26_result/s26_result.wl","misc/s26_result/s26_execution.json"];
own=readAccepted["misc/s23_result/s23_result.wl","misc/s23_result/s23_execution.json"];
mapped=readAccepted["misc/s10_result/s10_result.wl","misc/s10_result/s10_execution.json"];
index=captured["Facts"]["ComponentIndex"];
gate["actual captured component identity",mapped["Components"][[index]]["Index"]===captured["Index"]];
coefficient=mapped["Components"][[index]]["ReducedCoefficients"][captured["Master"]]/.mapped["TransverseSubstitution"];
Clear[mapped];ClearSystemCache[];
recoilPath=FileNameJoin[{root,"common","s12_check_recoil_factorization.wls"}];recoilText=ReadString[recoilPath];
gate["exact defining reference derivative",StringContainsQ[recoilText,"derivative = s23 D[rational, s23]/rational;"]];
capture[value_,label_]:=Module[{original,rational,derivative,distributed,terms,count,seconds,facts,arguments,positions,position,selected,outer},
 original=bounded[Cancel[value/.t->omega-s],"original recoil substitution"];
 {seconds,rational}=AbsoluteTiming[bounded[Factor[original],"original recoil factor"]];
 gate["exact reference factored input",bounded[Factor[Together[rational-original]]===0,"reference factor identity"]];
 derivative=s23 D[rational,s23]/rational;
 count=If[Head[derivative]===Times,Times@@(Length/@Select[List@@derivative,Head[#]===Plus&]),If[Head[derivative]===Plus,Length[derivative],1]];
 facts=<|"Label"->label,"FactorSeconds"->seconds,"OriginalBytes"->ByteCount[original],"RationalBytes"->ByteCount[rational],"DerivativeBytes"->ByteCount[derivative],"TopHead"->Head[derivative],"DistributionCount"->count|>;
 Print["RECOIL_DERIVATIVE_FACTS ",InputForm[facts]];
 If[Head[derivative]===Times,
  arguments=List@@derivative;positions=Select[Range[Length[arguments]],Head[arguments[[#]]]===Plus&];
  If[positions==={},terms={derivative},
   position=First[MinimalBy[positions,Length[arguments[[#]]]&]];
   selected=arguments[[position]];outer=Times@@Delete[arguments,position];
   gate["exact native derivative factors retained",outer selected===derivative&&Total[List@@selected]===selected];
   terms=(outer #&)/@(List@@selected)],
  terms=If[Head[derivative]===Plus,List@@derivative,{derivative}]];
 gate["bounded selective derivative distribution",Length[terms]<=128];
 AssociateTo[facts,{"SelectedTermCount"->Length[terms],"SelectedTermBytes"->ByteCount[terms]}];
 Print["SELECTIVE_DERIVATIVE_FACTS ",InputForm[facts]];
 <|"Original"->original,"Rational"->rational,"Derivative"->derivative,"Terms"->terms,"Facts"->facts|>];
actual=capture[coefficient,{"Actual",index,captured["Master"]}];
ownData=capture[own["Packet"]["Coefficient"],{"Own",own["ComponentIndex"],own["Master"]}];
{ownSeconds,ownRatio}=AbsoluteTiming[bounded[Factor[Together[ownData["Derivative"]]],"own reference derivative reduction"]];
gate["complete own native derivative reconstruction",bounded[Factor[Together[ownRatio-ownData["Derivative"]]]===0,"own derivative identity"]];
packet=<|"Schema"->"polarized-sidis-recoil-derivative-capture-v1","SourceHash"->FileHash[source,"SHA256"],"ReferenceHash"->FileHash[recoilPath,"SHA256"],"InputHash"->captured["InputHash"],"CaptureHash"->FileHash[FileNameJoin[{root,"misc","s26_result","s26_result.wl"}],"SHA256"],"Actual"->actual,"Own"->ownData,"OwnRatio"->ownRatio,"OwnSeconds"->ownSeconds,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks|>;
out=FileNameJoin[{root,"misc","s30_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
serialized="Uncompress["<>ToString[Compress[packet],InputForm]<>"]\n";
gate["bounded exact derivative capture",StringLength[serialized]<128*1024^2];
proofFile=FileNameJoin[{out,"s30_result.wl"}];Export[proofFile,serialized,"Text"];
gate["exact derivative capture reload",Get[proofFile]===packet];
Put[actual["Terms"],FileNameJoin[{out,"s30_equations.wl"}]];
Export[FileNameJoin[{out,"s30_checks.json"}],<|"checks"->checks,"facts"->ToString[actual["Facts"],InputForm]|>,"RawJSON"];
Print["PASS: actual Hgg endpoint derivative captured"];Quit[0];


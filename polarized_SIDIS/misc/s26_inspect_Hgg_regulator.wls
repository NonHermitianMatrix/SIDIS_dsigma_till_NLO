(* Inspect the actual coefficient at the reported regulator-valuation memory boundary. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];checks=<||>;
gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
source=ExpandFileName[$InputFileName];mapPath=FileNameJoin[{root,"misc","s10_result","s10_result.wl"}];
receipt=Import[FileNameJoin[{root,"misc","s10_result","s10_execution.json"}],"RawJSON"];
gate["accepted actual reduced input",TrueQ[receipt["passed"]]&&receipt["result_sha256"]["misc/s10_result/s10_result.wl"]===IntegerString[FileHash[mapPath,"SHA256"],16,64]];
mapped=Get[mapPath];
gate["complete accepted reduction",TrueQ[mapped["ReductionCoverageComplete"]]&&And@@Values[mapped["Checks"]]];
log=ReadString[FileNameJoin[{root,"misc","s11_result","s11.log"}]];
gate["reported component memory boundary",StringContainsQ[log,"coefficient regulator valuation memory limit"]];
indices=Select[Range[Length[mapped["Components"]]],mapped["Components"][[#]]["Index"]==={4,1,1}&];
gate["unique actual failing projection",Length[indices]===1];idx=First[indices];
component=mapped["Components"][[idx]];rule=mapped["TransverseSubstitution"];Clear[mapped];ClearSystemCache[];
coefficients=Select[component["ReducedCoefficients"],#=!=0&]/.rule;
firstMaster=First[Keys[coefficients]];coefficient=coefficients[firstMaster]/.D->4-2eps;
{seconds,pair}=AbsoluteTiming[{Numerator[coefficient],Denominator[coefficient]}];
facts=<|"ComponentIndex"->idx,"Master"->firstMaster,"OriginalBytes"->ByteCount[coefficient],
 "NumeratorBytes"->ByteCount[First[pair]],"DenominatorBytes"->ByteCount[Last[pair]],
 "Head"->Head[coefficient],"NumeratorHead"->Head[First[pair]],"DenominatorHead"->Head[Last[pair]],
 "NumeratorPolynomialInRegulator"->PolynomialQ[First[pair],eps],
 "DenominatorPolynomialInRegulator"->PolynomialQ[Last[pair],eps],
 "NativeExactReconstruction"->(First[pair]/Last[pair]===coefficient),"Seconds"->seconds|>;
gate["native numerator denominator reconstruct exact coefficient",facts["NativeExactReconstruction"]];
out=FileNameJoin[{root,"misc","s26_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
packet=<|"Schema"->"polarized-sidis-regulator-input-inspection-v1","SourceHash"->FileHash[source,"SHA256"],
 "InputHash"->FileHash[mapPath,"SHA256"],"Index"->component["Index"],"Master"->firstMaster,
 "Coefficient"->coefficient,"Pair"->pair,"Facts"->facts,"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks|>;
file=FileNameJoin[{out,"s26_result.wl"}];serialized="Uncompress["<>ToString[Compress[packet],InputForm]<>"]\n";
gate["bounded inspection file",StringLength[serialized]<128*1024^2];Export[file,serialized,"Text"];
gate["exact saved inspection reload",Get[file]===packet];
Put[<|"Facts"->facts,"CompleteDenominator"->Last[pair]|>,FileNameJoin[{out,"s26_equations.wl"}]];
Export[FileNameJoin[{out,"s26_checks.json"}],<|"checks"->checks,"facts"->ToString[facts,InputForm]|>,"RawJSON"];
Print["REGULATOR_INPUT ",InputForm[facts]];Print["PASS: actual Hgg regulator input inspected"];Quit[0];

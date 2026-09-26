(* Read and compare the saved endpoint equations under their recorded assumptions. *)
$HistoryLength=0;
If[!StringQ[Environment["JOB_ID"]],Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
r=Directory[];p=FileNameJoin[{r,"common","s12_read_endpoint_comparison.wls"}];
If[!SyntaxQ[Import[p,"Text"]],Quit[1]];
oldFiles=FileNames["component_0025.wl",FileNameJoin[{r,"cache","s12","Hqq"}],Infinity];
newFiles=FileNames["component_0025.wl",FileNameJoin[{r,"cache","s12_transverse_endpoint","Hqq"}],Infinity];
If[Length[oldFiles]=!=1 || Length[newFiles]=!=1,Print["FAIL: unique saved own comparison"];Quit[1]];
old=Get[First[oldFiles]];new=Get[First[newFiles]];
If[old["InputHash"]=!=new["InputHash"] || KeyTake[old,{"Sector","Kind","Index"}]=!=KeyTake[new,{"Sector","Kind","Index"}],
 Print["FAIL: own comparison provenance"];Quit[1]];
rows=Association@Table[
 assumptions=old["Branches"][sign]["Assumptions"];
 If[assumptions=!=new["Branches"][sign]["Assumptions"],Print["FAIL: branch assumptions"];Quit[1]];
 Print["ORIGINAL_DELTA ",sign," ",InputForm[old["Branches"][sign]["Delta"]]];
 Print["CANDIDATE_DELTA ",sign," ",InputForm[new["Branches"][sign]["Delta"]]];
 values=Association@Table[
  difference=Together[new["Branches"][sign][key]-old["Branches"][sign][key]];
  Print["COMPARISON_EQUATION ",InputForm[{sign,key,difference,assumptions}]];
  {seconds,simplified}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
    FullSimplify[difference,assumptions],1200,$Aborted],2*1024^3,$Aborted]];
  Print["PHYSICAL_COMPARISON ",InputForm[{sign,key,simplified,seconds}]];
  key-><|"Difference"->difference,"SimplifiedDifference"->simplified,"Seconds"->seconds|>,
  {key,{"Delta","L0","L1","Regular"}}];
 sign-><|"Assumptions"->assumptions,"OriginalDelta"->old["Branches"][sign]["Delta"],
   "CandidateDelta"->new["Branches"][sign]["Delta"],"Comparisons"->values|>,{sign,{1,-1}}];
result=<|"SourceHash"->FileHash[p,"SHA256"],"OriginalFile"->First[oldFiles],"OriginalHash"->FileHash[First[oldFiles],"SHA256"],
 "CandidateFile"->First[newFiles],"CandidateHash"->FileHash[First[newFiles],"SHA256"],"InputHash"->old["InputHash"],
 "Rows"->rows,"AllPhysicalDifferencesZero"->AllTrue[Flatten[Values[#["Comparisons"]]&/@Values[rows]],#["SimplifiedDifference"]===0&]|>;
dir=FileNameJoin[{r,"Hqq","s12_endpoint_comparison_equations_result"}];
If[!DirectoryQ[dir],CreateDirectory[dir,CreateIntermediateDirectories->True]];
file=FileNameJoin[{dir,"s12_result.wl"}];Put[result,file];
If[Get[file]=!=result,Print["FAIL: comparison read reload"];Quit[1]];
Print["PASS: exact endpoint comparison read"];Quit[0];

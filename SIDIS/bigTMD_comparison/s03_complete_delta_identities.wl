(* Complete the existing normalizer on the actual argument sign regions. *)
$HistoryLength=0;$MaxExtraPrecision=2000;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=DirectoryName[$InputFileName];source=$InputFileName;
gate[name_,test_]:=If[!TrueQ[test],Throw[<|"Gate"->name,"Value"->test|>,"stage"]];
SetAttributes[bounded,HoldFirst];
bounded[value_,name_]:=TimeConstrained[MemoryConstrained[value,2*1024^3,
 Throw[<|"Gate"->name,"Reason"->"memory limit"|>,"stage"]],600,
 Throw[<|"Gate"->name,"Reason"->"time limit"|>,"stage"]];
put[value_,file_]:=(Block[{$ContextPath={"System`","Global`"}},Put[value,file<>".tmp"]];
 RenameFile[file<>".tmp",file,OverwriteTarget->True]);
sha[file_]:=FileHash[file,"SHA256","HexString"];
log[value_]:=Print[DateString[Now,"ISODateTime"]," ",value];
setup=Catch[
 gate["source syntax",SyntaxQ[Import[source,"Text"]]];
 previous=Get[FileNameJoin[{root,"s02_result.wl"}]];
 previousReceipt=Import[FileNameJoin[{root,"s02_result.json"}],"RawJSON"];
 gate["complete source-bound S02",TrueQ[previous["Completed"]]&&
  previousReceipt["ResultSHA256"]===sha[FileNameJoin[{root,"s02_result.wl"}]]&&
  previous["SourceSHA256"]===sha[FileNameJoin[{root,"s02_compare_coefficients.wl"}]]];
 rows=Flatten[Lookup[Values[previous["Channels"]],"Results"],1];
 gate["all original high-precision comparisons agree",AllTrue[rows,
  AllTrue[#["NumericalChecks"],TrueQ[#["Equal"]]&]&]];
 helperSource=Import[FileNameJoin[{root,"reference","s05_compare_distributions.wl"}],"Text"];
 helperCode=StringTake[helperSource,{First[First[StringPosition[helperSource,"unitDilogarithm["]]],
  First[First[StringPosition[helperSource,"splitChains["]]]-1}];
 helperGate="And @@ MapThread[SameQ, {Times @@@ rows, terms}]";
 gate["existing reconstruction gate",StringCount[helperCode,helperGate]===1];
 helperCode=StringReplace[helperCode,helperGate->
  "And @@ MapThread[(SameQ[#1,#2] || Together[#1-#2] === 0)&, {Times @@@ rows, terms}]"];
 ToExpression[helperCode];
 dilogarithms=Get[FileNameJoin[{root,"reference","s13_dilogarithms.wl"}]];
 gate["source-bound tool-derived identity library",TrueQ[dilogarithms["Complete"]]&&
  dilogarithms["SourceHash"]===FileHash[FileNameJoin[{root,"reference","s13_dilogarithm_identities.wl"}],"SHA256"]];
 hash=Hash[{FileHash[source,"SHA256"],FileHash[FileNameJoin[{root,"s02_result.wl"}],"SHA256"],
  helperCode,dilogarithms},"SHA256"];
 pending=Select[rows,!TrueQ[#["Equal"]]&];
 gate["only finite delta normalization remains",AllTrue[pending,StringEndsQ[#["Label"],"_Delta"]&]];
 True,"stage"];
If[setup=!=True,put[setup,FileNameJoin[{root,"s03_failure.wl"}]];Print["FAIL: setup ",InputForm[setup]];Quit[1]];

completeDelta[row_]:=Module[{directory,file,saved,result,difference,assumptions,arguments,argument,
 points,values,numericalChecks,regions,regionProofs,domain,map,solutions,value,regionDirectory,coverage},
 directory=FileNameJoin[{root,row["Channel"],"s03_result",IntegerString[hash,16],row["Label"]}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 file=FileNameJoin[{directory,"s03_result.wl"}];
 If[FileExistsQ[file],saved=Get[file];If[saved["InputHash"]===hash&&TrueQ[saved["Completed"]],Return[saved]]];
 result=Catch[
  log[{"DELTA_IDENTITY",row["Channel"],row["Label"]}];
  difference=row["Difference"];assumptions=row["Assumptions"];
  numericalChecks=Table[
   values=bounded[N[difference/.Map[First[#]->N[Last[#],90]&,check["Point"]],90],"normalized residual value"];
   gate["normalization agrees with the original difference",NumericQ[values]&&
    TrueQ[Abs[values-check["Difference"]]<10^-60 Max[1,Max[Abs[check["Values"]]]]]];
   <|"Point"->check["Point"],"NormalizedDifference"->values,
     "OriginalDifference"->check["Difference"],"Equal"->True|>,{check,row["NumericalChecks"]}];
  arguments=DeleteDuplicates[Cases[difference,PolyLog[2,a_]:>Factor[a],Infinity]];
  gate["remaining functions are dilogarithms and logarithms",arguments=!={}&&
    FreeQ[difference,_Re|_Im|_ArcTan|_ArcTanh|_Arg|_Abs|_Sign]];
  argument=First[SortBy[arguments,{LeafCount,ToString[#,InputForm]&}]];
  gate["selected argument is real below one",bounded[
    FullSimplify[Element[argument,Reals]&&argument<1,assumptions],"argument domain"]===True];
  regions={argument<0,argument==0,argument>0};
  coverage=bounded[FullSimplify[Or@@regions,assumptions],"complete sign-region coverage"];
  gate["sign regions cover the full physical domain",coverage===True];
  regionProofs=Table[
   regionDirectory=FileNameJoin[{directory,"region_"<>ToString[index]}];
   If[!DirectoryQ[regionDirectory],CreateDirectory[regionDirectory]];
   domain=assumptions&&regions[[index]];map={};
   If[bounded[FullSimplify[domain],"nonempty region"]===False,
    <|"Region"->regions[[index]],"Empty"->True,"Difference"->0|>,
    If[index===2,
     solutions=Solve[argument==0,s];
     gate["zero-argument boundary has one solved coordinate",Length[solutions]===1];
     map=First[solutions];
     gate["boundary substitution reconstructs",Together[argument/.map]===0];
     domain=assumptions/.map];
    value=Block[{cache=regionDirectory,inputHash=hash,acceptedInputHashes={hash}},
     bounded[normalize[Refine[difference/.map,domain],domain],"existing identity normalizer on one region"]];
    gate["exact zero finite delta residual",value===0];
    <|"Region"->regions[[index]],"Domain"->domain,"Map"->map,"Empty"->False,"Difference"->value|>],
   {index,Length[regions]}];
  <|"Completed"->True,"Channel"->row["Channel"],"Label"->row["Label"],"InputHash"->hash,
   "S02Difference"->difference,"Assumptions"->assumptions,"SelectedArgument"->argument,
   "Coverage"->coverage,"Regions"->regionProofs,"NumericalChecks"->numericalChecks,
   "Equal"->AllTrue[regionProofs,#["Difference"]===0&],"Difference"->0|>,"stage"];
 If[!AssociationQ[result]||!TrueQ[result["Completed"]],result=<|"Completed"->False,"Channel"->row["Channel"],
  "Label"->row["Label"],"InputHash"->hash,"Failure"->result|>];
 put[result,file];log[{"DELTA_FINISHED",row["Channel"],row["Label"],result["Completed"],result["Equal"]}];result];

slots=Quiet[Check[ToExpression[Environment["NSLOTS"]],1]];If[!IntegerQ[slots]||slots<1,slots=1];
LaunchKernels[KernelConfiguration["localhost","KernelCommand"->
 "/u/local/apps/mathematica/13.1/Executables/WolframKernel","KernelCount"->Min[4,slots],"TimeConstraint"->60]];
gate["cluster workers available",Length[Kernels[]]>0];
ParallelEvaluate[$HistoryLength=0;$MaxExtraPrecision=2000;$FeynCalcStartupMessages=False;Get["FeynCalc`"]];
DistributeDefinitions[root,hash,gate,bounded,put,log,dilogarithms,unitDilogarithm,reduceDilogarithm,
 reduceFunction,reduceAlgebraic,expandCoth,normalize,completeDelta];$DistributedContexts=None;
proofs=ParallelMap[completeDelta,pending,Method->"FinestGrained"];CloseKernels[];
accepted=AllTrue[proofs,TrueQ[#["Completed"]]&&TrueQ[#["Equal"]]&];
byChannel=Association@Table[ch->Module[{original=previous["Channels"][ch],channelRows,proof},
 channelRows=Map[Function[row,If[TrueQ[row["Equal"]],row,
   proof=SelectFirst[proofs,#["Channel"]===ch&&#["Label"]===row["Label"]&];
   Join[row,<|"Completed"->TrueQ[proof["Completed"]],"Equal"->TrueQ[proof["Equal"]],
     "Difference"->If[TrueQ[proof["Equal"]],proof["Difference"],row["Difference"]],"S03Proof"->proof|>]]],original["Results"]];
 <|"Completed"->AllTrue[channelRows,TrueQ[#["Completed"]]&],
   "AllEqual"->AllTrue[channelRows,TrueQ[#["Equal"]]&],"Results"->channelRows,
   "CoefficientChecks"->Length[channelRows],"NumericalChecks"->Total[Length[#["NumericalChecks"]]&/@channelRows],
   "AllNumericalEqual"->AllTrue[channelRows,AllTrue[#["NumericalChecks"],TrueQ[#["Equal"]]&]&],
   "ProductionSHA256"->original["ProductionSHA256"]|>],{ch,Keys[previous["Channels"]]}];
KeyValueMap[put[#2,FileNameJoin[{root,#1,"s03_result.wl"}]]&,byChannel];
out=<|"Completed"->accepted,"AllEqual"->AllTrue[Values[byChannel],TrueQ[#["AllEqual"]]&],
 "Channels"->byChannel,"InputHash"->hash,"SourceSHA256"->sha[source],
 "S02ResultSHA256"->sha[FileNameJoin[{root,"s02_result.wl"}]],"Direction"->previous["Direction"],
 "ReferenceInterpretation"->previous["ReferenceInterpretation"]|>;
put[out,FileNameJoin[{root,"s03_result.wl"}]];
Export[FileNameJoin[{root,"s03_result.json"}],<|"Completed"->out["Completed"],"AllEqual"->out["AllEqual"],
 "Channels"->Map[KeyTake[#,{"Completed","AllEqual","CoefficientChecks","NumericalChecks","AllNumericalEqual","ProductionSHA256"}]&,byChannel],
 "ResultSHA256"->sha[FileNameJoin[{root,"s03_result.wl"}]]|>,"RawJSON"];
If[accepted,Print["S03_SUCCESS: complete exact comparison including finite delta identities"];Quit[0],
 Print["FAIL: incomplete delta identity proof"];Quit[1]];

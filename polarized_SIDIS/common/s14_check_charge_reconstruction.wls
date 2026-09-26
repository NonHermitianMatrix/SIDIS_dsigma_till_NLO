(* Inspect the exact saved first-component charge polynomials used by S14. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];checks=<||>;
source=FileNameJoin[{root,"common","s14_check_charge_reconstruction.wls"}];
gate[name_,test_] := If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
gate["complete source syntax",SyntaxQ[Import[source,"Text"]]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];$FeynCalcStartupMessages=False;Get["FeynCalc`"];
path=FileNameJoin[{root,channel,"s12_result","s12_result.wl"}];
receiptPath=FileNameJoin[{root,channel,"s12_result","s12_execution.json"}];receipt=Import[receiptPath,"RawJSON"];
gate["accepted own integrated result",TrueQ[receipt["passed"]]&&
  IntegerString[FileHash[path,"SHA256"],16,64]===receipt["result_sha256"][channel<>"/s12_result/s12_result.wl"]];
real=Get[path];gate["accepted real schema",real["Schema"]==="polarized-sidis-real-distributions-v1"&&
  real["Channel"]===channel&&And@@Values[real["Checks"]]];
physicalRows=Select[real["Components"],#["Kind"]==="ExtendedResponse"&];
index=First[physicalRows]["Index"];rows=Select[physicalRows,#["Index"]===index&];
saved=Flatten[Table[Join[
  Flatten[Table[<|"Sector"->row["Sector"],"Index"->index,"Branch"->sign,"Distribution"->dist,
    "Expression"->row["Branches"][sign][dist]|>,{sign,{1,-1}},{dist,{"Delta","L0","L1","Regular"}}]],
  {<|"Sector"->row["Sector"],"Index"->index,"Branch"->"Ordinary","Distribution"->"Ordinary","Expression"->row["Ordinary"]|>}],{row,rows}]];
SetAttributes[bounded,HoldFirst];bounded[value_] := MemoryConstrained[TimeConstrained[value,600,$Aborted],2*1024^3,$Aborted];
inspect[row_] := Module[{expression=row["Expression"],rules,monomials,reconstruction,residual,original,seconds,reduced},
  gate["polynomial distinct-flavor charge dependence",PolynomialQ[expression,chargeRatio]];
  rules=CoefficientRules[expression,{chargeRatio}];monomials=chargeRatio^First[First[#]]&/@rules;
  reconstruction=Total[MapThread[Times,{Last/@rules,monomials}]];
  residual=bounded[Expand[expression-reconstruction]];original=residual===0;
  {seconds,reduced}=AbsoluteTiming[If[original,0,bounded[Together[residual]]]];
  If[!original,Print["ACTUAL_CHARGE_RECONSTRUCTION ",InputForm[Join[KeyDrop[row,"Expression"],
    <|"Expression"->expression,"Rules"->rules,"ExpandedResidual"->residual,"TogetherResidual"->reduced|>]]]];
  gate["own exact charge reconstruction",reduced===0];
  Join[KeyDrop[row,"Expression"],<|"InputHash"->Hash[expression,"SHA256"],"InputBytes"->ByteCount[expression],
    "OriginalPredicatePassed"->original,"TogetherSeconds"->seconds,"ExactResidual"->reduced,
    "Expression"->expression,"CoefficientRules"->rules,"ExpandedResidual"->residual,"Accepted"->True|>]];
values=inspect/@saved;gate["complete own input comparisons",Length[values]===Length[saved]&&And@@Lookup[values,"Accepted"]];
result=<|"Schema"->"polarized-sidis-charge-reconstruction-v1","Channel"->channel,"Index"->index,
  "SourceHash"->FileHash[source,"SHA256"],"RealHash"->FileHash[path,"SHA256"],
  "ProducerReceiptHash"->FileHash[receiptPath,"SHA256"],"Comparisons"->values,
  "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True|>;
directory=FileNameJoin[{root,channel,"s14_charge_result"}];If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
output=FileNameJoin[{directory,"s14_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded native result",StringLength[serialized]<128*1024^2];Export[output<>".tmp",serialized,"Text"];
gate["exact native reload",Get[output<>".tmp"]===result];RenameFile[output<>".tmp",output,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s14_checks.json"}],<|"checks"->checks,"comparison_count"->Length[values],
  "original_predicate_failures"->Count[Lookup[values,"OriginalPredicatePassed"],False],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_check_charge_reconstruction"];Quit[0];

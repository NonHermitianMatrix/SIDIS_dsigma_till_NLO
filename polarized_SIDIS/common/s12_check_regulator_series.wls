(* Compare a regulator-polynomial series with the accepted real integration. *)
$HistoryLength=0;
proofRoot=Directory[];
proofSource=FileNameJoin[{proofRoot,"common","s12_check_regulator_series.wls"}];
originalSource=FileNameJoin[{proofRoot,"common","s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[originalSource,"SHA256"],16,64]=!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243",Quit[1]];
originalText=Import[originalSource,"Text"];
If[!SyntaxQ[Import[proofSource,"Text"]],Quit[1]];
If[StringCount[originalText,"\nslots="]=!=1,Quit[1]];
ToExpression[First[StringSplit[originalText,"\nslots="]]];
gate["series comparison channel",channel==="Hqqprime"];
gate["accepted coefficient file identity",
  IntegerString[FileHash[mapPath,"SHA256"],16,64]===
  "e262ce55f59c1a4a1e8ddd3acfbb487536106af566b373922bd09f8e6e73d3ec"];

regulatorMasterSeries[coefficient_,masterValue_,order_,label_] := Module[
  {numerator,denominator,dimensionCoefficients,weights,formalNumerator,
   formalSeries,normalSeries,kernels,reconstructed,result},
  gate[label<>" coefficient is regulator free",FreeQ[coefficient,eps]];
  numerator=Numerator[coefficient];denominator=Denominator[coefficient];
  gate[label<>" rational dimension dependence",
    PolynomialQ[numerator,D]&&PolynomialQ[denominator,D]];
  dimensionCoefficients=bounded[CoefficientList[numerator,D],label<>" dimension coefficients"];
  gate[label<>" dimension coefficients are constant in the regulator",
    FreeQ[dimensionCoefficients,D|eps]];
  weights=Table[Unique["regulatorWeight$"],{Length[dimensionCoefficients]}];
  formalNumerator=Sum[weights[[j]] D^(j-1),{j,Length[weights]}];
  reconstructed=formalNumerator/.Thread[weights->dimensionCoefficients];
  gate[label<>" exact dimension polynomial reconstruction",
    bounded[Expand[numerator-reconstructed],label<>" dimension reconstruction"]===0];
  formalSeries=bounded[Series[(formalNumerator/denominator/.D->4-2eps)masterValue,
    {eps,0,order}],label<>" formal regulator series"];
  gate[label<>" regulator coverage",FreeQ[formalSeries,eps|_SeriesData|_Series]||
    (MatchQ[formalSeries,_SeriesData]&&formalSeries[[5]]>order)];
  normalSeries=Normal[formalSeries];
  kernels=Coefficient[normalSeries,#]&/@weights;
  gate[label<>" exact linear formal series reconstruction",
    bounded[Expand[normalSeries-Total[MapThread[Times,{weights,kernels}]]],
      label<>" formal linearity"]===0];
  gate[label<>" formal kernels independent of abbreviations",FreeQ[kernels,Alternatives@@weights]];
  result=Total[MapThread[Times,{dimensionCoefficients,kernels}]];
  gate[label<>" restored symbolic series evaluated",
    FreeQ[result,Alternatives@@Join[weights,{_SeriesData,_Series,_Missing,$Failed,$Aborted}]]];
  result];

Print["REGULATOR_SERIES_COMPARISON_START"];
controlRows=Table[
  controlFile=FileNameJoin[{cache,"component_"<>IntegerString[controlIndex,10,4]<>".wl"}];
  gate["own completed integration checkpoint exists "<>ToString[controlIndex],FileExistsQ[controlFile]];
  control=Get[controlFile];
  gate["own completed integration checkpoint identity "<>ToString[controlIndex],
    control["InputHash"]===inputHash&&TrueQ[control["Accepted"]]&&And@@Values[control["Checks"]]];
  component=mapped["Components"][[controlIndex]];
  coefficients=Select[component["ReducedCoefficients"],#=!=0&]/.transverseRule;
  measured=AbsoluteTiming[Total[KeyValueMap[
    regulatorMasterSeries[#2,regions["OrdinaryMasters"][#1],0,
      "control "<>ToString[controlIndex]<>" "<>ToString[#1,InputForm]]&,coefficients]]];
  gate["own accepted ordinary integral equality "<>ToString[controlIndex],
    bounded[Together[measured[[2]]-control["Ordinary"]],"own accepted series equality"]===0];
  Print["REGULATOR_CONTROL_ACCEPTED ",controlIndex," seconds ",measured[[1]]];
  <|"Index"->controlIndex,"Checkpoint"->StringDrop[controlFile,StringLength[root]+1],
    "SHA256"->FileHash[controlFile,"SHA256"],"Seconds"->measured[[1]],
    "InputBytes"->ByteCount[coefficients],"OutputBytes"->ByteCount[measured[[2]]]|>,
  {controlIndex,Range[6]}];

stressIndex=7;
component=mapped["Components"][[stressIndex]];
coefficients=Select[component["ReducedCoefficients"],#=!=0&]/.transverseRule;
stressRows=KeyValueMap[Function[{master,coefficient},Module[{timed},
  Print["REGULATOR_STRESS_MASTER ",master," bytes ",ByteCount[coefficient]];
  timed=AbsoluteTiming[regulatorMasterSeries[coefficient,regions["OrdinaryMasters"][master],0,
    "actual stalled coefficient "<>ToString[master,InputForm]]];
  Print["REGULATOR_STRESS_ACCEPTED ",master," seconds ",timed[[1]]];
  <|"Master"->master,"Seconds"->timed[[1]],"InputBytes"->ByteCount[coefficient],
    "OutputBytes"->ByteCount[timed[[2]]],"Value"->timed[[2]]|>]],coefficients];
gate["all actual component masters expanded",Length[stressRows]===Length[coefficients]];
proofResult=<|"Schema"->"polarized-sidis-regulator-series-check-v1","Channel"->channel,
  "OriginalSourceHash"->sourceHash,"SourceHash"->FileHash[proofSource,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersion"->$Version,
  "Definitions"->DownValues[regulatorMasterSeries],"ControlRows"->controlRows,
  "StressComponentIndex"->stressIndex,"StressComponent"->KeyTake[component,{"Sector","Kind","Index"}],
  "StressRows"->stressRows,"Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
proofDirectory=FileNameJoin[{root,channel,"s12_regulator_result"}];
If[!DirectoryQ[proofDirectory],CreateDirectory[proofDirectory,CreateIntermediateDirectories->True]];
proofOutput=FileNameJoin[{proofDirectory,"s12_result.wl"}];
proofCompressed=Compress[proofResult];
gate["compressed comparison file bound",StringLength[proofCompressed]<128*1024^2];
With[{payload=proofCompressed},Put[Unevaluated[Uncompress[payload]],proofOutput]];
gate["comparison exact native reload",Get[proofOutput]===proofResult];
Export[FileNameJoin[{proofDirectory,"s12_checks.json"}],<|"channel"->channel,"checks"->checks,
  "control_count"->Length[controlRows],"stress_component"->stressIndex,
  "finite_nlo_fhats_computed"->False,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s12_check_regulator_series"];Quit[0];

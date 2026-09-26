(* Inspect the actual scalar-product interface before any diagram work. *)
$HistoryLength=0;root=Directory[];
ownSource=FileNameJoin[{root,"common","s05_coordinate_check.wls"}];
productionPath=FileNameJoin[{root,"common","s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath,"SHA256"],16,64]=!=
  "d34991466b6c4677600840ae1c837fab5879e2483932e778096134f8784c4d84",Quit[1]];
productionText=Import[productionPath,"Text"];
ToExpression[StringTake[productionText,First[First[StringPosition[productionText,"sourceHash = FileHash[sourcePath"]]]-1]];
gate["diagnostic source syntax",SyntaxQ[Import[ownSource,"Text"]]];
begin=First[First[StringPosition[productionText,"(* Derive the old coordinate conversion"]]];
finish=First[First[StringPosition[productionText,"gate[\"unique reference coordinate conversion\""]]]-1;
ToExpression[StringTake[productionText,{begin,finish}]];
record=<|"Schema"->"polarized-sidis-real-coordinate-diagnostic-v1","Channel"->channel,
  "OldRows"->oldRows,"OldVariables"->oldVariables,"TargetValues"->targetValues,
  "TemporaryVariables"->temporary,"Solutions"->solutions,
  "SourceHash"->FileHash[ownSource,"SHA256"],"ProductionSourceHash"->FileHash[productionPath,"SHA256"],
  "Checks"->checks,"AcceptedRealTensor"->False|>;
Print["COORDINATE_INTERFACE ",InputForm[record]];
resultDir=FileNameJoin[{root,channel,"s05_coordinate_result"}];
If[!DirectoryQ[resultDir],CreateDirectory[resultDir,CreateIntermediateDirectories->True]];
put[record,FileNameJoin[{resultDir,"s05_result.wl"}]];
Print["PASS: s05_coordinate_check"];Quit[0];

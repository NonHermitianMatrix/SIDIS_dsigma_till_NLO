(* Reuse accepted counterterms and expand only the changed dimensional convolution. *)
$HistoryLength=0;differenceRoot=Directory[];
differenceSource=FileNameJoin[{differenceRoot,"common","s11_complete_collinear_difference.wls"}];
differenceBaseline=FileNameJoin[{differenceRoot,"common","s11_collinear_spin_convolutions.wls"}];
If[IntegerString[FileHash[differenceBaseline,"SHA256"],16,64]=!=
  "4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6",Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
differenceText=Import[differenceBaseline,"Text"];
differenceMarker="\ncounterterms = Association@Table";
If[StringCount[differenceText,differenceMarker]=!=1||!SyntaxQ[Import[differenceSource,"Text"]],Quit[1]];
differencePrefix=First[StringSplit[differenceText,differenceMarker]];
If[StringCount[differencePrefix,"Get[\"FeynCalc`\"]"]=!=1,Quit[1]];
differencePrefix=StringReplace[differencePrefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[differencePrefix],Quit[1]];
ToExpression[differencePrefix,InputForm];
gate["difference completion channel",channel==="Hqq"];
differenceCounterterms[old_,new_,owner_] := Module[{delta,correction,answer},
  gate[owner<>" unchanged subtraction prefactor",old["Prefactor"]===new["Prefactor"]&&old["MSPole"]===new["MSPole"]];
  delta=Association@Table[d->Map[Factor,new["ConvolutionsD"][d]-old["ConvolutionsD"][d],{3}],
    {d,Keys[new["ConvolutionsD"]]}];
  gate[owner<>" convolution difference has zero D4 limit",zeroArray[Values[delta]/.D->4]];
  correction=Association@Table[
    Print["SUBTRACTION_DIFFERENCE_EXPANSION ",owner," ",d];
    d->MapIndexed[Function[{value,index},
      If[value=!=0,Print["SUBTRACTION_DIFFERENCE_COMPONENT ",owner," ",d," ",index]];
      bounded[Normal[Series[new["Prefactor"] new["MSPole"] (value/.D->4-2eps),{eps,0,0}]],
        {owner,d,index,"difference epsilon expansion"}]],delta[d],{3}],{d,Keys[delta]}];
  gate[owner<>" finite evaluated correction",FreeQ[correction,eps|D|_Missing|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted]];
  answer=Association@Table[d->old["Counterterms"][d]+correction[d],{d,Keys[correction]}];
  <|"Counterterms"->answer,"Correction"->correction,"ConvolutionDifference"->delta|>];
differenceControls=<||>;
Do[newPath=FileNameJoin[{root,owner,"s11_result","s11_result.wl"}];
  oldPath=FileNameJoin[{root,owner,"s11_result","reference","before_dimensional_completion","s11_result.wl"}];
  controlNew=Get[newPath];controlOld=Get[oldPath];
  gate[owner<>" accepted own comparison tensors",And@@Values[controlNew["Checks"]]&&And@@Values[controlOld["Checks"]]&&
    controlNew["SourceHash"]===FileHash[differenceBaseline,"SHA256"]&&
    controlNew["PreviousSubtractionHash"]===FileHash[oldPath,"SHA256"]];
  timing=AbsoluteTiming[differenceCounterterms[controlOld,controlNew,owner]];
  gate[owner<>" entire accepted counterterm tensor reproduced",zeroArray[
    Values[timing[[2]]["Counterterms"]]-Values[controlNew["Counterterms"]]]];
  AssociateTo[differenceControls,owner-><|"OldHash"->FileHash[oldPath,"SHA256"],"NewHash"->FileHash[newPath,"SHA256"],
    "Seconds"->timing[[1]],"Accepted"->True|>],{owner,{"Hqg","Hgq"}}];
differenceTiming=AbsoluteTiming[differenceCounterterms[previous,
  <|"Prefactor"->reference["Prefactor"],"MSPole"->msPole,"ConvolutionsD"->convolutionsD|>,channel]];
counterterms=differenceTiming[[2]]["Counterterms"];
differenceTailStart=First[First[StringPosition[differenceText,"gate[\"all subtraction coefficients evaluated\""]]];
differenceTail=StringDrop[differenceText,differenceTailStart-1];
differenceExport="put[result, FileNameJoin[{resultDir, \"s11_result.wl\"}]];";
gate["unique original subtraction export",StringCount[differenceTail,differenceExport]===1];
differenceTail=StringReplace[differenceTail,differenceExport->
  "AssociateTo[result,{\"DispatchSourceHash\"->FileHash[differenceSource,\"SHA256\"],\"DifferenceControls\"->differenceControls,\"DifferenceSeconds\"->differenceTiming[[1]]}];"<>differenceExport];
gate["original subtraction export syntax",SyntaxQ[differenceTail]];
ToExpression[differenceTail,InputForm];

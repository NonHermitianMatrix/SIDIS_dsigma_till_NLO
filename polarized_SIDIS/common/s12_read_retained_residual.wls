(* Read the actual residual rejected by the retained-coefficient shortcut. *)
$HistoryLength=0;
residualSource=FileNameJoin[{Directory[],"common","s12_read_retained_residual.wls"}];
residualBase=FileNameJoin[{Directory[],"common","s12_assemble_real_retained_series.wls"}];
If[IntegerString[FileHash[residualBase,"SHA256"],16,64]=!=
  "a6c7321e5aba5cc0754323ea5fb369646e6ba95d1039301ec26ab019903f3346",Quit[1]];
residualText=Import[residualBase,"Text"];
residualBoundary="\nretainedControlPath=";
If[StringCount[residualText,residualBoundary]=!=1 || !SyntaxQ[Import[residualSource,"Text"]],Quit[1]];
ToExpression[First[StringSplit[residualText,residualBoundary]],InputForm];
residualIndex=44;residualTask=mapped["Components"][[residualIndex]];
residualCoefficients=Select[residualTask["ReducedCoefficients"],#=!=0&]/.transverseRule;
residualMasters=Keys[residualCoefficients];
Print["ACTUAL_COMPONENT ",InputForm[KeyTake[residualTask,{"Sector","Kind","Index"}]]];
Print["ORDERED_MASTERS ",InputForm[residualMasters]];
residualRows=Table[
  residualCoefficient=residualCoefficients[master]/.D->4-2eps;
  residualMaster=regions["OrdinaryMasters"][master];
  residualOrder=-Exponent[Expand[Normal[residualMaster],eps],eps,Min];
  residualRational=bounded[Together[residualCoefficient],"actual residual input"];
  residualNumerator=Numerator[residualRational];residualDenominator=Denominator[residualRational];
  residualValue=bounded[rationalSeries[rat[residualNumerator,residualDenominator],residualOrder],"actual recurrence"];
  residualEquation=bounded[Expand[residualDenominator residualValue-residualNumerator,eps],"actual reconstruction residual"];
  residualFirst=Exponent[residualEquation,eps,Min];
  residualLast=residualOrder+Exponent[residualDenominator,eps,Min];
  residualOriginalZero=bounded[zeroCoefficient[residualEquation],"original reference residual predicate"];
  Print["ACTUAL_RESIDUAL ",InputForm[{master,residualEquation}]];
  Print["ACTUAL_RESIDUAL_SUPPORT ",InputForm[{master,residualOrder,residualFirst,residualLast,residualOriginalZero}]];
  <|"Master"->master,"Order"->residualOrder,"Denominator"->residualDenominator,
    "Residual"->residualEquation,"First"->residualFirst,"Last"->residualLast,
    "OriginalReferenceZero"->residualOriginalZero|>,{master,Drop[residualMasters,2]}];
residualResult=<|"SourceHash"->FileHash[residualSource,"SHA256"],"BaseHash"->FileHash[residualBase,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"ComponentIndex"->residualIndex,
  "ComponentHash"->Hash[residualTask,"SHA256"],"Rows"->residualRows|>;
residualDirectory=FileNameJoin[{root,channel,"s12_retained_residual_result"}];
If[!DirectoryQ[residualDirectory],CreateDirectory[residualDirectory,CreateIntermediateDirectories->True]];
residualOutput=FileNameJoin[{residualDirectory,"s12_result.wl"}];
Put[residualResult,residualOutput];gate["exact residual equation reload",Get[residualOutput]===residualResult];
Print["PASS: actual retained residual read"];Quit[0];

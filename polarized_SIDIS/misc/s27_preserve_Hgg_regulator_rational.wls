(* Preserve an existing exact regulator-polynomial ratio without multivariate recombination. *)
localRegulatorRational[coefficient_]:=Module[{numerator,denominator,seconds},
 {seconds,{numerator,denominator}}=AbsoluteTiming[{Numerator[coefficient],Denominator[coefficient]}];
 If[PolynomialQ[numerator,eps]&&PolynomialQ[denominator,eps]&&denominator=!=0,
  gate["stored regulator-polynomial ratio reconstructs",numerator/denominator===coefficient];
  Print["REGULATOR_RATIO_PRESERVED bytes ",ByteCount[coefficient]," seconds ",seconds];coefficient,
  bounded[Together[coefficient],"reference fallback regulator rational"]]];

If[Environment["POLARIZED_SIDIS_VALIDATE_REGULATOR"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];
 source=ExpandFileName[$InputFileName];checks=<||>;
 gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];bounded[v_,label_]:=MemoryConstrained[
  TimeConstrained[v,1200,gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
 readAccepted[relative_,receiptRelative_]:=Module[{p=FileNameJoin[{root,relative}],receipt},
  receipt=Import[FileNameJoin[{root,receiptRelative}],"RawJSON"];
  gate["accepted input "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[p,"SHA256"],16,64]];Get[p]];
 captured=readAccepted["misc/s26_result/s26_result.wl","misc/s26_result/s26_execution.json"];
 own=readAccepted["misc/s23_result/s23_result.wl","misc/s23_result/s23_execution.json"];
 reference=readAccepted["Hqqbar/s12_rational_series_result/s12_result.wl","Hqqbar/s12_rational_series_result/s12_execution.json"];
 argumentProof=readAccepted["misc/s24_result/s24_result.wl","misc/s24_result/s24_execution.json"];
 Get[FileNameJoin[{root,"misc","s24_canonical_Hgg_arguments.wls"}]];
 gate["accepted argument comparison retained",TrueQ[argumentProof["Accepted"]]&&And@@Values[argumentProof["Checks"]]&&
  DownValues[localCanonicalScalarArguments]===argumentProof["Definitions"]];
 zeroCoefficient[value_]:=Factor[Together[localCanonicalScalarArguments[value]]]===0;
 DownValues[epsilonSeries]=reference["OriginalDefinitions"][[1]];
 DownValues[laurentProduct]=reference["OriginalDefinitions"][[2]];
 DownValues[rationalSeries]=reference["RationalDefinitions"];
 DownValues[checkedRationalSeries]=reference["CheckedRationalDefinitions"];
 DownValues[ordinaryMasterProduct]=reference["ProductDefinitions"];
 referenceSeriesComparisonText=ReadString[FileNameJoin[{root,"common","s12_check_rational_master_product.wls"}]];
 gate["executed reference product source retained",reference["SourceHash"]===FileHash[FileNameJoin[{root,"common","s12_check_rational_master_product.wls"}],"SHA256"]];
 parentPath=FileNameJoin[{root,"misc","s11_assemble_Hgg_real.wls"}];parentText=ReadString[parentPath];
 parentConfig=Import[FileNameJoin[{root,"misc","s11_inputs.json"}],"RawJSON"];
 gate["reviewed actual parent source",parentConfig["source_sha256"]===IntegerString[FileHash[parentPath,"SHA256"],16,64]];
 start="productOriginalDefinitions = ";finish="recoilProofRelative = ";
 gate["complete executed product adapter boundary",StringCount[parentText,start]===1&&StringCount[parentText,finish]===1];
 adapter=start<>First[StringSplit[Last[StringSplit[parentText,start]],finish]];
 gate["complete executed product adapter syntax",SyntaxQ[adapter]];ToExpression[adapter,InputForm];
 originalChecked=DownValues[checkedRationalSeries];originalProduct=DownValues[ordinaryMasterProduct];
 checkedStart="\ncheckedRationalSeries[";checkedEnd="\nordinaryMasterProduct[";
 gate["complete checked recurrence source boundary",StringCount[referenceSeriesComparisonText,checkedStart]===1&&StringCount[referenceSeriesComparisonText,checkedEnd]===1];
 checkedText=checkedStart<>First[StringSplit[Last[StringSplit[referenceSeriesComparisonText,checkedStart]],checkedEnd]];
 checkedOld="rational = bounded[Together[coefficient], \"rational master coefficient\"];";
 productOld="rational = bounded[Together[coefficient], \"coefficient regulator valuation\"];";
 replacement="rational = localRegulatorRational[coefficient];";
 gate["only two rational preparation calls changed",StringCount[checkedText,checkedOld]===1&&StringCount[productCorrectedText,productOld]===1];
 checkedNew=StringReplace[checkedText,checkedOld->replacement];productNew=StringReplace[productCorrectedText,productOld->replacement];
 gate["complete recurrence and product retained",SyntaxQ[checkedNew]&&SyntaxQ[productNew]&&
  StringReplace[checkedNew,replacement->checkedOld]===checkedText&&StringReplace[productNew,replacement->productOld]===productCorrectedText];
 ToExpression[checkedNew,InputForm];ToExpression[productNew,InputForm];
 {ownSeconds,ownValue}=AbsoluteTiming[ordinaryMasterProduct[own["Packet"]["Coefficient"],own["Packet"]["Master"],own["Packet"]["Order"],{"Own",own["ComponentIndex"],own["Master"]}]];
 gate["entire accepted own master product reproduced",bounded[zeroCoefficient[ownValue-own["Packet"]["Direct"]],"own regulator preparation comparison"]];
 mapPath=FileNameJoin[{root,"misc","s10_result","s10_result.wl"}];
 gate["captured actual map unchanged",captured["InputHash"]===FileHash[mapPath,"SHA256"]];
 scalarRules=Get[mapPath]["ScalarConventionRules"];ClearSystemCache[];
 library=Get[FileNameJoin[{root,"common","s06_result","s06_result.wl"}]];
 row=library["Library"]["s15"];regionPath=FileNameJoin[{root,row["File"]}];
 gate["pinned scalar master regions",IntegerString[FileHash[regionPath,"SHA256"],16,64]===row["SHA256"]];
 regions=Get[regionPath]/.scalarRules;master=regions["OrdinaryMasters"][captured["Master"]];
 {actualSeconds,actualValue}=AbsoluteTiming[ordinaryMasterProduct[captured["Coefficient"],master,own["Packet"]["Order"],{"Actual",captured["Facts"]["ComponentIndex"],captured["Master"]}]];
 gate["actual failed master product fully evaluated",FreeQ[actualValue,_CutIntegral|_Series|_SeriesData|_Missing|_Real|$Failed|$Aborted]];
 out=FileNameJoin[{root,"misc","s27_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 result=<|"Schema"->"polarized-sidis-direct-regulator-ratio-comparison-v1","SourceHash"->FileHash[source,"SHA256"],
  "ParentSourceHash"->FileHash[parentPath,"SHA256"],"CaptureHash"->FileHash[FileNameJoin[{root,"misc","s26_result","s26_result.wl"}],"SHA256"],
  "Definitions"->DownValues[localRegulatorRational],"OriginalCheckedDefinitions"->originalChecked,"OriginalProductDefinitions"->originalProduct,
  "CheckedDefinitions"->DownValues[checkedRationalSeries],"ProductDefinitions"->DownValues[ordinaryMasterProduct],
  "OwnValue"->ownValue,"ActualValue"->actualValue,"OwnSeconds"->ownSeconds,"ActualSeconds"->actualSeconds,
  "Checks"->checks,"NativeVersions"->{$Version,$FeynCalcVersion},"Accepted"->True|>;
 file=FileNameJoin[{out,"s27_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded regulator preparation proof",StringLength[serialized]<128*1024^2];Export[file,serialized,"Text"];
 gate["exact regulator preparation proof reload",Get[file]===result];
 Export[FileNameJoin[{out,"s27_checks.json"}],<|"checks"->checks,"own_seconds"->ownSeconds,"actual_seconds"->actualSeconds|>,"RawJSON"];
 Print["PASS: direct Hgg regulator ratio validated"];Quit[0]];

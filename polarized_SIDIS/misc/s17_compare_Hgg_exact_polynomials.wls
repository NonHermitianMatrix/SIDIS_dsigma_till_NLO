(* Native producer and consumer for an isolated exact-polynomial comparison. *)
$HistoryLength=0;
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
polynomialSource=ExpandFileName[$InputFileName];
polynomialRoot=DirectoryName[DirectoryName[polynomialSource]];
polynomialDriver=FileNameJoin[{polynomialRoot,"misc","s16_compare_Hgg_reference_sum.wls"}];
If[IntegerString[FileHash[polynomialDriver,"SHA256"],16,64]=!=
 "8a02d9449c8f940241011ee7e2afd83e3261906504ac1cceee7882e2822c0b6a",Quit[1]];
polynomialText=ReadString[polynomialDriver];
polynomialPrefix=StringTake[polynomialText,
 First[First[StringPosition[polynomialText,"\n{comparisonSeconds,comparisonAnswer}"]]]-1];
polynomialPrefix=StringReplace[polynomialPrefix,
 "$FeynCalcStartupMessages=False;Get[\"FeynCalc`\"];"->"Null;"];
If[!SyntaxQ[polynomialPrefix]||!SyntaxQ[ReadString[polynomialSource]],Quit[1]];
ToExpression[polynomialPrefix,InputForm];
polynomialDir=FileNameJoin[{root,"misc","s17_result"}];
If[!DirectoryQ[polynomialDir],CreateDirectory[polynomialDir,CreateIntermediateDirectories->True]];
polynomialVariables=<||>;
polynomialCase[label_,terms_List,expected_:None]:=Module[
 {rational,numerators,denominators,variables,encodedVariables,rules,encode,rows,factors,numeric,symbolic,unit,value},
 rational=bounded[Together[#],{label,"native rational term"}]&/@DeleteCases[terms,0];
 numerators=Numerator/@rational;denominators=Denominator/@rational;
 variables=Variables[Join[numerators,denominators,If[expected===None,{},
  {Numerator[Together[expected]],Denominator[Together[expected]]}]]];
 gate["rational polynomial variables "<>label,AllTrue[variables,Head[#]===Symbol&]&&
  FreeQ[{numerators,denominators},_Real|_Complex]];
 encodedVariables=Table[Symbol["Global`pfsVar"<>ToString[i]],{i,Length[variables]}];
 gate["unassigned polynomial transfer variables "<>label,AllTrue[encodedVariables,OwnValues[#]==={}&]];
 rules=Thread[variables->encodedVariables];
 encode[expression_]:=Module[{transformed,text},transformed=expression/.rules;text=ToString[transformed,InputForm];
  gate["exact native polynomial text "<>label,ToExpression[text,InputForm]===transformed];text];
 rows=MapThread[Function[{num,den},factors=FactorList[den];
  numeric=Select[factors,NumberQ[First[#]]&];symbolic=Select[factors,!NumberQ[First[#]]&];
  unit=Times@@(Power@@@numeric);
  gate["exact exported denominator "<>label,zero[den-unit (Times@@(Power@@@symbolic))]];
  <|"numerator"->encode[num],"denominator"->encode[den],"unit"->ToString[unit,InputForm],
   "factors"->({encode[First[#]],Last[#]}&/@symbolic)|>],{numerators,denominators}];
 value=<|"label"->label,"variables"->(ToString[#,InputForm]&/@encodedVariables),"terms"->rows|>;
 If[expected=!=None,AssociateTo[value,"expected"-><|"numerator"->encode[Numerator[Together[expected]]],
  "denominator"->encode[Denominator[Together[expected]]]|>]];
 AssociateTo[polynomialVariables,label->Thread[encodedVariables->variables]];value];
polynomialCases={polynomialCase["accepted_reference_control",controlTerms,controlValue],
 polynomialCase["Hgg_component_1_first_master",comparisonTerms]};
polynomialInputPath=FileNameJoin[{polynomialDir,"s17_input.json"}];
polynomialOutputPath=FileNameJoin[{polynomialDir,"s17_output.json"}];
polynomialBackendPath=FileNameJoin[{root,"misc","s18_sum_exact_polynomials.py"}];
polynomialPayload=<|"schema"->"polarized-sidis-exact-polynomial-input-v1","cases"->polynomialCases|>;
Export[polynomialInputPath,polynomialPayload,"RawJSON"];
gate["exact native JSON input round trip",Import[polynomialInputPath,"RawJSON"]===polynomialPayload];
Print["EXACT_POLYNOMIAL_INPUT_READY ",FileByteCount[polynomialInputPath]];
polynomialProcess=RunProcess[{"python3",polynomialBackendPath,polynomialInputPath,polynomialOutputPath}];
Print[polynomialProcess["StandardOutput"]];Print[polynomialProcess["StandardError"]];
gate["exact polynomial backend completed",polynomialProcess["ExitCode"]===0&&FileExistsQ[polynomialOutputPath]];
polynomialOutput=Import[polynomialOutputPath,"RawJSON"];
gate["exact polynomial backend identity",polynomialOutput["schema"]==="polarized-sidis-exact-polynomial-output-v1"&&
 polynomialOutput["input_sha256"]===IntegerString[FileHash[polynomialInputPath,"SHA256"],16,64]&&
 polynomialOutput["source_sha256"]===IntegerString[FileHash[polynomialBackendPath,"SHA256"],16,64]&&
 polynomialOutput["flint_version"]==="0.8.0"];
polynomialValues=Association@Map[Function[row,
 gate["exact polynomial reconstruction "<>row["label"],TrueQ[row["exact_termwise_reconstruction_passed"]]];
 row["label"]->((ToExpression[row["numerator"],InputForm]/ToExpression[row["denominator"],InputForm])/.
 polynomialVariables[row["label"]])],polynomialOutput["cases"]];
gate["native accepted reference coefficient equality",bounded[
 zero[polynomialValues["accepted_reference_control"]-controlValue],"native backend control comparison"]];
polynomialResult=<|"Schema"->"polarized-sidis-exact-polynomial-comparison-v1","Channel"->channel,
 "Component"->1,"Master"->comparisonMaster,"Value"->polynomialValues["Hgg_component_1_first_master"],
 "SourceHash"->FileHash[polynomialSource,"SHA256"],"BackendHash"->FileHash[polynomialBackendPath,"SHA256"],
 "ProductionSourceHash"->FileHash[comparisonDriver,"SHA256"],"ProductionConfigurationHash"->FileHash[localConfigPath,"SHA256"],
 "InputHash"->inputHash,"RawInputHash"->localRawInputHash,
 "InputFileHash"->FileHash[polynomialInputPath,"SHA256"],"OutputFileHash"->FileHash[polynomialOutputPath,"SHA256"],
 "NativeVersions"->{$Version,$FeynCalcVersion},"BackendVersion"->polynomialOutput["flint_version"],
 "Evidence"->(KeyDrop[#,{"numerator","denominator"}]&/@polynomialOutput["cases"]),
 "AcceptedOwnHggComparisonPassed"->False,"AdoptedForProduction"->False,"Checks"->checks|>;
putCompressed[polynomialResult,FileNameJoin[{polynomialDir,"s17_result.wl"}]];
Print["PASS: isolated exact polynomial comparison"];Quit[0];

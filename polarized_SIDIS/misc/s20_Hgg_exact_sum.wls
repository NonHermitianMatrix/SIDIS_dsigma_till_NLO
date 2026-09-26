(* Exact coefficient addition with a bounded, term-at-a-time native transfer. *)
localPolynomialTransfer[cases_List,path_]:=Module[
 {stream,mappings=<||>,nonzero,variables,encodedVariables,rules,encode,header,rational,
  numerator,denominator,factors,numerical,symbolic,unit,packet,serialized,expected,case},
 stream=OpenWrite[path,CharacterEncoding->"UTF-8"];
 WriteString[stream,"{\"schema\":\"polarized-sidis-exact-polynomial-input-v1\",\"cases\":["];
 Do[
  case=cases[[caseIndex]];nonzero=DeleteCases[case["Terms"],0];expected=Lookup[case,"Expected",None];
  variables=Sort[DeleteDuplicates[Cases[Join[nonzero,If[expected===None,{},{expected}]],_Symbol,Infinity]]];
  gate["exact polynomial transfer supports rational coefficients",FreeQ[nonzero,_Real|_Complex]];
  encodedVariables=Table[Symbol["Global`pfsVar"<>ToString[i]],{i,Length[variables]}];
  gate["unassigned exact polynomial variables",AllTrue[encodedVariables,OwnValues[#]==={}&]];
  rules=Thread[variables->encodedVariables];
  encode[expression_]:=Module[{value,text},value=expression/.rules;text=ToString[value,InputForm];
   gate["native polynomial text reconstructs",ToExpression[text,InputForm]===value];text];
  header=StringTrim[ExportString[<|"label"->case["Label"],
   "variables"->(ToString[#,InputForm]&/@encodedVariables)|>,"RawJSON"]];
  gate["native JSON header shape",StringTake[header,-1]==="}"];
  If[caseIndex>1,WriteString[stream,","]];WriteString[stream,StringDrop[header,-1],",\"terms\":["];
  Do[
   rational=bounded[Together[nonzero[[i]]],{"polynomial transfer",i}];
   numerator=Numerator[rational];denominator=Denominator[rational];
   gate["complete polynomial variable support",PolynomialQ[numerator,variables]&&PolynomialQ[denominator,variables]];
   factors=bounded[FactorList[denominator],{"polynomial denominator",i}];
   numerical=Select[factors,NumberQ[First[#]]&];symbolic=Select[factors,!NumberQ[First[#]]&];
   unit=Times@@(Power@@@numerical);
   gate["exported polynomial denominator reconstructs",zero[denominator-unit (Times@@(Power@@@symbolic))]];
   packet=<|"numerator"->encode[numerator],"denominator"->encode[denominator],"unit"->ToString[unit,InputForm],
    "factors"->({encode[First[#]],Last[#]}&/@symbolic)|>;
   serialized=ExportString[packet,"RawJSON"];
   gate["native JSON term reconstructs",ImportString[serialized,"RawJSON"]===packet];
   If[i>1,WriteString[stream,","]];WriteString[stream,serialized];
   If[Mod[i,64]===0,Print["EXACT_POLYNOMIAL_TRANSFER ",case["Label"]," ",i,"/",Length[nonzero]]],
   {i,Length[nonzero]}];
  WriteString[stream,"]"];
  If[expected=!=None,packet=<|"numerator"->encode[Numerator[Together[expected]]],
    "denominator"->encode[Denominator[Together[expected]]]|>;
   serialized=ExportString[packet,"RawJSON"];
   gate["native expected coefficient JSON reconstructs",ImportString[serialized,"RawJSON"]===packet];
   WriteString[stream,",\"expected\":",serialized]];
  WriteString[stream,"}"];AssociateTo[mappings,case["Label"]->Thread[encodedVariables->variables]],
  {caseIndex,Length[cases]}];
 WriteString[stream,"]}"];Close[stream];
 gate["bounded polynomial transfer file",FileByteCount[path]<512*1024^2];mappings];

localExactPolynomialSum[terms_List,purpose_]:=Module[
 {nonzero,identity,directory,inputPath,outputPath,mappings,process,output,row,value,evidence,
  inputFileHash,outputFileHash,elapsed,start},
 nonzero=DeleteCases[terms,0];
 If[nonzero==={},Return[<|"Value"->0,"Evidence"-><|"TermCount"->0|>|>]];
 If[!FreeQ[nonzero,_Complex],Return[streamedDenominatorSum[terms,purpose]]];
 start=AbsoluteTime[];identity=Hash[{inputHash,purpose,localPolynomialProofHash},"SHA256"];
 directory=FileNameJoin[{cache,"polynomial",IntegerString[identity,16]}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 inputPath=FileNameJoin[{directory,"input.json"}];outputPath=FileNameJoin[{directory,"output.json"}];
 mappings=localPolynomialTransfer[{<|"Label"->"production_sum","Terms"->nonzero|>},inputPath];
 inputFileHash=FileHash[inputPath,"SHA256"];
 gate["unchanged validated exact backend",FileHash[localPolynomialBackendPath,"SHA256"]===localPolynomialBackendHash];
 Print["EXACT_POLYNOMIAL_BACKEND_START ",InputForm[purpose]," terms ",Length[nonzero]," bytes ",FileByteCount[inputPath]];
 process=RunProcess[{"python3",localPolynomialBackendPath,inputPath,outputPath}];
 Print[process["StandardOutput"]];Print[process["StandardError"]];
 gate["exact production backend completed",process["ExitCode"]===0&&FileExistsQ[outputPath]];
 output=Import[outputPath,"RawJSON"];outputFileHash=FileHash[outputPath,"SHA256"];
 gate["exact production backend input and source",output["schema"]==="polarized-sidis-exact-polynomial-output-v1"&&
  output["input_sha256"]===IntegerString[inputFileHash,16,64]&&
  output["source_sha256"]===IntegerString[localPolynomialBackendHash,16,64]&&output["flint_version"]==="0.8.0"&&
  Length[output["cases"]]===1];
 row=First[output["cases"]];
 gate["complete production termwise reconstruction",row["label"]==="production_sum"&&
  row["term_count"]===Length[nonzero]&&TrueQ[row["exact_termwise_reconstruction_passed"]]];
 value=(ToExpression[row["numerator"],InputForm]/ToExpression[row["denominator"],InputForm])/.
  mappings["production_sum"];
 gate["exact scalar coefficient import",FreeQ[value,_Real|_CutIntegral|$Failed|$Aborted|_Integrate|_SeriesData]];
 elapsed=AbsoluteTime[]-start;
 evidence=<|"TermCount"->Length[nonzero],"FactorCount"->row["factor_count"],"InputBytes"->ByteCount[terms],
  "OutputBytes"->ByteCount[value],"BackendSeconds"->row["seconds"],"TransferAndSumSeconds"->elapsed,
  "InputFileHash"->inputFileHash,"OutputFileHash"->outputFileHash,"BackendHash"->localPolynomialBackendHash,
  "OwnHggValidationHash"->localPolynomialProofHash,"ExactTermwiseReconstructionPassed"->True|>;
 DeleteFile[{inputPath,outputPath}];DeleteDirectory[directory];
 Print["EXACT_POLYNOMIAL_ACCEPTED ",InputForm[purpose]," seconds ",elapsed," bytes ",ByteCount[value]];
 <|"Value"->value,"Evidence"->evidence|>];

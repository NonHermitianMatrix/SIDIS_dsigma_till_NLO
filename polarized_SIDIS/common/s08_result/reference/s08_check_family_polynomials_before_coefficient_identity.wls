(* Compare polynomial family collection with the reference on its actual inputs. *)
$HistoryLength=0;
polynomialSource=FileNameJoin[{Directory[],"common","s08_check_family_polynomials.wls"}];
polynomialBase=FileNameJoin[{Directory[],"common","s08_map_certified_group_targets.wls"}];
If[IntegerString[FileHash[polynomialBase,"SHA256"],16,64]=!=
  "f38a83d6b7080e4acbd9919f05a38ce602800f445e3bd594263f18bb8e4a091c",Quit[1]];
polynomialBaseText=Import[polynomialBase,"Text"];
If[StringCount[polynomialBaseText,"\nmapTargetTask[index_]"]=!=1||
  !SyntaxQ[Import[polynomialSource,"Text"]],Quit[1]];
polynomialPrefix=First[StringSplit[polynomialBaseText,"\nmapTargetTask[index_]"]];
If[!SyntaxQ[polynomialPrefix],Quit[1]];
ToExpression[polynomialPrefix,InputForm];
polynomialInspectionPath=FileNameJoin[{root,channel,"s08_map_equation_result","s08_result.wl"}];
polynomialInspectionSource=FileNameJoin[{root,"common","s08_inspect_group_map.wls"}];
polynomialReceipt=Import[FileNameJoin[{root,channel,"s08_map_equation_result","s08_execution.json"}],"RawJSON"];
gate["accepted operation inspection receipt",TrueQ[polynomialReceipt["passed"]]&&
  polynomialReceipt["result_sha256"][channel<>"/s08_map_equation_result/s08_result.wl"]===
    IntegerString[FileHash[polynomialInspectionPath,"SHA256"],16,64]];
polynomialInspection=Get[polynomialInspectionPath];
gate["actual operation input identity",polynomialInspection["Schema"]==="polarized-sidis-group-map-inspection-v1"&&
  polynomialInspection["Channel"]===channel&&And@@Values[polynomialInspection["Checks"]]&&
  polynomialInspection["SourceHash"]===FileHash[polynomialInspectionSource,"SHA256"]&&
  polynomialInspection["BaseSourceHash"]===FileHash[polynomialBase,"SHA256"]&&
  polynomialInspection["InputHashes"]===inputHashes&&polynomialInspection["TargetInputHash"]===targetInputHash&&
  polynomialInspection["MappingInputHash"]===inputHash&&polynomialInspection["NativeVersions"]==={$Version,$FeynCalcVersion}];
polynomialOriginalFamily=DownValues[familyRows];
polynomialOriginalMap=DownValues[mapExpression];
gate["unchanged inspected family and mapping definitions",
  polynomialInspection["OriginalFamilyDefinitions"]===polynomialOriginalFamily&&
  polynomialInspection["OriginalMappingDefinitions"]===polynomialOriginalMap];

polynomialFamilyRows[transformed_,family_] := Module[
  {variables={v3,v4},pattern,numerator,denominator,powers,coefficient,polynomial,rows,
   reconstruction,residual,residualRows},
  pattern=Alternatives@@variables;
  denominator=bounded[Factor[Denominator[transformed]],{family,"outer family denominator"}];
  numerator=bounded[Expand[Numerator[transformed],pattern],{family,"selective family numerator expansion"}];
  gate["family numerator remains polynomial",PolynomialQ[numerator,variables]];
  powers=Exponent[denominator,#]&/@variables;
  gate["integer nonnegative family denominator powers",AllTrue[powers,IntegerQ[#]&&#>=0&]];
  coefficient=bounded[Cancel[denominator/(Times@@MapThread[Power,{variables,powers}])],
    {family,"family denominator coefficient"}];
  gate["family denominator remains a Laurent monomial",FreeQ[coefficient,pattern]];
  gate["exact outer family denominator reconstruction",
    bounded[Expand[denominator-coefficient Times@@MapThread[Power,{variables,powers}],pattern],
      {family,"denominator reconstruction"}]===0];
  polynomial=bounded[CoefficientRules[numerator,variables],{family,"family polynomial coefficients"}];
  gate["family coefficients independent of integration variables",FreeQ[Last/@polynomial,pattern]];
  gate["exact native family polynomial collection",bounded[Expand[numerator-
    Total[(Last[#] Times@@MapThread[Power,{variables,First[#]}])&/@polynomial],pattern],
    {family,"native polynomial reconstruction"}]===0];
  rows=Association[Map[Function[entry,
    CutIntegral[family,Join[ConstantArray[1,Length[geometry["CutMomenta"]]],powers-First[entry]]] ->
      bounded[Factor[Last[entry]/coefficient],{family,First[entry],"family coefficient factor"}]],polynomial]];
  reconstruction=Total[KeyValueMap[Function[{integral,value},
    value Times@@MapThread[Power,{variables,-Drop[integral[[2]],2]}]],rows]];
  residual=bounded[Expand[denominator reconstruction-numerator,pattern],{family,"family polynomial residual"}];
  gate["complete family residual is polynomial",PolynomialQ[residual,variables]];
  residualRows=bounded[CoefficientRules[residual,variables],{family,"residual polynomial collection"}];
  gate["complete family Laurent coefficients reconstruct",And@@
    (bounded[zero[Last[#]],{family,First[#],"exact residual coefficient"}]&/@residualRows)];
  gate["both cut powers unchanged in polynomial family",
    And@@(Take[#[[2]],Length[geometry["CutMomenta"]]]===ConstantArray[1,Length[geometry["CutMomenta"]]]&/@Keys[rows])];
  rows];

familyRows[expression_,family_] := polynomialFamilyRows[expression/.families[family]["UncutCoordinateRules"],family];
polynomialDispatch=DownValues[familyRows];
gate["only family collection changed",DownValues[mapExpression]===polynomialOriginalMap];
polynomialControlTimed=AbsoluteTiming[bounded[mapExpression[targetControlTask["Value"]/.coordinateRules],
  "complete accepted reference map with polynomial families"]];
polynomialControl=polynomialControlTimed[[2]];
gate["same complete accepted control target inventory",Sort[Keys[polynomialControl]]===Sort[Keys[targetFixture["Coefficients"]]]];
gate["complete accepted control coefficients agree",And@@KeyValueMap[
  Function[{key,value},bounded[zero[value-targetFixture["Coefficients"][key]],{"own reference control",key}]],polynomialControl]];
Print["POLYNOMIAL_REFERENCE_CONTROL_SECONDS ",polynomialControlTimed[[1]]];

polynomialActualRows=Table[
  gate["captured family-coordinate operation",row["Outcome"]["Operation"]==="family coordinates Together"&&
    !MissingQ[row["OperationInput"]]];
  atoms=bounded[extractAtoms[row["Equation"]],{row["ComponentIndex"],"actual group atoms"}];
  decomposition=decompose[First[atoms]];firstKey=First[Keys[decomposition]];
  support=Flatten[Position[List@@firstKey,_?(#>0&)]];
  family=SelectFirst[familyNames,Complement[support,families[#]["UncutIndices"]]==={}&,Missing["NoFamily"]];
  gate["actual captured family identified",!MissingQ[family]];
  familyInput=bounded[Cancel[Last[atoms] decomposition[firstKey]/
    (Times@@MapThread[Power,{denominators,List@@firstKey}])],"actual reference family input"]/.families[family]["UncutCoordinateRules"];
  gate["exact captured operation input reproduced",familyInput===row["OperationInput"]];
  Print["ACTUAL_POLYNOMIAL_FAMILY ",row["ComponentIndex"]," family ",family," input bytes ",ByteCount[familyInput]];
  timed=AbsoluteTiming[polynomialFamilyRows[familyInput,family]];
  Print["ACTUAL_POLYNOMIAL_FAMILY_SECONDS ",timed[[1]]," targets ",Length[timed[[2]]]];
  <|"ComponentIndex"->row["ComponentIndex"],"Family"->family,"Seconds"->timed[[1]],
    "InputBytes"->ByteCount[familyInput],"Coefficients"->timed[[2]]|>,{row,polynomialInspection["Rows"]}];
polynomialProof=<|"Schema"->"polarized-sidis-family-polynomial-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[polynomialSource,"SHA256"],"InspectionHash"->FileHash[polynomialInspectionPath,"SHA256"],
  "BaseSourceHash"->FileHash[polynomialBase,"SHA256"],"InputHashes"->inputHashes,
  "TargetInputHash"->targetInputHash,"MappingInputHash"->inputHash,"NativeVersions"->{$Version,$FeynCalcVersion},
  "OriginalFamilyDefinitions"->polynomialOriginalFamily,"OriginalMappingDefinitions"->polynomialOriginalMap,
  "Definitions"->DownValues[polynomialFamilyRows],"DispatchDefinitions"->polynomialDispatch,
  "ControlSeconds"->polynomialControlTimed[[1]],"ControlCoefficients"->polynomialControl,
  "ActualRows"->polynomialActualRows,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
polynomialDir=FileNameJoin[{root,channel,"s08_family_polynomial_result"}];
If[!DirectoryQ[polynomialDir],CreateDirectory[polynomialDir,CreateIntermediateDirectories->True]];
polynomialOutput=FileNameJoin[{polynomialDir,"s08_result.wl"}];
polynomialSerialized="Uncompress["<>ToString[bounded[Compress[polynomialProof],"polynomial proof compression"],InputForm]<>"]\n";
gate["polynomial proof file bound",StringLength[polynomialSerialized]<128*1024^2];
Export[polynomialOutput<>".tmp",polynomialSerialized,"Text"];
gate["polynomial proof exact native reload",Get[polynomialOutput<>".tmp"]===polynomialProof];
RenameFile[polynomialOutput<>".tmp",polynomialOutput,OverwriteTarget->True];
Export[FileNameJoin[{polynomialDir,"s08_checks.json"}],<|"checks"->checks,
  "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_check_family_polynomials"];Quit[0];

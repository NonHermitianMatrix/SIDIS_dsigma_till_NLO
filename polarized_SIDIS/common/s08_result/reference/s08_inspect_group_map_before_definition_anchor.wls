(* Read and time the actual reference mapping operations in the stalled groups. *)
$HistoryLength=0;
inspectionSource=FileNameJoin[{Directory[],"common","s08_inspect_group_map.wls"}];
inspectionBase=FileNameJoin[{Directory[],"common","s08_map_certified_group_targets.wls"}];
If[IntegerString[FileHash[inspectionBase,"SHA256"],16,64]=!=
  "f38a83d6b7080e4acbd9919f05a38ce602800f445e3bd594263f18bb8e4a091c",Quit[1]];
inspectionBaseText=Import[inspectionBase,"Text"];
If[StringCount[inspectionBaseText,"\nmapTargetTask[index_]"]=!=1||
  !SyntaxQ[Import[inspectionSource,"Text"]],Quit[1]];
inspectionPrefix=First[StringSplit[inspectionBaseText,"\nmapTargetTask[index_]"]];
If[!SyntaxQ[inspectionPrefix],Quit[1]];
ToExpression[inspectionPrefix,InputForm];
originalMapDefinitions=DownValues[mapExpression];
originalFamilyDefinitions=DownValues[familyRows];
inspectionOriginal=StringTake[targetMapperText,{
  First[First[StringPosition[targetMapperText,"merge[pieces_List]"]]],
  First[First[StringPosition[targetMapperText,"\n\ncoefficientPath ="]]]-1}];
inspectionReplacements={
  "{powers, prefactor} = extractAtoms[expression];" ->
    "{powers, prefactor} = inspectOperation[\"extract atoms\",expression,extractAtoms[expression]];",
  "decomposition = decompose[powers];" ->
    "decomposition = inspectOperation[\"partial fractions\",powers,decompose[powers]];",
  "value = Cancel[prefactor coefficient/(Times @@ MapThread[Power, {denominators, indices}])];" ->
    "value = inspectOperation[\"family input cancellation\",prefactor coefficient/(Times @@ MapThread[Power,{denominators,indices}]),Cancel[prefactor coefficient/(Times @@ MapThread[Power,{denominators,indices}])]];",
  "transformed = Together[expression /. spec[\"UncutCoordinateRules\"]];" ->
    "transformed = inspectOperation[\"family coordinates Together\",expression /. spec[\"UncutCoordinateRules\"],Together[expression /. spec[\"UncutCoordinateRules\"]]];",
  "numerator = Expand[Numerator[transformed]];" ->
    "numerator = inspectOperation[\"family numerator expansion\",Numerator[transformed],Expand[Numerator[transformed]]];",
  "denominator = Factor[Denominator[transformed]];" ->
    "denominator = inspectOperation[\"family denominator factor\",Denominator[transformed],Factor[Denominator[transformed]]];",
  "polynomial = CoefficientRules[numerator, {v3, v4}];" ->
    "polynomial = inspectOperation[\"family polynomial coefficients\",numerator,CoefficientRules[numerator,{v3,v4}]];",
  "Factor[Last[entry]/denominatorCoefficient]" ->
    "inspectOperation[\"family coefficient factor\",Last[entry]/denominatorCoefficient,Factor[Last[entry]/denominatorCoefficient]]",
  "zero[reconstruction - transformed]" ->
    "inspectOperation[\"family reconstruction\",reconstruction-transformed,zero[reconstruction-transformed]]",
  "rows = merge[pieces];" ->
    "rows = inspectOperation[\"merge family maps\",pieces,merge[pieces]];",
  "zero[reconstruction - expression]" ->
    "inspectOperation[\"complete map reconstruction\",reconstruction-expression,zero[reconstruction-expression]]"};
gate["unique reference operation instrumentation",And@@(StringCount[inspectionOriginal,First[#]]===1&/@inspectionReplacements)];
inspectionInstrumented=StringReplace[inspectionOriginal,inspectionReplacements];
gate["all original mapping equations and gates preserved",
  StringReplace[inspectionInstrumented,Reverse/@inspectionReplacements]===inspectionOriginal];
gate["instrumented mapping syntax",SyntaxQ[inspectionInstrumented]];
SetAttributes[inspectOperation,HoldRest];
inspectOperation[name_,input_,expression_] := Module[{actual=input,seconds,answer},
  Print["MAP_NATIVE_BEGIN ",name," bytes ",ByteCount[actual]];
  {seconds,answer}=AbsoluteTiming[TimeConstrained[MemoryConstrained[expression,4*1024^3,
    Missing["MemoryBound"]],120,Missing["TimeBound"]]];
  AppendTo[inspectionMeasurements,<|"Operation"->name,"Seconds"->seconds,
    "InputBytes"->ByteCount[actual],"OutputBytes"->ByteCount[answer],
    "Status"->If[MissingQ[answer],answer,"Completed"]|>];
  Print["MAP_NATIVE_END ",InputForm[Last[inspectionMeasurements]]];
  If[MissingQ[answer],inspectionFailedInput=actual;
    Throw[KeyTake[Last[inspectionMeasurements],{"Operation","Status"}],"MapInspection"]];answer];
ToExpression[inspectionInstrumented,InputForm];
inspectionRows=Table[
  inspectionMeasurements={};inspectionFailedInput=Missing["NoBoundReached"];
  task=tasks[[index]];equation=task["Value"]/.coordinateRules;
  groups=bounded[groupDenominators[equation],{index,"accepted grouping"}];
  groupEquation=First[KeyValueMap[#2/(Times@@MapThread[Power,{denominators,#1}])&,groups]];
  Print["ACTUAL_MAP_GROUP ",index," task ",KeyDrop[task,"Value"]," powers ",First[Keys[groups]],
    " bytes ",ByteCount[groupEquation]];
  outcome=Catch[<|"Status"->"Completed","Coefficients"->mapExpression[groupEquation]|>,"MapInspection"];
  <|"ComponentIndex"->index,"Task"->KeyDrop[task,"Value"],"GroupIndex"->1,
    "Powers"->First[Keys[groups]],"Equation"->groupEquation,"OperationInput"->inspectionFailedInput,
    "Outcome"->outcome,"Measurements"->inspectionMeasurements|>,{index,{25,26}}];
inspectionResult=<|"Schema"->"polarized-sidis-group-map-inspection-v1","Channel"->channel,
  "SourceHash"->FileHash[inspectionSource,"SHA256"],"BaseSourceHash"->FileHash[inspectionBase,"SHA256"],
  "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,"MappingInputHash"->inputHash,
  "NativeVersions"->{$Version,$FeynCalcVersion},"OriginalMappingCode"->inspectionOriginal,
  "OriginalMappingDefinitions"->originalMapDefinitions,"OriginalFamilyDefinitions"->originalFamilyDefinitions,
  "Rows"->inspectionRows,"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
inspectionDir=FileNameJoin[{root,channel,"s08_map_equation_result"}];
If[!DirectoryQ[inspectionDir],CreateDirectory[inspectionDir,CreateIntermediateDirectories->True]];
inspectionOutput=FileNameJoin[{inspectionDir,"s08_result.wl"}];
inspectionSerialized="Uncompress["<>ToString[bounded[Compress[inspectionResult],"inspection compression"],InputForm]<>"]\n";
gate["inspection file bound",StringLength[inspectionSerialized]<128*1024^2];
Export[inspectionOutput<>".tmp",inspectionSerialized,"Text"];
gate["inspection exact native reload",Get[inspectionOutput<>".tmp"]===inspectionResult];
RenameFile[inspectionOutput<>".tmp",inspectionOutput,OverwriteTarget->True];
Export[FileNameJoin[{inspectionDir,"s08_checks.json"}],<|"checks"->checks,
  "rows"->(ToString[KeyDrop[#,{"Equation","OperationInput"}],InputForm]&/@inspectionRows),
  "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s08_inspect_group_map"];Quit[0];

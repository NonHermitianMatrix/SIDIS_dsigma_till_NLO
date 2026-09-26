(* Compare early polynomial reduction on the saved own nonzero scalar equation. *)
$HistoryLength=0;
studyPath=FileNameJoin[{Directory[],"common","s05_check_scalar_power_reduction.wls"}];
productionPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[productionPath,"SHA256"],16,64]=!="ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",Quit[1]];
productionText=Import[productionPath,"Text"];
boundary="\nDo[\n  amplitudes =";
If[StringCount[productionText,boundary]=!=1 || !SyntaxQ[Import[studyPath,"Text"]],Quit[1]];
prefix=First[StringSplit[productionText,boundary]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;$LoadAddOns={"FeynArts"};Get["FeynCalc`"];
If[StringCount[prefix,"Get[\"FeynCalc`\"]"] =!= 1,Quit[1]];
prefix=StringReplace[prefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[prefix],Quit[1]];ToExpression[prefix,InputForm];
gate["own scalar power comparison channel",channel==="Hgg"];
parentRelative="Hgg/s05_zero_angular_result/s05_result.wl";
parentPath=FileNameJoin[{root,parentRelative}];
parent=Get[parentPath];parentReceipt=Import[FileNameJoin[{DirectoryName[parentPath],"s05_execution.json"}],"RawJSON"];
gate["accepted own saved equation producer",TrueQ[parentReceipt["passed"]] &&
  parentReceipt["result_sha256"][parentRelative]===IntegerString[FileHash[parentPath,"SHA256"],16,64] &&
  parent["Schema"]==="polarized-sidis-own-angular-zero-comparison-v1" && parent["Channel"]===channel &&
  parent["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_Hgg_zero_angular.wls"}],"SHA256"] &&
  parent["ProductionSourceHash"]===FileHash[productionPath,"SHA256"] &&
  parent["InputHash"]===inputHash && parent["InputHashes"]===inputHashes &&
  parent["NativeVersions"]==={$Version,$FeynCalcVersion} && And@@Values[parent["Checks"]]];
originalDefinitions=DownValues[algebraicReduceOne];
gate["same original scalar reduction equations",parent["OriginalReductionDefinitions"]===
  {DownValues[algebraicReduce],DownValues[algebraicReduceOne],DownValues[angularAverage],DownValues[angularAverageOne]}];
earlyPowerReduce[value_] := Module[{expanded,terms,powers,coefficients,distinct,divisions,remainders,reduced},
  If[!PolynomialQ[value,transverseK],Return[algebraicReduceOne[value]]];
  gate["early power exact scalar input",FreeQ[value,_ConditionalExpression|_Piecewise|_Real|$Failed|$Aborted]];
  expanded=Expand[value,transverseK];
  gate["early selective expansion reconstructs",Expand[value-expanded,transverseK]===0];
  terms=If[Head[expanded]===Plus,List@@expanded,{expanded}];
  powers=If[#===0,0,Exponent[#,transverseK]]&/@terms;
  gate["early transverse powers nonnegative integral",AllTrue[powers,IntegerQ[#] && #>=0&]];
  coefficients=terms/.transverseK->1;
  gate["early coefficients independent of transverse variable",FreeQ[coefficients,transverseK]];
  gate["early complete monomial reconstruction",MapThread[Times,{coefficients,transverseK^#&/@powers}]===terms];
  distinct=DeleteDuplicates[powers];
  divisions=PolynomialReduce[transverseK^#,{transverseConstraint},{transverseK}]&/@distinct;
  gate["early exact native polynomial division",And@@MapThread[
    zero[transverseK^#1-First[First[#2]] transverseConstraint-Last[#2]]&,{distinct,divisions}]];
  gate["early remainder degrees below constraint",AllTrue[Last/@divisions,
    #===0 || Exponent[#,transverseK]<Exponent[transverseConstraint,transverseK]&]];
  remainders=powers/.Thread[distinct->(Last/@divisions)];
  reduced=Total[MapThread[Times,{coefficients,remainders}]];
  Print["EARLY_TRANSVERSE_POWER_REDUCTION ",InputForm[<|"InputBytes"->ByteCount[value],
    "PowerSupport"->distinct,"ReducedBytes"->ByteCount[reduced]|>]];
  algebraicReduceOne[reduced]];
representative=parent["RepresentativeInputs"]["UnchangedReduction"];
equation=representative["RestoredEquation"];
gate["complete saved scalar equation identity",Hash[equation,"SHA256"]===
  SelectFirst[parent["Comparisons"],#["PhotonIndices"]===representative["PhotonIndices"]&]["Components"][[representative["Component"]]]["InputHash"]];
ClearSystemCache[];
{originalSeconds,originalValue}=AbsoluteTiming[bounded[algebraicReduceOne[equation],"original saved scalar equation"]];
ClearSystemCache[];
{candidateSeconds,candidateValue}=AbsoluteTiming[bounded[earlyPowerReduce[equation],"early-power saved scalar equation"]];
gate["complete original scalar value reproduced",bounded[zero[candidateValue-originalValue],"complete scalar comparison"]];
label=First[labels];gate["single own real sector",labels==={label}];
sectorCode=StringDrop[sourceSection[productionText,boundary,"\n  slots ="],StringLength["\nDo["]];
gate["unchanged own sector initialization syntax",SyntaxQ[sectorCode]];ToExpression[sectorCode,InputForm];
controlPair=parent["ControlPair"];gate["own accepted diagonal pair",SameQ@@controlPair];
controlPath=FileNameJoin[{cache,label<>"_"<>ToString[First[controlPair]]<>"_"<>ToString[Last[controlPair]]<>".wl"}];
gate["own accepted control artifact",FileHash[controlPath,"SHA256"]===parent["ControlHash"]];
control=Get[controlPath];gate["own accepted control conventions",control["InputHash"]===inputHash && And@@Values[control["Checks"]]];
acceptedProjection=Extract[control["PhotonMatrix"],representative["PhotonIndices"]];
acceptedCoefficient=Flatten[First[compactSpinResponse[{acceptedProjection},inVariables,outVariables]]][[representative["Component"]]];
candidateAverage=bounded[angularAverage[candidateValue],"candidate unchanged angular average"];
gate["own accepted projected coefficient reproduced",bounded[zero[candidateAverage-acceptedCoefficient],"own accepted coefficient comparison"]];
gate["original scalar implementation retained",DownValues[algebraicReduceOne]===originalDefinitions];
result=<|"Schema"->"polarized-sidis-scalar-power-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[studyPath,"SHA256"],"ProductionSourceHash"->FileHash[productionPath,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,$FeynCalcVersion},
  "ParentHash"->FileHash[parentPath,"SHA256"],"ControlHash"->FileHash[controlPath,"SHA256"],
  "Equation"->equation,"EquationHash"->Hash[equation,"SHA256"],"OriginalValue"->originalValue,
  "CandidateValue"->candidateValue,"AcceptedCoefficient"->acceptedCoefficient,"CandidateAverage"->candidateAverage,
  "OriginalSeconds"->originalSeconds,"CandidateSeconds"->candidateSeconds,
  "OriginalDefinitions"->originalDefinitions,"CandidateDefinitions"->DownValues[earlyPowerReduce],
  "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
directory=FileNameJoin[{root,channel,"s05_scalar_power_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
path=FileNameJoin[{directory,"s05_result.wl"}];
serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
gate["bounded scalar comparison output",StringLength[serialized]<128*1024^2];
Export[path<>".tmp",serialized,"Text"];gate["exact scalar comparison reload",Get[path<>".tmp"]===result];
RenameFile[path<>".tmp",path,OverwriteTarget->True];
Export[FileNameJoin[{directory,"s05_checks.json"}],<|"checks"->checks,"original_seconds"->originalSeconds,
  "candidate_seconds"->candidateSeconds,"job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["SCALAR_POWER_COMPARISON ",InputForm[KeyTake[result,{"OriginalSeconds","CandidateSeconds"}]]];
Print["PASS: s05_check_scalar_power_reduction"];Quit[0];

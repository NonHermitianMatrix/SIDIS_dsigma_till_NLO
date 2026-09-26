(* Resolve the saved gluon spin polynomial before the unchanged native scalar work. *)
$HistoryLength=0;
studyRoot=Directory[];
studySource=FileNameJoin[{studyRoot,"common","s05_check_Hgg_components_angular.wls"}];
inputSource=FileNameJoin[{studyRoot,"common","s05_prepare_Hgg_trace_inputs.wls"}];
If[IntegerString[FileHash[inputSource,"SHA256"],16,64]=!=
  "ea8ce663c1583a1ff42005fd309f2961ede4a22303826c778a85ad32abeb1733",Quit[1]];
inputText=Import[inputSource,"Text"];inputBoundary="\ntraceRows=Table[";
If[StringCount[inputText,inputBoundary]=!=1||!SyntaxQ[Import[studySource,"Text"]],Quit[1]];
inputPrefix=First[StringSplit[inputText,inputBoundary]];
If[!SyntaxQ[inputPrefix],Quit[1]];ToExpression[inputPrefix,InputForm];
packetRelative=channel<>"/s05_trace_input_result/s05_result.wl";
packetPath=FileNameJoin[{root,packetRelative}];packet=Get[packetPath];
packetReceipt=Import[FileNameJoin[{DirectoryName[packetPath],"s05_execution.json"}],"RawJSON"];
gate["accepted exact own trace equations",channel==="Hgg"&&TrueQ[packetReceipt["passed"]]&&
  packet["Schema"]==="polarized-sidis-native-trace-inputs-v1"&&packet["Channel"]===channel&&
  packetReceipt["job_id"]==="14815515"&&packetReceipt["result_sha256"][packetRelative]===
    IntegerString[FileHash[packetPath,"SHA256"],16,64]&&
  packet["InputHash"]===inputHash&&packet["InputHashes"]===inputHashes&&
  packet["SourceHash"]===FileHash[inputSource,"SHA256"]&&
  packet["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"]&&
  packet["ScalarRestore"]===scalarRestore&&packet["SpinVariables"]==={outVariables,inVariables}&&
  packet["NativeVersions"]==={$Version,$FeynCalcVersion}&&And@@Values[packet["Checks"]]];
parentRelative="Hqg/s05_precontracted_trace_result/s05_result.wl";
parentPath=FileNameJoin[{root,parentRelative}];parent=Get[parentPath];
parentReceipt=Import[FileNameJoin[{DirectoryName[parentPath],"s05_execution.json"}],"RawJSON"];
gate["accepted contraction before trace routine",TrueQ[parentReceipt["passed"]]&&
  parentReceipt["job_id"]==="14814379"&&parentReceipt["result_sha256"][parentRelative]===
    IntegerString[FileHash[parentPath,"SHA256"],16,64]&&
  parent["Schema"]==="polarized-sidis-precontracted-trace-comparison-v1"&&
  parent["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_precontracted_traces.wls"}],"SHA256"]&&
  parent["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"]&&
  parent["NativeVersions"]==={$Version,$FeynCalcVersion}&&And@@Values[parent["Checks"]]];
Do[gate["shared contraction convention "<>relative,parent["InputHashes"][relative]===inputHashes[relative]],
  {relative,{"common/s02_result/s02_result.wl","common/s04_result/s04_result.wl"}}];
DownValues[precontractedTrace]=parent["TraceDefinitions"];
gate["exact accepted trace routine installed",DownValues[precontractedTrace]===parent["TraceDefinitions"]];
ownPath=FileNameJoin[{root,channel,"s05_zero_angular_result","s05_result.wl"}];own=Get[ownPath];
earlyPath=FileNameJoin[{root,channel,"s05_scalar_power_result","s05_result.wl"}];early=Get[earlyPath];
ownReceipt=Import[FileNameJoin[{DirectoryName[ownPath],"s05_execution.json"}],"RawJSON"];
earlyReceipt=Import[FileNameJoin[{DirectoryName[earlyPath],"s05_execution.json"}],"RawJSON"];
gate["accepted own scalar methods",TrueQ[ownReceipt["passed"]]&&TrueQ[earlyReceipt["passed"]]&&
  ownReceipt["result_sha256"][channel<>"/s05_zero_angular_result/s05_result.wl"]===
    IntegerString[FileHash[ownPath,"SHA256"],16,64]&&
  earlyReceipt["result_sha256"][channel<>"/s05_scalar_power_result/s05_result.wl"]===
    IntegerString[FileHash[earlyPath,"SHA256"],16,64]&&
  own["Schema"]==="polarized-sidis-own-angular-zero-comparison-v1"&&own["Channel"]===channel&&
  early["Schema"]==="polarized-sidis-scalar-power-comparison-v1"&&early["Channel"]===channel&&
  own["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_Hgg_zero_angular.wls"}],"SHA256"]&&
  early["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_scalar_power_reduction.wls"}],"SHA256"]&&
  own["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"]&&
  early["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"]&&
  own["InputHash"]===inputHash&&own["InputHashes"]===inputHashes&&
  early["InputHash"]===inputHash&&early["InputHashes"]===inputHashes&&
  own["NativeVersions"]==={$Version,$FeynCalcVersion}&&early["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  And@@Values[own["Checks"]]&&And@@Values[early["Checks"]]&&
  early["ParentHash"]===FileHash[ownPath,"SHA256"]&&
  early["OriginalDefinitions"]===DownValues[algebraicReduceOne]&&
  own["OriginalReductionDefinitions"]==={DownValues[algebraicReduce],DownValues[algebraicReduceOne],
    DownValues[angularAverage],DownValues[angularAverageOne]}&&
  DownValues[restoredScalarComponent]===
    (own["OriginalCheckpointDefinitions"]/.checkpointedScalarComponent->restoredScalarComponent)];
DownValues[exactAngularZero]=own["ZeroAngularDefinitions"];
guardedDefinitions=own["GuardedCheckpointDefinitions"]/.zeroCheckpointedScalarComponent->restoredScalarComponent;
gate["one accepted nonzero scalar reduction",Count[guardedDefinitions,algebraicReduce,Infinity,Heads->True]===1];
DownValues[earlyPowerReduce]=early["CandidateDefinitions"];
DownValues[restoredScalarComponent]=guardedDefinitions/.algebraicReduce->earlyPowerReduce;
gate["complete production scalar method retained",
  (DownValues[restoredScalarComponent]/.earlyPowerReduce->algebraicReduce)===guardedDefinitions];
originalAngularDefinitions=DownValues[angularAverageOne];
originalComponentScalarDefinitions={DownValues[reduceScalar],DownValues[restoredScalarComponent],
  DownValues[algebraicReduce],DownValues[algebraicReduceOne],DownValues[angularAverage],
  DownValues[angularAverageOne],DownValues[exactAngularZero],DownValues[earlyPowerReduce]};
angularNormalFormEvidence=<||>;
certifiedAngularReduce[value_] := Module[
  {expanded,terms,powers,coefficients,distinct,divisions,monomials,binding},
  If[!PolynomialQ[value,transverseK],Return[algebraicReduce[value]]];
  expanded=Expand[value,transverseK];
  gate["angular selective expansion reconstructs",Expand[value-expanded,transverseK]===0];
  terms=If[Head[expanded]===Plus,List@@expanded,{expanded}];
  powers=If[#===0,0,Exponent[#,transverseK]]&/@terms;
  gate["angular transverse powers nonnegative integral",AllTrue[powers,IntegerQ[#]&&#>=0&]];
  coefficients=terms/.transverseK->1;monomials=transverseK^#&/@powers;
  gate["angular complete polynomial reconstructed",
    FreeQ[coefficients,transverseK]&&MapThread[Times,{coefficients,monomials}]===terms];
  distinct=DeleteDuplicates[powers];
  divisions=PolynomialReduce[transverseK^#,{transverseConstraint},{transverseK}]&/@distinct;
  gate["angular native monomial divisions reconstruct",And@@MapThread[
    zero[transverseK^#1-First[#2].{transverseConstraint}-Last[#2]]&,{distinct,divisions}]];
  If[!And@@MapThread[And@@(#===0&/@First[#2])&&Last[#2]===transverseK^#1&,{distinct,divisions}],
    Return[algebraicReduce[value]]];
  binding=Hash[{inputHash,value,transverseConstraint},"SHA256"];
  AssociateTo[angularNormalFormEvidence,binding-><|"InputBytes"->ByteCount[value],
    "Powers"->distinct,"Divisions"->divisions,"ExactInputReconstruction"->True,
    "ZeroQuotients"->True,"UnchangedRemainders"->True|>];
  Print["CERTIFIED_ANGULAR_NORMAL_FORM ",InputForm[KeyTake[angularNormalFormEvidence[binding],{"InputBytes","Powers"}]]];
  value];
gate["two original angular scalar reductions",Count[originalAngularDefinitions,algebraicReduce,Infinity,Heads->True]===2];
DownValues[angularAverageOne]=originalAngularDefinitions/.algebraicReduce->certifiedAngularReduce;
gate["all other angular equations preserved",
  (DownValues[angularAverageOne]/.certifiedAngularReduce->algebraicReduce)===originalAngularDefinitions];
{angularControlSeconds,angularControlValue}=AbsoluteTiming[
  bounded[angularAverage[early["CandidateValue"]],"own accepted complete angular control"]];
gate["own complete accepted scalar angular result reproduced",
  bounded[zero[angularControlValue-early["CandidateAverage"]],"exact own angular result comparison"]];
angularEquationRelative=channel<>"/s05_angular_equation_result/s05_result.wl";
angularEquationPath=FileNameJoin[{root,angularEquationRelative}];
angularEquation=Get[angularEquationPath];
angularEquationReceipt=Import[FileNameJoin[{DirectoryName[angularEquationPath],"s05_execution.json"}],"RawJSON"];
gate["exact readable native angular equation",TrueQ[angularEquationReceipt["passed"]]&&
  angularEquationReceipt["job_id"]==="14816264"&&
  angularEquationReceipt["result_sha256"][angularEquationRelative]===
    IntegerString[FileHash[angularEquationPath,"SHA256"],16,64]&&
  angularEquation["Record"]["InputHash"]===inputHash&&
  angularEquation["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  angularEquation["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_export_native_equation.wls"}],"SHA256"]&&
  angularEquation["CheckpointHash"]===FileHash[FileNameJoin[{root,angularEquation["Checkpoint"]}],"SHA256"]];
Print["SAVED_ANGULAR_EQUATION_BEGIN"];
{savedAngularSeconds,savedAngularValue}=AbsoluteTiming[
  bounded[angularAverage[angularEquation["Record"]["Value"]],"saved complete angular equation"]];
gate["saved angular result fully evaluated",FreeQ[savedAngularValue,normalDot|_Pair|_Eps|_DiracTrace|$Failed|$Aborted]];
Print["SAVED_ANGULAR_EQUATION_COMPLETE seconds ",savedAngularSeconds," bytes ",ByteCount[savedAngularValue]];

scalarDefinitions={DownValues[reduceScalar],DownValues[restoredScalarComponent],
  DownValues[algebraicReduce],DownValues[algebraicReduceOne],DownValues[angularAverage],
  DownValues[angularAverageOne],DownValues[exactAngularZero],DownValues[earlyPowerReduce]};
componentResolvedScalar[expression_] := Module[
  {variables,monomials,raw,originalHash,rows,record,key,path,saved,traced,value,seconds,answer},
  variables=DeleteCases[Join[inVariables,outVariables],1];
  gate["spin variables occur outside native traces",
    FreeQ[Cases[expression,_DiracTrace,{0,Infinity}],Alternatives@@variables]];
  raw=Flatten[First[compactSpinResponse[{expression},inVariables,outVariables]]];
  monomials=Flatten[Outer[Times,outVariables,inVariables]];
  gate["complete original spin input reconstructed",Length[raw]===Length[monomials]&&
    FreeQ[raw,Alternatives@@variables]&&Expand[expression-Total[MapThread[Times,{raw,monomials}]]]===0];
  originalHash=Hash[expression,"SHA256"];
  rows=Table[
    key=Hash[{inputHash,componentAlgorithmHash,originalHash,n,raw[[n]]},"SHA256"];
    path=FileNameJoin[{componentDirectory,IntegerString[key,16,64]<>".wl"}];
    saved=If[FileExistsQ[path],Get[path],<||>];
    If[Lookup[saved,"Binding",None]===key&&TrueQ[Lookup[saved,"Accepted",False]]&&
       AssociationQ[Lookup[saved,"Checks",None]]&&And@@Values[saved["Checks"]],
      Print["REUSED_SPIN_COMPONENT ",n];saved,
      Print["SPIN_COMPONENT_BEGIN ",n," of ",Length[raw]," input_bytes ",ByteCount[raw[[n]]]];
      {seconds,record}=AbsoluteTiming[
        traced=bounded[precontractedTrace[raw[[n]]],{"component trace",n}];
        gate["no spin variables remain after trace",FreeQ[traced["Value"],Alternatives@@variables]];
        value=bounded[reduceScalar[traced["Value"]],{"component scalar reduction",n}];
        gate["complete scalar spin component",FreeQ[value,Alternatives@@variables]&&
          FreeQ[value,_Pair|_Eps|_Spinor|_DiracGamma|_DiracTrace|_LorentzIndex|
            _Polarization|_SUNTF|_SUNTrace|_SUNF|_SUNDelta|_SUNFDelta|
            _FeynAmpDenominator|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
        <|"Value"->value,"TraceEvidence"->KeyDrop[traced,"Value"]|>];
      saved=Join[record,<|"Binding"->key,"InputHash"->inputHash,"AlgorithmHash"->componentAlgorithmHash,
        "Component"->n,"Seconds"->seconds,"Checks"->checks,"Accepted"->True|>];
      put[saved,path];gate["exact component checkpoint reload",Get[path]===saved];
      Clear[traced,value,record];ClearSystemCache[];
      Print["SPIN_COMPONENT_COMPLETE ",n," seconds ",seconds];saved],
    {n,Length[raw]}];
  answer=Total[MapThread[Times,{Lookup[rows,"Value"],monomials}]];
  <|"Value"->answer,"ExpressionHash"->originalHash,"InputBytes"->ByteCount[expression],
    "ComponentInputBytes"->(ByteCount/@raw),"Components"->(KeyDrop[#,{"Value","Checks"}]&/@rows),
    "ExactInputReconstruction"->True,"OutputBytes"->ByteCount[answer]|>];
componentAlgorithmHash=Hash[{DownValues[componentResolvedScalar],DownValues[precontractedTrace],
  scalarDefinitions,DownValues[certifiedAngularReduce],transverseConstraint,$Version,$FeynCalcVersion},"SHA256"];
componentDirectory=FileNameJoin[{root,"cache","s05_spin_components",channel,IntegerString[inputHash,16],
  IntegerString[componentAlgorithmHash,16]}];
If[!DirectoryQ[componentDirectory],CreateDirectory[componentDirectory,CreateIntermediateDirectories->True]];
previousComponentAlgorithmHash=Hash[{DownValues[componentResolvedScalar],DownValues[precontractedTrace],
  originalComponentScalarDefinitions,transverseConstraint,$Version,$FeynCalcVersion},"SHA256"];
previousCoefficientDirectory=FileNameJoin[{root,"cache","s05_spin_components",channel,IntegerString[inputHash,16],
  IntegerString[previousComponentAlgorithmHash,16],"scalar"}];
gate["same unchanged pre-average scalar cache",
  Most[FileNameSplit[FileNameJoin[{root,angularEquation["Checkpoint"]}]]]===FileNameSplit[previousCoefficientDirectory]];
coefficientDirectory=FileNameJoin[{componentDirectory,"scalar"}];
If[!DirectoryQ[coefficientDirectory],CreateDirectory[coefficientDirectory]];
reusedScalarCheckpointHashes=<||>;
Do[scalarRecord=Get[previousScalarPath];
  gate["completed own pre-average scalar identity",scalarRecord["InputHash"]===inputHash&&
    FileBaseName[previousScalarPath]===IntegerString[scalarRecord["ArgumentHash"],16,64]&&
    KeyExistsQ[scalarRecord,"Value"]];
  scalarDestination=FileNameJoin[{coefficientDirectory,FileNameTake[previousScalarPath]}];
  If[!FileExistsQ[scalarDestination],CopyFile[previousScalarPath,scalarDestination]];
  gate["exact independent scalar checkpoint copy",FileHash[scalarDestination,"SHA256"]===FileHash[previousScalarPath,"SHA256"]];
  AssociateTo[reusedScalarCheckpointHashes,StringDrop[previousScalarPath,StringLength[root]+1]->FileHash[previousScalarPath,"SHA256"]],
  {previousScalarPath,FileNames["*.wl",previousCoefficientDirectory]}];
Clear[scalarRecord];
controlPath=FileNameJoin[{root,"cache","s05_sector_ward",channel,
  "d1394d7246f4688fcd675a6f772afc08a0cb265b82e0acbda7ccf061c16831c0","Real_1_1.wl"}];
gate["pinned accepted own complete pair",IntegerString[FileHash[controlPath,"SHA256"],16,64]===
  "e2c22f5dd25724e3c96e85334141b75dcb7e86baa58db10d7e2213313def78dd"];
control=Get[controlPath];
gate["accepted own pair physical input",control["InputHash"]===inputHash&&And@@Values[control["Checks"]]];
controlRow=First[packet["Rows"]];
gate["own control is the first generated pair",controlRow["Pair"]===First[pairs]&&
  Hash[controlRow["Expression"],"SHA256"]===controlRow["ExpressionHash"]];
controlExpected=Extract[control["PhotonMatrix"],controlRow["PhotonIndices"]];Clear[control];ClearSystemCache[];
controlValue=componentResolvedScalar[controlRow["Expression"]];
controlMonomials=Flatten[Outer[Times,outVariables,inVariables]];
controlExpectedCoefficients=Flatten[First[compactSpinResponse[{controlExpected},inVariables,outVariables]]];
controlActualCoefficients=Flatten[First[compactSpinResponse[{controlValue["Value"]},inVariables,outVariables]]];
gate["complete accepted output decomposed exactly",
  Expand[controlExpected-Total[MapThread[Times,{controlExpectedCoefficients,controlMonomials}]]]===0];
gate["complete candidate output decomposed exactly",
  Expand[controlValue["Value"]-Total[MapThread[Times,{controlActualCoefficients,controlMonomials}]]]===0];
Do[gate["own accepted complete spin coefficient "<>ToString[n],
  bounded[algebraicReduce[controlActualCoefficients[[n]]-controlExpectedCoefficients[[n]]],
    {"own output comparison",n}]===0],{n,Length[controlMonomials]}];
gate["entire accepted own projection reproduced",Length[controlActualCoefficients]===Length[controlExpectedCoefficients]];
studyRows={Join[KeyTake[controlRow,{"Pair","PhotonIndices","ExpressionHash"}],
  controlValue,<|"OwnAcceptedProjectionCompared"->True|>]};
Clear[controlExpected,controlExpectedCoefficients,controlActualCoefficients,controlValue];ClearSystemCache[];
Do[
  gate["exact saved target equation",Hash[row["Expression"],"SHA256"]===row["ExpressionHash"]];
  Print["SPIN_COMPONENT_TARGET ",InputForm[row["Pair"]]," ",InputForm[row["PhotonIndices"]]];
  answer=componentResolvedScalar[row["Expression"]];
  AppendTo[studyRows,Join[KeyTake[row,{"Pair","PhotonIndices","ExpressionHash"}],answer,
    <|"OwnAcceptedProjectionCompared"->False|>]],{row,Rest[packet["Rows"]]}];
gate["unchanged complete scalar and angular definitions",scalarDefinitions===
  {DownValues[reduceScalar],DownValues[restoredScalarComponent],DownValues[algebraicReduce],
    DownValues[algebraicReduceOne],DownValues[angularAverage],DownValues[angularAverageOne],
    DownValues[exactAngularZero],DownValues[earlyPowerReduce]}];
studyResult=<|"Schema"->"polarized-sidis-spin-component-projection-comparison-v1","Channel"->channel,
  "SourceHash"->FileHash[studySource,"SHA256"],"ProductionSourceHash"->FileHash[sourcePath,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,$FeynCalcVersion},
  "InputPacketHash"->FileHash[packetPath,"SHA256"],"ParentTraceProofHash"->FileHash[parentPath,"SHA256"],
  "OwnAngularProofHash"->FileHash[ownPath,"SHA256"],"OwnEarlyPowerProofHash"->FileHash[earlyPath,"SHA256"],
  "ControlHash"->FileHash[controlPath,"SHA256"],"Rows"->studyRows,
  "CandidateDefinitions"->DownValues[componentResolvedScalar],"TraceDefinitions"->DownValues[precontractedTrace],
  "ScalarDefinitions"->scalarDefinitions,"AlgorithmHash"->componentAlgorithmHash,
  "OriginalAngularDefinitions"->originalAngularDefinitions,"AngularDefinitions"->DownValues[angularAverageOne],
  "AngularNormalFormDefinitions"->DownValues[certifiedAngularReduce],"AngularNormalFormEvidence"->angularNormalFormEvidence,
  "OwnAngularControlSeconds"->angularControlSeconds,"ReadableAngularEquationHash"->FileHash[angularEquationPath,"SHA256"],
  "SavedAngularSeconds"->savedAngularSeconds,"SavedAngularValue"->savedAngularValue,
  "PreviousComponentAlgorithmHash"->previousComponentAlgorithmHash,
  "ReusedScalarCheckpointHashes"->reusedScalarCheckpointHashes,
  "Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
studyDirectory=FileNameJoin[{root,channel,"s05_components_angular_result"}];
If[!DirectoryQ[studyDirectory],CreateDirectory[studyDirectory,CreateIntermediateDirectories->True]];
studyPath=FileNameJoin[{studyDirectory,"s05_result.wl"}];
serialized="Uncompress["<>ToString[bounded[Compress[studyResult],"component proof compression"],InputForm]<>"]\n";
gate["bounded component comparison output",StringLength[serialized]<128*1024^2];
Export[studyPath<>".tmp",serialized,"Text"];
gate["exact component comparison reload",Get[studyPath<>".tmp"]===studyResult];
RenameFile[studyPath<>".tmp",studyPath,OverwriteTarget->True];
Export[FileNameJoin[{studyDirectory,"s05_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "accepted"->True,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s05_check_Hgg_components_angular"];Quit[0];

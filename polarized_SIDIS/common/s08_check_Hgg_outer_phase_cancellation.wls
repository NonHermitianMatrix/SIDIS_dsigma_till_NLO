(* Compare early exact numeric-phase cancellation against completed Hgg maps. *)
$HistoryLength=0;
phaseCheckSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_outer_phase_cancellation.wls"}];
phaseCheckBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_partitioned.wls"}];
If[!SyntaxQ[Import[phaseCheckSource,"Text"]]||IntegerString[FileHash[phaseCheckBase,"SHA256"],16,64]=!=
 "cdf9518ee3ac9a54ca865cfb867f3b28a9bacf91589e439957c72165219a388e",Quit[1]];
phaseCheckText=StringTrim[Import[phaseCheckBase,"Text"]];
phaseCheckTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[phaseCheckText,phaseCheckTerminal],Quit[1]];
phaseCheckPrefix=StringDrop[phaseCheckText,-StringLength[phaseCheckTerminal]];
If[!SyntaxQ[phaseCheckPrefix],Quit[1]];ToExpression[phaseCheckPrefix,InputForm];

phasePrepare[expression_]:=Module[{outer,splits,terms,factors,flat,candidate,atoms,scalars,left,right,rules},
 outer=If[Head[expression]===Plus,List@@expression,{expression}];
 splits=numericOuterFactor/@outer;
 If[!AnyTrue[splits,First[#]=!=1&],
  Return[<|"Value"->expression,"Flattened"->False,"ExactReconstruction"->True|>]];
 factors=First/@splits;
 terms=Map[If[Head[Last[#]]===Plus,List@@Last[#],{Last[#]}]&,splits];
 gate["phase factors reconstruct every actual outer term",
  And@@MapThread[(First[#1] Last[#1]===#2)&,{splits,outer}]&&Total[outer]===expression];
 gate["phase core lists reconstruct every actual core",
  And@@MapThread[(Total[#1]===Last[#2])&,{terms,splits}]];
 atoms=Map[Function[list,Table[Unique["phaseAtom$"],{Length[list]}]],terms];
 scalars=Table[Unique["phaseScalar$"],{Length[factors]}];
 left=Total[MapThread[Times,{scalars,Total/@atoms}]];
 right=Total[Flatten[MapThread[Function[{c,list},Map[c #&,list]],{scalars,atoms}],1]];
 gate["native full scalar distributivity identity",Expand[left-right]===0];
 flat=Flatten[MapThread[Function[{c,list},Map[c #&,list]],{factors,terms}],1];
 candidate=Total[flat];
 rules=Thread[Join[scalars,Flatten[atoms]]->Join[factors,Flatten[terms]]];
 gate["scalar identity specializes to entire original input",(left/.rules)===expression];
 gate["scalar identity specializes to entire prepared input",(right/.rules)===candidate];
 <|"Value"->candidate,"Flattened"->True,"ExactReconstruction"->True,
   "OuterFactors"->factors,"CoreTermCounts"->(Length/@terms)|>];
phaseBoundedPrepare[expression_]:=TimeConstrained[
 MemoryConstrained[phasePrepare[expression],2*1024^3,Missing["PreparationMemoryLimit"]],
 120,Missing["PreparationTimeLimit"]];
phaseEarlyMap[expression_,key_]:=Module[{prepared=phaseBoundedPrepare[expression]},
 If[AssociationQ[prepared]&&TrueQ[prepared["ExactReconstruction"]]&&prepared["Value"]===0,
  externalOriginalMap[prepared["Value"]],phaseOriginalMap[expression,key]]];

phaseComparison[]:=Module[{original,alias,ownPath,ownRecord,ownProof,ownSeconds,ownRows,
 measurements,directory,result,accepted,ownIdentity,definitionsBefore},
 CloseKernels[];
 original=DownValues[numericPhaseMap];alias=original/.numericPhaseMap->phaseOriginalMap;
 gate["complete original numeric-phase fallback preserved",
  Length[original]>0&&(alias/.phaseOriginalMap->numericPhaseMap)===original];
 DownValues[phaseOriginalMap]=alias;
 definitionsBefore={DownValues[numericPhaseMap],DownValues[mapExpression],DownValues[familyRows],
  DownValues[groupedMapExpression],DownValues[polynomialPieceMap],DownValues[merge]};
 ownPath=FileNameJoin[{root,channel,"s08_mapping_inputs_result",
  "s08_component_"<>IntegerString[hggOwnIndex,10,4]<>".wl"}];
 ownRecord=Get[ownPath];
 ownProof=Get[FileNameJoin[{root,channel,"s08_termwise_comparison_result","s08_result.wl"}]];
 gate["same accepted nonzero own cancellation control",
  ownRecord["InputHashes"]===inputHashes&&ownRecord["TargetInputHash"]===targetInputHash&&
  ownProof["InputHash"]===targetInputHash&&TrueQ[ownProof["OwnAcceptedComparison"]]&&
  And@@Values[ownProof["Checks"]]&&Length[ownProof["Coefficients"]]>0&&
  ownProof["NativeInputHash"]===FileHash[ownPath,"SHA256"]];
 {ownSeconds,ownRows}=AbsoluteTiming[Block[{numericPhaseCache=groupCache<>"_numeric_phase"},
  bounded[phaseEarlyMap[ownRecord["Expression"],"component_"<>ToString[hggOwnIndex]],"own early-phase map"]]];
 ownIdentity=partitionSameCoefficients[ownRows,ownProof["Coefficients"]];
 gate["complete accepted nonzero own coefficients unchanged",ownIdentity];
 Clear[ownRows,ownRecord,ownProof];ClearSystemCache[];
 measurements=Table[Module[{path,saved,task,value,loadSeconds,prepareSeconds,prepared,
   shortcut,rows,mapSeconds=0,comparison=False,totalSeconds,summary},
  path=FileNameJoin[{targetCache,"component_"<>IntegerString[index,10,4]<>".wl"}];
  saved=Get[path];task=tasks[[index]];
  gate["completed actual zero-map identity "<>ToString[index],
   saved["InputHash"]===targetInputHash&&TrueQ[saved["ReconstructionPassed"]]&&
   And@@Values[saved["Checks"]]&&KeyTake[saved,{"Sector","Kind","Index"}]===KeyDrop[task,"Value"]&&
   AssociationQ[saved["Coefficients"]]&&Length[saved["Coefficients"]]===0];
  {loadSeconds,value}=AbsoluteTiming[With[{loaded=task["Value"]},
    bounded[loaded/.coordinateRules,{"actual phase input",index}]]];
  Print["OUTER_PHASE_ACTUAL_INPUT ",index," bytes ",ByteCount[value]];
  {prepareSeconds,prepared}=AbsoluteTiming[phaseBoundedPrepare[value]];
  shortcut=AssociationQ[prepared]&&TrueQ[prepared["ExactReconstruction"]]&&prepared["Value"]===0;
  If[shortcut,
   {mapSeconds,rows}=AbsoluteTiming[externalOriginalMap[prepared["Value"]]];
   comparison=partitionSameCoefficients[rows,saved["Coefficients"]];
   gate["entire completed actual map reproduced "<>ToString[index],comparison];
   gate["early zero map reconstructs prepared actual input "<>ToString[index],
    zero[pairReconstruct[rows]-prepared["Value"]]]];
  totalSeconds=Total[{loadSeconds,prepareSeconds,mapSeconds}];
  summary=If[AssociationQ[prepared],KeyDrop[prepared,"Value"],<|"PreparationBound"->ToString[prepared,InputForm]|>];
  Print["OUTER_PHASE_ACTUAL_RESULT ",index," ",InputForm[summary]," shortcut ",shortcut,
   " seconds ",totalSeconds," original_seconds ",saved["Seconds"]];
  <|"Component"->index,"Task"->KeyDrop[task,"Value"],"AcceptedMapHash"->FileHash[path,"SHA256"],
    "ActualInputHash"->Hash[value,"SHA256"],"InputBytes"->ByteCount[value],
    "Preparation"->summary,"ExactZero"->shortcut,"OwnAcceptedComparison"->comparison,
    "LoadSeconds"->loadSeconds,"PreparationSeconds"->prepareSeconds,"MapSeconds"->mapSeconds,
    "CandidateSeconds"->totalSeconds,"OriginalSeconds"->saved["Seconds"],
    "SpeedupObserved"->(shortcut&&comparison&&totalSeconds<saved["Seconds"])|>],{index,{43,44}}];
 gate["all original mapping equations and interfaces unchanged",definitionsBefore===
  {DownValues[numericPhaseMap],DownValues[mapExpression],DownValues[familyRows],
   DownValues[groupedMapExpression],DownValues[polynomialPieceMap],DownValues[merge]}];
 accepted=ownIdentity&&And@@Lookup[measurements,"OwnAcceptedComparison"]&&
  And@@Lookup[measurements,"SpeedupObserved"];
 result=<|"Schema"->"polarized-sidis-outer-phase-cancellation-v1","Channel"->channel,
  "SourceHash"->FileHash[phaseCheckSource,"SHA256"],"BaseHash"->FileHash[phaseCheckBase,"SHA256"],
  "InputHashes"->inputHashes,"TargetInputHash"->targetInputHash,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Accepted"->accepted,
  "OwnAcceptedComparison"->ownIdentity,"OwnSeconds"->ownSeconds,"Measurements"->measurements,
  "OriginalPhaseDefinitions"->original,"OriginalAliasDefinitions"->DownValues[phaseOriginalMap],
  "PreparationDefinitions"->DownValues[phasePrepare],"BoundedPreparationDefinitions"->DownValues[phaseBoundedPrepare],
  "CandidateDefinitions"->DownValues[phaseEarlyMap],"OriginalAlgebraDefinitions"->definitionsBefore,
  "ZeroMappingDefinitions"->DownValues[externalOriginalMap],
  "Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
 directory=FileNameJoin[{root,channel,"s08_outer_phase_cancellation_trimmed_result"}];
 If[!DirectoryQ[directory],CreateDirectory[directory]];
 saveNative[result,FileNameJoin[{directory,"s08_result.wl"}]];
 Export[FileNameJoin[{directory,"s08_checks.json"}],<|"checks"->checks,"accepted"->accepted,
  "own_seconds"->ownSeconds,"measurements"->Map[Join[KeyDrop[#,"Preparation"],
    <|"preparation_input_form"->ToString[#["Preparation"],InputForm]|>]&,measurements],
  "job_id"->Environment["JOB_ID"]|>,"RawJSON"];
 Print["PASS: s08_Hgg_outer_phase_comparison"];Quit[0]];

(* Use the accepted bootstrap and private control owner; stop before production dispatch. *)
If[partitionCheckOnly,Quit[1]];
partitionOwner="s08_outer_phase_cancellation_trimmed";
partitionRun=StringReplace[externalConsumerRun,"\"s08_other_group_control_result\""->
 ToString[partitionOwner<>"_control_result",InputForm]];
If[!SyntaxQ[partitionRun]||StringReplace[partitionRun,
 ToString[partitionOwner<>"_control_result",InputForm]->"\"s08_other_group_control_result\""]=!=externalConsumerRun,Quit[1]];
Clear[partitionDispatch];partitionDispatch[]:=phaseComparison[];
ToExpression[partitionRun,InputForm];

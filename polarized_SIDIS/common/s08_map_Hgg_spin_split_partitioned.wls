(* Install only an accepted, measured metric spin-polynomial split. *)
$HistoryLength=0;
metricSpinSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_spin_split_partitioned.wls"}];
metricSpinBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_metric_partitioned.wls"}];
If[!SyntaxQ[ReadString[metricSpinSource]]||IntegerString[FileHash[metricSpinBase,"SHA256"],16,64]=!=
 "177ae0baf676d0c9751e67c432e230d7ec911d1c60d01cebe35bebc6499e97a0",Quit[1]];
metricSpinText=StringTrim[ReadString[metricSpinBase]];metricSpinTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[metricSpinText,metricSpinTerminal],Quit[1]];
metricSpinPrefix=StringDrop[metricSpinText,-StringLength[metricSpinTerminal]];
If[!SyntaxQ[metricSpinPrefix],Quit[1]];ToExpression[metricSpinPrefix,InputForm];

metricSpinInstall[]:=Module[{relative,path,receipt,producer,proof,fixed,metadata,variables,original,
 own,control,expected,seconds},
 relative="Hgg/s08_metric_spin_split_exact_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_Hgg_metric_spin_split.wls"}];
 gate["accepted complete metric spin-split execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_Hgg_metric_spin_split.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];fixed={DownValues[mapExpression],DownValues[merge],DownValues[familyRows],
  DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]};
 gate["same accepted complete metric spin mapping contract",proof["Schema"]==="polarized-sidis-metric-spin-polynomial-v1"&&
  proof["Channel"]===channel&&proof["SourceHash"]===FileHash[producer,"SHA256"]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["FixedDefinitions"]===fixed&&
  TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["SpeedupObserved"]]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&And@@Flatten[Values/@proof["PieceChecks"]]&&
  FileHash[FileNameJoin[{root,proof["AcceptedGroupFile"]}],"SHA256"]===proof["AcceptedGroupHash"]];
 metadata=Get[FileNameJoin[{root,"Hgg","s05_result","s05_metadata.wl"}]];
 variables=DeleteDuplicates[DeleteCases[Join[metadata["ComponentStorage"]["IncomingVariables"],
  metadata["ComponentStorage"]["OutgoingVariables"]],1]];
 gate["exact recorded metric spin variables",variables===proof["SpinVariables"]];
 spinSplitVariables=variables;
 DownValues[spinPolynomialPieces]=proof["PieceDefinitions"];
 DownValues[spinPolynomialMap]=proof["MappingDefinitions"];
 original=DownValues[polynomialPieceMap];
 DownValues[metricSpinOriginalPieceMap]=original/.polynomialPieceMap->metricSpinOriginalPieceMap;
 gate["complete original spin-independent piece mapper retained",
  (DownValues[metricSpinOriginalPieceMap]/.metricSpinOriginalPieceMap->polynomialPieceMap)===original];
 polynomialPieceMap[expression_]:=If[FreeQ[expression,Alternatives@@spinSplitVariables],
  metricSpinOriginalPieceMap[expression],spinPolynomialMap[expression]["Coefficients"]];
 own=Get[FileNameJoin[{root,"Hgg","s08_shared_piece_cache_result","s08_result.wl"}]];
 gate["accepted original own group for spin interface",TrueQ[own["OwnAcceptedComparison"]]&&And@@Values[own["Checks"]]&&
  own["InputHashes"]===inputHashes&&own["TargetInputHash"]===targetInputHash&&
  FreeQ[own["ActualInput"]["Equation"],Alternatives@@spinSplitVariables]];
 expected=Map[First[variables] #&,own["FreshCoefficients"]];
 {seconds,control}=AbsoluteTiming[bounded[polynomialPieceMap[First[variables] own["ActualInput"]["Equation"]],
  "production complete spin branch interface"]];
 gate["every spin interface coefficient equals its accepted original",partitionSameCoefficients[control,expected]];
 gate["remaining scalar family cut and merge definitions unchanged",fixed==={DownValues[mapExpression],DownValues[merge],
  DownValues[familyRows],DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]}];
 AssociateTo[hggPolynomialEvidence,"MetricSpinSplit"-><|"SourceHash"->FileHash[metricSpinSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"OriginalSeconds"->proof["OriginalSeconds"],"CandidateSeconds"->proof["CandidateSeconds"],
  "ProductionInterfaceSeconds"->seconds|>];
 Print["ACCEPTED_METRIC_SPIN_SPLIT_INSTALLED seconds ",seconds];ClearSystemCache[]];

metricSpinOriginalInstallDefinitions=DownValues[externalInstall];
DownValues[metricSpinOriginalInstall]=metricSpinOriginalInstallDefinitions/.externalInstall->metricSpinOriginalInstall;
If[(DownValues[metricSpinOriginalInstall]/.metricSpinOriginalInstall->externalInstall)=!=metricSpinOriginalInstallDefinitions,Quit[1]];
externalInstall[]:=(metricSpinOriginalInstall[];metricSpinInstall[]);
metricSpinOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[metricSpinOriginalTail]=metricSpinOriginalTailDefinitions/.coordinateTail->metricSpinOriginalTail;
If[(DownValues[metricSpinOriginalTail]/.metricSpinOriginalTail->coordinateTail)=!=metricSpinOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=metricSpinOriginalTail[text]},
 coordinateReplace[changed,"DistributeDefinitions[earlyAffineCancel,",
  "DistributeDefinitions[spinSplitVariables,spinPolynomialPieces,spinPolynomialMap,metricSpinOriginalPieceMap,earlyAffineCancel,"]];
ToExpression[partitionRun,InputForm];

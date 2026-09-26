(* Reuse the accepted early-Cancel operation in the existing Hgg partition pipeline. *)
$HistoryLength=0;
earlySource=FileNameJoin[{Directory[],"common","s08_map_Hgg_early_affine_partitioned.wls"}];
earlyBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_affine_partitioned.wls"}];
If[!SyntaxQ[ReadString[earlySource]]||IntegerString[FileHash[earlyBase,"SHA256"],16,64]=!=
 "20045e89edbfdc0a4f00c30e4559ccbcd76fb5bd33e3e53736e53692443edc3f",Quit[1]];
earlyText=StringTrim[ReadString[earlyBase]];earlyTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[earlyText,earlyTerminal],Quit[1]];
earlyPrefix=StringDrop[earlyText,-StringLength[earlyTerminal]];
If[!SyntaxQ[earlyPrefix],Quit[1]];ToExpression[earlyPrefix,InputForm];

earlyInstall[]:=Module[{relative,path,receipt,producer,proof,input,fixed,own,known,seconds},
 relative="Hgg/s08_affine_cancel_exact_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_Hgg_affine_cancel.wls"}];
 gate["accepted complete early-Cancel comparison",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_Hgg_affine_cancel.wls"]===IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];input=Get[FileNameJoin[{root,"Hgg","s08_failed_group_input_result","s08_result.wl"}]];
 fixed={DownValues[mapExpression],DownValues[merge],DownValues[familyRows],DownValues[certifyFamilyLaurent],
  DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]};
 gate["same complete early-Cancel scalar contract",proof["Schema"]==="polarized-sidis-early-affine-cancel-comparison-v1"&&
  proof["Channel"]===channel&&proof["SourceHash"]===FileHash[producer,"SHA256"]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[proof["OwnAcceptedComparison"]]&&TrueQ[proof["KnownAcceptedComparison"]]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
  And@@Flatten[Values/@Flatten[proof["PieceChecks"]]]&&
  proof["OriginalMappingDefinitions"]===DownValues[externalOriginalMap]&&proof["FixedDefinitions"]===fixed&&
  And@@KeyValueMap[FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2&,proof["ProofHashes"]]];
 gate["complete original mapper preserved by the accepted Cancel-only edit",
  (proof["CandidateMappingDefinitions"]/.earlyAffineCancel->Cancel)===DownValues[externalOriginalMap]];
 cancelEvidence={};DownValues[earlyAffineCancel]=proof["CancelDefinitions"];
 DownValues[externalOriginalMap]=proof["CandidateMappingDefinitions"];
 gate["exact accepted early-Cancel definitions installed",DownValues[earlyAffineCancel]===proof["CancelDefinitions"]&&
  DownValues[externalOriginalMap]===proof["CandidateMappingDefinitions"]];
 {seconds,{own,known}}=AbsoluteTiming[Block[{sharedReadPiece},sharedReadPiece[path_String,binding_Integer]:=<||>;
  {bounded[polynomialPieceMap[input["OwnAcceptedEquation"]],"early-Cancel production own interface"],
   bounded[polynomialPieceMap[input["Equation"]],"early-Cancel production accepted38 interface"]}]];
 gate["early-Cancel production interface preserves all own coefficients",partitionSameCoefficients[own,proof["OwnCoefficients"]]];
 gate["early-Cancel production interface preserves all accepted38 coefficients",partitionSameCoefficients[known,proof["KnownCoefficients"]]];
 gate["early-Cancel production output contains only original coordinates",FreeQ[{own,known},Alternatives@@basisCoordinates]];
 gate["all remaining production mapping and certificates unchanged",fixed===
  {DownValues[mapExpression],DownValues[merge],DownValues[familyRows],DownValues[certifyFamilyLaurent],
   DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]}];
 AssociateTo[hggPolynomialEvidence,"EarlyAffineCancel"-><|"SourceHash"->FileHash[earlySource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"KnownAcceptedComparison"->True,"ActualGroupSeconds"->proof["ActualSeconds"],
  "ProductionInterfaceSeconds"->seconds|>];
 Print["ACCEPTED_EARLY_AFFINE_CANCEL_INSTALLED seconds ",seconds];cancelEvidence={};ClearSystemCache[]];

earlyOriginalInstallDefinitions=DownValues[externalInstall];
DownValues[earlyOriginalInstall]=earlyOriginalInstallDefinitions/.externalInstall->earlyOriginalInstall;
If[(DownValues[earlyOriginalInstall]/.earlyOriginalInstall->externalInstall)=!=earlyOriginalInstallDefinitions,Quit[1]];
externalInstall[]:=(earlyOriginalInstall[];earlyInstall[]);
earlyOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[earlyOriginalTail]=earlyOriginalTailDefinitions/.coordinateTail->earlyOriginalTail;
If[(DownValues[earlyOriginalTail]/.earlyOriginalTail->coordinateTail)=!=earlyOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=earlyOriginalTail[text]},
 coordinateReplace[changed,"DistributeDefinitions[basisPrepareFamily,",
  "DistributeDefinitions[earlyAffineCancel,cancelEvidence,basisPrepareFamily,"]];
ToExpression[partitionRun,InputForm];

(* Reuse the accepted affine family map in the existing disjoint Hgg pipeline. *)
$HistoryLength=0;
affineSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_affine_partitioned.wls"}];
affineBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_partitioned.wls"}];
If[!SyntaxQ[ReadString[affineSource]]||IntegerString[FileHash[affineBase,"SHA256"],16,64]=!=
 "cdf9518ee3ac9a54ca865cfb867f3b28a9bacf91589e439957c72165219a388e",Quit[1]];
affineText=StringTrim[ReadString[affineBase]];affineTerminal="ToExpression[partitionRun,InputForm];";
If[!StringEndsQ[affineText,affineTerminal],Quit[1]];
affinePrefix=StringDrop[affineText,-StringLength[affineTerminal]];
If[!SyntaxQ[affinePrefix],Quit[1]];ToExpression[affinePrefix,InputForm];

affineInstall[]:=Module[{relative,path,receipt,producer,proof,input,originalPiece,text,begin,end,
 originalText,sharedEdits,currentText,candidateText,decision,own,actual,seconds},
 relative="Hgg/s08_affine_piece_basis_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 producer=FileNameJoin[{root,"common","s08_check_Hgg_affine_family_basis.wls"}];
 gate["accepted full affine failed-group execution",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]&&
  receipt["reviewed_sha256"]["common/s08_check_Hgg_affine_family_basis.wls"]===
   IntegerString[FileHash[producer,"SHA256"],16,64]];
 proof=Get[path];input=Get[FileNameJoin[{root,"Hgg","s08_failed_group_input_result","s08_result.wl"}]];
 gate["same complete accepted affine mapping contract",
  proof["Schema"]==="polarized-sidis-affine-family-basis-v1"&&proof["Channel"]===channel&&
  TrueQ[proof["Accepted"]]&&TrueQ[proof["OwnAcceptedComparison"]]&&
  Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
  proof["SourceHash"]===FileHash[producer,"SHA256"]&&
  proof["InputHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_failed_group_input_result","s08_result.wl"}],"SHA256"]&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["OriginalFamilyDefinitions"]===DownValues[familyRows]&&
  proof["FixedDefinitions"]==={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
   DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]}&&
  input["Families"]===families&&input["Denominators"]===denominators];
 basisVariables=proof["Variables"];basisForms=proof["Forms"];basisCoordinates=proof["Coordinates"];
 basisInverse=proof["Inverse"];basisForward=proof["Forward"];
 DownValues[basisPrepareFamily]=proof["PreparationDefinitions"];
 DownValues[basisPieceCertificate]=proof["PieceCertificateDefinitions"];
 originalPiece=DownValues[polynomialPieceMap];
 text=ReadString[FileNameJoin[{root,"common","s08_map_Hqg_polynomial_group.wls"}]];
 begin=StringPosition[text,"\npolynomialPieceMap[expression_]"];
 end=StringPosition[text,"\n{controlSeconds,controlCandidate}="];
 gate["unique complete production piece source",Length[begin]===1&&Length[end]===1];
 originalText=StringTake[text,{First[First[begin]],First[First[end]]-1}];
 sharedEdits={"saved=If[FileExistsQ[path],Get[path],<||>];"->"saved=sharedReadPiece[path,binding];",
  "And@@Values[saved[\"Checks\"]],Return[saved]];"->"And@@Values[saved[\"Checks\"]],Null,",
  "seconds];saved]]],pieces];"->"seconds]];saved]]],pieces];",
  "Expand[Total[pieces]-expression]===0"->"zero[Total[pieces]-expression]"};
 gate["unique accepted production piece interfaces",And@@(StringCount[originalText,First[#]]===1&/@sharedEdits)];
 currentText=StringReplace[originalText,sharedEdits];
 gate["entire inherited piece source restores exactly",SyntaxQ[currentText]&&
  StringReplace[currentText,Reverse/@sharedEdits]===originalText];
 ToExpression[currentText,InputForm];
 gate["complete live piece map reproduced",DownValues[polynomialPieceMap]===originalPiece];
 decision="zero[Total[pieces]-expression]";
 gate["one complete piece reconstruction decision",StringCount[currentText,decision]===1];
 candidateText=StringReplace[currentText,decision->"basisPieceCertificate[expression,pieces]"];
 gate["all remaining piece mapping and cache code unchanged",SyntaxQ[candidateText]&&
  StringReplace[candidateText,"basisPieceCertificate[expression,pieces]"->decision]===currentText];
 ToExpression[candidateText,InputForm];
 DownValues[familyRows]=proof["CandidateFamilyDefinitions"];
 gate["exact accepted family and certificate definitions installed",
  DownValues[familyRows]===proof["CandidateFamilyDefinitions"]&&
  DownValues[basisPrepareFamily]===proof["PreparationDefinitions"]&&
  DownValues[basisPieceCertificate]===proof["PieceCertificateDefinitions"]];
 {seconds,{own,actual}}=AbsoluteTiming[Block[{sharedReadPiece},sharedReadPiece[path_String,binding_Integer]:=<||>;
  {bounded[polynomialPieceMap[input["OwnAcceptedEquation"]],"affine production own interface"],
   bounded[polynomialPieceMap[input["Equation"]],"affine production actual failed-group interface"]}]];
 gate["production piece interface preserves own accepted coefficients",partitionSameCoefficients[own,proof["OwnCoefficients"]]];
 gate["production piece interface preserves entire actual failed-group coefficients",
  partitionSameCoefficients[actual,proof["ActualCoefficients"]]];
 gate["affine production output contains only original coordinates",
  FreeQ[{own,actual},Alternatives@@basisCoordinates]];
 gate["production global geometry and scalar certificates unchanged",input["Families"]===families&&
  proof["FixedDefinitions"]==={DownValues[mapExpression],DownValues[externalOriginalMap],DownValues[merge],
   DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms]}];
 AssociateTo[hggPolynomialEvidence,"AffineFamilyBasis"-><|"SourceHash"->FileHash[affineSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "Forms"->basisForms,"OwnAcceptedComparison"->True,"ActualAcceptedComparison"->True,
  "ProductionInterfaceSeconds"->seconds|>];
 Print["ACCEPTED_AFFINE_FAMILY_INSTALLED seconds ",seconds];ClearSystemCache[]];

affineOriginalInstallDefinitions=DownValues[externalInstall];
DownValues[affineOriginalInstall]=affineOriginalInstallDefinitions/.externalInstall->affineOriginalInstall;
If[(DownValues[affineOriginalInstall]/.affineOriginalInstall->externalInstall)=!=affineOriginalInstallDefinitions,Quit[1]];
externalInstall[]:=(affineOriginalInstall[];affineInstall[]);
affineOriginalTailDefinitions=DownValues[coordinateTail];
DownValues[affineOriginalTail]=affineOriginalTailDefinitions/.coordinateTail->affineOriginalTail;
If[(DownValues[affineOriginalTail]/.affineOriginalTail->coordinateTail)=!=affineOriginalTailDefinitions,Quit[1]];
coordinateTail[text_]:=Module[{changed=affineOriginalTail[text]},
 coordinateReplace[changed,"DistributeDefinitions[partitionNativeWrite,",
  "DistributeDefinitions[basisPrepareFamily,basisPieceCertificate,basisVariables,basisForms,basisCoordinates,basisInverse,basisForward,partitionNativeWrite,"]];
ToExpression[partitionRun,InputForm];

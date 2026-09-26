(* Resolve spin coefficients before the accepted contraction and scalar operations. *)
$HistoryLength=0;
componentDispatchPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_components.wls"}];
componentBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_packed_pairs.wls"}];
If[IntegerString[FileHash[componentBasePath,"SHA256"],16,64]=!=
  "d8f49bafd57f582aad3a959bb9348c2ca702fb0289a9c6f3341c1cbc94608645",Quit[1]];
componentBaseText=Import[componentBasePath,"Text"];
componentEntry="ToExpression[packedRunTail,InputForm];";
If[StringCount[componentBaseText,componentEntry]=!=1||
  !StringEndsQ[StringTrim[componentBaseText],componentEntry]||
  !SyntaxQ[Import[componentDispatchPath,"Text"]],Quit[1]];
componentPrefix=First[StringSplit[componentBaseText,componentEntry]];
If[!SyntaxQ[componentPrefix],Quit[1]];ToExpression[componentPrefix,InputForm];
componentProofRelative=channel<>"/s05_components_angular_result/s05_result.wl";
componentProofPath=FileNameJoin[{root,componentProofRelative}];
componentProof=Get[componentProofPath];
componentReceipt=Import[FileNameJoin[{DirectoryName[componentProofPath],"s05_execution.json"}],"RawJSON"];
componentPacketPath=FileNameJoin[{root,channel,"s05_trace_input_result","s05_result.wl"}];
componentPacket=Get[componentPacketPath];
gate["accepted complete own component calculation",channel==="Hgg"&&
  TrueQ[componentReceipt["passed"]]&&componentReceipt["job_id"]==="14816479"&&
  componentReceipt["result_sha256"][componentProofRelative]===
    IntegerString[FileHash[componentProofPath,"SHA256"],16,64]&&
  componentProof["Schema"]==="polarized-sidis-spin-component-projection-comparison-v1"&&
  componentProof["Channel"]===channel&&TrueQ[componentProof["Accepted"]]&&
  And@@Values[componentProof["Checks"]]&&
  TrueQ[componentProof["Checks"]["entire accepted own projection reproduced"]]&&
  componentProof["InputHash"]===inputHash&&componentProof["InputHashes"]===inputHashes&&
  componentProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  componentProof["ProductionSourceHash"]===FileHash[sourcePath,"SHA256"]&&
  componentProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s05_check_Hgg_components_angular.wls"}],"SHA256"]];
gate["accepted component equations and scalar parents",
  componentProof["InputPacketHash"]===FileHash[componentPacketPath,"SHA256"]&&
  componentProof["ParentTraceProofHash"]===FileHash[FileNameJoin[{root,"Hqg","s05_precontracted_trace_result","s05_result.wl"}],"SHA256"]&&
  componentProof["OwnAngularProofHash"]===FileHash[ownZeroProofPath,"SHA256"]&&
  componentProof["OwnEarlyPowerProofHash"]===FileHash[earlyProofPath,"SHA256"]&&
  componentProof["ReadableAngularEquationHash"]===FileHash[
    FileNameJoin[{root,channel,"s05_angular_equation_result","s05_result.wl"}],"SHA256"]&&
  componentPacket["ScalarRestore"]===scalarRestore&&
  componentPacket["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  componentPacket["InputHash"]===inputHash&&componentPacket["InputHashes"]===inputHashes&&
  Length[componentProof["Rows"]]===Length[componentPacket["Rows"]]&&
  Map[KeyTake[#,{"Pair","PhotonIndices","ExpressionHash"}]&,componentProof["Rows"]]===
    Map[KeyTake[#,{"Pair","PhotonIndices","ExpressionHash"}]&,componentPacket["Rows"]]&&
  AllTrue[componentProof["Rows"],TrueQ[#["ExactInputReconstruction"]]&]];
componentControlPath=FileNameJoin[{cache,"Real_1_1.wl"}];
gate["same own accepted component control",componentProof["ControlHash"]===FileHash[componentControlPath,"SHA256"]];
installComponentContraction[] := Module[{definitions,algorithm},
  gate["same native spin polynomial variables",componentPacket["SpinVariables"]==={outVariables,inVariables}];
  gate["same original angular equations",DownValues[angularAverageOne]===componentProof["OriginalAngularDefinitions"]];
  DownValues[certifiedAngularReduce]=componentProof["AngularNormalFormDefinitions"];
  DownValues[angularAverageOne]=componentProof["AngularDefinitions"];
  angularNormalFormEvidence=<||>;
  gate["exact accepted angular equations installed",
    DownValues[certifiedAngularReduce]===componentProof["AngularNormalFormDefinitions"]&&
    DownValues[angularAverageOne]===componentProof["AngularDefinitions"]&&
    (DownValues[angularAverageOne]/.certifiedAngularReduce->algebraicReduce)===componentProof["OriginalAngularDefinitions"]];
  definitions={DownValues[reduceScalar],DownValues[restoredScalarComponent],DownValues[algebraicReduce],
    DownValues[algebraicReduceOne],DownValues[angularAverage],DownValues[angularAverageOne],
    DownValues[exactAngularZero],DownValues[earlyPowerReduce]};
  gate["unchanged complete accepted scalar methods",definitions===componentProof["ScalarDefinitions"]];
  DownValues[componentResolvedScalar]=componentProof["CandidateDefinitions"];
  DownValues[precontractedTrace]=componentProof["TraceDefinitions"];
  gate["exact saved component implementation installed",
    DownValues[componentResolvedScalar]===componentProof["CandidateDefinitions"]&&
    DownValues[precontractedTrace]===componentProof["TraceDefinitions"]];
  algorithm=Hash[{DownValues[componentResolvedScalar],DownValues[precontractedTrace],
    definitions,DownValues[certifiedAngularReduce],transverseConstraint,$Version,$FeynCalcVersion},"SHA256"];
  gate["same executed component algorithm",algorithm===componentProof["AlgorithmHash"]];
  componentAlgorithmHash=algorithm;
  componentDirectory=FileNameJoin[{root,"cache","s05_spin_components",channel,
    IntegerString[inputHash,16],IntegerString[componentAlgorithmHash,16]}];
  If[!DirectoryQ[componentDirectory],CreateDirectory[componentDirectory,CreateIntermediateDirectories->True]];
  traceScalar[expression_]:=componentResolvedScalar[expression]["Value"]];
componentInstallAnchor="  installOwnEarlyPower[];";
componentWorkersAnchor="calculatePair, pairTask, packPairEntry";
componentMetadataAnchor="AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
componentChanges={
  componentInstallAnchor->(componentInstallAnchor<>"\n  installComponentContraction[];"),
  componentWorkersAnchor->"componentResolvedScalar, precontractedTrace, certifiedAngularReduce, angularNormalFormEvidence, componentAlgorithmHash, componentDirectory, calculatePair, pairTask, packPairEntry",
  componentMetadataAnchor->(componentMetadataAnchor<>
    "\nAssociateTo[result,{\"ComponentContractionProofHash\"->FileHash[componentProofPath,\"SHA256\"],\"ComponentContractionDispatchHash\"->FileHash[componentDispatchPath,\"SHA256\"]}];")};
gate["unique component contraction interfaces",And@@(StringCount[packedRunTail,First[#]]===1&/@componentChanges)];
componentRunTail=StringReplace[packedRunTail,componentChanges];
gate["original full production assembly preserved",
  StringReplace[componentRunTail,Reverse/@componentChanges]===packedRunTail&&SyntaxQ[componentRunTail]];
ToExpression[componentRunTail,InputForm];

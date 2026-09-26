(* Read the exact accepted S05 consumer fields; retain the complete finite assembly. *)
$HistoryLength=0;
projectedSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_projected_frame.wls"}];
projectedParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_compact_inputs.wls"}];
If[IntegerString[FileHash[projectedParent,"SHA256"],16,64]=!=
    "0e87dc4d088369ad3cd9754e31c5aedd4e6a80db2f18b3d318abb345cd68a613"||
   !SyntaxQ[Import[projectedSource,"Text"]],Print["FAIL: pinned projected-frame assembly source"];Quit[1]];
projectedLoadReal[relative_] := Module[{original,path,receiptPath,receipt,proof,producerPath,producer,fields},
  original=FileNameJoin[{root,relative}];
  gate["projected input is the original channel tensor",relative===channel<>"/s05_result/s05_result.wl"&&FileExistsQ[original]];
  path=FileNameJoin[{root,channel,"s14_frame_result","s14_result.wl"}];
  receiptPath=FileNameJoin[{root,channel,"s14_frame_result","s14_execution.json"}];
  receipt=Import[receiptPath,"RawJSON"];
  gate["accepted exact frame extraction",AssociationQ[receipt]&&TrueQ[receipt["passed"]]];
  KeyValueMap[gate["bound frame extraction result "<>#1,
    IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,receipt["result_sha256"]];
  proof=Get[path];
  Print["S14_FRAME_INTERFACE ",InputForm[<|"Schema"->proof["Schema"],"Channel"->proof["Channel"],"Accepted"->proof["Accepted"],"SavedNativeVersions"->proof["NativeVersions"],"ReaderNativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->proof["Checks"]|>]];
  gate["accepted native frame record",proof["Schema"]==="polarized-sidis-real-frame-projection-v1"&&
    proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
    proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
  gate["unchanged exact projection implementation",proof["SourceHash"]===
    FileHash[FileNameJoin[{root,"common","s14_project_real_frame.wls"}],"SHA256"]&&
    IntegerString[proof["SourceHash"],16,64]===
      "503ef2168287d2e0309c42704de529c395af605a9c8a99111fb59f31deea5cb5"];
  producerPath=FileNameJoin[{root,channel,"s05_result","s05_execution.json"}];
  producer=Import[producerPath,"RawJSON"];
  gate["same accepted complete tensor producer",TrueQ[producer["passed"]]&&
    proof["ProducerResultHash"]===FileHash[original,"SHA256"]&&
    proof["ProducerReceiptHash"]===FileHash[producerPath,"SHA256"]&&
    proof["ProducerResultHashes"]===producer["result_sha256"]];
  KeyValueMap[gate["bound original tensor result "<>#1,
    IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,producer["result_sha256"]];
  fields=proof["Projection"];
  gate["complete unchanged finite consumer fields",proof["RetainedKeys"]==={"Channel","Checks","Frame"}&&
    Sort[Keys[fields]]===Sort[proof["RetainedKeys"]]&&fields["Channel"]===channel&&
    AssociationQ[fields["Frame"]]&&And@@Values[fields["Checks"]]];
  AppendTo[inputPaths,original];
  projectedInputEvidence=<|"SourceHash"->FileHash[projectedSource,"SHA256"],
    "ProjectionHash"->FileHash[path,"SHA256"],"ProjectionReceiptHash"->FileHash[receiptPath,"SHA256"],
    "ProducerResultHash"->proof["ProducerResultHash"],"ProducerReceiptHash"->proof["ProducerReceiptHash"],
    "RetainedKeys"->proof["RetainedKeys"],"Evidence"->proof["Evidence"]|>;
  Print["S14_PROJECTED_INPUT ",InputForm[projectedInputEvidence]];fields];
projectedReplaceInput[] := Module[{anchor,replacement,original},
  anchor="spinReal=loadResult[channel<>\"/s05_result/s05_result.wl\"];";
  replacement="spinReal=projectedLoadReal[channel<>\"/s05_result/s05_result.wl\"];";
  If[StringCount[phaseRunPrefix,anchor]=!=1,Print["FAIL: unique complete tensor reader"];Quit[1]];
  original=phaseRunPrefix;phaseRunPrefix=StringReplace[phaseRunPrefix,anchor->replacement];
  If[StringReplace[phaseRunPrefix,replacement->anchor]=!=original||!SyntaxQ[phaseRunPrefix],
    Print["FAIL: unchanged finite assembly equations"];Quit[1]]];
projectedInstallReader[] := Module[{anchor,replacement,original},
  anchor="ToExpression[phaseRunPrefix,InputForm];";
  replacement="projectedReplaceInput[];"<>anchor;
  If[StringCount[compactAssemblyInitialization,anchor]=!=1,Print["FAIL: unique finite input initialization"];Quit[1]];
  original=compactAssemblyInitialization;
  compactAssemblyInitialization=StringReplace[compactAssemblyInitialization,anchor->replacement];
  If[StringReplace[compactAssemblyInitialization,replacement->anchor]=!=original||!SyntaxQ[compactAssemblyInitialization],
    Print["FAIL: unchanged compact assembly initialization"];Quit[1]]];
projectedRecordEvidence[] := Module[{anchor,replacement,original},
  anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
  replacement="AssociateTo[result,\"RealFrameProjection\"->projectedInputEvidence];"<>anchor;
  gate["unique projected assembly evidence boundary",StringCount[phaseRunTail,anchor]===1];
  original=phaseRunTail;phaseRunTail=StringReplace[phaseRunTail,anchor->replacement];
  gate["unchanged finite assembly and export gates",StringReplace[phaseRunTail,replacement->anchor]===original&&SyntaxQ[phaseRunTail]]];
projectedParentText=Import[projectedParent,"Text"];
projectedInsertions={
  "ToExpression[compactAssemblyInitialization,InputForm];"->
    "projectedInstallReader[];ToExpression[compactAssemblyInitialization,InputForm];",
  "\nToExpression[phaseRunTail,InputForm];"->
    "\nprojectedRecordEvidence[];ToExpression[phaseRunTail,InputForm];"};
If[!And@@(StringCount[projectedParentText,First[#]]===1&/@projectedInsertions),
  Print["FAIL: unique original compact assembly entries"];Quit[1]];
projectedRunText=StringReplace[projectedParentText,projectedInsertions];
If[StringReplace[projectedRunText,Reverse/@projectedInsertions]=!=projectedParentText||!SyntaxQ[projectedRunText],
  Print["FAIL: complete original assembly restoration"];Quit[1]];
ToExpression[projectedRunText,InputForm];

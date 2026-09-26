(* Lossless pair transport; the accepted contractions and sums remain unchanged. *)
$HistoryLength=0;
packedDispatchPath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_packed_pairs.wls"}];
packedBasePath=FileNameJoin[{Directory[],"common","s05_real_spin_response_Hgg_early_power.wls"}];
If[IntegerString[FileHash[packedBasePath,"SHA256"],16,64]=!=
  "6256f73b5dab9f299dc08ed09afdd1da62648ace4fb05734d92f969d80f1f04d",Quit[1]];
packedBaseText=Import[packedBasePath,"Text"];
packedEntry="ToExpression[earlyRunTail,InputForm];";
If[StringCount[packedBaseText,packedEntry]=!=1 ||
  !StringEndsQ[StringTrim[packedBaseText],packedEntry] ||
  !SyntaxQ[Import[packedDispatchPath,"Text"]],Quit[1]];
packedPrefix=First[StringSplit[packedBaseText,packedEntry]];
If[!SyntaxQ[packedPrefix],Quit[1]];ToExpression[packedPrefix,InputForm];

packPairEntry[value_] := Compress[<|"Value"->value,"ValueHash"->Hash[value,"SHA256"]|>];
unpackPairEntry[text_String] := Module[{entry=Uncompress[text]},
  gate["exact native transported entry",AssociationQ[entry] &&
    Keys[entry]==={"Value","ValueHash"} && Hash[entry["Value"],"SHA256"]===entry["ValueHash"]];
  entry["Value"]];
unpackPairRecord[record_Association] := Join[
  KeyDrop[record,{"PackedPairTransport","PackedTransportEvidence"}],
  <|"PhotonMatrix"->Map[unpackPairEntry,record["PhotonMatrix"],{2}],
    "ScalarModes"->Map[unpackPairEntry,record["ScalarModes"]]|>];
packPairRecord[record_Association] := Module[{packed,seconds,originalBytes,transportBytes},
  gate["accepted own pair before transport",record["InputHash"]===inputHash &&
    record["SectorWardComparisonHash"]===wardProofHash &&
    AssociationQ[record["Checks"]] && And@@Values[record["Checks"]]];
  originalBytes=ByteCount[record];
  {seconds,packed}=AbsoluteTiming[Join[record,<|
    "PhotonMatrix"->Map[packPairEntry,record["PhotonMatrix"],{2}],
    "ScalarModes"->Map[packPairEntry,record["ScalarModes"]],
    "PackedPairTransport"->True|>]];
  gate["native pair transport shape",MatrixQ[packed["PhotonMatrix"],StringQ] &&
    Dimensions[packed["PhotonMatrix"]]===Dimensions[record["PhotonMatrix"]] &&
    Keys[packed["ScalarModes"]]===Keys[record["ScalarModes"]] &&
    AllTrue[Values[packed["ScalarModes"]],StringQ]];
  gate["entire accepted own pair survives native transport",unpackPairRecord[packed]===record];
  transportBytes=ByteCount[packed];
  AssociateTo[packed,"PackedTransportEvidence"-><|"InputBytes"->originalBytes,
    "TransportBytes"->transportBytes,"PackingSeconds"->seconds,
    "ExactCompleteRecordComparison"->True|>];
  Print["PACKED_PAIR_TRANSPORT ",InputForm[packed["PackedTransportEvidence"]]];packed];
packedPairTask[pair_] := Catch[Block[{checks=<||>},Module[{record,packed},
  record=pairTask[pair];If[!AssociationQ[record],Return[record]];
  packed=bounded[packPairRecord[record],{label,pair,"lossless pair transport"}];
  Clear[record];ClearSystemCache[];packed]],"StageFailure"];
packedSumTask[task_] := Catch[Block[{checks=<||>},Module[{decoded},
  gate["packed sum entry list",ListQ[task["Values"]] && AllTrue[task["Values"],StringQ]];
  decoded=Join[task,<|"Values"->Map[unpackPairEntry,task["Values"]]|>];
  gate["original sum task metadata retained",KeyDrop[decoded,"Values"]===KeyDrop[task,"Values"]];
  sumTask[decoded]]],"StageFailure"];
verifyOwnPackedPair[] := Block[{checks=<||>},Module[{path,expected,record,packed,seconds,evidence,task,encodedTask},
  path=FileNameJoin[{cache,label<>"_"<>ToString[First[First[pairs]]]<>"_"<>
    ToString[Last[First[pairs]]]<>".wl"}];
  expected=Environment["POLARIZED_SIDIS_PACKED_PAIR_CONTROL_SHA256"];
  gate["pinned own completed pair transport control",StringQ[expected] &&
    IntegerString[FileHash[path,"SHA256"],16,64]===expected];
  record=Get[path];
  {seconds,packed}=AbsoluteTiming[bounded[packPairRecord[record],"own complete pair transport comparison"]];
  task=<|"Key"->"Photon_1_1","Values"->{record["PhotonMatrix"][[1,1]]}|>;
  encodedTask=Join[task,<|"Values"->{packed["PhotonMatrix"][[1,1]]}|>];
  Block[{sumTask},sumTask[value_]:=value;
    gate["actual saved entry restores the entire original sum packet",packedSumTask[encodedTask]===task]];
  evidence=Join[packed["PackedTransportEvidence"],<|"ControlFile"->
    StringDrop[path,StringLength[root]+1],"ControlFileHash"->FileHash[path,"SHA256"],
    "ComparisonSeconds"->seconds,"Checks"->checks,"NativeVersions"->{$Version,$FeynCalcVersion}|>];
  Clear[record,packed];ClearSystemCache[];
  Print["OWN_PACKED_PAIR_COMPARISON ",InputForm[evidence]];evidence]];
finishPackedPreflight[] := Module[{directory,proofPath,proof,receipt},
  directory=FileNameJoin[{root,channel,"s05_pair_transport_result"}];
  proofPath=FileNameJoin[{directory,"s05_result.wl"}];
  If[Environment["POLARIZED_SIDIS_PACKED_TRANSPORT_VALIDATE_ONLY"]==="1",
    If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
    proof=<|"Schema"->"polarized-sidis-pair-transport-comparison-v1","Channel"->channel,
      "Control"->ownPackedPairComparison,"SourceHash"->FileHash[packedDispatchPath,"SHA256"],
      "ProductionSourceHash"->FileHash[packedBasePath,"SHA256"],"InputHash"->inputHash,
      "InputHashes"->inputHashes,"NativeVersions"->{$Version,$FeynCalcVersion},
      "Checks"->ownPackedPairComparison["Checks"],"Accepted"->True|>;
    Put[proof,proofPath];
    gate["complete pair-transfer proof native reload",Get[proofPath]===proof];
    Export[FileNameJoin[{directory,"s05_checks.json"}],<|"channel"->channel,
      "checks"->Join[proof["Checks"],<|"exact proof reload"->True|>],
      "job_id"->Environment["JOB_ID"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
    CloseKernels[];Print["PASS: s05_pair_transport_validation"];Quit[0]];
  receipt=Import[FileNameJoin[{directory,"s05_execution.json"}],"RawJSON"];
  gate["accepted own pair-transfer receipt",TrueQ[receipt["passed"]] &&
    receipt["result_sha256"][channel<>"/s05_pair_transport_result/s05_result.wl"]===
      IntegerString[FileHash[proofPath,"SHA256"],16,64]];
  proof=Get[proofPath];
  gate["accepted exact own pair-transfer implementation",TrueQ[proof["Accepted"]] &&
    proof["Channel"]===channel && proof["SourceHash"]===FileHash[packedDispatchPath,"SHA256"] &&
    proof["ProductionSourceHash"]===FileHash[packedBasePath,"SHA256"] &&
    proof["InputHash"]===inputHash && proof["InputHashes"]===inputHashes &&
    proof["NativeVersions"]==={$Version,$FeynCalcVersion} && And@@Values[proof["Checks"]] &&
    proof["Control"]["ControlFileHash"]===ownPackedPairComparison["ControlFileHash"]]];

packedPairDispatch="ParallelMap[pairTask, pairs, Method -> \"FinestGrained\"], pairTask /@ pairs";
packedSumDispatch="ParallelMap[sumTask, sumTasks, Method -> \"FinestGrained\"], sumTask /@ sumTasks";
packedPairDefinitions="calculatePair, pairTask, amplitudes";
packedSumDefinitions="DistributeDefinitions[sumTask, linearComponentSum]";
packedBeforePairs="  pairValues = If[workerCount > 0,";
packedMetadata="AssociateTo[result, \"ScalarCheckpointValidationHash\" -> FileHash[coefficientProofPath, \"SHA256\"]];";
packedChanges={
  packedPairDispatch->"ParallelMap[packedPairTask, pairs, Method -> \"FinestGrained\"], packedPairTask /@ pairs",
  packedSumDispatch->"ParallelMap[packedSumTask, sumTasks, Method -> \"FinestGrained\"], packedSumTask /@ sumTasks",
  packedPairDefinitions->"calculatePair, pairTask, packPairEntry, unpackPairEntry, packPairRecord, unpackPairRecord, packedPairTask, amplitudes",
  packedSumDefinitions->"DistributeDefinitions[sumTask, linearComponentSum, packedSumTask, unpackPairEntry]",
  packedBeforePairs->("  ownPackedPairComparison=verifyOwnPackedPair[];finishPackedPreflight[];\n"<>packedBeforePairs),
  packedMetadata->(packedMetadata<>"\nAssociateTo[result,{\"PackedPairControl\"->ownPackedPairComparison,\"PackedPairDispatchHash\"->FileHash[packedDispatchPath,\"SHA256\"]}];")};
gate["unique lossless pair-transfer interfaces",And@@(StringCount[earlyRunTail,First[#]]===1&/@packedChanges)];
packedRunTail=StringReplace[earlyRunTail,packedChanges];
gate["unchanged complete contractions and assembly",StringReplace[packedRunTail,Reverse/@packedChanges]===earlyRunTail &&
  SyntaxQ[packedRunTail]];
ToExpression[packedRunTail,InputForm];

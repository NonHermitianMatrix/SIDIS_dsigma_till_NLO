(* Collect existing Hgg maps one component at a time after binding the metric input. *)
$HistoryLength=0;
collectorRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[collectorRoot];
collectorSource=FileNameJoin[{collectorRoot,"misc","s08_collect_Hgg_targets.wls"}];
collectorConfigPath=FileNameJoin[{collectorRoot,"misc","s08_inputs.json"}];
collectorConfig=Import[collectorConfigPath,"RawJSON"];
collectorRequire[name_,test_]:=If[!TrueQ[test],Print["FAIL: ",name];Quit[1]];
collectorRequire["complete collector source",SyntaxQ[ReadString[collectorSource]]&&
 IntegerString[FileHash[collectorSource,"SHA256"],16,64]===collectorConfig["source_sha256"]];
KeyValueMap[Function[{relative,identity},collectorRequire["collector pinned input "<>relative,
 IntegerString[FileHash[FileNameJoin[{collectorRoot,relative}],"SHA256"],16,64]===identity]],collectorConfig["input_sha256"]];
collectorBase=FileNameJoin[{collectorRoot,"misc","s06_map_Hgg_local.wls"}];
collectorText=ReadString[collectorBase];collectorBoundary="\nIf[Environment[\"POLARIZED_SIDIS_LOCAL_PREFLIGHT\"]";
collectorRequire["complete reused local initialization",StringCount[collectorText,collectorBoundary]===1];
collectorPrefix=First[StringSplit[collectorText,collectorBoundary]];
collectorRequire["reused initialization syntax",SyntaxQ[collectorPrefix]];ToExpression[collectorPrefix,InputForm];root=Directory[];
collectorOutput=FileNameJoin[{root,"misc","s08_result"}];
If[!DirectoryQ[collectorOutput],CreateDirectory[collectorOutput,CreateIntermediateDirectories->True]];
collectorNativeVersions={$Version,FeynCalc`$FeynCalcVersion};
collectorProvenance=<|"ExecutionBackend"->"local","NativeVersions"->collectorNativeVersions,
 "ImportedNativeVersions"->importedNativeVersions,"SourceHash"->FileHash[collectorSource,"SHA256"],
 "ConfigurationHash"->FileHash[collectorConfigPath,"SHA256"],"ReusedInitializationHash"->FileHash[collectorBase,"SHA256"]|>;
localProvenance=collectorProvenance;
collectorMappingHash=Hash[{FileHash[FileNameJoin[{root,"common","s08_result","reference","s08_map_real_spin_before_known_denominator.wls"}],"SHA256"],
 inputHashes,Sequence@@importedNativeVersions},"SHA256"];
gate["original mapping input identity reproduced",collectorMappingHash===record["InputHash"]];
collectorManifest=Import[FileNameJoin[{root,"misc","s08_imported_components.json"}],"RawJSON"];
groupManifest=Import[FileNameJoin[{root,"misc","s07_imported_groups.json"}],"RawJSON"];
mergeRelative="misc/s07_result/s07_result.wl";mergePath=FileNameJoin[{root,mergeRelative}];
mergeReceipt=Import[FileNameJoin[{DirectoryName[mergePath],"s07_execution.json"}],"RawJSON"];
gate["accepted actual local merge receipt",TrueQ[mergeReceipt["passed"]]&&mergeReceipt["execution_backend"]==="local"&&
 mergeReceipt["result_sha256"][mergeRelative]===IntegerString[FileHash[mergePath,"SHA256"],16,64]&&
 mergeReceipt["source_sha256"]===IntegerString[FileHash[FileNameJoin[{root,"misc","s07_merge_Hgg_coefficients.wls"}],"SHA256"],16,64]];
merged=Get[mergePath];
gate["complete local merge and runtime comparison",merged["Schema"]==="polarized-sidis-local-Hgg-coefficient-merge-v1"&&
 merged["Channel"]===channel&&merged["NativeVersions"]===collectorNativeVersions&&
 merged["ImportedNativeVersions"]===importedNativeVersions&&TrueQ[merged["OwnAcceptedComparison"]]&&
 merged["OriginalMergeDefinitions"]===DownValues[merge]&&Length[merged["Checks"]]>0&&And@@Values[merged["Checks"]]&&
 merged["ManifestHash"]===FileHash[FileNameJoin[{root,"misc","s07_imported_groups.json"}],"SHA256"]&&
 merged["Metric"]["InputFiles"]===groupManifest["groups"]];
metricPositions=Select[Range[Length[hggTaskMetadata]],hggTaskMetadata[[#]]["Kind"]==="PhotonMetricD"&];
gate["single original metric task",Length[metricPositions]===1];metricIndex=First[metricPositions];
metricTask=hggTaskMetadata[[metricIndex]];metricInput=hggTaskSources[[metricIndex]];
gate["original scalar payload interface",metricInput["Field"]==="Value"&&metricInput["Index"]==={}];
metricPayloadPath=FileNameJoin[{root,metricInput["Payload"]["File"]}];
gate["original scalar payload hash",FileHash[metricPayloadPath,"SHA256"]===metricInput["Payload"]["Hash"]];
metricPayload=bounded[Get[metricPayloadPath],"original complete scalar payload"];
gate["accepted original scalar",metricPayload["Channel"]===channel&&metricPayload["Key"]==="Scalar_PgD"&&
 Length[metricPayload["Checks"]]>0&&And@@Values[metricPayload["Checks"]]];
metricInputBytes=ByteCount[metricPayload["Value"]];
metricValue=bounded[metricPayload["Value"]/.coordinateRules,"saved metric coordinate conversion"];
Clear[metricPayload];ClearSystemCache[];
metricGroups=bounded[hggOriginalGrouping[metricValue],"complete original metric denominator grouping"];
metricGroupValues=KeyValueMap[#2/(Times@@MapThread[Power,{denominators,#1}])&,metricGroups];
gate["complete imported metric group inventory",Length[metricGroupValues]===Length[groupManifest["groups"]]];
metricExpectedBindings=MapIndexed[Hash[{groupInputHash,"component_"<>ToString[metricIndex],First[#2],#1},"SHA256"]&,metricGroupValues];
Clear[metricValue,metricGroups,metricGroupValues];ClearSystemCache[];
metricPackets=MapIndexed[Function[{row,position},Module[{path,packet},path=FileNameJoin[{root,row["file"]}];
 gate["exact original group file "<>row["file"],IntegerString[FileHash[path,"SHA256"],16,64]===row["sha256"]];
 packet=bounded[Get[path],{"saved metric group",First[position]}];
 gate["complete original metric group binding "<>ToString[First[position]],packet["Binding"]===metricExpectedBindings[[First[position]]]&&
  TrueQ[packet["Accepted"]]&&Length[packet["Checks"]]>0&&And@@Values[packet["Checks"]]];packet]],groupManifest["groups"]];
metricMaps=Lookup[metricPackets,"Coefficients"];metricGrouped=Merge[metricMaps,Identity];metricKeys=Keys[metricGrouped];
metricInventory=merged["Metric"]["Inventory"];
gate["complete original coefficient order",Lookup[metricInventory,"Key"]===metricKeys];
metricRecords=MapIndexed[Function[{row,position},Module[{path,packet,expected},path=FileNameJoin[{root,row["File"]}];
 gate["exact local coefficient file",IntegerString[FileHash[path,"SHA256"],16,64]===row["SHA256"]];packet=Get[path];
 expected=Hash[{merged["InputHash"],<|"Component"->"metric_component_98","Position"->First[position],
  "Key"->row["Key"],"Values"->metricGrouped[row["Key"]]|>},"SHA256"];
 gate["same fully reconstructed input and output",packet["Binding"]===expected&&row["Binding"]===expected&&packet["Key"]===row["Key"]&&
  TrueQ[packet["ReconstructionPassed"]]&&Length[packet["Checks"]]>0&&And@@Values[packet["Checks"]]&&
  KeyDrop[packet,"Value"]===KeyDrop[row,{"File","SHA256"}]];packet]],metricInventory];
metricCoefficients=Select[AssociationThread[metricKeys,Lookup[metricRecords,"Value"]],#=!=0&];
gate["complete original formal merge certificate",bounded[certifyPairMerge[metricMaps,metricGrouped,metricCoefficients],"complete metric merge certificate"]];
gate["both original physical cuts retained",And@@(Take[#[[2]],Length[geometry["CutMomenta"]]]===
 ConstantArray[1,Length[geometry["CutMomenta"]]]&/@Keys[metricCoefficients])];
metricRaw=Join[metricTask,<|"Coefficients"->metricCoefficients,"InputHash"->targetInputHash,
 "MissingTargets"->Complement[Keys[metricCoefficients],ruleKeys,reduction["Masters"]],"ReconstructionPassed"->True,
 "Checks"->checks,"InputBytes"->metricInputBytes,"OutputBytes"->ByteCount[metricCoefficients],
 "LocalMergeHash"->FileHash[mergePath,"SHA256"],"LocalMergeReceiptHash"->FileHash[FileNameJoin[{DirectoryName[mergePath],"s07_execution.json"}],"SHA256"]|>];
metricRawPath=FileNameJoin[{collectorOutput,"s08_metric_map.wl"}];saveNative[metricRaw,metricRawPath];
Clear[metricMaps,metricGrouped,metricPackets,metricRecords,metricCoefficients,metricRaw,merged];ClearSystemCache[];
rawFiles=Association[Map[Function[row,FromDigits[Last[StringCases[FileBaseName[row["file"]],DigitCharacter..]]]->row],collectorManifest["files"]]];
gate["all original response components present",Sort[Keys[rawFiles]]===Complement[Range[Length[hggTaskMetadata]],metricPositions]];
AssociateTo[rawFiles,metricIndex-><|"file"->StringDrop[metricRawPath,StringLength[root]+1],
 "sha256"->IntegerString[FileHash[metricRawPath,"SHA256"],16,64],"bytes"->FileByteCount[metricRawPath]|>];
targetInventory={};targetMissing={};
componentMetadata=Table[Module[{row=rawFiles[index],path,packet},path=FileNameJoin[{root,row["file"]}];
 gate["exact completed component file "<>ToString[index],IntegerString[FileHash[path,"SHA256"],16,64]===row["sha256"]];
 packet=bounded[Get[path],{"completed raw component",index}];
 gate["complete accepted component identity "<>ToString[index],packet["InputHash"]===targetInputHash&&
  KeyTake[packet,{"Sector","Kind","Index"}]===hggTaskMetadata[[index]]&&TrueQ[packet["ReconstructionPassed"]]&&
  Length[packet["Checks"]]>0&&And@@Values[packet["Checks"]]];
 targetInventory=Union[targetInventory,Keys[packet["Coefficients"]]];
 targetMissing=Union[targetMissing,Complement[Keys[packet["Coefficients"]],ruleKeys,reduction["Masters"]]];
 Print["LOCAL_RAW_COMPONENT_ACCEPTED ",index," bytes ",ByteCount[packet]];
 Join[KeyDrop[packet,"Coefficients"],<|"RawTargets"->Keys[packet["Coefficients"]],
  "RawCoefficientFile"->row["file"],"RawCoefficientSHA256"->row["sha256"]|>]],
 {index,Length[hggTaskMetadata]}];
gate["complete original component order",(KeyTake[#,{"Sector","Kind","Index"}]&/@componentMetadata)===hggTaskMetadata];
collectorResult=<|"Schema"->"polarized-sidis-real-target-map-v1","Channel"->channel,"Components"->componentMetadata,
 "ComponentStorage"->"hash-pinned-raw-component-files-v1","Targets"->targetInventory,"MissingTargets"->targetMissing,
 "ReductionCoverageComplete"->(targetMissing==={}),"Bookkeeping"->bookkeeping,"SourceHash"->FileHash[collectorSource,"SHA256"],
 "MapperSourceHash"->FileHash[FileNameJoin[{root,"common","s08_result","reference","s08_map_real_spin_before_known_denominator.wls"}],"SHA256"],
 "NativeVersions"->collectorNativeVersions,"ImportedNativeVersions"->importedNativeVersions,"InputHashes"->inputHashes,
 "InputHash"->targetInputHash,"MappingInputHash"->collectorMappingHash,
 "Checks"->checks,"MappingAccepted"->True,"FiniteNLOFHatsComputed"->False|>;
saveNative[collectorResult,FileNameJoin[{collectorOutput,"s08_result.wl"}]];
Export[FileNameJoin[{collectorOutput,"s08_checks.json"}],<|"checks"->checks,"components"->Length[componentMetadata],
 "targets"->Length[targetInventory],"missing_targets"->Length[targetMissing],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: local Hgg complete target collection"];Quit[0];

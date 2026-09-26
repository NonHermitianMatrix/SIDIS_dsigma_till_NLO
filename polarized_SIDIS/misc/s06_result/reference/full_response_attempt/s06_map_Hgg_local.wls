(* Authorized one-kernel execution of the accepted Hgg scalar map. *)
$HistoryLength=0;
localRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[localRoot];
root=localRoot;channel="Hgg";checks=<||>;
localSource=FileNameJoin[{root,"misc","s06_map_Hgg_local.wls"}];
localConfigPath=FileNameJoin[{root,"misc","s06_inputs.json"}];
localConfig=Import[localConfigPath,"RawJSON"];
localWork=FileNameJoin[{root,"misc","s06_work"}];
localOutput=FileNameJoin[{root,"misc","s06_result"}];
gate[name_,test_]:=If[TrueQ[test],If[!KeyExistsQ[checks,name],Print["PASS: ",name]];
 AssociateTo[checks,name->True],Print["FAIL: ",name];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=MemoryConstrained[TimeConstrained[value,3600,
 gate["time bound "<>ToString[label,InputForm],False]],4*1024^3,
 gate["operation memory bound "<>ToString[label,InputForm],False]];
zero[value_]:=Factor[Together[value]]===0;
gate["explicit authorized single local kernel",Environment["POLARIZED_SIDIS_LOCAL_AUTHORIZED"]==="1"&&$VersionNumber===15.];
gate["bound complete local source",SyntaxQ[ReadString[localSource]]&&
 IntegerString[FileHash[localSource,"SHA256"],16,64]===localConfig["source_sha256"]];
KeyValueMap[Function[{relative,identity},gate["pinned input "<>relative,
 IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===identity]],localConfig["input_sha256"]];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
localNativeVersions={$Version,FeynCalc`$FeynCalcVersion};
readAccepted[relative_,receiptName_:"s08_execution.json"]:=Module[{path,receipt,result},
 path=FileNameJoin[{root,relative}];receipt=Import[FileNameJoin[{DirectoryName[path],receiptName}],"RawJSON"];
 gate["accepted receipt "<>relative,TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 result=bounded[Get[path],{"accepted native input",relative}];
 gate["accepted checks "<>relative,AssociationQ[result]&&AssociationQ[result["Checks"]]&&
  Length[result["Checks"]]>0&&And@@Values[result["Checks"]]];result];
record=readAccepted["Hgg/s08_mapping_inputs_result/s08_component_0008.wl","s08_recovery_execution.json"];
gate["own complete Hgg native input",record["Schema"]==="polarized-sidis-native-mapping-input-v1"&&
 record["Channel"]===channel&&record["Component"]===8];
importedNativeVersions=record["NativeVersions"];
gate["same FeynCalc serialization version",Last[importedNativeVersions]===FeynCalc`$FeynCalcVersion];
inputHashes=record["InputHashes"];targetInputHash=record["TargetInputHash"];
coordinateRules=record["CoordinateRules"];
KeyValueMap[Function[{relative,identity},gate["unchanged scientific input "<>relative,
 FileHash[FileNameJoin[{root,relative}],"SHA256"]===identity]],inputHashes];
geometry=record["Geometry"];denominators=record["Denominators"];
directions=record["Directions"];families=record["Families"];familyNames=Keys[families];
sourceBlock[relative_,first_,last_]:=Module[{text,begin,end,block},
 text=ReadString[FileNameJoin[{root,relative}]];begin=StringPosition[text,first];end=StringPosition[text,last];
 gate["unique reviewed source block "<>relative,Length[begin]===1&&Length[end]===1];
 block=StringTake[text,{First[First[begin]],First[First[end]]-1}];
 gate["complete source block syntax "<>relative,SyntaxQ[block]];block];
ToExpression[sourceBlock["common/s08_result/reference/s08_map_real_spin_before_known_denominator.wls",
 "\nmerge[pieces_List]","\ncoefficientPath ="],InputForm];
gate["exact own original mapping definitions",{DownValues[mapExpression],DownValues[familyRows],DownValues[merge]}===
 Lookup[record,{"OriginalMappingDefinitions","OriginalFamilyDefinitions","OriginalMergeDefinitions"}]];
DownValues[certifyPairMerge]=record["MergeCertificateDefinitions"];
DownValues[certifyGroupMerge]=record["GroupMergeDefinitions"];
DownValues[pairReconstruct]=record["ReconstructionDefinitions"];
polynomial=readAccepted["Hqg/s08_polynomial_group_result/s08_result.wl"];
gate["accepted reusable polynomial contract",TrueQ[polynomial["Accepted"]]&&TrueQ[polynomial["OwnAcceptedComparison"]]&&
 polynomial["NativeVersions"]===importedNativeVersions&&polynomial["OriginalFamilyDefinitions"]===DownValues[familyRows]&&
 KeyDrop[polynomial["InputHashes"],"Hqg/s05_result/s05_result.wl"]===KeyDrop[inputHashes,"Hgg/s05_result/s05_result.wl"]];
DownValues[familyRows]=polynomial["CandidateFamilyDefinitions"];
polynomialVariables=polynomial["PolynomialVariables"];
DownValues[polynomialAdditivePieces]=polynomial["AdditivePiecesDefinitions"];
DownValues[polynomialPieceMap]=polynomial["PieceMappingDefinitions"];
DownValues[localOriginalSave]=polynomial["PieceStorageDefinitions"]/.saveNative->localOriginalSave;
gate["unchanged exact native writer",(DownValues[localOriginalSave]/.localOriginalSave->saveNative)===polynomial["PieceStorageDefinitions"]];
pieceScientificHash=Hash[{polynomial["PieceScientificHash"],targetInputHash,
 FileHash[FileNameJoin[{root,"common","s08_map_Hgg_factored_inputs.wls"}],"SHA256"]},"SHA256"];
sameOwnContract[proof_]:=proof["NativeVersions"]===importedNativeVersions&&
 proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&TrueQ[proof["OwnAcceptedComparison"]];
atom=readAccepted["Hgg/s08_factored_atom_certificate_result/s08_result.wl"];
gate["accepted exact atom implementation",sameOwnContract[atom]&&atom["OriginalExtractionDefinitions"]===DownValues[extractAtoms]&&
 atom["OriginalGroupingCertificateDefinitions"]===record["GroupingCertificateDefinitions"]];
atomVariables=atom["Variables"];DownValues[factoredAtoms]=atom["FactoredExtractionDefinitions"];
DownValues[extractAtoms]=atom["DispatchDefinitions"];
DownValues[factoredAtomCertificate]=atom["AtomCertificateDefinitions"];
DownValues[certifyGrouping]=atom["GroupingCertificateDefinitions"];Clear[atom];ClearSystemCache[];
scalar=readAccepted["Hgg/s08_scalar_certificate_result/s08_result.wl"];
gate["accepted exact scalar certificates",sameOwnContract[scalar]&&TrueQ[scalar["ActualAcceptedComparison"]]&&
 scalar["OriginalFamilyDefinitions"]===DownValues[familyRows]&&scalar["OriginalMappingDefinitions"]===DownValues[mapExpression]];
DownValues[familyRows]=scalar["FamilyDefinitions"];DownValues[mapExpression]=scalar["MappingDefinitions"];
DownValues[certifyFamilyLaurent]=scalar["FamilyCertificateDefinitions"];
DownValues[certifyScalarReconstruction]=scalar["MappingCertificateDefinitions"];Clear[scalar];
compact=readAccepted["Hgg/s08_compact_groups_result/s08_result.wl"];
gate["accepted compact grouping contract",sameOwnContract[compact]&&Length[compact["CandidateDefinitions"]]===2];
DownValues[hggOriginalGrouping]=First[compact["CandidateDefinitions"]];
DownValues[groupDenominators]=DownValues[hggOriginalGrouping]/.hggOriginalGrouping->groupDenominators;
DownValues[groupedMapExpression]=Last[compact["CandidateDefinitions"]]/.mapExpression->polynomialPieceMap;
gate["only accepted piece mapper installed",(DownValues[groupedMapExpression]/.polynomialPieceMap->mapExpression)===Last[compact["CandidateDefinitions"]]];
external=readAccepted["Hgg/s08_external_factor_result/s08_result.wl"];
gate["accepted exact external-factor implementation",sameOwnContract[external]&&TrueQ[external["ActualAcceptedComparison"]]&&
 {DownValues[mapExpression],DownValues[familyRows],DownValues[merge]}===
 Lookup[external,{"OriginalMappingDefinitions","FamilyDefinitions","MergeDefinitions"}]];
externalVariables=external["Variables"];externalEvidence={};externalFallbackCount=0;
DownValues[externalAtomCompatible]=external["CompatibilityDefinitions"];
DownValues[externalSplit]=external["SplitDefinitions"];
DownValues[externalFactorMap]=external["FactorMappingDefinitions"];
DownValues[externalOriginalMap]=external["OriginalAliasDefinitions"];
DownValues[mapExpression]=external["MappingDefinitions"];
controlReference=external["OwnCoefficients"];Clear[external,polynomial,compact];ClearSystemCache[];
ToExpression[sourceBlock["common/s08_resume_Hqg_polynomial_maps.wls",
 "\nnumericOuterFactor[expression_]","\ninstallNumericPhase[]"],InputForm];
reader=readAccepted["Hgg/s08_response_read_result/s08_result.wl"];
gate["accepted input reader native version",reader["NativeVersions"]===importedNativeVersions&&TrueQ[reader["OwnAcceptedComparison"]]];
DownValues[responseOnlyRead]=reader["ReaderDefinitions"];Clear[reader];
inputFunctions=sourceBlock["common/s08_map_Hgg_component_inputs.wls","\nhggInitializeTasks[]","\nhggBaselinePath ="];
gate["unique accepted payload read",StringCount[inputFunctions,"Get[path]"]===1];
inputFunctions=StringReplace[inputFunctions,"Get[path]"->"responseOnlyRead[path,row[\"Payload\"][\"Hash\"]]"];
gate["complete single-component reader syntax",SyntaxQ[inputFunctions]];ToExpression[inputFunctions,InputForm];
spin=Get[FileNameJoin[{root,"Hgg","s05_result","s05_metadata.wl"}]];
gate["accepted complete metadata",spin["Channel"]===channel&&And@@Values[spin["Checks"]]];
hggInitializeTasks[];
gate["own native task identity",hggTaskMetadata[[8]]===record["Task"]];
gate["selected components exist",AllTrue[localConfig["components"],IntegerQ[#]&&1<=#<=Length[tasks]&]&&DuplicateFreeQ[localConfig["components"]]];
reduction=Get[FileNameJoin[{root,"common","s06_result","reference","s04_result.wl"}]]/.{Q2->Q^2,w->s23};
gate["accepted original scalar reduction",TrueQ[reduction["Accepted"]]];ruleKeys=First/@reduction["Rules"];
groupInputHash=Hash[{FileHash[FileNameJoin[{root,"common","s08_map_Hgg_factored_inputs.wls"}],"SHA256"],
 FileHash[FileNameJoin[{root,"Hgq","s08_certified_denominator_result","s08_result.wl"}],"SHA256"],
 inputHashes,targetInputHash,record["Component"],Hash[record["Expression"],"SHA256"],
 Sequence@@importedNativeVersions},"SHA256"];
gate["scientific group identity matches imported checkpoints",IntegerString[groupInputHash,16]===localConfig["group_input_hash"]];
localExecutionIdentity=Hash[{FileHash[localSource,"SHA256"],FileHash[localConfigPath,"SHA256"],localNativeVersions},"SHA256"];
localProvenance=<|"ExecutionBackend"->"local","NativeVersions"->localNativeVersions,
 "ImportedNativeVersions"->importedNativeVersions,"LocalSourceHash"->FileHash[localSource,"SHA256"],
 "LocalConfigurationHash"->FileHash[localConfigPath,"SHA256"],"ExecutionIdentity"->localExecutionIdentity|>;
saveNative[value_,path_]:=localOriginalSave[Join[value,<|"ExecutionProvenance"->localProvenance|>],path];
put[value_,path_]:=saveNative[value,path];
Do[If[!DirectoryQ[dir],CreateDirectory[dir,CreateIntermediateDirectories->True]],{dir,{localWork,localOutput}}];
If[Environment["POLARIZED_SIDIS_LOCAL_PREFLIGHT"]==="1",Print["PASS: local Hgg complete interface preflight"];Quit[0]];
controlPath=FileNameJoin[{localOutput,"s06_control.wl"}];
controlSaved=If[FileExistsQ[controlPath],Get[controlPath],<||>];
If[Lookup[controlSaved,"ExecutionIdentity",None]=!=localExecutionIdentity||!TrueQ[Lookup[controlSaved,"OwnAcceptedComparison",False]],
 Print["LOCAL_COMPLETE_OWN_COMPARISON_START"];
 controlTerms=If[Head[record["Expression"]]===Plus,List@@record["Expression"],{record["Expression"]}];
 gate["whole own input retained",Total[controlTerms]===record["Expression"]];
 controlPackets=MapIndexed[Function[{term,index},Block[{checks=<||>},Module[{seconds,rows},
  Print["LOCAL_OWN_TERM_START ",First[index],"/",Length[controlTerms]];
  {seconds,rows}=AbsoluteTiming[bounded[mapExpression[term],{"whole own term",First[index]}]];
  Print["LOCAL_OWN_TERM_DONE ",First[index]," seconds ",seconds];
  <|"Coefficients"->rows,"Checks"->checks,"Accepted"->True,"Seconds"->seconds|>]]],controlTerms];
 controlRows=bounded[merge[Lookup[controlPackets,"Coefficients"]],"whole own merge"];
 gate["whole own exact merge certificate",certifyGroupMerge[controlPackets,controlRows]];
 gate["every accepted own Hgg coefficient unchanged",Sort[Keys[controlRows]]===Sort[Keys[controlReference]]&&
  And@@KeyValueMap[(#2===controlReference[#1]||bounded[zero[#2-controlReference[#1]],{"own coefficient",#1}])&,controlRows]];
 controlSaved=<|"Schema"->"polarized-sidis-local-Hgg-runtime-comparison-v1","Channel"->channel,
  "ExecutionIdentity"->localExecutionIdentity,"OwnAcceptedComparison"->True,
  "InputHash"->targetInputHash,"NativeInputHash"->FileHash[FileNameJoin[{root,"Hgg","s08_mapping_inputs_result","s08_component_0008.wl"}],"SHA256"],
  "ReferenceHash"->FileHash[FileNameJoin[{root,"Hgg","s08_external_factor_result","s08_result.wl"}],"SHA256"],
  "Coefficients"->controlRows,"Checks"->checks,"TermSeconds"->Lookup[controlPackets,"Seconds"],"FiniteNLOFHatsComputed"->False|>;
 saveNative[controlSaved,controlPath];Print["LOCAL_COMPLETE_OWN_COMPARISON_ACCEPTED"]];
gate["accepted exact local runtime comparison",TrueQ[controlSaved["OwnAcceptedComparison"]]&&And@@Values[controlSaved["Checks"]]];
AssociateTo[localProvenance,"OwnComparisonHash"->FileHash[controlPath,"SHA256"]];
Clear[controlReference,controlRows,controlPackets,controlTerms,controlSaved,record,spin];ClearSystemCache[];
groupCache=FileNameJoin[{localWork,"cache","s08_Hgg_grouped",IntegerString[groupInputHash,16]}];
Do[If[!DirectoryQ[dir],CreateDirectory[dir,CreateIntermediateDirectories->True]],{dir,{groupCache,groupCache<>"_numeric_phase"}}];
localMap[index_]:=Block[{checks=<||>},Module[{value,originalBytes,seconds,coefficients,result,path},
 path=FileNameJoin[{localOutput,"s06_component_"<>IntegerString[index,10,4]<>".wl"}];
 If[FileExistsQ[path],result=Get[path];If[TrueQ[result["ReconstructionPassed"]]&&
  result["ExecutionProvenance"]["ExecutionIdentity"]===localExecutionIdentity&&And@@Values[result["Checks"]],Return[result]]];
 Print["LOCAL_HGG_COMPONENT_START ",index," ",InputForm[hggTaskMetadata[[index]]]];
 value=bounded[hggTaskValue[index],{"load component",index}];originalBytes=ByteCount[value];
 Clear[hggCachedValue,hggCachedKey];ClearSystemCache[];
 value=value/.coordinateRules;
 Print["LOCAL_HGG_INPUT_BYTES ",index," ",ByteCount[value]];
 {seconds,coefficients}=AbsoluteTiming[Block[{root=localWork,numericPhaseCache=groupCache<>"_numeric_phase"},
  numericPhaseMap[value,"component_"<>ToString[index]]]];
 gate["complete selected component reconstructed",AssociationQ[coefficients]&&Length[checks]>0&&And@@Values[checks]];
 result=Join[hggTaskMetadata[[index]],<|"ComponentIndex"->index,"Coefficients"->coefficients,
  "MissingTargets"->Complement[Keys[coefficients],ruleKeys,reduction["Masters"]],
  "InputHash"->targetInputHash,"ReconstructionPassed"->True,"Checks"->checks,"Seconds"->seconds,
  "InputBytes"->originalBytes,"OutputBytes"->ByteCount[coefficients],"NativeVersions"->localNativeVersions,
  "FiniteNLOFHatsComputed"->False|>];saveNative[result,path];
 Print["LOCAL_HGG_COMPONENT_ACCEPTED ",index," seconds ",seconds," targets ",Length[coefficients]];
 KeyDrop[result,"Coefficients"]]];
localComponents=localMap/@localConfig["components"];
gate["all requested local components accepted",And@@Lookup[localComponents,"ReconstructionPassed"]&&
 And@@Flatten[Values[#["Checks"]]&/@localComponents]];
saveNative[<|"Schema"->"polarized-sidis-local-Hgg-components-v1","Channel"->channel,
 "Components"->localComponents,"Checks"->checks,"OwnAcceptedComparison"->True,
 "InputHash"->targetInputHash,"FiniteNLOFHatsComputed"->False|>,FileNameJoin[{localOutput,"s06_result.wl"}]];
Export[FileNameJoin[{localOutput,"s06_checks.json"}],<|"checks"->checks,"components"->localConfig["components"],
 "execution_backend"->"local","native_versions"->localNativeVersions,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: local Hgg requested component maps"];Quit[0];

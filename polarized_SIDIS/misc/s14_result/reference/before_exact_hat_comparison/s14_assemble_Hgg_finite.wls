(* Local execution of the unchanged native Hgg finite assembly. *)
$HistoryLength=0;
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
localFiniteRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[localFiniteRoot];
localFiniteSource=FileNameJoin[{localFiniteRoot,"misc","s14_assemble_Hgg_finite.wls"}];
localFiniteConfigPath=FileNameJoin[{localFiniteRoot,"misc","s14_inputs.json"}];
localFiniteConfig=Import[localFiniteConfigPath,"RawJSON"];
localFiniteRequire[n_,x_]:=If[!TrueQ[x],Print["FAIL: ",n];Quit[1]];
localFiniteRequire["bound complete finite source",SyntaxQ[ReadString[localFiniteSource]]&&
 IntegerString[FileHash[localFiniteSource,"SHA256"],16,64]===localFiniteConfig["source_sha256"]];
KeyValueMap[Function[{p,h},localFiniteRequire["pinned finite input "<>p,
 IntegerString[FileHash[FileNameJoin[{localFiniteRoot,p}],"SHA256"],16,64]===h]],localFiniteConfig["input_sha256"]];
SetEnvironment["POLARIZED_SIDIS_CHANNEL"->"Hgg"];
localFiniteChange[text_,edits_]:=Module[{candidate},
 localFiniteRequire["unique reviewed finite interfaces",And@@(StringCount[text,First[#]]===1&/@edits)];
 candidate=StringReplace[text,edits];localFiniteRequire["complete preserved finite implementation",SyntaxQ[candidate]&&
 StringReplace[candidate,Reverse/@edits]===text];candidate];
localFinitePrefix[text_]:=localFiniteChange[text,{"gate[\"compute allocation\",StringQ[Environment[\"JOB_ID\"]]&&!StringStartsQ[$MachineName,\"login\"]];\ngate[\"isolated runtime\",StringStartsQ[$UserBaseDirectory,root<>\"/\"]];"->"gate[\"authorized local finite assembly\",Environment[\"POLARIZED_SIDIS_LOCAL_AUTHORIZED\"]===\"1\"&&$VersionNumber===15.];",
"inputPaths={configPath,basePath};"->"inputPaths={configPath,basePath,localFiniteSource,localFiniteConfigPath,FileNameJoin[{root,\"misc\",\"s11_result\",\"s11_execution.json\"}]};",
"real=loadResult[channel<>\"/s12_result/s12_result.wl\"];"->"real=loadResult[\"misc/s11_result/s11_result.wl\"];\nlocalFiniteImportedVersions=real[\"ImportedNativeVersions\"];\nlocalFiniteReceipt=Import[FileNameJoin[{root,\"misc\",\"s11_result\",\"s11_execution.json\"}],\"RawJSON\"];\ngate[\"actual accepted local integrated input\",real[\"NativeVersions\"]==={$Version,$FeynCalcVersion}&&\n Last[localFiniteImportedVersions]===$FeynCalcVersion&&TrueQ[localFiniteReceipt[\"passed\"]]&&\n localFiniteReceipt[\"execution_backend\"]===\"local\"&&\n localFiniteReceipt[\"result_sha256\"][\"misc/s11_result/s11_result.wl\"]===IntegerString[FileHash[FileNameJoin[{root,\"misc\",\"s11_result\",\"s11_result.wl\"}],\"SHA256\"],16,64]];",
"cache=FileNameJoin[{root,\"cache\",\"s14\",channel,IntegerString[inputHash,16]}];"->"cache=FileNameJoin[{root,\"misc\",\"s14_work\",IntegerString[inputHash,16]}];",
"saved=If[FileExistsQ[file],Get[file],<||>];"->"saved=localFiniteRead[label,file];"}];
localFinitePhase[text_]:=localFiniteChange[text,{
 "phaseRunProof[\"NativeVersions\"]==={$Version,$FeynCalcVersion}"->
 "phaseRunProof[\"NativeVersions\"]===localFiniteImportedVersions",
 "Get[\"FeynCalc`\"]"->"If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]"}];
(* Keep the accepted assembly and consume Hgg's native MS subtraction. *)
$HistoryLength=0;
hggNativeSource=FileNameJoin[{Directory[],"common","s14_Hgg_native_subtraction.wls"}];
hggNativeBase=FileNameJoin[{Directory[],"common","s14_assemble_finite_compact_inputs.wls"}];
If[IntegerString[FileHash[hggNativeBase,"SHA256"],16,64]=!=
 "0e87dc4d088369ad3cd9754e31c5aedd4e6a80db2f18b3d318abb345cd68a613"||
 !SyntaxQ[Import[hggNativeSource,"Text"]],Quit[1]];
hggNativeAdapt[text_]:=Module[{old,new,candidate},
 old="subtraction=loadResult[channel<>\"/s11_result/s11_result.wl\"];";
 new="gate[\"own native-subtraction assembly\",channel===\"Hgg\"&&!core];"<>
  "subtraction=loadResult[channel<>\"/s11_native_result/s11_result.wl\"];"<>
  "hggNativeReceiptPath=FileNameJoin[{root,channel,\"s11_native_result\",\"s11_execution.json\"}];"<>
  "hggNativeSubtractionPath=FileNameJoin[{root,channel,\"s11_native_result\",\"s11_result.wl\"}];"<>
  "hggNativeSubtractionSource=FileNameJoin[{root,\"common\",\"s11_Hgg_native_routes.wls\"}];"<>
  "hggNativeReceipt=Import[hggNativeReceiptPath,\"RawJSON\"];"<>
  "gate[\"bound accepted native subtraction\",TrueQ[hggNativeReceipt[\"passed\"]]&&"<>
   "hggNativeReceipt[\"result_sha256\"][channel<>\"/s11_native_result/s11_result.wl\"]===IntegerString[FileHash[hggNativeSubtractionPath,\"SHA256\"],16,64]&&"<>
   "subtraction[\"SourceHash\"]===FileHash[hggNativeSubtractionSource,\"SHA256\"]&&"<>
   "TrueQ[subtraction[\"AcceptedForProduction\"]]&&TrueQ[subtraction[\"OwnAcceptedSubtractionComparison\"]]&&"<>
   "TrueQ[subtraction[\"FiniteDimensionalSchemeConversionApplied\"]]&&And@@Values[subtraction[\"Checks\"]]&&"<>
   "subtraction[\"OriginalSubtractionHash\"]===FileHash[FileNameJoin[{root,channel,\"s11_result\",\"s11_result.wl\"}],\"SHA256\"]&&"<>
   "FreeQ[subtraction[\"NativeCountertermDifference\"],eps|D|_SeriesData|$Failed|$Aborted]];"<>
  "inputPaths=Join[inputPaths,{hggNativeSource,hggNativeBase,hggNativeReceiptPath,hggNativeSubtractionSource}];";
 If[StringCount[text,old]=!=1,Print["FAIL: unique Hgg subtraction input"];Quit[1]];
 candidate=StringReplace[text,old->new];
 If[!SyntaxQ[candidate]||StringReplace[candidate,new->old]=!=text,
  Print["FAIL: unchanged full Hgg assembly prefix"];Quit[1]];candidate];
hggNativeInitialization[text_]:=Module[{old,new,candidate},
 old="ToExpression[phaseRunPrefix,InputForm];";
 new="phaseRunPrefix=localFinitePrefix[hggNativeAdapt[phaseRunPrefix]];"<>old;
 If[StringCount[text,old]=!=1,Print["FAIL: unique native assembly prefix handoff"];Quit[1]];
 candidate=StringReplace[text,old->new];
 If[!SyntaxQ[candidate]||StringReplace[candidate,new->old]=!=text,Quit[1]];candidate];
hggNativeText=StringTrim[Import[hggNativeBase,"Text"]];hggNativeTerminal="ToExpression[phaseRunTail,InputForm];";
If[!StringEndsQ[hggNativeText,hggNativeTerminal],Quit[1]];
hggNativePrefix=StringDrop[hggNativeText,-StringLength[hggNativeTerminal]];
hggNativeEntry="ToExpression[compactAssemblyInitialization,InputForm];";
hggNativeChangedEntry="compactAssemblyInitialization=localFinitePhase[hggNativeInitialization[compactAssemblyInitialization]];"<>hggNativeEntry;
If[StringCount[hggNativePrefix,hggNativeEntry]=!=1,Quit[1]];
hggNativePrefixCandidate=StringReplace[hggNativePrefix,hggNativeEntry->hggNativeChangedEntry];
If[!SyntaxQ[hggNativePrefixCandidate]||StringReplace[hggNativePrefixCandidate,hggNativeChangedEntry->hggNativeEntry]=!=hggNativePrefix,Quit[1]];
ToExpression[hggNativePrefixCandidate,InputForm];

(* Reuse the accepted regulator-only phase helper and exact native checkpoints. *)
localFinitePhasePath=FileNameJoin[{root,"misc","s34_regulator_only_phase_product.wls"}];
localFiniteProofPath=FileNameJoin[{root,"misc","s34_result","s34_result.wl"}];
localFiniteProofReceipt=Import[FileNameJoin[{root,"misc","s34_result","s34_execution.json"}],"RawJSON"];
gate["accepted complete phase optimization",TrueQ[localFiniteProofReceipt["passed"]]&&
 localFiniteProofReceipt["result_sha256"]["misc/s34_result/s34_result.wl"]===
 IntegerString[FileHash[localFiniteProofPath,"SHA256"],16,64]];
localFiniteProof=KeyDrop[Get[localFiniteProofPath],{"Candidates","Finite"}];
gate["exact phase proof source and runtime",TrueQ[localFiniteProof["Accepted"]]&&
 And@@Values[localFiniteProof["Checks"]]&&localFiniteProof["SourceHash"]===FileHash[localFinitePhasePath,"SHA256"]&&
 localFiniteProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
localFiniteChangedInputKeys={"misc/s14_assemble_Hgg_finite.wls","misc/s14_inputs.json"};
gate["all original mathematical assembly inputs unchanged",
 KeyDrop[inputHashes,localFiniteChangedInputKeys]===KeyDrop[localFiniteProof["InputHashes"],localFiniteChangedInputKeys]&&
 Hash[{sourceHash,localFiniteProof["InputHashes"],$Version,FeynCalc`$FeynCalcVersion},"SHA256"]===localFiniteProof["InputHash"]];
Get[localFinitePhasePath];localPhaseInstall[];
gate["validated complete phase implementation installed",DownValues[laurentProduct]===localFiniteProof["LaurentDefinitions"]];
localFiniteResumePath=FileNameJoin[{root,"misc","s14_resume.json"}];
localFiniteResume=Import[localFiniteResumePath,"RawJSON"];
gate["original complete assembly source pinned for reuse",
 FileHash[FileNameJoin[{root,localFiniteResume["parent_source"]}],"SHA256"]===
 localFiniteProof["InputHashes"]["misc/s14_assemble_Hgg_finite.wls"]&&
 FileHash[FileNameJoin[{root,localFiniteResume["parent_config"]}],"SHA256"]===
 localFiniteProof["InputHashes"]["misc/s14_inputs.json"]];

localFiniteGateProofPath=FileNameJoin[{root,"misc","s36_result","s36_result.json"}];
localFiniteGateReceipt=Import[FileNameJoin[{root,"misc","s36_result","s36_execution.json"}],"RawJSON"];
localFiniteGateProof=Import[localFiniteGateProofPath,"RawJSON"];
gate["accepted exact scoped Laurent predicate",TrueQ[localFiniteGateReceipt["passed"]]&&
 localFiniteGateReceipt["result_sha256"]["misc/s36_result/s36_result.json"]===
 IntegerString[FileHash[localFiniteGateProofPath,"SHA256"],16,64]&&
 And@@Values[localFiniteGateProof["checks"]]&&localFiniteGateProof["source_sha256"]===
 IntegerString[FileHash[FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}],"SHA256"],16,64]];
localFiniteParentSource=FileNameJoin[{root,"misc","s14_result","reference","before_scoped_polynomial_gate","s14_assemble_Hgg_finite.wls"}];
localFiniteParentConfig=FileNameJoin[{root,"misc","s14_result","reference","before_scoped_polynomial_gate","s14_inputs.json"}];
gate["bound accepted predicate parent generation",
 IntegerString[FileHash[localFiniteParentSource,"SHA256"],16,64]===localFiniteGateReceipt["source_sha256"]&&
 IntegerString[FileHash[localFiniteParentConfig,"SHA256"],16,64]===
 localFiniteGateReceipt["input_sha256"]["misc/s14_inputs.json"]];
localFiniteParentInputs=inputHashes;
AssociateTo[localFiniteParentInputs,{
 "misc/s14_assemble_Hgg_finite.wls"->FileHash[localFiniteParentSource,"SHA256"],
 "misc/s14_inputs.json"->FileHash[localFiniteParentConfig,"SHA256"]}];
localFiniteParentInputHash=Hash[{sourceHash,localFiniteParentInputs,$Version,FeynCalc`$FeynCalcVersion},"SHA256"];
localFiniteAcceptedInputHashes={localFiniteProof["InputHash"],localFiniteParentInputHash};

localFiniteReused=<||>;
localFiniteRead[label_,currentPath_]:=Module[{name,row,path,saved},
 If[FileExistsQ[currentPath],Return[Get[currentPath]]];
 name=FileNameTake[currentPath];
 If[!KeyExistsQ[localFiniteResume["files"],name],Return[<||>]];
 row=localFiniteResume["files"][name];path=FileNameJoin[{root,row["path"]}];
 gate["pinned accepted finite checkpoint "<>ToString[label,InputForm],
  IntegerString[FileHash[path,"SHA256"],16,64]===row["sha256"]];
 saved=Get[path];
 gate["exact accepted finite checkpoint identity "<>ToString[label,InputForm],
  TrueQ[saved["Accepted"]]&&saved["Label"]===label&&MemberQ[localFiniteAcceptedInputHashes,saved["InputHash"]]&&
  KeyExistsQ[saved,"Finite"]&&KeyExistsQ[saved,"PoleResiduals"]];
 AssociateTo[localFiniteReused,name-><|"Label"->label,"Path"->row["path"],"SHA256"->row["sha256"]|>];
 Join[saved,<|"InputHash"->inputHash,"OriginalInputHash"->saved["InputHash"],"CheckpointSHA256"->row["sha256"]|>]];

(* Complete the rational/algebraic pole sum with the accepted exact backend. *)
localFiniteSumPath=FileNameJoin[{root,"misc","s35_exact_Hgg_finite_poles.wls"}];
localFiniteSumProofPath=FileNameJoin[{root,"misc","s35_result","s35_result.wl"}];
localFiniteSumReceipt=Import[FileNameJoin[{root,"misc","s35_result","s35_execution.json"}],"RawJSON"];
gate["accepted exact pole summation proof",TrueQ[localFiniteSumReceipt["passed"]]&&
 localFiniteSumReceipt["result_sha256"]["misc/s35_result/s35_result.wl"]===
 IntegerString[FileHash[localFiniteSumProofPath,"SHA256"],16,64]];
localFiniteSumProof=Get[localFiniteSumProofPath];
gate["exact sum proof source and control",localFiniteSumProof["SourceHash"]===FileHash[localFiniteSumPath,"SHA256"]&&
 localFiniteSumProof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
 And@@Values[localFiniteSumProof["Checks"]]&&TrueQ[localFiniteSumProof["PoleCancellationResolved"]]&&
 localFiniteSumProof["OwnValue"]=!=0];
Get[localFiniteSumPath];
localFinitePoleReduce[value_,assumptions_]:=Module[{expression=reduce[value,assumptions]},
 If[FreeQ[expression,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im|_Abs|_Piecewise|_ConditionalExpression|_Sign],
  localFiniteExactSum[expression],expression]];
localFinitePoleOld="reduce[Coefficient[combined,eps,n],assumptions]";
localFinitePoleNew="localFinitePoleReduce[Coefficient[combined,eps,n],assumptions]";
localFinitePoleStart="finitePart[parts_,label_,assumptions_] :=";
localFinitePoleEnd="\ndistributions=";
localFinitePoleText=ReadString[FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}]];
gate["unique original pole simplifier source",StringCount[localFinitePoleText,localFinitePoleStart]===1&&
 StringCount[localFinitePoleText,localFinitePoleEnd]===1];
localFinitePoleDefinition=localFinitePoleStart<>First[StringSplit[
 Last[StringSplit[localFinitePoleText,localFinitePoleStart]],localFinitePoleEnd]];
localFinitePoleDefinition=localFiniteChange[localFinitePoleDefinition,{
 "saved=If[FileExistsQ[file],Get[file],<||>];"->"saved=localFiniteRead[label,file];"}];
localFinitePoleEdits={localFinitePoleOld->localFinitePoleNew,localFiniteGateProof["old"]->localFiniteGateProof["new"]};
localFinitePoleCandidate=localFiniteChange[localFinitePoleDefinition,localFinitePoleEdits];
ToExpression[localFinitePoleCandidate,InputForm];
gate["all original pole and finite gates retained",StringReplace[localFinitePoleCandidate,
 Reverse/@localFinitePoleEdits]===localFinitePoleDefinition];

localFiniteMemoryAssemble[index_]:=Module[{before,value},
 ClearSystemCache[];before=MemoryInUse[];value=assemble[index];ClearSystemCache[];
 Print["FINITE_COMPONENT_MEMORY ",index," before ",before," after ",MemoryInUse[]];value];
hggNativeExport="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
hggNativeExportCandidate="AssociateTo[result,{\"DispatchSourceHash\"->FileHash[hggNativeSource,\"SHA256\"],"<>
 "\"SubtractionResultHash\"->FileHash[hggNativeSubtractionPath,\"SHA256\"],\"FiniteDimensionalSchemeConversionApplied\"->True}];"<>hggNativeExport;
gate["unique native Hgg finite export",StringCount[phaseRunTail,hggNativeExport]===1];
hggNativeFinal=StringReplace[phaseRunTail,hggNativeExport->hggNativeExportCandidate];
gate["all original final Hgg gates retained",SyntaxQ[hggNativeFinal]&&
 StringReplace[hggNativeFinal,hggNativeExportCandidate->hggNativeExport]===phaseRunTail];
localFiniteTailEdits={
 "resultDir=FileNameJoin[{root,channel,\"s14_result\"}];"->"resultDir=FileNameJoin[{root,\"misc\",\"s14_result\"}];",
 hggNativeExport->"AssociateTo[result,<|\"ExecutionBackend\"->\"local\",\"NativeVersions\"->{$Version,$FeynCalcVersion},\"ImportedNativeVersions\"->localFiniteImportedVersions,\"LocalDispatchSourceHash\"->FileHash[localFiniteSource,\"SHA256\"],\"LocalConfigurationHash\"->FileHash[localFiniteConfigPath,\"SHA256\"]|>];"<>hggNativeExport,
 "values=assemble/@indices;"->"values=localFiniteMemoryAssemble/@indices;"};
ToExpression[localFiniteChange[hggNativeFinal,localFiniteTailEdits],InputForm];

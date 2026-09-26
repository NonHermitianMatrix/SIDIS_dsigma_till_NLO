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
"cache=FileNameJoin[{root,\"cache\",\"s14\",channel,IntegerString[inputHash,16]}];"->"cache=FileNameJoin[{root,\"misc\",\"s14_work\",IntegerString[inputHash,16]}];"}];
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
hggNativeExport="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
hggNativeExportCandidate="AssociateTo[result,{\"DispatchSourceHash\"->FileHash[hggNativeSource,\"SHA256\"],"<>
 "\"SubtractionResultHash\"->FileHash[hggNativeSubtractionPath,\"SHA256\"],\"FiniteDimensionalSchemeConversionApplied\"->True}];"<>hggNativeExport;
gate["unique native Hgg finite export",StringCount[phaseRunTail,hggNativeExport]===1];
hggNativeFinal=StringReplace[phaseRunTail,hggNativeExport->hggNativeExportCandidate];
gate["all original final Hgg gates retained",SyntaxQ[hggNativeFinal]&&
 StringReplace[hggNativeFinal,hggNativeExportCandidate->hggNativeExport]===phaseRunTail];
localFiniteTailEdits={
 "resultDir=FileNameJoin[{root,channel,\"s14_result\"}];"->"resultDir=FileNameJoin[{root,\"misc\",\"s14_result\"}];",
 hggNativeExport->"AssociateTo[result,<|\"ExecutionBackend\"->\"local\",\"NativeVersions\"->{$Version,$FeynCalcVersion},\"ImportedNativeVersions\"->localFiniteImportedVersions,\"LocalDispatchSourceHash\"->FileHash[localFiniteSource,\"SHA256\"],\"LocalConfigurationHash\"->FileHash[localFiniteConfigPath,\"SHA256\"]|>];"<>hggNativeExport};
ToExpression[localFiniteChange[hggNativeFinal,localFiniteTailEdits],InputForm];

(* Local runtime for the unchanged Hgg helicity conversion and final F hats. *)
$HistoryLength=0;
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
localFinalRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[localFinalRoot];
localFinalSource=FileNameJoin[{localFinalRoot,"misc","s15_finalize_Hgg_hats.wls"}];
localFinalConfigPath=FileNameJoin[{localFinalRoot,"misc","s15_inputs.json"}];
localFinalConfig=Import[localFinalConfigPath,"RawJSON"];
localFinalRequire[n_,x_]:=If[!TrueQ[x],Print["FAIL: ",n];Quit[1]];
localFinalRequire["bound complete final source",SyntaxQ[ReadString[localFinalSource]]&&
 IntegerString[FileHash[localFinalSource,"SHA256"],16,64]===localFinalConfig["source_sha256"]];
KeyValueMap[Function[{p,h},localFinalRequire["pinned final input "<>p,
 IntegerString[FileHash[FileNameJoin[{localFinalRoot,p}],"SHA256"],16,64]===h]],localFinalConfig["input_sha256"]];
SetEnvironment["POLARIZED_SIDIS_CHANNEL"->"Hgg"];

localNativeWriterPath=FileNameJoin[{localFinalRoot,"misc","s40_chunked_native_record.wls"}];
localNativeWriterReceipt=Import[FileNameJoin[{localFinalRoot,"misc","s40_result","s40_execution.json"}],"RawJSON"];
localNativeWriterChecksPath=FileNameJoin[{localFinalRoot,"misc","s40_result","s40_checks.json"}];
localNativeWriterChecks=Import[localNativeWriterChecksPath,"RawJSON"];
localFinalRequire["accepted complete native storage interface",
 TrueQ[localNativeWriterReceipt["passed"]]&&
 localNativeWriterReceipt["source_sha256"]===IntegerString[FileHash[localNativeWriterPath,"SHA256"],16,64]&&
 localNativeWriterReceipt["result_sha256"]["misc/s40_checks.json"]===
 IntegerString[FileHash[localNativeWriterChecksPath,"SHA256"],16,64]&&
 And@@Values[localNativeWriterChecks["checks"]]&&
 localNativeWriterChecks["native_versions"]==={$Version,FeynCalc`$FeynCalcVersion}];
Get[localNativeWriterPath];

localFinalChange[text_]:=Module[{edits,candidate},edits={localFinalWriterOld->"put[value_, path_] := localChunkWrite[value,path];","gate[\"compute allocation\", StringQ[Environment[\"JOB_ID\"]] && !StringStartsQ[$MachineName, \"login\"]];\ngate[\"isolated runtime\", StringStartsQ[$UserBaseDirectory, root <> \"/\"]];"->"gate[\"authorized local final export\",Environment[\"POLARIZED_SIDIS_LOCAL_AUTHORIZED\"]===\"1\"&&$VersionNumber===15.];",
"inputPaths = {};"->"inputPaths = {localFinalSource,localFinalConfigPath};",
"rawPath = FileNameJoin[{root, channel, \"s14_result\", \"s14_result.wl\"}]; raw = Get[rawPath];"->"rawPath = FileNameJoin[{root,\"misc\",\"s14_result\",\"s14_result.wl\"}]; raw=Get[rawPath];\nlocalFinalImportedVersions=raw[\"ImportedNativeVersions\"];\ngate[\"actual local finite assembly runtime\",raw[\"NativeVersions\"]==={$Version,$FeynCalcVersion}&&\n Last[localFinalImportedVersions]===$FeynCalcVersion];",
"finalAssemblyReceipt=readInput[channel<>\"/s14_result/s14_execution.json\"];"->"finalAssemblyReceipt=readInput[\"misc/s14_result/s14_execution.json\"];",
"finalAssemblyReceipt[\"result_sha256\"][channel<>\"/s14_result/s14_result.wl\"]"->"finalAssemblyReceipt[\"result_sha256\"][\"misc/s14_result/s14_result.wl\"]",
"schemeDirectory = FileNameJoin[{root,channel,\"s15_native_scheme_result\"}];"->"schemeDirectory = FileNameJoin[{root,\"misc\",\"s15_result\",\"scheme\"}];",
"resultDirectory = FileNameJoin[{root, channel, \"s15_result\"}];"->"AssociateTo[result,<|\"ExecutionBackend\"->\"local\",\"NativeVersions\"->{$Version,$FeynCalcVersion},\n \"ImportedNativeVersions\"->localFinalImportedVersions,\"LocalDispatchSourceHash\"->FileHash[localFinalSource,\"SHA256\"],\n \"LocalConfigurationHash\"->FileHash[localFinalConfigPath,\"SHA256\"]|>];\nresultDirectory = FileNameJoin[{root,\"misc\",\"s15_result\"}];"};
 localFinalRequire["unique reviewed final interfaces",And@@(StringCount[text,First[#]]===1&/@edits)];
 candidate=StringReplace[text,edits];localFinalRequire["complete original final implementation preserved",SyntaxQ[candidate]&&
 StringReplace[candidate,Reverse/@edits]===text];candidate];
(* Preserve the final exporter with the accepted Hgg dimensional MS subtraction. *)
$HistoryLength=0;
gluonFinalSource=FileNameJoin[{Directory[],"common","s15_finalize_Hgg_coefficients.wls"}];
gluonCompactSource=FileNameJoin[{Directory[],"common","s15_finalize_spin_coefficients_compact.wls"}];
If[IntegerString[FileHash[gluonCompactSource,"SHA256"],16,64]=!=
  "8f2bb37f8b38701c669a08b9270d290aeb7292ab162f0b66820dea7b8eb3ddc9",Quit[1]];
gluonCompactText=Import[gluonCompactSource,"Text"];
gluonFinalEntry="ToExpression[compactFinalCode,InputForm];";
If[StringCount[gluonCompactText,gluonFinalEntry]=!=1||
  !StringEndsQ[StringTrim[gluonCompactText],gluonFinalEntry]||
  !SyntaxQ[Import[gluonFinalSource,"Text"]],Quit[1]];
gluonCompactPrefix=StringTake[gluonCompactText,
  First[First[StringPosition[gluonCompactText,gluonFinalEntry]]]-1];
localFinalPackageOld="Get[\"FeynCalc`\"]";
localFinalPackageNew="If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]";
localFinalRequire["single inherited package load",StringCount[gluonCompactPrefix,localFinalPackageOld]===1];
localFinalPackagePrefix=StringReplace[gluonCompactPrefix,localFinalPackageOld->localFinalPackageNew];
localFinalRequire["unchanged final builder after package initialization",SyntaxQ[localFinalPackagePrefix]&&
 StringReplace[localFinalPackagePrefix,localFinalPackageNew->localFinalPackageOld]===gluonCompactPrefix];
ToExpression[localFinalPackagePrefix,InputForm];
localFinalWriterOld=Last[SelectFirst[compactFinalReplacements,StringStartsQ[First[#],"put[value_, path_]"]&]];
gluonFinalReplacements={
  "subtraction = readInput[channel <> \"/s11_result/s11_result.wl\"];"->
    "gate[\"own final gluon channel\",channel===\"Hgg\"];subtraction = readInput[channel <> \"/s11_native_result/s11_result.wl\"];gate[\"accepted dimensional MS subtraction\",TrueQ[subtraction[\"AcceptedForProduction\"]]&&TrueQ[subtraction[\"FiniteDimensionalSchemeConversionApplied\"]]];",
  "subtractionSource = FileNameJoin[{root, \"common\", If[core,\n  \"s11_collinear_spin_convolutions.wls\", \"s11_small_collinear_spin.wls\"]}];"->
    "subtractionSource = FileNameJoin[{root,\"common\",\"s11_Hgg_native_routes.wls\"}];",
  "schemeDirectory = FileNameJoin[{root, channel, \"s15_scheme_result\"}];"->
    "previousScheme=readInput[channel<>\"/s15_scheme_result/reference/before_dimensional_completion/s15_result.wl\"];gate[\"same previously accepted helicity conversion\",And@@Values[previousScheme[\"Checks\"]]&&previousScheme[\"SelectedRoutes\"]===scheme[\"SelectedRoutes\"]&&zeroArray[previousScheme[\"RegularCorrection\"]-scheme[\"RegularCorrection\"]]];schemeDirectory = FileNameJoin[{root,channel,\"s15_native_scheme_result\"}];",
  "gate[\"same final photon and spin basis\","->
    "finalAssemblyReceipt=readInput[channel<>\"/s14_result/s14_execution.json\"];gate[\"bound accepted updated finite assembly\",TrueQ[finalAssemblyReceipt[\"passed\"]]&&finalAssemblyReceipt[\"result_sha256\"][channel<>\"/s14_result/s14_result.wl\"]===IntegerString[FileHash[rawPath,\"SHA256\"],16,64]&&raw[\"SubtractionResultHash\"]===FileHash[FileNameJoin[{root,channel,\"s11_native_result\",\"s11_result.wl\"}],\"SHA256\"]&&TrueQ[raw[\"UnpolarizedFinalReferenceComparisonPassed\"]]];gate[\"same final photon and spin basis\",",
  "result = Join["->
    "inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,\"SHA256\"])&/@DeleteDuplicates[inputPaths]];result = Join[",
  "AssociateTo[result,\"DispatchSourceHash\"->FileHash[compactFinalSource,\"SHA256\"]];"->
    "AssociateTo[result,{\"DispatchSourceHash\"->FileHash[gluonFinalSource,\"SHA256\"],\"StorageSourceHash\"->FileHash[compactFinalSource,\"SHA256\"],\"SubtractionResultHash\"->raw[\"SubtractionResultHash\"],\"FiniteDimensionalSchemeConversionApplied\"->True}];"};
If[!And@@(StringCount[compactFinalCode,First[#]]===1&/@gluonFinalReplacements),
  Print["FAIL: unique Hgg final source interfaces"];Quit[1]];
gluonFinalCode=StringReplace[compactFinalCode,gluonFinalReplacements];
If[StringReplace[gluonFinalCode,Reverse/@gluonFinalReplacements]=!=compactFinalCode||
  !SyntaxQ[gluonFinalCode],Print["FAIL: preserved final calculation and syntax"];Quit[1]];
ToExpression[localFinalChange[gluonFinalCode],InputForm];

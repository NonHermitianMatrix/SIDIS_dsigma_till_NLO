(* Local runtime and bounded storage for the unchanged reference real assembly. *)
$HistoryLength=0;
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
localAssemblyRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[localAssemblyRoot];
localAssemblySource=FileNameJoin[{localAssemblyRoot,"misc","s11_assemble_Hgg_real.wls"}];
localAssemblyConfigPath=FileNameJoin[{localAssemblyRoot,"misc","s11_inputs.json"}];
localAssemblyConfig=Import[localAssemblyConfigPath,"RawJSON"];
localAssemblyRequire[n_,x_]:=If[!TrueQ[x],Print["FAIL: ",n];Quit[1]];
localAssemblyRequire["bound complete local assembly source",SyntaxQ[ReadString[localAssemblySource]]&&
 IntegerString[FileHash[localAssemblySource,"SHA256"],16,64]===localAssemblyConfig["source_sha256"]];
KeyValueMap[Function[{p,h},localAssemblyRequire["pinned assembly input "<>p,
 IntegerString[FileHash[FileNameJoin[{localAssemblyRoot,p}],"SHA256"],16,64]===h]],localAssemblyConfig["input_sha256"]];
SetEnvironment["POLARIZED_SIDIS_CHANNEL"->"Hgg"];
localAssemblyBase[text_]:=Module[{edits,changed},edits={"gate[\"compute allocation\",StringQ[Environment[\"JOB_ID\"]]&&!StringStartsQ[$MachineName,\"login\"]];\ngate[\"isolated runtime\",StringStartsQ[$UserBaseDirectory,root<>\"/\"]];"->"gate[\"authorized local assembly\",Environment[\"POLARIZED_SIDIS_LOCAL_AUTHORIZED\"]===\"1\"&&$VersionNumber===15.];",
"mapPath=FileNameJoin[{root,channel,\"s08_result\",\"s08_result.wl\"}];"->"mapPath=FileNameJoin[{root,\"misc\",\"s10_result\",\"s10_result.wl\"}];",
"inputPaths=Join[{configPath,referencePath,mapPath,libraryPath},"->"inputPaths=Join[{configPath,referencePath,mapPath,libraryPath,localAssemblySource,localAssemblyConfigPath,\n FileNameJoin[{root,\"misc\",\"s10_result\",\"s10_execution.json\"}]},",
"cache=FileNameJoin[{root,\"cache\",\"s12\",channel,IntegerString[inputHash,16]}];"->"cache=FileNameJoin[{root,\"misc\",\"s11_work\",\"integrated\",IntegerString[inputHash,16]}];",
"slots=Quiet[Check[ToExpression[Environment[\"NSLOTS\"]],1]];"->"slots=2;",
"\"/u/local/apps/mathematica/13.1/Executables/WolframKernel\""->"\"/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel\"",
"Min[4,slots]"->"Min[2,slots]",
"workers=Length[Kernels[]];"->"workers=Length[Kernels[]];\ngate[\"bounded local assembly workers\",0<=workers<=2];\nIf[workers>0,gate[\"local assembly worker runtime\",And@@(#===$Version&/@ParallelEvaluate[$Version])]];",
"resultDir=FileNameJoin[{root,channel,\"s12_result\"}];"->"resultDir=FileNameJoin[{root,\"misc\",\"s11_result\"}];",
"FileNameJoin[{resultDir,\"s12_result.wl\"}]"->"FileNameJoin[{resultDir,\"s11_result.wl\"}]",
"FileNameJoin[{resultDir,\"s12_checks.json\"}]"->"FileNameJoin[{resultDir,\"s11_checks.json\"}]",
"Print[\"PASS: s12_assemble_real_spin\"];Quit[0];"->"Print[\"PASS: local Hgg real distributions\"];Quit[0];",
"put[value_,file_] := (Put[value,file<>\".tmp\"];RenameFile[file<>\".tmp\",file,OverwriteTarget->True]);"->"put[value_,file_] := Module[{serialized},\n serialized=\"Uncompress[\"<>ToString[bounded[Compress[value],\"native assembly compression\"],InputForm]<>\"]\\n\";\n gate[\"bounded compressed assembly file\",StringLength[serialized]<128*1024^2];\n Export[file<>\".tmp\",serialized,\"Text\"];\n gate[\"exact native assembly reload\",bounded[Get[file<>\".tmp\"]===value,\"native assembly reload\"]];\n RenameFile[file<>\".tmp\",file,OverwriteTarget->True]];"};
 localAssemblyRequire["unique reviewed local assembly interfaces",And@@(StringCount[text,First[#]]===1&/@edits)];
 changed=StringReplace[text,edits];localAssemblyRequire["complete native local assembly syntax",SyntaxQ[changed]];changed];
(* Reuse the executed standalone rational recurrence after an own-input comparison. *)
$HistoryLength = 0;
referenceSeriesPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_factored_series.wls"}];
referenceSeriesBase = FileNameJoin[{Directory[], "common", "s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[referenceSeriesBase, "SHA256"], 16, 64] =!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243", Quit[1]];
referenceSeriesText = localAssemblyBase[Import[referenceSeriesBase, "Text"]];
referenceSeriesBoundary = "\nslots=";
If[StringCount[referenceSeriesText, referenceSeriesBoundary] =!= 1 ||
  !SyntaxQ[Import[referenceSeriesPath, "Text"]], Print["FAIL: complete reference-series source syntax"]; Quit[1]];
referenceSeriesPrefix = First[StringSplit[referenceSeriesText, referenceSeriesBoundary]];
referenceSeriesTail = referenceSeriesBoundary <> Last[StringSplit[referenceSeriesText, referenceSeriesBoundary]];
referenceSeriesOldCall = "terms=KeyValueMap[Function[{m,c},epsilonSeries[(c/.D->4-2eps)regions[\"OrdinaryMasters\"][m],0,\n    \"ordinary cut coefficient\"]],coefficients];\n  ordinary=Total[terms];";
If[StringCount[referenceSeriesPrefix, referenceSeriesOldCall] =!= 1 ||
  StringCount[referenceSeriesPrefix, "Get[\"FeynCalc`\"]"] =!= 1, Quit[1]];
referenceSeriesPrefix = StringReplace[referenceSeriesPrefix, {
  referenceSeriesOldCall -> "ordinary=referenceSeriesOrdinary[component,index];",
  "Get[\"FeynCalc`\"]" -> "If[!MemberQ[$Packages,\"FeynCalc`\"],Get[\"FeynCalc`\"]]"}];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
Null;
If[!SyntaxQ[referenceSeriesPrefix] || !SyntaxQ[referenceSeriesTail], Quit[1]];
ToExpression[referenceSeriesPrefix, InputForm];
localAssemblyImportedVersions=mapped["ImportedNativeVersions"];
gate["actual local master-coefficient runtime",mapped["NativeVersions"]==={$Version,$FeynCalcVersion}&&
 Last[localAssemblyImportedVersions]===$FeynCalcVersion];
localAssemblyReceipt=Import[FileNameJoin[{root,"misc","s10_result","s10_execution.json"}],"RawJSON"];
gate["accepted local master-coefficient receipt",TrueQ[localAssemblyReceipt["passed"]]&&
 localAssemblyReceipt["execution_backend"]==="local"&&
 localAssemblyReceipt["result_sha256"]["misc/s10_result/s10_result.wl"]===IntegerString[FileHash[mapPath,"SHA256"],16,64]];
(* Retain exactly the component fields read by assemble and candidateOrdinary. *)
referenceInputFields = {"Sector", "Kind", "Index", "ReducedCoefficients"};
gate["complete real-assembly component interface", AllTrue[mapped["Components"],
  Function[component, AssociationQ[component] && AllTrue[referenceInputFields, KeyExistsQ[component, #] &]]]];
referenceInputBytes = ByteCount[mapped["Components"]];
referenceInputRecords = KeyTake[#, referenceInputFields] & /@ mapped["Components"];
gate["exact real-assembly consumer values retained", And @@
  (Lookup[referenceInputRecords, #] === Lookup[mapped["Components"], #] & /@ referenceInputFields)];
referenceInputFootprint = <|"OriginalComponentBytes" -> referenceInputBytes,
  "ProjectedComponentBytes" -> ByteCount[referenceInputRecords],
  "ComponentCount" -> Length[referenceInputRecords], "Fields" -> referenceInputFields|>;
AssociateTo[mapped, "Components" -> referenceInputRecords];
Clear[referenceInputRecords]; ClearSystemCache[];
Print["S12_INPUT_PROJECTION ", InputForm[referenceInputFootprint]];
(* Reuse accepted components across the reviewed memory and exact regulator changes. *)
localMemoryManifest=Import[FileNameJoin[{root,"misc","s11_source_changes.json"}],"RawJSON"];
localMemoryResume=localMemoryManifest["memory_resume"];
localMemoryOldSource=FileNameJoin[{root,localMemoryResume["source"]}];
localMemoryOldConfig=FileNameJoin[{root,localMemoryResume["config"]}];
localMemoryReconstructed=ReadString[localMemoryOldSource];
Do[gate["reviewed source edit coverage",StringCount[localMemoryReconstructed,edit["before"]]===edit["count"]];
 localMemoryReconstructed=StringReplace[localMemoryReconstructed,edit["before"]->edit["after"]],
 {edit,Join[localMemoryManifest["memory_changes"],localMemoryManifest["regulator_changes"]]}];
gate["complete reviewed source reconstruction",localMemoryReconstructed===ReadString[localAssemblySource]];
localMemoryOldHashes=ReplacePart[inputHashes,{
 Key[StringDrop[localAssemblySource,StringLength[root]+1]]->FileHash[localMemoryOldSource,"SHA256"],
 Key[StringDrop[localAssemblyConfigPath,StringLength[root]+1]]->FileHash[localMemoryOldConfig,"SHA256"]}];
localMemoryOldHash=Hash[{sourceHash,localMemoryOldHashes,$Version},"SHA256"];
localMemoryOldStudy=Get[FileNameJoin[{root,localMemoryResume["ordinary_comparison"]}]];
gate["complete previous calculation identity retained",TrueQ[localMemoryOldStudy["Accepted"]]&&
 And@@Values[localMemoryOldStudy["Checks"]]&&localMemoryOldStudy["InputHashes"]===localMemoryOldHashes&&
 localMemoryOldStudy["InputHash"]===localMemoryOldHash];
localMemoryReused=Module[{accepted={}},
 KeyValueMap[Function[{relative,expected},Module[{file,idx,saved,reused,target},
  file=FileNameJoin[{root,relative}];
  gate["pinned accepted component cache",IntegerString[FileHash[file,"SHA256"],16,64]===expected&&
   FileNameSplit[DirectoryName[file]]===FileNameSplit[FileNameJoin[{root,"misc","s11_work","integrated",IntegerString[localMemoryOldHash,16]}]]];
  idx=FromDigits[StringDrop[FileBaseName[file],StringLength["component_"]]];
  gate["cached component index in actual map",IntegerQ[idx]&&1<=idx<=Length[mapped["Components"]]];
  saved=Get[file];
  gate["accepted component and unchanged actual input",AssociationQ[saved]&&TrueQ[saved["Accepted"]]&&
   saved["InputHash"]===localMemoryOldHash&&AssociationQ[saved["Checks"]]&&Length[saved["Checks"]]>0&&
   And@@Values[saved["Checks"]]&&KeyTake[saved,{"Sector","Kind","Index"}]===
    KeyTake[mapped["Components"][[idx]],{"Sector","Kind","Index"}]];
  reused=Join[saved,<|"InputHash"->inputHash,"ReusedFromInputHash"->localMemoryOldHash,
    "ReusedFromFileHash"->FileHash[file,"SHA256"]|>];
  gate["entire cached payload preserved",KeyDrop[reused,{"InputHash","ReusedFromInputHash","ReusedFromFileHash"}]===
    KeyDrop[saved,{"InputHash"}]];
  target=FileNameJoin[{cache,FileNameTake[file]}];
  If[FileExistsQ[target],gate["exact existing replay retained",Get[target]===reused],put[reused,target]];
  AppendTo[accepted,idx]]],localMemoryResume["cache_file_sha256"]];
 accepted];
Clear[localMemoryOldStudy,localMemoryReconstructed];ClearSystemCache[];
Print["ACCEPTED_COMPONENTS_REUSED ",Length[localMemoryReused]," ",localMemoryReused];

referenceSeriesParentRelative = "Hqqbar/s12_rational_series_result/s12_result.wl";
referenceSeriesParentPath = FileNameJoin[{root, referenceSeriesParentRelative}];
referenceSeriesReceiptPath = FileNameJoin[{root, "Hqqbar", "s12_rational_series_result", "s12_execution.json"}];
gate["pinned executed reference recurrence and receipt",
  IntegerString[FileHash[referenceSeriesParentPath, "SHA256"], 16, 64] === "0724c147d2349bd44183ecb90936a56d1c7790f7ebd6dade58459cd0c1f8373a" &&
  IntegerString[FileHash[referenceSeriesReceiptPath, "SHA256"], 16, 64] === "406139892f2afcce55da23b0c374078dcc99e52d38166406fa06c7cdc2346874"];
referenceSeriesParent = Get[referenceSeriesParentPath];
referenceSeriesReceipt = Import[referenceSeriesReceiptPath, "RawJSON"];
referenceSeriesComparisonPath = FileNameJoin[{root, "common", "s12_check_rational_master_product.wls"}];
gate["accepted reference recurrence with unchanged equations", TrueQ[referenceSeriesReceipt["passed"]] &&
  referenceSeriesReceipt["result_sha256"][referenceSeriesParentRelative] === IntegerString[FileHash[referenceSeriesParentPath, "SHA256"], 16, 64] &&
  referenceSeriesParent["Schema"] === "polarized-sidis-rational-master-product-comparison-v1" &&
  AssociationQ[referenceSeriesParent["Checks"]] && Length[referenceSeriesParent["Checks"]] > 0 &&
  And @@ Values[referenceSeriesParent["Checks"]] &&
  referenceSeriesParent["SourceHash"] === FileHash[referenceSeriesComparisonPath, "SHA256"] &&
  referenceSeriesParent["ProductionSourceHash"] === sourceHash &&
  referenceSeriesParent["NativeVersions"] === localAssemblyImportedVersions &&
  referenceSeriesParent["OriginalDefinitions"] === {DownValues[epsilonSeries], DownValues[laurentProduct],
    DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint]}];
referenceSeriesStandalonePath = FileNameJoin[{root, "common", "s12_result", "reference", "s12_standalone_rational_series.wls"}];
gate["same standalone reference implementation", referenceSeriesParent["ReferenceSourceHash"] === FileHash[referenceSeriesStandalonePath, "SHA256"]];
Do[gate["same accepted scalar master " <> stage,
  referenceSeriesParent["InputHashes"][library["Library"][stage]["File"]] === inputHashes[library["Library"][stage]["File"]]],
  {stage, {"s08", "s10", "s15"}}];
referenceSeriesComparisonText = Import[referenceSeriesComparisonPath, "Text"];
referenceSeriesPredicateStart = "\nzeroCoefficient[value_] := ";
referenceSeriesPredicateEnd = "\ncheckedRationalSeries[";
gate["unique executed recurrence predicate", StringCount[referenceSeriesComparisonText, referenceSeriesPredicateStart] === 1 &&
  StringCount[referenceSeriesComparisonText, referenceSeriesPredicateEnd] === 1];
referenceSeriesPredicate = referenceSeriesPredicateStart <>
  First[StringSplit[Last[StringSplit[referenceSeriesComparisonText, referenceSeriesPredicateStart]], referenceSeriesPredicateEnd]];
gate["native recurrence predicate syntax", SyntaxQ[referenceSeriesPredicate]];
ToExpression[referenceSeriesPredicate, InputForm];
localArgumentSource=FileNameJoin[{root,"misc","s24_canonical_Hgg_arguments.wls"}];
localArgumentProofPath=FileNameJoin[{root,"misc","s24_result","s24_result.wl"}];
localArgumentReceipt=Import[FileNameJoin[{root,"misc","s24_result","s24_execution.json"}],"RawJSON"];
gate["accepted exact argument comparison receipt",TrueQ[localArgumentReceipt["passed"]]&&
 localArgumentReceipt["source_sha256"]===IntegerString[FileHash[localArgumentSource,"SHA256"],16,64]&&
 localArgumentReceipt["result_sha256"]["misc/s24_result/s24_result.wl"]===IntegerString[FileHash[localArgumentProofPath,"SHA256"],16,64]];
localArgumentProof=Get[localArgumentProofPath];
Get[localArgumentSource];
gate["exact executed argument normalization installed",TrueQ[localArgumentProof["Accepted"]]&&
 And@@Values[localArgumentProof["Checks"]]&&localArgumentProof["RetainedResidual"]===0&&
 localArgumentProof["SourceHash"]===FileHash[localArgumentSource,"SHA256"]&&
 DownValues[localCanonicalScalarArguments]===localArgumentProof["Definitions"]];
zeroCoefficient[value_]:=Factor[Together[localCanonicalScalarArguments[value]]]===0;
DownValues[rationalSeries] = referenceSeriesParent["RationalDefinitions"];
DownValues[checkedRationalSeries] = referenceSeriesParent["CheckedRationalDefinitions"];
DownValues[ordinaryMasterProduct] = referenceSeriesParent["ProductDefinitions"];
DownValues[candidateOrdinary] = referenceSeriesParent["CandidateDefinitions"];
gate["exact executed recurrence definitions installed",
  DownValues[rationalSeries] === referenceSeriesParent["RationalDefinitions"] &&
  DownValues[checkedRationalSeries] === referenceSeriesParent["CheckedRationalDefinitions"] &&
  DownValues[ordinaryMasterProduct] === referenceSeriesParent["ProductDefinitions"] &&
  DownValues[candidateOrdinary] === referenceSeriesParent["CandidateDefinitions"]];
(* The recurrence is unchanged. Compare and return the product at its requested order. *)
productOriginalDefinitions = DownValues[ordinaryMasterProduct];
productStart = "\nordinaryMasterProduct[";
productEnd = "\ncandidateOrdinary[";
gate["unique complete reference product definition", StringCount[referenceSeriesComparisonText, productStart] === 1 &&
  StringCount[referenceSeriesComparisonText, productEnd] === 1];
productText = productStart <> First[StringSplit[Last[StringSplit[referenceSeriesComparisonText, productStart]], productEnd]];
productOldTail = "  If[!TrueQ[productIdentity], Print[\"MASTER_PRODUCT_RESIDUAL \", StringTake[ToString[residual, InputForm], UpTo[4000]]]];\n  gate[\"complete product matches native polynomial Series\", productIdentity];\n  answer];";
productNewTail = "  gate[\"product agrees through requested regulator order\", TrueQ[productIdentity] || bounded[zeroCoefficient[Normal[Series[residual,{eps,0,order}]]],\"retained product comparison\"]];\n  If[!TrueQ[productIdentity],Print[\"MASTER_PRODUCT_TRUNCATED \",description,\" first_discarded_power \",Exponent[residual,eps,Min],\" requested_order \",order]];\n  gate[\"native product contains no higher regulator powers\", direct===0 || Exponent[Expand[direct,eps],eps]<=order];\n  direct];";
gate["single bounded product correction", StringCount[productText, productOldTail] === 1];
productCorrectedText = StringReplace[productText, productOldTail -> productNewTail];
gate["complete product correction syntax and reversible source", SyntaxQ[productCorrectedText] &&
  StringReplace[productCorrectedText, productNewTail -> productOldTail] === productText];
ToExpression[productCorrectedText, InputForm];

localRegulatorSource=FileNameJoin[{root,"misc","s29_exact_Hgg_regulator_series.wls"}];
localRegulatorProofPath=FileNameJoin[{root,"misc","s29_result","s29_result.wl"}];
localRegulatorReceipt=Import[FileNameJoin[{root,"misc","s29_result","s29_execution.json"}],"RawJSON"];
gate["accepted exact regulator recurrence receipt",TrueQ[localRegulatorReceipt["passed"]]&&
 localRegulatorReceipt["source_sha256"]===IntegerString[FileHash[localRegulatorSource,"SHA256"],16,64]&&
 localRegulatorReceipt["result_sha256"]["misc/s29_result/s29_result.wl"]===
  IntegerString[FileHash[localRegulatorProofPath,"SHA256"],16,64]];
localRegulatorProof=Get[localRegulatorProofPath];
gate["same complete input recurrence and master product",TrueQ[localRegulatorProof["Accepted"]]&&
 And@@Values[localRegulatorProof["Checks"]]&&localRegulatorProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&
 localRegulatorProof["OriginalCheckedDefinitions"]===DownValues[checkedRationalSeries]&&
 localRegulatorProof["OriginalProductDefinitions"]===DownValues[ordinaryMasterProduct]];
Get[localRegulatorSource];
gate["exact executed polynomial recurrence helper",DownValues[localExactRegulatorSeries]===localRegulatorProof["Definitions"]];
DownValues[checkedRationalSeries]=localRegulatorProof["CheckedDefinitions"];
DownValues[ordinaryMasterProduct]=localRegulatorProof["ProductDefinitions"];
gate["validated recurrence and master product installed",
 DownValues[checkedRationalSeries]===localRegulatorProof["CheckedDefinitions"]&&
 DownValues[ordinaryMasterProduct]===localRegulatorProof["ProductDefinitions"]];
recoilProofRelative = "Hqqbar/s12_recoil_factorization_result/s12_result.wl";
recoilProofPath = FileNameJoin[{root, recoilProofRelative}];
recoilReceiptPath = FileNameJoin[{DirectoryName[recoilProofPath], "s12_execution.json"}];
recoilProof = Get[recoilProofPath]; recoilReceipt = Import[recoilReceiptPath,"RawJSON"];
gate["accepted reference factorization definitions", TrueQ[recoilReceipt["passed"]] &&
  recoilReceipt["result_sha256"][recoilProofRelative] === IntegerString[FileHash[recoilProofPath,"SHA256"],16,64] &&
  recoilProof["Schema"] === "polarized-sidis-recoil-factorization-comparison-v1" &&
  recoilProof["SourceHash"] === FileHash[FileNameJoin[{root,"common","s12_check_recoil_factorization.wls"}],"SHA256"] &&
  And@@Values[recoilProof["Checks"]] && recoilProof["ProductionSourceHash"] === sourceHash &&
  recoilProof["NativeVersions"] === localAssemblyImportedVersions &&
  First[recoilProof["OriginalDefinitions"]] === DownValues[softRows]];
DownValues[recoilData] = recoilProof["HelperDefinitions"];
DownValues[softRows] = recoilProof["RowDefinitions"];
gate["exact reference endpoint factorization installed", DownValues[recoilData] === recoilProof["HelperDefinitions"] &&
  DownValues[softRows] === recoilProof["RowDefinitions"]];

referenceSeriesControlCode = "referenceOriginalOrdinary[component_] := Module[{coefficients,terms,ordinary},\n" <>
  "coefficients=Select[component[\"ReducedCoefficients\"],#=!=0&]/.transverseRule;\n" <>
  referenceSeriesOldCall <> "\nordinary];";
gate["original ordinary coefficient calculation syntax", SyntaxQ[referenceSeriesControlCode]];
ToExpression[referenceSeriesControlCode, InputForm];
referenceSeriesIndices = Select[Range[Length[mapped["Components"]]],
  AnyTrue[Values[mapped["Components"][[#]]["ReducedCoefficients"]], # =!= 0 &] &];
gate["own nonzero ordinary control available", referenceSeriesIndices =!= {}];
referenceSeriesControlIndex = First[MinimalBy[referenceSeriesIndices,
  ByteCount[mapped["Components"][[#]]["ReducedCoefficients"]] &]];
referenceSeriesControl = mapped["Components"][[referenceSeriesControlIndex]];
referenceSeriesControlHash = Hash[referenceSeriesControl, "SHA256"];
referenceSeriesStudyDirectory = FileNameJoin[{root, "misc", "s11_result", "own_reference"}];
If[!DirectoryQ[referenceSeriesStudyDirectory], CreateDirectory[referenceSeriesStudyDirectory, CreateIntermediateDirectories -> True]];
referenceSeriesStudyPath = FileNameJoin[{referenceSeriesStudyDirectory, "s12_result.wl"}];
referenceSeriesStudy = If[FileExistsQ[referenceSeriesStudyPath], Get[referenceSeriesStudyPath], <||>];
referenceSeriesBinding = Hash[{FileHash[referenceSeriesPath, "SHA256"], inputHash,
  FileHash[referenceSeriesParentPath, "SHA256"], referenceSeriesControlHash, $Version, $FeynCalcVersion}, "SHA256"];
If[Lookup[referenceSeriesStudy, "Binding", None] === referenceSeriesBinding &&
  TrueQ[Lookup[referenceSeriesStudy, "Accepted", False]] && AssociationQ[Lookup[referenceSeriesStudy, "Checks", None]] &&
  Length[referenceSeriesStudy["Checks"]] > 0 && And @@ Values[referenceSeriesStudy["Checks"]],
  referenceSeriesControlValue = referenceSeriesStudy["CandidateValue"],
  Print["OWN_REFERENCE_SERIES_CONTROL ", channel, " component ", referenceSeriesControlIndex,
    " input_bytes ", ByteCount[referenceSeriesControl["ReducedCoefficients"]]];
  ClearSystemCache[];
  referenceSeriesOriginalPath=FileNameJoin[{referenceSeriesStudyDirectory,"s12_original_ordinary.wl"}];
  referenceSeriesOriginalBinding=Hash[{referenceSeriesControl,transverseRule,regions["OrdinaryMasters"],
    DownValues[epsilonSeries],$Version,$FeynCalcVersion,$Assumptions},"SHA256"];
  referenceSeriesOriginalPacket=If[FileExistsQ[referenceSeriesOriginalPath],Get[referenceSeriesOriginalPath],<||>];
  If[Lookup[referenceSeriesOriginalPacket,"Binding",None]===referenceSeriesOriginalBinding&&
     KeyExistsQ[referenceSeriesOriginalPacket,"Value"]&&
     Lookup[referenceSeriesOriginalPacket,"ValueHash",None]===Hash[referenceSeriesOriginalPacket["Value"],"SHA256"],
    referenceSeriesOriginalValue=referenceSeriesOriginalPacket["Value"];referenceSeriesOriginalSeconds=0;
    gate["exact saved original ordinary reused",True],
    {referenceSeriesOriginalSeconds, referenceSeriesOriginalValue} = AbsoluteTiming[referenceOriginalOrdinary[referenceSeriesControl]];
    gate["original ordinary control fully evaluated",FreeQ[referenceSeriesOriginalValue,
     _CutIntegral|_SeriesData|_Series|_Integrate|_Missing|_Real|$Failed|$Aborted]];
    referenceSeriesOriginalPacket=<|"Binding"->referenceSeriesOriginalBinding,
     "Value"->referenceSeriesOriginalValue,"ValueHash"->Hash[referenceSeriesOriginalValue,"SHA256"],
     "Seconds"->referenceSeriesOriginalSeconds,"NativeVersions"->{$Version,$FeynCalcVersion}|>;
    put[referenceSeriesOriginalPacket,referenceSeriesOriginalPath]];
  ClearSystemCache[];
  {referenceSeriesCandidateSeconds, referenceSeriesControlValue} = AbsoluteTiming[candidateOrdinary[referenceSeriesControl, referenceSeriesControlIndex]];
  gate["own complete original ordinary contribution reproduced", bounded[
    zeroCoefficient[Expand[referenceSeriesControlValue - referenceSeriesOriginalValue, eps]], "own ordinary reference comparison"]];
  referenceSeriesStudy = <|"Schema" -> "polarized-sidis-own-reference-series-v1", "Channel" -> channel,
    "Binding" -> referenceSeriesBinding, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
    "SourceHash" -> FileHash[referenceSeriesPath, "SHA256"], "ParentProofHash" -> FileHash[referenceSeriesParentPath, "SHA256"],
    "ControlIndex" -> referenceSeriesControlIndex, "ControlHash" -> referenceSeriesControlHash,
    "ControlCoefficients" -> referenceSeriesControl["ReducedCoefficients"], "CandidateValue" -> referenceSeriesControlValue,
    "InputProjectionFootprint" -> referenceInputFootprint,
    "OriginalValue" -> referenceSeriesOriginalValue, "OriginalSeconds" -> referenceSeriesOriginalSeconds,
    "CandidateSeconds" -> referenceSeriesCandidateSeconds, "NativeVersions" -> {$Version, $FeynCalcVersion},
    "Checks" -> checks, "Accepted" -> True, "FiniteNLOFHatsComputed" -> False|>;
  referenceSeriesSerialized = "Uncompress[" <> ToString[Compress[referenceSeriesStudy], InputForm] <> "]\n";
  gate["bounded own recurrence comparison output", StringLength[referenceSeriesSerialized] < 128*1024^2];
  Export[referenceSeriesStudyPath <> ".tmp", referenceSeriesSerialized, "Text"];
  gate["exact own recurrence comparison reload", Get[referenceSeriesStudyPath <> ".tmp"] === referenceSeriesStudy];
  RenameFile[referenceSeriesStudyPath <> ".tmp", referenceSeriesStudyPath, OverwriteTarget -> True]];
gate["own reference recurrence comparison accepted", TrueQ[referenceSeriesStudy["Accepted"]] &&
  TrueQ[referenceSeriesStudy["Checks"]["own complete original ordinary contribution reproduced"]]];
Print["OWN_REFERENCE_SERIES_ACCEPTED ", channel, " ", InputForm[KeyTake[referenceSeriesStudy,
  {"ControlIndex", "OriginalSeconds", "CandidateSeconds"}]]];
referenceSeriesOrdinary[component_, index_] := If[index === referenceSeriesControlIndex,
  gate["reused own ordinary coefficient exact task", Hash[component, "SHA256"] === referenceSeriesControlHash];
  referenceSeriesControlValue, candidateOrdinary[component, index]];
(* Component-specific recoil memos are discarded after each unchanged assembly call. *)
localRecoilDefinitions=recoilProof["HelperDefinitions"];
gate["only general recoil definition retained",AllTrue[localRecoilDefinitions,!FreeQ[First[#],_Pattern]&]];
localMemoryAssemble[component_,index_]:=Module[
 {value,beforeDefinitions=DownValues[recoilData],beforeMemory=MemoryInUse[],memoBytes},
 value=Block[{recoilData},
  DownValues[recoilData]=localRecoilDefinitions;
  With[{answer=assemble[component,index]},memoBytes=ByteCount[DownValues[recoilData]];answer]];
 gate["component recoil definitions restored",DownValues[recoilData]===beforeDefinitions];
 ClearSystemCache[];
 Print["COMPONENT_MEMORY ",index," temporary_memo_bytes ",memoBytes,
  " memory_before ",beforeMemory," memory_after ",MemoryInUse[]];
 value];

(* Compare the complete smallest nonzero own component before remaining integration. *)
factoredControlIndex=referenceSeriesControlIndex;
factoredTask=mapped["Components"][[factoredControlIndex]];
factoredControlBinding=Hash[{FileHash[referenceSeriesPath,"SHA256"],inputHash,Hash[factoredTask,"SHA256"],
  FileHash[recoilProofPath,"SHA256"],$Version,$FeynCalcVersion},"SHA256"];
factoredControlRoot=FileNameJoin[{root,"misc","s11_work","controls",IntegerString[factoredControlBinding,16]}];
factoredOriginalCache=FileNameJoin[{factoredControlRoot,"original"}];
factoredCandidateCache=FileNameJoin[{factoredControlRoot,"candidate"}];
Do[If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]],
  {directory,{factoredOriginalCache,factoredCandidateCache}}];
factoredCanonicalPath=FileNameJoin[{cache,"component_"<>IntegerString[factoredControlIndex,10,4]<>".wl"}];
If[FileExistsQ[factoredCanonicalPath],
  factoredControl=Get[factoredCanonicalPath];factoredOriginalSeconds=0,
  Print["OWN_ORIGINAL_ENDPOINT_CONTROL ",channel," ",factoredControlIndex];
  {factoredOriginalSeconds,factoredControl}=AbsoluteTiming[Block[{cache=factoredOriginalCache,softRows,referenceSeriesOrdinary},
    DownValues[softRows]=referenceSeriesParent["OriginalDefinitions"][[3]];
    referenceSeriesOrdinary[component_,index_]:=(
      gate["original endpoint reuses exact own ordinary input",Hash[component,"SHA256"]===referenceSeriesControlHash];
      referenceSeriesStudy["OriginalValue"]);
    assemble[factoredTask,factoredControlIndex]]]];
gate["accepted own complete original control",AssociationQ[factoredControl] && TrueQ[factoredControl["Accepted"]] &&
  factoredControl["InputHash"]===inputHash && And@@Values[factoredControl["Checks"]] &&
  KeyTake[factoredControl,{"Sector","Kind","Index"}]===KeyTake[factoredTask,{"Sector","Kind","Index"}]];
factoredProofPath=FileNameJoin[{referenceSeriesStudyDirectory,"s12_endpoint_comparison.wl"}];
factoredProof=If[FileExistsQ[factoredProofPath],Get[factoredProofPath],<||>];
If[Lookup[factoredProof,"Binding",None]=!=factoredControlBinding || !TrueQ[Lookup[factoredProof,"Accepted",False]],
  {factoredControlSeconds,factoredControlValue}=AbsoluteTiming[Block[{cache=factoredCandidateCache},localMemoryAssemble[factoredTask,factoredControlIndex]]];
  gate["own factored full component accepted",AssociationQ[factoredControlValue] && TrueQ[factoredControlValue["Accepted"]] &&
    And@@Values[factoredControlValue["Checks"]]];
  gate["own complete ordinary unchanged",bounded[zeroCoefficient[factoredControlValue["Ordinary"]-factoredControl["Ordinary"]],"ordinary control"]];
  Do[
    gate["own complete branch assumptions unchanged",factoredControlValue["Branches"][sign]["Assumptions"]===factoredControl["Branches"][sign]["Assumptions"]];
    Do[gate["own complete branch "<>ToString[{sign,key}],bounded[zeroCoefficient[
      factoredControlValue["Branches"][sign][key]-factoredControl["Branches"][sign][key]],"endpoint own comparison"]],{key,{"Delta","L0","L1","Regular"}}];
    factoredRows=factoredControlValue["Branches"][sign]["SoftCoefficients"];
    originalRows=factoredControl["Branches"][sign]["SoftCoefficients"];
    gate["own soft support unchanged",Length[factoredRows]===Length[originalRows] && (Take[#,2]&/@factoredRows)===(Take[#,2]&/@originalRows)];
    gate["own soft coefficients unchanged",And@@MapThread[bounded[zeroCoefficient[Last[#1]-Last[#2]],"own soft comparison"]&,{factoredRows,originalRows}]],
    {sign,{1,-1}}];
  factoredProof=<|"Schema"->"polarized-sidis-factored-input-comparison-v1","Channel"->channel,"Binding"->factoredControlBinding,
    "SourceHash"->FileHash[referenceSeriesPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
    "RecoilProofHash"->FileHash[recoilProofPath,"SHA256"],"ControlIndex"->factoredControlIndex,"ControlTaskHash"->Hash[factoredTask,"SHA256"],
    "OriginalControl"->factoredControl,"CompleteControl"->factoredControlValue,"OriginalSeconds"->factoredOriginalSeconds,
    "ControlSeconds"->factoredControlSeconds,"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True|>;
  factoredSerialized="Uncompress["<>ToString[Compress[factoredProof],InputForm]<>"]\n";
  gate["bounded factored comparison output",StringLength[factoredSerialized]<128*1024^2];
  Export[factoredProofPath<>".tmp",factoredSerialized,"Text"];
  gate["exact factored comparison reload",Get[factoredProofPath<>".tmp"]===factoredProof];
  RenameFile[factoredProofPath<>".tmp",factoredProofPath,OverwriteTarget->True]];
gate["complete own factored-input comparison accepted",TrueQ[factoredProof["Accepted"]] &&
  factoredProof["Binding"]===factoredControlBinding && factoredProof["ControlTaskHash"]===Hash[factoredTask,"SHA256"] &&
  And@@Values[factoredProof["Checks"]]];
If[!FileExistsQ[factoredCanonicalPath],put[factoredProof["CompleteControl"],factoredCanonicalPath];
  gate["exact accepted own control reused",Get[factoredCanonicalPath]===factoredProof["CompleteControl"]]];
Print["OWN_FACTORED_INPUTS_ACCEPTED ",channel," ",InputForm[KeyTake[factoredProof,{"ControlIndex","OriginalSeconds","ControlSeconds"}]]];

referenceSeriesDistribute = "DistributeDefinitions[gate,put,bounded,branchAssumptions,reduce,epsilonSeries,laurentProduct,";
referenceSeriesOutput = "put[result,FileNameJoin[{resultDir,\"s11_result.wl\"}]];";
referenceSeriesChanges = {
  referenceSeriesDistribute -> (referenceSeriesDistribute <>
    "localExactRegulatorSeries,localSeriesRoot,localSeriesSource,recoilData,localRecoilDefinitions,localMemoryAssemble,rationalSeries,checkedRationalSeries,ordinaryMasterProduct,candidateOrdinary,zeroCoefficient,localCanonicalScalarArguments,referenceSeriesOrdinary,referenceSeriesControlIndex,referenceSeriesControlHash,referenceSeriesControlValue,"),
  referenceSeriesOutput -> ("AssociateTo[result,{\"ReferenceSeriesSourceHash\"->FileHash[referenceSeriesPath,\"SHA256\"],\"OwnReferenceSeriesComparisonHash\"->FileHash[referenceSeriesStudyPath,\"SHA256\"],\"InputProjectionFootprint\"->referenceInputFootprint,\"FactoredInputComparisonHash\"->FileHash[factoredProofPath,\"SHA256\"]}];\n" <> referenceSeriesOutput)};
gate["unique unchanged integration worker and output interfaces", And @@ (StringCount[referenceSeriesTail, First[#]] === 1 & /@ referenceSeriesChanges)];
referenceSeriesRunTail = StringReplace[referenceSeriesTail, referenceSeriesChanges];
gate["complete original integration tail retained", StringReplace[referenceSeriesRunTail, Reverse /@ referenceSeriesChanges] === referenceSeriesTail && SyntaxQ[referenceSeriesRunTail]];
localAssemblyProvenance="AssociateTo[result,<|\"ExecutionBackend\"->\"local\",\"NativeVersions\"->{$Version,$FeynCalcVersion},\"ImportedNativeVersions\"->localAssemblyImportedVersions,\"LocalDispatchSourceHash\"->FileHash[localAssemblySource,\"SHA256\"],\"LocalConfigurationHash\"->FileHash[localAssemblyConfigPath,\"SHA256\"]|>];\n";
gate["unique local assembly export",StringCount[referenceSeriesRunTail,referenceSeriesOutput]===1];
localAssemblyRunTail=StringReplace[referenceSeriesRunTail,referenceSeriesOutput->localAssemblyProvenance<>referenceSeriesOutput];
gate["unchanged complete integration tail after provenance",SyntaxQ[localAssemblyRunTail]&&
 StringReplace[localAssemblyRunTail,localAssemblyProvenance<>referenceSeriesOutput->referenceSeriesOutput]===referenceSeriesRunTail];
localUnscopedRunTail=localAssemblyRunTail;
gate["complete worker task-call coverage",StringCount[localUnscopedRunTail,"assemble@@#&"]===2];
localAssemblyRunTail=StringReplace[localUnscopedRunTail,"assemble@@#&"->"localMemoryAssemble@@#&"];
gate["only task memory scope changed",SyntaxQ[localAssemblyRunTail]&&
 StringReplace[localAssemblyRunTail,"localMemoryAssemble@@#&"->"assemble@@#&"]===localUnscopedRunTail];
ToExpression[localAssemblyRunTail, InputForm];

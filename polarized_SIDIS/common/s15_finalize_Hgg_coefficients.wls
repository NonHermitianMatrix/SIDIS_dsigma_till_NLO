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
If[!SyntaxQ[gluonCompactPrefix],Quit[1]];ToExpression[gluonCompactPrefix,InputForm];
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
ToExpression[gluonFinalCode,InputForm];

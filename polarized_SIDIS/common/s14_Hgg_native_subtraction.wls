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
 new="phaseRunPrefix=hggNativeAdapt[phaseRunPrefix];"<>old;
 If[StringCount[text,old]=!=1,Print["FAIL: unique native assembly prefix handoff"];Quit[1]];
 candidate=StringReplace[text,old->new];
 If[!SyntaxQ[candidate]||StringReplace[candidate,new->old]=!=text,Quit[1]];candidate];
hggNativeText=StringTrim[Import[hggNativeBase,"Text"]];hggNativeTerminal="ToExpression[phaseRunTail,InputForm];";
If[!StringEndsQ[hggNativeText,hggNativeTerminal],Quit[1]];
hggNativePrefix=StringDrop[hggNativeText,-StringLength[hggNativeTerminal]];
hggNativeEntry="ToExpression[compactAssemblyInitialization,InputForm];";
hggNativeChangedEntry="compactAssemblyInitialization=hggNativeInitialization[compactAssemblyInitialization];"<>hggNativeEntry;
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
ToExpression[hggNativeFinal,InputForm];

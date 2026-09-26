(* Use the accepted own regulator-only Laurent product in unchanged finite assembly. *)
$HistoryLength=0;
finiteRegulatorSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_regulator_phase.wls"}];
finiteRegulatorParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
If[IntegerString[FileHash[finiteRegulatorParent,"SHA256"],16,64]=!=
 "0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b"||
 !SyntaxQ[Import[finiteRegulatorSource,"Text"]],Quit[1]];
finiteRegulatorText=StringTrim[Import[finiteRegulatorParent,"Text"]];
finiteRegulatorTerminal="ToExpression[cachedPartsRun,InputForm];";
If[!StringEndsQ[finiteRegulatorText,finiteRegulatorTerminal],Quit[1]];
finiteRegulatorPrefix=StringDrop[finiteRegulatorText,-StringLength[finiteRegulatorTerminal]];
If[!SyntaxQ[finiteRegulatorPrefix],Quit[1]];ToExpression[finiteRegulatorPrefix,InputForm];
finiteRegulatorInstall[] := Module[{path,receipt,proof,anchor,replacement,old},
 path=FileNameJoin[{root,channel,"s14_regulator_phase_result","s14_result.wl"}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s14_execution.json"}],"RawJSON"];
 gate["accepted own regulator phase receipt",TrueQ[receipt["passed"]]&&
   receipt["result_sha256"][channel<>"/s14_regulator_phase_result/s14_result.wl"]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["exact own regulator phase comparison and original equations",proof["Schema"]==="polarized-sidis-regulator-phase-comparison-v1"&&
   proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
   And@@(#===0&/@Values[proof["Residuals"]])&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
   proof["InputHash"]===inputHash&&proof["InputHashes"]===inputHashes&&
   proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_regulator_phase.wls"}],"SHA256"]&&
   proof["ParentHash"]===FileHash[finiteRegulatorParent,"SHA256"]&&
   proof["OriginalDefinitions"]===DownValues[laurentProduct]];
 DownValues[laurentProduct]=proof["CandidateDefinitions"]/.regulatorLaurentProduct->laurentProduct;
 gate["exact accepted regulator product installed",DownValues[laurentProduct]===
   (proof["CandidateDefinitions"]/.regulatorLaurentProduct->laurentProduct)];
 finiteRegulatorEvidence=<|"SourceHash"->FileHash[finiteRegulatorSource,"SHA256"],"ComparisonHash"->FileHash[path,"SHA256"],
   "Control"->proof["Control"],"OriginalSeconds"->proof["OriginalSeconds"],"CandidateSeconds"->proof["CandidateSeconds"]|>;
 Print["S14_REGULATOR_PHASE_INSTALLED ",InputForm[finiteRegulatorEvidence]];
 anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
 replacement="AssociateTo[result,\"RegulatorPhaseComparison\"->finiteRegulatorEvidence];"<>anchor;
 gate["unique regulator phase evidence export",StringCount[phaseRunTail,anchor]===1];
 old=phaseRunTail;phaseRunTail=StringReplace[old,anchor->replacement];
 gate["unchanged complete finite acceptance gates",SyntaxQ[phaseRunTail]&&StringReplace[phaseRunTail,replacement->anchor]===old]];
finiteRegulatorAnchor="cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
finiteRegulatorReplacement="cachedPartsRecord[];finiteRegulatorInstall[];ToExpression[phaseRunTail,InputForm];";
If[StringCount[cachedPartsRun,finiteRegulatorAnchor]=!=1,Print["FAIL: unique regulator phase installation"];Quit[1]];
finiteRegulatorRun=StringReplace[cachedPartsRun,finiteRegulatorAnchor->finiteRegulatorReplacement];
If[!SyntaxQ[finiteRegulatorRun]||StringReplace[finiteRegulatorRun,finiteRegulatorReplacement->finiteRegulatorAnchor]=!=cachedPartsRun,Quit[1]];
ToExpression[finiteRegulatorRun,InputForm];

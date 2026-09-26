(* Resume unchanged Hgg coefficients with accepted compact reconstruction checks. *)
$HistoryLength=0;
compactResumeSource=FileNameJoin[{Directory[],"common","s08_resume_Hgg_compact_groups.wls"}];
compactResumeBase=FileNameJoin[{Directory[],"common","s08_map_Hgg_certified_inputs.wls"}];
If[!SyntaxQ[Import[compactResumeSource,"Text"]]||IntegerString[FileHash[compactResumeBase,"SHA256"],16,64]=!=
 "27b5d28bff24828735784d339403c52888513c4d4b54c11e36a5ca66b5d1774f",Quit[1]];
compactResumeInstall[]:=Module[{relative,path,receipt,proof,old,new,original,candidate},
 relative="Hgg/s08_compact_groups_result/s08_result.wl";path=FileNameJoin[{root,relative}];
 receipt=Import[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"RawJSON"];
 gate["accepted compact grouping execution",TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];old={DownValues[hggOriginalGrouping],DownValues[groupedMapExpression]};
 gate["same complete compact grouping contract",proof["Schema"]==="polarized-sidis-compact-grouping-v1"&&proof["Channel"]===channel&&
  proof["InputHashes"]===inputHashes&&proof["TargetInputHash"]===targetInputHash&&proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  TrueQ[proof["OwnAcceptedComparison"]]&&Length[proof["Checks"]]>0&&And@@Values[proof["Checks"]]&&
 
  proof["BaseHash"]===FileHash[compactResumeBase,"SHA256"]&&proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s08_map_Hgg_compact_groups.wls"}],"SHA256"]&&
  proof["ActualEquationReceiptHash"]===FileHash[FileNameJoin[{root,"Hgg","s08_blocked_equations_result","s08_execution.json"}],"SHA256"]];
 gate["actual failed-input comparisons complete",Lookup[proof["ActualMeasurements"],"Component"]==={12,13}&&
  AllTrue[proof["ActualMeasurements"],IntegerQ[#["GroupCount"]]&&#["GroupCount"]>0&]];
 original=proof["OriginalDefinitions"];candidate=proof["CandidateDefinitions"];
 gate["two complete saved compact definitions",ListQ[original]&&ListQ[candidate]&&Length[original]===Length[old]&&Length[candidate]===Length[old]];
 gate["saved comparisons use the original scalar entry",FreeQ[{original,candidate},polynomialPieceMap]&&
  Count[original,_mapExpression,Infinity]===1&&Count[candidate,_mapExpression,Infinity]===1];
 new=candidate/.mapExpression->polynomialPieceMap;
 gate["exact inherited polynomial dispatch preserved",(original/.mapExpression->polynomialPieceMap)===old&&
  (old/.polynomialPieceMap->mapExpression)===original&&(new/.polynomialPieceMap->mapExpression)===candidate];
 DownValues[hggOriginalGrouping]=new[[1]];DownValues[groupedMapExpression]=new[[2]];
 gate["exact accepted compact definitions installed",{DownValues[hggOriginalGrouping],DownValues[groupedMapExpression]}===new];
 AssociateTo[hggPolynomialEvidence,"CompactGrouping"-><|"ConsumerSourceHash"->FileHash[compactResumeSource,"SHA256"],
  "ProofHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{DirectoryName[path],"s08_execution.json"}],"SHA256"],
  "OwnAcceptedComparison"->True,"ActualMeasurements"->proof["ActualMeasurements"]|>]];
compactResumeText=StringTrim[Import[compactResumeBase,"Text"]];compactResumeTerminal="ToExpression[hggPolynomialRun,InputForm];";
If[!StringEndsQ[compactResumeText,compactResumeTerminal],Quit[1]];
compactResumePrefix=StringDrop[compactResumeText,-StringLength[compactResumeTerminal]];
If[!SyntaxQ[compactResumePrefix],Quit[1]];ToExpression[compactResumePrefix,InputForm];
compactResumeOld="hggPolynomialInstall[];";compactResumeNew="hggPolynomialInstall[];compactResumeInstall[];";
If[StringCount[hggPolynomialRun,compactResumeOld]=!=1,Print["FAIL: unique compact grouping installation"];Quit[1]];
compactResumeRun=StringReplace[hggPolynomialRun,compactResumeOld->compactResumeNew];
If[!SyntaxQ[compactResumeRun]||StringReplace[compactResumeRun,compactResumeNew->compactResumeOld]=!=hggPolynomialRun,
 Print["FAIL: unchanged full Hgg production contract"];Quit[1]];
ToExpression[compactResumeRun,InputForm];

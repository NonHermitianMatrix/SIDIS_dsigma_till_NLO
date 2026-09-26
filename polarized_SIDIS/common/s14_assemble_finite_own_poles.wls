(* Use the accepted own-channel residual comparison in the existing finite assembly. *)
$HistoryLength=0;
finiteOwnPoleSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_own_poles.wls"}];
finiteOwnPoleParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_structural.wls"}];
If[IntegerString[FileHash[finiteOwnPoleParent,"SHA256"],16,64]=!=
 "e3a9701903914e7c3164b614255cc6e01c2a63cbe8eac1be8762bd52185266b3",Quit[1]];
finiteOwnPoleText=StringTrim[Import[finiteOwnPoleParent,"Text"]];
finiteOwnPoleTerminal="ToExpression[finiteStructuralRun,InputForm];";
If[!StringEndsQ[finiteOwnPoleText,finiteOwnPoleTerminal]||!SyntaxQ[Import[finiteOwnPoleSource,"Text"]],Quit[1]];
finiteOwnPolePrefix=StringDrop[finiteOwnPoleText,-StringLength[finiteOwnPoleTerminal]];
If[!SyntaxQ[finiteOwnPolePrefix],Quit[1]];ToExpression[finiteOwnPolePrefix,InputForm];

finiteOwnPoleZero[value_,conditions_] := value===0||TrueQ[ownPoleRefine[value,conditions]===0]||TrueQ[zero[value,conditions]];
finiteOwnPoleInstall[] := Module[{directory,path,receipt,proof,definition,replacement,anchor,old},
 directory=FileNameJoin[{root,channel,"s14_pole_refinement_result"}];path=FileNameJoin[{directory,"s14_result.wl"}];
 receipt=Import[FileNameJoin[{directory,"s14_execution.json"}],"RawJSON"];
 gate["accepted own pole comparison receipt",TrueQ[receipt["passed"]]];
 KeyValueMap[gate["bound own pole proof "<>#1,
   IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,receipt["result_sha256"]];
 proof=Get[path];
 gate["complete own pole comparison identity",proof["Schema"]==="polarized-sidis-own-pole-refinement-v1"&&
   proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
   proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqq_pole_refinement.wls"}],"SHA256"]&&
   proof["ConfigHash"]===FileHash[FileNameJoin[{root,"common","s14_Hqq_pole_inputs.json"}],"SHA256"]&&
   proof["InputHash"]===inputHash&&proof["InputHashes"]===inputHashes&&
   proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
   AllTrue[proof["ControlRows"],#["Residual"]===0&]&&
   AllTrue[proof["ActualRows"],#["Residual"]===0&&#["InputSumResidual"]===0&]];
 gate["original complete finite and zero equations unchanged",
   proof["OriginalZeroDefinitions"]===DownValues[zero]&&proof["OriginalFinitePartDefinitions"]===DownValues[finitePart]];
 DownValues[ownPoleRefine]=proof["Definitions"];DownValues[refineUVResidual]=proof["RefinementDefinitions"];
 ownPoleRootEvidence=<||>;
 gate["exact accepted own residual equations installed",DownValues[ownPoleRefine]===proof["Definitions"]&&
   DownValues[refineUVResidual]===proof["RefinementDefinitions"]];
 definition=DownValues[finitePart];replacement=definition/.zero->finiteOwnPoleZero;
 gate["only the original pole predicate changes",Count[definition,_zero,Infinity]===1&&
   (replacement/.finiteOwnPoleZero->zero)===definition];
 DownValues[finitePart]=replacement;
 gate["complete finite equation retained",DownValues[finitePart]===replacement];
 finiteOwnPoleEvidence=<|"SourceHash"->FileHash[finiteOwnPoleSource,"SHA256"],
   "ComparisonHash"->FileHash[path,"SHA256"],"ReceiptHash"->FileHash[FileNameJoin[{directory,"s14_execution.json"}],"SHA256"],
   "ActualLabel"->proof["ActualLabel"],"OwnSavedAndInputSumPolesZero"->True|>;
 anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
 replacement="AssociateTo[result,\"OwnPoleRefinement\"->finiteOwnPoleEvidence];"<>anchor;
 gate["unique own pole evidence export",StringCount[phaseRunTail,anchor]===1];old=phaseRunTail;
 phaseRunTail=StringReplace[old,anchor->replacement];
 gate["all final assembly gates retained",SyntaxQ[phaseRunTail]&&StringReplace[phaseRunTail,replacement->anchor]===old]];
finiteOwnPoleAnchor="finiteStructuralInstall[];ToExpression[phaseRunTail,InputForm];";
finiteOwnPoleReplacement="finiteStructuralInstall[];finiteOwnPoleInstall[];ToExpression[phaseRunTail,InputForm];";
If[StringCount[finiteStructuralRun,finiteOwnPoleAnchor]=!=1,Quit[1]];
finiteOwnPoleRun=StringReplace[finiteStructuralRun,finiteOwnPoleAnchor->finiteOwnPoleReplacement];
If[!SyntaxQ[finiteOwnPoleRun]||StringReplace[finiteOwnPoleRun,finiteOwnPoleReplacement->finiteOwnPoleAnchor]=!=finiteStructuralRun,Quit[1]];
ToExpression[finiteOwnPoleRun,InputForm];

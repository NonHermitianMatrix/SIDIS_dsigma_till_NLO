(* Contract the certified response with the original dimensional spin sum. *)
$HistoryLength=0;
responseCDRSource=FileNameJoin[{Directory[],"common","s05_project_Hgg_response_cdr.wls"}];
responseCDRParent=FileNameJoin[{Directory[],"common","s05_project_Hgg_piecewise_storage.wls"}];
If[IntegerString[FileHash[responseCDRParent,"SHA256"],16,64]=!=
 "fc9e17ee0bb7d4cfa7ae517dfcc166c1c273dac1177c8d21d153cc6bfdf1acaa"||
 !SyntaxQ[Import[responseCDRSource,"Text"]],Quit[1]];
responseCDRText=StringTrim[Import[responseCDRParent,"Text"]];
responseCDRTerminal="ToExpression[piecewiseRun,InputForm];";
If[!StringEndsQ[responseCDRText,responseCDRTerminal],Quit[1]];
responseCDRPrefix=StringDrop[responseCDRText,-StringLength[responseCDRTerminal]];
If[!SyntaxQ[responseCDRPrefix],Quit[1]];ToExpression[responseCDRPrefix,InputForm];

cdrFromResponse[matrix_,incoming_,outgoing_,rules_] := Module[{left,right},
 left=outgoing/.rules;right=incoming/.rules;
 gate["complete CDR response dimensions",Dimensions[matrix]==={Length[left],Length[right]}];
 gate["original CDR basis substitutions fully applied",FreeQ[{left,right},Alternatives@@DeleteCases[Join[incoming,outgoing],1]]];
 left.matrix.right];
responseCDRControl[] := Module[{text,start,end,definition,candidate,original,seconds,residual},
 text=Import[projectSource,"Text"];
 start=First[First[StringPosition[text,"  cdrRules = Thread["]]];
 end=First[First[StringPosition[text,"  cdrAverage ="]]];
 definition=StringTake[text,{start,end-1}];
 gate["unique original CDR rule assignment",StringCount[definition,"cdrRules ="]===1];
 candidate=StringReplace[definition,"cdrRules ="->"responseCDRControlRules ="];
 gate["unchanged original CDR substitution definition",SyntaxQ[candidate]&&
   StringReplace[candidate,"responseCDRControlRules ="->"cdrRules ="]===definition];
 ToExpression[candidate,InputForm];
 original=responseCDRControlPhoton/.responseCDRControlRules;
 {seconds,candidate}=AbsoluteTiming[cdrFromResponse[responseCDRControlMatrix,inVariables,outVariables,responseCDRControlRules]];
 residual=bounded[algebraicReduce[candidate-original],"own complete original CDR contraction"];
 gate["own complete original CDR output reproduced",zeroArray[residual]];
 responseCDREvidence=<|"SourceHash"->FileHash[responseCDRSource,"SHA256"],"InputHash"->inputHash,
   "ControlHash"->responseCDRControlHash,"OriginalRuleDefinition"->definition,
   "OriginalOutputHash"->Hash[original,"SHA256"],"CandidateOutputHash"->Hash[candidate,"SHA256"],
   "ExactResidual"->residual,"OwnAcceptedComparisonPassed"->True,"Seconds"->seconds|>;
 Print["RESPONSE_CDR_CONTROL ",InputForm[responseCDREvidence]];
 Clear[responseCDRControlPhoton,responseCDRControlMatrix,responseCDRControlRules];ClearSystemCache[]];

responseCDRControlAnchor="  Clear[control, controlPhoton, controlResponse, proof]; ClearSystemCache[];";
responseCDRControlReplacement="  responseCDRControlPhoton=controlPhoton;responseCDRControlMatrix=controlResponse;responseCDRControlHash=FileHash[controlPath,\"SHA256\"];responseCDRControl[];\n"<>responseCDRControlAnchor;
responseCDROld="  entrywiseCDR=Total[MapThread[Times,{entrywiseWeights,(#/.cdrRules)&/@entrywiseValues}]];\n  Clear[entries,entrywiseValues,entrywiseWeights];ClearSystemCache[];";
responseCDRNew="  Clear[entries,entrywiseValues,entrywiseWeights];ClearSystemCache[];\n  Print[\"RESPONSE_CDR_INPUT bytes \",ByteCount[response],\" memory \",MemoryInUse[]];\n  entrywiseCDR=cdrFromResponse[response,inVariables,outVariables,cdrRules];";
responseCDREdits={responseCDRControlAnchor->responseCDRControlReplacement,responseCDROld->responseCDRNew,
 "\"OwnStorageComparison\"->piecewiseControlEvidence,"->
   "\"OwnStorageComparison\"->piecewiseControlEvidence,\"ResponseCDRComparison\"->responseCDREvidence,"};
If[!And@@(StringCount[piecewiseRun,First[#]]===1&/@responseCDREdits),Print["FAIL: unique response CDR interfaces"];Quit[1]];
responseCDRRun=StringReplace[piecewiseRun,responseCDREdits];
If[!SyntaxQ[responseCDRRun]||StringReplace[responseCDRRun,Reverse/@responseCDREdits]=!=piecewiseRun,
 Print["FAIL: unchanged complete projection and CDR normalization"];Quit[1]];
ToExpression[responseCDRRun,InputForm];

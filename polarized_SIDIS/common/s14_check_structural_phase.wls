(* Preserve exact regulator-independent coefficients through the original phase product. *)
$HistoryLength=0;
structuralPhaseSource=FileNameJoin[{Directory[],"common","s14_check_structural_phase.wls"}];
structuralPhaseParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
If[IntegerString[FileHash[structuralPhaseParent,"SHA256"],16,64]=!=
 "0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b"||
 !SyntaxQ[Import[structuralPhaseSource,"Text"]],Quit[1]];
structuralPhaseText=StringTrim[Import[structuralPhaseParent,"Text"]];
structuralPhaseTerminal="ToExpression[cachedPartsRun,InputForm];";
If[!StringEndsQ[structuralPhaseText,structuralPhaseTerminal],Quit[1]];
structuralPhasePrefix=StringDrop[structuralPhaseText,-StringLength[structuralPhaseTerminal]];
If[!SyntaxQ[structuralPhasePrefix],Quit[1]];ToExpression[structuralPhasePrefix,InputForm];

structuralPhaseCompare[] := Module[{proofPath,receiptPath,receipt,proof,phaseText,start,end,definition,candidate,
 shrinkSource,shrinkText,shrinkBlock,edits,ownValue,ownSeconds,ownResidual,actualLabel,actualCoefficient,
 actualValue,weightSeconds,actualSeconds,directory,path,serialized,result,plainPath,plain},
 proofPath=FileNameJoin[{root,channel,"s14_regulator_phase_result","s14_result.wl"}];
 receiptPath=FileNameJoin[{DirectoryName[proofPath],"s14_execution.json"}];receipt=Import[receiptPath,"RawJSON"];
 gate["accepted original own phase comparison receipt",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][channel<>"/s14_regulator_phase_result/s14_result.wl"]===IntegerString[FileHash[proofPath,"SHA256"],16,64]];
 proof=Get[proofPath];
 gate["same complete own phase equations and input",proof["Schema"]==="polarized-sidis-regulator-phase-comparison-v1"&&
  proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
  proof["InputHash"]===inputHash&&proof["InputHashes"]===inputHashes&&proof["Kernel"]===phase&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&proof["OriginalDefinitions"]===DownValues[laurentProduct]&&
  And@@(#===0&/@Values[proof["Residuals"]])];
 phaseText=Import[FileNameJoin[{root,"common","s14_check_phase_series.wls"}],"Text"];
 start=First[First[StringPosition[phaseText,"phaseProduct[coefficient_"]]];
 end=First[First[StringPosition[phaseText,"\n\nphaseControlLabels="]]];
 definition=StringTake[phaseText,{start,end-1}];
 shrinkSource=FileNameJoin[{root,"common","s05_check_structural_reconstruction.wls"}];
 shrinkText=Import[shrinkSource,"Text"];
 start=First[First[StringPosition[shrinkText,"  atom[value_] :="]]];
 end=First[First[StringPosition[shrinkText,"  opaque = shrink[expression];"]]];
 shrinkBlock=StringTake[shrinkText,{start,end-1}];
 edits={"phaseProduct[coefficient_"->"structuralPhaseProduct[coefficient_",
  "{polynomial,first,last,rows,reconstruction,answer}"->
   "{polynomial,first,last,rows,reconstruction,answer,replacements={},atom,shrink,opaque,pattern=eps}",
  "  polynomial=bounded[Expand[coefficient,eps],{label,\"Laurent collection\"}];"->
   (shrinkBlock<>"  opaque=shrink[coefficient];\n  gate[\"exact regulator coefficient restoration\",FreeQ[Last/@replacements,eps]&&(opaque/.replacements)===coefficient];\n  Print[\"STRUCTURAL_PHASE_INPUT \",InputForm[<|\"Label\"->label,\"InputBytes\"->ByteCount[coefficient],\"AbstractBytes\"->ByteCount[opaque],\"CoefficientCount\"->Length[replacements],\"AbstractEquation\"->opaque|>]];\n  polynomial=bounded[Expand[opaque,eps],{label,\"Laurent collection\"}];"),
  "  answer];"->"  answer/.replacements];"};
 gate["unique structural phase interfaces",And@@(StringCount[definition,First[#]]===1&/@edits)];
 candidate=StringReplace[definition,edits];
 gate["all original Laurent and phase equations retained",SyntaxQ[candidate]&&StringReplace[candidate,Reverse/@edits]===definition];
 ToExpression[candidate,InputForm];
 gate["original phase implementation unchanged",DownValues[phaseProduct]===(ToExpression[definition,InputForm];DownValues[phaseProduct])];
 {ownSeconds,ownValue}=AbsoluteTiming[bounded[structuralPhaseProduct[proof["Coefficient"],phase,0,proof["Control"]["Label"]],"own complete structural phase"]];
 ownResidual=bounded[Factor[Together[ownValue-proof["OriginalValue"]]],"own complete original phase equality"];
 gate["own complete accepted phase reproduced",ownResidual===0];
 actualLabel=ReplacePart[proof["Control"]["Label"],3->"Regular"];
 Print["ACTUAL_REGULAR_WEIGHT_BEGIN ",actualLabel];
 {weightSeconds,actualCoefficient}=AbsoluteTiming[strongFactor realBranch[actualLabel[[1]],actualLabel[[2]],actualLabel[[3]]]];
 Print["ACTUAL_REGULAR_WEIGHT_SECONDS ",weightSeconds," bytes ",ByteCount[actualCoefficient]];
 directory=FileNameJoin[{root,channel,"s14_structural_phase_result"}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 plainPath=FileNameJoin[{directory,"s14_actual_coefficient.wl"}];plain=ToString[actualCoefficient,InputForm];
 gate["bounded actual readable coefficient",StringLength[plain]<128*1024^2];Export[plainPath,plain,"Text"];
 gate["actual readable coefficient exact reload",Get[plainPath]===actualCoefficient];Clear[plain];
 {actualSeconds,actualValue}=AbsoluteTiming[bounded[structuralPhaseProduct[actualCoefficient,phase,0,actualLabel],"actual Regular structural phase"]];
 result=<|"Schema"->"polarized-sidis-structural-phase-comparison-v1","Channel"->channel,"Accepted"->True,
  "SourceHash"->FileHash[structuralPhaseSource,"SHA256"],"ParentHash"->FileHash[structuralPhaseParent,"SHA256"],
  "OriginalProofHash"->FileHash[proofPath,"SHA256"],"ShrinkSourceHash"->FileHash[shrinkSource,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
  "OriginalDefinitions"->DownValues[phaseProduct],"LaurentDefinitions"->DownValues[laurentProduct],
  "CandidateDefinitions"->DownValues[structuralPhaseProduct],"OwnControl"->proof["Control"],"OwnResidual"->ownResidual,
  "OwnSeconds"->ownSeconds,"ActualLabel"->actualLabel,"ActualCoefficient"->actualCoefficient,
  "ActualKernel"->phase,"ActualValue"->actualValue,"WeightSeconds"->weightSeconds,"ActualSeconds"->actualSeconds,
  "ReadableCoefficientHash"->FileHash[plainPath,"SHA256"],"Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
 path=FileNameJoin[{directory,"s14_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded structural phase result",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];
 gate["exact structural phase result reload",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
 Export[FileNameJoin[{directory,"s14_checks.json"}],<|"channel"->channel,"checks"->checks,"actual_label"->actualLabel,
  "weight_seconds"->weightSeconds,"actual_seconds"->actualSeconds,"own_seconds"->ownSeconds,
  "finite_nlo_fhats_computed"->False|>,"RawJSON"];Print["PASS: s14_check_structural_phase"];Quit[0]];
structuralPhaseAnchor="cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
structuralPhaseReplacement="cachedPartsRecord[];structuralPhaseCompare[];";
If[StringCount[cachedPartsRun,structuralPhaseAnchor]=!=1,Quit[1]];
structuralPhaseRun=StringReplace[cachedPartsRun,structuralPhaseAnchor->structuralPhaseReplacement];
If[!SyntaxQ[structuralPhaseRun]||StringReplace[structuralPhaseRun,structuralPhaseReplacement->structuralPhaseAnchor]=!=cachedPartsRun,Quit[1]];
ToExpression[structuralPhaseRun,InputForm];

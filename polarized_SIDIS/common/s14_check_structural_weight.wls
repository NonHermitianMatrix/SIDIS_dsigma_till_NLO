(* Derive charge coefficients without expanding their independent kinematics. *)
$HistoryLength=0;
structuralWeightSource=FileNameJoin[{Directory[],"common","s14_check_structural_weight.wls"}];
structuralWeightParent=FileNameJoin[{Directory[],"common","s14_check_structural_phase.wls"}];
structuralWeightText=StringTrim[Import[structuralWeightParent,"Text"]];
structuralWeightTerminal="ToExpression[structuralPhaseRun,InputForm];";
If[!SyntaxQ[Import[structuralWeightSource,"Text"]]||!StringEndsQ[structuralWeightText,structuralWeightTerminal],Quit[1]];
structuralWeightPrefix=StringDrop[structuralWeightText,-StringLength[structuralWeightTerminal]];
If[!SyntaxQ[structuralWeightPrefix],Quit[1]];ToExpression[structuralWeightPrefix,InputForm];

structuralChargeRows[expression_] := Module[{pattern=chargeRatio,replacements={},atom,shrink,opaque,rows,monomials},
 atom[value_] := atom[value] = Module[{symbol=Unique["sidisChargeCoefficient"]},AppendTo[replacements,symbol->value];symbol];
 shrink[value_] := If[FreeQ[value,pattern],If[AtomQ[value],value,atom[value]],Map[shrink,value]];
 opaque=shrink[expression];
 gate["exact charge-independent coefficient restoration",FreeQ[Last/@replacements,chargeRatio]&&(opaque/.replacements)===expression];
 gate["native structural charge polynomial",PolynomialQ[opaque,chargeRatio]];
 rows=CoefficientRules[opaque,{chargeRatio}];monomials=chargeRatio^First[First[#]]&/@rows;
 gate["exact abstract charge decomposition",Expand[opaque-Total[MapThread[Times,{Last/@rows,monomials}]]]===0];
 <|"Rules"->(rows/.replacements),"Accepted"->True,"InputBytes"->ByteCount[expression],
   "AbstractBytes"->ByteCount[opaque],"CoefficientCount"->Length[replacements]|>];

structuralWeightInstall[] := Module[{path,receiptPath,receipt,proof,ownRows,packet,seconds,equalitySeconds,
 residuals,evidence={},start,end,definition,edits,candidate,originalDefinitions,result,directory,out,serialized},
 path=FileNameJoin[{root,channel,"s14_charge_result","s14_result.wl"}];
 receiptPath=FileNameJoin[{DirectoryName[path],"s14_execution.json"}];receipt=Import[receiptPath,"RawJSON"];
 gate["accepted own charge-rule receipt",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"][channel<>"/s14_charge_result/s14_result.wl"]===IntegerString[FileHash[path,"SHA256"],16,64]];
 proof=Get[path];
 gate["same complete own accepted charge inputs",proof["Channel"]===channel&&TrueQ[proof["Accepted"]]&&
  proof["RealHash"]===FileHash[FileNameJoin[{root,channel,"s12_result","s12_result.wl"}],"SHA256"]&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&And@@Values[proof["Checks"]]&&
  And@@Lookup[proof["Comparisons"],"Accepted"]];
 Do[
  {seconds,packet}=AbsoluteTiming[bounded[structuralChargeRows[row["Expression"]],"own structural charge coefficients"]];
  ownRows=packet["Rules"];
  gate["same complete own charge powers",First/@ownRows===First/@row["CoefficientRules"]];
  {equalitySeconds,residuals}=AbsoluteTiming[MapThread[If[#1===#2,0,bounded[Factor[Together[#1-#2]],"own charge coefficient equality"]]&,
    {Last/@ownRows,Last/@row["CoefficientRules"]}]];
  gate["entire own accepted charge coefficients reproduced",And@@(#===0&/@residuals)];
  AppendTo[evidence,Join[KeyTake[row,{"Sector","Index","Branch","Distribution","InputHash"}],KeyDrop[packet,"Rules"],
    <|"Seconds"->seconds,"EqualitySeconds"->equalitySeconds,"ExactResiduals"->residuals|>]];
  Print["STRUCTURAL_CHARGE_COMPARISON ",InputForm[Last[evidence]]],{row,proof["Comparisons"]}];
 originalDefinitions=DownValues[weighted];
 start=First[First[StringPosition[phaseRunPrefix,"weighted[expression_,sector_]"]]];
 end=First[First[StringPosition[phaseRunPrefix,"\nphysicalComponents="]]];
 definition=StringTake[phaseRunPrefix,{start,end-1}];
 edits={"{rows,monomials,names}"->"{rows,monomials,names,packet}",
  "  gate[\"polynomial distinct-flavor charge dependence\",PolynomialQ[expression,chargeRatio]];"->
   "  packet=structuralChargeRows[expression];gate[\"polynomial distinct-flavor charge dependence\",TrueQ[packet[\"Accepted\"]]];",
  "rows=CoefficientRules[expression,{chargeRatio}];"->"rows=packet[\"Rules\"];",
  "exactChargeZero[expression-Total[MapThread[Times,{Last/@rows,monomials}]]]"->"TrueQ[packet[\"Accepted\"]]"};
 gate["unique charge weighting implementation edits",And@@(StringCount[definition,First[#]]===1&/@edits)];
 candidate=StringReplace[definition,edits];
 gate["all charge names and inherited weighting equations retained",SyntaxQ[candidate]&&StringReplace[candidate,Reverse/@edits]===definition];
 ToExpression[candidate,InputForm];
 result=<|"Schema"->"polarized-sidis-structural-charge-comparison-v1","Channel"->channel,"Accepted"->True,
  "SourceHash"->FileHash[structuralWeightSource,"SHA256"],"OriginalProofHash"->FileHash[path,"SHA256"],
  "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
  "OriginalDefinitions"->originalDefinitions,"CandidateDefinitions"->DownValues[weighted],
  "CoefficientDefinitions"->DownValues[structuralChargeRows],"Weights"->weights,"Evidence"->evidence,"Checks"->checks|>;
 directory=FileNameJoin[{root,channel,"s14_structural_weight_result"}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 out=FileNameJoin[{directory,"s14_charge_comparison.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded structural charge proof",StringLength[serialized]<128*1024^2];Export[out<>".tmp",serialized,"Text"];
 gate["exact structural charge proof reload",Get[out<>".tmp"]===result];RenameFile[out<>".tmp",out,OverwriteTarget->True];
 structuralWeightProofHash=FileHash[out,"SHA256"];
 Print["PASS: complete own structural charge comparison"]];

structuralWeightAnchor="cachedPartsRecord[];structuralPhaseCompare[];";
structuralWeightReplacement="cachedPartsRecord[];structuralWeightInstall[];structuralPhaseCompare[];";
If[StringCount[structuralPhaseRun,structuralWeightAnchor]=!=1,Quit[1]];
structuralWeightRun=StringReplace[structuralPhaseRun,structuralWeightAnchor->structuralWeightReplacement];
If[!SyntaxQ[structuralWeightRun]||StringReplace[structuralWeightRun,structuralWeightReplacement->structuralWeightAnchor]=!=structuralPhaseRun,Quit[1]];
DownValues[structuralPhaseCompare]=DownValues[structuralPhaseCompare]/."s14_structural_phase_result"->"s14_structural_weight_result";
structuralPhaseSource=structuralWeightSource;
ToExpression[structuralWeightRun,InputForm];

(* Install the accepted compact charge/phase equations in the finite assembly. *)
$HistoryLength=0;
finiteStructuralSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_structural.wls"}];
finiteStructuralParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
If[IntegerString[FileHash[finiteStructuralParent,"SHA256"],16,64]=!=
 "0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b"||
 !SyntaxQ[Import[finiteStructuralSource,"Text"]],Quit[1]];
finiteStructuralText=StringTrim[Import[finiteStructuralParent,"Text"]];
finiteStructuralTerminal="ToExpression[cachedPartsRun,InputForm];";
If[!StringEndsQ[finiteStructuralText,finiteStructuralTerminal],Quit[1]];
finiteStructuralPrefix=StringDrop[finiteStructuralText,-StringLength[finiteStructuralTerminal]];
If[!SyntaxQ[finiteStructuralPrefix],Quit[1]];ToExpression[finiteStructuralPrefix,InputForm];

finiteStructuralInstall[] := Module[{directory,receipt,chargeProof,phaseProof,source,phaseDefinitions,
 checkedDefinitions,originalChecked,actualCoefficient,actualValue,weightSeconds,phaseSeconds,anchor,replacement,old},
 directory=FileNameJoin[{root,channel,"s14_structural_weight_result"}];
 receipt=Import[FileNameJoin[{directory,"s14_execution.json"}],"RawJSON"];
 gate["accepted own structural comparison receipt",TrueQ[receipt["passed"]]];
 KeyValueMap[gate["bound structural comparison "<>#1,
   IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,receipt["result_sha256"]];
 chargeProof=Get[FileNameJoin[{directory,"s14_charge_comparison.wl"}]];
 phaseProof=Get[FileNameJoin[{directory,"s14_result.wl"}]];
 source=FileHash[FileNameJoin[{root,"common","s14_check_structural_weight.wls"}],"SHA256"];
 gate["same accepted structural sources inputs and native versions",AllTrue[{chargeProof,phaseProof},
   #["Channel"]===channel&&TrueQ[#["Accepted"]]&&And@@Values[#["Checks"]]&&
   #["SourceHash"]===source&&#["InputHash"]===inputHash&&#["InputHashes"]===inputHashes&&
   #["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&]];
 gate["complete own charge and phase comparison identities",
   chargeProof["Schema"]==="polarized-sidis-structural-charge-comparison-v1"&&
   phaseProof["Schema"]==="polarized-sidis-structural-phase-comparison-v1"&&phaseProof["OwnResidual"]===0&&
   AllTrue[chargeProof["Evidence"],TrueQ[#["Accepted"]]&&And@@(#===0&/@#["ExactResiduals"])&]&&
   chargeProof["OriginalDefinitions"]===DownValues[weighted]&&chargeProof["Weights"]===weights&&
   phaseProof["OriginalDefinitions"]===DownValues[phaseProduct]&&
   phaseProof["LaurentDefinitions"]===DownValues[laurentProduct]&&phaseProof["ActualKernel"]===phase&&
   phaseProof["ParentHash"]===FileHash[finiteStructuralParent,"SHA256"]];
 DownValues[structuralChargeRows]=chargeProof["CoefficientDefinitions"];
 DownValues[weighted]=chargeProof["CandidateDefinitions"];
 gate["exact accepted charge equations installed",DownValues[weighted]===chargeProof["CandidateDefinitions"]&&
   DownValues[structuralChargeRows]===chargeProof["CoefficientDefinitions"]];
 phaseDefinitions=phaseProof["CandidateDefinitions"]/.structuralPhaseProduct->phaseProduct;
 gate["single reconstructed Laurent product interface",Count[phaseDefinitions,_laurentProduct,Infinity]===1];
 checkedDefinitions=phaseDefinitions/.laurentProduct->finiteStructuralLaurent;
 gate["phase equations retain exact accepted form",(checkedDefinitions/.finiteStructuralLaurent->laurentProduct)===phaseDefinitions];
 DownValues[phaseProduct]=checkedDefinitions;
 originalChecked=DownValues[checkedPhaseProduct];
 gate["original complete phase caller has one product and support expansion",
   Count[originalChecked,_phaseProduct,Infinity]===1&&Count[originalChecked,_phaseMonomialCheck,Infinity]===1&&
   Count[originalChecked,_Expand,Infinity]===1];
 Clear[checkedPhaseProduct];
 checkedPhaseProduct[coefficient_,kernel_,order_,label_] := phaseProduct[coefficient,kernel,order,label];
 {weightSeconds,actualCoefficient}=AbsoluteTiming[strongFactor (realBranch@@phaseProof["ActualLabel"])];
 gate["entire actual compact weighted input reproduced",actualCoefficient===phaseProof["ActualCoefficient"]];
 {phaseSeconds,actualValue}=AbsoluteTiming[bounded[
   checkedPhaseProduct[actualCoefficient,phase,0,phaseProof["ActualLabel"]],"own complete structural caller"]];
 gate["entire accepted actual phase output reproduced",actualValue===phaseProof["ActualValue"]];
 gate["original Laurent equations unchanged",DownValues[laurentProduct]===phaseProof["LaurentDefinitions"]];
 finiteStructuralEvidence=<|"SourceHash"->FileHash[finiteStructuralSource,"SHA256"],
   "ChargeComparisonHash"->FileHash[FileNameJoin[{directory,"s14_charge_comparison.wl"}],"SHA256"],
   "PhaseComparisonHash"->FileHash[FileNameJoin[{directory,"s14_result.wl"}],"SHA256"],
   "ReceiptHash"->FileHash[FileNameJoin[{directory,"s14_execution.json"}],"SHA256"],
   "ActualLabel"->phaseProof["ActualLabel"],"OwnInputAndOutputEqual"->True,
   "WeightSeconds"->weightSeconds,"PhaseSeconds"->phaseSeconds,"OriginalCheckedCaller"->originalChecked|>;
 Print["S14_STRUCTURAL_INSTALLED ",InputForm[KeyDrop[finiteStructuralEvidence,"OriginalCheckedCaller"]]];
 anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
 replacement="AssociateTo[result,\"StructuralComparison\"->finiteStructuralEvidence];"<>anchor;
 gate["unique structural evidence export",StringCount[phaseRunTail,anchor]===1];
 old=phaseRunTail;phaseRunTail=StringReplace[old,anchor->replacement];
 gate["all final finite acceptance gates retained",SyntaxQ[phaseRunTail]&&StringReplace[phaseRunTail,replacement->anchor]===old]];

finiteStructuralLaurent[polynomial_,kernel_,order_] := Module[{first,last},
 first=Exponent[polynomial,eps,Min];last=Exponent[polynomial,eps];
 Scan[phaseMonomialCheck[kernel,#,order]&,Range[first,last]];
 laurentProduct[polynomial,kernel,order]];
finiteStructuralAnchor="cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
finiteStructuralReplacement="cachedPartsRecord[];finiteStructuralInstall[];ToExpression[phaseRunTail,InputForm];";
If[StringCount[cachedPartsRun,finiteStructuralAnchor]=!=1,Quit[1]];
finiteStructuralRun=StringReplace[cachedPartsRun,finiteStructuralAnchor->finiteStructuralReplacement];
If[!SyntaxQ[finiteStructuralRun]||StringReplace[finiteStructuralRun,finiteStructuralReplacement->finiteStructuralAnchor]=!=cachedPartsRun,Quit[1]];
ToExpression[finiteStructuralRun,InputForm];

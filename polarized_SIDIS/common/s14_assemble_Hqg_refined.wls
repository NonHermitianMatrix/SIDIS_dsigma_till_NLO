(* Resume the same finite response with the accepted own pole certificate. *)
$HistoryLength=0;
hqgRefinementSource=FileNameJoin[{Directory[],"common","s14_assemble_Hqg_refined.wls"}];
hqgCompactSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_compact_inputs.wls"}];
If[IntegerString[FileHash[hqgCompactSource,"SHA256"],16,64]=!="0e87dc4d088369ad3cd9754e31c5aedd4e6a80db2f18b3d318abb345cd68a613"||
 !SyntaxQ[Import[hqgRefinementSource,"Text"]],Quit[1]];
hqgCompactText=StringTrim[Import[hqgCompactSource,"Text"]];hqgTerminal="ToExpression[phaseRunTail,InputForm];";
If[!StringEndsQ[hqgCompactText,hqgTerminal],Quit[1]];
hqgCompactPrefix=StringDrop[hqgCompactText,-StringLength[hqgTerminal]];
If[!SyntaxQ[hqgCompactPrefix],Quit[1]];ToExpression[hqgCompactPrefix,InputForm];
gate["own Hqg refinement channel",channel==="Hqg"&&core];
hqgProofRelative="Hqg/s14_pole_refinement_result/s14_result.wl";
hqgProofPath=FileNameJoin[{root,hqgProofRelative}];
hqgReceiptPath=FileNameJoin[{DirectoryName[hqgProofPath],"s14_execution.json"}];
hqgReceipt=Import[hqgReceiptPath,"RawJSON"];
gate["accepted own exact pole refinement",TrueQ[hqgReceipt["passed"]]&&hqgReceipt["result_sha256"][hqgProofRelative]===IntegerString[FileHash[hqgProofPath,"SHA256"],16,64]];
hqgProof=Get[hqgProofPath];
gate["same own native refinement inputs",hqgProof["Schema"]==="polarized-sidis-Hqg-pole-refinement-v1"&&hqgProof["Channel"]===channel&&
 TrueQ[hqgProof["Accepted"]]&&And@@Values[hqgProof["Checks"]]&&hqgProof["InputHash"]===inputHash&&
 hqgProof["NativeVersions"]==={$Version,$FeynCalcVersion}&&hqgProof["BaselineSourceHash"]===sourceHash&&
 hqgProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqg_pole_refinement.wls"}],"SHA256"]];
gate["both actual saved and original input poles proved zero",Length[hqgProof["Rows"]]>0&&
 AllTrue[hqgProof["Rows"],#["Refined"]===0&&#["InputSumRefined"]===0&]&&
 AllTrue[hqgProof["ControlRows"],#["Refined"]===0&]];
hqgLabel=hqgProof["FailedLabel"];
hqgConditions=(softPhysical/.t->hqgLabel[[2]] omega-s)&&If[hqgLabel[[2]]===0,True,omega>0]&&flavorDomain;
gate["identical actual pole domain",hqgConditions===hqgProof["PhysicalConditions"]];
gate["unchanged finite extraction and zero predicate",DownValues[finitePart]===hqgProof["OriginalFinitePartDefinitions"]&&DownValues[zero]===hqgProof["OriginalZeroDefinitions"]];
DownValues[refineUVResidual]=hqgProof["RefinementDefinitions"];
DownValues[refineAssemblyPole]=hqgProof["Definitions"];
gate["exact executed refinement definitions installed",{DownValues[refineUVResidual],DownValues[refineAssemblyPole]}===Lookup[hqgProof,{"RefinementDefinitions","Definitions"}]];
poleFactorCertificates=<||>;
hqgControlFile=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[hqgProof["ControlLabel"],"SHA256"],16]<>".wl"}];
gate["unchanged accepted own control checkpoint",FileHash[hqgControlFile,"SHA256"]===hqgProof["ControlHash"]];
{hqgOriginalSeconds,hqgOriginalControl}=AbsoluteTiming[assemble[First[hqgProof["ControlLabel"]]]];
gate["complete own original control accepted",AssociationQ[hqgOriginalControl]&&TrueQ[hqgOriginalControl["Accepted"]]&&And@@Values[hqgOriginalControl["Checks"]]];
hqgOriginalFinite=DownValues[finitePart];
gate["one original pole predicate",Count[hqgOriginalFinite,zero,Infinity,Heads->True]===1];
DownValues[finitePart]=hqgOriginalFinite/.zero->hqgRefinedPoleZero;
gate["entire finite extraction restored exactly",(DownValues[finitePart]/.hqgRefinedPoleZero->zero)===hqgOriginalFinite];
hqgRefinedPoleZero[value_,conditions_]:=refineAssemblyPole[value,conditions]===0;
SetAttributes[hqgResumeFinitePart,HoldFirst];
hqgResumeFinitePart[parts_,label_,assumptions_]:=Module[{file,saved},
 file=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
 saved=If[FileExistsQ[file],Get[file],<||>];
 If[Lookup[saved,"InputHash",None]===inputHash&&TrueQ[Lookup[saved,"Accepted",False]],Return[saved["Finite"]]];
 finitePart[parts,label,assumptions]];
hqgOriginalAssembly=DownValues[assemble];
gate["original finite calls available",Count[hqgOriginalAssembly,finitePart,Infinity,Heads->True]>0];
DownValues[assemble]=hqgOriginalAssembly/.finitePart->hqgResumeFinitePart;
gate["entire assembler restored exactly",(DownValues[assemble]/.hqgResumeFinitePart->finitePart)===hqgOriginalAssembly];
{hqgDeferredSeconds,hqgDeferredControl}=AbsoluteTiming[assemble[First[hqgProof["ControlLabel"]]]];
gate["whole own accepted component unchanged",AssociationQ[hqgDeferredControl]&&TrueQ[hqgDeferredControl["Accepted"]]&&And@@Values[hqgDeferredControl["Checks"]]&&
 KeyTake[hqgDeferredControl,{"Index","Branches"}]===KeyTake[hqgOriginalControl,{"Index","Branches"}]];
hqgControlComparison=<|"Index"->First[hqgProof["ControlLabel"]],"OriginalSeconds"->hqgOriginalSeconds,"DeferredSeconds"->hqgDeferredSeconds,"ExactCompleteComponentComparison"->True|>;
Print["HQG_FINITE_CONTROL_ACCEPTED ",InputForm[hqgControlComparison]];
Clear[hqgOriginalControl,hqgDeferredControl];ClearSystemCache[];
hqgResultAnchor="resultDir=FileNameJoin[{root,channel,\"s14_result\"}];";
hqgResultReplacement="AssociateTo[result,{\"PoleRefinementHash\"->FileHash[hqgProofPath,\"SHA256\"],\"PoleRefinementReceiptHash\"->FileHash[hqgReceiptPath,\"SHA256\"],\"PoleFactorCertificates\"->poleFactorCertificates,\"DeferredCheckpointInputComparison\"->hqgControlComparison,\"RefinementConsumerSourceHash\"->FileHash[hqgRefinementSource,\"SHA256\"]}];"<>hqgResultAnchor;
gate["unique original finite result boundary",StringCount[phaseRunTail,hqgResultAnchor]===1];
hqgOriginalTail=phaseRunTail;phaseRunTail=StringReplace[phaseRunTail,hqgResultAnchor->hqgResultReplacement];
gate["complete original final gates retained",SyntaxQ[phaseRunTail]&&StringReplace[phaseRunTail,hqgResultReplacement->hqgResultAnchor]===hqgOriginalTail];
ToExpression[phaseRunTail,InputForm];

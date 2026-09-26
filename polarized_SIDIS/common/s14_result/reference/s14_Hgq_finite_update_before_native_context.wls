(* Reuse accepted Laurent coefficients after an explicitly finite subtraction change. *)
$HistoryLength=0;
updateSource=FileNameJoin[{Directory[],"common","s14_assemble_Hgq_finite_update.wls"}];
updateLegacySource=FileNameJoin[{Directory[],"common","s14_assemble_finite_Hgq_roots.wls"}];
If[IntegerString[FileHash[updateLegacySource,"SHA256"],16,64]=!=
  "4f695976bf5320e47df51bc3d8def722c573d2988be5c3afd412c794068d73c8",Quit[1]];
updateLegacyText=Import[updateLegacySource,"Text"];
updateEntry="ToExpression[phaseRunTail,InputForm];";
If[!StringEndsQ[StringTrim[updateLegacyText],updateEntry]||
  !SyntaxQ[Import[updateSource,"Text"]],Quit[1]];
updatePrefix=StringTake[updateLegacyText,
  First[Last[StringPosition[updateLegacyText,updateEntry]]]-1];
If[!SyntaxQ[updatePrefix],Quit[1]];ToExpression[updatePrefix,InputForm];
gate["own finite-update channel",channel==="Hgq"&&core];
updateOldCache=cache;updateOldInputHash=inputHash;updateOldInputHashes=inputHashes;
updateOldCounterterms=subtraction["Counterterms"];
updateOriginalAssembly=DownValues[assemble];
updateOldControl=assemble[First[poleRunProof["ControlLabel"]]];
gate["own accepted assembly control retained",TrueQ[updateOldControl["Accepted"]]&&
  And@@Values[updateOldControl["Checks"]]];
updateRelative=channel<>"/s11_msbar_result/s11_result.wl";
updateSubtractionPath=FileNameJoin[{root,updateRelative}];
updateReceiptPath=FileNameJoin[{root,channel,"s11_msbar_result","s11_execution.json"}];
updateComparisonPath=FileNameJoin[{root,channel,"s11_msbar_result","s11_comparison.wl"}];
updateSubtractionSource=FileNameJoin[{root,"common","s11_finalize_Hgq_subtraction.wls"}];
updateReceipt=Import[updateReceiptPath,"RawJSON"];
updateSubtraction=Get[updateSubtractionPath];updateComparison=Get[updateComparisonPath];
gate["accepted finite MS subtraction execution",TrueQ[updateReceipt["passed"]]&&
  updateReceipt["result_sha256"][updateRelative]===IntegerString[FileHash[updateSubtractionPath,"SHA256"],16,64]&&
  updateSubtraction["SourceHash"]===FileHash[updateSubtractionSource,"SHA256"]&&
  updateSubtraction["Channel"]===channel&&TrueQ[updateSubtraction["AcceptedForProduction"]]&&
  TrueQ[updateSubtraction["FiniteDimensionalSchemeConversionApplied"]]&&
  And@@Values[updateSubtraction["Checks"]]];
gate["complete native subtraction comparison",TrueQ[updateComparison["AcceptedForProduction"]]&&
  And@@Values[updateComparison["Checks"]]&&AllTrue[updateComparison["Comparisons"],TrueQ[#["Equal"]]&]&&
  updateSubtraction["ConvolutionComparisonHash"]===FileHash[updateComparisonPath,"SHA256"]&&
  updateComparison["OriginalAssemblyInputHash"]===updateOldInputHash&&
  updateComparison["OriginalSubtractionHash"]===FileHash[FileNameJoin[{root,channel,"s11_result","s11_result.wl"}],"SHA256"]];
gate["same physical subtraction basis",updateSubtraction["PhotonLabels"]===subtraction["PhotonLabels"]&&
  updateSubtraction["SpinLabels"]===subtraction["SpinLabels"]&&
  updateSubtraction["Prefactor"]===subtraction["Prefactor"]&&
  updateSubtraction["MSPole"]===subtraction["MSPole"]];
updateDifference=Association@Table[distribution->Map[Factor,
  updateSubtraction["Counterterms"][distribution]-updateOldCounterterms[distribution],{3}],
  {distribution,Keys[updateOldCounterterms]}];
gate["actual full-spin counterterm difference is finite",FreeQ[updateDifference,
  eps|D|_Missing|_Integrate|_Limit|_Series|_SeriesData|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
gate["exact subtraction difference from native comparison",And@@Flatten[
  Map[Together[#]===0&,Values[updateDifference]-Values[updateComparison["Correction"]],{4}]]];
updateNormalization=eq^2 couplingSquare^2 hardNormalization;
updateCheckpointHashes=<||>;
updateAssemble[index_,difference_] := Block[{checks=<||>},Module[
  {branches,label,path,saved,change,value},
  branches=Association@Table[sign->Association@Table[
    label={index,sign,distribution};path=FileNameJoin[{updateOldCache,
      "finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
    gate["required own accepted finite checkpoint",FileExistsQ[path]];
    saved=Get[path];
    gate["bound own finite checkpoint",TrueQ[saved["Accepted"]]&&
      saved["InputHash"]===updateOldInputHash&&saved["Label"]===label&&AssociationQ[saved["PoleResiduals"]]];
    AssociateTo[updateCheckpointHashes,StringDrop[path,StringLength[root]+1]->FileHash[path,"SHA256"]];
    change=If[KeyExistsQ[difference,distribution],Extract[difference[distribution],index],0]/.t->sign omega-s;
    value=updateNormalization (saved["Finite"]+change);
    gate["finite updated physical component",FreeQ[value,eps|D|gs|_Missing|_GLI|_CutIntegral|_PaVe|
      _Integrate|_Limit|_Series|_SeriesData|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
    distribution->value,{distribution,distributions}],{sign,{1,-1,0}}];
  <|"Index"->index,"Branches"->branches,"Checks"->checks,"Accepted"->True|>]];
updateZeroDifference=Map[ConstantArray[0,Dimensions[#]]&,updateDifference];
updateReusedControl=updateAssemble[updateOldControl["Index"],updateZeroDifference];
gate["own accepted complete output comparison",updateReusedControl["Branches"]===updateOldControl["Branches"]];
Clear[updateOldControl,updateReusedControl];
updateIndices=Tuples[{Range[Length[basis["PhotonLabels"]]],
  Range[Length[basis["SpinLabels"]]],Range[Length[basis["SpinLabels"]]]}];
updateControlIndex=SelectFirst[updateIndices,Function[index,
  AnyTrue[Values[updateDifference],Function[tensor,Extract[tensor,index]=!=0]]]];
gate["a changed physical component is available",MemberQ[updateIndices,updateControlIndex]];
subtraction=updateSubtraction;
inputPaths=DeleteDuplicates[Join[inputPaths,{updateSource,updateLegacySource,updateSubtractionPath,
  updateReceiptPath,updateComparisonPath,updateSubtractionSource}]];
inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths];
inputHash=Hash[{sourceHash,inputHashes,$Version,$FeynCalcVersion},"SHA256"];
cache=FileNameJoin[{root,"cache","s14",channel,IntegerString[inputHash,16]}];
If[!DirectoryQ[cache],CreateDirectory[cache,CreateIntermediateDirectories->True]];
Print["DIRECT_FINITE_UPDATE_CONTROL ",InputForm[updateControlIndex]];
{updateDirectSeconds,updateDirectControl}=AbsoluteTiming[assemble[updateControlIndex]];
gate["direct updated assembly control accepted",TrueQ[updateDirectControl["Accepted"]]&&
  And@@Values[updateDirectControl["Checks"]]];
{updateReuseSeconds,updateReuseControl}=AbsoluteTiming[updateAssemble[updateControlIndex,updateDifference]];
gate["updated complete component equals direct assembly",And@@Flatten[Table[
  zero[updateDirectControl["Branches"][sign][distribution]-updateReuseControl["Branches"][sign][distribution],
    (If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&If[sign===0,True,omega>0]],
  {sign,{1,-1,0}},{distribution,distributions}]]];
updateEvidence=<|"Index"->updateControlIndex,"DirectSeconds"->updateDirectSeconds,
  "ReuseSeconds"->updateReuseSeconds,"OwnAcceptedOutputComparison"->True,
  "DirectUpdatedComponentComparison"->True,"FiniteCountertermDifference"->True|>;
Print["FINITE_UPDATE_COMPARISON ",InputForm[updateEvidence]];
Clear[updateDirectControl,updateReuseControl,updateSubtraction,updateOldCounterterms];ClearSystemCache[];
Clear[assemble];assemble[index_] := updateAssemble[index,updateDifference];
updateExportAnchor="poleFinalPut[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
gate["unique original final finite export",StringCount[phaseRunTail,updateExportAnchor]===1];
updateExportCode="AssociateTo[result,{\"DispatchSourceHash\"->FileHash[updateSource,\"SHA256\"],"<>
  "\"SubtractionResultHash\"->FileHash[updateSubtractionPath,\"SHA256\"],"<>
  "\"FiniteUpdateEvidence\"->updateEvidence,\"PreviousAssemblyInputHash\"->updateOldInputHash,"<>
  "\"PreviousCheckpointHashes\"->updateCheckpointHashes}];"<>updateExportAnchor;
phaseRunTail=StringReplace[phaseRunTail,updateExportAnchor->updateExportCode];
gate["complete updated finite assembly syntax",SyntaxQ[phaseRunTail]];
ToExpression[phaseRunTail,InputForm];

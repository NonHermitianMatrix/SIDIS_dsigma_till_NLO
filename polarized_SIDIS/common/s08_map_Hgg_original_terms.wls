(* Run the complete own Hgg termwise comparison directly against the original mapper. *)
$HistoryLength=0;
hggOriginalTermSource=FileNameJoin[{Directory[],"common","s08_map_Hgg_original_terms.wls"}];
hggOriginalTermBase=FileNameJoin[{Directory[],"common","s08_map_saved_terms.wls"}];
If[Environment["POLARIZED_SIDIS_CHANNEL"]=!="Hgg"||!SyntaxQ[Import[hggOriginalTermSource,"Text"]]||
 IntegerString[FileHash[hggOriginalTermBase,"SHA256"],16,64]=!="1d7679bf634e5dc0fa6d5301de2137becfc0bdcbe336a63fd528bb78b0a76d72",Quit[1]];
hggOriginalTermText=Import[hggOriginalTermBase,"Text"];
hggOtherControlStart=StringPosition[hggOriginalTermText,"\nIf[channel===\"Hgg\","];
hggOtherControlEnd=StringPosition[hggOriginalTermText,"\nterms="];
If[Length[hggOtherControlStart]=!=1||Length[hggOtherControlEnd]=!=1,Quit[1]];
hggOtherControlBlock=StringTake[hggOriginalTermText,{First[First[hggOtherControlStart]],First[First[hggOtherControlEnd]]-1}];
hggOriginalTermEdits={
 hggOtherControlBlock->"\n(* The complete original Hgg term comparison below is the own-control gate. *)",
 "source=FileNameJoin[{root,\"common\",\"s08_map_saved_terms.wls\"}];"->"source=hggOriginalTermSource;"};
If[!And@@(StringCount[hggOriginalTermText,First[#]]===1&/@hggOriginalTermEdits),Quit[1]];
hggOriginalTermRun=StringReplace[hggOriginalTermText,hggOriginalTermEdits];
If[!SyntaxQ[hggOriginalTermRun]||StringReplace[hggOriginalTermRun,Reverse/@hggOriginalTermEdits]=!=hggOriginalTermText,Quit[1]];
ToExpression[hggOriginalTermRun,InputForm];

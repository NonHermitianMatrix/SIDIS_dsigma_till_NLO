(* Apply the accepted affine basis before the original scalar-map Cancel. *)
$HistoryLength=0;
cancelSource=FileNameJoin[{Directory[],"common","s08_check_Hgg_affine_cancel.wls"}];
cancelSetup=FileNameJoin[{Directory[],"common","s08_check_Hgg_polynomial_content.wls"}];
If[!SyntaxQ[ReadString[cancelSource]]||IntegerString[FileHash[cancelSetup,"SHA256"],16,64]=!=
 "6b42c2b8cf22dc736c2dff283bfc703c45ee83cd1a063736daed95a8e0b2dff2",Quit[1]];
cancelText=ReadString[cancelSetup];cancelBoundary=StringPosition[cancelText,"\ncontentFixed="];
If[Length[cancelBoundary]=!=1,Quit[1]];
cancelPrefix=StringTake[cancelText,First[First[cancelBoundary]]-1];
If[!SyntaxQ[cancelPrefix],Quit[1]];ToExpression[cancelPrefix,InputForm];
cancelOriginalDefinitions=DownValues[externalOriginalMap];
cancelFixedDefinitions={DownValues[mapExpression],DownValues[merge],DownValues[familyRows],
 DownValues[certifyFamilyLaurent],DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]};
cancelEvidence={};
earlyAffineCancel[expression_]:=Module[{prepared,cancelled,restored,seconds},
 prepared=expression/.basisInverse;
 gate["early affine complete input round trip",(prepared/.basisForward)===expression||
  bounded[zero[(prepared/.basisForward)-expression],"early affine input roundtrip"]];
 Print["EARLY_AFFINE_CANCEL_START bytes ",ByteCount[prepared]];
 {seconds,cancelled}=AbsoluteTiming[Cancel[prepared]];
 gate["early affine cancellation preserves the complete rational input",Cancel[cancelled-prepared]===0];
 restored=cancelled/.basisForward;
 gate["early affine cancellation output has only original variables",FreeQ[restored,Alternatives@@basisCoordinates]];
 gate["early affine restored output returns to its exact cancelled form",
  (restored/.basisInverse)===cancelled||zero[(restored/.basisInverse)-cancelled]];
 AppendTo[cancelEvidence,<|"InputBytes"->ByteCount[expression],"PreparedBytes"->ByteCount[prepared],
  "CancelledBytes"->ByteCount[cancelled],"RestoredBytes"->ByteCount[restored],"Seconds"->seconds|>];
 Print["EARLY_AFFINE_CANCEL_DONE ",InputForm[Last[cancelEvidence]]];restored];
gate["one original Cancel call in the complete scalar mapper",
 Count[cancelOriginalDefinitions,HoldPattern[Cancel[_]],Infinity]===1];
cancelCandidateDefinitions=cancelOriginalDefinitions/.Cancel->earlyAffineCancel;
gate["complete original scalar mapper restored by reversing only Cancel",
 (cancelCandidateDefinitions/.earlyAffineCancel->Cancel)===cancelOriginalDefinitions];
DownValues[externalOriginalMap]=cancelCandidateDefinitions;
gate["exact early affine scalar mapper installed",DownValues[externalOriginalMap]===cancelCandidateDefinitions];
cancelGroup[value_,label_]:=Module[{parts,packets,rows},
 parts=polynomialAdditivePieces[value];
 gate["complete early affine additive input "<>label,basisPieceCertificate[value,parts]];
 packets=MapIndexed[Function[{piece,index},Block[{checks=<||>},Module[{seconds,rows},
  Print["EARLY_AFFINE_MAP_START ",label," ",First[index],"/",Length[parts]];
  {seconds,rows}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
   mapExpression[piece],600,gate["early affine piece time bound",False]],4*1024^3,gate["early affine piece memory bound",False]]];
  Print["EARLY_AFFINE_MAP_DONE ",label," ",First[index]," seconds ",seconds];
  <|"Coefficients"->rows,"Seconds"->seconds,"Checks"->checks,"Accepted"->True|>]]],parts];
 gate["every complete early affine piece accepted "<>label,And@@Lookup[packets,"Accepted"]&&And@@Flatten[Values[#["Checks"]]&/@packets]];
 rows=bounded[merge[Lookup[packets,"Coefficients"]],"early affine full merge"];
 gate["complete early affine group merge reconstructs "<>label,certifyGroupMerge[packets,rows]];
 <|"Coefficients"->rows,"PieceSeconds"->Lookup[packets,"Seconds"],"Checks"->Lookup[packets,"Checks"]|>];
cancelSame[actual_,expected_]:=Sort[Keys[actual]]===Sort[Keys[expected]]&&
 And@@KeyValueMap[(#2===expected[#1]||bounded[zero[#2-expected[#1]],{"early affine coefficient",#1}])&,actual];
{cancelOwnSeconds,cancelOwn}=AbsoluteTiming[cancelGroup[contentKnown["OwnAcceptedEquation"],"own"]];
gate["early affine mapper preserves every independently accepted own coefficient",cancelSame[cancelOwn["Coefficients"],contentAffine["OwnCoefficients"]]];
{cancelKnownSeconds,cancelKnown}=AbsoluteTiming[cancelGroup[contentKnown["Equation"],"accepted38"]];
gate["early affine mapper preserves every accepted component38 group coefficient",cancelSame[cancelKnown["Coefficients"],contentAffine["ActualCoefficients"]]];
{cancelActualSeconds,cancelActual}=AbsoluteTiming[cancelGroup[contentSlow["Equation"],"actual37"]];
gate["all remaining affine mapping and scalar certificates unchanged",cancelFixedDefinitions===
 {DownValues[mapExpression],DownValues[merge],DownValues[familyRows],DownValues[certifyFamilyLaurent],
 DownValues[certifyScalarReconstruction],DownValues[extractAtoms],DownValues[externalSplit]}&&
 (DownValues[externalOriginalMap]/.earlyAffineCancel->Cancel)===cancelOriginalDefinitions];
cancelInputPaths={"Hgg/s08_affine_piece_basis_result/s08_result.wl","Hgg/s08_slow_group_input_result/s08_result.wl",
 "Hgg/s08_failed_group_input_result/s08_result.wl"};
cancelResult=<|"Schema"->"polarized-sidis-early-affine-cancel-comparison-v1","Channel"->channel,
 "SourceHash"->FileHash[cancelSource,"SHA256"],"InputHashes"->record["InputHashes"],"TargetInputHash"->record["TargetInputHash"],
 "ProofHashes"->Association[(#->FileHash[FileNameJoin[{root,#}],"SHA256"])&/@cancelInputPaths],
 "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"OwnAcceptedComparison"->True,"KnownAcceptedComparison"->True,
 "OwnCoefficients"->cancelOwn["Coefficients"],"KnownCoefficients"->cancelKnown["Coefficients"],
 "ActualCoefficients"->cancelActual["Coefficients"],"PieceChecks"->Lookup[{cancelOwn,cancelKnown,cancelActual},"Checks"],
 "OwnSeconds"->cancelOwnSeconds,"KnownSeconds"->cancelKnownSeconds,"ActualSeconds"->cancelActualSeconds,
 "Evidence"->cancelEvidence,"CancelDefinitions"->DownValues[earlyAffineCancel],
 "OriginalMappingDefinitions"->cancelOriginalDefinitions,"CandidateMappingDefinitions"->DownValues[externalOriginalMap],
 "FixedDefinitions"->cancelFixedDefinitions,"Checks"->checks,"PeakKernelMemoryBytes"->MaxMemoryUsed[],"FiniteNLOFHatsComputed"->False|>;
cancelDirectory=FileNameJoin[{root,"Hgg","s08_affine_cancel_result"}];
If[!DirectoryQ[cancelDirectory],CreateDirectory[cancelDirectory]];
saveNative[cancelResult,FileNameJoin[{cancelDirectory,"s08_result.wl"}]];
Export[FileNameJoin[{cancelDirectory,"s08_checks.json"}],<|"checks"->checks,"own_seconds"->cancelOwnSeconds,
 "known_seconds"->cancelKnownSeconds,"actual_seconds"->cancelActualSeconds,"evidence"->cancelEvidence,
 "peak_kernel_memory_bytes"->MaxMemoryUsed[],"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s08_check_Hgg_affine_cancel"];Quit[0];

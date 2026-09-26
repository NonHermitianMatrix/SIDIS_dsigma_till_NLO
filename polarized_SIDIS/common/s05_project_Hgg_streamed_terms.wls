(* Reuse exact structural spin extraction term by term, retaining all native gates. *)
$HistoryLength=0;
streamedStructuralSource=FileNameJoin[{Directory[],"common","s05_project_Hgg_streamed_terms.wls"}];
streamedStructuralParent=FileNameJoin[{Directory[],"common","s05_project_Hgg_reduced_hermiticity.wls"}];
If[IntegerString[FileHash[streamedStructuralParent,"SHA256"],16,64]=!=
  "817d2afc17c3087eba8bb9ffb153327cf32895031249298c266d3df382fd5b5f"||
  !SyntaxQ[Import[streamedStructuralSource,"Text"]],Print["FAIL: pinned streamed structural source"];Quit[1]];
streamedStructuralText=StringTrim[Import[streamedStructuralParent,"Text"]];
streamedStructuralTerminal="ToExpression[reducedProjectionRun,InputForm];";
If[!StringEndsQ[streamedStructuralText,streamedStructuralTerminal],Quit[1]];
streamedStructuralPrefix=StringDrop[streamedStructuralText,-StringLength[streamedStructuralTerminal]];
If[!SyntaxQ[streamedStructuralPrefix],Quit[1]];ToExpression[streamedStructuralPrefix,InputForm];
streamedStructuralExtract[expression_,incoming_,outgoing_] := Module[
  {parts,answers,evidence={},packet,answer,shape,genericA,genericB,contract,checks,seconds,started=AbsoluteTime[]},
  shape={Length[outgoing],Length[incoming]};
  genericA=Table[Unique["spinA"],{j,Length[outgoing]},{i,Length[incoming]}];
  genericB=Table[Unique["spinB"],{j,Length[outgoing]},{i,Length[incoming]}];
  gate["complete symbolic test matrices",Dimensions[genericA]===shape&&Dimensions[genericB]===shape];
  contract[m_] := Sum[incoming[[i]]outgoing[[j]]m[[j,i]],{i,Length[incoming]},{j,Length[outgoing]}];
  checks=<|"ExactLinearSpinContraction"->(Expand[contract[genericA+genericB]-contract[genericA]-contract[genericB]]===0)|>;
  parts=If[Head[expression]===Plus,List@@expression,{expression}];
  AssociateTo[checks,"ExactNativeTermRestoration"->(Total[parts]===expression)];
  gate["exact structural streaming identity",And@@Values[checks]];
  Print["STREAMED_STRUCTURAL_INPUT ",InputForm[<|"InputBytes"->ByteCount[expression],
    "TermCount"->Length[parts],"LargestTermBytes"->Max[ByteCount/@parts]|>]];
  answers=Table[
    {seconds,packet}=AbsoluteTiming[bounded[structuralSpinExtraction[parts[[k]],incoming,outgoing],
      {"structural spin term",k}]];
    gate["exact structural term reconstruction",TrueQ[packet["Accepted"]]&&And@@Values[packet["Checks"]]&&
      Dimensions[packet["Response"]]===shape];
    AppendTo[evidence,Join[KeyDrop[packet,"Response"],<|"Term"->k,"TermHash"->Hash[parts[[k]],"SHA256"],"Seconds"->seconds|>]];
    If[Mod[k,100]===0||k===Length[parts],Print["STREAMED_STRUCTURAL_PROGRESS ",k,"/",Length[parts]," memory ",MemoryInUse[]]];
    packet["Response"],{k,Length[parts]}];
  AssociateTo[checks,"EveryTermExactlyReconstructed"->(Length[evidence]===Length[parts]&&And@@Lookup[evidence,"Accepted"])];
  answer=Total[answers];
  AssociateTo[checks,"ExactResponseSum"->(answer===Total[answers])];
  Clear[parts,answers,packet];ClearSystemCache[];
  <|"Response"->answer,"Accepted"->And@@Values[checks],"Checks"->checks,"TermEvidence"->evidence,
    "InputBytes"->ByteCount[expression],"ResponseBytes"->ByteCount[answer],"Seconds"->AbsoluteTime[]-started,
    "KernelMemoryBytes"->MemoryInUse[],"PeakKernelMemoryBytes"->MaxMemoryUsed[]|>];
streamedStructuralOriginal="  {responseSeconds, response} = AbsoluteTiming[bounded[hggProjectionExtractOne[photon, inVariables, outVariables], \"complete structural spin extraction\"]];\n  reconstruction = bounded[structuralSpinReconstruction[photon, response, inVariables, outVariables],\n    \"complete native spin reconstruction\"];";
streamedStructuralReplacement="  {responseSeconds, streamedStructuralPacket} = AbsoluteTiming[streamedStructuralExtract[photon,inVariables,outVariables]];\n  response=streamedStructuralPacket[\"Response\"];reconstruction=KeyDrop[streamedStructuralPacket,\"Response\"];Clear[streamedStructuralPacket];";
streamedStructuralControl="  gate[\"own complete structural spin response exactly reproduced\",bounded[";
streamedStructuralControlReplacement="  streamedStructuralControlPacket=streamedStructuralExtract[controlPhoton,inVariables,outVariables];\n  gate[\"own accepted response equals streamed structural response\",TrueQ[streamedStructuralControlPacket[\"Accepted\"]]&&And@@Values[streamedStructuralControlPacket[\"Checks\"]]&&streamedStructuralControlPacket[\"Response\"]===controlResponse];Clear[streamedStructuralControlPacket];\n"<>streamedStructuralControl;
streamedStructuralMetadata="\"ReductionDispatchHash\" -> FileHash[reducedProjectionSource,\"SHA256\"],";
streamedStructuralChanges={streamedStructuralOriginal->streamedStructuralReplacement,
  streamedStructuralControl->streamedStructuralControlReplacement,
  streamedStructuralMetadata->(streamedStructuralMetadata<>"\n    \"StreamingDispatchHash\"->FileHash[streamedStructuralSource,\"SHA256\"],")};
If[!And@@(StringCount[reducedProjectionRun,First[#]]===1&/@streamedStructuralChanges),
  Print["FAIL: unique complete structural extraction interfaces"];Quit[1]];
streamedStructuralRun=StringReplace[reducedProjectionRun,streamedStructuralChanges];
If[!SyntaxQ[streamedStructuralRun]||StringReplace[streamedStructuralRun,Reverse/@streamedStructuralChanges]=!=reducedProjectionRun,
  Print["FAIL: unchanged photon projection and acceptance gates"];Quit[1]];
ToExpression[streamedStructuralRun,InputForm];

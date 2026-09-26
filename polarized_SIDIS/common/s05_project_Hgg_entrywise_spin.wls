(* Extract accepted sum entries before applying the inherited photon weights. *)
$HistoryLength=0;
entrywiseSource=FileNameJoin[{Directory[],"common","s05_project_Hgg_entrywise_spin.wls"}];
entrywiseParent=FileNameJoin[{Directory[],"common","s05_project_Hgg_streamed_terms.wls"}];
If[IntegerString[FileHash[entrywiseParent,"SHA256"],16,64]=!=
 "ee3d71aefbbd86bf1f766573062db602b685ef94ae8285c8cf64d35ce84a2c83"||
 !SyntaxQ[Import[entrywiseSource,"Text"]],Quit[1]];
entrywiseText=StringTrim[Import[entrywiseParent,"Text"]];
entrywiseTerminal="ToExpression[streamedStructuralRun,InputForm];";
If[!StringEndsQ[entrywiseText,entrywiseTerminal],Quit[1]];
entrywisePrefix=StringDrop[entrywiseText,-StringLength[entrywiseTerminal]];
If[!SyntaxQ[entrywisePrefix],Quit[1]];ToExpression[entrywisePrefix,InputForm];

entrywiseSpinProjection[values_,weights_,incoming_,outgoing_] := Module[
 {variables,shape,symbolic,contract,linearCheck,packets,evidence,response,started=AbsoluteTime[]},
 variables=DeleteCases[Join[incoming,outgoing],1];shape={Length[outgoing],Length[incoming]};
 gate["actual photon weights independent of spin",Length[values]===Length[weights]&&
   Length[values]>0&&FreeQ[weights,Alternatives@@variables]];
 symbolic=Table[Unique["entrywiseCoefficient"],{k,Length[values]},{j,Length[outgoing]},{i,Length[incoming]}];
 contract[m_] := Sum[incoming[[i]]outgoing[[j]]m[[j,i]],{j,Length[outgoing]},{i,Length[incoming]}];
 linearCheck=Expand[Total[MapThread[Times,{weights,contract/@symbolic}]]-
   contract[Total[MapThread[Times,{weights,symbolic}]]]]===0;
 gate["exact photon and spin projection linearity",linearCheck];
 packets=Table[Print["ENTRYWISE_SPIN_INPUT ",k,"/",Length[values]," bytes ",ByteCount[values[[k]]]];
   streamedStructuralExtract[values[[k]],incoming,outgoing],{k,Length[values]}];
 evidence=KeyDrop[#,"Response"]&/@packets;
 gate["every complete entry reconstructed",And@@Lookup[evidence,"Accepted"]&&
   And@@Flatten[Values[#["Checks"]]&/@evidence]];
 response=Total[MapThread[Times,{weights,Lookup[packets,"Response"]}]];
 gate["complete weighted spin shape",Dimensions[response]===shape];
 Clear[packets,symbolic];ClearSystemCache[];
 <|"Response"->response,"Accepted"->True,"Checks"-><|"ExactPhotonSpinLinearity"->linearCheck,
   "EveryEntryReconstructed"->And@@Lookup[evidence,"Accepted"],"CompleteShape"->(Dimensions[response]===shape)|>,
   "EntryEvidence"->evidence,"Seconds"->AbsoluteTime[]-started,"ResponseBytes"->ByteCount[response],
   "PeakKernelMemoryBytes"->MaxMemoryUsed[]|>];

entrywiseOld= "  photon = Total[(Extract[Transpose[dual], #] entries[\"Photon_\" <> StringRiffle[ToString /@ #, \"_\"]] &) /@ positions];\n  Clear[entries]; ClearSystemCache[];\n"<>streamedStructuralReplacement;
entrywiseNew="  entrywiseWeights=Extract[Transpose[dual],#]&/@positions;\n  entrywiseValues=entries[\"Photon_\"<>StringRiffle[ToString/@#,\"_\"]]&/@positions;\n  {responseSeconds,entrywisePacket}=AbsoluteTiming[entrywiseSpinProjection[entrywiseValues,entrywiseWeights,inVariables,outVariables]];\n  response=entrywisePacket[\"Response\"];reconstruction=KeyDrop[entrywisePacket,\"Response\"];Clear[entrywisePacket];\n  cdrRules=Thread[Join[Rest[inVariables],Rest[outVariables]]->(If[MemberQ[{eIn,eOut},#],1,0]&/@Join[Rest[inVariables],Rest[outVariables]])];\n  entrywiseCDR=Total[MapThread[Times,{entrywiseWeights,(#/.cdrRules)&/@entrywiseValues}]];\n  Clear[entries,entrywiseValues,entrywiseWeights];ClearSystemCache[];";
entrywiseControl="  Clear[control, controlPhoton, controlResponse, proof]; ClearSystemCache[];";
entrywiseControlNew="  entrywiseControlPacket=entrywiseSpinProjection[Extract[control[\"PhotonMatrix\"],#]&/@positions,Extract[Transpose[dual],#]&/@positions,inVariables,outVariables];\n  gate[\"own original weighted response exactly reproduced\",TrueQ[entrywiseControlPacket[\"Accepted\"]]&&bounded[zeroArray[algebraicReduce[entrywiseControlPacket[\"Response\"]-controlResponse]],\"own weighted response comparison\"]];Clear[entrywiseControlPacket];\n"<>entrywiseControl;
entrywiseHermiticity="    gate[\"complete sum Hermiticity \" <> key, bounded[hggReducedHermiticity[entries[key],\n      entries[\"Photon_\" <> StringRiffle[ToString /@ Reverse[position], \"_\"]]], {key, \"full native Hermiticity\"}]],";
entrywiseHermiticityNew="    gate[\"complete sum Hermiticity \" <> key, hggReducedHermiticity[entries[key],\n      entries[\"Photon_\" <> StringRiffle[ToString /@ Reverse[position], \"_\"]]]],";
entrywiseChanges={entrywiseOld->entrywiseNew,entrywiseControl->entrywiseControlNew,
 entrywiseHermiticity->entrywiseHermiticityNew,
 "answer = Total[termConjugate /@ parts];"->"answer = Total[(bounded[termConjugate[#],\"native conjugation term\"]&) /@ parts];",
 "{seconds,reduced}=AbsoluteTiming[algebraicReduce[difference]];"->"{seconds,reduced}=AbsoluteTiming[bounded[algebraicReduce[difference],\"native Hermiticity residual reduction\"]];",
 "  reconstructed = cdrAverage (photon /. cdrRules);"->"  reconstructed = cdrAverage entrywiseCDR;Clear[entrywiseCDR];",
 "\"StreamingDispatchHash\"->FileHash[streamedStructuralSource,\"SHA256\"],"->
 "\"StreamingDispatchHash\"->FileHash[streamedStructuralSource,\"SHA256\"],\n    \"EntrywiseDispatchHash\"->FileHash[entrywiseSource,\"SHA256\"],"};
If[!And@@(StringCount[streamedStructuralRun,First[#]]===1&/@entrywiseChanges),
 Print["FAIL: unique entrywise projection interfaces"];Quit[1]];
entrywiseRun=StringReplace[streamedStructuralRun,entrywiseChanges];
If[!SyntaxQ[entrywiseRun]||StringReplace[entrywiseRun,Reverse/@entrywiseChanges]=!=streamedStructuralRun,
 Print["FAIL: unchanged remaining projection and output equations"];Quit[1]];
ToExpression[entrywiseRun,InputForm];

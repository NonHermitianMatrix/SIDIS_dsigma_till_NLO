(* Preserve the accepted finite assembly and bound its final native file. *)
$HistoryLength=0;
compactAssemblySource=FileNameJoin[{Directory[],"common","s14_assemble_finite_compact_inputs.wls"}];
compactAssemblyPhaseSource=FileNameJoin[{Directory[],"common","s14_assemble_finite_phase_series.wls"}];
compactAssemblyWriterSource=FileNameJoin[{Directory[],"common","s15_finalize_spin_coefficients_compact.wls"}];
If[IntegerString[FileHash[compactAssemblyPhaseSource,"SHA256"],16,64]=!=
    "313f46987aa90ae14205aabec53154b72a96d1cceb5be5dcbca3d7ce770afcf2"||
   IntegerString[FileHash[compactAssemblyWriterSource,"SHA256"],16,64]=!=
    "8f2bb37f8b38701c669a08b9270d290aeb7292ab162f0b66820dea7b8eb3ddc9",
  Print["FAIL: pinned finite assembly and native writer"];Quit[1]];
compactAssemblyText=Import[compactAssemblyPhaseSource,"Text"];
compactAssemblyEntry="ToExpression[phaseRunTail,InputForm];";
compactAssemblyPositions=StringPosition[compactAssemblyText,compactAssemblyEntry];
If[Length[compactAssemblyPositions]=!=1||
   !StringEndsQ[StringTrim[compactAssemblyText],compactAssemblyEntry]||
   !SyntaxQ[Import[compactAssemblySource,"Text"]],
  Print["FAIL: unique terminal finite assembly entry and source syntax"];Quit[1]];
compactAssemblyInitialization=StringTake[compactAssemblyText,First[First[compactAssemblyPositions]]-1];
If[!SyntaxQ[compactAssemblyInitialization],Print["FAIL: finite assembly initialization syntax"];Quit[1]];
compactReleaseAnchor="realFrame=spinReal[\"Frame\"];";
compactReleaseCode=compactReleaseAnchor<>
  "spinRealMemoryEvidence=<|\"TensorBytes\"->ByteCount[spinReal],\"MemoryBefore\"->MemoryInUse[]|>;"<>
  "compactRetainedFrame=spinReal[\"Frame\"];Clear[spinReal];ClearSystemCache[];"<>
  "gate[\"released spin tensor preserves exact frame\",realFrame===compactRetainedFrame];Clear[compactRetainedFrame];"<>
  "AssociateTo[spinRealMemoryEvidence,\"MemoryAfter\"->MemoryInUse[]];Print[\"S14_INPUT_RELEASE \",InputForm[spinRealMemoryEvidence]];";
compactReleaseEntry="ToExpression[phaseRunPrefix,InputForm];";
compactReleaseInitialization=
  "If[StringCount[phaseRunPrefix,compactReleaseAnchor]=!=1,Print[\"FAIL: unique unused tensor release boundary\"];Quit[1]];"<>
  "compactOriginalPrefix=phaseRunPrefix;phaseRunPrefix=StringReplace[phaseRunPrefix,compactReleaseAnchor->compactReleaseCode];"<>
  "If[StringReplace[phaseRunPrefix,compactReleaseCode->compactReleaseAnchor]=!=compactOriginalPrefix,Print[\"FAIL: unchanged finite assembly input equations\"];Quit[1]];"<>
  "If[!SyntaxQ[phaseRunPrefix],Print[\"FAIL: complete compact input syntax\"];Quit[1]];"<>compactReleaseEntry;
If[StringCount[compactAssemblyInitialization,compactReleaseEntry]=!=1,
  Print["FAIL: unique assembly initialization"];Quit[1]];
compactAssemblyInitialization=StringReplace[compactAssemblyInitialization,
  compactReleaseEntry->compactReleaseInitialization];
ToExpression[compactAssemblyInitialization,InputForm];
compactAssemblyWrite[value_,path_] := Module[{serialized},
  Clear[real,spinReal,subtraction,virtual,born];ClearSystemCache[];
  serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
  gate["bounded finite native file "<>StringDrop[path,StringLength[root]+1],
    StringLength[serialized]<128*1024^2];
  Export[path<>".tmp",serialized,"Text"];
  Clear[serialized];ClearSystemCache[];
  gate["exact finite native reload "<>StringDrop[path,StringLength[root]+1],
    Get[path<>".tmp"]===value];
  RenameFile[path<>".tmp",path,OverwriteTarget->True]];
compactAssemblyExport="put[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
gate["unique finite native export",StringCount[phaseRunTail,compactAssemblyExport]===1];
compactAssemblyReplacement=compactAssemblyExport->
  "AssociateTo[result,{\"InputReleaseEvidence\"->spinRealMemoryEvidence,\"StorageSourceHash\"->FileHash[compactAssemblySource,\"SHA256\"]}];compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
compactAssemblyOriginalTail=phaseRunTail;
phaseRunTail=StringReplace[phaseRunTail,compactAssemblyReplacement];
gate["unchanged finite assembly with compact storage",
  StringReplace[phaseRunTail,Reverse[compactAssemblyReplacement]]===compactAssemblyOriginalTail];
gate["complete compact finite assembly syntax",SyntaxQ[phaseRunTail]];
ToExpression[phaseRunTail,InputForm];

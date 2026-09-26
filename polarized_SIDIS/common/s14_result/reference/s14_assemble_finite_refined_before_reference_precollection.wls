(* Preserve the accepted finite assembly and certify factored pole residuals. *)
$HistoryLength=0;
poleRunRoot=Directory[];
poleRunSource=FileNameJoin[{poleRunRoot,"common","s14_assemble_finite_refined.wls"}];
polePhaseSource=FileNameJoin[{poleRunRoot,"common","s14_assemble_finite_phase_series.wls"}];
If[IntegerString[FileHash[polePhaseSource,"SHA256"],16,64]=!=
  "313f46987aa90ae14205aabec53154b72a96d1cceb5be5dcbca3d7ce770afcf2",Quit[1]];
polePhaseText=Import[polePhaseSource,"Text"];
polePhaseBoundary="\nphaseRunTail=\"indices=Tuples\"";
If[StringCount[polePhaseText,polePhaseBoundary]=!=1||
  !SyntaxQ[Import[poleRunSource,"Text"]],
  Print["FAIL: reviewed finite-assembly entry boundary or source syntax"];Quit[1]];
polePhasePosition=First[First[StringPosition[polePhaseText,polePhaseBoundary]]];
polePhasePrefix=StringTake[polePhaseText,polePhasePosition-1];
If[!SyntaxQ[polePhasePrefix],Quit[1]];
ToExpression[polePhasePrefix,InputForm];
poleRunProofPath=FileNameJoin[{root,channel,"s14_pole_factorization_result","s14_result.wl"}];
poleRunReceipt=Import[FileNameJoin[{root,channel,"s14_pole_factorization_result","s14_execution.json"}],"RawJSON"];
gate["accepted own pole-refinement execution",TrueQ[poleRunReceipt["passed"]]&&
  poleRunReceipt["result_sha256"][channel<>"/s14_pole_factorization_result/s14_result.wl"]===
    IntegerString[FileHash[poleRunProofPath,"SHA256"],16,64]];
poleRunProof=Get[poleRunProofPath];
gate["accepted saved and original input-sum poles",poleRunProof["Schema"]===
  "polarized-sidis-assembly-pole-refinement-v1"&&TrueQ[poleRunProof["Accepted"]]&&
  And@@Values[poleRunProof["Checks"]]&&Length[poleRunProof["Rows"]]>0&&
  AllTrue[poleRunProof["Rows"],#["Refined"]===0&&#["InputSumRefined"]===0&]&&
  AllTrue[poleRunProof["ControlRows"],#["Refined"]===0&]];
gate["own exact pole-refinement inputs",channel===poleRunProof["Channel"]&&
  inputHash===poleRunProof["InputHash"]&&inputHashes===poleRunProof["InputHashes"]&&
  sourceHash===poleRunProof["BaselineSourceHash"]&&
  poleRunProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
gate["reviewed pole-refinement source",IntegerString[poleRunProof["SourceHash"],16,64]===
  "adfb5f8c877b57b191a08514488580907bc221008dab61e24ebee6d196cee14f"&&
  poleRunProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_pole_factorization.wls"}],"SHA256"]&&
  poleRunProof["ConfigHash"]===FileHash[FileNameJoin[{root,"common","s14_pole_factorization_inputs.json"}],"SHA256"]];
poleRunLabel=poleRunProof["FailedCheckpoint"]["Label"];
poleRunConditions=(If[Last[poleRunLabel]==="Regular",physical,softPhysical]/.t->poleRunLabel[[2]]omega-s)&&
  If[poleRunLabel[[2]]===0,True,omega>0]&&flavorDomain;
gate["unchanged exact branch conditions",poleRunConditions===poleRunProof["PhysicalConditions"]];
gate["unchanged original finite extraction and zero predicate",
  DownValues[finitePart]===poleRunProof["OriginalFinitePartDefinitions"]&&
  DownValues[zero]===poleRunProof["OriginalZeroDefinitions"]];
DownValues[refineUVResidual]=poleRunProof["RefinementDefinitions"];
DownValues[refineAssemblyPole]=poleRunProof["Definitions"];
gate["exact executed factor-certificate definitions installed",
  DownValues[refineUVResidual]===poleRunProof["RefinementDefinitions"]&&
  DownValues[refineAssemblyPole]===poleRunProof["Definitions"]];
poleFactorCertificates=<||>;
poleOriginalFinite=DownValues[finitePart];
gate["one original finite pole predicate",Count[poleOriginalFinite,zero,Infinity,Heads->True]===1];
DownValues[finitePart]=poleOriginalFinite/.zero->refinedPoleZero;
gate["exact reconstruction of original finite extraction",
  (DownValues[finitePart]/.refinedPoleZero->zero)===poleOriginalFinite];
refinedPoleZero[value_,conditions_] := refineAssemblyPole[value,conditions]===0;
SetAttributes[resumeFinitePart,HoldFirst];
resumeFinitePart[parts_,label_,assumptions_] := Module[{file,saved},
  file=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
  saved=If[FileExistsQ[file],Get[file],<||>];
  If[Lookup[saved,"InputHash",None]===inputHash&&TrueQ[Lookup[saved,"Accepted",False]],
    Return[saved["Finite"]]];
  finitePart[parts,label,assumptions]];
poleOriginalAssembly=DownValues[assemble];
gate["original finite calls available for checkpoint deferral",
  Count[poleOriginalAssembly,finitePart,Infinity,Heads->True]>0];
{poleOriginalSeconds,poleOriginalControl}=AbsoluteTiming[assemble[First[poleRunLabel]]];
gate["accepted complete own checkpoint control",AssociationQ[poleOriginalControl]&&
  TrueQ[poleOriginalControl["Accepted"]]&&And@@Values[poleOriginalControl["Checks"]]];
DownValues[assemble]=poleOriginalAssembly/.finitePart->resumeFinitePart;
gate["exact original assembler restoration",
  (DownValues[assemble]/.resumeFinitePart->finitePart)===poleOriginalAssembly];
{poleDeferredSeconds,poleDeferredControl}=AbsoluteTiming[assemble[First[poleRunLabel]]];
gate["deferred inputs preserve complete own accepted component",AssociationQ[poleDeferredControl]&&
  TrueQ[poleDeferredControl["Accepted"]]&&And@@Values[poleDeferredControl["Checks"]]&&
  KeyTake[poleDeferredControl,{"Index","Branches"}]===KeyTake[poleOriginalControl,{"Index","Branches"}]];
poleCheckpointComparison=<|"Index"->First[poleRunLabel],"OriginalSeconds"->poleOriginalSeconds,
  "DeferredSeconds"->poleDeferredSeconds,"ExactCompleteComponentComparison"->True|>;
Print["FINITE_CHECKPOINT_COMPARISON ",InputForm[poleCheckpointComparison]];
poleFinalPut[value_,path_] := Module[{serialized,temporary=path<>".tmp"},
  serialized="Uncompress["<>ToString[bounded[Compress[value],"finite native compression"],InputForm]<>"]\n";
  gate["bounded complete finite result file",StringLength[serialized]<128*1024^2];
  Export[temporary,serialized,"Text"];
  gate["complete finite result exact native reload",Get[temporary]===value];
  RenameFile[temporary,path,OverwriteTarget->True]];
polePhaseTail=StringDrop[polePhaseText,polePhasePosition];
polePhaseExecute="ToExpression[phaseRunTail,InputForm];";
gate["unique original phase assembly execution",StringCount[polePhaseTail,polePhaseExecute]===1];
polePhaseTail=StringReplace[polePhaseTail,polePhaseExecute->"Null;"];
gate["retained phase adapter syntax",SyntaxQ[polePhaseTail]];
ToExpression[polePhaseTail,InputForm];
poleReferenceAnchor="uPosition=First[FirstPosition[basis[\"SpinLabels\"],\"U\"]];";
poleResultAnchor="\nresult=<|";
gate["unique original reference-comparison boundaries",
  StringCount[phaseRunTail,poleReferenceAnchor]===1&&StringCount[phaseRunTail,poleResultAnchor]===1];
poleReferenceStart=First[First[StringPosition[phaseRunTail,poleReferenceAnchor]]];
poleReferenceEnd=First[First[StringPosition[phaseRunTail,poleResultAnchor]]]-1;
poleOriginalReference=StringTake[phaseRunTail,{poleReferenceStart,poleReferenceEnd}];
gate["two original final-reference zero calls",StringCount[poleOriginalReference,"bounded[zero["]===2];
poleSharedReference=StringReplace[poleOriginalReference,"bounded[zero["->"bounded[poleReferenceZero["];
gate["exact original comparison restoration",
  StringReplace[poleSharedReference,"bounded[poleReferenceZero["->"bounded[zero["]===poleOriginalReference];
poleReferenceZero[value_,conditions_] := Module[{answer=zero[value,conditions]},
  ClearSystemCache[];answer];
poleShareFinalStorage[] := Module[{beforeMemory,afterMemory,seconds,recovered},
  ClearSystemCache[];beforeMemory=MemoryInUse[];
  Print["FINITE_STORAGE_BEFORE_SHARING ",beforeMemory];
  {seconds,recovered}=AbsoluteTiming[Share[]];
  afterMemory=MemoryInUse[];
  poleSharingMeasurement=<|"BeforeBytes"->beforeMemory,"AfterBytes"->afterMemory,
    "ShareRecoveredBytes"->recovered,"Seconds"->seconds|>;
  Print["FINITE_STORAGE_SHARING ",InputForm[poleSharingMeasurement]];Null];
phaseRunTail=StringReplace[phaseRunTail,poleOriginalReference->
  ("poleShareFinalStorage[];\n"<>poleSharedReference)];
gate["unique phase-adapted final export",StringCount[phaseRunTail,phaseRunExport]===1];
phaseRunTail=StringReplace[phaseRunTail,phaseRunExport->
  "AssociateTo[result,{\"PhaseDispatchSourceHash\"->FileHash[phaseRunSource,\"SHA256\"],\"DispatchSourceHash\"->FileHash[poleRunSource,\"SHA256\"],\"PoleRefinementHash\"->FileHash[poleRunProofPath,\"SHA256\"],\"PoleFactorCertificates\"->poleFactorCertificates,\"NativeStorageSharing\"->poleSharingMeasurement,\"DeferredCheckpointInputComparison\"->poleCheckpointComparison}];poleFinalPut[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];"];
gate["complete refined finite assembly syntax",SyntaxQ[phaseRunTail]];
ToExpression[phaseRunTail,InputForm];

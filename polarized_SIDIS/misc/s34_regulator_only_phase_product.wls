(* Preserve the reference Laurent product while limiting expansion to its regulator. *)
localPhaseRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localPhaseSource=ExpandFileName[$InputFileName];
localPhaseInstall[]:=Module[{path,text,first,last,original,changed},
 path=FileNameJoin[{localPhaseRoot,"common","s12_assemble_real_spin.wls"}];
 gate["pinned original Laurent implementation",IntegerString[FileHash[path,"SHA256"],16,64]===
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243"];
 text=ReadString[path];first="laurentProduct[laurent_";last="\n\nsoftPieces[";
 gate["unique complete Laurent definition",StringCount[text,first]===1&&StringCount[text,last]===1];
 original=first<>First[StringSplit[Last[StringSplit[text,first]],last]];
 gate["unique regulator expansion change",StringCount[original,"polynomial=Expand[laurent]"]===1];
 changed=StringReplace[original,"polynomial=Expand[laurent]"->"polynomial=Expand[laurent,eps]"];
 gate["entire original Laurent algorithm retained",SyntaxQ[changed]&&
  StringReplace[changed,"polynomial=Expand[laurent,eps]"->"polynomial=Expand[laurent]"]===original];
 Clear[laurentProduct];ToExpression[changed,InputForm]];

If[Environment["POLARIZED_SIDIS_VALIDATE_PHASE"]==="1",
 $HistoryLength=0;SetDirectory[localPhaseRoot];
 s34Source=localPhaseSource;s34Out=FileNameJoin[{localPhaseRoot,"misc","s34_result"}];
 s34Require[n_,v_]:=If[!TrueQ[v],Print["FAIL: ",n];Quit[1]];
 s34ParentPath=FileNameJoin[{localPhaseRoot,"misc","s14_assemble_Hgg_finite.wls"}];
 s34Parent=StringTrim[ReadString[s34ParentPath]];
 s34Terminal="ToExpression[localFiniteChange[hggNativeFinal,localFiniteTailEdits],InputForm];";
 s34Require["complete unchanged finite initialization",StringEndsQ[s34Parent,s34Terminal]&&
  StringCount[s34Parent,s34Terminal]===1&&SyntaxQ[ReadString[s34Source]]];
 ToExpression[StringDrop[s34Parent,-StringLength[s34Terminal]],InputForm];
 s34ReceiptPath=FileNameJoin[{root,"misc","s33_result","s33_execution.json"}];
 s34ReferencePath=FileNameJoin[{root,"misc","s33_result","s33_result.wl"}];
 s34CapturePath=FileNameJoin[{root,"misc","s33_result","s33_inputs.wl"}];
 s34Receipt=Import[s34ReceiptPath,"RawJSON"];
 gate["genuine accepted original finite control",TrueQ[s34Receipt["passed"]]&&
  s34Receipt["result_sha256"]["misc/s33_result/s33_result.wl"]===IntegerString[FileHash[s34ReferencePath,"SHA256"],16,64]];
 s34Reference=Get[s34ReferencePath];s34Capture=Get[s34CapturePath];
 gate["exact original phase capture and native input identity",TrueQ[s34Reference["Accepted"]]&&
  And@@Values[s34Reference["Checks"]]&&And@@Values[s34Capture["Checks"]]&&
  s34Reference["CaptureHash"]===FileHash[s34CapturePath,"SHA256"]&&
  s34Reference["InputHash"]===inputHash&&s34Capture["InputHash"]===inputHash&&
  s34Reference["InputHashes"]===inputHashes&&s34Capture["InputHashes"]===inputHashes&&
  s34Reference["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
 localPhaseInstall[];
 s34Candidates=Association@Table[
  s34Label=s34Capture[key]["Label"];
  s34Coefficient=strongFactor realBranch[s34Label[[1]],s34Label[[2]],s34Label[[3]]];
  {s34Seconds,s34Value}=AbsoluteTiming[checkedPhaseProduct[s34Coefficient,phase,0,s34Label]];
  Print["REGULATOR_PHASE_CANDIDATE ",key," seconds ",s34Seconds," coefficient_bytes ",ByteCount[s34Coefficient],
   " original_phase_bytes ",ByteCount[First[s34Capture[key]["Parts"]]]," candidate_bytes ",ByteCount[s34Value]];
  key-><|"Label"->s34Label,"Parts"->ReplacePart[s34Capture[key]["Parts"],1->s34Value],
   "Assumptions"->s34Capture[key]["Assumptions"],"Seconds"->s34Seconds|>,{key,{"Own","Actual"}}];
 Clear[real,spinReal,subtraction,physicalComponents,phaseRunProof,geometry,cutGeometry,
  projectorReference,referenceHats,basis,library,s34Coefficient,s34Value];ClearSystemCache[];
 s34Comparisons=Association@Table[
  {s34Seconds,s34Difference}=AbsoluteTiming[MemoryConstrained[TimeConstrained[
   Expand[First[s34Candidates[key]["Parts"]]-First[s34Capture[key]["Parts"]]],600,$Aborted],4*1024^3,$Aborted]];
  gate["complete original phase exactly reconstructed "<>key,s34Difference===0];
  Print["REGULATOR_PHASE_RECONSTRUCTION ",key," seconds ",s34Seconds];
  ClearSystemCache[];key->s34Seconds,{key,{"Own","Actual"}}];
 Clear[s34Capture];ClearSystemCache[];
 s34Work=FileNameJoin[{root,"misc","s34_work"}];If[!DirectoryQ[s34Work],CreateDirectory[s34Work]];
 s34Finite=Association@Table[
  s34Packet=s34Candidates[key];
  {s34Seconds,s34Value}=AbsoluteTiming[Block[{cache=s34Work},
   finitePart[s34Packet["Parts"],s34Packet["Label"],s34Packet["Assumptions"]]]];
  gate["complete accepted finite value reconstructed "<>key,
   MemoryConstrained[TimeConstrained[Expand[s34Value-s34Reference[key<>"Finite"]],600,$Aborted],4*1024^3,$Aborted]===0];
  Print["REGULATOR_FINITE_ACCEPTED ",key," seconds ",s34Seconds," finite_bytes ",ByteCount[s34Value]];
  ClearSystemCache[];key-><|"Value"->s34Value,"Seconds"->s34Seconds|>,{key,{"Own","Actual"}}];
 s34Result=<|"Schema"->"polarized-sidis-regulator-only-phase-comparison-v1",
  "SourceHash"->FileHash[s34Source,"SHA256"],"ReferenceHash"->FileHash[s34ReferencePath,"SHA256"],
  "CaptureHash"->FileHash[s34CapturePath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
  "LaurentDefinitions"->DownValues[laurentProduct],"Candidates"->s34Candidates,
  "PhaseComparisonSeconds"->s34Comparisons,"Finite"->s34Finite,"Checks"->checks,"Accepted"->True,
  "NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>;
 s34Serialized="Uncompress["<>ToString[Compress[s34Result],InputForm]<>"]\n";
 gate["bounded exact phase proof",StringLength[s34Serialized]<128*1024^2];
 s34ResultPath=FileNameJoin[{s34Out,"s34_result.wl"}];Export[s34ResultPath,s34Serialized,"Text"];
 gate["exact phase proof reload",Get[s34ResultPath]===s34Result];
 Export[FileNameJoin[{s34Out,"s34_checks.json"}],<|"checks"->checks,
  "phase_comparison_seconds"->s34Comparisons|>,"RawJSON"];
 Print["PASS: regulator-only Hgg phase product validated"];Quit[0]];

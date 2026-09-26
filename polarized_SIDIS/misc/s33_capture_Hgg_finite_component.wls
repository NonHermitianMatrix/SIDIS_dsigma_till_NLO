(* Isolate the actual finite-component inputs without changing their algebra. *)
$HistoryLength=0;
s33Root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[s33Root];
s33Source=ExpandFileName[$InputFileName];
s33ConfigPath=FileNameJoin[{s33Root,"misc","s33_inputs.json"}];
s33Config=Import[s33ConfigPath,"RawJSON"];
s33Require[n_,v_]:=If[!TrueQ[v],Print["FAIL: ",n];Quit[1]];
s33SHA[p_]:=IntegerString[FileHash[p,"SHA256"],16,64];
s33AssemblyPath=FileNameJoin[{s33Root,s33Config["assembly_source"]}];
s33Require["original assembly and failure identities",
 s33SHA[s33AssemblyPath]===s33Config["source_sha256"]&&
 s33SHA[FileNameJoin[{s33Root,"misc","s14_inputs.json"}]]===s33Config["assembly_config_sha256"]&&
 s33SHA[FileNameJoin[{s33Root,"misc","s14_result","s14_execution.json"}]]===s33Config["failure_receipt_sha256"]];
s33Original=StringTrim[ReadString[s33AssemblyPath]];
s33Terminal="ToExpression[localFiniteChange[hggNativeFinal,localFiniteTailEdits],InputForm];";
s33Require["unique complete original entry",StringEndsQ[s33Original,s33Terminal]&&
 StringCount[s33Original,s33Terminal]===1&&SyntaxQ[s33Original]&&SyntaxQ[ReadString[s33Source]]];
s33Prefix=StringDrop[s33Original,-StringLength[s33Terminal]];
s33Require["original initialization exactly retained",s33Prefix<>s33Terminal===s33Original&&SyntaxQ[s33Prefix]];
ToExpression[s33Prefix,InputForm];
s33Out=FileNameJoin[{root,"misc","s33_result"}];
s33Work=FileNameJoin[{root,"misc","s33_work"}];
If[!DirectoryQ[s33Work],CreateDirectory[s33Work]];
s33FiniteDefinitions=DownValues[finitePart];
s33ActualLabel=s33Config["actual_label"];s33OwnLabel=s33Config["own_label"];
s33OwnPath=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[s33OwnLabel,"SHA256"],16]<>".wl"}];
s33Own=Get[s33OwnPath];
gate["own accepted finite checkpoint",s33Own["Label"]===s33OwnLabel&&
 s33Own["InputHash"]===inputHash&&TrueQ[s33Own["Accepted"]]];
s33Capture[label_]:=Block[{finitePart},Clear[finitePart];
 finitePart[parts_,current_,assumptions_]:=If[current===label,
  Throw[<|"Label"->current,"Parts"->parts,"Assumptions"->assumptions|>,"s33Capture"],0];
 Catch[assemble[First[label]],"s33Capture"]];
Print["ACTUAL_PHASE_EQUATION ",InputForm[phase]];
{s33OwnSeconds,s33OwnParts}=AbsoluteTiming[s33Capture[s33OwnLabel]];
gate["own captured input identity",AssociationQ[s33OwnParts]&&s33OwnParts["Label"]===s33OwnLabel];
ClearSystemCache[];
{s33ActualSeconds,s33ActualParts}=AbsoluteTiming[s33Capture[s33ActualLabel]];
gate["actual captured input identity",AssociationQ[s33ActualParts]&&s33ActualParts["Label"]===s33ActualLabel];
gate["native finite definition restored",DownValues[finitePart]===s33FiniteDefinitions];
s33CaptureResult=<|"Schema"->"polarized-sidis-finite-input-capture-v1",
 "SourceHash"->FileHash[s33Source,"SHA256"],"ConfigHash"->FileHash[s33ConfigPath,"SHA256"],
 "AssemblySourceHash"->FileHash[s33AssemblyPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
 "Own"->s33OwnParts,"Actual"->s33ActualParts,"OwnAccepted"->s33Own,
 "OwnCheckpointHash"->FileHash[s33OwnPath,"SHA256"],"OwnSeconds"->s33OwnSeconds,
 "ActualSeconds"->s33ActualSeconds,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Checks"->checks|>;
s33Write[value_,path_]:=Module[{serialized},serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
 gate["bounded captured native file",StringLength[serialized]<128*1024^2];Export[path,serialized,"Text"];
 gate["exact captured native reload",Get[path]===value]];
s33Write[s33CaptureResult,FileNameJoin[{s33Out,"s33_inputs.wl"}]];
Print["FINITE_INPUT_BYTES ",InputForm[<|"OwnParts"->(ByteCount/@s33OwnParts["Parts"]),
 "ActualParts"->(ByteCount/@s33ActualParts["Parts"]),"MemoryBeforeRelease"->MemoryInUse[]|>]];
Clear[real,spinReal,subtraction,physicalComponents,phaseRunProof,geometry,cutGeometry,
 projectorReference,referenceHats,basis,library,s33CaptureResult];ClearSystemCache[];
Print["FINITE_MEMORY_AFTER_RELEASE ",MemoryInUse[]];
s33Native[value_]:=Block[{cache=s33Work},finitePart[value["Parts"],value["Label"],value["Assumptions"]]];
{s33OwnFiniteSeconds,s33OwnFinite}=AbsoluteTiming[s33Native[s33OwnParts]];
gate["entire own accepted finite value preserved",s33OwnFinite===s33Own["Finite"]];
ClearSystemCache[];
{s33ActualFiniteSeconds,s33ActualFinite}=AbsoluteTiming[s33Native[s33ActualParts]];
s33Result=<|"Schema"->"polarized-sidis-isolated-finite-component-v1",
 "SourceHash"->FileHash[s33Source,"SHA256"],"ConfigHash"->FileHash[s33ConfigPath,"SHA256"],
 "CaptureHash"->FileHash[FileNameJoin[{s33Out,"s33_inputs.wl"}],"SHA256"],
 "InputHash"->inputHash,"InputHashes"->inputHashes,"OwnLabel"->s33OwnLabel,"ActualLabel"->s33ActualLabel,
 "OwnFinite"->s33OwnFinite,"ActualFinite"->s33ActualFinite,"OwnSeconds"->s33OwnFiniteSeconds,
 "ActualSeconds"->s33ActualFiniteSeconds,"FiniteDefinitions"->s33FiniteDefinitions,
 "Checks"->checks,"Accepted"->True,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion}|>;
s33Write[s33Result,FileNameJoin[{s33Out,"s33_result.wl"}]];
Export[FileNameJoin[{s33Out,"s33_checks.json"}],<|"checks"->checks,
 "own_seconds"->s33OwnFiniteSeconds,"actual_seconds"->s33ActualFiniteSeconds|>,"RawJSON"];
Print["PASS: isolated Hgg finite component validated"];Quit[0];

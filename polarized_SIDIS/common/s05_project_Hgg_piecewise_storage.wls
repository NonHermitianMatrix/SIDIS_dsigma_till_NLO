(* Keep projection equations unchanged; compress native response entries separately. *)
$HistoryLength=0;
piecewiseSource=FileNameJoin[{Directory[],"common","s05_project_Hgg_piecewise_storage.wls"}];
piecewiseParent=FileNameJoin[{Directory[],"common","s05_project_Hgg_entrywise_spin.wls"}];
If[IntegerString[FileHash[piecewiseParent,"SHA256"],16,64]=!=
 "cf900acf03c03f50f365d844143f7c8107b34d15e80d180c2aa05fb295f7c1b9"||
 !SyntaxQ[Import[piecewiseSource,"Text"]],Quit[1]];
piecewiseText=StringTrim[Import[piecewiseParent,"Text"]];
piecewiseTerminal="ToExpression[entrywiseRun,InputForm];";
If[!StringEndsQ[piecewiseText,piecewiseTerminal],Quit[1]];
piecewisePrefix=StringDrop[piecewiseText,-StringLength[piecewiseTerminal]];
If[!SyntaxQ[piecewisePrefix],Quit[1]];ToExpression[piecewisePrefix,InputForm];

writePiecewiseProjection[value_,resultPath_,relativeBase_] := Module[
 {shape,keys,metadata,positions,piece,compressed,chunk,parts={},groups={},indices,path,directory,
 reader,roundTrip,manifest,manifestPath,started=AbsoluteTime[],before=MemoryInUse[],n=0},
 shape=Dimensions[value["Response"]];keys=Keys[value];metadata=KeyDrop[value,{"Response","CDRPhotonCoefficient"}];
 gate["complete piecewise projection schema",AssociationQ[value]&&Length[shape]===2&&
   MemberQ[keys,"Response"]&&MemberQ[keys,"CDRPhotonCoefficient"]];
 positions=Tuples[Range/@shape];directory=DirectoryName[resultPath];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 Print["PIECEWISE_STORAGE_INPUT ",InputForm[<|"Bytes"->ByteCount[value],"ResponseBytes"->ByteCount[value["Response"]],
   "CDRBytes"->ByteCount[value["CDRPhotonCoefficient"]],"MemoryBytes"->before,"Shape"->shape|>]];
 Do[
   piece=Which[k===1,metadata,k===Length[positions]+2,value["CDRPhotonCoefficient"],True,Extract[value["Response"],positions[[k-1]]]];
   compressed=bounded[Compress[piece],{"projection piece compression",k}];
   gate["exact individual native piece round trip",bounded[Uncompress[compressed]===piece,{"projection piece reload",k}]];
   indices={};
   Do[n++;AppendTo[indices,n];
     chunk=StringTake[compressed,{offset,Min[offset+32*1024^2-1,StringLength[compressed]]}];
     path=FileNameJoin[{directory,"s05_payload_"<>IntegerString[n,10,4]<>".txt"}];
     Export[path<>".tmp",chunk,"Text"];
     gate["bounded exact native payload text",FileByteCount[path<>".tmp"]<128*1024^2&&Import[path<>".tmp","Text"]===chunk];
     RenameFile[path<>".tmp",path,OverwriteTarget->True];
     AppendTo[parts,<|"file"->relativeBase<>"/"<>FileNameTake[path],"name"->FileNameTake[path],
       "bytes"->FileByteCount[path],"sha256"->IntegerString[FileHash[path,"SHA256"],16,64]|>],
     {offset,1,StringLength[compressed],32*1024^2}];
   AppendTo[groups,indices];Clear[piece,compressed,chunk];ClearSystemCache[];
   Print["PIECEWISE_STORAGE_PROGRESS ",k,"/",Length[positions]+2," memory ",MemoryInUse[]],
   {k,Length[positions]+2}];
 gate["bounded complete projection payload inventory",0<Length[parts]<=64&&Flatten[groups]===Range[Length[parts]]];
 reader="Module[{paths,hashes,groups,readPiece,metadata,response,cdr,keys}, paths=FileNameJoin[{DirectoryName[$InputFileName],#}]&/@"<>
   ToString[Lookup[parts,"name"],InputForm]<>"; hashes="<>ToString[FromDigits[#,16]&/@Lookup[parts,"sha256"],InputForm]<>
   "; groups="<>ToString[groups,InputForm]<>"; keys="<>ToString[keys,InputForm]<>"; "<>
   "If[!And@@(FileExistsQ/@paths)||(FileHash[#,\"SHA256\"]&/@paths)=!=hashes,Print[\"FAIL: native projection payload identity\"];Return[$Failed]]; "<>
   "readPiece[k_]:=Uncompress[StringJoin[Import[#,\"Text\"]&/@paths[[groups[[k]]]]]]; metadata=readPiece[1]; "<>
   "response=ArrayReshape[Table[readPiece[k],{k,2,Length[groups]-1}],"<>ToString[shape,InputForm]<>
   "]; cdr=readPiece[Length[groups]]; AssociationThread[keys,(Switch[#,\"Response\",response,\"CDRPhotonCoefficient\",cdr,_,metadata[#]]&/@keys)]]\n";
 gate["complete piecewise native reader syntax",SyntaxQ[reader]];
 Export[resultPath<>".tmp",reader,"Text"];
 gate["bounded piecewise reader",FileByteCount[resultPath<>".tmp"]<128*1024^2];
 Clear[metadata];ClearSystemCache[];
 roundTrip=Get[resultPath<>".tmp"]===value;
 gate["complete piecewise native exact round trip",roundTrip];
 RenameFile[resultPath<>".tmp",resultPath,OverwriteTarget->True];
 manifest=<|"schema"->"polarized-sidis-chunked-wolfram-result-v1","result"->relativeBase<>"/"<>FileNameTake[resultPath],
   "result_sha256"->IntegerString[FileHash[resultPath,"SHA256"],16,64],"payloads"->parts,
   "expression_bytes"->ByteCount[value],"payload_bytes"->Total[Lookup[parts,"bytes"]],
   "exact_round_trip"->roundTrip,"serialization_seconds"->AbsoluteTime[]-started,
   "piece_groups"->groups,"storage_source_sha256"->IntegerString[FileHash[piecewiseSource,"SHA256"],16,64],
   "memory_before_bytes"->before,"memory_after_bytes"->MemoryInUse[],"peak_memory_bytes"->MaxMemoryUsed[]|>;
 manifestPath=FileNameJoin[{directory,"s05_payload_manifest.json"}];Export[manifestPath<>".tmp",manifest,"RawJSON"];
 gate["exact piecewise manifest reload",KeyDrop[Import[manifestPath<>".tmp","RawJSON"],"serialization_seconds"]===KeyDrop[manifest,"serialization_seconds"]];
 RenameFile[manifestPath<>".tmp",manifestPath,OverwriteTarget->True];manifest];

piecewiseControl="  Clear[control, controlPhoton, controlResponse, proof]; ClearSystemCache[];";
piecewiseControlNew="  piecewiseControlValue=<|\"Response\"->controlResponse,\"CDRPhotonCoefficient\"->controlPhoton,\"ControlHash\"->FileHash[controlPath,\"SHA256\"],\"InputHash\"->inputHash|>;\n  piecewiseControlRelative=\"cache/s05_piecewise_storage_control_\"<>ToString[$ProcessID];\n  piecewiseControlPath=FileNameJoin[{root,piecewiseControlRelative,\"s05_result.wl\"}];\n  piecewiseControlEvidence=writePiecewiseProjection[piecewiseControlValue,piecewiseControlPath,piecewiseControlRelative];\n  gate[\"complete own accepted projection storage comparison\",TrueQ[piecewiseControlEvidence[\"exact_round_trip\"]]];\n  DeleteDirectory[DirectoryName[piecewiseControlPath],DeleteContents->True];Clear[piecewiseControlValue];\n"<>piecewiseControl;
piecewiseWrite="  put[result, FileNameJoin[{directory, \"s05_result.wl\"}]];";
piecewiseWriteNew="  piecewiseEvidence=writePiecewiseProjection[result,FileNameJoin[{directory,\"s05_result.wl\"}],StringDrop[directory,StringLength[root]+1]];";
piecewiseChanges={piecewiseControl->piecewiseControlNew,piecewiseWrite->piecewiseWriteNew,
 "\"EntrywiseDispatchHash\"->FileHash[entrywiseSource,\"SHA256\"],"->
 "\"EntrywiseDispatchHash\"->FileHash[entrywiseSource,\"SHA256\"],\"StorageDispatchHash\"->FileHash[piecewiseSource,\"SHA256\"],\"OwnStorageComparison\"->piecewiseControlEvidence,"};
If[!And@@(StringCount[entrywiseRun,First[#]]===1&/@piecewiseChanges),Print["FAIL: unique piecewise storage interfaces"];Quit[1]];
piecewiseRun=StringReplace[entrywiseRun,piecewiseChanges];
If[!SyntaxQ[piecewiseRun]||StringReplace[piecewiseRun,Reverse/@piecewiseChanges]=!=entrywiseRun,
 Print["FAIL: unchanged full projection equations and gates"];Quit[1]];
ToExpression[piecewiseRun,InputForm];

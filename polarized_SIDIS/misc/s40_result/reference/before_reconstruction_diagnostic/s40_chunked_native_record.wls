(* Bounded native storage; mathematical expressions and schemas are unchanged. *)
localChunkSource=ExpandFileName[$InputFileName];
localChunkRoot=DirectoryName[DirectoryName[localChunkSource]];
localChunkWrite[value_,path_]:=Module[
 {directory,partDirectory,relative,manifest=<||>,originals=<||>,pack,intern,template,
  serialized,index,loader,temporary,bytesBefore=MemoryInUse[],threshold=32*1024^2},
 gate["native chunk marker is unassigned",OwnValues[Global`polarizedNativeChunk]==={}&&
  DownValues[Global`polarizedNativeChunk]==={}&&FreeQ[value,Global`polarizedNativeChunk]];
 directory=DirectoryName[path];If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 relative=FileBaseName[path]<>"_parts";partDirectory=FileNameJoin[{directory,relative}];
 If[!DirectoryQ[partDirectory],CreateDirectory[partDirectory]];
 intern[x_]:=Module[{key,file,serial,reloaded},
  key=IntegerString[Hash[x,"SHA256"],16,64];
  If[KeyExistsQ[originals,key],
   gate["exact repeated native chunk",originals[key]===x],
   AssociateTo[originals,key->x];file=FileNameJoin[{partDirectory,key<>".wl"}];
   serial="Uncompress["<>ToString[Compress[x],InputForm]<>"]\n";
   gate["bounded native chunk",StringLength[serial]<128*1024^2];
   Export[file<>".tmp",serial,"Text"];Clear[serial];ClearSystemCache[];
   reloaded=Get[file<>".tmp"];
   gate["exact native chunk reload",reloaded===x];Clear[reloaded];ClearSystemCache[];
   RenameFile[file<>".tmp",file,OverwriteTarget->True];
   AssociateTo[manifest,key-><|"File"->FileNameJoin[{relative,key<>".wl"}],
    "SHA256"->IntegerString[FileHash[file,"SHA256"],16,64]|>]];
  Global`polarizedNativeChunk[key]];
 pack[x_]:=If[MemberQ[{Association,List},Head[x]]&&ByteCount[x]>threshold,Map[pack,x],intern[x]];
 template=pack[value];
 gate["entire native record exactly reconstructs",
  (template/.HoldPattern[Global`polarizedNativeChunk[key_String]]:>originals[key])===value];
 index=<|"Schema"->"polarized-sidis-chunked-native-v1","Template"->template,"Parts"->manifest,
  "WriterSHA256"->IntegerString[FileHash[localChunkSource,"SHA256"],16,64]|>;
 loader="Module[{dir=DirectoryName[ExpandFileName[$InputFileName]],index=Uncompress[INDEX],parts=<||>,load,result},"<>
  "load[key_String]:=If[KeyExistsQ[parts,key],parts[key],Module[{row,file,v},"<>
  "row=Lookup[index[\"Parts\"],key,Missing[\"Part\"]];If[MissingQ[row],Throw[$Failed,\"NativeChunks\"]];"<>
  "file=FileNameJoin[{dir,row[\"File\"]}];If[!FileExistsQ[file]||"<>
  "IntegerString[FileHash[file,\"SHA256\"],16,64]=!=row[\"SHA256\"],Throw[$Failed,\"NativeChunks\"]];"<>
  "v=Get[file];If[v===$Failed||v===$Aborted,Throw[$Failed,\"NativeChunks\"]];AssociateTo[parts,key->v];v]];"<>
  "Catch[result=index[\"Template\"]/.HoldPattern[Global`polarizedNativeChunk[key_String]]:>load[key];"<>
  "If[!FreeQ[result,Global`polarizedNativeChunk],Throw[$Failed,\"NativeChunks\"]];result,\"NativeChunks\"]]\n";
 gate["unique native manifest insertion",StringCount[loader,"INDEX"]===1];
 serialized=StringReplace[loader,"INDEX"->ToString[Compress[index],InputForm]];
 gate["bounded complete native index",SyntaxQ[serialized]&&StringLength[serialized]<128*1024^2];
 temporary=path<>".tmp";Export[temporary,serialized,"Text"];
 gate["exact native index bytes",ReadString[temporary]===serialized];
 RenameFile[temporary,path,OverwriteTarget->True];
 Print["NATIVE_CHUNK_RECORD ",FileNameTake[path]," pieces ",Length[manifest],
  " memory_before ",bytesBefore," memory_after ",MemoryInUse[]];
 <|"Path"->path,"Parts"->manifest,"WriterSHA256"->index["WriterSHA256"]|>];

If[Environment["POLARIZED_SIDIS_VALIDATE_CHUNK_WRITER"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 SetDirectory[localChunkRoot];root=localChunkRoot;checks=<||>;
 gate[n_,x_]:=If[TrueQ[x],If[!KeyExistsQ[checks,n],Print["PASS: ",n]];AssociateTo[checks,n->True],
  Print["FAIL: ",n];Quit[1]];
 config=Import[FileNameJoin[{root,"misc","s40_inputs.json"}],"RawJSON"];
 gate["bound entire native writer",config["source_sha256"]===IntegerString[FileHash[localChunkSource,"SHA256"],16,64]&&
  SyntaxQ[ReadString[localChunkSource]]];
 KeyValueMap[gate["pinned chunk-writer input "<>#1,
  IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,config["input_sha256"]];
 own=Get[FileNameJoin[{root,"misc","s35_result","s35_result.wl"}]];
 actual=Get[FileNameJoin[{root,"misc","s37_result","s37_result.wl"}]];
 gate["accepted native own and actual inputs",And@@Values[own["Checks"]]&&And@@Values[actual["Checks"]]];
 value=<|"Own"->own,"Actual"->actual|>;Clear[own,actual];ClearSystemCache[];
 out=FileNameJoin[{root,"misc","s40_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 path=FileNameJoin[{out,"s40_roundtrip.wl"}];
 {seconds,storage}=AbsoluteTiming[localChunkWrite[value,path]];
 gate["actual record exercises bounded pieces",Length[storage["Parts"]]>1];
 gate["entire actual native reader roundtrip",Get[path]===value];
 Export[FileNameJoin[{out,"s40_checks.json"}],<|"checks"->checks,
  "source_sha256"->IntegerString[FileHash[localChunkSource,"SHA256"],16,64],
  "seconds"->seconds,"part_count"->Length[storage["Parts"]],"parts"->storage["Parts"],
  "native_versions"->{$Version,FeynCalc`$FeynCalcVersion}|>,"RawJSON"];
 Print["PASS: bounded native record writer"];Quit[0]];

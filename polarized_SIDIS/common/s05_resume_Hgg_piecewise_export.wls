(* Finish a fully written piecewise projection in a fresh native kernel. *)
$HistoryLength=0;
resumeSource=FileNameJoin[{Directory[],"common","s05_resume_Hgg_piecewise_export.wls"}];
resumeBase=FileNameJoin[{Directory[],"common","s05_project_Hgg_component_sum.wls"}];
resumeText=StringTrim[Import[resumeBase,"Text"]];
resumeTerminal="ToExpression[assemblyRunTail, InputForm];";
If[!StringEndsQ[resumeText,resumeTerminal]||!SyntaxQ[Import[resumeSource,"Text"]],Quit[1]];
resumePrefix=StringDrop[resumeText,-StringLength[resumeTerminal]];
If[!SyntaxQ[resumePrefix],Quit[1]];ToExpression[resumePrefix,InputForm];

assembleCompletedPairs[] := Module[{settings,previous,temporary,log,tail,held,pieceGroups,shape,names,paths,
 pieceHashes,savedKeys,packet,metadata,positions,piece,readPiece,equalities={},component,dual,required,
 expectedSums,readSeconds,pieceSeconds,started=AbsoluteTime[],directory,relative,resultPath,
 manifest,manifestPath,payloads,report,roundTrip,temporaryHash,originalBytes},
 gate["fresh projection export setup",channel==="Hgg"&&workerCount===0&&!validationOnly];
 settings=Import[FileNameJoin[{root,Environment["POLARIZED_SIDIS_PIECEWISE_RESUME_INPUTS"]}],"RawJSON"];
 KeyValueMap[gate["bound complete export input "<>#1,
   IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,settings["files"]];
 previous=Import[FileNameJoin[{root,settings["previous_receipt"]}],"RawJSON"];
 gate["stopped original piecewise writer",previous["job_id"]===settings["previous_job_id"]&&
   previous["passed"]===False&&previous["exit_code"]===1&&previous["reason"]==="normal_exit"&&
   previous["reviewed_sha256"]["common/s05_project_Hgg_piecewise_storage.wls"]===
     IntegerString[FileHash[FileNameJoin[{root,"common","s05_project_Hgg_piecewise_storage.wls"}],"SHA256"],16,64]];
 temporary=FileNameJoin[{root,settings["temporary"]}];temporaryHash=FileHash[temporary,"SHA256"];
 held=ToExpression[Import[temporary,"Text"],InputForm,HoldComplete];
 pieceGroups=Cases[held,HoldPattern[Set[Global`groups,v_List]]:>v,Infinity];
 pieceHashes=Cases[held,HoldPattern[Set[Global`hashes,v_List]]:>v,Infinity];
 savedKeys=Cases[held,HoldPattern[Set[Global`keys,v_List]]:>v,Infinity];
 shape=Cases[held,HoldPattern[ArrayReshape[_,v_List]]:>v,Infinity];
 gate["unique original native loader fields",Length/@{pieceGroups,pieceHashes,savedKeys,shape}==={1,1,1,1}];
 pieceGroups=First[pieceGroups];pieceHashes=First[pieceHashes];savedKeys=First[savedKeys];shape=First[shape];
 names=Cases[held,name_String/;StringMatchQ[name,"s05_payload_"~~DigitCharacter..~~".txt"]:>name,Infinity];
 paths=FileNameJoin[{DirectoryName[temporary],#}]&/@names;
 gate["complete bound piece inventory",DuplicateFreeQ[names]&&0<Length[names]<=64&&
   Flatten[pieceGroups]===Range[Length[names]]&&AllTrue[pieceGroups,Length[#]>0&]&&
   Length[pieceHashes]===Length[names]&&(FileHash[#,"SHA256"]&/@paths)===pieceHashes&&
   Length[shape]===2&&Length[pieceGroups]===(Times@@shape)+2&&DuplicateFreeQ[savedKeys]&&
   MemberQ[savedKeys,"Response"]&&MemberQ[savedKeys,"CDRPhotonCoefficient"]];
 log=Import[FileNameJoin[{root,settings["previous_log"]}],"Text"];
 tail=Last[StringSplit[log,"\"PIECEWISE_STORAGE_INPUT \""]];
 gate["original writer completed every exact native piece",StringContainsQ[log,"No more memory available."]&&
   And@@Table[StringContainsQ[tail,"\"PIECEWISE_STORAGE_PROGRESS \""<>ToString[k]<>"\"/\""<>ToString[Length[pieceGroups]]],
     {k,Length[pieceGroups]}]&&!StringContainsQ[tail,"\"FAIL:"]];
 Clear[componentPacket,componentProof];ClearSystemCache[];
 Print["FRESH_COMPLETE_PROJECTION_READ ",settings["temporary"]," memory ",MemoryInUse[]];
 {readSeconds,packet}=AbsoluteTiming[MemoryConstrained[TimeConstrained[Get[temporary],1200,
   gate["fresh complete projection read time",False]],16*1024^3,gate["fresh complete projection read memory",False]]];
 component=settings["component"];
 gate["complete original projection conventions",AssociationQ[packet]&&
   packet["Schema"]==="polarized-sidis-complete-photon-spin-component-v1"&&packet["Channel"]===channel&&
   packet["Component"]===component&&packet["PhotonLabel"]===basis["PhotonLabels"][[component]]&&
   packet["InputHash"]===inputHash&&packet["InputHashes"]===inputHashes&&
   packet["SourceHash"]===FileHash[resumeBase,"SHA256"]&&packet["BasisHash"]===FileHash[basisPath,"SHA256"]&&
   packet["NativeVersions"]==={$Version,$FeynCalcVersion}&&
   packet["IncomingVariables"]===inVariables&&packet["OutgoingVariables"]===outVariables&&
   TrueQ[packet["OwnStorageComparison"]["exact_round_trip"]]&&
   packet["StorageDispatchHash"]===FileHash[FileNameJoin[{root,"common","s05_project_Hgg_piecewise_storage.wls"}],"SHA256"]&&
   packet["EntrywiseDispatchHash"]===FileHash[FileNameJoin[{root,"common","s05_project_Hgg_entrywise_spin.wls"}],"SHA256"]&&
   TrueQ[packet["Reconstruction"]["Accepted"]]&&And@@Values[packet["Reconstruction"]["Checks"]]&&
   TrueQ[packet["Checks"]["entire actual spin polynomial reconstructed"]]&&And@@Values[packet["Checks"]]];
 dual=basis["PhotonDual"][[component]];
 positions=Position[Transpose[dual],v_/;v=!=0,{2},Heads->False];required=Union[positions,Reverse/@positions];
 expectedSums=(channel<>"/s05_component_sums_result/Photon_"<>StringRiffle[ToString/@#,"_"]<>"/s05_result.wl")&/@required;
 gate["complete original photon sum support",Sort[Keys[packet["SumInputHashes"]]]===Sort[expectedSums]];
 KeyValueMap[gate["unchanged actual photon sum "<>#1,FileHash[FileNameJoin[{root,#1}],"SHA256"]===#2]&,packet["SumInputHashes"]];
 gate["complete original output layout",Keys[packet]===savedKeys&&Dimensions[packet["Response"]]===shape&&
   shape==={Length[outVariables],Length[inVariables]}];
 originalBytes=ByteCount[packet];
 gate["complete loaded size measurement",IntegerQ[originalBytes]&&originalBytes>0];
 Print["FRESH_NATIVE_SIZE ",originalBytes," original writer record ",First[StringSplit[tail,"\n"]]];
 readPiece[k_] := Uncompress[StringJoin[Import[#,"Text"]&/@paths[[pieceGroups[[k]]]]]];
 positions=Tuples[Range/@shape];
 {pieceSeconds,roundTrip}=AbsoluteTiming[
   Do[
     piece=bounded[readPiece[k],{"fresh original native piece",k}];
     AppendTo[equalities,Which[k===1,piece===KeyDrop[packet,{"Response","CDRPhotonCoefficient"}],
       k===Length[pieceGroups],piece===packet["CDRPhotonCoefficient"],
       True,piece===Extract[packet["Response"],positions[[k-1]]]]];
     gate["exact full loader piece "<>ToString[k],Last[equalities]];
     Clear[piece];ClearSystemCache[];
     Print["FRESH_PROJECTION_PIECE ",k,"/",Length[pieceGroups]," memory ",MemoryInUse[]],{k,Length[pieceGroups]}];
   Length[equalities]===Length[pieceGroups]&&And@@equalities];
 gate["complete native output reload exact",roundTrip];
 gate["temporary reader remains unchanged",FileHash[temporary,"SHA256"]===temporaryHash];
 directory=DirectoryName[temporary];relative=StringDrop[directory,StringLength[root]+1];
 resultPath=FileNameJoin[{directory,"s05_result.wl"}];
 gate["no existing published projection overwritten",!FileExistsQ[resultPath]];
 RenameFile[temporary,resultPath];
 payloads=MapThread[<|"file"->relative<>"/"<>#1,"name"->#1,"bytes"->FileByteCount[#2],
   "sha256"->IntegerString[#3,16,64]|>&,{names,paths,pieceHashes}];
 manifest=<|"schema"->"polarized-sidis-chunked-wolfram-result-v1","result"->relative<>"/s05_result.wl",
   "result_sha256"->IntegerString[FileHash[resultPath,"SHA256"],16,64],"payloads"->payloads,
   "expression_bytes"->originalBytes,"payload_bytes"->Total[Lookup[payloads,"bytes"]],"exact_round_trip"->roundTrip,
   "piece_groups"->pieceGroups,"storage_source_sha256"->IntegerString[packet["StorageDispatchHash"],16,64],
   "resume_source_sha256"->IntegerString[FileHash[resumeSource,"SHA256"],16,64],
   "original_job_id"->previous["job_id"],"serialization_seconds"->readSeconds+pieceSeconds|>;
 manifestPath=FileNameJoin[{directory,"s05_payload_manifest.json"}];Export[manifestPath<>".tmp",manifest,"RawJSON"];
 gate["exact resumed manifest reload",KeyDrop[Import[manifestPath<>".tmp","RawJSON"],"serialization_seconds"]===KeyDrop[manifest,"serialization_seconds"]];
 RenameFile[manifestPath<>".tmp",manifestPath,OverwriteTarget->True];
 report=<|"channel"->channel,"component"->component,"checks"->Join[packet["Checks"],checks],
   "recovery_source_sha256"->IntegerString[FileHash[resumeSource,"SHA256"],16,64],"original_job_id"->previous["job_id"],
   "temporary_sha256"->IntegerString[temporaryHash,16,64],"recovered_complete_native_export"->True,
   "exact_native_storage_comparison"->roundTrip,"response_bytes"->ByteCount[packet["Response"]],
   "loaded_expression_bytes"->originalBytes,"original_writer_size_record"->First[StringSplit[tail,"\n"]],
   "read_seconds"->readSeconds,"piece_comparison_seconds"->pieceSeconds,"elapsed_seconds"->AbsoluteTime[]-started,
   "peak_kernel_memory_bytes"->MaxMemoryUsed[],"finite_nlo_fhats_computed"->False|>;
 Export[FileNameJoin[{directory,"s05_checks.json"}],report,"RawJSON"];
 Print["PASS: s05_resume_Hgg_piecewise_export"];Quit[0]];
ToExpression[assemblyRunTail,InputForm];

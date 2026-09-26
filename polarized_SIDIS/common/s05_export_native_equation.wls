(* Read an existing native checkpoint as a bounded, human-readable equation. *)
$HistoryLength=0;root=Directory[];
sourcePath=FileNameJoin[{root,"common","s05_export_native_equation.wls"}];
channel=Environment["POLARIZED_SIDIS_CHANNEL"];
relative=Environment["POLARIZED_SIDIS_EQUATION_FILE"];
expected=Environment["POLARIZED_SIDIS_EQUATION_SHA256"];
gate[name_,test_]:=If[TrueQ[test],Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["own compute allocation",channel==="Hgg"&&StringQ[Environment["JOB_ID"]]&&
  !StringStartsQ[$MachineName,"login"]];
gate["complete native reader syntax",SyntaxQ[Import[sourcePath,"Text"]]];
gate["own scalar checkpoint path",StringQ[relative]&&
  StringStartsQ[relative,"cache/s05_spin_components/"<>channel<>"/"]&&
  FreeQ[FileNameSplit[relative],".."]&&StringEndsQ[relative,".wl"]];
path=FileNameJoin[{root,relative}];
gate["exact saved scalar equation",IntegerString[FileHash[path,"SHA256"],16,64]===expected];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
record=Get[path];
gate["native scalar checkpoint schema",AssociationQ[record]&&
  ContainsAll[Keys[record],{"InputHash","ArgumentHash","Value"}]];
result=<|"SourceHash"->FileHash[sourcePath,"SHA256"],"Checkpoint"->relative,
  "CheckpointHash"->FileHash[path,"SHA256"],"Record"->record,
  "NativeVersions"->{$Version,$FeynCalcVersion},"NewContractionEvaluated"->False|>;
directory=FileNameJoin[{root,channel,"s05_angular_equation_result"}];
If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
output=FileNameJoin[{directory,"s05_result.wl"}];
serialized=ToString[result,InputForm]<>"\n";
gate["bounded readable native output",StringLength[serialized]<128*1024^2];
Export[output<>".tmp",serialized,"Text"];
gate["exact readable native reload",Get[output<>".tmp"]===result];
RenameFile[output<>".tmp",output,OverwriteTarget->True];
Print["PASS: s05_export_native_equation"];Quit[0];

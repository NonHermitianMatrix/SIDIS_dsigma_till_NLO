(* Bounded reduction of the exact saved Hqg Regular comparison equation. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=Directory[];out=FileNameJoin[{root,"misc","s03_result"}];
source=FileNameJoin[{root,"misc","s03_reduce_Hqg_regular.wls"}];
configPath=FileNameJoin[{root,"misc","s03_inputs.json"}];
config=Import[configPath,"RawJSON"];checks=<||>;
gate[name_,value_]:=If[TrueQ[value],AssociateTo[checks,name->True];Print["PASS: ",name],
 Print["FAIL: ",name];Quit[1]];
gate["authorized bounded local execution",Environment["POLARIZED_SIDIS_LOCAL_BOUNDED"]==="1"];
gate["source binding",IntegerString[FileHash[source,"SHA256"],16,64]===config["source_sha256"]];
gate["source syntax",SyntaxQ[ReadString[source]]];
KeyValueMap[gate["input binding "<>#1,IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,config["input_sha256"]];
SetAttributes[bounded,HoldFirst];
bounded[value_]:=MemoryConstrained[TimeConstrained[value,45,$TimedOut],2*1024^3,$Failed];
save[value_,path_]:=Module[{text},
 text="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
 gate["bounded saved equation",StringLength[text]<config["limits"]["output_bytes"]];
 Export[path<>".tmp",text,"Text"];
 gate["exact saved equation reload",Get[path<>".tmp"]===value];
 RenameFile[path<>".tmp",path,OverwriteTarget->True]];
packetPath=FileNameJoin[{root,"misc","s02_result","s03_regular_coefficients.wl"}];
equationPath=FileNameJoin[{root,"misc","s02_result","s02_equation_F1_1_Regular.wl"}];
identityPath=FileNameJoin[{root,"misc","s02_result","s03_log_identities.wl"}];
Print["LOAD_EXACT_COEFFICIENT_PACKET"];
packet=bounded[Get[packetPath]];identities=Get[identityPath];
gate["exact packet reconstruction",AssociationQ[packet]&&TrueQ[packet["ExactInputRestoration"]]&&TrueQ[packet["ExactReconstruction"]]];
gate["same actual equation and function identities",packet["InputHash"]===FileHash[equationPath,"SHA256"]&&
 packet["LogIdentityHash"]===FileHash[identityPath,"SHA256"]&&identities["InputHash"]===packet["InputHash"]&&
 And@@Lookup[identities["Rows"],"Accepted"]&&And@@(#===0&/@Lookup[identities["Rows"],"Residual"])];
variables=packet["Variables"];rows=packet["FormalCoefficientRules"];
rebuilt=Total[(Last[#] Times@@MapThread[Power,{variables,First[#]}])&/@rows];
Print["VERIFY_COEFFICIENT_RECONSTRUCTION"];
gate["own exact coefficient reconstruction",bounded[CoefficientRules[packet["Formal"],variables]]===rows&&
 bounded[CoefficientRules[rebuilt,variables]]===rows];
restoration=Dispatch[packet["KinematicCoefficientRules"]];
inputHash=Hash[{config["input_sha256"],config["source_sha256"],$Version,$FeynCalcVersion},"SHA256"];
order=Ordering[ByteCount/@(Last/@rows)];results=Association[];
Do[
 path=FileNameJoin[{out,"s03_coefficient_"<>IntegerString[index,10,2]<>".wl"}];
 cached=If[FileExistsQ[path],Get[path],<||>];
 If[AssociationQ[cached]&&Lookup[cached,"InputHash",None]===inputHash&&TrueQ[Lookup[cached,"Completed",False]],
  AssociateTo[results,index->cached];Print["REUSED_COEFFICIENT ",index];Continue[]];
 Print["RESTORE_COEFFICIENT ",index," OF ",Length[rows]];
 {restoreSeconds,value}=AbsoluteTiming[bounded[Last[rows[[index]]]/.restoration]];
 completed=FreeQ[value,$Failed|$TimedOut|$Aborted];
 If[completed,
  gate["coefficient restoration resolved",Intersection[DeleteDuplicates[Cases[value,_Symbol,Infinity]],
    Join[variables,First/@packet["KinematicCoefficientRules"]]]==={}];
  Print["FACTOR_COEFFICIENT ",index," BYTES ",ByteCount[value]];
  {factorSeconds,reduced}=AbsoluteTiming[bounded[Factor[value]]];
  completed=FreeQ[reduced,$Failed|$TimedOut|$Aborted],
  factorSeconds=0;reduced=value];
 record=<|"Index"->index,"Exponent"->First[rows[[index]]],"InputHash"->inputHash,
  "Completed"->completed,"Coefficient"->reduced,"RestoreSeconds"->restoreSeconds,
  "FactorSeconds"->factorSeconds,"NativeVersions"->{$Version,$FeynCalcVersion},"AcceptedForProduction"->False|>;
 save[record,path];AssociateTo[results,index->record];
 Print["COEFFICIENT_RESULT ",index," COMPLETED ",completed," ZERO ",reduced===0,
  " RESTORE_SECONDS ",restoreSeconds," FACTOR_SECONDS ",factorSeconds," RESULT_BYTES ",ByteCount[reduced]];
 Clear[value,reduced,cached];ClearSystemCache[],{index,order}];
complete=And@@(TrueQ[results[#]["Completed"]]&/@Range[Length[rows]]);
gate["all coefficient reductions completed",complete];
reducedRules=Table[results[index]["Exponent"]->results[index]["Coefficient"],{index,Length[rows]}];
residual=Total[(Last[#] Times@@MapThread[Power,{packet["Functions"],First[#]}])&/@reducedRules];
Print["FINAL_FUNCTION_REDUCTION ",ByteCount[residual]];
If[residual=!=0,residual=bounded[FullSimplify[FunctionExpand[residual,identities["Conditions"]],identities["Conditions"]]]];
result=<|"Channel"->"Hqg","Hat"->"F1","Branch"->1,"Distribution"->"Regular",
 "InputHash"->inputHash,"InputSHA256"->config["input_sha256"],"SourceSHA256"->config["source_sha256"],
 "Residual"->residual,"Equal"->(residual===0),"CoefficientResults"->results,"Checks"->checks,
 "NativeVersions"->{$Version,$FeynCalcVersion},"AcceptedForProduction"->False,"FiniteNLOFHatsComputed"->False|>;
save[result,FileNameJoin[{out,"s03_result.wl"}]];
Export[FileNameJoin[{out,"s03_checks.json"}],<|"checks"->checks,"regular_comparison_equal"->(residual===0),
 "finite_nlo_fhats_computed"->False|>,"RawJSON"];
gate["actual Regular comparison vanishes",residual===0];
Print["PASS: s03_reduce_Hqg_regular"];Quit[0];

(* Exact color/regulator-constant decomposition of the saved Regular remainder. *)
$HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
root=Directory[];source=FileNameJoin[{root,"misc","s04_factor_Hqg_remainder.wls"}];
out=FileNameJoin[{root,"misc","s04_result"}];configPath=FileNameJoin[{root,"misc","s04_inputs.json"}];
config=Import[configPath,"RawJSON"];checks=<||>;
gate[name_,value_]:=If[TrueQ[value],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["authorized local execution",Environment["POLARIZED_SIDIS_LOCAL_BOUNDED"]==="1"];
gate["source binding",IntegerString[FileHash[source,"SHA256"],16,64]===config["source_sha256"]];
gate["source syntax",SyntaxQ[ReadString[source]]];
KeyValueMap[gate["input binding "<>#1,IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,config["input_sha256"]];
SetAttributes[bounded,HoldFirst];
bounded[value_,label_]:=Module[{result},
 Print["BEGIN ",label];result=MemoryConstrained[TimeConstrained[value,90,$TimedOut],2*1024^3,$Failed];
 gate["completed "<>ToString[label,InputForm],FreeQ[result,$TimedOut|$Failed|$Aborted]];result];
save[value_,path_]:=Module[{text},text="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
 gate["bounded output",StringLength[text]<config["limits"]["output_bytes"]];Export[path<>".tmp",text,"Text"];
 gate["exact native reload",Get[path<>".tmp"]===value];RenameFile[path<>".tmp",path,OverwriteTarget->True]];
packetPath=FileNameJoin[{root,"misc","s02_result","s03_regular_coefficients.wl"}];packet=Get[packetPath];
gate["exact original equation reconstruction",TrueQ[packet["ExactReconstruction"]]&&TrueQ[packet["ExactInputRestoration"]]];
rows=packet["FormalCoefficientRules"];restoration=Dispatch[packet["KinematicCoefficientRules"]];
producerConfig=Import[FileNameJoin[{root,"misc","s03_inputs.json"}],"RawJSON"];
producerReceipt=Import[FileNameJoin[{root,"misc","s03_result","s03_execution.json"}],"RawJSON"];
producerInputHash=Hash[{producerConfig["input_sha256"],producerConfig["source_sha256"],$Version,$FeynCalcVersion},"SHA256"];
gate["bound partial producer execution",producerReceipt["source_sha256"]===producerConfig["source_sha256"]&&
 producerReceipt["config_sha256"]===IntegerString[FileHash[FileNameJoin[{root,"misc","s03_inputs.json"}],"SHA256"],16,64]&&
 producerConfig["source_sha256"]===IntegerString[FileHash[FileNameJoin[{root,"misc","s03_reduce_Hqg_regular.wls"}],"SHA256"],16,64]];
completed=Association@Table[index->Get[FileNameJoin[{root,"misc","s03_result","s03_coefficient_"<>IntegerString[index,10,2]<>".wl"}]],{index,Length[rows]}];
KeyValueMap[gate["bound actual coefficient "<>ToString[#1],#2["InputHash"]===producerInputHash&&
 #2["Index"]===#1&&#2["Exponent"]===First[rows[[#1]]]&&#2["NativeVersions"]==={$Version,$FeynCalcVersion}]&,completed];
controlIndex=First[Select[Keys[completed],TrueQ[completed[#]["Completed"]]&&completed[#]["Coefficient"]===0&]];
remaining=Select[Keys[completed],!TrueQ[completed[#]["Completed"]]&];
gate["only constant coefficient remains",Length[remaining]===1&&
 First[rows[[First[remaining]]]]===ConstantArray[0,Length[packet["Variables"]]]];
factorSeparated[value_,label_]:=Module[{scalarSymbols={SUNN,EulerGamma},variables,formalValue,aliases,restore,powers,shift,scaled,coefficients,
 rebuilt,results,result,seconds,part,exponents,inputHash,record,path,previous,reducedRules},
 variables=Table[Unique["scalarCoefficientVariable"],{Length[scalarSymbols]}];
 aliases=Thread[scalarSymbols->variables];restore=Reverse/@aliases;
 formalValue=value/.aliases;
 gate["exact scalar-symbol restoration",(formalValue/.restore)===value];
 powers=Exponent[formalValue,#,List]&/@variables;
 gate["integer Laurent powers",And@@(IntegerQ/@Flatten[powers])];
 shift=Times@@MapThread[Power,{variables,-(Min/@powers)}];scaled=shift formalValue;
 Print["DERIVED_SCALAR_SUPPORT ",label," ",InputForm[powers]];
 coefficients=bounded[CoefficientRules[scaled,variables],{label,"scalar coefficient extraction"}];
 gate["resolved scalar coefficient rules",ListQ[coefficients]&&FreeQ[coefficients,_CoefficientRules]];
 rebuilt=Total[(Last[#] Times@@MapThread[Power,{variables,First[#]}])&/@coefficients];
 gate["exact scalar polynomial reconstruction",bounded[CoefficientRules[rebuilt,variables],{label,"scalar reconstruction"}]===coefficients];
 gate["scalar coefficient independence",And@@(FreeQ[Last[#],Alternatives@@variables]&/@coefficients)];
 inputHash=Hash[{value,config["source_sha256"],config["input_sha256"],$Version,$FeynCalcVersion},"SHA256"];
 results=Table[
  exponents=First[coefficients[[index]]];path=FileNameJoin[{out,"s04_"<>label<>"_"<>IntegerString[index,10,2]<>".wl"}];
  previous=If[FileExistsQ[path],Get[path],<||>];
  If[AssociationQ[previous]&&Lookup[previous,"InputHash",None]===inputHash&&TrueQ[Lookup[previous,"Completed",False]],previous,
   Print["SCALAR_FACTOR ",label," ",index," OF ",Length[coefficients]," BYTES ",ByteCount[Last[coefficients[[index]]]]];
   {seconds,part}=AbsoluteTiming[bounded[Factor[Last[coefficients[[index]]]],{label,index,"original Factor"}]];
   record=<|"InputHash"->inputHash,"Exponent"->exponents,"Coefficient"->part,"Completed"->True,"Seconds"->seconds|>;
   save[record,path];Print["SCALAR_RESULT ",label," ",index," ZERO ",part===0," SECONDS ",seconds];record],{index,Length[coefficients]}];
 reducedRules=(# ["Exponent"]-># ["Coefficient"]&/@results);
 result=(Total[(Last[#] Times@@MapThread[Power,{variables,First[#]}])&/@reducedRules]/shift)/.restore;
 <|"Value"->result,"Symbols"->scalarSymbols,"Powers"->powers,"Shift"->(shift/.restore),"Components"->results,"ExactReconstruction"->True|>];
control=factorSeparated[Last[rows[[controlIndex]]]/.restoration,"control"];
gate["own original Factor output reproduced",control["Value"]===completed[controlIndex]["Coefficient"]];
actual=factorSeparated[Last[rows[[First[remaining]]]]/.restoration,"actual"];
gate["actual constant coefficient vanishes",actual["Value"]===0];
gate["all other native coefficients vanish",And@@(TrueQ[completed[#]["Completed"]]&&completed[#]["Coefficient"]===0&/@Complement[Keys[completed],remaining])];
result=<|"Channel"->"Hqg","Hat"->"F1","Branch"->1,"Distribution"->"Regular",
 "SourceSHA256"->config["source_sha256"],"InputSHA256"->config["input_sha256"],"Control"->control,
 "Actual"->actual,"RegularResidual"->actual["Value"],"OwnOriginalOutputComparison"->True,"Checks"->checks,
 "AcceptedForProduction"->False,"FiniteNLOFHatsComputed"->False,"NativeVersions"->{$Version,$FeynCalcVersion}|>;
save[result,FileNameJoin[{out,"s04_result.wl"}]];
Export[FileNameJoin[{out,"s04_checks.json"}],<|"checks"->checks,"regular_comparison_equal"->True,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s04_factor_Hqg_remainder"];Quit[0];

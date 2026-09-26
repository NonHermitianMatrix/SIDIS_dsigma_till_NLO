(* Execute the reference regulator recurrence with the accepted exact polynomial backend. *)
localSeriesRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localSeriesSource=ExpandFileName[$InputFileName];
localExactRegulatorSeries[coefficient_,order_Integer]:=Module[
 {backendPath,basePath,review,reviewReceipt,backendHash,baseHash,identity,cacheRoot,cacheFile,saved,
  pair,atoms,atomSymbols,atomRules,reverseAtoms,lifted,variables,encodedVariables,rules,reverseRules,
  numerator,denominator,encode,payload,directory,inputPath,outputPath,process,output,row,value,
  inputFileHash,outputFileHash,packet,serialized,temporary,start=AbsoluteTime[]},
 If[NumberQ[coefficient],Return[If[order>=0,coefficient,0]]];
 backendPath=FileNameJoin[{localSeriesRoot,"misc","s29_regulator_series.py"}];
 basePath=FileNameJoin[{localSeriesRoot,"misc","s18_sum_exact_polynomials.py"}];
 backendHash=FileHash[backendPath,"SHA256"];baseHash=FileHash[basePath,"SHA256"];
 review=Import[FileNameJoin[{localSeriesRoot,"misc","s20_interface_review.json"}],"RawJSON"];
 reviewReceipt=Import[FileNameJoin[{localSeriesRoot,"misc","s20_result","s20_review_execution.json"}],"RawJSON"];
 gate["accepted exact polynomial backend retained",TrueQ[reviewReceipt["passed"]]&&
  reviewReceipt["result_sha256"]["misc/s20_interface_review.json"]===
   IntegerString[FileHash[FileNameJoin[{localSeriesRoot,"misc","s20_interface_review.json"}],"SHA256"],16,64]&&
  And@@Values[review["checks"]]&&review["backend_sha256"]===IntegerString[baseHash,16,64]];
 identity=Hash[{coefficient,order,FileHash[localSeriesSource,"SHA256"],backendHash,baseHash},"SHA256"];
 cacheRoot=FileNameJoin[{localSeriesRoot,"misc","s11_work","regulator_series"}];
 If[!DirectoryQ[cacheRoot],CreateDirectory[cacheRoot,CreateIntermediateDirectories->True]];
 cacheFile=FileNameJoin[{cacheRoot,IntegerString[identity,16]<>".wl"}];
 saved=If[FileExistsQ[cacheFile],Get[cacheFile],<||>];
 If[Lookup[saved,"Binding",None]===identity&&TrueQ[Lookup[saved,"Accepted",False]]&&
   KeyExistsQ[saved,"Value"]&&Lookup[saved,"ValueHash",None]===Hash[saved["Value"],"SHA256"],
  Return[saved["Value"]]];
 pair={Numerator[coefficient],Denominator[coefficient]};
 gate["raw scalar ratio exactly reconstructs",First[pair]/Last[pair]===coefficient&&FreeQ[pair,_Real]];
 atoms=DeleteDuplicates[Join[Cases[pair,p_Power/;!IntegerQ[p[[2]]],Infinity],Cases[pair,_Complex,Infinity]]];
 atomSymbols=Table[Symbol["Global`prrAtom"<>ToString[i]],{i,Length[atoms]}];
 gate["unassigned algebraic input generators",AllTrue[atomSymbols,OwnValues[#]==={}&]];
 atomRules=Thread[atoms->atomSymbols];reverseAtoms=Reverse/@atomRules;lifted=pair/.atomRules;
 gate["algebraic generators preserve the exact input",(lifted/.reverseAtoms)===pair];
 gate["lifted algebraic atoms independent of regulator",FreeQ[atoms,eps]];
 variables=Sort[DeleteDuplicates[Append[Cases[lifted,_Symbol,Infinity],eps]]];
 gate["complete rational polynomial support",And@@(PolynomialQ[#,variables]&/@lifted)];
 encodedVariables=Table[Symbol["Global`pfsVar"<>ToString[i]],{i,Length[variables]}];
 gate["unassigned polynomial transfer generators",AllTrue[encodedVariables,OwnValues[#]==={}&]];
 rules=Thread[variables->encodedVariables];reverseRules=Reverse/@rules;
 encode[expression_]:=Module[{nativeValue=expression/.rules,nativeText},nativeText=ToString[nativeValue,InputForm];
  gate["complete polynomial transfer text reconstructs",ToExpression[nativeText,InputForm]===nativeValue];nativeText];
 numerator=encode[First[lifted]];denominator=encode[Last[lifted]];
 payload=<|"schema"->"polarized-sidis-regulator-series-input-v1",
  "base_backend_sha256"->IntegerString[baseHash,16,64],
  "variables"->(ToString[#,InputForm]&/@encodedVariables),"numerator"->numerator,"denominator"->denominator,
  "regulator"->ToString[eps/.rules,InputForm],"maximum_power"->order|>;
 directory=FileNameJoin[{cacheRoot,IntegerString[identity,16]<>"_"<>ToString[$ProcessID]}];
 If[!DirectoryQ[directory],CreateDirectory[directory]];
 inputPath=FileNameJoin[{directory,"input.json"}];outputPath=FileNameJoin[{directory,"output.json"}];
 Export[inputPath,payload,"RawJSON"];
 gate["exact native polynomial JSON transfer",Import[inputPath,"RawJSON"]===payload&&FileByteCount[inputPath]<128*1024^2];
 inputFileHash=FileHash[inputPath,"SHA256"];
 Print["REGULATOR_POLYNOMIAL_BACKEND_START input_bytes ",ByteCount[coefficient]," transfer_bytes ",FileByteCount[inputPath]];
 process=RunProcess[{"python3",backendPath,inputPath,outputPath}];
 Print[process["StandardOutput"]];Print[process["StandardError"]];
 gate["exact polynomial normalization completed",process["ExitCode"]===0&&FileExistsQ[outputPath]];
 output=Import[outputPath,"RawJSON"];outputFileHash=FileHash[outputPath,"SHA256"];
 gate["complete normalization backend identity",output["schema"]==="polarized-sidis-regulator-series-output-v1"&&
  output["source_sha256"]===IntegerString[backendHash,16,64]&&output["base_backend_sha256"]===IntegerString[baseHash,16,64]&&
  output["input_sha256"]===IntegerString[inputFileHash,16,64]&&output["flint_version"]==="0.8.0"&&
  TrueQ[output["exact_polynomial_reconstruction"]]&&TrueQ[output["complete_retained_residual_reconstruction"]]&&
  output["maximum_power"]===order];
 row=output["coefficients"];
 gate["complete regulator coefficient coverage",If[output["leading_power"]===Null,row==={},
   Lookup[row,"power",{}]===Range[output["leading_power"],order]]];
 value=Total[Map[(ToExpression[#["numerator"],InputForm]/ToExpression[#["denominator"],InputForm])*eps^#["power"]&,row]]/.reverseRules/.reverseAtoms;
 gate["complete physical scalar reconstruction",FreeQ[value,Alternatives@@Join[atomSymbols,encodedVariables]]&&
  FreeQ[value,_Real|_CutIntegral|$Failed|$Aborted|_SeriesData]];
 packet=<|"Binding"->identity,"Value"->value,"ValueHash"->Hash[value,"SHA256"],"InputHash"->Hash[coefficient,"SHA256"],
  "InputFileHash"->inputFileHash,"OutputFileHash"->outputFileHash,"BackendHash"->backendHash,"BaseBackendHash"->baseHash,
  "Evidence"->KeyDrop[output,{"coefficients"}],"Accepted"->True|>;
 serialized="Uncompress["<>ToString[Compress[packet],InputForm]<>"]\n";
 gate["bounded normalized scalar cache",StringLength[serialized]<128*1024^2];
 temporary=cacheFile<>".tmp."<>ToString[$ProcessID];Export[temporary,serialized,"Text"];
 gate["exact normalized scalar reload",Get[temporary]===packet];RenameFile[temporary,cacheFile,OverwriteTarget->True];
 DeleteFile[{inputPath,outputPath}];DeleteDirectory[directory];
 Print["REGULATOR_POLYNOMIAL_ACCEPTED seconds ",AbsoluteTime[]-start," input_bytes ",ByteCount[coefficient],
  " output_bytes ",ByteCount[value]," backend_seconds ",output["seconds"]];
 value];

If[Environment["POLARIZED_SIDIS_VALIDATE_SERIES"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];
 source=ExpandFileName[$InputFileName];checks=<||>;
 gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];bounded[v_,label_]:=MemoryConstrained[
  TimeConstrained[v,1200,gate[label<>" time limit",False]],2*1024^3,gate[label<>" memory limit",False]];
 readAccepted[relative_,receiptRelative_]:=Module[{p=FileNameJoin[{root,relative}],receipt},
  receipt=Import[FileNameJoin[{root,receiptRelative}],"RawJSON"];
  gate["accepted input "<>relative,TrueQ[receipt["passed"]]&&receipt["result_sha256"][relative]===IntegerString[FileHash[p,"SHA256"],16,64]];Get[p]];
 captured=readAccepted["misc/s26_result/s26_result.wl","misc/s26_result/s26_execution.json"];
 own=readAccepted["misc/s23_result/s23_result.wl","misc/s23_result/s23_execution.json"];
 reference=readAccepted["Hqqbar/s12_rational_series_result/s12_result.wl","Hqqbar/s12_rational_series_result/s12_execution.json"];
 argumentProof=readAccepted["misc/s24_result/s24_result.wl","misc/s24_result/s24_execution.json"];
 Get[FileNameJoin[{root,"misc","s24_canonical_Hgg_arguments.wls"}]];
 gate["accepted argument comparison retained",TrueQ[argumentProof["Accepted"]]&&And@@Values[argumentProof["Checks"]]&&
  DownValues[localCanonicalScalarArguments]===argumentProof["Definitions"]];
 zeroCoefficient[value_]:=Factor[Together[localCanonicalScalarArguments[value]]]===0;
 DownValues[epsilonSeries]=reference["OriginalDefinitions"][[1]];
 DownValues[laurentProduct]=reference["OriginalDefinitions"][[2]];
 DownValues[rationalSeries]=reference["RationalDefinitions"];
 DownValues[checkedRationalSeries]=reference["CheckedRationalDefinitions"];
 DownValues[ordinaryMasterProduct]=reference["ProductDefinitions"];
 referenceSeriesComparisonText=ReadString[FileNameJoin[{root,"common","s12_check_rational_master_product.wls"}]];
 gate["executed reference product source retained",reference["SourceHash"]===FileHash[FileNameJoin[{root,"common","s12_check_rational_master_product.wls"}],"SHA256"]];
 parentPath=FileNameJoin[{root,"misc","s11_assemble_Hgg_real.wls"}];parentText=ReadString[parentPath];
 parentConfig=Import[FileNameJoin[{root,"misc","s11_inputs.json"}],"RawJSON"];
 gate["reviewed actual parent source",parentConfig["source_sha256"]===IntegerString[FileHash[parentPath,"SHA256"],16,64]];
 start="productOriginalDefinitions = ";finish="recoilProofRelative = ";
 gate["complete executed product adapter boundary",StringCount[parentText,start]===1&&StringCount[parentText,finish]===1];
 adapter=start<>First[StringSplit[Last[StringSplit[parentText,start]],finish]];
 gate["complete executed product adapter syntax",SyntaxQ[adapter]];ToExpression[adapter,InputForm];
 originalChecked=DownValues[checkedRationalSeries];originalProduct=DownValues[ordinaryMasterProduct];
 checkedNew="checkedRationalSeries[coefficient_, order_, description_] := localExactRegulatorSeries[coefficient, order];";
 productOld="rational = bounded[Together[coefficient], \"coefficient regulator valuation\"];";
 replacement="rational = coefficient; gate[\"exact raw regulator ratio retained\", Numerator[rational]/Denominator[rational] === rational];";
 gate["one rational preparation call replaced",StringCount[productCorrectedText,productOld]===1];
 productNew=StringReplace[productCorrectedText,productOld->replacement];
 gate["master product and valuation checks retained",SyntaxQ[checkedNew]&&SyntaxQ[productNew]&&
  StringReplace[productNew,replacement->productOld]===productCorrectedText];
 ToExpression[checkedNew,InputForm];ToExpression[productNew,InputForm];
 {ownSeconds,ownValue}=AbsoluteTiming[ordinaryMasterProduct[own["Packet"]["Coefficient"],own["Packet"]["Master"],own["Packet"]["Order"],{"Own",own["ComponentIndex"],own["Master"]}]];
 gate["entire accepted own master product reproduced",bounded[zeroCoefficient[ownValue-own["Packet"]["Direct"]],"own regulator preparation comparison"]];
 mapPath=FileNameJoin[{root,"misc","s10_result","s10_result.wl"}];
 gate["captured actual map unchanged",captured["InputHash"]===FileHash[mapPath,"SHA256"]];
 scalarRules=Get[mapPath]["ScalarConventionRules"];ClearSystemCache[];
 library=Get[FileNameJoin[{root,"common","s06_result","s06_result.wl"}]];
 row=library["Library"]["s15"];regionPath=FileNameJoin[{root,row["File"]}];
 gate["pinned scalar master regions",IntegerString[FileHash[regionPath,"SHA256"],16,64]===row["SHA256"]];
 regions=Get[regionPath]/.scalarRules;master=regions["OrdinaryMasters"][captured["Master"]];
 {actualSeconds,actualValue}=AbsoluteTiming[ordinaryMasterProduct[captured["Coefficient"],master,own["Packet"]["Order"],{"Actual",captured["Facts"]["ComponentIndex"],captured["Master"]}]];
 gate["actual failed master product fully evaluated",FreeQ[actualValue,_CutIntegral|_Series|_SeriesData|_Missing|_Real|$Failed|$Aborted]];
 out=FileNameJoin[{root,"misc","s29_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 result=<|"Schema"->"polarized-sidis-exact-regulator-series-comparison-v1","SourceHash"->FileHash[source,"SHA256"],
  "ParentSourceHash"->FileHash[parentPath,"SHA256"],"CaptureHash"->FileHash[FileNameJoin[{root,"misc","s26_result","s26_result.wl"}],"SHA256"],
  "Definitions"->DownValues[localExactRegulatorSeries],"OriginalCheckedDefinitions"->originalChecked,"OriginalProductDefinitions"->originalProduct,
  "CheckedDefinitions"->DownValues[checkedRationalSeries],"ProductDefinitions"->DownValues[ordinaryMasterProduct],
  "OwnValue"->ownValue,"ActualValue"->actualValue,"OwnSeconds"->ownSeconds,"ActualSeconds"->actualSeconds,
  "Checks"->checks,"NativeVersions"->{$Version,$FeynCalcVersion},"Accepted"->True|>;
 proofFile=FileNameJoin[{out,"s29_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded regulator preparation proof",StringLength[serialized]<128*1024^2];Export[proofFile,serialized,"Text"];
 gate["exact regulator preparation proof reload",Get[proofFile]===result];
 Export[FileNameJoin[{out,"s29_checks.json"}],<|"checks"->checks,"own_seconds"->ownSeconds,"actual_seconds"->actualSeconds|>,"RawJSON"];
 Print["PASS: exact Hgg regulator recurrence validated"];Quit[0]];

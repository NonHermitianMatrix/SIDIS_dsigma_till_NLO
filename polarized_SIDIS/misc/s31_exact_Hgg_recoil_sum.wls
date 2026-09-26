localRecoilTerms[rational_]:=Module[
 {factors,functions,genericFactors,generic,rawGeneric,rawTerms,terms},
 factors=If[Head[rational]===Times,List@@rational,{rational}];
 gate["exact native recoil factors retained",Times@@factors===rational];
 functions=Table[Unique["recoilFactor$"],{Length[factors]}];
 genericFactors=(#[s23]&)/@functions;
 generic=s23 D[Times@@genericFactors,s23]/(Times@@genericFactors);
 rawGeneric=(s23 D[#,s23]/#&)/@genericFactors;
 gate["native product rule exactly derived",Together[generic-Total[rawGeneric]]===0];
 rawTerms=(s23 D[#,s23]/#&)/@factors;
 terms=Map[bounded[Cancel[#],"factor derivative cancellation"]&,rawTerms];
 gate["each factor derivative exactly reconstructed",And@@MapThread[
  bounded[Cancel[Together[#1-#2]]===0,"factor derivative reconstruction"]&,{terms,rawTerms}]];
 Print["RECOIL_FACTOR_TERMS count ",Length[terms]," rational_bytes ",ByteCount[rational],
  " terms_bytes ",ByteCount[terms]];
 terms];
(* Sum the exact native recoil derivative with the accepted polynomial backend. *)
localRecoilRoot=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
localRecoilSource=ExpandFileName[$InputFileName];
localExactRecoilRatio[rational_]:=Module[
 {backendPath,basePath,review,reviewReceipt,backendHash,baseHash,identity,cacheRoot,cacheFile,saved,
  terms,pair,atoms,atomSymbols,atomRules,reverseAtoms,lifted,variables,encodedVariables,rules,reverseRules,
  numerator,denominator,encode,payload,directory,inputPath,outputPath,process,output,row,value,
  inputFileHash,outputFileHash,packet,serialized,temporary,start=AbsoluteTime[]},
 If[NumberQ[rational],Return[s23 D[rational,s23]/rational]];
 backendPath=FileNameJoin[{localRecoilRoot,"misc","s31_sum_recoil_polynomials.py"}];
 basePath=FileNameJoin[{localRecoilRoot,"misc","s18_sum_exact_polynomials.py"}];
 backendHash=FileHash[backendPath,"SHA256"];baseHash=FileHash[basePath,"SHA256"];
 review=Import[FileNameJoin[{localRecoilRoot,"misc","s20_interface_review.json"}],"RawJSON"];
 reviewReceipt=Import[FileNameJoin[{localRecoilRoot,"misc","s20_result","s20_review_execution.json"}],"RawJSON"];
 gate["accepted exact polynomial backend retained",TrueQ[reviewReceipt["passed"]]&&
  reviewReceipt["result_sha256"]["misc/s20_interface_review.json"]===
   IntegerString[FileHash[FileNameJoin[{localRecoilRoot,"misc","s20_interface_review.json"}],"SHA256"],16,64]&&
  And@@Values[review["checks"]]&&review["backend_sha256"]===IntegerString[baseHash,16,64]];
 identity=Hash[{rational,FileHash[localRecoilSource,"SHA256"],backendHash,baseHash},"SHA256"];
 cacheRoot=FileNameJoin[{localRecoilRoot,"misc","s11_work","recoil_derivative"}];
 If[!DirectoryQ[cacheRoot],CreateDirectory[cacheRoot,CreateIntermediateDirectories->True]];
 cacheFile=FileNameJoin[{cacheRoot,IntegerString[identity,16]<>".wl"}];
 saved=If[FileExistsQ[cacheFile],Get[cacheFile],<||>];
 If[Lookup[saved,"Binding",None]===identity&&TrueQ[Lookup[saved,"Accepted",False]]&&
   KeyExistsQ[saved,"Value"]&&Lookup[saved,"ValueHash",None]===Hash[saved["Value"],"SHA256"],
  Return[saved["Value"]]];
 terms=localRecoilTerms[rational];
 pair=({Numerator[#],Denominator[#]}&)/@terms;
 gate["raw scalar ratio exactly reconstructs",(First[#]/Last[#]&/@pair)===terms&&FreeQ[pair,_Real]];
 atoms=DeleteDuplicates[Join[Cases[pair,p_Power/;!IntegerQ[p[[2]]],Infinity],Cases[pair,_Complex,Infinity]]];
 atomSymbols=Table[Symbol["Global`prrAtom"<>ToString[i]],{i,Length[atoms]}];
 gate["unassigned algebraic input generators",AllTrue[atomSymbols,OwnValues[#]==={}&]];
 atomRules=Thread[atoms->atomSymbols];reverseAtoms=Reverse/@atomRules;lifted=pair/.atomRules;
 gate["algebraic generators preserve the exact input",(lifted/.reverseAtoms)===pair];
 variables=Sort[DeleteDuplicates[Cases[lifted,_Symbol,Infinity]]];
 gate["complete rational polynomial support",And@@(PolynomialQ[#,variables]&/@Flatten[lifted,1])];
 encodedVariables=Table[Symbol["Global`pfsVar"<>ToString[i]],{i,Length[variables]}];
 gate["unassigned polynomial transfer generators",AllTrue[encodedVariables,OwnValues[#]==={}&]];
 rules=Thread[variables->encodedVariables];reverseRules=Reverse/@rules;
 encode[expression_]:=Module[{nativeValue=expression/.rules,nativeText},nativeText=ToString[nativeValue,InputForm];
  gate["complete polynomial transfer text reconstructs",ToExpression[nativeText,InputForm]===nativeValue];nativeText];
 payload=<|"schema"->"polarized-sidis-recoil-polynomial-input-v1",
  "base_backend_sha256"->IntegerString[baseHash,16,64],
  "variables"->(ToString[#,InputForm]&/@encodedVariables),
  "terms"->Map[<|"numerator"->encode[First[#]],"denominator"->encode[Last[#]]|>&,lifted]|>;
 directory=FileNameJoin[{cacheRoot,IntegerString[identity,16]<>"_"<>ToString[$ProcessID]}];
 If[!DirectoryQ[directory],CreateDirectory[directory]];
 inputPath=FileNameJoin[{directory,"input.json"}];outputPath=FileNameJoin[{directory,"output.json"}];
 Export[inputPath,payload,"RawJSON"];
 gate["exact native polynomial JSON transfer",Import[inputPath,"RawJSON"]===payload&&FileByteCount[inputPath]<128*1024^2];
 inputFileHash=FileHash[inputPath,"SHA256"];
 Print["RECOIL_POLYNOMIAL_BACKEND_START input_bytes ",ByteCount[rational]," transfer_bytes ",FileByteCount[inputPath]];
 process=RunProcess[{"python3",backendPath,inputPath,outputPath}];
 Print[process["StandardOutput"]];Print[process["StandardError"]];
 gate["exact polynomial normalization completed",process["ExitCode"]===0&&FileExistsQ[outputPath]];
 output=Import[outputPath,"RawJSON"];outputFileHash=FileHash[outputPath,"SHA256"];
 gate["complete normalization backend identity",output["schema"]==="polarized-sidis-recoil-polynomial-output-v1"&&
  output["source_sha256"]===IntegerString[backendHash,16,64]&&output["base_backend_sha256"]===IntegerString[baseHash,16,64]&&
  output["input_sha256"]===IntegerString[inputFileHash,16,64]&&output["flint_version"]==="0.8.0"&&
  TrueQ[output["factored_output_reconstruction"]]];
 row=output["result"];
 gate["exact existing cancellation gates passed",row["label"]==="recoil_derivative"&&
  row["term_count"]===Length[terms]&&TrueQ[row["exact_termwise_reconstruction_passed"]]];
 value=(ToExpression[output["factored"]["numerator"],InputForm]/ToExpression[output["factored"]["denominator"],InputForm])/.reverseRules/.reverseAtoms;
 gate["complete physical scalar reconstruction",FreeQ[value,Alternatives@@Join[atomSymbols,encodedVariables]]&&
  FreeQ[value,_Real|_CutIntegral|$Failed|$Aborted|_SeriesData]];
 packet=<|"Binding"->identity,"Value"->value,"ValueHash"->Hash[value,"SHA256"],"InputHash"->Hash[rational,"SHA256"],
  "InputFileHash"->inputFileHash,"OutputFileHash"->outputFileHash,"BackendHash"->backendHash,"BaseBackendHash"->baseHash,
  "Evidence"->KeyDrop[output,{"result","factored"}],"CancellationEvidence"->KeyDrop[row,{"numerator","denominator"}],"Accepted"->True|>;
 serialized="Uncompress["<>ToString[Compress[packet],InputForm]<>"]\n";
 gate["bounded normalized scalar cache",StringLength[serialized]<128*1024^2];
 temporary=cacheFile<>".tmp."<>ToString[$ProcessID];Export[temporary,serialized,"Text"];
 gate["exact normalized scalar reload",Get[temporary]===packet];RenameFile[temporary,cacheFile,OverwriteTarget->True];
 DeleteFile[{inputPath,outputPath}];DeleteDirectory[directory];
 Print["RECOIL_POLYNOMIAL_ACCEPTED seconds ",AbsoluteTime[]-start," input_bytes ",ByteCount[rational],
  " output_bytes ",ByteCount[value]," backend_seconds ",output["seconds"]];
 value];

If[Environment["POLARIZED_SIDIS_VALIDATE_RECOIL"]==="1",
 $HistoryLength=0;$FeynCalcStartupMessages=False;Get["FeynCalc`"];
 root=DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];SetDirectory[root];source=ExpandFileName[$InputFileName];checks=<||>;
 gate[n_,v_]:=If[TrueQ[v],AssociateTo[checks,n->True];Print["PASS: ",n],Print["FAIL: ",n];Quit[1]];
 SetAttributes[bounded,HoldFirst];bounded[v_,label_]:=MemoryConstrained[TimeConstrained[v,300,gate[label<>" time",False]],2*1024^3,gate[label<>" memory",False]];
 capturePath=FileNameJoin[{root,"misc","s30_result","s30_result.wl"}];
 captureReceipt=Import[FileNameJoin[{root,"misc","s30_result","s30_execution.json"}],"RawJSON"];
 gate["accepted exact derivative capture",TrueQ[captureReceipt["passed"]]&&
  captureReceipt["result_sha256"]["misc/s30_result/s30_result.wl"]===IntegerString[FileHash[capturePath,"SHA256"],16,64]];
 captured=Get[capturePath];
 gate["executed captured equations retained",And@@Values[captured["Checks"]]&&
  captured["SourceHash"]===FileHash[FileNameJoin[{root,"misc","s30_result","reference","before_facts_logging","s30_capture_Hgg_recoil_derivative.wls"}],"SHA256"]&&
  captured["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}];
 Do[gate["exact captured defining derivative "<>key,
  s23 D[captured[key]["Rational"],s23]/captured[key]["Rational"]===captured[key]["Derivative"]],
  {key,{"Own","Actual"}}];
 facts=captured["Actual"]["Facts"];terms=captured["Actual"]["Terms"];
 fixedSource=ReadString[FileNameJoin[{root,"misc","s30_capture_Hgg_recoil_derivative.wls"}]];
 fixedLine="AssociateTo[facts,{\"SelectedTermCount\"->Length[terms],\"SelectedTermBytes\"->ByteCount[terms]}]";
 gate["unique corrected facts interface",StringCount[fixedSource,fixedLine]===1&&SyntaxQ[fixedSource]];
 ToExpression[fixedLine,InputForm];
 gate["corrected actual facts interface",facts["SelectedTermCount"]===Length[terms]&&facts["SelectedTermBytes"]===ByteCount[terms]];
 Print["ACTUAL_DERIVATIVE_FACTS ",InputForm[facts]];
 {ownSeconds,ownRatio}=AbsoluteTiming[localExactRecoilRatio[captured["Own"]["Rational"]]];
 gate["complete own accepted derivative reproduced",bounded[Factor[Together[ownRatio-captured["OwnRatio"]]]===0,"own derivative comparison"]];
 {actualSeconds,actualRatio}=AbsoluteTiming[localExactRecoilRatio[captured["Actual"]["Rational"]]];
 baseText=ReadString[FileNameJoin[{root,"common","s12_assemble_real_spin.wls"}]];
 first="branchAssumptions[sign_] :=";last="\nreduce[value_";
 gate["exact reference assumptions source",StringCount[baseText,first]===1&&StringCount[baseText,last]===1];
 assumptionsText=first<>First[StringSplit[Last[StringSplit[baseText,first]],last]];
 gate["native reference assumptions syntax",SyntaxQ[assumptionsText]];ToExpression[assumptionsText,InputForm];
 {limitSeconds,valuation}=AbsoluteTiming[bounded[FullSimplify[
  Limit[actualRatio,s23->0,Direction->"FromAbove",Assumptions->branchAssumptions[1]],branchAssumptions[1]],"original endpoint valuation"]];
 gate["original endpoint returns unconditional integer",IntegerQ[valuation]];
 result=<|"Schema"->"polarized-sidis-exact-recoil-sum-comparison-v1","SourceHash"->FileHash[source,"SHA256"],
  "CaptureHash"->FileHash[capturePath,"SHA256"],"Definitions"->DownValues[localExactRecoilRatio],
  "TermDefinitions"->DownValues[localRecoilTerms],"OwnRatio"->ownRatio,"ActualRatio"->actualRatio,
  "OwnSeconds"->ownSeconds,"ActualSeconds"->actualSeconds,"LimitSeconds"->limitSeconds,"ActualValuation"->valuation,
  "Facts"->facts,"Checks"->checks,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},"Accepted"->True|>;
 out=FileNameJoin[{root,"misc","s31_result"}];If[!DirectoryQ[out],CreateDirectory[out]];
 serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded exact recoil proof",StringLength[serialized]<128*1024^2];
 proofFile=FileNameJoin[{out,"s31_result.wl"}];Export[proofFile,serialized,"Text"];
 gate["exact recoil proof reload",Get[proofFile]===result];
 Export[FileNameJoin[{out,"s31_checks.json"}],<|"checks"->checks,"own_seconds"->ownSeconds,"actual_seconds"->actualSeconds,"limit_seconds"->limitSeconds|>,"RawJSON"];
 Print["PASS: exact Hgg recoil derivative sum validated"];Quit[0]];

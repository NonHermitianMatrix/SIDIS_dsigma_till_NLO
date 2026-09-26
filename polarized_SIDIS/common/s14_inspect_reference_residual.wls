(* Inspect the actual failed reference comparison from accepted pole checkpoints. *)
$HistoryLength=0;
inspectionRoot=Directory[];
inspectionSource=FileNameJoin[{inspectionRoot,"common","s14_inspect_reference_residual.wls"}];
inspectionBase=FileNameJoin[{inspectionRoot,"common","s14_assemble_finite_spin.wls"}];
If[IntegerString[FileHash[inspectionBase,"SHA256"],16,64]=!=
  "9f511361187996d8fef88f8897ba2b40018032d9d4e789ec2cd17d445939a94a",Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
inspectionText=Import[inspectionBase,"Text"];
If[!SyntaxQ[Import[inspectionSource,"Text"]]||StringCount[inspectionText,"\nindices=Tuples"]=!=1,Quit[1]];
inspectionPrefix=First[StringSplit[inspectionText,"\nindices=Tuples"]];
If[StringCount[inspectionPrefix,"Get[\"FeynCalc`\"]"]=!=1,Quit[1]];
inspectionPrefix=StringReplace[inspectionPrefix,"Get[\"FeynCalc`\"]"->"Null"];
If[!SyntaxQ[inspectionPrefix],Quit[1]];
ToExpression[inspectionPrefix,InputForm];
gate["inspected failed small channel",channel==="Hqqprime"&&!core];
inspectionReceiptPath=FileNameJoin[{root,channel,"s14_result","s14_execution.json"}];
inspectionReceipt=Import[inspectionReceiptPath,"RawJSON"];
gate["failed comparison execution source identity",!TrueQ[inspectionReceipt["passed"]]&&
  inspectionReceipt["job_id"]==="14797221"&&inspectionReceipt["exit_code"]===1&&
  inspectionReceipt["reviewed_sha256"]["common/s14_assemble_finite_spin.wls"]===
    IntegerString[FileHash[inspectionBase,"SHA256"],16,64]];
inspectionU=First[FirstPosition[basis["SpinLabels"],"U"]];
inspectionSign=First[{1,-1,0}];inspectionDistribution="Regular";
inspectionFiles=<||>;
inspectionFinite=Table[
  label={{a,inspectionU,inspectionU},inspectionSign,inspectionDistribution};
  path=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
  gate["own pole checkpoint exists "<>ToString[a],FileExistsQ[path]];
  saved=Get[path];
  gate["own pole checkpoint source input and label "<>ToString[a],
    saved["InputHash"]===inputHash&&TrueQ[saved["Accepted"]]&&saved["Label"]===label];
  AssociateTo[inspectionFiles,StringDrop[path,StringLength[root]+1]->FileHash[path,"SHA256"]];
  saved["Finite"],{a,Length[basis["PhotonLabels"]]}];
inspectionNormalizationStart=StringPosition[inspectionText,"  normalization=If[core,"];
inspectionNormalizationEnd=StringPosition[inspectionText,"  gate[\"finite physical component\""];
gate["unique unchanged final normalization",Length[inspectionNormalizationStart]===1&&Length[inspectionNormalizationEnd]===1];
inspectionNormalization=StringTake[inspectionText,{First[First[inspectionNormalizationStart]],First[First[inspectionNormalizationEnd]]-1}];
gate["unchanged normalization syntax",SyntaxQ[inspectionNormalization]];
inspectionPhysical=Table[
  branches=<|inspectionSign-><|inspectionDistribution->value|>|>;
  ToExpression[inspectionNormalization,InputForm];
  branches[inspectionSign][inspectionDistribution],{value,inspectionFinite}];
inspectionAssumptions=(physical/.t->inspectionSign omega-s)&&omega>0&&flavorDomain;
inspectionRows=Table[
  name={"F1","F2"}[[hatIndex]];
  candidate=Sum[hatPhotonWeights[[hatIndex,a]]inspectionPhysical[[a]],{a,Length[inspectionPhysical]}];
  expected=referenceHats[name]/.t->inspectionSign omega-s;
  Print["REFERENCE_RESIDUAL_BEGIN ",name," input bytes ",ByteCount[candidate-expected]];
  timing=AbsoluteTiming[bounded[reduce[candidate-expected,inspectionAssumptions],{name,"actual reference residual"}]];
  residual=timing[[2]];
  functions=DeleteDuplicates[Cases[residual,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
  Print["REFERENCE_RESIDUAL ",name," bytes ",ByteCount[residual]," functions ",Length[functions]," seconds ",timing[[1]]];
  Print["REFERENCE_RESIDUAL_EXPRESSION ",name," ",StringTake[ToString[residual,InputForm],UpTo[12000]]];
  <|"Hat"->name,"Branch"->inspectionSign,"Distribution"->inspectionDistribution,
    "Candidate"->candidate,"Expected"->expected,"Residual"->residual,"Functions"->functions,"Seconds"->timing[[1]],
    "StructuralZero"->(residual===0)|>,{hatIndex,Length[hatPhotonWeights]}];
inspectionResult=<|"Schema"->"polarized-sidis-reference-residual-inspection-v1","Channel"->channel,
  "SourceHash"->FileHash[inspectionSource,"SHA256"],"BaselineSourceHash"->sourceHash,
  "InputHash"->inputHash,"InputHashes"->inputHashes,"CheckpointHashes"->inspectionFiles,
  "FailedExecutionHash"->FileHash[inspectionReceiptPath,"SHA256"],"NativeVersions"->{$Version,$FeynCalcVersion},
  "NormalizationSource"->inspectionNormalization,"PhotonWeights"->hatPhotonWeights,
  "PhysicalConditions"->inspectionAssumptions,"Rows"->inspectionRows,"Checks"->checks,
  "FiniteNLOFHatsComputed"->False|>;
inspectionDir=FileNameJoin[{root,channel,"s14_reference_residual_result"}];
If[!DirectoryQ[inspectionDir],CreateDirectory[inspectionDir,CreateIntermediateDirectories->True]];
inspectionPath=FileNameJoin[{inspectionDir,"s14_result.wl"}];
inspectionSerialized="Uncompress["<>ToString[bounded[Compress[inspectionResult],"residual inspection compression"],InputForm]<>"]\n";
gate["residual inspection file bound",StringLength[inspectionSerialized]<128*1024^2];
Export[inspectionPath<>".tmp",inspectionSerialized,"Text"];
gate["residual inspection exact native reload",Get[inspectionPath<>".tmp"]===inspectionResult];
RenameFile[inspectionPath<>".tmp",inspectionPath,OverwriteTarget->True];
Export[FileNameJoin[{inspectionDir,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_inspect_reference_residual"];Quit[0];

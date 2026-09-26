(* Validate the native output completed before the scheduler killed its supervisor. *)
$HistoryLength=0;root=Directory[];checks=<||>;
sourcePath=FileNameJoin[{root,"common","s14_verify_completed_assembly.wls"}];
gate[name_,test_] := If[TrueQ[test],AssociateTo[checks,name->True];Print["PASS: ",name],Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete source syntax",SyntaxQ[Import[sourcePath,"Text"]]];
channel=Environment["POLARIZED_SIDIS_CHANNEL"];gate["completed assembly channel",channel==="Hqqprime"];
path=FileNameJoin[{root,channel,"s14_result","s14_result.wl"}];
gate["exact completed native assembly",IntegerString[FileHash[path,"SHA256"],16,64]===
  "531cb108c8933cc8351693f2b6a3d831d5e212b66244f3d4c1d6d2df1fd94e75"];
raw=Get[path];
gate["complete accepted native schema",AssociationQ[raw]&&raw["Channel"]===channel&&
  raw["Schema"]==="polarized-sidis-finite-bmhv-response-v1"&&And@@Values[raw["Checks"]]&&
  TrueQ[raw["CompletePoleCancellationChecked"]]&&TrueQ[raw["UnpolarizedFinalReferenceComparisonPassed"]]&&
  TrueQ[raw["FiniteMinimalSubtractionCoefficientsComputed"]]];
gate["original assembly source",raw["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}],"SHA256"]];
gate["executed dispatch source",raw["DispatchSourceHash"]===FileHash[FileNameJoin[{root,"common","s14_resume_corrected_subtraction.wls"}],"SHA256"]];
Do[gate["unchanged input "<>name,FileHash[FileNameJoin[{root,name}],"SHA256"]===raw["InputHashes"][name]],
  {name,Keys[raw["InputHashes"]]}];
gate["complete native input identity",raw["InputHash"]===Hash[{raw["SourceHash"],raw["InputHashes"],$Version,$FeynCalcVersion},"SHA256"]];
proofPath=FileNameJoin[{root,channel,"s14_resume_result","s14_result.wl"}];proof=Get[proofPath];
gate["complete executed subtraction continuation",raw["SubtractionResumeHash"]===FileHash[proofPath,"SHA256"]&&
  proof["InputHash"]===raw["InputHash"]&&And@@Values[proof["Checks"]]];
basis=Get[FileNameJoin[{root,"common","s02_result","s02_result.wl"}]];
gate["same accepted physical basis",And@@Values[basis["Checks"]]&&raw["PhotonLabels"]===basis["PhotonLabels"]&&raw["SpinLabels"]===basis["SpinLabels"]];
dims=Length/@{basis["PhotonLabels"],basis["SpinLabels"],basis["SpinLabels"]};
indices=Tuples[Range/@dims];components=raw["Components"];
gate["complete component inventory",Lookup[components,"Index"]===indices&&And@@Lookup[components,"Accepted"]&&
  And@@Flatten[Values[#["Checks"]]&/@components]];
distributions={"Delta","L0","L1","Regular"};
Do[gate["component response reconstruction "<>ToString[{sign,distribution},InputForm],
  ArrayReshape[#["Branches"][sign][distribution]&/@components,dims]===raw["NLOResponse"][sign][distribution]],
  {sign,{1,-1,0}},{distribution,distributions}];
Do[name=Keys[raw["FhatsBMHV"]][[h]];
  gate[name<>" Born reference comparison was executed",TrueQ[raw["Checks"][name<>" original unpolarized Born hat"]]];
  Do[gate[name<>" original reference comparison was executed "<>ToString[{sign,distribution},InputForm],
      TrueQ[raw["Checks"][name<>" original unpolarized finite hat "<>ToString[{sign,distribution},InputForm]]]];
    projected=Table[Sum[raw["FhatPhotonWeights"][[h,a]]raw["NLOResponse"][sign][distribution][[a,j,i]],
      {a,dims[[1]]}],{j,dims[[2]]},{i,dims[[3]]}];
    gate[name<>" saved projection reconstruction "<>ToString[{sign,distribution},InputForm],
      projected===raw["FhatsBMHV"][name]["NLO"][sign][distribution]],
    {sign,{1,-1,0}},{distribution,distributions}],{h,Length[raw["FhatsBMHV"]]}];
gate["entire export finite",FreeQ[{raw["NLOResponse"],raw["FhatsBMHV"]},eps|D|gs|_Missing|_GLI|_CutIntegral|_PaVe|_Integrate|_Series|_SeriesData|_Limit|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
cache=FileNameJoin[{root,"cache","s14",channel,IntegerString[raw["InputHash"],16]}];
labels=Flatten[Table[{index,sign,distribution},{index,indices},{sign,{1,-1,0}},{distribution,distributions}],2];
gate["complete continuation checkpoint inventory",Lookup[proof["CheckpointRows"],"Label"]===labels];
Do[file=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];saved=Get[file];
  If[!(AssociationQ[saved]&&saved["InputHash"]===raw["InputHash"]&&saved["Label"]===label&&TrueQ[saved["Accepted"]]&&
    FileHash[file,"SHA256"]===proof["CheckpointRows"][[n]]["CurrentHash"]&&
    And@@(Factor[Together[#]]===0&/@Values[saved["PoleResiduals"]])),gate["checkpoint "<>ToString[label,InputForm],False]],
  {n,Length[labels]},{label,{labels[[n]]}}];
gate["all executed pole checkpoints verified",True];
result=<|"Schema"->"polarized-sidis-completed-assembly-validation-v1","Channel"->channel,
  "SourceHash"->FileHash[sourcePath,"SHA256"],"ResultHash"->FileHash[path,"SHA256"],"InputHash"->raw["InputHash"],
  "Checks"->checks,"Accepted"->True,"NativeVersions"->{$Version,$FeynCalcVersion},"FiniteNLOFHatsComputed"->False|>;
out=FileNameJoin[{root,channel,"s14_recovery_result"}];If[!DirectoryQ[out],CreateDirectory[out,CreateIntermediateDirectories->True]];
Put[result,FileNameJoin[{out,"s14_result.wl"}]];
gate["validation output reload",Get[FileNameJoin[{out,"s14_result.wl"}]]===result];
Export[FileNameJoin[{out,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_verify_completed_assembly"];Quit[0];

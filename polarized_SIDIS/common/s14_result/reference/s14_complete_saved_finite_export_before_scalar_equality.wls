(* Validate the completed native export in a clean allocation without repeating its algebra. *)
$HistoryLength=0;root=Directory[];channel=Environment["POLARIZED_SIDIS_CHANNEL"];checks=<||>;
recoverySource=FileNameJoin[{root,"common","s14_complete_saved_finite_export.wls"}];
gate[name_,test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks,name],Print["PASS: ",name]];AssociateTo[checks,name->True],
  Print["FAIL: ",name];Quit[1]];
gate["compute allocation",StringQ[Environment["JOB_ID"]]&&!StringStartsQ[$MachineName,"login"]];
gate["isolated runtime",StringStartsQ[$UserBaseDirectory,root<>"/"]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
gate["complete recovery syntax",SyntaxQ[Import[recoverySource,"Text"]]];
recovery=Import[FileNameJoin[{root,"common","s14_export_recovery_inputs.json"}],"RawJSON"];
gate["bound own export recovery",recovery["schema"]==="polarized-sidis-saved-finite-export-recovery-v1"&&
  recovery["channel"]===channel&&channel==="Hqqbar"];
path[relative_] := FileNameJoin[{root,relative}];
hexHash[relative_] := IntegerString[FileHash[path[relative],"SHA256"],16,64];
parent=Import[path[recovery["parent_receipt"]],"RawJSON"];
gate["recorded completed-algebra export failure",parent["job_id"]===recovery["parent_job_id"]&&
  parent["passed"]===False&&parent["reason"]==="normal_exit"&&
  hexHash[recovery["parent_receipt"]]===recovery["files"][recovery["parent_receipt"]]];
KeyValueMap[gate["unchanged producer input "<>#1,hexHash[#1]===#2]&,parent["reviewed_sha256"]];
gate["bound complete native export",hexHash[recovery["pending_result"]]===recovery["files"][recovery["pending_result"]]&&
  FileByteCount[path[recovery["pending_result"]]]<128*1024^2];
gate["bound producer log",hexHash[recovery["parent_log"]]===recovery["files"][recovery["parent_log"]]];
parentLog=Import[path[recovery["parent_log"]],"Text"];
gate["producer reached its bounded complete export",StringContainsQ[parentLog,"bounded complete finite result file"]&&
  StringContainsQ[parentLog,"No more memory available."]&&!StringContainsQ[parentLog,"FAIL:"]];
Clear[parentLog];
Print["RECOVERY_LOAD_BEGIN memory ",MemoryInUse[]];
raw=Get[path[recovery["pending_result"]]];
Print["RECOVERY_LOAD_COMPLETE memory ",MemoryInUse[]];
Share[];ClearSystemCache[];
gate["accepted complete saved BMHV schema",AssociationQ[raw]&&
  raw["Schema"]==="polarized-sidis-finite-bmhv-response-v1"&&raw["Channel"]===channel&&
  And@@Values[raw["Checks"]]&&TrueQ[raw["CompletePoleCancellationChecked"]]&&
  TrueQ[raw["UnpolarizedFinalReferenceComparisonPassed"]]&&
  TrueQ[raw["FiniteMinimalSubtractionCoefficientsComputed"]]&&
  raw["FiniteAxialSchemeConversionApplied"]===False&&raw["FiniteNLOFHatsComputed"]===False];
producerPath=path["common/s14_assemble_finite_spin.wls"];
gate["unchanged mathematical and dispatch sources",raw["SourceHash"]===FileHash[producerPath,"SHA256"]&&
  raw["DispatchSourceHash"]===FileHash[path["common/s14_assemble_finite_refined.wls"],"SHA256"]];
KeyValueMap[gate["unchanged saved physical input "<>#1,FileHash[path[#1],"SHA256"]===#2]&,raw["InputHashes"]];
gate["same native input identity",raw["InputHash"]===Hash[
  {raw["SourceHash"],raw["InputHashes"],$Version,$FeynCalcVersion},"SHA256"]];
basis=Get[path["common/s02_result/s02_result.wl"]];
base=Import[path["common/s01_inputs.json"],"RawJSON"];
gate["same accepted physical basis",And@@Values[basis["Checks"]]&&
  raw["PhotonLabels"]===basis["PhotonLabels"]&&raw["SpinLabels"]===basis["SpinLabels"]];
core=base["channel_contracts"][channel]["amplitude_schema"]==="core";
gate["own real-only normalization contract",!core];
producerText=Import[producerPath,"Text"];
section[start_,finish_] := Module[{begin,end},
  gate["unique producer section "<>start,StringCount[producerText,start]===1];
  begin=First[First[StringPosition[producerText,start]]];
  end=Select[StringPosition[producerText,finish],First[#]>begin&];
  gate["producer section endpoint "<>start,Length[end]>0];
  StringTake[producerText,{begin,First[First[end]]-1}]];
couplingCode=section["couplingSquare=Factor[","\nphaseInput="];
distributionCode=section["distributions={","\nassemble["];
normalizationCode=section["  normalization=If[core,","\n  gate[\"finite physical component\""];
leadingCode=section["leadingResponse=If[core,","\nfiniteResponse="];
gate["unchanged saved-normalization syntax",And@@(SyntaxQ/@
  {couplingCode,distributionCode,normalizationCode,leadingCode})];
ToExpression[couplingCode,InputForm];ToExpression[distributionCode,InputForm];
normalizeSaved[value_] := Block[{branches=value,normalization},ToExpression[normalizationCode,InputForm];branches];
dimensions={Length[basis["PhotonLabels"]],Length[basis["SpinLabels"]],Length[basis["SpinLabels"]]};
indices=Tuples[Range/@dimensions];signs={1,-1,0};
gate["complete physical component inventory",Lookup[raw["Components"],"Index"]===indices&&
  AllTrue[raw["Components"],TrueQ[#["Accepted"]]&&And@@Values[#["Checks"]]&]&&
  Keys[raw["NLOResponse"]]===signs&&AllTrue[Values[raw["NLOResponse"]],Keys[#]===distributions&]];
cache=path["cache/s14/"<>channel<>"/"<>IntegerString[raw["InputHash"],16]];
Do[component=raw["Components"][[position]];index=component["Index"];
  candidate=Association@Table[sign->Association@Table[
    label={index,sign,distribution};
    checkpointPath=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
    relative=StringDrop[checkpointPath,StringLength[root]+1];
    gate["every own finite checkpoint is bound",KeyExistsQ[recovery["files"],relative]];
    saved=Get[checkpointPath];
    gate["accepted own finite checkpoint schema",saved["InputHash"]===raw["InputHash"]&&
      TrueQ[saved["Accepted"]]&&saved["Label"]===label];
    distribution->saved["Finite"],{distribution,distributions}],{sign,signs}];
  candidate=normalizeSaved[candidate];
  gate["entire saved finite component "<>ToString[index,InputForm],candidate===component["Branches"]];
  Do[gate["complete tensor embedding "<>ToString[index,InputForm],
    Extract[raw["NLOResponse"][sign][distribution],index]===candidate[sign][distribution]],
    {sign,signs},{distribution,distributions}];
  Clear[candidate,saved,component];ClearSystemCache[],{position,Length[indices]}];
ToExpression[leadingCode,InputForm];
gate["original own leading response",leadingResponse===raw["LODeltaResponse"]];
hatNames=Keys[raw["FhatsBMHV"]];
config=Import[path["common/s14_inputs.json"],"RawJSON"];
gate["complete original projector inventory",hatNames===Keys[config["channels"][channel]["unpolarized_hats"]]&&
  Length[hatNames]===Length[raw["FhatPhotonWeights"]]];
Do[name=hatNames[[hatIndex]];
  gate[name<>" accepted original Born reference check",TrueQ[raw["Checks"][name<>" original unpolarized Born hat"]]];
  Do[gate[name<>" exact saved Born projector",Sum[raw["FhatPhotonWeights"][[hatIndex,a]]leadingResponse[[a,j,i]],
    {a,dimensions[[1]]}]===raw["FhatsBMHV"][name]["LODelta"][[j,i]]],
    {j,dimensions[[2]]},{i,dimensions[[3]]}];
  Do[gate[name<>" accepted original reference "<>ToString[{sign,distribution},InputForm],
      TrueQ[raw["Checks"][name<>" original unpolarized finite hat "<>ToString[{sign,distribution},InputForm]]]];
    Do[gate[name<>" exact saved tensor projector "<>ToString[{sign,distribution,j,i},InputForm],
      Sum[raw["FhatPhotonWeights"][[hatIndex,a]]raw["NLOResponse"][sign][distribution][[a,j,i]],
        {a,dimensions[[1]]}]===raw["FhatsBMHV"][name]["NLO"][sign][distribution][[j,i]]],
      {j,dimensions[[2]]},{i,dimensions[[3]]}],{sign,signs},{distribution,distributions}],
  {hatIndex,Length[hatNames]}];
gate["finite reloaded tensor and hats",FreeQ[{raw["NLOResponse"],raw["FhatsBMHV"]},
  eps|D|gs|_Missing|_GLI|_CutIntegral|_PaVe|_Integrate|_Limit|_Series|_SeriesData|
  _ConditionalExpression|_Piecewise|_Real|$Failed|$Aborted|Indeterminate|_DirectedInfinity]];
resultPath=path[channel<>"/s14_result/s14_result.wl"];
CopyFile[path[recovery["pending_result"]],resultPath,OverwriteTarget->True];
gate["published bytes equal the completely validated native export",
  IntegerString[FileHash[resultPath,"SHA256"],16,64]===recovery["files"][recovery["pending_result"]]];
Export[path[channel<>"/s14_result/s14_checks.json"],<|"channel"->channel,"checks"->checks,
  "component_count"->Length[indices],"finite_minimal_subtraction_coefficients_computed"->True,
  "finite_nlo_fhats_computed"->False,"parent_job_id"->parent["job_id"],
  "recovery_source_sha256"->IntegerString[FileHash[recoverySource,"SHA256"],16,64],
  "job_id"->Environment["JOB_ID"]|>,"RawJSON"];
Print["PASS: s14_complete_saved_finite_export"];Quit[0];

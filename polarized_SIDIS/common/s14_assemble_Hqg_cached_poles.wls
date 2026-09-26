(* Reuse accepted Hqg frame fields and the executed own common-root proof. *)
$HistoryLength=0;
hqgRegularSource=FileNameJoin[{Directory[],"common","s14_assemble_Hqg_cached_poles.wls"}];
hqgRegularParent=FileNameJoin[{Directory[],"common","s14_assemble_Hqg_refined.wls"}];
hqgFrameConsumer=FileNameJoin[{Directory[],"common","s14_assemble_finite_projected_frame.wls"}];
If[IntegerString[FileHash[hqgRegularParent,"SHA256"],16,64]=!=
 "cea77d3fb463b56f20c352f895616859b291687d78511452204d17d67f34af5d"||
 IntegerString[FileHash[hqgFrameConsumer,"SHA256"],16,64]=!=
 "b4ea25b660b0fc445ecbc302668a20436435f2b2cc9b6a6ac59871ec051faf2a"||
 !SyntaxQ[Import[hqgRegularSource,"Text"]],Print["FAIL: pinned own assembly entry"];Quit[1]];
hqgFrameText=Import[hqgFrameConsumer,"Text"];
hqgFrameBoundary="projectedParentText=Import[projectedParent,\"Text\"];";
If[StringCount[hqgFrameText,hqgFrameBoundary]=!=1,Print["FAIL: unique frame reader boundary"];Quit[1]];
hqgFramePrefix=StringTake[hqgFrameText,First[First[StringPosition[hqgFrameText,hqgFrameBoundary]]]-1];
If[!SyntaxQ[hqgFramePrefix],Print["FAIL: complete frame reader definitions"];Quit[1]];
ToExpression[hqgFramePrefix,InputForm];
hqgRegularReplace[text_,old_,new_]:=Module[{changed},
 If[StringCount[text,old]=!=1,Print["FAIL: unique own assembly interface"];Quit[1]];
 changed=StringReplace[text,old->new];
 If[!SyntaxQ[changed]||StringReplace[changed,new->old]=!=text,
  Print["FAIL: unchanged complete own assembly"];Quit[1]];changed];
hqgRegularPrepareFrame[]:=(hqgCompactText=hqgRegularReplace[hqgCompactText,
 "ToExpression[compactAssemblyInitialization,InputForm];",
 "projectedInstallReader[];ToExpression[compactAssemblyInitialization,InputForm];"]);
hqgRegularInstall[]:=Module[{receipt,proof,conditions,previous,changed,before,after,seconds},
 hqgRegularProofPath=FileNameJoin[{root,"Hqg","s14_regular_pole_result","s14_result.wl"}];
 hqgRegularReceiptPath=FileNameJoin[{DirectoryName[hqgRegularProofPath],"s14_execution.json"}];
 receipt=Import[hqgRegularReceiptPath,"RawJSON"];
 gate["accepted own regular-pole proof",TrueQ[receipt["passed"]]&&
  receipt["result_sha256"]["Hqg/s14_regular_pole_result/s14_result.wl"]===
   IntegerString[FileHash[hqgRegularProofPath,"SHA256"],16,64]];
 proof=Get[hqgRegularProofPath];
 gate["same native own regular-pole contract",proof["Schema"]==="polarized-sidis-Hqg-regular-pole-refinement-v1"&&
  proof["Channel"]===channel&&channel==="Hqg"&&TrueQ[proof["Accepted"]]&&And@@Values[proof["Checks"]]&&
  proof["InputHash"]===inputHash&&proof["BaselineSourceHash"]===sourceHash&&
  proof["NativeVersions"]==={$Version,FeynCalc`$FeynCalcVersion}&&
  proof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqg_regular_poles.wls"}],"SHA256"]&&
  proof["ConfigHash"]===FileHash[FileNameJoin[{root,"common","s14_Hqg_regular_pole_inputs.json"}],"SHA256"]&&
  proof["EndpointProofHash"]===FileHash[hqgProofPath,"SHA256"]];
 conditions=(physical/.t->proof["ActualLabel"][[2]] omega-s)&&
  If[proof["ActualLabel"][[2]]===0,True,omega>0]&&flavorDomain;
 gate["same complete original regular-pole interface",Last[proof["ActualLabel"]]==="Regular"&&
  proof["ActualConditions"]===conditions&&proof["OriginalZeroDefinitions"]===DownValues[zero]&&
  proof["OriginalFinitePartDefinitions"]===hqgOriginalFinite];
 gate["all own comparison poles vanished",Length[proof["ActualRows"]]>0&&Length[proof["ControlRows"]]>0&&
  AllTrue[proof["ActualRows"],#["Residual"]===0&&#["InputSumResidual"]===0&]&&
  AllTrue[proof["ControlRows"],#["Residual"]===0&]];
 gate["unchanged own accepted finite control",proof["ControlLabel"]===hqgProof["ControlLabel"]&&
  proof["ControlCheckpointHash"]===FileHash[hqgControlFile,"SHA256"]&&
  proof["ControlFiniteHash"]===Hash[Get[hqgControlFile]["Finite"],"SHA256"]];
 before=assemble[First[proof["ControlLabel"]]];
 gate["whole previous own component accepted",TrueQ[before["Accepted"]]&&And@@Values[before["Checks"]]];
 DownValues[ownPoleRefine]=proof["Definitions"];
 DownValues[refineUVResidual]=proof["RefinementDefinitions"];
 gate["exact executed common-root routines installed",{DownValues[ownPoleRefine],DownValues[refineUVResidual]}===
  Lookup[proof,{"Definitions","RefinementDefinitions"}]];
 ownPoleRootEvidence=<||>;
 previous=DownValues[hqgRefinedPoleZero];
 gate["one own pole refinement call",Count[previous,refineAssemblyPole,Infinity,Heads->True]===1];
 changed=previous/.refineAssemblyPole->ownPoleRefine;
 gate["complete pole predicate restored exactly",(changed/.ownPoleRefine->refineAssemblyPole)===previous];
 DownValues[hqgRefinedPoleZero]=changed;
 {seconds,after}=AbsoluteTiming[assemble[First[proof["ControlLabel"]]]];
 gate["entire own finite component unchanged with common roots",TrueQ[after["Accepted"]]&&And@@Values[after["Checks"]]&&
  KeyTake[before,{"Index","Branches"}]===KeyTake[after,{"Index","Branches"}]];
 hqgRegularEvidence=<|"ProofHash"->FileHash[hqgRegularProofPath,"SHA256"],
  "ProofReceiptHash"->FileHash[hqgRegularReceiptPath,"SHA256"],"SourceHash"->FileHash[hqgRegularSource,"SHA256"],
  "ControlIndex"->First[proof["ControlLabel"]],"WholeControlUnchanged"->True,"ControlSeconds"->seconds|>;
 Print["HQG_REGULAR_CONSUMER_ACCEPTED ",InputForm[hqgRegularEvidence]]];

(* Cache the computed pole reduction instead of refactoring its unreduced input. *)
hqgComputedPoles=<||>;
hqgMemoPole[value_,conditions_]:=Module[{key,result},
 key=Hash[{value,conditions},"SHA256"];
 result=ownPoleRefine[value,conditions];
 AssociateTo[hqgComputedPoles,key->result];result];
hqgStoredPoleMap[values_Association,conditions_]:=Association@KeyValueMap[
 Function[{power,value},Module[{key,result},
  key=Hash[{value,conditions},"SHA256"];
  gate["stored pole has executed proof",KeyExistsQ[hqgComputedPoles,key]];
  result=hqgComputedPoles[key];
  gate["stored pole is the proved zero",result===0];power->result]],values];
hqgPoleStorageInstall[]:=Module[{text,start,finish,original,candidate,oldFinite,oldPredicate,
 actualPath,actual,expected,validationDirectory,validationFile,canonicalFile,checked,saved,
 before,after,seconds,definitions},
 oldFinite=DownValues[finitePart];oldPredicate=DownValues[hqgRefinedPoleZero];
 gate["one existing common-root predicate",Count[oldPredicate,ownPoleRefine,Infinity,Heads->True]===1];
 DownValues[hqgRefinedPoleZero]=oldPredicate/.ownPoleRefine->hqgMemoPole;
 gate["entire computed-pole predicate restored",
  (DownValues[hqgRefinedPoleZero]/.hqgMemoPole->ownPoleRefine)===oldPredicate];
 text=Import[FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}],"Text"];
 start=StringPosition[text,"finitePart[parts_,label_,assumptions_]"];
 finish=StringPosition[text,"\ndistributions={"];
 gate["unique original checkpoint implementation",Length[start]===1&&Length[finish]===1];
 original=StringTake[text,{First[First[start]],First[First[finish]]-1}];
 original=hqgRegularReplace[original,"zero[residues[n],assumptions]","hqgRefinedPoleZero[residues[n],assumptions]"];
 candidate=hqgRegularReplace[original,"Map[Factor,residues]","hqgStoredPoleMap[residues,assumptions]"];
 gate["complete checkpoint consumer syntax",SyntaxQ[candidate]];
 ToExpression[candidate,InputForm];
 definitions=DownValues[finitePart];
 gate["entire finite extraction and pole checks unchanged",
  (definitions/.HoldPattern[hqgStoredPoleMap[value_,assumptions]]:>Map[Factor,value])===oldFinite];
 before=assemble[First[hqgProof["ControlLabel"]]];
 gate["unchanged complete accepted own control",TrueQ[before["Accepted"]]&&And@@Values[before["Checks"]]];
 actualPath=FileNameJoin[{root,"Hqg","s14_regular_pole_result","reference","s14_regular_checkpoint.wl"}];
 actual=Get[actualPath];
 gate["same actual equation for checkpoint comparison",FileHash[actualPath,"SHA256"]===
  Get[hqgRegularProofPath]["ActualCheckpointHash"]&&actual["InputHash"]===inputHash&&actual["Accepted"]===False];
 expected=bounded[Coefficient[Expand[Total[actual["InputParts"]],eps],eps,0],"unchanged actual finite extraction"];
 validationDirectory=FileNameJoin[{cache,"pole_storage_"<>IntegerString[FileHash[hqgRegularSource,"SHA256"],16]}];
 If[!DirectoryQ[validationDirectory],CreateDirectory[validationDirectory]];
 {seconds,checked}=AbsoluteTiming[Block[{cache=validationDirectory},
  finitePart[actual["InputParts"],actual["Label"],Get[hqgRegularProofPath]["ActualConditions"]]]];
 gate["actual complete finite coefficient unchanged",checked===expected];
 validationFile=FileNameJoin[{validationDirectory,"finite_"<>IntegerString[Hash[actual["Label"],"SHA256"],16]<>".wl"}];
 saved=Get[validationFile];
 gate["actual saved checkpoint contains only computed cancelled poles",TrueQ[saved["Accepted"]]&&
  saved["InputHash"]===inputHash&&saved["Label"]===actual["Label"]&&saved["Finite"]===expected&&
  Keys[saved["PoleResiduals"]]===Keys[actual["PoleResiduals"]]&&AllTrue[Values[saved["PoleResiduals"]],#===0&]];
 canonicalFile=FileNameJoin[{cache,FileNameTake[validationFile]}];
 If[FileExistsQ[canonicalFile]&&TrueQ[Lookup[Get[canonicalFile],"Accepted",False]],
  gate["existing accepted finite checkpoint unchanged",Get[canonicalFile]["Finite"]===expected],
  put[saved,canonicalFile]];
 after=assemble[First[hqgProof["ControlLabel"]]];
 gate["whole own component unchanged after checkpoint comparison",TrueQ[after["Accepted"]]&&And@@Values[after["Checks"]]&&
  KeyTake[before,{"Index","Branches"}]===KeyTake[after,{"Index","Branches"}]];
 hqgPoleStorageEvidence=<|"SourceHash"->FileHash[hqgRegularSource,"SHA256"],
  "ActualCheckpointHash"->FileHash[actualPath,"SHA256"],"ActualLabel"->actual["Label"],
  "ActualFiniteUnchanged"->True,"OwnCompleteControlUnchanged"->True,"ActualSeconds"->seconds,
  "OriginalCheckpointDefinitions"->oldFinite,"InstalledCheckpointDefinitions"->definitions|>;
 Print["HQG_POLE_STORAGE_ACCEPTED ",InputForm[KeyDrop[hqgPoleStorageEvidence,{"OriginalCheckpointDefinitions","InstalledCheckpointDefinitions"}]]]];

hqgRegularRecord[]:=Module[{anchor,replacement},
 anchor="compactAssemblyWrite[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
 replacement="AssociateTo[result,{\"CommonRootRefinement\"->hqgRegularEvidence,\"CommonRootEvidence\"->ownPoleRootEvidence,\"PoleStorageEvidence\"->hqgPoleStorageEvidence,\"ComputedPoleProofs\"->hqgComputedPoles}];"<>anchor;
 phaseRunTail=hqgRegularReplace[phaseRunTail,anchor,replacement]];
hqgRegularText=Import[hqgRegularParent,"Text"];
hqgRegularText=hqgRegularReplace[hqgRegularText,
 "hqgCompactText=StringTrim[Import[hqgCompactSource,\"Text\"]];",
 "hqgCompactText=StringTrim[Import[hqgCompactSource,\"Text\"]];hqgRegularPrepareFrame[];"];
hqgRegularText=hqgRegularReplace[hqgRegularText,"\nToExpression[phaseRunTail,InputForm];",
 "\nhqgRegularInstall[];hqgPoleStorageInstall[];projectedRecordEvidence[];hqgRegularRecord[];ToExpression[phaseRunTail,InputForm];"];
ToExpression[hqgRegularText,InputForm];

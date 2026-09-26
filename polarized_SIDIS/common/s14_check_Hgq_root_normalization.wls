(* Reuse the accepted residual refinement on the actual failed assembly pole. *)
$HistoryLength=0;
poleRoot=Directory[];
poleSource=FileNameJoin[{poleRoot,"common","s14_check_Hgq_root_normalization.wls"}];
poleConfigPath=FileNameJoin[{poleRoot,"common","s14_Hgq_root_normalization_inputs.json"}];
poleSettings=Import[poleConfigPath,"RawJSON"];
poleBaseline=FileNameJoin[{poleRoot,"common","s14_assemble_finite_spin.wls"}];
If[IntegerString[FileHash[poleBaseline,"SHA256"],16,64]=!=poleSettings["baseline_sha256"],Quit[1]];
PrependTo[$Path,"/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
poleText=Import[poleBaseline,"Text"];
If[StringCount[poleText,"\nindices=Tuples"]=!=1,Quit[1]];
polePrefix=First[StringSplit[poleText,"\nindices=Tuples"]];
If[StringCount[polePrefix,"Get[\"FeynCalc`\"]"]=!=1,Quit[1]];
polePrefix=StringReplace[polePrefix,"Get[\"FeynCalc`\"]"->"Null"];
poleFrameAnchor="realFrame=spinReal[\"Frame\"];";
poleFrameRelease=poleFrameAnchor<>"Clear[spinReal];ClearSystemCache[];";
If[StringCount[polePrefix,poleFrameAnchor]=!=1,Quit[1]];
poleUnreleasedPrefix=polePrefix;
polePrefix=StringReplace[polePrefix,poleFrameAnchor->poleFrameRelease];
If[StringReplace[polePrefix,poleFrameRelease->poleFrameAnchor]=!=poleUnreleasedPrefix,Quit[1]];
If[!SyntaxQ[polePrefix]||!SyntaxQ[Import[poleSource,"Text"]],Quit[1]];
ToExpression[polePrefix,InputForm];
gate["own pole comparison channel",channel===poleSettings["channel"]&&channel==="Hgq"&&core];
KeyValueMap[gate["bound pole comparison input "<>#1,
  IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,poleSettings["files"]];
poleFailedPath=FileNameJoin[{root,poleSettings["failed_checkpoint"]}];
poleControlPath=FileNameJoin[{root,poleSettings["control_checkpoint"]}];
poleFailed=Get[poleFailedPath];poleControl=Get[poleControlPath];
gate["failed checkpoint retains exact assembly inputs",poleFailed["InputHash"]===inputHash&&
  !TrueQ[poleFailed["Accepted"]]&&KeyExistsQ[poleFailed,"InputParts"]&&
  Length[poleFailed["PoleResiduals"]]>0];
gate["own accepted control identity",poleControl["InputHash"]===inputHash&&
  TrueQ[poleControl["Accepted"]]&&KeyExistsQ[poleControl,"Finite"]&&
  Length[poleControl["PoleResiduals"]]>0];
poleReceipt=Import[FileNameJoin[{root,poleSettings["failed_receipt"]}],"RawJSON"];
gate["failed execution binds the unchanged assembly",poleReceipt["job_id"]===poleSettings["failed_job_id"]&&
  !TrueQ[poleReceipt["passed"]]&&poleReceipt["exit_code"]===1&&
  poleReceipt["reviewed_sha256"]["common/s14_assemble_finite_spin.wls"]===poleSettings["baseline_sha256"]];
gate["failed execution uses the reviewed assembly adapter",
  poleReceipt["reviewed_sha256"]["common/s14_assemble_finite_Hgq_refined.wls"]===
    poleSettings["failed_entrypoint_sha256"]];
KeyValueMap[gate["failed execution input unchanged "<>#1,
  poleReceipt["reviewed_sha256"][#1]===IntegerString[#2,16,64]]&,inputHashes];
poleUV=Get[FileNameJoin[{root,"Hqg","s13_branch_result","s13_result.wl"}]];
poleUVReceipt=Import[FileNameJoin[{root,"Hqg","s13_branch_result","s13_execution.json"}],"RawJSON"];
gate["accepted existing residual routine",TrueQ[poleUVReceipt["passed"]]&&TrueQ[poleUV["Accepted"]]&&
  And@@Values[poleUV["Checks"]]&&poleUV["RefinedOriginalResidual"]===0&&poleUV["RefinedSumResidual"]===0&&
  poleUV["SourceHash"]===FileHash[FileNameJoin[{root,"common","s13_check_uv_branches.wls"}],"SHA256"]&&
  poleUV["NativeVersions"]==={$Version,$FeynCalcVersion}];
DownValues[refineUVResidual]=poleUV["Definitions"];
gate["exact existing residual routine installed",DownValues[refineUVResidual]===poleUV["Definitions"]];
poleFactorCertificates=<||>;
poleInheritedPath=FileNameJoin[{root,"Hqqbar","s14_pole_factorization_result","s14_result.wl"}];
poleInherited=Get[poleInheritedPath];
poleInheritedReceipt=Import[FileNameJoin[{DirectoryName[poleInheritedPath],"s14_execution.json"}],"RawJSON"];
gate["accepted inherited assembly refinement",TrueQ[poleInheritedReceipt["passed"]]&&
  poleInheritedReceipt["job_id"]==="14806606"&&TrueQ[poleInherited["Accepted"]]&&
  And@@Values[poleInherited["Checks"]]&&
  poleInheritedReceipt["result_sha256"]["Hqqbar/s14_pole_factorization_result/s14_result.wl"]===
    IntegerString[FileHash[poleInheritedPath,"SHA256"],16,64]&&
  poleInherited["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_pole_factorization.wls"}],"SHA256"]&&
  poleInherited["BaselineSourceHash"]===sourceHash&&poleInherited["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  AllTrue[poleInherited["Rows"],#["Refined"]===0&&#["InputSumRefined"]===0&]&&
  AllTrue[poleInherited["ControlRows"],#["Refined"]===0&]];
gate["unchanged original predicates and refinement definitions",
  DownValues[zero]===poleInherited["OriginalZeroDefinitions"]&&
  DownValues[finitePart]===poleInherited["OriginalFinitePartDefinitions"]&&
  DownValues[refineUVResidual]===poleInherited["RefinementDefinitions"]];
DownValues[refineAssemblyPole]=poleInherited["Definitions"];
gate["exact accepted assembly refinement installed",DownValues[refineAssemblyPole]===poleInherited["Definitions"]];


poleOriginalAssemblyDefinitions=DownValues[refineAssemblyPole];
DownValues[refineOriginalAssemblyPole]=poleOriginalAssemblyDefinitions/.
  refineAssemblyPole->refineOriginalAssemblyPole;
normalizeAssemblyRoots[value_,conditions_] := Module[
  {powers,rules={},certificates={},variables,domain,radical,candidate,decision,
   normalized,seconds,key,factors,positiveFactors,remainder,factor,multiplicity,
   sign,positiveDecision,negativeDecision,factorSigns=<||>,factorKey,factorCertificates},
  key=Hash[{value,conditions},"SHA256"];
  variables=DeleteDuplicates[Cases[{value,conditions},
    symbol_Symbol/;MemberQ[{"Global`","FeynCalc`"},Context[symbol]],Infinity]];
  gate["root variables real "<>ToString[key],Refine[Element[variables,Reals],conditions]===True];
  domain=With[{v=variables,c=conditions},Resolve[Exists[v,c],Reals]];
  gate["root normalization domain nonempty "<>ToString[key],domain===True];
  powers=DeleteDuplicates[Cases[value,power:Power[_,_Rational]:>power,{0,Infinity}]];
  {seconds,normalized}=AbsoluteTiming[
    Do[
      factors=FactorList[Together[First[radical]]];
      gate["exact root radicand factorization "<>ToString[Hash[radical,"SHA256"]],
        ListQ[factors]&&AllTrue[factors,Length[#]===2&&IntegerQ[Last[#]]&]&&
        Together[First[radical]-Times@@(Power@@#&/@factors)]===0];
      positiveFactors={};remainder=1;factorCertificates={};
      Do[
        factor=First[row];multiplicity=Last[row];factorKey=Hash[factor,"SHA256"];
        If[KeyExistsQ[factorSigns,factorKey],sign=factorSigns[factorKey],
          positiveDecision=Refine[factor>0,conditions];
          negativeDecision=If[TrueQ[positiveDecision],False,Refine[factor<0,conditions]];
          If[!TrueQ[positiveDecision]&&!TrueQ[negativeDecision],
            positiveDecision=TimeConstrained[
              Reduce[conditions&&factor<=0,variables,Reals],15,$Failed]===False;
            If[!TrueQ[positiveDecision],negativeDecision=TimeConstrained[
              Reduce[conditions&&factor>=0,variables,Reals],15,$Failed]===False]];
          sign=Which[TrueQ[positiveDecision],1,TrueQ[negativeDecision],-1,True,0];
          AssociateTo[factorSigns,factorKey->sign]];
        If[sign===0,remainder*=factor^multiplicity,
          AppendTo[positiveFactors,{sign factor,multiplicity}];
          remainder*=sign^multiplicity;
          AppendTo[factorCertificates,<|"Factor"->factor,"Sign"->sign,
            "Conditions"->conditions,"ExactSign"->True|>]],
        {row,factors}];
      candidate=remainder^Last[radical] Times@@
        (Power[First[#],Last[#] Last[radical]]&/@positiveFactors);
      If[candidate===radical,Continue[]];
      If[!FreeQ[candidate,$Failed|$Aborted|Indeterminate|_DirectedInfinity],Continue[]];
      decision=FullSimplify[radical==candidate,conditions,TimeConstraint->15];
      If[decision=!=True,decision=
        TimeConstrained[Reduce[conditions&&radical!=candidate,variables,Reals],30,$Failed]===False];
      If[!TrueQ[decision],
        Print["UNCERTIFIED_ROOT ",InputForm[radical]," CANDIDATE ",InputForm[candidate]];
        Continue[]];
      AppendTo[rules,radical->candidate];
      AppendTo[certificates,<|"Original"->radical,"Candidate"->candidate,
        "Conditions"->conditions,"ExactEquality"->True,"FactorCertificates"->factorCertificates|>];
      Print["CERTIFIED_ROOT ",InputForm[radical]," -> ",InputForm[candidate]],
      {radical,powers}];
    Together[Expand[value/.rules]]];
  gate["every applied root replacement certified "<>ToString[key],
    Length[rules]===Length[certificates]&&AllTrue[certificates,TrueQ[#["ExactEquality"]]&]];
  Print["ROOT_NORMALIZATION ",InputForm[<|"InputBytes"->ByteCount[value],
    "NormalizedBytes"->ByteCount[normalized],"Powers"->Length[powers],
    "CertifiedRules"->Length[rules],"Seconds"->seconds,"ExactZero"->(normalized===0)|>]];
  <|"Method"->"IndividuallyCertifiedPositiveFactorProducts","OriginalHash"->Hash[value,"SHA256"],
    "Conditions"->conditions,"DomainNonempty"->domain,"Rules"->rules,
    "RuleCertificates"->certificates,"InputBytes"->ByteCount[value],
    "NormalizedBytes"->ByteCount[normalized],"Seconds"->seconds,"Result"->normalized|>];
refineAssemblyPole[value_,conditions_] := Module[{certificate,key},
  If[value===0,Return[0]];
  certificate=normalizeAssemblyRoots[value,conditions];
  If[certificate["Result"]===0,
    key=Hash[{value,conditions},"SHA256"];
    AssociateTo[poleFactorCertificates,key->certificate];Return[0]];
  refineOriginalAssemblyPole[value,conditions]];

poleConditions[label_] := (If[Last[label]==="Regular",physical,softPhysical]/.t->label[[2]]omega-s)&&
  If[label[[2]]===0,True,omega>0]&&flavorDomain;
SetAttributes[poleBounded,HoldFirst];
poleBounded[value_,label_] := MemoryConstrained[TimeConstrained[value,300,
  gate["pole comparison time bound "<>ToString[label,InputForm],False]],2*1024^3,
  gate["pole comparison memory bound "<>ToString[label,InputForm],False]];
poleControlConditions=poleConditions[poleControl["Label"]];
poleControlRows=KeyValueMap[Function[{power,value},
  gate["own original pole predicate "<>ToString[power],poleBounded[zero[value,poleControlConditions],"original control"]];
  timed=AbsoluteTiming[poleBounded[refineAssemblyPole[value,poleControlConditions],"refined control"]];
  gate["own accepted pole unchanged "<>ToString[power],Last[timed]===0];
  <|"Power"->power,"Seconds"->First[timed],"Refined"->Last[timed]|>],poleControl["PoleResiduals"]];

polePriorOwnPath=FileNameJoin[{root,channel,"s14_pole_factorization_result","s14_result.wl"}];
polePriorOwn=Get[polePriorOwnPath];
polePriorReceipt=Import[FileNameJoin[{DirectoryName[polePriorOwnPath],"s14_execution.json"}],"RawJSON"];
gate["accepted own nontrivial root-normalization control",TrueQ[polePriorOwn["Accepted"]]&&
  And@@Values[polePriorOwn["Checks"]]&&TrueQ[polePriorReceipt["passed"]]&&
  polePriorReceipt["result_sha256"][channel<>"/s14_pole_factorization_result/s14_result.wl"]===
    IntegerString[FileHash[polePriorOwnPath,"SHA256"],16,64]&&
  polePriorOwn["InputHash"]===inputHash&&polePriorOwn["InputHashes"]===inputHashes&&
  polePriorOwn["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  polePriorOwn["Definitions"]===poleOriginalAssemblyDefinitions&&
  AllTrue[polePriorOwn["Rows"],#["Refined"]===0&&#["InputSumRefined"]===0&]];
poleRootControlRows=Map[Function[row,
  certificate=poleBounded[normalizeAssemblyRoots[row["Original"],polePriorOwn["PhysicalConditions"]],
    {"own accepted root control",row["Power"]}];
  gate["complete own accepted refined residue reproduced "<>ToString[row["Power"]],
    certificate["Result"]===row["Refined"]];
  certificate],polePriorOwn["Rows"]];

poleActualConditions=poleConditions[poleFailed["Label"]];
poleCombined=Expand[Total[poleFailed["InputParts"]],eps];
poleRows=KeyValueMap[Function[{power,value},
  factored=poleBounded[Factor[Together[value]],"actual saved residue factorization"];
  Print["ACTUAL_FACTORED_POLE ",power," ",InputForm[factored]];
  timed=AbsoluteTiming[poleBounded[
    certificate=normalizeAssemblyRoots[value,poleActualConditions];
    gate["root-normalized saved residue exactly vanishes "<>ToString[power],certificate["Result"]===0];
    AssociateTo[poleFactorCertificates,Hash[{value,poleActualConditions},"SHA256"]->certificate];
    certificate["Result"],"actual saved residue refinement"]];
  sumTimed=AbsoluteTiming[poleBounded[
    actual=reduce[Coefficient[poleCombined,eps,power],poleActualConditions];
    gate["original input reduction exactly reproduces saved residue "<>ToString[power],
      actual===value||Together[actual-value]===0];
    Last[timed],"complete original input pole"]];

  Print["ACTUAL_REFINED_POLE ",power," ",InputForm[Last[timed]]," INPUT_SUM ",InputForm[Last[sumTimed]]];
  <|"Power"->power,"Original"->value,"Factored"->factored,"Refined"->Last[timed],
    "InputSumRefined"->Last[sumTimed],"InputSumMethod"->"OriginalReductionAndExactSavedResidueEquality","Seconds"->First[timed],"InputSumSeconds"->First[sumTimed]|>],poleFailed["PoleResiduals"]];
poleResult=<|"Schema"->"polarized-sidis-assembly-pole-refinement-v1","Channel"->channel,
  "SourceHash"->FileHash[poleSource,"SHA256"],"BaselineSourceHash"->sourceHash,
  "ConfigHash"->FileHash[poleConfigPath,"SHA256"],"InheritedPoleProofHash"->FileHash[poleInheritedPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
  "NativeVersions"->{$Version,$FeynCalcVersion},"OriginalZeroDefinitions"->DownValues[zero],
  "OriginalFinitePartDefinitions"->DownValues[finitePart],"Definitions"->DownValues[refineAssemblyPole],
  "OriginalAssemblyDefinitions"->poleOriginalAssemblyDefinitions,
  "RootNormalizationDefinitions"->DownValues[normalizeAssemblyRoots],
  "OriginalAssemblyFallbackDefinitions"->DownValues[refineOriginalAssemblyPole],
  "RootControlRows"->poleRootControlRows,
  "PriorOwnProofHash"->FileHash[polePriorOwnPath,"SHA256"],
  "RefinementDefinitions"->DownValues[refineUVResidual],"ExistingProofHash"->
    FileHash[FileNameJoin[{root,"Hqg","s13_branch_result","s13_result.wl"}],"SHA256"],
  "FailedCheckpoint"->poleFailed,"FailedCheckpointHash"->FileHash[poleFailedPath,"SHA256"],
  "PhysicalConditions"->poleActualConditions,"ControlLabel"->poleControl["Label"],
  "ControlHash"->FileHash[poleControlPath,"SHA256"],"ControlFiniteHash"->Hash[poleControl["Finite"],"SHA256"],
  "ControlRows"->poleControlRows,"Rows"->poleRows,"FactorCertificates"->poleFactorCertificates,"Checks"->checks,"Accepted"->False,"FiniteNLOFHatsComputed"->False|>;
poleDirectory=FileNameJoin[{root,channel,"s14_root_normalization_result"}];
If[!DirectoryQ[poleDirectory],CreateDirectory[poleDirectory,CreateIntermediateDirectories->True]];
put[poleResult,FileNameJoin[{poleDirectory,"s14_unaccepted.wl"}]];
gate["every actual saved residue vanishes",And@@(#["Refined"]===0&/@poleRows)];
gate["every original input-sum pole vanishes",And@@(#["InputSumRefined"]===0&/@poleRows)];
AssociateTo[poleResult,{"Accepted"->True,"Checks"->checks}];
polePath=FileNameJoin[{poleDirectory,"s14_result.wl"}];
poleSerialized="Uncompress["<>ToString[poleBounded[Compress[poleResult],"proof compression"],InputForm]<>"]\n";
gate["pole proof file bound",StringLength[poleSerialized]<128*1024^2];
Export[polePath<>".tmp",poleSerialized,"Text"];
gate["pole proof exact native reload",Get[polePath<>".tmp"]===poleResult];
RenameFile[polePath<>".tmp",polePath,OverwriteTarget->True];
DeleteFile[FileNameJoin[{poleDirectory,"s14_unaccepted.wl"}]];
Export[FileNameJoin[{poleDirectory,"s14_checks.json"}],<|"checks"->checks,"job_id"->Environment["JOB_ID"],
  "accepted"->True,"finite_nlo_fhats_computed"->False|>,"RawJSON"];
Print["PASS: s14_check_Hgq_root_normalization"];Quit[0];

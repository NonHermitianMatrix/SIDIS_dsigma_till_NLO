(* Compare regulator-only expansion with the complete own original phase input. *)
$HistoryLength=0;
regulatorPhaseSource=FileNameJoin[{Directory[],"common","s14_check_regulator_phase.wls"}];
regulatorPhaseParent=FileNameJoin[{Directory[],"common","s14_assemble_finite_cached_parts.wls"}];
If[IntegerString[FileHash[regulatorPhaseParent,"SHA256"],16,64]=!=
 "0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b"||
 !SyntaxQ[Import[regulatorPhaseSource,"Text"]],Quit[1]];
regulatorPhaseText=StringTrim[Import[regulatorPhaseParent,"Text"]];
regulatorPhaseTerminal="ToExpression[cachedPartsRun,InputForm];";
If[!StringEndsQ[regulatorPhaseText,regulatorPhaseTerminal],Quit[1]];
regulatorPhasePrefix=StringDrop[regulatorPhaseText,-StringLength[regulatorPhaseTerminal]];
If[!SyntaxQ[regulatorPhasePrefix],Quit[1]];ToExpression[regulatorPhasePrefix,InputForm];
regulatorPhaseCompare[] := Module[{text,start,end,definition,candidateDefinition,records,control=None,
 label,index,sign,distribution,coefficient,original,candidate,originalSeconds,candidateSeconds,comparisonSeconds,
 first,last,powers,residuals,result,directory,path,serialized},
 gate["own phase comparison channel",channel==="Hqq"];
 text=Import[FileNameJoin[{root,"common","s12_assemble_real_spin.wls"}],"Text"];
 start=First[First[StringPosition[text,"laurentProduct[laurent_"]]];
 end=First[First[StringPosition[text,"\n\nsoftPieces["]]];
 definition=StringTake[text,{start,end-1}];
 gate["one native Laurent expansion",StringCount[definition,"polynomial=Expand[laurent]"]===1];
 candidateDefinition=StringReplace[definition,{"laurentProduct[laurent_"->"regulatorLaurentProduct[laurent_",
   "polynomial=Expand[laurent]"->"polynomial=Expand[laurent,eps]"}];
 gate["unchanged Laurent powers and kernel product",SyntaxQ[candidateDefinition]&&
  StringReplace[candidateDefinition,{"regulatorLaurentProduct[laurent_"->"laurentProduct[laurent_",
    "polynomial=Expand[laurent,eps]"->"polynomial=Expand[laurent]"}]===definition];
 ToExpression[candidateDefinition,InputForm];
 Do[records=Get[file];
   If[Lookup[records,"InputHash",None]===inputHash&&TrueQ[Lookup[records,"Accepted",False]]&&
     Lookup[records,"Finite",0]=!=0&&MemberQ[{"Delta","L0"},Last[records["Label"]]]&&MemberQ[{1,-1},records["Label"][[2]]],
     control=Join[records,<|"File"->file,"FileHash"->FileHash[file,"SHA256"]|>];Break[]],
   {file,FileNames["finite_*.wl",cache]}];
 gate["own accepted nonzero endpoint phase control",AssociationQ[control]];
 label=control["Label"];{index,sign,distribution}=label;
 coefficient=strongFactor realBranch[index,sign,distribution];
 Print["REGULATOR_PHASE_CONTROL ",InputForm[<|"Label"->label,"CoefficientBytes"->ByteCount[coefficient],"Kernel"->phase,"Coefficient"->coefficient|>]];
 {originalSeconds,original}=AbsoluteTiming[bounded[phaseProduct[coefficient,phase,0,label],"own original phase product"]];
 {candidateSeconds,candidate}=AbsoluteTiming[bounded[Block[{laurentProduct},
   DownValues[laurentProduct]=DownValues[regulatorLaurentProduct]/.regulatorLaurentProduct->laurentProduct;
   phaseProduct[coefficient,phase,0,label]],"own regulator phase product"]];
 first=Min[Exponent[Expand[original,eps],eps,Min],Exponent[Expand[candidate,eps],eps,Min]];
 last=Max[Exponent[Expand[original,eps],eps],Exponent[Expand[candidate,eps],eps]];
 gate["same finite integer phase support",IntegerQ[first]&&IntegerQ[last]&&first<=last];powers=Range[first,last];
 {comparisonSeconds,residuals}=AbsoluteTiming[Association@Table[n->bounded[
   Factor[Together[Coefficient[Expand[candidate-original,eps],eps,n]]],{"own full phase coefficient",n}],{n,powers}]];
 gate["complete own original phase product reproduced",And@@(#===0&/@Values[residuals])];
 result=<|"Schema"->"polarized-sidis-regulator-phase-comparison-v1","Channel"->channel,"Accepted"->True,
   "SourceHash"->FileHash[regulatorPhaseSource,"SHA256"],"ParentHash"->FileHash[regulatorPhaseParent,"SHA256"],
   "InputHash"->inputHash,"InputHashes"->inputHashes,"NativeVersions"->{$Version,FeynCalc`$FeynCalcVersion},
   "Control"->KeyTake[control,{"Label","File","FileHash"}],"Coefficient"->coefficient,"Kernel"->phase,
   "OriginalValue"->original,"CandidateValue"->candidate,"Residuals"->residuals,
   "OriginalDefinitions"->DownValues[laurentProduct],"CandidateDefinitions"->DownValues[regulatorLaurentProduct],
   "OriginalSeconds"->originalSeconds,"CandidateSeconds"->candidateSeconds,"ComparisonSeconds"->comparisonSeconds,
   "Checks"->checks,"FiniteNLOFHatsComputed"->False|>;
 directory=FileNameJoin[{root,channel,"s14_regulator_phase_result"}];
 If[!DirectoryQ[directory],CreateDirectory[directory,CreateIntermediateDirectories->True]];
 path=FileNameJoin[{directory,"s14_result.wl"}];serialized="Uncompress["<>ToString[Compress[result],InputForm]<>"]\n";
 gate["bounded phase comparison file",StringLength[serialized]<128*1024^2];Export[path<>".tmp",serialized,"Text"];
 gate["exact phase comparison native reload",Get[path<>".tmp"]===result];RenameFile[path<>".tmp",path,OverwriteTarget->True];
 Export[FileNameJoin[{directory,"s14_checks.json"}],<|"channel"->channel,"checks"->checks,"label"->label,
   "original_seconds"->originalSeconds,"candidate_seconds"->candidateSeconds,"comparison_seconds"->comparisonSeconds,
   "finite_nlo_fhats_computed"->False|>,"RawJSON"];Print["PASS: s14_check_regulator_phase"];Quit[0]];
regulatorPhaseAnchor="cachedPartsRecord[];ToExpression[phaseRunTail,InputForm];";
regulatorPhaseReplacement="cachedPartsRecord[];regulatorPhaseCompare[];";
If[StringCount[cachedPartsRun,regulatorPhaseAnchor]=!=1,Print["FAIL: unique phase comparison boundary"];Quit[1]];
regulatorPhaseRun=StringReplace[cachedPartsRun,regulatorPhaseAnchor->regulatorPhaseReplacement];
If[!SyntaxQ[regulatorPhaseRun]||StringReplace[regulatorPhaseRun,regulatorPhaseReplacement->regulatorPhaseAnchor]=!=cachedPartsRun,Quit[1]];
ToExpression[regulatorPhaseRun,InputForm];

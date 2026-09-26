(* Reuse the pinned reference endpoint code only on its native polynomial support. *)
$HistoryLength=0;
referenceRecoilPath=FileNameJoin[{Directory[],"common","s12_assemble_real_reference_recoil.wls"}];
referenceRecoilBase=FileNameJoin[{Directory[],"common","s12_assemble_real_factored_series.wls"}];
If[IntegerString[FileHash[referenceRecoilBase,"SHA256"],16,64]=!="7bbecbad4109fd3a2cef0f1d69aeaf8e6050c488427327e941bcaa096be0b44f",Quit[1]];
referenceRecoilText=Import[referenceRecoilBase,"Text"];
referenceRecoilBoundary="\nreferenceSeriesDistribute =";
If[StringCount[referenceRecoilText,referenceRecoilBoundary]=!=1 || !SyntaxQ[Import[referenceRecoilPath,"Text"]],Quit[1]];
referenceRecoilPrefix=First[StringSplit[referenceRecoilText,referenceRecoilBoundary]];
referenceRecoilTail=referenceRecoilBoundary<>Last[StringSplit[referenceRecoilText,referenceRecoilBoundary]];
If[!SyntaxQ[referenceRecoilPrefix] || !SyntaxQ[referenceRecoilTail],Quit[1]];
ToExpression[referenceRecoilPrefix,InputForm];
referenceRecoilReference=Import[referencePath,"Text"];
referenceRecoilStart="\nsoftRows[coefficient_,piece_,sign_]";
referenceRecoilEnd="\nassemble[channel_,key_,component_,channelHash_]";
gate["unique pinned native reference endpoint definition",StringCount[referenceRecoilReference,referenceRecoilStart]===1 &&
  StringCount[referenceRecoilReference,referenceRecoilEnd]===1];
referenceRecoilDefinition=referenceRecoilStart<>First[StringSplit[
  Last[StringSplit[referenceRecoilReference,referenceRecoilStart]],referenceRecoilEnd]];
referenceRecoilConverted=StringReplace[referenceRecoilDefinition,{
  RegularExpression["\\bsoftRows\\b"]->"referenceNativeSoftRows",RegularExpression["\\bw\\b"]->"s23"}];
gate["exact reversible native endpoint conversion",SyntaxQ[referenceRecoilConverted] &&
  StringReplace[referenceRecoilConverted,{RegularExpression["\\breferenceNativeSoftRows\\b"]->"softRows",
  RegularExpression["\\bs23\\b"]->"w"}]===referenceRecoilDefinition];
ToExpression[referenceRecoilConverted,InputForm];
referenceRecoilOriginalDefinitions=DownValues[softRows];
DownValues[referencePriorSoftRows]=referenceRecoilOriginalDefinitions/.HoldPattern[softRows]->referencePriorSoftRows;
gate["exact original nonpolynomial endpoint fallback",
  (DownValues[referencePriorSoftRows]/.HoldPattern[referencePriorSoftRows]->softRows)===referenceRecoilOriginalDefinitions];
referenceRecoilLastKey=None;referenceRecoilLastRational=0;
referenceRecoilNativeCount=0;referenceRecoilFallbackCount=0;
referenceRecoilRational[coefficient_,sign_] := Module[{key=Hash[{coefficient,sign},"SHA256"]},
  If[key=!=referenceRecoilLastKey,
    referenceRecoilLastRational=bounded[Cancel[coefficient/.t->sign omega-s],"native reference recoil input"];
    referenceRecoilLastKey=key];referenceRecoilLastRational];
referenceRecoilNativeCall="  rational=Cancel[coefficient/.t->sign omega-s];";
referenceRecoilCachedCall="  rational=referenceRecoilRational[coefficient,sign];";
gate["single native recoil input reuse boundary",StringCount[referenceRecoilConverted,referenceRecoilNativeCall]===1];
referenceRecoilCached=StringReplace[referenceRecoilConverted,referenceRecoilNativeCall->referenceRecoilCachedCall];
gate["all reference endpoint equations retained",SyntaxQ[referenceRecoilCached] &&
  StringReplace[referenceRecoilCached,referenceRecoilCachedCall->referenceRecoilNativeCall]===referenceRecoilConverted];
ToExpression[referenceRecoilCached,InputForm];
Clear[softRows];
softRows[coefficient_,piece_,sign_] := Module[{rational,eligible,answer,seconds},
  rational=referenceRecoilRational[coefficient,sign];
  eligible=rational=!=0 && PolynomialQ[Numerator[rational],s23] && PolynomialQ[Denominator[rational],s23];
  {seconds,answer}=AbsoluteTiming[If[eligible,referenceRecoilNativeCount++;gate["native reference polynomial support accepted",True];referenceNativeSoftRows[coefficient,piece,sign],
    referenceRecoilFallbackCount++;referencePriorSoftRows[coefficient,piece,sign]]];
  Print["REFERENCE_RECOIL_ROW branch ",sign," polynomial ",eligible," input_bytes ",ByteCount[coefficient],
    " seconds ",seconds];answer];
referenceRecoilWorkerBoundary="recoilData,rationalSeries,";
referenceRecoilWorkerReplacement="referenceRecoilRational,referenceRecoilLastKey,referenceRecoilLastRational,referenceRecoilNativeCount,referenceRecoilFallbackCount,referenceNativeSoftRows,referencePriorSoftRows,recoilData,rationalSeries,";
referenceRecoilOutputBoundary="\\\"FactoredInputComparisonHash\\\"->FileHash[factoredProofPath,\\\"SHA256\\\"]";
referenceRecoilOutputReplacement=referenceRecoilOutputBoundary<>",\\\"ReferenceRecoilComparisonHash\\\"->FileHash[referenceRecoilProofPath,\\\"SHA256\\\"],\\\"ReferenceRecoilSourceHash\\\"->FileHash[referenceRecoilPath,\\\"SHA256\\\"]";
referenceRecoilChanges={referenceRecoilWorkerBoundary->referenceRecoilWorkerReplacement,
  referenceRecoilOutputBoundary->referenceRecoilOutputReplacement};
gate["unique remaining reference-recoil interfaces",And@@(StringCount[referenceRecoilTail,First[#]]===1&/@referenceRecoilChanges)];
referenceRecoilRun=StringReplace[referenceRecoilTail,referenceRecoilChanges];
gate["all remaining integration equations retained",SyntaxQ[referenceRecoilRun] &&
  StringReplace[referenceRecoilRun,Reverse/@referenceRecoilChanges]===referenceRecoilTail];
referenceRecoilDirectory=FileNameJoin[{root,channel,"s12_reference_recoil_result"}];
If[!DirectoryQ[referenceRecoilDirectory],CreateDirectory[referenceRecoilDirectory,CreateIntermediateDirectories->True]];
referenceRecoilProofPath=FileNameJoin[{referenceRecoilDirectory,"s12_result.wl"}];
referenceRecoilBinding=Hash[{FileHash[referenceRecoilPath,"SHA256"],inputHash,
  FileHash[referencePath,"SHA256"],factoredControlBinding,$Version,$FeynCalcVersion},"SHA256"];
referenceRecoilProof=If[FileExistsQ[referenceRecoilProofPath],Get[referenceRecoilProofPath],<||>];
If[Lookup[referenceRecoilProof,"Binding",None]=!=referenceRecoilBinding || !TrueQ[Lookup[referenceRecoilProof,"Accepted",False]],
  referenceRecoilControlCache=FileNameJoin[{root,"cache","s12_reference_recoil",channel,IntegerString[referenceRecoilBinding,16]}];
  If[!DirectoryQ[referenceRecoilControlCache],CreateDirectory[referenceRecoilControlCache,CreateIntermediateDirectories->True]];
  {referenceRecoilSeconds,referenceRecoilControl}=AbsoluteTiming[Block[{cache=referenceRecoilControlCache},
    assemble[factoredTask,factoredControlIndex]]];
  gate["own complete reference-recoil component accepted",AssociationQ[referenceRecoilControl] &&
    TrueQ[referenceRecoilControl["Accepted"]] && referenceRecoilControl["InputHash"]===inputHash &&
    And@@Values[referenceRecoilControl["Checks"]]];
  gate["own comparison exercises native rational endpoint code",TrueQ[Lookup[referenceRecoilControl["Checks"],
    "native reference polynomial support accepted",False]]];
  gate["own reference-recoil ordinary unchanged",bounded[zeroCoefficient[
    referenceRecoilControl["Ordinary"]-factoredControl["Ordinary"]],"reference recoil ordinary comparison"]];
  Do[
    gate["own reference-recoil branch assumptions unchanged",referenceRecoilControl["Branches"][sign]["Assumptions"]===
      factoredControl["Branches"][sign]["Assumptions"]];
    Do[gate["own reference-recoil distribution "<>ToString[{sign,key}],bounded[zeroCoefficient[
      referenceRecoilControl["Branches"][sign][key]-factoredControl["Branches"][sign][key]],"reference recoil distribution comparison"]],
      {key,{"Delta","L0","L1","Regular"}}];
    referenceRecoilRows=referenceRecoilControl["Branches"][sign]["SoftCoefficients"];
    referenceRecoilOldRows=factoredControl["Branches"][sign]["SoftCoefficients"];
    gate["own reference-recoil soft support unchanged",Length[referenceRecoilRows]===Length[referenceRecoilOldRows] &&
      (Take[#,2]&/@referenceRecoilRows)===(Take[#,2]&/@referenceRecoilOldRows)];
    gate["own reference-recoil soft values unchanged",And@@MapThread[bounded[zeroCoefficient[Last[#1]-Last[#2]],
      "reference recoil soft comparison"]&,{referenceRecoilRows,referenceRecoilOldRows}]],{sign,{1,-1}}];
  referenceRecoilProof=<|"Schema"->"polarized-sidis-reference-recoil-comparison-v1","Channel"->channel,
    "Binding"->referenceRecoilBinding,"InputHash"->inputHash,"InputHashes"->inputHashes,
    "SourceHash"->FileHash[referenceRecoilPath,"SHA256"],"ReferenceHash"->FileHash[referencePath,"SHA256"],
    "ControlIndex"->factoredControlIndex,"ControlHash"->Hash[factoredTask,"SHA256"],
    "OriginalControl"->factoredControl,"CompleteControl"->referenceRecoilControl,"ControlSeconds"->referenceRecoilSeconds,
    "NativeRows"->referenceRecoilNativeCount,"FallbackRows"->referenceRecoilFallbackCount,
    "OriginalDefinitions"->referenceRecoilOriginalDefinitions,"NativeDefinition"->referenceRecoilDefinition,
    "NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True,"FiniteNLOFHatsComputed"->False|>;
  referenceRecoilSerialized="Uncompress["<>ToString[Compress[referenceRecoilProof],InputForm]<>"]\n";
  gate["bounded reference-recoil comparison",StringLength[referenceRecoilSerialized]<128*1024^2];
  Export[referenceRecoilProofPath<>".tmp",referenceRecoilSerialized,"Text"];
  gate["exact reference-recoil comparison reload",Get[referenceRecoilProofPath<>".tmp"]===referenceRecoilProof];
  RenameFile[referenceRecoilProofPath<>".tmp",referenceRecoilProofPath,OverwriteTarget->True]];
gate["own complete reference-recoil comparison accepted",referenceRecoilProof["Binding"]===referenceRecoilBinding &&
  TrueQ[referenceRecoilProof["Accepted"]] && And@@Values[referenceRecoilProof["Checks"]]];
Export[FileNameJoin[{referenceRecoilDirectory,"s12_checks.json"}],<|"checks"->checks,
  "channel"->channel,"control_index"->referenceRecoilProof["ControlIndex"],
  "control_seconds"->referenceRecoilProof["ControlSeconds"],"finite_nlo_fhats_computed"->False|>,"RawJSON"];
If[Environment["POLARIZED_SIDIS_RECOIL_COMPARISON_ONLY"]==="1",Print["PASS: s12_reference_recoil_comparison"];Quit[0]];
ToExpression[referenceRecoilRun,InputForm];

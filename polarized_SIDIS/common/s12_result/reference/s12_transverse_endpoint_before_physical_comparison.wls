(* Separate the measured transverse root before the pinned polynomial endpoint. *)
$HistoryLength=0;
transverseEndpointPath=FileNameJoin[{Directory[],"common","s12_assemble_real_transverse_endpoint.wls"}];
transverseEndpointBase=FileNameJoin[{Directory[],"common","s12_assemble_real_reference_recoil.wls"}];
If[IntegerString[FileHash[transverseEndpointBase,"SHA256"],16,64]=!="9fb68f329aac43cf66ebfbf23f9b9fb4f590bd255dc78743840eb0093850ac42",Quit[1]];
transverseEndpointText=Import[transverseEndpointBase,"Text"];
transverseEndpointBoundary="\nToExpression[referenceRecoilRun,InputForm];";
If[StringCount[transverseEndpointText,transverseEndpointBoundary]=!=1 || !SyntaxQ[Import[transverseEndpointPath,"Text"]],Quit[1]];
ToExpression[First[StringSplit[transverseEndpointText,transverseEndpointBoundary]],InputForm];
gate["single inherited transverse-coordinate rule",MatchQ[transverseRule,_Rule] && MatchQ[Last[transverseRule],_Power]];
transverseEndpointSymbol=First[transverseRule];transverseEndpointRoot=Last[transverseRule];
transverseEndpointOriginal=DownValues[softRows];
DownValues[transverseEndpointPriorRows]=transverseEndpointOriginal/.HoldPattern[softRows]->transverseEndpointPriorRows;
gate["unchanged unsupported endpoint fallback",(DownValues[transverseEndpointPriorRows]/.HoldPattern[transverseEndpointPriorRows]->softRows)===transverseEndpointOriginal];
transverseRootData[sign_] := transverseRootData[sign] = Module[{rootValue,endpoint,valuation},
  rootValue=transverseEndpointRoot/.t->sign omega-s;
  endpoint=bounded[FullSimplify[Limit[rootValue,s23->0,Direction->"FromAbove",
    Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"transverse root endpoint"];
  valuation=bounded[FullSimplify[Limit[s23 D[rootValue,s23]/rootValue,s23->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"transverse root valuation"];
  gate["transverse root is finite positive and nonvanishing at endpoint",
    FreeQ[endpoint,s23|Indeterminate|ComplexInfinity|_DirectedInfinity|_Limit] &&
    bounded[FullSimplify[endpoint>0,branchAssumptions[sign]],"positive transverse root endpoint"]];
  gate["transverse root has zero recoil valuation",valuation===0];
  Print["TRANSVERSE_ROOT_ENDPOINT ",sign," ",InputForm[endpoint]," valuation ",valuation];
  <|"Root"->rootValue,"Endpoint"->endpoint,"Valuation"->valuation|>];
transverseCandidateInput[coefficient_,sign_] := Module[
  {powers,inverse,numerator,denominator,ndegree,ddegree,power,rational,data,endpointFactor,candidate,branch},
  powers=DeleteDuplicates[Cases[coefficient,Power[b_,e_]/;!IntegerQ[e]:>Power[b,e],Infinity]];
  If[powers=!={transverseEndpointRoot},Return[Missing["UnsupportedRoot"]]];
  inverse=coefficient/.transverseEndpointRoot->transverseEndpointSymbol;
  gate["exact reversible transverse-coordinate extraction",(inverse/.transverseRule)===coefficient];
  numerator=Numerator[inverse];denominator=Denominator[inverse];
  If[!PolynomialQ[numerator,transverseEndpointSymbol] || !PolynomialQ[denominator,transverseEndpointSymbol],
    Return[Missing["NonpolynomialTransverseCoordinate"]]];
  ndegree=Exponent[numerator,transverseEndpointSymbol];ddegree=Exponent[denominator,transverseEndpointSymbol];
  If[ndegree=!=Exponent[numerator,transverseEndpointSymbol,Min] ||
     ddegree=!=Exponent[denominator,transverseEndpointSymbol,Min],Return[Missing["NonhomogeneousTransverseCoordinate"]]];
  power=ndegree-ddegree;
  gate["transverse factor degree derived from actual coefficient",IntegerQ[power]];
  rational=bounded[Cancel[inverse/transverseEndpointSymbol^power],"extract transverse factor"];
  gate["transverse factor removes the only nonpolynomial support",FreeQ[rational,transverseEndpointSymbol] &&
    FreeQ[rational,Power[_,e_]/;!IntegerQ[e]]];
  gate["exact transverse factor reconstruction",bounded[
    zeroCoefficient[inverse-transverseEndpointSymbol^power rational],"transverse factor reconstruction"]];
  data=transverseRootData[sign];
  endpointFactor=bounded[FullSimplify[Limit[data["Root"]^power,s23->0,Direction->"FromAbove",
    Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],"transverse factor endpoint"];
  gate["transverse factor power endpoint exact",bounded[FullSimplify[
    endpointFactor==data["Endpoint"]^power,branchAssumptions[sign]],"transverse power endpoint comparison"]];
  candidate=rational endpointFactor;
  gate["transverse factor endpoint independent of recoil",FreeQ[endpointFactor,s23|_Limit|Indeterminate|ComplexInfinity]];
  branch=referenceRecoilRational[candidate,sign];
  gate["extracted coefficient has native polynomial recoil support",
    PolynomialQ[Numerator[branch],s23] && PolynomialQ[Denominator[branch],s23]];
  candidate];
transverseEndpointLastKey=None;transverseEndpointLastInput=Missing["Empty"];
Clear[softRows];
softRows[coefficient_,piece_,sign_] := Module[{key,candidate,answer,seconds,preparationSeconds},
  key=Hash[{coefficient,sign},"SHA256"];
  {preparationSeconds,candidate}=AbsoluteTiming[If[key=!=transverseEndpointLastKey,
    transverseEndpointLastInput=transverseCandidateInput[coefficient,sign];transverseEndpointLastKey=key];transverseEndpointLastInput];
  candidate=transverseEndpointLastInput;
  If[MissingQ[candidate],Return[transverseEndpointPriorRows[coefficient,piece,sign]]];
  gate["transverse endpoint uses pinned polynomial code",True];
  {seconds,answer}=AbsoluteTiming[referenceNativeSoftRows[candidate,piece,sign]];
  Print["TRANSVERSE_REFERENCE_RECOIL_ROW branch ",sign," input_bytes ",ByteCount[coefficient],
    " preparation_seconds ",preparationSeconds," endpoint_seconds ",seconds];
  answer];
transverseEndpointWorkerNeedle="recoilData,rationalSeries,";
transverseEndpointWorkerText="transverseCandidateInput,transverseRootData,transverseEndpointPriorRows,transverseEndpointSymbol,transverseEndpointRoot,transverseEndpointLastKey,transverseEndpointLastInput,"<>transverseEndpointWorkerNeedle;
gate["single inherited transverse worker interface",StringCount[referenceRecoilRun,transverseEndpointWorkerNeedle]===1];
transverseEndpointRun=StringReplace[referenceRecoilRun,transverseEndpointWorkerNeedle->transverseEndpointWorkerText];
gate["unchanged full integration equations for transverse workers",SyntaxQ[transverseEndpointRun] &&
  StringReplace[transverseEndpointRun,transverseEndpointWorkerText->transverseEndpointWorkerNeedle]===referenceRecoilRun];
transverseOutputNeedle="put[result,FileNameJoin[{resultDir,\"s12_result.wl\"}]];";
transverseOutputText="AssociateTo[result,{\"TransverseEndpointSourceHash\"->FileHash[transverseEndpointPath,\"SHA256\"],\"TransverseEndpointComparisonHash\"->FileHash[transverseEndpointProofPath,\"SHA256\"]}];\n"<>transverseOutputNeedle;
gate["single inherited transverse provenance export",StringCount[referenceSeriesTail,transverseOutputNeedle]===1];
transverseOutputTail=StringReplace[referenceSeriesTail,transverseOutputNeedle->transverseOutputText];
gate["unchanged integration with extra transverse provenance",SyntaxQ[transverseOutputTail] &&
  StringReplace[transverseOutputTail,transverseOutputText->transverseOutputNeedle]===referenceSeriesTail];
transverseControlIndices=Select[Range[Length[mapped["Components"]]],
  FileExistsQ[FileNameJoin[{cache,"component_"<>IntegerString[#,10,4]<>".wl"}]] &&
  AnyTrue[Values[mapped["Components"][[#]]["ReducedCoefficients"]],
    !FreeQ[#/.transverseRule,transverseEndpointRoot]&]&];
gate["own accepted component with actual transverse root available",transverseControlIndices=!={}];
transverseControlIndex=First[MinimalBy[transverseControlIndices,ByteCount[mapped["Components"][[#]]["ReducedCoefficients"]]&]];
transverseControlTask=mapped["Components"][[transverseControlIndex]];
transverseControlOld=Get[FileNameJoin[{cache,"component_"<>IntegerString[transverseControlIndex,10,4]<>".wl"}]];
gate["own accepted transverse control provenance",AssociationQ[transverseControlOld] &&
  TrueQ[transverseControlOld["Accepted"]] && transverseControlOld["InputHash"]===inputHash &&
  And@@Values[transverseControlOld["Checks"]] &&
  KeyTake[transverseControlOld,{"Sector","Kind","Index"}]===KeyTake[transverseControlTask,{"Sector","Kind","Index"}]];
transverseEndpointDirectory=FileNameJoin[{root,channel,"s12_transverse_endpoint_result"}];
If[!DirectoryQ[transverseEndpointDirectory],CreateDirectory[transverseEndpointDirectory,CreateIntermediateDirectories->True]];
transverseEndpointProofPath=FileNameJoin[{transverseEndpointDirectory,"s12_result.wl"}];
transverseEndpointBinding=Hash[{FileHash[transverseEndpointPath,"SHA256"],inputHash,transverseControlIndex,
  Hash[transverseControlTask,"SHA256"],Hash[transverseControlOld,"SHA256"],$Version,$FeynCalcVersion},"SHA256"];
transverseEndpointProof=If[FileExistsQ[transverseEndpointProofPath],Get[transverseEndpointProofPath],<||>];
If[Lookup[transverseEndpointProof,"Binding",None]=!=transverseEndpointBinding || !TrueQ[Lookup[transverseEndpointProof,"Accepted",False]],
  transverseControlCache=FileNameJoin[{root,"cache","s12_transverse_endpoint",channel,IntegerString[transverseEndpointBinding,16]}];
  If[!DirectoryQ[transverseControlCache],CreateDirectory[transverseControlCache,CreateIntermediateDirectories->True]];
  {transverseControlSeconds,transverseControlNew}=AbsoluteTiming[Block[{cache=transverseControlCache},
    assemble[transverseControlTask,transverseControlIndex]]];
  gate["own transverse endpoint control fully accepted",TrueQ[transverseControlNew["Accepted"]] &&
    transverseControlNew["InputHash"]===inputHash && And@@Values[transverseControlNew["Checks"]] &&
    TrueQ[transverseControlNew["Checks"]["transverse endpoint uses pinned polynomial code"]]];
  gate["own transverse ordinary coefficient unchanged",bounded[zeroCoefficient[
    transverseControlNew["Ordinary"]-transverseControlOld["Ordinary"]],"transverse ordinary control"]];
  Do[
    gate["own transverse branch assumptions unchanged",transverseControlNew["Branches"][sign]["Assumptions"]===
      transverseControlOld["Branches"][sign]["Assumptions"]];
    Do[gate["own transverse full distribution "<>ToString[{sign,key}],bounded[zeroCoefficient[
      transverseControlNew["Branches"][sign][key]-transverseControlOld["Branches"][sign][key]],"transverse distribution control"]],
      {key,{"Delta","L0","L1","Regular"}}];
    transverseRows=transverseControlNew["Branches"][sign]["SoftCoefficients"];
    transverseOldRows=transverseControlOld["Branches"][sign]["SoftCoefficients"];
    gate["own transverse soft support unchanged",(Take[#,2]&/@transverseRows)===(Take[#,2]&/@transverseOldRows)];
    gate["own transverse soft coefficients unchanged",And@@MapThread[bounded[zeroCoefficient[Last[#1]-Last[#2]],
      "transverse soft control"]&,{transverseRows,transverseOldRows}]],{sign,{1,-1}}];
  transverseEndpointProof=<|"Schema"->"polarized-sidis-transverse-endpoint-comparison-v1","Channel"->channel,
    "SourceHash"->FileHash[transverseEndpointPath,"SHA256"],"InputHash"->inputHash,"InputHashes"->inputHashes,
    "Binding"->transverseEndpointBinding,"ControlIndex"->transverseControlIndex,"ControlTaskHash"->Hash[transverseControlTask,"SHA256"],
    "OriginalControl"->transverseControlOld,"CompleteControl"->transverseControlNew,"ControlSeconds"->transverseControlSeconds,
    "OriginalDefinitions"->transverseEndpointOriginal,"NativeVersions"->{$Version,$FeynCalcVersion},"Checks"->checks,"Accepted"->True|>;
  transverseSerialized="Uncompress["<>ToString[Compress[transverseEndpointProof],InputForm]<>"]\n";
  gate["bounded complete transverse comparison",StringLength[transverseSerialized]<128*1024^2];
  Export[transverseEndpointProofPath<>".tmp",transverseSerialized,"Text"];
  gate["exact transverse comparison reload",Get[transverseEndpointProofPath<>".tmp"]===transverseEndpointProof];
  RenameFile[transverseEndpointProofPath<>".tmp",transverseEndpointProofPath,OverwriteTarget->True]];
gate["own complete transverse endpoint comparison accepted",transverseEndpointProof["Binding"]===transverseEndpointBinding &&
  TrueQ[transverseEndpointProof["Accepted"]] && And@@Values[transverseEndpointProof["Checks"]]];
Export[FileNameJoin[{transverseEndpointDirectory,"s12_checks.json"}],<|"checks"->checks,"channel"->channel,
  "control_index"->transverseEndpointProof["ControlIndex"],"control_seconds"->transverseEndpointProof["ControlSeconds"],
  "finite_nlo_fhats_computed"->False|>,"RawJSON"];
If[Environment["POLARIZED_SIDIS_TRANSVERSE_COMPARISON_ONLY"]==="1",Print["PASS: s12_transverse_endpoint_comparison"];Quit[0]];
referenceSeriesTail=transverseOutputTail;
ToExpression[transverseEndpointRun,InputForm];

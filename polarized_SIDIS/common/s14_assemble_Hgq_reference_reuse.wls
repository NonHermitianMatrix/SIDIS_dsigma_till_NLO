(* Reuse executed reference reductions after exact reconstruction of the new hats. *)
$HistoryLength=0;
certificateSource=FileNameJoin[{Directory[],"common","s14_assemble_Hgq_reference_reuse.wls"}];
certificateBase=FileNameJoin[{Directory[],"common","s14_assemble_Hgq_finite_update.wls"}];
If[IntegerString[FileHash[certificateBase,"SHA256"],16,64]=!=
  "1a1a93a147c5a6988f1eed039554949ab03b7cf2423b97408878ef24700d0dca",Quit[1]];
certificateText=Import[certificateBase,"Text"];
certificateEntry="ToExpression[phaseRunTail,InputForm];";
If[!StringEndsQ[StringTrim[certificateText],certificateEntry]||
  !SyntaxQ[Import[certificateSource,"Text"]],Quit[1]];
certificatePrefix=StringTake[certificateText,
  First[Last[StringPosition[certificateText,certificateEntry]]]-1];
If[!SyntaxQ[certificatePrefix],Quit[1]];ToExpression[certificatePrefix,InputForm];

certificateRead[relative_] := Module[{path=FileNameJoin[{root,relative}]},
  gate["accepted comparison input "<>relative,
    KeyExistsQ[updateComparison["InputHashes"],relative]&&
    FileHash[path,"SHA256"]===updateComparison["InputHashes"][relative]];
  AppendTo[inputPaths,path];Get[path]];
certificateResidual=certificateRead[channel<>"/s11_resolved_gluon_result/s11_result.wl"];
certificateInspection=certificateRead[channel<>"/s14_reference_residual_result/s14_result.wl"];
certificateTerms=certificateRead[channel<>"/s14_reference_terms_result/s14_result.wl"];
certificateOld=Get[FileNameJoin[{root,channel,"s11_result","s11_result.wl"}]];
certificateMS=Get[updateSubtractionPath];
certificateResidualSource=FileNameJoin[{root,"common","s11_check_Hgq_resolved_gluon.wls"}];
gate["same executed reference reducer",certificateResidual["SourceHash"]===
  FileHash[certificateResidualSource,"SHA256"]&&
  FileHash[certificateResidualSource,"SHA256"]===
    updateComparison["InputHashes"]["common/s11_check_Hgq_resolved_gluon.wls"]&&
  StringCount[Import[certificateResidualSource,"Text"],
    "candidate=normalization photonWeights[[First[FirstPosition[Keys[referenceHats],name]]]].(values+change);"]===1];
gate["same complete reference calculation",channel==="Hgq"&&core&&flavorDomain===True&&
  certificateResidual["Channel"]===channel&&
  certificateResidual["NativeVersions"]==={$Version,$FeynCalcVersion}&&
  certificateResidual["OriginalAssemblyInputHash"]===updateOldInputHash&&
  certificateInspection["InputHash"]===updateOldInputHash&&
  And@@Values[certificateResidual["Checks"]]&&
  certificateResidual["CheckpointHashes"]===updateComparison["CheckpointHashes"]&&
  certificateInspection["PhotonWeights"]===hatPhotonWeights&&
  Factor[certificateTerms["Normalization"]-updateNormalization]===0];
Do[gate["unchanged reference equation input "<>relative,
  FileHash[FileNameJoin[{root,relative}],"SHA256"]===updateComparison["InputHashes"][relative]],
  {relative,Keys[updateComparison["InputHashes"]]}];
certificateZeroArray[value_] := And@@(Together[#]===0&/@Flatten[{value}]);
certificatePreviousChange=Association@Table[distribution->Map[Factor,
  certificateResidual["Counterterms"][distribution]-certificateOld["Counterterms"][distribution],{3}],
  {distribution,Keys[certificateOld["Counterterms"]]}];
certificateExtra=Association@Table[distribution->Map[Factor,
  certificateMS["Counterterms"][distribution]-certificateResidual["Counterterms"][distribution],{3}],
  {distribution,Keys[certificateMS["Counterterms"]]}];
gate["same actual finite scheme change",certificateZeroArray[
  Values[certificateExtra]-Values[updateComparison["ExtraCounterterms"]]]&&
  certificateZeroArray[Values[updateDifference]-Values[certificateExtra]-Values[certificatePreviousChange]]];
certificateRows=<||>;certificateControl=False;
certificateCompare[value_,conditions_] := Module[
  {key={name,sign,distribution},weights,oldValues,oldChange,newChange,extraChange,
   reconstructed,variables,before,after,projectedChange,row,accepted,residual,seconds},
  weights=hatPhotonWeights[[First[FirstPosition[Keys[referenceHats],name]]]];
  gate["same current reference domain",conditions===
    ((If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&
      If[sign===0,True,omega>0]&&flavorDomain)];
  row=SelectFirst[certificateResidual["Comparisons"],
    Lookup[#,{"Hat","Branch","Distribution"}]===key&];
  accepted=SelectFirst[updateComparison["Comparisons"],
    Lookup[#,{"Hat","Branch","Distribution"}]===key&];
  gate["exact accepted reference row",AssociationQ[row]&&AssociationQ[accepted]&&
    TrueQ[accepted["Equal"]]&&accepted["Residual"]===0];
  oldValues=Table[Module[{label={{a,uPosition,uPosition},sign,distribution},path,saved,relative},
    path=FileNameJoin[{updateOldCache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
    relative=StringDrop[path,StringLength[root]+1];
    gate["same coefficient used by executed reference reduction",
      FileHash[path,"SHA256"]===certificateResidual["CheckpointHashes"][relative]&&
      updateCheckpointHashes[relative]===certificateResidual["CheckpointHashes"][relative]];
    saved=Get[path];
    gate["same accepted finite coefficient",TrueQ[saved["Accepted"]]&&
      saved["InputHash"]===updateOldInputHash&&saved["Label"]===label];saved["Finite"]],
    {a,Length[weights]}];
  oldChange=If[KeyExistsQ[certificatePreviousChange,distribution],
    certificatePreviousChange[distribution][[All,uPosition,uPosition]],ConstantArray[0,Length[weights]]]/.t->sign omega-s;
  newChange=If[KeyExistsQ[updateDifference,distribution],
    updateDifference[distribution][[All,uPosition,uPosition]],ConstantArray[0,Length[weights]]]/.t->sign omega-s;
  extraChange=If[KeyExistsQ[certificateExtra,distribution],
    certificateExtra[distribution][[All,uPosition,uPosition]],ConstantArray[0,Length[weights]]]/.t->sign omega-s;
  reconstructed=Sum[weights[[a]]updateNormalization(oldValues[[a]]+newChange[[a]]),{a,Length[weights]}];
  gate["actual assembled coefficient reconstructed exactly",
    reconstructed===hats[name]["NLO"][sign][distribution][[uPosition,uPosition]]&&
    value===reconstructed-referenceHats[name]["NLO"][sign][distribution]];
  variables=Table[Unique["finiteCoefficient"],{Length[weights]}];
  before=certificateTerms["Normalization"]weights.(variables+oldChange);
  after=Sum[weights[[a]]updateNormalization(variables[[a]]+newChange[[a]]),{a,Length[weights]}];
  projectedChange=certificateTerms["Normalization"]weights.extraChange;
  gate["native projection update identity",Together[Expand[after-before-projectedChange]]===0];
  {seconds,residual}=AbsoluteTiming[Factor[Together[row["Residual"]+projectedChange]]];
  gate["executed residual plus actual update matches",residual===accepted["Residual"]];
  AssociateTo[certificateRows,ToString[key,InputForm]-><|"Hat"->name,"Branch"->sign,
    "Distribution"->distribution,"ActualResidualHash"->Hash[value,"SHA256"],
    "ExactCoefficientReconstruction"->True,"NativeProjectionIdentity"->True,
    "Residual"->residual,"ReductionSeconds"->seconds|>];True];
certificateZero[value_,conditions_] := Module[{direct,reused,seconds},
  If[name===First[Keys[referenceHats]]&&sign===1&&distribution==="Delta",
    {seconds,direct}=AbsoluteTiming[poleReferenceZero[value,conditions]];
    reused=certificateCompare[value,conditions];
    gate["own complete accepted reference output comparison",TrueQ[direct]&&direct===reused];
    certificateControl=<|"Label"->{name,sign,distribution},"DirectSeconds"->seconds,
      "ExactOwnOutputComparison"->True|>;Return[direct]];
  If[distribution==="Regular",
    gate["own direct reference comparison passed",AssociationQ[certificateControl]];
    Return[certificateCompare[value,conditions]]];
  poleReferenceZero[value,conditions]];
certificateTail=phaseRunTail;
gate["same complete final reference interface",StringCount[certificateTail,"bounded[poleReferenceZero["]===2];
phaseRunTail=StringReplace[certificateTail,"bounded[poleReferenceZero["->"bounded[certificateZero["];
gate["complete original assembly preserved",StringReplace[phaseRunTail,
  "bounded[certificateZero["->"bounded[poleReferenceZero["]===certificateTail];
inputPaths=DeleteDuplicates[Join[inputPaths,{certificateSource,certificateBase,certificateResidualSource},
  FileNameJoin[{root,#}]&/@Keys[updateComparison["InputHashes"]]]];
inputHashes=Association[(StringDrop[#,StringLength[root]+1]->FileHash[#,"SHA256"])&/@inputPaths];
inputHash=Hash[{sourceHash,inputHashes,$Version,$FeynCalcVersion},"SHA256"];
certificateExport="poleFinalPut[result,FileNameJoin[{resultDir,\"s14_result.wl\"}]];";
gate["unique final certified export",StringCount[phaseRunTail,certificateExport]===1];
certificateExportCode=
  "gate[\"all regular reference rows certified\",AssociationQ[certificateControl]&&Sort[Lookup[#,{\"Hat\",\"Branch\",\"Distribution\"}]&/@Select[Values[certificateRows],#[\"Distribution\"]===\"Regular\"&]]===Sort[Lookup[#,{\"Hat\",\"Branch\",\"Distribution\"}]&/@Select[updateComparison[\"Comparisons\"],#[\"Distribution\"]===\"Regular\"&]]];"<>
  "AssociateTo[result,{\"DispatchSourceHash\"->FileHash[certificateSource,\"SHA256\"],\"FiniteUpdateDispatchHash\"->FileHash[certificateBase,\"SHA256\"],\"ReferenceReuseCertificate\"-><|\"OwnControl\"->certificateControl,\"Rows\"->certificateRows,\"AcceptedComparisonHash\"->FileHash[updateComparisonPath,\"SHA256\"]|>}];"<>certificateExport;
phaseRunTail=StringReplace[phaseRunTail,certificateExport->certificateExportCode];
gate["complete certified assembly syntax",SyntaxQ[phaseRunTail]];
ToExpression[phaseRunTail,InputForm];

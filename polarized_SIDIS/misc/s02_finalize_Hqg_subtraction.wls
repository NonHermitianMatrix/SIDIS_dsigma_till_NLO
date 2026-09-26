(* Original S11 convolution with the native intermediate-gluon transfer. *)
$HistoryLength = 0; root = Directory[];
$FeynCalcStartupMessages=False;Get["FeynCalc`"];
studySource = FileNameJoin[{root, "misc", "s02_finalize_Hqg_subtraction.wls"}];
localConfig=Import[FileNameJoin[{root,"misc","s02_inputs.json"}],"RawJSON"];
If[IntegerString[FileHash[studySource,"SHA256"],16,64]=!=localConfig["source_sha256"],Quit[1]];
KeyValueMap[If[IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]=!=#2,Quit[1]]&,localConfig["input_sha256"]];
baselineSource = FileNameJoin[{root, "common", "s11_collinear_spin_convolutions.wls"}];
If[IntegerString[FileHash[baselineSource, "SHA256"], 16, 64] =!=
  "4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6", Quit[1]];
baselineText = Import[baselineSource, "Text"];
boundary = StringPosition[baselineText, "completionPath = FileNameJoin["];
If[Length[boundary] =!= 1 || !SyntaxQ[ReadString[studySource]], Quit[1]];
prefix = StringTake[baselineText, First[First[boundary]] - 1];
platformReplacements={
 "gate[\"compute allocation\", StringQ[Environment[\"JOB_ID\"]] && !StringStartsQ[$MachineName, \"login\"]];" ->
 "gate[\"authorized bounded local execution\", Environment[\"POLARIZED_SIDIS_LOCAL_BOUNDED\"] === \"1\"];",
 "gate[\"isolated runtime\", StringStartsQ[$UserBaseDirectory, root <> \"/\"]];" ->
 "gate[\"isolated local result owner\", DirectoryQ[FileNameJoin[{root,\"misc\",\"s02_result\"}]]];",
 "PrependTo[$Path, \"/u/home/r/rushil/.Mathematica/Applications\"];" -> "Null;",
 "$FeynCalcStartupMessages = False; $LoadAddOns = {\"FeynArts\"}; Get[\"FeynCalc`\"];" ->
 "\"FeynCalc loaded before parsing the reused prefix; saved amplitudes require no FeynArts\";"};
If[!And@@(StringCount[prefix,First[#]]===1&/@platformReplacements),Quit[1]];
originalPrefix=prefix;prefix=StringReplace[prefix,platformReplacements];
If[StringReplace[prefix,Reverse/@platformReplacements]=!=originalPrefix||!SyntaxQ[prefix],Quit[1]];
ToExpression[prefix,InputForm];
localProofPath=FileNameJoin[{root,"misc","s01_result","s01_result.wl"}];
localProof=Get[localProofPath];
localReceiptPath=FileNameJoin[{root,"misc","s01_result","s01_execution.json"}];
localReceipt=Import[localReceiptPath,"RawJSON"];
gate["accepted local exact residual comparison",TrueQ[localReceipt["passed"]]&&
 localReceipt["result_sha256"]["s01_result.wl"]===IntegerString[FileHash[localProofPath,"SHA256"],16,64]&&
 TrueQ[localProof["AllResidualsExplained"]]&&And@@Values[localProof["Checks"]]&&
 localProof["LocalNativeVersions"]==={$Version,$FeynCalcVersion}&&
 localProof["SourceSHA256"]===IntegerString[FileHash[FileNameJoin[{root,"misc","s01_check_Hqg_residual.wls"}],"SHA256"],16,64]];
gate["own gluon subtraction channel", channel === "Hqg"];
inputPaths = {baselineSource, FileNameJoin[{root,"common","s11_finalize_Hqg_subtraction.wls"}],
 localProofPath,localReceiptPath,FileNameJoin[{root,"misc","s01_check_Hqg_residual.wls"}],
 FileNameJoin[{root,"misc","s02_inputs.json"}]};
read[relative_] := Module[{path = FileNameJoin[{root, relative}]},
  AppendTo[inputPaths, path]; If[StringEndsQ[path, ".json"], Import[path, "RawJSON"], Get[path]]];
currentRelative = channel <> "/s11_result/s11_result.wl";
previousRelative = channel <> "/s11_result/reference/before_dimensional_completion/s11_result.wl";
current = read[currentRelative]; previous = read[previousRelative];
previousSource = FileNameJoin[{root, "common", "s11_result", "reference", "s11_collinear_spin_convolutions_before_dimensional.wls"}];
AppendTo[inputPaths, previousSource];
gate["same original and completed subtraction inputs", current["Channel"] === channel &&
  previous["Channel"] === channel && And @@ Values[current["Checks"]] && And @@ Values[previous["Checks"]] &&
  current["SourceHash"] === FileHash[baselineSource, "SHA256"] &&
  previous["SourceHash"] === FileHash[previousSource, "SHA256"] &&
  current["Routes"] === routes && previous["Routes"] === routes &&
  current["Prefactor"] === previous["Prefactor"] && current["Prefactor"] === reference["Prefactor"] &&
  current["MSPole"] === previous["MSPole"]];
Do[gate["unchanged actual convolution input " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === current["InputHashes"][name]],
  {name, Keys[current["InputHashes"]]}];
nativeRelative = "Hgq/s10_dimensional_gluon_result/s10_result.wl";
native = read[nativeRelative]; nativeReceipt = read["Hgq/s10_dimensional_gluon_result/s10_execution.json"];
nativeSource = FileNameJoin[{root, "common", "s10_dimensional_gluon_transfer.wls"}];
AppendTo[inputPaths, nativeSource];
gate["accepted native intermediate transfer", TrueQ[nativeReceipt["passed"]] &&
  nativeReceipt["job_id"] === "14816855" && nativeReceipt["result_sha256"][nativeRelative] ===
    IntegerString[FileHash[FileNameJoin[{root, nativeRelative}], "SHA256"], 16, 64] &&
  native["Schema"] === "polarized-sidis-gluon-intermediate-transfer-v1" &&
  native["SourceHash"] === FileHash[nativeSource, "SHA256"] && TrueQ[native["Accepted"]] &&
  And @@ Values[native["Checks"]] && native["NativeVersions"] === localProof["InputNativeVersions"] &&
  Last[native["NativeVersions"]] === $FeynCalcVersion &&
  native["InputHashes"]["common/s10_result/s10_result.wl"] === FileHash[kernelPath, "SHA256"]];
Do[gate["unchanged native transition input " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === native["InputHashes"][name]],
  {name, Keys[native["InputHashes"]]}];
spinBasis = read["common/s02_result/s02_result.wl"];
physicalPositions = Flatten[FirstPosition[native["SpinLabels"], #] & /@ labels];
ePosition = First[FirstPosition[native["SpinLabels"], "E"]];
selfRoutes = Select[routes, #["KernelKey"] === "gg" &];
gate["unique own intermediate gluon route", Length[selfRoutes] === 1 &&
  First[selfRoutes]["Side"] === "FF" && First[selfRoutes]["BornChannel"] === channel];
self = First[selfRoutes]; selfName = self["ReferenceName"];
born = borns[channel]; photonLabels = born["PhotonLabels"];
bornInPositions = Flatten[FirstPosition[born["ExtendedIncomingLabels"], #] & /@ labels];
bornOutPositions = Flatten[FirstPosition[born["ExtendedOutgoingLabels"], #] & /@ native["SpinLabels"]];
extendedBorn = born["ExtendedResponse"][[All, bornOutPositions, bornInPositions]];
mappedBorn = bounded[simplify[extendedBorn /. mapRules["FF"]], "original mapped extended Born response"];
gate["same physical Born response", zeroArray[
  extendedBorn[[All, physicalPositions, All]] - born["Response"]]];
gate["extra Born component vanishes in physical dimension",
  zeroArray[extendedBorn[[All, ePosition, All]] /. D -> native["DimensionLimit"]]];
gate["native outgoing transfer derived from parent Gram dual", zeroArray[
  native["FFKernelD"] - native["RawDimensionalKernel"].native["DualMatrices"][p]]];
leadingPhysical = Table[If[k === ePosition, 0, native["FFLeadingKernel"][[j, k]]],
  {j, physicalPositions}, {k, Length[native["SpinLabels"]]}];
(* Complete only the U projector, using the defining S03 CDR density.
   Other physical Stokes projectors keep their accepted native definitions.
   The regulator remainder is removed as in arXiv:0807.4424 Eq. (39). *)
stateGram = native["GramMatrices"][p];
physicalRank = stateGram[[uPosition, uPosition]];
extraRank = stateGram[[ePosition, ePosition]];
incomingAverage = Factor[physicalRank/(physicalRank + extraRank)];
gate["native dimensional average from parent projector norm", zero[
  incomingAverage (physicalRank + extraRank) - spinBasis["IncomingDensityNormalization"]]];
gate["same accepted incoming-gluon average convention", zero[
  incomingAverage - borns["Hgq"]["CDRAverageConversion"]]];
completion = Table[KroneckerDelta[k, physicalPositions[[i]]] +
    If[labels[[i]] === "U", KroneckerDelta[k, ePosition], 0],
  {i, Length[labels]}, {k, Length[native["SpinLabels"]]}];
incomingCompletion = Transpose[completion].DiagonalMatrix[
  If[# === "U", incomingAverage, 1] & /@ labels];
cdrKernelD = Map[Factor, completion.native["RawDimensionalKernel"].incomingCompletion, {2}];
cdrLeading = Map[Factor[Limit[#, D -> native["DimensionLimit"]]] &, cdrKernelD, {2}];
gate["all CDR physical limits equal accepted spin kernels", zeroArray[
  cdrLeading - kernelInput["Responses"]["gg"]["RealKernel"]]];
gate["complete CDR unpolarized kernel", zero[
  cdrKernelD[[uPosition, uPosition]] - native["FullDimensionalUnpolarizedKernel"]]];
cdrRegulatorRemainder = Map[Factor, cdrKernelD - cdrLeading, {2}];
gate["CDR regulator remainder has zero physical limit", zeroArray[Map[
  Limit[#, D -> native["DimensionLimit"]] &, cdrRegulatorRemainder, {2}]]];
gate["CDR scheme subtraction preserves unpolarized kernel",
  zero[cdrRegulatorRemainder[[uPosition, uPosition]]]];
embeddedCDRRemainder = Table[If[k === ePosition, 0,
    cdrRegulatorRemainder[[j, First[FirstPosition[physicalPositions, k]]]]],
  {j, Length[labels]}, {k, Length[native["SpinLabels"]]}];
msbarOperatorD = Map[Factor, native["FFKernelD"][[physicalPositions, All]] - embeddedCDRRemainder, {2}];
gate["exact MS scheme operator reconstruction", zeroArray[
  msbarOperatorD + embeddedCDRRemainder - native["FFKernelD"][[physicalPositions, All]]]];
gate["CDR finite conversion has no soft endpoint", zeroArray[
  Map[Limit[(1 - z) #, z -> 1] &, embeddedCDRRemainder, {2}]]];
Print["NATIVE_CDR_SPIN_KERNEL ", InputForm[cdrKernelD]];
Print["NATIVE_CDR_REGULATOR_REMAINDER ", InputForm[cdrRegulatorRemainder]];
kernelDifferenceD = Map[Factor, msbarOperatorD - leadingPhysical, {2}];
gate["exact dimensional kernel decomposition", zeroArray[
  leadingPhysical + kernelDifferenceD - msbarOperatorD]];
gate["unchanged leading physical kernel", zeroArray[Map[
  Limit[#, D -> native["DimensionLimit"]] &, kernelDifferenceD[[All, physicalPositions]], {2}]]];
softDifference = Map[Factor[Limit[(1 - z) #, z -> 1]] &, kernelDifferenceD, {2}];
gate["dimensional kernel difference has no soft endpoint", zeroArray[softDifference]];
gate["dimensional unpolarized MS kernel has no regulator term", zero[
  native["FullDimensionalUnpolarizedKernel"] -
    native["FFLeadingKernel"][[uPosition, uPosition]]]];
extraKernel = kernelDifferenceD /. z -> x;
pieces = Table[
  Print["DIMENSIONAL_OPERATOR_CONVOLUTION ", a, " ", j, " ", i];
  terms = Table[
    If[extraKernel[[j, k]] === 0 ||
        (extendedBorn[[a, k, i]] === 0 && mappedBorn[[a, k, i]] === 0),
      AssociationThread[distributions, ConstantArray[0, Length[distributions]]],
      bounded[convolution[extendedBorn[[a, k, i]], extraKernel[[j, k]], roots["FF"],
        simplify[measureWeights["FF"] mappedBorn[[a, k, i]]]],
        {a, j, i, k, "dimensional operator convolution"}]],
    {k, Length[native["SpinLabels"]]}];
  Merge[terms, Factor[Total[#]] &],
  {a, Length[photonLabels]}, {j, Length[labels]}, {i, Length[labels]}];
extraConvolutions = Association@Table[distribution -> Map[#[distribution] &, pieces, {3}],
  {distribution, distributions}];
gate["evaluated additional convolutions", FreeQ[extraConvolutions,
  _Missing | _Integrate | _Limit | _SeriesData | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
gate["native zero endpoint contributions", zeroArray[Lookup[extraConvolutions, {"Delta", "L0"}]]];
candidateRoutes = previous["RouteConvolutionsD"];
AssociateTo[candidateRoutes, selfName -> Association@Table[distribution ->
  Map[Factor, candidateRoutes[selfName][distribution] + extraConvolutions[distribution], {3}],
  {distribution, distributions}]];
candidateConvolutions = Association@Table[distribution -> Map[Factor,
  Total[#[distribution] & /@ Values[candidateRoutes]], {3}], {distribution, distributions}];
gate["only the computed native route added", zeroArray[Values[candidateConvolutions] -
  Values[previous["ConvolutionsD"]] - Values[extraConvolutions]]];
(* Reuse the accepted baseline and apply the original expansion to the added
   operator only. The defining convolution identity above and own full-Series
   comparisons below gate this linear update before any finite comparison. *)
expansionStarted=AbsoluteTime[];
originalExpandCounterterm[value_,label_]:=bounded[
  Normal[Series[reference["Prefactor"] previous["MSPole"] (value/.D->4-2eps),{eps,0,0}]],label];
expansionStructureCounts=<||>;
expandCounterterm[value_,label_]:=Module[
  {rational,numerator,denominator,denominatorFactors,dimensionalDenominator,
   constantDenominator,coefficients,placeholders,formal,restoration,expanded,structure},
  If[value===0,Return[0]];
  rational=Together[value];numerator=Numerator[rational];denominator=Denominator[rational];
  gate["counterterm numerator polynomial in dimension",PolynomialQ[numerator,D]&&FreeQ[rational,eps]];
  denominatorFactors=FactorList[denominator];
  dimensionalDenominator=Times@@(Power@@#&/@Select[denominatorFactors,!FreeQ[First[#],D]&]);
  constantDenominator=Factor[denominator/dimensionalDenominator];
  coefficients=CoefficientList[numerator,D];
  gate["counterterm coefficients independent of dimension",FreeQ[{coefficients,constantDenominator},D|eps]];
  placeholders=Table[Unique["countertermCoefficient"],{Length[coefficients]}];
  restoration=Thread[placeholders->coefficients];
  formal=Sum[placeholders[[degree+1]] D^degree,{degree,0,Length[coefficients]-1}]/dimensionalDenominator;
  gate["exact dimensional polynomial reconstruction",Together[value-(formal/.restoration)/constantDenominator]===0];
  structure=ToString[{Length[coefficients]-1,dimensionalDenominator},InputForm];
  AssociateTo[expansionStructureCounts,structure->(Lookup[expansionStructureCounts,structure,0]+1)];
  expanded=originalExpandCounterterm[formal,label];
  Factor[(expanded/.restoration)/constantDenominator]];
baselineExpansion=Association@Table[
  Print["BASELINE_COUNTERTERM_REUSE_CHECK ",distribution];
  distribution->Map[expandCounterterm[#,{distribution,"saved baseline expansion"}]&,
    previous["ConvolutionsD"][distribution],{3}],{distribution,distributions}];
gate["all baseline expansions equal own accepted counterterms",zeroArray[
  Values[baselineExpansion]-Values[previous["Counterterms"]]]];
Clear[baselineExpansion];
originalControls=Table[
  position=First[Position[previous["ConvolutionsD"][distribution],value_/;value=!=0,{3},Heads->False]];
  Print["DIRECT_ORIGINAL_BASELINE_CONTROL ",distribution," ",position];
  originalValue=originalExpandCounterterm[Extract[previous["ConvolutionsD"][distribution],position],
    {distribution,position,"original unsplit baseline expansion"}];
  gate["original unsplit baseline expansion "<>distribution,
    zero[originalValue-Extract[previous["Counterterms"][distribution],position]]];
  <|"Distribution"->distribution,"Position"->position,"Equal"->True|>,{distribution,distributions}];
newCounterterms=Association@Table[
  Print["EXPAND_ADDED_COUNTERTERM ",distribution];
  distribution->Map[expandCounterterm[#,{distribution,"additional counterterm expansion"}]&,
    extraConvolutions[distribution],{3}],{distribution,distributions}];
candidateCounterterms=Association@Table[distribution->
  (previous["Counterterms"][distribution]+newCounterterms[distribution]),{distribution,distributions}];
expansionSeconds=AbsoluteTime[]-expansionStarted;
expansionControls=Table[
  changedPositions=Position[extraConvolutions[distribution],value_/;value=!=0,{3},Heads->False];
  nonzeroPositions=Position[candidateConvolutions[distribution],value_/;value=!=0,{3},Heads->False];
  controlPosition=If[changedPositions=!={},First[changedPositions],First[nonzeroPositions]];
  controlInput=Extract[candidateConvolutions[distribution],controlPosition];
  Print["RECONSTRUCTED_COUNTERTERM_CONTROL ",distribution," ",controlPosition];
  controlStarted=AbsoluteTime[];
  directCounterterm=expandCounterterm[controlInput,{distribution,controlPosition,"own full expansion control"}];
  gate["own full expansion equals reused counterterm "<>distribution,
    zero[directCounterterm-Extract[candidateCounterterms[distribution],controlPosition]]];
  <|"Distribution"->distribution,"Position"->controlPosition,"Changed"->(changedPositions=!={}),
    "Seconds"->(AbsoluteTime[]-controlStarted),"Equal"->True|>,{distribution,distributions}];
Print["COUNTERTERM_EXPANSION_SECONDS ",expansionSeconds," CONTROLS ",InputForm[expansionControls]];
correction = Association@Table[distribution -> Map[Factor,
  candidateCounterterms[distribution] - current["Counterterms"][distribution], {3}], {distribution, distributions}];
extraCounterterms = Association@Table[distribution -> Map[Factor,
  candidateCounterterms[distribution] - previous["Counterterms"][distribution], {3}], {distribution, distributions}];
gate["complete native counterterm change is finite", FreeQ[{correction, extraCounterterms}, eps | D] &&
  FreeQ[candidateCounterterms, _Series | _SeriesData | _Missing | $Failed | $Aborted]];
localCheckpoint[value_,path_]:=Module[{serialized},
  serialized="Uncompress["<>ToString[Compress[value],InputForm]<>"]\n";
  gate["bounded local equation checkpoint",StringLength[serialized]<localConfig["limits"]["output_bytes"]];
  Export[path<>".tmp",serialized,"Text"];
  gate["exact local equation checkpoint reload",Get[path<>".tmp"]===value];
  RenameFile[path<>".tmp",path,OverwriteTarget->True]];
localCheckpoint[<|"Channel"->channel,"SourceSHA256"->localConfig["source_sha256"],
  "InputSHA256"->localConfig["input_sha256"],"Counterterms"->candidateCounterterms,
  "ConvolutionsD"->candidateConvolutions,"Correction"->correction,"ExtraCounterterms"->extraCounterterms,
  "ExtraConvolutionsD"->extraConvolutions,"Checks"->checks,"NativeVersions"->{$Version,$FeynCalcVersion},
  "ExpansionSeconds"->expansionSeconds,"ExpansionControls"->expansionControls,
  "OriginalControls"->originalControls,"DimensionalStructures"->expansionStructureCounts,
  "AcceptedForProduction"->False|>,FileNameJoin[{root,"misc","s02_result","s02_candidate.wl"}]];

inspection=read["misc/s01_result/reference/s14_result.wl"];
termProof=localProof;
gate["exact locally established discrepancy inputs",
 termProof["InputSHA256"]["misc/s01_result/reference/s14_result.wl"]===IntegerString[
  FileHash[FileNameJoin[{root,"misc","s01_result","reference","s14_result.wl"}],"SHA256"],16,64]&&
 termProof["InputSHA256"][currentRelative]===IntegerString[FileHash[FileNameJoin[{root,currentRelative}],"SHA256"],16,64]&&
 termProof["InputSHA256"][previousRelative]===IntegerString[FileHash[FileNameJoin[{root,previousRelative}],"SHA256"],16,64]&&
 inspection["Channel"]===channel&&inspection["NativeVersions"]===termProof["InputNativeVersions"]&&
 inspection["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_inspect_Hqg_reference_residual.wls"}],"SHA256"]];
assemblyPath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];assemblyText=Import[assemblyPath,"Text"];
gate["same finite assembly equations",inspection["BaselineSourceHash"]===FileHash[assemblyPath,"SHA256"]&&
  termProof["InputSHA256"]["common/s14_assemble_finite_spin.wls"]===IntegerString[FileHash[assemblyPath,"SHA256"],16,64]];
domainLines=Select[StringSplit[assemblyText,"\n"],StringStartsQ[#,"physical="]||StringStartsQ[#,"softPhysical="]&];
gate["unique original domains",Length[domainLines]===2&&SyntaxQ[StringRiffle[domainLines,"\n"]]];
ToExpression[StringRiffle[domainLines,"\n"],InputForm];
reductionStart=StringPosition[assemblyText,"reduce[value_,assumptions_] :="];
reductionEnd=StringPosition[assemblyText,"\nzero[value_,assumptions_] :="];
gate["unique original finite reducer",Length[reductionStart]===1&&Length[reductionEnd]===1];
reductionText=StringTake[assemblyText,{First[First[reductionStart]],First[First[reductionEnd]]-1}];
gate["original finite reducer syntax",SyntaxQ[reductionText]];ToExpression[reductionText,InputForm];
hatConfig=read["common/s14_inputs.json"];
referenceHats=Association@KeyValueMap[Function[{name,relative},Module[{row},
  row=SelectFirst[hatConfig["files"],#["destination"]===relative&];
  gate["pinned final reference "<>name,IntegerString[FileHash[FileNameJoin[{root,relative}],"SHA256"],16,64]===row["sha256"]];
  name->(read[relative]/.{Q2->Q^2,w->s23,Nc->SUNN})]],hatConfig["channels"][channel]["unpolarized_hats"]];
cache=FileNameJoin[{root,"misc","s02_result","reference","finite_checkpoints"}];
checkpointManifestPath=FileNameJoin[{cache,"s02_checkpoint_manifest.json"}];
checkpointManifest=Import[checkpointManifestPath,"RawJSON"];AppendTo[inputPaths,checkpointManifestPath];
photonWeights=inspection["PhotonWeights"];normalization=termProof["Normalization"];
checkpointHashes=<||>;comparisonRows={};
SetAttributes[referenceStep,HoldFirst];
referenceStep[value_,step_]:=Module[{started=AbsoluteTime[],answer},
  Print["REFERENCE_OPERATION_BEGIN ",name," ",sign," ",distribution," ",step];
  answer=TimeConstrained[bounded[value,{name,sign,distribution,step}],60,$TimedOut];
  Print["REFERENCE_OPERATION_END ",name," ",sign," ",distribution," ",step,
    " seconds ",AbsoluteTime[]-started," completed ",answer=!=$TimedOut];
  If[answer===$TimedOut,Print["INCOMPLETE: saved exact equation before ",step];Quit[2]];answer];
Do[
  distributionKeys=Keys[referenceHats[name]["NLO"][sign]];
  Do[
    Print["RESOLVED_GLUON_REFERENCE ",name," ",sign," ",distribution];
    values=Table[
      label={{a,uPosition,uPosition},sign,distribution};
      path=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
      gate["bound local checkpoint hash",KeyExistsQ[checkpointManifest["files"],FileNameTake[path]]&&
        IntegerString[FileHash[path,"SHA256"],16,64]===checkpointManifest["files"][FileNameTake[path]]["sha256"]];
      saved=Get[path];
      gate["accepted own finite checkpoint "<>ToString[label,InputForm],
        saved["InputHash"]===inspection["InputHash"]&&saved["Label"]===label&&TrueQ[saved["Accepted"]]];
      AssociateTo[checkpointHashes,StringDrop[path,StringLength[root]+1]->FileHash[path,"SHA256"]];
      saved["Finite"],{a,Length[spinBasis["PhotonLabels"]]}];
    change=If[KeyExistsQ[correction,distribution],correction[distribution][[All,uPosition,uPosition]],
      ConstantArray[0,Length[values]]]/.t->sign omega-s;
    candidate=normalization photonWeights[[First[FirstPosition[Keys[referenceHats],name]]]].(values+change);
    expected=referenceHats[name]["NLO"][sign][distribution];
    assumptions=(If[distribution==="Regular",physical,softPhysical]/.t->sign omega-s)&&If[sign===0,True,omega>0];
    difference=candidate-expected;
    equationPath=FileNameJoin[{root,"misc","s02_result",
      "s02_equation_"<>name<>"_"<>ToString[sign]<>"_"<>distribution<>".wl"}];
    equationRecord=<|"SourceSHA256"->localConfig["source_sha256"],"Hat"->name,"Branch"->sign,
      "Distribution"->distribution,"Candidate"->candidate,"Expected"->expected,
      "Difference"->difference,"Conditions"->assumptions,"Accepted"->False|>;
    localCheckpoint[equationRecord,equationPath];
    functions=DeleteDuplicates[Cases[difference,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
    prepared=referenceStep[If[functions==={},Factor[difference],Collect[difference,functions,Factor]],"reference precollection"];
    gate["exact finite input reconstruction",referenceStep[Together[difference-prepared],"reference reconstruction"]===0];
    AssociateTo[equationRecord,"Prepared"->prepared];localCheckpoint[equationRecord,equationPath];
    residual=referenceStep[reduce[prepared,assumptions],"original finite reduction"];
    AssociateTo[equationRecord,"Reduced"->residual];localCheckpoint[equationRecord,equationPath];
    residual=If[residual===0,0,referenceStep[FullSimplify[FunctionExpand[residual,assumptions],assumptions],"finite function identities"]];
    AssociateTo[equationRecord,{"Residual"->residual,"Accepted"->(residual===0)}];localCheckpoint[equationRecord,equationPath];
    AppendTo[comparisonRows,<|"Hat"->name,"Branch"->sign,"Distribution"->distribution,"Residual"->residual,"Equal"->(residual===0)|>];
    Print["RESOLVED_GLUON_REFERENCE_RESIDUAL ",name," ",sign," ",distribution," ",InputForm[residual]];
    Clear[saved,values,candidate,expected,difference,prepared];ClearSystemCache[],
    {distribution,distributionKeys}],{name,Keys[referenceHats]},{sign,Keys[referenceHats[name]["NLO"]]}];
allEqual = And @@ Lookup[comparisonRows, "Equal"];
inputPaths = DeleteDuplicates[Join[inputPaths, {studySource,assemblyPath},
 FileNameJoin[{root,#}]&/@{"common/s14_inspect_Hqg_reference_residual.wls","common/s14_check_Hqg_reference_terms.wls"},
 FileNameJoin[{root, #}] & /@ Keys[current["InputHashes"]]]];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
sourceHash = FileHash[studySource, "SHA256"];
proof = <|"Schema" -> "polarized-sidis-native-gluon-convolution-comparison-v1", "Channel" -> channel,
  "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "ReusedInputNativeVersions" -> native["NativeVersions"], "LocalResidualComparisonHash" -> FileHash[localProofPath,"SHA256"],
  "NativeTransferHash" -> FileHash[FileNameJoin[{root, nativeRelative}], "SHA256"],
  "OriginalAssemblyInputHash" -> inspection["InputHash"], "CheckpointHashes" -> checkpointHashes,
  "OriginalSubtractionHash" -> FileHash[FileNameJoin[{root, currentRelative}], "SHA256"],
  "CDRKernelD" -> cdrKernelD, "CDRRegulatorRemainder" -> cdrRegulatorRemainder,
  "MSOperatorD" -> msbarOperatorD, "MSReference" -> "arXiv:0807.4424 Eqs. (36)-(39)",
  "KernelDifferenceD" -> kernelDifferenceD, "ExtraConvolutionsD" -> extraConvolutions, "ExtraCounterterms" -> extraCounterterms,
  "ExpansionReuse"-><|"BaselineHash"->FileHash[FileNameJoin[{root,previousRelative}],"SHA256"],
    "ExpansionSeconds"->expansionSeconds,"OwnFullExpansionComparisons"->expansionControls,
    "OriginalUnsplitBaselineComparisons"->originalControls,"AllSavedBaselineCountertermsEqual"->True,
    "DimensionalStructures"->expansionStructureCounts|>,
  "Correction" -> correction, "Comparisons" -> comparisonRows, "Checks" -> checks,
   "Accepted" -> allEqual, "AcceptedForProduction" -> allEqual,
  "SchemeStatus" -> "MS subtraction: complete native operator minus its CDR regulator remainder; quark axial conversion deferred to S15",
  "FiniteNLOFHatsComputed" -> False|>;
out = FileNameJoin[{root, "misc", "s02_result"}];
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
proofPath = FileNameJoin[{out, "s11_comparison.wl"}]; put[proof, proofPath];
gate["exact native comparison reload", Get[proofPath] === proof];
Export[FileNameJoin[{out, "s11_checks.json"}], <|"checks" -> checks, "all_reference_components_restored" -> allEqual,
  "execution_location" -> "local misc", "process_id" -> $ProcessID, "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
gate["all native-corrected finite reference components match", allEqual];
result = Join[previous, <|"RouteConvolutionsD" -> candidateRoutes, "ConvolutionsD" -> candidateConvolutions,
  "Counterterms" -> candidateCounterterms, "CountertermDifference" -> correction,
  "IntermediateStateConvention" -> "Native dimensional operator with CDR MS finite conversion",
  "AcceptedForProduction" -> allEqual, "SchemeStatus" -> proof["SchemeStatus"],
  "CDRKernelD" -> cdrKernelD, "CDRRegulatorRemainder" -> cdrRegulatorRemainder,
  "MSOperatorD" -> msbarOperatorD, "FiniteDimensionalSchemeConversionApplied" -> True,
  "PreviousSubtractionHash" -> proof["OriginalSubtractionHash"], "NativeTransferHash" -> proof["NativeTransferHash"],
  "ConvolutionComparisonHash" -> FileHash[proofPath, "SHA256"],
  "SourceHash" -> sourceHash, "BaseSourceHash" -> FileHash[baselineSource, "SHA256"],
  "InputHashes" -> inputHashes, "InputHash" -> Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"],
  "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>];
path = FileNameJoin[{out, "s11_result.wl"}];
serialized = "Uncompress[" <> ToString[Compress[result], InputForm] <> "]\n";
gate["bounded native subtraction export", StringLength[serialized] < 128*1024^2];
Export[path <> ".tmp", serialized, "Text"]; gate["exact native subtraction reload", Get[path <> ".tmp"] === result];
RenameFile[path <> ".tmp", path, OverwriteTarget -> True];
Print["PASS: s02_finalize_Hqg_subtraction"]; Quit[0];

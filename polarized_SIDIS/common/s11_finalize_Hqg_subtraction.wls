(* Original S11 convolution with the native intermediate-gluon transfer. *)
$HistoryLength = 0; root = Directory[];
studySource = FileNameJoin[{root, "common", "s11_finalize_Hqg_subtraction.wls"}];
baselineSource = FileNameJoin[{root, "common", "s11_collinear_spin_convolutions.wls"}];
If[IntegerString[FileHash[baselineSource, "SHA256"], 16, 64] =!=
  "4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6", Quit[1]];
baselineText = Import[baselineSource, "Text"];
boundary = StringPosition[baselineText, "completionPath = FileNameJoin["];
If[Length[boundary] =!= 1 || !SyntaxQ[Import[studySource, "Text"]], Quit[1]];
prefix = StringTake[baselineText, First[First[boundary]] - 1];
If[!SyntaxQ[prefix], Quit[1]]; ToExpression[prefix, InputForm];
gate["own gluon subtraction channel", channel === "Hqg"];
inputPaths = {baselineSource};
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
  And @@ Values[native["Checks"]] && native["NativeVersions"] === {$Version, $FeynCalcVersion} &&
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
candidateCounterterms = Association@Table[distribution -> Map[
  bounded[Normal[Series[reference["Prefactor"] previous["MSPole"] (# /. D -> 4 - 2 eps), {eps, 0, 0}]],
    {distribution, "original counterterm expansion"}] &, candidateConvolutions[distribution], {3}],
  {distribution, distributions}];
correction = Association@Table[distribution -> Map[Factor,
  candidateCounterterms[distribution] - current["Counterterms"][distribution], {3}], {distribution, distributions}];
extraCounterterms = Association@Table[distribution -> Map[Factor,
  candidateCounterterms[distribution] - previous["Counterterms"][distribution], {3}], {distribution, distributions}];
gate["complete native counterterm change is finite", FreeQ[{correction, extraCounterterms}, eps | D] &&
  FreeQ[candidateCounterterms, _Series | _SeriesData | _Missing | $Failed | $Aborted]];

inspection=read[channel<>"/s14_reference_residual_result/s14_result.wl"];
termProof=read[channel<>"/s14_reference_terms_result/s14_result.wl"];
gate["exact established discrepancy input",termProof["InspectionHash"]===
  FileHash[FileNameJoin[{root,channel,"s14_reference_residual_result","s14_result.wl"}],"SHA256"]&&
  termProof["SubtractionHash"]===FileHash[FileNameJoin[{root,currentRelative}],"SHA256"]&&
  termProof["PreviousSubtractionHash"]===FileHash[FileNameJoin[{root,previousRelative}],"SHA256"]&&
  And@@Values[termProof["Checks"]]&&And@@Lookup[termProof["Rows"],"DimensionalChangeExplainsResidual"]&&
  termProof["NativeVersions"]==={$Version,$FeynCalcVersion}];
inspectionReceipt=read[channel<>"/s14_reference_residual_result/s14_execution.json"];
termReceipt=read[channel<>"/s14_reference_terms_result/s14_execution.json"];
gate["accepted own native comparison inputs",TrueQ[inspectionReceipt["passed"]]&&TrueQ[termReceipt["passed"]]&&
 inspection["Channel"]===channel&&termProof["Channel"]===channel&&
 inspection["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_inspect_Hqg_reference_residual.wls"}],"SHA256"]&&
 termProof["SourceHash"]===FileHash[FileNameJoin[{root,"common","s14_check_Hqg_reference_terms.wls"}],"SHA256"]];
Do[KeyValueMap[gate["bound accepted comparison output "<>#1,
 IntegerString[FileHash[FileNameJoin[{root,#1}],"SHA256"],16,64]===#2]&,receipt["result_sha256"]],
 {receipt,{inspectionReceipt,termReceipt}}];
assemblyPath=FileNameJoin[{root,"common","s14_assemble_finite_spin.wls"}];assemblyText=Import[assemblyPath,"Text"];
gate["same finite assembly equations",inspection["BaselineSourceHash"]===FileHash[assemblyPath,"SHA256"]&&
  termProof["AssemblySourceHash"]===FileHash[assemblyPath,"SHA256"]];
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
cache=FileNameJoin[{root,"cache","s14",channel,IntegerString[inspection["InputHash"],16]}];
photonWeights=inspection["PhotonWeights"];normalization=termProof["Normalization"];
checkpointHashes=<||>;comparisonRows={};
Do[
  distributionKeys=Keys[referenceHats[name]["NLO"][sign]];
  Do[
    Print["RESOLVED_GLUON_REFERENCE ",name," ",sign," ",distribution];
    values=Table[
      label={{a,uPosition,uPosition},sign,distribution};
      path=FileNameJoin[{cache,"finite_"<>IntegerString[Hash[label,"SHA256"],16]<>".wl"}];
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
    functions=DeleteDuplicates[Cases[difference,_Log|_PolyLog|_ArcTan|_ArcTanh|_Re|_Im,Infinity]];
    prepared=bounded[If[functions==={},Factor[difference],Collect[difference,functions,Factor]],"reference precollection"];
    gate["exact finite input reconstruction",bounded[Together[difference-prepared],"reference reconstruction"]===0];
    residual=bounded[reduce[prepared,assumptions],"original finite reduction"];
    residual=If[residual===0,0,bounded[FullSimplify[FunctionExpand[residual,assumptions],assumptions],"finite function identities"]];
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
  "NativeTransferHash" -> FileHash[FileNameJoin[{root, nativeRelative}], "SHA256"],
  "OriginalAssemblyInputHash" -> inspection["InputHash"], "CheckpointHashes" -> checkpointHashes,
  "OriginalSubtractionHash" -> FileHash[FileNameJoin[{root, currentRelative}], "SHA256"],
  "CDRKernelD" -> cdrKernelD, "CDRRegulatorRemainder" -> cdrRegulatorRemainder,
  "MSOperatorD" -> msbarOperatorD, "MSReference" -> "arXiv:0807.4424 Eqs. (36)-(39)",
  "KernelDifferenceD" -> kernelDifferenceD, "ExtraConvolutionsD" -> extraConvolutions, "ExtraCounterterms" -> extraCounterterms,
  "Correction" -> correction, "Comparisons" -> comparisonRows, "Checks" -> checks,
   "Accepted" -> allEqual, "AcceptedForProduction" -> allEqual,
  "SchemeStatus" -> "MS subtraction: complete native operator minus its CDR regulator remainder; quark axial conversion deferred to S15",
  "FiniteNLOFHatsComputed" -> False|>;
out = FileNameJoin[{root, channel, "s11_msbar_result"}];
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
proofPath = FileNameJoin[{out, "s11_comparison.wl"}]; put[proof, proofPath];
gate["exact native comparison reload", Get[proofPath] === proof];
Export[FileNameJoin[{out, "s11_checks.json"}], <|"checks" -> checks, "all_reference_components_restored" -> allEqual,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
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
Print["PASS: s11_finalize_Hqg_subtraction"]; Quit[0];

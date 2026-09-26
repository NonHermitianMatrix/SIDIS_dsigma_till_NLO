(* Original S11 convolution with the native intermediate-gluon transfer. *)
$HistoryLength = 0; root = Directory[];
studySource = FileNameJoin[{root, "common", "s11_finalize_Hgq_subtraction.wls"}];
baselineSource = FileNameJoin[{root, "common", "s11_collinear_spin_convolutions.wls"}];
If[IntegerString[FileHash[baselineSource, "SHA256"], 16, 64] =!=
  "4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6", Quit[1]];
baselineText = Import[baselineSource, "Text"];
boundary = StringPosition[baselineText, "completionPath = FileNameJoin["];
If[Length[boundary] =!= 1 || !SyntaxQ[Import[studySource, "Text"]], Quit[1]];
prefix = StringTake[baselineText, First[First[boundary]] - 1];
If[!SyntaxQ[prefix], Quit[1]]; ToExpression[prefix, InputForm];
gate["own gluon subtraction channel", channel === "Hgq"];
inputPaths = {baselineSource};
read[relative_] := Module[{path = FileNameJoin[{root, relative}]},
  AppendTo[inputPaths, path]; If[StringEndsQ[path, ".json"], Import[path, "RawJSON"], Get[path]]];
currentRelative = channel <> "/s11_result/reference/before_resolved_gluon/s11_result.wl";
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
nativeRelative = channel <> "/s10_dimensional_gluon_result/s10_result.wl";
native = read[nativeRelative]; nativeReceipt = read[channel <> "/s10_dimensional_gluon_result/s10_execution.json"];
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
  First[selfRoutes]["Side"] === "PDF" && First[selfRoutes]["BornChannel"] === channel];
self = First[selfRoutes]; selfName = self["ReferenceName"];
born = borns[channel]; photonLabels = born["PhotonLabels"];
bornInPositions = Flatten[FirstPosition[born["ExtendedIncomingLabels"], #] & /@ native["SpinLabels"]];
bornOutPositions = Flatten[FirstPosition[born["ExtendedOutgoingLabels"], #] & /@ labels];
extendedBorn = born["ExtendedResponse"][[All, bornOutPositions, bornInPositions]];
mappedBorn = bounded[simplify[extendedBorn /. mapRules["PDF"]], "original mapped extended Born response"];
gate["same physical Born response", zeroArray[
  extendedBorn[[All, All, physicalPositions]] - born["Response"]]];
gate["extra Born component vanishes in physical dimension",
  zeroArray[extendedBorn[[All, All, ePosition]] /. D -> native["DimensionLimit"]]];
leadingPhysical = Table[If[j === ePosition, 0, native["PDFLeadingKernel"][[j, i]]],
  {j, Length[native["SpinLabels"]]}, {i, physicalPositions}];
(* Complete only the U projector, using the defining S03 CDR density.
   Other physical Stokes projectors keep their accepted native definitions.
   The regulator remainder is removed as in arXiv:0807.4424 Eq. (39). *)
stateGram = native["GramMatrices"][p];
physicalRank = stateGram[[uPosition, uPosition]];
extraRank = stateGram[[ePosition, ePosition]];
incomingAverage = Factor[physicalRank/(physicalRank + extraRank)];
gate["same native S03 dimensional average", zero[incomingAverage - born["CDRAverageConversion"]]];
completion = Table[KroneckerDelta[k, physicalPositions[[i]]] +
    If[labels[[i]] === "U", KroneckerDelta[k, ePosition], 0],
  {i, Length[labels]}, {k, Length[native["SpinLabels"]]}];
incomingCompletion = Transpose[completion].DiagonalMatrix[
  If[# === "U", incomingAverage, 1] & /@ labels];
cdrKernelD = Map[Factor, completion.native["CrossedRawDimensionalKernel"].incomingCompletion, {2}];
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
    cdrRegulatorRemainder[[First[FirstPosition[physicalPositions, k]], i]]],
  {k, Length[native["SpinLabels"]]}, {i, Length[labels]}];
msbarOperatorD = Map[Factor, native["PDFKernelD"][[All, physicalPositions]] - embeddedCDRRemainder, {2}];
gate["exact MS scheme operator reconstruction", zeroArray[
  msbarOperatorD + embeddedCDRRemainder - native["PDFKernelD"][[All, physicalPositions]]]];
gate["CDR finite conversion has no soft endpoint", zeroArray[
  Map[Limit[(1 - z) #, z -> 1] &, embeddedCDRRemainder, {2}]]];
Print["NATIVE_CDR_SPIN_KERNEL ", InputForm[cdrKernelD]];
Print["NATIVE_CDR_REGULATOR_REMAINDER ", InputForm[cdrRegulatorRemainder]];
kernelDifferenceD = Map[Factor, msbarOperatorD - leadingPhysical, {2}];
gate["exact dimensional kernel decomposition", zeroArray[
  leadingPhysical + kernelDifferenceD - msbarOperatorD]];
gate["unchanged leading physical kernel", zeroArray[Map[
  Limit[#, D -> native["DimensionLimit"]] &, kernelDifferenceD[[physicalPositions]], {2}]]];
softDifference = Map[Factor[Limit[(1 - z) #, z -> 1]] &, kernelDifferenceD, {2}];
gate["dimensional kernel difference has no soft endpoint", zeroArray[softDifference]];
gate["dimensional unpolarized MS kernel has no regulator term", zero[
  native["FullDimensionalUnpolarizedKernel"] -
    native["PDFLeadingKernel"][[uPosition, uPosition]]]];
extraKernel = kernelDifferenceD /. z -> x;
pieces = Table[
  Print["DIMENSIONAL_OPERATOR_CONVOLUTION ", a, " ", j, " ", i];
  terms = Table[
    If[extraKernel[[k, i]] === 0 ||
        (extendedBorn[[a, j, k]] === 0 && mappedBorn[[a, j, k]] === 0),
      AssociationThread[distributions, ConstantArray[0, Length[distributions]]],
      bounded[convolution[extendedBorn[[a, j, k]], extraKernel[[k, i]], roots["PDF"],
        simplify[measureWeights["PDF"] mappedBorn[[a, j, k]]]],
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

residualRelative = channel <> "/s11_resolved_gluon_result/s11_result.wl";
residualPacket = read[residualRelative]; residualReceipt = read[channel <> "/s11_resolved_gluon_result/s11_execution.json"];
residualSource = FileNameJoin[{root, "common", "s11_check_Hgq_resolved_gluon.wls"}];
AppendTo[inputPaths, residualSource];
gate["exact completed residual calculation", residualReceipt["job_id"] === "14816029" &&
  residualPacket["Schema"] === "polarized-sidis-resolved-gluon-subtraction-comparison-v1" &&
  residualPacket["SourceHash"] === FileHash[residualSource, "SHA256"] &&
  residualPacket["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  residualPacket["Channel"] === channel && And @@ Values[residualPacket["Checks"]] &&
  residualPacket["Counterterms"] === previous["Counterterms"] &&
  residualPacket["ConvolutionsD"] === previous["ConvolutionsD"]];
Do[gate["unchanged residual equation input " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === residualPacket["InputHashes"][name]],
  {name, Keys[residualPacket["InputHashes"]]}];
Do[gate["unchanged accepted finite checkpoint " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === residualPacket["CheckpointHashes"][name]],
  {name, Keys[residualPacket["CheckpointHashes"]]}];
inspection = read[channel <> "/s14_reference_residual_result/s14_result.wl"];
termProof = read[channel <> "/s14_reference_terms_result/s14_result.wl"];
gate["same original finite assembly", residualPacket["OriginalAssemblyInputHash"] === inspection["InputHash"] &&
  termProof["InspectionHash"] === FileHash[FileNameJoin[{root, channel, "s14_reference_residual_result", "s14_result.wl"}], "SHA256"] &&
  And @@ Values[inspection["Checks"]] && And @@ Values[termProof["Checks"]]];
assemblyPath = FileNameJoin[{root, "common", "s14_assemble_finite_spin.wls"}]; AppendTo[inputPaths, assemblyPath];
gate["same finite projection source", inspection["BaselineSourceHash"] === FileHash[assemblyPath, "SHA256"] &&
  termProof["AssemblySourceHash"] === FileHash[assemblyPath, "SHA256"]];
assemblyText = Import[assemblyPath, "Text"];
domainLines = Select[StringSplit[assemblyText, "\n"], StringStartsQ[#, "physical="] || StringStartsQ[#, "softPhysical="] &];
gate["unique original finite domains", Length[domainLines] === 2 && SyntaxQ[StringRiffle[domainLines, "\n"]]];
ToExpression[StringRiffle[domainLines, "\n"], InputForm];
hatConfig = read["common/s14_inputs.json"];
referenceHats = Association@KeyValueMap[Function[{name, relative}, name -> read[relative]],
  hatConfig["channels"][channel]["unpolarized_hats"]];
expectedInventory = Flatten[Table[{name, sign, distribution}, {name, Keys[referenceHats]},
  {sign, Keys[referenceHats[name]["NLO"]]}, {distribution, Keys[referenceHats[name]["NLO"][sign]]}], 2];
gate["every original finite distribution retained", Sort[Lookup[#, {"Hat", "Branch", "Distribution"}] & /@
  residualPacket["Comparisons"]] === Sort[expectedInventory]];
comparisonRows = Table[
  name = row["Hat"]; sign = row["Branch"]; distribution = row["Distribution"];
  weights = inspection["PhotonWeights"][[First[FirstPosition[Keys[referenceHats], name]]]];
  change = If[KeyExistsQ[extraCounterterms, distribution], extraCounterterms[distribution][[All, uPosition, uPosition]],
    ConstantArray[0, Length[weights]]];
  projectedChange = termProof["Normalization"] weights.change /. t -> sign omega - s;
  assumptions = (If[distribution === "Regular", physical, softPhysical] /. t -> sign omega - s) &&
    If[sign === 0, True, omega > 0];
  difference = bounded[Factor[Together[row["Residual"] + projectedChange]], {name, sign, distribution, "native correction"}];
  residual = If[difference === 0, 0, bounded[FullSimplify[FunctionExpand[difference, assumptions], assumptions],
    {name, sign, distribution, "physical-domain comparison"}]];
  Print["NATIVE_GLUON_REFERENCE_RESIDUAL ", name, " ", sign, " ", distribution, " ", InputForm[residual]];
  <|"Hat" -> name, "Branch" -> sign, "Distribution" -> distribution, "Residual" -> residual, "Equal" -> (residual === 0)|>,
  {row, residualPacket["Comparisons"]}];
allEqual = And @@ Lookup[comparisonRows, "Equal"];
inputPaths = DeleteDuplicates[Join[inputPaths, FileNameJoin[{root, #}] & /@ Keys[current["InputHashes"]]]];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
sourceHash = FileHash[studySource, "SHA256"];
proof = <|"Schema" -> "polarized-sidis-native-gluon-convolution-comparison-v1", "Channel" -> channel,
  "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "NativeTransferHash" -> FileHash[FileNameJoin[{root, nativeRelative}], "SHA256"],
  "OriginalAssemblyInputHash" -> inspection["InputHash"], "CheckpointHashes" -> residualPacket["CheckpointHashes"],
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
Print["PASS: s11_finalize_Hgq_subtraction"]; Quit[0];

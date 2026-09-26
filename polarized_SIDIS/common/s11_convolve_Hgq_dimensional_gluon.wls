(* Original S11 convolution with the native intermediate-gluon transfer. *)
$HistoryLength = 0; root = Directory[];
studySource = FileNameJoin[{root, "common", "s11_convolve_Hgq_dimensional_gluon.wls"}];
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
bornEPosition = First[FirstPosition[born["ExtendedIncomingLabels"], "E"]];
bornPhysicalPositions = Flatten[FirstPosition[born["ExtendedOutgoingLabels"], #] & /@ labels];
bornE = born["ExtendedResponse"][[All, bornPhysicalPositions, bornEPosition]];
mappedE = bounded[simplify[bornE /. mapRules["PDF"]], "original mapped Born E response"];
gate["extra Born component vanishes in physical dimension", zeroArray[bornE /. D -> native["DimensionLimit"]]];
nativeIdentity = Map[Factor, native["GramMatrices"][k1].native["DualMatrices"][k1]/
  spinBasis["IncomingDensityNormalization"], {2}];
deltaIdentity = kernelInput["Responses"]["gg"]["DeltaCoefficient"][[uPosition, uPosition]] nativeIdentity;
extraReal = native["PDFLeadingKernel"][[ePosition, physicalPositions]];
extraSoft = native["PDFSoftResidue"][[ePosition, physicalPositions]];
extraDelta = deltaIdentity[[ePosition, physicalPositions]];
gate["native additional transition has no endpoint distributions", zeroArray[{extraSoft, extraDelta}]];
extraKernel = (extraReal - extraSoft/(1 - z) + extraSoft kernelPlus[1/(1 - z)] +
  extraDelta kernelDelta[1 - z]) /. z -> x;
pieces = Table[
  Print["NATIVE_GLUON_CONVOLUTION ", a, " ", j, " ", i];
  If[extraKernel[[i]] === 0 || (bornE[[a, j]] === 0 && mappedE[[a, j]] === 0),
    AssociationThread[distributions, ConstantArray[0, Length[distributions]]],
    bounded[convolution[bornE[[a, j]], extraKernel[[i]], roots["PDF"],
      simplify[measureWeights["PDF"] mappedE[[a, j]]]], {a, j, i, "native E convolution"}]],
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
  "ExtraConvolutionsD" -> extraConvolutions, "ExtraCounterterms" -> extraCounterterms,
  "Correction" -> correction, "Comparisons" -> comparisonRows, "Checks" -> checks,
  "Accepted" -> allEqual, "FiniteNLOFHatsComputed" -> False|>;
out = FileNameJoin[{root, channel, "s11_dimensional_gluon_result"}];
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
proofPath = FileNameJoin[{out, "s11_comparison.wl"}]; put[proof, proofPath];
gate["exact native comparison reload", Get[proofPath] === proof];
Export[FileNameJoin[{out, "s11_checks.json"}], <|"checks" -> checks, "all_reference_components_restored" -> allEqual,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
gate["all native-corrected finite reference components match", allEqual];
result = Join[previous, <|"RouteConvolutionsD" -> candidateRoutes, "ConvolutionsD" -> candidateConvolutions,
  "Counterterms" -> candidateCounterterms, "CountertermDifference" -> correction,
  "IntermediateStateConvention" -> "Full-dimensional angular averaged Gram-dual gluon transfer with original physical endpoint identity",
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
Print["PASS: s11_convolve_Hgq_dimensional_gluon"]; Quit[0];

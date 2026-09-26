(* Spin-matrix PDF/FF convolutions in the pinned reference measurement. *)
$HistoryLength = 0; root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s11_collinear_spin_convolutions.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"]; checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  Print["FAIL: time bound ", label]; Quit[2]], 2*1024^3,
  Print["FAIL: memory bound ", label]; Quit[3]];
put[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
zeroArray[value_] := And @@ (zero /@ Flatten[{value}]);
configPath = FileNameJoin[{root, "common", "s11_inputs.json"}];
baseConfigPath = FileNameJoin[{root, "common", "s01_inputs.json"}];
config = Import[configPath, "RawJSON"]; baseConfig = Import[baseConfigPath, "RawJSON"];
gate["supported subtraction channel", KeyExistsQ[config["channels"], channel]];
referenceRow = config["channels"][channel];
Do[gate["pinned subtraction input " <> relative, IntegerString[
    FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] ===
    SelectFirst[config["files"], #["destination"] === relative &]["sha256"]], {relative, Values[referenceRow]}];
reference = Get[FileNameJoin[{root, referenceRow["result"]}]];
gate["reference subtraction source binding", reference["SourceHash"] ===
  FileHash[FileNameJoin[{root, referenceRow["source"]}], "SHA256"]];
kernelPath = FileNameJoin[{root, "common", "s10_result", "s10_result.wl"}];
kernelInput = Get[kernelPath];
gate["accepted spin splitting kernels", kernelInput["Schema"] === "polarized-sidis-collinear-kernels-v1" &&
  And @@ Values[kernelInput["Checks"]]];
labels = kernelInput["SpinLabels"]; uPosition = First[FirstPosition[labels, "U"]];
coreChannels = Keys[config["channels"]]; borns = <||>; species = <||>; additionalPaths = {};
Do[bornPath = FileNameJoin[{root, coreChannel, "s03_result", "s03_result.wl"}];
  born = Get[bornPath]; AppendTo[additionalPaths, bornPath];
  gate[coreChannel <> " accepted Born", born["Schema"] === "polarized-sidis-born-response-v2" &&
    born["Channel"] === coreChannel && And @@ Values[born["Checks"]]];
  ampRelative = baseConfig["channel_contracts"][coreChannel]["amplitude_file"];
  ampPath = FileNameJoin[{root, ampRelative}]; AppendTo[additionalPaths, ampPath];
  gate[coreChannel <> " pinned open amplitudes", IntegerString[FileHash[ampPath, "SHA256"], 16, 64] ===
    SelectFirst[baseConfig["files"], #["destination"] === ampRelative &]["sha256"]];
  amp = Get[ampPath]["Born"];
  fermions = DeleteDuplicates[Cases[amp, Spinor[sign_. Momentum[mom_, ___], ___] :> mom, Infinity]];
  anti = DeleteDuplicates[Cases[amp, Spinor[-Momentum[mom_, ___], ___] :> mom, Infinity]];
  gate[coreChannel <> " core resolved species", Intersection[anti, {p, k1}] === {}];
  AssociateTo[species, coreChannel -> (If[MemberQ[fermions, #], "q", "g"] & /@ {p, k1})];
  AssociateTo[borns, coreChannel -> born], {coreChannel, coreChannels}];
gate["unique generated Born species", DuplicateFreeQ[Values[species]]];
gate["shared accepted photon and spin bases", And @@ Table[
  borns[key]["PhotonLabels"] === borns[channel]["PhotonLabels"] && borns[key]["SpinLabels"] === labels,
  {key, coreChannels}]];
originalBornRelative = baseConfig["channel_contracts"]["Hqq"]["unpolarized_born_file"];
originalBornPath = FileNameJoin[{root, originalBornRelative}]; originalBorn = Get[originalBornPath];
AppendTo[additionalPaths, originalBornPath];
gate["pinned real scalar products", IntegerString[FileHash[originalBornPath, "SHA256"], 16, 64] ===
  SelectFirst[baseConfig["files"], #["destination"] === originalBornRelative &]["sha256"]];
physical = Q > 0 && s > s23 > 0 && s23 - Q^2 - s < t < -Q^2 s23/s && B > 0 && SUNN > 1;
endpointRegion = Q > 0 && s > 0 && -Q^2 - s < t < 0 && B > 0 && SUNN > 1;
simplify[value_] := FullSimplify[value, Assumptions -> physical];
FCClearScalarProducts[]; DataType[eta, FCVariable] = True; DataType[zeta, FCVariable] = True;
Scan[Function[row, With[{a = row[[1]], b = row[[2]], value = row[[3]] /. Q2 -> Q^2}, SPD[a, b] = value]],
  originalBorn["RealScalarProducts"]];
invariants = <|"s" -> ExpandScalarProduct[SPD[eta p + q]],
  "t" -> ExpandScalarProduct[SPD[q - k1/zeta]],
  "recoil" -> ExpandScalarProduct[SPD[eta p + q - k1/zeta]]|>;
gate["scaled invariants evaluated", FreeQ[invariants, _Pair]];
incomingSolutions = Solve[(invariants["recoil"] /. zeta -> 1) == 0, eta];
outgoingSolutions = Solve[(invariants["recoil"] /. eta -> 1) == 0, zeta];
gate["unique convolution roots", Length[incomingSolutions] === 1 && Length[outgoingSolutions] === 1];
incomingRoot = eta /. First[incomingSolutions]; outgoingRoot = zeta /. First[outgoingSolutions];
incomingJacobian = simplify[1/Abs[D[invariants["recoil"], eta] /. {eta -> incomingRoot, zeta -> 1}]];
outgoingJacobian = simplify[1/Abs[D[invariants["recoil"], zeta] /. {eta -> 1, zeta -> outgoingRoot}]];
gate["exact reference roots and Jacobians", zeroArray[
  {incomingRoot, outgoingRoot, incomingJacobian, outgoingJacobian} -
    Lookup[reference, {"IncomingRoot", "OutgoingRoot", "IncomingJacobian", "OutgoingJacobian"}]]];
gate["convolution roots in physical support", simplify[0 < incomingRoot < 1 && 0 < outgoingRoot < 1]];
metric = DiagonalMatrix[{1, -1, -1, -1}]; dot4[a_, b_] := Expand[a.metric.b];
pTrial = {ep, 0, 0, ep}; qTrial = {0, 0, 0, -Q}; kTrial = {ek, Sqrt[kxSquared], 0, kz};
frameEquations = {dot4[pTrial + qTrial, pTrial + qTrial] == s,
  dot4[qTrial - kTrial, qTrial - kTrial] == t, dot4[kTrial, kTrial] == 0,
  dot4[pTrial + qTrial - kTrial, pTrial + qTrial - kTrial] == s23};
frameSolutions = Solve[frameEquations, {ep, ek, kz, kxSquared}];
gate["unique real frame", Length[frameSolutions] === 1 && FreeQ[frameSolutions, _ConditionalExpression]];
frameRules = First[frameSolutions];
realFrame = <|p -> simplify[pTrial /. frameRules], q -> qTrial, k1 -> simplify[kTrial /. frameRules],
  eL -> {1, 0, 0, 0}, eX -> {0, 1, 0, 0}, eY -> {0, 0, 1, 0}|>;
realOutZ = simplify[Rest[realFrame[k1]]/First[realFrame[k1]]];
AssociateTo[realFrame, {eOutX -> Prepend[simplify[Cross[{0, 1, 0}, realOutZ]], 0], eOutY -> {0, 0, 1, 0}}];
gate["real frame defining equations", And @@ simplify[frameEquations /. frameRules]];
rootRules = <|"PDF" -> {eta -> incomingRoot, zeta -> 1}, "FF" -> {eta -> 1, zeta -> outgoingRoot}|>;
mapRules = AssociationMap[Thread[{s, t} -> (Lookup[invariants, {"s", "t"}] /. rootRules[#])] &, Keys[rootRules]];
Do[mappedFrame = borns[key]["Frame"] /. mapRules[side];
  gate[key <> " " <> side <> " mapped physical momenta", zeroArray[simplify[
    {mappedFrame[p] - (eta realFrame[p] /. rootRules[side]), mappedFrame[q] - realFrame[q],
      mappedFrame[k1] - (realFrame[k1]/zeta /. rootRules[side])}]]];
  gate[key <> " " <> side <> " fixed photon and spin axes", zeroArray[simplify[
    (mappedFrame /@ {eL, eX, eY, eOutX, eOutY}) - (realFrame /@ {eL, eX, eY, eOutX, eOutY})]]],
  {key, coreChannels}, {side, Keys[rootRules]}];
measureWeights = <|"PDF" -> incomingJacobian/incomingRoot, "FF" -> outgoingJacobian/outgoingRoot^2|>;
roots = <|"PDF" -> incomingRoot, "FF" -> outgoingRoot|>;
routes = {};
Do[If[Last[species[key]] === Last[species[channel]], kernelKey = First[species[channel]] <> First[species[key]];
    If[KeyExistsQ[kernelInput["Responses"], kernelKey], AppendTo[routes,
      <|"Side" -> "PDF", "BornChannel" -> key, "KernelKey" -> kernelKey|>]]];
  If[First[species[key]] === First[species[channel]], kernelKey = Last[species[key]] <> Last[species[channel]];
    If[KeyExistsQ[kernelInput["Responses"], kernelKey], AppendTo[routes,
      <|"Side" -> "FF", "BornChannel" -> key, "KernelKey" -> kernelKey|>]]], {key, coreChannels}];
Do[route = routes[[index]]; key = route["BornChannel"]; refKernel = kernelInput["Responses"][route["KernelKey"]]["ReferenceKernel"];
  If[KeyExistsQ[reference, "Routes"], matches = Select[reference["Routes"],
      #["Side"] === route["Side"] && #["Kernel"] === refKernel &&
        ({#["Incoming"], #["Observed"]} /. {quark -> "q", gluon -> "g"}) === species[key] &];
    gate["unique inherited subtraction route", Length[matches] === 1];
    refName = StringRiffle[Lookup[First[matches], {"Side", "Born", "Kernel"}], "_"],
    refName = If[route["Side"] === "PDF", "PDF", If[Last[species[key]] === "g", "GluonFragmentation", "QuarkFragmentation"]]];
  routes[[index]] = Append[route, "ReferenceName" -> refName], {index, Length[routes]}];
gate["complete reference route inventory", Sort[Lookup[routes, "ReferenceName"]] === Sort[Keys[reference["ConvolutionsD"]["Pg"]]]];
Do[gate["same kernel normalization " <> kernelKey, zero[
  kernelInput["Responses"][kernelKey]["Kernel"][[uPosition, uPosition]] -
    (reference["Kernels"][kernelInput["Responses"][kernelKey]["ReferenceKernel"]] /. x -> z)]] ,
  {kernelKey, DeleteDuplicates[Lookup[routes, "KernelKey"]]}];

endpointBranchComparisons = {};
convolution[bornEndpoint_, kernel_, rootValue_, weight_] := Module[{expandedKernel, plusCoefficient,
  deltaCoefficient, regularKernel, poleFunction, endpointCoefficient, endpointRatio,
  mappedDelta, result, endpointDifference, endpointProof},
  expandedKernel = Expand[kernel /. {kernelPlus[1/(1 - x)] -> p0, kernelDelta[1 - x] -> d0}];
  plusCoefficient = Coefficient[expandedKernel, p0];
  deltaCoefficient = Coefficient[expandedKernel, d0];
  regularKernel = expandedKernel /. {p0 -> 0, d0 -> 0};
  If[plusCoefficient =!= 0,
    poleFunction = Factor[weight/(1 - rootValue)];
    endpointCoefficient = FullSimplify[Limit[s23 poleFunction, s23 -> 0], endpointRegion];
    endpointRatio = FullSimplify[Limit[(1 - rootValue)/s23, s23 -> 0], endpointRegion];
    gate["plus mapping has a positive endpoint scale", FullSimplify[endpointRatio > 0, endpointRegion]];
    endpointDifference = Factor[endpointCoefficient - bornEndpoint];
    endpointProof = FullSimplify[endpointDifference, endpointRegion];
    If[endpointProof =!= 0, endpointProof = FullSimplify[
      PowerExpand[endpointDifference, Assumptions -> endpointRegion], endpointRegion]];
    If[endpointDifference =!= 0, AppendTo[endpointBranchComparisons,
      <|"BornEndpoint" -> bornEndpoint, "MappedEndpoint" -> endpointCoefficient,
        "Difference" -> endpointDifference, "PhysicalRegionDifference" -> endpointProof|>];
      Print["ENDPOINT_BRANCH_COMPARISON ", InputForm[endpointProof]]];
    gate["auxiliary endpoint pole cancels", endpointProof === 0];
    endpointCoefficient = bornEndpoint;
    mappedDelta = FullSimplify[Normal[Series[
      (B^lambdaCut endpointRatio^lambdaCut endpointCoefficient - bornEndpoint)/lambdaCut,
      {lambdaCut, 0, 0}]], endpointRegion],
    poleFunction = 0; endpointCoefficient = 0; mappedDelta = 0];
  gate["auxiliary endpoint regulator removed", FreeQ[mappedDelta, lambdaCut]];
  result = <|"Delta" -> Factor[deltaCoefficient bornEndpoint + plusCoefficient mappedDelta],
    "L0" -> Factor[plusCoefficient endpointCoefficient],
    "Regular" -> Factor[weight (regularKernel /. x -> rootValue) +
      plusCoefficient (poleFunction - endpointCoefficient/s23)]|>;
  gate["mapped convolution reconstructs its ordinary part", zero[FullSimplify[result["Regular"] +
    result["L0"]/s23 - weight (kernel /. {kernelDelta[_] -> 0, kernelPlus[a_] :> a} /. x -> rootValue), physical]]];
  result];


distributions = {"Delta", "L0", "Regular"};
(* Check the adapted convolution interface on every saved reference route. *)
referenceChecks = <||>;
Do[key = route["BornChannel"]; side = route["Side"]; refName = route["ReferenceName"];
  unpolarizedKernel = kernelInput["Responses"][route["KernelKey"]]["Kernel"][[uPosition, uPosition]] /. z -> x;
  Do[endpoint = borns[key][If[mode === "Pg", "CDRBornPg", "CDRBornPpp"]];
    weight = Factor[measureWeights[side] (endpoint /. mapRules[side]) If[mode === "Ppp" && side === "PDF",
      reference["IncomingProjectorScale"] /. rootRules[side], 1]];
    converted = bounded[convolution[endpoint, unpolarizedKernel, roots[side], weight], {refName, mode, "reference"}];
    gate[refName <> " distribution inventory", Keys[converted] === Keys[reference["ConvolutionsD"][mode][refName]]];
    differences = Values[converted] - Values[reference["ConvolutionsD"][mode][refName] /. Q2 -> Q^2];
    gate[refName <> " " <> mode <> " original convolution", zeroArray[FullSimplify[differences, endpointRegion && s23 > 0]]];
    AssociateTo[referenceChecks, refName <> "_" <> mode -> True], {mode, {"Pg", "Ppp"}}], {route, routes}];
completionPath = FileNameJoin[{root, "Hqqprime", "s11_dimensional_result", "s11_result.wl"}];
completionSource = FileNameJoin[{root, "common", "s11_check_dimensional_convolution.wls"}];
completionBaseline = FileNameJoin[{root, "common", "s11_result", "reference", "s11_small_collinear_spin_before_dimensional.wls"}];
gate["accepted dimensional completion identity", IntegerString[FileHash[completionPath, "SHA256"], 16, 64] ===
  "3c76ab221bf3c99ba7c35223b26ca10ec527596dc2f60307d5cc7e508dbc411c"];
completionProof = Get[completionPath];
gate["executed intermediate-state completion", TrueQ[completionProof["Accepted"]] &&
  TrueQ[completionProof["RestoresReferenceHats"]] && And @@ Values[completionProof["Checks"]] &&
  completionProof["SourceHash"] === FileHash[completionSource, "SHA256"] &&
  completionProof["BaselineSourceHash"] === FileHash[completionBaseline, "SHA256"] &&
  completionProof["NativeVersions"] === {$Version, $FeynCalcVersion}];
DownValues[completeIntermediateBorn] = completionProof["Definitions"];
coreBaseline = FileNameJoin[{root, "common", "s11_result", "reference", "s11_collinear_spin_convolutions_before_dimensional.wls"}];
previousPath = FileNameJoin[{root, channel, "s11_result", "reference", "before_dimensional_completion", "s11_result.wl"}];
previous = Get[previousPath];
gate["archived previous subtraction", previous["Channel"] === channel && And @@ Values[previous["Checks"]] &&
  previous["SourceHash"] === FileHash[coreBaseline, "SHA256"] && previous["Routes"] === routes];
Do[gate["unchanged inherited subtraction input " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === previous["InputHashes"][name]],
  {name, Keys[previous["InputHashes"]]}];
additionalPaths = Join[additionalPaths, {FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}], completionPath, completionSource, completionBaseline, coreBaseline, previousPath}];
photonLabels = borns[channel]["PhotonLabels"];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = DeleteDuplicates[Join[{configPath, baseConfigPath, kernelPath}, additionalPaths,
  FileNameJoin[{root, #}] & /@ Values[referenceRow]]];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s11", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
contributions = <||>; evanescentContributions = <||>; completedStates = <||>;
Do[key = route["BornChannel"]; side = route["Side"]; refName = route["ReferenceName"];
  completedBorn = completeIntermediateBorn[borns[key], side];
  gate[refName <> " physical D4 Born unchanged", zeroArray[
    (Take[completedBorn["Response"], Length[photonLabels]] - borns[key]["Response"]) /. D -> 4]];
  AssociateTo[completedStates, refName -> KeyDrop[completedBorn, "Response"]];
  file = FileNameJoin[{cache, refName <> ".wl"}]; saved = If[FileExistsQ[file], Get[file], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["SPIN_CONVOLUTION ", channel, " ", refName];
    bornResponse = completedBorn["Response"];
    mappedResponse = bounded[simplify[bornResponse /. mapRules[side]], {refName, "mapped Born"}];
    kernelMatrix = kernelInput["Responses"][route["KernelKey"]]["Kernel"] /. z -> x;
    reusePhysical = completedBorn["IntermediateLabels"] === labels;
    If[reusePhysical, gate[refName <> " unchanged dimensional physical Born",
      zeroArray[Take[bornResponse, Length[photonLabels]] - borns[key]["Response"]]]];
    pieces = Table[If[reusePhysical && a <= Length[photonLabels],
      Association@Table[d -> previous["RouteConvolutionsD"][refName][d][[a, j, i]], {d, distributions}],
      terms = Table[
      kernel = If[side === "PDF", kernelMatrix[[k, i]], kernelMatrix[[j, k]]];
      endpoint = If[side === "PDF", bornResponse[[a, j, k]], bornResponse[[a, k, i]]];
      mapped = If[side === "PDF", mappedResponse[[a, j, k]], mappedResponse[[a, k, i]]];
      If[kernel === 0 || (endpoint === 0 && mapped === 0), AssociationThread[distributions, ConstantArray[0, Length[distributions]]],
        bounded[convolution[endpoint, kernel, roots[side], simplify[measureWeights[side] mapped]], {refName, a, j, i, k}]],
      {k, Length[labels]}]; Merge[terms, Factor[Total[#]] &]],
      {a, Length[bornResponse]}, {j, Length[labels]}, {i, Length[labels]}];
    value = Association@Table[distribution -> Map[#[distribution] &, pieces, {3}], {distribution, distributions}];
    gate[refName <> " exact evaluated spin convolution", FreeQ[value,
      _Missing | _Integrate | _Limit | _Series | _SeriesData | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
    saved = <|"InputHash" -> inputHash, "Route" -> route, "ConvolutionsD" -> value|>; put[saved, file]];
  AssociateTo[evanescentContributions, refName -> Map[Last, saved["ConvolutionsD"]]];
  AssociateTo[contributions, refName -> Map[Take[#, Length[photonLabels]] &, saved["ConvolutionsD"]]];
  If[completedBorn["IntermediateLabels"] === labels,
    gate[refName <> " physical route without dimensional intermediate unchanged",
      zeroArray[Flatten[(Values[contributions[refName]] - Values[previous["RouteConvolutionsD"][refName]])]]]], {route, routes}];
convolutionsD = Association@Table[distribution -> Map[Factor, Total[#[distribution] & /@ Values[contributions]], {3}],
  {distribution, distributions}];
If[FreeQ[species[channel], "g"],
  basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
  spinBasis = Get[basisPath];
  gate["accepted contraction basis", And @@ Values[spinBasis["Checks"]]];
  metricWeights = Tr[spinBasis["PhotonMetric"].#] & /@ spinBasis["PhotonBasis"];
  pComponents = Take[LinearSolve[Transpose[realFrame /@ {eL, eX, eY, q}], realFrame[p]], Length[{eL, eX, eY}]];
  pWeights = Factor[pComponents.#.pComponents] & /@ spinBasis["PhotonBasis"];
  Do[value = contributions[route["ReferenceName"]][distribution];
    completedScalar = {metricWeights.value[[All, uPosition, uPosition]] +
      evanescentContributions[route["ReferenceName"]][distribution][[uPosition, uPosition]],
      pWeights.value[[All, uPosition, uPosition]]};
    referenceScalar = Table[reference["ConvolutionsD"][mode][route["ReferenceName"]][distribution] /. Q2 -> Q^2,
      {mode, {"Pg", "Ppp"}}];
    gate[route["ReferenceName"] <> " " <> distribution <> " actual spin convolution reconstructs dimensional reference",
      bounded[zeroArray[FullSimplify[completedScalar - referenceScalar, endpointRegion && s23 > 0]],
        {route["ReferenceName"], distribution, "actual reference contraction"}]],
    {route, routes}, {distribution, distributions}]];
msPole = 1/eps - EulerGamma + Log[4 Pi];
counterterms = Association@Table[distribution -> Map[
  bounded[Normal[Series[reference["Prefactor"] msPole (# /. D -> 4 - 2 eps), {eps, 0, 0}]],
    {distribution, "epsilon expansion"}] &, convolutionsD[distribution], {3}], {distribution, distributions}];
gate["all subtraction coefficients evaluated", FreeQ[counterterms,
  _Missing | _Series | _SeriesData | _Limit | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
countertermDifference = Association@Table[distribution -> Map[Factor,
  counterterms[distribution] - previous["Counterterms"][distribution], {3}], {distribution, distributions}];
gate["intermediate completion changes no regulator pole", FreeQ[countertermDifference, eps | D]];
result = <|"Schema" -> "polarized-sidis-collinear-convolutions-v1", "Channel" -> channel,
  "PhotonLabels" -> borns[channel]["PhotonLabels"], "SpinLabels" -> labels,
  "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"},
  "Routes" -> routes, "RouteConvolutionsD" -> contributions, "ConvolutionsD" -> convolutionsD,
  "IntermediateStateConvention" -> "CDR U/E completeness and incoming CDR averaging; physical resolved spin labels",
  "IntermediateStateCompletions" -> completedStates, "EvanescentPhotonConvolutionsD" -> evanescentContributions,
  "DimensionalCompletionValidationHash" -> FileHash[completionPath, "SHA256"],
  "PreviousSubtractionHash" -> FileHash[previousPath, "SHA256"], "CountertermDifference" -> countertermDifference,
  "Counterterms" -> counterterms, "ReferenceConvolutionChecks" -> referenceChecks,
  "EndpointBranchComparisons" -> endpointBranchComparisons,
  "IncomingRoot" -> incomingRoot, "OutgoingRoot" -> outgoingRoot,
  "IncomingJacobian" -> incomingJacobian, "OutgoingJacobian" -> outgoingJacobian,
  "ScaledInvariantRules" -> mapRules, "Prefactor" -> reference["Prefactor"], "MSPole" -> msPole,
  "PlusDefinition" -> reference["PlusDefinition"], "HardTensorNormalization" -> reference["HardTensorNormalization"],
  "Gamma5Scheme" -> "BMHV", "FiniteAxialSchemeConversionApplied" -> False,
  "CompletePoleCancellationChecked" -> False, "FiniteNLOFHatsComputed" -> False,
  "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s11_result"}];
put[result, FileNameJoin[{resultDir, "s11_result.wl"}]];
Export[FileNameJoin[{resultDir, "s11_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s11_collinear_spin_convolutions"]; Quit[0];

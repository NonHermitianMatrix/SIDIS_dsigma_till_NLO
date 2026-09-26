(* Regular spin-matrix subtraction for the pinned real-only channels. *)
$HistoryLength = 0; root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s11_small_collinear_spin.wls"}];
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
configPath = FileNameJoin[{root, "common", "s11_small_inputs.json"}];
auxConfigPath = FileNameJoin[{root, "common", "s03_auxiliary_inputs.json"}];
kernelPath = FileNameJoin[{root, "common", "s10_result", "s10_result.wl"}];
config = Import[configPath, "RawJSON"]; auxConfig = Import[auxConfigPath, "RawJSON"];
gate["supported subtraction channel", KeyExistsQ[config["channels"], channel]];
referenceRow = config["channels"][channel];
inputPaths = FileNameJoin[{root, #}] & /@ Values[referenceRow];
pinned[relative_] := gate["pinned " <> relative, IntegerString[
  FileHash[FileNameJoin[{root, relative}], "SHA256"], 16, 64] ===
  SelectFirst[config["files"], #["destination"] === relative &]["sha256"]];
Scan[pinned, Values[referenceRow]];
reference = Get[FileNameJoin[{root, referenceRow["result"]}]];
gate["accepted original subtraction and source bindings", reference["AcceptedSubtractionInputs"] &&
  reference["Channel"] === channel && reference["SourceHash"] ===
    FileHash[FileNameJoin[{root, referenceRow["assembly_source"]}], "SHA256"] &&
  reference["PreservedSourceHash"] === FileHash[FileNameJoin[{root, referenceRow["source"]}], "SHA256"]];
kernels = Get[kernelPath];
gate["accepted spin kernels", kernels["Schema"] === "polarized-sidis-collinear-kernels-v1" && And @@ Values[kernels["Checks"]]];
labels = kernels["SpinLabels"]; uPosition = First[FirstPosition[labels, "U"]];
bornOwners = <|"qg" -> {channel, "qg"}, "gq" -> {channel, "gq"}|>;
If[channel === "Hgg", AssociateTo[bornOwners, {"aqg" -> {channel, "aqg"}, "gaq" -> {"Hqqbar", "gq"}}]];
borns = <||>; species = <||>;
Do[owner = bornOwners[key]; path = FileNameJoin[{root, First[owner], "s03_result", Last[owner], "s03_result.wl"}];
  born = Get[path]; AppendTo[inputPaths, path];
  gate[key <> " accepted auxiliary Born", born["Schema"] === "polarized-sidis-auxiliary-born-response-v1" &&
    born["Channel"] === First[owner] && born["AuxiliaryRoute"] === Last[owner] && And @@ Values[born["Checks"]]];
  incoming = If[MemberQ[born["ExtendedIncomingLabels"], "E"], "g", If[MemberQ[born["AntifermionMomenta"], p], "aq", "q"]];
  outgoing = If[MemberQ[born["ExtendedOutgoingLabels"], "E"], "g", If[MemberQ[born["AntifermionMomenta"], k1], "aq", "q"]];
  AssociateTo[species, key -> {incoming, outgoing}]; AssociateTo[borns, key -> born], {key, Keys[bornOwners]}];
bornKeys = Keys[borns]; photonLabels = borns[First[bornKeys]]["PhotonLabels"];
gate["shared spin and photon bases", AllTrue[Values[borns], #["SpinLabels"] === labels && #["PhotonLabels"] === photonLabels &]];
If[channel === "Hgg", gate["native charge-conjugate routes", species["aqg"] === {"aq", "g"} && species["gaq"] === {"g", "aq"}];
  gate["charge-conjugate CDR Born normalizations", zeroArray[
    Lookup[borns["aqg"], {"CDRBornPg", "CDRBornPpp"}] - Lookup[borns["qg"], {"CDRBornPg", "CDRBornPpp"}]] &&
    zeroArray[Lookup[borns["gaq"], {"CDRBornPg", "CDRBornPpp"}] - Lookup[borns["gq"], {"CDRBornPg", "CDRBornPpp"}]]]];
realGenerated = Get[FileNameJoin[{root, referenceRow["real_amplitudes"]}]];
realFermions = DeleteDuplicates[Cases[realGenerated["amplitudes"], Spinor[sign_. Momentum[mom_, ___], ___] :> mom, Infinity]];
realAntifermions = DeleteDuplicates[Cases[realGenerated["amplitudes"], Spinor[-Momentum[mom_, ___], ___] :> mom, Infinity]];
realSpecies = (If[!MemberQ[realFermions, #], "g", If[MemberQ[realAntifermions, #], "aq", "q"]] &) /@ {p, k1};
flows = reference["FactorizationMetadata"]["flows"] /. {quark -> "q", antiquark -> "aq", gluon -> "g"};
routes = {};
Do[
  If[Last[species[key]] === Last[realSpecies] && MemberQ[flows, First[species[key]]],
    AppendTo[routes, <|"Name" -> "PDF_" <> key, "Side" -> "PDF", "Born" -> key,
      "Kernel" -> First[realSpecies] <> First[species[key]]|>]];
  If[First[species[key]] === First[realSpecies] && MemberQ[flows, Last[species[key]]],
    AppendTo[routes, <|"Name" -> "FF_" <> key, "Side" -> "FF", "Born" -> key,
      "Kernel" -> Last[species[key]] <> Last[realSpecies]|>]], {key, bornKeys}];
routedFlows = Association@Table[side -> Sort[(If[side === "PDF",
  First[species[#["Born"]]], Last[species[#["Born"]]]] &) /@
  Select[routes, #["Side"] === side &]], {side, {"PDF", "FF"}}];
gate["all inherited flavor flows represented once per side", And @@ Table[
  routedFlows[side] === Sort[flows], {side, {"PDF", "FF"}}]];
gate["all route kernels available", AllTrue[routes, KeyExistsQ[kernels["Responses"], #["Kernel"]] &]];
gate["off-diagonal routes have ordinary kernels", FreeQ[
  Lookup[kernels["Responses"], Lookup[routes, "Kernel"]], _kernelPlus | _kernelDelta]];
rawBorns = Association@Table[route -> Module[{relative = auxConfig["channels"][channel][route]["unpolarized_born_file"]},
  pinned[relative]; AppendTo[inputPaths, FileNameJoin[{root, relative}]]; Get[FileNameJoin[{root, relative}]]], {route, {"qg", "gq"}}];
couplingPowers = DeleteDuplicates[(Exponent[Numerator[Together[#]], gs] - Exponent[Denominator[Together[#]], gs]) & /@
  Select[Flatten[Values /@ Values[rawBorns]], # =!= 0 &]];
gate["one inherited Born coupling power", Length[couplingPowers] === 1 && IntegerQ[First[couplingPowers]]];
bornCoupling = gs^First[couplingPowers];
gate["removed Born coupling reconstructs every input", FreeQ[Values[Map[Map[Cancel[#/bornCoupling] &], rawBorns]], gs]];
physical = Q > 0 && s > s23 > 0 && s23 - Q^2 - s < t < -Q^2 s23/s && B > 0 && SUNN > 1;
endpointRegion = Q > 0 && s > 0 && -Q^2 - s < t < 0 && B > 0 && SUNN > 1;
simplify[value_] := FullSimplify[value, Assumptions -> physical];
kin = Get[FileNameJoin[{root, referenceRow["kinematics"]}]];
gate["reference scalar-input identities", reference["InputHashes"]["kinematics.wl"] ===
  FileHash[FileNameJoin[{root, referenceRow["kinematics"]}], "SHA256"] && And @@ Table[
  reference["InputHashes"]["born_" <> route <> ".wl"] === FileHash[
    FileNameJoin[{root, auxConfig["channels"][channel][route]["unpolarized_born_file"]}], "SHA256"], {route, {"qg", "gq"}}]];
FCClearScalarProducts[]; DataType[eta, FCVariable] = True; DataType[zeta, FCVariable] = True;
Do[With[{a = kin["momenta"][[i]], b = kin["momenta"][[j]], value = kin["gram"][[i, j]] /. {Q2 -> Q^2, w -> s23}},
  SPD[a, b] = value], {i, Length[kin["momenta"]]}, {j, Length[kin["momenta"]]}];
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
meta = reference["FactorizationMetadata"] /. {Q2 -> Q^2, w -> s23, Nc -> SUNN};
gate["exact original roots and Jacobians", zeroArray[
  {incomingRoot, outgoingRoot, incomingJacobian, outgoingJacobian} -
  Join[Lookup[meta, {"xi", "zeta"}], 1/meta["jacobians"]]]];
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
  {key, bornKeys}, {side, Keys[rootRules]}];
measureWeights = <|"PDF" -> incomingJacobian/incomingRoot, "FF" -> outgoingJacobian/outgoingRoot^2|>;
roots = <|"PDF" -> incomingRoot, "FF" -> outgoingRoot|>;

referenceConvolutions = Association@Table[mode -> Factor[Total[Table[
  key = route["Born"]; side = route["Side"];
  endpoint = borns[key][If[mode === "g", "CDRBornPg", "CDRBornPpp"]];
  unpolarizedKernel = kernels["Responses"][route["Kernel"]]["Kernel"][[uPosition, uPosition]];
  measureWeights[side] bornCoupling (endpoint /. mapRules[side]) (unpolarizedKernel /. z -> roots[side])
    If[mode === "pp" && side === "PDF", incomingRoot^-2, 1], {route, routes}]]], {mode, {"g", "pp"}}];
Do[gate[mode <> " original full-dimensional convolution", zero[referenceConvolutions[mode] -
  (reference["Convolutions"][mode] /. {Q2 -> Q^2, w -> s23, Nc -> SUNN})]], {mode, {"g", "pp"}}];
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
previousPath = FileNameJoin[{root, channel, "s11_result", "reference", "before_dimensional_completion", "s11_result.wl"}];
previous = Get[previousPath];
gate["archived previous subtraction", previous["Channel"] === channel && And @@ Values[previous["Checks"]] &&
  previous["SourceHash"] === FileHash[completionBaseline, "SHA256"] && previous["Routes"] === routes];
inputPaths = Join[inputPaths, {completionPath, completionSource, completionBaseline, previousPath}];
contributions = <||>; evanescentContributions = <||>; completedStates = <||>;
Do[key = route["Born"]; side = route["Side"];
  Print["SPIN_CONVOLUTION ", channel, " ", route["Name"]];
  completedBorn = completeIntermediateBorn[borns[key], side];
  gate[route["Name"] <> " physical D4 Born unchanged", zeroArray[
    (Take[completedBorn["Response"], Length[photonLabels]] - borns[key]["Response"]) /. D -> 4]];
  mapped = bounded[simplify[completedBorn["Response"] /. mapRules[side]], {key, side, "mapped Born"}];
  kernelMatrix = kernels["Responses"][route["Kernel"]]["Kernel"] /. z -> roots[side];
  value = bounded[Map[Factor, measureWeights[side] If[side === "PDF",
    (Dot[#, kernelMatrix] & /@ mapped), (Dot[kernelMatrix, #] & /@ mapped)], {3}], route["Name"]];
  gate[route["Name"] <> " evaluated spin convolution", FreeQ[value,
    _Missing | _Dot | _Integrate | _Limit | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
  endpointResidues = bounded[FullSimplify[Limit[s23 value, s23 -> 0], endpointRegion], {route["Name"], "endpoint"}];
  gate[route["Name"] <> " no soft endpoint pole", zeroArray[endpointResidues]];
  AssociateTo[completedStates, route["Name"] -> KeyDrop[completedBorn, "Response"]];
  AssociateTo[evanescentContributions, route["Name"] -> Last[value]];
  AssociateTo[contributions, route["Name"] -> Take[value, Length[photonLabels]]], {route, routes}];
regular = Map[Factor, Total[Values[contributions]], {3}];
If[FreeQ[realSpecies, "g"],
  basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
  spinBasis = Get[basisPath]; AppendTo[inputPaths, basisPath];
  gate["accepted contraction basis", And @@ Values[spinBasis["Checks"]]];
  metricWeights = Tr[spinBasis["PhotonMetric"].#] & /@ spinBasis["PhotonBasis"];
  pComponents = Take[LinearSolve[Transpose[realFrame /@ {eL, eX, eY, q}], realFrame[p]], Length[{eL, eX, eY}]];
  pWeights = Factor[pComponents.#.pComponents] & /@ spinBasis["PhotonBasis"];
  completedScalar = bornCoupling {metricWeights.regular[[All, uPosition, uPosition]] +
    Total[Values[evanescentContributions]][[uPosition, uPosition]], pWeights.regular[[All, uPosition, uPosition]]};
  gate["actual completed spin convolutions reproduce both dimensional references",
    zeroArray[completedScalar - Lookup[referenceConvolutions, {"g", "pp"}]]]];
zeros = ConstantArray[0, Dimensions[regular]];
convolutionsD = <|"Delta" -> zeros, "L0" -> zeros, "Regular" -> regular|>;
phaseCT = reference["PhaseCT"];
regularCounterterm = Map[bounded[Normal[Series[phaseCT bornCoupling (# /. D -> 4 - 2 eps),
  {eps, 0, 0}]], "counterterm Laurent expansion"] &, regular, {3}];
counterterms = <|"Delta" -> zeros, "L0" -> zeros, "Regular" -> regularCounterterm|>;
countertermDifference = Map[Factor, counterterms["Regular"] - previous["Counterterms"]["Regular"], {3}];
gate["intermediate completion changes no regulator pole", FreeQ[countertermDifference, eps | D]];
If[channel === "Hqqprime", gate["complete counterterm correction equals executed comparison",
  zeroArray[countertermDifference - completionProof["CountertermCorrection"]]]];
If[AllTrue[Values[completedStates], #["IntermediateLabels"] === labels &],
  gate["routes without dimensional intermediate states remain exactly unchanged", zeroArray[countertermDifference]]];
gate["all subtraction coefficients evaluated", FreeQ[counterterms,
  _Missing | _Series | _SeriesData | _Limit | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
inputPaths = DeleteDuplicates[Join[{configPath, auxConfigPath, kernelPath}, inputPaths]];
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
result = <|"Schema" -> "polarized-sidis-small-collinear-convolutions-v1", "Channel" -> channel,
  "PhotonLabels" -> photonLabels, "SpinLabels" -> labels,
  "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"},
  "Routes" -> routes, "NativeSpecies" -> species, "RealSpecies" -> realSpecies, "InheritedFlows" -> flows,
  "RouteConvolutionsD" -> contributions, "ConvolutionsD" -> convolutionsD, "Counterterms" -> counterterms,
  "ReferenceConvolutions" -> referenceConvolutions, "PhaseCT" -> phaseCT, "BornCoupling" -> bornCoupling,
  "IntermediateStateConvention" -> "CDR U/E completeness and incoming CDR averaging; physical resolved spin labels",
  "IntermediateStateCompletions" -> completedStates, "EvanescentPhotonConvolutionsD" -> evanescentContributions,
  "DimensionalCompletionValidationHash" -> FileHash[completionPath, "SHA256"],
  "PreviousSubtractionHash" -> FileHash[previousPath, "SHA256"], "CountertermDifference" -> countertermDifference,
  "CountertermsIncludePhaseAndCouplings" -> True, "IncomingRoot" -> incomingRoot, "OutgoingRoot" -> outgoingRoot,
  "IncomingJacobian" -> incomingJacobian, "OutgoingJacobian" -> outgoingJacobian, "ScaledInvariantRules" -> mapRules,
  "Gamma5Scheme" -> "BMHV", "FiniteAxialSchemeConversionApplied" -> False,
  "CompletePoleCancellationChecked" -> False, "FiniteNLOFHatsComputed" -> False,
  "SourceHash" -> FileHash[sourcePath, "SHA256"], "InputHashes" -> inputHashes,
  "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s11_result"}];
put[result, FileNameJoin[{resultDir, "s11_result.wl"}]];
Export[FileNameJoin[{resultDir, "s11_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s11_small_collinear_spin"]; Quit[0];

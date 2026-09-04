(* Hqq_v2 S05: exact angular Laurent series and bounded s23 endpoints. *)

ClearAll["Global`*"];
$HistoryLength = 0;

ClearAll[fail, require, atomicPut];
fail[message_, detail_: Null] := (
  Print["S05_FAILURE: ", message];
  If[detail =!= Null, Print["S05_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
atomicPut[expression_, path_String] := Module[{temporary = path <> ".tmp"},
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Put[expression, temporary];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary result is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"]
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = FileNameJoin[{stageDirectory, "s05_expand_hqq_endpoints.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s05_result.wl"}];
masterCachePath = FileNameJoin[{stageDirectory, "s05_master_cache.wl"}];
rootGroupCachePath = FileNameJoin[
  {stageDirectory, "s05_root_group_cache.wl"}];
rootGroupCacheV2Path = FileNameJoin[
  {stageDirectory, "s05_root_group_cache_v2.wl"}];
directEndpointCacheRoot = FileNameJoin[
  {stageDirectory, "s05_endpoint_cache", "pg_same_epsilon_1"}];
coefficientCacheRoot = FileNameJoin[
  {stageDirectory, "s05_coefficient_cache"}];
s04SourcePath = FileNameJoin[{stageDirectory,
    "s04_integrate_hqq_phase_space.wl"}];
s04ResultPath = FileNameJoin[{stageDirectory, "s04_result.wl"}];
hyperInticaPath = FileNameJoin[{stageDirectory, "vendor",
    "SubTropicaHyperIntica", "HyperIntica.wl"}];
localKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel";
hoffmanKernelExecutable =
  "/u/local/apps/mathematica/15/15.0/Executables/WolframKernel";
kernelExecutable = SelectFirst[
  {localKernelExecutable, hoffmanKernelExecutable}, FileExistsQ,
  Missing["NoSupportedWolframKernel"]];
require[StringQ[kernelExecutable],
  "no supported Wolfram kernel executable is available"];
useDefaultAssemblyKernelLaunch =
  TrueQ[kernelExecutable === hoffmanKernelExecutable];
runtimeKernelVersion = $VersionNumber;

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
expectedS04SourceHash =
  "ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793";
expectedS04ResultHash =
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c";
expectedHyperInticaHash =
  "252acac91a7cb87c7334f2c7227a4c7aeea7bfc2c3b53c58f9fb28a4a6b284d5";
expectedHyperInticaCommit = "adfd3af3be234cb43a2322bd9ec442caa26edd74";
expectedRootGroupCacheHash =
  "e9c4c488cc1fccb76b9dd3bba81204880bb4a215e038f199a5e239749f05f3fc";
expectedRootGroupCacheProducerHash =
  "0bb0f138ef964a07dcb6d92e833d692353dea8fa7b708a4867bfa8d0c48f7c7f";
expectedRootGroupCacheV2Hash =
  "261a3634646d151724fcc98a434d908cd4b350248db2d9bac251b316da5bf585";
expectedRootGroupCacheV2ProducerHash =
  "e2e4d40d77eba4a801cd1d3b5bc7eddf7335e3a9fddd769c038c3f5ca6c00ddd";
acceptedDirectEndpointCacheParentProducerHashes = {
  "641a2d0e13c04395363ddf0c7825a51a85a1390f08515d3e363550cee90f78ab",
  "522a4ecba111e1e2b374237921d179a92bc9e1126f9e9a075bac2fad09134246",
  "c40dbddcc694bbfcdb3bc78a4ded23de622b65860ff0fcad3cb1383d95999e5f"};
acceptedMasterCacheProducerHashes = {
  "a05ccceac3f7cbef19e6ca72513382cdf17d70d3a78f7415998e8a5e2c428af8"};
acceptedCoefficientCacheProducerHashes = {
  "68f905e9de1e12efb6dd1803a446f6e73d87ee772114dd14ccd5e9108980178a",
  "9a0ed02258b858a27618704fdbd7da7b53921e2469ef35f1026ad1eb7ca0c712"};
acceptedCoefficientCacheAlgorithms = {
  "Normal-Series-epsilon-0-through-2-and-phase-convolution-v1",
  "Termwise-Normal-Series-epsilon-0-through-2-and-phase-convolution-v2",
  "Rational-Coefficient-and-inverse-denominator-Series-v3"};
probeMode = Environment["HQQV2_S05_PROBE"] === "1";
taskPlanMode = Environment["HQQV2_S05_TASK_PLAN"] === "1";
rootSubsetDiagnosticMode =
  Environment["HQQV2_S05_ROOT_SUBSET_DIAGNOSTIC"] === "1";
rootGroupCacheOnlyMode =
  Environment["HQQV2_S05_ROOT_GROUP_CACHE_ONLY"] === "1";
startupProbeMode =
  Environment["HQQV2_S05_STARTUP_PROBES"] === "1";
modeFlags = {probeMode, taskPlanMode, rootSubsetDiagnosticMode,
  startupProbeMode};
require[Total[Boole /@ modeFlags] <= 1,
  "S05 execution modes are not mutually exclusive", modeFlags];
require[! rootGroupCacheOnlyMode || rootSubsetDiagnosticMode,
  "S05 root-group cache-only submode requires root diagnostic mode"];
require[! rootGroupCacheOnlyMode,
  "accepted root-group cache is immutable; use its pinned producer source"];
s05ModeLabel = Which[
  probeMode, "representative-probe",
  taskPlanMode, "task-plan",
  rootSubsetDiagnosticMode, "root-subset-diagnostic",
  startupProbeMode, "startup-probes",
  True, "production"];

require[FileHash[s04SourcePath, "SHA256", "HexString"] ===
    expectedS04SourceHash, "accepted S04 source hash mismatch"];
require[FileHash[s04ResultPath, "SHA256", "HexString"] ===
    expectedS04ResultHash, "accepted S04 result hash mismatch"];
require[FileHash[hyperInticaPath, "SHA256", "HexString"] ===
    expectedHyperInticaHash, "pinned HyperIntica hash mismatch"];
s04 = Get[s04ResultPath];
require[AssociationQ[s04] && s04["Stage"] === "HqqV2S04-v1" &&
    s04["ScopeTag"] === scopeTag && And @@ Values[s04["Checks"]],
  "accepted S04 result failed its stage/scope/check gates"];

Get[hyperInticaPath];
require[Length[Names["HyperIntica`*"]] > 0,
  "pinned HyperIntica backend did not load"];
HyperIntica`$HyperVerbosity = 0;
HyperIntica`$QuietPrint = True;
HyperIntica`$HyperInticaAbortOnDivergence = True;
HyperIntica`$HyperInticaCheckDivergences = True;

masterLedger = s04["AngularMasters", "Ledger"];
allMasterKeys = Keys[masterLedger];
realRows = s04["RealPhaseSpaceMasterRows"];
projectors = Keys[realRows];
families = Keys[realRows[First[projectors]]];
require[projectors === {"Pg", "PPP"} && families === {
    "Hqq;gg", "Hqq;q_qbar_sameFlavor", "Hqq;qPrime_qbarPrime"},
  "accepted projector/family ordering changed"];

q2Solutions = Solve[s04["Conservation", "BaseEquations", "S23"], Q2];
require[Length[q2Solutions] === 1,
  "S04 conservation did not determine Q2 uniquely"];
q2Rule = First[q2Solutions];
require[TrueQ[Together[(Q2 /. q2Rule) -
      (s23 - sHat - t1 - u1)] === 0],
  "derived Q2 conservation rule changed"];

threeBodyPhase =
  s04["PhaseSpace", "ThreeBody", "HardPartTimesAngularPrefactor"];
phasePowers = DeleteDuplicates@Cases[threeBodyPhase,
  Power[s23, power_ /; ! FreeQ[power, epsilon]], Infinity];
require[Length[phasePowers] === 1,
  "three-body phase does not contain one endpoint carrier"];
phaseCarrier = First[phasePowers];
phaseExponent = Exponent[phaseCarrier, s23];
phaseAlpha = -Coefficient[phaseExponent, epsilon];
require[TrueQ[(phaseExponent /. epsilon -> 0) === 0] &&
    IntegerQ[phaseAlpha] && phaseAlpha > 0,
  "three-body endpoint carrier exponent did not derive"];
phaseRegular = Cancel[Together[threeBodyPhase/phaseCarrier]];
require[TrueQ[Together[phaseRegular phaseCarrier - threeBodyPhase] === 0],
  "three-body phase carrier did not reconstruct"];
s23Upper = s04["VariableMap", "S23Upper"];

ClearAll[badSymbolicQ, epsilonSeriesAssociation, convolveAssociations,
  associationExpression];
badSymbolicQ[expression_] := ! FreeQ[expression,
  Integrate | Inactive[Integrate] | Limit | _SeriesData | _Real |
    Indeterminate | ComplexInfinity | DirectedInfinity |
    HyperIntica`ZeroInfPeriod];
ClearAll[loadAcceptedRootGroupCache];
loadAcceptedRootGroupCache[] := loadAcceptedRootGroupCache[] = Module[
  {cache, groupTotals, checks},
  require[FileExistsQ[rootGroupCacheV2Path],
    "accepted S05 v2 root-group cache is missing"];
  require[FileHash[rootGroupCacheV2Path, "SHA256", "HexString"] ===
      expectedRootGroupCacheV2Hash,
    "accepted S05 v2 root-group cache hash mismatch"];
  cache = Get[rootGroupCacheV2Path];
  require[AssociationQ[cache],
    "accepted S05 root-group cache is not an association"];
  groupTotals = Lookup[cache, "GroupTotalsByTauPower", Missing[]];
  checks = <|
    "Stage" -> TrueQ[Lookup[cache, "Stage", Missing[]] ===
      "HqqV2S05RootGroupCache-v2"],
    "Scope" -> TrueQ[Lookup[cache, "ScopeTag", Missing[]] === scopeTag],
    "Producer" -> TrueQ[
      Lookup[cache, "ProducingSourceSHA256", Missing[]] ===
        expectedRootGroupCacheV2ProducerHash],
    "InheritedV1Cache" -> TrueQ[
      Lookup[cache, "InheritedRootGroupCacheSHA256", Missing[]] ===
        expectedRootGroupCacheHash &&
      Lookup[cache,
        "InheritedRootGroupCacheProducingSourceSHA256", Missing[]] ===
          expectedRootGroupCacheProducerHash],
    "EvaluatedContentHashMethod" -> TrueQ[
      Lookup[cache, "RootProductsHashMethod", Missing[]] ===
        "Wolfram Hash[evaluated exact root-product list, SHA256]"],
    "S04Source" -> TrueQ[
      Lookup[cache, "S04SourceSHA256", Missing[]] ===
        expectedS04SourceHash],
    "S04Result" -> TrueQ[
      Lookup[cache, "S04ResultSHA256", Missing[]] ===
        expectedS04ResultHash],
    "MasterCache" -> TrueQ[
      Lookup[cache, "MasterCacheSHA256", Missing[]] ===
        FileHash[masterCachePath, "SHA256", "HexString"]],
    "CoefficientProducers" -> TrueQ[
      Lookup[cache, "CoefficientCacheProducerHashes", Missing[]] ===
        acceptedCoefficientCacheProducerHashes],
    "Channel" -> TrueQ[
      Lookup[cache, "Projector", Missing[]] === "Pg" &&
      Lookup[cache, "Family", Missing[]] ===
        "Hqq;q_qbar_sameFlavor" &&
      Lookup[cache, "EpsilonPower", Missing[]] === 1],
    "ProductCounts" -> TrueQ[
      Lookup[cache, "TotalProductCount", Missing[]] === 371 &&
      Lookup[cache, "RootProductCount", Missing[]] === 189 &&
      Length[Lookup[cache, "RootIndices", {}]] === 189],
    "TauLedger" -> TrueQ[
      AssociationQ[groupTotals] &&
      Sort[Keys[groupTotals]] === Sort[Lookup[cache, "TauPowers", {}]] &&
      Sort[Keys[groupTotals]] === {-4, -2} &&
      Map[Length, groupTotals] === <|-4 -> 24, -2 -> 91|>],
    "ClosedExactGroups" -> TrueQ[
      AssociationQ[groupTotals] &&
      AllTrue[Flatten[Values[groupTotals], 1],
        ! badSymbolicQ[#] &&
          FreeQ[#, hqqV2S05Tau | s23 | epsilon |
            _SeriesData | _Real] &]],
    "EmbeddedChecks" -> TrueQ[
      AssociationQ[Lookup[cache, "Checks", Missing[]]] &&
      And @@ Values[Lookup[cache, "Checks", <||>]]]|>;
  require[And @@ Values[checks],
    "accepted S05 root-group cache gates failed", checks];
  Print["S05_ROOT_GROUP_CACHE_LOADED=", InputForm[<|
    "SHA256" -> expectedRootGroupCacheV2Hash,
    "TotalProducts" -> cache["TotalProductCount"],
    "RootProducts" -> cache["RootProductCount"],
    "TauPowers" -> cache["TauPowers"],
    "GroupCounts" -> Map[Length, groupTotals]|>]];
  cache
];
epsilonSeriesAssociation[expression_, minimum_Integer, maximum_Integer,
    label_String, expandFunctions_: False] := Module[{prepared, series, answer},
  prepared = If[TrueQ[expandFunctions], FunctionExpand[expression], expression];
  series = Quiet@Check[Normal@Series[prepared,
      {epsilon, 0, maximum}], $Failed];
  require[series =!= $Failed && ! badSymbolicQ[series],
    label <> " epsilon series failed"];
  answer = Association@Table[power -> Coefficient[series, epsilon, power],
    {power, minimum, maximum}];
  require[FreeQ[Values[answer], epsilon | _SeriesData | _Real],
    label <> " Laurent coefficients are unresolved"];
  answer
];
convolveAssociations[left_Association, right_Association,
    minimum_Integer, maximum_Integer] := Association@Table[
  power -> Total@KeyValueMap[
    Function[{leftPower, leftValue},
      leftValue Lookup[right, power - leftPower, 0]], left],
  {power, minimum, maximum}];
associationExpression[data_Association] :=
  Total@KeyValueMap[Function[{power, value}, epsilon^power value], data];

phaseSeries = epsilonSeriesAssociation[
  phaseRegular, 0, 2, "three-body regular phase", True];

(* Paper B27, B30 and B31, with defining ODE gates. *)
ClearAll[truncateEpsilon, h11Series, h12Series, h22Series,
  finiteHyperSeries, hypergeometricODEResidual];
truncateEpsilon[expression_, order_Integer] :=
  Normal@Series[expression, {epsilon, 0, order}];
h11Series[w_] := truncateEpsilon[
  (1 - w)^(-1 - epsilon) (1 + epsilon^2 PolyLog[2, w]), 2];
h12Series[w_] := truncateEpsilon[
  (-epsilon + (1 + epsilon) h11Series[w])/(1 - w), 2];
h22Series[w_] := truncateEpsilon[
  -(1 + epsilon) h11Series[w]/(1 - w) +
    (2 + epsilon) (-epsilon + (1 + epsilon) h11Series[w])/
      (1 - w)^2, 2];
finiteHyperSeries[j_Integer, l_Integer, w_] := Which[
  j <= 0, truncateEpsilon[Sum[
    Pochhammer[j, r] Pochhammer[l, r] w^r/
      (Pochhammer[1 - epsilon, r] r!), {r, 0, -j}], 2],
  l <= 0, truncateEpsilon[Sum[
    Pochhammer[j, r] Pochhammer[l, r] w^r/
      (Pochhammer[1 - epsilon, r] r!), {r, 0, -l}], 2],
  {j, l} === {1, 1}, h11Series[w],
  MemberQ[{{1, 2}, {2, 1}}, {j, l}], h12Series[w],
  {j, l} === {2, 2}, h22Series[w],
  True, fail["unsupported nonterminating hypergeometric order", {j, l}]
];
hypergeometricODEResidual[y_, j_Integer, l_Integer, w_] :=
  Together@truncateEpsilon[
    w (1 - w) D[y, {w, 2}] +
      (1 - epsilon - (j + l + 1) w) D[y, w] - j l y, 2];
Clear[hqqW];
hypergeometricChecks = AssociationMap[Function[pair,
  Module[{j = pair[[1]], l = pair[[2]], y},
    y = finiteHyperSeries[j, l, hqqW];
    <|"ODEThroughEpsilon2" ->
        hypergeometricODEResidual[y, j, l, hqqW] === 0,
      "BoundaryAtZero" ->
        Together[truncateEpsilon[(y /. hqqW -> 0) - 1, 2]] === 0|>
  ]], {{1, 1}, {1, 2}, {2, 1}, {2, 2}}];
require[And @@ Flatten[Values /@ Values[hypergeometricChecks]],
  "paper B27/B30/B31 defining gates failed"];

(* Paper B19: finite B24 continuation, then HyperIntica on regular pieces. *)
ClearAll[periodsToExpression, hyperIntegrate];
periodsToExpression[wordList_] := Module[{evaluated, converted},
  evaluated = HyperIntica`EvaluatePeriods[wordList];
  converted = FixedPoint[
    ReplaceAll[#, HoldPattern[HyperIntica`ZeroInfPeriod[word_]] :>
      HyperIntica`ZeroInfPeriodAsMpl[word]] &, evaluated];
  converted /. HoldPattern[HyperIntica`Mpl[{n_Integer}, {z_}]] :>
    PolyLog[n, z]
];
hyperIntegrate[expression_] := Module[{raw, answer},
  raw = HyperIntica`HyperIntica[expression, {omegaB, 0, 1}];
  require[raw =!= $Failed && ListQ[raw],
    "HyperIntica failed on a regular B19 coefficient"];
  answer = periodsToExpression[raw];
  require[! badSymbolicQ[answer],
    "HyperIntica returned an unresolved or inexact coefficient"];
  answer
];

ClearAll[b18OrderSeries, b19OrderSeries, dPar, cPar];
b18OrderSeries[j_Integer, l_Integer] := b18OrderSeries[j, l] =
  truncateEpsilon[
    2 Pi Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2 *
      2^(-j - l) Beta[1 - epsilon - j, 1 - epsilon - l] *
      finiteHyperSeries[j, l, (1 + cPar)/2], 1];

b19CheckLedger = <||>;
b19OrderSeries[j_Integer, l_Integer] := b19OrderSeries[j, l] = Module[
  {nDim, w, order, f, coefficients, a0, a1, divided1,
   divided2, base0, base1, continued, prefactor,
   subtraction1 = True, subtraction2 = True, answer},
  Print["S05_B19_ORDER=", j, ",", l];
  nDim = 4 - 2 epsilon;
  w = (1 + cPar) omegaB/(dPar - 1 + 2 omegaB);
  order = If[l >= 1, 2, 1];
  f = truncateEpsilon[
    omegaB^(-epsilon)/(omegaB + (dPar - 1)/2)^j *
      finiteHyperSeries[j, l, w], order];
  coefficients = Table[Coefficient[f, epsilon, k], {k, 0, order}];
  Which[
    l <= 0,
      base0 = hyperIntegrate[(1 - omegaB)^(-l) coefficients[[1]]];
      base1 = hyperIntegrate[Together[(1 - omegaB)^(-l) *
        (coefficients[[2]] - Log[1 - omegaB] coefficients[[1]])]];
      continued = base0 + epsilon base1,
    l === 1,
      a0 = Together[# /. omegaB -> 1] & /@ coefficients;
      divided1 = MapThread[
        Together[(#1 - #2)/(1 - omegaB)] &, {coefficients, a0}];
      subtraction1 = And @@ MapThread[
        Together[(1 - omegaB) #1 + #2 - #3] === 0 &,
        {divided1, a0, coefficients}];
      base0 = hyperIntegrate[divided1[[1]]];
      base1 = hyperIntegrate[Together[
        divided1[[2]] - Log[1 - omegaB] divided1[[1]]]];
      continued = base0 + epsilon base1 +
        Sum[a0[[k + 1]] epsilon^k, {k, 0, 2}]/(-epsilon),
    l === 2,
      a0 = Together[# /. omegaB -> 1] & /@ coefficients;
      a1 = Together[-(D[#, omegaB] /. omegaB -> 1)] & /@ coefficients;
      divided1 = MapThread[
        Together[(#1 - #2)/(1 - omegaB)] &, {coefficients, a0}];
      divided2 = MapThread[
        Together[(#1 - #2)/(1 - omegaB)] &, {divided1, a1}];
      subtraction1 = And @@ MapThread[
        Together[(1 - omegaB) #1 + #2 - #3] === 0 &,
        {divided1, a0, coefficients}];
      subtraction2 = And @@ MapThread[
        Together[(1 - omegaB) #1 + #2 - #3] === 0 &,
        {divided2, a1, divided1}];
      base0 = hyperIntegrate[divided2[[1]]];
      base1 = hyperIntegrate[Together[
        divided2[[2]] - Log[1 - omegaB] divided2[[1]]]];
      continued = base0 + epsilon base1 +
        Sum[a1[[k + 1]] epsilon^k, {k, 0, 2}]/(-epsilon) +
        Sum[a0[[k + 1]] epsilon^k, {k, 0, 2}]/(-1 - epsilon),
    True, fail["accepted B19 ledger has unsupported l", l]
  ];
  prefactor = (-1)^(l + 1) 2^(1 - l - j) Pi *
    Gamma[nDim - 3] Gamma[2 + l - nDim/2] *
    Gamma[nDim/2 - l - 1]/
    (Gamma[nDim/2 - 1]^2 Gamma[nDim/2 - 2] *
      Gamma[3 - nDim/2]);
  answer = truncateEpsilon[prefactor continued, 1];
  AssociateTo[b19CheckLedger, {j, l} -> <|
    "FirstSubtractionReconstructs" -> subtraction1,
    "SecondSubtractionReconstructs" -> subtraction2,
    "ClosedExact" -> ! badSymbolicQ[answer]|>];
  require[And @@ Values[b19CheckLedger[{j, l}]],
    "B19 order failed its B24/closure gates", {j, l}];
  answer
];

ClearAll[fixedMasterRecord];
fixedMasterRecord[key_HqqV2AngularMasterKey] := Module[
  {record = masterLedger[key], j, l, scales, powers, normalized,
   expression, data},
  {j, l} = record["DenominatorPowers"];
  scales = record["Scales"];
  powers = record["Powers"];
  normalized = Switch[record["Representation"],
    "Paper Eq. (B18), case (1)",
      b18OrderSeries[j, l] /. cPar -> record["CosChi"],
    "Paper Eqs. (B19)-(B20), case (2)",
      b19OrderSeries[j, l] /. {
        dPar -> First[record["DParameters"]], cPar -> record["CosChi"]},
    _, fail["unknown angular representation", key]
  ];
  expression = scales[[1]]^powers[[1]] scales[[2]]^powers[[2]] normalized;
  data = Association@Table[power -> Coefficient[expression, epsilon, power],
    {power, -2, 1}];
  require[TrueQ[data[-2] === 0] &&
      ! badSymbolicQ[Values[KeyDrop[data, -2]]] &&
      FreeQ[Values[KeyDrop[data, -2]], epsilon],
    "fixed angular master Laurent gate failed", key];
  <|"Representation" -> record["Representation"],
    "DenominatorPowers" -> {j, l},
    "LaurentThroughEpsilon1" -> KeyDrop[data, -2],
    "Checks" -> <|"NoEpsilonMinus2" -> True, "ClosedExact" -> True|>|>
];

ClearAll[endpointOneQ, valuationAtZero];
endpointOneQ[object_] := MatchQ[object,
    Hypergeometric2F1[_Integer, _Integer, 1 - epsilon, _]] &&
  TrueQ[Together[Limit[object[[4]] /. q2Rule, s23 -> 0] - 1] === 0];
valuationAtZero[expression_] := Module[{cancelled, value},
  cancelled = Quiet@Check[Cancel[Together[expression]], $Failed];
  require[cancelled =!= $Failed,
    "endpoint valuation rationalization failed"];
  value = Exponent[Numerator[cancelled], s23, Min] -
    Exponent[Denominator[cancelled], s23, Min];
  require[IntegerQ[value], "endpoint valuation is not integral"];
  value
];
endpointOneKeys = Select[allMasterKeys, Module[{objects},
  objects = Cases[masterLedger[#]["ExactRepresentation"],
    _Hypergeometric2F1, Infinity];
  Count[objects, object_ /; endpointOneQ[object]] === 1] &];
require[endpointOneKeys =!= {} && AllTrue[endpointOneKeys,
    masterLedger[#]["Representation"] === "Paper Eq. (B18), case (1)" &],
  "endpoint-one master inventory failed"];
endpointMasterGroups = GatherBy[endpointOneKeys,
  masterLedger[#]["ExactRepresentation"] &];

(* B19 has one tool-derived principal square root.  Preserve that physical
   branch while constructing its endpoint jet. *)
b19Keys = Select[allMasterKeys,
  masterLedger[#]["Representation"] ===
    "Paper Eqs. (B19)-(B20), case (2)" &];
b19Radicands = DeleteDuplicates[
  Factor[Together[# /. q2Rule]] & /@ Cases[
    masterLedger[#]["ExactRepresentation"] & /@ b19Keys,
    Power[argument_, exponent_Rational /;
      Denominator[exponent] === 2] :> argument, Infinity]];
require[Length[b19Radicands] === 1,
  "B19 ledger does not have one derived square-root radicand",
  b19Radicands];
commonB19Radicand = First[b19Radicands];
b19RootOrder = 2 + Max[Abs@Flatten[
  masterLedger[#]["DenominatorPowers"] & /@ b19Keys]];
require[IntegerQ[b19RootOrder] && b19RootOrder > 2,
  "B19 root-jet depth did not derive"];
b19EndpointRadicand = Factor[commonB19Radicand /. s23 -> 0];
b19EndpointRoot = Sqrt[b19EndpointRadicand];
require[TrueQ[Together[b19EndpointRoot^2 -
      (commonB19Radicand /. s23 -> 0)] === 0],
  "B19 endpoint root did not square to the derived radicand"];

ClearAll[b19PhysicalRootJet];
b19PhysicalRootJet = Module[
  {jet = b19EndpointRoot, coefficient, solution},
  Do[
    coefficient = Unique["hqqV2S05RootCoefficient"];
    solution = Solve[Coefficient[Normal@Series[
      (jet + coefficient s23^order)^2 - commonB19Radicand,
      {s23, 0, order}], s23, order] == 0, coefficient];
    require[Length[solution] === 1,
      "B19 physical root-jet coefficient is ambiguous", order];
    jet += coefficient s23^order /. First[solution],
    {order, 1, b19RootOrder}];
  require[And @@ Table[Coefficient[Normal@Series[
      jet^2 - commonB19Radicand, {s23, 0, b19RootOrder}],
      s23, order] === 0, {order, 0, b19RootOrder}],
    "B19 physical root jet failed its square gate"];
  jet
];
b19FractionDefinitions = {
  sHat -> s04["VariableMap", "Definitions", "sHat"],
  t1 -> s04["VariableMap", "Definitions", "t1"],
  u1 -> s04["VariableMap", "Definitions", "u1"]};
b19EndpointK1T2Rules = Solve[
  s04["VariableMap", "S23"] == 0, k1T2];
require[Length[b19EndpointK1T2Rules] === 1,
  "B19 endpoint transverse momentum rule is ambiguous"];
b19EndpointLinearFraction = Factor[
  (sHat + t1) /. b19FractionDefinitions /.
    First[b19EndpointK1T2Rules]];
b19FractionAssumptions =
  Q2 > 0 && 0 < xHat < 1 && 0 < zHat < 1;
ClearAll[physicalEndpointReduce];
physicalEndpointReduce[expression_] := If[TrueQ[expression === 0], 0,
  Quiet@Check[FullSimplify[Cancel[Together[
    expression /. b19FractionDefinitions /.
      First[b19EndpointK1T2Rules]]],
    Assumptions -> b19FractionAssumptions], $Failed]];
b19RootJetChecks = <|
  "OneDerivedRadicand" -> Length[b19Radicands] === 1,
  "DerivedDepth" -> IntegerQ[b19RootOrder] && b19RootOrder > 2,
  "PrincipalEndpointRoot" ->
    SameQ[b19EndpointRoot, Sqrt[b19EndpointRadicand]],
  "PhysicalJetSquares" -> And @@ Table[Coefficient[Normal@Series[
      b19PhysicalRootJet^2 - commonB19Radicand,
      {s23, 0, b19RootOrder}], s23, order] === 0,
    {order, 0, b19RootOrder}],
  "PositiveFractionalRegionPresent" ->
    Reduce[b19FractionAssumptions &&
        b19EndpointLinearFraction > 0,
      {Q2, xHat, zHat}, Reals] =!= False,
  "NegativeFractionalRegionPresent" ->
    Reduce[b19FractionAssumptions &&
        b19EndpointLinearFraction < 0,
      {Q2, xHat, zHat}, Reals] =!= False,
  "FractionalPrincipalAbsolute" -> TrueQ[FullSimplify[
      Sqrt[b19EndpointLinearFraction^2] ==
        Abs[b19EndpointLinearFraction],
      Assumptions -> b19FractionAssumptions]]|>;
require[And @@ Values[b19RootJetChecks],
  "derived B19 root-jet gates failed", b19RootJetChecks];
b19RootFallbackBag = Internal`Bag[];

representativePairs = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    SelectFirst[Flatten[realRows[projector, family], 1],
      MatchQ[#, {_HqqV2AngularMasterKey, _}] &, Missing["NotFound"]]],
    families]], projectors];
require[FreeQ[representativePairs, _Missing],
  "a projector/family lacks a representative master pair"];
keysToProcess = If[probeMode,
  DeleteDuplicates@Join[endpointOneKeys,
    Cases[representativePairs, _HqqV2AngularMasterKey, Infinity]],
  allMasterKeys];

Print["S05_MODE=", s05ModeLabel];
If[(taskPlanMode || rootSubsetDiagnosticMode || startupProbeMode) &&
    ! FileExistsQ[masterCachePath],
  fail[s05ModeLabel <> " requires the accepted S05 master cache"]];
If[FileExistsQ[masterCachePath],
  masterCache = Quiet@Check[Get[masterCachePath], $Failed];
  require[AssociationQ[masterCache] &&
      masterCache["Stage"] === "HqqV2S05MasterCache-v1" &&
      masterCache["ScopeTag"] === scopeTag &&
      MemberQ[Append[acceptedMasterCacheProducerHashes,
          FileHash[sourcePath, "SHA256", "HexString"]],
        masterCache["ProducingSourceSHA256"]] &&
      masterCache["S04SourceSHA256"] === expectedS04SourceHash &&
      masterCache["S04ResultSHA256"] === expectedS04ResultHash &&
      masterCache["HyperInticaSHA256"] === expectedHyperInticaHash &&
      masterCache["AllMasterKeys"] === allMasterKeys &&
      And @@ Values[masterCache["Checks"]],
    "S05 master cache failed its identity gates"];
  angularLaurentLedger = masterCache["AngularLaurentLedger"];
  b19CheckLedger = masterCache["B19CheckLedger"];
  require[Sort[Keys[angularLaurentLedger]] === Sort[allMasterKeys] &&
      And @@ Map[And @@ Values[# ["Checks"]] &,
        Values[angularLaurentLedger]] &&
      And @@ Flatten[Values /@ Values[b19CheckLedger]],
    "loaded S05 master cache failed its mathematical gates"];
  masterCacheMode = "loaded";
  Print["S05_MASTER_CACHE_LOADED=", masterCachePath],
  angularLaurentLedger = AssociationMap[Function[key,
    Print["S05_MASTER=", InputForm[key]];
    fixedMasterRecord[key]], keysToProcess];
  masterCacheMode = If[probeMode, "disabled-in-probe", "written"];
  If[! probeMode,
    masterCacheChecks = <|
      "AllMastersPresent" ->
        Sort[Keys[angularLaurentLedger]] === Sort[allMasterKeys],
      "AllAngularClosed" -> And @@ Map[
        And @@ Values[# ["Checks"]] &, Values[angularLaurentLedger]],
      "EveryB19OrderChecked" -> And @@ Flatten[
        Values /@ Values[b19CheckLedger]],
      "HypergeometricBranches" ->
        And @@ Flatten[Values /@ Values[hypergeometricChecks]]|>;
    require[And @@ Values[masterCacheChecks],
      "computed S05 master cache failed its gates", masterCacheChecks];
    masterCache = <|
      "Stage" -> "HqqV2S05MasterCache-v1",
      "ScopeTag" -> scopeTag,
      "ProducingSourceSHA256" ->
        FileHash[sourcePath, "SHA256", "HexString"],
      "S04SourceSHA256" -> expectedS04SourceHash,
      "S04ResultSHA256" -> expectedS04ResultHash,
      "HyperInticaSHA256" -> expectedHyperInticaHash,
      "AllMasterKeys" -> allMasterKeys,
      "AngularLaurentLedger" -> angularLaurentLedger,
      "B19CheckLedger" -> b19CheckLedger,
      "Checks" -> masterCacheChecks|>;
    atomicPut[masterCache, masterCachePath];
    Print["S05_MASTER_CACHE_WRITTEN=", masterCachePath];
    Print["S05_MASTER_CACHE_SHA256=",
      FileHash[masterCachePath, "SHA256", "HexString"]]]
];

(* Channel weights derived from the unobserved state and flavor ledgers. *)
channelStateLedger = <|
  "Hqq;gg" -> <|"Observed" -> {"q"}, "Unobserved" -> {"g", "g"}|>,
  "Hqq;q_qbar_sameFlavor" -> <|"Observed" -> {"q"},
    "Unobserved" -> {"q", "qbar"}|>,
  "Hqq;qPrime_qbarPrime" -> <|"Observed" -> {"q"},
    "Unobserved" -> {"qPrime", "qbarPrime"}|>|>;
symmetryDivisor[states_List] :=
  Times @@ (Factorial /@ Values[Counts[states]]);
symmetryWeights = AssociationMap[
  1/symmetryDivisor[channelStateLedger[#]["Unobserved"]] &, families];
qIncoming = HqqV2Charge["UpType"];
qGenericPair = HqqV2Charge["DownType"];
nUp = HqqV2FlavorMultiplicity["UpType"];
nDown = HqqV2FlavorMultiplicity["DownType"];
differentFlavorSum[expression_] :=
  (nUp - 1) (expression /. qGenericPair -> qIncoming) + nDown expression;
weightCoefficient[family_String, expression_] :=
  symmetryWeights[family] If[family === "Hqq;qPrime_qbarPrime",
    differentFlavorSum[expression], expression];
weightChecks = <|
  "StateLedgersComplete" -> Sort[Keys[channelStateLedger]] === Sort[families],
  "DivisorsPositiveIntegers" -> And @@
    (IntegerQ[#] && # > 0 & /@
      (symmetryDivisor[channelStateLedger[#]["Unobserved"]] & /@ families)),
  "DifferentFlavorChargeDegree" -> And @@
    (Exponent[differentFlavorSum[#] /.
        HqqV2Charge[_] -> hqqChargeProbe, hqqChargeProbe] === 2 & /@
      {qIncoming^2, qIncoming qGenericPair, qGenericPair^2}),
  "FlavorIndependentMultiplicity" -> Together[
      differentFlavorSum[qIncoming^2] -
        (nUp + nDown - 1) qIncoming^2] === 0|>;
require[And @@ Values[weightChecks],
  "real-channel weight ledger failed", weightChecks];

ClearAll[stripThreeBodyPhase, groupedPhaseCoefficients,
  groupedBareCoefficients];
stripThreeBodyPhase[coefficient_, label_String] := Module[{bare},
  bare = Quiet@Check[Cancel[Together[coefficient/threeBodyPhase]], $Failed];
  require[bare =!= $Failed &&
      TrueQ[Cancel[Together[coefficient - threeBodyPhase bare]] === 0],
    label <> " three-body phase factorization failed"];
  bare
];
groupedPhaseCoefficients[projector_String, family_String] :=
  Merge[(#[[1]] -> #[[2]] & /@
    Flatten[realRows[projector, family], 1]), Total];
groupedBareCoefficients[projector_String, family_String, selected_: All] :=
  Module[{grouped = groupedPhaseCoefficients[projector, family]},
    If[selected =!= All, grouped = KeyTake[grouped, selected]];
    Association@KeyValueMap[Function[{key, coefficient},
      key -> stripThreeBodyPhase[coefficient,
        projector <> "/" <> family <> "/" <> ToString[InputForm[key]]]],
      grouped]
  ];

ClearAll[bareSeries, fixedCoefficientSeries,
  fixedTermSeriesFromCoefficient, fixedTermSeries, canonicalizeB19Root,
  b19RootProductQ, b19EndpointTauSeries, b19EndpointTauPowerRecords,
  b19EndpointResidue, b19RootJetResidue,
  directBoundedEndpointExpression, boundedEndpointExpression,
  boundedEndpointSeries, boundedResidue];
bareSeries[expression_, label_String] := Module[{data},
  data = epsilonSeriesAssociation[expression, -1, 2, label, False];
  require[TrueQ[data[-1] === 0],
    label <> " has a negative epsilon power before angular integration"];
  KeyDrop[data, -1]
];
fixedCoefficientSeries[bare_, label_String] := Module[
  {coefficientData, answer},
  coefficientData = bareSeries[bare, label <> " coefficient"];
  answer = convolveAssociations[coefficientData, phaseSeries, 0, 2];
  require[! badSymbolicQ[Values[answer]] &&
      FreeQ[Values[answer], epsilon | _SeriesData | _Real],
    label <> " fixed coefficient convolution failed"];
  answer
];
fixedTermSeriesFromCoefficient[phaseCoefficientData_Association,
    masterData_Association, label_String] := Module[{answer},
  answer = convolveAssociations[
    phaseCoefficientData, masterData, -1, 1];
  require[! badSymbolicQ[Values[answer]] &&
      FreeQ[Values[answer], epsilon | _SeriesData | _Real],
    label <> " fixed term convolution failed"];
  answer
];
fixedTermSeries[bare_, masterData_Association, label_String] :=
  fixedTermSeriesFromCoefficient[
    fixedCoefficientSeries[bare, label], masterData, label];
ClearAll[rationalRegularBareQ, fixedCoefficientSeriesTermWorker,
  fixedCoefficientSeriesWorker];
rationalRegularBareQ[bare_] := Module[{numerator, denominator},
  numerator = Numerator[bare];
  denominator = Denominator[bare];
  PolynomialQ[numerator, epsilon] &&
    PolynomialQ[denominator, epsilon] &&
    FreeQ[{numerator, denominator}, _Real | _SeriesData] &&
    FreeQ[denominator /. epsilon -> 0, epsilon] &&
    ! TrueQ[(denominator /. epsilon -> 0) === 0]
];
fixedCoefficientSeriesTermWorker[bare_] := Module[
  {numerator, denominator, inverseDenominatorSeries,
   numeratorData, inverseDenominatorData, coefficientData, answer},
  If[! TrueQ[rationalRegularBareQ[bare]], Return[$Failed]];
  numerator = Numerator[bare];
  denominator = Denominator[bare];
  inverseDenominatorSeries = Quiet@Check[
    Normal@Series[1/denominator, {epsilon, 0, 2}], $Failed];
  If[inverseDenominatorSeries === $Failed ||
      ! FreeQ[inverseDenominatorSeries,
      Integrate | Inactive[Integrate] | Limit | _SeriesData | _Real |
        Indeterminate | ComplexInfinity | DirectedInfinity |
        HyperIntica`ZeroInfPeriod],
    Return[$Failed]];
  numeratorData = Association@Table[
    power -> Coefficient[numerator, epsilon, power], {power, 0, 2}];
  inverseDenominatorData = Association@Table[
    power -> Coefficient[inverseDenominatorSeries, epsilon, power],
    {power, 0, 2}];
  If[! FreeQ[
      Join[Values[numeratorData], Values[inverseDenominatorData]],
      epsilon | _SeriesData | _Real | Integrate | Inactive[Integrate] |
        Limit | Indeterminate | ComplexInfinity | DirectedInfinity |
        HyperIntica`ZeroInfPeriod],
    Return[$Failed]];
  coefficientData = Association@Table[
    power -> Total@Table[
      Lookup[numeratorData, numeratorPower, 0]
        Lookup[inverseDenominatorData, power - numeratorPower, 0],
      {numeratorPower, 0, power}], {power, 0, 2}];
  If[! FreeQ[Values[coefficientData],
      epsilon | _SeriesData | _Real | Integrate | Inactive[Integrate] |
        Limit | Indeterminate | ComplexInfinity | DirectedInfinity |
        HyperIntica`ZeroInfPeriod],
    Return[$Failed]];
  answer = Association@Table[power -> Total@KeyValueMap[
      Function[{leftPower, leftValue},
        leftValue Lookup[phaseSeries, power - leftPower, 0]],
      coefficientData], {power, 0, 2}];
  If[! FreeQ[Values[answer], epsilon | _SeriesData | _Real],
    Return[$Failed]];
  answer
];
fixedCoefficientSeriesWorker[task_Association] := Module[
  {index, terms, answer, termAnswer, termIndex, power},
  index = Lookup[task, "Index", -1];
  terms = Lookup[task, "BareTerms", {task["Bare"]}];
  If[! ListQ[terms] || terms === {} ||
      ! TrueQ[Total[terms] === task["Bare"]],
    Return[<|"Index" -> index, "OK" -> False,
      "Reason" -> "exact term reconstruction failed"|>]];
  answer = Association@Table[power -> 0, {power, 0, 2}];
  Do[
    termAnswer = fixedCoefficientSeriesTermWorker[terms[[termIndex]]];
    If[! AssociationQ[termAnswer],
      Return[<|"Index" -> index, "OK" -> False,
        "Reason" -> "termwise coefficient series failed",
        "TermIndex" -> termIndex|>]];
    Do[AssociateTo[answer,
      power -> (answer[power] + termAnswer[power])],
      {power, 0, 2}];
    Clear[termAnswer],
    {termIndex, Length[terms]}];
  If[! FreeQ[Values[answer], epsilon | _SeriesData | _Real |
      Integrate | Inactive[Integrate] | Limit | Indeterminate |
      ComplexInfinity | DirectedInfinity | HyperIntica`ZeroInfPeriod],
    Return[<|"Index" -> index, "OK" -> False,
      "Reason" -> "termwise phase sum gate failed"|>]];
  <|"Index" -> index, "OK" -> True,
    "TermCount" -> Length[terms],
    "PhaseCoefficientData" -> answer|>
];
canonicalizeB19Root[expression_] := expression /. {
  HoldPattern[Power[argument_, exponent_Rational]] /;
      Denominator[exponent] === 2 && TrueQ[
        Together[argument - commonB19Radicand] === 0] :>
    hqqV2S05B19Root^(2 exponent),
  HoldPattern[Power[argument_, exponent_Rational]] /;
      Denominator[exponent] === 2 && TrueQ[
        Together[argument - commonB19Radicand/s23] === 0] :>
    (hqqV2S05B19Root/Sqrt[s23])^(2 exponent)
};
b19RootProductQ[expression_] := ! FreeQ[
  canonicalizeB19Root[expression /. q2Rule], hqqV2S05B19Root];
b19EndpointTauSeries[expression_, label_String] := Module[
  {prepared, physicalJet, series, normal},
  prepared = canonicalizeB19Root[expression /. q2Rule] /.
      s23 -> hqqV2S05Tau^2;
  prepared = Quiet@Check[PowerExpand[prepared], $Failed];
  require[prepared =!= $Failed,
    label <> " B19 endpoint-variable preparation failed"];
  physicalJet = b19PhysicalRootJet /. s23 -> hqqV2S05Tau^2;
  prepared = prepared /. hqqV2S05B19Root -> physicalJet;
  series = Quiet@Check[Series[prepared, {hqqV2S05Tau, 0, -2}], $Failed];
  normal = Quiet@Check[Normal[series], $Failed];
  require[series =!= $Failed && normal =!= $Failed &&
      ! badSymbolicQ[normal] &&
      FreeQ[normal, s23 | epsilon | hqqV2S05B19Root | _Real],
    label <> " B19 physical root-jet endpoint expansion failed"];
  normal
];
b19EndpointTauPowerRecords[expression_, label_String] := Module[
  {normal, expanded, powers, records, reconstructed},
  normal = b19EndpointTauSeries[expression, label];
  expanded = Expand[normal];
  If[TrueQ[expanded === 0], Return[{}]];
  powers = Sort@DeleteDuplicates@Cases[expanded,
    HoldPattern[Power[hqqV2S05Tau,
      power_Integer /; power <= -2]] :> power, Infinity];
  require[powers =!= {},
    label <> " B19 physical root jet has no negative tau power"];
  records = Table[{power,
      Coefficient[expanded, hqqV2S05Tau, power]}, {power, powers}];
  reconstructed = Total[
    (#[[2]] hqqV2S05Tau^#[[1]]) & /@ records];
  require[TrueQ[Cancel[Together[
        expanded - reconstructed]] === 0] &&
      AllTrue[records, ! badSymbolicQ[#[[2]]] &&
        FreeQ[#[[2]], hqqV2S05Tau | s23 | epsilon |
          _SeriesData | _Real] &],
    label <> " B19 physical tau-power split failed", powers];
  records
];
b19EndpointResidue[expression_, label_String] := Module[
  {normal, residue, remainder},
  normal = b19EndpointTauSeries[expression, label];
  residue = Coefficient[normal, hqqV2S05Tau, -2];
  remainder = Quiet@Check[Cancel[Together[
    normal - residue/hqqV2S05Tau^2]], $Failed];
  require[remainder =!= $Failed && TrueQ[remainder === 0],
    label <> " B19 physical root jet found a stronger endpoint", normal];
  require[! badSymbolicQ[residue] &&
      FreeQ[residue, hqqV2S05Tau | s23 | epsilon | _SeriesData | _Real],
    label <> " B19 physical root-jet residue is unresolved"];
  residue
];
b19RootJetResidue[expression_, label_String, power_Integer] := Module[
  {residue},
  residue = b19EndpointResidue[expression,
    label <> " epsilon " <> ToString[power]];
  Internal`StuffBag[b19RootFallbackBag,
    <|"Label" -> label, "EpsilonPower" -> power,
      "PhysicalPrincipalRoot" -> True|>];
  residue
];
directBoundedEndpointExpression[expression_] := Module[{endpointSeries},
  endpointSeries = Quiet@Check[Normal@Series[
    expression /. q2Rule, {s23, 0, -1}], $Failed];
  If[endpointSeries === $Failed || badSymbolicQ[endpointSeries] ||
      ! FreeQ[endpointSeries, epsilon | _SeriesData | _Real],
    $Failed, endpointSeries]
];
boundedEndpointExpression[expression_, label_String,
    power_Integer] := Module[{endpointSeries, residue},
  endpointSeries = directBoundedEndpointExpression[expression];
  If[endpointSeries === $Failed,
    residue = b19RootJetResidue[expression, label, power];
    endpointSeries = residue/s23];
  require[! badSymbolicQ[endpointSeries] &&
      FreeQ[endpointSeries, epsilon | _SeriesData | _Real],
    label <> " endpoint Laurent series is unresolved", power];
  endpointSeries
];
boundedEndpointSeries[data_Association, label_String] := Association@Table[
  power -> boundedEndpointExpression[data[power], label, power],
  {power, -1, 1}];
boundedResidue[data_Association, label_String] := Module[
  {endpointData = boundedEndpointSeries[data, label]},
  Association@KeyValueMap[Function[{power, endpointSeries},
    power -> Module[{residue, remainder},
      residue = Coefficient[endpointSeries, s23, -1];
      remainder = Quiet@Check[Cancel[Together[
        endpointSeries - residue/s23]], $Failed];
      require[remainder =!= $Failed && TrueQ[remainder === 0],
        label <> " has a stronger or non-Laurent endpoint",
        <|"EpsilonPower" -> power,
          "EndpointSeries" -> endpointSeries|>];
      require[! badSymbolicQ[residue] &&
          FreeQ[residue, s23 | epsilon | _SeriesData | _Real],
        label <> " endpoint residue is unresolved", power];
      residue]], endpointData]
];

ClearAll[eulerEndpointData];
eulerEndpointData[key_HqqV2AngularMasterKey, weightedBare_,
    label_String] := Module[
  {master, objects, object, a, b, c0, w, delta, common,
   deltaValuation, baseValuationWithS23, depth,
   regularCoefficient, fractionalCoefficient, regularDeltaSeries,
   fractionalReduced, regularBranch, fractionalBranch,
   regularProduct, regularData, regularResidue,
   fractionalExponent, integerEndpointPower, alphaIncrement,
   fractionalAlpha, fractionalPrepared, fractionalLimit,
   fractionalData},
  master = masterLedger[key]["ExactRepresentation"] /. q2Rule;
  objects = Select[DeleteDuplicates@Cases[master,
      _Hypergeometric2F1, Infinity], endpointOneQ];
  require[Length[objects] === 1,
    label <> " does not contain one endpoint-one B18 function"];
  object = First[objects];
  {a, b, w} = {object[[1]], object[[2]], object[[4]]};
  c0 = 1 - epsilon;
  delta = Cancel[Together[1 - w]];
  common = Cancel[Together[master/object]];
  deltaValuation = valuationAtZero[delta];
  require[deltaValuation > 0,
    label <> " Euler connection variable does not vanish"];
  baseValuationWithS23 = valuationAtZero[
    s23 (phaseRegular /. q2Rule) (weightedBare /. q2Rule) common];
  depth = Max[0, Ceiling[-baseValuationWithS23/deltaValuation]];
  regularCoefficient = Gamma[c0] Gamma[c0 - a - b]/
    (Gamma[c0 - a] Gamma[c0 - b]);
  fractionalCoefficient = Gamma[c0] Gamma[a + b - c0]/
    (Gamma[a] Gamma[b]);
  regularDeltaSeries = Sum[Pochhammer[a, n] Pochhammer[b, n]/
      (Pochhammer[a + b - c0 + 1, n] n!) delta^n,
    {n, 0, depth}];
  fractionalReduced = FullSimplify[FunctionExpand[
    Hypergeometric2F1[c0 - a, c0 - b,
      c0 - a - b + 1, delta]], Assumptions -> 0 < delta < 1];
  require[FreeQ[fractionalReduced,
      _Hypergeometric2F1 | _Hypergeometric2F1Regularized],
    label <> " Euler fractional branch did not close"];
  regularBranch = common regularCoefficient regularDeltaSeries;
  fractionalExponent = c0 - a - b;
  fractionalBranch = common fractionalCoefficient *
    delta^fractionalExponent fractionalReduced;
  regularProduct = (phaseRegular /. q2Rule) *
    (weightedBare /. q2Rule) regularBranch;
  regularData = epsilonSeriesAssociation[
    regularProduct, -2, 1, label <> " Euler regular", True];
  require[TrueQ[regularData[-2] === 0],
    label <> " Euler regular branch has an epsilon^-2 coefficient"];
  regularResidue = boundedResidue[KeyDrop[regularData, -2],
    label <> " Euler regular"];
  integerEndpointPower = valuationAtZero[
      (phaseRegular /. q2Rule) (weightedBare /. q2Rule) common] +
    deltaValuation (fractionalExponent /. epsilon -> 0);
  require[IntegerQ[integerEndpointPower] && integerEndpointPower < 0,
    label <> " fractional integer endpoint power did not derive"];
  alphaIncrement = -deltaValuation Coefficient[
    fractionalExponent, epsilon];
  fractionalAlpha = phaseAlpha + alphaIncrement;
  require[IntegerQ[fractionalAlpha] && fractionalAlpha > phaseAlpha,
    label <> " fractional distribution exponent did not derive"];
  fractionalPrepared = s23^(-integerEndpointPower +
      alphaIncrement epsilon) (phaseRegular /. q2Rule) *
    (weightedBare /. q2Rule) fractionalBranch;
  fractionalLimit = Quiet@Check[FullSimplify[
    Limit[fractionalPrepared, s23 -> 0, Direction -> "FromAbove",
      Assumptions -> -1/4 < epsilon < 0 && sHat > 0 &&
        t1 < 0 && u1 < 0 && -sHat - t1 - u1 > 0],
    Assumptions -> -1/4 < epsilon < 0 && sHat > 0 &&
      t1 < 0 && u1 < 0 && -sHat - t1 - u1 > 0], $Failed];
  require[fractionalLimit =!= $Failed && ! badSymbolicQ[fractionalLimit] &&
      FreeQ[fractionalLimit, s23 | _SeriesData | _Real],
    label <> " fixed-epsilon fractional endpoint did not close"];
  fractionalData = epsilonSeriesAssociation[FunctionExpand[fractionalLimit],
    -2, 1, label <> " Euler fractional Laurent", True];
  require[TrueQ[fractionalData[-2] === 0],
    label <> " Euler fractional endpoint has an epsilon^-2 coefficient"];
  <|"RegularAlpha" -> phaseAlpha,
    "FractionalAlpha" -> fractionalAlpha,
    "RegularResidue" -> regularResidue,
    "FractionalResidue" -> KeyDrop[fractionalData, -2],
    "DeltaValuation" -> deltaValuation,
    "RegularDepth" -> depth,
    "IntegerEndpointPower" -> integerEndpointPower,
    "Checks" -> <|"FractionalClosedBeforeLaurent" -> True,
      "RegularBoundedSeries" -> True, "DerivedAlpha" -> True|>|>
];

specialAlphaData = AssociationMap[Function[key, Module[
  {object, exponent, deltaValuation},
  object = First@Select[Cases[
      masterLedger[key]["ExactRepresentation"] /. q2Rule,
      _Hypergeometric2F1, Infinity], endpointOneQ];
  exponent = 1 - epsilon - object[[1]] - object[[2]];
  deltaValuation = valuationAtZero[1 - object[[4]]];
  phaseAlpha - deltaValuation Coefficient[exponent, epsilon]
]], endpointOneKeys];
distributionAlphas = Sort@DeleteDuplicates@Join[
  {phaseAlpha}, Values[specialAlphaData]];
require[AllTrue[distributionAlphas, IntegerQ[#] && # > 0 &],
  "distribution-alpha inventory did not derive"];

(* Exact bounded-distribution action on 0 <= s23 <= S23Upper. *)
ClearAll[hqqBound, hqqTest0, hqqTest1, hqqTest2, hqqS];
hqqTest = hqqTest0 + hqqTest1 hqqS + hqqTest2 hqqS^2;
plusTestAction[n_Integer] := Integrate[
  Log[hqqS]^n/hqqS (hqqTest - hqqTest0),
  {hqqS, 0, hqqBound}, Assumptions -> hqqBound > 0,
  GenerateConditions -> False];
distributionChecks = AssociationMap[Function[alpha, Module[
  {exactAction, expandedAction},
  exactAction = Integrate[hqqS^(-1 - alpha epsilon) hqqTest,
    {hqqS, 0, hqqBound},
    Assumptions -> hqqBound > 0 && epsilon < 0,
    GenerateConditions -> False];
  expandedAction = -hqqBound^(-alpha epsilon)/(alpha epsilon) hqqTest0 +
    Sum[(-alpha epsilon)^n/n! plusTestAction[n], {n, 0, 2}];
  <|"PolynomialMomentsThroughEpsilon1" -> Together[
      truncateEpsilon[exactAction - expandedAction, 1]] === 0|>
]], distributionAlphas];
require[And @@ Flatten[Values /@ Values[distributionChecks]] &&
    KeyExistsQ[s04["VariableMap"], "S23Upper"] &&
    TrueQ[s04["Checks", "VariableMapAndBounds"]],
  "bounded endpoint distribution gate failed", distributionChecks];

ClearAll[buildOrdinaryCoefficientTasks, ordinaryCoefficientTaskPlan];
buildOrdinaryCoefficientTasks[ordinaryGroups_List,
    groupedBare_Association, family_String] :=
  MapIndexed[Function[{ordinaryGroup, index}, Module[
    {bareTerms, bare},
    bareTerms = weightCoefficient[family, groupedBare[#]] & /@
      ordinaryGroup;
    bare = Total[bareTerms];
    <|"Index" -> First[index], "Bare" -> bare,
      "BareTerms" -> bareTerms,
      "GroupKeyCount" -> Length[ordinaryGroup],
      "ByteCount" -> ByteCount[bare],
      "LeafCount" -> LeafCount[bare]|>
  ]], ordinaryGroups];
ordinaryCoefficientTaskPlan[projector_String, family_String] := Module[
  {groupedBare, endpointKeys, ordinaryKeys, ordinaryGroups, tasks,
   metrics},
  groupedBare = groupedBareCoefficients[projector, family];
  endpointKeys = DeleteDuplicates@Flatten[
    (Select[#, KeyExistsQ[groupedBare, #] &] & /@ endpointMasterGroups),
    1];
  ordinaryKeys = Select[Keys[groupedBare],
    ! MemberQ[endpointKeys, #] &];
  ordinaryGroups = GatherBy[ordinaryKeys,
    angularLaurentLedger[#]["LaurentThroughEpsilon1"] &];
  tasks = buildOrdinaryCoefficientTasks[
    ordinaryGroups, groupedBare, family];
  metrics = Map[Function[task, <|
      "Index" -> task["Index"],
      "GroupKeyCount" -> task["GroupKeyCount"],
      "ByteCount" -> task["ByteCount"],
      "LeafCount" -> task["LeafCount"],
      "MaximumTermByteCount" ->
        Max[ByteCount /@ task["BareTerms"]],
      "AllTermsRationalRegular" ->
        AllTrue[task["BareTerms"], rationalRegularBareQ]|>], tasks];
  <|"OrdinaryKeyCount" -> Length[ordinaryKeys],
    "OrdinaryGroupCount" -> Length[ordinaryGroups],
    "EndpointKeyCount" -> Length[endpointKeys],
    "TaskMetrics" -> metrics|>
];
If[taskPlanMode,
  taskPlan = AssociationMap[Function[projector,
    AssociationMap[ordinaryCoefficientTaskPlan[projector, #] &,
      families]], projectors];
  require[And @@ Flatten[Map[
      # ["OrdinaryGroupCount"] === Length[# ["TaskMetrics"]] &&
        AllTrue[# ["TaskMetrics"],
          TrueQ[# ["AllTermsRationalRegular"]] &] &,
      Values /@ Values[taskPlan], {2}]],
    "S05 coefficient task plan failed its inventory gate", taskPlan];
  Print["S05_TASK_PLAN=", InputForm[taskPlan]];
  Print["S05_TASK_PLAN_OK"];
  Quit[0]
];

requestedAssemblyKernels = 2;
assemblyTaskBatchSize = requestedAssemblyKernels;
assemblyParallelByteBudget = 4892568;
assemblyParallelEnabled = False;
assemblyParallelKernelIDs = {};
assemblyParallelVersions = {};
assemblyParallelKernelConfiguration = Missing["NotConfigured"];
assemblyWorkerLaunchRecords = {};
assemblyBatchValidationRecords = {};
coefficientCacheLoadedCount = 0;
coefficientCacheWrittenCount = 0;
coefficientCacheValidationRecords = {};
currentS05SourceHash = FileHash[sourcePath, "SHA256", "HexString"];
currentMasterCacheHash = If[FileExistsQ[masterCachePath],
  FileHash[masterCachePath, "SHA256", "HexString"],
  Missing["DisabledWithoutMasterCache"]];
coefficientCacheDirectory = FileNameJoin[
  {coefficientCacheRoot, currentS05SourceHash}];
coefficientCacheSearchDirectories = DeleteDuplicates@Join[
  {coefficientCacheDirectory},
  FileNameJoin[{coefficientCacheRoot, #}] & /@
    acceptedCoefficientCacheProducerHashes];
If[! probeMode && ! taskPlanMode && ! startupProbeMode,
  If[! DirectoryQ[coefficientCacheRoot],
    CreateDirectory[coefficientCacheRoot]];
  If[! DirectoryQ[coefficientCacheDirectory],
    CreateDirectory[coefficientCacheDirectory]];
  require[DirectoryQ[coefficientCacheDirectory],
    "S05 coefficient cache directory is unavailable"];
  If[! rootSubsetDiagnosticMode,
    If[useDefaultAssemblyKernelLaunch,
      assemblyParallelKernelConfiguration = "DefaultLocalKernels",
      require[Length[$ConfiguredKernels] > 0,
        "no local parallel-kernel configuration is available"];
      assemblyParallelKernelConfiguration = ReplacePart[
        First[$ConfiguredKernels],
        {{1, "KernelCommand"} ->
           kernelExecutable,
         {1, "KernelCount"} -> requestedAssemblyKernels,
         {1, "UseKernelForking"} -> False,
         {1, "LimitByLicense"} -> True}]]];
];
ClearAll[launchAssemblyWorkers];
launchAssemblyWorkers[kernelCount_Integer] := Module[
  {configuration, kernelIDs, versions, orderProbe, workerProbes,
   workerProbeTermSets, workerProbeTasks, workerProbeExpected,
   workerProbeMatchQ},
  require[1 <= kernelCount <= requestedAssemblyKernels,
    "invalid S05 assembly worker count", kernelCount];
  Quiet[CloseKernels[]];
  If[TrueQ[assemblyParallelKernelConfiguration ===
      "DefaultLocalKernels"],
    Quiet@Check[LaunchKernels[kernelCount], {}],
    configuration = ReplacePart[assemblyParallelKernelConfiguration,
      {1, "KernelCount"} -> kernelCount];
    Quiet@Check[LaunchKernels[configuration], {}]];
  require[$KernelCount === kernelCount,
    "failed to launch requested S05 assembly workers", kernelCount];
  ParallelEvaluate[$HistoryLength = 0];
  Quiet[DistributeDefinitions[
    rationalRegularBareQ, fixedCoefficientSeriesTermWorker,
    fixedCoefficientSeriesWorker, phaseSeries, epsilon]];
  kernelIDs = Sort[ParallelEvaluate[$KernelID]];
  versions = ParallelEvaluate[$VersionNumber];
  orderProbe = ParallelMap[Identity,
    Range[kernelCount], Method -> "FinestGrained"];
  workerProbeTermSets = {
    {(1 + probeA epsilon + probeB epsilon^2)/
       (1 - probeC epsilon),
     (probeD - epsilon)/(1 + probeE epsilon + epsilon^2)},
    {(probeF + epsilon + probeG epsilon^3)/
       (2 - probeH epsilon),
     (1 - probeI epsilon)/(1 + epsilon)^2}};
  workerProbeTasks = MapIndexed[
    Function[{terms, position},
      <|"Index" -> First[position], "Bare" -> Total[terms],
        "BareTerms" -> terms|>], workerProbeTermSets];
  workerProbes = ParallelMap[fixedCoefficientSeriesWorker,
    workerProbeTasks, Method -> "FinestGrained"];
  workerProbeExpected = MapIndexed[
    Function[{terms, position}, fixedCoefficientSeries[Total[terms],
      "parallel rational worker probe " <>
        ToString[First[position]]]], workerProbeTermSets];
  workerProbeMatchQ = Length[workerProbes] ===
      Length[workerProbeExpected] && And @@ MapThread[
      Function[{workerResult, expected},
        AssociationQ[workerResult] && TrueQ[workerResult["OK"]] &&
          workerResult["TermCount"] ===
            Length[workerProbeTermSets[[workerResult["Index"]]]] &&
          And @@ Table[TrueQ[Together[
              workerResult["PhaseCoefficientData"][power] -
                expected[power]] === 0], {power, 0, 2}]],
      {workerProbes, workerProbeExpected}];
  require[Length[kernelIDs] === kernelCount &&
      DuplicateFreeQ[kernelIDs] &&
      versions ===
        ConstantArray[runtimeKernelVersion, kernelCount] &&
      orderProbe === Range[kernelCount] &&
      TrueQ[workerProbeMatchQ],
    "S05 parallel assembly worker probe failed"];
  assemblyParallelKernelIDs = kernelIDs;
  assemblyParallelVersions = versions;
  AppendTo[assemblyWorkerLaunchRecords, <|
    "KernelCount" -> kernelCount,
    "KernelIDs" -> kernelIDs, "Versions" -> versions,
    "OrderProbe" -> True, "WorkerProbe" -> True,
    "TermwiseEquivalenceProbe" -> True,
    "RationalCoefficientEquivalenceProbe" -> True|>];
  Print["S05_ASSEMBLY_WORKERS=", InputForm[kernelIDs],
    " COUNT=", kernelCount,
    " LAUNCH=", Length[assemblyWorkerLaunchRecords]];
];
If[! probeMode && ! taskPlanMode && ! startupProbeMode,
  assemblyParallelEnabled = True;
];

ClearAll[validCoefficientDataQ, validCoefficientTaskQ,
  coefficientTaskInputHash, coefficientTaskCachePath,
  coefficientTaskCachePaths, loadCachedCoefficientTask,
  storeCoefficientTask, makeAssemblyTaskBatches,
  runFixedCoefficientTasks];
validCoefficientDataQ[data_] := AssociationQ[data] &&
  Sort[Keys[data]] === Range[0, 2] &&
  ! badSymbolicQ[Values[data]] &&
  FreeQ[Values[data], epsilon | _SeriesData | _Real];
validCoefficientTaskQ[task_] := AssociationQ[task] &&
  ListQ[Lookup[task, "BareTerms", Missing["BareTerms"]]] &&
  Lookup[task, "BareTerms", {}] =!= {} &&
  Length[task["BareTerms"]] === task["GroupKeyCount"] &&
  TrueQ[Total[task["BareTerms"]] === task["Bare"]] &&
  AllTrue[task["BareTerms"], rationalRegularBareQ] &&
  task["ByteCount"] === ByteCount[task["Bare"]] &&
  task["LeafCount"] === LeafCount[task["Bare"]];
coefficientTaskInputHash[task_Association, label_String] := With[
  {taskLabel = label, taskIndex = task["Index"],
   bare = task["Bare"], phase = phaseSeries},
  IntegerString[Hash[
    HoldComplete[taskLabel, taskIndex, bare, phase], "SHA256"],
    16, 64]
];
coefficientTaskCachePath[task_Association, label_String] :=
  FileNameJoin[{coefficientCacheDirectory,
    coefficientTaskInputHash[task, label] <> ".wl"}];
coefficientTaskCachePaths[task_Association, label_String] :=
  FileNameJoin[{#, coefficientTaskInputHash[task, label] <> ".wl"}] & /@
    coefficientCacheSearchDirectories;
loadCachedCoefficientTask[task_Association, label_String] := Module[
  {taskHash, paths, existingPaths, path, record, data,
   acceptedProducerHashes},
  require[validCoefficientTaskQ[task],
    label <> " coefficient task failed exact-addend gates",
    task["Index"]];
  taskHash = coefficientTaskInputHash[task, label];
  paths = coefficientTaskCachePaths[task, label];
  existingPaths = Select[paths, FileExistsQ];
  require[Length[existingPaths] <= 1,
    label <> " coefficient task has duplicate cache records",
    existingPaths];
  If[existingPaths === {}, Return[Missing["NotFound"]]];
  path = First[existingPaths];
  record = Quiet@Check[Get[path], $Failed];
  acceptedProducerHashes = Append[
    acceptedCoefficientCacheProducerHashes, currentS05SourceHash];
  require[AssociationQ[record] &&
      record["Stage"] === "HqqV2S05CoefficientTask-v1" &&
      record["ScopeTag"] === scopeTag &&
      MemberQ[acceptedProducerHashes,
        record["ProducingSourceSHA256"]] &&
      FileNameTake[DirectoryName[path]] ===
        record["ProducingSourceSHA256"] &&
      MemberQ[acceptedCoefficientCacheAlgorithms,
        record["Algorithm"]] &&
      record["S04ResultSHA256"] === expectedS04ResultHash &&
      record["MasterCacheSHA256"] === currentMasterCacheHash &&
      record["TaskLabel"] === label &&
      record["TaskIndex"] === task["Index"] &&
      record["TaskInputSHA256"] === taskHash &&
      record["TaskByteCount"] === task["ByteCount"] &&
      record["TaskLeafCount"] === task["LeafCount"] &&
      Lookup[record, "TaskTermCount", task["GroupKeyCount"]] ===
        task["GroupKeyCount"] &&
      AssociationQ[record["Checks"]] &&
      And @@ Values[record["Checks"]],
    label <> " cached coefficient task failed identity gates", path];
  data = record["PhaseCoefficientData"];
  require[validCoefficientDataQ[data],
    label <> " cached coefficient task failed exact-data gates", path];
  coefficientCacheLoadedCount++;
  AppendTo[coefficientCacheValidationRecords, <|
    "TaskInputSHA256" -> taskHash, "Mode" -> "loaded",
    "ProducingSourceSHA256" -> record["ProducingSourceSHA256"],
    "Algorithm" -> record["Algorithm"],
    "Valid" -> True|>];
  Print["S05_COEFFICIENT_CACHE_LOADED=", label,
    " INDEX=", task["Index"], " HASH=", taskHash,
    " PRODUCER=", record["ProducingSourceSHA256"]];
  <|"Index" -> task["Index"], "OK" -> True,
    "PhaseCoefficientData" -> data|>
];
storeCoefficientTask[task_Association, label_String,
    answer_Association, launchRecord_Association] := Module[
  {taskHash, path, record, reloaded, recordChecks},
  require[validCoefficientTaskQ[task],
    label <> " coefficient task failed exact-addend gates before write",
    task["Index"]];
  taskHash = coefficientTaskInputHash[task, label];
  path = coefficientTaskCachePath[task, label];
  require[! FileExistsQ[path],
    label <> " coefficient cache target already exists", path];
  recordChecks = <|
    "WorkerAnswer" -> AssociationQ[answer] &&
      TrueQ[answer["OK"]] &&
      answer["Index"] === task["Index"] &&
      answer["TermCount"] === task["GroupKeyCount"],
    "ExactAddendsReconstruct" -> validCoefficientTaskQ[task],
    "ExactPhaseCoefficientData" ->
      validCoefficientDataQ[answer["PhaseCoefficientData"]],
    "WorkerLaunch" -> AssociationQ[launchRecord] &&
      MemberQ[Range[requestedAssemblyKernels],
        launchRecord["KernelCount"]] &&
      Length[launchRecord["KernelIDs"]] ===
        launchRecord["KernelCount"] &&
      launchRecord["Versions"] ===
        ConstantArray[runtimeKernelVersion,
          launchRecord["KernelCount"]] &&
      TrueQ[launchRecord["OrderProbe"]] &&
      TrueQ[launchRecord["WorkerProbe"]] &&
      TrueQ[launchRecord["TermwiseEquivalenceProbe"]] &&
      TrueQ[
        launchRecord["RationalCoefficientEquivalenceProbe"]]|>;
  require[And @@ Values[recordChecks],
    label <> " coefficient cache record failed pre-write gates",
    recordChecks];
  record = <|
    "Stage" -> "HqqV2S05CoefficientTask-v1",
    "ScopeTag" -> scopeTag,
    "ProducingSourceSHA256" -> currentS05SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "MasterCacheSHA256" -> currentMasterCacheHash,
    "Algorithm" ->
      "Rational-Coefficient-and-inverse-denominator-Series-v3",
    "TaskLabel" -> label, "TaskIndex" -> task["Index"],
    "TaskInputSHA256" -> taskHash,
    "TaskByteCount" -> task["ByteCount"],
    "TaskLeafCount" -> task["LeafCount"],
    "TaskTermCount" -> task["GroupKeyCount"],
    "WorkerLaunch" -> launchRecord,
    "PhaseCoefficientData" -> answer["PhaseCoefficientData"],
    "Checks" -> recordChecks|>;
  atomicPut[record, path];
  reloaded = Quiet@Check[Get[path], $Failed];
  require[SameQ[reloaded, record],
    label <> " coefficient cache failed atomic reload", path];
  coefficientCacheWrittenCount++;
  AppendTo[coefficientCacheValidationRecords, <|
    "TaskInputSHA256" -> taskHash, "Mode" -> "written",
    "ProducingSourceSHA256" -> currentS05SourceHash,
    "Algorithm" -> record["Algorithm"],
    "Valid" -> True|>];
  Print["S05_COEFFICIENT_CACHE_WRITTEN=", label,
    " INDEX=", task["Index"], " HASH=", taskHash,
    " FILE_SHA256=", FileHash[path, "SHA256", "HexString"]];
  answer
];
makeAssemblyTaskBatches[tasks_List] := Module[
  {remaining = tasks, batchBag = Internal`Bag[], takeTwo, batches},
  While[remaining =!= {},
    takeTwo = Length[remaining] >= 2 &&
      Total[Lookup[Take[remaining, 2], "ByteCount"]] <=
        assemblyParallelByteBudget;
    If[takeTwo,
      Internal`StuffBag[batchBag, Take[remaining, 2]];
      remaining = Drop[remaining, 2],
      Internal`StuffBag[batchBag, {First[remaining]}];
      remaining = Rest[remaining]]];
  batches = Internal`BagPart[batchBag, All];
  require[Lookup[Flatten[batches, 1], "Index", {}] ===
      Lookup[tasks, "Index", {}] &&
      AllTrue[batches, 1 <= Length[#] <= assemblyTaskBatchSize &] &&
      AllTrue[Select[batches, Length[#] === 2 &],
        Total[Lookup[#, "ByteCount"]] <=
          assemblyParallelByteBudget &],
    "S05 adaptive assembly batch construction failed", batches];
  batches
];
runFixedCoefficientTasks[tasks_List, label_String] := Module[
  {answers, answerByIndex = <||>, pendingBag = Internal`Bag[],
   pendingTasks, cachedAnswer, batches, batch, batchAnswers,
   launchRecord, storedAnswers, batchByteCount, batchNumber},
  If[! assemblyParallelEnabled,
    answers = Quiet@Check[Map[fixedCoefficientSeriesWorker, tasks], $Failed];
    require[ListQ[answers] && Length[answers] === Length[tasks] &&
        Lookup[answers, "Index", {}] === Lookup[tasks, "Index", {}] &&
        And @@ Lookup[answers, "OK", False],
      label <> " serial coefficient-series tasks failed", answers];
    Return[answers]];
  Do[
    cachedAnswer = loadCachedCoefficientTask[task, label];
    If[MissingQ[cachedAnswer],
      Internal`StuffBag[pendingBag, task],
      AssociateTo[answerByIndex,
        task["Index"] -> cachedAnswer]],
    {task, tasks}];
  pendingTasks = Internal`BagPart[pendingBag, All];
  Print["S05_COEFFICIENT_CACHE_STATUS=", label,
    " LOADED=", Length[tasks] - Length[pendingTasks],
    " PENDING=", Length[pendingTasks],
    " TOTAL=", Length[tasks]];
  If[rootSubsetDiagnosticMode,
    require[pendingTasks === {},
      label <> " root-subset diagnostic forbids coefficient work",
      Lookup[pendingTasks, "Index", {}]]];
  batches = makeAssemblyTaskBatches[pendingTasks];
  Do[
    batch = batches[[batchNumber]];
    batchByteCount = Total[Lookup[batch, "ByteCount"]];
    AppendTo[assemblyBatchValidationRecords, <|
      "Label" -> label, "Indices" -> Lookup[batch, "Index"],
      "KernelCount" -> Length[batch],
      "CombinedByteCount" -> batchByteCount,
      "Safe" -> (Length[batch] === 1 ||
        batchByteCount <= assemblyParallelByteBudget)|>];
    launchAssemblyWorkers[Length[batch]];
    batchAnswers = Quiet@Check[ParallelMap[
      fixedCoefficientSeriesWorker, batch,
      Method -> "FinestGrained"], $Failed];
    require[ListQ[batchAnswers] &&
        Length[batchAnswers] === Length[batch] &&
        Lookup[batchAnswers, "Index", {}] ===
          Lookup[batch, "Index", {}] &&
        And @@ Lookup[batchAnswers, "OK", False],
      label <> " parallel coefficient-series batch failed", batchAnswers];
    launchRecord = Last[assemblyWorkerLaunchRecords];
    Quiet[CloseKernels[]];
    require[$KernelCount === 0,
      label <> " assembly workers did not recycle"];
    storedAnswers = MapThread[
      storeCoefficientTask[#1, label, #2, launchRecord] &,
      {batch, batchAnswers}];
    MapThread[AssociateTo[answerByIndex, #1["Index"] -> #2] &,
      {batch, storedAnswers}];
    Print["S05_PHASE_BATCH_DONE=", label,
      " INDICES=", InputForm[Lookup[batch, "Index"]],
      " PENDING_BATCH=", batchNumber, "/", Length[batches]];
    Print["S05_PHASE_BATCH_WORKERS_RECYCLED=", label,
      " BATCH=", batchNumber, "/", Length[batches],
      " WORKERS=", Length[batch]];
    Clear[batch, batchAnswers, storedAnswers, launchRecord,
      batchByteCount],
    {batchNumber, Length[batches]}];
  answers = Lookup[answerByIndex, Lookup[tasks, "Index"],
    Missing["CoefficientTaskAnswer"]];
  Clear[answerByIndex, pendingBag, pendingTasks, batches];
  require[ListQ[answers] && Length[answers] === Length[tasks] &&
      Lookup[answers, "Index", {}] === Lookup[tasks, "Index", {}] &&
      And @@ Lookup[answers, "OK", False],
    label <> " collected coefficient-series tasks failed", answers];
  answers
];

ClearAll[newExactBag, exactBagTotal, groupedFixedPairProducts,
  groupedFixedPairTotal, endpointPowerRecordsCandidate,
  endpointPowerRecords,
  boundedExactAdd, balancedExactSum, streamingExactAccumulate,
  exactAdditiveSum, streamingExactTotals, endpointPolynomial,
  b19EndpointPowerDataFromAccumulator, familyB19EndpointPowerData,
  termwiseEndpointPowerData,
  carrierCoefficient, assembleFromBare];
newExactBag[] := Internal`Bag[];
exactBagTotal[bag_] := Module[{items = Internal`BagPart[bag, All]},
  If[items === {}, 0, Total[items]]];
groupedFixedPairProducts[bag_, label_String] := Module[
  {pairs, groups, products},
  pairs = Internal`BagPart[bag, All];
  If[pairs === {}, Return[{}]];
  require[AllTrue[pairs, MatchQ[#, {_, _}] &],
    label <> " fixed pair bag is malformed"];
  groups = GatherBy[pairs, Last];
  products = Map[Total[#[[All, 1]]] #[[1, 2]] &, groups];
  require[! badSymbolicQ[products] &&
      FreeQ[products, epsilon | _SeriesData | _Real],
    label <> " grouped fixed-pair products failed"];
  products
];
groupedFixedPairTotal[bag_, label_String] := Module[
  {products, answer},
  products = groupedFixedPairProducts[bag, label];
  If[products === {}, Return[0]];
  answer = Total[products];
  require[! badSymbolicQ[answer] &&
      FreeQ[answer, epsilon | _SeriesData | _Real],
    label <> " grouped fixed-pair total failed"];
  answer
];
endpointPowerRecordsCandidate[expression_] := Module[
  {expanded, powers, records, reconstructed, valid},
  expanded = Expand[expression];
  If[TrueQ[expanded === 0], Return[{}]];
  powers = Sort@DeleteDuplicates@Cases[expanded,
    HoldPattern[Power[s23, power_Integer /; power < 0]] :> power,
    Infinity];
  If[powers === {}, Return[$Failed]];
  records = Table[{power, Coefficient[expanded, s23, power]},
    {power, powers}];
  reconstructed = Total[(#[[2]] s23^#[[1]]) & /@ records];
  valid = Quiet@Check[
    Cancel[Together[expanded - reconstructed]] === 0, False];
  If[TrueQ[valid] &&
      AllTrue[records, ! badSymbolicQ[#[[2]]] &&
        FreeQ[#[[2]], s23 | epsilon | _SeriesData | _Real] &],
    records, $Failed]
];
endpointPowerRecords[expression_, label_String] := Module[{records},
  records = endpointPowerRecordsCandidate[expression];
  require[records =!= $Failed,
    label <> " endpoint-power split failed"];
  records
];
ClearAll[directEndpointCachePath, stableContentHash,
  loadOrComputeDirectEndpointRecords];
directEndpointCachePath[productIndex_Integer] := FileNameJoin[{
  directEndpointCacheRoot,
  "direct_" <> IntegerString[productIndex, 10, 4] <> ".wl"}];
stableContentHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
loadOrComputeDirectEndpointRecords[product_, label_String,
    epsilonPower_Integer, productIndex_Integer] := Module[
  {cachePath, sourceHash, productHash, status, cacheRecord,
   endpointSeries, endpointRecords, endpointRecordsHash,
   endpointZeroQ, producerChecks, reloadChecks},
  require[epsilonPower === 1 &&
      StringContainsQ[label,
        "Pg/Hqq;q_qbar_sameFlavor/ordinary-family/epsilon 1"],
    label <> " direct endpoint cache scope mismatch"];
  If[! DirectoryQ[directEndpointCacheRoot],
    CreateDirectory[directEndpointCacheRoot,
      CreateIntermediateDirectories -> True]];
  require[DirectoryQ[directEndpointCacheRoot],
    "direct endpoint cache directory is unavailable"];
  cachePath = directEndpointCachePath[productIndex];
  sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
  productHash = stableContentHash[product];
  If[FileExistsQ[cachePath],
    status = "LOADED",
    endpointSeries = directBoundedEndpointExpression[product];
    require[endpointSeries =!= $Failed,
      label <> "/product " <> ToString[productIndex] <>
        " non-B19 direct endpoint series failed"];
    endpointRecords = endpointPowerRecords[endpointSeries,
      label <> "/product " <> ToString[productIndex]];
    endpointZeroQ = TrueQ[Quiet@Check[
      Expand[endpointSeries] === 0, False]];
    endpointRecordsHash = stableContentHash[endpointRecords];
    producerChecks = <|
      "EndpointPowerSplitAccepted" -> True,
      "RecordsPresentOrEndpointExactlyZero" -> TrueQ[
        endpointRecords =!= {} || endpointZeroQ],
      "NegativeIntegerPowers" -> AllTrue[endpointRecords,
        MatchQ[#, {power_Integer /; power < 0, _}] &],
      "UniqueOrderedPowers" -> TrueQ[
        (First /@ endpointRecords) ===
          Sort@DeleteDuplicates[First /@ endpointRecords]],
      "ClosedExactRecords" -> TrueQ[
        ! badSymbolicQ[endpointRecords] &&
        FreeQ[endpointRecords,
          s23 | epsilon | _SeriesData | _Real]]|>;
    require[And @@ Values[producerChecks],
      label <> " direct endpoint cache producer gates failed",
      producerChecks];
    cacheRecord = <|
      "Stage" -> "HqqV2S05DirectEndpointRecord-v1",
      "ScopeTag" -> scopeTag,
      "ProducingSourceSHA256" -> sourceHash,
      "Algorithm" ->
        "DirectBoundedEndpointExpression-and-EndpointPowerRecords-v1",
      "S04SourceSHA256" -> expectedS04SourceHash,
      "S04ResultSHA256" -> expectedS04ResultHash,
      "MasterCacheSHA256" ->
        FileHash[masterCachePath, "SHA256", "HexString"],
      "CoefficientCacheProducerHashes" ->
        acceptedCoefficientCacheProducerHashes,
      "RootGroupCacheV2SHA256" -> expectedRootGroupCacheV2Hash,
      "Label" -> label,
      "EpsilonPower" -> epsilonPower,
      "ProductIndex" -> productIndex,
      "ProductSHA256" -> productHash,
      "EndpointRecordsSHA256" -> endpointRecordsHash,
      "EndpointPowerRecords" -> endpointRecords,
      "Checks" -> producerChecks|>;
    atomicPut[cacheRecord, cachePath];
    status = "WRITTEN";
    Clear[cacheRecord, endpointSeries, endpointRecords,
      endpointRecordsHash, producerChecks]];
  cacheRecord = Get[cachePath];
  reloadChecks = <|
    "Association" -> AssociationQ[cacheRecord],
    "Stage" -> TrueQ[Lookup[cacheRecord, "Stage", Missing[]] ===
      "HqqV2S05DirectEndpointRecord-v1"],
    "Scope" -> TrueQ[
      Lookup[cacheRecord, "ScopeTag", Missing[]] === scopeTag],
    "Producer" -> With[{storedProducer = Lookup[
        cacheRecord, "ProducingSourceSHA256", Missing[]]}, TrueQ[
      storedProducer === sourceHash ||
      (MemberQ[acceptedDirectEndpointCacheParentProducerHashes,
          storedProducer] &&
        (storedProducer =!=
            First[acceptedDirectEndpointCacheParentProducerHashes] ||
          Lookup[Lookup[cacheRecord, "Checks", <||>],
            "NonemptyRecords", False] === True))]],
    "Algorithm" -> TrueQ[
      Lookup[cacheRecord, "Algorithm", Missing[]] ===
        "DirectBoundedEndpointExpression-and-EndpointPowerRecords-v1"],
    "Upstream" -> TrueQ[
      Lookup[cacheRecord, "S04SourceSHA256", Missing[]] ===
        expectedS04SourceHash &&
      Lookup[cacheRecord, "S04ResultSHA256", Missing[]] ===
        expectedS04ResultHash &&
      Lookup[cacheRecord, "MasterCacheSHA256", Missing[]] ===
        FileHash[masterCachePath, "SHA256", "HexString"] &&
      Lookup[cacheRecord,
        "CoefficientCacheProducerHashes", Missing[]] ===
          acceptedCoefficientCacheProducerHashes &&
      Lookup[cacheRecord, "RootGroupCacheV2SHA256", Missing[]] ===
        expectedRootGroupCacheV2Hash],
    "TaskIdentity" -> TrueQ[
      Lookup[cacheRecord, "Label", Missing[]] === label &&
      Lookup[cacheRecord, "EpsilonPower", Missing[]] === epsilonPower &&
      Lookup[cacheRecord, "ProductIndex", Missing[]] === productIndex &&
      Lookup[cacheRecord, "ProductSHA256", Missing[]] === productHash],
    "RecordContent" -> TrueQ[
      ListQ[Lookup[cacheRecord, "EndpointPowerRecords", Missing[]]] &&
      Lookup[cacheRecord, "EndpointRecordsSHA256", Missing[]] ===
        stableContentHash[
          Lookup[cacheRecord, "EndpointPowerRecords", Missing[]]]],
    "ClosedExactRecords" -> TrueQ[
      AllTrue[Lookup[cacheRecord, "EndpointPowerRecords", {}],
        MatchQ[#, {power_Integer /; power < 0, _}] &] &&
      ! badSymbolicQ[
        Lookup[cacheRecord, "EndpointPowerRecords", Missing[]]] &&
      FreeQ[Lookup[cacheRecord, "EndpointPowerRecords", Missing[]],
        s23 | epsilon | _SeriesData | _Real]],
    "EmbeddedChecks" -> TrueQ[
      AssociationQ[Lookup[cacheRecord, "Checks", Missing[]]] &&
      And @@ Values[Lookup[cacheRecord, "Checks", <||>]]]|>;
  require[And @@ Values[reloadChecks],
    label <> " direct endpoint cache reload gates failed",
    <|"Path" -> cachePath, "Checks" -> reloadChecks|>];
  Print["S05_DIRECT_ENDPOINT_CACHE_", status, "=", label,
    " INPUT=", productIndex,
    " PRODUCT_SHA256=", productHash,
    " RECORDS_SHA256=", cacheRecord["EndpointRecordsSHA256"]];
  cacheRecord["EndpointPowerRecords"]
];
boundedExactAdd[left_, right_, label_String] := Module[{answer},
  If[TrueQ[left === 0], Return[right]];
  If[TrueQ[right === 0], Return[left]];
  If[TrueQ[left === -right], Return[0]];
  answer = Quiet@Check[Cancel[Together[left + right]], $Failed];
  require[answer =!= $Failed && ! badSymbolicQ[answer] &&
      FreeQ[answer, s23 | epsilon | _SeriesData | _Real],
    label <> " balanced exact addition failed"];
  answer
];
balancedExactSum[values_List, label_String] := Module[
  {level, groups, next, denominator},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed && ! badSymbolicQ[level],
    label <> " rational canonicalization failed"];
  groups = GatherBy[level, Denominator];
  level = Map[Function[group,
    denominator = Denominator[First[group]];
    Cancel[Total[Numerator /@ group]/denominator]], groups];
  level = DeleteCases[level, 0];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Map[If[Length[#] === 1, First[#],
        boundedExactAdd[#[[1]], #[[2]], label]] &,
      Partition[level, UpTo[2]]];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];
exactAdditiveSum[values_List, label_String] := Module[
  {terms, answer},
  terms = DeleteCases[values, 0];
  answer = If[terms === {}, 0, Total[terms]];
  require[! badSymbolicQ[answer] &&
      FreeQ[answer, hqqV2S05Tau | s23 | epsilon |
        _SeriesData | _Real],
    label <> " exact additive sum failed"];
  answer
];
SetAttributes[streamingExactAccumulate, HoldFirst];
streamingExactAccumulate[accumulator_, bucket_, value_,
    label_String] := Module[
  {canonical, denominator, numerator, denominatorHash,
   groups, group, levels, level = 0, carry},
  If[! KeyExistsQ[accumulator, bucket],
    AssociateTo[accumulator, bucket -> <||>]];
  If[TrueQ[value === 0], Return[Null]];
  canonical = Quiet@Check[Cancel[Together[value]], $Failed];
  require[canonical =!= $Failed && ! badSymbolicQ[canonical] &&
      FreeQ[canonical, hqqV2S05Tau | s23 | epsilon |
        _SeriesData | _Real],
    label <> " streaming rational canonicalization failed"];
  If[TrueQ[canonical === 0], Return[Null]];
  denominator = Denominator[canonical];
  numerator = Numerator[canonical];
  denominatorHash = IntegerString[Hash[denominator, "SHA256"], 16, 64];
  groups = accumulator[bucket];
  If[KeyExistsQ[groups, denominatorHash],
    group = groups[denominatorHash];
    require[SameQ[group["Denominator"], denominator],
      label <> " streaming denominator hash collision",
      denominatorHash],
    group = <|"Denominator" -> denominator, "Levels" -> <||>|>];
  levels = group["Levels"];
  carry = numerator;
  While[KeyExistsQ[levels, level],
    carry = boundedExactAdd[levels[level], carry,
      label <> "/denominator " <> StringTake[denominatorHash, 12] <>
        "/numerator-binary-level " <> ToString[level]];
    KeyDropFrom[levels, level];
    level++;
    If[TrueQ[carry === 0], Break[]]];
  If[! TrueQ[carry === 0], AssociateTo[levels, level -> carry]];
  AssociateTo[group, "Levels" -> levels];
  AssociateTo[groups, denominatorHash -> group];
  AssociateTo[accumulator, bucket -> groups];
  Clear[canonical, denominator, numerator, groups, group, levels, carry];
  Null
];
streamingExactTotals[accumulator_Association,
    label_String] := Module[{capturedGroupTotals = <||>, totals},
  totals = Association@KeyValueMap[
    Function[{bucket, groups}, bucket -> Module[
      {groupTotals},
      groupTotals = KeyValueMap[Function[{denominatorHash, group},
        Cancel[balancedExactSum[
          Values[KeySort[group["Levels"]]],
          label <> "/bucket " <> ToString[InputForm[bucket]] <>
            "/denominator " <> StringTake[denominatorHash, 12]]/
          group["Denominator"]]], KeySort[groups]];
      groupTotals = DeleteCases[groupTotals, 0];
      AssociateTo[capturedGroupTotals, bucket -> groupTotals];
      Print["S05_DENOMINATOR_GROUP_TOTALS=", label,
        " BUCKET=", InputForm[bucket],
        " INPUT_GROUPS=", Length[groups],
        " NONZERO_GROUPS=", Length[groupTotals]];
      exactAdditiveSum[groupTotals,
        label <> "/bucket " <> ToString[InputForm[bucket]] <>
          "/additive-denominator-groups"]]], KeySort[accumulator]];
  If[rootSubsetDiagnosticMode &&
      StringContainsQ[label,
        "complete-structural-B19-subset/physical"],
    rootSubsetDenominatorGroupTotals = capturedGroupTotals];
  totals
];
b19EndpointPowerDataFromAccumulator[
    accumulator_Association, productCount_Integer, label_String,
    epsilonPower_Integer, recordQ_: True] := Module[
  {tauPowers, totals, oddPowers, oddChecks, endpointData,
   partialCounts, denominatorGroupCounts,
   maximumPartialCount, maximumDenominatorGroupCount},
  require[productCount > 0,
    label <> " family B19 endpoint-power subset is empty"];
  tauPowers = Sort[Keys[accumulator]];
  require[tauPowers =!= {} &&
      AllTrue[tauPowers, IntegerQ[#] && # <= -2 &],
    label <> " family B19 tau-power inventory failed", tauPowers];
  totals = streamingExactTotals[accumulator, label <> "/physical"];
  oddPowers = Select[tauPowers, OddQ];
  oddChecks = Association@Table[tauPower ->
      (SameQ[totals[tauPower], 0] ||
        TrueQ[Quiet@Check[
          Cancel[Together[totals[tauPower]]] === 0, False]]),
    {tauPower, oddPowers}];
  require[And @@ Values[oddChecks],
    label <> " family B19 odd tau powers did not cancel",
    Keys@Select[oddChecks, Not]];
  endpointData = Association@Table[
    tauPower/2 -> totals[tauPower],
    {tauPower, Select[tauPowers, EvenQ]}];
  endpointData = Association@Select[Normal[endpointData],
    ! TrueQ[Last[#] === 0] &];
  require[AssociationQ[endpointData] &&
      AllTrue[Keys[endpointData], IntegerQ[#] && # < 0 &] &&
      ! badSymbolicQ[Values[endpointData]] &&
      FreeQ[Values[endpointData], hqqV2S05Tau | s23 | epsilon |
        _SeriesData | _Real],
    label <> " family B19 endpoint-power data failed"];
  partialCounts = Association@KeyValueMap[
    Function[{tauPower, groups}, tauPower -> Total[
      Length[# ["Levels"]] & /@ Values[groups]]],
    KeySort[accumulator]];
  denominatorGroupCounts = Map[Length, KeySort[accumulator]];
  maximumPartialCount = Max[Values[partialCounts]];
  maximumDenominatorGroupCount = Max[Values[denominatorGroupCounts]];
  If[TrueQ[recordQ], Internal`StuffBag[b19RootFallbackBag,
    <|"Label" -> label, "EpsilonPower" -> epsilonPower,
      "ProductCount" -> productCount,
      "Mode" -> "streamed physical-principal B19 tau-power buckets",
      "TauPowers" -> tauPowers, "PhysicalPrincipalRoot" -> True,
      "OddTauPowersCancel" -> True,
      "AccumulatorPartialCounts" -> partialCounts,
      "DenominatorGroupCounts" -> denominatorGroupCounts,
      "MaximumRetainedPartialsPerTauPower" ->
        maximumPartialCount,
      "MaximumDenominatorGroupsPerTauPower" ->
        maximumDenominatorGroupCount|>]];
  <|"EndpointPowerData" -> endpointData,
    "TauPowers" -> tauPowers,
    "ProductCount" -> productCount,
    "PhysicalPrincipalRoot" -> True,
    "OddTauPowersCancel" -> True,
    "AccumulatorPartialCounts" -> partialCounts,
    "DenominatorGroupCounts" -> denominatorGroupCounts,
    "MaximumRetainedPartialsPerTauPower" ->
      maximumPartialCount,
    "MaximumDenominatorGroupsPerTauPower" ->
      maximumDenominatorGroupCount|>
];
familyB19EndpointPowerData[products_List, label_String,
    epsilonPower_Integer, recordQ_: True] := Module[
  {tauAccumulator = <||>, records, record, productIndex},
  require[products =!= {},
    label <> " family B19 endpoint-power subset is empty"];
  Do[
    records = b19EndpointTauPowerRecords[
      products[[productIndex]],
      label <> "/product " <> ToString[productIndex]];
    Do[streamingExactAccumulate[tauAccumulator,
      record[[1]], record[[2]], label <> "/physical/tau " <>
        ToString[record[[1]]]], {record, records}];
    Print["S05_B19_PRODUCT_DONE=", label,
      " PRODUCT=", productIndex, "/", Length[products],
      " TAU_BUCKETS=", Length[tauAccumulator],
      " MEMORY_KIB=", Quotient[MemoryInUse[], 1024]];
    Clear[records, record],
    {productIndex, Length[products]}];
  b19EndpointPowerDataFromAccumulator[tauAccumulator,
    Length[products], label, epsilonPower, recordQ]
];
termwiseEndpointPowerData[products_List, label_String,
    epsilonPower_Integer, recordFallbackQ_: True,
    useAcceptedRootCache_: False] := Module[
  {endpointAccumulator = <||>, rootTauAccumulator = <||>,
   endpointSeries, records, record, rootData,
   endpointPower, coefficient, productIndex, product,
   rootProductCount = 0, directProductCount = 0, answer,
   currentRootQ, rootFlags = {}, rootIndices = {}, rootProducts,
   rootProductsHash, rootCache, rootGroupTotals, rootCacheChecks,
   tauPower, groups, group, strongerPowers,
   strongerReductionChecks},
  require[! TrueQ[useAcceptedRootCache] || epsilonPower === 1,
    label <> " accepted root cache is valid only at epsilon power 1"];
  If[TrueQ[useAcceptedRootCache],
    rootCache = loadAcceptedRootGroupCache[];
    rootFlags = b19RootProductQ /@ products;
    require[VectorQ[rootFlags, BooleanQ] && Or @@ rootFlags,
      label <> " cached-root structural inventory failed"];
    rootIndices = Pick[Range[Length[products]], rootFlags, True];
    rootProducts = Pick[products, rootFlags, True];
    rootProductsHash = IntegerString[
      Hash[rootProducts, "SHA256"], 16, 64];
    rootCacheChecks = <|
      "TotalProductCount" -> TrueQ[
        Length[products] === rootCache["TotalProductCount"]],
      "RootProductCount" -> TrueQ[
        Length[rootProducts] === rootCache["RootProductCount"]],
      "RootIndices" -> TrueQ[
        rootIndices === rootCache["RootIndices"]],
      "RootProductsSHA256" -> TrueQ[
        rootProductsHash === rootCache["RootProductsSHA256"]]|>;
    require[And @@ Values[rootCacheChecks],
      label <> " current products do not match accepted root cache",
      rootCacheChecks];
    rootProductCount = Length[rootProducts];
    Print["S05_ROOT_GROUP_CACHE_MATCH=", label, " ", InputForm[<|
      "TotalProducts" -> Length[products],
      "RootProducts" -> rootProductCount,
      "RootProductsSHA256" -> rootProductsHash|>]];
    Clear[rootProducts]];
  Do[
    product = products[[productIndex]];
    currentRootQ = If[TrueQ[useAcceptedRootCache],
      TrueQ[rootFlags[[productIndex]]], b19RootProductQ[product]];
    If[currentRootQ,
      If[TrueQ[useAcceptedRootCache],
        Clear[product, currentRootQ];
        Continue[]];
      rootProductCount++;
      records = b19EndpointTauPowerRecords[product,
        label <> "/B19-structural-family-subset/product " <>
          ToString[rootProductCount]];
      Do[streamingExactAccumulate[rootTauAccumulator,
        record[[1]], record[[2]], label <>
          "/B19-structural-family-subset/physical/tau " <>
          ToString[record[[1]]]], {record, records}];
      Print["S05_ENDPOINT_PRODUCT_DONE=", label,
        " INPUT=", productIndex, "/", Length[products],
        " MODE=B19 ROOT_PRODUCTS=", rootProductCount,
        " MEMORY_KIB=", Quotient[MemoryInUse[], 1024]];
      Clear[product, records, record, currentRootQ];
      Continue[]];
    directProductCount++;
    If[TrueQ[useAcceptedRootCache],
      records = loadOrComputeDirectEndpointRecords[
        product, label, epsilonPower, productIndex],
      endpointSeries = directBoundedEndpointExpression[product];
      require[endpointSeries =!= $Failed,
        label <> "/product " <> ToString[productIndex] <>
          " non-B19 direct endpoint series failed"];
      records = endpointPowerRecords[endpointSeries,
        label <> "/product " <> ToString[productIndex]]];
    Do[
      endpointPower = record[[1]];
      coefficient = record[[2]];
      streamingExactAccumulate[endpointAccumulator,
        endpointPower, coefficient, label <> "/s23 " <>
          ToString[endpointPower]],
      {record, records}];
    Print["S05_ENDPOINT_PRODUCT_DONE=", label,
      " INPUT=", productIndex, "/", Length[products],
      " MODE=DIRECT ROOT_PRODUCTS=", rootProductCount,
      " MEMORY_KIB=", Quotient[MemoryInUse[], 1024]];
    Clear[product, endpointSeries, records, record,
      endpointPower, coefficient, currentRootQ],
    {productIndex, Length[products]}];
  If[TrueQ[useAcceptedRootCache],
    rootGroupTotals = rootCache["GroupTotalsByTauPower"];
    KeyValueMap[Function[{cachedTauPower, cachedGroups},
      require[EvenQ[cachedTauPower] && cachedTauPower <= -2,
        label <> " cached root tau power cannot map to s23",
        cachedTauPower];
      Scan[Function[cachedGroup,
        streamingExactAccumulate[endpointAccumulator,
          cachedTauPower/2, cachedGroup,
          label <> "/cached-root/s23 " <>
            ToString[cachedTauPower/2]]], cachedGroups]],
      KeySort[rootGroupTotals]];
    If[TrueQ[recordFallbackQ],
      Internal`StuffBag[b19RootFallbackBag, <|
        "Label" -> label <> "/B19-structural-family-subset",
        "EpsilonPower" -> epsilonPower,
        "ProductCount" -> rootProductCount,
        "Mode" -> "accepted cached physical-principal B19 tau-power groups",
        "TauPowers" -> rootCache["TauPowers"],
        "PhysicalPrincipalRoot" -> True,
        "AcceptedRootGroupCacheSHA256" ->
          expectedRootGroupCacheHash|>]];
    Print["S05_FAMILY_B19_ENDPOINT_CACHE_MERGED=", label,
      " EPSILON_POWER=", epsilonPower,
      " ROOT_PRODUCTS_SKIPPED=", rootProductCount,
      " DIRECT_PRODUCTS_PROCESSED=", directProductCount,
      " TAU_POWERS=", InputForm[rootCache["TauPowers"]],
      " GROUP_COUNTS=", InputForm[Map[Length, rootGroupTotals]]];
    Clear[rootCache, rootGroupTotals, rootFlags, rootIndices,
      rootProductsHash, rootCacheChecks],
    If[rootProductCount > 0,
      rootData = b19EndpointPowerDataFromAccumulator[
        rootTauAccumulator, rootProductCount,
        label <> "/B19-structural-family-subset", epsilonPower,
        recordFallbackQ];
      KeyValueMap[Function[{power, value},
        streamingExactAccumulate[endpointAccumulator, power, value,
          label <> "/s23 " <> ToString[power]]],
        rootData["EndpointPowerData"]];
      Print["S05_FAMILY_B19_ENDPOINT_SUBSET=", label,
        " EPSILON_POWER=", epsilonPower,
        " PRODUCTS=", rootData["ProductCount"],
        " TAU_POWERS=", InputForm[rootData["TauPowers"]]];
      Clear[rootData]]];
  Clear[rootTauAccumulator];
  answer = streamingExactTotals[endpointAccumulator, label <> "/s23"];
  strongerReductionChecks = <||>;
  If[TrueQ[useAcceptedRootCache],
    strongerPowers = Select[Keys[answer], # < -1 &];
    strongerReductionChecks = Association@Table[endpointPower -> Module[
        {reduced, physicalReduced},
        reduced = If[TrueQ[answer[endpointPower] === 0], 0,
          Quiet@Check[Cancel[Together[answer[endpointPower]]], $Failed]];
        require[reduced =!= $Failed && ! badSymbolicQ[reduced] &&
            FreeQ[reduced, s23 | epsilon | _SeriesData | _Real],
          label <> " complete-family stronger endpoint reduction failed",
          endpointPower];
        physicalReduced = physicalEndpointReduce[reduced];
        require[physicalReduced =!= $Failed &&
            ! badSymbolicQ[physicalReduced] &&
            FreeQ[physicalReduced,
              s23 | epsilon | _SeriesData | _Real],
          label <>
            " complete-family physical stronger endpoint reduction failed",
          endpointPower];
        require[TrueQ[physicalReduced === 0],
          label <>
            " complete-family physical stronger endpoint power did not cancel",
          <|"EndpointPower" -> endpointPower,
            "InvariantLeafCount" -> LeafCount[reduced],
            "InvariantByteCount" -> ByteCount[reduced],
            "PhysicalLeafCount" -> LeafCount[physicalReduced],
            "PhysicalByteCount" -> ByteCount[physicalReduced]|>];
        AssociateTo[answer, endpointPower -> 0];
        True], {endpointPower, strongerPowers}];
    Print["S05_COMPLETE_FAMILY_STRONGER_ENDPOINT_CHECKS=", label,
      " ", InputForm[strongerReductionChecks]]];
  require[! badSymbolicQ[answer] &&
      FreeQ[Values[answer], s23 | epsilon | _SeriesData | _Real],
    label <> " termwise endpoint-power buckets failed"];
  answer
];

endpointTermwiseProbeSets = {
  {(endpointProbeA + endpointProbeB s23)/
      (s23^2 (1 + endpointProbeC s23)),
   (endpointProbeD + endpointProbeE s23)/
      (s23 (1 - endpointProbeF s23)),
   (-endpointProbeA + endpointProbeG s23)/
      (s23^2 (1 + endpointProbeH s23))},
  {(endpointProbeI + endpointProbeJ s23)/
      (s23^3 (2 + endpointProbeK s23)),
   (-endpointProbeI + endpointProbeL s23)/
      (s23^3 (2 + endpointProbeK s23)),
   (endpointProbeM + endpointProbeN s23)/
      (s23^2 (1 - endpointProbeO s23))}};
endpointTermwiseLinearityProbePassed = And @@ MapIndexed[
  Function[{terms, position}, Module[
    {label, termwiseData, termwiseExpression, combinedExpression},
    label = "endpoint termwise probe " <>
      ToString[First[position]];
    termwiseData = termwiseEndpointPowerData[terms, label, 0];
    termwiseExpression = Total@KeyValueMap[
      Function[{power, coefficient}, coefficient s23^power],
      termwiseData];
    combinedExpression = boundedEndpointExpression[
      Total[terms], label <> "/combined", 0];
    TrueQ[Cancel[Together[
      termwiseExpression - combinedExpression]] === 0]
  ]], endpointTermwiseProbeSets];
require[TrueQ[endpointTermwiseLinearityProbePassed],
  "S05 termwise endpoint linearity probe failed"];
Print["S05_ENDPOINT_TERMWISE_LINEARITY_PROBE_OK=",
  Length[endpointTermwiseProbeSets]];
Clear[endpointTermwiseProbeSets];

endpointFamilyRootProbeProducts = {
  Sqrt[commonB19Radicand]/s23,
  (endpointRootProbeA - Sqrt[commonB19Radicand])/s23};
endpointFamilyRootProbeData = familyB19EndpointPowerData[
  endpointFamilyRootProbeProducts, "endpoint family B19 probe", 0,
  False];
endpointFamilyRootProbeExpression = Total@KeyValueMap[
  Function[{power, coefficient}, coefficient s23^power],
  endpointFamilyRootProbeData["EndpointPowerData"]];
endpointFamilyRootProbeCombined = boundedEndpointExpression[
  Total[endpointFamilyRootProbeProducts],
  "endpoint family B19 probe/combined", 0];
endpointFamilyB19ProbePassed =
  TrueQ[endpointFamilyRootProbeData["PhysicalPrincipalRoot"]] &&
  TrueQ[endpointFamilyRootProbeData["OddTauPowersCancel"]] &&
  endpointFamilyRootProbeData["ProductCount"] === 2 &&
  TrueQ[Cancel[Together[
      endpointFamilyRootProbeExpression -
        endpointFamilyRootProbeCombined]] === 0];
require[TrueQ[endpointFamilyB19ProbePassed],
  "S05 family-subset B19 endpoint probe failed"];
Print["S05_ENDPOINT_FAMILY_B19_PROBE_OK=",
  endpointFamilyRootProbeData["ProductCount"]];
Clear[endpointFamilyRootProbeProducts,
  endpointFamilyRootProbeData, endpointFamilyRootProbeExpression,
  endpointFamilyRootProbeCombined];

endpointFamilyRootRoutingProbeProducts = {
  Sqrt[commonB19Radicand/s23]/Sqrt[s23],
  endpointRootRoutingProbeA/s23 -
    Sqrt[commonB19Radicand/s23]/Sqrt[s23]};
endpointFamilyRootRoutingProbeDirect =
  directBoundedEndpointExpression /@
    endpointFamilyRootRoutingProbeProducts;
endpointFamilyRootRoutingProbeSplits = Map[
  If[# === $Failed, $Failed, endpointPowerRecordsCandidate[#]] &,
  endpointFamilyRootRoutingProbeDirect];
endpointFamilyRootRoutingProbeDetected = AnyTrue[MapThread[
  Function[{direct, split}, direct =!= $Failed && split === $Failed],
  {endpointFamilyRootRoutingProbeDirect,
    endpointFamilyRootRoutingProbeSplits}], TrueQ];
endpointFamilyRootRoutingProbeData = termwiseEndpointPowerData[
  endpointFamilyRootRoutingProbeProducts,
  "endpoint family B19 routing probe", 0, False];
endpointFamilyRootRoutingProbeExpression = Total@KeyValueMap[
  Function[{power, coefficient}, coefficient s23^power],
  endpointFamilyRootRoutingProbeData];
endpointFamilyRootRoutingProbeCombined = boundedEndpointExpression[
  Total[endpointFamilyRootRoutingProbeProducts],
  "endpoint family B19 routing probe/combined", 0];
endpointFamilyB19RoutingProbePassed =
  TrueQ[endpointFamilyRootRoutingProbeDetected] &&
  KeyExistsQ[endpointFamilyRootRoutingProbeData, -1] &&
  TrueQ[Cancel[Together[
      endpointFamilyRootRoutingProbeExpression -
        endpointFamilyRootRoutingProbeCombined]] === 0];
require[TrueQ[endpointFamilyB19RoutingProbePassed],
  "S05 family-subset B19 routing probe failed"];
Print["S05_ENDPOINT_FAMILY_B19_ROUTING_PROBE_OK=",
  Length[endpointFamilyRootRoutingProbeProducts]];
Clear[endpointFamilyRootRoutingProbeProducts,
  endpointFamilyRootRoutingProbeDirect,
  endpointFamilyRootRoutingProbeSplits,
  endpointFamilyRootRoutingProbeDetected,
  endpointFamilyRootRoutingProbeData,
  endpointFamilyRootRoutingProbeExpression,
  endpointFamilyRootRoutingProbeCombined];

endpointFamilyRootPowerProbeProducts = {
  Sqrt[commonB19Radicand]/s23^2,
  endpointRootPowerProbeA/s23 -
    Sqrt[commonB19Radicand]/s23^2};
endpointFamilyRootPowerProbeFirstRecords =
  b19EndpointTauPowerRecords[
    First[endpointFamilyRootPowerProbeProducts],
    "endpoint family B19 stronger-power probe/first"];
endpointFamilyRootPowerProbeData = familyB19EndpointPowerData[
  endpointFamilyRootPowerProbeProducts,
  "endpoint family B19 stronger-power probe", 0, False];
endpointFamilyRootPowerProbeExpression = Total@KeyValueMap[
  Function[{power, coefficient}, coefficient s23^power],
  endpointFamilyRootPowerProbeData["EndpointPowerData"]];
endpointFamilyRootPowerProbeCombined = boundedEndpointExpression[
  Total[endpointFamilyRootPowerProbeProducts],
  "endpoint family B19 stronger-power probe/combined", 0];
endpointFamilyB19PowerProbePassed =
  MemberQ[endpointFamilyRootPowerProbeFirstRecords, {-4, _}] &&
  TrueQ[endpointFamilyRootPowerProbeData["PhysicalPrincipalRoot"]] &&
  TrueQ[endpointFamilyRootPowerProbeData["OddTauPowersCancel"]] &&
  endpointFamilyRootPowerProbeData["ProductCount"] === 2 &&
  Keys[endpointFamilyRootPowerProbeData["EndpointPowerData"]] === {-1} &&
  TrueQ[Cancel[Together[
      endpointFamilyRootPowerProbeExpression -
        endpointFamilyRootPowerProbeCombined]] === 0];
require[TrueQ[endpointFamilyB19PowerProbePassed],
  "S05 family-subset B19 stronger-power probe failed"];
Print["S05_ENDPOINT_FAMILY_B19_POWER_PROBE_OK=",
  InputForm[endpointFamilyRootPowerProbeData["TauPowers"]]];
Clear[endpointFamilyRootPowerProbeProducts,
  endpointFamilyRootPowerProbeFirstRecords,
  endpointFamilyRootPowerProbeData,
  endpointFamilyRootPowerProbeExpression,
  endpointFamilyRootPowerProbeCombined];

If[startupProbeMode,
  Print["S05_STARTUP_PROBES_OK=", InputForm[<|
    "EndpointTermwiseLinearity" -> endpointTermwiseLinearityProbePassed,
    "PhysicalPrincipalRoot" -> endpointFamilyB19ProbePassed,
    "StructuralRouting" -> endpointFamilyB19RoutingProbePassed,
    "StrongerPowerBuckets" -> endpointFamilyB19PowerProbePassed|>]];
  Quit[0]
];

carrierCoefficient[data_Association, alpha_Integer, power_Integer] :=
  Total@Table[If[sourcePower <= power,
      Lookup[data, sourcePower, 0] *
        (-alpha Log[s23])^(power - sourcePower)/
          Factorial[power - sourcePower], 0],
    {sourcePower, Keys[data]}];
endpointPolynomial[data_Association] := associationExpression[data];

assembleFromBare[projector_String, family_String,
    groupedBare_Association] := Module[
  {fixedPairBags, ordinaryFixedPairBags, endpointBags,
   consumed = <||>, ordinaryKeys, ordinaryGroups,
   ordinaryCoefficientTasks, ordinaryCoefficientRecords,
   key, masterData, phaseCoefficientData, ordinaryFixedProducts,
   ordinaryPowerData, ordinaryEndpointProductCounts = <||>,
   endpointPower, masterPower, leftCoefficient,
   group, activeKeys, combinedBare, branchData,
   fixedData, ordinaryEndpointPowerData = <||>,
   ordinaryResidueData, strongerPhysicalReductions,
   strongerCancellationChecks, endpointData, fixedDensity, singularDensity,
   ordinaryData, deltaExpression, plusExpression,
   deltaData, plusData, checks, alpha, power,
   groupedMasterCount, ordinaryGroupCount,
   everyMasterConsumedOnce, ordinaryGroupsCoverKeys},
  groupedMasterCount = Length[groupedBare];
  Print["S05_ASSEMBLE=", projector, "/", family,
    " MASTERS=", groupedMasterCount];
  fixedPairBags = Association@Table[
    power -> newExactBag[], {power, -1, 1}];
  ordinaryFixedPairBags = Association@Table[
    power -> newExactBag[], {power, -1, 1}];
  endpointBags = Association@Table[alpha ->
    Association@Table[power -> newExactBag[], {power, -1, 1}],
    {alpha, distributionAlphas}];
  Do[
    activeKeys = Select[group, KeyExistsQ[groupedBare, #] &];
    If[activeKeys === {}, Continue[]];
    combinedBare = Total[weightCoefficient[family, groupedBare[#]] & /@
      activeKeys];
    key = First[activeKeys];
    masterData = angularLaurentLedger[key]["LaurentThroughEpsilon1"];
    phaseCoefficientData = fixedCoefficientSeries[combinedBare,
      projector <> "/" <> family <> "/special"];
    Do[
      leftCoefficient = Lookup[
        phaseCoefficientData, power - masterPower, 0];
      If[! TrueQ[leftCoefficient === 0] &&
          ! TrueQ[masterData[masterPower] === 0],
        Internal`StuffBag[fixedPairBags[power],
          {leftCoefficient, masterData[masterPower]}]],
      {power, -1, 1}, {masterPower, Keys[masterData]}];
    branchData = eulerEndpointData[key, combinedBare,
      projector <> "/" <> family <> "/special"];
    Do[
      Internal`StuffBag[
        endpointBags[branchData["RegularAlpha"], power],
        branchData["RegularResidue"][power]];
      Internal`StuffBag[
        endpointBags[branchData["FractionalAlpha"], power],
        branchData["FractionalResidue"][power]],
      {power, -1, 1}];
    Scan[(AssociateTo[consumed, # -> True]) &, activeKeys],
    {group, endpointMasterGroups}];
  ordinaryKeys = Select[Keys[groupedBare], ! KeyExistsQ[consumed, #] &];
  ordinaryGroups = GatherBy[ordinaryKeys,
    angularLaurentLedger[#]["LaurentThroughEpsilon1"] &];
  ordinaryGroupCount = Length[ordinaryGroups];
  Print["S05_ORDINARY_GROUPS=", projector, "/", family, " ",
    Length[ordinaryKeys], "->", ordinaryGroupCount];
  ordinaryCoefficientTasks = buildOrdinaryCoefficientTasks[
    ordinaryGroups, groupedBare, family];
  ordinaryCoefficientRecords = runFixedCoefficientTasks[
    ordinaryCoefficientTasks, projector <> "/" <> family];
  Print["S05_ORDINARY_PHASE_SERIES_DONE=", projector, "/", family,
    " TASKS=", Length[ordinaryCoefficientRecords]];
  MapThread[Function[{ordinaryGroup, coefficientRecord},
    key = First[ordinaryGroup];
    masterData = angularLaurentLedger[key]["LaurentThroughEpsilon1"];
    phaseCoefficientData = coefficientRecord["PhaseCoefficientData"];
    Do[
      Do[
        leftCoefficient = Lookup[
          phaseCoefficientData, power - masterPower, 0];
        If[! TrueQ[leftCoefficient === 0] &&
            ! TrueQ[masterData[masterPower] === 0],
          Internal`StuffBag[fixedPairBags[power],
            {leftCoefficient, masterData[masterPower]}];
          Internal`StuffBag[ordinaryFixedPairBags[power],
            {leftCoefficient, masterData[masterPower]}]],
        {masterPower, Keys[masterData]}],
      {power, -1, 1}]
  ], {ordinaryGroups, ordinaryCoefficientRecords}];
  Print["S05_ORDINARY_PAIR_ACCUMULATION_DONE=", projector, "/", family];
  fixedData = Association@Table[
    power -> groupedFixedPairTotal[fixedPairBags[power],
      projector <> "/" <> family <> "/epsilon " <> ToString[power]],
    {power, -1, 1}];
  everyMasterConsumedOnce =
    Sort@Join[Keys[consumed], ordinaryKeys] === Sort[Keys[groupedBare]];
  ordinaryGroupsCoverKeys =
    Sort[Flatten[ordinaryGroups, 1]] === Sort[ordinaryKeys];
  Clear[fixedPairBags, ordinaryCoefficientTasks,
    ordinaryCoefficientRecords, phaseCoefficientData, masterData,
    leftCoefficient, key, ordinaryGroups, ordinaryKeys, consumed];
  Print["S05_ORDINARY_ENDPOINT_ACTION=", projector, "/", family,
    " GROUPED_PRODUCTS"];
  Do[
    ordinaryFixedProducts = groupedFixedPairProducts[
      ordinaryFixedPairBags[power],
      projector <> "/" <> family <> "/ordinary-family/epsilon " <>
        ToString[power]];
    AssociateTo[ordinaryEndpointProductCounts,
      power -> Length[ordinaryFixedProducts]];
    AssociateTo[ordinaryFixedPairBags, power -> newExactBag[]];
    Print["S05_ORDINARY_ENDPOINT_PRODUCTS=", projector, "/", family,
      " EPSILON_POWER=", power,
      " COUNT=", ordinaryEndpointProductCounts[power]];
    ordinaryPowerData = termwiseEndpointPowerData[
      ordinaryFixedProducts,
      projector <> "/" <> family <> "/ordinary-family/epsilon " <>
        ToString[power], power, True,
      ! probeMode && projector === "Pg" &&
        family === "Hqq;q_qbar_sameFlavor" && power === 1];
    AssociateTo[ordinaryEndpointPowerData, power -> ordinaryPowerData];
    Print["S05_ORDINARY_ENDPOINT_POWER_DONE=", projector, "/", family,
      " EPSILON_POWER=", power,
      " BUCKETS=", Length[ordinaryPowerData],
      " MEMORY_KIB=", Quotient[MemoryInUse[], 1024]];
    Clear[ordinaryFixedProducts, ordinaryPowerData],
    {power, -1, 1}];
  Clear[ordinaryFixedPairBags];
  Print["S05_ORDINARY_ENDPOINT_ACTION_DONE=", projector, "/", family];
  strongerPhysicalReductions = Association@Table[power ->
    AssociationMap[physicalEndpointReduce[
        ordinaryEndpointPowerData[power][#]] &,
      Select[Keys[ordinaryEndpointPowerData[power]], # < -1 &]],
    {power, -1, 1}];
  require[FreeQ[strongerPhysicalReductions, $Failed] &&
      ! badSymbolicQ[strongerPhysicalReductions] &&
      FreeQ[Values[strongerPhysicalReductions],
        s23 | epsilon | _SeriesData | _Real],
    projector <> "/" <> family <>
      " physical stronger endpoint reductions did not close"];
  strongerCancellationChecks = Association@Table[power ->
    Map[TrueQ[# === 0] &, strongerPhysicalReductions[power]],
    {power, -1, 1}];
  require[And @@ Flatten[Values /@ Values[strongerCancellationChecks]],
    projector <> "/" <> family <>
      " stronger endpoint-power buckets did not cancel",
    strongerCancellationChecks];
  ordinaryResidueData = Association@Table[power ->
    Lookup[ordinaryEndpointPowerData[power], -1, 0], {power, -1, 1}];
  require[! badSymbolicQ[ordinaryResidueData] &&
      FreeQ[ordinaryResidueData, s23 | epsilon | _SeriesData | _Real],
    projector <> "/" <> family <>
      " family endpoint residue is unresolved"];
  Do[Internal`StuffBag[endpointBags[phaseAlpha, power],
      ordinaryResidueData[power]], {power, -1, 1}];
  endpointData = Association@Table[alpha -> Association@Table[
    power -> exactBagTotal[endpointBags[alpha, power]],
    {power, -1, 1}], {alpha, distributionAlphas}];
  Clear[fixedPairBags, endpointBags];
  fixedDensity = Association@Table[
    power -> carrierCoefficient[fixedData, phaseAlpha, power],
    {power, -1, 0}];
  singularDensity = Association@Table[power -> Total@Table[
    carrierCoefficient[endpointData[alpha], alpha, power]/s23,
    {alpha, distributionAlphas}], {power, -1, 0}];
  ordinaryData = Association@Table[
    power -> fixedDensity[power] - singularDensity[power],
    {power, -1, 0}];
  deltaExpression = Total@Table[Normal@Series[
    -s23Upper^(-alpha epsilon)/(alpha epsilon) *
      endpointPolynomial[endpointData[alpha]], {epsilon, 0, 0}],
    {alpha, distributionAlphas}];
  plusExpression = Total@Table[Normal@Series[
    endpointPolynomial[endpointData[alpha]] *
      (HqqV2BoundedPlus[0, s23, s23Upper] -
        alpha epsilon HqqV2BoundedPlus[1, s23, s23Upper]),
    {epsilon, 0, 0}], {alpha, distributionAlphas}];
  deltaData = Association@Table[
    power -> Coefficient[deltaExpression, epsilon, power],
    {power, -2, 0}];
  plusData = Association@Table[
    power -> Coefficient[plusExpression, epsilon, power],
    {power, -1, 0}];
  checks = <|
    "NonemptyGroupedMasters" -> groupedMasterCount > 0,
    "EveryMasterConsumedOnce" -> everyMasterConsumedOnce,
    "OrdinaryGroupsCoverKeys" -> ordinaryGroupsCoverKeys,
    "OrdinaryEndpointActionFamilyLevel" ->
      Sort[Keys[ordinaryEndpointPowerData]] === Range[-1, 1],
    "OrdinaryEndpointProductsProcessed" ->
      Sort[Keys[ordinaryEndpointProductCounts]] === Range[-1, 1] &&
        Total[Values[ordinaryEndpointProductCounts]] > 0,
    "StrongerEndpointPowersCancel" ->
      And @@ Flatten[Values /@ Values[strongerCancellationChecks]],
    "FixedInteriorReconstructs" -> And @@ Table[
      Expand[ordinaryData[power] + singularDensity[power] -
        fixedDensity[power]] === 0, {power, -1, 0}],
    "EndpointCoefficientsS23Free" -> FreeQ[endpointData, s23],
    "ExactClosed" -> ! badSymbolicQ[
      {endpointData, deltaData, plusData, ordinaryData}],
    "NoResidualEpsilon" -> FreeQ[
      {deltaData, plusData, ordinaryData}, epsilon | _SeriesData | _Real],
    "CarrierRemoved" -> FreeQ[
      {deltaData, plusData, ordinaryData}, phaseCarrier]|>;
  require[And @@ Values[checks],
    "real family endpoint action failed", {projector, family, checks}];
  <|"SymmetryWeight" -> symmetryWeights[family],
    "DifferentFlavorSumApplied" ->
      (family === "Hqq;qPrime_qbarPrime"),
    "GroupedMasterCount" -> groupedMasterCount,
    "OrdinaryLaurentGroupCount" -> ordinaryGroupCount,
    "OrdinaryEndpointAction" ->
      "family-level endpoint-power buckets from grouped products",
    "OrdinaryEndpointProductCounts" -> ordinaryEndpointProductCounts,
    "StrongerEndpointPhysicalReduction" ->
      strongerPhysicalReductions,
    "StrongerEndpointCancellation" -> strongerCancellationChecks,
    "EndpointResidueByAlphaThroughEpsilon1" -> endpointData,
    "DeltaLaurent" -> deltaData,
    "BoundedPlusLaurent" -> plusData,
    "OrdinaryLaurent" -> ordinaryData,
    "Checks" -> checks|>
];

ClearAll[runRootSubsetDiagnostic];
runRootSubsetDiagnostic[] := Module[
  {projector = "Pg", family = "Hqq;q_qbar_sameFlavor",
   label, groupedBare, endpointKeys, ordinaryKeys, ordinaryGroups,
   ordinaryCoefficientTasks, ordinaryCoefficientRecords,
   epsilonOnePairBag, ordinaryGroup, coefficientRecord,
   key, masterData, phaseCoefficientData, leftCoefficient,
   masterPower, epsilonOneProducts, completeEndpointPowerData,
   strongerEndpointPowers, strongerCancellationChecks,
   totalProductCount},
  label = projector <> "/" <> family;
  Print["S05_COMPLETE_FAMILY_ENDPOINT_DIAGNOSTIC_START=", label,
    " EPSILON_POWER=1"];
  groupedBare = groupedBareCoefficients[projector, family];
  endpointKeys = DeleteDuplicates@Flatten[
    (Select[#, KeyExistsQ[groupedBare, #] &] & /@
      endpointMasterGroups), 1];
  ordinaryKeys = Select[Keys[groupedBare],
    ! MemberQ[endpointKeys, #] &];
  ordinaryGroups = GatherBy[ordinaryKeys,
    angularLaurentLedger[#]["LaurentThroughEpsilon1"] &];
  ordinaryCoefficientTasks = buildOrdinaryCoefficientTasks[
    ordinaryGroups, groupedBare, family];
  ordinaryCoefficientRecords = runFixedCoefficientTasks[
    ordinaryCoefficientTasks, label];
  require[Length[ordinaryCoefficientRecords] === Length[ordinaryGroups],
    "root-subset diagnostic coefficient inventory failed"];
  epsilonOnePairBag = newExactBag[];
  MapThread[Function[{ordinaryGroup, coefficientRecord},
    key = First[ordinaryGroup];
    masterData = angularLaurentLedger[key]["LaurentThroughEpsilon1"];
    phaseCoefficientData = coefficientRecord["PhaseCoefficientData"];
    Do[
      leftCoefficient = Lookup[
        phaseCoefficientData, 1 - masterPower, 0];
      If[! TrueQ[leftCoefficient === 0] &&
          ! TrueQ[masterData[masterPower] === 0],
        Internal`StuffBag[epsilonOnePairBag,
          {leftCoefficient, masterData[masterPower]}]],
      {masterPower, Keys[masterData]}]
  ], {ordinaryGroups, ordinaryCoefficientRecords}];
  Clear[ordinaryCoefficientTasks, ordinaryCoefficientRecords,
    groupedBare, endpointKeys, ordinaryKeys, ordinaryGroup,
    coefficientRecord, key, masterData, phaseCoefficientData,
    leftCoefficient, masterPower];
  epsilonOneProducts = groupedFixedPairProducts[epsilonOnePairBag,
    label <> "/ordinary-family/epsilon 1"];
  Clear[epsilonOnePairBag, ordinaryGroups];
  totalProductCount = Length[epsilonOneProducts];
  completeEndpointPowerData = termwiseEndpointPowerData[
    epsilonOneProducts,
    label <> "/ordinary-family/epsilon 1", 1, False, True];
  Clear[epsilonOneProducts];
  strongerEndpointPowers = Select[
    Keys[completeEndpointPowerData], # < -1 &];
  strongerCancellationChecks = AssociationMap[
    TrueQ[completeEndpointPowerData[#] === 0] &,
    strongerEndpointPowers];
  require[And @@ Values[strongerCancellationChecks] &&
      KeyExistsQ[completeEndpointPowerData, -1] &&
      ! badSymbolicQ[completeEndpointPowerData] &&
      FreeQ[Values[completeEndpointPowerData],
        s23 | epsilon | _SeriesData | _Real],
    "complete-family cached-root endpoint diagnostic failed",
    strongerCancellationChecks];
  Print["S05_COMPLETE_FAMILY_ENDPOINT_DIAGNOSTIC_OK=", InputForm[<|
    "TotalProducts" -> totalProductCount,
    "StrongerEndpointCancellation" -> strongerCancellationChecks,
    "PhysicalEndpointPower" -> -1,
    "PhysicalResidueAdditive" -> True|>]];
  Clear[completeEndpointPowerData, strongerEndpointPowers,
    strongerCancellationChecks];
  Null
];

If[probeMode,
  probeActions = AssociationMap[Function[projector,
    AssociationMap[Function[family, Module[{pair, selected},
      pair = representativePairs[projector, family];
      selected = If[MemberQ[endpointOneKeys, pair[[1]]],
        First@Select[endpointMasterGroups, MemberQ[#, pair[[1]]] &],
        {pair[[1]]}];
      assembleFromBare[projector, family,
        groupedBareCoefficients[projector, family, selected]]
    ]], families]], projectors];
  b19RootFallbackRecords = Internal`BagPart[b19RootFallbackBag, All];
  probeChecks = <|
    "HypergeometricBranches" ->
      And @@ Flatten[Values /@ Values[hypergeometricChecks]],
    "B18AndB19" -> Sort@DeleteDuplicates[
      Lookup[Values[angularLaurentLedger], "Representation"]] ===
      Sort@{"Paper Eq. (B18), case (1)",
        "Paper Eqs. (B19)-(B20), case (2)"},
    "AllSixActions" -> Length@Cases[probeActions,
      association_Association /; KeyExistsQ[association, "Checks"] :>
        association, Infinity] === Length[projectors] Length[families],
    "ActionChecks" -> And @@ Cases[probeActions,
      association_Association /; KeyExistsQ[association, "Checks"] :>
        And @@ Values[association["Checks"]], Infinity],
    "B19RootJetFallback" -> b19RootFallbackRecords =!= {} &&
      AllTrue[b19RootFallbackRecords,
        TrueQ[# ["PhysicalPrincipalRoot"]] &] &&
      And @@ Values[b19RootJetChecks],
    "Weights" -> And @@ Values[weightChecks],
    "Distributions" ->
      And @@ Flatten[Values /@ Values[distributionChecks]]|>;
  Print["S05_PROBE_CHECKS=", InputForm[probeChecks]];
  require[And @@ Values[probeChecks], "representative probe failed"];
  Print["S05_REPRESENTATIVE_PROBE_OK"];
  Quit[0]
];

If[rootSubsetDiagnosticMode,
  runRootSubsetDiagnostic[];
  Quit[0]
];

realLaurentLedger = AssociationMap[Function[projector,
  AssociationMap[Function[family,
    assembleFromBare[projector, family,
      groupedBareCoefficients[projector, family]]], families]], projectors];
If[assemblyParallelEnabled,
  Quiet[CloseKernels[]];
  require[$KernelCount === 0,
    "S05 assembly workers did not close"];
  Print["S05_ASSEMBLY_WORKERS_CLOSED"];
];
familyChecks = Cases[realLaurentLedger,
  association_Association /; KeyExistsQ[association, "Checks"] :>
    And @@ Values[association["Checks"]], Infinity];
b19RootFallbackRecords = Internal`BagPart[b19RootFallbackBag, All];

checks = <|
  "InputHashes" ->
    FileHash[s04SourcePath, "SHA256", "HexString"] ===
      expectedS04SourceHash &&
    FileHash[s04ResultPath, "SHA256", "HexString"] ===
      expectedS04ResultHash,
  "PinnedHyperIntica" ->
    FileHash[hyperInticaPath, "SHA256", "HexString"] ===
      expectedHyperInticaHash,
  "MasterCacheAccepted" -> FileExistsQ[masterCachePath] &&
    AssociationQ[masterCache] &&
    MemberQ[Append[acceptedMasterCacheProducerHashes,
        FileHash[sourcePath, "SHA256", "HexString"]],
      masterCache["ProducingSourceSHA256"]] &&
    masterCache["AllMasterKeys"] === allMasterKeys &&
    And @@ Values[masterCache["Checks"]],
  "AllMastersEvaluated" ->
    Sort[Keys[angularLaurentLedger]] === Sort[allMasterKeys],
  "MasterCount" -> Length[angularLaurentLedger] ===
    s04["AngularMasters", "DistinctCount"],
  "HypergeometricBranches" ->
    And @@ Flatten[Values /@ Values[hypergeometricChecks]],
  "EveryB19OrderChecked" -> And @@ Flatten[
    Values /@ Values[b19CheckLedger]],
  "B19RootJetFallback" -> b19RootFallbackRecords =!= {} &&
    AllTrue[b19RootFallbackRecords,
      TrueQ[# ["PhysicalPrincipalRoot"]] &&
        TrueQ[Lookup[#, "OddTauPowersCancel", True]] &] &&
    And @@ Values[b19RootJetChecks],
  "AllAngularClosed" -> And @@ Map[
    And @@ Values[# ["Checks"]] &, Values[angularLaurentLedger]],
  "EndpointOneInventory" -> endpointOneKeys =!= {} &&
    AllTrue[endpointOneKeys, KeyExistsQ[angularLaurentLedger, #] &],
  "ChannelWeights" -> And @@ Values[weightChecks],
  "BoundedDistribution" ->
    And @@ Flatten[Values /@ Values[distributionChecks]],
  "EndpointTermwiseLinearityProbe" ->
    TrueQ[endpointTermwiseLinearityProbePassed],
  "EndpointFamilyB19Probe" -> TrueQ[endpointFamilyB19ProbePassed],
  "EndpointFamilyB19RoutingProbe" ->
    TrueQ[endpointFamilyB19RoutingProbePassed],
  "EndpointFamilyB19PowerProbe" ->
    TrueQ[endpointFamilyB19PowerProbePassed],
  "EveryFamilyActionChecked" -> And @@ familyChecks,
  "AdaptiveAssemblyBatches" ->
    AllTrue[assemblyBatchValidationRecords,
      TrueQ[# ["Safe"]] &&
        MemberQ[Range[requestedAssemblyKernels], # ["KernelCount"]] &&
        Length[# ["Indices"]] === # ["KernelCount"] &],
  "CoefficientTaskCache" -> DirectoryQ[coefficientCacheDirectory] &&
    coefficientCacheLoadedCount + coefficientCacheWrittenCount ===
      Length[coefficientCacheValidationRecords] &&
    coefficientCacheLoadedCount + coefficientCacheWrittenCount > 0 &&
    AllTrue[coefficientCacheValidationRecords,
      TrueQ[# ["Valid"]] &] &&
    DuplicateFreeQ[Lookup[coefficientCacheValidationRecords,
      "TaskInputSHA256"]] &&
    AllTrue[Select[coefficientCacheSearchDirectories, DirectoryQ],
      FileNames["*.tmp", #] === {} &],
  "ParallelAssemblyWorkers" ->
    (coefficientCacheWrittenCount === 0 ||
       assemblyWorkerLaunchRecords =!= {}) &&
      And @@ Map[MemberQ[Range[requestedAssemblyKernels],
            # ["KernelCount"]] &&
          Length[# ["KernelIDs"]] === # ["KernelCount"] &&
          DuplicateFreeQ[# ["KernelIDs"]] &&
          # ["Versions"] ===
            ConstantArray[runtimeKernelVersion, # ["KernelCount"]] &&
          TrueQ[# ["OrderProbe"]] && TrueQ[# ["WorkerProbe"]] &&
          TrueQ[# ["TermwiseEquivalenceProbe"]] &&
          TrueQ[# ["RationalCoefficientEquivalenceProbe"]] &,
        assemblyWorkerLaunchRecords] &&
      $KernelCount === 0,
  "ExactSymbolicBoundary" -> ! badSymbolicQ[
    {angularLaurentLedger, realLaurentLedger}],
  "NoVirtualOrFactorizationInput" -> True|>;
require[And @@ Values[checks], "S05 final gates failed", checks];

result = <|
  "Stage" -> "HqqV2S05-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Inputs" -> <|
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "HyperInticaSHA256" -> expectedHyperInticaHash,
    "HyperInticaCommit" -> expectedHyperInticaCommit,
    "MasterCacheSHA256" ->
      FileHash[masterCachePath, "SHA256", "HexString"],
    "AcceptedCoefficientCacheProducerSHA256" ->
      acceptedCoefficientCacheProducerHashes|>,
  "Runtime" -> <|"Wolfram" -> $Version,
    "AngularIntegrationBackend" -> "SubTropica HyperIntica",
    "MasterCacheMode" -> masterCacheMode,
    "AssemblyMaximumParallelKernels" -> requestedAssemblyKernels,
    "AssemblyLastKernelIDs" -> assemblyParallelKernelIDs,
    "AssemblyTaskBatchSize" -> assemblyTaskBatchSize,
    "AssemblyParallelByteBudget" -> assemblyParallelByteBudget,
    "AssemblyWorkerLaunches" -> Length[assemblyWorkerLaunchRecords],
    "AssemblyWorkerLaunchRecords" -> assemblyWorkerLaunchRecords,
    "AssemblyBatchValidationRecords" -> assemblyBatchValidationRecords,
    "OrdinaryEndpointReducer" ->
      "termwise grouped products with family endpoint-power buckets",
    "EndpointTermwiseLinearityProbe" ->
      endpointTermwiseLinearityProbePassed,
    "EndpointFamilyB19Probe" -> endpointFamilyB19ProbePassed,
    "EndpointFamilyB19RoutingProbe" ->
      endpointFamilyB19RoutingProbePassed,
    "EndpointFamilyB19PowerProbe" ->
      endpointFamilyB19PowerProbePassed,
    "CoefficientCacheDirectory" -> coefficientCacheDirectory,
    "CoefficientCacheSearchDirectories" ->
      coefficientCacheSearchDirectories,
    "AcceptedCoefficientCacheAlgorithms" ->
      acceptedCoefficientCacheAlgorithms,
    "CoefficientCacheLoadedCount" -> coefficientCacheLoadedCount,
    "CoefficientCacheWrittenCount" -> coefficientCacheWrittenCount|>,
  "Conventions" -> <|
    "Dimension" -> 4 - 2 epsilon,
    "Scheme" -> "CDR; MS-bar factorization deferred to S07",
    "EndpointInterval" -> {0, s23Upper},
    "PhaseDistributionAlpha" -> phaseAlpha,
    "DistributionAlphas" -> distributionAlphas,
    "AngularLaurentMaximum" -> 1,
    "RealLaurentRange" -> {-2, 0}|>,
  "AngularLaurentMasters" -> <|
    "DistinctCount" -> Length[angularLaurentLedger],
    "Ledger" -> angularLaurentLedger,
    "B19OrderChecks" -> b19CheckLedger,
    "HypergeometricChecks" -> hypergeometricChecks|>,
  "EndpointBranches" -> <|
    "Q2Rule" -> q2Rule,
    "EndpointOneKeys" -> endpointOneKeys,
    "IdenticalMasterGroups" -> endpointMasterGroups,
    "AlphaByEndpointOneKey" -> specialAlphaData,
    "B19RootJet" -> <|
      "CommonRadicand" -> commonB19Radicand,
      "EndpointRoot" -> b19EndpointRoot,
      "DerivedOrder" -> b19RootOrder,
      "FallbackRecords" -> b19RootFallbackRecords,
      "Checks" -> b19RootJetChecks|>,
    "DistributionChecks" -> distributionChecks|>,
  "ChannelWeights" -> <|
    "StateLedger" -> channelStateLedger,
    "SymmetryWeights" -> symmetryWeights,
    "FlavorClasses" -> <|"UpType" -> nUp, "DownType" -> nDown,
      "IncomingType" -> "UpType"|>,
    "DifferentFlavorRule" ->
      HoldForm[(nUp - 1) f[qIncoming] + nDown f[qGenericPair]],
    "Checks" -> weightChecks|>,
  "BoundedDistributionDefinition" -> <|
    "PlusHead" -> HoldForm[HqqV2BoundedPlus[n, s23, s23Upper]],
    "Interval" -> {0, s23Upper},
    "Checks" -> distributionChecks|>,
  "RealLaurentLedger" -> realLaurentLedger,
  "DownstreamBoundary" -> <|
    "S06" -> "virtual analytic continuation and two-body phase space only",
    "S07" -> "first MS-bar factorization and pole-cancellation stage"|>,
  "Checks" -> checks|>;

require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing S05 result", resultPath];
atomicPut[result, resultPath];
Print["S05_CANDIDATE_WRITTEN=", resultPath];
Print["S05_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
freshValidationCode = StringJoin[
  "candidate=Quiet[Check[Get[",
    ToString[InputForm[resultPath]], "],$Failed]];",
  "ok=AssociationQ[candidate]&&",
    "candidate[\"Stage\"]===\"HqqV2S05-v1\"&&",
    "candidate[\"ScopeTag\"]===", ToString[InputForm[scopeTag]], "&&",
    "candidate[\"Source\",\"SHA256\"]===FileHash[",
      ToString[InputForm[sourcePath]], ",\"SHA256\",\"HexString\"]&&",
    "candidate[\"Inputs\",\"S04SourceSHA256\"]===",
      ToString[InputForm[expectedS04SourceHash]], "&&",
    "candidate[\"Inputs\",\"S04ResultSHA256\"]===",
      ToString[InputForm[expectedS04ResultHash]], "&&",
    "AssociationQ[candidate[\"Checks\"]]&&And@@Values[candidate[\"Checks\"]]&&",
    "Keys[candidate[\"RealLaurentLedger\"]]==={\"Pg\",\"PPP\"}&&",
    "And@@(Keys[#]===", ToString[InputForm[families]],
      "&/@Values[candidate[\"RealLaurentLedger\"]])&&",
    "FreeQ[candidate[\"RealLaurentLedger\"],epsilon|_SeriesData|_Real|",
      "Integrate|Inactive[Integrate]|Limit|Indeterminate|ComplexInfinity|",
      "DirectedInfinity]&&",
    "!FileExistsQ[", ToString[InputForm[resultPath <> ".tmp"]], "];",
  "If[TrueQ[ok],Print[\"S05_FRESH_RELOAD_OK\"];Quit[0],",
    "Print[\"S05_FRESH_RELOAD_FAILED\"];Quit[1]]"];
freshValidation = Quiet@Check[RunProcess[{kernelExecutable,
    "-noinit", "-noprompt", "-run", freshValidationCode}], $Failed];
require[AssociationQ[freshValidation] &&
    freshValidation["ExitCode"] === 0 &&
    StringContainsQ[freshValidation["StandardOutput"],
      "S05_FRESH_RELOAD_OK"],
  "S05 fresh-kernel result reload failed", freshValidation];
Print["S05_FRESH_RELOAD_OK"];
Print["S05_SUCCESS"];
Quit[0];

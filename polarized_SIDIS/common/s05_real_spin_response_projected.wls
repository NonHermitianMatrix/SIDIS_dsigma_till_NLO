(* Spin-resolved real tensors in the unchanged high-transverse-momentum SIDIS measurement. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s05_real_spin_response_projected.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
baselineSourcePath = FileNameJoin[{root, "common", "s05_real_spin_response.wls"}];
benchmarkPair = ImportString[Environment["POLARIZED_SIDIS_COMPARE_PAIR"], "RawJSON"];
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
FCSetDiracGammaScheme["BMHV"];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  Print["FAIL: time bound ", label]; Quit[2]], 2*1024^3,
  Print["FAIL: memory bound ", label]; Quit[3]];
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zero[value_] := Factor[Together[value]] === 0;
zeroArray[value_] := And @@ (TrueQ[# === 0] & /@ Flatten[{value}]);
config = Import[FileNameJoin[{root, "common", "s01_inputs.json"}], "RawJSON"];
realConfig = Import[FileNameJoin[{root, "common", "s05_inputs.json"}], "RawJSON"];
gate["known channel", KeyExistsQ[config["channel_contracts"], channel]];
contract = config["channel_contracts"][channel];
core = contract["amplitude_schema"] === "core";
ampPath = FileNameJoin[{root, contract["amplitude_file"]}];
referenceRelative = realConfig["channels"][channel]["unpolarized_real_file"];
referencePath = FileNameJoin[{root, referenceRelative}];
Do[row = SelectFirst[packet[[1]]["files"], #["destination"] === packet[[2]] &];
  gate["pinned input " <> packet[[2]], IntegerString[
    FileHash[FileNameJoin[{root, packet[[2]]}], "SHA256"], 16, 64] === row["sha256"]],
  {packet, {{config, contract["amplitude_file"]}, {realConfig, referenceRelative}}}];
generated = Get[ampPath]; reference = Get[referencePath];
basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
angularPath = FileNameJoin[{root, "common", "s04_result", "s04_result.wl"}];
basis = Get[basisPath]; angular = Get[angularPath];
gate["accepted spin basis", basis["Schema"] === "polarized-sidis-spin-basis-v1" && And @@ Values[basis["Checks"]]];
gate["accepted angular moments", angular["Schema"] === "polarized-sidis-transverse-average-v1" && And @@ Values[angular["Checks"]]];
$Assumptions = Q > 0 && s > s23 > 0 && s23 - Q^2 - s < t < -Q^2 s23/s && SUNN > 1;
simplify[value_] := FullSimplify[value, Assumptions -> $Assumptions];
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot4[a_, b_] := Expand[a.metric.b];
linearSolution[polynomials_, variables_, label_] := Module[{arrays, rules},
  arrays = Normal /@ CoefficientArrays[polynomials, variables];
  gate[label <> " linear", Length[arrays] === 2];
  gate[label <> " nonsingular", simplify[Det[arrays[[2]]] != 0]];
  rules = Thread[variables -> (Factor /@ LinearSolve[arrays[[2]], -arrays[[1]]])];
  gate[label <> " reconstructs", And @@ (zero /@ (polynomials /. rules))]; rules];
pTrial = {ep, 0, 0, ep}; qTrial = {0, 0, 0, -Q};
kTrial = {ek, Sqrt[kxSquared], 0, kz}; recoilTrial = pTrial + qTrial - kTrial;
equations = {dot4[pTrial + qTrial, pTrial + qTrial] == s,
  dot4[qTrial - kTrial, qTrial - kTrial] == t,
  dot4[kTrial, kTrial] == 0, dot4[recoilTrial, recoilTrial] == s23};
polynomials = equations /. Equal -> Subtract;
longitudinalRules = linearSolution[{polynomials[[1]], Expand[polynomials[[2]] - polynomials[[3]]]}, {ep, kz}, "real longitudinal frame"];
energyRules = linearSolution[{Expand[(polynomials[[4]] - polynomials[[3]]) /. longitudinalRules]}, {ek}, "real energy"];
transverseRules = linearSolution[{Expand[polynomials[[3]] /. longitudinalRules /. energyRules]}, {kxSquared}, "real transverse coordinate"];
frameSolution = Join[longitudinalRules, energyRules, transverseRules];
gate["real frame invariants", And @@ simplify[equations /. frameSolution]];
transverseSquared = Factor[kxSquared /. frameSolution];
gate["positive measured transverse momentum", simplify[transverseSquared > 0]];
transverseConstraint = transverseK^2 - transverseSquared;
transverseRule = transverseK -> Sqrt[transverseSquared];
algebraicReduce[values_List] := algebraicReduce /@ values;
algebraicReduce[value_] := Module[{rational, num, den, inverse, gcd, bezout, work, division, answer, proof},
  gate["unconditional exact algebra", FreeQ[value, _ConditionalExpression | _Piecewise | _Real | $Aborted | $Failed]];
  rational = Together[value]; num = Numerator[rational]; den = Denominator[rational];
  gate["transverse rational function", PolynomialQ[num, transverseK] && PolynomialQ[den, transverseK]];
  If[FreeQ[den, transverseK], inverse = 1/den,
    {gcd, bezout} = PolynomialExtendedGCD[den, transverseConstraint, transverseK];
    gate["denominator Bezout reconstruction", zero[gcd - bezout.{den, transverseConstraint}]];
    gate["invertible transverse denominator", FreeQ[gcd, transverseK] && gcd =!= 0];
    inverse = First[bezout]/gcd];
  work = Together[num inverse];
  gate["rationalized transverse denominator", FreeQ[Denominator[work], transverseK]];
  division = PolynomialReduce[Numerator[work], {transverseConstraint}, {transverseK}];
  gate["polynomial division reconstruction", zero[Numerator[work] - First[First[division]] transverseConstraint - Last[division]]];
  answer = Factor[Last[division]/Denominator[work]];
  proof = Last[PolynomialReduce[Numerator[Together[rational - answer]], {transverseConstraint}, {transverseK}]];
  gate["complete rational reconstruction on shell", zero[proof]]; answer];
pVector = Factor[pTrial /. frameSolution]; qVector = qTrial;
kVector = Factor[{ek, transverseK, 0, kz} /. frameSolution];
outZ = Factor[Rest[kVector]/First[kVector]]; outY = {0, 1, 0}; outX = Factor[Cross[outY, outZ]];
frame = <|p -> pVector, q -> qVector, k1 -> kVector,
  eL -> {1, 0, 0, 0}, eX -> {0, 1, 0, 0}, eY -> {0, 0, 1, 0}, eZ -> {0, 0, 0, 1},
  eOutX -> Prepend[outX, 0], eOutY -> Prepend[outY, 0]|>;
physicalKeys = Keys[frame];
gate["measured spin axes", zeroArray[algebraicReduce[{dot4[frame[eOutX], frame[k1]], dot4[frame[eOutY], frame[k1]],
  dot4[frame[eOutX], frame[eOutY]], dot4[frame[eOutX], frame[eOutX]] + 1, dot4[frame[eOutY], frame[eOutY]] + 1}]]];
invariantRules = angular["InvariantMap"] /. Q2 -> Q^2;
gramD = {{0, pq, pk1, pk2}, {pq, -Q^2, qk1, qk2}, {pk1, qk1, 0, k1k2}, {pk2, qk2, k1k2, 0}} /. invariantRules;
momentumBasis = {p, q, k1, k2};
momentumCoordinates[v_] := Coefficient[Expand[v /. k3 -> p + q - k1 - k2], #] & /@ momentumBasis;
dotD[a_, b_] := Factor[momentumCoordinates[a].gramD.momentumCoordinates[b]];
normalFrameMatrix = (frame /@ {p, q, k1, eY}).metric;
normalProducts = Join[(dotD[k2, #] & /@ {p, q, k1}), {normalDot}];
k2Vector = algebraicReduce[LinearSolve[normalFrameMatrix, normalProducts]];
gate["unresolved physical projections", zeroArray[algebraicReduce[normalFrameMatrix.k2Vector - normalProducts]]];
AssociateTo[frame, {k2 -> k2Vector, k3 -> algebraicReduce[pVector + qVector - kVector - k2Vector]}];
hatRules = linearSolution[{dot4[k2Vector, k2Vector] + hatSquared}, {hatSquared}, "evanescent on-shell norm"];
hatNorm = algebraicReduce[hatSquared /. hatRules];
cutRadius = angular["CutEuclideanRadiusSquared"] /. Q2 -> Q^2;
parallelVector = Total[MapThread[Times, {(angular["ParallelCoefficients"] /. Q2 -> Q^2), frame /@ {p, q, k1}}]];
gate["inherited cut radius", algebraicReduce[dot4[parallelVector, parallelVector] - cutRadius] === 0];
normalProjection = dot4[k2Vector, frame[eY]] frame[eY]/dot4[frame[eY], frame[eY]];
gate["one remaining physical normal coordinate", zeroArray[algebraicReduce[k2Vector - parallelVector - normalProjection]]];
gate["positive-energy support independent of normal angle", FreeQ[{First[frame[k2]], First[frame[k3]]}, normalDot]];
allMomenta = {p, q, k1, k2, k3};
realScalarProducts = Flatten[Table[{allMomenta[[i]], allMomenta[[j]], dotD[allMomenta[[i]], allMomenta[[j]]]},
  {i, Length[allMomenta]}, {j, i, Length[allMomenta]}], 1];
FCClearScalarProducts[];
Do[With[{a = aKey, b = bKey, v = algebraicReduce[dot4[frame[aKey], frame[bKey]]]}, SP[a, b] = v; SPD[a, b] = v],
  {aKey, physicalKeys}, {bKey, physicalKeys}];
Do[With[{a = leg, b = key, v = algebraicReduce[dot4[frame[leg], frame[key]]]}, SP[a, b] = v; SPD[a, b] = v],
  {leg, {k2, k3}}, {key, physicalKeys}];
Do[With[{a = left, b = right, full = dotD[left, right],
    extra = Factor[Coefficient[left /. k3 -> p + q - k1 - k2, k2] Coefficient[right /. k3 -> p + q - k1 - k2, k2] hatNorm]},
  SPD[a, b] = full; SPE[a, b] = extra; SP[a, b] = algebraicReduce[full - extra]],
  {left, {k2, k3}}, {right, {k2, k3}}];
Do[With[{a = key}, Momentum[a, D - 4] = 0], {key, physicalKeys}];
coordinates[v_] := algebraicReduce[Total[(Coefficient[Expand[v], #] frame[#]) & /@ Keys[frame]]];
physical[expr_] := expr /. HoldPattern[Momentum[mom_, D]] :>
  If[FreeQ[mom, k2 | k3 | _Polarization], Momentum[mom], Momentum[mom, D]];
epsilonRule = HoldPattern[Eps[Momentum[a_], Momentum[b_], Momentum[c_], Momentum[d_]]] :>
  basis["LeviCivitaSign"] Det[coordinates /@ {a, b, c, d}];
normalMoment[n_Integer] := normalMoment[n] = Module[{value},
  value = If[KeyExistsQ[angular["MomentTable"], {n, 0}], angular["MomentTable"][{n, 0}],
    If[OddQ[n], 0, FunctionExpand[angular["GenericEvenMoment"] /. {aPower -> n/2, bPower -> 0}]]];
  value = Factor[value /. {dimension -> D, radiusSquared -> cutRadius}];
  gate["evaluated angular moment", FreeQ[value, _Gamma | _Beta | _Integrate | _ConditionalExpression]]; value];
angularAverage[values_List] := angularAverage /@ values;
angularAverage[value_] := Module[{rational, num, den, rows, reconstructed},
  rational = Together[algebraicReduce[value]]; num = Numerator[rational]; den = Denominator[rational];
  gate["denominators independent of normal angle", FreeQ[den, normalDot]];
  gate["polynomial angular numerator", PolynomialQ[num, normalDot]];
  rows = CoefficientRules[num, {normalDot}];
  reconstructed = Total[(Last[#] normalDot^First[First[#]]) & /@ rows];
  gate["angular numerator reconstruction", zero[num - reconstructed]];
  algebraicReduce[Total[(Last[#] normalMoment[First[First[#]]]) & /@ rows]/den]];
reduceScalar[expression_] := Module[{value},
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[expression]]]]];
  value = algebraicReduce[value /. epsilonRule];
  gate["fully scalar real contraction", FreeQ[value, _Pair | _Eps | _Spinor | _DiracGamma | _DiracTrace |
    _LorentzIndex | _Polarization | _SUNTF | _SUNTrace | _SUNF | _SUNDelta | _SUNFDelta | _FeynAmpDenominator]]; angularAverage[value]];

(* The imported graph process supplies species where older packets omit them. *)
graphProcess[graphs_] := FirstCase[List @@ Head[graphs],
  HoldPattern[Rule[key_Symbol, process_Rule] /; SymbolName[key] === "Process"] :> process,
  Missing["GeneratedProcess"]];
additionalInputs = {};
If[channel === "Hqg",
  diagramRelative = SelectFirst[Lookup[config["files"], "destination"],
    StringStartsQ[#, "Hqg/"] && StringEndsQ[#, "/s04_diagrams.wl"] &];
  graphData = Get[FileNameJoin[{root, diagramRelative}]]["Real"]["Diagrams"];
  AppendTo[additionalInputs, diagramRelative]];
If[!core,
  kinematicRelative = SelectFirst[Lookup[config["files"], "destination"],
    StringStartsQ[#, channel <> "/"] && StringEndsQ[#, "/kinematics.wl"] &];
  kinematics = Get[FileNameJoin[{root, kinematicRelative}]];
  AppendTo[additionalInputs, kinematicRelative]];
labels = If[channel === "Hqq", generated["RealSectors"], {"Real"}];
referenceCharge = Get[FileNameJoin[{root, config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}]]["ModelChargeSquared"];
photonSymbols = {eL, eX, eY};
photonFrameMatrix = Transpose[frame /@ Append[photonSymbols, q]];
pExpansion = LinearSolve[photonFrameMatrix, frame[p]];
gate["incoming photon-basis projection", zeroArray[algebraicReduce[photonFrameMatrix.pExpansion - frame[p]]]];
pComponents = Take[pExpansion, Length[photonSymbols]];
spinNumerator[mom_, variables_, axes_, anti_] := FCI[Total[MapThread[Times, {Take[variables, Length[basis["SpinLabels"]]],
  basis[If[anti, "AntiquarkSpinNumerators", "QuarkSpinNumerators"]] /. {spinMomentum -> mom, spinX -> axes[[1]], spinY -> axes[[2]]}}]]];
photonDegree[amp_] := Module[{chains, degrees},
  chains = Cases[amp, chain_Dot /; !FreeQ[chain, Polarization[q, ___]], {0, Infinity}];
  degrees = DeleteDuplicates[Map[Function[chain, Which[
    !FreeQ[{First[chain], Last[chain]}, Spinor[Momentum[p, ___], ___]] &&
      !FreeQ[{First[chain], Last[chain]}, Spinor[Momentum[k1, ___], ___]], Exponent[1, chargeRatio],
    !FreeQ[{First[chain], Last[chain]}, Spinor[Momentum[k2, ___], ___]] &&
      !FreeQ[{First[chain], Last[chain]}, Spinor[-Momentum[k3, ___], ___]], Exponent[chargeRatio, chargeRatio],
    True, Missing["PhotonCurrent"]]], chains]];
  gate["identified distinct-flavor photon current", Length[degrees] === 1 && FreeQ[degrees, _Missing]]; First[degrees]];
sourceHash = FileHash[sourcePath, "SHA256"];
inputFiles = DeleteDuplicates[Join[{"common/s01_inputs.json", "common/s05_inputs.json",
  contract["amplitude_file"], referenceRelative, "common/s02_result/s02_result.wl",
  "common/s04_result/s04_result.wl", config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}, additionalInputs]];
inputHashes = Association[(# -> FileHash[FileNameJoin[{root, #}], "SHA256"]) & /@ inputFiles];
Do[row = SelectFirst[config["files"], #["destination"] === relative &];
  gate["pinned input " <> relative, IntegerString[inputHashes[relative], 16, 64] === row["sha256"]],
  {relative, Join[additionalInputs, {config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}]}];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
baselineInputHash = Hash[{FileHash[baselineSourcePath, "SHA256"], inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s05_projected", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
sectorResults = <||>;

Do[
  amplitudes = If[core, generated[label], generated["amplitudes"]];
  process = Which[KeyExistsQ[generated, "Requests"],
      generated["Requests"][label]["Incoming"] -> generated["Requests"][label]["Outgoing"],
    channel === "Hqg", graphProcess[graphData],
    KeyExistsQ[generated, "outgoing_fields"], generated["incoming_fields"] -> generated["outgoing_fields"],
    True, graphProcess[generated["graphs"]]];
  gate[label <> " generated process fields", MatchQ[process, _List -> _List]];
  outgoingFields = (Last[process] /. Index[Colour | Gluon, _] :> Sequence[]) /. V[n_, {}] :> V[n];
  outgoingMomenta = If[core, {k1, k2, k3}, generated["outgoing"]];
  gate[label <> " generated momentum-field correspondence", Length[outgoingFields] === Length[outgoingMomenta] && Count[outgoingMomenta, k1] === 1];
  observedField = outgoingFields[[First[FirstPosition[outgoingMomenta, k1]]]];
  tagWeight = Count[outgoingFields, observedField]/(Times @@ (Factorial /@ Values[Counts[outgoingFields]]));
  If[KeyExistsQ[generated, "symmetry_weight"], gate[label <> " inherited spectator weight", tagWeight === generated["symmetry_weight"]]];
  degrees = If[channel === "Hqq" && label === "RealDistinct", photonDegree /@ amplitudes, ConstantArray[0, Length[amplitudes]]];
  amplitudes = MapThread[Times, {amplitudes, chargeRatio^degrees}];
  couplingAmplitudes = amplitudes /. {SMP["e"] -> couplingEM, SMP["g_s"] -> couplingStrong,
    ee -> couplingEM, gs -> couplingStrong};
  couplingPowers = DeleteDuplicates[Flatten[(First /@ CoefficientRules[#, {couplingEM, couplingStrong}]) & /@ couplingAmplitudes, 1]];
  gate[label <> " unique coupling degree", Length[couplingPowers] === 1 && VectorQ[First[couplingPowers], IntegerQ]];
  gate[label <> " tree coupling reconstruction", And @@ (TrueQ[Expand[# -
    (couplingEM^First[First[couplingPowers]] couplingStrong^Last[First[couplingPowers]])
      (# /. {couplingEM -> 1, couplingStrong -> 1})] === 0] & /@ couplingAmplitudes)];
  amplitudes = amplitudes /. {SMP["e"] -> 1, SMP["g_s"] -> 1, ee -> 1, gs -> 1};
  spinorDimensions = DeleteDuplicates[Cases[amplitudes,
    Spinor[sign_. Momentum[mom_, dim_:4], ___] :> dim, Infinity]];
  gate[label <> " uniform native spinor dimension", Length[spinorDimensions] === 1];
  fermions = DeleteDuplicates[Cases[amplitudes, Spinor[sign_. Momentum[mom_, ___], ___] :> mom, Infinity]];
  antifermions = DeleteDuplicates[Cases[amplitudes, Spinor[-Momentum[mom_, ___], ___] :> mom, Infinity]];
  incomingQuark = MemberQ[fermions, p]; outgoingQuark = MemberQ[fermions, k1];
  gluons = DeleteCases[DeleteDuplicates[Cases[amplitudes, Polarization[mom_, ___] :> mom, Infinity]], q];
  inVariables = If[incomingQuark, {1, xIn, yIn, hIn}, {1, xIn, yIn, hIn, eIn}];
  outVariables = If[outgoingQuark, {1, xOut, yOut, hOut}, {1, xOut, yOut, hOut, eOut}];
  quarkIn = spinNumerator[p, inVariables, {eX, eY}, MemberQ[antifermions, p]];
  quarkOut = spinNumerator[k1, outVariables, {eOutX, eOutY}, MemberQ[antifermions, k1]];
  initialColor = SUNSimplify[If[incomingQuark, SUNFDelta[ci, ci], SUNDelta[ca, ca]], SUNNToCACF -> False];
  normalization = basis["IncomingDensityNormalization"] initialColor If[core, referenceCharge, 1];
  tensorWeight = If[core, tagWeight, 1];
  densities = <||>; gluonDimensions = <||>;
  Do[
    leftIndex = gluonLeft[leg]; rightIndex = gluonRight[leg];
    fullSum = physical[DoPolarizationSums[FVD[Polarization[leg, I], leftIndex] FVD[Polarization[leg, -I], rightIndex], leg, If[leg === p, k1, p]]];
    AssociateTo[gluonDimensions, leg -> reduceScalar[-fullSum MTD[leftIndex, rightIndex]]];
    If[MemberQ[{p, k1}, leg],
      vars = If[leg === p, inVariables, outVariables]; axes = If[leg === p, {eX, eY}, {eOutX, eOutY}];
      stokes = Total[MapThread[Times, {Take[vars, Length[basis["SpinLabels"]]], (#[[{2, 3}, {2, 3}]] &) /@ basis["GluonStokesTensorsCanonical"]}]];
      If[leg === k1, stokes = Transpose[stokes]];
      density = Sum[stokes[[i, j]] FV[axes[[i]], leftIndex] FV[axes[[j]], rightIndex], {i, Length[axes]}, {j, Length[axes]}];
      density += Last[vars] Contract[fullSum - ChangeDimension[fullSum, 4]], density = fullSum];
    AssociateTo[densities, leg -> density], {leg, gluons}];
  buildPair[i_, j_, wardLeg_] := Module[{a, b, value, replacements},
    a = amplitudes[[i]] /. Momentum[Polarization[q, ___], ___] -> LorentzIndex[mu, D];
    b = amplitudes[[j]] /. Momentum[Polarization[q, ___], ___] -> LorentzIndex[nu, D];
    Do[a = a /. Momentum[Polarization[leg, ___], ___] -> LorentzIndex[gluonLeft[leg], D];
      b = b /. Momentum[Polarization[leg, ___], ___] -> LorentzIndex[gluonRight[leg], D], {leg, gluons}];
    value = FermionSpinSum[a ComplexConjugate[b, FCRenameDummyIndices -> True],
      Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
    value = value /. HoldPattern[keptSpinSum[DiracGamma[Momentum[mom_, ___], ___]] /; MemberQ[{p, k1}, mom]] :>
      If[mom === p, quarkIn, quarkOut];
    value = value /. keptSpinSum[other_] :> other;
    gate["real spin closures", FreeQ[value, keptSpinSum | _Spinor]];
    value = physical[value];
    value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
    Do[value *= If[leg === wardLeg, FVD[leg, gluonLeft[leg]] FVD[leg, gluonRight[leg]], densities[leg]], {leg, gluons}];
    tensorWeight value/normalization];
  traceScalar[expression_] := reduceScalar[Contract[DiracSimplify[DotSimplify[Contract[expression]], DiracTraceEvaluate -> True]]];
  pairs = Flatten[Table[{i, j}, {i, Length[amplitudes]}, {j, i, Length[amplitudes]}], 1];
  gate["requested comparison pair exists", MemberQ[pairs, benchmarkPair]]; pairs = {benchmarkPair};
  pairValues = {};
  Do[
    {left, right} = pair; pairStarted = AbsoluteTime[];
    baselinePath = FileNameJoin[{root, "cache", "s05", channel, IntegerString[baselineInputHash, 16],
      label <> "_" <> ToString[left] <> "_" <> ToString[right] <> ".wl"}];
    gate["baseline checkpoint exists", FileExistsQ[baselinePath]];
    baseline = Get[baselinePath];
    gate["baseline source and input binding", baseline["InputHash"] === baselineInputHash];
    pairPath = FileNameJoin[{cache, label <> "_" <> ToString[left] <> "_" <> ToString[right] <> ".wl"}];
    saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
    cachedPairReused = Lookup[saved, "InputHash", None] === inputHash;
    If[!cachedPairReused,
      Print["REAL_PAIR ", channel, " ", label, " ", pair];
      tensor = bounded[buildPair[left, right, None], {label, pair, "spin trace"}];
      matrix = Table[Print["REAL_PHOTON ", pair, " ", a, " ", b];
        bounded[traceScalar[tensor FV[photonSymbols[[a]], mu] FV[photonSymbols[[b]], nu]], {label, pair, a, b}],
        {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
      scalarModes = <|"PgD" -> bounded[traceScalar[tensor MTD[mu, nu]], {label, pair, "PgD"}],
        "PhotonWard" -> bounded[traceScalar[tensor FV[q, mu] FV[q, nu]], {label, pair, "photon Ward"}]|>;
      Do[wardTensor = bounded[buildPair[left, right, leg], {label, pair, leg, "Ward trace"}];
        AssociateTo[scalarModes, "GluonWard_" <> ToString[leg] -> bounded[traceScalar[
          wardTensor Total[FV[#, mu] FV[#, nu] & /@ photonSymbols]], {label, pair, leg, "Ward contraction"}]], {leg, gluons}];
      If[left =!= right, matrix = algebraicReduce[ComplexExpand[matrix + ConjugateTranspose[matrix]]];
        scalarModes = Map[algebraicReduce[ComplexExpand[# + Conjugate[#]]] &, scalarModes]];
      saved = <|"InputHash" -> inputHash, "PhotonMatrix" -> matrix, "ScalarModes" -> scalarModes|>;
      put[saved, pairPath]; Clear[tensor, wardTensor]; ClearSystemCache[]];
    comparisonSeconds = AbsoluteTime[] - pairStarted;
    gate["all photon projections match the original checkpoint", zeroArray[algebraicReduce[saved["PhotonMatrix"] - baseline["PhotonMatrix"]]]];
    gate["same scalar-check inventory", Sort[Keys[saved["ScalarModes"]]] === Sort[Keys[baseline["ScalarModes"]]]];
    Do[gate["same scalar projection " <> key, algebraicReduce[saved["ScalarModes"][key] - baseline["ScalarModes"][key]] === 0],
      {key, Keys[baseline["ScalarModes"]]}];
    resultDir = FileNameJoin[{root, channel, "s05_projection_result"}];
    If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
    result = <|"Schema" -> "polarized-sidis-projection-comparison-v1", "Channel" -> channel, "Sector" -> label,
      "Pair" -> pair, "Checks" -> checks, "ProjectionOrderComparisonPassed" -> True,
      "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "InputHash" -> inputHash,
      "OriginalSourceHash" -> FileHash[baselineSourcePath, "SHA256"], "BaselineInputHash" -> baselineInputHash,
      "BaselineFile" -> baselinePath, "BaselineHash" -> FileHash[baselinePath, "SHA256"],
      "CandidateCheckpoint" -> pairPath, "ComparisonSeconds" -> comparisonSeconds,
      "CachedPairReused" -> cachedPairReused, "BaselineExpressionBytes" -> ByteCount[baseline],
      "CandidateExpressionBytes" -> ByteCount[saved],
      "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "FiniteNLOFHatsComputed" -> False|>;
    put[result, FileNameJoin[{resultDir, "s05_result.wl"}]];
    Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"channel" -> channel, "pair" -> pair,
      "checks" -> checks, "projection_order_comparison_passed" -> True, "comparison_seconds" -> comparisonSeconds,
      "cached_pair_reused" -> cachedPairReused,
      "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
    Print["PASS: s05_real_spin_response_projected"]; Quit[0], {pair, pairs}], {label, Take[labels, 1]}];
gate["comparison produced a result", False];

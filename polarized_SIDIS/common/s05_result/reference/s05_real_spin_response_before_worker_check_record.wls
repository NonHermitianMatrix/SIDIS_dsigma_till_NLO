(* Spin-resolved real tensors in the unchanged high-transverse-momentum SIDIS measurement. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s05_real_spin_response.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; If[TrueQ[$KernelID > 0], Throw[$Failed, "StageFailure"], CloseKernels[]; Quit[1]]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
FCSetDiracGammaScheme["BMHV"];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 2400,
  gate["time bound " <> ToString[label, InputForm], False]], 2*1024^3,
  gate["memory bound " <> ToString[label, InputForm], False]];
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
$LeviCivitaSign = basis["LeviCivitaSign"];
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
spinSymbols = {xIn, yIn, hIn, eIn, xOut, yOut, hOut, eOut};
spinMap[function_, value_] := Module[{variables, rows, monomials, reconstruction},
  variables = Select[spinSymbols, !FreeQ[value, #] &];
  If[variables === {}, Return[function[value]]];
  gate["polynomial dependence on resolved spin", PolynomialQ[value, variables]];
  rows = CoefficientRules[value, variables];
  monomials = (Times @@ MapThread[Power, {variables, First[#]}]) & /@ rows;
  reconstruction = Total[MapThread[Times, {Last /@ rows, monomials}]];
  gate["exact spin polynomial decomposition", zero[Expand[value - reconstruction]]];
  Print["SPIN_COEFFICIENTS ", Length[rows], " input bytes ", ByteCount[value]];
  Total[MapThread[Times, {function /@ (Last /@ rows), monomials}]]];
algebraicReduce[values_List] := algebraicReduce /@ values;
algebraicReduce[value_] := spinMap[algebraicReduceOne, value];
algebraicReduceOne[value_] := Module[{rational, num, den, inverse, gcd, bezout, work, division, answer, proof},
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
scalarRestore = {};
compactScalar[value_] := If[LeafCount[value] <= 4, value, compactScalarMemo[value]];
compactScalarMemo[value_] := compactScalarMemo[value] = Module[{symbol = Unique["sidisScalar"]},
  AppendTo[scalarRestore, symbol -> value]; symbol];
initializeScalarProducts[] := (
FCClearScalarProducts[];
Do[With[{a = aKey, b = bKey, v = compactScalar[algebraicReduce[dot4[frame[aKey], frame[bKey]]]]}, SP[a, b] = v; SPD[a, b] = v],
  {aKey, physicalKeys}, {bKey, physicalKeys}];
Do[With[{a = leg, b = key, v = compactScalar[algebraicReduce[dot4[frame[leg], frame[key]]]]}, SP[a, b] = v; SPD[a, b] = v],
  {leg, {k2, k3}}, {key, physicalKeys}];
Do[With[{a = left, b = right, full = dotD[left, right],
    extra = Factor[Coefficient[left /. k3 -> p + q - k1 - k2, k2] Coefficient[right /. k3 -> p + q - k1 - k2, k2] hatNorm]},
  SPD[a, b] = compactScalar[full]; SPE[a, b] = compactScalar[extra];
  SP[a, b] = compactScalar[full] - compactScalar[extra]],
  {left, {k2, k3}}, {right, {k2, k3}}];
Do[With[{a = key}, Momentum[a, D - 4] = 0], {key, physicalKeys}];
gate["compact real dimensional scalar identities", zeroArray[Table[algebraicReduce[
  FCI[SPD[left, right] - SP[left, right] - SPE[left, right]] /. scalarRestore],
  {left, {k2, k3}}, {right, {k2, k3}}]]];
);
initializeScalarProducts[];
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
angularAverage[value_] := spinMap[angularAverageOne, value];
angularAverageOne[value_] := Module[{rational, num, den, rows, reconstructed},
  rational = Together[algebraicReduce[value]]; num = Numerator[rational]; den = Denominator[rational];
  gate["denominators independent of normal angle", FreeQ[den, normalDot]];
  gate["polynomial angular numerator", PolynomialQ[num, normalDot]];
  rows = CoefficientRules[num, {normalDot}];
  reconstructed = Total[(Last[#] normalDot^First[First[#]]) & /@ rows];
  gate["angular numerator reconstruction", zero[num - reconstructed]];
  algebraicReduce[Total[(Last[#] normalMoment[First[First[#]]]) & /@ rows]/den]];
reduceScalar[expression_] := Module[{value},
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[expression]]]]];
  value = spinMap[Function[component, algebraicReduce[
    Factor[component /. epsilonRule] /. scalarRestore]], value];
  gate["all compact scalar products restored", FreeQ[value, Alternatives @@ (First /@ scalarRestore)]];
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
calculationSource = FileNameJoin[{root, "common", "s05_result", "reference", "s05_real_spin_response_before_sum_checkpoints.wls"}];
calculationSourceHash = FileHash[calculationSource, "SHA256"];
gate["accepted compact calculation source", IntegerString[calculationSourceHash, 16, 64] ===
  "33c00fd1361a5655d5f5c0fed5a15986182e4bb2fad67fc91ed0ba93da394507"];
sourceSection[text_, first_, last_] := Module[{begin, finish},
  begin = First[First[StringPosition[text, first]]];
  finish = First[First[Select[StringPosition[text, last], First[#] > begin &]]];
  StringTake[text, {begin, finish - 1}]];
calculationText = Import[calculationSource, "Text"]; dispatchText = Import[sourcePath, "Text"];
oldPhotonCode = "  photonProject[tensor_, leftAxis_, rightAxis_] := tensor /.\n    {LorentzIndex[mu, D] -> Momentum[leftAxis], LorentzIndex[nu, D] -> Momentum[rightAxis]};";
newPhotonCode = "  photonProject[tensor_, leftAxis_, rightAxis_] := tensor /.\n    {LorentzIndex[mu, D] -> Momentum[leftAxis], LorentzIndex[nu, D] -> Momentum[rightAxis],\n     LorentzIndex[mu] -> Momentum[leftAxis], LorentzIndex[nu] -> Momentum[rightAxis],\n     LorentzIndex[mu, D - 4] -> Momentum[leftAxis, D - 4], LorentzIndex[nu, D - 4] -> Momentum[rightAxis, D - 4]};";
gate["single reviewed real photon interface change", StringCount[dispatchText, newPhotonCode] === 1];
gate["unchanged complete scalar and frame routines", sourceSection[calculationText,
  "metric = DiagonalMatrix", "sourceHash = FileHash[sourcePath"] === sourceSection[dispatchText,
  "metric = DiagonalMatrix", "sourceHash = FileHash[sourcePath"]];
gate["unchanged complete pair contractions", sourceSection[calculationText,
  "Do[\n  amplitudes =", "  slots ="] === StringReplace[sourceSection[dispatchText, "Do[\n  amplitudes =", "  slots ="], newPhotonCode -> oldPhotonCode]];
inputFiles = DeleteDuplicates[Join[{"common/s01_inputs.json", "common/s05_inputs.json",
  contract["amplitude_file"], referenceRelative, "common/s02_result/s02_result.wl",
  "common/s04_result/s04_result.wl", config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}, additionalInputs]];
inputHashes = Association[(# -> FileHash[FileNameJoin[{root, #}], "SHA256"]) & /@ inputFiles];
Do[row = SelectFirst[config["files"], #["destination"] === relative &];
  gate["pinned input " <> relative, IntegerString[inputHashes[relative], 16, 64] === row["sha256"]],
  {relative, Join[additionalInputs, {config["channel_contracts"]["Hqq"]["unpolarized_born_file"]}]}];
inputHash = Hash[{calculationSourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
previousSources = {
  {"s05_real_spin_response_before_compact_products.wls", "a57a34bb658c985202d47ccddd9a431c767c4d0cecf576eb8bb9817fa9972a37"},
  {"s05_real_spin_response_before_coupling_inventory.wls", "e157ea02902f03c1109e0584afb4d50cef3d96cebcdc0a28b1cf7ce7ea8b8fac"},
  {"s05_real_spin_response_before_worker_initialization.wls", "336ac1a601cc637bc11f78c27c10d9c7c0290443568127e76154407a4e3b4b4f"},
  {"s05_real_spin_response_before_coefficient_reduction.wls", "376fd639b0624d1b0aab627969077213468cdd9811fd6b141960e7c831fa8a3a"},
  {"s05_real_spin_response_before_projection.wls", "899cf6d588e4a2186c8e0312a7361c6c99796bd414ff948a2d4ceee98129967d"}};
previousInputHashes = Table[previousSourcePath = FileNameJoin[{root, "common", "s05_result", "reference", First[row]}];
  gate["reviewed previous source " <> First[row], IntegerString[FileHash[previousSourcePath, "SHA256"], 16, 64] === Last[row]];
  Hash[{FileHash[previousSourcePath, "SHA256"], inputHashes, $Version, $FeynCalcVersion}, "SHA256"], {row, previousSources}];
cache = FileNameJoin[{root, "cache", "s05", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
validationOnly = Environment["POLARIZED_SIDIS_VALIDATE_ONLY"] === "1";
validationPath = FileNameJoin[{root, "Hqqprime", "s05_compact_result", "s05_result.wl"}];
If[validationOnly, gate["real comparison channel owns baseline", channel === "Hqqprime"],
  gate["compact real comparison exists", FileExistsQ[validationPath]];
  validation = Get[validationPath];
  gate["compact real comparison accepted", validation["Schema"] === "polarized-sidis-real-compact-comparison-v1" &&
    validation["SourceHash"] === calculationSourceHash && And @@ Values[validation["Checks"]]]];
interfaceProofPath = FileNameJoin[{root, "Hqqprime", "s05_interface_result", "s05_result.wl"}];
interfaceProof = Get[interfaceProofPath];
projectionBaseline = FileNameJoin[{root, "common", "s05_result", "reference", "s05_real_spin_response_before_complete_photon_projection.wls"}];
gate["pinned pre-interface real source", IntegerString[FileHash[projectionBaseline, "SHA256"], 16, 64] ===
  "d34991466b6c4677600840ae1c837fab5879e2483932e778096134f8784c4d84"];
gate["accepted real coordinate and photon interfaces", interfaceProof["Schema"] === "polarized-sidis-real-interface-validation-v1" &&
  And @@ Values[interfaceProof["Checks"]] && interfaceProof["ProductionSourceHash"] === FileHash[projectionBaseline, "SHA256"]];
gate["real interface comparison shares physical inputs", And @@ Table[
  interfaceProof["InputHashes"][relative] === inputHashes[relative],
  {relative, {"common/s02_result/s02_result.wl", "common/s04_result/s04_result.wl"}}]];
gate["executed coordinate conversion code", StringTrim[interfaceProof["CoordinateCode"]] ===
  StringTrim[sourceSection[dispatchText, "\n(* Derive the old coordinate conversion", "\nsectorResults = <||>;"]]];

(* Derive the old coordinate conversion from every saved scalar product. *)
If[core, oldRows = reference["RealScalarProducts"],
  oldRows = Flatten[Table[{kinematics["momenta"][[i]], kinematics["momenta"][[j]], kinematics["gram"][[i, j]]},
    {i, Length[kinematics["momenta"]]}, {j, i, Length[kinematics["momenta"]]}], 1]];
oldValues = oldRows[[All, 3]];
oldVariables = DeleteDuplicates[Cases[oldValues, symbol_Symbol /; Context[symbol] === "Global`", Infinity]];
temporary = Table[Unique["referenceInvariant"], {Length[oldVariables]}];
targetValues = dotD[#[[1]], #[[2]]] & /@ oldRows;
solutions = Block[{$Assumptions = True}, Solve[Thread[(oldValues /. Thread[oldVariables -> temporary]) == targetValues], temporary]];
gate["unique reference coordinate conversion", Length[solutions] === 1 && FreeQ[solutions, _ConditionalExpression]];
coordinateRules = Thread[oldVariables -> (temporary /. First[solutions])];
gate["all reference scalar products reconstruct", zeroArray[algebraicReduce[(oldValues /. coordinateRules) - targetValues]]];
sectorResults = <||>;

spinExtractionProofPath = FileNameJoin[{root, "Hqqprime", "s05_spin_extraction_result", "s05_result.wl"}];
spinExtractionProof = Get[spinExtractionProofPath];
gate["accepted spin extraction and linear sum comparison", spinExtractionProof["Schema"] === "polarized-sidis-spin-extraction-validation-v1" &&
  And @@ Values[spinExtractionProof["Checks"]] && TrueQ[spinExtractionProof["Evidence"]["CompleteMatrixReconstructionPassed"]] &&
  TrueQ[spinExtractionProof["LinearSumEvidence"]["ExactComparisonPassed"]]];
extractionBaseline = FileNameJoin[{root, "common", "s05_result", "reference", "s05_real_spin_response_before_spin_extraction.wls"}];
gate["spin extraction comparison source binding", spinExtractionProof["ProductionSourceHash"] === FileHash[extractionBaseline, "SHA256"]];
gate["spin extraction comparison shares physical inputs", And @@ Table[
  spinExtractionProof["InputHashes"][relative] === inputHashes[relative],
  {relative, {"common/s02_result/s02_result.wl", "common/s04_result/s04_result.wl"}}]];
compactSpinResponse[photon_, incoming_, outgoing_] := Module[
  {variables, incomingComponents, incomingZero, outgoingZero},
  variables = DeleteCases[Join[incoming, outgoing], 1];
  gate["distinct spin polynomial variables", DuplicateFreeQ[variables]];
  incomingZero = Thread[DeleteCases[incoming, 1] -> 0];
  outgoingZero = Thread[DeleteCases[outgoing, 1] -> 0];
  Table[
    gate["polynomial photon spin dependence", PolynomialQ[expression, variables]];
    incomingComponents = Table[If[incoming[[i]] === 1,
      expression /. incomingZero, D[expression, incoming[[i]]] /. incomingZero], {i, Length[incoming]}];
    Table[If[outgoing[[j]] === 1, incomingComponents[[i]] /. outgoingZero,
      D[incomingComponents[[i]], outgoing[[j]]] /. outgoingZero],
      {j, Length[outgoing]}, {i, Length[incoming]}], {expression, photon}]];
linearComponentSum[task_] := If[StringContainsQ[task["Key"], "Ward"],
  algebraicReduce[Total[task["Values"]]], Total[task["Values"]]];
gate["executed compact extraction definition", DownValues[compactSpinResponse] === spinExtractionProof["ExtractionDefinitions"]];
gate["executed linear assembly definition", DownValues[linearComponentSum] === spinExtractionProof["LinearSumDefinitions"]];

spinDispatchValidationOnly = Environment["POLARIZED_SIDIS_SPIN_CHECK_VALIDATE_ONLY"] === "1";
spinDispatchProofPath = FileNameJoin[{root, "Hqqprime", "s05_parallel_result", "s05_result.wl"}];
If[spinDispatchValidationOnly,
  gate["spin dispatch comparison owns accepted channel", channel === "Hqqprime" && !validationOnly],
  spinDispatchProof = Get[spinDispatchProofPath];
  gate["accepted complete spin dispatch comparison", spinDispatchProof["Schema"] === "polarized-sidis-spin-dispatch-validation-v1" &&
    spinDispatchProof["SourceHash"] === sourceHash && TrueQ[spinDispatchProof["MathematicalResultUnchanged"]] &&
    And @@ Values[spinDispatchProof["Checks"]]]];

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
  couplingAmplitudes = DotSimplify /@ couplingAmplitudes;
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
    value = FeynAmpDenominatorExplicit[a ComplexConjugate[b, FCRenameDummyIndices -> True]];
    value = FermionSpinSum[value,
      Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
    value = value /. HoldPattern[keptSpinSum[DiracGamma[Momentum[mom_, ___], ___]] /; MemberQ[{p, k1}, mom]] :>
      If[mom === p, quarkIn, quarkOut];
    value = value /. keptSpinSum[other_] :> other;
    gate["real spin closures", FreeQ[value, keptSpinSum | _Spinor]];
    value = physical[value];
    value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
    Do[value *= If[leg === wardLeg, FVD[leg, gluonLeft[leg]] FVD[leg, gluonRight[leg]], densities[leg]], {leg, gluons}];
    tensorWeight value/normalization];
  traceScalar[expression_] := Module[{value, answer, seconds},
    {seconds, value} = AbsoluteTiming[Contract[DiracSimplify[expression, DiracTraceEvaluate -> True]]];
    Print["TRACE_SECONDS ", seconds, " bytes ", ByteCount[value]];
    {seconds, answer} = AbsoluteTiming[reduceScalar[value]];
    Print["SCALAR_SECONDS ", seconds, " bytes ", ByteCount[answer]]; answer];
  photonProject[tensor_, leftAxis_, rightAxis_] := tensor /.
    {LorentzIndex[mu, D] -> Momentum[leftAxis], LorentzIndex[nu, D] -> Momentum[rightAxis],
     LorentzIndex[mu] -> Momentum[leftAxis], LorentzIndex[nu] -> Momentum[rightAxis],
     LorentzIndex[mu, D - 4] -> Momentum[leftAxis, D - 4], LorentzIndex[nu, D - 4] -> Momentum[rightAxis, D - 4]};
  gate["native physical photon projection interface", And @@ Flatten[Table[
    DiracSimplify[photonProject[FCI[GAD[mu].GAD[nu]], leftAxis, rightAxis] -
      Contract[FCI[GAD[mu].GAD[nu] FV[leftAxis, mu] FV[rightAxis, nu]]]] === 0,
    {leftAxis, Join[photonSymbols, {p, q}]}, {rightAxis, Join[photonSymbols, {p, q}]}]]];
  SetAttributes[cachedProjection, HoldRest];
  cachedProjection[path_, expression_, description_] := Module[{record, value, previousPath},
    record = If[FileExistsQ[path], Get[path], <||>];
    If[Lookup[record, "InputHash", None] === inputHash, Return[record["Value"]]];
    If[!validationOnly, Do[
      previousPath = FileNameJoin[{root, "cache", "s05", channel, IntegerString[oldHash, 16], FileNameTake[path]}];
      record = If[FileExistsQ[previousPath], Get[previousPath], <||>];
      If[Lookup[record, "InputHash", None] === oldHash,
        value = record["Value"];
        put[<|"InputHash" -> inputHash, "Value" -> value, "ReusedCheckpoint" -> previousPath,
          "ReusedCheckpointHash" -> FileHash[previousPath, "SHA256"]|>, path]; Return[value]], {oldHash, previousInputHashes}]];
    Print["REAL_PROJECTION ", description, " kernel ", $KernelID];
    value = bounded[traceScalar[expression], description];
    put[<|"InputHash" -> inputHash, "Value" -> value|>, path]; value];
  calculatePair[pair_] := Block[{checks = <||>}, Module[
    {left, right, pairPath, prefix, saved, previous, previousPath, previousHash,
     tensor, wardTensor, matrix, scalarModes, comparePrevious, elapsed, memory},
    {left, right} = pair;
    prefix = FileNameJoin[{cache, label <> "_" <> ToString[left] <> "_" <> ToString[right]}];
    pairPath = prefix <> ".wl";
    saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
    If[Lookup[saved, "InputHash", None] === inputHash, Return[saved]];
    previous = <||>; previousPath = None;
    Do[With[{candidate = FileNameJoin[{root, "cache", "s05", channel, IntegerString[oldHash, 16],
        label <> "_" <> ToString[left] <> "_" <> ToString[right] <> ".wl"}]},
      If[FileExistsQ[candidate], previous = Get[candidate]; previousPath = candidate; previousHash = oldHash;
        gate["reused pair exact input binding", previous["InputHash"] === previousHash]; Break[]]],
      {oldHash, previousInputHashes}];
    comparePrevious = previousPath =!= None && validationOnly;
    If[previousPath =!= None && !comparePrevious,
      saved = Join[previous, <|"InputHash" -> inputHash, "ReusedCheckpoint" -> previousPath,
        "ReusedCheckpointHash" -> FileHash[previousPath, "SHA256"], "Checks" -> checks|>];
      put[saved, pairPath]; Print["REUSED_REAL_PAIR ", channel, " ", label, " ", pair]; Return[saved]];
    Print["REAL_PAIR ", channel, " ", label, " ", pair, " kernel ", $KernelID];
    elapsed = AbsoluteTime[]; memory = MemoryInUse[];
    tensor = bounded[buildPair[left, right, None], {label, pair, "spin closure"}];
    matrix = Table[cachedProjection[prefix <> "_P" <> ToString[a] <> "_" <> ToString[b] <> ".wl",
      photonProject[tensor, photonSymbols[[a]], photonSymbols[[b]]], {label, pair, a, b}],
      {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
    scalarModes = <|"PgD" -> cachedProjection[prefix <> "_PgD.wl", tensor MTD[mu, nu], {label, pair, "PgD"}],
      "PhotonWard" -> cachedProjection[prefix <> "_PhotonWard.wl", photonProject[tensor, q, q], {label, pair, "photon Ward"}]|>;
    Do[wardTensor = bounded[buildPair[left, right, leg], {label, pair, leg, "Ward closure"}];
      AssociateTo[scalarModes, "GluonWard_" <> ToString[leg] -> cachedProjection[
        prefix <> "_GluonWard_" <> ToString[leg] <> ".wl",
        Total[photonProject[wardTensor, #, #] & /@ photonSymbols], {label, pair, leg, "Ward contraction"}]], {leg, gluons}];
    If[left =!= right, matrix = algebraicReduce[ComplexExpand[matrix + ConjugateTranspose[matrix]]];
      scalarModes = Map[algebraicReduce[ComplexExpand[# + Conjugate[#]]] &, scalarModes]];
    If[comparePrevious,
      gate["complete previous photon matrix comparison", zeroArray[algebraicReduce[matrix - previous["PhotonMatrix"]]]];
      gate["previous scalar projection inventory", Keys[scalarModes] === Keys[previous["ScalarModes"]]];
      gate["complete previous scalar projection comparison", zeroArray[algebraicReduce[Values[scalarModes] - Values[previous["ScalarModes"]]]]]];
    saved = <|"InputHash" -> inputHash, "PhotonMatrix" -> matrix, "ScalarModes" -> scalarModes,
      "Checks" -> checks, "ElapsedSeconds" -> AbsoluteTime[] - elapsed,
      "MemoryBeforeBytes" -> memory, "PeakKernelMemoryBytes" -> MaxMemoryUsed[],
      "ComparedCheckpoint" -> If[comparePrevious, previousPath, None],
      "ComparedCheckpointHash" -> If[comparePrevious, FileHash[previousPath, "SHA256"], None]|>;
    put[saved, pairPath]; ClearSystemCache[]; saved]];
  pairTask[pair_] := Catch[calculatePair[pair], "StageFailure"];
  pairs = Flatten[Table[{i, j}, {i, Length[amplitudes]}, {j, i, Length[amplitudes]}], 1];
  If[validationOnly, pairs = Take[pairs, 1]];
  slots = Quiet[Check[ToExpression[Environment["NSLOTS"]], 1]];
  If[!IntegerQ[slots] || slots < 1, slots = 1];
  CloseKernels[]; runtimeEvidence = {};
  If[slots > 1,
    configuration = KernelConfiguration["localhost", "KernelCommand" ->
      "/u/local/apps/mathematica/13.1/Executables/WolframKernel", "KernelCount" -> Min[8, slots], "TimeConstraint" -> 60];
    TimeConstrained[LaunchKernels[configuration], 60, $Failed]];
  workerCount = Length[Kernels[]];
  If[workerCount > 0,
    runtimeEvidence = ParallelEvaluate[{$MachineName, $Version, $CommandLine}];
    gate["workers share allocated compute node and runtime", And @@
      (#[[1]] === $MachineName && #[[2]] === $Version & /@ runtimeEvidence)];
    ParallelEvaluate[$HistoryLength = 0; PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
      $FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"]; FCSetDiracGammaScheme["BMHV"]];
    DistributeDefinitions[gate, bounded, put, zero, zeroArray, spinSymbols, spinMap,
      algebraicReduce, algebraicReduceOne, initializeScalarProducts, physicalKeys, frame,
      compactScalar, compactScalarMemo, scalarRestore, validationOnly,
      dot4, dotD, momentumCoordinates, momentumBasis, gramD, hatNorm, transverseConstraint,
      coordinates, physical, epsilonRule, normalMoment, angular, cutRadius, angularAverage,
      angularAverageOne, reduceScalar, buildPair, traceScalar, photonProject, cachedProjection,
      calculatePair, pairTask, amplitudes, quarkIn, quarkOut, gluons, densities,
      tensorWeight, normalization, photonSymbols, root, channel, label, cache,
      inputHash, previousInputHashes, pairs, basis];
    With[{assumptions = $Assumptions}, ParallelEvaluate[$Assumptions = assumptions]];
    ParallelEvaluate[checks = <||>; $LeviCivitaSign = basis["LeviCivitaSign"]; initializeScalarProducts[]]];
  Print["Independent-pair worker count = ", workerCount];
  $DistributedContexts = None;
  pairValues = If[workerCount > 0, ParallelMap[pairTask, pairs, Method -> "FinestGrained"], pairTask /@ pairs];
  gate[label <> " all diagram pairs complete", FreeQ[pairValues, $Failed | $Aborted] &&
    Length[pairValues] === Length[pairs] && AllTrue[pairValues, AssociationQ]];
  gate[label <> " all pair checks accepted", And @@ Flatten[(Values[Lookup[#, "Checks", <||>]] &) /@ pairValues]];
  If[validationOnly,
    gate["complete real pair comparison recorded", AllTrue[pairValues,
      Lookup[#, "ComparedCheckpoint", None] =!= None && KeyExistsQ[#["Checks"], "complete previous photon matrix comparison"] &]];
    If[!DirectoryQ[DirectoryName[validationPath]], CreateDirectory[DirectoryName[validationPath], CreateIntermediateDirectories -> True]];
    put[<|"Schema" -> "polarized-sidis-real-compact-comparison-v1", "Channel" -> channel,
      "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "InputHash" -> inputHash,
      "Comparisons" -> (KeyTake[#, {"ComparedCheckpoint", "ComparedCheckpointHash", "Checks", "ElapsedSeconds", "PeakKernelMemoryBytes"}] & /@ pairValues),
      "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>, validationPath];
    CloseKernels[]; Print["PASS: s05_compact_comparison"]; Quit[0]];
  (* The same scalar reduction is applied independently to each matrix entry.
     Every completed entry is input-bound and survives subsequent time limits. *)
  scalarKeys = Keys[First[pairValues]["ScalarModes"]];
  gate[label <> " common pair projection inventory", AllTrue[pairValues, Keys[#["ScalarModes"]] === scalarKeys &]];
  sumTasks = Join[Flatten[Table[<|"Key" -> "Photon_" <> ToString[a] <> "_" <> ToString[b],
      "Values" -> (#["PhotonMatrix"][[a, b]] & /@ pairValues)|>,
    {a, Length[photonSymbols]}, {b, Length[photonSymbols]}], 1],
    Table[<|"Key" -> "Scalar_" <> key, "Values" -> (#["ScalarModes"][key] & /@ pairValues)|>, {key, scalarKeys}]];
  sumTask[task_] := Catch[Block[{checks = <||>}, Module[{path, binding, saved, value, elapsed},
    binding = Hash[{inputHash, label, task["Key"], task["Values"]}, "SHA256"];
    path = FileNameJoin[{cache, label <> "_assembled_" <> task["Key"] <> ".wl"}];
    saved = If[FileExistsQ[path], Get[path], <||>];
    If[Lookup[saved, "SumInputHash", None] =!= binding,
      Print["REAL_COMPONENT_SUM ", label, " ", task["Key"], " input bytes ", ByteCount[task["Values"]]];
      {elapsed, value} = AbsoluteTiming[bounded[linearComponentSum[task], {label, task["Key"], "pair sum"}]];
      saved = <|"InputHash" -> inputHash, "SumInputHash" -> binding, "Key" -> task["Key"], "Value" -> value,
        "ElapsedSeconds" -> elapsed, "InputBytes" -> ByteCount[task["Values"]],
        "OutputBytes" -> ByteCount[value], "Checks" -> checks|>;
      put[saved, path]; ClearSystemCache[]]; saved]], "StageFailure"];
  If[workerCount > 0, DistributeDefinitions[sumTask, linearComponentSum]];
  sums = If[workerCount > 0, ParallelMap[sumTask, sumTasks, Method -> "FinestGrained"], sumTask /@ sumTasks];
  gate[label <> " all component sums complete", FreeQ[sums, $Failed | $Aborted] && AllTrue[sums, AssociationQ]];
  gate[label <> " component sum checks accepted", And @@ Flatten[Values[#["Checks"]] & /@ sums]];
  sumValues = AssociationThread[Lookup[sums, "Key"], Lookup[sums, "Value"]];
  matrix = Table[sumValues["Photon_" <> ToString[a] <> "_" <> ToString[b]], {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
  scalarModes = Association@Table[key -> sumValues["Scalar_" <> key], {key, scalarKeys}];
  sumEvidence = KeyDrop[#, {"Value", "Checks"}] & /@ sums;
  Clear[sums, sumValues, sumTasks];
  gate[label <> " photon Hermiticity", zeroArray[algebraicReduce[ComplexExpand[matrix - ConjugateTranspose[matrix]]]]];
  KeyValueMap[If[StringContainsQ[#1, "Ward"], gate[label <> " " <> #1, #2 === 0]] &, scalarModes];
  (* These entries have already passed the exact scalar reduction. The
     photon and spin basis changes are linear and require no new common
     rational denominator. Check both reconstructions by native expansion. *)
  photonCoefficients = Tr[#.matrix] & /@ basis["PhotonDual"];
  gate[label <> " photon reconstruction", zeroArray[bounded[
    Expand[matrix - Total[MapThread[Times, {photonCoefficients, basis["PhotonBasis"]}]]], {label, "linear photon reconstruction"}]]];
  response = bounded[compactSpinResponse[photonCoefficients, inVariables, outVariables], {label, "spin extraction"}];
  spinReconstructionTask[task_] := Catch[Module[{a, path, binding, saved, value, seconds},
    a = First[task]; binding = Hash[{inputHash, label, task, inVariables, outVariables}, "SHA256"];
    path = FileNameJoin[{cache, label <> "_spin_reconstruction_" <> ToString[a] <> ".wl"}];
    saved = If[FileExistsQ[path], Get[path], <||>];
    If[Lookup[saved, "Binding", None] === binding && TrueQ[Lookup[saved, "Accepted", False]], Return[saved]];
    Print["REAL_SPIN_RECONSTRUCTION ", label, " ", a, " kernel ", $KernelID];
    {seconds, value} = AbsoluteTiming[bounded[zero[task[[2]] -
      Sum[inVariables[[i]] outVariables[[j]] task[[3, j, i]], {i, Length[inVariables]}, {j, Length[outVariables]}]],
      {label, "exact spin reconstruction", a}]];
    gate[label <> " spin reconstruction " <> ToString[a], value];
    saved = <|"InputHash" -> inputHash, "Binding" -> binding, "Component" -> a,
      "Accepted" -> True, "ElapsedSeconds" -> seconds|>;
    put[saved, path]; ClearSystemCache[]; saved], "StageFailure"];
  spinReconstructionTasks = Table[{a, photonCoefficients[[a]], response[[a]]}, {a, Length[photonCoefficients]}];
  If[workerCount > 0, DistributeDefinitions[spinReconstructionTask, inVariables, outVariables]];
  spinReconstructions = If[workerCount > 0,
    ParallelMap[spinReconstructionTask, spinReconstructionTasks, Method -> "FinestGrained"],
    spinReconstructionTask /@ spinReconstructionTasks];
  CloseKernels[];
  gate[label <> " spin reconstruction", Length[spinReconstructions] === Length[photonCoefficients] &&
    AllTrue[spinReconstructions, AssociationQ] && And @@ Lookup[spinReconstructions, "Accepted"] &&
    Lookup[spinReconstructions, "Component"] === Range[Length[photonCoefficients]]];
  Clear[spinReconstructionTasks];
  cdrVariables = Join[Rest[inVariables], Rest[outVariables]];
  cdrRules = Thread[cdrVariables -> (If[MemberQ[{eIn, eOut}, #], 1, 0] & /@ cdrVariables)];
  cdrAverage = If[incomingQuark, 1, basis["IncomingDensityNormalization"]/gluonDimensions[p]];
  cdr = <|"Pg" -> algebraicReduce[cdrAverage (scalarModes["PgD"] /. cdrRules)],
    "Ppp" -> algebraicReduce[cdrAverage pComponents.(matrix /. cdrRules).pComponents]|>;
  AssociateTo[sectorResults, label -> <|"Response" -> response[[All, 1 ;; Length[basis["SpinLabels"]], 1 ;; Length[basis["SpinLabels"]]]],
    "ExtendedResponse" -> response, "PhotonMatrix" -> matrix, "CDRContractions" -> cdr,
    "PhotonMetricD" -> scalarModes["PgD"], "WardChecks" -> KeySelect[scalarModes, StringContainsQ[#, "Ward"] &],
    "TagWeight" -> tagWeight, "TagWeightAppliedToTensor" -> core, "OutgoingFields" -> outgoingFields,
    "IncomingSpinLabels" -> If[incomingQuark, basis["SpinLabels"], Append[basis["SpinLabels"], "E"]],
    "OutgoingSpinLabels" -> If[outgoingQuark, basis["SpinLabels"], Append[basis["SpinLabels"], "E"]],
    "ParallelRuntime" -> runtimeEvidence, "WorkerCount" -> workerCount, "ComponentSumEvidence" -> sumEvidence,
    "PairComparisons" -> (KeyTake[#, {"ComparedCheckpoint", "ComparedCheckpointHash", "Checks"}] & /@
      Select[pairValues, Lookup[#, "ComparedCheckpoint", None] =!= None &]),
    "ChargeDegrees" -> degrees, "AmplitudeCouplingPowers" -> First[couplingPowers], "DiagramPairs" -> pairs,
    "ReusedPairCheckpoints" -> (KeyTake[#, {"ReusedCheckpoint", "ReusedCheckpointHash"}] & /@
      Select[pairValues, KeyExistsQ[#, "ReusedCheckpoint"] &])|>];
  Clear[pairValues]; ClearSystemCache[], {label, labels}];

gate["executed complete real photon definition", DownValues[photonProject] ===
  (interfaceProof["ProjectionDefinitions"] /. completePhotonProject -> photonProject)];
Do[
  cdr = sectorResults[label]["CDRContractions"];
  If[channel === "Hqq",
    degrees = Union[Flatten[Outer[Plus, sectorResults[label]["ChargeDegrees"], sectorResults[label]["ChargeDegrees"]]]];
    Do[gate[label <> " reference " <> mode <> " charge " <> ToString[degree], algebraicReduce[
      Coefficient[cdr[mode], chargeRatio, degree] - (reference["Contractions"][label <> "_Charge" <> ToString[degree] <> "__" <> mode] /. coordinateRules)] === 0],
      {mode, {"Pg", "Ppp"}}, {degree, degrees}],
    Do[referenceValue = If[core, reference["Contractions"][mode], reference[If[mode === "Pg", "g", "pp"]] /. {Nc -> SUNN, gs -> 1}];
      gate[label <> " reference " <> mode, algebraicReduce[cdr[mode] - (referenceValue /. coordinateRules)] === 0], {mode, {"Pg", "Ppp"}}]], {label, labels}];
resultDir = FileNameJoin[{root, channel, "s05_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
result = <|"Schema" -> "polarized-sidis-real-response-v1", "Channel" -> channel,
  "PhotonLabels" -> basis["PhotonLabels"], "SpinLabels" -> basis["SpinLabels"],
  "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"}, "Sectors" -> sectorResults,
  "RealScalarProducts" -> realScalarProducts, "ReferenceCoordinateRules" -> coordinateRules,
  "Frame" -> frame, "TransverseSubstitution" -> transverseRule, "TransverseConstraint" -> transverseConstraint,
  "PhysicalRegion" -> $Assumptions, "Dimension" -> D, "Gamma5Scheme" -> "BMHV",
  "CutMomenta" -> {k2, p + q - k1 - k2}, "CutEnergySupport" -> {energy[k2] > 0, energy[p + q - k1 - k2] > 0},
  "ResidualAngularAverageApplied" -> True, "PhaseSpaceIntegrated" -> False, "FiniteNLOFHatsComputed" -> False,
  "CouplingsRemoved" -> If[core, "e_q^2 g_s^4; distinct-charge ratio retained", "ee^2 gs^4; flavor charges retained"],
  "SourceHash" -> sourceHash, "CalculationSourceHash" -> calculationSourceHash, "InputHashes" -> inputHashes, "InputHash" -> inputHash,
  "InterfaceValidationHash" -> FileHash[interfaceProofPath, "SHA256"],
  "SpinExtractionValidationHash" -> FileHash[spinExtractionProofPath, "SHA256"],
  "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
If[spinDispatchValidationOnly,
  acceptedPath = FileNameJoin[{root, "Hqqprime", "s05_result", "s05_result.wl"}];
  gate["pinned accepted complete real result", IntegerString[FileHash[acceptedPath, "SHA256"], 16, 64] ===
    "07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f"];
  acceptedResult = Get[acceptedPath];
  gate["accepted comparison baseline", And @@ Values[acceptedResult["Checks"]] &&
    acceptedResult["SourceHash"] === FileHash[FileNameJoin[{root, "common", "s05_result", "reference",
      "s05_real_spin_response_before_parallel_spin_checks.wls"}], "SHA256"]];
  mathematicalResult[data_] := Join[KeyDrop[data, {"SourceHash", "Checks", "PeakKernelMemoryBytes"}],
    <|"Sectors" -> Map[KeyDrop[#, {"ParallelRuntime", "WorkerCount"}] &, data["Sectors"]]|>];
  gate["complete accepted real result unchanged", mathematicalResult[result] === mathematicalResult[acceptedResult]];
  Clear[acceptedResult];
  If[!DirectoryQ[DirectoryName[spinDispatchProofPath]], CreateDirectory[DirectoryName[spinDispatchProofPath], CreateIntermediateDirectories -> True]];
  put[<|"Schema" -> "polarized-sidis-spin-dispatch-validation-v1", "Channel" -> channel,
    "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "InputHash" -> inputHash,
    "AcceptedResultHash" -> FileHash[acceptedPath, "SHA256"], "MathematicalResultUnchanged" -> True,
    "SpinChecks" -> spinReconstructions, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>, spinDispatchProofPath];
  Export[FileNameJoin[{DirectoryName[spinDispatchProofPath], "s05_checks.json"}],
    <|"channel" -> channel, "checks" -> checks, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
  Print["PASS: s05_spin_dispatch_validation"]; Quit[0]];
AssociateTo[result, "SpinDispatchValidationHash" -> FileHash[spinDispatchProofPath, "SHA256"]];
(* Native compression preserves the Get interface without a large text expansion. *)
resultPath = FileNameJoin[{resultDir, "s05_result.wl"}];
serializationStart = AbsoluteTime[];
compressedResult = bounded[Compress[result], "final result compression"];
serializedResult = "Uncompress[" <> ToString[compressedResult, InputForm] <> "]\n";
gate["compressed result below file bound", StringLength[serializedResult] < 128*1024^2];
Export[resultPath <> ".tmp", serializedResult, "Text"];
gate["saved result exact round trip", bounded[Get[resultPath <> ".tmp"] === result, "final result reload"]];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Print["RESULT_STORAGE expression_bytes ", ByteCount[result], " file_bytes ", FileByteCount[resultPath],
  " serialization_seconds ", AbsoluteTime[] - serializationStart];
Clear[compressedResult, serializedResult];
Export[FileNameJoin[{resultDir, "s05_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "sectors" -> labels, "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s05_real_spin_response"]; Quit[0];

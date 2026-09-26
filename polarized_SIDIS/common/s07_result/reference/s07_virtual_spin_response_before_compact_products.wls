(* Spin-resolved virtual integrands before adding their Hermitian conjugates. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s07_virtual_spin_response.wls"}];
channel = Environment["POLARIZED_SIDIS_CHANNEL"];
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

configPath = FileNameJoin[{root, "common", "s01_inputs.json"}];
virtualConfigPath = FileNameJoin[{root, "common", "s07_inputs.json"}];
config = Import[configPath, "RawJSON"]; virtualConfig = Import[virtualConfigPath, "RawJSON"];
gate["supported virtual channel", KeyExistsQ[virtualConfig["channels"], channel]];
contract = config["channel_contracts"][channel];
ampPath = FileNameJoin[{root, contract["amplitude_file"]}];
ampRow = SelectFirst[config["files"], #["destination"] === contract["amplitude_file"] &];
gate["pinned amplitude", IntegerString[FileHash[ampPath, "SHA256"], 16, 64] === ampRow["sha256"]];
referencePath = FileNameJoin[{root, virtualConfig["channels"][channel]["destination"]}];
referenceSource = FileNameJoin[{root, virtualConfig["source_destination"]}];
gate["pinned virtual reference", IntegerString[FileHash[referencePath, "SHA256"], 16, 64] === virtualConfig["channels"][channel]["sha256"]];
gate["pinned original virtual source", IntegerString[FileHash[referenceSource, "SHA256"], 16, 64] === virtualConfig["source_sha256"]];
reference = Get[referencePath]; generated = Get[ampPath];
gate["accepted original virtual map", reference["Accepted"] && reference["BornNormalizationAccepted"] &&
  reference["SourceHash"] === FileHash[referenceSource, "SHA256"]];
basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
angularPath = FileNameJoin[{root, "common", "s04_result", "s04_result.wl"}];
bornPath = FileNameJoin[{root, channel, "s03_result", "s03_result.wl"}];
basis = Get[basisPath]; angular = Get[angularPath]; born = Get[bornPath];
gate["accepted spin and angular inputs", And @@ Values[basis["Checks"]] && And @@ Values[angular["Checks"]]];
gate["accepted dimensional Born input", born["Schema"] === "polarized-sidis-born-response-v2" &&
  born["Channel"] === channel && And @@ Values[born["Checks"]]];
$Assumptions = born["PhysicalRegion"];
transverseRule = born["TransverseSubstitution"]; transverseConstraint = born["TransverseConstraint"];
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

frame = born["Frame"] /. Reverse[transverseRule];
gate["Born frame restored exactly", (frame /. transverseRule) === born["Frame"]];
gate["algebraic Born frame", FreeQ[frame, Power[_, _Rational]]];
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot4[a_, b_] := Expand[a.metric.b];
physicalKeys = Keys[frame];
external = {p, q, k1};
loopVariables = {loopSquare, loopP, loopQ, loopK};
loopProducts = Rest[loopVariables];
normalMatrix = (frame /@ Append[external, eY]).metric;
ellVector = algebraicReduce[LinearSolve[normalMatrix, Append[loopProducts, normalDot]]];
gate["loop physical projections", zeroArray[algebraicReduce[normalMatrix.ellVector - Append[loopProducts, normalDot]]]];
AssociateTo[frame, ell -> ellVector];
hatEquation = dot4[ellVector, ellVector] + hatSquared - loopSquare;
hatArrays = Normal /@ CoefficientArrays[{hatEquation}, {hatSquared}];
gate["linear evanescent norm equation", Length[hatArrays] === 2];
hatNorm = algebraicReduce[First[LinearSolve[hatArrays[[2]], -hatArrays[[1]]]]];
gate["loop dimensional norm reconstructs", algebraicReduce[hatEquation /. hatSquared -> hatNorm] === 0];
loopRadius = angular["GeneralEuclideanRadiusSquared"] /.
  Thread[(longitudinalProduct /@ Range[Length[external]]) -> loopProducts] /.
  {normalMomentumSquare -> loopSquare, s23 -> 0, Q2 -> Q^2};
externalGram = Table[dot4[frame[a], frame[b]], {a, external}, {b, external}];
parallelCoefficients = algebraicReduce[LinearSolve[externalGram, loopProducts]];
parallelVector = algebraicReduce[Total[MapThread[Times, {parallelCoefficients, frame /@ external}]]];
gate["general loop radius reconstructs", algebraicReduce[dot4[parallelVector, parallelVector] - loopSquare - loopRadius] === 0];
FCClearScalarProducts[];
Do[With[{a = aKey, b = bKey, v = algebraicReduce[dot4[frame[aKey], frame[bKey]]]}, SP[a, b] = v; SPD[a, b] = v],
  {aKey, physicalKeys}, {bKey, physicalKeys}];
Do[With[{a = key, v = algebraicReduce[dot4[ellVector, frame[key]]]}, SP[ell, a] = v; SPD[ell, a] = v;
  Momentum[a, D - 4] = 0], {key, physicalKeys}];
SPD[ell, ell] = loopSquare; SPE[ell, ell] = hatNorm;
SP[ell, ell] = algebraicReduce[loopSquare - hatNorm];
coordinates[v_] := algebraicReduce[Total[(Coefficient[Expand[v], #] frame[#]) & /@ Keys[frame]]];
physical[expr_] := expr /. HoldPattern[Momentum[mom_, D]] :>
  If[FreeQ[mom, ell | _Polarization], Momentum[mom], Momentum[mom, D]];
epsilonRule = HoldPattern[Eps[Momentum[a_], Momentum[b_], Momentum[c_], Momentum[d_]]] :>
  basis["LeviCivitaSign"] Det[coordinates /@ {a, b, c, d}];
normalMoment[n_Integer] := normalMoment[n] = Module[{value},
  value = If[KeyExistsQ[angular["MomentTable"], {n, 0}], angular["MomentTable"][{n, 0}],
    If[OddQ[n], 0, FunctionExpand[angular["GenericEvenMoment"] /. {aPower -> n/2, bPower -> 0}]]];
  value = Factor[value /. {dimension -> D, radiusSquared -> loopRadius}];
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
spinNumerator[mom_, variables_, axes_, anti_] := FCI[Total[MapThread[Times, {Take[variables, Length[basis["SpinLabels"]]],
  basis[If[anti, "AntiquarkSpinNumerators", "QuarkSpinNumerators"]] /. {spinMomentum -> mom, spinX -> axes[[1]], spinY -> axes[[2]]}}]]];

reduceScalar[expression_] := Module[{value},
  value = EpsEvaluate[ExpandScalarProduct[FeynAmpDenominatorExplicit[Contract[physical[expression]]]]];
  value = algebraicReduce[value /. epsilonRule];
  gate["fully scalar virtual contraction", FreeQ[value, _Pair | _Eps | _Spinor | _DiracGamma | _DiracTrace |
    _LorentzIndex | _Polarization | _SUNTF | _SUNTrace | _SUNF | _SUNDelta | _SUNFDelta | _FeynAmpDenominator]];
  angularAverage[value]];
bornAmplitude = Total[generated["Born"]] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
virtualAmplitudes = generated["Virtual"] /. {SMP["e"] -> 1, SMP["g_s"] -> 1};
genericQuarkMasses = DeleteDuplicates[Cases[virtualAmplitudes,
  value_ /; MatchQ[Head[value], _Symbol] && MemberQ[{"MQU", "MQD"}, SymbolName[Head[value]]] :> value, Infinity]];
masslessRules = Thread[genericQuarkMasses -> 0];
gate["inherited massless specialization", Sort[masslessRules] === Sort[reference["MasslessQuarkSpecialization"]]];
virtualAmplitudes = virtualAmplitudes /. masslessRules;
gate["complete inherited virtual inventory", Union[Lookup[reference["DiagramMaps"], "Diagram"]] === Range[Length[virtualAmplitudes]]];
spinorDimensions = DeleteDuplicates[Cases[{bornAmplitude, virtualAmplitudes},
  Spinor[sign_. Momentum[mom_, dim_:4], ___] :> dim, Infinity]];
gate["uniform native spinor dimension", Length[spinorDimensions] === 1];
fermions = DeleteDuplicates[Cases[bornAmplitude, Spinor[sign_. Momentum[mom_, ___], ___] :> mom, Infinity]];
antifermions = DeleteDuplicates[Cases[bornAmplitude, Spinor[-Momentum[mom_, ___], ___] :> mom, Infinity]];
gluons = DeleteCases[DeleteDuplicates[Cases[bornAmplitude, Polarization[mom_, ___] :> mom, Infinity]], q];
gate["one inherited Born gluon", Length[gluons] === 1]; gluonMomentum = First[gluons];
incomingQuark = MemberQ[fermions, p]; outgoingQuark = MemberQ[fermions, k1];
inVariables = If[incomingQuark, {1, xIn, yIn, hIn}, {1, xIn, yIn, hIn, eIn}];
outVariables = If[outgoingQuark, {1, xOut, yOut, hOut}, {1, xOut, yOut, hOut, eOut}];
quarkIn = spinNumerator[p, inVariables, {eX, eY}, MemberQ[antifermions, p]];
quarkOut = spinNumerator[k1, outVariables, {eOutX, eOutY}, MemberQ[antifermions, k1]];
normalization = born["IncomingNormalization"] born["ModelChargeSquared"];
fullSum = physical[DoPolarizationSums[FVD[Polarization[gluonMomentum, I], rho]
  FVD[Polarization[gluonMomentum, -I], sigma], gluonMomentum, If[gluonMomentum === p, k1, p]]];
gluonDimension = reduceScalar[-fullSum MTD[rho, sigma]];
If[gluonMomentum === k2, gluonDensity = fullSum,
  vars = If[gluonMomentum === p, inVariables, outVariables];
  axes = If[gluonMomentum === p, {eX, eY}, {eOutX, eOutY}];
  stokes = Total[MapThread[Times, {Take[vars, Length[basis["SpinLabels"]]],
    (#[[{2, 3}, {2, 3}]] &) /@ basis["GluonStokesTensorsCanonical"]}]];
  If[gluonMomentum === k1, stokes = Transpose[stokes]];
  gluonDensity = Sum[stokes[[i, j]] FV[axes[[i]], rho] FV[axes[[j]], sigma], {i, Length[axes]}, {j, Length[axes]}] +
    Last[vars] Contract[fullSum - ChangeDimension[fullSum, 4]]];
cdrVariables = Join[Rest[inVariables], Rest[outVariables]];
cdrRules = Thread[cdrVariables -> (If[MemberQ[{eIn, eOut}, #], 1, 0] & /@ cdrVariables)];
cdrAverage = If[incomingQuark, 1, basis["IncomingDensityNormalization"]/gluonDimension];
gate["inherited initial average", zero[cdrAverage/born["IncomingNormalization"] - reference["InitialAverage"]]];
gate["inherited charge normalization", born["ModelChargeSquared"] === reference["ModelChargeSquared"]];
photonSymbols = {eL, eX, eY};
buildTensor[amplitude_] := Module[{a, b, value},
  a = amplitude /. {Momentum[Polarization[q, ___], ___] -> LorentzIndex[mu, D],
    Momentum[Polarization[gluonMomentum, ___], ___] -> LorentzIndex[rho, D]};
  b = bornAmplitude /. {Momentum[Polarization[q, ___], ___] -> LorentzIndex[nu, D],
    Momentum[Polarization[gluonMomentum, ___], ___] -> LorentzIndex[sigma, D]};
  value = FermionSpinSum[a ComplexConjugate[b, FCRenameDummyIndices -> True],
    Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
  value = value /. HoldPattern[keptSpinSum[DiracGamma[Momentum[mom_, ___], ___]] /; MemberQ[{p, k1}, mom]] :>
    If[mom === p, quarkIn, quarkOut];
  value = value /. keptSpinSum[other_] :> other;
  gate["native virtual spin closure", FreeQ[value, keptSpinSum | _Spinor]];
  value = SUNSimplify[physical[value], Explicit -> True, SUNNToCACF -> False] gluonDensity;
  value/normalization];
traceScalar[expression_] := Module[{value, answer, seconds},
  {seconds, value} = AbsoluteTiming[Contract[DiracSimplify[expression, DiracTraceEvaluate -> True]]];
  Print["TRACE_SECONDS ", seconds, " bytes ", ByteCount[value]];
  {seconds, answer} = AbsoluteTiming[reduceScalar[value]];
  Print["SCALAR_SECONDS ", seconds, " bytes ", ByteCount[answer]]; answer];
photonProject[tensor_, leftAxis_, rightAxis_] := tensor /.
  {LorentzIndex[mu, D] -> Momentum[leftAxis], LorentzIndex[nu, D] -> Momentum[rightAxis]};
gate["native physical photon projection interface", And @@ Flatten[Table[
  DiracSimplify[photonProject[FCI[GAD[mu].GAD[nu]], leftAxis, rightAxis] -
    Contract[FCI[GAD[mu].GAD[nu] FV[leftAxis, mu] FV[rightAxis, nu]]]] === 0,
  {leftAxis, Join[photonSymbols, {p, q}]}, {rightAxis, Join[photonSymbols, {p, q}]}]]];
projectMatrix[tensor_] := Table[Print["VIRTUAL_PHOTON ", a, " ", b];
  bounded[traceScalar[photonProject[tensor, photonSymbols[[a]], photonSymbols[[b]]]], {"photon", a, b}],
  {a, Length[photonSymbols]}, {b, Length[photonSymbols]}];
coefficient[expr_, vars_, index_] := If[index === 1, expr /. Thread[Rest[vars] -> 0],
  Coefficient[Expand[expr], vars[[index]], 1] /. Thread[DeleteCases[Rest[vars], vars[[index]]] -> 0]];
spinResponse[matrix_] := Module[{photonCoefficients, response},
  photonCoefficients = algebraicReduce[Tr[#.matrix]] & /@ basis["PhotonDual"];
  gate["virtual photon reconstruction", zeroArray[algebraicReduce[matrix - Total[MapThread[Times, {photonCoefficients, basis["PhotonBasis"]}]]]]];
  response = Table[algebraicReduce[coefficient[coefficient[photonCoefficients[[a]], inVariables, i], outVariables, j]],
    {a, Length[photonCoefficients]}, {j, Length[outVariables]}, {i, Length[inVariables]}];
  gate["virtual spin reconstruction", zeroArray[algebraicReduce[photonCoefficients - Table[
    Sum[inVariables[[i]] outVariables[[j]] response[[a, j, i]], {i, Length[inVariables]}, {j, Length[outVariables]}], {a, Length[photonCoefficients]}]]]];
  response];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = {configPath, virtualConfigPath, ampPath, referencePath, referenceSource, basisPath, angularPath, bornPath};
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
inputHash = Hash[{sourceHash, inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s07", channel, IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
Print["VIRTUAL_BORN_INTERFACE ", channel];
bornTensor = bounded[buildTensor[bornAmplitude], "Born interface trace"];
bornMatrix = projectMatrix[bornTensor]; bornResponse = spinResponse[bornMatrix];
gate["entire inherited Born spin response", zeroArray[algebraicReduce[
  bornResponse[[All, 1 ;; Length[basis["SpinLabels"]], 1 ;; Length[basis["SpinLabels"]]]] - born["AlgebraicResponse"]]]];
Clear[bornTensor, bornMatrix, bornResponse]; ClearSystemCache[];
diagrams = {};
Do[
  pairPath = FileNameJoin[{cache, "diagram_" <> IntegerString[index, 10, 2] <> ".wl"}];
  saved = If[FileExistsQ[pairPath], Get[pairPath], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["VIRTUAL_DIAGRAM ", channel, " ", index];
    tensor = bounded[buildTensor[virtualAmplitudes[[index]]], {index, "virtual trace"}];
    matrix = projectMatrix[tensor]; response = spinResponse[matrix];
    scalarModes = <|"PgD" -> bounded[traceScalar[tensor MTD[mu, nu]], {index, "PgD"}],
      "PppD" -> bounded[traceScalar[photonProject[tensor, p, p]], {index, "PppD"}]|>;
    cdr = <|"Pg" -> algebraicReduce[cdrAverage (scalarModes["PgD"] /. cdrRules)],
      "Ppp" -> algebraicReduce[cdrAverage (scalarModes["PppD"] /. cdrRules)]|>;
    Do[original = SelectFirst[reference["DiagramMaps"], #["Diagram"] === index && #["Mode"] === mode &];
      originalValue = bounded[reduceScalar[original["ContractedIntegrand"] /. Q2 -> Q^2], {index, mode, "reference conversion"}];
      gate["diagram " <> ToString[index] <> " reference " <> mode, algebraicReduce[cdr[mode] - originalValue] === 0],
      {mode, {"Pg", "Ppp"}}];
    photonWard = Table[bounded[traceScalar[photonProject[tensor, q, axis]], {index, axis, "photon Ward"}], {axis, photonSymbols}];
    loopPropagators = DeleteDuplicates[Cases[virtualAmplitudes[[index]],
      line_PropagatorDenominator /; !FreeQ[line, ell], Infinity]];
    gate["loop propagators independent of normal angle", FreeQ[
      (ExpandScalarProduct[FeynAmpDenominatorExplicit[FeynAmpDenominator[#]]] & /@ loopPropagators), normalDot]];
    saved = <|"Diagram" -> index, "InputHash" -> inputHash, "PhotonMatrix" -> matrix,
      "Response" -> response[[All, 1 ;; Length[basis["SpinLabels"]], 1 ;; Length[basis["SpinLabels"]]]],
      "ExtendedResponse" -> response, "CDRContractions" -> cdr, "PhotonMetricD" -> scalarModes["PgD"],
      "PhotonWardLeft" -> photonWard, "LoopPropagators" -> loopPropagators,
      "ReferenceReconstructionPassed" -> True|>;
    put[saved, pairPath]; Clear[tensor, matrix, response, scalarModes]; ClearSystemCache[]];
  AppendTo[diagrams, saved], {index, Length[virtualAmplitudes]}];
gate["all inherited virtual diagrams contracted", Length[diagrams] === Length[virtualAmplitudes] &&
  And @@ Lookup[diagrams, "ReferenceReconstructionPassed"]];
result = <|"Schema" -> "polarized-sidis-virtual-response-v1", "Channel" -> channel,
  "PhotonLabels" -> basis["PhotonLabels"], "SpinLabels" -> basis["SpinLabels"],
  "IncomingSpinLabels" -> born["ExtendedIncomingLabels"], "OutgoingSpinLabels" -> born["ExtendedOutgoingLabels"],
  "IndexOrder" -> {"photon component", "outgoing spin", "incoming spin"}, "Diagrams" -> diagrams,
  "LoopScalarProducts" -> MapThread[List, {{ell, ell, ell, ell}, {ell, p, q, k1}, loopVariables}],
  "BornScalarProducts" -> (reference["BornScalarProducts"] /. Q2 -> Q^2),
  "IncomingNormalization" -> born["IncomingNormalization"], "ModelChargeSquared" -> born["ModelChargeSquared"],
  "CouplingsRemoved" -> reference["CouplingsRemoved"], "MasslessQuarkSpecialization" -> masslessRules,
  "Frame" -> frame, "TransverseSubstitution" -> transverseRule, "TransverseConstraint" -> transverseConstraint,
  "InterferenceConvention" -> reference["InterferenceConvention"], "Measure" -> reference["Measure"],
  "LoopPrescription" -> "Original massless FeynArts FeynAmpDenominator Feynman +i0 prescription",
  "Dimension" -> D, "Gamma5Scheme" -> "BMHV", "ResidualAngularAverageApplied" -> True,
  "LoopIntegrated" -> False, "IntegratedWardChecksPassed" -> False, "FiniteNLOFHatsComputed" -> False,
  "SourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, channel, "s07_result"}];
If[!DirectoryQ[resultDir], CreateDirectory[resultDir, CreateIntermediateDirectories -> True]];
put[result, FileNameJoin[{resultDir, "s07_result.wl"}]];
Export[FileNameJoin[{resultDir, "s07_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "diagram_count" -> Length[diagrams], "finite_nlo_fhats_computed" -> False,
  "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s07_virtual_spin_response"]; Quit[0];

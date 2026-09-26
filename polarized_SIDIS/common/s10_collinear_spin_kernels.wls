(* LO spin kernels for the reference PDF/FF subtraction convention. *)
$HistoryLength = 0; root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s10_collinear_spin_kernels.wls"}];
checks = <||>;
gate[name_, test_] := If[TrueQ[test],
  If[!KeyExistsQ[checks, name], Print["PASS: ", name]]; AssociateTo[checks, name -> True],
  Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynCalcLegacy"}; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
FCSetDiracGammaScheme["BMHV"];
SetAttributes[bounded, HoldFirst];
bounded[value_, label_] := MemoryConstrained[TimeConstrained[value, 1200,
  Print["FAIL: time bound ", label]; Quit[2]], 2*1024^3,
  Print["FAIL: memory bound ", label]; Quit[3]];
zero[value_] := Factor[Together[value]] === 0;
zeroArray[value_] := And @@ (zero /@ Flatten[{value}]);
put[value_, path_] := (Put[value, path <> ".tmp"];
  RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);

configPath = FileNameJoin[{root, "common", "s10_inputs.json"}];
config = Import[configPath, "RawJSON"];
Do[gate["pinned reference " <> row["destination"], IntegerString[
  FileHash[FileNameJoin[{root, row["destination"]}], "SHA256"], 16, 64] === row["sha256"]],
  {row, config["files"]}];
referencePath = FileNameJoin[{root, "common", "s10_result", "reference", "s08_result.wl"}];
referenceSource = FileNameJoin[{root, "common", "s10_result", "reference", "s08_collinear_subtraction.wl"}];
basisPath = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
colorPath = FileNameJoin[{root, "Hqq", "s01_result", "reference", "s01_result", "s01_inputs", "s02_result.wl"}];
reference = Get[referencePath]; basis = Get[basisPath]; colorInput = Get[colorPath];
gate["reference subtraction source identity", reference["SourceHash"] === FileHash[referenceSource, "SHA256"]];
gate["reference Born identity", reference["InputHashes"]["s02_result.wl"] === FileHash[colorPath, "SHA256"]];
gate["accepted spin projectors", And @@ Values[basis["Checks"]]];
labels = basis["SpinLabels"]; spinDimension = basis["IncomingDensityNormalization"];
uPosition = First[FirstPosition[labels, "U"]]; hPosition = First[FirstPosition[labels, "H"]];
spinIdentity = Table[Tr[basis["PauliMatrices"][[i]].basis["PauliMatrices"][[j]]]/spinDimension,
  {i, Length[labels]}, {j, Length[labels]}];
gate["endpoint spin identity", spinIdentity === IdentityMatrix[Length[labels]]];
colorNames = <|"CF" -> colorInput["ColorConstants"]["CF"], "CA" -> colorInput["ColorConstants"]["CA"],
  "Tf" -> colorInput["ColorConstants"]["TF"], "Nf" -> Nf|>;
convertKernel[value_] := Module[{converted},
  converted = value /. symbol_Symbol /; KeyExistsQ[colorNames, SymbolName[Unevaluated[symbol]]] :>
    colorNames[SymbolName[Unevaluated[symbol]]];
  converted /.
  {head_[argument_] /; SymbolName[Unevaluated[head]] === "PlusDistribution" :> kernelPlus[argument],
   head_[argument_] /; SymbolName[Unevaluated[head]] === "DeltaFunction" :> kernelDelta[argument]}];
kernelNames = Keys[reference["Kernels"]];
unpolarized = reference["Kernels"] /. x -> z;
helicity = Association@Table[name -> convertKernel[
  reference["KernelNormalization"][name] SplittingFunction[name, z, Polarization -> 1]], {name, kernelNames}];
Do[gate["reference kernel normalization " <> name, zero[unpolarized[name] - convertKernel[
    reference["KernelNormalization"][name] SplittingFunction[name, z, Polarization -> 0]]]], {name, kernelNames}];
gate["native helicity kernels evaluated", FreeQ[helicity, _SplittingFunction]];
ordinary[value_] := value /. {kernelPlus[arg_] :> arg, kernelDelta[_] -> 0};

physical = parentEnergy > 0 && transverseMagnitude > 0 && 0 < z < 1 && Element[azimuth, Reals];
$Assumptions = physical;
metric = DiagonalMatrix[{1, -1, -1, -1}]; dot4[a_, b_] := Expand[a.metric.b];
simplify[value_] := Factor[FullSimplify[TrigReduce[value], Assumptions -> physical]];
pVector = {parentEnergy, 0, 0, parentEnergy}; nVector = {1, 0, 0, -1};
firstTrial = {energy1, transverseMagnitude Cos[azimuth], transverseMagnitude Sin[azimuth], longitudinal1};
secondTrial = {energy2, -transverseMagnitude Cos[azimuth], -transverseMagnitude Sin[azimuth], longitudinal2};
definingEquations = {dot4[firstTrial, nVector] == z dot4[pVector, nVector],
  dot4[secondTrial, nVector] == (1 - z) dot4[pVector, nVector],
  dot4[firstTrial, firstTrial] == 0, dot4[secondTrial, secondTrial] == 0};
solutions = Solve[definingEquations, {energy1, longitudinal1, energy2, longitudinal2}];
gate["unique collinear frame", Length[solutions] === 1 && FreeQ[solutions, _ConditionalExpression]];
firstVector = simplify[firstTrial /. First[solutions]]; secondVector = simplify[secondTrial /. First[solutions]];
gate["collinear frame reconstructs", And @@ FullSimplify[definingEquations /. First[solutions], physical]];
parentVector = firstVector + secondVector; virtuality = simplify[dot4[parentVector, parentVector]];
gate["positive parent virtuality", FullSimplify[virtuality > 0, physical]];
shiftSolutions = Solve[dot4[parentVector - lightlikeShift nVector, parentVector - lightlikeShift nVector] == 0,
  lightlikeShift];
gate["unique lightlike parent projection", Length[shiftSolutions] === 1 && FreeQ[shiftSolutions, _ConditionalExpression]];
gate["reference lightlike parent", zeroArray[simplify[
  (parentVector - lightlikeShift nVector /. First[shiftSolutions]) - pVector]]];
baseX = {0, 1, 0, 0}; baseY = {0, 0, 1, 0};
axis[vector_, base_] := simplify[base - dot4[base, vector] nVector/dot4[nVector, vector]];
frame = <|p -> pVector, n -> nVector, k1 -> firstVector, k2 -> secondVector, parent -> parentVector,
  eX -> baseX, eY -> baseY, outX -> axis[firstVector, baseX], outY -> axis[firstVector, baseY]|>;
gate["daughter transverse axes", zeroArray[simplify[{dot4[frame[outX], firstVector], dot4[frame[outY], firstVector],
  dot4[frame[outX], frame[outY]], dot4[frame[outX], frame[outX]] + 1, dot4[frame[outY], frame[outY]] + 1}]]];
gate["spin axes approach the inherited collinear axes", zeroArray[FullSimplify[
  Limit[{frame[outX] - baseX, frame[outY] - baseY}, transverseMagnitude -> 0], parentEnergy > 0 && 0 < z < 1]]];
FCClearScalarProducts[];
Do[With[{a = aKey, b = bKey, value = simplify[dot4[frame[aKey], frame[bKey]]]}, SP[a, b] = value],
  {aKey, Keys[frame]}, {bKey, Keys[frame]}];
coordinates[value_] := Total[(Coefficient[Expand[value], #] frame[#]) & /@ Keys[frame]];
epsilonRule = HoldPattern[Eps[Momentum[a_], Momentum[b_], Momentum[c_], Momentum[d_]]] :>
  basis["LeviCivitaSign"] Det[coordinates /@ {a, b, c, d}];
inVariables = {1, xIn, yIn, hIn}; outVariables = {1, xOut, yOut, hOut};
spinNumerator[mom_, vars_, axes_, anti_] := FCI[Total[MapThread[Times, {vars,
  basis[If[anti, "AntiquarkSpinNumerators", "QuarkSpinNumerators"]] /.
    {spinMomentum -> mom, spinX -> axes[[1]], spinY -> axes[[2]]}}]]];
coefficient[expr_, vars_, index_] := If[index === 1, expr /. Thread[Rest[vars] -> 0],
  Coefficient[Expand[expr], vars[[index]], 1] /. Thread[DeleteCases[Rest[vars], vars[[index]]] -> 0]];
vertex = QuarkGluonVertex[mu, Dimension -> Length[pVector], CouplingConstant -> 1, Explicit -> True];
amplitudes = <|
  "qq" -> FCI[SpinorUBar[k1, 0].vertex.SpinorU[p, 0] FV[Polarization[k2, I], mu]],
  "gq" -> FCI[SpinorUBar[k1, 0].vertex.SpinorV[k2, 0] FV[Polarization[p, I], mu]],
  "qg" -> FCI[SpinorUBar[k2, 0].vertex.SpinorU[p, 0] FV[Polarization[k1, I], mu]],
  "gg" -> FCI[GluonVertex[{-parent, mu}, {k1, rho}, {k2, sigma}, Dimension -> Length[pVector],
    CouplingConstant -> 1, Explicit -> True] FV[Polarization[p, I], mu]
      FV[Polarization[k1, I], rho] FV[Polarization[k2, I], sigma]],
  "aqaq" -> FCI[SpinorVBar[p, 0].vertex.SpinorV[k1, 0] FV[Polarization[k2, I], mu]],
  "gaq" -> FCI[SpinorUBar[k2, 0].vertex.SpinorV[k1, 0] FV[Polarization[p, I], mu]],
  "aqg" -> FCI[SpinorVBar[p, 0].vertex.SpinorV[k2, 0] FV[Polarization[k1, I], mu]]|>;
referenceNames = <|"qq" -> "Pqq", "gq" -> "Pqg", "qg" -> "Pgq", "gg" -> "Pgg",
  "aqaq" -> "Pqq", "gaq" -> "Pqg", "aqg" -> "Pgq"|>;
gate["native QCD vertices evaluated", FreeQ[amplitudes, _QuarkGluonVertex | _GluonVertex]];
sourceHash = FileHash[sourcePath, "SHA256"];
inputPaths = {configPath, referencePath, referenceSource, basisPath, colorPath};
inputHashes = Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths];
nativeDirectory = "/u/home/r/rushil/.Mathematica/Applications/FeynCalc/AddOns/FeynCalcLegacy/LegacyFunctions";
nativeHashes = Association[(# -> FileHash[FileNameJoin[{nativeDirectory, #}], "SHA256"]) & /@
  {"SplittingFunction.m", "QuarkGluonVertex.m", "GluonVertex.m"}];
inputHash = Hash[{sourceHash, inputHashes, nativeHashes, $Version, $FeynCalcVersion}, "SHA256"];
cache = FileNameJoin[{root, "cache", "s10", IntegerString[inputHash, 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
responses = <||>;
Do[
  file = FileNameJoin[{cache, name <> ".wl"}]; saved = If[FileExistsQ[file], Get[file], <||>];
  If[Lookup[saved, "InputHash", None] =!= inputHash,
    Print["SPLITTING_CHANNEL ", name]; a = amplitudes[name]; b = amplitudes[name];
    gluons = DeleteDuplicates[Cases[a, Polarization[mom_, ___] :> mom, Infinity]];
    antiquarks = DeleteDuplicates[Cases[a, Spinor[-Momentum[mom_], ___] :> mom, Infinity]];
    resolvedGluons = Intersection[gluons, {p, k1}];
    Do[a = a /. Momentum[Polarization[leg, ___]] -> LorentzIndex[leftIndex[leg]];
      b = b /. Momentum[Polarization[leg, ___]] -> LorentzIndex[rightIndex[leg]], {leg, resolvedGluons}];
    value = FermionSpinSum[a ComplexConjugate[b, FCRenameDummyIndices -> True],
      Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
    value = value /. HoldPattern[keptSpinSum[DiracGamma[Momentum[mom_]]] /; MemberQ[{p, k1}, mom]] :>
      spinNumerator[mom, If[mom === p, inVariables, outVariables],
        If[mom === p, {eX, eY}, {outX, outY}], MemberQ[antiquarks, mom]];
    value = value /. keptSpinSum[other_] :> other;
    gate[name <> " complete native spin closure", FreeQ[value, keptSpinSum | _Spinor]];
    Do[value = DoPolarizationSums[value, leg, n], {leg, Complement[gluons, resolvedGluons]}];
    Do[vars = If[leg === p, inVariables, outVariables]; axes = If[leg === p, {eX, eY}, {outX, outY}];
      stokes = Total[MapThread[Times, {vars, (#[[{2, 3}, {2, 3}]] &) /@ basis["GluonStokesTensorsCanonical"]}]];
      If[leg === k1, stokes = Transpose[stokes]];
      value *= Sum[stokes[[i, j]] FV[axes[[i]], leftIndex[leg]] FV[axes[[j]], rightIndex[leg]],
        {i, Length[axes]}, {j, Length[axes]}], {leg, resolvedGluons}];
    value = bounded[Contract[DiracSimplify[value/spinDimension, DiracTraceEvaluate -> True]], {name, "trace"}];
    value = EpsEvaluate[ExpandScalarProduct[value]] /. epsilonRule;
    gate[name <> " scalar exact splitting response", FreeQ[value,
      _Pair | _Eps | _Spinor | _DiracGamma | _DiracTrace | _LorentzIndex | _Polarization | _Real | $Failed | $Aborted]];
    coefficientMatrix = Table[coefficient[coefficient[value, inVariables, i], outVariables, j],
      {j, Length[labels]}, {i, Length[labels]}];
    gate[name <> " complete spin reconstruction", zero[simplify[value -
      outVariables.coefficientMatrix.inVariables]]];
    rawMatrix = Table[Print["SPLITTING_SPIN ", name, " ", j, " ", i]; bounded[Module[{part, averaged},
      part = coefficientMatrix[[j, i]]/virtuality;
      part = Together[TrigReduce[part]];
      gate[name <> " azimuth-independent denominator", FreeQ[Denominator[part], azimuth]];
      averaged = Integrate[part, {azimuth, 0, 2 Pi}, Assumptions -> physical, GenerateConditions -> False]/
        Integrate[1, {azimuth, 0, 2 Pi}];
      simplify[Limit[averaged, transverseMagnitude -> 0]]], {name, j, i, "collinear limit"}],
      {j, Length[labels]}, {i, Length[labels]}];
    gate[name <> " evaluated collinear response", FreeQ[rawMatrix,
      _Integrate | _Limit | _ConditionalExpression | _Piecewise | _Real | parentEnergy | transverseMagnitude | azimuth | $Failed | $Aborted]];
    ref = referenceNames[name];
    normalization = Factor[ordinary[unpolarized[ref]]/rawMatrix[[uPosition, uPosition]]];
    gate[name <> " reference normalization is kinematics independent", FreeQ[normalization,
      z | parentEnergy | transverseMagnitude | azimuth | _kernelPlus | _kernelDelta | _Real] && normalization =!= 0];
    realMatrix = Map[Factor, normalization rawMatrix, {2}];
    gate[name <> " native unpolarized real kernel", zero[realMatrix[[uPosition, uPosition]] - ordinary[unpolarized[ref]]]];
    gate[name <> " native helicity real kernel", zero[realMatrix[[hPosition, hPosition]] - ordinary[helicity[ref]]]];
    softMatrix = Map[Factor[Limit[(1 - z) #, z -> 1]] &, realMatrix, {2}];
    delta = Factor[Coefficient[Expand[unpolarized[ref] /. {kernelPlus[_] -> plusToken, kernelDelta[_] -> deltaToken}], deltaToken]];
    gate[name <> " reference endpoint coefficient", FreeQ[delta, z | plusToken | deltaToken]];
    kernelMatrix = Map[Factor, realMatrix - softMatrix/(1 - z) +
      softMatrix kernelPlus[1/(1 - z)] + delta spinIdentity kernelDelta[1 - z], {2}];
    gate[name <> " full unpolarized distribution", zero[kernelMatrix[[uPosition, uPosition]] - unpolarized[ref]]];
    gate[name <> " full helicity distribution", zero[kernelMatrix[[hPosition, hPosition]] - helicity[ref]]];
    gate[name <> " endpoint spin conservation", zeroArray[softMatrix - softMatrix[[uPosition, uPosition]] spinIdentity]];
    gate[name <> " real spin kernel coefficients", zeroArray[ComplexExpand[
      {realMatrix - Conjugate[realMatrix], softMatrix - Conjugate[softMatrix], delta - Conjugate[delta]}]]];
    saved = <|"InputHash" -> inputHash, "ReferenceKernel" -> ref, "Kernel" -> kernelMatrix,
      "RealKernel" -> realMatrix, "SoftResidue" -> softMatrix, "DeltaCoefficient" -> delta spinIdentity,
      "ReferenceNormalizationDerived" -> normalization, "NativeReferenceChecksPassed" -> True|>;
    put[saved, file]];
  AssociateTo[responses, name -> saved], {name, Keys[amplitudes]}];
Do[gate["charge conjugation " <> pair[[1]], zeroArray[responses[pair[[1]]]["Kernel"] - responses[pair[[2]]]["Kernel"]]],
  {pair, {{"qq", "aqaq"}, {"gq", "gaq"}, {"qg", "aqg"}}}];
result = <|"Schema" -> "polarized-sidis-collinear-kernels-v1", "SpinLabels" -> labels,
  "IndexOrder" -> {"daughter spin", "parent spin"}, "ChannelOrder" -> "parent then daughter; aq denotes antiquark",
  "Responses" -> responses, "ReferenceKernelNormalization" -> reference["KernelNormalization"],
  "ReferenceSubtractionPrefactor" -> reference["Prefactor"], "ReferencePlusDefinition" -> reference["PlusDefinition"],
  "KernelFraction" -> z, "Order" -> "LO collinear kernels for NLO hard-coefficient subtraction",
  "EndpointConvention" -> "reference MSbar virtual endpoint times the Pauli spin identity",
  "ConvolutionPerformed" -> False, "FiniteNLOFHatsComputed" -> False,
  "SourceHash" -> sourceHash, "InputHashes" -> inputHashes, "NativeSourceHashes" -> nativeHashes,
  "InputHash" -> inputHash, "Checks" -> checks, "PeakKernelMemoryBytes" -> MaxMemoryUsed[]|>;
resultDir = FileNameJoin[{root, "common", "s10_result"}];
put[result, FileNameJoin[{resultDir, "s10_result.wl"}]];
Export[FileNameJoin[{resultDir, "s10_checks.json"}], <|"checks" -> checks,
  "channels" -> Keys[responses], "finite_nlo_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s10_collinear_spin_kernels"]; Quit[0];

(* Native intermediate-gluon projectors using the accepted S10 frame and vertex. *)
$HistoryLength = 0; root = Directory[];
studySource = FileNameJoin[{root, "common", "s10_dimensional_gluon_transfer.wls"}];
baselineSource = FileNameJoin[{root, "common", "s10_collinear_spin_kernels.wls"}];
If[IntegerString[FileHash[baselineSource, "SHA256"], 16, 64] =!=
  "4e2e1b0b662948805d939ea52ebd7e227d0719f2d85e03f3843b791b47c09696", Quit[1]];
baselineText = Import[baselineSource, "Text"];
boundary = StringPosition[baselineText, "sourceHash = FileHash[sourcePath, \"SHA256\"];"];
If[Length[boundary] =!= 1, Quit[1]];
prefix = StringTake[baselineText, First[First[boundary]] - 1];
frameChanges = {
  "physical = parentEnergy > 0" -> "physical = D > 4 && 0 < physicalFraction < 1 && parentEnergy > 0",
  "transverseMagnitude Cos[azimuth]" -> "Sqrt[physicalFraction] transverseMagnitude Cos[azimuth]",
  "transverseMagnitude Sin[azimuth]" -> "Sqrt[physicalFraction] transverseMagnitude Sin[azimuth]",
  "dot4[firstTrial, firstTrial] == 0" -> "dot4[firstTrial, firstTrial] == transverseMagnitude^2 (1 - physicalFraction)",
  "dot4[secondTrial, secondTrial] == 0" -> "dot4[secondTrial, secondTrial] == transverseMagnitude^2 (1 - physicalFraction)"};
If[!And @@ (StringContainsQ[prefix, First[#]] & /@ frameChanges), Quit[1]];
prefix = StringReplace[prefix, frameChanges];
If[!SyntaxQ[prefix] || !SyntaxQ[Import[studySource, "Text"]], Quit[1]];
ToExpression[prefix, InputForm];
(* The two daughters carry opposite unresolved transverse components.
   Their physical projections and full-dimensional scalar products are
   fixed by the same defining on-shell equations and momentum conservation. *)
extraMagnitudeSquared = simplify[transverseMagnitude^2 -
  Total[firstVector[[{2, 3}]]^2]];
extraDirections = Association@Table[leg -> simplify[frame[leg][[2]]/firstVector[[2]]], {leg, {k1, k2}}];
Do[With[{left = legA, right = legB,
    value = simplify[dot4[frame[legA], frame[legB]] -
      Lookup[extraDirections, legA, 0] Lookup[extraDirections, legB, 0] extraMagnitudeSquared]}, SPD[left, right] = value],
  {legA, Keys[frame]}, {legB, Keys[frame]}];
gate["opposite unresolved transverse directions", zero[Total[Values[extraDirections]]]];
gate["dimensional daughter mass shells", zeroArray[{SPD[k1, k1], SPD[k2, k2]}]];
gate["dimensional parent virtuality", zero[ExpandScalarProduct[SPD[k1 + k2, k1 + k2]] - virtuality]];
gate["own channel", Environment["POLARIZED_SIDIS_CHANNEL"] === "Hgq"];
acceptedPath = FileNameJoin[{root, "common", "s10_result", "s10_result.wl"}];
accepted = Get[acceptedPath];
gate["accepted physical splitting calculation", accepted["Schema"] === "polarized-sidis-collinear-kernels-v1" &&
  accepted["SourceHash"] === FileHash[baselineSource, "SHA256"] &&
  accepted["SpinLabels"] === labels && And @@ Values[accepted["Checks"]]];
Do[gate["unchanged S10 input " <> name,
  FileHash[FileNameJoin[{root, name}], "SHA256"] === accepted["InputHashes"][name]],
  {name, Keys[accepted["InputHashes"]]}];
nativeDirectory = "/u/home/r/rushil/.Mathematica/Applications/FeynCalc/AddOns/FeynCalcLegacy/LegacyFunctions";
Do[gate["unchanged native vertex " <> name,
  FileHash[FileNameJoin[{nativeDirectory, name}], "SHA256"] === accepted["NativeSourceHashes"][name]],
  {name, Keys[accepted["NativeSourceHashes"]]}];
gate["same accepted native runtime", Hash[{FileHash[baselineSource, "SHA256"],
  accepted["InputHashes"], accepted["NativeSourceHashes"], $Version, $FeynCalcVersion}, "SHA256"] === accepted["InputHash"]];

physicalMomenta[expr_] := MomentumExpand[expr] /. HoldPattern[Momentum[mom_, D]] :>
  If[FreeQ[mom, _Polarization] && FreeQ[mom, k1 | k2], Momentum[mom], Momentum[mom, D]];
nativeScalar[expr_] := Factor[Together[ExpandScalarProduct[Contract[FCI[physicalMomenta[expr]]]]]];
scalarQ[expr_] := FreeQ[expr, _Pair | _Eps | _LorentzIndex | _Polarization |
  _DiracGamma | _DiracTrace | _Spinor | _Real | $Failed | $Aborted];
fullTransverse[leg_, left_, right_] := physicalMomenta[DoPolarizationSums[
  FVD[Polarization[leg, I], left] FVD[Polarization[leg, -I], right], leg, n]];
projectors[leg_, left_, right_] := projectors[leg, left, right] = Module[{axes, stokes, physicalTensors, full},
  axes = If[leg === p, {eX, eY}, {outX, outY}];
  stokes = (#[[{2, 3}, {2, 3}]] &) /@ basis["GluonStokesTensorsCanonical"];
  If[leg === k1, stokes = Transpose /@ stokes];
  physicalTensors = Table[FCI[Sum[stokes[[a, i, j]] FV[axes[[i]], left] FV[axes[[j]], right],
    {i, Length[axes]}, {j, Length[axes]}]], {a, Length[labels]}];
  full = fullTransverse[leg, left, right];
  Append[physicalTensors, Contract[full - physicalTensors[[uPosition]]]]];
extendedLabels = Append[labels, "E"];
gram = Association@Table[leg -> bounded[Table[nativeScalar[
    projectors[leg, gramLeft, gramRight][[i]] projectors[leg, gramRight, gramLeft][[j]]],
    {i, Length[extendedLabels]}, {j, Length[extendedLabels]}], {leg, "projector Gram matrix"}],
  {leg, {p, k1}}];
gate["native Gram matrices evaluated", scalarQ[gram]];
duals = Association@Table[leg -> Map[Factor, spinDimension Inverse[gram[leg]], {2}], {leg, {p, k1}}];
Do[gate[ToString[leg] <> " exact projector dual", zeroArray[
    gram[leg].duals[leg] - spinDimension IdentityMatrix[Length[extendedLabels]]]];
  gate[ToString[leg] <> " inherited physical projector normalization", zeroArray[
    gram[leg][[1 ;; Length[labels], 1 ;; Length[labels]]] - spinDimension spinIdentity]];
  gate[ToString[leg] <> " orthogonal dimensional complement", zeroArray[
    Join[gram[leg][[Length[extendedLabels], 1 ;; Length[labels]]],
      gram[leg][[1 ;; Length[labels], Length[extendedLabels]]]]]], {leg, {p, k1}}];

physicalTransverseRank = gram[p][[uPosition, uPosition]];
extraTransverseRank = gram[p][[Length[extendedLabels], Length[extendedLabels]]];
angularWeight = physicalFraction^(physicalTransverseRank/2 - 1) *
  (1 - physicalFraction)^(extraTransverseRank/2 - 1);
angularMoment[power_] := angularMoment[power] = bounded[FullSimplify[
  Integrate[physicalFraction^power angularWeight, {physicalFraction, 0, 1},
    Assumptions -> D > Length[pVector], GenerateConditions -> False]/
  Integrate[angularWeight, {physicalFraction, 0, 1},
    Assumptions -> D > Length[pVector], GenerateConditions -> False], D > Length[pVector]],
  {"dimensional angular moment", power}];
gate["normalized full transverse angular measure", zero[angularMoment[0] - 1]];
gate["native second moment agrees with dimensional transverse average", zero[
  angularMoment[1]/physicalTransverseRank - 1/(physicalTransverseRank + extraTransverseRank)]];
dimensionalAverage[expression_] := Module[{rational, numerator, denominator, coefficients},
  rational = Together[expression]; numerator = Numerator[rational]; denominator = Denominator[rational];
  gate["polynomial unresolved angular numerator", PolynomialQ[numerator, physicalFraction] &&
    FreeQ[denominator, physicalFraction]];
  coefficients = CoefficientList[numerator, physicalFraction];
  gate["exact unresolved angular reconstruction", Expand[numerator -
    Sum[coefficients[[index]] physicalFraction^(index - 1), {index, Length[coefficients]}]] === 0];
  Factor[Total[MapIndexed[#1 angularMoment[First[#2] - 1] &, coefficients]]/denominator]];

a = ChangeDimension[amplitudes["gg"], D]; b = a;
Do[a = a /. Momentum[Polarization[leg, ___], D] -> LorentzIndex[leftIndex[leg], D];
  b = b /. Momentum[Polarization[leg, ___], D] -> LorentzIndex[rightIndex[leg], D], {leg, {p, k1, k2}}];
openProduct = physicalMomenta[a ComplexConjugate[b, FCRenameDummyIndices -> True]];
gate["native gluon amplitude indices opened", FreeQ[openProduct, _Polarization]];
extendedIn = Append[inVariables, eIn]; extendedOut = Append[outVariables, eOut];
inDensity = extendedIn.projectors[p, leftIndex[p], rightIndex[p]];
outDensity = extendedOut.projectors[k1, leftIndex[k1], rightIndex[k1]];
value = bounded[nativeScalar[openProduct inDensity outDensity
  fullTransverse[k2, leftIndex[k2], rightIndex[k2]]/spinDimension], "extended gg contraction"];
gate["exact scalar extended response", scalarQ[value]];
coefficientMatrix = Table[coefficient[coefficient[value, extendedIn, i], extendedOut, j],
  {j, Length[extendedLabels]}, {i, Length[extendedLabels]}];
gate["exact extended spin reconstruction", zero[simplify[
  value - extendedOut.coefficientMatrix.extendedIn]]];
rawMatrix = Table[Print["GLUON_TRANSFER_COMPONENT ", j, " ", i];
  bounded[Module[{part, averaged},
    part = Together[TrigReduce[coefficientMatrix[[j, i]]/virtuality]];
    gate["inherited azimuth-independent denominator", FreeQ[Denominator[part], azimuth]];
    averaged = Integrate[part, {azimuth, 0, 2 Pi}, Assumptions -> physical, GenerateConditions -> False]/
      Integrate[1, {azimuth, 0, 2 Pi}];
    simplify[Limit[dimensionalAverage[averaged], transverseMagnitude -> 0]]], {j, i, "collinear limit"}],
  {j, Length[extendedLabels]}, {i, Length[extendedLabels]}];
gate["evaluated dimensional collinear response", scalarQ[rawMatrix] && FreeQ[rawMatrix,
  _Integrate | _Limit | _ConditionalExpression | _Piecewise | parentEnergy | transverseMagnitude | azimuth | physicalFraction]];
normalization = Factor[ordinary[unpolarized["Pgg"]]/
  Limit[rawMatrix[[uPosition, uPosition]], D -> Length[pVector]]];
gate["same reference-derived gg normalization", FreeQ[normalization, z | D | _Real] &&
  zero[normalization - accepted["Responses"]["gg"]["ReferenceNormalizationDerived"]]];
rawKernel = Map[Factor, normalization rawMatrix, {2}];
(* Signer and Stockinger, arXiv:0807.4424, Eq. (33): cross the parent
   and measured daughter before applying the new outgoing projector dual.
   The raw response uses the same fixed physical density normalization on
   both legs; the state-count conversion is retained by the Gram dual. *)
uncrossedPath = FileNameJoin[{root, "Hgq", "s10_gluon_transfer_result", "s10_result.wl"}];
uncrossed = Get[uncrossedPath];
gate["same accepted native projectors and physical limit", And @@ Values[uncrossed["Checks"]] &&
  zeroArray[Map[Limit[#, D -> Length[pVector]] &, rawKernel - uncrossed["RawDimensionalKernel"], {2}]] &&
  uncrossed["GramMatrices"] === gram &&
  uncrossed["DualMatrices"] === duals && uncrossed["NativeVersions"] === {$Version, $FeynCalcVersion}];
unpolarizedPositions = {uPosition, Length[extendedLabels]};
fullDimensionalKernel = Factor[spinDimension Total[Flatten[rawKernel[[unpolarizedPositions, unpolarizedPositions]]]]/
  (physicalTransverseRank + extraTransverseRank)];
gate["complete dimensional unpolarized gg kernel", zero[fullDimensionalKernel - ordinary[unpolarized["Pgg"]]]];
crossedFermions = Length[Cases[amplitudes["gg"], _Spinor, Infinity]];
gate["native crossing is purely gluonic", crossedFermions === 0];
crossingSign = (-1)^(crossedFermions + 1);
crossedRawKernel = Map[Factor, crossingSign z Transpose[rawKernel /. z -> 1/z], {2}];
pdfKernelD = Map[Factor, duals[p].crossedRawKernel, {2}];
ffKernelD = Map[Factor, rawKernel.duals[p], {2}];
pdfKernel = Map[Factor[Limit[#, D -> Length[pVector]]] &, pdfKernelD, {2}];
ffKernel = Map[Factor[Limit[#, D -> Length[pVector]]] &, ffKernelD, {2}];
gate["evaluated dual-normalized leading transitions", FreeQ[{pdfKernel, ffKernel},
  D | _Limit | Indeterminate | ComplexInfinity | _DirectedInfinity | _ConditionalExpression]];
Do[gate[side <> " full accepted physical spin block", zeroArray[
  kernel[[1 ;; Length[labels], 1 ;; Length[labels]]] - accepted["Responses"]["gg"]["RealKernel"]]],
  {pair, {{"PDF", pdfKernel}, {"FF", ffKernel}}}, {side, {First[pair]}}, {kernel, {Last[pair]}}];
pdfSoft = Map[Factor[Limit[(1 - z) #, z -> 1]] &, pdfKernel, {2}];
ffSoft = Map[Factor[Limit[(1 - z) #, z -> 1]] &, ffKernel, {2}];
gate["evaluated additional soft limits", FreeQ[{pdfSoft, ffSoft},
  z | D | _Limit | Indeterminate | ComplexInfinity | _DirectedInfinity | _ConditionalExpression]];
Print["NATIVE_GLUON_PDF_TRANSFER ", InputForm[pdfKernel]];
Print["NATIVE_GLUON_FF_TRANSFER ", InputForm[ffKernel]];
Print["NATIVE_GLUON_SOFT_TRANSFER ", InputForm[{pdfSoft, ffSoft}]];
inputPaths = DeleteDuplicates[Join[{baselineSource, acceptedPath, uncrossedPath},
  FileNameJoin[{root, #}] & /@ Keys[accepted["InputHashes"]]]];
result = <|"Schema" -> "polarized-sidis-gluon-intermediate-transfer-v1", "SpinLabels" -> extendedLabels,
  "IndexOrder" -> {"daughter spin", "parent spin"}, "GramMatrices" -> gram, "DualMatrices" -> duals,
  "RawDimensionalKernel" -> rawKernel, "CrossedRawDimensionalKernel" -> crossedRawKernel,
  "CrossingReference" -> "arXiv:0807.4424 Eq. (33)", "CrossedFermionCount" -> crossedFermions,
  "PDFKernelD" -> pdfKernelD, "FFKernelD" -> ffKernelD,
  "PDFLeadingKernel" -> pdfKernel, "FFLeadingKernel" -> ffKernel,
  "PDFSoftResidue" -> pdfSoft, "FFSoftResidue" -> ffSoft,
  "ReferenceNormalizationDerived" -> normalization, "DimensionLimit" -> Length[pVector],
  "AngularConvention" -> "Full D-2 transverse angular average; incoming crossing before Gram dual normalization",
  "AngularReference" -> "hep-ph/9610553 Eq. (30)", "AngularMoments" -> DownValues[angularMoment],
  "FullDimensionalUnpolarizedKernel" -> fullDimensionalKernel,
  "SourceHash" -> FileHash[studySource, "SHA256"], "BaselineSourceHash" -> FileHash[baselineSource, "SHA256"],
  "InputHashes" -> Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths],
  "NativeSourceHashes" -> accepted["NativeSourceHashes"], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "Checks" -> checks, "Accepted" -> True, "ConvolutionPerformed" -> False, "FiniteNLOFHatsComputed" -> False|>;
out = FileNameJoin[{root, "Hgq", "s10_dimensional_gluon_result"}];
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
path = FileNameJoin[{out, "s10_result.wl"}];
put[result, path]; gate["bounded native export", FileByteCount[path] < 128*1024^2];
gate["exact native result reload", Get[path] === result];
Export[FileNameJoin[{out, "s10_checks.json"}], <|"checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s10_dimensional_gluon_transfer"]; Quit[0];

(* Native q -> g fragmentation transfer in the accepted dimensional frame. *)
$HistoryLength = 0; root = Directory[];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynCalcLegacy"}; Get["FeynCalc`"];
dimensionalSource = FileNameJoin[{root, "common", "s10_dimensional_gluon_transfer.wls"}];
If[IntegerString[FileHash[dimensionalSource, "SHA256"], 16, 64] =!=
  "113b9968a31eec26914c7018515e9ca214bfbc622b9fe7f5a3b539037aef957d", Quit[1]];
dimensionalText = Import[dimensionalSource, "Text"];
adapterBoundary = StringPosition[dimensionalText, "a = ChangeDimension[amplitudes[\"gg\"], D];"];
If[Length[adapterBoundary] =!= 1, Quit[1]];
originalAdapterPrefix = StringTake[dimensionalText, First[First[adapterBoundary]] - 1];
adapterChanges = {
  "\"s10_dimensional_gluon_transfer.wls\"" -> "\"s10_dimensional_quark_gluon_transfer.wls\"",
  "Environment[\"POLARIZED_SIDIS_CHANNEL\"] === \"Hgq\"" ->
    "Environment[\"POLARIZED_SIDIS_CHANNEL\"] === \"Hqg\""};
If[!And @@ (StringCount[originalAdapterPrefix, First[#]] === 1 & /@ adapterChanges), Quit[1]];
adapterPrefix = StringReplace[originalAdapterPrefix, adapterChanges];
If[StringReplace[adapterPrefix, Reverse /@ adapterChanges] =!= originalAdapterPrefix, Quit[1]];
ToExpression[adapterPrefix, InputForm];
gate["complete qg entry syntax", SyntaxQ[Import[studySource, "Text"]]];

(* Only the resolved parent gets a physical spin density.  The unobserved
   quark retains the dimensional spin sum from the generated amplitude. *)
a = ChangeDimension[amplitudes["qg"], D]; b = a;
a = a /. Momentum[Polarization[k1, ___], D] -> LorentzIndex[leftIndex[k1], D];
b = b /. Momentum[Polarization[k1, ___], D] -> LorentzIndex[rightIndex[k1], D];
closed = FermionSpinSum[a ComplexConjugate[b, FCRenameDummyIndices -> True],
  Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
closed = closed /. HoldPattern[keptSpinSum[DiracGamma[Momentum[p, ___], ___]]] :>
  spinNumerator[p, inVariables, {eX, eY}, False];
closed = closed /. keptSpinSum[other_] :> other;
gate["complete native quark spin closure", FreeQ[closed, keptSpinSum | _Spinor | _Polarization]];
extendedOut = Append[outVariables, eOut];
outDensity = extendedOut.projectors[k1, leftIndex[k1], rightIndex[k1]];
value = bounded[Contract[DiracSimplify[physicalMomenta[closed outDensity/spinDimension],
    DiracTraceEvaluate -> True]], "dimensional qg trace"];
value = Factor[Together[EpsEvaluate[ExpandScalarProduct[value]] /. epsilonRule]];
gate["exact scalar dimensional qg response", scalarQ[value]];
coefficientMatrix = Table[coefficient[coefficient[value, inVariables, i], extendedOut, j],
  {j, Length[extendedLabels]}, {i, Length[labels]}];
gate["complete dimensional qg spin reconstruction", zero[simplify[
  value - extendedOut.coefficientMatrix.inVariables]]];
rawMatrix = Table[Print["QUARK_GLUON_TRANSFER_COMPONENT ", j, " ", i];
  bounded[Module[{part, averaged},
    part = Together[TrigReduce[coefficientMatrix[[j, i]]/virtuality]];
    gate["inherited qg azimuth-independent denominator", FreeQ[Denominator[part], azimuth]];
    averaged = Integrate[part, {azimuth, 0, 2 Pi}, Assumptions -> physical, GenerateConditions -> False]/
      Integrate[1, {azimuth, 0, 2 Pi}];
    simplify[Limit[dimensionalAverage[averaged], transverseMagnitude -> 0]]],
    {j, i, "qg collinear limit"}],
  {j, Length[extendedLabels]}, {i, Length[labels]}];
gate["evaluated dimensional qg collinear response", scalarQ[rawMatrix] && FreeQ[rawMatrix,
  _Integrate | _Limit | _ConditionalExpression | _Piecewise | parentEnergy |
  transverseMagnitude | azimuth | physicalFraction]];
normalization = Factor[ordinary[unpolarized[referenceNames["qg"]]]/
  Limit[rawMatrix[[uPosition, uPosition]], D -> Length[pVector]]];
gate["same reference-derived qg normalization", FreeQ[normalization, z | D | _Real] &&
  zero[normalization - accepted["Responses"]["qg"]["ReferenceNormalizationDerived"]]];
rawKernel = Map[Factor, normalization rawMatrix, {2}];
physicalPositions = Flatten[FirstPosition[extendedLabels, #] & /@ labels];
ePosition = First[FirstPosition[extendedLabels, "E"]];
physicalKernelD = rawKernel[[physicalPositions, All]];
leadingKernel = Map[Factor[Limit[#, D -> Length[pVector]]] &, physicalKernelD, {2}];
gate["all physical qg spin entries reproduce accepted S10", zeroArray[
  leadingKernel - accepted["Responses"]["qg"]["RealKernel"]]];
gate["extra gluon response has zero physical limit", zeroArray[
  Map[Limit[#, D -> Length[pVector]] &, rawKernel[[ePosition]]]]];
completion = Table[KroneckerDelta[k, physicalPositions[[i]]] +
    If[labels[[i]] === "U", KroneckerDelta[k, ePosition], 0],
  {i, Length[labels]}, {k, Length[extendedLabels]}];
cdrKernelD = Map[Factor, completion.rawKernel, {2}];
cdrLeading = Map[Factor[Limit[#, D -> Length[pVector]]] &, cdrKernelD, {2}];
gate["CDR qg physical limit preserves all spin components", zeroArray[cdrLeading - leadingKernel]];
cdrRemainder = Map[Factor, cdrKernelD - cdrLeading, {2}];
msOperatorD = Map[Factor, physicalKernelD - cdrRemainder, {2}];
kernelDifferenceD = Map[Factor, msOperatorD - leadingKernel, {2}];
gate["native qg MS operator reconstruction", zeroArray[
  msOperatorD + cdrRemainder - physicalKernelD]];
gate["qg MS change has zero physical limit", zeroArray[
  Map[Limit[#, D -> Length[pVector]] &, kernelDifferenceD, {2}]]];
gate["qg MS change has no soft endpoint", zeroArray[
  Map[Limit[(1 - z) #, z -> 1] &, kernelDifferenceD, {2}]]];
Print["NATIVE_QG_DIMENSIONAL_MATRIX ", InputForm[rawKernel]];
Print["NATIVE_QG_CDR_MATRIX ", InputForm[cdrKernelD]];
Print["NATIVE_QG_MS_DIFFERENCE ", InputForm[kernelDifferenceD]];
inputPaths = DeleteDuplicates[Join[{dimensionalSource, baselineSource, acceptedPath},
  FileNameJoin[{root, #}] & /@ Keys[accepted["InputHashes"]]]];
result = <|"Schema" -> "polarized-sidis-quark-gluon-transfer-v1", "Channel" -> "Hqg",
  "IncomingSpinLabels" -> labels, "OutgoingSpinLabels" -> extendedLabels,
  "IndexOrder" -> {"daughter spin", "parent spin"},
  "RawDimensionalKernel" -> rawKernel, "PhysicalKernelD" -> physicalKernelD,
  "LeadingKernel" -> leadingKernel, "CDRKernelD" -> cdrKernelD,
  "CDRRegulatorRemainder" -> cdrRemainder, "MSOperatorD" -> msOperatorD,
  "KernelDifferenceD" -> kernelDifferenceD, "MSReference" -> "arXiv:0807.4424 Eqs. (36)-(39)",
  "DimensionLimit" -> Length[pVector], "ReferenceNormalizationDerived" -> normalization,
  "AngularConvention" -> "Full D-2 transverse angular average; same accepted S10 frame and physical axes",
  "AngularMoments" -> DownValues[angularMoment],
  "SourceHash" -> FileHash[studySource, "SHA256"],
  "InputHashes" -> Association[(StringDrop[#, StringLength[root] + 1] -> FileHash[#, "SHA256"]) & /@ inputPaths],
  "NativeSourceHashes" -> accepted["NativeSourceHashes"], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "Checks" -> checks, "Accepted" -> True, "ConvolutionPerformed" -> False, "FiniteNLOFHatsComputed" -> False|>;
out = FileNameJoin[{root, "Hqg", "s10_dimensional_quark_gluon_result"}];
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
path = FileNameJoin[{out, "s10_result.wl"}]; put[result, path];
gate["bounded qg native export", FileByteCount[path] < 128*1024^2];
gate["exact qg native result reload", Get[path] === result];
Export[FileNameJoin[{out, "s10_checks.json"}], <|"checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s10_dimensional_quark_gluon_transfer"]; Quit[0];

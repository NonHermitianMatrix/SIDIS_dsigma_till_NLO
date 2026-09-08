(* Paper Eq. 46: symbolic PDF and fragmentation convolutions in s23. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
$LoadAddOns = {"FeynCalcLegacy"};
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, convolution, mappedBorn];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
generated = Get[FileNameJoin[{root, "s01_result.wl"}]];
gate["S02 source identity", born["SourceHash"] === FileHash[FileNameJoin[{root, "s02_born_and_projectors.wl"}], "SHA256"]];
gate["S01 source identity", generated["SourceHash"] === FileHash[FileNameJoin[{root, "s01_generate_amplitudes.wl"}], "SHA256"]];
physical = Q2 > 0 && s > s23 > 0 && s23 - Q2 - s < t < -Q2 s23/s && B > 0;
endpointRegion = Q2 > 0 && s > 0 && -Q2 - s < t < 0 && B > 0;

cfValue = born["ColorConstants"]["CF"];
caValue = born["ColorConstants"]["CA"];
tfValue = born["ColorConstants"]["TF"];
colorNames = <|"CF" -> cfValue, "CA" -> caValue, "Tf" -> tfValue, "Nf" -> Nf|>;
libraryKernels = Association@Table[name -> (SplittingFunction[name, x, Polarization -> 0] /.
  symbol_Symbol /; KeyExistsQ[colorNames, SymbolName[Unevaluated[symbol]]] :>
    colorNames[SymbolName[Unevaluated[symbol]]]), {name, {"Pqq", "Pqg", "Pgg"}}];
libraryKernels = libraryKernels /.
  {head_[argument_] /; SymbolName[Unevaluated[head]] === "PlusDistribution" :> kernelPlus[argument],
   head_[argument_] /; SymbolName[Unevaluated[head]] === "DeltaFunction" :> kernelDelta[argument]};
gate["splitting-function tool evaluated", FreeQ[libraryKernels, _SplittingFunction]];
(* Defining reference conventions: paper Eqs. 51-53. *)
paperPqq = 2 cfValue (2 kernelPlus[1/(1 - x)] - 1 - x + 3 kernelDelta[1 - x]/2);
paperPqg = 2 tfValue ((1 - x)^2 + x^2);
paperPgq = 2 cfValue (1 + (1 - x)^2)/x;
normalizations = <|"Pqq" -> Factor[paperPqq/libraryKernels["Pqq"]],
  "Pqg" -> Factor[paperPqg/libraryKernels["Pqg"]]|>;
kernelMoment[kernel_, test_] := Module[{expression, plus, delta, ordinary},
  expression = Expand[kernel /. {kernelPlus[1/(1 - x)] -> p0, kernelDelta[1 - x] -> d0}];
  plus = Coefficient[expression, p0]; delta = Coefficient[expression, d0];
  ordinary = expression /. {p0 -> 0, d0 -> 0};
  Factor[Integrate[Cancel[test ordinary + plus (test - (test /. x -> 1))/(1 - x)],
    {x, 0, 1}, Assumptions -> SUNN > 1 && Nf >= 0, GenerateConditions -> False] + delta (test /. x -> 1)]];
fermionSpecies = Select[DeleteDuplicates[Flatten[Values[generated["OutgoingSpecies"]]]],
  MemberQ[{quark, antiquark}, #] &];
fermionMultiplicity = Length[fermionSpecies];
gluonMomentumEquation = kernelMoment[ggNormalization libraryKernels["Pgg"], x] +
  Nf fermionMultiplicity kernelMoment[paperPqg, x] == 0;
gluonSolutions = Solve[gluonMomentumEquation, ggNormalization];
gate["gluon momentum sum rule fixes one kernel normalization", Length[gluonSolutions] === 1];
AssociateTo[normalizations, "Pgg" -> Factor[ggNormalization /. First[gluonSolutions]]];
gate["kernel normalizations are exact constants", FreeQ[normalizations,
  x | SUNN | Nf | ggNormalization | _kernelPlus | _kernelDelta | _Real | _Integrate]];
kernels = Association@KeyValueMap[(#1 -> Factor[normalizations[#1] #2]) &, libraryKernels];
gate["Pqq agrees with paper Eq. 51", Factor[kernels["Pqq"] - paperPqq] === 0];
gate["Pqg agrees with paper Eq. 52", Factor[kernels["Pqg"] - paperPqg] === 0];
gate["quark number sum rule", kernelMoment[kernels["Pqq"], 1] === 0];
gate["quark momentum sum rule", kernelMoment[kernels["Pqq"] + paperPgq, x] === 0];
gate["gluon momentum sum rule", Factor[kernelMoment[kernels["Pgg"], x] +
  Nf fermionMultiplicity kernelMoment[kernels["Pqg"], x]] === 0];
Print["Derived kernel normalizations = ", InputForm[normalizations]];

(* Enumerate Eq. 46 using generated incoming and final-state species. *)
splittingName[daughter_, parent_] := Which[
  daughter === gluon && parent === gluon, "Pgg",
  MemberQ[fermionSpecies, daughter] && daughter === parent, "Pqq",
  MemberQ[fermionSpecies, daughter] && parent === gluon, "Pqg",
  daughter === gluon && MemberQ[fermionSpecies, parent], "Pgq", True, Missing["Zero"]];
externalIncoming = First[DeleteCases[generated["IncomingSpecies"]["Born"], photon]];
externalObserved = generated["ObservedSpecies"];
bornProcesses = Flatten[Table[
  incoming = First[DeleteCases[generated["IncomingSpecies"][key], photon]];
  Table[<|"Born" -> key, "Incoming" -> incoming, "Observed" -> tag|>,
    {tag, DeleteDuplicates[generated["OutgoingSpecies"][key]]}], {key, {"Born", "AuxHqqBorn"}}], 1];
routes = Join[
  Map[Append[#, "Side" -> "PDF"] &, Select[bornProcesses,
    #["Observed"] === externalObserved && !MissingQ[splittingName[#["Incoming"], externalIncoming]] &]],
  Map[Append[#, "Side" -> "FF"] &, Select[bornProcesses,
    #["Incoming"] === externalIncoming && !MissingQ[splittingName[externalObserved, #["Observed"]]] &]]];
routes = Map[Append[#, "Kernel" -> If[#["Side"] === "PDF",
  splittingName[#["Incoming"], externalIncoming], splittingName[externalObserved, #["Observed"]]]] &, routes];
gate["selected routes have generated observed-quark Born inputs", Length[routes] > 0 &&
  And @@ (#["Observed"] === externalObserved && KeyExistsQ[kernels, #["Kernel"]] & /@ routes)];
Print["Generated Eq. 46 routes = ", InputForm[routes]];

FCClearScalarProducts[];
DataType[eta, FCVariable] = True;
DataType[zeta, FCVariable] = True;
Scan[Function[row, With[{v1 = row[[1]], v2 = row[[2]], value = row[[3]]},
  SPD[v1, v2] = value]], born["RealScalarProducts"]];
invariants = <|"s" -> ExpandScalarProduct[SPD[eta p + q]],
  "t" -> ExpandScalarProduct[SPD[q - k1/zeta]],
  "recoil" -> ExpandScalarProduct[SPD[eta p + q - k1/zeta]]|>;
gate["scaled invariants contain no unresolved scalar products", FreeQ[invariants, _Pair]];
gate["unscaled recoil is s23", Factor[invariants["recoil"] /. {eta -> 1, zeta -> 1}] === s23];
incomingRoot = eta /. First[Solve[(invariants["recoil"] /. zeta -> 1) == 0, eta]];
outgoingRoot = zeta /. First[Solve[(invariants["recoil"] /. eta -> 1) == 0, zeta]];
incomingJacobian = FullSimplify[1/Abs[D[invariants["recoil"], eta] /.
  {eta -> incomingRoot, zeta -> 1}], physical];
outgoingJacobian = FullSimplify[1/Abs[D[invariants["recoil"], zeta] /.
  {eta -> 1, zeta -> outgoingRoot}], physical];
gate["convolution roots lie inside the partonic support", FullSimplify[
  0 < incomingRoot < 1 && 0 < outgoingRoot < 1, physical]];

(* Derive the pp projector conversion from the tensor definition, Eq. 16. *)
transverse[mu_] := FVD[eta p, mu] - FVD[q, mu] SPD[eta p, q]/SPD[q, q];
tensor = (-MTD[mu, nu] + FVD[q, mu] FVD[q, nu]/SPD[q, q]) f1 +
  transverse[mu] transverse[nu] f2/SPD[eta p, q];
incomingProjectorScale = Factor[Contract[FVD[p, mu] FVD[p, nu] tensor]/
  Contract[FVD[eta p, mu] FVD[eta p, nu] tensor]] // ExpandScalarProduct // Factor;
gate["projector conversion does not depend on the tensor coefficients", FreeQ[
  incomingProjectorScale, f1 | f2 | _Pair]];
bornD = <|"Born" -> <|"Pg" -> born["BornPg"], "Ppp" -> born["BornPpp"]|>,
  "AuxHqqBorn" -> born["AuxHqqBorn"]|>;
mappedBorn[mode_, key_] := (bornD[key][mode] /.
  {s -> invariants["s"], t -> invariants["t"]}) *
  If[mode === "Ppp", incomingProjectorScale, 1];

convolution[mode_, key_, kernel_, rootValue_, weight_] := Module[{expandedKernel, plusCoefficient,
  deltaCoefficient, regularKernel, poleFunction, endpointCoefficient, endpointRatio,
  bornEndpoint, mappedDelta, result},
  expandedKernel = Expand[kernel /. {kernelPlus[1/(1 - x)] -> p0, kernelDelta[1 - x] -> d0}];
  plusCoefficient = Coefficient[expandedKernel, p0];
  deltaCoefficient = Coefficient[expandedKernel, d0];
  regularKernel = expandedKernel /. {p0 -> 0, d0 -> 0};
  bornEndpoint = bornD[key][mode];
  If[plusCoefficient =!= 0,
    poleFunction = Factor[weight/(1 - rootValue)];
    endpointCoefficient = FullSimplify[Limit[s23 poleFunction, s23 -> 0], endpointRegion];
    endpointRatio = FullSimplify[Limit[(1 - rootValue)/s23, s23 -> 0], endpointRegion];
    gate["plus mapping has a positive endpoint scale", FullSimplify[endpointRatio > 0, endpointRegion]];
    gate["auxiliary endpoint pole cancels", Factor[endpointCoefficient - bornEndpoint] === 0];
    mappedDelta = FullSimplify[Normal[Series[
      (B^lambdaCut endpointRatio^lambdaCut endpointCoefficient - bornEndpoint)/lambdaCut,
      {lambdaCut, 0, 0}]], endpointRegion],
    poleFunction = 0; endpointCoefficient = 0; mappedDelta = 0];
  result = <|"Delta" -> Factor[deltaCoefficient bornEndpoint + plusCoefficient mappedDelta],
    "L0" -> Factor[plusCoefficient endpointCoefficient],
    "Regular" -> Factor[weight (regularKernel /. x -> rootValue) +
      plusCoefficient (poleFunction - endpointCoefficient/s23)]|>;
  gate["mapped convolution reconstructs its ordinary part", Factor[result["Regular"] +
    result["L0"]/s23 - weight (kernel /. {kernelDelta[_] -> 0, kernelPlus[a_] :> a} /. x -> rootValue)] === 0];
  result];

contributions = Association@Table[mode -> Association@Table[
  key = route["Born"];
  weight = If[route["Side"] === "PDF",
    Factor[incomingJacobian/incomingRoot * (mappedBorn[mode, key] /. {eta -> incomingRoot, zeta -> 1})],
    Factor[outgoingJacobian/outgoingRoot^2 * (mappedBorn[mode, key] /. {eta -> 1, zeta -> outgoingRoot})]];
  StringRiffle[{route["Side"], key, route["Kernel"]}, "_"] -> convolution[mode, key,
    kernels[route["Kernel"]], If[route["Side"] === "PDF", incomingRoot, outgoingRoot], weight],
  {route, routes}], {mode, {"Pg", "Ppp"}}];

(* Convert the Eq. 46 coupling factor to the same eq^2 gs^4 normalization. *)
alphaRule = First[Solve[gs^2 == 4 Pi alphaS, alphaS]];
prefactor = Factor[(gs^2 alphaS/(4 Pi) (2 Pi)/gs^4) /. alphaRule];
msPole = 1/eps - EulerGamma + Log[4 Pi];
result = Association@Table[mode -> Association@Table[distribution -> bounded[
  Normal[Series[prefactor msPole (Total[(#[distribution] &) /@
    Values[contributions[mode]]] /. D -> 4 - 2 eps), {eps, 0, 0}]], {mode, distribution}],
  {distribution, {"Delta", "L0", "Regular"}}], {mode, {"Pg", "Ppp"}}];
Put[<|"Counterterms" -> result, "ConvolutionsD" -> contributions, "Kernels" -> kernels,
  "KernelNormalization" -> normalizations, "Routes" -> routes,
  "FermionSpeciesMultiplicity" -> fermionMultiplicity, "AuthorsCoefficientsUsed" -> False, "IncomingRoot" -> incomingRoot,
  "OutgoingRoot" -> outgoingRoot, "IncomingJacobian" -> incomingJacobian,
  "OutgoingJacobian" -> outgoingJacobian, "IncomingProjectorScale" -> incomingProjectorScale,
  "Prefactor" -> prefactor, "Regulator" -> eps, "PlusDefinition" -> "L0=[1/s23]_+ on [0,B]",
  "CouplingsRemoved" -> "eq^2 gs^4", "HardTensorNormalization" -> "(2 Pi)^(-4) applied at final assembly",
  "InputHashes" -> Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
    {name, {"s01_result.wl", "s02_result.wl"}}],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s08_result.wl"}]];
Print["S08_SUCCESS; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

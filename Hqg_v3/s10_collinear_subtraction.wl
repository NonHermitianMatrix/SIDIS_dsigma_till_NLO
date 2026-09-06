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
real = Get[FileNameJoin[{root, "s05_result.wl"}]];
physical = Q2 > 0 && s > s23 > 0 && s23 - Q2 - s < t < -Q2 s23/s && B > 0;
endpointRegion = Q2 > 0 && s > 0 && -Q2 - s < t < 0 && B > 0;

adjointDimension = SUNSimplify[SUNDelta[ac, ac], SUNNToCACF -> False];
cfValue = born["ColorAverage"];
caValue = Factor[SUNSimplify[SUNF[ac, bc, cc] SUNF[ac, bc, cc],
  SUNNToCACF -> False]/adjointDimension];
tfValue = Factor[SUNSimplify[SUNTrace[SUNT[ac, ac]], SUNNToCACF -> False]/adjointDimension];
colorNames = <|"CF" -> cfValue, "CA" -> caValue, "Tf" -> tfValue, "Nf" -> Nf|>;
libraryKernels = Association@Table[name -> (SplittingFunction[name, x, Polarization -> 0] /.
  symbol_Symbol /; KeyExistsQ[colorNames, SymbolName[Unevaluated[symbol]]] :>
    colorNames[SymbolName[Unevaluated[symbol]]]), {name, {"Pqq", "Pgq", "Pgg"}}];
libraryKernels = libraryKernels /.
  {head_[argument_] /; SymbolName[Unevaluated[head]] === "PlusDistribution" :> kernelPlus[argument],
   head_[argument_] /; SymbolName[Unevaluated[head]] === "DeltaFunction" :> kernelDelta[argument]};
gate["splitting-function tool evaluated", FreeQ[libraryKernels, _SplittingFunction]];
(* Reference kernel conventions are inputs from paper Eqs. 51 and 53. *)
paperPqq = 2 cfValue (2 kernelPlus[1/(1 - x)] - 1 - x + 3 kernelDelta[1 - x]/2);
paperPgq = 2 cfValue (1 + (1 - x)^2)/x;
kernelNormalization = Factor[paperPqq/libraryKernels["Pqq"]];
gate["kernel normalization is an exact constant", FreeQ[kernelNormalization,
  x | SUNN | _kernelPlus | _kernelDelta | _Real]];
kernels = Map[Factor[kernelNormalization #] &, libraryKernels];
gate["quark-to-gluon kernel agrees with paper Eq. 53", Factor[kernels["Pgq"] - paperPgq] === 0];
Print["Splitting-function normalization: ", InputForm[kernelNormalization]];

FCClearScalarProducts[];
DataType[eta, FCVariable] = True;
DataType[zeta, FCVariable] = True;
Scan[Function[row, With[{v1 = row[[1]], v2 = row[[2]], value = row[[3]]},
  SPD[v1, v2] = value]], real["RealScalarProducts"]];
invariants = <|"s" -> ExpandScalarProduct[SPD[eta p + q]],
  "t" -> ExpandScalarProduct[SPD[q - k1/zeta]],
  "recoil" -> ExpandScalarProduct[SPD[eta p + q - k1/zeta]],
  "quarkParentTag" -> ExpandScalarProduct[SPD[q - (eta p + q - k1/zeta)]]|>;
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
bornD = <|"Pg" -> born["BornPg"], "Ppp" -> born["BornPpp"]|>;
mappedBorn[mode_, parent_] := (bornD[mode] /.
  {s -> invariants["s"], t -> invariants[If[parent === gluon, "t", "quarkParentTag"]]}) *
  If[mode === "Ppp", incomingProjectorScale, 1];

convolution[mode_, kernel_, rootValue_, weight_] := Module[{expandedKernel, plusCoefficient,
  deltaCoefficient, regularKernel, poleFunction, endpointCoefficient, endpointRatio,
  bornEndpoint, mappedDelta, result},
  expandedKernel = Expand[kernel /. {kernelPlus[1/(1 - x)] -> p0, kernelDelta[1 - x] -> d0}];
  plusCoefficient = Coefficient[expandedKernel, p0];
  deltaCoefficient = Coefficient[expandedKernel, d0];
  regularKernel = expandedKernel /. {p0 -> 0, d0 -> 0};
  bornEndpoint = bornD[mode];
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

contributions = Association@Table[
  initialWeight = Factor[incomingJacobian/incomingRoot *
    (mappedBorn[mode, gluon] /. {eta -> incomingRoot, zeta -> 1})];
  gluonWeight = Factor[outgoingJacobian/outgoingRoot^2 *
    (mappedBorn[mode, gluon] /. {eta -> 1, zeta -> outgoingRoot})];
  quarkWeight = Factor[outgoingJacobian/outgoingRoot^2 *
    (mappedBorn[mode, quark] /. {eta -> 1, zeta -> outgoingRoot})];
  mode -> <|"PDF" -> convolution[mode, kernels["Pqq"], incomingRoot, initialWeight],
    "GluonFragmentation" -> convolution[mode, kernels["Pgg"], outgoingRoot, gluonWeight],
    "QuarkFragmentation" -> convolution[mode, kernels["Pgq"], outgoingRoot, quarkWeight]|>,
  {mode, {"Pg", "Ppp"}}];

(* Convert the Eq. 46 coupling factor to the same eq^2 gs^4 normalization. *)
alphaRule = First[Solve[gs^2 == 4 Pi alphaS, alphaS]];
prefactor = Factor[(gs^2 alphaS/(4 Pi) (2 Pi)/gs^4) /. alphaRule];
msPole = 1/eps - EulerGamma + Log[4 Pi];
result = Association@Table[mode -> Association@Table[distribution -> bounded[
  Normal[Series[prefactor msPole (Total[(#[distribution] &) /@
    Values[contributions[mode]]] /. D -> 4 - 2 eps), {eps, 0, 0}]], {mode, distribution}],
  {distribution, {"Delta", "L0", "Regular"}}], {mode, {"Pg", "Ppp"}}];
Put[<|"Counterterms" -> result, "ConvolutionsD" -> contributions, "Kernels" -> kernels,
  "KernelNormalization" -> kernelNormalization, "IncomingRoot" -> incomingRoot,
  "OutgoingRoot" -> outgoingRoot, "IncomingJacobian" -> incomingJacobian,
  "OutgoingJacobian" -> outgoingJacobian, "IncomingProjectorScale" -> incomingProjectorScale,
  "Prefactor" -> prefactor, "Regulator" -> eps, "PlusDefinition" -> "L0=[1/s23]_+ on [0,B]",
  "CouplingsRemoved" -> "eq^2 gs^4", "HardTensorNormalization" -> "(2 Pi)^(-4) applied at final assembly",
  "InputHashes" -> Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
    {name, {"s02_result.wl", "s05_result.wl"}}],
  "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>, FileNameJoin[{root, "s10_result.wl"}]];
Print["Wrote s10_result.wl; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

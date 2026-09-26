(* Physical spin-density and photon bases, derived and checked on Hoffman2. *)
$HistoryLength = 0;
root = Directory[];
ClearAll[gate, zeroQ, atomicPut, simplify, slash, adjoint];
checks = <||>;
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True];
  Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] &&
  !StringStartsQ[$MachineName, "login"]];
gate["isolated Wolfram user base", StringStartsQ[$UserBaseDirectory, root <> "/"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False;
$LoadAddOns = {"FeynArts"};
Get["FeynCalc`"];
FCSetDiracGammaScheme["BMHV"];
gate["BMHV active", FCGetDiracGammaScheme[] === "BMHV"];
atomicPut[value_, path_] := (If[!DirectoryQ[DirectoryName[path]],
  CreateDirectory[DirectoryName[path], CreateIntermediateDirectories -> True]];
  Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
zeroQ[value_] := And @@ (TrueQ[# === 0] & /@ Flatten[{value}]);
simplify[value_] := FullSimplify[value, Assumptions -> kappa > 0 && mass > 0];

config = Import[FileNameJoin[{root, "common", "s01_inputs.json"}], "RawJSON"];
receipt = Import[FileNameJoin[{root, "common", "s01_result", "s01_result.json"}], "RawJSON"];
gate["S01 accepted", receipt["input_identity_checks_passed"] === True];
gate["configuration identity", receipt["configuration_sha256"] ===
  IntegerString[FileHash[FileNameJoin[{root, "common", "s01_inputs.json"}], "SHA256"], 16, 64]];
inventory = Association@Table[
  contract = config["channel_contracts"][channel];
  path = FileNameJoin[{root, contract["amplitude_file"]}];
  row = SelectFirst[config["files"], #["destination"] === contract["amplitude_file"] &];
  gate[channel <> " amplitude identity", IntegerString[FileHash[path, "SHA256"], 16, 64] === row["sha256"]];
  packet = Get[path];
  gate[channel <> " amplitude association", AssociationQ[packet]];
  sectors = If[contract["amplitude_schema"] === "core",
    Select[Keys[packet], MemberQ[{"Born", "Virtual", "Real", "RealQGG", "RealSame", "RealDistinct"}, #] &], {"amplitudes"}];
  sectors = Select[sectors, ListQ[packet[#]] &];
  gate[channel <> " open external states", Length[sectors] > 0 && And @@ Table[
    Length[packet[sector]] > 0 && !FreeQ[packet[sector], _Spinor] &&
      !FreeQ[packet[sector], _Polarization], {sector, sectors}]];
  channel -> <|"InputSHA256" -> row["sha256"], "Sectors" ->
    Association@Table[sector -> <|"DiagramCount" -> Length[packet[sector]],
      "SpinorMomenta" -> DeleteDuplicates[Cases[packet[sector], Spinor[mom_, __] :> mom, Infinity]],
      "PolarizationMomenta" -> DeleteDuplicates[Cases[packet[sector], Polarization[mom_, __] :> mom, Infinity]]|>,
      {sector, sectors}]|>, {channel, config["channels"]}];
Clear[packet];

(* Pauli density matrix and its complete response basis. *)
sigma = Prepend[Table[PauliMatrix[i], {i, 3}], IdentityMatrix[Length[PauliMatrix[1]]]];
spinDimension = Tr[First[sigma]];
spinLabels = {"U", "X", "Y", "H"};
pauliGram = Table[Tr[sigma[[i]].sigma[[j]]], {i, Length[sigma]}, {j, Length[sigma]}];
gate["complete Pauli basis", MatrixRank[Flatten /@ sigma] === spinDimension^2];
rho = Total[MapThread[Times, {{1, px, py, pz}, sigma}]]/spinDimension;
gate["density trace", Simplify[Tr[rho]] === 1];
gate["density Hermiticity", zeroQ[ComplexExpand[rho - ConjugateTranspose[rho]]]];
gate["pure state idempotence", zeroQ[FullSimplify[rho.rho - rho,
  Assumptions -> Element[{px, py, pz}, Reals] && px^2 + py^2 + pz^2 == 1]]];
rhoEigenvalues = FullSimplify[Eigenvalues[rho], Assumptions -> Element[{px, py, pz}, Reals]];
spinOperators = Flatten[Table[KroneckerProduct[Transpose[sigma[[i]]], sigma[[j]]],
  {i, Length[sigma]}, {j, Length[sigma]}], 1];
gate["complete incoming outgoing response", MatrixRank[Flatten /@ spinOperators] === spinDimension^4];

(* Derive Dirac representatives from massive normalized wavefunctions. *)
z2 = ConstantArray[0, Dimensions[First[sigma]]];
gamma0 = ArrayFlatten[{{First[sigma], z2}, {z2, -First[sigma]}}];
gammaSpace = Table[ArrayFlatten[{{z2, sigma[[i + 1]]}, {-sigma[[i + 1]], z2}}], {i, 3}];
gammas = Prepend[gammaSpace, gamma0];
diracDimension = Length[gamma0];
metric = Table[Tr[gammas[[i]].gammas[[j]]]/diracDimension,
  {i, Length[gammas]}, {j, Length[gammas]}];
gate["Clifford algebra", zeroQ[Table[gammas[[i]].gammas[[j]] + gammas[[j]].gammas[[i]] -
  2 metric[[i, j]] IdentityMatrix[diracDimension], {i, Length[gammas]}, {j, Length[gammas]}]]];
gamma5 = I (Dot @@ gammas);
gate["gamma5 squared", gamma5.gamma5 === IdentityMatrix[diracDimension]];
slash[vector_] := Total[MapThread[Times, {metric.vector, gammas}]];
adjoint[matrix_] := ConjugateTranspose[matrix].gamma0;
helicities = {1, -1};
chi = Table[First[NullSpace[sigma[[4]] - h First[sigma]]], {h, helicities}];
energy = Sqrt[kappa^2 + mass^2];
momentumMassive = {energy, 0, 0, kappa};
u = Transpose[Table[Sqrt[energy + mass] Join[chi[[i]],
  kappa sigma[[4]].chi[[i]]/(energy + mass)], {i, Length[chi]}]];
chargeConjugation = I gammas[[3]].gamma0;
v = chargeConjugation.Transpose[adjoint[u]];
gate["quark Dirac equation", zeroQ[simplify[(slash[momentumMassive] - mass IdentityMatrix[diracDimension]).u]]];
gate["antiquark Dirac equation", zeroQ[simplify[(slash[momentumMassive] + mass IdentityMatrix[diracDimension]).v]]];
gate["quark normalization", zeroQ[simplify[u.adjoint[u] - slash[momentumMassive] - mass IdentityMatrix[diracDimension]]]];
gate["antiquark normalization", zeroQ[simplify[v.adjoint[v] - slash[momentumMassive] + mass IdentityMatrix[diracDimension]]]];
u0 = FullSimplify[Limit[u, mass -> 0, Direction -> "FromAbove"], Assumptions -> kappa > 0];
v0 = FullSimplify[Limit[v, mass -> 0, Direction -> "FromAbove"], Assumptions -> kappa > 0];
momentumMassless = Limit[momentumMassive, mass -> 0, Direction -> "FromAbove", Assumptions -> kappa > 0];
sx = {0, 1, 0, 0}; sy = {0, 0, 1, 0};
diracBasis = {slash[momentumMassless], gamma5.slash[momentumMassless],
  gamma5.slash[sx].slash[momentumMassless], gamma5.slash[sy].slash[momentumMassless]};
diracMap = Transpose[Flatten /@ diracBasis];
gate["independent massless Dirac basis", MatrixRank[diracMap] === Length[sigma]];
quarkMatrices = simplify[u0.#.adjoint[u0]] & /@ sigma;
(* Antiquark amplitudes place v and vbar in the reverse order of their
   physical-state labels; transposition follows the density-matrix indices. *)
antiquarkMatrices = simplify[v0.Transpose[#].adjoint[v0]] & /@ sigma;
quarkCoefficients = simplify[LinearSolve[diracMap, Flatten[#]]] & /@ quarkMatrices;
antiquarkCoefficients = simplify[LinearSolve[diracMap, Flatten[#]]] & /@ antiquarkMatrices;
gate["quark projector reconstruction", zeroQ[simplify[MapThread[
  #1 - Total[MapThread[Times, {#2, diracBasis}]] &, {quarkMatrices, quarkCoefficients}]]]];
gate["antiquark projector reconstruction", zeroQ[simplify[MapThread[
  #1 - Total[MapThread[Times, {#2, diracBasis}]] &, {antiquarkMatrices, antiquarkCoefficients}]]]];
fcBasis = {GS[spinMomentum], GA[5].GS[spinMomentum],
  GA[5].GS[spinX].GS[spinMomentum], GA[5].GS[spinY].GS[spinMomentum]};
quarkNumerators = Total[MapThread[Times, {#, fcBasis}]] & /@ quarkCoefficients;
antiquarkNumerators = Total[MapThread[Times, {#, fcBasis}]] & /@ antiquarkCoefficients;

(* Gluon states are helicity eigenvectors, with linear Stokes components. *)
gluonStates = Transpose[{(sx + I sy)/Sqrt[spinDimension], (sx - I sy)/Sqrt[spinDimension]}];
gate["gluon physical normalization", ConjugateTranspose[gluonStates].metric.gluonStates === -First[sigma]];
gate["gluon transverse states", zeroQ[momentumMassless.metric.gluonStates]];
gluonMatrices = gluonStates.#.ConjugateTranspose[gluonStates] & /@ sigma;
lightReference = {1, 0, 0, -1};
physicalGluonSum = -metric + (Outer[Times, momentumMassless, lightReference] +
  Outer[Times, lightReference, momentumMassless])/(momentumMassless.metric.lightReference);
gate["gluon completeness", zeroQ[Simplify[First[gluonMatrices] - physicalGluonSum]]];

(* Complete virtual-photon Hermitian matrix basis in the L,X,Y frame. *)
photonVectors = {{1, 0, 0, 0}, sx, sy};
photonDimension = Length[photonVectors];
units = IdentityMatrix[photonDimension];
photonPairs = Subsets[Range[photonDimension], {2}];
photonBasis = Join[Outer[Times, #, #] & /@ units,
  (Outer[Times, units[[#[[1]]]], units[[#[[2]]]]] +
    Outer[Times, units[[#[[2]]]], units[[#[[1]]]]] &) /@ photonPairs,
  (-I Outer[Times, units[[#[[1]]]], units[[#[[2]]]]] +
    I Outer[Times, units[[#[[2]]]], units[[#[[1]]]]] &) /@ photonPairs];
photonGram = Table[Tr[photonBasis[[i]].photonBasis[[j]]],
  {i, Length[photonBasis]}, {j, Length[photonBasis]}];
photonDual = Total[MapThread[Times, {#, photonBasis}]] & /@ Inverse[photonGram];
genericPhoton = Array[photonElement, {photonDimension, photonDimension}];
gate["photon matrix reconstruction", zeroQ[Expand[genericPhoton -
  Total[MapThread[Times, {Tr[#.genericPhoton] & /@ photonDual, photonBasis}]]]]];
photonLabels = {"LL", "XX", "YY", "ReLX", "ReLY", "ReXY", "ImLX", "ImLY", "ImXY"};

(* Exercise the installed native interface with unsimplified completeness factors. *)
probe = FermionSpinSum[(SpinorUBarD[k1, 0].GAD[mu].SpinorUD[p, 0])
  (SpinorUBarD[p, 0].GAD[nu].SpinorUD[k1, 0]), Head -> preservedSpinSum,
  DotSimplify -> False, FCTraceFactor -> False];
gate["native spin-sum replacement interface", FreeQ[probe, _Spinor] &&
  Length[Cases[probe, preservedSpinSum[_], Infinity]] === spinDimension];
result = <|"Schema" -> "polarized-sidis-spin-basis-v1", "Scope" -> config["scope"],
  "SpinLabels" -> spinLabels, "PauliMatrices" -> sigma, "PauliGram" -> pauliGram,
  "IncomingDensityNormalization" -> spinDimension, "OutgoingAnalyzerNormalization" -> 1,
  "DensityMatrix" -> rho, "DensityEigenvalues" -> rhoEigenvalues,
  "QuarkDiracCoefficients" -> quarkCoefficients, "AntiquarkDiracCoefficients" -> antiquarkCoefficients,
  "QuarkSpinNumerators" -> quarkNumerators, "AntiquarkSpinNumerators" -> antiquarkNumerators,
  "DiracBasis" -> fcBasis, "GluonHelicityVectorsCanonical" -> gluonStates,
  "GluonStokesTensorsCanonical" -> gluonMatrices,
  "PhotonLabels" -> photonLabels, "PhotonBasis" -> photonBasis, "PhotonDual" -> photonDual,
  "PhotonMetric" -> photonVectors.metric.Transpose[photonVectors],
  "SpinResponseIndexOrder" -> {"outgoing", "incoming"},
  "GluonLabels" -> <|"X" -> "linear Stokes 1", "Y" -> "linear Stokes 2", "H" -> "helicity"|>,
  "AmplitudeInventory" -> inventory, "Checks" -> checks,
  "Gamma5Scheme" -> FCGetDiracGammaScheme[], "LeviCivitaSign" -> $LeviCivitaSign,
  "FeynCalcVersion" -> $FeynCalcVersion, "WolframVersion" -> $Version,
  "SourceHash" -> FileHash[$InputFileName, "SHA256"],
  "InputManifestHash" -> FileHash[FileNameJoin[{root, "common", "s01_inputs.json"}], "SHA256"],
  "FiniteFHatsComputed" -> False,
  "Boundary" -> "Canonical physical spin bases only; contractions, evanescent terms, subtraction and finite scheme conversion remain separate gates."|>;
atomicPut[result, FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}]];
Export[FileNameJoin[{root, "common", "s02_result", "s02_checks.json"}],
  <|"checks" -> checks, "spin_components_per_parton" -> Length[sigma],
    "photon_components" -> Length[photonBasis], "inventory" ->
      Map[Function[entry, Map[Function[sector, sector["DiagramCount"]], entry["Sectors"]]], inventory],
    "finite_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s02_define_spin_basis"];
Quit[0];

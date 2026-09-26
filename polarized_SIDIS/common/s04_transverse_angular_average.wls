(* Angular averages for a physical normal direction and BMHV evanescent space. *)
$HistoryLength = 0;
root = Directory[];
source = FileNameJoin[{root, "common", "s04_transverse_angular_average.wls"}];
checks = <||>;
ClearAll[gate, zeroQ, dot, evenMoment, moment];
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name],
  Print["FAIL: ", name]; Quit[1]];
zeroQ[value_] := And @@ (TrueQ[# === 0] & /@ Flatten[{value}]);
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
gate["isolated runtime", StringStartsQ[$UserBaseDirectory, root <> "/"]];
basisFile = FileNameJoin[{root, "common", "s02_result", "s02_result.wl"}];
(* No FeynCalc algebra is executed here. Load its definitions so serialized
   spin-basis symbols retain their producer contexts. *)
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
basis = Get[basisFile];
gate["accepted spin basis", basis["Schema"] === "polarized-sidis-spin-basis-v1" && And @@ Values[basis["Checks"]]];

(* Derive scalar products from the reference measurement and cut definitions. *)
momenta = {p, q, k1, k2};
fullGram = {{0, pq, pk1, pk2}, {pq, -Q2, qk1, qk2},
  {pk1, qk1, 0, k1k2}, {pk2, qk2, k1k2, 0}};
dot[v_, w_] := Expand[(Coefficient[v, #] & /@ momenta).fullGram.(Coefficient[w, #] & /@ momenta)];
recoil = p + q - k1 - k2;
equations = {dot[p + q, p + q] == s, dot[q - k1, q - k1] == t,
  dot[p + q - k1, p + q - k1] == s23, dot[recoil, recoil] == 0,
  dot[k1 + k2, k1 + k2] == a12, dot[p - recoil, p - recoil] == u3};
solutions = Solve[equations, {pq, pk1, pk2, qk1, qk2, k1k2}];
gate["unique real invariant map", Length[solutions] === 1];
invariantMap = First[solutions];
gate["invariant reconstruction", zeroQ[Factor[(equations /. Equal -> Subtract) /. invariantMap]]];
externalMomenta = Take[momenta, Length[momenta] - 1];
externalGram = fullGram[[Range[Length[externalMomenta]], Range[Length[externalMomenta]]]] /. invariantMap;
externalRank = MatrixRank[externalGram];
physicalDimension = Length[basis["GluonHelicityVectorsCanonical"]];
normalDimension = physicalDimension - externalRank;
hatDimension = dimension - physicalDimension;
orthogonalDimension = dimension - externalRank;
gate["one physical normal direction", normalDimension === 1];
scalarProductsWithCut = Last[fullGram][[Range[externalRank]]] /. invariantMap;
parallelCoefficients = LinearSolve[externalGram, scalarProductsWithCut];
gate["parallel projection reconstruction", zeroQ[Factor[externalGram.parallelCoefficients - scalarProductsWithCut]]];
normalMinkowskiSquared = Factor[(Last[Last[fullGram]] /. invariantMap) - scalarProductsWithCut.parallelCoefficients];
euclideanRadiusSquared = -normalMinkowskiSquared;
generalProducts = Array[longitudinalProduct, externalRank];
generalParallel = LinearSolve[externalGram, generalProducts];
generalRadiusSolution = First[Solve[normalMomentumSquare == generalProducts.generalParallel - radiusSquared,
  radiusSquared]];
generalEuclideanRadiusSquared = Factor[radiusSquared /. generalRadiusSolution];
gate["general radius specializes to the cut radius", Factor[
  (generalEuclideanRadiusSquared /. Join[{normalMomentumSquare -> 0},
    Thread[generalProducts -> scalarProductsWithCut]]) - euclideanRadiusSquared] === 0];

(* The sphere fraction u is the positive squared physical-normal component
   divided by the full positive transverse radius. The remaining fraction
   is the evanescent Euclidean norm; its Minkowski square has the opposite sign. *)
domain = dimension > physicalDimension && radiusSquared > 0 &&
  Element[{aPower, bPower}, Integers] && aPower >= 0 && bPower >= 0;
weight = uFraction^(normalDimension/2 - 1) (1 - uFraction)^(hatDimension/2 - 1);
normalizationIntegral = Integrate[weight, {uFraction, 0, 1}, Assumptions -> domain];
weightedIntegral = Integrate[uFraction^aPower (1 - uFraction)^bPower weight,
  {uFraction, 0, 1}, Assumptions -> domain];
unsignedSphereMoment = FullSimplify[weightedIntegral/normalizationIntegral, Assumptions -> domain];
signFromMinkowskiSquare = FullSimplify[(-radiusSquared)^bPower/radiusSquared^bPower,
  Assumptions -> domain];
genericEvenMoment = FullSimplify[signFromMinkowskiSquare radiusSquared^(aPower + bPower)
  unsignedSphereMoment, Assumptions -> domain];
gate["sphere integral evaluated", FreeQ[genericEvenMoment, _Integrate | _ConditionalExpression | _Real]];
Print["SPHERE_MOMENTS_DERIVED"];

(* Independent Gaussian factorization fixes the same normalized moments. *)
normalGaussian = Integrate[z^(2 aPower) Exp[-z^2], {z, -Infinity, Infinity}, Assumptions -> domain]/
  Integrate[Exp[-z^2], {z, -Infinity, Infinity}];
hatGaussian = Integrate[r^(hatDimension - 1 + 2 bPower) Exp[-r^2], {r, 0, Infinity}, Assumptions -> domain]/
  Integrate[r^(hatDimension - 1) Exp[-r^2], {r, 0, Infinity}, Assumptions -> domain];
radialGaussian = Integrate[r^(orthogonalDimension - 1 + 2 (aPower + bPower)) Exp[-r^2],
  {r, 0, Infinity}, Assumptions -> domain]/
  Integrate[r^(orthogonalDimension - 1) Exp[-r^2], {r, 0, Infinity}, Assumptions -> domain];
gaussianRatio = FullSimplify[normalGaussian hatGaussian/radialGaussian, Assumptions -> domain];
gate["sphere Gaussian agreement", FullSimplify[FunctionExpand[unsignedSphereMoment - gaussianRatio],
  Assumptions -> domain] === 0];
reflectedOddIntegrand = FullSimplify[(z^(2 aPower + 1) + (-z)^(2 aPower + 1)) Exp[-z^2],
  Assumptions -> domain && z > 0];
oddGaussian = Integrate[reflectedOddIntegrand, {z, 0, Infinity}, Assumptions -> domain];
gate["odd normal moments vanish", oddGaussian === 0];

evenMoment[a_Integer, b_Integer] /; a >= 0 && b >= 0 := Factor[FunctionExpand[
  genericEvenMoment /. {aPower -> a, bPower -> b}]];
moment[n_Integer, b_Integer] /; n >= 0 && b >= 0 := If[OddQ[n], 0, evenMoment[n/2, b]];
gate["unit angular normalization", moment[0, 0] === 1];
verificationDepth = 6;
radiusChecks = Table[Factor[Total[Table[Binomial[n, j] (-1)^j moment[2 (n - j), j], {j, 0, n}]] -
  radiusSquared^n], {n, 0, verificationDepth}];
gate["transverse radius reconstruction", zeroQ[radiusChecks]];
momentTable = Association@Flatten[Table[{n, b} -> moment[n, b],
  {n, 0, 2 verificationDepth}, {b, 0, verificationDepth - Ceiling[n/2]}], 1];
gate["continued integer moments are rational", FreeQ[Values[momentTable], _Gamma | _Beta |
  _Integrate | _ConditionalExpression | _Real | Indeterminate | ComplexInfinity]];
result = <|"Schema" -> "polarized-sidis-transverse-average-v1", "ExternalMomenta" -> externalMomenta,
  "ExternalGram" -> externalGram, "InvariantMap" -> invariantMap,
  "ParallelCoefficients" -> parallelCoefficients, "CutEuclideanRadiusSquared" -> euclideanRadiusSquared,
  "GeneralEuclideanRadiusSquared" -> generalEuclideanRadiusSquared,
  "PhysicalDimension" -> physicalDimension, "PhysicalNormalDimension" -> normalDimension,
  "EvanescentDimension" -> hatDimension, "OrthogonalDimension" -> orthogonalDimension,
  "SphereWeight" -> weight, "SphereNormalization" -> normalizationIntegral,
  "GenericEvenMoment" -> genericEvenMoment, "GaussianMomentRatio" -> gaussianRatio,
  "MomentIndexMeaning" -> {"power of k2 dot physical normal", "power of Minkowski evanescent k2 squared"},
  "MomentTable" -> momentTable, "VerificationDepth" -> verificationDepth,
  "Continuation" -> "Derive for dimension > 4, then continue the evaluated meromorphic expressions to dimension = 4 - 2 eps.",
  "ConsumerRequirements" -> {"Denominators and measurement must be independent of the residual angular variables.",
    "The complete numerator must reconstruct before its moments are replaced.",
    "Retain positive-energy cuts and the original phase-space and loop measures.",
    "The physical p,q,k1 Gram matrix must have rank three (nonzero transverse momentum)."},
  "Checks" -> checks, "SourceHash" -> FileHash[source, "SHA256"],
  "InputHash" -> FileHash[basisFile, "SHA256"], "FiniteFHatsComputed" -> False|>;
output = FileNameJoin[{root, "common", "s04_result"}];
If[!DirectoryQ[output], CreateDirectory[output, CreateIntermediateDirectories -> True]];
Put[result, FileNameJoin[{output, "s04_result.wl.tmp"}]];
RenameFile[FileNameJoin[{output, "s04_result.wl.tmp"}], FileNameJoin[{output, "s04_result.wl"}], OverwriteTarget -> True];
Export[FileNameJoin[{output, "s04_checks.json"}], <|"checks" -> checks,
  "moment_count" -> Length[momentTable], "verification_depth" -> verificationDepth,
  "finite_fhats_computed" -> False, "job_id" -> Environment["JOB_ID"]|>, "RawJSON"];
Print["PASS: s04_transverse_angular_average"];
Quit[0];

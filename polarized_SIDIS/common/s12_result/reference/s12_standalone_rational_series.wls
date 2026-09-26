(* Construct the production annihilation real-emission Laurent ledger from
   FORM/Kira coefficients and the locked SubTropica master candidates.

   The validation-only FeynCalc ledger is used only through a preconstruction
   SHA-256 equality gate.  It never supplies a production coefficient. *)

ClearAll[fail, pass, sha256, rationalSeries, canonicalCoefficient,
  canonicalMasterPolynomial, laurentTuple];
fail[msg_, detail_: Null] := (
  Print["FAIL: ", msg];
  If[detail =!= Null, Print["DETAIL=", InputForm[detail]]];
  Quit[1]
);
pass[msg_] := Print["PASS: ", msg];
sha256[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];

rationalSeries[rat[numerator_, denominator_], maximumPower_Integer] :=
 Module[{nMinimum, dMinimum, leadingPower, count, d0, quotient = {},
     order, numeratorCoefficient, correction},
  If[numerator === 0, Return[0]];
  nMinimum = Exponent[numerator, ep, Min];
  dMinimum = Exponent[denominator, ep, Min];
  leadingPower = nMinimum - dMinimum;
  count = maximumPower - leadingPower;
  If[count < 0, Return[0]];
  d0 = Coefficient[denominator, ep, dMinimum];
  Do[
    numeratorCoefficient = Coefficient[numerator, ep, nMinimum + order];
    correction = Sum[
      Coefficient[denominator, ep, dMinimum + index] *
        quotient[[order - index + 1]], {index, 1, order}];
    AppendTo[quotient, (numeratorCoefficient - correction)/d0],
    {order, 0, count}];
  Sum[quotient[[order + 1]] ep^(leadingPower + order),
    {order, 0, count}]
];
canonicalCoefficient[expression_] := Factor[Together[expression]];
canonicalMasterPolynomial[expression_] := Module[{rules},
  If[! PolynomialQ[expression, masterVariables],
    fail["Laurent coefficient is not polynomial in the master basis"]];
  rules = CoefficientRules[expression, masterVariables];
  Total @ Map[
    Function[rule, canonicalCoefficient[Last[rule]] *
      Times @@ MapThread[Power, {masterVariables, First[rule]}]], rules]
];
laurentTuple[expression_, label_] := Module[{series, tuple, elapsed},
  elapsed = First @ AbsoluteTiming[
    series = Normal @ Series[expression, {ep, 0, 1}];
    tuple = Association @ Table[
      order -> canonicalMasterPolynomial[Coefficient[series, ep, order]],
      {order, {-1, 0, 1}}]
  ];
  Print[label, "_LAURENT_SECONDS=", N[elapsed, 6]];
  tuple
];

scriptDirectory = DirectoryName[$InputFileName];
root = ExpandFileName @ FileNameJoin[{scriptDirectory, ".."}];
reducedPath = FileNameJoin[{root, "build", "real_kira",
  "real_kira_reduced.m"}];
oracleReducedPath = FileNameJoin[{root, "build", "real_kira_oracle",
  "real_kira_reduced.m"}];
familyManifestPath = FileNameJoin[{root, "build", "real_families",
  "manifest.json"}];
formPolarizedPath = FileNameJoin[{root, "build", "real",
  "math_RealP.m"}];
subtropicaRoot = FileNameJoin[{root, "build", "subtropica",
  "qqbar_annihilation_real_shifted_masters_v1"}];
subtropicaManifestPath = FileNameJoin[{subtropicaRoot, "manifest.json"}];
candidateDirectory = FileNameJoin[{subtropicaRoot, "candidates"}];
configuredOutput = Environment["QQBAR_REAL_LAURENT_OUTPUT_ROOT"];
outputDirectory = If[StringQ[configuredOutput] &&
    StringLength[configuredOutput] > 0, ExpandFileName[configuredOutput],
  FileNameJoin[{root, "build", "real_nlo"}]];

requiredInputs = {reducedPath, oracleReducedPath, familyManifestPath,
  formPolarizedPath, subtropicaManifestPath};
If[! And @@ (FileExistsQ /@ requiredInputs),
  fail["a Laurent construction input is missing"]];
If[sha256[reducedPath] =!= sha256[oracleReducedPath],
  fail["production and validation-only Kira ledgers differ"]];
familyManifest = Import[familyManifestPath, "RawJSON"];
If[Lookup[familyManifest, "polarized_source_role", ""] =!=
      "production FORM BMHV" ||
    Lookup[Lookup[familyManifest, "source_sha256", <||>],
      "polarized", ""] =!= sha256[formPolarizedPath],
  fail["production Kira ledger is not bound to finalized FORM BMHV"]];
pass["production FORM source and validation-only Kira equality gates pass"];

loadSeconds = First @ AbsoluteTiming[reducedRaw = Get[reducedPath]];
If[! ListQ[reducedRaw] || Length[reducedRaw] =!= 5,
  fail["unexpected FORM/Kira ledger structure"]];
If[! FreeQ[reducedRaw /. _rat -> 0, ep],
  fail["epsilon dependence escaped the FORM rat coefficients"]];
Print["KIRA_LEDGER_LOAD_SECONDS=", N[loadSeconds, 6]];

ratExpansionSeconds = First @ AbsoluteTiming[
  reducedU = reducedRaw[[1]] /.
    coefficient_rat :> rationalSeries[coefficient, 2];
  reducedPOrdinary = reducedRaw[[2]] /.
    coefficient_rat :> rationalSeries[coefficient, 2];
  reducedPHatNormalized = reducedRaw[[5]] /.
    coefficient_rat :> rationalSeries[coefficient, 1]
];
If[! FreeQ[{reducedU, reducedPOrdinary, reducedPHatNormalized}, rat],
  fail["an unexpanded FORM rational function survived"]];
Print["FORM_RAT_EXPANSION_SECONDS=", N[ratExpansionSeconds, 6]];

subtropicaManifest = Quiet @ Check[
  Import[subtropicaManifestPath, "RawJSON"], $Failed];
If[! AssociationQ[subtropicaManifest] ||
    Lookup[subtropicaManifest, "passed", False] =!= True ||
    Lookup[subtropicaManifest, "registry_id", ""] =!=
      "qqbar_annihilation_real_shifted_masters_v1" ||
    Lookup[subtropicaManifest, "backend", ""] =!= "SubTropica" ||
    Lookup[subtropicaManifest, "backend_version", ""] =!= "1.2.10",
  fail["unexpected SubTropica manifest identity"]];

loadCandidate[id_] := Module[{path, held, expectedHash},
  path = FileNameJoin[{candidateDirectory, id <> ".normalized.wl"}];
  expectedHash = subtropicaManifest["normalized_candidate_sha256"][id];
  If[! FileExistsQ[path] || sha256[path] =!= expectedHash,
    fail["SubTropica candidate hash mismatch", id]];
  held = Get[path];
  If[Head[held] =!= HoldComplete || ! FreeQ[held, _Total],
    fail["SubTropica candidate is not a frozen scalar", id]];
  ReleaseHold[held] /. eps -> ep /. Global`z -> z
];
uD = loadCandidate["universal_angular_d0"];
uD2 = loadCandidate["universal_angular_d2"];
uDOracle = -2/(ep z) + (4 + 2 Log[z])/z +
  ep/z (-4 Log[z] - Log[z]^2 - 2 PolyLog[2, 1 - z]);
uD2Oracle = -6 Log[z]/(1 - z);
If[canonicalCoefficient[uD - uDOracle] =!= 0 ||
    canonicalCoefficient[uD2 - uD2Oracle] =!= 0,
  fail["SubTropica angular-master normalization changed"]];
pass["frozen D and D+2 angular masters have the required Laurent depth"];

s23 = s + t + u;
axisData = <|
  "ab" -> {{-(s + t), -(s + u)}, s s23/((s + t) (s + u))},
  "aA" -> {{-(s + t), -(t + u)},
    1 - (-t) s23/((s + t) (-t - u))},
  "ac" -> {{-(s + t), t + u},
    (-t) s23/((s + t) (-t - u))},
  "bA" -> {{-(s + u), -(t + u)},
    1 - (-u) s23/((s + u) (-t - u))},
  "bc" -> {{-(s + u), t + u},
    (-u) s23/((s + u) (-t - u))}
|>;
topSign = <|"ab" -> 1, "aA" -> 1, "ac" -> -1,
  "bA" -> 1, "bc" -> -1|>;
names = {"ab", "aA", "ac", "bA", "bc"};
logSymbols = AssociationThread[names, {lab, laA, lac, lbA, lbc}];
dilogSymbols = AssociationThread[names, {qab, qaA, qac, qbA, qbc}];
masterVariables = Join[Values[logSymbols], Values[dilogSymbols]];
topCandidate[name_, universal_] := Module[
  {scales = axisData[name][[1]], argument = axisData[name][[2]]},
  topSign[name] (universal /. z -> argument)/
    (scales[[1]] scales[[2]])
];
uDPlaceholder[name_] := -2/(ep z) +
  (4 + 2 logSymbols[name])/z +
  ep/z (-4 logSymbols[name] - logSymbols[name]^2 -
    2 dilogSymbols[name]);
uD2Placeholder[name_] := -6 logSymbols[name]/(1 - z);
dRules = {
  abD[1, 1, 0, 0] -> 1,
  abD[1, 1, 1, 1] -> topCandidate["ab", uDPlaceholder["ab"]],
  aAD[1, 1, 1, 1] -> topCandidate["aA", uDPlaceholder["aA"]],
  acD[1, 1, 1, 1] -> topCandidate["ac", uDPlaceholder["ac"]],
  bAD[1, 1, 1, 1] -> topCandidate["bA", uDPlaceholder["bA"]],
  bcD[1, 1, 1, 1] -> topCandidate["bc", uDPlaceholder["bc"]]
};
d2Rules = {
  abD2[1, 1, 0, 0] -> 1,
  abD2[1, 1, 1, 1] -> topCandidate["ab", uD2Placeholder["ab"]],
  aAD2[1, 1, 1, 1] -> topCandidate["aA", uD2Placeholder["aA"]],
  acD2[1, 1, 1, 1] -> topCandidate["ac", uD2Placeholder["ac"]],
  bAD2[1, 1, 1, 1] -> topCandidate["bA", uD2Placeholder["bA"]],
  bcD2[1, 1, 1, 1] -> topCandidate["bc", uD2Placeholder["bc"]]
};
expectedOrdinaryAtoms = First /@ dRules;
expectedShiftedAtoms = First /@ d2Rules;
ordinaryAtoms = DeleteDuplicates @ Cases[reducedU + reducedPOrdinary,
  _abD | _aAD | _acD | _bAD | _bcD, Infinity];
shiftedAtoms = DeleteDuplicates @ Cases[reducedPHatNormalized,
  _abD2 | _aAD2 | _acD2 | _bAD2 | _bcD2, Infinity];
If[Sort[ordinaryAtoms] =!= Sort[expectedOrdinaryAtoms] ||
    Sort[shiftedAtoms] =!= Sort[expectedShiftedAtoms],
  fail["unexpected master support in the Laurent input",
    {ordinaryAtoms, shiftedAtoms}]];

regulatorValuation[expression_] := Module[{cancelled},
  cancelled = Cancel[Together[expression]];
  Exponent[Numerator[cancelled], ep, Min] -
    Exponent[Denominator[cancelled], ep, Min]
];
ordinaryTopValuations = Association @ Map[
  Function[atom, ToString[InputForm[atom]] -> Min[
    regulatorValuation[Coefficient[reducedU, atom]],
    regulatorValuation[Coefficient[reducedPOrdinary, atom]]]],
  Rest[expectedOrdinaryAtoms]];
shiftedTopValuations = Association @ Map[
  Function[atom, ToString[InputForm[atom]] ->
    regulatorValuation[Coefficient[reducedPHatNormalized, atom]]],
  Rest[expectedShiftedAtoms]];
If[Min[Values[ordinaryTopValuations]] < 0 ||
    Min[Values[shiftedTopValuations]] < 1,
  fail["master Laurent depth is insufficient for a Kira coefficient",
    {ordinaryTopValuations, shiftedTopValuations}]];
pass["actual Kira coefficient valuations certify the master truncation"];

kinematicRules = {t -> -s (1 - v), u -> -s v w};
constructionSeconds = First @ AbsoluteTiming[
  angularU = (reducedU /. dRules) /. kinematicRules;
  angularPOrdinary = (reducedPOrdinary /. dRules) /. kinematicRules;
  angularPHat = (reducedPHatNormalized /. d2Rules) /. kinematicRules
];
Print["MASTER_INSERTION_SECONDS=", N[constructionSeconds, 6]];
If[! FreeQ[{angularU, angularPOrdinary, angularPHat},
    _abD | _aAD | _acD | _bAD | _bcD |
    _abD2 | _aAD2 | _acD2 | _bAD2 | _bcD2 | rat],
  fail["a Kira master survived insertion"]];

unpolarizedPlaceholder = laurentTuple[angularU, "UNPOLARIZED"];
polarizedOrdinaryPlaceholder =
  laurentTuple[angularPOrdinary, "POLARIZED_ORDINARY"];
polarizedHatPlaceholder =
  laurentTuple[angularPHat, "POLARIZED_HAT_TARASOV"];
polarizedPlaceholder = Association @ Table[
  order -> canonicalMasterPolynomial[
    polarizedOrdinaryPlaceholder[order] +
      polarizedHatPlaceholder[order]], {order, {-1, 0, 1}}];

masterArguments = Association @ Map[
  Function[name, name -> Together[axisData[name][[2]] /. kinematicRules]],
  names];
specialRules = Flatten @ Map[
  Function[name, {
    logSymbols[name] -> FunctionExpand[Log[masterArguments[name]]],
    dilogSymbols[name] ->
      FunctionExpand[PolyLog[2, 1 - masterArguments[name]]]
  }], names];
materialize[tuple_] := Map[(# /. specialRules) &, tuple];
unpolarized = materialize[unpolarizedPlaceholder];
polarizedOrdinary = materialize[polarizedOrdinaryPlaceholder];
polarizedHat = materialize[polarizedHatPlaceholder];
polarized = materialize[polarizedPlaceholder];
polarizedSectors = <|"ordinary" -> polarizedOrdinary,
  "hat_tarasov" -> polarizedHat|>;

If[polarizedHat[-1] =!= 0 || polarizedHat[0] === 0,
  fail["unexpected BMHV hat/Tarasov Laurent structure"]];
If[! FreeQ[{unpolarized, polarized, polarizedSectors},
    ep | Gamma | Hypergeometric2F1 | EulerGamma |
    _abD | _aAD | _acD | _bAD | _bcD |
    _abD2 | _aAD2 | _acD2 | _bAD2 | _bcD2],
  fail["regulator or unexpanded master survived the Laurent tuples"]];

If[! DirectoryQ[outputDirectory],
  CreateDirectory[outputDirectory, CreateIntermediateDirectories -> True]];
poleFinite = <|
  "unpolarized" -> <|-1 -> unpolarized[-1], 0 -> unpolarized[0]|>,
  "polarized_total" -> <|-1 -> polarized[-1], 0 -> polarized[0]|>,
  "polarized_ordinary" ->
    <|-1 -> polarizedOrdinary[-1], 0 -> polarizedOrdinary[0]|>,
  "polarized_hat_tarasov" ->
    <|-1 -> polarizedHat[-1], 0 -> polarizedHat[0]|>
|>;
standardRows = Flatten @ {
  Table[<|"component" -> "unpolarized", "sector" -> "ordinary",
    "order" -> order, "coefficient" -> unpolarized[order]|>,
    {order, {-1, 0, 1}}],
  Table[<|"component" -> "polarized", "sector" -> "ordinary",
    "order" -> order, "coefficient" -> polarizedOrdinary[order]|>,
    {order, {-1, 0, 1}}],
  Table[<|"component" -> "polarized", "sector" -> "hat_tarasov",
    "order" -> order, "coefficient" -> polarizedHat[order]|>,
    {order, {-1, 0, 1}}],
  Table[<|"component" -> "polarized", "sector" -> "total",
    "order" -> order, "coefficient" -> polarized[order]|>,
    {order, {-1, 0, 1}}]
};
outputPaths = <|
  "unpolarized" -> FileNameJoin[{outputDirectory,
    "unpolarized_real_angular_laurent.wl"}],
  "polarized" -> FileNameJoin[{outputDirectory,
    "polarized_real_angular_laurent.wl"}],
  "polarized_sectors" -> FileNameJoin[{outputDirectory,
    "polarized_real_angular_sector_laurent.wl"}],
  "pole_finite" -> FileNameJoin[{outputDirectory,
    "real_angular_pole_finite.wl"}],
  "standard_rows" -> FileNameJoin[{outputDirectory,
    "real_angular_standard_basis_rows.wl"}]
|>;
Export[outputPaths["unpolarized"],
  ToString[InputForm[unpolarized]], "Text"];
Export[outputPaths["polarized"],
  ToString[InputForm[polarized]], "Text"];
Export[outputPaths["polarized_sectors"],
  ToString[InputForm[polarizedSectors]], "Text"];
Export[outputPaths["pole_finite"],
  ToString[InputForm[poleFinite]], "Text"];
Export[outputPaths["standard_rows"],
  ToString[InputForm[standardRows]], "Text"];

manifest = <|
  "schema_version" -> 1,
  "contract" -> "qqbar-annihilation-real-angular-laurent-v1",
  "source_role" -> "production FORM BMHV",
  "kinematics" -> <|
    "invariant_map" -> "t=-s(1-v), u=-s v w",
    "physical_region" -> "s>0, 0<v<1, 0<w<1"|>,
  "coupling_symbol" -> "gs",
  "color_symbol" -> "Nc",
  "orders" -> {-1, 0, 1},
  "sectors" -> {"unpolarized", "polarized_ordinary",
    "polarized_hat_tarasov", "polarized_total"},
  "production_kira_sha256" -> sha256[reducedPath],
  "validation_oracle_kira_sha256" -> sha256[oracleReducedPath],
  "production_equals_validation_oracle" -> True,
  "form_polarized_sha256" -> sha256[formPolarizedPath],
  "subtropica_manifest_sha256" -> sha256[subtropicaManifestPath],
  "ordinary_top_valuations" -> ordinaryTopValuations,
  "shifted_top_valuations" -> shiftedTopValuations,
  "hat_shift" -> "ep(s+t+u)/(2(3-2ep))",
  "endpoint_or_factorization_included" -> False,
  "artifact_sha256" -> Map[sha256, outputPaths],
  "passed" -> True
|>;
Export[FileNameJoin[{outputDirectory, "manifest.json"}], manifest,
  "RawJSON"];
Export[FileNameJoin[{outputDirectory, "real_laurent_receipt.wl"}],
  ToString[InputForm[<|
    "manifest" -> manifest,
    "families" -> names,
    "master_arguments" -> masterArguments,
    "polarized_total_is_ordinary_plus_hat" -> True,
    "validation_scope" ->
      "same-target live FeynCalc is validation-only; production coefficients originate in FORM"
  |>]], "Text"];
pass["exported production real angular Laurent ledger through ep^1"];
Quit[0];

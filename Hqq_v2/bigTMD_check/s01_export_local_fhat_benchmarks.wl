(* ::Package:: *)

(* Hqq_v2 BigTMD check S01: exact local distribution-coefficient export. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
$LoadAddOns = {"FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"]];
$FCAdvice = False;

ClearAll[
  fatal, require, fileSHA256, expressionSHA256, exactZeroQ,
  allBooleanLeavesTrueQ, deriveBenchmark, localRules, numericalValue,
  reduceToolSpecialFunctions, extractBoundedPlusCoefficients,
  jsonAssociation, atomicRawJSONExport
];

fatal[message_String, detail_: Null] := (
  Print["HQQV2_BIGTMD_S01_FATAL: " <> message];
  If[detail =!= Null, Print["HQQV2_BIGTMD_S01_DETAIL=", InputForm[detail]]];
  Quit[1]
);

require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fatal[message, detail]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];
expressionSHA256[expression_] :=
  IntegerString[Hash[expression, "SHA256"], 16, 64];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
allBooleanLeavesTrueQ[expression_] := Module[{leaves},
  leaves = Cases[expression, True | False, {0, Infinity}];
  leaves =!= {} && FreeQ[expression, False] && AllTrue[leaves, TrueQ]
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
channelDirectory = DirectoryName[checkDirectory];
scriptsDirectory = DirectoryName[channelDirectory];
programPath = ExpandFileName[$InputFileName];
s00ProgramPath = FileNameJoin[
  {checkDirectory, "s00_prepare_local_fhats.wl"}];
s00ResultPath = FileNameJoin[
  {checkDirectory, "s00_prepared_local_fhats.wl"}];
s08ProgramPath = FileNameJoin[{channelDirectory,
  "s08_extract_hqq_fhats.wl"}];
s08ResultPath = FileNameJoin[{channelDirectory, "s08_result.wl"}];
paperPath = FileNameJoin[{scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];
hyperInticaPath = FileNameJoin[{channelDirectory, "vendor",
  "SubTropicaHyperIntica", "HyperIntica.wl"}];
referenceDirectory = FileNameJoin[{scriptsDirectory, "Hqqprime",
  "bigTMD_check", "BigTMD_reference"}];
driverPath = FileNameJoin[{referenceDirectory, "sidis.py"}];
outputPath = FileNameJoin[{checkDirectory, "local_fhat_benchmarks.json"}];

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
stageVersion = "HqqV2BigTMDCheckS01-v1";
expectedS00ProgramSHA256 =
  "dfdfcc49bb39a94b2138291a9687a803ef1774b09cd7df45d3720e40da0cee20";
expectedS00ResultSHA256 =
  "a61e442a9b7ea27576bfe0773a0c295ac1af87046decace96123feb4f4a2627a";
expectedS08ProgramSHA256 =
  "f426373c24143950cb8cdb09a6410e7ec76e0d4f960293f6380021cf54c211b7";
expectedS08ResultSHA256 =
  "0b69a0db7740127ab16c53d181317b7defbd17af846e55582213ca28d1d35741";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedHyperInticaSHA256 =
  "252acac91a7cb87c7334f2c7227a4c7aeea7bfc2c3b53c58f9fb28a4a6b284d5";
expectedDriverSHA256 =
  "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d";
expectedHatSHA256 = <|
  "F1Hat" ->
    "24010c0ba80c1da601d39fcad6684a986024773cd84beafcbc09e956d6da4823",
  "F2Hat" ->
    "54aa977540c56796b7c5b03aead322022788455caa110b9fe285373fec139b36"|>;

referenceModulePaths = <|
  "Pg2A" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn2A.py"}],
  "PPP2A" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn2A.py"}],
  "Pg2B" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn2B.py"}],
  "PPP2B" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn2B.py"}],
  "Pg2C" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn2C.py"}],
  "PPP2C" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn2C.py"}]|>;
expectedReferenceSHA256 = <|
  "Pg2A" -> "9d24bb4b02ef7b69b125059b7b8fe4ba993c4fb1d3c3972dd826f221d3e64c23",
  "PPP2A" -> "f1a04d5fb041b174e61f82e5290dc81a01c1583c741a754de8a76d17e0d75e72",
  "Pg2B" -> "48d5e92a0b33abee65d000327d4bc1c6edb30dab97b396d237541e53291f07b3",
  "PPP2B" -> "59746b925caa9e016f7548836c443aa158a5521d32a9df4d9e22b3f8d5ffe586",
  "Pg2C" -> "c5da8f58bad64c6738b88f7d8acb0872bdbc5153444a1c7fc489af53872fd3c2",
  "PPP2C" -> "38cf2594a02e35ee51d7d5c83e94167d24cf65fbc864aac6df8fa4742a71050e"|>;

hatLabels = {"F1Hat", "F2Hat"};
sectorLabels = {"Delta", "BoundedPlus", "Ordinary"};
observableLabels = {"Delta", "Plus0", "Plus1", "Ordinary"};
expectedBound = Q2 (1/xHat - 1) (1 - z) - PHT2/z;

activeFlavorTypes = {"UpType", "DownType", "DownType", "UpType"};
flavorMultiplicities = Counts[activeFlavorTypes];
chargeAssignment = <|"UpType" -> 2/3, "DownType" -> -1/3|>;
require[Total[Values[flavorMultiplicities]] === 4 &&
    Keys[flavorMultiplicities] === {"UpType", "DownType"},
  "four-flavor benchmark multiplicities did not derive",
  flavorMultiplicities];

benchmarkSeeds = {
  <|"ID" -> "interior_1", "xB" -> 23/100, "xi" -> 61/100,
    "zH" -> 37/100, "Q2" -> 17, "qT2" -> 31/10,
    "S23Fraction" -> 2/5, "Nf" -> 4|>,
  <|"ID" -> "interior_2", "xB" -> 19/100, "xi" -> 73/100,
    "zH" -> 41/100, "Q2" -> 23, "qT2" -> 27/10,
    "S23Fraction" -> 7/20, "Nf" -> 4|>,
  <|"ID" -> "interior_3", "xB" -> 31/100, "xi" -> 79/100,
    "zH" -> 29/100, "Q2" -> 29, "qT2" -> 19/10,
    "S23Fraction" -> 11/20, "Nf" -> 4|>
};

deriveBenchmark[seed_Association] := Module[
  {xHatValue, pht2Value, upperValue, sampleValue, denominator,
   endpointDenominator, common, zHatValue, zHat0Value, zetaValue,
   zeta0Value, sValue, tValue, t0Value, jacobianValue,
   jacobian0Value},
  xHatValue = seed["xB"]/seed["xi"];
  pht2Value = seed["zH"]^2 seed["qT2"];
  upperValue = seed["Q2"] (1/xHatValue - 1) (1 - seed["zH"]) -
    pht2Value/seed["zH"];
  sampleValue = seed["S23Fraction"] upperValue;
  denominator = (1 - xHatValue) - xHatValue sampleValue/seed["Q2"];
  endpointDenominator = 1 - xHatValue;
  common = (1 - xHatValue) + xHatValue seed["qT2"]/seed["Q2"];
  zHatValue = denominator/common;
  zHat0Value = endpointDenominator/common;
  zetaValue = seed["zH"]/zHatValue;
  zeta0Value = seed["zH"]/zHat0Value;
  sValue = (1 - xHatValue) seed["Q2"]/xHatValue;
  tValue = -(1 - zHatValue) seed["Q2"] - zHatValue seed["qT2"];
  t0Value = -(1 - zHat0Value) seed["Q2"] - zHat0Value seed["qT2"];
  jacobianValue = zetaValue xHatValue/(seed["Q2"] denominator);
  jacobian0Value = zeta0Value xHatValue/
    (seed["Q2"] endpointDenominator);
  require[TrueQ[0 < xHatValue < 1] &&
      TrueQ[upperValue > 0 && 0 < sampleValue < upperValue] &&
      TrueQ[0 < zHatValue < 1 && 0 < zHat0Value < 1] &&
      TrueQ[0 < zetaValue < 1 && 0 < zeta0Value < 1] &&
      TrueQ[jacobianValue > 0 && jacobian0Value > 0],
    seed["ID"] <> " is not a physical interior benchmark"];
  Join[seed, <|
    "xHat" -> xHatValue, "PHT2" -> pht2Value,
    "Q" -> Sqrt[seed["Q2"]], "S23UpperB" -> upperValue,
    "S23Sample" -> sampleValue, "zHat" -> zHatValue,
    "zHat0" -> zHat0Value, "zeta" -> zetaValue,
    "zeta0" -> zeta0Value, "s" -> sValue, "t" -> tValue,
    "t0" -> t0Value, "Jacobian" -> jacobianValue,
    "Jacobian0" -> jacobian0Value|>]
];

benchmarks = deriveBenchmark /@ benchmarkSeeds;
Clear[benchmarkSeeds];

localRules[benchmark_Association, endpointQ_] := {
  xHat -> benchmark["xHat"], z -> benchmark["zH"],
  Q2 -> benchmark["Q2"], PHT2 -> benchmark["PHT2"],
  sHat -> benchmark["s"],
  t1 -> If[TrueQ[endpointQ], benchmark["t0"], benchmark["t"]],
  s23 -> If[TrueQ[endpointQ], 0, benchmark["S23Sample"]],
  FAGS -> 1,
  HoldPattern[FeynCalc`FCGV["EL"]] -> 1,
  HoldPattern[FeynArts`FCGV["EL"]] -> 1,
  HoldPattern[FeynCalc`SMP["g_s"]] -> 1,
  FeynCalc`ScaleMu -> benchmark["Q"],
  FeynCalc`SUNN -> 3, FeynCalc`CA -> 3,
  FeynCalc`CF -> 4/3, FeynCalc`TF -> 1/2,
  HoldPattern[HqqV2Charge["UpType"]] -> chargeAssignment["UpType"],
  HoldPattern[HqqV2Charge["DownType"]] -> chargeAssignment["DownType"],
  HoldPattern[HqqV2FlavorMultiplicity["UpType"]] ->
    flavorMultiplicities["UpType"],
  HoldPattern[HqqV2FlavorMultiplicity["DownType"]] ->
    flavorMultiplicities["DownType"]
};

numericalValue[expression_, benchmark_Association, endpointQ_,
    label_String] := Module[
  {substituted, remainingSymbols, value, physicalValue},
  substituted = Quiet@Check[
    expression /. localRules[benchmark, endpointQ], $Failed];
  require[substituted =!= $Failed && FreeQ[substituted, _Real],
    label <> " failed exact benchmark substitution"];
  substituted = Quiet@Check[reduceToolSpecialFunctions[substituted], $Failed];
  require[substituted =!= $Failed,
    label <> " failed pinned special-function reduction"];
  remainingSymbols = DeleteDuplicates@Cases[
    substituted,
    symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`",
    {0, Infinity}, Heads -> True];
  require[remainingSymbols === {},
    label <> " retained symbols", remainingSymbols];
  value = Quiet@Check[N[substituted, 30], $Failed];
  require[value =!= $Failed && NumberQ[value] &&
      FreeQ[value, Indeterminate | ComplexInfinity | DirectedInfinity[_]],
    label <> " did not evaluate to a finite number", value];
  AssociateTo[branchImaginaryDiagnostics, label -> N[Im[value], 17]];
  physicalValue = N[Re[value], 17];
  require[NumberQ[physicalValue] &&
      FreeQ[physicalValue, Indeterminate | ComplexInfinity |
        DirectedInfinity[_]],
    label <> " Hermitian real projection is not finite", physicalValue];
  physicalValue
];

reduceToolSpecialFunctions[expression_] := Module[{answer},
  answer = expression /.
    HoldPattern[HyperIntica`Mpl[indices_List, arguments_List]] :>
      HyperIntica`MplAsHlog[indices, arguments];
  answer //. HyperIntica`mzvAllReductions
];

extractBoundedPlusCoefficients[expression_, label_String] := Module[
  {atoms, bounds, orders, polynomial, coefficients, remainder, checks},
  atoms = DeleteDuplicates@Cases[expression,
    head : HqqV2BoundedPlus[_Integer, s23, _] :> head, Infinity];
  bounds = #[[3]] & /@ atoms;
  orders = Sort@DeleteDuplicates[#[[1]] & /@ atoms];
  polynomial = expression /.
    HqqV2BoundedPlus[order_Integer, s23, bound_] :> s01PlusDummy[order];
  coefficients = Association@Table[order -> Quiet@Check[
    Cancel[Together[Coefficient[polynomial, s01PlusDummy[order]]]],
    $Failed], {order, {0, 1}}];
  remainder = Quiet@Check[Cancel[Together[
    polynomial - Total@Table[
      coefficients[order] s01PlusDummy[order], {order, {0, 1}}]]],
    $Failed];
  checks = <|
    "Orders" -> orders === {0, 1},
    "Bounds" -> atoms =!= {} && And @@ (exactZeroQ[# - expectedBound] & /@ bounds),
    "Linear" -> PolynomialQ[polynomial, {s01PlusDummy[0], s01PlusDummy[1]}] &&
      And @@ (Exponent[polynomial, s01PlusDummy[#]] === 1 & /@ {0, 1}),
    "Coefficients" -> coefficients =!= $Failed &&
      FreeQ[coefficients, $Failed | _s01PlusDummy | HqqV2BoundedPlus],
    "Remainder" -> remainder =!= $Failed && SameQ[remainder, 0]|>;
  require[And @@ Values[checks],
    label <> " bounded-plus extraction failed", checks];
  <|"Plus0" -> coefficients[0], "Plus1" -> coefficients[1],
    "Orders" -> orders, "DistinctBoundCount" -> Length[DeleteDuplicates[bounds]],
    "Checks" -> checks|>
];

jsonAssociation[association_Association] := Association@KeyValueMap[
  (#1 -> If[NumericQ[#2], N[#2, 17], #2]) &, association];

atomicRawJSONExport[data_, path_String] := Module[
  {temporaryPath = path <> ".tmp", exported},
  require[! FileExistsQ[path] && ! FileExistsQ[temporaryPath],
    "refusing to overwrite local benchmark output or temporary"];
  exported = Quiet@Check[Export[temporaryPath, data, "RawJSON"], $Failed];
  If[exported === $Failed || ! FileExistsQ[temporaryPath] ||
      FileByteCount[temporaryPath] <= 0,
    If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
    fatal["failed to export local benchmark JSON"]];
  RenameFile[temporaryPath, path];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published local benchmark JSON is absent"]
];

Print[scopeTag];
Print["HQQV2_BIGTMD_S01_STAGE=validate accepted inputs"];
requiredFiles = Join[{s00ProgramPath, s00ResultPath, s08ProgramPath,
    s08ResultPath, paperPath, hyperInticaPath, driverPath},
  Values[referenceModulePaths]];
require[And @@ (FileExistsQ[#] && FileByteCount[#] > 0 & /@ requiredFiles),
  "one or more required input/reference files are absent"];
require[fileSHA256[s00ProgramPath] === expectedS00ProgramSHA256 &&
    fileSHA256[s00ResultPath] === expectedS00ResultSHA256 &&
    fileSHA256[s08ProgramPath] === expectedS08ProgramSHA256 &&
    fileSHA256[s08ResultPath] === expectedS08ResultSHA256 &&
    fileSHA256[paperPath] === expectedPaperSHA256 &&
    fileSHA256[hyperInticaPath] === expectedHyperInticaSHA256 &&
    fileSHA256[driverPath] === expectedDriverSHA256 &&
    And @@ KeyValueMap[fileSHA256[referenceModulePaths[#1]] === #2 &,
      expectedReferenceSHA256],
  "accepted input or BigTMD reference identity changed"];

Get[hyperInticaPath];
require[Length[Names["HyperIntica`*"]] > 0,
  "pinned HyperIntica backend did not load"];
HyperIntica`$HyperVerbosity = 0;
HyperIntica`$QuietPrint = True;
packageXInitialization = Quiet[
  ToExpression["FeynCalc`PaXEvaluate[FeynCalc`A0[1]]"]];
packageXNumericProbe = Quiet@Check[
  N[ToExpression["FeynCalc`PaXDiLog[2/3,5/7]"], 30], $Failed];
packageXGateDetail = <|
  "InitializationHead" -> Head[packageXInitialization],
  "NumericProbe" -> packageXNumericProbe,
  "NumericProbeNumberQ" -> NumberQ[packageXNumericProbe],
  "VisiblePaXSymbols" -> Names["*PaXDiLog*"]|>;
require[NumberQ[packageXNumericProbe] &&
    FreeQ[packageXNumericProbe,
      Indeterminate | ComplexInfinity | DirectedInfinity[_]],
  "FeynHelpers/Package-X numerical backend did not initialize",
  packageXGateDetail];
Clear[packageXInitialization, packageXNumericProbe, packageXGateDetail];

prepared = Quiet@Check[Get[s00ResultPath], $Failed];
require[AssociationQ[prepared] &&
    prepared["Stage"] === "HqqV2BigTMDCheckS00-v1" &&
    prepared["ScopeTag"] === scopeTag &&
    FileNameTake[prepared["Program", "Path"]] ===
      FileNameTake[s00ProgramPath] &&
    prepared["Program", "SHA256"] === expectedS00ProgramSHA256 &&
    prepared["Source", "SHA256"] === expectedS08ResultSHA256 &&
    prepared["Source", "ProgramSHA256"] === expectedS08ProgramSHA256 &&
    prepared["Source", "PaperSHA256"] === expectedPaperSHA256 &&
    prepared["AcceptedHatSHA256"] === expectedHatSHA256 &&
    AssociationQ[prepared["Checks"]] &&
    allBooleanLeavesTrueQ[prepared["Checks"]],
  "accepted S00 bridge schema, provenance, or check ledger changed"];
require[And @@ Table[
    AssociationQ[prepared[hat]] && Keys[prepared[hat]] === sectorLabels &&
      FreeQ[prepared[hat], epsilon | D | FeynCalc`EpsilonUV |
        FeynCalc`EpsilonIR | _SeriesData | _Real | $Failed],
    {hat, hatLabels}],
  "prepared S00 hat schema or exactness changed"];

Print["HQQV2_BIGTMD_S01_STAGE=extract exact bounded-plus coefficients"];
plusRecords = AssociationMap[
  extractBoundedPlusCoefficients[prepared[#, "BoundedPlus"], #] &,
  hatLabels];
observableExpressions = AssociationMap[Function[hat, <|
  "Delta" -> prepared[hat, "Delta"],
  "Plus0" -> plusRecords[hat, "Plus0"],
  "Plus1" -> plusRecords[hat, "Plus1"],
  "Ordinary" -> prepared[hat, "Ordinary"]|>], hatLabels];
Clear[prepared];
ClearSystemCache[];

Print["HQQV2_BIGTMD_S01_STAGE=evaluate exact local coefficients"];
valuesByHatObservable = <||>;
branchImaginaryDiagnostics = <||>;
Do[
  hatValues = <||>;
  Do[
    Print["HQQV2_BIGTMD_S01_OBSERVABLE=", hat, "/", observable];
    expression = observableExpressions[hat, observable];
    benchmarkValues = Association@Table[
      Print["HQQV2_BIGTMD_S01_POINT=", hat, "/", observable, "/",
        benchmark["ID"]];
      benchmark["ID"] -> numericalValue[expression, benchmark,
        observable =!= "Ordinary", "local " <> hat <> "/" <>
          observable <> "/" <> benchmark["ID"]],
      {benchmark, benchmarks}];
    AssociateTo[hatValues, observable -> benchmarkValues];
    Clear[expression, benchmarkValues];
    ClearSystemCache[],
    {observable, observableLabels}];
  AssociateTo[valuesByHatObservable, hat -> hatValues];
  KeyDropFrom[observableExpressions, hat];
  Clear[hatValues];
  ClearSystemCache[],
  {hat, hatLabels}];

benchmarkIDs = Lookup[benchmarks, "ID"];
localByBenchmark = AssociationMap[Function[id,
  AssociationMap[Function[observable,
    AssociationMap[valuesByHatObservable[#, observable, id] &, hatLabels]],
    observableLabels]], benchmarkIDs];

payload = <|
  "Status" -> "CompleteLocalHqqV2FHatBenchmarks",
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> <|"Path" -> programPath,
    "SHA256" -> fileSHA256[programPath]|>,
  "Source" -> <|"Path" -> s08ResultPath,
    "ByteCount" -> FileByteCount[s08ResultPath],
    "SHA256" -> expectedS08ResultSHA256,
    "ProgramPath" -> s08ProgramPath,
    "ProgramSHA256" -> expectedS08ProgramSHA256,
    "Stage" -> "HqqV2S08-v1",
    "FHatSHA256" -> expectedHatSHA256|>,
  "ReferenceBinding" -> <|
    "Directory" -> referenceDirectory,
    "Commit" -> "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c",
    "DriverPath" -> driverPath,
    "DriverSHA256" -> expectedDriverSHA256,
    "ModulePaths" -> referenceModulePaths,
    "ModuleSHA256" -> expectedReferenceSHA256|>,
  "Construction" -> <|
    "Method" -> "exact rational substitution into accepted S08 hats, pinned HyperIntica MPL/MZV reduction and Package-X evaluation, then the tool-evaluated Hermitian real projection",
    "LocalSymbolicUntilFinalEvaluation" -> True,
    "BoundedPlusOrders" -> {0, 1},
    "ObservableOrder" -> observableLabels,
    "ExpectedComparisonCount" -> 24|>,
  "ComparisonLevel" ->
    "finite fixed-up-flavor Hqq coefficient including zeta-to-s23 Jacobian, before the common remaining driver test factor and outer convolution",
  "Conventions" -> <|
    "BigTMDChannel" -> 2,
    "BigTMDCaseOrder" -> {"A", "B", "C"},
    "Couplings" -> "EL=1 and g_s=1",
    "Color" -> "SU(3): SUNN=CA=3, CF=4/3, TF=1/2",
    "Scale" -> "ScaleMu=Q",
    "Nf" -> 4,
    "ActiveFlavorTypes" -> activeFlavorTypes,
    "FlavorMultiplicities" -> <|"UpType" -> 2, "DownType" -> 2|>,
    "ChargeAssignment" -> <|"UpType" -> "2/3", "DownType" -> "-1/3"|>,
    "IncomingAndFragmentingType" -> "UpType",
    "LocalJacobianAlreadyIncluded" -> True,
    "RemainingDriverTestFactor" -> "deferred identically on both sides",
    "DifferenceDirectionExpectedByS02" -> "BigTMD minus local"|>,
  "BoundedPlusExtraction" -> AssociationMap[
    <|"Orders" -> plusRecords[#, "Orders"],
      "DistinctBoundCount" -> plusRecords[#, "DistinctBoundCount"],
      "Checks" -> plusRecords[#, "Checks"]|> &, hatLabels],
  "NumericalBranchDiagnostics" -> <|
    "Convention" ->
      "accepted S06 Hermitian expression; store Re of the final Package-X/HyperIntica numerical evaluation",
    "ImaginaryPartBeforeHermitianRealProjection" ->
      AssociationMap[N[#, 17] &, branchImaginaryDiagnostics]|>,
  "Benchmarks" -> (jsonAssociation /@ benchmarks),
  "LocalFHatByBenchmark" -> localByBenchmark|>;

Print["HQQV2_BIGTMD_S01_STAGE=write local benchmark artifact"];
atomicRawJSONExport[payload, outputPath];
Print["HQQV2_BIGTMD_S01_OUTPUT=", outputPath];
Print["HQQV2_BIGTMD_S01_OUTPUT_BYTES=", FileByteCount[outputPath]];
Print["HQQV2_BIGTMD_S01_SUCCESS"];
Quit[0];

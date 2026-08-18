(* ::Package:: *)

(*
  Hqqbar BigTMD check, stage S01.

  Load the accepted exact Hqqbar S13 coefficient pairs, prove that channel 5
  is regular-only in the local distribution representation, and evaluate the
  two regular F-hat coefficients at three exact rational interior benchmark
  points.  BigTMD itself is not evaluated here.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, sha256Hex, allBooleanLeavesTrueQ,
  accidentalGlobalFeynCalcSymbolQ, feynCalcContextCleanQ,
  deriveBenchmark, benchmarkRules, numericalValue, jsonAssociation,
  atomicRawJSONExport
];

fatal[message_String] := (
  Print["HQQBAR_BIGTMD_S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

sha256Hex[path_String] :=
  IntegerString[FileHash[path, "SHA256"], 16, 64];

allBooleanLeavesTrueQ[expression_] := Module[{leaves},
  leaves = Cases[expression, True | False, {0, Infinity}];
  leaves =!= {} && FreeQ[expression, False] && AllTrue[leaves, TrueQ]
];

feynCalcOwnedSymbolNames = {
  "CF", "CA", "SUNN", "TF", "SMP", "FCGV", "ScaleMu"
};
accidentalGlobalFeynCalcSymbolQ[symbol_Symbol] := TrueQ[
  Context[Unevaluated[symbol]] === "Global`" &&
    MemberQ[
      feynCalcOwnedSymbolNames,
      SymbolName[Unevaluated[symbol]]
    ]
];
feynCalcContextCleanQ[expression_] := FreeQ[
  expression,
  _Symbol?accidentalGlobalFeynCalcSymbolQ,
  {0, Infinity},
  Heads -> True
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
channelDirectory = DirectoryName[checkDirectory];
scriptsDirectory = DirectoryName[channelDirectory];
s13Path = FileNameJoin[{channelDirectory, "s13_result"}];
s13ProgramPath =
  FileNameJoin[{channelDirectory, "s13_extract_fhat_hqqbar.wl"}];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];
referenceDirectory = FileNameJoin[{
  scriptsDirectory, "Hqq", "bigTMD_check", "BigTMD_reference"
}];
driverPath = FileNameJoin[{referenceDirectory, "sidis.py"}];
outputPath = FileNameJoin[{checkDirectory, "local_fhat_benchmarks.json"}];
programPath = ExpandFileName[$InputFileName];

stageVersion = "HqqbarBigTMDCheckS01-v1";
expectedS13ProgramSHA256 =
  "760cad942ee628c0e3de3b76362cbbb103bf6c8d9c920983b84f717b5adf1f13";
expectedS13ResultSHA256 =
  "4224b46a064087ed3b20e36a049dd1929019f66583263fcb2c28c9b69614c64f";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedDriverSHA256 =
  "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d";
expectedReferenceSHA256 = <|
  "Pg5A" ->
    "9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b",
  "PPP5A" ->
    "5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e",
  "Pg5B" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "PPP5B" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "Pg5C" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
  "PPP5C" ->
    "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b"
|>;

structureFunctions = {"F1Hat", "F2Hat"};
fields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};

benchmarkSeeds = {
  <|
    "ID" -> "interior_1", "xB" -> 23/100, "xi" -> 61/100,
    "zH" -> 37/100, "Q2" -> 17, "qT2" -> 31/10,
    "S23Fraction" -> 2/5, "Nf" -> 4
  |>,
  <|
    "ID" -> "interior_2", "xB" -> 19/100, "xi" -> 73/100,
    "zH" -> 41/100, "Q2" -> 23, "qT2" -> 27/10,
    "S23Fraction" -> 7/20, "Nf" -> 4
  |>,
  <|
    "ID" -> "interior_3", "xB" -> 31/100, "xi" -> 79/100,
    "zH" -> 29/100, "Q2" -> 29, "qT2" -> 19/10,
    "S23Fraction" -> 11/20, "Nf" -> 4
  |>
};

deriveBenchmark[seed_Association] := Module[
  {
    xHatValue, pht2Value, upperValue, sampleValue, denominator,
    common, zHatValue, zetaValue, sValue, tValue, jacobianValue
  },
  xHatValue = seed["xB"]/seed["xi"];
  pht2Value = seed["zH"]^2 seed["qT2"];
  upperValue = seed["Q2"] (1/xHatValue - 1) (1 - seed["zH"]) -
    pht2Value/seed["zH"];
  sampleValue = seed["S23Fraction"] upperValue;
  denominator = (1 - xHatValue) - xHatValue sampleValue/seed["Q2"];
  common = (1 - xHatValue) + xHatValue seed["qT2"]/seed["Q2"];
  zHatValue = denominator/common;
  zetaValue = seed["zH"]/zHatValue;
  sValue = (1 - xHatValue) seed["Q2"]/xHatValue;
  tValue = -(1 - zHatValue) seed["Q2"] -
    zHatValue seed["qT2"];
  jacobianValue = zetaValue xHatValue/(seed["Q2"] denominator);
  assert[TrueQ[0 < xHatValue < 1], seed["ID"] <> " has unphysical xHat."];
  assert[TrueQ[upperValue > 0 && 0 < sampleValue < upperValue],
    seed["ID"] <> " has an invalid s23 interval/sample."];
  assert[TrueQ[0 < zHatValue < 1 && 0 < zetaValue < 1],
    seed["ID"] <> " has an invalid zHat or zeta."];
  assert[TrueQ[jacobianValue > 0],
    seed["ID"] <> " has a nonpositive zeta-to-s23 Jacobian."];
  Join[
    seed,
    <|
      "xHat" -> xHatValue,
      "PHT2" -> pht2Value,
      "Q" -> Sqrt[seed["Q2"]],
      "S23UpperB" -> upperValue,
      "S23Sample" -> sampleValue,
      "zHat" -> zHatValue,
      "zeta" -> zetaValue,
      "s" -> sValue,
      "t" -> tValue,
      "Jacobian" -> jacobianValue
    |>
  ]
];

benchmarks = deriveBenchmark /@ benchmarkSeeds;
Clear[benchmarkSeeds];

benchmarkRules[benchmark_Association] := {
  xB -> benchmark["xB"],
  xi -> benchmark["xi"],
  zH -> benchmark["zH"],
  Q2 -> benchmark["Q2"],
  PHT2 -> benchmark["PHT2"],
  s23 -> benchmark["S23Sample"],
  FeynCalc`ScaleMu -> benchmark["Q"],
  FeynCalc`CA -> 3,
  FeynCalc`CF -> 4/3,
  FeynCalc`TF -> 1/2,
  HoldPattern[FeynCalc`SMP["g_s"]] -> 1,
  HoldPattern[FeynCalc`FCGV["EL"]] -> 1,
  HoldPattern[FeynArts`FCGV["EL"]] -> 1,
  Nf -> benchmark["Nf"]
};

numericalValue[expression_, benchmark_Association, label_String] := Module[
  {substituted, remainingSymbols, value},
  substituted = expression /. benchmarkRules[benchmark];
  assert[FreeQ[substituted, _Real],
    label <> " acquired a machine number before final evaluation."];
  remainingSymbols = DeleteDuplicates@Cases[
    substituted,
    symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`",
    {0, Infinity},
    Heads -> True
  ];
  assert[remainingSymbols === {},
    label <> " retained symbols: " <> ToString[InputForm[remainingSymbols]]];
  value = Quiet@Check[N[substituted, 30], $Failed];
  assert[value =!= $Failed && NumberQ[value] &&
      FreeQ[value, Indeterminate | ComplexInfinity | DirectedInfinity[_]],
    label <> " did not evaluate to a finite number."];
  assert[Abs[N[Im[value], 20]] <= 10^-18 Max[1, Abs[N[Re[value], 20]]],
    label <> " is unexpectedly complex: " <> ToString[InputForm[value]]];
  N[Re[value], 17]
];

jsonAssociation[association_Association] := Association@@KeyValueMap[
  (#1 -> If[NumericQ[#2], N[#2, 17], #2]) &,
  association
];

atomicRawJSONExport[data_, path_String] := Module[
  {temporaryPath = path <> ".tmp", exported},
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  exported = Quiet@Check[Export[temporaryPath, data, "RawJSON"], $Failed];
  assert[exported =!= $Failed && FileExistsQ[temporaryPath] &&
      FileByteCount[temporaryPath] > 0,
    "failed to export the compact local benchmark JSON."];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
];

Print["HQQBAR_BIGTMD_S01_STAGE: validating accepted S13 and references"];
assert[FileExistsQ[s13Path] && FileByteCount[s13Path] > 0,
  "accepted s13_result is absent or empty."];
assert[FileExistsQ[s13ProgramPath] && FileExistsQ[paperPath] &&
    FileExistsQ[driverPath],
  "a required accepted source/reference file is absent."];
assert[sha256Hex[s13Path] === expectedS13ResultSHA256,
  "accepted S13 result hash changed."];
assert[sha256Hex[s13ProgramPath] === expectedS13ProgramSHA256,
  "accepted S13 program hash changed."];
assert[sha256Hex[paperPath] === expectedPaperSHA256,
  "authoritative paper hash changed."];
assert[sha256Hex[driverPath] === expectedDriverSHA256,
  "pinned BigTMD driver hash changed."];

s13 = Quiet@Check[Get[s13Path], $Failed];
assert[AssociationQ[s13] &&
    s13["Status"] === "CompleteFinitePartonicStructureFunctionsHqqbar" &&
    s13["StageVersion"] === "HqqbarS13-v1" &&
    s13["Channel"] === "Hqqbar only" &&
    s13["ProgramPath"] === s13ProgramPath &&
    s13["ProgramSHA256"] === expectedS13ProgramSHA256,
  "S13 artifact has the wrong schema, channel, or source binding."];
assert[AssociationQ[s13["Checks"]] &&
    allBooleanLeavesTrueQ[s13["Checks"]] &&
    AssociationQ[s13["PairChecks"]] &&
    allBooleanLeavesTrueQ[s13["PairChecks"]] &&
    AssociationQ[s13["FunctionChecks"]] &&
    allBooleanLeavesTrueQ[s13["FunctionChecks"]],
  "S13 contains a false or malformed validation ledger."];

inputProvenance = s13["InputProvenance"];
assert[AssociationQ[inputProvenance] &&
    inputProvenance["AuthoritativePaperPath"] === paperPath &&
    inputProvenance["AuthoritativePaperSHA256"] === expectedPaperSHA256 &&
    inputProvenance["BigTMDDriverPath"] === driverPath &&
    inputProvenance["BigTMDDriverSHA256"] === expectedDriverSHA256,
  "S13 paper or BigTMD-driver provenance is stale."];

bigTMDConvention = s13["BigTMDConvention"];
referencePaths = bigTMDConvention["ReferencePaths"];
assert[AssociationQ[bigTMDConvention] &&
    bigTMDConvention["ChannelNumber"] === 5 &&
    bigTMDConvention["ChargeCase"] === "A only" &&
    bigTMDConvention["FragmentingParton"] === "antiquark qbar(k1)" &&
    bigTMDConvention["BCases"] === "exact zero modules" &&
    AssociationQ[referencePaths] &&
    Sort[Keys[referencePaths]] === Sort[Keys[expectedReferenceSHA256]] &&
    And@@KeyValueMap[
      Function[{key, path},
        FileExistsQ[path] &&
          sha256Hex[path] === expectedReferenceSHA256[key] &&
          bigTMDConvention["ReferenceSHA256", key] ===
            expectedReferenceSHA256[key]
      ],
      referencePaths
    ],
  "S13 channel-5A/B/C reference convention or hash binding is stale."];

bookkeeping = s13["Bookkeeping"];
assert[AssociationQ[bookkeeping] &&
    bookkeeping["AdditionalMultiplicativeWeightAtS13"] === 1 &&
    TrueQ[bookkeeping["ChargeStripped"]] &&
    TrueQ[! bookkeeping["PhysicalFlavorChargeWeightApplied"]] &&
    bookkeeping["PhysicalFlavorChargeWeight"] ===
      "Sum_q e_q^2 f_q D_qbar" &&
    bookkeeping["IdenticalSpectatorFactorAppliedUpstreamAtS08"] === 1/2 &&
    TrueQ[! bookkeeping["IdenticalSpectatorFactorReappliedAtS13"]] &&
    bookkeeping["LOContributionAtThisOrder"] === 0 &&
    bookkeeping["VirtualContributionAtThisOrder"] === 0,
  "S13 charge, symmetry, LO, or virtual bookkeeping changed."];

physicalMapping = s13["PhysicalMapping"];
assert[AssociationQ[physicalMapping] &&
    TrueQ[Together[physicalMapping["XHat"] - xB/xi] === 0] &&
    TrueQ[Together[
      physicalMapping["S23Upper"] -
        (Q2 (xi/xB - 1) (1 - zH) - PHT2/zH)
    ] === 0] &&
    physicalMapping["Interval"] ===
      {s23, 0, physicalMapping["S23Upper"]},
  "S13 physical mapping changed."];
Do[
  assert[TrueQ[Together[
      (physicalMapping["XHat"] /. benchmarkRules[benchmark]) -
        benchmark["xHat"]
    ] === 0] &&
      TrueQ[Together[
        (physicalMapping["S23Upper"] /. benchmarkRules[benchmark]) -
          benchmark["S23UpperB"]
      ] === 0],
    benchmark["ID"] <> " does not match the accepted physical map."],
  {benchmark, benchmarks}
];

fHatPairs = s13["FiniteCoefficientPairsByStructureFunction"];
assert[AssociationQ[fHatPairs] &&
    Sort[Keys[fHatPairs]] === Sort[structureFunctions] &&
    And@@Table[
      AssociationQ[fHatPairs[structureFunction]] &&
        Keys[fHatPairs[structureFunction]] === fields &&
        TrueQ[fHatPairs[structureFunction, "Endpoint"] === 0] &&
        TrueQ[fHatPairs[structureFunction, "IntegrandPhi0"] === 0] &&
        FreeQ[
          fHatPairs[structureFunction],
          epsilon | _SeriesData | _Real | FeynCalc`SUNN | $Failed |
            Indeterminate | ComplexInfinity | DirectedInfinity[_]
        ] &&
        feynCalcContextCleanQ[fHatPairs[structureFunction]],
      {structureFunction, structureFunctions}
    ],
  "S13 F-hat pairs are not exact regular-only channel-5 coefficients."];
Clear[s13, inputProvenance, bookkeeping];
ClearSystemCache[];

Print["HQQBAR_BIGTMD_S01_STAGE: evaluating exact local regular F hats"];
regularValuesByFunction = <||>;
Do[
  Print["HQQBAR_BIGTMD_S01_FHAT: " <> structureFunction];
  regularExpression = fHatPairs[structureFunction, "IntegrandPhiS"];
  fHatPairs = KeyDrop[fHatPairs, structureFunction];
  valuesForFunction = Association@@Table[
    benchmark["ID"] -> numericalValue[
      regularExpression,
      benchmark,
      "local " <> structureFunction <> " " <> benchmark["ID"]
    ],
    {benchmark, benchmarks}
  ];
  AssociateTo[
    regularValuesByFunction,
    structureFunction -> valuesForFunction
  ];
  Clear[regularExpression, valuesForFunction];
  ClearSystemCache[];
  ,
  {structureFunction, structureFunctions}
];
Clear[fHatPairs];
ClearSystemCache[];

benchmarkIDs = Lookup[benchmarks, "ID"];
localByBenchmark = AssociationMap[
  Function[id,
    <|
      "Endpoint" -> AssociationMap[0. &, structureFunctions],
      "IntegrandPhiS" -> AssociationMap[
        regularValuesByFunction[#][id] &,
        structureFunctions
      ],
      "IntegrandPhi0" -> AssociationMap[0. &, structureFunctions]
    |>
  ],
  benchmarkIDs
];

payload = <|
  "Status" -> "CompleteLocalHqqbarFHatBenchmarks",
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> <|
    "Path" -> programPath,
    "SHA256" -> sha256Hex[programPath]
  |>,
  "Source" -> <|
    "Path" -> s13Path,
    "ByteCount" -> FileByteCount[s13Path],
    "SHA256" -> expectedS13ResultSHA256,
    "ProgramPath" -> s13ProgramPath,
    "ProgramSHA256" -> expectedS13ProgramSHA256,
    "Status" -> "CompleteFinitePartonicStructureFunctionsHqqbar",
    "StageVersion" -> "HqqbarS13-v1",
    "Channel" -> "Hqqbar only"
  |>,
  "ReferenceBinding" -> <|
    "DriverPath" -> driverPath,
    "DriverSHA256" -> expectedDriverSHA256,
    "ModulePaths" -> referencePaths,
    "ModuleSHA256" -> expectedReferenceSHA256
  |>,
  "Construction" -> <|
    "Method" ->
      "exact rational substitution into saved S13 coefficient pairs, then final numerical evaluation",
    "LocalSymbolicUntilFinalEvaluation" -> True,
    "EndpointAndPhi0ExactZero" -> True,
    "ReferenceDistributionContent" -> "channel-5A regular only"
  |>,
  "ComparisonLevel" ->
    "finite charge-stripped Hqqbar coefficient including zeta-to-s23 Jacobian, before physical luminosity, outer xi convolution, and remaining test-function weight",
  "Conventions" -> <|
    "Couplings" -> "EL=1 and g_s=1",
    "Color" -> "SU(3): CA=3, CF=4/3, TF=1/2",
    "Scale" -> "ScaleMu=Q",
    "PhysicalLuminosity" -> "Sum_q e_q^2 f_q D_qbar deferred",
    "BigTMDChannel" -> 5,
    "BigTMDChargeCases" -> {"A"},
    "BigTMDPartonicModuleWeight" -> 1,
    "BigTMDDistributionContent" -> "regular only",
    "LocalJacobianAlreadyIncluded" -> True,
    "AdditionalSymmetryFactor" -> 1,
    "BigTMDDecimalPolicy" ->
      "S02 executes the pinned decimal Python expressions as written",
    "DifferenceDirectionExpectedByS02" -> "BigTMD minus local"
  |>,
  "Benchmarks" -> (jsonAssociation /@ benchmarks),
  "LocalFHatByBenchmark" -> localByBenchmark
|>;

Print["HQQBAR_BIGTMD_S01_STAGE: writing compact local benchmarks"];
atomicRawJSONExport[payload, outputPath];
Print["HQQBAR_BIGTMD_S01_SUCCESS"];
Print["HQQBAR_BIGTMD_S01_OUTPUT=" <> outputPath];
Print["HQQBAR_BIGTMD_S01_OUTPUT_BYTES=", FileByteCount[outputPath]];
Quit[0];

(* ::Package:: *)

(*
  Hqqprime BigTMD check, stage S01.

  Validate the accepted charge-resolved Hqqprime S13 caches and evaluate the
  regular F1Hat/F2Hat coefficients at three exact rational interior benchmark
  points.  BigTMD itself is not evaluated here.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, fileSHA256, expressionSHA256, allBooleanLeavesTrueQ,
  accidentalGlobalFeynCalcSymbolQ, feynCalcContextCleanQ,
  deriveBenchmark, benchmarkRules, numericalValue, jsonAssociation,
  atomicRawJSONExport
];

fatal[message_String] := (
  Print["HQQPRIME_BIGTMD_S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

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
s13ResultPath = FileNameJoin[{channelDirectory, "s13_result"}];
s13ProgramPath =
  FileNameJoin[{channelDirectory, "s13_extract_fhat_hqqprime.wl"}];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
referenceDirectory = FileNameJoin[{checkDirectory, "BigTMD_reference"}];
driverPath = FileNameJoin[{referenceDirectory, "sidis.py"}];
outputPath = FileNameJoin[{checkDirectory, "local_fhat_benchmarks.json"}];
programPath = ExpandFileName[$InputFileName];

stageVersion = "HqqprimeBigTMDCheckS01-v1";
expectedS13ProgramSHA256 =
  "80141cec99769c0e32324fffcfc1322b5751554bc5f73172d7801bfa6041789e";
expectedS13ResultSHA256 =
  "351f1cbb6995d479cac0087e1cfefb92885c1e1f7dfb362386ba7dfe5c7d4365";
expectedPaperSHA256 =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedReferenceCommit =
  "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c";
expectedDriverSHA256 =
  "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d";

structureFunctions = {"F1Hat", "F2Hat"};
chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
caseOrder = {"A", "B", "C"};

expectedCachePaths = <|
  "F1Hat" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_incoming_charge_squared_f1hat"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_prime_charge_squared_f1hat"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_mixed_incoming_prime_charge_f1hat"
    }]
  |>,
  "F2Hat" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_incoming_charge_squared_f2hat"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_prime_charge_squared_f2hat"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      channelDirectory,
      "s13_cache_hqqprime_mixed_incoming_prime_charge_f2hat"
    }]
  |>
|>;

expectedCacheSHA256 = <|
  "F1Hat" -> <|
    "IncomingChargeSquared" ->
      "59cbf25b48e596d74b0541a1887f74a4256076002322cb4b110f078e3463adf0",
    "PrimeChargeSquared" ->
      "a755f32e6319c798fd24bdfdd2265b1d7adf88c7e203ca0d6c88995ae27f0d07",
    "MixedIncomingPrimeCharge" ->
      "24caef792f819725d9d607e21d0528a77164a2d64dd04337fcedf493f2ac1682"
  |>,
  "F2Hat" -> <|
    "IncomingChargeSquared" ->
      "6e07c2d9f20fbca5e038e127c932ba8e0f0c32e6c113ddadb430b22bb7a847d7",
    "PrimeChargeSquared" ->
      "716be770e25f9bec27127c1815c0ee4653b40b46b74c74753c95ef8a95445891",
    "MixedIncomingPrimeCharge" ->
      "babc7fbc0692727e7f57a9d0cfd437ae5ed4cbb1f7e495a30321be4060a08f1d"
  |>
|>;

expectedPairSHA256 = <|
  "F1Hat" -> <|
    "IncomingChargeSquared" ->
      "7f2303c53aabfac821e12e92f9121d09c64a38fc53053f78cf8bfaf7a7dea647",
    "PrimeChargeSquared" ->
      "a0c5708a8a916ed0eceed868898972381dd24b0cba6018c9be9669001fc292fc",
    "MixedIncomingPrimeCharge" ->
      "7b0ea8d36efc991eff38a3ac88dd975e28be61971b237e31fffcf690f1359faa"
  |>,
  "F2Hat" -> <|
    "IncomingChargeSquared" ->
      "d8cfe3974757c6244e9ace155737e97b8883ce69f2c60d91b90cd6b225d2b23e",
    "PrimeChargeSquared" ->
      "98aeff60f18cf55e61319682b7699dd218b98524ddaa745b50a1f3fed4fa1dfe",
    "MixedIncomingPrimeCharge" ->
      "cfbe4c8a317eb319f036bf1910e983dc2055ec4ec051706fe145938188a4c1dd"
  |>
|>;

expectedActionSHA256 = <|
  "F1Hat" -> <|
    "IncomingChargeSquared" ->
      "7ece6bb785554593bf3ef583ca58b5de698849b762c21fcac8ea03b775668450",
    "PrimeChargeSquared" ->
      "3e537828ab80fff696af1f36a3a0da48f950c305361566eab3287152ba319dbd",
    "MixedIncomingPrimeCharge" ->
      "a0b974c8555f6fa32764264c6ebfaee3a8d2cf2e90f5eb2220ca77114b9410d7"
  |>,
  "F2Hat" -> <|
    "IncomingChargeSquared" ->
      "01dd4fbf1dcf2234b9c0dc012223c87708ff9e3a308d78c9f1ddc3b4dcf51bf5",
    "PrimeChargeSquared" ->
      "bf1c0c28cab686a6a1c3b3e1f5872a24c4aebbbd19446b775a13cdfc9425618f",
    "MixedIncomingPrimeCharge" ->
      "a7c8ed2ae28666284d7efaa548f2a7c4b81e1aed9add0eb5f87cf99911389547"
  |>
|>;

referenceModulePaths = <|
  "Pg6A" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn6A.py"}],
  "PPP6A" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn6A.py"}],
  "Pg6B" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn6B.py"}],
  "PPP6B" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn6B.py"}],
  "Pg6C" -> FileNameJoin[{referenceDirectory, "NLO", "Pg", "fchn6C.py"}],
  "PPP6C" -> FileNameJoin[{referenceDirectory, "NLO", "Ppp", "fchn6C.py"}]
|>;

expectedReferenceSHA256 = <|
  "Pg6A" ->
    "502dbfb704a85356d004dcc290604a85cbe6379d664d47e27968aea795e1f3dd",
  "PPP6A" ->
    "2a3c88860a52be0946cd824cbb31fbc959d4384706cd9ac790a44f752d54dbd4",
  "Pg6B" ->
    "ce3bd5d92a0be6da8559f8c4daf629741dd52277cb0c1166b6b3286484a72fb9",
  "PPP6B" ->
    "bd522acf18af68129a125ce69405ab8283d4a7f718d1ee1be6e068cc6ae9e761",
  "Pg6C" ->
    "81fe1c6c909148aef8cdfafff86552645a5df68049d088b1ff6a931eafae2326",
  "PPP6C" ->
    "48bbba2e8c407665ed98824867a9e0f6429746803aaa8f9f59b8a4ab24ac6245"
|>;

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
  tValue = -(1 - zHatValue) seed["Q2"] - zHatValue seed["qT2"];
  jacobianValue = zetaValue xHatValue/(seed["Q2"] denominator);
  assert[TrueQ[0 < xHatValue < 1],
    seed["ID"] <> " has unphysical xHat."];
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
  assert[! FileExistsQ[path],
    "refusing to overwrite the final local benchmark JSON."];
  assert[! FileExistsQ[temporaryPath],
    "refusing to overwrite a pre-existing temporary local JSON."];
  exported = Quiet@Check[Export[temporaryPath, data, "RawJSON"], $Failed];
  If[
    exported === $Failed || ! FileExistsQ[temporaryPath] ||
      FileByteCount[temporaryPath] <= 0,
    If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
    fatal["failed to export the compact local benchmark JSON."]
  ];
  RenameFile[temporaryPath, path];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "atomic local benchmark JSON rename failed."];
];

Print["HQQPRIME_BIGTMD_S01_STAGE: validating accepted S13 result"];
assert[FileExistsQ[s13ResultPath] && FileByteCount[s13ResultPath] > 0,
  "accepted s13_result is absent or empty."];
assert[FileExistsQ[s13ProgramPath] && FileExistsQ[paperPath],
  "the accepted S13 source or authoritative paper is absent."];
assert[! FileExistsQ[outputPath] && ! FileExistsQ[outputPath <> ".tmp"],
  "a local benchmark output or temporary file already exists."];
assert[fileSHA256[s13ResultPath] === expectedS13ResultSHA256,
  "accepted S13 result hash changed."];
assert[fileSHA256[s13ProgramPath] === expectedS13ProgramSHA256,
  "accepted S13 source hash changed."];
assert[fileSHA256[paperPath] === expectedPaperSHA256,
  "authoritative paper hash changed."];

s13 = Quiet@Check[Get[s13ResultPath], $Failed];
assert[
  AssociationQ[s13] &&
    s13["Status"] === "Complete" &&
    s13["Stage"] === "HqqprimeS13-v1" &&
    s13["ResultSchemaVersion"] === 1 &&
    s13["Channel"] === "Hqqprime only" &&
    s13["ProgramPath"] === s13ProgramPath &&
    s13["ProgramSHA256"] === expectedS13ProgramSHA256 &&
    s13["ProjectorOrder"] === {"Pg", "PPP"} &&
    s13["StructureFunctionOrder"] === structureFunctions &&
    s13["ChargeKeyOrder"] === chargeKeys,
  "S13 compact artifact has the wrong schema, order, or source binding."
];
assert[
  AssociationQ[s13["Checks"]] && allBooleanLeavesTrueQ[s13["Checks"]] &&
    AssociationQ[s13["BranchSummaries"]] &&
    FreeQ[s13["BranchSummaries"], False],
  "S13 compact artifact contains a false or malformed validation ledger."
];
assert[
  s13["InputProvenance", "AuthoritativePaperPath"] === paperPath &&
    s13["InputProvenance", "AuthoritativePaperSHA256"] ===
      expectedPaperSHA256 &&
    s13["FiniteActionCaches", "StageVersion"] ===
      "HqqprimeS13Cache-v1" &&
    s13["FiniteActionCaches", "Paths"] === expectedCachePaths &&
    s13["FiniteActionCaches", "SHA256"] === expectedCacheSHA256 &&
    s13["FiniteActionCaches", "FiniteCoefficientPairField"] ===
      "FiniteCoefficientPair" &&
    s13["FiniteActionCaches", "FiniteHattedActionField"] ===
      "FiniteHattedAction" &&
    s13["FiniteActionCaches", "ProgramSHA256"] ===
      expectedS13ProgramSHA256 &&
    TrueQ[s13["FiniteActionCaches",
      "StructureFunctionFirstChargeSecondOrder"]] &&
    TrueQ[s13["FiniteActionCaches",
      "AtomicMainWriterExactReloadValidated"]],
  "S13 cache ledger or paper provenance changed."
];

bookkeeping = s13["Bookkeeping"];
assert[
  AssociationQ[bookkeeping] &&
    bookkeeping["AdditionalMultiplicativeWeightAtS13"] === 1 &&
    bookkeeping["ChargeInheritedFromS12", "SeparatedTensorKeys"] ===
      chargeKeys &&
    bookkeeping["ChargeInheritedFromS12",
      "CoefficientTensorsRemainChargeFree"] === True &&
    bookkeeping["ChargeInheritedFromS12",
      "PhysicalOrderedFlavorChargeAssemblyAppliedAtS12"] === False &&
    bookkeeping["ScaleInheritedFromS12",
      "PartonicPDForFFAdditionalMuEpsilon"] === 0 &&
    bookkeeping["ScaleInheritedFromS12",
      "SeparateMSBarSEpsilonAppliedToS10"] === False &&
    bookkeeping["SymmetryInheritedFromS12",
      "FinalStateFactorInherited"] === 1 &&
    bookkeeping["SymmetryInheritedFromS12",
      "AdditionalSymmetryOrFlavorMultiplicityAtS12"] === 1 &&
    bookkeeping["SymmetryInheritedFromS12",
      "NontrivialSymmetryFactorAppliedAtS12"] === False &&
    AssociationQ[bookkeeping["VirtualContributionAtThisOrder"]] &&
    bookkeeping["VirtualContributionAtThisOrder", "Applicable"] === False &&
    bookkeeping["VirtualContributionAtThisOrder", "Interference"] === 0 &&
    bookkeeping["VirtualContributionAtThisOrder", "SourceDisposition"] ===
      "NotApplicableAtThisOrder" &&
    bookkeeping["PhysicalOrderedFlavorChargeAssemblyAppliedAtS13"] ===
      False &&
    bookkeeping["NewMSbarScaleColorChargeOrSymmetryFactorAppliedAtS13"] ===
      False &&
    bookkeeping["HermitianProjectionAppliedAtS13"] === False,
  "S13 charge, scale, symmetry, or virtual bookkeeping changed."
];

physicalMapping = s13["PhysicalMapping", "AcceptedS12Mapping"];
integrationInterval = s13["PhysicalMapping", "IntegrationInterval"];
assert[
  AssociationQ[physicalMapping] &&
    TrueQ[Together[physicalMapping["XHat"] - xB/xi] === 0] &&
    TrueQ[Together[
      physicalMapping["S23Upper"] -
        (Q2 (xi/xB - 1) (1 - zH) - PHT2/zH)
    ] === 0] &&
    integrationInterval === {s23, 0, physicalMapping["S23Upper"]},
  "S13 physical mapping or integration interval changed."
];
Do[
  assert[
    TrueQ[Together[
      (physicalMapping["XHat"] /. benchmarkRules[benchmark]) -
        benchmark["xHat"]
    ] === 0] &&
      TrueQ[Together[
        (physicalMapping["S23Upper"] /. benchmarkRules[benchmark]) -
          benchmark["S23UpperB"]
      ] === 0],
    benchmark["ID"] <> " does not match the accepted S13 physical map."
  ],
  {benchmark, benchmarks}
];

Print["HQQPRIME_BIGTMD_S01_STAGE: deriving channel-6 case routing"];
localChargeMonomials = <|
  "IncomingChargeSquared" -> eIncoming^2,
  "PrimeChargeSquared" -> ePrime^2,
  "MixedIncomingPrimeCharge" -> eIncoming ePrime
|>;
bigTMDCaseMonomials = <|
  "A" -> eIncoming^2,
  "B" -> eIncoming ePrime,
  "C" -> ePrime^2
|>;
caseToCharge = AssociationMap[
  Function[case,
    Module[{matches},
      matches = Select[
        chargeKeys,
        TrueQ[Together[
          localChargeMonomials[#] - bigTMDCaseMonomials[case]
        ] === 0] &
      ];
      assert[Length[matches] === 1,
        "channel-6 case " <> case <> " did not map uniquely."];
      First[matches]
    ]
  ],
  caseOrder
];
assert[
  caseToCharge === <|
    "A" -> "IncomingChargeSquared",
    "B" -> "MixedIncomingPrimeCharge",
    "C" -> "PrimeChargeSquared"
  |> && Sort[Values[caseToCharge]] === Sort[chargeKeys],
  "derived channel-6 A/B/C routing is not the accepted permutation."
];
Clear[localChargeMonomials, bigTMDCaseMonomials, eIncoming, ePrime];

Print["HQQPRIME_BIGTMD_S01_STAGE: validating caches and evaluating local F hats"];
regularRecords = {};
Do[
  cachePath = expectedCachePaths[structureFunction, chargeKey];
  assert[FileExistsQ[cachePath] && FileByteCount[cachePath] > 0,
    "accepted S13 cache is absent or empty for " <>
      structureFunction <> "/" <> chargeKey <> "."];
  assert[fileSHA256[cachePath] ===
      expectedCacheSHA256[structureFunction, chargeKey],
    "accepted S13 cache disk hash changed for " <>
      structureFunction <> "/" <> chargeKey <> "."];
  cache = Quiet@Check[Get[cachePath], $Failed];
  assert[
    AssociationQ[cache] &&
      cache["Status"] === "Complete" &&
      cache["Stage"] === "HqqprimeS13Cache-v1" &&
      cache["ResultSchemaVersion"] === 1 &&
      cache["Channel"] === "Hqqprime only" &&
      cache["StructureFunction"] === structureFunction &&
      cache["ChargeKey"] === chargeKey &&
      cache["ProgramPath"] === s13ProgramPath &&
      cache["ProgramSHA256"] === expectedS13ProgramSHA256 &&
      cache["PaperPath"] === paperPath &&
      cache["PaperSHA256"] === expectedPaperSHA256 &&
      cache["ProjectorOrder"] === {"Pg", "PPP"} &&
      cache["PhysicalMapping"] === physicalMapping &&
      cache["IntegrationInterval"] === integrationInterval &&
      AssociationQ[cache["Checks"]] &&
      allBooleanLeavesTrueQ[cache["Checks"]],
    "S13 cache schema or embedded validation failed for " <>
      structureFunction <> "/" <> chargeKey <> "."
  ];
  pair = cache["FiniteCoefficientPair"];
  action = cache["FiniteHattedAction"];
  assert[
    AssociationQ[pair] && Keys[pair] === pairFields &&
      cache["FiniteCoefficientPairSHA256"] ===
        expectedPairSHA256[structureFunction, chargeKey] &&
      cache["FiniteCoefficientPairSHA256"] === expressionSHA256[pair] &&
      cache["FiniteCoefficientPairLeafCount"] === LeafCount[pair] &&
      cache["FiniteCoefficientPairByteCount"] === ByteCount[pair] &&
      cache["FiniteHattedActionSHA256"] ===
        expectedActionSHA256[structureFunction, chargeKey] &&
      cache["FiniteHattedActionSHA256"] === expressionSHA256[action] &&
      cache["FiniteHattedActionLeafCount"] === LeafCount[action] &&
      cache["FiniteHattedActionByteCount"] === ByteCount[action] &&
      TrueQ[pair["Endpoint"] === 0] &&
      ! TrueQ[pair["IntegrandPhiS"] === 0] &&
      TrueQ[pair["IntegrandPhi0"] === 0] &&
      FreeQ[
        {pair, action},
        epsilon | _SeriesData | _Real | FeynCalc`SUNN | $Failed |
          Indeterminate | ComplexInfinity | DirectedInfinity[_]
      ] && feynCalcContextCleanQ[{pair, action}],
    "S13 exact payload identity or regular-only gate failed for " <>
      structureFunction <> "/" <> chargeKey <> "."
  ];
  assert[
    cache["Bookkeeping", "AdditionalMultiplicativeWeightAtS13"] === 1 &&
      cache["Bookkeeping", "SeparatedChargeTensorKeys"] === chargeKeys &&
      cache["Bookkeeping",
        "PhysicalOrderedFlavorChargeAssemblyApplied"] === False &&
      cache["Bookkeeping", "ChargeBookkeepingInheritedFromS12"] ===
        bookkeeping["ChargeInheritedFromS12"] &&
      cache["Bookkeeping", "ScaleBookkeepingInheritedFromS12"] ===
        bookkeeping["ScaleInheritedFromS12"] &&
      cache["Bookkeeping", "SymmetryBookkeepingInheritedFromS12"] ===
        bookkeeping["SymmetryInheritedFromS12"] &&
      cache["Bookkeeping", "VirtualContributionAtThisOrder"] ===
        bookkeeping["VirtualContributionAtThisOrder"] &&
      cache["Bookkeeping", "HermitianProjectionAppliedAtS13"] === False,
    "S13 cache bookkeeping failed for " <>
      structureFunction <> "/" <> chargeKey <> "."
  ];
  regularExpression = pair["IntegrandPhiS"];
  Do[
    AppendTo[
      regularRecords,
      <|
        "BenchmarkID" -> benchmark["ID"],
        "ChargeKey" -> chargeKey,
        "StructureFunction" -> structureFunction,
        "Value" -> numericalValue[
          regularExpression,
          benchmark,
          "local " <> structureFunction <> "/" <> chargeKey <> "/" <>
            benchmark["ID"]
        ]
      |>
    ],
    {benchmark, benchmarks}
  ];
  Print[
    "HQQPRIME_BIGTMD_S01_CACHE_OK: " <>
      structureFunction <> "/" <> chargeKey
  ];
  Clear[cache, pair, action, regularExpression, cachePath];
  ClearSystemCache[];
  ,
  {structureFunction, structureFunctions},
  {chargeKey, chargeKeys}
];

expectedRecordCount =
  Length[benchmarks] Length[structureFunctions] Length[chargeKeys];
recordKeys = ({
    #["BenchmarkID"], #["ChargeKey"], #["StructureFunction"]
  } &) /@ regularRecords;
assert[
  Length[regularRecords] === expectedRecordCount &&
    Length[DeleteDuplicates[recordKeys]] === expectedRecordCount &&
    And@@(NumberQ[#["Value"]] & /@ regularRecords),
  "local benchmark coverage is incomplete, duplicated, or nonnumeric."
];

benchmarkIDs = Lookup[benchmarks, "ID"];
localByBenchmark = AssociationMap[
  Function[id,
    AssociationMap[
      Function[chargeKey,
        <|
          "Endpoint" -> AssociationMap[0 &, structureFunctions],
          "IntegrandPhiS" -> AssociationMap[
            Function[structureFunction,
              SelectFirst[
                regularRecords,
                #["BenchmarkID"] === id &&
                  #["ChargeKey"] === chargeKey &&
                  #["StructureFunction"] === structureFunction &
              ]["Value"]
            ],
            structureFunctions
          ],
          "IntegrandPhi0" -> AssociationMap[0 &, structureFunctions]
        |>
      ],
      chargeKeys
    ]
  ],
  benchmarkIDs
];

payload = <|
  "Status" -> "CompleteLocalHqqprimeFHatBenchmarks",
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> <|
    "Path" -> programPath,
    "SHA256" -> fileSHA256[programPath]
  |>,
  "Source" -> <|
    "Path" -> s13ResultPath,
    "ByteCount" -> FileByteCount[s13ResultPath],
    "SHA256" -> expectedS13ResultSHA256,
    "ProgramPath" -> s13ProgramPath,
    "ProgramSHA256" -> expectedS13ProgramSHA256,
    "Status" -> "Complete",
    "StageVersion" -> "HqqprimeS13-v1",
    "Channel" -> "Hqqprime only",
    "CachePaths" -> expectedCachePaths,
    "CacheSHA256" -> expectedCacheSHA256,
    "FiniteCoefficientPairSHA256" -> expectedPairSHA256,
    "FiniteHattedActionSHA256" -> expectedActionSHA256
  |>,
  "ReferenceBinding" -> <|
    "Directory" -> referenceDirectory,
    "Commit" -> expectedReferenceCommit,
    "DriverPath" -> driverPath,
    "DriverSHA256" -> expectedDriverSHA256,
    "ModulePaths" -> referenceModulePaths,
    "ModuleSHA256" -> expectedReferenceSHA256
  |>,
  "Construction" -> <|
    "Method" ->
      "exact rational substitution into six saved S13 charge-resolved coefficient pairs, then final numerical evaluation",
    "LocalSymbolicUntilFinalEvaluation" -> True,
    "EndpointAndPhi0ExactZero" -> True,
    "ReferenceDistributionContent" -> "channel-6 A/B/C regular only",
    "ExpectedComparisonCount" -> expectedRecordCount
  |>,
  "ComparisonLevel" ->
    "finite charge-resolved Hqqprime coefficient including the zeta-to-s23 Jacobian, before physical ordered-flavour/charge luminosity, outer xi convolution, and the remaining driver test factor",
  "Conventions" -> <|
    "Couplings" -> "EL=1 and g_s=1",
    "Color" -> "SU(3): CA=3, CF=4/3, TF=1/2",
    "Scale" -> "ScaleMu=Q",
    "Nf" -> 4,
    "PhysicalOrderedFlavorChargeAssembly" -> "deferred",
    "BigTMDChannel" -> 6,
    "BigTMDCaseOrder" -> caseOrder,
    "BigTMDCaseToLocalChargeKey" -> caseToCharge,
    "BigTMDPartonicModuleWeight" -> 1,
    "BigTMDDistributionContent" -> "regular only",
    "LocalJacobianAlreadyIncluded" -> True,
    "AdditionalSymmetryOrFlavorFactor" -> 1,
    "BigTMDDecimalPolicy" ->
      "S02 executes the pinned decimal Python expressions as written",
    "DifferenceDirectionExpectedByS02" -> "BigTMD minus local"
  |>,
  "Benchmarks" -> (jsonAssociation /@ benchmarks),
  "LocalFHatByBenchmark" -> localByBenchmark
|>;

Print["HQQPRIME_BIGTMD_S01_STAGE: writing compact local benchmarks"];
atomicRawJSONExport[payload, outputPath];
Print["HQQPRIME_BIGTMD_S01_SUCCESS"];
Print["HQQPRIME_BIGTMD_S01_OUTPUT=" <> outputPath];
Print["HQQPRIME_BIGTMD_S01_OUTPUT_BYTES=", FileByteCount[outputPath]];
Quit[0];

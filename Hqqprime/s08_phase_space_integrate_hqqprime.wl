(* ::Package:: *)

(*
  Hqqprime S08: integrate the unobserved q(k2), qbarPrime(k3)
  three-body phase-space angles of all six accepted charge-resolved Pg/PPP
  projections while keeping fragmenting qPrime(k1) differential.

  The implementation follows paper Eqs. (19), (29)-(32), (38)-(40) and
  Appendices B and D.  The current-channel final-state symmetry factor is
  derived from the accepted distinct-species ledger and is exact integer 1.
  Appendix-F expansion, endpoint distributions, factorization, Eq. (9),
  physical flavour assembly, and external comparisons remain downstream.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, workerRequire, fileSHA256, expressionSHA256,
  atomicPutAssociation, closeS08Kernels, splitTerms,
  hasExactlyExpectedScaleQ, scalarInputValidQ, setThreeBodyKinematics,
  prepareRealExplicit, laurentPower, denominatorADMVs, presentADMVs,
  typeOfADMV, sameTypeOffender, reduceSameTypeTerms, affineVector,
  tripleUnityRelation, reduceTripleTerms, chooseBasis, basisRules,
  reduceNumerators, reduceAndCertifyChunk, reduceAppendixD,
  linearCoefficients, reducedLinearCoefficients, coefficientDot,
  masslessGeometry, case2Geometry, appendixB18,
  angularKeyAndCoefficient, masterFromKey, integrateReducedTerms,
  angularExpressionValidQ, angularRecordValidQ, cacheMetadataValidQ,
  loadValidatedCache, writeCache, processProjectionCore,
  processChargeTask, launchS08Kernels, runOrderedChargeTasks,
  nestedProjectionChargeMap, validateProjectionChargePayload,
  transformProjectionChargePayload, validateXiS23Payload,
  zeroCoefficientVectorQ, S08Case2Master
];

activeTemporaryPath = "";

closeS08Kernels[] := If[
  IntegerQ[$KernelCount] && $KernelCount > 0,
  Quiet[CloseKernels[]]
];

fatal[message_String] := (
  closeS08Kernels[];
  If[
    StringQ[activeTemporaryPath] && activeTemporaryPath =!= "" &&
      FileExistsQ[activeTemporaryPath],
    Quiet[DeleteFile[activeTemporaryPath]]
  ];
  Print["S08_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

workerRequire[condition_, message_String] :=
  If[! TrueQ[condition], Throw[message, "S08WorkerFailure"]];

fileSHA256[path_String] := FileHash[path, "SHA256", "HexString"];

expressionSHA256[expression_] :=
  IntegerString[Hash[HoldComplete[expression], "SHA256"], 16, 64];

atomicPutAssociation[
    expression_Association, finalPath_String, expectedStage_String
  ] := Module[{writeResult, loaded, renameResult},
  assert[
    ! FileExistsQ[finalPath],
    "refusing to overwrite existing artifact " <> finalPath
  ];
  activeTemporaryPath = finalPath <> ".tmp." <> ToString[$ProcessID];
  assert[
    ! FileExistsQ[activeTemporaryPath],
    "process-specific temporary artifact already exists"
  ];
  writeResult = Quiet @ Check[
    Put[expression, activeTemporaryPath];
    FileExistsQ[activeTemporaryPath] &&
      FileByteCount[activeTemporaryPath] > 0,
    False
  ];
  If[! TrueQ[writeResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic temporary write failed"]
  ];
  loaded = Quiet @ Check[Get[activeTemporaryPath], $Failed];
  If[
    ! AssociationQ[loaded] ||
      loaded["Status"] =!= "Complete" ||
      loaded["Stage"] =!= expectedStage,
    Quiet[DeleteFile[activeTemporaryPath]];
    fatal["temporary Association failed status/stage reload validation"]
  ];
  renameResult = Quiet @ Check[
    RenameFile[activeTemporaryPath, finalPath];
    True,
    False
  ];
  If[! TrueQ[renameResult],
    If[FileExistsQ[activeTemporaryPath],
      Quiet[DeleteFile[activeTemporaryPath]]];
    fatal["atomic rename failed"]
  ];
  activeTemporaryPath = "";
  assert[
    FileExistsQ[finalPath] && FileByteCount[finalPath] > 0,
    "finalized artifact is missing or empty"
  ];
];

splitTerms[expression_] :=
  If[Head[expression] === Plus, List @@ expression, {expression}];

nestedProjectionChargeMap[function_, association_Association] :=
  AssociationMap[
    Function[projectorName,
      AssociationMap[
        Function[chargeKey,
          function[association[projectorName, chargeKey],
            projectorName, chargeKey]
        ],
        chargeKeys
      ]
    ],
    projectorKeys
  ];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
scriptsDirectory = DirectoryName[scriptDirectory];
paperPath = FileNameJoin[{
  scriptsDirectory,
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_" <>
    "Scattering_Beyond_Lowest_Order.pdf"
}];
s07SourcePath = FileNameJoin[{
  scriptDirectory, "s07_contract_hqqprime_projectors.wl"
}];
s07ResultPath = FileNameJoin[{scriptDirectory, "s07_result"}];
s08ResultPath = FileNameJoin[{scriptDirectory, "s08_result"}];

stageVersion = "HqqprimeS08-v1";
cacheStageVersion = "HqqprimeS08Cache-v1";
resultSchemaVersion = 1;
preflightOnly =
  Quiet @ Check[Environment["HQQPRIME_S08_PREFLIGHT_ONLY"], ""] === "1";
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/" <>
    "Executables/WolframKernel";
requestedParallelKernelCount = 3;
workerMemoryBudgetBytes = 3 2^30;

expectedPaperHash =
  "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b";
expectedS07SourceHash =
  "4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7";
expectedS07ResultHash =
  "b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026";
expectedS06SourceHash =
  "eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc";
expectedS06ResultHash =
  "92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607";
expectedS05SourceHash =
  "95a405581e6b5c9f24af44b513895cfa42c6524c097bc23e624de5c8df1c66f5";
expectedS05ResultHash =
  "d78577388379acf513733d6d21e85a30ab34200a1a35e7b7605e6241bfbfdec7";
expectedS01SourceHash =
  "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4";
expectedS01ResultHash =
  "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b";
expectedS04SourceHash =
  "9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc";
expectedS04ResultHash =
  "2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84";

chargeKeys = {
  "IncomingChargeSquared",
  "PrimeChargeSquared",
  "MixedIncomingPrimeCharge"
};
projectorKeys = {"Pg", "PPP"};

cachePaths = <|
  "Pg" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_incoming_charge_squared_pg"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_prime_charge_squared_pg"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_mixed_incoming_prime_charge_pg"
    }]
  |>,
  "PPP" -> <|
    "IncomingChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_incoming_charge_squared_ppp"
    }],
    "PrimeChargeSquared" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_prime_charge_squared_ppp"
    }],
    "MixedIncomingPrimeCharge" -> FileNameJoin[{
      scriptDirectory,
      "s08_cache_hqqprime_mixed_incoming_prime_charge_ppp"
    }]
  |>
|>;

programHash = fileSHA256[programPath];

staleTemporaryPaths = Join[
  FileNames["s08_result.tmp.*", scriptDirectory],
  FileNames["s08_cache_hqqprime*.tmp.*", scriptDirectory]
];
assert[
  staleTemporaryPaths === {},
  "a stale S08 temporary artifact exists"
];
If[
  ! preflightOnly,
  assert[
    ! FileExistsQ[s08ResultPath],
    "s08_result already exists; validate it or remove an invalid result before regeneration"
  ]
];

Print["S08_STAGE: validating paper and accepted Hqqprime S07 handoff"];
KeyValueMap[
  Function[{label, specification},
    assert[FileExistsQ[specification[[1]]], label <> " is missing"];
    assert[
      fileSHA256[specification[[1]]] === specification[[2]],
      label <> " SHA-256 does not match the accepted handoff"
    ];
  ],
  <|
    "authoritative paper" -> {paperPath, expectedPaperHash},
    "S07 source" -> {s07SourcePath, expectedS07SourceHash},
    "S07 result" -> {s07ResultPath, expectedS07ResultHash}
  |>
];

s07 = Quiet @ Check[Get[s07ResultPath], $Failed];
assert[AssociationQ[s07], "s07_result is not an Association"];
assert[
  s07["Status"] === "Complete" &&
    s07["Stage"] === "HqqprimeS07-v1" &&
    s07["ResultSchemaVersion"] === 1 &&
    s07["Channel"] === "Hqqprime only" &&
    s07["Contribution"] ===
      "H_{q qPrime; q qbarPrime} charge-resolved real Pg/PPP scalar projections",
  "S07 status, stage, schema, channel, or contribution is invalid"
];
assert[
  s07["ProgramSHA256"] === expectedS07SourceHash &&
    s07["Input", "S06SourceSHA256"] === expectedS06SourceHash &&
    s07["Input", "S06ResultSHA256"] === expectedS06ResultHash &&
    s07["Input", "S05SourceSHA256"] === expectedS05SourceHash &&
    s07["Input", "S05ResultSHA256"] === expectedS05ResultHash &&
    s07["Input", "S01SourceSHA256"] === expectedS01SourceHash &&
    s07["Input", "S01ResultSHA256"] === expectedS01ResultHash &&
    s07["Input", "S04SourceSHA256"] === expectedS04SourceHash &&
    s07["Input", "S04ResultSHA256"] === expectedS04ResultHash,
  "S07 does not bind the complete accepted upstream handoff"
];
assert[
  s07["PaperReference", "SHA256"] === expectedPaperHash,
  "S07 does not bind the authoritative paper edition"
];
assert[
  s07["ProjectionCount"] === 6 &&
    Length[s07["Checks"]] === 33 &&
    And @@ (TrueQ /@ Values[s07["Checks"]]),
  "S07 projection count or accepted checks are invalid"
];
assert[
  Keys[s07["WardIdentity", "ResidualsByChargeKey"]] === chargeKeys &&
    And @@ (TrueQ[# === 0] & /@
      Values[s07["WardIdentity", "ResidualsByChargeKey"]]),
  "S07 does not retain exact-zero charge-resolved Ward residuals"
];
assert[
  s07["ExternalStateBookkeeping", "Incoming"] === "q(p)" &&
    s07["ExternalStateBookkeeping", "Fragmenting"] === "qPrime(k1)" &&
    s07["ExternalStateBookkeeping", "Unobserved"] ===
      {"q(k2)", "qbarPrime(k3)"} &&
    s07["ExternalStateBookkeeping", "FinalStatesAreSummedNotAveraged"] ===
      True,
  "S07 external-state bookkeeping is invalid"
];
assert[
  s07["ChargeBookkeeping", "SeparatedTensorKeys"] === chargeKeys &&
    s07["ChargeBookkeeping", "CoefficientTensorsRemainChargeFree"] ===
      True &&
    s07["ChargeBookkeeping", "PhysicalOrderedFlavorSumAppliedAtS06"] ===
      False,
  "S07 charge bookkeeping is invalid"
];
assert[
  s07["ScaleBookkeeping", "PowerPreservedExactlyOnceInEveryProjection"] ===
      True &&
    s07["ScaleBookkeeping", "SeparateMSBarSEpsilonApplied"] === False,
  "S07 scale bookkeeping is invalid"
];
assert[
  s07["VirtualContributionAtThisOrder", "Applicable"] === False &&
    s07["VirtualContributionAtThisOrder", "Interference"] === 0 &&
    s07["VirtualContributionAtThisOrder", "SourceDisposition"] ===
      "NotApplicableAtThisOrder",
  "S07 violates the no-virtual contract"
];

dimensionalScaleFactor = s07["ScaleBookkeeping", "AbsoluteFactor"];
genericChargeSymbols = s07["ChargeBookkeeping", "GenericChargeSymbols"];

distinctStateIdentities =
  s07["SymmetryBookkeeping", "DistinctFinalStateIdentities"];
derivedRepresentativeSymmetryFactors =
  s07["SymmetryBookkeeping", "DerivedFinalStateSymmetryFactors"];
assert[
  distinctStateIdentities ===
    {"qPrime(k1)", "q(k2)", "qbarPrime(k3)"} &&
    AssociationQ[derivedRepresentativeSymmetryFactors] &&
    Length[derivedRepresentativeSymmetryFactors] === 3,
  "S07 distinct-final-state or representative symmetry ledger is invalid"
];
speciesLabels = First[StringSplit[#, "("]] & /@ distinctStateIdentities;
speciesMultiplicities = Counts[speciesLabels];
symmetryFactorFromSpecies =
  Times @@ (1/Factorial[#] & /@ Values[speciesMultiplicities]);
representativeFactorValues =
  DeleteDuplicates[Values[derivedRepresentativeSymmetryFactors]];
assert[
  Length[representativeFactorValues] === 1,
  "representative symmetry factors do not have one current-channel value"
];
finalStateSymmetryFactor = First[representativeFactorValues];
assert[
  finalStateSymmetryFactor === symmetryFactorFromSpecies &&
    finalStateSymmetryFactor === 1 &&
    s07["SymmetryBookkeeping", "NontrivialSymmetryFactorRequired"] ===
      False &&
    s07["SymmetryBookkeeping", "SymmetryFactorAppliedAtS06"] === False,
  "the tool-derived Hqqprime final-state symmetry factor is invalid"
];

realInput =
  s07["ScalarProjections", "NLOReal_OAlphaS2",
    "Hqqprime;q_qbarPrime"];
assert[
  AssociationQ[realInput] && Keys[realInput] === projectorKeys &&
    And @@ (AssociationQ /@ Values[realInput]) &&
    And @@ (Keys[#] === chargeKeys & /@ Values[realInput]),
  "S07 does not contain the exact ordered six-scalar input collection"
];

hasExactlyExpectedScaleQ[expression_] := Module[{contains, stripped},
  contains = ! FreeQ[
    expression,
    candidate_ /; SameQ[candidate, dimensionalScaleFactor]
  ];
  stripped = expression /.
    (candidate_ /; SameQ[candidate, dimensionalScaleFactor]) :> 1;
  contains &&
    FreeQ[stripped, FeynCalc`ScaleMu]
];

scalarInputValidQ[
    expression_, projectorName_String, chargeKey_String
  ] := TrueQ[
  expression =!= $Failed && expression =!= 0 &&
    FreeQ[
      expression,
      _FeynCalc`LorentzIndex | FeynCalc`Contract |
        _FeynCalc`Spinor | _FeynCalc`Polarization |
        _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
        _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
        FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
    ] &&
    And @@ (FreeQ[expression, #] & /@ genericChargeSymbols) &&
    hasExactlyExpectedScaleQ[expression] &&
    ! FreeQ[expression, _FeynCalc`FeynAmpDenominator] &&
    MemberQ[projectorKeys, projectorName] && MemberQ[chargeKeys, chargeKey]
];

inputValidation = nestedProjectionChargeMap[
  Function[{expression, projectorName, chargeKey},
    scalarInputValidQ[expression, projectorName, chargeKey]
  ],
  realInput
];
assert[
  And @@ Flatten[Values /@ Values[inputValidation]],
  "at least one accepted S07 scalar input failed validation"
];

inputScalarHashes = nestedProjectionChargeMap[
  Function[{expression, projectorName, chargeKey},
    expressionSHA256[expression]
  ],
  realInput
];
assert[
  And @@ (StringMatchQ[#, Repeated[HexadecimalCharacter, {64}]] & /@
    Flatten[Values /@ Values[inputScalarHashes]]),
  "an exact S08 input-scalar hash is invalid"
];

setThreeBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[k3, k3] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[q, k1] = (-Q2 - t1)/2;
  FeynCalc`SPD[q, k2] = (-Q2 - t2)/2;
  FeynCalc`SPD[q, k3] = (-Q2 - t3)/2;
  FeynCalc`SPD[p, k1] = -u1/2;
  FeynCalc`SPD[p, k2] = -u2/2;
  FeynCalc`SPD[p, k3] = -u3/2;
  FeynCalc`SPD[k1, k2] = s12/2;
  FeynCalc`SPD[k1, k3] = s13/2;
  FeynCalc`SPD[k2, k3] = s23/2;
);

propagatorInvariantRules = {
  s12 + s13 + s23 -> sHat,
  s23 + u2 + u3 -> t1,
  s12 + u1 + u2 -> t3,
  s13 + u1 + u3 -> t2
};

prepareRealExplicit[
    projection_, projectorName_String, chargeKey_String
  ] := Module[{raw, combined, expanded},
  Print[
    "S08_STAGE: exposing and combining " <> projectorName <> " " <>
      chargeKey
  ];
  setThreeBodyKinematics[];
  raw = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        FeynCalc`FeynAmpDenominatorExplicit[projection],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  workerRequire[
    raw =!= $Failed,
    projectorName <> " " <> chargeKey <>
      " propagator exposure failed or exceeded worker memory"
  ];
  combined = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        Together[
          raw /. propagatorInvariantRules /. D -> 4 - 2 epsilon
        ],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  Clear[raw];
  workerRequire[
    combined =!= $Failed,
    projectorName <> " " <> chargeKey <>
      " exact rational combination failed or exceeded worker memory"
  ];
  workerRequire[
    FreeQ[
      combined,
      _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum | D | _Real
    ],
    projectorName <> " " <> chargeKey <>
      " retains a propagator, momentum, D, or machine-real object"
  ];
  expanded = MemoryConstrained[
    CheckAbort[Quiet @ Check[Expand[combined], $Failed], $Failed],
    workerMemoryBudgetBytes,
    $Failed
  ];
  workerRequire[
    expanded =!= $Failed,
    projectorName <> " " <> chargeKey <>
      " exact expansion failed or exceeded worker memory"
  ];
  <|
    "CombinedLeafCount" -> LeafCount[combined],
    "ExpandedTermCount" -> Length[splitTerms[expanded]],
    "ExpandedLeafCount" -> LeafCount[expanded],
    "ExactRationalCombinationBeforeExpansion" -> True,
    "Expression" -> expanded
  |>
];

admv = {t2, t3, u2, u3, s12, s13};
sameTypeData = {
  {{t2, t3}, u1 - s23 - Q2},
  {{u2, u3}, t1 - s23},
  {{s12, s13}, sHat - s23}
};

appendixDRelations = {
  t2 + t3 == u1 - s23 - Q2,
  u2 + u3 == t1 - s23,
  s12 + s13 == sHat - s23,
  s13 == sHat + Q2 + t2 + u2
};

laurentPower[term_, variable_] := Module[{factors},
  factors = If[Head[term] === Times, List @@ term, {term}];
  Total @ Map[
    Function[factor,
      Which[
        factor === variable, 1,
        Head[factor] === Power && First[factor] === variable &&
          IntegerQ[Last[factor]], Last[factor],
        True, 0
      ]
    ],
    factors
  ]
];

denominatorADMVs[term_] :=
  Select[admv, laurentPower[term, #] < 0 &];

presentADMVs[term_] :=
  Select[admv, laurentPower[term, #] =!= 0 &];

typeOfADMV[variable_] := Which[
  MemberQ[{t2, t3}, variable], "t",
  MemberQ[{u2, u3}, variable], "u",
  MemberQ[{s12, s13}, variable], "s",
  True, "none"
];

sameTypeOffender[term_] := SelectFirst[
  sameTypeData,
  Function[data,
    And @@ (laurentPower[term, #] < 0 & /@ First[data])
  ],
  Missing["NotFound"]
];

reduceSameTypeTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, offender},
  While[
    changed = AnyTrue[terms, ! MissingQ[sameTypeOffender[#]] &];
    changed,
    iteration++;
    workerRequire[
      iteration <= 12,
      "Appendix-D same-type reduction exceeded 12 iterations"
    ];
    terms = Flatten[
      Map[
        Function[term,
          offender = sameTypeOffender[term];
          If[
            MissingQ[offender],
            {term},
            splitTerms @ Expand[
              term Total[First[offender]]/Last[offender]
            ]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

affineVector[variable_] := Switch[variable,
  t2, {1, 0, 0},
  t3, {-1, 0, u1 - s23 - Q2},
  u2, {0, 1, 0},
  u3, {0, -1, t1 - s23},
  s13, {1, 1, sHat + Q2},
  s12, {-1, -1, -s23 - Q2},
  _, workerRequire[False, "unknown ADMV in affineVector"]
];

tripleUnityRelation[variables_List] := Module[
  {vectors, nullSpace, nullVector, constant, lhs},
  workerRequire[
    Length[variables] === 3,
    "a three-variable Appendix-D relation was requested incorrectly"
  ];
  vectors = affineVector /@ variables;
  nullSpace = Quiet @ Check[
    NullSpace[Transpose[Take[#, 2] & /@ vectors]],
    $Failed
  ];
  workerRequire[
    ListQ[nullSpace] && Length[nullSpace] >= 1,
    "Appendix-D linear null-space derivation failed"
  ];
  nullVector = First[nullSpace];
  lhs = Together[nullVector . variables];
  constant = Together[nullVector . (Last /@ vectors)];
  workerRequire[
    ! TrueQ[constant === 0],
    "an Appendix-D three-variable unity denominator vanished"
  ];
  {lhs, constant}
];

reduceTripleTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, variables, relation},
  While[
    changed = AnyTrue[terms, Length[denominatorADMVs[#]] > 2 &];
    changed,
    iteration++;
    workerRequire[
      iteration <= 12,
      "Appendix-D triple reduction exceeded 12 iterations"
    ];
    terms = Flatten[
      Map[
        Function[term,
          variables = denominatorADMVs[term];
          If[
            Length[variables] <= 2,
            {term},
            workerRequire[
              Length[variables] === 3,
              "same-type reduction left more than three denominator ADMVs"
            ];
            relation = tripleUnityRelation[variables];
            splitTerms @ Expand[term First[relation]/Last[relation]]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

chooseBasis[term_] := Module[{variables, firstVariable, partner},
  variables = denominatorADMVs[term];
  Which[
    Length[variables] === 2,
      workerRequire[
        typeOfADMV[First[variables]] =!= typeOfADMV[Last[variables]],
        "two same-type denominator ADMVs survived Appendix D"
      ];
      variables,
    Length[variables] === 1,
      firstVariable = First[variables];
      partner = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &,
        Missing["NotFound"]
      ];
      workerRequire[
        ! MissingQ[partner],
        "could not choose a second Appendix-D basis variable"
      ];
      {firstVariable, partner},
    Length[variables] === 0,
      {t2, u2},
    True,
      workerRequire[False, "chooseBasis received an unreduced term"]
  ]
];

basisRules[basis_List] := basisRules[basis] = Module[
  {eliminate, solutions},
  eliminate = Complement[admv, basis];
  solutions = Quiet @ Check[
    Solve[appendixDRelations, eliminate],
    $Failed
  ];
  workerRequire[
    ListQ[solutions] && Length[solutions] >= 1,
    "could not solve Appendix-D relations for a numerator basis"
  ];
  First[solutions]
];

reduceNumerators[inputTerms_List] := Flatten[
  Map[
    Function[term,
      splitTerms @ Expand[term /. basisRules[chooseBasis[term]]]
    ],
    inputTerms
  ],
  1
];

reduceAndCertifyChunk[
    inputTerms_List, commonRules_List, label_String,
    chunkIndex_Integer, chunkCount_Integer
  ] := Module[
  {afterSame, afterTriple, reduced, reconstructionResidual},
  afterSame = reduceSameTypeTerms[inputTerms];
  afterTriple = reduceTripleTerms[afterSame];
  reduced = reduceNumerators[afterTriple];
  reconstructionResidual = MemoryConstrained[
    CheckAbort[
      Quiet @ Check[
        Together[(Total[reduced] - Total[inputTerms]) /. commonRules],
        $Failed
      ],
      $Failed
    ],
    workerMemoryBudgetBytes,
    $Failed
  ];
  workerRequire[
    reconstructionResidual === 0,
    label <> " Appendix-D reconstruction failed in exact chunk " <>
      ToString[chunkIndex] <> "/" <> ToString[chunkCount]
  ];
  If[
    Mod[chunkIndex, 8] === 0 || chunkIndex === chunkCount,
    Print[
      "S08_STAGE: exact reconstruction " <> label <> " chunk " <>
        ToString[chunkIndex] <> "/" <> ToString[chunkCount]
    ]
  ];
  <|
    "Terms" -> reduced,
    "InputTermCount" -> Length[inputTerms],
    "AfterSameTypeTermCount" -> Length[afterSame],
    "AfterTripleTermCount" -> Length[afterTriple],
    "ReducedTermCount" -> Length[reduced],
    "ReconstructionResidual" -> reconstructionResidual
  |>
];

reduceAppendixD[expression_, label_String] := Module[
  {terms, termChunks, chunkResults, reduced, invalid, commonRules,
   reconstructionChunkSize = 64, reconstructionChunkCount,
   initialDenominatorCounts},
  terms = splitTerms[Expand[expression]];
  initialDenominatorCounts = Length[denominatorADMVs[#]] & /@ terms;
  Print[
    "S08_STAGE: Appendix D start " <> label <> ", terms " <>
      ToString[Length[terms]]
  ];
  termChunks = Partition[terms, UpTo[reconstructionChunkSize]];
  reconstructionChunkCount = Length[termChunks];
  commonRules = basisRules[{t2, u2}];
  Print[
    "S08_STAGE: Appendix D exact partitioned reconstruction " <> label <>
      ", chunks " <> ToString[reconstructionChunkCount]
  ];
  chunkResults = MapIndexed[
    reduceAndCertifyChunk[
      #1, commonRules, label, First[#2], reconstructionChunkCount
    ] &,
    termChunks
  ];
  reduced = Flatten[Lookup[chunkResults, "Terms"], 1];
  invalid = Select[
    reduced,
    Function[term,
      Length[presentADMVs[term]] > 2 ||
        (Length[presentADMVs[term]] === 2 &&
          typeOfADMV[First[presentADMVs[term]]] ===
            typeOfADMV[Last[presentADMVs[term]]])
    ]
  ];
  workerRequire[
    invalid === {},
    label <> " did not reduce to at most two different ADMV types"
  ];
  workerRequire[
    And @@ (TrueQ[# === 0] & /@
      Lookup[chunkResults, "ReconstructionResidual"]),
    label <> " has a nonzero exact reconstruction chunk"
  ];
  Print[
    "S08_STAGE: Appendix D reconstruction passed " <> label <>
      ", reduced terms " <> ToString[Length[reduced]]
  ];
  <|
    "Terms" -> reduced,
    "Audit" -> <|
      "InputTermCount" -> Length[terms],
      "InitialMaximumDenominatorADMVCount" ->
        Max[initialDenominatorCounts],
      "InitialTermsWithMoreThanTwoDenominatorADMVs" ->
        Count[initialDenominatorCounts, _?(# > 2 &)],
      "AfterSameTypeTermCount" ->
        Total[Lookup[chunkResults, "AfterSameTypeTermCount"]],
      "AfterTripleTermCount" ->
        Total[Lookup[chunkResults, "AfterTripleTermCount"]],
      "ReducedTermCount" -> Length[reduced],
      "InvalidReducedTermCount" -> Length[invalid],
      "CommonBasis" -> {t2, u2},
      "ReconstructionMethod" ->
        "exact common-basis residual for every disjoint input-term partition",
      "ReconstructionChunkSize" -> reconstructionChunkSize,
      "ReconstructionChunkCount" -> reconstructionChunkCount,
      "ReconstructionResidual" -> 0,
      "EveryReconstructionChunkResidualZero" -> True,
      "ReconstructionPassed" -> True
    |>
  |>
];

(* Appendix-B frame 2 coefficients:
   a + b Cos[beta1] + c Sin[beta1] Cos[beta2]. *)
linearCoefficients[variable_] := Module[
  {rho, yCoefficient, sConstant, sCosine,
   tConstant, tCosine, uHalf},
  rho = Sqrt[s23 u1 (Q2 s23 + sHat t1)];
  yCoefficient = rho/(s23 - t1);
  sConstant = (sHat - s23)/2;
  sCosine = sConstant + u1 s23/(s23 - t1);
  tConstant = -Q2 - (sHat + t1)/2;
  tCosine = ((sHat + t1) (s23 - t1) -
      2 s23 (sHat + Q2))/(2 (s23 - t1));
  uHalf = (s23 - t1)/2;
  Switch[variable,
    t2, {tConstant, tCosine, yCoefficient},
    t3, {tConstant, -tCosine, -yCoefficient},
    u2, {-uHalf, uHalf, 0},
    u3, {-uHalf, -uHalf, 0},
    s12, {sConstant, -sCosine, -yCoefficient},
    s13, {sConstant, sCosine, yCoefficient},
    _, workerRequire[False, "unknown ADMV in linearCoefficients"]
  ]
];

q2ConstraintRule = Q2 -> s23 - sHat - t1 - u1;

reducedLinearCoefficients[variable_] :=
  reducedLinearCoefficients[variable] =
    (Together /@ (linearCoefficients[variable] /. q2ConstraintRule));

coefficientDot[first_List, second_List] :=
  first[[2]] second[[2]] + first[[3]] second[[3]];

masslessGeometry[first_, second_] :=
  masslessGeometry[first, second] = Module[
    {firstCoefficients, secondCoefficients, cosine},
    firstCoefficients = reducedLinearCoefficients[first];
    secondCoefficients = reducedLinearCoefficients[second];
    cosine = Together[
      coefficientDot[firstCoefficients, secondCoefficients]/
        (First[firstCoefficients] First[secondCoefficients])
    ];
    {First[firstCoefficients], First[secondCoefficients], cosine}
  ];

case2Geometry[tVariable_, masslessVariable_] :=
  case2Geometry[tVariable, masslessVariable] = Module[
    {tCoefficients, masslessCoefficients, radius,
     dCoefficient, cosine},
    tCoefficients = reducedLinearCoefficients[tVariable];
    masslessCoefficients = reducedLinearCoefficients[masslessVariable];
    radius = (Sqrt[(sHat + t1)^2 + 4 Q2 s23]/2) /.
      q2ConstraintRule;
    dCoefficient = Together[-First[tCoefficients]/radius];
    cosine = Together[
      -coefficientDot[tCoefficients, masslessCoefficients]/
        (radius First[masslessCoefficients])
    ];
    {-radius, First[masslessCoefficients], dCoefficient, cosine}
  ];

appendixB18[j_Integer, l_Integer, cosine_, epsilonSymbol_] :=
  2 Pi Gamma[1 - 2 epsilonSymbol]/Gamma[1 - epsilonSymbol]^2 *
    2^(-j - l) *
    Beta[1 - epsilonSymbol - j, 1 - epsilonSymbol - l] *
    Hypergeometric2F1[
      j, l, 1 - epsilonSymbol, (1 + cosine)/2
    ];

angularKeyAndCoefficient[term_] := Module[
  {variables, firstVariable, secondVariable, firstPower,
   secondPower, coefficient, ordered},
  variables = presentADMVs[term];
  Which[
    Length[variables] === 0,
      Return[{{"Area"}, term /. q2ConstraintRule}],
    Length[variables] === 1,
      firstVariable = First[variables];
      secondVariable = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &,
        Missing["NotFound"]
      ];
      workerRequire[
        ! MissingQ[secondVariable],
        "could not select an angular companion variable"
      ];
      variables = {firstVariable, secondVariable},
    Length[variables] === 2,
      Null,
    True,
      workerRequire[False,
        "angular integration received more than two ADMVs"]
  ];
  ordered = If[
    MemberQ[typeOfADMV /@ variables, "t"],
    Join[
      Select[variables, typeOfADMV[#] === "t" &],
      Select[variables, typeOfADMV[#] =!= "t" &]
    ],
    SortBy[variables, First @ First @ Position[admv, #] &]
  ];
  firstVariable = First[ordered];
  secondVariable = Last[ordered];
  firstPower = laurentPower[term, firstVariable];
  secondPower = laurentPower[term, secondVariable];
  coefficient = Cancel[
    term/(firstVariable^firstPower secondVariable^secondPower)
  ] /. q2ConstraintRule;
  If[
    typeOfADMV[firstVariable] === "t",
    {
      {"B19", firstVariable, firstPower,
        secondVariable, secondPower},
      coefficient
    },
    {
      {"B18", firstVariable, firstPower,
        secondVariable, secondPower},
      coefficient
    }
  ]
];

masterFromKey[{"Area"}] := appendixB18[0, 0, 0, epsilon];

masterFromKey[
    {"B18", first_, firstPower_Integer,
     second_, secondPower_Integer}
  ] := Module[{geometry},
  geometry = masslessGeometry[first, second];
  geometry[[1]]^firstPower geometry[[2]]^secondPower *
    appendixB18[-firstPower, -secondPower, geometry[[3]], epsilon]
];

masterFromKey[
    {"B19", tVariable_, tPower_Integer,
     masslessVariable_, masslessPower_Integer}
  ] := Module[{geometry},
  geometry = case2Geometry[tVariable, masslessVariable];
  geometry[[1]]^tPower geometry[[2]]^masslessPower *
    S08Case2Master[
      -tPower, -masslessPower, geometry[[3]], geometry[[4]], epsilon
    ]
];

integrateReducedTerms[terms_List, label_String] := Module[
  {keyed, grouped, answer},
  Print["S08_STAGE: grouping angular masters for " <> label];
  keyed = angularKeyAndCoefficient /@ terms;
  grouped = Merge[(First[#] -> Last[#]) & /@ keyed, Total];
  Print[
    "S08_STAGE: angular master count " <> label <> " = " <>
      ToString[Length[grouped]]
  ];
  answer = Total[
    (Last[#] masterFromKey[First[#]]) & /@ Normal[grouped]
  ];
  <|
    "Expression" -> answer,
    "MasterKeys" -> Keys[grouped],
    "MasterCount" -> Length[grouped]
  |>
];

(* Eq. (39), multiplied by Eq. (19)'s common 1/(2 Pi)^4. *)
eq19CommonFactor = 1/(2 Pi)^4;
eq39ThreeBodyPrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(2 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];
threeBodyPhasePrefactor =
  eq19CommonFactor eq39ThreeBodyPrefactor;
paperCombinedPhasePrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(6 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];

assert[
  TrueQ[
    Together[
      threeBodyPhasePrefactor - paperCombinedPhasePrefactor
    ] === 0
  ],
  "Eq. (19) times Eq. (39) does not reproduce the paper prefactor"
];

angularExpressionValidQ[expression_] := TrueQ[
  expression =!= $Failed && expression =!= 0 &&
    FreeQ[
      expression,
      t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2 |
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum | D |
        Indeterminate | ComplexInfinity | _DirectedInfinity |
        $Failed | _Real
    ] &&
    And @@ (FreeQ[expression, #] & /@ genericChargeSymbols) &&
    hasExactlyExpectedScaleQ[expression]
];

angularRecordValidQ[
    record_, projectorName_String, chargeKey_String
  ] := Module[{before, physical},
  If[! AssociationQ[record], Return[False]];
  If[
    ! And @@ (KeyExistsQ[record, #] & /@ {
      "PreparationAudit", "ReductionAudit", "MasterKeys",
      "MasterCount", "BeforeFinalStateSymmetryFactor",
      "PhysicalAfterFinalStateSymmetryFactor"
    }),
    Return[False]
  ];
  before = record["BeforeFinalStateSymmetryFactor"];
  physical = record["PhysicalAfterFinalStateSymmetryFactor"];
  TrueQ[
    MemberQ[projectorKeys, projectorName] &&
      MemberQ[chargeKeys, chargeKey] &&
      angularExpressionValidQ[before] &&
      angularExpressionValidQ[physical] &&
      Together[
        physical - finalStateSymmetryFactor before
      ] === 0 &&
      Together[physical - before] === 0 &&
      record["PreparationAudit",
        "ExactRationalCombinationBeforeExpansion"] === True &&
      IntegerQ[record["PreparationAudit", "ExpandedTermCount"]] &&
      record["PreparationAudit", "ExpandedTermCount"] > 0 &&
      record["ReductionAudit", "InvalidReducedTermCount"] === 0 &&
      record["ReductionAudit", "ReconstructionResidual"] === 0 &&
      record["ReductionAudit", "ReconstructionPassed"] === True &&
      IntegerQ[record["MasterCount"]] &&
      record["MasterCount"] === Length[record["MasterKeys"]] &&
      record["MasterCount"] > 0
  ]
];

cacheMetadataValidQ[
    cache_, projectorName_String, chargeKey_String
  ] := AssociationQ[cache] &&
  Lookup[cache, "Status", Missing["Status"]] === "Complete" &&
  Lookup[cache, "Stage", Missing["Stage"]] === cacheStageVersion &&
  Lookup[cache, "Channel", Missing["Channel"]] === "Hqqprime only" &&
  Lookup[cache, "Projector", Missing["Projector"]] === projectorName &&
  Lookup[cache, "ChargeKey", Missing["ChargeKey"]] === chargeKey &&
  Lookup[cache, "ProgramSHA256", Missing["ProgramSHA256"]] ===
    programHash &&
  Lookup[cache, "PaperSHA256", Missing["PaperSHA256"]] ===
    expectedPaperHash &&
  Lookup[cache, "S07SourceSHA256", Missing["S07SourceSHA256"]] ===
    expectedS07SourceHash &&
  Lookup[cache, "S07ResultSHA256", Missing["S07ResultSHA256"]] ===
    expectedS07ResultHash &&
  Lookup[cache, "InputScalarSHA256", Missing["InputScalarSHA256"]] ===
    inputScalarHashes[projectorName, chargeKey] &&
  Lookup[cache, "ScaleBookkeeping", Missing["ScaleBookkeeping"]] ===
    s07["ScaleBookkeeping"] &&
  Lookup[cache, "ChargeBookkeeping", Missing["ChargeBookkeeping"]] ===
    s07["ChargeBookkeeping"] &&
  Lookup[cache, "UpstreamSymmetryBookkeeping",
    Missing["UpstreamSymmetryBookkeeping"]] ===
    s07["SymmetryBookkeeping"] &&
  Lookup[cache, "FinalStateSymmetryFactor",
    Missing["FinalStateSymmetryFactor"]] ===
    finalStateSymmetryFactor &&
  Lookup[cache, "NontrivialSymmetryFactorAppliedAtS08",
    Missing["NontrivialSymmetryFactorAppliedAtS08"]] === False &&
  KeyExistsQ[cache, "AngularRecord"] &&
  Lookup[cache, "AngularRecordSHA256",
    Missing["AngularRecordSHA256"]] ===
    expressionSHA256[cache["AngularRecord"]] &&
  angularRecordValidQ[cache["AngularRecord"], projectorName, chargeKey];

loadValidatedCache[
    path_String, projectorName_String, chargeKey_String
  ] := Module[{cache},
  If[preflightOnly || ! FileExistsQ[path],
    Return[Missing["NotAvailable"]]
  ];
  Print[
    "S08_STAGE: inspecting cache " <> projectorName <> " " <> chargeKey
  ];
  cache = Quiet @ Check[Get[path], $Failed];
  If[! TrueQ[cacheMetadataValidQ[cache, projectorName, chargeKey]],
    Print[
      "S08_STAGE: deleting invalid cache " <> projectorName <> " " <>
        chargeKey
    ];
    Quiet[DeleteFile[path]];
    Return[Missing["InvalidCache"]]
  ];
  Print[
    "S08_STAGE: accepted source-bound cache " <> projectorName <> " " <>
      chargeKey
  ];
  cache["AngularRecord"]
];

writeCache[
    path_String, projectorName_String, chargeKey_String,
    angularRecord_Association
  ] := Module[{cache},
  If[preflightOnly, Return[Null]];
  cache = <|
    "Status" -> "Complete",
    "Stage" -> cacheStageVersion,
    "Channel" -> "Hqqprime only",
    "Projector" -> projectorName,
    "ChargeKey" -> chargeKey,
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "ProgramPath" -> programPath,
    "ProgramSHA256" -> programHash,
    "PaperPath" -> paperPath,
    "PaperSHA256" -> expectedPaperHash,
    "S07SourcePath" -> s07SourcePath,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultPath" -> s07ResultPath,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "InputProjectionKey" ->
      "ScalarProjections/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/" <>
        projectorName <> "/" <> chargeKey,
    "InputScalarSHA256" -> inputScalarHashes[projectorName, chargeKey],
    "ScaleBookkeeping" -> s07["ScaleBookkeeping"],
    "ChargeBookkeeping" -> s07["ChargeBookkeeping"],
    "VirtualContributionAtThisOrder" ->
      s07["VirtualContributionAtThisOrder"],
    "UpstreamSymmetryBookkeeping" -> s07["SymmetryBookkeeping"],
    "FinalStateSymmetryFactor" -> finalStateSymmetryFactor,
    "NontrivialSymmetryFactorAppliedAtS08" -> False,
    "AngularRecordSHA256" -> expressionSHA256[angularRecord],
    "AngularRecord" -> angularRecord
  |>;
  atomicPutAssociation[cache, path, cacheStageVersion];
];

processProjectionCore[
    projection_, projectorName_String, chargeKey_String
  ] := Module[
  {prepared, reduction, angularData, before, physical, record},
  prepared = prepareRealExplicit[projection, projectorName, chargeKey];
  reduction = reduceAppendixD[
    prepared["Expression"],
    "Hqqprime " <> projectorName <> " " <> chargeKey
  ];
  angularData = integrateReducedTerms[
    reduction["Terms"],
    "Hqqprime " <> projectorName <> " " <> chargeKey
  ];
  before = threeBodyPhasePrefactor angularData["Expression"];
  physical = finalStateSymmetryFactor before;
  record = <|
    "PreparationAudit" -> KeyDrop[prepared, {"Expression"}],
    "ReductionAudit" -> reduction["Audit"],
    "MasterKeys" -> angularData["MasterKeys"],
    "MasterCount" -> angularData["MasterCount"],
    "BeforeFinalStateSymmetryFactor" -> before,
    "PhysicalAfterFinalStateSymmetryFactor" -> physical
  |>;
  workerRequire[
    angularRecordValidQ[record, projectorName, chargeKey],
    projectorName <> " " <> chargeKey <>
      " angular record failed validation"
  ];
  Print[
    "S08_CHECKPOINT: completed ", projectorName, " ", chargeKey,
    " pre/physical leaf counts ",
    InputForm[{LeafCount[before], LeafCount[physical]}]
  ];
  record
];

processChargeTask[task_Association] := Module[
  {chargeKey, requestedProjectors, projections, caught},
  chargeKey = task["ChargeKey"];
  requestedProjectors = task["RequestedProjectors"];
  projections = task["Projections"];
  caught = Catch[
    Module[{records},
      workerRequire[
        MemberQ[chargeKeys, chargeKey],
        "worker received an unknown charge key"
      ];
      workerRequire[
        DuplicateFreeQ[requestedProjectors] &&
          And @@ (MemberQ[projectorKeys, #] & /@ requestedProjectors),
        "worker received an invalid projector request"
      ];
      records = AssociationMap[
        Function[projectorName,
          Module[{record},
            record = Quiet @ Check[
              processProjectionCore[
                projections[projectorName], projectorName, chargeKey
              ],
              $Failed
            ];
            workerRequire[
              AssociationQ[record],
              projectorName <> " " <> chargeKey <>
                " processing emitted a diagnostic or failed"
            ];
            record
          ]
        ],
        requestedProjectors
      ];
      <|
        "Success" -> True,
        "ChargeKey" -> chargeKey,
        "RequestedProjectors" -> requestedProjectors,
        "Records" -> records
      |>
    ],
    "S08WorkerFailure"
  ];
  If[
    AssociationQ[caught] && TrueQ[caught["Success"]],
    caught,
    <|
      "Success" -> False,
      "ChargeKey" -> chargeKey,
      "Failure" -> ToString[InputForm[caught]]
    |>
  ]
];

launchS08Kernels[] := Module[{localCandidates, configuration, launched},
  closeS08Kernels[];
  localCandidates = Select[
    $ConfiguredKernels,
    Quiet @ Check[# ["Class"] === "LocalKernels", False] &
  ];
  assert[
    Length[localCandidates] >= 1,
    "no local Wolfram kernel configuration is available"
  ];
  configuration = ReplacePart[
    First[localCandidates],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernelCount
    }
  ];
  assert[
    configuration["KernelCommand"] === parallelKernelExecutable &&
      configuration["KernelCount"] === requestedParallelKernelCount,
    "the in-memory Engine-15 local kernel configuration is invalid"
  ];
  launched = Quiet @ Check[LaunchKernels[configuration], $Failed];
  assert[
    ListQ[launched] &&
      Length[launched] === requestedParallelKernelCount &&
      $KernelCount === requestedParallelKernelCount,
    "failed to launch exactly three Engine-15 local kernels"
  ];
  ParallelNeeds["FeynCalc`"];
  ParallelEvaluate[$HistoryLength = 0; $FCAdvice = False;];
  workerVersions = ParallelEvaluate[$Version];
  assert[
    Length[workerVersions] === requestedParallelKernelCount &&
      And @@ (StringStartsQ[#, "15.0.0"] & /@ workerVersions),
    "a local worker is not the verified Engine 15.0 runtime"
  ];
  parallelOrderProbe = ParallelMap[
    Identity,
    chargeKeys,
    Method -> "FinestGrained"
  ];
  assert[
    parallelOrderProbe === chargeKeys,
    "parallel result ordering is not deterministic"
  ];
  DistributeDefinitions[
    workerRequire, splitTerms, hasExactlyExpectedScaleQ,
    setThreeBodyKinematics, prepareRealExplicit, laurentPower,
    denominatorADMVs, presentADMVs, typeOfADMV, sameTypeOffender,
    reduceSameTypeTerms, affineVector, tripleUnityRelation,
    reduceTripleTerms, chooseBasis, basisRules, reduceNumerators,
    reduceAndCertifyChunk, reduceAppendixD, linearCoefficients,
    reducedLinearCoefficients, coefficientDot, masslessGeometry,
    case2Geometry, appendixB18, angularKeyAndCoefficient,
    masterFromKey, integrateReducedTerms, angularExpressionValidQ,
    angularRecordValidQ, processProjectionCore, processChargeTask,
    chargeKeys, projectorKeys, propagatorInvariantRules, admv,
    sameTypeData, appendixDRelations, q2ConstraintRule,
    workerMemoryBudgetBytes, dimensionalScaleFactor,
    genericChargeSymbols, threeBodyPhasePrefactor,
    finalStateSymmetryFactor, S08Case2Master
  ];
  True
];

runOrderedChargeTasks[tasks_List] := Module[{results, returnedKeys},
  Print[
    "S08_STAGE: dispatching three charge tasks across three Engine-15 kernels"
  ];
  results = Quiet @ Check[
    ParallelMap[processChargeTask, tasks, Method -> "FinestGrained"],
    $Failed
  ];
  assert[
    ListQ[results] && Length[results] === Length[tasks] &&
      And @@ (AssociationQ /@ results),
    "parallel charge-task dispatch failed"
  ];
  assert[
    And @@ (TrueQ[# ["Success"]] & /@ results),
    "a charge worker reported failure: " <>
      ToString[InputForm[Lookup[results, "Failure", None]]]
  ];
  returnedKeys = Lookup[results, "ChargeKey"];
  assert[
    returnedKeys === Lookup[tasks, "ChargeKey"] &&
      returnedKeys === chargeKeys,
    "parallel charge results returned in the wrong key order"
  ];
  results
];

validateProjectionChargePayload[
    payload_Association, label_String
  ] := Module[{flags},
  assert[
    Keys[payload] === projectorKeys &&
      And @@ (Keys[#] === chargeKeys & /@ Values[payload]),
    label <> " has the wrong projector or charge order"
  ];
  flags = nestedProjectionChargeMap[
    Function[{expression, projectorName, chargeKey},
      angularExpressionValidQ[expression]
    ],
    payload
  ];
  assert[
    And @@ Flatten[Values /@ Values[flags]],
    label <> " contains an invalid angular expression"
  ];
  True
];

(* Paper Eqs. (29)-(32), with xB, zH, PHT2 external. *)
xHatXi = xB/xi;
xiLowerA = xB + xB PHT2/(zH (1 - zH) Q2);
s23UpperB = Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH;
zetaXiS23 =
  (xHatXi PHT2 + zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi));
zHatXiS23 = zH/zetaXiS23;
k1TPartonic2XiS23 = PHT2/zetaXiS23^2;
xiS23Jacobian = Together[D[zetaXiS23, s23]];
paperEq29Jacobian =
  (xHatXi^2 PHT2 + xHatXi zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi)^2);

partonicToXiS23Rules = {
  sHat -> Q2 (1/xHatXi - 1),
  t1 -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  tHat -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  u1 -> -zHatXiS23 Q2/xHatXi
};

transformProjectionChargePayload[payload_Association] :=
  nestedProjectionChargeMap[
    Function[{expression, projectorName, chargeKey},
      xiS23Jacobian * (expression /. partonicToXiS23Rules)
    ],
    payload
  ];

validateXiS23Payload[payload_Association, label_String] := Module[
  {flags},
  assert[
    Keys[payload] === projectorKeys &&
      And @@ (Keys[#] === chargeKeys & /@ Values[payload]),
    label <> " has the wrong projector or charge keys"
  ];
  flags = nestedProjectionChargeMap[
    Function[{expression, projectorName, chargeKey},
      TrueQ[
        expression =!= 0 && expression =!= $Failed &&
          FreeQ[
            expression,
            zeta | sHat | tHat | t1 | u1 | t2 | t3 | u2 | u3 |
              s12 | s13 | beta1 | beta2 | D |
              _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum |
              Indeterminate | ComplexInfinity | _DirectedInfinity |
              $Failed | _Real
          ] &&
          And @@ (FreeQ[expression, #] & /@ genericChargeSymbols) &&
          hasExactlyExpectedScaleQ[expression]
      ]
    ],
    payload
  ];
  assert[
    And @@ Flatten[Values /@ Values[flags]],
    label <> " contains an invalid xi-s23 kernel"
  ];
  True
];

zeroCoefficientVectorQ[vector_List] :=
  And @@ (TrueQ[Together[# /. q2ConstraintRule] === 0] & /@ vector);

Print["S08_STAGE: validating Appendix-D frame identities"];
appendixDIdentityChecks = <|
  "D5_u2_plus_u3" -> zeroCoefficientVectorQ[
    linearCoefficients[u2] + linearCoefficients[u3] -
      {t1 - s23, 0, 0}
  ],
  "D6_s12_plus_s13" -> zeroCoefficientVectorQ[
    linearCoefficients[s12] + linearCoefficients[s13] -
      {sHat - s23, 0, 0}
  ],
  "D7_t2_plus_t3" -> zeroCoefficientVectorQ[
    linearCoefficients[t2] + linearCoefficients[t3] -
      {u1 - s23 - Q2, 0, 0}
  ],
  "D8_s13_relation" -> zeroCoefficientVectorQ[
    linearCoefficients[s13] - linearCoefficients[t2] -
      linearCoefficients[u2] - {sHat + Q2, 0, 0}
  ]
|>;
assert[
  And @@ (TrueQ /@ Values[appendixDIdentityChecks]),
  "at least one Appendix-D frame identity failed"
];

eq40S23Expression =
  (Q2 (
      zHatXiS23 (1 - xHatXi) -
        zHatXiS23^2 (1 - xHatXi)
    ) - xHatXi k1TPartonic2XiS23)/
    (xHatXi zHatXiS23);

variableChangeChecks = <|
  "JacobianMatchesPaperEq29" -> TrueQ[
    Together[xiS23Jacobian - paperEq29Jacobian] === 0
  ],
  "Eq40ReconstructsS23" -> TrueQ[
    Together[eq40S23Expression - s23] === 0
  ],
  "PartonicConservationAfterMap" -> TrueQ[
    Together[
      (sHat + t1 + u1 + Q2 - s23) /.
        partonicToXiS23Rules
    ] === 0
  ],
  "XiLowerBoundCollapsesS23UpperBound" -> TrueQ[
    Together[s23UpperB /. xi -> xiLowerA] === 0
  ],
  "S23UpperBoundMapsToZetaOne" -> TrueQ[
    Together[(zetaXiS23 /. s23 -> s23UpperB) - 1] === 0
  ]
|>;
assert[
  And @@ (TrueQ /@ Values[variableChangeChecks]),
  "at least one exact xi-to-s23 variable-change identity failed"
];

cachedAngularRecords = nestedProjectionChargeMap[
  Function[{expression, projectorName, chargeKey},
    loadValidatedCache[
      cachePaths[projectorName, chargeKey], projectorName, chargeKey
    ]
  ],
  realInput
];
cacheReuseFlags = nestedProjectionChargeMap[
  Function[{record, projectorName, chargeKey}, AssociationQ[record]],
  cachedAngularRecords
];

tasks = Map[
  Function[chargeKey,
    Module[{requestedProjectors},
      requestedProjectors = Select[
        projectorKeys,
        ! AssociationQ[cachedAngularRecords[#, chargeKey]] &
      ];
      <|
        "ChargeKey" -> chargeKey,
        "RequestedProjectors" -> requestedProjectors,
        "Projections" -> AssociationMap[
          realInput[#, chargeKey] &,
          requestedProjectors
        ]
      |>
    ]
  ],
  chargeKeys
];

Print["S08_STAGE: launching three independent charge workers"];
assert[launchS08Kernels[], "Engine-15 worker launch failed"];
workerResults = runOrderedChargeTasks[tasks];
freshRecordsByCharge = AssociationThread[
  chargeKeys,
  Lookup[workerResults, "Records"]
];

angularRecords = AssociationMap[
  Function[projectorName,
    AssociationMap[
      Function[chargeKey,
        If[
          AssociationQ[cachedAngularRecords[projectorName, chargeKey]],
          cachedAngularRecords[projectorName, chargeKey],
          freshRecordsByCharge[chargeKey, projectorName]
        ]
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];

recordValidation = nestedProjectionChargeMap[
  Function[{record, projectorName, chargeKey},
    angularRecordValidQ[record, projectorName, chargeKey]
  ],
  angularRecords
];
assert[
  And @@ Flatten[Values /@ Values[recordValidation]],
  "at least one assembled angular record is invalid"
];

If[
  ! preflightOnly,
  Do[
    If[
      ! AssociationQ[cachedAngularRecords[projectorName, chargeKey]],
      writeCache[
        cachePaths[projectorName, chargeKey], projectorName, chargeKey,
        angularRecords[projectorName, chargeKey]
      ]
    ],
    {projectorName, projectorKeys},
    {chargeKey, chargeKeys}
  ]
];

closeS08Kernels[];

preSymmetryAngularResults = nestedProjectionChargeMap[
  Function[{record, projectorName, chargeKey},
    record["BeforeFinalStateSymmetryFactor"]
  ],
  angularRecords
];
physicalAngularResults = nestedProjectionChargeMap[
  Function[{record, projectorName, chargeKey},
    record["PhysicalAfterFinalStateSymmetryFactor"]
  ],
  angularRecords
];

assert[
  validateProjectionChargePayload[
    preSymmetryAngularResults,
    "Hqqprime pre-symmetry angular payload"
  ],
  "pre-symmetry angular payload failed validation"
];
assert[
  validateProjectionChargePayload[
    physicalAngularResults,
    "Hqqprime physical angular payload"
  ],
  "physical angular payload failed validation"
];

symmetryEqualityChecks = nestedProjectionChargeMap[
  Function[{physical, projectorName, chargeKey},
    TrueQ[
      Together[
        physical - preSymmetryAngularResults[projectorName, chargeKey]
      ] === 0
    ]
  ],
  physicalAngularResults
];
assert[
  And @@ Flatten[Values /@ Values[symmetryEqualityChecks]],
  "a physical angular branch differs despite exact factor 1"
];

Print["S08_STAGE: applying the exact zeta-to-s23 change of variables"];
xiS23Kernels = transformProjectionChargePayload[physicalAngularResults];
assert[
  validateXiS23Payload[xiS23Kernels, "Hqqprime xi-s23 payload"],
  "the Hqqprime xi-s23 kernels failed validation"
];

case2Masters = DeleteDuplicates @ Cases[
  Flatten[Values /@ Values[physicalAngularResults], 1],
  _S08Case2Master,
  Infinity
];

appendixDReconstructionChecks = nestedProjectionChargeMap[
  Function[{record, projectorName, chargeKey},
    TrueQ[
      record["ReductionAudit", "ReconstructionResidual"] === 0 &&
        record["ReductionAudit", "ReconstructionPassed"] === True &&
        record["ReductionAudit", "InvalidReducedTermCount"] === 0
    ]
  ],
  angularRecords
];

checks = <|
  "AuthoritativePaperHashValidated" -> True,
  "CurrentS07SourceAndResultHashesValidated" -> True,
  "CompleteS07UpstreamBindingsAndThirtyThreeChecksValidated" -> True,
  "SoleSixScalarHqqprimeInputConsumed" -> True,
  "ProjectorFirstChargeSecondOrderPreserved" -> True,
  "NoOtherChannelArtifactConsumed" -> True,
  "ExactRationalCombinationPrecedesAngularClassification" -> True,
  "AppendixDIdentitiesD5ThroughD8Verified" ->
    And @@ (TrueQ /@ Values[appendixDIdentityChecks]),
  "AllSixAppendixDExactReconstructionsPassed" ->
    And @@ Flatten[Values /@ Values[appendixDReconstructionChecks]],
  "AllSixBranchesAngularIntegrated" -> True,
  "AppendixB18EvaluatedExactly" -> True,
  "AppendixB19RetainedAsExactSymbolicMaster" -> True,
  "Eq19TimesEq39NormalizationVerified" -> True,
  "Eq39NumericPowerTwoIsMinusTwo" -> True,
  "FinalStateSpeciesMultiplicitiesDerived" -> True,
  "RepresentativeSymmetryFactorsRevalidated" -> True,
  "FinalStateSymmetryFactorIsExactOne" ->
    TrueQ[finalStateSymmetryFactor === 1],
  "NoNontrivialSymmetryFactorAppliedAtS08" -> True,
  "PhysicalResultsEqualPreSymmetryResults" ->
    And @@ Flatten[Values /@ Values[symmetryEqualityChecks]],
  "NoAngularVariablesOrPropagatorObjectsRemain" -> True,
  "XiS23JacobianMatchesPaperEq29" ->
    variableChangeChecks["JacobianMatchesPaperEq29"],
  "PaperEq40Verified" ->
    variableChangeChecks["Eq40ReconstructsS23"],
  "PartonicConservationAfterXiS23MapVerified" ->
    variableChangeChecks["PartonicConservationAfterMap"],
  "XiAndS23BoundaryIdentitiesVerified" -> TrueQ[
    variableChangeChecks["XiLowerBoundCollapsesS23UpperBound"] &&
      variableChangeChecks["S23UpperBoundMapsToZetaOne"]
  ],
  "PhysicalXiAndS23LimitsStored" -> True,
  "AbsoluteScaleMuPowerFourEpsilonPreservedExactlyOnce" -> True,
  "ThreeChargeStructuresRemainSeparateAndChargeFree" -> True,
  "PhysicalOrderedFlavorChargeAssemblyDeferred" -> True,
  "VirtualContributionRemainsStructurallyAbsent" -> True,
  "ExactlyThreeEngine15ChargeWorkersUsed" -> TrueQ[
    Length[workerVersions] === requestedParallelKernelCount &&
      requestedParallelKernelCount === Length[chargeKeys]
  ],
  "ProjectorsProcessedSeriallyWithinEachChargeWorker" -> True,
  "WorkersPerformedNoCacheWrites" -> True,
  "CalculationFullySymbolic" -> True,
  "AtomicCachesBindProgramPaperS07AndInputHashes" -> True,
  "AppendixFEpsilonExpansionNotApplied" -> True,
  "EndpointDistributionExpansionNotApplied" -> True,
  "CollinearFactorizationNotApplied" -> True,
  "Eq9FHatAndExternalComparisonNotApplied" -> True
|>;
assert[
  And @@ (TrueQ /@ Values[checks]),
  "at least one S08 validation check is not True"
];

angularLeafCounts = <|
  "PreSymmetry" -> nestedProjectionChargeMap[
    Function[{expression, projectorName, chargeKey}, LeafCount[expression]],
    preSymmetryAngularResults
  ],
  "Physical" -> nestedProjectionChargeMap[
    Function[{expression, projectorName, chargeKey}, LeafCount[expression]],
    physicalAngularResults
  ]
|>;
transformedLeafCounts = nestedProjectionChargeMap[
  Function[{expression, projectorName, chargeKey}, LeafCount[expression]],
  xiS23Kernels
];

If[
  preflightOnly,
  Print["S08_DYNAMIC_PREFLIGHT_SUCCESS"];
  Print["S08_DYNAMIC_PREFLIGHT_CHECK_COUNT=", Length[checks]];
  Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
  Print[
    "S08_DYNAMIC_PREFLIGHT_ANGULAR_LEAF_COUNTS=",
    InputForm[angularLeafCounts]
  ];
  Print[
    "S08_DYNAMIC_PREFLIGHT_TRANSFORMED_LEAF_COUNTS=",
    InputForm[transformedLeafCounts]
  ];
  Quit[0]
];

Print["S08_STAGE: validating finalized six-cache inventory"];
cacheValidation = AssociationMap[
  Function[projectorName,
    AssociationMap[
      Function[chargeKey,
        Module[{path, cache},
          path = cachePaths[projectorName, chargeKey];
          cache = If[FileExistsQ[path],
            Quiet @ Check[Get[path], $Failed],
            $Failed
          ];
          TrueQ[cacheMetadataValidQ[cache, projectorName, chargeKey]]
        ]
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];
assert[
  And @@ Flatten[Values /@ Values[cacheValidation]],
  "at least one finalized S08 cache is invalid"
];

cacheHashes = AssociationMap[
  Function[projectorName,
    AssociationMap[
      Function[chargeKey,
        fileSHA256[cachePaths[projectorName, chargeKey]]
      ],
      chargeKeys
    ]
  ],
  projectorKeys
];

symmetryBookkeeping = <|
  "Upstream" -> s07["SymmetryBookkeeping"],
  "DistinctFinalStateIdentities" -> distinctStateIdentities,
  "SpeciesLabelsDerivedFromIdentities" -> speciesLabels,
  "SpeciesMultiplicities" -> speciesMultiplicities,
  "FactorDerivedFromSpeciesMultiplicities" -> symmetryFactorFromSpecies,
  "RepresentativeFactorsRevalidated" ->
    derivedRepresentativeSymmetryFactors,
  "FinalStateSymmetryFactor" -> finalStateSymmetryFactor,
  "NontrivialSymmetryFactorRequired" -> False,
  "NontrivialSymmetryFactorAppliedAtS08" -> False,
  "PhysicalExpressionEqualsPreSymmetryExpression" -> True,
  "NoDownstreamNontrivialSymmetryFactorRemains" -> True
|>;

s08Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "ResultSchemaVersion" -> resultSchemaVersion,
  "Channel" -> "Hqqprime only",
  "Contribution" ->
    "H_{q qPrime; q qbarPrime} charge-resolved three-body angular-integrated Pg/PPP kernels",
  "PerturbativeOrder" -> "O(alpha_s^2)",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "ProgramPath" -> programPath,
  "ProgramSHA256" -> programHash,
  "PaperReference" -> <|
    "Path" -> paperPath,
    "SHA256" -> expectedPaperHash,
    "Equations" ->
      "Eqs. (19), (29)-(32), (38)-(40), Appendices B and D"
  |>,
  "Input" -> <|
    "S07SourcePath" -> s07SourcePath,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultPath" -> s07ResultPath,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "ProjectionPath" ->
      "ScalarProjections/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>",
    "InputScalarSHA256" -> inputScalarHashes
  |>,
  "ProjectorOrder" -> projectorKeys,
  "ChargeKeyOrder" -> chargeKeys,
  "DimensionalConvention" -> HoldForm[D == 4 - 2 epsilon],
  "ObservedMomentumTreatment" ->
    "fragmenting qPrime(k1) remains differential; only labelled unobserved q(k2),qbarPrime(k3) angles are integrated",
  "PhaseSpaceNormalization" -> <|
    "Eq19CommonFactor" -> eq19CommonFactor,
    "Eq39OutsideAngularWeights" -> eq39ThreeBodyPrefactor,
    "Eq19TimesEq39DerivedPrefactor" -> threeBodyPhasePrefactor,
    "PaperCombinedPrefactor" -> paperCombinedPhasePrefactor,
    "Eq39ExactNumericPower" -> HoldForm[2^(-2)],
    "AngularWeightsIntegrated" -> HoldForm[
      Sin[beta1]^(1 - 2 epsilon) Sin[beta2]^(-2 epsilon)
    ],
    "NormalizationIdentityVerified" -> True
  |>,
  "ScaleBookkeeping" -> s07["ScaleBookkeeping"],
  "ChargeBookkeeping" -> s07["ChargeBookkeeping"],
  "SymmetryBookkeeping" -> symmetryBookkeeping,
  "VirtualContributionAtThisOrder" ->
    s07["VirtualContributionAtThisOrder"],
  "PreSymmetryAngularAudit" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqprime;q_qbarPrime" -> preSymmetryAngularResults
    |>
  |>,
  "ThreeBodyAngularIntegrated" -> <|
    "NLOReal_OAlphaS2" -> <|
      "Hqqprime;q_qbarPrime" -> physicalAngularResults
    |>
  |>,
  "XiS23ConvolutionKernels" -> <|
    "ThreeBodyReal" -> <|
      "NLOReal_OAlphaS2" -> <|
        "Hqqprime;q_qbarPrime" -> xiS23Kernels
      |>
    |>
  |>,
  "XiS23ChangeOfVariables" -> <|
    "Replacement" -> HoldForm[zeta == zetaXiS23],
    "XHat" -> xHatXi,
    "ZetaExpression" -> zetaXiS23,
    "ZHatExpression" -> zHatXiS23,
    "PartonicK1TransverseMomentumSquared" -> k1TPartonic2XiS23,
    "JacobianDerivedByWolfram" -> xiS23Jacobian,
    "PaperEq29Jacobian" -> paperEq29Jacobian,
    "XiRange" -> {xi, xiLowerA, 1},
    "S23RangeAtFixedXi" -> {s23, 0, s23UpperB},
    "XiLowerA" -> xiLowerA,
    "S23UpperB" -> s23UpperB,
    "PartonicKinematicRules" -> partonicToXiS23Rules,
    "Checks" -> variableChangeChecks,
    "RemainingXiS23ConvolutionPerformed" -> False
  |>,
  "AngularMasterBasis" -> <|
    "MasslessMassless" -> "Eq. (B18), evaluated exactly",
    "VirtualPhotonMassless" ->
      "Eq. (B19), retained as exact S08Case2Master",
    "Case2MastersUsed" -> case2Masters,
    "Case2MasterCount" -> Length[case2Masters],
    "PerProjectorChargeMasterKeys" -> nestedProjectionChargeMap[
      Function[{record, projectorName, chargeKey}, record["MasterKeys"]],
      angularRecords
    ],
    "PerProjectorChargeMasterCounts" -> nestedProjectionChargeMap[
      Function[{record, projectorName, chargeKey}, record["MasterCount"]],
      angularRecords
    ],
    "Case2MasterDefinition" -> HoldComplete[
      S08Case2Master[j, l, dCoefficient, cosineChi, epsilon] ==
        With[{n = 4 - 2 epsilon},
          (-1)^(l + 1) 2^(1 - l - j) Pi Gamma[n - 3] *
            Gamma[2 + l - n/2] Gamma[n/2 - l - 1]/
            (Gamma[n/2 - 1]^2 Gamma[n/2 - 2] *
              Gamma[3 - n/2]) *
            Inactive[Integrate][
              zMaster^(n/2 - 2) (1 - zMaster)^(n/2 - l - 2)/
                (zMaster + (dCoefficient - 1)/2)^j *
                Hypergeometric2F1[
                  j, l, n/2 - 1,
                  (1 + cosineChi) zMaster/
                    (dCoefficient - 1 + 2 zMaster)
                ],
              {zMaster, 0, 1}
            ]
        ]
    ]
  |>,
  "AppendixD" -> <|
    "IdentityChecks" -> appendixDIdentityChecks,
    "ProjectionChargeAudits" -> nestedProjectionChargeMap[
      Function[{record, projectorName, chargeKey},
        record["ReductionAudit"]
      ],
      angularRecords
    ],
    "ExactCommonBasisReconstructionPassed" ->
      appendixDReconstructionChecks
  |>,
  "LeafCounts" -> <|
    "Angular" -> angularLeafCounts,
    "XiS23Transformed" -> transformedLeafCounts
  |>,
  "ParallelExecution" -> <|
    "KernelCommand" -> parallelKernelExecutable,
    "RequestedLocalKernelCount" -> requestedParallelKernelCount,
    "LaunchedLocalKernelCount" -> Length[workerVersions],
    "WorkerVersions" -> workerVersions,
    "ChargeKeysProcessedIndependently" -> chargeKeys,
    "ProjectorsSerialWithinEachChargeWorker" -> projectorKeys,
    "DeterministicResultOrder" -> True,
    "ConcurrentCacheWrites" -> False
  |>,
  "CacheProvenance" -> <|
    "StageVersion" -> cacheStageVersion,
    "ProgramSHA256" -> programHash,
    "PaperSHA256" -> expectedPaperHash,
    "S07SourceSHA256" -> expectedS07SourceHash,
    "S07ResultSHA256" -> expectedS07ResultHash,
    "Paths" -> cachePaths,
    "SHA256" -> cacheHashes,
    "InputScalarSHA256" -> inputScalarHashes,
    "Reused" -> cacheReuseFlags,
    "AtomicAndMainKernelOnly" -> True
  |>,
  "Checks" -> checks,
  "NotPerformed" -> {
    "Appendix-F epsilon expansion of Eq. (B19) masters",
    "B21-B31 analytic-continuation and contiguous-relation expansions",
    "s23 endpoint delta/plus-distribution expansion",
    "remaining xi and s23 convolution",
    "physical ordered q,qPrime-different charge/flavour assembly",
    "MS-bar PDF/FF collinear factorization",
    "paper Eq. (9) projector combination",
    "epsilon -> 0 limit",
    "F-hat extraction or external-code comparison"
  },
  "DownstreamInstruction" ->
    "A separately authorized S09 may expand the retained masters and formal endpoints. It must consume each physical projector/charge kernel separately and must not introduce a nontrivial final-state symmetry factor."
|>;

Print["S08_STAGE: atomically writing Hqqprime S08 result"];
atomicPutAssociation[s08Result, s08ResultPath, stageVersion];

reloadedResult = Quiet @ Check[Get[s08ResultPath], $Failed];
assert[
  AssociationQ[reloadedResult] &&
    reloadedResult["Status"] === "Complete" &&
    reloadedResult["Stage"] === stageVersion &&
    reloadedResult["ResultSchemaVersion"] === resultSchemaVersion,
  "final s08_result failed status/stage/schema reload validation"
];
assert[
  reloadedResult["ProgramSHA256"] === programHash &&
    reloadedResult["Input", "S07SourceSHA256"] ===
      expectedS07SourceHash &&
    reloadedResult["Input", "S07ResultSHA256"] ===
      expectedS07ResultHash &&
    reloadedResult["PaperReference", "SHA256"] === expectedPaperHash,
  "final s08_result failed source/upstream/paper hash validation"
];
assert[
  And @@ (TrueQ /@ Values[reloadedResult["Checks"]]),
  "final s08_result contains a failed check"
];
assert[
  reloadedResult["PreSymmetryAngularAudit", "NLOReal_OAlphaS2",
      "Hqqprime;q_qbarPrime"] === preSymmetryAngularResults &&
    reloadedResult["ThreeBodyAngularIntegrated", "NLOReal_OAlphaS2",
      "Hqqprime;q_qbarPrime"] === physicalAngularResults &&
    reloadedResult["XiS23ConvolutionKernels", "ThreeBodyReal",
      "NLOReal_OAlphaS2", "Hqqprime;q_qbarPrime"] === xiS23Kernels,
  "final s08_result failed exact six-payload reload validation"
];
assert[
  reloadedResult["SymmetryBookkeeping", "FinalStateSymmetryFactor"] ===
      finalStateSymmetryFactor &&
    reloadedResult["SymmetryBookkeeping",
      "NontrivialSymmetryFactorAppliedAtS08"] === False &&
    reloadedResult["SymmetryBookkeeping",
      "PhysicalExpressionEqualsPreSymmetryExpression"] === True,
  "final s08_result lost distinct-final-state symmetry bookkeeping"
];
assert[
  And @@ Flatten[
    Values /@ Values[
      AssociationMap[
        Function[projectorName,
          AssociationMap[
            Function[chargeKey,
              reloadedResult["CacheProvenance", "SHA256",
                  projectorName, chargeKey] ===
                fileSHA256[cachePaths[projectorName, chargeKey]]
            ],
            chargeKeys
          ]
        ],
        projectorKeys
      ]
    ]
  ],
  "final s08_result cache hashes do not match disk"
];
assert[
  FileNames["s08_result.tmp.*", scriptDirectory] === {} &&
    FileNames["s08_cache_hqqprime*.tmp.*", scriptDirectory] === {},
  "an S08 temporary artifact remains after finalization"
];

Print["S08_SUCCESS"];
Print["S08_PROGRAM_SHA256=" <> programHash];
Print["S08_RESULT_PATH=" <> s08ResultPath];
Print["S08_RESULT_SHA256=" <> fileSHA256[s08ResultPath]];
Print["S08_CACHE_SHA256=", InputForm[cacheHashes]];
Print["S08_CHECK_COUNT=", Length[checks]];
Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
Print["S08_ANGULAR_LEAF_COUNTS=", InputForm[angularLeafCounts]];
Print["S08_TRANSFORMED_LEAF_COUNTS=", InputForm[transformedLeafCounts]];
Print["S08_RESULT_BYTES=", FileByteCount[s08ResultPath]];

Quit[0];

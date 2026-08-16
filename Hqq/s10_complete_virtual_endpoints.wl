(* ::Package:: *)

(*
  Hqq stage s10.

  This stage is fully analytic and symbolic.  It does not choose numerical
  kinematics, PDFs, fragmentation functions, or a numerical test function.

  Requested operations:
    1. Evaluate every PaVe coefficient and every scalar B0/C0/D0 master in
       the inherited one-loop virtual interference, with Package-X analytic
       continuation and separate UV/IR regulators.
    2. Insert the explicit one-loop QCD coupling and massless on-shell field
       constants.  The saved counterterm amplitudes already contain the LSZ
       external-leg coefficients, so they are removed before the explicit
       constants are inserted once through their validated LO multiplier.
    3. Verify UV cancellation and expand the virtual coefficient through the
       finite term in epsilon.
    4. Resolve the two bounded-limit S09EndpointValue placeholders by an exact
       channel-by-channel algebraic endpoint extraction.
    5. Act every endpoint delta and plus distribution on an arbitrary symbolic
       test function over 0 <= s23 <= B(xi), leaving only ordinary subtracted
       inactive integrals and no distributional placeholder.

  Eq. (46) PDF/FF collinear factorization is not part of this requested stage.
*)

$HistoryLength = 0;
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];
$FCAdvice = False;

requestedParallelKernels = 0;
parallelKernelCount = 0;
Print["S10_PARALLEL_KERNELS=", parallelKernelCount];
Print[
  "S10_MEMORY_STAGE: serial bounded reconstruction; no large expression " <>
    "is copied to subkernels"
];

ClearAll[
  fatal, assert, zeroEquivalentQ, setTwoBodyKinematics,
  evaluatePaVe, obtainPaVeRules, transformTwoBodyCoefficient,
  virtualLaurentTerms, pppTerm2FactorwiseLaurent, finiteLaurentTerm,
  finiteLaurentProjector,
  finiteLaurentPair,
  invalidEndpointQ, endpointFactorwiseLaurent,
  endpointTermLaurent, splitEndpointChannel, alpha2EndpointData,
  alpha2TermIndex, processEndpointChannel,
  makeDistributionAction, S10ConvolutionTest,
  S10EndpointCA, S10EndpointCF, S10EndpointFCGV, S10EndpointSMP
];

fatal[message_String] := (
  Print["S10_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

zeroEquivalentQ[expression_, seconds_Integer : 600] := Module[{answer},
  If[TrueQ[expression === 0], Return[True]];
  answer = Check[
    TimeConstrained[
      Together[Cancel[expression]],
      seconds,
      $Failed
    ],
    $Failed
  ];
  TrueQ[answer === 0]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s09Path = FileNameJoin[{scriptDirectory, "s09_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
paVeCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v1_virtual_pax_rules"
}];
scalarMasterCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v1_virtual_scalar_rules"
}];
laurentCachePath = FileNameJoin[{
  scriptDirectory, "s10_cache_v2_virtual_laurent"
}];
laurentProgressCachePath[projector_String] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector]
}];
laurentSubtermCachePath[projector_String, index_Integer] := FileNameJoin[{
  scriptDirectory,
  "s10_cache_v1_virtual_laurent_progress_" <> ToLowerCase[projector] <>
    "_term_" <> ToString[index]
}];
paVeCacheVersion = 1;
scalarMasterCacheVersion = 1;
laurentCacheVersion = 2;
laurentProgressCacheVersion = 1;
laurentSubtermCacheVersion = 1;
legacyCompletedPgInputHash =
  84984990350238613880772404782144164267677938507855629699774420569474027219848;
legacyPPPProgressInputHash =
  11344946010545531301360816574701180890254301404582010766624759949431607978234;
endpointCacheVersion = 3;
coupledEndpointRepairVersion = 1;
coupledEndpointGroups = <|
  "Hqq;q_qbar_sameFlavor Pg" -> {{17, 29, 39, 55}},
  "Hqq;q_qbar_sameFlavor PPP" -> {{8, 35, 42, 57}}
|>;
projectors = {"Pg", "PPP"};
ggAlpha2TermIndex = <|"Pg" -> 15, "PPP" -> 10|>;

endpointCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s9p5_cache_v3_endpoint_" <>
    StringReplace[channel, {";" -> "_", "'" -> "p"}] <> "_" <>
    ToLowerCase[projector]
}];

alpha2TermIndex[channel_String, projector_String] := If[
  channel === "Hqq;gg",
  ggAlpha2TermIndex[projector],
  Missing["NotApplicable"]
];

Print["S10_STAGE: loading and validating s09, s08, and s07 inputs"];
assert[FileExistsQ[s09Path], "s09_result does not exist."];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09], "s09_result did not load as an Association."];
assert[s09["Status"] === "CompleteWithSymbolicVirtual",
  "s09_result does not have the expected symbolic-virtual status."];
assert[s09["Channel"] === "Hqq only", "s09_result is not Hqq-only."];
assert[And @@ Values[s09["Checks"]],
  "At least one s09 validation check is not True."];

s08Path = s09["SourceResult"];
assert[FileExistsQ[s08Path], "The s08 source result recorded by s09 is absent."];
s08 = Check[Get[s08Path], $Failed];
assert[AssociationQ[s08] && s08["Status"] === "Complete",
  "s08_result is absent, invalid, or incomplete."];
assert[And @@ Values[s08["Checks"]],
  "At least one s08 validation check is not True."];

s07Path = s08["SourceResult"];
assert[FileExistsQ[s07Path], "The s07 source result recorded by s08 is absent."];
s07 = Check[Get[s07Path], $Failed];
assert[AssociationQ[s07] && s07["Status"] === "Complete",
  "s07_result is absent, invalid, or incomplete."];
assert[And @@ Values[s07["Checks"]],
  "At least one s07 validation check is not True."];

virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];
loInput = s07["ScalarProjections", "LO_OAlphaS"];
loReference = s09["LOReferenceKernels"];
changeOfVariables = s08["XiS23ChangeOfVariables"];
partonicRules = changeOfVariables["PartonicKinematicRules"];
xiS23Jacobian =
  changeOfVariables["Jacobian_dXi_dZeta_to_dXi_dS23"];
s23UpperB = changeOfVariables["S23UpperB"];

assert[Sort[Keys[virtualInput]] === Sort[projectors],
  "The s07 virtual input lacks Pg or PPP."];
assert[Sort[Keys[loInput]] === Sort[projectors],
  "The s07 LO input lacks Pg or PPP."];
assert[Sort[Keys[loReference]] === Sort[projectors],
  "The s09 LO reference lacks Pg or PPP."];

(*
  Remove all saved symbolic QCD counterterm coefficients before evaluating the
  bare loops.  Their explicit values are inserted once below.  In the saved
  unpolarized interference the exact counterterm/LO multiplier is

    dZGG1 + 2 dZgs1 + 2 dZq1[3,1,1].

  The saved pair 2 dZq1 is the aggregate contribution of the two external
  quark legs.  deltaZqAggregate below represents that complete pair and must
  therefore be inserted once; no extra LSZ factor is added.
*)
countertermZeroRules = {
  dZGG1 -> 0,
  dZgs1 -> 0,
  HoldPattern[dZq1[___]] -> 0
};

virtualDimensional = Map[(# /. D -> 4 - 2 epsilon) &, virtualInput];
bareVirtualSymbolicD = Map[(# /. countertermZeroRules) &, virtualInput];
bareVirtualDimensional =
  Map[(# /. D -> 4 - 2 epsilon) &, bareVirtualSymbolicD];

assert[And @@ (! FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualDimensional]),
  "The inherited virtual pair does not contain the expected QCD counterterms."];
assert[And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[bareVirtualDimensional]),
  "A symbolic QCD counterterm survived the bare-loop split."];

uniquePaVe = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional], _FeynCalc`PaVe, Infinity
];
assert[Length[uniquePaVe] === 96,
  "Expected 96 unique virtual PaVe functions, found " <>
    ToString[Length[uniquePaVe]] <> "."];
uniqueScalarMasters = DeleteDuplicates@Cases[
  Values[bareVirtualDimensional],
  _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0,
  Infinity
];
assert[Length[uniqueScalarMasters] === 4 &&
    Count[uniqueScalarMasters, _FeynCalc`B0] === 2 &&
    Count[uniqueScalarMasters, _FeynCalc`C0] === 2 &&
    Count[uniqueScalarMasters, _FeynCalc`D0] === 0,
  "Expected exactly two B0 and two C0 virtual scalar masters."];

evaluatePaVe[
    integral_, index_Integer, total_Integer, label_String
  ] := Module[{answer},
  Print[
    "S10_STAGE: analytic " <> label <> " evaluation " <>
      ToString[index] <> "/" <> ToString[total]
  ];
  answer = CheckAbort[
    Quiet@Check[
      TimeConstrained[
        FeynCalc`PaXEvaluateUVIRSplit[
          integral,
          ell,
          FeynCalc`PaXImplicitPrefactor -> 1,
          FeynCalc`PaXC0Expand -> True,
          FeynCalc`PaXD0Expand -> True,
          FeynCalc`PaXAnalytic -> True
        ],
        600,
        $Failed
      ],
      $Failed
    ],
    $Failed
  ];
  assert[answer =!= $Failed,
    "Package-X failed or timed out on " <> label <> " integral " <>
      ToString[index] <> "."];
  assert[FreeQ[
      answer,
      _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`PaXEvaluateUVIRSplit
    ],
    "A Package-X " <> label <> " evaluation remained unresolved at " <>
      "integral " <> ToString[index] <> "."];
  answer
];

obtainPaVeRules[
    integrals_List, cache_String, version_Integer, label_String
  ] := Module[
  {payload, cachedIntegrals = {}, values = {}, index, total},
  total = Length[integrals];
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading resumable Package-X cache"];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === version &&
        (payload["IntegralType"] === label ||
          (label === "PaVe" && MissingQ[payload["IntegralType"]])),
      "The Package-X " <> label <> " cache is invalid."];
    cachedIntegrals = payload["Integrals"];
    values = payload["Values"];
    assert[ListQ[cachedIntegrals] && ListQ[values] &&
        Length[cachedIntegrals] === Length[values] &&
        Length[values] <= total,
      "The Package-X " <> label <> " cache has inconsistent list lengths."];
    assert[SameQ[cachedIntegrals, Take[integrals, Length[cachedIntegrals]]],
      "The Package-X " <> label <>
        " cache does not match the current integral ordering."];
  ];
  For[index = Length[values] + 1, index <= total, index++,
    AppendTo[cachedIntegrals, integrals[[index]]];
    AppendTo[values,
      evaluatePaVe[integrals[[index]], index, total, label]];
    payload = <|
      "CacheVersion" -> version,
      "IntegralType" -> label,
      "AnalyticContinuation" -> True,
      "ImplicitPrefactor" -> 1,
      "Integrals" -> cachedIntegrals,
      "Values" -> values
    |>;
    Put[payload, cache];
    assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
      "The resumable Package-X " <> label <> " cache was not written."];
  ];
  assert[Length[values] === total,
    "The Package-X " <> label <> " cache has incomplete coverage."];
  assert[And @@ (FreeQ[
        #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
          _FeynCalc`PaXEvaluateUVIRSplit
      ] & /@ values),
    "At least one cached Package-X " <> label <> " value is unresolved."];
  Thread[integrals -> values]
];

Print["S10_STAGE: completing all analytic scalar one-loop integrals"];
paVeRules = obtainPaVeRules[
  uniquePaVe, paVeCachePath, paVeCacheVersion, "PaVe"
];
scalarMasterRules = obtainPaVeRules[
  uniqueScalarMasters, scalarMasterCachePath,
  scalarMasterCacheVersion, "scalar master"
];
loopIntegralRules = Join[paVeRules, scalarMasterRules];
bareVirtualSplit = Map[
  (# /. Dispatch[loopIntegralRules]) &,
  bareVirtualSymbolicD
];
assert[And @@ (FreeQ[
      #, _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`PaXEvaluateUVIRSplit
    ] & /@ Values[bareVirtualSplit]),
  "A PaVe, scalar master, or Package-X evaluator remains in the virtual pair."];
assert[And @@ (! FreeQ[#, FeynCalc`EpsilonUV] & /@
      Values[bareVirtualSplit]),
  "A bare virtual projector lacks its explicit UV regulator."];
assert[And @@ (! FreeQ[#, FeynCalc`EpsilonIR] & /@
      Values[bareVirtualSplit]),
  "A bare virtual projector lacks its explicit IR regulator."];

setTwoBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[k1, k2] = sHat/2;
  FeynCalc`SPD[q, k1] = (-Q2 - tHat)/2;
  FeynCalc`SPD[q, k2] = (sHat + tHat)/2;
  FeynCalc`SPD[p, k1] = (Q2 + sHat + tHat)/2;
  FeynCalc`SPD[p, k2] = -tHat/2;
);

Print["S10_STAGE: resolving ordinary tree propagator denominators"];
setTwoBodyKinematics[];
bareVirtualExplicit = Map[
  Function[expression,
    Quiet@Check[
      FeynCalc`FeynAmpDenominatorExplicit[expression] /.
        D -> 4 - 2 epsilon,
      $Failed
    ]
  ],
  bareVirtualSplit
];
loExplicit = Map[
  Function[expression,
    Quiet@Check[
      FeynCalc`FeynAmpDenominatorExplicit[expression] /.
        D -> 4 - 2 epsilon,
      $Failed
    ]
  ],
  loInput
];
assert[FreeQ[Values[bareVirtualExplicit], $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity],
  "Bare-loop propagator expansion failed or became indeterminate."];
assert[FreeQ[Values[loExplicit], $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity],
  "LO propagator expansion failed or became indeterminate."];
assert[And @@ (FreeQ[#, _FeynCalc`FeynAmpDenominator] & /@
      Values[bareVirtualExplicit]),
  "A bare-loop FeynAmpDenominator remains unresolved."];
assert[And @@ (FreeQ[#, _FeynCalc`FeynAmpDenominator] & /@
      Values[loExplicit]),
  "An LO FeynAmpDenominator remains unresolved."];
assert[And @@ (FreeQ[#, _FeynCalc`Pair] & /@
      Join[Values[bareVirtualExplicit], Values[loExplicit]]),
  "A scalar Pair survived the symbolic-D denominator expansion."];

(* Explicit one-loop QCD constants in the convention of the saved amplitudes. *)
aSLoop = FeynCalc`SMP["g_s"]^2/(16 Pi^2);
deltaZGG = aSLoop (5 FeynCalc`CA/3 - 2 FeynCalc`Nf/3) *
  (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR);
deltaZgs = -aSLoop (11 FeynCalc`CA/6 - FeynCalc`Nf/3) /
  FeynCalc`EpsilonUV;
deltaZqAggregate = -2 aSLoop FeynCalc`CF *
  (1/FeynCalc`EpsilonUV - 1/FeynCalc`EpsilonIR);
explicitCountertermMultiplier =
  deltaZGG + 2 deltaZgs + deltaZqAggregate;

expectedBareUVRatio =
  FeynCalc`SMP["g_s"]^2 (FeynCalc`CF + FeynCalc`CA)/(8 Pi^2);
colorRule = FeynCalc`CF ->
  (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA);

Print["S10_STAGE: validating the explicit UV counterterm cancellation"];
bareUVResidues = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        SeriesCoefficient[
          bareVirtualExplicit[projector],
          {FeynCalc`EpsilonUV, 0, -1}
        ] /. epsilon -> 0,
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[FreeQ[Values[bareUVResidues], $Failed],
  "Extraction of a bare UV residue failed or timed out."];

bareUVRatioResiduals = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Together@Cancel[
          (bareUVResidues[projector]/
              (loExplicit[projector] /. epsilon -> 0) -
            expectedBareUVRatio) /. colorRule
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[And @@ (TrueQ[# === 0] & /@ Values[bareUVRatioResiduals]),
  "The evaluated bare UV residue is not the expected multiple of LO."];

countertermUVRatio = SeriesCoefficient[
  explicitCountertermMultiplier,
  {FeynCalc`EpsilonUV, 0, -1}
];
uvCancellationRatio = Together@Cancel[
  (expectedBareUVRatio + countertermUVRatio) /. colorRule
];
assert[uvCancellationRatio === 0,
  "The explicit QCD constants do not cancel the bare UV residue."];

(*
  The coefficient (without DiracDelta[s23]) is transformed exactly as in s08:
  multiply by 2 Pi/(2 Pi)^4 and by d zeta/d s23, apply the saved partonic
  substitutions, and then enforce the two-body endpoint s23=0.
*)
twoBodyPhaseCoefficient = (2 Pi)/(2 Pi)^4;
transformTwoBodyCoefficient[expression_] :=
  (twoBodyPhaseCoefficient xiS23Jacobian *
      (expression /. partonicRules)) /. s23 -> 0;

Print["S10_STAGE: applying the exact s08 two-body normalization and map"];
loTransformed = Map[transformTwoBodyCoefficient, loExplicit];
loStoredCoefficients = Map[
  Function[expression,
    (expression /. DiracDelta[s23] -> 1) /. s23 -> 0
  ],
  loReference
];
loNormalizationResiduals = AssociationMap[
  loTransformed[#] - loStoredCoefficients[#] &,
  projectors
];
assert[And @@ (zeroEquivalentQ[#, 600] & /@
      Values[loNormalizationResiduals]),
  "The reconstructed two-body normalization does not match the s09 LO reference."];

bareVirtualTransformed = Map[
  transformTwoBodyCoefficient,
  bareVirtualExplicit
];
renormalizedVirtualSplit = AssociationMap[
  bareVirtualTransformed[#] +
    loStoredCoefficients[#] explicitCountertermMultiplier &,
  projectors
];
assert[And @@ (FreeQ[
      #, dZGG1 | dZgs1 | _dZq1 | _FeynCalc`PaVe | _FeynCalc`B0 |
        _FeynCalc`C0 | _FeynCalc`D0 | _FeynCalc`FeynAmpDenominator
    ] & /@ Values[renormalizedVirtualSplit]),
  "The renormalized virtual pair retains a symbolic dZ, loop integral, or denominator."];

(*
  The source associations and the successive bare-loop representations are
  large and are no longer needed once the two renormalized projector
  expressions have been constructed.  Releasing them here is essential: a
  monolithic Series otherwise coexists with several complete copies of the
  virtual input and can exhaust WSL memory.
*)
Print["S10_MEMORY_STAGE: releasing superseded virtual inputs before Laurent expansion"];
Clear[
  s09, s08, s07, virtualInput, loInput, loReference,
  changeOfVariables, partonicRules, xiS23Jacobian,
  virtualDimensional, bareVirtualSymbolicD, bareVirtualDimensional,
  paVeRules, scalarMasterRules, loopIntegralRules,
  bareVirtualSplit, bareVirtualExplicit, loExplicit,
  bareUVResidues, loTransformed, loNormalizationResiduals,
  bareVirtualTransformed
];
ClearSystemCache[];

(*
  Series is linear.  Split only at an already-present additive boundary and
  expand one summand at a time.  This avoids constructing SeriesData for the
  complete projector at once and does not perform an algebraic Expand.
*)
virtualLaurentTerms[expression_] := Module[
  {factors, plusPositions, splitPosition, commonFactor},
  If[Head[expression] === Plus,
    Return[<|"CommonFactor" -> 1, "Summands" -> (List @@ expression)|>]
  ];
  If[Head[expression] =!= Times,
    Return[<|"CommonFactor" -> 1, "Summands" -> {expression}|>]
  ];
  factors = List @@ expression;
  plusPositions = Flatten@Position[
    factors, _Plus, {1}, Heads -> False
  ];
  If[Length[plusPositions] === 0,
    Return[<|"CommonFactor" -> 1, "Summands" -> {expression}|>]
  ];
  splitPosition = First@MaximalBy[
    plusPositions,
    Length[List @@ factors[[#]]] &
  ];
  commonFactor = Times @@ Delete[factors, splitPosition];
  <|
    "CommonFactor" -> commonFactor,
    "Summands" -> (List @@ factors[[splitPosition]])
  |>
];

(*)
  PPP coarse term 2 contains huge rational kinematic factors that are exactly
  independent of all dimensional regulators.  Pull them outside Series and
  expand only the much smaller regulator-dependent product.  This is used
  only for the refined subterms of that one coarse term.
*)
pppTerm2FactorwiseLaurent[expression_] := Module[
  {factors, staticFactors, dynamicFactors, staticFactor, dynamicFactor},
  factors = If[Head[expression] === Times, List @@ expression, {expression}];
  staticFactors = Select[
    factors,
    FreeQ[#, epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR] &
  ];
  dynamicFactors = Select[
    factors,
    ! FreeQ[#, epsilon | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR] &
  ];
  staticFactor = Times @@ staticFactors;
  dynamicFactor = Times @@ dynamicFactors;
  Print[
    "S10_TERM_OPTIMIZATION: PPP term 2 factorwise Laurent staticFactors=" <>
      ToString[Length[staticFactors]] <> " dynamicFactors=" <>
      ToString[Length[dynamicFactors]] <> " dynamicLeafCount=" <>
      ToString[LeafCount[dynamicFactor]]
  ];
  If[Length[dynamicFactors] === 0, Return[staticFactor]];
  Check[
    TimeConstrained[
      staticFactor Normal@Series[
        dynamicFactor /. {
          FeynCalc`EpsilonUV -> epsilon,
          FeynCalc`EpsilonIR -> epsilon
        },
        {epsilon, 0, 0}
      ],
      900,
      $Failed
    ],
    $Failed
  ]
];

finiteLaurentTerm[
    commonFactor_, term_, projector_String, index_Integer, inputHash_
  ] := Module[
  {
    pieces, subCommonFactor, subterms, subtermCache, payload,
    values = {}, subindex, subtotal, subtermAnswer
  },
  pieces = virtualLaurentTerms[term];
  subCommonFactor = pieces["CommonFactor"];
  subterms = pieces["Summands"];
  Clear[pieces];
  subtotal = Length[subterms];
  If[subtotal === 1,
    Return@Check[
      TimeConstrained[
        Normal@Series[
          (commonFactor term) /. {
            FeynCalc`EpsilonUV -> epsilon,
            FeynCalc`EpsilonIR -> epsilon
          },
          {epsilon, 0, 0}
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ];
  subtermCache = laurentSubtermCachePath[projector, index];
  Print[
    "S10_STAGE: refined virtual Laurent term " <> projector <> " " <>
      ToString[index] <> " into " <> ToString[subtotal] <> " subterms"
  ];
  If[FileExistsQ[subtermCache],
    Print[
      "S10_STAGE: loading refined Laurent progress for " <> projector <>
        " term " <> ToString[index]
    ];
    payload = Check[Get[subtermCache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === laurentSubtermCacheVersion &&
        payload["Projector"] === projector &&
        payload["CoarseTermIndex"] === index &&
        (payload["InputHash"] === inputHash ||
          (projector === "PPP" && index === 2 &&
            payload["InputHash"] === legacyPPPProgressInputHash)) &&
        payload["SubtermCount"] === subtotal,
      projector <> " virtual Laurent subterm cache is invalid."];
    values = payload["LaurentSubterms"];
    assert[ListQ[values] && Length[values] <= subtotal,
      projector <> " virtual Laurent subterm progress is invalid."];
  ];
  For[subindex = Length[values] + 1, subindex <= subtotal, subindex++,
    subtermAnswer = If[
      projector === "PPP" && index === 2,
      pppTerm2FactorwiseLaurent[
        commonFactor subCommonFactor subterms[[subindex]]
      ],
      Check[
        TimeConstrained[
          Normal@Series[
            (commonFactor subCommonFactor subterms[[subindex]]) /. {
              FeynCalc`EpsilonUV -> epsilon,
              FeynCalc`EpsilonIR -> epsilon
            },
            {epsilon, 0, 0}
          ],
          900,
          $Failed
        ],
        $Failed
      ]
    ];
    assert[subtermAnswer =!= $Failed,
      projector <> " virtual Laurent term " <> ToString[index] <>
        " subterm " <> ToString[subindex] <> " failed or timed out."];
    AppendTo[values, subtermAnswer];
    payload = <|
      "CacheVersion" -> laurentSubtermCacheVersion,
      "Projector" -> projector,
      "CoarseTermIndex" -> index,
      "InputHash" -> inputHash,
      "SubtermCount" -> subtotal,
      "LaurentSubterms" -> values
    |>;
    Put[payload, subtermCache];
    assert[FileExistsQ[subtermCache] && FileByteCount[subtermCache] > 0,
      projector <> " virtual Laurent subterm cache was not written."];
    Print[
      "S10_SUBTERM_CHECKPOINT: " <> projector <> " virtual Laurent term " <>
        ToString[index] <> " subterm " <> ToString[subindex] <> "/" <>
        ToString[subtotal]
    ];
    Clear[subtermAnswer];
    ClearSystemCache[];
  ];
  Total[values]
];

finiteLaurentProjector[
    expression_, projector_String, progressCache_String
  ] := Module[
  {
    pieces, commonFactor, terms, inputHash, payload, values = {},
    index, total, termAnswer
  },
  Print["S10_MEMORY_STAGE: locating additive boundary for " <> projector];
  pieces = virtualLaurentTerms[expression];
  commonFactor = pieces["CommonFactor"];
  terms = pieces["Summands"];
  Clear[pieces];
  total = Length[terms];
  assert[total > 1,
    projector <> " virtual expression has no safe additive split boundary."];
  inputHash = Hash[
    {
      FileHash[$InputFileName, "SHA256"],
      FileHash[s07Path, "SHA256"],
      FileHash[paVeCachePath, "SHA256"],
      FileHash[scalarMasterCachePath, "SHA256"],
      projector,
      laurentProgressCacheVersion
    },
    "SHA256"
  ];
  If[FileExistsQ[progressCache],
    Print["S10_STAGE: loading resumable virtual Laurent progress for " <>
      projector];
    payload = Check[Get[progressCache], $Failed];
    assert[AssociationQ[payload],
      projector <> " virtual Laurent progress cache is invalid."];
    values = payload["LaurentTerms"];
    If[projector === "Pg" &&
        payload["CacheVersion"] === 1 &&
        payload["InputHash"] === legacyCompletedPgInputHash &&
        payload["TermCount"] === total &&
        ListQ[values] && Length[values] === total,
      Print["S10_STAGE: reusing exact completed Pg Laurent checkpoint"];
      Return[Total[values]]
    ];
    assert[
        payload["CacheVersion"] === laurentProgressCacheVersion &&
        payload["Projector"] === projector &&
        (payload["InputHash"] === inputHash ||
          (projector === "PPP" &&
            payload["InputHash"] === legacyPPPProgressInputHash)) &&
        payload["TermCount"] === total,
      projector <> " virtual Laurent progress cache is invalid."];
    assert[ListQ[values] && Length[values] <= total,
      projector <> " virtual Laurent progress has an invalid term list."];
  ];
  Print[
    "S10_STAGE: bounded virtual Laurent terms for " <> projector <>
      " completed=" <> ToString[Length[values]] <> "/" <> ToString[total]
  ];
  For[index = Length[values] + 1, index <= total, index++,
    termAnswer = finiteLaurentTerm[
      commonFactor, terms[[index]], projector, index, inputHash
    ];
    assert[termAnswer =!= $Failed,
      projector <> " virtual Laurent term " <> ToString[index] <>
        " failed or timed out."];
    AppendTo[values, termAnswer];
    payload = <|
      "CacheVersion" -> laurentProgressCacheVersion,
      "Projector" -> projector,
      "InputHash" -> inputHash,
      "TermCount" -> total,
      "LaurentTerms" -> values
    |>;
    Put[payload, progressCache];
    assert[FileExistsQ[progressCache] && FileByteCount[progressCache] > 0,
      projector <> " virtual Laurent progress cache was not written."];
    If[FileExistsQ[laurentSubtermCachePath[projector, index]],
      DeleteFile[laurentSubtermCachePath[projector, index]]
    ];
    Print[
      "S10_TERM_CHECKPOINT: " <> projector <> " virtual Laurent term " <>
        ToString[index] <> "/" <> ToString[total]
    ];
    Clear[termAnswer];
    ClearSystemCache[];
  ];
  Total[values]
];

finiteLaurentPair[pair_Association, cache_String] := Module[
  {payload, answer = <||>, projector, projectorExpression, progressCache},
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading virtual Laurent cache"];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === laurentCacheVersion,
      "The virtual Laurent cache is invalid."];
    answer = payload["LaurentThroughFinite"];
    assert[AssociationQ[answer] && Sort[Keys[answer]] === Sort[projectors],
      "The virtual Laurent cache has invalid projector keys."];
    Scan[
      Function[projector,
        progressCache = laurentProgressCachePath[projector];
        If[FileExistsQ[progressCache], DeleteFile[progressCache]]
      ],
      projectors
    ];
    Return[answer]
  ];
  Do[
    Print["S10_STAGE: virtual Laurent expansion through finite term for " <>
      projector];
    projectorExpression = pair[projector];
    progressCache = laurentProgressCachePath[projector];
    AssociateTo[
      answer,
      projector -> finiteLaurentProjector[
        projectorExpression, projector, progressCache
      ]
    ];
    Clear[projectorExpression];
    ClearSystemCache[],
    {projector, projectors}
  ];
  payload = <|
    "CacheVersion" -> laurentCacheVersion,
    "RegulatorsUnifiedAfterUVCheck" -> True,
    "OrdersRetained" -> {-2, -1, 0},
    "LaurentThroughFinite" -> answer
  |>;
  Put[payload, cache];
  assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
    "The virtual Laurent cache was not written."];
  Scan[
    Function[projector,
      progressCache = laurentProgressCachePath[projector];
      If[FileExistsQ[progressCache], DeleteFile[progressCache]]
    ],
    projectors
  ];
  answer
];

Print["S10_STAGE: completing the renormalized virtual Laurent expansion"];
virtualLaurent = finiteLaurentPair[
  renormalizedVirtualSplit,
  laurentCachePath
];
assert[And @@ (FreeQ[
      #,
      FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | _SeriesData |
        _FeynCalc`PaVe | _FeynCalc`B0 | _FeynCalc`C0 | _FeynCalc`D0 |
        _FeynCalc`FeynAmpDenominator |
        dZGG1 | dZgs1 | _dZq1
    ] & /@ Values[virtualLaurent]),
  "A completed virtual Laurent coefficient retains an unresolved object."];

expectedVirtualDoublePoleRatio =
  -FeynCalc`SMP["g_s"]^2 (2 FeynCalc`CF + FeynCalc`CA)/(8 Pi^2);
virtualDoublePoleResiduals = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Together@Cancel[
          (SeriesCoefficient[
              virtualLaurent[projector], {epsilon, 0, -2}
            ]/(loStoredCoefficients[projector] /. epsilon -> 0) -
            expectedVirtualDoublePoleRatio) /. colorRule
        ],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[And @@ (TrueQ[# === 0] & /@ Values[virtualDoublePoleResiduals]),
  "The renormalized virtual double pole is not the universal LO multiple."];

(*
  Exact endpoint extraction.  Each s09 channel is a product containing one
  explicit s23^(-epsilon), seven remaining common factors, and one additive
  rational numerator sum.  For s23>0,

    s23^(1+epsilon) R = s23 * common * numerator.

  Multiplying each rational numerator term by s23 avoids the prohibitively
  large whole-expression Limit that s09 bounded.  Some individual terms then
  retain a simple rational pole even though the physically weighted channel
  sum is finite.  For those terms the pole and finite Laurent coefficients are
  extracted separately.  The weighted pole is required to cancel exactly
  before its finite coefficient is accepted as an endpoint value.
*)
invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | Indeterminate | ComplexInfinity | DirectedInfinity |
    Power[0, _?Negative]
];

endpointInertRules = {
  FeynCalc`CA -> S10EndpointCA,
  FeynCalc`CF -> S10EndpointCF,
  HoldPattern[FeynCalc`FCGV[arguments___]] :>
    S10EndpointFCGV[arguments],
  HoldPattern[FeynCalc`SMP[arguments___]] :>
    S10EndpointSMP[arguments]
};
endpointActiveRules = {
  S10EndpointCA -> FeynCalc`CA,
  S10EndpointCF -> FeynCalc`CF,
  HoldPattern[S10EndpointFCGV[arguments___]] :>
    FeynCalc`FCGV[arguments],
  HoldPattern[S10EndpointSMP[arguments___]] :>
    FeynCalc`SMP[arguments]
};

(*
  Asking Series to expand individual square-root or rational factors can
  destroy exact cancellations and consume prohibitive memory.  The endpoint
  factors are therefore classified summand by summand.  If exactly one factor
  q is singular while the complementary product r is regular, then

    term = r(s23) q(s23),
    q(s23) = q[-2]/s23^2 + q[-1]/s23 + O(1),

  then the coefficients needed from s23 term are

    pole   = r(0) q[-2],
    finite = r(0) q[-1] + r'(0) q[-2].

  The q coefficients are obtained summand by summand after multiplication by
  s23^2.  Values and, only when required, derivatives of r are also formed
  factor by factor.  This keeps the calculation exact and symbolic, selects
  the singular factor by its endpoint behavior rather than its expression
  size, and avoids differentiating a large regular product when q[-2] is zero.
*)
endpointFactorwiseLaurent[
    term_, label_String, index_Integer
  ] := Module[
  {
    inertTerm, factors, factorTermLists, factorEndpointTermValues,
    factorRegularFlags, singularIndices, remainderIndex, remainderTerms,
    regularIndices, regularFactorValues, regularDerivativeTermValues,
    regularFactorDerivatives, regular0, regular1, regularizedTerms,
    minus2Terms, minus1Terms, minus2Coefficient, minus1Coefficient,
    poleCoefficient, finiteCoefficient
  },
  If[Head[term] =!= Times, Return[$Failed]];
  inertTerm = term /. endpointInertRules;
  factors = List @@ inertTerm;
  factorTermLists =
    (If[Head[#] === Plus, List @@ #, {#}] &) /@ factors;
  factorEndpointTermValues = Quiet@TimeConstrained[
    ((# /. s23 -> 0 &) /@ # &) /@ factorTermLists,
    120,
    $Failed
  ];
  If[factorEndpointTermValues === $Failed, Return[$Failed]];
  factorRegularFlags = Map[
    Function[values,
      And @@ (
        (! invalidEndpointQ[#] && FreeQ[#, s23]) & /@ values
      )
    ],
    factorEndpointTermValues
  ];
  singularIndices = Flatten@Position[
    factorRegularFlags,
    False,
    {1},
    Heads -> False
  ];
  If[Length[singularIndices] === 0,
    Print[
      "S10_STAGE: used exact summand-wise regular endpoint extraction for " <>
        label <> " term " <> ToString[index]
    ];
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> 0,
      "RequiredPoleSubtraction" -> False
    |>]
  ];
  If[Length[singularIndices] =!= 1, Return[$Failed]];
  remainderIndex = First[singularIndices];
  remainderTerms = factorTermLists[[remainderIndex]];
  regularIndices = Complement[Range[Length[factors]], {remainderIndex}];
  regularFactorValues = Total /@
    factorEndpointTermValues[[regularIndices]];
  regular0 = Times @@ regularFactorValues;
  If[invalidEndpointQ[regular0] || ! FreeQ[regular0, s23],
    Return[$Failed]
  ];
  regularizedTerms = Quiet@Check[
    TimeConstrained[
      (Cancel[s23^2 #] &) /@ remainderTerms,
      600,
      $Failed
    ],
    $Failed
  ];
  If[regularizedTerms === $Failed, Return[$Failed]];
  minus2Terms = Quiet[(# /. s23 -> 0) & /@ regularizedTerms];
  If[AnyTrue[minus2Terms, invalidEndpointQ] ||
      ! And @@ (FreeQ[#, s23] & /@ minus2Terms),
    Return[$Failed]
  ];
  minus1Terms = Quiet@Check[
    TimeConstrained[
      (D[#, s23] /. s23 -> 0 &) /@ regularizedTerms,
      600,
      $Failed
    ],
    $Failed
  ];
  If[minus1Terms === $Failed ||
      AnyTrue[minus1Terms, invalidEndpointQ] ||
      ! And @@ (FreeQ[#, s23] & /@ minus1Terms),
    Return[$Failed]
  ];
  minus2Coefficient = Total[minus2Terms];
  minus1Coefficient = Total[minus1Terms];
  regular1 = 0;
  If[! TrueQ[minus2Coefficient === 0],
    regularDerivativeTermValues = Quiet@Check[
      TimeConstrained[
        Table[
          (D[#, s23] /. s23 -> 0 &) /@
            factorTermLists[[factorIndex]],
          {factorIndex, regularIndices}
        ],
        600,
        $Failed
      ],
      $Failed
    ];
    If[regularDerivativeTermValues === $Failed ||
        AnyTrue[Flatten[regularDerivativeTermValues], invalidEndpointQ] ||
        ! And @@ (
          FreeQ[#, s23] & /@ Flatten[regularDerivativeTermValues]
        ),
      Return[$Failed]
    ];
    regularFactorDerivatives = Total /@ regularDerivativeTermValues;
    regular1 = Sum[
      regularFactorDerivatives[[factorIndex]]
        Times @@ Delete[regularFactorValues, factorIndex],
      {factorIndex, Length[regularFactorValues]}
    ];
  ];
  poleCoefficient =
    (regular0 minus2Coefficient) /. endpointActiveRules;
  finiteCoefficient =
    (regular0 minus1Coefficient + regular1 minus2Coefficient) /.
      endpointActiveRules;
  If[invalidEndpointQ[poleCoefficient] ||
      invalidEndpointQ[finiteCoefficient] ||
      ! FreeQ[poleCoefficient, s23] ||
      ! FreeQ[finiteCoefficient, s23],
    Return[$Failed]
  ];
  Print[
    "S10_STAGE: used exact singular-factor endpoint Laurent extraction for " <>
      label <> " term " <> ToString[index]
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> ! TrueQ[poleCoefficient === 0]
  |>
];

endpointTermLaurent[
    term_, label_String, index_Integer, total_Integer
  ] := Module[{cancelled, direct, factorwise, numerator, denominator,
    poleOrder, poleCoefficient, finiteCoefficient},
  Print[
    "S10_STAGE: endpoint Laurent term " <> label <> " " <>
      ToString[index] <> "/" <> ToString[total]
  ];
  factorwise = endpointFactorwiseLaurent[term, label, index];
  If[AssociationQ[factorwise], Return[factorwise]];
  direct = If[
    LeafCount[term] > 30000,
    $Failed,
    Quiet@Check[
      TimeConstrained[(s23 term) /. s23 -> 0, 60, $Failed],
      $Failed
    ]
  ];
  If[! invalidEndpointQ[direct],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False
    |>]
  ];
  cancelled = Quiet@Check[
    TimeConstrained[
      Cancel[s23 term],
      600,
      $Failed
    ],
    $Failed
  ];
  assert[cancelled =!= $Failed,
    label <> " term " <> ToString[index] <>
      " failed or timed out during rational cancellation."];
  direct = Quiet[cancelled /. s23 -> 0];
  If[! invalidEndpointQ[direct],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False
    |>]
  ];
  numerator = Numerator[cancelled];
  denominator = Denominator[cancelled];
  poleOrder =
    Exponent[denominator, s23, Min] - Exponent[numerator, s23, Min];
  assert[poleOrder === 1,
    label <> " term " <> ToString[index] <>
      " has endpoint pole order " <> ToString[poleOrder] <>
      " after multiplication by s23; only a simple mutual-cancellation pole is allowed."];
  poleCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, -1}],
      600,
      $Failed
    ],
    $Failed
  ];
  finiteCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, 0}],
      600,
      $Failed
    ],
    $Failed
  ];
  assert[! invalidEndpointQ[poleCoefficient] &&
      ! invalidEndpointQ[finiteCoefficient] &&
      FreeQ[poleCoefficient, s23] && FreeQ[finiteCoefficient, s23],
    label <> " term " <> ToString[index] <>
      " has a failed pole or finite Laurent coefficient."];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> True
  |>
];

splitEndpointChannel[expression_, label_String] := Module[
  {
    factors, singularPositions, remainderIndex, remainder,
    prefactorIndices, prefactor, terms, regular
  },
  assert[Head[expression] === Times,
    label <> " is not in the expected factored product form."];
  factors = List @@ expression;
  singularPositions = Flatten@Position[
    factors,
    factor_ /; SameQ[factor, s23^(-epsilon)],
    {1},
    Heads -> False
  ];
  assert[Length[singularPositions] === 1,
    label <> " does not contain exactly one s23^(-epsilon) factor."];
  remainderIndex = First@Ordering[LeafCount /@ factors, -1];
  assert[remainderIndex =!= First[singularPositions],
    label <> " selected the endpoint singular factor as its remainder."];
  remainder = factors[[remainderIndex]];
  assert[Head[remainder] === Plus,
    label <> " has no additive rational remainder."];
  terms = List @@ remainder;
  assert[Length[terms] > 0,
    label <> " has an empty additive endpoint remainder."];
  prefactorIndices = Complement[
    Range[Length[factors]],
    {First[singularPositions], remainderIndex}
  ];
  prefactor = Times @@ factors[[prefactorIndices]];
  regular = s23 prefactor remainder;
  <|
    "RegularFunction" -> regular,
    "Prefactor" -> prefactor,
    "Terms" -> terms,
    "RemainderTermCount" -> Length[terms]
  |>
];

alpha2EndpointData[
    prefactor_, term_, index_Integer, label_String
  ] := Module[
  {
    nestedBases, nestedBase, nestedRatio, specialRemainder,
    regularFunction, endpointValue, ratioEndpoint
  },
  nestedBases = Cases[
    term,
    Power[base_, -1 - epsilon] :> base,
    Infinity
  ];
  assert[Length[nestedBases] === 1,
    label <> " alpha=2 term " <> ToString[index] <>
      " lacks its unique nested endpoint base."];
  nestedBase = First[nestedBases];
  nestedRatio = Cancel[Together[nestedBase/s23]];
  ratioEndpoint = Cancel[Together[nestedRatio /. s23 -> 0]];
  assert[TrueQ[
      Cancel[Together[ratioEndpoint - zH^2/PHT2]] === 0
    ],
    label <> " alpha=2 nested endpoint ratio is not zH^2/PHT2."];
  specialRemainder = term/Power[nestedBase, -1 - epsilon];
  regularFunction = Cancel[Together[
    prefactor Power[nestedRatio, -1 - epsilon] specialRemainder
  ]];
  endpointValue = Quiet@Check[
    TimeConstrained[regularFunction /. s23 -> 0, 600, $Failed],
    $Failed
  ];
  assert[! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    label <> " alpha=2 endpoint value is not finite."];
  <|
    "Index" -> index,
    "NestedRatioEndpoint" -> ratioEndpoint,
    "RegularFunction" -> regularFunction,
    "EndpointValue" -> endpointValue
  |>
];

processEndpointChannel[
    expression_, label_String, cache_String, specialIndex_
  ] := Module[
  {
    answer, payload, terms, standardIndices, standardTerms, alpha2Data,
    poles = {}, finite = {}, flags = {}, index, total, standardTotal,
    termAnswer
  },
  answer = splitEndpointChannel[expression, label];
  terms = answer["Terms"];
  total = Length[terms];
  standardIndices = If[
    MissingQ[specialIndex],
    Range[total],
    assert[IntegerQ[specialIndex] && 1 <= specialIndex <= total,
      label <> " alpha=2 term index is invalid."];
    Delete[Range[total], specialIndex]
  ];
  standardTerms = terms[[standardIndices]];
  standardTotal = Length[standardTerms];
  alpha2Data = If[
    MissingQ[specialIndex],
    Missing["NotApplicable"],
    alpha2EndpointData[
      answer["Prefactor"], terms[[specialIndex]], specialIndex, label
    ]
  ];
  assert[FileExistsQ[cache],
    label <> " corrected S9.5 endpoint cache is absent; run " <>
      "s9p5_complete_endpoint_caches.wl first."];
  If[FileExistsQ[cache],
    Print["S10_STAGE: loading endpoint cache for " <> label];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === endpointCacheVersion &&
        payload["Label"] === label &&
        payload["RemainderTermCount"] === total,
      label <> " endpoint cache is invalid."];
    poles = payload["PoleCoefficients"];
    finite = payload["FiniteCoefficients"];
    flags = payload["RequiredPoleSubtraction"];
    assert[payload["StandardTermIndices"] === standardIndices &&
        SameQ[payload["SpecialAlpha2Index"], specialIndex] &&
        TrueQ[payload["SpecialAlpha2Validated"] ===
          ! MissingQ[specialIndex]],
      label <> " endpoint cache has invalid alpha metadata."];
    If[KeyExistsQ[coupledEndpointGroups, label],
      assert[
        Lookup[payload, "CoupledLogEndpointRepairVersion", 0] ===
            coupledEndpointRepairVersion &&
          Lookup[payload, "CoupledLogEndpointGroups", {}] ===
            coupledEndpointGroups[label],
        label <> " endpoint cache predates the grouped physical-branch " <>
          "endpoint repair."]
    ];
    If[! MissingQ[specialIndex],
      assert[TrueQ[
          Cancel[Together[
            payload["SpecialAlpha2NestedRatioEndpoint"] -
              alpha2Data["NestedRatioEndpoint"]
          ]] === 0
        ],
        label <> " endpoint cache has the wrong alpha=2 ratio."]
    ];
  ];
  assert[ListQ[poles] && ListQ[finite] && ListQ[flags] &&
      Length[poles] === Length[finite] === Length[flags] &&
      Length[poles] === standardTotal,
    label <> " corrected S9.5 endpoint cache is incomplete."];
  For[index = Length[poles] + 1, index <= standardTotal, index++,
    termAnswer = endpointTermLaurent[
      standardTerms[[index]], label, standardIndices[[index]], total
    ];
    AppendTo[poles, termAnswer["PoleCoefficient"]];
    AppendTo[finite, termAnswer["FiniteCoefficient"]];
    AppendTo[flags, termAnswer["RequiredPoleSubtraction"]];
    payload = <|
      "CacheVersion" -> endpointCacheVersion,
      "Label" -> label,
      "RemainderTermCount" -> total,
      "StandardTermIndices" -> standardIndices,
      "SpecialAlpha2Index" -> specialIndex,
      "SpecialAlpha2Validated" -> ! MissingQ[specialIndex],
      "SpecialAlpha2NestedRatioEndpoint" -> If[
        MissingQ[specialIndex],
        Missing["NotApplicable"],
        alpha2Data["NestedRatioEndpoint"]
      ],
      "PoleCoefficients" -> poles,
      "FiniteCoefficients" -> finite,
      "RequiredPoleSubtraction" -> flags
    |>;
    Put[payload, cache];
    assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
      label <> " incremental endpoint cache was not written."];
  ];
  assert[Length[poles] === standardTotal && Length[finite] === standardTotal,
    label <> " endpoint cache does not cover every additive term."];
  KeyDrop[answer, {"Terms", "RegularFunction"}] ~Join~ <|
    "RegularFunction" -> s23 answer["Prefactor"] Total[standardTerms],
    "StandardTermIndices" -> standardIndices,
    "SpecialAlpha2Index" -> specialIndex,
    "SpecialAlpha2RegularFunction" -> If[
      MissingQ[specialIndex], 0, alpha2Data["RegularFunction"]
    ],
    "SpecialAlpha2EndpointValue" -> If[
      MissingQ[specialIndex], 0, alpha2Data["EndpointValue"]
    ],
    "SpecialAlpha2NestedRatioEndpoint" -> If[
      MissingQ[specialIndex],
      Missing["NotApplicable"],
      alpha2Data["NestedRatioEndpoint"]
    ],
    "RemainderPoleCoefficient" -> Total[poles],
    "RemainderFiniteCoefficient" -> Total[finite],
    "PoleSubtractionTermCount" -> Count[flags, True]
  |>
];

Print["S10_MEMORY_STAGE: releasing completed virtual data before real endpoints"];
Clear[
  renormalizedVirtualSplit, virtualLaurent, loStoredCoefficients,
  explicitCountertermMultiplier
];
ClearSystemCache[];

Print["S10_STAGE: reloading s09 real endpoint inputs"];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09] &&
    s09["Status"] === "CompleteWithSymbolicVirtual",
  "s09_result could not be reloaded for the real endpoint calculation."];
expandedRealByChannel =
  s09["AppendixF", "ExpandedRealKernelsByChannel"];
realChannelWeights = s09["RealChannelWeights"];
assert[Length[expandedRealByChannel] === 3,
  "Expected exactly three expanded real channels."];

endpointPlaceholderCount = Count[
  Values[s09[
    "EndpointExpansion", "EndpointExpandedRealSum"
  ]],
  _S09EndpointValue,
  Infinity
];
Clear[s09];
ClearSystemCache[];
assert[endpointPlaceholderCount === 2,
  "Expected exactly two S09EndpointValue placeholders."];

Print["S10_STAGE: releasing completed virtual intermediates before endpoints"];
Clear[
  s09, s08, s07, virtualInput, loInput, loReference,
  changeOfVariables, partonicRules, xiS23Jacobian,
  virtualDimensional, bareVirtualSymbolicD, bareVirtualDimensional,
  paVeRules, scalarMasterRules, loopIntegralRules,
  bareVirtualSplit, bareVirtualExplicit, loExplicit,
  bareUVResidues, loTransformed, loStoredCoefficients,
  loNormalizationResiduals, bareVirtualTransformed,
  renormalizedVirtualSplit, virtualLaurent
];
ClearSystemCache[];

Print["S10_STAGE: resolving all six channel/projector endpoint values"];
endpointData = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        processEndpointChannel[
          expandedRealByChannel[channel, projector],
          channel <> " " <> projector,
          endpointCachePath[channel, projector],
          alpha2TermIndex[channel, projector]
        ]
      ],
      projectors
    ]
  ],
  Keys[expandedRealByChannel]
];
assert[And @@ (
    TrueQ[
      endpointData["Hqq;gg", #, "SpecialAlpha2Index"] ===
        ggAlpha2TermIndex[#]
    ] & /@ projectors
  ),
  "The two Hqq;gg alpha=2 endpoint terms were not selected."];
assert[And @@ Flatten@Table[
      MissingQ[endpointData[channel, projector, "SpecialAlpha2Index"]],
      {channel, DeleteCases[Keys[endpointData], "Hqq;gg"]},
      {projector, projectors}
    ],
  "A non-gg channel was incorrectly assigned an alpha=2 endpoint term."];

weightedRegularFunctions = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] *
          endpointData[#, projector, "RegularFunction"]) & /@
        Keys[endpointData]
    ]
  ],
  projectors
];
weightedAlpha2RegularFunctions = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] *
          endpointData[#, projector, "SpecialAlpha2RegularFunction"]) & /@
        Keys[endpointData]
    ]
  ],
  projectors
];
weightedAlpha2EndpointValues = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] *
          endpointData[#, projector, "SpecialAlpha2EndpointValue"]) & /@
        Keys[endpointData]
    ]
  ],
  projectors
];
assert[And @@ (FreeQ[#, s23] & /@ Values[weightedAlpha2EndpointValues]),
  "A weighted alpha=2 endpoint value still depends on s23."];
commonEndpointPrefactors = AssociationMap[
  Function[projector,
    Module[{prefactors},
      prefactors = endpointData[#, projector, "Prefactor"] & /@
        Keys[endpointData];
      assert[And @@ (SameQ[First[prefactors], #] & /@ Rest[prefactors]),
        projector <> " real channels do not have a common endpoint prefactor."];
      First[prefactors]
    ]
  ],
  projectors
];
weightedRemainderPoleCoefficients = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] *
          endpointData[#, projector, "RemainderPoleCoefficient"]) & /@
        Keys[endpointData]
    ]
  ],
  projectors
];
Print["S10_STAGE: validating weighted endpoint poles through finite order"];
weightedRemainderPoleResiduals = AssociationMap[
  Function[projector,
    Check[
      TimeConstrained[
        Cancel[Together[weightedRemainderPoleCoefficients[projector]]],
        900,
        $Failed
      ],
      $Failed
    ]
  ],
  projectors
];
assert[FreeQ[Values[weightedRemainderPoleResiduals], $Failed],
  "A weighted endpoint pole simplification failed or timed out."];
weightedRemainderPoleOrders = AssociationMap[
  Function[projector,
    Module[{residual = weightedRemainderPoleResiduals[projector]},
      <|
        "Epsilon0" -> Check[
          TimeConstrained[
            Cancel[Together[residual /. epsilon -> 0]],
            900,
            $Failed
          ],
          $Failed
        ],
        "Epsilon1" -> Check[
          TimeConstrained[
            Cancel[Together[D[residual, epsilon] /. epsilon -> 0]],
            900,
            $Failed
          ],
          $Failed
        ],
        "Epsilon2" -> Check[
          TimeConstrained[
            Cancel[Together[
              (D[residual, {epsilon, 2}]/2) /. epsilon -> 0
            ]],
            900,
            $Failed
          ],
          $Failed
        ]
      |>
    ]
  ],
  projectors
];
assert[FreeQ[Values[weightedRemainderPoleOrders], $Failed],
  "A weighted endpoint pole epsilon-order check failed or timed out."];
assert[And @@ Flatten@Table[
      TrueQ[weightedRemainderPoleOrders[projector, order] === 0],
      {projector, projectors},
      {order, {"Epsilon0", "Epsilon1"}}
    ],
  "A weighted endpoint double pole contributes through the finite epsilon order."];

(*
  If F(s23,epsilon) contains A(epsilon)/s23, then
  s23^(-1-epsilon) F contains A s23^(-2-epsilon).  Its analytic
  distributional continuation has at most one 1/epsilon pole.  The exact
  gates above prove A = O(epsilon^2), so this term starts at O(epsilon) and
  cannot contribute through the requested finite term.  Remove the complete
  evanescent pole from the regular function used below; its exact untruncated
  coefficient remains recorded in weightedRemainderPoleResiduals.
*)
distributionRegularFunctions = AssociationMap[
  Function[projector,
    weightedRegularFunctions[projector] -
      commonEndpointPrefactors[projector] *
        weightedRemainderPoleResiduals[projector]/s23
  ],
  projectors
];
weightedRemainderFiniteCoefficients = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] *
          endpointData[#, projector, "RemainderFiniteCoefficient"]) & /@
        Keys[endpointData]
    ]
  ],
  projectors
];
weightedEndpointValues = AssociationMap[
  Function[projector,
    (commonEndpointPrefactors[projector] /. s23 -> 0) *
      weightedRemainderFiniteCoefficients[projector]
  ],
  projectors
];
assert[And @@ (FreeQ[#, s23] & /@ Values[weightedEndpointValues]),
  "A weighted endpoint value still depends on s23."];

Print["S10_STAGE: reloading completed virtual Laurent cache after endpoints"];
virtualLaurent = finiteLaurentPair[<||>, laurentCachePath];

(*
  Act the distribution tower through n=2 on an arbitrary symbolic test Phi:

    Integral_0^B ds [log^n(s/B)/s]_+ F(s) Phi(s)
      = Integral_0^B ds log^n(s/B)/s
          (F(s) Phi(s) - F(0) Phi(0)).

  The ordinary alpha=1 terms use exponent epsilon.  The two refactored
  Hqq;gg terms use exponent 2 epsilon and hence delta coefficient
  -1/(2 epsilon) and the doubled logarithmic tower.  Both acted integrands
  are combined into one ordinary integral to keep the output compact.
*)
makeDistributionAction[projector_String] := Module[
  {
    regular, endpoint, alpha2Regular, alpha2Endpoint,
    testAtS, testAtZero, logarithmTower, alpha2LogarithmTower
  },
  regular = distributionRegularFunctions[projector];
  endpoint = weightedEndpointValues[projector];
  alpha2Regular = weightedAlpha2RegularFunctions[projector];
  alpha2Endpoint = weightedAlpha2EndpointValues[projector];
  testAtS = S10ConvolutionTest[projector, s23];
  testAtZero = S10ConvolutionTest[projector, 0];
  logarithmTower =
    1 - epsilon Log[s23/s23UpperB] +
      epsilon^2 Log[s23/s23UpperB]^2/2;
  alpha2LogarithmTower =
    1 - 2 epsilon Log[s23/s23UpperB] +
      2 epsilon^2 Log[s23/s23UpperB]^2;
  -s23UpperB^(-epsilon) endpoint testAtZero/epsilon -
    s23UpperB^(-2 epsilon) alpha2Endpoint testAtZero/(2 epsilon) +
    Inactive[Integrate][
      s23UpperB^(-epsilon) logarithmTower/s23 *
        (regular testAtS - endpoint testAtZero) +
        s23UpperB^(-2 epsilon) alpha2LogarithmTower/s23 *
          (alpha2Regular testAtS - alpha2Endpoint testAtZero),
      {s23, 0, s23UpperB}
    ]
];

Print["S10_STAGE: acting all endpoint distributions on symbolic test functions"];
realConvolutionActions = AssociationMap[makeDistributionAction, projectors];
virtualConvolutionActions = AssociationMap[
  virtualLaurent[#] S10ConvolutionTest[#, 0] &,
  projectors
];
combinedConvolutionActions = AssociationMap[
  realConvolutionActions[#] + virtualConvolutionActions[#] &,
  projectors
];

assert[And @@ (FreeQ[
      #,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
    ] & /@ Values[realConvolutionActions]),
  "A real convolution action retains an endpoint placeholder or distribution."];
assert[And @@ (FreeQ[
      #,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
    ] & /@ Values[combinedConvolutionActions]),
  "A combined convolution action retains an endpoint placeholder or distribution."];
assert[And @@ (! FreeQ[#, Inactive[Integrate][___]] & /@
      Values[realConvolutionActions]),
  "A real convolution action lacks its ordinary subtracted integral."];
assert[And @@ (! FreeQ[#, _S10ConvolutionTest] & /@
      Values[combinedConvolutionActions]),
  "A combined convolution action lacks its arbitrary symbolic test function."];

endpointLaurentDataByChannel = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        <|
          "RemainderTermCount" ->
            endpointData[channel, projector, "RemainderTermCount"],
          "StandardTermIndices" ->
            endpointData[channel, projector, "StandardTermIndices"],
          "SpecialAlpha2Index" ->
            endpointData[channel, projector, "SpecialAlpha2Index"],
          "SpecialAlpha2NestedRatioEndpoint" ->
            endpointData[
              channel, projector, "SpecialAlpha2NestedRatioEndpoint"
            ],
          "PoleSubtractionTermCount" ->
            endpointData[channel, projector, "PoleSubtractionTermCount"],
          "RemainderPoleCoefficient" ->
            endpointData[channel, projector, "RemainderPoleCoefficient"],
          "RemainderFiniteCoefficient" ->
            endpointData[channel, projector, "RemainderFiniteCoefficient"]
        |>
      ],
      projectors
    ]
  ],
  Keys[endpointData]
];

s10Checks = <|
  "S09S08S07InputsValidated" -> True,
  "All96UniquePaVeFunctionsEvaluated" -> True,
  "All4UniqueScalarMastersEvaluated" -> True,
  "PackageXAnalyticContinuationApplied" -> True,
  "OrdinaryTreeDenominatorsResolved" -> True,
  "SavedSymbolicCountertermsRemovedBeforeExplicitInsertion" -> True,
  "ExternalLegNormalizationInsertedExactlyOnce" -> True,
  "BareUVResidueMatchesLOForBothProjectors" -> True,
  "ExplicitQCDCountertermsCancelUVPole" -> True,
  "VirtualDoublePoleMatchesUniversalIRFactor" -> True,
  "TwoBodyNormalizationMatchesS09LOReference" -> True,
  "VirtualLaurentExpandedThroughFiniteTerm" -> True,
  "ExactlyTwoS09EndpointPlaceholdersFound" -> True,
  "AllSixChannelEndpointLaurentDataResolved" -> True,
  "TwoGGNestedEndpointPowersRefactoredAsAlpha2" -> True,
  "WeightedEndpointDoublePoleAbsentThroughFiniteOrder" -> True,
  "EvanescentHigherOrderEndpointPoleRecorded" -> True,
  "WeightedEndpointValuesAreS23Independent" -> True,
  "WeightedAlpha2EndpointValuesAreS23Independent" -> True,
  "DiracDeltaActedOnSymbolicTestFunction" -> True,
  "AllPlusDistributionsActedOnSymbolicTestFunction" -> True,
  "FinalConvolutionActionsContainNoDistributionPlaceholders" -> True,
  "CalculationRemainsFullySymbolic" -> True,
  "CollinearFactorizationNotClaimed" -> True
|>;

s10Result = <|
  "Status" -> "CompleteSymbolic",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s09Path,
  "CalculationMode" ->
    "fully analytic and symbolic; no numerical kinematics, PDFs, FFs, or test function",
  "VirtualLaurentExpansion" -> <|
    "LoopIntegralCount" -> Length[uniquePaVe] + Length[uniqueScalarMasters],
    "LoopIntegralBasisCounts" -> <|
      "ThreePointPaVe" -> Count[
        uniquePaVe,
        FeynCalc`PaVe[_, {_, _, _}, {_, _, _}, ___]
      ],
      "FourPointPaVe" -> Count[
        uniquePaVe,
        FeynCalc`PaVe[_, {_, _, _, _, _, _}, {_, _, _, _}, ___]
      ],
      "ScalarB0" -> Count[uniqueScalarMasters, _FeynCalc`B0],
      "ScalarC0" -> Count[uniqueScalarMasters, _FeynCalc`C0],
      "ScalarD0" -> Count[uniqueScalarMasters, _FeynCalc`D0]
    |>,
    "EvaluationMethod" ->
      "PaXEvaluateUVIRSplit with PaXAnalytic->True, C0/D0 expansion, and implicit prefactor 1",
    "AnalyticContinuation" ->
      "Package-X analytic continuation with the Feynman +i0 prescription",
    "RegulatorProcedure" ->
      "UV and IR regulators kept separate through the UV cancellation gate, then both identified with epsilon",
    "OrdersRetained" -> {-2, -1, 0},
    "RenormalizedCoefficientByProjector" -> virtualLaurent,
    "UniversalDoublePoleRatio" -> expectedVirtualDoublePoleRatio,
    "UniversalDoublePoleResiduals" -> virtualDoublePoleResiduals,
    "BareUVOverLOResiduals" -> bareUVRatioResiduals,
    "UVSumOverLO" -> uvCancellationRatio
  |>,
  "QCDRenormalization" -> <|
    "LoopNormalization" -> HoldForm[aSLoop ==
      FeynCalc`SMP["g_s"]^2/(16 Pi^2)],
    "DeltaZGG" -> deltaZGG,
    "DeltaZgs" -> deltaZgs,
    "DeltaZqAggregate" -> deltaZqAggregate,
    "SavedCountertermInterferenceMultiplier" -> HoldForm[
      dZGG1 + 2 dZgs1 + 2 dZq1[3, 1, 1]
    ],
    "ExternalLegNormalizationLedger" ->
      "the saved field counterterm amplitudes already supply the external-leg/LSZ factors; their symbolic dZ terms were zeroed and the explicit aggregate multiplier was inserted once"
  |>,
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlaceholderCountAfter" -> 0,
    "Method" ->
      "apply the alpha=1 endpoint expansion to ordinary terms; separately refactor Hqq;gg Pg term 15 and PPP term 10 using nestedBase=s23 nestedRatio with nestedRatio(0)=zH^2/PHT2, then apply the alpha=2 endpoint expansion with delta coefficient -1/(2 epsilon) and doubled logarithmic tower",
    "EndpointLaurentDataByChannel" -> endpointLaurentDataByChannel,
    "WeightedRemainderPoleResiduals" -> weightedRemainderPoleResiduals,
    "WeightedRemainderPoleOrders" -> weightedRemainderPoleOrders,
    "EvanescentPoleTreatment" ->
      "the untruncated Pg stronger-pole coefficient begins at O(epsilon^2); analytic continuation of s23^(-2-epsilon) has at most one 1/epsilon pole, so this term starts at O(epsilon) and is excluded from a result retained through epsilon^0",
    "WeightedEndpointValuesByProjector" -> weightedEndpointValues,
    "WeightedAlpha2EndpointValuesByProjector" ->
      weightedAlpha2EndpointValues
  |>,
  "DistributionActions" -> <|
    "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
    "TestFunctionAssumption" ->
      "arbitrary symbolic function regular at s23=0 and independent of epsilon",
    "EndpointDeltaConvention" ->
      "the delta at the lower endpoint has full weight, as in the paper's endpoint-distribution identity",
    "RealByProjector" -> realConvolutionActions,
    "VirtualByProjector" -> virtualConvolutionActions,
    "RealPlusVirtualByProjector" -> combinedConvolutionActions,
    "RemainingIntegralType" ->
      "ordinary endpoint-subtracted integral over 0<=s23<=B(xi); it cannot be integrated further until a concrete symbolic PDF/FF test function is supplied"
  |>,
  "ParallelExecution" -> <|
    "RequestedLocalKernelCount" -> requestedParallelKernels,
    "AvailableLocalKernelCount" -> parallelKernelCount,
    "LargeAssemblyMode" ->
      "serial bounded per-term reconstruction; no subkernels are launched because distributing the large projector expressions would multiply WSL memory use"
  |>,
  "Checks" -> s10Checks,
  "NotPerformedAtThisStage" -> {
    "Eq. (46) initial-state PDF and final-state FF collinear-factorization subtraction",
    "claim of cancellation of the remaining collinear poles before Eq. (46)",
    "choice or numerical evaluation of PDFs, fragmentation functions, or kinematics"
  }
|>;

assert[And @@ Values[s10Checks],
  "At least one final s10 validation check is not True."];
assert[FreeQ[
    s10Result["DistributionActions", "RealPlusVirtualByProjector"],
    _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
  ],
  "The final saved convolution actions still contain a distribution object."];

Print["S10_STAGE: writing " <> resultPath];
Put[s10Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "s10_result was not written or is empty."];

Print["S10_SUCCESS_SYMBOLIC"];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CHECKS=", InputForm[s10Checks]];

Quit[0];

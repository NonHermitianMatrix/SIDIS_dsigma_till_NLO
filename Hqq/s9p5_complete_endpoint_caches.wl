(* ::Package:: *)

(*
  Hqq S9.5 endpoint-cache completion helper.

  This helper intentionally does not load FeynCalc or FeynHelpers.  The s09
  endpoint expressions then remain ordinary symbolic Wolfram expressions,
  so substitution at s23 = 0 cannot trigger package-owned evaluation rules.
  It writes exactly the same version-3 incremental caches consumed by
  s10_complete_virtual_endpoints.wl and performs no numerical substitution.

  Two Hqq;gg terms contain a second endpoint power in a nested factor
  B(s23)^(-1-epsilon), with B(s23)/s23 -> zH^2/PHT2.  They are validated
  and recorded separately as alpha=2 terms and are excluded from the
  ordinary alpha=1 endpoint coefficients.
*)

$HistoryLength = 0;

gibibyte = 1024^3;
parallelMemoryReserveBytes = 6 gibibyte;
parallelWorkerBudgetBytes = 1280 1024^2;
availableMemoryAtLaunch = Quiet@Check[MemoryAvailable[], 0];
requestedParallelKernels = Min[
  8,
  Max[
    1,
    Floor[
      Max[0, availableMemoryAtLaunch - parallelMemoryReserveBytes]/
        parallelWorkerBudgetBytes
    ]
  ]
];
Print[
  "S9P5_MEMORY_PLAN: availableGiB=",
  N[availableMemoryAtLaunch/gibibyte, 4],
  " reserveGiB=", N[parallelMemoryReserveBytes/gibibyte, 3],
  " workerLimitGiB=", N[parallelWorkerBudgetBytes/gibibyte, 3],
  " requestedKernels=", requestedParallelKernels
];
parallelKernelExecutable =
  "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel";
parallelKernelConfiguration = If[
  Length[$ConfiguredKernels] > 0,
  ReplacePart[
    First[$ConfiguredKernels],
    {
      {1, "KernelCommand"} -> parallelKernelExecutable,
      {1, "KernelCount"} -> requestedParallelKernels,
      {1, "UseKernelForking"} -> False,
      {1, "LimitByLicense"} -> True
    }
  ],
  Missing["NoLocalKernelConfiguration"]
];
parallelLaunchResult = Quiet@Check[
  If[
    MissingQ[parallelKernelConfiguration],
    {},
    LaunchKernels[parallelKernelConfiguration]
  ],
  {}
];
parallelKernelCount = Max[1, $KernelCount];
Print["S9P5_ENDPOINT_PARALLEL_KERNELS=", $KernelCount];

ClearAll[
  fatal, assert, invalidEndpointQ, endpointFactorwiseLaurent,
  endpointTermLaurent, splitEndpointChannel, alpha2EndpointData,
  alpha2TermIndex, exactPhysicalZeroQ, coupledEndpointGroups,
  coupledEndpointGroupFinite, repairCoupledEndpointGroups,
  processEndpointChannel
];

fatal[message_String] := (
  Print["S9P5_ENDPOINT_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | Indeterminate | ComplexInfinity | DirectedInfinity |
    Power[0, _?Negative]
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s09Path = FileNameJoin[{scriptDirectory, "s09_result"}];
endpointCacheVersion = 3;
legacyEndpointCacheVersion = 2;
coupledEndpointRepairVersion = 1;
projectors = {"Pg", "PPP"};
ggAlpha2TermIndex = <|"Pg" -> 15, "PPP" -> 10|>;
coupledEndpointGroups = <|
  "Hqq;q_qbar_sameFlavor Pg" -> {{17, 29, 39, 55}},
  "Hqq;q_qbar_sameFlavor PPP" -> {{8, 35, 42, 57}}
|>;
endpointReductionTimeoutSeconds = 300;

endpointCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s9p5_cache_v3_endpoint_" <>
    StringReplace[channel, {";" -> "_", "'" -> "p"}] <> "_" <>
    ToLowerCase[projector]
}];

legacyEndpointCachePath[channel_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s9p5_cache_v2_endpoint_" <>
    StringReplace[channel, {";" -> "_", "'" -> "p"}] <> "_" <>
    ToLowerCase[projector]
}];

alpha2TermIndex[channel_String, projector_String] := If[
  channel === "Hqq;gg",
  ggAlpha2TermIndex[projector],
  Missing["NotApplicable"]
];

exactPhysicalZeroQ[expression_, assumptions_] := Module[
  {combined, simplified},
  combined = Quiet@Check[
    TimeConstrained[
      Together[expression],
      endpointReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  If[combined === $Failed, Return[False]];
  If[TrueQ[combined === 0], Return[True]];
  simplified = Quiet@Check[
    TimeConstrained[
      FullSimplify[combined, Assumptions -> assumptions],
      endpointReductionTimeoutSeconds,
      $Failed
    ],
    $Failed
  ];
  TrueQ[simplified === 0]
];

(*
  Some same-flavor endpoint logarithms have arguments proportional to s23
  only after the physical square-root branch is resolved.  Their Log[s23]
  pieces cancel between four additive terms.  Evaluating each term at s23=0
  first loses that cancellation and leaves a spurious Log[0]^2 downstream.

  Resolve the validated physical root separately on both signs of

    delta = a zH - rT (1-zH),

  replace every vanishing logarithm by Log[s23]+Log[slope], and prove that
  every positive power of the inert endpoint logarithm cancels in the group.
  No branch-blind PowerExpand is used.
*)
coupledEndpointGroupFinite[
    sourceTerms_List, finiteTerms_List, sourceIndices_List,
    label_String
  ] := Module[
  {
    aPhysical, rTPhysical, denominatorPhysical, deltaPhysical,
    expectedRootRadicand, physicalSubstitution, inverseSubstitution,
    originalDelta, endpointLog, heldLog, heldPolyLog, qcdRules,
    branchResults = <||>, rootSign, positiveRoot, rootRule,
    branchAssumptions, canonical, transformTerm, branchTerms,
    maximumDegree, coefficient, constant, groupResult, groupPosition
  },
  assert[Length[sourceTerms] === Length[finiteTerms] ===
      Length[sourceIndices],
    label <> " coupled endpoint group has inconsistent term lists."];
  denominatorPhysical = rTPhysical + zH - rTPhysical zH;
  deltaPhysical = aPhysical zH - rTPhysical (1 - zH);
  expectedRootRadicand =
    Q2^2 deltaPhysical^2/denominatorPhysical^2;
  physicalSubstitution = {
    xi -> xB (1 + aPhysical),
    PHT2 -> rTPhysical Q2 aPhysical zH (1 - zH)
  };
  inverseSubstitution = {
    aPhysical -> xi/xB - 1,
    rTPhysical ->
      PHT2/(Q2 (xi/xB - 1) zH (1 - zH))
  };
  originalDelta = Factor[Together[deltaPhysical /. inverseSubstitution]];
  qcdRules = {
    FeynCalc`TF -> 1/2,
    FeynCalc`CF -> (FeynCalc`CA^2 - 1)/(2 FeynCalc`CA)
  };

  Do[
    positiveRoot = rootSign Q2 deltaPhysical/denominatorPhysical;
    rootRule = HoldPattern[
      Power[
        rootArgument_,
        rootPower_Rational?((Denominator[#] === 2) &)
      ]
    ] /; TrueQ[
      Cancel[Together[rootArgument - expectedRootRadicand]] === 0
    ] :> positiveRoot^(2 rootPower);
    canonical[value_] := FixedPoint[
      Factor[Together[# /. rootRule]] &,
      value,
      3
    ];
    branchAssumptions =
      aPhysical > 0 && 0 < rTPhysical < 1 && 0 < zH < 1 &&
        Q2 > 0 && rootSign deltaPhysical > 0;

    transformTerm[sourceTerm_, finiteTerm_, sourceIndex_] := Module[
      {
        held, transformed, rootRadicands, sourceLogArguments,
        zeroSourceLogArguments, slopes, slope, zeroHeldLogCount = 0,
        result
      },
      held = finiteTerm /. Log[value_] :> heldLog[value];
      held = held /. PolyLog[order_, value_] :> heldPolyLog[order, value];
      transformed = held /. physicalSubstitution;
      rootRadicands = DeleteDuplicates@Cases[
        transformed,
        Power[
          radicand_,
          power_Rational?((Denominator[#] === 2) &)
        ] :> radicand,
        Infinity
      ];
      assert[And @@ (
          TrueQ[Cancel[Together[# - expectedRootRadicand]] === 0] & /@
            rootRadicands
        ),
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected physical endpoint square root."];
      transformed = transformed /. rootRule;

      sourceLogArguments = DeleteDuplicates@Cases[
        sourceTerm,
        Log[value_] :> value,
        Infinity
      ];
      zeroSourceLogArguments = Select[
        sourceLogArguments,
        TrueQ[canonical[(# /. physicalSubstitution) /. s23 -> 0] === 0] &
      ];
      slopes = {};
      slope = Missing["NotNeeded"];

      transformed = transformed /. heldLog[value_] :> Module[
        {argument = canonical[value]},
        If[TrueQ[argument === 0],
          zeroHeldLogCount++;
          If[slopes === {},
            slopes = Quiet@DeleteDuplicates[
              canonical[
                ((D[#, s23] /. s23 -> 0) /. physicalSubstitution)
              ] & /@ zeroSourceLogArguments
            ];
            assert[
              Length[slopes] === 1 &&
                And @@ (
                  FreeQ[#, s23] && ! invalidEndpointQ[#] &&
                    ! TrueQ[# === 0] & /@ slopes
                ),
              label <> " term " <> ToString[sourceIndex] <>
                " has a non-linear or invalid vanishing logarithm."];
            slope = First[slopes]
          ];
          assert[! MissingQ[slope] && ! invalidEndpointQ[slope],
            label <> " term " <> ToString[sourceIndex] <>
              " cannot match its endpoint logarithm to a source slope."];
          endpointLog + heldLog[slope],
          heldLog[argument]
        ]
      ];
      transformed = transformed /.
        heldPolyLog[order_, value_] :> heldPolyLog[order, canonical[value]];
      assert[zeroHeldLogCount <= 2,
        label <> " term " <> ToString[sourceIndex] <>
          " has an unexpected number of endpoint logarithms."];
      result = transformed /.
        heldLog[value_] :> Log[value] /.
        heldPolyLog[order_, value_] :> PolyLog[order, value];
      assert[
        FreeQ[result, heldLog | heldPolyLog] &&
          ! invalidEndpointQ[result] && FreeQ[result, s23],
        label <> " term " <> ToString[sourceIndex] <>
          " did not produce a valid branch-resolved endpoint value."];
      result
    ];

    branchTerms = MapThread[
      transformTerm,
      {sourceTerms, finiteTerms, sourceIndices}
    ] /. qcdRules;
    maximumDegree = Max[
      0,
      Sequence @@ Replace[
        Exponent[#, endpointLog] & /@ branchTerms,
        -Infinity -> 0,
        {1}
      ]
    ];
    If[maximumDegree === 0,
      Print[
        "S9P5_COUPLED_ENDPOINT_CHECK: label=", label,
        " rootSign=", rootSign,
        " logPower=none status=log-free-after-branch-grouping"
      ]
    ];
    Do[
      coefficient = Total[
        Coefficient[#, endpointLog, groupPosition] & /@ branchTerms
      ];
      assert[
        exactPhysicalZeroQ[coefficient, branchAssumptions],
        label <> " retains endpoint Log[s23]^" <>
          ToString[groupPosition] <> " on root sign " <>
          ToString[rootSign] <> "."];
      Print[
        "S9P5_COUPLED_ENDPOINT_CHECK: label=", label,
        " rootSign=", rootSign,
        " logPower=", groupPosition,
        " status=zero"
      ];,
      {groupPosition, maximumDegree, 1, -1}
    ];
    constant = Total[(# /. endpointLog -> 0) & /@ branchTerms];
    assert[
      FreeQ[constant, endpointLog | s23] && ! invalidEndpointQ[constant],
      label <> " has an invalid grouped endpoint constant on root sign " <>
        ToString[rootSign] <> "."];
    branchResults[rootSign] = constant;
    Clear[branchTerms, coefficient, constant];
    ClearSystemCache[];,
    {rootSign, {1, -1}}
  ];

  groupResult = Piecewise[
    {{branchResults[1] /. inverseSubstitution, originalDelta >= 0}},
    branchResults[-1] /. inverseSubstitution
  ];
  assert[
    FreeQ[groupResult, endpointLog | heldLog | heldPolyLog | s23] &&
      ! invalidEndpointQ[groupResult],
    label <> " grouped endpoint result is invalid."];
  groupResult
];

repairCoupledEndpointGroups[
    standardTerms_List, standardIndices_List, finite_List,
    groups_List, label_String
  ] := Module[
  {repaired = finite, group, positions, groupedFinite},
  Do[
    positions = Flatten[
      FirstPosition[standardIndices, #] & /@ group
    ];
    assert[Length[positions] === Length[group] &&
        And @@ (IntegerQ /@ positions),
      label <> " coupled endpoint source indices are missing."];
    Print[
      "S9P5_COUPLED_ENDPOINT_STAGE: label=", label,
      " sourceTerms=", group
    ];
    groupedFinite = coupledEndpointGroupFinite[
      standardTerms[[positions]], repaired[[positions]], group, label
    ];
    repaired[[First[positions]]] = groupedFinite;
    Scan[(repaired[[#]] = 0) &, Rest[positions]];,
    {group, groups}
  ];
  repaired
];

Print["S9P5_ENDPOINT_STAGE: loading and validating s09 input without packages"];
assert[FileExistsQ[s09Path], "s09_result does not exist."];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09], "s09_result did not load as an Association."];
assert[s09["Status"] === "CompleteWithSymbolicVirtual",
  "s09_result does not have the expected status."];
assert[And @@ Values[s09["Checks"]],
  "At least one s09 validation check is not True."];

(*
  For term = r(s23) q(s23), with r regular and

    q = q[-2]/s23^2 + q[-1]/s23 + O(1),

  the required Laurent coefficients of s23 term are

    pole   = r(0) q[-2],
    finite = r(0) q[-1] + r'(0) q[-2].

  Every top-level factor is classified summand by summand at the endpoint.
  Only the unique singular factor is regularized, also summand by summand.
*)
endpointFactorwiseLaurent[
    term_, label_String, index_Integer
  ] := Module[
  {
    factors, factorTermLists, factorEndpointTermValues,
    factorRegularFlags, singularIndices, remainderIndex, remainderTerms,
    regularIndices, regularFactorValues, regularDerivativeTermValues,
    regularFactorDerivatives, regular0, regular1, regularizedTerms,
    minus2Terms, minus1Terms, minus2Coefficient, minus1Coefficient,
    poleCoefficient, finiteCoefficient, factorIndex
  },
  If[Head[term] =!= Times, Return[$Failed]];
  factors = List @@ term;
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
      "S9P5_ENDPOINT_STAGE: exact regular extraction for " <> label <>
        " term " <> ToString[index]
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
  poleCoefficient = regular0 minus2Coefficient;
  finiteCoefficient =
    regular0 minus1Coefficient + regular1 minus2Coefficient;
  If[invalidEndpointQ[poleCoefficient] ||
      invalidEndpointQ[finiteCoefficient] ||
      ! FreeQ[poleCoefficient, s23] ||
      ! FreeQ[finiteCoefficient, s23],
    Return[$Failed]
  ];
  Print[
    "S9P5_ENDPOINT_STAGE: exact singular-factor extraction for " <> label <>
      " term " <> ToString[index]
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> ! TrueQ[poleCoefficient === 0]
  |>
];

endpointTermLaurent[
    term_, label_String, index_Integer, total_Integer
  ] := Module[
  {
    factorwise, direct, cancelled, numerator, denominator, poleOrder,
    poleCoefficient, finiteCoefficient
  },
  Print[
    "S9P5_ENDPOINT_STAGE: Laurent term " <> label <> " " <>
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
    TimeConstrained[Cancel[s23 term], 600, $Failed],
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
      " does not have the allowed simple mutual-cancellation pole."];
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
      " has an invalid pole or finite coefficient."];
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
    label <> " is not in the expected product form."];
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
    label <> " selected s23^(-epsilon) as its remainder."];
  remainder = factors[[remainderIndex]];
  assert[Head[remainder] === Plus,
    label <> " has no additive rational remainder."];
  terms = List @@ remainder;
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
    expression_, label_String, cache_String, legacyCache_String,
    specialIndex_
  ] := Module[
  {
    answer, payload, legacyPayload, terms, standardIndices,
    standardTerms, alpha2Data, poles = {}, finite = {}, flags = {},
    index, total, standardTotal, termAnswer, remainingPositions,
    batchPositions, batchInputs, batchAnswers, batchOffset, groups,
    repairCurrent
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
  groups = Lookup[coupledEndpointGroups, label, {}];
  alpha2Data = If[
    MissingQ[specialIndex],
    Missing["NotApplicable"],
    alpha2EndpointData[
      answer["Prefactor"], terms[[specialIndex]], specialIndex, label
    ]
  ];
  If[FileExistsQ[cache],
    Print["S9P5_ENDPOINT_STAGE: loading cache for " <> label];
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
      label <> " endpoint cache has invalid alpha metadata."],
    If[FileExistsQ[legacyCache],
      Print["S9P5_ENDPOINT_STAGE: migrating valid coefficients for " <>
        label <> " into cache version 3"];
      legacyPayload = Check[Get[legacyCache], $Failed];
      assert[AssociationQ[legacyPayload] &&
          legacyPayload["CacheVersion"] === legacyEndpointCacheVersion &&
          legacyPayload["Label"] === label &&
          legacyPayload["RemainderTermCount"] === total &&
          Length[legacyPayload["PoleCoefficients"]] === total &&
          Length[legacyPayload["FiniteCoefficients"]] === total &&
          Length[legacyPayload["RequiredPoleSubtraction"]] === total,
        label <> " legacy endpoint cache is invalid."];
      poles = legacyPayload["PoleCoefficients"][[standardIndices]];
      finite = legacyPayload["FiniteCoefficients"][[standardIndices]];
      flags = legacyPayload["RequiredPoleSubtraction"][[standardIndices]];
    ]
  ];
  assert[ListQ[poles] && ListQ[finite] && ListQ[flags] &&
      Length[poles] === Length[finite] === Length[flags] &&
      Length[poles] <= standardTotal,
    label <> " endpoint cache has inconsistent progress lists."];
  remainingPositions = Range[Length[poles] + 1, standardTotal];
  While[Length[remainingPositions] > 0,
    batchPositions = Take[
      remainingPositions,
      UpTo[Min[requestedParallelKernels, parallelKernelCount]]
    ];
    Print[
      "S9P5_ENDPOINT_STAGE: parallel batch for " <> label <> " positions " <>
        ToString[First[batchPositions]] <> "-" <>
        ToString[Last[batchPositions]] <> "/" <> ToString[standardTotal]
    ];
    batchInputs = (
      {
        standardTerms[[#]], label, standardIndices[[#]], total
      } & /@ batchPositions
    );
    batchAnswers = If[
      $KernelCount > 0,
      ParallelMap[
        endpointTermLaurent[#[[1]], #[[2]], #[[3]], #[[4]]] &,
        batchInputs,
        Method -> "FinestGrained"
      ],
      endpointTermLaurent[#[[1]], #[[2]], #[[3]], #[[4]]] & /@
        batchInputs
    ];
    assert[And @@ (AssociationQ /@ batchAnswers),
      label <> " parallel endpoint batch returned an invalid result."];
    Do[
      termAnswer = batchAnswers[[batchOffset]];
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
      Put[payload, cache];,
      {batchOffset, Length[batchAnswers]}
    ];
    assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
      label <> " incremental endpoint cache was not written."];
    remainingPositions = Drop[remainingPositions, Length[batchPositions]];
  ];
  If[! FileExistsQ[cache],
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
    Put[payload, cache]
  ];
  assert[Length[poles] === standardTotal &&
      Length[finite] === standardTotal && FileExistsQ[cache],
    label <> " endpoint cache is incomplete."];
  repairCurrent = groups === {} || TrueQ[
    AssociationQ[payload] &&
      Lookup[payload, "CoupledLogEndpointRepairVersion", 0] ===
        coupledEndpointRepairVersion &&
      Lookup[payload, "CoupledLogEndpointGroups", {}] === groups
  ];
  If[! repairCurrent,
    finite = repairCoupledEndpointGroups[
      standardTerms, standardIndices, finite, groups, label
    ];
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
      "CoupledLogEndpointRepairVersion" ->
        coupledEndpointRepairVersion,
      "CoupledLogEndpointGroups" -> groups,
      "PoleCoefficients" -> poles,
      "FiniteCoefficients" -> finite,
      "RequiredPoleSubtraction" -> flags
    |>;
    Put[payload, cache];
    assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
      label <> " repaired endpoint cache was not written."];
    Print[
      "S9P5_COUPLED_ENDPOINT_SUCCESS: label=", label,
      " repairVersion=", coupledEndpointRepairVersion
    ];
  ];
  <|
    "Label" -> label,
    "RemainderTermCount" -> total,
    "StandardTermCount" -> standardTotal,
    "SpecialAlpha2Index" -> specialIndex,
    "SpecialAlpha2Validated" -> ! MissingQ[specialIndex],
    "CompletedTermCount" -> Length[poles],
    "CoupledLogEndpointRepairVersion" -> If[
      groups === {},
      Missing["NotApplicable"],
      coupledEndpointRepairVersion
    ]
  |>
];

expandedRealByChannel =
  s09["AppendixF", "ExpandedRealKernelsByChannel"];
assert[Length[expandedRealByChannel] === 3,
  "Expected exactly three expanded real channels."];

If[$KernelCount > 0,
  DistributeDefinitions[
    invalidEndpointQ, endpointFactorwiseLaurent, endpointTermLaurent,
    assert, fatal
  ]
];

Print["S9P5_ENDPOINT_STAGE: completing all six endpoint caches"];
coverage = AssociationMap[
  Function[channel,
    AssociationMap[
      Function[projector,
        processEndpointChannel[
          expandedRealByChannel[channel, projector],
          channel <> " " <> projector,
          endpointCachePath[channel, projector],
          legacyEndpointCachePath[channel, projector],
          alpha2TermIndex[channel, projector]
        ]
      ],
      projectors
    ]
  ],
  Keys[expandedRealByChannel]
];

assert[And @@ Cases[
      coverage,
      association_Association /; KeyExistsQ[association, "CompletedTermCount"] :>
        TrueQ[
          association["CompletedTermCount"] ===
            association["StandardTermCount"]
        ],
      Infinity
    ],
  "At least one endpoint cache did not reach full term coverage."];
assert[And @@ (
    TrueQ[coverage["Hqq;gg", #, "SpecialAlpha2Validated"]] & /@
      projectors
  ),
  "The two Hqq;gg alpha=2 endpoint terms were not validated."];

Print["S9P5_ENDPOINT_CACHE_SUCCESS"];
Quit[0];

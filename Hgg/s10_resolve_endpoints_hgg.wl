(* ::Package:: *)

(*
  Hgg stage S10: resolve and act the real-emission endpoint distributions.

  Reused from the corrected Hqq S10:
    - factored common-prefactor/additive-remainder split,
    - exact factorwise endpoint Laurent extraction,
    - source-bound resumable per-term checkpoints,
    - cancellation gates for spurious stronger endpoint poles,
    - action of the delta/plus tower on a symbolic test function.

  Hgg has no LO or virtual contribution at O(alpha_s^2).  Structural scans,
  rather than Hqq term indices, decide whether an additional vanishing
  epsilon-dependent base or coupled endpoint logarithm is present.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, writeAtomic, invalidEndpointQ, vanishingEndpointQ,
  exceptionalPowerTermIndices, singularLogTermIndices,
  splitEndpointProjection, endpointFactorwiseLaurent,
  endpointTermLaurent, structuralAlpha2EndpointData,
  loadExpansion, processProjection,
  S09EndpointValue, S09PlusDistribution, S09HggFlavorChargeSum,
  S10ConvolutionTest
];

fatal[message_String] := (
  Print["S10_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

writeAtomic[expression_, path_String] := Module[{temporaryPath},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Put[expression, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Temporary output was not written for " <> path <> "."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic output was not installed at " <> path <> "."];
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s09Path = FileNameJoin[{scriptDirectory, "s09_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s10_result"}];
stageVersion = "HggS10-v2";
endpointCacheVersion = 2;
projectors = {"Pg", "PPP"};
endpointCachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s10_cache_v2_endpoint_pg"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s10_cache_v2_endpoint_pp"}]
|>;

Print["S10_STAGE: loading and validating Hgg s09_result"];
assert[FileExistsQ[s09Path], "s09_result does not exist."];
s09 = Check[Get[s09Path], $Failed];
assert[AssociationQ[s09], "s09_result did not load as an Association."];
assert[s09["Status"] === "Complete", "s09_result is not complete."];
assert[s09["Channel"] === "Hgg only", "s09_result is not Hgg-only."];
assert[AllTrue[Values[s09["Checks"]], TrueQ],
  "At least one s09 validation check is not True."];
assert[
  s09["SourceResultSHA256"] ===
    FileHash[s09["SourceResult"], "SHA256"],
  "The S09 source binding to S08 is stale."
];
s09SHA256 = FileHash[s09Path, "SHA256"];
s08SHA256 = s09["SourceResultSHA256"];
expansionCachePaths = s09[
  "AppendixF", "ExpandedKernelCachesByProjector"
];
assert[AssociationQ[expansionCachePaths] &&
    Sort[Keys[expansionCachePaths]] === Sort[projectors],
  "S09 does not provide exactly the Pg/PPP expansion caches."];
assert[AllTrue[Values[expansionCachePaths], FileExistsQ],
  "At least one S09 expansion cache is absent."];
expansionCacheSHA256 = AssociationMap[
  FileHash[expansionCachePaths[#], "SHA256"] &,
  projectors
];
s23UpperB = s09["EndpointExpansion", "UpperLimit"];
assert[! MissingQ[s23UpperB], "The S09 endpoint upper limit is missing."];
flavorChargeWeight = s09[
  "FlavorChargeWeight", "AppliedMultiplicativeWeight"
];
assert[TrueQ[flavorChargeWeight === 9 S09HggFlavorChargeSum],
  "The S09 physical Hgg flavor-charge weight is not the expected ratio."];
endpointPlaceholderCount = s09[
  "EndpointExpansion", "SymbolicPlaceholderCount"
];
assert[endpointPlaceholderCount === 2,
  "Expected exactly two S09 endpoint placeholders."];
assert[s09["VirtualContributionAtThisOrder"] === 0,
  "S09 violates the Hgg no-virtual contract."];
Clear[s09];
ClearSystemCache[];
Print["S10_CHECKPOINT: validated S09 and released its large result"];

invalidEndpointQ[expression_] := ! FreeQ[
  expression,
  $Failed | Indeterminate | ComplexInfinity | DirectedInfinity |
    _Limit | Log[0] | Power[0, _?Negative]
];

vanishingEndpointQ[expression_] := Module[{value, reduced},
  value = Quiet@Check[expression /. s23 -> 0, $Failed];
  If[TrueQ[value === 0], Return[True]];
  If[invalidEndpointQ[value] || ! FreeQ[value, s23], Return[False]];
  reduced = Quiet@Check[
    TimeConstrained[Cancel[Together[value]], 30, $Failed],
    $Failed
  ];
  TrueQ[reduced === 0]
];

exceptionalPowerTermIndices[terms_List] := Flatten@MapIndexed[
  Function[{term, position},
    If[
      Cases[
        term,
        Power[base_, exponent_] /;
          ! FreeQ[exponent, epsilon] && vanishingEndpointQ[base],
        Infinity
      ] === {},
      Nothing,
      First[position]
    ]
  ],
  terms
];

singularLogTermIndices[terms_List] := Flatten@MapIndexed[
  Function[{term, position},
    If[
      AnyTrue[
        Cases[term, Log[argument_] :> argument, Infinity],
        Function[argument,
          Module[{value = Quiet@Check[argument /. s23 -> 0, $Failed]},
            TrueQ[value === 0] || invalidEndpointQ[value]
          ]
        ]
      ],
      First[position],
      Nothing
    ]
  ],
  terms
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
  For a remainder term term, S10 needs the Laurent coefficients of
  s23 term at s23=0.  If one multiplicative factor q is singular,

    q = q[-2]/s23^2 + q[-1]/s23 + O(1),

  while the complementary product r is regular, then

    pole   = r(0) q[-2],
    finite = r(0) q[-1] + r'(0) q[-2].

  This is the corrected low-memory Hqq S10 algorithm.
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
  factorEndpointTermValues = Quiet@Check[
    TimeConstrained[
      ((# /. s23 -> 0 &) /@ # &) /@ factorTermLists,
      120,
      $Failed
    ],
    $Failed
  ];
  If[factorEndpointTermValues === $Failed, Return[$Failed]];
  factorRegularFlags = Map[
    Function[values,
      AllTrue[values, ! invalidEndpointQ[#] && FreeQ[#, s23] &]
    ],
    factorEndpointTermValues
  ];
  singularIndices = Flatten@Position[
    factorRegularFlags, False, {1}, Heads -> False
  ];
  If[Length[singularIndices] === 0,
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> 0,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "factorwise regular"
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
    TimeConstrained[(Cancel[s23^2 #] &) /@ remainderTerms, 600, $Failed],
    $Failed
  ];
  If[regularizedTerms === $Failed, Return[$Failed]];
  minus2Terms = Quiet[(# /. s23 -> 0) & /@ regularizedTerms];
  If[AnyTrue[minus2Terms, invalidEndpointQ] ||
      ! AllTrue[minus2Terms, FreeQ[#, s23] &],
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
  If[minus1Terms === $Failed || AnyTrue[minus1Terms, invalidEndpointQ] ||
      ! AllTrue[minus1Terms, FreeQ[#, s23] &],
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
        ! AllTrue[
          Flatten[regularDerivativeTermValues], FreeQ[#, s23] &
        ],
      Return[$Failed]
    ];
    regularFactorDerivatives = Total /@ regularDerivativeTermValues;
    regular1 = Sum[
      regularFactorDerivatives[[factorIndex]] *
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
      ! FreeQ[poleCoefficient, s23] || ! FreeQ[finiteCoefficient, s23],
    Return[$Failed]
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> ! TrueQ[poleCoefficient === 0],
    "Method" -> "factorwise singular"
  |>
];

endpointTermLaurent[
    term_, label_String, index_Integer, total_Integer
  ] := Module[
  {factorwise, direct, cancelled, numerator, denominator, poleOrder,
    poleCoefficient, finiteCoefficient},
  Print["S10_TERM: " <> label <> " endpoint " <>
    ToString[index] <> "/" <> ToString[total]];
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
  If[! invalidEndpointQ[direct] && FreeQ[direct, s23],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "direct"
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
  If[! invalidEndpointQ[direct] && FreeQ[direct, s23],
    Return[<|
      "PoleCoefficient" -> 0,
      "FiniteCoefficient" -> direct,
      "RequiredPoleSubtraction" -> False,
      "Method" -> "cancelled direct"
    |>]
  ];
  numerator = Numerator[cancelled];
  denominator = Denominator[cancelled];
  poleOrder = Exponent[denominator, s23, Min] -
    Exponent[numerator, s23, Min];
  assert[poleOrder === 1,
    label <> " term " <> ToString[index] <>
      " has endpoint pole order " <> ToString[poleOrder] <>
      " after multiplication by s23."];
  poleCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, -1}], 600, $Failed
    ],
    $Failed
  ];
  finiteCoefficient = Quiet@Check[
    TimeConstrained[
      SeriesCoefficient[cancelled, {s23, 0, 0}], 600, $Failed
    ],
    $Failed
  ];
  assert[
    ! invalidEndpointQ[poleCoefficient] &&
    ! invalidEndpointQ[finiteCoefficient] &&
    FreeQ[poleCoefficient, s23] && FreeQ[finiteCoefficient, s23],
    label <> " term " <> ToString[index] <>
      " has a failed endpoint Laurent coefficient."
  ];
  <|
    "PoleCoefficient" -> poleCoefficient,
    "FiniteCoefficient" -> finiteCoefficient,
    "RequiredPoleSubtraction" -> True,
    "Method" -> "full Laurent fallback"
  |>
];

splitEndpointProjection[expression_, label_String] := Module[
  {factors, singularPositions, remainderIndex, remainder,
    prefactorIndices, prefactor, terms},
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
    label <> " selected s23^(-epsilon) as its remainder."];
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
  <|
    "Prefactor" -> prefactor,
    "Terms" -> terms,
    "RemainderTermCount" -> Length[terms]
  |>
];

(*
  A structurally detected factor base^(-1-epsilon), with base=s23 ratio
  and finite nonzero ratio(0), changes the endpoint exponent from alpha=1
  to alpha=2.  Refactor it without relying on any channel-specific index.
*)
structuralAlpha2EndpointData[
    prefactor_, term_, index_Integer, label_String
  ] := Module[
  {
    powers, nestedBase, nestedExponent, nestedPower, nestedRatio,
    ratioEndpoint, specialRemainder, regularFunction, endpointValue
  },
  powers = DeleteDuplicates@Cases[
    term,
    power : Power[base_, exponent_] /;
      ! FreeQ[exponent, epsilon] && vanishingEndpointQ[base] :>
        {base, exponent, power},
    Infinity
  ];
  assert[Length[powers] === 1,
    label <> " structurally exceptional term " <> ToString[index] <>
      " does not contain exactly one vanishing epsilon-dependent power."];
  {nestedBase, nestedExponent, nestedPower} = First[powers];
  assert[TrueQ[nestedExponent === -1 - epsilon],
    label <> " structurally exceptional term " <> ToString[index] <>
      " has unsupported exponent " <> ToString[InputForm[nestedExponent]] <>
      "; expected -1-epsilon."];
  nestedRatio = Quiet@Check[
    TimeConstrained[Cancel[Together[nestedBase/s23]], 120, $Failed],
    $Failed
  ];
  assert[nestedRatio =!= $Failed,
    label <> " alpha-two nested-ratio reduction failed."];
  ratioEndpoint = Quiet@Check[
    TimeConstrained[
      Cancel[Together[nestedRatio /. s23 -> 0]],
      120,
      $Failed
    ],
    $Failed
  ];
  assert[
    ratioEndpoint =!= $Failed &&
    ! invalidEndpointQ[ratioEndpoint] &&
    FreeQ[ratioEndpoint, s23] &&
    ! TrueQ[ratioEndpoint === 0],
    label <> " alpha-two nested ratio has no finite nonzero endpoint."];
  assert[TrueQ[
      Cancel[Together[ratioEndpoint - zH^2/PHT2]] === 0
    ],
    label <> " alpha-two nested ratio does not match zH^2/PHT2."];
  specialRemainder = term/nestedPower;
  regularFunction = Quiet@Check[
    TimeConstrained[
      Cancel[Together[
        prefactor nestedRatio^(-1 - epsilon) specialRemainder
      ]],
      600,
      $Failed
    ],
    $Failed
  ];
  assert[regularFunction =!= $Failed,
    label <> " alpha-two regular-function construction failed."];
  endpointValue = Quiet@Check[
    TimeConstrained[regularFunction /. s23 -> 0, 600, $Failed],
    $Failed
  ];
  assert[
    ! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    label <> " alpha-two endpoint value is not finite."];
  Print["S10_CHECKPOINT: " <> label <> " term " <> ToString[index] <>
    " structurally refactored as alpha=2"];
  <|
    "SourceTermIndex" -> index,
    "NestedExponent" -> nestedExponent,
    "NestedRatioEndpoint" -> ratioEndpoint,
    "RegularFunction" -> regularFunction,
    "EndpointValue" -> endpointValue
  |>
];

loadExpansion[projector_String] := Module[{payload, path},
  path = expansionCachePaths[projector];
  Print["S10_STAGE: loading S09 Appendix-F cache for " <> projector];
  payload = Check[Get[path], $Failed];
  assert[AssociationQ[payload],
    projector <> " S09 expansion cache is not an Association."];
  assert[payload["StageVersion"] === "HggS09-v1",
    projector <> " S09 expansion cache has the wrong stage version."];
  assert[payload["SourceS08SHA256"] === s08SHA256,
    projector <> " S09 expansion cache has stale S08 provenance."];
  assert[payload["Projector"] === projector,
    projector <> " S09 expansion cache has the wrong projector label."];
  assert[FreeQ[
      payload["Expression"],
      _S08Case2Master | _Hypergeometric2F1 | _Beta
    ],
    projector <> " S09 expansion cache is incomplete."];
  payload["Expression"]
];

processProjection[projector_String] := Module[
  {
    label, expression, split, terms, prefactor, termCount,
    exceptionalIndices, logIndices, alpha2Data,
    standardIndices, standardTerms, standardTermCount,
    cachePath, cachePayload,
    poles = {}, finite = {}, flags = {}, methods = {}, startIndex,
    position, sourceIndex, termAnswer,
    rawPoleResidual, reducedPoleResidual, poleOrders,
    prefactorEndpoint, endpointValue, regularFunction,
    alpha2RegularFunction, alpha2EndpointValue,
    testAtS, testAtZero, logarithmTower, alpha2LogarithmTower, action
  },
  label = "Hgg;q_qbar " <> projector;
  expression = loadExpansion[projector];
  split = splitEndpointProjection[expression, label];
  terms = split["Terms"];
  prefactor = split["Prefactor"];
  termCount = split["RemainderTermCount"];
  Print["S10_STAGE: structural endpoint scan for " <> projector <>
    ", terms=" <> ToString[termCount]];
  exceptionalIndices = exceptionalPowerTermIndices[terms];
  logIndices = singularLogTermIndices[terms];
  assert[logIndices === {},
    projector <> " has structurally detected singular endpoint logarithms " <>
      "at terms " <> ToString[logIndices] <>
      "; grouped treatment is required before continuation."];
  Print["S10_CHECKPOINT: " <> projector <>
    " structural alpha=2 source terms " <>
    ToString[InputForm[exceptionalIndices]]];
  alpha2Data = Map[
    structuralAlpha2EndpointData[
      prefactor, terms[[#]], #, label
    ] &,
    exceptionalIndices
  ];
  standardIndices = Complement[Range[termCount], exceptionalIndices];
  standardTerms = terms[[standardIndices]];
  standardTermCount = Length[standardTerms];
  assert[standardTermCount + Length[alpha2Data] === termCount,
    projector <> " structural endpoint partition is incomplete."];

  cachePath = endpointCachePaths[projector];
  If[FileExistsQ[cachePath],
    cachePayload = Check[Get[cachePath], $Failed];
    If[
      AssociationQ[cachePayload] &&
      cachePayload["CacheVersion"] === endpointCacheVersion &&
      cachePayload["StageVersion"] === stageVersion &&
      cachePayload["Projector"] === projector &&
      cachePayload["SourceExpansionSHA256"] ===
        expansionCacheSHA256[projector] &&
      cachePayload["RemainderTermCount"] === termCount &&
      Lookup[cachePayload, "StandardTermIndices", $Failed] ===
        standardIndices &&
      Lookup[cachePayload, "Alpha2TermIndices", $Failed] ===
        exceptionalIndices &&
      Lookup[cachePayload, "SingularLogTermIndices", $Failed] === {},
      poles = Lookup[cachePayload, "PoleCoefficients", {}];
      finite = Lookup[cachePayload, "FiniteCoefficients", {}];
      flags = Lookup[cachePayload, "RequiredPoleSubtraction", {}];
      methods = Lookup[cachePayload, "Methods", {}];
      assert[
        ListQ[poles] && ListQ[finite] && ListQ[flags] && ListQ[methods] &&
        Length[poles] === Length[finite] === Length[flags] ===
          Length[methods] && Length[poles] <= standardTermCount,
        projector <> " endpoint cache has inconsistent completed lists."
      ];
      Print["S10_STAGE: resuming " <> projector <> " endpoint cache at " <>
        ToString[Length[poles]] <> "/" <> ToString[standardTermCount]],
      Print["S10_STAGE: removing stale endpoint cache for " <> projector];
      DeleteFile[cachePath]
    ]
  ];
  startIndex = Length[poles] + 1;
  For[position = startIndex, position <= standardTermCount, position++,
    sourceIndex = standardIndices[[position]];
    termAnswer = endpointTermLaurent[
      standardTerms[[position]], label, sourceIndex, termCount
    ];
    AppendTo[poles, termAnswer["PoleCoefficient"]];
    AppendTo[finite, termAnswer["FiniteCoefficient"]];
    AppendTo[flags, termAnswer["RequiredPoleSubtraction"]];
    AppendTo[methods, termAnswer["Method"]];
    If[Mod[position, 4] === 0 || position === standardTermCount,
      cachePayload = <|
        "CacheVersion" -> endpointCacheVersion,
        "StageVersion" -> stageVersion,
        "Projector" -> projector,
        "SourceExpansionCache" -> expansionCachePaths[projector],
        "SourceExpansionSHA256" -> expansionCacheSHA256[projector],
        "RemainderTermCount" -> termCount,
        "StandardTermIndices" -> standardIndices,
        "Alpha2TermIndices" -> exceptionalIndices,
        "Alpha2NestedRatioEndpoints" ->
          Lookup[alpha2Data, "NestedRatioEndpoint", {}],
        "SingularLogTermIndices" -> logIndices,
        "PoleCoefficients" -> poles,
        "FiniteCoefficients" -> finite,
        "RequiredPoleSubtraction" -> flags,
        "Methods" -> methods,
        "CompletedStandardTermCount" -> position
      |>;
      writeAtomic[cachePayload, cachePath];
      Print["S10_CACHE_CHECKPOINT: " <> projector <> " " <>
        ToString[position] <> "/" <> ToString[standardTermCount] <>
        " standard terms"];
    ];
  ];
  assert[Length[poles] === standardTermCount &&
      Length[finite] === standardTermCount,
    projector <> " endpoint cache does not cover every standard term."];

  Print["S10_STAGE: reducing stronger endpoint pole for " <> projector];
  rawPoleResidual = Total[poles];
  reducedPoleResidual = Quiet@Check[
    TimeConstrained[Cancel[Together[rawPoleResidual]], 900, $Failed],
    $Failed
  ];
  assert[reducedPoleResidual =!= $Failed,
    projector <> " stronger endpoint-pole reduction failed or timed out."];
  poleOrders = <|
    "Epsilon0" -> Quiet@Check[
      TimeConstrained[
        Cancel[Together[reducedPoleResidual /. epsilon -> 0]],
        900,
        $Failed
      ],
      $Failed
    ],
    "Epsilon1" -> Quiet@Check[
      TimeConstrained[
        Cancel[Together[D[reducedPoleResidual, epsilon] /.
          epsilon -> 0]],
        900,
        $Failed
      ],
      $Failed
    ]
  |>;
  assert[FreeQ[Values[poleOrders], $Failed],
    projector <> " stronger-pole epsilon-order gate timed out."];
  assert[AllTrue[Values[poleOrders], TrueQ[# === 0] &],
    projector <> " has a nonzero stronger endpoint pole through the " <>
      "finite-order requirement."];
  Print["S10_CHECKPOINT: " <> projector <>
    " stronger endpoint pole vanishes through epsilon^1"];

  prefactorEndpoint = Quiet@Check[prefactor /. s23 -> 0, $Failed];
  assert[! invalidEndpointQ[prefactorEndpoint] &&
      FreeQ[prefactorEndpoint, s23],
    projector <> " common prefactor has no finite endpoint."];
  endpointValue = flavorChargeWeight * prefactorEndpoint * Total[finite];
  assert[! invalidEndpointQ[endpointValue] && FreeQ[endpointValue, s23],
    projector <> " endpoint value remains invalid or s23-dependent."];
  regularFunction = flavorChargeWeight * (
    s23 prefactor Total[standardTerms] -
      prefactor reducedPoleResidual/s23
  );
  alpha2RegularFunction = flavorChargeWeight *
    Total[Lookup[alpha2Data, "RegularFunction", {}]];
  alpha2EndpointValue = flavorChargeWeight *
    Total[Lookup[alpha2Data, "EndpointValue", {}]];
  assert[
    ! invalidEndpointQ[alpha2EndpointValue] &&
    FreeQ[alpha2EndpointValue, s23],
    projector <> " alpha-two endpoint value is invalid or s23-dependent."];
  testAtS = S10ConvolutionTest[projector, s23];
  testAtZero = S10ConvolutionTest[projector, 0];
  logarithmTower = 1 - epsilon Log[s23/s23UpperB] +
    epsilon^2 Log[s23/s23UpperB]^2/2;
  alpha2LogarithmTower = 1 - 2 epsilon Log[s23/s23UpperB] +
    2 epsilon^2 Log[s23/s23UpperB]^2;
  action = -s23UpperB^(-epsilon) endpointValue testAtZero/epsilon -
    s23UpperB^(-2 epsilon) alpha2EndpointValue testAtZero/(2 epsilon) +
    Inactive[Integrate][
      s23UpperB^(-epsilon) logarithmTower/s23 *
        (regularFunction testAtS - endpointValue testAtZero) +
      s23UpperB^(-2 epsilon) alpha2LogarithmTower/s23 *
        (alpha2RegularFunction testAtS -
          alpha2EndpointValue testAtZero),
      {s23, 0, s23UpperB}
    ];
  assert[FreeQ[
      action,
      _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
    ],
    projector <> " action retains an endpoint distribution object."];
  assert[! FreeQ[action, Inactive[Integrate][___]],
    projector <> " action lacks its endpoint-subtracted integral."];
  assert[! FreeQ[action, _S10ConvolutionTest],
    projector <> " action lacks the symbolic test function."];
  Print["S10_CHECKPOINT: completed symbolic distribution action for " <>
    projector];
  <|
    "Projector" -> projector,
    "RemainderTermCount" -> termCount,
    "StandardTermIndices" -> standardIndices,
    "Alpha2TermIndices" -> exceptionalIndices,
    "Alpha2NestedRatioEndpoints" ->
      Lookup[alpha2Data, "NestedRatioEndpoint", {}],
    "SingularLogTermIndices" -> logIndices,
    "PoleSubtractionTermCount" -> Count[flags, True],
    "EndpointCache" -> cachePath,
    "EndpointCacheSHA256" -> FileHash[cachePath, "SHA256"],
    "ReducedStrongerPoleResidual" -> reducedPoleResidual,
    "StrongerPoleOrders" -> poleOrders,
    "EndpointValue" -> endpointValue,
    "Alpha2EndpointValue" -> alpha2EndpointValue,
    "Action" -> action,
    "MethodCounts" -> Counts[methods]
  |>
];

Print["S10_STAGE: resolving Pg endpoint Laurent data and action"];
pgData = processProjection["Pg"];
ClearSystemCache[];
Print["S10_MEMORY_STAGE: Pg complete; processing PPP serially"];
pppData = processProjection["PPP"];

endpointDataByProjector = <|
  "Pg" -> KeyDrop[pgData, {"Action"}],
  "PPP" -> KeyDrop[pppData, {"Action"}]
|>;
realConvolutionActions = <|
  "Pg" -> pgData["Action"],
  "PPP" -> pppData["Action"]
|>;
Clear[pgData, pppData];
ClearSystemCache[];

s10Checks = <|
  "CurrentS09SourceBindingVerified" -> True,
  "S09ExpansionCachesValidated" -> True,
  "ExactlyTwoS09EndpointPlaceholdersReceived" -> True,
  "BothProjectorsProcessed" -> True,
  "All164RemainderTermsResolved" ->
    Total[
      (Length[# ["StandardTermIndices"]] +
          Length[# ["Alpha2TermIndices"]]) & /@
        Values[endpointDataByProjector]
    ] === 164,
  "TwoHggAlpha2TermsDetectedStructurally" ->
    Total[
      Length /@ Values[
        endpointDataByProjector[[All, "Alpha2TermIndices"]]
      ]
    ] === 2,
  "AllDetectedAlpha2TermsHavePhysicalNestedRatio" ->
    AllTrue[
      Flatten[Values[
        endpointDataByProjector[[All, "Alpha2NestedRatioEndpoints"]]
      ]],
      TrueQ[Cancel[Together[# - zH^2/PHT2]] === 0] &
    ],
  "NoSingularEndpointLogDetected" ->
    AllTrue[
      Values[
        endpointDataByProjector[[All, "SingularLogTermIndices"]]
      ],
      # === {} &
    ],
  "StrongerEndpointPoleAbsentThroughFiniteRequirement" ->
    AllTrue[
      Flatten[
        Values /@ Values[
          endpointDataByProjector[[All, "StrongerPoleOrders"]]
        ]
      ],
      TrueQ[# === 0] &
    ],
  "PhysicalFlavorChargeWeightRetained" ->
    AllTrue[Values[realConvolutionActions],
      ! FreeQ[#, S09HggFlavorChargeSum] &],
  "EndpointValuesAreS23Independent" ->
    AllTrue[
      Join[
        Values[endpointDataByProjector[[All, "EndpointValue"]]],
        Values[endpointDataByProjector[[All, "Alpha2EndpointValue"]]]
      ],
      FreeQ[#, s23] &
    ],
  "DiracDeltaActedOnSymbolicTestFunction" -> True,
  "AllPlusDistributionsActedOnSymbolicTestFunction" -> True,
  "FinalActionsContainNoDistributionPlaceholders" ->
    AllTrue[Values[realConvolutionActions],
      FreeQ[
        #,
        _S09EndpointValue | _S09PlusDistribution | DiracDelta[s23]
      ] &],
  "NoVirtualContributionIntroduced" -> True,
  "CalculationRemainsFullySymbolic" -> True,
  "CollinearFactorizationNotApplied" -> True
|>;
assert[AllTrue[Values[s10Checks], TrueQ],
  "At least one final S10 validation check is not True."];

s10Result = <|
  "Status" -> "CompleteSymbolic",
  "Channel" -> "Hgg only",
  "Contribution" -> "Hgg;q qbar real endpoint action",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s09Path,
  "SourceResultSHA256" -> s09SHA256,
  "CalculationMode" ->
    "fully analytic and symbolic; no numerical kinematics, PDFs, FFs, or concrete test function",
  "EndpointResolution" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "PhysicalUpperLimit" -> s23UpperB,
    "S09PlaceholderCountBefore" -> endpointPlaceholderCount,
    "S09PlaceholderCountAfter" -> 0,
    "Method" ->
      "corrected Hqq factorwise endpoint Laurent extraction for structurally ordinary alpha=1 terms; every Hgg-detected base^(-1-epsilon) with base/s23 finite is refactored into the alpha=2 delta coefficient and doubled logarithmic tower without fixed Hqq indices",
    "EndpointDataByProjector" -> endpointDataByProjector
  |>,
  "DistributionActions" -> <|
    "TestFunction" -> HoldForm[S10ConvolutionTest[projector, s23]],
    "TestFunctionAssumption" ->
      "arbitrary symbolic function regular at s23=0 and independent of epsilon",
    "EndpointDeltaConvention" ->
      "the lower-endpoint delta has full weight, matching the paper's endpoint identity",
    "RealByProjector" -> realConvolutionActions,
    "VirtualByProjector" -> <|"Pg" -> 0, "PPP" -> 0|>,
    "RemainingIntegralType" ->
      "ordinary endpoint-subtracted integral on 0<=s23<=B(xi); a concrete PDF/FF test function is intentionally not supplied"
  |>,
  "FlavorChargeWeight" -> flavorChargeWeight,
  "VirtualContributionAtThisOrder" -> 0,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "SourceExpansionCaches" -> expansionCachePaths,
    "SourceExpansionSHA256" -> expansionCacheSHA256,
    "EndpointCaches" -> endpointCachePaths,
    "AllCachesSourceBound" -> True
  |>,
  "MemoryStrategy" ->
    "load/process Pg then PPP serially; atomically checkpoint every four standard endpoint terms; retain no S09 monolithic result after metadata validation",
  "Checks" -> s10Checks,
  "NotPerformedAtThisStage" -> {
    "virtual-loop evaluation or QCD UV renormalization, absent for Hgg at this order",
    "Eq. (46) Pqg/Pgq initial-state PDF and final-state FF subtraction",
    "claim of collinear-pole cancellation before factorization",
    "epsilon -> 0 finite hard-part limit",
    "numerical PDF/FF convolution"
  }
|>;

Print["S10_STAGE: writing " <> resultPath];
writeAtomic[s10Result, resultPath];
Print["S10_SUCCESS_SYMBOLIC"];
Print["S10_RESULT_PATH=" <> resultPath];
Print["S10_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S10_CHECKS=", InputForm[s10Checks]];

Quit[0];

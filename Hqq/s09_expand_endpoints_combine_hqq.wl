(* ::Package:: *)

(*
  Hqq stage s09.

  Requested operations:
    1. Substitute the Appendix F epsilon expansions of all case-2 angular
       masters retained by s08. The j=0 one-denominator cases are derived from
       Eq. (B18), and Eq. (B27) is used for the remaining case-1 2F1.
    2. Rewrite the s23 -> 0 real-emission singularity on 0 <= s23 <= B(xi)
       using DiracDelta[s23] and S09PlusDistribution[n,s23,B].
    3. Apply the Hqq real-channel weights and add the two-body virtual
       interference separately for Pg and PPP.

  Important: the inherited virtual term is still symbolic in PaVe functions
  and QCD renormalization constants. Therefore this stage forms and validates
  the real-virtual sum but does not claim explicit pole cancellation. The
  Eq. (46) PDF/FF collinear subtraction is also not performed.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, appendixFExpansion, appendixFZeroJ,
  expandAppendixFMasters, expandCase1Functions,
  endpointDistributionForm, plusDistributionAction,
  validateMasterExpandedPair, validateEndpointPair,
  transformPair, S09PlusDistribution
];

fatal[message_String] := (
  Print["S09_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s08Path = FileNameJoin[{scriptDirectory, "s08_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
cacheVersion = 1;

cachePath[label_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s09_cache_v1_" <> label <> "_" <> ToLowerCase[projector]
}];

Print["S09_STAGE: loading s08_result"];
assert[FileExistsQ[s08Path], "s08_result does not exist."];
s08 = Check[Get[s08Path], $Failed];
assert[AssociationQ[s08], "s08_result did not load as an Association."];
assert[s08["Status"] === "Complete", "s08_result is not complete."];
assert[s08["Channel"] === "Hqq only", "s08_result is not Hqq-only."];
assert[And @@ Values[s08["Checks"]],
  "At least one s08 check is not True."];

realKernels = s08["XiS23ConvolutionKernels", "ThreeBodyReal"];
virtualKernels = s08[
  "XiS23ConvolutionKernels", "TwoBody",
  "NLOVirtualInterference_OAlphaS2_Symbolic"
];
loKernels = s08[
  "XiS23ConvolutionKernels", "TwoBody", "LO_OAlphaS"
];
changeOfVariables = s08["XiS23ChangeOfVariables"];
s23UpperB = changeOfVariables["S23UpperB"];

assert[Length[realKernels] === 3,
  "Expected exactly three real Hqq channels."];
assert[Sort[Keys[virtualKernels]] === Sort[{"Pg", "PPP"}],
  "Virtual kernels do not contain Pg and PPP."];

(* Appendix F abbreviations, Eqs. (F1)-(F5). *)
appendixFExpansion[j_Integer, l_Integer, d_, c_, eps_] := Module[
  {ll, kk, ff, gg, p4, q4, result},
  ll = Log[(d + 1)/(d - 1)];
  kk = PolyLog[2, 2/(d + 1)] - PolyLog[2, -2/(d - 1)];
  ff = c^2 (1 - 3 d^2) + 4 c d + d^2 - 3;
  gg = c^2 (3 d^2 - 1) - 4 c d - d^2 + 3;
  p4 = c^4 (35 d^4 - 30 d^2 + 3) +
    16 c^3 d (3 - 5 d^2) -
    6 c^2 (5 d^4 - 18 d^2 + 5) +
    16 c d (3 d^2 - 5) + 3 d^4 - 30 d^2 + 35;
  q4 = 5 c^4 d (3 - 7 d^2) +
    12 c^3 (5 d^2 - 1) +
    6 c^2 d (5 d^2 - 9) +
    4 c (5 - 9 d^2) - 3 d (d^2 - 5);

  result = Switch[{j, l},

    (* Eq. (F6) *)
    {1, -4},
      Pi/72 (
        -630 c^4 d^3 + 330 c^4 d + 1440 c^3 d^2 - 384 c^3 +
        540 c^2 d^3 - 1764 c^2 d + 9 p4 ll -
        864 c d^2 + 1152 c - 54 d^3 + 522 d
      ) + Pi eps/72 (
        -1773 c^4 d^3 + 943 c^4 d + 3744 c^3 d^2 -
        1024 c^3 + 1674 c^2 d^3 +
        27/2 (c^2 - 1) (d^2 - 1) *
          (c^2 (19 d^2 - 3) - 32 c d - 3 d^2 + 19) ll -
        4398 c^2 d + 9 p4 kk - 2592 c d^2 + 2688 c -
        189 d^3 + 1599 d
      ),

    (* Eq. (F7) *)
    {2, -4},
      Pi/(3 (d^2 - 1)) (
        36 c (3 - 5 c^2) d^3 + 12 c (13 c^2 - 11) d +
        3 (35 c^4 - 30 c^2 + 3) d^4 +
        (-115 c^4 + 222 c^2 - 51) d^2 +
        16 (c^4 - 6 c^2 + 3)
      ) + Pi/2 q4 ll + Pi eps/18 (
        72 (21 - 29 c^2) c d + 32 (39 - 8 c^2) c^2 +
        54 (27 c^4 - 26 c^2 + 3) d^2 - 9 q4 kk - 528
      ) + Pi eps/(2 (d^2 - 1)) (
        c^4 (-11 d^4 + 30 d^2 - 15) d -
        4 c^3 (d^4 + 6 d^2 - 3) +
        6 c^2 (3 d^4 - 2 d^2 + 3) d -
        4 c (3 d^4 - 2 d^2 + 3) - 3 d^5 + 6 d^3 + d
      ) ll,

    (* Eq. (F8) *)
    {1, -3},
      Pi (
        5 c^3 d^2 - 4 c^3/3 -
        1/2 (c d - 1) *
          (5 c^2 d^2 - 3 c^2 - 4 c d - 3 d^2 + 5) ll -
        9 c^2 d - 3 c d^2 + 8 c + 3 d
      ) + Pi eps (
        -1/2 (c d - 1) *
          (c^2 (5 d^2 - 3) - 4 c d - 3 d^2 + 5) kk +
        1/9 (
          117 c^3 d^2 - 32 c^3 -
          27/2 (c d - 1) (c^2 d^2 - c^2 - d^2 + 1) ll -
          189 c^2 d - 81 c d^2 + 156 c + 81 d
        )
      ),

    (* Eq. (F9) *)
    {2, -3},
      3 Pi/2 (
        c (c^2 (5 d^2 - 1) - 6 c d - 3 d^2 + 3) + 2 d
      ) ll + Pi/(d^2 - 1) (
        c^3 d (13 - 15 d^2) + 6 c^2 (3 d^2 - 2) +
        3 c d (3 d^2 - 5) - 6 d^2 + 8
      ) + Pi eps/2 (
        -58 c^3 d +
        3 (c (c^2 (5 d^2 - 1) - 6 c d - 3 d^2 + 3) +
          2 d) kk + 48 c^2 + 42 c d - 24
      ),

    (* Eq. (F12) *)
    {1, -2},
      Pi (d - 3 c^2 d + 4 c - ff ll/2) + Pi eps (
        -gg ll/4 Log[(d - 1) (d + 1)^3/16] -
        ll/2 (-c^2 d^2 + c^2 + d^2 - 1) +
        Pi^2/6 (c^2 (3 d^2 - 1) - 4 c d - d^2 + 3) +
        c (8 - 7 c d) + 3 d -
        gg PolyLog[2, (d - 1)/(d + 1)]
      ),

    (* Eq. (F13) *)
    {2, -2},
      Pi/(d^2 - 1) (
        c^2 (6 d^2 - 4) -
        (d^2 - 1) (c (3 c d - 2) - d) ll -
        4 c d - 2 d^2 + 4
      ) + Pi eps (
        4 (2 c^2 + d (c d - 1)^2 ll/(2 (d^2 - 1)) - 1) -
        (c (3 c d - 2) - d) kk
      ),

    (* Eq. (F15) *)
    {-1, -1},
      2 Pi (c/3 + d) + Pi eps (16 c/9 + 4 d),

    (* Eq. (F16); also follows directly from Eq. (B19) at j=-2,l=0. *)
    {-2, 0},
      2 Pi/3 (3 d^2 + 1) + 4 Pi eps/9 (9 d^2 + 4),

    (* Eq. (F17) *)
    {-1, 0},
      2 Pi d + 4 Pi d eps,

    (* Eq. (F18) *)
    {1, 0},
      Pi ll + Pi eps kk,

    (* Eq. (F19) *)
    {2, 0},
      2 Pi/(d^2 - 1) + 2 Pi eps d ll/(d^2 - 1),

    (* Eq. (F20) *)
    {1, -1},
      Pi (-(c d - 1) ll + 2 c) + Pi eps (
        4 c - Pi^2 (c d - 1)/3 +
        (c d - 1) ll/2 Log[(d - 1) (d + 1)^3/16] +
        2 (c d - 1) PolyLog[2, (d - 1)/(d + 1)]
      ),

    (* Eq. (F21) *)
    {2, -1},
      -Pi (-c (d^2 - 1) ll + 2 c d - 2)/(d^2 - 1) +
      Pi eps (
        -ll (
          c (d^2 - 1) Log[(d - 1) (d + 1)^3/16] +
          4 d (c d - 1)
        )/(2 (d^2 - 1)) + Pi^2 c/3 -
        2 c PolyLog[2, (d - 1)/(d + 1)]
      ),

    (* Eq. (F22) *)
    {-2, 1},
      -Pi (c - d)^2/eps + Pi (-3 c^2 + 4 c d + 1) +
      Pi eps (-7 c^2 + 8 c d + 3),

    (* Eq. (F23) *)
    {-1, 1},
      Pi (c - d)/eps + 2 Pi c + 4 Pi eps c,

    (* Eq. (F24) *)
    {1, 1},
      Pi/(eps (c - d)) +
      Pi Log[(d^2 - 1)/(d - c)^2]/(c - d) +
      2 Pi eps/(c - d) (
        PolyLog[2, (c - 1)/(d - 1)] -
        PolyLog[2, (d - c)/(d + 1)] +
        Log[c + 1] Log[(d + 1)/(d - c)] +
        Log[d - c] Log[(d - c)/(d - 1)] -
        ll/4 Log[(d - 1) (d + 1)^3] + Pi^2/6
      ),

    (* Eq. (F25) *)
    {2, 1},
      -Pi/(eps (d - c)^2) + Pi/((d^2 - 1) (c - d)^2) (
        (d^2 - 1) Log[(d - c)^2/(d^2 - 1)] - 2 c d + 2
      ) + 2 Pi eps/(c - d)^2 (
        PolyLog[2, (d - c)/(d + 1)] -
        PolyLog[2, (c - 1)/(d - 1)]
      ) - Pi eps/(6 (d^2 - 1) (c - d)^2) (
        12 Log[d + 1] (
          (d^2 - 1) Log[c + 1] + c + d^2 - d - 1
        ) - 12 Log[d - 1] (
          (d^2 - 1) Log[d - c] + c - d^2 - d + 1
        ) + (d^2 - 1) (
          2 (6 Log[d - c] (Log[(d - c)/(c + 1)] - 2) + Pi^2) -
          3 ll Log[(d - 1) (d + 1)^3]
        )
      ),

    (* Eq. (F27) *)
    {-1, 2},
      -Pi c/eps + Pi (c - d) + Pi eps (d - c),

    (* Eq. (F28) *)
    {1, 2},
      Pi (1 - c d)/(eps (c - d)^3) + Pi/(c - d)^3 (
        -c^2 - 2 c d + d^2 + 2 +
        (c d - 1) Log[(d - c)^2/(d^2 - 1)]
      ),

    (* Eq. (F29) *)
    {2, 2},
      Pi (c^2 + 2 c d - 3)/(eps (c - d)^4) +
      Pi/((d^2 - 1) (c - d)^4) (
        c^2 (7 d^2 - 5) +
        (d^2 - 1) (c^2 + 2 c d - 3) *
          Log[(d^2 - 1)/(d - c)^2] +
        2 (d^2 - 3) c d - d^2 (d^2 + 5) + 8
      ),

    _, $Failed
  ];
  result
];

(* j=0 is independent of d and c. It is the one-denominator B18 master. *)
appendixFZeroJ[l_Integer, eps_] := Module[{exact},
  exact = 2 Pi Gamma[1 - 2 eps]/Gamma[1 - eps]^2 *
    2^(-l) Beta[1 - eps, 1 - eps - l];
  Normal@Series[FunctionExpand[exact], {eps, 0, 2}]
];

requiredPairs = {
  {-2, 0}, {-2, 1},
  {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {0, -2}, {0, -1}, {0, 1}, {0, 2},
  {1, -4}, {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -4}, {2, -3}, {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};

implementedPairs = Select[
  requiredPairs,
  Function[pair,
    If[First[pair] === 0,
      appendixFZeroJ[Last[pair], epsilon] =!= $Failed,
      appendixFExpansion[
        First[pair], Last[pair], s09DTest, s09CTest, epsilon
      ] =!= $Failed
    ]
  ]
];
assert[Sort[implementedPairs] === Sort[requiredPairs],
  "Appendix F implementation does not cover every required (j,l) pair."];

expandAppendixFMasters[expression_] := expression /. HoldPattern[
    S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon]
  ] :> If[j === 0,
    appendixFZeroJ[l, epsilon],
    appendixFExpansion[j, l, d, c, epsilon]
  ];

(* Eq. (B27), plus local expansions of the gamma/beta building blocks. *)
expandCase1Functions[expression_] := Module[
  {answer, gammaRatio1, gammaRatio2, betaRules},
  gammaRatio1 = Normal@Series[
    Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2,
    {epsilon, 0, 2}
  ];
  gammaRatio2 = Normal@Series[
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon],
    {epsilon, 0, 2}
  ];
  betaRules = (Rule[#, Normal@Series[
        FunctionExpand[#], {epsilon, 0, 2}
      ]] &) /@ DeleteDuplicates@Cases[expression, _Beta, Infinity];
  answer = expression /. HoldPattern[
      Hypergeometric2F1[1, 1, 1 - epsilon, w_]
    ] :> (1 - w)^(-1 - epsilon) *
      (1 + epsilon^2 PolyLog[2, w]);
  answer = answer /. betaRules;
  answer = answer /. HoldPattern[
      Gamma[1 - 2 epsilon]/Gamma[1 - epsilon]^2
    ] :> gammaRatio1;
  answer = answer /. HoldPattern[
      Gamma[1 - epsilon]/Gamma[1 - 2 epsilon]
    ] :> gammaRatio2;
  answer
];

validateMasterExpandedPair[pair_Association, label_String] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " has the wrong projector keys."];
  assert[And @@ (FreeQ[#, _S08Case2Master] & /@ Values[pair]),
    label <> " retains an S08Case2Master."];
  assert[And @@ (FreeQ[#, _Hypergeometric2F1 | _Beta] & /@ Values[pair]),
    label <> " retains an unexpanded B18 special function."];
  True
];

processMasterExpansion[
    expression_, label_String, cache_String
  ] := Module[{payload, answer},
  If[FileExistsQ[cache],
    Print["S09_STAGE: loading Appendix F cache for " <> label];
    payload = Check[Get[cache], $Failed];
    assert[AssociationQ[payload] &&
        payload["CacheVersion"] === cacheVersion,
      label <> " cache is invalid."];
    Return[payload["Expression"]]
  ];
  Print["S09_STAGE: Appendix F expansion for " <> label];
  answer = expandCase1Functions@expandAppendixFMasters[expression];
  assert[FreeQ[answer, _S08Case2Master | _Hypergeometric2F1 | _Beta],
    label <> " master expansion is incomplete."];
  payload = <|
    "CacheVersion" -> cacheVersion,
    "Label" -> label,
    "Expression" -> answer
  |>;
  Put[payload, cache];
  assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
    label <> " Appendix F cache was not written."];
  Print[
    "S09_STAGE: completed Appendix F expansion for " <> label <>
      ", leaf count " <> ToString[LeafCount[answer]]
  ];
  answer
];

Print["S09_STAGE: expanding all real angular masters"];
appendixFExpandedReal = AssociationMap[
  Function[channel,
    <|
      "Pg" -> processMasterExpansion[
        realKernels[channel, "Pg"], channel <> " Pg",
        cachePath[StringReplace[channel, {";" -> "_", "'" -> "p"}], "g"]
      ],
      "PPP" -> processMasterExpansion[
        realKernels[channel, "PPP"], channel <> " PPP",
        cachePath[StringReplace[channel, {";" -> "_", "'" -> "p"}], "pp"]
      ]
    |>
  ],
  Keys[realKernels]
];

Scan[
  Function[channel,
    validateMasterExpandedPair[appendixFExpandedReal[channel], channel]
  ],
  Keys[appendixFExpandedReal]
];

(* Channel weights for the physical Hqq real sum. *)
realChannelWeights = <|
  "Hqq;gg" -> 1/2,
  "Hqq;q_qbar_sameFlavor" -> 1,
  "Hqq;qPrime_qbarPrime" -> (Nf - 1)
|>;

weightedRealSum = AssociationMap[
  Function[projector,
    Total[
      (realChannelWeights[#] appendixFExpandedReal[#, projector]) & /@
        Keys[appendixFExpandedReal]
    ]
  ],
  {"Pg", "PPP"}
];

(*
  Distribution identity on 0 <= s <= B:

    s^(-1-eps) = B^(-eps) [ -delta(s)/eps
      + Sum_n (-eps)^n/n! [log^n(s/B)/s]_+ ].

  The weighted real kernel is written as s^(-1-eps) F(s,eps), with
  F = s^(1+eps) R. Multiplication of the plus distribution by F is kept
  explicit; its action is defined below. Three logarithmic orders suffice for
  the Appendix F truncation retained at this stage.
*)
endpointDistributionForm[expression_, upper_] := Module[
  {testFunction, endpointValue, plusPart, deltaPart},
  testFunction = s23^(1 + epsilon) expression;
  endpointValue = Check[
    TimeConstrained[
      Assuming[
        0 < xB < 1 && 0 < zH < 1 && Q2 > 0 && PHT2 > 0,
        Limit[testFunction, s23 -> 0, Direction -> "FromAbove"]
      ],
      60,
      $Failed
    ],
    $Failed
  ];
  If[endpointValue === $Failed || ! FreeQ[endpointValue, _Limit],
    endpointValue = S09EndpointValue[testFunction, s23 -> 0]
  ];
  deltaPart = -upper^(-epsilon)/epsilon *
    endpointValue DiracDelta[s23];
  plusPart = upper^(-epsilon) testFunction * Sum[
    (-epsilon)^n/Factorial[n] *
      S09PlusDistribution[n, s23, upper],
    {n, 0, 2}
  ];
  deltaPart + plusPart
];

Print["S09_STAGE: constructing s23 endpoint distributions"];
endpointExpandedRealSum = AssociationMap[
  endpointDistributionForm[weightedRealSum[#], s23UpperB] &,
  {"Pg", "PPP"}
];

validateEndpointPair[pair_Association] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    "Endpoint pair has the wrong projector keys."];
  assert[And @@ (! FreeQ[#, DiracDelta[s23]] & /@ Values[pair]),
    "An endpoint-expanded real projector lacks DiracDelta[s23]."];
  assert[And @@ (! FreeQ[#, _S09PlusDistribution] & /@ Values[pair]),
    "An endpoint-expanded real projector lacks plus distributions."];
  True
];

validateEndpointPair[endpointExpandedRealSum];

Print["S09_STAGE: forming symbolic real-virtual combinations"];
realVirtualCombined = AssociationMap[
  Function[projector,
    endpointExpandedRealSum[projector] + virtualKernels[projector]
  ],
  {"Pg", "PPP"}
];

assert[And @@ (! FreeQ[#, DiracDelta[s23]] & /@
      Values[realVirtualCombined]),
  "A real-virtual combination lacks its delta contribution."];
assert[And @@ (! FreeQ[#, _S09PlusDistribution] & /@
      Values[realVirtualCombined]),
  "A real-virtual combination lacks its plus distributions."];

plusDistributionAction = HoldComplete[
  Inactive[Integrate][
    S09PlusDistribution[n, s23, upper] testFunction[s23],
    {s23, 0, upper}
  ] == Inactive[Integrate][
    Log[s23/upper]^n/s23 *
      (testFunction[s23] - testFunction[0]),
    {s23, 0, upper}
  ]
];

virtualUnresolvedObjects = <|
  "ContainsPaVe" -> And @@ (! FreeQ[#, _FeynCalc`PaVe] & /@
      Values[virtualKernels]),
  "ContainsFeynAmpDenominator" ->
    And @@ (! FreeQ[#, _FeynCalc`FeynAmpDenominator] & /@
      Values[virtualKernels]),
  "ContainsSymbolicQCDRenormalizationConstants" ->
    And @@ (! FreeQ[
        #,
        dZGG1 | dZgs1 | _dZfL1 | _dZfR1 | _dZq1
      ] & /@ Values[virtualKernels])
|>;

s09Checks = <|
  "S08InputValidated" -> True,
  "All24RequiredMasterPairsImplemented" -> True,
  "AllCase2MastersExpanded" -> True,
  "B18HypergeometricExpandedWithB27" -> True,
  "IdenticalGluonWeightApplied" -> True,
  "DifferentFlavorMultiplicityApplied" -> True,
  "DeltaS23TermsConstructed" -> True,
  "PlusDistributionsConstructed" -> True,
  "RealChannelsCombined" -> True,
  "RealVirtualSymbolicSumFormed" -> True,
  "ExplicitPoleCancellationNotClaimed" -> True,
  "CollinearFactorizationNotApplied" -> True
|>;

s09Result = <|
  "Status" -> "CompleteWithSymbolicVirtual",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s08Path,
  "AppendixF" -> <|
    "RequiredPairs" -> requiredPairs,
    "ImplementedPairs" -> implementedPairs,
    "ExpansionConvention" ->
      "Appendix F Eqs. (F6)-(F29) for required pairs; j=0 from Eq. (B18); B27 for remaining 2F1",
    "ExpandedRealKernelsByChannel" -> appendixFExpandedReal
  |>,
  "RealChannelWeights" -> realChannelWeights,
  "WeightedRealSumBeforeEndpointExpansion" -> weightedRealSum,
  "EndpointExpansion" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "UpperLimit" -> s23UpperB,
    "PlusDistributionAction" -> plusDistributionAction,
    "EndpointExpandedRealSum" -> endpointExpandedRealSum
  |>,
  "RealVirtualCombinedSymbolic" -> realVirtualCombined,
  "LOReferenceKernels" -> loKernels,
  "VirtualStatus" -> <|
    "InputLabel" -> "NLOVirtualInterference_OAlphaS2_Symbolic",
    "UnresolvedObjects" -> virtualUnresolvedObjects,
    "CombinationStatus" ->
      "Added to the endpoint-expanded real sum, but inherited PaVe functions and symbolic QCD counterterms prevent an explicit Laurent pole-cancellation claim"
  |>,
  "Checks" -> s09Checks,
  "NotPerformedAtThisStage" -> {
    "scheme-specific evaluation of inherited symbolic virtual PaVe and dZ objects",
    "explicit real-virtual pole cancellation test",
    "Eq. (46) PDF/FF collinear-factorization subtraction",
    "epsilon -> 0 finite hard-part limit",
    "numerical PDF/FF convolution"
  }
|>;

Print["S09_STAGE: writing " <> resultPath];
Put[s09Result, resultPath];
assert[FileExistsQ[resultPath], "s09_result was not created."];
assert[FileByteCount[resultPath] > 0, "s09_result is empty."];

Print["S09_SUCCESS_WITH_SYMBOLIC_VIRTUAL"];
Print["S09_RESULT_PATH=" <> resultPath];
Print["S09_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S09_CHECKS=", InputForm[s09Checks]];

Quit[0];

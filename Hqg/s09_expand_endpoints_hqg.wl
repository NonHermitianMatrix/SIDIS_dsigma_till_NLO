(* ::Package:: *)

(*
  Hqg stage S09.

  Reuses the corrected Hqq/Hgg S09 Appendix-F and endpoint-distribution
  algorithms for the sole Hqg;qg real channel.  The Hqg LO and symbolic
  virtual contributions are retained separately and combined projector by
  projector with the endpoint-expanded real contribution.

  The S08 hard kernels are already stripped of the reference down-quark
  electric charge at amplitude level.  No flavor, charge, identical-particle,
  or cross-channel weight is applied here.  BigTMD's physical
  Sum_q e_q^2 f_q D_g luminosity remains external to the hard kernel.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, writeAtomic, appendixFExpansion, appendixFZeroJ,
  expandAppendixFMasters, expandCase1Functions, validateExpandedPair,
  loadOrBuildExpansion, endpointDistributionData, validateEndpointPair,
  S08Case2Master, S09EndpointValue, S09PlusDistribution
];

fatal[message_String] := (
  Print["S09_FATAL: " <> message];
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
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s08Path = FileNameJoin[{scriptDirectory, "s08_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s09_result"}];
stageVersion = "HqgS09-v3";
endpointDirectLimitLeafThreshold = 500000;
cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s09_cache_v1_hqg_real_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s09_cache_v1_hqg_real_pp"}]
|>;

Print["S09_STAGE: loading validated Hqg s08_result"];
assert[FileExistsQ[s08Path], "s08_result does not exist."];
s08 = Check[Get[s08Path], $Failed];
assert[AssociationQ[s08], "s08_result did not load as an Association."];
assert[
  s08["Status"] === "Complete" &&
    s08["Stage"] === "HqgS08-v4" &&
    s08["Channel"] === "Hqg only",
  "s08_result is not the corrected complete Hqg S08 artifact."
];
assert[AllTrue[Values[s08["Checks"]], TrueQ],
  "At least one s08 validation check is not True."];
assert[
  FileExistsQ[s08["Program"]] &&
    s08["ProgramSHA256"] === FileHash[s08["Program"], "SHA256"] &&
    FileExistsQ[s08["SourceResult"]] &&
  s08["SourceResultSHA256"] === FileHash[s08["SourceResult"], "SHA256"],
  "An S08 program or source binding is stale."
];
assert[
  IntegerQ[s08["ReferencePDFSHA256"]] &&
    s08["BigTMDConvention", "ChannelNumber"] === 3 &&
    s08["BigTMDConvention", "ChargeCase"] === "A only" &&
    s08["BigTMDProjectorMapping", "Pg"] === "NLO.Pg.fchn3A" &&
    s08["BigTMDProjectorMapping", "PPP"] === "NLO.Ppp.fchn3A",
  "S08 is not bound to the paper and BigTMD channel-3A projectors."
];
assert[
  s08["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s08["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s08[
      "ElectricChargeNormalization",
      "BigTMDLuminosityAppliedDownstream"
    ] === "Sum_q e_q^2 f_q D_g" &&
    s08["FragmentingParton"] === "gluon g(k1)",
  "S08 is not in the corrected charge-stripped Hqg convention."
];
s08SHA256 = FileHash[s08Path, "SHA256"];

realKernels = s08[
  "XiS23ConvolutionKernels", "ThreeBodyReal", "Hqg;qg"
];
assert[AssociationQ[realKernels],
  "The sole Hqg real kernel did not load as an Association."];
assert[Sort[Keys[realKernels]] === Sort[{"Pg", "PPP"}],
  "The Hqg real kernel does not contain exactly Pg and PPP."];
virtualKernels = s08[
  "XiS23ConvolutionKernels", "TwoBody",
  "NLOVirtualInterference_OAlphaS2_Symbolic"
];
loKernels = s08[
  "XiS23ConvolutionKernels", "TwoBody", "LO_OAlphaS"
];
assert[
  Sort[Keys[virtualKernels]] === Sort[{"Pg", "PPP"}] &&
    Sort[Keys[loKernels]] === Sort[{"Pg", "PPP"}],
  "The Hqg two-body LO or virtual kernels lack Pg/PPP coverage."
];
assert[
  AllTrue[
    Values[virtualKernels],
    ! FreeQ[#, dZq1] && ! FreeQ[#, dZGG1] && ! FreeQ[#, dZgs1] &
  ],
  "The Hqg symbolic virtual kernels lost their QCD counterterms."
];
changeOfVariables = s08["XiS23ChangeOfVariables"];
s23UpperB = changeOfVariables["S23UpperB"];
assert[! MissingQ[s23UpperB], "The S08 s23 upper limit is missing."];

(* Appendix F abbreviations, Eqs. (F1)-(F5). *)
appendixFExpansion[j_Integer, l_Integer, d_, c_, eps_] := Module[
  {ll, kk, ff, gg, p4, q4, area, x2, y2, result},
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
  area = 2 Pi/(1 - 2 eps);
  x2 = 1/(3 - 2 eps);
  y2 = 1/(2 - 2 eps);

  result = Switch[{j, l},
    (*
      Polynomial Case-2 moments obtained directly from Eq. (B19)'s
      D-dimensional angular measure.  They appear only after retaining the
      physical axial-projector numerator terms in Hqg.
    *)
    {-2, -1},
      Normal@Series[
        area (d^2 + (1 + 2 c d) x2),
        {eps, 0, 2}
      ],

    {-1, -2},
      Normal@Series[
        area (d (1 + c^2 x2 + (1 - c^2) (1 - x2) y2) +
          2 c x2),
        {eps, 0, 2}
      ],

    (* Eqs. (F6)-(F9). *)
    {1, -4},
      Pi/72 (-630 c^4 d^3 + 330 c^4 d + 1440 c^3 d^2 - 384 c^3 +
        540 c^2 d^3 - 1764 c^2 d + 9 p4 ll - 864 c d^2 + 1152 c -
        54 d^3 + 522 d) +
      Pi eps/72 (-1773 c^4 d^3 + 943 c^4 d + 3744 c^3 d^2 -
        1024 c^3 + 1674 c^2 d^3 +
        27/2 (c^2 - 1) (d^2 - 1) *
          (c^2 (19 d^2 - 3) - 32 c d - 3 d^2 + 19) ll -
        4398 c^2 d + 9 p4 kk - 2592 c d^2 + 2688 c -
        189 d^3 + 1599 d),

    {2, -4},
      Pi/(3 (d^2 - 1)) (36 c (3 - 5 c^2) d^3 +
        12 c (13 c^2 - 11) d + 3 (35 c^4 - 30 c^2 + 3) d^4 +
        (-115 c^4 + 222 c^2 - 51) d^2 + 16 (c^4 - 6 c^2 + 3)) +
      Pi/2 q4 ll + Pi eps/18 (72 (21 - 29 c^2) c d +
        32 (39 - 8 c^2) c^2 + 54 (27 c^4 - 26 c^2 + 3) d^2 -
        9 q4 kk - 528) + Pi eps/(2 (d^2 - 1)) (
        c^4 (-11 d^4 + 30 d^2 - 15) d -
        4 c^3 (d^4 + 6 d^2 - 3) +
        6 c^2 (3 d^4 - 2 d^2 + 3) d -
        4 c (3 d^4 - 2 d^2 + 3) - 3 d^5 + 6 d^3 + d) ll,

    {1, -3},
      Pi (5 c^3 d^2 - 4 c^3/3 -
        1/2 (c d - 1) (5 c^2 d^2 - 3 c^2 - 4 c d - 3 d^2 + 5) ll -
        9 c^2 d - 3 c d^2 + 8 c + 3 d) +
      Pi eps (-1/2 (c d - 1) *
        (c^2 (5 d^2 - 3) - 4 c d - 3 d^2 + 5) kk +
        1/9 (117 c^3 d^2 - 32 c^3 -
          27/2 (c d - 1) (c^2 d^2 - c^2 - d^2 + 1) ll -
          189 c^2 d - 81 c d^2 + 156 c + 81 d)),

    {2, -3},
      3 Pi/2 (c (c^2 (5 d^2 - 1) - 6 c d - 3 d^2 + 3) + 2 d) ll +
      Pi/(d^2 - 1) (c^3 d (13 - 15 d^2) + 6 c^2 (3 d^2 - 2) +
        3 c d (3 d^2 - 5) - 6 d^2 + 8) +
      Pi eps/2 (-58 c^3 d +
        3 (c (c^2 (5 d^2 - 1) - 6 c d - 3 d^2 + 3) + 2 d) kk +
        48 c^2 + 42 c d - 24),

    (* Eqs. (F12)-(F13). *)
    {1, -2},
      Pi (d - 3 c^2 d + 4 c - ff ll/2) + Pi eps (
        -gg ll/4 Log[(d - 1) (d + 1)^3/16] -
        ll/2 (-c^2 d^2 + c^2 + d^2 - 1) +
        Pi^2/6 (c^2 (3 d^2 - 1) - 4 c d - d^2 + 3) +
        c (8 - 7 c d) + 3 d - gg PolyLog[2, (d - 1)/(d + 1)]),

    {2, -2},
      Pi/(d^2 - 1) (c^2 (6 d^2 - 4) -
        (d^2 - 1) (c (3 c d - 2) - d) ll - 4 c d - 2 d^2 + 4) +
      Pi eps (4 (2 c^2 + d (c d - 1)^2 ll/(2 (d^2 - 1)) - 1) -
        (c (3 c d - 2) - d) kk),

    (* Eqs. (F15)-(F25). *)
    {-1, -1},
      2 Pi (c/3 + d) + Pi eps (16 c/9 + 4 d),

    {-2, 0},
      2 Pi/3 (3 d^2 + 1) + 4 Pi eps/9 (9 d^2 + 4),

    {-1, 0},
      2 Pi d + 4 Pi d eps,

    {1, 0},
      Pi ll + Pi eps kk,

    {2, 0},
      2 Pi/(d^2 - 1) + 2 Pi eps d ll/(d^2 - 1),

    {1, -1},
      Pi (-(c d - 1) ll + 2 c) + Pi eps (
        4 c - Pi^2 (c d - 1)/3 +
        (c d - 1) ll/2 Log[(d - 1) (d + 1)^3/16] +
        2 (c d - 1) PolyLog[2, (d - 1)/(d + 1)]),

    {2, -1},
      -Pi (-c (d^2 - 1) ll + 2 c d - 2)/(d^2 - 1) + Pi eps (
        -ll (c (d^2 - 1) Log[(d - 1) (d + 1)^3/16] +
          4 d (c d - 1))/(2 (d^2 - 1)) + Pi^2 c/3 -
        2 c PolyLog[2, (d - 1)/(d + 1)]),

    {-2, 1},
      -Pi (c - d)^2/eps + Pi (-3 c^2 + 4 c d + 1) +
        Pi eps (-7 c^2 + 8 c d + 3),

    {-1, 1},
      Pi (c - d)/eps + 2 Pi c + 4 Pi eps c,

    {1, 1},
      Pi/(eps (c - d)) + Pi Log[(d^2 - 1)/(d - c)^2]/(c - d) +
      2 Pi eps/(c - d) (
        PolyLog[2, (c - 1)/(d - 1)] -
        PolyLog[2, (d - c)/(d + 1)] +
        Log[c + 1] Log[(d + 1)/(d - c)] +
        Log[d - c] Log[(d - c)/(d - 1)] -
        ll/4 Log[(d - 1) (d + 1)^3] + Pi^2/6),

    {2, 1},
      -Pi/(eps (d - c)^2) + Pi/((d^2 - 1) (c - d)^2) (
        (d^2 - 1) Log[(d - c)^2/(d^2 - 1)] - 2 c d + 2) +
      2 Pi eps/(c - d)^2 (
        PolyLog[2, (d - c)/(d + 1)] -
        PolyLog[2, (c - 1)/(d - 1)]) -
      Pi eps/(6 (d^2 - 1) (c - d)^2) (
        12 Log[d + 1] ((d^2 - 1) Log[c + 1] + c + d^2 - d - 1) -
        12 Log[d - 1] ((d^2 - 1) Log[d - c] + c - d^2 - d + 1) +
        (d^2 - 1) (2 (6 Log[d - c] (Log[(d - c)/(c + 1)] - 2) +
          Pi^2) - 3 ll Log[(d - 1) (d + 1)^3])),

    (* Eqs. (F27)-(F29). *)
    {-1, 2},
      -Pi c/eps + Pi (c - d) + Pi eps (d - c),

    {1, 2},
      Pi (1 - c d)/(eps (c - d)^3) + Pi/(c - d)^3 (
        -c^2 - 2 c d + d^2 + 2 +
        (c d - 1) Log[(d - c)^2/(d^2 - 1)]),

    {2, 2},
      Pi (c^2 + 2 c d - 3)/(eps (c - d)^4) +
      Pi/((d^2 - 1) (c - d)^4) (
        c^2 (7 d^2 - 5) +
        (d^2 - 1) (c^2 + 2 c d - 3) *
          Log[(d^2 - 1)/(d - c)^2] +
        2 (d^2 - 3) c d - d^2 (d^2 + 5) + 8),

    _, $Failed
  ];
  result
];

(* j=0 is independent of D and C and follows from Eq. (B18). *)
appendixFZeroJ[l_Integer, eps_] := Module[{exact},
  exact = 2 Pi Gamma[1 - 2 eps]/Gamma[1 - eps]^2 *
    2^(-l) Beta[1 - eps, 1 - eps - l];
  Normal@Series[FunctionExpand[exact], {eps, 0, 2}]
];

hqqRequiredPairs = {
  {-2, 0}, {-2, 1},
  {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {0, -2}, {0, -1}, {0, 1}, {0, 2},
  {1, -4}, {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -4}, {2, -3}, {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};
expectedHqgPairs = {
  {-2, -1}, {-2, 0}, {-2, 1},
  {-1, -2}, {-1, -1}, {-1, 0}, {-1, 1}, {-1, 2},
  {0, -3}, {0, -2}, {0, -1}, {0, 1}, {0, 2},
  {1, -3}, {1, -2}, {1, -1}, {1, 0}, {1, 1}, {1, 2},
  {2, -3}, {2, -2}, {2, -1}, {2, 0}, {2, 1}, {2, 2}
};
implementedPairs = Join[
  hqqRequiredPairs,
  {{-2, -1}, {-1, -2}, {0, -3}}
];
actualPairs = Sort@DeleteDuplicates@Cases[
  Values[realKernels],
  S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon] :> {j, l},
  Infinity
];
assert[actualPairs === Sort[expectedHqgPairs],
  "The Hqg S08 master-pair inventory is not the validated 25-pair set."];
assert[SubsetQ[implementedPairs, actualPairs],
  "At least one Hqg S08 master pair lacks an Appendix-F expansion."];
Print["S09_MASTER_PAIRS=", InputForm[actualPairs]];

expandAppendixFMasters[expression_] := expression /. HoldPattern[
    S08Case2Master[j_Integer, l_Integer, d_, c_, epsilon]
  ] :> If[j === 0,
    appendixFZeroJ[l, epsilon],
    appendixFExpansion[j, l, d, c, epsilon]
  ];

(* Eq. (B27), plus local gamma/beta expansions as in Hqq S09. *)
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

validateExpandedPair[pair_Association] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    "The expanded Hqg pair has the wrong projector keys."];
  assert[AllTrue[Values[pair], FreeQ[#, _S08Case2Master] &],
    "An expanded Hqg projector retains S08Case2Master."];
  assert[AllTrue[Values[pair], FreeQ[#, _Hypergeometric2F1 | _Beta] &],
    "An expanded Hqg projector retains a B18 special function."];
  True
];

loadOrBuildExpansion[projector_String] := Module[
  {cache, payload, answer},
  cache = cachePaths[projector];
  If[FileExistsQ[cache],
    payload = Check[Get[cache], $Failed];
    If[
      AssociationQ[payload] &&
      payload["StageVersion"] === stageVersion &&
      payload["SourceS08SHA256"] === s08SHA256 &&
      payload["ProgramSHA256"] === programSHA256 &&
      payload["Channel"] === "Hqg only" &&
      payload["TensorRole"] === "RealQG" &&
      payload["Projector"] === projector &&
      payload["ElectricChargeNormalization"] ===
        s08["ElectricChargeNormalization"] &&
      FreeQ[payload["Expression"], _S08Case2Master | _Hypergeometric2F1 | _Beta],
      Print["S09_STAGE: loading validated Appendix-F cache for " <> projector];
      Return[payload["Expression"]],
      Print["S09_STAGE: removing stale Appendix-F cache for " <> projector];
      DeleteFile[cache]
    ]
  ];
  Print["S09_STAGE: Appendix-F expansion for Hqg;qg " <> projector];
  answer = expandCase1Functions@expandAppendixFMasters[realKernels[projector]];
  assert[FreeQ[answer, _S08Case2Master | _Hypergeometric2F1 | _Beta],
    "The " <> projector <> " Appendix-F expansion is incomplete."];
  payload = <|
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> "RealQG",
    "SourceS08" -> s08Path,
    "SourceS08SHA256" -> s08SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "BigTMDProjectorMapping" -> s08["BigTMDProjectorMapping"],
    "ElectricChargeNormalization" -> s08["ElectricChargeNormalization"],
    "AppliedHardKernelWeight" -> 1,
    "Projector" -> projector,
    "Expression" -> answer
  |>;
  writeAtomic[payload, cache];
  Print["S09_CHECKPOINT: completed Appendix-F expansion for " <>
    projector <> ", leafCount=" <> ToString[LeafCount[answer]]];
  answer
];

Print["S09_STAGE: expanding Hqg real angular masters serially"];
appendixFExpandedReal = <||>;
appendixFExpandedReal["Pg"] = loadOrBuildExpansion["Pg"];
appendixFExpandedReal["PPP"] = loadOrBuildExpansion["PPP"];
validateExpandedPair[appendixFExpandedReal];

(*
  Hqg has one qg real channel, counted once.  S01 already stripped the
  reference electric charge, so the hard-kernel weight here is exactly one.
  BigTMD applies Sum_q e_q^2 f_q D_g outside fchn3A.
*)
realHardKernels = appendixFExpandedReal;

(* Same endpoint identity and truncation as Hqq S09. *)
endpointDistributionData[
    expression_, upper_, projector_String
  ] := Module[{testFunction, endpointValue, usedPlaceholder, distribution},
  Print["S09_STAGE: endpoint limit for " <> projector];
  testFunction = s23^(1 + epsilon) expression;
  endpointValue = If[
    LeafCount[testFunction] > endpointDirectLimitLeafThreshold,
    $Failed,
    Check[
      TimeConstrained[
        Assuming[
          0 < xB < 1 && 0 < zH < 1 && Q2 > 0 && PHT2 > 0,
          Limit[testFunction, s23 -> 0, Direction -> "FromAbove"]
        ],
        60,
        $Failed
      ],
      $Failed
    ]
  ];
  usedPlaceholder = endpointValue === $Failed || ! FreeQ[endpointValue, _Limit];
  If[usedPlaceholder,
    endpointValue = S09EndpointValue[testFunction, s23 -> 0]
  ];
  distribution = -upper^(-epsilon)/epsilon *
      endpointValue DiracDelta[s23] +
    upper^(-epsilon) testFunction * Sum[
      (-epsilon)^n/Factorial[n] *
        S09PlusDistribution[n, s23, upper],
      {n, 0, 2}
    ];
  Print["S09_CHECKPOINT: endpoint distribution completed for " <>
    projector <> ", symbolicPlaceholder=" <> ToString[usedPlaceholder]];
  <|
    "EndpointValue" -> endpointValue,
    "UsedSymbolicPlaceholder" -> usedPlaceholder,
    "Distribution" -> distribution
  |>
];

Print["S09_STAGE: constructing Hqg s23 endpoint distributions"];
endpointData = AssociationMap[
  endpointDistributionData[realHardKernels[#], s23UpperB, #] &,
  {"Pg", "PPP"}
];
endpointExpandedReal = Map[# ["Distribution"] &, endpointData];

validateEndpointPair[pair_Association] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    "The endpoint pair has the wrong projector keys."];
  assert[AllTrue[Values[pair], ! FreeQ[#, DiracDelta[s23]] &],
    "An endpoint-expanded Hqg projector lacks DiracDelta[s23]."];
  assert[AllTrue[Values[pair], ! FreeQ[#, _S09PlusDistribution] &],
    "An endpoint-expanded Hqg projector lacks plus distributions."];
  True
];
validateEndpointPair[endpointExpandedReal];

Print["S09_STAGE: forming Hqg symbolic real-virtual combinations"];
realVirtualCombined = AssociationMap[
  endpointExpandedReal[#] + virtualKernels[#] &,
  {"Pg", "PPP"}
];
assert[
  AllTrue[Values[realVirtualCombined], ! FreeQ[#, DiracDelta[s23]] &] &&
    AllTrue[Values[realVirtualCombined], ! FreeQ[#, _S09PlusDistribution] &],
  "A Hqg real-virtual combination lost its endpoint distributions."
];

virtualUnresolvedObjects = <|
  "ContainsPaVe" -> AllTrue[
    Values[virtualKernels], ! FreeQ[#, _FeynCalc`PaVe] &
  ],
  "ContainsFeynAmpDenominator" -> AllTrue[
    Values[virtualKernels], ! FreeQ[#, _FeynCalc`FeynAmpDenominator] &
  ],
  "ContainsSymbolicQCDRenormalizationConstants" -> AllTrue[
    Values[virtualKernels],
    ! FreeQ[#, dZGG1 | dZgs1 | _dZfL1 | _dZfR1 | _dZq1] &
  ]
|>;

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

placeholderCount = Count[
  Values[endpointData][[All, "UsedSymbolicPlaceholder"]],
  True
];

s09Checks = <|
  "CurrentS08SourceAndProgramBindingsVerified" -> True,
  "PaperReferenceHashPreserved" -> True,
  "BigTMDChannel3CaseAProjectorsPreserved" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "FragmentingGluonIsK1" -> True,
  "SoleHqgQGRealChannelProcessedOnce" -> True,
  "ExactValidated25MasterPairInventoryEnforced" -> True,
  "AdditionalPhysicalAxialPolynomialMomentsDerivedFromB19" -> True,
  "AllActualMasterPairsImplemented" -> True,
  "AllCase2MastersExpanded" -> True,
  "B18HypergeometricExpandedWithB27" -> True,
  "NoHqqOrHggChannelWeightApplied" -> True,
  "NoIdenticalParticleHalfFactorApplied" -> True,
  "DeltaS23TermsConstructed" -> True,
  "PlusDistributionsConstructed" -> True,
  "OversizedEndpointLimitsUseFormalS09EndpointValue" -> True,
  "LOReferenceKernelsRetained" -> True,
  "SymbolicVirtualQCDCountertermsRetained" -> True,
  "RealVirtualSymbolicSumFormed" -> True,
  "CachesBoundToS08ProgramAndChargeConvention" -> True,
  "PhysicalBigTMDLuminosityDeferred" -> True,
  "ExplicitPoleCancellationNotClaimed" -> True,
  "CollinearFactorizationNotApplied" -> True
|>;

s09Result = <|
  "Status" -> "CompleteWithSymbolicVirtual",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg;qg real endpoint-expanded plus Hqg symbolic virtual Pg/PPP projections",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s08Path,
  "SourceResultSHA256" -> s08SHA256,
  "ReferencePDFSHA256" -> s08["ReferencePDFSHA256"],
  "BigTMDConvention" -> s08["BigTMDConvention"],
  "BigTMDProjectorMapping" -> s08["BigTMDProjectorMapping"],
  "ElectricChargeNormalization" -> s08["ElectricChargeNormalization"],
  "FragmentingParton" -> s08["FragmentingParton"],
  "AppendixF" -> <|
    "ActualS08Pairs" -> actualPairs,
    "ExpectedHqgPairs" -> Sort[expectedHqgPairs],
    "HqqPairsReused" -> Intersection[actualPairs, hqqRequiredPairs],
    "HqgAdditionalPairs" -> {},
    "ExpansionConvention" ->
      "Corrected Hqq Appendix-F Eqs. (F6)-(F29) for required pairs; j=0 from Eq. (B18); Eq. (B27) for remaining 2F1",
    "ExpandedKernelCachesByProjector" -> cachePaths,
    "CachesBoundToSourceS08ProgramAndChargeConvention" -> True
  |>,
  "HardKernelWeight" -> <|
    "AppliedMultiplicativeWeight" -> 1,
    "RealChannelCounting" -> "sole Hqg;qg channel counted once",
    "IdenticalParticleFactor" -> 1,
    "BigTMDLuminosityAppliedDownstream" -> "Sum_q e_q^2 f_q D_g",
    "NoHqqOrHggWeightImported" -> True
  |>,
  "EndpointExpansion" -> <|
    "Interval" -> {s23, 0, s23UpperB},
    "UpperLimit" -> s23UpperB,
    "PlusDistributionAction" -> plusDistributionAction,
    "EndpointValuesByProjector" -> Map[# ["EndpointValue"] &, endpointData],
    "SymbolicPlaceholderByProjector" ->
      Map[# ["UsedSymbolicPlaceholder"] &, endpointData],
    "SymbolicPlaceholderCount" -> placeholderCount,
    "EndpointExpandedRealByProjector" -> endpointExpandedReal
  |>,
  "RealVirtualCombinedSymbolic" -> realVirtualCombined,
  "LOReferenceKernels" -> loKernels,
  "VirtualStatus" -> <|
    "InputLabel" -> "NLOVirtualInterference_OAlphaS2_Symbolic",
    "UnresolvedObjects" -> virtualUnresolvedObjects,
    "CombinationStatus" ->
      "Added projector by projector to endpoint-expanded real kernels; inherited PaVe/propagator and symbolic QCD counterterms prevent an explicit Laurent pole-cancellation claim"
  |>,
  "BigTMDComparisonStatus" ->
    "Finite fchn3A regular/delta/plus comparison deferred until virtual evaluation, factorization, and epsilon-to-zero finite assembly",
  "Checks" -> s09Checks,
  "MemoryStrategy" ->
    "Pg and PPP Appendix-F expansions are built serially and stored in atomic caches bound to S08, this program, and the charge convention",
  "NotPerformedAtThisStage" -> {
    "resolution/action of any bounded symbolic endpoint value",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "scheme-specific evaluation of inherited symbolic virtual PaVe and dZ objects",
    "Eq. (46) initial-state PDF and final-state FF subtraction",
    "explicit Laurent pole-cancellation test",
    "epsilon -> 0 finite hard-part limit",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels",
    "numerical PDF/FF convolution"
  }
|>;

Print["S09_STAGE: writing " <> resultPath];
writeAtomic[s09Result, resultPath];
Print["S09_SUCCESS_WITH_SYMBOLIC_VIRTUAL"];
Print["S09_RESULT_PATH=" <> resultPath];
Print["S09_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S09_ENDPOINT_PLACEHOLDER_COUNT=", placeholderCount];
Print["S09_CHECKS=", InputForm[s09Checks]];

Quit[0];

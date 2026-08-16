(* ::Package:: *)

(*
  BigTMD consistency check, stage s01.

  Read the validated finite Hqq F1Hat/F2Hat actions saved by S13 directly,
  extract their endpoint/running/subtraction coefficients structurally, and
  evaluate one generic interior benchmark one field at a time.

  Each imported F-hat action is released after its three coefficients are
  evaluated.  Existing Hqq files are read-only; the only output is compact
  JSON in this check directory.
*)

$HistoryLength = 0;
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, zeroArgumentQ, resolveCanceledZeroLogs, numericalValue,
  benchmarkRules, actionToPair, atomicRawJSONExport,
  S13ConvolutionTest
];

fatal[message_String] := (
  Print["BIGTMD_CHECK_S01_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

Print["BIGTMD_CHECK_S01_STAGE: initializing Package-X numeric functions"];
packageXInitialization = Quiet@Check[
  TimeConstrained[
    FeynCalc`PaXEvaluate[
      FeynCalc`B0[1, 0, 0],
      FeynCalc`PaXImplicitPrefactor -> 1
    ],
    120,
    $Failed
  ],
  $Failed
];
assert[packageXInitialization =!= $Failed,
  "Package-X numeric-function initialization failed."];
packageXProbe = Quiet@Check[
  N[FeynCalc`PaXDiLog[-2, -3], 18],
  $Failed
];
assert[NumericQ[packageXProbe],
  "Package-X PaXDiLog did not acquire its numeric evaluator."];
Clear[packageXInitialization, packageXProbe];
ClearSystemCache[];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
hqqDirectory = DirectoryName[scriptDirectory];
s13Path = FileNameJoin[{hqqDirectory, "s13_result"}];
outputPath = FileNameJoin[{scriptDirectory, "local_fhat_benchmark.json"}];

projectors = {"Pg", "PPP"};
fields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
structureFunctions = {"F1Hat", "F2Hat"};
endpointRegulator = 1/10^7;

(*
  A generic point away from simple symmetry loci.  PHT2=zH^2 qT2 exactly.
  One interior sample checks both running and subtraction integrands.
*)
benchmark = <|
  "ID" -> "generic_interior_1",
  "xB" -> 23/100,
  "xi" -> 61/100,
  "zH" -> 37/100,
  "Q2" -> 17,
  "qT2" -> 31/10,
  "PHT2" -> 42439/100000,
  "S23Fraction" -> 2/5,
  "Nf" -> 4
|>;

xHatValue = benchmark["xB"]/benchmark["xi"];
upperBValue = benchmark["Q2"] (1/xHatValue - 1) *
    (1 - benchmark["zH"]) - benchmark["PHT2"]/benchmark["zH"];
s23SampleValue = benchmark["S23Fraction"] upperBValue;
assert[TrueQ[0 < xHatValue < 1], "the benchmark xHat is not physical."];
assert[TrueQ[upperBValue > 0], "the benchmark s23 upper bound is not positive."];
assert[TrueQ[0 < s23SampleValue < upperBValue],
  "the benchmark s23 sample is not in the open physical interval."];

couplingAndColorRules = {
  FeynCalc`CA -> 3,
  FeynCalc`CF -> 4/3,
  FeynCalc`TF -> 1/2,
  Global`CA -> 3,
  Global`CF -> 4/3,
  Global`TF -> 1/2,
  HoldPattern[FeynCalc`SMP["g_s"]] -> 1,
  HoldPattern[Global`SMP["g_s"]] -> 1,
  HoldPattern[FeynArts`FCGV["EL"]] -> 1,
  HoldPattern[FeynCalc`FCGV["EL"]] -> 1,
  HoldPattern[Global`FCGV["EL"]] -> 1,
  FeynArts`FAGS -> 1,
  Global`FAGS -> 1,
  Nf -> benchmark["Nf"]
};

benchmarkRules[s23Value_] := {
  xB -> benchmark["xB"],
  xi -> benchmark["xi"],
  zH -> benchmark["zH"],
  Q2 -> benchmark["Q2"],
  PHT2 -> benchmark["PHT2"],
  ScaleMu -> Sqrt[benchmark["Q2"]],
  s23 -> s23Value
};

zeroArgumentQ[argument_] := Module[{reduced},
  reduced = Quiet@Check[Cancel[Together[argument]], argument];
  TrueQ[reduced === 0] || TrueQ[PossibleZeroQ[reduced]]
];

resolveCanceledZeroLogs[expression_, rules_List, label_String] := Module[
  {
    logPositions, zeroRecords, harvested, argument, evaluatedArgument,
    uniqueArguments, placeholders, positionRules, regularizedExpression,
    reducedExpression, dependentIndices, unresolvedZeroLogs
  },
  logPositions = Position[
    expression,
    HoldPattern[Inactive[Log][_]],
    {0, Infinity},
    Heads -> False
  ];

  harvested = Reap[
    Do[
      argument = Extract[expression, Append[position, 1]];
      evaluatedArgument = Quiet@Check[
        Cancel[Together[argument /. rules]],
        argument /. rules
      ];
      If[zeroArgumentQ[evaluatedArgument],
        Sow[{position, HoldComplete[argument]}]
      ];
      ,
      {position, logPositions}
    ]
  ][[2]];
  zeroRecords = If[harvested === {}, {}, First[harvested]];
  If[zeroRecords === {}, Return[expression /. rules]];

  uniqueArguments = DeleteDuplicates[zeroRecords[[All, 2]], SameQ];
  placeholders = Table[Unique["zeroLogValue$"], {Length[uniqueArguments]}];
  positionRules = Map[
    Function[record,
      record[[1]] -> placeholders[[
        First@FirstPosition[uniqueArguments, record[[2]]]
      ]]
    ],
    zeroRecords
  ];

  (*
    Keep distinct zero-log arguments independent.  A cancellation is valid
    only if exact algebra removes every corresponding placeholder; assigning
    a regulator or silently replacing Log[0] is not accepted.
  *)
  regularizedExpression = ReplacePart[expression, positionRules] /. rules;
  reducedExpression = Quiet@Check[
    TimeConstrained[
      Cancel[Together[regularizedExpression]],
      180,
      $Failed
    ],
    $Failed
  ];
  If[reducedExpression === $Failed,
    fatal[label <> " zero-log cancellation proof exceeded its bound."]
  ];

  dependentIndices = Flatten@Position[
    placeholders,
    placeholder_ /; ! FreeQ[reducedExpression, placeholder]
  ];
  If[dependentIndices =!= {},
    fatal[
      label <> " contains genuine uncanceled zero logarithms with source " <>
        "arguments=" <> ToString[
          InputForm[uniqueArguments[[dependentIndices]]]
        ]
    ]
  ];

  reducedExpression = reducedExpression /. Thread[placeholders -> 0];
  unresolvedZeroLogs = Cases[
    reducedExpression,
    HoldPattern[Inactive[Log][candidate_]] /; zeroArgumentQ[candidate],
    Infinity
  ];
  assert[unresolvedZeroLogs === {},
    label <> " retained a zero logarithm after exact cancellation."];
  Print[
    "BIGTMD_CHECK_S01_ZERO_LOG_CANCELED: " <> label <>
      " distinctArguments=" <> ToString[Length[uniqueArguments]]
  ];
  reducedExpression
];

numericalValue[expression_, rules_List, label_String] := Module[
  {
    allRules, inactiveExpression, replacedExpression, activatedExpression,
    value, remainingSymbols, singularObjects, nonNumericAtoms,
    minimalNonNumeric, diagnosticSummary
  },
  allRules = Join[rules, couplingAndColorRules];
  assert[ListQ[allRules] &&
      AllTrue[allRules, MatchQ[#, _Rule | _RuleDelayed] &],
    label <> " received an invalid replacement list."];

  (*
    Delay logarithm evaluation until exact substitutions and cancellation.
    Distinct Log[0] sources remain algebraically independent, so only a
    proven cancellation can remove them.
  *)
  inactiveExpression = Inactivate[expression, Log];
  replacedExpression = resolveCanceledZeroLogs[
    inactiveExpression,
    allRules,
    label
  ];

  activatedExpression = Activate[replacedExpression, Log] /.
    HoldPattern[Global`PaXDiLog[first_, second_]] :>
      FeynCalc`PaXDiLog[first, second];
  value = Quiet[N[activatedExpression, 18]];
  If[! NumericQ[value],
    remainingSymbols = DeleteDuplicates@Cases[
      activatedExpression,
      symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`",
      Infinity
    ];
    singularObjects = DeleteDuplicates@Cases[
      value,
      Indeterminate | ComplexInfinity | DirectedInfinity[_],
      Infinity
    ];
    nonNumericAtoms = DeleteDuplicates@Cases[
      value,
      atom_?AtomQ /; ! NumericQ[atom] :> HoldComplete[atom],
      Infinity
    ];
    minimalNonNumeric = DeleteDuplicates[
      Cases[
        value,
        candidate_ /;
            ! AtomQ[Unevaluated[candidate]] &&
            ! NumericQ[candidate] &&
            And @@ (NumericQ /@ (List @@ candidate)) :>
          HoldComplete[candidate],
        Infinity
      ],
      SameQ
    ];
    diagnosticSummary = <|
      "Head" -> Head[value],
      "LeafCount" -> LeafCount[value],
      "ContainsPiecewise" -> ! FreeQ[value, _Piecewise],
      "ContainsConditionalExpression" ->
        ! FreeQ[value, _ConditionalExpression],
      "ContainsInactive" -> ! FreeQ[value, _Inactive],
      "NonNumericAtoms" -> Take[nonNumericAtoms, UpTo[8]],
      "MinimalNonNumeric" -> Take[minimalNonNumeric, UpTo[4]]
    |>;
    Print[
      "BIGTMD_CHECK_S01_NONNUMERIC_DIAGNOSTIC: label=", label,
      " summary=", InputForm[diagnosticSummary]
    ];
    fatal[
      label <> " did not become numerical; remaining symbols=" <>
        ToString[InputForm[remainingSymbols]] <>
        ", singular objects=" <> ToString[InputForm[singularObjects]]
    ]
  ];
  value = Chop[value, 10^-12];
  assert[NumberQ[value] && Abs[N[Im[value], 16]] < 10^-10,
    label <> " is not a finite real number: " <> ToString[InputForm[value]]];
  N[Re[value], 17]
];

actionToPair[action_, structureFunction_String, expectedInterval_List] :=
    Module[
  {
    actionTerms, integralPositions, integralTerm, integralRecords,
    integrand, interval, endpointPart, endpointTest, runningTest,
    endpointCoefficient, runningCoefficient, subtractionCoefficient
  },
  actionTerms = If[Head[action] === Plus, List @@ action, {action}];
  integralPositions = Flatten@Position[
    actionTerms,
    term_ /; ! FreeQ[term, Inactive[Integrate][__]],
    {1},
    Heads -> False
  ];
  assert[Length[integralPositions] === 1,
    structureFunction <> " does not contain exactly one integral term."];
  integralTerm = actionTerms[[First[integralPositions]]];
  endpointPart = Total[Delete[actionTerms, First[integralPositions]]];
  integralRecords = Cases[
    integralTerm,
    HoldPattern[Inactive[Integrate][body_, range_]] :> {body, range},
    {0, Infinity}
  ];
  assert[Length[integralRecords] === 1,
    structureFunction <> " has an invalid inactive integral."];
  integrand = integralRecords[[1, 1]];
  interval = integralRecords[[1, 2]];
  assert[SameQ[interval, expectedInterval],
    structureFunction <> " uses the wrong integration interval."];

  endpointTest = S13ConvolutionTest[structureFunction, 0];
  runningTest = S13ConvolutionTest[structureFunction, First[interval]];
  endpointCoefficient = endpointPart /. endpointTest -> 1;
  runningCoefficient =
    integrand /. runningTest -> 1 /. endpointTest -> 0;
  subtractionCoefficient =
    integrand /. runningTest -> 0 /. endpointTest -> 1;
  assert[
    TrueQ[(endpointPart /. endpointTest -> 0) === 0] &&
      TrueQ[(integrand /. runningTest -> 0 /. endpointTest -> 0) === 0] &&
      FreeQ[
        {endpointCoefficient, runningCoefficient, subtractionCoefficient},
        _S13ConvolutionTest | Inactive[Integrate][__]
      ],
    structureFunction <> " action is not linear in its matching test " <>
      "function."];
  <|
    "Endpoint" -> endpointCoefficient,
    "IntegrandPhiS" -> runningCoefficient,
    "IntegrandPhi0" -> subtractionCoefficient
  |>
];

Print["BIGTMD_CHECK_S01_STAGE: importing validated S13 F hats"];
assert[FileExistsQ[s13Path] && FileByteCount[s13Path] > 0,
  "s13_result is absent or empty."];
s13ByteCount = FileByteCount[s13Path];
s13 = Quiet@Check[Get[s13Path], $Failed];
assert[AssociationQ[s13] &&
    s13["Status"] === "CompleteFinitePartonicStructureFunctionsHqq",
  "s13_result is unreadable or incomplete."];
assert[AssociationQ[s13["Checks"]] && And @@ Values[s13["Checks"]],
  "s13_result contains a failed validation check."];

fHatFunctions = s13["FiniteHattedStructureFunctions"];
xHatExpression = s13["XHat"];
intervalExpression = s13["IntegrationInterval"];
assert[AssociationQ[fHatFunctions] &&
    Sort[Keys[fHatFunctions]] === Sort[structureFunctions],
  "s13_result does not contain both finite F hats."];
assert[MatchQ[intervalExpression, {_, 0, _}],
  "the S13 physical integration interval is invalid."];
assert[TrueQ[Together[
      (xHatExpression /. benchmarkRules[s23SampleValue]) - xHatValue
    ] === 0],
  "the benchmark xHat does not match the S13 physical map."];
assert[TrueQ[Together[
      (Last[intervalExpression] /. benchmarkRules[s23SampleValue]) -
        upperBValue
    ] === 0],
  "the benchmark upper bound does not match the S13 physical map."];

(* Release S13 provenance before importing either large F-hat action. *)
Clear[s13];
ClearSystemCache[];

fieldS23Values = <|
  "Endpoint" -> endpointRegulator,
  "IntegrandPhiS" -> s23SampleValue,
  "IntegrandPhi0" -> s23SampleValue
|>;
localValues = <||>;

Do[
  Print["BIGTMD_CHECK_S01_FHAT: importing " <> structureFunction];
  action = fHatFunctions[structureFunction];
  pair = actionToPair[action, structureFunction, intervalExpression];
  fHatFunctions = KeyDrop[fHatFunctions, structureFunction];
  Clear[action];
  ClearSystemCache[];

  Do[
    Print[
      "BIGTMD_CHECK_S01_FIELD: " <> structureFunction <> " " <> field
    ];
    rules = benchmarkRules[fieldS23Values[field]];
    value = numericalValue[
      pair[field],
      rules,
      "local " <> structureFunction <> " " <> field
    ];
    fieldValues = Lookup[localValues, field, <||>];
    AssociateTo[fieldValues, structureFunction -> value];
    AssociateTo[localValues, field -> fieldValues];
    pair = KeyDrop[pair, field];
    Clear[value, fieldValues, rules];
    ClearSystemCache[];,
    {field, fields}
  ];
  Clear[pair];
  ,
  {structureFunction, structureFunctions}
];
Clear[fHatFunctions, intervalExpression];
ClearSystemCache[];

payload = <|
  "Status" -> "CompleteLocalFHatBenchmark",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Source" -> <|
    "Path" -> s13Path,
    "ByteCount" -> s13ByteCount,
    "Status" -> "CompleteFinitePartonicStructureFunctionsHqq"
  |>,
  "Construction" -> <|
    "Method" -> "imported directly from S13 saved F-hat actions",
    "Epsilon" -> 0,
    "ActionCoefficients" -> fields
  |>,
  "ComparisonLevel" ->
    "finite Hqq coefficient action before PDFs, FFs, and xi convolution",
  "Conventions" -> <|
    "Couplings" -> "EL=1 and g_s=1; generated down-type charge is retained",
    "Color" -> "SU(3): CA=3, CF=4/3, TF=1/2",
    "FlavorCount" -> benchmark["Nf"],
    "Scale" -> "ScaleMu=Q",
    "EndpointRegulator" -> N[endpointRegulator, 17],
    "DifferenceDirectionExpectedByS02" -> "BigTMD minus local"
  |>,
  "Benchmark" -> <|
    "ID" -> benchmark["ID"],
    "xB" -> N[benchmark["xB"], 17],
    "xi" -> N[benchmark["xi"], 17],
    "xHat" -> N[xHatValue, 17],
    "zH" -> N[benchmark["zH"], 17],
    "Q2" -> N[benchmark["Q2"], 17],
    "Q" -> N[Sqrt[benchmark["Q2"]], 17],
    "qT2" -> N[benchmark["qT2"], 17],
    "PHT2" -> N[benchmark["PHT2"], 17],
    "ScaleMu" -> N[Sqrt[benchmark["Q2"]], 17],
    "Nf" -> benchmark["Nf"],
    "S23UpperB" -> N[upperBValue, 17],
    "S23Fraction" -> N[benchmark["S23Fraction"], 17],
    "S23Sample" -> N[s23SampleValue, 17]
  |>,
  "FieldS23" -> AssociationMap[N[fieldS23Values[#], 17] &, fields],
  "LocalFHatByField" -> localValues
|>;

atomicRawJSONExport[data_, path_String] := Module[{temporaryPath, exported},
  temporaryPath = path <> ".tmp";
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  exported = Quiet@Check[Export[temporaryPath, data, "RawJSON"], $Failed];
  assert[exported =!= $Failed && FileExistsQ[temporaryPath] &&
      FileByteCount[temporaryPath] > 0,
    "failed to export the compact local benchmark JSON."];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
];

Print["BIGTMD_CHECK_S01_STAGE: writing compact local benchmark"];
atomicRawJSONExport[payload, outputPath];
Print["BIGTMD_CHECK_S01_SUCCESS"];
Print["BIGTMD_CHECK_S01_OUTPUT=" <> outputPath];
Print["BIGTMD_CHECK_S01_OUTPUT_BYTES=", FileByteCount[outputPath]];

(* ::Package:: *)

(*
  Hqq stage s13: convert the two finite S12 projector contractions into
  the finite partonic structure functions F1Hat and F2Hat.

  The authoritative paper's Eq. (9), applied to the partonic tensor in
  Eq. (16), gives

    F1Hat = (-Pg/2 + 2 xHat^2 PPP/Q2)/(1-epsilon),
    F2Hat = -xHat Pg/(1-epsilon) +
      4 xHat^3 (3-2 epsilon) PPP/(Q2 (1-epsilon)).

  S12 has already extracted the finite, epsilon-free coefficient of each
  projector action.  This stage applies epsilon -> 0 to the compact
  projector weights, combines the exact endpoint/integrand coefficient
  pairs fieldwise, and rebuilds one distributional action for each FHat.
*)

$HistoryLength = 0;

ClearAll[
  fatal, assert, atomicPut, pairToAction,
  S10ConvolutionTest, S13ConvolutionTest
];

fatal[message_String] := (
  Print["S13_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

atomicPut[expression_, path_String] := Module[
  {directory, temporaryPath},
  directory = DirectoryName[path];
  If[! DirectoryQ[directory],
    CreateDirectory[directory, CreateIntermediateDirectories -> True]
  ];
  temporaryPath = path <> ".tmp-" <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  Check[
    Put[expression, temporaryPath],
    fatal["Atomic result write failed for " <> path <> "."]
  ];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "Atomic result temporary file is absent or empty for " <> path <> "."];
  Check[
    RenameFile[temporaryPath, path, OverwriteTarget -> True],
    fatal["Atomic result rename failed for " <> path <> "."]
  ];
  assert[FileExistsQ[path] && FileByteCount[path] > 0,
    "Atomic result destination is absent or empty for " <> path <> "."];
  path
];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
s12Path = FileNameJoin[{scriptDirectory, "s12_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s13_result"}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
structureFunctions = {"F1Hat", "F2Hat"};

Print["S13_STAGE: loading and validating the completed S12 result"];
assert[FileExistsQ[s12Path] && FileByteCount[s12Path] > 0,
  "s12_result is absent or empty."];
assert[FileExistsQ[paperPath],
  "The authoritative paper is absent."];

s12ByteCount = FileByteCount[s12Path];
s12 = Quiet@Check[Get[s12Path], $Failed];
assert[AssociationQ[s12] &&
    s12["Status"] === "CompleteFiniteFactorizedHqq",
  "s12_result is unreadable or incomplete."];
assert[AssociationQ[s12["Checks"]] && And @@ Values[s12["Checks"]],
  "s12_result contains a failed validation check."];
assert[Sort[Keys[s12["FiniteHattedHardFunctionsByProjector"]]] ===
    Sort[projectors],
  "s12_result does not contain both completed H functions."];

finiteProjectorPairs = s12["FiniteCoefficientPairsByProjector"];
assert[AssociationQ[finiteProjectorPairs] &&
    Sort[Keys[finiteProjectorPairs]] === Sort[projectors],
  "s12_result lacks the two finite projector coefficient pairs."];
assert[And @@ Table[
    AssociationQ[finiteProjectorPairs[projector]] &&
      Sort[Keys[finiteProjectorPairs[projector]]] === Sort[pairFields],
    {projector, projectors}
  ],
  "A finite projector coefficient pair has an invalid field schema."];

xHat = s12["PhysicalMap", "XHat"];
integrationInterval = s12["PhysicalMap", "Interval"];
assert[FreeQ[xHat, epsilon],
  "The S12 xHat map unexpectedly contains epsilon."];
assert[MatchQ[integrationInterval, {_, 0, _}],
  "The S12 integration interval is invalid."];
integrationVariable = First[integrationInterval];

(*
  Retain only the exact finite coefficient representation needed below.
  Clearing the large S12 container releases its virtual, counterterm, and
  provenance payloads before either structure function is constructed.
*)
Clear[s12];
ClearSystemCache[];

Print["S13_STAGE: applying paper Eq. (9) and epsilon -> 0"];
projectorWeightsD = <|
  "F1Hat" -> <|
    "Pg" -> -1/(2 (1 - epsilon)),
    "PPP" -> 2 xHat^2/(Q2 (1 - epsilon))
  |>,
  "F2Hat" -> <|
    "Pg" -> -xHat/(1 - epsilon),
    "PPP" -> 4 xHat^3 (3 - 2 epsilon)/(Q2 (1 - epsilon))
  |>
|>;
projectorWeights4D = projectorWeightsD /. epsilon -> 0;
assert[FreeQ[projectorWeights4D, epsilon],
  "epsilon remains in the four-dimensional projector weights."];
assert[And[
    TrueQ[Together[projectorWeights4D["F1Hat", "Pg"] + 1/2] === 0],
    TrueQ[Together[
      projectorWeights4D["F1Hat", "PPP"] - 2 xHat^2/Q2
    ] === 0],
    TrueQ[Together[
      projectorWeights4D["F2Hat", "Pg"] + xHat
    ] === 0],
    TrueQ[Together[
      projectorWeights4D["F2Hat", "PPP"] - 12 xHat^3/Q2
    ] === 0]
  ],
  "The epsilon -> 0 projector weights do not match paper Eq. (9)."];

f1Values = {};
f2Values = {};
Do[
  Print["S13_FIELD: combining " <> field];
  pgValue = finiteProjectorPairs["Pg", field];
  pppValue = finiteProjectorPairs["PPP", field];
  AppendTo[f1Values,
    projectorWeights4D["F1Hat", "Pg"] pgValue +
      projectorWeights4D["F1Hat", "PPP"] pppValue
  ];
  AppendTo[f2Values,
    projectorWeights4D["F2Hat", "Pg"] pgValue +
      projectorWeights4D["F2Hat", "PPP"] pppValue
  ];
  finiteProjectorPairs = AssociationMap[
    KeyDrop[finiteProjectorPairs[#], field] &,
    projectors
  ];
  Clear[pgValue, pppValue];
  ClearSystemCache[];
  ,
  {field, pairFields}
];
Clear[finiteProjectorPairs];

fHatPairs = <|
  "F1Hat" -> AssociationThread[pairFields, f1Values],
  "F2Hat" -> AssociationThread[pairFields, f2Values]
|>;
Clear[f1Values, f2Values];
ClearSystemCache[];

pairToAction[pair_Association, label_String] :=
  pair["Endpoint"] S13ConvolutionTest[label, 0] +
    Inactive[Integrate][
      pair["IntegrandPhiS"] *
          S13ConvolutionTest[label, integrationVariable] +
        pair["IntegrandPhi0"] S13ConvolutionTest[label, 0],
      integrationInterval
    ];

Print["S13_STAGE: rebuilding the two finite structure-function actions"];
fHatFunctionRules = Table[
  Print["S13_ACTION: constructing " <> structureFunction];
  action = pairToAction[fHatPairs[structureFunction], structureFunction];
  fHatPairs = KeyDrop[fHatPairs, structureFunction];
  ClearSystemCache[];
  structureFunction -> action
  ,
  {structureFunction, structureFunctions}
];
fHatFunctions = Association[fHatFunctionRules];
Clear[fHatFunctionRules, fHatPairs, action];
ClearSystemCache[];

Print["S13_STAGE: validating epsilon-free F hats"];
functionChecks = AssociationMap[
  Function[structureFunction,
    <|
      "ContainsNoEpsilonOrSeries" ->
        FreeQ[
          fHatFunctions[structureFunction],
          epsilon | _SeriesData
        ],
      "ContainsNoProjectorTestFunction" ->
        FreeQ[fHatFunctions[structureFunction], _S10ConvolutionTest],
      "RetainsOrdinaryS23Integral" ->
        ! FreeQ[
          fHatFunctions[structureFunction],
          Inactive[Integrate][___]
        ],
      "RetainsMatchingArbitraryTestFunction" ->
        ! FreeQ[
          fHatFunctions[structureFunction],
          S13ConvolutionTest[structureFunction, _]
        ]
    |>
  ],
  structureFunctions
];

s13Checks = <|
  "S12CompleteAndValidated" -> True,
  "BothProjectorHardFunctionsConsumed" -> True,
  "PaperEq9PartonicInversionUsed" -> True,
  "EpsilonSetToZero" ->
    And @@ Table[
      TrueQ[
        functionChecks[structureFunction, "ContainsNoEpsilonOrSeries"]
      ],
      {structureFunction, structureFunctions}
    ],
  "ExactlyF1HatAndF2HatProduced" ->
    Sort[Keys[fHatFunctions]] === Sort[structureFunctions],
  "ProjectorTestFunctionsAligned" ->
    And @@ Table[
      TrueQ[
        functionChecks[
          structureFunction, "ContainsNoProjectorTestFunction"
        ]
      ],
      {structureFunction, structureFunctions}
    ],
  "OrdinaryS23IntegralsRetained" ->
    And @@ Table[
      TrueQ[
        functionChecks[
          structureFunction, "RetainsOrdinaryS23Integral"
        ]
      ],
      {structureFunction, structureFunctions}
    ],
  "ArbitrarySymbolicTestsRetained" ->
    And @@ Table[
      TrueQ[
        functionChecks[
          structureFunction, "RetainsMatchingArbitraryTestFunction"
        ]
      ],
      {structureFunction, structureFunctions}
    ],
  "CalculationFullySymbolic" -> True,
  "SerialExecutionAvoidsLargeSubkernelCopies" -> True
|>;
assert[And @@ Values[s13Checks],
  "At least one final S13 validation check is not True."];

s13Result = <|
  "Status" -> "CompleteFinitePartonicStructureFunctionsHqq",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s12Path,
  "SourceResultBytes" -> s12ByteCount,
  "AuthoritativePaper" -> paperPath,
  "PaperReference" -> <|
    "HadronicTensorDecomposition" -> "Eq. (5)",
    "ExtractionTensors" -> "Eqs. (7)-(9)",
    "PartonicTensorDecomposition" -> "Eq. (16)"
  |>,
  "DimensionalProjectorInversion" -> <|
    "F1Hat" -> HoldForm[
      F1Hat == (-HSubPg/2 + 2 xHat^2 HSubPPP/Q2)/(1 - epsilon)
    ],
    "F2Hat" -> HoldForm[
      F2Hat == -xHat HSubPg/(1 - epsilon) +
        4 xHat^3 (3 - 2 epsilon) HSubPPP/(Q2 (1 - epsilon))
    ]
  |>,
  "EpsilonRule" -> HoldForm[epsilon -> 0],
  "FourDimensionalProjectorWeights" -> projectorWeights4D,
  "XHat" -> xHat,
  "IntegrationInterval" -> integrationInterval,
  "FiniteHattedStructureFunctions" -> fHatFunctions,
  "TestFunction" -> HoldForm[
    S13ConvolutionTest[structureFunction, s23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s23=0 and independent of epsilon",
  "FunctionChecks" -> functionChecks,
  "Checks" -> s13Checks,
  "NotPerformedAtThisStage" -> {
    "outer xi convolution with a concrete PDF",
    "choice or numerical evaluation of PDFs, fragmentation functions, or kinematics",
    "sum over other partonic channels"
  }
|>;

Print["S13_STAGE: writing finite hatted Hqq structure functions"];
atomicPut[s13Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "s13_result was not written or is empty."];

Print["S13_SUCCESS_FINITE_FHAT_HQQ"];
Print["S13_RESULT_PATH=" <> resultPath];
Print["S13_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S13_CHECKS=", InputForm[s13Checks]];
Quit[0];

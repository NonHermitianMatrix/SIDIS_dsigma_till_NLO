(* ::Package:: *)

(*
  Hqg stage S13: convert the two finite S12 projector contractions into
  the finite partonic structure functions F1Hat and F2Hat.

  The authoritative paper's Eq. (9), applied to the partonic tensor in
  Eq. (16), gives

    F1Hat = (-Pg/2 + 2 xHat^2 PPP/Q2)/(1-epsilon),
    F2Hat = -xHat Pg/(1-epsilon) +
      4 xHat^3 (3-2 epsilon) PPP/(Q2 (1-epsilon)).

  Hqg S12-v4 is about 502 MB because it stores both finite coefficient
  pairs and rebuilt projector actions. This stage never monolithically
  imports that result. It scans fixed-size byte chunks, parses only compact
  metadata/check slices, and streams only the coefficient-pair field to an
  atomic temporary projection. The projection is deleted immediately after
  its exact symbolic payload is loaded.
*)

$HistoryLength = 0;

Needs["FeynCalc`"];

$HistoryLength = 0;

ClearAll["Global`*"];

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

feynCalcOwnedSymbolNames = {"CF", "CA", "TF", "SMP", "FCGV"};

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

findUniqueByteMarkerOffsets[path_String, markers_List] := Module[
  {
    chunkSize = 1024^2, markerBytes, offsets, maximumMarkerLength,
    stream, overlap = {}, chunk, data, dataStart, positions, marker
  },
  markerBytes = AssociationThread[
    markers,
    (ToCharacterCode[#, "UTF8"] &) /@ markers
  ];
  offsets = AssociationThread[
    markers,
    ConstantArray[{}, Length[markers]]
  ];
  maximumMarkerLength = Max[Length /@ Values[markerBytes]];
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "The Hqg S12 result could not be opened for bounded byte scanning."];
  While[True,
    chunk = Quiet@Check[
      BinaryReadList[stream, "Byte", chunkSize],
      $Failed
    ];
    assert[chunk =!= $Failed,
      "The bounded Hqg S12 byte scan failed while reading a chunk."];
    If[chunk === {} || chunk === EndOfFile, Break[]];
    data = Join[overlap, chunk];
    dataStart = StreamPosition[stream] - Length[chunk] - Length[overlap];
    Do[
      positions = SequencePosition[data, markerBytes[marker]];
      offsets[marker] = Join[
        offsets[marker],
        (dataStart + First[#] - 1 &) /@ positions
      ];,
      {marker, markers}
    ];
    overlap = Take[
      data,
      -Min[Length[data], maximumMarkerLength - 1]
    ];
  ];
  Close[stream];
  offsets = Map[DeleteDuplicates, offsets];
  assert[AllTrue[Values[offsets], Length[#] === 1 &],
    "The Hqg S12 result does not contain exactly one copy of every " <>
      "required projected-load marker."];
  AssociationMap[First[offsets[#]] &, markers]
];

readUTF8ByteRange[
    path_String, start_Integer, count_Integer, label_String
  ] := Module[{stream, bytes},
  assert[start >= 0 && count >= 0,
    "Invalid byte range requested for " <> label <> "."];
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "The Hqg S12 result could not be opened for " <> label <> "."];
  SetStreamPosition[stream, start];
  bytes = Quiet@Check[BinaryReadList[stream, "Byte", count], $Failed];
  Close[stream];
  assert[ListQ[bytes] && Length[bytes] === count,
    "The bounded Hqg S12 read was incomplete for " <> label <> "."];
  FromCharacterCode[bytes, "UTF8"]
];

parseProjectedText[text_String, label_String] := Module[{held},
  held = Quiet@Check[ToExpression[text, InputForm, HoldComplete], $Failed];
  assert[MatchQ[held, HoldComplete[_]],
    "The projected Hqg S12 text did not parse for " <> label <> "."];
  ReleaseHold[held]
];

dropTrailingFieldSeparator[text_String, label_String] := Module[
  {trimmed = StringTrim[text]},
  assert[StringEndsQ[trimmed, ","],
    "The projected Hqg S12 field boundary is malformed for " <> label <> "."];
  StringTrim[StringDrop[trimmed, -1]]
];

fieldValueEndOffset[
    path_String, valueStart_Integer, nextMarkerOffset_Integer,
    label_String
  ] := Module[
  {
    whitespaceBytes = {9, 10, 13, 32}, tailCount, tailStart,
    stream, tailBytes, position, commaOffset
  },
  assert[0 <= valueStart < nextMarkerOffset,
    "The projected byte range is invalid for " <> label <> "."];
  tailCount = Min[4096, nextMarkerOffset - valueStart];
  tailStart = nextMarkerOffset - tailCount;
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "The Hqg S12 result could not be opened for the " <> label <>
      " boundary check."];
  SetStreamPosition[stream, tailStart];
  tailBytes = Quiet@Check[
    BinaryReadList[stream, "Byte", tailCount],
    $Failed
  ];
  Close[stream];
  assert[ListQ[tailBytes] && Length[tailBytes] === tailCount,
    "The projected tail read was incomplete for " <> label <> "."];
  position = Length[tailBytes];
  While[
    position >= 1 && MemberQ[whitespaceBytes, tailBytes[[position]]],
    position--
  ];
  assert[position >= 1 && tailBytes[[position]] === 44,
    "The projected value is not followed by a comma for " <> label <> "."];
  commaOffset = tailStart + position - 1;
  assert[commaOffset > valueStart,
    "The projected value is empty for " <> label <> "."];
  commaOffset
];

writeProjectedPairPayload[
    sourcePath_String, valueStart_Integer, valueEnd_Integer,
    targetPath_String, sourceSHA256_Integer, sourceBytes_Integer,
    stageVersion_String
  ] := Module[
  {
    chunkSize = 1024^2, temporaryPath, input, output, header, footer,
    remaining, take, chunk
  },
  assert[0 <= valueStart < valueEnd <= sourceBytes,
    "The finite-pair projection range is invalid."];
  temporaryPath = targetPath <> ".tmp-" <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  If[FileExistsQ[targetPath],
    Print["S13_CLEANUP: deleting stale finite-pair projection"];
    DeleteFile[targetPath]
  ];
  header =
    "<|\"CacheVersion\" -> 1, \"StageVersion\" -> \"" <>
      stageVersion <> "\", \"S12SHA256\" -> " <>
      ToString[sourceSHA256, InputForm] <> ", \"S12Bytes\" -> " <>
      ToString[sourceBytes, InputForm] <>
      ", \"FiniteCoefficientPairsByProjector\" -> ";
  footer = "|>";
  input = Quiet@Check[
    OpenRead[sourcePath, BinaryFormat -> True],
    $Failed
  ];
  output = Quiet@Check[
    OpenWrite[targetPath <> ".tmp-" <> ToString[$ProcessID],
      BinaryFormat -> True],
    $Failed
  ];
  assert[Head[input] === InputStream && Head[output] === OutputStream,
    "The finite-pair projection streams could not be opened."];
  Check[
    BinaryWrite[output, ToCharacterCode[header, "UTF8"], "Byte"],
    Close[input]; Close[output];
    fatal["The finite-pair projection header write failed."]
  ];
  SetStreamPosition[input, valueStart];
  remaining = valueEnd - valueStart;
  While[remaining > 0,
    take = Min[chunkSize, remaining];
    chunk = Quiet@Check[
      BinaryReadList[input, "Byte", take],
      $Failed
    ];
    assert[ListQ[chunk] && Length[chunk] === take,
      "The streamed finite-pair source read was incomplete."];
    Check[
      BinaryWrite[output, chunk, "Byte"],
      Close[input]; Close[output];
      fatal["The streamed finite-pair projection write failed."]
    ];
    remaining -= take;
  ];
  Check[
    BinaryWrite[output, ToCharacterCode[footer, "UTF8"], "Byte"],
    Close[input]; Close[output];
    fatal["The finite-pair projection footer write failed."]
  ];
  Close[input];
  Close[output];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "The finite-pair projection temporary file is absent or empty."];
  Check[
    RenameFile[temporaryPath, targetPath, OverwriteTarget -> True],
    fatal["The finite-pair projection atomic rename failed."]
  ];
  assert[FileExistsQ[targetPath] && FileByteCount[targetPath] > 0,
    "The finite-pair projection destination is absent or empty."];
  targetPath
];

loadProjectedS12[path_String, projectionPath_String] := Module[
  {
    finitePairsMarker = "\"FiniteCoefficientPairsByProjector\" ->",
    finiteFunctionsMarker =
      "\"FiniteHattedHardFunctionsByProjector\" ->",
    checksMarker = "\"Checks\" ->",
    markers, offsets, fileBytes, sourceSHA256, metadataPrefixText,
    checksTailText, metadataPrefix, metadataTail, valueStart, valueEnd,
    projectedPayload, finitePairs
  },
  markers = {finitePairsMarker, finiteFunctionsMarker, checksMarker};
  fileBytes = FileByteCount[path];
  sourceSHA256 = FileHash[path, "SHA256"];
  offsets = findUniqueByteMarkerOffsets[path, markers];
  assert[
    0 < offsets[finitePairsMarker] < offsets[finiteFunctionsMarker] <
      offsets[checksMarker] < fileBytes,
    "The Hqg S12 projected-load fields are out of order."];

  metadataPrefixText = dropTrailingFieldSeparator[
    readUTF8ByteRange[
      path, 0, offsets[finitePairsMarker], "metadata prefix"
    ],
    "metadata prefix"
  ];
  metadataPrefix = parseProjectedText[
    metadataPrefixText <> "|>",
    "metadata prefix"
  ];

  checksTailText = readUTF8ByteRange[
    path,
    offsets[checksMarker],
    fileBytes - offsets[checksMarker],
    "checks/provenance tail"
  ];
  metadataTail = parseProjectedText[
    "<|" <> checksTailText,
    "checks/provenance tail"
  ];
  assert[AssociationQ[metadataPrefix] && AssociationQ[metadataTail],
    "The projected Hqg S12 metadata slices have invalid schemas."];

  valueStart = offsets[finitePairsMarker] +
    Length[ToCharacterCode[finitePairsMarker, "UTF8"]];
  valueEnd = fieldValueEndOffset[
    path, valueStart, offsets[finiteFunctionsMarker],
    "FiniteCoefficientPairsByProjector"
  ];
  Print[
    "S13_STAGE: streaming ", valueEnd - valueStart,
    " finite-pair bytes from S12"
  ];
  writeProjectedPairPayload[
    path, valueStart, valueEnd, projectionPath, sourceSHA256, fileBytes,
    stageVersion
  ];
  projectedPayload = Quiet@Check[Get[projectionPath], $Failed];
  assert[
    AssociationQ[projectedPayload] &&
      projectedPayload["CacheVersion"] === 1 &&
      projectedPayload["StageVersion"] === stageVersion &&
      projectedPayload["S12SHA256"] === sourceSHA256 &&
      projectedPayload["S12Bytes"] === fileBytes &&
      AssociationQ[
        projectedPayload["FiniteCoefficientPairsByProjector"]
      ],
    "The projected finite-pair payload is unreadable or source-stale."];
  finitePairs =
    projectedPayload["FiniteCoefficientPairsByProjector"];
  Clear[projectedPayload];
  ClearSystemCache[];
  DeleteFile[projectionPath];
  assert[! FileExistsQ[projectionPath],
    "The disposable finite-pair projection was not deleted."];
  Print["S13_CLEANUP: deleted disposable finite-pair projection"];

  <|
    "Metadata" -> Join[metadataPrefix, metadataTail],
    "FinitePairs" -> finitePairs,
    "MarkerOffsets" -> offsets,
    "FileBytes" -> fileBytes,
    "FileSHA256" -> sourceSHA256,
    "ProjectedValueBytes" -> valueEnd - valueStart
  |>
];

pairToAction[pair_Association, label_String, interval_List] :=
  pair["Endpoint"] S13ConvolutionTest[label, 0] +
    Inactive[Integrate][
      pair["IntegrandPhiS"] *
          S13ConvolutionTest[label, First[interval]] +
        pair["IntegrandPhi0"] S13ConvolutionTest[label, 0],
      interval
    ];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
s12Path = FileNameJoin[{scriptDirectory, "s12_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s13_result"}];
projectionPath = FileNameJoin[{
  scriptDirectory, "s13_projected_finite_pairs"
}];
paperPath = FileNameJoin[{
  DirectoryName[scriptDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"
}];

stageVersion = "HqgS13-v1";
sourceStageVersion = "HqgS12-v4";
projectors = {"Pg", "PPP"};
pairFields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
structureFunctions = {"F1Hat", "F2Hat"};

Print["S13_STAGE: validating and projecting completed Hqg S12-v4"];
assert[FileExistsQ[s12Path] && FileByteCount[s12Path] > 0,
  "s12_result is absent or empty."];
assert[FileExistsQ[paperPath] && FileByteCount[paperPath] > 0,
  "The authoritative paper is absent or empty."];
programSHA256 = FileHash[programPath, "SHA256"];
paperSHA256 = FileHash[paperPath, "SHA256"];
s12Projection = loadProjectedS12[s12Path, projectionPath];
s12Metadata = s12Projection["Metadata"];
finiteProjectorPairs = s12Projection["FinitePairs"];
s12ByteCount = s12Projection["FileBytes"];
s12SHA256 = s12Projection["FileSHA256"];
projectedValueBytes = s12Projection["ProjectedValueBytes"];
s12MarkerOffsets = s12Projection["MarkerOffsets"];
Clear[s12Projection];
ClearSystemCache[];

assert[
  AssociationQ[s12Metadata] &&
    s12Metadata["Status"] === "CompleteFiniteFactorizedHqg" &&
    s12Metadata["Stage"] === sourceStageVersion &&
    s12Metadata["StageVersion"] === sourceStageVersion &&
    s12Metadata["Channel"] === "Hqg only",
  "s12_result is incomplete or is not HqgS12-v4."];
assert[
  AssociationQ[s12Metadata["Checks"]] &&
    AllTrue[Values[s12Metadata["Checks"]], TrueQ],
  "s12_result contains a failed validation check."];
assert[
  FileExistsQ[s12Metadata["Program"]] &&
    FileHash[s12Metadata["Program"], "SHA256"] ===
      s12Metadata["ProgramSHA256"],
  "The Hqg S12 program SHA-256 binding is stale."];

s12Sources = s12Metadata["SourceResults"];
assert[
  AssociationQ[s12Sources] &&
    FileExistsQ[s12Sources["UVRenormalizedRealVirtual"]] &&
    FileHash[
      s12Sources["UVRenormalizedRealVirtual"], "SHA256"
    ] === s12Sources["UVRenormalizedRealVirtualSHA256"] &&
    FileExistsQ[s12Sources["S10VirtualLaurentCache"]] &&
    FileHash[
      s12Sources["S10VirtualLaurentCache"], "SHA256"
    ] === s12Sources["S10VirtualLaurentCacheSHA256"] &&
    FileExistsQ[s12Sources["CollinearCounterterms"]] &&
    FileHash[
      s12Sources["CollinearCounterterms"], "SHA256"
    ] === s12Sources["CollinearCountertermsSHA256"] &&
    s12Sources["AuthoritativePaper"] === paperPath &&
    s12Sources["AuthoritativePaperSHA256"] === paperSHA256,
  "An Hqg S12 upstream source or paper SHA-256 binding is invalid."];

bigTMDConvention = s12Metadata["BigTMDConvention"];
assert[
  AssociationQ[bigTMDConvention] &&
    bigTMDConvention["ChannelNumber"] === 3 &&
    bigTMDConvention["ChargeCase"] === "A only" &&
    bigTMDConvention["FragmentingParton"] === "gluon g(k1)" &&
    bigTMDConvention["ProjectorMapping"] === <|
      "Pg" -> "NLO.Pg.fchn3A",
      "PPP" -> "NLO.Ppp.fchn3A"
    |> &&
    And @@ Table[
      FileExistsQ[bigTMDConvention["ReferenceFiles", projector]] &&
        FileHash[
          bigTMDConvention["ReferenceFiles", projector], "SHA256"
        ] === bigTMDConvention["ReferenceSHA256", projector],
      {projector, projectors}
    ],
  "The Hqg BigTMD channel-3A source binding is invalid."];

assert[
  AssociationQ[finiteProjectorPairs] &&
    Sort[Keys[finiteProjectorPairs]] === Sort[projectors],
  "s12_result lacks the two finite projector coefficient pairs."];
assert[
  And @@ Table[
    AssociationQ[finiteProjectorPairs[projector]] &&
      Sort[Keys[finiteProjectorPairs[projector]]] === Sort[pairFields],
    {projector, projectors}
  ],
  "A finite projector coefficient pair has an invalid field schema."];
assert[
  FreeQ[
    finiteProjectorPairs,
    epsilon | _SeriesData | _Real | $Failed | Indeterminate |
      ComplexInfinity | DirectedInfinity[_]
  ],
  "An S12 finite projector coefficient is not exact and epsilon-free."];
assert[feynCalcContextCleanQ[finiteProjectorPairs],
  "An S12 finite projector coefficient contains accidental Global-context " <>
    "FeynCalc/QCD symbols."];

physicalMap = s12Metadata["PhysicalMap"];
assert[
  AssociationQ[physicalMap] &&
    KeyExistsQ[physicalMap, "XHat"] &&
    KeyExistsQ[physicalMap, "Interval"],
  "The Hqg S12 physical map lacks XHat or Interval."];
xHat = physicalMap["XHat"];
integrationInterval = physicalMap["Interval"];
assert[FreeQ[{xHat, integrationInterval}, epsilon | _Real],
  "The Hqg physical map is not exact and epsilon-free."];
assert[MatchQ[integrationInterval, {s23, 0, _}],
  "The Hqg S12 integration interval is invalid."];
assert[TrueQ[Cancel[Together[xHat - xB/xi]] === 0],
  "The Hqg S12 XHat map is not xB/xi."];
assert[
  TrueQ[Cancel[Together[
    Last[integrationInterval] -
      (Q2 (xi/xB - 1) (1 - zH) - PHT2/zH)
  ]] === 0],
  "The Hqg S12 s23 upper limit is not the validated physical limit."];
assert[
  s12Metadata["SpeciesRouting", "PhysicalLuminosityAppliedDownstream"] ===
    "Sum_q e_q^2 f_q D_g",
  "The Hqg physical luminosity boundary is invalid."];

Clear[s12Metadata, s12Sources, physicalMap];
ClearSystemCache[];

Print["S13_STAGE: applying paper Eq. (9) and epsilon -> 0 exactly"];
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
assert[FreeQ[projectorWeights4D, epsilon | _Real],
  "The four-dimensional projector weights are not exact and epsilon-free."];
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
  AppendTo[
    f1Values,
    projectorWeights4D["F1Hat", "Pg"] pgValue +
      projectorWeights4D["F1Hat", "PPP"] pppValue
  ];
  AppendTo[
    f2Values,
    projectorWeights4D["F2Hat", "Pg"] pgValue +
      projectorWeights4D["F2Hat", "PPP"] pppValue
  ];
  finiteProjectorPairs = AssociationMap[
    KeyDrop[finiteProjectorPairs[#], field] &,
    projectors
  ];
  Clear[pgValue, pppValue];
  ClearSystemCache[];,
  {field, pairFields}
];
Clear[finiteProjectorPairs];

fHatPairs = <|
  "F1Hat" -> AssociationThread[pairFields, f1Values],
  "F2Hat" -> AssociationThread[pairFields, f2Values]
|>;
Clear[f1Values, f2Values];
ClearSystemCache[];

Print["S13_STAGE: rebuilding the two finite Hqg structure-function actions"];
fHatFunctionRules = Table[
  Print["S13_ACTION: constructing " <> structureFunction];
  action = pairToAction[
    fHatPairs[structureFunction], structureFunction, integrationInterval
  ];
  fHatPairs = KeyDrop[fHatPairs, structureFunction];
  ClearSystemCache[];
  structureFunction -> action,
  {structureFunction, structureFunctions}
];
fHatFunctions = Association[fHatFunctionRules];
Clear[fHatFunctionRules, fHatPairs, action];
ClearSystemCache[];

Print["S13_STAGE: validating exact epsilon-free Hqg F hats"];
functionChecks = AssociationMap[
  Function[structureFunction,
    <|
      "ContainsNoEpsilonSeriesOrMachineReal" -> FreeQ[
        fHatFunctions[structureFunction],
        epsilon | _SeriesData | _Real
      ],
      "ContainsNoProjectorTestFunction" ->
        FreeQ[fHatFunctions[structureFunction], _S10ConvolutionTest],
      "RetainsOrdinaryS23Integral" -> ! FreeQ[
        fHatFunctions[structureFunction],
        Inactive[Integrate][___]
      ],
      "RetainsMatchingArbitraryTestFunction" -> ! FreeQ[
        fHatFunctions[structureFunction],
        S13ConvolutionTest[structureFunction, _]
      ],
      "FeynCalcContextsClean" ->
        feynCalcContextCleanQ[fHatFunctions[structureFunction]]
    |>
  ],
  structureFunctions
];

s13Checks = <|
  "HqgS12V4CompleteValidatedAndSourceBound" -> True,
  "ProjectedS12LoadUsesFixedMemoryChunks" -> True,
  "MonolithicS12ResultLoadExcluded" -> True,
  "DisposablePairProjectionDeleted" -> ! FileExistsQ[projectionPath],
  "BothProjectorHardFunctionsConsumed" -> True,
  "PaperEq9PartonicInversionUsed" -> True,
  "EpsilonSetToZeroWithoutDecimalConversion" -> And @@ Table[
    TrueQ[
      functionChecks[structureFunction][
        "ContainsNoEpsilonSeriesOrMachineReal"
      ]
    ],
    {structureFunction, structureFunctions}
  ],
  "ExactlyF1HatAndF2HatProduced" ->
    Sort[Keys[fHatFunctions]] === Sort[structureFunctions],
  "ProjectorTestFunctionsAligned" -> And @@ Table[
    TrueQ[
      functionChecks[structureFunction][
        "ContainsNoProjectorTestFunction"
      ]
    ],
    {structureFunction, structureFunctions}
  ],
  "OrdinaryS23IntegralsRetained" -> And @@ Table[
    TrueQ[
      functionChecks[structureFunction]["RetainsOrdinaryS23Integral"]
    ],
    {structureFunction, structureFunctions}
  ],
  "ArbitrarySymbolicTestsRetained" -> And @@ Table[
    TrueQ[
      functionChecks[structureFunction][
        "RetainsMatchingArbitraryTestFunction"
      ]
    ],
    {structureFunction, structureFunctions}
  ],
  "BigTMDChannel3ABindingRetained" ->
    bigTMDConvention["ChannelNumber"] === 3 &&
      bigTMDConvention["ChargeCase"] === "A only",
  "PhysicalLuminosityRemainsDeferred" -> True,
  "NoAccidentalGlobalFeynCalcSymbols" -> And @@ Table[
    TrueQ[functionChecks[structureFunction]["FeynCalcContextsClean"]],
    {structureFunction, structureFunctions}
  ],
  "CalculationFullySymbolicAndExact" -> FreeQ[fHatFunctions, _Real],
  "SerialExecutionAvoidsLargeSubkernelCopies" -> True
|>;
assert[AllTrue[Values[s13Checks], TrueQ],
  "At least one final Hqg S13 validation check is not True."];

s13Result = <|
  "Status" -> "CompleteFinitePartonicStructureFunctionsHqg",
  "Channel" -> "Hqg only",
  "Stage" -> stageVersion,
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s12Path,
  "SourceResultBytes" -> s12ByteCount,
  "SourceResultSHA256" -> s12SHA256,
  "SourceStageVersion" -> sourceStageVersion,
  "ProjectedSourceValueBytes" -> projectedValueBytes,
  "ProjectedSourceMarkerOffsets" -> s12MarkerOffsets,
  "AuthoritativePaper" -> paperPath,
  "AuthoritativePaperSHA256" -> paperSHA256,
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
  "BigTMDConvention" -> bigTMDConvention,
  "PhysicalLuminosityAppliedDownstream" -> "Sum_q e_q^2 f_q D_g",
  "FiniteHattedStructureFunctions" -> fHatFunctions,
  "TestFunction" -> HoldForm[
    S13ConvolutionTest[structureFunction, s23]
  ],
  "TestFunctionAssumption" ->
    "arbitrary symbolic function regular at s23=0 and independent of epsilon",
  "FunctionChecks" -> functionChecks,
  "Checks" -> s13Checks,
  "MemoryStrategy" ->
    "fixed-memory S12 marker scan; compact metadata/tail parse; streamed temporary finite-pair projection deleted after one exact load; serial fieldwise Pg/PPP combination; no subkernels",
  "NotPerformedAtThisStage" -> {
    "outer xi convolution with a concrete quark PDF or gluon fragmentation function",
    "physical Sum_q e_q^2 flavor luminosity multiplication",
    "choice or numerical evaluation of PDFs, fragmentation functions, or kinematics",
    "sum over other partonic channels",
    "BigTMD construction or comparison"
  }
|>;

Print["S13_STAGE: writing finite hatted Hqg structure functions"];
atomicPut[s13Result, resultPath];
assert[FileExistsQ[resultPath] && FileByteCount[resultPath] > 0,
  "s13_result was not written or is empty."];

Print["S13_SUCCESS_FINITE_FHAT_HQG"];
Print["S13_RESULT_PATH=", resultPath];
Print["S13_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S13_CHECKS=", InputForm[s13Checks]];

Quit[0];

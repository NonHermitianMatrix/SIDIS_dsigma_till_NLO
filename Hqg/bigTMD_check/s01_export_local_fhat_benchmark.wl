(* ::Package:: *)

(*
  Hqg BigTMD consistency check, stage S01.

  Read the validated Hqg S13 metadata/checks with bounded byte slices and
  stream one saved F-hat action at a time into a disposable projection.
  Extract Endpoint/IntegrandPhiS/IntegrandPhi0 structurally, evaluate one
  exact generic physical benchmark, and save only compact numerical JSON.

  The 530 MB S13 result is never monolithically imported. Each temporary
  action projection is deleted immediately after its expression is loaded.
*)

$HistoryLength = 0;
$LoadAddOns = {"FeynHelpers"};
Needs["FeynCalc`"];
$FCAdvice = False;
$HistoryLength = 0;

ClearAll[
  fatal, assert, zeroArgumentQ, resolveCanceledZeroLogs, numericalValue,
  benchmarkRules, actionToPair, atomicRawJSONExport,
  accidentalGlobalFeynCalcSymbolQ, feynCalcContextCleanQ,
  findByteMarkerOffsets, readUTF8ByteRange, parseProjectedText,
  dropTrailingFieldSeparator, fieldValueEndOffset,
  finalAssociationValueEndOffset,
  writeProjectedActionPayload, loadProjectedAction,
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
hqgDirectory = DirectoryName[scriptDirectory];
s13Path = FileNameJoin[{hqgDirectory, "s13_result"}];
outputPath = FileNameJoin[{scriptDirectory, "local_fhat_benchmark.json"}];
projectionPath = FileNameJoin[{
  scriptDirectory, "s01_projected_fhat_action"
}];
referencePgPath = FileNameJoin[{
  scriptDirectory, "BigTMD_reference", "NLO", "Pg", "fchn3A.py"
}];
referencePPPPath = FileNameJoin[{
  scriptDirectory, "BigTMD_reference", "NLO", "Ppp", "fchn3A.py"
}];

stageVersion = "HqgBigTMDCheckS01-v1";
fields = {"Endpoint", "IntegrandPhiS", "IntegrandPhi0"};
structureFunctions = {"F1Hat", "F2Hat"};
endpointRegulator = 1/10^7;

(*
  The shared generic point avoids simple symmetry loci. PHT2=zH^2 qT2
  exactly. One interior s23 sample checks both integrand coefficients.
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
assert[TrueQ[0 < xHatValue < 1],
  "the benchmark xHat is not physical."];
assert[TrueQ[upperBValue > 0],
  "the benchmark s23 upper bound is not positive."];
assert[TrueQ[0 < s23SampleValue < upperBValue],
  "the benchmark s23 sample is not in the open physical interval."];

feynCalcOwnedSymbolNames = {"CA", "CF", "TF", "SMP", "FCGV"};
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

couplingAndColorRules = {
  FeynCalc`CA -> 3,
  FeynCalc`CF -> 4/3,
  FeynCalc`TF -> 1/2,
  HoldPattern[FeynCalc`SMP["g_s"]] -> 1,
  HoldPattern[FeynCalc`FCGV["EL"]] -> 1,
  HoldPattern[FeynArts`FCGV["EL"]] -> 1,
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
        Sow[{position, HoldComplete @@ {argument}}]
      ];,
      {position, logPositions}
    ]
  ][[2]];
  zeroRecords = If[harvested === {}, {}, First[harvested]];
  If[zeroRecords === {}, Return[expression /. rules]];

  uniqueArguments = DeleteDuplicates[zeroRecords[[All, 2]], SameQ];
  Print[
    "BIGTMD_CHECK_S01_ZERO_LOG_CANDIDATES: " <> label <>
      " count=" <> ToString[Length[uniqueArguments]] <>
      " hashes=" <> ToString[
        InputForm[Hash[#, "SHA256"] & /@ uniqueArguments]
      ]
  ];
  placeholders = Table[Unique["zeroLogValue$"], {Length[uniqueArguments]}];
  positionRules = Map[
    Function[record,
      record[[1]] -> placeholders[[
        First@FirstPosition[uniqueArguments, record[[2]]]
      ]]
    ],
    zeroRecords
  ];
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
        "arguments=" <>
        ToString[InputForm[uniqueArguments[[dependentIndices]]]]
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
    label <> " is not a finite real number: " <>
      ToString[InputForm[value]]];
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

findByteMarkerOffsets[path_String, markers_List] := Module[
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
    "S13 could not be opened for bounded byte scanning."];
  While[True,
    chunk = Quiet@Check[
      BinaryReadList[stream, "Byte", chunkSize],
      $Failed
    ];
    assert[chunk =!= $Failed,
      "the bounded S13 byte scan failed while reading a chunk."];
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
  Map[DeleteDuplicates, offsets]
];

readUTF8ByteRange[
    path_String, start_Integer, count_Integer, label_String
  ] := Module[{stream, bytes},
  assert[start >= 0 && count >= 0,
    "invalid byte range requested for " <> label <> "."];
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "S13 could not be opened for " <> label <> "."];
  SetStreamPosition[stream, start];
  bytes = Quiet@Check[BinaryReadList[stream, "Byte", count], $Failed];
  Close[stream];
  assert[ListQ[bytes] && Length[bytes] === count,
    "the bounded S13 read was incomplete for " <> label <> "."];
  FromCharacterCode[bytes, "UTF8"]
];

parseProjectedText[text_String, label_String] := Module[{held},
  held = Quiet@Check[ToExpression[text, InputForm, HoldComplete], $Failed];
  assert[MatchQ[held, HoldComplete[_]],
    "the projected S13 text did not parse for " <> label <> "."];
  ReleaseHold[held]
];

dropTrailingFieldSeparator[text_String, label_String] := Module[
  {trimmed = StringTrim[text]},
  assert[StringEndsQ[trimmed, ","],
    "the projected S13 field boundary is malformed for " <> label <> "."];
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
    "the projected byte range is invalid for " <> label <> "."];
  tailCount = Min[4096, nextMarkerOffset - valueStart];
  tailStart = nextMarkerOffset - tailCount;
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "S13 could not be opened for the " <> label <> " boundary check."];
  SetStreamPosition[stream, tailStart];
  tailBytes = Quiet@Check[
    BinaryReadList[stream, "Byte", tailCount],
    $Failed
  ];
  Close[stream];
  assert[ListQ[tailBytes] && Length[tailBytes] === tailCount,
    "the projected S13 tail read was incomplete for " <> label <> "."];
  position = Length[tailBytes];
  While[
    position >= 1 && MemberQ[whitespaceBytes, tailBytes[[position]]],
    position--
  ];
  assert[position >= 1 && tailBytes[[position]] === 44,
    "the projected S13 value is not followed by a comma for " <>
      label <> "."];
  commaOffset = tailStart + position - 1;
  assert[commaOffset > valueStart,
    "the projected S13 value is empty for " <> label <> "."];
  commaOffset
];

finalAssociationValueEndOffset[
    path_String, valueStart_Integer, nextMarkerOffset_Integer,
    label_String
  ] := Module[
  {
    whitespaceBytes = {9, 10, 13, 32}, commaOffset, tailCount,
    tailStart, stream, tailBytes, position, valueEnd
  },
  commaOffset = fieldValueEndOffset[
    path, valueStart, nextMarkerOffset, label
  ];
  tailCount = Min[4096, commaOffset - valueStart];
  tailStart = commaOffset - tailCount;
  stream = Quiet@Check[OpenRead[path, BinaryFormat -> True], $Failed];
  assert[Head[stream] === InputStream,
    "S13 could not be opened for the final " <> label <>
      " association boundary check."];
  SetStreamPosition[stream, tailStart];
  tailBytes = Quiet@Check[
    BinaryReadList[stream, "Byte", tailCount],
    $Failed
  ];
  Close[stream];
  assert[ListQ[tailBytes] && Length[tailBytes] === tailCount,
    "the final projected S13 tail read was incomplete for " <>
      label <> "."];
  position = Length[tailBytes];
  While[
    position >= 1 && MemberQ[whitespaceBytes, tailBytes[[position]]],
    position--
  ];
  assert[
    position >= 2 &&
      tailBytes[[position - 1 ;; position]] === {124, 62},
    "the final projected S13 value is not followed by an association " <>
      "closer for " <> label <> "."
  ];
  valueEnd = tailStart + position - 2;
  assert[valueEnd > valueStart,
    "the final projected S13 value is empty for " <> label <> "."];
  valueEnd
];

writeProjectedActionPayload[
    sourcePath_String, valueStart_Integer, valueEnd_Integer,
    targetPath_String, sourceSHA256_Integer, sourceBytes_Integer,
    structureFunction_String
  ] := Module[
  {
    chunkSize = 1024^2, temporaryPath = targetPath <> ".tmp",
    input, output, header, footer, remaining, take, chunk
  },
  assert[0 <= valueStart < valueEnd <= sourceBytes,
    "the projected action byte range is invalid."];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  If[FileExistsQ[targetPath],
    Print["BIGTMD_CHECK_S01_CLEANUP: deleting stale action projection"];
    DeleteFile[targetPath]
  ];
  header =
    "<|\"CacheVersion\" -> 1, \"StageVersion\" -> \"" <>
      stageVersion <> "\", \"S13SHA256\" -> " <>
      ToString[sourceSHA256, InputForm] <> ", \"S13Bytes\" -> " <>
      ToString[sourceBytes, InputForm] <>
      ", \"StructureFunction\" -> \"" <> structureFunction <>
      "\", \"Action\" -> ";
  footer = "|>";
  input = Quiet@Check[
    OpenRead[sourcePath, BinaryFormat -> True],
    $Failed
  ];
  output = Quiet@Check[
    OpenWrite[temporaryPath, BinaryFormat -> True],
    $Failed
  ];
  assert[Head[input] === InputStream && Head[output] === OutputStream,
    "the projected action streams could not be opened."];
  BinaryWrite[output, ToCharacterCode[header, "UTF8"], "Byte"];
  SetStreamPosition[input, valueStart];
  remaining = valueEnd - valueStart;
  While[remaining > 0,
    take = Min[chunkSize, remaining];
    chunk = Quiet@Check[
      BinaryReadList[input, "Byte", take],
      $Failed
    ];
    assert[ListQ[chunk] && Length[chunk] === take,
      "the streamed S13 action read was incomplete."];
    BinaryWrite[output, chunk, "Byte"];
    remaining -= take;
  ];
  BinaryWrite[output, ToCharacterCode[footer, "UTF8"], "Byte"];
  Close[input];
  Close[output];
  assert[FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    "the projected action temporary file is absent or empty."];
  RenameFile[temporaryPath, targetPath, OverwriteTarget -> True];
  assert[FileExistsQ[targetPath] && FileByteCount[targetPath] > 0,
    "the projected action destination is absent or empty."];
  targetPath
];

loadProjectedAction[
    path_String, range_Association, label_String,
    sourceSHA256_Integer, sourceBytes_Integer
  ] := Module[{payload, action},
  Print[
    "BIGTMD_CHECK_S01_STAGE: streaming " <> label <> " action bytes=" <>
      ToString[range["End"] - range["Start"]]
  ];
  writeProjectedActionPayload[
    path, range["Start"], range["End"], projectionPath,
    sourceSHA256, sourceBytes, label
  ];
  payload = Quiet@Check[Get[projectionPath], $Failed];
  assert[
    AssociationQ[payload] &&
      payload["CacheVersion"] === 1 &&
      payload["StageVersion"] === stageVersion &&
      payload["S13SHA256"] === sourceSHA256 &&
      payload["S13Bytes"] === sourceBytes &&
      payload["StructureFunction"] === label,
    "the projected " <> label <> " action payload is invalid."];
  action = payload["Action"];
  Clear[payload];
  ClearSystemCache[];
  DeleteFile[projectionPath];
  assert[! FileExistsQ[projectionPath],
    "the disposable " <> label <> " action projection was not deleted."];
  Print[
    "BIGTMD_CHECK_S01_CLEANUP: deleted " <> label <> " action projection"
  ];
  action
];

atomicRawJSONExport[data_, path_String] := Module[
  {temporaryPath = path <> ".tmp", exported},
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  exported = Quiet@Check[Export[temporaryPath, data, "RawJSON"], $Failed];
  assert[exported =!= $Failed && FileExistsQ[temporaryPath] &&
      FileByteCount[temporaryPath] > 0,
    "failed to export the compact local benchmark JSON."];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
];

Print["BIGTMD_CHECK_S01_STAGE: bounded validation of Hqg S13"];
assert[FileExistsQ[s13Path] && FileByteCount[s13Path] > 0,
  "s13_result is absent or empty."];
assert[FileExistsQ[referencePgPath] && FileExistsQ[referencePPPPath],
  "the copied BigTMD fchn3A reference modules are absent."];

finiteFunctionsMarker = "\"FiniteHattedStructureFunctions\" ->";
f1Marker = "\"F1Hat\" ->";
f2Marker = "\"F2Hat\" ->";
testFunctionMarker = "\"TestFunction\" ->";
functionChecksMarker = "\"FunctionChecks\" ->";
markerOffsets = findByteMarkerOffsets[
  s13Path,
  {
    finiteFunctionsMarker, f1Marker, f2Marker, testFunctionMarker,
    functionChecksMarker
  }
];
assert[
  Length[markerOffsets[finiteFunctionsMarker]] === 1 &&
    Length[markerOffsets[testFunctionMarker]] === 1 &&
    Length[markerOffsets[functionChecksMarker]] === 1,
  "S13 does not contain unique outer action/check markers."];
finiteFunctionsOffset = First[markerOffsets[finiteFunctionsMarker]];
testFunctionOffset = First[markerOffsets[testFunctionMarker]];
functionChecksOffset = First[markerOffsets[functionChecksMarker]];
f1Candidates = Select[
  markerOffsets[f1Marker],
  finiteFunctionsOffset < # < functionChecksOffset &
];
f2Candidates = Select[
  markerOffsets[f2Marker],
  finiteFunctionsOffset < # < functionChecksOffset &
];
assert[Length[f1Candidates] === 1 && Length[f2Candidates] === 1,
  "S13 does not contain unique F1Hat/F2Hat action markers."];
f1Offset = First[f1Candidates];
f2Offset = First[f2Candidates];
s13ByteCount = FileByteCount[s13Path];
s13SHA256 = FileHash[s13Path, "SHA256"];
assert[
  0 < finiteFunctionsOffset < f1Offset < f2Offset <
    testFunctionOffset < functionChecksOffset < s13ByteCount,
  "the S13 action markers are out of order."];

metadataPrefixText = dropTrailingFieldSeparator[
  readUTF8ByteRange[
    s13Path, 0, finiteFunctionsOffset, "metadata prefix"
  ],
  "metadata prefix"
];
metadataPrefix = parseProjectedText[
  metadataPrefixText <> "|>",
  "metadata prefix"
];
checksTailText = readUTF8ByteRange[
  s13Path,
  functionChecksOffset,
  s13ByteCount - functionChecksOffset,
  "function/check tail"
];
metadataTail = parseProjectedText[
  "<|" <> checksTailText,
  "function/check tail"
];
s13Metadata = Join[metadataPrefix, metadataTail];
Clear[metadataPrefixText, checksTailText, metadataPrefix, metadataTail];

assert[
  AssociationQ[s13Metadata] &&
    s13Metadata["Status"] ===
      "CompleteFinitePartonicStructureFunctionsHqg" &&
    s13Metadata["StageVersion"] === "HqgS13-v1" &&
    s13Metadata["Channel"] === "Hqg only",
  "s13_result is incomplete or is not HqgS13-v1."];
assert[
  AssociationQ[s13Metadata["Checks"]] &&
    AllTrue[Values[s13Metadata["Checks"]], TrueQ] &&
    AssociationQ[s13Metadata["FunctionChecks"]] &&
    AllTrue[
      Flatten[Values /@ Values[s13Metadata["FunctionChecks"]]],
      TrueQ
    ],
  "s13_result contains a failed validation check."];
assert[
  FileExistsQ[s13Metadata["Program"]] &&
    FileHash[s13Metadata["Program"], "SHA256"] ===
      s13Metadata["ProgramSHA256"] &&
    FileExistsQ[s13Metadata["SourceResult"]] &&
    FileHash[s13Metadata["SourceResult"], "SHA256"] ===
      s13Metadata["SourceResultSHA256"] &&
    FileExistsQ[s13Metadata["AuthoritativePaper"]] &&
    FileHash[s13Metadata["AuthoritativePaper"], "SHA256"] ===
      s13Metadata["AuthoritativePaperSHA256"],
  "s13_result provenance hashes do not match current artifacts."];

bigTMDConvention = s13Metadata["BigTMDConvention"];
assert[
  AssociationQ[bigTMDConvention] &&
    bigTMDConvention["ChannelNumber"] === 3 &&
    bigTMDConvention["ChargeCase"] === "A only" &&
    bigTMDConvention["FragmentingParton"] === "gluon g(k1)" &&
    FileHash[referencePgPath, "SHA256"] ===
      bigTMDConvention["ReferenceSHA256", "Pg"] &&
    FileHash[referencePPPPath, "SHA256"] ===
      bigTMDConvention["ReferenceSHA256", "PPP"] &&
    s13Metadata["PhysicalLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g",
  "the Hqg channel-3A or deferred-luminosity binding is invalid."];

xHatExpression = s13Metadata["XHat"];
intervalExpression = s13Metadata["IntegrationInterval"];
assert[MatchQ[intervalExpression, {s23, 0, _}],
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

f1Start = f1Offset + Length[ToCharacterCode[f1Marker, "UTF8"]];
f2Start = f2Offset + Length[ToCharacterCode[f2Marker, "UTF8"]];
actionRanges = <|
  "F1Hat" -> <|
    "Start" -> f1Start,
    "End" -> fieldValueEndOffset[
      s13Path, f1Start, f2Offset, "F1Hat"
    ]
  |>,
  "F2Hat" -> <|
    "Start" -> f2Start,
    "End" -> finalAssociationValueEndOffset[
      s13Path, f2Start, testFunctionOffset, "F2Hat"
    ]
  |>
|>;
assert[
  actionRanges["F1Hat", "Start"] < actionRanges["F1Hat", "End"] <
    actionRanges["F2Hat", "Start"] < actionRanges["F2Hat", "End"],
  "the projected S13 action ranges are invalid."];

Clear[s13Metadata];
ClearSystemCache[];

fieldS23Values = <|
  "Endpoint" -> endpointRegulator,
  "IntegrandPhiS" -> s23SampleValue,
  "IntegrandPhi0" -> s23SampleValue
|>;
localValues = <||>;

Do[
  Print["BIGTMD_CHECK_S01_FHAT: importing " <> structureFunction];
  action = loadProjectedAction[
    s13Path, actionRanges[structureFunction], structureFunction,
    s13SHA256, s13ByteCount
  ];
  assert[
    FreeQ[action, epsilon | _SeriesData | _Real] &&
      feynCalcContextCleanQ[action],
    structureFunction <> " is not exact/context-clean."];
  pair = actionToPair[action, structureFunction, intervalExpression];
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
  ClearSystemCache[];,
  {structureFunction, structureFunctions}
];

assert[! FileExistsQ[projectionPath] &&
    ! FileExistsQ[projectionPath <> ".tmp"],
  "a disposable action projection remains after evaluation."];

payload = <|
  "Status" -> "CompleteLocalFHatBenchmark",
  "StageVersion" -> stageVersion,
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Source" -> <|
    "Path" -> s13Path,
    "ByteCount" -> s13ByteCount,
    "SHA256" -> IntegerString[s13SHA256, 16, 64],
    "Status" -> "CompleteFinitePartonicStructureFunctionsHqg",
    "StageVersion" -> "HqgS13-v1",
    "Channel" -> "Hqg only"
  |>,
  "Construction" -> <|
    "Method" ->
      "one-action-at-a-time projected import from S13 saved F hats",
    "Epsilon" -> 0,
    "ActionCoefficients" -> fields,
    "ProjectedActionBytes" -> AssociationMap[
      actionRanges[#, "End"] - actionRanges[#, "Start"] &,
      structureFunctions
    ],
    "DisposableProjectionsDeleted" -> True,
    "ReferenceDistributionContent" ->
      "regular, delta, plus1B, and plus2B"
  |>,
  "ComparisonLevel" ->
    "finite unit-charge Hqg coefficient action before PDFs, gluon FF, physical charge sum, and xi convolution",
  "Conventions" -> <|
    "Couplings" ->
      "EL=1 and g_s=1; upstream direct Born factor 9 stripped the generated down-quark charge",
    "Color" -> "SU(3): CA=3, CF=4/3, TF=1/2",
    "FlavorCount" -> benchmark["Nf"],
    "DirectBornNormalizationFactor" -> 9,
    "PhysicalLuminosity" -> "Sum_q e_q^2 f_q D_g deferred",
    "BigTMDChannel" -> 3,
    "BigTMDChargeCases" -> {"A"},
    "BigTMDPartonicModuleWeight" -> 1,
    "BigTMDDistributionContent" ->
      "regular, delta, plus1B, and plus2B",
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

Print["BIGTMD_CHECK_S01_STAGE: writing compact Hqg local benchmark"];
atomicRawJSONExport[payload, outputPath];
Print["BIGTMD_CHECK_S01_SUCCESS"];
Print["BIGTMD_CHECK_S01_OUTPUT=" <> outputPath];
Print["BIGTMD_CHECK_S01_OUTPUT_BYTES=", FileByteCount[outputPath]];

Quit[0];

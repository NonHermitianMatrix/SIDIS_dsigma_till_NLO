checkDirectory = DirectoryName[$InputFileName];
resultPath = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];

result = Quiet[Check[Get[resultPath], $Failed]];
If[! AssociationQ[result],
  Print["S06_FATAL: copied s07_result did not load as an Association"];
  Exit[1]
];

projections = Quiet[Check[
  result["ScalarProjections"]["NLOReal_OAlphaS2"]["Hqqbar;q_q"],
  $Failed
]];
If[! AssociationQ[projections] || Keys[projections] =!= {"Pg", "PPP"},
  Print["S06_FATAL: copied s07_result has the wrong projection schema"];
  Exit[1]
];

nonSystemSymbolNames[expression_] := Sort @ DeleteDuplicates @ Cases[
  Unevaluated[expression],
  symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`" :>
    Context[Unevaluated[symbol]] <> SymbolName[Unevaluated[symbol]],
  Infinity,
  Heads -> True
];

scalePowers[expression_] := DeleteDuplicates @ Cases[
  Unevaluated[expression],
  HoldPattern[Power[Global`ScaleMu, power_]] :> HoldForm[power],
  Infinity
];

inertDenominators[expression_] := DeleteDuplicates @ Cases[
  Unevaluated[expression],
  denominator_Global`FeynAmpDenominator :> HoldForm[denominator],
  Infinity
];

inertCouplings[expression_] := DeleteDuplicates @ Join[
  Cases[
    Unevaluated[expression],
    coupling_Global`SMP :> HoldForm[coupling],
    Infinity
  ],
  Cases[
    Unevaluated[expression],
    coupling_Global`FCGV :> HoldForm[coupling],
    Infinity
  ]
];

Print["S06_STAGE: copied S07 compact schema"];
Print["S06_RESULT_STAGE=", Lookup[result, "Stage", Missing["Stage"]]];
Print["S06_RESULT_CHANNEL=", Lookup[result, "Channel", Missing["Channel"]]];
Print["S06_PROJECTION_KEYS=", InputForm[Keys[projections]]];

KeyValueMap[
  Function[{name, expression},
    Print["S06_", name, "_HEAD=", Head[expression]];
    Print["S06_", name, "_LEAF_COUNT=", LeafCount[expression]];
    Print[
      "S06_", name, "_FAD_COUNT=",
      Count[Unevaluated[expression], _Global`FeynAmpDenominator, Infinity]
    ];
    Print[
      "S06_", name, "_PROPAGATOR_DENOMINATOR_COUNT=",
      Count[Unevaluated[expression], _Global`PropagatorDenominator, Infinity]
    ];
    Print[
      "S06_", name, "_UNIQUE_INERT_DENOMINATORS=",
      InputForm[inertDenominators[expression]]
    ];
    Print[
      "S06_", name, "_UNIQUE_INERT_COUPLINGS=",
      InputForm[inertCouplings[expression]]
    ];
    Print[
      "S06_", name, "_SCALE_POWERS=",
      InputForm[scalePowers[expression]]
    ];
    Print[
      "S06_", name, "_NON_SYSTEM_SYMBOLS=",
      InputForm[nonSystemSymbolNames[expression]]
    ];
    Print[
      "S06_", name, "_MACHINE_REAL_FREE=",
      FreeQ[Unevaluated[expression], _Real]
    ];
  ],
  projections
];

Print["S06_SUCCESS"];
Exit[0];

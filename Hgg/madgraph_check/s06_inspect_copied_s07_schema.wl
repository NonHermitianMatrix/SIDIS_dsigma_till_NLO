checkDirectory = DirectoryName[$InputFileName];
resultPath = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];

expectedProjectorKeys = {"Pg", "PPP"};

result = Quiet[Check[Get[resultPath], $Failed]];
If[
  ! AssociationQ[result] ||
    Lookup[result, "Status", Missing["Status"]] =!= "Complete" ||
    Lookup[result, "Channel", Missing["Channel"]] =!= "Hgg only",
  Print["S06_FATAL: copied s07_result has the wrong result identity"];
  Exit[1]
];

projections = Quiet[Check[
  result[
    "ScalarProjections",
    "NLOReal_OAlphaS2",
    "Hgg;q_qbar"
  ],
  $Failed
]];
If[
  ! AssociationQ[projections] ||
    Keys[projections] =!= expectedProjectorKeys,
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

Print["S06_STAGE: copied Hgg S07 compact schema"];
Print["S06_RESULT_STAGE=", Lookup[result, "Stage", Missing["Stage"]]];
Print["S06_RESULT_CHANNEL=", Lookup[result, "Channel", Missing["Channel"]]];
Print["S06_PROJECTOR_KEYS=", InputForm[Keys[projections]]];

KeyValueMap[
  Function[{projectorName, expression},
        label = projectorName;
        Print["S06_", label, "_HEAD=", Head[expression]];
        Print["S06_", label, "_LEAF_COUNT=", LeafCount[expression]];
        Print[
          "S06_", label, "_FAD_COUNT=",
          Count[Unevaluated[expression], _Global`FeynAmpDenominator, Infinity]
        ];
        Print[
          "S06_", label, "_PROPAGATOR_DENOMINATOR_COUNT=",
          Count[
            Unevaluated[expression],
            _Global`PropagatorDenominator,
            Infinity
          ]
        ];
        Print[
          "S06_", label, "_UNIQUE_INERT_DENOMINATORS=",
          InputForm[inertDenominators[expression]]
        ];
        Print[
          "S06_", label, "_UNIQUE_INERT_COUPLINGS=",
          InputForm[inertCouplings[expression]]
        ];
        Print[
          "S06_", label, "_SCALE_POWERS=",
          InputForm[scalePowers[expression]]
        ];
        Print[
          "S06_", label, "_NON_SYSTEM_SYMBOLS=",
          InputForm[nonSystemSymbolNames[expression]]
        ];
        Print[
          "S06_", label, "_MACHINE_REAL_FREE=",
          FreeQ[Unevaluated[expression], _Real]
        ];
  ],
  projections
];

Print["S06_SUCCESS"];
Exit[0];

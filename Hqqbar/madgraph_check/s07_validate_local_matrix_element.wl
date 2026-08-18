$HistoryLength = 0;

ClearAll[assert, minkowskiDot, invariantSquare];

assert[condition_, message_String] := If[
  ! TrueQ[condition],
  Print["S07_FATAL: " <> message];
  Exit[1]
];

checkDirectory = DirectoryName[ExpandFileName[$InputFileName]];
copiedResultPath = FileNameJoin[{checkDirectory, "upstream_copies", "s07_result"}];
madGraphValidationPath = FileNameJoin[{checkDirectory, "s05_bridge_validation.json"}];
outputPath = FileNameJoin[{checkDirectory, "s07_projected_local_point.json"}];

expectedCopiedResultHash =
  "a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50";
assert[
  IntegerString[FileHash[copiedResultPath, "SHA256"], 16, 64] ===
    expectedCopiedResultHash,
  "the copied S07 result hash is not the accepted hash"
];
assert[! FileExistsQ[outputPath], "the S07 validation output already exists"];

result = Quiet[Check[Get[copiedResultPath], $Failed]];
assert[AssociationQ[result], "the copied S07 result did not load"];
projections = Quiet[Check[
  result["ScalarProjections"]["NLOReal_OAlphaS2"]["Hqqbar;q_q"],
  $Failed
]];
assert[
  AssociationQ[projections] && Keys[projections] === {"Pg", "PPP"},
  "the copied S07 projection schema is invalid"
];

(* Every inert massless propagator is 1/r^2.  The mappings below follow
   the accepted S07 momentum labels and its exact conservation identities. *)
sHatSymbolic = Global`s12 + Global`s13 + Global`s23;
t1Symbolic = Global`s23 - sHatSymbolic - q2Symbolic - Global`u1;
t2Symbolic = Global`s13 - sHatSymbolic - q2Symbolic - Global`u2;
t3Symbolic = Global`s12 - sHatSymbolic - q2Symbolic - Global`u3;

denominatorRules = {
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k3, D], 0]
    ]
  ] :> 1/Global`s13,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k2 + Global`k3, D], 0]
    ]
  ] :> 1/sHatSymbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k2 - Global`p, D], 0]
    ]
  ] :> 1/Global`u2,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k2 - Global`p, D], 0]
    ]
  ] :> 1/t3Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k3, D], 0]
    ]
  ] :> 1/Global`s13,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/t2Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k2 + Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/t1Symbolic,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k1 + Global`k2, D], 0]
    ]
  ] :> 1/Global`s12,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[Global`Momentum[Global`k1 + Global`k2, D], 0]
    ]
  ] :> 1/Global`s12,
  HoldPattern[
    Global`FeynAmpDenominator[
      Global`PropagatorDenominator[-Global`Momentum[Global`k3 - Global`p, D], 0]
    ]
  ] :> 1/Global`u3
};

alphaS = 59/500;
alphaEMInverse = 132507/1000;
electricCoupling = Sqrt[4 Pi/alphaEMInverse];
strongCoupling = Sqrt[4 Pi alphaS];

fourDimensionalRules = {
  D -> 4,
  Global`epsilon -> 0,
  Global`ScaleMu -> 1,
  Global`CA -> 3,
  Global`CF -> 4/3,
  Global`SUNN -> 3,
  Global`SMP["g_s"] -> strongCoupling,
  Global`FCGV["EL"] -> electricCoupling
};

fourDimensionalProjections = AssociationMap[
  Function[expression, expression /. denominatorRules /. fourDimensionalRules],
  projections
];
assert[
  And @@ (
    FreeQ[#, _Global`FeynAmpDenominator | _Global`PropagatorDenominator |
      _Global`Momentum | _Global`SMP | _Global`FCGV | Global`epsilon |
      Global`ScaleMu | Global`CA | Global`CF | Global`SUNN | D] & /@
      Values[fourDimensionalProjections]
  ),
  "an inert denominator, coupling, dimensional, scale, or color object remains"
];

minkowskiDot[a_List, b_List] :=
  a[[1]] b[[1]] - Sum[a[[index]] b[[index]], {index, 2, 4}];
invariantSquare[a_List] := minkowskiDot[a, a];

rootThree = Sqrt[3];
outgoingEnergy = 250;
incomingElectron = {500, 0, 0, 500};
incomingQuark = {500, 0, 0, -500};
outgoingElectron = outgoingEnergy {1, 1/rootThree, 1/rootThree, 1/rootThree};
outgoingU2 = outgoingEnergy {1, 1/rootThree, -1/rootThree, -1/rootThree};
outgoingU3 = outgoingEnergy {1, -1/rootThree, 1/rootThree, -1/rootThree};
outgoingAntiquark = outgoingEnergy {1, -1/rootThree, -1/rootThree, 1/rootThree};

photonMomentum = incomingElectron - outgoingElectron;
q2Value = -invariantSquare[photonMomentum];
sHatValue = invariantSquare[incomingQuark + photonMomentum];
s12Value = invariantSquare[outgoingAntiquark + outgoingU2];
s13Value = invariantSquare[outgoingAntiquark + outgoingU3];
s23Value = invariantSquare[outgoingU2 + outgoingU3];
u1Value = invariantSquare[incomingQuark - outgoingAntiquark];
u2Value = invariantSquare[incomingQuark - outgoingU2];
u3Value = invariantSquare[incomingQuark - outgoingU3];

assert[
  sHatValue === s12Value + s13Value + s23Value,
  "the fixed point violates the three-body invariant sum"
];
assert[
  q2Value > 0 && And @@ Thread[{s12Value, s13Value, s23Value} > 0] &&
    And @@ Thread[{u1Value, u2Value, u3Value} < 0],
  "the fixed point is outside the required physical region"
];

kinematicRules = {
  q2Symbolic -> q2Value,
  Global`s12 -> s12Value,
  Global`s13 -> s13Value,
  Global`s23 -> s23Value,
  Global`u1 -> u1Value,
  Global`u2 -> u2Value,
  Global`u3 -> u3Value
};

pgEvaluated = fourDimensionalProjections["Pg"] /. kinematicRules;
pppEvaluated = fourDimensionalProjections["PPP"] /. kinematicRules;
remainingSymbolNames[expression_] := Sort @ DeleteDuplicates @ Cases[
  Unevaluated[expression],
  symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`" :>
    Context[Unevaluated[symbol]] <> SymbolName[Unevaluated[symbol]],
  Infinity,
  Heads -> True
];
allSymbolNames[expression_] := Sort @ DeleteDuplicates @ Cases[
  Unevaluated[expression],
  symbol_Symbol :> Context[Unevaluated[symbol]] <> SymbolName[Unevaluated[symbol]],
  Infinity,
  Heads -> True
];
If[! NumericQ[pgEvaluated] || ! NumericQ[pppEvaluated],
  Print["S07_DIAGNOSTIC_PG_HEAD=", Head[pgEvaluated]];
  Print["S07_DIAGNOSTIC_PG_LEAF_COUNT=", LeafCount[pgEvaluated]];
  Print[
    "S07_DIAGNOSTIC_PG_REMAINING_SYMBOLS=",
    InputForm[remainingSymbolNames[pgEvaluated]]
  ];
  Print[
    "S07_DIAGNOSTIC_PG_ALL_SYMBOLS=",
    InputForm[allSymbolNames[pgEvaluated]]
  ];
  Print[
    "S07_DIAGNOSTIC_PG_NONFINITE=",
    ! FreeQ[pgEvaluated, Indeterminate | ComplexInfinity | DirectedInfinity[_]]
  ];
  Print["S07_DIAGNOSTIC_PPP_HEAD=", Head[pppEvaluated]];
  Print["S07_DIAGNOSTIC_PPP_LEAF_COUNT=", LeafCount[pppEvaluated]];
  Print[
    "S07_DIAGNOSTIC_PPP_REMAINING_SYMBOLS=",
    InputForm[remainingSymbolNames[pppEvaluated]]
  ];
  Print[
    "S07_DIAGNOSTIC_PPP_ALL_SYMBOLS=",
    InputForm[allSymbolNames[pppEvaluated]]
  ];
  Print[
    "S07_DIAGNOSTIC_PPP_NONFINITE=",
    ! FreeQ[pppEvaluated, Indeterminate | ComplexInfinity | DirectedInfinity[_]]
  ];
];
pgValue = N[pgEvaluated, 40];
pppValue = N[pppEvaluated, 40];
assert[NumberQ[pgValue] && NumberQ[pppValue], "a projection did not become numeric"];

xHatValue = q2Value/(sHatValue + q2Value);
f1Value = -pgValue/2 + 2 xHatValue^2 pppValue/q2Value;
f2Value = -xHatValue pgValue + 12 xHatValue^3 pppValue/q2Value;

leptonicPPP = 4 minkowskiDot[incomingElectron, incomingQuark] *
  minkowskiDot[outgoingElectron, incomingQuark];
hadronicLeptonicContraction =
  2 q2Value f1Value + leptonicPPP/minkowskiDot[incomingQuark, photonMomentum] f2Value;

upChargeSquared = 4/9;
identicalFinalUFactor = 1/2;
localMatrixElement = N[
  identicalFinalUFactor upChargeSquared electricCoupling^2 *
    hadronicLeptonicContraction/q2Value^2,
  30
];

madGraphValidation = Quiet[Check[Import[madGraphValidationPath, "RawJSON"], $Failed]];
assert[AssociationQ[madGraphValidation], "the accepted MadGraph validation JSON did not load"];
madGraphMatrixElement = madGraphValidation["bridge_matrix_element"];
relativeDifference = N[
  Abs[localMatrixElement - madGraphMatrixElement]/
    Max[Abs[localMatrixElement], Abs[madGraphMatrixElement]],
  20
];

Print["S07_STAGE: convention-complete local matrix reconstruction"];
Print["S07_Q2=", N[q2Value, 20]];
Print["S07_SHAT=", N[sHatValue, 20]];
Print["S07_PG=", pgValue];
Print["S07_PPP=", pppValue];
Print["S07_F1=", f1Value];
Print["S07_F2=", f2Value];
Print["S07_LOCAL_MATRIX=", localMatrixElement];
Print["S07_MADGRAPH_MATRIX=", madGraphMatrixElement];
Print["S07_RELATIVE_DIFFERENCE=", relativeDifference];

output = <|
  "stage" -> "HqqbarProjectedLocalPoint-v1",
  "status" -> "complete",
  "copied_s07_result_sha256" -> expectedCopiedResultHash,
  "alpha_s" -> N[alphaS, 17],
  "alpha_em_inverse" -> N[alphaEMInverse, 17],
  "q2" -> N[q2Value, 17],
  "s_hat" -> N[sHatValue, 17],
  "pg" -> N[pgValue, 17],
  "ppp" -> N[pppValue, 17],
  "f1" -> N[f1Value, 17],
  "f2" -> N[f2Value, 17],
  "local_matrix_element" -> N[localMatrixElement, 17],
  "single_orientation_madgraph_matrix_element" -> madGraphMatrixElement,
  "single_orientation_relative_difference_not_an_acceptance_test" ->
    N[relativeDifference, 17],
  "comparison_scope" ->
    "S07 Pg/PPP reconstruct the paper's azimuth-independent F1/F2 terms; a fixed MadGraph orientation also contains omitted azimuthal tensors. S08 must compare an azimuthal average at these fixed invariants.",
  "normalization" -> <|
    "incoming_quark_spin_color_average" -> "already present in copied S07",
    "incoming_electron_spin_average" -> "included in L_munu",
    "physical_up_charge_squared" -> "4/9",
    "identical_final_u_factor" -> "1/2",
    "electron_photon_vertex_and_propagator" -> "e^2/Q^4"
  |>
|>;
Export[outputPath, output, "RawJSON"];
assert[FileExistsQ[outputPath] && FileByteCount[outputPath] > 0, "validation JSON write failed"];

Print["S07_SUCCESS_PROJECTED_LOCAL"];
Exit[0];

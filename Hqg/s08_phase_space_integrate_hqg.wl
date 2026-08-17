(* ::Package:: *)

(*
  Hqg stage S08: apply the paper's fixed-observed-k1 phase-space operations
  to the six validated S07 scalar projections.

    1. Apply the two-body k2 phase space to LO and renormalized virtual
       Pg/PPP projections, writing the constraint as DiracDelta[s23].
       Expand propagators only for LO; preserve the validated symbolic
       virtual projections to avoid expanding on-shell counterterm placeholders.
    2. Integrate the sole real Hqg;qg Pg/PPP pair over the unobserved
       q(k2),g(k3) angles in D=4-2 epsilon using Appendices B and D.
    3. Apply Eqs. (29)-(32), replacing zeta by s23 with the exact Jacobian
       and physical xi/s23 limits.
    4. Prove the resulting zHat, Jacobian, s, t, and endpoint B maps are
       exactly the maps used by BigTMD channel 3A after PHT2=zH^2 qT^2.

  Endpoint distributions, Appendix-F expansions, real-virtual cancellation,
  Eq. (46) collinear factorization, and finite fchn3A comparison are deferred.
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, splitTerms, setTwoBodyKinematics,
  setThreeBodyKinematics, validateScalarInput, makeTwoBodyPair,
  makeRealExplicit, laurentPower, denominatorADMVs, presentADMVs,
  typeOfADMV, sameTypeOffender, reduceSameTypeTerms, affineVector,
  tripleUnityRelation, reduceTripleTerms, chooseBasis, basisRules,
  reduceNumerators, reduceAppendixD, linearCoefficients,
  reducedLinearCoefficients, coefficientDot, masslessGeometry,
  case2Geometry, appendixB18, angularKeyAndCoefficient, masterFromKey,
  integrateReducedTerms, validateAngularExpression, loadValidatedCache,
  writeValidatedCache, processRealProjection, validateProjectionPair,
  validateTwoBodyPair, transformPair, validateXiS23Pair,
  zeroCoefficientVectorQ, S08Case2Master
];

fatal[message_String] := (
  Print["S08_FATAL: " <> message];
  Quit[1]
);

assert[condition_, message_String] :=
  If[! TrueQ[condition], fatal[message]];

splitTerms[expression_] :=
  If[Head[expression] === Plus, List @@ expression, {expression}];

scriptDirectory = DirectoryName[ExpandFileName[$InputFileName]];
programPath = ExpandFileName[$InputFileName];
programSHA256 = FileHash[programPath, "SHA256"];
s07Path = FileNameJoin[{scriptDirectory, "s07_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
stageVersion = "HqgS08-v4";

cachePaths = <|
  "Pg" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_g"}],
  "PPP" -> FileNameJoin[{scriptDirectory, "s08_cache_hqg_real_qg_pp"}]
|>;

Print["S08_STAGE: loading validated Hqg s07_result"];
assert[FileExistsQ[s07Path], "s07_result does not exist."];
s07 = Check[Get[s07Path], $Failed];
assert[AssociationQ[s07], "s07_result did not load as an Association."];
assert[
  s07["Status"] === "Complete" &&
    s07["Stage"] === "HqgS07-v3" &&
    s07["Channel"] === "Hqg only",
  "s07_result is not the complete Hqg S07 result."
];
assert[
  s07["ProjectionCount"] === 6 &&
    AllTrue[Values[s07["Checks"]], TrueQ],
  "S07 projection count or validation checks are invalid."
];
assert[
  FileExistsQ[s07["SourceResult"]] &&
    s07["SourceResultSHA256"] ===
      FileHash[s07["SourceResult"], "SHA256"],
  "The S07 source-result binding is stale."
];
assert[
  FileExistsQ[s07["Program"]] &&
    s07["ProgramSHA256"] === FileHash[s07["Program"], "SHA256"],
  "The S07 program binding is stale."
];
assert[
  IntegerQ[s07["ReferencePDFSHA256"]],
  "S07 has no exact reference-paper hash."
];
assert[
  s07["BigTMDConvention", "ChannelNumber"] === 3 &&
    s07["BigTMDConvention", "ChargeCase"] === "A only" &&
    s07["BigTMDProjectorMapping", "Pg"] === "NLO.Pg.fchn3A" &&
    s07["BigTMDProjectorMapping", "PPP"] === "NLO.Ppp.fchn3A",
  "S07 is not bound to the two BigTMD Hqg channel-3A projector families."
];
assert[
  s07["ElectricChargeNormalization", "ReferenceCharge"] === -1/3 &&
    s07["ElectricChargeNormalization", "AmplitudeStripFactor"] === -3 &&
    s07["ElectricChargeNormalization", "BigTMDLuminosityAppliedDownstream"] ===
      "Sum_q e_q^2 f_q D_g",
  "S07 is not in the corrected charge-stripped hard-kernel convention."
];
assert[
  s07["FragmentingParton"] === "gluon g(k1)",
  "S07 does not preserve the fragmenting-gluon g(k1) convention."
];

s07SHA256 = FileHash[s07Path, "SHA256"];

loInput = s07["ScalarProjections", "LO_OAlphaS"];
realQGInput = s07[
  "ScalarProjections", "NLOReal_OAlphaS2", "Hqg;qg"
];
virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];

validateScalarInput[pair_Association, label_String] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain exactly Pg and PPP."
  ];
  assert[
    And @@ Map[
      Function[expression, expression =!= $Failed && expression =!= 0],
      Values[pair]
    ],
    label <> " contains a failed or zero projection."
  ];
  assert[
    And @@ (FreeQ[
        #,
        _FeynCalc`LorentzIndex | FeynCalc`Contract |
          _FeynCalc`Spinor | _FeynCalc`Polarization |
          _FeynCalc`DiracGamma | _FeynCalc`DiracTrace |
          _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
          FeynCalc`ComplexConjugate | FeynCalc`TID | $Failed | _Real
      ] & /@ Values[pair]),
    label <> " is not a complete exact scalar pair."
  ];
  True
];

assert[validateScalarInput[loInput, "Hqg LO input"],
  "LO input validation failed."];
assert[validateScalarInput[realQGInput, "Hqg;qg real input"],
  "real input validation failed."];
assert[validateScalarInput[virtualInput, "Hqg virtual input"],
  "virtual input validation failed."];
assert[
  And @@ (! FreeQ[#, dZq1] & /@ Values[virtualInput]) &&
    And @@ (! FreeQ[#, dZGG1] & /@ Values[virtualInput]) &&
    And @@ (! FreeQ[#, dZgs1] & /@ Values[virtualInput]),
  "At least one virtual input projection lacks symbolic QCD counterterms."
];

setTwoBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[k1, k2] = sHat/2;
  FeynCalc`SPD[q, k1] = (-Q2 - tHat)/2;
  FeynCalc`SPD[q, k2] = (sHat + tHat)/2;
  FeynCalc`SPD[p, k1] = (Q2 + sHat + tHat)/2;
  FeynCalc`SPD[p, k2] = -tHat/2;
);

setThreeBodyKinematics[] := (
  FeynCalc`FCClearScalarProducts[];
  FeynCalc`SPD[p, p] = 0;
  FeynCalc`SPD[q, q] = -Q2;
  FeynCalc`SPD[k1, k1] = 0;
  FeynCalc`SPD[k2, k2] = 0;
  FeynCalc`SPD[k3, k3] = 0;
  FeynCalc`SPD[p, q] = (sHat + Q2)/2;
  FeynCalc`SPD[q, k1] = (-Q2 - t1)/2;
  FeynCalc`SPD[q, k2] = (-Q2 - t2)/2;
  FeynCalc`SPD[q, k3] = (-Q2 - t3)/2;
  FeynCalc`SPD[p, k1] = -u1/2;
  FeynCalc`SPD[p, k2] = -u2/2;
  FeynCalc`SPD[p, k3] = -u3/2;
  FeynCalc`SPD[k1, k2] = s12/2;
  FeynCalc`SPD[k1, k3] = s13/2;
  FeynCalc`SPD[k2, k3] = s23/2;
);

(* Eq. (34), including the common 1/(2 Pi)^4 from Eq. (19). *)
twoBodyPhaseFactor = (2 Pi)/(2 Pi)^4 DiracDelta[s23];

makeTwoBodyPair[
    input_Association, label_String, expandPropagatorsQ_
  ] := Module[{answer},
  Print["S08_STAGE: applying two-body phase space to " <> label];
  If[TrueQ[expandPropagatorsQ], setTwoBodyKinematics[]];
  answer = Map[
    Function[projection,
      twoBodyPhaseFactor *
        ((If[
            TrueQ[expandPropagatorsQ],
            FeynCalc`FeynAmpDenominatorExplicit[projection],
            projection
          ]) /. D -> 4 - 2 epsilon)
    ],
    input
  ];
  answer
];

validateTwoBodyPair[
    pair_Association, label_String, requireExplicitQ_
  ] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain exactly Pg and PPP."
  ];
  assert[
    And @@ Map[
      Function[expression, expression =!= $Failed && expression =!= 0],
      Values[pair]
    ],
    label <> " contains a failed or zero expression."
  ];
  assert[
    And @@ (! FreeQ[#, DiracDelta[s23]] & /@ Values[pair]),
    label <> " is missing DiracDelta[s23]."
  ];
  assert[
    And @@ (FreeQ[
        #,
        D | Indeterminate | ComplexInfinity | _DirectedInfinity | _Real
      ] & /@ Values[pair]),
    label <> " contains D, an infinity, or a machine real."
  ];
  If[TrueQ[requireExplicitQ],
    assert[
      And @@ (FreeQ[
          #,
          _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
        ] & /@ Values[pair]),
      label <> " still contains a propagator or momentum object."
    ]
  ];
  True
];

(* Exact propagator identities following from momentum conservation. *)
propagatorInvariantRules = {
  s12 + s13 + s23 -> sHat,
  s23 + u2 + u3 -> t1,
  s12 + u1 + u2 -> t3,
  s13 + u1 + u3 -> t2
};

makeRealExplicit[projection_] := Module[{answer},
  setThreeBodyKinematics[];
  answer = FeynCalc`FeynAmpDenominatorExplicit[projection];
  (*
    The physical axial projectors in S06 introduce intermediate reference-
    vector terms.  Combine the exact invariant expression before Appendix-D
    expansion so gauge-reference numerator/denominator cancellations occur
    before angular master powers are classified.
  *)
  answer = Together[
    answer /. propagatorInvariantRules /. D -> 4 - 2 epsilon
  ];
  Expand[answer]
];

admv = {t2, t3, u2, u3, s12, s13};
sameTypeData = {
  {{t2, t3}, u1 - s23 - Q2},
  {{u2, u3}, t1 - s23},
  {{s12, s13}, sHat - s23}
};

appendixDRelations = {
  t2 + t3 == u1 - s23 - Q2,
  u2 + u3 == t1 - s23,
  s12 + s13 == sHat - s23,
  s13 == sHat + Q2 + t2 + u2
};

laurentPower[term_, variable_] := Module[{factors},
  factors = If[Head[term] === Times, List @@ term, {term}];
  Total@Map[
    Function[factor,
      Which[
        factor === variable, 1,
        Head[factor] === Power && First[factor] === variable &&
          IntegerQ[Last[factor]], Last[factor],
        True, 0
      ]
    ],
    factors
  ]
];

denominatorADMVs[term_] :=
  Select[admv, laurentPower[term, #] < 0 &];

presentADMVs[term_] :=
  Select[admv, laurentPower[term, #] =!= 0 &];

typeOfADMV[variable_] := Which[
  MemberQ[{t2, t3}, variable], "t",
  MemberQ[{u2, u3}, variable], "u",
  MemberQ[{s12, s13}, variable], "s",
  True, "none"
];

sameTypeOffender[term_] := SelectFirst[
  sameTypeData,
  Function[data, And @@ (laurentPower[term, #] < 0 & /@ First[data])],
  Missing["NotFound"]
];

reduceSameTypeTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, offender},
  While[
    changed = AnyTrue[terms, ! MissingQ[sameTypeOffender[#]] &];
    changed,
    iteration++;
    assert[
      iteration <= 12,
      "Appendix D same-type reduction exceeded 12 iterations."
    ];
    terms = Flatten[
      Map[
        Function[term,
          offender = sameTypeOffender[term];
          If[
            MissingQ[offender],
            {term},
            splitTerms@Expand[term Total[First[offender]]/Last[offender]]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

affineVector[variable_] := Switch[variable,
  t2, {1, 0, 0},
  t3, {-1, 0, u1 - s23 - Q2},
  u2, {0, 1, 0},
  u3, {0, -1, t1 - s23},
  s13, {1, 1, sHat + Q2},
  s12, {-1, -1, -s23 - Q2},
  _, fatal["Unknown ADMV in affineVector."]
];

tripleUnityRelation[variables_List] := Module[
  {vectors, nullVector, constant, lhs},
  assert[
    Length[variables] === 3,
    "A three-variable Appendix D relation was requested incorrectly."
  ];
  vectors = affineVector /@ variables;
  nullVector = First@NullSpace[Transpose[Take[#, 2] & /@ vectors]];
  lhs = Together[nullVector . variables];
  constant = Together[nullVector . (Last /@ vectors)];
  assert[
    ! TrueQ[constant === 0],
    "A three-variable Appendix D unity denominator vanished."
  ];
  {lhs, constant}
];

reduceTripleTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, variables, relation},
  While[
    changed = AnyTrue[terms, Length[denominatorADMVs[#]] > 2 &];
    changed,
    iteration++;
    assert[
      iteration <= 12,
      "Appendix D triple reduction exceeded 12 iterations."
    ];
    terms = Flatten[
      Map[
        Function[term,
          variables = denominatorADMVs[term];
          If[
            Length[variables] <= 2,
            {term},
            assert[
              Length[variables] === 3,
              "Same-type reduction left more than three denominator ADMVs."
            ];
            relation = tripleUnityRelation[variables];
            splitTerms@Expand[term First[relation]/Last[relation]]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

chooseBasis[term_] := Module[{variables, firstVariable, partner},
  variables = denominatorADMVs[term];
  Which[
    Length[variables] === 2,
      assert[
        typeOfADMV[First[variables]] =!= typeOfADMV[Last[variables]],
        "Two same-type denominator ADMVs survived Appendix D."
      ];
      variables,
    Length[variables] === 1,
      firstVariable = First[variables];
      partner = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &
      ];
      {firstVariable, partner},
    Length[variables] === 0,
      {t2, u2},
    True,
      fatal["chooseBasis received an unreduced term."]
  ]
];

basisRules[basis_List] := basisRules[basis] = Module[
  {eliminate, solution},
  eliminate = Complement[admv, basis];
  solution = Solve[appendixDRelations, eliminate];
  assert[
    Length[solution] >= 1,
    "Could not solve Appendix D relations for a numerator basis."
  ];
  First[solution]
];

reduceNumerators[inputTerms_List] := Flatten[
  Map[
    Function[term, splitTerms@Expand[term /. basisRules[chooseBasis[term]]]],
    inputTerms
  ],
  1
];

reduceAppendixD[expression_, label_String] := Module[
  {terms, afterSame, afterTriple, reduced, invalid},
  terms = splitTerms[Expand[expression]];
  Print[
    "S08_STAGE: Appendix D start " <> label <>
      ", terms " <> ToString[Length[terms]]
  ];
  afterSame = reduceSameTypeTerms[terms];
  Print[
    "S08_STAGE: Appendix D same-type complete " <> label <>
      ", terms " <> ToString[Length[afterSame]]
  ];
  afterTriple = reduceTripleTerms[afterSame];
  Print[
    "S08_STAGE: Appendix D triple complete " <> label <>
      ", terms " <> ToString[Length[afterTriple]]
  ];
  reduced = reduceNumerators[afterTriple];
  invalid = Select[
    reduced,
    Function[term,
      Length[presentADMVs[term]] > 2 ||
        (Length[presentADMVs[term]] === 2 &&
          typeOfADMV[First[presentADMVs[term]]] ===
            typeOfADMV[Last[presentADMVs[term]]])
    ]
  ];
  assert[
    invalid === {},
    label <> " did not reduce to two different ADMV types."
  ];
  Print[
    "S08_STAGE: Appendix D numerator complete " <> label <>
      ", terms " <> ToString[Length[reduced]]
  ];
  reduced
];

(* Appendix-B frame 2: a + b Cos[beta1] + c Sin[beta1] Cos[beta2]. *)
linearCoefficients[variable_] := Module[
  {rho, yCoefficient, sConstant, sCosine, tConstant, tCosine, uHalf},
  rho = Sqrt[s23 u1 (Q2 s23 + sHat t1)];
  yCoefficient = rho/(s23 - t1);
  sConstant = (sHat - s23)/2;
  sCosine = sConstant + u1 s23/(s23 - t1);
  tConstant = -Q2 - (sHat + t1)/2;
  tCosine = ((sHat + t1) (s23 - t1) -
      2 s23 (sHat + Q2))/(2 (s23 - t1));
  uHalf = (s23 - t1)/2;
  Switch[variable,
    t2, {tConstant, tCosine, yCoefficient},
    t3, {tConstant, -tCosine, -yCoefficient},
    u2, {-uHalf, uHalf, 0},
    u3, {-uHalf, -uHalf, 0},
    s12, {sConstant, -sCosine, -yCoefficient},
    s13, {sConstant, sCosine, yCoefficient},
    _, fatal["Unknown ADMV in linearCoefficients."]
  ]
];

q2ConstraintRule = Q2 -> s23 - sHat - t1 - u1;

reducedLinearCoefficients[variable_] :=
  reducedLinearCoefficients[variable] =
    (Together /@ (linearCoefficients[variable] /. q2ConstraintRule));

coefficientDot[first_List, second_List] :=
  first[[2]] second[[2]] + first[[3]] second[[3]];

masslessGeometry[first_, second_] :=
  masslessGeometry[first, second] = Module[
    {firstCoefficients, secondCoefficients, cosine},
    firstCoefficients = reducedLinearCoefficients[first];
    secondCoefficients = reducedLinearCoefficients[second];
    cosine = Together[
      coefficientDot[firstCoefficients, secondCoefficients]/
        (First[firstCoefficients] First[secondCoefficients])
    ];
    {First[firstCoefficients], First[secondCoefficients], cosine}
  ];

case2Geometry[tVariable_, masslessVariable_] :=
  case2Geometry[tVariable, masslessVariable] = Module[
    {tCoefficients, masslessCoefficients, radius, dCoefficient, cosine},
    tCoefficients = reducedLinearCoefficients[tVariable];
    masslessCoefficients = reducedLinearCoefficients[masslessVariable];
    radius = (Sqrt[(sHat + t1)^2 + 4 Q2 s23]/2) /.
      q2ConstraintRule;
    dCoefficient = Together[-First[tCoefficients]/radius];
    cosine = Together[
      -coefficientDot[tCoefficients, masslessCoefficients]/
        (radius First[masslessCoefficients])
    ];
    {-radius, First[masslessCoefficients], dCoefficient, cosine}
  ];

appendixB18[j_Integer, l_Integer, cosine_, epsilonSymbol_] :=
  2 Pi Gamma[1 - 2 epsilonSymbol]/Gamma[1 - epsilonSymbol]^2 *
    2^(-j - l) *
    Beta[1 - epsilonSymbol - j, 1 - epsilonSymbol - l] *
    Hypergeometric2F1[
      j, l, 1 - epsilonSymbol, (1 + cosine)/2
    ];

angularKeyAndCoefficient[term_] := Module[
  {variables, firstVariable, secondVariable, firstPower,
   secondPower, coefficient, ordered},
  variables = presentADMVs[term];
  Which[
    Length[variables] === 0,
      Return[{{"Area"}, term /. q2ConstraintRule}],
    Length[variables] === 1,
      firstVariable = First[variables];
      secondVariable = SelectFirst[
        {t2, u2, s12},
        typeOfADMV[#] =!= typeOfADMV[firstVariable] &
      ];
      variables = {firstVariable, secondVariable},
    Length[variables] === 2,
      Null,
    True,
      fatal["Angular integration received more than two ADMVs."]
  ];
  ordered = If[
    MemberQ[typeOfADMV /@ variables, "t"],
    Join[
      Select[variables, typeOfADMV[#] === "t" &],
      Select[variables, typeOfADMV[#] =!= "t" &]
    ],
    SortBy[variables, First@First@Position[admv, #] &]
  ];
  firstVariable = First[ordered];
  secondVariable = Last[ordered];
  firstPower = laurentPower[term, firstVariable];
  secondPower = laurentPower[term, secondVariable];
  coefficient = Cancel[
    term/(firstVariable^firstPower secondVariable^secondPower)
  ] /. q2ConstraintRule;
  If[
    typeOfADMV[firstVariable] === "t",
    {
      {"B19", firstVariable, firstPower, secondVariable, secondPower},
      coefficient
    },
    {
      {"B18", firstVariable, firstPower, secondVariable, secondPower},
      coefficient
    }
  ]
];

masterFromKey[{"Area"}] := 2 Pi/(1 - 2 epsilon);

masterFromKey[
    {"B18", first_, firstPower_Integer, second_, secondPower_Integer}
  ] := Module[{geometry},
  geometry = masslessGeometry[first, second];
  geometry[[1]]^firstPower geometry[[2]]^secondPower *
    appendixB18[-firstPower, -secondPower, geometry[[3]], epsilon]
];

masterFromKey[
    {"B19", tVariable_, tPower_Integer,
     masslessVariable_, masslessPower_Integer}
  ] := Module[{geometry},
  geometry = case2Geometry[tVariable, masslessVariable];
  geometry[[1]]^tPower geometry[[2]]^masslessPower *
    S08Case2Master[
      -tPower, -masslessPower, geometry[[3]], geometry[[4]], epsilon
    ]
];

integrateReducedTerms[terms_List, label_String] := Module[
  {keyed, grouped, answer},
  Print["S08_STAGE: grouping angular masters for " <> label];
  keyed = angularKeyAndCoefficient /@ terms;
  grouped = Merge[(First[#] -> Last[#]) & /@ keyed, Total];
  Print[
    "S08_STAGE: angular master count " <> label <> " = " <>
      ToString[Length[grouped]]
  ];
  answer = Total[(Last[#] masterFromKey[First[#]]) & /@ Normal[grouped]];
  answer
];

(* Eq. (38), including the common 1/(2 Pi)^4 from Eq. (19). *)
threeBodyPhasePrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(6 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];

validateAngularExpression[expr_, label_String] := Module[{},
  assert[expr =!= $Failed && expr =!= 0,
    label <> " is failed or identically zero."];
  assert[
    FreeQ[
      expr,
      t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2 |
        _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum |
        Indeterminate | ComplexInfinity | _DirectedInfinity | $Failed | _Real
    ],
    label <> " contains an angular, propagator, infinity, or machine-real object."
  ];
  assert[FreeQ[expr, D], label <> " still contains D rather than epsilon."];
  True
];

loadValidatedCache[path_String, projectorName_String] := Module[
  {cache, validMetadata},
  If[! FileExistsQ[path], Return[Missing["NotAvailable"]]];
  Print["S08_STAGE: inspecting RealQG " <> projectorName <> " cache"];
  cache = Quiet@Check[Get[path], $Failed];
  validMetadata =
    AssociationQ[cache] &&
    cache["Status"] === "Complete" &&
    cache["StageVersion"] === stageVersion &&
    cache["Channel"] === "Hqg only" &&
    cache["TensorRole"] === "RealQG" &&
    cache["Projector"] === projectorName &&
    cache["SourceS07SHA256"] === s07SHA256 &&
    cache["ProgramSHA256"] === programSHA256 &&
    cache["BigTMDChannel"] === 3 &&
    cache["BigTMDChargeCase"] === "A only" &&
    cache["ElectricChargeNormalization"] ===
      s07["ElectricChargeNormalization"] &&
    cache["FragmentingParton"] === "g(k1)" &&
    KeyExistsQ[cache, "Expression"];
  If[! TrueQ[validMetadata],
    Print[
      "S08_STAGE: deleting stale or invalid RealQG " <>
        projectorName <> " cache"
    ];
    DeleteFile[path];
    Return[Missing["InvalidCache"]]
  ];
  validateAngularExpression[
    cache["Expression"],
    "cached Hqg RealQG " <> projectorName <> " angular result"
  ];
  Print[
    "S08_STAGE: loading validated RealQG " <> projectorName <> " cache"
  ];
  cache["Expression"]
];

writeValidatedCache[path_String, projectorName_String, expr_] := Module[
  {temporaryPath, cache},
  temporaryPath = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporaryPath], DeleteFile[temporaryPath]];
  cache = <|
    "Status" -> "Complete",
    "StageVersion" -> stageVersion,
    "Channel" -> "Hqg only",
    "TensorRole" -> "RealQG",
    "Projector" -> projectorName,
    "SourceS07" -> s07Path,
    "SourceS07SHA256" -> s07SHA256,
    "Program" -> programPath,
    "ProgramSHA256" -> programSHA256,
    "BigTMDChannel" -> 3,
    "BigTMDChargeCase" -> "A only",
    "ElectricChargeNormalization" -> s07["ElectricChargeNormalization"],
    "FragmentingParton" -> "g(k1)",
    "GeneratedAt" -> DateString[Now, "ISODateTime"],
    "Expression" -> expr
  |>;
  Put[cache, temporaryPath];
  assert[
    FileExistsQ[temporaryPath] && FileByteCount[temporaryPath] > 0,
    projectorName <> " temporary cache was not written."
  ];
  RenameFile[temporaryPath, path, OverwriteTarget -> True];
  assert[
    FileExistsQ[path] && FileByteCount[path] > 0,
    projectorName <> " cache was not finalized."
  ];
];

processRealProjection[projection_, projectorName_String] := Module[
  {answer, explicit, reducedTerms, angularResult},
  answer = loadValidatedCache[cachePaths[projectorName], projectorName];
  If[! MissingQ[answer], Return[answer]];

  Print[
    "S08_STAGE: making propagators explicit for Hqg;qg " <> projectorName
  ];
  explicit = makeRealExplicit[projection];
  assert[
    FreeQ[explicit, _FeynCalc`FeynAmpDenominator] &&
      FreeQ[explicit, _FeynCalc`Momentum],
    "Hqg;qg " <> projectorName <>
      " still contains an explicit propagator object."
  ];
  reducedTerms = reduceAppendixD[
    explicit,
    "Hqg;qg " <> projectorName
  ];
  angularResult = threeBodyPhasePrefactor *
    integrateReducedTerms[reducedTerms, "Hqg;qg " <> projectorName];
  validateAngularExpression[
    angularResult,
    "Hqg;qg " <> projectorName <> " angular result"
  ];
  writeValidatedCache[
    cachePaths[projectorName],
    projectorName,
    angularResult
  ];
  Print[
    "S08_CHECKPOINT: completed ", projectorName,
    " angular integration leaf count ", LeafCount[angularResult]
  ];
  angularResult
];

validateProjectionPair[pair_Association, label_String] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain exactly Pg and PPP."
  ];
  Scan[validateAngularExpression[#, label <> " projection"] &, Values[pair]];
  True
];

(* Eqs. (29)-(32): xB, zH, and PHT2 are external hadronic variables. *)
xHatXi = xB/xi;
xiLowerA = xB + xB PHT2/(zH (1 - zH) Q2);
s23UpperB = Q2 (1/xHatXi - 1) (1 - zH) - PHT2/zH;
zetaXiS23 =
  (xHatXi PHT2 + zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi));
zHatXiS23 = zH/zetaXiS23;
k1TPartonic2XiS23 = PHT2/zetaXiS23^2;
xiS23Jacobian =
  (xHatXi^2 PHT2 + xHatXi zH^2 Q2 (1 - xHatXi))/
    (zH (Q2 (1 - xHatXi) - s23 xHatXi)^2);

partonicSXi = Q2 (1/xHatXi - 1);
partonicTXiS23 =
  -Q2 + zHatXiS23 Q2 - k1TPartonic2XiS23/zHatXiS23;
partonicUXiS23 = -zHatXiS23 Q2/xHatXi;

partonicToXiS23Rules = {
  sHat -> partonicSXi,
  t1 -> partonicTXiS23,
  tHat -> partonicTXiS23,
  u1 -> partonicUXiS23
};

(* Exact equivalents of the formulas used in BigTMD sidis.py. *)
qT2BigTMD = PHT2/zH^2;
bigTMDZHatXiS23 =
  ((1 - xHatXi) - xHatXi s23/Q2)/
    ((1 - xHatXi) + xHatXi qT2BigTMD/Q2);
bigTMDJacobianXiS23 =
  zetaXiS23 xHatXi/Q2/
    ((1 - xHatXi) - xHatXi s23/Q2);
bigTMDPartonicSXi = Q2 (1 - xHatXi)/xHatXi;
bigTMDPartonicTXiS23 =
  -(1 - zHatXiS23) Q2 - zHatXiS23 qT2BigTMD;
bigTMDS23UpperB =
  Q2 (1/xHatXi - 1) (1 - zH) - zH qT2BigTMD;

bigTMDKinematicChecks = <|
  "ZHatS23MapExact" ->
    TrueQ[Together[zHatXiS23 - bigTMDZHatXiS23] === 0],
  "JacobianExact" ->
    TrueQ[Together[xiS23Jacobian - bigTMDJacobianXiS23] === 0],
  "PartonicSExact" ->
    TrueQ[Together[partonicSXi - bigTMDPartonicSXi] === 0],
  "PartonicTExact" ->
    TrueQ[Together[partonicTXiS23 - bigTMDPartonicTXiS23] === 0],
  "EndpointBExact" ->
    TrueQ[Together[s23UpperB - bigTMDS23UpperB] === 0]
|>;

transformPair[pair_Association] := Map[
  Function[expression,
    xiS23Jacobian * (expression /. partonicToXiS23Rules)
  ],
  pair
];

validateXiS23Pair[pair_Association, label_String] := Module[{},
  assert[
    Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " transformed pair has the wrong projector keys."
  ];
  assert[
    And @@ Map[
      Function[expression, expression =!= $Failed && expression =!= 0],
      Values[pair]
    ],
    label <> " contains a failed or zero transformed expression."
  ];
  assert[
    And @@ (FreeQ[
        #,
        zeta | sHat | tHat | t1 | u1 |
          Indeterminate | ComplexInfinity | _DirectedInfinity | $Failed | _Real
      ] & /@ Values[pair]),
    label <> " retains a replaced variable, infinity, or machine real."
  ];
  assert[
    And @@ Map[
      Function[expression,
        ! FreeQ[expression, xi] && ! FreeQ[expression, s23]
      ],
      Values[pair]
    ],
    label <> " does not retain both xi and s23 dependence."
  ];
  True
];

zeroCoefficientVectorQ[vector_List] :=
  And @@ (TrueQ[Together[# /. q2ConstraintRule] === 0] & /@ vector);

Print["S08_STAGE: validating Appendix D and BigTMD kinematic identities"];
appendixDIdentityChecks = <|
  "D5_t2_plus_t3" -> zeroCoefficientVectorQ[
    linearCoefficients[t2] + linearCoefficients[t3] -
      {u1 - s23 - Q2, 0, 0}
  ],
  "D6_u2_plus_u3" -> zeroCoefficientVectorQ[
    linearCoefficients[u2] + linearCoefficients[u3] -
      {t1 - s23, 0, 0}
  ],
  "D7_s12_plus_s13" -> zeroCoefficientVectorQ[
    linearCoefficients[s12] + linearCoefficients[s13] -
      {sHat - s23, 0, 0}
  ],
  "D8_s13_relation" -> zeroCoefficientVectorQ[
    linearCoefficients[s13] - linearCoefficients[t2] -
      linearCoefficients[u2] - {sHat + Q2, 0, 0}
  ]
|>;
assert[
  AllTrue[Values[appendixDIdentityChecks], TrueQ],
  "At least one Appendix D angular identity failed."
];
assert[
  TrueQ[Together[D[zetaXiS23, s23] - xiS23Jacobian] === 0],
  "The zeta-to-s23 Jacobian identity failed."
];
assert[
  AllTrue[Values[bigTMDKinematicChecks], TrueQ],
  "At least one exact BigTMD kinematic-map identity failed."
];

Print["S08_STAGE: applying two-body Hqg phase space"];
twoBodyResults = <|
  "LO_OAlphaS" -> makeTwoBodyPair[loInput, "Hqg LO", True],
  "NLOVirtualInterference_OAlphaS2_Symbolic" ->
    makeTwoBodyPair[
      virtualInput,
      "Hqg renormalized virtual interference",
      False
    ]
|>;
validateTwoBodyPair[
  twoBodyResults["LO_OAlphaS"],
  "Hqg LO two-body result",
  True
];
validateTwoBodyPair[
  twoBodyResults["NLOVirtualInterference_OAlphaS2_Symbolic"],
  "Hqg virtual two-body result",
  False
];
assert[
  And @@ (! FreeQ[#, dZq1] & /@
      Values[twoBodyResults[
        "NLOVirtualInterference_OAlphaS2_Symbolic"
      ]]) &&
    And @@ (! FreeQ[#, dZGG1] & /@
      Values[twoBodyResults[
        "NLOVirtualInterference_OAlphaS2_Symbolic"
      ]]) &&
    And @@ (! FreeQ[#, dZgs1] & /@
      Values[twoBodyResults[
        "NLOVirtualInterference_OAlphaS2_Symbolic"
      ]]),
  "The two-body virtual pair lost symbolic QCD counterterms."
];

Print["S08_STAGE: integrating the Hqg;qg real projections"];
realAngularResults = <|
  "Pg" -> processRealProjection[realQGInput["Pg"], "Pg"],
  "PPP" -> processRealProjection[realQGInput["PPP"], "PPP"]
|>;
validateProjectionPair[realAngularResults, "Hqg;qg angular result"];

Print["S08_STAGE: applying zeta-to-s23 change of variables"];
xiS23Kernels = <|
  "TwoBody" -> Map[transformPair, twoBodyResults],
  "ThreeBodyReal" -> <|
    "Hqg;qg" -> transformPair[realAngularResults]
  |>
|>;
Scan[
  Function[order,
    validateXiS23Pair[xiS23Kernels["TwoBody", order], order]
  ],
  Keys[xiS23Kernels["TwoBody"]]
];
validateXiS23Pair[
  xiS23Kernels["ThreeBodyReal", "Hqg;qg"],
  "Hqg;qg xi-s23 kernel"
];

case2Masters = DeleteDuplicates@Cases[
  Values[realAngularResults],
  _S08Case2Master,
  Infinity
];

s08Checks = <|
  "CurrentS07SourceAndProgramBindingsVerified" -> True,
  "PaperReferenceHashPreserved" -> True,
  "BigTMDChannel3CaseAEnforced" -> True,
  "ChargeStrippedHardKernelConventionPreserved" -> True,
  "FragmentingGluonIsK1" -> True,
  "TwoBodyLOIntegratedAtFixedK1" -> True,
  "TwoBodyVirtualIntegratedAtFixedK1" -> True,
  "VirtualPropagatorPlaceholdersPreserved" -> True,
  "TwoBodyConstraintIsDeltaS23" -> True,
  "SoleRealHqgQGChannelAngularIntegrated" -> True,
  "BothProjectorsRetainedForAllThreeContributions" -> True,
  "AppendixDIdentitiesD5ThroughD8Verified" -> True,
  "NoBeta1OrBeta2Remain" -> True,
  "NoAngleDependentMandelstamVariablesRemain" -> True,
  "NoExplicitRealPropagatorObjectsRemain" -> True,
  "AxialReferenceTermsCombinedBeforeAppendixD" -> True,
  "ZetaReplacedByS23" -> True,
  "XiS23JacobianIdentityVerified" -> True,
  "XiS23JacobianIncluded" -> True,
  "PhysicalXiAndS23LimitsStored" -> True,
  "BigTMDZHatJacobianSAndTAndBMapsExact" -> True,
  "CalculationFullySymbolic" -> True,
  "VirtualQCDCountertermsPreserved" -> True,
  "EndpointDistributionExpansionNotApplied" -> True,
  "RealVirtualCombinationNotApplied" -> True,
  "CollinearFactorizationNotApplied" -> True,
  "EveryRealCacheBoundToS07AndProgramSHA256" -> True
|>;

s08Result = <|
  "Status" -> "Complete",
  "Stage" -> stageVersion,
  "Channel" -> "Hqg only",
  "Contribution" ->
    "Hqg LO/virtual two-body and Hqg;qg real angular-integrated Pg/PPP kernels",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "Program" -> programPath,
  "ProgramSHA256" -> programSHA256,
  "SourceResult" -> s07Path,
  "SourceResultSHA256" -> s07SHA256,
  "ReferencePDFSHA256" -> s07["ReferencePDFSHA256"],
  "BigTMDConvention" -> s07["BigTMDConvention"],
  "ElectricChargeNormalization" -> s07["ElectricChargeNormalization"],
  "BigTMDProjectorMapping" -> s07["BigTMDProjectorMapping"],
  "BigTMDKinematicMapping" -> <|
    "PHT2Relation" -> HoldForm[PHT2 == zH^2 qT2],
    "ZHatExpression" -> zHatXiS23,
    "BigTMDZHatExpression" -> bigTMDZHatXiS23,
    "JacobianExpression" -> xiS23Jacobian,
    "BigTMDJacobianExpression" -> bigTMDJacobianXiS23,
    "PartonicS" -> partonicSXi,
    "PartonicT" -> partonicTXiS23,
    "S23UpperB" -> s23UpperB,
    "Checks" -> bigTMDKinematicChecks,
    "FiniteKernelComparisonStatus" ->
      "Deferred until endpoint expansion, real-virtual combination, factorization, and finite regular/delta/plus assembly."
  |>,
  "DimensionalConvention" -> HoldForm[D == 4 - 2 epsilon],
  "FragmentingParton" -> "gluon g(k1)",
  "ObservedMomentumTreatment" ->
    "fragmenting g(k1) is kept differential; only unobserved q(k2),g(k3) real-phase-space angles are integrated",
  "TwoBodyPhaseSpaceIntegrated" -> twoBodyResults,
  "ThreeBodyAngularIntegrated" -> <|
    "Hqg;qg" -> realAngularResults
  |>,
  "XiS23ConvolutionKernels" -> xiS23Kernels,
  "XiS23ChangeOfVariables" -> <|
    "Replacement" -> HoldForm[zeta == zetaXiS23],
    "ZetaExpression" -> zetaXiS23,
    "Jacobian_dXi_dZeta_to_dXi_dS23" -> xiS23Jacobian,
    "JacobianIdentityVerified" -> True,
    "XiRange" -> {xi, xiLowerA, 1},
    "S23RangeAtFixedXi" -> {s23, 0, s23UpperB},
    "XiLowerA" -> xiLowerA,
    "S23UpperB" -> s23UpperB,
    "PartonicKinematicRules" -> partonicToXiS23Rules,
    "SIsNotReplaced" -> True
  |>,
  "AngularMasterBasis" -> <|
    "MasslessMassless" -> "Eq. (B18), evaluated explicitly",
    "VirtualPhotonMassless" -> "I[j,l] of Eq. (B19)",
    "Case2MastersUsed" -> case2Masters,
    "Case2MasterCount" -> Length[case2Masters],
    "Case2MasterDefinition" -> HoldComplete[
      S08Case2Master[j, l, dCoefficient, cosineChi, epsilon] ==
        With[{n = 4 - 2 epsilon},
          (-1)^(l + 1) 2^(1 - l - j) Pi Gamma[n - 3] *
            Gamma[2 + l - n/2] Gamma[n/2 - l - 1]/
            (Gamma[n/2 - 1]^2 Gamma[n/2 - 2] *
              Gamma[3 - n/2]) *
            Inactive[Integrate][
              zMaster^(n/2 - 2) (1 - zMaster)^(n/2 - l - 2)/
                (zMaster + (dCoefficient - 1)/2)^j *
                Hypergeometric2F1[
                  j, l, n/2 - 1,
                  (1 + cosineChi) zMaster/
                    (dCoefficient - 1 + 2 zMaster)
                ],
              {zMaster, 0, 1}
            ]
        ]
    ]
  |>,
  "AppendixDIdentityChecks" -> appendixDIdentityChecks,
  "CacheProvenance" -> <|
    "StageVersion" -> stageVersion,
    "SourceS07SHA256" -> s07SHA256,
    "ProgramSHA256" -> programSHA256,
    "Paths" -> cachePaths,
    "EveryCacheBoundToSourceS07AndProgramSHA256" -> True
  |>,
  "PaperReferences" -> {
    "two-body phase space: Eqs. (34)-(35)",
    "three-body phase space: Eqs. (38)-(40)",
    "angular master integrals: Appendix B",
    "partial fractions: Appendix D",
    "zeta to s23: Eqs. (29)-(32)"
  },
  "Checks" -> s08Checks,
  "NotPerformedAtThisStage" -> {
    "Appendix F epsilon expansion of I[j,l] masters",
    "physical Sum_q e_q^2 PDF luminosity and gluon fragmentation function",
    "s23 endpoint delta/plus-distribution expansion",
    "real-virtual infrared-pole cancellation",
    "initial-state PDF and final-state FF subtraction from Eq. (46)",
    "epsilon -> 0 limit",
    "BigTMD cross-section/luminosity/photon-spin normalization",
    "finite comparison with BigTMD Pg/Ppp fchn3A regular/delta/plus kernels"
  }
|>;

angularLeafCounts = Map[LeafCount, realAngularResults];
transformedLeafCounts = <|
  "TwoBody" -> Map[
    Map[LeafCount, #] &,
    xiS23Kernels["TwoBody"]
  ],
  "ThreeBodyReal" -> Map[
    LeafCount,
    xiS23Kernels["ThreeBodyReal", "Hqg;qg"]
  ]
|>;

Print["S08_STAGE: writing " <> resultPath];
temporaryResultPath = resultPath <> ".tmp." <> ToString[$ProcessID];
If[FileExistsQ[temporaryResultPath], DeleteFile[temporaryResultPath]];
Put[s08Result, temporaryResultPath];
assert[
  FileExistsQ[temporaryResultPath] && FileByteCount[temporaryResultPath] > 0,
  "The temporary s08_result was not written."
];
RenameFile[temporaryResultPath, resultPath, OverwriteTarget -> True];
assert[FileExistsQ[resultPath], "s08_result was not created."];
assert[FileByteCount[resultPath] > 0, "s08_result is empty."];

Print["S08_SUCCESS"];
Print["S08_RESULT_PATH=" <> resultPath];
Print["S08_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
Print["S08_ANGULAR_LEAF_COUNTS=", InputForm[angularLeafCounts]];
Print["S08_TRANSFORMED_LEAF_COUNTS=", InputForm[transformedLeafCounts]];
Print["S08_CHECKS=", InputForm[s08Checks]];

Quit[0];

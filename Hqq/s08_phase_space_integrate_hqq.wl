(* ::Package:: *)

(*
  Hqq stage s08: perform the phase-space operations requested after s07.

  1. Apply the two-body k2 phase space to the LO and renormalized-virtual
     projections at fixed observed k1, writing the constraint as Delta(s23).
  2. Integrate the three real channels over beta1,beta2 in D=4-2 epsilon.
     Appendix D reduces every term to two angular denominators of different
     types. Eq. (B18) is evaluated explicitly; virtual-photon masters are
     represented by S08Case2Master, whose exact Eq. (B19) definition is saved
     in s08_result. Thus beta1 and beta2 are absent from the output.
  3. Apply Eq. (29): replace zeta by s23 in the PDF/FF convolution, including
     the Jacobian and the physical xi and s23 limits.

  This stage deliberately does not expand s23 -> 0 into endpoint
  distributions, combine real and virtual poles, or apply Eq. (46).
*)

$HistoryLength = 0;
Needs["FeynCalc`"];
$FCAdvice = False;

ClearAll[
  fatal, assert, splitTerms, setTwoBodyKinematics,
  setThreeBodyKinematics, makeTwoBodyPair, makeRealExplicit,
  laurentPower, denominatorADMVs, presentADMVs, typeOfADMV,
  sameTypeOffender, reduceSameTypeTerms, affineVector,
  tripleUnityRelation, reduceTripleTerms, chooseBasis,
  basisRules, reduceNumerators, reduceAppendixD,
  linearCoefficients, reducedLinearCoefficients,
  coefficientDot, masslessGeometry, case2Geometry,
  appendixB18, angularKeyAndCoefficient, masterFromKey,
  integrateReducedTerms, processRealProjection, transformPair,
  validateTwoBodyPair, validateRealPair, validateXiS23Pair,
  S08Case2Master
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
s07Path = FileNameJoin[{scriptDirectory, "s07_result"}];
resultPath = FileNameJoin[{scriptDirectory, "s08_result"}];
cacheVersion = 1;

cachePath[label_String, projector_String] := FileNameJoin[{
  scriptDirectory,
  "s08_cache_v1_" <> label <> "_" <> ToLowerCase[projector]
}];

Print["S08_STAGE: loading s07_result"];
assert[FileExistsQ[s07Path], "s07_result does not exist."];
s07 = Check[Get[s07Path], $Failed];
assert[AssociationQ[s07], "s07_result did not load as an Association."];
assert[s07["Status"] === "Complete", "s07_result is not complete."];
assert[s07["Channel"] === "Hqq only", "s07_result is not Hqq-only."];
assert[s07["ProjectionCount"] === 10,
  "s07_result does not contain ten projections."];
assert[And @@ Values[s07["Checks"]],
  "At least one s07 validation check is not True."];

loInput = s07["ScalarProjections", "LO_OAlphaS"];
virtualInput = s07[
  "ScalarProjections", "NLOVirtualInterference_OAlphaS2_Symbolic"
];
realInputs = <|
  "Hqq;gg" -> s07[
    "ScalarProjections", "NLOReal_OAlphaS2", "Hqq;gg"
  ],
  "Hqq;q_qbar_sameFlavor" -> s07[
    "ScalarProjections", "NLOReal_OAlphaS2",
    "Hqq;q_qbar_sameFlavor"
  ],
  "Hqq;qPrime_qbarPrime" -> s07[
    "ScalarProjections", "NLOReal_OAlphaS2",
    "Hqq;qPrime_qbarPrime"
  ]
|>;

assert[And @@ (AssociationQ /@ Join[
      {loInput, virtualInput}, Values[realInputs]
    ]),
  "At least one s07 projection pair is not an Association."];

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

(* Eq. (34), including the common 1/(2 Pi)^4 in Eq. (19). *)
twoBodyPhaseFactor = (2 Pi)/(2 Pi)^4 DiracDelta[s23];

makeTwoBodyPair[
    input_Association, label_String, expandPropagatorsQ_
  ] := Module[{answer},
  Print["S08_STAGE: applying two-body phase space to " <> label];
  If[TrueQ[expandPropagatorsQ], setTwoBodyKinematics[]];
  answer = Map[
    Function[projection,
      twoBodyPhaseFactor *
        ((If[TrueQ[expandPropagatorsQ],
            FeynCalc`FeynAmpDenominatorExplicit[projection],
            projection
          ]) /. D -> 4 - 2 epsilon)
    ],
    input
  ];
  answer
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
  answer = Expand[answer /. propagatorInvariantRules];
  answer /. D -> 4 - 2 epsilon
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
  Total[Map[
    Function[factor,
      Which[
        factor === variable, 1,
        Head[factor] === Power && First[factor] === variable &&
          IntegerQ[Last[factor]], Last[factor],
        True, 0
      ]
    ],
    factors
  ]]
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
  Function[data,
    And @@ (laurentPower[term, #] < 0 & /@ First[data])
  ],
  Missing["NotFound"]
];

reduceSameTypeTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, offender},
  While[
    changed = AnyTrue[terms, ! MissingQ[sameTypeOffender[#]] &];
    changed,
    iteration++;
    assert[iteration <= 12,
      "Appendix D same-type reduction exceeded 12 iterations."];
    terms = Flatten[
      Map[
        Function[term,
          offender = sameTypeOffender[term];
          If[MissingQ[offender],
            {term},
            splitTerms@Expand[
              term Total[First[offender]]/Last[offender]
            ]
          ]
        ],
        terms
      ],
      1
    ];
  ];
  terms
];

(* Affine coordinates in the independent pair {t2,u2}. *)
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
  assert[Length[variables] === 3,
    "A three-variable Appendix D relation was requested incorrectly."];
  vectors = affineVector /@ variables;
  nullVector = First@NullSpace[
    Transpose[Take[#, 2] & /@ vectors]
  ];
  lhs = Together[nullVector . variables];
  constant = Together[nullVector . (Last /@ vectors)];
  assert[! TrueQ[constant === 0],
    "A three-variable Appendix D unity denominator vanished."];
  {lhs, constant}
];

reduceTripleTerms[inputTerms_List] := Module[
  {terms = inputTerms, iteration = 0, changed, variables, relation},
  While[
    changed = AnyTrue[terms, Length[denominatorADMVs[#]] > 2 &];
    changed,
    iteration++;
    assert[iteration <= 12,
      "Appendix D triple reduction exceeded 12 iterations."];
    terms = Flatten[
      Map[
        Function[term,
          variables = denominatorADMVs[term];
          If[Length[variables] <= 2,
            {term},
            assert[Length[variables] === 3,
              "Same-type reduction left more than three denominator ADMVs."];
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
      assert[typeOfADMV[First[variables]] =!=
          typeOfADMV[Last[variables]],
        "Two same-type denominator ADMVs survived Appendix D."];
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
  assert[Length[solution] >= 1,
    "Could not solve Appendix D relations for a numerator basis."];
  First[solution]
];

reduceNumerators[inputTerms_List] := Flatten[
  Map[
    Function[term,
      splitTerms@Expand[term /. basisRules[chooseBasis[term]]]
    ],
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
  assert[invalid === {},
    label <> " did not reduce to two different ADMV types."];
  Print[
    "S08_STAGE: Appendix D numerator complete " <> label <>
      ", terms " <> ToString[Length[reduced]]
  ];
  reduced
];

(* Frame 2 of Appendix B. A variable is a + b Cos[beta1]
   + c Sin[beta1] Cos[beta2]. *)
linearCoefficients[variable_] := Module[
  {rho, yCoefficient, sConstant, sCosine, tConstant, tCosine,
   uHalf},
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
    {tCoefficients, masslessCoefficients, radius, dCoefficient,
     cosine},
    tCoefficients = reducedLinearCoefficients[tVariable];
    masslessCoefficients = reducedLinearCoefficients[masslessVariable];
    radius = (Sqrt[
      (sHat + t1)^2 + 4 Q2 s23
    ]/2) /. q2ConstraintRule;
    dCoefficient = Together[-First[tCoefficients]/radius];
    cosine = Together[
      -coefficientDot[tCoefficients, masslessCoefficients]/
        (radius First[masslessCoefficients])
    ];
    {-radius, First[masslessCoefficients], dCoefficient, cosine}
  ];

(* Eq. (B18), with j and l denoting denominator powers. *)
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
      {{"Area"}, term /. q2ConstraintRule},
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
  If[Length[variables] === 0, Return[
    {{"Area"}, term /. q2ConstraintRule}
  ]];
  ordered = If[MemberQ[typeOfADMV /@ variables, "t"],
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
  If[typeOfADMV[firstVariable] === "t",
    {{"B19", firstVariable, firstPower,
       secondVariable, secondPower}, coefficient},
    {{"B18", firstVariable, firstPower,
       secondVariable, secondPower}, coefficient}
  ]
];

masterFromKey[{"Area"}] := 2 Pi/(1 - 2 epsilon);

masterFromKey[
    {"B18", first_, firstPower_Integer,
     second_, secondPower_Integer}
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
  answer = Total[
    (Last[#] masterFromKey[First[#]]) & /@ Normal[grouped]
  ];
  answer
];

(* Eq. (38), including the common 1/(2 Pi)^4 from Eq. (19). *)
threeBodyPhasePrefactor =
  s23^(-epsilon) 2^(-2) Pi^(-epsilon)/
    (2 Pi)^(6 - 2 epsilon) *
    Gamma[1 - epsilon]/Gamma[1 - 2 epsilon];

processRealProjection[
    projection_, label_String, cache_String
  ] := Module[{cached, explicit, reducedTerms, angularResult, payload},
  If[FileExistsQ[cache],
    Print["S08_STAGE: loading real cache for " <> label];
    cached = Check[Get[cache], $Failed];
    assert[AssociationQ[cached] &&
        cached["CacheVersion"] === cacheVersion,
      label <> " cache is invalid or has the wrong version."];
    Return[cached["Expression"]]
  ];
  Print["S08_STAGE: making propagators explicit for " <> label];
  explicit = makeRealExplicit[projection];
  assert[FreeQ[explicit, _FeynCalc`FeynAmpDenominator] &&
      FreeQ[explicit, _FeynCalc`Momentum],
    label <> " still contains an explicit propagator object."];
  reducedTerms = reduceAppendixD[explicit, label];
  angularResult = threeBodyPhasePrefactor *
    integrateReducedTerms[reducedTerms, label];
  assert[FreeQ[
      angularResult,
      t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2
    ],
    label <> " still contains an angular variable or ADMV."];
  payload = <|
    "CacheVersion" -> cacheVersion,
    "Label" -> label,
    "Expression" -> angularResult
  |>;
  Put[payload, cache];
  assert[FileExistsQ[cache] && FileByteCount[cache] > 0,
    label <> " cache was not written."];
  Print[
    "S08_STAGE: completed angular integration for " <> label <>
      ", leaf count " <> ToString[LeafCount[angularResult]]
  ];
  angularResult
];

validateTwoBodyPair[pair_Association, label_String] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain Pg and PPP."];
  assert[And @@ (! FreeQ[#, DiracDelta[s23]] & /@ Values[pair]),
    label <> " is missing DiracDelta[s23]."];
  assert[And @@ (FreeQ[#, D] & /@ Values[pair]),
    label <> " still contains D rather than epsilon."];
  True
];

validateRealPair[pair_Association, label_String] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " does not contain Pg and PPP."];
  assert[And @@ (FreeQ[
        #,
        t2 | t3 | u2 | u3 | s12 | s13 | beta1 | beta2 |
          _FeynCalc`FeynAmpDenominator | _FeynCalc`Momentum
      ] & /@ Values[pair]),
    label <> " contains an unintegrated angular or propagator object."];
  True
];

Print["S08_STAGE: two-body phase-space integration"];
twoBodyResults = <|
  "LO_OAlphaS" -> makeTwoBodyPair[loInput, "LO", True],
  "NLOVirtualInterference_OAlphaS2_Symbolic" ->
    makeTwoBodyPair[
      virtualInput, "renormalized virtual interference", False
    ]
|>;

validateTwoBodyPair[twoBodyResults["LO_OAlphaS"], "LO two-body result"];
validateTwoBodyPair[
  twoBodyResults["NLOVirtualInterference_OAlphaS2_Symbolic"],
  "virtual two-body result"
];

Print["S08_STAGE: three-body angular integrations"];
realAngularResults = <|
  "Hqq;gg" -> <|
    "Pg" -> processRealProjection[
      realInputs["Hqq;gg", "Pg"],
      "Hqq;gg Pg",
      cachePath["real_qgg", "g"]
    ],
    "PPP" -> processRealProjection[
      realInputs["Hqq;gg", "PPP"],
      "Hqq;gg PPP",
      cachePath["real_qgg", "pp"]
    ]
  |>,
  "Hqq;q_qbar_sameFlavor" -> <|
    "Pg" -> processRealProjection[
      realInputs["Hqq;q_qbar_sameFlavor", "Pg"],
      "Hqq;q_qbar_sameFlavor Pg",
      cachePath["real_same_flavor", "g"]
    ],
    "PPP" -> processRealProjection[
      realInputs["Hqq;q_qbar_sameFlavor", "PPP"],
      "Hqq;q_qbar_sameFlavor PPP",
      cachePath["real_same_flavor", "pp"]
    ]
  |>,
  "Hqq;qPrime_qbarPrime" -> <|
    "Pg" -> processRealProjection[
      realInputs["Hqq;qPrime_qbarPrime", "Pg"],
      "Hqq;qPrime_qbarPrime Pg",
      cachePath["real_different_flavor", "g"]
    ],
    "PPP" -> processRealProjection[
      realInputs["Hqq;qPrime_qbarPrime", "PPP"],
      "Hqq;qPrime_qbarPrime PPP",
      cachePath["real_different_flavor", "pp"]
    ]
  |>
|>;

Scan[
  Function[channel,
    validateRealPair[realAngularResults[channel], channel]
  ],
  Keys[realAngularResults]
];

(* Eq. (29)-(32). xB, zH, and PHT2 are external hadronic variables. *)
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

partonicToXiS23Rules = {
  sHat -> Q2 (1/xHatXi - 1),
  t1 -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  tHat -> -Q2 + zHatXiS23 Q2 -
    k1TPartonic2XiS23/zHatXiS23,
  u1 -> -zHatXiS23 Q2/xHatXi
};

transformPair[pair_Association] := Map[
  Function[expression,
    xiS23Jacobian * (expression /. partonicToXiS23Rules)
  ],
  pair
];

Print["S08_STAGE: applying zeta-to-s23 change of variables"];
xiS23Kernels = <|
  "TwoBody" -> Map[transformPair, twoBodyResults],
  "ThreeBodyReal" -> Map[transformPair, realAngularResults]
|>;

validateXiS23Pair[pair_Association, label_String] := Module[{},
  assert[Sort[Keys[pair]] === Sort[{"Pg", "PPP"}],
    label <> " transformed pair has the wrong projector keys."];
  assert[And @@ (FreeQ[#, zeta | sHat | tHat | t1 | u1] & /@
      Values[pair]),
    label <> " transformed pair retains a replaced variable."];
  True
];

Scan[
  Function[order,
    validateXiS23Pair[xiS23Kernels["TwoBody", order], order]
  ],
  Keys[xiS23Kernels["TwoBody"]]
];
Scan[
  Function[channel,
    validateXiS23Pair[
      xiS23Kernels["ThreeBodyReal", channel], channel
    ]
  ],
  Keys[xiS23Kernels["ThreeBodyReal"]]
];

case2Masters = DeleteDuplicates@Cases[
  Values[realAngularResults],
  _S08Case2Master,
  Infinity
];

s08Checks = <|
  "S07InputValidated" -> True,
  "TwoBodyLOIntegratedAtFixedK1" -> True,
  "TwoBodyVirtualIntegratedAtFixedK1" -> True,
  "TwoBodyConstraintIsDeltaS23" -> True,
  "ThreeRealChannelsAngularIntegrated" -> True,
  "BothProjectorsRetainedForAllFiveContributions" -> True,
  "NoBeta1OrBeta2Remain" -> True,
  "NoAngleDependentMandelstamVariablesRemain" -> True,
  "ZetaReplacedByS23" -> True,
  "XiS23JacobianIncluded" -> True,
  "PhysicalXiAndS23LimitsStored" -> True,
  "EndpointDistributionExpansionNotApplied" -> True,
  "RealVirtualCombinationNotApplied" -> True,
  "CollinearFactorizationNotApplied" -> True
|>;

s08Result = <|
  "Status" -> "Complete",
  "Channel" -> "Hqq only",
  "GeneratedAt" -> DateString[Now, "ISODateTime"],
  "SourceResult" -> s07Path,
  "DimensionalConvention" -> HoldForm[D == 4 - 2 epsilon],
  "ObservedMomentumTreatment" ->
    "k1 is kept differential; only unobserved final-state phase space is integrated",
  "TwoBodyPhaseSpaceIntegrated" -> twoBodyResults,
  "ThreeBodyAngularIntegrated" -> realAngularResults,
  "XiS23ConvolutionKernels" -> xiS23Kernels,
  "XiS23ChangeOfVariables" -> <|
    "Replacement" -> HoldForm[zeta == zetaXiS23],
    "ZetaExpression" -> zetaXiS23,
    "Jacobian_dXi_dZeta_to_dXi_dS23" -> xiS23Jacobian,
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
    "s23 endpoint delta/plus-distribution expansion",
    "real-virtual infrared-pole cancellation",
    "initial-state PDF and final-state FF subtraction from Eq. (46)",
    "epsilon -> 0 limit",
    "numerical PDF/FF convolution"
  }
|>;

Print["S08_STAGE: writing " <> resultPath];
Put[s08Result, resultPath];
assert[FileExistsQ[resultPath], "s08_result was not created."];
assert[FileByteCount[resultPath] > 0, "s08_result is empty."];

Print["S08_SUCCESS"];
Print["S08_RESULT_PATH=" <> resultPath];
Print["S08_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S08_CASE2_MASTER_COUNT=", Length[case2Masters]];
Print["S08_CHECKS=", InputForm[s08Checks]];

Quit[0];

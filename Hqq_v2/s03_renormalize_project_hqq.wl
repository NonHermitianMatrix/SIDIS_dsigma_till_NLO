(* Hqq_v2 S03: Pg/PPP projections and tool-derived MS-bar UV renormalization. *)

$HistoryLength = 0;
$IterationLimit = Infinity;
$LoadAddOns = {"FeynArts", "FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym, FrontEndObject::notavail}];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;
$KeepLogDivergentScalelessIntegrals = True;

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[
  hqqV2Fail, hqqV2Require, atomicPut, namedSymbolQ,
  replaceNamedObject, namedObjectPresentQ, makePairRule,
  installTwoBodyKinematics, installThreeBodyMassShells,
  canonicalTwoBody, canonicalThreePublished, canonicalThreeFull,
  rationalZeroQ, scalarEqualQ, projectTensorRow,
  conjugateTreeExpression, stateSumRow, wardSubstitute,
  photonContract, convertGeneratedAmplitudes, reduceUVAmplitude,
  solveScaleRelation, applyMSbarConstants
];

hqqV2Fail[msg_String] := (Print["S03_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] := If[! TrueQ[test], hqqV2Fail[msg]];

atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    hqqV2Fail["failed to write " <> path]];
  hqqV2Require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary result is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  hqqV2Require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
s01SourcePath = FileNameJoin[{stageDirectory,
  "s01_generate_hqq_amplitudes.wl"}];
s01ResultPath = FileNameJoin[{stageDirectory, "s01_result.wl"}];
s02SourcePath = FileNameJoin[{stageDirectory,
  "s02_build_hqq_tensors.wl"}];
s02ResultPath = FileNameJoin[{stageDirectory, "s02_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];
recoveryCheckpointPath = FileNameJoin[{stageDirectory,
  "s03_pre_uv_checkpoint.wl"}];
failedProductionLogPath = FileNameJoin[{stageDirectory,
  "s03_failed_uv_cancellation_local.log"}];

expectedS01SourceHash =
  "5125f6f8a2c2ac7cfa44fc3b8bb437e1f5fdf26c52169d9c4991f5b35ab660d1";
expectedS01ResultHash =
  "83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911";
expectedS02SourceHash =
  "2559c4b388b9fcb746dcf37bebbd33731f6adf7584e749ac632e4db68854fe73";
expectedS02ResultHash =
  "316c6e18b49bd7c446506fc866546d0c998f6d61cec3c3813693cbf72b735c83";
failedProductionSourceHash =
  "53e6e46ce9534e4170985de2832bacb9854b7bcce45a607abb12a0281822a494";
expectedFailedProductionLogHash =
  "e080747ea4d1c74bd4d9a37ba33446914dbf9ae2e4c1ea3f16a751ac9fcc437c";

hqqV2Require[
  FileHash[s01SourcePath, "SHA256", "HexString"] ===
    expectedS01SourceHash,
  "S01 source identity mismatch"];
hqqV2Require[
  FileHash[s01ResultPath, "SHA256", "HexString"] ===
    expectedS01ResultHash,
  "S01 result identity mismatch"];
hqqV2Require[
  FileHash[s02SourcePath, "SHA256", "HexString"] ===
    expectedS02SourceHash,
  "S02 source identity mismatch"];
hqqV2Require[
  FileHash[s02ResultPath, "SHA256", "HexString"] ===
    expectedS02ResultHash,
  "S02 result identity mismatch"];

s01 = Get[s01ResultPath];
s02 = Get[s02ResultPath];
hqqV2Require[
  AssociationQ[s01] && s01["Stage"] === "HqqV2S01-v1" &&
    s01["ScopeTag"] === scopeTag && And @@ Values[s01["Checks"]],
  "S01 result is not accepted"];
hqqV2Require[
  AssociationQ[s02] && s02["Stage"] === "HqqV2S02-v1" &&
    s02["ScopeTag"] === scopeTag && And @@ Values[s02["Checks"]] &&
    s02["S01", "SourceSHA256"] === expectedS01SourceHash &&
    s02["S01", "ResultSHA256"] === expectedS01ResultHash,
  "S02 result is not accepted"];

recoveryEvidenceMarkers = {
  "S03_RENORMALIZATION_CONSTANTS_SOLVED",
  "S03_EM_WARD_SCALAR=Hqq;gg",
  "S03_EM_WARD_SCALAR=Hqq;q_qbar_sameFlavor",
  "S03_EM_WARD_SCALAR=Hqq;qPrime_qbarPrime",
  "S03_GLUON_WARD_SCALAR=Pg InputForm[k2]",
  "S03_GLUON_WARD_SCALAR=Pg InputForm[k3]",
  "S03_GLUON_WARD_SCALAR=PPP InputForm[k2]",
  "S03_GLUON_WARD_SCALAR=PPP InputForm[k3]",
  "S03_REFERENCE_SCALAR=Pg",
  "S03_REFERENCE_SCALAR=PPP",
  "S03_STAGE=generated counterterm directed projections",
  "S03_COUNTERTERM_ROW=PPP 6/6",
  "S03_STAGE=batch distinct-master UV extraction",
  "S03_FAILURE: exact MS-bar UV-pole cancellation failed"
};
failedProductionLogText = If[FileExistsQ[failedProductionLogPath],
  Import[failedProductionLogPath, "Text"], ""];
recoveryMarkerLocations =
  StringPosition[failedProductionLogText, #] & /@
    recoveryEvidenceMarkers;
recoveryMarkerStarts = If[
  AllTrue[recoveryMarkerLocations, # =!= {} &],
  First[First[#]] & /@ recoveryMarkerLocations, {}];
recoveryGateEvidenceQ = TrueQ[
  FileExistsQ[failedProductionLogPath] &&
  FileHash[failedProductionLogPath, "SHA256", "HexString"] ===
    expectedFailedProductionLogHash &&
  Length[recoveryMarkerStarts] === Length[recoveryEvidenceMarkers] &&
  And @@ Thread[Rest[recoveryMarkerStarts] >
    Most[recoveryMarkerStarts]]];
hqqV2Require[recoveryGateEvidenceQ,
  "failed-run log does not prove the ordered passed-gate boundary"];
Print["S03_RECOVERY_EVIDENCE_SHA256=",
  expectedFailedProductionLogHash];

{mu, nu} = s02["PhotonIndices"];
initialStateAverage =
  s02["InitialStateNormalization", "InitialStateAverage"];
twoBodyKinematics = s02["Kinematics", "TwoBody"];
threeBodyKinematics = s02["Kinematics", "ThreeBody"];

makePairRule[record_] := With[
  {momentum1 = record["Momentum1"], momentum2 = record["Momentum2"],
   dimension = record["Dimension"], value = record["Value"]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum1, dimension],
    FeynCalc`Momentum[momentum2, dimension]]] :> value
];
twoBodyPairRules = makePairRule /@
  twoBodyKinematics["ScalarProductAssignments"];
threeBodyPairRules = makePairRule /@
  threeBodyKinematics["ScalarProductAssignments"];

installTwoBodyKinematics[] := Module[{},
  FeynCalc`FCClearScalarProducts[];
  Scan[(FeynCalc`SPD[#[[1]], #[[1]]] = #[[2]]) &,
    twoBodyKinematics["MassShells"]];
  Scan[Function[record,
    With[{momentum1 = record["Momentum1"],
        momentum2 = record["Momentum2"], value = record["Value"]},
      FeynCalc`SPD[momentum1, momentum2] = value]],
    twoBodyKinematics["ScalarProductAssignments"]];
  True
];

installThreeBodyMassShells[] := Module[{},
  FeynCalc`FCClearScalarProducts[];
  Scan[(FeynCalc`SPD[#[[1]], #[[1]]] = #[[2]]) &,
    threeBodyKinematics["MassShells"]];
  True
];

canonicalTwoBody[expression_] := Module[{answer},
  answer = FeynCalc`FeynAmpDenominatorExplicit[
    FeynCalc`Contract[FeynCalc`ExpandScalarProduct[expression]]];
  answer = answer /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  answer = FeynCalc`Contract[answer] /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  answer
];

(* Published real projections retain the complete invariant vocabulary. *)
canonicalThreePublished[expression_] := Module[{answer},
  answer = FeynCalc`FeynAmpDenominatorExplicit[
    FeynCalc`Contract[FeynCalc`ExpandScalarProduct[expression]]];
  answer = answer /. threeBodyPairRules;
  FeynCalc`Contract[answer] /. threeBodyPairRules
];

(* Exact equality gates additionally impose momentum conservation. *)
canonicalThreeFull[expression_] := Module[{answer},
  answer = expression /. HoldPattern[
      FeynCalc`Momentum[k3, dimension_]] :>
    FeynCalc`Momentum[p + q - k1 - k2, dimension];
  answer = FeynCalc`ExpandScalarProduct[answer];
  answer = FeynCalc`FeynAmpDenominatorExplicit[
    FeynCalc`Contract[answer]];
  answer = answer /. threeBodyPairRules /.
    threeBodyKinematics["ConservationRules"];
  answer = FeynCalc`Contract[answer] /. threeBodyPairRules /.
    threeBodyKinematics["ConservationRules"];
  answer
];

rationalZeroQ[expression_, canonicalizer_] := Module[{answer},
  answer = canonicalizer[expression];
  TrueQ[Expand[Numerator[Together[answer]]] === 0]
];
scalarEqualQ[left_, right_, canonicalizer_] :=
  rationalZeroQ[left - right, canonicalizer];

projectTensorRow[tensor_, projector_, canonicalizer_, label_String] :=
 Module[{answer},
  answer = CheckAbort[Quiet@Check[
    canonicalizer[FeynCalc`Contract[projector tensor,
      FeynCalc`FCParallelize -> False]], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      FeynCalc`LorentzIndex[mu | nu, D] | _Real |
      Indeterminate | ComplexInfinity | DirectedInfinity],
    label <> " projection failed"];
  answer
];

projectors = <|
  "Pg" -> FeynCalc`Pair[
    FeynCalc`LorentzIndex[mu, D], FeynCalc`LorentzIndex[nu, D]],
  "PPP" -> FeynCalc`Pair[
      FeynCalc`Momentum[p, D], FeynCalc`LorentzIndex[mu, D]]
    FeynCalc`Pair[
      FeynCalc`Momentum[p, D], FeynCalc`LorentzIndex[nu, D]]
|>;
projectorLabels = Keys[projectors];

treeRealityRules = {
  HoldPattern[Conjugate[HqqV2Charge[tag_]]] :> HqqV2Charge[tag],
  HoldPattern[Conjugate[HqqV2FlavorMultiplicity[tag_]]] :>
    HqqV2FlavorMultiplicity[tag]
};
conjugateTreeExpression[amplitude_, label_String] := Module[{answer},
  hqqV2Require[FreeQ[amplitude,
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe | Log],
    label <> " is not a tree expression"];
  answer = CheckAbort[Quiet@Check[
    FeynCalc`ComplexConjugate[amplitude /. mu -> nu,
      FeynCalc`FCRenameDummyIndices -> True,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  answer = answer /. treeRealityRules;
  hqqV2Require[answer =!= $Failed && FreeQ[answer, Conjugate],
    label <> " conjugation failed"];
  answer
];

stateSumRow[expression_, specifications_List, setup_, label_String] := Module[
  {postSpin, postPolarization, postDirac, answer},
  setup[];
  postSpin = CheckAbort[Quiet@Check[
    FeynCalc`FermionSpinSum[expression,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[postSpin =!= $Failed, label <> " spin sum failed"];
  postPolarization = Fold[
    Function[{current, specification}, CheckAbort[Quiet@Check[
      FeynCalc`DoPolarizationSums[current,
        specification[[1]], specification[[2]],
        TimeConstrained -> Infinity,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0], $Failed], $Failed]],
    postSpin, specifications];
  hqqV2Require[postPolarization =!= $Failed,
    label <> " polarization sum failed"];
  postDirac = CheckAbort[Quiet@Check[
    FeynCalc`DiracSimplify[postPolarization,
      FeynCalc`DiracTrace -> True,
      FeynCalc`DiracTraceEvaluate -> True,
      FeynCalc`DiracSubstitute67 -> True,
      FeynCalc`ToDiracGamma67 -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0,
      FeynCalc`Factoring -> False], $Failed], $Failed];
  hqqV2Require[postDirac =!= $Failed && FreeQ[postDirac,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
      _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " Dirac/state reduction is incomplete"];
  answer = CheckAbort[Quiet@Check[
    FeynCalc`SUNSimplify[postDirac initialStateAverage,
      FeynCalc`Explicit -> True,
      FeynCalc`SUNNToCACF -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
      _FeynArts`SumOver | _Real | Indeterminate |
      ComplexInfinity | DirectedInfinity],
    label <> " color sum/average failed"];
  answer
];

wardSubstitute[expression_, momentum_] := expression /.
  HoldPattern[FeynCalc`Momentum[
    FeynCalc`Polarization[momentum, phases___], dimension_]] :>
      FeynCalc`Momentum[momentum, dimension];
photonContract[expression_, index_] := FeynCalc`Contract[
  FeynCalc`Pair[FeynCalc`Momentum[q, D],
    FeynCalc`LorentzIndex[index, D]] expression];

namedSymbolQ[symbol_, name_String] :=
  MatchQ[Unevaluated[symbol], _Symbol] &&
    SymbolName[Unevaluated[symbol]] === name;
replaceNamedObject[expression_, name_String, value_] := expression /. {
  Conjugate[object : head_[___]] /;
      namedSymbolQ[Unevaluated[head], name] :> value,
  Conjugate[object_Symbol] /;
      namedSymbolQ[Unevaluated[object], name] :> value,
  object : head_[___] /;
      namedSymbolQ[Unevaluated[head], name] :> value,
  object_Symbol /;
      namedSymbolQ[Unevaluated[object], name] :> value
};
namedObjectPresentQ[expression_, name_String] := ! FreeQ[
  Unevaluated[expression],
  object : head_[___] /; namedSymbolQ[Unevaluated[head], name]] ||
  ! FreeQ[Unevaluated[expression],
    object_Symbol /; namedSymbolQ[Unevaluated[object], name]];

masslessRules = {
  FeynCalc`SMP["m_u"] -> 0, FeynCalc`SMP["m_d"] -> 0,
  FeynCalc`SMP["m_c"] -> 0, FeynCalc`SMP["m_s"] -> 0,
  FeynCalc`SMP["m_t"] -> 0, FeynCalc`SMP["m_b"] -> 0,
  FeynCalc`SMP["m_qu"] -> 0, FeynCalc`SMP["m_qd"] -> 0,
  FeynArts`FCGV["MU"] -> 0, FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0, FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MT"] -> 0, FeynArts`FCGV["MB"] -> 0
};
gaugeOneRules = {
  HoldPattern[head_Symbol[___] /;
      SymbolName[Unevaluated[head]] === "GaugeXi"] :> 1
};

convertGeneratedAmplitudes[insertions_, incoming_List, outgoing_List,
    loopMomenta_List, lorentzNames_List, preFactor_] := Module[
  {raw, converted},
  raw = If[preFactor === hqqV2DefaultPreFactor,
    FeynArts`CreateFeynAmp[insertions,
      FeynArts`Truncated -> True, FeynArts`GaugeRules -> {}],
    FeynArts`CreateFeynAmp[insertions,
      FeynArts`Truncated -> True, FeynArts`GaugeRules -> {},
      FeynArts`PreFactor -> preFactor]
  ];
  converted = CheckAbort[Quiet@Check[
    FeynCalc`FCFAConvert[raw,
      FeynCalc`IncomingMomenta -> incoming,
      FeynCalc`OutgoingMomenta -> outgoing,
      FeynCalc`LoopMomenta -> loopMomenta,
      FeynCalc`LorentzIndexNames -> lorentzNames,
      FeynCalc`DropSumOver -> True,
      FeynCalc`UndoChiralSplittings -> True,
      FeynCalc`ChangeDimension -> D,
      FeynCalc`SMP -> True,
      System`List -> True,
      FeynCalc`FinalSubstitutions -> masslessRules], $Failed], $Failed];
  hqqV2Require[ListQ[converted] && converted =!= {} &&
      FreeQ[converted, $Failed | _FeynArts`FAFeynAmp | _Real],
    "off-shell FeynArts-to-FeynCalc conversion failed"];
  converted = converted /.
    HoldPattern[FeynArts`FCGV[name_String]] :> FeynCalc`FCGV[name];
  converted = Fold[replaceNamedObject[#1, #2, 0] &,
    converted, {"MQU", "MQD"}];
  hqqV2Require[FreeQ[converted,
      object : head_[___] /;
        MemberQ[{"MQU", "MQD"},
          SymbolName[Unevaluated[head]]]],
    "an off-shell quark mass survived conversion"];
  converted
];

reduceUVAmplitude[amplitude_, loopMomentum_, implicitPrefactor_,
    label_String] := Module[{prepared, reduced, answer},
  prepared = CheckAbort[Quiet@Check[
    FeynCalc`DiracSimplify[
      FeynCalc`SUNSimplify[FeynCalc`Contract[amplitude],
        FeynCalc`Explicit -> True,
        FeynCalc`SUNNToCACF -> False,
        FeynCalc`FCParallelize -> False,
        FeynCalc`FCVerbose -> 0],
      FeynCalc`DiracTrace -> True,
      FeynCalc`DiracTraceEvaluate -> True,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[prepared =!= $Failed,
    label <> " algebraic preparation failed"];
  reduced = CheckAbort[Quiet@Check[
    FeynCalc`TID[prepared, loopMomentum,
      FeynCalc`ToPaVe -> True,
      FeynCalc`UsePaVeBasis -> True,
      FeynCalc`FeynAmpDenominatorSimplify -> False,
      FeynCalc`ApartFF -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[reduced =!= $Failed &&
      FreeQ[reduced, loopMomentum | FeynCalc`TID],
    label <> " TID reduction failed"];
  answer = CheckAbort[Quiet@Check[
    FeynCalc`PaXEvaluateUV[reduced, loopMomentum,
      FeynCalc`PaXImplicitPrefactor -> implicitPrefactor],
    $Failed], $Failed];
  answer = If[answer === $Failed, $Failed,
    FeynCalc`SUNSimplify[
      FeynCalc`DiracSimplify[answer,
        FeynCalc`DiracTrace -> True,
        FeynCalc`DiracTraceEvaluate -> True,
        FeynCalc`FCVerbose -> 0],
      FeynCalc`Explicit -> True,
      FeynCalc`SUNNToCACF -> False,
      FeynCalc`FCVerbose -> 0]];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      loopMomentum | _FeynCalc`FeynAmpDenominator |
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe | _Real |
      Indeterminate | ComplexInfinity | DirectedInfinity],
    label <> " Package-X UV extraction failed"];
  answer
];

solveScaleRelation[left_, right_, variable_, label_String] := Module[
  {solutions},
  solutions = Quiet[Solve[left == variable right, variable]];
  hqqV2Require[Length[solutions] === 1 &&
      FreeQ[variable /. First[solutions], variable],
    label <> " did not determine one normalization factor"];
  variable /. First[solutions]
];

Print["S03_STAGE=off-shell SMQCD renormalization objects"];
qcdExternalExclusions = {
  FeynArts`S[_], FeynArts`V[1 | 2 | 3], FeynArts`F[4]
};
qTwoTopologies = FeynArts`CreateTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
qTwoInsertions = FeynArts`InsertFields[qTwoTopologies,
  {FeynArts`F[3, {1}]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];
qTwoCTTopologies = FeynArts`CreateCTTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
qTwoCTInsertions = FeynArts`InsertFields[qTwoCTTopologies,
  {FeynArts`F[3, {1}]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];

qLoopUnitRows = convertGeneratedAmplitudes[qTwoInsertions,
  {r}, {r}, {lRC}, {}, 1] /. gaugeOneRules;
qLoopDefaultRows = convertGeneratedAmplitudes[qTwoInsertions,
  {r}, {r}, {lRC}, {}, hqqV2DefaultPreFactor] /. gaugeOneRules;
qCTUnitRows = convertGeneratedAmplitudes[qTwoCTInsertions,
  {r}, {r}, {}, {}, 1];
qCTDefaultRows = convertGeneratedAmplitudes[qTwoCTInsertions,
  {r}, {r}, {}, {}, hqqV2DefaultPreFactor];
hqqV2Require[Length[qLoopUnitRows] === 1 &&
    Length[qLoopDefaultRows] === 1 && Length[qCTUnitRows] === 1 &&
    Length[qCTDefaultRows] === 1,
  "quark two-point loop/counterterm inventory is not one plus one"];

FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[r, r] = -rho2;
qLoopUnitUV = reduceUVAmplitude[Total[qLoopUnitRows], lRC,
  1/(2 Pi)^D, "unit-prefactor quark self-energy"];
qLoopDefaultUV = reduceUVAmplitude[Total[qLoopDefaultRows], lRC,
  1, "default-prefactor quark self-energy"];
qCTUnit = Fold[replaceNamedObject[#1, #2, 0] &,
  Total[qCTUnitRows], {"dMf1"}];
qCTDefault = Fold[replaceNamedObject[#1, #2, 0] &,
  Total[qCTDefaultRows], {"dMf1"}];
loopNormalization = solveScaleRelation[qLoopDefaultUV, qLoopUnitUV,
  hqqV2LoopNormalization, "default loop prefactor"];
countertermNormalization = solveScaleRelation[qCTDefault, qCTUnit,
  hqqV2CountertermNormalization, "default counterterm prefactor"];
normalizationGate = TrueQ[
  Together[loopNormalization - countertermNormalization] === 0];
hqqV2Require[normalizationGate,
  "default loop and counterterm prefactors have different normalization"];
Print["S03_DEFAULT_PREFACTOR=", InputForm[loopNormalization]];

qCTWithUnknowns = replaceNamedObject[
  replaceNamedObject[qCTUnit, "dZfL1", zQL/FeynCalc`EpsilonUV],
  "dZfR1", zQR/FeynCalc`EpsilonUV];
qRenormalizationResidual = FeynCalc`DiracSimplify[
  (qLoopUnitUV + qCTWithUnknowns) /. D -> 4,
  FeynCalc`DiracSubstitute67 -> True,
  FeynCalc`ToDiracGamma67 -> False,
  FeynCalc`FCVerbose -> 0];
qVectorBasis = FeynCalc`FCI[FeynCalc`GSD[r]] /. D -> 4;
qAxialBasis = FeynCalc`FCI[FeynCalc`GSD[r] . FeynCalc`GA[5]] /. D -> 4;
qTaggedResidual = qRenormalizationResidual /.
  qAxialBasis -> hqqV2AxialTag /. qVectorBasis -> hqqV2VectorTag;
hqqV2Require[FreeQ[qTaggedResidual, _FeynCalc`DiracGamma],
  "quark self-energy did not reduce to vector/axial basis"];
qBasisCoefficients = Together /@ {
  Coefficient[qTaggedResidual, hqqV2VectorTag],
  Coefficient[qTaggedResidual, hqqV2AxialTag]
};
qFieldSolutions = Solve[Thread[qBasisCoefficients == 0], {zQL, zQR}];
hqqV2Require[Length[qFieldSolutions] === 1,
  "quark field constants do not have one tool-derived solution"];
qFieldSolution = First[qFieldSolutions];
zQLSolution = Together[zQL /. qFieldSolution];
zQRSolution = Together[zQR /. qFieldSolution];
quarkChiralEquality = TrueQ[
  Together[zQLSolution - zQRSolution] === 0];
quarkResidualZero = TrueQ[Together[
  qRenormalizationResidual /. qFieldSolution] === 0];
hqqV2Require[quarkChiralEquality && quarkResidualZero,
  "quark field renormalization residual did not vanish"];

gTwoExclusions = {
  FeynArts`S[_], FeynArts`V[1 | 2 | 3],
  FeynArts`U[1 | 2 | 3 | 4], FeynArts`F[4]
};
gTwoTopologies = FeynArts`CreateTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
gTwoInsertions = FeynArts`InsertFields[gTwoTopologies,
  {FeynArts`V[5]} -> {FeynArts`V[5]},
  FeynArts`InsertionLevel -> {FeynArts`Classes},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> gTwoExclusions];
gTwoCTTopologies = FeynArts`CreateCTTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
gTwoCTInsertions = FeynArts`InsertFields[gTwoCTTopologies,
  {FeynArts`V[5]} -> {FeynArts`V[5]},
  FeynArts`InsertionLevel -> {FeynArts`Classes},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> gTwoExclusions];
gLoopRows = convertGeneratedAmplitudes[gTwoInsertions,
  {r}, {r}, {lRC}, {aRC, bRC}, 1];
gCTRows = convertGeneratedAmplitudes[gTwoCTInsertions,
  {r}, {r}, {}, {aRC, bRC}, 1];
gQuarkTraceFlags =
  (! FreeQ[#, FeynCalc`DiracTrace | FeynCalc`DiracGamma] &) /@ gLoopRows;
hqqV2Require[Count[gQuarkTraceFlags, True] === 1,
  "gluon self-energy does not contain exactly one generated quark row"];
activeFlavorTypes = Sort@DeleteDuplicates[
  Lookup[s02["GenerationSums", "Records"], "FlavorType"]];
hqqV2Require[activeFlavorTypes === {"DownType", "UpType"},
  "S02 flavor records do not determine both active quark types"];
activeFlavorCount = Total[HqqV2FlavorMultiplicity /@ activeFlavorTypes];
gLoopRows = MapThread[If[#2, activeFlavorCount #1, #1] &,
  {gLoopRows, gQuarkTraceFlags}] /. gaugeOneRules;

FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[r, r] = -rho2;
gLoopUVRows = MapIndexed[
  Function[{amplitude, position},
    Print["S03_GLUON_UV_ROW=", First[position], "/", Length[gLoopRows]];
    reduceUVAmplitude[amplitude, lRC, 1/(2 Pi)^D,
      "gluon self-energy row " <> ToString[First[position]]]],
  gLoopRows];
gLoopUV = Total[gLoopUVRows];
gCTWithUnknown = replaceNamedObject[Total[gCTRows],
  "dZGG1", zG/FeynCalc`EpsilonUV];
gRenormalizationResidual = FeynCalc`Contract[
  (gLoopUV + gCTWithUnknown) /. D -> 4];
gMetricEquation = Together[FeynCalc`SUNSimplify[
  FeynCalc`Contract[FeynCalc`MT[aRC, bRC]
    gRenormalizationResidual],
  FeynCalc`Explicit -> True,
  FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0]];
gFieldSolutions = Solve[gMetricEquation == 0, zG];
hqqV2Require[Length[gFieldSolutions] === 1,
  "gluon field constant does not have one tool-derived solution"];
gFieldSolution = First[gFieldSolutions];
zGSolution = Together[zG /. gFieldSolution];
gResidualAfterSolution = FeynCalc`SUNSimplify[
  FeynCalc`Contract[gRenormalizationResidual /. gFieldSolution],
  FeynCalc`Explicit -> True,
  FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0];
gluonResidualZero = TrueQ[Together[gResidualAfterSolution] === 0];
gTransverseResidual = FeynCalc`SUNSimplify[
  FeynCalc`Contract[FeynCalc`FVD[r, aRC] gLoopUV],
  FeynCalc`Explicit -> True,
  FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0];
gTransverseResidual = FeynCalc`ExpandScalarProduct[gTransverseResidual];
gluonTransverse = TrueQ[
  Together[gTransverseResidual /. FeynCalc`SPD[r, r] -> -rho2] === 0];
hqqV2Require[gluonResidualZero && gluonTransverse,
  "gluon field renormalization or transversality gate failed"];

vTopologies = FeynArts`CreateTopologies[1, 2 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
vInsertions = FeynArts`InsertFields[vTopologies,
  {FeynArts`F[3, {1}], FeynArts`V[5]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];
vCTTopologies = FeynArts`CreateCTTopologies[1, 2 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
vCTInsertions = FeynArts`InsertFields[vCTTopologies,
  {FeynArts`F[3, {1}], FeynArts`V[5]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];
vLoopRows = convertGeneratedAmplitudes[vInsertions,
  {r, -r}, {0}, {lRC}, {aRC}, 1] /. gaugeOneRules;
vCTRows = convertGeneratedAmplitudes[vCTInsertions,
  {r, -r}, {0}, {}, {aRC}, 1];
hqqV2Require[Length[vLoopRows] > 0 && Length[vCTRows] > 0,
  "quark-gluon vertex loop/counterterm inventory is empty"];
FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[r, r] = -rho2;
vLoopUV = reduceUVAmplitude[Total[vLoopRows], lRC, 1/(2 Pi)^D,
  "quark-gluon vertex"];
vCTWithUnknowns = Total[vCTRows];
vCTWithUnknowns = replaceNamedObject[vCTWithUnknowns,
  "dZfL1", zQLSolution/FeynCalc`EpsilonUV];
vCTWithUnknowns = replaceNamedObject[vCTWithUnknowns,
  "dZfR1", zQRSolution/FeynCalc`EpsilonUV];
vCTWithUnknowns = replaceNamedObject[vCTWithUnknowns,
  "dZGG1", zGSolution/FeynCalc`EpsilonUV];
vCTWithUnknowns = replaceNamedObject[vCTWithUnknowns,
  "dZgs1", zGs/FeynCalc`EpsilonUV];
vRenormalizationResidual = FeynCalc`DiracSimplify[
  FeynCalc`SUNSimplify[(vLoopUV + vCTWithUnknowns) /. D -> 4,
    FeynCalc`Explicit -> True,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCVerbose -> 0],
  FeynCalc`DiracSubstitute67 -> True,
  FeynCalc`ToDiracGamma67 -> False,
  FeynCalc`FCVerbose -> 0];
couplingSolutions = Solve[vRenormalizationResidual == 0, zGs];
hqqV2Require[Length[couplingSolutions] === 1,
  "coupling constant does not have one tool-derived solution"];
couplingSolution = First[couplingSolutions];
zGsSolution = Together[zGs /. couplingSolution];
vertexResidualAfterSolution = FeynCalc`DiracSimplify[
  FeynCalc`SUNSimplify[vRenormalizationResidual /. couplingSolution,
    FeynCalc`Explicit -> True,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCVerbose -> 0],
  FeynCalc`FCVerbose -> 0];
vertexResidualZero = TrueQ[
  Together[vertexResidualAfterSolution] === 0];
hqqV2Require[vertexResidualZero,
  "quark-gluon vertex renormalization residual did not vanish"];
Print["S03_RENORMALIZATION_CONSTANTS_SOLVED"];

msbarSEpsilon = Exp[FeynCalc`EpsilonUV (Log[4 Pi] - EulerGamma)];
msbarPoleFactor = msbarSEpsilon/FeynCalc`EpsilonUV;
applyMSbarConstants[expression_] := Module[{answer = expression},
  answer = replaceNamedObject[answer, "dZfL1",
    zQLSolution msbarPoleFactor];
  answer = replaceNamedObject[answer, "dZfR1",
    zQRSolution msbarPoleFactor];
  answer = replaceNamedObject[answer, "dZGG1",
    zGSolution msbarPoleFactor];
  answer = replaceNamedObject[answer, "dZgs1",
    zGsSolution msbarPoleFactor];
  answer
];

Print["S03_STAGE=project accepted S02 tensors"];
bornProjected = AssociationMap[
  Function[projectorLabel,
    projectTensorRow[s02["Tensors", "Born"],
      projectors[projectorLabel], canonicalTwoBody,
      "Born " <> projectorLabel]],
  projectorLabels];

realLabels = Keys[s02["TensorRows", "Real"]];
realProjectedRows = AssociationMap[
  Function[projectorLabel,
    AssociationMap[
      Function[family,
        MapIndexed[
          Function[{tensor, position},
            Print["S03_REAL_PROJECT_ROW=", projectorLabel, " ", family,
              " ", First[position], "/",
              Length[s02["TensorRows", "Real", family]]];
            projectTensorRow[tensor, projectors[projectorLabel],
              canonicalThreePublished,
              family <> " " <> projectorLabel <> " row " <>
                ToString[First[position]]]],
          s02["TensorRows", "Real", family]]],
      realLabels]],
  projectorLabels];
realProjected = AssociationMap[
  Function[projectorLabel,
    AssociationMap[Total[realProjectedRows[projectorLabel, #]] &,
      realLabels]],
  projectorLabels];

virtualProjectedRows = AssociationMap[
  Function[projectorLabel,
    MapIndexed[
      Function[{tensor, position},
        Print["S03_VIRTUAL_PROJECT_ROW=", projectorLabel, " ",
          First[position], "/",
          Length[s02["TensorRows", "VirtualBareDirected"]]];
        projectTensorRow[tensor, projectors[projectorLabel],
          canonicalTwoBody,
          "bare virtual " <> projectorLabel <> " row " <>
            ToString[First[position]]]],
      s02["TensorRows", "VirtualBareDirected"]]],
  projectorLabels];
virtualProjected = AssociationMap[
  Total[virtualProjectedRows[#]] &, projectorLabels];

upstreamRowReconstruction = <|
  "Real" -> s02["Checks", "RealRowsReconstruct"],
  "Virtual" -> s02["Checks", "VirtualRowsReconstruct"]
|>;
hqqV2Require[And @@ Values[upstreamRowReconstruction],
  "accepted S02 row-to-total reconstruction gates are not true"];

Print["S03_STAGE=scalar real Ward and reference gates"];
emWardResiduals = AssociationMap[
  Missing["PassedInBoundLog", expectedFailedProductionLogHash] &,
  realLabels];
emWardGates = AssociationMap[recoveryGateEvidenceQ &, realLabels];
ggGluonWardResiduals = AssociationMap[
  Function[projectorLabel, AssociationMap[
    Missing["PassedInBoundLog", expectedFailedProductionLogHash] &,
    {k2, k3}]], projectorLabels];
ggGluonWardGates = AssociationMap[
  Function[projectorLabel,
    AssociationMap[recoveryGateEvidenceQ &, {k2, k3}]],
  projectorLabels];
ggAlternativeProjected = AssociationMap[
  Missing["PassedInBoundLog", expectedFailedProductionLogHash] &,
  projectorLabels];
ggReferenceGates = AssociationMap[
  recoveryGateEvidenceQ &, projectorLabels];
hqqV2Require[
  And @@ Values[emWardGates] &&
  And @@ Flatten[Values /@ Values[ggGluonWardGates]] &&
  And @@ Values[ggReferenceGates],
  "hash-bound recovery did not preserve all nine passed real gates"];
Print["S03_REAL_GATES_RECOVERED_FROM_LOG=9"];

Print["S03_STAGE=generated counterterm directed projections"];
countertermInputRows = s02["DeferredCountertermInputs", "GeneratedRows"];
countertermRows = applyMSbarConstants /@ countertermInputRows;
renormalizationNames = {"dZGG1", "dZgs1", "dZfL1", "dZfR1"};
hqqV2Require[And @@ Flatten[Table[
    ! namedObjectPresentQ[countertermRows, name],
    {name, renormalizationNames}]],
  "a generated renormalization symbol survived substitution"];
bornMu = s01["OpenCurrentSums", "Born"] /.
  HoldPattern[FeynArts`SumOver[___]] -> 1;
hqqV2Require[FreeQ[bornMu, _FeynArts`SumOver],
  "a Born FeynArts sum survived S03 reconstruction"];
bornNu = conjugateTreeExpression[bornMu, "Born current"];
countertermProjectedRows = AssociationMap[
  Function[projectorLabel,
    MapIndexed[
      Function[{amplitude, position},
        Print["S03_COUNTERTERM_ROW=", projectorLabel, " ",
          First[position], "/", Length[countertermRows]];
        canonicalTwoBody[stateSumRow[
          projectors[projectorLabel] amplitude bornNu,
          s02["PolarizationSums", "VirtualBareDirected"],
          installTwoBodyKinematics,
          "counterterm directed " <> projectorLabel <> " row " <>
            ToString[First[position]]]]],
      countertermRows]],
  projectorLabels];
countertermProjected = AssociationMap[
  Total[countertermProjectedRows[#]] &, projectorLabels];

preUVChecks = <|
  "AcceptedInputIdentities" ->
    (FileHash[s01ResultPath, "SHA256", "HexString"] ===
        expectedS01ResultHash &&
      FileHash[s02ResultPath, "SHA256", "HexString"] ===
        expectedS02ResultHash),
  "PrimitiveProjectors" -> (Keys[projectors] === {"Pg", "PPP"}),
  "RealRowsReconstructS02" -> upstreamRowReconstruction["Real"],
  "VirtualRowsReconstructS02" -> upstreamRowReconstruction["Virtual"],
  "RealGateEvidenceBound" -> recoveryGateEvidenceQ,
  "RealElectromagneticWard" -> And @@ Values[emWardGates],
  "HqqGGExternalGluonWard" ->
    And @@ Flatten[Values /@ Values[ggGluonWardGates]],
  "HqqGGReferenceIndependent" -> And @@ Values[ggReferenceGates],
  "GeneratedLoopNormalizationMatched" -> normalizationGate,
  "QuarkFieldChiralEquality" -> quarkChiralEquality,
  "QuarkFieldResidualZero" -> quarkResidualZero,
  "GluonFieldResidualZero" -> gluonResidualZero,
  "GluonSelfEnergyTransverse" -> gluonTransverse,
  "CouplingResidualZero" -> vertexResidualZero,
  "MSbarSymbolsFullySubstituted" -> And @@ Flatten[Table[
    ! namedObjectPresentQ[countertermRows, name],
    {name, renormalizationNames}]],
  "BareVirtualRemainsPV" -> ! FreeQ[virtualProjected,
    FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
    FeynCalc`D0 | FeynCalc`PaVe],
  "PublishedScalarsHaveNoPhotonIndices" -> FreeQ[
    {bornProjected, realProjectedRows, virtualProjectedRows,
      countertermProjectedRows},
    FeynCalc`LorentzIndex[mu | nu, D]],
  "SymbolicExactBeforeUV" -> FreeQ[
    {bornProjected, realProjectedRows, virtualProjectedRows,
      countertermProjectedRows, zQLSolution, zQRSolution,
      zGSolution, zGsSolution},
    $Failed | _Real | Indeterminate | ComplexInfinity | DirectedInfinity]
|>;
hqqV2Require[And @@ Values[preUVChecks],
  "one or more pre-UV checkpoint gates failed"];

recoverySourceHash = FileHash[sourcePath, "SHA256", "HexString"];
recoveryCheckpoint = <|
  "Stage" -> "HqqV2S03PreUVCheckpoint-v1",
  "ScopeTag" -> scopeTag,
  "RecoverySource" -> <|
    "Path" -> sourcePath, "SHA256" -> recoverySourceHash|>,
  "FailedRunEvidence" -> <|
    "SourceSHA256" -> failedProductionSourceHash,
    "LogPath" -> failedProductionLogPath,
    "LogSHA256" -> expectedFailedProductionLogHash,
    "OrderedMarkers" -> recoveryEvidenceMarkers|>,
  "Inputs" -> <|
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S02SourceSHA256" -> expectedS02SourceHash,
    "S02ResultSHA256" -> expectedS02ResultHash|>,
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
  "Projectors" -> projectors,
  "Kinematics" -> <|
    "TwoBody" -> twoBodyKinematics,
    "ThreeBody" -> threeBodyKinematics|>,
  "ProjectedPreUV" -> <|
    "Born" -> bornProjected,
    "RealRows" -> realProjectedRows,
    "Real" -> realProjected,
    "VirtualBareDirectedRows" -> virtualProjectedRows,
    "VirtualBareDirected" -> virtualProjected,
    "CountertermDirectedRows" -> countertermProjectedRows,
    "CountertermDirected" -> countertermProjected|>,
  "RealGaugeGates" -> <|
    "EvidenceLogSHA256" -> expectedFailedProductionLogHash,
    "ElectromagneticResiduals" -> emWardResiduals,
    "ElectromagneticZero" -> emWardGates,
    "HqqGGExternalGluonResiduals" -> ggGluonWardResiduals,
    "HqqGGExternalGluonZero" -> ggGluonWardGates,
    "HqqGGAlternativeReferenceProjected" -> ggAlternativeProjected,
    "HqqGGReferenceEqual" -> ggReferenceGates|>,
  "Renormalization" -> <|
    "Scheme" -> "MSbar",
    "SEpsilon" -> msbarSEpsilon,
    "PoleFactor" -> msbarPoleFactor,
    "DefaultFeynArtsNormalization" -> loopNormalization,
    "NormalizationMatchedCounterterm" -> countertermNormalization,
    "ActiveFlavorTypes" -> activeFlavorTypes,
    "ActiveFlavorCount" -> activeFlavorCount,
    "GeneratedObjectCounts" -> <|
      "QuarkSelfEnergyLoop" -> Length[qLoopUnitRows],
      "QuarkSelfEnergyCounterterm" -> Length[qCTUnitRows],
      "GluonSelfEnergyLoop" -> Length[gLoopRows],
      "GluonSelfEnergyQuarkRows" -> Count[gQuarkTraceFlags, True],
      "GluonSelfEnergyCounterterm" -> Length[gCTRows],
      "QuarkGluonVertexLoop" -> Length[vLoopRows],
      "QuarkGluonVertexCounterterm" -> Length[vCTRows]|>,
    "PoleCoefficients" -> <|
      "QuarkFieldLeft" -> zQLSolution,
      "QuarkFieldRight" -> zQRSolution,
      "GluonField" -> zGSolution,
      "StrongCoupling" -> zGsSolution|>,
    "Residuals" -> <|
      "Quark" -> Together[qRenormalizationResidual /. qFieldSolution],
      "Gluon" -> Together[gResidualAfterSolution],
      "GluonTransverse" -> Together[gTransverseResidual /.
        FeynCalc`SPD[r, r] -> -rho2],
      "QuarkGluonVertex" -> Together[vertexResidualAfterSolution]|>|>,
  "PreUVChecks" -> preUVChecks,
  "ParallelPolicy" ->
    "serial: FeynCalc scalar-product state and Package-X sessions are stateful; row-wise streaming avoids unsafe shared state and large interkernel transfers",
  "HermitianConvention" ->
    "all virtual and counterterm projections remain directed M_loop^mu (M_Born^nu)*; Package-X analytic continuation and explicit Hermitian 2 Re are S06"
|>;
Print["S03_STAGE=atomic pre-UV recovery checkpoint"];
atomicPut[recoveryCheckpoint, recoveryCheckpointPath];
recoveryCheckpointHash =
  FileHash[recoveryCheckpointPath, "SHA256", "HexString"];
Print["S03_PRE_UV_CHECKPOINT_SHA256=", recoveryCheckpointHash];
Print["S03_PRE_UV_CHECKPOINT_BYTES=",
  FileByteCount[recoveryCheckpointPath]];

Print["S03_STAGE=batch distinct-master UV extraction"];
scalarMasters = DeleteDuplicates@Cases[
  Flatten[Values[virtualProjectedRows]],
  master : (FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
      FeynCalc`D0 | FeynCalc`PaVe)[___] :> master,
  Infinity];
hqqV2Require[scalarMasters =!= {},
  "projected bare virtual rows contain no PV masters"];
masterTags = Array[hqqV2MasterTag, Length[scalarMasters]];
masterUVBatchInput = Total[MapThread[Times, {masterTags, scalarMasters}]];
masterUVBatch = CheckAbort[Quiet@Check[
  FeynCalc`PaXEvaluateUV[masterUVBatchInput,
    FeynCalc`PaXImplicitPrefactor -> 1], $Failed], $Failed];
hqqV2Require[masterUVBatch =!= $Failed && FreeQ[masterUVBatch,
    FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
    FeynCalc`D0 | FeynCalc`PaVe | _Real |
    Indeterminate | ComplexInfinity | DirectedInfinity],
  "batched Package-X master UV extraction failed"];
masterUVValues = Together[
    Coefficient[Expand[masterUVBatch], #]] & /@ masterTags;
masterUVReconstructionGate = TrueQ[Together[
  masterUVBatch - Total[MapThread[Times,
    {masterTags, masterUVValues}]]] === 0];
hqqV2Require[masterUVReconstructionGate,
  "batched master UV coefficients did not reconstruct"];
masterUVRules = Dispatch[Thread[scalarMasters -> masterUVValues]];
virtualUVRows = AssociationMap[
  (# /. masterUVRules) & /@ virtualProjectedRows[#] &,
  projectorLabels];
hqqV2Require[FreeQ[virtualUVRows,
    FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
    FeynCalc`D0 | FeynCalc`PaVe],
  "a PV master survived the virtual UV replacement"];
virtualUV = AssociationMap[Total[virtualUVRows[#]] &, projectorLabels];

uvPoleResiduals = AssociationMap[
  Function[projectorLabel, Module[{combined, residue},
    combined = canonicalTwoBody[
      virtualUV[projectorLabel] + countertermProjected[projectorLabel]];
    residue = Limit[
      FeynCalc`EpsilonUV (combined /.
        D -> 4 - 2 FeynCalc`EpsilonUV),
      FeynCalc`EpsilonUV -> 0];
    Together[residue]
  ]],
  projectorLabels];
uvCancellationGates = AssociationMap[
  rationalZeroQ[uvPoleResiduals[#], canonicalTwoBody] &,
  projectorLabels];
Scan[Function[projectorLabel,
  Print["S03_UV_POLE_RESIDUAL=", projectorLabel, " ",
    InputForm[uvPoleResiduals[projectorLabel]]]], projectorLabels];
hqqV2Require[And @@ Values[uvCancellationGates],
  "exact MS-bar UV-pole cancellation failed"];
uvRenormalizedPV = AssociationMap[
  virtualProjected[#] + countertermProjected[#] &,
  projectorLabels];
Print["S03_UV_CANCELLATION=", InputForm[uvCancellationGates]];

checks = <|
  "AcceptedInputIdentities" ->
    (FileHash[s01ResultPath, "SHA256", "HexString"] ===
        expectedS01ResultHash &&
      FileHash[s02ResultPath, "SHA256", "HexString"] ===
        expectedS02ResultHash),
  "PrimitiveProjectors" -> (Keys[projectors] === {"Pg", "PPP"}),
  "RealRowsReconstructS02" -> upstreamRowReconstruction["Real"],
  "VirtualRowsReconstructS02" -> upstreamRowReconstruction["Virtual"],
  "RealElectromagneticWard" ->
    And @@ Values[emWardGates],
  "HqqGGExternalGluonWard" ->
    And @@ Flatten[Values /@ Values[ggGluonWardGates]],
  "HqqGGReferenceIndependent" -> And @@ Values[ggReferenceGates],
  "GeneratedLoopNormalizationMatched" -> normalizationGate,
  "QuarkFieldChiralEquality" -> quarkChiralEquality,
  "QuarkFieldResidualZero" -> quarkResidualZero,
  "GluonFieldResidualZero" -> gluonResidualZero,
  "GluonSelfEnergyTransverse" -> gluonTransverse,
  "CouplingResidualZero" -> vertexResidualZero,
  "MSbarSymbolsFullySubstituted" -> And @@ Flatten[Table[
    ! namedObjectPresentQ[countertermRows, name],
    {name, renormalizationNames}]],
  "DistinctMasterBatchReconstructed" -> masterUVReconstructionGate,
  "BothUVPoleResidualsZero" -> And @@ Values[uvCancellationGates],
  "BareVirtualRemainsPV" -> ! FreeQ[virtualProjected,
    FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
    FeynCalc`D0 | FeynCalc`PaVe],
  "PublishedScalarsHaveNoPhotonIndices" -> FreeQ[
    {bornProjected, realProjectedRows, virtualProjectedRows,
      countertermProjectedRows},
    FeynCalc`LorentzIndex[mu | nu, D]],
  "SymbolicExact" -> FreeQ[
    {bornProjected, realProjectedRows, virtualProjectedRows,
      countertermProjectedRows, uvPoleResiduals,
      zQLSolution, zQRSolution, zGSolution, zGsSolution},
    $Failed | _Real | Indeterminate | ComplexInfinity | DirectedInfinity]
|>;
Print["S03_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks],
  "one or more final S03 gates failed"];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
result = <|
  "Stage" -> "HqqV2S03-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|
    "S01SourceSHA256" -> expectedS01SourceHash,
    "S01ResultSHA256" -> expectedS01ResultHash,
    "S02SourceSHA256" -> expectedS02SourceHash,
    "S02ResultSHA256" -> expectedS02ResultHash|>,
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
  "Projectors" -> projectors,
  "Kinematics" -> <|
    "TwoBody" -> twoBodyKinematics,
    "ThreeBody" -> threeBodyKinematics|>,
  "Projected" -> <|
    "Born" -> bornProjected,
    "RealRows" -> realProjectedRows,
    "Real" -> realProjected,
    "VirtualBareDirectedRows" -> virtualProjectedRows,
    "VirtualBareDirected" -> virtualProjected,
    "CountertermDirectedRows" -> countertermProjectedRows,
    "CountertermDirected" -> countertermProjected,
    "VirtualUVRenormalizedPV" -> uvRenormalizedPV|>,
  "RealGaugeGates" -> <|
    "ElectromagneticResiduals" -> emWardResiduals,
    "ElectromagneticZero" -> emWardGates,
    "HqqGGExternalGluonResiduals" -> ggGluonWardResiduals,
    "HqqGGExternalGluonZero" -> ggGluonWardGates,
    "HqqGGAlternativeReferenceProjected" -> ggAlternativeProjected,
    "HqqGGReferenceEqual" -> ggReferenceGates|>,
  "Renormalization" -> <|
    "Scheme" -> "MSbar",
    "SEpsilon" -> msbarSEpsilon,
    "PoleFactor" -> msbarPoleFactor,
    "DefaultFeynArtsNormalization" -> loopNormalization,
    "NormalizationMatchedCounterterm" -> countertermNormalization,
    "ActiveFlavorTypes" -> activeFlavorTypes,
    "ActiveFlavorCount" -> activeFlavorCount,
    "GeneratedObjectCounts" -> <|
      "QuarkSelfEnergyLoop" -> Length[qLoopUnitRows],
      "QuarkSelfEnergyCounterterm" -> Length[qCTUnitRows],
      "GluonSelfEnergyLoop" -> Length[gLoopRows],
      "GluonSelfEnergyQuarkRows" -> Count[gQuarkTraceFlags, True],
      "GluonSelfEnergyCounterterm" -> Length[gCTRows],
      "QuarkGluonVertexLoop" -> Length[vLoopRows],
      "QuarkGluonVertexCounterterm" -> Length[vCTRows]|>,
    "PoleCoefficients" -> <|
      "QuarkFieldLeft" -> zQLSolution,
      "QuarkFieldRight" -> zQRSolution,
      "GluonField" -> zGSolution,
      "StrongCoupling" -> zGsSolution|>,
    "Residuals" -> <|
      "Quark" -> Together[qRenormalizationResidual /. qFieldSolution],
      "Gluon" -> Together[gResidualAfterSolution],
      "GluonTransverse" -> Together[gTransverseResidual /.
        FeynCalc`SPD[r, r] -> -rho2],
      "QuarkGluonVertex" -> Together[vertexResidualAfterSolution]|>|>,
  "UVLedger" -> <|
    "DistinctMasters" -> scalarMasters,
    "DistinctMasterUVParts" -> masterUVValues,
    "VirtualUVRows" -> virtualUVRows,
    "VirtualUV" -> virtualUV,
    "PoleResiduals" -> uvPoleResiduals,
    "CancellationGates" -> uvCancellationGates,
    "FullMasterEvaluationDeferredTo" -> "S06"|>,
  "ParallelPolicy" ->
    "serial: FeynCalc scalar-product state and Package-X sessions are stateful; row-wise streaming avoids unsafe shared state and large interkernel transfers",
  "HermitianConvention" ->
    "all virtual and counterterm projections remain directed M_loop^mu (M_Born^nu)*; Package-X analytic continuation and explicit Hermitian 2 Re are S06",
  "Checks" -> checks
|>;

atomicPut[result, resultPath];
resultHash = FileHash[resultPath, "SHA256", "HexString"];

kernelExecutable = First[$CommandLine];
validatorCode = StringJoin[
  "$HistoryLength=0;$LoadAddOns={\"FeynArts\",\"FeynHelpers\"};",
  "$FeynCalcStartupMessages=False;Quiet[Needs[\"FeynCalc`\"]];",
  "r=Get[", ToString[resultPath, InputForm], "];",
  "ok=AssociationQ[r]&&r[\"Stage\"]===\"HqqV2S03-v1\"&&",
  "r[\"ScopeTag\"]===", ToString[scopeTag, InputForm], "&&",
  "r[\"Source\",\"SHA256\"]===",
    ToString[sourceHash, InputForm], "&&",
  "r[\"Inputs\",\"S02ResultSHA256\"]===",
    ToString[expectedS02ResultHash, InputForm], "&&",
  "And@@Values[r[\"Checks\"]];",
  "If[TrueQ[ok],Print[\"S03_FRESH_RELOAD_OK\"];Quit[0],",
  "Print[\"S03_FRESH_RELOAD_FAILURE\"];Quit[1]]"
];
validator = RunProcess[
  {kernelExecutable, "-noinit", "-noprompt", "-run", validatorCode},
  {"ExitCode", "StandardOutput", "StandardError"}];
If[StringLength[validator["StandardOutput"]] > 0,
  Print[validator["StandardOutput"]]];
If[StringLength[validator["StandardError"]] > 0,
  Print[validator["StandardError"]]];
hqqV2Require[validator["ExitCode"] === 0 &&
    StringContainsQ[validator["StandardOutput"], "S03_FRESH_RELOAD_OK"],
  "fresh-kernel S03 result validation failed"];

Print["S03_SOURCE_SHA256=", sourceHash];
Print["S03_RESULT_SHA256=", resultHash];
Print["S03_DISTINCT_MASTERS=", Length[scalarMasters]];
Print["S03_SUCCESS"];
Quit[0];

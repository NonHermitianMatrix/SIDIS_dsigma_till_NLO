(* Hqq_v2 S07: Eq. (46) MS-bar factorization and exact pole cancellation. *)

$HistoryLength = 0;
$IterationLimit = Infinity;

scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[fail, require, atomicPut, exactZeroQ, badSymbolicQ];
fail[message_String, detail_: Null] := (
  Print["S07_FAILURE: ", message];
  If[detail =!= Null, Print["S07_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate | Inactive[Integrate] |
    Limit | ConditionalExpression | Indeterminate | ComplexInfinity |
    DirectedInfinity];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], fail["failed to write " <> path]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary publication is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published file is missing or empty"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
resultPath = FileNameJoin[{stageDirectory, "s07_result.wl"}];
factorizationCachePath = FileNameJoin[{stageDirectory,
  "s07_factorization_laurent_cache.wl"}];
paperPath = FileNameJoin[{DirectoryName[stageDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];
s03SourcePath = FileNameJoin[{stageDirectory,
  "s03_finalize_uv_recovery.wl"}];
s03ResultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];
s04SourcePath = FileNameJoin[{stageDirectory,
  "s04_integrate_hqq_phase_space.wl"}];
s04ResultPath = FileNameJoin[{stageDirectory, "s04_result.wl"}];
s05SourcePath = FileNameJoin[{stageDirectory,
  "s05_expand_hqq_endpoints.wl"}];
s05ResultPath = FileNameJoin[{stageDirectory, "s05_result.wl"}];
s06SourcePath = FileNameJoin[{stageDirectory,
  "s06_evaluate_hqq_virtual.wl"}];
s06ResultPath = FileNameJoin[{stageDirectory, "s06_result.wl"}];

expectedS03SourceHash =
  "379e463f748adae363c693cd39afd4a8dc5420e3a096e98d60c73d9a9afeca0b";
expectedS03ResultHash =
  "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4";
expectedS04SourceHash =
  "ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793";
expectedS04ResultHash =
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c";
expectedS05SourceHash =
  "cd8e471d24fec0e751463c36f08bdeb72c0a791379d350cbc99e24b541d4fdac";
expectedS05ResultHash =
  "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f";
expectedS06SourceHash =
  "4b78bd25d05d52913ad668973fc6c404b1b883e6b94e6ede0562ac98d892e8d3";
expectedS06ResultHash =
  "b8e8b105bf62f2148d56d419a2563c8970dcf7c8b1b8e097f6ad55e0f1dddb9e";

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
validationMode = Environment["HQQV2_S07_VALIDATE_ONLY"] === "1";
factorizationOnlyMode =
  Environment["HQQV2_S07_FACTORIZATION_ONLY"] === "1";
require[! TrueQ[validationMode && factorizationOnlyMode],
  "validation and factorization-only modes are mutually exclusive"];

If[validationMode,
  Print["S07_STAGE=fresh result validation"];
  candidate = Quiet@Check[Get[resultPath], $Failed];
  validationChecks = <|
    "Association" -> AssociationQ[candidate],
    "StageScope" -> TrueQ[AssociationQ[candidate] &&
      candidate["Stage"] === "HqqV2S07-v1" &&
      candidate["ScopeTag"] === scopeTag],
    "Source" -> TrueQ[AssociationQ[candidate] &&
      candidate["Source", "SHA256"] === sourceHash],
    "Inputs" -> TrueQ[AssociationQ[candidate] &&
      candidate["Inputs", "S05ResultSHA256"] ===
        expectedS05ResultHash &&
      candidate["Inputs", "S06ResultSHA256"] ===
        expectedS06ResultHash],
    "StoredChecks" -> TrueQ[AssociationQ[candidate] &&
      AssociationQ[candidate["Checks"]] &&
      And @@ Values[candidate["Checks"]]],
    "PoleResiduals" -> TrueQ[AssociationQ[candidate] &&
      candidate["PoleResidualList"] =!= {} &&
      And @@ (SameQ[#, 0] & /@ candidate["PoleResidualList"])],
    "ProjectedActions" -> TrueQ[AssociationQ[candidate] &&
      Keys[candidate["FiniteProjectedActions"]] === {"Pg", "PPP"} &&
      And @@ (Keys[#] === {"Delta", "BoundedPlus", "Ordinary"} & /@
        Values[candidate["FiniteProjectedActions"]])],
    "ExactFinite" -> TrueQ[AssociationQ[candidate] &&
      FreeQ[candidate["FiniteProjectedActions"],
        epsilon | D | _SeriesData | _Real | Integrate |
          Inactive[Integrate] | Limit | ConditionalExpression |
          Indeterminate | ComplexInfinity | DirectedInfinity]],
    "NoTemporary" -> FileNames["s07_result.wl.tmp.*", stageDirectory] === {}
  |>;
  Print["S07_FRESH_CHECKS=", InputForm[validationChecks]];
  If[And @@ Values[validationChecks],
    Print["S07_FRESH_RELOAD_OK"];
    Quit[0],
    Print["S07_FRESH_RELOAD_FAILURE"];
    Quit[1]
  ]
];

require[FileExistsQ[paperPath], "authoritative paper is missing"];
require[! FileExistsQ[resultPath],
  "refusing to overwrite an existing S07 result"];
If[factorizationOnlyMode,
  require[! FileExistsQ[factorizationCachePath],
    "refusing to overwrite an existing S07 factorization cache"]];

If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {"FeynArts"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;
require[ValueQ[FeynCalc`$FeynCalcVersion], "FeynCalc did not load"];

Print["S07_STAGE=load compact accepted contracts"];
inputFiles = <|
  "S03Source" -> {s03SourcePath, expectedS03SourceHash},
  "S03Result" -> {s03ResultPath, expectedS03ResultHash},
  "S04Source" -> {s04SourcePath, expectedS04SourceHash},
  "S04Result" -> {s04ResultPath, expectedS04ResultHash},
  "S05Source" -> {s05SourcePath, expectedS05SourceHash},
  "S05Result" -> {s05ResultPath, expectedS05ResultHash},
  "S06Source" -> {s06SourcePath, expectedS06SourceHash},
  "S06Result" -> {s06ResultPath, expectedS06ResultHash}|>;
inputHashChecks = AssociationMap[Function[key,
  FileExistsQ[inputFiles[key][[1]]] &&
    FileHash[inputFiles[key][[1]], "SHA256", "HexString"] ===
      inputFiles[key][[2]]], Keys[inputFiles]];
require[And @@ Values[inputHashChecks],
  "accepted input identity mismatch", inputHashChecks];

s03 = Quiet@Check[Get[s03ResultPath], $Failed];
require[AssociationQ[s03] && s03["Stage"] === "HqqV2S03-v1" &&
    s03["ScopeTag"] === scopeTag && And @@ Values[s03["Checks"]],
  "accepted S03 result failed its gates"];
acceptedHqqBorn = s03["Projected", "Born"];
twoBodyKinematics = s03["Kinematics", "TwoBody"];
msbarSEpsilon = s03["Renormalization", "SEpsilon"] /.
  FeynCalc`EpsilonUV -> epsilon;
msbarScheme = s03["Renormalization", "Scheme"];
couplingCanonicalization =
  s03["Renormalization", "CouplingCanonicalization"];
require[AssociationQ[couplingCanonicalization] &&
    KeyExistsQ[couplingCanonicalization, "FeynCalcSMCoupling"] &&
    KeyExistsQ[couplingCanonicalization, "ChannelCoupling"] &&
    TrueQ[couplingCanonicalization["GeneratedTreeGate"]],
  "accepted S03 coupling canonicalization is unavailable"];
feynCalcStrongCoupling =
  couplingCanonicalization["FeynCalcSMCoupling"];
channelStrongCoupling = couplingCanonicalization["ChannelCoupling"];
regeneratedStrongCouplingRules =
  couplingCanonicalization["AppliedRules"];
require[ListQ[regeneratedStrongCouplingRules] &&
    regeneratedStrongCouplingRules =!= {},
  "accepted S03 coupling rules are unavailable"];
ClearAll[namedStrongCouplings, canonicalizeRegeneratedStrongCoupling];
namedStrongCouplings[expression_] := DeleteDuplicates@Cases[
  expression,
  (symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "FAGS") :>
    Unevaluated[symbol], Infinity];
canonicalizeRegeneratedStrongCoupling[expression_] :=
  expression /. regeneratedStrongCouplingRules /.
    ((symbol_Symbol /;
      SymbolName[Unevaluated[symbol]] === "FAGS") :>
        channelStrongCoupling);
Clear[s03];

s04 = Quiet@Check[Get[s04ResultPath], $Failed];
require[AssociationQ[s04] && s04["Stage"] === "HqqV2S04-v1" &&
    s04["ScopeTag"] === scopeTag && And @@ Values[s04["Checks"]],
  "accepted S04 result failed its gates"];
fractionDefinitions = s04["VariableMap", "Definitions"];
physicalBoundary = s04["VariableMap", "S23Upper"];
hardPartNormalization = s04["Conventions", "HardPartNormalization"];
twoBodyInvariantMeasure =
  s04["PhaseSpace", "TwoBody", "InvariantMeasure"];
s23Equation = s04["Conservation", "BaseEquations", "S23"];
Clear[s04];

require[msbarScheme === "MSbar" &&
    FreeQ[msbarSEpsilon, FeynCalc`EpsilonUV | FeynCalc`EpsilonIR] &&
    Length[Cases[twoBodyInvariantMeasure, _DiracDelta, Infinity]] === 1,
  "accepted renormalization or two-body contract changed"];
twoBodyMeasurePrefactor = twoBodyInvariantMeasure /. DiracDelta[_] -> 1;

(* All two-body scalar products are taken from the accepted tool solution. *)
ClearAll[makePairRule, installTwoBodyKinematics, canonicalTwoBody];
makePairRule[record_] := With[
  {momentum1 = record["Momentum1"], momentum2 = record["Momentum2"],
   dimension = record["Dimension"], value = record["Value"]},
  HoldPattern[FeynCalc`Pair[
    FeynCalc`Momentum[momentum1, dimension],
    FeynCalc`Momentum[momentum2, dimension]]] :> value
];
twoBodyPairRules = makePairRule /@
  twoBodyKinematics["ScalarProductAssignments"];
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
canonicalTwoBody[expression_] := Module[{answer},
  answer = FeynCalc`FeynAmpDenominatorExplicit[
    FeynCalc`Contract[FeynCalc`ExpandScalarProduct[expression]]];
  answer = answer /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  answer = FeynCalc`Contract[answer] /. twoBodyPairRules /.
    twoBodyKinematics["MandelstamURule"];
  Cancel[Together[answer]]
];

(* Regenerate all lower Born channels entering Eq. (46). *)
Print["S07_STAGE=regenerate Eq46 lower Born channels"];
mu = Unique["mu"];
nu = Unique["nu"];
upField = FeynArts`F[3, {1}];
gluonField = FeynArts`V[5];
bornSpecifications = <|
  "Hqq" -> <|"Indices" -> {"q", "q"},
    "IncomingFields" -> {FeynArts`V[1], upField},
    "OutgoingFields" -> {upField, gluonField},
    "GluonMomentum" -> k2, "Reference" -> 0,
    "AlternativeReference" -> p, "InitialType" -> "q"|>,
  "Hgq" -> <|"Indices" -> {"g", "q"},
    "IncomingFields" -> {FeynArts`V[1], gluonField},
    "OutgoingFields" -> {upField, -upField},
    "GluonMomentum" -> p, "Reference" -> k1,
    "AlternativeReference" -> k2, "InitialType" -> "g"|>,
  "Hqg" -> <|"Indices" -> {"q", "g"},
    "IncomingFields" -> {FeynArts`V[1], upField},
    "OutgoingFields" -> {gluonField, upField},
    "GluonMomentum" -> k1, "Reference" -> p,
    "AlternativeReference" -> k2, "InitialType" -> "q"|>
|>;

excludedParticles = {
  FeynArts`V[2], FeynArts`V[3], FeynArts`S[1], FeynArts`S[2],
  FeynArts`S[3], FeynArts`F[1], FeynArts`F[2], FeynArts`U[1],
  FeynArts`U[2], FeynArts`U[3], FeynArts`U[4]};

ClearAll[fixPhotonCoupling, symbolizePhotonCharges, chargeDegree,
  couplingSignature, classEntry, quantumNumbers, electricQuantumNumber,
  chargeCoefficient, canonicalCharge, quarkMassHeadQ, generateBorn,
  convertBorn, openPhotonIndex, conjugateTree, wardSubstitute];
$S07ChargeRewriteCount = 0;
$S07RawCharges = {};
fixPhotonCoupling[value_] := Module[{numeric, rawCharge},
  If[FreeQ[value, FeynArts`FCGV["EL"]] &&
      FreeQ[value, FeynCalc`FCGV["EL"]], Return[value]];
  require[FreeQ[value,
      FeynArts`FCGV["SW"] | FeynCalc`FCGV["SW"] |
      FeynArts`FCGV["MW"] | FeynCalc`FCGV["MW"]],
    "electroweak factor survived in a photon coupling"];
  numeric = If[Head[value] === Times,
    Times @@ Cases[List @@ value, _?NumberQ], 1];
  require[NumberQ[numeric] && numeric =!= 0,
    "photon coupling has no exact numeric charge"];
  rawCharge = I numeric;
  require[Element[rawCharge, Rationals] && rawCharge =!= 0,
    "photon charge is not a nonzero rational"];
  $S07ChargeRewriteCount++;
  $S07RawCharges = Union[$S07RawCharges, {rawCharge}];
  value HqqV2RawCharge[rawCharge]/rawCharge
];
symbolizePhotonCharges[amplitudes_] := amplitudes /.
  FeynArts`Insertions[FeynArts`Classes][values__List] :>
    FeynArts`Insertions[FeynArts`Classes] @@
      (Map[fixPhotonCoupling, #] & /@ {values});
chargeDegree[amplitude_] := Exponent[
  amplitude /. HqqV2RawCharge[_] :> s07ChargeTag, s07ChargeTag];
couplingSignature[amplitude_] := Module[{probe},
  probe = Expand[amplitude /.
    {FeynArts`FCGV["EL"] -> s07E,
      FeynCalc`FCGV["EL"] -> s07E,
      FeynArts`FAGS -> s07GS, HqqV2RawCharge[_] -> 1}];
  {Exponent[probe, s07E], Exponent[probe, s07GS]}
];
generateBorn[label_String] := Module[
  {specification, topologies, insertions, raw, prepared, picked,
   selected, rows, graphIDs},
  specification = bornSpecifications[label];
  topologies = FeynArts`CreateTopologies[0, 2 -> 2,
    FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles}];
  insertions = FeynArts`InsertFields[topologies,
    specification["IncomingFields"] -> specification["OutgoingFields"],
    FeynArts`InsertionLevel -> FeynArts`Classes,
    FeynArts`Model -> "SMQCD",
    FeynArts`ExcludeParticles -> excludedParticles];
  raw = FeynArts`CreateFeynAmp[insertions, FeynArts`Truncated -> False];
  require[Length[raw] > 0, "no generated Born amplitudes for " <> label];
  prepared = symbolizePhotonCharges[raw];
  picked = FeynArts`PickLevel[FeynArts`Classes][prepared];
  selected = Select[picked,
    couplingSignature[#] === {1, 1} && chargeDegree[#] === 1 &];
  rows = List @@ selected;
  require[rows =!= {} && AllTrue[rows,
      couplingSignature[#] === {1, 1} && chargeDegree[#] === 1 &],
    "Born coupling-order selection failed for " <> label];
  graphIDs = DeleteDuplicates@Cases[rows, _FeynArts`GraphID, Infinity];
  require[Length[graphIDs] === Length[rows],
    "Born graph identities are missing or nonunique for " <> label];
  Print["S07_BORN_GENERATED=", label, " COUNT=", Length[rows]];
  <|"Selected" -> selected, "UnfilteredCount" -> Length[raw],
    "SelectedCount" -> Length[rows], "GraphIDs" -> graphIDs|>
];
generatedBorn = AssociationMap[generateBorn, Keys[bornSpecifications]];

classSymbols = Names["*M$ClassesDescription*"];
require[Length[classSymbols] === 1,
  "loaded SMQCD class table is not unique"];
classDescriptions = ToExpression[First[classSymbols]];
classEntry[n_Integer] := FirstCase[classDescriptions,
  HoldPattern[FeynArts`F[n] == rhs_] :> rhs, Missing["NotFound"]];
quantumNumbers[n_Integer] := FirstCase[classEntry[n],
  Rule[key_, value_] /; SymbolName[Unevaluated[key]] ===
      "QuantumNumbers" :> value, Missing["NotFound"], Infinity];
electricQuantumNumber[n_Integer] := Module[{qns = quantumNumbers[n]},
  If[ListQ[qns] && qns =!= {}, First[qns], Missing["NotFound"]]
];
chargeMarkers = DeleteDuplicates@Cases[
  {electricQuantumNumber[3], electricQuantumNumber[4]},
  symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "Charge",
  Infinity];
require[Length[chargeMarkers] === 1,
  "SMQCD charge marker is not unique"];
chargeMarker = First[chargeMarkers];
chargeCoefficient[n_Integer] := Together[
  electricQuantumNumber[n] /. chargeMarker -> 1];
upModelCharge = chargeCoefficient[3];
downModelCharge = chargeCoefficient[4];
require[Element[upModelCharge, Rationals] && upModelCharge =!= 0 &&
    Element[downModelCharge, Rationals] && downModelCharge =!= 0 &&
    Abs[upModelCharge] =!= Abs[downModelCharge],
  "model-derived quark charges are invalid"];
canonicalCharge[raw_] := Which[
  TrueQ[Abs[raw] === Abs[upModelCharge]],
    Together[raw/upModelCharge] HqqV2Charge["UpType"],
  TrueQ[Abs[raw] === Abs[downModelCharge]],
    Together[raw/downModelCharge] HqqV2Charge["DownType"],
  True, fail["unrecognized raw quark charge", raw]
];
quarkMassHeadQ[head_] := MatchQ[Unevaluated[head], _Symbol] &&
  MemberQ[{"MQU", "MQD"}, SymbolName[Unevaluated[head]]];
masslessRules = {
  SMP["m_u"] -> 0, SMP["m_d"] -> 0, SMP["m_c"] -> 0,
  SMP["m_s"] -> 0, SMP["m_t"] -> 0, SMP["m_b"] -> 0,
  SMP["m_qu"] -> 0, SMP["m_qd"] -> 0,
  FeynArts`FCGV["MU"] -> 0, FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0, FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MT"] -> 0, FeynArts`FCGV["MB"] -> 0,
  HoldPattern[head_Symbol[arguments___] /; quarkMassHeadQ[head]] :> 0};
convertBorn[label_String] := Module[
  {answer, strongCouplings, conversionChecks},
  answer = CheckAbort[Quiet@Check[FeynCalc`FCFAConvert[
    generatedBorn[label, "Selected"],
    FeynCalc`IncomingMomenta -> {q, p},
    FeynCalc`OutgoingMomenta -> {k1, k2},
    FeynCalc`LoopMomenta -> {}, FeynCalc`ChangeDimension -> D,
    FeynCalc`DropSumOver -> False,
    FeynCalc`UndoChiralSplittings -> True,
    FeynCalc`Contract -> False, FeynCalc`SMP -> True,
    List -> True, FeynCalc`FinalSubstitutions -> masslessRules],
    $Failed], $Failed];
  require[ListQ[answer] &&
      Length[answer] === generatedBorn[label, "SelectedCount"],
    "FeynCalc Born conversion failed for " <> label];
  answer = answer /.
    HoldPattern[FeynArts`FCGV[name_String]] :> FeynCalc`FCGV[name];
  answer = answer /. HqqV2RawCharge[value_] :> canonicalCharge[value];
  answer = canonicalizeRegeneratedStrongCoupling[answer];
  answer = answer /. HoldPattern[FeynArts`SumOver[___]] -> 1;
  strongCouplings = namedStrongCouplings[answer];
  conversionChecks = <|
    "ResolvedObjects" -> FreeQ[answer,
      HqqV2RawCharge | _FeynArts`SumOver | _FeynArts`FAFeynAmp |
        _FeynArts`FCGV | feynCalcStrongCoupling | _Real |
        (head_Symbol[___] /; quarkMassHeadQ[head])],
    "CanonicalCharge" ->
      ! FreeQ[answer, HqqV2Charge["UpType"]],
    "UniqueChannelCoupling" ->
      SameQ[strongCouplings, {channelStrongCoupling}]|>;
  Print["S07_BORN_CONVERSION=", label, " ",
    InputForm[conversionChecks]];
  require[And @@ Values[conversionChecks],
    "Born conversion is unresolved for " <> label,
    <|"Checks" -> conversionChecks,
      "StrongCouplings" -> strongCouplings|>];
  answer
];
openPhotonIndex[amplitude_, index_Symbol, label_String] := Module[{answer},
  answer = FeynCalc`Contract[amplitude];
  require[! FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " has no photon polarization"];
  answer = answer /. {
    HoldPattern[FeynCalc`DiracGamma[
      FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], dim_]] :>
        FeynCalc`DiracGamma[FeynCalc`LorentzIndex[index, dim], dim],
    HoldPattern[FeynCalc`Pair[FeynCalc`LorentzIndex[lor_, dim_],
      FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]]] :>
        FeynCalc`Pair[FeynCalc`LorentzIndex[lor, dim],
          FeynCalc`LorentzIndex[index, dim]],
    HoldPattern[FeynCalc`Pair[
      FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
      FeynCalc`LorentzIndex[lor_, dim_]]] :>
        FeynCalc`Pair[FeynCalc`LorentzIndex[index, dim],
          FeynCalc`LorentzIndex[lor, dim]],
    HoldPattern[FeynCalc`Pair[
      FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
      FeynCalc`Momentum[momentum_, dim_]]] :>
        FeynCalc`Pair[FeynCalc`LorentzIndex[index, dim],
          FeynCalc`Momentum[momentum, dim]],
    HoldPattern[FeynCalc`Pair[FeynCalc`Momentum[momentum_, dim_],
      FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]]] :>
        FeynCalc`Pair[FeynCalc`Momentum[momentum, dim],
          FeynCalc`LorentzIndex[index, dim]]};
  answer = FeynCalc`Contract[answer];
  require[FreeQ[answer, FeynCalc`Polarization[q, ___]] &&
      ! FreeQ[answer, FeynCalc`LorentzIndex[index, D]],
    label <> " photon-index opening failed"];
  answer
];
convertedBornRows = AssociationMap[convertBorn, Keys[bornSpecifications]];
bornCurrents = AssociationMap[Function[label,
  Total[MapIndexed[openPhotonIndex[#1, mu,
      label <> " row " <> ToString[First[#2]]] &,
    convertedBornRows[label]]]], Keys[bornSpecifications]];

treeRealityRules = {
  HoldPattern[Conjugate[HqqV2Charge[tag_]]] :> HqqV2Charge[tag],
  HoldPattern[Conjugate[FeynCalc`FCGV[tag_]]] :> FeynCalc`FCGV[tag],
  Conjugate[channelStrongCoupling] -> channelStrongCoupling};
conjugateTree[expression_] := Module[{answer},
  answer = CheckAbort[Quiet@Check[FeynCalc`ComplexConjugate[
    expression /. mu -> nu,
    FeynCalc`FCRenameDummyIndices -> True,
    FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  answer = answer /. treeRealityRules;
  require[answer =!= $Failed && FreeQ[answer, Conjugate],
    "tree conjugation failed"];
  answer
];
wardSubstitute[expression_, momentum_] := expression /.
  HoldPattern[FeynCalc`Momentum[
    FeynCalc`Polarization[momentum, phases___], dimension_]] :>
      FeynCalc`Momentum[momentum, dimension];

(* Tool-derived state counts and color factors. *)
installTwoBodyKinematics[];
spinProbe = FeynCalc`DiracSimplify[FeynCalc`DiracTrace[
  FeynCalc`GSD[p] . FeynCalc`GSD[s07SpinReference]],
  FeynCalc`DiracTraceEvaluate -> True, FeynCalc`FCVerbose -> 0];
spinNormalization = 2 FeynCalc`FCI[
  FeynCalc`SPD[p, s07SpinReference]];
quarkSpinStates = Together[spinProbe/spinNormalization];
quarkColorStates = FeynCalc`SUNSimplify[
  FeynCalc`SUNFDelta[s07Fundamental, s07Fundamental],
  FeynCalc`SUNNToCACF -> False, FeynCalc`FCVerbose -> 0];
FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[p, p] = 0;
FeynCalc`SPD[s07AxialReference, s07AxialReference] = 0;
gluonNorm = FeynCalc`Pair[
  FeynCalc`Momentum[FeynCalc`Polarization[p, I], D],
  FeynCalc`Momentum[FeynCalc`Polarization[p, -I], D]];
gluonSpinStates = -FeynCalc`Contract[
  FeynCalc`DoPolarizationSums[gluonNorm, p, s07AxialReference]];
gluonColorStates = FeynCalc`SUNSimplify[
  FeynCalc`SUNDelta[FeynCalc`SUNIndex[s07Adjoint],
    FeynCalc`SUNIndex[s07Adjoint]],
  FeynCalc`SUNNToCACF -> False];
quarkAverage = Cancel[Together[1/(quarkSpinStates quarkColorStates)]];
gluonAverage = Cancel[Together[1/(gluonSpinStates gluonColorStates)]];
tfTensor = FeynCalc`SUNSimplify[FeynCalc`SUNTrace[
  FeynCalc`SUNT[s07A, s07B]], FeynCalc`SUNNToCACF -> False];
tfValue = Cancel[Together[tfTensor/
  FeynCalc`SUNDelta[FeynCalc`SUNIndex[s07A],
    FeynCalc`SUNIndex[s07B]]]];
cfValue = FeynCalc`SUNSimplify[FeynCalc`SUNT[s07A, s07A],
  FeynCalc`SUNNToCACF -> False];
stateCountChecks = <|
  "QuarkAverage" -> exactZeroQ[
    quarkAverage quarkSpinStates quarkColorStates - 1],
  "GluonAverage" -> exactZeroQ[
    gluonAverage gluonSpinStates gluonColorStates - 1],
  "ExactCounts" -> FreeQ[
    {quarkSpinStates, quarkColorStates, gluonSpinStates,
      gluonColorStates, tfValue, cfValue}, _Real | $Failed |
      FeynCalc`DoPolarizationSums | FeynCalc`SUNSimplify],
  "TraceReconstructs" -> exactZeroQ[tfTensor - tfValue
    FeynCalc`SUNDelta[FeynCalc`SUNIndex[s07A],
      FeynCalc`SUNIndex[s07B]]]|>;
require[And @@ Values[stateCountChecks],
  "tool-derived state/color counts failed", stateCountChecks];

projectors = <|
  "Pg" -> FeynCalc`Pair[FeynCalc`LorentzIndex[mu, D],
    FeynCalc`LorentzIndex[nu, D]],
  "PPP" -> FeynCalc`Pair[
      FeynCalc`Momentum[p, D], FeynCalc`LorentzIndex[mu, D]]
    FeynCalc`Pair[FeynCalc`Momentum[p, D],
      FeynCalc`LorentzIndex[nu, D]]|>;
projectorLabels = Keys[projectors];

ClearAll[stateSumProjected];
stateSumProjected[expression_, specifications_List, average_, label_String] :=
 Module[{postSpin, postPolarization, postDirac, answer},
  installTwoBodyKinematics[];
  postSpin = CheckAbort[Quiet@Check[FeynCalc`FermionSpinSum[
    expression, FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  require[postSpin =!= $Failed, label <> " spin sum failed"];
  postPolarization = Fold[Function[{current, specification},
    CheckAbort[Quiet@Check[FeynCalc`DoPolarizationSums[current,
      specification[[1]], specification[[2]],
      TimeConstrained -> Infinity, FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed]],
    postSpin, specifications];
  require[postPolarization =!= $Failed,
    label <> " polarization sum failed"];
  postDirac = CheckAbort[Quiet@Check[FeynCalc`DiracSimplify[
    postPolarization, FeynCalc`DiracTrace -> True,
    FeynCalc`DiracTraceEvaluate -> True,
    FeynCalc`DiracSubstitute67 -> True,
    FeynCalc`ToDiracGamma67 -> False,
    FeynCalc`FCParallelize -> False, FeynCalc`FCVerbose -> 0,
    FeynCalc`Factoring -> False], $Failed], $Failed];
  require[postDirac =!= $Failed && FreeQ[postDirac,
      _FeynCalc`Spinor | _FeynCalc`Polarization |
      _FeynCalc`DiracTrace | _FeynCalc`DiracGamma],
    label <> " Dirac/state reduction failed"];
  answer = CheckAbort[Quiet@Check[FeynCalc`SUNSimplify[
    postDirac average, FeynCalc`Explicit -> True,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCParallelize -> False,
    FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  require[answer =!= $Failed && FreeQ[answer,
      _FeynCalc`SUNFIndex | _FeynCalc`SUNIndex |
      _FeynArts`SumOver | _Real],
    label <> " color sum failed"];
  canonicalTwoBody[answer]
];

bornProjected = <||>;
bornReferenceProjected = <||>;
bornGaugeProjected = <||>;
bornWardResiduals = <||>;
Do[
  specification = bornSpecifications[label];
  current = bornCurrents[label];
  conjugate = conjugateTree[current];
  average = If[specification["InitialType"] === "q",
    quarkAverage, gluonAverage];
  pol = {{specification["GluonMomentum"], specification["Reference"]}};
  polAlternative = {{specification["GluonMomentum"],
    specification["AlternativeReference"]}};
  primaryTensor = stateSumProjected[current conjugate,
    pol, average, label <> "/primary tensor"];
  alternativeTensor = stateSumProjected[current conjugate,
    polAlternative, average, label <> "/alternate tensor"];
  AssociateTo[bornProjected, label -> AssociationMap[Function[projector,
    Print["S07_BORN_PROJECT=", label, "/", projector];
    canonicalTwoBody[FeynCalc`Contract[
      projectors[projector] primaryTensor]]], projectorLabels]];
  AssociateTo[bornReferenceProjected,
    label -> AssociationMap[Function[projector,
      canonicalTwoBody[FeynCalc`Contract[
        projectors[projector] alternativeTensor]]], projectorLabels]];
  wardCurrent = wardSubstitute[current, specification["GluonMomentum"]];
  wardConjugate = conjugateTree[wardCurrent];
  gaugeTensor = stateSumProjected[wardCurrent wardConjugate,
    {}, average, label <> "/gluon-Ward tensor"];
  AssociateTo[bornGaugeProjected,
    label -> AssociationMap[Function[projector,
      canonicalTwoBody[FeynCalc`Contract[
        projectors[projector] gaugeTensor]]],
      projectorLabels]];
  qContracted = FeynCalc`Contract[
    FeynCalc`Pair[FeynCalc`Momentum[q, D],
      FeynCalc`LorentzIndex[mu, D]] current];
  qConjugate = Quiet@Check[FeynCalc`ComplexConjugate[qContracted,
    FeynCalc`FCRenameDummyIndices -> True,
    FeynCalc`FCVerbose -> 0] /. treeRealityRules, $Failed];
  require[qConjugate =!= $Failed && FreeQ[qConjugate, Conjugate],
    label <> " electromagnetic Ward conjugation failed"];
  AssociateTo[bornWardResiduals, label -> stateSumProjected[
    qContracted qConjugate, pol, average, label <> "/photon-Ward"]],
  {label, Keys[bornSpecifications]}];

bornGaugeChecks = AssociationMap[Function[label,
  <|"ReferenceIndependence" -> And @@ Map[
      exactZeroQ[bornProjected[label, #] -
        bornReferenceProjected[label, #]] &, projectorLabels],
    "ExternalGluonWard" -> And @@ Map[
      exactZeroQ[bornGaugeProjected[label, #]] &, projectorLabels],
    "ElectromagneticWard" -> exactZeroQ[bornWardResiduals[label]]|>],
  Keys[bornSpecifications]];
require[And @@ Flatten[Values /@ Values[bornGaugeChecks]],
  "regenerated Born gauge gate failed", bornGaugeChecks];
hqqBornAgreement = AssociationMap[
  exactZeroQ[bornProjected["Hqq", #] - acceptedHqqBorn[#]] &,
  projectorLabels];
hqqBornRatios = AssociationMap[
  Cancel[Together[bornProjected["Hqq", #]/acceptedHqqBorn[#]]] &,
  projectorLabels];
Print["S07_HQQ_BORN_RATIOS=", InputForm[hqqBornRatios]];
require[And @@ Values[hqqBornAgreement],
  "regenerated Hqq Born does not match accepted S03",
  <|"Agreement" -> hqqBornAgreement,
    "Ratios" -> hqqBornRatios|>];

bornDiagramLedger = AssociationMap[Function[label, <|
  "Indices" -> bornSpecifications[label, "Indices"],
  "UnfilteredCount" -> generatedBorn[label, "UnfilteredCount"],
  "SelectedCount" -> generatedBorn[label, "SelectedCount"],
  "GraphIDs" -> generatedBorn[label, "GraphIDs"],
  "GaugeChecks" -> bornGaugeChecks[label]|>], Keys[bornSpecifications]];
Clear[generatedBorn, convertedBornRows, bornCurrents,
  bornReferenceProjected, bornGaugeProjected, current, conjugate,
  wardCurrent, wardConjugate, qContracted, qConjugate,
  primaryTensor, alternativeTensor, gaugeTensor];

(* Paper Eqs. (51)-(53), decomposed by Wolfram into regular/plus/delta. *)
Print["S07_STAGE=derive splitting kernels and Eq46 route inventory"];
ClearAll[S07KernelPlus, S07KernelDelta, decomposeKernel];
pqqDefinition = 2 cfValue (2 S07KernelPlus[1 - y] - 1 - y +
  3/2 S07KernelDelta[1 - y]);
pqgDefinition = 2 tfValue ((1 - y)^2 + y^2);
pgqDefinition = 2 cfValue (1 + (1 - y)^2)/y;
decomposeKernel[definition_] := Module[{tagged},
  tagged = definition /.
    {S07KernelPlus[1 - y] -> s07PlusTag,
      S07KernelDelta[1 - y] -> s07DeltaTag};
  <|"Regular" -> tagged /. {s07PlusTag -> 0, s07DeltaTag -> 0},
    "Plus" -> Coefficient[tagged, s07PlusTag],
    "Delta" -> Coefficient[tagged, s07DeltaTag]|>
];
splittingKernels = <|
  {"q", "q"} -> decomposeKernel[pqqDefinition],
  {"q", "g"} -> decomposeKernel[pqgDefinition],
  {"g", "q"} -> decomposeKernel[pgqDefinition]|>;
kernelDefinitions = <|{"q", "q"} -> pqqDefinition,
  {"q", "g"} -> pqgDefinition, {"g", "q"} -> pgqDefinition|>;
kernelReconstructionChecks = AssociationMap[Function[key,
  exactZeroQ[kernelDefinitions[key] -
    (splittingKernels[key, "Regular"] +
      splittingKernels[key, "Plus"] S07KernelPlus[1 - y] +
      splittingKernels[key, "Delta"] S07KernelDelta[1 - y])]],
  Keys[splittingKernels]];
require[And @@ Values[kernelReconstructionChecks],
  "splitting-kernel decomposition failed",
  kernelReconstructionChecks];

bornChannelByIndices = Association@KeyValueMap[
  bornSpecifications[#1, "Indices"] -> #1 &, bornSpecifications];
externalInitial = "q";
externalFinal = "q";
partonSpecies = {"q", "g"};
initialParents = Select[partonSpecies,
  KeyExistsQ[bornChannelByIndices, {#, externalFinal}] &&
    KeyExistsQ[splittingKernels, {#, externalInitial}] &];
finalParents = Select[partonSpecies,
  KeyExistsQ[bornChannelByIndices, {externalInitial, #}] &&
    KeyExistsQ[splittingKernels, {externalFinal, #}] &];
routeSpecifications = Association@Join[
  Table["Initial_" <> parent <> externalInitial -> <|
    "Direction" -> "Initial", "Parent" -> parent,
    "BornChannel" -> bornChannelByIndices[{parent, externalFinal}],
    "Kernel" -> splittingKernels[{parent, externalInitial}]|>,
    {parent, initialParents}],
  Table["Final_" <> externalFinal <> parent -> <|
    "Direction" -> "Final", "Parent" -> parent,
    "BornChannel" -> bornChannelByIndices[{externalInitial, parent}],
    "Kernel" -> splittingKernels[{externalFinal, parent}]|>,
    {parent, finalParents}]];
require[AssociationQ[routeSpecifications] &&
    Keys[routeSpecifications] ===
    {"Initial_qq", "Initial_gq", "Final_qq", "Final_qg"},
  "Eq. (46) Hqq route inventory changed", Keys[routeSpecifications]];

(* Derive both convolution maps from accepted S04 definitions. *)
Print["S07_STAGE=derive initial and final convolution pushforwards"];
sDefinition[x_, zeta_, transverse_] :=
  fractionDefinitions["sHat"] /.
    {xHat -> x, zHat -> zeta, k1T2 -> transverse};
tDefinition[x_, zeta_, transverse_] :=
  fractionDefinitions["t1"] /.
    {xHat -> x, zHat -> zeta, k1T2 -> transverse};
uDefinition[x_, zeta_, transverse_] :=
  fractionDefinitions["u1"] /.
    {xHat -> x, zHat -> zeta, k1T2 -> transverse};
inverseFractionSolutions = Solve[{
    sHat == sDefinition[xHat, zHat, k1T2],
    t1 == tDefinition[xHat, zHat, k1T2],
    u1 == uDefinition[xHat, zHat, k1T2]},
  {xHat, zHat, k1T2}];
require[Length[inverseFractionSolutions] === 1,
  "fraction definitions lack a unique inverse"];
inverseFractionRules = First[inverseFractionSolutions];
u1Solutions = Solve[s23Equation, u1];
require[Length[u1Solutions] === 1,
  "S04 conservation does not determine u1 uniquely"];
u1Rule = First[u1Solutions];
require[exactZeroQ[(s23Equation[[1]] - s23Equation[[2]]) /. u1Rule],
  "derived u1 conservation rule failed"];

transverseComponentRule = First@Solve[
  shiftedTransverseComponent == transverseComponent/eta,
  shiftedTransverseComponent];
shiftedTransverseSquared = Expand[
  shiftedTransverseComponent^2 /. transverseComponentRule /.
    transverseComponent^2 -> k1T2];
require[FreeQ[shiftedTransverseSquared, shiftedTransverseComponent |
    transverseComponent], "final transverse scaling did not close"];

initialShiftRules = {
  sHat -> sDefinition[xHat/eta, zHat, k1T2],
  tHat -> tDefinition[xHat/eta, zHat, k1T2],
  uHat -> uDefinition[xHat/eta, zHat, k1T2]};
finalShiftRules = {
  sHat -> sDefinition[xHat, zHat/eta, shiftedTransverseSquared],
  tHat -> tDefinition[xHat, zHat/eta, shiftedTransverseSquared],
  uHat -> uDefinition[xHat, zHat/eta, shiftedTransverseSquared]};
initialConstraint = Cancel[Together[(Q2 + sHat + tHat + uHat) /.
  initialShiftRules /. inverseFractionRules /. u1Rule]];
finalConstraint = Cancel[Together[(Q2 + sHat + tHat + uHat) /.
  finalShiftRules /. inverseFractionRules /. u1Rule]];

ClearAll[uniqueRoot, signedPositiveJacobian, safeLimit,
  physicalSimplify, buildPushforward];
uniqueRoot[equation_, variable_Symbol, label_String] := Module[{solutions},
  solutions = Solve[equation, variable];
  require[Length[solutions] === 1,
    label <> " does not have one localization root", solutions];
  First[solutions]
];
physicalAssumptions = Q2 > 0 && sHat > 0 && t1 < 0 &&
  s23 >= 0 && s07PhysicalBoundary > 0 && Element[epsilon, Reals];
signedPositiveJacobian[derivative_, domain_, label_String] := Module[
  {positive, negative, assumptions},
  assumptions = physicalAssumptions && domain;
  positive = TrueQ[FullSimplify[derivative > 0,
    Assumptions -> assumptions]];
  negative = TrueQ[FullSimplify[derivative < 0,
    Assumptions -> assumptions]];
  require[Xor[positive, negative],
    label <> " Jacobian sign was not determined", derivative];
  If[positive, derivative, -derivative]
];
safeLimit[expression_, rule_, label_String] := Module[
  {canonical, direct, answer},
  canonical = Quiet@Check[Cancel[Together[expression]], $Failed];
  require[canonical =!= $Failed && ! badSymbolicQ[canonical],
    label <> " rational canonicalization failed", canonical];
  direct = Quiet@Check[Cancel[Together[canonical /. rule]], $Failed];
  If[direct =!= $Failed && ! badSymbolicQ[direct], Return[direct]];
  answer = Quiet@Check[Limit[canonical, rule,
    Direction -> "FromAbove", Assumptions -> physicalAssumptions],
    $Failed];
  require[answer =!= $Failed && ! badSymbolicQ[answer],
    label <> " limit failed", answer];
  answer
];
physicalSimplify[expression_] := Quiet@Check[
  FullSimplify[Cancel[Together[expression]],
    Assumptions -> physicalAssumptions], $Failed];

alphaSSolutions = Solve[channelStrongCoupling^2 == 4 Pi alphaS, alphaS];
require[Length[alphaSSolutions] === 1,
  "QCD coupling definition did not determine alphaS"];
alphaSRule = First[alphaSSolutions];
factorizationPrefactor = Cancel[Together[
  (alphaS msbarSEpsilon/(4 Pi epsilon)) /. alphaSRule]];
require[FreeQ[factorizationPrefactor, mu | mu2 | ScaleMu] &&
    ! FreeQ[factorizationPrefactor, epsilon],
  "MS-bar factorization prefactor is malformed"];

loCoefficients = AssociationMap[Function[channel,
  AssociationMap[Function[projector,
    hardPartNormalization twoBodyMeasurePrefactor
      (bornProjected[channel, projector] /. D -> 4 - 2 epsilon)],
    projectorLabels]], Keys[bornSpecifications]];

buildPushforward[routeName_String, projector_String] := Module[
  {route, direction, kernel, channel, shiftRules, constraint,
   measurePower, shiftedLO, rootRule, root, derivativeEta,
   jacobianEta, derivativeSAtOne, jacobianSAtOne, regularDensity,
   deltaBase, deltaPiece, singularBase, singularWeight,
   endpointWeight, cutoffRule, cutoffS, cutoffScale,
   cutoffRootResidual, endpointBaseResidual, endpointRegulatorResidual,
   ordinaryFromPlus, ordinaryEndpoint, deltaFromPlus,
   actionDensityResidual, momentResiduals, momentChecks,
  components, mapChecks},
  route = routeSpecifications[routeName];
  require[AssociationQ[route] &&
      And @@ (KeyExistsQ[route, #] & /@
        {"Direction", "BornChannel", "Kernel"}),
    routeName <> " route lookup failed", route];
  direction = route["Direction"];
  kernel = route["Kernel"];
  channel = route["BornChannel"];
  shiftRules = If[direction === "Initial",
    initialShiftRules, finalShiftRules];
  constraint = If[direction === "Initial",
    initialConstraint, finalConstraint];
  measurePower = If[direction === "Initial", 1, 2];
  shiftedLO = Cancel[Together[(loCoefficients[channel, projector] /.
      shiftRules) /. inverseFractionRules /. u1Rule]];
  rootRule = uniqueRoot[constraint == 0, eta,
    routeName <> "/" <> projector <> "/eta"];
  root = eta /. rootRule;
  derivativeEta = Cancel[Together[D[constraint, eta] /. rootRule]];
  jacobianEta = signedPositiveJacobian[derivativeEta,
    0 < root <= 1,
    routeName <> "/" <> projector <> "/eta"];
  derivativeSAtOne = Cancel[Together[
    D[constraint /. eta -> 1, s23]]];
  jacobianSAtOne = signedPositiveJacobian[derivativeSAtOne, True,
    routeName <> "/" <> projector <> "/s23"];
  regularDensity = Cancel[Together[
    ((shiftedLO/eta^measurePower) (kernel["Regular"] /. y -> eta)/
      jacobianEta) /. rootRule]];
  deltaBase = Cancel[Together[
    ((shiftedLO/eta^measurePower)/jacobianSAtOne) /.
      {eta -> 1, s23 -> 0}]];
  deltaPiece = kernel["Delta"] deltaBase;
  singularBase = Cancel[Together[
    ((shiftedLO/eta^measurePower)/jacobianEta) /. rootRule]];
  If[TrueQ[kernel["Plus"] === 0],
    components = <|"Delta" -> deltaPiece,
      "BoundedPlus" -> 0, "Ordinary" -> regularDensity|>;
    mapChecks = <|
      "NoPlusRequired" -> True,
      "RootCloses" -> exactZeroQ[constraint /. rootRule],
      "EndpointRoot" -> exactZeroQ[(root /. s23 -> 0) - 1],
      "ClosedExact" -> ! badSymbolicQ[components] &&
        FreeQ[components, Abs | eta | s07Cutoff | s07CutoffS]|>;
    require[And @@ Values[mapChecks],
      routeName <> "/" <> projector <> " non-plus pushforward gate failed",
      mapChecks];
    Return[<|"Components" -> components, "Root" -> root,
      "EtaJacobian" -> jacobianEta, "DeltaJacobian" -> jacobianSAtOne,
      "Checks" -> mapChecks|>]
  ];
  singularWeight = physicalSimplify[singularBase s23/(1 - root)];
  require[singularWeight =!= $Failed && ! badSymbolicQ[singularWeight],
    routeName <> "/" <> projector <> " singular weight failed"];
  endpointWeight = safeLimit[singularWeight, s23 -> 0,
    routeName <> "/" <> projector <> "/endpoint weight"];
  cutoffRule = uniqueRoot[
    (root /. s23 -> s07CutoffS) == 1 - s07Cutoff,
    s07CutoffS, routeName <> "/" <> projector <> "/cutoff"];
  cutoffS = s07CutoffS /. cutoffRule;
  cutoffRootResidual = physicalSimplify[
    (root /. s23 -> cutoffS) - (1 - s07Cutoff)];
  cutoffScale = safeLimit[cutoffS/s07Cutoff,
    s07Cutoff -> 0,
    routeName <> "/" <> projector <> "/cutoff scale"];
  ordinaryFromPlus = physicalSimplify[
    (singularWeight - endpointWeight)/s23];
  require[ordinaryFromPlus =!= $Failed &&
      ! badSymbolicQ[ordinaryFromPlus],
    routeName <> "/" <> projector <> " regularized plus remainder failed"];
  ordinaryEndpoint = safeLimit[ordinaryFromPlus, s23 -> 0,
    routeName <> "/" <> projector <> "/ordinary endpoint"];
  endpointBaseResidual = physicalSimplify[endpointWeight - deltaBase];
  deltaFromPlus = physicalSimplify[
    endpointWeight Log[s07PhysicalBoundary/cutoffScale]];
  require[deltaFromPlus =!= $Failed && ! badSymbolicQ[deltaFromPlus],
    routeName <> "/" <> projector <> " delta pushforward failed"];
  endpointRegulatorResidual = safeLimit[
    endpointWeight Log[s07PhysicalBoundary/cutoffS] +
      deltaBase Log[s07Cutoff] - deltaFromPlus,
    s07Cutoff -> 0,
    routeName <> "/" <> projector <> "/endpoint regulator"];
  actionDensityResidual[test_] := physicalSimplify[
    singularWeight test -
      endpointWeight (test - (test /. s23 -> 0)) -
      s23 ordinaryFromPlus test -
      endpointWeight (test /. s23 -> 0)];
  momentResiduals = Association@Table[n ->
    physicalSimplify[actionDensityResidual[s23^n] +
      endpointRegulatorResidual (s23^n /. s23 -> 0)],
    {n, 0, 2}];
  momentChecks = Map[SameQ[#, 0] &, momentResiduals];
  components = <|
    "Delta" -> deltaPiece + kernel["Plus"] deltaFromPlus,
    "BoundedPlus" -> kernel["Plus"] endpointWeight
      HqqV2BoundedPlus[0, s23, s07PhysicalBoundary],
    "Ordinary" -> regularDensity +
      kernel["Plus"] ordinaryFromPlus|>;
  mapChecks = <|
    "RootCloses" -> exactZeroQ[constraint /. rootRule],
    "EndpointRoot" -> exactZeroQ[(root /. s23 -> 0) - 1],
    "CutoffRootCloses" -> SameQ[cutoffRootResidual, 0],
    "CutoffScaleClosed" -> ! badSymbolicQ[cutoffScale] &&
      FreeQ[cutoffScale, s07Cutoff | s07CutoffS],
    "CutoffScalePositive" -> TrueQ[FullSimplify[cutoffScale > 0,
      Assumptions -> physicalAssumptions]],
    "EndpointBaseMatches" -> SameQ[endpointBaseResidual, 0],
    "EndpointRegulator" -> SameQ[endpointRegulatorResidual, 0],
    "OrdinaryEndpointClosed" ->
      ! badSymbolicQ[ordinaryEndpoint] && FreeQ[ordinaryEndpoint, s23],
    "PolynomialMoments" -> And @@ Values[momentChecks],
    "ClosedExact" -> ! badSymbolicQ[components] &&
      FreeQ[components, Abs | eta | s07Cutoff | s07CutoffS]|>;
  require[And @@ Values[mapChecks],
    routeName <> "/" <> projector <> " pushforward gate failed",
    <|"MapChecks" -> mapChecks, "MomentChecks" -> momentChecks,
      "MomentResiduals" -> momentResiduals|>];
  <|"Components" -> components, "Root" -> root,
    "EtaJacobian" -> jacobianEta, "DeltaJacobian" -> jacobianSAtOne,
    "SingularWeight" -> singularWeight,
    "EndpointWeight" -> endpointWeight,
    "CutoffScale" -> cutoffScale,
    "OrdinaryEndpoint" -> ordinaryEndpoint,
    "DeltaFromPlus" -> deltaFromPlus,
    "MomentResiduals" -> momentResiduals,
    "MomentChecks" -> momentChecks, "Checks" -> mapChecks|>
];

pushforwards = AssociationMap[Function[route,
  Print["S07_PUSHFORWARD=", route];
  AssociationMap[buildPushforward[route, #] &, projectorLabels]],
  Keys[routeSpecifications]];

ClearAll[laurentAssociation];
laurentAssociation[expression_, label_String] := Module[{series},
  series = Quiet@Check[Normal@Series[
    factorizationPrefactor expression,
    {epsilon, 0, 0}], $Failed];
  require[series =!= $Failed && ! badSymbolicQ[series],
    label <> " MS-bar Laurent expansion failed"];
  Association@Table[power -> Coefficient[series, epsilon, power],
    {power, -1, 0}]
];
factorizationByRoute = AssociationMap[Function[route,
  AssociationMap[Function[projector,
    AssociationMap[Function[sector,
      laurentAssociation[
        pushforwards[route, projector, "Components", sector] /.
          s07PhysicalBoundary -> physicalBoundary,
        route <> "/" <> projector <> "/" <> sector]],
      {"Delta", "BoundedPlus", "Ordinary"}]], projectorLabels]],
  Keys[routeSpecifications]];
factorizationLaurentLedger = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    Association@Table[power -> Total[Table[
      factorizationByRoute[route, projector, sector, power],
      {route, Keys[routeSpecifications]}]], {power, -1, 0}]],
    {"Delta", "BoundedPlus", "Ordinary"}]], projectorLabels];

pushforwardCheckValues = Cases[pushforwards,
  (association_Association /; KeyExistsQ[association, "Checks"]) :>
    And @@ Values[association["Checks"]], Infinity];
factorizationChecks = <|
  "RouteInventory" -> AssociationQ[routeSpecifications] &&
    Keys[routeSpecifications] ===
    {"Initial_qq", "Initial_gq", "Final_qq", "Final_qg"},
  "KernelReconstruction" -> And @@ Values[kernelReconstructionChecks],
  "PushforwardChecks" ->
    Length[pushforwardCheckValues] ===
      Length[routeSpecifications] Length[projectorLabels] &&
    And @@ pushforwardCheckValues,
  "MSbarNoMuEpsilon" -> FreeQ[factorizationLaurentLedger,
    mu | mu2 | ScaleMu | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR],
  "ClosedExact" -> ! badSymbolicQ[factorizationLaurentLedger] &&
    FreeQ[factorizationLaurentLedger, epsilon | D | Abs]
|>;
require[And @@ Values[factorizationChecks],
  "factorization ledger failed", factorizationChecks];
Print["S07_FACTORIZATION_READY"];

factorizationPrincipalRoots = DeleteDuplicates@Cases[
  factorizationLaurentLedger,
  Power[Power[_, 2], Rational[1, 2]], Infinity];
factorizationCacheChecks = <|
  "AcceptedInputHashes" -> And @@ Values[inputHashChecks],
  "BornToolchain" -> And @@ Flatten[Values /@ Values[bornGaugeChecks]],
  "BornHqqAgreement" -> And @@ Values[hqqBornAgreement],
  "StateAndColorCounts" -> And @@ Values[stateCountChecks],
  "SplittingKernels" -> And @@ Values[kernelReconstructionChecks],
  "Factorization" -> And @@ Values[factorizationChecks],
  "PrincipalRootInventoryClosed" ->
    FreeQ[factorizationPrincipalRoots,
      $Failed | _Missing | _Real | ConditionalExpression |
        Indeterminate | ComplexInfinity | DirectedInfinity]
|>;
require[And @@ Values[factorizationCacheChecks],
  "factorization cache gates failed", factorizationCacheChecks];
Print["S07_FACTORIZATION_PRINCIPAL_ROOTS=",
  InputForm[factorizationPrincipalRoots]];

If[factorizationOnlyMode,
  factorizationCache = <|
    "Stage" -> "HqqV2S07FactorizationCache-v1",
    "ScopeTag" -> scopeTag,
    "ProducerSource" -> <|"Path" -> sourcePath,
      "SHA256" -> sourceHash|>,
    "Inputs" -> <|
      "PaperSHA256" -> FileHash[paperPath, "SHA256", "HexString"],
      "S03SourceSHA256" -> expectedS03SourceHash,
      "S03ResultSHA256" -> expectedS03ResultHash,
      "S04SourceSHA256" -> expectedS04SourceHash,
      "S04ResultSHA256" -> expectedS04ResultHash,
      "S05SourceSHA256" -> expectedS05SourceHash,
      "S05ResultSHA256" -> expectedS05ResultHash,
      "S06SourceSHA256" -> expectedS06SourceHash,
      "S06ResultSHA256" -> expectedS06ResultHash|>,
    "Runtime" -> <|"Wolfram" -> $Version,
      "FeynCalc" -> FeynCalc`$FeynCalcVersion|>,
    "Conventions" -> <|
      "Dimension" -> 4 - 2 epsilon,
      "Scheme" -> "MSbar",
      "CouplingCanonicalization" -> couplingCanonicalization,
      "FactorizationEquation" -> 46,
      "FactorizationPrefactor" -> factorizationPrefactor,
      "PhysicalEndpoint" -> physicalBoundary,
      "BoundedPlusHead" ->
        HoldForm[HqqV2BoundedPlus[0, s23, physicalBoundary]]|>,
    "LowerBorn" -> <|
      "DiagramLedger" -> bornDiagramLedger,
      "Projected" -> bornProjected,
      "HqqAgreementWithS03" -> hqqBornAgreement,
      "HqqRatiosToS03" -> hqqBornRatios,
      "StateCounts" -> <|
        "QuarkSpin" -> quarkSpinStates,
        "QuarkColor" -> quarkColorStates,
        "GluonSpin" -> gluonSpinStates,
        "GluonColor" -> gluonColorStates,
        "QuarkAverage" -> quarkAverage,
        "GluonAverage" -> gluonAverage,
        "TF" -> tfValue, "CF" -> cfValue,
        "Checks" -> stateCountChecks|>|>,
    "SplittingKernels" -> <|
      "Definitions" -> kernelDefinitions,
      "Decomposition" -> splittingKernels,
      "Checks" -> kernelReconstructionChecks|>,
    "Factorization" -> <|
      "Routes" -> routeSpecifications,
      "InitialConstraint" -> initialConstraint,
      "FinalConstraint" -> finalConstraint,
      "InverseFractionRules" -> inverseFractionRules,
      "ConservationRule" -> u1Rule,
      "ByRouteLaurent" -> factorizationByRoute,
      "LaurentLedger" -> factorizationLaurentLedger,
      "PrincipalRoots" -> factorizationPrincipalRoots,
      "Checks" -> factorizationChecks|>,
    "Checks" -> factorizationCacheChecks|>;
  Print["S07_STAGE=atomic factorization cache publication"];
  atomicPut[factorizationCache, factorizationCachePath];
  factorizationCacheReload = Quiet@Check[
    Get[factorizationCachePath], $Failed];
  require[SameQ[factorizationCacheReload, factorizationCache] &&
      And @@ Values[factorizationCacheReload["Checks"]],
    "fresh factorization cache reload failed"];
  Print["S07_FACTORIZATION_CACHE_SHA256=",
    FileHash[factorizationCachePath, "SHA256", "HexString"]];
  Print["S07_FACTORIZATION_CACHE_READY"];
  Quit[0]
];

Clear[pushforwards, bornWardResiduals, acceptedHqqBorn,
  twoBodyKinematics, twoBodyPairRules];

(* Load the two accepted unsubtracted ledgers only at their combination boundary. *)
Print["S07_STAGE=load accepted real and virtual ledgers"];
s05 = Quiet@Check[Get[s05ResultPath], $Failed];
require[AssociationQ[s05] && s05["Stage"] === "HqqV2S05-v1" &&
    s05["ScopeTag"] === scopeTag && And @@ Values[s05["Checks"]],
  "accepted S05 result failed its gates"];
s06 = Quiet@Check[Get[s06ResultPath], $Failed];
require[AssociationQ[s06] && s06["Stage"] === "HqqV2S06-v1" &&
    s06["ScopeTag"] === scopeTag && And @@ Values[s06["Checks"]],
  "accepted S06 result failed its gates"];
realLedger = s05["RealLaurentLedger"];
virtualLedger = s06["VirtualLaurentLedger"];
realFamilies = Keys[realLedger["Pg"]];
require[Keys[realLedger] === projectorLabels &&
    Keys[virtualLedger] === projectorLabels &&
    realFamilies === {"Hqq;gg", "Hqq;q_qbar_sameFlavor",
      "Hqq;qPrime_qbarPrime"},
  "accepted real/virtual ledger schema changed"];

(* Put every saved field into one tool-derived special-function basis before
   exact addition.  S05 retains endpoint Gamma-function derivatives whereas
   S06 is already expanded; expanding only the discovered atoms avoids a
   global FunctionExpand over the large ledgers. *)
combinationSpecialAtoms = DeleteDuplicates@Cases[
  {realLedger, virtualLedger, factorizationLaurentLedger},
  _PolyGamma, Infinity];
combinationSpecialValues = Quiet@Check[
  FunctionExpand /@ combinationSpecialAtoms, $Failed];
require[combinationSpecialValues =!= $Failed &&
    Length[combinationSpecialValues] === Length[combinationSpecialAtoms] &&
    FreeQ[combinationSpecialValues, _PolyGamma] &&
    ! badSymbolicQ[combinationSpecialValues],
  "special-function basis expansion failed"];
combinationSpecialResiduals = Quiet@Check[
  MapThread[FullSimplify[#1 - #2] &,
    {combinationSpecialAtoms, combinationSpecialValues}], $Failed];
require[combinationSpecialResiduals =!= $Failed &&
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "special-function basis identities failed",
  combinationSpecialResiduals];
combinationSpecialRules = MapThread[Rule,
  {combinationSpecialAtoms, combinationSpecialValues}];
combinationBasisChecks = <|
  "AtomsDiscovered" -> combinationSpecialAtoms =!= {},
  "ExactIdentities" ->
    And @@ (SameQ[#, 0] & /@ combinationSpecialResiduals),
  "ExpandedBasis" -> FreeQ[combinationSpecialValues, _PolyGamma]
|>;
require[And @@ Values[combinationBasisChecks],
  "combination basis gates failed", combinationBasisChecks];
Print["S07_COMBINATION_SPECIAL_RULES=",
  InputForm[combinationSpecialRules]];
Clear[s05, s06];

sectorNames = {"Delta", "BoundedPlus", "Ordinary"};
realSectorName = <|"Delta" -> "DeltaLaurent",
  "BoundedPlus" -> "BoundedPlusLaurent",
  "Ordinary" -> "OrdinaryLaurent"|>;
virtualSectorName = realSectorName;

ClearAll[canonicalCombinationBasis, canonicalReal, canonicalVirtual,
  canonicalFactorization];
canonicalCombinationBasis[expression_] :=
  expression /. combinationSpecialRules;
canonicalReal[expression_, "Delta"] :=
  canonicalCombinationBasis[expression] /. u1Rule /. s23 -> 0;
canonicalReal[expression_, _String] :=
  canonicalCombinationBasis[expression] /. u1Rule;
canonicalVirtual[expression_] := canonicalCombinationBasis[expression] /.
  {tHat -> t1, uHat -> u1} /. u1Rule /. s23 -> 0;
canonicalFactorization[expression_, "Delta"] :=
  canonicalCombinationBasis[expression] /. s23 -> 0;
canonicalFactorization[expression_, _String] :=
  canonicalCombinationBasis[expression];

ClearAll[balancedExactSum, denominatorGroupedCombination];
balancedExactSum[values_List, label_String] := Module[{level, next},
  level = DeleteCases[values, 0];
  If[level === {}, Return[0]];
  level = Quiet@Check[Cancel[Together[#]] & /@ level, $Failed];
  require[level =!= $Failed && ! badSymbolicQ[level],
    label <> " canonicalization failed"];
  level = DeleteCases[level, 0];
  While[Length[level] > 1,
    level = SortBy[level, LeafCount];
    next = Map[If[Length[#] === 1, First[#],
      Quiet@Check[Cancel[Together[#[[1]] + #[[2]]]], $Failed]] &,
      Partition[level, UpTo[2]]];
    require[FreeQ[next, $Failed] && ! badSymbolicQ[next],
      label <> " balanced exact addition failed"];
    level = DeleteCases[next, 0]];
  If[level === {}, 0, First[level]]
];

denominatorGroupedCombination[expressions_List, label_String,
    proveZeroQ_] := Module[
  {accumulator = <||>, terms, canonical, denominator, numerator,
   denominatorHash, group, levels, level, carry, groupTotals,
   additiveExpression, zeroResidual},
  Do[
    terms = If[Head[expression] === Plus,
      List @@ expression, {expression}];
    Do[
      If[TrueQ[term === 0], Continue[]];
      canonical = Quiet@Check[Cancel[Together[term]], $Failed];
      require[canonical =!= $Failed && ! badSymbolicQ[canonical],
        label <> " term canonicalization failed"];
      If[TrueQ[canonical === 0], Continue[]];
      denominator = Denominator[canonical];
      numerator = Numerator[canonical];
      denominatorHash = IntegerString[
        Hash[denominator, "SHA256"], 16, 64];
      If[KeyExistsQ[accumulator, denominatorHash],
        group = accumulator[denominatorHash];
        require[SameQ[group["Denominator"], denominator],
          label <> " denominator hash collision"],
        group = <|"Denominator" -> denominator, "Levels" -> <||>|>];
      levels = group["Levels"];
      level = 0;
      carry = numerator;
      While[KeyExistsQ[levels, level],
        carry = Quiet@Check[Cancel[Together[
          levels[level] + carry]], $Failed];
        require[carry =!= $Failed && ! badSymbolicQ[carry],
          label <> " numerator accumulation failed"];
        KeyDropFrom[levels, level];
        level++;
        If[TrueQ[carry === 0], Break[]]];
      If[! TrueQ[carry === 0], AssociateTo[levels, level -> carry]];
      AssociateTo[group, "Levels" -> levels];
      AssociateTo[accumulator, denominatorHash -> group],
      {term, terms}],
    {expression, expressions}];
  groupTotals = KeyValueMap[Function[{hash, storedGroup},
    With[{summedNumerator = balancedExactSum[
        Values[KeySort[storedGroup["Levels"]]],
        label <> "/denominator/" <> StringTake[hash, 12]]},
      If[TrueQ[summedNumerator === 0], 0,
        Cancel[summedNumerator/storedGroup["Denominator"]]]]],
    KeySort[accumulator]];
  groupTotals = DeleteCases[groupTotals, 0];
  additiveExpression = If[groupTotals === {}, 0, Total[groupTotals]];
  zeroResidual = If[TrueQ[proveZeroQ],
    balancedExactSum[groupTotals, label <> "/cross-denominator"],
    Missing["NotRequested"]];
  Print["S07_GROUPED_SUM=", label, " DENOMINATORS=",
    Length[accumulator], " NONZERO_GROUPS=", Length[groupTotals],
    If[TrueQ[proveZeroQ], " ZERO=" <> ToString[SameQ[zeroResidual, 0]],
      ""]];
  <|"Expression" -> additiveExpression,
    "ZeroResidual" -> zeroResidual,
    "DenominatorCount" -> Length[accumulator],
    "NonzeroGroupCount" -> Length[groupTotals]|>
];

ClearAll[fieldContributions];
fieldContributions[projector_, sector_, power_] := Join[
  Table[canonicalReal[Lookup[
    realLedger[projector, family, realSectorName[sector]], power, 0],
    sector], {family, realFamilies}],
  {canonicalVirtual[Lookup[
    virtualLedger[projector, virtualSectorName[sector]], power, 0]]},
  {canonicalFactorization[Lookup[
    factorizationLaurentLedger[projector, sector], power, 0], sector]}];

Print["S07_STAGE=exact pole cancellation"];
poleCombinationMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    Association@Table[power -> Module[{combined},
      Print["S07_POLE_FIELD=", projector, "/", sector,
        "/", power];
      combined = denominatorGroupedCombination[
        fieldContributions[projector, sector, power],
        projector <> "/" <> sector <> "/epsilon" <> ToString[power],
        True];
      require[SameQ[combined["ZeroResidual"], 0],
        projector <> "/" <> sector <> " pole did not cancel",
        <|"Power" -> power,
          "Residual" -> combined["ZeroResidual"]|>];
      combined], {power, -2, -1}]], sectorNames]], projectorLabels];
poleResiduals = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    AssociationMap[Lookup[
      poleCombinationMetadata[projector, sector, #],
      "ZeroResidual"] &, {-2, -1}]], sectorNames]], projectorLabels];
poleResidualList = Flatten[Table[
  poleResiduals[projector, sector, power],
  {projector, projectorLabels}, {sector, sectorNames},
  {power, {-2, -1}}]];
require[And @@ (SameQ[#, 0] & /@ poleResidualList),
  "one or more exact pole residuals are nonzero"];

Print["S07_STAGE=finite projected actions"];
finiteCombinationMetadata = AssociationMap[Function[projector,
  AssociationMap[Function[sector,
    Print["S07_FINITE_FIELD=", projector, "/", sector];
    denominatorGroupedCombination[
      fieldContributions[projector, sector, 0],
      projector <> "/" <> sector <> "/finite", False]],
    sectorNames]], projectorLabels];
finiteProjectedActions = AssociationMap[Function[projector,
  AssociationMap[finiteCombinationMetadata[projector, #,
      "Expression"] &, sectorNames]], projectorLabels];

schemeTaggedActions = finiteProjectedActions /.
  {EulerGamma -> s07EulerGammaTag,
    HoldPattern[Log[4 Pi]] -> s07Log4PiTag};
schemeConstantGate = FreeQ[schemeTaggedActions,
  s07EulerGammaTag | s07Log4PiTag];

checks = <|
  "AcceptedInputHashes" -> And @@ Values[inputHashChecks],
  "AcceptedSchemas" -> Keys[realLedger] === projectorLabels &&
    Keys[virtualLedger] === projectorLabels,
  "BornToolchain" -> And @@ Flatten[Values /@ Values[bornGaugeChecks]],
  "BornHqqAgreement" -> And @@ Values[hqqBornAgreement],
  "StateAndColorCounts" -> And @@ Values[stateCountChecks],
  "SplittingKernels" -> And @@ Values[kernelReconstructionChecks],
  "Factorization" -> And @@ Values[factorizationChecks],
  "CombinationSpecialFunctionBasis" ->
    And @@ Values[combinationBasisChecks],
  "EveryDoubleAndSinglePoleZero" ->
    And @@ (SameQ[#, 0] & /@ poleResidualList),
  "FiniteProjectorSchema" ->
    Keys[finiteProjectedActions] === projectorLabels &&
      And @@ (Keys[#] === sectorNames & /@
        Values[finiteProjectedActions]),
  "MSbarConstantsCancel" -> TrueQ[schemeConstantGate],
  "FiniteExact" -> ! badSymbolicQ[finiteProjectedActions] &&
    FreeQ[finiteProjectedActions,
      epsilon | D | FeynCalc`EpsilonUV | FeynCalc`EpsilonIR | Abs],
  "NoForeignProductionCache" -> True
|>;
Print["S07_CHECKS=", InputForm[checks]];
require[And @@ Values[checks], "S07 final gates failed", checks];

result = <|
  "Stage" -> "HqqV2S07-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Inputs" -> <|
    "PaperSHA256" -> FileHash[paperPath, "SHA256", "HexString"],
    "S03SourceSHA256" -> expectedS03SourceHash,
    "S03ResultSHA256" -> expectedS03ResultHash,
    "S04SourceSHA256" -> expectedS04SourceHash,
    "S04ResultSHA256" -> expectedS04ResultHash,
    "S05SourceSHA256" -> expectedS05SourceHash,
    "S05ResultSHA256" -> expectedS05ResultHash,
    "S06SourceSHA256" -> expectedS06SourceHash,
    "S06ResultSHA256" -> expectedS06ResultHash|>,
  "Runtime" -> <|"Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "ParallelPolicy" ->
      "serial: six large exact distribution fields share loaded ledgers; interkernel copies would dominate and risk memory exhaustion"|>,
  "Conventions" -> <|
    "Dimension" -> 4 - 2 epsilon,
    "Scheme" -> "MSbar",
    "CouplingCanonicalization" -> couplingCanonicalization,
    "FactorizationEquation" -> 46,
    "FactorizationPrefactor" -> factorizationPrefactor,
    "PhysicalEndpoint" -> physicalBoundary,
    "BoundedPlusHead" ->
      HoldForm[HqqV2BoundedPlus[0, s23, physicalBoundary]]|>,
  "LowerBorn" -> <|
    "DiagramLedger" -> bornDiagramLedger,
    "Projected" -> bornProjected,
    "HqqAgreementWithS03" -> hqqBornAgreement,
    "HqqRatiosToS03" -> hqqBornRatios,
    "StateCounts" -> <|
      "QuarkSpin" -> quarkSpinStates,
      "QuarkColor" -> quarkColorStates,
      "GluonSpin" -> gluonSpinStates,
      "GluonColor" -> gluonColorStates,
      "QuarkAverage" -> quarkAverage,
      "GluonAverage" -> gluonAverage,
      "TF" -> tfValue, "CF" -> cfValue,
      "Checks" -> stateCountChecks|>|>,
  "SplittingKernels" -> <|
    "Definitions" -> kernelDefinitions,
    "Decomposition" -> splittingKernels,
    "Checks" -> kernelReconstructionChecks|>,
  "Factorization" -> <|
    "Routes" -> routeSpecifications,
    "InitialConstraint" -> initialConstraint,
    "FinalConstraint" -> finalConstraint,
    "InverseFractionRules" -> inverseFractionRules,
    "ConservationRule" -> u1Rule,
    "ByRouteLaurent" -> factorizationByRoute,
    "LaurentLedger" -> factorizationLaurentLedger,
    "Checks" -> factorizationChecks|>,
  "PoleLedger" -> <|
    "CombinationMetadata" -> poleCombinationMetadata,
    "Residuals" -> poleResiduals|>,
  "PoleResidualList" -> poleResidualList,
  "FiniteCombinationMetadata" -> finiteCombinationMetadata,
  "FiniteProjectedActions" -> finiteProjectedActions,
  "DownstreamBoundary" ->
    "S08 derives Eq. (9) weights and applies them only to these finite Pg/PPP actions",
  "Checks" -> checks|>;

Print["S07_STAGE=atomic result publication"];
atomicPut[result, resultPath];
Print["S07_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_CANDIDATE_READY"];
Quit[0];

(* Hqq_v2 S03 correction: tool-derived external-leg LSZ contribution. *)
$HistoryLength = 0;
$IterationLimit = Infinity;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {"FeynArts", "FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym, FrontEndObject::notavail}];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;
$KeepLogDivergentScalelessIntegrals = True;

ClearAll[
  hqqV2Fail, hqqV2Require, atomicPut, namedSymbolQ,
  replaceNamedObject, convertGeneratedAmplitudes, reduceToPV,
  quarkBasisCoefficient, gluonMetricCoefficient, evaluateSplit,
  evaluateUV, evaluateIR, r, lRC, rho2, aRC, bRC,
  hqqV2QuarkBasisTag, hqqV2AxialBasisTag, hqqV2ZQTag,
  hqqV2ZGTag, hqqV2LoopOrderTag
];

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
hqqV2Fail[msg_String] := (Print["S03_LSZ_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] := If[! TrueQ[test], hqqV2Fail[msg]];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], hqqV2Fail["failed to write " <> path]];
  hqqV2Require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "temporary result is missing or empty"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  hqqV2Require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"]
];
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

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
preLSZResultPath = FileNameJoin[{stageDirectory,
  "s03_result_pre_lsz_superseded_bb9b4c75.wl"}];
probeSourcePath = FileNameJoin[{stageDirectory,
  "s03_probe_scaleless_uv_ir.wl"}];
probeResultPath = FileNameJoin[{stageDirectory,
  "s03_scaleless_uv_ir_probe_result.wl"}];
resultPath = FileNameJoin[{stageDirectory, "s03_result.wl"}];

expectedPreLSZHash =
  "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4";
expectedPreLSZSourceHash =
  "379e463f748adae363c693cd39afd4a8dc5420e3a096e98d60c73d9a9afeca0b";
expectedProbeSourceHash =
  "1dd26643be835b2c8b24d8893b6462e8345cf420110eabac0dc8db59cbef197f";
expectedProbeResultHash =
  "83bda791f6f2ecb448cb9cf6dd190734bc6be97de19267f50d5866de2a9a6293";

hqqV2Require[And @@ (FileExistsQ /@ {preLSZResultPath,
    probeSourcePath, probeResultPath}), "a correction input is missing"];
hqqV2Require[
  FileHash[preLSZResultPath, "SHA256", "HexString"] === expectedPreLSZHash &&
  FileHash[probeSourcePath, "SHA256", "HexString"] === expectedProbeSourceHash &&
  FileHash[probeResultPath, "SHA256", "HexString"] === expectedProbeResultHash,
  "a correction input identity mismatches"];
preLSZ = Get[preLSZResultPath];
probe = Get[probeResultPath];
hqqV2Require[
  AssociationQ[preLSZ] && preLSZ["Stage"] === "HqqV2S03-v1" &&
    preLSZ["Source", "SHA256"] === expectedPreLSZSourceHash &&
    preLSZ["ScopeTag"] === scopeTag && And @@ Values[preLSZ["Checks"]],
  "superseded pre-LSZ checkpoint is not the accepted former S03 result"];
hqqV2Require[
  AssociationQ[probe] &&
    probe["Stage"] === "HqqV2S03ScalelessUVIRProbe-v1" &&
    probe["SourceSHA256"] === expectedProbeSourceHash &&
    And @@ Values[probe["Checks"]],
  "scaleless UV/IR convention probe is not accepted"];
hqqV2Require[
  TrueQ[Together[probe["DirectBubble", "Split"] -
      1/FeynCalc`EpsilonUV + 1/FeynCalc`EpsilonIR] === 0],
  "stored Package-X scaleless split is not the accepted exact convention"];

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
couplingRules = preLSZ["Renormalization", "CouplingCanonicalization",
  "AppliedRules"];
hqqV2Require[ListQ[couplingRules] && couplingRules =!= {} &&
    FreeQ[FeynCalc`SMP["g_s"] /. couplingRules, FeynCalc`SMP["g_s"]],
  "former S03 result does not provide its tool-derived coupling map"];

convertGeneratedAmplitudes[insertions_, incoming_List, outgoing_List,
    loopMomenta_List, lorentzNames_List] := Module[{raw, converted},
  raw = FeynArts`CreateFeynAmp[insertions,
    FeynArts`Truncated -> True, FeynArts`GaugeRules -> {},
    FeynArts`PreFactor -> 1];
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
    "FeynArts-to-FeynCalc self-energy conversion failed"];
  converted = converted /.
    HoldPattern[FeynArts`FCGV[name_String]] :> FeynCalc`FCGV[name];
  converted = Fold[replaceNamedObject[#1, #2, 0] &,
    converted, {"MQU", "MQD"}];
  hqqV2Require[FreeQ[converted,
      object : head_[___] /;
        MemberQ[{"MQU", "MQD"}, SymbolName[Unevaluated[head]]]],
    "a mass survived generated self-energy conversion"];
  converted /. couplingRules
];

reduceToPV[amplitude_, loopMomentum_, label_String] := Module[
  {prepared, reduced},
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
  hqqV2Require[prepared =!= $Failed, label <> " preparation failed"];
  reduced = CheckAbort[Quiet@Check[
    FeynCalc`TID[prepared, loopMomentum,
      FeynCalc`ToPaVe -> True,
      FeynCalc`UsePaVeBasis -> True,
      FeynCalc`FeynAmpDenominatorSimplify -> False,
      FeynCalc`ApartFF -> False,
      FeynCalc`FCParallelize -> False,
      FeynCalc`FCVerbose -> 0], $Failed], $Failed];
  hqqV2Require[reduced =!= $Failed &&
      FreeQ[reduced, loopMomentum | FeynCalc`TID | _Real],
    label <> " TID reduction failed"];
  reduced
];

quarkVectorBasis = FeynCalc`FCI[FeynCalc`GSD[r]] /. D -> 4;
quarkAxialBasis =
  FeynCalc`FCI[FeynCalc`GSD[r] . FeynCalc`GA[5]] /. D -> 4;
quarkBasisCoefficient[expression_, label_String] := Module[
  {simplified, tagged, axialCoefficient},
  simplified = FeynCalc`DiracSimplify[
    FeynCalc`SUNSimplify[expression /. D -> 4,
      FeynCalc`Explicit -> True,
      FeynCalc`SUNNToCACF -> False,
      FeynCalc`FCVerbose -> 0],
    FeynCalc`DiracSubstitute67 -> True,
    FeynCalc`ToDiracGamma67 -> False,
    FeynCalc`FCVerbose -> 0];
  tagged = simplified /. quarkAxialBasis -> hqqV2AxialBasisTag /.
    quarkVectorBasis -> hqqV2QuarkBasisTag;
  hqqV2Require[FreeQ[tagged, _FeynCalc`DiracGamma],
    label <> " did not reduce to the quark vector/axial basis"];
  axialCoefficient = Together[Coefficient[tagged, hqqV2AxialBasisTag]];
  hqqV2Require[TrueQ[axialCoefficient === 0],
    label <> " generated a nonzero axial coefficient"];
  Together[Coefficient[tagged, hqqV2QuarkBasisTag]]
];

gluonMetricCoefficient[expression_, label_String] := Module[{answer},
  answer = FeynCalc`SUNSimplify[
    FeynCalc`Contract[FeynCalc`MT[aRC, bRC] (expression /. D -> 4)],
    FeynCalc`Explicit -> True,
    FeynCalc`SUNNToCACF -> False,
    FeynCalc`FCVerbose -> 0];
  answer = FeynCalc`ExpandScalarProduct[answer] /.
    FeynCalc`SPD[r, r] -> -rho2;
  hqqV2Require[FreeQ[answer, _FeynCalc`LorentzIndex | _Real | $Failed],
    label <> " metric projection failed"];
  Together[answer]
];

evaluateSplit[expression_, label_String] := Module[{answer},
  answer = CheckAbort[Quiet@Check[
    FeynCalc`PaXEvaluateUVIRSplit[expression, lRC,
      FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 | FeynCalc`D0 |
      FeynCalc`PaVe | _FeynCalc`FeynAmpDenominator | _Real],
    label <> " UV/IR split failed"];
  Together[answer]
];
evaluateUV[expression_, label_String] := Module[{answer},
  answer = CheckAbort[Quiet@Check[
    FeynCalc`PaXEvaluateUV[expression, lRC,
      FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 | FeynCalc`D0 |
      FeynCalc`PaVe | _FeynCalc`FeynAmpDenominator | _Real],
    label <> " UV extraction failed"];
  Together[answer]
];
evaluateIR[expression_, label_String] := Module[{answer},
  answer = CheckAbort[Quiet@Check[
    FeynCalc`PaXEvaluateIR[expression, lRC,
      FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D], $Failed], $Failed];
  hqqV2Require[answer =!= $Failed && FreeQ[answer,
      FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 | FeynCalc`D0 |
      FeynCalc`PaVe | _FeynCalc`FeynAmpDenominator | _Real],
    label <> " IR extraction failed"];
  Together[answer]
];

Print["S03_LSZ_STAGE=generate quark self energy"];
qcdExternalExclusions = {
  FeynArts`S[_], FeynArts`V[1 | 2 | 3], FeynArts`F[4]
};
qTopologies = FeynArts`CreateTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
qInsertions = FeynArts`InsertFields[qTopologies,
  {FeynArts`F[3, {1}]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];
qCTTopologies = FeynArts`CreateCTTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
qCTInsertions = FeynArts`InsertFields[qCTTopologies,
  {FeynArts`F[3, {1}]} -> {FeynArts`F[3, {1}]},
  FeynArts`InsertionLevel -> {FeynArts`Particles},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> qcdExternalExclusions];
qLoopRows = convertGeneratedAmplitudes[qInsertions, {r}, {r}, {lRC}, {}] /.
  gaugeOneRules;
qCTRows = convertGeneratedAmplitudes[qCTInsertions, {r}, {r}, {}, {}];
hqqV2Require[Length[qLoopRows] === 1 && Length[qCTRows] === 1,
  "quark loop/counterterm inventory is not one plus one"];
FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[r, r] = -rho2;
qLoopPV = reduceToPV[Total[qLoopRows], lRC, "quark self energy"];
qCT = Fold[replaceNamedObject[#1, #2, 0] &, Total[qCTRows], {"dMf1"}];
qCT = replaceNamedObject[
  replaceNamedObject[qCT, "dZfL1", hqqV2ZQTag],
  "dZfR1", hqqV2ZQTag] /. couplingRules;
qLoopScalar = quarkBasisCoefficient[qLoopPV, "quark loop"];
qCTScalar = quarkBasisCoefficient[qCT, "quark counterterm"];
hqqV2Require[Exponent[qCTScalar, hqqV2ZQTag] === 1 &&
    TrueQ[Together[qCTScalar /. hqqV2ZQTag -> 0] === 0],
  "quark counterterm is not linear in its field constant"];
qCTUnitScalar = Coefficient[qCTScalar, hqqV2ZQTag];
qLoopToCTPV = Cancel[qLoopScalar/qCTUnitScalar];
qLoopToCTOnShell = Cancel[qLoopToCTPV] /. rho2 -> 0;
qLoopToCTOnShell = Together[qLoopToCTOnShell];
hqqV2Require[FreeQ[qLoopToCTOnShell,
    rho2 | Indeterminate | ComplexInfinity | DirectedInfinity] &&
    DeleteDuplicates@Cases[qLoopToCTOnShell,
      master : (FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
        FeynCalc`D0 | FeynCalc`PaVe)[___] :> master, Infinity] ===
      {FeynCalc`B0[0, 0, 0]},
  "quark on-shell residue did not reduce to the scaleless bubble"];
qLoopSplit = evaluateSplit[qLoopToCTOnShell, "quark self energy"];
qLoopUV = evaluateUV[qLoopToCTOnShell, "quark self energy"];
qLoopIR = evaluateIR[qLoopToCTOnShell, "quark self energy"];
hqqV2Require[TrueQ[Together[qLoopSplit - qLoopUV - qLoopIR] === 0],
  "quark UV/IR pieces do not reconstruct"];

Print["S03_LSZ_STAGE=generate gluon self energy"];
gTwoExclusions = {
  FeynArts`S[_], FeynArts`V[1 | 2 | 3],
  FeynArts`U[1 | 2 | 3 | 4], FeynArts`F[4]
};
gTopologies = FeynArts`CreateTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
gInsertions = FeynArts`InsertFields[gTopologies,
  {FeynArts`V[5]} -> {FeynArts`V[5]},
  FeynArts`InsertionLevel -> {FeynArts`Classes},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> gTwoExclusions];
gCTTopologies = FeynArts`CreateCTTopologies[1, 1 -> 1,
  FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles,
    FeynArts`WFCorrections, FeynArts`WFCorrectionCTs}];
gCTInsertions = FeynArts`InsertFields[gCTTopologies,
  {FeynArts`V[5]} -> {FeynArts`V[5]},
  FeynArts`InsertionLevel -> {FeynArts`Classes},
  FeynArts`Model -> "SMQCD", FeynArts`GenericModel -> "Lorentz",
  FeynArts`ExcludeParticles -> gTwoExclusions];
gLoopRows = convertGeneratedAmplitudes[gInsertions,
  {r}, {r}, {lRC}, {aRC, bRC}];
gCTRows = convertGeneratedAmplitudes[gCTInsertions,
  {r}, {r}, {}, {aRC, bRC}];
gQuarkTraceFlags =
  (! FreeQ[#, FeynCalc`DiracTrace | FeynCalc`DiracGamma] &) /@ gLoopRows;
hqqV2Require[Count[gQuarkTraceFlags, True] === 1,
  "gluon self energy does not contain exactly one quark row"];
activeFlavorCount = preLSZ["Renormalization", "ActiveFlavorCount"];
activeFlavorTypes = preLSZ["Renormalization", "ActiveFlavorTypes"];
hqqV2Require[activeFlavorTypes === {"DownType", "UpType"} &&
    TrueQ[activeFlavorCount ===
      Total[HqqV2FlavorMultiplicity /@ activeFlavorTypes]],
  "former S03 active-flavor ledger is inconsistent"];
gLoopRows = MapThread[If[#2, activeFlavorCount #1, #1] &,
  {gLoopRows, gQuarkTraceFlags}] /. gaugeOneRules;
FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[r, r] = -rho2;
gLoopPV = reduceToPV[Total[gLoopRows], lRC, "gluon self energy"];
gLongitudinal = FeynCalc`SUNSimplify[
  FeynCalc`Contract[FeynCalc`FVD[r, aRC] gLoopPV],
  FeynCalc`Explicit -> True, FeynCalc`SUNNToCACF -> False,
  FeynCalc`FCVerbose -> 0];
gLongitudinal = FeynCalc`ExpandScalarProduct[gLongitudinal] /.
  FeynCalc`SPD[r, r] -> -rho2;
hqqV2Require[TrueQ[Together[gLongitudinal] === 0],
  "generated full gluon self energy is not transverse"];
gCT = replaceNamedObject[Total[gCTRows], "dZGG1", hqqV2ZGTag] /.
  couplingRules;
gLoopScalar = gluonMetricCoefficient[gLoopPV, "gluon loop"];
gCTScalar = gluonMetricCoefficient[gCT, "gluon counterterm"];
hqqV2Require[Exponent[gCTScalar, hqqV2ZGTag] === 1 &&
    TrueQ[Together[gCTScalar /. hqqV2ZGTag -> 0] === 0],
  "gluon counterterm is not linear in its field constant"];
gCTUnitScalar = Coefficient[gCTScalar, hqqV2ZGTag];
gLoopToCTPV = Cancel[gLoopScalar/gCTUnitScalar];
gLoopToCTOnShell = Cancel[gLoopToCTPV] /. rho2 -> 0;
gLoopToCTOnShell = Together[gLoopToCTOnShell];
hqqV2Require[FreeQ[gLoopToCTOnShell,
    rho2 | Indeterminate | ComplexInfinity | DirectedInfinity] &&
    DeleteDuplicates@Cases[gLoopToCTOnShell,
      master : (FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 |
        FeynCalc`D0 | FeynCalc`PaVe)[___] :> master, Infinity] ===
      {FeynCalc`B0[0, 0, 0]},
  "gluon on-shell residue did not reduce to the scaleless bubble"];
gLoopSplit = evaluateSplit[gLoopToCTOnShell, "gluon self energy"];
gLoopUV = evaluateUV[gLoopToCTOnShell, "gluon self energy"];
gLoopIR = evaluateIR[gLoopToCTOnShell, "gluon self energy"];
hqqV2Require[TrueQ[Together[gLoopSplit - gLoopUV - gLoopIR] === 0],
  "gluon UV/IR pieces do not reconstruct"];

Print["S03_LSZ_STAGE=solve MS-renormalized residues"];
qMSCoefficient = preLSZ["Renormalization", "PoleCoefficients",
  "QuarkFieldLeft"];
hqqV2Require[TrueQ[Together[qMSCoefficient -
      preLSZ["Renormalization", "PoleCoefficients", "QuarkFieldRight"]] === 0],
  "former S03 quark field constants are not equal"];
gMSCoefficient = preLSZ["Renormalization", "PoleCoefficients",
  "GluonField"];
qMSMatch = TrueQ[Together[-FeynCalc`EpsilonUV qLoopUV -
    qMSCoefficient] === 0];
gMSMatch = TrueQ[Together[-FeynCalc`EpsilonUV gLoopUV -
    gMSCoefficient] === 0];
hqqV2Require[qMSMatch && gMSMatch,
  "on-shell self-energy UV pieces do not match the stored MS-bar constants"];

qOSCounterterm = Together[-qLoopSplit];
gOSCounterterm = Together[-gLoopSplit];
qMSCounterterm = qMSCoefficient/FeynCalc`EpsilonUV;
gMSCounterterm = gMSCoefficient/FeynCalc`EpsilonUV;
qRenormalizedResidue = Together[qOSCounterterm - qMSCounterterm];
gRenormalizedResidue = Together[gOSCounterterm - gMSCounterterm];
residueDifferenceChecks = <|
  "QuarkEqualsMinusIR" ->
    TrueQ[Together[qRenormalizedResidue + qLoopIR] === 0],
  "GluonEqualsMinusIR" ->
    TrueQ[Together[gRenormalizedResidue + gLoopIR] === 0],
  "QuarkUVFree" -> FreeQ[qRenormalizedResidue, FeynCalc`EpsilonUV],
  "GluonUVFree" -> FreeQ[gRenormalizedResidue, FeynCalc`EpsilonUV],
  "IRPresent" -> (! FreeQ[{qRenormalizedResidue, gRenormalizedResidue},
    FeynCalc`EpsilonIR]),
  "ExactResolved" -> FreeQ[{qRenormalizedResidue, gRenormalizedResidue},
    _Real | $Failed | Indeterminate | ComplexInfinity | DirectedInfinity |
    FeynCalc`A0 | FeynCalc`B0 | FeynCalc`C0 | FeynCalc`D0 | FeynCalc`PaVe]
|>;
hqqV2Require[And @@ Values[residueDifferenceChecks],
  "one or more MS-renormalized on-shell residue gates failed"];

bornProcessFields = Flatten[{
  {FeynArts`V[1], FeynArts`F[3, {1}]},
  {FeynArts`F[3, {1}], FeynArts`V[5]}
}];
qcdExternalTypes = bornProcessFields /. {
  FeynArts`V[1] -> Nothing,
  FeynArts`F[3, {1}] -> "Quark",
  FeynArts`V[5] -> "Gluon"
};
externalFieldCounts = Counts[qcdExternalTypes];
hqqV2Require[Sort[Keys[externalFieldCounts]] === {"Gluon", "Quark"} &&
    Total[Values[externalFieldCounts]] === Length[qcdExternalTypes],
  "Born process did not determine the QCD external-field counts"];
residuesByType = <|
  "Quark" -> qRenormalizedResidue,
  "Gluon" -> gRenormalizedResidue
|>;
lszProduct = Times @@ KeyValueMap[
  (1 + hqqV2LoopOrderTag residuesByType[#1])^(#2/2) &,
  externalFieldCounts];
lszAmplitudeCoefficient = Together@SeriesCoefficient[
  lszProduct, {hqqV2LoopOrderTag, 0, 1}];
lszDerivativeCoefficient = Together[
  D[lszProduct, hqqV2LoopOrderTag] /. hqqV2LoopOrderTag -> 0];
hqqV2Require[
  TrueQ[Together[lszAmplitudeCoefficient - lszDerivativeCoefficient] === 0] &&
  FreeQ[lszAmplitudeCoefficient,
    hqqV2LoopOrderTag | FeynCalc`EpsilonUV | _Real | $Failed],
  "external-leg square-root product was not derived exactly"];

projectorLabels = Keys[preLSZ["Projectors"]];
hqqV2Require[projectorLabels === {"Pg", "PPP"},
  "former S03 projector ledger is unexpected"];
lszProjectedRows = AssociationMap[
  {Together[lszAmplitudeCoefficient preLSZ["Projected", "Born", #]]} &,
  projectorLabels];
lszProjected = AssociationMap[Total[lszProjectedRows[#]] &,
  projectorLabels];
virtualUVRenormalizedWithLSZ = AssociationMap[
  preLSZ["Projected", "VirtualUVRenormalizedPV", #] + lszProjected[#] &,
  projectorLabels];

checks = <|
  "PreLSZIdentity" ->
    (FileHash[preLSZResultPath, "SHA256", "HexString"] === expectedPreLSZHash),
  "ProbeIdentities" ->
    (FileHash[probeSourcePath, "SHA256", "HexString"] === expectedProbeSourceHash &&
      FileHash[probeResultPath, "SHA256", "HexString"] === expectedProbeResultHash),
  "PreLSZChecksRetained" -> And @@ Values[preLSZ["Checks"]],
  "KeepScalelessEnabled" -> TrueQ[$KeepLogDivergentScalelessIntegrals],
  "GeneratedInventories" ->
    (Length[qLoopRows] === 1 && Length[qCTRows] === 1 &&
      Length[gLoopRows] ===
        preLSZ["Renormalization", "GeneratedObjectCounts",
          "GluonSelfEnergyLoop"] &&
      Length[gCTRows] ===
        preLSZ["Renormalization", "GeneratedObjectCounts",
          "GluonSelfEnergyCounterterm"]),
  "OneGluonQuarkLoop" -> (Count[gQuarkTraceFlags, True] === 1),
  "GluonTransverse" -> TrueQ[Together[gLongitudinal] === 0],
  "UVIRReconstruction" ->
    (TrueQ[Together[qLoopSplit - qLoopUV - qLoopIR] === 0] &&
      TrueQ[Together[gLoopSplit - gLoopUV - gLoopIR] === 0]),
  "StoredMSbarConstantsMatched" -> (qMSMatch && gMSMatch),
  "ResidueDifferenceChecks" -> And @@ Values[residueDifferenceChecks],
  "ExternalCountsDerived" ->
    (Sort[Keys[externalFieldCounts]] === {"Gluon", "Quark"}),
  "SquareRootProductDerived" ->
    TrueQ[Together[lszAmplitudeCoefficient - lszDerivativeCoefficient] === 0],
  "LSZRowsBornProportional" -> And @@ Map[
    TrueQ[Together[First[lszProjectedRows[#]] -
      lszAmplitudeCoefficient preLSZ["Projected", "Born", #]] === 0] &,
    projectorLabels],
  "LSZRowsUVFree" -> FreeQ[lszProjectedRows, FeynCalc`EpsilonUV],
  "LSZRowsIRPresent" -> ! FreeQ[lszProjectedRows, FeynCalc`EpsilonIR],
  "SymbolicExact" -> FreeQ[
    {qLoopToCTOnShell, gLoopToCTOnShell, qRenormalizedResidue,
      gRenormalizedResidue, lszAmplitudeCoefficient, lszProjectedRows},
    _Real | $Failed | Indeterminate | ComplexInfinity | DirectedInfinity]
|>;
Print["S03_LSZ_EXTERNAL_FIELD_COUNTS=", InputForm[externalFieldCounts]];
Print["S03_LSZ_RESIDUES=", InputForm[residuesByType]];
Print["S03_LSZ_AMPLITUDE_COEFFICIENT=", InputForm[lszAmplitudeCoefficient]];
Print["S03_LSZ_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks], "one or more final LSZ gates failed"];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
correctedProjected = Join[preLSZ["Projected"], <|
  "ExternalLSZDirectedRows" -> lszProjectedRows,
  "ExternalLSZDirected" -> lszProjected,
  "VirtualUVRenormalizedWithLSZ" -> virtualUVRenormalizedWithLSZ
|>];
correctedRenormalization = Join[preLSZ["Renormalization"], <|
  "ExternalLSZ" -> <|
    "Scheme" -> "MSbar amplitudes with on-shell external residues",
    "ScalelessConventionProbeSHA256" -> expectedProbeResultHash,
    "ExternalFieldCounts" -> externalFieldCounts,
    "LoopToCountertermPV" -> <|
      "Quark" -> qLoopToCTPV, "Gluon" -> gLoopToCTPV|>,
    "LoopToCountertermOnShell" -> <|
      "Quark" -> qLoopToCTOnShell, "Gluon" -> gLoopToCTOnShell|>,
    "LoopUV" -> <|"Quark" -> qLoopUV, "Gluon" -> gLoopUV|>,
    "LoopIR" -> <|"Quark" -> qLoopIR, "Gluon" -> gLoopIR|>,
    "OSCounterterms" -> <|
      "Quark" -> qOSCounterterm, "Gluon" -> gOSCounterterm|>,
    "MSbarCounterterms" -> <|
      "Quark" -> qMSCounterterm, "Gluon" -> gMSCounterterm|>,
    "RenormalizedResidues" -> residuesByType,
    "SquareRootProduct" -> lszProduct,
    "DirectedAmplitudeCoefficient" -> lszAmplitudeCoefficient,
    "Checks" -> residueDifferenceChecks
  |>
|>];
correctedUVLedger = Join[preLSZ["UVLedger"], <|
  "ExternalLSZUVFree" -> True,
  "ExternalLSZMSbarMatch" -> <|"Quark" -> qMSMatch, "Gluon" -> gMSMatch|>
|>];

result = Join[preLSZ, <|
  "Stage" -> "HqqV2S03-v2",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "SourceSHA256" -> sourceHash,
  "Correction" -> <|
    "Name" -> "ExternalLSZ",
    "PreLSZResultSHA256" -> expectedPreLSZHash,
    "PreLSZProducingSourceSHA256" -> expectedPreLSZSourceHash,
    "ScalelessProbeSourceSHA256" -> expectedProbeSourceHash,
    "ScalelessProbeResultSHA256" -> expectedProbeResultHash,
    "DependentMasterCachesReevaluated" -> False
  |>,
  "Projected" -> correctedProjected,
  "Renormalization" -> correctedRenormalization,
  "UVLedger" -> correctedUVLedger,
  "Checks" -> checks
|>];

Print["S03_LSZ_STAGE=atomic corrected result publication"];
atomicPut[result, resultPath];
reloaded = Get[resultPath];
hqqV2Require[
  AssociationQ[reloaded] && reloaded["Stage"] === "HqqV2S03-v2" &&
    reloaded["SourceSHA256"] === sourceHash &&
    And @@ Values[reloaded["Checks"]] &&
    reloaded["Correction", "PreLSZResultSHA256"] === expectedPreLSZHash,
  "same-kernel corrected-result reload failed"];
Print["S03_LSZ_RESULT_SHA256=", FileHash[resultPath, "SHA256", "HexString"]];
Print["S03_LSZ_RESULT_BYTES=", FileByteCount[resultPath]];
Print["S03_LSZ_SAME_KERNEL_RELOAD_OK"];
Print["S03_LSZ_SUCCESS"];
Quit[0];

(* Hqq_v2 S01: generate exact open-photon Hqq amplitudes through NLO. *)

$HistoryLength = 0;
$LoadFeynArts = True;
$FeynCalcStartupMessages = False;
Needs["FeynCalc`"];
FeynArts`$FAVerbose = 0;
$FCAdvice = False;

scopeTag = "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];

ClearAll[
  hqqV2Fail, hqqV2Require, atomicPut, fixPhotonCoupling,
  symbolizePhotonCharges, chargeDegree, couplingSignature,
  generateFamily, classEntry, quantumNumbers, electricQuantumNumber,
  chargeCoefficient, canonicalCharge, convertFamily, openPhotonIndex,
  quarkMassHeadQ, generationSymbolQ, unresolvedQ
];

hqqV2Fail[msg_String] := (Print["S01_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] := If[! TrueQ[test], hqqV2Fail[msg]];

atomicPut[expression_, path_String] := Module[{tmp},
  tmp = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[tmp], DeleteFile[tmp]];
  Check[Put[expression, tmp], hqqV2Fail["failed to write " <> path]];
  hqqV2Require[FileExistsQ[tmp] && FileByteCount[tmp] > 0,
    "temporary result is missing or empty"];
  RenameFile[tmp, path, OverwriteTarget -> True];
  hqqV2Require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published result is missing or empty"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
paperPath = FileNameJoin[{DirectoryName[stageDirectory],
  "Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf"}];
resultPath = FileNameJoin[{stageDirectory, "s01_result.wl"}];
sourcePath = ExpandFileName[$InputFileName];
hqqV2Require[FileExistsQ[paperPath], "authoritative paper is missing"];

(* The external fields are fixed by the paper's Hqq row.  k1 is observed. *)
incomingFields = {FeynArts`V[1], FeynArts`F[3, {1}]};
upField = FeynArts`F[3, {1}];
downField = FeynArts`F[4, {1}];
gluonField = FeynArts`V[5];

familySpecifications = <|
  "Born" -> <|
    "Kind" -> "Tree", "OutgoingFields" -> {upField, gluonField},
    "OutgoingMomenta" -> {k1, k2}, "LoopMomenta" -> {},
    "CouplingSignature" -> {1, 1}|>,
  "VirtualBare" -> <|
    "Kind" -> "Loop", "OutgoingFields" -> {upField, gluonField},
    "OutgoingMomenta" -> {k1, k2}, "LoopMomenta" -> {ell},
    "CouplingSignature" -> {1, 3}|>,
  "VirtualCounterterm" -> <|
    "Kind" -> "Counterterm", "OutgoingFields" -> {upField, gluonField},
    "OutgoingMomenta" -> {k1, k2}, "LoopMomenta" -> {},
    "CouplingSignature" -> {1, 1}|>,
  "Hqq;gg" -> <|
    "Kind" -> "Tree", "OutgoingFields" -> {upField, gluonField, gluonField},
    "OutgoingMomenta" -> {k1, k2, k3}, "LoopMomenta" -> {},
    "CouplingSignature" -> {1, 2}|>,
  "Hqq;q_qbar_sameFlavor" -> <|
    "Kind" -> "Tree", "OutgoingFields" -> {upField, upField, -upField},
    "OutgoingMomenta" -> {k1, k2, k3}, "LoopMomenta" -> {},
    "CouplingSignature" -> {1, 2}|>,
  "Hqq;qPrime_qbarPrime" -> <|
    "Kind" -> "Tree", "OutgoingFields" -> {upField, downField, -downField},
    "OutgoingMomenta" -> {k1, k2, k3}, "LoopMomenta" -> {},
    "CouplingSignature" -> {1, 2}|>
|>;

(* Only QCD, QED and their ghosts are allowed internally.  V[1] cannot be
   excluded globally because it is the external photon, so coupling-order
   selection below removes amplitudes with extra photon vertices. *)
excludedParticles = {
  FeynArts`V[2], FeynArts`V[3],
  FeynArts`S[1], FeynArts`S[2], FeynArts`S[3],
  FeynArts`F[1], FeynArts`F[2],
  FeynArts`U[1], FeynArts`U[2], FeynArts`U[3], FeynArts`U[4]
};

(* These vanish because the requested correction is purely QCD and every
   quark is massless.  QCD dZ symbols remain untouched for S02. *)
qcdCountertermProjectionRules = {
  dZAA1 -> 0, dZe1 -> 0, dZZA1 -> 0,
  HoldPattern[dMf1[___]] -> 0,
  HoldPattern[Conjugate[dMf1[___]]] -> 0
};

(* Replace the numeric charge inside every photon-fermion model coupling by
   a temporary exact marker.  The model-derived flavor charge and the
   fermion-flow orientation are canonicalized after all classes are loaded. *)
$HqqV2ChargeRewriteCount = 0;
$HqqV2RawCharges = {};

fixPhotonCoupling[value_] := Module[{numeric, rawCharge},
  If[FreeQ[value, FeynArts`FCGV["EL"]] &&
      FreeQ[value, FeynCalc`FCGV["EL"]],
    Return[value]];
  hqqV2Require[FreeQ[value,
      FeynArts`FCGV["SW"] | FeynCalc`FCGV["SW"] |
      FeynArts`FCGV["MW"] | FeynCalc`FCGV["MW"]],
    "an electroweak factor survived in a photon coupling"];
  numeric = If[Head[value] === Times,
    Times @@ Cases[List @@ value, _?NumberQ], 1];
  hqqV2Require[NumberQ[numeric] && numeric =!= 0,
    "a photon coupling has no exact numeric charge coefficient"];
  rawCharge = I numeric;
  hqqV2Require[Element[rawCharge, Rationals] && rawCharge =!= 0,
    "a photon coupling charge is not a nonzero rational"];
  $HqqV2ChargeRewriteCount++;
  $HqqV2RawCharges = Union[$HqqV2RawCharges, {rawCharge}];
  value HqqV2RawCharge[rawCharge]/rawCharge
];

symbolizePhotonCharges[amplitudes_] := amplitudes /.
  FeynArts`Insertions[FeynArts`Classes][values__List] :>
    FeynArts`Insertions[FeynArts`Classes] @@
      (Map[fixPhotonCoupling, #] & /@ {values});

chargeDegree[amp_] := Exponent[
  amp /. HqqV2RawCharge[_] :> hqqV2ChargeDegreeTag,
  hqqV2ChargeDegreeTag
];

couplingSignature[amp_] := Module[{probe},
  probe = Expand[amp /.
    {FeynArts`FCGV["EL"] -> hqqV2E,
      FeynCalc`FCGV["EL"] -> hqqV2E,
      FeynArts`FAGS -> hqqV2GS,
      HqqV2RawCharge[_] -> 1}];
  {Exponent[probe, hqqV2E], Exponent[probe, hqqV2GS]}
];

generateFamily[label_String, specification_Association] := Module[
  {kind, outgoing, topologies, insertions, raw, prepared, picked,
   pickedRows, signatures, wanted, selected, selectedRows, graphIDs,
   chargeBefore, ctNames, ctHeads},
  kind = specification["Kind"];
  outgoing = specification["OutgoingFields"];
  topologies = Switch[kind,
    "Counterterm",
      FeynArts`CreateCTTopologies[1, 2 -> Length[outgoing],
        FeynArts`ExcludeTopologies -> {FeynArts`WFCorrectionCTs}],
    "Loop",
      FeynArts`CreateTopologies[1, 2 -> Length[outgoing],
        FeynArts`ExcludeTopologies ->
          {FeynArts`Tadpoles, FeynArts`WFCorrections}],
    "Tree",
      FeynArts`CreateTopologies[0, 2 -> Length[outgoing],
        FeynArts`ExcludeTopologies -> {FeynArts`Tadpoles}],
    _, hqqV2Fail["unknown family kind " <> ToString[kind]]
  ];
  hqqV2Require[Length[topologies] > 0,
    "no topologies were generated for " <> label];
  insertions = FeynArts`InsertFields[topologies,
    incomingFields -> outgoing,
    FeynArts`InsertionLevel -> FeynArts`Classes,
    FeynArts`Model -> "SMQCD",
    FeynArts`ExcludeParticles -> excludedParticles];
  raw = FeynArts`CreateFeynAmp[insertions, FeynArts`Truncated -> False];
  hqqV2Require[Length[raw] > 0,
    "no amplitudes were generated for " <> label];
  prepared = If[kind === "Counterterm",
    raw /. qcdCountertermProjectionRules,
    raw
  ];
  hqqV2Require[FreeQ[prepared, dZAA1 | dZe1 | dZZA1 | _dMf1],
    "electroweak or mass counterterms survived in " <> label];
  chargeBefore = $HqqV2ChargeRewriteCount;
  prepared = symbolizePhotonCharges[prepared];
  hqqV2Require[$HqqV2ChargeRewriteCount > chargeBefore,
    "no photon charge was symbolized in " <> label];
  picked = FeynArts`PickLevel[FeynArts`Classes][prepared];
  pickedRows = List @@ picked;
  hqqV2Require[pickedRows =!= {},
    "class-level selection is empty for " <> label];
  signatures = couplingSignature /@ pickedRows;
  wanted = specification["CouplingSignature"];
  selected = Select[picked,
    couplingSignature[#] === wanted && chargeDegree[#] === 1 &];
  selectedRows = List @@ selected;
  hqqV2Require[selectedRows =!= {},
    "coupling-order selection is empty for " <> label];
  hqqV2Require[AllTrue[selectedRows,
      couplingSignature[#] === wanted && chargeDegree[#] === 1 &],
    "a selected amplitude has the wrong coupling order in " <> label];
  If[kind === "Counterterm",
    ctNames = {"dZGG1", "dZgs1", "dZfL1", "dZfR1"};
    ctHeads = Cases[selectedRows,
      symbol_Symbol /; MemberQ[ctNames, SymbolName[Unevaluated[symbol]]],
      Infinity, Heads -> True];
    hqqV2Require[ctHeads =!= {},
      "no QCD renormalization constant survived in the counterterm family"];
  ];
  graphIDs = DeleteDuplicates@Cases[selectedRows,
    _FeynArts`GraphID, Infinity];
  hqqV2Require[Length[graphIDs] === Length[selectedRows],
    "graph IDs are missing or nonunique in " <> label];
  Print["S01_FAMILY=", label,
    " unfiltered=", Length[raw],
    " class=", Length[pickedRows],
    " selected=", Length[selectedRows],
    " signatures=", InputForm[Counts[signatures]]];
  <|
    "SelectedFeynArts" -> selected,
    "UnfilteredCount" -> Length[raw],
    "ClassCount" -> Length[pickedRows],
    "SelectedCount" -> Length[selectedRows],
    "UnfilteredCouplingSignatures" -> Counts[signatures],
    "SelectedCouplingSignature" -> wanted,
    "GraphIDs" -> graphIDs
  |>
];

Print["S01_STAGE=generate FeynArts families"];
generated = Association@KeyValueMap[
  #1 -> generateFamily[#1, #2] &,
  familySpecifications
];

(* Read the SMQCD charge quantum numbers from the loaded class table. *)
classSymbols = Names["*M$ClassesDescription*"];
hqqV2Require[Length[classSymbols] === 1,
  "the loaded SMQCD class table is not unique"];
classDescriptions = ToExpression[First[classSymbols]];
classEntry[n_Integer] := FirstCase[classDescriptions,
  HoldPattern[FeynArts`F[n] == rhs_] :> rhs, Missing["NotFound"]];
quantumNumbers[n_Integer] := FirstCase[classEntry[n],
  Rule[key_, value_] /; SymbolName[Unevaluated[key]] === "QuantumNumbers" :>
    value, Missing["NotFound"], Infinity];
electricQuantumNumber[n_Integer] := Module[{qns = quantumNumbers[n]},
  If[ListQ[qns] && qns =!= {}, First[qns], Missing["NotFound"]]
];
chargeMarkers = DeleteDuplicates@Cases[
  {electricQuantumNumber[3], electricQuantumNumber[4]},
  symbol_Symbol /; SymbolName[Unevaluated[symbol]] === "Charge",
  Infinity
];
hqqV2Require[Length[chargeMarkers] === 1,
  "the SMQCD electric-charge marker is not unique"];
chargeMarker = First[chargeMarkers];
chargeCoefficient[n_Integer] := Together[electricQuantumNumber[n] /.
  chargeMarker -> 1];
upModelCharge = chargeCoefficient[3];
downModelCharge = chargeCoefficient[4];
hqqV2Require[Element[upModelCharge, Rationals] && upModelCharge =!= 0 &&
    Element[downModelCharge, Rationals] && downModelCharge =!= 0 &&
    Abs[upModelCharge] =!= Abs[downModelCharge],
  "model-derived quark charges are invalid"];

canonicalCharge[raw_] := Which[
  TrueQ[Abs[raw] === Abs[upModelCharge]],
    Together[raw/upModelCharge] HqqV2Charge["UpType"],
  TrueQ[Abs[raw] === Abs[downModelCharge]],
    Together[raw/downModelCharge] HqqV2Charge["DownType"],
  True,
    hqqV2Fail["unrecognized raw quark charge " <> ToString[raw, InputForm]]
];

quarkMassHeadQ[head_] :=
  MatchQ[Unevaluated[head], _Symbol] &&
    MemberQ[{"MQU", "MQD"}, SymbolName[Unevaluated[head]]];
generationSymbolQ[symbol_] :=
  MatchQ[Unevaluated[symbol], _Symbol] &&
    SymbolName[Unevaluated[symbol]] === "Generation";

masslessRules = {
  SMP["m_u"] -> 0, SMP["m_d"] -> 0, SMP["m_c"] -> 0,
  SMP["m_s"] -> 0, SMP["m_t"] -> 0, SMP["m_b"] -> 0,
  SMP["m_qu"] -> 0, SMP["m_qd"] -> 0,
  FeynArts`FCGV["MU"] -> 0, FeynArts`FCGV["MD"] -> 0,
  FeynArts`FCGV["MC"] -> 0, FeynArts`FCGV["MS"] -> 0,
  FeynArts`FCGV["MT"] -> 0, FeynArts`FCGV["MB"] -> 0,
  HoldPattern[head_Symbol[arguments___] /; quarkMassHeadQ[head]] :> 0
};

unresolvedQ[expression_] := ! FreeQ[expression,
  $Failed | _Real | _FeynArts`FAFeynAmp | _FeynArts`FCGV |
  (head_Symbol[___] /; quarkMassHeadQ[head])
];

convertFamily[label_String] := Module[
  {specification, converted},
  specification = familySpecifications[label];
  Print["S01_STAGE=convert ", label];
  converted = CheckAbort[
    Quiet@Check[
      FeynCalc`FCFAConvert[generated[label, "SelectedFeynArts"],
        FeynCalc`IncomingMomenta -> {q, p},
        FeynCalc`OutgoingMomenta -> specification["OutgoingMomenta"],
        FeynCalc`LoopMomenta -> specification["LoopMomenta"],
        FeynCalc`ChangeDimension -> D,
        FeynCalc`DropSumOver -> False,
        FeynCalc`UndoChiralSplittings -> True,
        FeynCalc`Contract -> False,
        FeynCalc`SMP -> True,
        List -> True,
        FeynCalc`FinalSubstitutions -> masslessRules],
      $Failed],
    $Failed
  ];
  hqqV2Require[ListQ[converted] &&
      Length[converted] === generated[label, "SelectedCount"],
    "FeynCalc conversion count mismatch for " <> label];
  converted = converted /.
    HoldPattern[FeynArts`FCGV[name_String]] :> FeynCalc`FCGV[name];
  converted = converted /. HqqV2RawCharge[value_] :> canonicalCharge[value];
  hqqV2Require[FreeQ[converted, HqqV2RawCharge] &&
      ! FreeQ[converted, _HqqV2Charge],
    "charge canonicalization failed for " <> label];
  hqqV2Require[! unresolvedQ[converted],
    "conversion is incomplete or nonexact for " <> label];
  converted
];

openPhotonIndex[amp_, index_Symbol, label_String] := Module[{answer},
  answer = FeynCalc`Contract[amp];
  hqqV2Require[! FreeQ[answer, FeynCalc`Polarization[q, ___]],
    label <> " has no incoming photon polarization"];
  answer = answer /. HoldPattern[
      FeynCalc`DiracGamma[
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], dim_]
    ] :> FeynCalc`DiracGamma[FeynCalc`LorentzIndex[index, dim], dim];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[FeynCalc`LorentzIndex[lor_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]]
    ] :> FeynCalc`Pair[FeynCalc`LorentzIndex[lor, dim],
      FeynCalc`LorentzIndex[index, dim]];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        FeynCalc`LorentzIndex[lor_, dim_]]
    ] :> FeynCalc`Pair[FeynCalc`LorentzIndex[index, dim],
      FeynCalc`LorentzIndex[lor, dim]];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_],
        FeynCalc`Momentum[momentum_, dim_]]
    ] :> FeynCalc`Pair[FeynCalc`LorentzIndex[index, dim],
      FeynCalc`Momentum[momentum, dim]];
  answer = answer /. HoldPattern[
      FeynCalc`Pair[FeynCalc`Momentum[momentum_, dim_],
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_]]
    ] :> FeynCalc`Pair[FeynCalc`Momentum[momentum, dim],
      FeynCalc`LorentzIndex[index, dim]];
  answer = answer /. HoldPattern[
      FeynCalc`Eps[before___,
        FeynCalc`Momentum[FeynCalc`Polarization[q, phase_], dim_], after___]
    ] :> FeynCalc`Eps[before, FeynCalc`LorentzIndex[index, dim], after];
  answer = FeynCalc`Contract[answer];
  hqqV2Require[FreeQ[answer, FeynCalc`Polarization[q, ___]] &&
      ! FreeQ[answer, FeynCalc`LorentzIndex[index, D]],
    label <> " photon-index opening failed"];
  answer
];

converted = AssociationMap[convertFamily, Keys[familySpecifications]];
openCurrentsPerDiagram = Association@KeyValueMap[
  Function[{label, rows},
    label -> MapIndexed[
      openPhotonIndex[#1, mu,
        label <> " diagram " <> ToString[First[#2]]] &,
      rows
    ]
  ],
  converted
];
openCurrentSums = AssociationMap[Total[openCurrentsPerDiagram[#]] &,
  Keys[openCurrentsPerDiagram]];

diagramLedger = AssociationMap[
  <|
    "UnfilteredCount" -> generated[#, "UnfilteredCount"],
    "ClassCount" -> generated[#, "ClassCount"],
    "SelectedCount" -> generated[#, "SelectedCount"],
    "UnfilteredCouplingSignatures" ->
      generated[#, "UnfilteredCouplingSignatures"],
    "SelectedCouplingSignature" ->
      generated[#, "SelectedCouplingSignature"],
    "GraphIDs" -> generated[#, "GraphIDs"]
  |> &,
  Keys[generated]
];

checks = <|
  "PaperExists" -> FileExistsQ[paperPath],
  "AllFamiliesSelected" -> AllTrue[Values[diagramLedger],
    AssociationQ[#] && IntegerQ[# ["SelectedCount"]] &&
      # ["SelectedCount"] > 0 &],
  "ConvertedCountsMatch" -> And @@ KeyValueMap[
    Length[converted[#1]] === #2["SelectedCount"] &,
    diagramLedger],
  "OneElectromagneticVertexPerAmplitude" -> And @@ KeyValueMap[
    AllTrue[List @@ generated[#1, "SelectedFeynArts"],
      chargeDegree[#] === 1 &] &,
    diagramLedger],
  "RequestedCouplingOrdersOnly" -> And @@ KeyValueMap[
    Function[{label, ledger},
      AllTrue[List @@ generated[label, "SelectedFeynArts"],
        Function[amplitude,
          couplingSignature[amplitude] ===
            familySpecifications[label, "CouplingSignature"]]]],
    diagramLedger],
  "ModelChargesDerived" ->
    (Element[upModelCharge, Rationals] &&
      Element[downModelCharge, Rationals]),
  "RawChargesCanonicalized" ->
    (FreeQ[openCurrentSums, HqqV2RawCharge] &&
      ! FreeQ[openCurrentSums, HqqV2Charge["UpType"]] &&
      ! FreeQ[openCurrentSums["Hqq;qPrime_qbarPrime"],
        HqqV2Charge["DownType"]]),
  "PhotonPolarizationRemoved" ->
    FreeQ[openCurrentSums, FeynCalc`Polarization[q, ___]],
  "PhotonIndexOpen" -> And @@
    (! FreeQ[#, FeynCalc`LorentzIndex[mu, D]] & /@
      Values[openCurrentSums]),
  "ExternalStatesRetained" ->
    (! FreeQ[openCurrentSums, _FeynCalc`Spinor] &&
      ! FreeQ[openCurrentSums["Born"], FeynCalc`Polarization[k2, ___]] &&
      ! FreeQ[openCurrentSums["Hqq;gg"],
        FeynCalc`Polarization[k3, ___]]),
  "CoherentSumsExact" -> And @@ KeyValueMap[
    SameQ[openCurrentSums[#1], Total[#2]] &,
    openCurrentsPerDiagram],
  "MasslessExactOutput" ->
    FreeQ[openCurrentSums,
      _Real | (head_Symbol[___] /; quarkMassHeadQ[head]) |
      SMP["m_u" | "m_d" | "m_c" | "m_s" | "m_t" | "m_b"]],
  "GenerationIndicesOnlyInSumOver" -> FreeQ[
    openCurrentSums /. HoldPattern[FeynArts`SumOver[___]] -> 1,
    symbol_Symbol /; generationSymbolQ[symbol]],
  "CountertermsAreQCDOnly" ->
    (FreeQ[openCurrentSums["VirtualCounterterm"],
        dZAA1 | dZe1 | dZZA1 | _dMf1] &&
      ! FreeQ[openCurrentSums["VirtualCounterterm"],
        dZGG1 | dZgs1 | _dZfL1 | _dZfR1])
|>;
Print["S01_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks], "one or more final S01 gates failed"];

sourceHash = FileHash[sourcePath, "SHA256", "HexString"];
paperHash = FileHash[paperPath, "SHA256", "HexString"];
result = <|
  "Stage" -> "HqqV2S01-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath, "SHA256" -> sourceHash|>,
  "Paper" -> <|"Path" -> paperPath, "SHA256" -> paperHash|>,
  "Runtime" -> <|
    "Wolfram" -> $Version,
    "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynArts" -> FeynArts`$FeynArtsVersion
  |>,
  "Process" -> <|
    "BornVirtual" -> "gamma*(q)+q(p)->q(k1)+g(k2)",
    "RealFamilies" -> {
      "gamma*(q)+q(p)->q(k1)+g(k2)+g(k3)",
      "gamma*(q)+q(p)->q(k1)+q(k2)+qbar(k3)",
      "gamma*(q)+q(p)->q(k1)+qPrime(k2)+qbarPrime(k3)"
    },
    "ObservedFragmentingParton" -> "q(k1)"
  |>,
  "Regularization" -> <|"Scheme" -> "CDR", "Dimension" -> D|>,
  "ExternalLegConvention" ->
    "WFCorrections and WFCorrectionCTs excluded; LSZ field factors are represented by generated QCD counterterm vertices and are derived in S02",
  "ChargeConvention" -> <|
    "ModelChargeMarker" -> chargeMarker,
    "UpTypeModelCharge" -> upModelCharge,
    "DownTypeModelCharge" -> downModelCharge,
    "SymbolicUpTypeCharge" -> HqqV2Charge["UpType"],
    "SymbolicDownTypeCharge" -> HqqV2Charge["DownType"],
    "RawChargesSeen" -> $HqqV2RawCharges,
    "RewriteCount" -> $HqqV2ChargeRewriteCount
  |>,
  "DiagramLedger" -> diagramLedger,
  "OpenPhotonIndex" -> mu,
  "OpenCurrentsPerDiagram" -> openCurrentsPerDiagram,
  "OpenCurrentSums" -> openCurrentSums,
  "Checks" -> checks
|>;

atomicPut[result, resultPath];
reloaded = Get[resultPath];
hqqV2Require[SameQ[reloaded, result],
  "written S01 result failed exact same-kernel reload"];
Print["S01_COUNTS=", InputForm[AssociationMap[
  diagramLedger[#, "SelectedCount"] &, Keys[diagramLedger]]]];
Print["S01_SOURCE_SHA256=", sourceHash];
Print["S01_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S01_SUCCESS"];
Quit[0];

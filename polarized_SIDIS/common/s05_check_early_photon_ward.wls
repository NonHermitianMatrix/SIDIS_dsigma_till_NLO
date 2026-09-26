(* Compare the reference's early Ward substitution on the actual Hgg amplitudes. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s05_check_early_photon_ward.wls"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "24fe8bc812f0a7306ee73ab9346d0e772d6d0bba77839feee131da55142f5c65",
  Print["FAIL: reviewed Ward production source"]; Quit[1]];
productionText = Import[productionPath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
prefixEnd = First[First[StringPosition[productionText, "\nDo[\n  amplitudes ="]]];
prefix = StringTake[productionText, prefixEnd - 1];
prefix = StringReplace[prefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[prefix], Print["FAIL: Ward initialization syntax"]; Quit[1]];
ToExpression[prefix];
gate["complete early Ward comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
gate["own gluon channel and accepted scalar routines", channel === "Hgg" && useRestoredScalar && useFactoredPair];
label = First[labels]; gate["single generated real sector", labels === {label}];
sectorCode = StringDrop[sourceSection[productionText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged complete pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode];
controlPair = First[pairs]; gate["own diagonal control pair", SameQ @@ controlPair];
controlPath = FileNameJoin[{cache, label <> "_" <> ToString[First[controlPair]] <> "_" <> ToString[Last[controlPair]] <> ".wl"}];
gate["pinned own accepted control", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  "16e98e475d6b9922b571ea98bc9b6c6a8d2fe473b2a12a221986e4cc443f1a9b"];
control = Get[controlPath];
gate["complete control input and checks", control["InputHash"] === inputHash && And @@ Values[control["Checks"]]];
referencePath = FileNameJoin[{root, "common", "s05_result", "reference", "s05_early_ward_reference.wl"}];
referenceText = Import[referencePath, "Text"];
gate["reference substitutes Ward momentum before spin sum", StringContainsQ[referenceText,
  "\"PhotonWard\", a = a /. Polarization[q, ___] -> q; b = b /. Polarization[q, ___] -> q"] &&
  StringContainsQ[referenceText, "expression = FermionSpinSum[a ComplexConjugate[b]"]];
conservationEquation = Total[generated["incoming"]] == Total[generated["outgoing"]];
wardSolutions = Solve[conservationEquation, q];
gate["unique generated momentum conservation rule", Length[wardSolutions] === 1 &&
  FreeQ[wardSolutions, _ConditionalExpression | _Real | $Failed]];
wardMomentumRule = First[wardSolutions];
gate["generated momentum relation reconstructs", Expand[(conservationEquation /. Equal -> Subtract) /. wardMomentumRule] === 0];
originalDefinitions = {DownValues[buildPair], DownValues[reduceScalar], DownValues[restoredScalarComponent],
  DownValues[algebraicReduceOne], DownValues[angularAverageOne]};
earlyWardAmplitude[index_] := earlyWardAmplitude[index] = Module[{projected, value, seconds},
  projected = (amplitudes[[index]] /. Polarization[q, ___] -> q) /. wardMomentumRule;
  gate["early Ward removes only the photon polarization", FreeQ[projected, Polarization[q, ___]]];
  {seconds, value} = AbsoluteTiming[bounded[DiracSimplify[Contract[projected]], {"early Ward amplitude", index}]];
  Print["EARLY_WARD_AMPLITUDE ", index, " seconds ", seconds, " before bytes ", ByteCount[projected], " after bytes ", ByteCount[value]];
  value];
earlyWardPair[i_, j_] := Module[{a, b, value},
  a = earlyWardAmplitude[i]; b = earlyWardAmplitude[j];
  Do[a = a /. Momentum[Polarization[leg, ___], ___] -> LorentzIndex[gluonLeft[leg], D];
    b = b /. Momentum[Polarization[leg, ___], ___] -> LorentzIndex[gluonRight[leg], D], {leg, gluons}];
  value = FeynAmpDenominatorExplicit[a ComplexConjugate[b, FCRenameDummyIndices -> True]];
  value = FermionSpinSum[value, Head -> keptSpinSum, DotSimplify -> False, FCTraceFactor -> False];
  value = value /. HoldPattern[keptSpinSum[DiracGamma[Momentum[mom_, ___], ___]] /; MemberQ[{p, k1}, mom]] :>
    If[mom === p, quarkIn, quarkOut];
  value = value /. keptSpinSum[other_] :> other;
  gate["early Ward preserves spin closures", FreeQ[value, keptSpinSum | _Spinor]];
  value = physical[value]; value = SUNSimplify[value, Explicit -> True, SUNNToCACF -> False];
  Do[value *= densities[leg], {leg, gluons}]; tensorWeight value/normalization];
{controlSeconds, controlValue} = AbsoluteTiming[bounded[
  traceScalar[earlyWardPair @@ controlPair], "early Ward own control"]];
gate["entire own accepted Ward spin polynomial reproduced", controlValue === control["ScalarModes"]["PhotonWard"] ||
  bounded[algebraicReduce[controlValue - control["ScalarModes"]["PhotonWard"]] === 0, "early Ward control equality"]];
candidatePair = {2, 6}; gate["actual slow pair belongs to generated inventory", MemberQ[pairs, candidatePair]];
{candidateSeconds, candidateValue} = AbsoluteTiming[bounded[
  traceScalar[earlyWardPair @@ candidatePair], "early Ward timed-out projection"]];
gate["all original scalar equations unchanged", originalDefinitions ===
  {DownValues[buildPair], DownValues[reduceScalar], DownValues[restoredScalarComponent],
    DownValues[algebraicReduceOne], DownValues[angularAverageOne]}];
gate["complete exact scalar candidate", FreeQ[candidateValue, _Spinor | _DiracTrace | _DiracGamma | _Pair |
  _Eps | _SUNTF | _SUNTrace | _Polarization | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
result = <|"Schema" -> "polarized-sidis-early-ward-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ReferenceSourceHash" -> FileHash[referencePath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "ControlHash" -> FileHash[controlPath, "SHA256"],
  "ControlPair" -> controlPair, "ControlSeconds" -> controlSeconds, "ControlValue" -> controlValue,
  "CandidatePair" -> candidatePair, "CandidateSeconds" -> candidateSeconds, "CandidateValue" -> candidateValue,
  "ConservationEquation" -> conservationEquation, "WardMomentumRule" -> wardMomentumRule,
  "OriginalDefinitions" -> originalDefinitions, "AmplitudeDefinitions" -> DownValues[earlyWardAmplitude],
  "PairDefinitions" -> DownValues[earlyWardPair], "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultDirectory = FileNameJoin[{root, channel, "s05_early_ward_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
resultPath = FileNameJoin[{resultDirectory, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[Compress[result], InputForm] <> "]\n";
gate["bounded early Ward comparison output", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["exact early Ward native result reload", Get[resultPath <> ".tmp"] === result];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{resultDirectory, "s05_checks.json"}], <|"checks" -> checks,
  "control_seconds" -> controlSeconds, "candidate_seconds" -> candidateSeconds,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_early_photon_ward"]; Quit[0];

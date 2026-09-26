(* Compare the reference's early Ward substitution on the actual Hgg amplitudes. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s05_check_ordered_amplitude_ward.wls"}];
productionPath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff",
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
controlSourcePath = FileNameJoin[{root, "common", "s05_check_cached_early_photon_ward.wls"}];
gate["pinned complete control implementation", IntegerString[FileHash[controlSourcePath, "SHA256"], 16, 64] ===
  "e2520f254c114853bfd8a6cb2f497ddfc1299cfb1e81b1f84b9ed4721933039f"];
amplitudeBasePath = FileNameJoin[{root, "common", "s05_check_amplitude_photon_ward.wls"}];
residualPath = FileNameJoin[{root, channel, "s05_amplitude_ward_result", "s05_unaccepted_expression.wl"}];
gate["pinned original amplitude implementation", IntegerString[FileHash[amplitudeBasePath, "SHA256"], 16, 64] ===
  "aa13c2621bab08032a2f399f800e7b83ce2a483476f2721413bb70bc86aca6b5"];
gate["pinned actual open amplitude residual", IntegerString[FileHash[residualPath, "SHA256"], 16, 64] ===
  "0b71c05075bc1aaf9a702e1c2cca266ae465d015a344244f859fed7c38c3a14f"];
residual = Get[residualPath]; amplitudeInventory = Range[Length[amplitudes]];
gate["complete original generated residual identity", residual["Schema"] === "polarized-sidis-unaccepted-amplitude-ward-v1" &&
  residual["Channel"] === channel && residual["InputHash"] === inputHash &&
  residual["SourceHash"] === FileHash[amplitudeBasePath, "SHA256"] &&
  residual["AmplitudeInventory"] === amplitudeInventory && residual["Accepted"] === False];
{candidateSeconds, candidateValue} = AbsoluteTiming[bounded[Module[{value},
  value = DiracSimplify[residual["Value"], DiracOrder -> True];
  value = SUNSimplify[value, Explicit -> True, SUNTraceEvaluate -> False, SUNNToCACF -> False];
  value = DiracSimplify[Contract[ExpandScalarProduct[value]], DiracOrder -> True];
  Factor[value /. scalarRestore]], "ordered complete amplitude photon Ward"]];
Print["ORDERED_AMPLITUDE_WARD seconds ", candidateSeconds, " bytes ", ByteCount[candidateValue]];
If[candidateValue =!= 0, Print["ORDERED_AMPLITUDE_RESIDUAL ", StringTake[ToString[candidateValue, InputForm], UpTo[4000]]]];
resultDirectory = FileNameJoin[{root, channel, "s05_ordered_amplitude_ward_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
gate["complete open-spin amplitude photon Ward exactly zero", candidateValue === 0];
{scalarSeconds, scalarValue} = AbsoluteTiming[bounded[traceScalar[candidateValue], "complete sector Ward scalar"]];
gate["unchanged scalar routine reproduces sector Ward zero", scalarValue === 0];
gate["all original scalar equations unchanged", originalDefinitions ===
  {DownValues[buildPair], DownValues[reduceScalar], DownValues[restoredScalarComponent],
    DownValues[algebraicReduceOne], DownValues[angularAverageOne]}];
result = <|"Schema" -> "polarized-sidis-amplitude-ward-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ProductionSourceHash" -> FileHash[productionPath, "SHA256"],
  "ResidualHash" -> FileHash[residualPath, "SHA256"], "AmplitudeBaseSourceHash" -> FileHash[amplitudeBasePath, "SHA256"],
  "ControlSourceHash" -> FileHash[controlSourcePath, "SHA256"],
  "ReferenceSourceHash" -> FileHash[referencePath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "ControlHash" -> FileHash[controlPath, "SHA256"],
  "ControlPair" -> controlPair, "ControlSeconds" -> controlSeconds, "ControlValue" -> controlValue,
  "AmplitudeInventory" -> amplitudeInventory, "AmplitudeHash" -> Hash[amplitudes, "SHA256"],
  "CandidateSeconds" -> candidateSeconds, "CandidateValue" -> candidateValue,
  "ScalarSeconds" -> scalarSeconds, "ScalarValue" -> scalarValue,
  "ConservationEquation" -> conservationEquation, "WardMomentumRule" -> wardMomentumRule,
  "OriginalDefinitions" -> originalDefinitions, "AmplitudeDefinitions" -> DownValues[earlyWardAmplitude],
  "PairDefinitions" -> DownValues[earlyWardPair], "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultPath = FileNameJoin[{resultDirectory, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[Compress[result], InputForm] <> "]\n";
gate["bounded complete amplitude Ward comparison output", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["exact amplitude Ward native result reload", Get[resultPath <> ".tmp"] === result];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{resultDirectory, "s05_checks.json"}], <|"checks" -> checks,
  "control_seconds" -> controlSeconds, "candidate_seconds" -> candidateSeconds, "scalar_seconds" -> scalarSeconds,
  "amplitude_count" -> Length[amplitudeInventory], "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_ordered_amplitude_ward"]; Quit[0];

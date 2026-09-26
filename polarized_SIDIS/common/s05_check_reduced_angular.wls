(* Check already reduced angular inputs using native polynomial normal forms. *)
$HistoryLength = 0;
angularStudyPath = FileNameJoin[{Directory[], "common", "s05_check_reduced_angular.wls"}];
angularBasePath = FileNameJoin[{Directory[], "common", "s05_real_spin_response_cached_scalar.wls"}];
If[IntegerString[FileHash[angularBasePath, "SHA256"], 16, 64] =!=
  "ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff", Quit[1]];
angularBaseText = Import[angularBasePath, "Text"];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; $LoadAddOns = {"FeynArts"}; Get["FeynCalc`"];
If[StringCount[angularBaseText, "\nDo[\n  amplitudes ="] =!= 1, Quit[1]];
angularPrefix = First[StringSplit[angularBaseText, "\nDo[\n  amplitudes ="]];
angularPrefix = StringReplace[angularPrefix, "Get[\"FeynCalc`\"]" ->
  "If[!MemberQ[$Packages, \"FeynCalc`\"], Get[\"FeynCalc`\"]]"];
If[!SyntaxQ[angularPrefix], Quit[1]];
ToExpression[angularPrefix, InputForm];
gate["complete reduced angular comparison syntax", SyntaxQ[Import[angularStudyPath, "Text"]]];
gate["own gluon angular comparison", channel === "Hgg" && useRestoredScalar && useFactoredPair];
label = First[labels]; gate["single inherited angular sector", labels === {label}];
sectorCode = StringDrop[sourceSection[angularBaseText, "\nDo[\n  amplitudes =", "\n  slots ="], StringLength["\nDo["]];
gate["unchanged angular pair initialization syntax", SyntaxQ[sectorCode]];
ToExpression[sectorCode, InputForm];
controlPair = First[pairs]; gate["own diagonal angular control", SameQ @@ controlPair];
controlPath = FileNameJoin[{cache, label <> "_" <> ToString[First[controlPair]] <> "_" <> ToString[Last[controlPair]] <> ".wl"}];
gate["pinned complete own angular control", IntegerString[FileHash[controlPath, "SHA256"], 16, 64] ===
  "16e98e475d6b9922b571ea98bc9b6c6a8d2fe473b2a12a221986e4cc443f1a9b"];
control = Get[controlPath];
gate["own angular control input binding", control["InputHash"] === inputHash && And @@ Values[control["Checks"]]];
originalAngularDefinitions = DownValues[angularAverageOne];
originalOtherDefinitions = {DownValues[buildPair], DownValues[traceScalar], DownValues[reduceScalar],
  DownValues[restoredScalarComponent], DownValues[algebraicReduceOne], DownValues[spinMap]};
angularNormalForms = <||>;
checkedReducedAngularInput[value_] := Module[{rational, numerator, denominator, division, binding, seconds, unchanged},
  {seconds, rational} = AbsoluteTiming[Together[value]];
  numerator = Numerator[rational]; denominator = Denominator[rational];
  If[!FreeQ[denominator, transverseK] || !PolynomialQ[numerator, transverseK], Return[algebraicReduce[value]]];
  division = PolynomialReduce[numerator, {transverseConstraint}, {transverseK}];
  unchanged = And @@ (# === 0 & /@ First[division]) && Last[division] === numerator;
  If[!TrueQ[unchanged], Return[algebraicReduce[value]]];
  gate["native angular input division reconstructs exactly", Expand[numerator - First[division].{transverseConstraint} - Last[division]] === 0];
  gate["native angular input already in original transverse normal form", zero[rational - Last[division]/denominator]];
  binding = Hash[{inputHash, value, transverseConstraint}, "SHA256"];
  AssociateTo[angularNormalForms, binding -> <|"InputHash" -> Hash[value, "SHA256"],
    "InputBytes" -> ByteCount[value], "TogetherSeconds" -> seconds, "ZeroQuotient" -> True,
    "UnchangedRemainder" -> True, "ExactReconstruction" -> True|>];
  Print["ANGULAR_NORMAL_FORM_REUSED bytes ", ByteCount[value], " seconds ", seconds]; rational];
angularOriginalCode = sourceSection[angularBaseText, "angularAverageOne[value_]", "\nreduceScalar[expression_]"];
angularOld = "rational = Together[algebraicReduce[value]];";
angularNew = "rational = Together[checkedReducedAngularInput[value]];";
gate["unique repeated angular reduction interface", StringCount[angularOriginalCode, angularOld] === 1];
angularCandidateCode = StringReplace[angularOriginalCode, angularOld -> angularNew];
gate["all angular equations otherwise unchanged", StringReplace[angularCandidateCode, angularNew -> angularOld] === angularOriginalCode];
gate["complete candidate angular definition syntax", SyntaxQ[angularCandidateCode]];
ToExpression[angularCandidateCode, InputForm];
tensor = bounded[buildPair[First[controlPair], Last[controlPair], None], "own angular control closure"];
{controlSeconds, controlValue} = AbsoluteTiming[bounded[traceScalar[photonProject[tensor, First[photonSymbols], First[photonSymbols]]],
  "own complete angular control"]];
gate["entire own accepted angular spin projection reproduced", controlValue === control["PhotonMatrix"][[1, 1]] ||
  bounded[algebraicReduce[controlValue - control["PhotonMatrix"][[1, 1]]] === 0, "complete own angular comparison"]];
candidatePair = {2, 6}; gate["actual bounded angular pair exists", MemberQ[pairs, candidatePair]];
tensor = bounded[buildPair[First[candidatePair], Last[candidatePair], None], "actual angular candidate closure"];
{candidateSeconds, candidateValue} = AbsoluteTiming[bounded[traceScalar[photonProject[tensor, q, q]], "actual angular candidate projection"]];
gate["all other original contraction and scalar equations unchanged", originalOtherDefinitions ===
  {DownValues[buildPair], DownValues[traceScalar], DownValues[reduceScalar], DownValues[restoredScalarComponent],
    DownValues[algebraicReduceOne], DownValues[spinMap]}];
gate["native normal form reuse actually exercised", Length[angularNormalForms] > 0 && And @@ Lookup[Values[angularNormalForms], "ExactReconstruction"]];
gate["complete exact angular candidate scalar", FreeQ[candidateValue, _Spinor | _DiracTrace | _DiracGamma | _Pair |
  _Eps | _SUNTF | _SUNTrace | _Polarization | _ConditionalExpression | _Piecewise | _Real | $Failed | $Aborted]];
angularResult = <|"Schema" -> "polarized-sidis-reduced-angular-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[angularStudyPath, "SHA256"], "ProductionSourceHash" -> FileHash[angularBasePath, "SHA256"],
  "InputHash" -> inputHash, "InputHashes" -> inputHashes, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "ControlHash" -> FileHash[controlPath, "SHA256"], "ControlPair" -> controlPair, "ControlValue" -> controlValue,
  "ControlSeconds" -> controlSeconds, "CandidatePair" -> candidatePair, "CandidateProjection" -> "PhotonWard",
  "CandidateValue" -> candidateValue, "CandidateSeconds" -> candidateSeconds,
  "OriginalAngularDefinitions" -> originalAngularDefinitions, "AngularDefinitions" -> DownValues[angularAverageOne],
  "NormalFormDefinitions" -> DownValues[checkedReducedAngularInput], "NormalFormEvidence" -> angularNormalForms,
  "OriginalOtherDefinitions" -> originalOtherDefinitions, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
angularDirectory = FileNameJoin[{root, channel, "s05_reduced_angular_result"}];
If[!DirectoryQ[angularDirectory], CreateDirectory[angularDirectory, CreateIntermediateDirectories -> True]];
angularPath = FileNameJoin[{angularDirectory, "s05_result.wl"}];
serialized = "Uncompress[" <> ToString[bounded[Compress[angularResult], "angular output compression"], InputForm] <> "]\n";
gate["bounded reduced angular output", StringLength[serialized] < 128*1024^2];
Export[angularPath <> ".tmp", serialized, "Text"];
gate["reduced angular exact native output reload", bounded[Get[angularPath <> ".tmp"] === angularResult, "angular output reload"]];
RenameFile[angularPath <> ".tmp", angularPath, OverwriteTarget -> True];
Export[FileNameJoin[{angularDirectory, "s05_checks.json"}], <|"checks" -> checks,
  "control_seconds" -> controlSeconds, "candidate_seconds" -> candidateSeconds,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s05_check_reduced_angular"]; Quit[0];

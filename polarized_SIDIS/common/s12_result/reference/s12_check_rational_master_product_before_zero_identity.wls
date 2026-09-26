(* Test the standalone rational-series routine on the actual SIDIS master products. *)
$HistoryLength = 0;
comparisonPath = FileNameJoin[{Directory[], "common", "s12_check_rational_master_product.wls"}];
productionPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_spin.wls"}];
If[IntegerString[FileHash[productionPath, "SHA256"], 16, 64] =!=
  "ca3777035d3d220b3fb8fcddb8131348f0d7c97f8fd9b8d54703337c93daa243", Quit[1]];
productionText = Import[productionPath, "Text"];
boundary = "\nassemble[component_,index_]";
If[StringCount[productionText, boundary] =!= 1, Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
initialization = StringReplace[First[StringSplit[productionText, boundary]], "Get[\"FeynCalc`\"]" -> "Null"];
If[!SyntaxQ[initialization], Quit[1]]; ToExpression[initialization, InputForm];
gate["complete rational product comparison syntax", SyntaxQ[Import[comparisonPath, "Text"]]];
gate["own rational product comparison channel", channel === "Hqqbar"];
comparisonConfigPath = FileNameJoin[{root, "common", "s12_rational_series_inputs.json"}];
comparisonConfig = Import[comparisonConfigPath, "RawJSON"];
KeyValueMap[gate["comparison input " <> #1,
  IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &, comparisonConfig["files"]];
standalonePath = FileNameJoin[{root, comparisonConfig["reference"]}];
standaloneText = Import[standalonePath, "Text"];
beginMarker = "rationalSeries[rat[numerator_, denominator_], maximumPower_Integer] :=";
endMarker = "\ncanonicalCoefficient[expression_]";
gate["unique complete standalone rational definition", StringCount[standaloneText, beginMarker] === 1 &&
  StringCount[standaloneText, endMarker] === 1];
referenceDefinition = beginMarker <> First[StringSplit[Last[StringSplit[standaloneText, beginMarker]], endMarker]];
convertedDefinition = StringReplace[referenceDefinition, RegularExpression["\\bep\\b"] -> "eps"];
gate["standalone regulator conversion is reversible", StringReplace[convertedDefinition,
  RegularExpression["\\beps\\b"] -> "ep"] === referenceDefinition && SyntaxQ[convertedDefinition]];
ToExpression[convertedDefinition, InputForm];
originalDefinitions = {DownValues[epsilonSeries], DownValues[laurentProduct], DownValues[softRows],
  DownValues[softPieces], DownValues[pieceEndpoint]};
zeroCoefficient[value_] := Factor[Together[value]] === 0;
checkedRationalSeries[coefficient_, order_, description_] := Module[
  {rational, numerator, denominator, value, residual, first, last, seconds},
  rational = bounded[Together[coefficient], "rational master coefficient"];
  numerator = Numerator[rational]; denominator = Denominator[rational];
  gate["rational coefficient has polynomial regulator support", PolynomialQ[numerator, eps] &&
    PolynomialQ[denominator, eps] && denominator =!= 0];
  {seconds, value} = AbsoluteTiming[bounded[rationalSeries[rat[numerator, denominator], order], "reference rational recurrence"]];
  residual = bounded[Expand[denominator value - numerator, eps], "rational series numerator identity"];
  If[residual =!= 0,
    first = Exponent[residual, eps, Min]; last = order + Exponent[denominator, eps, Min];
    gate["integer rational identity coverage", IntegerQ[first] && IntegerQ[last]];
    gate["complete truncated rational numerator reconstruction", And @@ Table[
      bounded[zeroCoefficient[Coefficient[residual, eps, power]], "rational residual coefficient"], {power, first, last}]]];
  Print["RATIONAL_MASTER_SERIES ", description, " order ", order, " seconds ", seconds,
    " input bytes ", ByteCount[coefficient], " output bytes ", ByteCount[value]];
  value];
ordinaryMasterProduct[coefficient_, master_, order_, description_] := Module[
  {polynomial, first, last, powers, coefficients, reconstruction, rationalPart, answer, direct, residual,
   rational, valuation, coverage},
  If[coefficient === 0, Return[0]];
  gate["native master retains its regulator remainder", MatchQ[master, _SeriesData] &&
    master[[1]] === eps && master[[2]] === 0 && master[[6]] === 1];
  rational = bounded[Together[coefficient], "coefficient regulator valuation"];
  If[rational === 0, Return[0]];
  gate["coefficient valuation is rational", PolynomialQ[Numerator[rational], eps] && PolynomialQ[Denominator[rational], eps]];
  valuation = Exponent[Numerator[rational], eps, Min] - Exponent[Denominator[rational], eps, Min];
  gate["integer coefficient regulator valuation", IntegerQ[valuation]];
  coverage = eps^valuation master;
  gate["actual coefficient preserves required master depth", MatchQ[coverage, _SeriesData] && coverage[[5]]/coverage[[6]] > order];
  polynomial = bounded[Expand[Normal[master], eps], "master Laurent polynomial"];
  If[polynomial === 0, Return[0]];
  first = Exponent[polynomial, eps, Min]; last = Exponent[polynomial, eps];
  gate["integer master Laurent support", IntegerQ[first] && IntegerQ[last] && first <= last];
  powers = Range[first, last]; coefficients = Coefficient[polynomial, eps, #] & /@ powers;
  gate["master Laurent coefficients independent of regulator", FreeQ[coefficients, eps]];
  reconstruction = Total[MapThread[Times, {coefficients, eps^powers}]];
  gate["complete master Laurent reconstruction", bounded[Expand[Normal[master] - reconstruction] === 0, "master reconstruction"]];
  rationalPart = checkedRationalSeries[rational, order - first, description];
  answer = bounded[laurentProduct[polynomial, rationalPart, order], "reference master Laurent product"];
  direct = bounded[Normal[Series[polynomial rationalPart, {eps, 0, order}]], "native polynomial master product"];
  residual = bounded[Expand[answer - direct, eps], "master product difference"];
  gate["complete product matches native polynomial Series", residual === 0 || And @@ Table[
    bounded[zeroCoefficient[Coefficient[residual, eps, power]], "master product coefficient identity"],
    {power, Exponent[residual, eps, Min], Exponent[residual, eps]}]];
  answer];
candidateOrdinary[component_, index_] := Module[{coefficients},
  coefficients = Select[component["ReducedCoefficients"], # =!= 0 &] /. transverseRule;
  gate["candidate preserves transverse substitution", FreeQ[coefficients, First[transverseRule]]];
  Total[KeyValueMap[ordinaryMasterProduct[#2 /. D -> 4 - 2 eps,
    regions["OrdinaryMasters"][#1], 0, {index, #1}] &, coefficients]]];
controlPath = FileNameJoin[{root, comparisonConfig["control"]}]; control = Get[controlPath];
gate["complete accepted own integration control", control["InputHash"] === inputHash &&
  TrueQ[control["Accepted"]] && And @@ Values[control["Checks"]]];
componentIdentity = {"Sector", "Kind", "Index"};
controlIndex = First[FirstPosition[(KeyTake[#, componentIdentity] &) /@ mapped["Components"], KeyTake[control, componentIdentity]]];
gate["own complete control belongs to scalar map", IntegerQ[controlIndex]];
unfinished = Select[Range[Length[mapped["Components"]]],
  !FileExistsQ[FileNameJoin[{cache, "component_" <> IntegerString[#, 10, 4] <> ".wl"}]] &];
targetIndex = If[unfinished === {}, controlIndex, First[unfinished]];
{controlSeconds, controlValue} = AbsoluteTiming[candidateOrdinary[mapped["Components"][[controlIndex]], controlIndex]];
controlResidual = bounded[Expand[controlValue - control["Ordinary"], eps], "own complete ordinary difference"];
gate["complete own accepted ordinary contribution reproduced", controlResidual === 0 || And @@ Table[
  bounded[zeroCoefficient[Coefficient[controlResidual, eps, power]], "own complete ordinary comparison"],
  {power, Exponent[controlResidual, eps, Min], Exponent[controlResidual, eps]}]];
{candidateSeconds, candidateValue} = AbsoluteTiming[candidateOrdinary[mapped["Components"][[targetIndex]], targetIndex]];
gate["reference endpoint and series definitions unchanged", originalDefinitions ===
  {DownValues[epsilonSeries], DownValues[laurentProduct], DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint]}];
result = <|"Schema" -> "polarized-sidis-rational-master-product-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[comparisonPath, "SHA256"], "ProductionSourceHash" -> sourceHash,
  "ConfigurationHash" -> FileHash[comparisonConfigPath, "SHA256"], "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "ReferenceSourceHash" -> FileHash[standalonePath, "SHA256"], "ReferenceDefinition" -> referenceDefinition,
  "ControlHash" -> FileHash[controlPath, "SHA256"], "ControlIndex" -> controlIndex, "ControlSeconds" -> controlSeconds,
  "ControlValue" -> controlValue, "TargetIndex" -> targetIndex, "CandidateSeconds" -> candidateSeconds,
  "CandidateValue" -> candidateValue, "OriginalDefinitions" -> originalDefinitions,
  "RationalDefinitions" -> DownValues[rationalSeries], "CheckedRationalDefinitions" -> DownValues[checkedRationalSeries],
  "ProductDefinitions" -> DownValues[ordinaryMasterProduct], "CandidateDefinitions" -> DownValues[candidateOrdinary],
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
resultDirectory = FileNameJoin[{root, channel, "s12_rational_series_result"}];
If[!DirectoryQ[resultDirectory], CreateDirectory[resultDirectory, CreateIntermediateDirectories -> True]];
resultPath = FileNameJoin[{resultDirectory, "s12_result.wl"}];
serialized = "Uncompress[" <> ToString[Compress[result], InputForm] <> "]\n";
gate["bounded complete rational comparison output", StringLength[serialized] < 128*1024^2];
Export[resultPath <> ".tmp", serialized, "Text"];
gate["exact native rational comparison reload", Get[resultPath <> ".tmp"] === result];
RenameFile[resultPath <> ".tmp", resultPath, OverwriteTarget -> True];
Export[FileNameJoin[{resultDirectory, "s12_checks.json"}], <|"checks" -> checks,
  "control_index" -> controlIndex, "control_seconds" -> controlSeconds, "target_index" -> targetIndex,
  "candidate_seconds" -> candidateSeconds, "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s12_check_rational_master_product"]; Quit[0];

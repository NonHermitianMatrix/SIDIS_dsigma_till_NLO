(* Preserve the accepted denominator equations while accumulating one row at a time. *)
$HistoryLength = 0;
streamSource = FileNameJoin[{Directory[], "common", "s08_check_streamed_numerator.wls"}];
streamBaseline = FileNameJoin[{Directory[], "common", "s08_map_real_spin.wls"}];
If[IntegerString[FileHash[streamBaseline, "SHA256"], 16, 64] =!=
  "e42c8bec95f9e856911436024b9b39cf2f1b6fd8bac4c3f345dbfaa63c173fdc", Quit[1]];
streamText = Import[streamBaseline, "Text"];
streamStop = First[First[StringPosition[streamText, "\nslots = Quiet["]]];
streamPrefix = StringTake[streamText, streamStop - 1];
If[!SyntaxQ[streamPrefix], Quit[1]];
ToExpression[streamPrefix, InputForm];
gate["complete streamed numerator source syntax", SyntaxQ[Import[streamSource, "Text"]]];
originalSumDefinitions = DownValues[factoredDenominatorSum];

streamedDenominatorSum[terms_List, purpose_] := Module[
  {nonzero, packets, expression, rational, factors, numerical, symbolic, unit, factorMap,
   allFactors, commonPowers, commonDenominator, row, multiplier, numerator, next,
   factoredNumerator, answer, seconds, evidence, rowCount = 0, peakRowBytes = 0},
  nonzero = DeleteCases[terms, 0];
  If[nonzero === {}, Return[<|"Value" -> 0, "Evidence" -> <|"TermCount" -> 0|>|>]];
  packets = Table[
    expression = nonzero[[i]];
    rational = bounded[Together[expression], {purpose, "individual rational term", i}];
    factors = bounded[FactorList[Denominator[rational]], {purpose, "denominator factors", i}];
    numerical = Select[factors, NumberQ[First[#]] &];
    symbolic = Select[factors, !NumberQ[First[#]] &];
    unit = Times @@ (Power @@@ numerical);
    factorMap = Association[Rule @@@ symbolic];
    gate["exact individual denominator factorization", zero[Denominator[rational] - unit (Times @@ (Power @@@ symbolic))]];
    gate["unique positive denominator factor powers", DuplicateFreeQ[First /@ symbolic] &&
      AllTrue[Values[factorMap], IntegerQ[#] && # > 0 &] && unit =!= 0];
    <|"Numerator" -> Numerator[rational], "Denominator" -> Denominator[rational], "Unit" -> unit,
      "FactorPowers" -> factorMap, "InputBytes" -> ByteCount[expression]|>, {i, Length[nonzero]}];
  allFactors = Union[Flatten[Keys[#["FactorPowers"]] & /@ packets]];
  commonPowers = Table[Max[Lookup[#["FactorPowers"], factor, 0] & /@ packets], {factor, allFactors}];
  commonDenominator = Times @@ MapThread[Power, {allFactors, commonPowers}];
  evidence = <|"TermCount" -> Length[nonzero], "FactorCount" -> Length[allFactors],
    "FactorPowers" -> AssociationThread[allFactors, commonPowers],
    "InputBytes" -> ByteCount[terms], "CommonDenominatorBytes" -> ByteCount[commonDenominator]|>;
  Print["DENOMINATOR_SUPPORT ", purpose, " ", InputForm[evidence]];
  numerator = 0;
  seconds = First[AbsoluteTiming[Do[
    multiplier = (Times @@ MapThread[Power, {allFactors,
      commonPowers - (Lookup[packets[[i]]["FactorPowers"], #, 0] & /@ allFactors)}])/packets[[i]]["Unit"];
    gate["exact common-denominator embedding", bounded[
      zero[packets[[i]]["Denominator"] multiplier/commonDenominator - 1], {purpose, "denominator embedding", i}]];
    row = bounded[Expand[packets[[i]]["Numerator"] multiplier], {purpose, "polynomial numerator", i}];
    peakRowBytes = Max[peakRowBytes, ByteCount[row]];
    next = bounded[numerator + row, {purpose, "streamed numerator addition", i}];
    gate["exact streamed numerator addition", bounded[Expand[next - numerator - row] === 0,
      {purpose, "streamed addition reconstruction", i}]];
    numerator = next; Clear[next, row]; rowCount++;
    If[Mod[i, 16] === 0 || i === Length[packets],
      Print["STREAMED_NUMERATOR ", purpose, " row ", i, "/", Length[packets],
        " numerator_bytes ", ByteCount[numerator], " kernel_memory ", MemoryInUse[]]; ClearSystemCache[]],
    {i, Length[packets]}]]];
  gate["exact complete numerator assembly", rowCount === Length[packets]];
  Print["DENOMINATOR_NUMERATOR ", purpose, " bytes ", ByteCount[numerator], " seconds ", seconds];
  Clear[packets]; ClearSystemCache[];
  factoredNumerator = cancelKnownDenominatorFactors[numerator, allFactors, commonPowers, purpose];
  gate["exact final numerator factorization", bounded[Expand[numerator - factoredNumerator] === 0,
    {purpose, "final numerator reconstruction"}]];
  answer = factoredNumerator/commonDenominator;
  gate["exact final denominator reconstruction", bounded[zero[answer commonDenominator - factoredNumerator],
    {purpose, "final denominator reconstruction"}]];
  <|"Value" -> answer, "Evidence" -> Join[evidence, <|"NumeratorBytes" -> ByteCount[numerator],
    "OutputBytes" -> ByteCount[answer], "PeakRowBytes" -> peakRowBytes, "NumeratorAssemblySeconds" -> seconds,
    "ExactTermwiseReconstructionPassed" -> True|>]|>];

streamInputHash = Hash[{FileHash[streamSource, "SHA256"], inputHash, $Version, $FeynCalcVersion}, "SHA256"];
streamDir = FileNameJoin[{root, channel, "s08_streamed_result"}];
If[!DirectoryQ[streamDir], CreateDirectory[streamDir, CreateIntermediateDirectories -> True]];
streamControl = streamedDenominatorSum[controlTerms, "own accepted original control"];
gate["streamed own accepted original coefficient equality", bounded[
  zero[streamControl["Value"] - controlValue], "streamed control equality"]];
streamIndex = SelectFirst[Range[Length[tasks]],
  !FileExistsQ[FileNameJoin[{cache, "component_" <> IntegerString[#, 10, 4] <> ".wl"}]] &];
gate["actual unfinished component selected", IntegerQ[streamIndex]];
streamRaw = rawTargetComponents[[streamIndex]];
gate["actual component exact reconstruction accepted", TrueQ[streamRaw["ReconstructionPassed"]] &&
  And @@ Values[streamRaw["Checks"]]];
streamRules = Association[reduction["Rules"]];
gate["actual component complete Kira coverage", Complement[Keys[streamRaw["Coefficients"]], Keys[streamRules]] === {}];
streamMasters = Union[Cases[Values[KeyTake[streamRules, Keys[streamRaw["Coefficients"]]]], _CutIntegral, Infinity]];
streamMaster = First[streamMasters];
streamTerms = KeyValueMap[#2 Coefficient[streamRules[#1], streamMaster] &, streamRaw["Coefficients"]];
Print["ACTUAL_COEFFICIENT ", streamIndex, " ", InputForm[streamMaster], " bytes ", ByteCount[streamTerms]];
Print["SMALLEST_NONZERO_INPUT_TERM ", InputForm[First[MinimalBy[DeleteCases[streamTerms, 0], ByteCount]]]];
{streamSeconds, streamPacket} = AbsoluteTiming[streamedDenominatorSum[streamTerms, {streamIndex, streamMaster}]];
gate["actual coefficient exact streamed reconstruction", TrueQ[streamPacket["Evidence"]["ExactTermwiseReconstructionPassed"]]];
streamResult = <|"Schema" -> "polarized-sidis-streamed-numerator-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[streamSource, "SHA256"], "BaselineSourceHash" -> FileHash[streamBaseline, "SHA256"],
  "InputHashes" -> inputHashes, "InputHash" -> streamInputHash, "ProductionInputHash" -> inputHash,
  "Definitions" -> DownValues[streamedDenominatorSum], "OriginalDefinitions" -> originalSumDefinitions,
  "ControlMaster" -> controlMaster, "ControlValue" -> streamControl["Value"],
  "ComponentIndex" -> streamIndex, "Task" -> KeyDrop[tasks[[streamIndex]], "Value"],
  "Master" -> streamMaster, "Coefficient" -> streamPacket, "Seconds" -> streamSeconds,
  "Checks" -> checks, "NativeVersions" -> {$Version, $FeynCalcVersion},
  "PeakKernelMemoryBytes" -> MaxMemoryUsed[], "FiniteNLOFHatsComputed" -> False|>;
putCompressed[streamResult, FileNameJoin[{streamDir, "s08_result.wl"}]];
Export[FileNameJoin[{streamDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "component_index" -> streamIndex, "seconds" -> streamSeconds,
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_check_streamed_numerator"]; Quit[0];

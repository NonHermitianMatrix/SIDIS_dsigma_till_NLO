(* Exact rational summation from the factor supports of the actual saved cut coefficients. *)
$HistoryLength = 0;
denominatorSource = FileNameJoin[{Directory[], "common", "s08_denominator_sum_check.wls"}];
denominatorBaseline = FileNameJoin[{Directory[], "common", "s08_rational_sum_check.wls"}];
If[IntegerString[FileHash[denominatorBaseline, "SHA256"], 16, 64] =!=
  "7057bd25031c8032c05ba486395032e46c5e5dd10db004c4ce1c96f32779603f", Quit[1]];
denominatorText = Import[denominatorBaseline, "Text"];
denominatorStop = First[First[StringPosition[denominatorText, "\nsumValues = <||>; sumTimings = {};"]]];
denominatorPrefix = StringTake[denominatorText, denominatorStop - 1];
If[!SyntaxQ[denominatorPrefix], Print["FAIL: complete comparison prefix syntax"]; Quit[1]];
ToExpression[denominatorPrefix, InputForm];
gate["complete denominator-sum comparison syntax", SyntaxQ[Import[denominatorSource, "Text"]]];

factoredDenominatorSum[terms_List, purpose_] := Module[
  {nonzero, packets, expression, rational, factors, numerical, symbolic, unit, factorMap,
   allFactors, commonPowers, commonDenominator, rows, multiplier, numerator, factoredNumerator,
   answer, seconds, evidence},
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
  rows = Table[
    multiplier = (Times @@ MapThread[Power, {allFactors,
      commonPowers - (Lookup[packets[[i]]["FactorPowers"], #, 0] & /@ allFactors)}])/packets[[i]]["Unit"];
    gate["exact common-denominator embedding", bounded[
      zero[packets[[i]]["Denominator"] multiplier/commonDenominator - 1], {purpose, "denominator embedding", i}]];
    bounded[Expand[packets[[i]]["Numerator"] multiplier], {purpose, "polynomial numerator", i}],
    {i, Length[packets]}];
  {seconds, numerator} = AbsoluteTiming[bounded[Total[rows], {purpose, "polynomial numerator sum"}]];
  gate["exact complete numerator assembly", bounded[Expand[numerator - Total[rows]] === 0, {purpose, "numerator reconstruction"}]];
  Print["DENOMINATOR_NUMERATOR ", purpose, " bytes ", ByteCount[numerator], " seconds ", seconds];
  Clear[rows]; ClearSystemCache[];
  factoredNumerator = bounded[Factor[numerator], {purpose, "final numerator factorization"}];
  gate["exact final numerator factorization", bounded[Expand[numerator - factoredNumerator] === 0,
    {purpose, "final numerator reconstruction"}]];
  answer = factoredNumerator/commonDenominator;
  gate["exact final denominator reconstruction", bounded[zero[answer commonDenominator - factoredNumerator],
    {purpose, "final denominator reconstruction"}]];
  <|"Value" -> answer, "Evidence" -> Join[evidence, <|"NumeratorBytes" -> ByteCount[numerator],
    "OutputBytes" -> ByteCount[answer], "ExactTermwiseReconstructionPassed" -> True|>]|>];

denominatorControl = factoredDenominatorSum[sumControl["Terms"], "original same-channel control"];
gate["own accepted original coefficient comparison", bounded[
  zero[denominatorControl["Value"] - sumControlValue[sumControl["Master"]]], "original control equality"]];

denominatorCacheHash = Hash[{FileHash[denominatorSource, "SHA256"], FileHash[denominatorBaseline, "SHA256"],
  FileHash[FileNameJoin[{root, sumConfig["raw_map"]}], "SHA256"], inputHashes, $Version, $FeynCalcVersion}, "SHA256"];
denominatorCache = FileNameJoin[{root, "cache", "s08_denominator_sum", IntegerString[denominatorCacheHash, 16]}];
If[!DirectoryQ[denominatorCache], CreateDirectory[denominatorCache, CreateIntermediateDirectories -> True]];
sumValues = <||>; denominatorEvidence = {};
Do[
  sumMaster = sumPacket["Master"];
  packetPath = FileNameJoin[{denominatorCache, "master_" <> IntegerString[Hash[sumMaster, "SHA256"], 16] <> ".wl"}];
  packet = If[FileExistsQ[packetPath], Get[packetPath], <||>];
  If[Lookup[packet, "InputHash", None] =!= denominatorCacheHash,
    Print["FACTORED_DENOMINATOR_SUM ", InputForm[sumMaster]];
    {denominatorSeconds, packet} = AbsoluteTiming[factoredDenominatorSum[sumPacket["Terms"], sumMaster]];
    packet = Join[packet, <|"InputHash" -> denominatorCacheHash, "Master" -> sumMaster, "Seconds" -> denominatorSeconds|>];
    put[packet, packetPath]];
  If[sumMaster === sumControl["Master"], gate["original same-channel coefficient unchanged",
    bounded[zero[packet["Value"] - sumControlValue[sumMaster]], "original coefficient comparison"]]];
  AssociateTo[sumValues, sumMaster -> packet["Value"]];
  AppendTo[denominatorEvidence, KeyDrop[packet, {"Value", "InputHash"}]];
  Print["FACTORED_DENOMINATOR_SUM_ACCEPTED ", InputForm[sumMaster], " seconds ", packet["Seconds"]],
  {sumPacket, sumPackets}];
gate["complete factored-denominator coefficient inventory", Keys[sumValues] === sumMasters];
gate["fully scalar exact denominator-sum coefficients", FreeQ[sumValues, _CutIntegral | _Real | $Failed | $Aborted | _Integrate | _SeriesData]];
denominatorResult = <|"Schema" -> "polarized-sidis-denominator-sum-validation-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[denominatorSource, "SHA256"], "BaselineSourceHash" -> FileHash[denominatorBaseline, "SHA256"],
  "MapperSourceHash" -> FileHash[sumMapper, "SHA256"], "InputHashes" -> inputHashes,
  "RawMapHash" -> FileHash[FileNameJoin[{root, sumConfig["raw_map"]}], "SHA256"],
  "InputHash" -> denominatorCacheHash, "Task" -> sumRaw["Task"],
  "Definitions" -> DownValues[factoredDenominatorSum], "ControlMaster" -> sumControl["Master"],
  "ReducedCoefficients" -> sumValues, "Evidence" -> denominatorEvidence, "Checks" -> checks,
  "FiniteNLOFHatsComputed" -> False|>;
denominatorDir = FileNameJoin[{root, channel, "s08_denominator_result"}];
If[!DirectoryQ[denominatorDir], CreateDirectory[denominatorDir, CreateIntermediateDirectories -> True]];
put[denominatorResult, FileNameJoin[{denominatorDir, "s08_result.wl"}]];
Export[FileNameJoin[{denominatorDir, "s08_checks.json"}], <|"channel" -> channel, "checks" -> checks,
  "job_id" -> Environment["JOB_ID"], "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s08_denominator_sum_check"]; Quit[0];

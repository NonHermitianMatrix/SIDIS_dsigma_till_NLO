(* Verify exact preprocessing of the original recoil limit on actual inputs. *)
$HistoryLength = 0;
recoilSourcePath = FileNameJoin[{Directory[], "common", "s12_check_recoil_factorization.wls"}];
recoilAdapterPath = FileNameJoin[{Directory[], "common", "s12_assemble_real_rational.wls"}];
If[IntegerString[FileHash[recoilAdapterPath, "SHA256"], 16, 64] =!=
  "25de9eb8201f602b83e3e6757adc8adf88c58e3583e01f5dfb1a9188ff836f6f", Quit[1]];
recoilAdapterText = Import[recoilAdapterPath, "Text"];
recoilBoundary = "\nToExpression[rationalProgram, InputForm];";
If[StringCount[recoilAdapterText, recoilBoundary] =!= 1 || !SyntaxQ[Import[recoilSourcePath, "Text"]], Quit[1]];
recoilInitialization = First[StringSplit[recoilAdapterText, recoilBoundary]];
If[StringCount[recoilInitialization, "Get[\"FeynCalc`\"]"] =!= 1, Quit[1]];
recoilInitialization = StringReplace[recoilInitialization, "Get[\"FeynCalc`\"]" -> "Null"];
If[!SyntaxQ[recoilInitialization], Quit[1]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
ToExpression[recoilInitialization, InputForm];
gate["recoil comparison channel", channel === "Hqqbar"];
recoilConfigPath = FileNameJoin[{root, "common", "s12_recoil_factorization_inputs.json"}];
recoilConfig = Import[recoilConfigPath, "RawJSON"];
KeyValueMap[gate["recoil comparison input " <> #1,
  IntegerString[FileHash[FileNameJoin[{root, #1}], "SHA256"], 16, 64] === #2] &, recoilConfig["files"]];
recoilCapturePath = FileNameJoin[{root, recoilConfig["capture"]}];
recoilCapture = Get[recoilCapturePath];
recoilReceipt = Import[FileNameJoin[{DirectoryName[recoilCapturePath], "s12_execution.json"}], "RawJSON"];
gate["accepted exact recoil capture", TrueQ[recoilReceipt["passed"]] &&
  recoilReceipt["result_sha256"][recoilConfig["capture"]] === recoilConfig["files"][recoilConfig["capture"]] &&
  recoilCapture["Schema"] === "polarized-sidis-recoil-valuation-capture-v1" &&
  recoilCapture["Channel"] === channel && And @@ Values[recoilCapture["Checks"]] &&
  recoilCapture["ProductionSourceHash"] === sourceHash && recoilCapture["InputHash"] === inputHash &&
  recoilCapture["InputHashes"] === inputHashes && recoilCapture["NativeVersions"] === {$Version, $FeynCalcVersion} &&
  recoilCapture["OriginalDefinitions"] === DownValues[softRows]];
recoilOriginalDefinitions = {DownValues[softRows], DownValues[softPieces], DownValues[pieceEndpoint],
  DownValues[epsilonSeries], DownValues[laurentProduct], DownValues[assemble]};
recoilData[coefficient_, sign_] := recoilData[coefficient, sign] = Module[
  {original, rational, derivative, ratio, valuation, seconds},
  original = Cancel[coefficient /. t -> sign omega - s];
  {seconds, rational} = AbsoluteTiming[bounded[Factor[original], "factor actual recoil coefficient"]];
  gate["exact factored recoil coefficient", bounded[Factor[Together[rational - original]] === 0,
    "factored recoil reconstruction"]];
  derivative = s23 D[rational, s23]/rational;
  ratio = bounded[Factor[Together[derivative]], "reduce actual logarithmic derivative"];
  gate["exact reduced logarithmic derivative", bounded[Factor[Together[ratio - derivative]] === 0,
    "logarithmic derivative reconstruction"]];
  valuation = bounded[FullSimplify[Limit[ratio, s23 -> 0, Direction -> "FromAbove",
    Assumptions -> branchAssumptions[sign]], branchAssumptions[sign]], "factored recoil valuation"];
  gate["factored recoil valuation is an unconditional integer", IntegerQ[valuation]];
  Print["RECOIL_FACTORIZATION branch ", sign, " factor_seconds ", seconds,
    " original_bytes ", ByteCount[original], " factored_bytes ", ByteCount[rational],
    " derivative_bytes ", ByteCount[derivative], " reduced_bytes ", ByteCount[ratio],
    " valuation ", InputForm[valuation]];
  <|"Rational" -> rational, "Valuation" -> valuation, "ReducedDerivative" -> ratio|>];
softRows[coefficient_,piece_,sign_] := Module[
  {power=piece["Power"],integerPower,kappa,recoil,rational,valuation,firstPower,leading,value},
  integerPower=power/.eps->0;kappa=-Coefficient[power,eps];
  gate["regulated soft power is affine with integer recoil degree",
    IntegerQ[integerPower]&&PolynomialQ[power,eps]&&Exponent[power,eps]<=1];
  recoil=recoilData[coefficient,sign];rational=recoil["Rational"];valuation=recoil["Valuation"];
  gate["spin coefficient has integer recoil valuation",IntegerQ[valuation]];
  firstPower=valuation+integerPower;
  If[firstPower>=0,Return[{}]];
  gate["measured recoil degree needs only a leading endpoint coefficient",firstPower===-1];
  leading=bounded[FullSimplify[Limit[s23^(-valuation)rational,s23->0,
    Direction->"FromAbove",Assumptions->branchAssumptions[sign]],branchAssumptions[sign]],
    "physical spin endpoint coefficient"];
  gate["rational endpoint coefficient is finite",FreeQ[leading,s23|Indeterminate|ComplexInfinity|_DirectedInfinity]];
  value=epsilonSeries[(leading/.D->4-2eps)pieceEndpoint[piece,sign],1,"leading soft epsilon coefficient"];
  value=bounded[reduce[value,branchAssumptions[sign]],"leading endpoint collection"];
  gate["endpoint coefficients are fully evaluated",FreeQ[value,s23|_Limit|_Derivative|_Series|_SeriesData|Indeterminate|ComplexInfinity]];
  If[value===0,{},{{kappa,firstPower,value}}]];
recoilHelperDefinitions = DownValues[recoilData]; recoilRowDefinitions = DownValues[softRows];
recoilFailure = recoilCapture["Failure"];
gate["captured recoil substitution exact", Cancel[recoilFailure["Coefficient"] /.
  t -> recoilFailure["Branch"] omega - s] === recoilFailure["Rational"]];
{recoilSeconds, recoilCorrected} = AbsoluteTiming[recoilData[recoilFailure["Coefficient"], recoilFailure["Branch"]]];
recoilOld = recoilFailure["Valuation"];
gate["captured conditional valuation structure", MatchQ[recoilOld, _ConditionalExpression]];
gate["same valuation on original returned domain", bounded[FullSimplify[
  recoilCorrected["Valuation"] == recoilOld[[1]], branchAssumptions[recoilFailure["Branch"]] && recoilOld[[2]]],
  "captured conditional valuation comparison"]];
Print["RECOIL_FAILURE_COMPARISON seconds ", recoilSeconds, " original_seconds ", recoilFailure["Seconds"]];
recoilCanonicalCache = cache;
cache = FileNameJoin[{root, "cache", "s12_recoil_factorization", channel,
  IntegerString[Hash[{inputHash, FileHash[recoilSourcePath, "SHA256"], FileHash[recoilConfigPath, "SHA256"]}, "SHA256"], 16]}];
If[!DirectoryQ[cache], CreateDirectory[cache, CreateIntermediateDirectories -> True]];
recoilControls = Association[KeyValueMap[FromDigits[#1] -> Get[FileNameJoin[{root, #2}]] &, recoilConfig["controls"]]];
KeyValueMap[gate["accepted recoil control " <> ToString[#1], AssociationQ[#2] && TrueQ[#2["Accepted"]] &&
  #2["InputHash"] === inputHash && And @@ Values[#2["Checks"]] &&
  KeyTake[#2, {"Sector", "Kind", "Index"}] === KeyTake[mapped["Components"][[#1]], {"Sector", "Kind", "Index"}]] &, recoilControls];
recoilCompare[value_, control_, index_] := Module[{actualRows, oldRows},
  gate["own complete ordinary control " <> ToString[index], bounded[zeroCoefficient[value["Ordinary"] - control["Ordinary"]], "recoil ordinary control"]];
  Do[
    gate["own branch assumptions unchanged", value["Branches"][sign]["Assumptions"] === control["Branches"][sign]["Assumptions"]];
    Do[gate["own complete branch control " <> ToString[{index, sign, key}], bounded[
      zeroCoefficient[value["Branches"][sign][key] - control["Branches"][sign][key]], "recoil branch control"]],
      {key, {"Delta", "L0", "L1", "Regular"}}];
    actualRows = value["Branches"][sign]["SoftCoefficients"]; oldRows = control["Branches"][sign]["SoftCoefficients"];
    gate["own complete soft support", Length[actualRows] === Length[oldRows] &&
      (Take[#, 2] & /@ actualRows) === (Take[#, 2] & /@ oldRows)];
    gate["own complete soft coefficients", And @@ MapThread[
      bounded[zeroCoefficient[Last[#1] - Last[#2]], "recoil soft control"] &, {actualRows, oldRows}]],
    {sign, {1, -1}}]];
recoilValues = <||>; recoilTimings = <||>;
Do[
  {recoilElapsed, recoilValue} = AbsoluteTiming[assemble[mapped["Components"][[recoilIndex]], recoilIndex]];
  gate["complete candidate recoil component", AssociationQ[recoilValue] && TrueQ[recoilValue["Accepted"]] &&
    And @@ Values[recoilValue["Checks"]] && recoilValue["InputHash"] === inputHash];
  If[KeyExistsQ[recoilControls, recoilIndex], recoilCompare[recoilValue, recoilControls[recoilIndex], recoilIndex]];
  AssociateTo[recoilValues, recoilIndex -> recoilValue]; AssociateTo[recoilTimings, recoilIndex -> recoilElapsed],
  {recoilIndex, Join[Keys[recoilControls], recoilConfig["targets"]]}];
gate["original integration and master definitions retained", Rest[recoilOriginalDefinitions] ===
  {Select[DownValues[softPieces], !FreeQ[First[#], _Pattern] &],
   Select[DownValues[pieceEndpoint], !FreeQ[First[#], _Pattern] &],
   DownValues[epsilonSeries], DownValues[laurentProduct], DownValues[assemble]}];
recoilResult = <|"Schema" -> "polarized-sidis-recoil-factorization-comparison-v1", "Channel" -> channel,
  "SourceHash" -> FileHash[recoilSourcePath, "SHA256"], "AdapterSourceHash" -> FileHash[recoilAdapterPath, "SHA256"],
  "ProductionSourceHash" -> sourceHash, "InputHash" -> inputHash, "InputHashes" -> inputHashes,
  "ConfigurationHash" -> FileHash[recoilConfigPath, "SHA256"], "CaptureHash" -> FileHash[recoilCapturePath, "SHA256"],
  "RationalProofHash" -> FileHash[rationalProofPath, "SHA256"], "OriginalDefinitions" -> recoilOriginalDefinitions,
  "HelperDefinitions" -> recoilHelperDefinitions, "RowDefinitions" -> recoilRowDefinitions,
  "CapturedComparison" -> recoilCorrected, "CapturedSeconds" -> recoilSeconds,
  "ComponentHashes" -> Association[(# -> Hash[mapped["Components"][[#]], "SHA256"]) & /@ Keys[recoilValues]],
  "Components" -> recoilValues, "ComponentSeconds" -> recoilTimings, "Cache" -> cache,
  "NativeVersions" -> {$Version, $FeynCalcVersion}, "Checks" -> checks, "FiniteNLOFHatsComputed" -> False|>;
recoilDirectory = FileNameJoin[{root, channel, "s12_recoil_factorization_result"}];
If[!DirectoryQ[recoilDirectory], CreateDirectory[recoilDirectory, CreateIntermediateDirectories -> True]];
recoilFile = FileNameJoin[{recoilDirectory, "s12_result.wl"}];
recoilSerialized = "Uncompress[" <> ToString[bounded[Compress[recoilResult], "recoil proof compression"], InputForm] <> "]\n";
gate["bounded complete recoil proof", StringLength[recoilSerialized] < 128*1024^2];
Export[recoilFile <> ".tmp", recoilSerialized, "Text"];
gate["exact native recoil proof reload", bounded[Get[recoilFile <> ".tmp"] === recoilResult, "recoil proof reload"]];
RenameFile[recoilFile <> ".tmp", recoilFile, OverwriteTarget -> True];
Export[FileNameJoin[{recoilDirectory, "s12_checks.json"}], <|"checks" -> checks,
  "components" -> Keys[recoilValues], "captured_seconds" -> recoilSeconds, "job_id" -> Environment["JOB_ID"],
  "finite_nlo_fhats_computed" -> False|>, "RawJSON"];
Print["PASS: s12_check_recoil_factorization"]; Quit[0];

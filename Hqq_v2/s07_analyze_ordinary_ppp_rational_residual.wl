(* Hqq_v2 S07: exact factor inventory of the cached PPP ordinary residual. *)

ClearAll["Global`*"];
$HistoryLength = 0;
$IterationLimit = Infinity;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"], {SetDelayed::wrsym,
  FrontEndObject::notavail}];
$FCAdvice = False;

ClearAll[fail, require, atomicPut, exactZeroQ, badSymbolicQ,
  expressionHash];
scopeTag =
  "[Hqq_v2, people or agents working on other channels should ignore]";
Print[scopeTag];
fail[message_String, detail_: Null] := (
  Print["S07_PPP_RATIONAL_FAILURE: ", message];
  If[detail =!= Null,
    Print["S07_PPP_RATIONAL_FAILURE_DETAIL=", InputForm[detail]]];
  Quit[1]
);
require[condition_, message_String, detail_: Null] :=
  If[! TrueQ[condition], fail[message, detail]];
exactZeroQ[expression_] := TrueQ[Quiet@Check[
  Cancel[Together[expression]] === 0, False]];
badSymbolicQ[expression_] := ! FreeQ[expression,
  $Failed | _Missing | _Real | _SeriesData | Integrate |
    Inactive[Integrate] | Limit | ConditionalExpression | Indeterminate |
    ComplexInfinity | DirectedInfinity];
expressionHash[expression_] := IntegerString[
  Hash[expression, "SHA256"], 16, 64];
atomicPut[expression_, path_String] := Module[{temporary},
  temporary = path <> ".tmp." <> ToString[$ProcessID];
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary],
    fail["rational-factor result publication failed"]];
  require[FileExistsQ[temporary] && FileByteCount[temporary] > 0,
    "rational-factor temporary file is missing"];
  RenameFile[temporary, path, OverwriteTarget -> True];
  require[FileExistsQ[path] && FileByteCount[path] > 0,
    "published rational-factor result is missing"];
];

stageDirectory = DirectoryName[ExpandFileName[$InputFileName]];
sourcePath = ExpandFileName[$InputFileName];
cachePath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_raw_residual_cache.wl"}];
resultPath = FileNameJoin[{stageDirectory,
  "s07_ordinary_ppp_rational_factor_result.wl"}];
expectedCacheHash =
  "afc12bb8e9942d9059c0f1eda9e1e6d73d137e19af5dc0cf26651992edaad569";
expectedProducerHash =
  "f66a719faf20465e6986eb2b8f592c5b7449f9efad41d32be715abbed154ebc6";
expectedResidualHash =
  "abe32a8afa08a3631e3735d9941598c05b170a5bebe5d49e78677026ddb02918";
require[FileExistsQ[cachePath] && ! FileExistsQ[resultPath] &&
    FileHash[cachePath, "SHA256", "HexString"] === expectedCacheHash,
  "rational-factor input/target state is invalid"];

cache = Quiet@Check[Get[cachePath], $Failed];
cacheChecks = <|
  "Association" -> AssociationQ[cache],
  "StageScope" -> TrueQ[AssociationQ[cache] &&
    cache["Stage"] === "HqqV2S07OrdinaryPPPRawResidualCache-v1" &&
    cache["ScopeTag"] === scopeTag],
  "Producer" -> TrueQ[AssociationQ[cache] &&
    cache["Source", "SHA256"] === expectedProducerHash],
  "StoredChecks" -> TrueQ[AssociationQ[cache] &&
    AssociationQ[cache["Checks"]] && And @@ Values[cache["Checks"]]],
  "ResidualIdentity" -> TrueQ[AssociationQ[cache] &&
    cache["RawResidualMetadata", "SHA256"] === expectedResidualHash &&
    cache["RawResidualMetadata", "Zero"] === False &&
    expressionHash[cache["RawResidual"]] === expectedResidualHash]|>;
require[And @@ Values[cacheChecks],
  "cached PPP residual failed its gates", cacheChecks];

Print["S07_PPP_RATIONAL_STAGE=exact factor inventory"];
residual = cache["RawResidual"];
togetherResidual = Quiet@Check[Cancel[Together[residual]], $Failed];
factoredResidual = Quiet@Check[Factor[togetherResidual], $Failed];
require[FreeQ[{togetherResidual, factoredResidual}, $Failed] &&
    ! badSymbolicQ[{togetherResidual, factoredResidual}],
  "exact rational reduction failed"];
numerator = Numerator[factoredResidual];
denominator = Denominator[factoredResidual];
variables = Quiet@Check[Variables[{numerator, denominator}], $Failed];
require[variables =!= $Failed && ListQ[variables],
  "rational variable inventory failed"];
numeratorFactors = Quiet@Check[FactorList[numerator], $Failed];
denominatorFactors = Quiet@Check[FactorList[denominator], $Failed];
require[FreeQ[{numeratorFactors, denominatorFactors}, $Failed],
  "rational factor-list extraction failed"];

checks = <|
  "AcceptedCache" -> And @@ Values[cacheChecks],
  "TogetherReconstructs" -> exactZeroQ[togetherResidual - residual],
  "FactorReconstructs" -> exactZeroQ[factoredResidual - residual],
  "NumeratorDenominatorReconstruct" -> exactZeroQ[
    factoredResidual - numerator/denominator],
  "NumeratorFactorListReconstruct" -> exactZeroQ[
    numerator - Times @@ (Power @@@ numeratorFactors)],
  "DenominatorFactorListReconstruct" -> exactZeroQ[
    denominator - Times @@ (Power @@@ denominatorFactors)],
  "ResidualNonzero" -> ! exactZeroQ[factoredResidual],
  "LogFree" -> FreeQ[factoredResidual, _Log],
  "ExactClosed" -> ! badSymbolicQ[
    {factoredResidual, numeratorFactors, denominatorFactors}] &&
    FreeQ[factoredResidual, epsilon | D | _SeriesData | _Real]|>;
require[And @@ Values[checks],
  "rational factor inventory failed", checks];

result = <|
  "Stage" -> "HqqV2S07OrdinaryPPPRationalFactor-v1",
  "ScopeTag" -> scopeTag,
  "Source" -> <|"Path" -> sourcePath,
    "SHA256" -> FileHash[sourcePath, "SHA256", "HexString"]|>,
  "Input" -> <|"RawCacheSHA256" -> expectedCacheHash,
    "ResidualSHA256" -> expectedResidualHash|>,
  "FactoredResidual" -> factoredResidual,
  "Numerator" -> numerator,
  "Denominator" -> denominator,
  "Variables" -> variables,
  "NumeratorFactors" -> numeratorFactors,
  "DenominatorFactors" -> denominatorFactors,
  "Metadata" -> <|
    "ResidualLeafCount" -> LeafCount[residual],
    "FactoredLeafCount" -> LeafCount[factoredResidual],
    "NumeratorLeafCount" -> LeafCount[numerator],
    "DenominatorLeafCount" -> LeafCount[denominator],
    "VariableCount" -> Length[variables],
    "NumeratorFactorCount" -> Length[Rest[numeratorFactors]],
    "DenominatorFactorCount" -> Length[Rest[denominatorFactors]],
    "FactoredSHA256" -> expressionHash[factoredResidual]|>,
  "Checks" -> checks|>;
atomicPut[result, resultPath];
reloaded = Quiet@Check[Get[resultPath], $Failed];
require[SameQ[reloaded, result],
  "same-kernel rational-factor result reload failed"];
Print["S07_PPP_RATIONAL_RESULT_SHA256=",
  FileHash[resultPath, "SHA256", "HexString"]];
Print["S07_PPP_RATIONAL_FACTORED=", InputForm[factoredResidual]];
Print["S07_PPP_RATIONAL_METADATA=", InputForm[result["Metadata"]]];
Print["S07_PPP_RATIONAL_CHECKS=", InputForm[checks]];
Print["S07_PPP_RATIONAL_SUCCESS"];
Quit[0];

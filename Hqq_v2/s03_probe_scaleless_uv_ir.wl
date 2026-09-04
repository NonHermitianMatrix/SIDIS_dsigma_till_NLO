(* Hqq_v2 S03: verify the installed Package-X scaleless UV/IR convention. *)
$HistoryLength = 0;
If[DirectoryQ["/u/home/r/rushil/.Mathematica/Applications"],
  PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"]];
$LoadAddOns = {"FeynArts", "FeynHelpers"};
$FeynCalcStartupMessages = False;
Quiet[Needs["FeynCalc`"]];

ClearAll[hqqV2Fail, hqqV2Require, atomicPut, lProbe, pProbe];
hqqV2Fail[msg_String] := (Print["S03_SCALELESS_PROBE_FAILURE: " <> msg]; Quit[1]);
hqqV2Require[test_, msg_String] := If[! TrueQ[test], hqqV2Fail[msg]];
atomicPut[expression_, path_String] := Module[{temporary = path <> ".tmp." <> ToString[$ProcessID]},
  If[FileExistsQ[temporary], DeleteFile[temporary]];
  Check[Put[expression, temporary], hqqV2Fail["write failed"]];
  RenameFile[temporary, path, OverwriteTarget -> True]
];

sourcePath = ExpandFileName[$InputFileName];
baseDirectory = DirectoryName[sourcePath];
resultPath = FileNameJoin[{baseDirectory, "s03_scaleless_uv_ir_probe_result.wl"}];

$KeepLogDivergentScalelessIntegrals = True;
FeynCalc`FCClearScalarProducts[];
FeynCalc`SPD[pProbe, pProbe] = 0;

directBubble = FeynCalc`B0[0, 0, 0];
directSplit = FeynCalc`PaXEvaluateUVIRSplit[directBubble,
  FeynCalc`PaXImplicitPrefactor -> 1];
directUV = FeynCalc`PaXEvaluateUV[directBubble,
  FeynCalc`PaXImplicitPrefactor -> 1];
directIR = FeynCalc`PaXEvaluateIR[directBubble,
  FeynCalc`PaXImplicitPrefactor -> 1];

integrand = FeynCalc`FAD[{lProbe, 0}, {lProbe - pProbe, 0}];
integrandSplit = FeynCalc`PaXEvaluateUVIRSplit[integrand, lProbe,
  FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D];
integrandUV = FeynCalc`PaXEvaluateUV[integrand, lProbe,
  FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D];
integrandIR = FeynCalc`PaXEvaluateIR[integrand, lProbe,
  FeynCalc`PaXImplicitPrefactor -> 1/(2 Pi)^D];

checks = <|
  "KeepScalelessEnabled" -> TrueQ[$KeepLogDivergentScalelessIntegrals],
  "DirectSplitResolved" -> FreeQ[directSplit, FeynCalc`B0 | FeynCalc`PaVe | _Real | $Failed],
  "IntegrandSplitResolved" -> FreeQ[integrandSplit,
    FeynCalc`FeynAmpDenominator | FeynCalc`B0 | FeynCalc`PaVe | _Real | $Failed],
  "DirectUVIRReconstruct" -> TrueQ[Together[directSplit - directUV - directIR] === 0],
  "IntegrandUVIRReconstruct" -> TrueQ[Together[integrandSplit - integrandUV - integrandIR] === 0],
  "SeparateRegulatorsPresent" -> (! FreeQ[{directSplit, integrandSplit}, FeynCalc`EpsilonUV] &&
    ! FreeQ[{directSplit, integrandSplit}, FeynCalc`EpsilonIR])
|>;
Print["S03_SCALELESS_PROBE_VALUES=", InputForm[<|
  "Direct" -> <|"Split" -> directSplit, "UV" -> directUV, "IR" -> directIR|>,
  "Integrand" -> <|"Split" -> integrandSplit, "UV" -> integrandUV, "IR" -> integrandIR|>|>]];
Print["S03_SCALELESS_PROBE_CHECKS=", InputForm[checks]];
hqqV2Require[And @@ Values[checks], "one or more Package-X convention gates failed"];

result = <|
  "Stage" -> "HqqV2S03ScalelessUVIRProbe-v1",
  "SourceSHA256" -> FileHash[sourcePath, "SHA256", "HexString"],
  "Runtime" -> <|"Wolfram" -> $Version, "FeynCalc" -> FeynCalc`$FeynCalcVersion,
    "FeynHelpers" -> FeynCalc`$FeynHelpersVersion|>,
  "DirectBubble" -> <|"Split" -> directSplit, "UV" -> directUV, "IR" -> directIR|>,
  "IntegrandBubble" -> <|"Split" -> integrandSplit, "UV" -> integrandUV, "IR" -> integrandIR|>,
  "Checks" -> checks
|>;
atomicPut[result, resultPath];
hqqV2Require[Get[resultPath]["Checks"] === checks, "fresh reload failed"];
Print["S03_SCALELESS_PROBE_RESULT_SHA256=", FileHash[resultPath, "SHA256", "HexString"]];
Print["S03_SCALELESS_PROBE_SUCCESS"];
Quit[0];

(* Correct the signed-model-label interface in the independent Hgq comparison. *)
$HistoryLength = 0;
root = Directory[];
sourcePath = FileNameJoin[{root, "common", "s17_check_Hgq_color_dimension.wls"}];
referenceRoot = FileNameJoin[{root, "Hgq", "s16_result", "reference"}];
out = FileNameJoin[{root, "Hgq", "s17_result"}];
checks = <||>;
gate[name_, test_] := If[TrueQ[test], AssociateTo[checks, name -> True]; Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
gate["compute allocation", StringQ[Environment["JOB_ID"]] && !StringStartsQ[$MachineName, "login"]];
PrependTo[$Path, "/u/home/r/rushil/.Mathematica/Applications"];
$FeynCalcStartupMessages = False; Get["FeynCalc`"];
gate["complete source syntax", SyntaxQ[Import[sourcePath, "Text"]]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 180,
  gate["time bound " <> label, False]], 2*1024^3, gate["memory bound " <> label, False]];
sha[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];
manifestPath = FileNameJoin[{root, "common", "s16_Hgq_reference_sign_inputs.json"}];
manifest = Import[manifestPath, "RawJSON"];
KeyValueMap[gate["pinned " <> #1, sha[FileNameJoin[{root, #1}]] === #2] &, manifest];
metadata = Import[FileNameJoin[{referenceRoot, "s01_result.json"}], "RawJSON"];
samples = Import[FileNameJoin[{referenceRoot, "s03_result.json"}], "RawJSON"];
original = Import[FileNameJoin[{referenceRoot, "s04_result.json"}], "RawJSON"];
born = Get[FileNameJoin[{referenceRoot, "inputs", "s02_result.wl"}]];
real = Get[FileNameJoin[{referenceRoot, "inputs", "s03_result.wl"}]];
nativePath = FileNameJoin[{root, "Hgq", "s16_result", "native_contractions_14818476", "s16_result.wl"}];
native = Get[nativePath];
gate["saved exact native contraction accepted", sha[nativePath] ===
  "ff6681d1d06cbdabd5935107c0a5e5d2a0c38d39a605c3d7194e64cf259333a2" &&
  TrueQ[native["Report"]["OwnAcceptedPairExactlyReproduced"]] &&
  TrueQ[native["Report"]["CompleteSavedReferenceExactlyReproduced"]] &&
  native["Report"]["ManifestSHA256"] === sha[manifestPath] &&
  native["Report"]["NativeVersions"] === {$Version, $FeynCalcVersion}];
fundamental = SUNSimplify[SUNFDelta[ci, ci], SUNNToCACF -> False];
adjoint = SUNSimplify[SUNDelta[ca, ca], SUNNToCACF -> False];
colorSolutions = Solve[{fundamental == Abs[metadata["Particles"]["u"]["color"]],
  adjoint == Abs[metadata["Particles"]["g"]["color"]], SUNN > 0}, {SUNN}, Reals];
gate["unique positive model color dimension", Length[colorSolutions] === 1];
colorDimension = SUNN /. First[colorSolutions];
gate["native color traces and reference dimensions agree", IntegerQ[colorDimension] && colorDimension > 0 &&
  (born["FundamentalDimension"] /. SUNN -> colorDimension) === Abs[metadata["Particles"]["u"]["color"]] &&
  (born["AdjointDimension"] /. SUNN -> colorDimension) === Abs[metadata["Particles"]["g"]["color"]]];
Print["COLOR_DIMENSION ", InputForm[<|"SignedModelLabel" -> metadata["Particles"]["u"]["color"],
  "DerivedPositiveDimension" -> colorDimension|>]];
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot[a_, b_] := a.metric.b;
exactNumbers[value_] := Rationalize[value, 0];
exactMomenta[value_] := Map[Function[vector, Map[exactNumbers, vector]], value];
close[a_, b_] := Abs[a - b] <= 10^-25 + 10^-8 Max[Abs[a], Abs[b]];
relative[a_, b_] := If[Max[Abs[a], Abs[b]] === 0, 0, Abs[a - b]/Max[Abs[a], Abs[b]]];
invariants[mom_, kind_] := Module[{pin = mom["p"], photon = mom["q"], tagged = mom["k1"],
  quark = mom["k2"], spectator, rules},
  rules = {Q2 -> -dot[photon, photon], s -> dot[pin + photon, pin + photon], t -> dot[photon - tagged, photon - tagged]};
  If[kind === "real", spectator = mom["k3"];
    rules = Join[rules, {s23 -> dot[quark + spectator, quark + spectator],
      a12 -> dot[tagged + quark, tagged + quark], u3 -> dot[pin - spectator, pin - spectator]}]]; rules];
rows = {}; nativeComparison = <||>;
Do[
  kind = point["Kind"]; id = point["ID"];
  mom = exactMomenta[point["HadronMomenta"]];
  gate[id <> " exact coordinate inputs", FreeQ[Values[mom], _Real]];
  rules = invariants[mom, kind];
  normalization = Map[Function[text, exactNumbers[ToExpression[text]]], original["Normalization"][kind]];
  gate[id <> " exact normalization inputs", FreeQ[Values[normalization], _Real]];
  prefactor = Abs[normalization["AmplitudeCoupling"] normalization["ChargeAmplitude"] (-I/dot[mom["q"], mom["q"]])]^2;
  expressions = If[kind === "born", normalization["TagWeight"] {born["BornPg"], born["BornPpp"]},
    Lookup[real["Contractions"], {"Pg", "Ppp"}]];
  oldRow = SelectFirst[original["Rows"], #["ID"] === id &];
  oldValues = bounded[N[(prefactor expressions /. {D -> Length[metric],
    SUNN -> metadata["Particles"]["u"]["color"]}) /. rules, 40], id <> " original comparison"];
  gate[id <> " entire old comparison reproduced", And @@ MapThread[close,
    {oldValues, Lookup[oldRow, {"LocalScaledPg", "LocalScaledPpp"}]}]];
  values = bounded[N[(prefactor expressions /. {D -> Length[metric], SUNN -> colorDimension}) /. rules, 40], id <> " corrected comparison"];
  gate[id <> " finite real projectors", AllTrue[values, NumberQ[#] && FreeQ[#, Indeterminate | _DirectedInfinity] && Im[#] === 0 &]];
  external = Lookup[point, {"MadGraphScaledPg", "MadGraphScaledPpp"}];
  projectorPass = MapThread[close, {values, external}];
  averages = exactNumbers[point["LeptonWeights"]].values;
  averagePass = MapThread[close, {averages, point["TaggedAzimuthAverages"]}];
  gate[id <> " both MadGraph projectors", And @@ projectorPass];
  gate[id <> " all lepton-setting averages", And @@ averagePass];
  AppendTo[rows, <|"ID" -> id, "Kind" -> kind, "OriginalColorLabel" -> metadata["Particles"]["u"]["color"],
    "DerivedColorDimension" -> colorDimension, "OriginalValues" -> N[oldValues, 17], "CorrectedValues" -> N[values, 17],
    "MadGraphValues" -> external, "RelativeDifferences" -> N[MapThread[relative, {values, external}], 17],
    "ProjectorsPass" -> projectorPass, "AzimuthAveragesPass" -> averagePass|>];
  If[id === native["Report"]["Point"],
    fresh = bounded[N[prefactor (native["ExactTotal"] /. {D -> Length[metric], SUNN -> colorDimension}), 40], "saved fresh exact contraction"];
    gate["fresh exact contraction equals corrected reference", close[fresh, Last[values]]];
    gate["fresh exact contraction equals MadGraph", close[fresh, Last[external]]];
    nativeComparison = <|"Point" -> id, "FreshScaledPpp" -> N[fresh, 17], "CorrectedStoredPpp" -> N[Last[values], 17],
      "MadGraphScaledPpp" -> Last[external], "RelativeDifference" -> N[relative[fresh, Last[external]], 17]|>],
  {point, samples["Rows"]}];
gate["complete existing sample inventory", Lookup[rows, "ID"] === Lookup[samples["Rows"], "ID"] && Length[nativeComparison] > 0];
report = <|"Schema" -> "polarized-sidis-corrected-reference-color-comparison-v1", "Channel" -> "Hgq",
  "SourceSHA256" -> sha[sourcePath], "InputManifestSHA256" -> sha[manifestPath],
  "NativeContractionSHA256" -> sha[nativePath], "NativeVersions" -> {$Version, $FeynCalcVersion},
  "SignedModelColorLabel" -> metadata["Particles"]["u"]["color"], "DerivedColorDimension" -> colorDimension,
  "PointCount" -> Length[rows], "ProjectorComparisonCount" -> Total[Length[#["ProjectorsPass"]] & /@ rows],
  "AllProjectorsPass" -> And @@ Flatten[Lookup[rows, "ProjectorsPass"]],
  "AllAzimuthAveragesPass" -> And @@ Flatten[Lookup[rows, "AzimuthAveragesPass"]],
  "MaximumRelativeDifference" -> Max[Flatten[Lookup[rows, "RelativeDifferences"]]],
  "NativeComparison" -> nativeComparison, "Rows" -> rows, "Checks" -> checks,
  "ProductionCoefficientsChanged" -> False|>;
If[!DirectoryQ[out], CreateDirectory[out, CreateIntermediateDirectories -> True]];
Put[report, FileNameJoin[{out, "s17_result.wl"}]];
gate["complete native report reload", Get[FileNameJoin[{out, "s17_result.wl"}]] === report];
Export[FileNameJoin[{out, "s17_checks.json"}], report, "RawJSON"];
gate["complete JSON report reload", Import[FileNameJoin[{out, "s17_checks.json"}], "RawJSON"]["AllProjectorsPass"] === True];
Print[InputForm[KeyDrop[report, {"Rows", "Checks"}]]]; Print["PASS: s17_check_Hgq_color_dimension"]; Quit[0];

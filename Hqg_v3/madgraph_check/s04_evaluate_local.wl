(* Evaluate the accepted Hqg Born and real Pg/Ppp at the MadGraph points. *)
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
root = DirectoryName[$InputFileName];
channel = DirectoryName[root];
ClearAll[gate, sha, bounded, checkInputs, dot, invariants, evaluate];
gate[label_, condition_] := If[TrueQ[condition], Print["PASS: ", label], Print["FAIL: ", label]; Quit[1]];
sha[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 180,
  Print["TIME LIMIT: ", label]; Quit[2]], 1024^3,
  Print["MEMORY LIMIT: ", label]; Quit[3]];
manifest = Import[FileNameJoin[{root, "s01_result.json"}], "RawJSON"];
samplesPath = FileNameJoin[{root, "s03_result.json"}];
samples = Import[samplesPath, "RawJSON"];
sampleHash = sha[samplesPath];
gate["Hqg sample and source binding", samples["Channel"] === "Hqg" &&
  samples["InputManifestSHA256"] === sha[FileNameJoin[{root, "s01_result.json"}]] &&
  samples["SourceSHA256"] === sha[FileNameJoin[{root, "s03_sample_madgraph.py"}]]];
checkInputs[] := KeyValueMap[Function[{name, record},
  gate["accepted copied " <> name, sha[FileNameJoin[{root, "inputs", name}]] === record["sha256"]];
  gate["unchanged parent " <> name, sha[FileNameJoin[{channel, name}]] === record["sha256"]]],
  manifest["Inputs"]];
checkInputs[];
born = Get[FileNameJoin[{root, "inputs", "s02_result.wl"}]];
amplitudes = Get[FileNameJoin[{root, "inputs", "s04_result.wl"}]];
real = Get[FileNameJoin[{root, "inputs", "s05_result.wl"}]];
gate["accepted Born Ward identities", And @@ (# === 0 & /@ Values[born["Checks"]])];
gate["accepted real Ward identities", And @@ (# === 0 & /@
  Lookup[real["Contractions"], {"PhotonWard", "Gluon1Ward", "Gluon3Ward"}])];
gate["accepted real coupling convention", real["CouplingsRemoved"] === "eq^2 gs^4"];
particles = manifest["Particles"];
metric = DiagonalMatrix[{1, -1, -1, -1}];
dot[v_, w_] := v . metric . w;
normalization = <||>;
Do[
  mg = samples["Processes"][kind];
  name = If[kind === "born", "Born", "Real"];
  degrees = DeleteDuplicates[({Exponent[#, SMP["e"]], Exponent[#, SMP["g_s"]]} &) /@ amplitudes[name]];
  gate[kind <> " measured amplitude degrees", Length[degrees] === 1];
  degree = First[degrees];
  gate[kind <> " independent generated diagram count", Length[amplitudes[name]] === mg["DiagramCount"]];
  gate[kind <> " strong coupling order", degree[[2]] === mg["CouplingOrders"]["QCD"]];
  electronVertices = mg["CouplingOrders"]["QED"]-degree[[1]];
  gate[kind <> " electron electromagnetic vertex",
    electronVertices === Count[mg["Incoming"], "e-"]];
  finalCounts = Counts[mg["Outgoing"]];
  symmetry = Times @@ (Factorial /@ Values[finalCounts]);
  tag = Count[mg["Outgoing"], "g"]/symmetry;
  If[kind === "real", gate["S05 tag weight equals generated species weight", tag === real["TagWeight"]]];
  constants = Rationalize[mg["Couplings"], 0];
  gate[kind <> " model quark charge matches S05",
    Abs[constants["QuarkChargeAbs"]^2-real["ModelChargeSquared"]] < 10^-14];
  amplitudeCoupling = constants["e"]^mg["CouplingOrders"]["QED"]*
    constants["gs"]^mg["CouplingOrders"]["QCD"];
  chargeAmplitude = Sqrt[real["ModelChargeSquared"]]*constants["ElectronChargeAbs"]^electronVertices;
  AssociateTo[normalization, kind -> <|"AmplitudeCoupling" -> amplitudeCoupling,
    "ChargeAmplitude" -> chargeAmplitude, "TagWeight" -> tag,
    "HadronicCouplingDegrees" -> degree, "ElectronVertices" -> electronVertices|>],
  {kind, Keys[samples["Processes"]]}];

invariants[mom_, kind_] := Module[{pin = mom["p"], photon = mom["q"],
    tagged = mom["k1"], quark = mom["k2"], spectator, rules},
  rules = {Q2 -> -dot[photon, photon], s -> dot[pin+photon, pin+photon],
    t -> dot[photon-tagged, photon-tagged]};
  If[kind === "real", spectator = mom["k3"];
    rules = Join[rules, {s23 -> dot[quark+spectator, quark+spectator],
      a12 -> dot[tagged+quark, tagged+quark], u3 -> dot[pin-spectator, pin-spectator]}]];
  rules
];
evaluate[expression_, rules_, label_] := Module[{value},
  value = bounded[N[expression /. {D -> Length[metric], SUNN -> particles["u"]["color"]} /. rules, 40], label];
  gate[label <> " finite real scalar", NumberQ[value] && FreeQ[value, Indeterminate | _DirectedInfinity] &&
    Abs[Im[value]] < 10^-30 Max[1, Abs[Re[value]]]];
  Re[value]
];
rows = {};
Do[
  kind = point["Kind"]; label = point["ID"];
  momenta = Rationalize[point["HadronMomenta"], 0];
  rules = invariants[momenta, kind];
  n = normalization[kind];
  photonPropagator = -I/dot[momenta["q"], momenta["q"]];
  prefactor = Abs[n["AmplitudeCoupling"]*n["ChargeAmplitude"]*photonPropagator]^2;
  expressions = If[kind === "born",
    n["TagWeight"]*{born["BornPg"], born["BornPpp"]},
    Lookup[real["Contractions"], {"Pg", "Ppp"}]];
  local = Table[evaluate[prefactor*expressions[[j]], rules, label <> "/" <> {"Pg", "Ppp"}[[j]]],
    {j, Length[expressions]}];
  exchangeResidual = 0;
  If[kind === "real",
    swapped = Join[momenta, <|"k1" -> momenta["k3"], "k3" -> momenta["k1"]|>];
    swappedRules = invariants[swapped, kind];
    exchanged = Table[evaluate[prefactor*expressions[[j]], swappedRules, label <> "/gluon exchange"],
      {j, Length[expressions]}];
    exchangeResidual = Max[MapThread[Abs[#1-#2]/Max[Abs[#1], Abs[#2], 10^-100] &, {local, exchanged}]];
    gate[label <> " identical-gluon exchange", exchangeResidual < 10^-8]];
  weights = Rationalize[point["LeptonWeights"], 0];
  AppendTo[rows, <|"ID" -> label, "Kind" -> kind,
    "LocalScaledPg" -> N[local[[1]], 17], "LocalScaledPpp" -> N[local[[2]], 17],
    "LocalTaggedAzimuthAverages" -> N[weights . local, 17],
    "Invariants" -> Association[(ToString[First[#], InputForm] -> N[Last[#], 17]) & /@ rules],
    "GluonExchangeRelativeDifference" -> N[exchangeResidual, 17]|>];
  Print["EVALUATED: ", label]; ClearSystemCache[],
  {point, samples["Rows"]}];
gate["complete local coverage", Lookup[rows, "ID"] === Lookup[samples["Rows"], "ID"]];
checkInputs[];
gate["sample unchanged", sha[samplesPath] === sampleHash];
output = FileNameJoin[{root, "s04_result.json"}];
gate["new local output", !FileExistsQ[output]];
result = <|"Channel" -> "Hqg", "SourceSHA256" -> sha[$InputFileName], "SampleSHA256" -> sampleHash,
  "Boundary" -> "spin/color-averaged tree Pg/Ppp; no phase-space, loop or subtraction input",
  "Numerics" -> "40-digit arithmetic at the same double-precision phase-space points",
  "Normalization" -> Map[Map[ToString[#, InputForm] &, #] &, normalization],
  "Rows" -> rows, "KernelPeakBytes" -> MaxMemoryUsed[]|>;
Export[output <> ".tmp", result, "RawJSON"];
gate["local JSON reload", Length[Import[output <> ".tmp", "RawJSON"]["Rows"]] === Length[rows]];
RenameFile[output <> ".tmp", output];
Print["HQG_MADGRAPH_S04_SUCCESS"];
Quit[0];

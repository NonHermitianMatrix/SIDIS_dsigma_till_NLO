(* Numerical benchmarks of the accepted incoming-quark, observed-gluon hats. *)
$HistoryLength = 0;
ClearAll[gate, bounded, sha, checkFrozen, number, jsonValue, localValue,
  authorValue, derivePoint, transport, atomicJSON];
root = DirectoryName[$InputFileName];
channel = DirectoryName[root];
gate[label_, test_] := If[TrueQ[test], Print["PASS: ", label],
  Print["FAIL: ", label]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 180,
  Print["TIME LIMIT: ", label]; Quit[2]], 1024^3,
  Print["MEMORY LIMIT: ", label]; Quit[3]];
sha[path_] := IntegerString[FileHash[path, "SHA256"], 16, 64];
manifest = Import[FileNameJoin[{channel, "s12_frozen_inputs.json"}], "RawJSON"];
checkFrozen[] := KeyValueMap[Function[{name, record},
  gate["frozen " <> name, sha[FileNameJoin[{channel, name}]] === record["sha256"]]],
  manifest["files"]];
checkFrozen[];
comparisonPath = FileNameJoin[{channel, "s13_result.wl"}];
gate["accepted Hqg S13 map", sha[comparisonPath] ===
  "c3fd17bb39e701b781a806d6b5b65213732c1094757e6eae83762a11c45b2f5f"];
comparison = Get[comparisonPath];
authorPath = FileNameJoin[{channel, "comparison", "s03_result.wl"}];
gate["corrected Hqg author endpoint input",
  FileHash[authorPath, "SHA256"] === comparison["AuthorResultHash"]];
independent = bounded[KeyTake[Get[FileNameJoin[{channel, "s12_result.wl"}]],
  {"Hats", "BranchCoordinates", "RegulatorCancellationPassed", "AuthorsCoefficientsUsed"}],
  "load S12"];
authors = KeyTake[Get[authorPath], {"BornDeltaCoefficients", "XhatRule",
  "PhysicalSupport", "SourceTree", "ReconstructionAssumption"}];
authorMetadataPath = FileNameJoin[{channel, "comparison", "s01_result.json"}];
gate["accepted Hqg source metadata",
  Import[authorMetadataPath, "RawJSON"] === comparison["AuthorMetadata"]];
born = Get[FileNameJoin[{channel, "s02_result.wl"}]];
gate["independent Hqg result accepted without author coefficients",
  independent["RegulatorCancellationPassed"] === True &&
  independent["AuthorsCoefficientsUsed"] === False];
names = Keys[independent["Hats"]];
gate["both hats", names === {"F1", "F2"}];
outputPath = FileNameJoin[{root, "s01_result.json"}];
gate["new S01 output", !FileExistsQ[outputPath]];

(* These are benchmark inputs, copied only from the named Hqqprime setup. *)
seeds = {
  <|"ID" -> "interior_1", "xB" -> 23/100, "xi" -> 61/100,
    "zH" -> 37/100, "Q2" -> 17, "qT2" -> 31/10, "S23Fraction" -> 2/5, "Nf" -> 4|>,
  <|"ID" -> "interior_2", "xB" -> 19/100, "xi" -> 73/100,
    "zH" -> 41/100, "Q2" -> 23, "qT2" -> 27/10, "S23Fraction" -> 7/20, "Nf" -> 4|>,
  <|"ID" -> "interior_3", "xB" -> 31/100, "xi" -> 79/100,
    "zH" -> 29/100, "Q2" -> 29, "qT2" -> 19/10, "S23Fraction" -> 11/20, "Nf" -> 4|>
};
kinematicRules = comparison["KinematicRules"];
zetaExpression = Factor[zH/(zh /. kinematicRules)];
upperSolutions = Solve[zetaExpression == 1, s23];
gate["unique physical upper-bound equation", Length[upperSolutions] === 1];
upperExpression = s23 /. First[upperSolutions];
jacobianExpression = Factor[D[zetaExpression, s23]];
gate["upper bound maps to zeta=1", Factor[(zetaExpression /. s23 -> upperExpression) - 1] === 0];
driverJacobian = zetaExpression*xh/(Q^2*((1-xh)-xh*s23/Q^2));
gate["Jacobian equals the published driver definition",
  Factor[jacobianExpression - driverJacobian] === 0];

(* Derive the complete coefficient-times-plus transport from its test action. *)
originalAction = (coefficientValue*testValue-coefficientEndpoint*testEndpoint)*kernel;
canonicalAction = plusWeight*(testValue-testEndpoint)*kernel+ordinaryWeight*testValue;
actionDifference = Expand[originalAction-canonicalAction];
transportSolutions = Solve[Table[Coefficient[actionDifference, test] == 0,
  {test, {testValue, testEndpoint}}], {plusWeight, ordinaryWeight}];
gate["unique plus transport", Length[transportSolutions] === 1];
transportRules = First[transportSolutions];
gate["plus transport reconstructs its action",
  Expand[actionDifference /. transportRules] === 0];
alphaRule = First[Solve[alphaS == gs^2/(4 Pi), alphaS]] /. gs -> 1;
gate["unit strong coupling conversion", Simplify[4 Pi alphaS /. alphaRule] === 1];
projectorExpressions = {f1, f2} /. born["ProjectorsEpsilon"] /. eps -> 0;
projectorWeights = Table[Coefficient[expression, projector],
  {expression, projectorExpressions}, {projector, {hg, hpp}}];
gate["saved Hqg projector reconstruction",
  Expand[projectorWeights . {hg, hpp}-projectorExpressions] === {0, 0}];
rawDensityDefinition = rawRegular+rawPlus0/s23+rawPlus1*Log[s23]/s23;
rawInteriorWeights = Coefficient[rawDensityDefinition, #] & /@
  {rawRegular, rawPlus0, rawPlus1};

derivePoint[seed_] := Module[{rules, upper, recoil, sval, tcurve, tval, tend,
    jval, jend, zvalue, zetavalue, p},
  rules = {xh -> seed["xB"]/seed["xi"], Q -> Sqrt[seed["Q2"]],
    qT2 -> seed["qT2"], zH -> seed["zH"]};
  upper = upperExpression /. rules;
  recoil = seed["S23Fraction"]*upper;
  sval = s /. kinematicRules /. rules;
  tcurve = t /. kinematicRules /. rules;
  tval = tcurve /. s23 -> recoil;
  tend = tcurve /. s23 -> 0;
  jval = jacobianExpression /. rules /. s23 -> recoil;
  jend = jacobianExpression /. rules /. s23 -> 0;
  zvalue = zh /. kinematicRules /. rules /. s23 -> recoil;
  zetavalue = zetaExpression /. rules /. s23 -> recoil;
  p = Join[seed, <|"xHat" -> (xh /. rules), "Q" -> (Q /. rules),
    "s" -> sval, "t" -> tval, "tEndpoint" -> tend,
    "S23UpperB" -> upper, "S23Sample" -> recoil, "zHat" -> zvalue,
    "zeta" -> zetavalue, "Jacobian" -> jval, "JacobianEndpoint" -> jend,
    "InteriorBranch" -> Sign[sval+tval], "EndpointBranch" -> Sign[sval+tend],
    "ProjectorWeights" -> (projectorWeights /. Q2 -> Q^2 /. rules),
    "RawInteriorWeights" -> (rawInteriorWeights /. s23 -> recoil)|>];
  gate[seed["ID"] <> " physical interior", 0 < p["xHat"] < 1 &&
    0 < recoil < upper && 0 < zvalue < 1 && 0 < zetavalue < 1 && jval > 0 && jend > 0];
  Do[gate[seed["ID"] <> " physical invariants " <> ToString[endpoint],
    authors["PhysicalSupport"] /. {Q -> p["Q"], mu -> p["Q"], s -> sval,
      s23 -> If[endpoint, 0, recoil], t -> If[endpoint, tend, tval], B -> upper}],
    {endpoint, {False, True}}];
  p
];
points = derivePoint /@ seeds;

evaluationRules[p_, endpoint_] := Join[alphaRule, {eq -> 1, nf -> p["Nf"],
  Q -> p["Q"], mu -> p["Q"], s -> p["s"], xh -> p["xHat"],
  t -> If[endpoint, p["tEndpoint"], p["t"]],
  s23 -> If[endpoint, 0, p["S23Sample"]], B -> p["S23UpperB"]}];
localValue[name_, part_, p_, endpoint_] := Module[{branch, expression},
  branch = p[If[endpoint, "EndpointBranch", "InteriorBranch"]];
  expression = If[part === "Born", independent["Hats"][name]["LODelta"],
    independent["Hats"][name]["NLO"][branch][part] /.
      independent["BranchCoordinates"][branch]];
  expression /. comparison["CommonRules"] /. evaluationRules[p, endpoint]
];
authorValue[name_, part_, p_, endpoint_] := Module[{expression},
  expression = If[part === "Born",
    authors["BornDeltaCoefficients"]["Fhat" <> StringDrop[name, 1]] /. authors["XhatRule"],
    comparison["CanonicalAuthorCoefficients"][name][part]];
  expression /. evaluationRules[p, endpoint]
];

transport[atPoint_, atEndpoint_, p_] := Module[{ordinary = p["Jacobian"]*atPoint["Regular"],
    plus = <||>, rules, k, part, index},
  Do[
    part = specification[[1]]; index = specification[[2]];
    k = Log[p["S23Sample"]/p["S23UpperB"]]^index/p["S23Sample"];
    rules = {coefficientValue -> p["Jacobian"]*atPoint[part],
      coefficientEndpoint -> p["JacobianEndpoint"]*atEndpoint[part], kernel -> k};
    AssociateTo[plus, part -> (plusWeight /. transportRules /. rules)];
    ordinary = ordinary+(ordinaryWeight /. transportRules /. rules),
    {specification, {{"L0", 0}, {"L1", 1}}}];
  Join[<|"Born" -> p["JacobianEndpoint"]*atEndpoint["Born"],
    "Delta" -> p["JacobianEndpoint"]*atEndpoint["Delta"]|>, plus,
    <|"Regular" -> ordinary|>]
];

precisions = {};
imaginaryResiduals = {};
number[expression_, label_] := Module[{value, symbols},
  gate[label <> " exact substitution", FreeQ[expression, _Real]];
  symbols = DeleteDuplicates@Cases[expression,
    symbol_Symbol /; Context[Unevaluated[symbol]] =!= "System`", {0, Infinity}, Heads -> True];
  gate[label <> " no remaining parameters", symbols === {}];
  value = bounded[N[expression, 60], label];
  gate[label <> " finite", NumberQ[value] && FreeQ[value, Indeterminate | _DirectedInfinity]];
  gate[label <> " real to evaluation precision",
    Abs[Im[value]] <= 10^-35*Max[Abs[Re[value]], 10^-30]];
  gate[label <> " retained precision", value === 0 || Precision[Re[value]] >= 30];
  If[value =!= 0, AppendTo[precisions, Precision[Re[value]]]];
  AppendTo[imaginaryResiduals, Abs[Im[value]]];
  Re[value]
];

coefficientRows = {};
interiorRows = {};
Do[
  Print["EVALUATE: ", p["ID"], " ", name];
  pointParts = {"L0", "L1", "Regular"};
  endpointParts = {"Born", "Delta", "L0", "L1"};
  lp = AssociationMap[localValue[name, #, p, False] &, pointParts];
  le = AssociationMap[localValue[name, #, p, True] &, endpointParts];
  ap = AssociationMap[authorValue[name, #, p, False] &, pointParts];
  ae = AssociationMap[authorValue[name, #, p, True] &, endpointParts];
  lc = transport[lp, le, p];
  ac = transport[ap, ae, p];
  Do[
    label = StringRiffle[{p["ID"], name, part}, "/"];
    lv = number[lc[part], label <> "/local"];
    av = number[ac[part], label <> "/authors"];
    AppendTo[coefficientRows, <|"Benchmark" -> p["ID"], "Function" -> name,
      "Part" -> part, "Local" -> lv, "BigTMDReconstructed" -> av,
      "LocalHighPrecision" -> ToString[lv, InputForm],
      "BigTMDHighPrecision" -> ToString[av, InputForm]|>],
    {part, Keys[lc]}];
  kernels = {1/p["S23Sample"], Log[p["S23Sample"]/p["S23UpperB"]]/p["S23Sample"]};
  lv = number[p["Jacobian"]*(lp["Regular"]+Lookup[lp, {"L0", "L1"}] . kernels),
    p["ID"] <> name <> "/local interior density"];
  av = number[p["Jacobian"]*(ap["Regular"]+Lookup[ap, {"L0", "L1"}] . kernels),
    p["ID"] <> name <> "/author interior density"];
  AppendTo[interiorRows, <|"Benchmark" -> p["ID"], "Function" -> name,
    "Local" -> lv, "BigTMDReconstructed" -> av,
    "LocalHighPrecision" -> ToString[lv, InputForm],
    "BigTMDHighPrecision" -> ToString[av, InputForm]|>];
  Clear[lp, le, ap, ae, lc, ac]; ClearSystemCache[],
  {p, points}, {name, names}];
allParts = {"Born", "Delta", "L0", "L1", "Regular"};
gate["complete coefficient coverage", Length[coefficientRows] === Length[points]*Length[names]*Length[allParts] &&
  DuplicateFreeQ[Lookup[#, {"Benchmark", "Function", "Part"}] & /@ coefficientRows]];
gate["complete interior coverage", Length[interiorRows] === Length[points]*Length[names] &&
  DuplicateFreeQ[Lookup[#, {"Benchmark", "Function"}] & /@ interiorRows]];
checkFrozen[];
gate["author input unchanged", FileHash[authorPath, "SHA256"] === comparison["AuthorResultHash"]];
gate["S13 map unchanged", sha[comparisonPath] ===
  "c3fd17bb39e701b781a806d6b5b65213732c1094757e6eae83762a11c45b2f5f"];

jsonValue[x_Association] := Map[jsonValue, x];
jsonValue[x_List] := jsonValue /@ x;
jsonValue[x_?NumericQ] := If[IntegerQ[x], x, N[x, 17]];
jsonValue[x_] := x;
atomicJSON[path_, data_] := Module[{temporary = path <> ".tmp", reread},
  gate["no stale temporary output", !FileExistsQ[temporary]];
  Export[temporary, jsonValue[data], "RawJSON"];
  reread = Import[temporary, "RawJSON"];
  gate["JSON reload coverage", Length[reread["CoefficientRows"]] === Length[coefficientRows] &&
    Length[reread["InteriorRows"]] === Length[interiorRows]];
  RenameFile[temporary, path]
];
atomicJSON[outputPath, <|"Status" -> "Complete", "Channel" -> "Hqg",
  "SourceSHA256" -> sha[$InputFileName], "IndependentInputs" -> manifest,
  "S13SHA256" -> sha[comparisonPath], "AuthorResultSHA256" -> sha[authorPath],
  "AuthorMetadataSHA256" -> sha[authorMetadataPath],
  "AuthorTree" -> authors["SourceTree"],
  "AuthorReconstructionAssumption" -> authors["ReconstructionAssumption"],
  "Conventions" -> <|"Couplings" -> "g_s=1, eq=1; alpha_s derived from g_s^2/(4 Pi)",
    "Color" -> ToString[comparison["CommonRules"], InputForm], "Scale" -> "mu=Q", "Nf" -> 4,
    "Basis" -> "delta(s23), L0=[1/s23]_+, L1=[Log[s23/B]/s23]_+, Regular on [0,B]",
    "HeldFixed" -> "xhat,Q,qT2,zH; t(s23) and J(s23) transported together",
    "Jacobians" -> "J(s23) for ordinary density; J(0) for endpoint coefficients",
    "Deferred" -> "PDFs/FFs, luminosity, zh/(xi*zeta), outer convolution",
    "Difference" -> "BigTMD minus local"|>,
  "DerivedMaps" -> <|"Kinematics" -> ToString[kinematicRules, InputForm],
    "Zeta" -> ToString[zetaExpression, InputForm], "B" -> ToString[upperExpression, InputForm],
    "Jacobian" -> ToString[jacobianExpression, InputForm],
    "PlusTransport" -> ToString[transportRules, InputForm],
    "ProjectorWeights" -> ToString[projectorWeights, InputForm],
    "RawInteriorWeights" -> ToString[rawInteriorWeights, InputForm],
    "AlphaS" -> ToString[alphaS /. alphaRule, InputForm]|>,
  "ExactSeeds" -> (Map[ToString[#, InputForm] &, #] & /@ seeds),
  "Benchmarks" -> points, "CoefficientRows" -> coefficientRows, "InteriorRows" -> interiorRows,
  "Evaluation" -> <|"RequestedDigits" -> 60, "MinimumRetainedPrecision" -> Min[precisions],
    "MaximumImaginaryResidual" -> Max[imaginaryResiduals], "KernelPeakBytes" -> MaxMemoryUsed[]|>|>];
Print["HQG_BIGTMD_S01_SUCCESS: ", outputPath];
Quit[0];

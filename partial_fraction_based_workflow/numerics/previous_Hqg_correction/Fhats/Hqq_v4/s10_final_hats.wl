If[!TrueQ[SyntaxQ[Import[$InputFileName, "Text"]]], Print["FAIL: source syntax"]; Quit[1]];
(* Finite independent Hqq hats, gated by complete distributional IR cancellation. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
atomicPut[value_, path_] := (Put[value, path <> ".tmp"]; RenameFile[path <> ".tmp", path, OverwriteTarget -> True]);
ClearAll[gate, bounded, reduce, zero, assemble, boundarySide, regularSeries];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
bookkeeping = Get[FileNameJoin[{root, "s03_result.wl"}]];
virtual = Get[FileNameJoin[{root, "s07_result.wl"}]];
subtraction = Get[FileNameJoin[{root, "s08_result.wl"}]];
real = Get[FileNameJoin[{root, "s09_result.wl"}]];
gate["all assembly inputs exist", And @@ (AssociationQ /@ {born, bookkeeping, virtual, subtraction, real})];
Scan[Function[entry, gate[entry[[1]] <> " source identity", entry[[2]]["SourceHash"] ===
  FileHash[FileNameJoin[{root, entry[[3]]}], "SHA256"]]],
  {{"S02", born, "s02_born_and_projectors.wl"}, {"S03", bookkeeping, "s03_contract_real.wl"},
   {"S07", virtual, "s07_renormalize_virtual.wl"},
   {"S08", subtraction, "s08_collinear_subtraction.wl"}, {"S09", real, "s09_real_phase_space.wl"}}];
hashes = Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
  {name, {"s02_result.wl", "s03_result.wl", "s07_result.wl", "s08_result.wl", "s09_result.wl"}}];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], hashes}, "SHA256"];
cache = FileNameJoin[{root, "s10_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
acceptedInputHashes = {inputHash};
reduce[value_, assumptions_] := Module[{expression, functions},
  expression = Refine[value /. a_ArcTanh :> ComplexExpand[a], assumptions];
  expression = PowerExpand[expression /. Log[arg_] :> Log[Factor[arg]], Assumptions -> assumptions];
  functions = DeleteDuplicates[Cases[expression, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  If[functions === {}, Factor[expression],
    Collect[Expand[expression, Alternatives @@ functions], functions, Factor]]];
zero[value_, assumptions_] := Module[{a = reduce[value, assumptions]},
  If[a === 0, True, FullSimplify[a, assumptions] === 0]];
tensorKeys = real["TensorKeys"];
gate["real distributions preserve S03 flavor and charge bookkeeping",
  real["Components"] === bookkeeping["Components"] &&
  real["OtherChargeMomentDefinitions"] === bookkeeping["OtherChargeMomentDefinitions"]];
flavorRanges = DeleteDuplicates[(#[[2]] &) /@ Values[bookkeeping["OtherChargeMomentDefinitions"]]];
gate["charge moments have one defining flavor range", Length[flavorRanges] === 1 && Length[First[flavorRanges]] === 3];
flavorRange = First[flavorRanges];
observedFlavor = bookkeeping["ObservedFlavor"];
flavorDomain = Reduce[Element[flavorRange[[3]], Integers] &&
  flavorRange[[2]] <= observedFlavor <= flavorRange[[3]], flavorRange[[3]], Integers];
gate["observed-flavor domain is evaluated and nonempty", FreeQ[flavorDomain, _Reduce] && flavorDomain =!= False];
Print["Inherited observed-flavor domain: ", InputForm[flavorDomain]];
flavorCountOriginal = bookkeeping["DistinctFlavorMultiplicity"];
flavorCountCanonical = If[Head[flavorCountOriginal] === Piecewise,
  flavorCountOriginal[[1, 1, 1]], flavorCountOriginal];
flavorCountCounterexample = Reduce[flavorDomain && flavorCountOriginal != flavorCountCanonical,
  flavorRange[[3]], Integers];
gate["canonical flavor count equals the defining sum on its complete integer domain",
  flavorCountCounterexample === False];
Print["Tool-proved canonical flavor count: ", InputForm[flavorCountCanonical]];
componentWeights = Map[FullSimplify[#["FlavorWeight"] /.
  flavorCountOriginal -> flavorCountCanonical, flavorDomain] &, real["Components"]];
componentOf[key_] := First[StringSplit[key, "__"]];
modeOf[key_] := Last[StringSplit[key, "__"]];
weightedReal[mode_, sign_] := Association[Join[
  Table[distribution -> Total[Map[
    componentWeights[componentOf[#]] real["Real"][#]["Branches"][sign][distribution] &,
    Select[tensorKeys, modeOf[#] === mode &]]],
    {distribution, {"Delta", "L0", "L1", "Regular"}}],
  {"Assumptions" -> real["Real"][First[tensorKeys]]["Branches"][sign]["Assumptions"]}]];
Do[
  branch = real["Real"][mode]["Branches"][sign];
  reconstructionAssumptions = branch["Assumptions"] &&
    (real["PhysicalRegion"] /. t -> sign omega - s);
  gate[mode <> " ordinary real-distribution reconstruction, branch " <> ToString[sign],
    bounded[zero[branch["Regular"] + branch["L0"]/s23 + branch["L1"] Log[s23/B]/s23 -
      (real["Real"][mode]["Ordinary"] /. t -> sign omega - s), reconstructionAssumptions],
      {mode, sign, "real-distribution reconstruction"}]],
  {mode, tensorKeys}, {sign, {1, -1}}];
poles = <||>;

assemble[mode_, sign_, distribution_] := Module[{file, saved, realPart, assumptions,
  virtualPart, subtractionPart, inputParts, combined, powers, residues, result},
  file = FileNameJoin[{cache, StringRiffle[{mode, ToString[sign], distribution}, "_"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedInputHashes, saved["InputHash"]],
    AssociateTo[poles, StringRiffle[{mode, ToString[sign], distribution}, "_"] -> saved["PoleResidues"]];
    Return[saved["Value"]]]];
  ClearSystemCache[];
  Print["Assemble ", mode, " ", sign, " ", distribution, "; memory = ", MemoryInUse[]];
  realPart = weightedReal[mode, sign];
  assumptions = realPart["Assumptions"] && flavorDomain;
  If[distribution === "Regular", assumptions = assumptions &&
    (real["PhysicalRegion"] /. t -> sign omega - s)];
  virtualPart = If[distribution === "Delta", 2 Pi virtual["RenormalizedVirtual"][mode], 0] /.
    virtual["Regulator"] -> eps;
  subtractionPart = If[distribution === "L1", 0, subtraction["Counterterms"][mode][distribution]] /.
    subtraction["Regulator"] -> eps;
  inputParts = {realPart[distribution] /. real["Regulator"] -> eps,
    virtualPart /. t -> sign omega - s, subtractionPart /. t -> sign omega - s};
  combined = Expand[Total[inputParts], eps];
  powers = Range[Min[Append[Cases[(Expand[#, eps] &) /@ inputParts,
    (Power[eps, n_Integer] /; n < 0) :> n, Infinity], 0]], -1];
  gate["combined input is a Laurent polynomial in the common regulator",
    PolynomialQ[Expand[eps^(-Min[Append[powers, 0]]) combined, eps], eps]];
  residues = Association@Table[power -> bounded[
    reduce[Coefficient[combined, eps, power], assumptions], {mode, sign, distribution, power}],
    {power, powers}];
  AssociateTo[poles, StringRiffle[{mode, ToString[sign], distribution}, "_"] -> residues];
  atomicPut[<|"PoleResidues" -> poles, "Accepted" -> False, "InputHash" -> inputHash|>,
    FileNameJoin[{root, "s10_poles.wl"}]];
  Do[gate[StringRiffle[{mode, ToString[sign], distribution, "IR", ToString[power]}, " "],
    bounded[zero[residues[power], assumptions], {"IR gate", mode, sign, distribution, power}]];
    AssociateTo[residues, power -> 0],
    {power, powers}];
  AssociateTo[poles, StringRiffle[{mode, ToString[sign], distribution}, "_"] -> residues];
  result = Coefficient[combined, eps, 0];
  gate["finite contraction has no regulator or unresolved integral", FreeQ[result,
    eps | _Integrate | _SeriesData | _SeriesCoefficient | _Derivative | _Real]];
  atomicPut[<|"InputHash" -> inputHash, "Value" -> result, "PoleResidues" -> residues|>, file]; result];

finite = Association@Table[mode -> Association@Table[sign -> Association@Table[
  distribution -> assemble[mode, sign, distribution],
  {distribution, {"L1", "L0", "Regular", "Delta"}}], {sign, {1, -1}}], {mode, {"Pg", "Ppp"}}];
atomicPut[<|"PoleResidues" -> poles, "Accepted" -> True, "InputHash" -> inputHash|>,
  FileNameJoin[{root, "s10_poles.wl"}]];

(* Projectors are applied only to accepted finite contractions. *)
projectors = born["ProjectorsEpsilon"] /. eps -> 0 /. born["BornKinematics"];
couplingSquare = Factor[gs^2 /. First[Solve[gs^2 == 4 Pi alphaS, gs]]];
hardNormalization = (2 Pi)^(-4);
leading = Association@Table[With[{name = item[[1]], symbol = item[[2]]},
  name -> Factor[eq^2 couplingSquare 2 Pi hardNormalization *
  ((symbol /. projectors) /. {hg -> born["BornPg"], hpp -> born["BornPpp"]} /. D -> 4)]],
  {item, {{"F1", f1}, {"F2", f2}}}];
hats = Association@Table[With[{name = item[[1]], symbol = item[[2]]}, name -> <|"LODelta" -> leading[name],
  "NLO" -> Association@Table[sign -> Association@Table[distribution ->
    (eq^2 couplingSquare^2 hardNormalization *
      ((symbol /. projectors) /. {hg -> finite["Pg"][sign][distribution],
        hpp -> finite["Ppp"][sign][distribution]})),
    {distribution, {"Delta", "L0", "L1", "Regular"}}], {sign, {1, -1}}]|>],
  {item, {{"F1", f1}, {"F2", f2}}}];
regularSeries[input_, assumptions_, name_, sign_] := Module[
  {expanded, terms, values, factors, constant, dependent, file, expressionHash, saved, value},
  expanded = bounded[Expand[input, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im],
    {name, sign, "regular boundary partition"}];
  terms = If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  Print["Regular boundary ", name, " ", sign, ": ", Length[terms], " symbolic terms"];
  gate["regular boundary partition reproduces its input",
    bounded[Expand[Total[terms] - input, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im] === 0,
      "boundary partition reconstruction"]];
  values = Table[
    factors = If[Head[terms[[k]]] === Times, List @@ terms[[k]], {terms[[k]]}];
    constant = Times @@ Select[factors, FreeQ[#, omega] &];
    dependent = Times @@ Select[factors, !FreeQ[#, omega] &];
    gate["boundary term factorization reconstructs its input", constant dependent === terms[[k]]];
    expressionHash = Hash[{dependent, assumptions}, "SHA256"];
    file = FileNameJoin[{cache, "SeriesShared_" <> IntegerString[expressionHash, 16] <> ".wl"}];
    saved = If[FileExistsQ[file], Get[file], <||>];
    value = If[MemberQ[acceptedInputHashes, saved["InputHash"]] &&
      saved["ExpressionHash"] === expressionHash, saved["Value"],
      Print["Boundary term ", name, " ", sign, " ", k, "/", Length[terms]];
      value = bounded[Normal[Series[dependent, {omega, 0, 0}, Assumptions -> assumptions]],
        {name, sign, k, "regular boundary term series"}];
      gate["boundary term series is evaluated symbolically", FreeQ[value,
        _Series | _SeriesData | _SeriesCoefficient | _Derivative | _Limit | _Integrate | _Sum | _Real]];
      atomicPut[<|"InputHash" -> inputHash, "ExpressionHash" -> expressionHash, "Value" -> value|>, file];
      value];
    If[Mod[k, 5] === 0, ClearSystemCache[]];
    If[Mod[k, 25] === 0, Print["Completed boundary terms ", name, " ", sign, " ", k, "/", Length[terms]]];
    constant value,
    {k, Length[terms]}];
  Total[values]];

boundarySide[name_, distribution_, sign_, assumptions_] := Module[
  {file, saved, expression, expressionHash, interiorAssumptions, value,
    seriesTerms, independentSeries, dependentSeries},
  file = FileNameJoin[{cache, StringRiffle[{"Boundary", name, distribution, ToString[sign]}, "_"] <> ".wl"}];
  expression = hats[name]["NLO"][sign][distribution];
  expressionHash = Hash[{expression, assumptions}, "SHA256"];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]] && saved["ExpressionHash"] === expressionHash,
      Return[saved["Value"]]]];
  ClearSystemCache[];
  interiorAssumptions = assumptions && real["Real"][First[tensorKeys]]["Branches"][sign]["Assumptions"];
  If[distribution === "Regular", interiorAssumptions = interiorAssumptions &&
    (real["PhysicalRegion"] /. t -> sign omega - s)];
  If[distribution =!= "Regular",
    Print["Simplify boundary ", name, " ", distribution, " ", sign];
    expression = bounded[reduce[expression, interiorAssumptions],
      {name, distribution, sign, "boundary simplification"}]];
  Print["Expand boundary ", name, " ", distribution, " ", sign];
  value = If[distribution === "Regular",
    regularSeries[expression, interiorAssumptions, name, sign],
    bounded[Normal[Series[expression, {omega, 0, 0}, Assumptions -> interiorAssumptions]],
      {name, distribution, sign, "boundary series"}]];
  Print["Simplify boundary series ", name, " ", distribution, " ", sign];
  If[distribution === "Regular",
    If[!FreeQ[value, omega],
      seriesTerms = bounded[Expand[value, omega], "boundary Laurent partition"];
      seriesTerms = If[Head[seriesTerms] === Plus, List @@ seriesTerms, {seriesTerms}];
      independentSeries = Total[Select[seriesTerms, FreeQ[#, omega] &]];
      dependentSeries = Total[Select[seriesTerms, !FreeQ[#, omega] &]];
      gate["boundary Laurent partition reconstructs its input",
        bounded[Expand[independentSeries + dependentSeries - value, omega] === 0,
          "boundary Laurent partition reconstruction"]];
      Print["Reduce remaining coordinate dependence ", name, " ", sign];
      value = independentSeries + bounded[reduce[dependentSeries, interiorAssumptions],
        {name, sign, "boundary singular-part reduction"}]],
    value = bounded[reduce[value, interiorAssumptions],
      {name, distribution, sign, "boundary series reduction"}]];
  gate["one-sided boundary is evaluated and finite",
    FreeQ[value, omega | _Limit | _Series | _SeriesData | _SeriesCoefficient |
      _Derivative | _ConditionalExpression | Indeterminate | _DirectedInfinity]];
  atomicPut[<|"InputHash" -> inputHash, "ExpressionHash" -> expressionHash,
    "Method" -> "One-sided symbolic series with the full singular part gated away", "Value" -> value|>, file];
  Print["Saved boundary ", name, " ", distribution, " ", sign]; value];
boundary = Association@Table[name -> Association@Table[distribution -> Module[{right, left, assumptions},
  Print["Coordinate boundary ", name, " ", distribution];
  assumptions = Q2 > 0 && s > 0 && mu > 0 && SUNN > 1 && B > 0 && flavorDomain &&
    (If[distribution === "Regular", real["PhysicalRegion"] /. t -> -s, True]);
  right = boundarySide[name, distribution, 1, assumptions];
  left = boundarySide[name, distribution, -1, assumptions];
  gate["soft-coordinate boundary limits agree", bounded[zero[right - left, assumptions], "boundary gate"]];
  gate["boundary limit is evaluated and finite", FreeQ[right, _Limit | Indeterminate | _DirectedInfinity]];
  right], {distribution, {"Delta", "L0", "L1", "Regular"}}], {name, {"F1", "F2"}}];
distributionBasis = <|"Delta" -> DiracDelta[s23],
  "L0" -> PlusDistribution[1/s23, {s23, 0, B}],
  "L1" -> PlusDistribution[Log[s23/B]/s23, {s23, 0, B}], "Regular" -> 1|>;
assembleDistributions[coefficients_Association] := Total[
  KeyValueMap[(#2 distributionBasis[#1]) &, coefficients]];
structureFunctions = Association@Table[name -> (leading[name] DiracDelta[s23] + Piecewise[
  Table[{assembleDistributions[hats[name]["NLO"][sign]] /. omega -> sign (s + t),
    sign (s + t) > 0}, {sign, {1, -1}}], assembleDistributions[boundary[name]]]), {name, {"F1", "F2"}}];
KeyValueMap[Function[{name, expression}, atomicPut[expression,
  FileNameJoin[{root, "s10_" <> name <> "_hat.wl"}]]], structureFunctions];
atomicPut[<|"StructureFunctions" -> structureFunctions, "Hats" -> hats,
  "BoundaryAtTEqualsMinusS" -> boundary, "FiniteContractions" -> finite,
  "BranchCoordinates" -> <|1 -> (omega -> s + t), -1 -> (omega -> -s - t)|>,
  "BranchDomains" -> <|1 -> s + t > 0, -1 -> s + t < 0|>,
  "PlusDefinition" -> real["PlusDefinition"], "PhysicalRegion" -> real["PhysicalRegion"],
  "RegulatorCancellationPassed" -> True, "AuthorsCoefficientsUsed" -> False,
  "Components" -> real["Components"], "OtherChargeMomentDefinitions" -> real["OtherChargeMomentDefinitions"],
  "FlavorDomain" -> flavorDomain, "FlavorRange" -> flavorRange, "ObservedFlavor" -> observedFlavor,
  "ComponentWeightsUsed" -> componentWeights,
  "FlavorCountReduction" -> <|"Original" -> flavorCountOriginal, "Canonical" -> flavorCountCanonical,
    "Counterexample" -> flavorCountCounterexample|>,
  "InputHashes" -> hashes, "InputHash" -> inputHash,
  "AcceptedCacheInputHashes" -> acceptedInputHashes, "SourceHash" -> FileHash[$InputFileName, "SHA256"]|>,
  FileNameJoin[{root, "s10_result.wl"}]];
Print["S10_SUCCESS: finite independent hats; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

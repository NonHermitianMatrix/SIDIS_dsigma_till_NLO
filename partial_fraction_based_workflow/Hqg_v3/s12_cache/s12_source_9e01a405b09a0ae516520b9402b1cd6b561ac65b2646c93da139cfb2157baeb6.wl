(* Finite independent Hqg hats, gated by complete distributional IR cancellation. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, bounded, reduce, zero, assemble, boundarySide];
gate[name_, test_] := If[TrueQ[test], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
  Print["Time limit: ", label]; Quit[2]], 2*1024^3,
  Print["Memory limit: ", label]; Quit[3]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
virtual = Get[FileNameJoin[{root, "s09_result.wl"}]];
subtraction = Get[FileNameJoin[{root, "s10_result.wl"}]];
real = Get[FileNameJoin[{root, "s11_result.wl"}]];
gate["all assembly inputs exist", And @@ (AssociationQ /@ {born, virtual, subtraction, real})];
hashes = Association@Table[name -> FileHash[FileNameJoin[{root, name}], "SHA256"],
  {name, {"s02_result.wl", "s09_result.wl", "s10_result.wl", "s11_result.wl"}}];
inputHash = Hash[{FileHash[$InputFileName, "SHA256"], hashes}, "SHA256"];
cache = FileNameJoin[{root, "s12_cache"}];
If[!DirectoryQ[cache], CreateDirectory[cache]];
priorSources = FileNames["s12_source_*.wl", cache];
acceptedInputHashes = DeleteDuplicates[Prepend[
  (Hash[{FileHash[#, "SHA256"], hashes}, "SHA256"] &) /@ priorSources, inputHash]];
reduce[value_, assumptions_] := Module[{expression, functions},
  expression = Refine[value /. a_ArcTanh :> ComplexExpand[a], assumptions];
  expression = PowerExpand[expression /. Log[arg_] :> Log[Factor[arg]], Assumptions -> assumptions];
  functions = DeleteDuplicates[Cases[expression, _Log | _PolyLog | _ArcTan | _ArcTanh | _Re | _Im, Infinity]];
  Collect[Expand[expression], functions, Factor]];
zero[value_, assumptions_] := Module[{a = reduce[value, assumptions]},
  If[a === 0, True, FullSimplify[a, assumptions] === 0]];
Do[
  branch = real["Real"][mode]["Branches"][sign];
  reconstructionAssumptions = branch["Assumptions"] &&
    (real["PhysicalRegion"] /. t -> sign omega - s);
  gate[mode <> " ordinary real-distribution reconstruction, branch " <> ToString[sign],
    bounded[zero[branch["Regular"] + branch["L0"]/s23 + branch["L1"] Log[s23/B]/s23 -
      (real["Real"][mode]["Ordinary"] /. t -> sign omega - s), reconstructionAssumptions],
      {mode, sign, "real-distribution reconstruction"}]],
  {mode, {"Pg", "Ppp"}}, {sign, {1, -1}}];
poles = <||>;

assemble[mode_, sign_, distribution_] := Module[{file, saved, realPart, assumptions,
  virtualPart, subtractionPart, inputParts, combined, powers, residues, result},
  file = FileNameJoin[{cache, StringRiffle[{mode, ToString[sign], distribution}, "_"] <> ".wl"}];
  If[FileExistsQ[file], saved = Get[file]; If[MemberQ[acceptedInputHashes, saved["InputHash"]],
    AssociateTo[poles, StringRiffle[{mode, ToString[sign], distribution}, "_"] -> saved["PoleResidues"]];
    Return[saved["Value"]]]];
  ClearSystemCache[];
  Print["Assemble ", mode, " ", sign, " ", distribution, "; memory = ", MemoryInUse[]];
  realPart = real["Real"][mode]["Branches"][sign];
  assumptions = realPart["Assumptions"] && Element[Nf, Integers] && Nf >= 0;
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
  Put[<|"PoleResidues" -> poles, "Accepted" -> False, "InputHash" -> inputHash|>,
    FileNameJoin[{root, "s12_poles.wl"}]];
  Do[gate[StringRiffle[{mode, ToString[sign], distribution, "IR", ToString[power]}, " "],
    bounded[zero[residues[power], assumptions], {"IR gate", mode, sign, distribution, power}]];
    AssociateTo[residues, power -> 0],
    {power, powers}];
  AssociateTo[poles, StringRiffle[{mode, ToString[sign], distribution}, "_"] -> residues];
  result = Coefficient[combined, eps, 0];
  gate["finite contraction has no regulator or unresolved integral", FreeQ[result,
    eps | _Integrate | _SeriesData | _SeriesCoefficient | _Derivative | _Real]];
  Put[<|"InputHash" -> inputHash, "Value" -> result, "PoleResidues" -> residues|>, file]; result];

finite = Association@Table[mode -> Association@Table[sign -> Association@Table[
  distribution -> assemble[mode, sign, distribution],
  {distribution, {"L1", "L0", "Regular", "Delta"}}], {sign, {1, -1}}], {mode, {"Pg", "Ppp"}}];
Put[<|"PoleResidues" -> poles, "Accepted" -> True, "InputHash" -> inputHash|>,
  FileNameJoin[{root, "s12_poles.wl"}]];

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
boundarySide[name_, distribution_, sign_, assumptions_] := Module[
  {file, saved, expression, expressionHash, value},
  file = FileNameJoin[{cache, StringRiffle[{"Boundary", name, distribution, ToString[sign]}, "_"] <> ".wl"}];
  expression = hats[name]["NLO"][sign][distribution];
  expressionHash = Hash[{expression, assumptions}, "SHA256"];
  If[FileExistsQ[file], saved = Get[file];
    If[MemberQ[acceptedInputHashes, saved["InputHash"]] && saved["ExpressionHash"] === expressionHash,
      Return[saved["Value"]]]];
  ClearSystemCache[];
  Print["Simplify boundary ", name, " ", distribution, " ", sign];
  expression = bounded[reduce[expression, assumptions && omega > 0],
    {name, distribution, sign, "boundary simplification"}];
  Print["Evaluate boundary ", name, " ", distribution, " ", sign];
  value = bounded[Limit[expression, omega -> 0, Direction -> "FromAbove", Assumptions -> assumptions],
    {name, distribution, sign, "boundary limit"}];
  gate["one-sided boundary is evaluated and finite",
    FreeQ[value, omega | _Limit | Indeterminate | _DirectedInfinity]];
  Put[<|"InputHash" -> inputHash, "ExpressionHash" -> expressionHash, "Value" -> value|>, file];
  Print["Saved boundary ", name, " ", distribution, " ", sign]; value];
boundary = Association@Table[name -> Association@Table[distribution -> Module[{right, left, assumptions},
  Print["Coordinate boundary ", name, " ", distribution];
  assumptions = Q2 > 0 && s > 0 && mu > 0 && SUNN > 1 && B > 0 &&
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
Put[<|"StructureFunctions" -> structureFunctions, "Hats" -> hats,
  "BoundaryAtTEqualsMinusS" -> boundary, "FiniteContractions" -> finite,
  "BranchCoordinates" -> <|1 -> (omega -> s + t), -1 -> (omega -> -s - t)|>,
  "BranchDomains" -> <|1 -> s + t > 0, -1 -> s + t < 0|>,
  "PlusDefinition" -> real["PlusDefinition"], "PhysicalRegion" -> real["PhysicalRegion"],
  "RegulatorCancellationPassed" -> True, "AuthorsCoefficientsUsed" -> False,
  "InputHashes" -> hashes, "InputHash" -> inputHash,
  "AcceptedCacheInputHashes" -> acceptedInputHashes, "PriorSources" -> priorSources|>,
  FileNameJoin[{root, "s12_result.wl"}]];
Print["Wrote s12_result.wl: finite independent hats; peak memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

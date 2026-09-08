(* Symbolic Fhat_1 and Fhat_2 from the paper authors' finite H_qg. *)
$HistoryLength = 0;
root = DirectoryName[$InputFileName];
ClearAll[gate, canonical, endpoint, compact, project];
gate[name_, value_] := If[TrueQ[value], Print["PASS: ", name], Print["FAIL: ", name]; Quit[1]];
gate["required earlier stages exist", And @@ (FileExistsQ[FileNameJoin[{root, #}]] & /@
 {"s01_result.wl", "s02_result.wl"})];
published = Get[FileNameJoin[{root, "s01_result.wl"}]];
born = Get[FileNameJoin[{root, "s02_result.wl"}]];
gate["Born normalization accepted", born["BornNormalizationRatios"] === {1, 1}];
gate["inputs have no floating-point numbers", FreeQ[{published, born}, _Real]];

canonical[expr_] := expr /. {
  Power[a_, b_Rational] :> Power[Factor[a], b],
  Log[a_] :> Log[Factor[a]]
};
SetAttributes[bounded, HoldFirst];
bounded[work_, label_] := MemoryConstrained[TimeConstrained[work, 900,
 Print["Time limit: ", label]; Quit[2]], 2*1024^3,
 Print["Memory limit: ", label]; Quit[3]];
endpoint[expr_] := Module[{branches, branchAssumptions, terms, values, direct, value},
 branches = Table[
  branchAssumptions = (endpointAssumptions /. t -> sign omega-s) && omega > 0;
  terms = If[Head[expr] === Plus, List @@ expr, {expr}] /. t -> sign omega-s;
  values = Table[
   direct = Quiet[canonical[Refine[canonical[terms[[j]] /. s23 -> 0], branchAssumptions]],
     {Power::infy, Infinity::indet}];
   value = If[FreeQ[direct, Indeterminate | _DirectedInfinity], direct,
    Print["Physical endpoint limit: branch ", sign, ", term ", j, "/", Length[terms]];
    bounded[canonical[Limit[Cancel[canonical[terms[[j]]]], s23 -> 0, Direction -> "FromAbove",
      Assumptions -> branchAssumptions]], {"physical endpoint", sign, j}]];
   gate["physical endpoint term is finite and evaluated", FreeQ[value,
     $Failed | _Limit | _ConditionalExpression | Indeterminate | _DirectedInfinity | _Real]];
   If[Mod[j, 10] === 0, ClearSystemCache[]];
   value, {j, Length[terms]}];
  canonical[Total[values]], {sign, {1, -1}}];
 Piecewise[{{branches[[1]] /. omega -> s+t, s+t > 0},
   {branches[[2]] /. omega -> -s-t, s+t < 0}}]];
compact[expr_] := Collect[expr, {_Log, _PolyLog, EulerGamma}, Factor];
endpointAssumptions = Q > 0 && s > 0 && t < 0 && Q^2 + s + t > 0 &&
                      mu > 0 && B > 0 && s + t != 0;
tensorRows = <||>;
cutoffChecks = <||>;
Do[
 Print["Assembling ", name, "."];
 data = published[name];
 cDelta = endpoint[data["delta"]];
 cZero = endpoint[data["plus1B"]];
 cLog = endpoint[data["plus2B"]];
 gate[name <> " exact endpoint exists", FreeQ[{cDelta, cZero, cLog},
      Indeterminate | ComplexInfinity | DirectedInfinity[_]]];
 Print[name, ": checking endpoint/plus cutoff dependence."];
 cutoffResidual = bounded[FullSimplify[B D[cDelta, B] - cZero - Log[B] cLog,
    endpointAssumptions], {name, "cutoff relation"}];
 If[cutoffResidual =!= 0,
  cutoffResidual = TimeConstrained[FullSimplify[cutoffResidual,
    Assumptions -> endpointAssumptions], 60, cutoffResidual]];
 Put[cutoffResidual, FileNameJoin[{root, "s03_cutoff_" <> name <> ".wl"}]];
 gate[name <> " endpoint and plus cutoff dependence agrees", cutoffResidual === 0];
 AssociateTo[cutoffChecks, name -> cutoffResidual];
 Print[name, ": collecting endpoint coefficient."];
 cDelta = cDelta;
 (* The public plus2B multiplies Log[s23]/s23. Express it instead with
    Log[s23/Q^2]/s23, keeping the compensating Log[Q^2] in the plus0 row. *)
 rows = <|"delta" -> cDelta,
   "plus0" -> canonical[data["plus1B"] + Log[Q^2] data["plus2B"]],
   "plus1" -> canonical[data["plus2B"]],
   "regular" -> canonical[data["regular"]]|>;
 AssociateTo[tensorRows, name -> rows];
 Put[rows, FileNameJoin[{root, "s03_tensor_" <> name <> ".wl"}]];
 Print[name, " checkpoint saved; kernel memory = ", MemoryInUse[], " bytes."],
 {name, {"Pg", "Ppp"}}];

(* Kinematics in Eq. (25)-(27), with the measured transverse momentum held fixed. *)
kinematicRules = First[Solve[{
 s == Q^2 (1/xh - 1), t == -Q^2 (1 - zh) - zh qT2,
 u == -Q^2 zh/xh, s + t + u == -Q^2 + s23
}, {s, t, u, zh}]];
gate["kinematic equations close", Factor[(s + t + u + Q^2 - s23) /. kinematicRules] === 0];
physicalSupport = Q > 0 && mu > 0 && s > s23 >= 0 && t < 0 &&
                  Q^2 + s - s23 + t > 0 && Q^2 s23 + s t < 0 && B > 0 && s+t != 0;
projectors = (born["ProjectorsEpsilon"] /. {eps -> 0, Q2 -> Q^2});
project[index_, g_, pp_] := ({f1, f2}[[index]] /. projectors /. {hg -> g, hpp -> pp});
couplingRule = First[Solve[alphaS == gsSquared/(4 Pi), gsSquared]];
bornNormalization = eq^2 (gsSquared /. couplingRule) (2 Pi)/(2 Pi)^4;
nloNormalization = eq^2 (gsSquared /. couplingRule)^2;
bornContractions = {born["BornPg"], born["BornPpp"]} /. {D -> 4, SUNN -> 3, Q2 -> Q^2};
bornHats = Table[Factor[bornNormalization project[index, Sequence @@ bornContractions]], {index, 2}];
nloHats = Table[AssociationMap[
  nloNormalization project[index, tensorRows["Pg"][#], tensorRows["Ppp"][#]] &,
  {"delta", "plus0", "plus1", "regular"}], {index, 2}];

(* PlusDistribution[n,r,B,M2] acts on a test function f as
   Integrate[Log[r/M2]^n (f[r]-f[0])/r,{r,0,B}].
   For a multiplying coefficient C[r], replace f[r] by C[r] f[r]. *)
distribution[rows_] := rows["delta"] DiracDelta[s23] +
 rows["plus0"] PlusDistribution[0, s23, B, Q^2] +
 rows["plus1"] PlusDistribution[1, s23, B, Q^2] + rows["regular"];
finalHats = Table[bornHats[[index]] DiracDelta[s23] + distribution[nloHats[[index]]], {index, 2}];
gate["final expressions contain no floats or unevaluated integrals", FreeQ[finalHats, _Real | _Integrate | _NIntegrate | _Limit]];
gate["final expressions have no epsilon poles", FreeQ[finalHats, eps | epsilon]];

result = <|
 "Channel" -> "incoming quark, observed gluon (Hqg)",
 "Order" -> "alphaS + alphaS^2; SU(3)",
 "Source" -> "JeffersonLab/BigTMD published finite coefficients, channel 3A",
 "SourceTree" -> "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c",
 "ReconstructionAssumption" -> "Long decimal coefficients reconstruct uniquely with rational denominator <= 10^6.",
 "ScaleConvention" -> "mu is the common scale in the published coefficient functions.",
 "PlusDefinition" -> HoldForm[PlusDistribution[n, r, cutoff, scaleSquared][f] ==
   Integrate[Log[r/scaleSquared]^n (f[r] - f[0])/r, {r, 0, cutoff}]],
 "PhysicalSupport" -> physicalSupport,
 "XhatRule" -> (xh -> Q^2/(Q^2 + s)),
 "KinematicRules" -> kinematicRules,
 "EndpointInstruction" -> "Endpoints are refined on each physical s+t sign branch before accepting substitution; singular terms use the defining one-sided finite-recoil limit. The author representation excludes s+t=0. At fixed xh,Q,qT2, apply KinematicRules before the endpoint of coefficient times test function.",
 "EndpointSourceHash" -> FileHash[$InputFileName, "SHA256"],
 "Fhat1" -> finalHats[[1]], "Fhat2" -> finalHats[[2]],
 "BornDeltaCoefficients" -> AssociationThread[{"Fhat1", "Fhat2"}, bornHats],
 "NLOCoefficients" -> AssociationThread[{"Fhat1", "Fhat2"}, nloHats],
 "Checks" -> <|"CutoffResiduals" -> cutoffChecks, "ExactSymbolic" -> True,
   "BornWardAndNormalization" -> True, "ProjectorsEqualPaper" -> True,
   "IndependentNLOIntegrationPerformed" -> False|>|>;
Put[result, FileNameJoin[{root, "s03_result.wl"}]];
Print["Born Fhat1 delta coefficient = ", InputForm[bornHats[[1]]]];
Print["Born Fhat2 delta coefficient = ", InputForm[bornHats[[2]]]];
Print["Wrote s03_result.wl. Leaf counts = ", LeafCount /@ finalHats];
Print["Peak kernel memory = ", MaxMemoryUsed[], " bytes."];
Quit[];

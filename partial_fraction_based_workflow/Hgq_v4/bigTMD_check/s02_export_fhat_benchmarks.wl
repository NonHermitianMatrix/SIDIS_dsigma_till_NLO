(* Numerical check of the frozen Hgq hats against the pinned authors input. *)
$HistoryLength=0;
root=DirectoryName[$InputFileName];channel=DirectoryName[root];
gate[label_,test_]:=If[TrueQ[test],Print["PASS: ",label],Print["FAIL: ",label];Quit[1]];
SetAttributes[bounded,HoldFirst];
bounded[work_,label_]:=MemoryConstrained[TimeConstrained[work,180,
 Print["TIME LIMIT: ",label];Quit[2]],1024^3,Print["MEMORY LIMIT: ",label];Quit[3]];
sha[path_]:=IntegerString[FileHash[path,"SHA256"],16,64];
manifest=Import[FileNameJoin[{root,"frozen_inputs.json"}],"RawJSON"];
checkFrozen[]:=KeyValueMap[Function[{name,record},
 gate["frozen "<>name,sha[FileNameJoin[{channel,name}]]===record["sha256"]]],manifest["files"]];
checkFrozen[];
metadata=Import[FileNameJoin[{root,"s01_result.json"}],"RawJSON"];
gate["Hgq reference and importer",metadata["Channel"]==="Hgq"&&metadata["BigTMDChannel"]==="1A"&&
 metadata["SourceSHA256"]===sha[FileNameJoin[{root,"s01_prepare_reference.py"}]]];
authorPath=FileNameJoin[{root,"s01_result.wl"}];authorHash=sha[authorPath];
published=Get[authorPath];
independent=KeyTake[Get[FileNameJoin[{channel,"s10_result.wl"}]],
 {"Hats","BranchCoordinates","BoundaryAtTEqualsMinusS","PhysicalRegion",
 "RegulatorCancellationPassed","AuthorsCoefficientsUsed"}];
born=Get[FileNameJoin[{channel,"s02_result.wl"}]];
gate["independent hats accepted without authors coefficients",
 independent["RegulatorCancellationPassed"]===True&&independent["AuthorsCoefficientsUsed"]===False];
names=Keys[independent["Hats"]];gate["both structure functions",names==={"F1","F2"}];
gate["reference contains no floats",FreeQ[published,_Real]];
outputPath=FileNameJoin[{root,"s02_result.json"}];
gate["new numerical result",!FileExistsQ[outputPath]];
momenta = {p, q, k1};
basis = AssociationThread[momenta, IdentityMatrix[Length[momenta]]];
gram = {{pp, pq, pk}, {pq, qq, qk}, {pk, qk, kk}};
dot[a_, b_] := Expand[a . gram . b];
norm[a_] := dot[a, a];
invariantSolutions = Solve[{
  norm[basis[p]] == 0, norm[basis[q]] == -Q^2, norm[basis[k1]] == 0,
  norm[basis[p] + basis[q]] == s, norm[basis[q] - basis[k1]] == t,
  norm[basis[p] + basis[q] - basis[k1]] == s23}, DeleteDuplicates[Flatten[gram]]];
gate["invariant scalar products have a unique solution", Length[invariantSolutions] === 1];
invariantRules = First[invariantSolutions];
xhatExpression = Factor[Q^2/(2 dot[basis[p], basis[q]]) /. invariantRules];
zhatExpression = Factor[dot[basis[p], basis[k1]]/dot[basis[p], basis[q]] /. invariantRules];
kTransverse = basis[k1] - ap basis[p] - aq basis[q];
transverseSolutions = Solve[{
  dot[kTransverse, basis[p]] == 0, dot[kTransverse, basis[q]] == 0}, {ap, aq}];
gate["transverse projection has a unique solution", Length[transverseSolutions] === 1];
kTransverse = kTransverse /. First[transverseSolutions];
gate["transverse projection is orthogonal", And @@ (Factor[# /. invariantRules] === 0 & /@
  {dot[kTransverse, basis[p]], dot[kTransverse, basis[q]]})];
qTExpression = Factor[-norm[-kTransverse/zhatExpression] /. invariantRules];
uExpression = Factor[norm[basis[p] - basis[k1]] /. invariantRules];
kinematicSolutions = Solve[{xh == xhatExpression, qT2 == qTExpression,
  zh == zhatExpression, u == uExpression}, {s, t, zh, u}];
gate["physical-variable map has a unique algebraic solution", Length[kinematicSolutions] === 1];
kinematicRules = First[kinematicSolutions];
squareScaleRule = First[Solve[Q2 == Q^2, Q2]];
gate["derived kinematics reduce to the independent Born definitions", And @@ Table[
  Factor[(symbol /. {xh -> xhatExpression, zh -> zhatExpression, qT2 -> qTExpression} /. s23 -> 0) -
    (symbol /. born["BornKinematics"] /. squareScaleRule)] === 0, {symbol, {xh, zh, qT2}}]];

commonRules=Join[squareScaleRule,{SUNN->3,Nf->nf}];
seeds = {
  <|"ID" -> "interior_1", "xB" -> 23/100, "xi" -> 61/100,
    "zH" -> 37/100, "Q2" -> 17, "qT2" -> 31/10, "S23Fraction" -> 2/5, "Nf" -> 4|>,
  <|"ID" -> "interior_2", "xB" -> 19/100, "xi" -> 73/100,
    "zH" -> 41/100, "Q2" -> 23, "qT2" -> 27/10, "S23Fraction" -> 7/20, "Nf" -> 4|>,
  <|"ID" -> "interior_3", "xB" -> 31/100, "xi" -> 79/100,
    "zH" -> 29/100, "Q2" -> 29, "qT2" -> 19/10, "S23Fraction" -> 11/20, "Nf" -> 4|>
};
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
gate["saved Hgq projector reconstruction",
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
  gate[seed["ID"] <> " physical recoil interval", FullSimplify[
    independent["PhysicalRegion"] /. {Q2->seed["Q2"],s->sval,t->tcurve,mu->p["Q"],SUNN->3,B->upper},
    0<s23<upper]===True];
  p
];
points = derivePoint /@ seeds;


evaluationRules[p_,endpoint_]:=Join[alphaRule,{eq->1,nf->p["Nf"],
 Q->p["Q"],mu->p["Q"],s->p["s"],xh->p["xHat"],
 t->If[endpoint,p["tEndpoint"],p["t"]],s23->If[endpoint,0,p["S23Sample"]],B->p["S23UpperB"]}];
localValue[name_,part_,p_,endpoint_]:=Module[{branch,expression},
 branch=p[If[endpoint,"EndpointBranch","InteriorBranch"]];
 expression=If[part==="Born",independent["Hats"][name]["LODelta"],
  If[branch===0,independent["BoundaryAtTEqualsMinusS"][name][part],
   independent["Hats"][name]["NLO"][branch][part]/.independent["BranchCoordinates"][branch]]];
 expression/.commonRules/.evaluationRules[p,endpoint]];
logShift=FullSimplify[Log[s23]-Log[s23/B],s23>0&&B>0];
gate["raw logarithm shift is recoil independent",FreeQ[logShift,s23]];
gate["raw logarithmic kernels reconstruct",FullSimplify[
 Log[s23]-Log[s23/B]-logShift,s23>0&&B>0]===0];
bornDriverWeights=Map[Factor[#/(rawBorn factor0)]&,published["BornDriver"]];
gate["published Born driver weights extracted exactly",
 FreeQ[bornDriverWeights,rawBorn|factor0]&&And@@Table[
  Factor[published["BornDriver"][mode]-bornDriverWeights[mode] rawBorn factor0]===0,{mode,{"Pg","Ppp"}}]];
referenceValue[mode_,part_,p_,endpoint_]:=referenceValue[mode,part,p,endpoint]=Module[
 {raw,rules,curve,direct,value},
 rules={xh->p["xHat"],Q->p["Q"],qT2->p["qT2"],zH->p["zH"]};
 If[part==="Born",
  raw=bornDriverWeights[mode]*published["Born"][metadata["BornFunctions"][mode]];
  Return[raw/.{Q2->Q^2}/.{zh->(zh/.kinematicRules)}/.rules/.s23->0]];
 curve=t/.kinematicRules/.rules;
 raw=Switch[part,"Delta",published[mode]["delta"],"L0",
  published[mode]["plus1B"]+logShift published[mode]["plus2B"],
  "L1",published[mode]["plus2B"],"Regular",published[mode]["regular"]];
 raw=raw/.{t->curve,s->p["s"],Q->p["Q"],mu->p["Q"],nf->p["Nf"],B->p["S23UpperB"],g->1,gp->1};
 If[!endpoint,Return[raw/.s23->p["S23Sample"]]];
 direct=Quiet[raw/.s23->0,{Power::infy,Infinity::indet}];
 value=If[FreeQ[direct,Indeterminate|_DirectedInfinity],direct,
  bounded[Limit[raw,s23->0,Direction->"FromAbove",Assumptions->s23>0],
   {"reference endpoint",p["ID"],mode,part}]];
 gate["reference endpoint evaluated",FreeQ[value,s23|_Limit|_ConditionalExpression|Indeterminate|_DirectedInfinity|_Real]];
 value];
authorValue[name_,part_,p_,endpoint_]:=Module[{index},
 index=First[FirstPosition[names,name]];
 p["ProjectorWeights"][[index]].Table[referenceValue[mode,part,p,endpoint],{mode,{"Pg","Ppp"}}]];
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
gate["author expressions unchanged",sha[authorPath]===authorHash];
gate["author metadata unchanged",Import[FileNameJoin[{root,"s01_result.json"}],"RawJSON"]===metadata];
jsonValue[x_Association]:=Map[jsonValue,x];
jsonValue[x_List]:=jsonValue/@x;
jsonValue[x_?NumericQ]:=If[IntegerQ[x],x,N[x,MachinePrecision]];
jsonValue[x_]:=x;
result=<|"Status"->"Complete","Channel"->"Hgq","SourceSHA256"->sha[$InputFileName],
 "IndependentInputs"->manifest,"AuthorResultSHA256"->authorHash,
 "AuthorMetadataSHA256"->sha[FileNameJoin[{root,"s01_result.json"}]],"AuthorTree"->metadata["tree"],
 "AuthorReconstructionAssumption"->metadata["interpretation"],
 "Conventions"-><|"Couplings"->"g_s=1, eq=1; alpha_s derived from its defining relation",
 "Color"->"SU(3) benchmark","Scale"->"mu=Q","Nf"->4,
 "Basis"->"delta(s23), L0=[1/s23]_+, L1=[Log(s23/B)/s23]_+, Regular on [0,B]",
 "HeldFixed"->"xhat,Q,qT2,zH; t(s23) and J(s23) transported together",
 "Jacobians"->"J(s23) for ordinary density; J(0) for endpoint coefficients",
 "Deferred"->"PDFs/FFs, luminosity, zh/(xi*zeta), outer convolution","Difference"->"BigTMD minus local"|>,
 "DerivedMaps"-><|"Kinematics"->ToString[kinematicRules,InputForm],
 "Zeta"->ToString[zetaExpression,InputForm],"B"->ToString[upperExpression,InputForm],
 "Jacobian"->ToString[jacobianExpression,InputForm],"PlusTransport"->ToString[transportRules,InputForm],
 "ProjectorWeights"->ToString[projectorWeights,InputForm],
 "RawInteriorWeights"->ToString[rawInteriorWeights,InputForm],
 "BornDriverWeights"->Map[ToString[#,InputForm]&,bornDriverWeights]|>,
 "ExactSeeds"->(Map[ToString[#,InputForm]&,#]&/@seeds),
 "Benchmarks"->points,"CoefficientRows"->coefficientRows,"InteriorRows"->interiorRows,
 "Evaluation"-><|"RequestedDigits"->60,"MinimumRetainedPrecision"->Min[precisions],
 "MaximumImaginaryResidual"->Max[imaginaryResiduals],"KernelPeakBytes"->MaxMemoryUsed[]|>|>;
Export[outputPath<>".tmp",jsonValue[result],"RawJSON"];
reread=Import[outputPath<>".tmp","RawJSON"];
gate["JSON reload coverage",Length[reread["CoefficientRows"]]===Length[coefficientRows]&&
 Length[reread["InteriorRows"]]===Length[interiorRows]];
gate["strict Python JSON reload",RunProcess[{"/u/local/apps/anaconda3/2023.03/bin/python","-c",
 "import json,sys; json.load(open(sys.argv[1]))",outputPath<>".tmp"},"ExitCode"]===0];
RenameFile[outputPath<>".tmp",outputPath];
Print["HGQ_BIGTMD_S02_SUCCESS"];
Quit[0];

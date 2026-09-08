$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
SetDirectory[DirectoryName[$InputFileName]];
If[!DirectoryQ["s02_result"], CreateDirectory["s02_result"]];
require[c_, m_] := If[!TrueQ[c], Print["FAIL: ", m]; Quit[1]];

(* Solve scalar products from the on-shell and Mandelstam definitions. *)
setKinematics[real_] := Module[{basis, gram, vars, dot, remaining, definitions, sol, all},
  FCClearScalarProducts[];
  basis = If[real, {p, q, k1, k2}, {p, q, k1}];
  gram = Table[sv[Min[i,j], Max[i,j]], {i,Length[basis]}, {j,Length[basis]}];
  vars = DeleteDuplicates[Flatten[gram]];
  dot[l_,r_] := (Coefficient[Expand[l],#]& /@ basis).gram.(Coefficient[Expand[r],#]& /@ basis);
  remaining = p + q - Total[Drop[basis,2]];
  definitions = Join[Thread[Diagonal[gram] == If[real,{0,-Q2,0,0},{0,-Q2,0}]],
    {dot[remaining,remaining] == 0, dot[p+q,p+q] == s,
     dot[q-k1,q-k1] == t},
    If[real, {dot[p-k1,p-k1] == w-Q2-s-t, dot[p-k2,p-k2] == a,
      dot[k1+k2,k1+k2] == b}, {}]];
  sol = Solve[definitions, vars];
  require[Length[sol] == 1, "unique kinematics"];
  sol = First[sol];
  all = If[real, {p,q,k1,k2,k3}, {p,q,k1,k2}];
  Do[With[{l=all[[i]], r=all[[j]], v=Factor[dot[
       all[[i]] /. Last[all] -> remaining,
       all[[j]] /. Last[all] -> remaining] /. sol]}, SPD[l,r] = v],
    {i,Length[all]}, {j,i,Length[all]}];
  If[real,
    Put[<|"u" -> ExpandScalarProduct[SPD[p-k1]],
      "forms" -> (Factor[ExpandScalarProduct[SPD[#]]]& /@
        {p-k2,p-k3,k1+k2,k1+k3,q-k2,q-k3}),
      "gram" -> Table[SPD[all[[i]],all[[j]]],{i,Length[all]},{j,Length[all]}],
      "momenta" -> all|>, "s02_result/kinematics.wl"]];
];

openPhoton[amp_, index_] := amp /. Momentum[Polarization[q,___],D] :> LorentzIndex[index,D];
reduce[amp_, channel_, projection_] := Module[{v, density, norm},
  density = Switch[projection, "g", MTD[mu,nu], "pp", FVD[p,mu] FVD[p,nu],
    "qq", FVD[q,mu] FVD[q,nu]];
  norm = If[channel == "born_qg", 2 SUNN, (D-2)(SUNN^2-1)];
  v = amp FCI[density]/norm;
  v = FeynAmpDenominatorExplicit[v];
  v = SUNSimplify[v, Explicit -> True, SUNNToCACF -> True];
  v = FermionSpinSum[v];
  If[channel != "born_qg", v = DoPolarizationSums[v,p,k1]];
  If[channel != "born_gq", v = DoPolarizationSums[v,k1,p]];
  v = DiracSimplify[v, DiracTraceEvaluate -> True];
  v = ExpandScalarProduct[Contract[v]];
  v = SUNSimplify[v, Explicit -> True, SUNNToCACF -> True];
  v = Factor[Together[v/ee^2 /. {SUNN -> Nc, CA -> Nc, CF -> (Nc^2-1)/(2 Nc)}]];
  require[FreeQ[v, _Spinor|_DiracGamma|_DiracTrace|_SUNTF|_SUNF|_SUNDelta|
     _LorentzIndex|_Polarization|_FeynAmpDenominator|_Pair], "scalar reduction"];
  v
];

Do[
  setKinematics[channel == "real"];
  amps = Get["s01_result/" <> channel <> ".wl"]["amplitudes"];
  pairs = Flatten[Table[{i,j},{i,Length[amps]},{j,i,Length[amps]}],1];
  Do[
    {i,j} = pair;
    file = "s02_result/" <> channel <> "_" <> IntegerString[i,10,2] <> IntegerString[j,10,2] <> ".wl";
    If[FileExistsQ[file], Print["Resume ", file]; Continue[]];
    tensor = openPhoton[amps[[i]],mu] ComplexConjugate[openPhoton[amps[[j]],nu], FCRenameDummyIndices -> True];
    If[i != j, tensor += openPhoton[amps[[j]],mu] ComplexConjugate[openPhoton[amps[[i]],nu], FCRenameDummyIndices -> True]];
    Print["Reducing ", channel, " ", pair];
    result = Association@Table[projection -> MemoryConstrained[reduce[tensor,channel,projection],
      4*1024^3,$Aborted], {projection,{"g","pp","qq"}}];
    require[FreeQ[result,$Aborted], "memory limit"];
    Put[result,file];
    Print["Saved ", channel," ",pair,"; bytes ",ByteCount[result],"; memory MB ",Round[MemoryInUse[]/1024^2]];
    Clear[tensor,result]; ClearSystemCache[],
    {pair,pairs}];
  result = Association@Table[projection -> Factor[Together[Total[
    Get[#][projection]& /@ FileNames[channel <> "_*.wl","s02_result"]]]],
    {projection,{"g","pp","qq"}}];
  require[result["qq"] === 0, channel <> " photon Ward identity"];
  Put[result,"s02_result/" <> channel <> ".wl"];
  Print["PASS: ",channel," scalar square and photon Ward identity"],
  {channel,{"born_qg","born_gq","real"}}];
Print["PASS: all squared amplitudes saved"];
Quit[0];

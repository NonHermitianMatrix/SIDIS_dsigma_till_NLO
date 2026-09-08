$HistoryLength=0;$FeynCalcStartupMessages=False;
Get["FeynCalc`"];
SetDirectory[DirectoryName[$InputFileName]];
If[!DirectoryQ["s05_result"],CreateDirectory["s05_result"]];
require[c_,m_] := If[!TrueQ[c],Print["FAIL: ",m];Quit[1]];
If[FileExistsQ["s05_result/Fhats.wl"],
  saved=Get["s05_result/Fhats.wl"];
  require[Values[saved["pole_residues"]]==={0,0} &&
    Values[Get["s04_result/endpoint_residues.wl"]]==={0,0},"saved result gates"];
  Print["PASS: final symbolic F1hat and F2hat saved; all pole and endpoint gates passed"];
  Quit[0]];
physical=Q2>0 && s>w>0 && w-Q2-s<t<-Q2 w/s;
kin=Get["s02_result/kinematics.wl"];u=kin["u"];
bornQ=Get["s02_result/born_qg.wl"];bornG=Get["s02_result/born_gq.wl"];
colorTrace=SUNSimplify[SUNTrace[SUNT[aa,aa]],SUNNToCACF->False] /. SUNN->Nc;
tf=Cancel[colorTrace/(Nc^2-1)];cf=Cancel[colorTrace/Nc];
require[FreeQ[{tf,cf},_SUNTrace|_SUNT|_SUNTF|_SUNDelta],"color normalization"];
pqg=2tf ((1-xi)^2+xi^2);pgq=2cf (1+(1-zz)^2)/zz; (* Eqs. 52-53 *)
initialS=xi(s+Q2)-Q2;initialT=t;initialU=xi u;
finalS=s;finalT=(t+Q2)/zz-Q2;finalU=u/zz;
initialMass=Expand[initialS+initialT+initialU+Q2];
finalMass=Together[finalS+finalT+finalU+Q2];
xiRoot=xi /. First[Solve[initialMass==0,xi]];
zzRoot=zz /. First[Solve[finalMass==0,zz]];
require[FullSimplify[0<xiRoot<1 && 0<zzRoot<1,physical],"factorization roots in support"];
xiJac=FullSimplify[Abs[D[initialMass,xi] /. xi->xiRoot],physical];
zzJac=FullSimplify[Abs[D[finalMass,zz] /. zz->zzRoot],physical];
flows={gluon}; (* One intermediate gluon in each fixed-flavour convolution. *)
counter=Association@Table[projection -> Module[{initial,final},
  initial=(bornG[projection] /. {s->initialS,t->initialT}) (pgq /. zz->xi)/
    (xi If[projection=="pp",xi^2,1]);
  final=(bornQ[projection] /. {s->finalS,t->finalT}) (pqg /. xi->zz)/zz^2;
  Factor[Together[Total[Table[(initial /. xi->xiRoot)/xiJac+
    (final /. zz->zzRoot)/zzJac,{flow,flows}]]]]],{projection,{"g","pp"}}];
Put[<|"convolutions"->counter,"xi"->xiRoot,"zeta"->zzRoot,
  "jacobians"->{xiJac,zzJac},"TF"->tf,"CF"->cf,"flows"->flows|>,
  "s05_result/counterterms.wl"];

FCClearScalarProducts[];SPD[p]=0;SPD[q]=-Q2;SPD[p,q]=Q2/(2xh);
transverse=FVD[p,mu]-FVD[q,mu]SPD[p,q]/SPD[q];
tensor=(-MTD[mu,nu]+FVD[q,mu]FVD[q,nu]/SPD[q]) f1+
  transverse (transverse /. mu->nu) f2/SPD[p,q];
contractions={Contract[MTD[mu,nu]tensor],Contract[FVD[p,mu]FVD[p,nu]tensor]};
projectors=First[Solve[Thread[{Hg,Hpp}==contractions],{f1,f2}]];
require[FullSimplify[({f1,f2} /. projectors /. D->4-2eps)-{
  (-Hg/2+2xh^2 Hpp/Q2)/(1-eps),
  ((3-2eps)4xh^3 Hpp/Q2-xh Hg)/(1-eps)}] === {0,0},"paper projectors"];
Put[projectors,"s05_result/projectors.wl"];
Print["PASS: factorization support, Jacobians, and paper projectors"];
If[!FileExistsQ["s04_result/real.wl"],
  Print["Counterterms saved; rerun after angular integration finishes"];
  Quit[0]];
geometry=Get["s04_result/geometry.wl"];rhoSquare=geometry["rho_squared"];
reduceRoot[x_] := Module[{v=Together[x],n,d},
  n=PolynomialRemainder[Numerator[v],rho^2-rhoSquare,rho];
  d=PolynomialRemainder[Denominator[v],rho^2-rhoSquare,rho];
  Factor[n/d]];
compact[x_] := Module[{logs=DeleteDuplicates[Cases[x,_Log,Infinity]]},
  Collect[x,logs,reduceRoot]];
symmetryWeight=Get["s01_result/real.wl"]["symmetry_weight"];
phase3=symmetryWeight Pi w^-eps 2^-2 Pi^-eps Gamma[1-eps]/
  ((2Pi)^(6-2eps)Gamma[1-2eps]) mu2^(2eps); (* Eqs. 19, 38; angular Pi restored. *)
phaseCT=(2Pi)/(2Pi)^4 mu2^eps gs^2/(16Pi^2) (4Pi)^eps Exp[-EulerGamma eps]/eps;
realPhase=Normal[Series[phase3,{eps,0,1}]];
ctPhase=Normal[Series[eps phaseCT,{eps,0,1}]];
realParts=Table[
  output="s05_result/"<>FileNameTake[file];
  If[FileExistsQ[output],Get[output],
    Print["Combining ",FileNameTake[file]];
    part=Get[file];
    require[MatchQ[Values[part],{{_,_},{_,_}}],"angular input vector shape"];
    simple=Association@Table[projection -> {
      reduceRoot[part[projection][[1]]],
      compact[part[projection][[2]] /. Log[arg_] :> Log[reduceRoot[arg]]]},
      {projection,{"g","pp"}}];
    Put[simple,output];simple],
  {file,Sort[FileNames["real_*.wl","s04_result"]]}];
finite=<||>;poles=<||>;
Do[
  Print["Factorizing ",projection];
  realPole=reduceRoot[Total[#[projection][[1]]& /@ realParts]];
  realFinite=compact[Total[#[projection][[2]]& /@ realParts]];
  ct=Normal[Series[counter[projection] /. D->4-2eps,{eps,0,1}]];
  pole=reduceRoot[(realPhase /. eps->0) realPole+(ctPhase /. eps->0)(ct /. eps->0)];
  AssociateTo[poles,projection->pole];
  require[pole===0,projection<>" collinear pole cancellation"];
  AssociateTo[finite,projection->compact[(realPhase /. eps->0) realFinite+
    Coefficient[realPhase,eps]realPole+(ctPhase /. eps->0)Coefficient[ct,eps]+
    Coefficient[ctPhase,eps](ct /. eps->0)]];
  Print["PASS: ",projection," poles cancel"],{projection,{"g","pp"}}];
Put[poles,"s05_result/pole_residues.wl"];
hard=finite /. {gs->Sqrt[4Pi alphaS],eq->Sqrt[eq2]};
hats=AssociationThread[{"F1hat","F2hat"},compact /@ ({f1,f2} /. projectors /.
  {D->4,xh->Q2/(s+Q2),Hg->hard["g"],Hpp->hard["pp"]})];
require[FreeQ[hats,eps|ee|eq|gs|_Part|_Integrate|_Series|Indeterminate|ComplexInfinity],"finite symbolic F hats"];
mapS=Q2(1/xh-1);mapT=-Q2+zh(Q2-qT2);mapU=-zh Q2/xh;
maps={s->mapS,t->mapT,w->Factor[mapS+mapT+mapU+Q2]};
result=<|"channel"->"Hqqbar", "order"->HoldForm[alphaS^2],"Fhats"->hats,"contractions"->hard,
  "rho_squared"->rhoSquare,"rho_branch"->"positive","hat_variable_rules"->maps,
  "eq2"->"squared electric charge of the fixed incoming quark flavour",
  "spectator_symmetry_weight"->symmetryWeight,
  "mu2"->"common squared MSbar renormalization and factorization scale",
  "support"->HoldForm[Q2>0 && s>w>0 && w-Q2-s<t<-Q2 w/s],
  "delta"->{0,0},"plus"->{0,0},"pole_residues"->poles|>;
Put[result,"s05_result/Fhats.wl"];
Export["s05_result/Fhats.txt",ToString[result,InputForm,PageWidth->120],"Text"];
Print["PASS: final symbolic F1hat and F2hat saved; bytes ",ByteCount[hats]];
Quit[0];

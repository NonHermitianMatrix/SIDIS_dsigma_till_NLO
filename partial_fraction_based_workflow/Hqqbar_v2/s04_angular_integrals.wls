$HistoryLength=0;
SetDirectory[DirectoryName[$InputFileName]];
If[!DirectoryQ["s04_result"],CreateDirectory["s04_result"]];
require[c_,m_] := If[!TrueQ[c],Print["FAIL: ",m];Quit[1]];
assume = dd>1 && -1<cc<1;
laurent[x_] := With[{v=Normal[Series[x,{eps,0,0}]]},
  {Coefficient[v,eps,-1],Coefficient[v,eps,0]}];
(* Gamma recurrence, applied by the program before expanding at epsilon=0. *)
gam[n_Integer,c_Integer] := Gamma[1-c eps] If[n>=1,
  Product[r-c eps,{r,1,n-1}],1/Product[r-c eps,{r,n,0}]];
hyper[j_Integer,l_Integer] := Module[{v,nmax},
  If[j<=0 || l<=0,
    nmax=Min[Select[{-j,-l},#>=0&]];
    Return[Sum[Pochhammer[j,n] Pochhammer[l,n] z^n/(Pochhammer[1-eps,n] n!),{n,0,nmax}]]];
  v=(1-z)^(-1-eps); (* Eq. B27 through the order needed for single poles. *)
  Do[v=(z D[v,z]+r v)/r,{r,1,j-1}];
  Do[v=(z D[v,z]+r v)/r,{r,1,l-1}];
  v
];
massless[j_Integer,l_Integer] := massless[j,l] = Module[{pref,v},
  pref=Cancel[2^(1-j-l) gam[1,2] gam[1-j,1] gam[1-l,1]/
    (gam[1,1]^2 gam[2-j-l,2])];
  v=laurent[pref hyper[j,l]];
  v /. z -> (1+cc)/2
];
massive[j_Integer,l_Integer] := massive[j,l] = Module[
  {pref,hh,f0,f1,c0,c1,regular,finite,pole,n,poly,moments,answer,file},
  file="s04_result/master_"<>ToString[j]<>"_"<>ToString[l]<>".wl";
  If[FileExistsQ[file],Return[Get[file]]];
  Print["Deriving angular master ",{j,l}];
  If[l>=1,
    (* Eq. B19, followed by the Taylor endpoint subtraction in B22-B26. *)
    pref=Cancel[(-1)^(l+1) 2^(1-l-j) gam[1,2] gam[l, -1] gam[1-l,1]/
      (gam[1,1]^2 gam[0,1] gam[1,-1])];
    hh=Normal[Series[hyper[j,l],{eps,0,1}]];
    f0=Cancel[(hh /. eps->0) /. z->(1+cc)v/(dd-1+2v)]/(v+(dd-1)/2)^j;
    f0=Cancel[f0];
    f1=(Coefficient[hh,eps] /. z->(1+cc)v/(dd-1+2v))/(v+(dd-1)/2)^j-Log[v] f0;
    c0=Table[Cancel[(-1)^r (D[f0,{v,r}] /. v->1)/r!],{r,0,l-1}];
    c1=FullSimplify[(-1)^(l-1) (D[f1,{v,l-1}] /. v->1)/(l-1)!,assume];
    regular=Cancel[(f0-Sum[c0[[r+1]] (1-v)^r,{r,0,l-1}])/(1-v)^l];
    finite=Integrate[regular,{v,0,1},Assumptions->assume,GenerateConditions->False]+
      Sum[c0[[r+1]]/(r-l+1),{r,0,l-2}]-c1;
    pole=-Last[c0];
    answer=FullSimplify[laurent[pref (pole/eps+finite)],assume],
    (* A polynomial second factor needs only the finite angular moment. *)
    n=-l;
    moments=Table[Integrate[Cos[phi]^(2r),{phi,0,Pi}]/Pi,{r,0,Floor[n/2]}];
    poly=Expand[Sum[Binomial[n,2r](1-cc^2)^r (1-v^2)^r (1-cc v)^(n-2r)
      moments[[r+1]],{r,0,Floor[n/2]}]];
    answer={0,FullSimplify[Integrate[poly/(dd-v)^j,{v,-1,1},
      Assumptions->assume,GenerateConditions->False],assume]}
  ];
  require[FreeQ[answer,_Integrate|_Series|_Hypergeometric2F1|Indeterminate|ComplexInfinity],"evaluated angular master"];
  Put[answer,file];answer
];

(* Check the convention of the pole masters against Appendix F. *)
require[FullSimplify[massive[1,1]-{1/(cc-dd),Log[(dd^2-1)/(dd-cc)^2]/(cc-dd)},assume]==={0,0},"Eq. F24"];
require[FullSimplify[massive[1,2]-{(1-cc dd)/(cc-dd)^3,
  (-cc^2-2cc dd+dd^2+2+(cc dd-1)Log[(dd-cc)^2/(dd^2-1)])/(cc-dd)^3},assume]==={0,0},"Eq. F28"];
Print["PASS: angular master conventions (F24, F28)"];

kin=Get["s02_result/kinematics.wl"];forms=kin["forms"];gram=kin["gram"];
vectors=Table[Coefficient[forms[[i]],x],{i,6},{x,{a,b}}];
means=Factor[forms /. {a->(forms[[1]]+forms[[2]])/2,b->(forms[[3]]+forms[[4]])/2}];
energies=Table[(gram[[i,4]]+gram[[i,5]])/Sqrt[w],{i,{1,3}}];
eta={-2,2}; (* coefficients in (p-k2)^2 and (k1+k2)^2 *)
baseGram=Table[Factor[w eta[[i]] eta[[j]] (energies[[i]] energies[[j]]-
  gram[[{1,3}[[i]],{1,3}[[j]]]])/4],{i,2},{j,2}];
spatialGram=Map[Factor,vectors.baseGram.Transpose[vectors],{2}];
rhoSquare=spatialGram[[5,5]];
require[And@@Table[Factor[means[[i]]^2-spatialGram[[i,i]]]===0,{i,4}],"massless angular directions"];
scales=Join[Take[means,4],{-rho,-rho}];
putGeometry=<|"means"->means,"spatial_gram"->spatialGram,"scales"->scales,
  "rho_squared"->rhoSquare,"rho_branch"->"positive",
  "physical_region"->HoldForm[Q2>0 && s>w>0 && w-Q2-s<t<-Q2 w/s]|>;
Put[putGeometry,"s04_result/geometry.wl"];
angular[key_List] := angular[key] = Module[{i,j,powerI,powerJ,c,d,answer},
  {i,j,powerI,powerJ}=key;
  If[i<=4 && j>4,{i,j,powerI,powerJ}={j,i,powerJ,powerI}];
  c=Factor[spatialGram[[i,j]]/(scales[[i]]scales[[j]])];
  If[i>4,
    d=Factor[means[[i]]/scales[[i]]];
    answer=massive[powerI,powerJ] /. {cc->c,dd->d},
    answer=massless[powerI,powerJ] /. cc->c];
  answer/(scales[[i]]^powerI scales[[j]]^powerJ)
];

files=Sort[FileNames["real_*.wl","s03_result"]];
Do[
  output="s04_result/"<>FileNameTake[file];
  If[FileExistsQ[output],Print["Resume ",output];Continue[]];
  source=Get[file];Print["Integrating ",FileNameTake[file]];
  result=Association@Table[projection -> Module[{rows=source[projection],pieces,co,ang},
    pieces=Table[co=laurent[(Last[row]/eps) /. D->4-2eps];ang=angular[First[row]];
      {co[[1]]ang[[1]],co[[1]]ang[[2]]+co[[2]]ang[[1]]},{row,rows}];
    Total[Prepend[pieces,ConstantArray[0,2]]]],{projection,{"g","pp"}}];
  require[MatchQ[Values[result],{{_,_},{_,_}}],"pole and finite vector shape"];
  Put[result,output];Print["Saved angular poles and finite terms"];
  Clear[source,result];ClearSystemCache[],{file,files}];
If[!FileExistsQ["s03_result/real.wl"],
  Print["Angular checkpoints saved; rerun after stage 3 assembles the full result"];
  Quit[0]];
(* The singular branch of B18 checks recoil endpoints at symbolic epsilon.
   This retains the full D dependence, including possible evanescent residues. *)
partialTotal=Get["s03_result/real.wl"];
threshold=Association@Table[projection -> Module[{terms={},hs={},i,j,jj,ll,c,h,pref,series,co},
  Do[
    {i,j,jj,ll}=First[row];
    If[i>4 || j>4 || jj<=0 || ll<=0,Continue[]];
    c=Factor[spatialGram[[i,j]]/(scales[[i]]scales[[j]])];
    If[Cancel[c /. w->0] =!= 1,Continue[]];
    h=Cancel[(1-c)/(2w)];AppendTo[hs,h];
    pref=Cancel[2^(1-jj-ll) gam[1,2] gam[1-jj,1] gam[1-ll,1]/
      (gam[1,1]^2 gam[2-jj-ll,2]) * gam[1,1] gam[jj+ll-1,-1]/
      (Gamma[jj] Gamma[ll] gam[1,1] gam[1,-1])];
    require[FreeQ[pref,_Gamma],"common endpoint Gamma factor"];
    co=(Last[row] /. D->4-2eps)/(scales[[i]]^jj scales[[j]]^ll);
    series=Sum[Pochhammer[1-eps-jj,r] Pochhammer[1-eps-ll,r] (w h)^r/
      (Pochhammer[2-eps-jj-ll,r] r!),{r,0,jj+ll-2}];
    AppendTo[terms,co pref w^(1-jj-ll) h^(1-jj-ll) series],
    {row,partialTotal[projection]}];
  require[Length[DeleteDuplicates[hs]]<=1,"common aligned-direction endpoint factor"];
  Factor[Together[Normal[Series[Total[terms],{w,0,-1}]]]]],
  {projection,{"g","pp"}}];
require[Values[threshold]==={0,0},"no recoil endpoint poles at symbolic epsilon"];
Put[threshold,"s04_result/endpoint_residues.wl"];
Print["PASS: no recoil endpoint distributions at symbolic epsilon"];
result=Association@Table[projection -> Total[Get[#][projection]& /@
  Sort[FileNames["real_*.wl","s04_result"]]],{projection,{"g","pp"}}];
Put[result,"s04_result/real.wl"];
Print["PASS: symbolic angular integrals saved (overall Pi factored out)"];
Quit[0];

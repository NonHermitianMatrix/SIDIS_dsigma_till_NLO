$HistoryLength = 0;
SetDirectory[DirectoryName[$InputFileName]];
If[!DirectoryQ["s03_result"], CreateDirectory["s03_result"]];
require[c_,m_] := If[!TrueQ[c],Print["FAIL: ",m];Quit[1]];
kin = Get["s02_result/kinematics.wl"];
forms = kin["forms"];
vectors = Table[Coefficient[forms[[i]],x],{i,Length[forms]},{x,{a,b}}];
family[i_] := Ceiling[i/2];
combine[rows_] := ({First[First[#]], Factor[Together[Total[Last /@ #]]]}& /@
  GatherBy[rows,First]) /. {key_,0} :> Nothing;

(* Appendix D: use affine relations to remove redundant denominators. *)
reducePowers[exponents_List] := reducePowers[exponents] = Module[
  {used, same, chosen, relation, constant, rows, lowered},
  used = Flatten[Position[exponents,_?(#>0&)]];
  same = Select[Subsets[used,{2}], SameQ @@ (family /@ #)&];
  If[same == {} && Length[used] <= 2, Return[{{exponents,1}}]];
  chosen = If[same != {}, First[same], Take[used,3]];
  relation = First[NullSpace[Transpose[vectors[[chosen]]]]];
  constant = Expand[relation.forms[[chosen]]];
  require[constant =!= 0 && FreeQ[constant,a|b], "partial-fraction relation"];
  rows = Flatten[Table[
    lowered = ReplacePart[exponents,chosen[[i]] -> exponents[[chosen[[i]]]]-1];
    {First[#],Last[#] relation[[i]]/constant}& /@ reducePowers[lowered],
    {i,Length[chosen]}],1];
  combine[rows]
];
pairCoordinates[ids_List] := pairCoordinates[ids] = First[Solve[
  Thread[forms[[ids]] == {v1,v2}],{a,b}]];

partial[expression_] := Module[{num,den,factors,powers,constant,base,power,matches,
    ratio,terms,used,ids,polynomial,records,answer,reconstruction},
  If[expression === 0, Return[{}]];
  num=Numerator[expression];den=Denominator[expression];
  factors=FactorList[den];powers=ConstantArray[0,Length[forms]];constant=1;
  Do[
    {base,power}=factor;
    If[FreeQ[base,a|b],constant*=base^power;Continue[]];
    matches=Select[Range[Length[forms]], FreeQ[Cancel[base/forms[[#]]],a|b]&];
    require[Length[matches] == 1,"physical denominator: "<>ToString[base,InputForm]];
    ratio=Cancel[base/forms[[First[matches]]]];
    constant*=ratio^power;powers[[First[matches]]]+=power,
    {factor,factors}];
  terms=reducePowers[powers];
  records=Reap[Do[
    used=Flatten[Position[First[term],_?(#>0&)]];
    ids=Switch[Length[used],2,used,1,
      {First[used],First[Select[Range[Length[forms]],
        MatrixRank[vectors[[{First[used],#}]]] == 2&]]},0,{1,3}];
    polynomial=Expand[num /. pairCoordinates[ids]];
    Do[Sow[{Join[ids,First[term][[ids]]-First[monomial]],
      Last[monomial] Last[term]/constant}],
      {monomial,CoefficientRules[polynomial,{v1,v2}]}],{term,terms}]][[2]];
  answer=If[records=={}, {}, combine[First[records]]];
  reconstruction=Total[Last[#] Times @@ (forms[[Take[First[#],2]]]^(-Drop[First[#],2]))& /@ answer];
  require[Together[reconstruction-expression] === 0,"exact partial-fraction equality"];
  answer
];

files=Sort[FileNames["real_*.wl","s02_result"]];
require[Length[files]>0,"squared-amplitude checkpoints"];
Do[
  output="s03_result/"<>FileNameTake[file];
  If[FileExistsQ[output],Print["Resume ",output];Continue[]];
  source=Get[file];Print["Partial fractions ",FileNameTake[file]];
  result=Association@Table[projection -> MemoryConstrained[partial[source[projection]],4*1024^3,$Aborted],
    {projection,{"g","pp"}}];
  require[FreeQ[result,$Aborted],"memory limit"];
  Put[result,output];Print["Saved terms ",Length /@ Values[result]];
  Clear[source,result];ClearSystemCache[],{file,files}];
If[!FileExistsQ["s02_result/real.wl"],
  Print["Checkpoints saved; rerun after stage 2 finishes to assemble the full result"];
  Quit[0]];
result=Association@Table[projection -> combine[Flatten[
  Get[#][projection]& /@ Sort[FileNames["real_*.wl","s03_result"]],1]],
  {projection,{"g","pp"}}];
Put[result,"s03_result/real.wl"];
Print["PASS: exact partial fractions; total terms ",Length /@ Values[result]];
Print["Angular powers ",Sort[DeleteDuplicates[Drop[First[#],2]& /@ Flatten[Values[result],1]]]];
Quit[0];

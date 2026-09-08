$HistoryLength = 0;
SetDirectory[DirectoryName[$InputFileName]];
require[c_, m_] := If[!TrueQ[c], Print["FAIL: ", m]; Quit[1]];
tensor = Get["../s02_result/real.wl"];
metric = DiagonalMatrix[{1,-1,-1,-1}];
dot[v_, z_] := v.metric.z;
massless[v_] := Prepend[v, Sqrt[v.v]];
seeds = {{{1,2,3},{-2,1,-1},4}, {{2,-1,1},{1,3,-2},7},
         {{-1,3,2},{2,-2,1},10}, {{3,1,-2},{-1,-3,1},2},
         {{1,-2,-3},{-3,1,2},13}, {{2,3,-1},{-1,2,3},5}};
rows = Table[
  {v1,v2,q2input} = seed;
  out = massless /@ {v1,v2,-v1-v2};
  total = Total[out];
  pin = energy {1,0,0,1};
  energyRule = First@Solve[dot[total-pin,total-pin] == -q2input, energy];
  pin = Simplify[pin /. energyRule];
  qin = Simplify[total-pin];
  {o1,o2,o3} = out;
  momenta = Join[{qin,pin},out];
  require[And@@(TrueQ[Simplify[#]==0]& /@ (dot[#,#]& /@ Join[{pin},out])),"massless partons"];
  require[TrueQ[Simplify[dot[qin,qin]] == -q2input],"spacelike photon"];
  require[And@@Thread[Simplify[qin+pin-Total[out]] == 0],"momentum conservation"];
  rules = Thread[{Q2,s,t,w,a,b} -> Simplify[{-dot[qin,qin],dot[pin+qin,pin+qin],
       dot[qin-o1,qin-o1],dot[o2+o3,o2+o3],dot[pin-o2,pin-o2],dot[o1+o2,o1+o2]}]];
  vals = N[({tensor["g"],tensor["pp"]} /. {D->4,Nc->3,eq->1,gs->1}) /. rules,60];
  require[And@@(NumberQ /@ vals),"finite numeric reference"];
  <|"momenta"->N[momenta,17],"invariants"->AssociationThread[
       {"Q2","s","t","w","a","b"},N[Last /@ rules,17]],
    "g"->vals[[1]],"pp"->vals[[2]],
    "g_60_digits"->ToString[vals[[1]],InputForm],
    "pp_60_digits"->ToString[vals[[2]],InputForm]|>,
  {seed,seeds}];
Put[<|"points"->rows,"seeds"->seeds|>,"s02_result.wl"];
Export["s02_result.json",<|"points"->rows,"seeds"->seeds,
  "D"->4,"Nc"->3,"eq"->1,"gs"->1,
  "production_tensor_sha256"->FileHash["../s02_result/real.wl","SHA256","HexString"],
  "production_hats_sha256"->FileHash["../s05_result/Fhats.wl","SHA256","HexString"]|>,"RawJSON"];
Print["PASS: ",Length[rows]," exact on-shell points and 60-digit reference contractions"];
Quit[0];

$HistoryLength=0;
SetDirectory[DirectoryName[$InputFileName]];
require[c_,m_] := If[!TrueQ[c],Print["FAIL: ",m];Quit[1]];
result=Get["../s05_result/Fhats.wl"];
projectors=Get["../s05_result/projectors.wl"];
manifest=Import["s01_result.json","RawJSON"];
require[FileHash["../s05_result/Fhats.wl","SHA256","HexString"]===manifest["production_sha256"],"frozen production hash"];
require[FileHash["s01_auxiliary.wl","SHA256","HexString"]===manifest["auxiliary_sha256"],"published auxiliary hash"];
auxiliary=Get["s01_auxiliary.wl"];
endpointAssume=Q>0 && s>0 && -Q^2-s<t<0 && mu>0;
endpointLimits=Association@Table[projection->(FullSimplify[
  Limit[#,w->0,Direction->"FromAbove",Assumptions->endpointAssume],endpointAssume]& /@
  auxiliary[projection]),{projection,{"Pg","Ppp"}}];
require[Values[endpointLimits]==={{0,0},{0,0}},"vanishing published plus endpoints"];
ordinaryAddition=Association@Table[projection->auxiliary[projection][[1]]/w+
  auxiliary[projection][[2]]Log[w]/w,{projection,{"Pg","Ppp"}}];
Put[<|"endpoint_limits"->endpointLimits,"ordinary_addition"->ordinaryAddition|>,"s02_endpoint_result.wl"];
Export["s02_endpoint_result.json",<|"all_endpoints_zero"->True,"endpoint_limits"->endpointLimits,
  "auxiliary_sha256"->manifest["auxiliary_sha256"],
  "identity"->"For C(0)=0, its plus-distribution products are C(w)/w and C(w)Log[w]/w.",
  "decimal_policy"->"Exact base-10 rational values of the source tokens; no rational reconstruction is needed for zero endpoint limits."|>,"RawJSON"];
Print["PASS: published plus coefficients have zero endpoints and contribute ordinary densities"];
(* sidis.py 203, 247-250 and paper Eqs. 6, 15 fix this transport. *)
normalization=Cancel[(gs2^2 jac/(xi zeta) zh)/(z jac/(xi zeta^2)) /. zh->z/zeta];
chargeWeight=manifest["charge_weight"]; (* Counted from the channel-5 flavour mapping. *)
require[normalization===gs2^2 && chargeWeight===1,"driver normalization and charge weight"];
matrix=Table[Coefficient[({f1,f2} /. projectors /. D->4)[[i]],h],
  {i,2},{h,{Hg,Hpp}}] /. xh->Q2/(Q2+s);
(* Exact rational seeds cover s+t positive, negative, and zero. *)
seeds=Flatten[Table[ReplacePart[seed,3->recoil],
  {seed,{{4,10,1,-3},{4,10,1,-12},{4,10,1,-10}}},{recoil,{1,3/2}}],1];
points=Flatten[Table[Append[seed,scale First[seed]],{seed,seeds},{scale,{1/2,1,2}}],1];
rows=Table[
  rules=Join[Thread[{Q2,s,w,t,mu2}->point],{Nc->3,alphaS->1,eq2->1}];
  require[TrueQ[(Q2>0 && s>w>0 && w-Q2-s<t<-Q2 w/s) /. rules],"physical point"];
  values=N[Values[result["Fhats"]] /. rho->Sqrt[result["rho_squared"]] /. rules,60];
  contractions=N[Values[result["contractions"]] /. rho->Sqrt[result["rho_squared"]] /. rules,60];
  require[And@@(NumericQ /@ Join[values,contractions]) &&
    Max[Abs[Im[Join[values,contractions]]]]<10^-50,"real high-precision values"];
  <|"parameters"->AssociationThread[{"Q2","s","s23","t","mu2"},point],
    "branch_s_plus_t"->Sign[(s+t) /. rules],"local_hats"->N[Re[values]],
    "local_contractions"->N[Re[contractions]],
    "local_hats_60_digits"->(ToString[#,InputForm]& /@ Re[values]),
    "projector_matrix"->N[matrix /. rules],
    "published_weight"->N[normalization chargeWeight /. gs2->4Pi]|>,{point,points}];
Export["s02_result.json",<|"points"->rows,"euler_gamma"->N[EulerGamma],
  "normalization"->ToString[normalization,InputForm],"charge_weight"->chargeWeight,
  "precision_digits"->60,"production_sha256"->manifest["production_sha256"]|>,"RawJSON"];
Print["PASS: ",Length[points]," physical points; both hats evaluated at 60 digits"];
Quit[0];

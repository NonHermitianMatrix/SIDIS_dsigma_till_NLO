$HistoryLength=0;$LoadAddOns={};$FeynCalcStartupMessages=False;Get["FeynCalc`"];
d=Get["/home/physics/projects/AI_Assisted_SIDIS/scripts/Hqq_v2/s04_result.wl"];
require[x_,m_]:=If[!TrueQ[x],Print["S10_FATAL ",m];Quit[1]];
require[And@@Values[d["Checks"]],"accepted S04 checks"];
j=d["VariableMap","Dzetads23"]/.{xHat->xB/xi,z->zH};
measures=<|"BornInvariant"->(d["PhaseSpace","TwoBody","InvariantMeasure"]/.DiracDelta[_]->1),
"RealAngular"->d["PhaseSpace","ThreeBody","HardPartTimesAngularPrefactor"]|>;
checks=<|"JacobianAgreesWithNumericsS04"->(Cancel[Together[j-(-xB*(-PHT2*xB + Q2*xB*zH^2 - Q2*xi*zH^2)/(zH*(Q2*xB - Q2*xi + s23*xB)^2))]]===0),
"PartonicMeasuresIndependentOfHadronicVariables"->FreeQ[measures,z|zH|PHT2|xi|xB|zeta],
"FragmentationJacobianDependsOnHadronicVariables"->(!TrueQ[Cancel[Together[D[j,zH]]]===0])|>;
Print["S10_MEASURE_CHECKS ",checks];require[And@@Values[checks],"measure contract"];
Export["/home/physics/projects/AI_Assisted_SIDIS/scripts/numerics/s10_cache/s10_hqq_measures_result",<|"Checks"->checks,"Measures"->Map[ToString[#,InputForm]&,measures],
"FragmentationJacobian"->ToString[j,InputForm],"InputSHA256"->FileHash["/home/physics/projects/AI_Assisted_SIDIS/scripts/Hqq_v2/s04_result.wl","SHA256","HexString"]|>,"RawJSON"];
Print["S10_MEASURE_CONTRACT ",checks];Quit[];

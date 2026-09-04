<|"Stage" -> "HqqV2S05CoefficientTask-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "ProducingSourceSHA256" -> 
  "68f905e9de1e12efb6dd1803a446f6e73d87ee772114dd14ccd5e9108980178a", 
 "S04ResultSHA256" -> 
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c", 
 "MasterCacheSHA256" -> 
  "8d968dbc9583c41736aec709b9d09e62eba9be52cc1a31475cc70c3910b4b839", 
 "Algorithm" -> "Normal-Series-epsilon-0-through-2-and-phase-convolution-v1", 
 "TaskLabel" -> "Pg/Hqq;gg", "TaskIndex" -> 34, 
 "TaskInputSHA256" -> 
  "f945e7596a1a9b237db8f9a34f7e9a5e98e4a6f7d6f6843a063605313591527a", 
 "TaskByteCount" -> 17864, "TaskLeafCount" -> 566, 
 "WorkerLaunch" -> <|"KernelCount" -> 2, "KernelIDs" -> {33, 34}, 
   "Versions" -> {15., 15.}, "OrderProbe" -> True, "WorkerProbe" -> True|>, 
 "PhaseCoefficientData" -> 
  <|0 -> (FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
      FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(32*Pi^6*s23^2*(s23 - t1)*t1^2*
      (-Q2 + s23 - t1 - u1)*(Q2 + t1 + u1)), 
   1 -> -1/16*(FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
        FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(Pi^6*s23^2*(s23 - t1)*t1^2*
        (-Q2 + s23 - t1 - u1)*(Q2 + t1 + u1)) + 
     (FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
       FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(Log[16*Pi] + PolyGamma[0, 1/2]))/
      (32*Pi^6*s23^2*(s23 - t1)*t1^2*(-Q2 + s23 - t1 - u1)*(Q2 + t1 + u1)), 
   2 -> (FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
       FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(32*Pi^6*s23^2*(s23 - t1)*t1^2*
       (-Q2 + s23 - t1 - u1)*(Q2 + t1 + u1)) - 
     (FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
       FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(Log[16*Pi] + PolyGamma[0, 1/2]))/
      (16*Pi^6*s23^2*(s23 - t1)*t1^2*(-Q2 + s23 - t1 - u1)*(Q2 + t1 + u1)) + 
     (FAGS^4*(-1 + SUNN^2)*(Q2^2 - Q2*s23 + Q2*t1 - s23*t1 + Q2*u1)*
       FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(-Pi^2 + 2*Log[16]^2 + 
        4*Log[16]*Log[Pi] + 2*Log[Pi]^2 + 4*Log[16]*PolyGamma[0, 1/2] + 
        4*Log[Pi]*PolyGamma[0, 1/2] + 2*PolyGamma[0, 1/2]^2))/
      (128*Pi^6*s23^2*(s23 - t1)*t1^2*(-Q2 + s23 - t1 - u1)*
       (Q2 + t1 + u1))|>, "Checks" -> <|"WorkerAnswer" -> True, 
   "ExactPhaseCoefficientData" -> True, "WorkerLaunch" -> True|>|>

<|"Stage" -> "HqqV2S05CoefficientTask-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "ProducingSourceSHA256" -> 
  "9a0ed02258b858a27618704fdbd7da7b53921e2469ef35f1026ad1eb7ca0c712", 
 "S04ResultSHA256" -> 
  "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c", 
 "MasterCacheSHA256" -> 
  "8d968dbc9583c41736aec709b9d09e62eba9be52cc1a31475cc70c3910b4b839", 
 "Algorithm" -> "Rational-Coefficient-and-inverse-denominator-Series-v3", 
 "TaskLabel" -> "Pg/Hqq;q_qbar_sameFlavor", "TaskIndex" -> 151, 
 "TaskInputSHA256" -> 
  "08128827c48c9ad06af0fbc62652fc5a6a2421dedfcb56c73c60f92d81c2ea90", 
 "TaskByteCount" -> 2560, "TaskLeafCount" -> 80, "TaskTermCount" -> 1, 
 "WorkerLaunch" -> <|"KernelCount" -> 2, "KernelIDs" -> {144, 145}, 
   "Versions" -> {15., 15.}, "OrderProbe" -> True, "WorkerProbe" -> True, 
   "TermwiseEquivalenceProbe" -> True, 
   "RationalCoefficientEquivalenceProbe" -> True|>, 
 "PhaseCoefficientData" -> 
  <|0 -> -1/64*(FAGS^4*Q2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2 - 
       FAGS^4*Q2*SUNN^2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
      (Pi^6*SUNN), 
   1 -> -1/64*(-(FAGS^4*Q2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2) + 
        FAGS^4*Q2*SUNN^2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
       (Pi^6*SUNN) - ((FAGS^4*Q2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2 - 
        FAGS^4*Q2*SUNN^2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)*
       (Log[16*Pi] + PolyGamma[0, 1/2]))/(64*Pi^6*SUNN), 
   2 -> -1/64*((-(FAGS^4*Q2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2) + 
         FAGS^4*Q2*SUNN^2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)*
        (Log[16*Pi] + PolyGamma[0, 1/2]))/(Pi^6*SUNN) - 
     ((FAGS^4*Q2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2 - 
        FAGS^4*Q2*SUNN^2*u1^2*FCGV["EL"]^2*HqqV2Charge["UpType"]^2)*
       (-Pi^2 + 2*Log[16]^2 + 4*Log[16]*Log[Pi] + 2*Log[Pi]^2 + 
        4*Log[16]*PolyGamma[0, 1/2] + 4*Log[Pi]*PolyGamma[0, 1/2] + 
        2*PolyGamma[0, 1/2]^2))/(256*Pi^6*SUNN)|>, 
 "Checks" -> <|"WorkerAnswer" -> True, "ExactAddendsReconstruct" -> True, 
   "ExactPhaseCoefficientData" -> True, "WorkerLaunch" -> True|>|>

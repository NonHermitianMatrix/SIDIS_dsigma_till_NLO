<|"Stage" -> "HqqV2S07FactorizationCache-v1", 
 "ScopeTag" -> 
  "[Hqq_v2, people or agents working on other channels should ignore]", 
 "ProducerSource" -> 
  <|"Path" -> 
    "/u/home/r/rushil/AI_Assisted_SIDIS_Hqq_v2/s07_factorize_hqq_msbar.wl", 
   "SHA256" -> 
    "db2012e21e8abe0fe4c007f3811ed57fd4cd5f2635301fb107a0aa0bf45a7c00"|>, 
 "Inputs" -> <|"PaperSHA256" -> 
    "bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b", 
   "S03SourceSHA256" -> 
    "379e463f748adae363c693cd39afd4a8dc5420e3a096e98d60c73d9a9afeca0b", 
   "S03ResultSHA256" -> 
    "bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4", 
   "S04SourceSHA256" -> 
    "ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793", 
   "S04ResultSHA256" -> 
    "8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c", 
   "S05SourceSHA256" -> 
    "cd8e471d24fec0e751463c36f08bdeb72c0a791379d350cbc99e24b541d4fdac", 
   "S05ResultSHA256" -> 
    "e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f", 
   "S06SourceSHA256" -> 
    "4b78bd25d05d52913ad668973fc6c404b1b883e6b94e6ede0562ac98d892e8d3", 
   "S06ResultSHA256" -> 
    "b8e8b105bf62f2148d56d419a2563c8970dcf7c8b1b8e097f6ad55e0f1dddb9e"|>, 
 "Runtime" -> <|"Wolfram" -> "15.0.0 for Linux x86 (64-bit) (May 19, 2026)", 
   "FeynCalc" -> "10.2.1"|>, "Conventions" -> <|"Dimension" -> 4 - 2*epsilon, 
   "Scheme" -> "MSbar", "CouplingCanonicalization" -> 
    <|"FeynArtsRawModelCoupling" -> Global`FAGS, "FeynCalcSMCoupling" -> 
      SMP["g_s"], "LoggedSMCouplingDisplay" -> "SMP[g_s]", 
     "ChannelCoupling" -> Global`FAGS, "AppliedRules" -> 
      {SMP["g_s"] -> Global`FAGS, HqqV2LoggedStrongCoupling -> Global`FAGS}, 
     "GeneratedTreeGate" -> True|>, "FactorizationEquation" -> 46, 
   "FactorizationPrefactor" -> (E^(epsilon*(-EulerGamma + Log[4*Pi]))*
      Global`FAGS^2)/(16*epsilon*Pi^2), "PhysicalEndpoint" -> 
    (-(PHT2*xHat) + Q2*z - Q2*xHat*z - Q2*z^2 + Q2*xHat*z^2)/(xHat*z), 
   "BoundedPlusHead" -> HoldForm[HqqV2BoundedPlus[0, s23, 
      physicalBoundary]]|>, "LowerBorn" -> 
  <|"DiagramLedger" -> <|"Hqq" -> <|"Indices" -> {"q", "q"}, 
       "UnfilteredCount" -> 2, "SelectedCount" -> 2, 
       "GraphIDs" -> {GraphID[Topology == 1, Generic == 1, Classes == 1, 
          Number == 1], GraphID[Topology == 1, Generic == 1, Classes == 1, 
          Number == 2]}, "GaugeChecks" -> <|"ReferenceIndependence" -> True, 
         "ExternalGluonWard" -> True, "ElectromagneticWard" -> True|>|>, 
     "Hgq" -> <|"Indices" -> {"g", "q"}, "UnfilteredCount" -> 2, 
       "SelectedCount" -> 2, "GraphIDs" -> {GraphID[Topology == 1, 
          Generic == 1, Classes == 1, Number == 1], GraphID[Topology == 1, 
          Generic == 1, Classes == 1, Number == 2]}, 
       "GaugeChecks" -> <|"ReferenceIndependence" -> True, 
         "ExternalGluonWard" -> True, "ElectromagneticWard" -> True|>|>, 
     "Hqg" -> <|"Indices" -> {"q", "g"}, "UnfilteredCount" -> 2, 
       "SelectedCount" -> 2, "GraphIDs" -> {GraphID[Topology == 1, 
          Generic == 1, Classes == 1, Number == 1], GraphID[Topology == 1, 
          Generic == 1, Classes == 1, Number == 2]}, 
       "GaugeChecks" -> <|"ReferenceIndependence" -> True, 
         "ExternalGluonWard" -> True, "ElectromagneticWard" -> True|>|>|>, 
   "Projected" -> 
    <|"Hqq" -> <|"Pg" -> ((-2 + D)*Global`FAGS^2*(-1 + SUNN^2)*
          (4*Q2^2 + 4*Q2*sHat - 2*sHat^2 + D*sHat^2 + 4*Q2*tHat - 
           8*sHat*tHat + 2*D*sHat*tHat - 2*tHat^2 + D*tHat^2)*
          FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(2*sHat*SUNN*tHat), 
       "PPP" -> ((-2 + D)*Global`FAGS^2*(-1 + SUNN^2)*(Q2 + sHat + tHat)*
          FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(2*SUNN)|>, 
     "Hgq" -> <|"Pg" -> (Global`FAGS^2*(-2*Q2^2 + D*Q2^2 - 8*Q2*sHat + 
           2*D*Q2*sHat - 2*sHat^2 + D*sHat^2 + 4*Q2*tHat + 4*sHat*tHat + 
           4*tHat^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
         (tHat*(Q2 + sHat + tHat)), "PPP" -> 
        (4*Global`FAGS^2*sHat*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
         (-2 + D)|>, "Hqg" -> 
      <|"Pg" -> -1/2*((-2 + D)*Global`FAGS^2*(-1 + SUNN^2)*
           (-2*Q2^2 + D*Q2^2 + 4*Q2*sHat + 4*sHat^2 - 8*Q2*tHat + 
            2*D*Q2*tHat + 4*sHat*tHat - 2*tHat^2 + D*tHat^2)*
           FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
          (sHat*SUNN*(Q2 + sHat + tHat)), 
       "PPP" -> -1/2*((-2 + D)*Global`FAGS^2*(-1 + SUNN^2)*tHat*
           FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/SUNN|>|>, 
   "HqqAgreementWithS03" -> <|"Pg" -> True, "PPP" -> True|>, 
   "HqqRatiosToS03" -> <|"Pg" -> 1, "PPP" -> 1|>, 
   "StateCounts" -> <|"QuarkSpin" -> 2, "QuarkColor" -> SUNN, 
     "GluonSpin" -> -2 + D, "GluonColor" -> -1 + SUNN^2, 
     "QuarkAverage" -> 1/(2*SUNN), "GluonAverage" -> 
      1/((-2 + D)*(-1 + SUNN^2)), "TF" -> 1/2, 
     "CF" -> -1/2*(1 - SUNN^2)/SUNN, "Checks" -> <|"QuarkAverage" -> True, 
       "GluonAverage" -> True, "ExactCounts" -> True, "TraceReconstructs" -> 
        True|>|>|>, "SplittingKernels" -> 
  <|"Definitions" -> <|{"q", "q"} -> 
      -(((1 - SUNN^2)*(-1 - y + (3*S07KernelDelta[1 - y])/2 + 
          2*S07KernelPlus[1 - y]))/SUNN), {"q", "g"} -> (1 - y)^2 + y^2, 
     {"g", "q"} -> -(((1 - SUNN^2)*(1 + (1 - y)^2))/(SUNN*y))|>, 
   "Decomposition" -> <|{"q", "q"} -> 
      <|"Regular" -> -(((1 - SUNN^2)*(-1 - y))/SUNN), 
       "Plus" -> (-2*(1 - SUNN^2))/SUNN, "Delta" -> (-3*(1 - SUNN^2))/
         (2*SUNN)|>, {"q", "g"} -> <|"Regular" -> (1 - y)^2 + y^2, 
       "Plus" -> 0, "Delta" -> 0|>, {"g", "q"} -> 
      <|"Regular" -> -(((1 - SUNN^2)*(1 + (1 - y)^2))/(SUNN*y)), "Plus" -> 0, 
       "Delta" -> 0|>|>, "Checks" -> <|{"q", "q"} -> True, 
     {"q", "g"} -> True, {"g", "q"} -> True|>|>, 
 "Factorization" -> 
  <|"Routes" -> <|"Initial_qq" -> <|"Direction" -> "Initial", 
       "Parent" -> "q", "BornChannel" -> "Hqq", "Kernel" -> 
        <|"Regular" -> -(((1 - SUNN^2)*(-1 - y))/SUNN), 
         "Plus" -> (-2*(1 - SUNN^2))/SUNN, "Delta" -> (-3*(1 - SUNN^2))/
           (2*SUNN)|>|>, "Initial_gq" -> <|"Direction" -> "Initial", 
       "Parent" -> "g", "BornChannel" -> "Hgq", "Kernel" -> 
        <|"Regular" -> -(((1 - SUNN^2)*(1 + (1 - y)^2))/(SUNN*y)), 
         "Plus" -> 0, "Delta" -> 0|>|>, "Final_qq" -> 
      <|"Direction" -> "Final", "Parent" -> "q", "BornChannel" -> "Hqq", 
       "Kernel" -> <|"Regular" -> -(((1 - SUNN^2)*(-1 - y))/SUNN), 
         "Plus" -> (-2*(1 - SUNN^2))/SUNN, "Delta" -> (-3*(1 - SUNN^2))/
           (2*SUNN)|>|>, "Final_qg" -> <|"Direction" -> "Final", 
       "Parent" -> "g", "BornChannel" -> "Hqg", "Kernel" -> 
        <|"Regular" -> (1 - y)^2 + y^2, "Plus" -> 0, "Delta" -> 0|>|>|>, 
   "InitialConstraint" -> eta*s23 + t1 - eta*t1, 
   "FinalConstraint" -> (s23 - sHat + eta*sHat)/eta, 
   "InverseFractionRules" -> {xHat -> Q2/(Q2 + sHat), 
     zHat -> -(u1/(Q2 + sHat)), 
     k1T2 -> (u1*(Q2^2 + Q2*sHat + Q2*t1 + sHat*t1 + Q2*u1))/(Q2 + sHat)^2}, 
   "ConservationRule" -> {u1 -> -Q2 + s23 - sHat - t1}, 
   "ByRouteLaurent" -> <|"Initial_qq" -> 
      <|"Pg" -> <|"Delta" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
              (2*Q2^2 + 2*Q2*sHat + sHat^2 + 2*Q2*t1 + t1^2)*FeynCalc`FCGV[
                "EL"]^2*HqqV2Charge["UpType"]^2*(3 + 4*Log[(PHT2*xHat + 
                   Q2*z*(-1 + xHat + z - xHat*z))/(t1*xHat*z)]))/
             (128*Pi^5*sHat*SUNN^2*t1), 0 -> -1/128*
             (Global`FAGS^4*(-1 + SUNN^2)^2*FeynCalc`FCGV["EL"]^2*
               HqqV2Charge["UpType"]^2*(2*Q2^2 + 2*EulerGamma*Q2^2 + 
                2*Q2*sHat + 2*EulerGamma*Q2*sHat + 2*sHat^2 + EulerGamma*
                 sHat^2 + 2*Q2*t1 + 2*EulerGamma*Q2*t1 + 2*sHat*t1 + 2*t1^2 + 
                EulerGamma*t1^2 - 2*Q2^2*Log[4*Pi] - 2*Q2*sHat*Log[4*Pi] - 
                sHat^2*Log[4*Pi] - 2*Q2*t1*Log[4*Pi] - t1^2*Log[4*Pi])*(3 + 
                4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - xHat*z))/(t1*xHat*
                    z)]))/(Pi^5*sHat*SUNN^2*t1)|>, "BoundedPlus" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(2*Q2^2 + 2*Q2*sHat + sHat^
                2 + 2*Q2*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, 
               s23, (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*
              HqqV2Charge["UpType"]^2)/(32*Pi^5*sHat*SUNN^2*t1), 
           0 -> (Global`FAGS^4*(1 - SUNN^2)*(-1 + SUNN^2)*FeynCalc`FCGV["EL"]^
               2*HqqV2BoundedPlus[0, s23, (-(PHT2*xHat) + Q2*z - Q2*xHat*z - 
                 Q2*z^2 + Q2*xHat*z^2)/(xHat*z)]*HqqV2Charge["UpType"]^2*
              ((sHat + t1)^2 - (-2*Q2^2 - 2*Q2*sHat - sHat^2 - 2*Q2*t1 - 
                 t1^2)*(1 + EulerGamma - Log[4*Pi])))/(32*Pi^5*sHat*SUNN^2*
              t1)|>, "Ordinary" -> 
          <|-1 -> (Global`FAGS^2*((Global`FAGS^2*(1 - SUNN^2)*(-1 + SUNN^2)*
                 (-(Q2^2*s23*sHat) + Q2*(2*Q2^2 + 4*Q2*sHat - 2*s23*sHat + 
                    sHat^2)*t1 + (2*Q2^2 + 4*Q2*sHat - s23*sHat)*t1^2 + 
                  (Q2 + 2*sHat)*t1^3)*FeynCalc`FCGV["EL"]^2*
                 HqqV2Charge["UpType"]^2)/(2*Pi^3*sHat*SUNN^2*t1^2*
                 (Q2*s23 + sHat*t1)) - (Global`FAGS^2*(-1 + SUNN^2)^2*
                 (s23 - 2*t1)*(Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23^2*t1 + 
                  2*Q2^2*t1^2 - 4*Q2*s23*t1^2 + s23^2*t1^2 + 2*Q2*sHat*t1^2 + 
                  sHat^2*t1^2 + 2*Q2*t1^3 - 2*s23*t1^3 + t1^4)*
                 FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                (4*Pi^3*SUNN^2*(s23 - t1)^2*t1^2*(Q2*s23 + sHat*t1))))/
             (16*Pi^2), 0 -> (Global`FAGS^2*((Global`FAGS^2*(-1 + SUNN^2)^2*
                 (-(Q2^2*s23*sHat) + Q2^3*t1 + 2*Q2^2*sHat*t1 + Q2^2*t1^2 + 
                  2*Q2*sHat*t1^2 - s23*sHat*t1^2 + sHat^2*t1^2 + Q2*t1^3 + 
                  2*sHat*t1^3)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                (Pi^3*sHat*SUNN^2*t1^2*(Q2*s23 + sHat*t1)) + (Global`FAGS^2*
                 (-1 + SUNN^2)^2*(s23 - 2*t1)*(Q2^2*s23^2 - Q2^2*s23*t1 + 
                  Q2*s23*sHat*t1 + Q2^2*t1^2 - Q2*s23*t1^2 + s23^2*t1^2 + 
                  Q2*sHat*t1^2 - s23*sHat*t1^2 + sHat^2*t1^2 + Q2*t1^3 - 
                  2*s23*t1^3 + sHat*t1^3 + t1^4)*FeynCalc`FCGV["EL"]^2*
                 HqqV2Charge["UpType"]^2)/(2*Pi^3*SUNN^2*(s23 - t1)^2*t1^2*
                 (Q2*s23 + sHat*t1)) + ((Global`FAGS^2*(1 - SUNN^2)*
                   (-1 + SUNN^2)*(-(Q2^2*s23*sHat) + Q2*(2*Q2^2 + 4*Q2*sHat - 
                      2*s23*sHat + sHat^2)*t1 + (2*Q2^2 + 4*Q2*sHat - 
                      s23*sHat)*t1^2 + (Q2 + 2*sHat)*t1^3)*FeynCalc`FCGV[
                     "EL"]^2*HqqV2Charge["UpType"]^2)/(2*Pi^3*sHat*SUNN^2*
                   t1^2*(Q2*s23 + sHat*t1)) - (Global`FAGS^2*(-1 + SUNN^2)^2*
                   (s23 - 2*t1)*(Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23^2*t1 + 
                    2*Q2^2*t1^2 - 4*Q2*s23*t1^2 + s23^2*t1^2 + 2*Q2*sHat*
                     t1^2 + sHat^2*t1^2 + 2*Q2*t1^3 - 2*s23*t1^3 + t1^4)*
                   FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                  (4*Pi^3*SUNN^2*(s23 - t1)^2*t1^2*(Q2*s23 + sHat*t1)))*
                (-EulerGamma + Log[4*Pi])))/(16*Pi^2)|>|>, 
       "PPP" -> <|"Delta" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
              (Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
              (3 + 4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - xHat*z))/
                  (t1*xHat*z)]))/(256*Pi^5*SUNN^2), 
           0 -> -1/256*(Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
               FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + 
                EulerGamma - Log[4*Pi])*(3 + 4*Log[(PHT2*xHat + Q2*z*
                     (-1 + xHat + z - xHat*z))/(t1*xHat*z)]))/
              (Pi^5*SUNN^2)|>, "BoundedPlus" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
               (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge["UpType"]^
               2)/(64*Pi^5*SUNN^2), 0 -> -1/64*(Global`FAGS^4*(-1 + SUNN^2)^
                2*(Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, 
                s23, (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge[
                 "UpType"]^2*(1 + EulerGamma - Log[4*Pi]))/(Pi^5*SUNN^2)|>, 
         "Ordinary" -> <|-1 -> -1/128*(Global`FAGS^4*(-1 + SUNN^2)^2*(
                Q2*s23 + s23^2 + s23*sHat - 2*Q2*t1 - s23*t1 - 2*sHat*t1)*
               FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
              (Pi^5*SUNN^2*(s23 - t1)^2), 0 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
              (Q2*s23 + s23^2 + s23*sHat - 2*Q2*t1 - s23*t1 - 2*sHat*t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + EulerGamma - 
               Log[4*Pi]))/(128*Pi^5*SUNN^2*(s23 - t1)^2)|>|>|>, 
     "Initial_gq" -> <|"Pg" -> <|"Delta" -> <|-1 -> 0, 0 -> 0|>, 
         "BoundedPlus" -> <|-1 -> 0, 0 -> 0|>, "Ordinary" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)*(2*s23^2 - 2*s23*t1 + t1^2)*
              (2*Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23*sHat*t1 + Q2^2*t1^2 - 
               2*Q2*s23*t1^2 + 2*s23^2*t1^2 - 2*s23*sHat*t1^2 + sHat^2*t1^2 + 
               2*Q2*t1^3 - 4*s23*t1^3 + 2*sHat*t1^3 + 2*t1^4)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
             (64*Pi^5*SUNN*(s23 - t1)^2*(-Q2 + s23 - sHat - t1)*t1^4), 
           0 -> (Global`FAGS^4*(-1 + SUNN^2)*(2*s23^2 - 2*s23*t1 + t1^2)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
              (-((Q2 + sHat)^2*t1^2) + (2*Q2^2*s23^2 - 2*Q2^2*s23*t1 + 
                 2*Q2*s23*sHat*t1 + Q2^2*t1^2 - 2*Q2*s23*t1^2 + 2*s23^2*
                  t1^2 - 2*s23*sHat*t1^2 + sHat^2*t1^2 + 2*Q2*t1^3 - 
                 4*s23*t1^3 + 2*sHat*t1^3 + 2*t1^4)*(-EulerGamma + 
                 Log[4*Pi])))/(64*Pi^5*SUNN*(s23 - t1)^2*(-Q2 + s23 - sHat - 
               t1)*t1^4)|>|>, "PPP" -> <|"Delta" -> <|-1 -> 0, 0 -> 0|>, 
         "BoundedPlus" -> <|-1 -> 0, 0 -> 0|>, "Ordinary" -> 
          <|-1 -> -1/64*(Global`FAGS^4*(-1 + SUNN^2)*(Q2*s23 + sHat*t1)*(
                2*s23^2 - 2*s23*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge[
                 "UpType"]^2)/(Pi^5*SUNN*(s23 - t1)^2*t1^2), 
           0 -> (Global`FAGS^4*(-1 + SUNN^2)*(Q2*s23 + sHat*t1)*
              (2*s23^2 - 2*s23*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*
              HqqV2Charge["UpType"]^2*(-1 + EulerGamma - Log[4*Pi]))/
             (64*Pi^5*SUNN*(s23 - t1)^2*t1^2)|>|>|>, 
     "Final_qq" -> <|"Pg" -> <|"Delta" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(2*Q2^2 + 2*Q2*sHat + sHat^
                2 + 2*Q2*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge[
                "UpType"]^2*(3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*
                    (-1 + z)*z)/(sHat*xHat*z)]))/(128*Pi^5*sHat*SUNN^2*t1), 
           0 -> -1/128*(Global`FAGS^4*(-1 + SUNN^2)^2*FeynCalc`FCGV["EL"]^
                2*HqqV2Charge["UpType"]^2*(2*Q2^2 + 2*EulerGamma*Q2^2 + 
                2*Q2*sHat + 2*EulerGamma*Q2*sHat + 2*sHat^2 + EulerGamma*
                 sHat^2 + 2*Q2*t1 + 2*EulerGamma*Q2*t1 + 2*sHat*t1 + 2*t1^2 + 
                EulerGamma*t1^2 - 2*Q2^2*Log[4*Pi] - 2*Q2*sHat*Log[4*Pi] - 
                sHat^2*Log[4*Pi] - 2*Q2*t1*Log[4*Pi] - t1^2*Log[4*Pi])*(3 + 
                4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*z)/(sHat*xHat*
                    z)]))/(Pi^5*sHat*SUNN^2*t1)|>, "BoundedPlus" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(2*Q2^2 + 2*Q2*sHat + sHat^
                2 + 2*Q2*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, 
               s23, (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*
              HqqV2Charge["UpType"]^2)/(32*Pi^5*sHat*SUNN^2*t1), 
           0 -> (Global`FAGS^4*(1 - SUNN^2)*(-1 + SUNN^2)*FeynCalc`FCGV["EL"]^
               2*HqqV2BoundedPlus[0, s23, (-(PHT2*xHat) + Q2*z - Q2*xHat*z - 
                 Q2*z^2 + Q2*xHat*z^2)/(xHat*z)]*HqqV2Charge["UpType"]^2*
              ((sHat + t1)^2 - (-2*Q2^2 - 2*Q2*sHat - sHat^2 - 2*Q2*t1 - 
                 t1^2)*(1 + EulerGamma - Log[4*Pi])))/(32*Pi^5*sHat*SUNN^2*
              t1)|>, "Ordinary" -> 
          <|-1 -> (Global`FAGS^2*((Global`FAGS^2*(s23 - 2*sHat)*(-1 + SUNN^2)^
                  2*(Q2^2*s23^2 - 2*Q2^2*s23*sHat + 2*Q2*s23^2*sHat + 
                  2*Q2^2*sHat^2 - 4*Q2*s23*sHat^2 + s23^2*sHat^2 + 
                  2*Q2*sHat^3 - 2*s23*sHat^3 + sHat^4 + 2*Q2*sHat^2*t1 + 
                  sHat^2*t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                (4*Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*(Q2*s23 + sHat*t1)) + 
               (Global`FAGS^2*(1 - SUNN^2)*(-1 + SUNN^2)*(Q2*(s23 - sHat)^2*
                   (2*Q2^2 + 2*Q2*sHat + sHat^2) + Q2^2*s23*(2*s23 - 3*sHat)*
                   t1 + Q2*(s23^2 - 3*sHat^2)*t1^2 + (s23 - 2*sHat)*sHat*
                   t1^3)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                (2*Pi^3*(s23 - sHat)^2*sHat*SUNN^2*t1*(Q2*s23 + sHat*t1))))/
             (16*Pi^2), 0 -> (Global`FAGS^2*(-1/2*(Global`FAGS^2*
                  (-1 + SUNN^2)^2*(-2*Q2^3*s23^2*sHat + 4*Q2^3*s23*sHat^2 - 
                   2*Q2^2*s23^2*sHat^2 - 2*Q2^3*sHat^3 + 4*Q2^2*s23*sHat^3 - 
                   2*Q2*s23^2*sHat^3 - 2*Q2^2*sHat^4 + 4*Q2*s23*sHat^4 - 
                   2*Q2*sHat^5 + Q2^2*s23^3*t1 - 5*Q2^2*s23^2*sHat*t1 + 
                   7*Q2^2*s23*sHat^2*t1 - 3*Q2*s23^2*sHat^2*t1 + s23^3*sHat^2*
                    t1 - 2*Q2^2*sHat^3*t1 + 5*Q2*s23*sHat^3*t1 - 4*s23^2*
                    sHat^3*t1 - 2*Q2*sHat^4*t1 + 5*s23*sHat^4*t1 - 
                   2*sHat^5*t1 - Q2*s23^2*sHat*t1^2 + Q2*s23*sHat^2*t1^2 - 
                   s23^2*sHat^2*t1^2 + 2*Q2*sHat^3*t1^2 + s23*sHat^3*t1^2 - 
                   s23*sHat^2*t1^3 + 2*sHat^3*t1^3)*FeynCalc`FCGV["EL"]^2*
                  HqqV2Charge["UpType"]^2)/(Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*
                  t1*(Q2*s23 + sHat*t1)) + ((Global`FAGS^2*(s23 - 2*sHat)*
                   (-1 + SUNN^2)^2*(Q2^2*s23^2 - 2*Q2^2*s23*sHat + 2*Q2*s23^2*
                     sHat + 2*Q2^2*sHat^2 - 4*Q2*s23*sHat^2 + s23^2*sHat^2 + 
                    2*Q2*sHat^3 - 2*s23*sHat^3 + sHat^4 + 2*Q2*sHat^2*t1 + 
                    sHat^2*t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^
                    2)/(4*Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*(Q2*s23 + 
                    sHat*t1)) + (Global`FAGS^2*(1 - SUNN^2)*(-1 + SUNN^2)*
                   (Q2*(s23 - sHat)^2*(2*Q2^2 + 2*Q2*sHat + sHat^2) + 
                    Q2^2*s23*(2*s23 - 3*sHat)*t1 + Q2*(s23^2 - 3*sHat^2)*
                     t1^2 + (s23 - 2*sHat)*sHat*t1^3)*FeynCalc`FCGV["EL"]^2*
                   HqqV2Charge["UpType"]^2)/(2*Pi^3*(s23 - sHat)^2*sHat*
                   SUNN^2*t1*(Q2*s23 + sHat*t1)))*(-EulerGamma + Log[4*Pi])))/
             (16*Pi^2)|>|>, "PPP" -> 
        <|"Delta" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
              (3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*z)/
                  (sHat*xHat*z)]))/(256*Pi^5*SUNN^2), 
           0 -> -1/256*(Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
               FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + 
                EulerGamma - Log[4*Pi])*(3 + 4*Log[(-(PHT2*xHat) + 
                    Q2*(-1 + xHat)*(-1 + z)*z)/(sHat*xHat*z)]))/
              (Pi^5*SUNN^2)|>, "BoundedPlus" -> 
          <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
               (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge["UpType"]^
               2)/(64*Pi^5*SUNN^2), 0 -> -1/64*(Global`FAGS^4*(-1 + SUNN^2)^
                2*(Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, 
                s23, (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge[
                 "UpType"]^2*(1 + EulerGamma - Log[4*Pi]))/(Pi^5*SUNN^2)|>, 
         "Ordinary" -> <|-1 -> -1/128*(Global`FAGS^4*(-1 + SUNN^2)^2*(
                Q2*s23 + s23^2 - 2*Q2*sHat - s23*sHat + s23*t1 - 2*sHat*t1)*
               FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
              (Pi^5*(s23 - sHat)^2*SUNN^2), 
           0 -> (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2*s23 + s23^2 - 2*Q2*sHat - 
               s23*sHat + s23*t1 - 2*sHat*t1)*FeynCalc`FCGV["EL"]^2*
              HqqV2Charge["UpType"]^2*(1 + EulerGamma - Log[4*Pi]))/
             (128*Pi^5*(s23 - sHat)^2*SUNN^2)|>|>|>, 
     "Final_qg" -> <|"Pg" -> <|"Delta" -> <|-1 -> 0, 0 -> 0|>, 
         "BoundedPlus" -> <|-1 -> 0, 0 -> 0|>, "Ordinary" -> 
          <|-1 -> (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*
              (-1 + SUNN^2)*(2*Q2^2*s23^2 - 2*Q2^2*s23*sHat + Q2^2*sHat^2 - 2*
                Q2*s23*sHat^2 + 2*s23^2*sHat^2 + 2*Q2*sHat^3 - 4*s23*sHat^3 + 
               2*sHat^4 + 2*Q2*s23*sHat*t1 - 2*s23*sHat^2*t1 + 2*sHat^3*t1 + 
               sHat^2*t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
             (64*Pi^5*(s23 - sHat)^2*sHat^4*SUNN*(-Q2 + s23 - sHat - t1)), 
           0 -> (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + SUNN^2)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
              (-(sHat^2*(Q2 + t1)^2) + (-2*Q2^2*s23^2 + 2*Q2^2*s23*sHat - 
                 Q2^2*sHat^2 + 2*Q2*s23*sHat^2 - 2*s23^2*sHat^2 - 
                 2*Q2*sHat^3 + 4*s23*sHat^3 - 2*sHat^4 - 2*Q2*s23*sHat*t1 + 
                 2*s23*sHat^2*t1 - 2*sHat^3*t1 - sHat^2*t1^2)*
                (1 + EulerGamma - Log[4*Pi])))/(64*Pi^5*(s23 - sHat)^2*sHat^4*
              SUNN*(-Q2 + s23 - sHat - t1))|>|>, 
       "PPP" -> <|"Delta" -> <|-1 -> 0, 0 -> 0|>, "BoundedPlus" -> 
          <|-1 -> 0, 0 -> 0|>, "Ordinary" -> 
          <|-1 -> -1/128*(Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + 
                SUNN^2)*(Q2*s23 + sHat*t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge[
                 "UpType"]^2)/(Pi^5*(s23 - sHat)^2*sHat^2*SUNN), 
           0 -> (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + SUNN^2)*
              (Q2*s23 + sHat*t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^
               2*(1 + EulerGamma - Log[4*Pi]))/(128*Pi^5*(s23 - sHat)^2*
              sHat^2*SUNN)|>|>|>|>, "LaurentLedger" -> 
    <|"Pg" -> <|"Delta" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
             (2*Q2^2 + 2*Q2*sHat + sHat^2 + 2*Q2*t1 + t1^2)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*z)/
                 (sHat*xHat*z)]))/(128*Pi^5*sHat*SUNN^2*t1) + 
           (Global`FAGS^4*(-1 + SUNN^2)^2*(2*Q2^2 + 2*Q2*sHat + sHat^2 + 
              2*Q2*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (3 + 4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - xHat*z))/
                 (t1*xHat*z)]))/(128*Pi^5*sHat*SUNN^2*t1), 
         0 -> -1/128*(Global`FAGS^4*(-1 + SUNN^2)^2*FeynCalc`FCGV["EL"]^2*
              HqqV2Charge["UpType"]^2*(2*Q2^2 + 2*EulerGamma*Q2^2 + 2*Q2*
                sHat + 2*EulerGamma*Q2*sHat + 2*sHat^2 + EulerGamma*sHat^2 + 
               2*Q2*t1 + 2*EulerGamma*Q2*t1 + 2*sHat*t1 + 2*t1^2 + EulerGamma*
                t1^2 - 2*Q2^2*Log[4*Pi] - 2*Q2*sHat*Log[4*Pi] - sHat^2*
                Log[4*Pi] - 2*Q2*t1*Log[4*Pi] - t1^2*Log[4*Pi])*
              (3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*z)/
                  (sHat*xHat*z)]))/(Pi^5*sHat*SUNN^2*t1) - 
           (Global`FAGS^4*(-1 + SUNN^2)^2*FeynCalc`FCGV["EL"]^2*
             HqqV2Charge["UpType"]^2*(2*Q2^2 + 2*EulerGamma*Q2^2 + 
              2*Q2*sHat + 2*EulerGamma*Q2*sHat + 2*sHat^2 + EulerGamma*sHat^
                2 + 2*Q2*t1 + 2*EulerGamma*Q2*t1 + 2*sHat*t1 + 2*t1^2 + 
              EulerGamma*t1^2 - 2*Q2^2*Log[4*Pi] - 2*Q2*sHat*Log[4*Pi] - 
              sHat^2*Log[4*Pi] - 2*Q2*t1*Log[4*Pi] - t1^2*Log[4*Pi])*
             (3 + 4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - xHat*z))/
                 (t1*xHat*z)]))/(128*Pi^5*sHat*SUNN^2*t1)|>, 
       "BoundedPlus" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
            (2*Q2^2 + 2*Q2*sHat + sHat^2 + 2*Q2*t1 + t1^2)*
            FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
             (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge["UpType"]^
             2)/(16*Pi^5*sHat*SUNN^2*t1), 0 -> (Global`FAGS^4*(1 - SUNN^2)*
            (-1 + SUNN^2)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
             (-(PHT2*xHat) + Q2*z - Q2*xHat*z - Q2*z^2 + Q2*xHat*z^2)/
              (xHat*z)]*HqqV2Charge["UpType"]^2*((sHat + t1)^2 - 
             (-2*Q2^2 - 2*Q2*sHat - sHat^2 - 2*Q2*t1 - t1^2)*
              (1 + EulerGamma - Log[4*Pi])))/(16*Pi^5*sHat*SUNN^2*t1)|>, 
       "Ordinary" -> <|-1 -> (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*
             (-1 + SUNN^2)*(2*Q2^2*s23^2 - 2*Q2^2*s23*sHat + Q2^2*sHat^2 - 
              2*Q2*s23*sHat^2 + 2*s23^2*sHat^2 + 2*Q2*sHat^3 - 4*s23*sHat^3 + 
              2*sHat^4 + 2*Q2*s23*sHat*t1 - 2*s23*sHat^2*t1 + 2*sHat^3*t1 + 
              sHat^2*t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
            (64*Pi^5*(s23 - sHat)^2*sHat^4*SUNN*(-Q2 + s23 - sHat - t1)) + 
           (Global`FAGS^4*(-1 + SUNN^2)*(2*s23^2 - 2*s23*t1 + t1^2)*
             (2*Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23*sHat*t1 + Q2^2*t1^2 - 
              2*Q2*s23*t1^2 + 2*s23^2*t1^2 - 2*s23*sHat*t1^2 + sHat^2*t1^2 + 
              2*Q2*t1^3 - 4*s23*t1^3 + 2*sHat*t1^3 + 2*t1^4)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
            (64*Pi^5*SUNN*(s23 - t1)^2*(-Q2 + s23 - sHat - t1)*t1^4) + 
           (Global`FAGS^2*((Global`FAGS^2*(s23 - 2*sHat)*(-1 + SUNN^2)^2*
                (Q2^2*s23^2 - 2*Q2^2*s23*sHat + 2*Q2*s23^2*sHat + 
                 2*Q2^2*sHat^2 - 4*Q2*s23*sHat^2 + s23^2*sHat^2 + 
                 2*Q2*sHat^3 - 2*s23*sHat^3 + sHat^4 + 2*Q2*sHat^2*t1 + 
                 sHat^2*t1^2)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(
                4*Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*(Q2*s23 + sHat*t1)) + 
              (Global`FAGS^2*(1 - SUNN^2)*(-1 + SUNN^2)*(Q2*(s23 - sHat)^2*
                  (2*Q2^2 + 2*Q2*sHat + sHat^2) + Q2^2*s23*(2*s23 - 3*sHat)*
                  t1 + Q2*(s23^2 - 3*sHat^2)*t1^2 + (s23 - 2*sHat)*sHat*t1^3)*
                FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(2*Pi^3*
                (s23 - sHat)^2*sHat*SUNN^2*t1*(Q2*s23 + sHat*t1))))/
            (16*Pi^2) + (Global`FAGS^2*((Global`FAGS^2*(1 - SUNN^2)*
                (-1 + SUNN^2)*(-(Q2^2*s23*sHat) + Q2*(2*Q2^2 + 4*Q2*sHat - 
                   2*s23*sHat + sHat^2)*t1 + (2*Q2^2 + 4*Q2*sHat - s23*sHat)*
                  t1^2 + (Q2 + 2*sHat)*t1^3)*FeynCalc`FCGV["EL"]^2*
                HqqV2Charge["UpType"]^2)/(2*Pi^3*sHat*SUNN^2*t1^2*
                (Q2*s23 + sHat*t1)) - (Global`FAGS^2*(-1 + SUNN^2)^2*
                (s23 - 2*t1)*(Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23^2*t1 + 
                 2*Q2^2*t1^2 - 4*Q2*s23*t1^2 + s23^2*t1^2 + 2*Q2*sHat*t1^2 + 
                 sHat^2*t1^2 + 2*Q2*t1^3 - 2*s23*t1^3 + t1^4)*
                FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(4*Pi^3*SUNN^2*
                (s23 - t1)^2*t1^2*(Q2*s23 + sHat*t1))))/(16*Pi^2), 
         0 -> (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + SUNN^2)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (-(sHat^2*(Q2 + t1)^2) + (-2*Q2^2*s23^2 + 2*Q2^2*s23*sHat - 
                Q2^2*sHat^2 + 2*Q2*s23*sHat^2 - 2*s23^2*sHat^2 - 
                2*Q2*sHat^3 + 4*s23*sHat^3 - 2*sHat^4 - 2*Q2*s23*sHat*t1 + 
                2*s23*sHat^2*t1 - 2*sHat^3*t1 - sHat^2*t1^2)*(1 + 
                EulerGamma - Log[4*Pi])))/(64*Pi^5*(s23 - sHat)^2*sHat^4*SUNN*
             (-Q2 + s23 - sHat - t1)) + (Global`FAGS^4*(-1 + SUNN^2)*
             (2*s23^2 - 2*s23*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*
             HqqV2Charge["UpType"]^2*(-((Q2 + sHat)^2*t1^2) + 
              (2*Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23*sHat*t1 + Q2^2*t1^2 - 
                2*Q2*s23*t1^2 + 2*s23^2*t1^2 - 2*s23*sHat*t1^2 + 
                sHat^2*t1^2 + 2*Q2*t1^3 - 4*s23*t1^3 + 2*sHat*t1^3 + 2*t1^4)*(
                -EulerGamma + Log[4*Pi])))/(64*Pi^5*SUNN*(s23 - t1)^2*
             (-Q2 + s23 - sHat - t1)*t1^4) + (Global`FAGS^2*
             (-1/2*(Global`FAGS^2*(-1 + SUNN^2)^2*(-2*Q2^3*s23^2*sHat + 
                  4*Q2^3*s23*sHat^2 - 2*Q2^2*s23^2*sHat^2 - 2*Q2^3*sHat^3 + 
                  4*Q2^2*s23*sHat^3 - 2*Q2*s23^2*sHat^3 - 2*Q2^2*sHat^4 + 
                  4*Q2*s23*sHat^4 - 2*Q2*sHat^5 + Q2^2*s23^3*t1 - 
                  5*Q2^2*s23^2*sHat*t1 + 7*Q2^2*s23*sHat^2*t1 - 3*Q2*s23^2*
                   sHat^2*t1 + s23^3*sHat^2*t1 - 2*Q2^2*sHat^3*t1 + 
                  5*Q2*s23*sHat^3*t1 - 4*s23^2*sHat^3*t1 - 2*Q2*sHat^4*t1 + 
                  5*s23*sHat^4*t1 - 2*sHat^5*t1 - Q2*s23^2*sHat*t1^2 + 
                  Q2*s23*sHat^2*t1^2 - s23^2*sHat^2*t1^2 + 2*Q2*sHat^3*t1^2 + 
                  s23*sHat^3*t1^2 - s23*sHat^2*t1^3 + 2*sHat^3*t1^3)*
                 FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                (Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*t1*(Q2*s23 + sHat*t1)) + 
              ((Global`FAGS^2*(s23 - 2*sHat)*(-1 + SUNN^2)^2*(Q2^2*s23^2 - 
                   2*Q2^2*s23*sHat + 2*Q2*s23^2*sHat + 2*Q2^2*sHat^2 - 
                   4*Q2*s23*sHat^2 + s23^2*sHat^2 + 2*Q2*sHat^3 - 
                   2*s23*sHat^3 + sHat^4 + 2*Q2*sHat^2*t1 + sHat^2*t1^2)*
                  FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                 (4*Pi^3*(s23 - sHat)^2*sHat^2*SUNN^2*(Q2*s23 + sHat*t1)) + 
                (Global`FAGS^2*(1 - SUNN^2)*(-1 + SUNN^2)*(Q2*(s23 - sHat)^2*
                    (2*Q2^2 + 2*Q2*sHat + sHat^2) + Q2^2*s23*(2*s23 - 3*sHat)*
                    t1 + Q2*(s23^2 - 3*sHat^2)*t1^2 + (s23 - 2*sHat)*sHat*
                    t1^3)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                 (2*Pi^3*(s23 - sHat)^2*sHat*SUNN^2*t1*(Q2*s23 + sHat*t1)))*(
                -EulerGamma + Log[4*Pi])))/(16*Pi^2) + 
           (Global`FAGS^2*((Global`FAGS^2*(-1 + SUNN^2)^2*(-(Q2^2*s23*sHat) + 
                 Q2^3*t1 + 2*Q2^2*sHat*t1 + Q2^2*t1^2 + 2*Q2*sHat*t1^2 - 
                 s23*sHat*t1^2 + sHat^2*t1^2 + Q2*t1^3 + 2*sHat*t1^3)*
                FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/(Pi^3*sHat*
                SUNN^2*t1^2*(Q2*s23 + sHat*t1)) + (Global`FAGS^2*
                (-1 + SUNN^2)^2*(s23 - 2*t1)*(Q2^2*s23^2 - Q2^2*s23*t1 + 
                 Q2*s23*sHat*t1 + Q2^2*t1^2 - Q2*s23*t1^2 + s23^2*t1^2 + 
                 Q2*sHat*t1^2 - s23*sHat*t1^2 + sHat^2*t1^2 + Q2*t1^3 - 
                 2*s23*t1^3 + sHat*t1^3 + t1^4)*FeynCalc`FCGV["EL"]^2*
                HqqV2Charge["UpType"]^2)/(2*Pi^3*SUNN^2*(s23 - t1)^2*t1^2*
                (Q2*s23 + sHat*t1)) + ((Global`FAGS^2*(1 - SUNN^2)*
                  (-1 + SUNN^2)*(-(Q2^2*s23*sHat) + Q2*(2*Q2^2 + 4*Q2*sHat - 
                     2*s23*sHat + sHat^2)*t1 + (2*Q2^2 + 4*Q2*sHat - 
                     s23*sHat)*t1^2 + (Q2 + 2*sHat)*t1^3)*FeynCalc`FCGV["EL"]^
                   2*HqqV2Charge["UpType"]^2)/(2*Pi^3*sHat*SUNN^2*t1^2*
                  (Q2*s23 + sHat*t1)) - (Global`FAGS^2*(-1 + SUNN^2)^2*
                  (s23 - 2*t1)*(Q2^2*s23^2 - 2*Q2^2*s23*t1 + 2*Q2*s23^2*t1 + 
                   2*Q2^2*t1^2 - 4*Q2*s23*t1^2 + s23^2*t1^2 + 2*Q2*sHat*
                    t1^2 + sHat^2*t1^2 + 2*Q2*t1^3 - 2*s23*t1^3 + t1^4)*
                  FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
                 (4*Pi^3*SUNN^2*(s23 - t1)^2*t1^2*(Q2*s23 + sHat*t1)))*(
                -EulerGamma + Log[4*Pi])))/(16*Pi^2)|>|>, 
     "PPP" -> <|"Delta" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
             (Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*z)/
                 (sHat*xHat*z)]))/(256*Pi^5*SUNN^2) + 
           (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (3 + 4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - xHat*z))/
                 (t1*xHat*z)]))/(256*Pi^5*SUNN^2), 
         0 -> -1/256*(Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + EulerGamma - 
               Log[4*Pi])*(3 + 4*Log[(-(PHT2*xHat) + Q2*(-1 + xHat)*(-1 + z)*
                    z)/(sHat*xHat*z)]))/(Pi^5*SUNN^2) - 
           (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2 + sHat + t1)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + EulerGamma - 
              Log[4*Pi])*(3 + 4*Log[(PHT2*xHat + Q2*z*(-1 + xHat + z - 
                    xHat*z))/(t1*xHat*z)]))/(256*Pi^5*SUNN^2)|>, 
       "BoundedPlus" -> <|-1 -> (Global`FAGS^4*(-1 + SUNN^2)^2*
            (Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
             (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge["UpType"]^
             2)/(32*Pi^5*SUNN^2), 0 -> -1/32*(Global`FAGS^4*(-1 + SUNN^2)^2*
             (Q2 + sHat + t1)*FeynCalc`FCGV["EL"]^2*HqqV2BoundedPlus[0, s23, 
              (Q2*(-1 + xHat)*(-1 + z))/xHat - PHT2/z]*HqqV2Charge["UpType"]^
              2*(1 + EulerGamma - Log[4*Pi]))/(Pi^5*SUNN^2)|>, 
       "Ordinary" -> <|-1 -> -1/128*(Global`FAGS^4*(-1 + SUNN^2)^2*
              (Q2*s23 + s23^2 + s23*sHat - 2*Q2*t1 - s23*t1 - 2*sHat*t1)*
              FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
             (Pi^5*SUNN^2*(s23 - t1)^2) - (Global`FAGS^4*(-1 + SUNN^2)^2*
             (Q2*s23 + s23^2 - 2*Q2*sHat - s23*sHat + s23*t1 - 2*sHat*t1)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2)/
            (128*Pi^5*(s23 - sHat)^2*SUNN^2) - 
           (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + SUNN^2)*
             (Q2*s23 + sHat*t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^
              2)/(128*Pi^5*(s23 - sHat)^2*sHat^2*SUNN) - 
           (Global`FAGS^4*(-1 + SUNN^2)*(Q2*s23 + sHat*t1)*
             (2*s23^2 - 2*s23*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*
             HqqV2Charge["UpType"]^2)/(64*Pi^5*SUNN*(s23 - t1)^2*t1^2), 
         0 -> (Global`FAGS^4*(-1 + SUNN^2)*(Q2*s23 + sHat*t1)*
             (2*s23^2 - 2*s23*t1 + t1^2)*FeynCalc`FCGV["EL"]^2*
             HqqV2Charge["UpType"]^2*(-1 + EulerGamma - Log[4*Pi]))/
            (64*Pi^5*SUNN*(s23 - t1)^2*t1^2) + (Global`FAGS^4*(-1 + SUNN^2)^2*
             (Q2*s23 + s23^2 + s23*sHat - 2*Q2*t1 - s23*t1 - 2*sHat*t1)*
             FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*(1 + EulerGamma - 
              Log[4*Pi]))/(128*Pi^5*SUNN^2*(s23 - t1)^2) + 
           (Global`FAGS^4*(-1 + SUNN^2)^2*(Q2*s23 + s23^2 - 2*Q2*sHat - 
              s23*sHat + s23*t1 - 2*sHat*t1)*FeynCalc`FCGV["EL"]^2*
             HqqV2Charge["UpType"]^2*(1 + EulerGamma - Log[4*Pi]))/
            (128*Pi^5*(s23 - sHat)^2*SUNN^2) + 
           (Global`FAGS^4*(2*s23^2 - 2*s23*sHat + sHat^2)*(-1 + SUNN^2)*
             (Q2*s23 + sHat*t1)*FeynCalc`FCGV["EL"]^2*HqqV2Charge["UpType"]^2*
             (1 + EulerGamma - Log[4*Pi]))/(128*Pi^5*(s23 - sHat)^2*sHat^2*
             SUNN)|>|>|>, "PrincipalRoots" -> {}, 
   "Checks" -> <|"RouteInventory" -> True, "KernelReconstruction" -> True, 
     "PushforwardChecks" -> True, "MSbarNoMuEpsilon" -> True, 
     "ClosedExact" -> True|>|>, "Checks" -> <|"AcceptedInputHashes" -> True, 
   "BornToolchain" -> True, "BornHqqAgreement" -> True, 
   "StateAndColorCounts" -> True, "SplittingKernels" -> True, 
   "Factorization" -> True, "PrincipalRootInventoryClosed" -> True|>|>

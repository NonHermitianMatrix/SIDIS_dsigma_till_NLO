<|"InputHash" -> 
  571494009176269687774111618152234879877753282200301646762304321425789500798\
81, "Conditions" -> Q > 0 && s > s23 > 0 && -Q^2 - s + s23 < omega - s < 
    -((Q^2*s23)/s) && mu > 0 && mu2 > 0 && B > 0 && SUNN > 1 && omega > 0, 
 "Rows" -> {<|"Original" -> Log[mu], "Candidate" -> Log[mu], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.003092|>, <|"Original" -> Log[2*Pi], 
    "Candidate" -> Log[2] + Log[Pi], "Residual" -> 0, "Accepted" -> True, 
    "Seconds" -> 0.000804|>, <|"Original" -> Log[4*Pi], 
    "Candidate" -> 2*Log[2] + Log[Pi], "Residual" -> 0, "Accepted" -> True, 
    "Seconds" -> 0.000981|>, <|"Original" -> Log[Pi], "Candidate" -> Log[Pi], 
    "Residual" -> 0, "Accepted" -> True, "Seconds" -> 0.000343|>, 
   <|"Original" -> Log[Q], "Candidate" -> Log[Q], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.000376|>, 
   <|"Original" -> Log[Q^2/(omega + Q^2)], "Candidate" -> 
     2*Log[Q] - Log[omega + Q^2], "Residual" -> 0, "Accepted" -> True, 
    "Seconds" -> 0.001471|>, <|"Original" -> Log[Pi*(omega + Q^2)], 
    "Candidate" -> Log[Pi] + Log[omega + Q^2], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.000786|>, 
   <|"Original" -> Log[-((omega + Q^2)/(omega*s - s^2))], 
    "Candidate" -> Log[omega + Q^2] - Log[s] - Log[-omega + s], 
    "Residual" -> 0, "Accepted" -> True, "Seconds" -> 0.008266|>, 
   <|"Original" -> Log[(1 - Sqrt[1 - (4*Q^2*(omega + Q^2 - s23))/
           (omega + 2*Q^2)^2])/(1 + Sqrt[1 - (4*Q^2*(omega + Q^2 - s23))/
           (omega + 2*Q^2)^2])], "Candidate" -> 
     Log[1 - Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)] - 
      Log[1 + Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.056387|>, <|"Original" -> Log[s23], 
    "Candidate" -> Log[s23], "Residual" -> 0, "Accepted" -> True, 
    "Seconds" -> 0.000483|>, 
   <|"Original" -> Log[((s - s23)*(-omega + s + s23))/
       ((omega + Q^2 - s23)*s23)], "Candidate" -> -Log[omega + Q^2 - s23] + 
      Log[s - s23] - Log[s23] + Log[-omega + s + s23], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.011483|>, 
   <|"Original" -> Log[-(((s - s23)*(-omega + s + s23))/
        ((omega - s)*s + Q^2*s23))], "Candidate" -> 
     Log[s - s23] + Log[-omega + s + s23] - Log[-(omega*s) + s^2 - Q^2*s23], 
    "Residual" -> 0, "Accepted" -> True, "Seconds" -> 0.01123|>, 
   <|"Original" -> Log[((omega + 2*Q^2)^2*(omega - s - s23)^2*
        (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q^2*s23)/
           (omega + 2*Q^2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
            s^2 + 4*Q^2*s23)/(omega + 2*Q^2)^2]))/(4*(omega - s)^2*
        (omega + Q^2 - s23)^2)], "Candidate" -> 
     -2*Log[2] + 2*Log[omega + 2*Q^2] - 2*(I*Pi + Log[-omega + s]) - 
      2*Log[omega + Q^2 - s23] + 2*(I*Pi + Log[-omega + s + s23]) + 
      Log[1 - Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)] + 
      Log[1 + Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.207436|>, 
   <|"Original" -> Log[((omega + 2*Q^2)^2*(s - s23)^2*
        (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q^2*s23)/
           (omega + 2*Q^2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
            s^2 + 4*Q^2*s23)/(omega + 2*Q^2)^2]))/
       (4*s^2*(omega + Q^2 - s23)^2)], "Candidate" -> 
     -2*Log[2] + 2*Log[omega + 2*Q^2] - 2*Log[s] - 2*Log[omega + Q^2 - s23] + 
      2*Log[s - s23] + Log[1 - Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)] + 
      Log[1 + Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.120805|>, 
   <|"Original" -> Log[((omega + 2*Q^2)^2*(s - s23)^2*
        (1 - Sqrt[((omega - s)^2 + 2*(omega - s)*s + s^2 + 4*Q^2*s23)/
           (omega + 2*Q^2)^2])*(1 + Sqrt[((omega - s)^2 + 2*(omega - s)*s + 
            s^2 + 4*Q^2*s23)/(omega + 2*Q^2)^2]))/
       (4*(Q^2*s - 2*Q^2*s23 - (omega - s)*s23)^2)], 
    "Candidate" -> -2*Log[2] + 2*Log[omega + 2*Q^2] + 2*Log[s - s23] - 
      2*Log[Q^2*s - omega*s23 - 2*Q^2*s23 + s*s23] + 
      Log[1 - Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)] + 
      Log[1 + Sqrt[omega^2 + 4*Q^2*s23]/(omega + 2*Q^2)], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.162421|>, 
   <|"Original" -> Log[(Pi*(omega + Q^2))/Q^2], 
    "Candidate" -> Log[Pi] - 2*Log[Q] + Log[omega + Q^2], "Residual" -> 0, 
    "Accepted" -> True, "Seconds" -> 0.002691|>}, 
 "NativeVersion" -> "15.0.0 for Linux x86 (64-bit) (May 31, 2026)", 
 "AcceptedForProduction" -> False|>

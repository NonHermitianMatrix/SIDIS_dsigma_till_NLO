<|"Delta" -> ((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega + Q2)*(-1 + SUNN)*
     (1 + SUNN))/(9*eps*SUNN) + (2*Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*
     Log[2])/(3*SUNN) + (Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*Log[B])/
    (3*SUNN) + (Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi/4])/(3*SUNN), 
 "L0" -> -1/3*(omega*Pi)/SUNN - (Pi*Q2)/(3*SUNN) + (omega*Pi*SUNN)/3 + 
   (Pi*Q2*SUNN)/3, "L1" -> 0, "Regular" -> 
  -((-1/3*(omega*Pi)/SUNN - (Pi*Q2)/(3*SUNN) + (omega*Pi*SUNN)/3 + 
      (Pi*Q2*SUNN)/3)/w) + (Pi*(-1 + SUNN)*(1 + SUNN)*(omega + Q2 - w)*
     (omega - s - w)^2)/(3*(omega - s)^2*SUNN*w), 
 "SoftCoefficients" -> 
  {{1, -1, -1/9*((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega + Q2)*(-1 + SUNN)*
        (1 + SUNN))/SUNN - (2*eps*Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*
       Log[2])/(3*SUNN) - (eps*Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*
       Log[Pi/4])/(3*SUNN)}}, "Assumptions" -> 
  Q2 > 0 && s > 0 && omega > 0 && B > 0 && -Q2 - s < omega - s < 0 && 
   SUNN > 1 && Nc > 1|>

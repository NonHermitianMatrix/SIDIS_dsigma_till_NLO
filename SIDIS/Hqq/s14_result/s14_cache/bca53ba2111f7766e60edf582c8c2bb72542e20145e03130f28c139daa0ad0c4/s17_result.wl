<|"Channel" -> "Hqq", "TensorKey" -> "RealDistinct_Charge0__Ppp", 
 "Ordinary" -> (Pi*(-1 + SUNN)*(1 + SUNN)*(t - w)^2*(Q2 + s + t - w))/
   (3*SUNN*t^2*w), "Branches" -> 
  <|1 -> <|"Delta" -> ((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega + Q2)*
         (-1 + SUNN)*(1 + SUNN))/(9*eps*SUNN) + 
       (Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*Log[B])/(3*SUNN) + 
       (Pi*(omega + Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(3*SUNN), 
     "L0" -> -1/3*(omega*Pi)/SUNN - (Pi*Q2)/(3*SUNN) + (omega*Pi*SUNN)/3 + 
       (Pi*Q2*SUNN)/3, "L1" -> 0, "Regular" -> 
      -((-1/3*(omega*Pi)/SUNN - (Pi*Q2)/(3*SUNN) + (omega*Pi*SUNN)/3 + 
          (Pi*Q2*SUNN)/3)/w) + (Pi*(-1 + SUNN)*(1 + SUNN)*(omega + Q2 - w)*
         (omega - s - w)^2)/(3*(omega - s)^2*SUNN*w), 
     "SoftCoefficients" -> 
      {{1, -1, -1/9*((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega + Q2)*
            (-1 + SUNN)*(1 + SUNN))/SUNN - (eps*Pi*(omega + Q2)*(-1 + SUNN)*
           (1 + SUNN)*Log[Pi])/(3*SUNN)}}, "Assumptions" -> 
      Q2 > 0 && s > 0 && omega > 0 && B > 0 && -Q2 - s < omega - s < 0 && 
       SUNN > 1 && Nc > 1|>, 
   -1 -> <|"Delta" -> -1/9*((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega - Q2)*
          (-1 + SUNN)*(1 + SUNN))/(eps*SUNN) - 
       (Pi*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[B])/(3*SUNN) - 
       (Pi*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*Log[Pi])/(3*SUNN), 
     "L0" -> (omega*Pi)/(3*SUNN) - (Pi*Q2)/(3*SUNN) - (omega*Pi*SUNN)/3 + 
       (Pi*Q2*SUNN)/3, "L1" -> 0, "Regular" -> 
      -(((omega*Pi)/(3*SUNN) - (Pi*Q2)/(3*SUNN) - (omega*Pi*SUNN)/3 + 
          (Pi*Q2*SUNN)/3)/w) + (Pi*(-1 + SUNN)*(1 + SUNN)*(-omega + Q2 - w)*
         (-omega - s - w)^2)/(3*(-omega - s)^2*SUNN*w), 
     "SoftCoefficients" -> 
      {{1, -1, ((-3 - 2*eps + 3*eps*EulerGamma)*Pi*(omega - Q2)*(-1 + SUNN)*
           (1 + SUNN))/(9*SUNN) + (eps*Pi*(omega - Q2)*(-1 + SUNN)*(1 + SUNN)*
           Log[Pi])/(3*SUNN)}}, "Assumptions" -> Q2 > 0 && s > 0 && 
       omega > 0 && B > 0 && -Q2 - s < -omega - s < 0 && SUNN > 1 && 
       Nc > 1|>|>, "InputHash" -> 8532675687169158864045065502706228340267384\
2135163965181640656579490665386180, "CoefficientHash" -> 
  104396794406039396294716553619466296109870356244085071797623099434142488025\
16, "SourceHash" -> 
  453307118739644521026463404478360765074401302794177681298992830849643437185\
44, "Accepted" -> True|>

<|"InputHash" -> 
  172211121500154154231929379499740302130220082635721826437100262235151637083\
28, "Function" -> Log[(2*(-1/4*((-omega^2 + radius^2)*(omega - s))/Q^2 + 
      Q^2*(-1/2*(-omega^2 + radius^2)/Q^2 + s)))/
    (radius*(-1/4*(-omega^2 + radius^2)/Q^2 + s))], 
 "Assumptions" -> Q > 0 && mu > 0 && Inequality[s, Greater, 
    (-omega^2 + radius^2)/(4*Q^2), GreaterEqual, 0] && omega - s < 0 && 
   omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2) > 0 && 
   (-omega^2 + radius^2)/4 + (omega - s)*s < 0 && B > 0 && omega != 0 && 
   (-omega^2 + radius^2)/(4*Q^2) > 0 && Element[nf, Integers] && nf >= 0 && 
   alphaS > 0 && Element[eq, Reals] && omega > 0 && radius > 0, 
 "Value" -> Log[2] - Log[radius] - Log[omega^2 - radius^2 + 4*Q^2*s] + 
   Log[omega^3 + 2*omega^2*Q^2 - omega*radius^2 - 2*Q^2*radius^2 - 
     omega^2*s + 4*Q^4*s + radius^2*s]|>

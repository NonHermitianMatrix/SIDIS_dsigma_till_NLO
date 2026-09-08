<|"InputHash" -> 
  524731851600252029320150748515633058493619995660498299994419083897517769401\
83, "Function" -> Log[(Q^2*(-1/4*(-omega^2 + radius^2)/Q^2 + s)^2)/
    ((omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2))*s^2)], 
 "Assumptions" -> Q > 0 && mu > 0 && Inequality[s, Greater, 
    (-omega^2 + radius^2)/(4*Q^2), GreaterEqual, 0] && omega - s < 0 && 
   omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2) > 0 && 
   (-omega^2 + radius^2)/4 + (omega - s)*s < 0 && B > 0 && omega != 0 && 
   (-omega^2 + radius^2)/(4*Q^2) > 0 && Element[nf, Integers] && nf >= 0 && 
   alphaS > 0 && Element[eq, Reals] && omega > 0 && radius > 0, 
 "Value" -> -2*Log[2] - Log[omega + 2*Q^2 - radius] - 
   Log[omega + 2*Q^2 + radius] - 2*Log[s] + 
   2*Log[omega^2 - radius^2 + 4*Q^2*s]|>

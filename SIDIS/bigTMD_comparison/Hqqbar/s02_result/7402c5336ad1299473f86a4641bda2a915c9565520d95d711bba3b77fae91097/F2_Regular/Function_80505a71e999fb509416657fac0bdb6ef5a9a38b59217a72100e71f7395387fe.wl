<|"InputHash" -> 
  524731851600252029320150748515633058493619995660498299994419083897517769401\
83, "Function" -> Log[(2*Q^2 + radius + s + t)/(2*Q^2 - radius + s + t)], 
 "Assumptions" -> Q^2 > 0 && s > (radius^2 - s^2 - 2*s*t - t^2)/(4*Q^2) > 
    0 && -Q^2 - s + (radius^2 - s^2 - 2*s*t - t^2)/(4*Q^2) < t < 
    -1/4*(radius^2 - s^2 - 2*s*t - t^2)/s && mu > 0 && mu^2 > 0 && B > 0 && 
   Q > 0 && alphaS > 0 && Element[nf, Integers] && nf >= 1 && 
   Element[eq | eqp | eq2 | chargeSum | otherChargeMoment[1] | 
     otherChargeMoment[2], Reals] && radius > 0, 
 "Value" -> -Log[2*Q^2 - radius + s + t] + Log[2*Q^2 + radius + s + t]|>

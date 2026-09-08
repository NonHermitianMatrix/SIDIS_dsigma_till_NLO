<|"InputHash" -> 
  468115366208831432455361714392407686132954903798962052334609846425061017822\
80, "Function" -> Log[(Q^2*(-omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2))*
     (-1/4*(-omega^2 + radius^2)/Q^2 + s)^2)/
    ((omega^2 - radius^2)/2 - ((-omega^2 + radius^2)*(-omega - s))/(4*Q^2) + 
      Q^2*s)^2], "Assumptions" -> Q > 0 && mu > 0 && 
   Inequality[s, Greater, (-omega^2 + radius^2)/(4*Q^2), GreaterEqual, 0] && 
   -omega - s < 0 && -omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2) > 0 && 
   (-omega^2 + radius^2)/4 + (-omega - s)*s < 0 && B > 0 && -omega != 0 && 
   (-omega^2 + radius^2)/(4*Q^2) > 0 && Element[nf, Integers] && nf >= 0 && 
   alphaS > 0 && Element[eq, Reals] && omega > 0 && radius > 0, 
 "Value" -> -2*Log[2] + Log[-omega + 2*Q^2 - radius] + 
   Log[-omega + 2*Q^2 + radius] + 2*Log[omega^2 - radius^2 + 4*Q^2*s] - 
   2*Log[-omega^3 + 2*omega^2*Q^2 + omega*radius^2 - 2*Q^2*radius^2 - 
      omega^2*s + 4*Q^4*s + radius^2*s]|>

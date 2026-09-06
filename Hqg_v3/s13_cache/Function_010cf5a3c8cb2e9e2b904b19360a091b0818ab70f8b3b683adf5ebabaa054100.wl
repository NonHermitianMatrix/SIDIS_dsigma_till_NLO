<|"InputHash" -> 
  468115366208831432455361714392407686132954903798962052334609846425061017822\
80, "Function" -> Log[((-omega^2 + radius^2)/4 + (-omega - s)*s)/
    (((-omega^2 + radius^2)/(4*Q^2) - s)*(omega + (-omega^2 + radius^2)/
       (4*Q^2) + s))], "Assumptions" -> Q > 0 && mu > 0 && 
   Inequality[s, Greater, (-omega^2 + radius^2)/(4*Q^2), GreaterEqual, 0] && 
   -omega - s < 0 && -omega + Q^2 - (-omega^2 + radius^2)/(4*Q^2) > 0 && 
   (-omega^2 + radius^2)/4 + (-omega - s)*s < 0 && B > 0 && -omega != 0 && 
   (-omega^2 + radius^2)/(4*Q^2) > 0 && Element[nf, Integers] && nf >= 0 && 
   alphaS > 0 && Element[eq, Reals] && omega > 0 && radius > 0, 
 "Value" -> 2*Log[2] + 4*Log[Q] + Log[omega - radius + 2*s] + 
   Log[omega + radius + 2*s] - Log[omega^2 - radius^2 + 4*Q^2*s] - 
   Log[-omega^2 + 4*omega*Q^2 + radius^2 + 4*Q^2*s]|>

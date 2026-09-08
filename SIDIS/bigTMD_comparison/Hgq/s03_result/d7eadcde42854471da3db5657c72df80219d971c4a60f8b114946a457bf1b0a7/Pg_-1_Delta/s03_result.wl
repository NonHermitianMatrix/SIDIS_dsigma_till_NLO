<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Pg_-1_Delta", 
 "InputHash" -> 9766222903487030372796892120568081491165525353924891665459609\
7947491380605095, "S02Difference" -> 
  -1/3*(alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
       16*Q^2*s + 7*s^2)*Log[Q]^2)/(Pi^3*(omega - Q^2)*(omega + s)) + 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*Log[Q]*Log[omega + s])/(3*Pi^3*(omega - Q^2)*
     (omega + s)) - (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 
      16*omega*s - 16*Q^2*s + 7*s^2)*Log[omega + s]^2)/
    (12*Pi^3*(omega - Q^2)*(omega + s)) - 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (-omega + Q^2 - s)/Q^2])/
    (6*Pi^3*(omega - Q^2)*(omega + s)) - 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (omega - Q^2 + s)/(omega + s)])/
    (6*Pi^3*(omega - Q^2)*(omega + s)), 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
   -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "SelectedArgument" -> (omega - Q^2 + s)/(omega + s), "Coverage" -> True, 
 "Regions" -> {<|"Region" -> (omega - Q^2 + s)/(omega + s) < 0, 
    "Domain" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
      -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
      Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
      Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals] && 
      (omega - Q^2 + s)/(omega + s) < 0, "Map" -> {}, "Empty" -> False, 
    "Difference" -> 0|>, <|"Region" -> (omega - Q^2 + s)/(omega + s) == 0, 
    "Domain" -> Q^2 > 0 && -omega + Q^2 > 0 && omega - 2*Q^2 < -Q^2 && 
      -Q^2 < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
      Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
      Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
    "Map" -> {s -> -omega + Q^2}, "Empty" -> False, "Difference" -> 0|>, 
   <|"Region" -> (omega - Q^2 + s)/(omega + s) > 0, 
    "Domain" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
      -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
      Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
      Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals] && 
      (omega - Q^2 + s)/(omega + s) > 0, "Map" -> {}, "Empty" -> False, 
    "Difference" -> 0|>}, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "NormalizedDifference" -> 0``90.62131156389428, 
    "OriginalDifference" -> 0``86.84671698270692, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "NormalizedDifference" -> 0``90.91954276438533, 
    "OriginalDifference" -> 0``86.57720572174868, "Equal" -> True|>}, 
 "Equal" -> True, "Difference" -> 0|>

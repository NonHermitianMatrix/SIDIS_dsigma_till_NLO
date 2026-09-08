<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Ppp_-1_Delta", 
 "InputHash" -> 9766222903487030372796892120568081491165525353924891665459609\
7947491380605095, "S02Difference" -> 
  (-17*alphaS^2*eq^2*s*Log[Q]^2)/(6*Pi^3) + 
   (17*alphaS^2*eq^2*s*Log[Q]*Log[omega + s])/(6*Pi^3) - 
   (17*alphaS^2*eq^2*s*Log[omega + s]^2)/(24*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (-omega + Q^2 - s)/Q^2])/(12*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (omega - Q^2 + s)/(omega + s)])/(12*Pi^3), 
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
      s23 -> 1/7}, "NormalizedDifference" -> 0``90.04005341135803, 
    "OriginalDifference" -> 0``86.15157140941447, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "NormalizedDifference" -> 0``90.20900772116715, 
    "OriginalDifference" -> 0``85.96543503238915, "Equal" -> True|>}, 
 "Equal" -> True, "Difference" -> 0|>

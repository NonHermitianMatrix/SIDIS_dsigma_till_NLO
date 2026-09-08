<|"Completed" -> True, "Channel" -> "Hqg", "Label" -> "F2_1_Delta", 
 "InputHash" -> 9766222903487030372796892120568081491165525353924891665459609\
7947491380605095, "S02Difference" -> 
  (8*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s - 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 - 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[Q]^2)/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^3) - 
   (8*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s - 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 - 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[Q]*Log[-omega + s])/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^3) + 
   (2*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s - 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 - 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[-omega + s]^2)/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^3) + 
   (4*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s - 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 - 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*
     PolyLog[2, (omega + Q^2 - s)/Q^2])/(9*Pi^3*(omega + Q^2)*s*
     (Q^2 + s)^3) + (4*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 
      6*omega^2*Q^2*s - 10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 
      10*omega*Q^2*s^2 + 14*Q^4*s^2 - 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*
     PolyLog[2, (omega + Q^2 - s)/(omega - s)])/(9*Pi^3*(omega + Q^2)*s*
     (Q^2 + s)^3), "Assumptions" -> Q > 0 && mu > 0 && s > 0 && 
   omega - s < 0 && omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && 
   omega != 0 && Element[nf, Integers] && nf >= 0 && alphaS > 0 && 
   Element[eq, Reals] && omega > 0, "SelectedArgument" -> 
  (omega + Q^2 - s)/Q^2, "Coverage" -> True, 
 "Regions" -> {<|"Region" -> (omega + Q^2 - s)/Q^2 < 0, 
    "Domain" -> Q > 0 && mu > 0 && s > 0 && omega - s < 0 && 
      omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && omega != 0 && 
      Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
      omega > 0 && (omega + Q^2 - s)/Q^2 < 0, "Map" -> {}, "Empty" -> False, 
    "Difference" -> 0|>, <|"Region" -> (omega + Q^2 - s)/Q^2 == 0, 
    "Domain" -> Q > 0 && mu > 0 && omega + Q^2 > 0 && -Q^2 < 0 && 
      omega + Q^2 > 0 && -(Q^2*(omega + Q^2)) < 0 && B > 0 && omega != 0 && 
      Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
      omega > 0, "Map" -> {s -> omega + Q^2}, "Empty" -> False, 
    "Difference" -> 0|>, <|"Region" -> (omega + Q^2 - s)/Q^2 > 0, 
    "Domain" -> Q > 0 && mu > 0 && s > 0 && omega - s < 0 && 
      omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && omega != 0 && 
      Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
      omega > 0 && (omega + Q^2 - s)/Q^2 > 0, "Map" -> {}, "Empty" -> False, 
    "Difference" -> 0|>}, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "NormalizedDifference" -> 0``91.04095140380484, 
    "OriginalDifference" -> 0``86.65626268420235, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "NormalizedDifference" -> 0``90.88569992445241, 
    "OriginalDifference" -> 0``86.1597452932302, "Equal" -> True|>}, 
 "Equal" -> True, "Difference" -> 0|>

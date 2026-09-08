<|"Completed" -> True, "Channel" -> "Hqg", "Label" -> "F1_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  (4*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s - 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 - 2*omega*Q^2*s^2 + 10*Q^4*s^2 - 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*Log[Q]^2)/(9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^2) - 
   (4*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s - 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 - 2*omega*Q^2*s^2 + 10*Q^4*s^2 - 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*Log[Q]*Log[-omega + s])/(9*Pi^3*(omega + Q^2)*s*
     (Q^2 + s)^2) + (alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s - 
      6*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 2*omega*Q^2*s^2 + 
      10*Q^4*s^2 - 4*omega*s^3 + 6*Q^2*s^3 + 3*s^4)*Log[-omega + s]^2)/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^2) + 
   (2*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s - 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 - 2*omega*Q^2*s^2 + 10*Q^4*s^2 - 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*PolyLog[2, (omega + Q^2 - s)/Q^2])/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^2) + 
   (2*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s - 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 - 2*omega*Q^2*s^2 + 10*Q^4*s^2 - 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*PolyLog[2, (omega + Q^2 - s)/(omega - s)])/
    (9*Pi^3*(omega + Q^2)*s*(Q^2 + s)^2), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0480009565439612008273967976380848359684140\
823157213350725234621782233207427758932972150245423492641675690332953477`85.5\
8566166862992, 0.048000956543961200827396797638084835968414082315721335072523\
4621782233207427758932972150245407616646444159818930662`85.59380184366489}, 
    "Difference" -> 0``86.60743279698708, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0416162715261246440842194750394028576428441\
02469254918713880935433984078633459664172781857988354`84.86759141793837, 0.04\
16162715261246440842194750394028576428441024692549187138809354339840786334596\
641727818579818451812317049739984546`85.46595443991531}, 
    "Difference" -> 0``86.15067632068812, "Equal" -> True|>}, 
 "Assumptions" -> Q > 0 && mu > 0 && s > 0 && omega - s < 0 && 
   omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && omega != 0 && 
   Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
   omega > 0, "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 1239251746998484\
2762687564530573964865728576936772697033059573108215213091816|>

<|"Completed" -> True, "Channel" -> "Hqg", "Label" -> "F1_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  (-4*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s + 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 + 2*omega*Q^2*s^2 + 10*Q^4*s^2 + 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*Log[Q]^2)/(9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^2) + 
   (4*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s + 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 + 2*omega*Q^2*s^2 + 10*Q^4*s^2 + 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*Log[Q]*Log[omega + s])/(9*Pi^3*(omega - Q^2)*s*
     (Q^2 + s)^2) - (alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s + 
      6*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 + 2*omega*Q^2*s^2 + 
      10*Q^4*s^2 + 4*omega*s^3 + 6*Q^2*s^3 + 3*s^4)*Log[omega + s]^2)/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^2) - 
   (2*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s + 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 + 2*omega*Q^2*s^2 + 10*Q^4*s^2 + 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*PolyLog[2, (-omega + Q^2 - s)/Q^2])/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^2) - 
   (2*alphaS^2*eq^2*(3*omega^2*Q^4 + Q^8 + 2*omega^2*Q^2*s + 6*omega*Q^4*s + 
      4*Q^6*s + 3*omega^2*s^2 + 2*omega*Q^2*s^2 + 10*Q^4*s^2 + 4*omega*s^3 + 
      6*Q^2*s^3 + 3*s^4)*PolyLog[2, (omega - Q^2 + s)/(omega + s)])/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^2), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0942002467343951444876164034064207064545459\
287878989304601469275010838000542651802088837775065110520210609522847807`85.7\
1777827074062, 0.094200246734395144487616403406420706454545928787898930460146\
9275010838000542651802088837775087122167160408713741461`85.76785340457934}, 
    "Difference" -> 0``86.46701247912013, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0652567393680573082661025670668800827478476\
62455267820532710342359949956227691428957735621728391`85.18196665840779, 0.06\
52567393680573082661025670668800827478476624552678205327103423599499562276914\
289577356217278366714646078319535315`85.55467600306376}, 
    "Difference" -> 0``86.21385368918394, "Equal" -> True|>}, 
 "Assumptions" -> Q > 0 && mu > 0 && s > 0 && -omega - s < 0 && 
   -omega + Q^2 > 0 && (-omega - s)*s < 0 && B > 0 && -omega != 0 && 
   Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
   omega > 0, "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 9312257651630517\
4566744195042512376066834023266103061651014323537211194023419|>

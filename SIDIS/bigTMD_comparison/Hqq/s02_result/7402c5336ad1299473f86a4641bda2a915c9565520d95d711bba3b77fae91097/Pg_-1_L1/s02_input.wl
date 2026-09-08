<|"Definition" -> <|"Channel" -> "Hqq", "Label" -> "Pg_-1_L1", 
   "Left" -> (alphaS^2*eq^2*(-56*omega^2 + 112*omega*Q^2 - 112*Q^4 - 
       112*omega*s - 112*s^2))/(9*Pi^3*s*(omega + s)), 
   "Right" -> (alphaS^2*eq^2*(-112*Q^6*(-omega - s)^5*s^5 + 
       (-omega - s)^2*s^2*(-56*(-omega - s)^6*s^3 - 56*(-omega - s)^5*s^4 - 
         56*(-omega - s)^4*s^5 - 56*(-omega - s)^3*s^6) - 
       Q^2*(-omega - s)*s*(168*(-omega - s)^6*s^4 + 224*(-omega - s)^5*s^5 + 
         168*(-omega - s)^4*s^6) + Q^4*(-224*(-omega - s)^6*s^5 - 
         224*(-omega - s)^5*s^6)))/(9*Pi^3*(-omega + Q^2)*(-omega - s)^3*s^6*
      (omega + s)^3), "Assumptions" -> Q^2 > 0 && s > 0 && 
     -Q^2 - s < -omega - s && -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
     omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
     Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
   "Kind" -> "L1"|>, "Difference" -> 
  (alphaS^2*eq^2*(-56*omega^2 + 112*omega*Q^2 - 112*Q^4 - 112*omega*s - 
      112*s^2))/(9*Pi^3*s*(omega + s)) - 
   (alphaS^2*eq^2*(-112*Q^6*(-omega - s)^5*s^5 + (-omega - s)^2*s^2*
       (-56*(-omega - s)^6*s^3 - 56*(-omega - s)^5*s^4 - 
        56*(-omega - s)^4*s^5 - 56*(-omega - s)^3*s^6) - 
      Q^2*(-omega - s)*s*(168*(-omega - s)^6*s^4 + 224*(-omega - s)^5*s^5 + 
        168*(-omega - s)^4*s^6) + Q^4*(-224*(-omega - s)^6*s^5 - 
        224*(-omega - s)^5*s^6)))/(9*Pi^3*(-omega + Q^2)*(-omega - s)^3*s^6*
     (omega + s)^3), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.007945967271353481330824162745447251313074\
3698665481340120935798661784660439143096110339428271558057896525336400318`89.\
07445639140934, -0.0079459672713534813308241627454472513130743698665481340120\
935798661784660439143096110339428271558057878449317406416`87.78209011718253}, 
    "Difference" -> 0``89.86033754527064, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.009295970894496700352846839375158442480040\
5765836708526988421319556873584891303632337249137258511544263639079778536`89.\
05733765680641, -0.0092959708944967003528468393751584424800405765836708526988\
421319556873584891303632337249137258511544266737825891778`87.89953726989805}, 
    "Difference" -> 0``89.90204776344362, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

<|"Completed" -> True, "Channel" -> "Hqg", "Label" -> "F2_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
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
     (Q^2 + s)^3), "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0320512058197990666476386226580709297606436\
915117435293216085505129875225784820085076200938376199422925894803415882`85.6\
5269539257301, 0.032051205819799066647638622658070929760643691511743529321608\
5505129875225784820085076200938364819651700420139190779`85.33161820689334}, 
    "Difference" -> 0``86.65626268420235, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0384364159188002149282488059094439922214173\
43032161303477953459332385395180465574384841752605881`84.94666261103775, 0.03\
84364159188002149282488059094439922214173430321613034779534593323853951804655\
74384841752590887`85.17371898585405}, "Difference" -> 0``86.1597452932302, 
    "Equal" -> True|>}, "Assumptions" -> Q > 0 && mu > 0 && s > 0 && 
   omega - s < 0 && omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && 
   omega != 0 && Element[nf, Integers] && nf >= 0 && alphaS > 0 && 
   Element[eq, Reals] && omega > 0, "AlgebraicMap" -> {}, 
 "FreshDifferenceHash" -> 642996491451193374541316871300543140000078958777105\
28213073269235138620017642|>

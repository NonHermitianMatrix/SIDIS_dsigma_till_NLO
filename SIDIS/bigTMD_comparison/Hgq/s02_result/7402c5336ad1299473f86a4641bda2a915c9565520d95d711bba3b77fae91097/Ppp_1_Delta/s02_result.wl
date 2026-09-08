<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Ppp_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> (-17*alphaS^2*eq^2*s*Log[Q]^2)/(6*Pi^3) + 
   (17*alphaS^2*eq^2*s*Log[Q]*Log[-omega + s])/(6*Pi^3) - 
   (17*alphaS^2*eq^2*s*Log[-omega + s]^2)/(24*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (omega + Q^2 - s)/Q^2])/(12*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (omega + Q^2 - s)/(omega - s)])/(12*Pi^3), 
 "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0567308966028696609142013053405385127926961\
790789480247791897688988275184732825969996557241282257839381844409400566`85.5\
5848706511456, 0.056730896602869660914201305340538512792696179078948024779189\
7688988275184732825969996557241390050698915179407205877`85.2788953892543}, 
    "Difference" -> 0``86.3417201535829, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0479065809637688809503694395513665205944508\
75563118553050610278955488547146623886888597293962904`84.8164068136151, 0.047\
90658096376888095036943955136652059445087556311855305061027895548854714662388\
6888597293933493`85.09009718096682}, "Difference" -> 0``85.95061462109825, 
    "Equal" -> True|>}, "Assumptions" -> Q^2 > 0 && s > 0 && 
   -Q^2 - s < omega - s && omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
   omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 35587315668760774728862875608\
535740629960219736058703545492508603935366486030|>

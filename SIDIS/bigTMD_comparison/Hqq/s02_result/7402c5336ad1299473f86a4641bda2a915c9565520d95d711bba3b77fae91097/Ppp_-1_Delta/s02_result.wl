<|"Completed" -> True, "Channel" -> "Hqq", "Label" -> "Ppp_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> (32*alphaS^2*eq^2*(omega - Q^2)*Log[Q]^2)/
    (9*Pi^3) - (32*alphaS^2*eq^2*(omega - Q^2)*Log[Q]*Log[omega + s])/
    (9*Pi^3) + (8*alphaS^2*eq^2*(omega - Q^2)*Log[omega + s]^2)/(9*Pi^3) + 
   (16*alphaS^2*eq^2*(omega - Q^2)*PolyLog[2, (-omega + Q^2 - s)/Q^2])/
    (9*Pi^3) + (16*alphaS^2*eq^2*(omega - Q^2)*
     PolyLog[2, (omega - Q^2 + s)/(omega + s)])/(9*Pi^3), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0148837840638906823993133354420751938238056\
873546931245216967144338736092083992400875088679240993368457683935320184`86.4\
176584475718, 0.0148837840638906823993133354420751938238056873546931245216967\
14433873609208399240087508867924091742102789563841713`86.15101284177607}, 
    "Difference" -> 0``87.79044167256656, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0272007539977086517984384016600594649234464\
607511933174499047117157392572325512959443200564462850792976860833746996`86.4\
8251740495957, 0.027200753997708651798438401660059464923446460751193317449904\
711715739257232551295944320056430071479674087115712932`86.33706574303486}, 
    "Difference" -> 0``87.66811964384772, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
   -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 65108983255985489076943652659\
096039062954683188468532430743226194496992117528|>

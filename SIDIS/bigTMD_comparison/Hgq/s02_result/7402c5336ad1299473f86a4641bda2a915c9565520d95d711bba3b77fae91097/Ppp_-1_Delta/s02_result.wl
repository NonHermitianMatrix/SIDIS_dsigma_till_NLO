<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Ppp_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> (-17*alphaS^2*eq^2*s*Log[Q]^2)/(6*Pi^3) + 
   (17*alphaS^2*eq^2*s*Log[Q]*Log[omega + s])/(6*Pi^3) - 
   (17*alphaS^2*eq^2*s*Log[omega + s]^2)/(24*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (-omega + Q^2 - s)/Q^2])/(12*Pi^3) - 
   (17*alphaS^2*eq^2*s*PolyLog[2, (omega - Q^2 + s)/(omega + s)])/(12*Pi^3), 
 "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0769852271229447753849635286708162514637440\
869666558624702170312423050364519702320521170425420357974143155728946301`85.5\
7493035170934, 0.076985227122944775384963528670816251463744086966655862470217\
031242305036451970232052117042559733`85.18698641542129}, 
    "Difference" -> 0``86.15157140941447, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0625892165038191612455699219065804496761861\
64938070524815087751971286760794694933912542253997686`85.09445796848588, 0.06\
25892165038191612455699219065804496761861649380705248150877519712867607946949\
33912542253947936`85.03360130128095}, "Difference" -> 0``85.96543503238915, 
    "Equal" -> True|>}, "Assumptions" -> Q^2 > 0 && s > 0 && 
   -Q^2 - s < -omega - s && -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
   omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 49108102402943605153757418885\
078123785795642363881068664902226545589880047646|>

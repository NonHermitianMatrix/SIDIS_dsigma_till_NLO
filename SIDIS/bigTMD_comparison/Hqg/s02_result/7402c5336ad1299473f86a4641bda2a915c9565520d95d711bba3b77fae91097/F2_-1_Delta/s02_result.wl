<|"Completed" -> True, "Channel" -> "Hqg", "Label" -> "F2_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  (-8*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s + 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 + 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[Q]^2)/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^3) + 
   (8*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s + 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 + 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[Q]*Log[omega + s])/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^3) - 
   (2*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s + 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 + 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*Log[omega + s]^2)/
    (9*Pi^3*(omega - Q^2)*s*(Q^2 + s)^3) - 
   (4*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 6*omega^2*Q^2*s + 
      10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 10*omega*Q^2*s^2 + 
      14*Q^4*s^2 + 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*
     PolyLog[2, (-omega + Q^2 - s)/Q^2])/(9*Pi^3*(omega - Q^2)*s*
     (Q^2 + s)^3) - (4*alphaS^2*eq^2*Q^2*(3*omega^2*Q^4 + Q^8 - 
      6*omega^2*Q^2*s + 10*omega*Q^4*s + 4*Q^6*s + 3*omega^2*s^2 - 
      10*omega*Q^2*s^2 + 14*Q^4*s^2 + 4*omega*s^3 + 2*Q^2*s^3 + 3*s^4)*
     PolyLog[2, (omega - Q^2 + s)/(omega + s)])/(9*Pi^3*(omega - Q^2)*s*
     (Q^2 + s)^3), "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0608664669619750153098178545823550204177103\
379842066758455370950720011046991548063964205658285124314697036903125635`85.7\
7054168295174, 0.060866466961975015309817854582355020417710337984206675845537\
0950720011046991548063964205658322855817681979392264353`85.51773888428978}, 
    "Difference" -> 0``86.54059161336518, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0594721350175305898300604935414729781392637\
858478904116329391606045542011944645210235824921065663507125497710563722`85.2\
5521470197933, 0.059472135017530589830060493541472978139263785847890411632939\
1606045542011944645210235824920995524098376573870099604`85.27560842861183}, 
    "Difference" -> 0``86.1899483440934, "Equal" -> True|>}, 
 "Assumptions" -> Q > 0 && mu > 0 && s > 0 && -omega - s < 0 && 
   -omega + Q^2 > 0 && (-omega - s)*s < 0 && B > 0 && -omega != 0 && 
   Element[nf, Integers] && nf >= 0 && alphaS > 0 && Element[eq, Reals] && 
   omega > 0, "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 9394930790632600\
0333188005404820489268458365680147190368399815093777079063985|>

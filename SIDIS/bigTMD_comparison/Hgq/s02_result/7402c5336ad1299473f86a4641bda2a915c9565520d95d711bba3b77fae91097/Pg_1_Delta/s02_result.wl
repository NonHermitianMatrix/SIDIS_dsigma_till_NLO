<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Pg_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  -1/3*(alphaS^2*eq^2*(17*omega^2 + 16*omega*Q^2 + 8*Q^4 - 16*omega*s - 
       16*Q^2*s + 7*s^2)*Log[Q]^2)/(Pi^3*(omega + Q^2)*(omega - s)) + 
   (alphaS^2*eq^2*(17*omega^2 + 16*omega*Q^2 + 8*Q^4 - 16*omega*s - 
      16*Q^2*s + 7*s^2)*Log[Q]*Log[-omega + s])/(3*Pi^3*(omega + Q^2)*
     (omega - s)) - (alphaS^2*eq^2*(17*omega^2 + 16*omega*Q^2 + 8*Q^4 - 
      16*omega*s - 16*Q^2*s + 7*s^2)*Log[-omega + s]^2)/
    (12*Pi^3*(omega + Q^2)*(omega - s)) - 
   (alphaS^2*eq^2*(17*omega^2 + 16*omega*Q^2 + 8*Q^4 - 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (omega + Q^2 - s)/Q^2])/
    (6*Pi^3*(omega + Q^2)*(omega - s)) - 
   (alphaS^2*eq^2*(17*omega^2 + 16*omega*Q^2 + 8*Q^4 - 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (omega + Q^2 - s)/(omega - s)])/
    (6*Pi^3*(omega + Q^2)*(omega - s)), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.005149544947693745586859668103583871625656\
0816201311523485688002172272445308954368392881982485604683076874250590152`84.\
88382862873148, -0.0051495449476937455868596681035838716256560816201311523485\
688002172272445308954368392881982489121292615547744516766`85.2264866204359}, 
    "Difference" -> 0``87.00940599896131, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.001667764089016012715730994832209889888522\
1820697065789656781831494302140780357219904199843885070852987241061051933`83.\
74789667660116, -0.0016677640890160127157309948322098898885221820697065789656\
781831494302140780357219904199843885077373021042499004987`84.59046766656309}, 
    "Difference" -> 0``86.46745342486328, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < omega - s && 
   omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 86495837913624370466210829047\
884406731071940180470120551973408315144585754654|>

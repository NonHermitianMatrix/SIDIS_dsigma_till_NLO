<|"Completed" -> True, "Channel" -> "Hqq", "Label" -> "Ppp_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> (-32*alphaS^2*eq^2*(omega + Q^2)*Log[Q]^2)/
    (9*Pi^3) + (32*alphaS^2*eq^2*(omega + Q^2)*Log[Q]*Log[-omega + s])/
    (9*Pi^3) - (8*alphaS^2*eq^2*(omega + Q^2)*Log[-omega + s]^2)/(9*Pi^3) - 
   (16*alphaS^2*eq^2*(omega + Q^2)*PolyLog[2, (omega + Q^2 - s)/Q^2])/
    (9*Pi^3) - (16*alphaS^2*eq^2*(omega + Q^2)*
     PolyLog[2, (omega + Q^2 - s)/(omega - s)])/(9*Pi^3), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0254338587780822090311143911173642594275910\
097389621236700012541438735734537821217345297104804999891260874204505308`86.6\
7818146495834, 0.025433858778082209031114391117364259427591009738962123670001\
254143873573453782121734529710488212168939459157323057`86.25554309702744}, 
    "Difference" -> 0``87.71091732643944, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0376885284570022576744464895967777971253914\
575261933137129774458938394118131961160399892946679258370851400467366224`86.6\
5266293511961, 0.037688528457002257674446489596777797125391457526193313712977\
4458938394118131961160399892946679227888910266317386112`86.2619026976479}, 
    "Difference" -> 0``87.53750197755073, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < omega - s && 
   omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 49986196539504204672278863480\
326442610048738950506344393964830500153545805999|>

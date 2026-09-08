<|"Definition" -> <|"Channel" -> "Hgq", "Label" -> "Pg_-1_L1", 
   "Left" -> (alphaS^2*eq^2*(88*omega^2 - 88*omega*Q^2 + 44*Q^4 + 
       88*omega*s - 88*Q^2*s + 44*s^2))/(6*Pi^3*(omega - Q^2)*(omega + s)), 
   "Right" -> (alphaS^2*eq^2*(-176*Q^6*(-omega - s)^5*s^5 - 
       (-omega - s)^2*s^3*(352*(-omega - s)^6*s^2 + 704*(-omega - s)^5*s^3 + 
         528*(-omega - s)^4*s^4 + 176*(-omega - s)^3*s^5) + 
       Q^2*(-omega - s)*s*(-704*(-omega - s)^6*s^4 - 704*(-omega - s)^5*s^5 - 
         176*(-omega - s)^4*s^6) + Q^4*(-528*(-omega - s)^6*s^5 - 
         176*(-omega - s)^5*s^6)))/(24*Pi^3*(-omega + Q^2)^2*(-omega - s)^3*
      s^5*(omega + s)^3), "Assumptions" -> Q^2 > 0 && s > 0 && 
     -Q^2 - s < -omega - s && -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
     omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
     Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
   "Kind" -> "L1"|>, "Difference" -> 
  (alphaS^2*eq^2*(88*omega^2 - 88*omega*Q^2 + 44*Q^4 + 88*omega*s - 
      88*Q^2*s + 44*s^2))/(6*Pi^3*(omega - Q^2)*(omega + s)) - 
   (alphaS^2*eq^2*(-176*Q^6*(-omega - s)^5*s^5 - (-omega - s)^2*s^3*
       (352*(-omega - s)^6*s^2 + 704*(-omega - s)^5*s^3 + 
        528*(-omega - s)^4*s^4 + 176*(-omega - s)^3*s^5) + 
      Q^2*(-omega - s)*s*(-704*(-omega - s)^6*s^4 - 704*(-omega - s)^5*s^5 - 
        176*(-omega - s)^4*s^6) + Q^4*(-528*(-omega - s)^6*s^5 - 
        176*(-omega - s)^5*s^6)))/(24*Pi^3*(-omega + Q^2)^2*(-omega - s)^3*
     s^5*(omega + s)^3), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.006370673468286318851243862259469370586284\
1157822178917006581179685104319594065164519951436660870163036572791574599`88.\
71130373940974, -0.0063706734682863188512438622594693705862841157822178917006\
5811796851043195940651645199514366608701630365727915746`86.99566715984771}, 
    "Difference" -> 0``89.18320236524234, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.001715531355388530147799240051299966222163\
6511784972465508200789100917377490687547874301208300820036760562816016874`88.\
37608119979477, -0.0017155313553885301477992400512999662221636511784972465508\
200789100917377490687547874301208300820036760562816016871`86.81113294503461}, 
    "Difference" -> 0``89.56506648165103, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

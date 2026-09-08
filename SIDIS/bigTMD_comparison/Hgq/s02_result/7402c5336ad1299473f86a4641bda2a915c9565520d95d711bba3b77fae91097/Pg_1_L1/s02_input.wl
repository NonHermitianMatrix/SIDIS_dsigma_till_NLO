<|"Definition" -> <|"Channel" -> "Hgq", "Label" -> "Pg_1_L1", 
   "Left" -> (alphaS^2*eq^2*(88*omega^2 + 88*omega*Q^2 + 44*Q^4 - 
       88*omega*s - 88*Q^2*s + 44*s^2))/(6*Pi^3*(omega + Q^2)*(omega - s)), 
   "Right" -> (alphaS^2*eq^2*(-176*Q^6*(omega - s)^5*s^5 - 
       (omega - s)^2*s^3*(352*(omega - s)^6*s^2 + 704*(omega - s)^5*s^3 + 
         528*(omega - s)^4*s^4 + 176*(omega - s)^3*s^5) + 
       Q^2*(omega - s)*s*(-704*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
         176*(omega - s)^4*s^6) + Q^4*(-528*(omega - s)^6*s^5 - 
         176*(omega - s)^5*s^6)))/(24*Pi^3*(omega + Q^2)^2*(omega - s)^3*s^5*
      (-omega + s)^3), "Assumptions" -> Q^2 > 0 && s > 0 && 
     -Q^2 - s < omega - s && omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
     omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
     Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
   "Kind" -> "L1"|>, "Difference" -> 
  (alphaS^2*eq^2*(88*omega^2 + 88*omega*Q^2 + 44*Q^4 - 88*omega*s - 
      88*Q^2*s + 44*s^2))/(6*Pi^3*(omega + Q^2)*(omega - s)) - 
   (alphaS^2*eq^2*(-176*Q^6*(omega - s)^5*s^5 - (omega - s)^2*s^3*
       (352*(omega - s)^6*s^2 + 704*(omega - s)^5*s^3 + 
        528*(omega - s)^4*s^4 + 176*(omega - s)^3*s^5) + 
      Q^2*(omega - s)*s*(-704*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
        176*(omega - s)^4*s^6) + Q^4*(-528*(omega - s)^6*s^5 - 
        176*(omega - s)^5*s^6)))/(24*Pi^3*(omega + Q^2)^2*(omega - s)^3*s^5*
     (-omega + s)^3), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.002429350149239849588607659474944319983569\
676151619089368517628985325311387187018273694148118001182217127975785378`88.5\
3726933683629, -0.00242935014923984958860765947494431998356967615161908936851\
76289853253113871870182736941481180011822171776848376114`87.01910280154416}, 
    "Difference" -> 0``89.62063748719812, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.000551758903259050718897959794541398935260\
3541657357679766029760792267368369440011662733725002754674465293976833501`87.\
99138280074985, -0.0005517589032590507188979597945413989352603541657357679766\
029760792267368369440011662733725002754674465530405143764`86.59290064309127}, 
    "Difference" -> 0``89.83413879343989, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

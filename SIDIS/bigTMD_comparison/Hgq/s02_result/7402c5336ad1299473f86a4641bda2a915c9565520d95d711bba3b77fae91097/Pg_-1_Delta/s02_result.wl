<|"Completed" -> True, "Channel" -> "Hgq", "Label" -> "Pg_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  -1/3*(alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
       16*Q^2*s + 7*s^2)*Log[Q]^2)/(Pi^3*(omega - Q^2)*(omega + s)) + 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*Log[Q]*Log[omega + s])/(3*Pi^3*(omega - Q^2)*
     (omega + s)) - (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 
      16*omega*s - 16*Q^2*s + 7*s^2)*Log[omega + s]^2)/
    (12*Pi^3*(omega - Q^2)*(omega + s)) - 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (-omega + Q^2 - s)/Q^2])/
    (6*Pi^3*(omega - Q^2)*(omega + s)) - 
   (alphaS^2*eq^2*(17*omega^2 - 16*omega*Q^2 + 8*Q^4 + 16*omega*s - 
      16*Q^2*s + 7*s^2)*PolyLog[2, (omega - Q^2 + s)/(omega + s)])/
    (6*Pi^3*(omega - Q^2)*(omega + s)), "Equal" -> False, 
 "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.014829193725821295407328423611840926204590\
1718947998418395531711477433605170896996369796456441061788615934023868251`85.\
21733279950689, -0.0148291937258212954073284236118409262045901718947998418395\
531711477433605170896996369796456441063355863683276409028`85.4516171007198}, 
    "Difference" -> 0``86.84671698270692, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.003900691082632721568960139988247610148518\
8936571306552845877015589148386666386302264694530274311491812214318833309`84.\
26676795818555, -0.0039006910826327215689601399882476101485188936571306552845\
877015589148386666386302264694530269830416120482580472803`84.86132662533404}, 
    "Difference" -> 0``86.57720572174868, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
   -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 10998388225327899332200644527\
8993092889495032574655508424279017151839939409813|>

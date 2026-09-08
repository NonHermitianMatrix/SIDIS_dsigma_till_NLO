<|"Completed" -> True, "Channel" -> "Hqq", "Label" -> "Pg_1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  (-8*alphaS^2*eq^2*(7*omega^2 + 14*omega*Q^2 + 16*Q^4 - 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[Q]^2)/(9*Pi^3*(omega - s)*s) + 
   (8*alphaS^2*eq^2*(7*omega^2 + 14*omega*Q^2 + 16*Q^4 - 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[Q]*Log[-omega + s])/(9*Pi^3*(omega - s)*s) - 
   (2*alphaS^2*eq^2*(7*omega^2 + 14*omega*Q^2 + 16*Q^4 - 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[-omega + s]^2)/(9*Pi^3*(omega - s)*s) - 
   (4*alphaS^2*eq^2*(7*omega^2 + 14*omega*Q^2 + 16*Q^4 - 16*omega*s + 
      2*Q^2*s + 17*s^2)*PolyLog[2, (omega + Q^2 - s)/Q^2])/
    (9*Pi^3*(omega - s)*s) - (4*alphaS^2*eq^2*(7*omega^2 + 14*omega*Q^2 + 
      16*Q^4 - 16*omega*s + 2*Q^2*s + 17*s^2)*
     PolyLog[2, (omega + Q^2 - s)/(omega - s)])/(9*Pi^3*(omega - s)*s), 
 "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.028499966478369971628331774690795118122187\
2444669647704119932765353959002507633911464865544927446955665326486246143`86.\
0233951066005, -0.02849996647836997162833177469079511812218724446696477041199\
32765353959002507633911464865545010563078255104290390172`88.03514152187962}, 
    "Difference" -> 0``87.5643441412066, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.035223672915176703434985111602770544315778\
5361132082356430636119691523703730209592604971518564237293238173774464882`85.\
24611549247321, -0.0352236729151767034349851116027705443157785361132082356430\
636119691523703730209592604971518564237310916022627993032`87.55393897417707}, 
    "Difference" -> 0``86.69714832783636, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < omega - s && 
   omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 11149450539523916361812660476\
2707478180834570662678280818741052812041521588223|>

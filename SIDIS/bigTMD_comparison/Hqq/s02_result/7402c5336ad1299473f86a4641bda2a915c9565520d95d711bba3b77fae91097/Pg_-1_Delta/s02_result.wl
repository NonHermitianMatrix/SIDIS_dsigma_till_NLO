<|"Completed" -> True, "Channel" -> "Hqq", "Label" -> "Pg_-1_Delta", 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183, "Difference" -> 
  (8*alphaS^2*eq^2*(7*omega^2 - 14*omega*Q^2 + 16*Q^4 + 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[Q]^2)/(9*Pi^3*s*(omega + s)) - 
   (8*alphaS^2*eq^2*(7*omega^2 - 14*omega*Q^2 + 16*Q^4 + 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[Q]*Log[omega + s])/(9*Pi^3*s*(omega + s)) + 
   (2*alphaS^2*eq^2*(7*omega^2 - 14*omega*Q^2 + 16*Q^4 + 16*omega*s + 
      2*Q^2*s + 17*s^2)*Log[omega + s]^2)/(9*Pi^3*s*(omega + s)) + 
   (4*alphaS^2*eq^2*(7*omega^2 - 14*omega*Q^2 + 16*Q^4 + 16*omega*s + 
      2*Q^2*s + 17*s^2)*PolyLog[2, (-omega + Q^2 - s)/Q^2])/
    (9*Pi^3*s*(omega + s)) + (4*alphaS^2*eq^2*(7*omega^2 - 14*omega*Q^2 + 
      16*Q^4 + 16*omega*s + 2*Q^2*s + 17*s^2)*
     PolyLog[2, (omega - Q^2 + s)/(omega + s)])/(9*Pi^3*s*(omega + s)), 
 "Equal" -> False, "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.025787087784315254730160877239861752558629\
9583233143446570258393781786620512247725816015442263527569759785570014556`86.\
10778099295537, -0.0257870877843152547301608772398617525586299583233143446570\
25839378178662051224772581601544226352742938895593847847`88.11897909621918}, 
    "Difference" -> 0``87.6921667893996, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {-0.031141245563504080505369717698131665401626\
7952646865646475480407042357726967805074043272370930293655293873538376212`85.\
52702046877744, -0.0311412455635040805053697176981316654016267952646865646475\
480407042357726967805074043272370752806778689978569431018`87.82395246076563}, 
    "Difference" -> 0``87.03149794377681, "Equal" -> True|>}, 
 "Assumptions" -> Q^2 > 0 && s > 0 && -Q^2 - s < -omega - s && 
   -omega - s < 0 && mu > 0 && B > 0 && Q > 0 && omega > 0 && 
   Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
   Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
 "AlgebraicMap" -> {}, "FreshDifferenceHash" -> 
  308286915959552673471399280812336239561338505088384972954585610662830184119\
2|>

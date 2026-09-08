<|"Definition" -> <|"Channel" -> "Hqq", "Label" -> "Ppp_1_L1", 
   "Left" -> (alphaS^2*eq^2*(56*omega + 56*Q^2))/(18*Pi^3), 
   "Right" -> (alphaS^2*eq^2*(-56*Q^4*(omega - s)^4*s^6 - 
       (omega - s)*s^2*(56*(omega - s)^5*s^4 + 112*(omega - s)^4*s^5 + 
         56*(omega - s)^3*s^6) + Q^2*s*(-112*(omega - s)^5*s^5 - 
         112*(omega - s)^4*s^6)))/(18*Pi^3*(omega + Q^2)*(omega - s)^3*s^6*
      (-omega + s)), "Assumptions" -> Q^2 > 0 && s > 0 && 
     -Q^2 - s < omega - s && omega - s < 0 && mu > 0 && B > 0 && Q > 0 && 
     omega > 0 && Element[nf, Integers] && nf >= 1 && alphaS > 0 && 
     Element[eq | otherChargeMoment[1] | otherChargeMoment[2], Reals], 
   "Kind" -> "L1"|>, "Difference" -> 
  (alphaS^2*eq^2*(56*omega + 56*Q^2))/(18*Pi^3) - 
   (alphaS^2*eq^2*(-56*Q^4*(omega - s)^4*s^6 - (omega - s)*s^2*
       (56*(omega - s)^5*s^4 + 112*(omega - s)^4*s^5 + 
        56*(omega - s)^3*s^6) + Q^2*s*(-112*(omega - s)^5*s^5 - 
        112*(omega - s)^4*s^6)))/(18*Pi^3*(omega + Q^2)*(omega - s)^3*s^6*
     (-omega + s)), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0089189428556008463917414071632571188207977\
620951050483809213651559146047431691230327932011325218228251201908204439`89.2\
3657200643706, 0.008918942855600846391741407163257118820797762095105048380921\
3651559146047431691230327932011325218228251201908204436`87.62565905972512}, 
    "Difference" -> 0``89.66483560540438, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0129324671406212272680250403867228222901567\
550379023201523359794760761768775952283975501416421566430964242766896437`89.2\
3194907652066, 0.012932467140621227268025040386722822290156755037902320152335\
9794760761768775952283975501416421566430964242766896431`87.83533914117604}, 
    "Difference" -> 0``89.70657318620826, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

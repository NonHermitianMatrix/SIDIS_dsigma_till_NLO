<|"Definition" -> <|"Channel" -> "Hqg", "Label" -> "F1_-1_L1", 
   "Left" -> (alphaS^2*eq^2*((Q^2*(352*omega + 352*s))/(18*Pi*(Q^2 + s)^2) - 
       (352*omega^2 + 352*Q^4 + 704*Q^2*s + 352*s^2)/(36*Pi*(omega - Q^2)*
         s)))/Pi^2, "Right" -> 16*alphaS^2*eq^2*Pi^2*
     (-1/288*(-176*Q^6*(-omega - s)^5*s^5 - (-omega - s)^3*s^2*
          (176*(-omega - s)^5*s^3 + 528*(-omega - s)^4*s^4 + 
           704*(-omega - s)^3*s^5 + 352*(-omega - s)^2*s^6) + 
         Q^2*(-omega - s)*s*(-176*(-omega - s)^6*s^4 - 704*(-omega - s)^5*
            s^5 - 704*(-omega - s)^4*s^6) + Q^4*(-176*(-omega - s)^6*s^5 - 
           528*(-omega - s)^5*s^6))/(Pi^5*(-omega + Q^2)^2*(-omega - s)^5*
         s^6) - (Q^2*(176*Q^4*(-omega - s)^5*s^6 + (-omega - s)*s^2*
          (176*(-omega - s)^6*s^4 + 352*(-omega - s)^5*s^5 + 
           176*(-omega - s)^4*s^6) + Q^2*s*(352*(-omega - s)^6*s^5 + 
           352*(-omega - s)^5*s^6)))/(144*Pi^5*(-omega + Q^2)^2*
        (-omega - s)^4*s^6*(Q^2 + s)^2)), "Assumptions" -> 
    Q > 0 && mu > 0 && s > 0 && -omega - s < 0 && -omega + Q^2 > 0 && 
     (-omega - s)*s < 0 && B > 0 && -omega != 0 && Element[nf, Integers] && 
     nf >= 0 && alphaS > 0 && Element[eq, Reals] && omega > 0, 
   "Kind" -> "L1", "ReferenceFile" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/\
SIDIS_20260907/bigTMD_comparison/Hqg/s01_result/reference/F1_-1_L1.wl"|>, 
 "Difference" -> 
  (alphaS^2*eq^2*((Q^2*(352*omega + 352*s))/(18*Pi*(Q^2 + s)^2) - 
      (352*omega^2 + 352*Q^4 + 704*Q^2*s + 352*s^2)/(36*Pi*(omega - Q^2)*s)))/
    Pi^2 - 16*alphaS^2*eq^2*Pi^2*
    (-1/288*(-176*Q^6*(-omega - s)^5*s^5 - (-omega - s)^3*s^2*
         (176*(-omega - s)^5*s^3 + 528*(-omega - s)^4*s^4 + 
          704*(-omega - s)^3*s^5 + 352*(-omega - s)^2*s^6) + 
        Q^2*(-omega - s)*s*(-176*(-omega - s)^6*s^4 - 704*(-omega - s)^5*
           s^5 - 704*(-omega - s)^4*s^6) + Q^4*(-176*(-omega - s)^6*s^5 - 
          528*(-omega - s)^5*s^6))/(Pi^5*(-omega + Q^2)^2*(-omega - s)^5*
        s^6) - (Q^2*(176*Q^4*(-omega - s)^5*s^6 + (-omega - s)*s^2*
         (176*(-omega - s)^6*s^4 + 352*(-omega - s)^5*s^5 + 
          176*(-omega - s)^4*s^6) + Q^2*s*(352*(-omega - s)^6*s^5 + 
          352*(-omega - s)^5*s^6)))/(144*Pi^5*(-omega + Q^2)^2*(-omega - s)^4*
       s^6*(Q^2 + s)^2)), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0393310645040982241873010866014140847575417\
113840622741876331361470328670895756977340780997503079940417700485857966`88.9\
7861565740145, 0.039331064504098224187301086601414084757541711384062274187633\
1361470328670895756977340780997503079940427645477294381`87.53718373142739}, 
    "Difference" -> 0``88.92700935015696, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0312237997617910435883844423597966651064662\
994928389588095632817416358690904484818759022777057922608552659991009224`88.9\
8781242050049, 0.031223799761791043588384442359796665106466299492838958809563\
2817416358690904484818759022777057922608555498643341889`87.78698951551551}, 
    "Difference" -> 0``89.26598018345355, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

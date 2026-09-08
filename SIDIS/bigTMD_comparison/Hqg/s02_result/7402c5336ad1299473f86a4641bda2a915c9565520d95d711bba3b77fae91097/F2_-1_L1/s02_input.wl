<|"Definition" -> <|"Channel" -> "Hqg", "Label" -> "F2_-1_L1", 
   "Left" -> (alphaS^2*eq^2*((Q^4*(352*omega + 352*s))/(3*Pi*(Q^2 + s)^3) - 
       (Q^2*(352*omega^2 + 352*Q^4 + 704*Q^2*s + 352*s^2))/
        (18*Pi*(omega - Q^2)*s*(Q^2 + s))))/Pi^2, 
   "Right" -> 16*alphaS^2*eq^2*Pi^2*
     (-1/144*(Q^2*(-176*Q^6*(-omega - s)^5*s^5 - (-omega - s)^3*s^2*
           (176*(-omega - s)^5*s^3 + 528*(-omega - s)^4*s^4 + 
            704*(-omega - s)^3*s^5 + 352*(-omega - s)^2*s^6) + 
          Q^2*(-omega - s)*s*(-176*(-omega - s)^6*s^4 - 704*(-omega - s)^5*
             s^5 - 704*(-omega - s)^4*s^6) + Q^4*(-176*(-omega - s)^6*s^5 - 
            528*(-omega - s)^5*s^6)))/(Pi^5*(-omega + Q^2)^2*(-omega - s)^5*
         s^6*(Q^2 + s)) - (Q^4*(176*Q^4*(-omega - s)^5*s^6 + 
         (-omega - s)*s^2*(176*(-omega - s)^6*s^4 + 352*(-omega - s)^5*s^5 + 
           176*(-omega - s)^4*s^6) + Q^2*s*(352*(-omega - s)^6*s^5 + 
           352*(-omega - s)^5*s^6)))/(24*Pi^5*(-omega + Q^2)^2*(-omega - s)^4*
        s^6*(Q^2 + s)^3)), "Assumptions" -> Q > 0 && mu > 0 && s > 0 && 
     -omega - s < 0 && -omega + Q^2 > 0 && (-omega - s)*s < 0 && B > 0 && 
     -omega != 0 && Element[nf, Integers] && nf >= 0 && alphaS > 0 && 
     Element[eq, Reals] && omega > 0, "Kind" -> "L1", 
   "ReferenceFile" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/b\
igTMD_comparison/Hqg/s01_result/reference/F2_-1_L1.wl"|>, 
 "Difference" -> 
  (alphaS^2*eq^2*((Q^4*(352*omega + 352*s))/(3*Pi*(Q^2 + s)^3) - 
      (Q^2*(352*omega^2 + 352*Q^4 + 704*Q^2*s + 352*s^2))/
       (18*Pi*(omega - Q^2)*s*(Q^2 + s))))/Pi^2 - 
   16*alphaS^2*eq^2*Pi^2*
    (-1/144*(Q^2*(-176*Q^6*(-omega - s)^5*s^5 - (-omega - s)^3*s^2*
          (176*(-omega - s)^5*s^3 + 528*(-omega - s)^4*s^4 + 
           704*(-omega - s)^3*s^5 + 352*(-omega - s)^2*s^6) + 
         Q^2*(-omega - s)*s*(-176*(-omega - s)^6*s^4 - 704*(-omega - s)^5*
            s^5 - 704*(-omega - s)^4*s^6) + Q^4*(-176*(-omega - s)^6*s^5 - 
           528*(-omega - s)^5*s^6)))/(Pi^5*(-omega + Q^2)^2*(-omega - s)^5*
        s^6*(Q^2 + s)) - (Q^4*(176*Q^4*(-omega - s)^5*s^6 + 
        (-omega - s)*s^2*(176*(-omega - s)^6*s^4 + 352*(-omega - s)^5*s^5 + 
          176*(-omega - s)^4*s^6) + Q^2*s*(352*(-omega - s)^6*s^5 + 
          352*(-omega - s)^5*s^6)))/(24*Pi^5*(-omega + Q^2)^2*(-omega - s)^4*
       s^6*(Q^2 + s)^3)), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0253515409608496705667395404099818563524252\
457248574717416152303084004013161216268920242431547053175437091207098479`88.8\
6377009935238, 0.025351540960849670566739540409981856352425245724857471741615\
2303084004013161216268920242431547053175437050052832951`87.4613243028087}, 
    "Difference" -> 0``89.04045903888162, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0285093858284518499322604467253174898470481\
951144273605162226851401882456902989290173531760732018624030515379183283`88.8\
6684341219495, 0.028509385828451849932260446725317489847048195114427360516222\
6851401882456902989290173531760732018624018967776139915`87.72119434205297}, 
    "Difference" -> 0``89.23621130970277, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>

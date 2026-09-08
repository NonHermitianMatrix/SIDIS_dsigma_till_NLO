<|"Definition" -> <|"Channel" -> "Hqg", "Label" -> "F2_1_L1", 
   "Left" -> (alphaS^2*eq^2*((Q^4*(-352*omega + 352*s))/(3*Pi*(Q^2 + s)^3) - 
       (Q^2*(-352*omega^2 - 352*Q^4 - 704*Q^2*s - 352*s^2))/
        (18*Pi*(omega + Q^2)*s*(Q^2 + s))))/Pi^2, 
   "Right" -> 16*alphaS^2*eq^2*Pi^2*
     (-1/144*(Q^2*(-176*Q^6*(omega - s)^5*s^5 - (omega - s)^3*s^2*
           (176*(omega - s)^5*s^3 + 528*(omega - s)^4*s^4 + 
            704*(omega - s)^3*s^5 + 352*(omega - s)^2*s^6) + 
          Q^2*(omega - s)*s*(-176*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
            704*(omega - s)^4*s^6) + Q^4*(-176*(omega - s)^6*s^5 - 
            528*(omega - s)^5*s^6)))/(Pi^5*(omega + Q^2)^2*(omega - s)^5*s^6*
         (Q^2 + s)) - (Q^4*(176*Q^4*(omega - s)^5*s^6 + 
         (omega - s)*s^2*(176*(omega - s)^6*s^4 + 352*(omega - s)^5*s^5 + 
           176*(omega - s)^4*s^6) + Q^2*s*(352*(omega - s)^6*s^5 + 
           352*(omega - s)^5*s^6)))/(24*Pi^5*(omega + Q^2)^2*(omega - s)^4*
        s^6*(Q^2 + s)^3)), "Assumptions" -> Q > 0 && mu > 0 && s > 0 && 
     omega - s < 0 && omega + Q^2 > 0 && (omega - s)*s < 0 && B > 0 && 
     omega != 0 && Element[nf, Integers] && nf >= 0 && alphaS > 0 && 
     Element[eq, Reals] && omega > 0, "Kind" -> "L1", 
   "ReferenceFile" -> "/u/scratch/r/rushil/AI_Assisted_SIDIS/SIDIS_20260907/b\
igTMD_comparison/Hqg/s01_result/reference/F2_1_L1.wl"|>, 
 "Difference" -> 
  (alphaS^2*eq^2*((Q^4*(-352*omega + 352*s))/(3*Pi*(Q^2 + s)^3) - 
      (Q^2*(-352*omega^2 - 352*Q^4 - 704*Q^2*s - 352*s^2))/
       (18*Pi*(omega + Q^2)*s*(Q^2 + s))))/Pi^2 - 
   16*alphaS^2*eq^2*Pi^2*
    (-1/144*(Q^2*(-176*Q^6*(omega - s)^5*s^5 - (omega - s)^3*s^2*
          (176*(omega - s)^5*s^3 + 528*(omega - s)^4*s^4 + 
           704*(omega - s)^3*s^5 + 352*(omega - s)^2*s^6) + 
         Q^2*(omega - s)*s*(-176*(omega - s)^6*s^4 - 704*(omega - s)^5*s^5 - 
           704*(omega - s)^4*s^6) + Q^4*(-176*(omega - s)^6*s^5 - 
           528*(omega - s)^5*s^6)))/(Pi^5*(omega + Q^2)^2*(omega - s)^5*s^6*
        (Q^2 + s)) - (Q^4*(176*Q^4*(omega - s)^5*s^6 + 
        (omega - s)*s^2*(176*(omega - s)^6*s^4 + 352*(omega - s)^5*s^5 + 
          176*(omega - s)^4*s^6) + Q^2*s*(352*(omega - s)^6*s^5 + 
          352*(omega - s)^5*s^6)))/(24*Pi^5*(omega + Q^2)^2*(omega - s)^4*s^6*
       (Q^2 + s)^3)), "NumericalChecks" -> 
  {<|"Point" -> {Q -> 2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0161523726720214551969878901066537886110982\
065042120355071351984870456541283271962690883938291107085507146274286299`88.8\
9458651268177, 0.016152372672021455196987890106653788611098206504212035507135\
198487045654128327196269088393829110708550720311139507`87.75079892971955}, 
    "Difference" -> 0``89.51244295693387, "Equal" -> True|>, 
   <|"Point" -> {Q -> 5/2, s -> 10, t -> -9, omega -> 1, mu -> 3, B -> 2, 
      nf -> 4, alphaS -> 1/5, eq -> 2/3, eqp -> -1/3, eq2 -> 4/9, 
      chargeSum -> 1, otherChargeMoment[1] -> 0, otherChargeMoment[2] -> 2/9, 
      s23 -> 1/7}, "Values" -> {0.0212782653628356083776651757387341823663610\
053770889409375219477934071098254378443381015603527952170042151731307517`88.8\
8249483035479, 0.021278265362835608377665175738734182366361005377088940937521\
9477934071098254378443381015603527952170033852511828839`87.90400459542059}, 
    "Difference" -> 0``89.53267563500305, "Equal" -> True|>}, 
 "InputHash" -> 5247318516002520293201507485156330584936199956604982999944190\
8389751776940183|>
